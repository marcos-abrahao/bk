#include "totvs.ch"
#include "protheus.ch"

/*/{Protheus.doc} BKVARS
BK - Funcoes com par�metros embutidos no fonte
@Return
@author Marcos B. Abrah�o
@since 03/05/22
@version P12
/*/


// Retorna IP e Porta do server REST
User Function BkIpPort()
Local cIpPort := "10.139.0.30:8080"
If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer()) //.OR. GetPort(1) = 1500
	cIpPort := "10.139.0.30:8081"
EndIf
//u_MsgLog(,GetEnvServer()+" - "+cIpPort,"I")
Return cIpPort


// Retorna endere�o do REST BK
User Function BKRest()
Local cRest := "http://"+u_BkIpPort()+"/rest"
Return cRest


// Retorna endere�o do Servidor BK
User Function BKIpServer()
Local cRest := "http://10.139.0.30"
Return cRest


User Function BKFavIco()
//<!-- Favicon -->
Local cRest := '<link rel="shortcut icon" href="http://10.139.0.30:80/favicon.ico">'
Return cRest

User Function BKDTStyle()
Local cHtml := ""
//<!-- Styling https://datatables.net/download/ -->
//<!-- CSS Bootstrap 5 -->
//<!-- Packages: Jquery3, Bootstrap5, DataTables -->
//<!-- Extensions: Buttons, DateTime, FixedColumns, FixedHeader -->

BEGINCONTENT var cHTML
<link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/2.0.8/css/dataTables.bootstrap5.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/buttons/3.0.2/css/buttons.bootstrap5.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/datetime/1.5.2/css/dataTables.dateTime.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/fixedcolumns/5.0.1/css/fixedColumns.bootstrap5.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/fixedheader/4.0.1/css/fixedHeader.bootstrap5.min.css" rel="stylesheet">
ENDCONTENT

Return cHtml


User Function BKDTScript()
Local cHtml := ""

//<!-- JavaScript https://datatables.net/download/-->
//<!-- Packages: Jquery3, Bootstrap5, DataTables -->
//<!-- Extensions: Buttons, DateTime, FixedColumns, FixedHeader -->
BEGINCONTENT var cHTML
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.datatables.net/2.0.8/js/dataTables.min.js"></script>
<script src="https://cdn.datatables.net/2.0.8/js/dataTables.bootstrap5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/3.0.2/js/dataTables.buttons.min.js"></script>
<script src="https://cdn.datatables.net/buttons/3.0.2/js/buttons.bootstrap5.min.js"></script>
<script src="https://cdn.datatables.net/datetime/1.5.2/js/dataTables.dateTime.min.js"></script>
<script src="https://cdn.datatables.net/fixedcolumns/5.0.1/js/dataTables.fixedColumns.min.js"></script>
<script src="https://cdn.datatables.net/fixedheader/4.0.1/js/dataTables.fixedHeader.min.js"></script>

ENDCONTENT

Return cHtml
