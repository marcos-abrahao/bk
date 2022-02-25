#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DATAUTIL
BK - VERIFICA SE A DATA é UTIL
@Return
@author Marcos B. Abrahao
@since 29/01/2011
@version P12
/*/
//-------------------------------------------------------------------

USER FUNCTION DATAUTIL(dData)
Local lRet := .F.
Local dData2 := CTOD("")

dData2 := LastDay(dData, 3)
IF dData2  == dData
	lRet := .T.
ENDIF

RETURN lRet 
