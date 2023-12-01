#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#Include "Protheus.ch"
#Include "TBICONN.CH"

/*/{Protheus.doc} RestLibPN
    REST para Liberação de Pré-notas de Entrada
	https://datatables.net/examples/api/row_details.html
    @type  REST
    @author Marcos B. Abrahão
    @since 16/08/2021 rev 07/06/22
    @version 12.1.33
/*/

WSRESTFUL RestLibPN DESCRIPTION "Rest Liberação de Pré-notas de Entrada"

	WSDATA mensagem     AS STRING
	WSDATA empresa      AS STRING
	WSDATA filial       AS STRING
	WSDATA prenota 		AS STRING
	WSDATA userlib 		AS STRING OPTIONAL
	WSDATA documento	AS STRING
	WSDATA acao 		AS STRING

	WSDATA page         AS INTEGER OPTIONAL
	WSDATA pageSize     AS INTEGER OPTIONAL

	WSMETHOD GET LISTPN;
		DESCRIPTION "Listar Pré-notas de Entrada em aberto";
		WSSYNTAX "/RestLibPN/v0";
		PATH  "/RestLibPN/v0";
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

	WSMETHOD GET DOWNLPN;
		DESCRIPTION "Retorna um arquivo por meio do método FwFileReader().";
		WSSYNTAX "/RestLibPN/v4";
		PATH "/RestLibPN/v4";
		TTALK "v1"

	WSMETHOD PUT LIBDOC;
		DESCRIPTION "Liberação de Pré-notas de Entrada" ;
		WSSYNTAX "/RestLibPN/v3";
		PATH "/RestLibPN/v3";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

	WSMETHOD GET TOKEN;
		DESCRIPTION "Token para Liberação de digitação de Pré-notas de Entrada" ;
		WSSYNTAX "/RestLibPN/v5";
		PATH "/RestLibPN/v5";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL


// v4
WSMETHOD GET DOWNLPN QUERYPARAM empresa,documento WSREST RestLibPN
    Local cFile  := ""// VALORES RETORNADOS NA LEITURA
	Local cName  := Decode64(self:documento)
	Local cFName := "/dirdoc/co"+self:empresa+"/shared/"+cName
    Local oFile  := FwFileReader():New(cFName) // CAMINHO ABAIXO DO ROOTPATH

    // SE FOR POSSÍVEL ABRIR O ARQUIVO, LEIA-O
    // SE NÃO, EXIBA O ERRO DE ABERTURA
    If (oFile:Open())
        cFile := oFile:FullRead() // EFETUA A LEITURA DO ARQUIVO

        // RETORNA O ARQUIVO PARA DOWNLOAD

        //Self:SetHeader("Content-Disposition", '"inline; filename='+cName+'"') não funciona
        Self:SetHeader("Content-Disposition", "attachment; filename="+cName)

        Self:SetResponse(cFile)

        lSuccess := .T. // CONTROLE DE SUCESSO DA REQUISIÇÃO
    Else
        SetRestFault(002, "Nao foi mpossivel carregar o arquivo "+cFName) // GERA MENSAGEM DE ERRO CUSTOMIZADA

        lSuccess := .F. // CONTROLE DE SUCESSO DA REQUISIÇÃO
    EndIf
Return (lSuccess)



WSMETHOD PUT LIBDOC QUERYPARAM empresa,prenota,userlib,acao,liberacao WSREST RestLibPN  //v3

Local cJson			:= Self:GetContent()   
Local lRet			:= .T.
Local oJson			As Object
Local aParams		As Array
Local cMsg			As Char
Local cMotivo 		As Char
Local cAvali 		As Char
Local cAvaliar      As Char

::setContentType('application/json')

oJson := JsonObject():New()
oJson:FromJSON(cJson)

If u_BkAvPar(::userlib,@aParams,@cMsg)

	cMotivo  := AllTrim(oJson['motivo'])
	cAvali   := AllTrim(oJson['avaliacao'])
	cAvaliar := AllTrim(oJson['avaliar'])
	If !Empty(cMotivo)
		cMotivo := StrIConv( cMotivo, "UTF-8", "CP1252")+"."+CRLF
	EndIf

	lRet := fLibPN(::empresa,::prenota,::acao,@cMsg,cMotivo,cAvali,cAvaliar)

EndIf

oJson['liberacao'] := StrIConv( "Pré-nota "+cMsg, "CP1252", "UTF-8")

cRet := oJson:ToJson()

FreeObj(oJson)

Self:SetResponse(cRet)
  
Return lRet


Static Function fLibPN(empresa,prenota,acao,cMsg,cMotivo,cAvali,cAvaliar)
Local lRet 		:= .F.
Local cQuery	:= ""
Local cTabSF1	:= "SF1"+empresa+"0"
Local cTabSA2	:= "SA2"+empresa+"0"
Local cQrySF1	:= GetNextAlias()
Local cDoc		:= ""
Local cSerie	:= ""
Local cxUser	:= ""
Local cxUsers	:= ""
Local cFornece	:= ""
Local nTAval    := 0
Local nAv		:= 0

Default cMsg	:= ""
Default cMotivo := ""

Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

cQuery := "SELECT "
cQuery += "  SF1.F1_XXLIB,"
cQuery += "  SF1.F1_STATUS,"
cQuery += "  SF1.F1_DOC,"
cQuery += "  SF1.F1_SERIE,"
cQuery += "  SF1.F1_XXUSER,"
cQuery += "  SF1.F1_XXUSERS,"
cQuery += "  SF1.D_E_L_E_T_ AS F1DELET,"
cQuery += "  SA2.A2_COD,"
cQuery += "  SA2.A2_LOJA,"
cQuery += "  SA2.A2_NOME "
cQuery += " FROM "+cTabSF1+" SF1 "
cQuery += " INNER JOIN "+cTabSA2+" SA2 ON "
cQuery += "    SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SF1.F1_FORNECE = SA2.A2_COD AND SF1.F1_LOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_='' " 
cQuery += " WHERE SF1.R_E_C_N_O_ = "+prenota

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySF1,.T.,.T.)
If !(cQrySF1)->(Eof()) 
	cDoc    := (cQrySF1)->F1_DOC
	cSerie  := (cQrySF1)->F1_SERIE
	cxUser  := (cQrySF1)->F1_XXUSER
	cxUsers := (cQrySF1)->F1_XXUSER
	cFornece:= (cQrySF1)->(A2_COD+"-"+A2_LOJA+" - "+A2_NOME)
EndIf

If !u_IsLibDPH("RESTLIBPN",__cUserId)
	cMsg:= "Não é permitido liberar ou aprovar pré-notas neste horário"
Else
	Do Case
		Case (cQrySF1)->(Eof()) 
			cMsg:= "não encontrada"
		Case (cQrySF1)->F1DELET = '*'
			cMsg:= "foi excluída"
		Case (cQrySF1)->F1_STATUS == "B"
			cMsg:= "está bloqueada"
		Case (cQrySF1)->F1_STATUS <> " "
			cMsg:= "não pode ser liberada"
		Case (cQrySF1)->F1_XXLIB $ "AN"
			// Liberar
			cQuery := "UPDATE "+cTabSF1
			If acao == 'E'
				cQuery += "  SET F1_XXLIB = 'N',"
				cMsg := "Restringida"
				If !Empty(cMotivo)
					cMotivo := "Motivo da restrição "+DtoC(Date())+" "+Time()+" "+cUserName+": "+cMotivo
				EndIf
			Else
				cQuery += "  SET F1_XXLIB = 'L', F1_XXAVALI = '"+cAvali+"', "
				cMsg := "liberada"
				If !Empty(cMotivo)
					cMotivo := "Obs liberação "+DtoC(Date())+" "+Time()+" "+cUserName+": "+cMotivo
				EndIf
			EndIf
			If !Empty(cMotivo)
				cQuery += "      F1_HISTRET = CONVERT(VARBINARY(800),'"+cMotivo+"' + ISNULL(CONVERT(varchar(800),F1_HISTRET),'')),"
			EndIf
			If cAvaliar == 'S'
				cQuery += "      F1_XXAVAL = 'S',"
			EndIf
			cQuery += "      F1_XXULIB = '"+__cUserId+"',"
			cQuery += "      F1_XXDLIB = '"+DtoC(Date())+"-"+SUBSTR(Time(),1,5)+"'"
			cQuery += " FROM "+cTabSF1+" SF1"+CRLF
			cQuery += " WHERE SF1.R_E_C_N_O_ = "+prenota+CRLF

			If TCSQLExec(cQuery) < 0 
				cMsg := "Erro: "+TCSQLERROR()
			Else
				lRet := .T.
			EndIf
		Case (cQrySF1)->F1_XXLIB $ "9R "
			// Aprovar para liberação
			cQuery := "UPDATE "+cTabSF1
			If acao == 'E'
				cQuery += "  SET F1_XXLIB = 'R',"
				cMsg := "Reprovada"
				If !Empty(cMotivo)
					cMotivo := "Motivo reprovação "+DtoC(Date())+" "+Time()+" "+cUserName+": "+cMotivo
				EndIf
			Else
				cQuery += "  SET F1_XXLIB = 'A', F1_XXAVALI = '"+cAvali+"', "
				cMsg := "aprovada"
				If !Empty(cMotivo)
					cMotivo := "Obs aprovação "+DtoC(Date())+" "+Time()+" "+cUserName+": "+cMotivo
				EndIf
			EndIf
			If !Empty(cMotivo)
				cQuery += "      F1_HISTRET = CONVERT(VARBINARY(800),'"+cMotivo+"' + ISNULL(CONVERT(varchar(800),F1_HISTRET),'')),"
			EndIf
			If cAvaliar == 'S'
				cQuery += "      F1_XXAVAL = 'S',"
			EndIf
			cQuery += "      F1_XXUAPRV = '"+__cUserId+"',"
			cQuery += "      F1_XXDAPRV = '"+DtoC(Date())+"-"+SUBSTR(Time(),1,5)+"'"
			cQuery += " FROM "+cTabSF1+" SF1"+CRLF
			cQuery += " WHERE SF1.R_E_C_N_O_ = "+prenota+CRLF

			If TCSQLExec(cQuery) < 0 
				cMsg := "Erro: "+TCSQLERROR()
			Else
				lRet := .T.
			EndIf

		OtherWise 
			cMsg:= "ação não efetuada por motivo indeterminado"
	EndCase
EndIf

// Enviar e-mail de aviso do estorno
If lRet .AND. (!Empty(cMotivo) .OR. acao == 'E')
	LibEmail(acao,empresa,cMotivo,cDoc,cSerie,cFornece,cxUser,cxUsers)
EndIf

//cAvali := "SSNN"
If lRet .AND. cAvaliar == "S" .AND. !Empty(cAvali)
	cAvali := TRIM(cAvali)
	For nAv := 1 To Len(cAvali)
		If SUBSTR(cAvali,nAv,1) == "S"
			nTAval += 25
		Else
			If nAv == 1
				cMotivo += ' Preço'
			ElseIf nAv == 2
				cMotivo += ' Prazo'
			ElseIf nAv == 3
				cMotivo += ' Quantidade/Atendimento'
			ElseIf nAv == 4
				cMotivo += ' Qualidade/Integridade'
			EndIf
		EndIf
	Next
    If nTAval <= 50
		LibEmail("I",empresa,cMotivo,cDoc,cSerie,cFornece,cxUser,cxUsers)
	EndIf
EndIf 

cMsg := cDoc+" "+cMsg

u_MsgLog("RESTLIBPN",cMsg+" "+cMotivo)

(cQrySF1)->(dbCloseArea())

Return lRet



Static Function LibEmail(acao,empresa,cMotivo,cDoc,cSerie,cFornece,cxUser,cxUsers)
Local cEmail    := "microsiga@bkconsultoria.com.br;"
Local cEmailCC  := "" 
Local aCabs   	:= {}
Local aEmail 	:= {}
Local cMsg		:= ""
Local cAssunto	:= ""

If acao == "E"
	cAssunto := "Não liberação"
ElseIf acao == "L"
	cAssunto := "Liberação"
ElseIf acao == "I"
	cAssunto := "Índice Negativo da Avaliação"
EndIF
	
cAssunto +=" do Documento nº.:"+cDoc+" Série:"+cSerie+" - "+DTOC(DATE())+"-"+TIME()+" - "+FWEmpName(empresa)

If !Empty(cxUser)
	cEmail += UsrRetMail(cxUser)+';'
EndIf
If !Empty(cxUsers)
	cEmail += UsrRetMail(cxUsers)+';'
EndIf

cEmailCC += UsrRetMail(__cUserId)+';'

// Incluir usuarios do almoxarifado 28/09/2021 - Fabio Quirino
cEmail  += u_EmEstAlm(cxUser,.F.,cEmail)

aCabs   := {"Pré-Nota nº.:" + TRIM(cDoc) + " Série:" + cSerie + " Fornecedor: "+cFornece}
aEmail 	:= {}
AADD(aEmail,{"Reprovador:"+UsrFullName(__cUserId)})
AADD(aEmail,{cMotivo})

cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,"RESTLIBPN")

U_BkSnMail("RESTLIBPN",cAssunto,cEmail,cEmailCC,cMsg)

Return Nil


/*/{Protheus.doc} GET / salesorder
Retorna a lista de prenotas.
 
@param 
 Page , numerico, numero da pagina 
 PageSize , numerico, quantidade de registros por pagina
 
@return cResponse , caracter, JSON contendo a lista de Pré-notas
/*/


WSMETHOD GET LISTPN QUERYPARAM userlib WSREST RestLibPN   //v0
Local aEmpresas		:= {}
Local aListSales 	:= {}
Local cQrySF1       := GetNextAlias()
Local cJsonCli      := ''
//Local cWhereSF1   := ""
//Local cWhereSA2   := "%AND SA2.A2_FILIAL = '"+xFilial('SA2')+"'%"
Local cFilSF1		:= ""
Local lRet 			:= .T.
//Local nCount 		:= 0
//Local nStart 		:= 1
//Local nReg		:= 0
//Local nTamPag 	:= 0
Local oJsonSales 	:= JsonObject():New()

Local aParams      	As Array
Local cMsg         	As Character
Local nE			:= 0
Local cEmpresa		:= ""
Local cNomeEmp		:= 0
Local cTabSF1		:= ""
Local cTabSD1		:= ""
Local cTabSA2		:= ""
Local cQuery		:= ""
Local cLiberOk		:= "N"
Local cStatus		:= ""
Local lFiscal		:= .F.
Local lMaster		:= .F.
Local lSuper		:= .F.

//Default self:page 	:= 1
//Default self:pageSize := 500
//Local page := 1
//Local pagesize := 500

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

lFiscal	:= u_InGrupo(__cUserId,"000031")
lMaster := u_InGrupo(__cUserId,"000000/000005/000007/000038")
lSuper  := u_IsSuperior(__cUserId)

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
	cQuery += "		'"+cEmpresa+"' AS F1EMPRESA,"+CRLF
	cQuery += "		'"+cNomeEmp+"' AS F1NOMEEMP,"+CRLF
	cQuery += "		SF1.F1_FILIAL,"+CRLF
	cQuery += "		SF1.R_E_C_N_O_ F1RECNO,"+CRLF
	cQuery += "		SF1.F1_DOC,"+CRLF
	cQuery += "		SF1.F1_FORNECE,"+CRLF
	cQuery += "		SF1.F1_LOJA,"+CRLF
	cQuery += "		SF1.F1_XXLIB,"+CRLF
	cQuery += "		SF1.F1_STATUS,"+CRLF
	cQuery += "		SF1.F1_XXUSER,"+CRLF
	cQuery += "		SF1.F1_XXUSERS,"+CRLF
	cQuery += "		SF1.F1_DTDIGIT,"+CRLF
	cQuery += "		SF1.F1_XXPVPGT,"+CRLF
	//cQuery += "		SF1.F1_XXAVALI,"+CRLF
	cQuery += "		(SELECT SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) FROM "+cTabSD1+" SD1 "+CRLF
	cQuery += "				WHERE D1_FILIAL = F1_FILIAL	AND D1_DOC=F1_DOC AND D1_SERIE=F1_SERIE AND D1_FORNECE=F1_FORNECE AND D1_LOJA=F1_LOJA AND SD1.D_E_L_E_T_ = ' ')"+CRLF
	cQuery += "			AS D1_TOTAL,"+CRLF
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

cQuery += "ORDER BY SF1.F1_XXPVPGT,SF1.F1_DTDIGIT,SF1.F1_DOC"+CRLF

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySF1,.T.,.T.)

//-------------------------------------------------------------------
// Alimenta array de Pré-notas
//-------------------------------------------------------------------
Do While ( cQrySF1 )->( ! Eof() )

	cLiberOk := (cQrySF1)->F1_XXLIB
	cStatus  := Alltrim("Indefinida "+cLiberOk)

	Do Case
	Case cLiberOk $ "AN" .AND. (cQrySF1)->F1_STATUS == " "
		If lFiscal .AND. (cQrySF1)->F1_XXUSER == __cUserId
			cLiberOk := "X"
			cStatus  := "A Liberar"
		Else
			If lFiscal .OR. lMaster
				If cLiberOk == "A"
					cStatus  := "Liberar"
				Else
					cStatus  := "Nao Liberada"
				EndIf
				cLiberOk := "A"
			Else
				cLiberOk := "X"
				cStatus  := "A Liberar"
			EndIf
		EndIf
	Case cLiberOk $ "9 " .AND. (cQrySF1)->F1_STATUS == " "
		If lSuper .OR. lMaster 
			If lMaster .OR. (cQrySF1)->F1_XXUSER <> __cUserId
				cStatus  := "Aprovar"
			Else
				cStatus  := "A Aprovar"
				cLiberOk := "X"
			EndIf
		Else
			cStatus  := "A Aprovar"
			cLiberOk := "X"
		EndIf
	Case cLiberOk == "T"
		cStatus  := "Token"
	Case cLiberOk == "B"
		cStatus  := "Bloqueada"
	Case cLiberOk == "C"
		cStatus  := "Classificada"
	Case cLiberOk == "E"
		cStatus  := "Estornada"
	Case cLiberOk == "R"
		cStatus  := "Reprovada"
		If lSuper .OR. lMaster
			cStatus  := "Reprovada"
		Else
			cLiberOk := "X"
		EndIf
	Case cLiberOk == "L"
		cStatus  := "Liberada"
	EndCase

	aAdd( aListSales , JsonObject():New() )
	nPos := Len(aListSales)
	aListSales[nPos]['DOC']        := (cQrySF1)->F1_DOC
	aListSales[nPos]['DTDIGIT']    := DTOC(STOD((cQrySF1)->F1_DTDIGIT))
	aListSales[nPos]['FORNECEDOR'] := TRIM((cQrySF1)->A2_NOME)
	aListSales[nPos]['RESPONSAVEL']:= UsrRetName((cQrySF1)->F1_XXUSER)
	aListSales[nPos]['PGTO']  	   := DTOC(STOD((cQrySF1)->F1_XXPVPGT))
	aListSales[nPos]['TOTAL']      := TRANSFORM((cQrySF1)->D1_TOTAL,"@E 999,999,999.99")
	aListSales[nPos]['LIBEROK']    := cLiberOk
	aListSales[nPos]['STATUS']     := cStatus
	aListSales[nPos]['F1EMPRESA']  := (cQrySF1)->F1EMPRESA
	aListSales[nPos]['F1NOMEEMP']  := (cQrySF1)->F1NOMEEMP
	aListSales[nPos]['F1RECNO']    := STRZERO((cQrySF1)->F1RECNO,7)
	(cQrySF1)->(DBSkip())

EndDo

( cQrySF1 )->( DBCloseArea() )

oJsonSales := aListSales
//oJsonSales['liberacao'] := "ok"

//-------------------------------------------------------------------
// Serializa objeto Json
//-------------------------------------------------------------------
cJsonCli:= FwJsonSerialize( oJsonSales )
//cJsonCli := oJsonSales:toJson() 
//-------------------------------------------------------------------
// Elimina objeto da memoria
//-------------------------------------------------------------------
FreeObj(oJsonSales)

//Self:SetHeader("Access-Control-Allow-Origin", "http://"+u_BkIpPort())
Self:SetHeader("Access-Control-Allow-Origin", "*")

Self:SetResponse( cJsonCli ) //-- Seta resposta

Return( lRet )


WSMETHOD GET CONSPN QUERYPARAM empresa,prenota,userlib WSREST RestLibPN  //v1

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
Local cAvalForn := 'N'
Local nAvalIQF	:= 0
Local cAvalIQF	:= ""
Local cF1Avali  := ""
Local cPedidos  := ""
Local dUltPag   := DATE()

aEmpresas := u_BKGrupo()
u_BkAvPar(::userlib,@aParams,@cMsg)

cQuery := "SELECT "+CRLF
cQuery += "		SF1.F1_DOC,"+CRLF
cQuery += "		SF1.F1_SERIE,"+CRLF
cQuery += "		SF1.F1_EMISSAO,"+CRLF
cQuery += "		SF1.F1_DTDIGIT,"+CRLF
cQuery += "		SF1.F1_XXPVPGT,"+CRLF
cQuery += "		SF1.F1_ESPECIE,"+CRLF
cQuery += "		SF1.F1_XXUSER,"+CRLF
cQuery += "		SF1.F1_XXUSERS,"+CRLF
cQuery += "		SF1.F1_FORNECE,"+CRLF
cQuery += "		SF1.F1_LOJA,"+CRLF
cQuery += "		SA2.A2_NOME,"+CRLF
cQuery += "		SA2.A2_CGC,"+CRLF
cQuery += "		SA2.A2_EST,"+CRLF
cQuery += "		SA2.A2_MUN,"+CRLF
cQuery += "		SF1.F1_XXLIB,"+CRLF
cQuery += "		SF1.F1_XXAVAL,"+CRLF
cQuery += "		SF1.F1_XXAVALI,"+CRLF
cQuery += "		SF1.F1_XXJSPGT,"+CRLF
cQuery += "		SD1.D1_ITEM,"+CRLF
cQuery += "		SD1.D1_COD,"+CRLF
cQuery += "		SB1.B1_DESC,"+CRLF
cQuery += "		SD1.D1_TOTAL,"+CRLF
cQuery += "		(SD1.D1_TOTAL+SD1.D1_VALFRE+SD1.D1_SEGURO+SD1.D1_DESPESA-SD1.D1_VALDESC) AS D1_GERAL,"+CRLF
cQuery += "		SD1.D1_QUANT,"+CRLF
cQuery += "		SD1.D1_VUNIT,"+CRLF
cQuery += "		SD1.D1_PEDIDO,"+CRLF
cQuery += "		SD1.D1_CC,"+CRLF
cQuery += "		SD1.D1_XXDCC,"+CRLF
cQuery += "		CONVERT(VARCHAR(2000),CONVERT(Binary(2000),SD1.D1_XXHIST))  D1_XXHIST,"+CRLF
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

cQuery += "WHERE SF1.R_E_C_N_O_ = "+self:prenota+CRLF

//	cQuery += "ORDER BY SF1.F1_DTDIGIT"+CRLF
//u_MsgLog("RESTLIBPN",cQuery)

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
	dUltPag := aParcelas[nI,2]
	cParcelas += aParcelas[nI,1]+" - "+DTOC(aParcelas[nI,2])+ " - R$ "+ALLTRIM(TRANSFORM(aParcelas[nI,3],"@E 999,999,999.99"))
	If MOD(nI,2) == 0
		cParcelas += CRLF
	ElseIf nI < LEN(aParcelas)
		cParcelas += "  |  "
	EndIf
Next
oJsonPN['F1_XXPARCE']	:= cParcelas

// Avaliação do Fornecedor
cF1Avali 			:= (cQrySF1)->F1_XXAVALI
oJsonPN['F1AVAL1']	:= IIF(SUBSTR((cQrySF1)->F1_XXAVALI,1,1)='S','S','N')
oJsonPN['F1AVAL2']	:= IIF(SUBSTR((cQrySF1)->F1_XXAVALI,2,1)='S','S','N')
oJsonPN['F1AVAL3']	:= IIF(SUBSTR((cQrySF1)->F1_XXAVALI,3,1)='S','S','N')
oJsonPN['F1AVAL4']	:= IIF(SUBSTR((cQrySF1)->F1_XXAVALI,4,1)='S','S','N')

//If u_IsAvalia(__cUserId) .OR. u_IsAvalia((cQrySF1)->(F1_XXUSER)) .OR. u_IsAvalia((cQrySF1)->(F1_XXUSERS))
//u_MsgLog("RESTLIBPN",(cQrySF1)->F1_DOC+"-"+(cQrySF1)->D1_PEDIDO)
If !Empty((cQrySF1)->D1_PEDIDO) .OR. (cQrySF1)->F1_XXAVAL == 'S' //u_IsAvalPN((cQrySF1)->F1_XXUSER)
	nAvalIQF :=	IIF(SUBSTR((cQrySF1)->F1_XXAVALI,1,1)=='S',25,0)+;
				IIF(SUBSTR((cQrySF1)->F1_XXAVALI,2,1)=='S',25,0)+;
				IIF(SUBSTR((cQrySF1)->F1_XXAVALI,3,1)=='S',25,0)+;
				IIF(SUBSTR((cQrySF1)->F1_XXAVALI,4,1)=='S',25,0)

	cAvalForn := 'S'
EndIf

// Documentos anexos
aFiles := u_BKDocs(self:empresa,"SF1",(cQrySF1)->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA),1)
For nI := 1 To Len(aFiles)
	aAdd(aAnexos,JsonObject():New())
	aAnexos[nI]["F1_ANEXO"]		:= aFiles[nI,2]
	aAnexos[nI]["F1_ENCODE"]	:= Encode64(aFiles[nI,2])
Next
/*
aFiles := DocsPN(self:empresa,(cQrySF1)->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
For nI := 1 To Len(aFiles)
	aAdd(aAnexos,JsonObject():New())
	aAnexos[nI]["F1_ANEXO"]		:= aFiles[nI,1]
	aAnexos[nI]["F1_ENCODE"]	:= aFiles[nI,2]
Next
*/


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
	aItens[nI]["B1_DESC"]	:= StrIConv(TRIM((cQrySF1)->B1_DESC), "CP1252", "UTF-8") 
	aItens[nI]["D1_QUANT"]	:= TRANSFORM((cQrySF1)->D1_QUANT,"@E 99999999.99")
	aItens[nI]["D1_VUNIT"]	:= TRANSFORM((cQrySF1)->D1_TOTAL,"@E 999,999,999.9999")
	aItens[nI]["D1_TOTAL"]	:= TRANSFORM((cQrySF1)->D1_TOTAL,"@E 999,999,999.99")
	aItens[nI]["D1_GERAL"]	:= TRANSFORM((cQrySF1)->D1_GERAL,"@E 999,999,999.99")
	aItens[nI]["D1_CC"]		:= (cQrySF1)->D1_CC
	aItens[nI]["D1_CC"]		+= "-"+StrIConv(TRIM((cQrySF1)->D1_XXDCC), "CP1252", "UTF-8") 
	aItens[nI]["D1CCVIG"]	:= " "+ALLTRIM(U_Vig2Contrat((cQrySF1)->D1_CC,dUltPag,self:empresa))
	If !ALLTRIM((cQrySF1)->D1_XXHIST) $ cHist                   
       cHist += STRTRAN(LTRIM((cQrySF1)->D1_XXHIST),CRLF," ")
    EndIf
	nGeral += (cQrySF1)->D1_GERAL
	If !Empty((cQrySF1)->D1_PEDIDO)
		cAvalForn := 'S'
		cPedidos  += (cQrySF1)->D1_PEDIDO + " "
	EndIf
	dbSkip()
EndDo

//cHist := STRTRAN(cHist,CRLF," ")
oJsonPN['D1_XXHIST']	:= StrIConv( cHist, "CP1252", "UTF-8")  //CP1252  ISO-8859-1
oJsonPN['D1_ITENS']		:= aItens
oJsonPN['F1_GERAL']		:= TRANSFORM(nGeral,"@E 999,999,999.99")

If cAvalForn == 'S' //.OR. nAvalIQF > 0 
	If Empty(cF1Avali)
		cAvalIQF := StrIConv( "Não avaliado", "CP1252", "UTF-8")
	Else
		cAvalIQF := ALLTRIM(STR(nAvalIQF,3,0))+"%"
	EndIf
	cAvalIQF  := "IQF: "+cAvalIQF
Else
	cAvalIQF :=  StrIConv( "Avaliação desnecessária "+TRIM(cF1Avali), "CP1252", "UTF-8")
EndIf

oJsonPN['F1AVAL']		:= cAvalIQF
oJsonPN['F1AVALFORN']	:= cAvalForn
oJsonPN['D1PEDIDOS']	:= TRIM(cPedidos)

(cQrySF1)->(dbCloseArea())

cRet := oJsonPN:ToJson()

FreeObj(oJsonPN)

//Retorno do servico
Self:SetHeader("Access-Control-Allow-Origin", "*")
Self:SetResponse(cRet)

return .T.


WSMETHOD GET BROWPN QUERYPARAM userlib WSREST RestLibPN

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
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Liberação de Pré-notas de Entradas - #cUserName#</a> 
    <form class="d-flex">
      <input class="form-control me-2" type="search" placeholder="Num. Documento" id="TokenDoc" value="" aria-label="TokenDoc">
      <button type="button" class="btn btn-dark" aria-label="Token" onclick="token(1);">Token</button>
    </form>
    <button type="button" 
       class="btn btn-dark" aria-label="Atualizar" onclick="window.location.reload();">
       Atualizar
    </button>
  </div>
</nav>
<br>
<br>
<br>
<div class="container">
<div class="table-responsive-sm">
<table id="tableSF1" class="table">
<thead>
<tr>
<th scope="col">Empresa</th>
<th scope="col">Pré-nota</th>
<th scope="col">Entrada</th>
<th scope="col">Fornecedor</th>
<th scope="col">Responsável</th>
<th scope="col">Vencimento</th>
<th scope="col" style="text-align:center;">Total</th>
<th scope="col" style="text-align:center;">Ação</th>
</tr>
</thead>
<tbody id="mytable">
<tr>
  <th scope="col">Carregando Pré-notas...</th>
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
           <div class="col-md-2">
             <label for="SD1Pedidos" class="form-label">Pedidos</label>
             <input type="text" class="form-control form-control-sm" id="SD1Pedidos" value="#SD1Pedidos#" readonly="">
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
           <div class="col-md-2">
             <label for="SF1Aval" class="form-label">Avaliação do Fornecedor</label>
             <input type="text" class="form-control form-control-sm" id="SF1Aval" value="#SF1Aval#" readonly="">
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
							<th scope="col">Obs</th>
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
         <div id="inpest"></div>
         <div id="btnest"></div>
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


<div id="confToken" class="modal" tabindex="-1">
   <div class="modal-dialog">
     <div class="modal-content">
       <div class="modal-header">
         <h5 id="titToken" class="modal-title">Token gerado:</h5>
         <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Fechar"></button>
       </div>
      <div class="modal-body">
	  	 <!-- <label for="txtToken" class="form-label">Token gerado:</label> -->
		<input type="text" class="form-control form-control-sm" id="txtToken" size="100" value="">
      </div>
       <div class="modal-footer">
         <button type="button" class="btn btn-outline-danger" data-bs-dismiss="modal">Fechar</button>
       </div>
     </div>
   </div>
</div>


<div id="avalModal" class="modal" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 id="titAval" class="modal-title">Avaliação do fornecedor</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Fechar"></button>
      </div>

      <div class="modal-body">
        <div class="form-check form-switch" id="inpPreco">
        </div>
        <div class="form-check form-switch" id="inpPrazo">
        </div>
        <div class="form-check form-switch" id="inpQuant">
        </div>
        <div class="form-check form-switch" id="inpQuali">
        </div>
      </div>

      <div class="modal-footer">
        <button type="button" class="btn btn-outline-danger" data-bs-dismiss="modal">Fechar</button>
		<div id="btnlib2"></div>
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

async function getPNs() {
	let url = '#iprest#/RestLibPN/v0?userlib='+'#userlib#';
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
let nlin = 0;
let cbtn = '';
let ccanl = '';
let cbtnid = ''

if (Array.isArray(prenotas)) {
   prenotas.forEach(object => {
   let cprenota = object['DOC']
   let cLiberOk = object['LIBEROK']
   let cStatus  = object['STATUS']
   nlin += 1;
   trHTML += '<tr>';
   trHTML += '<td>'+object['F1NOMEEMP']+'</td>';
   trHTML += '<td>'+cprenota+'</td>';
   trHTML += '<td>'+object['DTDIGIT']+'</td>';
   trHTML += '<td>'+object['FORNECEDOR']+'</td>';
   trHTML += '<td>'+object['RESPONSAVEL']+'</td>';
   trHTML += '<td>'+object['PGTO']+'</td>';
   trHTML += '<td align="right">'+object['TOTAL']+'</td>';

   if (cLiberOk == 'A' ){
    cbtn = 'btn-outline-success';
    ccanl = '1';
 	} else if (cLiberOk == '9' || cLiberOk == 'T'){
    cbtn = 'btn-outline-warning';
    ccanl = '1';
 	} else if (cLiberOk == 'B'){
    cbtn = 'btn-outline-danger';
    ccanl = '2';
 	} else if (cLiberOk == 'C' || cLiberOk == 'L'){
    cbtn = 'btn-outline-primary';
    ccanl = '2';
 	} else if (cLiberOk == 'E'){
    cbtn = 'btn-outline-secondary';
    ccanl = '2';
 	} else if (cLiberOk == 'R'){
    cbtn = 'btn-outline-secondary';
    ccanl = '1';
 	} else if (cLiberOk == ' '){
    cbtn = 'btn-outline-secondary';
    ccanl = '1';
	} else if (cLiberOk == 'X'){
    cbtn = 'btn-outline-dark';
    ccanl = '2';
  }

cbtnid = 'btnac'+nlin;
trHTML += '<td align="right"><button type="button" id="'+cbtnid+'" class="btn '+cbtn+' btn-sm" onclick="showPN(\''+object['F1EMPRESA']+'\',\''+object['F1RECNO']+'\',\'#userlib#\','+ccanl+','+'\''+cbtnid+'\')">'+cStatus+'</button></td>';

trHTML += '</tr>';
   });
} else {
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="8" style="text-align:center;">'+prenotas['liberacao']+'</th>';
    trHTML += '</tr>';   
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="8" style="text-align:center;">Faça login novamente no sistema Protheus</th>';
    trHTML += '</tr>';   
}
document.getElementById("mytable").innerHTML = trHTML;

$('#tableSF1').DataTable({
  dom: 'Bfrtip',
  buttons: [
            'copyHtml5',
            'excelHtml5',
            'csvHtml5',
            'pdfHtml5'
        ],
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


async function getPN(f1empresa,f1recno,userlib) {
let url = '#iprest#/RestLibPN/v1?empresa='+f1empresa+'&prenota='+f1recno+'&userlib='+userlib;
	try {
	let res = await fetch(url);
		return await res.json();
		} catch (error) {
	console.log(error);
		}
	}

async function showPN(f1empresa,f1recno,userlib,canLib,cbtnac) {

document.getElementById(cbtnac).disabled = true;
document.getElementById(cbtnac).innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>';

let prenota = await getPN(f1empresa,f1recno,userlib);
let itens = '';
let i = 0;
let foot = '';
let anexos = '';
let inpE = '';
let iCheck = '';
let cClick = 'libdoc';

document.getElementById('SF1Doc').value = prenota['F1_DOC'];
document.getElementById('SF1Serie').value = prenota['F1_SERIE'];
document.getElementById('SF1Emissao').value = prenota['F1_EMISSAO'];
document.getElementById('SF1DtDigit').value = prenota['F1_DTDIGIT'];
document.getElementById('SF1XXPvPgt').value = prenota['F1_XXPVPGT'];
document.getElementById('SF1Especie').value = prenota['F1_ESPECIE'];
document.getElementById('SF1XXUser').value = prenota['F1_XXUSER'];
document.getElementById('SD1Pedidos').value = prenota['D1PEDIDOS'];

document.getElementById('SF1Forn').value = prenota['F1_FORN'];
document.getElementById('SF1CGC').value = prenota['A2_CGC'];
document.getElementById('SF1EstMun').value = prenota['A2_ESTMUN'];
document.getElementById('SF1Aval').value = prenota['F1AVAL'];

document.getElementById('SF1XXHist').value = prenota['D1_XXHIST'];
document.getElementById('SF1XXParce').value = prenota['F1_XXPARCE'];

iCheck += '<input class="form-check-input" type="checkbox" id="f1Aval1" value="Preço" '
if (prenota['F1AVAL1'] === 'S'){
  iCheck += 'checked'
}
iCheck += '><label class="form-check-label" for="f1Aval1">Preço</label>'
document.getElementById("inpPreco").innerHTML = iCheck;

iCheck = '';
iCheck += '<input class="form-check-input" type="checkbox" id="f1Aval2" value="Prazo" '
if (prenota['F1AVAL2'] === 'S'){
  iCheck += 'checked'
}
iCheck += '><label class="form-check-label" for="f1Aval2">Prazo</label>'
document.getElementById("inpPrazo").innerHTML = iCheck;

iCheck = '';
iCheck += '<input class="form-check-input" type="checkbox" id="f1Aval3" value="Quantidade" '
if (prenota['F1AVAL3'] === 'S'){
  iCheck += 'checked'
}
iCheck += '><label class="form-check-label" for="f1Aval3">Quantidade/Atendimento</label>'
document.getElementById("inpQuant").innerHTML = iCheck;

iCheck = '';
iCheck += '<input class="form-check-input" type="checkbox" id="f1Aval4" value="Qualidade" '
if (prenota['F1AVAL4'] === 'S'){
  iCheck += 'checked'
}
iCheck += '><label class="form-check-label" for="f1Aval4">Qualidade/Integridade</label>'
document.getElementById("inpQuali").innerHTML = iCheck;

if (canLib === 1){
	if (prenota['F1AVALFORN'] === 'S'){
		cClick = 'avalForn';
	} else {
		cClick = 'libdoc';
	}

	if (prenota['F1_XXLIB'] === '9' || prenota['F1_XXLIB'] == ' ' || prenota['F1_XXLIB'] == 'R'){
		let btnL = '<button type="button" class="btn btn-outline-success" onclick="'+cClick+'(\''+f1empresa+'\',\''+f1recno+'\',\'#userlib#\',\'A\')">Aprovar</button>';
		document.getElementById("btnlib").innerHTML = btnL;
	} else {
		if (prenota['F1_XXLIB'] !== ' '){
			let btnL = '<button type="button" class="btn btn-outline-success" onclick="'+cClick+'(\''+f1empresa+'\',\''+f1recno+'\',\'#userlib#\',\'L\')">Liberar</button>';
			document.getElementById("btnlib").innerHTML = btnL;
		}
	}

	inpE  += '<input type="text" class="form-control form-control-sm" id="SF1Motivo" size="50" value="" placeholder="Obs ou Motivo do Estorno">';
	document.getElementById("inpest").innerHTML = inpE;

	if (prenota['F1_XXLIB'] === 'A'){
		let btnE = '<button type="button" class="btn btn-outline-secondary" onclick="libdoc(\''+f1empresa+'\',\''+f1recno+'\',\'#userlib#\',\'E\',\'N\')">Restringir</button>';
		document.getElementById("btnest").innerHTML = btnE;
	}

	if (prenota['F1_XXLIB'] === '9'){
		let btnE = '<button type="button" class="btn btn-outline-secondary" onclick="libdoc(\''+f1empresa+'\',\''+f1recno+'\',\'#userlib#\',\'E\',\'N\')">Reprovar</button>';
		document.getElementById("btnest").innerHTML = btnE;
	}


} 
if (prenota['F1_XXLIB'] === 'T'){
	let btnE = '<button type="button" class="btn btn-outline-warning" onclick="token(2)">Token</button>';
	document.getElementById("btnest").innerHTML = btnE;
}


if (Array.isArray(prenota.D1_ITENS)) {
   prenota.D1_ITENS.forEach(object => {
    i++
	itens += '<tr>';
	itens += '<td>'+object['D1_ITEM']+'</td>';	
	itens += '<td>'+object['D1_COD']+'</td>';
   	itens += '<td>'+object['B1_DESC']+'</td>';
	itens += '<td>'+object['D1_CC']+'</td>';
	itens += '<td>'+object['D1CCVIG']+'</td>';
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

if (Array.isArray(prenota.F1_ANEXOS)) {
	prenota.F1_ANEXOS.forEach(object => {
	anexos += '<a href="#iprest#/RestLibPN/v4?empresa='+f1empresa+'&documento='+object['F1_ENCODE']+'" class="link-primary">'+object['F1_ANEXO']+'</a></br>';
  })
}
document.getElementById("anexos").innerHTML = anexos;

document.getElementById("d1Table").innerHTML = itens;
foot = '<th scope="row" colspan="8" style="text-align:right;">'+prenota['F1_GERAL']+'</th>'
document.getElementById("d1Foot").innerHTML = foot;

$("#titLib").text('Liberação de Pré-Nota - Empresa: '+prenota['EMPRESA'] + ' - Usuário: '+prenota['USERNAME']);
$('#meuModal').modal('show');
$('#meuModal').on('hidden.bs.modal', function () {
	location.reload();
	})
}

async function avalForn(f1empresa,f1recno,userlib,acao){

let btnL = '<button type="button" class="btn btn-outline-success" onclick="libdoc(\''+f1empresa+'\',\''+f1recno+'\',\'#userlib#\',\'L\',\'S\')">Liberar</button>';
document.getElementById("btnlib2").innerHTML = btnL;
$('#avalModal').modal('show');
}

async function libdoc(f1empresa,f1recno,userlib,acao,avaliar){
let resposta = ''
let SF1Motivo = document.getElementById("SF1Motivo").value;
let SF1Avali = ''

if (document.getElementById("f1Aval1").checked){
	SF1Avali += 'S';
} else {
	SF1Avali += 'N';
}

if (document.getElementById("f1Aval2").checked){
	SF1Avali += 'S';
} else {
	SF1Avali += 'N';
}

if (document.getElementById("f1Aval3").checked){
	SF1Avali += 'S';
} else {
	SF1Avali += 'N';
}

if (document.getElementById("f1Aval4").checked){
	SF1Avali += 'S';
} else {
	SF1Avali += 'N';
}

let dataObject = {	liberacao:'ok',
					motivo:SF1Motivo,
					avaliacao:SF1Avali,
					avaliar:avaliar, 
				 };

fetch('#iprest#/RestLibPN/v3?empresa='+f1empresa+'&prenota='+f1recno+'&userlib='+userlib+'&acao='+acao, {
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
	  $('#avalModal').modal('hide');
	  $("#titConf").text(data.liberacao);
	  $('#confModal').modal('show');
	  $('#confModal').on('hidden.bs.modal', function () {
	  $('#meuModal').modal('toggle');
	  })
	})
}


async function getToken(cDoc) {
let url = '#iprest#/RestLibPN/v5?userlib='+'#userlib#'+'&documento='+cDoc;
	try {
	let res = await fetch(url);
		return await res.json();
		} catch (error) {
	console.log(error);
	}
}


async function token(nOrigem){

let TokenDoc = '';

if (nOrigem === 1) {
	TokenDoc = document.getElementById("TokenDoc").value;
} else {
	TokenDoc = document.getElementById('SF1Doc').value;
}

let TokenRet = await getToken(TokenDoc);

document.getElementById("titToken").innerHTML = 'Token gerado para o documento: '+TokenRet['DOC'];
document.getElementById("txtToken").value = TokenRet['TOKEN'];
$('#confToken').modal('show');
}

</script>

</body>
</html>
endcontent

cHtml := STRTRAN(cHtml,"#iprest#",u_BkRest())

iF !Empty(::userlib)
	cHtml := STRTRAN(cHtml,"#userlib#",::userlib)
	cHtml := STRTRAN(cHtml,"#cUserName#",cUserName)
EndIf

//StrIConv( cHtml, "UTF-8", "CP1252")
//DecodeUtf8(cHtml)
cHtml := StrIConv( cHtml, "CP1252", "UTF-8")

If __cUserId == '000000'
	Memowrite("\tmp\pn.html",cHtml)
EndIf

Self:SetHeader("Access-Control-Allow-Origin", "*")
self:setResponse(cHTML)
self:setStatus(200)

return .T.



WSMETHOD GET TOKEN QUERYPARAM userlib,documento WSREST RestLibPN
Local oJsonPN	:= JsonObject():New()
Local lRet		:= .T.
Local cRet		:= ""
Local aParams	As Array
Local cMsg		:= ""
Local cDoc      := ::documento

If u_BkAvPar(::userlib,@aParams,@cMsg)
	If Val(::documento) > 0
		cDoc := STRZERO(Val(::documento),9)
		cMsg := U_BKEnCode({cDoc})
	Else
		cMsg := "Erro: Informe um valor numerico"
	EndIf
EndIf

u_MsgLog("RESTLIBPN","Doc: "+cDoc+" Token: "+cMsg)

oJsonPN['TOKEN'] := cMsg
oJsonPN['DOC']   := cDoc

cRet := oJsonPN:ToJson()

FreeObj(oJsonPN)

//Retorno do servico
Self:SetHeader("Access-Control-Allow-Origin", "*")
Self:SetResponse(cRet)

Return lRet



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

//Substituida por BKDocs
/*
Static Function DocsPN(empresa,cChave)
Local oStatement := nil
Local cQuery     := ""
Local cAliasSQL  := ""
Local nSQLParam  := 0
Local cTabAC9	 := "AC9"+empresa+"0" 
Local cTabACB	 := "ACB"+empresa+"0"
Local aFiles	 := {}

cQuery := "SELECT ACB.ACB_OBJETO " + CRLF
cQuery += " FROM " + cTabAC9 + " AC9 " + CRLF // Entidade x objeto.
cQuery += "LEFT JOIN " + cTabACB + " ACB ON ACB.D_E_L_E_T_ = ' ' " + CRLF // Objeto.
cQuery += " AND ACB.ACB_FILIAL = AC9.AC9_FILIAL " + CRLF
cQuery += " AND ACB.ACB_CODOBJ = AC9.AC9_CODOBJ " + CRLF
cQuery += "WHERE AC9.D_E_L_E_T_ = '' " + CRLF
cQuery += " AND AC9.AC9_FILIAL = ? " + CRLF
cQuery += " AND AC9.AC9_ENTIDA = ? " + CRLF
cQuery += " AND AC9.AC9_CODENT = ? " + CRLF

//cQuery += "ORDER BY AC9.AC9_FILIAL, AC9.AC9_ENTIDA, AC9.AC9_CODENT, AC9.AC9_CODOBJ "

// Trata SQL para proteger de SQL injection.
oStatement := FWPreparedStatement():New()
oStatement:SetQuery(cQuery)

nSQLParam++
oStatement:SetString(nSQLParam, xFilial("AC9"))  // Filial

nSQLParam++
oStatement:SetString(nSQLParam, "SF1")  // Entidade.

nSQLParam++
oStatement:SetString(nSQLParam, cChave) // Chave.

cQuery := oStatement:GetFixQuery()
oStatement:Destroy()
oStatement := nil

cAliasSQL := MPSysOpenQuery(cQuery)

Do While (cAliasSQL)->(!eof())
	aAdd(aFiles,{AllTrim((cAliasSQL)->ACB_OBJETO),Encode64(Alltrim((cAliasSQL)->ACB_OBJETO))})
	(cAliasSQL)->(dbSkip())
EndDo
(cAliasSQL)->(dbCloseArea())

Return (aFiles)
*/
