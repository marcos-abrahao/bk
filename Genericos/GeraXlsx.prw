// Marcos - v17/01/19
#INCLUDE "PROTHEUS.CH"

// Exemplo
//	    AADD(aCabsX,Capital(cNomeC))
//	    AADD(aCamposX,_cAlias+"->"+FIELDNAME(nI))
//	    AADD(aImpr,.T.)
//	    AADD(aAlign,NIL)
//	    AADD(aFormat,NIL)
//	    AADD(aTotal,NIL)

//AADD(aPlansX,{_cAlias,_cPlan,"",_cTitulo,aCamposX,aCabsX,aImpr,aAlign,aFormat,aTotal,_cQuebra,_lClose})
//MsAguarde({|| U_GeraXml(aPlansX,_cTitulo,_cAlias,.F.)},"Aguarde","Gerando planilha...",.F.)

User Function GeraXlsx( _aPlans,_cTitulo,_cProg, lClose, _lZebra )

Local oExcel := YExcel():new()
Local oAlCenter
Local aTamCol := {}
Local aTotal  := {}
Local nTamCol := 0
Local cTipo   := ""
Local lTotal  := .F.
Local nI 	  := 0
Local nJ	  := 0
Local nLin    := 1
Local nTop    := 1
Local cFile   := _cProg+"-"+DTOS(Date())
Local nRet    := 0
Local cDirTmp := "C:\TMP"

Local aArea   := GetArea()
Local nPl     := 0

Local _cAlias := ""
Local _aCabs  := {}
Local _cPlan   := ""
Local _cFiltra := ""
Local _cTitulos:= ""
Local _aCampos := {}
Local _aImpr   := {}
Local _aAlign  := {}
Local _aFormat := {}
Local _aTotal  := {}
Local _cQuebra := ""
Local _lClose  := .F.


Local nPosFont
Local nTitFont
Local nPosCor
Local nLisCor
Local nBordas
Local nFmtNum2
Local nTotFont
Local nApoFont
Local nPosStyle	
Local nLisStyle	
Local nV2Style
Local nD2Style
Local nG2Style 	
Local nT2Style
Local nTitStyle	
Local nTit2Style	
Local nApoStyle	
Local nVApoStyle
Local nDApoStyle
Local nTotStyle	
Local nIDImg

Private xCampo
Private xQuebra


IF lClose == NIL
   lClose := .T.
ENDIF

MakeDir(cDirTmp)

oExcel:new(cFile)

oAlCenter	:= oExcel:Alinhamento("center","center")
oVtCenter	:= oExcel:Alinhamento(,"center")
nPosFont	:= oExcel:AddFont(10,"FFFFFFFF","Calibri","2")
nTitFont	:= oExcel:AddFont(20,"00000000","Calibri","2")
nTit2Font	:= oExcel:AddFont(14,"00000000","Calibri","2")
nPosCor		:= oExcel:CorPreenc("9E0000")	//Cor de Fundo Vermelho alterado
nLisCor		:= oExcel:CorPreenc("D9D9D9")
nBordas 	:= oExcel:Borda("ALL")
nFmtNum2	:= oExcel:AddFmtNum(2/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)

				//nTamanho,cCorRGB,cNome,cfamily,cScheme,lNegrito,lItalico,lSublinhado,lTachado
nTotFont 	:= oExcel:AddFont(11,56,"Calibri","2",,.T.,.F.,.F.,.F.)
nApoFont 	:= oExcel:AddFont(11,"FF0000","Calibri","2",,.T.,.F.,.F.,.F.)

nPosStyle	:= oExcel:AddStyles(/*numFmtId*/,nPosFont/*fontId*/,nPosCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})
nLisStyle	:= oExcel:AddStyles(/*numFmtId*/,/*fontId*/,nLisCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,)

nV2Style	:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nD2Style	:= oExcel:AddStyles(14/*numFmtId*/,/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})
nG2Style 	:= oExcel:AddStyles(/*numFmtId*/,/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nT2Style	:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,nTotFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)

nTitStyle	:= oExcel:AddStyles(/*numFmtId*/,nTitFont/*fontId*/,/*fillId*/,/*borderId*/,/*xfId*/,{oVtCenter})
nTit2Style	:= oExcel:AddStyles(/*numFmtId*/,nTit2Font/*fontId*/,/*fillId*/,/*borderId*/,/*xfId*/,{oVtCenter})
nApoStyle	:= oExcel:AddStyles(/*numFmtId*/,nApoFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nVApoStyle	:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,nApoFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nDApoStyle	:= oExcel:AddStyles(14/*numFmtId*/,nApoFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)

nTotStyle	:= oExcel:AddStyles(/*numFmtId*/,nTotFont/*fontId*/,nLisCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,)

nIDImg		:= oExcel:ADDImg("LGMID"+cEmpAnt+".PNG")	//Imagem no Protheus_data


FOR nPl := 1 TO LEN(_aPlans)

	_cAlias  := _aPlans[nPl,01]
	_cPlan   := _aPlans[nPl,02]
	_cFiltra := _aPlans[nPl,03]
	_cTitulos:= _aPlans[nPl,04] 
	_aCampos := _aPlans[nPl,05]
	_aCabs   := _aPlans[nPl,06]
	_aImpr   := _aPlans[nPl,07]
	_aAlign  := _aPlans[nPl,08]
	_aFormat := _aPlans[nPl,09]
	_aTotal  := _aPlans[nPl,10]
	_cQuebra := _aPlans[nPl,11]
	_lClose  := _aPlans[nPl,12]

	nPosTit  := 0
	nPosTot  := 0 
	nPosCpo  := 0

	nLin     := 1
	nTop     := 1

	oExcel:ADDPlan(_cPlan,"0000FF")		//Adiciona nova planilha

	oExcel:nTamLinha := 34
	oExcel:Img(nIDImg,1,1,40,40,/*"px"*/,)

	// Titulo
	aTitulos := {}
	aAdd(aTitulos,_cTitulos)
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

		oExcel:Cell(nLin,nJ,_aCabs[nJ],,nPosStyle)

	NEXT

	// Tamanho das colunas e colunas de Total
	aTamCol := {}
	aTotal  := {}

	(_cAlias)->(dbgotop())

	For nI :=1 to LEN(_aCampos)

	    IF !EMPTY(_aImpr)  // Coluna a ignorar
			IF !_aImpr[nI]
		    	Loop
		 	ENDIF 
		ENDIF

		xCampo := &(_aCampos[nI])
		cTipo := ValType(xCampo)

		nTamCol := 0
		lTotal  := .F.
		If cTipo == "N"
			nTamCol := 17
			lTotal  := .T.
		ElseIf cTipo == "D"
			nTamCol := 15
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

	(_cAlias)->(dbgotop())
	ProcRegua((_cAlias)->(RecCount())) 
	If !empty(_cFiltra)
		(_cAlias)->(dbsetfilter({|| &_cFiltra} , _cFiltra))
	Endif

	Do While (_cAlias)->(!eof()) 

		IncProc("Gerando planilha "+_cPlan+"...")   

		nLin++

		For nI :=1 to LEN(_aCampos)

			IF !EMPTY(_aImpr)  // Coluna a ignorar
				IF !_aImpr[nI]
					Loop
				ENDIF 
			ENDIF

			xCampo := &(_aCampos[nI])

			If ValType(xCampo) == "N"
				oExcel:Cell(nLin,nI,xCampo,,nV2Style)
			ElseIf ValType(xCampo) == "D"
				oExcel:Cell(nLin,nI,xCampo,,nD2Style)
			Else
				oExcel:Cell(nLin,nI,xCampo,,nG2Style)
			EndIf
		Next

		(_cAlias)->(dbskip())
	EndDo

	oExcel:AutoFilter(nTop-1,1,nLin,Len(_aCabs))	//Auto filtro
	oExcel:AddPane(nTop-1,1)	//Congela paineis

	nLin++
	oExcel:Cell(nLin,1,"Total",,nTotStyle)
	For nI := 1 To Len(aTotal)
		If aTotal[nI]
			oExcel:AddNome("COL"+STRZERO(nI,3)+"P"+STRZERO(nPl,1) ,nTop, nI, nLin-1, nI)
			oExcel:Cell(nLin,nI,0,"SUBTOTAL(9,"+"COL"+STRZERO(nI,3)+"P"+STRZERO(nPl,1)+")",nT2Style)
		EndIf
	Next

	IF _lClose   
	   (_cAlias)->(dbCloseArea())
	ENDIF

Next

cFile := cDirTmp+"\"+cFile+".xlsx"
If File(cFile)
	nRet:= FERASE(cFile)
	If nRet < 0
		MsgStop("Não será possivel gerar a planilha "+cFile+", feche o arquivo",_cProg)
	EndIf
EndIf

oExcel:Gravar(cDirTmp+"\",.T.,.T.)

RestArea(aArea)

Return


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
MsAguarde({|| U_GeraXlsx(aPlansX,_cTitulo,_cAlias,.F.)},"Aguarde","Gerando planilha...",.F.)

Return nil

