#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} BKFINR23
Saldos bancários consolidados

@Return
@author Marcos Bispo Abrahão
@since 25/06/2019
@version P11/P12
/*/

User Function BKFINR23()

Local nB      := 0
Local cNCampo := ""

Private aParam		:=	{}
Private aRet		:=	{}

Private cTitulo     := "Saldos Bancários Consolidados"
Private cPerg       := "BKFINR23"

Private aFields := {}
Private	cPict       := "@E 99,999,999,999.99"
Private nPlan       := 1
Private aHeader	    := {}
Private aTitulos,aCampos,aCabs,aCampos2,aCabs2

Private dDataI  	:= CTOD("")
Private dDataF  	:= CTOD("")
Private cFormato    := ""
Private lSintetico  := .T.

Private aDbf
Private cAliasQry   := ""
Private cAliasTrb   := GetNextAlias()


// Estrutura temporária da tabela de bancos
Private aStruct1    := {}
Private cAliasTmp1  := "TMP1"
Private aCabs1      := {}
Private aCampos1    := {}
Private aTitulos1   := {}
Private aImpr1      := {}
Private oTmpTb
Private aBancos     := {}



/*
Param Box Tipo 1
1 - MsGet
  [2] : Descrição
  [3] : String contendo o inicializador do campo
  [4] : String contendo a Picture do campo
  [5] : String contendo a validação
  [6] : Consulta F3
  [7] : String contendo a validação When
  [8] : Tamanho do MsGet
  [9] : Flag .T./.F. Parâmetro Obrigatório ?
*/
 
aAdd( aParam, { 1, "Data Inicial:" 		, CTOD("01/01/2019")		, ""            , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Data Final:" 		, dDataBase					, ""            , "", ""	, "" , 70  , .F. })  

/*  
aParametros	 	Array of Record	 	Array contendo as perguntas
cTitle	 	 	Caracter	 	 	Titulo
aRet	 	 	Array of Record	 	Array container das respostas
bOk	 	 		Array of Record	 	Array contendo definições dos botões opcionais	 	 	 	 	 	 	 	 	 	 
aButtons	 	Array of Record	 	Array contendo definições dos botões opcionais	 	 	 	 	 	 	 	 	 	 
lCentered	 	Lógico	 	 		Indica se será centralizada a janela	 	 	 	 	 	 	 	 	 	 
nPosX	 	 	Numérico	 	 	Coordenada X da janela	 	 	 	 	 	 	 	 	 	 
nPosy	 	 	Numérico	 	 	Coordenada y da janela
oDlgWizard	 	Objeto	 	 		Objeto referente janela do Wizard	 	 	 	 	 	 	 	 	 	 
cLoad	 	 	Caracter	 	 	Nome arquivo para gravar respostas	 	 	 	 	 	 	 	 	 	 
lCanSave	 	Lógico	 	 		Indica se pode salvar o arquivo com respostas	 	 	 	 	 	 	 	 	 	 
lUserSave	 	Array of Record	 	Indica se salva nome do usuario no arquivo
*/

If !BkFR23()
   Return
EndIf

If !KFin23Bco()
	MsgStop("Nenhuma conta selecionada!","Atenção")
	Return
EndIf

aCabs   := {}
aCampos := {}

aTitulos:= {}
AADD(aTitulos,cPerg+"/"+TRIM(cUserName)+" - "+cTitulo)

aFields := {}

aAdd(aFields,{"XX_DATA","E8_DTSALAT"})
For nB := 1 TO LEN(aBancos)
    cNCampo := "XX_SLD"+STRZERO(nB,3)
	aAdd(aFields,{cNCampo,"","(cAliasTrb)->("+cNCampo+")",aBancos[nB,1]+"-"+TRIM(aBancos[nB,3])+"-"+TRIM(aBancos[nB,4]),cPict,"N",18,2})
Next
aAdd(aFields,{"XX_SALDO","","(cAliasTrb)->(XX_SALDO)","Saldo Consolidado",cPict,"N",18,2})


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

//cArqTmp := CriaTrab( aDbf, .t. )
//dbUseArea( .t.,NIL,cArqTmp,cAliasTrb,.f.,.f. )
//IndRegua(cAliasTrb,cArqTmp,"XX_DATA",,,"Indexando Arquivo de Trabalho") 

oTmpTb := FWTemporaryTable():New(cAliasTrb)
oTmpTb:SetFields( aDbf )
oTmpTb:AddIndex("indice1", {"XX_DATA"} )
oTmpTb:Create()

Processa( {|| ProcBKFR23() })

MBrwBKF23()

oTmpTb:Delete()
///(cAliasTrb)->(Dbclosearea())
///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())

Return



Static Function BkFR23
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,@cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKFINR23",.T.         ,.T.))
	lRet     := .T.
	dDataI   := mv_par01
	dDataF   := mv_par02
	cTitulo  := "Saldos bancários consolidados - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
Endif
Return lRet



Static Function MBrwBKF23()
Local oSize
Local aPosObj 

Private aRotina	:= {}
Private lRefresh:= .T.
Private aButton := {}
Private oGetDb1
Private oDlg1
 

// Dimensionamento da tela
oSize := FWDefSize():New(.T.,.F., nOr(WS_VISIBLE,WS_POPUP) )
oSize:AddObject("TELA1", 100, 100, .T., .T.)
oSize:lProp := .T.
oSize:aMargins:= {3,3,3,3}
oSize:Process()

aPosObj := { 	oSize:GetDimension("TELA1","LININI"), oSize:GetDimension("TELA1","COLINI") ,;
				oSize:GetDimension("TELA1","LINEND"), oSize:GetDimension("TELA1","COLEND") }



AADD(aRotina,{"Exp. Excel"	,"U_CBKCR12",0,6})
AADD(aRotina,{"Parametros"	,"U_PBKCR12",0,8})
AADD(aRotina,{"Legenda"		,"U_LBKCR12",0,9})

dbSelectArea(cAliasTrb)
//dbSetOrder(1)
dbGoTop()
	
DEFINE DIALOG oDlg1;
 TITLE cTitulo ;
 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] of oMainWnd PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)

//MsGetDB():         New(< nTop>   ,< nLeft>  ,< nBottom>, < nRight>, < nOpc>, [ cLinhaOk]    , [ cTudoOk]     , [ cIniCpos], [ lDelete], [ aAlter], [ nFreeze], [ lEmpty], [ uPar1]     , < cTRB>  , [ cFieldOk], [ uPar2], [ lAppend], [ oWnd], [ lDisparos], [ uPar3], [ cDelOk], [ cSuperDel] ) --> oObj
oGetDb1 := MsGetDb():New(aPosObj[1],aPosObj[2],aPosObj[3],aPosObj[4], 2      , "AllwaysTrue()", "AllwaysTrue()",            ,           ,          ,          ,           ,"AllwaysTrue()",cAliasTrb,            ,         ,           ,oDlg1)


nBrLin  :=1
oGetDb1:ForceRefresh()

aadd(aButton , { "BMPTABLE" , { || U_CBKCR12(), (cAliasTrb)->(dbGoTop()), nBrLin:=1, oGetDb1:ForceRefresh(), oDlg1:Refresh()}, "Gerar planilha" } )
//aadd(aButton , { "BMPTABLE" , { || U_PBKCR12(), (cAliasTrb)->(dbGoTop()), nBrLin:=1, oGetDb1:ForceRefresh(), oDlg1:Refresh()}, "Parametros" } )
//aadd(aButton , { "BMPTABLE" , { || U_LBKCOMR04()}, "Legenda" } )
	
ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| oDlg1:End()}, {||oDlg1:End()},, aButton)

Return Nil



User Function LBKFR23()
Local aLegenda := {}

AADD(aLegenda,{"BR_AMARELO"," - Cancelado"})
AADD(aLegenda,{"BR_AMARELO"," - Em Elaboração" })
AADD(aLegenda,{"BR_AZUL" ," - Emitido"})
AADD(aLegenda,{"BR_LARANJA"," - Em Aprovação" })
AADD(aLegenda,{"BR_VERDE"," - Vigente" })
AADD(aLegenda,{"BR_CINZA"," - Paralisado" })
AADD(aLegenda,{"BR_MARRON"," - Sol. Finalização" })
AADD(aLegenda,{"BR_PRETO"," - Finalizado" })
AADD(aLegenda,{"BR_PINK"," - Resisão" })
AADD(aLegenda,{"BR_BRANCO"," - Revisado" })

BrwLegenda(cCadastro, "Legenda", aLegenda)

Return Nil





User FUNCTION PBKFR23()

If !BkCR12Par()
   Return Nil
EndIf

Processa( {|| ProcBKFR23() })

Return Nil
   

Static Function LimpaBrw(cAlias)

DbSelectArea(cAlias)
(cAlias)->(dbgotop())
Do While (cAlias)->(!eof())
	RecLock(cAlias,.F.)
	(cAlias)->(dbDelete())
	(cAlias)->(MsUnlock())
	dbselectArea(cAlias)
	(cAlias)->(dbskip())
EndDo

Return (.T.) 


// Gera Excel
User FUNCTION CBKFR23()

Local aPlans  := {}

AADD(aPlans,{cAliasTrb,TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
U_GeraXml(aPlans,cTitulo,TRIM(cPerg),.F.,aParam)

Return 

Static Function ProcBKFR23

Local nB		:= 0
Local nS		:= 0
Local dSaldo	:= dDataI
Local cBco		:= ""
Local cAge		:= ""
Local cCta		:= ""
Local nMoeda	:= 1
Local nMoedaBco	:= 1
Local nDecs		:= 2
Local nSaldo	:= 0


Private xCampo

LimpaBrw(cAliasTrb)

For nB := 1 To Len(aBancos)

	cBco 	:= aBancos[nB,1]
	cAge 	:= aBancos[nB,2]
	cCta 	:= aBancos[nB,3]
	dSaldo	:= dDataI

	ProcRegua(dDataF - dDataI + 1)

	Do While dSaldo <= dDataF

		IncProc("Consultando banco de dados...")

		dbSelectArea("SE8")
		dbSetOrder(1)
		If ! dbSeek(xFilial("SE8")+cBco+cAge+cCta+DtoS( dSaldo ),.T.)
			dbSkip( -1 )
		EndIf

		If cBco	== SE8->E8_BANCO	.AND. ;
			cAge == SE8->E8_AGENCIA	.AND. ;
			cCta == SE8->E8_CONTA	.AND. ;
			SE8->E8_DTSALAT	<= dSaldo

			nMoedaBco := Iif(cPaisLoc=="BRA",1,Max(nMoeda /*SA6->A6_MOEDA*/,1))
			nSaldo    := xMoeda(SE8->E8_SALATUA,nMoedaBco,nMoeda,SE8->E8_DTSALAT,nDecs+1)

			dbSelectArea(cAliasTrb)
			If dbSeek(dSaldo,.F.)
				Reclock(cAliasTrb,.F.)
			Else
				Reclock(cAliasTrb,.T.)
				cNCampo := "XX_DATA"
				&(cAliasTrb+"->"+cNCampo) := dSaldo
			EndIf

			cNCampo := "XX_SLD"+STRZERO(nB,3)
			&(cAliasTrb+"->"+cNCampo) := nSaldo

			nSaldo := 0
			For nS := 1 TO Len(aBancos)
				cNCampo := "XX_SLD"+STRZERO(nS,3)
				nSaldo += &(cAliasTrb+"->"+cNCampo)
			Next
			cNCampo := "XX_SALDO"
			&(cAliasTrb+"->"+cNCampo) := nSaldo
			
			(cAliasTrb)->(MsUnLock())

		EndIf

		dSaldo++
	EndDo

Next

dbSelectArea(cAliasTrb)
//dbSetOrder(1)
dbGoTop()

Return


/* Antiga
Static Function ProcBKFR23
Local cQuery := ""
Local nReg   := 0
Local nB     := 0

Private xCampo

LimpaBrw(cAliasTrb)

For nB := 1 To Len(aBancos)

	cQuery := "SELECT E8_DTSALAT,E8_SALATUA "
	cQuery += " FROM "+RETSQLNAME("SE8")+" SE8" 

	cQuery += " WHERE SE8.D_E_L_E_T_ = ' ' "
	cQuery += " AND SE8.E8_BANCO   = '"+aBancos[nB,1]+"'"
	cQuery += " AND SE8.E8_AGENCIA = '"+aBancos[nB,2]+"'"
	cQuery += " AND SE8.E8_CONTA   = '"+aBancos[nB,3]+"'"
	
	If !Empty(dDataI)
		cQuery += " AND SE8.E8_DTSALAT >= '"+DTOS(dDataI)+"'"
	EndIf
	If !Empty(dDataF)
		cQuery += " AND SE8.E8_DTSALAT <= '"+DTOS(dDataF)+"'"
	EndIf          
	cQuery += " ORDER BY E8_DTSALAT"

	u_LogMemo("BKFINR23"+STRZERO(nB,3)+".SQL",cQuery)

	cAliasQry := GetNextAlias()

	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
	TCSetField(cAliasQry, "E8_DTSALAT","D", 8,0)
	TCSetField(cAliasQry, "E8_SALATUA","N",18,0)

	ProcRegua((cAliasQry)->(LastRec()))
	
	nReg := 0
	
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	DO WHILE (cAliasQry)->(!EOF())
	    nReg++
		IncProc("Consultando banco de dados...")
		dbSelectArea(cAliasTrb)
		If dbSeek((cAliasQry)->E8_DTSALAT)
			Reclock(cAliasTrb,.F.)
		Else
			Reclock(cAliasTrb,.T.)
		    cNCampo := "XX_DATA"
			&(cAliasTrb+"->"+cNCampo) := (cAliasQry)->E8_DTSALAT
		EndIf
		
	    cNCampo := "XX_SLD"+STRZERO(nB,3)
		&(cAliasTrb+"->"+cNCampo) := (cAliasQry)->E8_SALATUA
	    cNCampo := "XX_SALDO"
		&(cAliasTrb+"->"+cNCampo) += (cAliasQry)->E8_SALATUA
		
		(cAliasTrb)->(MsUnLock())
		
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbSkip())
	ENDDO
	
	(cAliasQry)->(dbCloseArea())

Next

dbSelectArea(cAliasTrb)
dbGoTop()

Return
*/


// Selecionar contas bancárias

Static Function KFin23Bco()

Local cMarca     := GetMark()
Local oDlg
Local oMark
Local lInverte   := .F.
Local nOpcA 
Local lRet       := .F.
Local aCamposB2 := {{"A6_OK"      ,,"  ",""},;
					{"A6_COD"     ,,"Banco","@X"}   ,;
					{"A6_AGENCIA" ,,"Agencia","@X"} ,;
					{"A6_NUMCON"  ,,"Conta","@X"}   ,;
					{"A6_NREDUZ"  ,,"Nome","@X"}    ,;
					{"A6_XXTIPBK" ,,"Tipo","@X"}    }
					
Local aTipBk := {"Corrente","Vinculada","Garantida","Outras"}					
Local oTmpTb1

// Estrutura da tabela de bancos temporária
aStruct1    := {}
cAliasTmp1  := "TMP1"
aCabs1      := {}
aCampos1    := {}
aTitulos1   := {}
aBancos     := {}

AADD(aStruct1,{"A6_OK","C",2,0})
AADD(aCampos1,cAliasTmp1+"->A6_OK")
AADD(aCabs1  ,"Ok")

AADD(aStruct1,{"A6_DATA","D",8,0})
AADD(aCampos1,cAliasTmp1+"->A6_DATA")
AADD(aCabs1  ,"Data")

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek ("SA6")
Do While SX3->(!EOF()) .And. (SX3->x3_arquivo == "SA6")
	IF Alltrim(SX3->X3_CAMPO) $ "A6_COD#A6_AGENCIA#A6_NUMCON#A6_NREDUZ"
		AADD(aStruct1,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		AADD(aCampos1,cAliasTmp1+"->"+SX3->X3_CAMPO)
		AADD(aCabs1  ,SX3->X3_TITULO)
	ENDIF
	SX3->(dbSkip())
Enddo

AADD(aStruct1,{"A6_XXTIPBK","C",20,0})
AADD(aCampos1,cAliasTmp1+"->A6_XXTIPBK")
AADD(aCabs1  ,"Tipo")


///cArqTmp1 := CriaTrab(aStruct1)
///IF SELECT(cAliasTmp1) > 0
///   dbSelectArea(cAliasTmp1)
///   dbCloseArea()
///ENDIF
///dbUseArea(.T.,,cArqTmp1,cAliasTmp1,if(.F. .OR. .F.,!.F., NIL),.F.)
///IndRegua (cAliasTmp1,cArqTmp1,"A6_COD+A6_AGENCIA+A6_NUMCON",,,OemToAnsi("Selecionando Registros...") )  //

oTmpTb1 := FWTemporaryTable():New(cAliasTmp1)
oTmpTb1:SetFields( aStruct1 )
oTmpTb1:AddIndex("indice1", {"A6_COD","A6_AGENCIA","A6_NUMCON"} )
oTmpTb1:Create()

dbSetOrder(1)


dbSelectArea( "SA6" )
dbSetOrder( 1 )
dbSeek( xFilial("SA6") )
While SA6->A6_FILIAL == xFilial( "SA6" ) .And. SA6->(!Eof())

	If SA6->A6_FLUXCAI <> "N"

		dbSelectArea(cAliasTmp1)
		RecLock( cAliasTmp1, .T. )
		(cAliasTmp1)->A6_OK      := cMarca	
		(cAliasTmp1)->A6_COD     := SA6->A6_COD	
		(cAliasTmp1)->A6_AGENCIA := SA6->A6_AGENCIA 	
		(cAliasTmp1)->A6_NUMCON  := SA6->A6_NUMCON 	
		(cAliasTmp1)->A6_NREDUZ  := SA6->A6_NREDUZ	
		If VAL(SA6->A6_XXTIPBK) > 0 .AND. VAL(SA6->A6_XXTIPBK) <= 4
			(cAliasTmp1)->A6_XXTIPBK := aTipBk[VAL(SA6->A6_XXTIPBK)]	
		EndIf
		(cAliasTmp1)->(msUnlock())
		lRet := .T.
		
	EndIf
	SA6->(dbSkip())
EndDo

If lRet
	(cAliasTmp1)->( dbGotop() )
	DEFINE MSDIALOG oDlg TITLE "Selecione os Bancos que deverão ser consolidados" From 009,000 To 030,063 OF oMainWnd
	oMark := MsSelect():New(cAliasTmp1,"A6_OK","",aCamposB2,@lInverte,@cMarca,{30,2,150,248})
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2}) CENTERED
	
    lRet := .F.
	dbSelectArea(cAliasTmp1)
	dbGoTop()
	Do While !EOF()
		If !EMPTY((cAliasTmp1)->A6_OK)
		    //cTitBanco += IIF(EMPTY(cTitBanco),"","/")+TRIM((cAliasTmp1)->A6_NREDUZ)
		    AADD(aBancos,{(cAliasTmp1)->A6_COD,(cAliasTmp1)->A6_AGENCIA,(cAliasTmp1)->A6_NUMCON,(cAliasTmp1)->A6_NREDUZ})
		    lRet := .T.
		EndIf
		dbSkip()
	EndDo
EndIf

oTmpTb1:Delete()

Return lRet
