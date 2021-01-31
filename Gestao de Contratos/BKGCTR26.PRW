#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"                     

/*/{Protheus.doc} BKGCTR26
BK - Planilha diária de Pagamentos
@Return
@author Marcos Bispo Abrahão
@since 28/01/2021
@version P12-25
/*/

User Function BKGCTR26()

Private cTitulo     := "Fluxo de Caixa Por Contrato"
Private cPerg       := "BKGCTR26"

Private cTTipos 	:= ""
Private cXTipos 	:= ""

Private aParam		:=	{}
Private aRet		:=	{}

Private cContrato 	:= SPACE(TamSx3("CN9_NUMERO")[1])
Private lSintetico  := .T.

Private dDataI  	:= CTOD("")
Private dDataF  	:= CTOD("")
Private aPeriodo    := {}
Private aAnoMes     := {}
Private nPeriodo    := 1

Private aPlan2      := {}

Private	cPict       := "@E 99,999,999,999.99"


aAdd( aParam, { 1, "Centro de Custos:"  , cContrato	, ""    , "", "CTT"	, "" , 70  , .F. })
aAdd( aParam ,{ 2, "Sintético/Analítico", "Sintético", {"Sintético", "Analítico"}, 70,'.T.'  ,.T.})

If !BKGC26()
   Return
EndIf

aPlan2 := BKGC26PL()

For nI := 1 To Len(aPlan2)
	If !Empty(aPlan2[nI,3])
		cTTipos += aPlan2[nI,3]+"/"
	EndIf
Next

Processa( {|| ProcPer() })
Processa( {|| Proc191() })

//Processa( {|| ProcGC26() })

If nCont > 0
	//MsAguarde({|| BKGCTX26(cAliasTrb,TRIM(cPerg),cTitulo,aCampos,aCabs)},"Aguarde","Gerando planilha...",.F.)
Else
    MsgStop("Não foram encontrados registros para esta seleção", cPerg)
EndIf

Return



Static Function BKGC26
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg      ,.T.         ,.T.))
	lRet        := .T.

	cContrato   := mv_par01
	lSintetico  := IIF(SUBSTR(mv_par02,1,1)=="S",.F.,.T.)
    If ! Empty(cContrato)
	    cTitulo  += ": "+cContrato
    EndIf
Endif
Return lRet


Static Function ProcPer()
Local cQuery := ""
Local dDataInicio := dDataBase

cQuery := " SELECT TOP 1 MIN(CN9_DTOSER) AS CN9_DTOSER,MIN(CN9_DTINIC) AS CN9_DTINIC,MIN(CNF_DTVENC) AS CNF_INICIO,MAX(CNF_DTVENC) AS CNF_FIM,CN9_SITUAC"+CRLF
cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF
cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA"+CRLF
cQuery += "       AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"+CRLF
cQuery += " WHERE CNF.D_E_L_E_T_=''"+CRLF
If !Empty(cContrato)
    cQuery += " AND CNF_CONTRA ='"+ALLTRIM(cContrato)+"'"+CRLF 
EndIf
cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
cQuery += " GROUP BY CN9_SITUAC"+CRLF

u_LogMemo("BKGCTR26-CNF.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP1"
TCSETFIELD("QTMP1","CNF_INICIO","D",8,0)	
TCSETFIELD("QTMP1","CNF_FIM"   ,"D",8,0)	
TCSETFIELD("QTMP1","CN9_DTINIC","D",8,0)	
TCSETFIELD("QTMP1","CN9_DTOSER","D",8,0)	

dbSelectArea("QTMP1")
dDataI		:= QTMP1->CN9_DTOSER
If Empty(dDataI)
	dDataI	:= QTMP1->CN9_DTINIC
EndIf
If (!Empty(QTMP1->CNF_INICIO) .AND. QTMP1->CNF_INICIO < dDataI) .OR. Empty(dDataI)
	dDataI	:= QTMP1->CNF_INICIO
EndIf
If Empty(dDataI)
    dDataI := dDataBase
EndIf
dDataF	:= QTMP1->CNF_FIM

If Empty(dDataF)
    dDataF := dDataBase
EndIf

QTMP1->(Dbclosearea())

// Voltar 1 mes
dDataI      := dDataI - Day(dDataI)
dDataI      := dDataI - Day(dDataI)+1

//Determina quantos Meses utilizar no calculo
nPeriodo    := DateDiffMonth( dDataI , dDataF ) + 1

aPeriodo	:= {}
aAnoMes     := {}
dDataInicio := dDataI

For _nI := 1 To nPeriodo

  	aAdd(aPeriodo,STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4))
	aAdd(aAnoMes,STRZERO(YEAR(dDataInicio),4)+STRZERO(Month(dDataInicio),2))  

	dDataInicio := MonthSum(dDataInicio,1)

Next

Return Nil




Static Function ProcGC26
Local cQuery 	:= ""
Local nF 		:= 0
Local nX		:= 0
//Local nValor 	:= 0
Local nSaldo 	:= 0
Local cTipoBk	:= ""
Local cFilF1	:= ""
Local cxTipoPg 	:= ""
Local cxNumPa 	:= ""
Local cFormaPgto := ""
Local cDadosBanc := ""
Local aItem 	:= {}
Local aDupLin	:= {}
Local cDescB1   := ""
Local cCodPrd	:= ""
Local nScan		:= 0
Local cCCusto	:= ""
Local lRH 		:= .F.
Local cJust		:= ""
Local cTitPai	:= ""
Local cChave	:= ""
Local cHist		:= ""

Private xCampo

//cOrder := SqlOrder(IndexKey())
cQuery := "SELECT *, R_E_C_N_O_ AS E5_XXRECNO,
cQuery += "(SELECT TOP 1 'CANC' FROM "+RetSqlName("SE5")+" SE52 WHERE SE52.D_E_L_E_T_ = '' AND E5_FILIAL = '" + xFilial("SE5") + "'"
cQuery += " AND SE52.E5_BANCO=SE5.E5_BANCO "
cQuery += " AND SE52.E5_AGENCIA=SE5.E5_AGENCIA "
cQuery += " AND SE52.E5_CONTA=SE5.E5_CONTA "
cQuery += " AND SE52.E5_NUMCHEQ=SE5.E5_NUMCHEQ "
cQuery += " AND SE52.E5_VALOR=SE5.E5_VALOR "
cQuery += " AND SE52.E5_NATUREZ='NTCHEST' "
cQuery += " AND SE52.R_E_C_N_O_>SE5.R_E_C_N_O_ "
cQuery += "  ) AS CANC "
cQuery += " FROM " + RetSqlName("SE5")+" SE5"
cQuery += " WHERE " +RetSqlCond("SE5")
cQuery += " AND E5_DATA    >= '" + DTOS(dDataI) + "'"   
cQuery += " AND E5_DATA    <= '" + DTOS(dDataF) + "'" 
cQuery += " AND E5_TIPODOC NOT IN ('BA','MT','CM','DC','JR','CP','M2','C2','D2','J2','V2')"
cQuery += " AND E5_MOTBX   <> 'CMP'"
cQuery += " AND E5_SITUACA <> 'C'"
cQuery += " AND D_E_L_E_T_ <> '*'"
cQuery += " ORDER BY " + cOrder

u_LogMemo("BKGCTR26.SQL",cQuery)

cAliasQry := GetNextAlias()

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
TCSETFIELD(cAliasQry,"E5_DATA"	,"D", 8,0)
TCSETFIELD(cAliasQry,"E5_VALOR" ,"N",18,2)
	
ProcRegua((cAliasQry)->(LastRec()))
	
nCont := 0
dbSelectArea("SD1")  // * Itens da N.F. de Compra
dbSetOrder(1)
aPrd   := {}
cFilF1 := xFilial("SF1")

dbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())
DO WHILE (cAliasQry)->(!EOF())
    nCont++
	IncProc("Consultando banco de dados...")
	dbSelectArea(cAliasTrb)
	Reclock(cAliasTrb,.T.)
	SE2->(dbGoTo((cAliasQry)->E2RECNO))
	
	cCCusto	:= ""
	cJust	:= ""
	cTitPai := ""
	lRH		:= .F.
	cHist	:= ""

	For nF := 1 To Len(aFields)
		If Len(aFields[nF]) > 2 .AND. !Empty(aFields[nF,3])
			xCampo := &(aFields[nF,3])
		Else
			xCampo := &(cAliasQry+"->"+aFields[nF,2])
			&(cAliasTrb+"->"+aFields[nF,1]) :=  xCampo
		EndIf

		If aFields[nF,2] = "E2_SALDO"
			nSaldo := SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,1,,iIf(lDetCC,dDataBase,dDataI-1),SE2->E2_LOJA,,0/*nTxMoeda*/)
			xCampo := nSaldo
        ElseIf aFields[nF,1] = "XX_FORMPGT"
            SE2->(dbGoTo((cAliasQry)->E2RECNO))
            dbSelectArea("SF1")                   // * Cabeçalho da N.F. de Compra
            dbSetOrder(1)
            If dbSeek(cFilF1+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA+"N")
                cxTipoPg := SF1->F1_XTIPOPG
                cxNumPa  := SF1->F1_XNUMPA
				cJust	 := SF1->F1_XXJSPGT
                If !Empty(cxTipoPg)
                    cFormaPgto := TRIM(cxTipoPg)
                    If TRIM(cxTipoPg) == "DEPOSITO" //.AND. SF1->F1_FORNECE <> "000084"
                        If Empty(SF1->F1_XBANCO) .AND. SF1->F1_FORNECE <> "000084"
                            cDadosBanc := "Bco: "+ALLTRIM(SA2->A2_BANCO)+" Ag: "+ALLTRIM(SA2->A2_AGENCIA)+" C/C: "+ALLTRIM(SA2->A2_NUMCON)
                        Else
                            cDadosBanc := "Bco: "+ALLTRIM(SF1->F1_XBANCO)+" Ag: "+ALLTRIM(SF1->F1_XAGENC)+" C/C: "+ALLTRIM(SF1->F1_XNUMCON)
                        EndIf
                        cFormaPgto += ": "+cDadosBanc
                    ElseIf TRIM(cxTipoPg) == "P.A."
                        cFormaPgto += " "+cxNumPa
                    EndIf
                EndIf
            EndIf
			xCampo := cFormaPgto
        ElseIf aFields[nF,1] = "XX_JUST"
            xCampo := cJust
		EndIf
		&(cAliasTrb+"->"+aFields[nF,1]) :=  xCampo
	Next

	cTipoBk := TRIM((cAliasQry)->E2_XXTIPBK)
	If !((TRIM(cTipoBk)+"/") $ cTTipos) .AND. !((TRIM(cTipoBk)+"/") $ cXTipos)
		// Tipos não Classificados
		cXTipos += TRIM(cTipoBk)+"/"
	EndIf

	If Empty(cTipoBk)
		cTitPai := SUBSTR(SE2->E2_TITPAI,4,9)+SUBSTR(SE2->E2_TITPAI,1,3)+SUBSTR(SE2->E2_TITPAI,18,8) //E  000000014  NF 00108501
		If TRIM(SE2->E2_NATUREZ) == "IRF"
			cTipoBk := "IIRRF"
		ElseIf TRIM(SE2->E2_NATUREZ) == "INSS"
			cTipoBk := "INSS"
		ElseIf TRIM(SE2->E2_NATUREZ) == "ISS"
			cTipoBk := "ISS"
			If TRIM(SE2->E2_ORIGEM) == "MATA460"  // Faturamento
				cTitPai := ""
				SD2->(dbSetOrder(3))
				SD2->(dbSeek(xFilial("SD2")+SE2->E2_NUM+SE2->E2_PREFIXO,.T.))
				If SD2->(!EOF()) .and. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE == ;
										xFilial("SD2")+SE2->E2_NUM+SE2->E2_PREFIXO
					cCCusto := SD2->D2_CCUSTO
				EndIf
			EndIf

		ElseIf TRIM(SE2->E2_NATUREZ) $ "PIS/COFINS/CSLL"
			cTipoBk := "PCC"
		Else
			cTitPai := ""
		EndIf

		(cAliasTrb)->XX_XXTIPBK := cTipoBk
	Else
		lRH := .T.
	EndIf

	// Gravar valor padrão do item caso não haja Doc de Entrada
	If lDetCC
		(cAliasTrb)->XX_VALITEM := (cAliasTrb)->XX_VALOR
		(cAliasTrb)->XX_RATEIO  := "N"
		(cAliasTrb)->XX_CC := cCCusto
	EndIf

	aItem := {}
	If Empty(cTipoBk) .OR. !Empty(cTitPai)

		SE2->(dbGoTo((cAliasQry)->E2RECNO))

	    dbSelectArea("SD1")
		If !Empty(cTitPai)
			cChave := cTitPai
		Else
			cChave := SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA
		EndIf

    	IF dbSeek(xFilial("SD1")+cChave)
			// Pega o primeiro produto

			SB1->(dbSeek(xFilial("SB1")+SD1->D1_COD,.F.))
			If Empty(cTitPai)
				cTipoBk := SB1->B1_XXGRPF
			EndIf
			If TRIM(SB1->B1_GRUPO) $ "0008/0009/0010"
				cDescB1 := TRIM(Posicione("SBM",1,xFilial("SBM")+SB1->B1_GRUPO,"BM_DESC"))
			Else
				cDescB1 := TRIM(SB1->B1_DESC)
			EndIf

			(cAliasTrb)->XX_PRODUTO := TRIM(SD1->D1_COD)
			(cAliasTrb)->XX_DESC    := cDescB1
			If lDetCC
				(cAliasTrb)->XX_CC  := TRIM(SD1->D1_CC)
			EndIf

			If aScan(aPrd,{|x| x[1] == SD1->D1_COD}) = 0
				aAdd(aPrd,{SD1->D1_COD,(cAliasTrb)->XX_DESC,cTipoBk})
			EndIf

			If lDetCC 
				cHist := ""
				Do While !Eof() .AND. cChave  == SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
					SB1->(dbSeek(xFilial("SB1")+SD1->D1_COD,.F.))
					If Empty(cTitPai)
						cTipoBk := SB1->B1_XXGRPF
					EndIf
					If TRIM(SB1->B1_GRUPO) $ "0008/0009/0010"
						cDescB1 := TRIM(Posicione("SBM",1,xFilial("SBM")+SB1->B1_GRUPO,"BM_DESC"))
						cCodPrd := TRIM(SB1->B1_GRUPO)
					Else
						cDescB1 := TRIM(SB1->B1_DESC)
						cCodPrd := TRIM(SD1->D1_COD)
					EndIf
					nScan := aScan(aItem,{|x| x[1] == cCodPrd .AND. x[4] == SD1->D1_CC})
					If nScan = 0
						aAdd(aItem,{cCodPrd,cDescB1,cTipoBk,SD1->D1_CC,SD1->D1_TOTAL})
					Else
						aItem[nScan,5] += SD1->D1_TOTAL
					EndIf
					If !AllTrim(SD1->D1_XXHIST) $ cHist
						cHist += AllTrim(SD1->D1_XXHIST)+" " 
					EndIf
					dbSkip()
				EndDo
				If Empty(cHist)
					cHist := SE2->E2_HIST
				EndIf
				(cAliasTrb)->XX_HIST := cHist
			Endif
		ENDIF

		If Empty(cTipoBk)
			cTipoBk := "FORN"
		EndIf
		
		(cAliasTrb)->XX_XXTIPBK := cTipoBk
		//(cAliasTrb)->XX_VALITEM := (cAliasTrb)->XX_VALOR

		// Detalhar Centros de Custos
		If lDetCC .AND. Len(aItem) > 1
			Rateio(@aItem,(cAliasTrb)->XX_VALOR,5)
			aDupLin := {}
			dbSelectArea(cAliasTrb)
			For nX := 1 To Len(aFields)
				AADD(aDupLin,FieldGet(nX))
			Next
			For nX := 1 To Len(aItem)
				If nX > 1
					Reclock(cAliasTrb,.T.)
					For nF := 1 To Len(aDupLin)
						FieldPut(nF,aDupLin[nF])
					Next
					(cAliasTrb)->XX_SALDO	:= 0
					(cAliasTrb)->XX_VALOR	:= 0
					(cAliasTrb)->XX_FORMPGT	:= ""
					(cAliasTrb)->XX_HIST	:= ""
					(cAliasTrb)->XX_JUST	:= ""
				Endif

				(cAliasTrb)->XX_PRODUTO := aItem[nx,1]
				(cAliasTrb)->XX_DESC	:= aItem[nx,2]
				(cAliasTrb)->XX_XXTIPBK	:= aItem[nx,3]				
				(cAliasTrb)->XX_CC		:= aItem[nx,4]
				(cAliasTrb)->XX_DESCCC  := Posicione("CTT",1,xFilial("CTT")+(cAliasTrb)->XX_CC,"CTT_DESC01")
				(cAliasTrb)->XX_VALITEM := aItem[nx,5]
				(cAliasTrb)->XX_RATEIO	:= "S"
			Next
		EndIf
	ElseIf lRH .AND. lDetCC

		(cAliasTrb)->XX_HIST := SE2->E2_HIST

		ProcSz2(@aItem)
		If Len(aItem) > 0
			Rateio(@aItem,(cAliasTrb)->XX_VALOR,2)
			aDupLin := {}
			dbSelectArea(cAliasTrb)
			For nX := 1 To Len(aFields)
				AADD(aDupLin,FieldGet(nX))
			Next
			For nX := 1 To Len(aItem)
				If nX > 1
					Reclock(cAliasTrb,.T.)
					For nF := 1 To Len(aDupLin)
						FieldPut(nF,aDupLin[nF])
					Next
					(cAliasTrb)->XX_SALDO := 0
					(cAliasTrb)->XX_VALOR := 0
					(cAliasTrb)->XX_FORMPGT:= ""
					(cAliasTrb)->XX_HIST	:= ""
					(cAliasTrb)->XX_JUST	:= ""
				Endif

				//(cAliasTrb)->XX_PRODUTO := aItem[nx,1]
				//(cAliasTrb)->XX_DESC	:= aItem[nx,2]
				//(cAliasTrb)->XX_XXTIPBK	:= aItem[nx,3]				
				(cAliasTrb)->XX_CC		:= aItem[nx,1]
				(cAliasTrb)->XX_VALITEM := aItem[nx,2]
				(cAliasTrb)->XX_DESCCC  := Posicione("CTT",1,xFilial("CTT")+(cAliasTrb)->XX_CC,"CTT_DESC01")
				If Len(aItem) > 1
					(cAliasTrb)->XX_RATEIO	:= "S"
				Else
					(cAliasTrb)->XX_RATEIO	:= "N"
				EndIf
			Next
		EndIf

	EndIf

	//nValor  := (cAliasQry)->E2_VALOR
	If lDetCC .AND. Empty((cAliasTrb)->XX_DESCCC)
		(cAliasTrb)->XX_DESCCC := Posicione("CTT",1,xFilial("CTT")+(cAliasTrb)->XX_CC,"CTT_DESC01")
	EndIf
	
	(cAliasTrb)->(MsUnLock())
		
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbSkip())
ENDDO

(cAliasQry)->(dbCloseArea())

dbSelectArea(cAliasTrb)
dbGoTop()

Return


Static Function BKGCTX26(cAliasTrb,cArqXlsx,cTitulo,aCampos,aCabs)
Local oExcel := YExcel():new()
Local oAlCenter
Local nI 	 := 0
Local nJ	 := 0
Local nLin   := 1
Local cFile  := cArqXlsx+"-"+DTOS(dDataI)
Local nRet   := 0
Local aAports:= {}
Local xCelApo:= ""
Local nCelStl:= 0

oExcel:new(cFile)

oExcel:ADDPlan(cArqXlsx,"0000FF")		//Adiciona nova planilha

oAlCenter	:= oExcel:Alinhamento("center","center")
nPosFont	:= oExcel:AddFont(10,"FFFFFFFF","Calibri","2")
nTitFont	:= oExcel:AddFont(20,"00000000","Calibri","2")
nPosCor		:= oExcel:CorPreenc("9E0000")	//Cor de Fundo Vermelho alterado
nLisCor		:= oExcel:CorPreenc("D9D9D9")
nBordas 	:= oExcel:Borda("ALL")
nFmtNum2	:= oExcel:AddFmtNum(2/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)

				//nTamanho,cCorRGB,cNome,cfamily,cScheme,lNegrito,lItalico,lSublinhado,lTachado
nTotFont 	:= oExcel:AddFont(11,56,"Calibri","2",,.T.,.F.,.F.,.F.)
nApoFont 	:= oExcel:AddFont(11,"FF0000","Calibri","2",,.T.,.F.,.F.,.F.)
nRatFont 	:= oExcel:AddFont(11,"0000FF","Calibri","2",,.T.,.F.,.F.,.F.)

nPosStyle	:= oExcel:AddStyles(/*numFmtId*/,nPosFont/*fontId*/,nPosCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})
nLisStyle	:= oExcel:AddStyles(/*numFmtId*/,/*fontId*/,nLisCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,)

nV2Style	:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nD2Style	:= oExcel:AddStyles(14/*numFmtId*/,/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})
nG2Style 	:= oExcel:AddStyles(/*numFmtId*/,/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nT2Style	:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,nTotFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)

nTitStyle	:= oExcel:AddStyles(/*numFmtId*/,nTitFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})
nApoStyle	:= oExcel:AddStyles(/*numFmtId*/,nApoFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nVApoStyle	:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,nApoFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nDApoStyle	:= oExcel:AddStyles(14/*numFmtId*/,nApoFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})

nVRatStyle	:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,nRatFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)


nTotStyle	:= oExcel:AddStyles(/*numFmtId*/,nTotFont/*fontId*/,nLisCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,)

nIDImg		:= oExcel:ADDImg("LGMID"+cEmpAnt+".PNG")	//Imagem no Protheus_data

			  //nID,nLinha,nColuna,nX,nY,cUnidade,nRot
oExcel:Img(nIDImg,1,1,36,36,/*"px"*/,)

oExcel:Cell(1,1,"",,nTitStyle)
oExcel:Cell(1,2,"Pagamentos Diários - "+DTOC(dDataI),,nTitStyle)

// Merge com Bordas
For nI := 3 To nColDiv-1
	oExcel:Cell(1,nI,"",,nTitStyle)
Next

oExcel:Cell(1,nColDiv+1,"Totalizadores",,nTitStyle)
For nI := nColDiv+2 To Len(aTamCol)
	oExcel:Cell(1,nI,"",,nTitStyle)
Next

oExcel:Cell(2,1,"",,nTitStyle)
For nI := 2 To nColDiv-1
	oExcel:Cell(2,nI,"",,nTitStyle)
Next
For nI := nColDiv+1 To Len(aTamCol)
	oExcel:Cell(2,nI,"",,nTitStyle)
Next

oExcel:mergeCells(1,1,2,1)				//Mescla as células Logo
oExcel:mergeCells(1,2,2,nColDiv-1)		//Mescla as células Titulos
oExcel:mergeCells(1,nColDiv+1,2,Len(aTamCol))

nLin := nTop
For nJ := 1 To Len(aCabs)
	oExcel:Cell(nLin,nJ,aCabs[nJ],,nPosStyle)
NEXT

// Cabeçalhos dos totalizadores
oExcel:Cell(nLin,nPosT,"DESPESAS",,nPosStyle)
oExcel:Cell(nLin,nPosV,"TOTAIS"  ,,nPosStyle)
oExcel:Cell(nLin,nPosS,"SALDOS"  ,,nPosStyle)
oExcel:Cell(nLin,nPosL,"SIGLAS"  ,,nPosStyle)

For nJ := 1 To Len(aTamCol)
	oExcel:AddTamCol(nJ,nJ,aTamCol[nJ])
Next

(cAliasTrb)->(dbgotop())

Do While (cAliasTrb)->(!eof()) 

	nLin++

	For nI :=1 to LEN(aCampos)

		xCampo := &(aCampos[nI])

		If ValType(xCampo) == "N"
			If "VALITEM" $ aCampos[nI] .AND. lDetCC .AND. (cAliasTrb)->XX_RATEIO = "S"
				oExcel:Cell(nLin,nI,xCampo,,nVApoStyle /*nVRatStyle*/)
			Else
				oExcel:Cell(nLin,nI,xCampo,,nV2Style)
			EndIf
		ElseIf ValType(xCampo) == "D"
			oExcel:Cell(nLin,nI,xCampo,,nD2Style)
		Else
			If "XXTIPBK" $ aCampos[nI] .AND. !( (TRIM(xCampo)+"/") $ cTTipos)
				oExcel:Cell(nLin,nI,xCampo,,nApoStyle)
				//If !TRIM(xCampo)+"/" $ cXTipos
				//	cXTipos += TRIM(xCampo)+"/"
				//EndIf
			Else
				oExcel:Cell(nLin,nI,xCampo,,nG2Style)
			EndIf
		EndIf

	Next

	LPlan2(oExcel,nLin)

	(cAliasTrb)->(dbskip())
EndDo

If !lDetCC
	aAports := {"BALSA NOVA","LIMEIRA","OSASCO","CAMPINAS","TABOÃO","BKTER HF","CORRETORA","BHG INTERIOR 3","",""}
	For nI := 1 To Len(aAports)
		nLin++
		For nJ := 1 To nColDiv - 1
			xCelApo := ""
			nCelStl := nApoStyle
			If nJ == nColNForn
				xCelApo := aAports[nI]
			ElseIf nJ == nColTipo
				xCelApo := IIF(!Empty(aAports[nI]),"APO","")
			ElseIf nJ == nColVenc
				xCelApo := dDataI
				nCelStl := nDApoStyle
			ElseIf nJ == nColValor
				xCelApo := 0
				nCelStl := nVApoStyle
			ElseIf nJ == nColVSaldo
				xCelApo := 0
				nCelStl := nVApoStyle
			ElseIf nJ == nColItem
				xCelApo := 0
				nCelStl := nVApoStyle
			Endif
			oExcel:Cell(nLin,nJ,xCelApo,,nCelStl)
		Next

		LPlan2(oExcel,nLin)
	Next
EndIf

oExcel:AddNome(cNTipoBk ,nTopV, nColTipo  ,nLin, nColTipo)
oExcel:AddNome(cNValores,nTopV, nColValor ,nLin, nColValor)	
oExcel:AddNome(cNSaldos ,nTopV, nColVSaldo,nLin, nColVSaldo)	
If lDetCC
	oExcel:AddNome(cNItensCC ,nTopV, nColItem,nLin, nColItem)	
EndIf

nLin++
oExcel:Cell(nLin,1,"Total",,nTotStyle)
For nI := 2 to iIf(lDetCC,nColItem,nColValor)-1
	oExcel:Cell(nLin,nI,"",,nTotStyle)
Next
oExcel:mergeCells(nLin,1,nLin,iIf(lDetCC,nColItem,nColValor)-1)
If lDetCC
	oExcel:Cell(nLin,nColItem,0,"SUM("+cNItensCC+")",nT2Style)
EndIf
oExcel:Cell(nLin,nColValor,0,"SUM("+cNValores+")",nT2Style)
oExcel:Cell(nLin,nColVSaldo,0,"SUM("+cNSaldos+")",nT2Style)
//oExcel:Cell(nLin,9,0,"SUM("+cCVal+ALLTRIM(STR(nTopV))+":"+cCVal+ALLTRIM(STR(nLin-1))+")",nV2Style)
LPlan2(oExcel,nLin)

Do While nLin <= (Len(aPlan2)+nTopV+1)
	nLin++
	LPlan2(oExcel,nLin)
EndDo

cFile := "C:\TEMP\"+cFile+".xlsx"
If File(cFile)
	nRet:= FERASE(cFile)
	If nRet < 0
		MsgStop("Não será possivel gerar a planilha "+cFile+", feche o arquivo","BKGCTR26")
	EndIf
EndIf
oExcel:Gravar("C:\TEMP\",.T.,.T.)
return




Static Function LPlan2(oExcel,nLin)
Local nStyle  	:= 0
Local cFormula	:= ""
Local aTipos  	:= {}
Local nI 		:= 0
Local nL 		:= nLin - nTop

If MOD(nLin,2) > 0
	nStyle :=  nG2Style
else
	nStyle :=  nLisStyle
EndIf

If nL < Len(aPlan2)
	If aPlan2[nL,1]
		// Titulo
		oExcel:Cell(nLin,nPosT,aPlan2[nL,2],,nPosStyle)
		oExcel:Cell(nLin,nPosT+1,,,nG2Style)
		oExcel:Cell(nLin,nPosT+2,,,nG2Style)
		oExcel:Cell(nLin,nPosT+3,,,nG2Style)
	Else
		// Item
		//aAdd(aPlan2,.F,"Folha CLT","LPM/LAD/LAS/LFG/COM")
		If !Empty(aPlan2[nL,3])
			If aPlan2[nL,3] <> "XXX" 
				aTipos := StrTokArr(aPlan2[nL,3],"/")
			Else
				// Não classificado
				aTipos := StrTokArr(cXTipos,"/")
			EndIf
			For nI := 1 To Len(aTipos)
				If nI > 1
					cFormula += "+"
				EndIf
				cFormula += "SUMIF("+cNTipoBk+",&quot;="+aTipos[nI]+"&quot;,"+cNValores+")"
			Next
		EndIf
		oExcel:Cell(nLin,nPosT,aPlan2[nL,2],,nStyle)
		oExcel:Cell(nLin,nPosV,0,cFormula,nV2Style)
		oExcel:Cell(nLin,nPosS,0,STRTRAN(cFormula,cNValores,cNSaldos),nV2Style)
		If aPlan2[nL,3] <> "XXX" 
			oExcel:Cell(nLin,nPosL,aPlan2[nL,3],,nG2Style)
		Else
			oExcel:Cell(nLin,nPosL,cXTipos,,nApoStyle)
		EndIf
	EndIf
ElseIf nL == Len(aPlan2)

	oExcel:AddNome(cNTotais ,nTopV,nPosV,nLin-1,nPosV)	
	oExcel:AddNome(cNTSaldos,nTopV,nPosS,nLin-1,nPosS)	
	oExcel:Cell(nLin,nPosT,"Total",,nTotStyle)
	oExcel:Cell(nLin,nPosV,0,"SUM("+cNTotais+")",nT2Style)
	//oExcel:Cell(nLin,nPosV,0,"SUM("+cPosV+ALLTRIM(STR(nTopV+1))+":"+cPosV+ALLTRIM(STR(nLin-1))+")",nV2Style)
	oExcel:Cell(nLin,nPosS,0,"SUM("+cNTSaldos+")",nT2Style)
EndIf

Return Nil



Static Function BKGC26PL()
Local aPlan := {}
aAdd(aPlan,{.T.,"SALDO",""})
aAdd(aPlan,{.F.,"saldo do mês anterior","XSALDO"})

aAdd(aPlan,{.T.,"RECEITAS",""})
aAdd(aPlan,{.F.,"Notas Fiscais","XFAT"})
aAdd(aPlan,{.F.,"NDC","XNDC"})
aAdd(aPlan,{.F.,"Outras Receitas","XOUTRAS"})
aAdd(aPlan,{.F.,"",""})

aAdd(aPlan,{.T.,"DESPESAS",""})
aAdd(aPlan,{.T.,"PESSOAL",""})
aAdd(aPlan,{.F.,"Folha CLT","LPM/LAD/LAS/LFG/COM"})
aAdd(aPlan,{.F.,"Férias","LFE"})
aAdd(aPlan,{.F.,"13º Salário","LD1/LD2"})
aAdd(aPlan,{.F.,"Rescisões + MFG","MFG/LRC"})
aAdd(aPlan,{.F.,"Pensão ALimentícia","PEN"})
aAdd(aPlan,{.F.,"Parcelas Faltantes 13-PJ","LDV"})

aAdd(aPlan,{.F.,"",""})
aAdd(aPlan,{.T.,"BENEFÍCIOS",""})
aAdd(aPlan,{.F.,"Seguro Saúde","SS"})
aAdd(aPlan,{.F.,"Seguro Odontológico","SO"})
aAdd(aPlan,{.F.,"Seguro de Vida","SV"})
aAdd(aPlan,{.F.,"Vale Refeição","VR"})
aAdd(aPlan,{.F.,"Vale Alimentação","VA"})
aAdd(aPlan,{.F.,"Vale Transporte","VT"})
aAdd(aPlan,{.F.,"Cursos e Treinamento","CT"})
aAdd(aPlan,{.F.,"",""})
aAdd(aPlan,{.T.,"DESPESAS DE VIAGEM",""})
aAdd(aPlan,{.F.,"DV (SOL + HOS)","SOL/HOS/REE"})
aAdd(aPlan,{.F.,"",""})
aAdd(aPlan,{.T.,"ENCARGOS",""})
aAdd(aPlan,{.F.,"INSS","INSS"})
aAdd(aPlan,{.F.,"FGTS","FGTS"})
aAdd(aPlan,{.F.,"IRRF","EIRRF"})
aAdd(aPlan,{.F.,"Sindicatos e Assoc. Classe (CECM Furnas)","SIN"})
aAdd(aPlan,{.F.,"Exames Médicos","EXM"})
aAdd(aPlan,{.F.,"Trabalhistas","TRB"})
aAdd(aPlan,{.F.,"",""})
aAdd(aPlan,{.T.,"OUTRAS DESPESAS",""})
aAdd(aPlan,{.F.,"Aluguel","ALU"})
aAdd(aPlan,{.F.,"Condomínio","COND"})
aAdd(aPlan,{.F.,"IPTU","IPTU"})
aAdd(aPlan,{.F.,"Fornecedores","FORN"})
aAdd(aPlan,{.F.,"Consultoria  Jurídica / Contábil e Financeira","JCF"})
aAdd(aPlan,{.F.,"Tarifas Bancárias","TAR"})
aAdd(aPlan,{.F.,"Outras Despesas - Estrutura","EST"})
aAdd(aPlan,{.F.,"",""})
aAdd(aPlan,{.T.,"AMORTIZAÇÃO/JUROS EMPRÉSTIMOS/FINANCIAMENTOS",""})
aAdd(aPlan,{.F.,"Amortização/Juros Empréstimos/Financiamentos","AJF"})
aAdd(aPlan,{.F.,"",""})
aAdd(aPlan,{.T.,"IMPOSTOS",""})
aAdd(aPlan,{.F.,"PIS","PIS"})
aAdd(aPlan,{.F.,"COFINS","COFINS"})
aAdd(aPlan,{.F.,"Imposto de renda","IIRRF"})
aAdd(aPlan,{.F.,"ISS","ISS"})
aAdd(aPlan,{.F.,"4,65% ( CSSLL - COFINS - PIS )+TFF","PCC"})
aAdd(aPlan,{.F.,"",""})
aAdd(aPlan,{.T.,"DESPESAS DIVERSAS",""})
aAdd(aPlan,{.F.,"Representantes","REPR"})
aAdd(aPlan,{.F.,"Aportes Consórcios","APO"})
aAdd(aPlan,{.F.,"BK TER","BKTER"})
aAdd(aPlan,{.F.,"Fundo Fixo","CXA"})
aAdd(aPlan,{.F.,"Diretoria","DIR"})
aAdd(aPlan,{.F.,"DERSA Arrecadação","DERSA"})
aAdd(aPlan,{.F.,"Sem classificação","XXX"})
aAdd(aPlan,{.F.,"",""})
aAdd(aPlan,{.F.,"Total",""})
Return aPlan



Static Function Rateio(aRTot,nVal,nPos)
// Parametros: Array, Valor a ratear, posição do valor
Local nTot	:= 0
Local nRes	:= 0
Local nIx	:= 0

For nIx := 1 To LEN(aRTot)
	nTot += aRTot[nIx,nPos]
Next

For nIx := 1 To LEN(aRTot)
	nRes := ROUND( (aRTot[nIx,nPos] * 100 / nTot ) * nVal / 100,2)
	aRTot[nIx,nPos] := nRes
Next

Return Nil






Static Function ProcSZ2(aItem)
Local cQryZ2
Local cPrefixo := SE2->E2_PREFIXO
Local cNum     := SE2->E2_NUM
Local cParcela := SE2->E2_PARCELA
Local cTipo    := SE2->E2_TIPO
Local cFornece := SE2->E2_FORNECE
Local cLoja    := SE2->E2_LOJA
Local nZ2		:= 0

cQryZ2 := "SELECT ""
cQryZ2 += " Z2_NOME,Z2_PRONT,Z2_BANCO,Z2_AGENCIA,Z2_DATAEMI,Z2_DATAPGT,Z2_DIGAGEN,Z2_CONTA,Z2_DIGCONT,Z2_TIPO,Z2_VALOR,"
cQryZ2 += " Z2_TIPOPES,Z2_CC,Z2_USUARIO,Z2_OBSTITU,Z2_NOMDEP,Z2_NOMMAE "
cQryZ2 += " FROM "+RETSQLNAME("SZ2")+" SZ2"
cQryZ2 += " WHERE Z2_CODEMP = '"+SM0->M0_CODIGO+"' "
cQryZ2 += " AND Z2_E2PRF  = '"+cPrefixo+"' "
cQryZ2 += " AND Z2_E2NUM  = '"+cNum+"' "
cQryZ2 += " AND Z2_E2PARC = '"+cParcela+"' "
cQryZ2 += " AND Z2_E2TIPO = '"+cTipo+"' "
cQryZ2 += " AND Z2_E2FORN = '"+cFornece+"' "
cQryZ2 += " AND Z2_E2LOJA = '"+cLoja+"' "
cQryZ2 += " AND Z2_STATUS = 'S'"
cQryZ2 += " AND SZ2.D_E_L_E_T_ = ' '"
cQryZ2 += " ORDER BY Z2_NOME"  

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryZ2), 'QSZ2', .F., .T.)
TCSETFIELD("QSZ2","Z2_DATAEMI","D",8,0)
TCSETFIELD("QSZ2","Z2_DATAPGT","D",8,0)
dbSelectArea("QSZ2")
dbGoTop()
Do While !Eof()
	nZ2 := aScan(aItem,{|x| x[1] == QSZ2->Z2_CC})
	If nZ2 == 0
		aAdd(aItem,{QSZ2->Z2_CC,QSZ2->Z2_VALOR})
	Else
		aItem[nZ2,2] += QSZ2->Z2_VALOR
	EndIf
	dbSkip()
EndDo
QSZ2->(dbCloseArea())
Return Nil



Static Function Proc191()

Local aRelat        As Array
Local nOrdem        As Numeric
Local aTotais       As Array
Local oReport		As Object
Local nGerOrig      As Numeric
Local nI            As Numeric
Local cTotText      As Character

aRelat 		:= {}
nOrdem		:= 1
aTotais		:= {}

nGerOrig 	:= 0
nI			:= 1
cTotText	:= "Sub Total"

FA190ImpR4(@aRelat, nOrdem, @aTotais, oReport, nGerOrig, @nI, @cTotText)

Return aRelat




/*/{Protheus.doc} FA190ImpR4
Efetua montagem do array para definir quais baixas serão apresentadas no relatório.

@type       function
@author     Adrianne Furtado
@since      05/09/2006
@param      aRet, array, array que conterá os movimentos a serem impressos (passado por referência)
@param      nOrdem, numeric, ordem de impressão
@param      aTotais, array, array de totalizador para impressão (referência)
@param      oReport, object, objeto do relatório
@param      nGerOrig, numeric, não utilizado
@param      nI, numeric, contador de títulos para uso no printLine (por referência)
@param      cTotText, character, texto do totalizador (por referência)
@return     Nil
/*/
Static Function FA190ImpR4(aRet As Array, nOrdem As Numeric, aTotais As Array, oReport As Object, nGerOrig As Numeric, nI As Numeric, cTotText As Character) As Array

    Local aAreaBk       As Array
    Local aAreaSE2      As Array
    Local aAreaSE5      As Array
    Local aCampos       As Array 
    Local aChaveTit     As Array 
    Local aColu         As Array 
    Local aIndex        As Array
    Local aModoComp     As Array 
    Local aStru         As Array 
    Local aTam          As Array 

    Local cAge          As Character
    Local cAnterior     As Character
    Local cAuxFilNome   As Character
    Local cAuxCliFor    As Character
    Local cAuxLote      As Character
    Local cBanco        As Character
    Local cCarteira     As Character
    Local cChave        As Character
    Local cChaveTit     As Character
    Local cCliFor       As Character
    Local cCliFor190    As Character
    Local cCond2        As Character
    Local cCondicao     As Character
    Local cContaBco     As Character
    Local cDelete1      As Character
    Local cEmpresa      As Character
    Local cEstorno      As Character
    Local cFilNome      As Character
    Local cFilOrig      As Character
    Local cFilSE5       As Character
    Local cFilTrb       As Character
    Local cFilUser      As Character
    Local cHistorico    As Character
    Local cInsert       As Character
    Local cLayout       As Character
    Local cLoja         As Character
    Local cMascNat      As Character
    Local cMotBaixa     As Character
    Local cNatureza     As Character
    Local cRecPag       As Character
    Local cSelUpdat1    As Character
    Local cSelUpdat2    As Character
    Local cSGBD         As Character
    Local cTipoDoc      As Character
    Local cTmpSE5Fil    As Character
    Local cUpdate1      As Character
    Local cUpdate2      As Character
    Local cXFilSA1      As Character
    Local cXFilSA2      As Character
    Local cXFilSA6      As Character
    Local cXFilSE1      As Character
    Local cXFilSE2      As Character
    Local cXFilSE5      As Character
    Local cXFilSED      As Character
    Local cXFilSEH      As Character
    Local cXFilSEI      As Character
    Local tamanho       As Character

    Local dAuxDtDispo   As Date
    Local dDigit        As Date
    Local dDtMovFin     As Date

    Local lAchou        As Logical
    Local lAchouEmp     As Logical
    Local lAchouEst     As Logical
    Local lBxTit        As Logical
    Local lConsImp      As Logical
    Local lContinua     As Logical
    Local lDB2          As Logical
    Local lExclusivo    As Logical
    Local lF190Qry      As Logical
    Local lFilSit       As Logical
    Local lGestao       As Logical
    Local lManual       As Logical
    Local lMultiNat     As Logical
    Local lMVGlosa      As Logical
    Local lMVLjTroco    As Logical
    Local lNovaGestao   As Logical
    Local lOracle       As Logical
    Local lOriginal     As Logical
    Local lPCCBaixa     As Logical
    Local lPccBxCr      As Logical
    Local lRelatInit    As Logical
    Local lRaRtImp      As Logical
    Local lSkpNewSe5    As Logical
    Local lTroco        As Logical

    Local nAbat         As Numeric
    Local nAbatLiq      As Numeric
    Local nCM           As Numeric
    Local nCT           As Numeric
    Local nDesc         As Numeric
    Local nDecs         As Numeric
    Local nFilAbLiq     As Numeric
    Local nFilAbImp     As Numeric
    Local nFilBaixado   As Numeric
    Local nFilCM        As Numeric
    Local nFilComp      As Numeric
    Local nFilDesc      As Numeric
    Local nFilFat       As Numeric
    Local nFilJurMul    As Numeric
    Local nFilMovFin    As Numeric
    Local nFilOrig      As Numeric
    Local nFilValor     As Numeric
    Local nGerAbImp     As Numeric
    Local nGerAbLiq     As Numeric
    Local nGerBaixado   As Numeric
    Local nGerCm        As Numeric
    Local nGerComp      As Numeric
    Local nGerDesc      As Numeric
    Local nGerFat       As Numeric
    Local nGerJurMul    As Numeric
    Local nGerMovFin    As Numeric
    Local nGerValor     As Numeric
    Local nJurMul       As Numeric
    Local nJuros        As Numeric
    Local nLenSelFil    As Numeric
    Local nMoedaBco     As Numeric
    Local nMoedMov      As Numeric
    Local nMulta        As Numeric
    Local nPccBxCr      As Numeric
    Local nRecEmp       As Numeric
    Local nRecChkd      As Numeric
    Local nRecno        As Numeric
    Local nRecnoSE5     As Numeric
    Local nRecSE2       As Numeric
    Local nRecSe5       As Numeric
    Local nSelFil       As Numeric
    Local nTamEH        As Numeric
    Local nTamEI        As Numeric
    Local nTamRet       As Numeric
    Local nTaxa         As Numeric
    Local nTotAbImp     As Numeric
    Local nTotAbLiq     As Numeric
    Local nTotBaixado   As Numeric
    Local nTotCm        As Numeric
    Local nTotComp      As Numeric
    Local nTotDesc      As Numeric
    Local nTotFat       As Numeric
    Local nTotImp       As Numeric
    Local nTotJurMul    As Numeric
    Local nTotMovFin    As Numeric
    Local nTotOrig      As Numeric
    Local nTotValor     As Numeric
    Local nValor        As Numeric
    Local nValTroco     As Numeric
    Local nVlImp        As Numeric
    Local nVlMovFin     As Numeric
    Local nVlr          As Numeric
    Local nVlrGlosa     As Numeric

    Local oBaixas       As Object

    Default aRet        := {}

    oBaixas     := oReport:Section(1)
    nValor      := 0
    nDesc       := 0
    nJuros      := 0
    nMulta      := 0
    nJurMul     := 0
    nCM         := 0
    nVlMovFin   := 0
    nTotValor   := 0
    nTotDesc    := 0
    nTotJurMul  := 0
    nTotCm      := 0
    nTotOrig    := 0
    nTotBaixado := 0
    nTotMovFin  := 0
    nTotComp    := 0
    nTotFat     := 0
    nGerValor   := 0
    nGerDesc    := 0
    nGerJurMul  := 0
    nGerCm      := 0
    nGerBaixado := 0
    nGerMovFin  := 0
    nGerComp    := 0
    nGerFat     := 0
    nFilOrig    := 0
    nFilJurMul  := 0
    nFilCM      := 0
    nFilDesc    := 0
    nFilAbLiq   := 0
    nFilAbImp   := 0
    nFilValor   := 0
    nFilBaixado := 0
    nFilMovFin  := 0
    nFilComp    := 0
    nFilFat     := 0
    nAbatLiq    := 0
    nTotAbImp   := 0
    nTotImp     := 0
    nTotAbLiq   := 0
    nGerAbLiq   := 0
    nGerAbImp   := 0
    cBanco      := ""
    cCondicao   := ""
    cNatureza   := ""
    cAnterior   := ""
    cCliFor     := ""
    nCT         = 0
    cLoja       := ""
    lContinua   := .T.
    lBxTit      := .F.
    tamanho     := "G"
    aCampos     := {}
    nVlr        := 0
    nVlImp      := 0
    lOriginal   := .T.
    nAbat       := 0
    lManual     := .F.
    nRecSe5     := 0
    nRecEmp     := SM0->(Recno())
    cMotBaixa   := CriaVar("E5_MOTBX")
    cFilNome    := Space(15)
    cCliFor190  := ""
    aTam        := IIf(MV_PAR11 == 1, TamSX3("E1_CLIENTE"), TamSX3("E2_FORNECE"))
    aColu       := {}
    nDecs       := GetMv("MV_CENT" + (IIf(MV_PAR12 > 1 , STR(MV_PAR12, 1), "")))
    nMoedaBco   := 1
    aStru       := SE5->(DbStruct())
    cFilSE5     := ".T."

    //FwXFilial Por Empresa/Filial
    cXFilSA1    := ""
    cXFilSA2    := ""
    cXFilSA6    := ""
    cXFilSE1    := ""
    cXFilSE2    := ""
    cXFilSE5    := ""
    cXFilSED    := ""
    cXFilSEH    := ""
    cXFilSEI    := ""
    cChave      := ""
    lAchou      := .F.
    lF190Qry    := ExistBlock("F190QRY")
    lFilSit     := !Empty(MV_PAR15)
    lAchouEmp   := .T.
    lAchouEst   := .F.
    nTamEH      := TamSX3("EH_NUMERO")[1]
    nTamEI      := TamSX3("EI_NUMERO")[1] + TamSX3("EI_REVISAO")[1] + TamSX3("EI_SEQ")[1]
    nRecSE2     := 0
    cFilUser    := ""
    lPCCBaixa   := SuperGetMv("MV_BX10925", .T., "2") == "1"
    nTaxa       := 0
    lMVLjTroco  := SuperGetMV("MV_LJTROCO",, .F.)
    nRecnoSE5   := 0
    nValTroco   := 0
    lTroco      := .F.
    cEstorno    := "Estorno de tranferencia" // -bk- STR0080 

    //Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default))
    lPccBxCr    := FPccBxCr()
    nPccBxCr    := 0

    //Controla o Pis Cofins e Csll na RA (1 = Controla retenção de impostos no RA; ou 2 = Não controla retenção de impostos no RA(default))
    lRaRtImp    := FRaRtImp()
    cEmpresa    := IIf(lUnidNeg, FwCodEmp(), "")
    cAge        := ""
    cContaBco   := ""
    cMascNat    := ""
    lConsImp    := .T.
    lMVGlosa    := SuperGetMv("MV_GLOSA", .F., .F.)
    nVlrGlosa   := 0
    nTamRet     := 0
    aChaveTit   := {}
    cChaveTit   := ""
    nMoedMov    := 0
    //GESTAO - inicio */
    cTmpSE5Fil  := ""
    lNovaGestao := .F.
    nSelFil     := 0
    nLenSelFil  := 0
    cLayout     := FwSM0Layout()
    lGestao     := IIf(lFwCodFil, ("E" $ cLayout .And. "U" $ cLayout), .F.)// Indica se usa Gestao Corporativa
    lExclusivo  := .F.
    aModoComp   := {}
    lMultiNat   := .F.
    nRecChkd    := 0
    lSkpNewSe5  := .F.
    //GESTAO - fim
    cUpdate1    := ""
    cUpdate2    := ""
    cDelete1    := ""
    cSelUpdat1  := ""
    cSelUpdat2  := ""
    lRelatInit  := .F.
    cSGBD       := Upper(TCGetDB())
    lOracle     := "ORACLE" $ cSGBD
    lDB2        := "DB2" $ cSGBD

    //GESTAO - inicio
    lNovaGestao := .T.
    //GESTAO - fim

    If lFwCodFil .And. lGestao
        AAdd(aModoComp, FwModeAccess("SE5", 1))
        AAdd(aModoComp, FwModeAccess("SE5", 2))
        AAdd(aModoComp, FwModeAccess("SE5", 3))
        lExclusivo := AScan(aModoComp, "E") > 0
    Else
        DbSelectArea("SE5")
        lExclusivo := !Empty(FwXFilial("SE5"))
    EndIf

    If MV_PAR41 == 2
        lConsImp := .F.
    EndIf

    nGerOrig := 0

    //Atribui valores as variaveis ref a filiais
    /* GESTAO - inicio */
    If lNovaGestao
        nLenSelFil := Len(aSelFil)
        If MV_PAR40 == 1
            If nLenSelFil > 0
                cFilDe  := aSelFil[1]
                cFilAte := aSelFil[nLenSelFil]
            EndIf
        Else
            If MV_PAR17 == 2 // Cons filiais abaixo
                cFilDe := IIf(lFwCodFil, FWGETCODFILIAL, SM0->M0_CODFIL)
                cFilAte:= IIf(lFwCodFil, FWGETCODFILIAL, SM0->M0_CODFIL)
            Else
                cFilDe := MV_PAR18 // Todas as filiais
                cFilAte:= MV_PAR19
            EndIf
        EndIf
    Else
        If MV_PAR17 == 2 // Cons filiais abaixo
            cFilDe := IIf(lFwCodFil, FWGETCODFILIAL, SM0->M0_CODFIL)
            cFilAte:= IIf(lFwCodFil, FWGETCODFILIAL, SM0->M0_CODFIL)
        Else
            cFilDe := MV_PAR18 // Todas as filiais
            cFilAte:= MV_PAR19
        EndIf
    EndIf
    /* GESTAO - fim */

    F190InitTb()

    // Definicao das condicoes e ordem de impressao, de acordo com a ordem escolhida pelo usuario.
    DbSelectArea("SE5")
    Do Case
    Case nOrdem == 1
        cCond2 := "E5_DATA"
        cChave := IndexKey(1)
        aIndex := {"E5_FILIAL", "E5_DATA", "E5_BANCO", "E5_AGENCIA", "E5_CONTA", "E5_NUMCHEQ"}
    Case nOrdem == 2
        cCond2 := "E5_BANCO"
        cChave := IndexKey(3)
        aIndex := {"E5_FILIAL", "E5_BANCO", "E5_AGENCIA", "E5_CONTA", "E5_PREFIXO", "E5_NUMERO", "E5_PARCELA" ,"E5_TIPO", "E5_DATA"}
    Case nOrdem == 3
        cCond2 := "E5_NATUREZ"
        cChave := IndexKey(4)
        aIndex := {"E5_FILIAL", "E5_NATUREZ", "E5_PREFIXO", "E5_NUMERO", "E5_PARCELA", "E5_TIPO", "E5_DTDIGIT", "E5_RECPAG", "E5_CLIFOR", "E5_LOJA"}
    Case nOrdem == 4
        cCond2 := "E5_BENEF"
        cChave := "E5_FILIAL+E5_BENEF+DToS(E5_DATA)+E5_PREFIXO+E5_NUMERO+E5_PARCELA"
        aIndex := {"E5_FILIAL", "E5_BENEF", "E5_DATA", "E5_PREFIXO", "E5_NUMERO", "E5_PARCELA"}
    Case nOrdem == 5
        cCond2 := "E5_NUMERO"
        cChave := "E5_FILIAL+E5_NUMERO+E5_PARCELA+E5_PREFIXO+DToS(E5_DATA)"
        aIndex := {"E5_FILIAL", "E5_NUMERO", "E5_PARCELA", "E5_PREFIXO", "E5_DATA"}
    Case nOrdem == 6        //Ordem 6 (Digitacao)
        cCond2 := "E5_DTDIGIT"
        cChave := "E5_FILIAL+DToS(E5_DTDIGIT)+E5_PREFIXO+E5_NUMERO+E5_PARCELA+DToS(E5_DATA)"
        aIndex := {"E5_FILIAL", "E5_DTDIGIT", "E5_PREFIXO", "E5_NUMERO", "E5_PARCELA", "E5_DATA"}
    Case nOrdem == 7        // por Lote
        cCond2 := "E5_LOTE"
        cChave := IndexKey(5)
        aIndex := {"E5_FILIAL", "E5_LOTE", "E5_PREFIXO", "E5_NUMERO", "E5_PARCELA", "E5_TIPO", "E5_DATA"}
    OtherWise               // Data de Crédito (dtdispo)
        cCond2 := "E5_DTDISPO"
        cChave := "E5_FILIAL+DToS(E5_DTDISPO)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ"
        aIndex := {"E5_FILIAL", "E5_DTDISPO", "E5_BANCO", "E5_AGENCIA", "E5_CONTA", "E5_NUMCHEQ"}
    EndCase

    cChaveInterFun := cChave

    F190IndexTb(aIndex)

    oFinR190Tb:Create()

    cCondicao := ".T."
    DbSelectArea("SE5")

    cTable  := oFinR190Tb:GetRealName()
    cCampos := ""

    // Preenche todos os campos do arquivo temporario.
    AEval(aStru, {|Estrutura| If( Estrutura[DBS_TYPE] <> "M", cCampos += "," + AllTrim(Estrutura[DBS_NAME]), Nil)})

    cValues := SubStr(cCampos, 2)

    cInsert := ""
    cInsert := " INSERT "

    If lOracle
        cInsert += " /*+ APPEND */ "
    EndIf

    cInsert += " INTO " + cTable  + " ( " + cValues  + " , SE5RECNO, SE5MAXSEQ, SE5VA) "
    cInsert += " SELECT " + cValues + " , SE5.R_E_C_N_O_ SE5RECNO, '" + Space(GetSX3Cache("E5_SEQ", "X3_TAMANHO")) + "' SE5MAXSEQ, 0 SE5VA"
    cInsert += " FROM " + RetSQLName("SE5") + " SE5 "

    If !Empty(MV_PAR42) .And. MV_PAR42 == 2
        cInsert += "WHERE E5_RECPAG = '" + IIf(MV_PAR11 == 1, "R", "P") + "' AND "
    Else
        If MV_PAR11 == 1
            cInsert += "WHERE E5_RECPAG = (CASE WHEN E5_TIPODOC = 'TR' AND  E5_HISTOR LIKE '%" + cEstorno + "%' THEN 'P' Else 'R' END ) AND"
        Else
            cInsert += "WHERE E5_RECPAG = (CASE WHEN E5_TIPODOC = 'TR' AND  E5_HISTOR LIKE '%" + cEstorno + "%' THEN 'R' Else 'P' END ) AND"
        EndIf
    EndIf

    cInsert += " E5_DATA    BETWEEN '" + DToS(MV_PAR01) + "' AND '" + DToS(MV_PAR02) + "' AND "
    cInsert += " E5_DATA    <= '" + DToS(dDataBase) + "' AND "

    //Retirado da função FR190TstCond
    cInsert += " E5_MOTBX <> 'DSD' AND "
    //Retirado da função

    If cPaisLoc == "ARG" .And. MV_PAR03 == MV_PAR04
        cInsert += " (E5_BANCO = '" + MV_PAR03 + "' OR E5_BANCO = '" + Space(TamSX3("A6_COD")[1]) + "') AND "
    Else
        cInsert += " E5_BANCO   BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND "
    EndIf
    If cPaisLoc == "ARG" .And. MV_PAR11 == 2 // pagar
        cInsert += " (E5_DOCUMEN <> ' ' AND E5_TIPO <> 'CH') AND "
    EndIf
    // Realiza filtragem pela natureza principal
    If MV_PAR39 == 2
        cInsert +=  " E5_NATUREZ BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' AND "
    Else
        cInsert +=       " (E5_NATUREZ BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' OR "
        cInsert +=       " EXISTS (SELECT EV_FILIAL, EV_PREFIXO, EV_NUM, EV_PARCELA, EV_CLIFOR, EV_LOJA "
        cInsert +=                 " FROM " + RetSQLName("SEV") + " SEV "
        cInsert +=                " WHERE E5_FILIAL  = EV_FILIAL AND "
        cInsert +=                       "E5_PREFIXO = EV_PREFIXO AND "
        cInsert +=                       "E5_NUMERO  = EV_NUM AND "
        cInsert +=                       "E5_PARCELA = EV_PARCELA AND "
        cInsert +=                       "E5_TIPO    = EV_TIPO AND "
        cInsert +=                       "E5_CLIFOR  = EV_CLIFOR AND "
        cInsert +=                       "E5_LOJA    = EV_LOJA AND "
        cInsert +=                       "EV_NATUREZ BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' AND "
        cInsert +=                       "SEV.D_E_L_E_T_ = ' ')) AND "
    EndIf
    cInsert += "        E5_CLIFOR  BETWEEN '" + MV_PAR07       + "' AND '" + MV_PAR08       + "' AND "
    cInsert += "        E5_DTDIGIT BETWEEN '" + DToS(MV_PAR09) + "' AND '" + DToS(MV_PAR10) + "' AND "
    cInsert += "        E5_LOTE    BETWEEN '" + MV_PAR20       + "' AND '" + MV_PAR21       + "' AND "
    cInsert += "        E5_LOJA    BETWEEN '" + MV_PAR22       + "' AND '" + MV_PAR23       + "' AND "
    cInsert += "        E5_PREFIXO BETWEEN '" + MV_PAR26       + "' AND '" + MV_PAR27       + "' AND "
    cInsert += "        E5_MOVCX <> 'S' AND "
    cInsert += "        SE5.D_E_L_E_T_ = ' '  AND "
    cInsert += "        E5_SITUACA NOT IN ('C','E','X') AND NOT EXISTS ( "
    cInsert += "                                                                SELECT SE5ES.E5_NUMERO "
    cInsert += "                                                                FROM " + RetSQLName("SE5") + " SE5ES "
    cInsert += "                                                                WHERE SE5ES.E5_FILIAL  = SE5.E5_FILIAL "
    cInsert += "                                                                    AND SE5ES.E5_PREFIXO = SE5.E5_PREFIXO "
    cInsert += "                                                                    AND SE5ES.E5_NUMERO  = SE5.E5_NUMERO "
    cInsert += "                                                                    AND SE5ES.E5_PARCELA = SE5.E5_PARCELA "
    cInsert += "                                                                    AND SE5ES.E5_TIPO    = SE5.E5_TIPO "
    cInsert += "                                                                    AND SE5ES.E5_CLIFOR  = SE5.E5_CLIFOR "
    cInsert += "                                                                    AND SE5ES.E5_LOJA    = SE5.E5_LOJA "
    cInsert += "                                                                    AND SE5ES.E5_SEQ     = SE5.E5_SEQ "
    cInsert += "                                                                    AND SE5ES.E5_BANCO   = SE5.E5_BANCO "
    cInsert += "                                                                    AND SE5ES.E5_AGENCIA = SE5.E5_AGENCIA "
    cInsert += "                                                                    AND SE5ES.E5_CONTA   = SE5.E5_CONTA "
    cInsert += "                                                                    AND SE5ES.E5_MOVCX   = SE5.E5_MOVCX "
    cInsert += "                                                                    AND SE5ES.E5_TIPODOC = 'ES' "
    cInsert += "                                                                    AND SE5ES.E5_ORIGEM <> 'FINA100 ' "
    cInsert += "                                                                    AND (SE5ES.E5_KEY NOT LIKE '%PA%' OR "
    cInsert += "                                                                    SE5ES.E5_KEY LIKE '%PA%' AND "
    cInsert += "                                                                    SE5ES.E5_NUMERO = '" + Space(Len(E5_NUMERO)) + "')"
    cInsert += "                                                            AND SE5ES.D_E_L_E_T_ = ' ' "
    cInsert += "                                                            ) AND "
    cInsert += "    ((E5_TIPODOC = 'CD' AND E5_VENCTO <= E5_DATA) OR (E5_TIPODOC <> 'CD')) "
    cInsert += "        AND E5_HISTOR NOT LIKE '%" + STR0077 + "%'"
    cInsert += "        AND E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2','ES' "

    If !Empty(MV_PAR42) .And. MV_PAR42 == 2 // Cons. Baixa por Mov. Bancário //dms
        cInsert += "        ,'TR'"
    EndIf

    If MV_PAR11 == 2
        cInsert += " , 'E2'"
    Else//ElseIf MV_PAR11 == 1
        cInsert += " , 'E2', 'CB'"
    EndIf

    If MV_PAR16 == 2
        cInsert += " ,' '"
        cInsert += " ,'CH'"
        cInsert += " ,'TE'"
        cInsert += " ,'TR'"
    EndIf
    cInsert += " )"

    If !Empty(MV_PAR42) .And. MV_PAR42 == 2
        cInsert += " AND E5_ORIGEM <> 'FINA100' "
        cInsert += " AND E5_NUMERO  <> '" + Space(Len(E5_NUMERO)) + "'"
    EndIf

    If MV_PAR16 == 2
        cInsert += " AND E5_NUMERO  <> '" + Space(Len(E5_NUMERO)) + "'"
        cInsert += " AND E5_TIPO  <> '" + Space(Len(E5_TIPODOC)) + "'"
    EndIf

    If !Empty(MV_PAR28) // Deseja imprimir apenas os tipos do parametro 28
        cInsert += " AND E5_TIPO IN " + FormatIn(MV_PAR28, ";")
    ElseIf !Empty(MV_PAR29) // Deseja excluir os tipos do parametro 29
        cInsert += " AND E5_TIPO NOT IN " + FormatIn(MV_PAR29, ";")
    EndIf

    If MV_PAR11 == 1 .And. MV_PAR36 == 2 .And. !Empty(cSitCartei) // Nao imprime titulos em carteira
        cInsert += " AND E5_SITCOB NOT IN " + FormatIn(cSitCartei, "|")
    EndIf

    cCondFil := "NEWSE5->E5_FILIAL==FwXFilial('SE5')"

    /* GESTAO - inicio */
    If MV_PAR40 == 1 .And. !Empty(aSelFil)
        If lExclusivo
            cInsert += " AND " + FinSelFil(aSelFil, "SE5", .F., .T., 20)
        Else
            cInsert += " AND " + FinSelFil(aSelFil, "SE5", .T., .T., 20)
        EndIf
    Else
        If MV_PAR17 == 2
            cInsert += " AND E5_FILIAL = '" + FwxFilial("SE5") + "'"
        Else
            If !lExclusivo
                cInsert += " AND E5_FILORIG BETWEEN '" + cFilDe + "' AND '" + cFilAte + "'"
            Else
                cInsert += " AND E5_FILIAL BETWEEN '" + cFilDe + "' AND '" + cFilAte + "'"
            EndIf
        EndIf
    EndIf
    /* GESTAO - fim */

    cFilUser := oBaixas:GetSQLExp("SE5")

    If lF190Qry
        cInsertAdd := ExecBlock("F190QRY", .F., .F., {cFilUser})
        If ValType(cInsertAdd) == "C"
            cInsert += " AND (" + cInsertAdd + ")"
        EndIf
    EndIf

    If !Empty(cFilUser)
        cInsert += " AND (" + cFilUser + ") "
    EndIf

    cInsert += IIf(FindFunction("JurQWRelBx"), JurQWRelBx() , "")

    // seta a ordem de acordo com a opcao do usuario
    cInsert += " ORDER BY " + SQLOrder(cChave)

    If lDB2
        cInsert += " FOR READ ONLY "
    EndIf

    If TCSQLExec(cInsert) < 0
        DbOnError(TCSqlError(), "cInsert")
        Return Nil
    EndIf

    If MV_PAR37 == 1 .Or. MV_PAR37 == 2
        cDelete1 := DeleteChq()

        If TCSQLExec(cDelete1) < 0
            DbOnError(TCSqlError(), "cDelete1")
            Return Nil
        EndIf
    EndIf

    cSelUpdat1 += " SELECT ISNULL(MAX(E5_SEQ), '" + Space(GetSX3Cache("E5_SEQ", "X3_TAMANHO")) + "') SE5MAXSEQ "
    cSelUpdat1 += " FROM " + RetSQLName("SE5") + " SE5 "
    cSelUpdat1 += " WHERE SE5.E5_FILIAL =   " + cTable + ".E5_FILIAL "
    cSelUpdat1 +=   " AND SE5.E5_PREFIXO =  " + cTable + ".E5_PREFIXO "
    cSelUpdat1 +=   " AND SE5.E5_NUMERO =   " + cTable + ".E5_NUMERO "
    cSelUpdat1 +=   " AND SE5.E5_PARCELA =  " + cTable + ".E5_PARCELA "
    cSelUpdat1 +=   " AND SE5.E5_TIPO =     " + cTable + ".E5_TIPO "
    cSelUpdat1 +=   " AND SE5.E5_CLIFOR =   " + cTable + ".E5_CLIFOR "
    cSelUpdat1 +=   " AND SE5.E5_LOJA =     " + cTable + ".E5_LOJA "
    cSelUpdat1 +=   " AND SE5.E5_RECPAG =   " + cTable + ".E5_RECPAG "
    cSelUpdat1 +=   " AND SE5.E5_SITUACA =  " + cTable + ".E5_SITUACA "
    cSelUpdat1 +=   " AND SE5.E5_NATUREZ =  " + cTable + ".E5_NATUREZ "
    cSelUpdat1 +=   " AND SE5.E5_SITUACA NOT IN ('C','E','X') "
    cSelUpdat1 +=   " AND SE5.D_E_L_E_T_ = ' ' "
    cSelUpdat1 +=   " AND NOT EXISTS "
    cSelUpdat1 += " (SELECT A.E5_NUMERO "
    cSelUpdat1 += " FROM " + RetSQLName("SE5") + " A "
    cSelUpdat1 += " WHERE "
    cSelUpdat1 +=   " A.E5_FILIAL = SE5.E5_FILIAL "
    cSelUpdat1 +=   " AND A.E5_PREFIXO = SE5.E5_PREFIXO "
    cSelUpdat1 +=   " AND A.E5_NUMERO = SE5.E5_NUMERO "
    cSelUpdat1 +=   " AND A.E5_PARCELA = SE5.E5_PARCELA "
    cSelUpdat1 +=   " AND A.E5_TIPO = SE5.E5_TIPO "
    cSelUpdat1 +=   " AND A.E5_CLIFOR = SE5.E5_CLIFOR "
    cSelUpdat1 +=   " AND A.E5_LOJA = SE5.E5_LOJA "
    cSelUpdat1 +=   " AND A.E5_SEQ = SE5.E5_SEQ "
    cSelUpdat1 +=   " AND A.E5_TIPODOC = 'ES' "
    cSelUpdat1 += " ) "

    cUpdate1 := " UPDATE " + cTable + " SET SE5MAXSEQ = ( " + ChangeQuery(cSelUpdat1) + ") "
    cUpdate1 += " WHERE " + cTable + ".E5_ORIGEM <> 'FINA100' "
    cUpdate1 += "   AND " + cTable + ".E5_NUMERO <> '" + Space(GetSX3Cache("E5_SEQ", "X3_TAMANHO"))  + "' "

    If TCSQLExec(cUpdate1) < 0
        DbOnError(TCSqlError(), "cUpdate1")
        Return Nil
    EndIf

    If TableInDic("FKD")
        cSelUpdat2 := " SELECT ISNULL(SUM(CASE WHEN FK6.FK6_ACAO = '1' THEN FK6.FK6_VALMOV ELSE -FK6.FK6_VALMOV END), 0) "
        If MV_PAR11 == 1
            cSelUpdat2 += " FROM " + RetSQLName("FK1") + " FK1 "
            cSelUpdat2 += " INNER JOIN " + RetSQLName("FK6") + " FK6 ON "
            cSelUpdat2 += " FK6.FK6_FILIAL = FK1.FK1_FILIAL "
            cSelUpdat2 += " AND FK6.FK6_IDORIG = FK1.FK1_IDFK1 "
            cSelUpdat2 += " AND FK6.FK6_TABORI = 'FK1' "
            cSelUpdat2 += " AND FK6.D_E_L_E_T_ = ' ' "
            cSelUpdat2 += " WHERE FK6.FK6_TPDOC = 'VA' "
            cSelUpdat2 += " AND FK1_FILIAL = " + cTable + ".E5_FILIAL "
            cSelUpdat2 += " AND FK1.FK1_IDFK1 = " + cTable + ".E5_IDORIG "
            cSelUpdat2 += " AND FK1.D_E_L_E_T_ = ' ' "
            cSelUpdat2 += " AND " + cTable + ".E5_TIPODOC <> 'VA' "
        Else
            cSelUpdat2 += " FROM " + RetSQLName("FK2") + " FK2 "
            cSelUpdat2 += " INNER JOIN " + RetSQLName("FK6") + " FK6 ON "
            cSelUpdat2 += " FK6.FK6_FILIAL = FK2.FK2_FILIAL "
            cSelUpdat2 += " AND FK6.FK6_IDORIG = FK2.FK2_IDFK2 "
            cSelUpdat2 += " AND FK6.FK6_TABORI = 'FK2' "
            cSelUpdat2 += " AND FK6.D_E_L_E_T_ = ' ' "
            cSelUpdat2 += " WHERE FK6.FK6_TPDOC = 'VA' "
            cSelUpdat2 += " AND FK2_FILIAL = " + cTable + ".E5_FILIAL "
            cSelUpdat2 += " AND FK2.FK2_IDFK2 = " + cTable + ".E5_IDORIG "
            cSelUpdat2 += " AND FK2.D_E_L_E_T_ = ' ' "
            cSelUpdat2 += " AND " + cTable + ".E5_TIPODOC <> 'VA' "
        EndIf

        cUpdate2 := " UPDATE " + cTable + " SET SE5VA = (" + ChangeQuery(cSelUpdat2) + ") "

        If TCSQLExec(cUpdate2) < 0
            DbOnError(TCSqlError(), "cUpdate2")
            Return Nil
        EndIf
    EndIf

    DbSelectArea("NEWSE5")
    DbGoTop()

    //Define array para arquivo de trabalho
    AAdd(aCampos, {"LINHA", "C", 80, 0})

    //Cria arquivo de Trabalho
    If (__oFINR190 <> Nil)
        __oFINR190:Delete()
        __oFINR190 := Nil
    EndIf

    __oFINR190 := FwTemporaryTable():New("TRB")
    __oFINR190:SetFields(aCampos)
    __oFINR190:AddIndex("1", {"LINHA"})
    __oFINR190:Create()

    aColu := IIf(aTam[1] > 6, {023, 027, TamParcela("E1_PARCELA", 40, 39, 38), 042, 000, 022}, {000, 004, TamParcela("E1_PARCELA", 17, 16, 15), 019, 023, 030})

    If MV_PAR16 == 1
        DbSelectArea("SE5")
        DbSetOrder(17) //"E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ+E5_TIPODOC+E5_SEQ"
        DbGoTop()
    EndIf

    /* GESTAO - inicio */
    If MV_PAR40 == 1 .And. lNovaGestao
        nSelFil := 0
    Else
        SM0->(DbSeek(cEmpAnt + If(Empty(cFilDe), "", cFilDe), .T.))
    EndIf

    While SM0->(!EoF()) .And. SM0->M0_CODIGO == cEmpAnt .And.  If(MV_PAR40 == 1 .And. lNovaGestao, (nSelFil < nLenSelFil) .And. cFilDe <= cFilAte, SM0->M0_CODFIL <= cFilAte)
        If MV_PAR40 == 1 .And. lNovaGestao
            nSelFil++
            SM0->(DbSeek(cEmpAnt + aSelFil[nSelFil], .T.))
        EndIf
        /* GESTAO - fim */

        cFilAnt := IIf(lFwCodFil, FWGETCODFILIAL, SM0->M0_CODFIL)
        cFilNome:= SM0->M0_FILIAL
        DbSelectArea("NEWSE5")

        /* GESTAO - inicio */
        If !lNovaGestao
            If lUnidNeg .And. (cEmpresa <> FwCodEmp())
                SM0->(DbSkip())
                Loop
            EndIf
        EndIf
        /* GESTAO - fim */

        If MV_PAR11 == 2  //Pagar
            If MV_PAR39 != 3  //diferente de multinatureza verifica no SE2 se o campo esta preenchido
                SE2->(DbSetOrder(1))
                If SE2->(MsSeek(NEWSE5->(E5_FILIAL + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR + E5_LOJA))) //Alimentar a variável lMultiNat apenas se for encontrado o título na filial corrente
                    lMultiNat := .F.//Inicializa variável apenas se encontrar o título na filial corrente
                    lMultiNat := (SE2->E2_MULTNAT == "1") //pq se o campo nao estiver preenchido nao desvia para FINR199
                    lMultiNat := (lMultiNat .And. lRelMulNat)
                EndIf
            Else
                lMultiNat := lRelMulNat
            EndIf
        ElseIf MV_PAR11 = 1  //Receber
            lMultiNat := lRelMulNat
        EndIf

        If lMultiNat

            Finr199(    @nGerOrig, @nGerValor, @nGerDesc, @nGerJurMul, @nGerCM, @nGerAbLiq, @nGerAbImp, @nGerBaixado, @nGerMovFin, @nGerComp,;
                        @nFilOrig, @nFilValor, @nFilDesc, @nFilJurMul, @nFilCM, @nFilAbLiq, @nFilAbImp, @nFilBaixado, @nFilMovFin, @nFilComp,;
                        .F., cCondicao, cCond2, aColu, lContinua, cFilSE5, .T., Tamanho, @aRet, @aTotais, nOrdem, @nGerFat, @nFilFat, lNovaGestao)

            DbSelectArea("SE5")
            DbCloseArea()
            ChKFile("SE5")
            DbSelectArea("SE5")
            DbSetOrder(1)

            If Empty(FwXFilial("SE5"))
                Exit
            EndIf

            DbSelectArea("SM0")
            DbSkip()
            Loop
        Else
            cXFilSA1 := FwXFilial("SA1")
            cXFilSA2 := FwXFilial("SA2")
            cXFilSA6 := FwXFilial("SA6")
            cXFilSE1 := FwXFilial("SE1")
            cXFilSE2 := FwXFilial("SE2")
            cXFilSE5 := FwXFilial("SE5")
            cXFilSED := FwXFilial("SED")
            cXFilSEH := FwXFilial("SEH")
            cXFilSEI := FwXFilial("SEI")

            While NEWSE5->(!EoF()) .And. NEWSE5->E5_FILIAL == cXFilSE5

                DbSelectArea("NEWSE5")
                // Testa condicoes de filtro
                If (nRecChkd <> NEWSE5->SE5RECNO) .And. !Fr190TstCond()
                    NEWSE5->(DbSkip()) // filtro de registros desnecessarios
                    Loop
                Else
                    nRecChkd := NEWSE5->SE5RECNO
                EndIf

                //Titulo normal ou Adiantamento
                If (NEWSE5->E5_RECPAG == "R" .And. ! (NEWSE5->E5_TIPO $ "PA /" + MV_CPNEG)) .Or. (NEWSE5->E5_RECPAG == "P" .And. (NEWSE5->E5_TIPO $ "RA /" + MV_CRNEG))
                    cCarteira := "R"
                Else
                    cCarteira := "P"
                EndIf

                DbSelectArea("NEWSE5")
                cAnterior   := &cCond2
                nTotValor   := 0
                nTotDesc    := 0
                nTotJurMul  := 0
                nTotCM      := 0
                nCT         := 0
                nTotOrig    := 0
                nTotBaixado := 0
                nTotAbLiq   := 0
                nTotImp     := 0
                nTotMovFin  := 0
                nTotComp    := 0
                nTotFat     := 0

                While NEWSE5->(!EoF()) .And. NEWSE5->E5_FILIAL == cXFilSE5 .And. &cCond2 == cAnterior

                    lManual     := .F.
                    lSkpNewSe5  := .F.
                    DbSelectArea("NEWSE5")

                    If (Empty(NEWSE5->E5_TIPODOC) .And. MV_PAR16 == 1) .Or. (Empty(NEWSE5->E5_NUMERO)  .And. MV_PAR16 == 1)
                        lManual := .T.
                    EndIf

                    // Testa condicoes de filtro
                    If (nRecChkd <> NEWSE5->SE5RECNO) .And. !Fr190TstCond()
                        NEWSE5->(DbSkip()) // filtro de registros desnecessarios
                        Loop
                    Else
                        nRecChkd := NEWSE5->SE5RECNO
                    EndIf

                    cNumero     := NEWSE5->E5_NUMERO
                    cPrefixo    := NEWSE5->E5_PREFIXO
                    cParcela    := NEWSE5->E5_PARCELA
                    dBaixa      := NEWSE5->E5_DATA
                    cBanco      := NEWSE5->E5_BANCO
                    cAge        := NEWSE5->E5_AGENCIA
                    cContaBco   := NEWSE5->E5_CONTA
                    cNatureza   := NEWSE5->E5_NATUREZ
                    cCliFor     := NEWSE5->E5_BENEF
                    cLoja       := NEWSE5->E5_LOJA
                    cSeq        := NEWSE5->E5_SEQ
                    cNumCheq    := NEWSE5->E5_NUMCHEQ
                    cRecPag     := NEWSE5->E5_RECPAG
                    cTipoDoc    := NEWSE5->E5_TIPODOC
                    cMotBaixa   := NEWSE5->E5_MOTBX
                    cCheque     := NEWSE5->E5_NUMCHEQ
                    cSeq        := NEWSE5->E5_SEQ
                    cTipo       := NEWSE5->E5_TIPO
                    cFornece    := NEWSE5->E5_CLIFOR
                    dDigit      := NEWSE5->E5_DTDIGIT
                    lBxTit      := .F.
                    cFilorig    := NEWSE5->E5_FILORIG
                    nMoedMov    := Val(NEWSE5->E5_MOEDA)

                    cMaxSeq := NEWSE5->SE5MAXSEQ

                    //Titulo normal ou Adiantamento
                    If (NEWSE5->E5_RECPAG == "R" .And. ! (NEWSE5->E5_TIPO $ "PA /" + MV_CPNEG)) .Or. (NEWSE5->E5_RECPAG == "P" .And. (NEWSE5->E5_TIPO $ "RA /" + MV_CRNEG))
                        DbSelectArea("SE1")
                        DbSetOrder(1)
                        // Procuro SE1 pela filial origem
                        lBxTit := MsSeek(FwXFilial("SE1", cFilOrig) + cPrefixo + cNumero + cParcela + cTipo)
                        If !lBxTit
                            lBxTit := MsSeek(NEWSE5->E5_FILORIG + cPrefixo + cNumero + cParcela + cTipo)
                        EndIf
                        cCarteira := "R"
                        dDtMovFin := IIf (lManual, CToD("//"), SE1->E1_VENCREA)
                        While SE1->(!EoF()) .And. SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO == cPrefixo + cNumero + cParcela + cTipo
                            If SE1->E1_CLIENTE == cFornece .And. SE1->E1_LOJA == cLoja // Cliente igual, Ok
                                Exit
                            EndIf
                            SE1->(DbSkip())
                        End
                        If !SE1->(EoF()) .And. MV_PAR11 == 1 .And. !lManual .And. (NEWSE5->E5_RECPAG == "R" .And. !(NEWSE5->E5_TIPO $ MVPAGANT + "/" + MV_CPNEG))
                            If lFilSit .And. !Empty(NEWSE5->E5_SITCOB) //Verifica se filtra por situação MV_PAR15 em branco exibi todas situações
                                If !(NEWSE5->E5_SITCOB $ MV_PAR15)
                                    DbSelectArea("NEWSE5")
                                    NEWSE5->(DbSkip()) // filtro de registros desnecessarios
                                    Loop
                                EndIf
                            EndIf

                        EndIf
                        cCond3  := "1"
                        nDesc   := nJuros := nValor := nMulta := nJurMul := nCM := nVlMovFin := 0
                    Else
                        DbSelectArea("SE2")
                        DbSetOrder(1)
                        cCarteira := "P"
                        // Procuro SE2 pela filial origem
                        lBxTit := MsSeek(FwXFilial("SE2", cFilOrig) + cPrefixo + cNumero + cParcela + cTipo + cFornece + cLoja)

                        IIf(lBxTit, nRecSE2 := SE2->(Recno()), nRecSE2 := 0)

                        If !lBxTit
                            lBxTit := MsSeek(NEWSE5->E5_FILORIG + cPrefixo + cNumero + cParcela + cTipo + cFornece + cLoja)
                        EndIf
                        dDtMovFin := IIf(lManual, CToD("//"), SE2->E2_VENCREA)
                        cCond3  := "2"
                        nDesc   := nJuros := nValor := nMulta := nJurMul := nCM := nVlMovFin := 0
                        cCheque := IIf(Empty(NEWSE5->E5_NUMCHEQ), SE2->E2_NUMBCO, NEWSE5->E5_NUMCHEQ)
                    EndIf

                    DbSelectArea("NEWSE5")
                    cHistorico := Space(40)
                    While NEWSE5->(!EoF()) .And. NEWSE5->E5_FILIAL == cXFilSE5 .And.;
                        IIf(cCond3 == "1",;
                        NEWSE5->(E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + DToS(E5_DATA) + E5_SEQ + E5_NUMCHEQ) == cPrefixo + cNumero + cParcela + cTipo + DToS(dBaixa) + cSeq + cNumCheq,;
                        NEWSE5->(E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO + E5_CLIFOR + DToS(E5_DATA) + E5_SEQ + E5_NUMCHEQ) == cPrefixo + cNumero + cParcela + cTipo + cFornece + DToS(dBaixa) + cSeq + cNumCheq)

                        DbSelectArea("NEWSE5")
                        cTipoDoc    := NEWSE5->E5_TIPODOC
                        cCheque     := NEWSE5->E5_NUMCHEQ

                        lSkpNewSe5  := .F.
                        lAchouEmp   := .T.
                        lAchouEst   := .F.
                        nVlrGlosa   := 0

                        // Testa condicoes de filtro
                        If (nRecChkd <> NEWSE5->SE5RECNO) .And. !Fr190TstCond()
                            NEWSE5->(DbSkip()) // filtro de registros desnecessarios
                            lSkpNewSe5 := .T.
                            Loop
                        Else
                            nRecChkd := NEWSE5->SE5RECNO
                        EndIf

                        If NEWSE5->E5_LOJA != cLoja
                            Exit
                        EndIf

                        If NEWSE5->E5_FILORIG < MV_PAR33 .Or. NEWSE5->E5_FILORIG > MV_PAR34
                            DbSelectArea("NEWSE5")
                            NEWSE5->(DbSkip())
                            lSkpNewSe5 := .T.
                            Loop
                        EndIf

                        //Nao imprime os registros de emprestimos excluidos
                        If NEWSE5->E5_TIPODOC == "EP"
                            aAreaSE5 := NEWSE5->(GetArea())
                            DbSelectArea("SEH")
                            DbSetOrder(1)
                            lAchouEmp := MsSeek(cXFilSEH + SubStr(NEWSE5->E5_DOCUMEN, 1, nTamEH))
                            RestArea(aAreaSE5)
                            If !lAchouEmp
                                NEWSE5->(DbSkip())
                                lSkpNewSe5 := .T.
                                Loop
                            EndIf
                        EndIf

                        //Nao imprime os registros de pagamento de emprestimos estornados
                        If NEWSE5->E5_TIPODOC == "PE"
                            aAreaSE5 := NEWSE5->(GetArea())
                            DbSelectArea("SEI")
                            DbSetOrder(1)
                            If MsSeek(cXFilSEI + "EMP" + SubStr(NEWSE5->E5_DOCUMEN, 1, nTamEI))
                                If SEI->EI_STATUS == "C"
                                    lAchouEst := .T.
                                EndIf
                            EndIf
                            RestArea(aAreaSE5)
                            If lAchouEst
                                NEWSE5->(DbSkip())
                                lSkpNewSe5 := .T.
                                Loop
                            EndIf
                        EndIf

                        //Verifica o vencto do Titulo
                        cFilTrb := If(cCarteira == "R", "SE1", "SE2")
                        If (cFilTrb)->(!EoF()) .And. ((cFilTrb)->&(Right(cFilTrb, 2) + "_VENCREA") < MV_PAR31 .Or.;
                            (!Empty(MV_PAR32) .And. (cFilTrb)->&(Right(cFilTrb, 2) + "_VENCREA") > MV_PAR32))
                            DbSelectArea("NEWSE5")
                            NEWSE5->(DbSkip())
                            lSkpNewSe5 := .T.
                            Loop
                        EndIf

                        dBaixa      := NEWSE5->E5_DATA
                        cBanco      := NEWSE5->E5_BANCO
                        cAge        := NEWSE5->E5_AGENCIA
                        cContaBco   := NEWSE5->E5_CONTA
                        cNatureza   := NEWSE5->E5_NATUREZ
                        cCliFor     := NEWSE5->E5_BENEF
                        cSeq        := NEWSE5->E5_SEQ
                        cNumCheq    := NEWSE5->E5_NUMCHEQ
                        cRecPag     := NEWSE5->E5_RECPAG
                        cMotBaixa   := NEWSE5->E5_MOTBX
                        cTipo190    := NEWSE5->E5_TIPO
                        cFilorig    := NEWSE5->E5_FILORIG

                        //Obter moeda da conta no Banco.
                        If (cPaisLoc # "BRA" .And. !Empty(NEWSE5->E5_BANCO + NEWSE5->E5_AGENCIA + NEWSE5->E5_CONTA)) .Or. FXMultSld()
                            SA6->(DbSetOrder(1))
                            SA6->(MsSeek(cXFilSA6 + NEWSE5->E5_BANCO + NEWSE5->E5_AGENCIA + NEWSE5->E5_CONTA))
                            nMoedaBco := Max(SA6->A6_MOEDA, 1)
                        Else
                            nMoedaBco := 1
                        EndIf

                        If !Empty(NEWSE5->E5_NUMERO)
                            If (NEWSE5->E5_RECPAG == "R" .And. !(NEWSE5->E5_TIPO $ MVPAGANT + "/" + MV_CPNEG)) .Or. ;
                                (NEWSE5->E5_RECPAG == "P" .And. NEWSE5->E5_TIPO $ MVRECANT + "/" + MV_CRNEG) .Or.;
                                (NEWSE5->E5_RECPAG == "P" .And. NEWSE5->E5_TIPODOC $ "DB#OD")
                                DbSelectArea("SA1")
                                DbSetOrder(1)
                                lAchou := .F.
                                If MsSeek(cXFilSA1 + NEWSE5->E5_CLIFOR + NEWSE5->E5_LOJA)
                                    lAchou := .T.
                                EndIf
                                If !lAchou
                                    cFilOrig := NEWSE5->E5_FILIAL //Procuro SA1 pela filial do movimento
                                    If MsSeek(cFilOrig + NEWSE5->E5_CLIFOR + NEWSE5->E5_LOJA)
                                        If Upper(AllTrim(SA1->A1_NREDUZ)) == Upper(AllTrim(NEWSE5->E5_BENEF))
                                            lAchou := .T.
                                        Else
                                            cFilOrig := NEWSE5->E5_FILORIG //Procuro SA1 pela filial origem
                                            If MsSeek(cFilOrig + NEWSE5->E5_CLIFOR + NEWSE5->E5_LOJA)
                                                If Upper(AllTrim(SA1->A1_NREDUZ)) == Upper(AllTrim(NEWSE5->E5_BENEF))
                                                    lAchou := .T.
                                                EndIf
                                            EndIf
                                        EndIf
                                    Else
                                        cFilOrig := NEWSE5->E5_FILORIG //Procuro SA1 pela filial origem
                                        If MsSeek(cFilOrig + NEWSE5->E5_CLIFOR + NEWSE5->E5_LOJA)
                                            If Upper(AllTrim(SA1->A1_NREDUZ)) == Upper(AllTrim(NEWSE5->E5_BENEF))
                                                lAchou := .T.
                                            EndIf
                                        EndIf
                                    EndIf
                                EndIf
                                If lAchou
                                    cCliFor := IIf(MV_PAR30 == 1, GetLGPDValue("SA1", "A1_NREDUZ"), GetLGPDValue("SA1", "A1_NOME"))
                                Else
                                    cCliFor := Upper(AllTrim(GetLGPDValue("NEWSE5", "E5_BENEF")))
                                EndIf
                            Else
                                DbSelectArea("SA2")
                                DbSetOrder(1)
                                lAchou := .F.
                                If MsSeek(cXFilSA2 + NEWSE5->E5_CLIFOR + NEWSE5->E5_LOJA)
                                    lAchou := .T.
                                EndIf
                                If !lAchou
                                    cFilOrig := NEWSE5->E5_FILIAL //Procuro SA2 pela filial do movimento
                                    If MsSeek(cFilOrig + NEWSE5->E5_CLIFOR + NEWSE5->E5_LOJA)
                                        If Upper(AllTrim(SA2->A2_NREDUZ)) == Upper(AllTrim(NEWSE5->E5_BENEF))
                                            lAchou := .T.
                                        Else
                                            cFilOrig := NEWSE5->E5_FILORIG //Procuro SA2 pela filial origem
                                            If MsSeek(cFilOrig + NEWSE5->E5_CLIFOR + NEWSE5->E5_LOJA)
                                                If Upper(AllTrim(SA2->A2_NREDUZ)) == Upper(AllTrim(NEWSE5->E5_BENEF))
                                                    lAchou := .T.
                                                EndIf
                                            EndIf
                                        EndIf
                                    Else
                                        cFilOrig := NEWSE5->E5_FILORIG //Procuro SA2 pela filial origem
                                        If MsSeek(cFilOrig + NEWSE5->E5_CLIFOR + NEWSE5->E5_LOJA)
                                            If Upper(AllTrim(SA2->A2_NREDUZ)) == Upper(AllTrim(NEWSE5->E5_BENEF))
                                                lAchou := .T.
                                            EndIf
                                        EndIf
                                    EndIf
                                EndIf
                                If lAchou
                                    cCliFor := IIf(MV_PAR30 == 1, GetLGPDValue("SA2", "A2_NREDUZ"), GetLGPDValue("SA2", "A2_NOME"))
                                Else
                                    cCliFor := Upper(AllTrim(GetLGPDValue("NEWSE5", "E5_BENEF")))
                                EndIf
                            EndIf
                        EndIf
                        DbSelectArea("SM2")
                        DbSetOrder(1)
                        DbSeek(NEWSE5->E5_DATA)
                        DbSelectArea("NEWSE5")
                        nTaxa := 0

                        If cPaisLoc == "BRA"
                            nTaxa := NEWSE5->E5_TXMOEDA
                            If nTaxa == 0 .And. (nMoedMov <> 1 .Or. SE2->E2_MOEDA <> 1)
                                If nMoedaBco == 1
                                    nTaxa := NEWSE5->E5_VALOR / NEWSE5->E5_VLMOED2
                                Else
                                    nTaxa := NEWSE5->E5_VLMOED2 / NEWSE5->E5_VALOR
                                EndIf
                            ElseIf nTaxa > 0 .And.  nMoedMov == 1 .And. SE2->E2_MOEDA == 1 .And. (NEWSE5->E5_TIPODOC == "PA" .And. NEWSE5->E5_TIPO $ MVPAGANT)
                                nTaxa := 0
                            EndIf
                        EndIf

                        nRecSe5 := NEWSE5->SE5RECNO
                        nDesc   += IIf(MV_PAR12 == 1 .And. nMoedaBco == 1, NEWSE5->E5_VLDESCO, Round(xMoeda(NEWSE5->E5_VLDESCO, nMoedaBco, MV_PAR12, NEWSE5->E5_DATA, nDecs + 1, nTaxa), nDecs + 1))
                        nJuros  += IIf(MV_PAR12 == 1 .And. nMoedaBco == 1, NEWSE5->E5_VLJUROS, Round(xMoeda(NEWSE5->E5_VLJUROS, nMoedaBco, MV_PAR12, NEWSE5->E5_DATA, nDecs +  1, nTaxa), nDecs + 1))
                        nMulta  += IIf(MV_PAR12 == 1 .And. nMoedaBco == 1, NEWSE5->E5_VLMULTA, Round(xMoeda(NEWSE5->E5_VLMULTA, nMoedaBco, MV_PAR12, NEWSE5->E5_DATA, nDecs + 1, nTaxa), nDecs + 1))
                        nJurMul += nJuros + nMulta
                        nCM     += IIf(MV_PAR12 == 1 .And. nMoedaBco == 1, NEWSE5->E5_VLCORRE, Round(xMoeda(NEWSE5->E5_VLCORRE, nMoedaBco, MV_PAR12, NEWSE5->E5_DATA, nDecs + 1, nTaxa), nDecs + 1))

                        If lPccBaixa .And. Empty(NEWSE5->E5_PRETPIS) .And. Empty(NEWSE5->E5_PRETCOF) .And. Empty(NEWSE5->E5_PRETCSL) .And. cCarteira == "P"
                            If nRecSE2 > 0

                                aAreaBk  := GetArea()
                                aAreaSE2 := SE2->(GetArea())
                                SE2->(DbGoTo(nRecSE2))

                                nTotAbImp += (NEWSE5->E5_VRETPIS) + (NEWSE5->E5_VRETCOF) + (NEWSE5->E5_VRETCSL) + SE2->E2_INSS + SE2->E2_ISS + SE2->E2_IRRF

                                RestArea(aAreaSE2)
                                RestArea(aAreaBk)
                            Else
                                nTotAbImp += (NEWSE5->E5_VRETPIS) + (NEWSE5->E5_VRETCOF) + (NEWSE5->E5_VRETCSL) + IIf(lMvGlosa , NEWSE5->E5_VRETIRF + NEWSE5->E5_VRETISS + NEWSE5->E5_VRETINS , 0)
                            EndIf

                            nVlrGlosa := nTotAbImp
                        EndIf

                        If NEWSE5->E5_TIPODOC $ "VL/V2/BA/RA/PA/CP"
                            nValTroco := 0
                            cHistorico := NEWSE5->E5_HISTOR

                            If MV_PAR11 == 2
                                If cPaisLoc == "ARG" .And. !Empty(NEWSE5->E5_ORDREC)
                                    nValor += IIf(nMoedMov == MV_PAR12, NEWSE5->E5_VALOR, Round(xMoeda(NEWSE5->E5_VALOR, Val(NEWSE5->E5_MOEDA), MV_PAR12, NEWSE5->E5_DATA, nDecs + 1, NEWSE5->E5_TXMOEDA), nDecs + 1))
                                Else
                                    If MV_PAR12 == nMoedMov
                                        nValor += NEWSE5->E5_VALOR
                                    Else
                                        nValor += Round(xMoeda(NEWSE5->E5_VALOR, nMoedMov, MV_PAR12, NEWSE5->E5_DATA, nDecs + 1, IIf(nMoedMov == 1, 0, nTaxa), IIf(nMoedMov == 1, nTaxa, 0)), nDecs + 1)
                                    EndIf
                                EndIf
                            Else
                                If cPaisLoc <> "BRA" .And. !Empty(NEWSE5->E5_ORDREC)
                                    nValor += IIf(MV_PAR12 == 1 .And. nMoedaBco == 1, NEWSE5->E5_VALOR, Round(xMoeda(NEWSE5->E5_VLMOED2, Val(NEWSE5->E5_MOEDA), MV_PAR12, NEWSE5->E5_DATA, nDecs + 1, If(cPaisLoc == "BRA", NEWSE5->E5_TXMOEDA, 0)), nDecs + 1))
                                Else
                                    If NEWSE5->E5_VLMOED2 > 0 .And. MovMoedEs(NEWSE5->E5_MOEDA, NEWSE5->E5_TIPODOC, NEWSE5->E5_MOTBX, DTOC(NEWSE5->E5_DATA))
                                        nValor += If(MV_PAR12 == 2, NEWSE5->E5_VALOR, NEWSE5->E5_VLMOED2)
                                    Else
                                        If (MV_PAR12 == 1 .And. nMoedaBco == 1)
                                            nValor += NEWSE5->E5_VALOR
                                        ElseIf NEWSE5->E5_TIPODOC == "RA" .And. MV_PAR12 = nMoedaBco // Garantir que será impresso o valor na moeda do banco.
                                            nValor += NEWSE5->E5_VALOR
                                        ElseIf NEWSE5->E5_TIPODOC == "RA" .And. MV_PAR12 == 1 // RA sempre gera o valor na moeda 2 em Reais. Conceito da moeda 2 esta sendo revisto em 20/07/2020.
                                            nValor += NEWSE5->E5_VLMOED2
                                        ElseIf NEWSE5->E5_TIPODOC == "RA"
                                            nValor += Round(xMoeda(NEWSE5->E5_VALOR, nMoedMov, MV_PAR12, NEWSE5->E5_DATA, nDecs + 1, If(cPaisLoc == "BRA", nTaxa, 0)), nDecs + 1)
                                        Else
                                            nValor += Round(xMoeda(NEWSE5->E5_VLMOED2, SE1->E1_MOEDA, MV_PAR12, SE1->E1_BAIXA, nDecs + 1, If(cPaisLoc == "BRA", nTaxa, 0)), nDecs + 1)
                                        EndIf
                                    EndIf
                                EndIf
                            EndIf

                            If lMVLjTroco
                                lTroco := If(SubStr(NEWSE5->E5_HISTOR, 1, 3) == "LOJ", .T., .F.)
                                If lTroco
                                    nRecnoSE5 := SE5->(Recno())
                                    DbSelectArea("SE5")
                                    DbSetOrder(7)
                                    If DbSeek(cXFilSE5 + NEWSE5->E5_PREFIXO + NEWSE5->E5_NUMERO + NEWSE5->E5_PARCELA + Space(TamSX3("E5_TIPO")[1]) + NEWSE5->E5_CLIFOR + NEWSE5->E5_LOJA)
                                        While !EoF() .And. cXFilSE5 == SE5->E5_FILIAL .And. NEWSE5->E5_PREFIXO + NEWSE5->E5_NUMERO + NEWSE5->E5_PARCELA + Space(TamSX3("E5_TIPO")[1]) + NEWSE5->E5_CLIFOR + NEWSE5->E5_LOJA == SE5->E5_PREFIXO + ;
                                                            SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_CLIFOR + SE5->E5_LOJA

                                            If SE5->E5_MOEDA = "TC" .And. SE5->E5_TIPODOC = "VL" .And. SE5->E5_RECPAG = "P"
                                                nValTroco := SE5->E5_VALOR
                                            EndIf
                                            SE5->(DbSkip())
                                        End
                                    EndIf
                                    SE5->(DbGoTo(nRecnoSE5))
                                EndIf
                            EndIf

                            DbSelectArea("NEWSE5")

                            nValor -= nValTroco

                            //Pcc Baixa CR
                            If cCarteira == "R" .And. lPccBxCr .And. cPaisLoc == "BRA" .And. (IIf(lRaRtImp, NEWSE5->E5_TIPO $ MVRECANT, .T.) .Or. lPccBaixa)
                                If Empty(NEWSE5->E5_PRETPIS)
                                    nPccBxCr += IIf(MV_PAR12 == 1.And.nMoedaBco == 1, NEWSE5->E5_VRETPIS, Round(xMoeda(NEWSE5->E5_VRETPIS, nMoedaBco, MV_PAR12, NEWSE5->E5_DATA, nDecs + 1,, NEWSE5->E5_TXMOEDA), nDecs + 1))
                                EndIf
                                If Empty(NEWSE5->E5_PRETCOF)
                                    nPccBxCr += IIf(MV_PAR12 == 1.And.nMoedaBco == 1, NEWSE5->E5_VRETCOF, Round(xMoeda(NEWSE5->E5_VRETCOF, nMoedaBco, MV_PAR12, NEWSE5->E5_DATA, nDecs + 1,, NEWSE5->E5_TXMOEDA), nDecs + 1))
                                EndIf
                                If Empty(NEWSE5->E5_PRETCSL)
                                    nPccBxCr += IIf(MV_PAR12 == 1.And.nMoedaBco == 1, NEWSE5->E5_VRETCSL, Round(xMoeda(NEWSE5->E5_VRETCSL, nMoedaBco, MV_PAR12, NEWSE5->E5_DATA, nDecs + 1,, NEWSE5->E5_TXMOEDA), nDecs + 1))
                                EndIf
                            EndIf
                        Else
                            nVlMovFin   += IIf(MV_PAR12 == 1.And.nMoedaBco == 1, NEWSE5->E5_VALOR, Round(xMoeda(NEWSE5->E5_VALOR, nMoedaBco, MV_PAR12, NEWSE5->E5_DATA, nDecs + 1, nTaxa), nDecs + 1))
                            cHistorico  := IIf(Empty(NEWSE5->E5_HISTOR),"MOV FIN MANUAL", NEWSE5->E5_HISTOR)
                            cNatureza   := NEWSE5->E5_NATUREZ
                        EndIf

                        cAuxFilNome := cFilAnt + " - " + cFilNome
                        cAuxCliFor  := cCliFor
                        cAuxLote    := E5_LOTE
                        dAuxDtDispo := E5_DTDISPO
                        Exit
                    End

                    If (nDesc + nValor + nJurMul + nVlMovFin) <> 0
                        AAdd(aRet, Array(ID_ARRAYSIZE))
                        nTamRet := Len(aRet)
                        // Defaults >>>
                        aRet[nTamRet][ID_PREFIXO]   := ""
                        aRet[nTamRet][ID_NUMERO ]   := ""
                        aRet[nTamRet][ID_PARCELA]   := ""
                        aRet[nTamRet][ID_TIPO]      := ""
                        aRet[nTamRet][ID_CLIFOR]    := ""
                        aRet[nTamRet][ID_LOJA]      := ""
                        // <<< Defaults

                        aRet[nTamRet][ID_FILIAL]    := cAuxFilNome
                        aRet[nTamRet][ID_E5BENEFIC] := cAuxCliFor
                        aRet[nTamRet][ID_E5LOTE]    := cAuxLote
                        aRet[nTamRet][ID_E5DTDISPO] := dAuxDtDispo

                        //Cálculo do Abatimento
                        If cCarteira == "R" .And. !lManual
                            DbSelectArea("SE1")
                            nRecno      := Recno()
                            nAbat       := 0
                            nAbatLiq    := 0

                            // Entra no If abaixo se titulo totalmente baixado e se for a maior sequnecia de baixa no SE5
                            If !SE1->E1_TIPO $ MVRECANT + "/" + MV_CRNEG .And. Empty(SE1->E1_SALDO) .And. cMaxSeq == cSeq
                                // Calcula o valor total de abatimento do titulo e impostos se houver
                                nTotAbImp  := 0
                                nAbat := SumAbatRec(cPrefixo, cNumero, cParcela, SE1->E1_MOEDA, "V", dBaixa, @nTotAbImp)
                                nAbatLiq := nAbat - nTotAbImp

                                cCliFor190 := SE1->E1_CLIENTE + SE1->E1_LOJA

                                SA1->(DbSetOrder(1))
                                If cPaisLoc == "BRA" .And. SA1->(DbSeek(cXFilSA1 + cCliFor190))
                                    lCalcIRF := SA1->A1_RECIRRF == "1" .And. SA1->A1_IRBAX == "1" // se for na baixa
                                Else
                                    lCalcIRF := .F.
                                EndIf
                                If lCalcIRF .And. !lMvGlosa
                                    nTotAbImp += SE1->E1_IRRF
                                EndIf
                            EndIf
                            DbSelectArea("SE1")
                            DbGoTo(nRecno)
                        ElseIf !lManual
                            DbSelectArea("SE2")
                            nRecno := Recno()
                            nAbat := 0
                            nAbatLiq := 0
                            If !SE2->E2_TIPO $ MVPAGANT + "/" + MV_CPNEG .And. Empty(SE2->E2_SALDO) .And. cMaxSeq == cSeq //NEWSE5->E5_SEQ
                                nAbat       := SomaAbat(cPrefixo, cNumero, cParcela, "P", MV_PAR12,, cFornece, cLoja)
                                nAbatLiq    := nAbat
                            EndIf
                            DbSelectArea("SE2")
                            DbGoTo(nRecno)
                        EndIf

                        aRet[nTamRet][ID_CLIFOR]    := " "
                        aRet[nTamRet][ID_LOJA]      := " "

                        If MV_PAR11 == 1 .And. aTam[1] > 6 .And. !lManual
                            If lBxTit
                                aRet[nTamRet][ID_CLIFOR] := SE1->E1_CLIENTE
                                aRet[nTamRet][ID_LOJA]   := SE1->E1_LOJA
                            EndIf
                            aRet[nTamRet][ID_NOMECLIFOR] := AllTrim(cCliFor)
                        ElseIf MV_PAR11 == 2 .And. aTam[1] > 6 .And. !lManual
                            If lBxTit
                                aRet[nTamRet][ID_CLIFOR] := SE2->E2_FORNECE
                                aRet[nTamRet][ID_LOJA]   := SE2->E2_LOJA
                            EndIf
                            aRet[nTamRet][ID_NOMECLIFOR] := AllTrim(cCliFor)
                        EndIf

                        aRet[nTamRet][ID_PREFIXO] := cPrefixo
                        aRet[nTamRet][ID_NUMERO ] := cNumero
                        aRet[nTamRet][ID_PARCELA] := cParcela
                        aRet[nTamRet][ID_TIPO]    := cTipo

                        If !lManual
                            DbSelectArea("TRB")
                            lOriginal := .T.
                            //Baixas a Receber
                            If cCarteira == "R"
                                cCliFor190 := SE1->E1_CLIENTE + SE1->E1_LOJA
                                nVlr := Round(xMoeda(SE1->E1_VALOR, SE1->E1_MOEDA, MV_PAR12, SE1->E1_BAIXA, nDecs + 1, If(cPaisLoc == "BRA", nTaxa, 0)), nDecs + 1)
                                //Baixa de PA
                            Else
                                cCliFor190 := SE2->E2_FORNECE + SE2->E2_LOJA

                                If cPaisLoc == "BRA"
                                    lCalcIRF:= Posicione("SA2", 1, cXFilSA2 + cCliFor190, "A2_CALCIRF") == "1" .Or.;//1-Normal, 2-Baixa
                                            Posicione("SA2", 1, cXFilSA2 + cCliFor190, "A2_CALCIRF") == " "
                                Else
                                    lCalcIRF:=.F.
                                EndIf

                                nVlImp := 0
                                //efetua tratamento de Soma de Impostos
                                If lConsImp   //default soma os impostos no valor original (MV_PAR41)
                                    // MV_MRETISS "1" retencao do ISS na Emissao, "2" retencao na Baixa.
                                    nVlImp := SE2->E2_INSS + IIf(GetNewPar("MV_MRETISS", "1") == "1", SE2->E2_ISS, 0) + IIf(lCalcIRF, SE2->E2_IRRF, 0)
                                    If ! lPccBaixa  // SE PCC NA EMISSAO SOMA PCC
                                        nVlImp += SE2->E2_VRETPIS + SE2->E2_VRETCOF + SE2->E2_VRETCSL
                                    EndIf
                                EndIf
                                //impostos sempre estarão em reais.
                                nVlImp  := Round(xMoeda(nVlImp, 1, MV_PAR12, SE2->E2_BAIXA, nDecs + 1, IIf(MV_PAR12 == 1, nTaxa, 0), IIf(MV_PAR12 > 1, nTaxa, 0)), nDecs + 1)
                                If MV_PAR12 == SE2->E2_MOEDA
                                    nVlr := SE2->E2_VALOR + nVlImp
                                Else
                                    nVlr := Round(xMoeda(SE2->E2_VALOR, SE2->E2_MOEDA, MV_PAR12, SE2->E2_BAIXA, nDecs + 1, IIf(MV_PAR12 == 1, nTaxa, 0), IIf(MV_PAR12 > 1, nTaxa, 0)) + nVlImp, nDecs + 1)
                                EndIf
                            EndIf
                            aRet[nTamRet, ID_E5RECNO] := nRecSE5
                            DbGoTo(nRecSe5)
                            cFilTrb := If(cCarteira == "R", "SE1", "SE2")
                            If DbSeek(IIf(cFilTrb == "SE1", cXFilSE1, cXFilSE2) + cPrefixo + cNumero + cParcela + cCliFor190 + cTipo)
                                nAbat       := 0
                                lOriginal   := .F.
                            Else
                                If cMaxSeq == cSeq
                                    RecLock("TRB", .T.)
                                    Replace linha With IIf(cFilTrb == "SE1", cXFilSE1, cXFilSE2) + cPrefixo + cNumero + cParcela + cCliFor190 + cTipo
                                    MsUnlock()
                                EndIf
                            EndIf
                        Else
                            DbSelectArea("SE5")
                            aRet[nTamRet, ID_E5RECNO] := nRecSE5
                            DbGoTo(nRecSe5)
                            nVlr := Round(xMoeda(E5_VALOR, nMoedaBco, MV_PAR12, E5_DATA, nDecs + 1,, If(cPaisLoc == "BRA", nTaxa, 0)), nDecs + 1)

                            nAbat:= 0
                            lOriginal := .T.
                            nRecSe5 := NEWSE5->SE5RECNO
                            DbSelectArea("TRB")
                        EndIf

                        If cCarteira == "R"
                            If (!lManual)
                                If MV_PAR13 == 1  // Utilizar o Hist¢rico da Baixa ou Emiss„o
                                    cHistorico := IIf(Empty(cHistorico), SE1->E1_HIST, cHistorico)
                                Else
                                    cHistorico := IIf(Empty(SE1->E1_HIST), cHistorico, SE1->E1_HIST)
                                EndIf
                            EndIf
                            If aTam[1] <= 6 .And. !lManual
                                If lBxTit
                                    aRet[nTamRet][ID_CLIFOR]    := SE1->E1_CLIENTE
                                    aRet[nTamRet][ID_LOJA]      := SE1->E1_LOJA
                                EndIf
                                aRet[nTamRet][ID_NOMECLIFOR]    := AllTrim(cCliFor)
                            EndIf
                            cMascNat := MascNat(cNatureza)
                            aRet[nTamRet][ID_NATUREZA] := If(Len(AllTrim(cNatureza)) > 8, cNatureza, cMascNat)
                            If Empty(dDtMovFin) .Or. dDtMovFin == Nil
                                dDtMovFin := CToD("  /  /  ")
                            EndIf
                            aRet[nTamRet][ID_VENCIMENTO]    := IIf(lManual, dDtMovFin, SE1->E1_VENCREA) //Vencto
                            aRet[nTamRet][ID_HISTORICO]     := AllTrim(cHistorico)
                            aRet[nTamRet][ID_DTBAIXA]       := dBaixa
                            cChaveTit := SE1->(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO)
                        Else
                            If MV_PAR13 == 1  // Utilizar o Hist¢rico da Baixa ou Emiss„o
                                cHistorico := IIf(Empty(cHistorico), SE2->E2_HIST, cHistorico)
                            Else
                                cHistorico := IIf(Empty(SE2->E2_HIST), cHistorico, SE2->E2_HIST)
                            EndIf
                            If aTam[1] <= 6 .And. !lManual
                                If lBxTit
                                    aRet[nTamRet][ID_CLIFOR] := SE2->E2_FORNECE
                                    aRet[nTamRet][ID_LOJA]   := SE2->E2_LOJA
                                EndIf
                                aRet[nTamRet][ID_NOMECLIFOR] := AllTrim(cCliFor)
                            EndIf
                            cMascNat := MascNat(cNatureza)
                            aRet[nTamRet][ID_NATUREZA] := If(Len(AllTrim(cNatureza)) > 8, cNatureza, cMascNat)
                            If Empty(dDtMovFin) .Or. dDtMovFin == Nil
                                dDtMovFin := CToD("  /  /  ")
                            EndIf
                            aRet[nTamRet][ID_VENCIMENTO] := IIf(lManual, dDtMovFin, SE2->E2_VENCREA)
                            If !Empty(cCheque)
                                aRet[nTamRet][ID_HISTORICO] := AllTrim(cCheque) + "/" + Trim(cHistorico)
                            Else
                                aRet[nTamRet][ID_HISTORICO] := AllTrim(cHistorico)
                            EndIf
                            aRet[nTamRet][ID_DTBAIXA] := dBaixa
                            cChaveTit := SE2->(E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA)
                        EndIf

                        aRet[nTamRet][ID_VALORORIG] := nVlr
                        nCT++
                        aRet[nTamRet][ID_JUROSMULTA] := nJurMul

                        If cCarteira == "R" .And. MV_PAR12 == SE1->E1_MOEDA
                            aRet[nTamRet][ID_CORRECAO] := 0

                        ElseIf cCarteira == "P" .And. MV_PAR12 == SE2->E2_MOEDA
                            aRet[nTamRet][ID_CORRECAO] := 0

                        Else
                            aRet[nTamRet][ID_CORRECAO] := nCM 
                        EndIf

                        //PCC Baixa CR
                        //Somo aos abatimentos de impostos, os impostos PCC na baixa.
                        //Caso o calculo do PCC CR seja pela emissao, esta variavel estara zerada
                        //O sistema encontra duas vezes o valor de impostos por conta do parâmetro mv_glosa, portanto é necessário somar apenas um deles
                        If lMvGlosa .And. cCarteira == "R" .And. Empty(nTotAbImp) .And. nVlrGlosa > 0 .And. nVlrGlosa > nPccBxCr
                            nTotAbImp := nVlrGlosa
                        ElseIf !lMvGlosa
                            nTotAbImp := nTotAbImp + nPccBxCr
                        EndIf

                        aRet[nTamRet][ID_DESCONTO  ] := nDesc           //PicTure tm(nDesc, 11, nDecs)
                        aRet[nTamRet][ID_ABATIMENTO] := nAbatLiq        //Picture tm(nAbatLiq, 11, nDecs)
                        aRet[nTamRet][ID_IMPOSTO   ] := nTotAbImp       //Picture tm(nTotAbImp, 11, nDecs)

                        If nVlMovFin <> 0
                            aRet[nTamRet][ID_TOTALPAGO] := nVlMovFin    //PicTure tm(nVlMovFin, 15, nDecs)
                        Else
                            aRet[nTamRet][ID_TOTALPAGO] := nValor       //PicTure tm(nValor, 15, nDecs)
                        EndIf
                        aRet[nTamRet][ID_BANCO]   := cBanco
                        aRet[nTamRet][ID_AGENCIA] := cAge
                        aRet[nTamRet][ID_CONTA]   := cContaBco
                        If Len(DToC(dDigit)) <= 8
                            aRet[nTamRet][ID_DTDIGITACAO] := dDigit
                        Else
                            aRet[nTamRet][ID_DTDIGITACAO] := dDigit
                        EndIf

                        If Empty(cMotBaixa)
                            cMotBaixa := "NOR"  //NORMAL
                        EndIf

                        aRet[nTamRet][ID_MOTIVO ] := SubStr(cMotBaixa, 1, 3)
                        aRet[nTamRet][ID_FILORIG] := cFilorig

                        aRet[nTamRet][ID_LORIGINAL] := lOriginal
                        aRet[nTamRet][ID_VALORPG]   := If(nVlMovFin <> 0, nVlMovFin, If(F190MovBco(cMotBaixa), nValor, 0))
                        aRet[nTamRet][ID_TEMVALOR]  := aRet[nTamRet][ID_VALORPG] = 0
                        nTotOrig    += If(lOriginal, nVlr, 0)
                        nTotBaixado += If(cTipoDoc $ "CP/BA" .And. cMotBaixa $ "CMP/FAT", 0, nValor) //não soma, pois já somou no principal
                        nTotDesc    += nDesc
                        nTotJurMul  += nJurMul
                        nTotCM      += nCM
                        nTotAbLiq   += nAbatLiq
                        nTotImp     += nTotAbImp
                        nTotValor   += aRet[nTamRet][ID_VALORPG]
                        nTotMovFin  += nVlMovFin
                        nTotComp    += If(cTipoDoc == "CP", nValor, 0)
                        nTotFat     += If(cMotBaixa $ "FAT", nValor, 0)
                        nDesc       := nJurMul := nValor := nCM := nAbat := nTotAbImp := nAbatLiq := nVlMovFin := 0
                        nPccBxCr    := 0    //PCC Baixa CR

                        If lOriginal .And. aRet[nTamRet][ID_VALORORIG] != 0 .And. Len(aChaveTit) > 0 .And. AScan(aChaveTit, cChaveTit) > 0
                            aRet[nTamRet][ID_LORIGINAL] := .F.
                        Else
                            AAdd(aChaveTit, cChaveTit)
                        EndIf

                        aRet[nTamRet][ID_TIPODOC] := cTipoDoc

                        aRet[nTamRet][ID_VALORVA] := NEWSE5->SE5VA

                        If !lRelMulNat
                            SE5->(DbGoTo(aRet[nTamRet][ID_E5RECNO]))
                            If !lRelatInit
                                lRelatInit := .T.
                                InitReport(oReport, aRet, @nI, @cTotText)
                                oBaixas:Init()
                            EndIf

                            nI := nTamRet
                            If oReport:Cancel()
                                nI++
                                EndReport()
                                FwFreeArray(aChaveTit)
                                Return Nil
                            EndIf

                            If aRet[nTamRet][ID_CLIFOR] == Nil
                                aRet[nTamRet][ID_CLIFOR] := ""
                            EndIf

                            If aRet[nTamRet][ID_TIPODOC] == "VA"
                                ZeraVA(aRet[nTamRet])
                            EndIf

                            oBaixas:PrintLine()

                            If (nOrdem == 1 .Or. nOrdem == 6 .Or. nOrdem == 8)
                                cTotText := STR0071 + " : " + DToC(aRet[nTamRet][nCond1])   //"Sub Total"
                            Else //nOrdem == 2 .Or. nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 5 .Or. nOrdem == 7
                                cTotText := STR0071 + " : " + aRet[nTamRet][nCond1]         //"Sub Total"
                                If nOrdem == 2 //Banco
                                    SA6->(DbSetOrder(1))
                                    SA6->(MsSeek(cXFilSA6 + aRet[nTamRet][nCond1] + aRet[nTamRet][ID_AGENCIA] + aRet[nTamRet][ID_CONTA]))
                                    cTotText += " " + Trim(SA6->A6_NOME)
                                ElseIf nOrdem == 3 //Natureza
                                    SED->(DbSetOrder(1))
                                    SED->(MsSeek(cXFilSED + StrTran (aRet[nTamRet][nCond1], ".", "")))
                                    cTotText += SED->ED_DESCRIC
                                EndIf
                            EndIf

                            If lVarFil
                                cTxtFil := aRet[nTamRet][ID_FILIAL]
                            EndIf
                            nI++
                        EndIf
                    EndIf

                    If !lSkpNewSe5
                        DbSelectArea("NEWSE5")
                        NEWSE5->(DbSkip())
                    EndIf

                    If lManual
                        Exit
                    EndIf
                End

                If (nOrdem == 1 .Or. nOrdem == 6 .Or. nOrdem == 8)
                    cQuebra := DToS(cAnterior)
                Else //nOrdem == 2 .Or. nOrdem == 3 .Or. nOrdem == 4 .Or. nOrdem == 5 .Or. nOrdem == 7
                    cQuebra := cAnterior
                EndIf

                If (nTotValor + nDesc + nJurMul + nCM + nTotOrig + nTotMovFin + nTotComp + nTotFat) > 0
                    If nCT > 0
                        If nTotBaixado > 0
                            AAdd(aTotais, {cQuebra, STR0028, nTotBaixado})  //"Baixados"
                        EndIf
                        If nTotMovFin > 0
                            AAdd(aTotais, {cQuebra, STR0031, nTotMovFin})  //"Mov Fin."
                        EndIf
                        If nTotComp > 0
                            AAdd(aTotais, {cQuebra, STR0037, nTotComp})  //"Compens."
                        EndIf
                        If nTotFat > 0
                            AAdd(aTotais, {cQuebra, STR0076, nTotFat})  //"Bx.Fatura"
                        EndIf
                    EndIf
                EndIf

                //Incrementa Totais Gerais
                nGerBaixado += nTotBaixado
                nGerMovFin  += nTotMovFin
                nGerComp    += nTotComp
                nGerFat     += nTotFat

                //Incrementa Totais Filial
                nFilOrig    += nTotOrig
                nFilValor   += nTotValor
                nFilDesc    += nTotDesc
                nFilJurMul  += nTotJurMul
                nFilCM      += nTotCM
                nFilAbLiq   += nTotAbLiq
                nFilAbImp   += nTotImp
                nFilBaixado += nTotBaixado
                nFilMovFin  += nTotMovFin
                nFilComp    += nTotComp
                nFilFat     += nTotFat
            End
        EndIf

        //Imprimir TOTAL por filial somente quando houver 1 filial ou mais.
        If MV_PAR17 == 1 .And. SM0->(RecCount()) >= 1
            If nFilBaixado > 0
                AAdd(aTotais, {IIf(lFwCodFil, FWGETCODFILIAL, SM0->M0_CODFIL), STR0028, nFilBaixado})  //"Baixados"
            EndIf
            If nFilMovFin > 0
                AAdd(aTotais, {IIf(lFwCodFil, FWGETCODFILIAL, SM0->M0_CODFIL), STR0031, nFilMovFin})  //"Mov Fin."
            EndIf
            If nFilComp > 0
                AAdd(aTotais, {IIf(lFwCodFil, FWGETCODFILIAL, SM0->M0_CODFIL), STR0037, nFilComp})  //"Compens."
            EndIf
            If nFilFat > 0
                AAdd(aTotais, {IIf(lFwCodFil, FWGETCODFILIAL, SM0->M0_CODFIL), STR0076, nFilFat})  //"Compens."
            EndIf

            If MV_PAR17 == 2 .And. Empty(cXFilSE5)
                Exit
            EndIf

            nFilOrig    := nFilJurMul := nFilCM := nFilDesc := nFilAbLiq := nFilAbImp := nFilValor := 0
            nFilBaixado := nFilMovFin := nFilComp := nFilFat:= 0
        EndIf

        DbSelectArea("SM0")
        SM0->(DbSkip())
    End

    If nGerBaixado > 0
        AAdd(aTotais, {STR0075, STR0028, nGerBaixado})  //"Baixados"
    EndIf

    If nGerMovFin > 0
        AAdd(aTotais, {STR0075, STR0031, nGerMovFin})   //"Mov Fin."
    EndIf

    If nGerComp > 0
        AAdd(aTotais, {STR0075, STR0037, nGerComp})     //"Compens."
    EndIf

    If nGerFat > 0
        AAdd(aTotais, {STR0075, STR0076, nGerFat})      //"Bx.Fatura"
    EndIf

    SM0->(DbGoTo(nRecEmp))
    cFilAnt := IIf(lFwCodFil, FWGETCODFILIAL, SM0->M0_CODFIL)

    If (__oFINR190 <> Nil)
        __oFINR190:Delete()
        __oFINR190 := Nil
    EndIf

    /* GESTAO - inicio */
    If !Empty(cTmpSE5Fil)
        CtbTmpErase(cTmpSE5Fil)
    EndIf
    /* GESTAO - fim */

    EndReport()

    FwFreeArray(aChaveTit)

    DbSelectArea("SE5")
    DbSetOrder(1)

Return NIl



