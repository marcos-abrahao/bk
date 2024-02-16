#Include "FINR470.CH"
#include "PROTHEUS.CH"
#DEFINE REC_NAO_CONCILIADO	1
#DEFINE REC_CONCILIADO		2
#DEFINE PAG_NAO_CONCILIADO	3
#DEFINE PAG_CONCILIADO		4

Static lFWCodFil   := .T.
Static cSM0Leiaute := ALLTRIM(FWSM0Layout())
Static lGestao     := ('E' $ cSM0Leiaute .or. 'U' $ cSM0Leiaute)
Static cHistSE5    := ""
Static cCCusto     := "" // BK
Static cDocument   := ""
Static cPref_Tit   := ""
Static cDataDisp   := ""
Static __lMVPAR12  := .F.
//----------------------------------------------------------------
/*/{Protheus.doc}FINR_470
Extrato Bancário - Com CC - BK	

@author Marcos Abrahão
@since  08/02/2024

@author Adrianne Furtado 
@since  10/08/06
@version 12

@todo
M.Camargo 29/07/14 Se modIfica línea 29 para usar mv_par10
solo para brasil.

Jose Glez 29/05/17 Se reajusta el orden para el informe 
FINR470 por RECNO.  
/*/
//-----------------------------------------------------------------
User Function FINR_470()
	Local lExec		:= .T.

	/*
	VerIfica se o ambiente esta configurada para as rotina de "modelo II" */
	If cPaisLoc == "ARG"
		lExec := FinModProc()
	Else
		lExec := .T.
	EndIf
	If lExec
		
		//Interface de impressao                          
		oReport := ReportDef()
		If !Empty(oReport:uParam) .AND. !isblind()
			Pergunte(oReport:uParam,.F.)
		EndIf
		oReport:PrintDialog()
	EndIf

Return

//----------------------------------------------------------------
/*/{Protheus.doc}ReportDef
A funcao estatica ReportDef devera ser criada para todos os
relatorios que poderao ser agendados pelo usuario.  

@author Adrianne Furtado 
@since  10/08/06
@version 12

@return Objeto do relatório  
/*/
//-----------------------------------------------------------------
Static Function ReportDef()
	Local oReport   := Nil
	Local oBanco    := Nil
	Local oMovBanc  := Nil
	Local nTamChave := TamSX3("E5_PREFIXO")[1]+TamSX3("E5_NUMERO")[1]+TamSX3("E5_PARCELA")[1] + 3
	Local nTamValor := TamSX3("E5_VALOR")[1]

	Pergunte("FIN470",.F.)
	
	oReport := TReport():New("FINR470",STR0004,"FIN470", {|oReport| ReportPrint(oReport)},STR0001+" "+STR0002+" "+STR0003)
	oReport:SetUseGC(.f.)

	oBanco := TRSection():New(oReport, STR0035, {"SA6"}, Nil /*[Ordem]*/)
	TRCell():New(oBanco, "A6_COD",     "SA6", STR0008, Nil, 23, .F.)
	TRCell():New(oBanco, "A6_AGENCIA", "SA6", STR0009)
	TRCell():New(oBanco, "A6_NUMCON",  "SA6", STR0010)
	TRCell():New(oBanco, "SALDOINI",    Nil,  STR0034, Nil, 20, Nil,)
	
	oMovBanc := TRSection():New(oBanco, STR0036, {"SE5"})
	
	TRCell():New(oMovBanc, "E5_DTDISPO",      "SE5", STR0025, Nil/*Picture*/, Nil, Nil/*lPixel*/, {|| cDataDisp },,,,, 2 , .F.)
	TRCell():New(oMovBanc, "E5_HISTOR",       "SE5", STR0026, Nil, 40, Nil, {|| cHistSE5 },, .T.)
	TRCell():New(oMovBanc, "E5_NUMCHEQ",      "SE5", STR0027, Nil, Nil, Nil, {|| cDocument })
	TRCell():New(oMovBanc, "PREFIXO/TITULO",  "SE5", STR0028, Nil, nTamChave, Nil, {|| cPref_Tit })	
	TRCell():New(oMovBanc, "CENTRO DE CUSTOS","SE5", "CCUSTO",Nil, 09, Nil, {|| cCCusto })	 // BK
	TRCell():New(oMovBanc, "E5_VALOR-ENTRAD", "SE5", STR0029, Nil, nTamValor)
	TRCell():New(oMovBanc, "E5_VALOR-SAIDA",  "SE5", STR0030, Nil, nTamValor)
	TRCell():New(oMovBanc, "SALDO ATUAL",     "SE5", STR0031, Nil, nTamValor, Nil, {||nSaldoAtu})
	If cPaisLoc <> "BRA"
		TRCell():New(oMovBanc, "TAXA",         Nil , STR0037, Nil, 12)
	EndIf
	TRCell():New(oMovBanc, "x-CONCILIADOS",   "SE5", STR0016, Nil, 3)	
	oMovBanc:SetAutoSize(.T.)

	oTotal := TRSection():New(oMovBanc, STR0032, {"SE5"}, Nil/*[Ordem]*/)

	TRCell():New(oTotal, "DESCRICAO", Nil, STR0033, Nil, 30, Nil, Nil)
	TRCell():New(oTotal, "NAOCONC",   Nil, STR0015, Nil, 20, Nil, Nil)
	TRCell():New(oTotal, "CONC",      Nil, STR0016, Nil, 20, Nil, Nil)
	TRCell():New(oTotal, "TOTAL",     Nil, STR0017, Nil, 20, Nil, Nil)
	oTotal:SetLeftMargin(35)
Return(oReport)

//----------------------------------------------------------------
/*/{Protheus.doc}ReportPrint
A funcao estatica ReportDef devera ser criada para todos os
relatorios que poderao ser agendados pelo usuario.  

@author Adrianne Furtado 
@since  27/06/06
@version 12
@param oReport Objeto do TReport

@return NIL
/*/
//-----------------------------------------------------------------
Static Function ReportPrint(oReport)
	Local oBanco	 := oReport:Section(1)
	Local oMovBanc	 := oReport:Section(1):Section(1)
	Local oTotal	 := oReport:Section(1):Section(1):Section(1)
	Local cAlias     := ""
	Local lAllFil	 := .F.
	Local cAliasSA6	 := "SA6"
	Local cAliasSE5	 := "SE5"
	Local cSql1		 := " "
	Local nMoeda	 := GetMv("MV_CENT"+(IIf(mv_par06 > 1 , Alltrim(STR(mv_par06)),"")))             
	Local lSpbInUse	 := SpbInUse()
	Local nSaldoAtu	 := 0
	Local cTabela14	 := ""
	Local aRecon 	 := {}
	Local nLimCred	 := 0
	Local aTotais    := {}
	Local nLinReport := 8
	Local nLinPag	 := MV_PAR08
	Local cExpMda	 := ""
	Local nCont 	 := 0
	Local cCampos 	 := ""
	Local lMultSld   := FXMultSld()
	Local lMsmMoeda  := .F.
	Local cFilSE5    := IIf(lGestao, FwFilial("SE5"), xFilial("SE5"))
	Local cFilSE8    := IIf(lGestao, FWFilial("SE8"), xFilial("SE8"))
	Local nSaldoIni	 :=0
	Local lDvc		 := oReport:nDevice == 4
	Local nx         :=0
	Local cOrder     := ""
	Local lTitulo    := .T.
	Local nCasDecE2  := TamSx3("E2_TXMOEDA")[2]
	Local nCasDecE1  := TamSx3("E1_TXMOEDA")[2]
	Local nCasDec    := TamSx3("E5_TXMOEDA")[2]
	Local cTbl       := ""
	Local nMoedaBx   := 1
	Local nTaxaMovi  := 0
	Local nMoedaTit  := 0
	Local dDataMovi  := 0
	Local nTaxaDest  := 0
	Local nValorMov  := 0
	Local nValorPag  := 0
	Local nValorRec  := 0
	Local nI 		 := 1
	Local nTxContr   := 0	
	Local nTxMov     := 0
	Local nFiliais	 := 0
	Local lTemTxCr   := .F.
	Local lTxMov     := .F.
	Local dDtConvSLD := dDataBase
	Local oFwSX1Util := Nil
	Local aPergunte	 := {}
	Local aFiliais	 := {}
	Local aSelFil	 := {}
	Local lVldUnNeg  := lGestao
	Local lTudoComp  := .F.
	Local nTamEmp    := 0
	Local nTamUni    := 0
	Local cMAEmpSA6  := ""
	Local cMAUniSA6  := ""
	Local cMAFilSA6  := ""
	Local lTemPar11  := .F.
	Local lFieldLGI := Ascan(oMovBanc:ACell,{|a|a:CNAME == "E5_USERLGI"}) > 0	
	Local lFieldLGA := Ascan(oMovBanc:ACell,{|a|a:CNAME == "E5_USERLGA"}) > 0
	Local cChave    := ""	// BK
	Private nTxMoedBc := 0
	Private nMoedaBco := 1
	
	AAdd(aRecon, {0,0,0,0} )
	
	If (Empty(mv_par08) .Or. MV_PAR08 > 89) 
		nLinPag := 89
	EndIf

	If !__lMVPAR12
		oFwSX1Util := FwSX1Util():New()

		//Valida se ambiente está atualizado e possuí o MV_PAR10
		oFwSX1Util:AddGroup("FIN470")
		oFwSX1Util:SearchGroup()
		aPergunte := oFwSX1Util:GetGroup("FIN470")

		If Len(aPergunte) > 1 .And. Len(aPergunte[2]) >= 12 .And. Upper(AllTrim(aPergunte[2][12]:CX1_VAR01)) == "MV_PAR12"
			__lMVPAR12 := .T.
		EndIf

		FwFreeArray(aPergunte)
		FwFreeObj(oFwSX1Util)
		aPergunte := Nil
	EndIf
	
	dbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	
	If !SA6->(dbSeek(cFilial+mv_par01+mv_par02+mv_par03))
		Help(" ", 1, "BCONOEXIST")
		Return
	EndIf
	
	nMoedaBco := nMoedaBx := Max(SA6->A6_MOEDA, 1)	
	cTabela14 := FR470Tab14()
	
	dbSelectArea("SE8")
	SE8->(DbSetOrder(1))
	SE8->(dbSeek(xFilial("SE8")+mv_par01+mv_par02+mv_par03+Dtos(mv_par04),.T.))
	SE8->(DbSkip(-1))
	
	If ((cPaisLoc == "BRA" .And. mv_par10 == 2) .Or. cPaisLoc != "BRA") .And. FWModeAccess("SA6",3,) == 'C' .and. FWModeAccess("SE8",3,) == 'E'
		CalcSldIni(@nSaldoAtu, @nSaldoIni)
	Else	
		If (SE8->E8_FILIAL != xFilial("SE8") .Or. SE8->E8_BANCO != mv_par01 .Or. SE8->E8_AGENCIA != mv_par02 .Or. SE8->E8_CONTA != mv_par03 .Or. SE8->(BOF()) .Or. SE8->(EOF()))
			nSaldoAtu := 0
		Else 

			dDtConvSLD := F470DtSld()
			If mv_par07 == 1
				nSaldoAtu := Round(xMoeda(E8_SALATUA, nMoedaBco, mv_par06, IIf(cPaisLoc <> "BRA" .And. mv_par09 == 1, dDataBase, dDtConvSLD),nCasDec), nMoeda)
			ElseIf mv_par07 == 2
				nSaldoAtu := Round(xMoeda(E8_SALRECO, nMoedaBco, mv_par06, IIf(cPaisLoc <> "BRA" .And. mv_par09 == 1, dDataBase, dDtConvSLD),nCasDec), nMoeda)
			ElseIf mv_par07 == 3
				nSaldoAtu := Round(xMoeda(E8_SALATUA-E8_SALRECO, nMoedaBco, mv_par06, IIf(cPaisLoc <> "BRA" .And. mv_par09 == 1, dDataBase, dDtConvSLD),nCasDec), nMoeda)
			EndIf
		EndIf
		
		nSaldoIni := nSaldoAtu
	EndIf
	
	If ExistBlock("F470ALLF")
		lAllFil := ExecBlock("F470ALLF",.F.,.F.,{lAllFil})
	Else
		lTemPar11 := (Type("mv_par11") <> "U" .And. ValType(mv_par11) == "N")
		lAllFil   := IIf(lTemPar11, mv_par11 == 1, lAllFil) //.T. se for todas as filiais
	EndIf
	
	cAlias := GetNextAlias()
	MakeSqlExpr(oReport:uParam)
	oBanco:BeginQuery()
	cOrder := "%E5_DTDISPO,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_NUMCHEQ,E5_DOCUMEN,SE5.R_E_C_N_O_,E5_PREFIXO,E5_NUMERO%" 
	
	If !lAllFil 
		cSql1 := "E5_FILIAL = '" + xFilial("SE5") + "'" + " AND "   
		If Empty(cFilSE5) .and. !Empty(cFilSE8)
			cSql1 += "E5_FILORIG = '" + xFilial("SE8") + "'" + " AND "
		EndIf
	Else
		If lTemPar11 .And. MV_PAR11 == 1
			lVldUnNeg := .F.
			cMAEmpSA6 := AllTrim(FWModeAccess("SA6",1))
			cMAUniSA6 := AllTrim(FWModeAccess("SA6",2))
			cMAFilSA6 := AllTrim(FWModeAccess("SA6",3))
			nTamEmp   := Len(FwSM0Layout(,1))
			nTamUni   := Len(FwSM0Layout(,2))
			
			If (nTamEmp+nTamUni) == 0
				cMAEmpSA6 := cMAUniSA6 := cMAFilSA6
			Else
				If nTamEmp == 0
					cMAEmpSA6 := cMAUniSA6
				ElseIf nTamUni == 0 
					cMAUniSA6 := cMAFilSA6
				EndIf 
			EndIf			
			
			lTudoComp := ((cMAEmpSA6+cMAUniSA6+cMAFilSA6) == "CCC")
			
			If nTamUni > 0 .And. !lTudoComp 
				lVldUnNeg := (cMAUniSA6 == "E")
			EndIf
		EndIf
		
		aFiliais := AdmGetFil(.F., lGestao, "SA6", lVldUnNeg, Nil, .F., lTudoComp) //AdmGetFil sem exibir tela traz infos alem do codigo da filial
		nFiliais := Len(aFiliais)
		
		For nI := 1 to nFiliais
			Aadd(aSelFil,aFiliais[nI,1])	// Extrai apenas o codigo da filial
		Next nI
		
		cSql1 += FinSelFil(aSelFil, "SE5", .F., .F.) + " AND "
	EndIf

	If lSpbInUse
		cSql1	+=	" E5_DTDISPO >=  '" + DTOS(mv_par04) + "' AND"
		cSql1	+=	" ((E5_DTDISPO <= '"+ DTOS(mv_par05) + "') OR "
		cSql1	+=	"  (E5_DTDISPO >= '"+ DTOS(mv_par05) + "' AND "
		cSql1	+=	"  (E5_DATA    >= '"+ DTOS(mv_par04) + "' AND "
		cSql1	+=	"   E5_DATA    <= '"+ DTOS(mv_par05) + "'))) AND"
	Else
		cSql1	+=	" E5_DTDISPO >= '" + DTOS(mv_par04) + "' AND"
		cSql1	+=	" E5_DTDISPO <= '" + DTOS(mv_par05) + "' AND"
	EndIf

	cSql1 += " (NOT (E5_TIPODOC = 'PA ' AND E5_ORIGEM = 'FINA090' AND E5_NUMCHEQ <> ' ')) AND "

	If mv_par07 == 2
		cSql1	+=	" E5_RECONC <> ' ' AND "
	ElseIf mv_par07 == 3
		cSql1	+=	" E5_RECONC = ' ' AND "
	EndIf
	
	cSql1   := "%" + cSql1 + "%"
	cCampos := "E5_FILIAL,E5_DTDISPO,E5_HISTOR,E5_NUMCHEQ,E5_DOCUMEN,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_TIPODOC,E5_FILORIG,E5_DATA,"
	cCampos += "E5_RECPAG,E5_VALOR,E5_MOEDA,E5_VLMOED2,E5_CLIFOR,E5_LOJA,E5_RECONC,E5_TIPO,E5_SEQ,E5_BANCO,E5_AGENCIA,E5_CONTA,"
	cCampos += "A6_FILIAL,A6_COD,A6_NREDUZ,A6_AGENCIA,A6_NUMCON,A6_LIMCRED,E5_TXMOEDA,E5_ORIGEM,E5_MOTBX"
	
	cCampos += ",E5_CCD,E5_CCC" // BK
	
	If lFieldLGI
		cCampos += ",E5_USERLGI"
	EndIf	
	
	If lFieldLGA
		cCampos += ",E5_USERLGA"
	EndIf

	cCampos := "%" + cCampos + "%"
	
	if cPaisLoc != "BRA" 
		cExpMda	:= "%E5_MOEDA NOT IN " + FormatIn(cTabela14+"/DO","/") + "%"
	else 	
		cExpMda	:= "%E5_MOEDA NOT IN " + FormatIn(cTabela14,"/") + "%"
	endif 
	
	BeginSql Alias cAlias
		SELECT	%Exp:cCampos%
		FROM 	%table:SE5% SE5
		LEFT JOIN %table:SA6% SA6 ON (E5_BANCO = A6_COD AND E5_AGENCIA = A6_AGENCIA AND E5_CONTA = A6_NUMCON)
		WHERE 	%Exp:cSql1%
		A6_FILIAL = %xFilial:SA6% AND E5_BANCO = %Exp:mv_par01% AND E5_AGENCIA = %Exp:mv_par02% AND E5_CONTA = %Exp:mv_par03% AND
		E5_TIPODOC NOT IN ('DC','JR','MT','CM','D2','J2','M2','V2','C2','CP','TL','BA','I2','EI','VA') AND (E5_TIPODOC <> 'VL' OR E5_TIPO <> 'VP') AND
		NOT (E5_TIPODOC = 'ES' AND E5_RECPAG = 'P' AND E5_MOTBX = 'CMP') AND 
		NOT (E5_MOEDA IN ('C1','C2','C3','C4','C5','CH') AND E5_NUMCHEQ = '               ' AND (E5_TIPODOC NOT IN('TR','TE'))) AND
		NOT (E5_TIPODOC IN ('TR','TE') AND ((E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ') OR (E5_DOCUMEN BETWEEN '*                ' AND '*ZZZZZZZZZZZZZZZZ' ))) AND
		NOT (E5_TIPODOC IN ('TR','TE') AND E5_NUMERO = '      ' AND %Exp:cExpMda% ) AND
		E5_VALOR <> 0 AND E5_SITUACA <> 'C' AND NOT (E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ') AND SE5.%notDel% AND SA6.%notDel%
		ORDER BY %exp:cOrder%
	EndSql
	
	oBanco:EndQuery()
	oMovBanc:SetParentQuery()
	cAliasSA6 := cAlias
	cAliasSE5 := cAlias
	cMoeda    := Upper(GetMv("MV_MOEDA"+LTrim(Str(mv_par06))))
	nTxMoeda  := nTxMoedBc
	
	If nTxMoedBc <= 1
		nTxMoeda := RecMoeda( iIf(MV_PAR09 == 1, dDataBase, (cAliasSE5)->E5_DTDISPO), IIf(cPaisLoc <> "BRA" .And. nMoedaBco > 1, nMoedaBco, mv_par06))
	EndIf
	
	If alltrim(oReport:title()) == Alltrim(STR0004)
		oReport:SetTitle(OemToAnsi(STR0007 + " " + DTOC(mv_par04) + STR0040 + Dtoc(mv_par05) + STR0039 + cMoeda))
	EndIf
	
	oMovBanc:Cell("E5_VALOR-ENTRAD"	):SetPicture(tm(E5_VALOR, 20, nMoeda))
	oMovBanc:Cell("E5_VALOR-SAIDA"	):SetPicture(tm(E5_VALOR, 20, nMoeda))
	If cPaisLoc <> "BRA"
		oMovBanc:Cell("TAXA"	    ):SetPicture(tm(E5_VALOR, 12, nMoeda))
	EndIf
	oMovBanc:Cell("SALDO ATUAL"		):SetPicture(tm(E5_VALOR, 20, nMoeda))

	If lMultSld .And. !Empty((cAliasSE5)->E5_TXMOEDA)
		If (cAliasSE5)->E5_RECPAG == "P"
			lMsmMoeda := Posicione("SE2", 1, xFilial("SE2")+(cAliasSE5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO), "E2_MOEDA") == mv_par06
		Else
			lMsmMoeda := Posicione("SE1", 1, xFilial("SE1")+(cAliasSE5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO), "E1_MOEDA") == mv_par06
		EndIf
	EndIf
	
	nValorPag := 0
	nValorRec := 0
	oMovBanc:Cell("SALDO ATUAL"	   ):SetBlock({|| nSaldoAtu += (nValorMov * If((cAliasSE5)->E5_RECPAG == 'R', 1, -1))})
	oMovBanc:Cell("E5_VALOR-ENTRAD"):SetBlock({||nValorRec})			 
	oMovBanc:Cell("E5_VALOR-SAIDA" ):SetBlock({||nValorPag})
	oMovBanc:Cell("E5_VALOR-ENTRAD"):SetHeaderAlign("RIGHT")
	oMovBanc:Cell("E5_VALOR-SAIDA" ):SetHeaderAlign("RIGHT")
	oMovBanc:Cell("SALDO ATUAL"    ):SetHeaderAlign("RIGHT")
	If cPaisLoc <> "BRA"
		oMovBanc:Cell("TAXA"       ):SetHeaderAlign("CENTER")
	EndIf
	oMovBanc:Cell("x-CONCILIADOS"  ):SetBlock({|| IIf(Empty((cAliasSE5)->E5_RECONC), " ", "x")})
	oMovBanc:Cell("x-CONCILIADOS"  ):SetTitle("")
	
	If lFieldLGI
		oMovBanc:Cell("E5_USERLGI"    ):SetBlock({|| R470Lgi(cAliasSE5, "E5_USERLGI")})
		oMovBanc:Cell("E5_USERLGI"    ):SetTitle(STR0049) //"USR. INC."
	EndIf	

	If lFieldLGA
		oMovBanc:Cell("E5_USERLGA"    ):SetBlock({|| R470Lgi(cAliasSE5, "E5_USERLGA")})
		oMovBanc:Cell("E5_USERLGA"    ):SetTitle(STR0050) //"USR. ALT."
	EndIf	
	
	If cPaisLoc <> "BRA"
		If cPaisLoc <> "ANG"
			If mv_par06 <> nMoedaBco .And. mv_par06 > 1
				oMovBanc:Cell("TAXA"):SetBlock({||If(nTxMoedBc > 1, nTxMoedBc, RecMoeda(iIf(MV_PAR09 == 1, dDataBase, (cAliasSE5)->E5_DTDISPO), mv_par06))})
			Else
				oMovBanc:Cell("TAXA"):Disable()
			EndIf
		Else
			If mv_par06 <> nMoedaBco
				If nMoedaBco>1
					oMovBanc:Cell("TAXA"):SetBlock({||If(nTxMoedBc > 1, nTxMoedBc, RecMoeda((cAliasSE5)->E5_DTDISPO, nMoedaBco))})
				Else
					oMovBanc:Cell("TAXA"):SetBlock({||If(nTxMoedBc > 1, nTxMoedBc, IIf(!lMsmMoeda, RecMoeda((cAliasSE5)->E5_DTDISPO, mv_par06), (cAliasSE5)->E5_TXMOEDA))})
				EndIf
			Else
				oMovBanc:Cell("TAXA"):Disable()
			EndIf
		EndIf
	EndIf

	oBanco:SetLineStyle()

	If cPaisLoc == "BRA"
		If (cAliasSA6)->(A6_LIMCRED) == 0 .And. !Empty(SA6->A6_LIMCRED)		
			nLimCred := SA6->A6_LIMCRED		
		Else
			nLimCred := (cAliasSA6)->(A6_LIMCRED)
		EndIf
	Else
		If SA6->A6_MOEDA <> 1 .and. SA6->A6_MOEDA == mv_par06
			nLimCred := (cAliasSA6)->(A6_LIMCRED)
		Else
			nLimCred := xMoeda((cAliasSA6)->A6_LIMCRED,SA6->A6_MOEDA,1,dDataBase)
		EndIf
	EndIf
	
	oBanco:Init()
	oBanco:Cell("SALDOINI"):SetBlock( { || Transform(nSaldoIni,tm(nSaldoIni,16,nMoeda)) } )
	oBanco:Cell("SALDOINI"):SetHeaderAlign("RIGHT")
	oMovBanc:OnPrintLine( {|| F470LinPag(nLinPag, @nLinReport)})

	(cAliasSE5)->(dbEval({|| nCont++}))
	(cAliasSE5)->(dbGoTop())
	
	If (cAliasSE5)->(Eof())
		oReport:OnPageBreak( { || F470LinPag( nLinPag, @nLinReport,.T.) } )
		oBanco:Cell("A6_COD"):SetBlock( {|| SA6->A6_COD +" - "+AllTrim(SA6->A6_NREDUZ)} )
		oBanco:Cell("A6_AGENCIA"):SetBlock( {|| SA6->A6_AGENCIA } )
		oBanco:Cell("A6_NUMCON"):SetBlock( {|| SA6->A6_NUMCON } )
		oBanco:PrintLine()
		oMovBanc:Init()
		oMovBanc:PrintLine()
		oMovBanc:Finish()	
	Else
		oBanco:Cell("A6_COD"):SetBlock( {|| (cAliasSA6)->A6_COD +" - "+AllTrim((cAliasSA6)->A6_NREDUZ)} )
		oReport:OnPageBreak( { || oBanco:PrintLine(), F470LinPag( nLinPag, @nLinReport,.T.) } )
	EndIf
	
	oReport:SetMeter(nCont)
	
	While !oReport:Cancel() .And. (cAliasSE5)->(!Eof())
		If (oReport:Cancel() .Or. oBanco:Cancel())
			Exit
		EndIf
		
		oMovBanc:Init()
		
		While !oReport:Cancel() .And. !(cAliasSE5)->(Eof())
			nTaxaMovi := 0
			nMoedaTit := 0
			dDataMovi := 0
			nTaxaDest := 0
			nValorMov := 0
			nValorPag := 0
			nValorRec := 0
			nTxContr  := 0
			cDocument := ""
			cHistSE5  := ""
			cPref_Tit := ""
			cCCusto   := "" // BK
			lTitulo   := .F. // BK
			
			If oReport:Cancel()
				Exit
			EndIf
			
			oReport:IncMeter()
			
			If (cAliasSE5)->E5_MOEDA == "TC" .And. cPaisLoc == "MEX"
				(cAliasSE5)->(DbSkip())
				Loop
			EndIf
			
			If (cAliasSE5)->E5_TIPODOC == "ES"
				SE5->(DbSetOrder(7))
				
				If SE5->(DbSeek((cAliasSE5)->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ))) .And. SE5->E5_TIPODOC == "V2"
					(cAliasSE5)->(dbSkip())
					Loop
				EndIf
			EndIf
			
			nValorMov := (cAliasSE5)->E5_VALOR

			//---> BK
			cTbl      := "SE1"
			If (cAliasSE5)->E5_TIPO $ MVPAGANT .Or.;
				( !(cAliasSE5)->E5_TIPO $ MVRECANT+"|"+MV_CRNEG .And.;
				((cAliasSE5)->E5_RECPAG == "P" .And. (cAliasSE5)->E5_TIPODOC != "ES") .Or.;
				((cAliasSE5)->E5_RECPAG == "R" .And. (cAliasSE5)->E5_TIPODOC == "ES") )
				cTbl     := "SE2"
			EndIf

			If cTbl == "SE1"
				(cTbl)->(DbSetOrder(1))
				lTitulo := (cTbl)->(MsSeek(xFilial(cTbl, (cAliasSE5)->E5_FILORIG) + (cAliasSE5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)))
				If lTitulo
					If !Empty(SE1->E1_PEDIDO)
						cCCusto := Posicione("SC5",1,xFilial("SC5")+SE1->E1_PEDIDO,"C5_MDCONTR")
						If Empty(cCCusto)
							cCCusto := Posicione("SC5",1,xFilial("SC5")+SE1->E1_PEDIDO,"C5_ESPECI1")
						EndIf
						//If Empty(cCCusto)
						//	cCCusto := SE1->E1_PEDIDO
						//EndIf
					EndIf
				EndIf
			Else
				(cTbl)->(DbSetOrder(1))
				lTitulo := (cTbl)->(MsSeek(xFilial(cTbl, (cAliasSE5)->E5_FILORIG) + (cAliasSE5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)))
				If lTitulo
					SD1->(dbSetOrder(1))
					cChave := (cAliasSE5)->(E5_NUMERO+E5_PREFIXO+E5_CLIFOR+E5_LOJA)
					If SD1->(MsSeek(xFilial("SD1")+cChave,.T.))
				    	Do While SD1->(!EOF()) .AND. xFilial("SD1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == xFilial("SD1")+cChave
							If Empty(cCCusto)
								cCCusto := SD1->D1_CC
							ElseIf cCCusto <> SD1->D1_CC
								cCCusto := "DIVERSOS"
							EndIf
							SD1->(dbSkip())
						EndDo
					EndIf
				EndIf
			EndIf

			If !lTitulo .OR. Empty(cCCusto)
				If !Empty((cAliasSE5)->E5_CCD)
					cCCusto := (cAliasSE5)->E5_CCD
				Else
					cCCusto := (cAliasSE5)->E5_CCC
				EndIf
			EndIf

			//<---- BK

			//Converte o valor quando o relatorio for parametrizado c/ uma moeda dIferente a da movimentacao bancaria
			If nMoedaBx > 0 .And. nMoedaBx != mv_par06 .And. !Empty((cAliasSE5)->E5_RECPAG) .And. !Empty((cAliasSE5)->E5_MOEDA)
				
				dDataMovi := If(MV_PAR09 == 2, (cAliasSE5)->E5_DATA, dDataBase)
				nCasDec   := nCasDecE1
				cTbl      := "SE1"
				nTxMov    := If((cAliasSE5)->E5_TXMOEDA != 1, (cAliasSE5)->E5_TXMOEDA, 0) //Trata gravacao incorreta do E5_TXMOEDA
				
				If (cAliasSE5)->E5_TIPO $ MVPAGANT .Or.;
				( !(cAliasSE5)->E5_TIPO $ MVRECANT+"|"+MV_CRNEG .And.;
				((cAliasSE5)->E5_RECPAG == "P" .And. (cAliasSE5)->E5_TIPODOC != "ES") .Or.;
				((cAliasSE5)->E5_RECPAG == "R" .And. (cAliasSE5)->E5_TIPODOC == "ES") )
					cTbl     := "SE2"
					nCasDec  := nCasDecE2
				EndIf

				//Encontra a moeda do titulo
				(cTbl)->(DbSetOrder(1))
				lTitulo := (cTbl)->(MsSeek(xFilial(cTbl, (cAliasSE5)->E5_FILORIG) + (cAliasSE5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)))
				If lTitulo
					nMoedaTit := If(cTbl == "SE1", SE1->E1_MOEDA, SE2->E2_MOEDA)
					nTxContr  := If(cTbl == "SE1", SE1->E1_TXMOEDA, SE2->E2_TXMOEDA)
				EndIf

				If mv_par09 == 1  // Taxa do dia
					//Converte valor pela taxa do dia (SM2 pela database)
					If mv_par06 > 1 .and. nMoedaBx > 1 
						//Para conversao entre moedas estrangeiras, considerar o E5_TXMOEDA como partida e o SM2 como taxa de destino
						nTaxaMovi := nTxMov 
						nTaxaDest := RecMoeda(dDataMovi, mv_par06) 
					Else
						nTaxaMovi := RecMoeda(dDataMovi, If(nMoedaBx>1,nMoedaBx,mv_par06))
					EndIf
				Else // Taxa do Movimento
					nTaxaMovi := nTxMov
					
					//Converte valor pela taxa do movimento (E5_TXMOEDA). Obs: ou taxa do dia (SM2 pela data da baixa) quando E5_TXMOEDA nao tiver relacao com a moeda do relatorio
					If mv_par06 > 1						
						If !lTitulo .And. nTxMov > 0
							nTaxaMovi := 0
							nTaxaDest := nTxMov
						Else//Exibir valores em moeda estrangeira
							lTemTxCr  := mv_par06 == nMoedaTit .and. nTxContr > 0 //VerIfica se deve considerar a taxa contratada do titulo
							lTxMov    := mv_par06 == nMoedaTit //VerIfica se deve considerar a taxa do movimento bancário (E5_TXMOEDA) como taxa destino
							nTaxaMovi := If(nMoedaBx > 1, nTxMov, 0) //Para conversao entre duas moedas estrangeiras, considerar o E5_TXMOEDA como taxa de partida
							nTaxaDest := If(nMoedaBx > 1, If(lTemTxCr, nTxContr, RecMoeda(dDataMovi, mv_par06)), If(lTxMov, nTxMov, RecMoeda(dDataMovi, mv_par06)))
						EndIf
					EndIf
				EndIf
			EndIf
			If lTitulo .AND. mv_par06 == nMoedaTit .AND. nMoedaBx > 1 .AND. nMoedaTit > 1 .AND. mv_par09 == 2 // Taxa do Movimento
				nValorMov := (cAliasSE5)->E5_VLMOED2
			Else
				nValorMov  := Round(xMoeda(nValorMov, nMoedaBx, mv_par06, dDataMovi, nCasDec, nTaxaMovi, nTaxaDest), 2)
			EndIf			

			If (cAliasSE5)->E5_RECPAG == "R"
				nValorRec := nValorMov
				
				If Empty((cAliasSE5)->E5_RECONC)
					aRecon[1][REC_NAO_CONCILIADO] += nValorRec
				Else
					aRecon[1][REC_CONCILIADO] += nValorRec
				EndIf
			Else
				nValorPag := nValorMov
				
				If Empty((cAliasSE5)->E5_RECONC)
					aRecon[1][PAG_NAO_CONCILIADO] += nValorPag 
				Else
					aRecon[1][PAG_CONCILIADO] += nValorPag
				EndIf
			EndIf
			
			cDataDisp := DTOC((cAliasSE5)->E5_DTDISPO)
			cHistSE5  := AllTrim((cAliasSE5)->E5_HISTOR)
			
			If Len(AllTrim(E5_DOCUMEN)) + Len(AllTrim(E5_NUMCHEQ)) > 35
				cDocument := AllTrim(SUBSTR((cAliasSE5)->E5_DOCUMEN, 1, 20)) +;
				If(!Empty(AllTrim((cAliasSE5)->E5_DOCUMEN)), "-", " ") + AllTrim((cAliasSE5)->E5_NUMCHEQ )
			Else
				cDocument := If(Empty((cAliasSE5)->E5_NUMCHEQ), (cAliasSE5)->E5_DOCUMEN, (cAliasSE5)->E5_NUMCHEQ)
			EndIf
			
			If (cAliasSE5)->E5_TIPODOC == "CH"
				cPref_Tit := ChecaTp((cAliasSE5)->(E5_NUMCHEQ+E5_BANCO+E5_AGENCIA+E5_CONTA))
			Else
				cPref_Tit := (cAliasSE5)->E5_PREFIXO + If(Empty((cAliasSE5)->E5_PREFIXO), " ", "-") + (cAliasSE5)->E5_NUMERO +;
				If(Empty((cAliasSE5)->E5_PARCELA), " ", "-") + (cAliasSE5)->E5_PARCELA
			EndIf
			
			oMovBanc:PrintLine()
			(cAliasSE5)->(dbSkip())
		EndDo
		
		oMovBanc:Finish()
		oReport:SkipLine()
	EndDo
	
	oBanco:Finish()
	AADD(aTotais, {STR0014, Nil, Nil, nSaldoIni})
	AADD(aTotais, {STR0018, aRecon[1][REC_NAO_CONCILIADO], aRecon[1][REC_CONCILIADO], aRecon[1][REC_NAO_CONCILIADO] + aRecon[1][REC_CONCILIADO]})
	AADD(aTotais, {STR0019, aRecon[1][PAG_NAO_CONCILIADO], aRecon[1][PAG_CONCILIADO], aRecon[1][PAG_NAO_CONCILIADO] + aRecon[1][PAG_CONCILIADO]})
	AADD(aTotais, {STR0021, Nil, Nil, nLimCred})
	AADD(aTotais, {STR0020, Nil, Nil, nSaldoAtu += nLimCred})

	oTotal:Init()
	oTotal:Cell("DESCRICAO"):HideHeader()
	oTotal:Cell("NAOCONC"):SetHeaderAlign("CENTER")
	oTotal:Cell("CONC"):SetHeaderAlign("CENTER")
	oTotal:Cell("TOTAL"):SetHeaderAlign("CENTER")
	
	If lDvc
		For nI := 1 To Len(oMovBanc:aCell)
			oMovBanc:aCell[nI]:Hide()
		Next nI
	EndIf
	
	For nX := 1 to 5
		oTotal:Cell("DESCRICAO"):SetBlock( { || aTotais[nX][1] } )
		oTotal:Cell("NAOCONC"):SetBlock( { || If(nX == 2 .Or. nX == 3,Transform(aTotais[nX][2],tm(aTotais[nX][2],16,nMoeda)),"")} )
		oTotal:Cell("CONC"):SetBlock( { || If(nX == 2 .Or. nX == 3,Transform(aTotais[nX][3],tm(aTotais[nX][3],16,nMoeda)),"")} )
		oTotal:Cell("TOTAL"):SetBlock( { || Transform(aTotais[nX][4],tm(aTotais[nX][4],16,nMoeda))} )
		
		If nX == 2 .Or. nX == 5
			oReport:SkipLine()
		EndIf
		
		oTotal:PrintLine()
	Next nX
	
	oReport:Title(STR0004)
	oTotal:Finish()
Return NIL

//----------------------------------------------------------------
/*/{Protheus.doc}F470LinPag
Faz a quebra de pagina de acordo com o parametro "Linhas 
por Pagina?" (mv_par08) 

@author Marcio Menon 
@since  29/06/07
@version 12

@param nLinPag Numero maximo de linhas definido no relatorio
@param nLinReport Contador de linhas impressas no relatorio
@param lLimpa Restaura o contador quando troca a pagina

@return NIL
/*/
//-----------------------------------------------------------------
Static Function F470LinPag(nLinPag, nLinReport, lLimpa)
	Default nLinPag    := 0
	Default nLinReport := 0
	Default lLimpa     := .F.
	
	If lLimpa
		nLinReport := 9
	Else
		nLinReport++
		
		If nLinReport > (nLinPag + 8)
			oReport:EndPage()
			nLinReport := 9
		EndIf
	EndIf

Return Nil

//----------------------------------------------------------------
/*/{Protheus.doc}FR470Tab14
Carrega e retorna moedas da tabela 14 

@author Gustavo Henrique 
@since  15/07/10
@version 12

@return Dados da tabela 14 cadastrada no SX5
/*/
//-----------------------------------------------------------------
Static Function FR470Tab14() As Character
	Local cTabela14 As Character
	Local aRetSX5 	As Array
	Local nX		As Numeric

	cTabela14 := ""
	aRetSX5   := FWGetSX5( "14",,"pt-br")
	nX		  := 0
	
	For nX := 1 to Len(aRetSX5)
		if cPaisLoc != "BRA"
	        cTabela14 += (Alltrim(aRetSX5[nX,3]) + "/")
	    else 
	        cTabela14 += (Substring(Alltrim(aRetSX5[nX,3]),1,2) + "/")
	    endif 
	Next nX
	
	If cPaisLoc == "BRA"
		cTabela14 := SubStr(cTabela14, 1, Len(cTabela14) - 1)
	Else	
		cTabela14 += "/$ " 
	EndIf

Return cTabela14

//----------------------------------------------------------------
/*/{Protheus.doc}ChecaTp
Essa funcao retorna os dados do arquivo SEF para movimentos
bancarios do tipo CH.

@author Andrea Verissimo
@since  14/12/10
@version 12
@param cChaveTp Chave de busca contendo os valores
(Nro Cheque, Banco, Agencia e Conta da SE5)

@return prefixo, titulo e parcela do arquivo SEF. 
/*/
//-----------------------------------------------------------------
Static Function ChecaTp(cChaveTp)
	Local cRetorno := ""
	Local cChavSef := ""
	
	SEF->(dbSetOrder(4))
	cChavSef := (xFilial("SE5") + cChaveTp)
	
	If !SEF->(DbSeek(cChavSef))
		cChavSef := (E5_FILORIG+cChaveTp) 
		SEF->(DbSeek(cChavSef))
	EndIf
	
	While SEF->(!Eof()) .And. SEF->(EF_FILIAL+EF_NUM+EF_BANCO+EF_AGENCIA+EF_CONTA) = cChavSef
		If !Empty(SEF->EF_TIPO)
			cRetorno := SEF->EF_PREFIXO + If(Empty(SEF->EF_PREFIXO), " ", "-") + SEF->EF_TITULO + If(Empty(SEF->EF_PARCELA), " ", "-") + SEF->EF_PARCELA
			exit
		EndIf
		
		SEF->(Dbskip())
	Enddo
Return cRetorno

//----------------------------------------------------------------
/*/{Protheus.doc}CalcSldIni
Função para cálculo do saldo inicial de banco compart. 
e saldo exclusivo 

@author Rodrigo Oliveira
@since  14/04/15
@version 12
@param nSaldoAtu Saldo atual do movimento
@param nSaldoIni Saldo Inicial do movimento

@return 
/*/
//-----------------------------------------------------------------
Static Function CalcSldIni(nSaldoAtu, nSaldoIni) 
	Local cSaldo 		:= GetNextAlias()
	Local cQry			:= ""
	Local nMoeda		:= GetMv("MV_CENT"+(IIf(mv_par06 > 1 , STR(mv_par06,1),"")))
	Local cFl 			:= ""
	Local nSld			:= 0
	Local nSlRec		:= 0 
	Local dDtConvSLD	:= dDataBase
	Local nCasDec    	:= TamSx3("E5_TXMOEDA")[2]
	
	cQry := "SELECT E8_FILIAL, E8_BANCO, E8_AGENCIA, E8_CONTA, E8_DTSALAT, E8_SALATUA, E8_SALRECO "
	cQry += "FROM " + RetSqlName("SE8") + " SE8 " 
	cQry += "WHERE E8_BANCO = '" + mv_par01 + "' "
	cQry += "AND E8_AGENCIA = '" + mv_par02 + "' "
	cQry += "AND E8_CONTA = '" + mv_par03 + "' "
	cQry += "AND E8_DTSALAT < '" + DTOS(mv_par04) + "' "
	cQry += "AND D_E_L_E_T_ = ' ' ORDER BY E8_FILIAL, E8_DTSALAT DESC "
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cSaldo, .T., .T.)
	(cSaldo)->(DbGoTop())
	
	cFl 	:= (cSaldo)->E8_FILIAL
	nSld	:= (cSaldo)->E8_SALATUA
	nSlRec	:= (cSaldo)->E8_SALRECO
	
	While (cSaldo)->(!Eof())
		If (cSaldo)->E8_FILIAL != cFl
			nSld	+= (cSaldo)->E8_SALATUA
			nSlRec	+= (cSaldo)->E8_SALRECO
			cFl 	:= (cSaldo)->E8_FILIAL
		EndIf
		
		(cSaldo)->(DbSkip())
	EndDo
	
	(cSaldo)->(DbCloseArea())
	
	If mv_par07 == 2
		nSld := nSlRec
	ElseIf mv_par07 == 3
		nSld := (nSld - nSlRec)
	EndIf
	dDtConvSLD := F470DtSld()
	
	nSaldoAtu :=  nSaldoIni := Round(xMoeda(nSld, nMoedaBco, mv_par06, dDtConvSLD,nCasDec), nMoeda)

Return Nil

//----------------------------------------------------------------
/*/{Protheus.doc}F470DtSld
Função que retornará a data de conversão do saldo inicial (SE8)

@author Pâmela Bernardo
@since  02/06/21
@version 12

@return dDtConvSLD
/*/
//-----------------------------------------------------------------
Static Function F470DtSld() as Date
	Local dDtConvSLD as Date

	dDtConvSLD := SE8->E8_DTSALAT

	If __lMVPAR12
		If MV_PAR12 == 1
			dDtConvSLD := SE8->E8_DTSALAT
		ElseIf MV_PAR12 == 2
			dDtConvSLD := dDataBase
		ElseIf MV_PAR12 == 3
			dDtConvSLD := MV_PAR04
		Else
			dDtConvSLD := MV_PAR05
		EndIf
	EndIf

Return dDtConvSLD

//----------------------------------------------------------------
/*/{Protheus.doc}R470Lgi
Função que retornará o nome do usuário convertido do campo E5_USERLGI

@author Francisco Oliveira
@since  08/06/22
@version 12

@return cUserRet
/*/
//-----------------------------------------------------------------

Static Function R470Lgi(cAliasReg as Char, cCampo as Char) as Char

	Local cUserRet as Char
	
	cUserRet := FwLeUserLg(cAliasReg + "->"+cCampo,1)

Return cUserRet
