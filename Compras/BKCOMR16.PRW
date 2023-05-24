#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} BKCOMR16
BK - Relatório Pedidos de Compra em Aberto

@Return
@author Marcos Bispo Abrahão
@since 18/05/23
@version P12
/*/

User Function BKCOMR16()

Private cTitulo     := "Pedidos de Compras em Aberto"
Private cPerg 		:= "BKCOMR16"
Private	cPict       := "@E 99,999,999,999.99"
Private aTitulos,aCampos,aCabs,aTotal,aPlans := {}

u_MsgLog(cPerg)

aCabs   := {}
aCampos := {}
aTitulos:= {}
aTotal  := {}

aAdd(aTitulos,cTitulo)

aAdd(aCampos,"QTMP->C7_NUM")
aAdd(aCabs  ,"Pedido")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->C7_EMISSAO")
aAdd(aCabs  ,"Emissão")
aAdd(aTotal,.F.)

aAdd(aCampos,"UsrRetName(QTMP->C1_USER)")
aAdd(aCabs  ,"Solicitante")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->A2_NOME")
aAdd(aCabs  ,"Razão Social")
aAdd(aTotal,.F.)

aAdd(aCampos,"Transform(QTMP->A2_CGC,'@R 99.999.999/9999-99')")
aAdd(aCabs  ,"CNPJ")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->C7_PRODUTO")
aAdd(aCabs  ,"Produto")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->B1_DESC")
aAdd(aCabs  ,"Desc. Produto")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->C7_UM")
aAdd(aCabs  ,"UM")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->C7_QUANT")
aAdd(aCabs  ,"Qtde")
aAdd(aTotal,.T.)

aAdd(aCampos,"QTMP->C7_PRECO")
aAdd(aCabs  ,"Valor Unitário")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->C7_TOTAL")
aAdd(aCabs  ,"Valor Total")
aAdd(aTotal,.T.)

aAdd(aCampos,"QTMP->C7_CC")
aAdd(aCabs  ,"Contrato")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->CTT_DESC01")
aAdd(aCabs  ,"Descrição Contrato")
aAdd(aTotal,.F.)

aAdd(aCampos,"IIF(QTMP->C7_CONAPRO='L','Sim','Não')")
aAdd(aCabs  ,"Liberado")
aAdd(aTotal,.F.)

aAdd(aCampos,"IIF(QTMP->C7_QUANT==QTMP->C7_QUJE,'Total',IIF(QTMP->C7_QUJE>0,'Parcial','Não Entregue'))")
aAdd(aCabs  ,"Entrega")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->C7_QUJE")
aAdd(aCabs  ,"Qtde Entregue")
aAdd(aTotal,.T.)

aAdd(aCampos,"IIF(QTMP->C7_XXURGEN=='S','Sim','Não')")
aAdd(aCabs  ,"Urgente")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->C7_OBS")
aAdd(aCabs  ,"Observações")
aAdd(aTotal,.F.)

u_WaitLog(, {|| PRCCOMR16() })

aAdd(aPlans,{"QTMP",cPerg ,"",cTitulo,aCampos,aCabs,/*aImpr*/, /* aAlign */,/* aFormat */, aTotal, /*cQuebra*/, lClose:= .T. })

U_PlanXlsx(aPlans,cTitulo,cPerg,.T.)

Return



Static Function PRCCOMR16
Local cQuery 	:= ""

cQuery := "SELECT " + CRLF
cQuery += " 	C7_FORNECE" + CRLF
cQuery += " 	,C7_LOJA" + CRLF
cQuery += " 	,C7_NUM" + CRLF
cQuery += " 	,C7_NUMCOT" + CRLF
cQuery += " 	,C7_ITEM" + CRLF
cQuery += " 	,C7_XXURGEN" + CRLF
cQuery += " 	,C7_EMISSAO" + CRLF
cQuery += " 	,C7_PRODUTO" + CRLF
cQuery += " 	,SB1.B1_DESC" + CRLF
cQuery += " 	,C7_UM" + CRLF
cQuery += " 	,C7_QUANT" + CRLF
cQuery += " 	,C7_QUJE" + CRLF
cQuery += " 	,C7_PRECO" + CRLF
cQuery += " 	,C7_TOTAL" + CRLF
cQuery += " 	,C7_CC" + CRLF
cQuery += " 	,C7_CONAPRO" + CRLF
cQuery += " 	,C7_OBS" + CRLF
cQuery += " 	,CTT.CTT_DESC01" + CRLF
cQuery += " 	,SA2.A2_NREDUZ" + CRLF
cQuery += " 	,SA2.A2_NOME" + CRLF
cQuery += " 	,SA2.A2_CGC " + CRLF
cQuery += " 	,SC1.C1_USER " + CRLF
cQuery += " FROM "+RETSQLNAME("SC7")+" SC7"+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+" SB1 ON SB1.B1_FILIAL='" +xFilial("SB1")+"' AND SC7.C7_PRODUTO=SB1.B1_COD AND SB1.D_E_L_E_T_=''" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON CTT.CTT_FILIAL='"+xFilial("CTT")+"' AND SC7.C7_CC=CTT.CTT_CUSTO AND CTT.D_E_L_E_T_=''" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SA2")+" SA2 ON SA2.A2_FILIAL='" +xFilial("SA2")+"' AND SC7.C7_FORNECE=SA2.A2_COD AND SC7.C7_LOJA=SA2.A2_LOJA AND SA2.D_E_L_E_T_=''" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC1")+" SC1" + CRLF
cQuery += "     ON (C7_FILIAL = C1_FILIAL " + CRLF
cQuery += "         AND C7_NUMSC = C1_NUM " + CRLF
cQuery += "         AND C7_ITEMSC = C1_ITEM " + CRLF
cQuery += "         AND SC7.D_E_L_E_T_ = ''" + CRLF
cQuery += "  ) " + CRLF

cQuery += " WHERE SC7.D_E_L_E_T_='' " + CRLF
cQuery += " AND ( (C7_QUANT-C7_QUJE) > 0 ) AND C7_RESIDUO = ' ' " + CRLF
//cQuery += " AND SC7.C7_EMISSAO>='"+DTOS(dDataI)+"' AND SC7.C7_EMISSAO<='"+DTOS(dDataF)+"'
//cQuery += " AND SC7.C7_NUM >='"+ALLTRIM(cPEDI)+"' AND SC7.C7_NUM <='"+ALLTRIM(cPEDF)+"'" 
//cQuery += " AND SC7.C7_FORNECE >='"+ALLTRIM(cFornI)+"' AND SC7.C7_FORNECE <='"+ALLTRIM(cFornF)+"'" 
//cQuery += " AND SC7.C7_CC >='"+ALLTRIM(cContraI)+"' AND SC7.C7_CC <='"+ALLTRIM(cContraF)+"'"

u_LogMemo(cPerg+".SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","C7_EMISSAO","D",8,0)

Return


