#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSPLA
BK - Atualização da tabela PLANILHAS do banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/

// 
User Function BKDSPLA
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0
Local cProg		:= "BKDSPLA"
Local cJCNACNB:= FWJoinFilial("CNA", "CNB")
Local cJCNBSB1:= FWJoinFilial("CNB", "SB1")

Local cTabCN9   := ""
Local cTabCNA   := ""
Local cTabCNB   := ""
Local cTabSA1   := ""
Local cTabSB1   := ""

//u_MsgLog("BKDSPLA","Inicio: Planilhas")
 
cQuery := "WITH PLANS AS ( " + CRLF

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabCN9 := "CN9"+cEmpresa+"0"
	cTabCNA := "CNA"+cEmpresa+"0"
	cTabCNB := "CNB"+cEmpresa+"0"
	cTabSA1 := "SA1"+cEmpresa+"0"
	cTabSB1 := "SB1"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT"+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC, " + CRLF
	cQuery += "  SUBSTRING(CNB_CONTRA,1,9) AS CONTRATO,"+CRLF
	cQuery += "  CNB_REVISA,"+CRLF
	cQuery += "  CONVERT(DATE,CN9_DTREV,112) AS CN9_DTREV, "+CRLF
	cQuery += "  CNB_NUMERO,"+CRLF
	cQuery += "  CNB_ITEM,"+CRLF
	cQuery += "  CNB_PRODUT,"+CRLF
	cQuery += "  CNB_TS,"+CRLF
	cQuery += "  CNB_QUANT,"+CRLF
	cQuery += "  CNB_SLDMED,"+CRLF
	cQuery += "  CNB_VLUNIT,"+CRLF
	cQuery += "  CNB_VLTOT,"+CRLF
	cQuery += "  CNA_XXMOT,"+CRLF
	cQuery += "  CNA_NUMERO,"+CRLF
	cQuery += "  CNA_CLIENT,"+CRLF
	cQuery += "  CNA_LOJACL,"+CRLF
	cQuery += "  CNA_XXCMUN,"+CRLF
	cQuery += "  CNA_XXUF,"+CRLF
	cQuery += "  CNA_XXMUN,"+CRLF
	cQuery += "  CNA_XXTPNF,"+CRLF
	cQuery += "  CNA_XXRETC,"+CRLF
	cQuery += "  CNA_XXNAT,"+CRLF
	cQuery += "  CNA_CRONOG,"+CRLF
	cQuery += "  B1_DESC,"+CRLF
	cQuery += "  B1_CODISS,"+CRLF
	cQuery += "  B1_ALIQISS,"+CRLF
	cQuery += "  B1_TS,"+CRLF
	cQuery += "  A1_NOME,"+CRLF
	cQuery += "  A1_CGC,"+CRLF
	cQuery += "  A1_PESSOA,"+CRLF
	cQuery += "  A1_END,"+CRLF
	cQuery += "  A1_BAIRRO,"+CRLF
	cQuery += "  A1_EST,"+CRLF
	cQuery += "  A1_COD_MUN,"+CRLF
	cQuery += "  A1_MUN,"+CRLF
	cQuery += "  A1_CEP,"+CRLF
	cQuery += "  A1_DDD,"+CRLF
	cQuery += "  A1_TEL"+CRLF


	cQuery += " FROM "+cTabCNB+ " CNB " + CRLF

	cQuery += " LEFT JOIN "+cTabCNA+ " CNA " + CRLF
	cQuery += "      ON CNB_NUMERO = CNA_NUMERO AND CNB_CONTRA = CNA_CONTRA AND CNB_REVISA = CNA_REVISA " + CRLF
	cQuery += " 	 AND "+cJCNACNB+" AND CNA.D_E_L_E_T_=''" + CRLF

	cQuery += " LEFT JOIN "+cTabSB1+ " SB1 " + CRLF
	cQuery += "      ON CNB_PRODUT = B1_COD" + CRLF
	cQuery += " 	 AND "+cJCNBSB1+" AND SB1.D_E_L_E_T_=''" + CRLF

	cQuery += " LEFT JOIN "+cTabSA1+ " SA1 " + CRLF
	cQuery += "      ON CNA_CLIENT = A1_COD AND CNA_LOJACL = A1_LOJA" + CRLF
	cQuery += " 	 AND SA1.D_E_L_E_T_=''" + CRLF

	cQuery += " INNER JOIN "+cTabCN9+ " CN9 " + CRLF
	cQuery += "      ON CNB_CONTRA = CN9_NUMERO" + CRLF
	cQuery += "      AND CNB_REVISA = CN9_REVISA" + CRLF
	//cQuery += "      AND CN9_REVATU = ' '" + CRLF
	cQuery += " 	 AND CN9.D_E_L_E_T_=''" + CRLF

	cQuery += " WHERE CNB.D_E_L_E_T_=''" + CRLF
	
Next

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  *, " + CRLF
cQuery += "  (EMPRESA+CONTRATO+CNB_REVISA) AS CHAVE " + CRLF
cQuery += "  INTO PowerBk.dbo.PLANILHAS  " + CRLF
cQuery += "  FROM PLANS " + CRLF

cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,CONTRATO,CNB_REVISA,CNA_NUMERO" + CRLF

u_LogMemo("BKDSPLA.SQL",cQuery)

If !TCIsConnected()
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.PLANILHAS', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.PLANILHAS "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1 := TcSqlError()
EndIf

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2 := TcSqlError()
EndIf

u_QryResult(cProg,cQueryD+cQuery,cErro1+cErro2)

Return
