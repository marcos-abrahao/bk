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

	WSMETHOD GET CONSZ2;
		DESCRIPTION "Retorna dados RH";
		WSSYNTAX "/RestTitCP/v1";
		PATH "/RestTitCP/v1";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET BROWCP;
		DESCRIPTION "Browse Contas a Pagar como página HTML";
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
	Local cDescr 	:= "Exportação Excel do C.Pagar Web"
	Local cVersao	:= "13/01/2024"
	Local oRExcel	AS Object
	Local oPExcel	AS Object

    Local cFile  	:= ""
	Local cName  	:= "" //Decode64(self:documento)
	Local cFName 	:= ""
    Local oFile  	AS Object

	Local cQrySE2	:= GetNextAlias()

	u_MsgLog(cProg,cTitulo+" "+self:vencreal)

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
	oPExcel:AddCol("LOTE","LOTE","Lote","")
	oPExcel:AddCol("VALOR","E2_VALOR","Valor","E2_VALOR")
	oPExcel:AddCol("SALDO","SALDO","Saldo","")
	oPExcel:AddCol("STATUS","u_DE2XXPgto(E2_XXPGTO)")
	oPExcel:AddCol("HIST","HIST","Histórico","D1_XXHIST")
	oPExcel:AddCol("OPER","UsrRetName(E2_XXOPER)","Operador","")
	oPExcel:AddCol("DADOSPGT","u_CPDadosPgt('"+cQrySE2+"')","Dados Pagamento","")

	oPExcel:GetCol("FORMPGT"):SetHAlign("C")
	oPExcel:GetCol("PORTADO"):SetHAlign("C")
	oPExcel:GetCol("LOTE"):SetHAlign("C")
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

	oPExcel:GetCol("DADOSPGT"):SetTamCol(40)
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
		oFile:Close()
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
Local cNumTit 		:= ""
Local cFormaPgto	:= ""

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
	aListCP[nPos]['LOTE']		:= TRIM((cQrySE2)->LOTE)
	aListCP[nPos]['VALOR']      := TRANSFORM((cQrySE2)->E2_VALOR,"@E 999,999,999.99")
	aListCP[nPos]['SALDO'] 	    := TRANSFORM((cQrySE2)->SALDO,"@E 999,999,999.99")

	aListCP[nPos]['XSTATUS']	:= (cQrySE2)->(E2_XXPGTO)
	aListCP[nPos]['STATUS']		:= u_DE2XXPgto((cQrySE2)->(E2_XXPGTO))
	aListCP[nPos]['HIST']		:= StrIConv(ALLTRIM((cQrySE2)->HIST), "CP1252", "UTF-8") 
	aListCP[nPos]['OPER']		:= (cQrySE2)->(UsrRetName(E2_XXOPER)) //(cQrySE2)->(FwLeUserLg('E2_USERLGA',1))
	aListCP[nPos]['E2RECNO']	:= STRZERO((cQrySE2)->E2RECNO,7)

	cFormaPgto := u_CPDadosPgt(cQrySE2)
	aListCP[nPos]['DADOSPGT']	:= cFormaPgto

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

// v1
WSMETHOD GET CONSZ2 QUERYPARAM empresa,e2recno,userlib WSREST RestTitCP

Local oJsonPN	:= JsonObject():New()
Local cRet		:= ""
Local cQuery	:= ""
Local cTabSE2	:= "SE2"+self:empresa+"0"
Local cTabSZ2	:= "SZ2010"
Local cQrySE2	:= GetNextAlias()
Local cQrySZ2	:= GetNextAlias()
Local aItens	:= {}
Local nI		:= 0
Local aEmpresas	As Array
Local aParams	As Array
Local cMsg		As Character
// Chave Z2
Local cPrefixo	:= ""
Local cNum		:= ""
Local cParcela	:= ""
Local cTipo		:= ""
Local cFornece	:= ""
Local cLoja		:= ""

Local nTotal	:= 0
Local cTipBk 	:= ""

aEmpresas := u_BKGrupo()
u_BkAvPar(::userlib,@aParams,@cMsg)

cQuery := "SELECT " + CRLF
cQuery += "		 SE2.E2_PREFIXO" + CRLF
cQuery += "		,SE2.E2_NUM" + CRLF
cQuery += "		,SE2.E2_PARCELA" + CRLF
cQuery += "		,SE2.E2_TIPO" + CRLF
cQuery += "		,SE2.E2_XXTIPBK" + CRLF
cQuery += "		,SE2.E2_FORNECE" + CRLF
cQuery += "		,SE2.E2_LOJA" + CRLF
cQuery += "		,SE2.E2_NOMFOR" + CRLF
cQuery += "		,SE2.E2_EMISSAO" + CRLF
cQuery += "		,SE2.E2_VENCREA" + CRLF
cQuery += "		,SE2.E2_HIST" + CRLF
cQuery += "FROM "+cTabSE2+" SE2" + CRLF
cQuery += "WHERE SE2.R_E_C_N_O_ = "+self:e2recno + CRLF

//u_MsgLog("RESTLIBCP",cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySE2,.T.,.T.)

dbSelectArea(cQrySE2)
dbGoTop()
cPrefixo	:= (cQrySE2)->E2_PREFIXO
cNum		:= (cQrySE2)->E2_NUM
cParcela	:= (cQrySE2)->E2_PARCELA
cTipo		:= (cQrySE2)->E2_TIPO
cFornece	:= (cQrySE2)->E2_FORNECE
cLoja		:= (cQrySE2)->E2_LOJA
cTipBK 		:= (cQrySE2)->E2_XXTIPBK

oJsonPN['USERNAME']		:= cUserName
oJsonPN['EMPRESA']		:= aEmpresas[aScan(aEmpresas,{|x| x[1] == self:empresa }),2]
oJsonPN['E2_PREFIXO']	:= (cQrySE2)->E2_PREFIXO
oJsonPN['E2_NUM']		:= (cQrySE2)->E2_NUM
oJsonPN['E2_NOMFOR']	:= (cQrySE2)->E2_NOMFOR
oJsonPN['E2_EMISSAO']	:= DTOC(STOD((cQrySE2)->E2_EMISSAO))
oJsonPN['E2_VENCREA']	:= DTOC(STOD((cQrySE2)->E2_VENCREA))
oJsonPN['E2_HIST']		:= (cQrySE2)->E2_HIST

(cQrySE2)->(dbCloseArea())

cQuery := "SELECT " + CRLF
cQuery += "		Z2_NOME" + CRLF
cQuery += "		,Z2_PRONT" + CRLF
cQuery += "		,Z2_BANCO" + CRLF
cQuery += "		,Z2_AGENCIA" + CRLF
cQuery += "		,Z2_DATAEMI" + CRLF
cQuery += "		,Z2_DATAPGT" + CRLF
cQuery += "		,Z2_DIGAGEN" + CRLF
cQuery += "		,Z2_CONTA" + CRLF
cQuery += "		,Z2_DIGCONT" + CRLF
cQuery += "		,Z2_TIPO" + CRLF
cQuery += "		,Z2_VALOR" + CRLF
cQuery += " 	,Z2_TIPOPES" + CRLF
cQuery += "		,Z2_CC" + CRLF
cQuery += "		,Z2_USUARIO" + CRLF
cQuery += "		,Z2_OBSTITU" + CRLF
cQuery += "		,Z2_NOMDEP" + CRLF
cQuery += "		,Z2_NOMMAE " + CRLF
cQuery += "		,Z2_BORDERO " + CRLF
cQuery += " FROM "+cTabSZ2+" SZ2" + CRLF
cQuery += " WHERE Z2_FILIAL = '"+xFilial("SZ2")+"' " + CRLF
cQuery += " 	AND Z2_CODEMP = '"+self:empresa+"' " + CRLF
cQuery += " 	AND Z2_E2PRF  = '"+cPrefixo+"' " + CRLF
cQuery += " 	AND Z2_E2NUM  = '"+cNum+"' " + CRLF
cQuery += " 	AND Z2_E2PARC = '"+cParcela+"' " + CRLF
cQuery += " 	AND Z2_E2TIPO = '"+cTipo+"' " + CRLF
cQuery += " 	AND Z2_E2FORN = '"+cFornece+"' " + CRLF
cQuery += " 	AND Z2_E2LOJA = '"+cLoja+"' " + CRLF
cQuery += " 	AND Z2_STATUS = 'S'" + CRLF
cQuery += " 	AND SZ2.D_E_L_E_T_ = ' '" + CRLF
cQuery += " ORDER BY Z2_NOME" + CRLF

//u_MsgLog("RESTLIBCP",cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySZ2,.T.,.T.)

dbSelectArea(cQrySZ2)
dbGoTop()

oJsonPN['LOTE']			:= (cQrySZ2)->Z2_BORDERO  // Numero do Bordero
oJsonPN['Z2_USUARIO']	:= (cQrySZ2)->Z2_USUARIO

nI := 0
Do While (cQrySZ2)->(!EOF())
	aAdd(aItens,JsonObject():New())
	nI++
	aItens[nI]["Z2_PRONT"]	:= (cQrySZ2)->Z2_PRONT
	If cTipBK == "PEN"
		aItens[nI]["Z2_NOME"]	:= ALLTRIM(IIF(!EMPTY((cQrySZ2)->Z2_NOMMAE),(cQrySZ2)->Z2_NOMMAE,(cQrySZ2)->Z2_NOMDEP))
	Else
		aItens[nI]["Z2_NOME"]	:= (cQrySZ2)->Z2_NOME
	EndIf

	aItens[nI]["Z2_NOME"]	:= StrIConv((cQrySZ2)->Z2_NOME, "CP1252", "UTF-8")


	aItens[nI]["DADOSBC"]	:= (cQrySZ2)->('Bco: '+Z2_BANCO+' Ag: '+Z2_AGENCIA+'-'+Z2_DIGAGEN+' C/C: '+Z2_CONTA+'-'+Z2_DIGCONT)
	aItens[nI]["Z2_CC"]		:= (cQrySZ2)->Z2_CC
	aItens[nI]["Z2_OBSTITU"]:= StrIConv(TRIM((cQrySZ2)->Z2_OBSTITU), "CP1252", "UTF-8")
	aItens[nI]["Z2_VALOR"]	:= TRANSFORM((cQrySZ2)->Z2_VALOR,"@E 99999999.99")

	nTotal += (cQrySZ2)->Z2_VALOR

	dbSkip()
EndDo

oJsonPN['DADOSZ2']		:= aItens
oJsonPN['Z2_TOTAL']		:= TRANSFORM(nTotal,"@E 999,999,999.99")

(cQrySZ2)->(dbCloseArea())

cRet := oJsonPN:ToJson()

FreeObj(oJsonPN)

//Retorno do servico
Self:SetHeader("Access-Control-Allow-Origin", "*")
Self:SetResponse(cRet)

return .T.


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
    <a class="navbar-brand" href="#">Títulos a Pagar - #cUserName#</a> 

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
<th scope="col" style="text-align:center;">Lote</th>
<th scope="col" style="text-align:center;">Valor</th>
<th scope="col" style="text-align:center;">Saldo</th>
<th scope="col" style="text-align:center;">Status</th>
<th scope="col">Histórico</th>
<th scope="col">Dados Pgto</th>
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
  <th scope="col" style="text-align:center;"></th>
  <th scope="col" style="text-align:center;"></th>
  <th scope="col" style="text-align:center;"></th>
  <th scope="col" style="text-align:center;"></th>
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col"></th>
</tr>
</tbody>
</table>
</div>
</div>

<!-- Modal -->
<div id="Z2Modal" class="modal fade" role="dialog">
   <div class="modal-dialog modal-fullscreen">
     <!-- Conteúdo do modal-->
     <div class="modal-content">
       <!-- Cabeçalho do modal -->
       <div class="modal-header bk-colors">
         <h4 id="titZ2Modal" class="modal-title">Título do modal</h4>
         <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                 <span aria-hidden="true">&times;</span>
         </button>
       </div>
       <!-- Corpo do modal -->
       <div class="modal-body">

          <form class="row g-3 font-condensed">
            
           <div class="col-md-1">
             <label for="SE2Prefixo" class="form-label">Prefixo</label>
             <input type="text" class="form-control form-control-sm" id="SE2Prefixo" value="#SE2Prefixo#" readonly="">
           </div>
          <div class="col-md-2">
             <label for="SE2Num" class="form-label">Título</label>
             <input type="text" class="form-control form-control-sm" id="SE2Num" value="#SE2Num#" readonly="">
           </div>
           <div class="col-md-2">
             <label for="SE2NomFor" class="form-label">Fornecedor</label>
             <input type="text" class="form-control form-control-sm" id="SE2NomFor" value="#SE2NomFor#" readonly="">
           </div>
           <div class="col-md-1">
             <label for="SE2Emissao" class="form-label">Emissão</label>
             <input type="text" class="form-control form-control-sm" id="SE2Emissao" value="#SE2Emissao#" readonly="">
           </div>
           <div class="col-md-1">
             <label for="SE2VencRea" class="form-label">Vencimento</label>
             <input type="text" class="form-control form-control-sm" id="SE2VencRea" value="#SE2VencRea#" readonly="">
           </div>

           <div class="col-md-2">
             <label for="SE2RHUsr" class="form-label">Usuário RH</label>
             <input type="text" class="form-control form-control-sm" id="SE2RHUsr" value="#SE2RHUsr#" readonly="">
           </div>

           <div class="col-md-1">
             <label for="SE2Lote" class="form-label">Lote</label>
             <input type="text" class="form-control form-control-sm" id="SE2Lote" value="#SE2Lote#" readonly="">
           </div>

           <div class="col-md-8">
             <label for="SE2Hist" class="form-label">Histórico</label>
			 <textarea class="form-control form-control-sm" id="SE2Hist" rows="1" value="#SE2Hist#" readonly=""></textarea>
           </div>

			<div class="container">
				<div class="table-responsive-sm">
				<table class="table ">
					<thead>
						<tr>
							<th scope="col">Prontuário</th>
							<th scope="col">Beneficiário</th>
							<th scope="col">Dados Bancários</th>
							<th scope="col">Centro de Custo</th>
							<th scope="col">Obs</th>
							<th scope="col" style="text-align:right;">Valor</th>
						</tr>
					</thead>
					<tbody id="z2Table">
						<tr>
							<th scope="row" colspan="8" style="text-align:center;">Carregando itens...</th>
						</tr>
					</tbody>

					<tfoot id="z2Foot">
						<th scope="row" colspan="8" style="text-align:right;">Total Geral</th>
					</tfoot>

				</table>
				</div>
			</div>

            <div class="col-12" id="anexos">
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
let cbtnz2 = ''

if (Array.isArray(titulos)) {
	titulos.forEach(object => {
	let cStatus  = object['XSTATUS']
	let cEmpresa = object['EMPRESA'].substring(0,2)
	let cDadosPgt = object['DADOSPGT']

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
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgBanco(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'756\','+'\''+cbtnidp+'\')">756 Sicoob</button>';
	trHTML += '</div>'
	trHTML += '</td>'

	trHTML += '<td align="center">'+object['LOTE']+'</td>';
	trHTML += '<td align="right">'+object['VALOR']+'</td>';
	trHTML += '<td align="right">'+object['SALDO']+'</td>';

	if (cStatus == 'C' ){
	 cbtn = 'btn-outline-success';
	 } else if (cStatus == ' ' || cStatus == 'A'){
	 cbtn = 'btn-outline-warning';
	} else if (cStatus == 'P'){
	 cbtn = 'btn-outline-danger';
	} else if (cStatus == 'O'){
	 cbtn = 'btn-outline-primary';
	} else if (cStatus == 'D'){
	 cbtn = 'btn btn-dark';
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
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgStatus(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'O\','+'\''+cbtnids+'\')">Compensar PA</button>';
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgStatus(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'D\','+'\''+cbtnids+'\')">Deb Automatico</button>';

	trHTML += '</div>'

	trHTML += '</td>'

	trHTML += '<td>'+object['HIST']+'</td>';

	trHTML += '<td>';
		if (cDadosPgt.indexOf('#RH#') !== -1){
			cbtnz2 = 'btnz2'+nlin;
			trHTML += '<button type="button" id="'+cbtnz2+'" class="btn '+cbtn+' btn-sm" onclick="showZ2(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\','+'\''+cbtnz2+'\')">'+cDadosPgt+'</button>';
		} else {
			trHTML += object['DADOSPGT'];
		}
	trHTML += '</td>'

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


async function getZ2(empresa,e2recno,userlib) {
let url = '#iprest#/RestTitCP/v1?empresa='+empresa+'&e2recno='+e2recno+'&userlib='+userlib;
	try {
	let res = await fetch(url);
		return await res.json();
		} catch (error) {
	console.log(error);
		}
	}

async function showZ2(empresa,e2recno,userlib,cbtnz2) {

document.getElementById(cbtnz2).disabled = true;
document.getElementById(cbtnz2).innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>';

let dadosE2 = await getZ2(empresa,e2recno,userlib);
let itens = '';
let i = 0;
let foot = '';
let anexos = '';
let inpE = '';
let iCheck = '';
let cClick = 'libdoc';

document.getElementById('SE2Prefixo').value = dadosE2['E2_PREFIXO'];
document.getElementById('SE2Num').value = dadosE2['E2_NUM'];
document.getElementById('SE2NomFor').value = dadosE2['E2_NOMFOR'];
document.getElementById('SE2Emissao').value = dadosE2['E2_EMISSAO'];
document.getElementById('SE2VencRea').value = dadosE2['E2_VENCREA'];
document.getElementById('SE2RHUsr').value = dadosE2['Z2_USUARIO'];
document.getElementById('SE2Hist').value = dadosE2['E2_HIST'];
document.getElementById('SE2Lote').value = dadosE2['LOTE'];

if (Array.isArray(dadosE2.DADOSZ2)) {
   dadosE2.DADOSZ2.forEach(object => {
    i++
	itens += '<tr>';
	itens += '<td>'+object['Z2_PRONT']+'</td>';	
	itens += '<td>'+object['Z2_NOME']+'</td>';
   	itens += '<td>'+object['DADOSBC']+'</td>';
	itens += '<td>'+object['Z2_CC']+'</td>';
	itens += '<td>'+object['Z2_OBSTITU']+'</td>';
	itens += '<td align="right">'+object['Z2_VALOR']+'</td>';
	itens += '</tr>';
  })
}

document.getElementById("z2Table").innerHTML = itens;
foot = '<th scope="row" colspan="8" style="text-align:right;">'+dadosE2['Z2_TOTAL']+'</th>'
document.getElementById("z2Foot").innerHTML = foot;

$("#titZ2Modal").text('Integração RH - Empresa: '+dadosE2['EMPRESA'] + ' - Usuário: '+dadosE2['USERNAME']);
$('#Z2Modal').modal('show');
$('#Z2Modal').on('hidden.bs.modal', function () {
	location.reload();
	})
}


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
		} else if (acao == 'O'){
			cbtn = 'Compensar PA';
		} else if (acao == 'D'){
			cbtn = 'Deb Automatico';
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

// Empresas com integração pendente
IntegEmp(@aEmpresas)

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
Local cEmpr 		:= ""

aGrupoBK := u_BKGrupo()
nE := aScan(aGrupoBK,{|x| x[1] == SUBSTR(xEmpresa,1,2) })
If nE > 0
	aEmpresas := {aGrupoBK[nE]}
Else
	aEmpresas := aGrupoBK
EndIf


cQuery := "WITH RESUMO AS ( " + CRLF

For nE := 1 To Len(aEmpresas)
	cEmpr 	:= aEmpresas[nE,1]
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
	cQuery += "	 ,E2_XXTIPBK"+CRLF
	cQuery += "	 ,E2_XXLOTEB"+CRLF
	cQuery += "	 ,E2_NUMBOR"+CRLF
	cQuery += "	 ,SE2.R_E_C_N_O_ AS E2RECNO"+CRLF
	cQuery += "	 ,A2_NOME"+CRLF
	cQuery += "	 ,A2_TIPO"+CRLF
	cQuery += "	 ,A2_CGC"+CRLF
	cQuery += "	 ,A2_BANCO"+CRLF
	cQuery += "	 ,A2_AGENCIA"+CRLF
	cQuery += "	 ,A2_NUMCON"+CRLF
	cQuery += "	 ,(CASE WHEN E2_SALDO = E2_VALOR "+CRLF
	cQuery += "	 		THEN E2_VALOR + E2_ACRESC - E2_DECRESC"+CRLF
	cQuery += "	 		ELSE E2_SALDO END) AS SALDO"+CRLF


	//cQuery += "	 ,"+IIF(dDtIni <> dDtFim,"+' '+E2_VENCREA",'')+"+ "
	cQuery += "	 ,(CASE WHEN (F1_XTIPOPG IS NULL) AND (Z2_BANCO IS NULL) "+CRLF
	cQuery += "	 		THEN E2_TIPO+' '+E2_PORTADO"+CRLF
	cQuery += "	 		WHEN F1_XTIPOPG IS NULL AND (E2_PORTADO IS NOT NULL) THEN 'LF '+E2_PORTADO+' '+E2_TIPO"+CRLF
	cQuery += "	 		ELSE F1_XTIPOPG END)"+" AS FORMPGT"+CRLF

	cQuery += "	 ,Z2_NOME"+CRLF
	cQuery += "	 ,Z2_NOMMAE"+CRLF
	cQuery += "	 ,Z2_NOMDEP"+CRLF
	cQuery += "	 ,Z2_BORDERO"+CRLF
	cQuery += "	 ,(CASE WHEN (Z2_BANCO IS NOT NULL) AND "+CRLF
	cQuery += "	 					(SELECT COUNT(Z2_E2NUM) FROM "+cTabSZ2+" SZ2T"+CRLF
	cQuery += "	 			    		WHERE SZ2T.D_E_L_E_T_ = ''"+CRLF
	cQuery += "	  						AND SZ2T.Z2_FILIAL = ' '"+CRLF
	cQuery += "	  	 					AND SZ2T.Z2_CODEMP = '"+cEmpr+"'"+CRLF
	cQuery += "	 						AND SE2.E2_PREFIXO = SZ2T.Z2_E2PRF"+CRLF
	cQuery += "	 						AND SE2.E2_NUM     = SZ2T.Z2_E2NUM"+CRLF
	cQuery += "	 	 					AND SE2.E2_PARCELA = SZ2T.Z2_E2PARC"+CRLF
	cQuery += "	 	 					AND SE2.E2_TIPO    = SZ2T.Z2_E2TIPO"+CRLF
	cQuery += "	 	 					AND SE2.E2_FORNECE = SZ2T.Z2_E2FORN"+CRLF
	cQuery += "	 	 					AND SE2.E2_LOJA    = SZ2T.Z2_E2LOJA) = 1"+CRLF
	cQuery += "	 		THEN 'Bco: '+Z2_BANCO+' Ag: '+Z2_AGENCIA+'-'+Z2_DIGAGEN+' C/C: '+Z2_CONTA+'-'+Z2_DIGCONT"+CRLF
	cQuery += "	 		ELSE '' END)"+" AS Z2CONTA"+CRLF

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
	cQuery += "	 	 		AND SZ2.Z2_CODEMP  = '"+cEmpr+"' "+CRLF
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
	cQuery += "	 	 		AND SZ2T.Z2_CODEMP = '"+cEmpr+"'"+CRLF
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
//cQuery += "  ,ISNULL(Z2_BORDERO,E2_XXLOTEB) AS LOTE"+CRLF
cQuery += "  ,(CASE WHEN ISNULL(Z2_BORDERO,E2_XXLOTEB) = ' ' THEN E2_XXLOTEB ELSE ISNULL(Z2_BORDERO,E2_XXLOTEB) END) AS LOTE"+CRLF
cQuery += "  FROM RESUMO " + CRLF
cQuery += " ORDER BY EMPRESA,E2_PORTADO,FORMPGT,E2_FORNECE" + CRLF

//u_LogMemo("RESTTITCP.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySE2,.T.,.T.)

Return Nil


User Function CPDadosPgt(cQrySE2)
// Forma de Pagamento = BKFINR06
Local cxTipoPg	:= (cQrySE2)->F1_XTIPOPG
Local cxNumPa	:= (cQrySE2)->F1_XNUMPA
Local cxTpPix	:= ""
Local cxChPix	:= ""
Local cFormaPgto:= ""

If !Empty(cxTipoPg)
	cFormaPgto := TRIM(cxTipoPg)
	If TRIM(cxTipoPg) == "DEPOSITO"
		If Empty((cQrySE2)->F1_XBANCO) .AND. !IsFornBK((cQrySE2)->F1_FORNECE)
	 		cDadosBanc := "Bco: "+ALLTRIM((cQrySE2)->A2_BANCO)+" Ag: "+ALLTRIM((cQrySE2)->A2_AGENCIA)+" C/C: "+ALLTRIM((cQrySE2)->A2_NUMCON)
		Else
			cDadosBanc := "Bco: "+ALLTRIM((cQrySE2)->F1_XBANCO)+" Ag: "+ALLTRIM((cQrySE2)->F1_XAGENC)+" C/C: "+ALLTRIM((cQrySE2)->F1_XNUMCON)
	 	EndIf
		cFormaPgto += ": "+cDadosBanc
	ElseIf TRIM(cxTipoPg) == "P.A."
		cFormaPgto += " "+cxNumPa
	ElseIf TRIM(cxTipoPg) == "PIX"
		cxTpPix  := (cQrySE2)->F1_XXTPPIX
		cxChPix  := AllTrim((cQrySE2)->F1_XXCHPIX)
		cFormaPgto += " - "+X3COMBO('F72_TPCHV',cxTpPix)
		If Len(cxChPix) <= 50
			cFormaPgto += ": "+cxChPix
			cxChPix := ""
		EndIf
	EndIf
ElseIf !Empty((cQrySE2)->Z2CONTA)

	cFormaPgto += TRIM((cQrySE2)->Z2CONTA)

	If TRIM((cQrySE2)->E2_XXTIPBK) == "PEN"
		cFormaPgto += " "+ALLTRIM(IIF(!EMPTY((cQrySE2)->Z2_NOMMAE),(cQrySE2)->Z2_NOMMAE,(cQrySE2)->Z2_NOMDEP))
	Else
		cFormaPgto += " "+TRIM((cQrySE2)->Z2_NOME)
	EndIf
	//If !EMPTY(cLinObs) .and. !EMPTY(QSZ2->Z2_OBSTITU)
	//	cLinObs += " - "
	//EndIf
ElseIf !Empty((cQrySE2)->E2_XXTIPBK)
	cFormaPgto += '#RH#'
EndIf

Return cFormaPgto


// Marca empresa que tem integração RH Pendente
Static Function IntegEmp(aEmpresas)
Local cQuery 	 := "SELECT Z2_CODEMP FROM SZ2010 SZ2 "+ ;
					" WHERE SZ2.Z2_STATUS = ' ' "+;
					"   AND SZ2.D_E_L_E_T_ = '' "+;
					" GROUP BY Z2_CODEMP"

Local aReturn 	:= {}
Local aBinds 	:= {}
Local aSetFields:= {}
Local nRet		:= 0
Local lRet      := .F.
Local nQ 		:= 0
Local nE 		:= 0

// Ajustes de tratamento de retorno
aadd(aSetFields,FWSX3Util():GetFieldStruct( "Z2_CODEMP" ))

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

If nRet < 0
	u_MsgLog("IntegEmp",tcsqlerror()+" Falha ao executar a Query: "+cQuery)
Else
	//u_MsgLog("IntegEmp",VarInfo("aReturn",aReturn))
	If Len(aReturn) > 0
		For nQ := 1 To Len(aReturn)
			nE := aScan(aEmpresas,{|x| x[1] == SUBSTR(aReturn[nQ,1],1,2) })
			If nE > 0
				aEmpresas[nE,2] += " - integração pendente"			
			EndIf
		Next
		lRet := .T.
	EndIf
Endif

Return lRet

