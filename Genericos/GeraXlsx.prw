#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"


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

User Function GeraXlsx( _aPlans,_cTitulo,_cProg, lClose, _aParam, _aGraph, lOpen, lJob )
Local cFile := ""

Default lJob := .F.

If !lJob
	MsgRun("Criando Planilha Excel "+_cProg,"Aguarde...",{|| cFile := U_ProcXlsx(_aPlans,_cTitulo,_cProg, lClose, _aParam, _aGraph, lOpen, lJob) })
Else
	cFile := U_ProcXlsx(_aPlans,_cTitulo,_cProg, lClose, _aParam, _aGraph, lOpen, lJob)
EndIf
Return cFile


User Function ProcXlsx(_aPlans,_cTitulo,_cProg, lClose, _aParam, _aGraph, lOpen, lJob)

Local oExcel := YExcel():new()
Local oObjPerg

Local aPergunte
Local aLocPar := {}

Local aTitulos:= {}
Local aTamCol := {}
Local aTotal  := {}
Local nTamCol := 0
Local aStruct := {}
Local aRef    := {}

Local aResumo := {}
Local cMacro  := ""

Local cTipo   := ""
Local lTotal  := .F.
Local lFormula:= .F.
Local nI 	  := 0
Local nJ	  := 0
Local nF	  := 0
Local nLin    := 1
Local nTop    := 1
Local cFile   := _cProg+"-"+DTOS(Date())
Local cFileN  := ""
Local cFileTmp:= ""
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
Local oAlCenter
Local oVtCenter
Local oQtCenter

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
Local lGraf     := .F.
Local cMensGraf := ""

Default _aGraph := {}
Default lOpen   := .T.
Default lJob	:= .F.

Private xCampo,yCampo
Private xQuebra


If lJob
	cDirTmp := "\tmp\"
EndIf


If lClose == NIL
   lClose := .T.
EndIf

MakeDir(cDirTmp)

oExcel:new(cFile)

				//cHorizontal,cVertical,lReduzCaber,lQuebraTexto,ntextRotation
oAlCenter	:= oExcel:Alinhamento("center","center")
oVtCenter	:= oExcel:Alinhamento(,"center")
oQtCenter	:= oExcel:Alinhamento("center","center",.F.,.T.)

				//nTamanho,cCorRGB,cNome,cfamily,cScheme,lNegrito,lItalico,lSublinhado,lTachado
nCabFont	:= oExcel:AddFont(9,"FFFFFFFF","Calibri","2",,.T.)
nLinFont	:= oExcel:AddFont(9,"00000000","Calibri","2")
nTitFont	:= oExcel:AddFont(18,"00000000","Calibri","2",,.T.)
nTit2Font	:= oExcel:AddFont(9,"00000000","Calibri","2")
nTit3Font	:= oExcel:AddFont(11,"00000000","Calibri","2",,.T.)
nSCabFont	:= oExcel:AddFont(9,"00000000","Calibri","2",,.T.)
nTotFont 	:= oExcel:AddFont(9,56,"Calibri","2",,.T.,.F.,.F.,.F.)

nCabCor		:= oExcel:CorPreenc("9E0000")	//Cor de Fundo Vermelho BK
nSCabCor	:= oExcel:CorPreenc("D9D9D9")	//Cor de Fundo de sub cabeçalho

nBordas 	:= oExcel:Borda("ALL")

nFmtNum0	:= oExcel:AddFmtNum(0/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)
nFmtNum2	:= oExcel:AddFmtNum(2/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)
nFmtNum5	:= oExcel:AddFmtNum(5/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)

nFmtPer5	:= oExcel:AddFmtNum(5/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,"%"/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)

nCabStyle	:= oExcel:AddStyles(/*numFmtId*/,nCabFont/*fontId*/,nCabCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oQtCenter})
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

	If Empty(_aFormat)
		_aFormat := Array(Len(_aCabs))
	EndIf

	aRef     := {}
	nCont	 := 0
	nLin     := 1
	nTop     := 1

	oExcel:ADDPlan(_cPlan,"0000FF")		//Adiciona nova planilha
	oExcel:SetDefRow(.T.,{1,Len(_aCabs)})

	oExcel:nTamLinha := 40
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

	nLin := 1
	For nJ := 1 To Len(aTitulos)
		oExcel:mergeCells(nLin,2,nLin,Len(_aCabs))
		If nJ == 1
			oExcel:nTamLinha := 40
			oExcel:Cell(nLin,2,aTitulos[nJ],,nTitStyle)
			oExcel:nTamLinha := NIL
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
				nTamCol := 10
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
				nTamCol := 10
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

		If  nTamCol < 8
			// Não reduzir a coluna do Logo //nI == 1 .AND.
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

	If !empty(_cFiltra)
		(_cAlias)->(dbsetfilter({|| &_cFiltra} , _cFiltra))
	Endif

	Do While (_cAlias)->(!eof()) 

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
			//If cTipo $ "CM"
			//	xCampo := StrTran( xCampo, '&', "E" )
			//EndIf
			//EndIf

			nF		:= 0
			lFormula:= .F.

			If !Empty(_aFormula)
				nF := aScan(_aFormula,{|x| x[1]=nCont .AND. x[2]= _aCampos[nI]})
			EndIf

			If nF > 0
				// Formula ou Conteúdo fixo
				If Len(_aFormula[nf,3]) > 0
					xCampo  := _aFormula[nf,3]
					If "(" $ _aFormula[nf,3]
						lFormula:= .T.
					EndIf
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
			ElseIf cTipo == "S"    // Estilo Subtotal
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


// --> Planilha de Parâmetros
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

nLin := 1
oExcel:ADDPlan("Parâmetros","0000FF")		//Adiciona nova planilha
oExcel:SetDefRow(.T.,{1,4})
oExcel:AddTamCol(1,2,50)

For nJ := 1 To Len(aTitulos)
	oExcel:mergeCells(nLin,1,nLin,2)
	oExcel:Cell(nLin,1,_cProg+" - "+aTitulos[nJ],,nTit3Style)
	nLin++
Next

	//aAdd(aTitulos,_cProg+" - Data base: "+DTOC(dDataBase) +" - Emitido em: "+DTOC(DATE())+"-"+SUBSTR(TIME(),1,5)+" - "+cUserName)

oExcel:Cell(nLin,1,"Emitido por: "+Trim(cUserName)+" em "+DTOC(DATE())+"-"+SUBSTR(TIME(),1,5)+" - "+ComputerName(),,nTit3Style)
nLin++
oExcel:Cell(nLin,1,"Data Base: "+DTOC(dDataBase),,nTit3Style)
nLin++
oExcel:Cell(nLin,1,"Empresa "+cEmpAnt+": "+ALLTRIM(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_NOME"} )[1,2]),,nTit3Style)
nLin++
oExcel:Cell(nLin,1,"Filial "+cFilAnt+": "+ALLTRIM(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_FILIAL"} )[1,2]),,nTit3Style)
nLin++

If Len(aLocPar) > 0
	oExcel:Cell(nLin,1,"Parâmetros - "+_cProg,,nSCabStyle)
	oExcel:Cell(nLin,2,"Conteúdo",,nSCabStyle)

	For nI := 1 TO LEN(aLocPar)
		nLin++
		oExcel:Cell(nLin,1,aLocPar[nI,1],,nG2Style)
		oExcel:Cell(nLin,2,aLocPar[nI,2],,nG2Style)
	Next
EndIf
// <-- Parâmetros

If Len(_aGraph) > 0 .AND. !lJob
	oExcel:ADDPlan("Resumo","0000FF")		//Adiciona nova planilha

	nLin  := 2
	oExcel:Cell(nLin,1,_aGraph[2],,nTit3Style)
	oExcel:AddNome("titGrafico",nLin, 1, nLin, 1)

	aResumo := _aGraph[3]
	nLin  := 3
	For nI := 1 To Len(aResumo)
		For nJ := 1 To Len(aResumo[nI])
			oExcel:Cell(nLin,nJ,aResumo[nI,nJ],,IiF(nI==1,nCabStyle,nG2Style))
		Next
		nLin++
	Next
	oExcel:AddNome("dadosGrafico",3, 1, nLin-1, Len(aResumo[1]))
	oExcel:AddNome("posGrafico",3, Len(aResumo[1])+2, 3, Len(aResumo[1])+2)

	cMensGraf := "Incluir Gráfico na planilha ?"+CRLF+CRLF
	cMensGraf := "Obs: As macros devem estar habilitadas no Excel (2013 em diante):"+CRLF+CRLF
	cMensGraf += "1-Clique no botão do Microsoft Office e em Opções do Excel;"+CRLF
	cMensGraf += "2-Clique em Central de Confiabilidade, em Configurações da Central de Confiabilidade e em Configurações de Macro;"+CRLF
	cMensGraf += "3-Clique em Habilitar todas as macros."+CRLF
	If MsgYesNo(cMensGraf,_cProg)
		lGraf := .T.
		lOpen := .F.
	EndIf
EndIf


// Grava a Planilha
cFileN := cFile
cFile  := cDirTmp+"\"+cFile+".xlsx"
If File(cFile)
	nRet:= FERASE(cFile)
	If nRet < 0
		MsgAlert("Não será possivel gerar a planilha "+cFile+", feche o arquivo",_cProg)
	EndIf
EndIf

oExcel:Gravar(cDirTmp+"\",lOpen,.T.)

If lGraf .AND. !lJob

	cMacro := _aGraph[1]
	cFileTmp := cDirTmp+"\"+cMacro+".xlsm"
	nRet:= FERASE(cFileTmp)
	If File(cFileTmp)
		MsgAlert("Não foi possível excluir o arquivo "+cFileTmp+", feche o arquivo",_cProg)
	EndIf
	CpyS2T( "\macros\"+cMacro+".xlsm",cDirTmp)

	cFileTmp := cDirTmp+"\"+cFileN+".xlsm
	nRet:= FERASE(cFileTmp)
	If File(cFileTmp)
		MsgAlert("Não foi possível excluir o arquivo "+cFileTmp+", feche o arquivo",_cProg)
	EndIf

	fRename(cDirTmp+"\"+cMacro+".xlsm",cDirTmp+"\"+cFileN+".xlsm")
	ShellExecute("open",cDirTmp+"\"+cFileN+".xlsm","",cDirTmp+"\", 1 )
EndIf

RestArea(aArea)

Return cFile



/* macrograf.xlsm

Private Sub Workbook_Open()
Call Macro1
End Sub

Sub Macro1()
Dim sFileName As String
Dim wkb As Workbook
Dim wst As Worksheet
Dim rng As Range
Dim cht As ChartObject

 sFileName = Application.ThisWorkbook.Name

 sFileName = "c:\tmp\" + Replace(sFileName, "xlsm", "xlsx")
 
 MsgBox "Criando o gráfico! " + sFileName
 
 
 Set wkb = Workbooks.Open(sFileName)
 
 Set wst = wkb.Worksheets("Resumo")
 
 wst.Select
  
 Set rng = wst.Range("dadosGrafico")
 
 wst.Range("posGrafico").Select
 
 Set cht = wst.ChartObjects.Add( _
    Left:=ActiveCell.Left, _
    Width:=450, _
    Top:=ActiveCell.Top, _
    Height:=250)
 
 cht.Chart.SetSourceData Source:=rng

 cht.Chart.ChartType = xlBarStacked
 
 cht.Chart.HasTitle = True

 cht.Chart.ChartTitle.Text = "My Graph"
 
 ActiveWorkbook.Close SaveChanges:=True
 
 Set wkb = Workbooks.Open(sFileName)
 
End Sub

*/



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
Local cArqXls  := ""

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
cArqXls := U_GeraXlsx(aPlansX,_cTitulo,_cAlias,.F.)

Return cArqXls

// Marcos - v04/04/20
// Exemplo:

//  ... aAdd(aCabec,"Total")
//	... aAdd(aItens,ZZ7->ZZ7_DTASSC)
//	... Aadd(aDados, aItens )

//	AADD(aPlans,{aDados,cPerg,cTitExcel,aCabec,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */ })   
//	MsAguarde({|| U_ArrToXml(aPlans,cTitExcel,cPerg,.T.)},"Aguarde","Gerando planilha...",.F.)


User Function ArrToXlsx( _aPlans,_cTitulo,_cProg, _aParam, lJob )
Default lJob := .F.

If !lJob
	MsgRun("Criando Planilha Excel "+_cProg,"Aguarde...",{|| U_PrcArrXlsx(_aPlans,_cTitulo,_cProg, _aParam, lJob) })
Else
	U_PrcArrXlsx(_aPlans,_cTitulo,_cProg, _aParam, lJob)
EndIf

Return Nil

User Function PrcArrXlsx( _aPlans,_cTitulo,_cProg, _aParam, lJob )

Local oExcel := YExcel():new()
Local oObjPerg

Local aPergunte
Local aLocPar := {}

Local aTitulos:= {}
Local aTamCol := {}
Local aTotal  := {}
Local nTamCol := 0
//Local aStruct := {}
Local aRef    := {}

Local cTipo   := ""
Local lTotal  := .F.
//Local lFormula:= .F.
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

// -->Dif GeraXlsx
Local _aDados  := {}
Local _cPlan   := ""
Local _xTitulos:= ""
Local _aCabs   := {}
Local _aImpr   := {}
Local _aFormula:= {}
Local _aFormat := {}
Local _aTotal  := {}
// <-- Dif GeraXlsx

Local oAlCenter
Local oVtCenter
Local oQtCenter

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

//Local nStyle
Default lJob	:= .F.
Private xCampo,yCampo
Private xQuebra

If lJob
	cDirTmp := "\tmp\"
EndIf

//If lClose == NIL
//   lClose := .T.
//EndIf

MakeDir(cDirTmp)

oExcel:new(cFile)

				//cHorizontal,cVertical,lReduzCaber,lQuebraTexto,ntextRotation
oAlCenter	:= oExcel:Alinhamento("center","center")
oVtCenter	:= oExcel:Alinhamento(,"center")
oQtCenter	:= oExcel:Alinhamento("center","center",.F.,.T.)

				//nTamanho,cCorRGB,cNome,cfamily,cScheme,lNegrito,lItalico,lSublinhado,lTachado
nCabFont	:= oExcel:AddFont(9,"FFFFFFFF","Calibri","2",,.T.)
nLinFont	:= oExcel:AddFont(9,"00000000","Calibri","2")
nTitFont	:= oExcel:AddFont(18,"00000000","Calibri","2",,.T.)
nTit2Font	:= oExcel:AddFont(9,"00000000","Calibri","2")
nTit3Font	:= oExcel:AddFont(11,"00000000","Calibri","2",,.T.)
nSCabFont	:= oExcel:AddFont(9,"00000000","Calibri","2",,.T.)
nTotFont 	:= oExcel:AddFont(9,56,"Calibri","2",,.T.,.F.,.F.,.F.)

nCabCor		:= oExcel:CorPreenc("9E0000")	//Cor de Fundo Vermelho BK
nSCabCor	:= oExcel:CorPreenc("D9D9D9")	//Cor de Fundo de sub cabeçalho

nBordas 	:= oExcel:Borda("ALL")

nFmtNum0	:= oExcel:AddFmtNum(0/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)
nFmtNum2	:= oExcel:AddFmtNum(2/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)
nFmtNum5	:= oExcel:AddFmtNum(5/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)

nFmtPer5	:= oExcel:AddFmtNum(5/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,"%"/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)

nCabStyle	:= oExcel:AddStyles(/*numFmtId*/,nCabFont/*fontId*/,nCabCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oQtCenter})
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

// --> Dif GeraXlsx

FOR nPl := 1 TO LEN(_aPlans)

	_aDados  := _aPlans[nPl,01]
	_cPlan   := _aPlans[nPl,02]
	_xTitulos:= _aPlans[nPl,03] 
	_aCabs   := _aPlans[nPl,04]
	_aImpr   := _aPlans[nPl,05]
	_aFormula:= _aPlans[nPl,06]
	_aFormat := _aPlans[nPl,07]
	_aTotal  := _aPlans[nPl,08]

	If Empty(_aFormat)
		_aFormat := Array(Len(_aCabs))
	EndIf

	aRef     := {}
	nCont	 := 0
	nLin     := 1
	nTop     := 1

	oExcel:ADDPlan(_cPlan,"0000FF")		//Adiciona nova planilha

	oExcel:nTamLinha := 40
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
			oExcel:nTamLinha := 40
			oExcel:Cell(nLin,2,aTitulos[nJ],,nTitStyle)
			oExcel:nTamLinha := NIL
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
			nTamCol := 10
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

		If  nTamCol < 8
			// Não reduzir a coluna do Logo //nI == 1 .AND.
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

	For nRow := 1 To Len(_aDados)

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
	oExcel:Cell(nLin,1,"Emitido por: "+Trim(cUserName)+" em "+DTOC(DATE())+"-"+SUBSTR(TIME(),1,5)+" - "+ComputerName(),,nTit3Style)
	nLin++
	oExcel:Cell(nLin,1,"Data Base: "+DTOC(dDataBase),,nTit3Style)
	nLin++
	oExcel:Cell(nLin,1,"Empresa "+cEmpAnt+": "+ALLTRIM(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_NOME"} )[1,2]),,nTit3Style)
	nLin++
	oExcel:Cell(nLin,1,"Filial "+cFilAnt+": "+ALLTRIM(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_FILIAL"} )[1,2]),,nTit3Style)
	nLin++

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
		MsgAlert("Não será possivel gerar a planilha, feche o arquivo "+cFile,_cProg)
	EndIf
EndIf

oExcel:Gravar(cDirTmp+"\",.T.,.T.)

RestArea(aArea)

Return cFile

