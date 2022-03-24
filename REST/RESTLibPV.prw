#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#Include "Protheus.ch"
#Include "TBICONN.CH"

/*/{Protheus.doc} RestLibPV
    REST para liberação de pedidos de venda
    @type  Function
    @author Marcos B. Abrahão
    @since 15/08/2021
    @version 12.1.25
/*/

WSRESTFUL RestLibPV DESCRIPTION "Rest Liberação de Pedido de Venda"

	WSDATA mensagem     AS STRING
	WSDATA empresa      AS STRING
	WSDATA filial       AS STRING
	WSDATA pedido 		AS STRING
	WSDATA userlib 		AS STRING

	WSDATA page         AS INTEGER OPTIONAL
	WSDATA pageSize     AS INTEGER OPTIONAL

	WSMETHOD GET LISTPV;
		DESCRIPTION "Listar pedido de venda em aberto";
		WSSYNTAX "/RestLibPV";
		PATH  "/RestLibPV";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET CONSPV;
		DESCRIPTION "Retorna Consulta Pedido como página HTML";
		WSSYNTAX "/RestLibPV/v1";
		PATH "/RestLibPV/v1";
		TTALK "v1";
		PRODUCES TEXT_HTML

	WSMETHOD GET BROWPV;
		DESCRIPTION "Browse Pedidos de Venda a Liberar como página HTML";
		WSSYNTAX "/RestLibPV/v2";
		PATH "/RestLibPV/v2";
		TTALK "v1";
		PRODUCES TEXT_HTML


	WSMETHOD PUT ;
		DESCRIPTION "Liberação de Pedido de Venda" ;
		WSSYNTAX "/RestLibPV/v3";
		PATH "/RestLibPV/v3";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL


WSMETHOD PUT QUERYPARAM empresa,filial,pedido,userlib,liberacao WSREST RestLibPV

Local cJson        := Self:GetContent()   
Local lRet         := .T.
//	Local lLib         := .T.
//	Local oJson        As Object
//  Local cCatch       As Character  
Local oJson        As Object
Local cPedido      As Char
Local aParams      As Array
Local cMsg         As Char

/*
	//Seta job para nao consumir licensas
	RpcSetType(3)
	RpcClearEnv()
	// Seta job para empresa filial desejada
	RpcSetEnv( cEmpX,cFilX,,,,,)

	//PutGlbValue(cVarStatus,stThrConnect) VARIAVEL PÚBLICA publica

	//Set o usuário para buscar as perguntas do profile
	lMsErroAuto := .F.
	lMsHelpAuto := .T. 
	lAutoErrNoFile := .T.

	__cUserId := cXUserId 
	cUserName := cXUserName
	cAcesso   := cXAcesso
	cUsuario  := cXUsuario
*/

	//Define o tipo de retorno do servico
	::setContentType('application/json')

	//oJson  := JsonObject():New()
	//cCatch := oJson:FromJSON(cJson)

	oJson := JsonObject():New()
  	oJson:FromJSON(cJson)

	//If cCatch == Nil
	//PrePareContexto(::empresa,::filial)
	cPedido   := ::pedido

	If u_BkAvPar(::userlib,@aParams,@cMsg)

		lRet := fLibPed(cPedido)

		oJson['liberacao'] := "Pedido "+cPedido+iIf(lRet," liberado"," não foi liberado")
	Else
		oJson['liberacao'] := EncodeUTF8(cMsg)
	EndIf

	cRet := oJson:ToJson()

  	FreeObj(oJson)

 	Self:SetResponse(cRet)
  //Else 
  //  SetRestFault(404, EncodeUTF8(cMsg), .T.)
	//EndIf

	//If !lRet
	//    SetRestFault(Val(oMessages["code"]),oMessages["detailMessage"])
	//EndIf
Return lRet



/*/{Protheus.doc} GET / salesorder
Retorna a lista de pedidos.
 
@param 
 Page , numerico, numero da pagina 
 PageSize , numerico, quantidade de registros por pagina
 
@return cResponse , caracter, JSON contendo a lista de pedidos
/*/


WSMETHOD GET LISTPV QUERYPARAM userlib, page, pageSize WSREST RestLibPV

Local aListSales := {}
Local cQrySC5       := GetNextAlias()
Local cJsonCli      := ''
Local cWhereSC5     := "%AND SC5.C5_FILIAL = '"+xFilial('SC5')+"'%"
Local cWhereSA1     := "%AND SA1.A1_FILIAL = '"+xFilial('SA1')+"'%"
Local lRet 			:= .T.
Local nCount 		:= 0
Local nStart 		:= 1
Local nReg 			:= 0
//Local nTamPag 	:= 0
Local oJsonSales 	:= JsonObject():New()

Local aParams      	As Array
Local cMsg         	As String

Default self:page 	:= 1
Default self:pageSize := 500

//nStart := INT(self:pageSize * (self:page - 1))
//nTamPag := self:pageSize := 100

//-------------------------------------------------------------------
// Query para selecionar pedidos
//-------------------------------------------------------------------

  If !u_BkAvPar(::userlib,@aParams,@cMsg)
    oJsonSales['liberacao'] := cMsg

    cRet := oJsonSales:ToJson()

    FreeObj(oJsonSales)

    //Retorno do servico
    ::SetResponse(cRet)

    Return lRet:= .t.
  EndIf

	BeginSQL Alias cQrySC5
    SELECT  SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,
            SC5.C5_EMISSAO,SC5.C5_LIBEROK,C5_MDCONTR,C5_XXCOMPM,
            (SELECT SUM(C6_VALOR) FROM %Table:SC6% SC6 
                WHERE SC6.%NotDel% AND SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM)
                AS C6_TOTAL,
            SA1.A1_NOME
            
    FROM %Table:SC5% SC5
            INNER JOIN %Table:SA1% SA1 
                ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA
                %exp:cWhereSA1%
                AND SA1.%NotDel%

    WHERE   SC5.%NotDel%
            AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = ''
            %exp:cWhereSC5%
    ORDER BY SC5.C5_NUM 
    
	EndSQL

//Syntax abaixo somente para o SQL 2012 em diante
//ORDER BY SC5.C5_NUM OFFSET %exp:nStart% ROWS FETCH NEXT %exp:nTamPag% ROWS ONLY


//conout(cQrySC5)

	If ( cQrySC5 )->( ! Eof() )

		//-------------------------------------------------------------------
		// Identifica a quantidade de registro no alias temporário
		//-------------------------------------------------------------------
		COUNT TO nRecord

		//-------------------------------------------------------------------
		// nStart -> primeiro registro da pagina
		// nReg -> numero de registros do inicio da pagina ao fim do arquivo
		//-------------------------------------------------------------------
		If self:page > 1
			nStart := ( ( self:page - 1 ) * self:pageSize ) + 1
			nReg := nRecord - nStart + 1
		Else
			nReg := nRecord
		EndIf

		//-------------------------------------------------------------------
		// Posiciona no primeiro registro.
		//-------------------------------------------------------------------
		( cQrySC5 )->( DBGoTop() )

		//-------------------------------------------------------------------
		// Valida a exitencia de mais paginas
		//-------------------------------------------------------------------
		If nReg > self:pageSize
			//oJsonSales['hasNext'] := .T.
		Else
			//oJsonSales['hasNext'] := .F.
		EndIf
	Else
		//-------------------------------------------------------------------
		// Nao encontrou registros
		//-------------------------------------------------------------------
		//oJsonSales['hasNext'] := .F.
	EndIf

//-------------------------------------------------------------------
// Alimenta array de pedidos
//-------------------------------------------------------------------
	Do While ( cQrySC5 )->( ! Eof() )

		nCount++

		If nCount >= nStart

			aAdd( aListSales , JsonObject():New() )
			nPos := Len(aListSales)
			aListSales[nPos]['NUM']       := (cQrySC5)->C5_NUM
			aListSales[nPos]['EMISSAO']   := DTOC(STOD((cQrySC5)->C5_EMISSAO))
			aListSales[nPos]['CLIENTE']   := TRIM((cQrySC5)->A1_NOME)
			aListSales[nPos]['CONTRATO']  := TRIM((cQrySC5)->C5_MDCONTR)
			aListSales[nPos]['COMPET']    := TRIM((cQrySC5)->C5_XXCOMPM)
			aListSales[nPos]['TOTAL']     := TRANSFORM((cQrySC5)->C6_TOTAL,"@E 999,999,999.99")
			aListSales[nPos]['LIBEROK']   := TRIM((cQrySC5)->C5_LIBEROK)
			(cQrySC5)->(DBSkip())

			If Len(aListSales) >= self:pageSize
				Exit
			EndIf
		Else
			(cQrySC5)->(DBSkip())
		EndIf

	EndDo

	( cQrySC5 )->( DBCloseArea() )

	oJsonSales := aListSales

//-------------------------------------------------------------------
// Serializa objeto Json
//-------------------------------------------------------------------
	cJsonCli:= FwJsonSerialize( oJsonSales )
//cJsonCli := oJsonSales:toJson() 
//-------------------------------------------------------------------
// Elimina objeto da memoria
//-------------------------------------------------------------------
	FreeObj(oJsonSales)

	Self:SetResponse( cJsonCli ) //-- Seta resposta

Return( lRet )


WSMETHOD GET CONSPV QUERYPARAM pedido WSRECEIVE pedido WSREST RestLibPV

Local cHTML as char
Local cPed  as char

cPed  := self:pedido
cHtml := StrIConv(u_BKFATR5H(cPed), "CP1252", "UTF-8")

self:setResponse(cHTML)
self:setStatus(200)

return .T.


WSMETHOD GET BROWPV QUERYPARAM userlib WSRECEIVE userlib WSREST RestLibPV

local cHTML as char

begincontent var cHTML

<!doctype html>
<html lang="pt-BR">
<head>

<!-- Required meta tags -->
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Bootstrap CSS -->
<link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.0.2/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/1.11.1/css/dataTables.bootstrap5.min.css" rel="stylesheet">

<title>Liberação de Pedidos</title>
<!-- <link href="index.css" rel="stylesheet"> -->
<style type="text/css">
.bg-mynav {
  background-color: #9E0000;
  padding-left:30px;
  padding-right:30px;
}

body {
font-size: 1rem;
	background-color: #f6f8fa;
	}
td {
line-height: 1rem;
	vertical-align: middle;
	}
</style>
</head>
<body>
<nav class="navbar navbar-dark bg-mynav fixed-top justify-content-between">
	<a class="navbar-brand" href="#">BK - Liberação de Pedidos de Vendas</a>
    <button type="button" 
        class="btn btn-dark" aria-label="Atualizar" onclick="window.location.reload();">
        Atualizar
    </button>
</nav>
<br>
<br>
<br>
<div class="container">
<div class="table-responsive-sm">
<table id="tableSC5" class="table">
<thead>
<tr>
<th scope="col">Pedido</th>
<th scope="col">Emissão</th>
<th scope="col">Cliente</th>
<th scope="col">Contrato</th>
<th scope="col" style="text-align:center;">Competência</th>
<th scope="col" style="text-align:center;">Total</th>
<th scope="col" style="text-align:center;">Ação</th>
</tr>
</thead>
<tbody id="mytable">
<tr>
<th scope="col">Carregando Pedidos...</th>
<th scope="col"></th>
<th scope="col"></th>
<th scope="col"></th>
<th scope="col" style="text-align:center;"></th>
<th scope="col" style="text-align:center;"></th>
<th scope="col" style="text-align:center;"></th>
</tr>
</tbody>
</table>
</div>
</div>
<!-- Modal -->
<div id="meuModal" class="modal fade" role="dialog">
   <div class="modal-dialog modal-xl">
     <!-- Conteúdo do modal-->
     <div class="modal-content">
       <!-- Corpo do modal -->
       <div class="modal-body">
         <div id="conteudo" align="center">Aguarde, carregando o pedido...</div>
       </div>
        <!-- Rodapé do modal-->
       <div class="modal-footer">
         <button type="button" class="btn btn-outline-danger" data-bs-dismiss="modal">Fechar</button>
         <div id="btnlib"></div>
       </div>
     </div>
   </div>
</div>
 <div id="confModal" class="modal" tabindex="-1">
   <div class="modal-dialog">
     <div class="modal-content">
       <div class="modal-header">
         <h5 id="titConf" class="modal-title">Modal title</h5>
         <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Fechar"></button>
       </div>
       <div class="modal-footer">
         <button type="button" class="btn btn-outline-danger" data-bs-dismiss="modal">Fechar</button>
       </div>
     </div>
   </div>
</div>

<!-- Optional JavaScript -->
<!-- jQuery first, then Popper.js, then Bootstrap JS -->
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.datatables.net/1.11.1/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.11.1/js/dataTables.bootstrap5.min.js"></script>


<script>
async function getPeds() {
	let url = 'http://10.139.0.30:8080/rest/RestLibPV/?userlib='+'#userlib#';
		try {
		let res = await fetch(url);
			return await res.json();
			} catch (error) {
		console.log(error);
			}
		}


async function loadTable() {
let pedidos = await getPeds();
let trHTML = '';
if (Array.isArray(pedidos)) {
    pedidos.forEach(object => {
    let cPedido = object['NUM']
    let cLiberOk = object['LIBEROK']
    trHTML += '<tr>';
    trHTML += '<td>'+cPedido+'</td>';
    trHTML += '<td>'+object['EMISSAO']+'</td>';
    trHTML += '<td>'+object['CLIENTE']+'</td>';
    trHTML += '<td>'+object['CONTRATO']+'</td>';
    trHTML += '<td align="center">'+object['COMPET']+'</td>';
    trHTML += '<td align="right">'+object['TOTAL']+'</td>';
    if (cLiberOk == 'S'){
      	trHTML += '<td align="right"><button type="button" class="btn btn-outline-warning btn-sm" onclick="showPed(\''+object['NUM']+'\',2)">Liberado</button></td>';
   	} else {
      	trHTML += '<td align="right"><button type="button" class="btn btn-outline-success btn-sm" onclick="showPed(\''+object['NUM']+'\',1)">Liberar</button></td>';
    }
   	trHTML += '</tr>';
    });
} else {
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="7" style="text-align:center;">'+pedidos['liberacao']+'</th>';
    trHTML += '</tr>';   
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="7" style="text-align:center;">Faça login novamente no sistema Protheus</th>';
    trHTML += '</tr>';   
}
document.getElementById("mytable").innerHTML = trHTML;

$('#tableSC5').DataTable({
 "pageLength": 100,
 "order": [[ 0, "desc" ]],
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
  }
});

}

loadTable();


function showPed(idPed,canLib) {
let url = 'http://10.139.0.30:8080/rest/RestLibPV/v1?pedido='+idPed;

$("#titulo").text(url);
$("#conteudo").load(url);
if (canLib === 1){
	let btn = '<button type="button" class="btn btn-outline-success" onclick="libPed(\''+idPed+'\',\'#userlib#\')">Liberar</button>';
	document.getElementById("btnlib").innerHTML = btn;
}

$('#meuModal').modal('show');
$('#meuModal').on('hidden.bs.modal', function () {
	location.reload();
	})
//loadTable();
}


async function libPed(id,userlib){
let dataObject = {liberacao:'ok'};
let resposta = ''

fetch('http://10.139.0.30:8080/rest/RestLibPV/v3?pedido='+id+'&userlib='+userlib, {
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

		//document.getElementById("msgLiberacao").innerHTML = data.liberacao;
	  $("#titConf").text(data.liberacao);
	  $('#confModal').modal('show');
	  $('#confModal').on('hidden.bs.modal', function () {
	  $('#meuModal').modal('toggle');
	  })

	})

}

</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>

</body>
</html>

endcontent

If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer())
	cHtml := STRTRAN(cHtml,"10.139.0.30:8080","10.139.0.30:8081")
EndIf

iF !Empty(::userlib)
	cHtml := STRTRAN(cHtml,"#userlib#",::userlib)
EndIf

cHtml := StrIConv( cHtml, "CP1252", "UTF-8")

//Memowrite("\tmp\PV.html",cHtml)

self:setResponse(cHTML)
self:setStatus(200)

return .T.



Static Function fLibPed(cNumPed)
	Local lOk := .F.

	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	SC5->(dbSeek(xFilial("SC5")+cNumPed))

	If Empty(SC5->C5_LIBEROK) .And. Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_BLQ)
		dbSelectArea("SC6")
		SC6->(dbSetOrder(1))
		SC6->(dbSeek(xFilial("SC6")+cNumPed))

		While SC6->(!EOF()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == cNumPed

			MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,.T.,.T.,.F.,.F.,,,,{||SC9->C9_XXRM := SC5->C5_XXRM,SC9->C9_XXORPED := SC5->C5_XXTPNF})

			Begin Transaction
				SC6->(MaLiberOk({cNumPed},.F.))
			End Transaction

			SC6->(dbSkip())
		EndDo

		u_MTA410T()

		lOk := .T.
	Else
		lOk := .F.
	EndIf

	u_LogPrw("RESTLIBPV","Pedido "+cNumPed+" "+iIf(lOk,"liberado","não liberado"))

Return lOk



Static Function PrePareContexto(cCodEmpresa , cCodFilial)

	RESET ENVIRONMENT
	RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA cCodEmpresa FILIAL cCodFilial TABLES "SC5" MODULO "FAT"

Return .T.

