#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MT150FIX บAutor  ณAdilso do Prado   บ Data ณ  06/02/13     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ LOCALIZAวรO : Function MATA150() - Responsแvel pela		  บฑฑ
ฑฑบ atualiza็ใo manual das cota็๕es de compra.EM QUE PONTO : Ponto de	  บฑฑ
ฑฑบ entrada para manipular a ordem dos campos do array aFixe.			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BK                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

USER FUNCTION MT150FIX()
Local afixe 		:=	{{"Numero","C8_NUM    " },;			//"Numero"
						{ "Fornecedor","C8_FORNECE" },;		//"Fornecedor"
						{ "Loja","C8_LOJA   " },;			//"Loja"
						{ "Nome Fornec.","C8_FORNOME" },;	//"Loja"
						{ "Proposta","C8_NUMPRO" },;		//"Proposta"
						{ "Cod.Produto","C8_PRODUTO" },;	//"Cod.Produto"
						{ "Desc.Produto","C8_DESCRI" },;	//"Desc.Produto"
						{ "Pre็o","C8_PRECO" },;			//"Preco"
						{ "Validade ","C8_VALIDA " }}		//"Validade "
RETURN aFixe
