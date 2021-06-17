#include "rwmake.ch"

/*/{Protheus.doc} M410ALOK
	BK - Ponto de Entrada antes da exclusao do pedido pelo fat
	@type  Function
	@author user
	@since 01/01/2002
	@version P10,P11,P12
	@param param_name, param_type, param_descr
	@return _lRet, Lógica, sendo:.T. Prossegue alteracao do Pedido de Venda .F. Impede alteracao no pedido de venda
	@example
	(examples)
	@see (links_or_references)
	/*/


User Function M410ALOK()
Local _lRet := .T.

If !Empty(SC5->C5_NOTA) .and. ALTERA
	MsgBox("Nota Fiscal já gerada, pedido não pode ser Alterado!","M410ALOK","ALERT")
	_lRet := .F.
Else
	If !Empty(SC5->C5_MDCONTR) .and. ALTERA
		MsgBox("Pedido de Origem na Gestão de Contratos nao pode ser Alterado no Faturamento!","M410ALOK","ALERT")
		If __cUserId <> "000000"
			_lRet := .F.
		Else
			MsgBox("Pedido de Origem na Gestão de Contratos - Alteração permitida para o Adm!","M410ALOK","ALERT")
		Endif
	Endif
Endif

Return(_lRet)

