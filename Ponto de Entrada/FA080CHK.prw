#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} FA080CHK
BK - Ponto de Entrada para evitar que titulos incluidos pelo liquidos BK sejam excluidos por esta rotina
@Return
@author Marcos Bispo Abrahão
@since 25/02/11
@version P12
/*/

User Function FA080CHK() 
Local lRet := .T.

If !lF080Auto
	IF TRIM(SE2->E2_XXTIPBK) = "PCT"
	    u_MsgLog(,"Este titulo se refere a uma prestação de contas gerada pelo Liquidos BK, utilize a função compensação", "W")
	    lRet := .F.
	ENDIF

	IF TRIM(SE2->E2_XXTIPBK) = "NDB"
		IF VAL(__CUSERID) == 0 .OR. VAL(__CUSERID) == 12 //.OR. ASCAN(aUser[1,10],cMDiretoria) > 0        
		   lRet := .T.
		ELSE   
		    u_MsgLog(,"A baixa deste titulo (tipobk = NDB) somente está disponível para os administradores do sistema", "W")
		    lRet := .F.
		ENDIF
	ENDIF

	IF TRIM(SE2->E2_TIPO) = "NDF"
	    u_MsgLog(,"Título a receber", "W")
	    lRet := .T.
	ENDIF

EndIf

Return lRet

