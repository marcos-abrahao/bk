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


WSMETHOD GET LISTPV QUERYPARAM userlib, page, pageSize WSREST RestLibPV

Local aListSales := {}
Local cQrySC5       := ''
Local cJsonCli      := ''
Local lRet 			:= .T.
Local nCount 		:= 0
Local oJsonSales 	:= JsonObject():New()

Local aParams      	As Array
Local cMsg         	As Character

//Default self:page 	:= 1
//Default self:pageSize := 500

//-------------------------------------------------------------------
// Query para selecionar pedidos
//-------------------------------------------------------------------

If !u_BkAvPar(::userlib,@aParams,@cMsg)
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

	aAdd( aListSales , JsonObject():New() )
	nPos := Len(aListSales)
	aListSales[nPos]['NUM']       := "&nbsp"+ALLTRIM((cQrySC5)->C5_NUM)
	aListSales[nPos]['EMISSAO']   := "&nbsp"+DTOC(STOD((cQrySC5)->C5_EMISSAO))
	aListSales[nPos]['CLIENTE']   := TRIM((cQrySC5)->A1_NOME)
	aListSales[nPos]['CONTRATO']  := "&nbsp"+ALLTRIM((cQrySC5)->C5_MDCONTR)
	aListSales[nPos]['COMPET']    := "&nbsp"+TRIM((cQrySC5)->C5_XXCOMPM)
	aListSales[nPos]['TOTAL']     := TRANSFORM((cQrySC5)->C6_TOTAL,"@E 999,999,999.99")
	aListSales[nPos]['LIBEROK']   := TRIM((cQrySC5)->C5_LIBEROK)
	(cQrySC5)->(DBSkip())

	If Len(aListSales) >= self:pageSize
		Exit
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

Self:SetHeader("Access-Control-Allow-Origin", "*")
Self:SetResponse( cJsonCli ) //-- Seta resposta

Return( lRet )


Static Function TmpQuery()
Local cQrySC5       := GetNextAlias()
Local cWhereSC5     := "%AND SC5.C5_FILIAL = '"+xFilial('SC5')+"'%"
Local cWhereSA1     := "%AND SA1.A1_FILIAL = '"+xFilial('SA1')+"'%"

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
    ORDER BY C5_LIBEROK,SC5.C5_NUM DESC 
    
EndSQL

//Syntax abaixo somente para o SQL 2012 em diante
//ORDER BY SC5.C5_NUM OFFSET %exp:nStart% ROWS FETCH NEXT %exp:nTamPag% ROWS ONLY

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



WSMETHOD GET CONSPV QUERYPARAM pedido WSRECEIVE pedido WSREST RestLibPV   // V1

Local cHTML as char
Local cPed  as char

cPed  := self:pedido
cHtml := StrIConv(u_BKFATR5H(cPed), "CP1252", "UTF-8")

Self:SetHeader("Access-Control-Allow-Origin", "*")
self:setResponse(cHTML)
self:setStatus(200)

return .T.


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

<title>Liberação de Pedidos</title>

<!-- Favicon -->
#BKFavIco#

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
thead input {
	width: 100%;
	font-weight: bold;
	background-color: #F3F3F3
}
</style>
</head>
<body>
<nav class="navbar navbar-dark bg-mynav fixed-top justify-content-between">
	<a class="navbar-brand" href="#">BK - Liberação de Pedidos de Vendas - #cUserName#</a>

	<div class="btn-group">
		<button type="button" class="btn btn-dark" aria-label="Excel" onclick="Excel()">Excel</button>
	</div>

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
<table id="tableSC5" class="table table-sm table-hover" style="width:100%">
<thead>
<tr>
<th scope="col">Pedido</th>
<th scope="col">Emissão</th>
<th scope="col">Cliente</th>
<th scope="col">Contrato</th>
<th scope="col">Competência</th>
<th scope="col">Total</th>
<th scope="col">Ação</th>
</tr>
</thead>
<tbody id="mytable">
<tr>
<th scope="col">Carregando Pedidos...</th>
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

<!-- JavaScript -->
#BKDTScript#

<script>
async function getPeds() {
	let url = '#iprest#/RestLibPV/?userlib='+'#userlib#';
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

tableSC5 = $('#tableSC5').DataTable({
 "pageLength": 100,
 "order": [],
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
   },

	columnDefs: [
    	{
            targets: [0,1,3],
            className: 'dt-left dt-head-left'
        }
    ],   

  },
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


function showPed(idPed,canLib) {
let url = '#iprest#/RestLibPV/v1?pedido='+idPed;

$("#titulo").text(url);
$("#conteudo").load(url);
if (canLib === 1){
	let btn = '<button type="button" id="btnlp" class="btn btn-outline-success" onclick="libPed(\''+idPed+'\',\'#userlib#\')">Liberar</button>';
	document.getElementById("btnlib").innerHTML = btn;
}

$('#meuModal').modal('show');
$('#meuModal').on('hidden.bs.modal', function () {
	location.reload();
	})
}

async function libPed(id,userlib,btnlp){
let dataObject = {liberacao:'ok'};
let resposta = ''

document.getElementById("btnlp").innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>';

fetch('#iprest#/RestLibPV/v3?pedido='+id+'&userlib='+userlib, {
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

function Excel(){

window.open("#iprest#/RestLibPV/v5?empresa=#empresa#","_self");

}

</script>
</body>
</html>

ENDCONTENT

cHtml := STRTRAN(cHtml,"#iprest#"	 ,u_BkRest())
cHtml := STRTRAN(cHtml,"#BKDTStyle#" ,u_BKDTStyle())
cHtml := STRTRAN(cHtml,"#BKDTScript#",u_BKDTScript())
cHtml := STRTRAN(cHtml,"#BKFavIco#"  ,u_BkFavIco())


iF !Empty(::userlib)
	cHtml := STRTRAN(cHtml,"#userlib#",::userlib)
	cHtml := STRTRAN(cHtml,"#cUserName#",cUserName)
EndIf

cHtml := StrIConv( cHtml, "CP1252", "UTF-8")

// Desabilitar para testar o html
//If __cUserId == '000000'
//	Memowrite("\tmp\pv.html",cHtml)
//EndIf

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



Static Function PrePareContexto(cCodEmpresa , cCodFilial)

	RESET ENVIRONMENT
	RPCSetType(3)
	PREPARE ENVIRONMENT EMPRESA cCodEmpresa FILIAL cCodFilial TABLES "SC5" MODULO "FAT"

Return .T.

