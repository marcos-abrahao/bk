#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSSC
BK - Atualização da tabela SOLCOMPRAS do banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 04/11/2022
@version P12.1.33
/*/

User Function BKDSSC
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpDsp()
Local nE 		:= 0
Local cEmpresa  := ""
Local cNomeEmp  := ""
Local cPerg		:= "BKDSSC"

Local cTabSC1   := ""
Local cTabSC7   := ""
Local cTabSF1   := ""
Local cTabSD1   := ""
Local cTabSA2   := ""

//u_MsgLog("BKDSSC","Inicio: Sol. Compras")

cQuery := "WITH SC AS ("

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabSC1 := "SC1"+cEmpresa+"0"
	cTabSC7 := "SC7"+cEmpresa+"0"
	cTabSF1 := "SF1"+cEmpresa+"0"
	cTabSD1 := "SD1"+cEmpresa+"0"
	cTabSA2 := "SA2"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += "SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF

	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(C1_CC,1,3) = '000' THEN '302000508' ELSE SUBSTRING(C1_CC,1,9) END) AS CONTRATO,"+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(C1_CC,1,3) = '000' THEN '305000554' ELSE SUBSTRING(C1_CC,1,9) END) AS CONTRATO,"+CRLF	
	ElseIf cEmpresa == '16'
		cQuery += "  (CASE WHEN SUBSTRING(C1_CC,1,3) = '000' THEN '386000609' ELSE SUBSTRING(C1_CC,1,9) END) AS CONTRATO,"+CRLF	
	ElseIf cEmpresa == '18'
		cQuery += "  (CASE WHEN SUBSTRING(C1_CC,1,3) = '000' THEN '303000623' ELSE SUBSTRING(C1_CC,1,9) END) AS CONTRATO,"+CRLF	
	Else
		cQuery += "  SUBSTRING(C1_CC,1,9) AS CONTRATO, " + CRLF
	EndIf

	//cQuery += "  ISNULL(CTT_DESC01,'BK CONSULTORIA') AS DESCRICAO, " + CRLF
	cQuery += "  SUBSTRING(C1_EMISSAO,5,2)+'/'+SUBSTRING(C1_EMISSAO,1,4) AS COMPET, " + CRLF
	cQuery += "  SUBSTRING(C1_EMISSAO,1,4)+SUBSTRING(C1_EMISSAO,5,2) AS COMPETAM, " + CRLF
	cQuery += "  CONVERT(DATE,C1_EMISSAO,112) AS COMPETD, " + CRLF

	// Chave
	cQuery += "  '"+cEmpresa+"' + "+CRLF
	cQuery += "     SUBSTRING(C1_CC,1,9) +  " + CRLF
	cQuery += "     SUBSTRING(C1_EMISSAO,1,6) AS CHAVE, " + CRLF

	cQuery += "  C1_NUM," + CRLF
	cQuery += "  C1_ITEM," + CRLF
	cQuery += "  C1_PRODUTO," + CRLF
	cQuery += "  C1_DESCRI," + CRLF
	cQuery += "  C1_QUANT," + CRLF
	cQuery += "  C1_QUJE," + CRLF
	cQuery += "  C1_UM," + CRLF
	cQuery += "  CONVERT(DATE,C1_DATPRF,112) AS C1_DATPRF," + CRLF
	cQuery += "  C1_CC," + CRLF
	cQuery += "  CONVERT(DATE,C1_EMISSAO,112) AS C1_EMISSAO," + CRLF
	cQuery += "  CONVERT(DATE,C1_XDTAPRV,112) AS C1_XDTAPRV," + CRLF
	cQuery += "  C1_PEDIDO," + CRLF
	cQuery += "  C1_ITEMPED," + CRLF
	cQuery += "  C1_USER," + CRLF
	cQuery += "  C1_FORNECE," + CRLF
	cQuery += "  C1_LOJA," + CRLF
 	cQuery += "  A2_NOME,"+CRLF
	cQuery += "  CONVERT(DATE,A2_PRICOM,112) AS A2_PRICOM," + CRLF
	cQuery += "  C7_NUM," + CRLF
	cQuery += "  CONVERT(DATE,C7_EMISSAO,112) AS C7_EMISSAO," + CRLF
	cQuery += "  C7_QUANT," + CRLF
	cQuery += "  C7_QUJE," + CRLF
	cQuery += "  C7_QTDACLA," + CRLF
	cQuery += "  C7_USER," + CRLF
	cQuery += "  C7_APROV," + CRLF
	cQuery += "  C7_XXURGEN," + CRLF	 
	cQuery += "  D1_PEDIDO," + CRLF
	cQuery += "  D1_ITEMPC," + CRLF
	cQuery += "  D1_SERIE," + CRLF
	cQuery += "  D1_DOC," + CRLF
	cQuery += "  CONVERT(DATE,D1_DTDIGIT,112) AS D1_DTDIGIT," + CRLF
	cQuery += "  D1_TOTAL," + CRLF
	cQuery += "  CONVERT(DATE,F1_XXPVPGT,112) AS F1_XXPVPGT," + CRLF
	cQuery += "  CASE WHEN SUBSTRING(F1_XXAVALI,1,1) = 'S' THEN 25 ELSE 0 END AS AVALPRECO," + CRLF
	cQuery += "  CASE WHEN SUBSTRING(F1_XXAVALI,2,1) = 'S' THEN 25 ELSE 0 END AS AVALPRAZO," + CRLF
	cQuery += "  CASE WHEN SUBSTRING(F1_XXAVALI,3,1) = 'S' THEN 25 ELSE 0 END AS AVALQUAL," + CRLF
	cQuery += "  CASE WHEN SUBSTRING(F1_XXAVALI,4,1) = 'S' THEN 25 ELSE 0 END AS AVALATEND," + CRLF
	cQuery += "  (SELECT AVG(C8_TOTAL) FROM SC8010 WHERE C8_FILIAL = C1_FILIAL AND C8_NUM = C7_NUMCOT AND C8_PRODUTO = C7_PRODUTO) AS MEDIACOTACAO" + CRLF
	//If nE == 1
	//	cQuery += "  INTO PowerBk.dbo.SOLCOMPRAS " + CRLF
	//EndIf

	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabSC1+" SC1" + CRLF

	cQuery += " LEFT JOIN "+cTabSC7+" SC7" + CRLF
	cQuery += "     ON (C7_FILIAL = C1_FILIAL " + CRLF
	cQuery += "         AND C7_NUMSC = C1_NUM " + CRLF
	cQuery += "         AND C7_ITEMSC = C1_ITEM " + CRLF
	cQuery += "         AND SC7.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabSD1+" SD1" + CRLF
	cQuery += "     ON (D1_FILIAL = C1_FILIAL " + CRLF
	cQuery += "         AND D1_PEDIDO = C1_PEDIDO " + CRLF
	cQuery += "         AND D1_ITEMPC = C1_ITEMPED " + CRLF
	cQuery += "         AND D1_PEDIDO <> ' ' " + CRLF
	cQuery += "         AND SD1.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

 	cQuery += " LEFT JOIN "+cTabSF1+" SF1" + CRLF
	cQuery += "     ON (F1_SERIE = D1_SERIE" + CRLF
	cQuery += "         AND F1_DOC = D1_DOC" + CRLF
	cQuery += "         AND F1_FORNECE = D1_FORNECE" + CRLF
	cQuery += "         AND F1_LOJA = D1_LOJA" + CRLF
	cQuery += "         AND F1_FILIAL = D1_FILIAL " + CRLF
	cQuery += "         AND SF1.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabSA2+" SA2" + CRLF
	cQuery += "     ON (A2_COD = C1_FORNECE " + CRLF
	cQuery += "         AND A2_LOJA = C1_LOJA " + CRLF
	cQuery += "         AND A2_FILIAL = '  ' " + CRLF
	cQuery += "         AND SA2.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	/*
	cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON (C1_CC = CTT_CUSTO " + CRLF
	cQuery += " 		AND CTT_FILIAL = '"+xFilial("CTT")+"'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF
	*/

	cQuery += "WHERE " + CRLF
	cQuery += "     SC1.D_E_L_E_T_ = '' " + CRLF
	cQuery += "     AND SC1.C1_APROV <> 'B' AND SC1.C1_APROV <> 'R' " + CRLF

Next

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  SC.*," + CRLF
cQuery += "  CCUSTOS.DESCRCC AS DESCRICAO," + CRLF
cQuery += "  (CASE WHEN MEDIACOTACAO > D1_TOTAL THEN MEDIACOTACAO - D1_TOTAL ELSE 0 END) AS CUSTOEVITADO," + CRLF

cQuery += "  (SELECT datediff(dd, F1_XXPVPGT, D1_DTDIGIT) - (datediff(wk, F1_XXPVPGT, D1_DTDIGIT) * 2) - " + CRLF
cQuery += "        case when datepart(dw, F1_XXPVPGT) = 1 then 1 else 0 end +" + CRLF
cQuery += "        case when datepart(dw, F1_XXPVPGT) = 1 then 1 else 0 end) AS DIFPGT," + CRLF
cQuery += "  CASE WHEN (select datediff(dd, F1_XXPVPGT, D1_DTDIGIT) - (datediff(wk, F1_XXPVPGT, D1_DTDIGIT) * 2) -" + CRLF
cQuery += "         case when datepart(dw, F1_XXPVPGT) = 1 then 1 else 0 end +" + CRLF
cQuery += "        case when datepart(dw, F1_XXPVPGT) = 1 then 1 else 0 end) > -3 AND F1_XXPVPGT IS NOT NULL AND YEAR(F1_XXPVPGT) > 1900 THEN 'S' ELSE 'N' END AS DIF3DIAS" + CRLF

cQuery += "  INTO PowerBk.dbo.SOLCOMPRAS" + CRLF
cQuery += "  FROM SC " + CRLF
cQuery += "  LEFT JOIN PowerBk.dbo.CCUSTOS ON SC.EMPRESA = CCUSTOS.EMPRESA AND SC.CONTRATO = CCUSTOS.CCUSTO COLLATE Latin1_General_BIN" + CRLF
cQuery += " ORDER BY" + CRLF
cQuery += "    SC.EMPRESA,CONTRATO,C1_NUM,C1_ITEM" + CRLF

u_LogMemo("BKDSSC.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.SOLCOMPRAS', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.SOLCOMPRAS "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	u_MsgLog(cPerg,cErro1,"E")
EndIf

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	u_MsgLog(cPerg,cErro2,"E")
EndIf

u_LogMemo("BKDSSC.SQL",cErro1+cQueryD+cErro2+cQuery)
//u_MsgLog("BKDSSC","Final: Sol. Compras")

Return
