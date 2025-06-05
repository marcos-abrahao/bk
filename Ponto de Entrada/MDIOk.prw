#Include "Protheus.ch"
 
/*/{Protheus.doc} MDIOk
MDIOk - P.E. ao abrir o módulo SIGAMDI
@Return
@author Marcos Bispo Abrahão
@since 19/08/21
@version P12.1.33
/*/

User Function MDIOk()

u_BkWeb()

Return .T.


/*/{Protheus.doc} WEB
Página HTML da Web
@type function
@version 12.1.25
@author Jorge Alberto
@since 30/06/2021
@obs Pequenas alterações e adaptações feitas por Daniel Atilio
/*/
 
User Function BKWEB()
Local aSize     := FWGetDialogSize( oMainWnd ) // GetScreenRes() //MsAdvSize() // GetScreenRes()
Local nPort     := 0
Local nTop		:= 0
Local nLeft		:= 0
Local nJanLarg	:= 0
Local nJanAltu	:= 0
//Local nPosBt 	:= 0
Local nTamBt    := 70  // Largura fixa dos botões
Local nAltBt    := 15  // Altura fixa dos botões
Local nEsps     := 10  // Espaçamento entre os botões
Local lCR 		:= .F.
Local lCP 		:= .F.
Local lLPV 		:= .F.
Local lLPN		:= .F.
Local cToken	:= u_BKEnCode()
//Local cUrl 		:= u_BkRest()+"/RestMsgUs/v2?userlib="+cToken
Local cHtml		:= ""
Local cLib		:= ""
//Local lWebAgent := .F.
Local nRemote	:= 0
Local oDlg
Local oWebEngine 
Local oLayer
Local oPanelUp
Local oPanelDown

Local nNumButtons := 0
Local nTotalWidth := 0
Local nWidth      := 0
Local nHeight	  := 0
Local nStartX     := 0
Local nStartY     := 0
Local cUrl 		  := u_BkRest()+"/RestMsgUs/v2?userlib="+cToken
Local cGetParms   := ""
Local cHeaderGet  := ""
Local nTimeOut    := 200
Local aHeader 	  := {}
Local lBarcas	  := .F.

Private oWebChannel := TWebChannel():New()

If cEmpAnt == "20" // Barcas
	lBarcas := .T.
EndIf

If u_AmbTeste()
    Aadd(aHeader, "Content-Type: text/html; charset=utf8")
    Aadd(aHeader, "Authorization: Basic " + Encode64(u_BkUsrRest()+":"+u_BkPswRest()))
    cHtml       := HttpGet(u_BkRest()+"/RestMsgUs/v2?userlib="+cToken,cGetParms, nTimeOut, aHeader, @cHeaderGet)
EndIf

//cUrl := u_BkAvUs(.F.)

// Para teste
//If __cUserId $ "000000/000038"
//	ShellExecute("open", u_BkRest()+"/RestMsgUs/v2?userlib="+cToken, "", "", 1)
//EndIf

// FWGetDialogSize( oMainWnd )

nJanLarg	:= aSize[4]
nJanAltu	:= aSize[3]
nTop		:= aSize[1]
nLeft		:= aSize[2]


// GetScreenRes()
//nJanLarg	:= aSize[1]
//nJanAltu	:= aSize[2]
//nTop		:= 0
//nLeft		:= 0

// MsAdvSize()
/*
nJanLarg	:= aSize[5]
nJanAltu	:= aSize[6]
nTop		:= 0
nLeft		:= 0
*/

nRemote := GetRemoteType(@cLib)
/*
If nRemote <> 1 
    lWebAgent := .F.
	u_MsgLog("MDIOK","Confirme se o webagent local está ativo, pois algumas funcionalidades como consulta pedidos e manipulaçao de arquivos estarão limitadas ("+TRIM(cLib)+" Remote: "+STR(nRemote,1,0)+")","W")
Else
	u_MsgLog("MDIOK","Webagent ativo ("+TRIM(cLib)+" Remote: "+STR(nRemote,1,0)+")")
    lWebAgent := .T.
EndIf
*/
oDlg := MsDialog():New( nTop, nLeft, nJanAltu, nJanLarg,"Avisos do Sistema ("+TRIM(cLib)+" Remote: "+STR(nRemote,1,0)+") - "+cEmpAnt,,,,,,,,, .T.,,,, .F. )

//oDlg:nClientHeight  := nJanAltu
//oDlg:nClientWidth   := nJanLarg

//oDlg:Refresh()

//EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End() })

oLayer := FWLayer():new()
oLayer:init(oDlg,.F.)

oLayer:addCollumn ('Col1',100,.F.)


oLayer:addWindow('Col1', 'WinTop' ,'Ações WEB' ,15,.F.,.F.,,,)
oLayer:addWindow('Col1', 'WinGrid','Avisos' ,83,.F.,.F.,,,)

oPanelUp := oLayer:getWinPanel('Col1','WinTop')
oPanelDown := oLayer:getWinPanel('Col1','WinGrid')

If AMIIn(5, 69) .OR. Modulo == 5 .OR. nModulo == 69
	If !lBarcas
		lLPV := .T.
		lCR  := .T.
	EndIf
EndIf

If AMIIn(2,6,9) .OR. Modulo == 2 .OR. nModulo == 6 .OR. Modulo == 9
	If u_IsFiscal(__cUserId) .OR. u_IsStaf(__cUserId) .OR. u_IsSuperior(__cUserId)
		lLPN := .T.
	EndIf
EndIf

If AMIIn(6) .OR. nModulo == 6 
	If  (u_InGrupo(__cUserId,"000024") .OR. __cUserId == "000000")
		lCP := .T.
	EndIf
EndIf

  
// Calcula a posição dos botões
nNumButtons := 7  //7
nTotalWidth := (nTamBt * nNumButtons) + (nEsps * (nNumButtons - 1)) // Largura total dos botões + espaçamento
nWidth  := oPanelUp:nWidth / 2
nHeight := oPanelUp:nHeight / 2

// Verifica se a largura total dos botões é maior que a largura do painel
If nTotalWidth > nWidth
    // Ajusta o espaçamento para caber todos os botões
    nEsps := (nWidth - (nTamBt * nNumButtons)) / (nNumButtons + 1)
	nTotalWidth := (nTamBt * nNumButtons) + (nEsps * (nNumButtons - 1)) // Largura total dos botões + espaçamento
EndIf

// Calcula a posição inicial para distribuir os botões uniformemente
//nStartX := nEsps // Posição X inicial
nStartX := (nWidth - nTotalWidth) / 2
nStartY := (nHeight - nAltBt) / 2

@ nStartY, nStartX BUTTON "Titulos a Pagar" SIZE nTamBt,nAltBt PIXEL OF oPanelUp ACTION (u_BKTitCP(.T.)) WHEN lCP
nStartX += nTamBt + nEsps
@ nStartY, nStartX BUTTON "Previsão a Receber" SIZE nTamBt,nAltBt PIXEL OF oPanelUp ACTION (u_BKPrvCR(.T.)) WHEN lCR
nStartX += nTamBt + nEsps
@ nStartY, nStartX BUTTON "Titulos a Receber" SIZE nTamBt,nAltBt PIXEL OF oPanelUp ACTION (u_BKTitCR(.T.)) WHEN lCR
nStartX += nTamBt + nEsps
@ nStartY, nStartX BUTTON "Lib. de Pedidos de Venda" SIZE nTamBt,nAltBt PIXEL OF oPanelUp ACTION (u_BKLibPV(.T.)) WHEN lLPV
nStartX += nTamBt + nEsps
@ nStartY, nStartX BUTTON "Lib. de Docs de Entrada" SIZE nTamBt,nAltBt PIXEL OF oPanelUp ACTION (u_BKLibPN(.T.)) WHEN lLPN
nStartX += nTamBt + nEsps
@ nStartY, nStartX BUTTON "Avisos" SIZE nTamBt,nAltBt PIXEL OF oPanelUp ACTION (u_BKAvUs(.T.))
nStartX += nTamBt + nEsps
@ nStartY, nStartX BUTTON "Entrar no Protheus" SIZE nTamBt,nAltBt PIXEL OF oPanelUp ACTION (lOk:=.T.,oDlg:End())

//nPosbt += nTamBt + nEsps
//TButton():New( 010, nPosbt, "GoHome", oPanelUp,{|| oWebEngine:GoHome() },nTamBt,015,,,.F.,.T.,.F.,,.F.,,,.F. )

//Prepara o conector
nPort := oWebChannel::connect()
 
//Cria o componente que irá carregar a url
oWebEngine := TWebEngine():New(oPanelDown, 0, 0, oPanelDown:nWidth / 2, oPanelDown:nHeight / 2,/*cUrl*/, nPort)
//oWebEngine:bLoadFinished := {|self, url| /*conout("Fim do carregamento da pagina " + url)*/ }

If u_AmbTeste()
    // Por texto em variavel de memoria
    oWebEngine:setHtml(cHtml, u_BkIpServer()+"/tmp/")
Else
    oWebEngine:navigate(cUrl)
EndIf


//oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
oDlg:Activate()

Return

// Funçao nova - falta testar
User Function WebAtivo()
Local aInfoWebAgent := Nil
//Local cInfoWebAgent := ""
Local lRet 			:= .F.

aInfoWebAgent := GetWebAgentInfo()
If len(aInfoWebAgent) > 0
    If !Empty(aInfoWebAgent[1])
		//cInfoWebAgent:= 'Versão: ' + aInfoWebAgent[1]+' - Porta: ' + aInfoWebAgent[2]
		lRet := .T.
	EndIf
Endif
//If !lRet
//	u_MsgLog("WebAtivo","Algumas funções estão indisponíveis quando o webagent local não está ativo.","W")
//EndIf

Return lRet

