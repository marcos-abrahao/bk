#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

//#Include "Protheus.ch"
//#include 'totvs.ch'
//#include 'RestFul.ch'
#Include "TBICONN.CH"


//User Function RestLibPV
//Return Nil

WSRESTFUL RestLibPV DESCRIPTION "Rest Liberação de Pedido de Venda"
	
	WSDATA mensagem       AS STRING
    WSDATA empresa      AS STRING
    WSDATA filial       AS STRING
	  WSDATA pedido 		  AS STRING
	  WSDATA userlib 		  AS STRING

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


WSMETHOD PUT WSRECEIVE empresa,filial,pedido,userlib WSSERVICE RestLibPV    
//  Local cJson        := Self:GetContent()   
  Local lRet         := .T.
  Local lLib         := .T.
  Local oJson        As Object
//  Local cCatch       As Character  
  Local oMessages    As Object
  Local cPedido      As char


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

    oJson  := JsonObject():New()
    //cCatch := oJson:FromJSON(cJson)

    oMessages := JsonObject():New()

    //If cCatch == Nil
        //PrePareContexto(::empresa,::filial)
        cPedido   := ::pedido
        If !Empty(::userlib)
          __cUserId := ::userlib
          cUserName := UsrRetName(__cUserId)
        EndIf

        Do While Len(cPedido) < 6
            cPedido := "0" + cPedido
        EndDo

        lLib := fLibPed(cPedido)

        oMessages['liberacao'] :="Pedido "+cPedido+iIf(lLib," liberado"," nao foi liberado")
        
        cRet := oMessages:ToJson()
        
        //Retorno do servico
        ::SetResponse(cRet)

    //Else
    //    oMessages["code"] 	:= "400"
    //    oMessages["message"]	:= "Bad Request"
    //    oMessages["detailMessage"] := cCatch
    //    lRet := .F.
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


WSMETHOD GET LISTPV WSRECEIVE page, pageSize WSREST RestLibPV
 
Local aListSales := {}
Local cQrySC5       := GetNextAlias()
Local cJsonCli      := ''
Local cWhereSC5     := "%AND SC5.C5_FILIAL = '"+xFilial('SC5')+"'%"
Local cWhereSA1     := "%AND SA1.A1_FILIAL = '"+xFilial('SA1')+"'%"
Local cPedido       := ''
 
Local lRet := .T.
 
Local nCount := 0
Local nStart := 1
Local nReg := 0
//Local nTamPag := 0
Local oJsonSales := JsonObject():New()
 
Default self:page := 1
Default self:pageSize := 500

//nStart := INT(self:pageSize * (self:page - 1))
//nTamPag := self:pageSize := 100

//-------------------------------------------------------------------
// Query para selecionar pedidos
//-------------------------------------------------------------------

 
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
    ORDER BY SC5.C5_NUM DESC
    
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

    cPedido := (cQrySC5)->C5_NUM
 
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
cHtml := u_BKFATR5H(cPed)
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
    <meta charset="iso-8859-1">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-EVSTQN3/azprG1Anm3QDgpJLIm9Nao0Yz1ztcQTwFspd3yD65VohhpuuCOmLASjC" crossorigin="anonymous">

    <title>Liberação de Pedidos</title>

    <!-- <link href="index.css" rel="stylesheet"> -->
    <style type="text/css">
      .bg-mynav {
        background-color: #9E0000;
      }

      .mesmo-tamanho {
                    height: 1rem;
                    white-space: normal;
      }

      body {
        font-size: 1rem;
        background-color: #f6f8fa;
      }

      td {
          line-height: 1.2rem;
      }
    </style>

  </head>
  <body>

    <nav class="navbar navbar-dark bg-mynav">
      <div class="container-fluid">
        <a class="navbar-brand" href="#">BK - Liberação de Pedidos de Vendas</a>
      </div>
    </nav>

    <div class="container">
      

      <div class="table-responsive">
        <table class="table">
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
              <th scope="row" colspan="5">Loading...</th>
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

          <!-- Cabeçalho do modal -->
          <div class="modal-header">
            <h4 id="titulo" class="modal-title">Título do modal</h4>
            <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
          </div>

          <!-- Corpo do modal -->
          <div class="modal-body">
              <div id="conteudo">Aguarde...</div>
          </div>

          <!-- Rodapé do modal-->
          <div class="modal-footer">
            <button type="button" class="btn btn-danger" data-bs-dismiss="modal">Fechar</button>
            <div id="btnlib"></div>
          </div>

        </div>
      </div>
    </div>

    <!-- Optional JavaScript -->
    <!-- jQuery first, then Popper.js, then Bootstrap JS -->
    <script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>

<script>


async function getPeds() {
    let url = 'http://10.139.0.30:8080/rest/RestLibPV/';
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
    pedidos.forEach(object => {
        let cPedido = object['NUM']
        let cLiberOk = object['LIBEROK']
        trHTML += '<tr>';
        trHTML += '<td>'+cPedido+'</td>';
        trHTML += '<td>'+object['EMISSAO']+'</td>';
        trHTML += '<td>'+object['CLIENTE']+'</td>';
        trHTML += '<td>'+object['CONTRATO']+'</td>';
        trHTML += '<td>'+object['COMPET']+'</td>';
        trHTML += '<td>'+object['TOTAL']+'</td>';
        if (cLiberOk == 'S'){
            trHTML += '<td><button type="button" class="btn btn-outline-warning" onclick="showPed(\''+object['NUM']+'\',2)">Liberado</button></td>';
        } else {
            trHTML += '<td><button type="button" class="btn btn-outline-danger" onclick="showPed(\''+object['NUM']+'\',1)">Liberar</button></td>';
        }
        trHTML += '</tr>';
    });
    document.getElementById("mytable").innerHTML = trHTML;
}

loadTable();


function showPed(idPed,canLib) {
  let url = 'http://10.139.0.30:8080/rest/RestLibPV/v1?pedido='+idPed;
  $("#titulo").text(url);
  $("#conteudo").load(url);
  if (canLib === 1){
    let btn = '<button type="button" class="btn btn-primary" onclick="libPed(\''+idPed+'\',\'#userlib#\')">Liberar</button>';
    document.getElementById("btnlib").innerHTML = btn;
  }

  $('#meuModal').modal('show');

  $('#meuModal').on('hidden.bs.modal', function () {
    location.reload();
  })
  //loadTable();
}


async function putLibPed(id,userlib){
  let dataObject = {empresa:"01", filial: "01", pedido: id};

  fetch('http://10.139.0.30:8080/rest/RestLibPV/v3?pedido='+id+'&userlib='+userlib, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(dataObject)})

  .then(response=>{
    //console.log(response)
    return response.json()
  })
  .then(data=> {
  // this is the data we get after putting our data,
  console.log(data)
  })
}



function libPed(id,userlib) {
let resposta = ''
resposta = putLibPed(id,userlib);
$('#meuModal').modal('toggle');
}

</script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>
    <!-- <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script> -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js" integrity="sha256-/xUj+3OJU5yExlq6GSYGSHk7tPXikynS7ogEvDej/m4=" crossorigin="anonymous"></script>
  </body>
</html>

endcontent

If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer())
    cHtml := STRTRAN(cHtml,"10.139.0.30:8080","10.139.0.30:8081")
EndIf

iF !Empty(::userlib)
    cHtml := STRTRAN(cHtml,"#userlib#",::userlib)
EndIf

Memowrite("\tmp\x.html",cHtml)

self:setResponse(cHTML)
self:setStatus(200)

return .T.



Static Function fLibPed(cNumPed)
Local lOk := .F.

    dbSelectArea("SC5")
    SC5->(dbSetOrder(1))
    SC5->(dbSeek(xFilial("SC5")+cNumPed))

    If Empty(SC5->C5_LIBEROK).And.Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_BLQ)
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
Return lOk



Static Function PrePareContexto(cCodEmpresa , cCodFilial)
 
RESET ENVIRONMENT
RPCSetType(3)
PREPARE ENVIRONMENT EMPRESA cCodEmpresa FILIAL cCodFilial TABLES "SC5" MODULO "FAT" 		

Return .T.

