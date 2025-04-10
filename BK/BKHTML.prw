#include "totvs.ch"
#include "protheus.ch"

/*/{Protheus.doc} BKHTML
BK - Funcoes com parâmetros embutidos no fonte
@Return
@author Marcos B. Abrahão
@since 03/05/22
@version P12
/*/

// Retorna IP e Porta do server REST
User Function BkIpPort()
Local cIpPort := "10.139.0.30:8080"
If u_AmbTeste()
	cIpPort := "10.139.0.30:8081"
EndIf
//u_MsgLog(,GetEnvServer()+" - "+STR(GetPort(1))+" - "+cIpPort,"I")

Return cIpPort


User Function AmbTeste()
Local lRet := .F.
If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer()) .OR. GetPort(1) = 1240 .OR. GetPort(1) = 1400
	lRet := .T.
EndIf
Return lRet

// Retorna endereço do REST BK
User Function BKRest()
Local cRest := "http://"+u_BkIpPort()+"/rest"
Return cRest


// Retorna endereço do Servidor BK
User Function BKIpServer()
Local cRest := "http://10.139.0.30"
Return cRest

// Usuário para consumo de API REST
User Function BKUsrRest()
Return "web"

User Function BKPswRest()
Return "846250"


// String a ser colocada em um arquivo HTML para identificar que é um arquivo UTF-8
User Function BKUtf8()
Return Chr(239) + Chr(187) + Chr(191)


User Function BKLogo()
Local cLogo := '<img src="https://contato.bkconsultoria.com.br/content/grupo-bk.png" style="padding-left:5;border-width: 0;" width="200">'
Return cLogo


User Function BKLogos(cEmp)
Default cEmp := FWCodEmp()
Local cLogo := '<img src="http://10.139.0.30:80/logos/lgmid'+cEmp+'.png" style="padding-left:5px; border-width:0; width:300px; height:100px; object-fit:contain;">'
Return cLogo


User Function BKFavIco()
//<!-- Favicon -->
Local cRest := '<link rel="shortcut icon" href="http://10.139.0.30:80/favicon.ico">'
Return cRest

User Function BKDTStyle()
Local cHtml := ""
//<!-- Download: https://datatables.net/download/ -->
//<!-- Styling: Bootstrap 5 -->
//<!-- Packages: Jquery3, Bootstrap5, DataTables -->
//<!-- Extensions: Buttons, DateTime, FixedColumns, FixedHeader -->
//Awesome : https://cdn.datatables.net/plug-ins/2.1.4/integration/
//    <link href="https://cdn.datatables.net/plug-ins/2.1.4/integration/font-awesome/dataTables.fontAwesome.css rel="stylesheet">

BEGINCONTENT var cHTML
<link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/2.1.4/css/dataTables.bootstrap5.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/buttons/3.1.1/css/buttons.bootstrap5.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/datetime/1.5.3/css/dataTables.dateTime.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/fixedcolumns/5.0.1/css/fixedColumns.bootstrap5.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/fixedheader/4.0.1/css/fixedHeader.bootstrap5.min.css" rel="stylesheet">
ENDCONTENT
/* Select
<link href="https://cdn.datatables.net/select/2.0.5/css/select.bootstrap5.css" rel="stylesheet">
*/

Return cHtml


User Function BKBootStrap()
Local cHtml := ""

BEGINCONTENT var cHTML
<link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
ENDCONTENT

Return cHtml


User Function BKAwesome()
Local cHtml := ""
//https://cdnjs.com/libraries/font-awesome -->
BEGINCONTENT var cHTML
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" rel="stylesheet" type="text/css" />
ENDCONTENT
Return cHtml


User Function BKDTScript()
Local cHtml := ""

//<!-- Download: https://datatables.net/download/ -->
//<!-- Styling: Bootstrap 5 -->
//<!-- Packages: Jquery3, Bootstrap5, DataTables -->
//<!-- Extensions: Buttons, DateTime, FixedColumns, FixedHeader -->
BEGINCONTENT var cHTML
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/2.1.4/js/dataTables.min.js"></script>
<script src="https://cdn.datatables.net/2.1.4/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/3.1.1/js/dataTables.buttons.min.js"></script>
<script src="https://cdn.datatables.net/buttons/3.1.1/js/buttons.bootstrap5.min.js"></script>
<script src="https://cdn.datatables.net/datetime/1.5.3/js/dataTables.dateTime.min.js"></script>
<script src="https://cdn.datatables.net/fixedcolumns/5.0.1/js/dataTables.fixedColumns.min.js"></script>
<script src="https://cdn.datatables.net/fixedheader/4.0.1/js/dataTables.fixedHeader.min.js"></script>

<!-- Formatação de Data -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.2/moment.min.js"></script>

ENDCONTENT

/* Select
<script src="https://cdn.datatables.net/select/2.0.5/js/dataTables.select.js"></script>
<script src="https://cdn.datatables.net/select/2.0.5/js/select.bootstrap5.js"></script>
*/

Return cHtml

// Botão para abrir anexo via rest
// Empresa,Arquivo e Numero do Botão para id
// Exemplo: //cHtm += u_BtnAnexo(cEmpAnt,aFiles[nI,2],nI)
User Function BtnAnexo(cEmp,cFile,nBt)
Local cHtm 		as Character
Local cBtn 		as Character
Local cLinkBtn 	as Character

cBtn := "btn"+ALLTRIM(STR(nBt,0))
cLinkBtn = "Anexo('"+u_BkRest()+"/RestLibPN/v4?empresa="+cEmp+"&documento="+Encode64(cFile)+"&tpanexo=P',"+"'"+cFile+"','"+u_MimeFile(cFile)+"','"+cBtn+"')"
cHtm := '<button type="button" class="btn btn-link" id="'+cBtn+'" onclick="'+cLinkBtn+'">'+cFile+"</button>"+CRLF

Return cHtm



// Usar com browse externo
User Function AnexoHtml()
Local cHtml := ""
BEGINCONTENT var cHtml
<script>
	async function Anexo(url,cLink,mime,btna) {
		const btnanexo = document.getElementById(btna);
		const cbtnh = btnanexo.innerHTML; // Salva o conteúdo original do botão
	
		try {

			// Desabilita o botão e exibe o spinner
			btnanexo.disabled = true;
        	btnanexo.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span> Processando...';
	
			// Substitua os placeholders pelos valores reais
			const username = '#usrrest#';
			const password = '#pswrest#';
	
			// Codifica as credenciais em Base64
			const credentials = btoa(`${username}:${password}`);
	

			// Faz a requisição com autenticação básica
			const response = await fetch(url, {
				method: 'GET',
				headers: {
					'Authorization': `Basic ${credentials}`,
					'Content-Type': `${mime}`, // Adiciona o tipo de conteúdo, se necessário
				},
			});
	
			// Verifica se a resposta é válida
			if (!response.ok) {
				let errorDetails = "Erro desconhecido";
				try {
					// Tenta obter detalhes do erro da resposta (se for JSON)
					const errorResponse = await response.json();
					errorDetails = JSON.stringify(errorResponse);
				} catch (e) {
					// Se a resposta não for JSON, usa o texto da resposta
					errorDetails = await response.text();
				}
				throw new Error(`Erro ao baixar o arquivo: ${response.statusText}. Detalhes: ${errorDetails}`);
			}
	
       		// Obtém o blob (arquivo) da resposta
	   		const blob = await response.blob();

			// Cria uma URL temporária para o blob
			const blobUrl = URL.createObjectURL(blob);

			// Abre o arquivo em uma nova aba/janela
			window.open(blobUrl, '_blank');

			// Libera a URL temporária após o uso
			URL.revokeObjectURL(blobUrl);
		} catch (error) {
			console.error("Erro durante a execução da função Anexo:", error);
			alert(`Ocorreu um erro ao tentar abrir o arquivo: ${error.message}`);
		} finally {
			// Restaura o botão ao estado original
			btnanexo.disabled = false;
			btnanexo.innerHTML = cbtnh;
		}
	}

</script>
ENDCONTENT

cHtml := STRTRAN(cHtml,"#usrrest#"	 ,u_BkUsrRest())
cHtml := STRTRAN(cHtml,"#pswrest#"	 ,u_BkPswRest())

Return cHtml


// Funções para retornar Mime Type de arquivos 

User Function MimeFile(cFile)
Return u_MimeType(SUBSTR(cFile,RAt(".",cFile)+1))


User Function MimeType(cMime)
Local cContent 	:= ""
Local aMimes	:= {}
lOCAL nMime		:= 0

/*
'hqx'   => 'application/mac-binhex40',
    'cpt'   => 'application/mac-compactpro',
    'csv'   => array('text/x-comma-separated-values', 'text/comma-separated-values', 'application/octet-stream'),
    'bin'   => 'application/macbinary',
    'dms'   => 'application/octet-stream',
    'lha'   => 'application/octet-stream',
    'lzh'   => 'application/octet-stream',
    'exe'   => array('application/octet-stream', 'application/x-msdownload'),
    'class' => 'application/octet-stream',
    'psd'   => 'application/x-photoshop',
    'so'    => 'application/octet-stream',
    'sea'   => 'application/octet-stream',
    'dll'   => 'application/octet-stream',
    'oda'   => 'application/oda',
    'pdf'   => array('application/pdf', 'application/x-download'),
    'ai'    => 'application/postscript',
    'eps'   => 'application/postscript',
    'ps'    => 'application/postscript',
    'smi'   => 'application/smil',
    'smil'  => 'application/smil',
    'mif'   => 'application/vnd.mif',
    'xls'   => array('application/excel', 'application/vnd.ms-excel', 'application/msexcel'),
    'ppt'   => array('application/powerpoint', 'application/vnd.ms-powerpoint'),
    'wbxml' => 'application/wbxml',
    'wmlc'  => 'application/wmlc',
    'dcr'   => 'application/x-director',
    'dir'   => 'application/x-director',
    'dxr'   => 'application/x-director',
    'dvi'   => 'application/x-dvi',
    'gtar'  => 'application/x-gtar',
    'gz'    => 'application/x-gzip',
    'php'   => array('application/x-httpd-php', 'text/x-php'),
    'php4'  => 'application/x-httpd-php',
    'php3'  => 'application/x-httpd-php',
    'phtml' => 'application/x-httpd-php',
    'phps'  => 'application/x-httpd-php-source',
    'js'    => 'application/x-javascript',
    'swf'   => 'application/x-shockwave-flash',
    'sit'   => 'application/x-stuffit',
    'tar'   => 'application/x-tar',
    'tgz'   => array('application/x-tar', 'application/x-gzip-compressed'),
    'xhtml' => 'application/xhtml+xml',
    'xht'   => 'application/xhtml+xml',
    'zip'   => array('application/x-zip', 'application/zip', 'application/x-zip-compressed'),
    'mid'   => 'audio/midi',
    'midi'  => 'audio/midi',
    'mpga'  => 'audio/mpeg',
    'mp2'   => 'audio/mpeg',
    'mp3'   => array('audio/mpeg', 'audio/mpg', 'audio/mpeg3', 'audio/mp3'),
    'aif'   => 'audio/x-aiff',
    'aiff'  => 'audio/x-aiff',
    'aifc'  => 'audio/x-aiff',
    'ram'   => 'audio/x-pn-realaudio',
    'rm'    => 'audio/x-pn-realaudio',
    'rpm'   => 'audio/x-pn-realaudio-plugin',
    'ra'    => 'audio/x-realaudio',
    'rv'    => 'video/vnd.rn-realvideo',
    'wav'   => 'audio/x-wav',
    'bmp'   => 'image/bmp',
    'gif'   => 'image/gif',
    'jpeg'  => array('image/jpeg', 'image/pjpeg'),
    'jpg'   => array('image/jpeg', 'image/pjpeg'),
    'jpe'   => array('image/jpeg', 'image/pjpeg'),
    'png'   => 'image/png',
    'tiff'  => 'image/tiff',
    'tif'   => 'image/tiff',
    'css'   => 'text/css',
    'html'  => 'text/html',
    'htm'   => 'text/html',
    'shtml' => 'text/html',
    'txt'   => 'text/plain',
    'text'  => 'text/plain',
    'log'   => array('text/plain', 'text/x-log'),
    'rtx'   => 'text/richtext',
    'rtf'   => 'text/rtf',
    'xml'   => 'text/xml',
    'xsl'   => 'text/xml',
    'mpeg'  => 'video/mpeg',
    'mpg'   => 'video/mpeg',
    'mpe'   => 'video/mpeg',
    'qt'    => 'video/quicktime',
    'mov'   => 'video/quicktime',
    'avi'   => 'video/x-msvideo',
    'mp4'   => 'video/mp4',
    'wmv'   => 'video/x-ms-asf',
    'movie' => 'video/x-sgi-movie',
    'doc'   => 'application/msword',
    'docx'  => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'xlsx'  => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'word'  => array('application/msword', 'application/octet-stream'),
    'xl'    => 'application/excel',
    'eml'   => 'message/rfc822',
    'json'  => array('application/json', 'text/json'),
*/

    aAdd(aMimes,{'csv'  , 'text/comma-separated-values' })
    aAdd(aMimes,{'pdf'  , 'application/pdf' })
    aAdd(aMimes,{'xls'  , 'application/excel' })
    aAdd(aMimes,{'ppt'  , 'application/powerpoint' })
    aAdd(aMimes,{'xhtml', 'application/xhtml+xml' })
    aAdd(aMimes,{'zip'  , 'application/zip', })
    aAdd(aMimes,{'bmp'  , 'image/bmp' })
    aAdd(aMimes,{'gif'  , 'image/gif' })
    aAdd(aMimes,{'jpeg' , 'image/jpeg' })
    aAdd(aMimes,{'jpg'  , 'image/jpeg' })
    aAdd(aMimes,{'jpe'  , 'image/jpeg' })
    aAdd(aMimes,{'png'  , 'image/png' })
    aAdd(aMimes,{'tiff' , 'image/tiff' })
    aAdd(aMimes,{'tif'  , 'image/tiff' })
    aAdd(aMimes,{'html' , 'text/html' })
    aAdd(aMimes,{'htm'  , 'text/html' })
    aAdd(aMimes,{'shtml', 'text/html' })
    aAdd(aMimes,{'txt'  , 'text/plain' })
    aAdd(aMimes,{'text' , 'text/plain' })
    aAdd(aMimes,{'log'  , 'text/plain' })
    aAdd(aMimes,{'xml'  , 'text/xml' })
    aAdd(aMimes,{'xsl'  , 'text/xml' })
    aAdd(aMimes,{'mpeg' , 'video/mpeg' })
    aAdd(aMimes,{'mpg'  , 'video/mpeg' })
    aAdd(aMimes,{'mpe'  , 'video/mpeg' })
    aAdd(aMimes,{'doc'  , 'application/msword' })
    aAdd(aMimes,{'docx' , 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' })
    aAdd(aMimes,{'xlsx' , 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
    aAdd(aMimes,{'word' , 'application/msword' })
    aAdd(aMimes,{'xl'   , 'application/excel' })
    aAdd(aMimes,{'eml'  , 'message/rfc822' })
    aAdd(aMimes,{'json' , 'text/json' })

nMime := Ascan(aMimes, { |x| x[1] == Lower(cMime)})
If nMime > 0
	cContent := aMimes[nMime,2]
EndIf

Return cContent


// Usar com browse interno
// Exemplo (BKCOMA04): cHtm += '     <a href="'+u_BKIpServer()+'/recursos/loadanexo.html?empresa='+cEmpAnt+'&documento='+Encode64(aFiles[nI,2])+'&tpanexo=P&bkip='+u_BKRest()+'/RestLibPN/v4&username='+u_BKUsrRest()+'&password='+u_BKPswRest()+'&titulo'+cTitulo+'" target="_blank" class="link-primary">'+aFiles[nI,2]+'</a></br>'+CRLF

User Function LoadAnexo()
Local cHtml := ""
Local cFile := ""
cFile := u_SRecHttp()+"LoadAnexo.html"
If !File(cFile)
	BEGINCONTENT var cHtml
		<!DOCTYPE html>
		<html lang="pt-BR">
		<head>
			<meta charset="UTF-8">
			<meta name="viewport" content="width=device-width, initial-scale=1.0">
			<title>Abrir anexos</title>
			<style>
				/* Estilos para o layout */
				body, html {
					margin: 0;
					padding: 0;
					height: 100%;
					overflow: hidden; /* Evita barras de rolagem desnecessárias */
				}

				h3 {
					margin: 0;
					padding: 10px;
					background-color: #f0f0f0; /* Cor de fundo para o título */
				}

				.main {
					display: flex;
					flex-direction: column;
					height: calc(100% - 40px); /* Altura total menos o espaço do h3 */
				}

				#pdf-container {
					flex: 1; /* Ocupa todo o espaço restante */
					overflow: hidden; /* Evita barras de rolagem no container */
				}

				iframe {
					width: 100%;
					height: 100%;
					border: none; /* Remove a borda do iframe */
				}
			</style>
			<script>
				function abrirPDF() {
					try {
						// Obtém os parâmetros da URL
						const urlParams = new URLSearchParams(window.location.search);
						const empresa = urlParams.get('empresa');
						const documento = urlParams.get('documento');
						const tpanexo = urlParams.get('tpanexo');
						const bkip = urlParams.get('bkip');
						const username = urlParams.get('username');
						const password = urlParams.get('password');

						// Monta a URL do endpoint REST externo
						const url = `${bkip}?empresa=${empresa}&documento=${documento}&tpanexo=${tpanexo}`;

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
								return response.blob();
							} else {
								throw new Error(`Erro ao acessar o PDF: ${response.statusText}`);
							}
						})
						.then(blob => {
							console.log("Blob recebido:", blob);
							console.log("Tipo MIME do Blob:", blob.type);
							console.log("Tamanho do Blob:", blob.size);

							if (blob.size === 0) {
								throw new Error("O Blob está vazio.");
							}

							// Cria uma URL temporária para o Blob
							const blobUrl = URL.createObjectURL(blob);

							// Exibe o PDF na mesma página usando um <iframe>
							const iframe = document.createElement("iframe");
							iframe.src = blobUrl;

							// Remove qualquer conteúdo anterior e adiciona o iframe à página
							const container = document.getElementById("pdf-container");
							container.innerHTML = ""; // Limpa o conteúdo anterior
							container.appendChild(iframe);
						})
						.catch(error => {
							try {
								console.error("Erro no fetch:", error);
								console.log("Mensagem de erro:", error.message);
								console.log("Stack trace:", error.stack);
							} catch (err) {
								console.log("Erro ao tentar logar o erro:", err);
							}
							alert("Não foi possível abrir o PDF. Verifique o console para mais detalhes.");
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
				window.onload = abrirPDF;
			</script>
		</head>
		<body>
			<h3 id="titulo">Segue abaixo o conteúdo do Anexo: (caso não seja exibido, verifique os downloads e/ou habilite popup para este endereço)</h3>
			<div class="main">
				<div id="pdf-container"></div> <!-- Container para exibir o PDF -->
			</div>
		</body>
		</html>
	ENDCONTENT

	cHtml := StrIConv( cHtml, "CP1252", "UTF-8")
	cHtml := u_BKUtf8()+cHtml
	MemoWrite(cFile,cHtml)
EndIf
Return cHtml


