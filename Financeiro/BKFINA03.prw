#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³BKFIN03   ºAutor  ³ Marcos B. Abrahão  º Data ³ 08/10/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Liquidos - Folha BK - Exclusão dos titulos por CTRID       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³BK                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Tratamento do campo campo Z2_STATUS pelos sistemas:

" "- Gerado ou alterado pelo RH: financeiro pode importar ou RH pode manipular
"X"- Em seleção, na tela do financeiro: RH não pode manipular
"S"- Titulos gerados no financeiro: financeiro pode excluir,RH não pode manipular
"D"- Titulos excluídos no financeiro: RH pode manipular

/*/

User Function BKFINA03()

Local oOk
Local oNo
Local oDlg
Local oListId
Local oPanelLeft
Local lAll
Local oAll
Local aButtons := {}

Local aCtrId,aTitGer
Local lOk      := .F.,cE2Ok := "B",lOkEx := .T.
Local aAreaIni := GetArea()
Local cQuery
Local nI
Local cKey
Local cMsgEx
Local cDataF
Local cE2CtrId
Local cTitulo2 := "Exclusão de Titulos - Liquidos "+ALLTRIM(SM0->M0_NOME)

Private cE2Filial := xFilial("SE2")

cE2CtrID := SE2->E2_XXCTRID


dbSelectArea("SZ2")
dbGoTop()
IF BOF() .OR. EOF()
	MsgStop("Não ha lotes gerados", "Atenção")
	RestArea(aAreaIni)
	Return
ENDIF
// FILTRAR 15 ANTES
cDataF := DTOS(dDataBase - 16)

cQuery  := "SELECT Z2_CTRID,MAX(Z2_DATAPGT) AS XX_DATAPGT,SUM(Z2_VALOR) AS XX_TOTAL " 
cQuery  += "FROM "+RETSQLNAME("SZ2")+" SZ2 WHERE Z2_CODEMP = '"+SM0->M0_CODIGO+"' AND Z2_STATUS = 'S' "
IF EMPTY(cE2CtrId)
   cQuery  += "AND Z2_DATAPGT > '"+cDataF+"' "
ELSE
   cQuery  += "AND Z2_CTRID = '"+cE2CtrId+"' "
ENDIF   

cQuery  += "GROUP BY Z2_CTRID "
cQuery  += "ORDER BY Z2_CTRID "

TCQUERY cQuery NEW ALIAS "QSZ2"
TCSETFIELD("QSZ2","XX_DATAPGT","D",8,0)

DbSelectArea("QSZ2")
DbGoTop()

aCtrId := {}
Do While !eof()
	AADD(aCtrId,{.F.,QSZ2->Z2_CTRID,DTOC(QSZ2->XX_DATAPGT),TRANSFORM(QSZ2->XX_TOTAL,"@E 999,999,999.99")})
	DbSkip()
Enddo
QSZ2->(DbCloseArea())

ASORT(aCtrId,,,{|x,y| x[2]<y[2]})

If Empty(aCtrId)
	MsgStop("Não há lotes disponíveis para excluir", "Atenção")
	RestArea(aAreaIni)
	Return
EndIf

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE cTitulo2 FROM 000,000 TO 270,430 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 220,125
oPanelLeft:Align := CONTROL_ALIGN_LEFT
lAll := .F.
@ 005, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
oAll:bChange := {|| Aeval(aCtrId,{|x| IIF(CTOD(x[3]) >= dDatabase,x[1]:=lAll,x[1]:=.F.) }), oListId:Refresh()}

@ 020, 005 LISTBOX oListID FIELDS HEADER "","Lote (CTRID)","Pgto","Total R$" SIZE 210,100 OF oPanelLeft PIXEL 
oListID:SetArray(aCtrId)
oListID:bLine := {|| {If(aCtrId[oListId:nAt][1],oOk,oNo),aCtrId[oListId:nAt][2],aCtrId[oListId:nAt][3],aCtrId[oListId:nAt][4]}}
oListID:bLDblClick := {|| aCtrId[oListId:nAt][1] := ValidaMrk(aCtrId[oListId:nAt][1],aCtrId[oListId:nAt][3]), oListID:DrawSelect()}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

lOkEx := .T.
If ( lOk )
    lOk     := .F.
	aTitGer := {}
	For nI  := 1 To Len(aCtrId)
        If aCtrId[nI,1]

			cQuery  := "SELECT Z2_CODEMP,Z2_E2PRF,Z2_E2NUM,Z2_E2PARC,Z2_E2TIPO,Z2_E2FORN,Z2_E2LOJA,Z2_CTRID,Z2_TIPO,Z2_BANCO,Z2_DATAPGT,SUM(Z2_VALOR) AS XX_VALOR " 
			cQuery  += "FROM "+RETSQLNAME("SZ2")+" SZ2 WHERE Z2_CODEMP = '"+SM0->M0_CODIGO+"' AND Z2_STATUS = 'S' AND Z2_CTRID = '"+aCtrId[nI,2]+"' "
			cQuery  += "GROUP BY Z2_CODEMP,Z2_E2PRF,Z2_E2NUM,Z2_E2PARC,Z2_E2TIPO,Z2_E2FORN,Z2_E2LOJA,Z2_CTRID,Z2_TIPO,Z2_BANCO,Z2_DATAPGT "
			cQuery  += "ORDER BY Z2_CODEMP,Z2_E2PRF,Z2_E2NUM,Z2_E2PARC,Z2_E2TIPO,Z2_E2FORN,Z2_E2LOJA,Z2_CTRID,Z2_TIPO,Z2_BANCO,Z2_DATAPGT "
	
			TCQUERY cQuery NEW ALIAS "QSZ2"
			
			TCSETFIELD("QSZ2","Z2_DATAPGT","D",8,0)

			DbSelectArea("QSZ2")
			DbGoTop()
			Do While !eof()

				cKey  := cE2Filial+QSZ2->Z2_E2PRF+QSZ2->Z2_E2NUM+QSZ2->Z2_E2PARC+QSZ2->Z2_E2TIPO+QSZ2->Z2_E2FORN+QSZ2->Z2_E2LOJA
				cMsgEx:= SPACE(50)
			    cE2Ok := IIF(ValidaExc(cKey,@cMsgEx),"N","B")
				//IF !lE2Ok
				//	lOkEx := .F.
				//ENDIF	
				AADD(aTitGer,{cE2Ok,cKey,QSZ2->Z2_CTRID,QSZ2->Z2_TIPO,QSZ2->Z2_BANCO,QSZ2->Z2_DATAPGT,QSZ2->XX_VALOR,cMsgEx})
				dbSelectArea("QSZ2")
				DbSkip()
			Enddo
			QSZ2->(DbCloseArea())
						
        Endif
	Next nI
	
EndIf
If !EMPTY(aTitGer)
	If !lOkEx
		MsgStop("Há titulos com movimento neste lote, estorne os movimentos as baixas antes de exclui-los.", "Atenção")
	Endif
	ConfTit(aTitGer,aCtrId,lOkEx)
EndIf
RestArea(aAreaIni)
Return


STATIC FUNCTION ConfTit(aTitGer,aCtrId,lOkEx)
Local oOk
Local oNo
Local oDlg
Local oListId
Local oPanelLeft
Local aButtons := {}

Local lOk      := .F.
Local nI,nTotal := 0

FOR nI := 1 TO LEN(aTitGer)
	nTotal += aTitGer[nI,7]
NEXT

//oOk := LoadBitmap( GetResources(), "BR_VERDE" )
oBx := LoadBitmap( GetResources(), "BR_VERMELHO" )
oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE "Marque os Titulos que deseja excluir" FROM 000,000 TO 450,630 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 320,225
oPanelLeft:Align := CONTROL_ALIGN_LEFT

//lAll := .F.
//@ 005, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
//oAll:bChange := {|| Aeval(aCtrId,{|x| x[1]:=lAll}), oListId:Refresh()}

@ 005, 005 SAY "Total: "+TRANSFORM(nTotal,"@E 999,999,999.99") OF oPanelLeft SIZE 100,10 PIXEL

@ 012, 005 LISTBOX oListID FIELDS HEADER "Ok","Titulo","Lote (CTRID)","Tipo","Banco","Data Pgt","Valor R$","Validação" SIZE 310,200 OF oPanelLeft PIXEL 

//cPrf,cTitulo,QSZ2->Z2_CTRID,QSZ2->Z2_TIPO,QSZ2->Z2_BANCO,QSZ2->Z2_DATAPGT,TRANSFORM(QSZ2->XX_TOTAL,"@E 999,999,999.99")

oListID:SetArray(aTitGer)
oListID:bLine := {|| {	IIf(aTitGer[oListId:nAt][1] = "N",oNo,IIF(aTitGer[oListId:nAt][1] = "S",oOk,oBx)),;
						aTitGer[oListId:nAt][2],;
						aTitGer[oListId:nAt][3],;
						aTitGer[oListId:nAt][4],;
						aTitGer[oListId:nAt][5],;
						aTitGer[oListId:nAt][6],;
						TRANSFORM(aTitGer[oListId:nAt][7],"@E 999,999,999.99"),;
						aTitGer[oListId:nAt][8]}}

//oListID:bLDblClick := {|| aCtrId[oListId:nAt][1] := !aCtrId[oListId:nAt][1], oListID:DrawSelect()}
oListID:bLDblClick := {|| aTitGer[oListId:nAt][1] := ValidaDel(aTitGer[oListId:nAt][1],aTitGer[oListId:nAt][8]), oListID:DrawSelect()}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

If ( lOk )
    //lOk := .T.
	If !lOkEx
		If !MsgYesNo("Há titulos com movimento neste lote, serão excluidos apenas os sem movimentos, confirma?", "Atenção")
		   lOk := .F.
		Endif
	EndIf
	If lOk
	    ExcluiSe2(aTitGer,aCtrId)
	   //MsgStop("Problemas na exclusão do lote, informe o setor de T.I.", "Atenção")
	Endif
EndIf
Return Nil



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
			MsgStop("Titulo "+cKey+" não existe, informe o setor de T.I.", "Atenção")
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
			MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetor,,5) //Exclusão
			IF lMsErroAuto
				MsgStop("Problemas na exclusão do titulo "+cKey+", informe o setor de T.I.", "Atenção")
			   	AADD(aTitErr,cKey)
	    		MostraErro()
				DisarmTransaction()
			EndIf
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


Static Function ValidaMrk(lRet,cPgto)
//IF CTOD(cPgto) >= dDataBase
   lRet := !lRet
//ELSE
//   MsgStop("Data de pgto deste lote é inferior a data base do sistema", "Atenção")
//   lRet := .F.
//ENDIF   
Return lRet


Static Function ValidaDel(cRet,cMsg)
IF EMPTY(cMsg)
   IF cRet = "N"
      cRet := "S"
   ELSEIF cRet = "S"
      cRet := "N"
   ELSE
      cRet := "B"
   ENDIF      
ELSE
   MsgStop(cMsg, "Atenção: título não pode ser excluido")
   cRet := "B"
ENDIF   
Return cRet



Static Function ValidaExc(cKey,cMsgEx)
Local lRet := .T.

dbSelectArea("SE2")
dbSetOrder(1)

If !MsSeek(cKey)
	cMsgEx := "Titulo inexistente"
	Return  .F. 
EndIf

//If !Empty(SE2->E2_NUMBOR)
	//Help("",1,"FA050BORD")
//	cMsgEx := "Titulo em borderô"
//	Return  .F. 
//EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se titulo ja foi baixado total ou parcialmente			 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SE2->E2_BAIXA)
	//Help(" ",1,"FA050BAIXA")
	cMsgEx := "Titulo baixado"
	Return .F. 
EndIf

If SE2->E2_VALOR != SE2->E2_SALDO
	//Help(" ",1,"BAIXAPARC")
	cMsgEx := "Titulo baixado parcialmente"
	Return .F. 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se data do movimento n„o ‚ menor que data limite de ³
//³ movimentacao no financeiro    										  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SE2->E2_TIPO $ MVPAGANT
	If !DtMovFin()
		cMsgEx := "Data inferior ao limite permitido"
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
	cMsgEx := "Cheque emitido para o titulo"
	Return( .F. )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi emitido cheque para um dos titulos de impostos		 ³
//³ Verifica na delecao do titulo pai                             		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Fa050VerImp()
	//Help( " ", 1, "EXISTCHEQ" )
	cMsgEx := "Há impostos baixados para o titulo"
	Return( .F. )
EndIf

Return lRet 


Static Function ExcluiBord(cChave)
LOCAL cNumBor := ""

IncProc("Excluido Borderô BK...")

dbSelectArea("SE2")
dbSetOrder(1)
DBSEEK(cChave)
IF !EMPTY(SE2->E2_NUMBOR)

	cNumBor := ALLTRIM(SE2->E2_NUMBOR)
	RecLock("SE2")
	Replace E2_NUMBOR  With ""
	MsUnlock( )
	FKCOMMIT()
	dbSelectArea("SEA")
	dbSetOrder(1)
	DBSEEK(xFilial("SE2")+cNumBor+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA)
	RecLock("SEA",.F.,.T.)
	dbDelete()
	MsUnlock( )
	FKCOMMIT()
ENDIF

RETURN


