#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BMVFOLHA
OSESP - Rotina verificar qual periodo da folha esta ativo
@Return
@author Adilson do Prado
@since 17/00/2024
@version P12
/*/
//-------------------------------------------------------------------

USER FUNCTION MVFOLHA(cROTEIR)
LOCAL c_MVFOLHA := "" 
LOCAL c_Query := ""

DEFAULT cROTEIR := "FOL"


c_Query := " SELECT TOP 1 RCH_PER FROM "+RETSQLNAME("RCH")+ " RCH"
c_Query += " WHERE D_E_L_E_T_='' AND RCH_ROTEIR='"+cROTEIR+"'"
c_Query += " AND RCH_STATUS<>'5' ORDER BY RCH_PER"

IF SELECT('QRCH')> 0
	QRCH->(DBCLOSEAREA())
ENDIF

TCQUERY c_Query NEW ALIAS "QRCH"

DBSELECTAREA("QRCH")
QRCH->(dbGoTop())
Do While QRCH->(!EOF())

	c_MVFOLHA := ALLTRIM(QRCH->RCH_PER)
	
	dbSelectArea("QRCH")
	QRCH->(dbSkip())
ENDDO
QRCH->(DbCloseArea()) 


RETURN c_MVFOLHA
