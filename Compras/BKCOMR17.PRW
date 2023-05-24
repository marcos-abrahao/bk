#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} BKCOMR17
BK - Relatório Solicitações de Compra em Aberto

@Return
@author Marcos Bispo Abrahão
@since 18/05/23
@version P12
/*/

User Function BKCOMR17()

Private cTitulo     := "Solicitações de Compras em Aberto"
Private cPerg 		:= "BKCOMR17"
Private	cPict       := "@E 99,999,999,999.99"
Private aTitulos,aCampos,aCabs,aTotal,aPlans := {}

u_MsgLog(cPerg)

aCabs   := {}
aCampos := {}
aTitulos:= {}
aTotal  := {}

aAdd(aTitulos,cTitulo)

aAdd(aCampos,"QTMP->C1_NUM")
aAdd(aCabs  ,"Solicitação")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->C1_ITEM")
aAdd(aCabs  ,"Item")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->C1_EMISSAO")
aAdd(aCabs  ,"Emissão")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->C1_DATPRF")
aAdd(aCabs  ,"Dt.Prevista")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->C1_XDTAPRV")
aAdd(aCabs  ,"Aprovação")
aAdd(aTotal,.F.)

aAdd(aCampos,"UsrRetName(QTMP->C1_USER)")
aAdd(aCabs  ,"Solicitante")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->C1_PRODUTO")
aAdd(aCabs  ,"Produto")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->B1_DESC")
aAdd(aCabs  ,"Desc. Produto")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->C1_UM")
aAdd(aCabs  ,"UM")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->C1_QUANT")
aAdd(aCabs  ,"Qtde")
aAdd(aTotal,.T.)

aAdd(aCampos,"QTMP->C1_XXLCVAL")
aAdd(aCabs  ,"Valor Un. Estimado")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->C1_XXLCTOT")
aAdd(aCabs  ,"Valor Total")
aAdd(aTotal,.T.)

aAdd(aCampos,"QTMP->C1_CC")
aAdd(aCabs  ,"Contrato")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->CTT_DESC01")
aAdd(aCabs  ,"Descrição Contrato")
aAdd(aTotal,.F.)

aAdd(aCampos,"IIF(QTMP->C1_APROV == 'L','Sim','Não')")
aAdd(aCabs  ,"Aprovado")
aAdd(aTotal,.F.)

aAdd(aCampos,"QTMP->C1_QUJE")
aAdd(aCabs  ,"Qtde Entregue")
aAdd(aTotal,.T.)

aAdd(aCampos,"QTMP->C1_OBS")
aAdd(aCabs  ,"Observações")
aAdd(aTotal,.F.)

u_WaitLog(, {|| PRCCOMR17() })

aAdd(aPlans,{"QTMP",cPerg ,"",cTitulo,aCampos,aCabs,/*aImpr*/, /* aAlign */,/* aFormat */, aTotal, /*cQuebra*/, lClose:= .T. })

U_PlanXlsx(aPlans,cTitulo,cPerg,.T.)

Return



Static Function PRCCOMR17
Local cQuery 	:= ""

cQuery := "SELECT " + CRLF
cQuery += " 	C1_USER" + CRLF
cQuery += " 	,C1_EMISSAO" + CRLF
cQuery += " 	,C1_DATPRF" + CRLF
cQuery += " 	,C1_NUM" + CRLF
cQuery += " 	,C1_ITEM" + CRLF
cQuery += " 	,C1_PRODUTO" + CRLF
cQuery += " 	,B1_DESC" + CRLF
cQuery += " 	,C1_UM" + CRLF
cQuery += " 	,C1_QUANT" + CRLF
cQuery += " 	,C1_QUJE" + CRLF
cQuery += " 	,C1_CC" + CRLF
cQuery += " 	,CTT_DESC01" + CRLF
cQuery += " 	,C1_XDTAPRV" + CRLF
cQuery += " 	,C1_XXLCVAL" + CRLF
cQuery += " 	,C1_XXLCTOT" + CRLF
cQuery += " 	,C1_APROV" + CRLF
cQuery += " 	,C1_OBS" + CRLF
cQuery += " 	,C1_XDTAPRV" + CRLF

cQuery += " FROM "+RETSQLNAME("SC1")+" SC1" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+" SB1 ON SB1.D_E_L_E_T_='' AND B1_COD =C1_PRODUTO" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON CTT.D_E_L_E_T_='' AND C1_CC =CTT_CUSTO" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC8")+" SC8 ON SC8.D_E_L_E_T_='' AND C8_NUM=C1_COTACAO AND C8_ITEMSC=C1_ITEM" + CRLF
cQuery += " WHERE SC1.D_E_L_E_T_=''" + CRLF
cQuery += "     AND C1_RESIDUO = ''" + CRLF 
cQuery += "     AND C1_APROV <> 'B'" + CRLF
cQuery += "     AND C1_QUJE < C1_QUANT " + CRLF
cQuery += "     AND C8_NUMSC IS NULL" + CRLF
cQuery += " ORDER BY C1_NUM,C1_ITEM" + CRLF
//,C1_SOLICIT,C1_EMISSAO,C1_DATPRF,C1_PRODUTO,B1_DESC,C1_UM,C1_QUANT,C1_QUJE,C1_CC,CTT_DESC01,C1_XDTAPRV" + CRLF
//cQuery += " ORDER BY C1_NUM,C1_ITEM,C1_SOLICIT,C1_EMISSAO,C1_DATPRF,C1_PRODUTO,B1_DESC,C1_UM,C1_QUANT,C1_QUJE,C1_CC,CTT_DESC01,C1_XDTAPRV" + CRLF

u_LogMemo(cPerg+".SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","C1_EMISSAO","D",8,0)
TCSETFIELD("QTMP","C1_DATPRF","D",8,0)
TCSETFIELD("QTMP","C1_XDTAPRV","D",8,0)

Return


