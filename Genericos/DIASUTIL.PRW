#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DATAUTIL
BK - RETORNA O DIA UTIL CONFORME PARAMETROS
@Return
@author Marcos B. Abrahao
@since 29/01/2011
@version P12
/*/
//-------------------------------------------------------------------

USER FUNCTION DIASUTIL(dData,nDIAS)
Local dData2 := CTOD("")
Local nSoma  := 1

dData2 := dData

DO WHILE nDIAS > nSoma

	IF U_DATAUTIL(dData2)
		++nSoma
	ENDIF
	dData2 := DaySum(dData2,1)
ENDDO

DO WHILE !U_DATAUTIL(dData2)
	dData2 := DaySum(dData2,1)
ENDDO


RETURN dData2 
