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
Local cIpPort := "10.139.0.30:8080"
If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer()) .OR. GetPort(1) = 1240 .OR. GetPort(1) = 1400
	cIpPort := "10.139.0.30:8081"
EndIf
//u_MsgLog(,GetEnvServer()+" - "+STR(GetPort(1))+" - "+cIpPort,"I")

Return cIpPort


// Retorna endere�o do REST BK
User Function BKRest()
Local cRest := "http://"+u_BkIpPort()+"/rest"
Return cRest


// Retorna endere�o do Servidor BK
User Function BKIpServer()
Local cRest := "http://10.139.0.30"
Return cRest

// Usu�rio para consumo de API REST
User Function BKUsrRest()
Return "web"

User Function BKPswRest()
Return "846250"


User Function BKLogo()
Local cLogo := '<img src="https://contato.bkconsultoria.com.br/content/grupo-bk.png" style="padding-left:5;border-width: 0;" width="200">'
Return cLogo


User Function BKLogos(cEmp)
Local cLogo := '<img src="http://10.139.0.30:80/logos/lgmid'+cEmp+'.png style="padding-left:5;border-width: 0;" width="30"">'
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

<!-- Formata��o de Data -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.2/moment.min.js"></script>

ENDCONTENT

/* Select
<script src="https://cdn.datatables.net/select/2.0.5/js/dataTables.select.js"></script>
<script src="https://cdn.datatables.net/select/2.0.5/js/select.bootstrap5.js"></script>
*/

Return cHtml


