#include "rwmake.ch"

/*/{Protheus.doc} FA050UPD
BK - Ponto de Entrada para evitar que titulos incluidos pela rotina liquidos BK sejam excluidos por esta rotina
@Return
@author Adilson do Prado / Marcos Bispo Abrahão
@since 02/10/09
@version P12
/*/

User Function FA050UPD() 
Local lRet := .T.

IF !lF050Auto
	IF !EMPTY(SE2->E2_XXCTRID)  .AND. (_Opc == 4 .OR. _Opc == 5)
	    IF __cUserId <> "000000"
	    	//__cUserId <> "000012" .AND. 
	    	MsgStop("Este titulo foi gerado pelos Liquidos BK, utilize a rotina adequada", "Atenção")
	    	lRet := .F.
	    ELSE
	    	IF Aviso( "Atencao", "Este titulo foi gerado pelos Liquidos BK. Excluir Titulo?",{"Sim","Nao"} ) <> 1
	    		lRet := .F.
	    	ENDIF
	    ENDIF
	ENDIF
ENDIF

Return lRet

