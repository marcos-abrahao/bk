#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

Static oCellHorAlign := FwXlsxCellAlignment():Horizontal()
Static oCellVertAlign := FwXlsxCellAlignment():Vertical()

/*/{Protheus.doc} BKXlsx
Generico - Gera planilha excel 
@Return
@author Marcos Bispo Abrahão
@since 26/06/2021
@version P12-30/12/2021
/*/


// Exemplo
//	    AADD(aCabsX,Capital(cNomeC))
//	    AADD(aCamposX,_cAlias+"->"+FIELDNAME(nI))
//	    AADD(aImpr,.T.)
//	    AADD(aFormula,NIL)
//	    AADD(aFormat,NIL)
//	    AADD(aTotal,NIL)
//		AADD(aResumo,{nColUnq1,nColVal1,{}})  // Coluna com chaves a unificar, coluna de valores, array com chaves e valores iniciais

//AADD(aPlansX,{_cAlias,_cPlan,"",_cTitulo,aCamposX,aCabsX,aImpr,aFormula,aFormat,aTotal,aResumo,_lClose})
//U_BKXlsx(aPlansX,_cTitulo,_cAlias,.F.) 

User Function PlanXlsx( _aPlans,_cTitulo,_cProg, lClose, _aParam, _aGraph, lOpen, lJob )
Local cFile := ""
Default lJob := IsBlind()

u_WaitLog(_cProg,{|oSay| cFile := u_PlXlsx(_aPlans,_cTitulo,TRIM(_cProg), lClose, _aParam, _aGraph, lOpen, lJob) }, "Gerando Planilha Excel: "+_cProg+"...")

Return cFile


User Function PlXlsx(_aPlans,_cTitulo,_cProg, lClose, _aParam, _aGraph, lOpen, lJob)

Local oFileW    As Object
Local oPrtXlsx  As Object

Local oObjPerg  As Object

Local aPergunte
Local aLocPar 		:= {}

Local aTitulos		:= {}
Local aTamCol 		:= {}
Local aTotal  		:= {}
Local nTamCol 		:= 0
Local aStruct 		:= {}
Local aRef    		:= {}
Local lFirst  		:= .T.

Local cTipo   		:= ""
Local cFormat 		:= ""
Local cEstilo		:= ""
Local cCorFonte		:= ""
Local cCorFundo		:= ""

Local cCorN			:= "000000" // Cor Preta
Local cFundoN		:= "FFFFFF" // Fundo Branco

Local cCorS			:= "FFFFFF" // Cor Branca
Local cFundoS		:= "9E0000" // Fundo Vermelho BK

Local cCorS1		:= "000000" // Cor Preta
Local cFundoS1		:= "E9967A" // Fundo DarkSalmon

Local cCorS2		:= "000000" // Cor Preta
Local cFundoS2		:= "9ACD32" // Fundo YellowGreen

Local cCorAntes		:= ""
Local cCustomAnt	:= ""
Local nDecimal		:= 0
Local lTotal  		:= .F.
Local lFormula		:= .F.
Local nI 	  		:= 0
Local nJ	  		:= 0
Local nF	  		:= 0

Local nR	  		:= 0
Local nS 			:= 0
Local aLinha		:= {}

Local nLin    		:= 1
Local nTop    		:= 1
Local nLast 		:= 0
Local cColExcel 	:= ""
Local cLinTop   	:= ""
Local cLinExcel 	:= ""
Local cFile   		:= TRIM(_cProg)+"-"+cEmpAnt+"-"+DTOS(Date())
Local cFileL  		:= ""
Local cFileR  		:= ""
Local cFileX  		:= ""
Local cDirDest		:= "C:\TMP\"
Local cDirTmp 		:= "\tmp\"
Local nCont	  		:= 0
Local nRet    		:= 0

Local aArea   		:= GetArea()
Local nPl     		:= 0

Local _cAlias  		:= ""
Local _aCabs   		:= {}
Local _cPlan   		:= ""
Local _cFiltra 		:= ""
Local _xTitulos		:= ""
Local _aCampos 		:= {}
Local _aImpr   		:= {}
Local _aFormula		:= {}
Local _aFormat 		:= {}
Local _aTotal  		:= {}
Local _aResumo 		:= {}
//Local _aTResumo		:= {}
Local _lClose  		:= .F.

Local cFont 		:= ""

Local nLSize 		:= 9
Local lLItalic 		:= .F.
Local lLBold 		:= .F.
Local lLUnderl		:= .F.
Local cLHorAlig		:= oCellHorAlign:Default()
Local cLVertAlig	:= oCellVertAlign:Center()
Local lLWrapText	:= .F.
Local nLRotation	:= 0

Local nHSize 		:= 9
Local lHItalic 		:= .F.
Local lHBold 		:= .T.
Local lHUnderl		:= .F.
Local cHHorAlig		:= oCellHorAlign:Center()
Local cHVertAlig	:= oCellVertAlign:Center()
Local lHWrapText	:= .T.
Local nHRotation	:= 0

Local nTSize1 		:= 18
Local nTSize2 		:= 9
Local lTItalic 		:= .F.
Local lTBold 		:= .T.
Local lTUnderl		:= .F.
Local cTHorAlig		:= oCellHorAlign:Default()
Local cTVertAlig	:= oCellVertAlign:Center()
Local lTWrapText 	:= .F.
Local nTRotation 	:= 0

Local cStartPath 	:= GetSrvProfString( "StartPath", "" ) 
Local cImgRel 		:= 'logo'
Local cImgDir 		:= cStartPath + "lgmid"+cEmpAnt+".png"
Local nHndImagem 	:= 0
Local nLenImagem 	:= 0
Local cBuffer		:= ""

Default _aGraph 	:= {}
Default lOpen   	:= .T.
Default lJob		:= IsBlind()

Private xCampo
Private yCampo

If lJob
	cDirDest := cDirTmp
	lOpen	 := .F.
EndIf


If lClose == NIL
   lClose := .T.
EndIf

MakeDir(cDirTmp)
MakeDir(cDirDest)

cFileR 		:= cDirTmp+cFile+".rel"
cFileX 		:= cDirTmp+cFile+".xlsx"
oFileW      := FwFileWriter():New(cFileR)
oPrtXlsx    := FwPrinterXlsx():New()

oPrtXlsx:Activate(cFileR, oFileW)

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
	_aResumo := aClone(_aPlans[nPl,11])
	_lClose  := _aPlans[nPl,12]

	If Empty(_aFormat)
		_aFormat := Array(Len(_aCabs))
	EndIf

	aRef    := {}
	nCont	:= 0
	nLin    := 1
	nTop    := 1

	oPrtXlsx:AddSheet(_cPlan)    //Adiciona nova planilha
    cFont   := FwPrinterFont():Calibri()


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

	// Formatação do cabeçalho
    oPrtXlsx:SetFont(cFont, nTSize1, lTItalic, lTBold, lTUnderl)
    oPrtXlsx:SetCellsFormat(cTHorAlig, cTVertAlig, lTWrapText, nTRotation,cCorN, cFundoN, "" )

	nLin := 1
	For nJ := 1 To Len(aTitulos)
		If nJ == 1
		    oPrtXlsx:SetFont(cFont, nTSize1, lTItalic, lTBold, lTUnderl)
		Else
    		oPrtXlsx:SetFont(cFont, nTSize2, lTItalic, lTBold, lTUnderl)
		EndIf
        oPrtXlsx:SetValue(nLin,2,aTitulos[nJ])

		nLin++
	Next

	// Logo
    nHndImagem := fOpen(cImgDir, FO_READ)
    if nHndImagem < 0
        //MsgStop("Não foi possível abrir " + cImgDir)
    Else
		nLenImagem := fSeek( nHndImagem, 0, FS_END)
		fSeek( nHndImagem, 0, FS_SET)
		fRead( nHndImagem, @cBuffer, nLenImagem)
	
		oPrtXlsx:AddImageFromBuffer(1, 1, cImgRel, cBuffer, 42, 40)
	EndIf

	nTop := nLin + 1

    cFont 		:= FwPrinterFont():Calibri()

	// Formatação do cabeçalho
    oPrtXlsx:SetFont(cFont, nHSize, lHItalic, lHBold, lHUnderl)
    oPrtXlsx:SetCellsFormat(cHHorAlig, cHVertAlig, lHWrapText, nHRotation, cCorS, cFundoS, "" )

	OPrtXlsx:SetBorder(.T.,.T.,.T.,.T.,FwXlsxBorderStyle():Thin(),"000000")

	// Cabeçalho
	For nJ := 1 To Len(_aCabs)

	    If !EMPTY(_aImpr)  // Coluna a ignorar
			If !_aImpr[nJ]
		    	Loop
		 	EndIf 
		EndIf

        oPrtXlsx:SetValue(nLin,nJ,_aCabs[nJ])

	Next

	oPrtXlsx:ResetCellsFormat()

	// Formatação das linhas normais
    oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
    oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )


	// Tamanho das colunas e colunas de Total
	aTamCol := {}
	aTotal  := {}

	aStruct := (_cAlias)->(dbStruct())

	If !Empty(_cFiltra)
		(_cAlias)->(dbSetFilter({|| &_cFiltra} , _cFiltra))
	Else
		(_cAlias)->(dbClearFilter())
	Endif
	(_cAlias)->(dbGoTop())

	lFirst := .T.
	cCustomAnt := ""
	
	cCorFonte := cCorN
	cCorFundo := cFundoN
	cCorAntes := ""

	Do While (_cAlias)->(!Eof()) 

		nLin++
		nCont++
		aLinha := {}

		For nI := 1 to LEN(_aCampos)

			IF !EMPTY(_aImpr)  // Coluna a ignorar
				IF !_aImpr[nI]
					Loop
				ENDIF 
			ENDIF

			xCampo := &(_aCampos[nI])
			// Obs: esta macro não pode ser executada mais de uma vez

			If lFirst
				// Calcular o tamanho das colunas
				nTamCol := 0
				lTotal  := .F.
				cTipo   := ""
				nDecimal:= 2
				cFormat := ""

				nF := aScan(aStruct,{|x| x[1] = SUBSTR(_aCampos[nI],aT(">",_aCampos[nI])+1) })
				If nF > 0
					cTipo    := aStruct[nF,2]
					//nTamCol := aStruct[nF,3]+aStruct[nF,4]+1
					nTamCol := aStruct[nF,3]+1
					If cTipo == "N"
						lTotal := .T.
						nDecimal := aStruct[nF,4]
						If nDecimal == 8
							nDecimal := 2
						EndIf
						cTipo:="N"+ALLTRIM(STR(nDecimal))
						//If aStruct[nF,4] == 0
						//	cTipo := "N0"
						//ElseIf aStruct[nF,4] > 2 .AND. aStruct[nF,4] < 6
						//	cTipo := "N5"
						//	nTamCol += 5
						//Else
						//	nTamCol := 15
						//EndIf
						nTamCol += nDecimal
					Elseif cTipo == "D"
						nTamCol := 10
					ElseiF nTamCol > 150
						nTamCol := 150
					EndIf
				EndIf

				If Empty(cTipo)

					cTipo  := ValType(xCampo)

					If cTipo == "N"
						nTamCol := 15
						lTotal  := .T.
						cTipo   := "N2"
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

				For nJ := 1 To Len(aTamCol)
					If aTamCol[nJ] > 0
                        oPrtXlsx:SetColumnsWidth(nJ,nJ,aTamCol[nJ])
					EndIf
				Next

			EndIf

			cTipo	:= _aFormat[nI]
			cEstilo := ""
			nF		:= 0
			lFormula:= .F.

			If !Empty(_aFormula)
				nF := aScan(_aFormula,{|x| x[1]=(_cAlias)->(RECNO()) .AND. x[2]= _aCampos[nI]})

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
						If SUBSTR(_aFormula[nf,4],1,1) == "S"
							cEstilo := _aFormula[nf,4]
						Else
							cTipo   := _aFormula[nf,4]
						EndIf
					EndIf

					// NOME
					If !Empty(_aFormula[nf,5])
						///// oExcel:AddNome(_aFormula[nf,5],nLin, nI, nLin, nI)
					EndIf

					// REFERENCIA
					If !Empty(_aFormula[nf,6])
						///// aAdd(aRef,{_aFormula[nf,6],oExcel:Ref(nLin, nI)})
						// Criar Array para Guardar a referencia concatenada
						//oExcel:AddNome(_aFormula[nf,5],nLin, nI, nLin, nI)
					EndIf

				EndIf
			EndIf
 
			If !Empty(xCampo) .AND. Substr(cTipo,1,1) $ "NP" .AND. ValType(xCampo) == "C" .AND. !IsAlpha(xCampo)
				yCampo := ALLTRIM(xCampo)

				If "," $ xCampo
					If cTipo == "N"
						nDecimal := Len(ycampo) - at(",",ycampo)
						If nDecimal > 0
							cTipo := "N"+ALLTRIM(STR(nDecimal))
						EndIf
					EndIf
					yCampo := STRTRAN(yCampo,".","")
					yCampo := STRTRAN(yCampo,",",".")
				EndIf
				
				If "%" $ xCampo
					cTipo  := "P"
					nDecimal := Len(ycampo) - at(".",ycampo)
					If nDecimal > 0
						cTipo := "P"+ALLTRIM(STR(nDecimal))
					EndIf
					xCampo := VAL(yCampo) / 100
				Else
					xCampo := VAL(yCampo)
				EndIf
			
			EndIf


			cFormat := ""

			If SUBSTR(cTipo,1,1) == "N"
			    cFormat := "#,##0"
				nDecimal := VAL(SUBSTR(cTipo,2))
				If nDecimal > 0
					cFormat += "."+REPLICATE("0",nDecimal)
				EndIf
			    cFormat := cFormat+";[Red]-"+cFormat

			ElseIf SUBSTR(cTipo,1,1) == "P"
				cFormat  := "0"
				nDecimal := VAL(SUBSTR(cTipo,2))
				If nDecimal > 0
					cFormat += "."+REPLICATE("0",nDecimal)+"%"
				Else
					cFormat := "0.00%"
				EndIf
				cFormat := cFormat+";[Red]-"+cFormat
			ElseIf cTipo == "D"
				If !Empty(xCampo)
			    	cFormat := "dd/mm/yyyy"
				Else
					xCampo  := ""
				EndIf
			ElseIf cTipo == "U"
				xCampo  := ""
			ElseIf cTipo == "C"
				xCampo  := TRIM(xCampo)
				If SUBSTR(xCampo,1,1) == "="
					If "(" $ xCampo
						cTipo := "F"  // Formula
					EndIf
				EndIf
			EndIf
            
			If cEstilo == "S"   // Estilo Cab
				cCorFonte := cCorS
				cCorFundo := cFundoS
			ElseIf cEstilo == "S1"  // Estilo Subtotal 1
				cCorFonte := cCorS1
				cCorFundo := cFundoS1
			ElseIf cEstilo == "S2"  // Estilo Subtotal 2
				cCorFonte := cCorS2
				cCorFundo := cFundoS2
			Else
				cCorFonte := cCorN
				cCorFundo := cFundoN
			EndIf

			//If lFormula
			//	oExcel:Cell(nLin,nI,0,xCampo,nStyle)
			//Else
			//	oExcel:Cell(nLin,nI,xCampo,,nStyle)
			//EndIf
			If cCustomAnt <> cFormat .OR. cCorAntes <> (cCorFonte+cCorFundo)
		    	oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorFonte, cCorFundo, cFormat )
				cCustomAnt := cFormat
				cCorAntes  := (cCorFonte+cCorFundo)
			EndIf
			If cTipo == "F"
				/*
				If "HYPERLINK" $ UPPER(xCampo)
					xCampo := STRTRAN(xCampo,'=HYPERLINK("','')
					xCampo := STRTRAN(xCampo,'")','')

					oPrtXlsx:SetHyperlink(nLin,nI,xCampo)
				Else
					oPrtXlsx:SetFormula(nLin,nI,xCampo)
				EndIf
				*/
				If "HYPERLINK" $ UPPER(xCampo)
				    oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, .T.)
			    	oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, "0000FF", cCorFundo, cFormat )
				EndIf

				oPrtXlsx:SetFormula(nLin,nI,xCampo)

				If "HYPERLINK" $ UPPER(xCampo)
				    oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
			    	oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorFonte, cCorFundo, cFormat )
				EndIf

			Else
            	oPrtXlsx:SetValue(nLin,nI,xCampo)
			EndIf
			aAdd(aLinha,xCampo)

		Next

		// Monta os resumos
		If !Empty(_aResumo)
			For nR := 1 To Len(_aResumo)
				If Len(_aResumo[nR,3]) > 0
					nS := Ascan(_aResumo[nR,3],{|x| x[1] == aLinha[_aResumo[nR,1]]})
					If nS == 0
						aAdd(_aResumo[nR,3],{aLinha[_aResumo[nR,1]],aLinha[_aResumo[nR,2]]})
					Else
						_aResumo[nR,3,nS,2] += aLinha[_aResumo[nR,2]]
					EndIf
				Else
					aAdd(_aResumo[nR,3],{aLinha[_aResumo[nR,1]],aLinha[_aResumo[nR,2]]})
				EndIf
			Next
		EndIf


		(_cAlias)->(dbskip())

		lFirst := .F.
	EndDo
	nLast := nLin

	If !lFirst

        oPrtXlsx:ApplyAutoFilter(nTop-1,1,nLin,Len(_aCabs))

		//oExcel:AddPane(nTop-1,1)	//Congela paineis

		nLin++
		// Linha de Total
	    oPrtXlsx:SetFont(cFont, nTSize2, lTItalic, lTBold, lTUnderl)
        oPrtXlsx:SetValue(nLin,1,"Total ("+ALLTRIM(STR(nCont))+")")
        
		If nCont > 0
			// Formatação dos totais		
			cFormat := "#,##0.00;[Red]-#,##0.00"
			oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, cFormat )
			For nI := 2 To Len(aTotal)
				If aTotal[nI]
					cColExcel := NumToString(nI)
					cLinTop   := ALLTRIM(STR(nTop))
					cLinExcel := ALLTRIM(STR(nLast))
					oPrtXlsx:SetFormula(nLin,nI, "=SUBTOTAL(9,"+cColExcel+cLinTop+":"+cColExcel+cLinExcel+")")

				EndIf
			Next
		EndIf
		oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)


		// Mostrar o Resumo
		If !Empty(_aResumo)

			For nI := 1 To Len(_aResumo)
				nLin+=3
				// Formatação do cabeçalho
				oPrtXlsx:SetFont(cFont, nHSize, lHItalic, lHBold, lHUnderl)
				oPrtXlsx:SetCellsFormat(cHHorAlig, cHVertAlig, lHWrapText, nHRotation, cCorS, cFundoS, "" )

				OPrtXlsx:SetBorder(.T.,.T.,.T.,.T.,FwXlsxBorderStyle():Thin(),"000000")

				// Cabeçalho do resumo

				oPrtXlsx:SetValue(nLin,2,_aCabs[_aResumo[nI,1]])
				oPrtXlsx:SetValue(nLin,3,_aCabs[_aResumo[nI,2]])

				oPrtXlsx:ResetCellsFormat()
				// Formatação das linhas normais
				oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
				oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )

				// Resumo
				nLin++

				// Via formula, não funcionou no excel 365
				//cColExcel := NumToString(_aResumo[nI,1])
				//cLinTop   := ALLTRIM(STR(nTop))
				//cLinExcel := ALLTRIM(STR(nLast))
				//oPrtXlsx:SetFormula(nLin,2, "ÚNICO("+cColExcel+cLinTop+":"+cColExcel+cLinExcel+")")
				//oPrtXlsx:SetFormula(nLin,2, "SOMASES( .... "+cColExcel+cLinTop+":"+cColExcel+cLinExcel+")")

				nLinR := nLin
				cFormat := "#,##0.00;[Red]-#,##0.00"
				For nR := 1 To Len(_aResumo[nI,3])

					oPrtXlsx:ResetCellsFormat()

					// Formatação das linhas normais
					oPrtXlsx:SetFont(cFont, nLSize, lLItalic, .T., lLUnderl)
					oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )

					oPrtXlsx:SetValue(nLin,2,_aResumo[nI,3,nR,1])

					// Formatação de totais
					oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, cFormat )
					oPrtXlsx:SetValue(nLin,3,_aResumo[nI,3,nR,2])

					// Total do Resumo
					/*
					nS := Ascan(_aTResumo,{ |x| x[1] == _aResumo[nI,1] .AND. x[2] == _aResumo[nI,2] })

					If nS == 0
						aAdd(_aTResumo,{_aResumo[nI,1],_aResumo[nI,2],{{_aResumo[nI,3,nR,1],_aResumo[nI,3,nR,2]}}})
					Else
						aAdd(_aTResumo[nS,3],{_aResumo[nI,3,nR,1],_aResumo[nI,3,nR,2]})
					EndIf
					*/
					nLin++
				Next


				cColExcel := NumToString(3)
				cLinTop   := ALLTRIM(STR(nLinR))
				cLinExcel := ALLTRIM(STR(nLin-1))
				oPrtXlsx:SetFormula(nLin,3, "=SUBTOTAL(9,"+cColExcel+cLinTop+":"+cColExcel+cLinExcel+")")
				
				// Total do Resumo
				//aAdd(_aTResumo,_aResumo[nI])
			Next

		EndIf

	EndIf

	If _lClose   
	   (_cAlias)->(dbCloseArea())
	EndIf

Next
/*
// Mostrar o Resumo
If Len(_aTResumo) > 0 .AND. Len(_aPlans) > 1
	nLin := 1
	oPrtXlsx:AddSheet("Resumo")    //Adiciona a planilha de Resumo
	For nI := 1 To Len(_aTResumo)
		nLin+=3
		// Formatação do cabeçalho
		oPrtXlsx:SetFont(cFont, nHSize, lHItalic, lHBold, lHUnderl)
		oPrtXlsx:SetCellsFormat(cHHorAlig, cHVertAlig, lHWrapText, nHRotation, cCorS, cFundoS, "" )
		OPrtXlsx:SetBorder(.T.,.T.,.T.,.T.,FwXlsxBorderStyle():Thin(),"000000")
		// Cabeçalho do resumo
		oPrtXlsx:SetValue(nLin,2,_aCabs[_aTResumo[nI,1]])
		oPrtXlsx:SetValue(nLin,3,_aCabs[_aTResumo[nI,2]])
		oPrtXlsx:ResetCellsFormat()
		// Formatação das linhas normais
		oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
		oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )
		// Resumo
		nLin++
		// Via formula, não funcionou no excel 365
		//cColExcel := NumToString(_aTResumo[nI,1])
		//cLinTop   := ALLTRIM(STR(nTop))
		//cLinExcel := ALLTRIM(STR(nLast))
		//oPrtXlsx:SetFormula(nLin,2, "ÚNICO("+cColExcel+cLinTop+":"+cColExcel+cLinExcel+")")
		//oPrtXlsx:SetFormula(nLin,2, "SOMASES( .... "+cColExcel+cLinTop+":"+cColExcel+cLinExcel+")")
		nLinR := nLin
		cFormat := "#,##0.00;[Red]-#,##0.00"
		For nR := 1 To Len(_aTResumo[nI,3])
			oPrtXlsx:ResetCellsFormat()
			// Formatação das linhas normais
			oPrtXlsx:SetFont(cFont, nLSize, lLItalic, .T., lLUnderl)
			oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )
			oPrtXlsx:SetValue(nLin,2,_aTResumo[nI,3,nR,1])
			// Formatação de totais
			oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, cFormat )
			oPrtXlsx:SetValue(nLin,3,_aTResumo[nI,3,nR,2])
			nLin++
		Next
		// Total do Resumo
		cColExcel := NumToString(3)
		cLinTop   := ALLTRIM(STR(nLinR))
		cLinExcel := ALLTRIM(STR(nLin-1))
		oPrtXlsx:SetFormula(nLin,3, "=SUBTOTAL(9,"+cColExcel+cLinTop+":"+cColExcel+cLinExcel+")")
	Next
EndIf
*/

// --> Planilha de Parâmetros
If ValType(_aParam) == "A"
	For nI := 1 TO LEN(_aParam)
		//xCampo := "MV_PAR"+STRZERO(nI,2)
		//aAdd(aLocPar,{_aParam[nI,2],cValToChar(&xCampo)})

		xCampo := &("MV_PAR"+STRZERO(nI,2))
		yCampo := cValToChar(xCampo)
		// Se for combo ou radio, pega a posição do array
		If _aParam[nI,1] == 2 .OR. _aParam[nI,1] == 3
			If ValType(xCampo) == "N"
				If  xCampo > 0 .AND. xCampo <= Len(_aParam[nI,4])
					yCampo := _aParam[nI,4,xCampo]
				EndIf
			EndIf
		EndIf
		aAdd(aLocPar,{_aParam[nI,2],yCampo})

	Next

Else
	oObjPerg := FWSX1Util():New()
	oObjPerg:AddGroup(_cProg)
	oObjPerg:SearchGroup()
	aPergunte := oObjPerg:GetGroup(_cProg)
	If !Empty(aPergunte[2])
		For nI := 1 TO Len(aPergunte[2])
			xCampo := "MV_PAR"+STRZERO(nI,2)
			If aPergunte[2,nI,"CX1_GSC"] == "C"
				cVarDef := SUBSTR(cValToChar(&xCampo),1,1)
				If cVarDef $ "12345"
					yCampo := "CX1_DEF0"+cVarDef
					aAdd(aLocPar,{aPergunte[2,nI,"CX1_PERGUNT"],aPergunte[2,nI,yCampo]})
				EndIf
			Else
				aAdd(aLocPar,{aPergunte[2,nI,"CX1_PERGUNT"],cValToChar(&xCampo)})
			EndIf
		Next
	EndIf

EndIf

nLin := 1
oPrtXlsx:AddSheet("Parâmetros")    //Adiciona a planilha de Parâmetros
oPrtXlsx:SetColumnsWidth(1,2,50)

// Formatação de cabeçalho
oPrtXlsx:SetFont(cFont, nHSize, lHItalic, lHBold, lHUnderl)
oPrtXlsx:SetCellsFormat(cHHorAlig, cHVertAlig, lHWrapText, nHRotation, cCorS, cFundoS, "" )
oPrtXlsx:MergeCells(nLin,1,nLin,2)
oPrtXlsx:SetValue(nLin,1,_cProg+" - "+_cTitulo)
nLin++

// Formatação das linhas normais
oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )

oPrtXlsx:SetValue(nLin,1,"Emitido por: ")
oPrtXlsx:SetValue(nLin,2,Trim(cUserName)+" em "+DTOC(DATE())+"-"+SUBSTR(TIME(),1,5)+" - "+ComputerName())
nLin++
oPrtXlsx:SetValue(nLin,1,"Serviço/Porta: ")
oPrtXlsx:SetValue(nLin,2,TRIM(GetPvProfString("Service", "Name", "", GetAdv97())+"/"+GetPvProfString("TCP", "Port", "", GetAdv97())) )
nLin++
oPrtXlsx:SetValue(nLin,1,"Data Base: ")
oPrtXlsx:SetValue(nLin,2,+DTOC(dDataBase))
nLin++
oPrtXlsx:SetValue(nLin,1,"Empresa "+cEmpAnt+": ")
oPrtXlsx:SetValue(nLin,2,ALLTRIM(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_NOME"} )[1,2]))
nLin++
oPrtXlsx:SetValue(nLin,1,"Filial "+cFilAnt+": ")
oPrtXlsx:SetValue(nLin,2,ALLTRIM(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_FILIAL"} )[1,2]))
nLin++

If Len(aLocPar) > 0

	// Formatação de cabeçalho
    oPrtXlsx:SetFont(cFont, nHSize, lHItalic, lHBold, lHUnderl)
    oPrtXlsx:SetCellsFormat(cHHorAlig, cHVertAlig, lHWrapText, nHRotation, cCorS, cFundoS, "" )

	oPrtXlsx:SetValue(nLin,1,"Parâmetros - "+_cProg)
	oPrtXlsx:SetValue(nLin,2,"Conteúdo")

	// Formatação das linhas normais
    oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
    oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )

	For nI := 1 TO LEN(aLocPar)
		nLin++
		oPrtXlsx:SetValue(nLin,1,aLocPar[nI,1],)
		oPrtXlsx:SetValue(nLin,2,aLocPar[nI,2],)
	Next
EndIf
// <-- Parâmetros


// Grava a Planilha
cFileL  := cDirDest+cFile+".xlsx"

If File(cFileL)
	nRet:= FERASE(cFileL)
	If nRet < 0
		MsgAlert("Não será possivel gerar a planilha "+cFileL+", feche o arquivo",_cProg)
	EndIf
EndIf

//cGenFile := StrTran(cArquivo, ".rel", ".xlsx")

oPrtXlsx:toXlsx()
If !lJob
	If file(cFileR)
		CpyS2T(cFileX, cDirDest)
		ShellExecute("open",cFileL,"",cDirDest+"\", 1 )
	EndIf
EndIf

oPrtXlsx:EraseBaseFile()
oPrtXlsx:DeActivate()

If !lJob
	FErase(cFileX)
EndIf

FErase(cFileR)

RestArea(aArea)

Return cFileL




//-----------------------------------------------------------
//ALGORITIMO PARA CONVERTER COLUNAS DA PLANILHA
Static Function NumToString(nNum)
	Local cRet	:= ""
	If nNum<=26
		cRet	:= ColunasIndex(nNum)
	ElseIf nNum<=702
		IF nNum % 26==0
			cRet	+= ColunasIndex(((nNum-(nNum % 26))/26)-1)
		Else
			cRet	+= ColunasIndex((nNum-(nNum % 26))/26)
		EndIf
		cRet	+= ColunasIndex(nNum % 26)
	Else
		IF nNum % 26==0
			cRet	+= NumToString(((nNum-(nNum % 26))/26)-1)
		Else
			cRet	+= NumToString((nNum-(nNum % 26))/26)
		EndIf
		cRet	+= ColunasIndex(nNum % 26)
	EndIf
Return cRet

Static Function StringToNum(cString)
	Local nTam	:= Len(cString)
	Local nRet
	If nTam==1
		nRet	:= ColunasIndex(cString,2)
	ElseIf nTam==2
		nRet	:= (ColunasIndex(SubStr(cString,1,1),2)*26)+ColunasIndex(SubStr(cString,2,1),2)
	ElseIf nTam==3
		nRet	:= (ColunasIndex(SubStr(cString,1,1),2)*676)+(ColunasIndex(SubStr(cString,2,1),2)*26)+ColunasIndex(SubStr(cString,3,1),2)
	EndIf
Return nRet

Static aColIdx	:= {{1,"A"},;
					{2,"B"},;
					{3,"C"},;
					{4,"D"},;
					{5,"E"},;
					{6,"F"},;
					{7,"G"},;
					{8,"H"},;
					{9,"I"},;
					{10,"J"},;
					{11,"K"},;
					{12,"L"},;
					{13,"M"},;
					{14,"N"},;
					{15,"O"},;
					{16,"P"},;
					{17,"Q"},;
					{18,"R"},;
					{19,"S"},;
					{20,"T"},;
					{21,"U"},;
					{22,"V"},;
					{23,"W"},;
					{24,"X"},;
					{25,"Y"},;
					{26,"Z"},;
					{0,"Z"},;
					}
Static Function ColunasIndex(xNum,nIdx)
	Local cRet		:= ""
	Default nIdx	:= 1
	nPos	:= aScan(aColIdx,{|x| x[nIdx]==xNum})
	If nPos>0
		If nIdx==1
			cRet	:= aColIdx[nPos][2]
		Else
			cRet	:= aColIdx[nPos][1]
		EndIf
	EndIf
Return cRet


// Converte uma query simples para um planilha excel
User Function QryToXlsx(_cAlias,_cPlan,_cTitulo,_aDefs,_aResumo,_lClose)
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
Default _aResumo := {}

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

AADD(aPlansX,{_cAlias,_cPlan,"",_cTitulo,aCamposX,aCabsX,aImpr,aAlign,aFormat,aTotal,_aResumo,_lClose})
cArqXls := U_PlanXlsx(aPlansX,_cTitulo,_cAlias,.F.)

Return cArqXls


// Listagem de array simples - 28/10/22
User Function ArrXls(cProg,aArrXls,cTitulo,aCabec)
Local aPlans    := {}
Local nI        := 0

If Empty(aCabec) .AND. Len(aArrXls) > 0
	aCabec := {}
	For nI := 1 to LEN(aArrXls[1])
		aAdd(aCabec,"Coluna "+STRZERO(nI,3))
	Next
EndIf

AADD(aPlans,{aArrXls,cProg,cTitulo,aCabec,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */ }) 
U_ArrToXlsx(aPlans,cTitulo,cProg)

Return Nil
// Marcos - v29/06/20
// Exemplo:

//  ... aAdd(aCabec,"Total")
//	... aAdd(aItens,ZZ7->ZZ7_DTASSC)
//	... Aadd(aDados, aItens )

//	AADD(aPlans,{aDados,cPerg,cTitExcel,aCabec,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */ })   
//	MsAguarde({|| U_ArrToXlsx(aPlans,cTitExcel,cPerg,aParam,.F.)},"Aguarde","Gerando planilha...",.F.)


User Function ArrToXlsx( _aPlans,_cTitulo,_cProg, _aParam, lJob )
Default lJob := IsBlind()

u_WaitLog(_cProg,{|oSay| U_PrcArrXlsx(_aPlans,_cTitulo,_cProg, _aParam, lJob) },"Gerando Planilha Excel: "+_cProg+"...")

Return Nil


User Function PrcArrXlsx( _aPlans,_cTitulo,_cProg, _aParam, lJob )

Local oFileW    As Object
Local oPrtXlsx  As Object

Local oObjPerg  As Object

Local aPergunte
Local aLocPar 		:= {}

Local aTitulos		:= {}
Local aTamCol 		:= {}
Local aTotal  		:= {}
Local nTamCol 		:= 0
Local aRef    		:= {}

Local cTipo   		:= ""
Local cFormat 		:= ""
Local cCustomAnt	:= ""

Local cCorFonte		:= ""
Local cCorFundo		:= ""

Local cCorN			:= "000000" // Cor Preta
Local cFundoN		:= "FFFFFF" // Fundo Branco

Local cCorS			:= "FFFFFF" // Cor Branca
Local cFundoS		:= "9E0000" // Fundo Vermelho BK

//Local cCorS1		:= "000000" // Cor Preta
//Local cFundoS1		:= "E9967A" // Fundo DarkSalmon

//Local cCorS2		:= "000000" // Cor Preta
//Local cFundoS2		:= "9ACD32" // Fundo YellowGreen

Local lTotal  		:= .F.
Local nI 	  		:= 0
Local nJ	  		:= 0
Local nRow	  		:= 0
Local nLin    		:= 1
Local nTop    		:= 1
Local cColExcel 	:= ""
Local cLinTop   	:= ""
Local cLinExcel 	:= ""
Local cFile   		:= _cProg+"-"+cEmpAnt+"-"+DTOS(Date())
Local nRet    		:= 0
Local cFileL  		:= ""
Local cFileR  		:= ""
Local cFileX  		:= ""
Local cDirDest		:= "C:\TMP\"
Local cDirTmp 		:= "\tmp\"
Local nCont	  		:= 0

Local cFont			:= ""

Local nLSize 		:= 9
Local lLItalic 		:= .F.
Local lLBold 		:= .F.
Local lLUnderl		:= .F.
Local cLHorAlig		:= oCellHorAlign:Default()
Local cLVertAlig	:= oCellVertAlign:Center()
Local lLWrapText	:= .F.
Local nLRotation	:= 0

Local nHSize 		:= 9
Local lHItalic 		:= .F.
Local lHBold 		:= .T.
Local lHUnderl		:= .F.
Local cHHorAlig		:= oCellHorAlign:Center()
Local cHVertAlig	:= oCellVertAlign:Center()
Local lHWrapText	:= .T.
Local nHRotation	:= 0

Local nTSize1 		:= 18
Local nTSize2 		:= 9
Local lTItalic 		:= .F.
Local lTBold 		:= .T.
Local lTUnderl		:= .F.
Local cTHorAlig		:= oCellHorAlign:Default()
Local cTVertAlig	:= oCellVertAlign:Center()
Local lTWrapText 	:= .F.
Local nTRotation 	:= 0

Local cStartPath 	:= GetSrvProfString( "StartPath", "" ) 
Local cImgRel 		:= 'logo'
Local cImgDir 		:= cStartPath + "lgmid"+cEmpAnt+".png"
Local nHndImagem 	:= 0
Local nLenImagem 	:= 0
Local cBuffer		:= ""

Local aArea   		:= GetArea()
Local nPl     		:= 0

// -->Dif GeraXlsx
Local _aDados  		:= {}
Local _cPlan   		:= ""
Local _xTitulos		:= ""
Local _aCabs   		:= {}
Local _aImpr   		:= {}
Local _aFormula		:= {}
Local _aFormat 		:= {}
Local _aTotal  		:= {}
// <-- Dif GeraXlsx

Default lJob		:= IsBlind()
Private xCampo
Private yCampo

If lJob
	cDirDest := cDirTmp
	lOpen	:= .F.
EndIf

MakeDir(cDirTmp)
MakeDir(cDirDest)

cFileR 		:= cDirTmp+cFile+".rel"
cFileX 		:= cDirTmp+cFile+".xlsx"
oFileW      := FwFileWriter():New(cFileR)
oPrtXlsx    := FwPrinterXlsx():New()

oPrtXlsx:Activate(cFileR, oFileW)

FOR nPl := 1 TO LEN(_aPlans)

	_aDados  := _aPlans[nPl,01]
	_cPlan   := STRTRAN(_aPlans[nPl,02],"/","-")
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

	oPrtXlsx:AddSheet(_cPlan)    //Adiciona nova planilha
    cFont   := FwPrinterFont():Calibri()

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

	// Formatação dos titulos
    oPrtXlsx:SetFont(cFont, nTSize1, lTItalic, lTBold, lTUnderl)
    oPrtXlsx:SetCellsFormat(cTHorAlig, cTVertAlig, lTWrapText, nTRotation,cCorN, cFundoN, "" )

	nLin := 1
	For nJ := 1 To Len(aTitulos)
		If nJ == 1
		    oPrtXlsx:SetFont(cFont, nTSize1, lTItalic, lTBold, lTUnderl)
		Else
    		oPrtXlsx:SetFont(cFont, nTSize2, lTItalic, lTBold, lTUnderl)
		EndIf
        oPrtXlsx:SetValue(nLin,2,aTitulos[nJ])

		nLin++
	Next

	// Logo
    nHndImagem := fOpen(cImgDir, FO_READ)
    if nHndImagem < 0
        //MsgStop("Não foi possível abrir " + cImgDir)
    Else
		nLenImagem := fSeek( nHndImagem, 0, FS_END)
		fSeek( nHndImagem, 0, FS_SET)
		fRead( nHndImagem, @cBuffer, nLenImagem)
	
		oPrtXlsx:AddImageFromBuffer(1, 1, cImgRel, cBuffer, 42, 40)
	EndIf

	nTop := nLin + 1

    cFont 		:= FwPrinterFont():Calibri()

	// Formatação do cabeçalho
    oPrtXlsx:SetFont(cFont, nHSize, lHItalic, lHBold, lHUnderl)
    oPrtXlsx:SetCellsFormat(cHHorAlig, cHVertAlig, lHWrapText, nHRotation, cCorS, cFundoS, "" )

	OPrtXlsx:SetBorder(.T.,.T.,.T.,.T.,FwXlsxBorderStyle():Thin(),"000000")
	
	// Cabeçalho
	For nJ := 1 To Len(_aCabs)

	    If !EMPTY(_aImpr)  // Coluna a ignorar
			If !_aImpr[nJ]
		    	Loop
		 	EndIf 
		EndIf

		oPrtXlsx:SetValue(nLin,nJ,_aCabs[nJ])

	Next

	oPrtXlsx:ResetCellsFormat()

	// Formatação das linhas normais
    oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
    oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )


	// Tamanho das colunas e colunas de Total
	aTamCol := {}
	aTotal  := {}

	For nI :=1 to LEN(_aCabs)

	    If !EMPTY(_aImpr)  // Coluna a ignorar
			If !_aImpr[nI]
		    	Loop
		 	EndIf 
		EndIf

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
		ElseIf cTipo == "C"
			If Len(xCampo) > 8
				nTamCol := Len(xCampo) + 1
			EndIf
		Else
			nTamCol := 20
		EndIf

	    If !EMPTY(_aTotal)
			If _aTotal[nI] <> NIL 
				If lTotal
			    	lTotal  := _aTotal[nI]
			 	EndIf
		 	EndIf
		EndIf

		If nTamCol < 8
			// Não reduzir a coluna do Logo //nI == 1 .AND.
			nTamCol := 8
		EndIf

		aAdd( aTamCol, nTamCol)
		aAdd( aTotal,lTotal)

	Next

	For nJ := 1 To Len(aTamCol)
		If aTamCol[nJ] > 0
			oPrtXlsx:SetColumnsWidth(nJ,nJ,aTamCol[nJ])
		EndIf
	NEXT

	cCorFonte := cCorN
	cCorFundo := cFundoN

	For nRow := 1 To Len(_aDados)

		nLin++
		nCont++

		cCustomAnt := ""

		For nI :=1 to LEN(_aCabs)

			IF !EMPTY(_aImpr)  // Coluna a ignorar
				IF !_aImpr[nI]
					Loop
				ENDIF 
			ENDIF

			xCampo := _aDados[nRow,nI]
			cTipo  := ValType(xCampo)

			cFormat := ""
			If SUBSTR(cTipo,1,1) == "N"
			    cFormat := "#,##0.00;[Red]-#,##0.00"
			ElseIf cTipo == "D"
				If !Empty(xCampo)
			    	cFormat := "dd/mm/yyyy"
				Else
					xCampo  := ""
				EndIf
			ElseIf cTipo == "U"
				xCampo  := ""
			EndIf
            
			If cCustomAnt <> cFormat
		    	oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorFonte, cCorFundo, cFormat )
				cCustomAnt := cFormat
			EndIf

			If SUBSTR(cTipo,1,1) == "N"
            	oPrtXlsx:SetNumber(nLin,nI,xCampo)
			Else
            	oPrtXlsx:SetValue(nLin,nI,xCampo)
			EndIf

		Next

	Next

	If LEN(_aDados) > 0
		oPrtXlsx:ApplyAutoFilter(nTop-1,1,nLin,Len(_aCabs))

		//oExcel:AddPane(nTop-1,1)	//Congela paineis

		nLin++
		// Linha de Total
		oPrtXlsx:SetFont(cFont, nTSize2, lTItalic, lTBold, lTUnderl)
		oPrtXlsx:SetValue(nLin,1,"Total ("+ALLTRIM(STR(nCont))+")")

		// Formatação dos totais		
		cFormat := "#,##0.00;[Red]-#,##0.00"
		oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, cFormat )

		For nI := 2 To Len(aTotal)
			If aTotal[nI]
				cColExcel := NumToString(nI)
				cLinTop   := ALLTRIM(STR(nTop))
				cLinExcel := ALLTRIM(STR(nLin-1))
				oPrtXlsx:SetFormula(nLin,nI, "=SUBTOTAL(9,"+cColExcel+cLinTop+":"+cColExcel+cLinExcel+")")
			EndIf
		Next
		oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)		
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
			If aPergunte[2,nI,"CX1_GSC"] == "C"
				cVarDef := SUBSTR(cValToChar(&xCampo),1,1)
				If cVarDef $ "12345"
					yCampo := "CX1_DEF0"+cVarDef
					aAdd(aLocPar,{aPergunte[2,nI,"CX1_PERGUNT"],aPergunte[2,nI,yCampo]})
				EndIf
			Else
				aAdd(aLocPar,{aPergunte[2,nI,"CX1_PERGUNT"],cValToChar(&xCampo)})
			EndIf
		Next
	EndIf

EndIf

nLin := 1
oPrtXlsx:AddSheet("Parâmetros")    //Adiciona a planilha de Parâmetros
oPrtXlsx:SetColumnsWidth(1,2,50)

// Formatação de cabeçalho
oPrtXlsx:SetFont(cFont, nHSize, lHItalic, lHBold, lHUnderl)
oPrtXlsx:SetCellsFormat(cHHorAlig, cHVertAlig, lHWrapText, nHRotation, cCorS, cFundoS, "" )
oPrtXlsx:MergeCells(nLin,1,nLin,2)
oPrtXlsx:SetValue(nLin,1,_cProg+" - "+_cTitulo)
nLin++

// Formatação das linhas normais
oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )

oPrtXlsx:SetValue(nLin,1,"Emitido por: ")
oPrtXlsx:SetValue(nLin,2,Trim(cUserName)+" em "+DTOC(DATE())+"-"+SUBSTR(TIME(),1,5)+" - "+ComputerName())
nLin++
oPrtXlsx:SetValue(nLin,1,"Serviço/Porta: ")
oPrtXlsx:SetValue(nLin,2,TRIM(GetPvProfString("Service", "Name", "", GetAdv97())+"/"+GetPvProfString("TCP", "Port", "", GetAdv97())) )
nLin++
oPrtXlsx:SetValue(nLin,1,"Data Base: ")
oPrtXlsx:SetValue(nLin,2,+DTOC(dDataBase))
nLin++
oPrtXlsx:SetValue(nLin,1,"Empresa "+cEmpAnt+": ")
oPrtXlsx:SetValue(nLin,2,ALLTRIM(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_NOME"} )[1,2]))
nLin++
oPrtXlsx:SetValue(nLin,1,"Filial "+cFilAnt+": ")
oPrtXlsx:SetValue(nLin,2,ALLTRIM(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_FILIAL"} )[1,2]))
nLin++

If Len(aLocPar) > 0

	// Formatação de cabeçalho
    oPrtXlsx:SetFont(cFont, nHSize, lHItalic, lHBold, lHUnderl)
    oPrtXlsx:SetCellsFormat(cHHorAlig, cHVertAlig, lHWrapText, nHRotation, cCorS, cFundoS, "" )

	oPrtXlsx:SetValue(nLin,1,"Parâmetros - "+_cProg)
	oPrtXlsx:SetValue(nLin,2,"Conteúdo")

	// Formatação das linhas normais
    oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
    oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )

	For nI := 1 TO LEN(aLocPar)
		nLin++
		oPrtXlsx:SetValue(nLin,1,aLocPar[nI,1],)
		oPrtXlsx:SetValue(nLin,2,aLocPar[nI,2],)
	Next
EndIf
// <-- Parâmetros


// Grava a Planilha
cFileL  := cDirDest+cFile+".xlsx"

If File(cFileL)
	nRet:= FERASE(cFileL)
	If nRet < 0
		MsgAlert("Não será possivel gerar a planilha "+cFileL+", feche o arquivo",_cProg)
	EndIf
EndIf

//cGenFile := StrTran(cArquivo, ".rel", ".xlsx")

oPrtXlsx:toXlsx()
If !lJob
	If file(cFileR)
		CpyS2T(cFileX, cDirDest)
		ShellExecute("open",cFileL,"",cDirDest+"\", 1 )
	EndIf
EndIf

oPrtXlsx:EraseBaseFile()
oPrtXlsx:DeActivate()

If !lJob
	FErase(cFileX)
EndIf

FErase(cFileR)

RestArea(aArea)

Return cFileL

