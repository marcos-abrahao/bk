#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} RestTitCR
    REST Titulos do Contas a Receber
	https://datatables.net/examples/api/row_details.html
    @type  REST
    @author Marcos B. Abrahão
    @since 09/05/2024
    @version 12.2310
/*/

WSRESTFUL RestTitCR DESCRIPTION "Rest Titulos do Contas a Receber"

	WSDATA mensagem     AS STRING
	WSDATA empresa      AS STRING
	WSDATA filial       AS STRING
	WSDATA vencreal     AS STRING
	WSDATA e1recno 		AS STRING
	WSDATA banco 		AS STRING
	WSDATA userlib 		AS STRING OPTIONAL
	WSDATA acao 		AS STRING

	WSMETHOD GET LISTCR;
		DESCRIPTION "Listar Títulos a Receber";
		WSSYNTAX "/RestTitCR/v0";
		PATH  "/RestTitCR/v0";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET CONSE1;
		DESCRIPTION "Retorna dados do Título";
		WSSYNTAX "/RestTitCR/v6";
		PATH "/RestTitCR/v6";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET BROWCR;
		DESCRIPTION "Browse Contas a Receber como página HTML";
		WSSYNTAX "/RestTitCR/v2";
		PATH "/RestTitCR/v2";
		TTALK "v1";
		PRODUCES TEXT_HTML

	WSMETHOD GET PLANCR;
		DESCRIPTION "Retorna planilha excel da tela por meio do método FwFileReader().";
		WSSYNTAX "/RestTitCR/v5";
		PATH "/RestTitCR/v5";
		TTALK "v1"

	WSMETHOD PUT STATUS;
		DESCRIPTION "Alterar o status do titulo a Receber" ;
		WSSYNTAX "/RestTitCR/v3";
		PATH "/RestTitCR/v3";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL


//v3
WSMETHOD PUT STATUS QUERYPARAM empresa,e1recno,userlib,acao WSREST RestTitCR 

Local cJson			:= Self:GetContent()   
Local lRet			:= .T.
Local oJson			As Object
Local aParams		As Array
Local cMsg			As Char

::setContentType('application/json')

oJson := JsonObject():New()
oJson:FromJSON(cJson)

If u_BkAvPar(::userlib,@aParams,@cMsg)

	lRet := fStatus(::empresa,::e1recno,::acao,@cMsg)

EndIf

oJson['liberacao'] := StrIConv(cMsg, "CP1252", "UTF-8")

cRet := oJson:ToJson()

FreeObj(oJson)
// CORS
Self:SetHeader("Access-Control-Allow-Origin", "*")

Self:SetResponse(cRet)
  
Return lRet



Static Function fStatus(empresa,e1recno,acao,cMsg)
Local lRet 		:= .F.
Local cQuery	:= ""
Local cTabSE1	:= "SE1"+empresa+"0"
Local cQrySE1	:= GetNextAlias()
Local cNum		:= ""

Default cMsg	:= ""
Default cMotivo := ""

Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

cQuery := "SELECT "
cQuery += "  SE1.E1_XXTPPRV,"
cQuery += "  SE1.D_E_L_E_T_ AS E1DELET,"
cQuery += "  SE1.E1_NUM "
cQuery += " FROM "+cTabSE1+" SE1 "
cQuery += " WHERE SE1.R_E_C_N_O_ = "+e1recno

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySE1,.T.,.T.)

// E1_XXTPPRV: 0=Sem Previsao;1=Aguardando Previsao;2=Previsao Informada

cNum := (cQrySE1)->E1_NUM
Do Case
	Case (cQrySE1)->(Eof()) 
		cMsg:= "não encontrado"
	Case (cQrySE1)->E1DELET = '*'
		cMsg:= "foi excluído"
	OtherWise 
		// Alterar o Status
		cMsg   := acao
		cQuery := "UPDATE "+cTabSE1+CRLF
		cQuery += "  SET E1_XXTPPRV = '"+SUBSTR(acao,1,1)+"',"+CRLF
		cQuery += "      E1_XXOPER = '"+__cUserId+"'"+CRLF
		cQuery += " FROM "+cTabSE1+" SE1"+CRLF
		cQuery += " WHERE SE1.R_E_C_N_O_ = "+e1recno+CRLF

		If TCSQLExec(cQuery) < 0 
			cMsg := "Erro: "+TCSQLERROR()
		Else
			lRet := .T.
		EndIf
EndCase

cMsg := cNum+" "+cMsg

u_MsgLog("RESTTitCR",cMsg)

(cQrySE1)->(dbCloseArea())

Return lRet


// v5
WSMETHOD GET PLANCR QUERYPARAM empresa,vencreal WSREST RestTitCR
	Local cProg 	:= "RestTitCR"
	Local cTitulo	:= "Contas a Receber WEB"
	Local cDescr 	:= "Exportação Excel do C.Receber Web"
	Local cVersao	:= "15/05/2024"
	Local oRExcel	AS Object
	Local oPExcel	AS Object

    Local cFile  	:= ""
	Local cName  	:= "" //Decode64(self:documento)
	Local cFName 	:= ""
    Local oFile  	AS Object

	Local cQrySE1	:= GetNextAlias()

	u_MsgLog(cProg,cTitulo+" "+self:vencreal)

	// Query para selecionar os Títulos a Receber
	TmpQuery(cQrySE1,self:empresa,self:vencreal)


	// Definição do Arq Excel
	oRExcel := RExcel():New(cProg)
	oRExcel:SetTitulo(cTitulo)
	oRExcel:SetVersao(cVersao)
	oRExcel:SetDescr(cDescr)

	// Definição da Planilha 1
	oPExcel:= PExcel():New(cProg,cQrySE1)
	oPExcel:SetTitulo("Empresa: "+self:empresa+" - Vencimento: "+DTOC(STOD(self:vencreal)))

	oPExcel:AddCol("EMPRESA","EMPRESA","Empresa","")
	oPExcel:AddCol("TITULO" ,"(E1_PREFIXO+E1_NUM+E1_PARCELA)","Título","")
	oPExcel:AddCol("Cliente","A1_NOME","Cliente","A1_NOME")
	oPExcel:AddCol("VENC","STOD(E1_VENCREA)","Vencto","E1_VENCREA")
	oPExcel:AddCol("PEDIDO","E1_PEDIDO","Pedido","")
	oPExcel:AddCol("VALOR","E1_VALOR","Valor","E1_VALOR")
	oPExcel:AddCol("SALDO","SALDO","Saldo","E1_SALDO")
	//oPExcel:AddCol("STATUS","u_DE2XXPgto(E1_XXTPPRV)")
	oPExcel:AddCol("HIST","HIST","Histórico","E1_XXHIST")
	oPExcel:AddCol("OPER","UsrRetName(E1_XXOPER)","Operador","")

	oPExcel:GetCol("PEDIDO"):SetHAlign("C")
	oPExcel:GetCol("HIST"):SetWrap(.T.)
	oPExcel:GetCol("VALOR"):SetTotal(.T.)

	oPExcel:GetCol("SALDO"):SetDecimal(2)
	oPExcel:GetCol("SALDO"):SetTotal(.T.)

	oPExcel:GetCol("STATUS"):SetHAlign("C")
	oPExcel:GetCol("STATUS"):SetTamCol(12)
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'P'}	,"FF0000","",,,.T.)	// Vermelho
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,3) == 'Con'},"008000","",,,.T.)	// Verde
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'E'}	,"FFA500","",,,.T.)	// Laranja
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,3) == 'Com'},"0000FF","",,,.T.)	// Azul
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'D'}	,"000000","",,,.T.)	// Preto

	// Adiciona a planilha
	oRExcel:AddPlan(oPExcel)

	// Cria arquivo Excel
	cFName:= oRExcel:RunCreate()

	// Remove pastas do nome do arquivo
	cName:= SubStr(cFName,Rat("\",cFName)+1)

	(cQrySE1)->(dbCloseArea())

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

		// Deletar o arquivo após o fechamento
		Ferase(cFName)

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
WSMETHOD GET LISTCR QUERYPARAM empresa,vencreal,userlib WSREST RestTitCR
Local aListCR 		:= {}
Local cQrySE1       := GetNextAlias()
Local cJsonCli      := ''
Local lRet 			:= .T.
Local oJsonTmp	 	:= JsonObject():New()
Local aParams      	As Array
Local cMsg         	As Character
Local cNumTit 		:= ""

//u_MsgLog("RESTTITCR",VarInfo("vencreal",self:vencreal))

If !u_BkAvPar(::userlib,@aParams,@cMsg)
  oJsonTmp['liberacao'] := cMsg
  cRet := oJsonTmp:ToJson()
  FreeObj(oJsonTmp)
  //Retorno do servico
  ::SetResponse(cRet)
  Return lRet:= .T.
EndIf

// Usuários que podem executar alguma ação
//lPerm := u_InGrupo(__cUserId,"000000/000005/000007/000038")

// Query para selecionar os Títulos a Receber
TmpQuery(cQrySE1,self:empresa,self:vencreal)

//-------------------------------------------------------------------
// Alimenta array de Pré-notas
//-------------------------------------------------------------------
Do While ( cQrySE1 )->( ! Eof() )

	aAdd( aListCR , JsonObject():New() )

	nPos	:= Len(aListCR)
	cNumTit	:= (cQrySE1)->(E1_PREFIXO+E1_NUM+E1_PARCELA)
	cNumTit := STRTRAN(cNumTit," ","&nbsp;")

	aListCR[nPos]['EMPRESA']	:= (cQrySE1)->EMPRESA
	aListCR[nPos]['TIPO']     	:= (cQrySE1)->E1_TIPO
	aListCR[nPos]['TITULO']     := cNumTit
	aListCR[nPos]['CLIENTE'] 	:= TRIM((cQrySE1)->A1_NOME)
	aListCR[nPos]['VENC'] 		:= DTOC(STOD((cQrySE1)->E1_VENCREA))
	aListCR[nPos]['EMISSAO'] 	:= DTOC(STOD((cQrySE1)->E1_EMISSAO))
	aListCR[nPos]['COMPET']		:= TRIM((cQrySE1)->C5_XXCOMPM)
	aListCR[nPos]['PEDIDO']		:= TRIM((cQrySE1)->E1_PEDIDO)
	aListCR[nPos]['VALOR']      := TRANSFORM((cQrySE1)->E1_VALOR,"@E 999,999,999.99")
	aListCR[nPos]['SALDO'] 	    := TRANSFORM((cQrySE1)->SALDO,"@E 999,999,999.99")
	aListCR[nPos]['STATUS']		:= (cQrySE1)->(E1_XXTPPRV)
	aListCR[nPos]['HIST']		:= StrIConv(ALLTRIM((cQrySE1)->E1_XXHIST), "CP1252", "UTF-8") 
	aListCR[nPos]['OPER']		:= (cQrySE1)->(UsrRetName(E1_XXOPER)) //(cQrySE1)->(FwLeUserLg('E1_USERLGA',1))
	aListCR[nPos]['E1RECNO']	:= STRZERO((cQrySE1)->E1RECNO,7)

	(cQrySE1)->(DBSkip())

EndDo

( cQrySE1 )->( DBCloseArea() )

oJsonTmp	 := aListCR

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


// /v6
WSMETHOD GET CONSE1 QUERYPARAM empresa,e1recno,userlib WSREST RestTitCR

Local oJsonPN	:= JsonObject():New()
Local cRet		:= ""
Local cQuery	:= ""
Local cTabSE1	:= "SE1"+self:empresa+"0"
Local cTabSA2	:= "SA2"+self:empresa+"0"
Local cTabSF2	:= "SF2"+self:empresa+"0"
Local cQrySE1	:= GetNextAlias()
Local aEmpresas	As Array
Local aParams	As Array
Local cMsg		As Character
// Chave Z2
Local cPrefixo	:= ""
Local cNum		:= ""
Local cParcela	:= ""
Local cTipo		:= ""
Local cCliente	:= ""
Local cLoja		:= ""

aEmpresas := u_BKGrpFat()
u_BkAvPar(::userlib,@aParams,@cMsg)

cQuery := "SELECT " + CRLF
cQuery += "	  E1_TIPO"+CRLF
cQuery += "	 ,E1_PREFIXO"+CRLF
cQuery += "	 ,E1_NUM"+CRLF
cQuery += "	 ,E1_PARCELA"+CRLF
cQuery += "	 ,E1_CLIENTE"+CRLF
cQuery += "	 ,E1_PEDIDO"+CRLF
cQuery += "	 ,E1_LOJA"+CRLF
cQuery += "	 ,E1_XXHIST"+CRLF
cQuery += "	 ,E1_USERLGA"+CRLF 
cQuery += "	 ,E1_EMISSAO"+CRLF
cQuery += "	 ,E1_BAIXA"+CRLF
cQuery += "	 ,E1_VENCREA"+CRLF
cQuery += "	 ,E1_VALOR"+CRLF
cQuery += "	 ,E1_XXOPER"+CRLF
cQuery += "	 ,SE1.R_E_C_N_O_ AS E1RECNO"+CRLF
cQuery += "	 ,A1_NOME"+CRLF
cQuery += "	 ,A1_PESSOA"+CRLF
cQuery += "	 ,A1_CGC"+CRLF
cQuery += "	 ,(CASE WHEN E1_SALDO = E1_VALOR "+CRLF
cQuery += "	 		THEN E1_VALOR + E1_ACRESC - E1_DECRESC"+CRLF
cQuery += "	 		ELSE E1_SALDO END) AS SALDO"+CRLF

cQuery += "	 FROM "+cTabSE1+" SE1 "+CRLF

cQuery += "	 LEFT JOIN "+cTabSF2+" SF2 ON"+CRLF
cQuery += "	 	SE1.E1_FILIAL      = SF2.F2_FILIAL"+CRLF
cQuery += "	 	AND SE1.E1_NUM     = SF2.F2_DOC "+CRLF
cQuery += "	 	AND SE1.E1_PREFIXO = SF2.F2_SERIE"+CRLF
cQuery += "	 	AND SE1.E1_CLIENTE = SF2.F2_CLIENTE"+CRLF
cQuery += "	 	AND SE1.E1_LOJA    = SF2.F2_LOJA"+CRLF
cQuery += "	 	AND SF1.D_E_L_E_T_ = ''"+CRLF

cQuery += "	 LEFT JOIN "+cTabSA2+"  SA2 ON"+CRLF
cQuery += "	 	SA1.A1_FILIAL      = '  '"+CRLF
cQuery += "	 	AND SE1.E1_CLIENTE = SA1.A1_COD"+CRLF
cQuery += "	 	AND SE1.E1_LOJA    = SA1.A1_LOJA"+CRLF
cQuery += "	 	AND SA1.D_E_L_E_T_ = ''"+CRLF

cQuery += "WHERE SE1.R_E_C_N_O_ = "+self:e1recno + CRLF

//u_LogMemo("RESTTITCR-E2.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySE1,.T.,.T.)

dbSelectArea(cQrySE1)
dbGoTop()
cPrefixo	:= (cQrySE1)->E1_PREFIXO
cNum		:= (cQrySE1)->E1_NUM
cParcela	:= (cQrySE1)->E1_PARCELA
cTipo		:= (cQrySE1)->E1_TIPO
cCliente	:= (cQrySE1)->E1_CLIENTE
cLoja		:= (cQrySE1)->E1_LOJA

oJsonPN['USERNAME']		:= cUserName
oJsonPN['EMPRESA']		:= aEmpresas[aScan(aEmpresas,{|x| x[1] == self:empresa }),2]
oJsonPN['E1_PREFIXO']	:= (cQrySE1)->E1_PREFIXO
oJsonPN['E1_NUM']		:= (cQrySE1)->E1_NUM
oJsonPN['A1_NOME']		:= (cQrySE1)->A1_NOME
oJsonPN['E1_EMISSAO']	:= DTOC(STOD((cQrySE1)->E1_EMISSAO))
oJsonPN['E1_VENCREA']	:= DTOC(STOD((cQrySE1)->E1_VENCREA))
//oJsonPN['E1_XXUSER']	:= UsrRetName((cQrySE1)->E1_XXUSER)
oJsonPN['E1_XXHIST']		:= (cQrySE1)->E1_XXHIST
oJsonPN['LOTE']			:= (cQrySE1)->E1_XXLOTEB


(cQrySE1)->(dbCloseArea())

cRet := oJsonPN:ToJson()

FreeObj(oJsonPN)

//Retorno do servico
Self:SetHeader("Access-Control-Allow-Origin", "*")
Self:SetResponse(cRet)

return .T.


// /v2
WSMETHOD GET BROWCR QUERYPARAM empresa,vencreal,userlib WSREST RestTitCR

Local cHTML		as char
Local cDropEmp	as char
Local aEmpresas := u_BKGrpFat()
Local nE 		:= 0

//u_MsgLog(,"BROWCR/1")

BEGINCONTENT var cHTML

<!doctype html>
<html lang="pt-BR">
<head>
<!-- Required meta tags -->
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Bootstrap CSS -->
<!-- https://datatables.net/manual/styling/bootstrap5   examples-->
<link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/2.0.2/css/dataTables.bootstrap5.min.css" rel="stylesheet">

<title>Títulos Contas a Receber #datavenc# #NomeEmpresa#</title>
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
</style>
</head>
<body>
<nav class="navbar navbar-dark bg-mynav fixed-top justify-content-between">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Títulos a Receber - #cUserName#</a> 

	<div class="btn-group">
		<button type="button" class="btn btn-dark dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">
			#NomeEmpresa#
		</button>
		<ul class="dropdown-menu dropdown-menu-dark">
			#DropEmpresas#
		</ul>
	</div>

	<div class="btn-group">
		<button type="button" class="btn btn-dark" aria-label="Excel" onclick="Excel()">Excel</button>
		<button type="button" class="btn btn-dark" aria-label="PDF" onclick="HtmlPdf()">PDF</button>
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
<table id="tableSE1" class="table">
<thead>
<tr>
<th scope="col"></th>
<th scope="col">Empresa</th>
<th scope="col">Tipo</th>
<th scope="col">Título</th>
<th scope="col">Cliente</th>
<th scope="col">Vencto</th>
<th scope="col">Emissão</th>
<th scope="col">Pedido</th>
<th scope="col" style="text-align:center;">Compet</th>
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
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col" style="text-align:center;"></th>
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


<!-- Modal -->
<div id="E2Modal" class="modal fade" role="dialog">
   <div class="modal-dialog modal-fullscreen">
     <!-- Conteúdo do modal-->
     <div class="modal-content">
       <!-- Cabeçalho do modal -->
       <div class="modal-header bk-colors">
         <h4 id="titE2Modal" class="modal-title">Título do modal</h4>
         <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                 <span aria-hidden="true">&times;</span>
         </button>
       </div>
       <!-- Corpo do modal -->
       <div class="modal-body">

          <form class="row g-3 font-condensed">
            
           <div class="col-md-1">
             <label for="E1Prefixo" class="form-label">Prefixo</label>
             <input type="text" class="form-control form-control-sm" id="E1Prefixo" value="#E1Prefixo#" readonly="">
           </div>
          <div class="col-md-2">
             <label for="E1Num" class="form-label">Título</label>
             <input type="text" class="form-control form-control-sm" id="E1Num" value="#E1Num#" readonly="">
           </div>
           <div class="col-md-2">
             <label for="E1NomCLI" class="form-label">Cliente</label>
             <input type="text" class="form-control form-control-sm" id="E1NomCLI" value="#E1NomCLI#" readonly="">
           </div>
           <div class="col-md-1">
             <label for="E1Emissao" class="form-label">Emissão</label>
             <input type="text" class="form-control form-control-sm" id="E1Emissao" value="#E1Emissao#" readonly="">
           </div>
           <div class="col-md-1">
             <label for="E1VencRea" class="form-label">Vencimento</label>
             <input type="text" class="form-control form-control-sm" id="E1VencRea" value="#E1VencRea#" readonly="">
           </div>

           <div class="col-md-2">
             <label for="E1User" class="form-label">Usuário</label>
             <input type="text" class="form-control form-control-sm" id="E1User" value="#E1User#" readonly="">
           </div>

           <div class="col-md-1">
             <label for="E1Pedido" class="form-label">Lote<E1_PEDIDOel>
             <input type="text" class="form-control form-control-sm" id="E1Pedido" value="#E1Pedido#" readoE1_PEDIDO"">
           </div>

           <div class="col-md-8">
             <label for="E1Hist" class="form-label">Histórico CR</label>
			 <textarea class="form-control form-control-sm" id="E1Hist" rows="1" value="#E1Hist#" readonly=""></textarea>
           </div>

           <div class="col-md-8">
             <label for="D1Hist" class="form-label">Histórico Doc de Entrada</label>
			 <textarea class="form-control form-control-sm" id="D1Hist" rows="4" value="#D1Hist#" readonly=""></textarea>
           </div>

			<div class="container">
				<div class="table-responsive-sm">
				<table class="table ">
					<thead>
						<tr>
							<th scope="col">Produto</th>
							<th scope="col">Descrição</th>
							<th scope="col">Centro de Custo</th>
							<th scope="col" style="text-align:right;">Valor</th>
						</tr>
					</thead>
					<tbody id="E2Table">
						<tr>
							<th scope="row" colspan="4" style="text-align:center;">Carregando itens...</th>
						</tr>
					</tbody>

					<tfoot id="E2Foot">
						<th scope="row" colspan="4" style="text-align:right;">Total Geral</th>
					</tfoot>

				</table>
				</div>
			</div>

            <div class="col-12" id="anexosE1">
				<!-- <button type="submit" class="btn btn-primary">Sign in</button> -->
            </div>

          </form>

       </div>
        <!-- Rodapé do modal-->
        <div class="modal-footer">
         <button type="button" class="btn btn-outline-danger" data-bs-dismiss="modal">Fechar</button>
       </div>
     </div>
   </div>
</div>


<!-- Optional JavaScript -->
<!-- jQuery first, then Popper.js, then Bootstrap JS -->
<!-- https://datatables.net/examples/styling/bootstrap5.html -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<!-- JavaScript Bundle with Popper -->
<!-- https://getbootstrap.com/docs/5.3/getting-started/download/ -->
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js" integrity="sha384-I7E8VVD/ismYTF4hNIPjVp/Zjvgyol6VFvRkX/vR+Vc4jQkC+hVqc2pM8ODewa9r" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js" integrity="sha384-0pUGZvbkm6XF6gxjEnlmuGrJXVbNuzT9qBBavbLwCsOGabYfZo0T0to5eqruptLy" crossorigin="anonymous"></script>

<!-- https://datatables.net/ -->
<script src="https://cdn.datatables.net/2.0.2/js/dataTables.min.js"></script>
<script src="https://cdn.datatables.net/2.0.2/js/dataTables.bootstrap5.min.js"></script>

<!-- Buttons -->
<!-- https://cdn.datatables.net/buttons/ -->
<script src="https://cdn.datatables.net/buttons/3.0.1/js/dataTables.buttons.min.js"></script>

<!-- https://cdnjs.com/libraries/jszip -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>

<!-- https://cdnjs.com/libraries/pdfmake -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.10/pdfmake.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.10/vfs_fonts.js"></script>

<!-- https://cdn.datatables.net/buttons -->
<script src="https://cdn.datatables.net/buttons/3.0.1/js/buttons.html5.min.js"></script>

<script>

async function getCRs() {
	let url = '#iprest#/RestTitCR/v0?empresa=#empresa#&vencreal=#vencreal#&userlib=#userlib#'
		try {
		let res = await fetch(url);
			return await res.json();
			} catch (error) {
		console.log(error);
			}
		}


async function loadTable() {
let titulos = await getCRs();
let trHTML = '';
let nlin = 0;
let ccbtn = '';
let cbtnids = '';
let cbtne1 = '';
let anexos = '';

if (Array.isArray(titulos)) {
	titulos.forEach(object => {
	let cStatus  = object['STATUS'];
	let cEmpresa = object['EMPRESA'].substring(0,2);

	nlin += 1;
	cbtne1 = 'btnz2'+nlin;

	if (cStatus == ' '){
	 ccbtn = 'dark';
	} else if (cStatus == '0'){
	 ccbtn = 'danger';
	} else if (cStatus == '1'){
	 ccbtn = 'warning';
	} else if (cStatus == '2'){
	 ccbtn = 'primary';
	}

	trHTML += '<tr>';
	trHTML += '<td></td>';
	trHTML += '<td>'+object['EMPRESA']+'</td>';
	trHTML += '<td>'+object['TIPO']+'</td>';
	trHTML += '<td>'+object['TITULO']+'</td>';
	trHTML += '<td>'+object['CLIENTE']+'</td>';
	trHTML += '<td>'+object['VENC']+'</td>';
	trHTML += '<td>'+object['EMISSAO']+'</td>';
	trHTML += '<td>'+object['PEDIDO']+'</td>';
	trHTML += '<td>'+object['COMPET']+'</td>';

	trHTML += '<td align="right">'+object['VALOR']+'</td>';
	trHTML += '<td align="right">'+object['SALDO']+'</td>';

	cbtnids = 'btnac'+nlin;

	trHTML += '<td>'
		// Botão para mudança de status
		trHTML += '<div class="btn-group">'
			trHTML += '<button type="button" id="'+cbtnids+'" class="btn btn-outline-'+ccbtn+' dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">'
			trHTML += object['STATUS']
			trHTML += '</button>'

			trHTML += '<div class="dropdown-menu" aria-labelledby="dropdownMenu2">'
			trHTML += '<button class="dropdown-item" type="button" onclick="ChgStatus(\''+cEmpresa+'\',\''+object['E1RECNO']+'\',\'#userlib#\',\' \','+'\''+cbtnids+'\')">Aguardando Recebimento</button>';
			trHTML += '<button class="dropdown-item" type="button" onclick="ChgStatus(\''+cEmpresa+'\',\''+object['E1RECNO']+'\',\'#userlib#\',\'0\','+'\''+cbtnids+'\')">Sem Previsao</button>';
			trHTML += '<button class="dropdown-item" type="button" onclick="ChgStatus(\''+cEmpresa+'\',\''+object['E1RECNO']+'\',\'#userlib#\',\'1\','+'\''+cbtnids+'\')">Aguardando Previsao</button>';
			trHTML += '<button class="dropdown-item" type="button" onclick="ChgStatus(\''+cEmpresa+'\',\''+object['E1RECNO']+'\',\'#userlib#\',\'2\','+'\''+cbtnids+'\')">Previsao Informada</button>';
		trHTML += '</div>'
	trHTML += '</td>'

	trHTML += '<td>'+object['HIST']+'</td>';

	trHTML += '<td>'+object['OPER']+'</td>';

	trHTML += '</tr>';
	});
} else {
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="13" style="text-align:center;">'+titulos['liberacao']+'</th>';
    trHTML += '</tr>';   
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="13" style="text-align:center;">Faça login novamente no sistema Protheus</th>';
    trHTML += '</tr>';   
}
document.getElementById("mytable").innerHTML = trHTML;


tableSE1 = $('#tableSE1').DataTable({
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
        { data: 'Tipo' },
        { data: 'Título' },
        { data: 'Cliente' },
        { data: 'Vencto' },
        { data: 'Emissão' },
        { data: 'Pedido' },
        { data: 'Compet' },
        { data: 'Valor' },
        { data: 'Saldo' },
        { data: 'Status' },
        { data: 'Histórico' },
        { data: 'Operador' },
  ],
  "columnDefs": [
        {
            target: 14,
            visible: false,
            searchable: false
        }
  ],
  "order": [[1,'asc']]
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
$('#tableSE1 tbody').on('click', 'td.dt-control', function () {
    var tr = $(this).closest('tr');
    var row = tableSE1.row(tr);
 
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


async function getE1(empresa,e1recno,userlib) {
let urlE1 = '#iprest#/RestTitCR/v6?empresa='+empresa+'&e1recno='+e1recno+'&userlib='+userlib;
	try {
	let res = await fetch(urlE1);
		return await res.json();
		} catch (error) {
	console.log(error);
		}
	}

async function showE1(empresa,e1recno,userlib,cbtne1) {

document.getElementById(cbtne1).disabled = true;
document.getElementById(cbtne1).innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>';

let dadosE1 = await getE1(empresa,e1recno,userlib);
let itens = '';
let i = 0;
let foot = '';
let anexos = '';
let inpE = '';
let iCheck = '';
let cClick = 'libdoc';

document.getElementById('E1Prefixo').value = dadosE1['E1_PREFIXO'];
document.getElementById('E1Num').value = dadosE1['E1_NUM'];
document.getElementById('E1NomCLI').value = dadosE1['A1_NOME'];
document.getElementById('E1Emissao').value = dadosE1['E1_EMISSAO'];
document.getElementById('E1VencRea').value = dadosE1['E1_VENCREA'];
document.getElementById('E1User').value = dadosE1['E1_XXUSER'];
document.getElementById('E1Hist').value = dadosE1['E1_XXHIST'];
document.getElementById('E1Pedido').value = dadosE1['E1_PEDIDO'];

if (Array.isArray(dadosE1.DADOSD1)) {
   dadosE1.DADOSD1.forEach(object => {
    i++
	itens += '<tr>';
	itens += '<td>'+object['D1_COD']+'</td>';	
	itens += '<td>'+object['B1_DESC']+'</td>';
	itens += '<td>'+object['D1_CC']+'</td>';
	itens += '<td align="right">'+object['D1_VALOR']+'</td>';
	itens += '</tr>';
  })
}

document.getElementById("E2Table").innerHTML = itens;
foot = '<th scope="row" colspan="8" style="text-align:right;">'+dadosE1['D1_TOTAL']+'</th>'
document.getElementById("E2Foot").innerHTML = foot;

$("#titE2Modal").text('Título do Contas a Receber - Empresa: '+dadosE1['EMPRESA'] + ' - Usuário: '+dadosE1['USERNAME']);
$('#E2Modal').modal('show');
$('#E2Modal').on('hidden.bs.modal', function () {
	location.reload();
	})
}


async function ChgStatus(empresa,e1recno,userlib,acao,btnids){
let resposta = ''
let dataObject = {	liberacao:'ok' };
let cbtn = '';
	
fetch('#iprest#/RestTitCR/v3?empresa='+empresa+'&e1recno='+e1recno+'&userlib='+userlib+'&acao='+acao, {
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
		if (acao == ' '){
			cbtn = 'Aguardando Recebimento';
		} else if (acao == '0'){
			cbtn = 'Sem Previsao';
		} else if (acao == '1'){
			cbtn = 'Aguardando Previsao';
		} else {
			cbtn = 'Previsao Informada ';
		}
		document.getElementById(btnids).textContent = cbtn;
	})
}

async function Excel(){
let newvenc = document.getElementById("DataVenc").value;
let newvamd  = newvenc.substring(0, 4)+newvenc.substring(5, 7)+newvenc.substring(8, 10)
window.open("#iprest#/RestTitCR/v5?empresa=#empresa#&vencreal="+newvamd+'&userlib=#userlib#',"_self");
}


async function getUrlTmp(url1) {
	try {
	let res = await fetch(url1);
		return await res.json();
		} catch (error) {
	console.log(error);
		}
	}

async function HtmlPdf(){
let newvenc = document.getElementById("DataVenc").value;
let newvamd  = newvenc.substring(0, 4)+newvenc.substring(5, 7)+newvenc.substring(8, 10)
let url1 = '#iprest#/RestTitCR/v7?empresa=#empresa#&vencreal='+newvamd+'&userlib=#userlib#';
let urlT = await getUrlTmp(url1);
let curlT = urlT[0].URLTMP;
window.open(curlT,"_self");

}

async function AltVenc(){
let newvenc = document.getElementById("DataVenc").value;
let newvamd  = newvenc.substring(0, 4)+newvenc.substring(5, 7)+newvenc.substring(8, 10)
window.open("#iprest#/RestTitCR/v2?empresa=#empresa#&vencreal="+newvamd+'&userlib=#userlib#',"_self");
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
	cDropEmp += '<li><a class="dropdown-item" href="'+u_BkRest()+'/RestTitCR/v2?empresa='+aEmpresas[nE,1]+'&vencreal='+self:vencreal+'&userlib='+self:userlib+'">'+aEmpresas[nE,1]+'-'+aEmpresas[nE,2]+'</a></li>'+CRLF
Next
cDropEmp +='<li><hr class="dropdown-divider"></li>'+CRLF
cDropEmp +='<li><a class="dropdown-item" href="'+u_BkRest()+'/RestTitCR/v2?empresa=Todas&vencreal='+self:vencreal+'&userlib='+self:userlib+'">Todas</a></li>'+CRLF

cHtml := STRTRAN(cHtml,"#DropEmpresas#",cDropEmp)
// <-- Seleção de Empresas

//StrIConv( cHtml, "UTF-8", "CP1252")
//DecodeUtf8(cHtml)
cHtml := StrIConv( cHtml, "CP1252", "UTF-8")

u_MsgLog(,"BROWCR/2")
//If ::userlib == '000000'
	Memowrite("\tmp\cr.html",cHtml)
//EndIf
//u_MsgLog("RESTTITCR",__cUserId)

Self:SetHeader("Access-Control-Allow-Origin", "*")
self:setResponse(cHTML)
self:setStatus(200)

return .T.


// Montagem da Query
Static Function TmpQuery(cQrySE1,xEmpresa,xVencreal)

Local aEmpresas		:= {}
Local aGrupoBK 		:= {}
Local cEmpresa		:= ""
Local cNomeEmp		:= ""
Local cTabSE1		:= ""
Local cTabSF2		:= ""
Local cTabSC5		:= ""
Local cTabSA1		:= ""
Local cQuery		:= ""
Local nE			:= 0
Local cEmpr 		:= ""
Local bBlock
Local aBinds		:= {}
Local lRet 			:= .T.

aGrupoBK := u_BKGrpFat()
nE := aScan(aGrupoBK,{|x| x[1] == SUBSTR(xEmpresa,1,2) })
If nE > 0
	aEmpresas := {aGrupoBK[nE]}
Else
	aEmpresas := aGrupoBK
EndIf


//cQuery := "WITH RESUMO AS ( " + CRLF

For nE := 1 To Len(aEmpresas)
	cEmpr 	:= aEmpresas[nE,1]
	cTabSE1 := "SE1"+cEmpr+"0"
	cTabSA1 := "SA1"+cEmpr+"0"
	cTabSF2 := "SF2"+cEmpr+"0"
	cTabSC5 := "SC5"+cEmpr+"0"

	cEmpresa := cEmpr
	cNomeEmp := aEmpresas[nE,3]

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT "+CRLF
	cQuery += "	  '"+cEmpresa+"-"+cNomeEmp+"' AS EMPRESA"+CRLF
	cQuery += "	 ,E1_TIPO"+CRLF
	cQuery += "	 ,E1_PREFIXO"+CRLF
	cQuery += "	 ,E1_NUM"+CRLF
	cQuery += "	 ,E1_PARCELA"+CRLF
	cQuery += "	 ,E1_CLIENTE"+CRLF
	cQuery += "	 ,E1_LOJA"+CRLF
	cQuery += "	 ,E1_XXHIST"+CRLF
	cQuery += "	 ,E1_VENCREA"+CRLF
	cQuery += "	 ,E1_EMISSAO"+CRLF
	cQuery += "	 ,E1_VALOR"+CRLF
	cQuery += "	 ,E1_PEDIDO"+CRLF
	cQuery += "	 ,E1_XXTPPRV"+CRLF
	cQuery += "	 ,E1_XXOPER"+CRLF
	cQuery += "	 ,SE1.R_E_C_N_O_ AS E1RECNO"+CRLF
	cQuery += "	 ,A1_NOME"+CRLF
	//cQuery += "	 ,A1_PESSOA"+CRLF
	//cQuery += "	 ,A1_CGC"+CRLF
	cQuery += "	 ,(CASE WHEN E1_SALDO = E1_VALOR "+CRLF
	cQuery += "	 		THEN E1_VALOR + E1_ACRESC - E1_DECRESC "+CRLF
	cQuery += "	 		ELSE E1_SALDO END) AS SALDO"+CRLF

	//cQuery += "	 ,F2_USERLGI"+CRLF
	cQuery += "	 ,C5_XXCOMPM"+CRLF

	cQuery += "	 FROM "+cTabSE1+" SE1 "+CRLF
	/*
	cQuery += "	 LEFT JOIN "+cTabSF2+" SF2 ON"+CRLF
	cQuery += "	 	SE1.E1_FILIAL      = SF2.F2_FILIAL "+CRLF
	cQuery += "	 	AND SE1.E1_NUM     = SF2.F2_DOC "+CRLF
	cQuery += "	 	AND SE1.E1_PREFIXO = SF2.F2_SERIE "+CRLF
	cQuery += "	 	AND SE1.E1_CLIENTE = SF2.F2_CLIENTE "+CRLF
	cQuery += "	 	AND SE1.E1_LOJA    = SF2.F2_LOJA "+CRLF
	cQuery += "	 	AND SE1.D_E_L_E_T_ = '' "+CRLF
	*/
	cQuery += "	 LEFT JOIN "+cTabSA1+" SA1 ON"+CRLF
	cQuery += "	 	SA1.A1_FILIAL      = '"+xFilial("SA1")+"'"+CRLF
	cQuery += "	 	AND SE1.E1_CLIENTE = SA1.A1_COD "+CRLF
	cQuery += "	 	AND SE1.E1_LOJA    = SA1.A1_LOJA "+CRLF
	cQuery += "	 	AND SA1.D_E_L_E_T_ = '' "+CRLF

	cQuery += "	 LEFT JOIN "+cTabSC5+" SC5 ON"+CRLF
	cQuery += "	 	SC5.C5_NUM         = SE1.E1_PEDIDO "+CRLF
	cQuery += "	 	AND SC5.D_E_L_E_T_ = '' "+CRLF

	cQuery += "	 WHERE SE1.D_E_L_E_T_ = '' "+ CRLF
	cQuery += "  AND E1_FILIAL = '"+xFilial("SE1")+"' "+CRLF
	cQuery += "  AND E1_STATUS = 'A' "+CRLF
	cQuery += "  AND E1_TIPO IN ('BOL','NF','NDC') "+CRLF
	//cQuery += "  AND E1_VENCREA >= '"+xVencreal+"' "+CRLF
	cQuery += "  AND E1_VENCREA >= ? --"+xVencreal+CRLF
	aAdd(aBinds,xVencreal)
Next
/*
cQuery += ") "+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  * " + CRLF
cQuery += "  FROM RESUMO " + CRLF
cQuery += " ORDER BY EMPRESA,E1_VENCREA,A1_NOME " + CRLF
*/

u_LogMemo("RESTTITCR1.SQL",cQuery)

bBlock := ErrorBlock( { |e| u_LogMemo("RESTTITCR1.SQL",e:Description) } )
BEGIN SEQUENCE
	//dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySE1,.T.,.T.)
	dbUseArea(.T.,"TOPCONN",TCGenQry2(,,cQuery,aBinds),cQrySE1,.T.,.T.)
RECOVER
	lRet := .F.
END SEQUENCE
ErrorBlock(bBlock)

Return lRet
