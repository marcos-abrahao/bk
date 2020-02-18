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

Local nF  := 0

Private cTitulo     := "Planilha diária de Pagamentos"
Private cPerg       := "BKFINR25"

Private aParam		:=	{}
Private aRet		:=	{}

Private dDataI  	:= CTOD("")
Private dDataF  	:= CTOD("")

Private aFields     := {}
Private aCabs       := {}
Private aCampos     := {}
Private aTitulos    := {}
Private aPlans      := {}
Private aDbf        := {}
Private aHeader     := {}
Private cAliasQry   := ""
Private cAliasTrb   := GetNextAlias()
Private nCont       := 0
Private aTotais     := {}
Private aLF         := {}
Private nTop		:= 3
Private nTopV		:= nTop + 1
Private cCVal  		:= "I"
Private cCSal  		:= "J"

Private cVa  := ""
Private cVR  := "" // VR
Private cVT  := "" // VT
Private cRes := "" // MFG / LRC
Private cFe  := "" // LFE
Private cCLT := "" // LPM / LAD
Private c13  := "" // LD1 / LD2
Private cPen := "" // PEN
Private cExm := "" // EXM
Private cDV  := "" // SOL/HOS
Private cForn:= ""

Private cSVa  := ""
Private cSVR  := "" // VR
Private cSVT  := "" // VT
Private cSRes := "" // MFG / LRC
Private cSFe  := "" // LFE
Private cSCLT := "" // LPM / LAD
Private cS13  := "" // LD1 / LD2
Private cSPen := "" // PEN
Private cSExm := "" // EXM
Private cSDV  := "" // SOL/HOS
Private cSForn:= ""

aAdd( aParam, { 1, "Data Inicial:" 	, dDataBase	, "" , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Data Final:" 	, dDataBase	, "" , "", ""	, "" , 70  , .F. })  

If !BkFR25()
   Return
EndIf


AADD(aTitulos,cPerg+"/"+TRIM(cUserName)+" - "+cTitulo)


aAdd(aFields,{"XX_FORNECE","E2_FORNECE"})
aAdd(aFields,{"XX_LOJA"   ,"E2_LOJA"})
aAdd(aFields,{"XX_NOMFOR" ,"E2_NOMFOR"})
aAdd(aFields,{"XX_PREFIXO","E2_PREFIXO"})
aAdd(aFields,{"XX_NUM"    ,"E2_NUM"})
aAdd(aFields,{"XX_XXTIPBK","E2_XXTIPBK"})
aAdd(aFields,{"XX_PARCELA","E2_PARCELA"})
aAdd(aFields,{"XX_VENCREA","E2_VENCREA"})
aAdd(aFields,{"XX_VALOR"  ,"E2_VALOR"})
aAdd(aFields,{"XX_SALDO"  ,"E2_SALDO"})

//aAdd(aFields,{"XX_SALDO","","(cAliasTrb)->(XX_SALDO)","Saldo Consolidado",cPict,"N",18,2})


aDbf    := {}

For nF := 1 To Len(aFields)

	aAdd(aCampos,"(cAliasTrb)->"+aFields[nF,1])

	If !Empty(aFields[nF,2])
		aAdd( aDbf, { aFields[nF,1],GetSX3Cache(aFields[nF,2],"X3_TIPO"), GetSX3Cache(aFields[nF,2],"X3_TAMANHO"),GetSX3Cache(aFields[nF,2],"X3_DECIMAL") } )
		aAdd(aCabs  ,RetTitle(aFields[nF,2]))
		aAdd(aHeader,{	RetTitle(aFields[nF,2]),;
						aFields[nF,1],;
						GetSX3Cache(aFields[nF,2],"X3_PICTURE"),;
						GetSX3Cache(aFields[nF,2],"X3_TAMANHO"),;
						GetSX3Cache(aFields[nF,2],"X3_DECIMAL"),;
						"",;
						"",;
						GetSX3Cache(aFields[nF,2],"X3_TIPO"),;
						cAliasTrb,;
						"R"})
	Else
		aAdd( aDbf, { aFields[nF,1],aFields[nF,6], aFields[nF,7],aFields[nF,8] } )
		aAdd(aCabs  ,aFields[nF,4])
		aAdd(aHeader,{	aFields[nF,4],;
						aFields[nF,1],;
						aFields[nF,5],;
						aFields[nF,7],;
						aFields[nF,8],;
						"",;
						"",;
						aFields[nF,6],;
						cAliasTrb,;
						"R"})
	
	EndIf	

Next

cArqTmp := CriaTrab( aDbf, .t. )
dbUseArea( .t.,NIL,cArqTmp,cAliasTrb,.f.,.f. )

//IndRegua(cAliasTrb,cArqTmp,"XX_NUM",,,"Indexando Arquivo de Trabalho") 

Processa( {|| ProcBKR25() })

//AADD(aPlans,{cAliasTrb,TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })

//MsAguarde({|| U_GeraXml(aPlans,cTitulo,TRIM(cPerg),.F.)},"Aguarde","Gerando planilha...",.F.)

//MsAguarde({|| BKFINE25(cAliasTrb,TRIM(cPerg),cTitulo,aCampos,aCabs)},"Aguarde","Gerando planilha...",.F.)
MsAguarde({|| BKFINX25(cAliasTrb,TRIM(cPerg),cTitulo,aCampos,aCabs)},"Aguarde","Gerando planilha...",.F.)

(cAliasTrb)->(Dbclosearea())
FErase(cArqTmp+GetDBExtension())
FErase(cArqTmp+OrdBagExt())

Return

Static Function BkFR25
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,@cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKFINR23",.T.         ,.T.))
	lRet     := .T.
	dDataI   := mv_par01
	dDataF   := mv_par02
	cTitulo  := "Planilha Diária de Pagamentos - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
Endif
Return lRet


Static Function ProcBKR25
Local cQuery := ""
Local nF     := 0
Local nValor := 0
Local nSaldo := 0

Private xCampo

cQuery := "SELECT "
For nF := 1 To Len(aFields)
	cQuery += aFields[nF,2]+","
Next
cQuery += "R_E_C_N_O_ AS E2_RECNO"

cQuery += " FROM "+RETSQLNAME("SE2")+" SE2" 

cQuery += " WHERE SE2.D_E_L_E_T_ = ' ' "
cQuery += " AND SE2.E2_FILIAL = '" + xFilial("SE2") + "' "
cQuery += " AND SE2.E2_TIPO NOT IN "+FormatIn(MVABATIM,";")
If !Empty(dDataI)
	cQuery += " AND SE2.E2_VENCREA >= '"+DTOS(dDataI)+"'"
EndIf
If !Empty(dDataF)
	cQuery += " AND SE2.E2_VENCREA <= '"+DTOS(dDataF)+"'"
EndIf          
cQuery += " ORDER BY E2_NUM"

//MemoWrite("BKFINR25.SQL",cQuery)
	
cAliasQry := "TMPR25" //GetNextAlias()

//TCQUERY cQuery NEW ALIAS "TMPR25"

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPR25', .F., .T.)
TCSETFIELD(cAliasQry,"E2_VENCREA","D", 8,0)
TCSETFIELD(cAliasQry,"E2_VALOR"  ,"N",18,2)
	
ProcRegua((cAliasQry)->(RecCount()))
	
nCont := 0
	
dbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())
DO WHILE (cAliasQry)->(!EOF())
    nCont++
	IncProc("Consultando banco de dados...")
	dbSelectArea(cAliasTrb)
	Reclock(cAliasTrb,.T.)
		
	For nF := 1 To Len(aFields)
		If !Empty(aFields[nF,2])
			xCampo := &(cAliasQry+"->"+aFields[nF,2])
			&(cAliasTrb+"->"+aFields[nF,1]) :=  xCampo
		Else
			xCampo := &(aFields[nF,3])
		EndIf
		If aFields[nF,2] = "E2_SALDO"
			SE2->(dbGoTo((cAliasQry)->E2_RECNO))
			nSaldo := SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,1,,dDataI-1,SE2->E2_LOJA,,0/*nTxMoeda*/)
			xCampo := nSaldo
		EndIf


		&(cAliasTrb+"->"+aFields[nF,1]) :=  xCampo
	Next


	cTipoBk := TRIM((cAliasQry)->E2_XXTIPBK)
	nValor  := (cAliasQry)->E2_VALOR

	IF cTipoBk = "VA"
		cVa += iif(!Empty(cVa),"+","")+cCVal+Alltrim(STR(nCont+nTop))
		cSVa += iif(!Empty(cSVa),"+","")+cCSal+Alltrim(STR(nCont+nTop))
	ELSEIF cTipoBk = "VR"
		cVr += iif(!Empty(cVr),"+","")+cCVal+Alltrim(STR(nCont+nTop))
		cSVr += iif(!Empty(cSVr),"+","")+cCSal+Alltrim(STR(nCont+nTop))
	ELSEIF cTipoBk = "VT"
		cVT += iif(!Empty(cVT),"+","")+cCVal+Alltrim(STR(nCont+nTop))
		cSVT += iif(!Empty(cSVT),"+","")+cCSal+Alltrim(STR(nCont+nTop))
	ELSEIF cTipoBk $ "MFG/LRC"
		cRes += iif(!Empty(cRes),"+","")+cCVal+Alltrim(STR(nCont+nTop))
		cSRes += iif(!Empty(cSRes),"+","")+cCSal+Alltrim(STR(nCont+nTop))
	ELSEIF cTipoBk = "LFE"
		cFe += iif(!Empty(cFe),"+","")+cCVal+Alltrim(STR(nCont+nTop))
		cSFe += iif(!Empty(cSFe),"+","")+cCSal+Alltrim(STR(nCont+nTop))
	ELSEIF cTipoBk $ "LPM/LAD"
		cCLT += iif(!Empty(cCLT),"+","")+cCVal+Alltrim(STR(nCont+nTop))
		cSCLT += iif(!Empty(cSCLT),"+","")+cCSal+Alltrim(STR(nCont+nTop))
	ELSEIF cTipoBk $ "LD1/LD2"
		c13 += iif(!Empty(c13),"+","")+cCVal+Alltrim(STR(nCont+nTop))
		cS13 += iif(!Empty(cS13),"+","")+cCSal+Alltrim(STR(nCont+nTop))
	ELSEIF cTipoBk = "PEN"
		cPen += iif(!Empty(cPen),"+","")+cCVal+Alltrim(STR(nCont+nTop))
		cSPen += iif(!Empty(cSPen),"+","")+cCSal+Alltrim(STR(nCont+nTop))
	ELSEIF cTipoBk = "EXM"
		cExm += iif(!Empty(cExm),"+","")+cCVal+Alltrim(STR(nCont+nTop))
		cSExm += iif(!Empty(cSExm),"+","")+cCSal+Alltrim(STR(nCont+nTop))
	ELSEIF cTipoBk $ "SOL/HOS"
		cDV += iif(!Empty(cDV),"+","")+cCVal+Alltrim(STR(nCont+nTop))
		cSDV += iif(!Empty(cSDV),"+","")+cCSal+Alltrim(STR(nCont+nTop))
	ELSE
		cForn += iif(!Empty(cForn),"+","")+cCVal+Alltrim(STR(nCont+nTop))
		cSForn += iif(!Empty(cSForn),"+","")+cCSal+Alltrim(STR(nCont+nTop))
	ENDIF


	(cAliasTrb)->(MsUnLock())
		
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbSkip())
ENDDO

(cAliasQry)->(dbCloseArea())

dbSelectArea(cAliasTrb)
dbGoTop()

Return



/*/{Protheus.doc} BKFINE25
Teste da classe YExcel
@author Saulo Gomes Martins
@since 08/05/2017

@type function
@obs para leitura ver função YxlsRead no fim do fonte
/*/
Static Function BKFINE25(cAliasTrb,cArqXlsx,cTitulo,aCampos,aCabs)
Local oExcel  := YExcel():new()
Local nTotal  := 0
Local nI 	:= 0
Local nJ	:= 0

oExcel:new(cArqXlsx)

oExcel:ADDPlan("Tabela","0000FF")		//Adiciona nova planilha

oExcel:SetPrintTitles(1,1)				//Linha de/ate que irá repetir na impressão de paginas
oExcel:showGridLines(.F.)		//Oculta linhas de grade
oExcel:SetDefRow(.T.,{1,Len(aCabs)})		//Definir a coluna inicial e final da linha, importante para performace da classe

oTabela	:= oExcel:AddTabela("Tabela1",1,1)	//Cria uma tabela de estilos
oTabela:AddStyle("TableStyleMedium15"/*cNome*/,.T./*lLinhaTiras*/,/*lColTiras*/,/*lFormPrimCol*/,/*lFormUltCol*/)	//Cria os estilos,Cab:Preto|Linha:Cinza,Branco
//oTabela:AddStyle("TableStyleMedium2"/*cNome*/,.T./*lLinhaTiras*/,/*lColTiras*/,.T./*lFormPrimCol*/,/*lFormUltCol*/)	//Cria os estilos,Cab:Azul|Linha:Azul,Branco
oTabela:AddFilter()				//Adiciona filtros a tabela

For nJ := 1 To Len(aCabs)
	oTabela:AddColumn(aCabs[nJ])		//Adiciona cabeçalho
NEXT

oExcel:AddPane(1,1)	//Congela primeira linha e primeira coluna

nTotal	:= 0	//Valor Total da venda

(cAliasTrb)->(dbgotop())

Do While (cAliasTrb)->(!eof()) 

	oTabela:AddLine()				//Adiciona nova linha

	For nI :=1 to LEN(aCampos)

		xCampo := &(aCampos[nI])
		oTabela:Cell(nI,xCampo,,)

	Next

	(cAliasTrb)->(dbskip())
EndDo
//oTabela:AddTotal(1,"TOTAL","")							//Preenche texto TOTAL na linha totalizadora da coluna Linha
//oTabela:AddTotal("Filial",99,"SUBTOTAL(103,Tabela1[Filial])")	//Usa função COUNTA(Contar Valores)
//oTabela:AddTotal(8,nTotal,"SUM")		//Usa função SUM(Somar) para totalizar a coluna venda
//oTabela:AddTotais()	//Adiciona linha de totais

oTabela:Finish()	//Fecha a edição da tabela

oExcel:Gravar(GetTempPath(),.T.,.T.)

return



Static Function BKFINX25(cAliasTrb,cArqXlsx,cTitulo,aCampos,aCabs)
Local oExcel  := YExcel():new()
Local nI 	:= 0
Local nJ	:= 0
Local nLin  := 1

oExcel:new(cArqXlsx+"-"+DTOS(dDataI))

oExcel:ADDPlan(cArqXlsx,"0000FF")		//Adiciona nova planilha

oAlinhamento	:= oExcel:Alinhamento("center","center")
nPosFont		:= oExcel:AddFont(10,"FFFFFFFF","Calibri","2")
nTitFont		:= oExcel:AddFont(20,"00000000","Calibri","2")
nPosCor			:= oExcel:CorPreenc("9E0000")	//Cor de Fundo Vermelho alterado
nLisCor         := oExcel:CorPreenc("D9D9D9")
nPosBorda2		:= oExcel:Borda("ALL")
nFmtNum2		:= oExcel:AddFmtNum(2/*nDecimal*/,.T./*lMilhar*/,/*cPrefixo*/,/*cSufixo*/,"("/*cNegINI*/,")"/*cNegFim*/,/*cValorZero*/,/*cCor*/,"Red"/*cCorNeg*/,/*nNumFmtId*/)

					//nTamanho,cCorRGB,cNome,cfamily,cScheme,lNegrito,lItalico,lSublinhado,lTachado
nTotFont 		:= oExcel:AddFont(10,56,"Calibri","2",,.T.,.F.,.F.,.F.)

nPosStyle		:= oExcel:AddStyles(/*numFmtId*/,nPosFont/*fontId*/,nPosCor/*fillId*/,/*borderId*/,/*xfId*/,{oAlinhamento})
nLisStyle		:= oExcel:AddStyles(/*numFmtId*/,/*fontId*/,nLisCor/*fillId*/,/*borderId*/,/*xfId*/,)
nV2Style		:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,/*fontId*/,/*fillId*/,/*borderId*/,/*xfId*/,)
nT2Style		:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,nTotFont/*fontId*/,/*fillId*/,/*borderId*/,/*xfId*/,)
nTitStyle		:= oExcel:AddStyles(/*numFmtId*/,nTitFont/*fontId*/,/*fillId*/,/*borderId*/,/*xfId*/,{oAlinhamento})

nTotStyle		:= oExcel:AddStyles(/*numFmtId*/,nTotFont/*fontId*/,nLisCor/*fillId*/,/*borderId*/,/*xfId*/,)
nPosBordas		:= oExcel:AddStyles(/*numFmtId*/,/*fontId*/,/*fillId*/,nPosBorda2/*borderId*/,/*xfId*/,)


nIDImg			:= oExcel:ADDImg("LGMID"+cEmpAnt+".PNG")	//Imagem no Protheus_data

oExcel:mergeCells(1,1,2,1)						//Mescla as células 

			  //nID,nLinha,nColuna,nX,nY,cUnidade,nRot
oExcel:Img(nIDImg,1,1,40,40,/*"px"*/,)

oExcel:Cell(1,2,"Pagamentos Diários - "+DTOC(dDataI),,nTitStyle)
oExcel:mergeCells(1,2,2,13)						//Mescla as células 

nLin := nTop
For nJ := 1 To Len(aCabs)
	oExcel:Cell(nLin,nJ,aCabs[nJ],,nPosStyle)
NEXT

oExcel:AddTamCol(1,1,10.45)
oExcel:AddTamCol(2,2,03.90)
oExcel:AddTamCol(3,3,25.00)
oExcel:AddTamCol(4,4,08.40)
oExcel:AddTamCol(5,5,10.30)
oExcel:AddTamCol(6,6,06.90)
oExcel:AddTamCol(7,7,06.60)
oExcel:AddTamCol(8,8,11.00)
oExcel:AddTamCol(9,9,13.50)
oExcel:AddTamCol(10,10,13.50)
oExcel:AddTamCol(11,11,10.00)
oExcel:AddTamCol(12,12,50.00)
oExcel:AddTamCol(13,13,13.50)
oExcel:AddTamCol(14,14,13.50)
(cAliasTrb)->(dbgotop())

Do While (cAliasTrb)->(!eof()) 

	nLin++

	For nI :=1 to LEN(aCampos)

		xCampo := &(aCampos[nI])
		//oTabela:Cell(nI,xCampo,,)
		//oExcel:Cell(nCont,nI,xCampo,,nPosBordas)
		If ValType(xCampo) == "N"
			oExcel:Cell(nLin,nI,xCampo,,nV2Style)
		Else
			oExcel:Cell(nLin,nI,xCampo)
		EndIf

	Next

	Plan2(oExcel,nLin)

	(cAliasTrb)->(dbskip())
EndDo

oExcel:AddNome("TIPOBK" ,nTopV, 6,nLin,6)
oExcel:AddNome("VALORES",nTopV, 9,nLin,9)	
oExcel:AddNome("SALDOS" ,nTopV,10,nLin,10)	

nLin++
oExcel:Cell(nLin,9,0,"SUM(VALORES)",nV2Style)
oExcel:Cell(nLin,10,0,"SUM(SALDOS)",nV2Style)
//oExcel:Cell(nLin,9,0,"SUM("+cCVal+ALLTRIM(STR(nTopV))+":"+cCVal+ALLTRIM(STR(nLin-1))+")",nV2Style)


If nLin < 60
	For nJ := nLin TO 60
		Plan2(oExcel,nJ)
	Next
EndIf

oExcel:Gravar("C:\TEMP\",.T.,.T.)
return



Static Function Plan2(oExcel,nLin)
Local nPosT := 12
Local nPosV := 13
Local nPosS := 14
Local nPosL := 15
//Local cPosV := CHR(64+nPosV)

DO CASE
	CASE nLin == nTopV 
		oExcel:Cell(nLin,nPosT,"PESSOAL",,nPosStyle)
		oExcel:Cell(nLin,nPosV,"TOTAIS",,nPosStyle)
		oExcel:Cell(nLin,nPosS,"SALDOS",,nPosStyle)
		oExcel:Cell(nLin,nPosL,"SIGLAS",,nPosStyle)

	CASE nLin == nTopV + 1

		oExcel:Cell(nLin,nPosT,"Folha CLT",,nLisStyle)
		//oExcel:Cell(nLin,nPosV,0,cClt,nV2Style)  
		//oExcel:Cell(nLin,nPosS,0,cSClt,nV2Style)  
		oExcel:Cell(nLin,nPosV,0,"SUMIF(TIPOBK,&quot;=LPM&quot;,VALORES)+SUMIF(TIPOBK,&quot;=LAD&quot;,VALORES)",nV2Style)
		oExcel:Cell(nLin,nPosS,0,"SUMIF(TIPOBK,&quot;=LPM&quot;,SALDOS)+SUMIF(TIPOBK,&quot;=LAD&quot;,SALDOS)",nV2Style)
		oExcel:Cell(nLin,nPosL,"LPM/LAD")

	CASE nLin == nTopV + 2
		oExcel:Cell(nLin,nPosT,"Férias")
		//oExcel:Cell(nLin,nPosV,0,cFe,nV2Style)  
		//oExcel:Cell(nLin,nPosS,0,cSFe,nV2Style)  
		oExcel:Cell(nLin,nPosV,0,"SUMIF(TIPOBK,&quot;=LFE&quot;,VALORES)",nV2Style)
		oExcel:Cell(nLin,nPosS,0,"SUMIF(TIPOBK,&quot;=LFE&quot;,SALDOS)",nV2Style)
		oExcel:Cell(nLin,nPosL,"LFE")

	CASE nLin == nTopV + 3
		oExcel:Cell(nLin,nPosT,"13º Salário",,nLisStyle)
		//oExcel:Cell(nLin,nPosV,0,c13,nV2Style)
		//oExcel:Cell(nLin,nPosS,0,cS13,nV2Style)
		oExcel:Cell(nLin,nPosV,0,"SUMIF(TIPOBK,&quot;=LD1&quot;,VALORES)+SUMIF(TIPOBK,&quot;=LD2&quot;,VALORES)",nV2Style)
		oExcel:Cell(nLin,nPosS,0,"SUMIF(TIPOBK,&quot;=LD1&quot;,SALDOS)+SUMIF(TIPOBK,&quot;=LD2&quot;,SALDOS)",nV2Style)
		oExcel:Cell(nLin,nPosL,"LD1/LD2")

	CASE nLin == nTopV + 4
		oExcel:Cell(nLin,nPosT,"Rescisões + MFG")
		//oExcel:Cell(nLin,nPosV,0,cRes,nV2Style)
		//oExcel:Cell(nLin,nPosS,0,cSRes,nV2Style)
		oExcel:Cell(nLin,nPosV,0,"SUMIF(TIPOBK,&quot;=LRC&quot;,VALORES)+SUMIF(TIPOBK,&quot;=MGF&quot;,VALORES)",nV2Style)
		oExcel:Cell(nLin,nPosS,0,"SUMIF(TIPOBK,&quot;=LRC&quot;,SALDOS)+SUMIF(TIPOBK,&quot;=MGF&quot;,SALDOS)",nV2Style)
		oExcel:Cell(nLin,nPosL,"MFG/LRC")

	CASE nLin == nTopV + 5
		oExcel:Cell(nLin,nPosT,"Pensão alimetícia",,nLisStyle)
		//oExcel:Cell(nLin,nPosV,0,cPen,nV2Style)
		//oExcel:Cell(nLin,nPosS,0,cSPen,nV2Style)
		oExcel:Cell(nLin,nPosV,0,"SUMIF(TIPOBK,&quot;=PEN&quot;,VALORES)",nV2Style)
		oExcel:Cell(nLin,nPosS,0,"SUMIF(TIPOBK,&quot;=PEN&quot;,SALDOS)",nV2Style)
		oExcel:Cell(nLin,nPosL,"PEN")

	CASE nLin == nTopV + 6
		oExcel:Cell(nLin,nPosT,"BENFÍCIOS",,nPosStyle)

	CASE nLin == nTopV + 7
		oExcel:Cell(nLin,nPosT,"Seguro saúde")

	CASE nLin == nTopV + 8
		oExcel:Cell(nLin,nPosT,"Seguro odontológico",,nLisStyle)

	CASE nLin == nTopV + 9
		oExcel:Cell(nLin,nPosT,"Seguro de vida")

	CASE nLin == nTopV + 10
		oExcel:Cell(nLin,nPosT,"Vale refeição",,nLisStyle)
		//oExcel:Cell(nLin,nPosV,0,cVR,nV2Style)
		//oExcel:Cell(nLin,nPosS,0,cSVR,nV2Style)
		oExcel:Cell(nLin,nPosV,0,"SUMIF(TIPOBK,&quot;=VR&quot;,VALORES)",nV2Style)
		oExcel:Cell(nLin,nPosS,0,"SUMIF(TIPOBK,&quot;=VR&quot;,SALDOS)",nV2Style)
		oExcel:Cell(nLin,nPosL,"VR")

	CASE nLin == nTopV + 11
		oExcel:Cell(nLin,nPosT,"Vale alimentação")
		//oExcel:Cell(nLin,nPosV,0,cVA,nV2Style)
		//oExcel:Cell(nLin,nPosS,0,cSVA,nV2Style)
		oExcel:Cell(nLin,nPosV,0,"SUMIF(TIPOBK,&quot;=VA&quot;,VALORES)",nV2Style)
		oExcel:Cell(nLin,nPosS,0,"SUMIF(TIPOBK,&quot;=VA&quot;,SALDOS)",nV2Style)
		oExcel:Cell(nLin,nPosL,"VA")


	CASE nLin == nTopV + 12
		oExcel:Cell(nLin,nPosT,"Vale transporte",,nLisStyle)
		//oExcel:Cell(nLin,nPosV,0,cVT,nV2Style)
		//oExcel:Cell(nLin,nPosS,0,cSVT,nV2Style)
		oExcel:Cell(nLin,nPosV,0,"SUMIF(TIPOBK,&quot;=VT&quot;,VALORES)",nV2Style)
		oExcel:Cell(nLin,nPosS,0,"SUMIF(TIPOBK,&quot;=VT&quot;,SALDOS)",nV2Style)
		oExcel:Cell(nLin,nPosL,"VT")

	CASE nLin == nTopV + 13
		oExcel:Cell(nLin,nPosT,"Cursos e Treinamento")

	CASE nLin == nTopV + 14
		oExcel:Cell(nLin,nPosT,"",,nLisStyle)

	CASE nLin == nTopV + 15
		oExcel:Cell(nLin,nPosT,"DESPESAS DE VIAGEM",,nPosStyle)

	CASE nLin == nTopV + 16
		oExcel:Cell(nLin,nPosT,"DV (SOL + HOS)",,nLisStyle)
		//oExcel:Cell(nLin,nPosV,0,cDV,nV2Style)
		//oExcel:Cell(nLin,nPosS,0,cSDV,nV2Style)
		oExcel:Cell(nLin,nPosV,0,"SUMIF(TIPOBK,&quot;=SOL&quot;,VALORES)+SUMIF(TIPOBK,&quot;=HOS&quot;,VALORES)",nV2Style)
		oExcel:Cell(nLin,nPosS,0,"SUMIF(TIPOBK,&quot;=SOL&quot;,SALDOS)+SUMIF(TIPOBK,&quot;=HOS&quot;,SALDOS)",nV2Style)
		oExcel:Cell(nLin,nPosL,"SOL/HOS")

	CASE nLin == nTopV + 17
		oExcel:Cell(nLin,nPosT,"ENCARGOS",,nPosStyle)

	CASE nLin == nTopV + 18
		oExcel:Cell(nLin,nPosT,"INSS",,nLisStyle)

	CASE nLin == nTopV + 19
		oExcel:Cell(nLin,nPosT,"FGTS")

	CASE nLin == nTopV + 20
		oExcel:Cell(nLin,nPosT,"IRRF",,nLisStyle)

	CASE nLin == nTopV + 21
		oExcel:Cell(nLin,nPosT,"Sindicatos e Assoc. Classe (CECM Furnas)")

	CASE nLin == nTopV + 22
		oExcel:Cell(nLin,nPosT,"Exames Médicos",,nLisStyle)
		//oExcel:Cell(nLin,nPosV,0,cExm,nV2Style)
		//oExcel:Cell(nLin,nPosS,0,cSExm,nV2Style)
		oExcel:Cell(nLin,nPosV,0,"SUMIF(TIPOBK,&quot;=EXM&quot;,VALORES)",nV2Style)
		oExcel:Cell(nLin,nPosS,0,"SUMIF(TIPOBK,&quot;=EXM&quot;,SALDOS)",nV2Style)
		oExcel:Cell(nLin,nPosL,"EXM")

	CASE nLin == nTopV + 23
		oExcel:Cell(nLin,nPosT,"Trabalhistas")

	CASE nLin == nTopV + 24
		oExcel:Cell(nLin,nPosT,"",,nLisStyle)

	CASE nLin == nTopV + 25
		oExcel:Cell(nLin,nPosT,"OUTRAS DESPESAS",,nPosStyle)

	CASE nLin == nTopV + 26
		oExcel:Cell(nLin,nPosT,"Aluguel",,nLisStyle)

	CASE nLin == nTopV + 27
		oExcel:Cell(nLin,nPosT,"Condomínio")

	CASE nLin == nTopV + 28
		oExcel:Cell(nLin,nPosT,"IPTU",,nLisStyle)

	CASE nLin == nTopV + 29
		oExcel:Cell(nLin,nPosT,"Fornecedores")
		//oExcel:Cell(nLin,nPosV,0,cForn,nV2Style)
		//oExcel:Cell(nLin,nPosS,0,cSForn,nV2Style)
		oExcel:Cell(nLin,nPosV,0,"SUMIF(TIPOBK,&quot;=FOR&quot;,VALORES)",nV2Style)
		oExcel:Cell(nLin,nPosS,0,"SUMIF(TIPOBK,&quot;=FOR&quot;,SALDOS)",nV2Style)
		oExcel:Cell(nLin,nPosL,"FOR")

	CASE nLin == nTopV + 30
		oExcel:Cell(nLin,nPosT,"Consultoria  Jurídica / Contábil e Financeira",,nLisStyle)

	CASE nLin == nTopV + 31
		oExcel:Cell(nLin,nPosT,"Tarifas Bancárias")

	CASE nLin == nTopV + 32
		oExcel:Cell(nLin,nPosT,"Outras Despesas - Estrutura",,nLisStyle)

	CASE nLin == nTopV + 33
		oExcel:Cell(nLin,nPosT," ")

	CASE nLin == nTopV + 34
		oExcel:Cell(nLin,nPosT,"AMORTIZAÇÃO /JUROS EMPRÉSTIMOS/FINANCIAMENTOS",,nPosStyle)

	CASE nLin == nTopV + 35
		oExcel:Cell(nLin,nPosT," ")

	CASE nLin == nTopV + 36
		oExcel:Cell(nLin,nPosT,"IMPOSTOS",,nPosStyle)

	CASE nLin == nTopV + 37
		oExcel:Cell(nLin,nPosT,"PIS")

	CASE nLin == nTopV + 38
		oExcel:Cell(nLin,nPosT,"COFINS",,nLisStyle)

	CASE nLin == nTopV + 39 
		oExcel:Cell(nLin,nPosT,"Imposto de renda")

	CASE nLin == nTopV + 40
		oExcel:Cell(nLin,nPosT,"ISS",,nLisStyle)

	CASE nLin == nTopV + 41
		oExcel:Cell(nLin,nPosT,"4,65% ( CSSLL - COFINS - PIS )+TFF")

	CASE nLin == nTopV + 42
		oExcel:Cell(nLin,nPosT,"",,nLisStyle)

	CASE nLin == nTopV + 43
		oExcel:Cell(nLin,nPosT,"DESPESAS DIVERSAS",,nPosStyle)

	CASE nLin == nTopV + 44
		oExcel:Cell(nLin,nPosT,"Representantes",,nLisStyle)

	CASE nLin == nTopV + 45
		oExcel:Cell(nLin,nPosT,"Aportes Consórcios")

	CASE nLin == nTopV + 46
		oExcel:Cell(nLin,nPosT,"HF",,nLisStyle)

	CASE nLin == nTopV + 47
		oExcel:Cell(nLin,nPosT,"BK Telecom")

	CASE nLin == nTopV + 48
		oExcel:Cell(nLin,nPosT,"ESA",,nLisStyle)

	CASE nLin == nTopV + 49
		oExcel:Cell(nLin,nPosT,"Fundo Fixo")

	CASE nLin == nTopV + 50
		oExcel:Cell(nLin,nPosT,"Diretoria",,nLisStyle)

	//CASE nLin == nTopV + 51
	//	oExcel:Cell(nLin,nPosT,"")

	CASE nLin == nTopV + 52
		oExcel:AddNome("TOTAIS" ,nTopV+1,nPosV,nLin-1,nPosV)	
		oExcel:AddNome("TSALDOS",nTopV+1,nPosS,nLin-1,nPosS)	
		oExcel:Cell(nLin,nPosT,"Total",,nTotStyle)
		oExcel:Cell(nLin,nPosV,0,"SUM(TOTAIS)",nV2Style)
		//oExcel:Cell(nLin,nPosV,0,"SUM("+cPosV+ALLTRIM(STR(nTopV+1))+":"+cPosV+ALLTRIM(STR(nLin-1))+")",nV2Style)
		oExcel:Cell(nLin,nPosS,0,"SUM(TSALDOS)",nV2Style)
ENDCASE

Return NIL
