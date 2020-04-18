#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} GeraXCsv
Generico - Gera planilha excel no formato .XLSX (chamada pela GeraCSV)
@Return
@author Marcos Bispo Abrahão
@since 04/04/2020
@version P12
/*/

// Funcão para gerar arquivo excell (texto, com campos separados por virgula)
//	Exemplo de campos:
//	ProcRegua(1)
//	Processa( {|| ProcQuery() })
//
//	aCabs   := {}
//	aCampos := {}
//	aTitulos:= {}
   
//	nomeprog := "BKFINR05/"+TRIM(SUBSTR(cUsuario,7,15))
//	AADD(aTitulos,nomeprog+" - "+titulo)

//	AADD(aCampos,"QSE2->Z2_BANCO")
//	AADD(aCabs  ,"Banco")
//		AADD(aTitulos,"Cliente de: "+mv_par01)  -> Titulo do relatorio
//		AADD(aCampos,"QSC9->C9_FILIAL")         -> Campo
//		AADD(aCabs  ,"Filial")                  -> Cab do Campo
//         cTpQuebra : "H"-> Quebra Horizontal, itens na mesma linha "V" -> Quebra em novas linhas
//                     " "-> Sem Quebra
//         cQuebra = "QSC9->C9_FILIAL+QSC9->C9_PRODUTO"
//         AADD(AQuebra,{ {"QSC9->C9_FILIAL","Filial"},{"QSC9->C9_PRODUTO","Produto"} }
//
//  Chamada
//    Processa( {|| U_GeraCSVQ("QSC6",TRIM(cPerg),aTitulos,aCampos,aCabs)})


// Converte query ou dbf em arquivo .csv
// Exemplo: 	U_QryToCsv("QSC2",cPerg,{Titulo})


User Function GeraXCSV(cAliasTrb,cArqXlsx,aTitulos,aCampos,aCabs,cTpQuebra,cQuebra,aQuebra,lClose)

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
Local cFile   := cArqXlsx+"-"+DTOS(Date())
Local nRet    := 0
Local cDirTmp := "C:\TMP"

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

(cAliasTrb)->(dbgotop())
If (cAliasTrb)->(EOF())
    MsgStop("Não há dados para gerar a planilha Excel",cArqXlsx)
    Return Nil
EndIf

MakeDir(cDirTmp)

oExcel:new(cFile)

oExcel:ADDPlan(cArqXlsx,"0000FF")		//Adiciona nova planilha

oAlCenter	:= oExcel:Alinhamento("center","center")
oVtCenter	:= oExcel:Alinhamento(,"center")
nPosFont	   := oExcel:AddFont(10,"FFFFFFFF","Calibri","2")
nTitFont	   := oExcel:AddFont(20,"00000000","Calibri","2")
nTit2Font	:= oExcel:AddFont(14,"00000000","Calibri","2")
nPosCor		:= oExcel:CorPreenc("9E0000")	//Cor de Fundo Vermelho alterado
nLisCor		:= oExcel:CorPreenc("D9D9D9")
nBordas 	   := oExcel:Borda("ALL")
nFmtNum2	   := oExcel:AddFmtNum(2/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)

				//nTamanho,cCorRGB,cNome,cfamily,cScheme,lNegrito,lItalico,lSublinhado,lTachado
nTotFont 	:= oExcel:AddFont(11,56,"Calibri","2",,.T.,.F.,.F.,.F.)
nApoFont 	:= oExcel:AddFont(11,"FF0000","Calibri","2",,.T.,.F.,.F.,.F.)

nPosStyle	:= oExcel:AddStyles(/*numFmtId*/,nPosFont/*fontId*/,nPosCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})
nLisStyle	:= oExcel:AddStyles(/*numFmtId*/,/*fontId*/,nLisCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,)

nV2Style	   := oExcel:AddStyles(nFmtNum2/*numFmtId*/,/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nD2Style	   := oExcel:AddStyles(14/*numFmtId*/,/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})
nG2Style 	:= oExcel:AddStyles(/*numFmtId*/,/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nT2Style	   := oExcel:AddStyles(nFmtNum2/*numFmtId*/,nTotFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)

nTitStyle	:= oExcel:AddStyles(/*numFmtId*/,nTitFont/*fontId*/,/*fillId*/,/*borderId*/,/*xfId*/,{oVtCenter})
nTit2Style	:= oExcel:AddStyles(/*numFmtId*/,nTit2Font/*fontId*/,/*fillId*/,/*borderId*/,/*xfId*/,{oVtCenter})
nApoStyle	:= oExcel:AddStyles(/*numFmtId*/,nApoFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nVApoStyle	:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,nApoFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nDApoStyle	:= oExcel:AddStyles(14/*numFmtId*/,nApoFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)

nTotStyle	:= oExcel:AddStyles(/*numFmtId*/,nTotFont/*fontId*/,nLisCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,)

nIDImg		:= oExcel:ADDImg("LGMID"+cEmpAnt+".PNG")	//Imagem no Protheus_data

// Logotipo
//oExcel:mergeCells(1,1,Len(aTitulos)+1,1)						//Mescla as células 

			  //nID,nLinha,nColuna,nX,nY,cUnidade,nRot
oExcel:nTamLinha := 34
oExcel:Img(nIDImg,1,1,40,40,/*"px"*/,)
If Len(aTitulos) == 1
   aAdd(aTitulos,cArqXlsx+" - Emitido em: "+DTOC(DATE())+"-"+SUBSTR(TIME(),1,5)+" - "+cUserName)
EndIf

// Titulo
nLin := 1
For nJ := 1 To Len(aTitulos)
   oExcel:mergeCells(nLin,2,nLin,Len(aCabs))
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
For nJ := 1 To Len(aCabs)
	oExcel:Cell(nLin,nJ,aCabs[nJ],,nPosStyle)
NEXT

// Tamanho das colunas e colunas de Total

(cAliasTrb)->(dbgotop())
For nI :=1 to LEN(aCampos)
	xCampo := &(aCampos[nI])
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
	aAdd( aTamCol, nTamCol)
	aAdd( aTotal,lTotal)

Next

For nJ := 1 To Len(aTamCol)
	If aTamCol[nJ] > 0
		oExcel:AddTamCol(nJ,nJ,aTamCol[nJ])
	EndIf
NEXT

(cAliasTrb)->(dbgotop())
ProcRegua((cAliasTrb)->(LastRec())) 

Do While (cAliasTrb)->(!eof()) 

   IncProc("Gerando planilha "+cFile+"...")   

	nLin++

	For nI :=1 to LEN(aCampos)

		xCampo := &(aCampos[nI])

		If ValType(xCampo) == "N"
			oExcel:Cell(nLin,nI,xCampo,,nV2Style)
		ElseIf ValType(xCampo) == "D"
			oExcel:Cell(nLin,nI,xCampo,,nD2Style)
		Else
			oExcel:Cell(nLin,nI,xCampo,,nG2Style)
		EndIf
	Next

	(cAliasTrb)->(dbskip())
EndDo


oExcel:AutoFilter(nTop-1,1,nLin,Len(aCabs))	//Auto filtro
oExcel:AddPane(nTop-1,1)	//Congela paineis

nLin++
oExcel:Cell(nLin,1,"Total",,nTotStyle)
For nI := 1 To Len(aTotal)
	If aTotal[nI]
		oExcel:AddNome("COLUNA"+STRZERO(nI,3) ,nTop, nI, nLin-1, nI)
		oExcel:Cell(nLin,nI,0,"SUBTOTAL(9,"+"COLUNA"+STRZERO(nI,3)+")",nT2Style)
	EndIf
Next

cFile := cDirTmp+"\"+cFile+".xlsx"
If File(cFile)
	nRet:= FERASE(cFile)
	If nRet < 0
		MsgStop("Não será possivel gerar a planilha "+cFile+", feche o arquivo",cArqXlsx)
	EndIf
EndIf

IF lClose   
   (cAliasTrb)->(dbCloseArea())
ENDIF

oExcel:Gravar(cDirTmp+"\",.T.,.T.)

return


User Function QryToXCsv(_cAlias,cArqS,aTitulos,lClose)
Local _nI
Local aCabs   := {}
Local aCampos := {}                 

dbSelectArea(_cAlias)
FOR _nI := 1 TO FCOUNT()
    AADD(aCabs,FIELDNAME(_ni))
    AADD(aCampos,_cAlias+"->"+FIELDNAME(_ni))
NEXT

ProcRegua(LASTREC())
Processa( {|| U_GeraXCSV(_cAlias,TRIM(cArqS),aTitulos,aCampos,aCabs,,,,lClose)})

Return nil
