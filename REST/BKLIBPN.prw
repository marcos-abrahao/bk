#Include "Protheus.ch"
 
/*/{Protheus.doc} BKLIBPN
    Abre Liberação de Documentos de Entrada Web
    @type  Function
    @author user
    @since 12/09/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/


User Function BKLIBPN(lShell)

Local cToken  := u_BKEnCode()
//Local oRestClient := FWRest():New(u_BkRest())
Local aHeader := {} //{"tenantId: 99,01"}

Local cGetParms  := ""
Local cHeaderGet := ""
Local nTimeOut   := 200
Local cHtml      := ""

Aadd(aHeader, "Content-Type: text/html; charset=utf8")
Aadd(aHeader, "Authorization: Basic " + Encode64(u_BkUsrRest()+":"+u_BkPswRest()))

cHtml := HttpGet(u_BkRest()+'/RestLibPN/v2?userlib='+cToken,cGetParms, nTimeOut, aHeader, @cHeaderGet)

If !Empty(cHtml)
    u_TmpHtml(cHtml,"BKLIBPN",.T.)
Else
    u_MsgLog("BKPRVCR","Erro ao acessar o ambiente REST, contate o suporte.","E")
EndIf

Return .T.


/*
User Function BKLIBPN(lShell)
Local cToken  := u_BKEnCode()
Local cUrl  := u_BkRest()+"/RestLibPN/v2?userlib="+cToken

Default lShell := .T.

If lShell
    ShellExecute("open", cUrl , "", "", 1)
    Return .T.
EndIf

Return cUrl
*/
