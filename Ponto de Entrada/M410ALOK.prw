#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณM410ALOK  บAutor  ณEwerton C Tomaz     บ Data ณ  09/12/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada antes da exclusao do pedido pelo fat.     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      ณAnalista/Altera็๕es                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
M410ALOK Revisใo: 01/01/2002
Sintaxe M410ALOK ( < UPAR > ) --> URET
Parโmetros
Argumento	Tipo	Descri็ใo
UPAR 	 (Qualquer)	Nenhum
Retorno
Tipo	    Descri็ใo
(Qualquer)	Variavel logica, sendo:.T. Prossegue alteracao do Pedido de Venda
.F. Impede alteracao no pedido de venda
Descri็ใo
EXECUTA ANTES DE ALTERAR PEDIDO VENDA
Executado antes de iniciar a alteracao do pedido de venda
Grupos Relacionados
Principal / Sistemas / Pontos de Entrada / Vendas e Fiscal / SIGAFAT / MATA410 */

User Function M410ALOK()
Local _lRet := .T.

If !Empty(SC5->C5_NOTA) .and. ALTERA
	MsgBox("Nota Fiscal jแ gerada pedido nใo pode ser Alterado!","TI - BK","ALERT")
	_lRet := .F.
Else
	If !Empty(SC5->C5_MDCONTR) .and. ALTERA
		MsgBox("Pedido de Origem na Gestใo de Contratos nao pode ser Alterado no Faturamento!","TI - BK","ALERT")
		_lRet := .F.
	Endif
Endif

Return(_lRet)

