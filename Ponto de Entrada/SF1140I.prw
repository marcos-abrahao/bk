#include "protheus.ch"
#include "rwmake.ch"

// Ponto de entrada para gravar UserId e Superior 
// 19/11/09 - Marcos B Abrahão
// Gravar dados de pagamento
// 19/03/19 - Marcos B Abrahão

User Function SF1140I()
Local aUser,cSuper

Private cxTipoPg := SF1->F1_XTIPOPG
Private cxNumPa  := SF1->F1_XNUMPA
Private cxBanco  := SF1->F1_XBANCO
Private cxAgencia:= SF1->F1_XAGENC
Private cxConta  := SF1->F1_XNUMCON
Private cChvNfe  := SF1->F1_CHVNFE
Private nTipoPg  := 0

//GetSa2(SF1->F1_FORNECE,SF1->F1_LOJA)
If !l140Auto
	SelFPgto()
EndIf

IF EMPTY(SF1->F1_XXUSER) .AND. VAL(__CUSERID) > 0  // Não Gravar Administrador
	PswOrder(1) 
	PswSeek(__CUSERID) 
	aUser  := PswRet(1)
	cSuper := aUser[1,11]
	RecLock("SF1",.F.)
	SF1->F1_XXUSER  := __cUserId
	SF1->F1_XXUSERS := cSuper
	MSUNLOCK("SF1")
ENDIF

RecLock("SF1",.F.)
SF1->F1_XTIPOPG := cxTipoPg
SF1->F1_XNUMPA  := cxNumPa
SF1->F1_XBANCO  := cxBanco
SF1->F1_XAGENC  := cxAgencia
SF1->F1_XNUMCON := cxConta
SF1->F1_CHVNFE  := cChvNfe
MSUNLOCK("SF1")

If nTipoPg == 1 .AND. SF1->F1_FORNECE <> "000084"
	PutSa2(SF1->F1_FORNECE,SF1->F1_LOJA)
EndIf

If Inclui

EndIf
	
Return .T.


Static Function SelFPgto
Local aOpcoes   := {}
Local oRadMenu1
Local oSay1
Local bClickP
Static oDlg3
Private nRadMenu1 := 1
Private oGetBco,oGetAge,oGetCon,oGetPA,oGetChv

aadd(aOpcoes,"DEPOSITO")   //01
aadd(aOpcoes,"CARTAO")     //02
aadd(aOpcoes,"BOLETO")     //03
aadd(aOpcoes,"P.A.")       //04
aadd(aOpcoes,"FUNDO FIXO") //05
aadd(aOpcoes,"CHEQUE")     //06

nRadMenu1 := ASCAN(aOpcoes,ALLTRIM(cxTipoPg))
If nRadMenu1 = 0
	nRadMenu1 := 1
EndIf

DEFINE MSDIALOG oDlg3 TITLE "Forma de pagamento" STYLE DS_MODALFRAME FROM 000, 000 TO 310, 430 COLORS 0, 16777215 PIXEL

oDlg3:lEscClose := .F.

bClickP	:= { || Habilita(nRadMenu1) }	
oRadMenu1:= tRadMenu():New(20,10,aOpcoes,{|u|if(PCount()>0,nRadMenu1:=u,nRadMenu1)}, oDlg3,,bClickP,,,,,,70,130,,,,.T.)


@ 010,010 SAY oSay1 PROMPT "Selecione a forma de pagamento :" SIZE 091, 007 OF oDlg3 COLORS 0, 16777215 PIXEL

@ 087,010 SAY "Banco" 	 OF oDlg3 PIXEL
@ 085,040 MSGET oGetBco VAR cxBanco   OF oDlg3 PICTURE "@!" PIXEL WHEN (nRadMenu1==1) Valid IIf(nRadMenu1==1,!Empty(cxBanco),.T.)
@ 087,065 SAY "Agência"  OF oDlg3 PIXEL
@ 085,090 MSGET oGetAge VAR cxAgencia OF oDlg3 PICTURE "@!" PIXEL WHEN (nRadMenu1==1) Valid IIf(nRadMenu1==1,!Empty(cxAgencia),.T.)
@ 087,125 SAY "Conta"  	 OF oDlg3 PIXEL
@ 085,145 MSGET oGetCon VAR cxConta   OF oDlg3 PICTURE "@!" SIZE 60,10 PIXEL WHEN (nRadMenu1==1) Valid IIf(nRadMenu1==1,!Empty(cxConta),.T.)

@ 102,010 SAY "P.A."     OF oDlg3 PIXEL
@ 100,040 MSGET oGetPA VAR cxNumPa	  OF oDlg3 PICTURE "@!" PIXEL WHEN (nRadMenu1==4) Valid IIf(nRadMenu1==4,!Empty(cxNumPa),.T.)

@ 122,010 SAY 'Chave Nfe:' OF oDlg3 PIXEL COLOR CLR_RED 
@ 120,040 MSGET oGetChv VAR cChvNfe  OF oDlg3 PICTURE "@!" SIZE 140,10 PIXEL 

@ 140,090 BUTTON "Ok" SIZE 050, 012 PIXEL OF oDlg3 Action(IIf(ValidFP(nRadMenu1),oDlg3:End(),AllwaysTrue()))
//@ 170,150 BUTTON "Cancelar" SIZE 050, 012 PIXEL OF oDlg3 Action(oDlg3:End(),lRet:= .F.)

ACTIVATE MSDIALOG oDlg3 CENTERED
If nRadMenu1 > 0
	cxTipoPg := aOpcoes[nRadMenu1]
	If nRadMenu1 <> 4
		cxNumPa := SPACE(9)
	EndIf
EndIf

nTipoPg := nRadMenu1

Return


Static Function ValidFP(nRadio)
Local lRet := .T.
If nRadio <> 1 .AND. nRadio <> 4
	cxNumPa   := SPACE(9)
	cxBanco   := ""
	cxAgencia := ""
	cxConta   := ""
Else
	If nRadio == 1
		If Empty(cxBanco)
			MsgStop("Informe o banco para depósito")
			oGetBco:Enable()
			oGetBco:Setfocus()
			lRet := .F.
		ElseIf Empty(cxAgencia)
			MsgStop("Informe a agência para depósito")
			oGetAge:Enable()
			oGetAge:Setfocus()
			lRet := .F. 
		ElseIf Empty(cxConta)
			MsgStop("Informe a conta bancária para depósito")
			oGetCon:Enable()
			oGetCon:Setfocus()
			lRet := .F. 
		EndIf
	ElseIf nRadio == 4
		If Empty(cxNumPa)
			MsgStop("Informe o número do Pagamento Antecipado (P.A.)")
			oGetPA:Enable()
			oGetPA:Setfocus()
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet



Static Function Habilita(nRadio)

If nRadio <> 1 .AND. nRadio <> 4
	oGetBco:Disable()
	oGetAge:Disable()
	OGetCon:Disable()
	cxNumPa := SPACE(9)
	oGetPA:Refresh()
	oGetPA:Disable()
Else
	If nRadio == 1
		oGetBco:Enable()
		oGetAge:Enable()
		oGetCon:Enable()
		//oGetBco:Setfocus()
	ElseIf nRadio == 4
		oGetPA:Enable()
		//oGetPA:Setfocus()
	EndIf
EndIf
Return Nil


/*
Static Function GetSa2(cCod,cLoja)
Local aArea := GetArea()

dbSelectArea("SA2")
If dbSeek(xFilial("SA2")+cCod+cLoja) 
	cxBanco   := SA2->A2_BANCO
	cxAgencia := SA2->A2_AGENCIA
	cxConta   := SA2->A2_NUMCON
Else
	cxBanco   := SPACE(LEN(SA2->A2_BANCO))
	cxAgencia := SPACE(LEN(SA2->A2_AGENCIA))
	cxConta   := SPACE(LEN(SA2->A2_NUMCON))
EndIf

RestArea(aArea)
Return
*/


Static Function PutSa2(cCod,cLoja)
Local aArea := GetArea()

dbSelectArea("SA2")
If dbSeek(xFilial("SA2")+cCod+cLoja) 
	RecLock("SA2",.F.)
	SA2->A2_BANCO   := cxBanco
	SA2->A2_AGENCIA := cxAgencia
	SA2->A2_NUMCON  := cxConta
	MSUNLOCK("SA2")
EndIf

RestArea(aArea)
Return
