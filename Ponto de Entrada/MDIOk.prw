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

/*
If __cUserId == "000000"
	u_BkWeb("http://10.139.0.30:8080/rest/RestLibPN/v2?userlib=DAPAgQZgnYwDyKEGcBjNs8DBR2KYjkPc2Q--")
EndIf
*/

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

Return .T.


/*/{Protheus.doc} WEB
Página HTML da Web
@type function
@version 12.1.25
@author Jorge Alberto
@since 30/06/2021
@obs Pequenas alterações e adaptações feitas por Daniel Atilio
/*/
 
User Function BKWEB(cUrl)
    Local aSize       := MsAdvSize()
    Local nPort       := 0
    Local oModal
    Local oWebEngine 
    Private oWebChannel := TWebChannel():New()
     
    //Cria a dialog
    oModal := MSDialog():New(aSize[7],0,aSize[6]-80,aSize[5], "Página Web",,,,,,,,,.T./*lPixel*/)
     
        //Prepara o conector
        nPort := oWebChannel::connect()
 
        //Cria o componente que irá carregar a url
        oWebEngine := TWebEngine():New(oModal, 100, 100, 100, 100,/*cUrl*/, nPort)
        oWebEngine:bLoadFinished := {|self, url| /*conout("Fim do carregamento da pagina " + url)*/ }
        oWebEngine:navigate(cUrl)
        oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
    oModal:Activate()
  
Return
