#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKGCTR2B
BK - Gestão do Recebimento

@Return
@author Marcos Bispo Abrahão
@since 09/06/10 Rev 25/05/20
@version P11/P12
/*/
//-------------------------------------------------------------------
User Function BKGCTR2B()

	Local cTitulo   := "Gestão do Recebimento - empresas: 01,02 e 14"
	Local aTitulos  := {}
	Local aCampos   := {}
	Local aCabs     := {}
	Local aDbf      := {}
	Local oTmpTb
	Local nMes      := 0
	Local nAno      := 0

	Private cProg   := "BKGCTR2B"
	Private nMesI   := 1
	Private nAnoI   := YEAR(dDataBase)
	Private cMesI   := ""
	Private aMeses  := {}

	Private cTpRel  := "X"
	Private aPlans  := {}

	Private nOpcao  := 1
	Private aParam	:= {}
	Private aRet	:= {}
	Private aTpRel  := {"XLSX", "CSV"}
	Private nCEndiv := 0.0
/*
Param Box Tipo 1
1 - MsGet
  [2] : Descrição
  [3] : String contendo o inicializador do campo
  [4] : String contendo a Picture do campo
  [5] : String contendo a validação
  [6] : Consulta F3
  [7] : String contendo a validação When
  [8] : Tamanho do MsGet
  [9] : Flag .T./.F. Parâmetro Obrigatório ?
*/

	aAdd(aParam, {2,"Gerar:",nOpcao,aTpRel, 50,'.T.',.T.})
	aAdd(aRet, aTpRel[nOpcao])

	aAdd(aParam, {1,"Mes",nMesI,"99"  ,"nMesI > 0    .AND. nMesI <= 12"  ,"","",20,.F.})
	aAdd(aRet, nMesI)

	aAdd(aParam, {1,"Ano",nAnoI,"9999","nAnoI >= 2010 .AND. nAnoI <= 2030","","",20,.F.})
	aAdd(aRet, nAnoI)

	aAdd(aParam, {1,"Custo end. BK %a.a."  ,nCEndiv,"999.99"  ,"MV_PAR04 > 0.00","","",20,.F.})
	aAdd(aRet, nCEndiv)

/*  
aParametros	 	Array of Record	 	Array contendo as perguntas
cTitle	 	 	Caracter	 	 	Titulo
aRet	 	 	Array of Record	 	Array container das respostas
bOk	 	 		Array of Record	 	Array contendo definições dos botões opcionais	 	 	 	 	 	 	 	 	 	 
aButtons	 	Array of Record	 	Array contendo definições dos botões opcionais	 	 	 	 	 	 	 	 	 	 
lCentered	 	Lógico	 	 		Indica se será centralizada a janela	 	 	 	 	 	 	 	 	 	 
nPosX	 	 	Numérico	 	 	Coordenada X da janela	 	 	 	 	 	 	 	 	 	 
nPosy	 	 	Numérico	 	 	Coordenada y da janela
oDlgWizard	 	Objeto	 	 		Objeto referente janela do Wizard	 	 	 	 	 	 	 	 	 	 
cLoad	 	 	Caracter	 	 	Nome arquivo para gravar respostas	 	 	 	 	 	 	 	 	 	 
lCanSave	 	Lógico	 	 		Indica se pode salvar o arquivo com respostas	 	 	 	 	 	 	 	 	 	 
lUserSave	 	Array of Record	 	Indica se salva nome do usuario no arquivo
*/

//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
	If !(Parambox(aParam     ,@cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cProg     ,.T.         ,.T.))
		Return Nil
	EndIf

	If VALTYPE(aRet[1]) == "N"
		cTpRel := Substr(aTpRel[aRet[1]],1,1)
	Else
		cTpRel := (Substr(aRet[1],1,1))
	EndIf

	nMesI    := aRet[2]
	nAnoI    := aRet[3]
	nCEndiv  := aRet[4]

	cMesI    := STRZERO(nAnoI,4)+STRZERO(nMesI,2)
	aMeses   := {}
	AADD(aMeses,cMesI)

	nMes     := nMesI
	nAno     := nAnoI

	cTitulo1 := cTitulo+": "+STRZERO(nMesI,2)+"/"+STRZERO(nAnoI,4)+ " - Custo Endiv. BK "+ALLTRIM(STR(nCEndiv,5,2))+"%"

	aDbf     := {}
	aCabs    := {}
	aCampos  := {}
	aTitulos := {}

	Aadd( aDbf, { 'XX_EMPRESA','C',  2,00 } )
	AADD(aCampos,"TMPC->XX_EMPRESA")
	AADD(aCabs  ,"Empresa")

	Aadd( aDbf, { 'XX_CLIENTE','C', TamSx3("A1_COD")[1],00 } )
	AADD(aCampos,"TMPC->XX_CLIENTE")
	AADD(aCabs  ,"Cliente")

	Aadd( aDbf, { 'XX_LOJA'   ,'C', TamSx3("A1_LOJA")[1],00 } )
	AADD(aCampos,"TMPC->XX_LOJA")
	AADD(aCabs  ,"Loja")

	Aadd( aDbf, { 'XX_NOMCLI' ,'C', TamSx3("A1_NOME")[1],00 } )
	AADD(aCampos,"TMPC->XX_NOMCLI")
	AADD(aCabs  ,"Nome do Cliente")

	Aadd( aDbf, { 'XX_SERIE' ,'C', TamSx3("D2_SERIE")[1],00 } )
	AADD(aCampos,"TMPC->XX_SERIE")
	AADD(aCabs  ,"Serie")

	Aadd( aDbf, { 'XX_DOC' ,'C', TamSx3("D2_DOC")[1],00 } )
	AADD(aCampos,"TMPC->XX_DOC")
	AADD(aCabs  ,"NF")

	Aadd( aDbf, { 'XX_CONTRA' ,'C', TamSx3("CNF_CONTRA")[1],00 } )
	AADD(aCampos,"TMPC->XX_CONTRA")
	AADD(aCabs  ,"Contrato")

	Aadd( aDbf, { 'XX_REVISAD','C',  1,00 } )

	Aadd( aDbf, { 'XX_DESC'   ,'C', TamSx3("CN9_XXDESC")[1],00 } )
	AADD(aCampos,"TMPC->XX_DESC")
	AADD(aCabs  ,"Descrição")

	Aadd( aDbf, { 'XX_INICIO' ,'C',  7,00 } )
	AADD(aCampos,"TMPC->XX_INICIO")
	AADD(aCabs  ,"Inicio")

	Aadd( aDbf, { 'XX_FINAL'  ,'C',  7,00 } )
	AADD(aCampos,"TMPC->XX_FINAL")
	AADD(aCabs  ,"Final")

	Aadd( aDbf, { 'XX_TOTFAT' ,'N', 17,02 } )
	AADD(aCampos,"TMPC->XX_TOTFAT")
	AADD(aCabs  ,"Faturado")

	Aadd( aDbf, { 'XX_DIAPRV' ,'D',  8,00 } )
	AADD(aCampos,"TMPC->XX_DIAPRV")
	AADD(aCabs  ,"Dia Prv")

	Aadd( aDbf, { 'XX_DIAFAT' ,'D',  8,00 } )
	AADD(aCampos,"TMPC->XX_DIAFAT")
	AADD(aCabs  ,"Dia Fat")

	Aadd( aDbf, { 'XX_DIASA'  ,'N',  5,00 } )
	AADD(aCampos,"TMPC->XX_DIASA")
	AADD(aCabs  ,"Dias (A)")

	Aadd( aDbf, { 'XX_VENCORI' ,'D',  8,00 } )
	AADD(aCampos,"TMPC->XX_VENCORI")
	AADD(aCabs  ,"Venc. Original")

	Aadd( aDbf, { 'XX_BAIXA' ,'D',  8,00 } )
	AADD(aCampos,"TMPC->XX_BAIXA")
	AADD(aCabs  ,"Recebimento")

	Aadd( aDbf, { 'XX_DIASB'  ,'N',  5,00 } )
	AADD(aCampos,"TMPC->XX_DIASB")
	AADD(aCabs  ,"Dias (B)")

	Aadd( aDbf, { 'XX_DIAST'  ,'N',  5,00 } )
	AADD(aCampos,"TMPC->XX_DIAST")
	AADD(aCabs  ,"Dias (A+B)")

	Aadd( aDbf, { 'XX_CUSFIN' ,'N', 17,02 } )
	AADD(aCampos,"TMPC->XX_CUSFIN")
	AADD(aCabs  ,"Custo Financeiro")

///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,'TMPC',.f.,.f. )
///IndRegua("TMPC",cArqTmp,"XX_CONTRA",,,"Indexando Arquivo de Trabalho")
///dbSetOrder(1)		

	oTmpTb := FWTemporaryTable():New("TMPC")
	oTmpTb:SetFields( aDbf )
	oTmpTb:AddIndex("indice1", {"XX_CONTRA"} )
	oTmpTb:Create()

	FWMsgRun(, {|oSay| ProcQuery("01") }, "", "Empresa 01 - Consultando o banco de dados...")
	FWMsgRun(, {|oSay| ProcQuery("02") }, "", "Empresa 02 - Consultando o banco de dados...")
	FWMsgRun(, {|oSay| ProcQuery("14") }, "", "Empresa 14 - Consultando o banco de dados...")

	AADD(aTitulos,cProg+"/"+TRIM(SUBSTR(cUsuario,7,15))+" - "+cTitulo1)

	If cTpRel == "C"
		// CSV
		U_GeraCSV("TMPC",cProg,aTitulos,aCampos,aCabs,,,,.F.)
	ElseIf cTpRel == "X"
		// XLSX
		aPlans := {}
		AADD(aPlans,{"TMPC",cProg,"",cTitulo1,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
		U_GeraXlsx(aPlans,cTitulo1,cProg,.F.,aParam)
	EndIf

	oTmpTb:Delete()

///dbSelectArea("TMPC")
///dbCloseArea()
///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())

Return



Static Function ProcQuery(_cEmp)
	Local cQuery := ""
	Local cMes   := ""
	Local dDtP   := DATE()
	Local dDtR   := DATE()
	Local nDiasA := 0
	Local nDiasB := 0
	Local nDiasT := 0
	Local _nI	 := 0

	Local cRevAtu := Space(GetSx3Cache("CN9_REVATU","X3_TAMANHO"))

	Local cJCNDCNE:= FWJoinFilial("CND", "CNE")
	Local cJCXNCNE:= FWJoinFilial("CXN", "CNE")
	//Local cJCNACN9:= FWJoinFilial("CNA", "CN9")
	Local cJSC5CNE:= FWJoinFilial("SC5", "CNE")
	Local cJSC6SC5:= FWJoinFilial("SC6", "SC5")
	Local cJSD2SC6:= FWJoinFilial("SD2", "SC6")
	Local cJSF2SC6:= FWJoinFilial("SF2", "SC6")

	Private cCampo
	Private _cEmpresa := _cEmp

	For _nI := 1 To LEN(aMeses)

		aJaPrv := {}
		cMes   := aMeses[_nI]
		cCompet:= SUBSTR(cMes,5,2)+"/"+SUBSTR(cMes,1,4)

		cQuery := " SELECT DISTINCT" + CRLF
		cQuery += "   CNF_CONTRA"+ CRLF
		cQuery += "   ,CNF_NUMERO"+ CRLF
		cQuery += "   ,CNF_PARCEL"+ CRLF
		cQuery += "   ,CNF_REVISA"+ CRLF
		cQuery += "   ,CN9_SITUAC"+ CRLF
		cQuery += "   ,CND_CLIENT"+ CRLF
		cQuery += "   ,CND_LOJACL"+ CRLF
		cQuery += "   ,CN9_NOMCLI"+ CRLF
		cQuery += "   ,CN9_XXDESC"+ CRLF
		cQuery += "   ,CNF_COMPET"+ CRLF
		cQuery += "   ,CNF_VLPREV"+ CRLF
		cQuery += "   ,D2_DOC"+ CRLF
		cQuery += "   ,D2_SERIE"+ CRLF
		cQuery += "   ,D2_TOTAL"+ CRLF
		cQuery += "   ,CNF_PRUMED"+ CRLF
		cQuery += "   ,D2_EMISSAO"+ CRLF
		cQuery += "   ,E1_NUM"+ CRLF
		cQuery += "   ,E1_PREFIXO"+ CRLF
		cQuery += "   ,E1_VALOR"+ CRLF
		cQuery += "   ,E1_VENCORI"+ CRLF
		cQuery += "   ,E1_BAIXA "+CRLF

		cQuery += " FROM "+xRETSQLNAME("CNE")+" CNE" + CRLF

		cQuery += " INNER JOIN "+xRETSQLNAME("CND")+" CND" + CRLF
		cQuery += " 	ON (CND_NUMMED = CNE_NUMMED AND CND_CONTRA = CNE_CONTRA AND CND_REVISA = CNE_REVISA" +CRLF
		cQuery += " 		AND "+cJCNDCNE+" AND CND.D_E_L_E_T_='')" + CRLF

		//cQuery += " INNER JOIN "+xRETSQLNAME("CXN")+" CXN" + CRLF
		//cQuery += " 	ON (CXN_NUMMED = CNE_NUMMED AND CXN_CONTRA = CNE_CONTRA AND CXN_REVISA = CNE_REVISA AND CXN_NUMPLA = CNE_NUMERO" +CRLF
		//cQuery += " 		AND "+cJCXNCNE+" AND CXN.D_E_L_E_T_='')" + CRLF
		// Sugestão Totvs: CXN.CXN_FILIAL = CND.CND_FILIAL AND CXN.CXN_CONTRA = CND.CND_CONTRA AND CXN.CXN_REVISA = CND.CND_REVISA AND CXN.CXN_NUMMED = CND.CND_NUMMED AND CXN.CXN_CHECK = 'T'

		cQuery += " LEFT JOIN "+xRETSQLNAME("CXN")+" CXN" + CRLF
		cQuery += " 	ON (CXN_CONTRA = CNE_CONTRA AND CXN_REVISA = CNE_REVISA AND CXN_NUMMED = CNE_NUMMED AND CXN_NUMPLA = CNE_NUMERO AND CXN.CXN_CHECK = 'T'" +CRLF
		cQuery += " 		AND "+cJCXNCNE+" AND CXN.D_E_L_E_T_='')" + CRLF

		cQuery += " INNER JOIN "+xRETSQLNAME("CTT")+" CTT" + CRLF
		cQuery += " 	ON (CTT_CUSTO = CNE_CONTRA" + CRLF
		cQuery += " 		AND CTT_FILIAL = '"+xFilial("CTT")+"' AND CTT.D_E_L_E_T_='')" + CRLF

		cQuery += " INNER JOIN "+xRETSQLNAME("CN9")+" CN9" + CRLF
		cQuery += " 	ON (CN9_FILCTR = CND_FILCTR AND CN9_NUMERO = CNE_CONTRA AND CN9_REVISA = CNE_REVISA" +CRLF
		cQuery += " 	 	AND CN9_FILIAL = CND_FILCTR AND CN9.D_E_L_E_T_='')" + CRLF

		cQuery += " INNER JOIN "+xRETSQLNAME("CNF")+" CNF" + CRLF
		cQuery += " 	ON (CNE_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CNE_NUMERO = CNF_NUMPLA AND CNE_REVISA = CNF_REVISA" +CRLF
		cQuery += " 	    AND CNF_PARCEL = ISNULL(CXN_PARCEL,CND_PARCEL)" + CRLF
		cQuery += " 	 	AND CNF_FILIAL = CN9_FILIAL AND CNF.D_E_L_E_T_='')" + CRLF

		//cQuery += " INNER JOIN "+xRETSQLNAME("CN1")+" CN1" + CRLF
		//cQuery += " 	ON (CN1_CODIGO = CN9_TPCTO AND CN1_ESPCTR IN ('2')" + CRLF
		//cQuery += " 		AND "+cJCN1CN9+" AND CN1.D_E_L_E_T_='')" + CRLF

		//cQuery += " INNER JOIN "+xRETSQLNAME("CNA")+" CNA" + CRLF
		//cQuery += " 	ON (CNA_CONTRA = CNE_CONTRA AND CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA AND CNA_NUMERO = CNF_NUMPLA" +CRLF
		//cQuery += " 		AND "+cJCNACN9+" AND CNA.D_E_L_E_T_='')"+CRLF // CNE_CONTRA

		cQuery += " INNER JOIN "+xRETSQLNAME("SC5")+" SC5" + CRLF
		cQuery += " 	ON (C5_MDNUMED = CNE_NUMMED AND C5_MDPLANI = CNE_NUMERO" + CRLF
		cQuery += " 		AND "+cJSC5CNE+" AND SC5.D_E_L_E_T_='')" + CRLF

		cQuery += " INNER JOIN "+xRETSQLNAME("SC6")+" SC6" + CRLF
		cQuery += " 	ON (C5_CLIENT = C6_CLI AND C5_LOJACLI = C6_LOJA AND C6_NUM = C5_NUM AND C6_ITEMED = CNE_ITEM" +CRLF
		cQuery += " 		AND "+cJSC6SC5+" AND SC6.D_E_L_E_T_='')" + CRLF

		cQuery += " LEFT JOIN "+xRETSQLNAME("SD2")+" SD2" + CRLF
		cQuery += " 	ON (D2_PEDIDO = C5_NUM AND D2_ITEMPV = C6_ITEM AND C5_CLIENT = D2_CLIENTE AND D2_LOJA = C5_LOJACLI" +CRLF
		cQuery += " 		AND "+cJSD2SC6+" AND SD2.D_E_L_E_T_='')" + CRLF

		cQuery += " LEFT JOIN "+xRETSQLNAME("SF2")+" SF2" + CRLF
		cQuery += " 	ON (C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND F2_CLIENTE = C6_CLI AND F2_LOJA = C6_LOJA AND F2_TIPO = 'N' AND F2_FORMUL = ' '" + CRLF
		cQuery += " 		AND "+cJSF2SC6+" AND SF2.D_E_L_E_T_='')" + CRLF

		//cQuery += " INNER JOIN "+xRETSQLNAME("SB1")+" SB1" + CRLF
		//cQuery += " 	ON (C6_PRODUTO = B1_COD" +CRLF
		//cQuery += " 		AND B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.D_E_L_E_T_='')"+CRLF

		cQuery += "	LEFT JOIN "+xRETSQLNAME("SE1")+ " SE1 ON SD2.D2_DOC = SE1.E1_NUM AND SD2.D2_SERIE = SE1.E1_PREFIXO AND E1_CLIENTE=D2_CLIENTE AND E1_LOJA=D2_LOJA AND E1_TIPO='"+MVNOTAFIS+"' "+CRLF
		cQuery += "      AND  E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' ' "+CRLF

		cQuery += " WHERE CNE.D_E_L_E_T_ = ' '"+ CRLF
		//cQuery += "       AND CNE_FILIAL = '"+xFilial("CNE")+"'" // Removido para considerar todas as filiais
		cQuery += " 	AND CN9.CN9_REVATU = '"+cRevAtu+"'"+ CRLF
		cQuery += "     AND CNF_COMPET = '"+cCompet+"'"+ CRLF
		If _cEmpresa <> "14"  
			cQuery += " AND CNF_CONTRA NOT IN ('302000508')"+CRLF
		EndIf  

		// Faturamento avulso - sem medição
		cQuery += " UNION ALL "+ CRLF

		cQuery += " SELECT DISTINCT" + CRLF
		cQuery += "   CASE WHEN (C5_ESPECI1 = ' ' OR C5_ESPECI1 IS NULL) THEN 'XXXXXXXXXX' ELSE C5_ESPECI1 END AS CNF_CONTRA"+ CRLF
		cQuery += "   ,' '        AS CNF_NUMERO"+ CRLF
		cQuery += "   ,' '        AS CNF_PARCEL"+ CRLF
		cQuery += "   ,' '        AS CNF_REVISA"+ CRLF
		cQuery += "   ,' '        AS CN9_SITUAC"+ CRLF
		cQuery += "   ,F2_CLIENTE AS CND_CLIENT"+ CRLF
		cQuery += "   ,F2_LOJA    AS CND_LOJACL"+ CRLF
		cQuery += "   ,A1_NOME    AS CN9_NOMCLI"+ CRLF
		cQuery += "   ,CTT_DESC01 AS CN9_XXDESC"+ CRLF
		cQuery += "   ,C5_XXCOMPM AS CNF_COMPET"+ CRLF
		cQuery += "   ,0          AS CNF_VLPREV"+ CRLF
		cQuery += "   ,D2_DOC"+ CRLF
		cQuery += "   ,D2_SERIE"+ CRLF
		cQuery += "   ,D2_TOTAL"+ CRLF
		cQuery += "   ,' '        AS CNF_PRUMED"+ CRLF
		cQuery += "   ,D2_EMISSAO"+ CRLF
		cQuery += "   ,E1_NUM"+ CRLF
		cQuery += "   ,E1_PREFIXO"+ CRLF
		cQuery += "   ,E1_VALOR"+ CRLF
		cQuery += "   ,E1_VENCORI"+ CRLF
		cQuery += "   ,E1_BAIXA "+CRLF

		cQuery += " FROM "+xRETSQLNAME("SF2")+" SF2" + CRLF

		cQuery += " LEFT JOIN "+xRETSQLNAME("SA1")+ " SA1 ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA" + CRLF
		cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '" + CRLF

		cQuery += " LEFT JOIN "+xRETSQLNAME("SD2")+ " SD2 ON D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA" + CRLF
		cQuery += "      AND  D2_FILIAL = '"+xFilial("SD2")+"' AND  SD2.D_E_L_E_T_ = ' '" + CRLF

		cQuery += " LEFT JOIN "+xRETSQLNAME("SC5")+ " SC5 ON C5_NOTA = F2_DOC AND C5_SERIE = F2_SERIE " + CRLF
		cQuery += "      AND  C5_FILIAL = F2_FILIAL AND SC5.D_E_L_E_T_ = ' '" + CRLF

		cQuery += " LEFT JOIN "+xRETSQLNAME("CTT")+" CTT" + CRLF
		cQuery += " 	ON (CTT_CUSTO = C5_ESPECI1" + CRLF
		cQuery += " 		AND CTT_FILIAL = '"+xFilial("CTT")+"' AND CTT.D_E_L_E_T_='')" + CRLF

		//cQuery += " LEFT JOIN "+xRETSQLNAME("SB1")+ " SB1 ON D2_COD = B1_COD"+ CRLF
		//cQuery += "      AND  B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.D_E_L_E_T_ = ' '"+ CRLF

		cQuery += "	LEFT JOIN "+xRETSQLNAME("SE1")+ " SE1 ON SD2.D2_DOC = SE1.E1_NUM AND SD2.D2_SERIE = SE1.E1_PREFIXO AND E1_CLIENTE=D2_CLIENTE AND E1_LOJA=D2_LOJA AND E1_TIPO='"+MVNOTAFIS+"' "+CRLF
		cQuery += "      AND  E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' ' "+CRLF

		cQuery += " WHERE (C5_MDCONTR = ' ' OR C5_MDCONTR IS NULL)"+ CRLF
		cQuery += "      AND C5_NUM IS NOT NULL"+ CRLF

		cQuery += "      AND SC5.C5_XXCOMPT ='"+SUBSTR(cCompet,1,2)+SUBSTR(cCompet,4,4)+"'"+ CRLF
		If _cEmpresa <> "14"  
			cQuery += "  AND C5_ESPECI1 <> '302000508' "+CRLF
		EndIf
		cQuery += "      AND SF2.D_E_L_E_T_ = ' '" + CRLF

		cQuery += " ORDER BY CNF_CONTRA,CNF_REVISA,CNF_COMPET" + CRLF

		u_LogMemo("BKGCTR2B-CONTRATO"+_cEmpresa+".SQL",cQuery)

		TCQUERY cQuery NEW ALIAS "QTMP"

		dbSelectArea("QTMP")
		QTMP->(dbGoTop())
		Do While QTMP->(!EOF())

			If QTMP->D2_TOTAL > 0

				dbSelectArea("TMPC")

				cQuery := " SELECT CNF_CONTRA,MAX(SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2)) AS XX_FIM,"
				cQuery += "                   MIN(SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2)) AS XX_INI "
				cQuery += " FROM "+xRETSQLNAME("CNF")+" CNF"
				cQuery += " WHERE CNF_CONTRA = '"+TRIM(QTMP->CNF_CONTRA)+"'"
				cQuery += "      AND  CNF_FILIAL = '"+xFilial("CNF")+"' AND  CNF.D_E_L_E_T_ = ' '"

				cQuery += " GROUP BY CNF_CONTRA "
				cQuery += " ORDER BY CNF_CONTRA "

				TCQUERY cQuery NEW ALIAS "TMP1"

				dbSelectArea("TMP1")
				TMP1->(dbGoTop())

				Reclock("TMPC",.T.)
				TMPC->XX_EMPRESA := _cEmpresa
				TMPC->XX_CONTRA  := QTMP->CNF_CONTRA
				TMPC->XX_CLIENTE := QTMP->CND_CLIENT
				TMPC->XX_LOJA    := QTMP->CND_LOJACL
				TMPC->XX_NOMCLI  := QTMP->CN9_NOMCLI
				TMPC->XX_DESC    := QTMP->CN9_XXDESC
				If TMP1->(!EOF())
					TMPC->XX_INICIO  := SUBSTR(TMP1->XX_INI,5,2)+"/"+SUBSTR(TMP1->XX_INI,1,4)
					TMPC->XX_FINAL   := SUBSTR(TMP1->XX_FIM,5,2)+"/"+SUBSTR(TMP1->XX_FIM,1,4)
				EndIf
				TMPC->XX_SERIE   := QTMP->D2_SERIE
				TMPC->XX_DOC     := QTMP->D2_DOC
				TMPC->XX_DIAFAT  := STOD(QTMP->D2_EMISSAO)
				TMPC->XX_VENCORI := STOD(QTMP->E1_VENCORI)
				TMPC->XX_BAIXA   := STOD(QTMP->E1_BAIXA)
				TMPC->XX_TOTFAT  := QTMP->D2_TOTAL

				nDiasA := 0
				nDiasB := 0
				// Data prevista faturamento
				If !Empty(STOD(QTMP->CNF_PRUMED))
					dDtP := STOD(QTMP->CNF_PRUMED)
					If DAY(dDtP) >= 28
						dDtP := LastDay(dDtP)+1
					EndIf
					dDtP := DataValida(dDtP,.T.)

					TMPC->XX_DIAPRV  := dDtP

					nDiasA := 0
					Do While dDtP < STOD(QTMP->D2_EMISSAO)
						dDtP++
						dDtP := DataValida(dDtP,.T.)
						nDiasA++
					EndDo

					TMPC->XX_DIASA := nDiasA

				EndIf


				// Vencimento original x data da baixa
				If Empty(STOD(QTMP->E1_BAIXA))
					dDtR := dDataBase
				Else
					dDtR := STOD(QTMP->E1_BAIXA)
				EndIf

				dDtP := STOD(QTMP->E1_VENCORI)
				dDtP := DataValida(dDtP,.T.)

				nDiasB := 0
				Do While dDtP < dDtR
					dDtP++
					dDtP := DataValida(dDtP,.T.)
					nDiasB++
				EndDo

				TMPC->XX_DIASB := nDiasB


				nDiasT := nDiasA + nDiasB

				TMPC->XX_DIAST   := nDiasT

				// Custo Financeiro = Faturado (c) x Custo Endiv (d) x Dias (e)
				TMPC->XX_CUSFIN  := TMPC->XX_TOTFAT * nCEndiv * nDiasT


				TMP1->(dbCloseArea())
			EndIf

			TMPC->(Msunlock())

			QTMP->(dbSkip())
		EndDo

		QTMP->(dbCloseArea())

	Next
Return


// Substituir a função padrao RESTSQLNAME
Static Function xRETSQLNAME(cAlias)
Return cAlias+_cEmpresa+"0"



