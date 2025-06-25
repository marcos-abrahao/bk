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
		DESCRIPTION "Listar pedidos de venda em aberto";
		WSSYNTAX "/RestLibPV/v0";
		PATH  "/RestLibPV/v0";
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

	WSMETHOD GET PLANPV;
		DESCRIPTION "Retorna planilha excel da tela por meio do método FwFileReader().";
		WSSYNTAX "/RestLibPV/v5";
		PATH "/RestLibPV/v5";
		TTALK "v1"

	WSMETHOD PUT ;
		DESCRIPTION "Liberação de Pedido de Venda" ;
		WSSYNTAX "/RestLibPV/v3";
		PATH "/RestLibPV/v3";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL

// v3
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
	//Seta job para nao consumir licenças
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

	Self:SetHeader("Access-Control-Allow-Origin", "*")
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

// v0
WSMETHOD GET LISTPV QUERYPARAM userlib WSREST RestLibPV

Local aListPV := {}
Local cQrySC5       := ''
Local cJsonCli      := ''
Local lRet 			:= .T.
Local nCount 		:= 0
Local oJsonSales 	:= JsonObject():New()

Local aParams      	As Array
Local cMsg         	As Character
Local xEmpr			As Character

//-------------------------------------------------------------------
// Query para selecionar pedidos
//-------------------------------------------------------------------

If !u_BkAvPar(::userlib,@aParams,@cMsg,@xEmpr)
	oJsonSales['liberacao'] := cMsg
	cRet := oJsonSales:ToJson()
	FreeObj(oJsonSales)
	//Retorno do servico
	Self:SetHeader("Access-Control-Allow-Origin", "*")
	Self:SetResponse(cRet)
	Return lRet:= .t.
EndIf

cQrySC5 := TmpQuery()

//-------------------------------------------------------------------
// Alimenta array de pedidos
//-------------------------------------------------------------------
Do While ( cQrySC5 )->( ! Eof() )
	nCount++
	aAdd( aListPV , JsonObject():New() )
	nPos := Len(aListPV)
	aListPV[nPos]['CPEDIDO']   := "&nbsp"+ALLTRIM((cQrySC5)->C5_NUM)
	aListPV[nPos]['PEDIDO']    := ALLTRIM((cQrySC5)->C5_NUM)
	aListPV[nPos]['EMISSAO']   := "&nbsp"+DTOC(STOD((cQrySC5)->C5_EMISSAO))
	aListPV[nPos]['CLIENTE']   := TRIM((cQrySC5)->A1_NOME)
	aListPV[nPos]['CONTRATO']  := "&nbsp"+ALLTRIM((cQrySC5)->C5_MDCONTR)
	aListPV[nPos]['COMPET']    := "&nbsp"+TRIM((cQrySC5)->C5_XXCOMPM)
	aListPV[nPos]['TOTAL']     := ALLTRIM(STR((cQrySC5)->C6_TOTAL,14,2)) //TRANSFORM((cQrySC5)->C6_TOTAL,"@E 999,999,999.99")
	aListPV[nPos]['LIBEROK']   := TRIM((cQrySC5)->C5_LIBEROK)
	aListPV[nPos]['XXMUN']     := TRIM((cQrySC5)->CNA_XXMUN)
	aListPV[nPos]['MEDICAO']   := TRIM((cQrySC5)->C5_MDNUMED)
	aListPV[nPos]['USUARIO']   := TRIM(IIF(!EMPTY((cQrySC5)->CND_USUAR),(cQrySC5)->CND_USUAR,(cQrySC5)->(FWLeUserlg('C5_USERLGI',1))))
	(cQrySC5)->(DBSkip())
EndDo

( cQrySC5 )->( DBCloseArea() )

oJsonSales := aListPV

//-------------------------------------------------------------------
// Serializa objeto Json
//-------------------------------------------------------------------
cJsonCli:= FwJsonSerialize( oJsonSales )
//cJsonCli := oJsonSales:toJson() 

//-------------------------------------------------------------------
// Elimina objeto da memoria
//-------------------------------------------------------------------
FreeObj(oJsonSales)

Self:SetHeader("Access-Control-Allow-Origin", "*")
Self:SetResponse( cJsonCli ) //-- Seta resposta

Return( lRet )


Static Function TmpQuery()
Local cQrySC5       := GetNextAlias()
Local cWhereSC5     := "%AND SC5.C5_FILIAL = '"+xFilial('SC5')+"'%"
Local cWhereSA1     := "%AND SA1.A1_FILIAL = '"+xFilial('SA1')+"'%"

BeginSQL Alias cQrySC5
    SELECT  SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,
            SC5.C5_EMISSAO,
			SC5.C5_LIBEROK,
			CASE SC5.C5_MDCONTR WHEN '' THEN SC5.C5_ESPECI1 ELSE SC5.C5_MDCONTR END AS C5_MDCONTR,
			SC5.C5_XXCOMPM,
            (SELECT SUM(C6_VALOR) FROM %Table:SC6% SC6 
                WHERE SC6.%NotDel% AND SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM)
                AS C6_TOTAL,
            SA1.A1_NOME,
			CNA.CNA_XXMUN,
			SC5.C5_MDNUMED,
      SC5.C5_USERLGI,
			CND.CND_USUAR
            
    FROM %Table:SC5% SC5
            LEFT JOIN %Table:SA1% SA1 
                ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA
                %exp:cWhereSA1%
                AND SA1.%NotDel%
			LEFT JOIN %Table:CNA% CNA 
                ON SC5.C5_MDCONTR = CNA.CNA_CONTRA AND SC5.C5_MDPLANI = CNA.CNA_NUMERO AND SC5.C5_XXREV = CNA.CNA_REVISA
                AND CNA.CNA_FILIAL = SC5.C5_FILIAL
                AND CNA.%NotDel%
			LEFT JOIN %Table:CND% CND
                ON SC5.C5_MDNUMED = CND.CND_NUMMED
                AND CND.CND_FILIAL = SC5.C5_FILIAL
                AND CND.%NotDel%

    WHERE   SC5.%NotDel%
			AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = ''
            %exp:cWhereSC5%
    ORDER BY C5_LIBEROK,SC5.C5_NUM DESC 
    
EndSQL

Return (cQrySC5)



// v5
WSMETHOD GET PLANPV QUERYPARAM empresa WSREST RestLibPV
	Local cProg 	:= "RestLibPV"
	Local cTitulo	:= "Liberação de Pedidos de Venda WEB"
	Local cDescr 	:= "Exportação Excel de Pedidos de Venda WEB"
	Local cVersao	:= "03/07/2024"
	Local cSolicit  := "26/06/2024 - joao.cordeiro"
	Local oRExcel	AS Object
	Local oPExcel	AS Object
	Local lSuccess  := .T.

    Local cFile  	:= ""
	Local cName  	:= ""
	Local cFName 	:= ""
    Local oFile  	AS Object

	Local cQrySC5	:= ""

	u_MsgLog(cProg,cTitulo)

	// Query para selecionar os Títulos a Pagar
	cQrySC5 := TmpQuery()

	// Definição do Arq Excel
	oRExcel := RExcel():New(cProg)
	oRExcel:SetTitulo(cTitulo)
	oRExcel:SetVersao(cVersao)
	oRExcel:SetSolicit(cSolicit)
	oRExcel:SetDescr(cDescr)

	// Definição da Planilha 1
	oPExcel:= PExcel():New(cProg,cQrySC5)
	oPExcel:SetTitulo("Pedidos de Venda em liberação")

	oPExcel:AddCol("PEDIDO" ,"C5_NUM","Pedido","C5_NUM")
	oPExcel:GetCol("PEDIDO"):SetHAlign("C")

	oPExcel:AddCol("EMISSAO","C5_EMISSAO","Emissão","C5_EMISSAO")

	oPExcel:AddCol("CLIENTE","A1_NOME","Cliente","A1_NOME")

	oPExcel:AddCol("CONTRATO","C5_MDCONTR","Contrato","C5_MDCONTR")
	oPExcel:GetCol("CONTRATO"):SetHAlign("C")

	oPExcel:AddCol("XXMUN","CNA_XXMUN","Planilha","CNA_XXMUN")

	oPExcel:AddCol("COMPET","C5_XXCOMPM","Competência","C5_XXCOMPM")
	oPExcel:GetCol("COMPET"):SetHAlign("C")

	oPExcel:AddCol("TOTAL","C6_TOTAL","Total","")
	oPExcel:GetCol("TOTAL"):SetTotal(.T.)
	oPExcel:GetCol("TOTAL"):SetDecimal(2)
	oPExcel:GetCol("TOTAL"):SetTotal(.T.)

	oPExcel:AddCol("LIBEROK","C5_LIBEROK","Liberação","")

	// Adiciona a planilha
	oRExcel:AddPlan(oPExcel)

	// Cria arquivo Excel
	cFName:= oRExcel:RunCreate()

	// Remove pastas do nome do arquivo
	cName:= SubStr(cFName,Rat("\",cFName)+1)

	(cQrySC5)->(dbCloseArea())

	// Abrir arquino na Web
	//cName  	:= cFName //Decode64(self:documento)
    oFile  	:= FwFileReader():New(cFName) // CAMINHO ABAIXO DO ROOTPATH

    If (oFile:Open())
        cFile := oFile:FullRead() // EFETUA A LEITURA DO ARQUIVO

        // RETORNA O ARQUIVO PARA DOWNLOAD

        //Self:SetHeader("Content-Disposition", '"inline; filename='+cName+'"') não funciona
        Self:SetHeader("Content-Disposition", "attachment; filename="+cName)

        Self:SetResponse(cFile)

		oFile:Close()

		// Apagar o arquivo após o fechamento
		Ferase(cFName)

        lSuccess := .T. // CONTROLE DE SUCESSO DA REQUISIÇÃO

    Else
        SetRestFault(002, "Nao foi possivel carregar o arquivo "+cFName) // GERA MENSAGEM DE ERRO CUSTOMIZADA

        lSuccess := .F. // CONTROLE DE SUCESSO DA REQUISIÇÃO
    EndIf

Return (lSuccess)


// v1
WSMETHOD GET CONSPV QUERYPARAM pedido WSRECEIVE pedido WSREST RestLibPV

Local cHTML as char
Local cPed  as char

cPed  := self:pedido
cHtml := StrIConv(u_BKFATR5H(cPed), "CP1252", "UTF-8")

Self:SetHeader("Access-Control-Allow-Origin", "*")
self:setResponse(cHtml)
self:setStatus(200)

return .T.

//v2
WSMETHOD GET BROWPV QUERYPARAM userlib WSRECEIVE userlib WSREST RestLibPV

local cHTML as char

BEGINCONTENT var cHTML

<!doctype html>
<html lang="pt-BR">
<head>

<!-- Required meta tags -->
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Styling CSS -->
#BKDTStyle#

<title>Liberação de Pedidos de Vendas</title>

<!-- Favicon -->
#BKFavIco#

<style type="text/css">

html *
{
   font-size: 12px;
}

.bk-colors{
 background-color: #9E0000;
 color: white;
}
.bg-mynav {
  background-color: #9E0000;
  padding-left:5px;
  padding-right:5px;
  font-size: 1.2rem;
}
.font-condensed{
  font-size: 0.8em;
}
body {
	background-color: #f6f8fa;
}

table.dataTable td {
  font-size: 1em;
}

td {
line-height: 1rem;
	vertical-align: middle;
	}

table.dataTable.table-sm>thead>tr th.dt-orderable-asc,table.dataTable.table-sm>thead>tr th.dt-orderable-desc,table.dataTable.table-sm>thead>tr th.dt-ordering-asc,table.dataTable.table-sm>thead>tr th.dt-ordering-desc,table.dataTable.table-sm>thead>tr td.dt-orderable-asc,table.dataTable.table-sm>thead>tr td.dt-orderable-desc,table.dataTable.table-sm>thead>tr td.dt-ordering-asc,table.dataTable.table-sm>thead>tr td.dt-ordering-desc {
    padding-right: 3px;
}

table.dataTable thead th {
  position: relative;
}

thead input::placeholder {
    font-weight: bold !important;
    color: #6c757d !important;
    font-style: italic;
    letter-spacing: 0.5px;
    font-size: 0.8rem !important; /* Tamanho reduzido */
    opacity: 1 !important; /* Garante visibilidade total */
}
/* Borda destacada para os inputs do cabeçalho */
thead input {
    width: 100% !important; /* Ocupa toda a largura da célula */
    border: 2px solid #9E0000 !important; /* Cor do seu header (.bk-colors) */
    border-radius: 4px !important; /* Cantos arredondados */
    padding: 4px !important; /* Espaçamento interno */
    box-shadow: 0 0 2px rgba(158, 0, 0, 0.3) !important; /* Sombra sutil (opcional) */
}

/* Efeito hover para os inputs do cabeçalho */
thead input:hover {
    background-color: #FFF2F2 !important; /* Vermelho claro de fundo */
    border-color: #9E0000 !important; /* Borda vermelha mais intensa */
    transition: all 0.3s ease; /* Suaviza a transição */
}

/* Opcional: Efeito ao focar (quando clicado) */
thead input:focus {
    background-color: #FFE5E5 !important;
    box-shadow: 0 0 0 2px rgba(158, 0, 0, 0.2) !important;
}
</style>
</head>
<body>
<nav class="navbar navbar-dark bg-mynav fixed-top justify-content-between">
	<a class="navbar-brand" href="#">BK - Liberação de Pedidos de Vendas - #cUserName#</a>

	<div class="btn-group">
		<button type="button" id="btn-excel" class="btn btn-dark" aria-label="Excel" onclick="Excel()">Excel</button>
	</div>

    <button type="button" 
        class="btn btn-dark" aria-label="Atualizar" onclick="Atualiza();">
        Atualizar
    </button>
</nav>
<br>
<br>
<br>
<div class="container">
<div class="table-responsive-sm">
<table id="tableSC5" class="table table-sm table-hover" style="width:100%">
<thead>
<tr>
<th scope="col">Pedido</th>
<th scope="col">Emissão</th>
<th scope="col">Cliente</th>
<th scope="col">Contrato</th>
<th scope="col">Competência</th>
<th scope="col">Planilha</th>
<th scope="col">Medição</th>
<th scope="col">Emissor</th>
<th scope="col">Total</th>
<th scope="col">Ação</th>
</tr>
</thead>
<tbody id="mytable">
<tr>
<th scope="col"></th>
<th scope="col"></th>
<th scope="col widht=30%></th>
<th scope="col"></th>
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
<!-- Modal -->
<div id="C5Modal" class="modal fade" role="dialog">
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

<!-- JavaScript -->
#BKDTScript#

<script>
async function getPeds() {

let url = '#iprest#/RestLibPV/v0?userlib=#userlib#';

const headers = new Headers();
headers.set('Authorization', 'Basic ' + btoa('#usrrest#' + ':' + '#pswrest#'));
headers.set("Access-Control-Allow-Origin", "*");

try {
     let res = await fetch(url, {
      method: 'GET',
      headers: headers,
      mode: 'cors' // Adiciona o modo CORS explicitamente
     });
      
     if (!res.ok) {
        throw new Error(`HTTP error! status: ${res.status}`);
     }
        
     return await res.json();
} catch (error) {
    console.error('Erro na requisição:', error);
    return {
        error: true,
        message: 'Falha ao carregar dados: ' + error.message
    };
}

}

async function loadTable() {
$('#mytable').html('<tr><td colspan="10" style="text-align: center;"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Carregando...</span></div></td></tr>')
let pedidos = await getPeds();
let trHTML = '';

// Destrói a tabela se já existir (preservando o thead original)
if ($.fn.DataTable.isDataTable('#tableSC5')) {
    $('#tableSC5').DataTable().destroy();
    // Restaura o thead original (com os textos das colunas)
    $('#tableSC5 thead').html(`
	<tr>
	<th scope="col">Pedido</th>
	<th scope="col">Emissão</th>
	<th scope="col">Cliente</th>
	<th scope="col">Contrato</th>
	<th scope="col">Competência</th>
	<th scope="col">Planilha</th>
	<th scope="col">Medição</th>
	<th scope="col">Emissor</th>
	<th scope="col">Total</th>
	<th scope="col">Ação</th>
	</tr>
    `);
}


if (Array.isArray(pedidos)) {
    pedidos.forEach(object => {
    let cLiberOk = object['LIBEROK']
    trHTML += '<tr>';
    trHTML += '<td>'+object['CPEDIDO']+'</td>';
    trHTML += '<td>'+object['EMISSAO']+'</td>';
    trHTML += '<td>'+object['CLIENTE']+'</td>';
    trHTML += '<td>'+object['CONTRATO']+'</td>';
    trHTML += '<td>'+object['COMPET']+'</td>';
    trHTML += '<td>'+object['XXMUN']+'</td>';
    trHTML += '<td>'+object['MEDICAO']+'</td>';
	trHTML += '<td>'+object['USUARIO']+'</td>';
    trHTML += '<td align="right">'+object['TOTAL']+'</td>';
 	if (cLiberOk == 'S') {
  		trHTML += `<td><button type="button" class="btn btn-outline-warning btn-sm" 
             onclick="showPedWithSpinner('${object['PEDIDO']}', 2, this)">Liberado</button></td>`;
	} else {
  		trHTML += `<td><button type="button" class="btn btn-outline-success btn-sm" 
             onclick="showPedWithSpinner('${object['PEDIDO']}', 1, this)">Liberar</button></td>`;
	}
   	trHTML += '</tr>';
    });
} else {
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="10" style="text-align:center;">'+pedidos['liberacao']+'</th>';
    trHTML += '</tr>';   
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="10" style="text-align:center;">Faça login novamente no sistema Protheus</th>';
    trHTML += '</tr>';   
}
document.getElementById("mytable").innerHTML = trHTML;

tableSC5 = $('#tableSC5').DataTable({
	"retrieve": true,
	"pageLength": 100,
	"order": [],
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
    "columns": [
        { data: 'Pedido' },
        { data: 'Emissão' },
        { data: 'Cliente' },
        { data: 'Contrato' },		
        { data: 'Compet' },
        { data: 'Planilha' },
        { data: 'Medição' },
        { data: 'Emissao' },
        { data: 'Emissor' },
        { data: 'Ação' }
    ],
	columnDefs: [
    	{
            targets: [0,1,3,4,5,6],
            className: 'text-center'
        },
		{
            targets: [2],
            width: '30%'
        },
		{
            targets: [8], // Colunas "Valor"
            render: DataTable.render.number('.', ',', 2) // Formato: 1.000,50
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

loadTable();

/*
function showPed(idPed,canLib) {
let url = '#iprest#/RestLibPV/v1?pedido='+idPed;

$("#titulo").text(url);
$("#conteudo").load(url);
if (canLib === 1){
	let btn = '<button type="button" id="btnlp" class="btn btn-outline-success" onclick="libPed(\''+idPed+'\',\'#userlib#\')">Liberar</button>';
	document.getElementById("btnlib").innerHTML = btn;
}

$('#C5Modal').modal('show');
$('#C5Modal').on('hidden.bs.modal', function () {
	location.reload();
	})
}
*/

function showPedWithSpinner(idPed, canLib, buttonElement) {
  const btn = buttonElement;
  const originalText = btn.innerHTML;
  
  // Mostra spinner no botão da tabela
  btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Carregando...';
  btn.disabled = true;
  
  showPed(idPed, canLib);
  
  // Restaura o botão quando o modal abre ou em caso de erro
  $('#C5Modal').one('shown.bs.modal hidden.bs.modal', function() {
    btn.innerHTML = originalText;
    btn.disabled = false;
  });
}


// função showPed com callback
function showPed(idPed, canLib) {
  const auth = 'Basic ' + btoa('web' + ':' + '846250');
  
  $.ajax({
    url: `#iprest#/RestLibPV/v1?pedido=${idPed}`,
    headers: { 'Authorization': auth },
    success: (data) => {
      $("#conteudo").html(data);
      if (canLib === 1) {
        $("#btnlib").html(`<button class="btn btn-success" 
                         onclick="libPed('${idPed}','#userlib#')">
                         Liberar</button>`);
      } else {
        $("#btnlib").empty(); // Remove o botão se canLib não for 1
	  }
      $('#C5Modal').modal('show');
    },
    error: () => {
      $("#conteudo").html('<div class="alert alert-danger">Falha ao carregar o pedido</div>');
      $('#C5Modal').modal('show');
	  $("#btnlib").empty();
    }
  });
}

async function xlibPed(id,userlib){
let dataObject = {liberacao:'ok'};
let resposta = ''
const auth = 'Basic ' + btoa('#usrrest#' + ':' + '#pswrest#');
document.getElementById("btnlp").innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>';

fetch('#iprest#/RestLibPV/v3?pedido='+id+'&userlib='+userlib, {
	method: 'PUT',
	headers: {
	'Content-Type': 'application/json',
	'Authorization': auth
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
	  $('#C5Modal').modal('toggle');
	  })
	})
}


async function libPed(id, userlib) {
  const btn = event.target;
  const originalText = btn.innerHTML;
  
  try {
    // Mostra spinner no botão do modal
    btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Liberando...';
    btn.disabled = true;
    
    const dataObject = { liberacao: 'ok' };
    const credentials = btoa('#usrrest#' + ':' + '#pswrest#');
    
    const response = await fetch(`#iprest#/RestLibPV/v3?pedido=${id}&userlib=${userlib}`, {
      method: 'PUT',
      headers: {
        'Authorization': `Basic ${credentials}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(dataObject)
    });

    if (!response.ok) throw new Error('Erro na requisição');
    
    const data = await response.json();
    
    // Fecha o modal e recarrega a tabela
    $('#C5Modal').modal('hide');
    Atualiza(); // Chama a função que recarrega a tabela
    
    // Mostra mensagem de sucesso
    $("#titConf").text(data.liberacao);
    $('#confModal').modal('show');
    
  } catch (error) {
    console.error("Erro:", error);
    btn.innerHTML = originalText;
    btn.disabled = false;
    alert("Ocorreu um erro durante a liberação");
  }
}


async function Excel(){

    const btnExcel = document.getElementById("btn-excel");
    const cbtnh = btnExcel.innerHTML; // Salva o conteúdo original do botão
	const newempr = '#empresa#';

    try {
        // Desabilita o botão e exibe o spinner
        btnExcel.disabled = true;
        btnExcel.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span> Processando...';

        // Substitua os placeholders pelos valores reais
        const username = '#usrrest#'; // Substitua pelo valor real
        const password = '#pswrest#'; // Substitua pelo valor real
        const iprest = '#iprest#'; // Substitua pelo valor real
        const userlib = '#userlib#'; // Substitua pelo valor real
		const newempr = '#empresa#';

        // Codifica as credenciais em Base64
        const credentials = btoa(`${username}:${password}`);

        // Monta a URL da API
        const url = `${iprest}/RestLibPV/v5?empresa=${newempr}`;

        // Faz a requisição com autenticação básica
        const response = await fetch(url, {
            method: 'GET',
            headers: {
                'Authorization': `Basic ${credentials}`,
                'Content-Type': 'application/json', // Adiciona o tipo de conteúdo, se necessário
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

        // Cria um link para download do arquivo
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = `Pedidos_de_Venda_${newempr}.xlsx`; // Nome do arquivo personalizado
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    } catch (error) {
        console.error("Erro durante a execução da função Excel:", error);
        alert(`Ocorreu um erro ao tentar baixar o arquivo: ${error.message}`);
    } finally {
        // Restaura o botão ao estado original
        btnExcel.disabled = false;
        btnExcel.innerHTML = cbtnh;
    }
}

async function Atualiza() {
    try {
        // Atualizar a tabela com os novos dados
        await loadTable();
        
    } catch (error) {
        console.error("Erro ao atualizar:", error);
        $('#mytable').html('<tr><td colspan="10" style="text-align: center; color: red;">Erro ao carregar dados</td></tr>');
    }
}

</script>
</body>
</html>

ENDCONTENT

cHtml := STRTRAN(cHtml,"#iprest#"	 ,u_BkRest())
cHtml := STRTRAN(cHtml,"#usrrest#"	 ,u_BkUsrRest())
cHtml := STRTRAN(cHtml,"#pswrest#"	 ,u_BkPswRest())
cHtml := STRTRAN(cHtml,"#empresa#"	 ,'01')

cHtml := STRTRAN(cHtml,"#BKDTStyle#" ,u_BKDTStyle())
cHtml := STRTRAN(cHtml,"#BKDTScript#",u_BKDTScript())
cHtml := STRTRAN(cHtml,"#BKFavIco#"  ,u_BkFavIco())


iF !Empty(::userlib)
	cHtml := STRTRAN(cHtml,"#userlib#",::userlib)
	cHtml := STRTRAN(cHtml,"#cUserName#",cUserName)
EndIf

cHtml := StrIConv( cHtml, "CP1252", "UTF-8")
cHtml := u_BKUtf8() + cHtml

Self:SetHeader("Access-Control-Allow-Origin", "*")
self:setResponse(cHTML)
self:setStatus(200)

return .T.



Static Function fLibPed(cNumPed)
	Local lOk := .F.

	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	SC5->(dbSeek(xFilial("SC5")+cNumPed))

	If Empty(SC5->C5_LIBEROK) .And. Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_BLQ)
		// ponto de entrada - gravação da liberação do pedido de venda 
		u_BK440GR(1)

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

		// Executar os pontos de entrada
		u_MTA410T()
		lOk := .T.
	Else
		lOk := .F.
	EndIf

	u_MsgLog("RESTLIBPV","Pedido "+cNumPed+" "+iIf(lOk,"liberado","não liberado"))

Return lOk

