#Include "Protheus.ch"
 
/*/{Protheus.doc} MDIOk
MDIOk - P.E. ao abrir o módulo SIGAMDI
@Return
@author Marcos Bispo Abrahão
@since 19/08/21
@version P12.1.33
/*/

User Function MDIOk()

//Local dUtil := dDatabase
//Local dUltLog := FWUsrUltLog(__cUserId)[1] // Data do Ultimo login  
//If __cUserId == "000000"
	u_BkWeb()
	//ShellExecute("open", u_BkRest()+"/RestMsgUs/v2?userlib="+cToken , "", "", 1)
//EndIf
/*
If nModulo == 5 .OR. nModulo == 69
   	If u_MsgLog("MDIOk","Deseja abrir a Liberação de Pedidos de Venda web?","Y")
		u_BKLibPV(.T.)
	EndIf

	If nModulo == 5
    	If u_MsgLog("MDIOk","Deseja abrir os Títulos a Receber web?","Y")
			u_BKTitCR(.T.)
		EndIf
	EndIf

ElseIf nModulo == 6 .OR. nModulo == 2  .OR. nModulo == 9
	If u_IsFiscal(__cUserId) .OR. u_IsStaf(__cUserId) .OR. u_IsSuperior(__cUserId)
		If u_MsgLog("MDIOk","Deseja abrir a Liberação de Docs de Entrada Web?","Y")
			u_BKLibPN(.T.)
		EndIf
	EndIf
EndIf

If nModulo == 6 .AND. (u_InGrupo(__cUserId,"000024") .OR. __cUserId == "000000")
	If u_MsgLog("MDIOk","Deseja abrir a tela Títulos a Pagar Web?","Y")
		u_BKTitCP(.T.)
	EndIf
EndIf
*/
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
Local aSize     := GetScreenRes() //FWGetDialogSize( oMainWnd ) //MsAdvSize() // GetScreenRes()
Local nPort     := 0
Local nTop		:= 0
Local nLeft		:= 0
Local nJanLarg	:= 0
Local nJanAltu	:= 0
Local nPosBt 	:= 0
Local nTamBt 	:= 75
Local nEsps		:= 15
Local lCR 		:= .F.
Local lCP 		:= .F.
Local lLPV 		:= .F.
Local lLPN		:= .F.
Local cToken	:= u_BKEnCode()
Local cUrl 		:= u_BkRest()+"/RestMsgUs/v2?userlib="+cToken
Local cLib		:= ""
Local nRemote	:= 0
Local oDlg
Local oWebEngine 
Local oLayer
Local oPanelUp
Local oPanelDown

Private oWebChannel := TWebChannel():New()

// Para teste
//If __cUserId $ "000000/000038"
//	ShellExecute("open", u_BkRest()+"/RestMsgUs/v2?userlib="+cToken, "", "", 1)
//EndIf

// FWGetDialogSize( oMainWnd )
/*
nJanLarg	:= aSize[4]
nJanAltu	:= aSize[3]
nTop		:= 0
nLeft		:= 0
*/

// GetScreenRes()
nJanLarg	:= aSize[1]
nJanAltu	:= aSize[2]
nTop		:= 0
nLeft		:= -10

// MsAdvSize()
/*
nJanLarg	:= aSize[5]
nJanAltu	:= aSize[6]
nTop		:= 0
nLeft		:= 0
*/

nRemote := GetRemoteType(@cLib)

oDlg := MsDialog():New( nTop, nLeft, nJanAltu, nJanLarg,"Avisos do Sistema ("+TRIM(cLib)+")",,,,,,,,, .T.,,,, .F. )

oDlg:nClientHeight  := nJanAltu
oDlg:nClientWidth   := nJanLarg

oDlg:Refresh()

//EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End() })

oLayer := FWLayer():new()
oLayer:init(oDlg,.F.)

oLayer:addCollumn ('Col1',100,.F.)

oLayer:addWindow('Col1', 'WinTop' ,'Ações WEB' ,15,.F.,.F.,,,)
oLayer:addWindow('Col1', 'WinGrid','Avisos' ,85,.F.,.F.,,,)

oPanelUp := oLayer:getWinPanel('Col1','WinTop')
oPanelDown := oLayer:getWinPanel('Col1','WinGrid')

If AMIIn(5, 69) .OR. Modulo == 5 .OR. nModulo == 69
	lLPV := .T.
	lCR := .T.
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

nPosBt := 12
@ 010,nPosBt BUTTON "Titulos a Pagar" SIZE nTamBt, 015 PIXEL OF oPanelUp ACTION (u_BKTitCP(.T.)) WHEN lCP
nPosbt += nTamBt + nEsps
@ 010,nPosBt BUTTON "Titulos a Receber" SIZE nTamBt, 015 PIXEL OF oPanelUp ACTION (u_BKTitCR(.T.)) WHEN lCR
nPosbt += nTamBt + nEsps
@ 010,nPosBt BUTTON "Lib. de Pedidos de Venda" SIZE nTamBt, 015 PIXEL OF oPanelUp ACTION (u_BKLibPV(.T.)) WHEN lLPV
nPosbt += nTamBt + nEsps
@ 010,nPosBt BUTTON "Lib. de Docs de Entrada" SIZE nTamBt, 015 PIXEL OF oPanelUp ACTION (u_BKLibPN(.T.)) WHEN lLPN
nPosbt += nTamBt + nEsps
@ 010,nPosBt BUTTON "Avisos" SIZE nTamBt, 015 PIXEL OF oPanelUp ACTION (ShellExecute("open", cUrl, "", "", 1))
nPosbt += nTamBt + nEsps
@ 010,nPosBt BUTTON "Entrar no Protheus" SIZE nTamBt, 015 PIXEL OF oPanelUp ACTION (lOk:=.T.,oDlg:End())
//nPosbt += nTamBt + nEsps
//TButton():New( 010, nPosbt, "GoHome", oPanelUp,{|| oWebEngine:GoHome() },nTamBt,015,,,.F.,.T.,.F.,,.F.,,,.F. )

//Prepara o conector
nPort := oWebChannel::connect()
 
//Cria o componente que irá carregar a url
oWebEngine := TWebEngine():New(oPanelDown, 100, 100, 100, 100,/*cUrl*/, nPort)
//oWebEngine:bLoadFinished := {|self, url| /*conout("Fim do carregamento da pagina " + url)*/ }
oWebEngine:navigate(cUrl)
oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
oDlg:Activate()

Return
