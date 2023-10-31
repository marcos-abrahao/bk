#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} A440BUT
BK - Ponto de Entrada para incluir botão na enchoice da liberação do pedido de venda
@Return
@author Adilson do Prado / Marcos Bispo Abrahão
@since 15/09/15 rev 10/01/21
@version P12
/*/

User Function A440BUT()
Local aBotao := {}

aBotao := {{"GLOSA",{|| U_VerGlosa(.T.)},"Glosas e Bonificações"}}

Return aBotao


User Function VerGlosa(lBut)

Local oDlg
Local aSize	   	:= FWGetDialogSize( oMainWnd )
Local nTop		:= 200
Local nLeft		:= 200

Local aAreaIni  := GetArea()
Local aCNR      := {}
Local oListID
Local oPanelLeft 
Local lOk       := .T.
Local aButtons 	:= {}

aCNR := U_BKGlosas(SC5->C5_MDNUMED,SC5->C5_MDPLANI)

If LEN(aCNR) > 0

	/*
    cREVISA := ""
   	dTINIC 	:= CTOD("")
   	cDETG	:= ""
   	cJUST	:= ""
	DbSelectArea("CND")
	CND->(DBSETORDER(4))
	CND->(DBSEEK(xFILIAL("CND")+SC5->C5_MDNUMED,.F.))
	DO While CND->(!eof()) .AND. CND->CND_NUMMED==SC5->C5_MDNUMED
        //IF CND->CND_REVISA > cREVISA
		If CND->CND_REVISA == CND->CND_REVGER
        	cREVISA := CND->CND_REVISA
        	dTINIC 	:= CND->CND_DTINIC
        	cDETG	:= CND->CND_XXDETG
        	cJUST	:= CND->CND_XXJUST
			Exit
        EndIf 
		CND->(dbSkip())
	ENDDO
	
	IF !EMPTY(dTINIC)  
		IF dTINIC >= CTOD("16/11/2015")
      		aCNR := {}
       		ALINHA1 := {}
			FOR nI:= 1 to MLCOUNT(cDETG,80)       		
				AADD(ALINHA1,U_StringToArray(TRIM(MEMOLINE(cDETG,80,nI)), "R$" ))
			NEXT
       		ALINHA2 := {}
			FOR nI:= 1 to MLCOUNT(cJUST,250)       		
				AADD(ALINHA2,MEMOLINE(cJUST,250,nI))
			NEXT
			
			FOR nI:= 1 to LEN(ALINHA1)
			    IF LEN(ALINHA1) == LEN(ALINHA2)
					IF LEN(ALINHA1[nI]) > 1
			    		AADD(aCNR,{IIF(VAL(ALINHA1[nI,2]) > 0,"Bonificação","Glosa"),ALINHA1[nI,1],ALINHA1[nI,2],ALINHA2[nI]})
			    	ENDIF 
			    ENDIF
			NEXT

		ENDIF
	ENDIF

    IF LEN(aCNR) == 0
		MsgStop("medição ("+TRIM(SC5->C5_MDNUMED)+") não justificada ou incorreta, favor estornar a medição, incluir novamente com a justificativa de Glosas ou Bonificações")
    	lOk:=.F.
    ELSE
	*/
		oDlg := MsDialog():New( nTop, nLeft, aSize[3], aSize[4],"Glosas e Bonificações",,,,,,,,, .T.,,,, .F. )

		@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 315,210 COLORS CLR_BLACK,CLR_HGRAY LOWERED RAISED
		oPanelLeft:Align := CONTROL_ALIGN_ALLCLIENT
	
		@ 003, 003 LISTBOX oListID FIELDS HEADER "Incidente","Descrição","Valor","Justificativa" SIZE 300,170 OF oPanelLeft PIXEL 
		oListID:SetArray(aCNR)
		oListID:bLine := {|| {aCNR[oListId:nAt][1],aCNR[oListId:nAt][2],aCNR[oListId:nAt][3],aCNR[oListId:nAt][4]}}
		oListID:Align := CONTROL_ALIGN_ALLCLIENT

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| lOk:=.T.,oDlg:End()}, /*lMsgDel*/, aButtons,/*nRecNo*/,/*cAlias*/,.F./*lMashups*/,.F./*lImpCad*/,.F./*lPadrao*/,.F./*lHasOk*/,.F./*lWalkThru*/)

    //ENDIF
Else
	If lBut	
		u_MsgLog(,"Não há glosas nem bonificações nesta medição ("+TRIM(SC5->C5_MDNUMED)+")","W")
	EndIf
EndIf

RestArea(aAreaIni)

Return lOk


// Retorna array com glosas e Bonificações
User Function BKGlosas(cMedicao,cPlanilha)
Local cQuery 	:= ""
Local cTipoNome	:= ""
Local cAliasCNR := GetNextAlias()
Local cJust		:= ""
Local aCNR		:= {}
Local aAreaIni  := GetArea()

cQuery  := "SELECT CNR_TIPO,CNR_DESCRI,CNR_VALOR,CNR_XTPJUS,CNR_CODPLA " 
cQuery  += " FROM "+RETSQLNAME("CNR")+" CNR "
cQuery  += " WHERE CNR.D_E_L_E_T_ = '' AND CNR_FILIAL = '"+xFilial("CNR")+"' "
cQuery  += "       AND CNR_NUMMED = '"+SC5->C5_MDNUMED+"'" 
cQuery  += "       AND (CNR_CODPLA = ' ' OR CNR_CODPLA = '"+cPlanilha+"')"

cQuery  := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCNR,.T.,.T.)

DbSelectArea(cAliasCNR)
DbGoTop()

Do While (cAliasCNR)->(!eof())

	cTipoNome := IIF((cAliasCNR)->CNR_TIPO == "2","Bonificação","Multa")

	//If Empty((cAliasCNR)->CNR_CODPLA) .OR. (cAliasCNR)->CNR_CODPLA == SC5->C5_MDPLANI
		If !Empty((cAliasCNR)->CNR_XTPJUS)
			cJust:= (cAliasCNR)->CNR_XTPJUS+"-"+Trim(Posicione("SZR",1,xFilial("SZR")+(cAliasCNR)->CNR_XTPJUS,"ZR_DESCR"))
		Else
			cJust := ""
		EndIf

		AADD(aCNR,{cTipoNome,TRIM((cAliasCNR)->CNR_DESCRI),TRANSFORM((cAliasCNR)->CNR_VALOR,"@E 999,999,999.99"),cJust})
	//EndIf

	(cAliasCNR)->(dbSkip())
EndDo

(cAliasCNR)->(dbCloseArea())

RestArea(aAreaIni)

Return aCNR
