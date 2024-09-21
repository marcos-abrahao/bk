#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSGG
BK - Atualização da tabela GASTOSGERAIS do banco de dados PowerBk
GASTOS GERAIS
@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/

User Function BKDSGG
Local cQuery	:= ""
Local cQueryD	:= ""
//Local cQueryF	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpDsp()
Local nE 		:= 0
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
Local cTabSZ2   := "SZ2010"
Local cTabSBM	:= "SBM010" // Tabela de grupos de produtos compartilhada

Local cCusBK	:= U_MVXCUSBK()
Local cAssMed   := U_MVASSMED()
Local cDescExm  := Posicione("SB1",1,xFilial("SB1")+U_MVXCEXMP(),"B1_DESC")
Local cDescDCH 	:= Posicione("SB1",1,xFilial("SB1")+U_MVXCDCH(),"B1_DESC")
Local cDescCBK	:= Posicione("SB1",1,xFilial("SB1")+cCusBK,"B1_DESC")

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
 	//cQuery += "  SUBSTRING(E2_VENCREA,5,2)+'/'+SUBSTRING(E2_VENCREA,1,4) AS COMPET,"+CRLF
	cQuery += "  (CASE WHEN E2_PARCELA = '  ' THEN SUBSTRING(F1_XXCOMPD,5,2)+'/'+SUBSTRING(F1_XXCOMPD,1,4) ELSE SUBSTRING(E2_VENCREA,5,2)+'/'+SUBSTRING(E2_VENCREA,1,4) END AS COMPET,"+CRLF
 	//cQuery += "  SUBSTRING(E2_VENCREA,1,6) AS COMPETAM,"+CRLF
	cQuery += "  (CASE WHEN E2_PARCELA = '  ' THEN SUBSTRING(F1_XXCOMPD,1,6) ELSE SUBSTRING(E2_VENCREA,1,6) END AS COMPETAM,"+CRLF
 	//cQuery += "  CONVERT(DATE,SUBSTRING(E2_VENCREA,1,6)+'01',112) AS COMPETD,"+CRLF
	cQuery += "  (CASE WHEN E2_PARCELA = '  ' THEN CONVERT(DATE,SUBSTRING(F1_XXCOMPD,1,6)+'01',112) ELSE CONVERT(DATE,SUBSTRING(E2_VENCREA,1,6)+'01',112) END AS COMPETD,"+CRLF

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
	//cQuery += "     SUBSTRING(E2_VENCREA,1,6)  AS CHAVE, " + CRLF
	cQuery += "  (CASE WHEN E2_PARCELA = '  ' THEN SUBSTRING(F1_XXCOMPD,1,6) ELSE SUBSTRING(E2_VENCREA,1,6) END AS CHAVE,"+CRLF

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
 	cQuery += "  BM_DESC,"+CRLF
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

	cQuery += " LEFT JOIN "+cTabSBM+" SBM" + CRLF
	cQuery += "     ON (B1_GRUPO = BM_GRUPO " + CRLF
	cQuery += "         AND BM_FILIAL = '"+xFilial("SBM")+"' "  + CRLF
	cQuery += "         AND SBM.D_E_L_E_T_ = ''" + CRLF
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
	cQuery += "      AND (SUBSTRING(B1_CONTA,1,1) = '3'" + CRLF
	cQuery += "      	OR B1_CONTA IN ('"+cCusBK+"') " + CRLF
	cQuery += "      	OR SUBSTRING(B1_CONTA,1,5) IN ('12201','12105') " + CRLF
	cQuery += "      	OR SUBSTRING(B1_CONTA,1,3) IN ('124','126')) " + CRLF  // Ativo Imobilizado

      
	// Despesas médicas 12/03/24
	cQuery += "      AND D1_COD <> '"+cAssMed+"'"+CRLF

	/*
	IF cEmpresa == "01" // Despesas médicas 
		cQuery += "AND 1 = CASE WHEN D1_CC = '313000504' AND D1_FORNECE = '002918' THEN 0 ELSE 1 END"+CRLF
	ENDIF 
	IF cEmpresa == "14" // Despesas médicas
		cQuery += "      AND D1_FORNECE <> '000604'"+CRLF
	ENDIF 
	*/



	// Movimento Bancário
	cQuery += "UNION ALL "+CRLF

	cQuery += " SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF

	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '302000508' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END) AS CONTRATO, " + CRLF
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '305000554' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END) AS CONTRATO, " + CRLF
	ElseIf cEmpresa == '16'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '386000609' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END) AS CONTRATO, " + CRLF
	ElseIf cEmpresa == '18'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '303000623' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END) AS CONTRATO, " + CRLF
	Else
		cQuery += "  (CASE "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END) AS CONTRATO, " + CRLF
	EndIf

	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
 	cQuery += "  SUBSTRING(E5_VENCTO,5,2)+'/'+SUBSTRING(E5_VENCTO,1,4) AS COMPET,"+CRLF
 	cQuery += "  SUBSTRING(E5_VENCTO,1,6) AS COMPETAM,"+CRLF
 	cQuery += "  CONVERT(DATE,SUBSTRING(E5_VENCTO,1,6)+'01',112) AS COMPETD,"+CRLF

	// Chave
	cQuery += "  '"+cEmpresa+"' + "+CRLF

	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '302000508' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END) + " + CRLF
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '305000554' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END) + " + CRLF
	ElseIf cEmpresa == '16'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '386000609' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END) + " + CRLF
	ElseIf cEmpresa == '18'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '303000623' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END) + " + CRLF
	Else
		cQuery += "  (CASE "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END) + " + CRLF
	EndIf
	cQuery += "   SUBSTRING(E5_VENCTO,1,6) AS CHAVE, " + CRLF
	cQuery += "     'SE5' AS ORIGEM, " + CRLF

 	//cQuery += "  E5_VALOR * (CASE WHEN E5_RECPAG = 'R' THEN -1 ELSE 1 END) AS E5_VALOR,"+CRLF
 	//cQuery += "  E5_RECPAG,"+CRLF
 	//cQuery += "  UPPER(E5_HISTOR) AS E5_HISTOR,"+CRLF
 	//Query += "  'W'+SUBSTRING(CT1_DESC01,1,15) AS E5CODIGO "+CRLF

  	cQuery += "     E5_FILIAL  AS D1_FILIAL, " + CRLF
  	cQuery += "     E5_PREFIXO AS D1_SERIE, " + CRLF
  	cQuery += "     E5_NUMERO  AS D1_DOC, " + CRLF
  	cQuery += "     E5_CLIFOR  AS D1_FORNECE, " + CRLF
  	cQuery += "     E5_LOJA    AS D1_LOJA, " + CRLF
 	cQuery += "     A2_NOME,"+CRLF
  	cQuery += "     '0001'     AS D1_ITEM, " + CRLF
  	cQuery += "     SUBSTRING(CT1_DESC01,1,15) AS D1_COD, " + CRLF
	cQuery += "     E5_HISTOR  AS D1_XXHIST, " + CRLF
  	cQuery += "     CT1_DESC01 AS B1_DESC, " + CRLF
  	cQuery += "     ' '        AS B1_GRUPO, " + CRLF
  	cQuery += "     ' '        AS BM_DESC, " + CRLF
  	cQuery += "     E5_VALOR * (CASE WHEN E5_RECPAG = 'R' THEN -1 ELSE 1 END) AS F1_VALBRUT, " + CRLF
	cQuery += "     ' '        AS F1_XXUSER, " + CRLF
	cQuery += "     ' '        AS F1RESPON, " + CRLF
	cQuery += "     ' '        AS F1_XXULIB, " + CRLF
	cQuery += "     ' '        AS F1APROV, " + CRLF
  	cQuery += "     E5_PARCELA AS E2_PARCELA, " + CRLF
  	cQuery += "     E5_VALOR * (CASE WHEN E5_RECPAG = 'R' THEN -1 ELSE 1 END) AS E2_VALOR, " + CRLF
  	cQuery += "     E5_VLDESCO AS E2_DESCONT, " + CRLF
  	cQuery += "     E5_VLMULTA AS E2_MULTA, " + CRLF
  	cQuery += "     E5_VLJUROS AS E2_JUROS, " + CRLF
  	cQuery += "     E5_VLACRES AS E2_ACRESC, " + CRLF
  	cQuery += "     E5_VLDECRE AS E2_DECRESC, " + CRLF
  	cQuery += "     E5_VRETPIS AS E2_VRETPIS, " + CRLF
  	cQuery += "     E5_VRETCOF AS E2_VRETCOF, " + CRLF
  	cQuery += "     E5_VRETCSL AS E2_VRETCSL, " + CRLF
  	cQuery += "     E5_VRETINS AS E2_VRETINS, " + CRLF
  	cQuery += "     E5_VRETIRF AS E2_VRETIRF, " + CRLF
  	cQuery += "     E5_VRETISS AS E2_VRETISS, " + CRLF
  	cQuery += "     E5_VALOR * (CASE WHEN E5_RECPAG = 'R' THEN -1 ELSE 1 END) AS E2VALTIT, " + CRLF
  	cQuery += "     E5_VALOR * (CASE WHEN E5_RECPAG = 'R' THEN -1 ELSE 1 END) AS D1TOTAL, " + CRLF
  	cQuery += "     CASE WHEN E5_VLACRES > 0 THEN E5_VLACRES ELSE E5_VLMULTA+E5_VLJUROS END -  " + CRLF
  	cQuery += "     	CASE WHEN E5_VLDECRE > 0 THEN E5_VLDECRE ELSE E5_VLDESCO END AS E2ACDEC " + CRLF

	cQuery += "FROM " + CRLF
	cQuery += " "+cTabSE5+" SE5 " + CRLF

	cQuery += "LEFT JOIN "+cTabSA2+" SA2" + CRLF
	cQuery += "     ON (A2_COD = E5_CLIFOR " + CRLF
	cQuery += "         AND A2_LOJA = E5_LOJA " + CRLF
	cQuery += "         AND A2_FILIAL = '"+xFilial("SA2")+"' " + CRLF
	cQuery += "         AND SA2.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON ( CTT_CUSTO = "+ CRLF
	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '302000508' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END)  " + CRLF
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '305000554' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END)  " + CRLF
	ElseIf cEmpresa == '16'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '386000609' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END)  " + CRLF
	ElseIf cEmpresa == '18'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '303000623' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END)  " + CRLF
	Else
		cQuery += "  (CASE "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END)  " + CRLF
	EndIf
	cQuery += " 		AND CTT_FILIAL = '01'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "LEFT JOIN "+cTabCT1+" CT1" + CRLF
	cQuery += "     ON ( "+ CRLF
	cQuery += "        (CT1_CONTA = E5_DEBITO OR CT1_CONTA = E5_CREDITO)" + CRLF
	cQuery += " 	   AND CT1_FILIAL = '  '" + CRLF
	cQuery += "        AND CT1.D_E_L_E_T_=''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "WHERE SE5.E5_FILIAL = '01' " + CRLF
	cQuery += "      AND SE5.D_E_L_E_T_ = '' " + CRLF
	cQuery += "      AND (SUBSTRING(E5_DEBITO,1,1)='3' OR SUBSTRING(E5_CREDITO,1,1)='3' )" + CRLF
	cQuery += "      AND E5_SITUACA <> 'C' " + CRLF
	cQuery += "      AND (E5_CCC <> ' ' OR E5_CCD <> '  ') " + CRLF
	//If cEmpresa <> '14' .AND. cEmpresa <> '15'
		cQuery += "      AND (SUBSTRING(E5_CCC,1,3) <> '000' AND SUBSTRING(E5_CCD,1,3) <> '000') " + CRLF
	///EndIf

	// Despesas advindas da integração Rubi Microsiga
	// CLT

	cQuery += "UNION ALL "+CRLF

	cQuery += " SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF

	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '302000508' ELSE SUBSTRING(Z2_CC,1,9) END) AS CONTRATO,"+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '305000554' ELSE SUBSTRING(Z2_CC,1,9) END) AS CONTRATO,"+CRLF	
	ElseIf cEmpresa == '16'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '386000609' ELSE SUBSTRING(Z2_CC,1,9) END) AS CONTRATO,"+CRLF	
	ElseIf cEmpresa == '18'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '303000623' ELSE SUBSTRING(Z2_CC,1,9) END) AS CONTRATO,"+CRLF	
	Else
		cQuery += "  SUBSTRING(Z2_CC,1,9) AS CONTRATO, " + CRLF
	EndIf

	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
 	cQuery += "  SUBSTRING(Z2_DATAPGT,5,2)+'/'+SUBSTRING(Z2_DATAPGT,1,4) AS COMPET,"+CRLF
 	cQuery += "  SUBSTRING(Z2_DATAPGT,1,6) AS COMPETAM,"+CRLF
 	cQuery += "  CONVERT(DATE,SUBSTRING(Z2_DATAPGT,1,6)+'01',112) AS COMPETD,"+CRLF

	// Chave
	cQuery += "  ('"+cEmpresa+"' + "+CRLF
	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '302000508' ELSE SUBSTRING(Z2_CC,1,9) END) + "+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '305000554' ELSE SUBSTRING(Z2_CC,1,9) END) + "+CRLF	
	ElseIf cEmpresa == '16'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '386000609' ELSE SUBSTRING(Z2_CC,1,9) END) + "+CRLF	
	ElseIf cEmpresa == '18'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '303000623' ELSE SUBSTRING(Z2_CC,1,9) END) + "+CRLF	
	Else
		cQuery += "  SUBSTRING(Z2_CC,1,9) + " + CRLF
	EndIf
	cQuery += "   SUBSTRING(Z2_DATAPGT,1,6)) AS CHAVE, " + CRLF
	cQuery += "  'SZ2-CLT' AS ORIGEM, " + CRLF

	cQuery += "  Z2_FILIAL   AS D1_FILIAL,"+CRLF
	cQuery += "  Z2_E2PRF	 AS D1_SERIE,"+CRLF
	cQuery += "  Z2_E2NUM    AS D1_DOC,"+CRLF
	cQuery += "  Z2_E2FORN   AS D1_FORNECE,"+CRLF
	cQuery += "  Z2_E2LOJA   AS D1_LOJA,"+CRLF
 	cQuery += "  A2_NOME,"+CRLF
	cQuery += "  '0001'      AS D1_ITEM,"+CRLF

	// PRODUTO CLT
	cQuery += "  (CASE "+CRLF
	cQuery += "    	WHEN Z2_TIPO = 'VT' THEN '12' "+CRLF
	cQuery += "    	WHEN Z2_TIPO IN ('VR','VA') THEN '14' "+CRLF
	cQuery += "    	WHEN Z2_TIPO = 'EXM' THEN '"+U_MVXCEXMP()+"'"+CRLF
	cQuery += "    	WHEN Z2_TIPO IN ('DCH','SOL','HOS','REE','CXA') THEN '"+U_MVXCDCH()+"'"+CRLF
	cQuery += "     ELSE Z2_TIPO "+CRLF
	cQuery += "   END"+CRLF
	cQuery += "  ) AS D1_COD,"+CRLF

	cQuery += "  RTRIM(Z2_NOME)+': '+RTRIM(Z2_OBSTITU)  AS D1_XXHIST,"+CRLF

	cQuery += "  (CASE "+CRLF
	cQuery += "     WHEN Z2_TIPO = 'VT' THEN 'VT' "+CRLF
	cQuery += "    	WHEN Z2_TIPO IN ('VR','VA') THEN 'VR/VA' "+CRLF
	cQuery += "    	WHEN Z2_TIPO = 'EXM' THEN '"+cDescExm+"'"+CRLF
	cQuery += "    	WHEN Z2_TIPO IN ('DCH','SOL','HOS','REE','CXA') THEN '"+cDescDCH+"'"+CRLF
	cQuery += "     ELSE Z2_TIPO "+CRLF
	cQuery += "   END"+CRLF
	cQuery += "  ) AS B1_DESC,"+CRLF

	cQuery += "  ' '         AS B1_GRUPO, "+CRLF
  	cQuery += "  ' '         AS BM_DESC, " + CRLF
	cQuery += "  Z2_VALOR    AS F1_VALBRUT,"+CRLF
	cQuery += "  (SELECT TOP 1 USUARIOS.CODIGO FROM PowerBk.dbo.USUARIOS USUARIOS WHERE UPPER(Z2_USUARIO) = USUARIOS.NOME OR UPPER(Z2_USUARIO) = USUARIOS.USUARIO) AS F1_XXUSER, "+CRLF
	cQuery += "  UPPER(Z2_USUARIO)  AS F1_RESPON,"+CRLF
	cQuery += "  (SELECT TOP 1 USUARIOS.CODIGO FROM PowerBk.dbo.USUARIOS USUARIOS WHERE UPPER(Z2_USUARIO) = USUARIOS.NOME OR UPPER(Z2_USUARIO) = USUARIOS.USUARIO) AS F1_XXULIB, "+CRLF
	cQuery += "  UPPER(Z2_USUARIO)  AS F1_APROV,"+CRLF
	cQuery += "  '  '        AS E2_PARCELA,"+CRLF
	cQuery += "  Z2_VALOR    AS E2_VALOR,"+CRLF
	cQuery += "  0           AS E2_DESCONT,"+CRLF
	cQuery += "  0           AS E2_MULTA,"+CRLF
	cQuery += "  0           AS E2_JUROS,"+CRLF
	cQuery += "  0           AS E2_ACESC,"+CRLF
	cQuery += "  0           AS E2_DECRESC,"+CRLF
	cQuery += "  0           AS E2_VRETPIS,"+CRLF
	cQuery += "  0           AS E2_VRETCOF,"+CRLF
	cQuery += "  0           AS E2_VRETCSL,"+CRLF
	cQuery += "  0           AS E2_VRETINS,"+CRLF
	cQuery += "  0           AS E2_VRETIRF,"+CRLF
	cQuery += "  0           AS E2_VRETISS,"+CRLF
	cQuery += "  Z2_VALOR    AS E2VALTIT,"+CRLF
	cQuery += "  Z2_VALOR    AS D1TOTAL,"+CRLF
	cQuery += "  0           AS E2ACDEC"+CRLF

	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabSZ2+" SZ2" + CRLF

	cQuery += "LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON ( CTT_CUSTO = " + CRLF
	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '302000508' ELSE Z2_CC END)"+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '305000554' ELSE Z2_CC END)"+CRLF	
	ElseIf cEmpresa == '16'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '386000609' ELSE Z2_CC END)"+CRLF	
	ElseIf cEmpresa == '18'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '303000623' ELSE Z2_CC END)"+CRLF	
	Else
		cQuery += "  Z2_CC " + CRLF
	EndIf
	cQuery += " 		AND CTT_FILIAL = '01'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabSA2+" SA2" + CRLF
	cQuery += "     ON (A2_COD = Z2_E2FORN " + CRLF
	cQuery += "         AND A2_LOJA = Z2_E2LOJA " + CRLF
	cQuery += "         AND A2_FILIAL = '"+xFilial("SA2")+"' " + CRLF
	cQuery += "         AND SA2.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "WHERE Z2_FILIAL = '  ' " + CRLF
	cQuery += "      AND SZ2.D_E_L_E_T_ = '' " + CRLF
	cQuery += "      AND SZ2.Z2_CODEMP = '"+cEmpresa+"'" + CRLF
	cQuery += "      AND SZ2.Z2_TIPO IN ('EXM','VT','VR','VA','DCH','SOL','HOS','REE','CXA') " + CRLF
	cQuery += "      AND SZ2.Z2_TIPOPES = 'CLT' " + CRLF
	cQuery += "      AND SZ2.Z2_STATUS = 'S' " + CRLF

	cQuery += "UNION ALL "+CRLF

	cQuery += " SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF
	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '302000508' ELSE SUBSTRING(Z2_CC,1,9) END) AS CONTRATO,"+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '305000554' ELSE SUBSTRING(Z2_CC,1,9) END) AS CONTRATO,"+CRLF	
	ElseIf cEmpresa == '16'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '386000609' ELSE SUBSTRING(Z2_CC,1,9) END) AS CONTRATO,"+CRLF	
	ElseIf cEmpresa == '18'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '303000623' ELSE SUBSTRING(Z2_CC,1,9) END) AS CONTRATO,"+CRLF	
	Else
		cQuery += "  SUBSTRING(Z2_CC,1,9) AS CONTRATO, " + CRLF
	EndIf	
	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
 	cQuery += "  SUBSTRING(Z2_DATAPGT,5,2)+'/'+SUBSTRING(Z2_DATAPGT,1,4) AS COMPET,"+CRLF
 	cQuery += "  SUBSTRING(Z2_DATAPGT,1,6) AS COMPETAM,"+CRLF
 	cQuery += "  CONVERT(DATE,SUBSTRING(Z2_DATAPGT,1,6)+'01',112) AS COMPETD,"+CRLF

	// Chave
	cQuery += "  ('"+cEmpresa+"' + "+CRLF
	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '302000508' ELSE SUBSTRING(Z2_CC,1,9) END) + "+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '305000554' ELSE SUBSTRING(Z2_CC,1,9) END) + "+CRLF	
	ElseIf cEmpresa == '16'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '386000609' ELSE SUBSTRING(Z2_CC,1,9) END) + "+CRLF	
	ElseIf cEmpresa == '18'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '303000623' ELSE SUBSTRING(Z2_CC,1,9) END) + "+CRLF	
	Else
		cQuery += "  SUBSTRING(Z2_CC,1,9) + " + CRLF
	EndIf
	cQuery += "   SUBSTRING(Z2_DATAPGT,1,6)) AS CHAVE, " + CRLF
	cQuery += "  'SZ2-AC' AS ORIGEM, " + CRLF

	cQuery += "  Z2_FILIAL   AS D1_FILIAL,"+CRLF
	cQuery += "  Z2_E2PRF	 AS D1_SERIE,"+CRLF
	cQuery += "  Z2_E2NUM    AS D1_DOC,"+CRLF
	cQuery += "  Z2_E2FORN   AS D1_FORNECE,"+CRLF
	cQuery += "  Z2_E2LOJA   AS D1_LOJA,"+CRLF
 	cQuery += "  A2_NOME,"+CRLF
	cQuery += "  '0001'      AS D1_ITEM,"+CRLF

	// PRODUTO AC/CLA
	cQuery += "  '"+cCusBK+"' AS D1_COD,"+CRLF
	cQuery += "  RTRIM(Z2_NOME)+': '+RTRIM(Z2_OBSTITU)  AS D1_XXHIST,"+CRLF
	cQuery += "  '"+cDescCBK+"' AS B1_DESC,"+CRLF
	cQuery += "  ' '         AS B1_GRUPO, "+CRLF
  	cQuery += "  ' '         AS BM_DESC, " + CRLF
	cQuery += "  Z2_VALOR    AS F1_VALBRUT,"+CRLF
	cQuery += "  (SELECT TOP 1 USUARIOS.CODIGO FROM PowerBk.dbo.USUARIOS USUARIOS WHERE UPPER(Z2_USUARIO) = USUARIOS.NOME OR UPPER(Z2_USUARIO) = USUARIOS.USUARIO) AS F1_XXUSER, "+CRLF
	cQuery += "  UPPER(Z2_USUARIO)  AS F1_RESPON,"+CRLF
	cQuery += "  (SELECT TOP 1 USUARIOS.CODIGO FROM PowerBk.dbo.USUARIOS USUARIOS WHERE UPPER(Z2_USUARIO) = USUARIOS.NOME OR UPPER(Z2_USUARIO) = USUARIOS.USUARIO) AS F1_XXULIB, "+CRLF
	cQuery += "  UPPER(Z2_USUARIO)  AS F1_APROV,"+CRLF
	cQuery += "  '  '        AS E2_PARCELA,"+CRLF
	cQuery += "  Z2_VALOR    AS E2_VALOR,"+CRLF
	cQuery += "  0           AS E2_DESCONT,"+CRLF
	cQuery += "  0           AS E2_MULTA,"+CRLF
	cQuery += "  0           AS E2_JUROS,"+CRLF
	cQuery += "  0           AS E2_ACESC,"+CRLF
	cQuery += "  0           AS E2_DECRESC,"+CRLF
	cQuery += "  0           AS E2_VRETPIS,"+CRLF
	cQuery += "  0           AS E2_VRETCOF,"+CRLF
	cQuery += "  0           AS E2_VRETCSL,"+CRLF
	cQuery += "  0           AS E2_VRETINS,"+CRLF
	cQuery += "  0           AS E2_VRETIRF,"+CRLF
	cQuery += "  0           AS E2_VRETISS,"+CRLF
	cQuery += "  Z2_VALOR    AS E2VALTIT,"+CRLF
	cQuery += "  Z2_VALOR    AS D1TOTAL,"+CRLF
	cQuery += "  0           AS E2ACDEC"+CRLF

	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabSZ2+" SZ2" + CRLF

	cQuery += "LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON ( CTT_CUSTO = " + CRLF
	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '302000508' ELSE Z2_CC END)"+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '305000554' ELSE Z2_CC END)"+CRLF	
	ElseIf cEmpresa == '16'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '386000609' ELSE Z2_CC END)"+CRLF	
	ElseIf cEmpresa == '18'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '303000623' ELSE Z2_CC END)"+CRLF	
	Else
		cQuery += "  Z2_CC " + CRLF
	EndIf
	cQuery += " 		AND CTT_FILIAL = '01'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "LEFT JOIN "+cTabSA2+" SA2" + CRLF
	cQuery += "     ON (A2_COD = Z2_E2FORN " + CRLF
	cQuery += "         AND A2_LOJA = Z2_E2LOJA " + CRLF
	cQuery += "         AND A2_FILIAL = '"+xFilial("SA2")+"' " + CRLF
	cQuery += "         AND SA2.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "WHERE Z2_FILIAL = '  ' " + CRLF
	cQuery += "      AND SZ2.D_E_L_E_T_ = '' " + CRLF
	cQuery += "      AND SZ2.Z2_CODEMP = '"+cEmpresa+"'" + CRLF
	cQuery += "      AND SZ2.Z2_TIPOPES IN ('AC','CLA') " + CRLF
	cQuery += "      AND SZ2.Z2_STATUS = 'S' " + CRLF

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
cQuery += "    	WHEN B1_GRUPO <> ' ' THEN 'W'+BM_DESC "+CRLF
//cQuery += "    	WHEN B1_GRUPO = '0009' THEN 'WMATERIAL DE SEG' "+CRLF
//cQuery += "    	WHEN B1_GRUPO = '0010' THEN 'WINSUMOS' "+CRLF
cQuery += "     ELSE 'W'+D1_COD "+CRLF
cQuery += "     END"+CRLF
cQuery += "    ) AS PREVPROD,"+CRLF

cQuery += "    (CASE "+CRLF
cQuery += "    	WHEN D1_COD IN "+U_FBkVars(U_MVXVTPRD())+" THEN 'VT' "+CRLF
cQuery += "    	WHEN D1_COD IN "+U_FBkVars(U_MVXVRVAP())+" THEN 'VR/VA' "+CRLF
cQuery += "    	WHEN B1_GRUPO <> ' ' THEN BM_DESC "+CRLF
//cQuery += "    	WHEN B1_GRUPO = '0008' THEN 'UNIFORME' "+CRLF
//cQuery += "    	WHEN B1_GRUPO = '0009' THEN 'MATERIAL DE SEGURANCA' "+CRLF
//cQuery += "    	WHEN B1_GRUPO = '0010' THEN 'INSUMOS' "+CRLF
cQuery += "     ELSE B1_DESC "+CRLF
cQuery += "     END"+CRLF
cQuery += "    ) AS PREVDESC"+CRLF

cQuery += "	INTO PowerBk.dbo.GASTOSGERAIS"+CRLF
cQuery += "	FROM DESPESAS"+CRLF
cQuery += "	WHERE SUBSTRING(DESPESAS.CONTRATO,1,3) <> '000'
cQuery += " ORDER BY" + CRLF
cQuery += "      EMPRESA,CONTRATO,COMPETAM,D1_SERIE,D1_DOC" + CRLF

u_LogMemo("BKDSGG.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  


//  Apaga a tabela GASTOSGERAIS da base PowerBk
cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.GASTOSGERAIS', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.GASTOSGERAIS "+CRLF
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

u_LogMemo("BKDSGG.SQL",cErro1+cQueryD+cErro2+cQuery)
//u_MsgLog("BKDSGG","Final: Gastos Gerais")

Return
