#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#Include "PROTHEUS.CH"
#Include "TBICONN.CH"

// Obs: Não está concluído

/*/{Protheus.doc} RestLibDc
    REST para Liberação de Documentos / PC - MATA094
    @type  REST
    @author Marcos B. Abrahão
    @since 08/02/2022
    @version 12.1.33
/*/

WSRESTFUL RestLibDc DESCRIPTION "Rest Liberação de Documentos"

	WSDATA mensagem     AS STRING
	WSDATA empresa      AS STRING
	WSDATA filial       AS STRING
	WSDATA userlib 		AS STRING OPTIONAL
	WSDATA documento	AS STRING

	WSDATA page         AS INTEGER OPTIONAL
	WSDATA pageSize     AS INTEGER OPTIONAL

	WSMETHOD GET LISTDC;
		DESCRIPTION "Listar Documentos Pendentes";
		WSSYNTAX "/RestLibDc/v0";
		PATH  "/RestLibDc/v0";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET CONSDC;
		DESCRIPTION "Retorna dados do Documento";
		WSSYNTAX "/RestLibDc/v1";
		PATH "/RestLibDc/v1";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET BROWDC;
		DESCRIPTION "Browse Documentos Pendentes";
		WSSYNTAX "/RestLibDc/v2";
		PATH "/RestLibDc/v2";
		TTALK "v1";
		PRODUCES TEXT_HTML

	WSMETHOD GET DOWNLDC;
		DESCRIPTION "Retorna um arquivo por meio do método FwFileReader().";
		WSSYNTAX "/RestLibDc/v4";
		PATH "/RestLibDc/v4";
		TTALK "v1"

	WSMETHOD PUT LIBDOC;
		DESCRIPTION "Liberação de Documentos" ;
		WSSYNTAX "/RestLibDc/v3";
		PATH "/RestLibDc/v3";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET CONSPC;
		DESCRIPTION "Retorna dados do Pedido de Compras";
		WSSYNTAX "/RestLibDc/v5";
		PATH "/RestLibDc/v5";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD PUT LIBPC;
		DESCRIPTION "Liberação de Pedidos de Compras" ;
		WSSYNTAX "/RestLibDc/v6";
		PATH "/RestLibDc/v6";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL


// v4
WSMETHOD GET DOWNLDC QUERYPARAM empresa,documento WSREST RestLibDc
    Local cFile  := ""// VALORES RETORNADOS NA LEITURA
	Local cName  := Decode64(self:documento)
	Local cFName := "/dirdoc/co"+self:empresa+"/shared/"+cName
    Local oFile  := FwFileReader():New(cFName) // CAMINHO ABAIXO DO ROOTPATH

    // SE FOR POSSÍVEL ABRIR O ARQUIVO, LEIA-O
    // SE NÃO, EXIBA O ERRO DE ABERTURA
    If (oFile:Open())
        cFile := oFile:FullRead() // EFETUA A LEITURA DO ARQUIVO

        // RETORNA O ARQUIVO PARA DOWNLOAD
        Self:SetHeader("Content-Disposition", "attachment; filename="+cName)
        Self:SetResponse(cFile)

        lSuccess := .T. // CONTROLE DE SUCESSO DA REQUISIÇÃO
    Else
        SetRestFault(002, "can't load file") // GERA MENSAGEM DE ERRO CUSTOMIZADA

        lSuccess := .F. // CONTROLE DE SUCESSO DA REQUISIÇÃO
    EndIf
Return (lSuccess)


// v3
WSMETHOD PUT LIBDOC QUERYPARAM empresa,documento,userlib,liberacao WSREST RestLibDc

Local cJson        := Self:GetContent()   
Local lRet         := .T.
//	Local lLib         := .T.
//	Local oJson        As Object
//  Local cCatch       As Character  
Local oJson        As Object
Local aParams      As Array
Local cMsg         As Char


	//Define o tipo de retorno do servico
	::setContentType('application/json')

	//oJson  := JsonObject():New()
	//cCatch := oJson:FromJSON(cJson)

	oJson := JsonObject():New()
  	oJson:FromJSON(cJson)

	//If cCatch == Nil
	//PrePareContexto(::empresa,::filial)

	If u_BkAvPar(::userlib,@aParams,@cMsg)

		lRet := fLibDC(::empresa,::documento,@cMsg)

	EndIf

	oJson['liberacao'] := StrIConv( "Documento "+cMsg, "CP1252", "UTF-8")

	cRet := oJson:ToJson()

  	FreeObj(oJson)

 	Self:SetResponse(cRet)
  
Return lRet


Static Function fLibDC(empresa,documento,cMsg)
Local lRet 		:= .F.
Local cQuery	:= ""
Local cTabSF1	:= "SF1"+empresa+"0"
Local cQrySF1	:= GetNextAlias()
Local cDoc		:= ""
Default cMsg	:= ""

Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

cQuery := "SELECT SF1.F1_XXLIB,SF1.F1_STATUS,SF1.F1_DOC,SF1.D_E_L_E_T_ AS F1DELET"+CRLF
cQuery += " FROM "+cTabSF1+" SF1"+CRLF
cQuery += " WHERE SF1.R_E_C_N_O_ = "+documento+CRLF

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySF1,.T.,.T.)
If !(cQrySF1)->(Eof()) 
	cDoc := (cQrySF1)->F1_DOC
EndIf

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
		cQuery += " WHERE SF1.R_E_C_N_O_ = "+documento+CRLF

		If TCSQLExec(cQuery) < 0 
			cMsg := "Erro: "+TCSQLERROR()
		Else
			cMsg := "liberada"
			lRet := .T.
		EndIf
	OtherWise 
		cMsg:= "não pode ser liberada por motivo indefinido"
EndCase

cMsg := cDoc+" "+cMsg

(cQrySF1)->(dbCloseArea())

Return lRet


/*/{Protheus.doc} GET 

Retorna a lista de Documentos Pendentes.
 
@param 
 Page , numerico, numero da pagina 
 PageSize , numerico, quantidade de registros por pagina
 
@return cResponse , caracter, JSON contendo a lista de Pré-notas
/*/


WSMETHOD GET LISTDC QUERYPARAM userlib WSREST RestLibDc
Local aEmpresas		:= {}
Local aListSales 	:= {}
Local cQrySCR       := GetNextAlias()
Local cJsonCli      := ''
Local lRet 			:= .T.
Local oJsonSales 	:= JsonObject():New()

Local aParams      	As Array
Local cMsg         	As Character
Local nE			:= 0
Local cEmpresa		:= ""
Local cNomeEmp		:= 0
Local cTabSCR		:= ""
Local cTabSA2		:= ""
Local cTabSC1		:= ""
Local cQuery		:= ""
Local cStatus		:= ""

aEmpresas := u_BKGrupo()

//-------------------------------------------------------------------
// Query para selecionar os Documentos
//-------------------------------------------------------------------

If !u_BkAvPar(::userlib,@aParams,@cMsg)
  oJsonSales['liberacao'] := cMsg

  cRet := oJsonSales:ToJson()

  FreeObj(oJsonSales)

  //Retorno do servico
  ::SetResponse(cRet)

  Return lRet:= .t.
EndIf

dbSelectArea("SAK")
dbSetOrder(2)
If !MsSeek(xFilial("SAK")+RetCodUsr())
	cMsg := "Usuário não esta cadastrado como aprovador"
	
	oJsonSales['liberacao'] := StrIConv( cMsg, "CP1252", "UTF-8")
	cRet := oJsonSales:ToJson()
	FreeObj(oJsonSales)

	//Retorno do servico
	::SetResponse(cRet)
	Return lRet:= .t.
EndIf


For nE := 1 To Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabSCR := "SCR"+cEmpresa+"0"
	cTabSA2 := "SA2"+cEmpresa+"0"
	cTabSC1 := "SC1"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += "SELECT "+CRLF
	cQuery += "		'"+cEmpresa+"' AS CREMPRESA,"+CRLF
	cQuery += "		'"+cNomeEmp+"' AS CRNOMEEMP,"+CRLF
	cQuery += "		CR_FILIAL,"+CRLF
	cQuery += "		SCR.R_E_C_N_O_ AS CRRECNO,"+CRLF
	cQuery += "		CR_NUM,"+CRLF
	cQuery += "		CR_TIPO,"+CRLF
	cQuery += "		CR_USER,"+CRLF
	cQuery += "		CR_APROV,"+CRLF
	cQuery += "		CR_STATUS,"+CRLF
	cQuery += "		CR_DATALIB,"+CRLF
	//cQuery += "	CR_OBS,"+CRLF
	cQuery += "		CR_TOTAL,"+CRLF
	cQuery += "		CR_EMISSAO,"+CRLF
	cQuery += "		CR_GRUPO"+CRLF
	//cQuery += "	CR_PRAZO,"+CRLF
	//cQuery += "	CR_AVISO"+CRLF
				
	cQuery += "FROM "+cTabSCR+" SCR"+CRLF

	//cQuery += "		INNER JOIN "+cTabSA2+" SA2 "+CRLF
	//cQuery += "			ON SF1.F1_FORNECE = SA2.A2_COD AND SF1.F1_LOJA = SA2.A2_LOJA"+CRLF
	//cQuery += "			AND SA2.A2_FILIAL = '"+xFilial('SA2')+"' "+CRLF
	//cQuery += "			AND SA2.D_E_L_E_T_ = ' '"+CRLF

	cQuery += "WHERE SCR.D_E_L_E_T_ = ' '"+CRLF
	cQuery += "		 AND SCR.CR_FILIAL = '"+xFilial('SCR')+"' "+CRLF
	cQuery += "  AND CR_STATUS = '02'"+CRLF
	cQuery += "  AND CR_USER   = '"+__cUserId+"'"+CRLF
	
	// Solicitações de Compras
	cQuery += "UNION ALL "+CRLF
	
	cQuery += "SELECT "+CRLF
	cQuery += "		'"+cEmpresa+"'  AS CREMPRESA,"+CRLF
	cQuery += "		'"+cNomeEmp+"'  AS CRNOMEEMP,"+CRLF
	cQuery += "		C1_FILIAL       AS CR_FILIAL,"+CRLF
	cQuery += "		MIN(SC1.R_E_C_N_O_)  AS CRRECNO,"+CRLF
	cQuery += "		C1_NUM          AS CR_NUM,"+CRLF
	cQuery += "		'SC'            AS CR_TIPO,"+CRLF
	cQuery += "		MIN(C1_USER)    AS CR_USER,"+CRLF
	cQuery += "		MIN(C1_NOMAPRO) AS CR_APROV,"+CRLF
	cQuery += "		MIN(C1_APROV)   AS CRSTATUS,"+CRLF
	cQuery += "		MIN(C1_XDTAPRV) AS CR_DATALIB,"+CRLF
	cQuery += "		SUM(C1_XXLCTOT) AS CR_TOTAL,"+CRLF
	cQuery += "		MIN(C1_EMISSAO) AS CR_EMISSAO,"+CRLF
	cQuery += "		''              AS CR_GRUPO"+CRLF

	cQuery += " FROM "+cTabSC1+" SC1"+CRLF
	cQuery += " WHERE SC1.D_E_L_E_T_ = ' '"+CRLF
	cQuery += "		 AND SC1.C1_FILIAL = '"+xFilial('SC1')+"' "+CRLF
	// Filtro Advpl: C1_QUJE == 0 .And. (C1_COTACAO == Space(Len(C1_COTACAO)) .Or. C1_COTACAO == "IMPORT") .And. C1_APROV == "B" .AND. Empty(C1_RESIDUO)
	cQuery += "  AND C1_QUJE    = 0"	+CRLF
	cQuery += "  AND C1_COTACAO = ' '"	+CRLF
	cQuery += "  AND C1_APROV   = 'B'"	+CRLF
	cQuery += "  AND C1_RESIDUO = ' '"	+CRLF
	cQuery += " GROUP BY  "		+CRLF
	cQuery += "  C1_FILIAL,"	+CRLF
	cQuery += "  C1_NUM"		+CRLF

Next

cQuery += "ORDER BY SCR.CR_EMISSAO,SCR.CR_TIPO,SCR.CR_NUM"+CRLF

u_LogMemo("RESTLIBDC.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySCR,.T.,.T.)

( cQrySCR )->( DBGoTop() )

//-------------------------------------------------------------------
// Alimenta array de Documentos
//-------------------------------------------------------------------
Do While ( cQrySCR )->( ! Eof() )

	cStatus  := "Liberar"

	aAdd( aListSales , JsonObject():New() )
	nPos := Len(aListSales)
	aListSales[nPos]['CREMPRESA']  := (cQrySCR)->CREMPRESA
	aListSales[nPos]['CRNOMEEMP']  := (cQrySCR)->CRNOMEEMP
	aListSales[nPos]['NUM']        := TRIM((cQrySCR)->CR_NUM)
	aListSales[nPos]['TIPO']       := (cQrySCR)->CR_TIPO
	aListSales[nPos]['USER'] 	   := UsrRetName((cQrySCR)->CR_USER)
	aListSales[nPos]['APROV']	   := UsrRetName((cQrySCR)->CR_APROV)
	aListSales[nPos]['GRUPO']	   := UsrRetName((cQrySCR)->CR_GRUPO)
	aListSales[nPos]['EMISSAO']    := DTOC(STOD((cQrySCR)->CR_EMISSAO))
	aListSales[nPos]['DATALIB']    := DTOC(STOD((cQrySCR)->CR_DATALIB))
	aListSales[nPos]['TOTAL']      := TRANSFORM((cQrySCR)->CR_TOTAL,"@E 999,999,999.99")
	aListSales[nPos]['CRRECNO']    := STRZERO((cQrySCR)->CRRECNO,7)
	aListSales[nPos]['STATUS']     := cStatus

	(cQrySCR)->(DBSkip())

EndDo

( cQrySCR )->( DBCloseArea() )

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


WSMETHOD GET CONSDC QUERYPARAM empresa,documento,userlib WSREST RestLibDc

Local oJsonPN	:= JsonObject():New()
Local cRet		:= ""
Local cQuery	:= ""
Local cTabSF1	:= "SF1"+self:empresa+"0"
Local cTabSD1	:= "SD1"+self:empresa+"0"
Local cTabSA2	:= "SA2"+self:empresa+"0"
Local cTabSB1	:= "SB1"+self:empresa+"0"
Local cQrySF1	:= GetNextAlias()
Local aItens	:= {}
Local aAnexos	:= {}
Local nI		:= 0
Local aEmpresas	As Array
Local aParams	As Array
Local cMsg		As Character
Local cHist		:= ""
Local aParcelas := {}
Local cParcelas := ""
Local nGeral	:= 0
Local aFiles	:= {}

aEmpresas := u_BKGrupo()
u_BkAvPar(::userlib,@aParams,@cMsg)

cQuery := "SELECT "+CRLF
cQuery += "		SF1.F1_DOC,SF1.F1_SERIE,SF1.F1_EMISSAO,SF1.F1_DTDIGIT,F1_XXPVPGT,F1_ESPECIE,F1_XXUSER,"+CRLF
cQuery += "		SF1.F1_FORNECE,SF1.F1_LOJA,SA2.A2_NOME,SA2.A2_CGC,SA2.A2_EST,SA2.A2_MUN,"+CRLF
cQuery += "		SF1.F1_XXLIB,SF1.F1_XXJSPGT,"+CRLF
cQuery += "		SD1.D1_ITEM,SD1.D1_COD,SB1.B1_DESC,D1_TOTAL,(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) AS D1_GERAL,"+CRLF
cQuery += "		SD1.D1_QUANT,SD1.D1_VUNIT,SB1.B1_DESC,SD1.D1_CC,SD1.D1_XXDCC,"+CRLF
cQuery += "		CONVERT(VARCHAR(2000),CONVERT(Binary(2000),SD1.D1_XXHIST)) D1_XXHIST,"+CRLF
cQuery += "		CONVERT(VARCHAR(2000),CONVERT(Binary(2000),SF1.F1_XXPARCE)) F1_XXPARCE,"+CRLF
cQuery += "		CONVERT(VARCHAR(2000),CONVERT(Binary(2000),SF1.F1_HISTRET)) F1_HISTRET"+CRLF

cQuery += "FROM "+cTabSF1+" SF1"+CRLF

cQuery += "		INNER JOIN "+cTabSA2+" SA2 "+CRLF
cQuery += "			ON SF1.F1_FORNECE = SA2.A2_COD AND SF1.F1_LOJA = SA2.A2_LOJA"+CRLF
cQuery += "			AND SA2.A2_FILIAL = '"+xFilial('SA2')+"' "+CRLF
cQuery += "			AND SA2.D_E_L_E_T_ = ' '"+CRLF

cQuery += "		INNER JOIN "+cTabSD1+" SD1 "+CRLF
cQuery += "			ON D1_FILIAL = F1_FILIAL AND D1_DOC=F1_DOC AND D1_SERIE=F1_SERIE AND D1_FORNECE=F1_FORNECE AND D1_LOJA=F1_LOJA"+CRLF
cQuery += "			AND SD1.D_E_L_E_T_ = ' ' "+CRLF

cQuery += " 	INNER JOIN "+cTabSB1+" SB1 ON  SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SD1.D1_COD=SB1.B1_COD AND SB1.D_E_L_E_T_=''" +CRLF

cQuery += "WHERE SF1.R_E_C_N_O_ = "+self:documento+CRLF

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

// Documentos anexos
aFiles := u_BKDocs(self:empresa,"SF1",(cQrySF1)->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
For nI := 1 To Len(aFiles)
	aAdd(aAnexos,JsonObject():New())
	aAnexos[nI]["F1_ANEXO"]		:= aFiles[nI,1]
	aAnexos[nI]["F1_ENCODE"]	:= aFiles[nI,2]
Next
oJsonPN['F1_ANEXOS']	:= aAnexos

If !Empty((cQrySF1)->F1_HISTRET)
	cHist += AllTrim(((cQrySF1)->F1_HISTRET))
EndIf
If !Empty((cQrySF1)->F1_XXJSPGT)
	cHist += "JUSTIFICATIVA: ***" +AllTrim(((cQrySF1)->F1_XXJSPGT))+" ***"+CRLF
EndIf

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
       cHist += STRTRAN(LTRIM((cQrySF1)->D1_XXHIST),CRLF," ")
    EndIf
	nGeral += (cQrySF1)->D1_GERAL
	dbSkip()
EndDo

//cHist := STRTRAN(cHist,CRLF," ")
oJsonPN['D1_XXHIST']	:= StrIConv( cHist, "CP1252", "UTF-8")  //CP1252  ISO-8859-1
oJsonPN['D1_ITENS']		:= aItens
oJsonPN['F1_GERAL']		:= TRANSFORM(nGeral,"@E 999,999,999.99")


(cQrySF1)->(dbCloseArea())

cRet := oJsonPN:ToJson()

FreeObj(oJsonPN)

//Retorno do servico
::SetResponse(cRet)

return .T.


WSMETHOD GET CONSPC QUERYPARAM empresa,documento,userlib WSREST RestLibDc

Local oJsonPN	:= JsonObject():New()
Local cRet		:= ""
Local cQuery	:= ""
Local cTabSC7	:= "SC7"+self:empresa+"0"
Local cTabSC1	:= "SC1"+self:empresa+"0"
Local cTabSC8	:= "SC8"+self:empresa+"0"
Local cTabSA2	:= "SA2"+self:empresa+"0"
Local cPedido 	:= TRIM(self:documento)
Local cQrySC7	:= GetNextAlias()
Local aItens	:= {}
Local nI		:= 0
Local aEmpresas	As Array
Local aParams	As Array
Local cMsg		As Character
Local nGeral	:= 0

aEmpresas := u_BKGrupo()
u_BkAvPar(::userlib,@aParams,@cMsg)

cQuery := "SELECT "+CRLF
cQuery += "  A2_NOME,"		+CRLF
cQuery += "  C1_CC,"		+CRLF
cQuery += "  C1_DATPRF,"	+CRLF
cQuery += "  C1_DESCRI,"	+CRLF
cQuery += "  C1_EMISSAO,"	+CRLF
cQuery += "  C1_ITEM,"		+CRLF
cQuery += "  C1_NUM,"		+CRLF
cQuery += "  C1_OBS,"		+CRLF
cQuery += "  C1_PRODUTO,"	+CRLF
cQuery += "  C1_QUANT-C1_XXQEST AS C1_QUANT,"	+CRLF
cQuery += "  C1_SOLICIT,"	+CRLF
cQuery += "  C1_UM,"		+CRLF
cQuery += "  C1_XXDCC,"		+CRLF
cQuery += "  C1_XXLCTOT,"	+CRLF
cQuery += "  C1_XXLCVAL,"	+CRLF
cQuery += "  C1_XXMTCM,"	+CRLF
cQuery += "  C1_XXOBJ,"		+CRLF
cQuery += "  C7_COND,"		+CRLF
cQuery += "  C7_DATPRF,"	+CRLF
cQuery += "  C7_EMISSAO,"	+CRLF
cQuery += "  C7_FORNECE,"	+CRLF
cQuery += "  C7_LOJA,"		+CRLF
cQuery += "  C7_ITEM,"		+CRLF
cQuery += "  C7_NUM,"		+CRLF
cQuery += "  C7_USER,"		+CRLF
cQuery += "  C7_XXURGEN,"	+CRLF
cQuery += "  C8_COND,"		+CRLF
cQuery += "  C8_EMISSAO,"	+CRLF
cQuery += "  C8_FORNECE,"	+CRLF
cQuery += "  C8_ITEM,"		+CRLF
cQuery += "  C8_ITEMPED,"	+CRLF
cQuery += "  C8_MOTIVO,"	+CRLF
cQuery += "  C8_NUM,"		+CRLF
cQuery += "  C8_NUMPED,"	+CRLF
cQuery += "  CONVERT(VARCHAR(1000),CONVERT(Binary(1000),C8_OBS)) C8_OBS,"		+CRLF
cQuery += "  C8_PRECO,"		+CRLF
cQuery += "  C8_PRODUTO,"	+CRLF
cQuery += "  C8_QUANT,"		+CRLF
cQuery += "  C8_TOTAL,"		+CRLF
cQuery += "  C8_UM,"		+CRLF
cQuery += "  C8_VALIDA,"	+CRLF
cQuery += "  C8_XXDESCP,"	+CRLF
cQuery += "  C8_XXNFOR,"	+CRLF
cQuery += "  CASE WHEN C8_NUMPED = C7_NUM AND C8_ITEMPED = C7_ITEM THEN 'Vencedor' ELSE '' END AS STATUS,"	+CRLF
cQuery += "  CASE WHEN C8_NUMPED = C7_NUM AND C8_ITEMPED = C7_ITEM THEN C7_DATPRF ELSE '' END AS C7_DATPRF"+CRLF

cQuery += " FROM "+cTabSC7+" SC7"+CRLF

cQuery += "	LEFT JOIN "+cTabSA2+" SA2 "+CRLF
cQuery += "		ON C7_FORNECE = A2_COD AND C7_LOJA = C7_LOJA AND A2_FILIAL = '"+xFilial("SA2")+"' AND SA2.D_E_L_E_T_ = ''"+CRLF

cQuery += "	INNER JOIN "+cTabSC1+" SC1 "+CRLF
cQuery += "		ON C7_NUMSC = C1_NUM AND C7_ITEMSC = C1_ITEM AND C1_FILIAL = C7_FILIAL AND SC1.D_E_L_E_T_ = ''"+CRLF

cQuery += "	INNER JOIN "+cTabSC8+" SC8 "+CRLF
cQuery += "		ON C7_NUMCOT = C8_NUM  AND C8_NUMSC = C1_NUM AND C8_ITEMSC = C1_ITEM AND C8_FILIAL = C7_FILIAL AND SC8.D_E_L_E_T_ = ''"+CRLF

cQuery += "WHERE C7_NUM = '"+cPedido+"'" +CRLF
cQuery += "  AND SC7.D_E_L_E_T_ = '' "+CRLF

cQuery += "ORDER BY C1_CC,C7_ITEM"+CRLF

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySC7,.T.,.T.)
tcSetField(cQrySC7,"C8_EMISSAO","D",8,0)
tcSetField(cQrySC7,"C7_DATPRF","D",8,0)
tcSetField(cQrySC7,"C8_VALIDA","D",8,0)

u_LogMemo("RESTLIBDC"+cPedido+".SQL",cQuery)

dbSelectArea(cQrySC7)
dbGoTop()

oJsonPN['USERNAME']		:= cUserName
oJsonPN['EMPRESA']		:= aEmpresas[aScan(aEmpresas,{|x| x[1] == self:empresa }),2]
oJsonPN['C7_NUM']		:= (cQrySC7)->C7_NUM
oJsonPN['C7_EMISSAO']	:= DTOC((cQrySC7)->C8_EMISSAO)
oJsonPN['C7_XXUSER']	:= UsrRetName((cQrySC7)->C7_USER)
oJsonPN['C7_XFORN']		:= (cQrySC7)->C7_FORNECE+"-"+(cQrySC7)->C7_LOJA+" - "+TRIM((cQrySC7)->A2_NOME)
oJsonPN['C7_XXURGEN']	:= (cQrySC7)->C7_XXURGEN

/*
If !Empty((cQrySC7)->F1_HISTRET)
	cHist += AllTrim(((cQrySC7)->F1_HISTRET))+" "
EndIf
*/
nI := 0
Do While (cQrySC7)->(!EOF())
	aAdd(aItens,JsonObject():New())
	nI++
/*
					<th scope="col">Item</th>
					<th scope="col">Prod.</th>
					<th scope="col">Descrição</th>
					<th scope="col">UM</th>
					<th scope="col" style="text-align:right;">Quant.</th>
					<th scope="col">Emissão</th>
					<th scope="col">Limite Entrega</th>
					<th scope="col">Motivo/Status Cotação</th>

					<th scope="col" style="text-align:right;">V.Lic/Cotado</th>
					<th scope="col" style="text-align:right;">T.Lic/Cotado</th>

					<th scope="col">Obs/Forma Pgto.</th>
					<th scope="col">Contrato/Forn.</th>
					<th scope="col">Desc. Contrato/Nome Forn.</th>
					<th scope="col">Detalhes</th>
*/

	aItens[nI]["C8_ITEM"]	:= (cQrySC7)->C8_ITEM
	aItens[nI]["C1_XXDCC"]	:= TRIM((cQrySC7)->C1_XXDCC)
	aItens[nI]["C8_PRODUTO"]:= TRIM((cQrySC7)->C8_PRODUTO)
	aItens[nI]["C8_XXDESCP"]:= TRIM((cQrySC7)->C8_XXDESCP)
	aItens[nI]["C8_UM"]		:= TRIM((cQrySC7)->C8_UM)
	aItens[nI]["C8_QUANT"]	:= TRANSFORM((cQrySC7)->C8_QUANT,"@E 99999999.99")
	aItens[nI]["C8_EMISSAO"]:= DTOC((cQrySC7)->C8_EMISSAO)
	aItens[nI]["C7_DATPRF"]	:= IIF((cQrySC7)->(C8_NUMPED == C7_NUM) .AND. (cQrySC7)->(C8_ITEMPED == C7_ITEM) ,DTOC((cQrySC7)->C7_DATPRF),"")
	aItens[nI]["C8_STATUS"]	:= IIF((cQrySC7)->(C8_NUMPED == C7_NUM) .AND. (cQrySC7)->(C8_ITEMPED == C7_ITEM) ,"Vencedor","")
	aItens[nI]["C8_PRECO"]	:= TRANSFORM((cQrySC7)->C8_PRECO,"@E 999,999,999.9999")
	aItens[nI]["C8_TOTAL"]	:= TRANSFORM((cQrySC7)->C8_TOTAL,"@E 999,999,999.99")
	aItens[nI]["C7_COND"]	:= TRIM((cQrySC7)->C7_COND)
	aItens[nI]["C8_FORNECE"]:= TRIM((cQrySC7)->C8_FORNECE)
	aItens[nI]["C8_XXNFOR"]	:= TRIM((cQrySC7)->C8_XXNFOR)
	aItens[nI]["C8_VALIDA"]	:= DTOC((cQrySC7)->C8_VALIDA)
	aItens[nI]["C8_OBS"]	:= TRIM((cQrySC7)->C8_OBS)

	// Detalhes
	/*
	SC1->C1_SOLICIT,
	SC1->C1_NUM,
	SC1->C1_QUANT-SC1->C1_XXQEST,
	SC1->C1_EMISSAO,
	SC1->C1_DATPRF,
	aMotivo[val(SC1->C1_XXMTCM)],
	TRANSFORM(SC1->C1_XXLCVAL,"@E 999,999,999.99"),
	TRANSFORM(SC1->C1_XXLCTOT,"@E 999,999,999.99"),
	"Obs: "+TRIM(SC1->C1_OBS),"Contrato: "+SC1->C1_CC,"Desc.Contr: "+SC1->C1_XXDCC,"Objeto: "+SC1->C1_XXOBJ})
	"Validade da Proposta: "+DTOC(SC8->C8_VALIDA)+"      "+IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM,IIF(ALLTRIM(SC8->C8_MOTIVO) == "ENCERRADO AUTOMATICAMENTE","X - Vencedor Indicado Pelo Sistema","* - Fornecedor Selecionado Pelo Usuário"),"")+IIF(!EMPTY(SC8->C8_OBS),"   OBS:"+SC8->C8_OBS,"")})
*/
	If (cQrySC7)->(C8_NUMPED == C7_NUM) .AND. (cQrySC7)->(C8_ITEMPED == C7_ITEM)
		nGeral += (cQrySC7)->C8_TOTAL
	EndIf
	dbSkip()
EndDo

//cHist := STRTRAN(cHist,CRLF," ")
//oJsonPN['D1_XXHIST']	:= StrIConv( cHist, "CP1252", "UTF-8")  //CP1252  ISO-8859-1
oJsonPN['C7_ITENS']		:= aItens
oJsonPN['C8_GERAL']		:= TRANSFORM(nGeral,"@E 999,999,999.99")

*/

(cQrySC7)->(dbCloseArea())

cRet := oJsonPN:ToJson()

FreeObj(oJsonPN)

//Retorno do servico
::SetResponse(cRet)

return .T.




WSMETHOD GET BROWDC QUERYPARAM userlib WSREST RestLibDc

local cHTML as char

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

<link href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css">


<title>Liberação de Documentos</title>
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
	<a class="navbar-brand" href="#">BK - Liberação de Documentos</a>
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
<table id="tableSCR" class="table">
<thead>
<tr>
<th scope="col">Empresa</th>
<th scope="col">Documento</th>
<th scope="col">Tipo</th>
<th scope="col">Usuário</th>
<th scope="col">Aprovador</th>
<th scope="col">Grupo</th>
<th scope="col">Emissão</th>
<th scope="col">Data Lib.</th>
<th scope="col" style="text-align:center;">Total</th>
<th scope="col" style="text-align:center;">Ação</th>
</tr>
</thead>
<tbody id="mytable">
<tr>
  <th scope="col">Carregando documentos...</th>
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col"></th>
  <th scope="col" style="text-align:center;"></th>
  <th scope="col" style="text-align:center;"></th>
</tr>
</tbody>
</table>
</div>
</div>
<!-- Modal Doc de Entrada -->
<div id="docModal" class="modal fade" role="dialog">
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

            <div class="col-12" id="anexos">
				<!-- <button type="submit" class="btn btn-primary">Sign in</button> -->
            </div>

          </form>

       </div>
        <!-- Rodapé do modal-->
       <div class="modal-footer">
         <button type="button" class="btn btn-outline-danger" data-bs-dismiss="modal">Fechar</button>
         <div id="btnlibNF"></div>
       </div>
     </div>
   </div>
</div>

<!-- Modal do Pedido de Compras -->
<div id="pcModal" class="modal fade" role="dialog">
  <div class="modal-dialog modal-fullscreen">
    <!-- Conteúdo do modal-->
    <div class="modal-content">
      <!-- Cabeçalho do modal -->
      <div class="modal-header bk-colors">
        <h4 id="titPC" class="modal-title">Pedido de Compra</h4>
        <button type="button" class="close" data-bs-dismiss="modal" aria-label="Close">
                <span aria-hidden="true">&times;</span>
        </button>
      </div>
      <!-- Corpo do modal -->
      <div class="modal-body">
         <form class="row g-3 font-condensed">
           
         <div class="col-md-1">
            <label for="pcDoc" class="form-label">Pedido</label>
            <input type="text" class="form-control form-control-sm" id="pcDoc" value="#pcDoc#" readonly="">
          </div>
          <div class="col-md-1">
            <label for="pcEmissao" class="form-label">Emissão</label>
            <input type="text" class="form-control form-control-sm" id="pcEmissao" value="#pcEmissao#" readonly="">
          </div>
          <div class="col-md-2">
            <label for="pcComprador" class="form-label">Comprador</label>
            <input type="text" class="form-control form-control-sm" id="pcComprador" value="#pcComprador#" readonly="">
          </div>
          <div class="col-md-6">
            <label for="pcForn" class="form-label">Fornecedor</label>
            <input type="text" class="form-control form-control-sm" id="pcForn" value="#pcForn#" readonly>
          </div>
		  <div class="container">
			<div class="table-responsive-sm">
			<table id="tableSC7" class="table ">
				<thead>
				<tr>
					<th ></th>
					<th scope="col">Item</th>
					<th scope="col">Contrato</th>
					<th scope="col">Prod.</th>
					<th scope="col">Descrição</th>
					<th scope="col">UM</th>
					<th scope="col" style="text-align:right;">Quant.</th>
					<th scope="col">Emissão</th>
					<th scope="col">Lim Entrega</th>
					<th scope="col">Motivo/Status Cotação</th>

					<th scope="col" style="text-align:right;">V.Lic/Cotado</th>
					<th scope="col" style="text-align:right;">T.Lic/Cotado</th>

					<th scope="col">Obs/Forma Pgto.</th>
					<th scope="col">Contrato/Forn.</th>
					<th scope="col">Desc. Contrato/Nome Forn.</th>
					<th scope="col">Detalhes</th>

				</tr>
				</thead>
				<tbody id="c7Table">
				<tr>
					<th scope="row" colspan="8" style="text-align:center;">Carregando itens...</th>
				</tr>
				</tbody>
				<tfoot id="c7Foot">
				<!-- <th scope="row" colspan="2" style="text-align:right;">Total Geral</th> -->
				</tfoot>
			</table>
			</div>
		</div>
    	</form>
    </div>
    <!-- Rodapé do modal-->
    <div class="modal-footer">
        <div id="c7Geral"></div>
        <button type="button" class="btn btn-outline-danger" data-bs-dismiss="modal">Fechar</button>
        <div id="btnlibPC"></div>
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
<!-- https://datatables.net/examples/styling/bootstrap5.html -->
<script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>

<!-- JavaScript Bundle with Popper -->
<!-- https://www.jsdelivr.com/package/npm/bootstrap -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js" integrity="sha256-gvZPYrsDwbwYJLD5yeBfcNujPhRoGOY831wwbIzz3t0=" crossorigin="anonymous"></script>

<!-- https://datatables.net/ -->
<script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js"></script>

<script>

async function getDcs() {
	let url = '#iprest#/RestLibDc/v0?userlib='+'#userlib#';
		try {
		let res = await fetch(url);
			return await res.json();
			} catch (error) {
		console.log(error);
			}
		}


async function loadTable() {
let documentos = await getDcs();
let trHTML = '';
if (Array.isArray(documentos)) {
    documentos.forEach(object => {

    let cStatus  = object['STATUS']
    let cTipoDoc = object['TIPO']

    trHTML += '<tr>';
    trHTML += '<td>'+object['CRNOMEEMP']+'</td>';
    trHTML += '<td>'+object['NUM']+'</td>';
    trHTML += '<td>'+object['TIPO']+'</td>';
    trHTML += '<td>'+object['USER']+'</td>';
    trHTML += '<td>'+object['APROV']+'</td>';
    trHTML += '<td>'+object['GRUPO']+'</td>';
    trHTML += '<td>'+object['EMISSAO']+'</td>';
    trHTML += '<td>'+object['DATALIB']+'</td>';
    trHTML += '<td align="right">'+object['TOTAL']+'</td>';

    if (cTipoDoc == 'NF'){
    	trHTML += '<td align="right"><button type="button" class="btn btn-outline-success btn-sm" onclick="showDC(\''+object['CREMPRESA']+'\',\''+object['CRRECNO']+'\',\'#userlib#\',1)">'+cStatus+'</button></td>';
  	} else {
     	trHTML += '<td align="right"><button type="button" class="btn btn-outline-warning btn-sm" onclick="showPC(\''+object['CREMPRESA']+'\',\''+object['NUM']+'\',\'#userlib#\',1)">'+cStatus+'</button></td>';
    }
	   
	trHTML += '</tr>';
    });
} else {
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="8" style="text-align:center;">'+documentos['liberacao']+'</th>';
    trHTML += '</tr>';   
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="8" style="text-align:center;">Faça login novamente no sistema Protheus</th>';
    trHTML += '</tr>';   
}
document.getElementById("mytable").innerHTML = trHTML;

$('#tableSCR').DataTable({
  "pageLength": 100,
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
   }
 });

}

loadTable();


async function getDC(f1empresa,f1recno,userlib) {
let url = '#iprest#/RestLibDc/v1?empresa='+f1empresa+'&documento='+f1recno+'&userlib='+userlib;
	try {
	let res = await fetch(url);
		return await res.json();
		} catch (error) {
	console.log(error);
		}
	}

async function showDC(f1empresa,f1recno,userlib,canLib) {
let documento = await getDC(f1empresa,f1recno,userlib);
let itens = ''
let i = 0
let foot = ''
let anexos = ''
document.getElementById('SF1Doc').value = documento['F1_DOC'];
document.getElementById('SF1Serie').value = documento['F1_SERIE'];
document.getElementById('SF1Emissao').value = documento['F1_EMISSAO'];
document.getElementById('SF1DtDigit').value = documento['F1_DTDIGIT'];
document.getElementById('SF1XXPvPgt').value = documento['F1_XXPVPGT'];
document.getElementById('SF1Especie').value = documento['F1_ESPECIE'];
document.getElementById('SF1XXUser').value = documento['F1_XXUSER'];

document.getElementById('SF1Forn').value = documento['F1_FORN'];
document.getElementById('SF1CGC').value = documento['A2_CGC'];
document.getElementById('SF1EstMun').value = documento['A2_ESTMUN'];

document.getElementById('SF1XXHist').value = documento['D1_XXHIST'];
document.getElementById('SF1XXParce').value = documento['F1_XXPARCE'];


if (canLib === 1){
	let btn = '<button type="button" class="btn btn-outline-success" onclick="libdoc(\''+f1empresa+'\',\''+f1recno+'\',\'#userlib#\')">Liberar</button>';
	document.getElementById("btnlibNF").innerHTML = btn;
}
if (Array.isArray(documento.D1_ITENS)) {
   documento.D1_ITENS.forEach(object => {
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

if (Array.isArray(documento.F1_ANEXOS)) {
	documento.F1_ANEXOS.forEach(object => {
	anexos += '<a href="#iprest#/RestLibDc/v4?empresa='+f1empresa+'&documento='+object['F1_ENCODE']+'" class="link-primary">'+object['F1_ANEXO']+'</a></br>';
  })
}
document.getElementById("anexos").innerHTML = anexos;

document.getElementById("d1Table").innerHTML = itens;
foot = '<th scope="row" colspan="9" style="text-align:right;">'+documento['F1_GERAL']+'</th>'
document.getElementById("d1Foot").innerHTML = foot;


$("#titLib").text('Aprovação de Documento de Entrada - Empresa: '+documento['EMPRESA'] + ' - Usuário: '+documento['USERNAME']);
$('#docModal').modal('show');
$('#docModal').on('hidden.bs.modal', function () {
	location.reload();
	})
}



async function libdoc(f1empresa,f1recno,userlib){
let dataObject = {liberacao:'ok'};
let resposta = ''

fetch('#iprest#/RestLibDc/v3?empresa='+f1empresa+'&documento='+f1recno+'&userlib='+userlib, {
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

	  //document.getElementById("titConf").innerHTML = data["liberacao"];
	  $("#titConf").text(data.liberacao);
	  $('#confModal').modal('show');
	  $('#confModal').on('hidden.bs.modal', function () {
	  $('#docModal').modal('toggle');
	  })
	})
}


async function getPC(c7empresa,c7num,userlib) {
let url = '#iprest#/RestLibDc/v5?empresa='+c7empresa+'&documento='+c7num+'&userlib='+userlib;
try {
let res = await fetch(url);
  return await res.json();
  } catch (error) {
console.log(error);
  }
}

function formatd ( d ) {
    // `d` is the original data object for the row
    return '<table cellpadding="5" cellspacing="0" border="0" style="padding-left:50px;">'+
        '<tr>'+
            '<td>Produto:</td>'+
            '<td>'+d[4]+'</td>'+
        '</tr>'+
        '<tr>'+
            '<td>Status:</td>'+
            '<td>'+d[15]+'</td>'+
        '</tr>'+
        '<tr>'+
            '<td>Obs:</td>'+
            '<td>'+d[16]+'</td>'+
        '</tr>'+
    '</table>';
}

async function showPC(c7empresa,c7num,userlib,canLib) {
let documento = await getPC(c7empresa,c7num,userlib);
let itens = ''
let i = 0
let foot = ''
let anexos = ''
let txtidel = '';
let txtedel = '';
//oJsonPN['C7_XXURGEN']	:= (cQrySC7)->C7_XXURGEN

document.getElementById('pcDoc').value = documento['C7_NUM'];
document.getElementById('pcEmissao').value = documento['C7_EMISSAO'];
document.getElementById('pcComprador').value = documento['C7_XXUSER'];
document.getElementById('pcForn').value = documento['C7_XFORN'];

//if (canLib === 1){
	let btn = '<button type="button" class="btn btn-outline-success" onclick="libpc(\''+c7empresa+'\',\''+c7num+'\',\'#userlib#\')">Liberar</button>';
	document.getElementById("btnlibPC").innerHTML = btn;
//}


const xarray = [];
if (Array.isArray(documento.C7_ITENS)) {
documento.C7_ITENS.forEach(object => {

  if (object['C8_STATUS'] == 'Vencedor'){
    txtidel = ' ';
    txtedel = ' ';
  } else {
    txtidel = '<del>';
    txtedel = '</del>';
  }

  const yarray = []
  yarray.push(null);
  yarray.push(txtidel+object['C8_ITEM']+txtedel);
  yarray.push(txtidel+object['C1_XXDCC']+txtedel);
  yarray.push(txtidel+object['C8_PRODUTO']+txtedel);
  yarray.push(txtidel+object['C8_XXDESCP']+txtedel);
  yarray.push(txtidel+object['C8_UM']+txtedel);
  yarray.push(txtidel+'<div align="right">'+object['C8_QUANT']+'</div>'+txtedel);
  yarray.push(txtidel+object['C8_EMISSAO']+txtedel);
  yarray.push(txtidel+object['C7_DATPRF']+txtedel);
  yarray.push(txtidel+'<div align="right">'+object['C8_PRECO']+'</div>'+txtedel);
  yarray.push(txtidel+'<div align="right">'+object['C8_TOTAL']+'</div>'+txtedel);
  yarray.push(txtidel+object['C7_COND']+txtedel);
  yarray.push(txtidel+object['C8_FORNECE']+txtedel);
  yarray.push(txtidel+object['C8_XXNFOR']+txtedel);
  yarray.push(txtidel+object['C8_VALIDA']+txtedel);
  yarray.push(txtidel+object['C8_STATUS']+txtedel);
  yarray.push(txtidel+object['C8_OBS']+txtedel);
  xarray.push(yarray);
i++
})
}

 var table7 = $('#tableSC7').DataTable( {
            data: xarray,
            paging: false,
            searching: false,
            columns: [
            {
                "className":      'dt-control',
                "orderable":      false,
                "defaultContent": ''
            },           
            { title: "Item" },
            { title: "Contrato" },
            { title: "Produto" },
            { title: "Descrição" },
            { title: "UM" },
            { title: "Quant." },
            { title: "Emissão" },
            { title: "Validade" },
            { title: "Preço" },
            { title: "Total" },
            { title: "Cond.Pgto." },
            { title: "Fornec." },
            { title: "Nome Fornecedor" },
            { title: "Valida" },
            { title: "Status" }
        ]
    } );

    // Add event listener for opening and closing details
    $('#tableSC7 tbody').on('click', 'td.dt-control', function () {
        var tr = $(this).closest('tr');
        var row = table7.row( tr );
 
        if ( row.child.isShown() ) {
            // This row is already open - close it
            row.child.hide();
            tr.removeClass('shown');
        }
        else {
            // Open this row
            row.child( formatd(row.data()) ).show();
            tr.addClass('shown');
        }
    } );   


//foot = '<th scope="row" colspan="9" style="text-align:right;">'+documento['C8_GERAL']+'</th>'
//document.getElementById("c7Foot").innerHTML = foot;

//foot += '  <input type="text" class="form-control form-control-sm" id="SF1Motivo" size="50" value="" placeholder="Obs ou Motivo do Estorno">';
foot =  '<th scope="row" style="text-align:left;font-weight: bold;">Total do Pedido:</th>'
foot += '<th scope="row" style="text-align:right;font-weight: 600;">'+documento['C8_GERAL']+'</th>'
foot += '<th scope="row" style="text-align:right;font-weight: bold;">&nbsp</th>'
foot += '<th scope="row" style="text-align:right;font-weight: bold;">&nbsp</th>'
foot += '<th scope="row" style="text-align:right;font-weight: bold;">&nbsp</th>'

document.getElementById("c7Geral").innerHTML = foot;


$("#titPC").text('Liberação de Pedido de Compra - Empresa: '+documento['EMPRESA'] + ' - Usuário: '+documento['USERNAME']);
$('#pcModal').modal('show');
$('#pcModal').on('hidden.bs.modal', function () {
location.reload();
})
}

function format (name, value) {
    return '<div>Name: ' + name + '<br />Value: ' + value + '</div>';
}

function detpc (table7) {
    var tr = $(this).closest('tr');
        var row = table7.row( tr );
 
        if ( row.child.isShown() ) {
            // This row is already open - close it
            row.child.hide();
            tr.removeClass('shown');
        }
        else {
            // Open this row
            row.child(format(tr.data('child-name'), tr.data('child-value'))).show();
            tr.addClass('shown');
        }
    } 

async function libpc(c7empresa,c7num,userlib){
let dataObject = {liberacao:'ok'};
let resposta = ''

fetch('#iprest#/RestLibDc/v6?empresa='+c7empresa+'&documento='+c7num+'&userlib='+userlib, {
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

	  //document.getElementById("titConf").innerHTML = data["liberacao"];
	  $("#titConf").text(data.liberacao);
	  $('#confModal').modal('show');
	  $('#confModal').on('hidden.bs.modal', function () {
	  $('#docModal').modal('toggle');
	  })
	})
}


</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js" integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous"></script>

</body>
</html>

endcontent

cHtml := STRTRAN(cHtml,"#iprest#",u_BkRest())

iF !Empty(::userlib)
	cHtml := STRTRAN(cHtml,"#userlib#",::userlib)
EndIf

//StrIConv( cHtml, "UTF-8", "CP1252")
//DecodeUtf8(cHtml)
cHtml := StrIConv( cHtml, "CP1252", "UTF-8")
//cPre  := StrIConv( "Pré", "CP1252", "UTF-8")
//cHtml := STRTRAN(cHtml,"Pré",cPre)

//Memowrite(u_STmpDir()+"dc.html",cHtml)

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

