#include "totvs.ch"
#include "protheus.ch"
#include "TopConn.ch"
#INCLUDE "rwmake.ch"

/*/{Protheus.doc} BKGCTA20
BK - Valida Vencimento do Contrato Chamada do Centro de Custo Contratos

@Return
@author Adilson do Prado
@since 31/05/16 rev 22/11/22
@version P12
/*/                                      

User Function BKGCTA20(cContrato)
Local lRet  := .T.
Local cVig  := ""
Local aArea := {}
Local cProg	:= "BKGCTA20"

If FWIsInCallStack("U_BKCOMA13") .OR. ALLTRIM(FUNNAME()) == 'RPC'
	Return lRet
ENDIF

aArea := GetArea()
cVig  := U_Vig2Contrat(cContrato,Date(),cEmpAnt)

IF !EMPTY(cVig)
   IF !u_MsgLog(cProg,"Contrato "+TRIM(cContrato)+" - "+cVig+"! Confirma a inclusão desta despesa neste C.Custo ?","N")
		lRet := .F.
   ENDIF
ENDIF

RestArea(aArea)

Return lRet
