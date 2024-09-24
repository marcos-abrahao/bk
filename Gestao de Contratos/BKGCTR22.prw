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
Private nColIni		:= 3 // Quantidade de Colunas Iniciais antes dos valores
Private aMatriz 	:= {}
Private nMesRef		:= Month(Date())
Private nAnoRef		:= Year(Date())
Private cAMesRef	:= StrZero(nAnoRef,4)+StrZero(nMesRef,2)
Private cMAnoRef	:= StrZero(nMesRef,2)+"/"+StrZero(nAnoRef,4)

// Linhas do relatorio
Private nLinFat		:= 0
Private nLinImp		:= 0

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
EndIf

If lRet
	u_WaitLog(cProg, {|| lRet := PrcPlan() }	,"Construindo a planilha...")
EndIf

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
Local aLinha	:= {}


////// Linha de Faturamento----------------- 
aLinha	:= {}
aAdd(aLinha,cContrato)
// Chave
aAdd(aLinha,"03")
// Descrição
aAdd(aLinha,"FATURAMENTO OFICIAL")
// Total Previsto
aAdd(aLinha,0)
// Total Realizado
aAdd(aLinha,0)

// Campos de Previsto e relizado por mês
IncPer(aLinha)
aAdd(aMatriz,aLinha)
nLinFat := Len(aMatriz)
////// -------------------------------------

// Impostos e Contribuições
aLinha	:= {}
aAdd(aLinha,cContrato)
// Chave
aAdd(aLinha,"04")
// Descrição
aAdd(aLinha,"(-) Impostos e Contribuições")
// Total Previsto
aAdd(aLinha,0)
// Total Realizado
aAdd(aLinha,0)

// Campos de Previsto e relizado por mês
IncPer(aLinha)
aAdd(aMatriz,aLinha)
nLinImp := Len(aMatriz)




Return .T.

// Montar os valores iniciais das linhas
Static Function IncPer(aLinha)
Local nI := 0
For nI := 1 To nPeriodo
	// Previsto
	aAdd(aLinha,0)
	// Realizado
	aAdd(aLinha,0)
Next
Return



#DEFINE FAT_CONTRATO		1
#DEFINE FAT_COMPETAM		2
#DEFINE FAT_VALPREV			3
#DEFINE FAT_VALFAT			4

Static Function PrcFat

Local lRet 			:= .T.
Local nX 			:= 0
Local cQuery 		:= ""
Local nCol 			:= 0
Local cAnoMes 		:= ""

Local aReturn       := {}
Local aBinds        := {}
Local aSetFields    := {}
Local nRet          := 0

//SELECT CONTRATO,COMPETAM,SUM(VALFAT),SUM(CXN_VLPREV) FROM FATURAMENTO WHERE CONTRATO = 386000609 GROUP BY CONTRATO,COMPETAM ORDER BY CONTRATO,COMPETAM

cQuery := " SELECT " + CRLF
cQuery += "   CONTRATO" + CRLF
cQuery += "  ,COMPETAM" + CRLF
cQuery += "  ,SUM(CXN_VLPREV) AS VALPREV" + CRLF
cQuery += "  ,SUM(VALFAT) AS VALFAT" + CRLF
cQuery += " FROM PowerBk.dbo.FATURAMENTO" + CRLF
cQuery += " WHERE CONTRATO = ? " + CRLF
cQuery += " GROUP BY CONTRATO,COMPETAM" + CRLF
cQuery += " ORDER BY CONTRATO,COMPETAM" + CRLF

aAdd(aBinds,cContrato)

// Ajustes de tratamento de retorno
aadd(aSetFields,{"CONTRATO"	,"C",  9,0})
aadd(aSetFields,{"COMPETAM"	,"C",  6,0})
aadd(aSetFields,{"VALPREV"	,"N", 14,2})
aadd(aSetFields,{"VALFAT"	,"N", 14,2})

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

u_LogTxt(cProg+".SQL",cQuery,aBinds)

If nRet < 0
	lRet := .F.
	u_MsgLog(cProg,TCSqlError()+" - Falha ao executar a Query: "+cQuery,"E")
Else

	For nX := 1 TO LEN(aReturn)
		cAnoMes := aReturn[nX,FAT_COMPETAM]
		nCol    := Ascan(aColMes,"P"+cAnoMes)
		If nCol > 0
			aMatriz[nLinFat,nCol+nColIni] += aReturn[nX,FAT_VALPREV]
			aMatriz[nLinImp,nCol+nColIni] := "'= 8 * "+ cValToChar(aMatriz[nLinFat,nCol+nColIni])+"'"
		Else
			lRet := .F.
		EndIf

		nCol    := Ascan(aColMes,"R"+cAnoMes)
		If nCol > 0
			aMatriz[nLinFat,nCol+nColIni] += aReturn[nX,FAT_VALFAT]
			aMatriz[nLinImp,nCol+nColIni] := "'= 8 * "+ cValToChar(aMatriz[nLinFat,nCol+nColIni])+"'"
		Else
			lRet := .F.
		EndIf
	Next

Endif

Return lRet



Static Function PrcPlan()
Local nI 		:= 0
Local cCol 		:= ""
Local cColsP	:= ""
Local cColsR	:= ""
Local cCab		:= ""

// Definição do Arq Excel
oRExcel := RExcel():New(cProg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetVersao(cVersao)
oRExcel:SetDescr(cDescr)
oRExcel:SetParam(aParam)

// Definição da Planilha 1
oPExcel:= PExcel():New(cProg,aMatriz)

// Colunas da Planilha 1
oPExcel:AddCol("CONTRATO","","Contrato","")
oPExcel:GetCol("CONTRATO"):SetTamCol(10)

oPExcel:AddCol("CHAVE","","Chave","")
oPExcel:GetCol("CHAVE"):SetTamCol(20)

oPExcel:AddCol("DESCRICAO","","Descricao","")
oPExcel:GetCol("DESCRICAO"):SetTamCol(50)

// Criação das fórmulas de soma do previsto e realizado até o mes de ref
cColsP := cColsR:= "'="
For nI := 1 To Len(aColMes)
	cCol := aColMes[nI]
	If SUBSTR(cCol,2,6) <= cAMesRef
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

oPExcel:AddCol("TOTPREV",cColsP,"Total Previsto até "+cMAnoRef,"")
oPExcel:GetCol("TOTPREV"):SetTipo("FN")
oPExcel:GetCol("TOTPREV"):SetTotal(.T.)

oPExcel:AddCol("TOTREAL",cColsR,"Total Realizado até "+cMAnoRef,"")
oPExcel:GetCol("TOTREAL"):SetTipo("FN")
oPExcel:GetCol("TOTREAL"):SetTotal(.T.)

For nI := 1 To Len(aColMes)
	cCol := aColMes[nI]
	If "P" $ cCol
		cCab := "Previsto "+SUBSTR(aColMes[nI],6,2)+"/"+SUBSTR(aColMes[nI],2,4)
	Else
		cCab := "Realizado "+SUBSTR(aColMes[nI],6,2)+"/"+SUBSTR(aColMes[nI],2,4)
	EndIf
	oPExcel:AddCol(cCol,"",cCab,"")
	oPExcel:GetCol(cCol):SetTipo("FN")	
	oPExcel:GetCol(cCol):SetTotal(.T.)
	oPExcel:GetCol(cCol):SetDecimal(2)
Next

// Adiciona a planilha 1
oRExcel:AddPlan(oPExcel)
oPExcel:SetTitulo("Contrato: "+cContrato+" - "+Posicione("CTT",1,xFilial("CTT")+cContrato,"CTT_DESC01"))

// Cria arquivo Excel
oRExcel:Create()

Return Nil

