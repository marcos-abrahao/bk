#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"


#DEFINE XACAO		01
#DEFINE XEMPRESA	02
#DEFINE XTITULO		03
#DEFINE XPORTADOR	04
#DEFINE XTIPOPAG	05
#DEFINE XEMISSAO	06
#DEFINE XVENCTO		07
#DEFINE XHIST		08
#DEFINE XVALOR		09
#DEFINE XCC			10
#DEFINE XDESCCC		11
#DEFINE XERROS		12

/*/{Protheus.doc} BKFINA05
BK - Importar txt lançamentos da Folha ADP

Pasta FTP: \\vmfileserver\G$\ADP\Inbox

@Return
@author Marcos Bispo Abrahão
@since 01/01/2025
@version P12
/*/

User Function BKFINA05()

//Local cEmail 	:= LoadEmail()
Local nE	  := 0
Local aEmp 	  := u_BkGrupo(4)
Local lOk 	  := .F.
Local lAllOk  := .T.

Private cProg	:= "BKFINA05"
Private aAcao	:= {"1-Incluir","2-Excluir","3-Excluir"}
Private nTotZ2	:= 0
Private cLote 	:= ""

If u_MsgLog(cProg,"Executar integração automática (todas empresas)","Y")

	For nE := 1 To Len(aEmp)
		//u_WaitLog(cProg, {|| u_FINA05S({aEmp[nE,1],"01"}) }, "Processando "+aEmp[nE,2])

		u_WaitLog(cProg, {|| lOk := StartJob("u_FINA05S",GetEnvServer(),.T.,{aEmp[nE,1],"01",__cUserID})},"Processando empresa "+aEmp[nE,3])

		//lOk := uStartJob("u_FINA05S",GetEnvServer(),.T.,{aEmp[nE,1],"01",.T.})

		If !lOk
			u_MsgLog(cProg,"Problemas na integração da empresa "+aEmp[nE,2],"E")
			lAllOk := .F.
		EndIf
	Next
	If lAllOk
		u_MsgLog(cProg,"Processo finalizado","I")
	EndIf

EndIf
Return Nil


Static Function LoadEmail()  // Para testes
Local cEmail	:= ""
Local aUsers 	:= {__cUserID}
Local aGrupos	:= {u_GrpMFin(),u_GrpRHPJ()}
Local aDeptos	:= {}

cEmail	 := u_GprEmail(cEmail,aUsers,aGrupos,aDeptos)

Return cEmail




User Function FINA05S(aParam)
Local nI 		:= 0
Local cPasta	:= "\ADP\Financeiro\"
Local aFiles	:= Directory(cPasta+"*.txt",,,.F.,2)
Local lValid 	:= .T.
Local aLinha 	:= {}
Local cAcao		:= ""
Local cEmpresa  := ""
Local cArq		:= ""
Local cAnexo 	:= ""
Local cNum 		:= ""
Local cMsg		:= ""
Local cMsgErr 	:= ""
Local cUser 	:= "000000"

Private cProg	:= "FINA05S"
Private aAcao	:= {"1-Incluir","2-Excluir","3-Excluir"}
Private nTotZ2	:= 0
Private cLote 	:= ""

Default aParam := {"01","01","000000"} 

//u_MsgLog(cProg,ArrTokStr(aParam))

If Len(aParam) > 2
	cUser := aParam[3]
EndIf

RpcSetType(3)
RpcSetEnv(aParam[1],aParam[2])

u_MsgLog(cProg,cEmpAnt+ " - "+cUser+" - "+ArrTokStr(aParam))

// Processar Exclusões primeiro
For nI := 1 To Len(aFiles)
	cAcao	:= ""
	cArq 	:= cPasta+aFiles[nI,1]
	cMsg	:= ""
	cAnexo	:= ""
	lValid	:= .T.
	cMsgErr := ""

	lValid  := Ler1L(cArq,@cAcao,@cEmpresa)

	If lValid
		If cEmpresa == FWCodEmp() .AND. cAcao <> '1'

			u_WaitLog(cProg, {|| aLinha := PFIN5I(cArq,@cAcao)}, "Carregando arquivo "+cArq)
	
			cAnexo := PFIN5E(aLinha,cArq)

			If !Empty(aLinha)
				u_WaitLog(cProg, {|| lValid := PFIN5V(aLinha,cAcao,@cMsgErr)}, "Validando dados...")
				If lValid
					u_WaitLog(cProg, {|| lValid := PFIN5Z2E(aLinha,@cNum,@cMsgErr)}, "Excluindo dados...")
					If lValid
						cMsg := "Lançamentos excluídos: "+ALLTRIM(STR(nTotZ2,14,2))+" lote "+cLote
						MoveArq(cArq,1)
					Else
						cMsg := "Lançamentos não excluídos: "+cMsgErr
						MoveArq(cArq,2)
					EndIf
				Else
					cMsg := cMsgErr
					MoveArq(cArq,2)
				EndIf
			Else
				cMsg   := "Arquivo vazio ou problemas com o layout"
				MoveArq(cArq,2)
			EndIf
			aFiles[nI,1] := ""
		EndIf
	Else
		cMsg := "Não foi possível abrir o arquivo ou conteúdo inválido"
		cAnexo := MoveArq(cArq,2)
	EndIf
	
	If !Empty(cMsg)
		SndMsg(cArq,cMsg,cAnexo,cUser)
		If !Isblind()
			u_MsgLog(cProg,cMsg,"I")
		EndIf
	EndIf
		
Next


// Processar inclusões
For nI := 1 To Len(aFiles)
	If !Empty(aFiles[nI,1])
		cAcao	:= ""
		cArq 	:= cPasta+aFiles[nI,1]
		cMsg	:= ""
		cAnexo	:= ""
		lValid	:= .T.
		cMsgErr := ""

		lValid  := Ler1L(cArq,@cAcao,@cEmpresa)

		If lValid
			If cEmpresa == FWCodEmp() .AND. cAcao == '1'

				u_WaitLog(cProg, {|| aLinha := PFIN5I(cArq,@cAcao)}, "Carregando arquivo "+cArq)
				cAnexo := PFIN5E(aLinha,cArq)

				If !Empty(aLinha)
					u_WaitLog(cProg, {|| lValid := PFIN5V(aLinha,cAcao,@cMsgErr)}, "Validando dados...")
					If lValid
						u_WaitLog(cProg, {|| lValid := PFIN5Z2(aLinha,@cNum,@cMsgErr)}, "Importando dados...")
						If lValid
							cMsg := "Lançamentos importados: "+ALLTRIM(STR(nTotZ2,14,2))+" lote "+cLote+" titulo "+cNum
							MoveArq(cArq,1)
						Else
							cMsg := "Lançamentos não importados: "+cMsgErr
							MoveArq(cArq,2)
						EndIf
					Else
						cMsg := cMsgErr					
						MoveArq(cArq,2)
					EndIf
				Else
					cMsg   := "Arquivo vazio ou problemas com o layout"
					MoveArq(cArq,2)
				EndIf
			EndIf
		Else
			cMsg := "Não foi possível abrir o arquivo ou conteúdo inválido"
			cAnexo := MoveArq(cArq,2)
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



Static Function SndMsg(cArq,cErro,cAnexo,cUser)
Local cEmail	:= ""
Local cEmailCC	:= u_EmailAdm()
Local aUsers 	:= {cUser}
Local aGrupos	:= {u_GrpMFin(),u_GrpRHPJ()}
Local aDeptos	:= {}
Local cAssunto	:= "Integração ADP "
Local cMsg 		:= ""
Local aCabs   	:= {"Empresa","Arquivo","Mensagem"}
Local aMsg 		:= {{FWCodEmp(),cArq,cErro}}

cEmail	 := u_GprEmail(cEmail,aUsers,aGrupos,aDeptos)

cMsg := u_GeraHtmB(aMsg,cAssunto,aCabs,cProg,"",cEmail,cEmailCC)
u_BkSnMail(cProg,cAssunto,cEmail,cEmailCC,cMsg,iIf(!Empty(cAnexo),{cAnexo},nil),.F.)
u_MsgLog("SNDMSG",cEmail)

Return Nil


// Ler a primeira linha para pegar ação e empresa
Static Function Ler1L(cArq,cAcao,cEmpresa)

Local cBuffer := ""
Local nPos 	  := 1
Local lOk 	  := .F.
Local nHandle := 0

nHandle := FT_FUSE(cArq)  //abrir
If nHandle == -1
	Sleep(1000 * (Val(cEmpresa)+1))
	nHandle := FT_FUSE(cArq)
EndIf

If nHandle <> -1
	FT_FGOTOP() //vai para o topo

	If !FT_FEOF()

	
		cBuffer := FT_FREADLN()  //lendo a linha

		If ( !Empty(cBuffer) )
			nPos := 1

			cAcao	:= SUBSTR(cBuffer,nPos,1)
			nPos += 1

			cEmpresa := SUBSTR(cBuffer,nPos,2)
			nPos += 2

			If cAcao $ "123"
				lOk := .T.
			EndIf
		EndIf

	EndIf

	FT_FUSE()  //fecha o arquivo txt
EndIf

Return lOk



Static Function FINA05DLG()
Local cTipoArq	:= "Arquivos no formato TXT (*.TXT) | *.TXT | "
Local cTitulo	:= "Importar arquivo TXT de Lançamentos da Folha ADP"
Local oDlg01
Local oButSel
Local nOpcA		:= 0
Local nSnd		:= 15
Local nTLin		:= 15
Local lValid 	:= .T.
Local aLinha 	:= {}
Local cAcao		:= ""
Local cArq		:= ""
Local cNum 		:= ""
Local cMsg 		:= ""
Local cMsgErr 	:= ""
Local cAnexo 	:= ""

u_MsgLog(cProg)

DEFINE MSDIALOG oDlg01 FROM  100,10 TO 250,470 TITLE cProg+" - "+cTitulo PIXEL

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
	If File(cArq)
		u_WaitLog(cProg, {|| aLinha := PFIN5I(cArq,@cAcao)}, "Carregando arquivo TXT...")
		If !Empty(aLinha)
			u_WaitLog(cProg, {|| lValid := PFIN5V(aLinha,cAcao,@cMsgErr)}, "Validando dados...")
			If lValid
				If u_MsgLog(cProg,"Lançamentos validados com sucesso, deseja imprimir o lote?","Y")
					cAnexo := PFIN5E(aLinha,cArq)
				EndIf
				If cAcao == '1'
					If u_MsgLog(cProg,"Confirma a importação dos lançamentos do lote?","Y")
						u_WaitLog(cProg, {|| lValid := PFIN5Z2(aLinha,@cNum,@cMsgErr)}, "Importando dados...")
						If lValid

							cMsg := "Lançamentos importados: "+ALLTRIM(STR(nTotZ2,14,2))+" lote "+cLote+" titulo "+cNum
							u_MsgLog(cProg,cMsg,"S")

							MoveArq(cArq,1)

						Else

							cMsg := "Lançamentos não importados: "+cMsgErr
							u_MsgLog(cProg,cMsg,"E")

							MoveArq(cArq,2)
						EndIf
					EndIf
				Else
					If u_MsgLog(cProg,"Confirma a exclusão dos lançamentos do lote?","Y")
						u_WaitLog(cProg, {|| lValid := PFIN5Z2E(aLinha,@cNum,@cMsgErr)}, "Excluindo dados...")
						If lValid

							cMsg := "Lançamentos excluídos: "+ALLTRIM(STR(nTotZ2,14,2))+" lote "+cLote
							u_MsgLog(cProg,cMsg,"S")

							MoveArq(cArq,1)

						Else

							cMsg := "Lançamentos não excluídos: "+cMsgErr
							u_MsgLog(cProg,cMsg,"E")
	
							MoveArq(cArq,2)

						EndIf
					EndIf
				EndIf
			Else
				If u_MsgLog(cProg,"Foram encontrados erros, deseja imprimir a relação de erros? "+cMsgErr,"Y")
					cAnexo := PFIN5E(aLinha,cArq)
				EndIf
				cMsg := cMsgErr
				cAnexo := MoveArq(cArq,2)
			EndIf
		Else
			cMsg := "Lançamentos não importados, verifique o conteudo do arquivo "+cArq
			u_MsgLog(cProg,cMsg,"E")
			cAnexo := MoveArq(cArq,2)
		EndIf
	Else
		u_MsgLog(cProg,"Arquivo "+TRIM(cArq)+" não encontrado","E")
	EndIf

	If !Empty(cMsg)
		SndMsg(cArq,cMsg,cAnexo,__cUserID)
	EndIf
Endif

RETURN NIL


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


Static FUNCTION PFIN5I(cArq,cAcao)
Local cBuffer   := ""
Local nPos		:= 0
Local aLinha	:= {}

Local cEmpresa	:= ""
Local cTitulo 	:= ""
Local cPortador	:= ""
Local cTipoPag	:= ""
Local cEmissao	:= ""
Local cVencto 	:= ""
Local cHist 	:= ""
Local cValor 	:= ""
Local nValor 	:= 0
Local cCC 		:= ""

cLote := ""

FT_FUSE(cArq)  //abrir
FT_FGOTOP() //vai para o topo

While !FT_FEOF()
 
	//Capturar dados
	cBuffer := ""
	cBuffer := FT_FREADLN()  //lendo a linha
	//u_xxLog(u_SLogDir()+"BKCTBA04.LOG","1-"+cBuffer)

	If ( !Empty(cBuffer) )
		nPos := 1

		cAcao	:= SUBSTR(cBuffer,nPos,1)
		nPos += 1

		cEmpresa := SUBSTR(cBuffer,nPos,2)
		nPos += 2

		//cTitulo	:= "ADP"+SUBSTR(cBuffer,nPos,9)
		cTitulo	:= SUBSTR(cBuffer,nPos,14)
		If Empty(cLote)
			cLote := cTitulo
		EndIf
		nPos += 14

		cPortador := SUBSTR(cBuffer,nPos,3)
		nPos += 3

		cTipoPag := SUBSTR(cBuffer,nPos,4)
		nPos += 4

		cEmissao := STOD(SUBSTR(cBuffer,nPos,8))
		nPos += 8

		cVencto := STOD(SUBSTR(cBuffer,nPos,8))
		nPos += 8

		// Evdescr -> Aumentado de 25 para 50 ADP 28/11/2024
		cHist := SUBSTR(cBuffer,nPos,80)
		nPos += 80

		cValor := SUBSTR(cBuffer,nPos,14)
		nValor := VAL(cValor) / 100
		nPos += 14

		cCC := SUBSTR(cBuffer,nPos,9)
		nPos += 9

		//aAdd(aLinha,{cEmpresa,cAnoMes,cCC,"",cDebito,"",cCredito,"",cEvento,cEvDescr,nValor,dDataArq,""})
		//cCC := "000000001"  // Teste
		aAdd(aLinha,{cAcao,cEmpresa,cTitulo,cPortador,cTipoPag,cEmissao,cVencto,cHist,nValor,cCC,"",""})

    ENDIF
	FT_FSKIP()   //proximo registro no arquivo txt
Enddo
FT_FUSE()  //fecha o arquivo txt

RETURN aLinha


// Validação dos dados
Static Function PFIN5V(aLinha,cAcao,cMsgErr)
Local nI	:= 0
Local cErros:= ""
Local lOk 	:= .T.
Local aLotes:= {}

CTT->(dbSetOrder(1))

For nI := 1 To Len(aLinha)

	cErros := ""

	If !(aLinha[nI,XACAO] $ '123')
		cErros += "Ação não disponível "+IIF(aLinha[nI,XACAO] $ '123',aAcao[VAL(aLinha[nI,XACAO])],TRIM(aLinha[nI,XACAO]))+"; "+CRLF
	EndIf

	If aLinha[nI,XEMPRESA] <> FWCodEmp()
		cErros += "Empresa não correspondente "+TRIM(aLinha[nI,XEMPRESA])+"; "+CRLF
	EndIf

	If !Empty(aLinha[nI,XCC])
		If !CTT->(dbSeek(xFilial("CTT")+TRIM(aLinha[nI,XCC])))
			cErros += "Centro de custo "+TRIM(aLinha[nI,XCC])+" não cadastrado; "+CRLF
		EndIf
		aLinha[nI,XDESCCC] := CTT->CTT_DESC01
	EndIf

	aLinha[nI,XERROS] := cErros
	If !Empty(cErros)
		lOk := .F.
	EndIf

	If aScan(aLotes,aLinha[nI,XTITULO]) == 0
		aAdd(aLotes,aLinha[nI,XTITULO])
	EndIf
Next

//Consistir Lotes
If lOk
	lOk := VldLote(aLotes,cAcao,@cMsgErr)
EndIf

Return lOk



Static Function PFIN5E(aLinha,cArq)
Local cTitulo	:= "Relação de Lote Financeiro - ADP"
Local cDescr 	:= "O objetivo deste relatório é a impressão de lote via arquivo TXT fornecido pela ADP."
Local cVersao	:= "02/01/2025"
Local cArqXls   := ""
Local cProg		:= "PFIN5E"
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
//aAcao[VAL(xCampo)]
oPExcel:AddCol("ACAO","aAcao[VAL(xCampo)]","Ação","")
oPExcel:GetCol("ACAO"):SetTamanho(9)

oPExcel:AddCol("EMPRESA","u_BKNEmpr(xCampo,3)","Empresa","")
oPExcel:GetCol("EMPRESA"):SetTamanho(9)

oPExcel:AddColX3("Z2_CTRID")
oPExcel:AddColX3("Z2_BANCO")
oPExcel:AddColX3("Z2_TIPO")

oPExcel:AddColX3("Z2_DATAEMI")
oPExcel:AddColX3("Z2_DATAPGT")
oPExcel:AddColX3("Z2_OBSTITU")

oPExcel:AddColX3("Z2_VALOR")
oPExcel:GetCol("Z2_VALOR"):SetTotal(.T.)

oPExcel:AddColX3("Z2_CC")

oPExcel:AddColX3("CTT_DESC01")
oPExcel:GetCol("CTT_DESC01"):SetTitulo("Descrição do Centro de Custos")

oPExcel:AddCol("ERROS","","Erros","")
oPExcel:GetCol("ERROS"):SetTamanho(200)

// Adiciona a planilha 1
oRExcel:AddPlan(oPExcel)

// Cria arquivo Excel
cArqXls:= oRExcel:Create()

Return cArqXls



// Importando Dados para a Tabela SZ2
Static Function PFIN5Z2(aLinha,cNum,cMsgErr)
Local nI		:= 0
Local lOk		:= .T.
Local cCtrId	:= "" //DTOS(date())+SubStr( TIME(), 1, 2 )+SubStr( TIME(), 4, 2 )+SubStr( TIME(), 7, 2 )
Local cLote		:= ""
Local cTipBK	:= ""
Local cBanco 	:= ""
Local dEmissao  := dDataBase
Local dPgto 	:= dDataBase
Local cHist 	:= ""
Local aZ2 		:= {}

nTotZ2 := 0

dbSelectArea("SZ2")

//ASORT(aLinha,,,{|x,y| x[XTITULO]<y[XTITULO]})

For nI := 1 To Len(aLinha)

	If nI == 1 //aLinha[nI,XTITULO] <> cLote .OR. Empty(cLote)
		cLote 	:= aLinha[nI,XTITULO]
		cCtrId	:= cLote // DTOS(date())+SubStr( TIME(), 1, 2 )+SubStr( TIME(), 4, 2 )+SubStr( TIME(), 7, 2 )
		cBanco	:= aLinha[nI,XPORTADOR]
		cTipBK 	:= aLinha[nI,XTIPOPAG]
		dEmissao:= aLinha[nI,XEMISSAO]
		dPgto 	:= aLinha[nI,XVENCTO]
		cHist 	:= aLinha[nI,XHIST]
	EndIf

	RecLock("SZ2",.T.)
	SZ2->Z2_FILIAL	:= xFilial("SZ2")
	SZ2->Z2_CODEMP	:= aLinha[nI,XEMPRESA]
	SZ2->Z2_E2NUM	:= aLinha[nI,XTITULO]
	SZ2->Z2_BANCO	:= aLinha[nI,XPORTADOR]
	SZ2->Z2_TIPO	:= aLinha[nI,XTIPOPAG]
	SZ2->Z2_DATAEMI	:= aLinha[nI,XEMISSAO]
	SZ2->Z2_DATAPGT	:= aLinha[nI,XVENCTO]
	SZ2->Z2_OBSTITU	:= aLinha[nI,XHIST]
	SZ2->Z2_VALOR	:= aLinha[nI,XVALOR]
	SZ2->Z2_CC		:= aLinha[nI,XCC]
	
	SZ2->Z2_DORIPGT	:= aLinha[nI,XVENCTO]

	SZ2->Z2_CTRID	:= cCtrId
	SZ2->Z2_PRONT	:= "000000"
	SZ2->Z2_NOME	:= "LOTE "+aLinha[nI,XTITULO]
	SZ2->Z2_STATUS	:= " "
	SZ2->Z2_USUARIO	:= cUserName
	SZ2->Z2_PRODUTO	:= "21301001"
	SZ2->Z2_TIPOPES	:= "CLT"

	nTotZ2 += aLinha[nI,XVALOR]

	SZ2->(MsUnlock())
	
	aAdd(aZ2,SZ2->(RecNo()))

Next
// Gravar SE2
cNum := GravaSe2(cCtrId,cBanco,cTipBK,dEmissao,dPgto,cHist,nTotZ2,aZ2)

Return lOk



// Excluindo Dados das Tabelas SE2 e SZ2
Static Function PFIN5Z2E(aLinha,cNum,cMsgErr)
Local lOk		:= .T.
Local cQuery 	:= ""

// Tabela SE2
cQuery := "SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_PARCELA,E2_TIPO, E2_FORNECE,E2_LOJA "+CRLF
cQuery += " FROM "+RetSqlName("SE2")+ " SE2 "+CRLF
cQuery += " WHERE E2_XXCTRID = '"+cLote+ "' AND D_E_L_E_T_ = ''"
TCQUERY cQuery NEW ALIAS "QSE2"

DbSelectArea("QSE2")
DbGoTop()
Do While !EOF()

	cNum := QSE2->E2_NUM

	aVetor:={{"E2_FILIAL"   ,QSE2->E2_FILIAL,Nil},;
             {"E2_PREFIXO"  ,QSE2->E2_PREFIXO,Nil},;
             {"E2_NUM"      ,QSE2->E2_NUM,Nil},;
             {"E2_PARCELA"  ,QSE2->E2_PARCELA,Nil},;
             {"E2_TIPO"     ,QSE2->E2_TIPO,Nil},;        
	         {"E2_FORNECE"  ,QSE2->E2_FORNECE,Nil},; 
	         {"E2_LOJA"     ,QSE2->E2_LOJA,Nil}}
		             
	lMsErroAuto := .F.  
	Begin Transaction 
		MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetor,,5) //Exclusão
		IF lMsErroAuto
			cMsgErr := "Problemas na exclusão do titulo "+QSE2->E2_NUM
			u_LogMsExec("PFIN5Z2E",cMsgErr)
			DisarmTransaction()
			lOk := .F.
		EndIf
	End Transaction
	DbSelectArea("QSE2")
	dbSkip()
EndDo

QSE2->(DbCloseArea())

If lOk

	// Tabela SZ2
	cQuery := "SELECT R_E_C_N_O_ AS RECNO "+CRLF
	cQuery += " FROM "+RetSqlName("SZ2")+ " SZ2 "+CRLF
	cQuery += " WHERE Z2_CTRID = '"+cLote+ "' AND D_E_L_E_T_ = ''"
	TCQUERY cQuery NEW ALIAS "QSZ2"

	DbSelectArea("QSZ2")
	DbGoTop()
	Do While !EOF()

		dbSelectArea("SZ2")
		dbGoTo(QSZ2->RECNO)

		RecLock("SZ2",.F.)
		dbDelete()
		SZ2->(MsUnlock())

		DbSelectArea("QSZ2")
		dbSkip()

	EndDo
EndIf
QSZ2->(DbCloseArea())

Return lOk




Static Function VldLote(aLotes,cAcao,cMsgErr)
Local cQuery        := ""
Local aReturn       := {}
Local aBinds        := {}
Local aSetFields    := {}
Local nRet          := 0
Local nI            := 0
Local nLotes 		:= 0
Local lOk 			:= .T.
Local cLotes 		:= ""

For nI := 1 TO LEN(aLotes)

    If nI > 1
        cQuery += "UNION ALL "+CRLF
    EndIf
    cQuery += "SELECT COUNT(*) AS NLOTES"+CRLF 
    cQuery += " FROM "+RETSQLNAME("SZ2")+" SZ2 "+CRLF
    cQuery += " WHERE Z2_CTRID = '"+aLotes[nI]+"' AND D_E_L_E_T_ = ' ' "+CRLF

	cLotes += aLotes[nI]+" "
Next 

//aadd(aBinds,xFilial("SA1")) // Filial
//aadd(aBinds,"000281") // Codigo
//aadd(aBinds,"01") // Loja

// Ajustes de tratamento de retorno
aadd(aSetFields,{"NLOTES"   ,"N",5,0})

//aadd(aSetFields,{"A1_ULTVIS","D",8,0})

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

If nRet < 0
	cMsgErr := tcsqlerror()+" - Falha ao executar a Query: "+cQuery
	u_MsgLog("BKFINA05-L",cMsgErr,"E")
Else
  //Alert(VarInfo("aReturn",aReturn))
  //MsgInfo("Verifique os valores retornados no console","Ok")
  If Len(aReturn) > 0
	nLotes := aReturn[1][1]
	If cAcao == '1'
		If nLotes > 0
			lOk := .F.
			cMsgErr := "Lote(s) já importado(s): "+cLotes+", verifique o arquivo"
			u_MsgLog("BKFINA05-V"+cAcao,cMsgErr,"E")
		EndIf
	Else
		If nLotes <= 0
			lOk := .F.
			cMsgErr := "Lote(s) não encontrados(s): "+cLotes+", verifique o arquivo"
			u_MsgLog("BKFINA05-V"+cAcao,cMsgErr,"E")
		EndIf
	EndIf
  EndIf
Endif
Return lOk


Static Function GravaSe2(cCtrId,cBanco,cTipBk,dEmissao,dPgto,cHist,nValor,aZ2)
Local cxFilial 
Local cPrefixo
Local cNum		:= ""
Local cParcela
Local cTipo
Local cFornece
Local cLoja
Local cPortado
Local cPortadoPA
Local cKey1
Local nI      := 0
Local cNaturez:= "0000000013"
Local cFornBK := u_cFornBK()
Local lErroT  := .F.

dbSelectArea("SE2")
dbSetOrder(1)
// E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
dbGoTop()

cxFilial := xFilial("SE2")
cPrefixo := PAD("LF",LEN(SE2->E2_TIPO))
cNum	 := PAD(STRZERO(VAL(ProxNum(.T.)),6)+cTipBK,LEN(SE2->E2_NUM))
cParcela := SPACE(LEN(SE2->E2_PARCELA))
cTipo    := PAD("DP",LEN(SE2->E2_TIPO))
cNaturez := PAD(cNaturez,LEN(SE2->E2_NATUREZ))
cFornece := PAD(cFornBK,LEN(SE2->E2_FORNECE))
cLoja 	 := PAD("01",LEN(SE2->E2_LOJA))
cPortado := PAD(cBanco,LEN(SE2->E2_PORTADO))
cPortadoPA := PAD(cBanco,LEN(SE2->E2_PORTADO))

cTipBk   := PAD(cTipBk,LEN(SE2->E2_XXTIPBK))
cCtrId   := PAD(cCtrId,LEN(SE2->E2_XXCTRID))

cKey1    := cxFilial+cPrefixo+cNum+cParcela+cTipo+cFornece+cLoja
//cKey2    := xFilial("SZ2")+SM0->M0_CODIGO+cCtrId+cTipBk+cPortado  //+DTOS(dVencto)
	
aVetor :={{"E2_FILIAL"   ,cxFilial,Nil},;
          {"E2_PREFIXO"  ,cPrefixo,Nil},;
          {"E2_NUM"      ,cNum,Nil},;
          {"E2_PARCELA"  ,cParcela,Nil},;
          {"E2_TIPO"     ,cTipo,Nil},;        
          {"E2_FORNECE"  ,cFornece,Nil},; 
          {"E2_LOJA"     ,cLoja,Nil},;      
          {"E2_NATUREZ"  ,cNaturez,Nil},;
          {"E2_PORTADO"  ,cPortado,Nil},;
          {"AUTBANCO"    ,cPortadoPA,NIL},;
	      {"AUTAGENCIA"  ,""      ,NIL},; 
	      {"AUTCONTA"    ,""      ,NIL},;
          {"AUTCHEQUE"   ,""      ,NIL},;
          {"E2_XXTIPBK"  ,cTipBk,Nil},;
          {"E2_XXCTRID"  ,cCtrId,Nil},;
          {"E2_XXORIG"   ,"ADP",Nil},;
          {"E2_XXRHLIB"  ,"ADP",Nil},;
          {"E2_XXRHUSR"  ,"ADP",Nil},;
          {"E2_XXRHTDE"  ,dEmissao,Nil},;
          {"E2_XXRHDTL"  ,dEmissao,Nil},;
          {"E2_HIST"     ,"ADP RH - "+TRIM(cHist),NIL},;
          {"E2_EMISSAO"  ,dEmissao,NIL},;
          {"E2_VENCTO"   ,dPgto,NIL},;                
          {"E2_EMIS1"    ,dEmissao,NIL},;              
          {"E2_VALOR"    ,nValor,Nil},;
          {"F4_APLIIVA"  ,"2",Nil},;
          {"E2_MOEDA"    ,1  , Nil},;
          {"ED_REDCOF"   ,0  , Nil},;
          {"ED_REDPIS"   ,0  , Nil}}

lErroT := .F.

Begin Transaction

	lMsErroAuto := .F.   
	MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetor,,3) //Inclusao

	IF lMsErroAuto

		u_LogMsExec("BKFINA02")
		DisarmTransaction()
		lErroT := .T.
	ENDIF	

END Transaction

If lErroT
	Return ""
EndIf

For nI := 1 To Len(aZ2)

	SZ2->(dbGoTo(aZ2[nI]))	
	RecLock("SZ2",.F.)
	SZ2->Z2_STATUS := "S"
	SZ2->Z2_TITULO := cKey1
	SZ2->Z2_E2Prf  := cPrefixo
	SZ2->Z2_E2Num  := cNum
	SZ2->Z2_E2Parc := cParcela
	SZ2->Z2_E2Tipo := cTipo
	SZ2->Z2_E2Forn := cFornece
	SZ2->Z2_E2Loja := cLoja
	SZ2->(MsUnlock())

Next	
Return cNum






Static Function ExcluiSe2(aTitGer,aCtrId)
Local cKey,cCtrId,aTitErr:= {}
Local nI,lOk := .T.
Local aEmail1 := {}
Local aEmail2 := {}

dbSelectArea("SE2")
dbSetOrder(1)
// E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

dbGoTop()

For nI := 1 TO LEN(aTitGer)
    cKey := aTitGer[nI,2]
	If aTitGer[nI,1] = "S"
	    If !MsSeek(cKey)
	    	lOk := .F.
			u_MsgLog(,"Titulo "+cKey+" não existe, informe o setor de T.I.", "E")
	    Else
		    Processa ( {|| ExcluiBord(cKey)})
			aVetor:={{"E2_FILIAL"   ,SE2->E2_FILIAL,Nil},;
		             {"E2_PREFIXO"  ,SE2->E2_PREFIXO,Nil},;
		             {"E2_NUM"      ,SE2->E2_NUM,Nil},;
		             {"E2_PARCELA"  ,SE2->E2_PARCELA,Nil},;
		             {"E2_TIPO"     ,SE2->E2_TIPO,Nil},;        
		             {"E2_FORNECE"  ,SE2->E2_FORNECE,Nil},; 
		             {"E2_LOJA"     ,SE2->E2_LOJA,Nil}}
		             
			lMsErroAuto := .F.  
			Begin Transaction 
				MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetor,,5) //Exclusão
				IF lMsErroAuto
					u_LogMsExec("BKFINA03","Problemas na exclusão do titulo "+cKey)
					AADD(aTitErr,cKey)
					DisarmTransaction()
				EndIf
			End Transaction
	    Endif	
	Else    
	   AADD(aTitErr,cKey)
	Endif
Next
dbSelectArea("SZ2")
dbSetOrder(2)
FOR nI := 1 TO LEN(aCtrId)
	IF aCtrId[nI,1]
	   cCtrId := aCtrId[nI,2]
	   //dbGoTop()
	   dbSeek(xFilial("SZ2")+SM0->M0_CODIGO+cCtrId,.T.)
	   DO WHILE !EOF() .AND. xFilial("SZ2")+SM0->M0_CODIGO+cCtrId == SZ2->Z2_FILIAL+SZ2->Z2_CODEMP+SZ2->Z2_CTRID
	      IF SZ2->Z2_STATUS == "S" .AND. ASCAN(aTitErr,cE2Filial+SZ2->Z2_E2PRF+SZ2->Z2_E2NUM+SZ2->Z2_E2PARC+SZ2->Z2_E2TIPO+SZ2->Z2_E2FORN+SZ2->Z2_E2LOJA) = 0
		     RecLock("SZ2",.F.)
	      	 SZ2->Z2_STATUS := "D"
	      	 SZ2->Z2_OBS    := "Titulo excluido: "+DTOC(DATE())+"-"+TIME()
	    	 IF SUBSTR(SZ2->Z2_TIPOPES,1,3) <> "CLT"
	    	    AADD(aEmail1,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,SZ2->Z2_OBS,SZ2->Z2_E2PRF+SZ2->Z2_E2NUM,SZ2->Z2_CTRID})
	    	 ELSE
                //lCLT := .T.
	    	    AADD(aEmail2,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,SZ2->Z2_OBS,SZ2->Z2_E2PRF+SZ2->Z2_E2NUM,SZ2->Z2_CTRID})
	    	 ENDIF
		     MsUnlock()
	      ENDIF	 
		  dbSkip()
	   ENDDO  
	ENDIF
NEXT

If LEN(aEmail1) > 0 // AC
	U_Fina04E(aEmail1,.F.)
EndIf	
If LEN(aEmail2) > 0 // CLT
	U_Fina04E(aEmail2,.T.)
EndIf

Return lOk
