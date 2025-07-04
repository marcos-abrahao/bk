#include "totvs.ch"
#include "protheus.ch"

/*/{Protheus.doc} BKHTML
BK - Funcoes com par�metros embutidos no fonte
@Return
@author Marcos B. Abrah�o
@since 03/05/22
@version P12
/*/

// Retorna IP e Porta do server REST
User Function BkIpPort()
Local cIpPort := "10.150.0.25:8080"
If u_AmbTeste()
	cIpPort := "10.150.0.25:8081"
EndIf
//u_MsgLog(,GetEnvServer()+" - "+STR(GetPort(1))+" - "+cIpPort,"I")

Return cIpPort


User Function BkSrvWeb()
Local cIpPort := "http://10.150.0.25:80"
Return cIpPort


User Function AmbTeste()
Local lRet := .F.
If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer()) .OR. GetPort(1) = 1240 .OR. GetPort(1) = 1400
	lRet := .T.
EndIf
Return lRet

// Retorna endere�o do REST BK
User Function BKRest()
Local cRest := "http://"+u_BkIpPort()+"/rest"
Return cRest


// Retorna endere�o do Servidor BK
User Function BKIpServer()
Local cRest := "http://10.150.0.25"
Return cRest

// Usu�rio para consumo de API REST
User Function BKUsrRest()
Return "web"

User Function BKPswRest()
Return "846250"


// String a ser colocada em um arquivo HTML para identificar que � um arquivo UTF-8
User Function BKUtf8()
Return Chr(239) + Chr(187) + Chr(191)


User Function BKLogos(cEmp)
Local cLink  := ""
Local cLogo  := ""
Default cEmp := FWCodEmp()

If FWCodEmp() == "01"      // BK
	cLink:= "https://drive.google.com/thumbnail?id=1oIDeUVCuwhFL9ISYdnkVeyPb-FXf5UHt"
ElseIf FWCodEmp() == "02"  // HF
	cLink:= "https://drive.google.com/thumbnail?id=1W4TKkyJcyiE42C1OgPrRvx8uU3V-98UH"
ElseIf FWCodEmp() == "04"  // ESA
	cLink:= "https://drive.google.com/thumbnail?id=1pzg8pXA-yPYAy90GutUbZrHqcgd-HkTj"
ElseIf FWCodEmp() == "06"  // BKDAHER SUZANO
	cLink:= "https://drive.google.com/thumbnail?id=1euoWrvOrFB7MZcrbPTSUL8dLQNDohThs"
ElseIf FWCodEmp() == "07"  // JUSTSOFTWARE
	cLink:= "https://drive.google.com/thumbnail?id=1S4D0M1y3UNJ7F50cse9QM88XUcus3G0O"
ElseIf FWCodEmp() == "08"  // BHG CAMPINAS
	cLink:= "https://drive.google.com/thumbnail?id=1PG3T7b6pQ4L7I0ogmziECzWNy7hJg7YW"
ElseIf FWCodEmp() == "09"  // BHG OSASCO
	cLink:= "https://drive.google.com/thumbnail?id=1HuOLWvapR9T33NuLU0Hx5FmQBJGPBTTU"
ElseIf FWCodEmp() == "10"  // BKDAHER TABOAO DA SERRA
	cLink:= "https://drive.google.com/thumbnail?id=1G8nQRJDWZJJqhtc1Be24WVmAcSq_cNsv"
ElseIf FWCodEmp() == "11"  // BKDAHER LIMEIRA
	cLink:= "https://drive.google.com/thumbnail?id=1e_3x4qXRrJTNiOo4bXGO3zPVnE3aMqE8"
ElseIf FWCodEmp() == "12"  // BK CORRETORA
	cLink:= "https://drive.google.com/thumbnail?id=11TCN27XesHba62Hkz6U1foXzWD1NPH0N"
ElseIf FWCodEmp() == "14"  // CONSORCIO NOVA BALSA
	cLink:= "https://drive.google.com/thumbnail?id=1hLWfAPyjOy2Lmyca7ERm3zMyCmP4B61o"
ElseIf FWCodEmp() == "15"  // BHG INTERIOR 3
	cLink:= "https://drive.google.com/thumbnail?id=1n35iuPHcoA8PP7sPOzc3apW3lb4nR2LW"
ElseIf FWCodEmp() == "16"  // MOOVE
	cLink:= "https://drive.google.com/thumbnail?id=1SOjCnmC3k1MztSB0vuot6109CjRMv9Eu"
ElseIf FWCodEmp() == "17"  // DMAF
	cLink:= "https://drive.google.com/thumbnail?id=1qQ3RxxDMwBxjJDGOYDJdeyZVCt1fvwru"
ElseIf FWCodEmp() == "18"  // BK VIA
	cLink:= "https://drive.google.com/thumbnail?id=1RfjrHRA64hKUGPuiVd5nWF2N53Su82LQ"
ElseIf FWCodEmp() == "19"  // BK SOL TEC
	cLink:= "https://drive.google.com/thumbnail?id=1SD0noro-C8rybd6tTC8RIbkFii3WJ1HY"
ElseIf FWCodEmp() == "20"  // BARCAS RIO
	cLink:= "https://drive.google.com/thumbnail?id=1IvZEQcmon3jn4ji6w0WRKvq9FAruuoll"
ElseIf FWCodEmp() == "97"  // CMOG
	cLink:= "https://drive.google.com/thumbnail?id=1CzmRwLfPFWqJ6kL5y6ibrIpaD-4TXl8m"
ElseIf FWCodEmp() == "98"  // TERO
	cLink:= "https://drive.google.com/thumbnail?id=1h7kQXhFEAMeAT8xn7qlgIKU7z1JEX9QJ"
Endif	

//Local cLogo := '<img src="'+u_BkSrvWeb()+'/logos/lgmid'+cEmp+'.png" style="padding-left:5px; border-width:0; width:300px; height:100px; object-fit:contain;">'
cLogo := '<img src="'+cLink+'" style="padding-left:5px; border-width:0; width:150px; object-fit:contain;">'

Return cLogo


User Function BKFavIco()
//<!-- Favicon -->
Local cRest := '<link rel="shortcut icon" href="'+u_BkSrvWeb()+'/favicon.ico">'
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

<link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-9ndCyUaIbzAi2FUVXJi0CjmCapSmO7SnpJef0486qhLnuZ2cdeRhO02iuK6FUUVM" crossorigin="anonymous">
<link href="https://cdn.datatables.net/2.3.1/css/dataTables.bootstrap5.min.css" rel="stylesheet" integrity="sha384-5hBbs6yhVjtqKk08rsxdk9xO80wJES15HnXHglWBQoj3cus3WT+qDJRpvs5rRP2c" crossorigin="anonymous">
<link href="https://cdn.datatables.net/buttons/3.2.3/css/buttons.bootstrap5.min.css" rel="stylesheet" integrity="sha384-DJhypeLg79qWALC844KORuTtaJcH45J+36wNgzj4d1Kv1vt2PtRuV2eVmdkVmf/U" crossorigin="anonymous">
<link href="https://cdn.datatables.net/datetime/1.5.5/css/dataTables.dateTime.min.css" rel="stylesheet" integrity="sha384-YerHysLtHRSApTDI4rm8VWFCYYmfBxaFWwYtysBUoNAtgL4Kbf04QSepZbpz5wji" crossorigin="anonymous">
<link href="https://cdn.datatables.net/fixedcolumns/5.0.4/css/fixedColumns.bootstrap5.min.css" rel="stylesheet" integrity="sha384-StUfKBL80ZWBFxSXA89vIUJ85yyOsUA5Gi6oLYEPaJd8WPvS1D9jIqLQDLWAO6jc" crossorigin="anonymous">
<link href="https://cdn.datatables.net/fixedheader/4.0.2/css/fixedHeader.bootstrap5.min.css" rel="stylesheet" integrity="sha384-OpjrOKWHgAo4SFhzmU3mBpqt+bXpISGTDqlG7KNsjknJnp72nQdpiQaPKzi1NkjR" crossorigin="anonymous">

<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css" rel="stylesheet">

ENDCONTENT
/* Old Select
<link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/2.1.4/css/dataTables.bootstrap5.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/buttons/3.1.1/css/buttons.bootstrap5.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/datetime/1.5.3/css/dataTables.dateTime.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/fixedcolumns/5.0.1/css/fixedColumns.bootstrap5.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/fixedheader/4.0.1/css/fixedHeader.bootstrap5.min.css" rel="stylesheet">
*/

Return cHtml


User Function BKBootStrap()
Local cHtml := ""

BEGINCONTENT var cHTML
<link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css" rel="stylesheet">
ENDCONTENT

Return cHtml


User Function BKAwesome()
Local cHtml := ""
//https://cdnjs.com/libraries/font-awesome -->
BEGINCONTENT var cHTML
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css" rel="stylesheet" type="text/css" />
ENDCONTENT
Return cHtml

/* Old
<link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" rel="stylesheet" type="text/css" />
*/

User Function BKDTScript()
Local cHtml := ""

//<!-- Download: https://datatables.net/download/ -->
//<!-- Styling: Bootstrap 5 -->
//<!-- Packages: Jquery3, Bootstrap5, DataTables -->
//<!-- Extensions: Buttons, DateTime, FixedColumns, FixedHeader -->

/* 29-05-2025
Step 1. Choose styling
- Bootstrap 5

Step 2. Select packages
- jQuery
- Moment
- Bootstrap 5

DataTables core
-DataTables

Extensions
- Buttons
- DateTime
- FixedColumns
-FixedHeader

CDN
- Minify
*/
 


BEGINCONTENT var cHTML

<script src="https://code.jquery.com/jquery-3.7.0.min.js" integrity="sha384-NXgwF8Kv9SSAr+jemKKcbvQsz+teULH/a5UNJvZc6kP47hZgl62M1vGnw6gHQhb1" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.4/moment.min.js" integrity="sha384-VCGDSwGwLWkVOK5vAWSaY38KZ4oKJ0whHjpJQhjqrMlWadpf2dUVKLgOLBdEaLvZ" crossorigin="anonymous"></script>
<script src="https://cdn.datatables.net/2.3.1/js/dataTables.min.js" integrity="sha384-LiV1KhVIIiAY/+IrQtQib29gCaonfR5MgtWzPCTBVtEVJ7uYd0u8jFmf4xka4WVy" crossorigin="anonymous"></script>
<script src="https://cdn.datatables.net/2.3.1/js/dataTables.bootstrap5.min.js" integrity="sha384-G85lmdZCo2WkHaZ8U1ZceHekzKcg37sFrs4St2+u/r2UtfvSDQmQrkMsEx4Cgv/W" crossorigin="anonymous"></script>
<script src="https://cdn.datatables.net/buttons/3.2.3/js/dataTables.buttons.min.js" integrity="sha384-zlMvVlfnPFKXDpBlp4qbwVDBLGTxbedBY2ZetEqwXrfWm+DHPvVJ1ZX7xQIBn4bU" crossorigin="anonymous"></script>
<script src="https://cdn.datatables.net/buttons/3.2.3/js/buttons.bootstrap5.min.js" integrity="sha384-BdedgzbgcQH1hGtNWLD56fSa7LYUCzyRMuDzgr5+9etd1/W7eT0kHDrsADMmx60k" crossorigin="anonymous"></script>
<script src="https://cdn.datatables.net/datetime/1.5.5/js/dataTables.dateTime.min.js" integrity="sha384-1a4pxt2oxato6x8A+75Oxr1nWUJWtjgWPom0n9VFGK/JD5+u9+3oKSAzW6k0/iMb" crossorigin="anonymous"></script>
<script src="https://cdn.datatables.net/fixedcolumns/5.0.4/js/dataTables.fixedColumns.min.js" integrity="sha384-pTT0DCmQdJKH1Vz2e0adpu+1Tp4tiIYm+vF6e+b+YAywojOEf3TR2WyIGdICT5Gy" crossorigin="anonymous"></script>
<script src="https://cdn.datatables.net/fixedheader/4.0.2/js/dataTables.fixedHeader.min.js" integrity="sha384-lPZltuOfggvHaMDQ/WOuU/YgMR8sK1jIoYiLD9CoLk8SOut6TcXa9PW751NOdVpW" crossorigin="anonymous"></script>

ENDCONTENT

/* Old Select
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/2.1.4/js/dataTables.min.js"></script>
<script src="https://cdn.datatables.net/2.1.4/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/3.1.1/js/dataTables.buttons.min.js"></script>
<script src="https://cdn.datatables.net/buttons/3.1.1/js/buttons.bootstrap5.min.js"></script>
<script src="https://cdn.datatables.net/datetime/1.5.3/js/dataTables.dateTime.min.js"></script>
<script src="https://cdn.datatables.net/fixedcolumns/5.0.1/js/dataTables.fixedColumns.min.js"></script>
<script src="https://cdn.datatables.net/fixedheader/4.0.1/js/dataTables.fixedHeader.min.js"></script>

<!-- Formata��o de Data -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.2/moment.min.js"></script>
*/

Return cHtml



// Usar com browse externo
User Function AnexoHtml(lScript)
Local cHtml := ""
Default lScript := .F.

// cTpAnexo = "P"  // Pasta Doc
// cTpAnexo = "A"  // Pasta Tmp Server

BEGINCONTENT var cHtml
async function AnexoBk(cEmp,cEncFile,cMime,btnA,cTpAnexo) {
	const btnanexo = document.getElementById(btnA);
	const cbtnh = btnanexo.innerHTML; // Salva o conte�do original do bot�o
	const url = '#iprest#/RestLibPN/v4?empresa='+cEmp+'&documento='+cEncFile+'&tpanexo='+cTpAnexo
	try {
		// Desabilita o bot�o e exibe o spinner
		btnanexo.disabled = true;
       	btnanexo.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span> Processando...';

		// Substitua os placeholders pelos valores reais
		const username = '#usrrest#';
		const password = '#pswrest#';

		// Codifica as credenciais em Base64
		const credentials = btoa(`${username}:${password}`);

		// Faz a requisi��o com autentica��o b�sica
		const response = await fetch(url, {
			method: 'GET',
			headers: {
				'Authorization': `Basic ${credentials}`,
				'Content-Type': `${cMime}`, // Adiciona o tipo de conte�do, se necess�rio
			},
		});

		// Verifica se a resposta � v�lida
		if (!response.ok) {
			let errorDetails = "Erro desconhecido";
			try {
				// Tenta obter detalhes do erro da resposta (se for JSON)
				const errorResponse = await response.json();
				errorDetails = JSON.stringify(errorResponse);
			} catch (e) {
				// Se a resposta n�o for JSON, usa o texto da resposta
				errorDetails = await response.text();
			}
			throw new Error(`Erro ao baixar o arquivo: ${response.statusText}. Detalhes: ${errorDetails}`);
		}

      	// Obt�m o blob (arquivo) da resposta
   		const blob = await response.blob();
		// Cria uma URL tempor�ria para o blob
		const blobUrl = URL.createObjectURL(blob);
		// Abre o arquivo em uma nova aba/janela
		window.open(blobUrl, '_blank');
		// Libera a URL tempor�ria ap�s o uso
		URL.revokeObjectURL(blobUrl);
	} catch (error) {
		console.error("Erro durante a execu��o da fun��o Anexo:", error);
		alert(`Ocorreu um erro ao tentar abrir o arquivo: ${error.message}`);
	} finally {
		// Restaura o bot�o ao estado original
		btnanexo.disabled = false;
		btnanexo.innerHTML = cbtnh;
	}
}
ENDCONTENT
cHtml := STRTRAN(cHtml,"#iprest#"	 ,u_BkRest())
cHtml := STRTRAN(cHtml,"#usrrest#"	 ,u_BkUsrRest())
cHtml := STRTRAN(cHtml,"#pswrest#"	 ,u_BkPswRest())
If lScript
	// Se estiver fora de um script
	cHtml:= '<script>'+CRLF+cHtml+CRLF+'</script>'+CRLF
EndIf
Return cHtml


// Fun��es para retornar Mime Type de arquivos 

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


// Bot�o para abrir anexo via rest
// Empresa,Arquivo e Numero do Bot�o para id
// Exemplo: //cHtm += u_BtnAnexo(cEmpAnt,aFiles[nI,2],nI)
User Function BtnAnexo(cEmp,cFile,cTpAnexo)
Local cHtm 		as Character
//Local cBtn 		as Character
//Local cLinkBtn 	as Character
Default cTpAnexo := "P"

//cBtn := "btnAnx"+ALLTRIM(STR(nBt,0))
//cLinkBtn := "Anexo('"+u_BkRest()+"/RestLibPN/v4?empresa="+cEmp+"&documento="+Encode64(cFile)+"&tpanexo=P',"+"'"+cFile+"','"+u_MimeFile(cFile)+"','"+cBtn+"','P')"
//cLinkBtn := u_BKIpServer()+'/recursos/loadanexo.html?empresa='+cEmpAnt+'&documento='+Encode64(cFile)+'&tpanexo='+cTpAnexo+'&bkip='+u_BKRest()+'/RestLibPN/v4&username='+u_BKUsrRest()+'&password='+u_BKPswRest()
//cHtm := '<button type="button" class="btn btn-link" style="font-size: 0.9rem;" id="'+cBtn+'" onclick="'+cLinkBtn+'">'+cFile+"</button>"+CRLF
cHtm := '<a href="'+u_BKIpServer()+'/recursos/loadanexo.html?empresa='+cEmp+'&documento='+Encode64(cFile)+'&tpanexo='+cTpAnexo+'&bkip='+u_BKRest()+'/RestLibPN/v4&username='+u_BKUsrRest()+'&password='+u_BKPswRest()+'" target="_blank" class="link-primary"><i class="bi bi-paperclip">'+cFile+'</a></br>'+CRLF

//cHtm := '<button type="button" class="btn btn-link" style="font-size: 0.9rem;" id="'+cbtn+'"'+;
//					' onclick="parent.AnexoBk('+"'"+cEmp+"','"+Encode64(cFile)+"','"+u_MimeFile(cFile)+"','"+cBtn+"','"+cTpAnexo+"')"+'">'+;
//					'<i class="bi bi-paperclip"></i>'+cFile+'</button>'

//<button type="button" class="btn btn-link" style="font-size: 0.9rem;" id="btnAn1" onclick=" anexo('01','qvbuty5qrey="," application="" pdf','btnan1','p')"=""><i class="bi bi-paperclip"></i>APTO.PDF</button>

/*
<form action="http://10.150.0.25/recursos/loadanexo.html" method="get" target="_blank">
  <input type="hidden" name="empresa" value="01">
  <input type="hidden" name="documento" value="QVBUTy5QREY=">
  <input type="hidden" name="tpanexo" value="P">
  <input type="hidden" name="bkip" value="http://10.150.0.25:8081/rest/RestLibPN/v4">
  <input type="hidden" name="username" value="web">
  <input type="hidden" name="password" value="846250">
  
  <button type="submit" class="link-primary">APTO.PDF</button>
</form>
*/


Return cHtm

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
					overflow: hidden; /* Evita barras de rolagem desnecess�rias */
				}

				h3 {
					margin: 0;
					padding: 10px;
					background-color: #f0f0f0; /* Cor de fundo para o t�tulo */
				}

				.main {
					display: flex;
					flex-direction: column;
					height: calc(100% - 40px); /* Altura total menos o espa�o do h3 */
				}

				#pdf-container {
					flex: 1; /* Ocupa todo o espa�o restante */
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
						// Obt�m os par�metros da URL
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
								throw new Error("O Blob est� vazio.");
							}

							// Cria uma URL tempor�ria para o Blob
							const blobUrl = URL.createObjectURL(blob);

							// Exibe o PDF na mesma p�gina usando um <iframe>
							const iframe = document.createElement("iframe");
							iframe.src = blobUrl;

							// Remove qualquer conte�do anterior e adiciona o iframe � p�gina
							const container = document.getElementById("pdf-container");
							container.innerHTML = ""; // Limpa o conte�do anterior
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
							alert("N�o foi poss�vel abrir o PDF. Verifique o console para mais detalhes.");
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
				window.onload = abrirPDF;
			</script>
		</head>
		<body>
			<h3 id="titulo">Segue abaixo o conte�do do Anexo: (caso n�o seja exibido, verifique os downloads e/ou habilite popup para este endere�o)</h3>
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


