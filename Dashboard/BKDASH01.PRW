#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDASH01
BK - Faturamento por contrato

@Return
@author Marcos Bispo Abrahão
@since 28/08/2020
@version P12.1.25
/*/

User Function BKDASH01()

Private cTitulo     := "Atualizar Dashboard: Faturamento e Glosas"
Private cPerg       := "BKDASH01"

If FWCodEmp() == "01"

	u_LogPrw(cPerg)

	If IsBlind()
		ProcDS01()
		ProcDS02()
	Else
		If MsgYesNo("Confirma a atualização das tabelas do banco de dados PowerBk?", cPerg)	
			FWMsgRun(, {|oSay| ProcDS01() }, "", "Atualizando a tabela GLOSAS do banco de dados PowerBk...")
			FWMsgRun(, {|oSay| ProcDS02() }, "", "Atualizando a tabela GESTORES do banco de dados PowerBk...")
		EndIf
	EndIf
Else
	If !IsBlind()
		MsgStop("Rodar apenas na empresa 01-BK", cPerg)
	EndIf
EndiF

Return


// Atualização da tabela GLOSAS do banco de dados PowerBk
Static Function ProcDS01
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrupo()
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
	//else
	//	cQuery += "DROP TABLE PowerBk.dbo.GLOSAS "+CRLF
	EndIf

	cQuery += "SELECT "+CRLF
	cQuery += "    '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "    '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "    '"+DTOS(DATE())+"' AS DATAPRC,"+CRLF
	cQuery += "    '"+SUBSTR(TIME(),1,5)+"' AS HORAPRC,"+CRLF

	cQuery += "  ISNULL(CND_CONTRA, C5_ESPECI1) AS CND_CONTRA, " + CRLF
	cQuery += "  CTT_DESC01, " + CRLF
	cQuery += "  C5_XXCOMPM, " + CRLF
	cQuery += "  C5_NUM, " + CRLF
	cQuery += "  C5_MDNUMED, " + CRLF
	cQuery += "  C5_MDPLANI, " + CRLF
	cQuery += "  F2_SERIE, " + CRLF
	cQuery += "  F2_DOC, " + CRLF
	cQuery += "  F2_EMISSAO, " + CRLF
	cQuery += "  F2_VALFAT, " + CRLF
	cQuery += "  CND_USUAR, " + CRLF
	cQuery += "  (" + CRLF
	cQuery += "    CASE WHEN CND_NUMERO = '' THEN 'NOVA' ELSE 'ANTIGA' END" + CRLF
	cQuery += "  ) AS FORMAMED, " + CRLF
	cQuery += "  CNA_XXMUN  AS CNA_XXMUN,"+ CRLF	
	//cQuery += "  ISNULL(CXN_VLPREV, CND_VLPREV) AS CXN_VLPREV, " + CRLF
	cQuery += "  CASE WHEN ISNULL(CXN_VLPREV, CND_VLPREV) = CNF_VLPREV THEN CNF_VLPREV ELSE 0 END AS CXN_VLPREV,"+ CRLF
	cQuery += "  ISNULL(CXN_VLBONI, CND_VLBONI) AS CXN_VLBONI, " + CRLF
	cQuery += "  ISNULL(CXN_VLMULT, CND_VLMULT) AS CXN_VLMULT, " + CRLF
	cQuery += "  STUFF (" + CRLF
	cQuery += "    (" + CRLF
	cQuery += "      SELECT " + CRLF
	cQuery += "        ';' + RTRIM(CNR_XTPJUS + '-' + ZR_DESCR) " + CRLF
	cQuery += "      FROM " + CRLF
	cQuery += "        "+cTabCNR+" CNR " + CRLF
	cQuery += "        INNER JOIN "+cTabSZR+" SZR ON ZR_TIPO = CNR_XTPJUS " + CRLF
	cQuery += "      WHERE " + CRLF
	cQuery += "        C5_MDNUMED = CNR.CNR_NUMMED " + CRLF
	cQuery += "        AND (" + CRLF
	cQuery += "          CASE WHEN CND_NUMERO = '' THEN CXN_NUMPLA ELSE '' END" + CRLF
	cQuery += "        ) = CNR_CODPLA " + CRLF
	cQuery += "        AND CNR_FILIAL = '"+xFilial("CNR")+"'" + CRLF
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
	cQuery += "        AND (" + CRLF
	cQuery += "          CASE WHEN CND_NUMERO = '' THEN CXN_NUMPLA ELSE '' END" + CRLF
	cQuery += "        ) = CNR_CODPLA " + CRLF
	cQuery += "        AND CNR_FILIAL = '"+xFilial("CNR")+"'" + CRLF
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
	cQuery += "        AND (" + CRLF
	cQuery += "          CASE WHEN CND_NUMERO = '' THEN CXN_NUMPLA ELSE '' END" + CRLF
	cQuery += "        ) = CNR_CODPLA " + CRLF
	cQuery += "        AND CNR_FILIAL = '"+xFilial("CNR")+"'" + CRLF
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
	cQuery += "        AND (" + CRLF
	cQuery += "          CASE WHEN CND_NUMERO = '' THEN CXN_NUMPLA ELSE '' END" + CRLF
	cQuery += "        ) = CNR_CODPLA " + CRLF
	cQuery += "        AND CNR_FILIAL = '"+xFilial("CNR")+"'" + CRLF
	cQuery += "        AND CNR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "        AND CNR_TIPO = '2' " + CRLF
	cQuery += "      ORDER BY " + CRLF
	cQuery += "        ';' + RTRIM(CNR_DESCRI) FOR XML PATH (''), " + CRLF
	cQuery += "        TYPE" + CRLF
	cQuery += "    ).value('.', 'varchar(100)'), " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    ''" + CRLF
	cQuery += "  ) AS CNRDESCBON "+CRLF
	If nE == 1
		cQuery += "  INTO PowerBk.dbo.GLOSAS " + CRLF
	EndIf
	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabSF2+" SF2 " + CRLF

	cQuery += "  LEFT JOIN "+cTabSC5+" SC5 ON (" + CRLF
	cQuery += "    C5_NOTA = F2_DOC " + CRLF
	cQuery += "    AND C5_SERIE = F2_SERIE " + CRLF
	cQuery += "    AND C5_FILIAL = F2_FILIAL " + CRLF
	cQuery += "    AND SC5.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "  LEFT JOIN "+cTabCXN+" CXN ON (" + CRLF
	cQuery += "    CXN_CONTRA = C5_MDCONTR " + CRLF
	cQuery += "    AND CXN_NUMMED = C5_MDNUMED " + CRLF
	cQuery += "    AND CXN_NUMPLA = C5_MDPLANI " + CRLF
	cQuery += "    AND CXN.CXN_CHECK = 'T' " + CRLF
	cQuery += "    AND CXN_FILIAL = '01' " + CRLF
	cQuery += "    AND CXN.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "  LEFT JOIN "+cTabCND+" CND ON (" + CRLF
	cQuery += "    CND_NUMMED = C5_MDNUMED " + CRLF
	cQuery += "    AND CND_FILIAL = '01' " + CRLF
	cQuery += "    AND CND.D_E_L_E_T_ = '' " + CRLF
	cQuery += "    AND CND.R_E_C_N_O_ = (" + CRLF
	cQuery += "      SELECT " + CRLF
	cQuery += "        TOP 1 R_E_C_N_O_ " + CRLF
	cQuery += "      FROM " + CRLF
	cQuery += "        "+cTabCND+" CND1 " + CRLF
	cQuery += "      WHERE " + CRLF
	cQuery += "        CND1.CND_NUMMED = C5_MDNUMED " + CRLF
	cQuery += "        AND CND1.CND_FILIAL = '01' " + CRLF
	cQuery += "        AND CND1.D_E_L_E_T_ = ''" + CRLF
	cQuery += "    )" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCNF+" CNF" + CRLF
	cQuery += " 	ON (CND_CONTRA = CNF_CONTRA AND C5_XXCOMPM = CNF_COMPET AND ISNULL(CXN_NUMPLA,CND_NUMERO) = CNF_NUMPLA AND ISNULL(CXN_REVISA, CND_REVISA) = CNF_REVISA" +CRLF
	cQuery += " 	    AND CNF_PARCEL = ISNULL(CXN_PARCEL,CND_PARCEL)" + CRLF
	cQuery += " 	 	AND CNF_FILIAL = '01' AND CNF.D_E_L_E_T_='')" + CRLF

	cQuery += " LEFT JOIN "+cTabCNA+" CNA" + CRLF
	cQuery += " 	ON (CNA_CONTRA = CNF_CONTRA AND CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA AND CNA_NUMERO = CNF_NUMPLA" +CRLF
	cQuery += " 		AND CNA_FILIAL = CNF_FILIAL AND CNA.D_E_L_E_T_='')"+CRLF

	cQuery += "  LEFT JOIN "+cTabCTT+" CTT ON (" + CRLF
	cQuery += "    ISNULL(CND_CONTRA, C5_ESPECI1) = CTT_CUSTO " + CRLF
	cQuery += "    AND CTT_FILIAL = '01' " + CRLF
	cQuery += "    AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "  SF2.D_E_L_E_T_ = '' " + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += "SELECT " + CRLF
	cQuery += "  DISTINCT " + CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  '"+DTOS(DATE())+"' AS DATAPRC,"+CRLF
	cQuery += "   '"+SUBSTR(TIME(),1,5)+"' AS HORAPRC,"+CRLF

	cQuery += "  CNF_CONTRA AS CND_CONTRA, " + CRLF
	cQuery += "  CTT_DESC01, " + CRLF
	cQuery += "  CNF_COMPET AS C5_XXCOMPM, " + CRLF
	cQuery += "  ' ' AS C5_NUM, " + CRLF
	cQuery += "  ' ' AS C5_MDNUMED, " + CRLF
	cQuery += "  CNF_NUMPLA AS C5_MDPLANI, " + CRLF
	cQuery += "  ' ' AS F2_SERIE, " + CRLF
	cQuery += "  'PREVISTO' AS F2_DOC, " + CRLF
	cQuery += "  ' ' AS F2_EMISSAO, " + CRLF
	cQuery += "  0 AS F2_VALFAT, " + CRLF
	cQuery += "  ' ' AS CND_USUAR, " + CRLF
	cQuery += "  ' ' AS FORMAMED, " + CRLF
	cQuery += "  CNA_XXMUN  AS CNA_XXMUN,"+ CRLF	
	cQuery += "  CNF_VLPREV AS CXN_VLPREV, " + CRLF
	cQuery += "  0 AS CXN_VLBONI, " + CRLF
	cQuery += "  0 AS CXN_VLMULT, " + CRLF
	cQuery += "  ' ' AS CNRTPMUL, " + CRLF
	cQuery += "  ' ' AS CNRDESCMUL, " + CRLF
	cQuery += "  ' ' AS CNRTPBON, " + CRLF
	cQuery += "  ' ' AS CNRDESCBON " + CRLF

	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabCNF+" CNF " + CRLF

	cQuery += "  INNER JOIN "+cTabCN9+" CN9 ON CN9_NUMERO = CNF_CONTRA " + CRLF
	cQuery += "  AND CN9_REVISA = CNF_REVISA " + CRLF
	cQuery += "  AND CN9_REVATU = ' ' " + CRLF
	cQuery += "  AND CN9_FILIAL = '01' " + CRLF
	cQuery += "  AND CN9.D_E_L_E_T_ = ' ' " + CRLF

	cQuery += " LEFT JOIN "+cTabCNA+" CNA" + CRLF
	cQuery += " 	ON (CNA_CONTRA = CNF_CONTRA AND CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA AND CNA_NUMERO = CNF_NUMPLA" +CRLF
	cQuery += " 		AND CNA_FILIAL = CNF_FILIAL AND CNA.D_E_L_E_T_='')"+CRLF

	cQuery += "  LEFT JOIN "+cTabCTT+" CTT ON CTT_CUSTO = CNF_CONTRA " + CRLF
	cQuery += "  AND CTT_FILIAL = '01' " + CRLF
	cQuery += "  AND CTT.D_E_L_E_T_ = ' ' " + CRLF

	cQuery += "WHERE " + CRLF
	cQuery += "  CNF_SALDO = CNF_VLPREV " + CRLF
	cQuery += "  AND CNF_FILIAL = '01' " + CRLF
	cQuery += "  AND CNF.D_E_L_E_T_ = ' ' " + CRLF
Next

cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,F2_DOC" + CRLF

//u_LogMemo("BKDASH01.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

//Begin Transaction

	cQueryD := "DROP TABLE PowerBk.dbo.GLOSAS "+CRLF
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


//End Transaction

u_LogMemo("BKDASH01-1.SQL",cErro1+cQueryD+cErro2+cQuery)

Return





// Atualização da tabela GESTORES do banco de dados PowerBk
Static Function ProcDS02
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrupo()
Local nE 		:= 0

Local cTabCN9   := ""

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabCN9 := "CN9"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += "SELECT DISTINCT "+CRLF
	cQuery += " '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += " '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += " '"+DTOS(DATE())+"' AS DATAPRC,"+CRLF
	cQuery += " '"+SUBSTR(TIME(),1,5)+"' AS HORAPRC,"+CRLF

	cQuery += "  CN9_NUMERO, " + CRLF
	cQuery += "  CN9_GESTC, " + CRLF
	cQuery += "  CN9_XXNRBK " + CRLF

	If nE == 1
		cQuery += "  INTO PowerBk.dbo.GESTORES " + CRLF
	EndIf

	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabCN9+" CN9 " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "  CN9_REVATU = ' ' " + CRLF
	cQuery += "  AND CN9.D_E_L_E_T_ = '' " + CRLF

Next

cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,CN9_NUMERO" + CRLF

//u_LogMemo("BKDASH01.SQL",cQuery)

If !TCIsConnected()
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

//Begin Transaction

	cQueryD := "DROP TABLE PowerBk.dbo.GESTORES "+CRLF
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


//End Transaction

u_LogMemo("BKDASH01-2.SQL",cErro1+cQueryD+cErro2+cQuery)

Return


