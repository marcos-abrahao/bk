#Include "Protheus.ch"
 
/*/{Protheus.doc} BKAVUS
    Abre Avisos aos usu�rios
    @type  Function
    @author user Marcos Abrah�o
    @since 11/03/2025
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function BKAVUS(lShell)
Local cToken  := u_BKEnCode()
//Local oRestClient := FWRest():New(u_BkRest())
Local aHeader := {} //{"tenantId: 99,01"}

Local cGetParms  := ""
Local cHeaderGet := ""
Local nTimeOut   := 200
Local cHtml      := ""
Local cUrl       := ""

Aadd(aHeader, "Content-Type: text/html; charset=utf8")
Aadd(aHeader, "Authorization: Basic " + Encode64(u_BkUsrRest()+":"+u_BkPswRest()))

cHtml := HttpGet(u_BkRest()+'/RestMsgUs/v2?userlib='+cToken,cGetParms, nTimeOut, aHeader, @cHeaderGet)

If !Empty(cHtml)
    cUrl := u_TmpHtml(cHtml,"BKAVUS",lShell)
Else
    u_MsgLog("BKAVUS","Erro ao acessar o ambiente REST, contate o suporte.","E")
EndIf

Return cUrl



User Function LoadMsgUs()
Local cHtml := ""
Local cFile := ""
cFile := u_SRecHttp()+"loadmsgus.html"
If !File(cFile)
	BEGINCONTENT var cHtml
        <!DOCTYPE html>
        <html lang="pt-BR">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Abrir Conte�do em Outra Aba e Fechar Atual</title>
            <script>
                function abrirConteudoEmNovaAbaEFecharAtual() {
                    try {
                        // Obt�m os par�metros da URL
                        const urlParams = new URLSearchParams(window.location.search);
                        const userlib = urlParams.get('userlib');
                        const bkip = urlParams.get('bkip');
                        const username = urlParams.get('username');
                        const password = urlParams.get('password');

                        // Monta a URL do endpoint REST externo
                        const url = `${bkip}?userlib=${userlib}`;

                        // Codifica as credenciais em Base64
                        const credentials = btoa(`${username}:${password}`);

                        // Faz a requisi��o ao endpoint REST externo
                        fetch(url, {
                            method: "GET",
                            headers: {
                                "Authorization": `Basic ${credentials}`,
                            },
                        })
                        .then(response => {
                            console.log("Resposta completa:", response);
                            console.log("Status:", response.status);
                            console.log("Cabe�alhos:", response.headers);
                            if (response.ok) {
                                return response.text(); // Recebe o conte�do como texto (HTML)
                            } else {
                                throw new Error(`Erro ao acessar o conte�do: ${response.statusText}`);
                            }
                        })
                        .then(html => {
                            console.log("Conte�do HTML recebido:", html);

                            // Abre uma nova aba/janela
                            const novaAba = window.open("", "_self");

                            // Escreve o conte�do HTML na nova aba
                            novaAba.document.open();
                            novaAba.document.write(html);
                            novaAba.document.close();

                            // Tenta fechar a aba atual
                            /*
                            try {
                                window.close(); // Fecha a aba atual
                            } catch (error) {
                                console.error("N�o foi poss�vel fechar a aba atual:", error);
                                alert("A aba atual n�o pode ser fechada automaticamente. Feche-a manualmente.");
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
                            alert("N�o foi poss�vel carregar o conte�do. Verifique o console para mais detalhes.");
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

                // Executa a fun��o ao carregar a p�gina
                window.onload = abrirConteudoEmNovaAbaEFecharAtual;
            </script>
        </head>
        <body>
            <h3 id="titulo">Abrindo conte�do em outra aba e fechando esta...</h3>
        </body>
        </html>
	ENDCONTENT

	cHtml := StrIConv( cHtml, "CP1252", "UTF-8")
	cHtml := u_BKUtf8()+cHtml
	MemoWrite(cFile,cHtml)
EndIf
Return cHtml


