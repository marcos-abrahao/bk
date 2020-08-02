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

Private cTTipos 	:= ""

Private cTitulo     := "Planilha diária de Pagamentos"
Private cPerg       := "BKFINR25"

Private aParam		:=	{}
Private aRet		:=	{}

Private dDataI  	:= CTOD("")
Private dDataF  	:= CTOD("")
Private cCadGrp     := "Nao"
Private cAltPrd     := "Nao"

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

Private nPosT := 16
Private nPosV := 17
Private nPosS := 18
Private nPosL := 19

aAdd( aParam, { 1, "Data Inicial:" 	 , dDataBase	, "" , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Data Final:" 	 , dDataBase	, "" , "", ""	, "" , 70  , .F. })  
aAdd( aParam ,{ 2, "Cadastrar Grupos", "Nao"		, {"Nao", "Sim"}, 40,'.T.'  ,.T.})
aAdd( aParam ,{ 2, "Alterar Produtos", "Nao"		, {"Nao", "Sim"}, 40,'.T.'  ,.T.})

If !BkFR25()
   Return
EndIf

If Substr(cCadGrp,1,1) == "S"
	U_BKFINA26()
EndIf

aAdd(aTitulos,cPerg+"/"+TRIM(cUserName)+" - "+cTitulo)

aPlan2 := U_BKR25PL2()


For nI := 1 To Len(aPlan2)
	cTTipos += aPlan2[nI,3]+"/"
Next

aAdd(aFields,{"XX_FORNECE","E2_FORNECE"})
aAdd(aFields,{"XX_LOJA"   ,"E2_LOJA"})
aAdd(aFields,{"XX_NOMFOR" ,"E2_NOMFOR"})
nColNForn := Len(aFields)
aAdd(aFields,{"XX_PREFIXO","E2_PREFIXO"})
aAdd(aFields,{"XX_NUM"    ,"E2_NUM"})
aAdd(aFields,{"XX_PARCELA","E2_PARCELA"})
aAdd(aFields,{"XX_XXTIPBK","E2_XXTIPBK","","Tipo","@!","C",6,0})
nColTipo := Len(aFields)
aAdd(aFields,{"XX_PRODUTO","D1_COD","(cAliasTrb)->XX_PRODUTO"})
aAdd(aFields,{"XX_PORTADO","E2_PORTADO"})
aAdd(aFields,{"XX_FORMPGT" ,"","(cAliasTrb)->XX_FORMPGT","Forma pgto","@!","C",40,0})
//aAdd(aFields,{"XX_PRODUTO","D1_COD","(cAliasTrb)->XX_PRODUTO","Produto","@!","C",50,0})
aAdd(aFields,{"XX_DESC"   ,"B1_DESC","(cAliasTrb)->XX_DESC"})
aAdd(aFields,{"XX_VENCREA","E2_VENCREA"})
nColVenc := Len(aFields)
aAdd(aFields,{"XX_VALOR"  ,"E2_VALOR"})
nColValor := Len(aFields)
aAdd(aFields,{"XX_SALDO"  ,"E2_SALDO"})
nColVSaldo := Len(aFields)

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
	aAdd( aTamCol, nTamCol)
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
	cTitulo  := "Planilha Diária de Pagamentos - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
Endif
Return lRet


Static Function ProcBKR25
Local cQuery 	:= ""
Local nF 		:= 0
Local nValor 	:= 0
Local nSaldo 	:= 0
Local cTipoBk	:= ""
Local cFilF1	:= ""
Local cxTipoPg 	:= ""
Local cxNumPa 	:= ""
Local cFormaPgto := ""
Local cDadosBanc := ""

Private xCampo

cQuery := "SELECT "
For nF := 1 To Len(aFields)
	If LEN(aFields[nF]) < 3 .OR. Empty(aFields[nF,3])
		cQuery += aFields[nF,2]+","
	EndIf
Next
//For nF := 1 To Len(aOthers)
//	cQuery += aOthers[nF]+","
//Next
cQuery += "R_E_C_N_O_ AS E2RECNO"+ CRLF
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
cQuery += " ORDER BY E2_NUM"+ CRLF

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

	For nF := 1 To Len(aFields)
		If Len(aFields[nF]) > 2 .AND. !Empty(aFields[nF,3])
			xCampo := &(aFields[nF,3])
		Else
			xCampo := &(cAliasQry+"->"+aFields[nF,2])
			&(cAliasTrb+"->"+aFields[nF,1]) :=  xCampo
		EndIf

		If aFields[nF,2] = "E2_SALDO"
			nSaldo := SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,1,,dDataI-1,SE2->E2_LOJA,,0/*nTxMoeda*/)
			xCampo := nSaldo
        ElseIf aFields[nF,1] = "XX_FORMPGT"
            SE2->(dbGoTo((cAliasQry)->E2RECNO))
            dbSelectArea("SF1")                   // * Cabeçalho da N.F. de Compra
            dbSetOrder(1)
            If dbSeek(cFilF1+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA+"N")
                cxTipoPg := SF1->F1_XTIPOPG
                cxNumPa  := SF1->F1_XNUMPA
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
		EndIf
		&(cAliasTrb+"->"+aFields[nF,1]) :=  xCampo
	Next

	cTipoBk := TRIM((cAliasQry)->E2_XXTIPBK)

	If Empty(cTipoBk)
		If TRIM(SE2->E2_NATUREZ) == "IRF"
			cTipoBk := "IIRRF"
		ElseIf TRIM(SE2->E2_NATUREZ) == "INSS"
			cTipoBk := "INSS"
		ElseIf TRIM(SE2->E2_NATUREZ) == "ISS"
			cTipoBk := "ISS"
		ElseIf TRIM(SE2->E2_NATUREZ) $ "PIS/COFINS/CSLL"
			cTipoBk := "PCC"
		EndIf
		(cAliasTrb)->XX_XXTIPBK := cTipoBk
	EndIf

	If Empty(cTipoBk)

		SE2->(dbGoTo((cAliasQry)->E2RECNO))

	    dbSelectArea("SD1")                   // * Itens da N.F. de Compra
    	IF dbSeek(xFilial("SD1")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA)
			// Pega o primeiro produto
			cTipoBk := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_XXGRPF")
			(cAliasTrb)->XX_PRODUTO := TRIM(SD1->D1_COD)
			(cAliasTrb)->XX_DESC    := TRIM(Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC"))
			If aScan(aPrd,{|x| x[1] == SD1->D1_COD}) = 0
				aAdd(aPrd,{SD1->D1_COD,(cAliasTrb)->XX_DESC,cTipoBk})
			EndIf
		ENDIF

		If Empty(cTipoBk)
			cTipoBk := "FORN"
		EndIf
		
		(cAliasTrb)->XX_XXTIPBK := cTipoBk

	EndIf

	nValor  := (cAliasQry)->E2_VALOR

	
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

nPosStyle	:= oExcel:AddStyles(/*numFmtId*/,nPosFont/*fontId*/,nPosCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})
nLisStyle	:= oExcel:AddStyles(/*numFmtId*/,/*fontId*/,nLisCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,)

nV2Style	:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nD2Style	:= oExcel:AddStyles(14/*numFmtId*/,/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})
nG2Style 	:= oExcel:AddStyles(/*numFmtId*/,/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nT2Style	:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,nTotFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)

nTitStyle	:= oExcel:AddStyles(/*numFmtId*/,nTitFont/*fontId*/,/*fillId*/,/*borderId*/,/*xfId*/,{oAlCenter})
nApoStyle	:= oExcel:AddStyles(/*numFmtId*/,nApoFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nVApoStyle	:= oExcel:AddStyles(nFmtNum2/*numFmtId*/,nApoFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,)
nDApoStyle	:= oExcel:AddStyles(14/*numFmtId*/,nApoFont/*fontId*/,/*fillId*/,nBordas/*borderId*/,/*xfId*/,{oAlCenter})

nTotStyle	:= oExcel:AddStyles(/*numFmtId*/,nTotFont/*fontId*/,nLisCor/*fillId*/,nBordas/*borderId*/,/*xfId*/,)

nIDImg		:= oExcel:ADDImg("LGMID"+cEmpAnt+".PNG")	//Imagem no Protheus_data

oExcel:mergeCells(1,1,2,1)						//Mescla as células 

			  //nID,nLinha,nColuna,nX,nY,cUnidade,nRot
oExcel:Img(nIDImg,1,1,40,40,/*"px"*/,)

oExcel:Cell(1,2,"Pagamentos Diários - "+DTOC(dDataI),,nTitStyle)
oExcel:Cell(1,16,"Totalizadores",,nTitStyle)
oExcel:mergeCells(1,2,2,14)		//Mescla as células 
oExcel:mergeCells(1,16,2,19)

nLin := nTop
For nJ := 1 To Len(aCabs)
	oExcel:Cell(nLin,nJ,aCabs[nJ],,nPosStyle)
NEXT

// Cabeçalhos dos totalizadores
oExcel:Cell(nLin,nPosT,"DESPESAS",,nPosStyle)
oExcel:Cell(nLin,nPosV,"TOTAIS" ,,nPosStyle)
oExcel:Cell(nLin,nPosS,"SALDOS" ,,nPosStyle)
oExcel:Cell(nLin,nPosL,"SIGLAS" ,,nPosStyle)

oExcel:AddTamCol(1,1,10.45)
oExcel:AddTamCol(2,2,03.90)
oExcel:AddTamCol(3,3,25.00)
oExcel:AddTamCol(4,4,08.40)
oExcel:AddTamCol(5,5,10.30)
oExcel:AddTamCol(6,6,06.90)
oExcel:AddTamCol(7,7,06.60)
oExcel:AddTamCol(8,8,16.00)
oExcel:AddTamCol(9,9,10.00)
oExcel:AddTamCol(10,10,35.00)
oExcel:AddTamCol(11,11,30.00)
oExcel:AddTamCol(12,12,11.00)
oExcel:AddTamCol(13,13,13.50)
oExcel:AddTamCol(14,14,13.50)
oExcel:AddTamCol(15,15,05.00)
oExcel:AddTamCol(16,17,50.00)
oExcel:AddTamCol(17,17,13.50)
oExcel:AddTamCol(18,18,13.50)
oExcel:AddTamCol(19,19,22)

(cAliasTrb)->(dbgotop())

Do While (cAliasTrb)->(!eof()) 

	nLin++

	For nI :=1 to LEN(aCampos)

		xCampo := &(aCampos[nI])

		If ValType(xCampo) == "N"
			oExcel:Cell(nLin,nI,xCampo,,nV2Style)
		ElseIf ValType(xCampo) == "D"
			oExcel:Cell(nLin,nI,xCampo,,nD2Style)
		Else
			If "XXTIPBK" $ aCampos[nI] .AND. !( (TRIM(xCampo)+"/") $ cTTipos)
				oExcel:Cell(nLin,nI,xCampo,,nApoStyle)
			Else
				oExcel:Cell(nLin,nI,xCampo,,nG2Style)
			EndIf
		EndIf

	Next

	LPlan2(oExcel,nLin)

	(cAliasTrb)->(dbskip())
EndDo

aAports := {"BALSA NOVA","LIMEIRA","OSASCO","CAMPINAS","TABOÃO","BKTER HF","CORRETORA","","",""}
For nI := 1 To Len(aAports)
	nLin++
	oExcel:Cell(nLin,1 ,"",,nApoStyle)
	oExcel:Cell(nLin,2 ,"",,nApoStyle)
	oExcel:Cell(nLin,nColNForn,aAports[nI],,nApoStyle)
	oExcel:Cell(nLin,4 ,"",,nApoStyle)
	oExcel:Cell(nLin,5 ,"",,nApoStyle)
	oExcel:Cell(nLin,6 ,"",,nApoStyle)
	oExcel:Cell(nLin,nColTipo,IIF(!Empty(aAports[nI]),"APO",""),,nApoStyle)
	oExcel:Cell(nLin,8 ,"",,nApoStyle)
	oExcel:Cell(nLin,9 ,"",,nApoStyle)
	oExcel:Cell(nLin,10,"",,nApoStyle)
	oExcel:Cell(nLin,11 ,"",,nApoStyle)
	oExcel:Cell(nLin,nColVenc,dDataI,,nDApoStyle)
	oExcel:Cell(nLin,nColValor,0,,nVApoStyle)
	oExcel:Cell(nLin,nColVSaldo,0,,nVApoStyle)
	LPlan2(oExcel,nLin)
Next

oExcel:AddNome("TIPOBK" ,nTopV, nColTipo  ,nLin, nColTipo)
oExcel:AddNome("VALORES",nTopV, nColValor ,nLin, nColValor)	
oExcel:AddNome("SALDOS" ,nTopV, nColVSaldo,nLin, nColVSaldo)	

nLin++
oExcel:Cell(nLin,1,"Total",,nTotStyle)
oExcel:mergeCells(nLin,1,nLin,12)
oExcel:Cell(nLin,nColValor,0,"SUM(VALORES)",nT2Style)
oExcel:Cell(nLin,nColVSaldo,0,"SUM(SALDOS)",nT2Style)
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
		oExcel:Cell(nLin,nPosT,aPlan2[nL,2],,nPosStyle)
		//oExcel:Cell(nLin,nPosV,"",,nG2Style)
		//oExcel:Cell(nLin,nPosS,"",,nG2Style)
		//oExcel:Cell(nLin,nPosL,"",,nG2Style)
	Else

		//aAdd(aPlan2,.F,"Folha CLT","LPM/LAD/LAS/LFG/COM")
		If !Empty(aPlan2[nL,3])
			aTipos := StrTokArr(aPlan2[nL,3],"/")
			For nI := 1 To Len(aTipos)
				If nI > 1
					cFormula += "+"
				EndIf
				cFormula += "SUMIF(TIPOBK,&quot;="+aTipos[nI]+"&quot;,VALORES)"
			Next
		EndIf
		oExcel:Cell(nLin,nPosT,aPlan2[nL,2],,nStyle)
		oExcel:Cell(nLin,nPosV,0,cFormula,nV2Style)
		oExcel:Cell(nLin,nPosS,0,STRTRAN(cFormula,"VALORES","SALDOS"),nV2Style)
		oExcel:Cell(nLin,nPosL,aPlan2[nL,3],,nG2Style)
	EndIf
ElseIf nL == Len(aPlan2)
	oExcel:AddNome("TOTAIS" ,nTopV,nPosV,nLin-1,nPosV)	
	oExcel:AddNome("TSALDOS",nTopV,nPosS,nLin-1,nPosS)	
	oExcel:Cell(nLin,nPosT,"Total",,nTotStyle)
	oExcel:Cell(nLin,nPosV,0,"SUM(TOTAIS)",nT2Style)
	//oExcel:Cell(nLin,nPosV,0,"SUM("+cPosV+ALLTRIM(STR(nTopV+1))+":"+cPosV+ALLTRIM(STR(nLin-1))+")",nV2Style)
	oExcel:Cell(nLin,nPosS,0,"SUM(TSALDOS)",nT2Style)
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
aAdd(aPlan,{.F.,"Folha CLT","LPM/LAD/LAS/LFG/COM"})
aAdd(aPlan,{.F.,"Férias","LFE"})
aAdd(aPlan,{.F.,"13º Salário","LD1/LD2"})
aAdd(aPlan,{.F.,"Rescisões + MFG","MFG/LRC"})
aAdd(aPlan,{.F.,"Pensão ALimentícia","PEN"})
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
aAdd(aPlan,{.F.,"",""})
aAdd(aPlan,{.F.,"Total",""})
Return aPlan

