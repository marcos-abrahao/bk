#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKGCTR29
BK - Relatório Despesas por Contrato

@Return
@author Marcos Bispo Abrahão
@since 10/10/2024
@version P12
/*/

User Function BKGCTR29()
Local cDescr 	:= "O objetivo deste relatório é demonstrar as despesas por Contrato."
Local cVersao	:= "10/10/2024 - Versão inicial"
Local oRExcel	AS Object
Local oPExcel	AS Object

Private cTitulo := "Despesas por Contrato"
Private cAlias  := GetNextAlias()
Private cProg 	:= "BKGCTR29"
Private aParam  := {}
Private aRet    := {}

Private cCusto      := SPACE(TamSx3("CTT_CUSTO")[1])

aAdd(aParam, {1,"Contrato:"  ,cCusto,""    ,""                                       ,"CTT","",70,.F.})

If !BkPar()
   Return
EndIf

u_MsgLog(cProg)

//cVersao += CRLF+"22/05/24 - REXCEL"

// Execução da Query
u_WaitLog(cProg, {|| PRCGCTR29() })

// Definição do Arq Excel
oRExcel := RExcel():New(cProg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetVersao(cVersao)
oRExcel:SetSolicit("10/10/2024: Bruno Bueno")
oRExcel:SetDescr(cDescr)
oRExcel:SetParam(aParam)

// Definição da Planilha 1
oPExcel:= PExcel():New(cProg,cAlias)
oPExcel:SetTitulo("")

// Colunas da Planilha 1

oPExcel:AddCol("EMPRESA","EMPRESA","Empresa","")

oPExcel:AddCol("NOMEEMP","NOMEEMP","Empresa","")

oPExcel:AddCol("DATAPRC","DATAPRC","Processamento","")

oPExcel:AddCol("CONTRATO","CONTRATO","Contrato","")

oPExcel:AddCol("DESCRICAO","DESCRICAO","Descrição","")

oPExcel:AddCol("COMPET","COMPET","Competência","")

oPExcel:AddCol("ORIGEM","ORIGEM","Origem","")

oPExcel:AddColX3("D1_SERIE")

oPExcel:AddColX3("D1_FORNECE")

oPExcel:AddColX3("D1_LOJA")

oPExcel:AddColX3("A2_NOME")

oPExcel:AddColX3("D1_ITEM")

oPExcel:AddColX3("D1_COD")

oPExcel:AddColX3("B1_DESC")

oPExcel:AddColX3("B1_GRUPO")

oPExcel:AddColX3("BM_DESC")

oPExcel:AddColX3("ZI_COD")

oPExcel:AddColX3("ZI_DESC")

oPExcel:AddColX3("F1_VALBRUT")

oPExcel:AddCol("F1RESPON","F1RESPON","Responsável","")

oPExcel:AddColX3("E2_PARCELA")

oPExcel:AddColX3("E2_VALOR")

oPExcel:AddColX3("E2_BAIXA")

oPExcel:AddColX3("E2_VENCREA")

oPExcel:AddCol("D1TOTIT","D1TOTIT","Total Item","")
oPExcel:GetCol("D1TOTIT"):SetTotal(.T.)

oPExcel:AddCol("E2ACDECIT","E2ACDECIT","Acrescimos/Decrescimos","")
oPExcel:GetCol("E2ACDECIT"):SetTotal(.T.)

oPExcel:AddCol("DESPESA","DESPESA","Despesa","")
oPExcel:GetCol("DESPESA"):SetTotal(.T.)

// Adiciona a planilha 1
oRExcel:AddPlan(oPExcel)

// Cria arquivo Excel
oRExcel:Create()

(cAlias)->(dbCloseArea())

Return

Static Function BkPar
Local lRet := .F.
//   Parambox(aParametros,@cTitle            ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam      ,cProg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKFINR28",.T.         ,.T.))
	lRet     := .T.
    cCusto := mv_par01
Endif
Return lRet


Static Function PRCGCTR29

Local cQuery 	:= ""
Local bBlock
Local aBinds	:= {}
Local lRet 		:= .T.

cQuery := " SELECT " + CRLF
cQuery += "   EMPRESA" + CRLF
cQuery += "   ,NOMEEMP" + CRLF
cQuery += "   ,DATAPRC" + CRLF
cQuery += "   ,CONTRATO" + CRLF
cQuery += "   ,DESCRICAO" + CRLF
cQuery += "   ,COMPET" + CRLF
cQuery += "   ,COMPETAM" + CRLF
cQuery += "   ,COMPETD" + CRLF
cQuery += "   ,CHAVE" + CRLF
cQuery += "   ,ORIGEM" + CRLF
cQuery += "   ,D1_FILIAL" + CRLF
cQuery += "   ,D1_SERIE" + CRLF
cQuery += "   ,D1_DOC" + CRLF
cQuery += "   ,D1_FORNECE" + CRLF
cQuery += "   ,D1_LOJA" + CRLF
cQuery += "   ,A2_NOME" + CRLF
cQuery += "   ,D1_ITEM" + CRLF
cQuery += "   ,D1_COD" + CRLF
cQuery += "   ,D1_XXHIST" + CRLF
cQuery += "   ,B1_DESC" + CRLF
cQuery += "   ,B1_GRUPO" + CRLF
cQuery += "   ,BM_DESC" + CRLF
cQuery += "   ,ZI_COD" + CRLF
cQuery += "   ,ZI_DESC" + CRLF
cQuery += "   ,F1_VALBRUT" + CRLF
cQuery += "   ,F1_XXUSER" + CRLF
cQuery += "   ,F1RESPON" + CRLF
cQuery += "   ,F1_XXULIB" + CRLF
cQuery += "   ,F1APROV" + CRLF
cQuery += "   ,E2_PARCELA" + CRLF
cQuery += "   ,E2_VALOR" + CRLF
cQuery += "   ,E2_BAIXA" + CRLF
cQuery += "   ,E2_VENCREA" + CRLF
cQuery += "   ,E2_DESCONT" + CRLF
cQuery += "   ,E2_MULTA" + CRLF
cQuery += "   ,E2_JUROS" + CRLF
cQuery += "   ,E2_ACRESC" + CRLF
cQuery += "   ,E2_DECRESC" + CRLF
cQuery += "   ,E2_VRETPIS" + CRLF
cQuery += "   ,E2_VRETCOF" + CRLF
cQuery += "   ,E2_VRETCSL" + CRLF
cQuery += "   ,E2_VRETINS" + CRLF
cQuery += "   ,E2_VRETIRF" + CRLF
cQuery += "   ,E2_VRETISS" + CRLF
cQuery += "   ,E2VALTIT" + CRLF
cQuery += "   ,D1TOTAL" + CRLF
cQuery += "   ,E2ACDEC" + CRLF
cQuery += "   ,CHAVEZG" + CRLF
cQuery += "   ,E2ACDECIT" + CRLF
cQuery += "   ,D1TOTIT" + CRLF
cQuery += "   ,DESPESA" + CRLF
cQuery += "   ,PREVPROD" + CRLF
cQuery += "   ,PREVDESC" + CRLF

cQuery += " FROM PowerBk.dbo.GASTOSGERAIS" + CRLF
cQuery += " WHERE CONTRATO = ? " + CRLF
cQuery += " ORDER BY EMPRESA,COMPETAM" + CRLF

aAdd(aBinds,cCusto)

u_LogMemo(cProg+".SQL",cQuery)

bBlock := ErrorBlock( { |e| u_LogMemo(cProg+".SQL",e:Description) } )
BEGIN SEQUENCE
	dbUseArea(.T.,"TOPCONN",TCGenQry2(,,cQuery,aBinds),cAlias,.T.,.T.)
RECOVER
	lRet := .F.
END SEQUENCE

ErrorBlock(bBlock)

TCSETFIELD(cAlias,"E2_BAIXA","D",8,0)
TCSETFIELD(cAlias,"E2_VENCREA","D",8,0)


Return


