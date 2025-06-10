#Include "Protheus.ch"
 
/*/{Protheus.doc} BKTITCP
BKTITCP - Abrir tela REST - Titulos a Pagar
@Return
@author Marcos Bispo Abrahão
@since 24/08/23
@version P12
/*/

User Function BKTITCP(lShell)

Local cToken  := u_BKEnCode()
//Local oRestClient := FWRest():New(u_BkRest())
Local aHeader    := {} //{"tenantId: 99,01"}
Local dUtil      := dDatabase + 1
Local cGetParms  := ""
Local cHeaderGet := ""
Local nTimeOut   := 200
Local cHtml      := ""
Default lShell   := .T.

Aadd(aHeader, "Content-Type: text/html; charset=utf8")
Aadd(aHeader, "Authorization: Basic " + Encode64(u_BkUsrRest()+":"+u_BkPswRest()))

cHtml := HttpGet(u_BkRest()+'/RestTitCP/v2?empresa='+cEmpAnt+'&vencini='+DTOS(dUtil)+'&vencfim='+DTOS(dUtil)+'&userlib='+cToken,cGetParms, nTimeOut, aHeader, @cHeaderGet)

If !Empty(cHtml)
    u_TmpHtml(cHtml,"BKTITCP",lShell)
Else
    u_MsgLog("BKTITCP","Erro ao acessar o ambiente REST, contate o suporte.","E")
EndIf

Return .T.




User Function xBKTITCP(lShell)
Local dUtil   := dDataBase + 1
Local cToken  := u_BKEnCode()
Local cUrl 	  := ""

Default lShell := .T.

If Select("SX2")==0
	If DOW(dUtil) == 7
		dUtil++
	EndIf
	If DOW(dUtil) == 1
		dUtil++
	EndIf
Else
	dUtil := DATAVALIDA(dDataBase+1)
EndIf

cUrl := u_BkRest()+'/RestTitCP/v2?empresa='+cEmpAnt+'&vencini='+DTOS(dUtil)+'&vencfim='+DTOS(dUtil)+'&userlib='+cToken
If lShell
	ShellExecute("open", cUrl , "", "", 1)
	Return .T.
EndIf
Return cUrl

