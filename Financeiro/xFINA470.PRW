#INCLUDE "FINA470.CH"
#include "fileio.ch"
#Include "Protheus.ch"                     

STATIC __lDefTop	:= NIL	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FinA470  ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 03/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reconcilia‡ao Bancaria Automatica                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Fina470()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±    
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER Function XFina470(nPosArotina)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//Local lPanelFin := IsPanelFin()
Local lExec		:= .T.

ValidPerg("XAFI470")

pergunte("XAFI470",.F.)

Private aRotina		:= MenuDef()
Private cCadastro	:= STR0006  //"Reconcilia‡„o Banc ria Autom tica" 
Private aIndices	:= {} //Array necessario para a funcao FilBrowse
Private bFilBrw		:= {|| }
Private lFiltBrw	:= ExistBlock("F470FBRW")
Private cFiltro		:= ""   
Private nTotExt 	:= 0
Private nTotSis 	:= 0
PUBLIC  cRecPag     := ""

// Variaveis para contabilizacao
If cPaisLoc == "ARG"
	If FindFunction("FinModProc")
		lExec := FinModProc()
	Else
		lExec := .T.
	Endif
Endif

If lExec
	If lFiltBrw
		cFiltro:= ExecBlock( "F470FBRW",.F.,.F.)
		bFilBrw	:=	{|| FilBrowse("SE5",@aIndices,@cFiltro)}
		Eval( bFilBrw )
	EndIf
	
	DEFAULT nPosArotina := 0
	If nPosArotina > 0 // Sera executada uma opcao diretamento de aRotina, sem passar pela mBrowse
		dbSelectArea("SE5")
		bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
		Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina)
	Else
		mBrowse( 6, 1,22,75,"SE5")
	Endif
	If lFiltBrw
		EndFilBrw("SE5",@aIndices)
	EndIf
Endif
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ XfA470Gera ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 03/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reconcilia‡„o Banc ria Autom tica                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ XfA470Gera()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ xFINA470                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER Function XFA470Gera(cAlias)

Local lPanelFin		:= IsPanelFin()   
Local lGestao		:= FWSizeFilial() > 2	// Indica se usa Gestao Corporativa
Local lCompExcl		:= .F.        			// Controle de compartilhamento (tudo exclusivo ou tudo compartilhado
Local nj			:= 0
Local aSelFil		:= {}
Local aTmpFil		:= {}                                                 
Local lRet			:= .T.
Local nOpca			:= 0
Local aButtons		:= {} 
Local aSays			:= {}

Private nHdlPrv		:= 0
Private lDigita  	:= Iif(mv_par07 ==1,.T.,.F.)
Private lAglutina	:= Iif(mv_par06 ==1,.T.,.F.)
Private lGeraLanc	:= Iif(mv_par08 ==1,.T.,.F.)
Private cArquivo    
Private nTotal		:= 0
Private cLote		:= ""
Private aFlagCTB	:= {}
Private lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/) 

If lPanelFin  //Chamado pelo Painel Financeiro							
	If ! PergInPanel("XAFI470",.T.)	
		lRet := .F.
	Endif
Endif

If lRet

	nOpcA := 0
	aSays := {}
	
	AADD(aSays, STR0063)		//"Este programa tem como objetivo possibilitar a conciliação dos"
	AADD(aSays, STR0064)		//"movimentos bancários do sistema através da leitura do arquivo")
	AADD(aSays, STR0065)		//"de extrato bancário."
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o log de processamento                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ProcLogIni( aButtons )
	
	If lPanelFin  //Chamado pelo Painel Financeiro			
		aButtonTxt := {}			
		AADD(aButtonTxt,{STR0001,STR0001, {||Pergunte("XAFI470",.T. )}}) // Parametros						
		FaMyFormBatch(aSays,aButtonTxt,{||nOpca:= 1},{||nOpca:=0})	
	Else
		AADD(aButtons, { 5,.T.,{|| Pergunte("XAFI470",.T. ) } } )
		AADD(aButtons, { 1,.T.,{|o| (nOpca:= 1,o:oWnd:End())}} )
		AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
		FormBatch( cCadastro, aSays, aButtons ,,,390)
	Endif
	
	If nOpcA == 1
		
		If lFiltBrw
			EndFilBrw("SE5",@aIndices)
		EndIf
	
		//Gestao
		If __lDefTop == NIL
			__lDefTop 	:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)
		Endif
		
		If lGestao
			lCompExcl := (FWModeAccess("SE5",1) == "C" .and. FWModeAccess("SA6",1) == "C") .or. ;
						 (FWModeAccess("SE5",3) == "3" .and. FWModeAccess("SA6",3) == "E")
		Endif
		
		//Gestao
		//Selecao de filiais
		If lGestao .and. __lDefTop .and. mv_par12 == 1 .And. Len( aSelFil ) <= 0 .and. !lCompExcl
			aSelFil := AdmGetFil(.F.,.T.,"SE5")
			If Len( aSelFil ) <= 0
				lRet := .F.
			EndIf	
		Else
			aSelFil := { cFilAnt }	 
		EndIf
	
		If lRet
		
			Processa({|lEnd| U_xfa470G(cAlias,aSelFil,aTmpFil)})  // Chamada com regua
	
			// Contabilizacao
			If nHdlPrv > 0 .And. nTotal > 0
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Efetiva Lan‡amento Contabil                                      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				RodaProva( nHdlPrv,;
				           nTotal)
			
				cA100Incl( cArquivo,;
				           nHdlPrv,;
				           3 /*nOpcx*/,;
				           cLote,;
				           lDigita,;
				           lAglutina,;
				           /*cOnLine*/,;
				           /*dData*/,;
				           /*dReproc*/,;
				           @aFlagCTB,;
				           /*aDadosProva*/,;
				           /*aDiario*/ )
				aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
			EndIf
			
			If lFiltBrw
				Eval(bFilBrw)
			EndIf
			
			//Gestao
			For nJ := 1 TO Len(aTmpFil)
				CtbTmpErase(aTmpFil[nJ])
			Next
		Endif
	Endif
Endif
		
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ fA470Ger³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 03/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reconciliacao Bancaria Automatica                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fA470Ger()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FinA470                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER Function XfA470G(cAlias,aSelFil,aTmpFil)

Local lPanelFin := IsPanelFin()
Local cPosNum	:= ""
Local cPosData	:= ""
Local cPosValor	:= ""
Local cPosOcor	:= ""
Local cPosDescr	:= ""
Local cPosDif	:= ""
Local cDebCred	:= ""
Local cRecTRB	:= ""
Local cArqConf	:= ""
Local cArqEnt	:= ""
Local cIndex	:= " "					
//Local cMotSist	:= Space(3)				// motivo da ocorrencia no sistema
//Local cMotBan	:= Space(3)				// motivo da ocorrencia no banco
Local cBanco	:= Space(TamSX3("E5_BANCO")[1])
Local cAgencia	:= Space(TamSX3("E5_AGENCIA")[1]) 
Local cConta	:= Space(TamSX3("E5_CONTA")[1])
Local cDifer	:= ""
Local cVarQ   	:= "  "
Local cPosVSI	:= ""
Local cPosDSI	:= ""
Local cPosDCI	:= ""
Local cReconAnt := ""
Local cQuery	:= ""
Local cAliasTrb	:= ""
Local cCampos	:= ""
Local xBuffer	:= ""
Local cTmpSE5Fil:= ""
Local nLidos	:= 0
Local nLenNum	:= 0
Local nLenData	:= 0
Local nLenValor	:= 0
Local nLenDescr	:= 0
Local nLenOcor	:= 0
Local nLenDif	:= 0
Local nLenBco	:= 0
Local nLenAge	:= 0
Local nLenCta	:= 0
Local nOpca		:= 0
Local nHdlBco	:= 0
Local nLenVSI	:= 0
Local nLenDSI	:= 0
Local nLenDCI	:= 0
Local nT 		:= 0
Local nX		:= 0
Local nReconc	:= 0
Local nTipoDat	:= 1
Local lSaida	:= .F.
Local lReconc	:= .F.
Local lPosNum	:= .F.
Local lPosData  := .F.
Local lPosValor := .F.
Local lPosOcor	:= .F.
Local lPosDescr := .F.
Local lPosDif   := .F.
Local lPosBco	:= .F.
Local lPosAge   := .F.
Local lPosCta   := .f.
Local lPosVSI	:= .F.
Local lPosDSI	:= .F.
Local lPosDCI	:= .F.
Local lFebraban := .F.
Local lGrava	:= .T.
Local lAtSalRec1:= .F.
Local lAtSalRec2:= .F.
Local lAtuDtDisp:= .T.
Local lIndice13	:= .F.
Local lReproc	:= .F.
Local lFa470Cta := ExistBlock("FA470CTA")
Local lF470Grv	:= ExistBlock("F470GRV")
Local lF470DAT 	:= ExistBlock("F470DAT")
Local lF470AtuDt:= ExistBlock("F470ATUDT")
Local lF470Qry	:= ExistBlock("F470QRY" )   
Local lGestao	:= FWSizeFilial() > 2	// Indica se usa Gestao Corporativa
Local aCores 	:= {}
Local aConta	:= {}
Local aCtas470  := {}
Local aAreaAtu	:= {}
Local aButtonTxt:= {}
Local oOk		:= LoadBitmap( GetResources(), "BR_VERDE" )
Local oNo		:= LoadBitmap( GetResources(), "DISABLE" )
Local oParc		:= LoadBitmap( GetResources(), "BR_AMARELO" )
Local oJaRec	:= LoadBitmap( GetResources(), "BR_CINZA" )
Local oTitulo 
Local oBtn
Local oDlg
//Local dDtaCred	:= CRIAVAR("E5_DTDISPO")
Local dDtIniA	:= CRIAVAR("E5_DTDISPO")	
Local dDtFinA	:= CRIAVAR("E5_DTDISPO")
Local lFA470Qry	:= ExistBlock( "FA470QRY" )

Private oTmpTb
Private lMarca	 := 1
Private dDtIni	 := CTOD("01/01/2099","ddmmyy")
Private dDtFin	 := CTOD("01/01/1980","ddmmyy")
Private	dDataInic:= dDataBase
Private	dDataFim := dDataBase
Private dOldDispo := Ctod("//")

Aadd(aCores,oOk)
Aadd(aCores,oNo)
Aadd(aCores,oParc)
Aadd(aCores,oJaRec)

//Gestao
If __lDefTop == NIL
	__lDefTop 	:= IfDefTopCTB() // verificar se pode executar query (TOPCONN)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona no Banco indicado                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SEE")
dbSetOrder(1)    
If dbSeek(xFilial("SEE")+mv_par03)
	lFebraban := IIF(SEE->EE_BYTESXT > 200 , .t., .f.)
	nTamDet	 := IIF(SEE->EE_BYTESXT > 0, SEE->EE_BYTESXT + 2, 202 )
Else
	Help(" ",1,"PAR150")
	Return .F.
Endif                            

nTipoDat := IIF(nTamDet > 202, 4,1)		//1 = ddmmaa		4= ddmmaaaa

If lF470DAT
	nTipoDat := ExecBlock("F470DAT",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo de configuracao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqConf:=mv_par02

IF !FILE(cArqConf)
	Help(" ",1,"A470NOPAR")
	Return .F.
Else
	nHdlConf:=FOPEN(cArqConf,0+64)
EndIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lˆ arquivo de configuracao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLidos 	:=0
FSEEK(nHdlConf,0,0)
nTamArq :=FSEEK(nHdlConf,0,2)
FSEEK(nHdlConf,0,0)

While nLidos <= nTamArq
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o tipo de qual registro foi lido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xBuffer:=Space(85)
	FREAD(nHdlConf,@xBuffer,85)
	IF SubStr(xBuffer,1,1) == CHR(1)  // Header
		nLidos+=85
		Loop
	EndIF

	IF SubStr(xBuffer,1,1) == CHR(4) // Saldo Final
		nLidos+=85
		Loop
	EndIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dados do Saldo Inicial (Bco/Ag/Cta)       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !lPosBco  //Nro do Banco
		cPosBco:=Substr(xBuffer,17,10)
		nLenBco:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosBco:=.T.
		nLidos+=85
		Loop
	EndIF
	IF !lPosAge  //Agencia
		cPosAge :=Substr(xBuffer,17,10)
		nLenAge :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosAge :=.T.
		nLidos+=85
		Loop
	EndIF
	IF !lPosCta  //Nro Cta Corrente
		cPosCta=Substr(xBuffer,17,10)
		nLenCta=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosCta=.T.
		nLidos+=85
		Loop
	Endif
	IF !lPosDif   // Diferencial de Lancamento
		cPosDif  :=Substr(xBuffer,17,10)
		nLenDif  :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosDif  :=.t.
		nLidos+=85
		Loop
	EndIF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Os dados abaixo nÆo sÆo utilizados na reconcilia‡Æo. ³
	//³ EstÆo ai apenas p/leitura do arquivo de configura‡Æo.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !lPosVSI   // Valor Saldo Inicial
		cPosVSI  :=Substr(xBuffer,17,10)
		nLenVSI  :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosVSI  :=.t.
		nLidos+=85
		Loop
	EndIF
	IF !lPosDSI   // Data Saldo Inicial
		cPosDSI  :=Substr(xBuffer,17,10)
		nLenDSI  :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosDSI  :=.t.
		nLidos+=85
		Loop
	EndIF
	IF !lPosDCI   // Identificador Deb/Cred do Saldo Inicial
		cPosDCI  :=Substr(xBuffer,17,10)
		nLenDCI  :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosDCI  :=.t.
		nLidos+=85
		Loop
	EndIF
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dados dos Movimentos                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !lPosNum  // Nro do Lancamento no Extrato
		cPosNum:=Substr(xBuffer,17,10)
		nLenNum:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosNum:=.t.
		nLidos+=85
		Loop
	EndIF
	IF !lPosData  // Data da Movimentacao
		cPosData:=Substr(xBuffer,17,10)
		nLenData:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosData:=.t.
		nLidos+=85
		Loop
	EndIF
	IF !lPosValor  // Valor Movimentado
		cPosValor=Substr(xBuffer,17,10)
		nLenValor=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosValor=.t.
		nLidos+=85
		Loop
	EndIF
	IF !lPosOcor // Ocorrencia do Banco
		cPosOcor	:=Substr(xBuffer,17,10)
		nLenOcor :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosOcor	:=.t.
		nLidos+=85
		Loop
	EndIF
	IF !lPosDescr  // Descricao do Lancamento
		cPosDescr:=Substr(xBuffer,17,10)
		nLenDescr:=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosDescr:=.t.
		nLidos+=85
		Loop
	EndIF
	IF !lPosDif   // Diferencial de Lancamento
		cPosDif  :=Substr(xBuffer,17,10)
		nLenDif  :=1+Int(Val(Substr(xBuffer,20,3)))-Int(Val(Substr(xBuffer,17,3)))
		lPosDif  :=.t.
		nLidos+=85
		Loop
	EndIF
	Exit
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ fecha arquivo de configuracao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Fclose(nHdlConf)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se constam dados banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cPosBco) .or. Empty(cPosAge)   .or. Empty(cPosCta)  .or.;
	Empty(cPosDif) .or. Empty(cPosValor) .or. Empty(cPosOcor) .or.;
	Empty(cPosData) 
	Help(" ",1,"A470NOCFG")
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre arquivo enviado pelo banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqEnt:=mv_par01
IF !FILE(cArqEnt)
	Help(" ",1,"A470NOBCO")
	Return .F.
Else
	nHdlBco:=FOPEN(cArqEnt,0+64)
EndIF

//Verifica se o arquivo de retorno bancafio ja foi processado
If !(U_xChk470File(@lReproc))
	If nHdlBco > 0
		FClose(nHdlBco)
	Endif
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria arquivo de trabalho                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
F470CRIARQ()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Lˆ arquivo enviado pelo banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLidos:=0
FSEEK(nHdlBco,0,0)
nTamArq:=FSEEK(nHdlBco,0,2)
FSEEK(nHdlBco,0,0)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desenha o cursor e o salva para poder moviment -lo ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ProcRegua( nTamArq / nTamDet , 24 )
nLidos := 0
While nLidos <= nTamArq
	IncProc()
	nValor  :=0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tipo qual registro foi lido ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xBuffer:=Space(nTamDet)
	FREAD(nHdlBco,@xBuffer,nTamDet)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica o diferencial do registro de Lancamento 			³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lFebraban  // 200 posicoes
		cDifer :=Substr(xBuffer,Int(Val(Substr(cPosDif, 1,3))),nLenDif )
	Else
		cDifer := "xx"  // 240 posicoes
	Endif

	// Header do arquivo
	IF (SubStr(xBuffer,1,1) == "0" .and. !lFebraban).or. ; // 200 posicoes
		(Substr(xBuffer,8,1) == "0" .and. lFebraban)			// 240 posicoes
		nLidos+=nTamDet
		Loop
	EndIF

	//Trailer do arquivo
	IF (SubStr(xBuffer,1,1) == "9" .and. !lFebraban) .or. ; //200 posicoes
		(Substr(xBuffer,8,1) == "9" .and. lFebraban)			 //240 posicoes
		nLidos+=nTamDet
		dbSelectArea("TRB")
		dbGoTop()
		IF BOF() .and. EOF()
			lSaida := .T.
		Endif
		Exit
	EndIF

	// Saldo Inicial
	IF (SubStr(xBuffer,1,1) == "1" .and. cDifer == "0" .and. !lFebraban) .or. ;
		(SubStr(xBuffer,8,1) == "1" .and. lFebraban)
		cBanco   :=Substr(xBuffer,Int(Val(Substr(cPosBco, 1,3))),nLenBco )
		cAgencia :=Substr(xBuffer,Int(Val(Substr(cPosAge, 1,3))),nLenAge )
		cConta   :=Substr(xBuffer,Int(Val(Substr(cPosCta, 1,3))),nLenCta )
		//Valida e retirar os zeros a esquerda se necessario
		A470VldBco( MV_PAR03 , @cAgencia , @cConta )
		If lFa470Cta
			aConta   := ExecBlock("FA470CTA", .F., .F., {cBanco, cAgencia, cConta} )
			cBanco   := aConta[1]
			cAgencia := aConta[2]
			cConta   := aConta[3]
		Endif
		If AllTrim(cBanco)!= AllTrim(mv_par03)
			Help(" ",1,"FA470CONTA")
			lSaida := .T.
			Exit
		Endif
		//Monto array com as contas contidas no arquivo de retorno, 
		//para posterior validacao dos movimentos contidos no SE5
		If nT := ascan(aCtas470,{|x| x = cAgencia+cConta }) == 0
 			Aadd(aCtas470,ALLTRIM(cAgencia)+ALLTRIM(cConta))
 		Endif

		nLidos+=nTamDet
		Loop
	EndIF

	// Saldo Final
	IF (SubStr(xBuffer,1,1) == "1" .and. cDifer == "2" .and. !lFebraban) .or. ;
		(Substr(xBuffer,8,1) == "5" .and. lFebraban)
		nLidos+=nTamDet
		Loop
	EndIF

	// Lancamentos
	IF (SubStr(xBuffer,1,1) == "1" .and. cDifer == "1" .and. !lFebraban) .or. ;
		(Substr(xBuffer,8,1) == "3" .and. lFebraban)

		cNumMov 	:=Substr(xBuffer,Int(Val(Substr(cPosNum,1,3))),nLenNum)
		cDataBco :=Substr(xBuffer,Int(Val(Substr(cPosData,1,3))),nLenData)
		cDataBco :=ChangDate(cDataBco,nTipoDat)
		dDataMov	:=Ctod(Substr(cDataBco,1,2)+"/"+Substr(cDataBco,3,2)+"/"+Substr(cDataBco,5,2),"ddmmyy")
		cDataMov	:=dToc(dDataMov)
		dDtIni 	:=MIN(dDtIni,dDataMov)
		dDtFin 	:=MAX(dDtFin,dDataMov)
		cValorMov:=Transform(Round(Val(Substr(xBuffer,Int(Val(Substr(cPosValor,1,3))),nLenValor))/100,2),"@E 999,999,999,999.99")
		cCodMov	:=Substr(xBuffer,Int(Val(Substr(cPosOcor,1,3))),nLenOcor)
		cDescrMov:=Substr(xBuffer,Int(Val(Substr(cPosDescr,1,3))),nLenDescr)

		dbSelectArea("SEJ") 
		If dbSeek(xFilial("SEJ")+cBanco+cCodMov)
			cTipoMov := SEJ->EJ_OCORSIS
			cDescMov := SEJ->EJ_DESCR
			cDebCred := SEJ->EJ_DEBCRE
		Else
			Help(" ",1,"FA470OCOR")
			MSGINFO("Banco:"+cBanco+"      Cod. Ocorrencia:"+cCodMov+"      Descrição:"+cDescrMov)
			lSaida := .T.
			Exit
		Endif

		lGrava := .T.
		If lF470GRV
			lGrava := ExecBlock("F470GRV",.F.,.F.,xBuffer)
		Endif
		
		If lGrava	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava dados no arquivo de trabalho³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lInclui := .T.
			IF ALLTRIM(cTipoMov) == "ENC"  // Customizado  BK
				dbSelectArea("TRB")
				dbGoTop()
                DO WHILE ("TRB")->(!EOF())
                	IF ALLTRIM(TRB->TIPOMOV) == "ENC" 
  						dbSelectArea("TRB")
  						cVMov := ""
  						nVMov := 0
  						cVMov := ConValor(TRB->VALORMOV,18)
  						nVMov := val(cVMov)
  						cVMov := ConValor(cValorMov,18)
  						nVMov += val(cVMov)
               			cValorMov := Transform(nVMov,"@E 999,999,999,999.99")
        				RecLock("TRB",.F.)
						TRB->VALORMOV := cValorMov
						("TRB")->(MsUnlock())
						lInclui := .F.
					ENDIF
					("TRB")->(DbSkip())
			    ENDDO
				dbSelectArea("TRB")
				dbGoTop()
			ENDIF
 			IF lInclui
				DbSelectArea("TRB")
				DbAppend()
				cRecTRB 		:= STR(TRB->(Recno()))
				TRB->SEQMOV 	:= SUBSTR(cRecTRB,-4)
				TRB->DATAMOV  	:= cDataMov
				TRB->NUMMOV   	:= cNumMov
				TRB->VALORMOV 	:= cValorMov
				TRB->TIPOMOV	:= cTipoMov
				TRB->DESCMOV	:= cDescMov
				TRB->DEBCRED	:= cDebCred
				TRB->DESCRMOV	:= cDescrMov
				TRB->AGEMOV		:= cAgencia
				TRB->CTAMOV		:= cConta
				TRB->OK     	:= 2		// N„O RECONCILIADO
			ENDIF
		Endif
	Endif
	nLidos += nTamDet
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha arquivo do Banco        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Fclose(nHdlBco)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processa dados, caso tudo Ok      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("TRB")
dbGoTop()
If BOf() .and. EOF() .and. !lSaida
	Help(" ",1,"ERROCONF")
	lSaida := .T.
Endif

dDtIniA := dDtIni           	// Armazeno data inicial e final contido no arquivo
dDtFinA := dDtFin
dDtIni  := dDtIni - mv_par05	// Acrescento/diminuo das variaveis para abrir periodo
dDtFin  := dDtFin + mv_par04	// E5_DTDISPO

If !lSaida

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre o SE5 com outro alias para ser filtrado porque a funcao³	
	//³ TemBxCanc() utilizara o SE5 sem filtro.							 ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dDataInic := Min(dDtIni,Iif(Empty(mv_par09),dDtIni,mv_par09) )
	dDataFim  := Max(dDtFin,Iif(Empty(mv_par10),dDtFin,mv_par10))

	If ( ChkFile("SE5",.F.,"NEWSE5") )

		If __lDefTop .and. Len(aSelFil) > 1
			cChave  := "E5_BANCO+E5_AGENCIA+E5_CONTA+DTOS(E5_DTDISPO)"
		Else
			cChave  := "E5_FILIAL+E5_BANCO+E5_AGENCIA+E5_CONTA+DTOS(E5_DTDISPO)"
		Endif

		If __lDefTop
			cTipoCH:=IF(Type("MVCHEQUES")=="C",MVCHEQUES,MVCHEQUE)
			
			cAliasTrb := GetNextAlias()
			aStru  := SE5->(dbStruct())
			cCampos := ""
			aEval(aStru,{|x| cCampos += ","+AllTrim(x[1])})
			cQuery := "SELECT "+SubStr(cCampos,2) + ", R_E_C_N_O_ RECNOSE5 "
			cQuery += "FROM " + RetSqlName("SE5") + " SE5 "
			cQuery += "WHERE "
			
			//Gestao
			If lGestao .and. Len(aSelFil) > 1
				cQuery += "E5_FILIAL " + GetRngFil( aSelFil, "SE5", .T., @cTmpSE5Fil ) + " AND "
				aAdd(aTmpFil, cTmpSE5Fil)
			Else						
				cQuery += "E5_FILIAL = '" + xFilial("SE5")+"' AND "
			Endif
			cQuery +=	"E5_DTDISPO >= '" + DTOS(dDataInic) + "' AND "
			cQuery +=	"E5_DTDISPO <= '" + DTOS(dDataFim) + "' AND "
			cQuery +=	"E5_BANCO = '" + mv_par03 + "' AND "
			cQuery +=	"E5_SITUACA <> 'C' AND "
			cQuery +=	"E5_TIPODOC NOT IN " + FormatIn("BA/DC/JR/MT/CM/D2/J2/M2/C2/V2/CP/TL","/") + " AND "
			cQuery +=	"E5_VALOR > 0 AND "
			cQuery +=	"(E5_MOEDA NOT IN " + FormatIn("C1/C2/C3/C4/C5/CH","/") + " OR (E5_MOEDA IN " + FormatIn("C1/C2/C3/C4/C5/CH","/") + " AND E5_NUMCHEQ <> ' ')) AND "
			cQuery +=	"(E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) AND "  
			cQuery +=	"((E5_TIPODOC  IN "+ FormatIn(cTipoCH,"|") + "AND  E5_DTDISPO BETWEEN  '" + DTOS(mv_par09)+ "' AND '"  + DTOS(mv_par10) +"' ) OR "  
			//AJUSTE bk 
			//Query +=	"(E5_TIPODOC   NOT IN "+ FormatIn(cTipoCH,"|") + "AND  E5_DTDISPO BETWEEN  '" + DTOS(dDtIni)+ "' AND '"  + DTOS(dDtFin) +"' )) AND "  
			cQuery +=	"(E5_TIPODOC   NOT IN "+ FormatIn(cTipoCH,"|") + "AND  E5_DTDISPO BETWEEN  '" + DTOS(mv_par09)+ "' AND '"  + DTOS(mv_par10) +"' )) AND "  
  
			cQuery +=	"(E5_NUMCHEQ <> '*' OR (E5_NUMCHEQ = '*' AND E5_RECPAG <> 'P')) AND "  
			If lF470Qry
				cQuery += ExecBlock( "F470QRY",.F.,.F.)
			EndIf
			cQuery +=	"D_E_L_E_T_ = ' ' "
			cQuery += 	"ORDER BY " + SqlOrder(cChave)
			If lFA470QRY
				cQuery := ExecBlock( "FA470QRY",.F.,.F.,{@cQuery})
			EndIf
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.T.)
			For nX :=  1 To Len(aStru)
				If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1]) > 0
					TcSetField(cAliasTrb,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
				EndIf
			Next nX
		Else
			
			aAreaAtu := GetArea()
			dbSelectArea("SIX")
			lIndice13:= dbSeek("SE5"+"D")    
			RestArea(aAreaAtu)
			
			If lIndice13 
				cAliasTrb:="SE5"
				DbSelectArea(cAliasTrb)
				DbSetOrder(13)
				DbSeek(xFilial("SE5")+mv_par03+Dtos(dDataInic),.T.)
	
			Else
				cAliasTrb := "NEWSE5"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Filtra o SE5 por Banco/Ag./Cta                               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("NEWSE5")
				cIndex := GetNextAlias() // CriaTrab(nil,.f.)
				IndRegua("NEWSE5",cIndex,cChave,,U_XFa470ChecF(), STR0009)  //"Selecionando Registros..."
				DbSelectArea("NEWSE5")
				dbSetIndex(cIndex+OrdBagExt())
				dbGoTop()
		    EndIf
				
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicia a leitura do arquivo   ³
		//³ de movimentacao do SE5        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While (cAliasTrb)->(!(Eof())) .And. Iif(!lIndice13,.T.,(cAliasTrb)->(E5_BANCO)==mv_par03 .And. (cAliasTrb)->(E5_DTDISPO)<= dDataFim)


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ registros a serem ignorados   ³
			//³ pela movimentacao do SE5      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	        //Movimentos do banco mas de contas que nao constem do arquivo de retorno
    	    //dever ser desprezadas.
			If nT := Ascan(aCtas470,{|x| AllTrim( x ) == ALLTRIM((cAliasTrb)->E5_AGENCIA)+ALLTRIM((cAliasTrb)->E5_CONTA)}) == 0
				(cAliasTrb)->(dbSkip())
				Loop
			EndIF

			If !Empty( (cAliasTrb)->E5_MOTBX ) .and. !MovBcoBx((cAliasTrb)->E5_MOTBX)
				(cAliasTrb)->(dbSkip())
				Loop
			EndIF

			If !__lDefTop
				IF (cAliasTrb)->E5_TIPODOC $ "BA/DC/JR/MT/CM/D2/J2/M2/C2/V2/CP/TL"  //Valores de Baixas
					(cAliasTrb)->( dbSkip())
					Loop
				EndIF

				IF (cAliasTrb)->(E5_BANCO)!= mv_par03
					(cAliasTrb)->(dbSkip())
					Loop
				EndIF

				IF (cAliasTrb)->(E5_TIPODOC) $ IIF(Type("MVCHEQUES")=="C",MVCHEQUES,MVCHEQUE) .And.  (cAliasTrb)->(E5_DTDISPO)> MV_PAR10 .And. (cAliasTrb)->(E5_DTDISPO)< MV_PAR09
					(cAliasTrb)->(dbSkip())
					Loop
				EndIF
	         
		    	IF !((cAliasTrb)->(E5_TIPODOC) $ IIF(Type("MVCHEQUES")=="C",MVCHEQUES,MVCHEQUE)) .And.  (cAliasTrb)->(E5_DTDISPO)> dDtFin .And. (cAliasTrb)->(E5_DTDISPO)< dDtIni 
					(cAliasTrb)->(dbSkip())
					Loop
				EndIF
     

				IF (cAliasTrb)->E5_SITUACA = "C"    //Cancelado
					(cAliasTrb)->( dbSkip())
					Loop
				EndIF

				IF (cAliasTrb)->E5_VALOR = 0
					(cAliasTrb)->(dbSkip())
					LOOP
				EndIF

				IF (cAliasTrb)->E5_MOEDA $ "C1/C2/C3/C4/C5/CH" .and. Empty((cAliasTrb)->E5_NUMCHEQ)
					(cAliasTrb)->(dbSkip())
					Loop
				EndIF

				If SubStr((cAliasTrb)->E5_NUMCHEQ,1,1)=="*"  .AND. (cAliasTrb)->E5_RECPAG=="P"    //cheque para juntar (PA)
					(cAliasTrb)->(dbSkip())
					Loop
				EndIF

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se existe estorno para esta baixa                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lIndice13
					SE5->(MsGoto(NEWSE5->(RECNO())))
				EndIf
			Else
				SE5->(MsGoto((cAliasTrb)->RECNOSE5))
			Endif	

			If TemBxCanc((cAliasTrb)->E5_PREFIXO+(cAliasTrb)->E5_NUMERO+(cAliasTrb)->E5_PARCELA+(cAliasTrb)->E5_TIPO+(cAliasTrb)->E5_CLIFOR+(cAliasTrb)->E5_LOJA+(cAliasTrb)->E5_SEQ)
				(cAliasTrb)->( dbskip())
				loop
			EndIf

			IF (cAliasTrb)->E5_TIPODOC = "CH"    //Emiss„o de Cheque
				If SEF->(dbSeek(xFilial("SEF")+(cAliasTrb)->E5_BANCO+(cAliasTrb)->E5_AGENCIA+(cAliasTrb)->E5_CONTA+(cAliasTrb)->E5_NUMCHEQ))
					If SEF->EF_IMPRESS = "C"
						(cAliasTrb)->(dbSkip())
						Loop
					EndIF
				EndIF
			EndIF

			//Grava Registro no TRB
			DbSelectArea("TRB")
			DbAppend()
			cRecTRB := STR(TRB->(Recno()))
			TRB->SEQMOV 	:= SUBSTR(cRecTRB,-4)
			TRB->DATAMOV	:= DTOC((cAliasTrb)->E5_DTDISPO)
			TRB->NUMSE5		:= (cAliasTrb)->E5_NUMCHEQ
			TRB->VALORSE5	:= Transform((cAliasTrb)->E5_VALOR,"@E 999,999,999,999.99")
			TRB->DEBCRED	:= IIF((cAliasTrb)->E5_RECPAG == "R", "C","D")
			TRB->RECSE5		:= If(__lDefTop,(cAliasTrb)->RECNOSE5,(cAliasTrb)->(Recno()))
			TRB->RECONSE5	:= (cAliasTrb)->E5_RECONC
			TRB->AGESE5		:= (cAliasTrb)->E5_AGENCIA
			TRB->CTASE5		:= (cAliasTrb)->E5_CONTA
			TRB->OK			:= IIF (!Empty(TRB->RECONSE5),4,2)  // 2 = N„o Reconciliado
						 														 // 4 = Reconciado anteriormente (SE5)
	        cDataMov  := TRB->DATAMOV
	        cNumMov   := TRB->NUMSE5
	        cValorMov := TRB->VALORSE5
	        nRecSe5   := TRB->RECSE5
	        cSeqSe5   := TRB->SEQMOV
	        cDebCred  := TRB->DEBCRED
			cCtaMov   := TRB->CTASE5
			cAgeMov   := TRB->AGESE5
			lReconc   := IIF(!EMPTY(TRB->RECONSE5),.T.,.F.)
			nRecTrb   := TRB->(Recno())
			DbSelectArea("TRB")
			DbSetOrder(2)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tento pre-reconciliacao dentro da 					  					  ³
			//³ Data + Agencia + Conta + Numero + Valor + Tipo					     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRecno := Recno()
			If DbSeek(cAgeMov + cCtaMov + cNumMov + cDataMov +  cValorMov + cDebCred)
				nRecno := Recno()
				
				DbGoTo(nRecTrb)
				dbDelete()
				dbGoto(nRecno)
				TRB->VALORSE5 	:= cValorMov
				TRB->NUMSE5	  	:= cNumMov
				TRB->RECSE5		:= nRecSE5
				TRB->CTASE5		:= cCtaMov
				TRB->AGESE5		:= cAgeMov
				TRB->SEQRECON	:= cSeqSE5
				TRB->OK			:= IIf (lReconc,4,1)  	// 1 => Reconc. totalmente
																 	// 4 => Reconc. Anteriomente no SE5
			Else
				dbGoto(nRecno)
			Endif

			DbSetOrder(1)

			If (mv_par04 # 0 .Or. mv_par05 # 0) .And. !Str(TRB->OK,1) $ "1#3#4"
				DbSelectArea("TRB")
				DbSetOrder(4)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Tento pre-reconcilizacao por numero + valor + tipo ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If DbSeek( cAgeMov + cCtaMov +cNumMov + cValorMov + cDebCred) .And. !Str(TRB->OK,1) $ "1#3#4"
					nRecno := Recno()
					
					DbGoTo(nRecTrb)
					dbDelete()
					dbGoto(nRecno)
					TRB->VALORSE5 	:= cValorMov
					TRB->NUMSE5	  	:= cNumMov
					TRB->RECSE5		:= nRecSE5	
					TRB->SEQRECON	:= cSeqSE5 	
					TRB->CTASE5		:= cCtaMov
					TRB->AGESE5		:= cAgeMov
					TRB->OK			:= IIf (lReconc,4,3)  	// 3 => Reconc. Chave parcial
																	 	// 4 => Reconc. Anteriomente no SE5
				Else
					dbGoto(nRecno)
				Endif
				DbSetOrder(1)
			Endif				

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Tento pre-reconcilizacao dentro da data + valor + tipo ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("TRB")
			DbSetOrder(3)
			If !Str(TRB->OK,1) $ "1#3#4" .or. lReproc
				If DbSeek(cAgeMov + cCtaMov + cDataMov +  cValorMov + cDebCred) 
			       While !EOF() .And. (cAgeMov + cCtaMov + cDataMov +  cValorMov + cDebCred) ==;
			        TRB->AGEMOV + TRB->CTAMOV + TRB->DATAMOV + TRB->VALORMOV + TRB->DEBCRED
			           If !Str(TRB->OK,1) $ "1#3#4"
			          		nRecno := Recno()
							DbGoTo(nRecTrb)
							dbDelete()
							dbGoto(nRecno)
							TRB->VALORSE5 	:= cValorMov
							TRB->NUMSE5	  	:= cNumMov
							TRB->RECSE5		:= nRecSE5
							TRB->SEQRECON	:= cSeqSE5
							TRB->CTASE5		:= cCtaMov
							TRB->AGESE5		:= cAgeMov
							TRB->OK			:= IIf (lReconc,4,3)  	// 3 => Reconc. Chave parcial ou 4 => Reconc. Anteriomente no SE5
						   Exit
						Endif
					 DbSkip()
					Enddo	   		
				Else
					dbGoto(nRecno)
				Endif
			Endif
			DbSetOrder(1)
			
			dbSelectArea(cAliasTrb)
			dbSkip()
		Enddo	
		If __lDefTop
			(cAliasTrb)->(DbCloseArea())
		Endif

		nTotExt 	:= 0
		nTotSis 	:= 0
		U_xF470ATRB() // calcula coluna extrato banco e siga

		dbSelectArea("TRB")
		dbGoTop()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Faz o calculo automatico de dimensoes de objetos     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSize := MSADVSIZE()
		
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
		oDlg:lMaximized := .T.

		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,30,30,.T.,.T. )
		
		If !lPanelFin

		    DEFINE SBUTTON FROM 10,250 TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oPanel
			DEFINE SBUTTON FROM 10,280 TYPE 2 ACTION (nOpca := 0,oDlg:End()) ENABLE OF oPanel
			DEFINE SBUTTON oBtn FROM 10,310 TYPE 4 ACTION (FA470EFET(oTitulo)) ENABLE PIXEL OF oPanel
			oBtn:cToolTip := STR0036 //"Efetiva Lancto."
			oBtn:cCaption := Substr(STR0036,1,7) //"Efetiva Lancto."
			DEFINE SBUTTON oBtn FROM 10,340 TYPE 11 ACTION (U_XFA470LEG()) ENABLE PIXEL OF oPanel
			oBtn:cToolTip := STR0019  //"Legenda"
			oBtn:cCaption := STR0019  //"Legenda"
			oPanel:Align := CONTROL_ALIGN_BOTTOM

			@010,010 Say "Saldo Banco:   "+TRANSFORM(nTotExt,"@E 999,999,999.99") Size 115,285 Pixel Of oPanel
			@010,150 Say "Saldo Sistema: "+TRANSFORM(nTotSis,"@E 999,999,999.99") Size 115,285 Pixel Of oPanel
			@010,450 Say "Diferença:     "+TRANSFORM(nTotExt-nTotSis,"@E 999,999,999.99") Size 115,285 Pixel Of oPanel

		Endif
	
		@ 01.0,.5 	LISTBOX oTitulo VAR cVarQ FIELDS ;
				 		HEADER "", 	STR0010,;  //"Seq."
										STR0011,;  //"Data"
							 			STR0045,;	//"Agenc.Bco"
										STR0046,; 	//"Conta Bco"
									 	STR0012,;  //"Docto.Bco."
										STR0013,;  //"Valor Extrato"
										STR0014,;  //"Tipo"
										STR0054,;  //"Descrição"
										STR0015,;  //"D/C"
										STR0047,;  //"Agenc.SE5"
										STR0048,;	//"Conta SE5"
										STR0016,;  //"Docto.SE5"
										STR0017,;   //"Valor SE5"
										STR0053 ;	//"Historico Extrato"
						 COLSIZES 12,GetTextWidth(0,"BBB"),;
					 	 				 GetTextWidth(0,"BBBB"),;
										 GetTextWidth(0,"BBB"),;
										 GetTextWidth(0,"BBBB"),;
										 GetTextWidth(0,"BBBBB"),;
										 GetTextWidth(0,"BBBBBB"),;
 										 GetTextWidth(0,"BB"),;
										 GetTextWidth(0,"BBBBBBBBBBB"),;
										 GetTextWidth(0,"BB"),;
										 GetTextWidth(0,"BBBB"),;
										 GetTextWidth(0,"BBBB"),;
										 GetTextWidth(0,"BBBBB"),;
										 GetTextWidth(0,"BBBBBB"),;
										 GetTextWidth(0,"BBBBBBBBBBBBBBBBBB");
		SIZE 345,400 ON DBLCLICK	(FA470marca(oTitulo),oTitulo:Refresh()) NOSCROLL 

		oTitulo:bLine := { || {aCores[TRB->OK],;
										TRB->SEQMOV 	,;
										TRB->DATAMOV	,;
										TRB->AGEMOV		,;
										TRB->CTAMOV		,;
										TRB->NUMMOV		,;
										PADR(TRB->VALORMOV,18)	,;
										TRB->TIPOMOV	,;
										TRB->DESCMOV	,;
										PADC(TRB->DEBCRED,3),;
										TRB->AGESE5		,;
										TRB->CTASE5		,;
										TRB->NUMSE5		,;
										PADR(TRB->VALORSE5,18),;
										TRB->DESCRMOV }}
		oTitulo:Align := CONTROL_ALIGN_ALLCLIENT
	
		If lPanelFin //Chamado pelo Painel Financeiro			
			aButtonTxt := {}
			aAdd(aButtonTxt,{STR0036,STR0036, {|| FA470EFET(oTitulo)}}) //"Efetiva Lancto." 
									
			ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,{||nOpca := 1,oDlg:End()},{||nOpca := 0,oDlg:End()},,aButtonTxt)
			
			cAlias := FinWindow:cAliasFile     
			dbSelectArea(cAlias)					
			FinVisual(cAlias,FinWindow,(cAlias)->(Recno()),.T.)
	   Else
			ACTIVATE MSDIALOG oDlg
      Endif

		If nOpca == 1
			dbSelectArea("TRB")
			dbGoTop()
			While !(TRB->(Eof()))
				nRecSE5 := TRB->RECSE5
				If nRecSe5 > 0
					dbSelectArea("NEWSE5")
					dbGoto(nRecSE5)
					RecLock("NEWSE5")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso j  tenha sido reconciliado no SE5, e tenha sido optado  ³
					//³ por se desreconciliar, grava branco no SE5->E5_RECONC        ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If TRB->OK == 2 .and. !Empty(NEWSE5->E5_RECONC)
						Replace NEWSE5->E5_RECONC  With " "
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava as reconciliacoes totais ou por chave parcial no SE5.    ³
					//³ e caso por chave parcial gravo a possivel nova data E5_DTDISPO ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If STR(TRB->OK,1) $ "1#3"
						cReconAnt := NEWSE5->E5_RECONC 	
						Replace NEWSE5->E5_RECONC  With "x"

						//Verifico atualizacao do saldo conciliado
						DO CASE
							CASE Empty(cReconAnt) .and. !Empty(NEWSE5->E5_RECONC)
								nReconc := 1 	//Se foi reconciliado agora 			
							CASE !Empty(cReconAnt) .and. Empty(NEWSE5->E5_RECONC)
								nReconc := 2 	//Se foi desconciliado agora
							CASE !Empty(cReconAnt) .and. !Empty(NEWSE5->E5_RECONC)
				            nReconc := 3	//Nao foi alterada a situacao anterior, mas ja estava conciliado
			   			CASE Empty(cReconAnt) .and. Empty(NEWSE5->E5_RECONC)		
				            nReconc := 3	//Nao foi alterada a situacao anterior, mas nao estava conciliado
						END CASE				
						//Atualiza saldo conciliado na data antiga
						lAtSalRec1 := IIF(nReconc == 2 .or. nReconc == 3, .T., .F.)
						//Atualiza saldo conciliado na data nova
						lAtSalRec2 := IIF(nReconc != 4, .T., .F.)
						
						//Ponto de entrada para que não se atulize a data de disponibilidade
						//do movimento bancario no sistema.
						If lF470AtuDt
							lAtuDtDisp := ExecBlock("F470ATUDT",.F.,.F.)
						Endif

						If (Ctod(TRB->DATAMOV) # NEWSE5->E5_DTDISPO) .and. lAtuDtDisp
							dOldDispo := NEWSE5->E5_DTDISPO
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
                            //³ Ponto de entrada que possibilita a alteracao ou           ³
                            //³ nao da data da disponibilidade do movimento (E5_DTDISPO)  ³
                            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                            IF ExistBlock("F470ADDM")
                               ExecBlock("F470ADDM",.f.,.f.)
                            Endif
							
							Replace NEWSE5->E5_DTDISPO With Ctod(TRB->DATAMOV)
							If NEWSE5->E5_RECPAG == "P"
								AtuSalBco(NEWSE5->E5_BANCO,NEWSE5->E5_AGENCIA,NEWSE5->E5_CONTA,dOldDispo,NEWSE5->E5_VALOR,"+",lAtSalRec1)
								AtuSalBco(NEWSE5->E5_BANCO,NEWSE5->E5_AGENCIA,NEWSE5->E5_CONTA,NEWSE5->E5_DTDISPO,NEWSE5->E5_VALOR,"-",lAtSalRec2)
							Else
								AtuSalBco(NEWSE5->E5_BANCO,NEWSE5->E5_AGENCIA,NEWSE5->E5_CONTA,dOldDispo,NEWSE5->E5_VALOR,"-",lAtSalRec1)
								AtuSalBco(NEWSE5->E5_BANCO,NEWSE5->E5_AGENCIA,NEWSE5->E5_CONTA,NEWSE5->E5_DTDISPO,NEWSE5->E5_VALOR,"+",lAtSalRec2)
							Endif
						Else
							//Atualiza apenas o saldo reconciliado
							If nReconc == 2	//Desconciliou
								AtuSalBco(NEWSE5->E5_BANCO,NEWSE5->E5_AGENCIA,NEWSE5->E5_CONTA,NEWSE5->E5_DTDISPO,NEWSE5->E5_VALOR,IIF(NEWSE5->E5_RECPAG == "P","+","-"),.T.,.F.)			
							Endif
							If nReconc == 1	//Conciliou
								AtuSalBco(NEWSE5->E5_BANCO,NEWSE5->E5_AGENCIA,NEWSE5->E5_CONTA,NEWSE5->E5_DTDISPO,NEWSE5->E5_VALOR,IIF(NEWSE5->E5_RECPAG == "P","-","+"),.T.,.F.)			
							Endif
						Endif
					Endif
					MsUnlock()
				EndIf	
				dbSelectArea("TRB")
				dbSkip()
				Loop
			Enddo
	     	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
            //³ Ponto de entrada para leitura do arquivo temporário ³
            //³ utilizadona rotina de conciliação bancária          ³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF ExistBlock("F470ATRB")
			    ExecBlock("F470ATRB", .F., .F., {"TRB"} )
			Endif    
		EndIf
	Endif
Endif

oTmpTb:Delete()

///dbSelectArea("TRB")
///Set Filter To
///dbCloseArea()
///Ferase(cArqRec1+ GetDBExtension())
///Ferase(cArqRec1+OrdBagExt())
///Ferase(cArqRec2+OrdBagExt())
///Ferase(cArqRec3+OrdBagExt())
///Ferase(cArqRec4+OrdBagExt())

IF SELECT("NEWSE5") != 0
   dbSelectArea( "NEWSE5" )
   dbCloseArea()
   If !Empty(cIndex)
	   FErase (cIndex+OrdBagExt())
   Endif
ENDIF

dbSelectArea("SE5")
dbSetOrder(1)

If lPanelFin //Chamado pelo Painel Financeiro							
	dbSelectArea(FinWindow:cAliasFile)					
	FinVisual(FinWindow:cAliasFile,FinWindow,(FinWindow:cAliasFile)->(Recno()),.T.)
Endif
Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fA470Par  ³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 03/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Aciona parametros do Programa                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER Function XfA470Par()

Pergunte( "XAFI470" )
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa470ChecF³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 03/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna Expresao para Indice Condicional						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Fa470ChecF() 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Generico																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER Function XFA470ChecF()
Local cFiltro := ""
cFiltro := 'NEWSE5->E5_FILIAL=="'	+xFilial("SE5") 		+'" .And. '
cFiltro += '((DTOS(E5_DTDISPO)>="'	+ DTOS(dDtIni)			+ '".And. '
cFiltro += 'DTOS(E5_DTDISPO)<="'		+ DTOS(dDtFin)			+ '") .OR. '
cFiltro += '(DTOS(E5_DTDISPO)<="'	+ DTOS(mv_par09)		+ '".And. '
cFiltro += 'DTOS(E5_DTDISPO)<="'		+ DTOS(mv_par10)		+ '" .And. '
cFiltro += 'E5_TIPODOC $ IIF(Type("MVCHEQUES")=="C",MVCHEQUES,MVCHEQUE))) .And. '

cFiltro += 'E5_BANCO =="' + mv_par03+'".And. '
cFiltro += '!E5_TIPODOC $ "BA/DC/JR/MT/CM/D2/J2/M2/C2/V2/CP/TL" .And.'
cFiltro += 'E5_SITUACA <> "C" .And. '                                 
cFiltro += 'E5_VALOR <> 0 .And. ' 
cFiltro += '(!E5_MOEDA $ "C1/C2/C3/C4/C5/CH" .OR. (E5_MOEDA $ "C1/C2/C3/C4/C5/CH"  .AND. E5_NUMCHEQ <> " ")) .And. '
cFiltro += '(E5_NUMCHEQ <> "*" .OR. (E5_NUMCHEQ = "*" .AND. E5_RECPAG <> "P"))
Return cFiltro

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³F470CriArq³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 04/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Cria Estrutura do arquivo de trabalho   						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³F470CriArq() 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Generico																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function F470CriArq()
Local aDbStru	:= aTamSX3 := {}
//Arquivo de reconciliacao
aadd(aDbStru,{"SEQMOV    ","C",04,0})
aadd(aDbStru,{"SEQRECON  ","C",04,0})
aadd(aDbStru,{"DATAMOV   ","C",10,0})
aadd(aDbStru,{"AGEMOV    ","C",TamSX3("A6_AGENCIA")[1],0})
aadd(aDbStru,{"CTAMOV    ","C",TamSX3("A6_NUMCON")[1],0})
aadd(aDbStru,{"NUMMOV    ","C",15,0})
aadd(aDbStru,{"VALORMOV  ","C",18,0})
aadd(aDbStru,{"TIPOMOV   ","C",03,0})
aadd(aDbStru,{"DESCMOV   ","C",LEN(SEJ->EJ_DESCR),0})
aadd(aDbStru,{"DEBCRED   ","C",01,0})
aadd(aDbStru,{"DESCRMOV  ","C",TamSX3("E5_HISTOR")[1],0})
aadd(aDbStru,{"AGESE5    ","C",TamSX3("A6_AGENCIA")[1],0})
aadd(aDbStru,{"CTASE5    ","C",TamSX3("A6_NUMCON")[1],0})
aadd(aDbStru,{"NUMSE5    ","C",15,0})
aadd(aDbStru,{"VALORSE5  ","C",18,0})
aadd(aDbStru,{"RECSE5    ","N",09,0})
aadd(aDbStru,{"OK        ","N",01,0})
aadd(aDbStru,{"RECONSE5  ","C",01,0})

///cArqRec1 := CriaTrab(aDbStru, .T. )
///cArqRec2 := Left(CriaTrab(Nil, .F. ),7)+"A"
///cArqRec3 := Left(CriaTrab(Nil, .F. ),7)+"B"
///cArqRec4 := Left(CriaTrab(Nil, .F. ),7)+"C"
///dbUseArea(.T.,,cArqRec1,"TRB",.F.,.F.)
///IndRegua("TRB",cArqRec1,"SEQMOV+DATAMOV",,,STR0007)  //"Selecionando Registros..."
///IndRegua("TRB",cArqRec2,"AGEMOV+CTAMOV+NUMMOV+DATAMOV+VALORMOV+DEBCRED",,,STR0007)  //"Selecionando Registros..."
///IndRegua("TRB",cArqRec3,"AGEMOV+CTAMOV+DATAMOV+VALORMOV+DEBCRED",,,STR0007)  //"Selecionando Registros..."

oTmpTb := FWTemporaryTable():New( "TRB")
oTmpTb:SetFields( aDbStru )
oTmpTb:AddIndex("indice1", {"SEQMOV","DATAMOV"} )
oTmpTb:AddIndex("indice2", {"AGEMOV","CTAMOV","NUMMOV","DATAMOV","VALORMOV","DEBCRED"} )
oTmpTb:AddIndex("indice3", {"AGEMOV","CTAMOV","DATAMOV","VALORMOV","DEBCRED"} )
If mv_par04 # 0 .Or. mv_par05 # 0
	oTmpTb:AddIndex("indice4", {"AGEMOV","CTAMOV","NUMMOV","VALORMOV","DEBCRED"} )
EndIf
oTmpTb:Create()

///If mv_par04 # 0 .Or. mv_par05 # 0
///	IndRegua("TRB",cArqRec4,"AGEMOV+CTAMOV+NUMMOV+VALORMOV+DEBCRED",,,STR0007)  //"Selecionando Registros..."
///	DbClearIndex()
///	DbSetIndex(cArqRec1 + OrdBagExt())
///	DbSetIndex(cArqRec2 + OrdBagExt())
///	DbSetIndex(cArqRec3 + OrdBagExt())
///	DbSetIndex(cArqRec4 + OrdBagExt())
///Else
///	DbClearIndex()
///	DbSetIndex(cArqRec1 + OrdBagExt())
///	DbSetIndex(cArqRec2 + OrdBagExt())
///	DbSetIndex(cArqRec3 + OrdBagExt())
///Endif

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa470Marca³ Autor ³ Mauricio Pequim Jr	  ³ Data ³ 03/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Troca o flag para marcado ou nao,aceitando valor.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fa470Marca																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA470Marca(oTitulo)
Local oDlg1
Local nOpca1 	:= 0
Local lRet		:= .T.
Local nReconc	:= TRB->OK
Local nSequen 	:= 0
Local lIsBanco := .F.
Local cDataRec,cValRec
Local lEfetiva := .F.
Local cRecTRB	
Local lReconc := .F.
Local nTamCta := TAMSX3("A6_NUMCON")[1]
Local nTamAge := TAMSX3("A6_AGENCIA")[1]

If nReconc == 2   // Se n„o reconciliado

	DEFINE MSDIALOG oDlg1 FROM  69,70 TO 160,331 TITLE STR0006 PIXEL   //"Reconciliacao bancaria Automatica"

	@ 0, 2 TO 22, 165 OF oDlg1 PIXEL
	@ 7, 98 MSGET nSequen Picture "9999" VALID (nSequen <= TRB->(LastRec())) .and. (nSequen > 0) SIZE 20, 10 OF oDlg1 PIXEL
	@ 8, 08 SAY  STR0020  SIZE 90, 7 OF oDlg1 PIXEL  //"Sequˆncia a Reconciliar"
	DEFINE SBUTTON FROM 29, 71 TYPE 1 ENABLE ACTION (nOpca1:=1,If((nSequen <= TRB->(LastRec())) .and. (nSequen > 0),oDLg1:End(),nOpca1:=0)) OF oDlg1
	DEFINE SBUTTON FROM 29, 99 TYPE 2 ENABLE ACTION (oDlg1:End()) OF oDlg1

	ACTIVATE MSDIALOG oDlg1 CENTERED

	IF	nOpca1 == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se a linha clicada ‚ Mov. Banco ou Sistema			  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRecOrig := Val(TRB->SEQMOV)
		cDCRec	:= TRB->DEBCRED
		cValRec	:= IIF(!Empty(TRB->VALORMOV), TRB->VALORMOV , TRB->VALORSE5)
		cDataRec := TRB->DATAMOV
		cNumRec	:= IIF(!Empty(TRB->VALORMOV), TRB->NUMMOV , TRB->NUMSE5)
		cAgeRet	:= IIF(!Empty(TRB->VALORMOV), TRB->AGEMOV , TRB->AGESE5)
		cCtaRet	:= IIF(!Empty(TRB->VALORMOV), TRB->CTAMOV , TRB->CTASE5)
		nRecSE5	:= TRB->RECSE5
		cSeqSE5	:= TRB->SEQRECON
		lReconc	:= IIF (!Empty(TRB->RECONSE5),.T.,.F.)
		If !Empty(TRB->VALORMOV)
			lIsBanco := .T.
		Endif		
		dbSelectArea("TRB")
		dbGoto(nSequen)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica tentativa de reconciliar Banco x Banco ou SE5 x SE5 ³
		//³ ou Lancamento de Credito x Lancamento D‚bito ou vice-versa   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ( 	(!Empty(TRB->VALORMOV) .and. Empty(TRB->VALORSE5) .and. lIsBanco) .or. ;
				(Empty(TRB->VALORMOV) .and. !Empty(TRB->VALORSE5) .and. !lIsBanco) .or. ;
				TRB->DEBCRED != cDCRec )
			Help(" ",1,"NORECONC")
			dbGoto(nRecOrig)
			oTitulo:Refresh()
			Return .F.
		Endif
		If (IIf(lIsBanco , TRB->VALORSE5 != cValRec , TRB->VALORMOV != cValRec))
			Help(" ",1,"NORECONC")
			oTitulo:Refresh()
			Return .F.
		Endif

		If !Empty(TRB->VALORMOV) .and. Empty(TRB->VALORSE5) .and. !lIsBanco
			DbSelectArea("TRB")
			TRB->VALORSE5 	:= cValRec
			TRB->NUMSE5		:= cNumRec
			TRB->RECSE5		:= nRecSE5
			TRB->SEQRECON	:= cSeqSE5
			TRB->CTASE5		:= cCtaRet
			TRB->AGESE5		:= cAgeRet
			TRB->OK			:= IIF (lReconc,4,1)
			dbGoTo(nRecOrig)
			dbDelete()
			oTitulo:Refresh()
		Endif
		If Empty(TRB->VALORMOV) .and. !Empty(TRB->VALORSE5) .and. lIsBanco
			cValRec := 	TRB->VALORSE5
			nRecSE5 :=  TRB->RECSE5
			cDBSE5  :=	TRB->DEBCRED
			cSeqSE5 :=	TRB->SEQMOV
			cDocSE5 :=	TRB->NUMSE5
			cAgeSE5 :=  TRB->AGESE5
			cCtaSE5 :=  TRB->CTASE5
			DbSelectArea("TRB")
			dbDelete()
			dbGoTo(nRecOrig)
			TRB->VALORSE5 	:= cValRec
			TRB->RECSE5		:= nRecSE5
			TRB->OK			:= IIF (lReconc,4,1)
			TRB->SEQRECON	:= cSeqSE5
			TRB->NUMSE5		:= cDocSE5
			TRB->CTASE5		:= cCtaSE5
			TRB->AGESE5		:= cAgeSE5
			oTitulo:Refresh()
		Endif
		dbGoTo(nRecOrig)
	Endif
Else
	lEfetiva := .F.
	DEFINE MSDIALOG oDlg1 FROM  69,70 TO 160,331 TITLE  STR0006 PIXEL  //"Reconcilia‡„o Banc ria Autom tica"
	@  0, 2 TO 22, 128 OF oDlg1	PIXEL
	@  7.5,  9 SAY  STR0021  SIZE 115, 7 OF oDlg1 PIXEL  //"Esta movimenta‡„o j  se encontra reconciliada"
	@ 14  ,  9 SAY  STR0022  SIZE 100, 7 OF oDlg1 PIXEL  //"             Deseja cancelar ?               "
	DEFINE SBUTTON FROM 29, 71 TYPE 1 ENABLE ACTION (nOpca1:=1,oDlg1:End()) OF oDlg1
	DEFINE SBUTTON FROM 29, 99 TYPE 2 ENABLE ACTION (oDlg1:End()) OF oDlg1

	ACTIVATE MSDIALOG oDlg1 CENTERED

	IF	nOpca1 == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cancela reconcilia‡Æo                               			  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nRecOrig := VAL(TRB->SEQMOV)
		nSeqSE5	:= VAL(TRB->SEQRECON)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso a reconcilia‡„o tenha sido feita via Efetivacao de mo-  ³
		//³ vimentacao, deve ser criado no TRB o registro com os dados   ³
		//³ da movimentacao no SE5.                                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("TRB")
		If Empty(TRB->SEQRECON)
			cValRec := 	TRB->VALORSE5
			nRecSE5 :=  TRB->RECSE5
			cDBSE5  :=	TRB->DEBCRED
			cDocSE5 :=	TRB->NUMSE5
			cDataRec := TRB->DATAMOV
			cAgeSE5	:= TRB->AGESE5
			cCtaSE5	:= TRB->CTASE5
			lEfetiva:=  .T.
		Endif
		TRB->VALORSE5 	:= Space(19)
		TRB->NUMSE5		:= Space(6)
		TRB->RECSE5		:= 0
		TRB->AGESE5		:= Space(nTamAge)
		TRB->CTASE5		:= Space(nTamCta)	
		TRB->SEQRECON	:= Space(4)
		TRB->OK			:= 2
		SET DELETED OFF
		If !lEfetiva
			dbGoTo(nSeqSE5)
			dbRecall()
			TRB->OK := 2
		Else
			DbSelectArea("TRB")
			DbAppend()
			cRecTRB 			:= STR(TRB->(Recno()))
			TRB->SEQMOV 	:= SUBSTR(cRecTRB,-4)
			TRB->DATAMOV	:= cDataRec
			TRB->VALORSE5 	:= cValRec
			TRB->RECSE5		:= nRecSE5
			TRB->NUMSE5		:= cDocSE5						
			TRB->DEBCRED 	:= cDBSE5
			TRB->AGESE5		:= cAgeSE5						
			TRB->CTASE5		:= cCtaSE5						
			TRB->OK			:= 2
		Endif
		SET DELETED ON
		dbGoto(nRecOrig)
	Endif
Endif
oTitulo:Refresh()
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa470Leg	³ Autor ³ Mauricio Pequim Jr	  ³ Data ³ 03/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra Legenda da Reconcilia‡Æo                   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fa470Leg 																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER Function xFA470Leg()
Local oDlg2
Local lRet		:= .T.

DEFINE MSDIALOG oDlg2 FROM  69,70 TO 165,331 TITLE  STR0026 PIXEL  //"Legenda - Reconcilia‡„o Autom tica"
@ 05 , 5 BITMAP NAME "BR_VERDE" 		SIZE 8,8 of Odlg2 PIXEL
@ 15 , 5 BITMAP NAME "BR_AMARELO" 	SIZE 8,8 of Odlg2 PIXEL
@ 25 , 5 BITMAP NAME "BR_CINZA" 		SIZE 8,8 of Odlg2 PIXEL
@ 35 , 5 BITMAP NAME "DISABLE" 		SIZE 8,8 of Odlg2 PIXEL
@ 05 , 19 SAY  STR0023  	SIZE 115, 7 OF oDlg2 PIXEL  //"  Reconciliado"
@ 15 , 19 SAY  STR0024  	SIZE 100, 7 OF oDlg2 PIXEL  //"  Reconciliado Parcial"
@ 25 , 19 SAY  STR0035  	SIZE 100, 7 OF oDlg2 PIXEL  //"  Reconciliado Anteriormente"
@ 35 , 19 SAY  STR0025  	SIZE 100, 7 OF oDlg2 PIXEL  //"  N„o Reconciliado"
DEFINE SBUTTON FROM 20, 100 TYPE 1 ENABLE ACTION (oDlg2:End()) OF oDlg2
ACTIVATE MSDIALOG oDlg2 CENTERED
Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa470EFET	³ Autor ³ Mauricio Pequim Jr	  ³ Data ³ 07/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetiva lancamento do extrato no SE5              			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fa470Efet																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA470Efet(oTitulo)
Local cRecPagE5
Local oDlg3
Local oDlg4
Local nOpcaE 		:= 0
Local nOpcaN		:= 0
Local lAchou		:= .F.
Local cValorSE5		:= ""
Local cNaturEfet	:= CRIAVAR("ED_CODIGO")
Local cCCD			:= CRIAVAR("E5_CCD")	// Centro Custo Debito
Local cCCC			:= CRIAVAR("E5_CCC") // Centro Custo Credito
Local cItemD		:= CRIAVAR("E5_ITEMD")  //Item contabil Debito
Local cItemC		:= CRIAVAR("E5_ITEMC")  //Item contabil Credito
Local cClVlDb		:= CRIAVAR("E5_CLVLDB")  //Classe de Valor Debito
Local cClVlCr		:= CRIAVAR("E5_CLVLCR")  //Classe de Valor Credito
Local cCDeb			:= CRIAVAR("E5_DEBITO")	// Conta Contábil Debito
Local cCCrd			:= CRIAVAR("E5_CREDITO") // Conta Contábil Credito
Local cBenef		:= CRIAVAR("E5_BENEF")
Local cHistor		:= TRB->DESCRMOV // Historico do movimento
Local lIsCTB		:= IIF(CtbInUse(),.T.,.F.)
Local lConsulta 	:= IIF(CtbInUse(),"CTT","SI3")
Local lConsult2 	:= IIF(CtbInUse(),"CT1","SI1")
Local oBtn			:= Nil
Local lPmsInt		:=(Iif( FindFunction("IsIntegTop"),IsIntegTop(,.T.),GetNewPar("MV_RMCOLIG",0) > 0))
Local cTpMov	    := CRIAVAR("ZK_COD") // BK

Private bPMSDlgMB	:= {||PmsDlgMB(3, NEWSE5->E5_PROJPMS, NEWSE5->E5_HISTOR, NEWSE5->E5_RECPAG)}
Private aRatAJE		:= {}

If IntePms().AND. !lPmsInt
	_SetOwnerPrvt("E5_VALOR", Val(StrTran(StrTran(TRB->VALORMOV, ",", ""), ".", "")) / 100)
EndIf

If !(STR(TRB->OK,1) $ "1#3#4") .and. !Empty(TRB->VALORMOV)
	dbSelectArea("NEWSE5")
	IF	dbSeek (xFilial("SE5")+DTOS(CTOD(TRB->DATAMOV,"ddmmyy")))
		While !EOF() .and. DTOS(NEWSE5->E5_DTDISPO) == DTOS(CTOD(TRB->DATAMOV,"ddmmyy"))
			cRecPagE5 := IIF(NEWSE5->E5_RECPAG == "R", "C","D")
			//************************************************************
			// Esta validação estava impedindo a conciliação             *
			// quando o lançamento tinha na mesma data uma movimentaçao  *
			// de cheque. A validação foi alterada para so bloqueio se o *
			// Tipo do movimento for de cheque tambem.                   *
			//************************************************************
			IF !Empty(TRB->NUMMOV) .and. TRB->TIPOMOV $ "CHQ" .and. NEWSE5->E5_NUMCHEQ == TRB->NUMMOV .and. cRecPagE5 == TRB->DEBCRED
				Help(" ",1,"A470EXIST")
				lAchou := .T.
				Exit
			Endif
			cValorSE5 := Transform(NEWSE5->E5_VALOR,"@E 999,999,999,999.99")
			If cValorSE5 == TRB->VALORMOV .and. ;
					Empty(NEWSE5->E5_NUMCHEQ) .and. cRecPagE5 == TRB->DEBCRED

				DEFINE MSDIALOG oDlg3 FROM  69,90 TO 220,400 TITLE  STR0027 PIXEL  //"Efetiva‡„o de Lan‡amento no SE5"			
				@ 00 , 03 TO 55, 152 OF oDlg4 PIXEL
				@ 10 , 10 SAY  STR0028  SIZE 140, 7 OF oDlg3 PIXEL  //"Existe lan‡amento semelhante em Data, Valor e Carteira."
				@ 20 , 10 SAY  STR0029  SIZE 140, 7 OF oDlg3 PIXEL  //"no seu arquivo de movimentos banc rios.	Em caso de     "
				@ 30 , 10 SAY  STR0030  SIZE 140, 7 OF oDlg3 PIXEL  //"d£vida, n„o efetive o lan‡amento, pois poder  gerar    "
				@ 40 , 10 SAY  STR0031  SIZE 140, 7 OF oDlg3 PIXEL  //"duplicidade. Deseja efetivar este lan‡amento ?			"
				DEFINE SBUTTON FROM 60, 50 TYPE 1 ENABLE ACTION (nOpcaE:=1,oDlg3:End()) OF oDlg3
				DEFINE SBUTTON FROM 60, 80 TYPE 2 ENABLE ACTION (nOpcaE:=2,oDlg3:End()) OF oDlg3
	
				ACTIVATE MSDIALOG oDlg3 CENTERED

				If nOpcaE == 1
					lAchou := .F.
				Else
					lAchou := .T.
				Endif
				Exit
			Endif
			NEWSE5->(dbSkip())
		Enddo
	Endif
	If !lAchou
		cRecPag := IIF(TRB->DEBCRED == "D", "P","R")
		nOpcaN := 0
		If mv_par11 == 1  //Mostra tela da efetivação do movimento bancário
			If lIsCtb
				DEFINE MSDIALOG oDlg4 FROM  69,70 TO 372,400 TITLE STR0006 PIXEL	//"Reconcilia‡„o Banc ria Autom tica"
				@ 0, 2 TO 150, 133 OF oDlg4 PIXEL
			Else
				DEFINE MSDIALOG oDlg4 FROM  69,70 TO 267,400 TITLE STR0006 PIXEL	//"Reconcilia‡„o Banc ria Autom tica"
				@ 0, 2 TO 97, 133 OF oDlg4 PIXEL
			Endif
	
			@ 07, 08 SAY  "Tipo Mov"  SIZE 80, 7 OF oDlg4 PIXEL  //"Tipo de Movimento Bancario - BK"
			@ 08, 80 MSGET cTpMov  F3 "SZK" VALID (!Empty(cTpMov) .and. ExistCpo("SZK",cRecPag+cTpMov) .AND. FA470TpMov(@cTpMov,@cBenef,@cHistor,@cCCD,@cCDeb)) SIZE 50, 10 OF oDlg4 PIXEL HASBUTTON

		
			@ 20, 08 SAY "Beneficiario" SIZE 30, 7 OF oDlg4 PIXEL  //"Beneficiario"
			@ 21, 40 MSGET cBenef SIZE 90, 10 VALID (!Empty(cBenef))  OF oDlg4 PIXEL PICTURE "@S30"

			@ 33, 08 SAY STR0052 SIZE 30, 7 OF oDlg4 PIXEL  //"Historico"
			@ 34, 40 MSGET cHistor SIZE 90, 10 VALID (!Empty(cHistor))  OF oDlg4 PIXEL PICTURE "@S40"
	
			@ 46, 08 SAY  STR0043  SIZE 80, 7 OF oDlg4 PIXEL  //"Conta Debito"
			@ 47, 80 MSGET cCDeb  F3 lConsult2 VALID (Empty(cCDeb) .or.CTB105CTA(cCDeb)) When IIF(cRecPag=='P',.T.,.F.) SIZE 50, 10 OF oDlg4 PIXEL HASBUTTON
			@ 59, 08 SAY  STR0044  SIZE 80, 7 OF oDlg4 PIXEL  //"Conta Credito"
			@ 60, 80 MSGET cCCrd  F3 lConsult2 VALID (Empty(cCCrd) .or.CTB105CTA(cCCrd)) When IIF(cRecPag=='R',.T.,.F.) SIZE 50, 10 OF oDlg4 PIXEL HASBUTTON
	
			@ 72, 08 SAY  STR0037  SIZE 80, 7 OF oDlg4 PIXEL  //"Centro Custo Debito"
			@ 73, 80 MSGET cCCD  F3 lConsulta VALID (Empty(cCCD) .or. CTB105CC(cCCD)) When IIF(cRecPag=='P',.T.,.F.) SIZE 50, 10 OF oDlg4 PIXEL HASBUTTON
			@ 85, 08 SAY  STR0038  SIZE 80, 7 OF oDlg4 PIXEL  //"Centro Custo Credito"
			@ 86, 80 MSGET cCCC  F3 lConsulta VALID (Empty(cCCC) .or. CTB105CC(cCCC)) When IIF(cRecPag=='R',.T.,.F.) SIZE 50, 10 OF oDlg4 PIXEL HASBUTTON

			@ 98, 08 SAY  STR0032  SIZE 80, 7 OF oDlg4 PIXEL  //"Natureza do Lançamento"
			@ 99, 80 MSGET cNaturEfet  F3 "SED" VALID ((Empty(cNaturEfet) .or. ExistCpo("SED",cNaturEfet)) .AND. ;
					FA470NATUR(cNaturEfet, @cCDeb,@cCCrd,@cCCD,@cCCC, lIsCtb, @cItemD,@cItemC,@cClVlDb,@cClVlCr) ) SIZE 50, 10 OF oDlg4 PIXEL HASBUTTON
	
			If .F. //lIsCtb
				@111, 08 SAY  STR0039  SIZE 80, 7 OF oDlg4 PIXEL  //"Item Contabil Debito"
				@112, 80 MSGET cItemD  F3 "CTD" VALID (Empty(cItemD) .or. CTB105ITEM(cItemD)) SIZE 50, 10 OF oDlg4 PIXEL HASBUTTON
				@124, 08 SAY  STR0040  SIZE 80, 7 OF oDlg4 PIXEL  //"Item Contabil Credito"
				@125, 80 MSGET cItemC  F3 "CTD" VALID (Empty(cItemC) .or. CTB105ITEM(cItemC)) SIZE 50, 10 OF oDlg4 PIXEL HASBUTTON
	
				@137, 08 SAY  STR0041  SIZE 80, 7 OF oDlg4 PIXEL  //"Classe Valor Debito"
				@138, 80 MSGET cClVlDb F3 "CTH" VALID (Empty(cClVlDb) .or. CTB105CLVL(cClVlDb)) SIZE 50, 10 OF oDlg4 PIXEL HASBUTTON
				@150, 08 SAY  STR0042  SIZE 80, 7 OF oDlg4 PIXEL  //"Classe Valor Credito"
				@151, 80 MSGET cClVlCr F3 "CTH" VALID (Empty(cClVlCr) .or. CTB105CLVL(cClVlCr)) SIZE 50, 10 OF oDlg4 PIXEL HASBUTTON
			Endif
			DEFINE SBUTTON FROM 07, 135 TYPE 1 ENABLE ACTION (nOpcaN:=1,If((!Empty(cTpMov) .and. ExistCpo("SZK",cRecPag+cTpMov)),oDlg4:End(),nOpcaN:=0)) OF oDlg4
			DEFINE SBUTTON FROM 20, 135 TYPE 2 ENABLE ACTION (nOpcaN:=2,oDlg4:End()) OF oDlg4
	
			If IntePMS()
				@ 033, 135 Button oBtn Prompt "PMS" Size 30, 11 FONT oDlg4:oFont Action Eval(bPmsDlgMB) Of oDlg4 Pixel
				oBtn:SetFocus()
			EndIf
	
			ACTIVATE MSDIALOG oDlg4 CENTERED
		Else
			//Nao mostra a tela de dados para o movimento bancario
			nOpcaN := 1		
		Endif

		If nOpcaN == 1 .And. FA470OK()
			FA470GrvEf(cTpMov,cNaturEfet,cCCC,cCCD,cItemD,cItemC,cClVlDb,cClVlCr,cCCrd,cCDeb,cBenef,cHistor)
			If IntePMS()
				PmsWriteMB(1, "SE5")							
			EndIf
			oTitulo:Refresh()
		Endif
	Endif
Else
	Help(" ",1,"A470JA_REC")
Endif		
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa470GrvEf³ Autor ³ Mauricio Pequim Jr	  ³ Data ³ 03/08/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava Efetivacao                                  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fa470GrvEf()															  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA470GrvEf(cTpMov,cNaturEfet,cCCC,cCCD,cItemD,cItemC,cClVlDb,cClVlCr,cCCrd,cCDeb,cBenef,cHistor)

Local cValorMov	:= ""
Local aAreaSE5	:= {}
Local lContab	:= .F.
Local nRecno	:= 0
Local aArea		:= {}
Local lRet		:= .T.
Local lAtuSldNat := FindFunction("AtuSldNat") .AND. AliasInDic("FIV") .AND. AliasInDic("FIW")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transforma TRB->VALORMOV (em formato europeu) para formato Americano  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cValorMov := ConValor(TRB->VALORMOV,18)

//Valida se existe Banco Agencia e Conta
//Posiciono o Banco para a contabilizacao
SA6->(DBSetOrder(1))
If !SA6->(MsSeek(xFilial("SA6")+mv_par03+TRB->AGEMOV+TRB->CTAMOV)) 
	IF !MsgYesNo(STR0055+mv_par03+"-"+TRB->AGEMOV+"-"+TRB->CTAMOV+") "+; //"A conta corrente da efetivação ("
					 STR0056+chr(10)+;  //"não existe no seu cadastro de bancos. Caso prossiga a conta será criada no cadastro de bancos. "
					 STR0057,STR0034) //" Prosseguir?"###"Atenção"
		lRet := .F.
	Endif		
Endif 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava Movimentacao da efetivacao no SE5.                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRet
	RecLock("NEWSE5",.T.)
	NEWSE5->E5_FILIAL	:= xFilial("SE5")
	NEWSE5->E5_BANCO	:= mv_par03
	NEWSE5->E5_AGENCIA	:= TRB->AGEMOV
	NEWSE5->E5_CONTA	:= TRB->CTAMOV
	NEWSE5->E5_DATA		:= CTOD(TRB->DATAMOV,"ddmmyy")
	NEWSE5->E5_DTDISPO	:= CTOD(TRB->DATAMOV,"ddmmyy")
	NEWSE5->E5_VENCTO	:= CTOD(TRB->DATAMOV,"ddmmyy")
	NEWSE5->E5_DTDIGIT	:= CTOD(TRB->DATAMOV,"ddmmyy")
 //	NEWSE5->E5_XXTPMOV  := cTpMov
	NEWSE5->E5_BENEF	:= ALLTRIM(cBenef)
	NEWSE5->E5_HISTOR 	:= IIF(Empty(cHistor),TRB->DESCRMOV,cHistor)
	NEWSE5->E5_VALOR	:= Val(cValorMov)
	NEWSE5->E5_NATUREZ	:= cNaturEfet
	NEWSE5->E5_MOEDA  	:= IIF(TRB->TIPOMOV=="CHQ","C1","M1")
	NEWSE5->E5_RECPAG 	:= IIF(TRB->DEBCRED=="D","P","R")
	NEWSE5->E5_CCC		:= cCCC
	NEWSE5->E5_CCD		:= cCCD
	NEWSE5->E5_CREDITO	:= cCCrd
	NEWSE5->E5_DEBITO	:= cCDeb
	If CtbInUse()
		NEWSE5->E5_ITEMD	:= cItemD
		NEWSE5->E5_ITEMC	:= cItemC
		NEWSE5->E5_CLVLDB	:= cClVlDb
		NEWSE5->E5_CLVLCR	:= cClVlCr
	Endif
	nRecno:=NEWSE5->(Recno()) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o movimento ‚ referente a um cheque e grava nro do cheque.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF TRB->TIPOMOV $ "CHQ"  
		NEWSE5->E5_NUMCHEQ	:= TRB->NUMMOV
	Endif
	MsUnlock()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza saldo bancario quando da efetivação de movimento             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AtuSalBco(mv_par03,NEWSE5->E5_AGENCIA,NEWSE5->E5_CONTA,NEWSE5->E5_DATA,NEWSE5->E5_VALOR,iif(NEWSE5->E5_RECPAG == "R","+","-"))
	
	If lAtuSldNat
		If lAtuSldNat
			AtuSldNat(NEWSE5->E5_NATUREZ, NEWSE5->E5_DATA, "01", "3", NEWSE5->E5_RECPAG, NEWSE5->E5_VALOR, 0, "+",,FunName(),"NEWSE5", NEWSE5->(Recno()),0)
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava dados da Reconciliacao no TRB											  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("TRB")
	Replace TRB->RECSE5		With NEWSE5->(RECNO())
	Replace TRB->OK 		With 1
	Replace TRB->VALORSE5	With Transform(NEWSE5->E5_VALOR,"@E 999,999,999,999.99")
	Replace TRB->NUMSE5		With NEWSE5->E5_NUMCHEQ
	Replace TRB->AGESE5		With NEWSE5->E5_AGENCIA
	Replace TRB->CTASE5		With NEWSE5->E5_CONTA
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se gera lancamento na contabilidade.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If NEWSE5->E5_RECPAG =="R"
		cPadrao:= "563"
		If VerPadrao(cPadrao)
			lContab:=.T.
		EndIf
	Else 
		cPadrao:= "562"
		If VerPadrao(cPadrao)
			lContab:=.T.
		EndIf
	EndIf
	                
	If lContab .and. lGeraLanc
		//Posiciono o Banco para a contabilizacao
		SA6->(DBSetOrder(1))
		SA6->(MSSeek(xFilial("SA6")+mv_par03+NEWSE5->E5_AGENCIA+NEWSE5->E5_CONTA))
		
		aAreaSE5:=SE5->(GetArea())
		aArea:=GetArea()
		DbSelectArea("SE5")
		DbGoTo(nRecno)
		If nHdlPrv <= 0 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializa Lancamento Contabil                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nHdlPrv := HeadProva( cLote,;
				                      "FINA470" /*cPrograma*/,;
				                      Substr( cUsuario, 7, 6 ),;
				                      @cArquivo )
			
	   	LoteCont("FIN")
		Endif 
		If nHdlPrv > 0 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Prepara Lancamento Contabil                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil 
					aAdd( aFlagCTB, {"E5_LA", "S", "NEWSE5", NEWSE5->( Recno() ), 0, 0, 0} )
				Endif
				nTotal += DetProva( nHdlPrv,;
				                    cPadrao,;
				                    "FINA470" /*cPrograma*/,;
				                    cLote,;
				                    /*nLinha*/,;
				                    /*lExecuta*/,;
				                    /*cCriterio*/,;
				                    /*lRateio*/,;
				                    /*cChaveBusca*/,;
				                    /*aCT5*/,;
				                    /*lPosiciona*/,;
				                    @aFlagCTB,;
				                    /*aTabRecOri*/,;
				                    /*aDadosProva*/ )
		Endif
		SE5->(RestArea(aAreaSE5))
		RestArea(aArea)
		If !lUsaFlag
			RecLock("NEWSE5",.F.)      
			NEWSE5->E5_LA := "S"
			MsUnlock()
		Endif
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada apos gravacao do TRB e do SE5      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF ExistBlock("F470GRVEF")
		ExecBlock("F470GRVEF",.f.,.f.,{"NEWSE5"})
	Endif
Endif	
Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa470OK	³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 13/10/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Confirma ou nao a efetivacao.                    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fa470OK																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA470OK()
Return (MsgYesNo( STR0033, STR0034))  //"Confirma Efetiva‡„o ?"###"Aten‡„o"



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Chk470File³ Autor ³ Mauricio Pequim Jr    ³ Data ³ 24/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Checa se arquivo de TB j  foi processado anteriormente		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³Chk470File()  															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Fina470																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user Function xChk470File(lReproc)
Local cFile := "CB"+cNumEmp+".VRF"
Local lRet	:= .F.
Local aFiles:= {}
Local cString
Local nTam
Local nHdlFile

If !FILE(cFile)
	nHdlFile := fCreate(cFile)
ELSE
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tenta abrir o arquivo em modo exclusivo e Leitura/Gravacao ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (nHdlFile := fOpen(cFile,FO_READWRITE+FO_EXCLUSIVE))==-1 .AND. ;
			MsgYesNo( STR0050+cNumEmp+STR0051, STR0034 )
	End
Endif

If nHdlFile > 0

	nTam := TamSx1("XAFI470","01")[1] // Tamanho do parametro
	xBuffer := SPACE(nTam)
	// Le o arquivo e adiciona na matriz
	While fReadLn(nHdlFile,@xBuffer,nTam) 
		Aadd(aFiles, Trim(xBuffer))
	Enddo	

	If ASCAN(aFiles,Trim(MV_PAR01)) > 0
		lRet := MSGYESNO(STR0049,STR0034)		//"Arquivo de Conciliação já processado anteriormente. Deseja proseguir ?"###"Atenção"
		If lRet
			lReproc := .T.
		Endif
	Else
		fSeek(nHdlFile,0,2) // Posiciona no final do arquivo
		cString := Alltrim(mv_par01)+Chr(13)+Chr(10)
		fWrite(nHdlFile,cString)	// Grava nome do arquivo a ser processado
		lRet := .T.
	endif	
	fClose (nHdlFile)
Else
   Help(" ", 1, "CHK200ERRO") // Erro na leitura do arquivo de entrada
EndIf	
Return lRet

//Trans facilitador de lancamento banco - BK
Static Function FA470TpMov(cTpMov,cBenef,cHistor,cCCrd,cCCD)

	SZK->(DBSetOrder(1))
	SZK->(MSSeek(xFilial("SZK")+cRecPag+cTpMov))
	cBENEF 	:= SZK->ZK_BENEF                         
	cHistor	:= SZK->ZK_HISTOR
	cCCD	:= SZK->ZK_DEBITO
	cCCrd 	:= SZK->ZK_CREDITO
Return (.T.)


Static Function FA470NATUR(cNatureza, cCDeb, cCCrd, cCCD, cCCC, lIsCtb,cItemD, cItemC, cClVlDb, cClVlCr)
	Local aContabil := {}
	If ExistBlock("FA470NAT")
		aContabil := ExecBlock("FA470NAT",.F.,.F.,cNatureza)
		If Len(aContabil) == 8
			cCDeb		:= aContabil[1]
			cCCrd		:= aContabil[2]
			cCCD		:= aContabil[3]
			cCCC		:= aContabil[4]
			If lIsCtb
				cItemD	:= aContabil[5]
				cItemC	:= aContabil[6]
				cClVlDb	:= aContabil[7]
				cClVlCr	:= aContabil[8]
			EndIf
		EndIf		
	EndIf
Return (.T.)




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³21/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados 		  ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/     
Static Function MenuDef()
Local aRotina:= { { STR0001 ,"U_XfA470Par" , 0 , 1},;  // "Parƒmetros"
                  { STR0002 ,"AxVisual" , 0 , 2},;  // "Visualizar"
                  { STR0003 ,"U_XfA470Gera", 0 , 3} }  // "Reconcilia‡„o"
Return(aRotina)
                                                                             

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FinA470T   ³ Autor ³ Marcelo Celi Marques ³ Data ³ 04.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada semi-automatica utilizado pelo gestor financeiro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA470                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
USER Function XFinA470(aParam)
	cRotinaExec := "FINA470"
	ReCreateBrow("SE5",FinWindow)      		
	FinA470(aParam[1])
	ReCreateBrow("SE5",FinWindow)      	
	dbSelectArea("SE5")
	
	INCLUI := .F.
	ALTERA := .F.

Return .T.
*/



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A910VLDBCO ºAutor  ³ Totvs S/A			 º Data ³  01/09/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida o banco, agencia e conta                              º±±
±±º          ³Funcao retirada do FINA910A                                  º±±  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A470VldBco( cBanco , cAgencia , cConta )
Local aAreaATU := GetArea()
Local cFilSA6  := xFilial( 'SA6' )
Local nSubAge  := 0
Local nSubCon  := 0
Local lStop    := .F.

If !SA6->( MsSeek( cFilSA6 + cBanco + cAgencia + cConta ) )
	SA6->( MsSeek( cFilSA6 + cBanco ) )

	While !SA6->( Eof() ) .And. cFilSA6 == SA6->A6_FILIAL .And. cBanco == SA6->A6_COD .And. !lStop
		nSubAge := At( Alltrim( SA6->A6_AGENCIA ) , cAgencia )
		nSubCon := At( Alltrim( SA6->A6_NUMCON  ) , cConta   )
		If nSubAge > 0 .And. nSubCon > 0
			If ( SubStr( cAgencia , 1 , nSubAge-1 ) == StrZero( 0 , nSubAge-1 ) .Or. ;// Valida 0 a esquerda: Agencia 
			     Alltrim( SA6->A6_AGENCIA ) == AllTrim( cAgencia ) ) ;
			   .And. ;
			   ( SubStr( cConta   , 1 , nSubCon-1 ) == StrZero( 0 , nSubCon-1 ) .Or. ;// Valida 0 a esquerda: Conta Corrente
			     Alltrim( SA6->A6_NUMCON  ) == AllTrim( cConta   ) )          
				cAgencia := SA6->A6_AGENCIA
				cConta   := SA6->A6_NUMCON
				lStop    := .T.			
			EndIf
		EndIf
		SA6->( DbSkip() )
	EndDo
EndIf

RestArea( aAreaATU )
Return



USER FUNCTION xF470ATRB()
Local nExtrato := 0
Local nSistema := 0

	dbSelectArea("TRB")
	dbGoTop()
   	While !(TRB->(Eof()))
        cExtrato := TRB->VALORMOV
		cSistema := TRB->VALORSE5 
		cExtrato := STRTRAN(cExtrato,'.','')
		cExtrato := STRTRAN(cExtrato,',','.')
		cSistema := STRTRAN(cSistema,'.','')
		cSistema := STRTRAN(cSistema,',','.')
		IF TRB->DEBCRED == "D"
        	nExtrato -= VAL(cExtrato)
			nSistema -= VAL(cSistema)
		ELSE
        	nExtrato += VAL(cExtrato)
			nSistema += VAL(cSistema)
		ENDIF
		dbSelectArea("TRB")
		dbSkip()
	Enddo

	nTotExt 	:= nExtrato
	nTotSis 	:= nSistema

Return NIL

    



Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}  

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Arquivo de Entrada ?" 		,"Archivo de Entrada ?"			,"Input File ?"					,"mv_ch1","C",99,0,0,"G","","mv_par01","","","","C:\TEMP\EXTRATO_BRASIL.TXT","","","","","","","","","","","","","","","","","","","","","","S","","","",""})
AADD(aRegistros,{cPerg,"02","Arquivo de Config ?"  		,"Archivo de Config. ?"			,"Setup File ?"					,"mv_ch2","C",99,0,0,"G","","mv_par02","","","","BRASIL.REC","","","","","","","","","","","","","","","","","","","","","","S","","","",""})
AADD(aRegistros,{cPerg,"03","Codigo do Banco ?"			,"Codigo del Banco ?"			,"Bank Code ?"					,"mv_ch3","C",03,0,0,"G","","mv_par03","","","","001","","","","","","","","","","","","","","","","","","","","","SA6","S","007","","",""})
AADD(aRegistros,{cPerg,"04","Dias a avancar ?"			,"Dias a avanzar ?"				,"Days forward ?"				,"MV_CH4","N",02,0,0,"G","","mv_par04","","","","0","","","","","","","","","","","","","","","","","","","","","","S","","","",""})
AADD(aRegistros,{cPerg,"05","Dias a retroceder ?"		,"Dias a retroceder ?"			,"Days backward ?"				,"MV_CH5","N",02,0,0,"G","","mv_par05","","","","0","","","","","","","","","","","","","","","","","","","","","","S","","","",""})
AADD(aRegistros,{cPerg,"06","Aglut. Lancamentos ?"		,"Agrup. Asientos ?"			,"Group entries ?"	   	 		,"MV_CH6","N",01,0,2,"C","","mv_par06","Sim","Si","Yes","","","Não","No","No","","","","","","","","","","","","","","","","","","S","",".FIN05007.","",""})
AADD(aRegistros,{cPerg,"07","Mostra Lanc Contab. ?"		,"Muestra Asto. Contab. ?"		,"Display accounting entry ?"	,"MV_CH7","N",01,0,1,"C","","mv_par07","Sim","Si","Yes","","","Não","No","No","","","","","","","","","","","","","","","","","","S","",".FIN05001.","",""})
AADD(aRegistros,{cPerg,"08","Contabiliza On Line ?"		,"Contabiliza On Line ?"		,"Account On-line ?"			,"MV_CH8","N",01,0,1,"C","","mv_par08","Sim","Si","Yes","","","Não","No","No","","","","","","","","","","","","","","","","","","S","",".FIN05004.","",""})
AADD(aRegistros,{cPerg,"09","Data Inicial Cheques ?"	,"Fecha Inicial Cheques ?"		,"Initial check date ?"			,"MV_CH9","D",08,0,0,"G","","mv_par09","","","","20190301","","","","","","","","","","","","","","","","","","","","","","S","","","",""})
AADD(aRegistros,{cPerg,"10","Data Final Cheques ?"		,"Fecha Final Cheques ?"		,"Final check date ?"			,"MV_CHA","D",08,0,0,"G","","mv_par10","","","","20190403","","","","","","","","","","","","","","","","","","","","","","S","","","",""})
AADD(aRegistros,{cPerg,"11","Mostra Tela Efetivação ?"	,"Muestra Pantalla Efectiv. ?"	,"Display confirm. screen ?"	,"MV_CHB","N",01,0,1,"C","","mv_par11","Sim","Si","Yes","","","Não","No","No","","","","","","","","","","","","","","","","","","S","","","",""})
AADD(aRegistros,{cPerg,"12","Seleciona Filiais?"		,"Selecciona sucursales?"		,"Select Branches?"				,"mv_chc","N",01,0,2,"C","","mv_par12","Sim","Si","Yes","","","Nao","No","No","","","","","","","","","","","","","","","","","","S","","","",""})


For i:=1 to Len(aRegistros)
	If !dbSeek(cPerg+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegistros[i])
				FieldPut(j,aRegistros[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(aArea)

Return(NIL) 
