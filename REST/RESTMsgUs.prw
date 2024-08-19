#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} RestMsgUs
    REST Avisos BK
	https://datatables.net/examples/api/row_details.html
    @type  REST
    @author Marcos B. Abrahão
    @since 09/08/2024
    @version 12.2310
/*/

WSRESTFUL RestMsgUs DESCRIPTION "Rest Avisos BK"

	WSDATA mensagem     AS STRING
	WSDATA empresa      AS STRING
	WSDATA z0recno      AS STRING
	WSDATA filial       AS STRING
	WSDATA userlib 		AS STRING OPTIONAL
	WSDATA acao 		AS STRING

	WSMETHOD GET LISTAV1;
		DESCRIPTION "Listar avisos recebidos";
		WSSYNTAX "/RestMsgUs/v0";
		PATH  "/RestMsgUs/v0";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET BROWAV1;
		DESCRIPTION "Browse avisos recebidos";
		WSSYNTAX "/RestMsgUs/v2";
		PATH "/RestMsgUs/v2";
		TTALK "v1";
		PRODUCES TEXT_HTML


	WSMETHOD PUT STATUS;
		DESCRIPTION "Alterar o status do aviso" ;
		WSSYNTAX "/RestMsgUs/v4";
		PATH "/RestMsgUs/v4";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL



//v4
WSMETHOD PUT STATUS QUERYPARAM empresa,z0recno,userlib,acao WSREST RestMsgUs 

Local cJson			:= Self:GetContent()   
Local lRet			:= .T.
Local oJson			As Object
Local aParams		As Array
Local cMsg			As Char

::setContentType('application/json')

oJson := JsonObject():New()
oJson:FromJSON(cJson)

If u_BkAvPar(::userlib,@aParams,@cMsg)

	lRet := fStatus(::empresa,::z0recno,::acao,@cMsg)

EndIf

oJson['liberacao'] := StrIConv(cMsg, "CP1252", "UTF-8")

cRet := oJson:ToJson()

FreeObj(oJson)
// CORS
Self:SetHeader("Access-Control-Allow-Origin", "*")

Self:SetResponse(cRet)
  
Return lRet



Static Function fStatus(empresa,z0recno,acao,cMsg)
Local lRet 		:= .F.
Local cQuery	:= ""
Local cTabSE2	:= "SE2"+empresa+"0"
Local cQrySZ0	:= GetNextAlias()
Local cNum		:= ""

Default cMsg	:= ""
Default cMotivo := ""

Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

cQuery := "SELECT "
cQuery += "  SE2.E2_XXPGTO,"
cQuery += "  SE2.D_E_L_E_T_ AS E2DELET,"
cQuery += "  SE2.E2_NUM "
cQuery += " FROM "+cTabSE2+" SE2 "
cQuery += " WHERE SE2.R_E_C_N_O_ = "+z0recno

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySZ0,.T.,.T.)

cNum := (cQrySZ0)->E2_NUM
Do Case
	Case (cQrySZ0)->(Eof()) 
		cMsg:= "não encontrado"
	Case (cQrySZ0)->E2DELET = '*'
		cMsg:= "foi excluído"
	OtherWise 
		// Alterar o Status
		cMsg 	:= acao
		cQuery := "UPDATE "+cTabSE2+CRLF
		cQuery += "  SET E2_XXPGTO = '"+SUBSTR(acao,1,1)+"',"+CRLF
		cQuery += "      E2_XXOPER = '"+__cUserId+"'"+CRLF
		cQuery += " FROM "+cTabSE2+" SE2"+CRLF
		cQuery += " WHERE SE2.R_E_C_N_O_ = "+z0recno+CRLF

		If TCSQLExec(cQuery) < 0 
			cMsg := "Erro: "+TCSQLERROR()
		Else
			lRet := .T.
		EndIf
EndCase

cMsg := cNum+" "+cMsg

u_MsgLog("RESTMsgUs",cMsg)

(cQrySZ0)->(dbCloseArea())

Return lRet




/*/{Protheus.doc} GET 
Retorna a lista de avisos recebidos.
/*/

// v0
WSMETHOD GET LISTAV1 QUERYPARAM userlib WSREST RestMsgUs
Local aListAV1 		:= {}
Local cQrySZ0       := GetNextAlias()
Local cJsonCli      := ''
Local lRet 			:= .T.
Local oJsonTmp	 	:= JsonObject():New()
Local aParams      	As Array
Local cMsg         	As Character

//u_MsgLog("RESTMsgUs",VarInfo("vencini",self:vencini))

If !u_BkAvPar(::userlib,@aParams,@cMsg)
  oJsonTmp['liberacao'] := cMsg
  cRet := oJsonTmp:ToJson()
  FreeObj(oJsonTmp)
  //Retorno do servico
  ::SetResponse(cRet)
  Return lRet:= .T.
EndIf


// Query para selecionar os Títulos a Pagar
TmpQuery(cQrySZ0,"R")

//-------------------------------------------------------------------
// Alimenta array de Pré-notas
//-------------------------------------------------------------------
Do While ( cQrySZ0 )->( ! Eof() )

	aAdd( aListAV1 , JsonObject():New() )

	nPos	:= Len(aListAV1)

	aListAV1[nPos]['EMPRESA']	:= u_BKNEmpr((cQrySZ0)->EMPRESA,3)
	aListAV1[nPos]['USRREM']    := TRIM((cQrySZ0)->USRREM)
	aListAV1[nPos]['USRDEST']	:= TRIM((cQrySZ0)->USRDEST)
	aListAV1[nPos]['MSG']		:= TRIM((cQrySZ0)->Z0_MSG)
	aListAV1[nPos]['DTENV'] 	:= TRIM((cQrySZ0)->Z0_DTENV)
	aListAV1[nPos]['HRENV'] 	:= TRIM((cQrySZ0)->Z0_HRENV)
	aListAV1[nPos]['Z0RECNO']	:= STRZERO((cQrySZ0)->Z0RECNO,7)

	(cQrySZ0)->(DBSkip())

EndDo

( cQrySZ0 )->( DBCloseArea() )

oJsonTmp	 := aListAV1

//-------------------------------------------------------------------
// Serializa objeto Json
//-------------------------------------------------------------------
cJsonCli:= FwJsonSerialize( oJsonTmp )

//-------------------------------------------------------------------
// Elimina objeto da memoria
//-------------------------------------------------------------------
FreeObj(oJsonTmp)


// CORS
Self:SetHeader("Access-Control-Allow-Origin", "*")

Self:SetResponse( cJsonCli ) //-- Seta resposta

Return( lRet )


// /v2
WSMETHOD GET BROWAV1 QUERYPARAM empresa,vencini,vencfim,userlib WSREST RestMsgUs

Local cHTML		as char
Local cDropEmp	as char
Local aEmpresas := u_BKGrupo()
Local nE 		:= 0

BEGINCONTENT var cHTML

<!doctype html>
<html lang="pt-BR">
<head>
<!-- Required meta tags -->
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Styling CSS -->
#BKDTStyle#

<title>Títulos Contas a Pagar #datavencI# #datavencF# #NomeEmpresa#</title>

<!-- Favicon -->
#BKFavIco#

<style type="text/css">
.bk-colors{
 background-color: #9E0000;
 color: white;
}
.bg-mynav {
  background-color: #9E0000;
  padding-left:5px;
  padding-right:5px;
}
.font-condensed{
  font-size: 0.8em;
}
body {
font-size: 0.8rem;
	background-color: #f6f8fa;
	}
td {
line-height: 1rem;
	vertical-align: middle;
	}

table.dataTable.table-sm>thead>tr th.dt-orderable-asc,table.dataTable.table-sm>thead>tr th.dt-orderable-desc,table.dataTable.table-sm>thead>tr th.dt-ordering-asc,table.dataTable.table-sm>thead>tr th.dt-ordering-desc,table.dataTable.table-sm>thead>tr td.dt-orderable-asc,table.dataTable.table-sm>thead>tr td.dt-orderable-desc,table.dataTable.table-sm>thead>tr td.dt-ordering-asc,table.dataTable.table-sm>thead>tr td.dt-ordering-desc {
    padding-right: 3px;
}

thead input {
	width: 100%;
	font-weight: bold;
	background-color: #F3F3F3
}

</style>
</head>
<body>
<nav class="navbar navbar-dark bg-mynav fixed-top justify-content-between">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Avisos - #cUserName#</a> 

    <form class="d-flex">
	    <button type="button" class="btn btn-dark" aria-label="Atualizar" onclick="window.location.reload();">Atualizar</button>
    </form>

  </div>
</nav>
<br>
<br>
<br>
<div class="container-fluid">
<div class="table-responsive-sm">
<table id="tableAV1" class="table table-sm table-hover" style="width:100%">
<thead>
<tr>
<th scope="col"></th>
<th scope="col">Empresa</th>
<th scope="col">Remetente</th>
<th scope="col">Destinatário</th>
<th scope="col">Mensagem</th>
<th scope="col">Data</th>
<th scope="col">Hora</th>
</tr>
</thead>
<tbody id="mytable1">
<tr>
  <th scope="col">Carregando Mensagens...</th>
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col"></th>
</tr>
</tbody>
</table>
</div>
</div>

<!-- JavaScript -->
#BKDTScript#

<script>

async function getAv1() {
	let url = '#iprest#/RestMsgUs/v0?userlib=#userlib#'
		try {
		let res = await fetch(url);
			return await res.json();
			} catch (error) {
		console.log(error);
			}
		}


async function loadTable() {
let av1 = await getAv1();
let trHTML = '';
let nlin = 0;
let ccbtn = 'light';
let cbtnidp = '';
let cbtnids = '';
let cbtnz2 = '';
let anexos = '';

if (Array.isArray(av1)) {
	av1.forEach(object => {

	nlin += 1; 
	cbtnz2 = 'btnz2'+nlin;

	if (cStatus == 'C' ){
	 ccbtn = 'success';
	} else if (cStatus == ' ' || cStatus == 'A'){
	 ccbtn = 'warning';
	} else if (cStatus == 'P'){
	 ccbtn = 'danger';
	} else if (cStatus == 'O'){
	 ccbtn = 'primary';
	} else if (cStatus == 'D'){
	 ccbtn = 'dark';
	} else if (cStatus == 'L'){
	 ccbtn = 'info';
	} else if (cStatus == 'T'){
	 ccbtn = 'secondary';
	}

	trHTML += '<tr>';
	trHTML += '<td></td>';
	trHTML += '<td>'+object['EMPRESA']+'</td>';
	trHTML += '<td>'+object['USRREM']+'</td>';
	trHTML += '<td>'+object['USRDEST']+'</td>';
	trHTML += '<td>'+object['MSG']+'</td>';
	trHTML += '<td>'+object['DTENV']+'</td>';
	trHTML += '<td>'+object['HRENV']+'</td>';
	trHTML += '</tr>';
	});
} else {
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="7" style="text-align:center;">'+titulos['liberacao']+'</th>';
    trHTML += '</tr>';   
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="7" style="text-align:center;">Faça login novamente no sistema Protheus</th>';
    trHTML += '</tr>';   
}
document.getElementById("mytable1").innerHTML = trHTML;


tableAV1 = $('#tableAV1').DataTable({
  "pageLength": 100,
  "language": {
  "lengthMenu": "Registros por página: _MENU_ ",
  "zeroRecords": "Nada encontrado",
  "info": "Página _PAGE_ de _PAGES_",
  "infoEmpty": "Nenhum registro disponível",
  "infoFiltered": "(filtrado de _MAX_ registros no total)",
  "search": "Filtrar:",
  "decimal": ",",
  "thousands": ".",
  "paginate": {
    "first":  "Primeira",
    "last":   "Ultima",
    "next":   "Próxima",
    "previous": "Anterior"
    }
   },
  "columns": [
		{
            className: 'dt-control',
            orderable: false,
            data: null,
            defaultContent: ''
        },
        { data: 'Empresa' },
        { data: 'Remetente' },
        { data: 'Destinatario' },
        { data: 'Mensagem' },
        { data: 'Data' },
        { data: 'Hora' }
  ],
  "columnDefs": [
        {
            target: 14,
            visible: false,
            searchable: false
        }
  ],
  "order": [[1,'asc']],
   initComplete: function () {
        this.api()
            .columns()
            .every(function () {
                var column = this;
                var title = column.header().textContent;
 
                // Create input element and add event listener
                //('<input class="form-control form-control-sm" style="width:100%;min-width:70px;" type="text" placeholder="' + 
				$('<input type="text" placeholder="' + title + '" />')
				    .appendTo($(column.header()).empty())
                    .on('keyup change clear', function () {
                        if (column.search() !== this.value) {
                            column.search(this.value).draw();
                        }
                    });
            });
    }

 });

}

// Formatting function for row details - modify as you need
function format(d) {
	var anexos = '';
    // `d` is the original data object for the row
    return (
        '<dl>' +
        '<dt>Anexos:&nbsp;&nbsp;'+d.Anexos+'</dt>' +
        '<dd>' +
        '</dd>' +
        '</dl>'
    );
}
 
 
// Add event listener for opening and closing details
$('#tableAV1 tbody').on('click', 'td.dt-control', function () {
    var tr = $(this).closest('tr');
    var row = tableAV1.row(tr);
 
    if (row.child.isShown()) {
        // This row is already open - close it
        row.child.hide();
    }
    else {
        // Open this row
        row.child(format(row.data())).show();
    }
});


loadTable();


async function envmot(empresa,f1recno,userlib){
let resposta = ''
let F1MsFin  = document.getElementById("F1MsFin").value;

let dataObject = { msfin:F1MsFin, };

fetch('#iprest#/RestMsgUs/v8?empresa='+empresa+'&f1recno='+f1recno+'&userlib='+userlib, {
	method: 'PUT',
	headers: {
	'Content-Type': 'application/json'
	},
	body: JSON.stringify(dataObject)})
	.then(response=>{
		console.log(response);
		return response.json();
	})
	.then(data=> {
		// this is the data we get after putting our data,
		console.log(data);

	  //$('#avalModal').modal('hide');
	  $('#E2Modal').modal('toggle');
	  
	})
}

async function ChgBanco(empresa,z0recno,userlib,banco,btnidp){
let resposta = ''
let dataObject = {	liberacao:'ok' };
let cbtn = '';
	
fetch('#iprest#/RestMsgUs/v4?empresa='+empresa+'&z0recno='+z0recno+'&userlib='+userlib+'&banco='+banco, {
	method: 'PUT',
	headers: {
	'Content-Type': 'application/json'
	},
	body: JSON.stringify(dataObject)})
	.then(response=>{
		console.log(response);
		return response.json();
	})
	.then(data=> {
		// this is the data we get after putting our data,
		console.log(data);
		document.getElementById(btnidp).textContent = banco;
	})
}

async function ChgStatus(empresa,z0recno,userlib,acao,btnids){
let resposta = ''
let dataObject = {	liberacao:'ok' };
let cbtn = '';
	
fetch('#iprest#/RestMsgUs/v3?empresa='+empresa+'&z0recno='+z0recno+'&userlib='+userlib+'&acao='+acao, {
	method: 'PUT',
	headers: {
	'Content-Type': 'application/json'
	},
	body: JSON.stringify(dataObject)})
	.then(response=>{
		console.log(response);
		return response.json();
	})
	.then(data=> {
		// this is the data we get after putting our data,
		console.log(data);
		if (acao == 'C' ){
			cbtn = 'Concluido';
		} else if (acao == 'P'){
			cbtn = 'Pendente';
		} else if (acao == 'O'){
			cbtn = 'Compensar PA';
		} else if (acao == 'D'){
			cbtn = 'Deb Automatico';
		} else if (acao == 'L'){
			cbtn = 'Parcelamento';
		} else if (acao == 'T'){
			cbtn = 'Cartao';
		} else {
			cbtn = 'Em Aberto';
		}
		document.getElementById(btnids).textContent = cbtn;
	})
}


</script>
</body>
</html>
ENDCONTENT

cHtml := STRTRAN(cHtml,"#iprest#"	 ,u_BkRest())
cHtml := STRTRAN(cHtml,"#BKDTStyle#" ,u_BKDTStyle())
cHtml := STRTRAN(cHtml,"#BKDTScript#",u_BKDTScript())
cHtml := STRTRAN(cHtml,"#BKFavIco#"  ,u_BkFavIco())

If !Empty(::userlib)
	cHtml := STRTRAN(cHtml,"#userlib#",::userlib)
	cHtml := STRTRAN(cHtml,"#cUserName#",cUserName)
EndIf

cHtml := STRTRAN(cHtml,"#empresa#",::empresa)

cHtml := StrIConv( cHtml, "CP1252", "UTF-8")

// Desabilitar para testar o html
If __cUserId == '000000'
	Memowrite("\tmp\Avisos.html",cHtml)
EndIf
u_MsgLog("RESTMsgUs",__cUserId+' - '+::userlib)

Self:SetHeader("Access-Control-Allow-Origin", "*")
self:setResponse(cHTML)
self:setStatus(200)

return .T.


// Montagem da Query
Static Function TmpQuery(cQrySZ0,cOpc)

Local aEmpresas		:= {}
Local aGrupoBK 		:= {}
Local cTabSZ0		:= "SZ0010"
Local cQuery		:= ""
Local nE			:= 0

aGrupoBK := u_BKGrupo()
nE := aScan(aGrupoBK,{|x| x[1] == SUBSTR(xEmpresa,1,2) })
If nE > 0
	aEmpresas := {aGrupoBK[nE]}
Else
	aEmpresas := aGrupoBK
EndIf

cQuery := "WITH RESUMO AS ( " + CRLF

cQuery += " SELECT "+CRLF
cQuery += "	  Z0_EMPRESA"+CRLF
cQuery += "	 ,Z0_USERO"+CRLF
cQuery += "  ,USRO.USR_CODIGO AS USRREM" + CRLF
cQuery += "	 ,Z0_USERD"+CRLF
cQuery += "  ,USRD.USR_CODIGO AS USRDEST" + CRLF
cQuery += "	 ,Z0_MSG"+CRLF
cQuery += "	 ,Z0_DTENV"+CRLF
cQuery += "	 ,Z0_HRENV"+CRLF
cQuery += "	 ,SZ0.R_E_C_N_O_ AS Z0RECNO"+CRLF

cQuery += " FROM " + CRLF
cQuery += "  "+cTabSZ0+" SZ0 " + CRLF

cQuery += "  LEFT JOIN SYS_USR USRO ON Z0_USERO = USRO.USR_ID AND USRO.D_E_L_E_T_ = ''" + CRLF
cQuery += "  LEFT JOIN SYS_USR USRD ON Z0_USERD = USRD.USR_ID AND USRD.D_E_L_E_T_ = ''" + CRLF

cQuery += "	 WHERE SZ0.D_E_L_E_T_ = '' "+ CRLF

If cOpc == "R" // Recebidas
	cQuery += "  AND E2_DTFINAL = '' "+CRLF
EndIf

cQuery += " ORDER BY Z0_EMPRESA,Z0_DTENV" + CRLF

u_LogMemo("RESTMsgUs1.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySZ0,.T.,.T.)

Return Nil

