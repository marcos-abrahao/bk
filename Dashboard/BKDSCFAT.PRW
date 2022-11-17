#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSCFAT
BK - Atualização da tabela CANCFATURAMENTO do banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/

User Function BKDSCFAT
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0
Local cEmpresa  := ""
Local cNomeEmp  := ""

Local cTabSF2   := ""
Local cTabSE1   := ""
Local cTabSC5   := ""
Local cTabSA1   := ""
Local cTabCTT   := ""

//u_MsgLog("BKDSCFAT","Inicio: Canc. Faturamento")

cQuery := "WITH CFATUR AS ("+CRLF
For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabSF2 := "SF2"+cEmpresa+"0"
	cTabSA1 := "SA1"+cEmpresa+"0"
	cTabCTT := "CTT"+cEmpresa+"0"
	cTabSE1 := "SE1"+cEmpresa+"0"
	cTabSC5 := "SC5"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += "SELECT DISTINCT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF

	cQuery += "  SUBSTRING(CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1 ELSE C5_MDCONTR END,1,9) AS CONTRATO, " + CRLF
	cQuery += "  ISNULL(CTT_DESC01,'BK CONSULTORIA') AS DESCRICAO, " + CRLF
	cQuery += "  SUBSTRING(F2_EMISSAO,5,2)+'/'+SUBSTRING(F2_EMISSAO,1,4) AS COMPET, " + CRLF
	cQuery += "  SUBSTRING(F2_EMISSAO,1,6) AS COMPETAM, " + CRLF
	cQuery += "  CONVERT(DATE,SUBSTRING(F2_EMISSAO,1,6)+'01',112) AS COMPETD, " + CRLF

	// Chave
	cQuery += "  '"+cEmpresa+"' + "+CRLF
	cQuery += "     SUBSTRING(CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1 ELSE C5_MDCONTR END,1,9) + " + CRLF
	cQuery += "     SUBSTRING(F2_EMISSAO,1,6) AS CHAVE , " + CRLF

	cQuery += " SF2.F2_DOC, "+CRLF
	cQuery += " SF2.F2_SERIE, "+CRLF
	cQuery += " CONVERT(DATE,SF2.F2_EMISSAO,112) AS F2_EMISSAO, " + CRLF
	cQuery += " SF2.F2_DUPL, "+CRLF
	cQuery += " SF2.F2_CLIENTE, "+CRLF
	cQuery += " SF2.F2_LOJA, "+CRLF
	cQuery += " SA1.A1_NREDUZ, "+CRLF
	cQuery += " SA1.A1_NOME, "+CRLF
	cQuery += " SF2.F2_VALFAT,"+CRLF
	cQuery += " SF2.F2_VALIRRF,"+CRLF
	cQuery += " SF2.F2_VALINSS,"+CRLF
	cQuery += " SF2.F2_VALPIS,"+CRLF
	cQuery += " SF2.F2_VALCOFI,"+CRLF
	cQuery += " SF2.F2_VALCSLL,"+CRLF
	cQuery += " SF2.F2_RECISS,"+CRLF
	cQuery += " SF2.F2_VALISS,"+CRLF
	cQuery += " SF2.F2_VLCPM,"+CRLF
	cQuery += " SF2.F2_XXVCVIN,"+CRLF
	cQuery += " SF2.F2_XXMOTEX, "+CRLF
	cQuery += " SF2.F2_XXAPREX, "+CRLF

	cQuery += " CASE WHEN SF2.F2_XXMCANC = '1' THEN 'GESTAO' "+CRLF
	cQuery += "      WHEN SF2.F2_XXMCANC = '2' THEN 'FATURAMENTO' "+CRLF
	cQuery += "      WHEN SF2.F2_XXMCANC = '3' THEN 'FISCAL' "+CRLF
	cQuery += "      WHEN SF2.F2_XXMCANC = '4' THEN 'CLIENTE' "+CRLF
	cQuery += "      ELSE 'SISTEMA'"+CRLF
	cQuery += " END AS MOTCANC, "+CRLF

	cQuery += " SC5.C5_NUM, "+CRLF
	cQuery += " SC5.C5_MDNUMED, " + CRLF
	cQuery += " SC5.C5_MDPLANI " + CRLF

	cQuery += " FROM " + CRLF
	cQuery += "  "+cTabSF2+" SF2 " + CRLF

	cQuery += " INNER JOIN "+cTabSA1+" SA1 "+CRLF
	cQuery += "     ON (SA1.A1_FILIAL='"+xFilial("SA1")+"'"+CRLF
	cQuery += "         AND SF2.F2_CLIENTE = SA1.A1_COD "+CRLF
	cQuery += "         AND SF2.F2_LOJA = SA1.A1_LOJA "+CRLF
	cQuery += "         AND SA1.D_E_L_E_T_ = '')" +CRLF

	//cQuery += " LEFT JOIN "+cTabSC5+" SC5" + CRLF
	//cQuery += "     ON (C5_NOTA = F2_DOC " + CRLF
	//cQuery += "         AND C5_SERIE = F2_SERIE " + CRLF
	//cQuery += "         AND C5_FILIAL = F2_FILIAL) " + CRLF
	//cQuery += "         AND SC5.D_E_L_E_T_ = '')" + CRLF

	cQuery += " LEFT JOIN "+cTabSE1+" SE1 " + CRLF
	cQuery += "	ON SE1.D_E_L_E_T_ <> ''  " + CRLF
	cQuery += "		AND E1_NUM     = F2_DOC " + CRLF
	cQuery += "		AND E1_PREFIXO = F2_SERIE " + CRLF
	cQuery += "		AND E1_TIPO    = 'NF' " + CRLF
	cQuery += "         AND SE1.R_E_C_N_O_ = ( " + CRLF
	cQuery += "         SELECT  " + CRLF
	cQuery += "            MIN(R_E_C_N_O_) " + CRLF
	cQuery += "         FROM "+cTabSE1+" SE11 " + CRLF
	cQuery += "         WHERE SE1.D_E_L_E_T_ <> ''  " + CRLF
	cQuery += "				AND E1_NUM     = F2_DOC " + CRLF
	cQuery += "				AND E1_PREFIXO = F2_SERIE " + CRLF
	cQuery += "				AND E1_TIPO    = 'NF' " + CRLF
	cQuery += "   ) " + CRLF

 	cQuery += " LEFT JOIN "+cTabSC5+" SC5" + CRLF
	cQuery += "   ON (SC5.C5_NUM = SE1.E1_PEDIDO) " + CRLF

	cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON (CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1 ELSE C5_MDCONTR END = CTT_CUSTO " + CRLF
	cQuery += " 		AND CTT_FILIAL = '"+xFilial("CTT")+"'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = '')" + CRLF

	cQuery += "WHERE " + CRLF
	cQuery += "      SF2.D_E_L_E_T_ <> ' ' " + CRLF
Next

cQuery += ")"  + CRLF
cQuery += " SELECT * " + CRLF

cQuery += " INTO PowerBk.dbo.CANCFATURAMENTO " + CRLF
cQuery += " FROM CFATUR " + CRLF
cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,CONTRATO,COMPETAM,F2_DOC" + CRLF

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.CANCFATURAMENTO', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.CANCFATURAMENTO "+CRLF
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

u_LogMemo("BKDSCFAT.SQL",cErro1+cQueryD+cErro2+cQuery)
//u_MsgLog("BKDSCFAT","Final: Canc. Faturamento")

Return
