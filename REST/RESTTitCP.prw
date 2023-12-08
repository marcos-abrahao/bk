#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} RestTitCP
    REST Titulos do Contas a Pagar
	https://datatables.net/examples/api/row_details.html
    @type  REST
    @author Marcos B. Abrahão
    @since 23/11/2023
    @version 12.2210
/*/

WSRESTFUL RestTitCP DESCRIPTION "Rest Titulos do Contas a Pagar"

	WSDATA mensagem     AS STRING
	WSDATA empresa      AS STRING
	WSDATA filial       AS STRING
	WSDATA vencreal     AS STRING
	WSDATA e2recno 		AS STRING
	WSDATA banco 		AS STRING
	WSDATA userlib 		AS STRING OPTIONAL
	WSDATA acao 		AS STRING

	WSMETHOD GET LISTCP;
		DESCRIPTION "Listar Títulos a Pagar";
		WSSYNTAX "/RestTitCP/v0";
		PATH  "/RestTitCP/v0";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET CONSCP;
		DESCRIPTION "Retorna dados Pré-nota";
		WSSYNTAX "/RestTitCP/v1";
		PATH "/RestTitCP/v1";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET BROWCP;
		DESCRIPTION "Browse Pré-notas de Entrada a Liberar como página HTML";
		WSSYNTAX "/RestTitCP/v2";
		PATH "/RestTitCP/v2";
		TTALK "v1";
		PRODUCES TEXT_HTML

	WSMETHOD GET PLANCP;
		DESCRIPTION "Retorna planilha excel da tela por meio do método FwFileReader().";
		WSSYNTAX "/RestTitCP/v5";
		PATH "/RestTitCP/v5";
		TTALK "v1"

	WSMETHOD PUT STATUS;
		DESCRIPTION "Alterar o status do titulo a pagar" ;
		WSSYNTAX "/RestTitCP/v3";
		PATH "/RestTitCP/v3";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD PUT BANCO;
		DESCRIPTION "Alterar o portador do titulo a pagar" ;
		WSSYNTAX "/RestTitCP/v4";
		PATH "/RestTitCP/v4";
		TTALK "v1";
		PRODUCES APPLICATION_JSON


END WSRESTFUL



//v3
WSMETHOD PUT STATUS QUERYPARAM empresa,e2recno,userlib,acao WSREST RestTitCP 

Local cJson			:= Self:GetContent()   
Local lRet			:= .T.
Local oJson			As Object
Local aParams		As Array
Local cMsg			As Char

::setContentType('application/json')

oJson := JsonObject():New()
oJson:FromJSON(cJson)

If u_BkAvPar(::userlib,@aParams,@cMsg)

	lRet := fStatus(::empresa,::e2recno,::acao,@cMsg)

EndIf

oJson['liberacao'] := StrIConv(cMsg, "CP1252", "UTF-8")

cRet := oJson:ToJson()

FreeObj(oJson)
// CORS
Self:SetHeader("Access-Control-Allow-Origin", "*")

Self:SetResponse(cRet)
  
Return lRet



Static Function fStatus(empresa,e2recno,acao,cMsg)
Local lRet 		:= .F.
Local cQuery	:= ""
Local cTabSE2	:= "SE2"+empresa+"0"
Local cQrySE2	:= GetNextAlias()
Local cNum		:= ""

Default cMsg	:= ""
Default cMotivo := ""

Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

cQuery := "SELECT "
cQuery += "  SE2.E2_XXPGTO,"
cQuery += "  SE2.D_E_L_E_T_ AS E2DELET,"
cQuery += "  SE2.E2_NUM "
cQuery += " FROM "+cTabSE2+" SE2 "
cQuery += " WHERE SE2.R_E_C_N_O_ = "+e2recno

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySE2,.T.,.T.)

cNum := (cQrySE2)->E2_NUM
Do Case
	Case (cQrySE2)->(Eof()) 
		cMsg:= "não encontrado"
	Case (cQrySE2)->E2DELET = '*'
		cMsg:= "foi excluído"
	OtherWise 
		// Alterar o Status
		cMsg 	:= acao
		cQuery := "UPDATE "+cTabSE2+CRLF
		cQuery += "  SET E2_XXPGTO = '"+SUBSTR(acao,1,1)+"',"+CRLF
		cQuery += "      E2_XXOPER = '"+__cUserId+"'"+CRLF
		cQuery += " FROM "+cTabSE2+" SE2"+CRLF
		cQuery += " WHERE SE2.R_E_C_N_O_ = "+e2recno+CRLF

		If TCSQLExec(cQuery) < 0 
			cMsg := "Erro: "+TCSQLERROR()
		Else
			lRet := .T.
		EndIf
EndCase

cMsg := cNum+" "+cMsg

u_MsgLog("RESTTitCP",cMsg)

(cQrySE2)->(dbCloseArea())

Return lRet


//v4
WSMETHOD PUT BANCO QUERYPARAM empresa,e2recno,userlib,banco WSREST RestTitCP 

Local cJson			:= Self:GetContent()   
Local lRet			:= .T.
Local oJson			As Object
Local aParams		As Array
Local cMsg			As Char

::setContentType('application/json')

oJson := JsonObject():New()
oJson:FromJSON(cJson)

If u_BkAvPar(::userlib,@aParams,@cMsg)

	lRet := fBanco(::empresa,::e2recno,::banco,@cMsg)

EndIf

oJson['liberacao'] := StrIConv(cMsg, "CP1252", "UTF-8")

cRet := oJson:ToJson()

FreeObj(oJson)
// CORS
Self:SetHeader("Access-Control-Allow-Origin", "*")

Self:SetResponse(cRet)
  
Return lRet


Static Function fBanco(empresa,e2recno,banco,cMsg)
Local lRet 		:= .F.
Local cQuery	:= ""
Local cTabSE2	:= "SE2"+empresa+"0"
Local cQrySE2	:= GetNextAlias()
Local cNum		:= ""

Default cMsg	:= ""
Default cMotivo := ""

Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

cQuery := "SELECT "
cQuery += "  SE2.E2_NUM,"
cQuery += "  SE2.D_E_L_E_T_ AS E2DELET,"
cQuery += "  SE2.E2_NUM "
cQuery += " FROM "+cTabSE2+" SE2 "
cQuery += " WHERE SE2.R_E_C_N_O_ = "+e2recno

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySE2,.T.,.T.)

cNum := (cQrySE2)->E2_NUM
Do Case
	Case (cQrySE2)->(Eof()) 
		cMsg:= "não encontrado"
	Case (cQrySE2)->E2DELET = '*'
		cMsg:= "foi excluído"
	OtherWise 
		// Alterar o Status
		cMsg 	:= banco
		cQuery := "UPDATE "+cTabSE2+CRLF
		cQuery += "  SET E2_PORTADO = '"+banco+"',"+CRLF
		cQuery += "      E2_XXOPER = '"+__cUserId+"'"+CRLF
		cQuery += " FROM "+cTabSE2+" SE2"+CRLF
		cQuery += " WHERE SE2.R_E_C_N_O_ = "+e2recno+CRLF
		//u_LogMemo("RESTTitCP.SQL",cQuery)
		If TCSQLExec(cQuery) < 0
			cMsg := "Erro: "+TCSQLERROR()
		Else
			lRet := .T.
		EndIf
EndCase

cMsg := cNum+" Banco -"+cMsg+" - "+e2recno

u_MsgLog("RESTTitCP",cMsg)

(cQrySE2)->(dbCloseArea())

Return lRet



// v5
WSMETHOD GET PLANCP QUERYPARAM empresa,vencreal WSREST RestTitCP
	Local cProg 	:= "RestTitCP"
	Local cTitulo	:= "Contas a Pagar WEB"
	Local cDescr 	:= "Exportação de tela do C.Pagar Web"
	Local cVersao	:= "07/12/2023"
	Local oRExcel	AS Object
	Local oPExcel	AS Object

    Local cFile  	:= ""
	Local cName  	:= "" //Decode64(self:documento)
	Local cFName 	:= ""
    Local oFile  	AS Object

	Local cQrySE2	:= GetNextAlias()

	// Query para selecionar os Títulos a Pagar
	TmpQuery(cQrySE2,self:empresa,self:vencreal)


	// Definição do Arq Excel
	oRExcel := RExcel():New(cProg)
	oRExcel:SetTitulo(cTitulo)
	oRExcel:SetVersao(cVersao)
	oRExcel:SetDescr(cDescr)

	// Definição da Planilha 1
	oPExcel:= PExcel():New(cProg,cQrySE2)
	oPExcel:SetTitulo("Empresa: "+self:empresa+" - Vencimento: "+DTOC(STOD(self:vencreal)))

	oPExcel:AddCol("EMPRESA","EMPRESA","Empresa","")
	oPExcel:AddCol("TITULO" ,"(E2_PREFIXO+E2_NUM+E2_PARCELA)","Título","")
	oPExcel:AddCol("FORNECEDOR","A2_NOME","Fornecedor","A2_NOME")
	oPExcel:AddCol("FORMPGT","FORMPGT","Forma Pgto","")
	oPExcel:AddCol("VENC","STOD(E2_VENCREA)","Vencto","E2_VENCREA")
	oPExcel:AddCol("PORTADO","E2_PORTADO","Portador","")
	oPExcel:AddCol("BORDERO","E2_NUMBOR","Bordero","")
	oPExcel:AddCol("VALOR","E2_VALOR","Valor","E2_VALOR")
	oPExcel:AddCol("SALDO","SALDO","Saldo","")
	oPExcel:AddCol("STATUS","IIF(E2_XXPGTO=='P','Pendente',IIF(E2_XXPGTO=='C','Concluído','Em Aberto'))","Status","")
	oPExcel:AddCol("HIST","HIST","Histórico","D1_XXHIST")
	oPExcel:AddCol("OPER","UsrRetName(E2_XXOPER)","Operador","")

	oPExcel:GetCol("FORMPGT"):SetHAlign("C")
	oPExcel:GetCol("PORTADO"):SetHAlign("C")
	oPExcel:GetCol("BORDERO"):SetHAlign("C")
	oPExcel:GetCol("HIST"):SetWrap(.T.)
	oPExcel:GetCol("VALOR"):SetTotal(.T.)

	oPExcel:GetCol("SALDO"):SetDecimal(2)
	oPExcel:GetCol("SALDO"):SetTotal(.T.)

	oPExcel:GetCol("STATUS"):SetHAlign("C")
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'P'},"FF0000","") // Vermelho
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'C'},"008000","") // Verde
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'E'},"FFA500","",,,.T.) // Laranja

	// Adiciona a planilha
	oRExcel:AddPlan(oPExcel)

	// Cria arquivo Excel
	cFName:= oRExcel:RunCreate()

	// Remove pastas do nome do arquivo
	cName:= SubStr(cFName,Rat("\",cFName)+1)

	(cQrySE2)->(dbCloseArea())

	// Abrir arquino na Web
	//cName  	:= cFName //Decode64(self:documento)
    oFile  	:= FwFileReader():New(cFName) // CAMINHO ABAIXO DO ROOTPATH

    If (oFile:Open())
        cFile := oFile:FullRead() // EFETUA A LEITURA DO ARQUIVO

        // RETORNA O ARQUIVO PARA DOWNLOAD

        //Self:SetHeader("Content-Disposition", '"inline; filename='+cName+'"') não funciona
        Self:SetHeader("Content-Disposition", "attachment; filename="+cName)

        Self:SetResponse(cFile)

        lSuccess := .T. // CONTROLE DE SUCESSO DA REQUISIÇÃO
    Else
        SetRestFault(002, "Nao foi possivel carregar o arquivo "+cFName) // GERA MENSAGEM DE ERRO CUSTOMIZADA

        lSuccess := .F. // CONTROLE DE SUCESSO DA REQUISIÇÃO
    EndIf

Return (lSuccess)



/*/{Protheus.doc} GET 
Retorna a lista de titulos.
/*/

// v0
WSMETHOD GET LISTCP QUERYPARAM empresa,vencreal,userlib WSREST RestTitCP
Local aListCP 		:= {}
Local cQrySE2       := GetNextAlias()
Local cJsonCli      := ''
Local lRet 			:= .T.
Local oJsonTmp	 	:= JsonObject():New()

Local aParams      	As Array
Local cMsg         	As Character
//Local lPerm			:= .T.
Local cStatus		:= ""
Local cNumTit 		:= ""

//u_MsgLog("RESTTITCP",VarInfo("vencreal",self:vencreal))

If !u_BkAvPar(::userlib,@aParams,@cMsg)
  oJsonTmp	['liberacao'] := cMsg
  cRet := oJsonTmp	:ToJson()
  FreeObj(oJsonTmp	)
  //Retorno do servico
  ::SetResponse(cRet)
  Return lRet:= .T.
EndIf

// Usuários que podem executar alguma ação
//lPerm := u_InGrupo(__cUserId,"000000/000005/000007/000038")

// Query para selecionar os Títulos a Pagar
TmpQuery(cQrySE2,self:empresa,self:vencreal)

//-------------------------------------------------------------------
// Alimenta array de Pré-notas
//-------------------------------------------------------------------
Do While ( cQrySE2 )->( ! Eof() )

	aAdd( aListCP , JsonObject():New() )

	nPos	:= Len(aListCP)
	cNumTit	:= (cQrySE2)->(E2_PREFIXO+E2_NUM+E2_PARCELA)
	cNumTit := STRTRAN(cNumTit," ","&nbsp;")

	aListCP[nPos]['EMPRESA']	:= (cQrySE2)->EMPRESA
	aListCP[nPos]['TITULO']     := cNumTit
	aListCP[nPos]['FORNECEDOR'] := TRIM((cQrySE2)->A2_NOME)
	aListCP[nPos]['FORMPGT']	:= TRIM((cQrySE2)->FORMPGT)
	aListCP[nPos]['VENC'] 		:= DTOC(STOD((cQrySE2)->E2_VENCREA))
	aListCP[nPos]['PORTADO']	:= TRIM((cQrySE2)->E2_PORTADO)
	aListCP[nPos]['BORDERO']	:= TRIM((cQrySE2)->E2_NUMBOR)
	aListCP[nPos]['VALOR']      := TRANSFORM((cQrySE2)->E2_VALOR,"@E 999,999,999.99")
	aListCP[nPos]['SALDO'] 	    := TRANSFORM((cQrySE2)->SALDO,"@E 999,999,999.99")

	aListCP[nPos]['XSTATUS']	:= (cQrySE2)->(E2_XXPGTO)
	If (cQrySE2)->(E2_XXPGTO) == "P"
		cStatus := "Pendente"
	ElseIf (cQrySE2)->(E2_XXPGTO) == "C"
		cStatus := "Concluido"
	Else
		cStatus := "Em Aberto"
	EndIf
	aListCP[nPos]['STATUS']		:= cStatus
	aListCP[nPos]['HIST']		:= StrIConv(ALLTRIM((cQrySE2)->HIST), "CP1252", "UTF-8") 
	aListCP[nPos]['OPER']		:= (cQrySE2)->(UsrRetName(E2_XXOPER)) //(cQrySE2)->(FwLeUserLg('E2_USERLGA',1))
	aListCP[nPos]['E2RECNO']	:= STRZERO((cQrySE2)->E2RECNO,7)

	(cQrySE2)->(DBSkip())

EndDo

( cQrySE2 )->( DBCloseArea() )

oJsonTmp	 := aListCP

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


// v2
WSMETHOD GET BROWCP QUERYPARAM empresa,vencreal,userlib WSREST RestTitCP

Local cHTML		as char
Local cDropEmp	as char
Local aEmpresas := u_BKGrupo()
Local nE 		:= 0

begincontent var cHTML

<!doctype html>
<html lang="pt-BR">
<head>
<!-- Required meta tags -->
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Bootstrap CSS -->
<!-- https://datatables.net/manual/styling/bootstrap5   examples-->
<link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css" rel="stylesheet">

<title>Títulos Contas a Pagar #datavenc# #NomeEmpresa#</title>
<!-- <link href="index.css" rel="stylesheet"> -->
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
  font-size: 0.7em;
}
body {
font-size: 0.8rem;
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
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Títulos a Pagar - #cUserName#</a> 

	<div class="btn-group">
		<button type="button" class="btn btn-dark dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">
			#NomeEmpresa#
		</button>
		<ul class="dropdown-menu">
			#DropEmpresas#
		</ul>
	</div>

	<div class="btn-group">
		<button type="button" class="btn btn-dark" aria-label="Excel" onclick="Excel()">Excel</button>
	</div>

    <form class="d-flex">
	  <input class="form-control me-2" type="date" id="DataVenc" value="#datavenc#" />
      <button type="button" class="btn btn-dark" aria-label="Atualizar" onclick="AltVenc()">Atualizar</button>
    </form>

  </div>
</nav>
<br>
<br>
<br>
<div class="container-fluid">
<div class="table-responsive-sm">
<table id="tableSE2" class="table">
<thead>
<tr>
<th scope="col">Empresa</th>
<th scope="col">Título</th>
<th scope="col">Fornecedor</th>
<th scope="col">Forma Pgto</th>
<th scope="col">Vencto</th>
<th scope="col" style="text-align:center;">Portador</th>
<th scope="col">Borderô</th>
<th scope="col" style="text-align:center;">Valor</th>
<th scope="col" style="text-align:center;">Saldo</th>
<th scope="col" style="text-align:center;">Status</th>
<th scope="col">Histórico</th>
<th scope="col">Operador</th>
</tr>
</thead>
<tbody id="mytable">
<tr>
  <th scope="col">Carregando Títulos...</th>
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col" style="text-align:center;"></th>
  <th scope="col" style="text-align:center;"></th>
  <th scope="col" style="text-align:center;"></th>
  <th scope="col"></th>
  <th scope="col"></th>
</tr>
</tbody>
</table>
</div>
</div>

<!-- Optional JavaScript -->
<!-- jQuery first, then Popper.js, then Bootstrap JS -->
<!-- https://datatables.net/examples/styling/bootstrap5.html -->
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>

<!-- JavaScript Bundle with Popper -->
<!-- https://www.jsdelivr.com/package/npm/bootstrap -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha256-gvZPYrsDwbwYJLD5yeBfcNujPhRoGOY831wwbIzz3t0=" crossorigin="anonymous"></script>

<!-- https://datatables.net/ -->
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>

<!-- Buttons -->
<script src="https://cdn.datatables.net/buttons/2.4.1/js/dataTables.buttons.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.53/pdfmake.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.1.53/vfs_fonts.js"></script>
<script src="https://cdn.datatables.net/buttons/2.4.1/js/buttons.html5.min.js"></script>

<script>

async function getCPs() {
	let url = '#iprest#/RestTitCP/v0?empresa=#empresa#&vencreal=#vencreal#&userlib=#userlib#'
		try {
		let res = await fetch(url);
			return await res.json();
			} catch (error) {
		console.log(error);
			}
		}


async function loadTable() {
let titulos = await getCPs();
let trHTML = '';
let nlin = 0;
let cbtn = '';
let cbtnidp = ''
let cbtnids = ''

if (Array.isArray(titulos)) {
	titulos.forEach(object => {
	let cStatus  = object['XSTATUS']
	let cEmpresa = object['EMPRESA'].substring(0,2)
	nlin += 1;
	trHTML += '<tr>';
	trHTML += '<td>'+object['EMPRESA']+'</td>';
	trHTML += '<td>'+object['TITULO']+'</td>';
	trHTML += '<td>'+object['FORNECEDOR']+'</td>';
	trHTML += '<td>'+object['FORMPGT']+'</td>';
	trHTML += '<td>'+object['VENC']+'</td>';

	// Botão para troca do portador
	cbtnidp = 'btnpor'+nlin;
	trHTML += '<td>'
	trHTML += '<div class="btn-group">'
	trHTML += '<button type="button" id="'+cbtnidp+'" class="btn btn-dark dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">'
	trHTML += object['PORTADO']
	trHTML += '</button>'

	trHTML += '<div class="dropdown-menu" aria-labelledby="dropdownMenu2">'
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgBanco(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'001\','+'\''+cbtnidp+'\')">001 BB</button>';
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgBanco(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'033\','+'\''+cbtnidp+'\')">033 Santander</button>';
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgBanco(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'104\','+'\''+cbtnidp+'\')">104 CEF</button>';
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgBanco(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'237\','+'\''+cbtnidp+'\')">237 Bradesco</button>';
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgBanco(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'341\','+'\''+cbtnidp+'\')">341 Itau</button>';
	trHTML += '</div>'
	trHTML += '</td>'

	trHTML += '<td>'+object['BORDERO']+'</td>';
	trHTML += '<td align="right">'+object['VALOR']+'</td>';
	trHTML += '<td align="right">'+object['SALDO']+'</td>';

	if (cStatus == 'C' ){
	 cbtn = 'btn-outline-success';
	 } else if (cStatus == ' ' || cStatus == 'A'){
	 cbtn = 'btn-outline-warning';
	} else if (cStatus == 'P'){
	 cbtn = 'btn-outline-danger';
	}

	cbtnids = 'btnac'+nlin;

	trHTML += '<td>'

	// Botão para mudança de status
	trHTML += '<div class="btn-group">'
	trHTML += '<button type="button" id="'+cbtnids+'" class="btn '+cbtn+' dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">'
	trHTML += object['STATUS']
	trHTML += '</button>'

	trHTML += '<div class="dropdown-menu" aria-labelledby="dropdownMenu2">'
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgStatus(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'A\','+'\''+cbtnids+'\')">Em Aberto</button>';
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgStatus(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'C\','+'\''+cbtnids+'\')">Concluido</button>';
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgStatus(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'P\','+'\''+cbtnids+'\')">Pendente</button>';

	trHTML += '</div>'

	trHTML += '</td>'

	trHTML += '<td>'+object['HIST']+'</td>';
	trHTML += '<td>'+object['OPER']+'</td>';

	trHTML += '</tr>';
	});
} else {
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="11" style="text-align:center;">'+titulos['liberacao']+'</th>';
    trHTML += '</tr>';   
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="11" style="text-align:center;">Faça login novamente no sistema Protheus</th>';
    trHTML += '</tr>';   
}
document.getElementById("mytable").innerHTML = trHTML;

$('#tableSE2').DataTable({
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
   }
 });

}

loadTable();


async function ChgBanco(empresa,e2recno,userlib,banco,btnidp){
let resposta = ''
let dataObject = {	liberacao:'ok' };
let cbtn = '';
	
fetch('#iprest#/RestTitCP/v4?empresa='+empresa+'&e2recno='+e2recno+'&userlib='+userlib+'&banco='+banco, {
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

async function ChgStatus(empresa,e2recno,userlib,acao,btnids){
let resposta = ''
let dataObject = {	liberacao:'ok' };
let cbtn = '';
	
fetch('#iprest#/RestTitCP/v3?empresa='+empresa+'&e2recno='+e2recno+'&userlib='+userlib+'&acao='+acao, {
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
		} else {
			cbtn = 'Em Aberto';
		}
		document.getElementById(btnids).textContent = cbtn;
	})
}

async function Excel(){
let newvenc = document.getElementById("DataVenc").value;
let newvamd  = newvenc.substring(0, 4)+newvenc.substring(5, 7)+newvenc.substring(8, 10)
window.open("#iprest#/RestTitCP/v5?empresa=#empresa#&vencreal="+newvamd+'&userlib=#userlib#',"_self");
}


async function AltVenc(){
let newvenc = document.getElementById("DataVenc").value;
let newvamd  = newvenc.substring(0, 4)+newvenc.substring(5, 7)+newvenc.substring(8, 10)
window.open("#iprest#/RestTitCP/v2?empresa=#empresa#&vencreal="+newvamd+'&userlib=#userlib#',"_self");
}

</script>

</body>
</html>
ENDCONTENT

cHtml := STRTRAN(cHtml,"#iprest#",u_BkRest())

If !Empty(::userlib)
	cHtml := STRTRAN(cHtml,"#userlib#",::userlib)
	cHtml := STRTRAN(cHtml,"#cUserName#",cUserName)
EndIf

cHtml := STRTRAN(cHtml,"#empresa#",::empresa)
cHtml := STRTRAN(cHtml,"#vencreal#",::vencreal)
cHtml := STRTRAN(cHtml,"#datavenc#",SUBSTR(::vencreal,1,4)+"-"+SUBSTR(::vencreal,5,2)+"-"+SUBSTR(::vencreal,7,2))   // Formato: 2023-10-24 input date


// --> Seleção de Empresas
nE := aScan(aEmpresas,{|x| x[1] == SUBSTR(self:empresa,1,2) })
If nE > 0
	cHtml := STRTRAN(cHtml,"#NomeEmpresa#",aEmpresas[nE,2])
Else
	cHtml := STRTRAN(cHtml,"#NomeEmpresa#","Todas")
EndIf

cDropEmp := ""
For nE := 1 To Len(aEmpresas)
//	<li><a class="dropdown-item" href="#">BK</a></li>
	cDropEmp += '<li><a class="dropdown-item" href="'+u_BkRest()+'/RestTitCP/v2?empresa='+aEmpresas[nE,1]+'&vencreal='+self:vencreal+'&userlib='+self:userlib+'">'+aEmpresas[nE,1]+'-'+aEmpresas[nE,2]+'</a></li>'+CRLF
Next
cDropEmp +='<li><hr class="dropdown-divider"></li>'+CRLF
cDropEmp +='<li><a class="dropdown-item" href="'+u_BkRest()+'/RestTitCP/v2?empresa=Todas&vencreal='+self:vencreal+'&userlib='+self:userlib+'">Todas</a></li>'+CRLF

cHtml := STRTRAN(cHtml,"#DropEmpresas#",cDropEmp)
// <-- Seleção de Empresas

//StrIConv( cHtml, "UTF-8", "CP1252")
//DecodeUtf8(cHtml)
cHtml := StrIConv( cHtml, "CP1252", "UTF-8")

//If ::userlib == '000000'
	//Memowrite("\tmp\cp.html",cHtml)
//EndIf
//u_MsgLog("RESTTITCP",__cUserId)

Self:SetHeader("Access-Control-Allow-Origin", "*")
self:setResponse(cHTML)
self:setStatus(200)

return .T.


// Montagem da Query
Static Function TmpQuery(cQrySE2,xEmpresa,xVencreal)

Local aEmpresas		:= {}
Local aGrupoBK 		:= {}
Local cEmpresa		:= ""
Local cNomeEmp		:= ""
Local cTabSE2		:= ""
Local cTabSF1		:= ""
Local cTabSD1		:= ""
Local cTabCTT		:= ""
Local cTabSA2		:= ""
Local cTabSB1		:= ""
Local cTabSZ2		:= "SZ2010"
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

For nE := 1 To Len(aEmpresas)

	cTabSE2 := "SE2"+aEmpresas[nE,1]+"0"
	cTabSA2 := "SA2"+aEmpresas[nE,1]+"0"
	cTabSF1 := "SF1"+aEmpresas[nE,1]+"0"
	cTabCTT := "CTT"+aEmpresas[nE,1]+"0"
	cTabSD1 := "SD1"+aEmpresas[nE,1]+"0"
	cTabSB1 := "SB1"+aEmpresas[nE,1]+"0"

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,3]

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT "+CRLF
	cQuery += "	  '"+cEmpresa+"-"+cNomeEmp+"' AS EMPRESA"+CRLF
	cQuery += "	 ,E2_TIPO"+CRLF
	cQuery += "	 ,E2_PREFIXO"+CRLF
	cQuery += "	 ,E2_NUM"+CRLF
	cQuery += "	 ,E2_PARCELA"+CRLF
	cQuery += "	 ,E2_FORNECE"+CRLF
	cQuery += "	 ,E2_PORTADO"+CRLF
	cQuery += "	 ,E2_NUMBOR"+CRLF   ///
	cQuery += "	 ,E2_LOJA"+CRLF
	cQuery += "	 ,E2_NATUREZ"+CRLF
	cQuery += "	 ,E2_HIST"+CRLF
	cQuery += "	 ,E2_USERLGA"+CRLF 
	cQuery += "	 ,E2_BAIXA"+CRLF
	cQuery += "	 ,E2_VENCREA"+CRLF
	cQuery += "	 ,E2_VALOR"+CRLF
	cQuery += "	 ,E2_XXPRINT"+CRLF
	cQuery += "	 ,E2_XXPGTO"+CRLF
	cQuery += "	 ,E2_XXOPER"+CRLF
	cQuery += "	 ,SE2.R_E_C_N_O_ AS E2RECNO"+CRLF
	cQuery += "	 ,A2_NOME"+CRLF
	cQuery += "	 ,A2_TIPO"+CRLF
	cQuery += "	 ,A2_CGC"+CRLF

	cQuery += "	 ,(CASE WHEN E2_SALDO = E2_VALOR "+CRLF
	cQuery += "	 		THEN E2_VALOR + E2_ACRESC - E2_DECRESC"+CRLF
	cQuery += "	 		ELSE E2_SALDO END) AS SALDO"+CRLF


	//cQuery += "	 ,"+IIF(dDtIni <> dDtFim,"+' '+E2_VENCREA",'')+"+ "
	cQuery += "	 ,(CASE WHEN (F1_XTIPOPG IS NULL) AND (Z2_BANCO IS NULL) "+CRLF
	cQuery += "	 			THEN E2_TIPO+' '+E2_PORTADO"+CRLF
	cQuery += "	 		WHEN F1_XTIPOPG IS NULL AND (E2_PORTADO IS NOT NULL) THEN 'LF '+E2_PORTADO+' '+E2_TIPO"+CRLF
	cQuery += "	 		ELSE F1_XTIPOPG END)"+" AS FORMPGT"+CRLF

	cQuery += "	 ,F1_DOC"+CRLF
	cQuery += "	 ,F1_XTIPOPG"+CRLF
	cQuery += "	 ,F1_XNUMPA"+CRLF
	cQuery += "	 ,F1_XBANCO"+CRLF
	cQuery += "	 ,F1_XAGENC"+CRLF
	cQuery += "	 ,F1_XNUMCON"+CRLF
	cQuery += "	 ,F1_XXTPPIX"+CRLF
	cQuery += "	 ,F1_XXCHPIX "+CRLF
	cQuery += "	 ,F1_USERLGI"+CRLF 
	cQuery += "	 ,F1_XXUSER"+CRLF
	cQuery += "	 ,D1_COD"+CRLF
	cQuery += "	 ,B1_DESC"+CRLF
	cQuery += "	 ,D1_CC"+CRLF
	cQuery += "	 ,CTT_DESC01"+CRLF
	cQuery += "  ,CONVERT(VARCHAR(800),CONVERT(Binary(800),D1_XXHIST)) AS D1_XXHIST "+CRLF

	//cQuery += "	 ,(SELECT TOP 1 Z2_BANCO "+CRLF
	//cQuery += "	 	FROM "+RetSqlName("SZ2")+" SZ2"+CRLF
	//cQuery += "	 	WHERE SZ2.Z2_FILIAL    = '  '"+CRLF
	//cQuery += "	 		AND SZ2.Z2_CODEMP  = '"+cEmpAnt+"' "+CRLF
	//cQuery += "	 		AND SE2.E2_PREFIXO = SZ2.Z2_E2PRF"+CRLF
	//cQuery += "	 		AND SE2.E2_NUM     = SZ2.Z2_E2NUM "+CRLF
	//cQuery += "	 		AND SE2.E2_PARCELA = SZ2.Z2_E2PARC"+CRLF
	//cQuery += "	 		AND SE2.E2_TIPO    = SZ2.Z2_E2TIPO"+CRLF
	//cQuery += "	 		AND SE2.E2_FORNECE = SZ2.Z2_E2FORN"+CRLF
	//cQuery += "	 		AND SE2.E2_LOJA    = SZ2.Z2_E2LOJA"+CRLF
	//cQuery += "	 		AND SZ2.Z2_STATUS  = 'S'"+CRLF
	//cQuery += "	 		AND SZ2.D_E_L_E_T_ = '') AS Z2_BANCO"+CRLF

	cQuery += "	 FROM "+cTabSE2+" SE2 "+CRLF

	cQuery += "	 LEFT JOIN "+cTabSF1+" SF1 ON"+CRLF
	cQuery += "	 	SE2.E2_FILIAL      = SF1.F1_FILIAL"+CRLF
	cQuery += "	 	AND SE2.E2_NUM     = SF1.F1_DOC "+CRLF
	cQuery += "	 	AND SE2.E2_PREFIXO = SF1.F1_SERIE"+CRLF
	cQuery += "	 	AND SE2.E2_FORNECE = SF1.F1_FORNECE"+CRLF
	cQuery += "	 	AND SE2.E2_LOJA    = SF1.F1_LOJA"+CRLF
	cQuery += "	 	AND SF1.D_E_L_E_T_ = ''"+CRLF

	cQuery += "	 LEFT JOIN "+cTabSA2+"  SA2 ON"+CRLF
	cQuery += "	 	SA2.A2_FILIAL      = '  '"+CRLF
	cQuery += "	 	AND SE2.E2_FORNECE = SA2.A2_COD"+CRLF
	cQuery += "	 	AND SE2.E2_LOJA    = SA2.A2_LOJA"+CRLF
	cQuery += "	 	AND SA2.D_E_L_E_T_ = ''"+CRLF

	cQuery += " LEFT JOIN "+cTabSD1+" SD1 ON SD1.D_E_L_E_T_=''"+ CRLF
	cQuery += "   AND D1_FILIAL  = '"+xFilial("SD1")+"' "+ CRLF
	cQuery += "   AND D1_DOC     = F1_DOC"+ CRLF
	cQuery += "   AND D1_SERIE   = F1_SERIE"+ CRLF
	cQuery += "   AND D1_FORNECE = F1_FORNECE"+ CRLF
	cQuery += "   AND D1_LOJA    = F1_LOJA"+ CRLF
	cQuery += "   AND SD1.R_E_C_N_O_ = "+ CRLF
	cQuery += "   	(SELECT TOP 1 R_E_C_N_O_ FROM "+cTabSD1+" SD1T "+ CRLF
	cQuery += "   	  WHERE SD1T.D_E_L_E_T_     = '' "+ CRLF
	cQuery += "   	        AND SD1T.D1_FILIAL  = '"+xFilial("SD1")+"' "+ CRLF
	cQuery += "   			AND SD1T.D1_DOC     = F1_DOC"+ CRLF
	cQuery += "   			AND SD1T.D1_SERIE   = F1_SERIE"+ CRLF
	cQuery += "   			AND SD1T.D1_FORNECE = F1_FORNECE"+ CRLF
	cQuery += "   			AND SD1T.D1_LOJA    = F1_LOJA"+ CRLF
	cQuery += "		 ORDER BY D1_ITEM)"+ CRLF

	cQuery += "	 LEFT JOIN "+cTabSZ2+" SZ2 ON SZ2.D_E_L_E_T_=''"+CRLF
	cQuery += "	 			AND SZ2.Z2_FILIAL  = ' '"+CRLF
	cQuery += "	 	 		AND SZ2.Z2_CODEMP  = '01' "+CRLF
	cQuery += "	 	 		AND SE2.E2_PREFIXO = SZ2.Z2_E2PRF"+CRLF
	cQuery += "	 	 		AND SE2.E2_NUM     = SZ2.Z2_E2NUM "+CRLF
	cQuery += "	 	 		AND SE2.E2_PARCELA = SZ2.Z2_E2PARC"+CRLF
	cQuery += "	 	 		AND SE2.E2_TIPO    = SZ2.Z2_E2TIPO"+CRLF
	cQuery += "	 	 		AND SE2.E2_FORNECE = SZ2.Z2_E2FORN"+CRLF
	cQuery += "	 	 		AND SE2.E2_LOJA    = SZ2.Z2_E2LOJA"+CRLF
	cQuery += "	 	 		AND SZ2.Z2_STATUS  = 'S'"+CRLF
	cQuery += "	 		    AND SZ2.R_E_C_N_O_ = "+CRLF
	cQuery += "	    	(SELECT TOP 1 R_E_C_N_O_ FROM "+cTabSZ2+" SZ2T "+CRLF
	cQuery += "	    	  WHERE SZ2T.D_E_L_E_T_     = ''"+CRLF
	cQuery += "	 			AND SZ2T.Z2_FILIAL = ' '"+CRLF
	cQuery += "	 	 		AND SZ2T.Z2_CODEMP = '01' "+CRLF
	cQuery += "	 	 		AND SE2.E2_PREFIXO = SZ2T.Z2_E2PRF"+CRLF
	cQuery += "	 	 		AND SE2.E2_NUM     = SZ2T.Z2_E2NUM "+CRLF
	cQuery += "	 	 		AND SE2.E2_PARCELA = SZ2T.Z2_E2PARC"+CRLF
	cQuery += "	 	 		AND SE2.E2_TIPO    = SZ2T.Z2_E2TIPO"+CRLF
	cQuery += "	 	 		AND SE2.E2_FORNECE = SZ2T.Z2_E2FORN"+CRLF
	cQuery += "	 	 		AND SE2.E2_LOJA    = SZ2T.Z2_E2LOJA"+CRLF
	cQuery += "	 	 		AND SZ2T.Z2_STATUS  = 'S'"+CRLF
	cQuery += "	 		 ORDER BY SZ2T.R_E_C_N_O_)"+CRLF

	cQuery += "  LEFT JOIN "+cTabCTT+" CTT ON CTT.D_E_L_E_T_=''"+CRLF
	cQuery += "    AND CTT.CTT_FILIAL = '"+xFilial("CTT")+"' "+CRLF
	cQuery += "    AND CTT.CTT_CUSTO  = SD1.D1_CC"+CRLF

	cQuery += "  LEFT JOIN "+cTabSB1+" SB1 ON SB1.D_E_L_E_T_=''"+CRLF
	cQuery += "    AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "+CRLF
	cQuery += "    AND SB1.B1_COD    = SD1.D1_COD"+CRLF


	cQuery += "	 WHERE SE2.D_E_L_E_T_ = '' "+ CRLF
	cQuery +=  "  AND E2_FILIAL = '"+xFilial("SE2")+"' "+CRLF

	cQuery +=  "  AND E2_VENCREA = '"+xVencreal+"' "+CRLF

Next

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  * " + CRLF
cQuery += "  ,ISNULL(D1_XXHIST,E2_HIST) AS HIST"+CRLF
cQuery += "  FROM RESUMO " + CRLF
cQuery += " ORDER BY EMPRESA,E2_PORTADO,FORMPGT,E2_FORNECE" + CRLF

//u_LogMemo("RESTTITCP.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySE2,.T.,.T.)

Return Nil
