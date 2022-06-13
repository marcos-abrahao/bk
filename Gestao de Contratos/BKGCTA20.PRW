#include "totvs.ch"
#include "protheus.ch"
#include "TopConn.ch"
#INCLUDE "rwmake.ch"

/*/{Protheus.doc} BKGCTA20
BK - Valida Vencimento do Contrato Chamada do Centro de Custo Contratos

@Return
@author Adilson do Prado
@since 31/05/16
@version P12
/*/                                      

User Function BKGCTA20(cContrato)
Local lRet := .T.
Local cVig := ""
Local aArea      := GetArea()

//u_LogPrw("BKGCTA20","Valida Vencimento do Contrato Chamada do Centro de Custo "+cContrato)

IF  ALLTRIM(funname()) == 'RPC'   // GERA APORT BK
	RestArea(aArea)
	Return lRet
ENDIF

cVig := U_Vig2Contrat(cContrato,Date(),cEmpAnt)
IF !EMPTY(cVig)
   IF !MsgYesNo("Contrato "+TRIM(cContrato)+" - "+cVig+"  !!  Confirma Inclusão deste C.Custo ??","Atenção")
		lRet := .F.
   ELSE
		u_LogPrw("BKGCTA20","Entrada em contrato vencido "+cContrato)
   ENDIF
ENDIF

RestArea(aArea)

Return lRet
