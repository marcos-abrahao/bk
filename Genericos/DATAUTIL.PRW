#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

//VERIFICA SE A DATA é UTIL
USER FUNCTION DATAUTIL(dData)
Local lRet := .F.
Local dData2 := CTOD("")

dData2 := LastDay(dData, 3)
IF dData2  == dData
	lRet := .T.
ENDIF

RETURN lRet 