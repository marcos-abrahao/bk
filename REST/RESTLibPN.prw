#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#Include "Protheus.ch"
#Include "TBICONN.CH"

/*/{Protheus.doc} RestLibPN
    REST para Liberação de Pré-notas de Entrada
    @type  Function
    @author Marcos B. Abrahão
    @since 16/08/2021
    @version 12.1.25
/*/

WSRESTFUL RestLibPN DESCRIPTION "Rest Liberação de Pré-notas de Entrada"

	WSDATA mensagem     AS STRING
	WSDATA empresa      AS STRING
	WSDATA filial       AS STRING
	WSDATA prenota 		AS STRING
	WSDATA userlib 		AS STRING

	WSDATA page         AS INTEGER OPTIONAL
	WSDATA pageSize     AS INTEGER OPTIONAL

	WSMETHOD GET LISTPN;
		DESCRIPTION "Listar Pré-notas de Entrada em aberto";
		WSSYNTAX "/RestLibPN";
		PATH  "/RestLibPN";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET CONSPN;
		DESCRIPTION "Retorna dados Pré-nota";
		WSSYNTAX "/RestLibPN/v1";
		PATH "/RestLibPN/v1";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET BROWPN;
		DESCRIPTION "Browse Pré-notas de Entrada a Liberar como página HTML";
		WSSYNTAX "/RestLibPN/v2";
		PATH "/RestLibPN/v2";
		TTALK "v1";
		PRODUCES TEXT_HTML


	WSMETHOD PUT ;
		DESCRIPTION "Liberação de Pré-notas de Entrada" ;
		WSSYNTAX "/RestLibPN/v3";
		PATH "/RestLibPN/v3";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL


WSMETHOD PUT QUERYPARAM empresa,prenota,userlib,liberacao WSREST RestLibPN

Local cJson        := Self:GetContent()   
Local lRet         := .T.
//	Local lLib         := .T.
//	Local oJson        As Object
//  Local cCatch       As Character  
Local oJson        As Object
Local aParams      As Array
Local cMsg         As String


	//Define o tipo de retorno do servico
	::setContentType('application/json')

	//oJson  := JsonObject():New()
	//cCatch := oJson:FromJSON(cJson)

	oJson := JsonObject():New()
  	oJson:FromJSON(cJson)

	//If cCatch == Nil
	//PrePareContexto(::empresa,::filial)

	If u_BkAvPar(::userlib,@aParams,@cMsg)

		lRet := fLibPN(::empresa,::prenota,@cMsg)

		oJson['liberacao'] := "Pré-nota "+self:prenota+" "+cMsg
	Else
		oJson['liberacao'] := cMsg
	EndIf

	cRet := oJson:ToJson()

  	FreeObj(oJson)

 	Self:SetResponse(cRet)
  
Return lRet


Static Function fLibPN(empresa,prenota,cMsg)
Local lOk 		:= .F.
Local cQuery	:= ""
Local cTabSF1	:= "SF1"+empresa+"0"
Local cQrySF1	:= GetNextAlias()

Set(_SET_DATEFORMAT, 'mm/dd/yyyy')

cQuery := "SELECT SF1.F1_XXLIB,SF1.F1_STATUS,SF1.D_E_L_E_T_ AS F1DELET"+CRLF
cQuery += " FROM "+cTabSF1+" SF1"+CRLF
cQuery += " WHERE SF1.R_E_C_N_O_ = "+prenota+CRLF

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySF1,.T.,.T.)

Do Case
	Case (cQrySF1)->(Eof()) 
		cMsg:= "não encontrada"
	Case (cQrySF1)->F1_STATUS == "B"
		cMsg:= "está bloqueada"
	Case (cQrySF1)->F1_STATUS <> " "
		cMsg:= "não pode ser liberada"
	Case (cQrySF1)->F1_XXLIB $ "AN"
		cQuery := "UPDATE "+cTabSF1
		cQuery += "  SET F1_XXLIB = 'L',"
		cQuery += "      F1_XXULIB = '"+__cUserId+"',"
		cQuery += "      F1_XXDLIB = '"+DtoC(Date())+"-"+SUBSTR(Time(),1,5)+"'"
		cQuery += " FROM "+cTabSF1+" SF1"+CRLF
		cQuery += " WHERE SF1.R_E_C_N_O_ = "+prenota+CRLF

		If TCSQLExec(cQuery) < 0 
			cMsg := "Erro: "+TCSQLERROR()
		Else
			cMsg := "liberada"
			lRet := .T.
		EndIf
	OtherWise 
		cMsg:= "não pode ser liberada por motivo indefinido"
EndCase

(cQrySF1)->(dbCloseArea())

Return lOk


/*/{Protheus.doc} GET / salesorder
Retorna a lista de prenotas.
 
@param 
 Page , numerico, numero da pagina 
 PageSize , numerico, quantidade de registros por pagina
 
@return cResponse , caracter, JSON contendo a lista de Pré-notas
/*/


WSMETHOD GET LISTPN QUERYPARAM userlib, page, pageSize WSREST RestLibPN
Local aEmpresas		:= {}
Local aListSales 	:= {}
Local cQrySF1       := GetNextAlias()
Local cJsonCli      := ''
//Local cWhereSF1   := ""
//Local cWhereSA2   := "%AND SA2.A2_FILIAL = '"+xFilial('SA2')+"'%"
Local cFilSF1		:= ""
Local lRet 			:= .T.
Local nCount 		:= 0
Local nStart 		:= 1
Local nReg 			:= 0
//Local nTamPag 	:= 0
Local oJsonSales 	:= JsonObject():New()

Local aParams      	As Array
Local cMsg         	As String
Local nE			:= 0
Local cEmpresa		:= ""
Local cNomeEmp		:= 0
Local cTabSF1		:= ""
Local cTabSD1		:= ""
Local cTabSA2		:= ""
Local cQuery		:= ""
Local cLiberOk		:= "N"
Local cStatus		:= ""

Default self:page 	:= 1
Default self:pageSize := 500

aEmpresas := u_BKGrupo()
//nStart := INT(self:pageSize * (self:page - 1))
//nTamPag := self:pageSize := 100

//-------------------------------------------------------------------
// Query para selecionar Pré-notas
//-------------------------------------------------------------------

If !u_BkAvPar(::userlib,@aParams,@cMsg)
  oJsonSales['liberacao'] := cMsg

  cRet := oJsonSales:ToJson()

  FreeObj(oJsonSales)

  //Retorno do servico
  ::SetResponse(cRet)

  Return lRet:= .t.
EndIf

cFilSF1 := U_M103FILB()
//If !Empty(cFilSF1)
//	cWhereSF1 += "AND "+cFilSF1
//EndIf
//cWhereSF1 += "%"

For nE := 1 To Len(aEmpresas)

	cTabSF1 := "SF1"+aEmpresas[nE,1]+"0"
	cTabSD1 := "SD1"+aEmpresas[nE,1]+"0"
	cTabSA2 := "SA2"+aEmpresas[nE,1]+"0"

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += "SELECT "+CRLF
	cQuery += "		'"+cEmpresa+"' AS F1EMPRESA,'"+cNomeEmp+"' AS F1NOMEEMP,SF1.F1_FILIAL,SF1.R_E_C_N_O_ F1RECNO,"+CRLF
	cQuery += "		SF1.F1_DOC,SF1.F1_FORNECE,SF1.F1_LOJA,"+CRLF
	cQuery += "		SF1.F1_XXLIB,F1_STATUS,"+CRLF
	cQuery += "		SF1.F1_DTDIGIT,F1_XXPVPGT,"+CRLF
	cQuery += "		(SELECT SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) FROM "+cTabSD1+" SD1 "+CRLF
	cQuery += "		WHERE D1_FILIAL = F1_FILIAL	AND D1_DOC=F1_DOC AND D1_SERIE=F1_SERIE AND D1_FORNECE=F1_FORNECE AND D1_LOJA=F1_LOJA AND SD1.D_E_L_E_T_ = ' ')"+CRLF
	cQuery += "		AS D1_TOTAL,"+CRLF
	cQuery += "		SA2.A2_NOME"+CRLF
				
	cQuery += "FROM "+cTabSF1+" SF1"+CRLF
	cQuery += "		INNER JOIN "+cTabSA2+" SA2 "+CRLF
	cQuery += "			ON SF1.F1_FORNECE = SA2.A2_COD AND SF1.F1_LOJA = SA2.A2_LOJA"+CRLF
	cQuery += "			AND SA2.A2_FILIAL = '"+xFilial('SA2')+"' "+CRLF
	cQuery += "			AND SA2.D_E_L_E_T_ = ' '"+CRLF

	cQuery += "WHERE SF1.D_E_L_E_T_ = ' '"+CRLF
	cQuery += "		 AND SF1.F1_FILIAL = '"+xFilial('SF1')+"' "+CRLF
	If !Empty(cFilSF1)
		cQuery += "  AND "+cFilSF1+CRLF
	EndIf
Next

cQuery += "ORDER BY SF1.F1_XXPVPGT,SF1.F1_DOC"+CRLF

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySF1,.T.,.T.)

	/*
	BeginSQL Alias cQrySF1

		SELECT  %exp:cEmpresa% AS F1EMPRESA,%exp:cNomeEmp% AS F1NOMEEMP,SF1.F1_FILIAL,SF1.R_E_C_N_O_ F1RECNO,
				SF1.F1_DOC,SF1.F1_FORNECE,SF1.F1_LOJA,
				SF1.F1_DTDIGIT,SF1.F1_XXLIB,F1_XXPVPGT,
				(SELECT SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) FROM %exp:cTabSD1% SD1 
					WHERE D1_FILIAL = F1_FILIAL	AND D1_DOC=F1_DOC AND D1_SERIE=F1_SERIE AND D1_FORNECE=F1_FORNECE AND D1_LOJA=F1_LOJA AND SD1.%NotDel%)
					AS D1_TOTAL,
				SA2.A2_NOME
				
		FROM %exp:cTabSF1% SF1
				INNER JOIN %exp:cTabSA2% SA2 
					ON SF1.F1_FORNECE = SA2.A2_COD AND SF1.F1_LOJA = SA2.A2_LOJA
					%exp:cWhereSA2%
					AND SA2.%NotDel%

		WHERE   SF1.%NotDel%
				%exp:cWhereSF1%
				
		ORDER BY SF1.F1_DTDIGIT
		
	EndSQL

	//Syntax abaixo somente para o SQL 2012 em diante
	//ORDER BY SF1.F1_NUM OFFSET %exp:nStart% ROWS FETCH NEXT %exp:nTamPag% ROWS ONLY

	X:= GetLastQuery()
	//conout(cQrySF1)
	*/

If (cQrySF1)->( ! Eof() )

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
	( cQrySF1 )->( DBGoTop() )

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
// Alimenta array de Pré-notas
//-------------------------------------------------------------------
Do While ( cQrySF1 )->( ! Eof() )

	nCount++

	If nCount >= nStart

		cStatus  := "Indefinido"
		cLiberOk := (cQrySF1)->F1_XXLIB

		Do Case
		Case cLiberOk $ "AN" .AND. (cQrySF1)->F1_STATUS == " "
			cLiberOk := "A"
			cStatus  := "Liberar"
		Case cLiberOk == "B"
			cStatus  := "Bloqueada"
		Case cLiberOk == "C"
			cStatus  := "Classificada"
		Case cLiberOk == "E"
			cStatus  := "Estornada"
		Case cLiberOk == "L"
			cStatus  := "Liberada"
		EndCase


		aAdd( aListSales , JsonObject():New() )
		nPos := Len(aListSales)
		aListSales[nPos]['DOC']       := (cQrySF1)->F1_DOC
		aListSales[nPos]['DTDIGIT']   := DTOC(STOD((cQrySF1)->F1_DTDIGIT))
		aListSales[nPos]['FORNECEDOR']:= TRIM((cQrySF1)->A2_NOME)
		aListSales[nPos]['PGTO']  	  := DTOC(STOD((cQrySF1)->F1_XXPVPGT))
		aListSales[nPos]['TOTAL']     := TRANSFORM((cQrySF1)->D1_TOTAL,"@E 999,999,999.99")
		aListSales[nPos]['LIBEROK']   := cLiberOk
		aListSales[nPos]['STATUS']    := cStatus
		aListSales[nPos]['F1EMPRESA'] := (cQrySF1)->F1EMPRESA
		aListSales[nPos]['F1NOMEEMP'] := (cQrySF1)->F1NOMEEMP
		aListSales[nPos]['F1RECNO']   := STRZERO((cQrySF1)->F1RECNO,7)
		(cQrySF1)->(DBSkip())

		If Len(aListSales) >= self:pageSize
			Exit
		EndIf
	Else
		(cQrySF1)->(DBSkip())
	EndIf

EndDo

( cQrySF1 )->( DBCloseArea() )

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


WSMETHOD GET CONSPN QUERYPARAM empresa,prenota,userlib WSREST RestLibPN

Local oJsonPN	:= JsonObject():New()
Local cRet		:= ""
Local cQuery	:= ""
Local cTabSF1	:= "SF1"+self:empresa+"0"
Local cTabSD1	:= "SD1"+self:empresa+"0"
Local cTabSA2	:= "SA2"+self:empresa+"0"
Local cTabSB1	:= "SB1"+self:empresa+"0"
Local cQrySF1	:= GetNextAlias()
Local aItens	:= {}
Local nI		:= 0
Local aEmpresas	As Array
Local aParams	As Array
Local cMsg		As String
Local cHist		:= ""
Local aParcelas := {}
Local cParcelas := ""
Local nGeral	:= 0

aEmpresas := u_BKGrupo()
u_BkAvPar(::userlib,@aParams,@cMsg)

cQuery := "SELECT "+CRLF
cQuery += "		SF1.F1_DOC,SF1.F1_SERIE,SF1.F1_EMISSAO,SF1.F1_DTDIGIT,F1_XXPVPGT,F1_ESPECIE,F1_XXUSER,"+CRLF
cQuery += "		SF1.F1_FORNECE,SF1.F1_LOJA,SA2.A2_NOME,SA2.A2_CGC,SA2.A2_EST,SA2.A2_MUN,"+CRLF
cQuery += "		SF1.F1_XXLIB,"+CRLF
cQuery += "		SD1.D1_ITEM,SD1.D1_COD,SB1.B1_DESC,D1_TOTAL,(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) AS D1_GERAL,"+CRLF
cQuery += "		SD1.D1_QUANT,SD1.D1_VUNIT,SB1.B1_DESC,SD1.D1_CC,SD1.D1_XXDCC,"+CRLF
cQuery += "		CONVERT(VARCHAR(2000),CONVERT(Binary(2000),SD1.D1_XXHIST)) D1_XXHIST,"+CRLF
cQuery += "		CONVERT(VARCHAR(2000),CONVERT(Binary(2000),SF1.F1_XXPARCE)) F1_XXPARCE"+CRLF

cQuery += "FROM "+cTabSF1+" SF1"+CRLF

cQuery += "		INNER JOIN "+cTabSA2+" SA2 "+CRLF
cQuery += "			ON SF1.F1_FORNECE = SA2.A2_COD AND SF1.F1_LOJA = SA2.A2_LOJA"+CRLF
cQuery += "			AND SA2.A2_FILIAL = '"+xFilial('SA2')+"' "+CRLF
cQuery += "			AND SA2.D_E_L_E_T_ = ' '"+CRLF

cQuery += "		INNER JOIN "+cTabSD1+" SD1 "+CRLF
cQuery += "			ON D1_FILIAL = F1_FILIAL AND D1_DOC=F1_DOC AND D1_SERIE=F1_SERIE AND D1_FORNECE=F1_FORNECE AND D1_LOJA=F1_LOJA"+CRLF
cQuery += "			AND SD1.D_E_L_E_T_ = ' ' "+CRLF

cQuery += " 	INNER JOIN "+cTabSB1+" SB1 ON  SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SD1.D1_COD=SB1.B1_COD AND SB1.D_E_L_E_T_=''" +CRLF

cQuery += "WHERE SF1.R_E_C_N_O_ = "+self:prenota+CRLF

//	cQuery += "ORDER BY SF1.F1_DTDIGIT"+CRLF

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySF1,.T.,.T.)

dbSelectArea(cQrySF1)
dbGoTop()

oJsonPN['USERNAME']		:= cUserName
oJsonPN['EMPRESA']		:= aEmpresas[aScan(aEmpresas,{|x| x[1] == self:empresa }),2]
oJsonPN['F1_XXUSER']	:= UsrRetName((cQrySF1)->F1_XXUSER)
oJsonPN['F1_DOC']		:= (cQrySF1)->F1_DOC
oJsonPN['F1_SERIE']		:= (cQrySF1)->F1_SERIE
oJsonPN['F1_EMISSAO']	:= DTOC(STOD((cQrySF1)->F1_EMISSAO))
oJsonPN['F1_DTDIGIT']	:= DTOC(STOD((cQrySF1)->F1_DTDIGIT))
oJsonPN['F1_XXPVPGT']	:= DTOC(STOD((cQrySF1)->F1_XXPVPGT))
oJsonPN['F1_ESPECIE']	:= (cQrySF1)->F1_ESPECIE

oJsonPN['F1_FORN']		:= (cQrySF1)->F1_FORNECE+"-"+(cQrySF1)->F1_LOJA+" - "+TRIM((cQrySF1)->A2_NOME)
If Len(AllTrim((cQrySF1)->A2_CGC)) > 11		//Se for CNPJ
	oJsonPN['A2_CGC']	:= Transform((cQrySF1)->A2_CGC,"@R 99.999.999/9999-99")
Else 										//Se for CPF
	oJsonPN['A2_CGC']	:= Transform((cQrySF1)->A2_CGC,"@R 999.999.999-99")
EndIf
oJsonPN['A2_ESTMUN']	:= (cQrySF1)->A2_EST+"-"+TRIM((cQrySF1)->A2_MUN)

oJsonPN['F1_XXLIB']		:= (cQrySF1)->F1_XXLIB

aParcelas := LoadVenc((cQrySF1)->F1_XXPARCE)
For nI := 1 TO LEN(aParcelas)
	cParcelas += aParcelas[nI,1]+" - "+DTOC(aParcelas[nI,2])+ " - R$ "+ALLTRIM(TRANSFORM(aParcelas[nI,3],"@E 999,999,999.99"))
	If MOD(nI,2) == 0
		cParcelas += CRLF
	ElseIf nI < LEN(aParcelas)
		cParcelas += "  |  "
	EndIf
Next
oJsonPN['F1_XXPARCE']	:= cParcelas

nI := 0
Do While (cQrySF1)->(!EOF())
	aAdd(aItens,JsonObject():New())
	nI++
	aItens[nI]["D1_ITEM"]	:= (cQrySF1)->D1_ITEM
	aItens[nI]["D1_COD"]	:= TRIM((cQrySF1)->D1_COD)
	aItens[nI]["B1_DESC"]	:= TRIM((cQrySF1)->B1_DESC)
	aItens[nI]["D1_QUANT"]	:= TRANSFORM((cQrySF1)->D1_QUANT,"@E 99999999.99")
	aItens[nI]["D1_VUNIT"]	:= TRANSFORM((cQrySF1)->D1_TOTAL,"@E 999,999,999.9999")
	aItens[nI]["D1_TOTAL"]	:= TRANSFORM((cQrySF1)->D1_TOTAL,"@E 999,999,999.99")
	aItens[nI]["D1_GERAL"]	:= TRANSFORM((cQrySF1)->D1_GERAL,"@E 999,999,999.99")
	aItens[nI]["D1_CC"]		:= (cQrySF1)->D1_CC+"-"+TRIM((cQrySF1)->D1_XXDCC)
	If !ALLTRIM((cQrySF1)->D1_XXHIST) $ cHist                   
       cHist += ALLTRIM((cQrySF1)->D1_XXHIST)+" "
    EndIf
	nGeral += (cQrySF1)->D1_GERAL
	dbSkip()
EndDo

cHist := STRTRAN(cHist,CRLF," ")
oJsonPN['D1_XXHIST']	:= StrIConv( cHist, "CP1252", "UTF-8")  //CP1252  ISO-8859-1
oJsonPN['D1_ITENS']		:= aItens
oJsonPN['F1_GERAL']		:= TRANSFORM(nGeral,"@E 999,999,999.99")

(cQrySF1)->(dbCloseArea())

cRet := oJsonPN:ToJson()

FreeObj(oJsonPN)

//Retorno do servico
::SetResponse(cRet)

return .T.


WSMETHOD GET BROWPN QUERYPARAM userlib WSRECEIVE userlib WSREST RestLibPN

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
<title>Liberação de Pré-notas</title>
<!-- <link href="index.css" rel="stylesheet"> -->
<style type="text/css">
.bk-colors{
 background-color: #9E0000;
 color: white;
}
.bg-mynav {
  background-color: #9E0000;
  padding-left:30px;
  padding-right:30px;
}
.font-condensed{
  font-size: 0.8em;
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
	<a class="navbar-brand" href="#">BK - Liberação de Pré-notas de Entradas</a>
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
<table class="table">
<thead>
<tr>
<th scope="col">Empresa</th>
<th scope="col">Pré-nota</th>
<th scope="col">Entrada</th>
<th scope="col">Fornecedor</th>
<th scope="col">Vencimento</th>
<th scope="col" style="text-align:center;">Total</th>
<th scope="col" style="text-align:center;">Ação</th>
</tr>
</thead>
<tbody id="mytable">
<tr>
<th scope="row" colspan="7" style="text-align:center;">Carregando Pré-notas...</th>
</tr>
</tbody>
</table>
</div>
</div>
<!-- Modal -->
<div id="meuModal" class="modal fade" role="dialog">
   <div class="modal-dialog modal-fullscreen">
     <!-- Conteúdo do modal-->
     <div class="modal-content">
       <!-- Cabeçalho do modal -->
       <div class="modal-header bk-colors">
         <h4 id="titLib" class="modal-title">Título do modal</h4>
         <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                 <span aria-hidden="true">&times;</span>
         </button>
       </div>
       <!-- Corpo do modal -->
       <div class="modal-body">

          <form class="row g-3 font-condensed">
            
          <div class="col-md-2">
             <label for="SF1Doc" class="form-label">Documento</label>
             <input type="text" class="form-control form-control-sm" id="SF1Doc" value="#SF1Doc#" readonly="">
           </div>
           <div class="col-md-1">
             <label for="SF1Serie" class="form-label">Série</label>
             <input type="text" class="form-control form-control-sm" id="SF1Serie" value="#SF1Serie#" readonly="">
           </div>
           <div class="col-md-1">
             <label for="SF1Emissao" class="form-label">Emissão</label>
             <input type="text" class="form-control form-control-sm" id="SF1Emissao" value="#SF1Emissao#" readonly="">
           </div>
           <div class="col-md-1">
             <label for="SF1DtDigit" class="form-label">Entrada</label>
             <input type="text" class="form-control form-control-sm" id="SF1DtDigit" value="#SF1DtDigit#" readonly="">
           </div>
           <div class="col-md-1">
             <label for="SF1XXPvPgt" class="form-label">Pagamento</label>
             <input type="text" class="form-control form-control-sm" id="SF1XXPvPgt" value="#SF1XXPvPgt#" readonly="">
           </div>
           <div class="col-md-2">
             <label for="SF1Especie" class="form-label">Espécie</label>
             <input type="text" class="form-control form-control-sm" id="SF1Especie" value="#SF1Especie#" readonly="">
           </div>

           <div class="col-md-2">
             <label for="SF1XXUser" class="form-label">Usuário</label>
             <input type="text" class="form-control form-control-sm" id="SF1XXUser" value="#SF1XXUser#" readonly="">
           </div>

           <div class="col-md-6">
             <label for="SF1Forn" class="form-label">Fornecedor</label>
             <input type="text" class="form-control form-control-sm" id="SF1Forn" value="#SF1Forn#" readonly>
           </div>
           <div class="col-md-2">
             <label for="SF1CGC" class="form-label">CNPJ/CPF</label>
             <input type="text" class="form-control form-control-sm" id="SF1CGC" value="#SF1CGC#" readonly="">
           </div>
           <div class="col-md-2">
             <label for="SF1EstMun" class="form-label">Estado/Município</label>
             <input type="text" class="form-control form-control-sm" id="SF1EstMun" value="#SF1EstMun#" readonly="">
           </div>

           <div class="col-md-6">
             <label for="SF1XXHist" class="form-label">Memorando</label>
			 <textarea class="form-control form-control-sm" id="SF1XXHist" rows="3" value="#SF1XXHist#" readonly=""></textarea>
           </div>

           <div class="col-md-6">
             <label for="SF1XXParce" class="form-label">Parcelas</label>
			 <textarea class="form-control form-control-sm" id="SF1XXParce" rows="3" value="#SF1XXParce#" readonly=""></textarea>
           </div>

			<div class="container">
				<div class="table-responsive-sm">
				<table class="table ">
					<thead>
						<tr>
							<th scope="col">Item</th>
							<th scope="col">Produto</th>
							<th scope="col">Descrição</th>
							<th scope="col">Centro de Custo</th>
							<th scope="col" style="text-align:right;">Quant.</th>
							<th scope="col" style="text-align:right;">V.Unitário</th>
							<th scope="col" style="text-align:right;">Total</th>
							<th scope="col" style="text-align:right;">Geral</th>
						</tr>
					</thead>
					<tbody id="d1Table">
						<tr>
							<th scope="row" colspan="8" style="text-align:center;">Carregando itens...</th>
						</tr>
					</tbody>

					<tfoot id="d1Foot">
						<th scope="row" colspan="8" style="text-align:right;">Total Geral</th>
					</tfoot>

				</table>
				</div>
			</div>

            <div class="col-12">
              <button type="submit" class="btn btn-primary">Sign in</button>
            </div>

          </form>

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
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.7/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>

<script>

async function getPNs() {
	let url = 'http://10.139.0.30:8080/rest/RestLibPN/?userlib='+'#userlib#';
		try {
		let res = await fetch(url);
			return await res.json();
			} catch (error) {
		console.log(error);
			}
		}


async function loadTable() {
let prenotas = await getPNs();
let trHTML = '';
if (Array.isArray(prenotas)) {
    prenotas.forEach(object => {

    let cprenota = object['DOC']
    let cLiberOk = object['LIBEROK']
    let cStatus  = object['STATUS']

    trHTML += '<tr>';
    trHTML += '<td>'+object['F1NOMEEMP']+'</td>';
    trHTML += '<td>'+cprenota+'</td>';
    trHTML += '<td>'+object['DTDIGIT']+'</td>';
    trHTML += '<td>'+object['FORNECEDOR']+'</td>';
    trHTML += '<td>'+object['PGTO']+'</td>';
    trHTML += '<td align="right">'+object['TOTAL']+'</td>';
    if (cLiberOk == 'A'){
    	trHTML += '<td align="right"><button type="button" class="btn btn-outline-success btn-sm" onclick="showPN(\''+object['F1EMPRESA']+'\',\''+object['F1RECNO']+'\',\'#userlib#\',1)">'+cStatus+cLiberOk+'</button></td>';
  	} else {
     	trHTML += '<td align="right"><button type="button" class="btn btn-outline-warning btn-sm" onclick="showPN(\''+object['F1EMPRESA']+'\',\''+object['F1RECNO']+'\',\'#userlib#\',2)">'+cStatus+cLiberOk+'</button></td>';
    }
	trHTML += '</tr>';
    });
} else {
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="7" style="text-align:center;">'+prenotas['liberacao']+'</th>';
    trHTML += '</tr>';   
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="7" style="text-align:center;">Faça login novamente no sistema Protheus</th>';
    trHTML += '</tr>';   
}
document.getElementById("mytable").innerHTML = trHTML;

}

loadTable();


async function getPN(f1empresa,f1recno,userlib) {
let url = 'http://10.139.0.30:8080/rest/RestLibPN/v1?empresa='+f1empresa+'&prenota='+f1recno+'&userlib='+userlib;
	try {
	let res = await fetch(url);
		return await res.json();
		} catch (error) {
	console.log(error);
		}
	}

async function showPN(f1empresa,f1recno,userlib,canLib) {
let prenota = await getPN(f1empresa,f1recno,userlib);
let itens = ''
let i = 0
let foot = ''
document.getElementById('SF1Doc').value = prenota['F1_DOC'];
document.getElementById('SF1Serie').value = prenota['F1_SERIE'];
document.getElementById('SF1Emissao').value = prenota['F1_EMISSAO'];
document.getElementById('SF1DtDigit').value = prenota['F1_DTDIGIT'];
document.getElementById('SF1XXPvPgt').value = prenota['F1_XXPVPGT'];
document.getElementById('SF1Especie').value = prenota['F1_ESPECIE'];
document.getElementById('SF1XXUser').value = prenota['F1_XXUSER'];

document.getElementById('SF1Forn').value = prenota['F1_FORN'];
document.getElementById('SF1CGC').value = prenota['A2_CGC'];
document.getElementById('SF1EstMun').value = prenota['A2_ESTMUN'];

document.getElementById('SF1XXHist').value = prenota['D1_XXHIST'];
document.getElementById('SF1XXParce').value = prenota['F1_XXPARCE'];


if (canLib === 1){
	let btn = '<button type="button" class="btn btn-outline-success" onclick="libdoc(\''+f1empresa+'\',\''+f1recno+'\',\'#userlib#\')">Liberar</button>';
	document.getElementById("btnlib").innerHTML = btn;
}
if (Array.isArray(prenota.D1_ITENS)) {
   prenota.D1_ITENS.forEach(object => {
    i++
	itens += '<tr>';
	itens += '<td>'+object['D1_ITEM']+'</td>';	
	itens += '<td>'+object['D1_COD']+'</td>';
   	itens += '<td>'+object['B1_DESC']+'</td>';
	itens += '<td>'+object['D1_CC']+'</td>';
	itens += '<td align="right">'+object['D1_QUANT']+'</td>';
	itens += '<td align="right">'+object['D1_VUNIT']+'</td>';
	itens += '<td align="right">'+object['D1_TOTAL']+'</td>';
	itens += '<td align="right">'+object['D1_GERAL']+'</td>';
	itens += '</tr>';
    <!-- itens += '<div class="col-md-2">' -->
    <!-- itens += '  <input type="text" class="form-control" id="D1_TOTAL'+i+'" value="'+object['D1_TOTAL']+'" readonly="">' -->
    <!-- itens += '</div>' -->

  })
}
document.getElementById("d1Table").innerHTML = itens;
foot = '<th scope="row" colspan="8" style="text-align:right;">'+prenota['F1_GERAL']+'</th>'
document.getElementById("d1Foot").innerHTML = foot;

$("#titLib").text('Liberação de Pré-Nota - Empresa: '+prenota['EMPRESA'] + ' - Usuário: '+prenota['USERNAME']);
$('#meuModal').modal('show');
$('#meuModal').on('hidden.bs.modal', function () {
	location.reload();
	})
}



async function libdoc(f1empresa,f1recno,userlib){
let dataObject = {liberacao:'ok'};
let resposta = ''

fetch('http://10.139.0.30:8081/rest/RestLibPN/v3?empresa='+f1empresa+'&prenota='+f1recno+'&userlib='+userlib, {
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

Memowrite("\tmp\pn.html",cHtml)

self:setResponse(cHTML)
self:setStatus(200)

return .T.


// Tranformar F1_XXPARCE em array
Static Function LoadVenc(mParcel)
Local aTmp		:= {}
Local nX 		:= 0
Local nTamTex	:= 0
Local aDados	:= {}

nTamTex := mlCount(mParcel, 200)
For nX := 1 To nTamTex	
	aTmp := StrTokArr(memoline(mParcel, 200, nX),";")
	If !Empty(aTmp[1])
		aAdd(aDados,{aTmp[1],CTOD(aTmp[2]),VAL(aTmp[3]),.F.})
	EndIf
Next

Return aDados
