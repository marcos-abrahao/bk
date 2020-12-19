#include "rwmake.ch"

// Ponto de entrada para gravar UserId e Superior 
// 19/11/09 - Marcos B Abrahão

User Function SF1100I()
Local aUser,cSuper

IF EMPTY(SF1->F1_XXUSER) .AND. VAL(__CUSERID) > 0  // Não Gravar Administrador
	PswOrder(1) 
	PswSeek(__CUSERID) 
	aUser  := PswRet(1)
	cSuper := aUser[1,11]
	RecLock("SF1",.F.)
	SF1->F1_XXUSER  := __cUserId
	SF1->F1_XXUSERS := cSuper
	MsUnLock("SF1")
ENDIF

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
		MsUnLock("SF1")
	EndIf
EndIf

Return .T.


