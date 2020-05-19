#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} A440BUT
BK - Ponto de Entrada para incluir botão na enchoice da liberação do pedido de venda
@Return
@author Adilson do Prado / Marcos Bispo Abrahão
@since 15/09/15 rev 17/05/20
@version P12
/*/

User Function A440BUT()
Local aBotao := {}

//aBotao := {{"",U_VerGlosa(),”Glosas e Bonificações”}}
aBotao := {{"GLOSA",{|| U_VerGlosa(.T.)},"Glosas e Bonificações"}}

Return aBotao


User Function VerGlosa(lBut)
Local cQuery    := ""
Local aAreaIni  := GetArea()
Local cAliasCNR := GetNextAlias()
Local aCNR      := {}
Local oDlg,oListID,oPanelLeft 
Local aButtons  := {}
Local lOk       := .T.
Local cREVISA 	:= ""
Local dTINIC 	:= CTOD("")
Local cDETG		:= ""
Local cJUST		:= ""

cQuery  := "SELECT CNR_TIPO,CNR_DESCRI,CNR_VALOR " 
cQuery  += "FROM "+RETSQLNAME("CNR")+" CNR WHERE CNR.D_E_L_E_T_ = '' AND CNR_NUMMED = '"+SC5->C5_MDNUMED+"' AND CNR_FILIAL = '"+SC5->C5_FILIAL+"' "

TCQUERY cQuery NEW ALIAS (cAliasCNR)

DbSelectArea(cAliasCNR)
DbGoTop()

Do While (cAliasCNR)->(!eof())
	cTipoNome := IIF((cAliasCNR)->CNR_TIPO == "1","Bonificação","Glosa")
	DBSELECTAREA("CND")
	CND->(DBSETORDER(4))
	CND->(DBSEEK(xFILIAL("CND")+SC5->C5_MDNUMED,.F.))

	AADD(aCNR,{cTipoNome,(cAliasCNR)->CNR_DESCRI,TRANSFORM((cAliasCNR)->CNR_VALOR,"@E 999,999,999.99"),CND->CND_XXJUST})

	(cAliasCNR)->(dbSkip())
EndDo

If LEN(aCNR) > 0
    cREVISA := ""
   	dTINIC 	:= CTOD("")
   	cDETG	:= ""
   	cJUST	:= ""
	DBSELECTAREA("CND")
	CND->(DBSETORDER(4))
	CND->(DBSEEK(xFILIAL("CND")+SC5->C5_MDNUMED,.F.))
	DO While CND->(!eof()) .AND. CND->CND_NUMMED==SC5->C5_MDNUMED
        IF CND->CND_REVISA > cREVISA
        	cREVISA := CND->CND_REVISA
        	dTINIC 	:= CND->CND_DTINIC
        	cDETG	:= CND->CND_XXDETG
        	cJUST	:= CND->CND_XXJUST
        ENDIF 
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

		DEFINE MSDIALOG oDlg TITLE "Glosas e Bonificações" FROM 000,000 TO 420,630 PIXEL 
	
		@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 320,225
		oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
		@ 015, 005 LISTBOX oListID FIELDS HEADER "Incidente","Descrição","Valor","Justificativa" SIZE 310,170 OF oPanelLeft PIXEL 
		oListID:SetArray(aCNR)
		oListID:bLine := {|| {aCNR[oListId:nAt][1],aCNR[oListId:nAt][2],aCNR[oListId:nAt][3],aCNR[oListId:nAt][4]}}
	
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| lOk:=.F.,oDlg:End()}, , aButtons)

    ENDIF
Else
	If lBut	
		MsgInfo("Não há glosas nem bonificações nesta medição ("+TRIM(SC5->C5_MDNUMED)+")")
	EndIf
EndIf

(cAliasCNR)->(dbCloseArea())

RestArea(aAreaIni)

Return lOk



