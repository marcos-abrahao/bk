#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSGCO
BK - Atualização da tabela GASTOSCONSORCIOS do banco de dados PowerBk
GASTOS CONSORCIOS PARA RATEIO DE CUSTOS COM SÓCIOS
@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/

User Function BKDSGCO
Local cQuery	:= ""
Local cQueryD	:= ""
//Local cQueryF	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpDsp()
Local nE 		:= 1
Local cEmpresa  := ""
Local cNomeEmp  := ""

Local cTabSD1	:= ""
Local cTabSB1	:= ""
Local cTabSE2	:= ""
Local cTabSA2	:= ""
Local cTabSF1	:= ""
Local cTabCTT	:= ""
Local cTabSE5	:= ""
Local cTabCT1	:= ""
//Local cTabSZ2   := "SZ2010"
//Local cCusBK	:= U_MVXCUSBK()
//Local cDescExm  := Posicione("SB1",1,xFilial("SB1")+U_MVXCEXMP(),"B1_DESC")
//Local cDescDCH 	:= Posicione("SB1",1,xFilial("SB1")+U_MVXCDCH(),"B1_DESC")
//Local cDescCBK	:= Posicione("SB1",1,xFilial("SB1")+cCusBK,"B1_DESC")

cQuery := "WITH DESPESAS AS ("+CRLF

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabSD1 := "SD1"+cEmpresa+"0"
	cTabSB1 := "SB1"+cEmpresa+"0"
	cTabSE2 := "SE2"+cEmpresa+"0"
	cTabSA2 := "SA2"+cEmpresa+"0"
	cTabSF1 := "SF1"+cEmpresa+"0"
	cTabCT1 := "CT1"+cEmpresa+"0"
	cTabCTT := "CTT"+cEmpresa+"0"
	cTabSE5 := "SE5"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF
	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '302000508' ELSE SUBSTRING(D1_CC,1,9) END) AS CONTRATO,"+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '305000554' ELSE SUBSTRING(D1_CC,1,9) END) AS CONTRATO,"+CRLF	
	ElseIf cEmpresa == '16'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '386000609' ELSE SUBSTRING(D1_CC,1,9) END) AS CONTRATO,"+CRLF	
	ElseIf cEmpresa == '18'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '303000623' ELSE SUBSTRING(D1_CC,1,9) END) AS CONTRATO,"+CRLF	
	Else
		cQuery += "  SUBSTRING(D1_CC,1,9) AS CONTRATO, " + CRLF
	EndIf
	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
 	cQuery += "  SUBSTRING(E2_VENCREA,5,2)+'/'+SUBSTRING(E2_VENCREA,1,4) AS COMPET,"+CRLF
 	cQuery += "  SUBSTRING(E2_VENCREA,1,6) AS COMPETAM,"+CRLF
 	cQuery += "  CONVERT(DATE,SUBSTRING(E2_VENCREA,1,6)+'01',112) AS COMPETD,"+CRLF

	// Chave
	cQuery += "  '"+cEmpresa+"' + "+CRLF
	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '302000508' ELSE SUBSTRING(D1_CC,1,9) END) + "+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '305000554' ELSE SUBSTRING(D1_CC,1,9) END) + "+CRLF	
	ElseIf cEmpresa == '16'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '386000609' ELSE SUBSTRING(D1_CC,1,9) END) + "+CRLF	
	ElseIf cEmpresa == '18'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '303000623' ELSE SUBSTRING(D1_CC,1,9) END) + "+CRLF	
	Else
		cQuery += "  SUBSTRING(D1_CC,1,9) + " + CRLF
	EndIf
	cQuery += "     SUBSTRING(E2_VENCREA,1,6)  AS CHAVE, " + CRLF
	cQuery += "     'SD1' AS ORIGEM, " + CRLF

 	cQuery += "  D1_FILIAL,"+CRLF
 	cQuery += "  D1_SERIE,"+CRLF
 	cQuery += "  D1_DOC,"+CRLF
 	cQuery += "  D1_FORNECE,"+CRLF
 	cQuery += "  D1_LOJA,"+CRLF
 	cQuery += "  A2_NOME,"+CRLF
 	cQuery += "  D1_ITEM,"+CRLF
 	cQuery += "  D1_COD,"+CRLF
	cQuery += "  CONVERT(VARCHAR(600),CONVERT(Binary(600),D1_XXHIST)) D1_XXHIST,"+CRLF
 	cQuery += "  B1_DESC,"+CRLF
 	cQuery += "  B1_GRUPO,"+CRLF
 	cQuery += "  F1_VALBRUT,"+CRLF
 	cQuery += "  F1_XXUSER,"+CRLF
	cQuery += "  (SELECT TOP 1 USUARIOS.NOME FROM PowerBk.dbo.USUARIOS USUARIOS WHERE F1_XXUSER = USUARIOS.CODIGO) AS F1RESPON,"+CRLF
 	cQuery += "  F1_XXULIB,"+CRLF
	cQuery += "  (SELECT TOP 1 USUARIOS.NOME FROM PowerBk.dbo.USUARIOS USUARIOS WHERE F1_XXULIB = USUARIOS.CODIGO) AS F1APROV,"+CRLF
 	cQuery += "  E2_PARCELA,"+CRLF
 	cQuery += "  E2_VALOR,"+CRLF
 	cQuery += "  E2_DESCONT,"+CRLF
 	cQuery += "  E2_MULTA,"+CRLF
 	cQuery += "  E2_JUROS,"+CRLF
 	cQuery += "  E2_ACRESC,"+CRLF
 	cQuery += "  E2_DECRESC,"+CRLF
 	cQuery += "  E2_VRETPIS,"+CRLF
 	cQuery += "  E2_VRETCOF,"+CRLF
 	cQuery += "  E2_VRETCSL,"+CRLF
 	cQuery += "  E2_VRETINS,"+CRLF
 	cQuery += "  E2_VRETIRF,"+CRLF
 	cQuery += "  E2_VRETISS,"+CRLF
 	cQuery += "  E2_VALOR+E2_VRETPIS+E2_VRETCOF+E2_VRETCSL+E2_VRETINS+E2_VRETIRF+E2_VRETISS AS E2VALTIT,"+CRLF
 	cQuery += "  (D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC)  AS D1TOTAL,"+CRLF
 	cQuery += "  CASE WHEN E2_ACRESC > 0 THEN E2_ACRESC  ELSE E2_MULTA+E2_JUROS END - "+CRLF
 	cQuery += "  	CASE WHEN E2_DECRESC > 0 THEN E2_DECRESC ELSE E2_DESCONT END AS E2ACDEC"+CRLF

	cQuery += "FROM " + CRLF
	cQuery += " "+cTabSD1+" SD1" + CRLF

	cQuery += " LEFT JOIN "+cTabSA2+" SA2" + CRLF
	cQuery += "     ON (A2_COD = D1_FORNECE " + CRLF
	cQuery += "         AND A2_LOJA = D1_LOJA " + CRLF
	cQuery += "         AND A2_FILIAL = '"+xFilial("SA2")+"' " + CRLF
	cQuery += "         AND SA2.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " INNER JOIN "+cTabSB1+" SB1" + CRLF
	cQuery += "     ON (B1_COD = D1_COD " + CRLF
	cQuery += "         AND B1_FILIAL = '"+xFilial("SB1")+"' "  + CRLF
	cQuery += "         AND SB1.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

 	cQuery += " INNER JOIN "+cTabSE2+" SE2" + CRLF
	cQuery += "     ON (E2_TIPO = 'NF' " + CRLF
	cQuery += "         AND E2_PREFIXO = D1_SERIE" + CRLF
	cQuery += "         AND E2_NUM = D1_DOC" + CRLF
	cQuery += "         AND E2_FORNECE = D1_FORNECE" + CRLF
	cQuery += "         AND E2_LOJA = D1_LOJA" + CRLF
	cQuery += "         AND E2_FILIAL = '"+xFilial("SE2")+"' " + CRLF
	cQuery += "         AND SE2.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

 	cQuery += " INNER JOIN "+cTabSF1+" SF1" + CRLF
	cQuery += "     ON (F1_SERIE = D1_SERIE" + CRLF
	cQuery += "         AND F1_DOC = D1_DOC" + CRLF
	cQuery += "         AND F1_FORNECE = D1_FORNECE" + CRLF
	cQuery += "         AND F1_LOJA = D1_LOJA" + CRLF
	cQuery += "         AND F1_FILIAL = D1_FILIAL " + CRLF
	cQuery += "         AND SF1.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON ( CTT_CUSTO = " + CRLF

	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '302000508' ELSE D1_CC END)"+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '305000554' ELSE D1_CC END)"+CRLF	
	ElseIf cEmpresa == '16'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '386000609' ELSE D1_CC END)"+CRLF	
	ElseIf cEmpresa == '18'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '303000623' ELSE D1_CC END)"+CRLF	
	Else
		cQuery += "  D1_CC " + CRLF
	EndIf

	cQuery += " 		AND CTT_FILIAL = '01'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "WHERE SD1.D1_FILIAL = '01' " + CRLF
	cQuery += "      AND SD1.D_E_L_E_T_ = '' " + CRLF

	cQuery += "      AND (A2_NOME LIKE 'TOTVS%' OR A2_NOME LIKE 'SAMA M%' OR A2_NOME LIKE 'DOCUSIGN%' OR A2_NOME LIKE 'INOVACOMM%' OR A2_NOME LIKE 'RKA%' OR A2_NOME LIKE 'AHGORA%')"
//	cQuery += "      AND D1_FORNECE IN ('000102','004386','501334' ,'500256','501586'  ,'000124')" + CRLF
//	cQuery += "         --               TOTVS  , SAMA   , DOCUSIGN, PSEVEN , INOVACOMM, RKA" + CRLF


Next

cQuery += ")"+CRLF
cQuery += " SELECT *,"+CRLF

// Gravar a chave das Previsões
cQuery += "	(SELECT TOP 1 ZGCHAVE FROM "+CRLF
cQuery += "		(SELECT MAX(COMPETAM+ZG_SEQ) AS ZGCHAVE"+CRLF
cQuery += "		FROM PowerBk.dbo.PREVDESP1 "+CRLF
cQuery += "		WHERE PREVDESP1.EMPRESA = DESPESAS.EMPRESA"+CRLF
cQuery += "		    AND PREVDESP1.CONTRATO = DESPESAS.CONTRATO"+CRLF
cQuery += "		    AND PREVDESP1.COMPETAM <= DESPESAS.COMPETAM"+CRLF
cQuery += "		GROUP BY PREVDESP1.CONTRATO,PREVDESP1.ZG_DATA"+CRLF
cQuery += "		) AS X"+CRLF
cQuery += "		ORDER BY ZGCHAVE DESC) AS CHAVEZG,"+CRLF

cQuery += "	   (E2ACDEC  / F1_VALBRUT * D1TOTAL)   AS E2ACDECIT,"+CRLF
cQuery += "	   (E2VALTIT / F1_VALBRUT * D1TOTAL)   AS D1TOTIT,"+CRLF
cQuery += "       (E2ACDEC  / F1_VALBRUT * D1TOTAL) + (E2VALTIT / F1_VALBRUT * D1TOTAL) AS DESPESA,"+CRLF

// Produtos das previsões

cQuery += "    (CASE "+CRLF
cQuery += "    	WHEN D1_COD IN "+U_FBkVars(U_MVXVTPRD())+" THEN '12' "+CRLF
cQuery += "    	WHEN D1_COD IN "+U_FBkVars(U_MVXVRVAP())+" THEN '14' "+CRLF
cQuery += "    	WHEN B1_GRUPO = '0008' THEN 'WUNIFORME' "+CRLF
cQuery += "    	WHEN B1_GRUPO = '0009' THEN 'WMATERIAL DE SEG' "+CRLF
cQuery += "    	WHEN B1_GRUPO = '0010' THEN 'WINSUMOS' "+CRLF
cQuery += "     ELSE 'W'+D1_COD "+CRLF
cQuery += "     END"+CRLF
cQuery += "    ) AS PREVPROD,"+CRLF

cQuery += "    (CASE "+CRLF
cQuery += "    	WHEN D1_COD IN "+U_FBkVars(U_MVXVTPRD())+" THEN 'VT' "+CRLF
cQuery += "    	WHEN D1_COD IN "+U_FBkVars(U_MVXVRVAP())+" THEN 'VR/VA' "+CRLF
cQuery += "    	WHEN B1_GRUPO = '0008' THEN 'UNIFORME' "+CRLF
cQuery += "    	WHEN B1_GRUPO = '0009' THEN 'MATERIAL DE SEGURANCA' "+CRLF
cQuery += "    	WHEN B1_GRUPO = '0010' THEN 'INSUMOS' "+CRLF
cQuery += "     ELSE B1_DESC "+CRLF
cQuery += "     END"+CRLF
cQuery += "    ) AS PREVDESC"+CRLF

cQuery += "	INTO PowerBk.dbo.GASTOSCONSORCIOS"+CRLF
cQuery += "	FROM DESPESAS"+CRLF
cQuery += " ORDER BY" + CRLF
cQuery += "      EMPRESA,CONTRATO,COMPETAM,D1_SERIE,D1_DOC" + CRLF

u_LogMemo("BKDSGCO.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  


//  Apaga a tabela GASTOSCONSORCIOS da base PowerBk
cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.GASTOSCONSORCIOS', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.GASTOSCONSORCIOS "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1  += "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	u_MsgLog(cPerg,cErro1,"E")
EndIf

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2  += "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	u_MsgLog(cPerg,cErro2,"E")
EndIf

u_LogMemo("BKDSGCO.SQL",cErro1+cQueryD+cErro2+cQuery)
//u_MsgLog("BKDSGCO","Final: Gastos Gerais")

Return
