#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINA04
BK - Liquidos - Folha BK - Alteração de titulos (antes da baixa)
@Return
@author Marcos Bispo Abrahão
@since 29/09/2009
@version P12
/*/
//-------------------------------------------------------------------


/*
User Function BKFINA04A()
// Alteração
BkFina04(.F.)
Return Nil


User Function BKFINA04C()
// Consulta
BkFina04(.T.)
Return nil
*/

User Function BKFINA04(lConsulta)
Local oOk
Local oNo
Local oDlg
Local oListId
Local oPanelLeft
Local aButtons := {}

Local aCtrId,aTitGer
Local lOk      := .F.
Local aAreaIni := GetArea()
Local cQuery
Local nI
Local lTitOk   := .T.
Local lAltOk1
Local cMsgEx   := SPACE(50)

PRIVATE cxFilial,cPrefixo,cNum,cParcela,cTipo,cFornece,cLoja,nValTit
PRIVATE cObs

dbSelectArea("SE2")
IF BOF() .OR. EOF()
	MsgStop("Selecione um titulo!", "Atenção")
	RestArea(aAreaIni)
	Return
ENDIF

IF EMPTY(SE2->E2_XXCTRID)
	MsgStop("Selecione um titulo de integração liq. "+ALLTRIM(SM0->M0_NOME), "Atenção")
	RestArea(aAreaIni)
	Return
ENDIF

IF TRIM(SE2->E2_TIPO) = 'PA'
	MsgStop("Titulo tipo PA: utilize a opção Excluir liq. "+ALLTRIM(SM0->M0_NOME), "Atenção")
	RestArea(aAreaIni)
	Return
ENDIF


IF lConsulta
	lTitOk := .F.
	cMsgEx := "Consultar"
ELSE
	lTitOk := ValidaE2(@cMsgEx,.F.)
ENDIF	

IF !EMPTY(cMsgEx)
   cMsgEx := " ("+cMsgEx+")"
ENDIF   

dbSelectArea("SZ2")
dbSetOrder(1)

cxFilial := xFilial("SE2")
cPrefixo := SE2->E2_PREFIXO
cNum     := SE2->E2_NUM
cParcela := SE2->E2_PARCELA
cTipo    := SE2->E2_TIPO
cFornece := SE2->E2_FORNECE
cLoja    := SE2->E2_LOJA
nValTit  := SE2->E2_VALOR

cKey1    := cxFilial+cPrefixo+cNum+cParcela+cTipo+cFornece+cLoja

cQuery  := "SELECT Z2_NOME,Z2_VALOR,Z2_BANCO,Z2_CTRID,Z2_DATAPGT,Z2_TIPOPES,Z2_OBS,R_E_C_N_O_ AS XX_RECNO " 
cQuery  += "FROM "+RETSQLNAME("SZ2")+" SZ2 WHERE Z2_CODEMP = '"+SM0->M0_CODIGO+"' "
cQuery  += "AND Z2_E2PRF  = '"+cPrefixo+"' "
cQuery  += "AND Z2_E2NUM  = '"+cNum+"' "
cQuery  += "AND Z2_E2PARC = '"+cParcela+"' "
cQuery  += "AND Z2_E2TIPO = '"+cTipo+"' "
cQuery  += "AND Z2_E2FORN = '"+cFornece+"' "
cQuery  += "AND Z2_E2LOJA = '"+cLoja+"' "
cQuery  += "AND Z2_STATUS = 'S' "
cQuery  += "AND SZ2.D_E_L_E_T_ <> '*' "
cQuery  += "ORDER BY Z2_NOME "

TCQUERY cQuery NEW ALIAS "QSZ2"
TCSETFIELD("QSZ2","Z2_DATAPGT","D",8,0)


DbSelectArea("QSZ2")
DbGoTop()

aCtrId := {}
Do While !eof()
	AADD(aCtrId,{.T.,QSZ2->Z2_NOME,DTOC(QSZ2->Z2_DATAPGT),TRANSFORM(QSZ2->Z2_VALOR,"@E 999,999,999.99"),QSZ2->Z2_BANCO,QSZ2->Z2_TIPOPES,QSZ2->Z2_VALOR,QSZ2->Z2_OBS,QSZ2->XX_RECNO})
	DbSelectArea("QSZ2")
	DbSkip()
Enddo
QSZ2->(DbCloseArea())

//ASORT(aCtrId,,,{|x,y| x[2]<y[2]})

If Empty(aCtrId)
	MsgStop("Não existem valores liquidos associados", "Atenção")
	RestArea(aAreaIni)
	Return
EndIf

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE "Liquidos do titulo: "+SE2->E2_NUM+cMsgEx FROM 000,000 TO 400,630 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 320,225
oPanelLeft:Align := CONTROL_ALIGN_LEFT
//lAll := .F.
//@ 005, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
//oAll:bChange := {|| Aeval(aCtrId,{|x| IIF(lTitOk,x[1]:=lAll,x[1]:=.T.) }), oListId:Refresh()}

@ 000, 005 LISTBOX oListID FIELDS HEADER "","Nome","Pgto","Valor R$","Bco","Tipo","Obs." SIZE 310,185 OF oPanelLeft PIXEL 
oListID:SetArray(aCtrId)
oListID:bLine := {|| {If(aCtrId[oListId:nAt][1],oOk,oNo),aCtrId[oListId:nAt][2],aCtrId[oListId:nAt][3],aCtrId[oListId:nAt][4],aCtrId[oListId:nAt][5],aCtrId[oListId:nAt][6],aCtrId[oListId:nAt][8]}}
oListID:bLDblClick := {|| aCtrId[oListId:nAt][1] := ValidaMrk(aCtrId[oListId:nAt][1],lTitOk,aCtrId[oListId:nAt][2],aCtrId[oListId:nAt][8],cMsgEx),aCtrId[oListId:nAt][8] := cObs, oListID:DrawSelect()}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

If !lConsulta

	aTitGer := {}
	lAltOk1 := .F.
	//lAltOk2 := .F.

	If ( lOk )
	    If !lTitOk
	       MsgStop("Titulo não pode ser alterado"+cMsgEx)
	    Else
			For nI:=1 To Len(aCtrId)
		        If aCtrId[nI,1]
		           AADD(aTitGer,aCtrId[nI])
		        Else
		        	lAltOk1 := .T.
		        Endif
			Next nI
		Endif	
	
		If lAltOk1 // .AND. lAltOk2
		   //If !EMPTY(aTitGer)
		   		aRet := {}
		      	aRet := ConfAltTit(aTitGer,aCtrId)
		      	IF !EMPTY(aRet[1,1])
	    			Processa ( {|| ExcluiBord(aRet[1,2],"3",aRet[1,1])})
   				ENDIF

		   //Endif   
		Else
			MsgStop("Nenhuma alteração foi efetuada")
		EndIf
	
	Endif

EndIf
	
RestArea(aAreaIni)
Return



Static Function ConfAltTit(aTitGer,aCtrId)
Local nI,cMens
Local nValor := 0
Local cBorde := "",cChave:=""
Local aEmail := {}
Local lCLT   := .T.
Local aSaveAreaSE5 := GetArea("SE5")
Local aRet :={}
Local lSucess := .T.

For nI := 1 TO LEN(aTitGer)
    nValor += aTitGer[nI,7]
NEXT

IF nValor > 0
	cMens:= "Confirma alteração do valor do titulo de R$ "+;
			ALLTRIM(TRANSFORM(nValTit,"@E 999,999,999.99"))+;
			" para R$ "+;
			ALLTRIM(TRANSFORM(nValor,"@E 999,999,999.99"))
			
ELSE
	cMens:= "Confirma exclusão do titulo "+TRIM(cNum)+" de R$ "+;
			ALLTRIM(TRANSFORM(nValTit,"@E 999,999,999.99"))
ENDIF


If MsgBox(cMens, "Titulo: "+cNum, "YESNO")

//  IF TRIM(cTipo) = "PA" 
//		dbSelectArea("SE5")
//		dbSetOrder(7)
//		If MsSeek(xFilial("SE5")+cPrefixo+cNum+cParcela+cTipo+cFornece+cLoja)
//		
//		
//		Endif
//	ENDIF

	cBorde := ""
	cChave := ""

	If nValor > 0
	    cChave := cPrefixo+cNum+cParcela+cTipo+cFornece+cLoja
	    Processa ( {|| cBorde := ExcluiBord(cChave,"2","")})
	    
		aVetor :={{"E2_FILIAL"  ,cxFilial,Nil},;
	             {"E2_PREFIXO"  ,cPrefixo,Nil},;
	             {"E2_NUM"      ,cNum,Nil},;
	             {"E2_PARCELA"  ,cParcela,Nil},;
	             {"E2_TIPO"     ,cTipo,Nil},;        
	             {"E2_FORNECE"  ,cFornece,Nil},; 
	             {"E2_LOJA"     ,cLoja,Nil},;      
	             {"E2_VALOR"    ,nValor,Nil}}
	
		Begin Transaction
			lMsErroAuto := .F.   
			MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetor,,4) //Alteração
			IF lMsErroAuto
		   		MsgStop("Problemas na alteração do titulo "+cKey1+", informe o setor de T.I.", "Atenção")
    			MostraErro()
				DisarmTransaction()
		   		lSucess := .F.
			EndIf
        End Transaction
		
	Else
		cBorde := ""
		cChave := ""

	    Processa ( {|| ExcluiBord(cPrefixo+cNum+cParcela+cTipo+cFornece+cLoja,"1","")})
	    
		aVetor :={{"E2_FILIAL"  ,cxFilial,Nil},;
	             {"E2_PREFIXO"  ,cPrefixo,Nil},;
	             {"E2_NUM"      ,cNum,Nil},;
	             {"E2_PARCELA"  ,cParcela,Nil},;
	             {"E2_TIPO"     ,cTipo,Nil},;        
	             {"E2_FORNECE"  ,cFornece,Nil},; 
	             {"E2_LOJA"     ,cLoja,Nil}}

		Begin Transaction
			lMsErroAuto := .F.   
			MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetor,,5) //Exclusão
			IF lMsErroAuto
				MsgStop("Problemas na exclusão do titulo "+cKey1+", informe o setor de T.I.", "Atenção")
				MostraErro()
				DisarmTransaction()
				lSucess := .F.
			EndIf
        End Transaction

	Endif

	dbSelectArea("SZ2")   
	FOR nI := 1 TO LEN(aCtrId)
		IF !aCtrId[nI,1]
			dbGoto(aCtrId[nI,9])
		   	RecLock("SZ2",.F.)
	    	SZ2->Z2_STATUS := "D"
	    	SZ2->Z2_OBS    := aCtrId[nI,8]
	    	If SUBSTR(SZ2->Z2_TIPOPES,1,3) <> "CLT"
	    		lCLT := .F.
	    	EndIf
	    	AADD(aEmail,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,SZ2->Z2_OBS,cPrefixo+cNum,SZ2->Z2_CTRID})
		    MsUnlock()
		EndIf
	Next
	dbSelectArea("SE2")   
Endif

If LEN(aEmail) > 0 .AND.  __cUserId <> "000000" .AND. lSucess
	U_Fina04E(aEmail,lCLT)
EndIf

RestArea(aSaveAreaSE5)

If lSucess
	AADD(aRet,{cBorde,cChave})
EndIf

Return aRet


User Function Fina04E(aEmail,lCLT)
Local cPrw     := "BKFINA04"
Local cAssunto := ""
Local cEmail1  := "sigapgto1@bkconsultoria.com.br"  //"anderson.oliveira@bkconsultoria.com.br;alexandre.teixeira@bkconsultoria.com.br;financeiro@bkconsultoria.com.br;"
Local cEmail2  := "sigapgto2@bkconsultoria.com.br"  //"rh@bkconsultoria.com.br;gestao@bkconsultoria.com.br;financeiro@bkconsultoria.com.br;"
Local cCC      := ""
Local cMsg     := "" 
Local cAnexo   := ""
Local _lJob    := .F.

Local aCabs


//cEmail1 := "microsiga@bkconsultoria.com.br;"
//cEmail2 := ""


cAssunto:= "Pagamentos nao Efetuados "+DTOC(DATE())+"-"+TIME()
aCabs   := {"Pront.","Nome","Valor","Bco","Ag.","Dg.Ag.","Conta","Dg.Conta","Obs.","Titulo","CtrId"}
cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,cPrw)

U_SendMail("BKFINA04",cAssunto,IIF(lCLT,cEmail2,cEmail1),cCc,cMsg,cAnexo,_lJob)

Return Nil




Static Function ValidaMrk(lRet,lTitOk,cNome,cMsg,cMsgEx)
cObs := cMsg
IF lTitOk
   lRet := !lRet
   IF !lRet
      cObs := SPACE(LEN(cMsg))
      Do While EMPTY(cObs)
         cObs := DlgObs(cNome,cMsg)
      EndDo   
   ENDIF
ELSE
   MsgStop("Titulo não pode ser alterado "+cMsgEx, "Atenção")
   lRet := .T.
ENDIF   
Return lRet



Static Function DlgObs(cNome,cMsg)
@ 200, 010 To 280,580 Dialog oDlg2 Title OemToAnsi ("Digite a observação para "+TRIM(cNome))
@ 010, 015 Get cMsg Valid !EMPTY(cMsg) SIZE 210, 040
@ 010, 235 BMPBUTTON TYPE 01 ACTION (Close(oDlg2))
Activate Dialog oDlg2 Center
Return (cMsg)






Static Function ValidaE2(cMsgEx,lBordero)
Local lRet := .T.

If !Empty(SE2->E2_NUMBOR) .AND. lBordero
	//Help("",1,"FA050BORD")
	cMsgEx := "em borderô"
	Return  .F. 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se titulo ja foi baixado total ou parcialmente			 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SE2->E2_BAIXA)
	//Help(" ",1,"FA050BAIXA")
    If SE2->E2_SALDO = 0
		cMsgEx := "baixado"
	Else
		cMsgEx := "baixado parcialmente"
	Endif   
	Return .F. 
EndIf

If SE2->E2_VALOR != SE2->E2_SALDO
	//Help(" ",1,"BAIXAPARC")
	cMsgEx := "baixado parcialmente"
	Return .F. 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se data do movimento n„o ‚ menor que data limite de ³
//³ movimentacao no financeiro    										  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SE2->E2_TIPO $ MVPAGANT
	If !DtMovFin()
		cMsgEx := "data inferior ao limite permitido"
		Return .F. 
	Endif
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se nao ‚ um titulo de ISS ou IR ou INSS ou SEST ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//IF SE2->E2_TIPO $ MVISS+"/"+MVTAXA+"/"+MVTXA+"/"+MVINSS+"/"+"SES"
//	If Fa050Pai()
//		Help(" ",1,"NOVALORIR")
//		Return .F. 
//	EndIf
//EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi emitido cheque para este titulo							 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SE2->E2_IMPCHEQ == "S"
	//Help( " ", 1, "EXISTCHEQ" )
	cMsgEx := "Cheque emitido"
	Return( .F. )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi emitido cheque para um dos titulos de impostos		 ³
//³ Verifica na delecao do titulo pai                             		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Fa050VerImp()
	//Help( " ", 1, "EXISTCHEQ" )
	cMsgEx := "impostos baixados"
	Return( .F. )
EndIf

Return lRet


Static Function ExcluiBord(cChave,cAlt,cNumBor)

IncProc("Excluido Borderô "+ALLTRIM(SM0->M0_NOME)+"...")

dbSelectArea("SE2")
dbSetOrder(1)
DBSEEK(xFilial("SE2")+cChave)
IF cAlt == "3"
	RecLock("SE2")
	Replace SE2->E2_NUMBOR  With cNumBor
	MsUnlock( )
	FKCOMMIT()
	RETURN cNumBor
ENDIF

IF !EMPTY(SE2->E2_NUMBOR)

	cNumBor := ALLTRIM(SE2->E2_NUMBOR)
	RecLock("SE2")
	Replace SE2->E2_NUMBOR  With ""
	MsUnlock( )
	FKCOMMIT()
	IF cAlt == "2"
		RETURN cNumBor
	ENDIF
    IF cALT == "1"
		dbSelectArea("SEA")
		dbSetOrder(1)
		DBSEEK(xFilial("SEA")+cNumBor+cChave)
		RecLock("SEA",.F.,.T.)
		dbDelete()
		MsUnlock( )
		FKCOMMIT()
	ENDIF

ENDIF

RETURN cNumBor
