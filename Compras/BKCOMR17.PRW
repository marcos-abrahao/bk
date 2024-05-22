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
Local cDescr 	:= "O objetivo deste relatório é demonstrar as solicitações de compras em aberto."
Local cVersao	:= "18/05/2023 - Versão inicial"
Local oRExcel	AS Object
Local oPExcel	AS Object
Local aParam 	:= {}
Local cTitulo   := "Solicitações de Compras em Aberto"
Local cAlias    := "QTMP"
Private cProg 	:= "BKCOMR17"

cVersao += CRLF+"22/05/24 - REXCEL"

// Execução da Query
u_WaitLog(cProg, {|| PRCCOMR17() })

// Definição do Arq Excel
oRExcel := RExcel():New(cProg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetVersao(cVersao)
oRExcel:SetDescr(cDescr)
oRExcel:SetParam(aParam)

// Definição da Planilha 1
oPExcel:= PExcel():New(cProg,cAlias)
oPExcel:SetTitulo("")

// Colunas da Planilha 1

oPExcel:AddColX3("C1_NUM")

oPExcel:AddColX3("C1_ITEM")

oPExcel:AddColX3("C1_EMISSAO")

oPExcel:AddColX3("C1_DATPRF")
oPExcel:GetCol("C1_DATPRF"):SetTitulo("Dt.Prevista")

oPExcel:AddColX3("C1_XDTAPRV")

oPExcel:AddCol("USUARIO","UsrRetName(QTMP->C1_USER)","Solicitante","")
oPExcel:GetCol("USUARIO"):SetTamCol(20)

oPExcel:AddColX3("C1_PRODUTO")

oPExcel:AddColX3("B1_DESC")

oPExcel:AddColX3("C1_UM")

oPExcel:AddColX3("C1_QUANT")
oPExcel:GetCol("C1_QUANT"):SetTotal(.T.)

oPExcel:AddColX3("C1_XXLCVAL")

oPExcel:AddColX3("C1_XXLCTOT")
oPExcel:GetCol("C1_XXLCTOT"):SetTotal(.T.)

oPExcel:AddColX3("C1_CC")

oPExcel:AddColX3("CTT_DESC01")
oPExcel:GetCol("CTT_DESC01"):SetTitulo("Descrição do Centro de Custos")

oPExcel:AddCol("APROVADO","IIF(QTMP->C1_APROV == 'L','Sim','Não')","Aprovado","")
oPExcel:GetCol("APROVADO"):SetTamCol(12)
oPExcel:GetCol("APROVADO"):SetHAlign("C")
oPExcel:GetCol("APROVADO"):AddCor({|x| SUBSTR(x,1,1) == 'N'},"FF0000","",,,.T.)	// Vermelho
oPExcel:GetCol("APROVADO"):AddCor({|x| SUBSTR(x,1,1) == 'S'},"008000","",,,.T.)	// Verde

oPExcel:AddColX3("C1_QUJE")
oPExcel:GetCol("C1_QUJE"):SetTotal(.T.)

oPExcel:AddColX3("C1_OBS")

// Adiciona a planilha 1
oRExcel:AddPlan(oPExcel)

// Cria arquivo Excel
oRExcel:Create()

QTMP->(dbCloseArea())

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

u_LogMemo(cProg+".SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","C1_EMISSAO","D",8,0)
TCSETFIELD("QTMP","C1_DATPRF","D",8,0)
TCSETFIELD("QTMP","C1_XDTAPRV","D",8,0)

Return


