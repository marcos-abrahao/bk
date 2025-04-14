#Include "Protheus.ch"
 
/*/{Protheus.doc} BKTITCR
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
If !Empty(cHtml)
    Memowrite(cArqHtml,cHtml)

    u_MsgLog("BKTITCR",u_BkRest())

    ShellExecute("open", cUrl, "", "", 1)
Else
    u_MsgLog("BKTITCR","Erro ao acessar o ambiente REST, contate o suporte.","E")
EndIf


Return .T.




User Function yBKTITCR(lShell)

Local cToken  := u_BKEnCode()
Local dUtil   := dDatabase - Day(dDatabase) + 1
//Local cUrl    := u_BkRest()+'/RestTitCR/v2?empresa='+cEmpAnt+'&vencini='+DTOS(dUtil-90)+'&vencfim='+DTOS(dUtil+365)+'&userlib='+cToken
Local cUrl     := u_BKIpServer()+'/recursos/loadcr.html?empresa='+cEmpAnt+'&vencini='+DTOS(dUtil-60)+'&vencfim='+DTOS(dUtil+365)+'&userlib='+cToken+'&bkip='+u_BKRest()+'/RestTitCR/v2&username='+u_BKUsrRest()+'&password='+u_BKPswRest()

u_LoadCR()

Default lShell := .T.


If lShell
    ShellExecute("open",cUrl, "", "", 1)
    Return .T.
EndIf

Return cUrl


User Function LoadCR()
Local cHtml := ""
Local cFile := ""
cFile := u_SRecHttp()+"loadcr.html"
If !File(cFile)
	BEGINCONTENT var cHtml
        <!DOCTYPE html>
        <html lang="pt-BR">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Abrir Conteúdo em Outra Aba e Fechar Atual</title>
            <script>
                function abrirConteudoEmNovaAbaEFecharAtual() {
                    try {
                        // Obtém os parâmetros da URL
                        const urlParams = new URLSearchParams(window.location.search);
                        const empresa = urlParams.get('empresa');
                        const vencini = urlParams.get('vencini');
                        const vencfim = urlParams.get('vencfim');
                        const userlib = urlParams.get('userlib');
                        const bkip = urlParams.get('bkip');
                        const username = urlParams.get('username');
                        const password = urlParams.get('password');

                        // Monta a URL do endpoint REST externo
                        const url = `${bkip}?empresa=${empresa}&vencini=${vencini}&vencfim=${vencfim}&userlib=${userlib}`;

                        // Codifica as credenciais em Base64
                        const credentials = btoa(`${username}:${password}`);

                        // Faz a requisição ao endpoint REST externo
                        fetch(url, {
                            method: "GET",
                            headers: {
                                "Authorization": `Basic ${credentials}`,
                            },
                        })
                        .then(response => {
                            console.log("Resposta completa:", response);
                            console.log("Status:", response.status);
                            console.log("Cabeçalhos:", response.headers);
                            if (response.ok) {
                                return response.text(); // Recebe o conteúdo como texto (HTML)
                            } else {
                                throw new Error(`Erro ao acessar o conteúdo: ${response.statusText}`);
                            }
                        })
                        .then(html => {
                            console.log("Conteúdo HTML recebido:", html);

                            // Abre uma nova aba/janela
                            const novaAba = window.open("", "_self");

                            // Escreve o conteúdo HTML na nova aba
                            novaAba.document.open();
                            novaAba.document.write(html);
                            novaAba.document.close();

                            // Tenta fechar a aba atual
                            /*
                            try {
                                window.close(); // Fecha a aba atual
                            } catch (error) {
                                console.error("Não foi possível fechar a aba atual:", error);
                                alert("A aba atual não pode ser fechada automaticamente. Feche-a manualmente.");
                            }
                            */
                        })
                        .catch(error => {
                            try {
                                console.error("Erro no fetch:", error);
                                console.log("Mensagem de erro:", error.message);
                                console.log("Stack trace:", error.stack);
                            } catch (err) {
                                console.log("Erro ao tentar logar o erro:", err);
                            }
                            alert("Não foi possível carregar o conteúdo. Verifique o console para mais detalhes.");
                        });
                    } catch (error) {
                        try {
                            console.error("Erro no bloco try:", error);
                            console.log("Mensagem de erro:", error.message);
                            console.log("Stack trace:", error.stack);
                        } catch (err) {
                            console.log("Erro ao tentar logar o erro:", err);
                        }
                        alert("Ocorreu um erro inesperado. Verifique o console para mais detalhes.");
                    }
                }

                // Executa a função ao carregar a página
                window.onload = abrirConteudoEmNovaAbaEFecharAtual;
            </script>
        </head>
        <body>
            <h3 id="titulo">Abrindo conteúdo em outra aba e fechando esta...</h3>
        </body>
        </html>
	ENDCONTENT

	cHtml := StrIConv( cHtml, "CP1252", "UTF-8")
	cHtml := u_BKUtf8()+cHtml
	MemoWrite(cFile,cHtml)
EndIf
Return cHtml





