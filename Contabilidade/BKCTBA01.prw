#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE XEMPRESA	01
#DEFINE XANOMES		02
#DEFINE XCCC		03
#DEFINE XDESCCC		04
#DEFINE XDEBITO		05
#DEFINE XDESCDB		06
#DEFINE XCREDITO	07
#DEFINE XDESCCR		08
#DEFINE XEVENTO		09
#DEFINE XEVDESCR	10
#DEFINE XVALOR		11
//#DEFINE XDATARQ		12
#DEFINE XERROS		12


/*/{Protheus.doc} BKCTBA01
BK - Integração Contabilização - Folha Senior/ADP
@Return
@author Adilson do Prado / Marcos Bispo Abrahão
@since 2010 Rev 28/11/2024
@version P12
/*/

User Function BKCTBA01()
Private cString   := "SZ5"
Private cCadastro := "Contabilização - Folha "+FWEmpName(cEmpAnt)
Private cPrw      := "BKCTBA01"

Private aRotina
private lMsErroAuto := .F.      

u_MsgLog(cPrw)

dbSelectArea("SZ5")
dbSetOrder(1)
DbGoTop()

aRotina := {{"Pesquisar"				,"AxPesqui"		,0, 1},;
			{"Visualizar"				,"AxVisual"		,0, 2},;
            {"Importar TXT Folha ADP"	,"U_BKCTB1I()"	,0, 3},;
            {"Integrar Lançamentos"		,"U_BKCTB01()"	,0, 3},;
            {"Alterar"					,"AxAltera"		,0,	4}}

//	{"Excluir"   ,"AxDeleta"	,0, 5},;

mBrowse(6,1,22,75,cString)

Return


User Function BKCTB01()
Local aAreaIni	:= GetArea()
Local nStatus	:= 0

// Verificar se há Lançamentos a importar
cQuery  := "SELECT COUNT(*) AS Z5STATUS " 
cQuery  += "FROM "+RETSQLNAME("SZ5")+" SZ5 WHERE Z5_STATUS = ' ' AND Z5_VALOR > 0 AND SZ5.D_E_L_E_T_ <> '*'"

TCQUERY cQuery NEW ALIAS "QSZ5"

DbSelectArea("QSZ5")
DbGoTop()
nStatus := QSZ5->Z5STATUS
QSZ5->(DbCloseArea())

IF nStatus > 0
   IF u_MsgLog(cPrw,"Confirma a importação de "+STRZERO(nStatus,6)+" lançamentos ?","Y")
      u_WaitLog(, {|| RunCtb01() } )
      Return
   ENDIF
ELSE
   u_MsgLog(cPrw,"Não há lançamentos para importar","W")    
ENDIF
RestArea(aAreaIni)

Return Nil

 
Static Function RunCtb01()
Local aCab 		:= {}
Local aItens 	:= {}
Local aRecno	:= {}
Local aAreaIni	:= GetArea()
Local cQuery	:= ""
Local nI 		:= 0
Local dUDia
Local nMes
Local nAno
Local cDoc 		:= ""
Local cEvento 	:= ""
Local cErros 	:= ""

Private lMSHelpAuto := .F.
Private lAutoErrNoFile := .T.
      
dbSelectArea("SZ5")
dbSetOrder(1)
dbGoTop()
IF BOF() .OR. EOF()
	u_MsgLog(cPrw,"Não há lançamentos gerados", "W")
	RestArea(aAreaIni)
	Return
ENDIF

cQuery  := "SELECT Z5_FILIAL,Z5_ANOMES,Z5_CC,Z5_DEBITO,Z5_CREDITO,Z5_EVENTO,Z5_EVDESCR,Z5_VALOR,Z5_STATUS,R_E_C_N_O_ AS Z5RECNO " 
cQuery  += "FROM "+RETSQLNAME("SZ5")+" SZ5 "
cQuery  += "WHERE Z5_STATUS = ' ' AND SZ5.D_E_L_E_T_ <> '*' "
cQuery  += "AND Z5_VALOR > 0 "
//cQuery  += "GROUP BY Z5_FILIAL,Z5_ANOMES "
cQuery  += "ORDER BY Z5_FILIAL,Z5_ANOMES,Z5_EVENTO "

TCQUERY cQuery NEW ALIAS "QSZ5"
//TCSETFIELD("QSZ5","XX_DATAPGT","D",8,0)


// Marca os registros a serem importados
//cQuery := " UPDATE "+RetSqlName("SZ5")+" SET Z5_STATUS = 'X' WHERE Z5_STATUS = ' ' AND D_E_L_E_T_ <> '*' "
//TcSqlExec(cQuery)

lMsErroAuto := .F.
dbSelectArea("CT1")
dbSetOrder(1)

dbSelectArea("CTT")
dbSetOrder(1)

DbSelectArea("QSZ5")
DbGoTop()
Do While !eof()

	dbSelectArea("CT1")
	If !dbSeek(xFilial("CT1")+QSZ5->Z5_DEBITO)
		cErros += "Conta debito "+QSZ5->Z5_DEBITO+" não cadastrada"+CRLF
	ElseIf CT1->CT1_BLOQ = '1'
		cErros += "Conta debito "+QSZ5->Z5_DEBITO+" bloqueada"+CRLF
	EndIf

	If !dbSeek(xFilial("CT1")+QSZ5->Z5_CREDITO)
		cErros += "Conta crédito "+QSZ5->Z5_CREDITO+" não cadastrada"+CRLF
	ElseIf CT1->CT1_BLOQ = '1'
		cErros += "Conta credito "+QSZ5->Z5_CREDITO+" bloqueada"+CRLF
	EndIf

	If QSZ5->Z5_DEBITO == QSZ5->Z5_CREDITO
		cErros += "Conta crédito "+QSZ5->Z5_CREDITO+" igual a conta débito "+QSZ5->Z5_DEBITO+CRLF
	EndIf

	If !Empty(QSZ5->Z5_CC)
		dbSelectArea("CTT")
		If !dbSeek(xFilial("CTT")+QSZ5->Z5_CC)
			cErros += "Centro de custo "+QSZ5->Z5_CC+" não cadastrado"+CRLF
		EndIf
	EndIf

	DbSelectArea("QSZ5")
	dbSkip()
EndDo

If !Empty(cErros)
   u_MsgLog(cPrw,cErros,"E")
EndIf

DbSelectArea("QSZ5")
DbGoTop()
Do While !eof()
    nMes := VAL(SUBSTR(QSZ5->Z5_ANOMES,5,2))
    nAno := VAL(SUBSTR(QSZ5->Z5_ANOMES,1,4))
    nMes++
    IF nMes > 12
       nAno++
       nMes := 1
    ENDIF

    dUDia:= STOD(STRZERO(nAno,4)+STRZERO(nMes,2)+"01")
    dUDia:= dUDia - 1
	If VAL(QSZ5->Z5_ANOMES) > 0
		cDoc := 'E'+ALLTRIM(SUBSTR(QSZ5->Z5_EVENTO,1,5))
	Else
		cDoc := '000001'	
	EndIf

	aCab := { {'DDATALANC', dUDia,     NIL},;
	          {'CLOTE',     QSZ5->Z5_ANOMES,  NIL},;
	          {'CSUBLOTE',  '001',     NIL},;
	          {'CPADRAO',   '',        NIL},;
	          {'NTOTINF',   0,         NIL},;
	          {'NTOTINFLOT',0,         NIL}}

//	          {'CDOC',      cDoc /*STRZERO( seconds() ,6)*/ ,NIL},;

//NOPC,DDATALANC,CLOTE,CSUBLOTE,CDOC,LAGLUT,CSEQUENC,LCUSTO,LITEM,LCLVL,NTOTINF,CPROG,CPRELCTO,DREPROC,CEMPORI,CFILORI,@AFLAGCTB,@ACTKXCT2,@ATPSALDO,CMODOCLR,ASEQDIARIO,LMLTSLD,CSEQCORR		

	nLinha  := 1
    cFil    := QSZ5->Z5_FILIAL
    cAnoMes := QSZ5->Z5_ANOMES
	cEvento := QSZ5->Z5_EVENTO
    aItens  := {}
    aRecno  := {}
	Do While !eof() .AND. cFil == QSZ5->Z5_FILIAL .AND. cAnoMes == QSZ5->Z5_ANOMES .AND. cEvento == QSZ5->Z5_EVENTO
	
		//aAdd(aItens,{  {'CT2_FILIAL'  ,QSZ5->Z5_FILIAL,     NIL},;
		cCCD := ""
		cCCC := ""
		IF SUBSTR(QSZ5->Z5_DEBITO,1,1) == "3"
		   cCCD := QSZ5->Z5_CC
		ENDIF
		   
		IF SUBSTR(QSZ5->Z5_CREDITO,1,1) == "3"
		   cCCC := QSZ5->Z5_CC
		ENDIF
		
		aAdd(aItens,{  {'CT2_FILIAL' ,xFilial("CT2")     , NIL},;
					   {'CT2_LINHA'  ,STRZERO(nLinha++,3), NIL},;
		               {'CT2_MOEDLC' ,'01',                NIL},;
		               {'CT2_DC'     ,'3',                 NIL},;
		               {'CT2_DEBITO' ,QSZ5->Z5_DEBITO,     NIL},;
		               {'CT2_CREDIT' ,QSZ5->Z5_CREDITO,    NIL},;
		               {'CT2_CCD'    ,cCCD,                NIL},;
		               {'CT2_CCC'    ,cCCC,                NIL},;
		               {'CT2_VALOR'  ,QSZ5->Z5_VALOR,      NIL},;
		               {'CT2_ORIGEM' ,'BKCTBA01-'+QSZ5->Z5_EVENTO+'-'+SUBSTR(cUsuario,7,14)+'-'+QSZ5->Z5_ANOMES, NIL},;
		               {'CT2_HP'     ,'',                  NIL},;
					   {'CT2_CONVER' ,'1' , NIL},;  // Conforme documentação da Totvs
		               {'CT2_HIST'   ,'FOLHA PGTO '+SUBSTR(QSZ5->Z5_ANOMES,5,2)+'/'+SUBSTR(QSZ5->Z5_ANOMES,1,4)+' - '+TRIM(QSZ5->Z5_EVENTO)+"-"+TRIM(QSZ5->Z5_EVDESCR), NIL} } )


		aAdd(aRecno,QSZ5->Z5RECNO)
		
		DbSelectArea("QSZ5")
		DbSkip()
		If nLinha > 999
		   Exit
		EndIf   
	Enddo
		
	Begin Transaction
	
		lMsErroAuto := .F.
	    MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)
		
		IF lMsErroAuto

            DisarmTransaction()
            //MostraErro()

			//aerro := Mostraerro() 
			u_LogMsExec(cPrw,"Problemas na inclusão de lançamento - Evento "+cEvento)
			// O sistema não mostra erro de conta debito = credito, periodo fechado, centro de custo não cadastrado

		ENDIF
		
	End Transaction

    IF !lMsErroAuto
    	FOR nI := 1 TO LEN(aRecno)
       		dbSelectArea("SZ5")
       		dbGoTo(aRecno[nI])
	   		RecLock("SZ5",.F.)
	   		SZ5->Z5_STATUS := "P"
	   		MsUnlock()
	   	NEXT	
    ELSE
	   u_MsgLog(cPrw,"Não foi possivel importar todos os lançamentos, erros possíveis: conta debito = credito, periodo fechado e centro de custo não cadastrado.","E")
	   EXIT
	ENDIF
	DbSelectArea("QSZ5")
EndDo

QSZ5->(DbCloseArea())

Return  




/*/{Protheus.doc} BKCTB1A
BK - Importar txt lançamentos da Folha ADP

@Return
@author Marcos Bispo Abrahão
@since 13/05/2024
@version P12
/*/

User Function BKCTB1A()

Local cTipoArq	:= "Arquivos no formato TXT (*.TXT) | *.TXT | "
Local cTitulo	:= "Importar arquivo TXT de Lançamentos da Folha ADP"
Local oDlg01
Local oButSel
Local nOpcA		:= 0
Local nSnd		:= 15
Local nTLin		:= 15
Local lValid 	:= .T.
Local aLinha 	:= {}
Local cArq	:= ""

Private cProg	:= "BKCTB1A"

u_MsgLog(cProg)

DEFINE MSDIALOG oDlg01 FROM 100,10 TO 250,470 TITLE cProg+" - "+cTitulo PIXEL

@ nSnd,010  SAY "Arquivo TXT ADP: " of oDlg01 PIXEL 
@ nSnd -3,057 MSGET cArq SIZE 150,010 of oDlg01 PIXEL READONLY
nSnd += nTLin
@ nSnd -3,057 BUTTON oButSel PROMPT 'Selecionar' SIZE 40, 12 OF oDlg01 ACTION ( cArq := cGetFile(cTipoArq,"Selecione o arquivo TXT da ADP",,cArq,.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY,.F.,.T.)  ) PIXEL  // "Selecionar" 
nSnd += nTLin

DEFINE SBUTTON FROM nSnd, 125 TYPE 1 ACTION (oDlg01:End(),nOpcA:=1) ENABLE OF oDlg01
DEFINE SBUTTON FROM nSnd, 155 TYPE 2 ACTION (oDlg01:End(),,nOpcA:=0) ENABLE OF oDlg01

ACTIVATE MSDIALOG oDlg01 CENTER

If nOpcA == 1
	nOpcA:=0
	u_WaitLog(cProg, {|| aLinha := PCTB1A(cArq)}, "Carregando arquivo TXT...")
	If !Empty(aLinha)
		u_WaitLog(cProg, {|| lValid := PCTB1V(aLinha)}, "Validando dados...")
		If lValid
			If u_MsgLog(cProg,"Lançamentos validados com sucesso, deseja imprimir o lote?","Y")
				PCTB1I(aLinha,cArq)
			EndIf
			If u_MsgLog(cProg,"Confirma a importação dos lançamentos do lote?","Y")
				u_WaitLog(cProg, {|| lValid := PCTB1P(aLinha)}, "Importando dados...")
			EndIf
		Else
			If u_MsgLog(cProg,"Foram encontrados erros, deseja imprimir a relação de erros?","Y")
				PCTB1I(aLinha,cArq)
			EndIf
		EndIf
	Else
		u_MsgLog(cProg,"Lançamentos não importados, verifique o conteudo do arquivo "+cArq,"E")
	EndIf
Endif

RETURN NIL


User Function BKCTB1I()

Local nE	  := 0
Local aEmp 	  := u_BkGrupo(4)
Local lOk 	  := .F.
Local lAllOk  := .T.

Private cProg	:= "BKCTB1I"
Private aAcao	:= {"1-Incluir","2-Excluir","3-Excluir"}
Private nTotZ2	:= 0
Private cLote 	:= ""

If u_MsgLog(cProg,"Executar importação automática (todas empresas)","Y")

	For nE := 1 To Len(aEmp)

		u_WaitLog(cProg, {|| lOk := StartJob("u_BKCTB1J",GetEnvServer(),.T.,{aEmp[nE,1],"01",__cUserID})},"Processando empresa "+aEmp[nE,3])

		If !lOk
			u_MsgLog(cProg,"Problemas na importação da empresa "+aEmp[nE,2],"E")
			lAllOk := .F.
		EndIf
	Next
	If lAllOk
		u_MsgLog(cProg,"Processo finalizado","I")
	EndIf

EndIf
Return Nil



User Function BKCTB1J(aParam)
Local nI 		:= 0
Local cPasta	:= "\ADP\Contabilidade\"
Local aFiles	:= Directory(cPasta+"*.txt",,,.F.,2)
Local lValid 	:= .T.
Local aLinha 	:= {}
Local cAcao		:= ""
Local cEmpresa  := ""
Local cArq		:= ""
Local cAnexo 	:= ""
Local cMsg		:= ""
Local cMsgErr 	:= ""
Local cUser 	:= "000000"

Private cProg	:= "BKCTB1J"
Private nTotZ2	:= 0
Private cLote 	:= ""

Default aParam := {"01","01","000000"} 

If Len(aParam) > 2
	cUser := aParam[3]
EndIf

RpcSetType(3)
RpcSetEnv(aParam[1],aParam[2])

u_MsgLog(cProg,cEmpAnt+ " - "+cUser+" - "+ArrTokStr(aParam))


// Processar inclusões
For nI := 1 To Len(aFiles)
	If !Empty(aFiles[nI,1])
		cAcao	:= ""
		cArq 	:= cPasta+aFiles[nI,1]
		cMsg	:= ""
		cAnexo	:= ""
		lValid	:= .T.
		cMsgErr := ""

		lValid  := Ler1L(cArq,@cEmpresa)

		If lValid
			If cEmpresa == FWCodEmp()

				u_WaitLog(cProg, {|| aLinha := PCTB1A(cArq)}, "Carregando arquivo TXT...")
				If !Empty(aLinha)

					u_WaitLog(cProg, {|| lValid := PCTB1V(aLinha)}, "Validando dados...")
					cAnexo := PCTB1I(aLinha,cArq)

					If lValid
						
						u_WaitLog(cProg, {|| lValid := PCTB1P(aLinha)}, "Importando dados...")
						If lValid
							cMsg := "Lançamentos importados: "
							MoveArq(cArq,1)
						Else
							cMsg := "Lançamentos não importados: "+cMsgErr
							MoveArq(cArq,2)
						EndIf

					Else
						cMsg := "Foram encontrados erros, verifique o conteudo do arquivo "+cArq
						MoveArq(cArq,2)				
					EndIf
				Else
					cMsg := "Lançamentos não importados, verifique o conteudo do arquivo "+cArq
					//cAnexo := 
					MoveArq(cArq,2)
				EndIf

			EndIf
		Else
			cMsg := "Não foi possível abrir o arquivo ou conteúdo inválido "+cArq
			//cAnexo := 
			MoveArq(cArq,2)
		EndIf

		If !Empty(cMsg)
			SndMsg(cArq,cMsg,cAnexo,cUser)
			If !Isblind()
				u_MsgLog(cProg,cMsg,"I")
			EndIf
		EndIf
	EndIf
Next

RpcClearEnv()

Return .T.


// Ler a primeira linha para pegar ação e empresa
Static Function Ler1L(cArq,cEmpresa)

Local cBuffer := ""
Local nPos 	  := 1
Local lOk 	  := .F.

FT_FUSE(cArq)  //abrir
FT_FGOTOP() //vai para o topo

If !FT_FEOF()
 
	cBuffer := FT_FREADLN()  //lendo a linha

	If ( !Empty(cBuffer) )
		nPos := 1

		cEmpresa := SUBSTR(cBuffer,nPos,2)
		nPos += 2

	EndIf

EndIf

FT_FUSE()  //fecha o arquivo txt

Return lOk



Static FUNCTION PCTB1A(cArq)
Local cBuffer   := ""
Local nPos		:= 0
Local aLinha	:= {}

Local cEmpresa	:= ""
Local cAnoMes	:= ""
Local cCC 		:= ""
Local cDebito	:= ""
Local cCredito 	:= ""
Local cEvento	:= ""
Local cEvDescr	:= ""
Local cValor 	:= ""
Local nValor 	:= 0
//Local cDataArq	:= ""
//Local dDataArq	:= CTOD("")

dbSelectArea("SZ5")

FT_FUSE(cArq)  //abrir
FT_FGOTOP() //vai para o topo

While !FT_FEOF()
 
	//Capturar dados
	cBuffer := ""
	cBuffer := FT_FREADLN()  //lendo a linha
	//u_xxLog(u_SLogDir()+"BKCTBA04.LOG","1-"+cBuffer)

	If ( !Empty(cBuffer) )
		nPos := 1

		cEmpresa := SUBSTR(cBuffer,nPos,2)
		nPos += 2

		cAnoMes	:= SUBSTR(cBuffer,nPos,6)
		nPos += 6

		cCC	:= SUBSTR(cBuffer,nPos,9)
		nPos += 9

		cDebito	:= SUBSTR(cBuffer,nPos,20)
		nPos += 20

		cCredito := SUBSTR(cBuffer,nPos,20)
		nPos += 20

		cEvento := SUBSTR(cBuffer,nPos,5)
		nPos += 5

		// Evdescr -> Aumentado de 25 para 50 ADP 28/11/2024
		cEvDescr := SUBSTR(cBuffer,nPos,50)
		nPos += 50

		cValor := SUBSTR(cBuffer,nPos,12)
		nValor := VAL(cValor) / 100
		nPos += 12

		//cDataArq := SUBSTR(cBuffer,nPos,8)
		//dDataArq := STOD(cDataArq)
		//nPos += 8

		//aAdd(aLinha,{cEmpresa,cAnoMes,cCC,"",cDebito,"",cCredito,"",cEvento,cEvDescr,nValor,dDataArq,""})
		//cCC := "000000001"  // Teste
		aAdd(aLinha,{cEmpresa,cAnoMes,cCC,"",cDebito,"",cCredito,"",cEvento,cEvDescr,nValor,""})

    ENDIF
	FT_FSKIP()   //proximo registro no arquivo txt
Enddo
FT_FUSE()  //fecha o arquivo txt

RETURN aLinha


// Validação dos dados
Static Function PCTB1V(aLinha)
Local nI	:= 0
Local cErros:= ""
Local lOk 	:= .T.

CT1->(dbSetOrder(1))
CTT->(dbSetOrder(1))

For nI := 1 To Len(aLinha)

	cErros := ""

	If aLinha[nI,XEMPRESA] <> cEmpAnt
		cErros += "Empresa não correspondente "+TRIM(aLinha[nI,XEMPRESA])+"; "+CRLF
	EndIf

	If !CT1->(dbSeek(xFilial("CT1")+TRIM(aLinha[nI,XDEBITO])))
		cErros += "Conta debito "+TRIM(aLinha[nI,XDEBITO])+" não cadastrada; "+CRLF
	ElseIf CT1->CT1_BLOQ = '1'
		cErros += "Conta debito "+TRIM(aLinha[nI,XDEBITO])+" bloqueada; "+CRLF
	EndIf
	aLinha[nI,XDESCDB] := CT1->CT1_DESC01

	If !CT1->(dbSeek(xFilial("CT1")+TRIM(aLinha[nI,XCREDITO])))
		cErros += "Conta crédito "+TRIM(aLinha[nI,XCREDITO])+" não cadastrada; "+CRLF
	ElseIf CT1->CT1_BLOQ = '1'
		cErros += "Conta credito "+TRIM(aLinha[nI,XCREDITO])+" bloqueada; "+CRLF
	EndIf
	aLinha[nI,XDESCCR] := CT1->CT1_DESC01

	If aLinha[nI,XDEBITO] == aLinha[nI,XCREDITO]
		cErros += "Conta crédito igual a conta débito; "
	EndIf

	If !Empty(aLinha[nI,XCCC])
		If !CTT->(dbSeek(xFilial("CTT")+TRIM(aLinha[nI,XCCC])))
			cErros += "Centro de custo "+TRIM(aLinha[nI,XCCC])+" não cadastrado; "+CRLF
		EndIf
		aLinha[nI,XDESCCC] := CTT->CTT_DESC01
	EndIf

	aLinha[nI,XERROS] := cErros
	If !Empty(cErros)
		lOk := .F.
	EndIf
Next

Return lOk



Static Function PCTB1I(aLinha,cArq)
Local cTitulo	:= "Relação de Lote Contábil - ADP"
Local cDescr 	:= "O objetivo deste relatório é a impressão de lote via arquivo TXT fornecido pela ADP."
Local cVersao	:= "28/11/2024"
Local cArqXls	:= ""
Local oRExcel	AS Object
Local oPExcel	AS Object

// Definição do Arq Excel
oRExcel := RExcel():New(cProg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetVersao(cVersao)
oRExcel:SetDescr(cDescr)
oRExcel:SetParam({})

// Definição da Planilha 1
oPExcel:= PExcel():New(cProg,aLinha)
oPExcel:SetTitulo("Arquivo: "+cArq)

// Colunas da Planilha 1
oPExcel:AddCol("EMPRESA","u_BKNEmpr(xCampo,3)","Empresa","")
oPExcel:GetCol("EMPRESA"):SetTamanho(9)

oPExcel:AddColX3("Z5_ANOMES")
oPExcel:AddColX3("Z5_CC")

oPExcel:AddColX3("CTT_DESC01")
oPExcel:GetCol("CTT_DESC01"):SetTitulo("Descrição do Centro de Custos")

oPExcel:AddColX3("Z5_DEBITO")

oPExcel:AddCol("DESCDB","","Descrição da Conta Débito","")

oPExcel:AddColX3("Z5_CREDITO")

oPExcel:AddCol("DESCCR","","Descrição da Conta Crédito","")

oPExcel:AddColX3("Z5_EVENTO")
oPExcel:AddColX3("Z5_EVDESCR")

oPExcel:AddColX3("Z5_VALOR")
oPExcel:GetCol("Z5_VALOR"):SetTotal(.T.)

//oPExcel:AddColX3("Z5_DATAARQ")

oPExcel:AddCol("ERROS","","Erros","")
oPExcel:GetCol("ERROS"):SetTamanho(200)

// Adiciona a planilha 1
oRExcel:AddPlan(oPExcel)

// Cria arquivo Excel
cArqXls:= oRExcel:Create()

Return cArqXls



// Importando Dados para a Tabela SZ5
Static Function PCTB1P(aLinha)
Local nI	:= 0
Local lOk 	:= .T.

Local cEmpresa	:= ""
Local cAnoMes	:= ""
Local cCC 		:= ""
Local cDebito	:= ""
Local cCredito 	:= ""
Local cEvento	:= ""
Local cEvDescr	:= ""
Local nValor 	:= 0
//Local dDataArq	:= CTOD("")

dbSelectArea("SZ5")

For nI := 1 To Len(aLinha)

	cEmpresa	:= aLinha[nI,XEMPRESA]
	cAnoMes		:= aLinha[nI,XANOMES]
	cCC 		:= aLinha[nI,XCCC]
	cDebito		:= aLinha[nI,XDEBITO]
	cCredito	:= aLinha[nI,XCREDITO]
	cEvento		:= aLinha[nI,XEVENTO]
	cEvDescr	:= aLinha[nI,XEVDESCR]
	nValor 		:= aLinha[nI,XVALOR]
	//dDataArq	:= aLinha[nI,XDATARQ]

	RecLock("SZ5",.T.)
	SZ5->Z5_FILIAL	:= xFilial("SZ5")
	SZ5->Z5_ANOMES	:= cAnoMes
	SZ5->Z5_CC		:= cCC
	SZ5->Z5_DEBITO	:= cDebito
	SZ5->Z5_CREDITO	:= cCredito
	SZ5->Z5_EVENTO	:= cEvento
	SZ5->Z5_EVDESCR	:= cEvDescr
	SZ5->Z5_VALOR	:= nValor
	//SZ5->Z5_ORIGEM	:= "ADP"
	//SZ5->Z5_DATAARQ	:= dDataArq
	MsUnlock()

Next

Return lOk



Static Function MoveArq(cArq,nOpc)
Local cDrive, cDir, cNome, cExt
Local cArqPrc	:= ""

SplitPath( cArq, @cDrive, @cDir, @cNome, @cExt )

If Empty(cDir)
	cDir := "\"
EndIf

If nOpc == 1
	cDir += "processados\"
	cExt :=  ".PRC"
Else
	cDir += "rejeitados\"
	cExt :=  ".ERR"
EndIf
MakeDir(cDrive+cDir)

cArqPrc := cDrive+cDir+cNome+cExt
If nOpc == 2 .AND. File(cArqPrc)
	Ferase(cArqPrc)
EndIf

FRename(cArq,cArqPrc)

u_MsgLog(cProg,"Arquivo movido para: "+cArqPrc)

Return cArqPrc
