#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKGCTR22
BK - Rentabilidade Contratos
@Return
@author Marcos Bispo Abrahão
@since 10/07/2024
@version P12
/*/

User Function BKGCTR22

/*
Local cDescricao	:= "Objetivo deste relatório é a emissão de relatório de acompanhamento das rentabilidades dos contratos "+CRLF+"Solicitado pelo Planejamento em junho de 2024."
Local cVersao 		:= "10/07/24 - Versão inicial"
Local oRExcel		AS Object
Local oPExcel		AS Object
*/
Local lRet			:= .T.

Private aParam		:= {}
Private cTitulo		:= "Rentabilidade Contratos"
Private cProg		:= "BKGCTR22"
Private cVersao		:= "10/09/24 - RExcel"
Private cDescr		:= "Rentabilidade Contratos (via PowerBk)"

Private cContrato   := SPACE(9)
Private dDataI		:= dDataBase
Private dDataF		:= dDataBase
Private nPeriodo    := 0
Private aAnoMes 	:= {}
Private aColMes		:= {}
Private nColIni		:= 8 // Quantidade de Colunas Iniciais antes dos valores
Private aMatriz 	:= {}
Private nMesRef		:= Month(Date())
Private nAnoRef		:= Year(Date())
Private cAMesRef	:= StrZero(nAnoRef,4)+StrZero(nMesRef,2)
Private cMAnoRef	:= StrZero(nMesRef,2)+"/"+StrZero(nAnoRef,4)

// Linhas do relatorio
// Linhas do Faturamento
Private nLinFatB	:= 0
Private nLinImp		:= 0
Private nLinIss		:= 0
Private nLinNDC 	:= 0
Private nLinFatL	:= 0
Private nLinDeAc	:= 0
// Linhas da FOlha
Private nLinProv	:= 0
Private nLinDesc	:= 0
Private nLinEnc		:= 0
Private nLinInc		:= 0
Private nLinPLR		:= 0
Private nLinSInc	:= 0
Private nLinVTP		:= 0
Private nLinVTV		:= 0
Private nLinVRVA	:= 0
Private nLinVRVAV	:= 0
Private nLinAsMed	:= 0
Private nLinAsMedV	:= 0
Private nLinSinoP	:= 0
Private nLinSinoV 	:=0

// Variaveis de Calculo Excel
Private cColsP	:= ""
Private cColsR	:= ""
Private cColAP	:= ""
Private cColAR	:= ""
Private cColPR 	:= ""
Private cColsPR	:= ""

aAdd( aParam, { 1, "Contrato:" 	, cContrato	, ""    , ""                                       , "CTT", "", 70, .T. })
aAdd( aParam, { 1, "Mes ref."   , nMesRef   ,"99"   , "mv_par02 > 0 .AND. mv_par02 <= 12"      , ""   , "", 20, .T. })
aAdd( aParam, { 1, "Ano ref."   , nAnoRef   ,"9999" , "mv_par03 >= 2010 .AND. mv_par03 <= 2040", ""   , "", 20, .T. })

If !BkPar()
	Return .F.
EndIf

u_WaitLog(cProg, {|| lRet := PrcPer() },"Definindo período...")

If lRet
	u_WaitLog(cProg, {|| lRet := PrcMatriz() }	,"Inicializando a matriz...")
	u_WaitLog(cProg, {|| lRet := PrcFat() }		,"Dados de Faturamento...")
	u_WaitLog(cProg, {|| lRet := PrcFol() }		,"Dados de Folha...")
	u_WaitLog(cProg, {|| lRet := PrcGastos() }	,"Dados de Despesas...")
EndIf

If lRet
	u_WaitLog(cProg, {|| lRet := PrcPlan() }	,"Construindo a planilha...")
EndIf

u_MsgLog(cProg,"Nova Rentabilidade Contrato está em fase de desenvolvimento, envie Sugestões!!","S")

Return lRet


Static Function BkPar
Local aRet  :=	{}
Local lRet  := .F.

//   Parambox(aParametros,@cTitle          ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cProg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cProg,.T.         ,.T.))
	lRet := .T.
	cContrato	:= mv_par01
	nMesRef 	:= mv_par02
	nAnoRef		:= mv_par03

	cAMesRef	:= StrZero(nAnoRef,4)+StrZero(nMesRef,2)
	cMAnoRef	:= StrZero(nMesRef,2)+"/"+StrZero(nAnoRef,4)
Endif
Return lRet


Static Function PrcPer
Local cQuery := ""
Local dAux   := Date()
Local lRet	 := .T.
Local nPer	 := 0
Local cAnoMes:= ""

cQuery := "SELECT TOP 1" + CRLF
cQuery += "   MIN(CN9_DTOSER) AS CN9_DTOSER" + CRLF
cQuery += "  ,MIN(CN9_DTINIC) AS CN9_DTINIC" + CRLF
cQuery += "  ,MIN(CNF_DTVENC) AS CNF_INICIO" + CRLF
cQuery += "  ,MAX(CNF_DTVENC) AS CNF_FIM" + CRLF
cQuery += "  ,CN9_SITUAC" + CRLF
cQuery += "  ,CN9_REVISA" + CRLF
cQuery += "  ,MAX(CN9_XXDVIG) AS CN9_XXDVIG" + CRLF
cQuery += "  ,MAX((SUBSTRING(CNF_COMPET,4,4))+SUBSTRING(CNF_COMPET,1,2))+'01' AS MAXCOMPET" + CRLF
cQuery += " FROM "+RETSQLNAME("CNF")+" CNF" + CRLF
cQuery += " INNER JOIN "+RETSQLNAME("CN9") + " CN9 ON " + CRLF
cQuery += "    CN9_NUMERO = CNF_CONTRA " + CRLF
cQuery += "    AND CN9_REVISA = CNF_REVISA " + CRLF
cQuery += "    AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''" + CRLF
cQuery += " WHERE CNF.D_E_L_E_T_=''" + CRLF
cQuery += "    AND CNF_CONTRA ='"+ALLTRIM(cContrato)+"'" + CRLF
cQuery += " GROUP BY CN9_REVISA,CN9_SITUAC" + CRLF
cQuery += " ORDER BY CN9_REVISA DESC" + CRLF

u_LogTxt(cProg+".SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP1",.T.,.T.)

TCSETFIELD("QTMP1","CNF_INICIO","D",8,0)
TCSETFIELD("QTMP1","CNF_FIM"   ,"D",8,0)
TCSETFIELD("QTMP1","CN9_DTINIC","D",8,0)
TCSETFIELD("QTMP1","CN9_DTOSER","D",8,0)
TCSETFIELD("QTMP1","CN9_XXDVIG","D",8,0)

dbSelectArea("QTMP1")

// Calculo das datas iniciais e finais

dDataI		:= QTMP1->CN9_DTOSER
If Empty(dDataI)
	dDataI	:= QTMP1->CN9_DTINIC
EndIf
If !Empty(QTMP1->CNF_INICIO) .AND. QTMP1->CNF_INICIO < dDataI
	dDataI	:= QTMP1->CNF_INICIO
EndIf

dDataF  := QTMP1->CN9_XXDVIG
If QTMP1->CNF_FIM > dDataF
	dDataF	:= QTMP1->CNF_FIM
EndIf

dAux  := STOD(QTMP1->MAXCOMPET)
If dAux > dDataF
	dDataF := dAux
EndIf

If EMPTY(DTOS(dDataI)) .OR. EMPTY(DTOS(dDataF))
	u_MsgLog(cProg,"Contrato "+cContrato+" não encontrado!!","E")
	lRet := .F.
Else
	// Voltar 1 mes na data inicial (lançamentos pré contrato)
	dDataI := dDataI - Day(dDataI)
	dDataI := dDataI - Day(dDataI)+1

	// Ultimo dia do mes do fim do contrato
	dDataF := LastDay(dDataF)

	//Determina quantos Meses utilizar no calculo
	nPeriodo := DateDiffMonth( dDataI , dDataF ) + 1

	// Cria o array com o periodo
	dAux := dDataI
	For nPer := 1 To nPeriodo

		cAnoMes := StrZero(Year(dAux),4)+StrZero(Month(dAux),2)

		aAdd(aAnoMes,cAnoMes)

		aAdd(aColMes,"P"+cAnoMes)
		aAdd(aColMes,"R"+cAnoMes)

		dAux := MonthSum(dAux,1)
	Next
EndIf

QTMP1->(Dbclosearea())

Return lRet


// Cria a Matriz geral do Relatório
Static Function PrcMatriz
Local nI 		:= 0
Local cFormula	:= ""

// Criação das fórmulas de soma do previsto e realizado até o mes de ref
cColsP := cColsR:= "'="
For nI := 1 To Len(aColMes)
	cCol := aColMes[nI]
	If SUBSTR(cCol,2,6) <= cAMesRef

		// Mes Atual
		If SUBSTR(cCol,2,6) == cAMesRef
			If "P" $ cCol
				cColAP := "'=##"+cCol+"##'"
			Else
				cColAR := "'=##"+cCol+"##'"
			EndIf
		EndIf

		// Soma dos meses
		If "P" $ cCol
			If "##" $ cColsP
				cColsP += "+"
			EndIf
			cColsP += "##"+cCol+"##"
		Else
			If "##" $ cColsR
				cColsR += "+"
			EndIf
			cColsR += "##"+cCol+"##"
		EndIf
	EndIf
Next
cColsP += "'"
cColsR += "'"

cColPR  := "'=IFERROR(#!REALMES,0#! / #!PREVMES,0#!,0)'"
cColsPR := "'=IFERROR(#!TOTREAL,0#! / #!TOTPREV,0#!,0)'"

// Linha vazia
IncVazia()

// Linha de Faturamento Bruto
nLinFatB := IncLin("03" ,"FATURAMENTO BRUTO",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)

// Linha vazia
IncVazia()

// Impostos e Contribuições
nLinImp := IncLin("04" ,"(-) Impostos e Contribuições",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)
// ISS
nLinIss := IncLin("05" ,"(-) ISS",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)

// Descontos / Acrescimos
nLinDeAc := IncLin("06" ,"(-) Descontos (+) Acrescimos",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)

// Linha vazia
IncVazia()

// Linha de Faturamento Liquido
cFormula := "'= #!0,nLinFatB#! + #!0,nLinImp#! + #!0,nLinISS#! + #!0,nLinDeAc#!'"
nLinFatL := IncLin("07" ,"FATURAMENTO LIQUIDO",cFormula,cFormula,cColPR,cFormula,cFormula,cColsPR,cFormula,cFormula)

// Linha vazia
IncVazia()

// Linha vazia
IncVazia("FOLHA")

nLinProv	:= IncLin("09" ,"PROVENTOS",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)
nLinDesc	:= IncLin(""   ,"DESCONTOS",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)
nLinEnc	 	:= IncLin("10" ,"ENCARGOS",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)
nLinInc	 	:= IncLin("11" ,"INCIDENCIAS",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)
nLinPLR	 	:= IncLin("110","PLR",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)
nLinSInc 	:= IncLin("111","VERBAS SEM ENCARGOS/INCIDENCIAS",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)
nLinVTP 	:= IncLin("12" ,"VT",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)
nLinVTV 	:= IncLin("13" ,"(-) Recuperação de VT",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)
nLinVRVA 	:= IncLin("14" ,"VR/VA",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)
nLinVRVAV 	:= IncLin("15" ,"(-) Recuperação de VR/VA",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)
nLinAsMed 	:= IncLin("16" ,"ASSISTENCIA MEDICA",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)
nLinAsMedV 	:= IncLin("17" ,"(-) Recuperação de ASSISTENCIA MEDICA",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)
nLinSinoP 	:= IncLin("18" , "Sindicato (Odonto)",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)
nLinSinoV 	:= IncLin("19" ,"(-) Recuperação de Sindicato (Odonto)",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)


// Linha vazia
IncVazia()

// Linha vazia
IncVazia("GASTOS GERAIS")

nLinNDC		:= IncLin("30-3" ,"NDC",cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)

Return .T.



// Montar os valores iniciais das linhas
Static Function IncLin(cChave,cDescr,cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,xColPPer,xColRPer)
Local nI := 0
Local aLinha := {}

// Chave
aAdd(aLinha,cChave)
// Descrição
aAdd(aLinha,cDescr)

// Previsto Mes
aAdd(aLinha,cColAP)
// Realizado Mes
aAdd(aLinha,cColAR)
// Realizado / Previsto Mes
aAdd(aLinha,cColPR)

// Total Previsto
aAdd(aLinha,cColsP)
// Total Realizado
aAdd(aLinha,cColsR)
// Total Realizado / Previsto
aAdd(aLinha,cColsPR)

/// Campos de Previsto e relizado por mês
For nI := 1 To nPeriodo
	// Previsto
	aAdd(aLinha,xColPPer)
	// Realizado
	aAdd(aLinha,xColRPer)
Next

aAdd(aMatriz,aLinha)

Return Len(aMatriz)


// Montar os valores iniciais das linhas
Static Function IncVazia(cDescr)
Local nI := 0
Local aLinha	:= {}
Default cDescr	:= ""

// Chave
aAdd(aLinha,"")
// Descrição
aAdd(aLinha,cDescr)

// Previsto Mes
aAdd(aLinha,"")
// Realizado Mes
aAdd(aLinha,"")
// Realizado / Previsto Mes
aAdd(aLinha,"")

// Total Previsto
aAdd(aLinha,"")
// Total Realizado
aAdd(aLinha,"")
// Total Realizado / Previsto
aAdd(aLinha,"")


// Campos de Previsto e relizado por mês
For nI := 1 To nPeriodo
	// Previsto
	aAdd(aLinha,"")
	// Realizado
	aAdd(aLinha,"")
Next

aAdd(aMatriz,aLinha)

Return




#DEFINE FAT_EMPRESA			1
#DEFINE FAT_CONTRATO		2
#DEFINE FAT_COMPETAM		3
#DEFINE FAT_VALPREV			4
#DEFINE FAT_VALFAT			5
#DEFINE FAT_VALISS			6
#DEFINE FAT_DESC			7
#DEFINE FAT_ACRES			8


// Faturamento
Static Function PrcFat

Local lRet 			:= .T.
Local nX 			:= 0
Local cQuery 		:= ""
Local nCol 			:= 0
Local cAnoMes 		:= ""
Local nMImp			:= 0
Local aReturn       := {}
Local aBinds        := {}
Local aSetFields    := {}
Local nRet          := 0
Local cFormula 		:= ""

//SELECT CONTRATO,COMPETAM,SUM(VALFAT),SUM(CXN_VLPREV) FROM FATURAMENTO WHERE CONTRATO = 386000609 GROUP BY CONTRATO,COMPETAM ORDER BY CONTRATO,COMPETAM

cQuery := " SELECT " + CRLF
cQuery += "   EMPRESA" + CRLF
cQuery += "  ,CONTRATO" + CRLF
cQuery += "  ,COMPETAM" + CRLF
cQuery += "  ,SUM(CXN_VLPREV) AS VALPREV" + CRLF
cQuery += "  ,SUM(F2_VALFAT)  AS VALFAT" + CRLF
cQuery += "  ,SUM(F2_VALISS+E1_XXISSBI+F2_VLCPM) AS VALISS" + CRLF
cQuery += "  ,SUM(XX_E5DESC)  AS E5DESC" + CRLF
cQuery += "  ,SUM(XX_E5MULTA) AS E5MULTA" + CRLF
cQuery += " FROM PowerBk.dbo.FATURAMENTO" + CRLF
cQuery += " WHERE CONTRATO = ? " + CRLF
cQuery += " GROUP BY EMPRESA,CONTRATO,COMPETAM" + CRLF
cQuery += " ORDER BY EMPRESA,CONTRATO,COMPETAM" + CRLF

aAdd(aBinds,cContrato)

// Ajustes de tratamento de retorno
aadd(aSetFields,{"EMPRESA"	,"C",  2,0})
aadd(aSetFields,{"CONTRATO"	,"C",  9,0})
aadd(aSetFields,{"COMPETAM"	,"C",  6,0})
aadd(aSetFields,{"VALPREV"	,"N", 14,2})
aadd(aSetFields,{"VALFAT"	,"N", 14,2})
aadd(aSetFields,{"VALISS"	,"N", 14,2})
aadd(aSetFields,{"E5DESC"	,"N", 14,2})
aadd(aSetFields,{"E5MULTA"	,"N", 14,2})

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

u_LogTxt(cProg+".SQL",cQuery,aBinds)

If nRet < 0
	lRet := .F.
	u_MsgLog(cProg,TCSqlError()+" - Falha ao executar a Query: "+cQuery,"E")
Else

	For nX := 1 TO LEN(aReturn)
		cAnoMes := aReturn[nX,FAT_COMPETAM]
		nCol    := Ascan(aColMes,"P"+cAnoMes)
		nMImp	:= u_MVNMIMPC(aReturn[nX,FAT_EMPRESA],cAnoMes)

		If nCol > 0
			// Valor Previsto
			aMatriz[nLinFatB,nCol+nColIni] += aReturn[nX,FAT_VALPREV]
			// Impostos
			//cFormula:= "'=-"+cValToChar(nMImp)+"% * #!0,-1#!'"  
			cFormula:= "'=-"+cValToChar(nMImp)+"% * #!0,nLinFatB#!'"  
			aMatriz[nLinImp,nCol+nColIni] := cFormula

			// ISS
			cFormula:= "'=IFERROR(#!1,0#! / #!1,nLinFatB#! * #!0,nLinFatB#!,0)'"  //=+K6/K4*J4
			aMatriz[nLinIss,nCol+nColIni] := cFormula

		Else
			lRet := .F.
		EndIf

		nCol    := Ascan(aColMes,"R"+cAnoMes)
		If nCol > 0
			// Valor Realizado
			aMatriz[nLinFatB,nCol+nColIni] += aReturn[nX,FAT_VALFAT]
			// Impostos
			//cFormula:= "'=-"+cValToChar(nMImp)+"% * "+ cValToChar(aMatriz[nLinFatB,nCol+nColIni])+"'"
			cFormula:= "'=-"+cValToChar(nMImp)+"% * #!0,nLinFatB#!'"    //+ cValToChar(aMatriz[nLinFatB,nCol+nColIni])+"'"
			aMatriz[nLinImp,nCol+nColIni] := cFormula

			// ISS
			aMatriz[nLinIss,nCol+nColIni] -= aReturn[nX,FAT_VALISS]

			// Descontos / Acrescimos
			aMatriz[nLinDeAc,nCol+nColIni] += aReturn[nX,FAT_ACRES] - aReturn[nX,FAT_DESC]

		Else
			lRet := .F.
		EndIf
	Next

Endif

Return lRet

#DEFINE GG_EMPRESA			1
#DEFINE GG_CONTRATO			2
#DEFINE GG_COMPETAM			3
#DEFINE GG_ORIGEM			4
#DEFINE GG_D1_COD			5
#DEFINE GG_B1_DESC			6
#DEFINE GG_B1_GRUPO			7
#DEFINE GG_BM_DESC			8

#DEFINE GG_ZI_COD			9
#DEFINE GG_ZI_DESC			10
#DEFINE GG_DESPESA			11

// Gastos Gerais
Static Function PrcGastos

Local lRet 			:= .T.
Local nX 			:= 0
Local cQuery 		:= ""
Local nCol 			:= 0
Local cAnoMes 		:= ""

Local cOrigem		:= ""
Local cD1_Cod		:= ""
Local cB1_Grupo		:= ""
Local cZI_Cod		:= ""
Local cDesc			:= ""
Local nDespesa		:= 0
Local cChave		:= ""
Local nChave 		:= 0

Local aReturn       := {}
Local aBinds        := {}
Local aSetFields    := {}
Local nRet          := 0

cQuery := " SELECT " + CRLF
cQuery += "   EMPRESA" + CRLF
cQuery += "  ,CONTRATO" + CRLF
cQuery += "  ,COMPETAM" + CRLF
cQuery += "  ,ORIGEM" + CRLF
cQuery += "  ,D1_COD" + CRLF
cQuery += "  ,B1_DESC" + CRLF
cQuery += "  ,B1_GRUPO" + CRLF
cQuery += "  ,BM_DESC" + CRLF
cQuery += "  ,ZI_COD" + CRLF
cQuery += "  ,ZI_DESC" + CRLF
cQuery += "  ,SUM(DESPESA) AS DESPESA" + CRLF
cQuery += " FROM PowerBk.dbo.GASTOSGERAIS" + CRLF
cQuery += " WHERE CONTRATO = ? " + CRLF
cQuery += " GROUP BY EMPRESA,CONTRATO,COMPETAM,ORIGEM,D1_COD,B1_DESC,B1_GRUPO,BM_DESC,ZI_COD,ZI_DESC" + CRLF
cQuery += " ORDER BY ZI_DESC,B1_DESC" + CRLF
//cQuery += " ORDER BY EMPRESA,CONTRATO,COMPETAM,ORIGEM,D1_COD,B1_DESC,B1_GRUPO,BM_DESC,ZI_COD,ZI_DESC" + CRLF

aAdd(aBinds,cContrato)

// Ajustes de tratamento de retorno
aadd(aSetFields,{"EMPRESA"	,"C",  2,0})
aadd(aSetFields,{"CONTRATO"	,"C",  9,0})
aadd(aSetFields,{"COMPETAM"	,"C",  6,0})
aadd(aSetFields,{"ORIGEM"	,"C",  7,0})
aadd(aSetFields,{"D1_COD"	,"C", 15,0})
aadd(aSetFields,{"B1_DESC"	,"C", 60,0})
aadd(aSetFields,{"B1_GRUPO"	,"C",  4,0})
aadd(aSetFields,{"BM_DESC"	,"C", 30,0})
aadd(aSetFields,{"ZI_COD"	,"C",  4,0})
aadd(aSetFields,{"ZI_DESC"	,"C", 40,0})
aadd(aSetFields,{"DESPESA"	,"N", 14,2})

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

u_LogTxt(cProg+".SQL",cQuery,aBinds)

If nRet < 0
	lRet := .F.
	u_MsgLog(cProg,TCSqlError()+" - Falha ao executar a Query: "+cQuery,"E")
Else

	For nX := 1 TO LEN(aReturn)
		cAnoMes 	:= aReturn[nX,GG_COMPETAM]
		nCol    	:= Ascan(aColMes,"P"+cAnoMes)
		cOrigem		:= aReturn[nX,GG_ORIGEM]
		cD1_Cod		:= aReturn[nX,GG_D1_COD]
		cB1_Grupo	:= aReturn[nX,GG_B1_GRUPO]
		cZI_Cod		:= aReturn[nX,GG_ZI_COD]
		cDesc 		:= Iif(Empty(cZI_Cod),aReturn[nX,GG_B1_DESC],aReturn[nX,GG_ZI_DESC])
		nDespesa	:= aReturn[nX,GG_DESPESA]
		cChave		:= TRIM(cOrigem+Iif(Empty(cZI_Cod),cD1_Cod,cZI_Cod))
		If TRIM(cD1_Cod ) == '12' // VT
			cChave := '12'
		ElseIf TRIM(cD1_Cod ) == '14' // VR/VA
			cChave := '14'
		EndIf

		nChave 		:= Ascan(aMatriz,{|x| TRIM(x[1]) == cChave})

		If nChave == 0
			nChave := IncLin(cChave,cDesc,cColAP,cColAR,cColPR,cColsP,cColsR,cColsPR,0,0)
		EndIf

		If nCol > 0
			// Valor Previsto
			//aMatriz[nChave,nCol+nColIni] += aReturn[nX,GG_xxxx]
		Else
			//lRet := .F.
		EndIf

		nCol    := Ascan(aColMes,"R"+cAnoMes)
		If nCol > 0
			// Valor da Despesa
			aMatriz[nChave,nCol+nColIni] -= aReturn[nX,GG_DESPESA]
		Else
			//lRet := .F.
		EndIf
	Next

Endif

Return lRet



#DEFINE FOL_COMPETAM		1
#DEFINE FOL_CHAVEZG			2
#DEFINE FOL_PROVENTOS		3
#DEFINE FOL_DESCONTOS		4
#DEFINE FOL_PLR				5
#DEFINE FOL_VTPROV			6
#DEFINE FOL_VTVER 			7
#DEFINE FOL_VRVAV 			8
#DEFINE FOL_ASSMP 			9
#DEFINE FOL_ASSMV 			10
#DEFINE FOL_SINOP 			11
#DEFINE FOL_SINOV 			12
#DEFINE FOL_SEMINC			13
#DEFINE FOL_PENCARGOS		14
#DEFINE FOL_PINCIDENCIAS	15	
#DEFINE FOL_VALASSOD		16
#DEFINE FOL_ENCARGOS		17
#DEFINE FOL_INCIDENCIAS		18
#DEFINE FOL_CUSTO 			19
#DEFINE FOL_CUSTOSE			20

// Folha
Static Function PrcFol

Local lRet 			:= .T.
Local nX 			:= 0
Local cQuery 		:= ""
Local nCol 			:= 0
Local cAnoMes 		:= ""
Local aReturn       := {}
Local aBinds        := {}
Local aSetFields    := {}
Local nRet          := 0

cQuery := " SELECT " + CRLF
cQuery += "   COMPETAM" + CRLF
cQuery += "  ,MAX(CHAVEZG) AS CHAVEZG" + CRLF
cQuery += "  ,SUM(PROVENTOS) AS PROVENTOS" + CRLF
cQuery += "  ,SUM(DESCONTOS) AS DESCONTOS" + CRLF
cQuery += "  ,SUM(PLR) AS PLR" + CRLF
cQuery += "  ,SUM(VTPROV) AS VTPROV" + CRLF
cQuery += "  ,SUM(VTVER) AS VTVER" + CRLF
cQuery += "  ,SUM(VRVAV) AS VRVAV" + CRLF
cQuery += "  ,SUM(ASSMP) AS ASSMP" + CRLF
cQuery += "  ,SUM(ASSMV) AS ASSMV" + CRLF
cQuery += "  ,SUM(SINOP) AS SINOP" + CRLF
cQuery += "  ,SUM(SINOV) AS SINOV" + CRLF
cQuery += "  ,SUM(SEMINC) AS SEMINC" + CRLF
cQuery += "  ,SUM(PENCARGOS) AS PENCARGOS" + CRLF
cQuery += "  ,SUM(PINCIDENCIAS) AS PINCIDENCIAS" + CRLF
cQuery += "  ,SUM(VALASSOD) AS VALASSOD" + CRLF
cQuery += "  ,SUM(ENCARGOS) AS ENCARGOS" + CRLF
cQuery += "  ,SUM(INCIDENCIAS) AS INCIDENCIAS" + CRLF
cQuery += "  ,SUM(CUSTO) AS CUSTO" + CRLF
cQuery += "  ,SUM(CUSTOSE) AS CUSTOSE" + CRLF

cQuery += " FROM PowerBk.dbo.FOLHA" + CRLF
cQuery += " WHERE CONTRATO = ? " + CRLF
cQuery += " GROUP BY COMPETAM" + CRLF
cQuery += " ORDER BY COMPETAM" + CRLF

aAdd(aBinds,cContrato)

// Ajustes de tratamento de retorno
aadd(aSetFields,{"EMPRESA"	,"C",  2,0})
aadd(aSetFields,{"CONTRATO"	,"C",  9,0})
aadd(aSetFields,{"COMPETAM"	,"C",  6,0})
aadd(aSetFields,{"VALPREV"	,"N", 14,2})
aadd(aSetFields,{"VALFAT"	,"N", 14,2})
aadd(aSetFields,{"VALISS"	,"N", 14,2})

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

u_LogTxt(cProg+".SQL",cQuery,aBinds)

If nRet < 0
	lRet := .F.
	u_MsgLog(cProg,TCSqlError()+" - Falha ao executar a Query: "+cQuery,"E")
Else

	For nX := 1 TO LEN(aReturn)
		cAnoMes := aReturn[nX,FOL_COMPETAM]
		nCol    := Ascan(aColMes,"P"+cAnoMes)

		If nCol > 0
			// Valor Previsto
			//aMatriz[nLinProv,nCol+nColIni] += aReturn[nX,FOL_PROVENTOS]

		Else
			lRet := .F.
		EndIf

		nCol    := Ascan(aColMes,"R"+cAnoMes)
		If nCol > 0
			// Valor Realizado
			aMatriz[nLinProv  ,nCol+nColIni] -= aReturn[nX,FOL_PROVENTOS]
			aMatriz[nLinDesc  ,nCol+nColIni] += aReturn[nX,FOL_DESCONTOS]
			aMatriz[nLinEnc   ,nCol+nColIni] -= aReturn[nX,FOL_ENCARGOS]
			aMatriz[nLinInc   ,nCol+nColIni] -= aReturn[nX,FOL_INCIDENCIAS]
			aMatriz[nLinPLR   ,nCol+nColIni] -= aReturn[nX,FOL_PLR]
			aMatriz[nLinSInc  ,nCol+nColIni] -= aReturn[nX,FOL_SEMINC]
			aMatriz[nLinVTP   ,nCol+nColIni] -= aReturn[nX,FOL_VTPROV]
			aMatriz[nLinVTV   ,nCol+nColIni] -= aReturn[nX,FOL_VTVER]
				// VA/VR - está em Despesas
			aMatriz[nLinVRVAV ,nCol+nColIni] -= aReturn[nX,FOL_VRVAV]
				// ASSMED - está em Despesas
			aMatriz[nLinAsMedV,nCol+nColIni] -= aReturn[nX,FOL_ASSMV]
			aMatriz[nLinSinoP ,nCol+nColIni] -= aReturn[nX,FOL_SINOP]
			aMatriz[nLinSinoV ,nCol+nColIni] -= aReturn[nX,FOL_SINOV]

		Else
			lRet := .F.
		EndIf
	Next

Endif

Return lRet


Static Function PrcPlan()
Local nI 		:= 0
Local cCol 		:= ""
Local cCab		:= ""
Local cTitPlan  := ""

// Definição do Arq Excel
oRExcel := RExcel():New(cProg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetVersao(cVersao)
oRExcel:SetDescr(cDescr)
oRExcel:SetParam(aParam)

// Definição da Planilha 1
oPExcel:= PExcel():New(cProg,aMatriz)

// Colunas da Planilha 1
oPExcel:AddCol("CHAVE","","Chave","")
oPExcel:GetCol("CHAVE"):SetTamCol(10)

oPExcel:AddCol("DESCRICAO","","Descricao","")
oPExcel:GetCol("DESCRICAO"):SetTamCol(50)

oPExcel:AddCol("PREVMES","","Previsto em "+cMAnoRef,"")
oPExcel:GetCol("PREVMES"):SetTipo("FN")
//oPExcel:GetCol("PREVMES"):SetTotal(.T.)

oPExcel:AddCol("REALMES","","Realizado em "+cMAnoRef,"")
oPExcel:GetCol("REALMES"):SetTipo("FN")
//oPExcel:GetCol("REALMES"):SetTotal(.T.)

oPExcel:AddCol("MPREVREAL","","Previsto / Realizado em "+cMAnoRef,"")
oPExcel:GetCol("MPREVREAL"):SetTipo("FP")
//oPExcel:GetCol("MPREVREAL"):SetTotal(.F.)

oPExcel:AddCol("TOTPREV","","Total Previsto até "+cMAnoRef,"")
oPExcel:GetCol("TOTPREV"):SetTipo("FN")
//oPExcel:GetCol("TOTPREV"):SetTotal(.T.)

oPExcel:AddCol("TOTREAL","","Total Realizado até "+cMAnoRef,"")
oPExcel:GetCol("TOTREAL"):SetTipo("FN")
//oPExcel:GetCol("TOTREAL"):SetTotal(.T.)

oPExcel:AddCol("PPREVREAL","","Previsto / Realizado até "+cMAnoRef,"")
oPExcel:GetCol("PPREVREAL"):SetTipo("FP")
//oPExcel:GetCol("PPREVREAL"):SetTotal(.F.)

For nI := 1 To Len(aColMes)
	cCol := aColMes[nI]
	If "P" $ cCol
		cCab := "Previsto "+SUBSTR(aColMes[nI],6,2)+"/"+SUBSTR(aColMes[nI],2,4)
	Else
		cCab := "Realizado "+SUBSTR(aColMes[nI],6,2)+"/"+SUBSTR(aColMes[nI],2,4)
	EndIf
	oPExcel:AddCol(cCol,"",cCab,"")
	oPExcel:GetCol(cCol):SetTipo("FN")	
	//oPExcel:GetCol(cCol):SetTotal(.T.)
	oPExcel:GetCol(cCol):SetDecimal(2)
Next

// Adiciona a planilha 1
oRExcel:AddPlan(oPExcel)

cTitPlan := "Contrato: "+cContrato+" - "+Posicione("CTT",1,xFilial("CTT")+cContrato,"CTT_DESC01")+" "+CRLF
cTitPlan += "Cliente : "+Posicione("CN9",8,xFilial("CN9")+Pad(cContrato,TamSx3("CN9_NUMERO")[1])+"   ","CN9_NOMCLI") // cn9_numer+cn9_revatu

oPExcel:SetTitulo(cTitPlan)

// Cria arquivo Excel
oRExcel:Create()

Return Nil
