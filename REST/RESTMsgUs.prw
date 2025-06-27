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
		DESCRIPTION "Listar avisos";
		WSSYNTAX "/RestMsgUs/v0";
		PATH  "/RestMsgUs/v0";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET BROWAV1;
		DESCRIPTION "Browse avisos";
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

	WSMETHOD GET EXEC;
		DESCRIPTION "Executar rotina do aviso" ;
		WSSYNTAX "/RestMsgUs/v5";
		PATH "/RestMsgUs/v5";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL



//v4
WSMETHOD PUT STATUS QUERYPARAM z0recno,userlib,acao WSREST RestMsgUs 

Local cJson			:= Self:GetContent()   
Local lRet			:= .T.
Local oJson			As Object
Local aParams		As Array
Local cMsg			As Char

::setContentType('application/json')

oJson := JsonObject():New()
oJson:FromJSON(cJson)

If u_BkAvPar(::userlib,@aParams,@cMsg)

	lRet := fStatus(::z0recno,::acao,@cMsg)

EndIf

oJson['liberacao'] := StrIConv(cMsg, "CP1252", "UTF-8")

cRet := oJson:ToJson()

FreeObj(oJson)
// CORS
Self:SetHeader("Access-Control-Allow-Origin", "*")
Self:SetHeader("X-Frame-Options", "allow-from *")
Self:SetResponse(cRet)
  
Return lRet



//v5
WSMETHOD GET EXEC QUERYPARAM userlib,acao WSREST RestMsgUs 

Local lRet		:= .T.
Local aParams	As Array
Local cMsg		As Char
Local cRotina	As Char
Local cError	:= ""
Local bError	:= ErrorBlock({ |oError| cError := oError:Description})
Local cHtml 	:= "Rotina processada!"

If u_BkAvPar(::userlib,@aParams,@cMsg)
	cRotina := "U_"+::acao+"()"

	BEGIN SEQUENCE
		lRet := &(cRotina)
	RECOVER
		//-> Recupera e apresenta o erro.
		lRet := .F.
	END SEQUENCE

    //Restaurando bloco de erro do sistema
    ErrorBlock(bError)
     
    //Se houve erro, será mostrado ao usuário
    If !Empty(cError)
        u_MsgLog("RESTMsgUs-v5",cError)
		cHtml := cError
    EndIf

EndIf

Self:SetHeader("Access-Control-Allow-Origin", "*")
Self:SetHeader("X-Frame-Options", "allow-from *")
self:setResponse(cHtml)
self:setStatus(200)

Return lRet


Static Function fStatus(z0recno,acao,cMsg)
Local lRet 		:= .F.
Local cQuery	:= ""
Local cTabSZ0	:= "SZ0010"
Local cQrySZ0	:= GetNextAlias()

Default cMsg	:= ""
Default cMotivo := ""

Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

cQuery := "SELECT "
cQuery += "   SZ0.Z0_STATUS"
cQuery += "  ,SZ0.D_E_L_E_T_ AS Z0DELET"
cQuery += " FROM "+cTabSZ0+" SZ0 "
cQuery += " WHERE SZ0.R_E_C_N_O_ = "+z0recno

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySZ0,.T.,.T.)

Do Case
	Case (cQrySZ0)->(Eof()) 
		cMsg:= "não encontrado"
	Case (cQrySZ0)->Z0DELET = '*'
		cMsg:= "foi excluído"
	OtherWise 
		// Alterar o Status
		cMsg 	:= acao
		cQuery := "UPDATE "+cTabSZ0+CRLF
		cQuery += "  SET Z0_STATUS = '"+SUBSTR(acao,1,1)+"',"+CRLF
		cQuery += "      Z0_DTLIDA = '"+DTOS(DATE())+"',"+CRLF
		cQuery += "      Z0_HRLIDA = '"+SUBSTR(TIME(),1,5)+"'"+CRLF
		cQuery += " FROM "+cTabSZ0+" SZ0"+CRLF
		cQuery += " WHERE SZ0.R_E_C_N_O_ = "+z0recno+CRLF

		If TCSQLExec(cQuery) < 0 
			cMsg := "Erro: "+TCSQLERROR()
		Else
			lRet := .T.
		EndIf
EndCase

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
Local xEmpr 		As Character

//u_MsgLog("RESTMsgUs",VarInfo("vencini",self:vencini))

If !u_BkAvPar(::userlib,@aParams,@cMsg,@xEmpr)
  oJsonTmp['liberacao'] := cMsg
  cRet := oJsonTmp:ToJson()
  FreeObj(oJsonTmp)
  //Retorno do servico

  Self:SetHeader("Access-Control-Allow-Origin", "*")
  Self:SetHeader("X-Frame-Options", "allow-from *")
  ::SetResponse(cRet)
  Return lRet:= .T.
EndIf

// Query para selecionar os avisos
TmpQuery(cQrySZ0,xEmpr)

//-------------------------------------------------------------------
// Alimenta array do Datatables
//-------------------------------------------------------------------
Do While ( cQrySZ0 )->( ! Eof() )

	aAdd( aListAV1 , JsonObject():New() )

	nPos	:= Len(aListAV1)

	aListAV1[nPos]['EMPRESA']	:= u_BKNEmpr((cQrySZ0)->Z0_EMPRESA,3)
	aListAV1[nPos]['STATUS']    := (cQrySZ0)->Z0_STATUS
	aListAV1[nPos]['USRREM']    := TRIM((cQrySZ0)->USRREM)	
	aListAV1[nPos]['USRDEST']	:= IIF(!EMPTY((cQrySZ0)->USRDEST),TRIM((cQrySZ0)->USRDEST),TRIM((cQrySZ0)->GR__NOME))
	aListAV1[nPos]['ASSUNTO']	:= StrIConv(TRIM((cQrySZ0)->Z0_ASSUNTO), "CP1252", "UTF-8")
	aListAV1[nPos]['MSG']		:= StrIConv(TRIM((cQrySZ0)->Z0_MSG), "CP1252", "UTF-8")
	aListAV1[nPos]['DTENV'] 	:= (cQrySZ0)->(SUBSTR(Z0_DTENV,1,4)+"-"+SUBSTR(Z0_DTENV,5,2)+"-"+SUBSTR(Z0_DTENV,7,2))+" 12:00:00"  // Se não colocar 12:00 ele mostra a data anterior
	aListAV1[nPos]['HRENV'] 	:= TRIM((cQrySZ0)->Z0_HRENV)

	aListAV1[nPos]['DTLIDA'] 	:= (cQrySZ0)->(DTOC(STOD(Z0_DTLIDA)))
	aListAV1[nPos]['HRLIDA'] 	:= TRIM((cQrySZ0)->Z0_HRLIDA)
	aListAV1[nPos]['ANEXO'] 	:= TRIM((cQrySZ0)->Z0_ANEXO)
	aListAV1[nPos]['ENCODE'] 	:= Encode64(TRIM((cQrySZ0)->Z0_ANEXO))
	aListAV1[nPos]["MIME"]		:= u_MimeFile(TRIM((cQrySZ0)->Z0_ANEXO))


	aListAV1[nPos]['Z0RECNO']	:= STRZERO((cQrySZ0)->Z0RECNO,7)
	aListAV1[nPos]['TIPO']		:= IIF(TRIM((cQrySZ0)->Z0_USERO) == TRIM(__cUserID),"R","D")
	aListAV1[nPos]['ORIGEM']	:= TRIM((cQrySZ0)->Z0_ORIGEM)

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
Self:SetHeader("X-Frame-Options", "allow-from *")
Self:SetResponse( cJsonCli ) //-- Seta resposta

Return( lRet )


// /v2
WSMETHOD GET BROWAV1 QUERYPARAM userlib WSREST RestMsgUs
Local cHTML		As char
Local aParams   As Array
Local cMsg      As Character

u_BkAvPar(::userlib,@aParams,@cMsg)

BEGINCONTENT var cHTML

<!doctype html>
<html lang="pt-BR">
<head>
<!-- Required meta tags -->
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Styling CSS -->

#BKDTStyle#
#BKAwesome#

<title>Avisos BK</title>

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
<header>
<nav class="navbar navbar-dark bg-mynav navbar-static-top justify-content-between id=nav1">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Avisos - #cUserName#</a>
    <form class="d-flex">
	    <button type="button" class="btn btn-dark" aria-label="Atualizar" onclick="window.location.reload();">Atualizar</button>
    </form>
  </div>
</nav>

</header>

<div class="container-fluid">
<div class="table-responsive-sm">
<table id="tableAV1" class="table table-sm" style="width:100%">
<thead>
<tr>
<th scope="col"></th>
<th scope="col">St</th>
<th scope="col">Empresa</th>
<th scope="col">Remetente</th>
<th scope="col">Destinatário</th>
<th scope="col">Assunto</th>
<th scope="col">Data</th>
<th scope="col">Hora</th>
<th scope="col">Origem</th>
</tr>
</thead>
<tbody id="mytable1">
<tr>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
</tr>
</tbody>
</table>
</div>
</div>

<div id="confModal" class="modal" tabindex="-1">
   <div class="modal-dialog">
     <div class="modal-content">
       <div class="modal-header">
         <h5 id="titConf" class="modal-title">Aguarde o resultado da rotina</h5>
         <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Fechar"></button>
       </div>
       <div class="modal-footer">
         <button type="button" class="btn btn-outline-danger" data-bs-dismiss="modal">Fechar</button>
       </div>
     </div>
   </div>
</div>

<!-- JavaScript -->
#BKDTScript#

<script>

async function getAv1() {
    
const url = '#iprest#/RestMsgUs/v0?userlib=#userlib#';
const headers = new Headers();
headers.set('Authorization', 'Basic ' + btoa('#usrrest#' + ':' + '#pswrest#'));
try {
let res = await fetch(url,{	method: 'GET',	headers: headers, mode: 'cors' });
	return await res.json();
	} catch (error) {
console.log(error);
	}
}

async function loadTable() {
let av1 = await getAv1();
$('#mytable').html('<tr><td colspan="9" style="text-align: center;"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Carregando...</span></div></td></tr>')

// Verifique se av1 é um array
if (!Array.isArray(av1)) {
    console.error('Resposta da API não é um array:', av1);
	alert("Resposta da API não é um array");
    return; // Saia da função se não for um array
}

let trHTML = '';
let nlin = 0;
let cbtnid = '';
let anexos = '';
let cStatus = '';
let z0recno = '';
let cTipo = '';
let cbtn = '';
let ctitbt = '';
let canexo = '';
let canexo1 = '';
let crotina = '';
let nbta = 0;
let cbta = '';

if (Array.isArray(av1)) {
	av1.forEach(object => {

	nlin += 1; 
	cbtnid = 'btnenv'+nlin;

	trHTML += '<tr>';
	trHTML += '<td></td>';

	cStatus = object['STATUS']
	cTipo = object['TIPO']
	z0recno = object['Z0RECNO']
	
	/*
	if (cStatus == 'L'){
		trHTML += '<td><button type="button" title="Aviso lido" class="btn btn-outline-primary"><i class="fa fa-envelope-open"></i></button></td>';
	} else if (cStatus == 'F'){
		trHTML += '<td><button type="button" title="Aviso fixo" class="btn btn-outline-primary"><i class="fa fa-thumbtack"></i></button></td>';
	} else {
		trHTML += '<td><div id="'+cbtnid+'"><button type="button" title="'+ctitbt+'" class="btn '+cbtn+'" onclick="lida(\''+z0recno+'\')"><i class="fa fa-envelope"></i></button></div></td>';
	} 
	*/

   if (cTipo == "R") {
      cbtn = 'btn-outline-success';
	  ctitbt = 'Você é o remetente deste aviso';
 	} else {
	  cbtn = 'btn-outline-primary';
	  ctitbt = 'Clique para marcar como lido';
	}

	if (cStatus == 'L'){
		trHTML += '<td><div id="'+cbtnid+'"><button type="button" title="Aviso lido" class="btn '+cbtn+'"><i class="fa fa-envelope-open"></i></button></div></td>';
	} else if (cStatus == 'F'){
		trHTML += '<td><div id="'+cbtnid+'"><button type="button" title="Aviso Fixo" class="btn '+cbtn+'"><i class="fa fa-thumbtack"></i></button></div></td>';
	} else {
		trHTML += '<td><div id="'+cbtnid+'"><button type="button" title="'+ctitbt+'" class="btn '+cbtn+'"><i class="fa fa-envelope"></i></button></div></td>';
	} 

	nbta += 1;
	cbta = 'btnAnx' + nbta;

	//canexo  = '<a href="#iprest#/RestLibPN/v4?empresa='+object['EMPRESA']+'&documento='+object['ENCODE']+'&tpanexo=A" class="link-primary">'+object['ASSUNTO']+'</a>';
	//canexo1 = '<a href="#iprest#/RestLibPN/v4?empresa='+object['EMPRESA']+'&documento='+object['ENCODE']+'&tpanexo=A" class="link-primary">'+object['ASSUNTO']+' ('+object['ANEXO']+')</a>';

	canexo = `<button type="button" class="btn btn-link" style="font-size: 0.9rem;" id="${cbta}" 
					onclick="AnexoBk('${object['EMPRESA']}', '${object['ENCODE']}', '${object['MIME']}', '${cbta}', 'A')">
					<i class="bi bi-paperclip"></i>${object['ASSUNTO']}</button> `;
	canexo1 = canexo;

	trHTML += '<td>'+object['EMPRESA']+'</td>';
	trHTML += '<td>'+object['USRREM']+'</td>';
	trHTML += '<td>'+object['USRDEST']+'</td>';
	if (object['ANEXO'].trim().length === 0) {
		trHTML += '<td>'+object['ASSUNTO']+'</td>';
		canexo1 = '';
	} else {
		trHTML += '<td>'+canexo+'</td>';
	}

	trHTML += '<td>'+object['DTENV']+'</td>';
	trHTML += '<td>'+object['HRENV']+'</td>';
	trHTML += '<td>'+object['ORIGEM']+'</td>';

	trHTML += '<td>'+object['DTLIDA']+'</td>';
	trHTML += '<td>'+object['HRLIDA']+'</td>';

	trHTML += '<td>'+canexo1+'</td>';

	trHTML += '<td>'+object['Z0RECNO']+'</td>';
	trHTML += '<td>'+object['STATUS']+'</td>';
	trHTML += '<td>'+object['TIPO']+'</td>';
	trHTML += '<td>';
	if (cStatus == 'F'){
		trHTML += '<button type="button" class="btn btn-outline-success btn-sm" onclick="rotexec(\''+object['ORIGEM']+'\',1)">Atualizar: '+object['ASSUNTO']+' ('+object['ORIGEM']+')</button>';
	} else {
		trHTML += object['MSG'];
	}
	trHTML += '</td>';

	trHTML += '</tr>';
	});
} else {
    trHTML += '<tr>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th scope="row" style="text-align:center;">'+av1['liberacao']+'</th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += '</tr>';   
    trHTML += '<tr>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th scope="row" style="text-align:center;">Faça login novamente no sistema Protheus</th>';
	trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += ' <th></th>';
    trHTML += '</tr>';   
}
document.getElementById("mytable1").innerHTML = trHTML;


tableAV1 = $('#tableAV1').DataTable({
  "pageLength": 100,
  "oLanguage": {
      "sEmptyTable": "Sem avisos no momento"
  		},
  "language": {
  "lengthMenu": "Registros por página: _MENU_ ",
  "zeroRecords": "Nada encontrado",
  "emptyTable": "Nenhum registro disponível",
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
  "rowId": 11,
  "columns": [
		{
            className: 'dt-control',
            orderable: false,
            data: null,
            defaultContent: ''
        },
        { data: 'St', className: 'dt-st', orderable: false },
        { data: 'Empresa' },
        { data: 'Remetente' },
        { data: 'Destinatario' },
        { data: 'Assunto' },
        { data: 'Data' },
        { data: 'Hora' },
		{ data: 'Origem' },
        { data: 'DataLida' },
        { data: 'HoraLida' },
    	{ data: 'Anexo' },
		{ data: 'Recno' },
		{ data: 'Status' },
		{ data: 'Tipo' },
		{ data: 'Msg' }
  ],
  "columnDefs": [
		{
			targets: 0, width: 30 
		},
		{
			targets: 1, width: 55,
		},	
		{
			targets: 5, width: '50%'
		},
        {
            targets: 6, render: DataTable.render.datetime('DD/MM/YYYY')
        },
        {
            targets: [9,10,11,12,13,14,15], visible: false, searchable: false
        }
  ],
  
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
    // `d` is the original data object for the row

    return (
        //'<dl>' +
        //'<dt>Aviso lido em:&nbsp;&nbsp;'+d.DataLida+'&nbsp;'+d.HoraLida+'</dt>' +
        //'<dd>' +
        //'</dd>' +

        '<dl>' +
        '<dt>' + d.Msg + '</dt>' +
        '<dd>' +
        '</dd>' +
        '</dl>'
    );
}
 
// Add event listener for click in status
$('#tableAV1 tbody').on('click', 'td.dt-st', function () {
   var tr = $(this).closest('tr');
   var row = tableAV1.row(tr);
   var data1 = tableAV1.row(tr).data();
   var cStatus = data1.Status
   var cTipo = data1.Tipo

	if (cStatus == 'N' && cTipo == 'D') {
   		data1.St = '<td><div><button type="button" title="Aviso lido" class="btn btn-outline-primary"><i class="fa fa-envelope-open"></i></button></div></td>';
   		lida(data1.Recno)
   		tableAV1.row(tr).data(data1).draw()
	}
});

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

async function lida(z0recno){
let dataObject = { acao:'L', };

const headers = new Headers();
headers.set('Authorization', 'Basic ' + btoa('#usrrest#' + ':' + '#pswrest#'));
headers.set('Content-Type', 'application/json'); // Define o tipo de conteúdo como JSON

fetch('#iprest#/RestMsgUs/v4?z0recno='+z0recno+'&userlib=#userlib#&acao=L', {
method: 'PUT',
headers: headers,
body: JSON.stringify(dataObject)})
.then(response=>{
	console.log(response);
	return response.json();
})
.then(data=> {
	// this is the data we get after putting our data,
	console.log(data);
})
}

async function rotexec(corigem,canLib) {

const url = '#iprest#/RestMsgUs/v5?userlib=#userlib#&acao='+corigem;
let html = '';

const headers = new Headers();
headers.set('Authorization', 'Basic ' + btoa('#usrrest#' + ':' + '#pswrest#'));
	try {
	let res = await fetch(url, { method: 'GET', headers: headers });
		//document.getElementById('conteudo-principal').innerHTML =  await res.text();
		html = await res.text();
        
		//const novaAba = window.open("", "_self");

        // Escreve o conteúdo HTML na nova aba
        //novaAba.document.open();
        //novaAba.document.write(html);
        //novaAba.document.close();
		} catch (error) {
	console.log(error);
	}
	$("#titConf").load(html);
	$('#confModal').modal('show');
	$('#confModal').on('hidden.bs.modal', function () {
	location.reload();
	})
}

#AnexoHtml#

</script>
</body>
</html>
ENDCONTENT

cHtml := STRTRAN(cHtml,"#AnexoHtml#" ,u_AnexoHtml(.F.))
cHtml := STRTRAN(cHtml,"#iprest#"	 ,u_BkRest())
cHtml := STRTRAN(cHtml,"#usrrest#"	 ,u_BkUsrRest())
cHtml := STRTRAN(cHtml,"#pswrest#"	 ,u_BkPswRest())

cHtml := STRTRAN(cHtml,"#BKDTStyle#" ,u_BKDTStyle())
cHtml := STRTRAN(cHtml,"#BKAwesome#" ,u_BKAwesome())
cHtml := STRTRAN(cHtml,"#BKDTScript#",u_BKDTScript())
cHtml := STRTRAN(cHtml,"#BKFavIco#"  ,u_BkFavIco())

If !Empty(::userlib)
	cHtml := STRTRAN(cHtml,"#userlib#",::userlib)
	cHtml := STRTRAN(cHtml,"#cUserName#",cUserName)
EndIf

cHtml := STRTRAN(cHtml,"#empresa#",::empresa)

cHtml := StrIConv( cHtml, "CP1252", "UTF-8")

// Caracteres iniciais de um arquivo UTF-8
//cHtml := u_BKUtf8() + cHtml

// Desabilitar para testar o html
/*
If __cUserId == '000000'
	Memowrite(u_STmpDir()+"RESTMSGUS.html",cHtml)
EndIf
*/
u_MsgLog("RESTMsgUs",__cUserId+' - '+::userlib)

Self:SetHeader("Access-Control-Allow-Origin", "*")
Self:SetHeader("X-Frame-Options", "allow-from *")

Self:SetHeader("Accept", "UTF-8")

self:setResponse(cHTML)
self:setStatus(200)

return .T.


// Montagem da Query
Static Function TmpQuery(cQrySZ0,xEmpr)
Local cTabSZ0		:= "SZ0010"
Local cQuery		:= ""
Local cGrupos		:= u_cUserGrps(__cUserID)

//cQuery := "WITH RESUMO AS ( " + CRLF

cQuery += " SELECT "+CRLF
cQuery += "	  Z0_EMPRESA"+CRLF
cQuery += "	 ,Z0_USERO"+CRLF
cQuery += "  ,USRO.USR_CODIGO AS USRREM" + CRLF
cQuery += "	 ,Z0_USERD"+CRLF
cQuery += "  ,USRD.USR_CODIGO AS USRDEST" + CRLF
cQuery += "  ,GRP.GR__NOME" + CRLF
cQuery += "	 ,Z0_ASSUNTO"+CRLF
cQuery += "	 ,Z0_MSG"+CRLF
cQuery += "	 ,Z0_STATUS"+CRLF
cQuery += "	 ,Z0_ANEXO"+CRLF
cQuery += "	 ,Z0_ORIGEM"+CRLF
cQuery += "	 ,Z0_DTENV"+CRLF
cQuery += "	 ,Z0_HRENV"+CRLF
cQuery += "	 ,Z0_DTLIDA"+CRLF
cQuery += "	 ,Z0_HRLIDA"+CRLF
cQuery += "	 ,Z0_DTFINAL"+CRLF
cQuery += "	 ,SZ0.R_E_C_N_O_ AS Z0RECNO"+CRLF

cQuery += " FROM " + CRLF
cQuery += "  "+cTabSZ0+" SZ0 " + CRLF

cQuery += "  LEFT JOIN SYS_USR USRO ON Z0_USERO = USRO.USR_ID AND USRO.D_E_L_E_T_ = ''" + CRLF
cQuery += "  LEFT JOIN SYS_USR USRD ON Z0_USERD = USRD.USR_ID AND USRD.D_E_L_E_T_ = ''" + CRLF
cQuery += "  LEFT JOIN SYS_GRP_GROUP GRP ON GR__ID = Z0_GRUPOD" + CRLF

cQuery += "	 WHERE SZ0.D_E_L_E_T_ = '' "+ CRLF
If u_IsBarcas(xEmpr)
	cQuery += "	 AND (Z0_EMPRESA = '"+xEmpr+"') "+ CRLF
EndIf

cQuery += "	 AND (Z0_DTFINAL >= '"+DTOS(DATE())+"' OR Z0_STATUS = 'F') "+CRLF
// Se o usuario for o destinatario ou o rementente ou se o destinatario for branco -> todos
cQuery += "  AND (Z0_USERD = '"+__cUserId+"' OR Z0_USERO = '"+__cUserId+"' OR Z0_USERD = 'TODOS'"
If !Empty(cGrupos)
	cQuery += "  OR Z0_GRUPOD IN "+cGrupos+")" +CRLF
Else
	cQuery += ")"
EndIf
cQuery += " ORDER BY Z0_DTENV DESC,Z0_HRENV DESC" + CRLF

//u_LogMemo("RESTMsgUs1.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySZ0,.T.,.T.)

Return Nil


// Inclui/Altera/Exclui Mensagem para usuário ou grupo (Tabela SZ0)
User Function BKMsgUs(cEmpresa,cOrigem,aUsDest,cGrpDest,cAssunto,cMsg,cStatus,cAnexo,dFinal)
Local lRet 	:= .T.
Local lInc  := .T.
Local nI 	:= 0
Local cArqDest	:= ""
Local cExt		:= ""

Default cStatus	:= "N"  // Não Lida
Default cAnexo	:= ""
Default dFinal  := DATE()+5

IF ValType(cAnexo) <> "C"
	Return lRet
ENDIF

// Remover diretorio
SplitPath(cAnexo,,,@cArqDest,@cExt)
cAnexo := Alltrim(cArqDest+cExt)

// Copia o arquivo da pasta tmp para a pasta anexos (http)
__CopyFile(u_STmpDir() + cAnexo, u_STmpAnexos() + cAnexo)

dbSelectArea("SZ0")
dbSetOrder(4)

// Quando somente o grupo for informado
If Len(aUsDest) == 0 .AND. !Empty(cGrpDest)
	aAdd(aUsDest,SPACE(LEN(SZ0->Z0_USERD)))
EndIf

For nI := 1 To Len(aUsDest)
	If cStatus == "F"  // Fixa
		// Verificar se a origem já está cadastrada, se tiver, alterar
		If dbseek(PAD(cOrigem,LEN(SZ0->Z0_ORIGEM))+aUsDest[nI]+cGrpDest,.F.)
			lInc := .F.
		EndIf
	EndIf

	RecLock("SZ0",lInc)
	SZ0->Z0_EMPRESA := cEmpresa
	SZ0->Z0_ORIGEM	:= cOrigem
	SZ0->Z0_USERO	:= IIF(!EMPTY(__cUserID),__cUserID,"000000")
	SZ0->Z0_USERD	:= aUsDest[nI]
	SZ0->Z0_GRUPOD	:= cGrpDest
	SZ0->Z0_ASSUNTO	:= cAssunto
	SZ0->Z0_MSG		:= cMsg
	SZ0->Z0_DTENV 	:= DATE()
	SZ0->Z0_HRENV	:= SUBSTR(TIME(),1,5)
	SZ0->Z0_ANEXO 	:= cAnexo
	SZ0->Z0_STATUS	:= cStatus
	SZ0->Z0_DTFINAL	:= dFinal
	SZ0->(MsUnLock())
Next

Return lRet

// Grava anexo dos avisos
User Function GrvAnexo(cArq,cTexto,lConv,cDir)
Local cRet  := ""

Default lConv := .T.
Default cDir  := u_STmpDir()

// Converto para UTF-8
If lConv
	cTexto := StrIConv(cTexto, "CP1252", "UTF-8")
EndIf

IF ValType(cArq) == "C"
	If !("\" $ cArq)
		MakeDir(cDir)
		cRet := cDir+cArq
		MemoWrite(cRet,cTexto)
	Else
		cRet := cArq
		MemoWrite(cRet,cTexto)
	EndIf
ENDIF
Return cRet
