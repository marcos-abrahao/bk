#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKGCTR08
BK - Mapa de Multas e Bonificações

@Return
@author Marcos Bispo Abrahão
@since 19/01/12 rev 19/05/20
@version P11/P12
/*/

User Function BKGCTR08()

Local cTitulo   := ""
Local aPlans    := {}
Local aTitulos	:= {}
Local aCampos	:= {}
Local aCabs		:= {}
Local cMesA 	:= ""
Local cAnoA 	:= ""

Private cPerg       := "BKGCTR08"
Private cMesComp    := "01"
Private cAnoComp    := "2010"
Private cMes 	    := "01"
Private nFiltro 	:= 1
Private cCompet		:= ""
Private cCompetA 	:= ""
//Private oTmpTb		As Object

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
Endif
u_LogPrw(cPerg)

cMesComp := mv_par01
cAnoComp := mv_par02
nFiltro	 := mv_par03
cCompet  := cMesComp+"/"+cAnoComp
cMes 	 := cAnoComp+cMesComp

// Competência Anterior
cMesA 	 := STRZERO(VAL(cMesComp) - 1,2)
cAnoA 	 := cAnoComp
If cMesA == "00"
	cMesA := "12"
	cAnoA := STRZERO(VAL(cAnoComp) - 1,2)
EndIf
cCompetA := cMesA+"/"+cAnoA

If nFiltro = 1
	cTitulo  := "Mapa de Multas e Bonificações : Emissão em "+cMesComp+"/"+cAnoComp
Else
	cTitulo  := "Mapa de Multas e Bonificações : Competencia "+cMesComp+"/"+cAnoComp
EndIf
FWMsgRun(, {|oSay| ProcQuery() }, "", cPerg+" - Consultando dados...")

AADD(aTitulos,cTitulo)
AADD(aCampos,"QTMP->CND_CONTRA")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QTMP->CTT_DESC01")
AADD(aCabs  ,"Centro de Custos")

AADD(aCampos,"QTMP->C5_XXCOMPM")
AADD(aCabs  ,"Competencia")

AADD(aCampos,"QTMP->C5_NUM")
AADD(aCabs  ,"Pedido")

AADD(aCampos,"QTMP->C5_MDNUMED")
AADD(aCabs  ,"Medição")

AADD(aCampos,"QTMP->C5_MDPLANI")
AADD(aCabs  ,"Planilha")

AADD(aCampos,"QTMP->CNA_XXMUN")
AADD(aCabs  ,"Municipio Planilha")

AADD(aCampos,"QTMP->F2_SERIE")
AADD(aCabs  ,"Serie")

AADD(aCampos,"QTMP->F2_DOC")
AADD(aCabs  ,"NF")

AADD(aCampos,"QTMP->F2_EMISSAO")
AADD(aCabs  ,"Emissão")

AADD(aCampos,"QTMP->CXN_VLPREV")
AADD(aCabs  ,"Valor Previsto")

AADD(aCampos,"QTMP->F2_VALFAT")
AADD(aCabs  ,"Valor Faturado")

AADD(aCabs  ,"Multas")
AADD(aCampos,"QTMP->CXN_VLMULT")

AADD(aCampos,"-QTMP->CXN_VLBONI")
AADD(aCabs  ,"Bonificações")

AADD(aCampos,"QTMP->CNRTPMUL")
AADD(aCabs  ,"Tipos Multas")

AADD(aCampos,"QTMP->CNRDESCMUL")
AADD(aCabs  ,"Descrição das Multas")

AADD(aCampos,"QTMP->CNRTPBON")
AADD(aCabs  ,"Tipos Bonificações")

AADD(aCampos,"QTMP->CNRDESCBON")
AADD(aCabs  ,"Descrição das Bonificações")

AADD(aCampos,"QTMP->FORMAMED")
AADD(aCabs  ,"Forma Medição")

AADD(aCampos,"Capital(QTMP->CND_USUAR)")
AADD(aCabs  ,"Usuário")


AADD(aPlans,{"QTMP",cPerg,"",aTitulos,aCampos,aCabs,/*aImpr1*/,/* aFormula */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })

U_PlanXlsx(aPlans,cTitulo,cPerg, lClose := .T.)

Return



Static Function ProcQuery
Local cQuery
//Local cRevAtu := Space(GetSx3Cache("CN9_REVATU","X3_TAMANHO"))
Local cFilSel := ""
//Local aStruct := {}

If nFiltro == 1
	cFilSel := xFilial("SF2")
Else
	cFilSel := xFilial("SC5")
EndIf


//Local cJCNDCNE:= FWJoinFilial("CND", "CNE")
//Local cJCXNCNE:= FWJoinFilial("CXN", "CNE")
//Local cJCNACN9:= FWJoinFilial("CNA", "CN9")
//Local cJSC5CNE:= FWJoinFilial("SC5", "CNE")
//Local cJSC6SC5:= FWJoinFilial("SC6", "SC5")
//Local cJSD2SC6:= FWJoinFilial("SD2", "SC6")
//Local cJSF2SC6:= FWJoinFilial("SF2", "SC6")


cQuery := " SELECT " + CRLF
cQuery += "   ISNULL(CND_CONTRA,C5_ESPECI1) AS CND_CONTRA"+ CRLF
cQuery += "   ,CTT_DESC01"+ CRLF
cQuery += "   ,C5_XXCOMPM"+ CRLF
cQuery += "   ,C5_NUM"+ CRLF
cQuery += "   ,C5_MDNUMED"+ CRLF
cQuery += "   ,C5_MDPLANI"+ CRLF
cQuery += "   ,F2_SERIE"+ CRLF
cQuery += "   ,F2_DOC"+ CRLF
cQuery += "   ,F2_EMISSAO"+ CRLF
cQuery += "   ,F2_VALFAT"+ CRLF

cQuery += "   ,CND_USUAR"+ CRLF
cQuery += "   ,(CASE WHEN CND_NUMERO = '' THEN 'NOVA' ELSE 'ANTIGA' END) AS FORMAMED"+ CRLF

cQuery += "   ,CNA_XXMUN"+ CRLF

//cQuery += "   ,ISNULL(CXN_VLPREV,CND_VLPREV) AS CXN_VLPREV"+ CRLF
cQuery += "   ,CASE WHEN ISNULL(CXN_VLPREV, CND_VLPREV) = CNF_VLPREV THEN CNF_VLPREV ELSE 0 END AS CXN_VLPREV"+ CRLF
//cQuery += "   ,ISNULL(CXN_VLBONI,CND_VLBONI) AS CXN_VLBONI"+ CRLF
//cQuery += "   ,ISNULL(CXN_VLMULT,CND_VLMULT) AS CXN_VLMULT"+ CRLF

cQuery += "   ,(SELECT SUM(CNR_VALOR)"+ CRLF
cQuery += "        FROM "+RETSQLNAME("CNR")+" CNR"+ CRLF
cQuery += "        WHERE "+ CRLF
cQuery += "          C5_MDNUMED = CNR.CNR_NUMMED "+ CRLF
cQuery += "          AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))"+ CRLF
cQuery += "          AND CNR_FILIAL = '"+cFilSel+"'"+ CRLF
cQuery += "          AND CNR.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += "          AND CNR_TIPO = '2' ) AS CXN_VLBONI"+ CRLF

cQuery += "   ,(SELECT SUM(CNR_VALOR)"+ CRLF
cQuery += "        FROM "+RETSQLNAME("CNR")+" CNR"+ CRLF
cQuery += "        WHERE "+ CRLF
cQuery += "          C5_MDNUMED = CNR.CNR_NUMMED "+ CRLF
cQuery += "          AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))"+ CRLF
cQuery += "          AND CNR_FILIAL = '"+cFilSel+"'"+ CRLF
cQuery += "          AND CNR.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += "          AND CNR_TIPO = '1' ) AS CXN_VLMULT"+ CRLF

cQuery += "   ,STUFF ((SELECT ';' + RTRIM(CNR_XTPJUS+'-'+ZR_DESCR)"+ CRLF
cQuery += "          FROM "+RETSQLNAME("CNR")+" CNR"+ CRLF
cQuery += "   			INNER JOIN SZR010 SZR ON ZR_TIPO = CNR_XTPJUS"+ CRLF
cQuery += "          WHERE C5_MDNUMED = CNR.CNR_NUMMED"+ CRLF
cQuery += "                AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))"+ CRLF
cQuery += "                AND CNR_FILIAL = '"+cFilSel+"' AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '1'"+ CRLF
cQuery += "          ORDER BY ';' + RTRIM(CNR_XTPJUS+ '-'+ZR_DESCR)"+ CRLF
cQuery += "          FOR XML PATH (''), TYPE).value('.', 'varchar(100)' 
cQuery += "          ), 1, 1, '') AS CNRTPMUL"+ CRLF

cQuery += "   ,STUFF ((SELECT ';' + RTRIM(CNR_DESCRI)"+ CRLF
cQuery += "          FROM "+RETSQLNAME("CNR")+" CNR"+ CRLF
cQuery += "          WHERE C5_MDNUMED = CNR.CNR_NUMMED"+ CRLF
cQuery += "                AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))"+ CRLF
cQuery += "                AND CNR_FILIAL = '"+cFilSel+"' AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '1'"+ CRLF
cQuery += "          ORDER BY ';' + RTRIM(CNR_DESCRI)"+ CRLF
cQuery += "          FOR XML PATH (''), TYPE).value('.', 'varchar(100)'
cQuery += "          ), 1, 1, '') AS CNRDESCMUL"+ CRLF

cQuery += "   ,STUFF ((SELECT ';' + RTRIM(CNR_XTPJUS+'-'+ZR_DESCR)"+ CRLF
cQuery += "          FROM "+RETSQLNAME("CNR")+" CNR"+ CRLF
cQuery += "   			INNER JOIN SZR010 SZR ON ZR_TIPO = CNR_XTPJUS"+ CRLF
cQuery += "          WHERE C5_MDNUMED = CNR.CNR_NUMMED"+ CRLF
cQuery += "                AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))"+ CRLF
cQuery += "                AND CNR_FILIAL = '"+cFilSel+"' AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2'"+ CRLF
cQuery += "          ORDER BY ';' + RTRIM(CNR_XTPJUS+ '-'+ZR_DESCR)"+ CRLF
cQuery += "          FOR XML PATH (''), TYPE).value('.', 'varchar(100)'
cQuery += "          ), 1, 1, '') AS CNRTPBON"+ CRLF

cQuery += "   ,STUFF ((SELECT ';' + RTRIM(CNR_DESCRI)"+ CRLF
cQuery += "          FROM "+RETSQLNAME("CNR")+" CNR"+ CRLF
cQuery += "          WHERE C5_MDNUMED = CNR.CNR_NUMMED"+ CRLF
cQuery += "                AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))"+ CRLF
cQuery += "                AND CNR_FILIAL = '"+cFilSel+"' AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2'"+ CRLF
cQuery += "          ORDER BY ';' + RTRIM(CNR_DESCRI)"+ CRLF
cQuery += "          FOR XML PATH (''), TYPE).value('.', 'varchar(100)'
cQuery += "          ), 1, 1, '') AS CNRDESCBON"+ CRLF

If nFiltro == 1
	cQuery  += " FROM "+RETSQLNAME("SF2")+" SF2" + CRLF
	cQuery  += " LEFT JOIN "+RETSQLNAME("SC5")+" SC5" + CRLF
	cQuery  += " 	ON (C5_NOTA = F2_DOC AND C5_SERIE = F2_SERIE" + CRLF
	cQuery  += " 		AND C5_FILIAL = F2_FILIAL AND SC5.D_E_L_E_T_='')" + CRLF
Else
	cQuery  += " FROM "+RETSQLNAME("SC5")+" SC5" + CRLF
	cQuery  += " LEFT JOIN "+RETSQLNAME("SF2")+" SF2" + CRLF
	cQuery  += " 	ON (C5_NOTA = F2_DOC AND C5_SERIE = F2_SERIE" + CRLF
	cQuery  += " 		AND F2_FILIAL = C5_FILIAL AND SF2.D_E_L_E_T_='')" + CRLF
EndIf

// Sugestão Totvs: CXN.CXN_FILIAL = CND.CND_FILIAL AND CXN.CXN_CONTRA = CND.CND_CONTRA AND CXN.CXN_REVISA = CND.CND_REVISA AND CXN.CXN_NUMMED = CND.CND_NUMMED AND CXN.CXN_CHECK = 'T'
cQuery += " LEFT JOIN "+RETSQLNAME("CND")+" CND" + CRLF
cQuery += " 	ON (CND_NUMMED = C5_MDNUMED" + CRLF
//cQuery += "         AND CND_REVISA = CND_REVGER " + CRLF
cQuery += "         AND CND_FILIAL = '"+cFilSel+"'" + CRLF
cQuery += "         AND CND.D_E_L_E_T_ = '' " + CRLF
cQuery += "         AND CND.R_E_C_N_O_ = (" + CRLF
cQuery += "            SELECT " + CRLF
cQuery += "                MIN(R_E_C_N_O_) " + CRLF
cQuery += "              FROM " + CRLF
cQuery += "                "+RETSQLNAME("CND")+" CND1 " + CRLF
cQuery += "              WHERE " + CRLF
cQuery += "                CND1.CND_NUMMED = C5_MDNUMED " + CRLF
cQuery += "                AND CND1.CND_FILIAL = '01' " + CRLF
cQuery += "                AND CND1.D_E_L_E_T_ = ''" + CRLF
cQuery += "    			)" + CRLF
cQuery += "    )" + CRLF
	

/*
cQuery += " 		AND CND.R_E_C_N_O_= " + CRLF
cQuery += "	        (SELECT TOP 1 R_E_C_N_O_ FROM CND010 CND1 " + CRLF
cQuery += "	            WHERE CND1.CND_NUMMED = C5_MDNUMED"+CRLF
cQuery += "	            AND CND1.CND_FILIAL = '"+cFilSel+"' AND CND1.D_E_L_E_T_=''))" + CRLF
*/

cQuery += " LEFT JOIN "+RETSQLNAME("CXN")+" CXN" + CRLF
cQuery += "    ON (CXN_CONTRA = C5_MDCONTR " + CRLF
cQuery += "        AND CXN_NUMMED = C5_MDNUMED " + CRLF
cQuery += "        AND CXN_NUMPLA = C5_MDPLANI " + CRLF
cQuery += "        AND CXN_REVISA = CND_REVISA " + CRLF
cQuery += "        AND CXN.CXN_CHECK = 'T' " + CRLF
cQuery += "        AND CXN_FILIAL = '"+cFilSel+"' " + CRLF
cQuery += "        AND CXN.D_E_L_E_T_ = '') " + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CNF")+" CNF" + CRLF
cQuery += " 	ON (CND_CONTRA = CNF_CONTRA" + CRLF
cQuery += " 	    AND C5_XXCOMPM = CNF_COMPET" + CRLF
cQuery += " 	    AND ISNULL(CXN_NUMPLA,CND_NUMERO) = CNF_NUMPLA" + CRLF
cQuery += " 	    AND ISNULL(CXN_REVISA, CND_REVISA) = CNF_REVISA" + CRLF
cQuery += " 	    AND CNF_PARCEL = ISNULL(CXN_PARCEL,CND_PARCEL)" + CRLF
cQuery += " 	 	AND CNF_FILIAL = '01' AND CNF.D_E_L_E_T_='')" + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+" CNA" + CRLF
cQuery += " 	ON (CNA_CONTRA = CNF_CONTRA" + CRLF
cQuery += " 	    AND CNA_CRONOG = CNF_NUMERO" + CRLF
cQuery += " 	    AND CNA_REVISA = CNF_REVISA" + CRLF
cQuery += " 	    AND CNA_NUMERO = CNF_NUMPLA" + CRLF
cQuery += " 		AND CNA_FILIAL = CNF_FILIAL" + CRLF
cQuery += " 	    AND CNA.D_E_L_E_T_='')" + CRLF // CNE_CONTRA

/* caso precise de produto
LEFT JOIN CNE010 CNE
ON (CNE_CONTRA = C5_MDCONTR AND CNE_NUMMED = C5_MDNUMED AND CNE_PEDIDO = C5_NUM
    AND CNE_REVISA = CND_REVGER AND CNE.D_E_L_E_T_ = '' AND
    CNE.R_E_C_N_O_ = 
	(SELECT TOP 1 R_E_C_N_O_ FROM CNE010 CNE1 WHERE CNE_CONTRA = C5_MDCONTR AND CNE_NUMMED = C5_MDNUMED AND CNE_PEDIDO = C5_NUM
	AND CNE_REVISA = CND_REVGER  AND CNE1.D_E_L_E_T_ = ''))

cQuery += " INNER JOIN "+RETSQLNAME("CTT")+" CTT" + CRLF
cQuery += " 	ON ISNULL(CND_CONTRA,C5_ESPECI1) = CTT_CUSTO" + CRLF
cQuery += " 		AND CTT_FILIAL = '"+xFilial("CTT")+"' AND CTT.D_E_L_E_T_='')" + CRLF
*/

cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+" CTT" + CRLF
cQuery += " 	ON (ISNULL(CND_CONTRA,C5_ESPECI1) = CTT_CUSTO" + CRLF
cQuery += " 		AND CTT_FILIAL = '"+xFilial("CTT")+"'" + CRLF
cQuery += " 		AND CTT.D_E_L_E_T_='')" + CRLF

cQuery += " WHERE "+ CRLF
If nFiltro == 1
	cQuery += " SUBSTRING(F2_EMISSAO,1,6) = '"+cMes+"'"+ CRLF
	cQuery += " AND SF2.D_E_L_E_T_=''"+ CRLF
Else 
	cQuery += " C5_XXCOMPM = '"+cCompet+"'"+ CRLF
	cQuery += " AND SC5.D_E_L_E_T_=''"+ CRLF
EndIf

If nFiltro == 1


EndIf

// Cronograma não faturado
cQuery += " UNION ALL "+ CRLF
cQuery += " SELECT DISTINCT" + CRLF

cQuery += "   CNF_CONTRA 	AS CND_CONTRA"+ CRLF
cQuery += "   ,CTT_DESC01"+ CRLF
cQuery += "   ,CNF_COMPET	AS C5_XXCOMPM"+ CRLF
cQuery += "   ,' '			AS C5_NUM"+ CRLF
cQuery += "   ,' '			AS C5_MDNUMED"+ CRLF
cQuery += "   ,CNF_NUMPLA	AS C5_MDPLANI"+ CRLF
cQuery += "   ,' '			AS F2_SERIE"+ CRLF
cQuery += "   ,'PREVISTO'	AS F2_DOC"+ CRLF
cQuery += "   ,' '			AS F2_EMISSAO"+ CRLF
cQuery += "   ,0			AS F2_VALFAT"+ CRLF
cQuery += "   ,' '			AS CND_USUAR"+ CRLF
cQuery += "   ,' '			AS FORMAMED"+ CRLF
cQuery += "   ,CNA_XXMUN    AS CNA_XXMUN"+ CRLF
cQuery += "   ,CNF_VLPREV	AS CXN_VLPREV"+ CRLF
cQuery += "   ,0 			AS CXN_VLBONI"+ CRLF
cQuery += "   ,0 			AS CXN_VLMULT"+ CRLF
cQuery += "   ,' '			AS CNRTPMUL"+ CRLF
cQuery += "   ,' '			AS CNRDESCMUL"+ CRLF
cQuery += "   ,' '			AS CNRTPBON"+ CRLF
cQuery += "   ,' '			AS CNRDESCBON"+ CRLF

cQuery += " FROM "+RETSQLNAME("CNF")+" CNF" + CRLF
cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9_REVATU = ' '"+ CRLF
cQuery += "      AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"+ CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+" CNA" + CRLF
cQuery += " 	ON (CNA_CONTRA = CNF_CONTRA AND CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA AND CNA_NUMERO = CNF_NUMPLA" +CRLF
cQuery += " 		AND CNA_FILIAL = CNF_FILIAL AND CNA.D_E_L_E_T_='')"+CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+ CRLF
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"+ CRLF

If nFiltro = 1
	// Emissão: usar competência anterior para previsões
	cQuery += " WHERE CNF_COMPET = '"+cCompetA+"'"+ CRLF
Else
	cQuery += " WHERE CNF_COMPET = '"+cCompet+"'"+ CRLF
EndIf

cQuery += "      AND  CNF_SALDO = CNF_VLPREV"+ CRLF
cQuery += "      AND  CNF_FILIAL = '"+xFilial("CNF")+"' AND  CNF.D_E_L_E_T_ = ' '"+ CRLF

cQuery += " ORDER BY F2_DOC"+ CRLF

u_LogMemo("BKGCTR08.SQL",cQuery)

// Change query insere erro no XML PATH
//cQuery := ChangeQuery(cQuery)
//u_LogMemo("CBKGCTR08.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP",.T.,.T.)
TCSETFIELD("QTMP","F2_EMISSAO","D",8,0)
//TCSETFIELD("QTMP","CNRDESCBON","C",100,0)
/*
aStruct := QTMP->(dbStruct())
aadd(aStruct,{"XX_VALBX","N",18,2})
aadd(aStruct,{"XX_VALDCAC","N",18,2})
aadd(aStruct,{"E1_XXOBX","C",15,0})
aadd(aStruct,{"E5_TIPODOC","C",2,0})

oTmpTb := FWTemporaryTable():New( "TRB")
oTmpTb:SetFields( aStruct )
oTmpTb:Create()


dbSelectArea(QTMP)
dbGoTop()
Do While !EOF()

	RecLock("TRB",.T.)
	For j:=1 to QTMP->(FCount())
		FieldPut(j,QCNC->(FieldGet(j)))
	Next

	dbSelectArea(QTMP)
	dbSkip()
EndDO
*/

Return


Static Function  ValidPerg(cPerg)
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Mes"          ,"" ,"" ,"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Ano"          ,"" ,"" ,"mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Filtrar por:" ,"" ,"" ,"mv_ch3","N",01,0,2,"C","","mv_par03","Emissão","Emissão","Emissão","","","Competencia","Competencia","Competencia","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegistros)
	If !dbSeek(cPerg+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegistros[i])
				FieldPut(j,aRegistros[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(aArea)

Return(NIL)

