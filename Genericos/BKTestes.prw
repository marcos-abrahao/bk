#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH"                     
#INCLUDE "TBICONN.CH"
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} BKTestes
BK - Acertos diversos
@Return
@author Marcos B. Abrahao
@since 29/01/2011
@version P12
/*/
//-------------------------------------------------------------------


User Function BKTESTE()
Local aTeste := {}
//u_IsPetro("000112")
//u_IsPetro("000281")

// Teste do calculo da EFD - usado para DEBUG
aTeste := u_FinS600(1,2024,'FC0000057')
x := 0
Return Nil


User Function BKTestes(cRotTest)
Local oDlg1 as Object
Local oSay,oSay1,oSay2,oRot

Default cRotTest := "XMT110CFM"

Private cRot := PAD("U_"+cRotTest,20)
Private lEnd := .F.

DEFINE DIALOG oDlg1;
 TITLE "Teste de User Functions"  ;
 FROM 0,0 TO 150,480 OF oMainWnd PIXEL //STYLE nOr(WS_VISIBLE,WS_POPUP)

//FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL;

//@ 200,01 TO 330,450 DIALOG oDlg1 TITLE "Teste de User Functions"
@ 15,015 Say oSay Prompt "Func�o: " Size  40, 10 Of oDlg1 Pixel 
@ 15,046 MsGet oRot Var cRot SIZE 180,10 Of oDlg1 Pixel 

@ 30,015 SAY oSay1 Prompt "Exemplos:" SIZE 180,10 Of oDlg1 Pixel 
@ 30,046 SAY oSay2 Prompt "U_BKPARFIS,U_BKPARGEN,U_NIVERSADVPL,U_TSTYEXCEL" SIZE 180,10 Of oDlg1 Pixel 

DEFINE SBUTTON FROM 050,060 TYPE 1 ACTION (ProcRot(),oDlg1:End()) ENABLE OF oDlg1
DEFINE SBUTTON FROM 050,110 TYPE 2 ACTION oDlg1:End() ENABLE OF oDlg1
	
ACTIVATE MSDIALOG oDlg1  CENTERED


//@ 50,060 BMPBUTTON TYPE 01 ACTION ProcRot()   
//@ 50,110 BMPBUTTON TYPE 02 ACTION Close(Odlg1)
//ACTIVATE DIALOG oDlg1 CENTER

RETURN


User Function TestDlg

Local nI

Local nTop		:= 200
Local nLeft		:= 200
Local aButtons 	:= {}
aSize	   	:= FWGetDialogSize( oMainWnd )
Private oDlg2

nTotal := 99999.77
oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )


//DEFINE MSDIALOG oDlg2 TITLE "Confirme os Border�s a gerar (consolidados)" FROM 000,000 TO 450,650 PIXEL 
oDlg2 := MsDialog():New( nTop, nLeft, aSize[3], aSize[4],"Confirme os Border�s a gerar (consolidados)",,,,,,,,, .T.,,,, .F. )

//@ 000,000 MSPANEL oPanel OF oDlg SIZE 330,225



oPanel2:= TPanel():New(0,0,"",oDlg2,,,,,,100,100)
oPanel2:Align := CONTROL_ALIGN_ALLCLIENT   //CONTROL_ALIGN_TOP

//@ 000,000 MSPANEL oPanel2 OF oDlg2 SIZE 330,225
//oPanel2:Align := CONTROL_ALIGN_LEFT 


//oAll:bChange := {|| MudaCell(lAll) , oListId2:Refresh()}

lAll:= .F. 
@ 003, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanel2 SIZE 050, 010 PIXEL 

oSay := tSay():New(003,100,{||'Total Selecionado: '+ TransForm(nTotal,"@E 99,999,999.99")},oPanel2,,,,,,.T.,,,200,20)


@ 012, 005 LISTBOX oListID2 FIELDS HEADER "","Lote (CTRID)","Prontuario" SIZE aSize[3]-100, aSize[4]-100 OF oPanel2 PIXEL 
aBordero := {}
For nI := 1 to 50
	aAdd(aBordero,{.F.,"xxxxxxxxxxxxxxx",STR(nI)})
Next
oListID2:SetArray(aBordero)
oListID2:bLine := {|| {If(aBordero[oListId2:nAt][1],oOk,oNo),;
							aBordero[oListId2:nAt][2]}}

oListID2:bLDblClick := {|| aBordero[oListId2:nAt][1] := MrkTit(aBordero[oListId2:nAt][1]), oListID2:DrawSelect()}
//oListID2:Align := CONTROL_ALIGN_BOTTOM

ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT (EnchoiceBar(oDlg2,{|| lOk:=.T., oDlg2:End()},{|| oDlg2:End()}, , aButtons),Ajuste(@oListID2,@oPanel2))

Return Nil


Static Function Ajuste(oListA,oPanelA)
oListA:nRight := oPanelA:nRight - 10 //right
oListA:nBottom := oPanelA:nHeight - oListA:nTop - oPanelA:nTop  //botttom

//OLISTID2:NBOTTOM := Opanel2:NCLIENTHEIGHT - 10

Return Nil


User Function test2dlg
	Local nI 
	Local aBordero
	Local aSize as array
	Local oDlgBrw as object
	Local nTop		:= 200
	Local nLeft		:= 200

	Private oTotSel as Object
	Private nTotSel as numeric
	Private oQtdSel as Object
	Private nQtdSel as numeric

	//aSize := MsAdvSize( .T. ) //Parametros verifica se exist enchoice
	aSize := FWGetDialogSize( oMainWnd )

	Define MsDialog oDlgBrw FROM nTop,nLeft To aSize[3],aSize[4] Title "MarkBrowse" Pixel

	// Cria o conteiner onde ser�o colocados os paineis
	oTela     := FWFormContainer():New( oDlgBrw )
	cIdTela	  := oTela:CreateHorizontalBox( 08 )
	cIdRod	  := oTela:CreateHorizontalBox( 75 )

	oTela:Activate( oDlgBrw, .F. )

	//Cria os paineis onde serao colocados os browses
	oPanelUp  	:= oTela:GeTPanel( cIdTela )
	oPanelDown  := oTela:GeTPanel( cIdRod )

	//Quantidade Selecionado
	@ oPanelUp:nTop + 04, oPanelUp:nLeft + 10 	SAY   "Marcados:" SIZE 038,007 OF oPanelUp PIXEL
	@ oPanelUp:nTop + 02, oPanelUp:nLeft + 50	MSGET oQtdSel Var nQtdSel SIZE 080,010	OF oPanelUp PIXEL WHEN .F. PICTURE "@E 999,999,999" HASBUTTON

	oOk := LoadBitmap( GetResources(), "LBTIK" )
	oNo := LoadBitmap( GetResources(), "LBNO" )

	@ 0,0 LISTBOX oListID2 FIELDS HEADER "","Teste","Linha" SIZE aSize[3], aSize[4] OF oPanelDown PIXEL 
	aBordero := {}
	For nI := 1 to 50
		aAdd(aBordero,{.F.,"xxxxxxxxxxxxxxx",STR(nI)})
	Next
	oListID2:SetArray(aBordero)
	oListID2:bLine := {|| {If(aBordero[oListId2:nAt][1],oOk,oNo),;
								aBordero[oListId2:nAt][2],;
								aBordero[oListId2:nAt][3]}}

	oListID2:bLDblClick := {|| aBordero[oListId2:nAt][1] := MrkTit(aBordero[oListId2:nAt][1]), oListID2:DrawSelect()}
	oListID2:Align := CONTROL_ALIGN_ALLCLIENT

	ACTIVATE MSDIALOG oDlgBrw CENTERED ON INIT (EnchoiceBar(oDlgBrw,{||oDlgBrw:End()},{||oDlgBrw:End()},,))	

Return Nil


User Function test3dlg
	Local nI 
	Local aBordero
	Local aSize as array
	Local oDlg  as object
	Local nTop		:= 200
	Local nLeft		:= 200

	Private oTotSel as Object
	Private nTotSel as numeric
	Private oQtdSel as Object
	Private nQtdSel as numeric

	aSize := FWGetDialogSize( oMainWnd )

	oDlg := TDialog():New(nTop,nLeft,aSize[3],aSize[4],'Teste de tela com FWLayer',,,,,CLR_BLACK,CLR_WHITE,,,.T.,,,,,,)

    oDlg:nClientHeight  := aSize[3]
    oDlg:nClientWidth   := aSize[4]

	oDlg:Refresh()

	EnchoiceBar(oDlg,{|| oDlg:End() },{|| oDlg:End() })

   	oLayer := FWLayer():new()
    oLayer:init(oDlg,.F.)

    oLayer:addCollumn ('Col1',100,.F.)

    oLayer:addWindow('Col1', 'WinTop' ,'Sele��o' ,20,.F.,.F.,,,)
    oLayer:addWindow('Col1', 'WinGrid','T�tulos' ,80,.F.,.F.,,,)

	oPanelUp := oLayer:getWinPanel('Col1','WinTop')
	oPanelDown := oLayer:getWinPanel('Col1','WinGrid')
   
	// Painel Top
	@ 04, 10 SAY   "Marcados:" SIZE 038,007 OF oPanelUp PIXEL
	@ 04, 50 MSGET oQtdSel Var nQtdSel SIZE 080,010	OF oPanelUp PIXEL WHEN .F. PICTURE "@E 999,999,999" HASBUTTON

	oOk := LoadBitmap( GetResources(), "LBTIK" )
	oNo := LoadBitmap( GetResources(), "LBNO" )

	@ 0,0 LISTBOX oListID2 FIELDS HEADER "","Teste","Linha" SIZE aSize[3], aSize[4] OF oPanelDown PIXEL 
	aBordero := {}
	For nI := 1 to 50
		aAdd(aBordero,{.F.,"xxxxxxxxxxxxxxx",STR(nI)})
	Next
	oListID2:SetArray(aBordero)
	oListID2:bLine := {|| {If(aBordero[oListId2:nAt][1],oOk,oNo),;
								aBordero[oListId2:nAt][2],;
								aBordero[oListId2:nAt][3]}}

	oListID2:bLDblClick := {|| aBordero[oListId2:nAt][1] := MrkTit(aBordero[oListId2:nAt][1]), oListID2:DrawSelect()}
	oListID2:Align := CONTROL_ALIGN_ALLCLIENT

	oDlg:Activate()

Return Nil


Static Function MrkTit(lTit)
LOCAL lOk := .T.
lOk := .T.
Return lOk 


User Function test4dlg
	Local lRet 		:= .T.
	Local aSize 	as Array
	Local oDlg  	as Object
	Local nTop		:= 200
	Local nLeft		:= 600
	Local cMot		:= ""
	Local cMun 		:= ""
	Local cCli 		:= ""

	Local oCliente 	as Object
	Local oPlanilha as Object
	Local oMotivo	as Object

// Teste
dbSelectArea("SF2")
dbGoTo(60120)
cContrato :="387000608"
cPlanilha := "000003"
cRevisa   := "003"
MotCNA(cContrato,cPlanilha,cRevisa,@cMot,@cMun)

cCli := SF2->F2_CLIENTE+"-"+SF2->F2_LOJA+" "+Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NOME")
cCONTA := SF2->F2_XXCVINC
nVALOR := SF2->F2_XXVCVIN

	aSize := FWGetDialogSize( oMainWnd )

	oDlg := TDialog():New(nTop,nLeft,aSize[3],aSize[4],"Dados conta vinculada NF:"+TRIM(SF2->F2_SERIE)+'-'+TRIM(SF2->F2_DOC),,,,,CLR_BLACK,CLR_WHITE,,,.T.,,,,,,)

    oDlg:nClientHeight  := aSize[3]
    oDlg:nClientWidth   := aSize[4]

	oDlg:Refresh()

	EnchoiceBar(oDlg,{|| lRet:= .T.,oDlg:End() },{|| lRet:= .F.,oDlg:End() })

   	oLayer := FWLayer():new()
    oLayer:init(oDlg,.F.)

    oLayer:addCollumn ('Col1',100,.F.)

    oLayer:addWindow('Col1', 'WinTop' ,'Dados da Medi��o' ,30,.F.,.F.,,,)
    oLayer:addWindow('Col1', 'WinGrid','Dados conta vinculada' ,70,.F.,.F.,,,)

	oPanelUp := oLayer:getWinPanel('Col1','WinTop')
	oPanelDown := oLayer:getWinPanel('Col1','WinGrid')
   
	// Painel Top
	@ 04, 010 SAY   "Cliente:" SIZE 050,007 OF oPanelUp PIXEL
	@ 04, 075 MSGET oCliente Var cCli SIZE 300,010	OF oPanelUp PIXEL WHEN .F. 

	@ 14, 010 SAY   "Planilha "+cPlanilha SIZE 050,007 OF oPanelUp PIXEL
	@ 14, 075 MSGET oPlanilha Var cMun SIZE 300,010	OF oPanelUp PIXEL WHEN .F. 

	@ 24, 010 SAY   "Motivo:" SIZE 050,007 OF oPanelUp PIXEL
	@ 24, 075 MSGET oMotivo Var cMot SIZE 300,010	OF oPanelUp PIXEL WHEN .F. 

	@ 010,010 Say "Conta Vinculada :" Size 060,025 Pixel Of oPanelDown
	@ 010,075 MSGET cCONTA SIZE 080,010 OF oPanelDown PIXEL PICTURE "@!" HASBUTTON  F3 "SA6_2"

	@ 025,010 Say "Valor Conta Vinculada:" Size 080,008 Pixel Of oPanelDown
	@ 025,075 MsGet nVALOR  Size 060,008 Pixel Of oPanelDown Picture "@E 999,999,999,999.99" HASBUTTON

	oDlg:Activate()

	If lRet
		u_MsgLog(,"OK","I")
	EndIf

Return lRet


Static Function MotCNA(cContrato,cPlanilha,cRevisa,cMot,cMun)
Local cQuery 	 := "SELECT CNA_XXMUN,CNA_XXMOT FROM "+RETSQLNAME("CNA") + ;
					" WHERE CNA_FILIAL = '"+xFilial("CNA")+"' "+;
					"   AND CNA_CONTRA = '"+cContrato+"' "+;
					"   AND CNA_NUMERO = '"+cPlanilha+"' "+;
					"   AND CNA_REVISA = '"+cRevisa+"' "+;
					"   AND D_E_L_E_T_ = '' "

Local aReturn 	 := {}
Local aBinds 	 := {}
Local aSetFields := {}
Local nRet		 := 0
Local lRet       := .F.
Default cMot	:= ""
Default cMun	:= ""

// Ajustes de tratamento de retorno
aadd(aSetFields,aSize(FWSX3Util():GetFieldStruct( "CNA_XXMUN" ),4))
aadd(aSetFields,aSize(FWSX3Util():GetFieldStruct( "CNA_XXMOT" ),4))

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

If nRet < 0
	u_MsgLog("MotCNA",tcsqlerror()+" Falha ao executar a Query: "+cQuery)
Else
  //Alert(VarInfo("aReturn",aReturn))
  //MsgInfo("Verifique os valores retornados no console","Ok")
  If Len(aReturn) > 0
	cMun := aReturn[1][1]
	cMot := aReturn[1][2]
  EndIf
Endif

Return lRet




//#include "TOTVS.CH"

// Alinhamento do m�todo addInLayout
#define LAYOUT_ALIGN_LEFT     1
#define LAYOUT_ALIGN_RIGHT    2
#define LAYOUT_ALIGN_HCENTER  4
#define LAYOUT_ALIGN_TOP      32
#define LAYOUT_ALIGN_BOTTOM   64
#define LAYOUT_ALIGN_VCENTER  128

// Alinhamento para preenchimento dos componentes no TLinearLayout
#define LAYOUT_LINEAR_L2R 0 // LEFT TO RIGHT
#define LAYOUT_LINEAR_R2L 1 // RIGHT TO LEFT
#define LAYOUT_LINEAR_T2B 2 // TOP TO BOTTOM
#define LAYOUT_LINEAR_B2T 3 // BOTTOM TO TOP

function u_fEstAlias()
    local oDlg as object
    local oSQL as object
    local aTam as array
    local oTBar as object
    local oBBrNovo as object
    local oBBrAbrir as object
    local oBBrPlay as object
    local oLyrSQL as object

    oDlg := TDialog():New(,,600,1000,'Consulta SQL',,,,,CLR_BLACK,CLR_WHITE,,,.T.,,,,,,)

    aTam  := FwGetDialogSize(oDlg)
    oDlg:lCentered  := .T.
    //oDlg:lMaximized := .T.

    oDlg:nTop       := 200 //aTam[1]
    oDlg:nLeft      := 200 //aTam[2]
    oDlg:nBottom    := aTam[3]
    oDlg:nRight     := aTam[4]

    oDlg:nClientHeight  := aTam[3]
    oDlg:nClientWidth   := aTam[4]

    oDlg:Refresh()

    //Componentes do cabe�alho
    oTBar       := TBar():New( oDlg, 25, 32, .T.,,,, .T.)
    oBBrNovo    := TBtnBmp2():New( 00, 00, 35, 25, 'TK_NOVO',,,, { || Alert( 'Novo' ) }     , oTBar, 'Nova Consulta'    ,, .F., .F. )
    oBBrAbrir   := TBtnBmp2():New( 00, 00, 35, 25, 'OPEN'   ,,,, { || Alert( 'Abrir' ) }    , oTBar, 'Abrir Consulta'   ,, .F., .F. )
    oBBrSalvar  := TBtnBmp2():New( 00, 00, 35, 25, 'SALVAR' ,,,, { || Alert( 'Salvar' ) }   , oTBar, 'Salvar Consulta'  ,, .F., .F. )
    oBBrPlay    := TBtnBmp2():New( 00, 00, 35, 25, 'NEXT'   ,,,, { || Alert( 'Executar' ) } , oTBar, 'Executar Consulta',, .F., .F. )

    oLyrSQL := FWLayer():new()
    oLyrSQL:init(oDlg,.F.)

    oLyrSQL:addLine('lCONSULTA',100,.F.)

    oLyrSQL:addCollumn ('cCONSULTA',100,.F.,'lCONSULTA')

    oLyrSQL:addWindow('cCONSULTA', 'wCONSULTA' ,'SQL'        ,60,.F.,.F.,,'lCONSULTA',)
    oLyrSQL:addWindow('cCONSULTA', 'wRESULTADO','Resultado'  ,40,.T.,.T.,{||sizePnlSQL(oSQL)},'lCONSULTA',)

    oSQL := FPanelSQL(@(oLyrSQL:GetWinPane('cCONSULTA','wCONSULTA','lCONSULTA')))

    oDlg:Activate()
Return

Static Function fPanelSQL(oPanel)
    Local oTSEditSql as object

    oTSEditSql := TSimpleEditor():New(,,oPanel,,)
    oTSEditSql:lAutoIndent := .T.
    oTSEditSql:nWidth   := oPanel:nWidth
    oTSEditSql:nHeight  := oPanel:nHeight

Return oTSEditSql

static function sizePnlSQL(oSQL)
    oSQL:nHeight := oSQL:oParent:nHeight
return nil




User Function BKBanner()
	Local	nLin	as	numeric
	Local	ncol	as	numeric
	Local	oDlg	as	object
	Local	oLayer	as	object
	Local	oSay	as	object
	Local	oFont 	as	object
	Local	cTxt	as	char
	Local   cMargiPri as Character
	Local   cMargiSec as Character

	cTxt			:=	''
	oFont 			:= 	TFont():New('Arial',,-12,.T.)
	oLayer 			:= 	FWLayer():New()
	nLin			:=	0
	nCol			:=	610
	nLin			:=	435
	cMargiPri		:= "margin-top:40px;"
	cMargiSec		:= "margin-top:20px;"
	
	cTxt	:= '<h1><strong>'+"Smartclient Incompat�vel"+'</strong></h1><br>'//
	cTxt	+= '<h2><strong>'+"Ocorrencia:"+'</strong></h2>'//
	cTxt	+= '<p style="'+cMargiSec+'">'+"O SmartClient utilizado esta na versao 64 bits"+'</p>'//
	cTxt	+= '<h2 style="'+cMargiPri+'"><strong>'+"Solucao:"+'</strong></h2>'//
	cTxt	+= '<p style="'+cMargiSec+'">'+"Para o correto funcionamento dessa rotina, sera necessario alterar a versao do"+'</p>'//
	cTxt	+= '<p>'+"SmartClient para Lobo Guara 32 bits."+'</p>'//
	cTxt    += '<p style="'+cMargiSec+'">'+"Obs. Os arquivos estao disponiveis no Portal do Cliente"+'</p>'//

	oDlg := MsDialog():New( 0, 0, nLin, nCol, "",,,, nOr( WS_VISIBLE, WS_POPUP ),,,,, .T.,,,, .F. )
	oLayer:Init( oDlg, .T. )
	oLayer:AddLine( "LINE01", 100 )
	oLayer:AddCollumn( "BOX01", 100,, "LINE01" )
	oLayer:AddWindow( "BOX01", "PANEL01", 'FINR460 - Cheques Especiais.', 100, .F.,,, "LINE01" )

	oSay	:=	TSay():New(10,10,{|| cTxt },oLayer:GetWinPanel ( 'BOX01' , 'PANEL01', 'LINE01' ),,oFont,,,,.T.,,,380,nLin,,,,,,.T.)
	oSay:lWordWrap = .T.

	oDlg:Activate(,,,.T.)

Return


User Function PisCof()
Local aRet := {}

aRet := FinSpdF600(3,2022) 
x:= 0

Return


Static FUNCTION ProcRot()
//Local bError 
Private nProc := 0

cRot:= ALLTRIM(cRot)+"(@lEnd)"

If MsgYesNo("Confirma a execu��o do processo ?",cRot,"YESNO")
	//-> Recupera e/ou define um bloco de c�digo para ser avaliado quando ocorrer um erro em tempo de execu��o.
	//bError := ErrorBlock( {|e| cError := e:Description, Break(e) } ) //, Break(e) } )
		
	//-> Inicia sequencia.
	BEGIN SEQUENCE
      x:= &(cRot)
	//RECOVER
		//-> Recupera e apresenta o erro.
		//ErrorBlock( bError )
		//MsgStop( cError )
	END SEQUENCE

Endif   

If nProc > 0
   MsgInfo("Registros processados: "+STR(nProc,6),cRot,"INFO")
EndIf

Return 


Static Function PEmailSa1()
Local lEnd := .F.
MsAguarde({|lEnd| EmailSa1(@lEnd) },"Processando...",cRot,.T.)
Return

Static Function EmailSa1(lEnd)
Local cEmail := ""

   dbSelectArea("SA1")
   dbSetOrder(0)
   dbGoTop()
   
   While !EOF()
      If lEnd
        MsgInfo(cCancel,"T�tulo da janela")
        Exit
      Endif
      MsProcTxt("Lendo tabela: SA1 ")
      ProcessMessage()

      If !EMPTY(SA1->A1_EMAIL)
         cEmail := STRTRAN(SA1->A1_EMAIL,"|",";")
         cEmail := LOWER(ALLTRIM(cEmail))
         If SUBSTR(cEmail,LEN(cEmail),1) == ";"
            cEmail := SUBSTR(cEmail,1,LEN(cEmail)-1)
         EndIf
         RecLock("SA1",.F.)
         SA1->A1_EMAIL := cEmail
         MsUnLock()
      EndIf

      dbSkip()

      nProc++

   End

Return lEnd



User Function PApvSC1()
Local lEnd := .F.


MsAguarde({|lEnd| ApvSC1(@lEnd) },"Processando...",cRot,.T.)
Return

Static Function ApvSC1(lEnd)
Local dData := DATE()
Local cUserLga := ""

   dbSelectArea("SC1")
   dbSetOrder(0)
   dbGoTop()
   
   While !EOF()
      If lEnd
        MsgInfo(cCancel,"T�tulo da janela")
        Exit
      Endif
      MsProcTxt("Lendo tabela: SC1 ")
      ProcessMessage()

	  If !Empty(SC1->C1_USERLGA) //.AND. Empty(SC1->C1_XDTAPRV) 
	    dData := CTOD(SC1->(FWLeUserlg("C1_USERLGA", 2)))
		cUserLga := SC1->C1_USERLGA
      	RecLock("SC1",.F.)
      	SC1->C1_XDTAPRV := dData
      	SC1->C1_USERLGA := cUserLga
      	MsUnLock()
	  EndIf

      dbSkip()

      nProc++

   End

Return lEnd


/*
Static Function FuncUser1()
Local lEnd := .F.
MsAguarde({|lEnd| FuncUser(@lEnd) },"Processando...",cRot,.T.)
Return

Static Function FuncUser(lEnd)

   dbSelectArea("SX5")
   dbSetOrder(1)
   dbGoTop()
   
   While !EOF()
      If lEnd
        MsgInfo(cCancel,"T�tulo da janela")
        Exit
      Endif
      MsProcTxt("Lendo tabela: "+SX5->X5_TABELA)
      ProcessMessage()
      dbSkip()

      nProc++

   End

Return lEnd
// fim do exemplo
*/



//#include 'protheus.ch'

User Function TmpTable()
Local aFields := {}
Local oTmpTb
Local nI
Local cAlias := "MEUALIAS"
Local cQuery

//-------------------
//Cria��o do objeto
//-------------------
oTmpTb := FWTemporaryTable():New( cAlias )

//--------------------------
//Monta os campos da tabela
//--------------------------
aadd(aFields,{"DESCR","C",30,0})
aadd(aFields,{"CONTR","N",3,1})
aadd(aFields,{"ALIAS","C",3,0})

oTmpTb:SetFields( aFields )
oTmpTb:AddIndex("indice1", {"DESCR"} )
oTmpTb:AddIndex("indice2", {"CONTR", "ALIAS"} )
//------------------
//Cria��o da tabela
//------------------
oTmpTb:Create()


//Conout("Executando a c�pia dos registros da tabela: " + RetSqlName("CT0") )

//--------------------------------------------------------------------------
//Caso o INSERT INTO SELECT preencha todos os campos, este ser� um m�todo facilitador
//Caso contr�rio dever� ser chamado o InsertIntoSelect():
 // oTmpTb:InsertIntoSelect( {"DESCR", "CONTR" } , RetSqlName("CT0") , { "CT0_DESC", "CT0_CONTR" } )
//--------------------------------------------------------------------------
oTmpTb:InsertSelect( RetSqlName("CT0") , { "CT0_DESC", "CT0_CONTR", "CT0_ALIAS" } )


//------------------------------------
//Executa query para leitura da tabela
//------------------------------------
cQuery := "select * from "+ oTmpTb:GetRealName()
MPSysOpenQuery( cQuery, 'QRYTMP' )

DbSelectArea('QRYTMP')

while !eof()
	for nI := 1 to fcount()
		varinfo(fieldname(nI),fieldget(ni))
	next
	dbskip()
Enddo

	
//---------------------------------
//Exclui a tabela 
//---------------------------------
oTmpTb:Delete() 

return








//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINSPDF600

Func�o para retornar os t�tulos que compoem o bloco F600 do SPED PIS/COFINS
Arquivo anterior: MATXATU.PRX

@Author	TOTVS
@since	28/04/2011
/*/
//-----------------------------------------------------------------------------------------------------
User Function FinS600(nMesRef,nAnoRef,cNF)       
Local dLastPcc := CTOD("22/06/2015")
Local aReturn		:= {}
Local cQuery 		:= ""
Local aF600  		:= {}
Local cAliasQry		:= "" 
Local aStruct		:= {}    
Local nX			:= 0 
Local nBase			:= 0
Local cIndCmlt		:= ""
Local dLastDay  	:= ""
Local lSpdMotBx		:= ExistBlock("SPDF6001")
Local lSpdNat		:= ExistBlock("SPDF6002")  
Local lSpdCodRec  	:= ExistBlock("SPDF6003")
Local lSpdCodR2	  	:= ExistBlock("SPDF6004")
Local cPeCodRec		:="" 
Local cNatur		:= ""   
Local nI			:=	0       
Local nJ			:=	0       
Local lBaixa 		:= FPccBxCr()
Local nPercBx		:=	0
Local nJurosBx		:=	0
Local nDescBx		:=	0
Local cChaveBx		:= ""
Local nPisBx		:=	0
Local nCofBx		:= 0
Local nVlrSe5		:=	0
Local aRegBx		:=	{}
Local lRecIss		:=	.F. 
Local cMotBx		:= SuperGetMv("MV_MTBXF6",,"")	
Local cBaixa		:=	"" 
Local aMotBx 		:= ReadMotBx()
Local cMotQry		:= ""
Local nTpMoeda		:= 0
Local lMVDescIss	:= GetNewPar("MV_DESCISS",.F.)
Local nVlMinImp		:= IIF(dDataBase > dLastPcc, GetNewPar("MV_VL13137",10), GetNewPar("MV_VL10925",5000))
Local aSpdMotTRF	:= {}
Local cAliasSPED	:= ""                   
Local lRetSFQ		:= .F. 						//titulo que retem valores de outros titulos                        
Local cFilSe5		:= xFilial("SE5")
Local cFilSe1		:= xFilial("SE1")
Local lSe5MsFil		:= SE5->(FieldPos("E5_MSFIL")) > 0
Local cTipoTit		:=	""
Local cTpAbIss		:=	SuperGetMv("MV_TPABISS",,"2") //Verificando se os titulos criados no modulo FATURAMENTO os impostos do PCC sao calculados atraves do valor do titulo com a reducao do ISS. 	
Local aTitRet		:=	{} 						//titulos que retem outros
Local cIndCmlDes  	:= cIndCmlOri	:= ""    //indicadores de cumulatividade    
Local	nVrPIS		:=	nVrCOFINS	:=	nVrCSLL :=	nVrIR	:=	nVrISS :=	nVrINSS	:=	0                            
Local lTitRet		:= .F. 						//titulo retido em outro
Local cRASpd		:= SuperGetMv("MV_NTRASPD",,'')//Indica as naturezas de titulos RA que devo antecipar os creditos na gera��o deste bloco.
Local aAreaSEV 		:= SEV->(GetArea())
Local nVrRateio		:= 0
Local nTxMoeda		:= 0 
Local nPercPis		:= 0  
Local nPercCof		:= 0  
Local cChaveOri		:= cChaveDes	:=	""     
Local aAreaSC5 		:= SC5->(GetArea())
Local aRet			:= {}
Local nTotPis		:= 0
Local nTotCof		:= 0
Local nTotCsll 		:= 0
Local lTotalImp 	:= .T.
Local lIdent		:= .F.
Local aAreaSF2		:= {}
Local lSF2			:= .F.
Local nVlPis		:= 0
Local lSe1MsFil		:= SE1->(FieldPos("E1_MSFIL")) > 0
Local lIrrfSE2		:= .F.
Local lIssSE2		:= .F.
Local lMvImpBxCR 	:= .F.
Local lMaxSeq       := .F.
Local aRegCmp		:= {}

PRIVATE aBaixaSE5	:= {}
Private cPeMBx		:=	""
Private cBxSql		:= ""
Private cDataIni	:= ""
Private cDataFim 	:= ""
Private cMotBaixa	:= ""   
Private cPeNat		:=	""
Private lUnidNeg 	:= FWSizeFilial() > 2	// Indica se usa Gestao Corporativa

DEFAULT nMesRef := Month(dDataBase)
DEFAULT nAnoRef := Year(dDataBase)
                               
If cPaisLoc == "BRA"
                               
If lUnidNeg
	cFilSe5	:= SM0->M0_CODFIL 
	cFilSe1 := SM0->M0_CODFIL 
Else
	cFilSe5	:= xFilial("SE5")
	cFilSe1 := xFilial("SE1")
Endif

cDataIni := StrZero(nAnoRef,4)+StrZero(nMesRef,2)+"01"
dLastDay := LastDay(Ctod("01/"+StrZero(nMesRef,2)+"/"+StrZero(nAnoRef,4))) 
cDataFim := StrZero(nAnoRef,4)+StrZero(nMesRef,2)+StrZero(Day(dLastDay),2)
    
//Tratamentos para o ponto de entrada SPDF6001
cPeMBx	:=	""
If lSpdMotBx
	cPeMBx := ExecBlock ("SPDF6001",.F.,.F.)	
Endif		

If !Empty(cPeMBx) // Inserindo aspas e virgulas para o select da query.
	cMotBaixa:="'"
	For nI:=1 To Len(cPeMBx)
		If Subst(cPeMBx,nI,1) $ ";,-_|./" 				 
	  	  	cMotBaixa+="','"
	  	Else
	  	 	cMotBaixa+=Subst(cPeMBx,nI,1)  
	  	Endif
	Next
Endif	
cMotBaixa	+=	"'"

//Tratamentos para o ponto de entrada SPDF6002
cPeNat	:=	""
If lSpdNat
	cPeNat := ExecBlock ("SPDF6002",.F.,.F.)	
Endif		

If !Empty(cPeNat) // Inserindo aspas e virgulas para o select da query.
	cNatur	:=	"'"
	For nI:=1 To Len(cPeNat)
		If Subst(cPeNat,nI,1) $ ";,-_|./" 				 
	  	  	cNatur	+=	"','"
	  	Else
	  	 	cNatur	+=	Subst(cPeNat,nI,1)  
	  	Endif
	Next
Endif	                             
cNatur	+=	"'"
             
dbSelectArea("SED")

If !Empty(cMotBx)// Para o parametro MV_MTBXF6
	cBxSql	+=""
	cBaixa	:=	""		
	For nI:=1 To Len(cMotBx)  		
		If Subst(cMotBx,nI,1) $ ";,-_|./" 				 
	   		If !Empty(cBaixa)
	    		nJ :=  Ascan(aMotBx, {|x| Substr(x,1,3) == Upper(cBaixa) })
				If nJ >0 .And. Substr(aMotBx[nJ],26,01) == "N" //Nao movimenta banco.
					If !Empty(cBxSql)
						cBxSql	+= ",'" 
					Else
						cBxSql	+= "'" 
					Endif
					cBxSql	+= cBaixa + "'"  				   	
				Endif
			   	cBaixa	:=	""
	  	  	Endif	  	  		
	  	Else
	  	 	cBaixa+=Subst(cMotBx,nI,1)  
	  	Endif
	Next
	If !Empty(cBaixa)			
		If !Empty(cBxSql)
			cBxSql	+= ",'" 
	   	Else
	   		cBxSql	+= "'" 
	   	Endif
		cBxSql	+= cBaixa 
	Endif
	cBxSql	+=	"'"
Endif                   

cPeCodRec:=	"" //Tratamentos para o ponto de entrada SPDF6003
If lSpdCodRec
	cPeCodRec := ExecBlock ("SPDF6003",.F.,.F.)	
	If Len(cPeCodRec) > 4
		cPeCodRec := Subst(cPeCodRec,1,4)	 			
	Endif
Endif		

//PIS e COFINS na emiss�o
If !lBaixa     
	lMvImpBxCR := SuperGetMv( "MV_IMPBXCR" , , "1" ) == "2"
	cAliasQry	:= "SE5QRY"
	aStruct	 	:= SE5->(dbStruct())
	cQuery	 	:= "SELECT "
			
	//Campos de refer�ncia
	cQuery	 	+= "SE5.E5_FILIAL FILIAL , SE5.E5_PREFIXO PREFIXO, SE5.E5_NUMERO NUMERO, SE5.E5_PARCELA PARCELA, SE5.E5_TIPO TIPO, "		
	cQuery	 	+= "SE5.E5_CLIFOR CLIENTE, SE5.E5_LOJA LOJA, SE5.E5_TIPODOC TIPODOC, SE5.E5_DATA DATAM, SE5.E5_FILORIG FILORIG, "
	cQuery		+= "SE5.E5_VALOR VALORE5 , SE5.E5_NATUREZ NATUREZ, SE5.E5_MOTBX MOTBX, SE5.E5_DOCUMEN DOCUMEN, SE5.R_E_C_N_O_ RECNO, "
	cQuery		+= "SE5.E5_PRETCOF PRETCOF , SE5.E5_PRETPIS PRETPIS, SE5.E5_SEQ SEQ, SE5.E5_VALOR VALORBX , " 		
	cQuery		+= "SE1.E1_PIS PIS, SE1.E1_COFINS COFINS, SE1.E1_CSLL CSLL, SE1.E1_SALDO SALDO, SE1.E1_VALOR VALORE1, SE1.E1_BASEPIS BASEPIS, "
	cQuery		+= "SE1.E1_IRRF VRIR, SE1.E1_INSS VRINSS, SE1.E1_ISS VRISS, SE1.E1_MOEDA TPMOEDA, SE1.E1_VLCRUZ VLCRUZ, SE1.E1_ORIGEM ORIGEM, "
	cQuery		+= "SE1.E1_MULTNAT MULTNAT, SE1.E1_PEDIDO PEDIDO, SE1.E1_NUMLIQ NUMLIQ"
	cQuery		+= ", SE1.E1_SCORGP SCORGP "
	cQuery		+= ", SED.ED_PERCPIS PERCPIS, SED.ED_PERCCOF PERCCOF,SED.ED_RECIRRF RECIRRF,SED.ED_CALCIRF CALCIRF, SED.ED_CODIGO CODIGO "
	cQuery	 	+= ", SA1.A1_RECPIS RECPIS, SA1.A1_RECCOFI RECCOFI, SA1.A1_CGC CNPJ "
	cQuery	 	+= ", SA1.A1_INDRET A1INDRET "
	cQuery	 	+= ", SE1.E1_EMISSAO, SE1.E1_SABTPIS, SE1.E1_SABTCOF, SE1.R_E_C_N_O_ E1RECNO "
				
	cQuery	 	+= "FROM "
	cQuery 		+= RetSqlName("SE5") + " SE5, "
	cQuery 		+= RetSqlName("SE1") + " SE1 ,"	
	cQuery 		+= RetSqlName("SED") + " SED ,"	
	cQuery 		+= RetSqlName("SA1") + " SA1 "						
				
	cQuery	 	+= "WHERE "

	If !Empty( Iif( lUnidNeg, FWFilial("SE5") , xFilial("SE5") ) )
		cQuery 	+= "SE5.E5_FILIAL = '"  + xFilial("SE5") + "' AND "
	Else
		If lSe5MsFil
			cQuery 	+= "SE5.E5_MSFIL = '" + Iif(lUnidNeg, cFilSe5, cFilAnt) + "' AND "					
		Else	
			cQuery 	+= "SE5.E5_FILORIG = '" + Iif(lUnidNeg, cFilSe5, cFilAnt) + "' AND "	
		Endif	
	EndIf   		
	
	If !Empty( Iif( lUnidNeg, FWFilial("SE1") , xFilial("SE1") ) )
		cQuery 	+= "SE1.E1_FILIAL = '"  + xFilial("SE1") + "' AND "
	Else
		If lSe1MsFil
			If FWModeAccess("SE1",3) <> "C"
				cQuery 	+= "SE1.E1_MSFIL = '" + Iif(lUnidNeg, cFilSe1, cFilAnt) + "' AND "
			EndIf					
		Else	
			cQuery 	+= "SE1.E1_FILORIG = '" + Iif(lUnidNeg, cFilSe1, cFilAnt) + "' AND "	
		Endif	
	EndIf   
	
	cQuery	 		+=	"SED.ED_FILIAL='" + xFilial("SED") + "' AND " 							
	cQuery 		+=	"SA1.A1_FILIAL ='" + xFilial("SA1") + "' AND "
	cQuery 		+= "SE5.E5_PREFIXO = SE1.E1_PREFIXO AND " 
	cQuery 		+= "SE5.E5_NUMERO = SE1.E1_NUM AND " 
	cQuery 		+= "SE5.E5_PARCELA = SE1.E1_PARCELA AND " 
	cQuery 		+= "SE5.E5_TIPO = SE1.E1_TIPO AND " 					
	cQuery	 		+= "SE5.E5_CLIFOR = SE1.E1_CLIENTE AND "
	cQuery			+= "SE5.E5_LOJA = SE1.E1_LOJA AND "
	cQuery			+= "SE5.E5_CLIFOR = SA1.A1_COD AND "
	cQuery			+= "SE5.E5_LOJA = SA1.A1_LOJA AND " 
	cQuery			+= "SE1.E1_CLIENTE = SA1.A1_COD AND "
	cQuery			+= "SE1.E1_LOJA = SA1.A1_LOJA AND " 
	cQuery			+= "SA1.A1_PESSOA != 'F' AND "
	cQuery			+= "SE1.E1_NATUREZ = SED.ED_CODIGO AND"
			
	If lMvImpBxCR
		cQuery		+= " ( ( ( SE1.E1_PIS > 0 AND SE1.E1_SABTPIS = 0 ) OR ( SE1.E1_COFINS > 0 AND SE1.E1_SABTCOF = 0 ) ) "
		cQuery		+= " OR ( SE1.E1_EMISSAO < '" + DtoS( dLastPcc ) + "' AND ( ( SE1.E1_PIS > 0 AND SE1.E1_SABTPIS > 0 ) OR ( SE1.E1_COFINS > 0 AND SE1.E1_SABTCOF > 0 ) ) ) ) AND "
	Else
		cQuery		+= "( ( SE1.E1_PIS > 0 AND SE1.E1_SABTPIS = 0 ) OR ( SE1.E1_COFINS > 0 AND SE1.E1_SABTCOF = 0 ) ) AND "
	EndIf
			
	cQuery	 	+= "SE5.E5_RECPAG = 'R' AND "
			
	cTipoTit		:=	""
	cTipoTit		:=	MVABATIM + "|" + MV_CRNEG + "|" + MVPROVIS  
	cQuery 		+= "SE5.E5_TIPO NOT IN " + FormatIn(cTipoTit,If("|"$cTipoTit,"|",","))  + " AND "
	
	cQuery		+= " (SE5.E5_TIPODOC <> 'BA ' OR (SE5.E5_LOTE <> '' AND SE5.E5_BANCO <> '' AND SE5.E5_TIPODOC = 'BA ')) AND "

	cQuery		+= "SE5.E5_SITUACA <> 'C' AND "
	cQuery	 	+= "SE5.E5_DATA BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND "
	///// BK AQUI
	If !Empty(cNf)
		cQuery	 	+= "SE5.E5_NUMERO = '"+cNf+"' AND "
	EndIf
	/////
	cMotQry		:= "('FAT','LIQ'"
			
	If !Empty(cPeMBx)                    
		cMotQry += "," + cMotBaixa
	Endif                        
				
	If !Empty(cBxSql)
		cMotQry += "," + cBxSql
	EndIf                       
			
	cMotQry		+= ")"
			
	cQuery		+= "SE5.E5_MOTBX NOT IN " + cMotQry + " AND "

	//Exclui os titulos que possuem estorno
	cQuery	 	+= "SE5.E5_SEQ NOT IN "
	cQuery 		+= "( SELECT SE5AUX.E5_SEQ FROM "
	cQuery		+=      RetSqlName("SE5") + " SE5AUX WHERE "
	cQuery		+= 		" SE5AUX.E5_FILIAL = SE5.E5_FILIAL AND "
	cQuery		+= 		" SE5AUX.E5_PREFIXO = SE5.E5_PREFIXO AND "
	cQuery		+= 		" SE5AUX.E5_NUMERO = SE5.E5_NUMERO AND  "
	cQuery		+= 		" SE5AUX.E5_PARCELA = SE5.E5_PARCELA AND " 
	cQuery		+= 		" SE5AUX.E5_TIPO = SE5.E5_TIPO AND "      
	cQuery		+= 		" SE5AUX.E5_CLIFOR = SE5.E5_CLIFOR AND " 
	cQuery		+= 		" SE5AUX.E5_LOJA = SE5.E5_LOJA AND "
	cQuery		+= 		" SE5AUX.E5_TIPODOC = 'ES' AND "
	cQuery		+= 		" SE5AUX.D_E_L_E_T_ = ' ' "
	cQuery 		+= ") AND "

	cQuery		+= "SED.D_E_L_E_T_ = ' ' AND "
	cQuery		+= "SA1.D_E_L_E_T_ = ' ' AND "
	cQuery		+= "SE1.D_E_L_E_T_ = ' ' AND "
	cQuery		+= "SE5.D_E_L_E_T_ = ' ' "
	
	cQuery 		+= " ORDER BY FILIAL, PREFIXO, NUMERO, PARCELA, TIPO, CLIENTE, LOJA, SEQ, VALORE5"

	cQuery 		:= ChangeQuery(cQuery)                 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
			                                                          
	For nX := 1 To len(aStruct)
		If aStruct[nX][2] <> "C" .And. FieldPos(aStruct[nX][1]) > 0
			TcSetField(cAliasQry,aStruct[nX,1],aStruct[nX,2],aStruct[nX,3],aStruct[nX,4])
		EndIf
	Next nX

	TcSetField( cAliasQry , "E1_EMISSAO" , "D" , 8 , 0 )
	TcSetField( cAliasQry , "E1_SABTPIS" , "N" , TamSX3("E1_SABTPIS")[ 1 ] , TamSX3("E1_SABTPIS")[ 2 ] )
	TcSetField( cAliasQry , "E1_SABTCOF" , "N" , TamSX3("E1_SABTCOF")[ 1 ] , TamSX3("E1_SABTCOF")[ 2 ] )

	// Tabelas posicionadas no laco de processamento da query
	SE1 -> ( dbSetOrder ( 1 ) ) //FILIAL+PREFIXO+NUM+PARCELA+TIPO
	SED -> ( dbSetOrder ( 1 ) )
	SA1 -> ( dbSetOrder ( 1 ) )
		
	dbSelectArea(cAliasQry) 		
	cAliasSPED := cAliasQry
	aTitRet		:= {}		
	While !(cAliasQry)->(Eof())

      		If (cAliasQry)->SCORGP  = "1" .And. (cAliasQry)->MOTBX == "CMP"  .And. "NCC" $ (cAliasQry)->DOCUMEN              
				(cAliasQry)->(Dbskip())			   
				Loop						
			Endif
			
			If !Empty(cRASpd) .And. 'RA' $ (cAliasQry)->DOCUMEN .And.;  //Caso tenham naturezas tenho que antecipar o credito do tipo RA.
				SE1->(DbSeek(xFilial("SE1") + (cAliasQry)->DOCUMEN )) .And. Alltrim(SE1->E1_NATUREZ) $ cRASpd
				(cAliasQry)->(Dbskip())		   
				Loop
			EndIf
			
			//Verifica��o de reten��o na baixa do t�tulo gerado em lei antiga...
			If lMvImpBxCR .And. (cAliasQry)->E1_EMISSAO < dLastPcc .And. ( (cAliasQry)->E1_SABTPIS > 0 .Or. (cAliasQry)->E1_SABTCOF > 0 )
				If !TemImpBx( (cAliasQry)->E1RECNO , cDataIni , cDataFim )
					(cAliasQry)->( Dbskip() )
					Loop
				EndIf
			EndIf

			lTitRet	:=	.F.			
			aTitRet	:= {}		
			If (cAliasQry)->VALORE1 <= nVlMinImp 
				SFQ->(DbSetOrder(2)) // FQ_FILIAL+FQ_ENTDES+FQ_PREFDES+FQ_NUMDES+FQ_PARCDES+FQ_TIPODES+FQ_CFDES+FQ_LOJADES
				If SFQ->(DbSeek(xFilial("SFQ")+"SE1"+ (cAliasQry)->PREFIXO + (cAliasQry)->NUMERO + (cAliasQry)->PARCELA + (cAliasQry)->TIPO + (cAliasQry)->CLIENTE + (cAliasQry)->LOJA ))             								
					Aadd(aTitRet,{(xFilial("SE1") + SFQ->FQ_PREFORI + SFQ->FQ_NUMORI + SFQ->FQ_PARCORI + SFQ->FQ_TIPOORI + SFQ->FQ_CFORI+ SFQ->FQ_LOJAORI),;
											(cAliasQry)->PIS,(cAliasQry)->COFINS,(cAliasQry)->CSLL,	(cAliasQry)->VRIR,(cAliasQry)->VRISS,(cAliasQry)->VRINSS})					
					lTitRet	:=	.T.																													
				Endif											
		    EndIf
		    
		    lRetSFQ		:=.F. //Retem valores de impostos de outros titulos.
			SFQ->(DbSetOrder(1)) // FQ_FILIAL + FQ_ENTORI + FQ_PREFORI + FQ_NUMORI + FQ_PARCORI + FQ_TIPOORI + FQ_CFORI + FQ_LOJAORI
			If SFQ->(DbSeek(xFilial("SFQ")+"SE1"+ (cAliasQry)->PREFIXO + (cAliasQry)->NUMERO + (cAliasQry)->PARCELA + (cAliasQry)->TIPO + (cAliasQry)->CLIENTE + (cAliasQry)->LOJA))
			   	lRetSFQ	:=	.T.		
			   	If Len(aTitRet) == 0
			   		While SFQ->FQ_FILIAL + SFQ->FQ_ENTORI + SFQ->FQ_PREFORI + SFQ->FQ_NUMORI + SFQ->FQ_PARCORI + SFQ->FQ_TIPOORI + SFQ->FQ_CFORI + SFQ->FQ_LOJAORI ==	xFilial("SFQ") +;
			   			( "SE1" + (cAliasQry)->PREFIXO + (cAliasQry)->NUMERO + (cAliasQry)->PARCELA + (cAliasQry)->TIPO + (cAliasQry)->CLIENTE + (cAliasQry)->LOJA)			   	
			   			SE1 -> ( dbSetOrder ( 1 ) ) //FILIAL+PREFIXO+NUM+PARCELA+TIPO 
						If SE1 -> ( dbSeek ( xFilial("SE1") + SFQ->FQ_PREFDES + SFQ->FQ_NUMDES + SFQ->FQ_PARCDES + SFQ->FQ_TIPODES ) )			
			   				Aadd(aTitRet,{(xFilial("SE1") + SFQ->FQ_PREFDES + SFQ->FQ_NUMDES + SFQ->FQ_PARCDES + SFQ->FQ_TIPODES + SFQ->FQ_CFDES+ SFQ->FQ_LOJADES),;
											SE1->E1_PIS,SE1->E1_COFINS,SE1->E1_CSLL,	SE1->E1_IRRF , SE1->E1_ISS, SE1->E1_INSS})					
						Endif
			   			SFQ->(Dbskip())			   			
			   		Enddo			   		
			   	Endif		   			        			   				        			   	
			Endif			
		    
			If (cAliasQry)->MOTBX $ 'NOR_CMP'
				cChaveBx		:=	SpdMotNOR((cAliasQry)->( FILIAL + PREFIXO + NUMERO + PARCELA + TIPO))
				If Empty(cChaveBx)
					(cAliasQry)->(Dbskip())
					Loop
				Endif
			ElseIf (cAliasQry)->MOTBX = 'TRF'
				aSpdMotTRF	:=	SpdMotTRF((cAliasQry)->( PREFIXO + NUMERO + PARCELA + TIPO + FILORIG))
                        
				If !aSpdMotTRF[3] .Or. !aSpdMotTRF[1]  
					(cAliasQry)->( dbSkip())
					Loop
				Endif

				If aSpdMotTRF[1] 
					cAliasQry := aSpdMotTRF[2] // novo alias a ser tratado
				Endif
			Endif  			

			cChaveBx		:=	(cAliasQry)->FILIAL + (cAliasQry)->PREFIXO + (cAliasQry)->NUMERO + (cAliasQry)->PARCELA + (cAliasQry)->TIPO + (cAliasQry)->CLIENTE + (cAliasQry)->LOJA 
			nJurosBx		:=	 nDescBx		:=		nVlrSe5		:=	0
			nTpMoeda		:=	(cAliasQry)->TPMOEDA
			aSpdMotTRF	:= {}
			aRegBx		:=	{}
			nVrPIS		:=		nVrCOFINS	:=	nVrCSLL :=	nVrIR	:=	nVrISS :=	nVrINSS	:=	0                            
					
			// Posiciona no cliente e loja e natureza do titulo que serao processadas as movimentacoes no loop abaixo
			SA1->( MsSeek( xFilial("SA1") + (cAliasQry)->CLIENTE + (cAliasQry)->LOJA ) )
		
			// Indica se a retencao do IR (carteira Receber) sera feita no CP
			lIrrfSE2 := (cPaisLoc == "BRA" .And. SA1->A1_RECIRRF == "2" .And.; 
						(cAliasQry)->RECIRRF <> '1' .And. (cAliasQry)->CALCIRF == "S")
			lIssSE2  := (cPaisLoc == "BRA" .And. SA1->A1_RECISS == "2" .And. lMVDescIss)

			If Select ("SF2") > 0
				aAreaSF2 := SF2->(GetArea())
				DbSelectArea("SF2")
				DbSetOrder(1)
				lSF2 := .T.
			EndIf		
			
			While  (cAliasQry)->( !EoF()) .AND. cChaveBx ==  ( (cAliasQry)->FILIAL + (cAliasQry)->PREFIXO + (cAliasQry)->NUMERO + (cAliasQry)->PARCELA + (cAliasQry)->TIPO + (cAliasQry)->CLIENTE + (cAliasQry)->LOJA ) 
			
				SED->( MsSeek( xFilial("SED") + (cAliasQry)->NATUREZ ) )

				If !Empty(cPeNat) .And. !SED->ED_INDRET $ cNatur 
					(cAliasQry)->( dbSkip() )
					Loop
				Endif		                

				If (cAliasQry)->TIPO $ ( MVABATIM + MV_CRNEG + MVPROVIS )
					(cAliasQry)->( dbSkip() )
					Loop
				EndIf	

				lRecIss := (SA1->A1_RECISS == "1" .And. lMVDescIss)                                  
		
				If !Empty((cAliasQry)->PEDIDO) .And. Alltrim((cAliasQry)->ORIGEM) == "MATA460"									
					SC5->(Dbsetorder(3)) //C5_FILIAL+C5_CLIENTE+C5_LOJACLI+C5_NUM
					If SC5->(Dbseek(xFilial("SC5") + (cAliasQry)->CLIENTE + (cAliasQry)->LOJA + (cAliasQry)->PEDIDO )) .And. !Empty(SC5->C5_RECISS)				    
						lRecIss := (SC5->C5_RECISS == "1" .And. lMVDescIss)				    
					ElseIf lSF2 .And. (SF2->( MsSeek((cAliasQry)->(FILIAL + NUMERO + PREFIXO + CLIENTE + LOJA ))) .And. !Empty(SF2->F2_RECISS) )		
						lRecIss := (SF2->F2_RECISS == "1" .And. lMVDescIss)
				    Endif
				Endif										
				
				nVrPIS		:=	(cAliasQry)->PIS
				nVrCOFINS	:=	(cAliasQry)->COFINS
				nVrCSLL		:=	(cAliasQry)->CSLL
				nVrIR		:=	If(lIrrfSE2,0,(cAliasQry)->VRIR)
				nVrISS		:=	If(lIssSE2,0,(cAliasQry)->VRISS)
				nVrINSS		:=	(cAliasQry)->VRINSS

				If lRetSFQ //Caso seja titulo que retenha outro com cumulatividades diferentes devo entao subtrair os valores para nao enviar duas vezes.
					For nI:= 1 To Len(aTitRet)
						nVrPIS		-=	aTitRet[nI,2]
						nVrCOFINS	-=	aTitRet[nI,3]
						nVrCSLL		-=	aTitRet[nI,4]
						nVrIR		-=	aTitRet[nI,5]
						nVrISS		-=	aTitRet[nI,6]
						nVrINSS		-=	aTitRet[nI,7]																									
					Next
				Endif
				
				If (cAliasQry)->TIPODOC $ "JR_MT_J2_M2"
					nJurosBx	+= (cAliasQry)->VALORE5	 
				ElseIf(cAliasQry)->TIPODOC $ "DC_CM_D2_C2"
			     	nDescBx	+= (cAliasQry)->VALORE5													
				ElseIf !(cAliasQry)->TIPODOC $ "JR_MT_J2_M2_DC_CM_D2_C2"
					nVlrSe5	+=	(cAliasQry)->VALORE5			     					
					aRegBx	:= {}													         					
	               nTxMoeda	:= 1
               
					If (cAliasQry)->MULTNAT = "1" //Tratamento para multiplas naturezas.			
						aAreaSEV := SEV->(GetArea())
						DbSelectArea("SEV")
						DbSetOrder(1)	//Verificar se o titulo possui multiplas naturezas.
						SEV->(DbSeek(xFilial("SEV")+(cAliasQry)->PREFIXO+(cAliasQry)->NUMERO+(cAliasQry)->PARCELA+(cAliasQry)->TIPO+(cAliasQry)->CLIENTE+(cAliasQry)->LOJA))
						While SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA) ==;
								((cAliasQry)->PREFIXO+(cAliasQry)->NUMERO+(cAliasQry)->PARCELA+(cAliasQry)->TIPO+(cAliasQry)->CLIENTE+(cAliasQry)->LOJA) .And. !SEV->(EOF())					
								
								nVrRateio:=	0
								
								If nTpMoeda > 1
									nTxMoeda	:= (cAliasQry)->VLCRUZ	/(cAliasQry)->VALORE1
								Endif							
								
								If SEV->EV_IDENT <> "1" // 1=Rateio de Inclusao 2=Rateio de Baixa 
									SEV->(Dbskip())
									Loop							
								Endif								
								
								aAreaSED := SED->(GetArea()) //Caso a natureza apure Pis ou Cofins
								DbSelectArea("SED")							
								DbSetOrder(1)			
								If DbSeek(xFilial("SED")+ SEV->EV_NATUREZ) .And. !Empty(SED->ED_PERCPIS) .Or. !Empty(SED->ED_PERCCOF)										
												   
									   nVrRateio	:=	SEV->EV_PERC
														                                                   
                                        AaDd(aRegBx,{SA1->A1_CGC,; //1
                                        (cAliasQry)->DATAM,;//2
                                        ((SEV->EV_VALOR*nTxMoeda)*SED->ED_PERCPIS)/100,;//3
                                        ((SEV->EV_VALOR*nTxMoeda)*SED->ED_PERCCOF)/100,;//4
                                        ((SEV->EV_VALOR*nTxMoeda)*SED->ED_PERCCSL)/100,;//5
                                        (cAliasQry)->VALORE1,;//6
                                        (cAliasQry)->VALORE5,;//7
                                        SA1->A1_RECPIS,;//8
                                        SA1->A1_RECCOFI,;//9
                                        SED->ED_PERCPIS,;//10
                                        SED->ED_INDRET,;//11
                                        SED->ED_INDCMLT,;//12
                                        (cAliasQry)->RECNO,;//13
                                        SED->ED_COND,;//14
                                        (cAliasQry)->SALDO,;//15
                                        nVrIR,;//16
                                        If(lRecIss, nVrISS,0),;//17
                                        nVrINSS,;//18
                                        (cAliasQry)->VLCRUZ,;//19
                                        SA1->A1_INDRET,;//20
                                        (cAliasQry)->BASEPIS,;//21
                                        (cAliasQry)->ORIGEM,;//22
										Iif(lRetSFQ,((cAliasQry)->PIS+(cAliasQry)->COFINS+(cAliasQry)->CSLL+(cAliasQry)->VRIR+Iif(lRecIss,(cAliasQry)->VRISS,0)+(cAliasQry)->VRINSS),0),;//23
                                        (cAliasQry)->MULTNAT,;//24
                                        nVrRateio,;//25
                                        SED->ED_PERCCOF,;//26
                                        nVrPIS,;//27
                                        nVrCOFINS,;//28
                                        nVrCSLL,;//29
                                        (cAliasQry)->SEQ,;//30
                                        (cAliasQry)->FILIAL + (cAliasQry)->PREFIXO + (cAliasQry)->NUMERO + (cAliasQry)->PARCELA + (cAliasQry)->TIPO + (cAliasQry)->CLIENTE + (cAliasQry)->LOJA})//31
								Endif
								RestArea(aAreaSED)								        		
								SEV->(Dbskip())
						Enddo
					   RestArea(aAreaSEV)										
					Else //Nao trata de multiplas naturezas
						AaDd(aRegBx,{SA1->A1_CGC,;  // 1
											(cAliasQry)->DATAM,;  // 2
											nVrPIS,;  // 3
											nVrCOFINS,;  // 4
											nVrCSLL,;  // 5
										 	(cAliasQry)->VALORE1,;  // 6
										 	(cAliasQry)->VALORE5,;  // 7
										 	SA1->A1_RECPIS,;  // 8
										 	SA1->A1_RECCOFI,;  // 9
										  	SED->ED_PERCPIS,;  // 10
										  	SED->ED_INDRET,;  // 11
										  	SED->ED_INDCMLT,;  // 12
										  	(cAliasQry)->RECNO,;  // 13
										  	SED->ED_COND,;  // 14
										  	(cAliasQry)->SALDO,;  // 15
										  	nVrIR,;  // 16
										  	If(lRecIss, nVrISS,0),;  // 17
										  	nVrINSS,;  // 18
										  	(cAliasQry)->VLCRUZ,;  // 19
										  	SA1->A1_INDRET,;  // 20
										  	(cAliasQry)->BASEPIS,;  // 21
										  	(cAliasQry)->ORIGEM,;  // 22
										  	Iif(lRetSFQ,    ( (cAliasQry)->PIS+(cAliasQry)->COFINS+(cAliasQry)->CSLL+(cAliasQry)->VRIR+(cAliasQry)->VRINSS+;
										  							Iif(lRecIss,  (cAliasQry)->VRISS,0)),;
										  							0),;	// 23
										  	(cAliasQry)->MULTNAT,;  // 24
										  	0,;  // 25
										  	SED->ED_PERCCOF,;  // 26
										  	0,;  // 27
										  	0,;  // 28
                                            0,;//29
                                            (cAliasQry)->SEQ,;//30
                                            (cAliasQry)->FILIAL + (cAliasQry)->PREFIXO + (cAliasQry)->NUMERO + (cAliasQry)->PARCELA + (cAliasQry)->TIPO + (cAliasQry)->CLIENTE + (cAliasQry)->LOJA})  // 31
						EndIf
					Endif													
				(cAliasQry)->(Dbskip())	
			
				If (cAliasQry)->(Eof()) .and. (cAliasQry <> cAliasSPED)
			   	(cAliasQry)->(dbCloseArea())
			   	cAliasQry := cAliasSPED
  					(cAliasQry)->(Dbskip())
			   Endif

			EndDo

			If !Empty( aAreaSF2 )
				RestArea(aAreaSF2)
			EndIf

			If Len(aRegBx) = 0
				Loop
			EndIf
			
			nTotPis	:= 0
			nTotCof	:= 0
			nTotCsll	:= 0
			If lTotalImp	
				For nI:=1 to Len(aTitRet)
					nTotPis += aTitRet[nI][2]
					nTotCof += aTitRet[nI][3]
					nTotCsll += aTitRet[nI][4]
				Next
			EndIf		
           
            For nI:=1 TO Len(aRegBx)
                
                aF600 	    := Array(12)
				nPisBx	    := 0
				nCofBx	    := 0							
                nBase	    := 0
                
                // verifica se � a ultima baixa
                lMaxSeq    := MaxSeq(aRegBx[nI,30], aRegBx[nI,31])

				If Alltrim(aRegBx[nI,22]) == "MATA460" .And. (aRegBx[nI,15] == 0) .And. cTpAbIss == "1" .And. lMaxSeq
					nPercBx	:=	((( nVlrSe5 + (aRegBx[nI,3]+aRegBx[nI,4]+aRegBx[nI,5]+aRegBx[nI,16]+aRegBx[nI,18]) - nJurosBx + nDescBx ) *100)/ aRegBx[nI,6])
				ElseIf aRegBx[nI,15] > 0 //Titulo nao baixado totalmente
					nPercBx	:=	((( nVlrSe5 - nJurosBx + nDescBx ) *100)/ If(nTpMoeda>1,aRegBx[nI,7],aRegBx[nI,6]))	
				ElseIf aRegBx[nI,24] = "1"     //Multiplas naturezas.
					If aRegBx[nI,15] == 0 .and. aRegBx[nI,6] == aRegBx[nI,7]//baixado totalmente e n�o descontou os impostos
						nPercBx	:=	(((nVlrSe5 - nJurosBx + nDescBx ) *100)/ aRegBx[nI,6])
					ElseIf Len(aTitRet) > 0
						nPercBx	:=	(((nVlrSe5 + (aRegBx[nI,27]+nTotPis+aRegBx[nI,28]+nTotCof+aRegBx[nI,29]+nTotCsll) - nJurosBx + nDescBx ) *100)/ aRegBx[nI,6])
						lTotalImp := .F.
					Else
						nPercBx	:=	(((nVlrSe5 + (aRegBx[nI,16]+aRegBx[nI,17]+aRegBx[nI,18]+aRegBx[nI,27]+aRegBx[nI,28]+aRegBx[nI,29]) - nJurosBx + nDescBx ) *100)/ aRegBx[nI,6])
					EndIf					
					If nTpMoeda > 1
						nPercBx	:= (nPercBx)/nTxMoeda
					Endif															
				Else// baixa total ou ultima baixa do titulo precisa acrescentar o valor dos impostos descontados na movimentacao do SE5            
					If nTpMoeda > 1
						nPercBx	:=	((( aRegBx[nI,19] - nJurosBx + nDescBx ) *100)/ aRegBx[nI,19])
					ElseIf lTitRet //titulo retido em outro
						nPercBx	:=	((nVlrSe5 + aRegBx[nI,16]+aRegBx[nI,17]+aRegBx[nI,18]) *100)/ aRegBx[nI,6]
					ElseIf aRegBx[nI,15] == 0 .and. lMaxSeq //baixado totalmente e � ultima baixa
                        nPercBx	:=	((( nVlrSe5 +(aRegBx[nI,3]+aRegBx[nI,4]+aRegBx[nI,5]+aRegBx[nI,16]+aRegBx[nI,17]+aRegBx[nI,18] + ;
                        if(lRetSFQ,aRegBx[nI,23],0)	 - nJurosBx + nDescBx )) *100)/ aRegBx[nI,6])        
                    Else
                        nPercBx	:=	((( nVlrSe5 - nJurosBx + nDescBx ) *100)/ aRegBx[nI,6])        
					Endif							
				Endif
				
				nPisBx	:=	(aRegBx[nI,3]	* nPercBx)/100
				nCofBx	:=	(aRegBx[nI,4]	* nPercBx)/100         
				
				If nVlrSe5 <= nVlMinImp .And. nPercBx > 100 //Para casos de titulos gerados com valor que nao retenha imposto.
					nPisBx	:=	0
					nCofBx	:=	0							
				Endif						
				
				//Calculo inverso da reten��o para achar a base
				If nTpMoeda > 1
					nBase 	:= Round((((aRegBx[nI,19]*aRegBx[nI,10])/100)* nPercBx)/ aRegBx[nI,10],2)										
				ElseIf aRegBx[nI,15] > 0 //.Or. lRetSFQ //Titulo nao baixado totalmente ou titulo que retem impostos de outros titulos.		
					nBase 	:= Round((aRegBx[nI,3] * nPercBx)/ aRegBx[nI,10],2)						
					If (nBase < aRegBx[nI,7] .And. (aRegBx[nI,7] - nBase) < 1) .Or.; // Problema com arredondamento diferenca a menor
						(nBase > aRegBx[nI,7] .And. (nBase - aRegBx[nI,7]) < 1) //diferenca a maior					    
						nBase	:=	aRegBx[nI,7]
					Endif
				Else				
					nBase 	:=	aRegBx[nI,21]
					If aRegBx[nI,3]  == Round((aRegBx[nI,6] * (aRegBx[nI,10]/100)), 2) .or. aRegBx[nI,3]  == NoRound((aRegBx[nI,6] * (aRegBx[nI,10]/100)), 2) 
						nVlPis	:= aRegBx[nI,6] * (aRegBx[nI,10]/100) // voltar as casas decimais
					Else
						nVlPis	:= aRegBx[nI,3]
					EndIf
					If nPercBx == 100 .And. nBase <> Round((nVlPis * nPercBx)/ aRegBx[nI,10],2)
						nBase := Round((aRegBx[nI,3] * nPercBx)/ aRegBx[nI,10],2)
					EndIf 				
				Endif												
				
				If aRegBx[nI,24] = "1" .And.  !(aRegBx[nI,15] > 0)     //Multiplas naturezas.)
				   nBase		:=	nBase * aRegBx[nI,25]
			   Endif
						   
				//Indicador da reten��o			
				If	Empty(aRegBx[nI,11]) 
					aF600[1] := aRegBx[nI,20]				
				Else 
					aF600[1] := aRegBx[nI,11]
				Endif										
			    
			   aF600[2] := aRegBx[nI,2] 			//-- Data da emiss�o
			   aF600[3] := nBase 					//-- Base do imposto
			   aF600[4] := nPisBx + nCofBx 		//-- Valor da reten��o
			    
			   //Indicador de cumulatividade das naturezas de receita
			    If aRegBx[nI,12] == "1" 
			    	cIndCmlt := "0" //Cumulativo
			    ElseIf aRegBx[nI,12] == "2"
			       	cIndCmlt := "1" //N�o Cumulativo
				EndIf
			    	
			    aF600[5] := Iif(aRegBx[nI,14] == "R", cIndCmlt, "")
			    
				aF600[6] := aRegBx[nI,1] 			//-- CNPJ do cliente
				aF600[7] := nPisBx 	 				//-- Valor da reten��o de PIS
			   aF600[8] := nCofBx 					//-- Valor da reten��o de COFINS
			    
			   //Indicador da pessoa declarante
			   If (aRegBx[nI,8] $ "SP" .Or. aRegBx[nI,9] $ "SP") .And. SM0->M0_CGC <> aRegBx[nI,1] 	  						//-- Empresa benefici�ria da reten��o
			   	aF600[9] := "0"
			   ElseIf (aRegBx[nI,8] $ "SP" .Or. aRegBx[nI,9] $ "SP") .And. SM0->M0_CGC == aRegBx[nI,1] //-- Empresa respons�vel pelo recolhimento
			   	aF600[9] := "1"
			   EndIf
			    
			   aF600[10] := "SE5" 					//-- Tabela
			   aF600[11] := aRegBx[nI,13] 		//-- Recno 
			   
				If lSPDCodR2
					cPeCodRec := ExecBlock ("SPDF6004",.F.,.F.,{aF600})	
					If Len(cPeCodRec) > 4
						cPeCodRec := Subst(cPeCodRec,1,4)	 			
					Endif
				EndIf
			   	
			   If (lSpdCodRec .Or. lSPDCodR2) .And. !Empty(cPeCodRec)
					aF600[12] := cPeCodRec 			//-- Codigo da Receita			 					
				Else
					aF600[12] := ""		 			//-- Codigo da Receita			 									
				Endif
			    
			   aAdd(aReturn, aF600)
			   nBase := 0
			Next   		      		    
	EndDo

	(cAliasQry)->(dbCloseArea())    

Else					
	
	//PIS e COFINS na baixa
		
	cAliasQry	:= "SE5QRY"
	aStruct	 	:= SE5->(dbStruct())
			
	cQuery	 	:= "SELECT " 
		
	//Campos de refer�ncia
	cQuery	 	+= "SE5.E5_FILIAL FILIAL, SE5.E5_PREFIXO PREFIXO, SE5.E5_NUMERO NUMERO, SE5.E5_PARCELA PARCELA, SE5.E5_TIPO TIPO, SE5.E5_CLIFOR CLIENTE, "
	cQuery		+= "SE5.E5_LOJA LOJA, SE5.E5_TXMOEDA TXMOEDA, SE5.E5_MOTBX MOTBX, SE5.E5_FILORIG FILORIG, "
	cQuery	 	+= "SE5.E5_TIPODOC TIPODOC, SE5.E5_PRETPIS PRETPIS, SE5.E5_DOCUMEN DOCUMEN, SE5.E5_VLMOED2 VLMOED2, SE5.E5_PRETCOF PRETCOF, " 				
	cQuery	 	+= "SE5.E5_DATA DATAM, SE5.E5_VALOR VALORBX, SE5.E5_VRETPIS PIS, SE5.E5_VRETCOF COFINS, SE5.E5_VRETCSL CSL, SE5.E5_SEQ SEQ , "  
	cQuery	 	+= "SE5.R_E_C_N_O_ RECNO, " 		
					
	//Campos do SED
	cQuery	 	+= "SED.ED_PERCPIS PERCPIS, SED.ED_COND COND, SED.ED_PERCCOF PERCCOF, SED.ED_CODIGO CODIGO, " 		 		

	//Indicador de Reten��o
	cQuery	+= "SED.ED_INDRET INDRET, "
			
	//Indicador de Cumulatividade
	cQuery	+= "SED.ED_INDCMLT INDCMLT, "

	//Dados do cliente para o SPED
	cQuery	 	+= "SA1.A1_CGC CNPJ, SA1.A1_RECPIS RECPIS, SA1.A1_RECCOFI RECCOFI "					
	cQuery	 	+= ", SA1.A1_INDRET A1INDRET "					
	cQuery	 	+= "FROM "		
	cQuery 		+= RetSqlName("SE5") + " SE5,  "
	cQuery 		+= RetSqlName("SED") + " SED,  "		
	cQuery 		+= RetSqlName("SA1") + " SA1   "		
			
	cQuery	 	+= "WHERE " 		
		
	cQuery	 	+=	"SED.ED_FILIAL='" + xFilial("SED") + "' AND " 							
	cQuery 		+=	"SA1.A1_FILIAL ='" + xFilial("SA1") + "' AND "
  
	If !Empty( Iif( lUnidNeg, FWFilial("SE5") , xFilial("SE5") ) )
		cQuery 	+= "SE5.E5_FILIAL = '"  + xFilial("SE5") + "' AND "
	Else
			If lSe5MsFil
				cQuery 	+= "SE5.E5_MSFIL = '" + Iif(lUnidNeg, cFilSe5, cFilAnt) + "' AND "					
			Else	
				cQuery 	+= "SE5.E5_FILORIG = '" + Iif(lUnidNeg, cFilSe5, cFilAnt) + "' AND "	
			Endif	
	EndIf   					

	cQuery	 	+= "SE5.E5_CLIFOR = SA1.A1_COD AND "
	cQuery	 	+= "SE5.E5_LOJA = SA1.A1_LOJA AND "				
	cQuery	 	+= "(SE5.E5_DATA >= '"+cDataIni+"' AND SE5.E5_DATA <= '"+cDataFim+"') AND "
	cQuery		+= "SE5.E5_SITUACA <> 'C' AND "			
	cQuery	 	+= "SE5.E5_RECPAG = 'R' AND "		
		
	cTipoTit		:=	""
	cTipoTit		:=	MVABATIM + "|" + MV_CRNEG + "|" + MVPROVIS 
	cQuery 		+= "SE5.E5_TIPO NOT IN " + FormatIn(cTipoTit,If("|"$cTipoTit,"|",","))  + " AND "		

	cMotQry		:= "('FAT','LIQ'"
			
	If !Empty(cPeMBx)                    
		cMotQry += "," + cMotBaixa
	Endif                        
				
	If !Empty(cBxSql)
		cMotQry += "," + cBxSql
	EndIf                       
		
	cMotQry		+= ")"
			
	cQuery		+= "SE5.E5_MOTBX NOT IN " + cMotQry + " AND "
								
	//Exclui os titulos que possuem estorno
	cQuery	 	+= "SE5.E5_SEQ NOT IN "
	cQuery 		+= "(SELECT SE5AUX.E5_SEQ FROM "+RetSqlName("SE5")+" SE5AUX WHERE "
	cQuery		+=		" SE5AUX.E5_FILIAL = SE5.E5_FILIAL AND "
	cQuery		+= 		" SE5AUX.E5_PREFIXO = SE5.E5_PREFIXO AND "
	cQuery		+= 		" SE5AUX.E5_NUMERO = SE5.E5_NUMERO AND  "
	cQuery		+= 		" SE5AUX.E5_PARCELA = SE5.E5_PARCELA AND " 
	cQuery		+= 		" SE5AUX.E5_TIPO = SE5.E5_TIPO AND " 
	cQuery		+= 		" SE5AUX.E5_CLIFOR = SE5.E5_CLIFOR AND " 
	cQuery		+= 		" SE5AUX.E5_LOJA = SE5.E5_LOJA AND "     
	cQuery		+= 		" SE5AUX.E5_TIPODOC = 'ES' AND "
	cQuery		+= 		" SE5AUX.D_E_L_E_T_ = ' ' "
	cQuery 		+= ") AND "      

	If !Empty(cPeNat)
		cQuery 	+= "SED.ED_INDRET NOT IN (" + cNatur + ") AND " 
	Endif		
                                                     
	cQuery	 	+= "SED.ED_CODIGO = SE5.E5_NATUREZ AND "

	cQuery		+= "SED.D_E_L_E_T_ = ' ' AND "
	cQuery		+= "SE5.D_E_L_E_T_ = ' ' AND "
	cQuery		+= "SA1.D_E_L_E_T_ = ' ' 	"
			
	cQuery 		:= ChangeQuery(cQuery)                 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
			
	For nX := 1 To len(aStruct)
			If aStruct[nX][2] <> "C" .And. FieldPos(aStruct[nX][1])<>0
			TcSetField(cAliasQry,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf                                          
			
	Next nX

	SE1 -> ( dbSetOrder ( 1 ) ) //FILIAL+PREFIXO+NUM+PARCELA+TIPO
	SA1 -> ( dbSetOrder ( 1 ) ) //FILIAL+COD+LOJA
	SED -> ( dbSetOrder ( 1 ) ) //FILIAL+CODIGO
				
	aTitRet	:= {}				
	dbSelectArea(cAliasQry) 
	cAliasSPED := cAliasQry		
	While !(cAliasQry)->(Eof())
                               
			If (cAliasQry)->MOTBX == "CMP"  .And. "NCC" $ (cAliasQry)->DOCUMEN 
				If SE1->(DbSeek(xFilial("SE1") + (cAliasQry)->PREFIXO + (cAliasQry)->NUMERO + (cAliasQry)->PARCELA + (cAliasQry)->TIPO )) 							
					If SE1->E1_SCORGP = "1" 
						(cAliasQry)->(Dbskip())			   
						Loop						
					Endif
				Endif	
			Endif     

			If !Empty(cRASpd) .And. MVRECANT $ (cAliasQry)->TIPO .And.;//Caso tenham naturezas tenho que antecipar o credito do tipo RA (MV_NTRASPD).
				SE1->(DbSeek(xFilial("SE1") + (cAliasQry)->DOCUMEN )) .And. Alltrim(SE1->E1_NATUREZ) $ cRASpd
				(cAliasQry)->(Dbskip())			   
				Loop
			ElseIf MVRECANT $ (cAliasQry)->TIPO .And.;//Caso seja um RA sem compensar que n�o ser� antecipado.
				SE1->(DbSeek(xFilial("SE1") + (cAliasQry)->PREFIXO + (cAliasQry)->NUMERO + (cAliasQry)-> PARCELA + (cAliasQry)->TIPO ))
				(cAliasQry)->(Dbskip())			   
				Loop
			Endif
			
			//Titulo compensado com Reten��o Antecipada
			If !Empty(cRASpd) .And. (cAliasQry)->MOTBX == "CMP" .And. ;
				!((cAliasQry)->TIPO $ MVRECANT) .And. ;
				SE1->(DbSeek(xFilial("SE1") + (cAliasQry)->DOCUMEN)) .And. ;		
				Alltrim(SE1->E1_NATUREZ) $ cRASpd .And. ;
				(SE1->E1_TIPO $ MVRECANT) .And. ;
				Dtos(SE1->E1_EMISSAO) < cDataIni
				
				(cAliasQry)->(Dbskip())			   
				Loop

			Endif
			
			If (Alltrim((cAliasQry)->RECPIS) == "N" .And. Alltrim((cAliasQry)->RECCOFI) == "N") .Or. ((cAliasQry)->(PERCPIS+PERCCOF) <= 0 .And. (cAliasQry)->RECPIS <> "P" .And. (cAliasQry)->RECCOFI <> "P")
			 	(cAliasQry)->(Dbskip())			   
				Loop
			Endif	
			
			aRet		:=	{}
			aRegBx		:= {}			
			aTitRet	:= {}
			cChaveBx	:=	""
			
			If (cAliasQry)->MOTBX $ 'NOR_CMP'
				cChaveBx		:=	SpdMotNOR((cAliasQry)->( FILIAL + PREFIXO + NUMERO + PARCELA + TIPO))
				If Empty(cChaveBx)
					(cAliasQry)->(Dbskip())
					Loop
				Endif
			ElseIf (cAliasQry)->MOTBX = 'TRF'
				aSpdMotTRF	:=	SpdTRFB((cAliasQry)->( PREFIXO + NUMERO + PARCELA + TIPO + FILORIG))

				If !aSpdMotTRF[3] 
					(cAliasQry)->( dbSkip())
					Loop
				Endif

				If aSpdMotTRF[1] 
					cAliasQry := aSpdMotTRF[2] // novo alias a ser tratado
				Endif
			Endif  									
			
			cChaveDes	:=	cChaveOri	:=	""
			cIndCmlDes	:=	cIndCmlOri	:= ""		
			
			If stod((cAliasQry)->DATAM) >= ctod("22/06/2015")
				nVlMinImp	:= 0
			EndIf
			
			If (cAliasQry)->VALORBX <= nVlMinImp //Caso o titulo seja retido em outro nao devo enviar no bloco F600.
				SFQ->(DbSetOrder(2)) // FQ_FILIAL+FQ_ENTDES+FQ_PREFDES+FQ_NUMDES+FQ_PARCDES+FQ_TIPODES+FQ_CFDES+FQ_LOJADES
				If SFQ->(DbSeek(xFilial("SFQ")+"E1B"+ (cAliasQry)->PREFIXO + (cAliasQry)->NUMERO + (cAliasQry)->PARCELA + (cAliasQry)->TIPO + (cAliasQry)->CLIENTE + (cAliasQry)->LOJA ))               
					
					If SE1->(DbSeek(xFilial("SE1") + SFQ->FQ_PREFDES + SFQ->FQ_NUMDES + SFQ->FQ_PARCDES + SFQ->FQ_TIPODES)) 			
						cIndCmlDes	:=	Iif(SED->(Dbseek(xFilial("SED")+SE1->E1_NATUREZ)),SED->ED_INDCMLT,'') //Natureza destino  					
						cChaveDes	:=(xFilial("SE1") + SFQ->FQ_PREFDES + SFQ->FQ_NUMDES + SFQ->FQ_PARCDES + SFQ->FQ_TIPODES)     
					Endif
									
					If SE1->(DbSeek(xFilial("SE1") + SFQ->FQ_PREFORI + SFQ->FQ_NUMORI + SFQ->FQ_PARCORI + SFQ->FQ_TIPOORI)) 
						cIndCmlOri	:= Iif(SED->(Dbseek(xFilial("SED")+SE1->E1_NATUREZ)),SED->ED_INDCMLT,'')	//Natureza origem  
						cChaveOri	:= (xFilial("SE1") + SFQ->FQ_PREFORI + SFQ->FQ_NUMORI + SFQ->FQ_PARCORI + SFQ->FQ_TIPOORI)     
					Endif
					
					If Alltrim(cIndCmlDes) == Alltrim(cIndCmlOri) 											
						aRegBx	:= {}			
						cChaveBx	:=	""
						If (cAliasQry)->MOTBX $ 'NOR_CMP'
							cChaveBx		:=	SpdMotNOR((cAliasQry)->( FILIAL + PREFIXO + NUMERO + PARCELA + TIPO))
							If Empty(cChaveBx)
								(cAliasQry)->(Dbskip())
								Loop
							Endif
						ElseIf (cAliasQry)->MOTBX = 'TRF'
							aSpdMotTRF	:=	SpdTRFB((cAliasQry)->( PREFIXO + NUMERO + PARCELA + TIPO + FILORIG))
			
							If !aSpdMotTRF[3] 
								(cAliasQry)->( dbSkip())
								Loop
							Endif
			
							If aSpdMotTRF[1] 
								cAliasQry := aSpdMotTRF[2] // novo alias a ser tratado
							Endif
						Endif 						
					Else
						Aadd(aTitRet,{(xFilial("SE1") + SFQ->FQ_PREFORI + SFQ->FQ_NUMORI + SFQ->FQ_PARCORI + SFQ->FQ_TIPOORI + SFQ->FQ_CFORI+ SFQ->FQ_LOJAORI),;
											(cAliasQry)->PIS,(cAliasQry)->COFINS,(cAliasQry)->CSL})					
					Endif	
				Endif						
			Endif
			
			
			lRetSFQ		:=.F. //Retem valores de impostos de outros titulos.
			SFQ->(DbSetOrder(1)) // FQ_FILIAL + FQ_ENTORI + FQ_PREFORI + FQ_NUMORI + FQ_PARCORI + FQ_TIPOORI + FQ_CFORI + FQ_LOJAORI
			If SFQ->(DbSeek(xFilial("SFQ")+"E1B"+ (cAliasQry)->PREFIXO + (cAliasQry)->NUMERO + (cAliasQry)->PARCELA + (cAliasQry)->TIPO + (cAliasQry)->CLIENTE + (cAliasQry)->LOJA))
		   		lRetSFQ	:=	.T.			   	
		   	  	If Len(aTitRet) == 0
			   		While SFQ->FQ_FILIAL + SFQ->FQ_ENTORI + SFQ->FQ_PREFORI + SFQ->FQ_NUMORI + SFQ->FQ_PARCORI + SFQ->FQ_TIPOORI + SFQ->FQ_CFORI + SFQ->FQ_LOJAORI ==	xFilial("SFQ") +;
				   			( "E1B" + (cAliasQry)->PREFIXO + (cAliasQry)->NUMERO + (cAliasQry)->PARCELA + (cAliasQry)->TIPO + (cAliasQry)->CLIENTE + (cAliasQry)->LOJA)			   	
				   			SE1 -> ( dbSetOrder ( 1 ) ) //FILIAL+PREFIXO+NUM+PARCELA+TIPO 
						If SE1 -> ( dbSeek ( xFilial("SE1") + SFQ->FQ_PREFDES + SFQ->FQ_NUMDES + SFQ->FQ_PARCDES + SFQ->FQ_TIPODES ) )			
			   				Aadd(aTitRet,{(xFilial("SE1") + SFQ->FQ_PREFDES + SFQ->FQ_NUMDES + SFQ->FQ_PARCDES + SFQ->FQ_TIPODES + SFQ->FQ_CFDES+ SFQ->FQ_LOJADES),;
												SE1->E1_PIS,SE1->E1_COFINS,SE1->E1_CSLL,	SE1->E1_IRRF , SE1->E1_ISS, SE1->E1_INSS})					
						Endif
			   			SFQ->(Dbskip())			   			
			   		Enddo			   		
			   	Endif		   			        			   				 		   	
			Endif					 
		 
		   nVrPIS		:=	(cAliasQry)->PIS
			nVrCOFINS	:=	(cAliasQry)->COFINS
			nVrCSLL		:=	(cAliasQry)->CSL
			
			If lRetSFQ //Caso seja titulo que retenha outro com cumulatividades diferentes devo entao subtrair os valores para nao enviar duas vezes.					                                          								
				For nI:= 1 To Len(aTitRet)
					nVrPIS		-=	aTitRet[nI,2]
					nVrCOFINS	-=	aTitRet[nI,3]
					nVrCSLL	-=	aTitRet[nI,4]						
				Next
			Endif									
				
		  	nTxMoeda	:= If((cAliasQry)->TXMOEDA>1,(cAliasQry)->TXMOEDA,1)
		    
		  	aAreaSEV := SEV->(GetArea())//Tratamento para multiplas naturezas.			
			DbSelectArea("SEV")
			DbSetOrder(1)	//Verificar se o titulo possui multiplas naturezas.
			If	SEV->(DbSeek(xFilial("SEV")+(cAliasQry)->PREFIXO+(cAliasQry)->NUMERO+(cAliasQry)->PARCELA+(cAliasQry)->TIPO+(cAliasQry)->CLIENTE+(cAliasQry)->LOJA))
				While SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA) ==;
						((cAliasQry)->PREFIXO+(cAliasQry)->NUMERO+(cAliasQry)->PARCELA+(cAliasQry)->TIPO+(cAliasQry)->CLIENTE+(cAliasQry)->LOJA) .And. !SEV->(EOF())					
								
						nVrRateio:=	0								
								
						If SEV->EV_IDENT == "1"  // 1=Rateio de Inclusao 2=Rateio de Baixa 
							lIdent	:= .T.
							SEV->(Dbskip())
							Loop							
						Endif								
								
						If ((cAliasQry)->PIS >0 .or. (cAliasQry)->COFINS > 0 ) .AND. !lIdent
							aAreaSED := SED->(GetArea()) //Caso a natureza apure Pis ou Cofins
							DbSelectArea("SED")							
							DbSetOrder(1)			
							If DbSeek(xFilial("SED")+ SEV->EV_NATUREZ) .And. !Empty(SED->ED_PERCPIS) .Or. !Empty(SED->ED_PERCCOF)										
										   
							   nVrRateio	:=	SEV->EV_PERC
											                                                   
 								AaDd(aRegBx,{(cAliasQry)->CNPJ,(cAliasQry)->DATAM,((SEV->EV_VALOR*nTxMoeda)*SED->ED_PERCPIS)/100,;
													((SEV->EV_VALOR*nTxMoeda)*SED->ED_PERCCOF)/100,((SEV->EV_VALOR*nTxMoeda)*SED->ED_PERCCSL)/100,;
												 	((cAliasQry)->VALORBX*nVrRateio),SED->ED_PERCPIS,(cAliasQry)->A1INDRET,SED->ED_INDRET,;
												  	SED->ED_INDCMLT,SED->ED_COND,;
												  	(cAliasQry)->RECCOFI,(cAliasQry)->RECPIS,(cAliasQry)->RECNO,;
												  	(nVrPIS*nVrRateio),(nVrCOFINS*nVrRateio),(nVrCSLL*nVrRateio),"1",0,"",SED->ED_PERCCOF,(cAliasQry)->DOCUMEN})
							Endif
							RestArea(aAreaSED)
						EndIf								        		
						SEV->(Dbskip())
				Enddo
				
				If lIdent .and. ((cAliasQry)->PIS >0 .or. (cAliasQry)->COFINS > 0 )// rateio na emiss�o, ent�o deve ser incluso no array como n�o sendo multiplas naturezas.
					lIdent	:= .F.
					If   !Empty((cAliasQry)->PREFIXO+(cAliasQry)->NUMERO+(cAliasQry)->PARCELA+(cAliasQry)->TIPO)
								AaDd(aRegBx,{(cAliasQry)->CNPJ,(cAliasQry)->DATAM,nVrPIS,nVrCOFINS,nVrCSLL,;
													 	(cAliasQry)->VALORBX,(cAliasQry)->PERCPIS,(cAliasQry)->A1INDRET,(cAliasQry)->INDRET,;
													  	(cAliasQry)->INDCMLT,(cAliasQry)->COND,;
													  	(cAliasQry)->RECCOFI,(cAliasQry)->RECPIS,(cAliasQry)->RECNO,;
													  	0,0,0,"2",(cAliasQry)->VLMOED2,((cAliasQry)->PREFIXO+(cAliasQry)->NUMERO+(cAliasQry)->PARCELA+(cAliasQry)->TIPO),;
													  	(cAliasQry)->PERCCOF,(cAliasQry)->DOCUMEN})
					Endif	
				Endif								
			Else //Nao trata de multiplas naturezas

				If   !Empty((cAliasQry)->PREFIXO+(cAliasQry)->NUMERO+(cAliasQry)->PARCELA+(cAliasQry)->TIPO);
					.and. ((cAliasQry)->PIS >0 .or. (cAliasQry)->COFINS > 0	)
 						AaDd(aRegBx,{(cAliasQry)->CNPJ,(cAliasQry)->DATAM,nVrPIS,nVrCOFINS,nVrCSLL,;
												 	(cAliasQry)->VALORBX,(cAliasQry)->PERCPIS,(cAliasQry)->A1INDRET,(cAliasQry)->INDRET,;
												  	(cAliasQry)->INDCMLT,(cAliasQry)->COND,;
												  	(cAliasQry)->RECCOFI,(cAliasQry)->RECPIS,(cAliasQry)->RECNO,;
												  	0,0,0,"2",(cAliasQry)->VLMOED2,((cAliasQry)->PREFIXO+(cAliasQry)->NUMERO+(cAliasQry)->PARCELA+(cAliasQry)->TIPO),;
												  	(cAliasQry)->PERCCOF,(cAliasQry)->DOCUMEN})
				Endif	
			Endif																									  						  
			For nI:= 1 to Len(aRegBx)
			
				aF600 := Array(12)							
				nPercCof	:=	0
				If !Empty(aRegBx[nI][22])						
					Aadd(aRegCmp,aRegBx[nI][22])
				EndIf	
				     
				//Calculo inverso da reten��o para achar a base
				If nTxMoeda > 1
					nBase := Round((((If(aRegBx[nI,18]="2",(aRegBx[nI,3]+aRegBx[nI,4]+aRegBx[nI,5]),(aRegBx[nI,15]+aRegBx[nI,16]+aRegBx[nI,17]))+aRegBx[nI,6]) *;
																			 aRegBx[nI,7]/100) * 100)/ aRegBx[nI,7],2)		
				Else                                             					 
					If aRegBx[nI,7] == 0 .And. aRegBx[nI,18]="2"  
						//Caso seja um titulo gerado por outro modulo que possua uma natureza sem percentual de imposto. Ou seja, que os Pis e Cofins 
						//por exemplo sejam gerados pelos percentuais do produto.
						SE1 -> ( DbSeek ( xFilial("SE1") + aRegBx[nI,20]) )            						
						nPercPis	:=	(aRegBx[nI,3]/If(SE1->E1_SALDO == 0 ,aRegBx[nI,19],aRegBx[nI,6]))*100										
					Else    
						nPercPis	:=	aRegBx[nI,7]					
						nPercCof	:=	aRegBx[nI,21]											
					Endif
					
					//nBase := Round((aRegBx[nI,3] * 100)/ nPercPis ,2)
					nBase := Round((aRegBx[nI,4] * 100)/ nPercCof ,2)
					
					//Problemas com arredondamento.
					If Round((aRegBx[nI,3] * 100)/ nPercPis ,2) <> Round((aRegBx[nI,4] * 100)/ nPercCof ,2) .And.;
							Round((aRegBx[nI,4] * 100)/ nPercCof ,2) > Round((aRegBx[nI,3] * 100)/ nPercPis ,2) 
						nBase := Round((aRegBx[nI,4] * 100)/ nPercCof ,2)															
					Endif
					
					If aRegBx[nI,18]="2" //N�o � multiplas naturezas //Problema com arredondamento
						If (nBase > (aRegBx[nI,6]+aRegBx[nI,3]+aRegBx[nI,4]+aRegBx[nI,5]) .And. (nBase - (aRegBx[nI,6]+aRegBx[nI,3]+aRegBx[nI,4]+aRegBx[nI,5])) < 1) .Or.;
							(nBase < (aRegBx[nI,6]+aRegBx[nI,3]+aRegBx[nI,4]+aRegBx[nI,5]) .And. ((aRegBx[nI,6]+aRegBx[nI,3]+aRegBx[nI,4]+aRegBx[nI,5])-nBase) < 1)							   
							nBase	:=	aRegBx[nI,19]
						Endif
					Endif
					
					If lRetSFQ					
						If nPercCof > 0 .And. Round((aRegBx[nI,4] * 100)/ nPercCof ,2) > nBase
							nBase	:=	nBase + (Round((aRegBx[nI,4] * 100)/ nPercCof ,2) - nBase)
						Endif					
					Endif					
					
					If 	SE1 -> ( DbSeek ( xFilial("SE1") + aRegBx[nI,20]) ) //Tratando erro de centavos no c�lculo.            						
						If SE1->E1_SALDO == 0 .And. SE1->E1_VALOR > nBase .And. (SE1->E1_VALOR - nBase) <= 0.5
							nBase	:=	SE1->E1_VALOR 						
						Endif					
					Endif
				
				Endif					
	
		    	//Indicador da reten��o
				If Empty(aRegBx[nI,9]) 
					aF600[1] := aRegBx[nI,8]
				Else 
					aF600[1] := aRegBx[nI,9]
				Endif	
			    
		   		aF600[2] := aRegBx[nI,2]					//-- Data da emiss�o			    
			   aF600[3] := nBase 						//-- Base do imposto
			   aF600[4] := aRegBx[nI,3] + aRegBx[nI,4]//-- Valor da reten��o
			    
			   //Indicador de cumulatividade das naturezas de receita
			    If Alltrim(aRegBx[nI,10]) == "1" 
			    	cIndCmlt := "0" //Cumulativo
			    ElseIf Alltrim(aRegBx[nI,10]) == "2"
			       	cIndCmlt := "1" //N�o Cumulativo
		        EndIf		    	
			    	
			    aF600[5] := Iif(Alltrim(aRegBx[nI,11]) == "R", cIndCmlt, "")
			    
			   aF600[6] := aRegBx[nI,1] 	 //-- CNPJ do cliente
			   aF600[7] := aRegBx[nI,3]	 //-- Valor da reten��o de PIS
			   aF600[8] := aRegBx[nI,4]   //-- Valor da reten��o de COFINS
			    
			   //Indicador da pessoa declarante
			   If (aRegBx[nI,13] $ "SP" .Or. aRegBx[nI,12] $ "SP") .And. SM0->M0_CGC <> aRegBx[nI,1]  //-- Empresa benefici�ria da reten��o
			   	aF600[9] := "0"
			   ElseIf (aRegBx[nI,13] $ "SP" .Or. aRegBx[nI,12] $ "SP") .And. SM0->M0_CGC == aRegBx[nI,1] //-- Empresa respons�vel pelo recolhimento
			    	aF600[9] := "1"
			   EndIf
			    
			   aF600[10] := "SE5" 			 //-- Tabela
	 	    	aF600[11] := aRegBx[nI,14] //-- Recno 		   	

				If lSPDCodR2
					cPeCodRec := ExecBlock ("SPDF6004",.F.,.F.,{aF600})	
					If Len(cPeCodRec) > 4
						cPeCodRec := Subst(cPeCodRec,1,4)	 			
					Endif
				EndIf
				If (lSpdCodRec .Or. lSPDCodR2) .And. !Empty(cPeCodRec)
					aF600[12] := cPeCodRec 	 //-- Codigo da Receita			 					
				Else
					aF600[12] := ""		 	//-- Codigo da Receita			 									
				Endif
	 	    	 
			   aAdd(aReturn,aF600)		   
				nBase := 0
		   	nProp := 0
			
			Next 
			(cAliasQry)->(dbSkip())
		
			If (cAliasQry)->(Eof()) .and. (cAliasQry <> cAliasSPED)
		   	(cAliasQry)->(dbCloseArea())
		   	cAliasQry := cAliasSPED
				(cAliasQry)->(Dbskip())
		   Endif
	EndDo		
	 
	(cAliasQry)->(dbCloseArea())
			
Endif

If !Empty(cRASpd) //Enviar somente os titulos do tipo RA caso o parametro esteja configurado para antecipacao de creditos de Pis e Cofins.
		
	cAliasQry	:= "SE5QRY"
	aStruct	 	:= SE5->(dbStruct())
			
	cQuery	 	:= "SELECT " 
		
	//Campos de refer�ncia
	cQuery	 	+= "SE5.E5_FILIAL FILIAL, SE5.E5_PREFIXO PREFIXO, SE5.E5_NUMERO NUMERO, SE5.E5_PARCELA PARCELA, SE5.E5_TIPO TIPO, SE5.E5_CLIFOR CLIENTE, "
	cQuery		+= "SE5.E5_LOJA LOJA, SE5.E5_TXMOEDA TXMOEDA, SE5.E5_MOTBX MOTBX, SE5.E5_FILORIG FILORIG, "
	cQuery	 	+= "SE5.E5_TIPODOC TIPODOC, SE5.E5_PRETPIS PRETPIS, SE5.E5_DOCUMEN DOCUMEN, "		
	cQuery	 	+= "SE5.E5_DATA DATAM, SE5.E5_VLMOED2 VALORBX, " 
	cQuery	 	+= "SE5.R_E_C_N_O_ RECNO, " 		
					
	//Campos do SED
	cQuery	 	+= "SED.ED_PERCPIS PERCPIS, SED.ED_PERCCOF PERCCOF, SED.ED_COND COND, " 		

	//Indicador de Reten��o
	cQuery	+= "SED.ED_INDRET INDRET, "
			
	//Indicador de Cumulatividade
	cQuery	+= "SED.ED_INDCMLT INDCMLT, "
		
	//Dados do cliente para o SPED
	cQuery	 	+= "SA1.A1_CGC CNPJ, SA1.A1_RECPIS RECPIS, SA1.A1_RECCOFI RECCOFI "					
	cQuery	 	+= ", SA1.A1_INDRET A1INDRET "								
	cQuery	 	+= "FROM "		
	cQuery 		+= RetSqlName("SE5") + " SE5,  "
	cQuery 		+= RetSqlName("SED") + " SED,  "		
	cQuery 		+= RetSqlName("SA1") + " SA1   "		
			
	cQuery	 	+= "WHERE " 		
		
	cQuery	 	+=	"SED.ED_FILIAL='" + xFilial("SED") + "' AND " 							
	cQuery 		+=	"SA1.A1_FILIAL ='" + xFilial("SA1") + "' AND "

	If !Empty( iif( lUnidNeg, FWFilial("SE5") , xFilial("SE5") ) ) //Filiais compartilhadas   
		cQuery 		+=	"SE5.E5_FILIAL='" + xFilial("SE5") + "' AND "		
	Else
		cQuery 		+=	"SE5.E5_FILORIG='" + cFilAnt + "' AND "
	Endif
  
	cQuery	 	+= "SE5.E5_CLIFOR = SA1.A1_COD AND "
	cQuery	 	+= "SE5.E5_LOJA = SA1.A1_LOJA AND "				
	cQuery	 	+= "(SE5.E5_DATA >= '"+cDataIni+"' AND SE5.E5_DATA <= '"+cDataFim+"') AND "
	cQuery		+= "SE5.E5_SITUACA <> 'C' AND "			
	cQuery	 	+= "SE5.E5_RECPAG = 'R' AND "	
	cQuery 		+= "SE5.E5_TIPO = 'RA' AND "
	cQuery 		+= "SE5.E5_TIPODOC = 'RA' AND "
	cQuery 		+= "SE5.E5_DOCUMEN = '' AND "
	cQuery 		+= "SE5.E5_NATUREZ IN " + FormatIn(cRASpd,"|") + " AND "

	//Exclui os titulos que possuem estorno
	cQuery	 	+= "SE5.E5_SEQ NOT IN "
	cQuery 		+= "(SELECT SE5AUX.E5_SEQ FROM "+RetSqlName("SE5")+" SE5AUX WHERE "
	cQuery		+=		" SE5AUX.E5_FILIAL = SE5.E5_FILIAL AND "
	cQuery		+= 		" SE5AUX.E5_PREFIXO = SE5.E5_PREFIXO AND "
	cQuery		+= 		" SE5AUX.E5_NUMERO = SE5.E5_NUMERO AND  "
	cQuery		+= 		" SE5AUX.E5_PARCELA = SE5.E5_PARCELA AND " 
	cQuery		+= 		" SE5AUX.E5_TIPO = SE5.E5_TIPO AND " 
	cQuery		+= 		" SE5AUX.E5_CLIFOR = SE5.E5_CLIFOR AND " 
	cQuery		+= 		" SE5AUX.E5_LOJA = SE5.E5_LOJA AND "     
	cQuery		+= 		" SE5AUX.E5_TIPODOC = 'ES' AND "
	cQuery		+= 		" SE5AUX.D_E_L_E_T_ = ' ' "
	cQuery 		+= ") AND "      
                                                     
	cQuery	 	+= "SED.ED_CODIGO = SE5.E5_NATUREZ AND "

	cQuery		+= "SED.D_E_L_E_T_ = ' ' AND "
	cQuery		+= "SE5.D_E_L_E_T_ = ' ' AND "
	cQuery		+= "SA1.D_E_L_E_T_ = ' ' 	"
			
	cQuery 		:= ChangeQuery(cQuery)                 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
			
	For nX := 1 To len(aStruct)
			If aStruct[nX][2] <> "C" .And. FieldPos(aStruct[nX][1])<>0
			TcSetField(cAliasQry,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf                                          
			
	Next nX
	
	SE1 -> ( dbSetOrder ( 1 ) ) //FILIAL+PREFIXO+NUM+PARCELA+TIPO

	dbSelectArea(cAliasQry) 
	cAliasSPED := cAliasQry		
	While !(cAliasQry)->(Eof())				
			
			If lBaixa //caso ja tenha sido registrado em baixa por compensa��o no mesmo periodo 
				If Ascan(aRegCmp,{|x| AllTrim(x) == AllTrim((cAliasQry)->PREFIXO+(cAliasQry)->NUMERO+(cAliasQry)->PARCELA+(cAliasQry)->TIPO+(cAliasQry)->LOJA)}) > 0
					(cAliasQry)->( dbSkip())
					Loop
				EndIf	
			EndIf
			If SE1->(DbSeek(xFilial("SE1") + (cAliasQry)->PREFIXO+(cAliasQry)->NUMERO+(cAliasQry)->PARCELA+(cAliasQry)->TIPO )) 
				nBase := SE1->E1_BASEPIS
			EndIf
			aF600 := Array(11)
			
			nPisBx	:= Round((nBase *(cAliasQry)->PERCPIS)/100,2)
			nCofBx	:=	Round((nBase * (cAliasQry)->PERCCOF)/100,2)		
			
	    	//Indicador da reten��o
			If Empty((cAliasQry)->INDRET) 
				aF600[1] := (cAliasQry)->A1INDRET				
			Else 
				aF600[1] := (cAliasQry)->INDRET
			Endif	
		    
			aF600[2] := (cAliasQry)->DATAM 	//-- Data da emiss�o
			aF600[3] := nBase 				//-- Base do imposto
			aF600[4] := nPisBx + nCofBx 	//-- Valor da reten��o
		    
		   //Indicador de cumulatividade das naturezas de receita
		    If (cAliasQry)->INDCMLT == "1" 
		    	cIndCmlt := "0" //Cumulativo
		    ElseIf (cAliasQry)->INDCMLT == "2"
		       	cIndCmlt := "1" //N�o Cumulativo
	        EndIf		    	
		    	
		    aF600[5] := Iif((cAliasQry)->COND == "R", cIndCmlt, "")
		    
		   aF600[6] := (cAliasQry)->CNPJ 	 	//-- CNPJ do cliente
		   aF600[7] := nPisBx 						//-- Valor da reten��o de PIS
		   aF600[8] := nCofBx 						//-- Valor da reten��o de COFINS
		    
		   //Indicador da pessoa declarante
		   If ((cAliasQry)->RECPIS $ "SP" .Or. (cAliasQry)->RECCOFI $ "SP") .And. SM0->M0_CGC <> (cAliasQry)->CNPJ 	  //-- Empresa benefici�ria da reten��o
		   	aF600[9] := "0"
		   ElseIf ((cAliasQry)->RECPIS $ "SP" .Or. (cAliasQry)->RECCOFI $ "SP") .And. SM0->M0_CGC == (cAliasQry)->CNPJ //-- Empresa respons�vel pelo recolhimento
		    	aF600[9] := "1"
		   EndIf
		    
		   aF600[10] := "SE5" 				 //-- Tabela
		   aF600[11] := (cAliasQry)->RECNO  //-- Recno 
		    
		   aAdd(aReturn,aF600)
		    
		   nBase := 0
		   nProp := 0

			(cAliasQry)->(dbSkip())
		
			If (cAliasQry)->(Eof()) .and. (cAliasQry <> cAliasSPED)
		   	(cAliasQry)->(dbCloseArea())
		   	cAliasQry := cAliasSPED
				(cAliasQry)->(Dbskip())
		   Endif
	EndDo		
	 
	(cAliasQry)->(dbCloseArea())
			
Endif

If Select(cAliasSPED)>0
	(cAliasSPED)->(dbCloseArea())
Endif                                  

SC5->(RestArea(aAreaSC5))

FWFreeArray(aRegCmp)

EndIf

Return aReturn



//-----------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SPDMOTNOR

Verifica titulos de transferencia entre filiais se devem ser enviados para o Sped Pis/Cofins.
Arquivo anterior: MATXATU.PRX

@Author	Andrea Verissimo
@since	13/03/2012
/*/
//-----------------------------------------------------------------------------------------------------
Static Function SpdMotNOR(cChave)         
Local cChaveRet	:= cChave

dbSelectArea("SE6")
SE6->(Dbsetorder(5)) // FILDEB + PREFIXO + NUM + PARCELA + TIPO 
If SE6->(Dbseek(cChave)) // se achar nao leva 
	cChaveRet	:= ""
Endif

Return cChaveRet



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �MaxSeq	   � Autor � Totvs          	    � Data � 02/07/15 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Func�o para retornar a maior sequ�ncia do t�t. na SE5      ���
���          � do SPED PIS/COFINS                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � MaxSeq()			   											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAFIS													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function MaxSeq(cSeq, cChaveBx)

Local cQry		:=	""
Local aArea		:= GetArea()
Local lRet		:= .F.
Local ME5		:= GetNextAlias()
Local cKeyFil 	:= "" 
Local cKeyPref 	:= "" 
Local cKeyNum 	:= "" 
Local cKeyParc 	:= "" 
Local cKeyTipo 	:= "" 
Local cKeyClifo := "" 
Local cKeyLoja 	:= "" 
Local nTamFil 	:= TamSX3("E5_FILIAL")[1]
Local nTamPre 	:= TamSX3("E5_PREFIXO")[1]
Local nTamNum 	:= TamSX3("E5_NUMERO")[1]
Local nTamPar 	:= TamSX3("E5_PARCELA")[1]
Local nTamTip 	:= TamSX3("E5_TIPO")[1]
Local nTamCli 	:= TamSX3("E5_CLIFOR")[1]
Local nTamLoj 	:= TamSX3("E5_LOJA")[1]

cKeyFil   := Substr(cChaveBx,01,nTamFil)
cKeyPref  := Substr(cChaveBx,nTamFil+1,nTamPre)
cKeyNum   := Substr(cChaveBx,nTamFil+nTamPre+1,nTamNum)
cKeyParc  := Substr(cChaveBx,nTamFil+nTamPre+nTamNum+1,nTamPar)
cKeyTipo  := Substr(cChaveBx,nTamFil+nTamPre+nTamNum+nTamPar+1,nTamTip)
cKeyClifo := Substr(cChaveBx,nTamFil+nTamPre+nTamNum+nTamPar+nTamTip+1,nTamCli)
cKeyLoja  := Substr(cChaveBx,nTamFil+nTamPre+nTamNum+nTamPar+nTamTip+nTamCli+1,nTamLoj)

cQry	:= 	" Select MAX(E5_SEQ) SEQ "
cQry	+= 	" From " + RetSqlName("SE5") + " SE5 "
cQry 	+=	" Where E5_FILIAL = '" + cKeyFil +  "' AND " 
cQry 	+=	" E5_PREFIXO 	  = '" + cKeyPref + "' AND " 
cQry 	+=	" E5_NUMERO       = '" + cKeyNum +  "' AND " 
cQry 	+=	" E5_PARCELA      = '" + cKeyParc + "' AND " 
cQry 	+=	" E5_TIPO         = '" + cKeyTipo + "' AND " 
cQry 	+=	" E5_CLIFOR       = '" + cKeyClifo +"' AND " 
cQry 	+=	" E5_LOJA         = '" + cKeyLoja + "' AND " 
cQry	+= 	" D_E_L_E_T_ = ' ' "
cQry 	:= ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),ME5)

lRet := AllTrim(cSeq) == AllTrim((ME5)->SEQ) 

(ME5)->(DbCloseArea())

RestArea(aArea)

Return lRet 

/*/{Protheus.doc} TemImpBx
Verifica a exist�ncia de t�tulos de impostos gerados com
base no t�tulo da SE1 informado via RecNo

@param nRecNoSE1 - RecNo da SE1 no t�tulo principal 
@param cDataIni - Data inicial de baixa do t�tulo
@param cDataFim - Data final de baixa do t�tulo

@author Daniel Mendes
@since 28/07/06
@version P12
@return Retorno Booleano da exist�ncia
/*/
Static Function TemImpBx( nRecNoSE1 , cDataIni , cDataFim )
Local lRet := .T.
Local cQry := ""
Local cPai := "" 
Local cNat := ""
Local cAls := ""
Local cTip := ""
Local nNat := 0
Local nTip := 0
Local nRcn := 0

cAls := Alias()
nRcn := SE1->( RecNo() )
cQry := GetNextAlias()

SE1->( dbGoTo( nRecNoSE1 ) )

nNat := Len( SE1->E1_NATUREZ )
nTip := Len( SE1->E1_TIPO    )
cPai := Pad( SE1->( E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA ) , Len( SE1->E1_TITPAI ) )
cNat := "% ( '" + Pad( SuperGetMv( "MV_PISNAT" ) , nNat ) + "' , '" + Pad( SuperGetMv( "MV_COFINS" ) , nNat ) + "' ) %"
cTip := "% ( '" + Pad( MVCFABT , nTip ) + "' , '" + Pad( MVPIABT , nTip ) + "' ) %"

BeginSql Alias cQry
	SELECT COUNT(E1_TITPAI) TEMIMP
	  FROM %Table:SE1%
	 WHERE E1_FILIAL  = %Exp:SE1->E1_FILIAL%
	   AND E1_TITPAI  = %Exp:cPai%
	   AND E1_NATUREZ IN %Exp:cNat%
	   AND E1_TIPO    IN %Exp:cTip%
	   AND E1_BAIXA   BETWEEN %Exp:cDataIni% AND %Exp:cDataFim%
	   AND %NotDel%
EndSql

lRet := (cQry)->TEMIMP > 0
(cQry)->( dbCloseArea() )
SE1->( dbGoTo( nRcn ) )

If !Empty( cAls )
	dbSelectArea( cAls )
EndIf

Return lRet



User Function XMT110CFM()
Local cNumSol	:= ""  //Paramixb[1]  // N�mero da Solicita��o de Compras
Local nOpcSel   := 1 //Paramixb[2]  // Cont�m a op��o selecionada: 1 = Aprovar; 2 = Rejeitar; 3 = Bloquear
Local aOpcSel   := {"Aprovada","Rejeitada","Bloqueada"}
Local cOpcSel   := ""
Local cAssunto	:= ""
Local cEmail	:= u_EmailAdm() //+"wiliam.lisboa@bkconsultoria.com.br;"
Local cEmailCC  := ""
Local cMsg 		:= ""
Local cRodape	:= ""
Local cAnexo	:= ""
Local aCabs		:= {}
Local aEmail	:= {}
Local aMotivo	:= {} 
Local lAprov	:= .T.
//Local cAlEmail	:= ""
Local _cXXENDEN := ""
Local _cXXEN 	:= ""
Local _nXXEN 	:= 0
Local aSaldos 	:= {}
Local nSaldo 	:= 0
Local cQuery2 	:= ""
Local _IX		as Numeric
Local xi		as Numeric
Local cUserC1   := ""
Local aFiles	:= {}
Local nI 		:= 0
Local nTotal    := 0

If nOpcSel > 0 .and. nOpcSel < 4
	cOpcSel := aOpcSel[nOpcSel]
EndIf
DbSelectArea(SC1)
dbGoBottom()

cNumSol := SC1->C1_NUM

AADD(aMotivo,"In�cio de Contrato")
AADD(aMotivo,"Reposi��o Programada")
AADD(aMotivo,"Reposi��o Eventual")

PswOrder(1) 
PswSeek(__cUserId)  
aUser  := PswRet(1)
IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
	//cEmail += ALLTRIM(aUser[1,14])+';'
ENDIF

SY1->(dbgotop())
Do While SY1->(!eof())                                                                                                               
	PswOrder(1) 
	PswSeek(SY1->Y1_USER) 
	aUser  := PswRet(1)
	IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
		//cEmail += ALLTRIM(aUser[1,14])+';'
	ENDIF
    SY1->(dbskip())
Enddo

/*
//aUsers:=AllUsers()

For nX_ := 1 to Len(aUsers)
	If Len(aUsers[nX_][1][10]) > 0 .AND. !aUsers[nX_][1][17] //USUARIO BLOQUEADO
		aGrupo := {}
		//AADD(aGRUPO,aUsers[nX_][1][10])
		//FOR i:=1 TO LEN(aGRUPO[1])
		//	lAlmox := (aGRUPO[1,i] $ cAlmox)
		//NEXT
		//Ajuste nova rotina a antiga n�o funciona na nova lib MDI
		aGRUPO := UsrRetGrp(aUsers[nX_][1][2])
		IF LEN(aGRUPO) > 0
			FOR i:=1 TO LEN(aGRUPO)
				lAlmox := (ALLTRIM(aGRUPO[i]) $ cAlmox )
			NEXT
		ENDIF	
    	IF lAlmox
    		cAlEmail += ALLTRIM(aUsers[nX_][1][14])+";"
    	ENDIF
 	ENDIF
NEXT
*/

//cEmail += u_EmEstAlm(__cUserId,.T.,cEmail)
//cEmail += u_EmGerCom(cEmail)

//Monta corpo do email Solicita��o de Compras
_cXXENDEN := ""  
DbSelectArea("SC1")
SC1->(DbSetOrder(1))
SC1->(DbSeek(xFilial("SC1")+cNumSol,.T.))
Do While SC1->(!eof()) .AND. SC1->C1_NUM == cNumSol
	IF EMPTY(_cXXENDEN) .AND. !EMPTY(SC1->C1_XXENDEN)
		_cXXENDEN := SC1->C1_XXENDEN
	ENDIF 
	IF (SC1->C1_QUANT-SC1->C1_XXQEST) > 0
    	AADD(aEmail,{SC1->C1_NUM,SC1->C1_SOLICIT,SC1->C1_ITEM,SC1->C1_PRODUTO,SC1->C1_DESCRI,SC1->C1_UM,SC1->C1_QUANT-SC1->C1_XXQEST,SC1->C1_DATPRF,SC1->C1_OBS,SC1->C1_CC,SC1->C1_XXDCC,SC1->C1_QUJE,SC1->C1_XXLCVAL,SC1->C1_XXLCTOT}) //aMotivo[val(SC1->C1_XXMTCM)]})
		nTotal += SC1->C1_XXLCTOT
		// Marcos 16/08/22 - Enviar e-mail para o solicitante tamb�m
		If cUserC1 <> SC1->C1_USER
			PswOrder(1) 
			PswSeek(SC1->C1_USER)  
			aUser  := PswRet(1)
			IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
				If !ALLTRIM(aUser[1,14]) $ cEmail
					cEmail += ALLTRIM(aUser[1,14])+';'
				EndIf
			ENDIF
			cUserC1 := SC1->C1_USER
		EndIf

    ENDIF
    IF SC1->C1_APROV == "B"
    	lAprov := .F.
    ENDIF

	// Gravando a data de Aprova��o/Bloqueio 08/11/22
	RecLock(("SC1"), .F.)
	SC1->C1_XDTAPRV := DATE()
	MsUnlock()


	// Documentos anexos: SC + Item
	aFiles := u_BKDocs(cEmpAnt,"SC1",SC1->(C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD),1)
	If Len(aFiles) > 0
		For nI := 1 To Len(aFiles)
			cRodape += '<a href="'+u_BkRest()+'/RestLibPN/v4?empresa='+cEmpAnt+'&documento='+Encode64(aFiles[nI,2])+'&tpanexo=P" class="link-primary">'+aFiles[nI,2]+'</a><br>'+CRLF
		Next
	EndIf

    SC1->(dbskip())
Enddo

If Empty(cRodape)
	cRodape += '<p><b>Nenhum documento foi anexado a esta Solicita��o de Compras</b></p><br>'+CRLF
EndIf

If nTotal > 0
	cRodape := '<p><b>Total Previsto: '+ALLTRIM(TRANSFORM(nTotal,"@E 999,999,999.99"))+CRLF+'</b></p><br>'+cRodape
EndIf

IF lAprov
	//Verifica Saldo em estoque
	aSaldos := {}
	FOR _IX:= 1 TO LEN(aEmail)
		nSaldo := 0
		IF aEmail[_IX,12] <= 0
			DBSELECTAREA("SB2")
			SB2->(DBSETORDER(1))
			SB2->(DBSEEK(xFILIAL("SB2")+aEmail[_IX,4],.T.))
			DO WHILE !EOF() .AND. SB2->B2_COD == aEmail[_IX,4]
				nSaldo += SB2->B2_QATU
				SB2->(DBSKIP())	
			ENDDO
			IF nSaldo > 0
				DBSELECTAREA("SCP")
				SCP->(DBSETORDER(2))
				SCP->(DBSEEK(xFILIAL("SCP")+aEmail[_IX,4],.T.))
				DO WHILE !EOF() .AND. SCP->CP_PRODUTO == aEmail[_IX,4]
					//A185BtVe Retorna o statusa da Req. Armazem
					IF !A185BtVe()
						nSaldo -= SCP->CP_QUANT
					ENDIF
					SCP->(DBSKIP())	
				ENDDO
			ENDIF
		ENDIF
		IF nSaldo > 0
			cQuery2 := ""
			cQuery2 += "SELECT COUNT(CP_XXNSCOM) AS nXXNSCOM FROM "+RETSQLNAME("SCP")+" SCP"
			cQuery2 += " WHERE SCP.D_E_L_E_T_ = '' AND CP_XXNSCOM='"+aEmail[_IX,1]+"'"
			cQuery2 += " AND CP_XXISCOM='"+aEmail[_IX,3]+"'"
		
			If SELECT("QSCP") > 0 
   				QSCP->(dbCloseArea())
			EndIf

			TCQUERY cQuery2 NEW ALIAS "QSCP"

            DBSELECTAREA("QSCP") 
			IF QSCP->nXXNSCOM == 0
				AADD(aSaldos,{	aEmail[_IX,1],; //N Solicit
								aEmail[_IX,3],; //Item
								aEmail[_IX,4],; //Cod. Prod
								aEmail[_IX,5],; //Dec. Prod
								aEmail[_IX,6],; //UN. Med.
								aEmail[_IX,7],; //Quand
								nSaldo,; //Saldo Estoque
								IIF(nSaldo < aEmail[_IX,7],nSaldo,aEmail[_IX,7]),; //Qnt Sol. Estoque
								aEmail[_IX,10],;  //CC
								aEmail[_IX,11],;  //Desc. CC
								aEmail[_IX,2]})   //Solicitante
			ENDIF
			QSCP->(dbCloseArea())
        ENDIF
    NEXT
    IF LEN(aSaldos) > 0
		//Removido para inclus�o da nova rotina de contraole de Estoque
    	//IF u_MsgLog("MT110CFM","Produtos da solicita��o em estoque. Deseja Utiliz�-los?","Y")
    	//	U_BKESTA01(aSaldos)
    	//	Return Nil
    	//ENDIF
    ENDIF            

ENDIF


//Adiciona Endere�o de Entrega
IF !EMPTY(_cXXENDEN)
   	_cXXEN := ""
	_nXXEN := 0
	_nXXEN := MLCOUNT(_cXXENDEN,80)
	FOR xi := 1 TO _nXXEN
		_cXXEN += MemoLine(_cXXENDEN,80,xi)+" "
	NEXT    

	cRodape += "<b>Endere�o de Entrega: </b>"+_cXXEN
ENDIF

cAssunto:= "Solicita��o de Compra n�.: "+ALLTRIM(cNumSol)+" "+cOpcSel+" - "+FWEmpName(cEmpAnt)
aCabs   := {"Cod. SC.","Solicitante","�tem","Cod.Prod","Desc.Prod.","UM","Quant.","Data Limite Entrega","OBS","Centro de Custo","Descr. Centro de Custo","Qtd Entregue","Vl Previsto","Tot Previsto"}//"Motivo"}
cMsg    := u_GeraHtmB(aEmail,cAssunto,aCabs,"MT110CFM",cEmail,cEmailCC,cRodape)

cAnexo := "MT110CFM"+alltrim(cNumSol)+".html"
u_GrvAnexo(cAnexo,cMsg,.T.)	
u_BkSnMail("M110STTS",cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)

u_MsgLog("MT110CFM",cAssunto+" - Op��o: "+cValToChar(nOpcSel)+" - "+cEmail)

Return Nil

