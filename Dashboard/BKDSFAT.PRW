#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSFAT
BK - Atualiza��o da tabela FATURAMENTO do banco de dados PowerBk

@Return
@author Marcos Bispo Abrah�o
@since 27/09/2022
@version P12.1.25
/*/

User Function BKDSFAT

Local cProg 	:= "BKDSFAT"
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
Local cTabSE5   := ""
Local cTabSE1   := ""
Local cTabSD2   := ""

//u_MsgLog("BKDSFAT","Inicio: Faturamento")

cTabSZR := "SZR010"

cQuery := "WITH FATUR AS ("
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
	cTabSE5 := "SE5"+cEmpresa+"0"
	cTabSE1 := "SE1"+cEmpresa+"0"
	cTabSD2 := "SD2"+cEmpresa+"0"

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
	cQuery += "  ISNULL(SUBSTRING(C5_XXCOMPM,4,4)+SUBSTRING(C5_XXCOMPM,1,2),SUBSTRING(F2_EMISSAO,1,6)) AS COMPETAM, " + CRLF
	cQuery += "  CONVERT(DATE,ISNULL(SUBSTRING(C5_XXCOMPM,4,4)+SUBSTRING(C5_XXCOMPM,1,2),SUBSTRING(F2_EMISSAO,1,6))+'01',112) AS COMPETD, " + CRLF

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
	cQuery += "  F2_VALFAT, " + CRLF
	// Fernando 01/08/22 - O ISS Retido e Apurado precisam entrar dentro da conta de faturamento l�quido e a reten��o e conta vinculada precisam sair
	//cQuery += "  (F2_VALFAT - F2_VALIRRF - F2_VALINSS - F2_VALPIS - F2_VALCOFI - F2_VALCSLL - (CASE WHEN F2_RECISS = '1' THEN F2_VALISS ELSE 0 END) - F2_VLCPM - F2_XXVRETC - F2_XXVCVIN) AS F2VALLIQ1, " + CRLF
	//cQuery += "  (F2_VALFAT - F2_VALIRRF - F2_VALINSS - F2_VALPIS - F2_VALCOFI - F2_VALCSLL - F2_VALISS - F2_VLCPM) AS F2VALLIQ1, " + CRLF

	cQuery += "  F2_VALISS, " + CRLF
	cQuery += "  F2_VLCPM, " + CRLF

	If cEmpresa = '02'
		cQuery += "  16.98 AS PERIMP," + CRLF
		cQuery += "  (F2_VALFAT * 16.98 / 100) AS VALIMP," + CRLF
	    cQuery += "  (F2_VALFAT - (F2_VALFAT * 16.98 / 100) - F2_VALISS - F2_VLCPM) AS F2VALLIQ1, " + CRLF
	Else
		cQuery += "  9.5 AS PERIMP," + CRLF
		cQuery += "  (F2_VALFAT * 9.5 / 100) AS VALIMP," + CRLF
	    cQuery += "  (F2_VALFAT - (F2_VALFAT * 9.5 / 100) - F2_VALISS - F2_VLCPM) AS F2VALLIQ1, " + CRLF
	EndIf

	cQuery += "  CND_USUAR, " + CRLF
	cQuery += "  CND_XX5DIA, " + CRLF
	cQuery += "  CND_XX5JUS, " + CRLF
	cQuery += "  (" + CRLF
	cQuery += "    CASE WHEN CND_NUMERO = '' THEN 'NOVA' ELSE 'ANTIGA' END" + CRLF
	cQuery += "  ) AS FORMAMED, " + CRLF
	cQuery += "  CNA_XXMUN  AS CNA_XXMUN,"+ CRLF
	cQuery += "  CNA_XXTIPO AS CNA_XXTIPO,"+ CRLF		
	//cQuery += "  ISNULL(CXN_VLPREV, CND_VLPREV) AS CXN_VLPREV, " + CRLF
	cQuery += "  CASE WHEN ISNULL(CXN_VLPREV, CND_VLPREV) = CNF_VLPREV THEN CNF_VLPREV ELSE 0 END AS CXN_VLPREV,"+ CRLF
	//cQuery += "  ISNULL(CXN_VLBONI, CND_VLBONI) AS CXN_VLBONI, " + CRLF
	//cQuery += "  ISNULL(CXN_VLMULT, CND_VLMULT) AS CXN_VLMULT, " + CRLF

	// Movimento Financeiro (multas e descontos)
	cQuery += "   (SELECT SUM(E5_VALOR) FROM "+cTabSE5+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " + CRLF
	cQuery += "   	AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5DESC," + CRLF
	cQuery += "   (SELECT SUM(E5_VALOR) FROM "+cTabSE5+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " + CRLF
	cQuery += "   	AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5MULTA," + CRLF
	cQuery += "   (SELECT TOP 1 E1_XXISSBI FROM "+cTabSE1+" SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC AND E1_TIPO = 'NF'"+ CRLF
	cQuery += "   	  AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"   + xFilial("SE1")+"') AS E1_XXISSBI, " + CRLF

	cQuery += "   (SELECT SUM(CNR_VALOR)"+ CRLF
	cQuery += "        FROM "+cTabCNR+" CNR " + CRLF
	cQuery += "        WHERE "+ CRLF
	cQuery += "          C5_MDNUMED = CNR.CNR_NUMMED "+ CRLF
	cQuery += "          AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))"+ CRLF
	cQuery += "          AND CNR_FILIAL = '01'"+ CRLF
	cQuery += "          AND CNR.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += "          AND CNR_TIPO = '2' ) AS CNRVLBONI,"+ CRLF

	cQuery += "   (SELECT SUM(CNR_VALOR)"+ CRLF
	cQuery += "        FROM "+cTabCNR+" CNR " + CRLF
	cQuery += "        WHERE "+ CRLF
	cQuery += "          C5_MDNUMED = CNR.CNR_NUMMED "+ CRLF
	cQuery += "          AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))"+ CRLF
	cQuery += "          AND CNR_FILIAL = '01'"+ CRLF
	cQuery += "          AND CNR.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += "          AND CNR_TIPO = '1' ) AS CNRVLMULT,"+ CRLF

	cQuery += "  STUFF (" + CRLF
	cQuery += "    (" + CRLF
	cQuery += "      SELECT " + CRLF
	cQuery += "        ';' + RTRIM(CNR_XTPJUS + '-' + ZR_DESCR) " + CRLF
	cQuery += "      FROM " + CRLF
	cQuery += "        "+cTabCNR+" CNR " + CRLF
	cQuery += "        INNER JOIN "+cTabSZR+" SZR ON ZR_TIPO = CNR_XTPJUS " + CRLF
	cQuery += "      WHERE " + CRLF
	cQuery += "        C5_MDNUMED = CNR.CNR_NUMMED " + CRLF
	cQuery += "        AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))" + CRLF
	cQuery += "        AND CNR_FILIAL = CND_FILIAL" + CRLF
	cQuery += "        AND CNR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "        AND CNR_TIPO = '1' " + CRLF
	cQuery += "      ORDER BY " + CRLF
	cQuery += "        ';' + RTRIM(CNR_XTPJUS + '-' + ZR_DESCR) FOR XML PATH (''), " + CRLF
	cQuery += "        TYPE" + CRLF
	cQuery += "    ).value('.', 'varchar(100)'), " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    ''" + CRLF
	cQuery += "  ) AS CNRTPMUL, " + CRLF
	cQuery += "  STUFF (" + CRLF
	cQuery += "    (" + CRLF
	cQuery += "      SELECT " + CRLF
	cQuery += "        ';' + RTRIM(CNR_DESCRI) " + CRLF
	cQuery += "      FROM " + CRLF
	cQuery += "        "+cTabCNR+" CNR " + CRLF
	cQuery += "      WHERE " + CRLF
	cQuery += "        C5_MDNUMED = CNR.CNR_NUMMED " + CRLF
	cQuery += "        AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))" + CRLF
	cQuery += "        AND CNR_FILIAL = CND_FILIAL" + CRLF
	cQuery += "        AND CNR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "        AND CNR_TIPO = '1' " + CRLF
	cQuery += "      ORDER BY " + CRLF
	cQuery += "        ';' + RTRIM(CNR_DESCRI) FOR XML PATH (''), " + CRLF
	cQuery += "        TYPE" + CRLF
	cQuery += "    ).value('.', 'varchar(100)'), " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    ''" + CRLF
	cQuery += "  ) AS CNRDESCMUL, " + CRLF
	cQuery += "  STUFF (" + CRLF
	cQuery += "    (" + CRLF
	cQuery += "      SELECT " + CRLF
	cQuery += "        ';' + RTRIM(CNR_XTPJUS + '-' + ZR_DESCR) " + CRLF
	cQuery += "      FROM " + CRLF
	cQuery += "        "+cTabCNR+" CNR " + CRLF
	cQuery += "        INNER JOIN "+cTabSZR+" SZR ON ZR_TIPO = CNR_XTPJUS " + CRLF
	cQuery += "      WHERE " + CRLF
	cQuery += "        C5_MDNUMED = CNR.CNR_NUMMED " + CRLF
	cQuery += "        AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))" + CRLF
	cQuery += "        AND CNR_FILIAL = CND_FILIAL" + CRLF
	cQuery += "        AND CNR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "        AND CNR_TIPO = '2' " + CRLF
	cQuery += "      ORDER BY " + CRLF
	cQuery += "        ';' + RTRIM(CNR_XTPJUS + '-' + ZR_DESCR) FOR XML PATH (''), " + CRLF
	cQuery += "        TYPE" + CRLF
	cQuery += "    ).value('.', 'varchar(100)'), " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    ''" + CRLF
	cQuery += "  ) AS CNRTPBON, " + CRLF
	cQuery += "  STUFF (" + CRLF
	cQuery += "    (" + CRLF
	cQuery += "      SELECT " + CRLF
	cQuery += "        ';' + RTRIM(CNR_DESCRI) " + CRLF
	cQuery += "      FROM " + CRLF
	cQuery += "        "+cTabCNR+" CNR " + CRLF
	cQuery += "      WHERE " + CRLF
	cQuery += "        C5_MDNUMED = CNR.CNR_NUMMED " + CRLF
	cQuery += "        AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))" + CRLF
	cQuery += "        AND CNR_FILIAL = CND_FILIAL" + CRLF
	cQuery += "        AND CNR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "        AND CNR_TIPO = '2' " + CRLF
	cQuery += "      ORDER BY " + CRLF
	cQuery += "        ';' + RTRIM(CNR_DESCRI) FOR XML PATH (''), " + CRLF
	cQuery += "        TYPE" + CRLF
	cQuery += "    ).value('.', 'varchar(100)'), " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    ''" + CRLF
	cQuery += "  ) AS CNRDESCBON, "+CRLF

	// Gravar a chave das Previs�es
	cQuery += "	(SELECT TOP 1 ZGCHAVE FROM "+CRLF
	cQuery += "		(SELECT MAX(COMPETAM+ZG_SEQ) AS ZGCHAVE"+CRLF
	cQuery += "		FROM PowerBk.dbo.PREVDESP1 "+CRLF
	cQuery += "		WHERE PREVDESP1.EMPRESA = '"+cEmpresa+"'"+CRLF
	cQuery += "		    AND PREVDESP1.CONTRATO = SUBSTRING(ISNULL(CND_CONTRA, ISNULL(C5_ESPECI1,'000000001')),1,9)"+CRLF
	cQuery += "		    AND PREVDESP1.COMPETAM <= SUBSTRING(C5_XXCOMPM,4,4)+SUBSTRING(C5_XXCOMPM,1,2)"+CRLF
	cQuery += "		GROUP BY PREVDESP1.CONTRATO,PREVDESP1.ZG_DATA"+CRLF
	cQuery += "		) AS X"+CRLF
	cQuery += "		ORDER BY ZGCHAVE DESC) AS CHAVEZG"+CRLF
	// --
	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabSF2+" SF2 " + CRLF

	// -->  27/06/2023 Marcos
	//cQuery += " LEFT JOIN "+cTabSC5+" SC5" + CRLF
	//cQuery += "     ON (C5_NOTA = F2_DOC " + CRLF
	//cQuery += "         AND C5_SERIE = F2_SERIE " + CRLF
	//cQuery += "         AND C5_FILIAL = F2_FILIAL " + CRLF
	//cQuery += "         AND SC5.D_E_L_E_T_ = ''" + CRLF
	//cQuery += " ) " + CRLF

	cQuery += " LEFT JOIN "+cTabSD2+" SD2" + CRLF
	cQuery += "     ON (D2_SERIE = F2_SERIE " + CRLF
	cQuery += "         AND D2_DOC = F2_DOC " + CRLF
	cQuery += "         AND D2_FILIAL = F2_FILIAL " + CRLF
    cQuery += "         AND SD2.D_E_L_E_T_ = '' " + CRLF
    cQuery += "         AND SD2.R_E_C_N_O_ = (" + CRLF
    cQuery += "              SELECT " + CRLF
    cQuery += "                 MIN(R_E_C_N_O_) " + CRLF
    cQuery += "              FROM " + CRLF
    cQuery += "                "+cTabSD2+" SD21 " + CRLF
    cQuery += "              WHERE " + CRLF
    cQuery += "                 SD21.D2_SERIE = F2_SERIE " + CRLF
    cQuery += "              AND SD21.D2_DOC = F2_DOC " + CRLF
	cQuery += "         	 AND SD21.D2_FILIAL = F2_FILIAL " + CRLF
    cQuery += "              AND SD21.D_E_L_E_T_ = '' ) " + CRLF
    cQuery += "         ) " + CRLF

	cQuery += " LEFT JOIN "+cTabSC5+" SC5" + CRLF
	cQuery += "     ON (C5_NUM = D2_PEDIDO " + CRLF
	cQuery += "         AND C5_FILIAL = D2_FILIAL " + CRLF
	cQuery += "         AND SC5.D_E_L_E_T_ = ''" + CRLF
	cQuery += " ) " + CRLF
	// <--  27/06/2023 Marcos

	cQuery += " LEFT JOIN "+cTabCND+" CND" + CRLF
	cQuery += "     ON (CND_NUMMED = C5_MDNUMED " + CRLF
	//cQuery += "         AND CND_REVISA = CND_REVGER " + CRLF
	cQuery += "         AND CND_FILIAL = '01' " + CRLF
	cQuery += "         AND CND.D_E_L_E_T_ = '' " + CRLF
	cQuery += "         AND CND.R_E_C_N_O_ = (" + CRLF
	cQuery += "         SELECT " + CRLF
	cQuery += "            MIN(R_E_C_N_O_) " + CRLF
	cQuery += "         FROM " + CRLF
	cQuery += "            "+cTabCND+" CND1 " + CRLF
	cQuery += "         WHERE " + CRLF
	cQuery += "            CND1.CND_NUMMED = C5_MDNUMED " + CRLF
	cQuery += "            AND CND1.CND_FILIAL = '01' " + CRLF
	cQuery += "            AND CND1.D_E_L_E_T_ = ''" + CRLF
	cQuery += "    )" + CRLF
	
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
	cQuery += " 	ON (CND_CONTRA = CNF_CONTRA AND C5_XXCOMPM = CNF_COMPET" + CRLF
	cQuery += " 	    AND ISNULL(CXN_NUMPLA,CND_NUMERO) = CNF_NUMPLA" + CRLF
	cQuery += " 	    AND ISNULL(CXN_REVISA,CND_REVISA) = CNF_REVISA" + CRLF
	cQuery += " 	    AND CNF_PARCEL = ISNULL(CXN_PARCEL,CND_PARCEL)" + CRLF
	cQuery += " 	 	AND CNF_FILIAL = F2_FILIAL AND CNF.D_E_L_E_T_=''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCNA+" CNA" + CRLF
	cQuery += " 	ON (CNA_CONTRA = CNF_CONTRA" + CRLF
	cQuery += " 	 	AND CNA_CRONOG = CNF_NUMERO" + CRLF
	cQuery += " 	 	AND CNA_REVISA = CNF_REVISA" + CRLF
	cQuery += " 	 	AND CNA_NUMERO = CNF_NUMPLA" +CRLF
	cQuery += " 		AND CNA_FILIAL = CNF_FILIAL AND CNA.D_E_L_E_T_=''"+CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON (ISNULL(CND_CONTRA, C5_ESPECI1) = CTT_CUSTO " + CRLF
	cQuery += " 		AND CTT_FILIAL = '"+xFilial("CTT")+"'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "WHERE " + CRLF
	cQuery += "  SF2.D_E_L_E_T_ = '' " + CRLF
	cQuery += "  AND SF2.F2_FILIAL = '"+xFilial("SF2")+"'" + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += "SELECT " + CRLF
	cQuery += "  DISTINCT " + CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF

	cQuery += "  SUBSTRING(CNF_CONTRA,1,9) AS CONTRATO, " + CRLF
	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
	cQuery += "  CNF_COMPET AS COMPET, " + CRLF
	cQuery += "  SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2) AS COMPETAM, " + CRLF
	cQuery += "  CONVERT(DATE,SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2)+'01',112) AS COMPETD, " + CRLF

	// Chave
	cQuery += "  '"+cEmpresa+"' + "+CRLF
	cQuery += "     SUBSTRING(CNF_CONTRA,1,9) +  " + CRLF
	cQuery += "     SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2) AS CHAVE, " + CRLF

	cQuery += "  ' ' 		AS C5_NUM, " + CRLF
	cQuery += "  ' ' 		AS C5_MDNUMED, " + CRLF
	cQuery += "  CNF_NUMPLA AS C5_MDPLANI, " + CRLF
	cQuery += "  ' ' 		AS F2_SERIE, " + CRLF
	cQuery += "  'PREVISTO' AS F2_DOC, " + CRLF
	cQuery += "  CONVERT(DATE,CONVERT(VARCHAR,''),112) AS F2_EMISSAO, " + CRLF
	cQuery += "  0 			AS F2_VALFAT, " + CRLF

	cQuery += "  0 			AS F2_VALISS, " + CRLF
	cQuery += "  0 			AS F2_VLCPM, " + CRLF

	If cEmpresa = '02'
		cQuery += "  16.98 	AS PERIMP," + CRLF
		cQuery += "  0 		AS VALIMP," + CRLF
	    cQuery += "  0 		AS F2VALLIQ1, " + CRLF
	Else
		cQuery += "  9.5 	AS PERIMP," + CRLF
		cQuery += "  0 		AS VALIMP," + CRLF
	    cQuery += "  0 		AS F2VALLIQ1, " + CRLF
	EndIf

	cQuery += "  ' ' 		AS CND_USUAR, " + CRLF
	cQuery += "  'P'		AS CND_XX5DIA, " + CRLF
	cQuery += "  ' '		AS CND_XX5JUS, " + CRLF

	cQuery += "  ' ' 		AS FORMAMED, " + CRLF
	cQuery += "  CNA_XXMUN  AS CNA_XXMUN,"+ CRLF	
	cQuery += "  CNA_XXTIPO AS CNA_XXTIPO,"+ CRLF	
	cQuery += "  CNF_VLPREV AS CXN_VLPREV, " + CRLF
	cQuery += "  0 			AS XX_E5DESC, " + CRLF
	cQuery += "  0 			AS XX_E5MULTA, " + CRLF
	cQuery += "  0 			AS E1_XXISSBI, " + CRLF
	cQuery += "  0 			AS CNRVLBONI, " + CRLF
	cQuery += "  0 			AS CNRVLMULT, " + CRLF
	cQuery += "  ' ' 		AS CNRTPMUL, " + CRLF
	cQuery += "  ' ' 		AS CNRDESCMUL, " + CRLF
	cQuery += "  ' ' 		AS CNRTPBON, " + CRLF
	cQuery += "  ' ' 		AS CNRDESCBON, " + CRLF

	// Gravar a chave das Previs�es
	cQuery += "	(SELECT TOP 1 ZGCHAVE FROM "+CRLF
	cQuery += "		(SELECT MAX(COMPETAM+ZG_SEQ) AS ZGCHAVE"+CRLF
	cQuery += "		FROM PowerBk.dbo.PREVDESP1 "+CRLF
	cQuery += "		WHERE PREVDESP1.EMPRESA = '"+cEmpresa+"'"+CRLF
	cQuery += "		    AND PREVDESP1.CONTRATO = SUBSTRING(CNF_CONTRA,1,9)"+CRLF
	cQuery += "		    AND PREVDESP1.COMPETAM <= SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2)"+CRLF
	cQuery += "		GROUP BY PREVDESP1.CONTRATO,PREVDESP1.ZG_DATA"+CRLF
	cQuery += "		) AS X"+CRLF
	cQuery += "		ORDER BY ZGCHAVE DESC) AS CHAVEZG"+CRLF

	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabCNF+" CNF " + CRLF

	cQuery += " INNER JOIN "+cTabCN9+" CN9" + CRLF
	cQuery += "     ON CN9_NUMERO = CNF_CONTRA " + CRLF
	cQuery += "     AND CN9_REVISA = CNF_REVISA " + CRLF
	cQuery += "     AND CN9_REVATU = ' ' " + CRLF
	cQuery += "     AND CN9_FILIAL = '01' " + CRLF
	cQuery += "     AND CN9.D_E_L_E_T_ = ' ' " + CRLF

	cQuery += " LEFT JOIN "+cTabCNA+" CNA" + CRLF
	cQuery += " 	ON (CNA_CONTRA = CNF_CONTRA" + CRLF
	cQuery += " 	AND CNA_CRONOG = CNF_NUMERO" + CRLF
	cQuery += " 	AND CNA_REVISA = CNF_REVISA" + CRLF
	cQuery += " 	AND CNA_NUMERO = CNF_NUMPLA" +CRLF
	cQuery += " 		AND CNA_FILIAL = CNF_FILIAL AND CNA.D_E_L_E_T_='')"+CRLF

	cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON CTT_CUSTO = CNF_CONTRA" + CRLF
	cQuery += " 	AND CTT_FILIAL = '"+xFilial("CTT")+"'" + CRLF
	cQuery += "     AND CTT.D_E_L_E_T_ = ' ' " + CRLF

	cQuery += "WHERE " + CRLF
	cQuery += "     CNF_SALDO = CNF_VLPREV " + CRLF
	cQuery += "     AND CNF_FILIAL = '01' " + CRLF
	cQuery += "     AND CNF.D_E_L_E_T_ = ' ' " + CRLF
Next

cQuery += ")"  + CRLF
cQuery += " SELECT *," + CRLF
//cQuery += " F2VALLIQ1 - ISNULL(XX_E5DESC,0) + ISNULL(XX_E5MULTA,0) - E1_XXISSBI AS F2VALLIQ" + CRLF

cQuery += " CASE WHEN ( (CONTRATO = '305000554' AND COMPETAM < '202501') OR CONTRATO = '386000609') " + CRLF
cQuery += "      THEN (F2VALLIQ1 - ISNULL(XX_E5DESC,0) + ISNULL(XX_E5MULTA,0) - E1_XXISSBI) * 2 " + CRLF
cQuery += "      ELSE (F2VALLIQ1 - ISNULL(XX_E5DESC,0) + ISNULL(XX_E5MULTA,0) - E1_XXISSBI) END AS F2VALLIQ," + CRLF
cQuery += " CASE WHEN ( (CONTRATO = '305000554' AND COMPETAM < '202501') OR CONTRATO = '386000609') " + CRLF
cQuery += "      THEN (F2_VALFAT * 2) " + CRLF
cQuery += "      ELSE (F2_VALFAT) END AS VALFAT" + CRLF

cQuery += " INTO PowerBk.dbo.FATURAMENTO " + CRLF
cQuery += " FROM FATUR " + CRLF
cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,CONTRATO,COMPETAM,F2_DOC" + CRLF

If !TCIsConnected() 
  MsgAlert( "Sem conex�o com o banco de dados", cPerg )
  Return( Nil )
Endif

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.FATURAMENTO', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.FATURAMENTO "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1 := TcSqlError()
EndIf

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2 := TcSqlError()
EndIf

u_QryResult(cProg,cQueryD+cQuery,cErro1+cErro2)

// Incluir na tabela FATURAMENTO as NDC geradas por medi��o - 15/08/2024

BKDSNDC()

Return



// Incluir na tabela FATURAMENTO as NDC geradas por medi��o - 15/08/2024
Static Function BKDSNDC
Local cProg     := "BKDSNDC"
Local cQuery	:= ""
Local nErro 	:= 0
Local cErro3	:= ""
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0
Local cEmpresa  := ""
Local cNomeEmp  := ""

Local cTabSE1   := ""
Local cTabSZR   := ""
Local cTabCNR   := ""
Local cTabCXN   := ""
Local cTabCND   := ""
Local cTabCTT   := ""
Local cTabCN9   := ""
Local cTabCNF   := ""
Local cTabCNA   := ""
Local cTabSE5   := ""

cTabSZR := "SZR010"

cQuery := "WITH NDC AS ("
For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabSE1 := "SE1"+cEmpresa+"0"
	cTabCNR := "CNR"+cEmpresa+"0"
	cTabCXN := "CXN"+cEmpresa+"0"
	cTabCND := "CND"+cEmpresa+"0"
	cTabCTT := "CTT"+cEmpresa+"0"
	cTabCN9 := "CN9"+cEmpresa+"0"
	cTabCNF := "CNF"+cEmpresa+"0"
	cTabCNA := "CNA"+cEmpresa+"0"
	cTabSE5 := "SE5"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += "SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF

	cQuery += "  SUBSTRING(E1_XXCUSTO,1,9) AS CONTRATO, " + CRLF
	cQuery += "  ISNULL(CTT_DESC01,'BK CONSULTORIA') AS DESCRICAO, " + CRLF
	cQuery += "  SUBSTRING(E1_XXCOMPE,5,2)+'/'+SUBSTRING(E1_XXCOMPE,1,4) AS COMPET, " + CRLF
	cQuery += "  E1_XXCOMPE AS COMPETAM, " + CRLF
	cQuery += "  CONVERT(DATE,E1_XXCOMPE+'01',112) AS COMPETD, " + CRLF

	// Chave
	cQuery += "  '01' +  SUBSTRING(E1_XXCUSTO,1,9) +  E1_XXCOMPE AS CHAVE, " + CRLF

	cQuery += "  '' AS C5_NUM, " + CRLF
	cQuery += "  E1_MEDNUME AS C5_MDNUMED, " + CRLF
	cQuery += "  E1_MDPLANI AS C5_MDPLANI, " + CRLF
	cQuery += "  E1_PREFIXO AS F2_SERIE, " + CRLF
	cQuery += "  E1_NUM     AS F2_DOC, " + CRLF
	cQuery += "  CONVERT(DATE,E1_EMISSAO,112) AS F2_EMISSAO, " + CRLF
	cQuery += "  E1_VALOR   AS F2_VALFAT, " + CRLF
	cQuery += "  0          AS F2_VALISS, " + CRLF
	cQuery += "  0          AS F2_VLCPM, " + CRLF

	If cEmpresa = '02'
		cQuery += "  16.98 AS PERIMP," + CRLF
		cQuery += "  (E1_VALOR * 16.98 / 100) AS VALIMP," + CRLF
	    cQuery += "  (E1_VALOR - (E1_VALOR * 16.98 / 100)) AS F2VALLIQ1, " + CRLF
	Else
		cQuery += "  9.5 AS PERIMP," + CRLF
		cQuery += "  (E1_VALOR * 9.5 / 100) AS VALIMP," + CRLF
	    cQuery += "  (E1_VALOR - (E1_VALOR * 9.5 / 100)) AS F2VALLIQ1, " + CRLF
	EndIf

	cQuery += "  CND_USUAR, " + CRLF
	cQuery += "  CND_XX5DIA, " + CRLF
	cQuery += "  CND_XX5JUS, " + CRLF
	cQuery += "  (" + CRLF
	cQuery += "    CASE WHEN CND_NUMERO = '' THEN 'NOVA' ELSE 'ANTIGA' END" + CRLF
	cQuery += "  ) AS FORMAMED, " + CRLF
	cQuery += "  CNA_XXMUN,"+ CRLF
	cQuery += "  CNA_XXTIPO,"+ CRLF		
	cQuery += "  CASE WHEN ISNULL(CXN_VLPREV, CND_VLPREV) = CNF_VLPREV THEN CNF_VLPREV ELSE 0 END AS CXN_VLPREV,"+ CRLF

	// Movimento Financeiro (multas e descontos)
	cQuery += "   (SELECT SUM(E5_VALOR) FROM "+cTabSE5+" SE5 WHERE E5_PREFIXO = E1_PREFIXO AND E5_NUMERO = E1_NUM  AND E5_TIPO = 'BOL' AND  E5_CLIFOR = E1_CLIENTE AND E5_LOJA = E1_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " + CRLF
	cQuery += "   	AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5DESC," + CRLF
	cQuery += "   (SELECT SUM(E5_VALOR) FROM "+cTabSE5+" SE5 WHERE E5_PREFIXO = E1_PREFIXO AND E5_NUMERO = E1_NUM  AND E5_TIPO = 'BOL' AND  E5_CLIFOR = E1_CLIENTE AND E5_LOJA = E1_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " + CRLF
	cQuery += "   	AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5MULTA," + CRLF
	cQuery += "   E1_XXISSBI, " + CRLF

	cQuery += "   (SELECT SUM(CNR_VALOR)"+ CRLF
	cQuery += "        FROM "+cTabCNR+" CNR " + CRLF
	cQuery += "        WHERE "+ CRLF
	cQuery += "          E1_MEDNUME = CNR.CNR_NUMMED "+ CRLF
	cQuery += "          AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))"+ CRLF
	cQuery += "          AND CNR_FILIAL = '01'"+ CRLF
	cQuery += "          AND CNR.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += "          AND CNR_TIPO = '2' ) AS CNRVLBONI,"+ CRLF

	cQuery += "   (SELECT SUM(CNR_VALOR)"+ CRLF
	cQuery += "        FROM "+cTabCNR+" CNR " + CRLF
	cQuery += "        WHERE "+ CRLF
	cQuery += "          E1_MEDNUME = CNR.CNR_NUMMED "+ CRLF
	cQuery += "          AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))"+ CRLF
	cQuery += "          AND CNR_FILIAL = '01'"+ CRLF
	cQuery += "          AND CNR.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += "          AND CNR_TIPO = '1' ) AS CNRVLMULT,"+ CRLF

	cQuery += "  STUFF (" + CRLF
	cQuery += "    (" + CRLF
	cQuery += "      SELECT " + CRLF
	cQuery += "        ';' + RTRIM(CNR_XTPJUS + '-' + ZR_DESCR) " + CRLF
	cQuery += "      FROM " + CRLF
	cQuery += "        "+cTabCNR+" CNR " + CRLF
	cQuery += "        INNER JOIN "+cTabSZR+" SZR ON ZR_TIPO = CNR_XTPJUS " + CRLF
	cQuery += "      WHERE " + CRLF
	cQuery += "        E1_MEDNUME = CNR.CNR_NUMMED " + CRLF
	cQuery += "        AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))" + CRLF
	cQuery += "        AND CNR_FILIAL = CND_FILIAL" + CRLF
	cQuery += "        AND CNR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "        AND CNR_TIPO = '1' " + CRLF
	cQuery += "      ORDER BY " + CRLF
	cQuery += "        ';' + RTRIM(CNR_XTPJUS + '-' + ZR_DESCR) FOR XML PATH (''), " + CRLF
	cQuery += "        TYPE" + CRLF
	cQuery += "    ).value('.', 'varchar(100)'), " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    ''" + CRLF
	cQuery += "  ) AS CNRTPMUL, " + CRLF
	cQuery += "  STUFF (" + CRLF
	cQuery += "    (" + CRLF
	cQuery += "      SELECT " + CRLF
	cQuery += "        ';' + RTRIM(CNR_DESCRI) " + CRLF
	cQuery += "      FROM " + CRLF
	cQuery += "        "+cTabCNR+" CNR " + CRLF
	cQuery += "      WHERE " + CRLF
	cQuery += "        E1_MEDNUME = CNR.CNR_NUMMED " + CRLF
	cQuery += "        AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))" + CRLF
	cQuery += "        AND CNR_FILIAL = CND_FILIAL" + CRLF
	cQuery += "        AND CNR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "        AND CNR_TIPO = '1' " + CRLF
	cQuery += "      ORDER BY " + CRLF
	cQuery += "        ';' + RTRIM(CNR_DESCRI) FOR XML PATH (''), " + CRLF
	cQuery += "        TYPE" + CRLF
	cQuery += "    ).value('.', 'varchar(100)'), " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    ''" + CRLF
	cQuery += "  ) AS CNRDESCMUL, " + CRLF
	cQuery += "  STUFF (" + CRLF
	cQuery += "    (" + CRLF
	cQuery += "      SELECT " + CRLF
	cQuery += "        ';' + RTRIM(CNR_XTPJUS + '-' + ZR_DESCR) " + CRLF
	cQuery += "      FROM " + CRLF
	cQuery += "        "+cTabCNR+" CNR " + CRLF
	cQuery += "        INNER JOIN "+cTabSZR+" SZR ON ZR_TIPO = CNR_XTPJUS " + CRLF
	cQuery += "      WHERE " + CRLF
	cQuery += "        E1_MEDNUME = CNR.CNR_NUMMED " + CRLF
	cQuery += "        AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))" + CRLF
	cQuery += "        AND CNR_FILIAL = CND_FILIAL" + CRLF
	cQuery += "        AND CNR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "        AND CNR_TIPO = '2' " + CRLF
	cQuery += "      ORDER BY " + CRLF
	cQuery += "        ';' + RTRIM(CNR_XTPJUS + '-' + ZR_DESCR) FOR XML PATH (''), " + CRLF
	cQuery += "        TYPE" + CRLF
	cQuery += "    ).value('.', 'varchar(100)'), " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    ''" + CRLF
	cQuery += "  ) AS CNRTPBON, " + CRLF
	cQuery += "  STUFF (" + CRLF
	cQuery += "    (" + CRLF
	cQuery += "      SELECT " + CRLF
	cQuery += "        ';' + RTRIM(CNR_DESCRI) " + CRLF
	cQuery += "      FROM " + CRLF
	cQuery += "        "+cTabCNR+" CNR " + CRLF
	cQuery += "      WHERE " + CRLF
	cQuery += "        E1_MEDNUME = CNR.CNR_NUMMED " + CRLF
	cQuery += "        AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))" + CRLF
	cQuery += "        AND CNR_FILIAL = CND_FILIAL" + CRLF
	cQuery += "        AND CNR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "        AND CNR_TIPO = '2' " + CRLF
	cQuery += "      ORDER BY " + CRLF
	cQuery += "        ';' + RTRIM(CNR_DESCRI) FOR XML PATH (''), " + CRLF
	cQuery += "        TYPE" + CRLF
	cQuery += "    ).value('.', 'varchar(100)'), " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    ''" + CRLF
	cQuery += "  ) AS CNRDESCBON, "+CRLF

	// Gravar a chave das Previs�es
	cQuery += "	(SELECT TOP 1 ZGCHAVE FROM "+CRLF
	cQuery += "		(SELECT MAX(COMPETAM+ZG_SEQ) AS ZGCHAVE"+CRLF
	cQuery += "		FROM PowerBk.dbo.PREVDESP1 "+CRLF
	cQuery += "		WHERE PREVDESP1.EMPRESA = '"+cEmpresa+"'"+CRLF
	cQuery += "		    AND PREVDESP1.CONTRATO = SUBSTRING(E1_XXCUSTO,1,9)"+CRLF
	cQuery += "		    AND PREVDESP1.COMPETAM <= E1_XXCOMPE"+CRLF
	cQuery += "		GROUP BY PREVDESP1.CONTRATO,PREVDESP1.ZG_DATA"+CRLF
	cQuery += "		) AS X"+CRLF
	cQuery += "		ORDER BY ZGCHAVE DESC) AS CHAVEZG"+CRLF
	// --
	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabSE1+" SE1 " + CRLF

	cQuery += " LEFT JOIN "+cTabCND+" CND" + CRLF
	cQuery += "     ON (CND_NUMMED = E1_MEDNUME " + CRLF
	//cQuery += "         AND CND_REVISA = CND_REVGER " + CRLF
	cQuery += "         AND CND_FILIAL = '01' " + CRLF
	cQuery += "         AND CND.D_E_L_E_T_ = '' " + CRLF
	cQuery += "         AND CND.R_E_C_N_O_ = (" + CRLF
	cQuery += "         SELECT " + CRLF
	cQuery += "            MIN(R_E_C_N_O_) " + CRLF
	cQuery += "         FROM " + CRLF
	cQuery += "            "+cTabCND+" CND1 " + CRLF
	cQuery += "         WHERE " + CRLF
	cQuery += "            CND1.CND_NUMMED = E1_MEDNUME " + CRLF
	cQuery += "            AND CND1.CND_FILIAL = '01' " + CRLF
	cQuery += "            AND CND1.D_E_L_E_T_ = ''" + CRLF
	cQuery += "    )" + CRLF
	
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCXN+" CXN" + CRLF
	cQuery += "     ON (CXN_CONTRA = E1_MDCONTR " + CRLF
	cQuery += "         AND CXN_NUMMED = E1_MEDNUME " + CRLF
	cQuery += "         AND CXN_NUMPLA = E1_MDPLANI " + CRLF
	cQuery += "         AND CXN_REVISA = CND_REVISA " + CRLF
	cQuery += "         AND CXN.CXN_CHECK = 'T' " + CRLF
	cQuery += "         AND CXN_FILIAL = E1_FILIAL " + CRLF
	cQuery += "         AND CXN.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCNF+" CNF" + CRLF
	cQuery += " 	ON (CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET" + CRLF
	cQuery += " 	    AND ISNULL(CXN_NUMPLA,CND_NUMERO) = CNF_NUMPLA" + CRLF
	cQuery += " 	    AND ISNULL(CXN_REVISA,CND_REVISA) = CNF_REVISA" + CRLF
	cQuery += " 	    AND CNF_PARCEL = ISNULL(CXN_PARCEL,CND_PARCEL)" + CRLF
	cQuery += " 	 	AND CNF_FILIAL = E1_FILIAL AND CNF.D_E_L_E_T_=''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCNA+" CNA" + CRLF
	cQuery += " 	ON (CNA_CONTRA = CNF_CONTRA" + CRLF
	cQuery += " 	 	AND CNA_CRONOG = CNF_NUMERO" + CRLF
	cQuery += " 	 	AND CNA_REVISA = CNF_REVISA" + CRLF
	cQuery += " 	 	AND CNA_NUMERO = CNF_NUMPLA" +CRLF
	cQuery += " 		AND CNA_FILIAL = CNF_FILIAL AND CNA.D_E_L_E_T_=''"+CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON (E1_XXCUSTO = CTT_CUSTO " + CRLF
	cQuery += " 		AND CTT_FILIAL = '"+xFilial("CTT")+"'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "WHERE " + CRLF
	cQuery += "  SE1.D_E_L_E_T_ = '' " + CRLF
	cQuery += "   AND SE1.E1_TIPO = 'BOL' " + CRLF
	cQuery += "   AND SE1.E1_PREFIXO = 'MED' " + CRLF
	cQuery += "   AND SE1.E1_FILIAL = '"+xFilial("SE1")+"'" + CRLF
Next

cQuery += "), NDC1 AS ("  + CRLF
cQuery += " SELECT *," + CRLF
//cQuery += " F2VALLIQ1 - ISNULL(XX_E5DESC,0) + ISNULL(XX_E5MULTA,0) - E1_XXISSBI AS F2VALLIQ" + CRLF

cQuery += " CASE WHEN ( (CONTRATO = '305000554' AND COMPETAM < '202501') OR CONTRATO = '386000609') " + CRLF
cQuery += "      THEN (F2VALLIQ1 - ISNULL(XX_E5DESC,0) + ISNULL(XX_E5MULTA,0) - E1_XXISSBI) * 2 " + CRLF
cQuery += "      ELSE (F2VALLIQ1 - ISNULL(XX_E5DESC,0) + ISNULL(XX_E5MULTA,0) - E1_XXISSBI) END AS F2VALLIQ," + CRLF
cQuery += " CASE WHEN ( (CONTRATO = '305000554' AND COMPETAM < '202501') OR CONTRATO = '386000609') " + CRLF
cQuery += "      THEN (F2_VALFAT * 2) " + CRLF
cQuery += "      ELSE (F2_VALFAT) END AS VALFAT" + CRLF

cQuery += " FROM NDC )" + CRLF
//cQuery += " ORDER BY" + CRLF
//cQuery += "    EMPRESA,CONTRATO,COMPETAM,F2_DOC" + CRLF

cQuery += " INSERT INTO PowerBk.dbo.FATURAMENTO " + CRLF
cQuery += " (" + CRLF
cQuery += "  EMPRESA," + CRLF
cQuery += "  NOMEEMP," + CRLF
cQuery += "  DATAPRC," + CRLF
cQuery += "  CONTRATO, " + CRLF
cQuery += "  DESCRICAO, " + CRLF
cQuery += "  COMPET, " + CRLF
cQuery += "  COMPETAM, " + CRLF
cQuery += "  COMPETD, " + CRLF
cQuery += "  CHAVE, " + CRLF
cQuery += "  C5_NUM, " + CRLF
cQuery += "  C5_MDNUMED, " + CRLF
cQuery += "  C5_MDPLANI, " + CRLF
cQuery += "  F2_SERIE, " + CRLF
cQuery += "  F2_DOC, " + CRLF
cQuery += "  F2_EMISSAO, " + CRLF
cQuery += "  F2_VALFAT, " + CRLF
cQuery += "  F2_VALISS, " + CRLF
cQuery += "  F2_VLCPM, " + CRLF
cQuery += "  PERIMP," + CRLF
cQuery += "  VALIMP," + CRLF
cQuery += "  F2VALLIQ1, " + CRLF
cQuery += "  CND_USUAR, " + CRLF
cQuery += "  CND_XX5DIA, " + CRLF
cQuery += "  CND_XX5JUS, " + CRLF
cQuery += "  FORMAMED, " + CRLF
cQuery += "  CNA_XXMUN," + CRLF
cQuery += "  CNA_XXTIPO," + CRLF
cQuery += "  CXN_VLPREV," + CRLF
cQuery += "  XX_E5DESC," + CRLF
cQuery += "  XX_E5MULTA," + CRLF
cQuery += "  E1_XXISSBI, " + CRLF
cQuery += "  CNRVLBONI," + CRLF
cQuery += "  CNRVLMULT," + CRLF
cQuery += "  CNRTPMUL, " + CRLF
cQuery += "  CNRDESCMUL, " + CRLF
cQuery += "  CNRTPBON, " + CRLF
cQuery += "  CNRDESCBON, " + CRLF
cQuery += "  CHAVEZG," + CRLF
cQuery += "  F2VALLIQ," + CRLF
cQuery += "  VALFAT" + CRLF
cQuery += " )" + CRLF
cQuery += " (SELECT * FROM NDC1)" + CRLF

If !TCIsConnected() 
  MsgAlert( "Sem conex�o com o banco de dados", cPerg )
  Return( Nil )
Endif

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro3 := TcSqlError()
EndIf

u_QryResult(cProg,cQuery,cErro3)

Return
