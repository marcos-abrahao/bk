#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} GeraXlsx
Generico - Gera planilha excel 
@Return
@author Marcos Bispo Abrahão
@since 04/04/2020
@version P12
/*/


// Exemplo
//	    AADD(aCabsX,Capital(cNomeC))
//	    AADD(aCamposX,_cAlias+"->"+FIELDNAME(nI))
//	    AADD(aImpr,.T.)
//	    AADD(aFormula,NIL)
//	    AADD(aFormat,NIL)
//	    AADD(aTotal,NIL)

//AADD(aPlansX,{_cAlias,_cPlan,"",_cTitulo,aCamposX,aCabsX,aImpr,aFormula,aFormat,aTotal,_cQuebra,_lClose})
//U_GeraXlsx(aPlansX,_cTitulo,_cAlias,.F.)


User Function GeraXlsx( _aPlans,_cTitulo,_cProg, lClose, _aParam )
Local oProcess
oProcess := MsNewProcess():New({|| ProcXlsx(oProcess,_aPlans,_cTitulo,_cProg, lClose, _aParam)}, "Processando...", "Aguarde...", .T.)
oProcess:Activate()
Return Nil


Static Function ProcXlsx( oProcess,_aPlans,_cTitulo,_cProg, lClose, _aParam )

Local oExcel := YExcel():new()
Local oObjPerg
Local oAlCenter

Local aPergunte
Local aLocPar := {}

Local aTitulos:= {}
Local aTamCol := {}
Local aTotal  := {}
Local nTamCol := 0
Local aStruct := {}
Local aRef    := {}

Local cTipo   := ""
Local lTotal  := .F.
Local lFormula:= .F.
Local nI 	  := 0
Local nJ	  := 0
Local nF	  := 0
Local nLin    := 1
Local nTop    := 1
Local cFile   := _cProg+"-"+DTOS(Date())
Local nRet    := 0
Local cDirTmp := "C:\TMP"
Local nCont	  := 0

Local aArea   := GetArea()
Local nPl     := 0

Local _cAlias  := ""
Local _aCabs   := {}
Local _cPlan   := ""
Local _cFiltra := ""
Local _xTitulos:= ""
Local _aCampos := {}
Local _aImpr   := {}
Local _aFormula:= {}
Local _aFormat := {}
Local _aTotal  := {}
Local _cQuebra := ""
Local _lClose  := .F.

Local nCabFont
Local nLinFont
Local nTitFont
Local nTit2Font
Local nTit3Font
Local nSCabFont
Local nCabCor
Local nSCabCor
Local nBordas
Local nFmtNum0
Local nFmtNum2
Local nFmtNum5
Local nFmtPer5
Local nTotFont
Local nCabStyle	
Local nSCabStyle	
Local nV0Style
Local nV2Style
Local nV5Style
Local nP5Style
Local nD2Style
Local nG2Style 	
Local nT0Style
Local nT2Style
Local nT5Style
Local nTitStyle	
Local nTit2Style	
Local nTit3Style	
Local nTotStyle	
Local nIDImg

Local nStyle

Private xCampo,yCampo
Private xQuebra

oProcess:SetRegua1(LEN(_aPlans)+2)

oProcess:IncRegua1("Preparando configurações...")

If lClose == NIL
   lClose := .T.
EndIf

MakeDir(cDirTmp)

oExcel:new(cFile)

oAlCenter	:= oExcel:Alinhamento("center","center")
oVtCenter	:= oExcel:Alinhamento(,"center")

				//nTamanho,cCorRGB,cNome,cfamily,cScheme,lNegrito,lItalico,lSublinhado,lTachado
nCabFont	:= oExcel:AddFont(10,"FFFFFFFF","Calibri","2",,.T.)
nLinFont	:= oExcel:AddFont(10,"00000000","Calibri","2")
nTitFont	:= oExcel:AddFont(20,"00000000","Calibri","2",,.T.)
nTit2Font	:= oExcel:AddFont(10,"00000000","Calibri","2")
nTit3Font	:= oExcel:AddFont(12,"00000000","Calibri","2",,.T.)
nSCabFont	:= oExcel:AddFont(10,"00000000","Calibri","2",,.T.)

nCabCor		:= oExcel:CorPreenc("9E0000")	//Cor de Fundo Vermelho BK
nSCabCor	:= oExcel:CorPreenc("D9D9D9")	//Cor de Fundo de sub cabeçalho

nBordas 	:= oExcel:Borda("ALL")

nFmtNum0	:= oExcel:AddFmtNum(0/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)
nFmtNum2	:= oExcel:AddFmtNum(2/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)
nFmtNum5	:= oExcel:AddFmtNum(5/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)

nFmtPer5	:= oExcel:AddFmtNum(5/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,"%"/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)
nTotFont 	:= oExcel:AddFont(10,56,"Calibri","2",,.T.,.F.,.F.,.F.)

nCabStyle	:= oExcel:AddStyles(/*numFmtId*/,nCabFont/*fontId*/,nCabCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})
nSCabStyle	:= oExcel:AddStyles(/*numFmtId*/,nSCabFont/*fontId*/,nSCabCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})

nV0Style	:= oExcel:AddStyles(nFmtNum0/*numFmtId*/,nLinFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nV2Style	:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,nLinFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nV5Style	:= oExcel:AddStyles(nFmtNum5/*numFmtId*/,nLinFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nP5Style	:= oExcel:AddStyles(nFmtPer5/*numFmtId*/,nLinFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})

nD2Style	:= oExcel:AddStyles(14/*numFmtId*/,nLinFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})
nG2Style 	:= oExcel:AddStyles(/*numFmtId*/,nLinFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nT0Style	:= oExcel:AddStyles(nFmtNum0/*numFmtId*/,nTotFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nT2Style	:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,nTotFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nT5Style	:= oExcel:AddStyles(nFmtNum5/*numFmtId*/,nTotFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nTitStyle	:= oExcel:AddStyles(/*numFmtId*/,nTitFont/*fontId*/,/*fillId*/,/*borderId*/,/*xfId*/,{oVtCenter})
nTit2Style	:= oExcel:AddStyles(/*numFmtId*/,nTit2Font/*fontId*/,/*fillId*/,/*borderId*/,/*xfId*/,{oVtCenter})
nTit3Style	:= oExcel:AddStyles(/*numFmtId*/,nTit3Font/*fontId*/,/*fillId*/,/*borderId*/,/*xfId*/,{oVtCenter})
nTotStyle	:= oExcel:AddStyles(/*numFmtId*/,nTotFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)

nIDImg		:= oExcel:ADDImg("LGMID"+cEmpAnt+".PNG")	//Imagem no Protheus_data

FOR nPl := 1 TO LEN(_aPlans)

	_cAlias  := _aPlans[nPl,01]
	_cPlan   := _aPlans[nPl,02]
	_cFiltra := _aPlans[nPl,03]
	_xTitulos:= _aPlans[nPl,04] 
	_aCampos := _aPlans[nPl,05]
	_aCabs   := _aPlans[nPl,06]
	_aImpr   := _aPlans[nPl,07]
	_aFormula:= _aPlans[nPl,08]
	_aFormat := _aPlans[nPl,09]
	_aTotal  := _aPlans[nPl,10]
	_cQuebra := _aPlans[nPl,11]
	_lClose  := _aPlans[nPl,12]

	oProcess:IncRegua1("Gerando planilha "+_cPlan+"...")

	If Empty(_aFormat)
		_aFormat := Array(Len(_aCabs))
	EndIf

	aRef     := {}
	nCont	 := 0
	nLin     := 1
	nTop     := 1

	oExcel:ADDPlan(_cPlan,"0000FF")		//Adiciona nova planilha

	oExcel:nTamLinha := 34
	oExcel:Img(nIDImg,1,1,40,40,/*"px"*/,)

	// Titulo
	aTitulos := {}
	If ValType(_xTitulos) == "C"
		aAdd(aTitulos,_xTitulos)
	Else
		For nJ := 1 To LEN(_xTitulos)
			aAdd(aTitulos,_xTitulos[nJ])
		Next
	EndIf
	aAdd(aTitulos,_cProg+" - Data base: "+DTOC(dDataBase) +" - Emitido em: "+DTOC(DATE())+"-"+SUBSTR(TIME(),1,5)+" - "+cUserName)

	nLin := 1
	For nJ := 1 To Len(aTitulos)
		oExcel:mergeCells(nLin,2,nLin,Len(_aCabs))
		If nJ == 1
			oExcel:Cell(nLin,2,aTitulos[nJ],,nTitStyle)
			oExcel:nTamLinha := nil
		Else
			oExcel:Cell(nLin,2,aTitulos[nJ],,nTit2Style)
		EndIf
		nLin++
	Next

	nTop := nLin + 1

	// Cabeçalho
	For nJ := 1 To Len(_aCabs)

	    IF !EMPTY(_aImpr)  // Coluna a ignorar
			IF !_aImpr[nJ]
		    	Loop
		 	ENDIF 
		ENDIF

		oExcel:Cell(nLin,nJ,_aCabs[nJ],,nCabStyle)

	NEXT

	// Tamanho das colunas e colunas de Total
	aTamCol := {}
	aTotal  := {}

	(_cAlias)->(dbgotop())
	aStruct := (_cAlias)->(dbStruct())

	For nI :=1 to LEN(_aCampos)

	    IF !EMPTY(_aImpr)  // Coluna a ignorar
			IF !_aImpr[nI]
		    	Loop
		 	ENDIF 
		ENDIF

		nTamCol := 0
		lTotal  := .F.
		cTipo   := ""

		nF := aScan(aStruct,{|x| x[1] = SUBSTR(_aCampos[nI],aT(">",_aCampos[nI])+1) })
		If nF > 0
			cTipo   := aStruct[nF,2]
			//nTamCol := aStruct[nF,3]+aStruct[nF,4]+1
			nTamCol := aStruct[nF,3]+1
			If cTipo == "N"
				lTotal := .T.
				If aStruct[nF,4] == 0
					cTipo := "N0"
				ElseIf aStruct[nF,4] > 2 .AND. aStruct[nF,4] < 6
					cTipo := "N5"
					nTamCol += 5
				Else
					nTamCol := 15
				EndIf
			Elseif cTipo == "D"
				nTamCol := 12
			ElseiF nTamCol > 150
				nTamCol := 150
			EndIf
		EndIf

		If Empty(cTipo)
			xCampo := &(_aCampos[nI])
			cTipo  := ValType(xCampo)

			If cTipo == "N"
				nTamCol := 15
				lTotal  := .T.
			ElseIf cTipo == "D"
				nTamCol := 12
			Else
				If Len(xCampo) > 8
					If Len(xCampo) < 150
						nTamCol := Len(xCampo) + 1
					Else
						nTamCol := 150
					EndIf
				EndIf
			EndIf
		EndIf

		If Empty(_aFormat[nI])
			_aFormat[nI] := cTipo
		EndIf

	    IF !EMPTY(_aTotal)
			IF _aTotal[nI] <> NIL 
				IF lTotal
			    	lTotal  := _aTotal[nI]
			 	ENDIF
		 	ENDIF 
		ENDIF

		If nI == 1 .AND. nTamCol < 8
			// Não reduzir a coluna do Logo
			nTamCol := 8
		EndIf

		aAdd( aTamCol, nTamCol)
		aAdd( aTotal,lTotal)

	Next

	For nJ := 1 To Len(aTamCol)
		If aTamCol[nJ] > 0
			oExcel:AddTamCol(nJ,nJ,aTamCol[nJ])
		EndIf
	NEXT

	(_cAlias)->(dbgotop())
	ProcRegua((_cAlias)->(RecCount())) 
	If !empty(_cFiltra)
		(_cAlias)->(dbsetfilter({|| &_cFiltra} , _cFiltra))
	Endif

	oProcess:SetRegua2(LastRec())

	Do While (_cAlias)->(!eof()) 

        oProcess:IncRegua2("Processando linhas...")

		nLin++
		nCont++

		For nI :=1 to LEN(_aCampos)

			IF !EMPTY(_aImpr)  // Coluna a ignorar
				IF !_aImpr[nI]
					Loop
				ENDIF 
			ENDIF

			xCampo	:= &(_aCampos[nI])

			//Tipo	:= ValType(xCampo)
			//If !Empty(_aFormat[nI])
				cTipo := _aFormat[nI]
			//EndIf

			nF		:= 0
			lFormula:= .F.

			If !Empty(_aFormula)
				nF := aScan(_aFormula,{|x| x[1]=nCont .AND. x[2]= _aCampos[nI]})
			EndIf

			If nF > 0
				// Formula
				If !Empty(_aFormula[nf,3])
					lFormula:= .T.
					xCampo  := _aFormula[nf,3]
				EndIf

				// "TIPO"
				If !Empty(_aFormula[nf,4])
					cTipo := _aFormula[nf,4]
				EndIf

				// NOME
				If !Empty(_aFormula[nf,5])
					oExcel:AddNome(_aFormula[nf,5],nLin, nI, nLin, nI)
				EndIf

				// REFERENCIA
				If !Empty(_aFormula[nf,6])
					aAdd(aRef,{_aFormula[nf,6],oExcel:Ref(nLin, nI)})
					// Criar Array para Guardar a referencia concatenada
					//oExcel:AddNome(_aFormula[nf,5],nLin, nI, nLin, nI)
				EndIf

			EndIf

			If !Empty(xCampo) .AND. Substr(cTipo,1,1) $ "NP" .AND. ValType(xCampo) == "C" .AND. !IsAlpha(xCampo)
				yCampo := ALLTRIM(xCampo)

				If "," $ xCampo
					yCampo := STRTRAN(yCampo,".","")
					yCampo := STRTRAN(yCampo,",",".")
				EndIf
				
				If "%" $ xCampo
					cTipo := "P"
				EndIf
				//	xCampo := VAL(yCampo) / 100
				//Else
					xCampo := VAL(yCampo)
				//EndIf
				
			EndIf

			nStyle := nG2Style
			If cTipo == "N"
				nStyle := nV2Style
			ElseIf cTipo == "N0"
				nStyle := nV0Style
			ElseIf cTipo == "N5"
				nStyle := nV5Style
			ElseIf cTipo == "P"
				nStyle := nP5Style
			ElseIf cTipo == "D"
				nStyle := nD2Style
			ElseIf cTipo == "S"
				nStyle := nSCabStyle
			EndIf

			If lFormula
				oExcel:Cell(nLin,nI,0,xCampo,nStyle)
			Else
				oExcel:Cell(nLin,nI,xCampo,,nStyle)
			EndIf

		Next

		(_cAlias)->(dbskip())
	EndDo

	oExcel:AutoFilter(nTop-1,1,nLin,Len(_aCabs))	//Auto filtro
	oExcel:AddPane(nTop-1,1)	//Congela paineis

	nLin++
	// Linha de Total
	oExcel:Cell(nLin,1,"Total ("+ALLTRIM(STR(nCont))+")",,nTotStyle)
	If nCont > 0
		For nI := 2 To Len(aTotal)
			If aTotal[nI]
				oExcel:AddNome("P"+ALLTRIM(STR(nPl,1,0))+"COL"+ALLTRIM(STR(nI,3,0)),nTop, nI, nLin-1, nI)
				nStyle := nT2Style
				If _aFormat[nI] == "N0"
					nStyle := nT0Style
				ElseIf _aFormat[nI] == "N5"
					nStyle := nT5Style
				EndIf
				oExcel:Cell(nLin,nI,0,"SUBTOTAL(9,"+"P"+ALLTRIM(STR(nPl,1,0))+"COL"+ALLTRIM(STR(nI,3,0))+")",nStyle)
			EndIf
		Next
	EndIf

	If _lClose   
	   (_cAlias)->(dbCloseArea())
	EndIf

Next

oProcess:IncRegua1("Listando parâmetros...")

// Planilha de Parâmetros
If ValType(_aParam) == "A"
	For nI := 1 TO LEN(_aParam)
		xCampo := "MV_PAR"+STRZERO(nI,2)
		aAdd(aLocPar,{_aParam[nI,2],cValToChar(&xCampo)})
	Next
Else
	oObjPerg := FWSX1Util():New()
	oObjPerg:AddGroup(_cProg)
	oObjPerg:SearchGroup()
	aPergunte := oObjPerg:GetGroup(_cProg)
	If !Empty(aPergunte[2])
		For nI := 1 TO Len(aPergunte[2])
			xCampo := "MV_PAR"+STRZERO(nI,2)
			aAdd(aLocPar,{aPergunte[2,nI,"CX1_PERGUNT"],cValToChar(&xCampo)})
		Next
	EndIf
EndIf

If Len(aLocPar) > 0
	nLin := 1
	oExcel:ADDPlan("Parâmetros","D9D9D9")		//Adiciona nova planilha
	oExcel:SetDefRow(.T.,{1,4})
	oExcel:AddTamCol(1,2,50)

	For nJ := 1 To Len(aTitulos)
		oExcel:mergeCells(nLin,1,nLin,2)
		oExcel:Cell(nLin,1,aTitulos[nJ],,nTit3Style)
		nLin++
	Next

	oExcel:Cell(nLin,1,"Parâmetros - "+_cProg,,nSCabStyle)
	oExcel:Cell(nLin,2,"Conteúdo",,nSCabStyle)


	For nI := 1 TO LEN(aLocPar)
		nLin++
		oExcel:Cell(nLin,1,aLocPar[nI,1],,nG2Style)
		oExcel:Cell(nLin,2,aLocPar[nI,2],,nG2Style)
	Next
EndIf

// Grava a Planilha
cFile := cDirTmp+"\"+cFile+".xlsx"
If File(cFile)
	nRet:= FERASE(cFile)
	If nRet < 0
		MsgAlert("Não será possivel gerar a planilha "+cFile+", feche o arquivo",_cProg)
	EndIf
EndIf

oExcel:Gravar(cDirTmp+"\",.T.,.T.)

RestArea(aArea)

Return Nil


User Function QryToXlsx(_cAlias,_cPlan,_cTitulo,_aDefs,_cQuebra,_lClose)
// _Adefs: {Campo,Formula,Titulo,Impr,Align,Format,Total}
Local nI       := 0
Local aCabsX   := {}
Local aCamposX := {}                 
Local aPlansX  := {} 
Local cNomeC   := {}
Local aImpr    := {}
Local aAlign   := {}
Local aFormat  := {}
Local aTotal   := {}

Default _cPlan   := _cAlias
Default _cTitulo := _cAlias
Default _lClose  := .F.
Default _aDefs   := {}
Default _cQuebra := ""

dbSelectArea(_cAlias)
FOR nI := 1 TO FCOUNT() 

	cNomeC := RetTitle(FIELDNAME(nI))

	nX := aScan(_aDefs,{|x| x[1] == FIELDNAME(nI) })
	If nX > 0
        // Formula
		If _aDefs[nX,2] <> NIL
		    AADD(aCamposX,_aDefs[nX,2])
		Else
		    AADD(aCamposX,_cAlias+"->"+FIELDNAME(nI))
		EndIf
		
		// Titulo
		If _aDefs[nX,3] <> NIL
		    AADD(aCabsX,_aDefs[nX,3])
		Else
			AADD(aCabsX,Capital(cNomeC))
		EndIf

		// Imprime
		If _aDefs[nX,4] <> NIL
		    AADD(aImpr,_aDefs[nX,4])
		Else
			AADD(aImpr,.T.)
		EndIf
		
		// Align
		If _aDefs[nX,5] <> NIL
		    AADD(aAlign,_aDefs[nX,5])
		Else
			AADD(aAlign,NIL)
		EndIf

		// Format
		If _aDefs[nX,6] <> NIL
		    AADD(aFormat,_aDefs[nX,6])
		Else
			AADD(aFormat,NIL)
		EndIf

		// Total
		If _aDefs[nX,7] <> NIL
		    AADD(aTotal,_aDefs[nX,7])
		Else
			AADD(aTotal,NIL)
		EndIf

    Else
		//If nI <= LEN(_aTitulos)
		//	If !EMPTY(_aTitulos[nI])
		//		cNomeC := _aTitulos[nI]
		//	EndIf
		//EndIf
		
		If EMPTY(cNomeC)
			cNomeC := FIELDNAME(nI)
		//Else
		//    cNomeC := GetSx3Cache( FIELDNAME(nI) , "X3_DESCRIC" )
		EndIf
		
	    AADD(aCabsX,Capital(cNomeC))
	    AADD(aCamposX,_cAlias+"->"+FIELDNAME(nI))
	    AADD(aImpr,.T.)
	    AADD(aAlign,NIL)
	    AADD(aFormat,NIL)
	    AADD(aTotal,NIL)

    EndIf
NEXT

AADD(aPlansX,{_cAlias,_cPlan,"",_cTitulo,aCamposX,aCabsX,aImpr,aAlign,aFormat,aTotal,_cQuebra,_lClose})
U_GeraXlsx(aPlansX,_cTitulo,_cAlias,.F.)

Return nil

// Marcos - v04/04/20
// Exemplo:

//  ... aAdd(aCabec,"Total")
//	... aAdd(aItens,ZZ7->ZZ7_DTASSC)
//	... Aadd(aDados, aItens )

//	AADD(aPlans,{aDados,cPerg,cTitExcel,aCabec,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */ })   
//	MsAguarde({|| U_ArrToXml(aPlans,cTitExcel,cPerg,.T.)},"Aguarde","Gerando planilha...",.F.)

User Function ArrToXlsx( _aPlans,_cTitulo,_cProg, _lZebra, _cDirHttp )

Local oExcel := YExcel():new()
Local oAlCenter
Local aTamCol := {}
Local aTotal  := {}
Local nTamCol := 0
Local cTipo   := ""
Local lTotal  := .F.
Local nI 	  := 0
Local nJ	  := 0
Local nRow	  := 0
Local nLin    := 1
Local nTop    := 1
Local cFile   := _cProg+"-"+DTOS(Date())
Local nRet    := 0
Local cDirTmp := "C:\TMP"
Local nCont	  := 0

Local aArea   := GetArea()
Local nPl     := 0

Local _aDados    := {}
Local _cPlan     := ""
Local _xTitulos  := "" 
Local _aCabs     := {}
Local _aImpr     := {}
Local _aAlign    := {}
Local _aFormat   := {}
Local _aTotal    := {}

Local nCabFont
Local nTitFont
Local nCabCor
Local nBordas
Local nFmtNum2
Local nTotFont
Local nCabStyle	
Local nV2Style
Local nD2Style
Local nG2Style 	
Local nT2Style
Local nTitStyle	
Local nTit2Style	
Local nTotStyle	
Local nIDImg

Default _cTitulo := ""
Default _lZebra  := .T.
Default _cDirHttp:= ""
Private cFiltra  := ""
Private xCampo
Private xQuebra

If !Empty(_cDirHttp)
	cDirTmp := _cDirHttp
EndIf

MakeDir(cDirTmp)

oExcel:new(cFile)

oAlCenter	:= oExcel:Alinhamento("center","center")
oVtCenter	:= oExcel:Alinhamento(,"center")

				//nTamanho,cCorRGB,cNome,cfamily,cScheme,lNegrito,lItalico,lSublinhado,lTachado
nCabFont	:= oExcel:AddFont(10,"FFFFFFFF","Calibri","2",,.T.)
nLinFont	:= oExcel:AddFont(10,"00000000","Calibri","2")
nTitFont	:= oExcel:AddFont(20,"00000000","Calibri","2",,.T.)
nTit2Font	:= oExcel:AddFont(10,"00000000","Calibri","2")

nCabCor		:= oExcel:CorPreenc("9E0000")	//Cor de Fundo Vermelho BK

nBordas 	:= oExcel:Borda("ALL")
nFmtNum2	:= oExcel:AddFmtNum(2/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)
nTotFont 	:= oExcel:AddFont(10,56,"Calibri","2",,.T.,.F.,.F.,.F.)

nCabStyle	:= oExcel:AddStyles(/*numFmtId*/,nCabFont/*fontId*/,nCabCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})
nV2Style	:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,nLinFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nD2Style	:= oExcel:AddStyles(14/*numFmtId*/,nLinFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})
nG2Style 	:= oExcel:AddStyles(/*numFmtId*/,nLinFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nT2Style	:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,nTotFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nTitStyle	:= oExcel:AddStyles(/*numFmtId*/,nTitFont/*fontId*/,/*fillId*/,/*borderId*/,/*xfId*/,{oVtCenter})
nTit2Style	:= oExcel:AddStyles(/*numFmtId*/,nTit2Font/*fontId*/,/*fillId*/,/*borderId*/,/*xfId*/,{oVtCenter})
nTotStyle	:= oExcel:AddStyles(/*numFmtId*/,nTotFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)

nIDImg		:= oExcel:ADDImg("LGMID"+cEmpAnt+".PNG")	//Imagem no Protheus_data

FOR nPl := 1 TO LEN(_aPlans)

	_aDados  := _aPlans[nPl,01]
	_cPlan   := _aPlans[nPl,02]
	_xTitulos:= _aPlans[nPl,03] 
	_aCabs   := _aPlans[nPl,04]
	_aImpr   := _aPlans[nPl,05]
	_aAlign  := _aPlans[nPl,06]
	_aFormat := _aPlans[nPl,07]
	_aTotal  := _aPlans[nPl,08]

	nCont	 := 0
	nLin     := 1
	nTop     := 1

	oExcel:ADDPlan(_cPlan,"0000FF")		//Adiciona nova planilha

	oExcel:nTamLinha := 34
	oExcel:Img(nIDImg,1,1,40,40,/*"px"*/,)

	// Titulo
	aTitulos := {}
	If ValType(_xTitulos) == "C"
		aAdd(aTitulos,_xTitulos)
	Else
		For nJ := 1 To LEN(_xTitulos)
			aAdd(aTitulos,_xTitulos[nJ])
		Next
	EndIf
	aAdd(aTitulos,_cProg+" - Emitido em: "+DTOC(DATE())+"-"+SUBSTR(TIME(),1,5)+" - "+cUserName)

	nLin := 1
	For nJ := 1 To Len(aTitulos)
		oExcel:mergeCells(nLin,2,nLin,Len(_aCabs))
		If nJ == 1
			oExcel:Cell(nLin,2,aTitulos[nJ],,nTitStyle)
			oExcel:nTamLinha := nil
		Else
			oExcel:Cell(nLin,2,aTitulos[nJ],,nTit2Style)
		EndIf
		nLin++
	Next

	nTop := nLin + 1

	// Cabeçalho
	For nJ := 1 To Len(_aCabs)

	    IF !EMPTY(_aImpr)  // Coluna a ignorar
			IF !_aImpr[nJ]
		    	Loop
		 	ENDIF 
		ENDIF

		oExcel:Cell(nLin,nJ,_aCabs[nJ],,nCabStyle)

	NEXT

	// Tamanho das colunas e colunas de Total
	aTamCol := {}
	aTotal  := {}

	For nI :=1 to LEN(_aCabs)

	    IF !EMPTY(_aImpr)  // Coluna a ignorar
			IF !_aImpr[nI]
		    	Loop
		 	ENDIF 
		ENDIF

        If len(_aDados) > 0
		    xCampo := _aDados[1,nI]
		Else
			xCampo := ""
		EndIf

		cTipo := ValType(xCampo)

		nTamCol := 0
		lTotal  := .F.
		If cTipo == "N"
			nTamCol := 15
			lTotal  := .T.
		ElseIf cTipo == "D"
			nTamCol := 13
		Else
			If Len(xCampo) > 8
				nTamCol := Len(xCampo) + 1
			EndIf
		EndIf

	    IF !EMPTY(_aTotal)
			IF _aTotal[nI] <> NIL 
				IF lTotal
			    	lTotal  := _aTotal[nI]
			 	ENDIF
		 	ENDIF 
		ENDIF

/*
	    IF !EMPTY(_aAlign)
			IF _aAlign[nI] <> NIL
		    	nAlign  := _aAlign[nI]
		 	ENDIF 
		ENDIF
		    
	    IF !EMPTY(_aFormat)
			IF _aFormat[nI] <> NIL
		    	nFormat  := _aFormat[nI]
		    	IF nFormat = 4
		    		nFormat := 1
		    	ENDIF
		 	ENDIF 
		ENDIF
*/

		aAdd( aTamCol, nTamCol)
		aAdd( aTotal,lTotal)

	Next

	For nJ := 1 To Len(aTamCol)
		If aTamCol[nJ] > 0
			oExcel:AddTamCol(nJ,nJ,aTamCol[nJ])
		EndIf
	NEXT

	For nRow := 1 To Len(_aDados)

		IncProc("Gerando planilha "+_cPlan+"...")   

		nLin++
		nCont++

		For nI :=1 to LEN(_aCabs)

			IF !EMPTY(_aImpr)  // Coluna a ignorar
				IF !_aImpr[nI]
					Loop
				ENDIF 
			ENDIF

			xCampo := _aDados[nRow,nI]

			If ValType(xCampo) == "N"
				oExcel:Cell(nLin,nI,xCampo,,nV2Style)
			ElseIf ValType(xCampo) == "D"
				oExcel:Cell(nLin,nI,xCampo,,nD2Style)
			Else
				oExcel:Cell(nLin,nI,xCampo,,nG2Style)
			EndIf
		Next

	Next

	If LEN(_aDados) > 0
		oExcel:AutoFilter(nTop-1,1,nLin,Len(_aCabs))	//Auto filtro
		oExcel:AddPane(nTop-1,1)	//Congela paineis

		nLin++
		// Linha de Total
		oExcel:Cell(nLin,1,"Total ("+ALLTRIM(STR(nCont))+")",,nTotStyle)
		For nI := 2 To Len(aTotal)
			If aTotal[nI]
				oExcel:AddNome("P"+ALLTRIM(STR(nPl,1,0))+"COL"+ALLTRIM(STR(nI,3,0)),nTop, nI, nLin-1, nI)
				oExcel:Cell(nLin,nI,0,"SUBTOTAL(9,"+"P"+ALLTRIM(STR(nPl,1,0))+"COL"+ALLTRIM(STR(nI,3,0))+")",nT2Style)
			EndIf
		Next
	EndIf
Next

cFile := cDirTmp+"\"+cFile+".xlsx"
If File(cFile)
	nRet:= FERASE(cFile)
	If nRet < 0
		MsgAlert("Não será possivel gerar a planilha, feche o arquivo "+cFile,_cProg)
	EndIf
EndIf

oExcel:Gravar(cDirTmp+"\",.T.,.T.)

RestArea(aArea)

Return

