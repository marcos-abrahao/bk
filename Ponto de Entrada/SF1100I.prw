#include "rwmake.ch"

// Ponto de entrada para gravar UserId e Superior 
// 19/11/09 - Marcos B Abrahão

User Function SF1100I()
Local aUser,cSuper

Private cxTipoPg := SF1->F1_XTIPOPG
Private cxNumPa  := SF1->F1_XNUMPA
Private cxBanco  := SF1->F1_XBANCO
Private cxAgencia:= SF1->F1_XAGENC
Private cxConta  := SF1->F1_XNUMCON
Private cChvNfe  := SF1->F1_CHVNFE
Private dPrvPgt  := SF1->F1_XXPVPGT
Private cJsPgt	 := SF1->F1_XXJSPGT
Private nTipoPg  := 0
Private cEspecie := SF1->F1_ESPECIE
Private cxCond	 := SF1->F1_COND
Private mParcel	 := SF1->F1_XXPARCE

IF EMPTY(SF1->F1_XXUSER) .AND. VAL(__cUserId) > 0  // Não Gravar Administrador
	PswOrder(1) 
	PswSeek(__cUserId) 
	aUser  := PswRet(1)
	cSuper := aUser[1,11]
	RecLock("SF1",.F.)
	SF1->F1_XXUSER  := __cUserId
	SF1->F1_XXUSERS := cSuper
	MsUnLock("SF1")
ENDIF

If Inclui .AND. !l103Auto
	//If !__cUserId $ "000011/000012/000016"
	If Empty(dPrvPgt) 
		dPrvPgt := SE2->E2_VENCREA
	EndIf
	If U_SelFPgto(.T.,__cUserId $ "000000/000011/000012/000016")
		RecLock("SF1",.F.)
		SF1->F1_XTIPOPG := cxTipoPg
		SF1->F1_XNUMPA  := cxNumPa
		SF1->F1_XBANCO  := cxBanco
		SF1->F1_XAGENC  := cxAgencia
		SF1->F1_XNUMCON := cxConta
		SF1->F1_CHVNFE  := cChvNfe
		SF1->F1_XXPVPGT := dPrvPgt
		SF1->F1_XXJSPGT := cJsPgt
		SF1->F1_COND	:= cxCond
		SF1->F1_XXPARCE := mParcel
		MsUnLock("SF1")
	EndIf
EndIf

If l103Class .OR. Inclui
	If SF1->F1_STATUS $ "AB"
		RecLock("SF1",.F.)
		If SF1->F1_STATUS == "A"
			SF1->F1_XXLIB  := "C"
		Else
			SF1->F1_XXLIB  := "B"
		EndIf
		If Empty(SF1->F1_XXULIB)
			SF1->F1_XXULIB  := __cUserId
		EndIf
		If Empty(SF1->F1_XXDLIB)
			SF1->F1_XXDLIB  := DtoC(Date())+"-"+Time()
		EndIf
		If Empty(SF1->F1_XXDINC)
			SF1->F1_XXDINC  := DtoC(Date())+"-"+Time()
		EndIf
		SF1->F1_XXUCLAS := __cUserId
		SF1->F1_XXDCLAS := DtoC(Date())+"-"+Time()
		MsUnLock("SF1")
	EndIf
EndIf

Return .T.


