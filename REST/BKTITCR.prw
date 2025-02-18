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
User Function BKTITCR(lShell)

Local cToken  := u_BKEnCode()
//Local oRestClient := FWRest():New(u_BkRest())
Local aHeader := {} //{"tenantId: 99,01"}
Local dUtil   := dDatabase - Day(dDatabase) + 1

Local cGetParms  := ""
Local cHeaderGet := ""
Local nTimeOut   := 200
Local cNomeTmp   := ""

Local cDirTmp   := u_STmpHttp()
Local cArqHtml  := ""
Local cUrl 		:= ""
Local cHtml     := ""

Aadd(aHeader, "Content-Type: text/html; charset=utf8")
Aadd(aHeader, "Authorization: Basic " + Encode64(u_BkUsrRest()+":"+u_BkPswRest()))

cHtml       := HttpGet(u_BkRest()+'/RestTitCR/v2?empresa='+cEmpAnt+'&vencini='+DTOS(dUtil-90)+'&vencfim='+DTOS(dUtil+365)+'&userlib='+cToken,cGetParms, nTimeOut, aHeader, @cHeaderGet)
cNomeTmp    := DTOS(dDataBase)+"-"+STRZERO(randomize(1,99999),5)+"-cr.html"
cArqHtml  	:= cDirTmp+cNomeTmp
cUrl 		:= u_BkIpServer()+"\tmp\"+cNomeTmp

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   

fErase(cArqHtml)

Memowrite(cArqHtml,cHtml)

u_MsgLog("BKTITCR",u_BkRest())

ShellExecute("open", cUrl, "", "", 1)

Return .T.


/*
User Function xBKTITCR(lShell)

Local cToken  := u_BKEnCode()
Local dUtil   := dDatabase - Day(dDatabase) + 1
Local cUrl    := u_BkRest()+'/RestTitCR/v2?empresa='+cEmpAnt+'&vencini='+DTOS(dUtil-90)+'&vencfim='+DTOS(dUtil+365)+'&userlib='+cToken

Default lShell := .T.

AutHtml(cUrl)

Return cUrl


User Function yBKTITCR(lShell)

Local cToken  := u_BKEnCode()
Local dUtil   := dDatabase - Day(dDatabase) + 1
Local cUrl    := u_BkRest()+'/RestTitCR/v2?empresa='+cEmpAnt+'&vencini='+DTOS(dUtil-90)+'&vencfim='+DTOS(dUtil+365)+'&userlib='+cToken

Default lShell := .T.

If lShell
    ShellExecute("open",cUrl, "", "", 1)
    Return .T.
EndIf

Return cUrl



Static Function AutHtml(cUrl)

Local cHTML		As char
Local cDirTmp   := u_STmpHttp()
Local cArqHtml  := ""
Local cUrlTmp   := ""


BEGINCONTENT var cHTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inserir HTML Dinâmico</title>
</head>
<body>
    <div id="content"></div>

    <script>

        async function LoadPg() {

        const username = '#usrrest#';
        const password = '#pswrest#';


        let url = '#cUrl#'


        const headers = new Headers();
        headers.set('Authorization', 'Basic ' + btoa('#usrrest#' + ':' + '#pswrest#'));
            try {
            let res = await fetch(url, { method: 'GET', headers: headers });
                document.getElementById('conteudo-principal').innerHTML =  await res.text();
                loadTable();
                } catch (error) {
            console.log(error);
            }
        }

        LoadPg()

    </script>

    </div>
</body>
</html>
ENDCONTENT

cHtml := STRTRAN(cHtml,"#usrrest#"	 ,u_BkUsrRest())
cHtml := STRTRAN(cHtml,"#pswrest#"	 ,u_BkPswRest())
cHtml := STRTRAN(cHtml,"#cUrl#"	     ,cUrl)

cArqHtml  	:= cDirTmp+"cr"+cEmpAnt+"-"+DTOS(dDataBase)+"-"+__cUserID+".html"
cUrlTmp		:= u_BkIpServer()+"\tmp\"+"cr"+cEmpAnt+"-"+DTOS(dDataBase)+"-"+__cUserID+".html"

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   

fErase(cArqHtml)

Memowrite(cArqHtml,cHtml)

u_MsgLog("BKTITCR",u_BkRest())

ShellExecute("open", cUrlTmp, "", "", 1)

Return cHtml
*/
