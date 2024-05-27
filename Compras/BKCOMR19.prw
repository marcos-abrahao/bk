
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKCOMR19
    Produtos x Grupos x Subgrupos
    @type  Relatório
    @author Marcos B. Abrahão
    @since 29/04/2024
    @version P12
/*/


User Function BKCOMR19
Local cProg 	:= "BKCOMR19"
Local cTitulo	:= "Produtos x Grupos x Subgrupos x Valor Estimado"
Local cDescr 	:= "O objetivo deste relatório é listar os produtos x grupos x subgrupos e Valor Estimado"
Local cVersao	:= "29/04/2023"
Local oRExcel	AS Object
Local oPExcel	AS Object
Local cQuery 	:= ""
Local cAlias 	:= "TMP"
Local aTcFields := {}
Local aRet		:= {}
Local aParam 	:= {}

cVersao	+= CRLF+"27/05/2024 - Valor Estimado"

Private cB1Blq  := "N"
Private cUltPrc := "N"

aAdd( aParam ,{ 2, "Listar bloqueados",     cB1Blq  ,{"Sim", "Não"}	, 60,'.T.'  ,.T.})
aAdd( aParam ,{ 2, "Listar Ultimo preço",   cUltPrc ,{"Sim", "Não"}	, 60,'.T.'  ,.T.})

If !ParCom19(cProg,@cTitulo,@aRet,aParam)
   Return
EndIf

//cQuery := "WITH PRD  AS ("

cQuery := "SELECT "+CRLF
cQuery += "  B1_COD "+CRLF
cQuery += " ,B1_DESC "+CRLF
cQuery += " ,B1_UM "+CRLF
cQuery += " ,B1_CONTA "+CRLF
cQuery += " ,(CASE WHEN B1_USERLGA = '' THEN B1_USERLGI ELSE B1_USERLGA END) AS B1_USERLGA "+CRLF
cQuery += " ,B1_UREV "+CRLF
cQuery += " ,B1_XXSGRP "+CRLF
cQuery += " ,ZI_DESC "+CRLF
cQuery += " ,B1_GRUPO "+CRLF
cQuery += " ,BM_DESC "+CRLF
cQuery += " ,CT1_DESC01 "+CRLF
cQuery += " ,(CASE WHEN B1_MSBLQL = '1' THEN 'BLOQUEADO' ELSE 'EM USO' END) AS BLOQUEIO "+CRLF

cQuery += " FROM "+RetSqlName("SB1")+" SB1 "+CRLF
cQuery += " LEFT JOIN "+RetSqlName("CT1")+" CT1 ON "+CRLF
cQuery += "  	CT1_CONTA = B1_CONTA "+CRLF
cQuery += "  	AND CT1.D_E_L_E_T_ = '' "+CRLF
cQuery += " LEFT JOIN "+RetSqlName("SZI")+" SZI ON ZI_COD = B1_XXSGRP AND SZI.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " LEFT JOIN "+RetSqlName("SBM")+" SBM ON BM_GRUPO = B1_GRUPO AND SBM.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " WHERE SB1.D_E_L_E_T_ = '' "+CRLF
cQuery += "     AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "+CRLF
If SUBSTR(cB1Blq,1,1) == 'N'
	cQuery += "     AND SB1.B1_MSBLQL != '1' "+CRLF
EndIf

cQuery += " ORDER BY B1_COD "+CRLF

aAdd(aTcFields,FWSX3Util():GetFieldStruct( "B1_UREV" ))

u_RunQuery(cProg,cQuery,cAlias,aTcFields)


// Definição do Arq Excel
oRExcel := RExcel():New(cProg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetVersao(cVersao)
oRExcel:SetDescr(cDescr)
oRExcel:SetParam(aParam)

// Definição da Planilha 1
oPExcel:= PExcel():New(cProg,cAlias)
oPExcel:SetTitulo("Utilização: conferência grupos e subgrupos")


// Colunas da Planilha 1
oPExcel:AddColX3("B1_COD")
oPExcel:AddColX3("B1_DESC")
oPExcel:AddColX3("B1_UM")

oPExcel:AddCol("BLOQUEIO","TMP->BLOQUEIO","Bloqueio","")
oPExcel:GetCol("BLOQUEIO"):SetTamCol(20)

oPExcel:AddCol("USUARIO","Capital(TMP->(FWLeUserlg('B1_USERLGA',1)))","Usuário","")
oPExcel:GetCol("USUARIO"):SetTamCol(30)

oPExcel:AddColX3("B1_UREV")
oPExcel:AddColX3("B1_GRUPO")
oPExcel:AddColX3("BM_DESC")
oPExcel:AddColX3("B1_XXSGRP")
oPExcel:AddColX3("ZI_DESC")
oPExcel:AddColX3("B1_CONTA")
oPExcel:AddColX3("CT1_DESC01")

If Substr(cUltPrc,1,1) == "S"
    oPExcel:AddCol("ULTPRC","U_GPrdSc1(TMP->B1_COD,'',0)","Último preço estimado","")
EndIf

// Adiciona a planilha 1
oRExcel:AddPlan(oPExcel)

// Cria arquivo Excel
oRExcel:Create()

(cAlias)->(dbCloseArea())

Return Nil


Static Function ParCom19(cProg,cTitulo,aRet,aParam)
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cProg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cProg      ,.T.         ,.T.))
	lRet	:= .T.
	cB1Blq	:= mv_par01
    cUltPrc := mv_par02
Endif
Return lRet

