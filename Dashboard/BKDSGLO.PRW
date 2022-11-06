#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSGLO
BK - Atualização da tabela GLOSAS do banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/

User Function BKDSGLO
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0
Local cEmpresa  := ""
Local cNomeEmp  := ""

Local cTabSZR   := ""
Local cTabCNR   := ""
Local cTabSF2   := ""
Local cTabSC5   := ""
Local cTabCXN   := ""
Local cTabCND   := ""
Local cTabCTT   := ""
Local cTabCN9   := ""
Local cTabCNF   := ""
Local cTabCNA   := ""

u_MsgLog("BKDSGLO","Inicio: Glosas")

cTabSZR := "SZR010"

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabCNR := "CNR"+cEmpresa+"0"
	cTabSF2 := "SF2"+cEmpresa+"0"
	cTabSC5 := "SC5"+cEmpresa+"0"
	cTabCXN := "CXN"+cEmpresa+"0"
	cTabCND := "CND"+cEmpresa+"0"
	cTabCTT := "CTT"+cEmpresa+"0"
	cTabCN9 := "CN9"+cEmpresa+"0"
	cTabCNF := "CNF"+cEmpresa+"0"
	cTabCNA := "CNA"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += "SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF
	cQuery += "  SUBSTRING(ISNULL(CND_CONTRA, ISNULL(C5_ESPECI1,'000000001')),1,9) AS CONTRATO, " + CRLF
	cQuery += "  ISNULL(CTT_DESC01,'BK CONSULTORIA') AS DESCRICAO, " + CRLF
	cQuery += "  ISNULL(C5_XXCOMPM,SUBSTRING(F2_EMISSAO,5,2)+'/'+SUBSTRING(F2_EMISSAO,1,4)) AS COMPET, " + CRLF
	cQuery += "  SUBSTRING(C5_XXCOMPM,4,4)+SUBSTRING(C5_XXCOMPM,1,2) AS COMPETAM, " + CRLF
	cQuery += "  CONVERT(DATE,SUBSTRING(C5_XXCOMPM,4,4)+SUBSTRING(C5_XXCOMPM,1,2)+'01',112) AS COMPETD, " + CRLF

	// Chave
	//cQuery += "  '"+cEmpresa+"' + "+CRLF
	//cQuery += "     SUBSTRING(ISNULL(CND_CONTRA, ISNULL(C5_ESPECI1,'000000001')),1,9) +  " + CRLF
	//cQuery += "     ISNULL(C5_XXCOMPM,SUBSTRING(F2_EMISSAO,1,6)) AS CHAVE, " + CRLF

	// Chave
	cQuery += "  '"+cEmpresa+"' + "+CRLF
	cQuery += "     SUBSTRING(ISNULL(CND_CONTRA, ISNULL(C5_ESPECI1,'000000001')),1,9) +  " + CRLF
	cQuery += "     ISNULL(SUBSTRING(C5_XXCOMPM,4,4)+SUBSTRING(C5_XXCOMPM,1,2),SUBSTRING(F2_EMISSAO,1,6)) AS CHAVE, " + CRLF


	cQuery += "  C5_NUM, " + CRLF
	cQuery += "  C5_MDNUMED, " + CRLF
	cQuery += "  C5_MDPLANI, " + CRLF
	cQuery += "  F2_SERIE, " + CRLF
	cQuery += "  F2_DOC, " + CRLF
	cQuery += "  CONVERT(DATE,F2_EMISSAO,112) AS F2_EMISSAO, " + CRLF
	cQuery += "  CND_USUAR, " + CRLF
	cQuery += "  (" + CRLF
	cQuery += "    CASE WHEN CND_NUMERO = '' THEN 'NOVA' ELSE 'ANTIGA' END" + CRLF
	cQuery += "  ) AS FORMAMED, " + CRLF
	cQuery += "  CNA_XXMUN  AS CNA_XXMUN," + CRLF
	cQuery += "    CNR_TIPO," + CRLF
  	cQuery += "  (" + CRLF
    cQuery += "    CASE WHEN CNR_TIPO = '1' THEN 'MULTA' ELSE 'BONIFICAÇÃO' END" + CRLF
  	cQuery += "  ) AS CNRTIPO, " + CRLF
  	cQuery += "  CNR_VALOR," + CRLF
  	cQuery += "  CNR_XTPJUS," + CRLF
  	cQuery += "  ZR_DESCR," + CRLF
  	cQuery += "  CNR_DESCRI" + CRLF

	If nE == 1
		cQuery += "  INTO PowerBk.dbo.GLOSAS " + CRLF
	EndIf
	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabSF2+" SF2" + CRLF

	cQuery += " LEFT JOIN "+cTabSC5+" SC5" + CRLF
	cQuery += "     ON (C5_NOTA = F2_DOC " + CRLF
	cQuery += "         AND C5_SERIE = F2_SERIE " + CRLF
	cQuery += "         AND C5_FILIAL = F2_FILIAL " + CRLF
	cQuery += "         AND SC5.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCND+" CND" + CRLF
	cQuery += "     ON (CND_NUMMED = C5_MDNUMED " + CRLF
	cQuery += "         AND CND_FILIAL = F2_FILIAL " + CRLF
	cQuery += "         AND CND.D_E_L_E_T_ = '' " + CRLF
	cQuery += "         AND CND.R_E_C_N_O_ = (" + CRLF
	cQuery += "         SELECT " + CRLF
	cQuery += "             MIN(R_E_C_N_O_) " + CRLF
	cQuery += "         FROM " + CRLF
	cQuery += "            "+cTabCND+" CND1 " + CRLF
	cQuery += "         WHERE " + CRLF
	cQuery += "             CND1.CND_NUMMED = C5_MDNUMED " + CRLF
	cQuery += "             AND CND1.CND_FILIAL = '01' " + CRLF
	cQuery += "             AND CND1.D_E_L_E_T_ = ''" + CRLF
	cQuery += "         )" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCXN+" CXN" + CRLF
	cQuery += "     ON (CXN_CONTRA = C5_MDCONTR " + CRLF
	cQuery += "         AND CXN_NUMMED = C5_MDNUMED " + CRLF
	cQuery += "         AND CXN_NUMPLA = C5_MDPLANI " + CRLF
	cQuery += "         AND CXN_REVISA = CND_REVISA " + CRLF
	cQuery += "         AND CXN.CXN_CHECK = 'T' " + CRLF
	cQuery += "         AND CXN_FILIAL = F2_FILIAL " + CRLF
	cQuery += "         AND CXN.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCNF+" CNF" + CRLF
	cQuery += " 	ON (CND_CONTRA = CNF_CONTRA" +CRLF
	cQuery += " 	    AND C5_XXCOMPM = CNF_COMPET AND ISNULL(CXN_NUMPLA,CND_NUMERO) = CNF_NUMPLA" +CRLF
	cQuery += " 	    AND ISNULL(CXN_REVISA, CND_REVISA) = CNF_REVISA" +CRLF
	cQuery += " 	    AND CNF_PARCEL = ISNULL(CXN_PARCEL,CND_PARCEL)" + CRLF
	cQuery += " 	 	AND CNF_FILIAL = F2_FILIAL" + CRLF
	cQuery += " 	 	AND CNF.D_E_L_E_T_='')" + CRLF

	cQuery += " LEFT JOIN "+cTabCNA+" CNA" + CRLF
	cQuery += " 	ON (CNA_CONTRA = CNF_CONTRA" + CRLF
	cQuery += " 	    AND CNA_CRONOG = CNF_NUMERO" + CRLF
	cQuery += " 	    AND CNA_REVISA = CNF_REVISA" + CRLF
	cQuery += " 	    AND CNA_NUMERO = CNF_NUMPLA" +CRLF
	cQuery += " 		AND CNA_FILIAL = CNF_FILIAL" +CRLF
	cQuery += " 		AND CNA.D_E_L_E_T_=''"+CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON (ISNULL(CND_CONTRA, C5_ESPECI1) = CTT_CUSTO " + CRLF
	cQuery += " 		AND CTT_FILIAL = '"+xFilial("CTT")+"'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " INNER JOIN "+cTabCNR+" CNR" + CRLF
	cQuery += "     ON (C5_MDNUMED = CNR.CNR_NUMMED " + CRLF
	cQuery += "         AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))" + CRLF
	cQuery += "         AND CNR_FILIAL = F2_FILIAL " + CRLF
	cQuery += "         AND CNR.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabSZR+" SZR" + CRLF
	cQuery += "     ON ZR_TIPO = CNR_XTPJUS" + CRLF
	cQuery += "     AND SZR.D_E_L_E_T_ = ''" + CRLF

	cQuery += "WHERE " + CRLF
	cQuery += "     SF2.D_E_L_E_T_ = '' " + CRLF

Next

cQuery += " ORDER BY" + CRLF
cQuery += "      EMPRESA,F2_SERIE,F2_DOC" + CRLF

u_LogMemo("BKDSGLO.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.GLOSAS', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.GLOSAS "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro1, cPerg)
	EndIf
EndIf

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro2, cPerg)
	EndIf
EndIf

u_LogMemo("BKDSGLO.SQL",cErro1+cQueryD+cErro2+cQuery)
u_MsgLog("BKDSGLO","Final: Glosas")

Return
