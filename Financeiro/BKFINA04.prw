#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINA04
BK - Liquidos - Folha BK - Altera��o de titulos (antes da baixa)
@Return
@author Marcos Bispo Abrah�o
@since 29/09/2009 rev 19/11/2024
@version P12
/*/
//-------------------------------------------------------------------


/*
User Function BKFINA04A()
// Altera��o
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
PRIVATE cPerg  := "BKFINA04"

u_MsgLog(cPerg)

dbSelectArea("SE2")
IF BOF() .OR. EOF()
	u_MsgLog(cPerg,"Selecione um titulo!", "E")
	RestArea(aAreaIni)
	Return
ENDIF

IF EMPTY(SE2->E2_XXCTRID)
	u_MsgLog(cPerg,"Selecione um titulo de integra��o liq. "+FWEmpName(cEmpAnt), "E")
	RestArea(aAreaIni)
	Return
ENDIF

IF TRIM(SE2->E2_TIPO) = 'PA'
	u_MsgLog(cPerg,"Titulo tipo PA: utilize a op��o Excluir liq. "+FWEmpName(cEmpAnt), "E")
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
	u_MsgLog(cPerg,"N�o existem valores liquidos associados", "E")
	RestArea(aAreaIni)
	Return
EndIf

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE "Liquidos do titulo: "+SE2->E2_NUM+cMsgEx FROM 000,000 TO 420,630 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 315,210
//oPanelLeft:Align := CONTROL_ALIGN_LEFT
oPanelLeft:Align := CONTROL_ALIGN_ALLCLIENT
//lAll := .F.
//@ 005, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
//oAll:bChange := {|| Aeval(aCtrId,{|x| IIF(lTitOk,x[1]:=lAll,x[1]:=.T.) }), oListId:Refresh()}

@ 003, 003 LISTBOX oListID FIELDS HEADER "","Nome","Pgto","Valor R$","Bco","Tipo","Obs." SIZE 310,185 OF oPanelLeft PIXEL 
oListID:SetArray(aCtrId)
oListID:bLine := {|| {If(aCtrId[oListId:nAt][1],oOk,oNo),aCtrId[oListId:nAt][2],aCtrId[oListId:nAt][3],aCtrId[oListId:nAt][4],aCtrId[oListId:nAt][5],aCtrId[oListId:nAt][6],aCtrId[oListId:nAt][8]}}
oListID:bLDblClick := {|| aCtrId[oListId:nAt][1] := ValidaMrk(aCtrId[oListId:nAt][1],lTitOk,aCtrId[oListId:nAt][2],aCtrId[oListId:nAt][8],cMsgEx),aCtrId[oListId:nAt][8] := cObs, oListID:DrawSelect()}
oListID:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

If !lConsulta

	aTitGer := {}
	lAltOk1 := .F.
	//lAltOk2 := .F.

	If ( lOk )
	    If !lTitOk
	       u_MsgLog(cPerg,"Titulo n�o pode ser alterado"+cMsgEx,"E")
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
		      	IF LEN(aRet) > 0 .AND. !EMPTY(aRet[1,1])
	    			u_WaitLog(cPerg, {|| ExcluiBord(aRet[1,2],"3",aRet[1,1])},"Excluindo border�...")
   				ENDIF

		   //Endif   
		Else
			u_MsgLog(cPerg,"Nenhuma altera��o foi efetuada","W")
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
Local cFunName := ""
Local cTipoDev := "D"

For nI := 1 TO LEN(aTitGer)
    nValor += aTitGer[nI,7]
NEXT

IF nValor > 0
	cMens:= "Confirma altera��o do valor do titulo de R$ "+;
			ALLTRIM(TRANSFORM(nValTit,"@E 999,999,999.99"))+;
			" para R$ "+;
			ALLTRIM(TRANSFORM(nValor,"@E 999,999,999.99"))
			
ELSE
	cMens:= "Confirma exclus�o do titulo "+TRIM(cNum)+" de R$ "+;
			ALLTRIM(TRANSFORM(nValTit,"@E 999,999,999.99"))
ENDIF


//If MsgBox(cMens, "Titulo: "+cNum, "YESNO")

If u_MsgLog(cPerg,cMens, "Y")

	If u_MsgLog(cPerg,"Devolver ao RH ? (se n�o, remarca para reintegrar)")
		cTipoDev := "D"
	Else
		cTipoDev := " "
	EndIf

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
	    u_WaitLog(cPerg, {|| cBorde := ExcluiBord(cChave,"2","")},"Excluindo border�...")
	    
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
			cFunName := FunName()
			SetFunName( "FINA050" )
			MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetor,,4) //Altera��o
			IF lMsErroAuto

				u_LogMsExec("BKFINA04","Problemas na altera��o do titulo "+cKey1)

				DisarmTransaction()
		   		lSucess := .F.
			EndIf
			SetFunName( cFunName )
        End Transaction
		
	Else
		cBorde := ""
		cChave := ""

	    u_WaitLog(cPerg, {|| ExcluiBord(cPrefixo+cNum+cParcela+cTipo+cFornece+cLoja,"1","")},"Excluindo border�...")
	    
		aVetor :={{"E2_FILIAL"  ,cxFilial,Nil},;
	             {"E2_PREFIXO"  ,cPrefixo,Nil},;
	             {"E2_NUM"      ,cNum,Nil},;
	             {"E2_PARCELA"  ,cParcela,Nil},;
	             {"E2_TIPO"     ,cTipo,Nil},;        
	             {"E2_FORNECE"  ,cFornece,Nil},; 
	             {"E2_LOJA"     ,cLoja,Nil}}

		Begin Transaction
			lMsErroAuto := .F.   
			MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetor,,5) //Exclus�o
			IF lMsErroAuto

				u_LogMsExec("BKFINA04","Problemas na exclus�o do titulo "+cKey1)

				DisarmTransaction()
				lSucess := .F.
			EndIf
        End Transaction

	Endif

	If lSucess
		dbSelectArea("SZ2")   
		FOR nI := 1 TO LEN(aCtrId)
			IF !aCtrId[nI,1]
				dbGoto(aCtrId[nI,9])
				RecLock("SZ2",.F.)
				SZ2->Z2_STATUS := cTipoDev
				SZ2->Z2_OBS    := aCtrId[nI,8]
				If SUBSTR(SZ2->Z2_TIPOPES,1,3) <> "CLT"
					lCLT := .F.
				EndIf
				AADD(aEmail,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,SZ2->Z2_OBS,cPrefixo+cNum,SZ2->Z2_CTRID})
				MsUnlock()
			EndIf
		Next
	EndIf
	
	dbSelectArea("SE2")   
Endif

If LEN(aEmail) > 0 .AND. cTipoDev == "D"
	U_Fina04E(aEmail,lCLT)
EndIf

RestArea(aSaveAreaSE5)

If lSucess
	AADD(aRet,{cBorde,cChave})
EndIf

Return aRet


User Function Fina04E(aEmail,lCLT)
Local cPrw     := "BKFINA04"
Local cEmail1  := u_BKPgto3() 
Local cEmail2  := u_BKPgto2()
Local cCC      := u_EmailAdm()
Local cAssunto := "Pagamentos n�o Efetuados"
Local aCabs    := {"Pront.","Nome","Valor","Bco","Ag.","Dg.Ag.","Conta","Dg.Conta","Obs.","Titulo","CtrId"}
Local cMsg     := u_GeraHtmB(aEmail,cAssunto,aCabs,cPrw,"",cEmail2,cEmail1)

// Grava o anexo html
u_GrvAnexo(cPrw+".html",cMsg,.T.)

U_BkSnMail(cPrw,cAssunto,IIF(lCLT,cEmail2,cEmail1),cCc,cMsg,{cPrw+".html"})

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
   u_MsgLog(cPerg,"Titulo n�o pode ser alterado "+cMsgEx, "E")
   lRet := .T.
ENDIF   
Return lRet



Static Function DlgObs(cNome,cMsg)
@ 200, 010 To 280,580 Dialog oDlg2 Title OemToAnsi ("Digite a observa��o para "+TRIM(cNome))
@ 010, 015 Get cMsg Valid !EMPTY(cMsg) SIZE 210, 040
@ 010, 235 BMPBUTTON TYPE 01 ACTION (Close(oDlg2))
Activate Dialog oDlg2 Center
Return (cMsg)






Static Function ValidaE2(cMsgEx,lBordero)
Local lRet := .T.

If !Empty(SE2->E2_NUMBOR) .AND. lBordero
	//Help("",1,"FA050BORD")
	cMsgEx := "em border�"
	Return  .F. 
EndIf

//�������������������������������������������������������������������Ŀ
//� Verifica se titulo ja foi baixado total ou parcialmente			 	 �
//���������������������������������������������������������������������
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

//��������������������������������������������������������������Ŀ
//� Verifica se data do movimento n�o � menor que data limite de �
//� movimentacao no financeiro    										  �
//����������������������������������������������������������������
If SE2->E2_TIPO $ MVPAGANT
	If !DtMovFin()
		cMsgEx := "data inferior ao limite permitido"
		Return .F. 
	Endif
Endif	

//����������������������������������������������������������Ŀ
//� Verifica se nao � um titulo de ISS ou IR ou INSS ou SEST �
//������������������������������������������������������������
//IF SE2->E2_TIPO $ MVISS+"/"+MVTAXA+"/"+MVTXA+"/"+MVINSS+"/"+"SES"
//	If Fa050Pai()
//		Help(" ",1,"NOVALORIR")
//		Return .F. 
//	EndIf
//EndIf

//����������������������������������������������������������������������Ŀ
//� Verifica se foi emitido cheque para este titulo							 �
//������������������������������������������������������������������������
If SE2->E2_IMPCHEQ == "S"
	//Help( " ", 1, "EXISTCHEQ" )
	cMsgEx := "Cheque emitido"
	Return( .F. )
Endif

//����������������������������������������������������������������������Ŀ
//� Verifica se foi emitido cheque para um dos titulos de impostos		 �
//� Verifica na delecao do titulo pai                             		 �
//������������������������������������������������������������������������
If Fa050VerImp()
	//Help( " ", 1, "EXISTCHEQ" )
	cMsgEx := "impostos baixados"
	Return( .F. )
EndIf

Return lRet


Static Function ExcluiBord(cChave,cAlt,cNumBor)

//IncProc("Excluindo Border� "+cNumBor+" da empresa "+FWEmpName(cEmpAnt)+"...")

dbSelectArea("SE2")
dbSetOrder(1)
DBSEEK(xFilial("SE2")+cChave)

// 18/03/2022 - Remover flag de contabiliza��o para n�o ocorrer erro na altera��o/exclus�o
RecLock("SE2")
SE2->E2_LA := " "
MsUnlock()

IF cAlt == "3"
	RecLock("SE2")
	SE2->E2_NUMBOR := cNumBor
	MsUnlock( )
	FKCOMMIT()
	RETURN cNumBor
ENDIF

IF !EMPTY(SE2->E2_NUMBOR)
	cNumBor := ALLTRIM(SE2->E2_NUMBOR)
	RecLock("SE2")
	SE2->E2_NUMBOR := " "
	MsUnlock( )
	FKCOMMIT()
	IF cAlt == "2"
		RETURN cNumBor
	ENDIF
    IF cAlt == "1"
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
