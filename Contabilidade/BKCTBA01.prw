#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKCTBA01
BK - Integra��o Contabiliza��o - Folha Rubi
@Return
@author Adilson do Prado / Marcos Bispo Abrah�o
@since 2010 Rev 06/07/20
@version P12
/*/

User Function BKCTBA01()
Private cString   := "SZ5"
Private cCadastro := "Contabiliza��o - Folha "+FWEmpName(cEmpAnt)
Private cPrw      := "BKCTBA01"

Private aRotina
private lMsErroAuto := .F.      

u_MsgLog(cPrw)

dbSelectArea("SZ5")
dbSetOrder(1)
DbGoTop()

aRotina := {{"Pesquisar" ,"AxPesqui"	,0, 1},;
			{"Visualizar","AxVisual"	,0, 2},;
            {"Importar",  "U_BKCTB01()" ,0, 3},;
            {"Alterar"	,"AxAltera"		,0,	4}}

//	{"Excluir"   ,"AxDeleta"	,0, 5},;


mBrowse(6,1,22,75,cString)

Return


User Function BKCTB01()
Local aAreaIni	:= GetArea()
Local nStatus	:= 0

// Verificar se h� Lan�amentos a importar
cQuery  := "SELECT COUNT(*) AS Z5STATUS " 
cQuery  += "FROM "+RETSQLNAME("SZ5")+" SZ5 WHERE Z5_STATUS = ' ' AND Z5_VALOR > 0 AND SZ5.D_E_L_E_T_ <> '*'"

TCQUERY cQuery NEW ALIAS "QSZ5"

DbSelectArea("QSZ5")
DbGoTop()
nStatus := QSZ5->Z5STATUS
QSZ5->(DbCloseArea())

IF nStatus > 0
   IF u_MsgLog(cPrw,"Confirma a importa��o de "+STRZERO(nStatus,6)+" lan�amentos ?","Y")
      u_WaitLog(, {|| RunCtb01() } )
      Return
   ENDIF
ELSE
   u_MsgLog(cPrw,"N�o h� lan�amentos para importar","W")    
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
	u_MsgLog(cPrw,"N�o h� lan�amentos gerados", "W")
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
		cErros += "Conta debito "+QSZ5->Z5_DEBITO+" n�o cadastrada"+CRLF
	ElseIf CT1->CT1_BLOQ = '1'
		cErros += "Conta debito "+QSZ5->Z5_DEBITO+" bloqueada"+CRLF
	EndIf

	If !dbSeek(xFilial("CT1")+QSZ5->Z5_CREDITO)
		cErros += "Conta cr�dito "+QSZ5->Z5_CREDITO+" n�o cadastrada"+CRLF
	ElseIf CT1->CT1_BLOQ = '1'
		cErros += "Conta credito "+QSZ5->Z5_CREDITO+" bloqueada"+CRLF
	EndIf

	If QSZ5->Z5_DEBITO == QSZ5->Z5_CREDITO
		cErros += "Conta cr�dito "+QSZ5->Z5_CREDITO+" igual a conta d�bito "+QSZ5->Z5_DEBITO+CRLF
	EndIf

	If !Empty(QSZ5->Z5_CC)
		dbSelectArea("CTT")
		If !dbSeek(xFilial("CTT")+QSZ5->Z5_CC)
			cErros += "Centro de custo "+QSZ5->Z5_CC+" n�o cadastrao"+CRLF
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
					   {'CT2_CONVER' ,'1' , NIL},;  // Conforme documenta��o da Totvs
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
			u_LogMsExec(cPrw,"Problemas na inclus�o de lan�amento - Evento "+cEvento)
			// O sistema n�o mostra erro de conta debito = credito, periodo fechado, centro de custo n�o cadastrado

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
	   u_MsgLog(cPrw,"N�o foi possivel importar todos os lan�amentos, erros poss�veis: conta debito = credito, periodo fechado e centro de custo n�o cadastrado.","E")
	   EXIT
	ENDIF
	DbSelectArea("QSZ5")
EndDo

QSZ5->(DbCloseArea())

Return  

