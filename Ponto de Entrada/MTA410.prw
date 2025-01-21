#include "rwmake.ch"

/*/{Protheus.doc} MTA410
    Ponto de Entrada de validação do pedido de vendas
    @type  Function
    @author Marcos Abrahão
    @since 11/08/15
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

User Function MTA410()
Local _lRet := .T.
If Empty(M->C5_MDCONTR) .and. (ALTERA .OR. INCLUI)
	If Empty(M->C5_ESPECI1)
		u_MsgLog("MTA410","C.Custo (BK) deve ser obrigatoriamente preenchido!","E")
		_lRet := .F.
	ElseIf Empty(M->C5_XXCOMPT)
		u_MsgLog("MTA410","Para pedidos avulsos, a competência deve ser obrigatoriamente preenchida!","E")
		_lRet := .F.
	Else
		If VAL(SUBSTR(M->C5_XXCOMPT,1,2)) < 1 .OR. VAL(SUBSTR(M->C5_XXCOMPT,1,2)) > 12
			u_MsgLog("MTA410","Preencha corretamente o mes da competência!","E")
			_lRet := .F.
		EndIf	
		If _lRet .AND. (VAL(SUBSTR(M->C5_XXCOMPT,3,4)) < 2009 .OR. VAL(SUBSTR(M->C5_XXCOMPT,3,4)) > 2100)
			u_MsgLog("MTA410","Preencha corretamente o ano da competência!","E")
			_lRet := .F.
    	EndIf
   EndIf
   If !Empty(M->C5_XXCOMPT) 
		M->C5_XXCOMPM := SUBSTR(M->C5_XXCOMPT,1,2)+"/"+SUBSTR(M->C5_XXCOMPT,3,4)
   EndIf
EndIf

Return(_lRet)
