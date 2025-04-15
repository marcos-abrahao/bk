#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} BKCOMR20
BK - Relatório Solicitações de Compra em Aberto

@Return
@author Marcos Bispo Abrahão
@since 18/05/23
@version P12
/*/

User Function BKCOMR20()
Local cDescr 	:= "O objetivo deste relatório é listar as solicitações de compras com preço final"
Local cVersao	:= "15/04/2025 - Versão inicial"
Local oRExcel	AS Object
Local oPExcel	AS Object
Local cAlias    := "QTMP"

Private cTitulo   := "Solicitações de Compras com preço final"
Private aParam  := {}
Private aRet    := {}
Private cSCIni  := SPACE(TamSX3("C1_NUM")[1])
Private cSCFim  := cSCIni

Private cProg 	:= "BKCOMR20"

cVersao += "" //CRLF+""


aAdd(aParam, {1,"Numero SC inicial:",cSCIni,""    ,"" ,"SC1","",40,.F.})
aAdd(aParam, {1,"Numero SC final:"  ,cSCFim,""    ,"" ,"SC1","",40,.F.})

If !BkPar()
   Return
EndIf


// Execução da Query
u_WaitLog(cProg, {|| PRCCOMR20() })

// Definição do Arq Excel
oRExcel := RExcel():New(cProg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetVersao(cVersao)
oRExcel:SetDescr(cDescr)
oRExcel:SetParam(aParam)
oRExcel:SetSolicit("02/04/2025 - GLPI 1875 - Romário/Bárbara")

// Definição da Planilha 1
oPExcel:= PExcel():New(cProg,cAlias)
oPExcel:SetTitulo("")

// Colunas da Planilha 1

oPExcel:AddColX3("C1_NUM")

oPExcel:AddCol("USUARIO","UsrRetName(QTMP->C1_USER)","Solicitante","")
oPExcel:GetCol("USUARIO"):SetTamCol(20)

oPExcel:AddColX3("C1_ITEM")

oPExcel:AddColX3("C1_PRODUTO")

oPExcel:AddColX3("B1_DESC")

oPExcel:AddColX3("C1_UM")

oPExcel:AddColX3("C1_QUANT")
oPExcel:GetCol("C1_QUANT"):SetTotal(.T.)

oPExcel:AddColX3("C7_PRECO")

oPExcel:AddCol("TOTAL","'=##C1_QUANT##*##C7_PRECO##'","Total","")
oPExcel:GetCol("TOTAL"):SetTipo("FN")
oPExcel:GetCol("TOTAL"):SetTotal(.T.)

oPExcel:AddColX3("C1_DATPRF")
oPExcel:GetCol("C1_DATPRF"):SetTitulo("Dt.Prevista")

oPExcel:AddColX3("C1_CC")

oPExcel:AddColX3("CTT_DESC01")
oPExcel:GetCol("CTT_DESC01"):SetTitulo("Descr. Centro de Custos")

oPExcel:AddColX3("C1_XXENDEN")

// Adiciona a planilha 1
oRExcel:AddPlan(oPExcel)

// Cria arquivo Excel
oRExcel:Create()

QTMP->(dbCloseArea())

Return

Static Function BkPar
Local lRet := .F.
//   Parambox(aParametros,@cTitle            ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam      ,cProg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKFINR28",.T.         ,.T.))
	lRet   := .T.
    cSCIni := mv_par01
    cSCFim := mv_par02
Endif
Return lRet



Static Function PRCCOMR20
Local cQuery 	:= ""

cQuery := "SELECT " + CRLF
cQuery += " 	 C1_USER" + CRLF
cQuery += " 	,C1_EMISSAO" + CRLF
cQuery += " 	,C1_DATPRF" + CRLF
cQuery += " 	,C1_NUM" + CRLF
cQuery += " 	,C1_ITEM" + CRLF
cQuery += " 	,C1_PRODUTO" + CRLF
cQuery += " 	,B1_DESC" + CRLF
cQuery += " 	,C1_UM" + CRLF
cQuery += " 	,C1_QUANT" + CRLF
//cQuery += " 	,C1_QUJE" + CRLF
cQuery += " 	,C1_CC" + CRLF
cQuery += " 	,CTT_DESC01" + CRLF
cQuery += " 	,C1_XDTAPRV" + CRLF
cQuery += " 	,C1_XXLCVAL" + CRLF
//cQuery += " 	,C1_XXLCTOT" + CRLF
//cQuery += " 	,C1_APROV" + CRLF
//cQuery += " 	,C1_OBS" + CRLF
//cQuery += " 	,C1_XDTAPRV" + CRLF
cQuery += " 	,C1_XXENDEN" + CRLF
cQuery += " 	,ISNULL(C7_PRECO,C1_XXLCVAL) AS C7_PRECO" + CRLF

cQuery += " FROM "+RETSQLNAME("SC1")+" SC1" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+" SB1 ON SB1.D_E_L_E_T_='' AND B1_COD = C1_PRODUTO" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON CTT.D_E_L_E_T_='' AND C1_CC = CTT_CUSTO" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC7")+" SC7 ON SC7.D_E_L_E_T_='' AND C7_NUMSC = C1_NUM AND C7_ITEMSC = C1_ITEM" + CRLF
cQuery += " WHERE SC1.D_E_L_E_T_=''" + CRLF
If !Empty(cSCIni)
    cQuery += "     AND C1_NUM >= '"+cSCIni+"'" + CRLF 
EndIf
If !Empty(cSCFim)
    cQuery += "     AND C1_NUM <= '"+cSCFim+"'" + CRLF 
EndIf
cQuery += " ORDER BY C1_NUM,C1_ITEM" + CRLF

u_LogMemo(cProg+".SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","C1_EMISSAO","D",8,0)
TCSETFIELD("QTMP","C1_DATPRF","D",8,0)
TCSETFIELD("QTMP","C1_XDTAPRV","D",8,0)

Return


