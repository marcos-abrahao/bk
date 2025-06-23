#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR02
BK - Faturamento x Previs�o de Faturamento

@Return
@author Marcos Bispo Abrah�o
@since 09/06/10 rev 10/05/21
@version P12
/*/

User Function BKGCTR02()

	Local cTitulo   := "Previsto x Faturado - Todas empresas do Grupo BK"
	Local aTitulos  := {}
	Local aCampos1  := {}
	Local aCabs1    := {}
	Local aCampos2  := {}
	Local aCabs2    := {}
	Local aGraph	:= {}
	Local aDGraph   := {}
	Local aCabGraph := {}
	Local aEmpresas := u_BKGrpGct()
	Local nE 		:= 0
	Local _nI       := 0
	Local _nY 		:= 0
	Local aDbf1     := {}
	Local aDbf2     := {}
	Local oTmpTb1
	Local oTmpTb2

	Local nMes      := 0
	Local nAno      := 0
	Local cMes      := ""
	Local cGraph    := ""

	Private cProg   := "BKGCTR02"
	Private nMesI   := 1
	Private nAnoI   := YEAR(dDataBase)
	Private nMesF   := MONTH(dDataBase)
	Private nAnoF   := YEAR(dDataBase)
	Private cMesI   := ""
	Private cMesF   := ""
	Private nQtdCli := 15
	Private nMeses  := 0
	Private aMeses  := {}
	Private l2010   := .F.

	Private cTpRel  := "XLSX"
	Private aPlans  := {}
	Private aTMensal:= {}

	//Private nOpcao  := 1
	Private aParam	:= {}
	Private aRet	:= {}
	Private aTpRel  := {"XLSX", "CSV", "Google Charts"}

/*
Param Box Tipo 1
1 - MsGet
  [2] : Descri��o
  [3] : String contendo o inicializador do campo
  [4] : String contendo a Picture do campo
  [5] : String contendo a valida��o
  [6] : Consulta F3
  [7] : String contendo a valida��o When
  [8] : Tamanho do MsGet
  [9] : Flag .T./.F. Par�metro Obrigat�rio ?
*/

	aAdd(aParam, {2,"Gerar:",cTpRel,aTpRel, 50,'.T.',.T.})
	aAdd(aRet, cTpRel)

	aAdd(aParam, {1,"Mes inicial",nMesI,"99"  ,"mv_par02 > 0 .AND. mv_par02 <= 12"  ,"","",20,.F.})
	aAdd(aRet, nMesI)

	aAdd(aParam, {1,"Ano inicial",nAnoI,"9999","mv_par03 >= 2010 .AND. mv_par03 <= 2030","","",20,.F.})
	aAdd(aRet, nAnoI)

	aAdd(aParam, {1,"Mes final"  ,nMesF,"99"  ,"mv_par04 > 0 .AND. mv_par04 <= 12"  ,"","",20,.F.})
	aAdd(aRet, nMesF)

	aAdd(aParam, {1,"Ano final"  ,nAnoF,"9999","mv_par05 >= 2010 .AND. mv_par05 <= 2030","","",20,.F.})
	aAdd(aRet, nAnoF)

	aAdd(aParam, {1,"Qtd Maiores Clientes(s� Gr�fico)",nQtdCli,"99","mv_par06 >= 0","","",20,.F.})
	aAdd(aRet, nQtdCli)

/*  
aParametros	 	Array of Record	 	Array contendo as perguntas
cTitle	 	 	Caracter	 	 	Titulo
aRet	 	 	Array of Record	 	Array container das respostas
bOk	 	 		Array of Record	 	Array contendo defini��es dos bot�es opcionais	 	 	 	 	 	 	 	 	 	 
aButtons	 	Array of Record	 	Array contendo defini��es dos bot�es opcionais	 	 	 	 	 	 	 	 	 	 
lCentered	 	L�gico	 	 		Indica se ser� centralizada a janela	 	 	 	 	 	 	 	 	 	 
nPosX	 	 	Num�rico	 	 	Coordenada X da janela	 	 	 	 	 	 	 	 	 	 
nPosy	 	 	Num�rico	 	 	Coordenada y da janela
oDlgWizard	 	Objeto	 	 		Objeto referente janela do Wizard	 	 	 	 	 	 	 	 	 	 
cLoad	 	 	Caracter	 	 	Nome arquivo para gravar respostas	 	 	 	 	 	 	 	 	 	 
lCanSave	 	L�gico	 	 		Indica se pode salvar o arquivo com respostas	 	 	 	 	 	 	 	 	 	 
lUserSave	 	Array of Record	 	Indica se salva nome do usuario no arquivo
*/

//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
	If !(Parambox(aParam     ,@cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cProg     ,.T.         ,.T.))
		Return Nil
	EndIf
	u_MsgLog(cProg)

//If VALTYPE(aRet[1]) == "N"
//	cTpRel := Substr(aTpRel[aRet[1]],1,1)
//Else
	cTpRel := (Substr(aRet[1],1,1))
//EndIf


	nMesI  := aRet[2]
	nAnoI  := aRet[3]
	nMesF  := aRet[4]
	nAnoF  := aRet[5]

	cMesI  := STRZERO(nAnoI,4)+STRZERO(nMesI,2)
	cMesF  := STRZERO(nAnoF,4)+STRZERO(nMesF,2)
	nMes   := nMesI
	nAno   := nAnoI

	aMeses   := {}

//If cTpRel == "X"
	aCabGraph := {"Codigo","Mes","Contratado","Faturado","Contratado/Faturado","%"}
	aAdd(aTmensal,aCabGraph)
//EndIf

	nMeses := 0
	cMes   := cMesI
	Do while cMes <= cMesF
		AADD(aMeses,cMes)
		//             Mes  Titulo                               ,P F M
		AADD(aTMensal,{cMes,SUBSTR(cMes,5,2)+"/"+SUBSTR(cMes,1,4),0,0,0,""})
		nMeses++
		nMes++
		If nMes > 12
			nMes := 1
			nAno++
		EndIf
		If nAno == 2010 .AND. nMes <= 4
			l2010 := .T.
		EndIf
		cMes := STRZERO(nAno,4)+STRZERO(nMes,2)
	EndDo

	If nMeses <= 0
		MsgStop("Data inicial deve ser menor que a final",cProg)
		Return Nil
	EndIf

	cTitulo1 := cTitulo+": "+STRZERO(nMesI,2)+"/"+STRZERO(nAnoI,4)+ " at� "+STRZERO(nMesF,2)+"/"+STRZERO(nAnoF,4)
	aDbf1    := {}

	Aadd( aDbf1, { 'XX_EMPRESA','C',  2,00 } )
	Aadd( aDbf1, { 'XX_CLIENTE','C', TamSx3("A1_COD")[1],00 } )
	Aadd( aDbf1, { 'XX_LOJA'   ,'C', TamSx3("A1_LOJA")[1],00 } )
	Aadd( aDbf1, { 'XX_NOMCLI' ,'C', TamSx3("A1_NOME")[1],00 } )
	Aadd( aDbf1, { 'XX_CONTRA' ,'C', TamSx3("CNF_CONTRA")[1],00 } )
	Aadd( aDbf1, { 'XX_REVISAD','C',  1,00 } )
	Aadd( aDbf1, { 'XX_DESC'   ,'C', TamSx3("CN9_XXDESC")[1],00 } )
	Aadd( aDbf1, { 'XX_INICIO' ,'C',  7,00 } )
	Aadd( aDbf1, { 'XX_FINAL'  ,'C',  7,00 } )
	FOR _nI := 1 TO LEN(aMeses)
		cMes := aMeses[_nI]
		Aadd( aDbf1, { 'XX_P'+cMes,'N', 17,02 } )
		Aadd( aDbf1, { 'XX_F'+cMes,'N', 17,02 } )
	NEXT
	Aadd( aDbf1, { 'XX_TOTPRV','N', 17,02 } )
	Aadd( aDbf1, { 'XX_TOTFAT','N', 17,02 } )

///cArqTmp1 := CriaTrab( aDbf1, .t. )
///dbUseArea( .t.,NIL,cArqTmp1,'TMPC',.f.,.f. )
///IndRegua("TMPC",cArqTmp1,"XX_EMPRESA+XX_CONTRA",,,"Indexando Arquivo de Trabalho")

	oTmpTb1 := FWTemporaryTable():New("TMPC")
	oTmpTb1:SetFields( aDbf1 )
	oTmpTb1:AddIndex("indice1", {"XX_EMPRESA","XX_CONTRA"} )
	oTmpTb1:Create()
	dbSetOrder(1)

	aDbf2    := {}
	Aadd( aDbf2, { 'XX_CLIENTE','C', TamSx3("A1_COD")[1],00 } )
	Aadd( aDbf2, { 'XX_NOMCLI' ,'C', TamSx3("A1_NOME")[1],00 } )
	Aadd( aDbf2, { 'XX_TOTPRV' ,'N', 17,02 } )
	Aadd( aDbf2, { 'XX_TOTPRVN','N', 17,02 } )
	Aadd( aDbf2, { 'XX_TOTFAT' ,'N', 17,02 } )
	Aadd( aDbf2, { 'XX_PERDIF' ,'N', 17,02 } )

///cArqTmp2 := CriaTrab( aDbf2, .t. )
///dbUseArea( .t.,NIL,cArqTmp2,'TMPD',.f.,.f. )
///IndRegua("TMPD",cArqTmp2+"1","XX_CLIENTE",,,"Indexando Arquivo de Trabalho")
///IndRegua("TMPD",cArqTmp2+"2","-XX_TOTPRV",,,"Indexando Arquivo de Trabalho")
///dbClearIndex()
///dbSetIndex(cArqTmp2+"1" + OrdBagExt())
///dbSetIndex(cArqTmp2+"2" + OrdBagExt())

	oTmpTb2 := FWTemporaryTable():New("TMPD")
	oTmpTb2:SetFields( aDbf2 )
	oTmpTb2:AddIndex("indice2", {"XX_CLIENTE"} )
	oTmpTb2:AddIndex("indice3", {"XX_TOTPRVN"} )
	oTmpTb2:Create()
	dbSetOrder(1)

	dbSelectArea("TMPC")

	For nE := 1 To Len(aEmpresas)
		u_WaitLog(, {|oSay| ProcQuery(aEmpresas[nE,1]) }, aEmpresas[nE,2]+" - Consultando o banco de dados...")
	Next

	aCabs1   := {}
	aCampos1 := {}
	aTitulos := {}

	AADD(aTitulos,cProg+"/"+TRIM(cUserName)+" - "+cTitulo1)

	AADD(aCampos1,"TMPC->XX_EMPRESA")
	AADD(aCabs1  ,"Empresa")

	AADD(aCampos1,"TMPC->XX_CLIENTE")
	AADD(aCabs1  ,"Cliente")

	AADD(aCampos1,"TMPC->XX_LOJA")
	AADD(aCabs1  ,"Loja")

	AADD(aCampos1,"TMPC->XX_NOMCLI")
	AADD(aCabs1  ,"Nome do Cliente")

	AADD(aCampos1,"TMPC->XX_CONTRA")
	AADD(aCabs1  ,"Contrato")

	AADD(aCampos1,"TMPC->XX_DESC")
	AADD(aCabs1  ,"Descri��o")

	AADD(aCampos1,"TMPC->XX_INICIO")
	AADD(aCabs1  ,"Inicio")

	AADD(aCampos1,"TMPC->XX_FINAL")
	AADD(aCabs1  ,"Final")

	FOR _nI := 1 TO LEN(aMeses)
		cMes := aMeses[_nI]

		AADD(aCampos1,"TMPC->XX_P"+cMes)
		AADD(aCabs1  ,"Prv. "+SUBSTR(cMes,5,2)+"/"+SUBSTR(cMes,1,4))

		AADD(aCampos1,"TMPC->XX_F"+cMes)
		AADD(aCabs1  ,"Fat. "+SUBSTR(cMes,5,2)+"/"+SUBSTR(cMes,1,4))
	NEXT

	AADD(aCampos1,"TMPC->XX_TOTPRV")
	AADD(aCabs1  ,"Total Prv.")

	AADD(aCampos1,"TMPC->XX_TOTFAT")
	AADD(aCabs1  ,"Total Fat.")


	aCabs2   := {}
	aCampos2 := {}

	AADD(aCampos2,"TMPD->XX_CLIENTE")
	AADD(aCabs2  ,"Cliente")

	AADD(aCampos2,"TMPD->XX_NOMCLI")
	AADD(aCabs2  ,"Nome do Cliente")

	AADD(aCampos2,"TMPD->XX_TOTPRV")
	AADD(aCabs2  ,"Total Prv.")

	AADD(aCampos2,"TMPD->XX_TOTFAT")
	AADD(aCabs2  ,"Total Fat.")

	AADD(aCampos2,"TMPD->XX_PERDIF")
	AADD(aCabs2  ,"%")


// Calcular diferen�a e % para os gr�ficos
	For _nY := 2 To Len(aTMensal)
		aTMensal[_nY,5] := aTMensal[_nY,3] - aTMensal[_nY,4]     // Mostrar no gr�fico apenas a diferen�a
		aTMensal[_nY,6] := ROUND((aTMensal[_nY,3] * 100 / aTMensal[_nY,4]) - 100,1)
	Next

	If cTpRel == "C"
		// CSV
		U_GeraCSV("TMPC",cProg,aTitulos,aCampos1,aCabs1,,,,.F.)
	ElseIf cTpRel == "X"
		// XLSX
		aPlans := {}
		AADD(aPlans,{"TMPC",cProg+"-A1","",cTitulo1,aCampos1,aCabs1,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
		TMPD->(dbSetOrder(2))
		AADD(aPlans,{"TMPD",cProg+"-A2","","Totais por Cliente",aCampos2,aCabs2,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })

		aDGraph := {}
		// Remover a primeira coluna
		For _nI := 1 TO Len(aTMensal)
			aAdd(aDGraph,{aTMensal[_nI,2],aTMensal[_nI,3],aTMensal[_nI,4],aTMensal[_nI,5],aTMensal[_nI,6]})
		Next
		aGraph:= {cProg,cTitulo,aDGraph}

		U_PlanXlsx(aPlans,cTitulo1,cProg,.F.,aParam,aGraph)
	Else
		// Gr�fico Google Charts
		//ProcRegua(TMPC->(LASTREC()))
		u_WaitLog(, {|| cGraph := GeraChart1(aTMensal,cProg,aTitulos)})
	EndIf

	oTmpTb1:Delete()
	oTmpTb2:Delete()

Return


Static Function ProcQuery(_cEmp)
	Local cQuery
	//Local cQuery2
	Local _nI
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

	// Consultando o banco de dados...

	FOR _nI := 1 TO LEN(aMeses)

		aJaPrv := {}
		cMes   := aMeses[_nI]
		cCompet:= SUBSTR(cMes,5,2)+"/"+SUBSTR(cMes,1,4)

		cQuery := " SELECT " + CRLF
		cQuery += "   CNF_CONTRA"+ CRLF
		cQuery += "   ,CNF_NUMERO"+ CRLF
		cQuery += "   ,CNF_PARCEL"+ CRLF
		cQuery += "   ,CNF_REVISA"+ CRLF
		cQuery += "   ,CN9_SITUAC"+ CRLF
		cQuery += "   ,ISNULL(CXN.CXN_CLIENT, CND.CND_CLIENT) CND_CLIENT"+ CRLF
		cQuery += "   ,ISNULL(CXN.CXN_CLIENT, CND.CND_LOJACL) CND_LOJACL"+ CRLF
		cQuery += "   ,CN9_NOMCLI"+ CRLF
		cQuery += "   ,CN9_XXDESC"+ CRLF
		cQuery += "   ,CNF_COMPET"+ CRLF
		cQuery += "   ,CNF_VLPREV"+ CRLF
		cQuery += "   ,D2_TOTAL"+ CRLF
		cQuery += "   ,CN9_DTULST"+ CRLF

		cQuery += " FROM "+xRETSQLNAME("CNE")+" CNE" + CRLF

		cQuery += " INNER JOIN "+xRETSQLNAME("CND")+" CND" + CRLF
		cQuery += " 	ON (CND_NUMMED = CNE_NUMMED AND CND_CONTRA = CNE_CONTRA AND CND_REVISA = CNE_REVISA" +CRLF
		cQuery += " 		AND "+cJCNDCNE+" AND CND.D_E_L_E_T_='')" + CRLF

		//cQuery += " INNER JOIN "+xRETSQLNAME("CXN")+" CXN" + CRLF
		//cQuery += " 	ON (CXN_NUMMED = CNE_NUMMED AND CXN_CONTRA = CNE_CONTRA AND CXN_REVISA = CNE_REVISA AND CXN_NUMPLA = CNE_NUMERO" +CRLF
		//cQuery += " 		AND "+cJCXNCNE+" AND CXN.D_E_L_E_T_='')" + CRLF
		// Sugest�o Totvs: CXN.CXN_FILIAL = CND.CND_FILIAL AND CXN.CXN_CONTRA = CND.CND_CONTRA AND CXN.CXN_REVISA = CND.CND_REVISA AND CXN.CXN_NUMMED = CND.CND_NUMMED AND CXN.CXN_CHECK = 'T'

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
		cQuery += " 	 	AND CNF_FILIAL = '01' AND CNF.D_E_L_E_T_='')" + CRLF

		//cQuery += " INNER JOIN "+xRETSQLNAME("CN1")+" CN1" + CRLF
		//cQuery += " 	ON (CN1_CODIGO = CN9_TPCTO AND CN1_ESPCTR IN ('2')" + CRLF
		//cQuery += " 		AND "+cJCN1CN9+" AND CN1.D_E_L_E_T_='')" + CRLF

		//cQuery += " INNER JOIN "+xRETSQLNAME("CNA")+" CNA" + CRLF
		//cQuery += " 	ON (CNA_CONTRA = CNE_CONTRA AND CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA AND CNA_NUMERO = CNF_NUMPLA" +CRLF
		//cQuery += " 		AND CNA_FILIAL = CND_FILCTR AND CNA.D_E_L_E_T_='')"+CRLF // CNE_CONTRA

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

		cQuery += " WHERE CNE.D_E_L_E_T_ = ' '"+ CRLF
		//cQuery += "       AND CNE_FILIAL = '"+xFilial("CNE")+"'" // Removido para considerar todas as filiais
		cQuery += " 	AND CN9.CN9_REVATU = '"+cRevAtu+"'"+ CRLF
		cQuery += "     AND CNF_COMPET = '"+cCompet+"'"+ CRLF

		// Faturamento avulso - sem medi��o
		cQuery += " UNION ALL "+ CRLF

		cQuery += " SELECT " + CRLF
		cQuery += "   CASE WHEN (C5_ESPECI1 = ' ' OR C5_ESPECI1 IS NULL) THEN 'XXXXXXXXXX' ELSE C5_ESPECI1 END AS CNF_CONTRA"+ CRLF
		cQuery += "   ,' '        AS CNF_NUMERO"+ CRLF
		cQuery += "   ,' '        AS CNF_PARCEL"+ CRLF
		cQuery += "   ,' '        AS CNF_REVISA"+ CRLF
		cQuery += "   ,' '        AS CN9_SITUAC"+ CRLF
		cQuery += "   ,F2_CLIENTE AS CND_CLIENT"+ CRLF
		cQuery += "   ,F2_LOJA    AS CND_LOJACL"+ CRLF
		cQuery += "   ,CTT_DESC01 AS CN9_XXDESC"+ CRLF
		cQuery += "   ,A1_NOME    AS CN9_NOMCLI"+ CRLF
		cQuery += "   ,C5_XXCOMPM AS CNF_COMPET"+ CRLF
		cQuery += "   ,0          AS CNF_VLPREV"+ CRLF
		cQuery += "   ,D2_TOTAL"+ CRLF
		cQuery += "   ,' '        AS CN9_DTULST"+ CRLF

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

		cQuery += " WHERE (C5_MDCONTR = ' ' OR C5_MDCONTR IS NULL)"+ CRLF
		cQuery += "      AND C5_NUM IS NOT NULL"+ CRLF
		cQuery += "      AND SC5.C5_XXCOMPT ='"+SUBSTR(cCompet,1,2)+SUBSTR(cCompet,4,4)+"'"+ CRLF
		cQuery += "      AND C5_ESPECI1 <> '000000001'"+ CRLF
		cQuery += "      AND SF2.D_E_L_E_T_ = ' '" + CRLF

		// Cronograma n�o faturado
		cQuery += " UNION ALL "+ CRLF

		cQuery += " SELECT DISTINCT" + CRLF

		cQuery += "   CNF_CONTRA"+ CRLF
		cQuery += "   ,CNF_NUMERO"+ CRLF
		cQuery += "   ,CNF_PARCEL"+ CRLF
		cQuery += "   ,CNF_REVISA"+ CRLF
		cQuery += "   ,CN9_SITUAC"+ CRLF
		cQuery += "   ,CN9_XCLIEN AS CND_CLIENT"+ CRLF
		cQuery += "   ,CN9_XLOJA  AS CND_LOJACL"+ CRLF
		cQuery += "   ,CN9_NOMCLI"+ CRLF
		cQuery += "   ,CN9_XXDESC"+ CRLF
		cQuery += "   ,CNF_COMPET"+ CRLF
		cQuery += "   ,CNF_VLPREV"+ CRLF
		cQuery += "   ,0 AS D2_TOTAL"+ CRLF
		cQuery += "   ,CN9_DTULST"+ CRLF

		cQuery += " FROM "+xRETSQLNAME("CNF")+" CNF" + CRLF

		cQuery += " INNER JOIN "+xRETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9_REVATU = ' '"+ CRLF
		cQuery += "      AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"+ CRLF

		//cQuery += " LEFT JOIN "+xRETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+ CRLF
		//cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"+ CRLF

		//cQuery += " LEFT JOIN "+xRETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_CONTRA = CNF_CONTRA AND CNA_REVISA = CNF_REVISA"+ CRLF
		//cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '"+ CRLF

		cQuery += " WHERE CNF_COMPET = '"+cCompet+"'"+ CRLF
		cQuery += "      AND  CNF_SALDO = CNF_VLPREV"+ CRLF
		cQuery += "      AND  CNF_FILIAL = '"+xFilial("CNF")+"' AND  CNF.D_E_L_E_T_ = ' '"+ CRLF

		cQuery += " ORDER BY CNF_CONTRA,CNF_REVISA,CNF_COMPET" + CRLF

		u_LogMemo("BKGCTR02-1-"+_cEmpresa+".SQL",cQuery)

		TCQUERY cQuery NEW ALIAS "QTMP"

		dbSelectArea("QTMP")
		QTMP->(dbGoTop())
		DO WHILE QTMP->(!EOF())

			nPrev   := QTMP->CNF_VLPREV
			// Parar previs�o quando o contrato for cancelado ou encerrado
			IF QTMP->CN9_SITUAC $ "01/08" .AND. cMes > SUBSTR(QTMP->CN9_DTULST,1,6)
				nPrev   := 0
			ENDIF

			IF nPrev == 0 .AND. QTMP->D2_TOTAL == 0
				dbSelectArea("QTMP")
				dbSkip()
				Loop
			ENDIF

			dbSelectArea("TMPC")
			If !TMPC->(MsSeek(_cEmpresa+QTMP->CNF_CONTRA,.F.))

				cQuery := " SELECT CNF_CONTRA,MAX(SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2)) AS XX_FIM," + CRLF
				cQuery += "                   MIN(SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2)) AS XX_INI " + CRLF

				cQuery += " FROM "+xRETSQLNAME("CNF")+" CNF" + CRLF

				cQuery += " WHERE CNF_CONTRA = '"+TRIM(QTMP->CNF_CONTRA)+"'" + CRLF
				cQuery += "      AND  CNF_FILIAL = '"+xFilial("CNF")+"' AND  CNF.D_E_L_E_T_ = '' " + CRLF

				cQuery += " GROUP BY CNF_CONTRA " + CRLF
				cQuery += " ORDER BY CNF_CONTRA " + CRLF

				u_LogMemo("BKGCTR02-x-"+_cEmpresa+".SQL",cQuery)

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

				TMP1->(dbCloseArea())

			Else
				Reclock("TMPC",.F.)
			EndIf

			cCampo  := "TMPC->XX_P"+cMes

			IF ASCAN(aJaPrv,QTMP->CNF_CONTRA+QTMP->CNF_NUMERO+QTMP->CNF_PARCEL) == 0
				&cCampo += nPrev
				AADD(aJaPrv,QTMP->CNF_CONTRA+QTMP->CNF_NUMERO+QTMP->CNF_PARCEL)
			ELSE
				nPrev := 0
			ENDIF

			cCampo  := "TMPC->XX_F"+cMes
			&cCampo += QTMP->D2_TOTAL    //QTMP->F2_VALFAT

			// Totalizador do Gr�fico
			_nY := aScan(aTMensal, {|x| x[1] == cMes})
			//If _nY > 0
			aTMensal[_nY,3] += nPrev
			aTMensal[_nY,4] += QTMP->D2_TOTAL  //QTMP->F2_VALFAT
			//EndIf

			TMPC->XX_TOTPRV += nPrev
			TMPC->XX_TOTFAT += QTMP->D2_TOTAL  //QTMP->F2_VALFAT

			TMPC->(Msunlock())

			// Gravar total por cliente
			dbSelectArea("TMPD")
			If !MsSeek(QTMP->CND_CLIENT,.F.)
				Reclock("TMPD",.T.)
				TMPD->XX_CLIENTE := QTMP->CND_CLIENT
				TMPD->XX_NOMCLI  := QTMP->CN9_NOMCLI
			Else
				Reclock("TMPD",.F.)
			EndIf
			TMPD->XX_TOTPRV  += nPrev
			TMPD->XX_TOTPRVN -= nPrev
			TMPD->XX_TOTFAT  += QTMP->D2_TOTAL
			If TMPD->XX_TOTPRV > 0
				TMPD->XX_PERDIF := 100 - (TMPD->XX_TOTFAT * 100 / TMPD->XX_TOTPRV)
			EndIf

			TMPD->(Msunlock())

			QTMP->(dbSkip())
		ENDDO
		QTMP->(dbCloseArea())

/*
		//*********Inclus�o para medi��o avulsa
		cQuery2 := "SELECT C5_ESPECI1,A1_COD,A1_LOJA,A1_NOME,CTT_DESC01,SUM(D2_TOTAL) AS MEDAVULSO FROM "+xRETSQLNAME("SC5")+" SC5" + CRLF
		cQuery2 += " INNER JOIN "+xRETSQLNAME("SC6")+" SC6 ON SC5.C5_NUM = SC6.C6_NUM" + CRLF
		cQuery2 += " INNER JOIN "+xRETSQLNAME("SD2")+" SD2 ON SC6.C6_SERIE = SD2.D2_SERIE AND SC6.C6_NOTA = SD2.D2_DOC"+ CRLF
		cQuery2 += "   AND SD2.D_E_L_E_T_ = ' '" + CRLF
		cQuery2 += " INNER JOIN "+xRETSQLNAME("SA1")+" SA1 ON SD2.D2_CLIENTE = SA1.A1_COD" + CRLF
		cQuery2 += "   AND SD2.D2_LOJA = SA1.A1_LOJA  AND  SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"+ CRLF
		cQuery2 += " INNER JOIN "+xRETSQLNAME("CTT")+" CTT ON SC5.C5_ESPECI1 = CTT.CTT_CUSTO AND CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '" + CRLF
		cQuery2 += " WHERE SC5.D_E_L_E_T_ = ' ' AND SC5.C5_MDCONTR='' AND SC5.C5_XXCOMPT ='"+SUBSTR(cCompet,1,2)+SUBSTR(cCompet,4,4)+"'"+ CRLF
		cQuery2 += "   AND C5_ESPECI1 <> '000000001'"+ CRLF
		cQuery2 += " GROUP BY SC5.C5_ESPECI1,SA1.A1_COD,SA1.A1_LOJA,SA1.A1_NOME,CTT.CTT_DESC01" + CRLF

		u_LogMemo("BKGCTR02-2-"+cEmpAnt+"+.SQL",cQuery)

		TCQUERY cQuery2 NEW ALIAS "TMPX2"

		dbSelectArea("TMPX2")
		TMPX2->(dbGoTop())
		DO While !TMPX2->(EOF())
			dbSelectArea("TMPC")
			If !TMPC->(MsSeek(_cEmpresa+TMPX2->C5_ESPECI1,.F.))
				Reclock("TMPC",.T.)
				TMPC->XX_EMPRESA := _cEmpresa
				TMPC->XX_CONTRA  := TMPX2->C5_ESPECI1
				TMPC->XX_CLIENTE := TMPX2->A1_COD
				TMPC->XX_LOJA    := TMPX2->A1_LOJA
				TMPC->XX_NOMCLI  := TMPX2->A1_NOME
				TMPC->XX_DESC    := TMPX2->CTT_DESC01
			Else
				Reclock("TMPC",.F.)
			EndIf

			cCampo  := "TMPC->XX_F"+cMes
			&cCampo += TMPX2->MEDAVULSO

			// Totalizador do Gr�fico
			_nY := aScan(aTMensal, {|x| x[1] == cMes})
			//If _nY > 0
			aTMensal[_nY,4] += TMPX2->MEDAVULSO
			//EndIf

			TMPC->XX_TOTFAT += TMPX2->MEDAVULSO

			TMPC->(Msunlock())


			// Gravar total por cliente
			dbSelectArea("TMPD")
			If !MsSeek(TMPX2->A1_COD,.F.)
				Reclock("TMPD",.T.)
				TMPD->XX_CLIENTE := TMPX2->A1_COD
				TMPD->XX_NOMCLI  := TMPX2->A1_NOME
			Else
				Reclock("TMPD",.F.)
			EndIf
			TMPD->XX_TOTFAT += TMPX2->MEDAVULSO
			TMPD->(Msunlock())
			If TMPD->XX_TOTPRV > 0
				TMPD->XX_PERDIF := 100 - (TMPD->XX_TOTFAT * 100 / TMPD->XX_TOTPRV)
			EndIf

			TMPX2->(dbSkip())
		ENDDO
		TMPX2->(dbCloseArea())
*/

	NEXT

Return




// Medi��o Antiga
/*
Static Function ProcQryOld(_cEmp)
	Local cQuery,cQuery2
	Local _nI

	Private cCampo
	Private _cEmpresa := _cEmp

	IncProc("Consultando o banco de dados...")

	FOR _nI := 1 TO LEN(aMeses)

		aJaPrv := {}
		cMes   := aMeses[_nI]
		cCompet:= SUBSTR(cMes,5,2)+"/"+SUBSTR(cMes,1,4)

		cQuery := " SELECT DISTINCT CNF_CONTRA,CNF_NUMERO,CNF_PARCEL,CN9_REVISA,CN9_SITUAC,CND_CLIENT,CND_LOJACL,CN9_NOMCLI,CN9_XXDESC,CNF_COMPET,CNF_VLPREV,SUM(D2_TOTAL) AS D2_TOTAL,CN9_DTULST "+ CRLF

		cQuery += " FROM "+xRETSQLNAME("CNF")+" CNF"+ CRLF
		cQuery += " INNER JOIN "+xRETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09' "+ CRLF
		cQuery += "      AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"+ CRLF
		cQuery += " LEFT JOIN "+xRETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+ CRLF
		cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"+ CRLF
		cQuery += " LEFT JOIN "+xRETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNF_CONTRA = CNA_CONTRA AND CNA_REVISA = CNF_REVISA"+ CRLF
		cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '"+ CRLF
		cQuery += " LEFT JOIN "+xRETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CND_PARCEL = CNF_PARCEL AND CNA_NUMERO = CND_NUMERO AND CND_REVISA = CNF_REVISA"+ CRLF
		cQuery += "      AND  CND.D_E_L_E_T_ = ' '"+ CRLF

		cQuery += " LEFT JOIN "+xRETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM"+ CRLF
		cQuery +=  "      AND  C6_FILIAL = CND_FILIAL AND SC6.D_E_L_E_T_ = ' '"+ CRLF
		cQuery += "	LEFT JOIN "+xRETSQLNAME("SD2")+ " SD2 ON SC6.C6_NUM = SD2.D2_PEDIDO AND C6_ITEM = D2_ITEM  "+ CRLF
		cQuery += "      AND  D2_FILIAL = CND_FILIAL AND SD2.D_E_L_E_T_ = ' ' "+ CRLF
		cQuery += " WHERE CNF_COMPET = '"+cCompet+"'"+ CRLF
		cQuery += "      AND  CNF_FILIAL = '"+xFilial("CNF")+"' AND CNF.D_E_L_E_T_ = ' '"+ CRLF
		IF _cEmpresa <> "14"
			cQuery += " AND CNF_CONTRA NOT IN ('302000508')"+ CRLF
		ENDIF

		cQuery += " GROUP BY CNF_CONTRA,CNF_NUMERO,CNF_PARCEL,CN9_REVISA,CN9_SITUAC,CND_CLIENT,CND_LOJACL,CN9_NOMCLI,CN9_XXDESC,CNF_COMPET,CNF_VLPREV,CN9_DTULST"+ CRLF
		cQuery += " ORDER BY CNF_CONTRA"+ CRLF

		u_LogMemo("BKGCTR02-1"+cEmpAnt+"+.SQL",cQuery)

		TCQUERY cQuery NEW ALIAS "QTMP"

		dbSelectArea("QTMP")
		QTMP->(dbGoTop())
		DO WHILE QTMP->(!EOF())

			IncProc()

			nPrev   := QTMP->CNF_VLPREV
			// Parar previs�o quando o contrato for cancelado ou encerrado
			IF QTMP->CN9_SITUAC $ "01/08" .AND. cMes > SUBSTR(QTMP->CN9_DTULST,1,6)
				nPrev   := 0
			ENDIF

			IF nPrev == 0 .AND. QTMP->D2_TOTAL == 0
				dbSelectArea("QTMP")
				dbSkip()
				Loop
			ENDIF

			dbSelectArea("TMPC")
			If !TMPC->(MsSeek(_cEmpresa+QTMP->CNF_CONTRA,.F.))

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

				TMP1->(dbCloseArea())

			Else
				Reclock("TMPC",.F.)
			EndIf

			//IF SUBSTR(cMes,1,4) = '2010' .AND. VAL(SUBSTR(cMes,5,2)) <= 4 .AND. TMPC->XX_REVISAD = "S"
			// N�o somar valores em vigencia para contrados revisados na competencia < 2010/04
			//ELSE
			cCampo  := "TMPC->XX_P"+cMes

			IF ASCAN(aJaPrv,QTMP->CNF_CONTRA+QTMP->CNF_NUMERO+QTMP->CNF_PARCEL) == 0
				&cCampo += nPrev
				AADD(aJaPrv,QTMP->CNF_CONTRA+QTMP->CNF_NUMERO+QTMP->CNF_PARCEL)
			ELSE
				nPrev := 0
			ENDIF

			cCampo  := "TMPC->XX_F"+cMes
			&cCampo += QTMP->D2_TOTAL    //QTMP->F2_VALFAT

			// Totalizador do Gr�fico
			_nY := aScan(aTMensal, {|x| x[1] == cMes})
			//If _nY > 0
			aTMensal[_nY,3] += nPrev
			aTMensal[_nY,4] += QTMP->D2_TOTAL  //QTMP->F2_VALFAT
			//EndIf

			TMPC->XX_TOTPRV += nPrev
			TMPC->XX_TOTFAT += QTMP->D2_TOTAL  //QTMP->F2_VALFAT

			TMPC->(Msunlock())

			// Gravar total por cliente
			dbSelectArea("TMPD")
			If !MsSeek(QTMP->CND_CLIENT,.F.)
				Reclock("TMPD",.T.)
				TMPD->XX_CLIENTE := QTMP->CND_CLIENT
				TMPD->XX_NOMCLI  := QTMP->CN9_NOMCLI
			Else
				Reclock("TMPD",.F.)
			EndIf
			TMPD->XX_TOTPRV  += nPrev
			TMPD->XX_TOTPRVN -= nPrev
			TMPD->XX_TOTFAT  += QTMP->D2_TOTAL
			If TMPD->XX_TOTPRV > 0
				TMPD->XX_PERDIF := 100 - (TMPD->XX_TOTFAT * 100 / TMPD->XX_TOTPRV)
			EndIf

			TMPD->(Msunlock())

			QTMP->(dbSkip())
		ENDDO
		QTMP->(dbCloseArea())

	
		//*********Inclus�o para medi��o avulsa
		cQuery2 := "SELECT C5_ESPECI1,A1_COD,A1_LOJA,A1_NOME,CTT_DESC01,SUM(D2_TOTAL) AS MEDAVULSO FROM "+xRETSQLNAME("SC5")+" SC5" + CRLF
		cQuery2 += " INNER JOIN "+xRETSQLNAME("SC6")+" SC6 ON SC5.C5_NUM = SC6.C6_NUM" + CRLF
		cQuery2 += " INNER JOIN "+xRETSQLNAME("SD2")+" SD2 ON SC6.C6_SERIE = SD2.D2_SERIE AND SC6.C6_NOTA = SD2.D2_DOC"+ CRLF
		cQuery2 += "   AND SD2.D_E_L_E_T_ = ' '" + CRLF
		cQuery2 += " INNER JOIN "+xRETSQLNAME("SA1")+" SA1 ON SD2.D2_CLIENTE = SA1.A1_COD" + CRLF
		cQuery2 += "   AND SD2.D2_LOJA = SA1.A1_LOJA  AND  SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"+ CRLF
		cQuery2 += " INNER JOIN "+xRETSQLNAME("CTT")+" CTT ON SC5.C5_ESPECI1 = CTT.CTT_CUSTO AND CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '" + CRLF
		cQuery2 += " WHERE SC5.D_E_L_E_T_ = ' ' AND SC5.C5_MDCONTR='' AND SC5.C5_XXCOMPT ='"+SUBSTR(cCompet,1,2)+SUBSTR(cCompet,4,4)+"'"+ CRLF
		cQuery2 += "   AND C5_ESPECI1 <> '000000001'"+ CRLF
		cQuery2 += " GROUP BY SC5.C5_ESPECI1,SA1.A1_COD,SA1.A1_LOJA,SA1.A1_NOME,CTT.CTT_DESC01" + CRLF

		u_LogMemo("BKGCTR02-2.SQL",cQuery)

		TCQUERY cQuery2 NEW ALIAS "TMPX2"

		dbSelectArea("TMPX2")
		TMPX2->(dbGoTop())
		DO While !TMPX2->(EOF())
			dbSelectArea("TMPC")
			If !TMPC->(MsSeek(_cEmpresa+TMPX2->C5_ESPECI1,.F.))
				Reclock("TMPC",.T.)
				TMPC->XX_EMPRESA := _cEmpresa
				TMPC->XX_CONTRA  := TMPX2->C5_ESPECI1
				TMPC->XX_CLIENTE := TMPX2->A1_COD
				TMPC->XX_LOJA    := TMPX2->A1_LOJA
				TMPC->XX_NOMCLI  := TMPX2->A1_NOME
				TMPC->XX_DESC    := TMPX2->CTT_DESC01
			Else
				Reclock("TMPC",.F.)
			EndIf

			cCampo  := "TMPC->XX_F"+cMes
			&cCampo += TMPX2->MEDAVULSO

			// Totalizador do Gr�fico
			_nY := aScan(aTMensal, {|x| x[1] == cMes})
			//If _nY > 0
			aTMensal[_nY,4] += TMPX2->MEDAVULSO
			//EndIf

			TMPC->XX_TOTFAT += TMPX2->MEDAVULSO

			TMPC->(Msunlock())


			// Gravar total por cliente
			dbSelectArea("TMPD")
			If !MsSeek(TMPX2->A1_COD,.F.)
				Reclock("TMPD",.T.)
				TMPD->XX_CLIENTE := TMPX2->A1_COD
				TMPD->XX_NOMCLI  := TMPX2->A1_NOME
			Else
				Reclock("TMPD",.F.)
			EndIf
			TMPD->XX_TOTFAT += TMPX2->MEDAVULSO
			TMPD->(Msunlock())
			If TMPD->XX_TOTPRV > 0
				TMPD->XX_PERDIF := 100 - (TMPD->XX_TOTFAT * 100 / TMPD->XX_TOTPRV)
			EndIf

			TMPX2->(dbSkip())
		ENDDO
		TMPX2->(dbCloseArea())
*/


		//*********Inclus�o de NDCs
		/* Removido em 28/10/2019
		cQuery2 := "SELECT E1_XXCUSTO,E1_VALOR AS MEDAVULSO,A1_COD,A1_LOJA,A1_NOME,CTT_DESC01 FROM "+xRETSQLNAME("SE1")+" SE1" + CRLF
		cQuery2 += " INNER JOIN "+xRETSQLNAME("SA1")+" SA1 ON SE1.E1_CLIENTE = SA1.A1_COD" + CRLF
		cQuery2 += "  AND SE1.E1_LOJA = SA1.A1_LOJA  AND  SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '" + CRLF
		cQuery2 += " INNER  JOIN "+xRETSQLNAME("CTT")+" CTT ON SE1.E1_XXCUSTO = CTT.CTT_CUSTO AND CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '" + CRLF
		cQuery2 += " WHERE SE1.D_E_L_E_T_ = ' ' AND SE1.E1_TIPO='NDC' AND SE1.E1_XXCOMPE ='"+SUBSTR(cCompet,4,4)+SUBSTR(cCompet,1,2)+"'" + CRLF
		cQuery2 += " ORDER BY E1_NUM" 

		u_LogMemo("BKGCTR02-NDC.SQL",cQuery2)
				
		TCQUERY cQuery2 NEW ALIAS "TMPX2"
		
		dbSelectArea("TMPX2")
		TMPX2->(dbGoTop())
		DO While !TMPX2->(EOF())
			dbSelectArea("TMPC")
			If !TMPC->(MsSeek(_cEmpresa+TMPX2->E1_XXCUSTO,.F.))
				Reclock("TMPC",.T.)
				TMPC->XX_EMPRESA := _cEmpresa
				TMPC->XX_CONTRA  := TMPX2->E1_XXCUSTO
				TMPC->XX_CLIENTE := TMPX2->A1_COD
				TMPC->XX_LOJA    := TMPX2->A1_LOJA
				TMPC->XX_NOMCLI  := TMPX2->A1_NOME
				TMPC->XX_DESC    := TMPX2->CTT_DESC01
			Else
				Reclock("TMPC",.F.)
			EndIf

			cCampo  := "TMPC->XX_F"+cMes
			&cCampo += TMPX2->MEDAVULSO

		// Totalizador do Gr�fico
		_nY := aScan(aTMensal, {|x| x[1] == cMes})
		//If _nY > 0
			aTMensal[_nY,4] += TMPX2->MEDAVULSO
		//EndIf				  
								
			TMPC->XX_TOTFAT += TMPX2->MEDAVULSO	
			TMPC->(Msunlock())

			// Gravar total por cliente
			dbSelectArea("TMPD")
			If !MsSeek(TMPX2->A1_COD,.F.)
				Reclock("TMPD",.T.)
				TMPD->XX_CLIENTE := TMPX2->A1_COD
				TMPD->XX_NOMCLI  := TMPX2->A1_NOME
			Else
				Reclock("TMPD",.F.)
			EndIf
			TMPD->XX_TOTFAT += TMPX2->MEDAVULSO	
			TMPD->(Msunlock())
			If TMPD->XX_TOTPRV > 0
				TMPD->XX_PERDIF := 100 - (TMPD->XX_TOTFAT * 100 / TMPD->XX_TOTPRV)
			EndIf
			
		TMPX2->(dbSkip())
		ENDDO
		TMPX2->(dbCloseArea())
		*/

/*
	NEXT

Return
*/





// Substituir a fun��o padrao RESTSQLNAME
Static Function xRETSQLNAME(cAlias)
Return cAlias+_cEmpresa+"0"



Static Function GeraChart1(aTMensal,cArq,aTitulos)

	Local aHtml   := {}
	Local _nY     := 0
	Local aCabecH := {}
	Local cHtml   := ""
	Local _nZ     := 0

	aAdd(aHtml,"<html>")
	aAdd(aHtml,"  <head>")
	aAdd(aHtml,'    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>')
	aAdd(aHtml,'    <script type="text/javascript">')
	aAdd(aHtml,"      google.charts.load('current', {'packages':['corechart']});")
	aAdd(aHtml,"      google.charts.setOnLoadCallback(drawVisualization);")
	aAdd(aHtml,"")
	aAdd(aHtml,"      function drawVisualization() {")
	aAdd(aHtml,"        // Some raw data (not necessarily accurate)")
	aAdd(aHtml,"        var data = google.visualization.arrayToDataTable([")
	aAdd(aHtml,"          ['Mes', 'Contratado', 'Faturado', 'Contratado/Faturado',{type: 'string', role: 'annotation'}],")

	For _nY := 2 To Len(aTMensal)
		//aTMensal[_nY,5] := aTMensal[_nY,3] - aTMensal[_nY,4]     // Mostrar no gr�fico apenas a diferen�a
		//aTMensal[_nY,6] := ROUND((aTMensal[_nY,3] * 100 / aTMensal[_nY,4]) - 100,1)
		aAdd(aHtml,"          ['"+aTMensal[_nY,2]+"',"+ALLTRIM(STR(aTMensal[_nY,3],17,2))+","+ALLTRIM(STR(aTMensal[_nY,4],17,2))+","+ALLTRIM(STR(aTMensal[_nY,5],17,2))+",'"+ALLTRIM(STR(aTMensal[_nY,6],4,1))+"%'],")
	Next
//aAdd(aHtml,"          ['2004/05',  165,      938,         614.6],")
//aAdd(aHtml,"          ['2005/06',  135,      1120,        682],")
//aAdd(aHtml,"          ['2006/07',  157,      1167,        623],")
//aAdd(aHtml,"          ['2007/08',  139,      1110,        609.4],")
//aAdd(aHtml,"          ['2008/09',  136,      691,         569.6]")
	aAdd(aHtml,"        ]);")
	aAdd(aHtml,"")
	aAdd(aHtml,"        var options = {")
	aAdd(aHtml,"          title : '"+aTitulos[1]+"',")
	aAdd(aHtml,"          vAxis: {title: 'R$'},")
	aAdd(aHtml,"          hAxis: {title: 'Mes'},")
	aAdd(aHtml,"          seriesType: 'line',")
	aAdd(aHtml,"          series: {2: {type: 'bars'}}")
	aAdd(aHtml,"        };")
	aAdd(aHtml,"")
	aAdd(aHtml,"        var chart = new google.visualization.ComboChart(document.getElementById('chart_div'));")
	aAdd(aHtml,"        chart.draw(data, options);")
	aAdd(aHtml,"      }")
	aAdd(aHtml,"    </script>")
	aAdd(aHtml,"  </head>")
	aAdd(aHtml,"  <body>")
	aAdd(aHtml,'    <div id="chart_div" style="width: 900px; height: 500px;"></div>')
	aAdd(aHtml,"  </body>")
	aAdd(aHtml,"</html>")

	OpenHtml(cArq,aHtml)
	aCabecH := {"Codigo","Mes","Contratado","Faturado","Contratado/Faturado","%"}

	u_WaitLog(,{|| U_ArrToCsv(aTMensal,aCabecH,aTitulos[1],cProg+"-totais","\http")},"Aguarde","Gerando planilha...")

	FOR _nZ := 1 TO LEN(aHtml)
		cHtml += aHtml[_nZ]
	NEXT

Return cHtml




// Abre o Gr�fico no navegador Web
Static Function OpenHtml(cArq,aHtml)
	Local cDirHtml  := u_LTmpDir()
	Local cArqHtml  := cDirHtml+cArq+".html"
	Local aArea     := GetArea()
	Local nHandle   := 0
	Local cCrLf     := Chr(13) + Chr(10)
	Local _nI       := 0

	IF !EMPTY(cDirHtml)
		MakeDir(cDirHtml)
	ENDIF

	fErase(cArqHtml)

	nHandle := MsfCreate(cArqHtml,0)

	If nHandle > 0

		FOR _nI := 1 TO LEN(aHtml)
			fWrite(nHandle, aHtml[_nI] + cCrLf )
		NEXT

		fClose(nHandle)

		//ShellExecute("open", "http:\\vmsiga12:81\"+cArq+".html", "", "", 1)
		ShellExecute("open", cArqHtml, "", "", 1)

	EndIf

	RestArea(aArea)

Return



User Function ArrToCsv( _aPlan,_aCabs,_cTitulo,_cProg, _cDirHttp )

	Local nHandle
	Local cCrLf   := Chr(13) + Chr(10)
	Local _ni,_nj
	Local cPicN   := "@E 9999999999.999999"

	Local cArq       := ""
//Local cDir       := GetSrvProfString("Startpath","")
	Local cDirTmp    := u_LTmpDir()

	If !Empty(_cDirHttp)
		cDirTmp := _cDirHttp
	EndIf

	MakeDir(cDirTmp)

	cArq := cDirTmp+_cProg+".csv"
	fErase(cArq)

	nHandle := MsfCreate(cArq,0)

	If nHandle > 0

		IncProc("Gerando arquivo: "+cArq)

		FOR _nI := 1 TO LEN(_aCabs)
			fWrite(nHandle, _aCabs[_nI] + IIF(_nI < LEN(_aCabs),";",""))
		NEXT

		fWrite(nHandle, cCrLf ) // Pula linha

		For _nJ := 1 To Len(_aPlan)

			For _ni :=1 to LEN(_aPlan[_nJ])

				xCampo := _aPlan[_nJ,_nI]

				_uValor := ""

				If VALTYPE(xCampo) == "D" // Trata campos data
					_uValor := dtoc(xCampo)
				Elseif VALTYPE(xCampo) == "N" // Trata campos numericos
					_uValor := transform(xCampo,cPicN)
				Elseif VALTYPE(xCampo) == "C" // Trata campos caracter
					//IF LEN(ALLTRIM(xCampo)) > 250
					_uValor := OEMTOANSI(ALLTRIM(xCampo))
					//ELSE
					//	_uValor := '="'+OEMTOANSI(ALLTRIM(xCampo))+'"'
					//ENDIF
				Endif

				fWrite(nHandle, _uValor + IIF(_nI < Len(_aPlan[_nJ]),";",""))

			Next _nI

			fWrite(nHandle, cCrLf )

		Next _nJ

		fClose(nHandle)

		//IF MsgYesNo("Deseja abrir o arquivo "+cArq+" pelo aplicativo associado?")
		//   ShellExecute("open", cArq,"","",1)
		//ENDIF
	Else
		MsgAlert("Falha na cria��o do arquivo "+cArq)
	Endif

Return

// BKGCTR02.XLSM
/*
Private Sub Workbook_Open()
Call Macro1
End Sub

Sub Macro1()
Dim sFileName As String
Dim wkb As Workbook
Dim wst As Worksheet
Dim rng As Range
Dim cht As ChartObject
Dim sTit As String


 sFileName = Application.ThisWorkbook.Name

 sFileName = u_LTmpDir()+ Replace(sFileName, "xlsm", "xlsx")
 
 //MsgBox "Criando o gr�fico! " + sFileName
 
 Set wkb = Workbooks.Open(sFileName)
 
 Set wst = wkb.Worksheets("Resumo")
 
 wst.Select
  
 Set rng = wst.Range("dadosGrafico")
 
 wst.Range("posGrafico").Select

 'wst.Shapes.AddChart2(322, xlColumnClustered).Select
 
 Set cht = wst.ChartObjects.Add( _
    Left:=ActiveCell.Left, _
    Width:=450, _
    Top:=ActiveCell.Top, _
    Height:=250)
 
 cht.Chart.SetSourceData Source:=rng

 cht.Chart.ChartType = xlColumnClustered
 cht.Chart.FullSeriesCollection(1).ChartType = xlColumnClustered
 cht.Chart.FullSeriesCollection(2).ChartType = xlColumnClustered
 cht.Chart.FullSeriesCollection(3).ChartType = xlLine
 cht.Chart.FullSeriesCollection(4).ChartType = xlLine
 cht.Chart.PlotBy = xlColumns
 cht.Chart.PlotArea.Select
 cht.Chart.FullSeriesCollection(1).ChartType = xlLine
 cht.Chart.FullSeriesCollection(2).ChartType = xlLine
 cht.Chart.FullSeriesCollection(3).ChartType = xlColumnStacked
 cht.Chart.FullSeriesCollection(4).ChartType = xlColumnStacked
 cht.Chart.FullSeriesCollection(4).Select
 cht.Chart.FullSeriesCollection(4).ApplyDataLabels
 
 sTit = wst.Range("titGrafico").Value
 
 cht.Chart.HasTitle = True
 cht.Chart.ChartTitle.Text = sTit
 
  
 ActiveWorkbook.Close savechanges:=True
 
 Set wkb = Workbooks.Open(sFileName)
 
 ThisWorkbook.Close savechanges:=False
 
End Sub

*/
