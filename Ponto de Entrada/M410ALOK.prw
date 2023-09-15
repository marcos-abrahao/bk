#include "rwmake.ch"

/*/{Protheus.doc} M410ALOK
	BK - Ponto de Entrada antes da exclusao do pedido pelo faturamento
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
	u_MsgLog("M410ALOK","Nota Fiscal "+SC5->C5_NOTA+" já gerada, pedido "+SC5->C5_NUM+" não pode ser Alterado!","E")
	_lRet := .F.
Else
	If !Empty(SC5->C5_MDCONTR) .and. ALTERA
		If __cUserId <> "000000"
			_lRet := .F.
			u_MsgLog("M410ALOK","Pedido "+SC5->C5_NUM+" de Origem na Gestão de Contratos nao pode ser Alterado no Faturamento!","E")
		Else
			u_MsgLog("M410ALOK","Pedido "+SC5->C5_NUM+" de Origem na Gestão de Contratos - Alteração permitida para o Adm!","W")
		Endif
	Endif
Endif

Return(_lRet)

