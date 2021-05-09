#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINR25
BK - Planilha diária de Pagamentos
@Return
@author Marcos Bispo Abrahão
@since 24/01/2020
@version P11
/*/
//-------------------------------------------------------------------

User Function BKFINR25()

Local nF    	:= 0
Local NIL		:= 0
Local cCampo	:= ""
Local cTipo 	:= ""
Local nTam  	:= 0
Local nDec  	:= 0
Local cPict 	:= ""
Local cTitC 	:= ""
Local nTamCol   := 0
Local lTotal    := .F.
Local nI 		:= 0

Private cTTipos 	:= ""
Private cXTipos 	:= ""

Private cTitulo     := "Planilha diária de Pagamentos"
Private cPerg       := "BKFINR25"

Private aParam		:=	{}
Private aRet		:=	{}

Private dDataI  	:= CTOD("")
Private dDataF  	:= CTOD("")
Private cCadGrp     := "Nao"
Private cAltPrd     := "Nao"
Private cDetCC      := "Nao"
Private lDetCC		:= .F.

Private aFields     := {}
//Private aOthers		:= {}
Private aCabs       := {}
Private aCampos     := {}
Private aTitulos    := {}
Private aPlans      := {}
Private aDbf        := {}
Private aTamCol		:= {}
Private aTotal		:= {}
Private cAliasQry   := ""
Private cAliasTrb   := GetNextAlias()
Private nCont       := 0
Private aTotais     := {}
Private aLF         := {}
Private nTop		:= 3
Private nTopV		:= nTop + 1
Private cCVal  		:= "I"
Private cCSal  		:= "J"

Private aPrd  		:= {}
Private aPlan2 		:= {}
Private nColNForn 	:= 0
Private nColTipo 	:= 0
Private nColVenc 	:= 0
Private nColValor	:= 0
Private nColVSaldo	:= 0
Private nColItem	:= 0
Private nColDiv		:= 0
Private nColRat		:= 0

Private nPosT 		:= 0
Private nPosV 		:= 0
Private nPosS 		:= 0
Private nPosL 		:= 0

Private cNValores	:= "VALORES"+cEmpAnt
Private cNTipoBk	:= "TIPOBK"+cEmpAnt
Private cNSaldos	:= "SALDOS"+cEmpAnt
Private cNItensCC	:= "ITENSCC"+cEmpAnt

Private cNTotais	:= "TOTAIS"+cEmpAnt
Private cNTSaldos	:= "TSALDOS"+cEmpAnt

aAdd( aParam, { 1, "Data Inicial:" 	 , dDataBase	, "" , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Data Final:" 	 , dDataBase	, "" , "", ""	, "" , 70  , .F. })  
aAdd( aParam ,{ 2, "Cadastrar Grupos", "Nao"		, {"Nao", "Sim"}, 40,'.T.'  ,.T.})
aAdd( aParam ,{ 2, "Alterar Produtos", "Nao"		, {"Nao", "Sim"}, 40,'.T.'  ,.T.})
aAdd( aParam ,{ 2, "Detalhar C.Custo", "Nao"		, {"Nao", "Sim"}, 40,'.T.'  ,.T.})

If !BkFR25()
   Return
EndIf

If Substr(cCadGrp,1,1) == "S"
	U_BKFINA26()
EndIf

aAdd(aTitulos,cPerg+"/"+TRIM(cUserName)+" - "+cTitulo)

aPlan2 := U_BKR25PL2()


For nI := 1 To Len(aPlan2)
	If !Empty(aPlan2[nI,3])
		cTTipos += aPlan2[nI,3]+"/"
	EndIf
Next

aAdd(aFields,{"XX_FORNECE","E2_FORNECE"})
aAdd( aTamCol, 10.45)

aAdd(aFields,{"XX_LOJA"   ,"E2_LOJA"})
aAdd( aTamCol, 03.90)

aAdd(aFields,{"XX_NOMFOR" ,"E2_NOMFOR"})
aAdd( aTamCol, 25.00)
nColNForn := Len(aFields)

aAdd(aFields,{"XX_PREFIXO","E2_PREFIXO"})
aAdd( aTamCol, 08.40)

aAdd(aFields,{"XX_NUM"    ,"E2_NUM"})
aAdd( aTamCol, 10.30)

aAdd(aFields,{"XX_PARCELA","E2_PARCELA"})
aAdd( aTamCol, 06.90)

aAdd(aFields,{"XX_XXTIPBK","E2_XXTIPBK","","Tipo","@!","C",6,0})
aAdd( aTamCol, 06.60)

nColTipo := Len(aFields)

aAdd(aFields,{"XX_XXDTPBK","ZU_DESCR","(cAliasTrb)->XX_XXDTPBK"})
aAdd( aTamCol, 20.00)

aAdd(aFields,{"XX_PRODUTO","D1_COD","(cAliasTrb)->XX_PRODUTO"})
aAdd( aTamCol, 16.00)

aAdd(aFields,{"XX_PORTADO","E2_PORTADO"})
aAdd( aTamCol, 10.00)

aAdd(aFields,{"XX_FORMPGT" ,"","(cAliasTrb)->XX_FORMPGT","Forma pgto","@!","C",40,0})
aAdd( aTamCol, 35.00)

aAdd(aFields,{"XX_DESC"   ,"B1_DESC","(cAliasTrb)->XX_DESC"})
aAdd( aTamCol, 30.00)

aAdd(aFields,{"XX_VENCREA","E2_VENCREA"})
aAdd( aTamCol, 16.00)
nColVenc := Len(aFields)

aAdd(aFields,{"XX_JUST"   ,"F1_XXJSPGT","(cAliasTrb)->XX_JUST"})
aAdd( aTamCol, 30.00)

If lDetCC

	aAdd(aFields,{"XX_CC"     ,"D1_CC","(cAliasTrb)->XX_CC"})
	aAdd( aTamCol, 13.00)

	aAdd(aFields,{"XX_DESCCC","CTT_DESC01","(cAliasTrb)->XX_DESCCC"})
	aAdd( aTamCol, 45.00)

	aAdd(aFields,{"XX_HIST" ,"","(cAliasTrb)->XX_HIST","Historico","","M",10,0})
	aAdd( aTamCol, 50.00)

	aAdd(aFields,{"XX_RATEIO","","(cAliasTrb)->XX_RATEIO","Rateio","@!","C",1,0})
	aAdd( aTamCol, 05.00)
	nColRat := Len(aFields)

	aAdd(aFields,{"XX_VALITEM","D1_TOTAL","(cAliasTrb)->XX_VALITEM"})
	aAdd( aTamCol, 14.00)
	nColItem := Len(aFields)
	
EndIf

aAdd(aFields,{"XX_VALOR"  ,"E2_VALOR"})
aAdd( aTamCol, 14.00)
nColValor := Len(aFields)

aAdd(aFields,{"XX_SALDO"  ,"E2_SALDO"})
aAdd( aTamCol, 14.00)
nColVSaldo := Len(aFields)

aAdd( aTamCol, 05.00)  // Coluna divisória
nColDiv := LEN(aTamCol)

aAdd( aTamCol, 50.00)  
nPosT := LEN(aTamCol)

aAdd( aTamCol, 14.00)  
nPosV := LEN(aTamCol)

aAdd( aTamCol, 14.00)  
nPosS := LEN(aTamCol)

aAdd( aTamCol, 36.00)  
nPosL := LEN(aTamCol)

//aAdd(aFields,{"XX_SALDO","","(cAliasTrb)->(XX_SALDO)","Saldo Consolidado",cPict,"N",18,2})
//aOthers := {"E2_NATUREZ","E2_TIPO"}

aDbf    := {}

For nF := 1 To Len(aFields)

	aAdd(aCampos,"(cAliasTrb)->"+aFields[nF,1])
	cCampo := aFields[nF,1]
	cTipo  := ""
	nTam   := 0
	nDec   := 0
	cPict  := ""
	cTitC  := ""

	If Len(aFields[NF]) > 3
		If !Empty(aFields[nF,4])
			cTitC := aFields[nF,4]
		EndIf
	EndIf

	If Len(aFields[NF]) > 4
		If !Empty(aFields[nF,5])
			cPict := aFields[nF,5]
		EndIf
	EndIf

	If Len(aFields[NF]) > 5
		If !Empty(aFields[nF,6])
			cTipo := aFields[nF,6]
		EndIf
	EndIf

	If Len(aFields[NF]) > 6
		If !Empty(aFields[nF,7])
			nTam := aFields[nF,7]
		EndIf
	EndIf

	If Len(aFields[NF]) > 7
		If !Empty(aFields[nF,8])
			nDec := aFields[nF,8]
		EndIf
	EndIf

	If Empty(cTitC)
		cTitC := RetTitle(aFields[nF,2])
	EndIf
	If Empty(cPict)
		cPict := GetSX3Cache(aFields[nF,2],"X3_PICTURE")
	EndIf
	If Empty(cTipo)
		cTipo := GetSX3Cache(aFields[nF,2],"X3_TIPO")
	EndIf
	If nTam = 0
		nTam  := GetSX3Cache(aFields[nF,2],"X3_TAMANHO")
	EndIf
	If nDec = 0 .and. GetSX3Cache(aFields[nF,2],"X3_DECIMAL") <> Nil
		nDec  := GetSX3Cache(aFields[nF,2],"X3_DECIMAL")			
	EndIf
		
	aAdd( aDbf, {cCampo , cTipo, nTam, nDec } )
	aAdd( aCabs, cTitC)

	nTamCol := 0
	lTotal  := .F.
	If cTipo == "N"
		nTamCol := 17
		lTotal  := .T.
	ElseIf cTipo == "D"
		nTamCol := 15
	Else
		If nTam > 8
			nTamCol := nTam + 1
		EndIf
	EndIf
	
	aAdd( aTotal,lTotal)
Next

///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,cAliasTrb,.f.,.f. )

oTmpTb := FWTemporaryTable():New( cAliasTrb )
oTmpTb:SetFields( aDbf )

//oTmpTb:AddIndex("01", {"DESCR"} )
oTmpTb:Create()

nCont:= 0

Processa( {|| ProcBKR25() })

If nCont > 0
	MsAguarde({|| BKFINX25(cAliasTrb,TRIM(cPerg),cTitulo,aCampos,aCabs)},"Aguarde","Gerando planilha...",.F.)
Else
    MsgStop("Não foram encontrados registros para esta seleção", cPerg)
EndIf

oTmpTb:Delete()
///(cAliasTrb)->(Dbclosearea())
///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())

If Substr(cAltPrd,1,1) == "S"
	AltGrpFin()
EndIf

Return

Static Function BkFR25
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg      ,.T.         ,.T.))
	lRet     := .T.

	dDataI   := mv_par01
	dDataF   := mv_par02
	cCadGrp  := mv_par03
	cAltPrd  := mv_par04
	cDetCC   := mv_par05
	lDetCC	 := IIF(SUBSTR(cDetCC,1,1)=="N",.F.,.T.)
	cTitulo  := "Planilha Diária de Pagamentos - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
Endif
Return lRet


Static Function ProcBKR25
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

cQuery := "SELECT "+ CRLF
cQuery += " E2_FORNECE"+ CRLF
cQuery += " ,E2_LOJA"+ CRLF
cQuery += " ,E2_NOMFOR"+ CRLF
cQuery += " ,E2_PREFIXO"+ CRLF
cQuery += " ,E2_NUM"+ CRLF
cQuery += " ,E2_PARCELA"+ CRLF
cQuery += " ,E2_XXTIPBK"+ CRLF
cQuery += " ,E2_PORTADO"+ CRLF
cQuery += " ,E2_VENCREA"+ CRLF
cQuery += " ,E2_VALOR"+ CRLF
cQuery += " ,E2_SALDO"+ CRLF
cQuery += " ,R_E_C_N_O_ AS E2RECNO"+ CRLF
cQuery += " FROM "+RETSQLNAME("SE2")+" SE2" + CRLF
cQuery += " WHERE SE2.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " AND SE2.E2_FILIAL = '" + xFilial("SE2") + "' "+ CRLF
cQuery += " AND SE2.E2_TIPO NOT IN "+FormatIn(MVABATIM,";")+ CRLF
If !Empty(dDataI)
	cQuery += " AND SE2.E2_VENCREA >= '"+DTOS(dDataI)+"'"+ CRLF
EndIf
If !Empty(dDataF)
	cQuery += " AND SE2.E2_VENCREA <= '"+DTOS(dDataF)+"'"+ CRLF
EndIf          
cQuery += " ORDER BY E2_VENCREA,E2_NUM,E2_PREFIXO,E2_PARCELA"+ CRLF

u_LogMemo("BKFINR25.SQL",cQuery)

cAliasQry := "TMPR25" //GetNextAlias()

//TCQUERY cQuery NEW ALIAS "TMPR25"

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPR25', .F., .T.)
TCSETFIELD(cAliasQry,"E2_VENCREA","D", 8,0)
TCSETFIELD(cAliasQry,"E2_VALOR"  ,"N",18,2)
	
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
		(cAliasTrb)->XX_XXDTPBK := Posicione("SZU",1,xFilial("SZU")+cTipoBk,"ZU_DESCR")
	Else
		lRH := .T.
	EndIf

	// Gravar valor padrão do item caso não haja Doc de Entrada
	If lDetCC
		(cAliasTrb)->XX_VALITEM := (cAliasTrb)->XX_VALOR
		(cAliasTrb)->XX_RATEIO  := "N"
		(cAliasTrb)->XX_CC 		:= cCCusto
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
		(cAliasTrb)->XX_XXDTPBK := Posicione("SZU",1,xFilial("SZU")+cTipoBk,"ZU_DESCR")
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
				//(cAliasTrb)->XX_XXTIPBK	:= aItem[nx,3]				
				//(cAliasTrb)->XX_XXDTPBK := Posicione("SZU",1,xFilial("SZU")+aItem[nx,3],"ZU_DESCR")
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
				(cAliasTrb)->XX_XXDTPBK := Posicione("SZU",1,xFilial("SZU")+(cAliasTrb)->XX_XXTIPBK,"ZU_DESCR")
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

	(cAliasTrb)->XX_XXDTPBK := Posicione("SZU",1,xFilial("SZU")+(cAliasTrb)->XX_XXTIPBK,"ZU_DESCR")
	
	(cAliasTrb)->(MsUnLock())
		
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbSkip())
ENDDO

(cAliasQry)->(dbCloseArea())

dbSelectArea(cAliasTrb)
dbGoTop()

Return


Static Function BKFINX25(cAliasTrb,cArqXlsx,cTitulo,aCampos,aCabs)
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
		MsgStop("Não será possivel gerar a planilha "+cFile+", feche o arquivo","BKFINR25")
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



STATIC Function AltGrpFin()
Local lOk       := .T.
Local cTitulo2	:= "Alteração de Grupo Financeiro - Produtos"

PRIVATE oSay2
PRIVATE oDlg2,oListID2,oPanelLeft2

DEFINE MSDIALOG oDlg2 TITLE cTitulo2 FROM 000,000 TO 320,630 PIXEL 

@ 000,000 MSPANEL oPanelLeft2 OF oDlg2 SIZE 320,225

@ 005, 005 LISTBOX oListID2 FIELDS HEADER "Produto","Descrição","Grupo" SIZE 310,130 OF oPanelLeft2 PIXEL 
oListID2:SetArray(aPrd)
oListID2:bLine := {||	{aPrd[oListId2:nAt][1],;
						aPrd[oListId2:nAt][2],;
						aPrd[oListId2:nAt][3]}}  

oListID2:bLDblClick := {|| EDITPRD() ,oListID2:DrawSelect(), }
  
@ 140,015 Button "&Gravar" Size 050,013 Pixel Action (lOk:=.T.,oDlg2:End())

ACTIVATE MSDIALOG oDlg2 CENTERED 

If ( lOk )
	lOk:=.F.
	GravPrd()
ENDIF

RETURN NIL


STATIC FUNCTION EditPrd()

lEditCell(aPrd,oListID2,'@!',3)

RETURN NIL




STATIC FUNCTION GravPrd()
Local iX 	:= 0

For iX := 1 To Len(aPrd)
	SB1->(dbSeek(xFilial("SB1")+aPrd[iX,1]))
	RecLock("SB1",.F.)
	SB1->B1_XXGRPF := aPrd[iX,3]
	MsUnlock("SB1")
Next

RETURN NIL




User Function BKR25PL2()
Local aPlan := {}
aAdd(aPlan,{.T.,"PESSOAL",""})
aAdd(aPlan,{.F.,"Folha CLT","LPM/LAD/LAS/LFG/COM/HEX/GRA/DIN/DSA"})
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
