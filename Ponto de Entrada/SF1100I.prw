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
	MSUNLOCK("SF1")
ENDIF

Return .T.


