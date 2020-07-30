#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} CNA130INC
BK - Este ponto de entrada atualiza os dados customizados relacionados à Medição do Contrato.
É localizado no término da gravação da Medição.
@Return
@author Adilson do Prado
@since 15/09/15
@version P11/P12
/*/

User Function CN130PGRV()
Local ExpN1 := PARAMIXB[1] 
U_xCN130PGRV(ExpN1) 
Return NIL

User Function xCN130PGRV(ExpN1)

Local aAreaIni  := GetArea()
Local cAliasCNR := GetNextAlias()
Local aCNR      := {}
Local oDlg,oListID,oPanelLeft,oOk,oNo,oAll
Local oSay2 
Local lOk       := .T.
Local cQuery  	:= ""
Local cTitulo2	:= ""
Local nBonif	:= 0 
Local nMulta	:= 0
Local cOutros	:= PAD("",254) 
Local cSuper    := ""
Local cTpNF		:= CND->CND_XXTPNF

If !cTpNf $ "NA"
	cTpNf := "N"
EndIf

// para teste da tela
//cTpNf := ValTpNf(cTpNf)


cTitulo2 := "Opções de Multa e Bonificação da Medição ("+STRZERO(ExpN1,2)+")"

//3-Incluir;4-Alterar
IF ExpN1 == 3 .OR. ExpN1 == 4 

	cQuery  := "SELECT CNR_TIPO,CNR_DESCRI,CNR_VALOR " 
	cQuery  += "FROM "+RETSQLNAME("CNR")+" CNR "
	cQuery  += "WHERE CNR.CNR_FILIAL = '"+xFilial("CNR")+"' AND CNR_NUMMED = '"+CND->CND_NUMMED+"' AND CNR.D_E_L_E_T_ = '' "

	TCQUERY cQuery NEW ALIAS (cAliasCNR)

	DbSelectArea(cAliasCNR)
	(cAliasCNR)->(DbGoTop())

	Do While (cAliasCNR)->(!eof())
		
		IF (cAliasCNR)->CNR_TIPO == "1"
			nMulta += (cAliasCNR)->CNR_VALOR
		ELSE
			nBonif += (cAliasCNR)->CNR_VALOR
		ENDIF
		(cAliasCNR)->(dbSkip())
	EndDo
    (cAliasCNR)->(dbCloseArea())

    IF nMulta <> 0 .OR. nBonif <> 0  
/* 
		AADD(aCNR,{.F.,"Posto descoberto por faltas/Atrasos"})
		AADD(aCNR,{.F.,"Posto descoberto por férias"})
		AADD(aCNR,{.F.,"Posto não Implantado pelo Cliente"})
		AADD(aCNR,{.F.,"Posto vago parte BK"})
		AADD(aCNR,{.F.,"Horas extras não utilizadas"})
		AADD(aCNR,{.F.,"Verba de viagem"})       // "Diárias não utilizadas"
		AADD(aCNR,{.F.,"Variação dias efetivo"})
		AADD(aCNR,{.F.,"Produtividade"})
		AADD(aCNR,{.F.,"Materiais e Equipamentos"})
		AADD(aCNR,{.F.,"Penalidades"})
		AADD(aCNR,{.F.,"Remanejamento de equipes"})

		AADD(aCNR,{.F.,"Postos não implantados - BK"})
		AADD(aCNR,{.F.,"Postos não implantados -CLIENTE"})
		AADD(aCNR,{.F.,"Inicio de contrato"})
		AADD(aCNR,{.F.,"Termino de contrato"})
//		AADD(aCNR,{.F.,"Posto descoberto por falta/atraso/férias -BK"})
//		AADD(aCNR,{.F.,"Posto descoberto por falta/atraso/férias -CLIENTE"})
		AADD(aCNR,{.F.,"Posto descoberto por falta/atraso -BK"})
		AADD(aCNR,{.F.,"Posto descoberto por falta/atraso -CLIENTE"})
		AADD(aCNR,{.F.,"Posto descoberto por férias -BK"})
		AADD(aCNR,{.F.,"Posto descoberto por férias -CLIENTE"})
		AADD(aCNR,{.F.,"Produtividade"})
		AADD(aCNR,{.F.,"HE não utilizadas"})
		AADD(aCNR,{.F.,"Diárias/Despesas viagem/Deslocamento não utilizados"})
*/

 //alterado em 30/10/2018
		AADD(aCNR,{.F.,"Postos não implantados - BK"})
		AADD(aCNR,{.F.,"Postos não implantados -CLIENTE"})
		AADD(aCNR,{.F.,"Inicio de contrato"})
		AADD(aCNR,{.F.,"Termino de contrato"})
		AADD(aCNR,{.F.,"Posto descoberto por falta/atraso -BK"})
		AADD(aCNR,{.F.,"Posto descoberto por falta/atraso -CLIENTE"})
		AADD(aCNR,{.F.,"Posto descoberto por férias -BK"})
		AADD(aCNR,{.F.,"Posto descoberto por férias -CLIENTE"})
		AADD(aCNR,{.F.,"Produtividade"})
		AADD(aCNR,{.F.,"HE não utilizadas"})
		AADD(aCNR,{.F.,"Diárias/Despesas viagem/Deslocamento não utilizados"})
		AADD(aCNR,{.F.,"Inicio de contrato"})
		AADD(aCNR,{.F.,"Terminio de contrato"})
		AADD(aCNR,{.F.,"Acerto de Valores/Repact/Ajustes"})


		oOk := LoadBitmap( GetResources(), "LBTIK" )
		oNo := LoadBitmap( GetResources(), "LBNO" )

		DEFINE MSDIALOG oDlg TITLE cTitulo2 FROM 000,000 TO 400,630 PIXEL 

		@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 320,225
		oPanelLeft:Align := CONTROL_ALIGN_LEFT
		lAll := .F.
		@ 003, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
		oAll:bChange := {|| Aeval(aCNR,{|x| x[1]:=lAll }), oListId:Refresh()}


		@ 015, 005 LISTBOX oListID FIELDS HEADER "","Opções de Multa e Bonificação" SIZE 310,150 OF oPanelLeft PIXEL 
		oListID:SetArray(aCNR)
		oListID:bLine := {|| {If(aCNR[oListId:nAt][1],oOk,oNo),;
						 	 aCNR[oListId:nAt][2]}}
						 
		oListID:bLDblClick := {|| aCNR[oListId:nAt][1] := IIF(aCNR[oListId:nAt][1],.F.,.T.), oListID:DrawSelect()}

//		@ 155,005 SAY oSay1 PROMPT "Outros: " SIZE 50,10 OF oPanelLeft PIXEL
//		@ 155,030 GET cOutros SIZE 250,10 OF oPanelLeft PIXEL


		@ 180,005 SAY oSay2 PROMPT "Multa: "+TRANSFORM(nMulta,"@E 999,999,999.99")+"        Bonificação: "+TRANSFORM(nBonif,"@E 999,999,999.99") SIZE 250, 10 OF oPanelLeft PIXEL
  
		@ 185,210 Button "&Confirmar" Size 050,013 Pixel Action (lOk:=.T.,oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTERED Valid(ValidaCRN(aCNR,cOutros)) 
		// ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

		If ( lOk )
			lOk:=.F.
			cOutros := ALLTRIM(cOutros)
            GeraCRN(aCNR,cOutros,nBonif,nMulta)
            //u_21TcBrowse()
		ENDIF
	ELSE
		//GRAVA DESCRIÇÃO QUANDO NAO TEM GLOSA OU BONIFICAÇÃO
		RecLock("CND",.F.)
		CND->CND_XXDETG := "Medição Cheia"
		CND->CND_XXJUST := "Medição Cheia"
		MsUnlock("CND")

	ENDIF
ENDIF


// Escolher tipo NF -> Normal ou Avulsa - 29/07/20
If ExpN1 == 3 .OR. ExpN1 == 4 
	PswOrder(1) 
	PswSeek(__CUSERID) 
	aUser  := PswRet(1)
	If !EMPTY(aUser[1,11])
	   cSuper := SUBSTR(aUser[1,11],1,6)
	EndIf
	If cSuper == "000175" .OR. __CUSERID == "000000" // Equipe do José Mário
		cTpNF := ValTpNf(cTpNf)
		RecLock("CND",.F.)
		CND->CND_XXTPNF := cTpNf
		MsUnlock("CND")
	EndIf
EndIf


IF ExpN1 == 12 .OR. ExpN1 == 3
	IF CND->CND_XXDV == "S" .OR. CND->CND_XXVLND > 0	  
    	//Chama a Rotina de Nota de Debito
    	U_FIN040INC(CND->(RECNO())) 
    ENDIF
ELSEIF ExpN1  == 5 .AND. !EMPTY(CND->CND_XXNDC)
   	U_FIN040EXC(CND->(RECNO())) 
ENDIF

RestArea(aAreaIni)

Return nil



STATIC FUNCTION ValidaCRN(aCNR,cOutros)
Local lOk:=.F.
Local _IX := 0

FOR _IX := 1 TO LEN(aCNR)
	IF aCNR[_IX,1]
		lOk:=.T.
	ENDIF
NEXT

IF !lOk
	IF !EMPTY(cOutros) 
		lOk:=.T.
	ENDIF
ENDIF

IF !lOk
	MSGSTOP("Item não selecionado. Favor verificar!!")
ENDIF

RETURN lOk


STATIC Function GeraCRN(aCNR,cOutros,nBonif,nMulta)
Local aCNR2     := {}
Local lOk       := .T.
Local cTitulo2	:= "Valida Opções de Multa e Bonificação da Medição"
Local oSay1		
PRIVATE oSay2
PRIVATE oDlg2,oListID2,oPanelLeft2
PRIVATE nBonif2	:= 0
PRIVATE nMulta2 := 0

FOR _IX := 1 TO LEN(aCNR)
	IF aCNR[_IX,1]
		AADD(aCNR2,{aCNR[_IX,2],0,SPACE(250)})
	ENDIF
NEXT

IF !EMPTY(cOutros)
	AADD(aCNR2,{Capital(ALLTRIM(cOutros)),0,SPACE(250)})
ENDIF

DEFINE MSDIALOG oDlg2 TITLE cTitulo2 FROM 000,000 TO 400,630 PIXEL 

@ 000,000 MSPANEL oPanelLeft2 OF oDlg2 SIZE 320,225


@ 015, 005 LISTBOX oListID2 FIELDS HEADER "Opções de Multa e Bonificação","Valor","Justificativa" SIZE 310,130 OF oPanelLeft2 PIXEL 
oListID2:SetArray(aCNR2)
oListID2:bLine := {|| {aCNR2[oListId2:nAt][1],;
					Transform(aCNR2[oListId2:nAt][2],'@E 99,999,999,999.99'),;
					aCNR2[oListId2:nAt][3]}}  

oListID2:bLDblClick := {|| EDITCNR2(@aCNR2) ,SomaCNR(aCNR2,nMulta,nBonif),oListID2:DrawSelect(), }

@ 150,005 SAY oSay1 PROMPT "Multa: "+TRANSFORM(nMulta,"@E 999,999,999.99")+"        Bonificação: "+TRANSFORM(nBonif,"@E 999,999,999.99") SIZE 250, 10 OF oPanelLeft2 PIXEL
						 

@ 180,005 SAY oSay2 PROMPT "Multa Atual: "+TRANSFORM(nMulta2,"@E 999,999,999.99")+"        Bonificação Atual: "+TRANSFORM(nBonif2,"@E 999,999,999.99") SIZE 250, 10 OF oPanelLeft2 PIXEL
  
@ 185,210 Button "&Confirmar" Size 050,013 Pixel Action (lOk:=.T.,oDlg2:End())

ACTIVATE MSDIALOG oDlg2 CENTERED Valid(VldSOMA(nMulta,nBonif,aCNR2)) 

If ( lOk )
	lOk:=.F.
	GRAVCND(aCNR2)
ENDIF

RETURN NIL


STATIC FUNCTION EDITCNR2(aCNR2)

lEditCell(aCNR2,oListID2,'@E 99,999,999,999.99',2)
lEditCell(aCNR2,oListID2,'@!',3)

RETURN NIL



STATIC FUNCTION SomaCNR(aCNR2,nMulta,nBonif)
Local _IX := 0

nMulta2 := 0
nBonif2 := 0

FOR _IX := 1 TO LEN(aCNR2)
	IF aCNR2[_IX,2] < 0 
		nBonif2 += aCNR2[_IX,2] *-1
	ELSE
		nMulta2 += aCNR2[_IX,2]
	ENDIF
NEXT

IF nMulta2 > nMulta
	MSGSTOP("Multa atual maior que informada. Favor verificar!!")
ENDIF

IF nBonif2 > nBonif
	MSGSTOP("Bonificação atual maior que informada. Favor verificar!!")
ENDIF

oSay2:refresh()
RETURN NIL



STATIC FUNCTION VldSOMA(nMulta,nBonif,aCNR2)
Local lOk	:=.T.
LOCAL lJut 	:= .T.

IF ABS(ABS(nMulta2) - ABS(nMulta)) > 0.01
	MSGSTOP("Multa atual diferente da informada. Favor verificar!!")
	lOk:=.F.
ENDIF

IF ABS(ABS(nBonif2) - ABS(nBonif)) > 0.01
	MSGSTOP("Bonificação atual diferente da informada. Favor verificar!!")
	lOk:=.F.
ENDIF


FOR _IX := 1 TO LEN(aCNR2)
	IF LEN(ALLTRIM(aCNR2[_IX,3])) == 0 
		lJut 	:= .F.
	ENDIF
NEXT

IF !lJut
	MSGSTOP("Justificativa não informada. Favor verificar!!")
	lOk:=.F.
ENDIF

RETURN lOk


STATIC FUNCTION GRAVCND(aCNR2)

Local cCrLf := Chr(13) + Chr(10)
Local _IX 	:= 0
Local cDesc := ""
Local cJust := ""


nMulta2 := 0
nBonif2 := 0

FOR _IX := 1 TO LEN(aCNR2)
	cDesc += aCNR2[_IX,1]+"   R$"+Transform(aCNR2[_IX,2],'@E 99,999,999,999.99')+cCrLf
	cJust += aCNR2[_IX,3]+cCrLf
NEXT

RecLock("CND",.F.)
	CND->CND_XXDETG := cDesc
	CND->CND_XXJUST := cJust
MsUnlock("CND")

RETURN NIL





// Mostra na Tela campos Tipo da NF
Static Function ValTpNf(cTpNf)
Local oDlg as Object
Local aTpNF := {}

aTpNf := U_StringToArray(GetSx3Cache("CND_XXTPNF", "X3_CBOX"),";") 

Define MsDialog oDlg Title OemToAnsi("Tipo da Emissão da NF") From 200, 001  To 295,400 Of oDlg Pixel Style DS_MODALFRAME

@ 015,015 SAY "Tipo NF: " Pixel Of oDlg 

@ 015,046 COMBOBOX cTpNF ITEMS aTpNf SIZE 100,010 Pixel Of oDlg VALID (cTpNF $ "NA")

@ 030,085 Button "&Ok" Size 036,013 Pixel Action (oDlg:End())

ACTIVATE MSDIALOG oDlg CENTERED Valid(cTpNF $ "NA") 

Return cTpNF

