#Include "Protheus.ch"
 
/*/{Protheus.doc} BKLIBCR
    Abre Titulos a Receber Web
    @type  Function
    @author user Marcos Abrahão
    @since 18/06/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

/*
User Function BKTITCR(lShell)

Local cToken  := u_BKEnCode()
Local dUtil   := dDatabase - Day(dDatabase) + 1
Local cUrl    := u_BkRest()+'/RestTitCR/v2?empresa='+cEmpAnt+'&vencini='+DTOS(dUtil-90)+'&vencfim='+DTOS(dUtil+365)+'&userlib='+cToken

Default lShell := .T.

If lShell
    ShellExecute("open",cUrl, "", "", 1)
    Return .T.
EndIf

Return cUrl
*/


User Function BKTITCR(lShell)

Local cToken  := u_BKEnCode()
//Local oRestClient := FWRest():New(u_BkRest())
Local aHeader := {} //{"tenantId: 99,01"}
Local dUtil   := dDatabase - Day(dDatabase) + 1

Local cGetParms  := ""
Local cHeaderGet := ""
Local nTimeOut   := 200


Local cDirTmp   := u_STmpHttp()
Local cArqHtml  := ""
Local cUrl 		:= ""
Local cHtml     := ""

Aadd(aHeader, "Content-Type: text/html")
Aadd(aHeader, "Authorization: Basic " + Encode64(u_BkUsrRest()+":"+u_BkPswRest()))

cHtml:= HttpGet(u_BkRest()+'/RestTitCR/v2?empresa='+cEmpAnt+'&vencini='+DTOS(dUtil-90)+'&vencfim='+DTOS(dUtil+365)+'&userlib='+cToken,cGetParms, nTimeOut, aHeader, @cHeaderGet)

cArqHtml  	:= cDirTmp+"cr"+cEmpAnt+"-"+DTOS(dDataBase)+"-"+__cUserID+".html"
cUrl 		:= u_BkIpServer()+"\tmp\"+"cr"+cEmpAnt+"-"+DTOS(dDataBase)+"-"+__cUserID+".html"

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   

fErase(cArqHtml)

Memowrite(cArqHtml,cHtml)

u_MsgLog("BKTITCR",u_BkRest())

ShellExecute("open", cUrl, "", "", 1)

Return .T.
