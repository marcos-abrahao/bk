#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#Include "PROTHEUS.CH"
#Include "TBICONN.CH"

/*/{Protheus.doc} RestLibDc
    REST para Libera��o de Documentos / PC - MATA094
    @type  REST
    @author Marcos B. Abrah�o
    @since 08/02/2022
    @version 12.1.33
/*/

WSRESTFUL RestLibDc DESCRIPTION "Rest Libera��o de Documentos"

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
		DESCRIPTION "Retorna um arquivo por meio do m�todo FwFileReader().";
		WSSYNTAX "/RestLibDc/v4";
		PATH "/RestLibDc/v4";
		TTALK "v1"

	WSMETHOD PUT ;
		DESCRIPTION "Libera��o de Documentos" ;
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

END WSRESTFUL



WSMETHOD GET DOWNLDC QUERYPARAM empresa,documento WSREST RestLibDc
    Local cFile  := ""// VALORES RETORNADOS NA LEITURA
	Local cName  := Decode64(self:documento)
	Local cFName := "/dirdoc/co"+self:empresa+"/shared/"+cName
    Local oFile  := FwFileReader():New(cFName) // CAMINHO ABAIXO DO ROOTPATH

    // SE FOR POSS�VEL ABRIR O ARQUIVO, LEIA-O
    // SE N�O, EXIBA O ERRO DE ABERTURA
    If (oFile:Open())
        cFile := oFile:FullRead() // EFETUA A LEITURA DO ARQUIVO

        // RETORNA O ARQUIVO PARA DOWNLOAD
        Self:SetHeader("Content-Disposition", "attachment; filename="+cName)
        Self:SetResponse(cFile)

        lSuccess := .T. // CONTROLE DE SUCESSO DA REQUISI��O
    Else
        SetRestFault(002, "can't load file") // GERA MENSAGEM DE ERRO CUSTOMIZADA

        lSuccess := .F. // CONTROLE DE SUCESSO DA REQUISI��O
    EndIf
Return (lSuccess)



WSMETHOD PUT QUERYPARAM empresa,documento,userlib,liberacao WSREST RestLibDc

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
		cMsg:= "n�o encontrada"
	Case (cQrySF1)->F1_STATUS == "B"
		cMsg:= "est� bloqueada"
	Case (cQrySF1)->F1_STATUS <> " "
		cMsg:= "n�o pode ser liberada"
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
		cMsg:= "n�o pode ser liberada por motivo indefinido"
EndCase

cMsg := cDoc+" "+cMsg

(cQrySF1)->(dbCloseArea())

Return lRet


/*/{Protheus.doc} GET 

Retorna a lista de Documentos Pendentes.
 
@param 
 Page , numerico, numero da pagina 
 PageSize , numerico, quantidade de registros por pagina
 
@return cResponse , caracter, JSON contendo a lista de Pr�-notas
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
	cMsg := "Usu�rio n�o esta cadastrado como aprovador"
	
	oJsonSales['liberacao'] := StrIConv( cMsg, "CP1252", "UTF-8")
	cRet := oJsonSales:ToJson()
	FreeObj(oJsonSales)

	//Retorno do servico
	::SetResponse(cRet)
	Return lRet:= .t.
EndIf


For nE := 1 To Len(aEmpresas)

	cTabSCR := "SCR"+aEmpresas[nE,1]+"0"
	cTabSA2 := "SA2"+aEmpresas[nE,1]+"0"

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += "SELECT "+CRLF
	cQuery += "		'"+cEmpresa+"' AS CREMPRESA,"+CRLF
	cQuery += "		'"+cNomeEmp+"' AS CRNOMEEMP,"+CRLF
	cQuery += "		SCR.CR_FILIAL,"+CRLF
	cQuery += "		SCR.R_E_C_N_O_ AS CRRECNO,"+CRLF
	cQuery += "		SCR.CR_NUM,"+CRLF
	cQuery += "		SCR.CR_TIPO,"+CRLF
	cQuery += "		SCR.CR_USER,"+CRLF
	cQuery += "		SCR.CR_APROV,"+CRLF
	cQuery += "		SCR.CR_STATUS,"+CRLF
	cQuery += "		SCR.CR_DATALIB,"+CRLF
	//cQuery += "		SCR.CR_OBS,"+CRLF
	cQuery += "		SCR.CR_TOTAL,"+CRLF
	cQuery += "		SCR.CR_EMISSAO,"+CRLF
	cQuery += "		SCR.CR_GRUPO"+CRLF
	//cQuery += "		SCR.CR_PRAZO,"+CRLF
	//cQuery += "		SCR.CR_AVISO"+CRLF
				
	cQuery += "FROM "+cTabSCR+" SCR"+CRLF

	//cQuery += "		INNER JOIN "+cTabSA2+" SA2 "+CRLF
	//cQuery += "			ON SF1.F1_FORNECE = SA2.A2_COD AND SF1.F1_LOJA = SA2.A2_LOJA"+CRLF
	//cQuery += "			AND SA2.A2_FILIAL = '"+xFilial('SA2')+"' "+CRLF
	//cQuery += "			AND SA2.D_E_L_E_T_ = ' '"+CRLF

	cQuery += "WHERE SCR.D_E_L_E_T_ = ' '"+CRLF
	cQuery += "		 AND SCR.CR_FILIAL = '"+xFilial('SCR')+"' "+CRLF
	cQuery += "  AND CR_STATUS = '02'"+CRLF
	cQuery += "  AND CR_USER   = '"+__cUserId+"'"+CRLF

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
	aListSales[nPos]['NUM']        := (cQrySCR)->CR_NUM
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
Local cMsg		As String
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
cQuery += "		SF1.F1_XXLIB,"+CRLF
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
aFiles := DocsPN(self:empresa,(cQrySF1)->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
For nI := 1 To Len(aFiles)
	aAdd(aAnexos,JsonObject():New())
	aAnexos[nI]["F1_ANEXO"]		:= aFiles[nI,1]
	aAnexos[nI]["F1_ENCODE"]	:= aFiles[nI,2]
Next
oJsonPN['F1_ANEXOS']	:= aAnexos

If !Empty((cQrySF1)->F1_HISTRET)
	cHist += AllTrim(((cQrySF1)->F1_HISTRET))+" "
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


WSMETHOD GET CONSPC QUERYPARAM empresa,documento,userlib WSREST RestLibDc

Local oJsonPN	:= JsonObject():New()
Local cRet		:= ""
Local cQuery	:= ""
Local cTabSC7	:= "SC7"+self:empresa+"0"
Local cTabSC1	:= "SC1"+self:empresa+"0"
Local cTabSC8	:= "SC8"+self:empresa+"0"
Local cTabSE4	:= "SE4010"
Local cQrySC7	:= GetNextAlias()
Local aItens	:= {}
Local nI		:= 0
Local aEmpresas	As Array
Local aParams	As Array
Local cMsg		As String
Local cHist		:= ""
Local nGeral	:= 0

aEmpresas := u_BKGrupo()
u_BkAvPar(::userlib,@aParams,@cMsg)

cQuery := "SELECT "+CRLF
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
cQuery += "  C7_DATPRF,"	+CRLF
cQuery += "  C7_ITEM,"		+CRLF
cQuery += "  C7_NUM,"		+CRLF
cQuery += "  C8_EMISSAO,"	+CRLF
cQuery += "  C8_FORNECE,"	+CRLF
cQuery += "  C8_ITEM,"		+CRLF
cQuery += "  C8_ITEMPED,"	+CRLF
cQuery += "  C8_MOTIVO,"	+CRLF
cQuery += "  C8_NUM,"		+CRLF
cQuery += "  C8_NUMPED,"	+CRLF
cQuery += "  C8_OBS,"		+CRLF
cQuery += "  C8_PRECO,"		+CRLF
cQuery += "  C8_PRODUTO,"	+CRLF
cQuery += "  C8_QUANT,"		+CRLF
cQuery += "  C8_TOTAL,"		+CRLF
cQuery += "  C8_UM,"		+CRLF
cQuery += "  C8_VALIDA,"	+CRLF
cQuery += "  C8_XXDESCP,"	+CRLF
cQuery += "  C8_XXNFOR"		+CRLF
cQuery += "  CASE WHEN C8_NUMPED = C7_NUM AND C8_ITEMPED = C7_ITEM THEN 'Vencedor' ELSE '' END AS STATUS,"	+CRLF
cQuery += "  CASE WHEN C8_NUMPED = C7_NUM AND C8_ITEMPED = C7_ITEM THEN C7_DATPRF ELSE '' END AS C7_DATPRF,"+CRLF

cQuery += "	INNER JOIN "+cTabSC1+" SC1 "+CRLF
cQuery += "		ON C7_NUMSC = C1_NUM AND C7_ITEMSC = C1_ITEM AND C1_FILIAL = C7_FILIAL AND SC1.D_E_L_E_T_ = ''"+CRLF

cQuery += "	INNER JOIN "+cTabSC8+" SC8 "+CRLF
cQuery += "		ON C7_NUMCOT = C8_NUM  AND C8_NUMSC = C1_NUM AND C8_ITEMSC = C1_ITEM AND C8_FILIAL = C7_FILIAL AND SC8.D_E_L_E_T_ = ''"+CRLF
cQuery += " FROM "+cTabSC7+" SC7"+CRLF

cQuery += "WHERE C7_NUM = "+self:documento +CRLF
cQuery += "  AND SC7.D_E_L_E_T_ = '' +CRLF

cQuery += "ORDER BY C7_ITEM"+CRLF

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySC7,.T.,.T.)

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


// Documentos anexos
aFiles := DocsPN(self:empresa,(cQrySF1)->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
For nI := 1 To Len(aFiles)
	aAdd(aAnexos,JsonObject():New())
	aAnexos[nI]["F1_ANEXO"]		:= aFiles[nI,1]
	aAnexos[nI]["F1_ENCODE"]	:= aFiles[nI,2]
Next
oJsonPN['F1_ANEXOS']	:= aAnexos

If !Empty((cQrySF1)->F1_HISTRET)
	cHist += AllTrim(((cQrySF1)->F1_HISTRET))+" "
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
<link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.0.2/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.datatables.net/1.11.1/css/dataTables.bootstrap5.min.css" rel="stylesheet">

<title>Libera��o de Documentos de Entrada</title>
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
	<a class="navbar-brand" href="#">BK - Libera��o de Documentos</a>
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
<th scope="col">Usu�rio</th>
<th scope="col">Aprovador</th>
<th scope="col">Grupo</th>
<th scope="col">Emiss�o</th>
<th scope="col">Data Lib.</th>
<th scope="col" style="text-align:center;">Total</th>
<th scope="col" style="text-align:center;">A��o</th>
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
     <!-- Conte�do do modal-->
     <div class="modal-content">
       <!-- Cabe�alho do modal -->
       <div class="modal-header bk-colors">
         <h4 id="titLib" class="modal-title">T�tulo do modal</h4>
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
             <label for="SF1Serie" class="form-label">S�rie</label>
             <input type="text" class="form-control form-control-sm" id="SF1Serie" value="#SF1Serie#" readonly="">
           </div>
           <div class="col-md-1">
             <label for="SF1Emissao" class="form-label">Emiss�o</label>
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
             <label for="SF1Especie" class="form-label">Esp�cie</label>
             <input type="text" class="form-control form-control-sm" id="SF1Especie" value="#SF1Especie#" readonly="">
           </div>

           <div class="col-md-2">
             <label for="SF1XXUser" class="form-label">Usu�rio</label>
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
             <label for="SF1EstMun" class="form-label">Estado/Munic�pio</label>
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
							<th scope="col">Descri��o</th>
							<th scope="col">Centro de Custo</th>
							<th scope="col" style="text-align:right;">Quant.</th>
							<th scope="col" style="text-align:right;">V.Unit�rio</th>
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
        <!-- Rodap� do modal-->
       <div class="modal-footer">
         <button type="button" class="btn btn-outline-danger" data-bs-dismiss="modal">Fechar</button>
         <div id="btnlib"></div>
       </div>
     </div>
   </div>
</div>

<!-- Modal do Pedido de Compras -->
<div id="pcModal" class="modal fade" role="dialog">
  <div class="modal-dialog modal-fullscreen">
    <!-- Conte�do do modal-->
    <div class="modal-content">
      <!-- Cabe�alho do modal -->
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
          </div>
          <div class="col-md-1">
            <label for="pcEmissao" class="form-label">Emiss�o</label>
            <input type="text" class="form-control form-control-sm" id="pcEmissao" value="#pcEmissao#" readonly="">
          </div>
          <div class="col-md-1">
            <label for="pcComprador" class="form-label">Comprador</label>
            <input type="text" class="form-control form-control-sm" id="pcComprador" value="#pcComprador#" readonly="">
          </div>
          <div class="col-md-6">
            <label for="pcForn" class="form-label">Fornecedor</label>
            <input type="text" class="form-control form-control-sm" id="pcForn" value="#pcForn#" readonly>
          </div>
      </div>
    <div class="container">
      <div class="table-responsive-sm">
      <table class="table ">
        <thead>
          <tr>
            <th scope="col">Solic/Cota��o</th>
            <th scope="col">Prod.</th>
            <th scope="col">Descri��o</th>
            <th scope="col">UM</th>
            <th scope="col" style="text-align:right;">Quant.</th>
            <th scope="col">Emiss�o</th>
            <th scope="col">Limite Entrega</th>
            <th scope="col">Motivo/Status Cota��o</th>

            <th scope="col" style="text-align:right;">V.Lic/Cotado</th>
            <th scope="col" style="text-align:right;">T.Lic/Cotado</th>

            <th scope="col">Obs/Forma Pgto.</th>
            <th scope="col">Contrato/Forn.</th>
            <th scope="col">Desc. Contrato/Nome Forn.</th>
            <th scope="col">Detalhes</th>

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
    </form>
      </div>
       <!-- Rodap� do modal-->
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

async function getDcs() {
	let url = 'http://10.139.0.30:8080/rest/RestLibDc/v0?userlib='+'#userlib#';
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
     	trHTML += '<td align="right"><button type="button" class="btn btn-outline-warning btn-sm" onclick="showPC(\''+object['CREMPRESA']+'\',\''+object['CRRECNO']+'\',\'#userlib#\',2)">'+cStatus+'</button></td>';
    }
	   
	trHTML += '</tr>';
    });
} else {
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="8" style="text-align:center;">'+documentos['liberacao']+'</th>';
    trHTML += '</tr>';   
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="8" style="text-align:center;">Fa�a login novamente no sistema Protheus</th>';
    trHTML += '</tr>';   
}
document.getElementById("mytable").innerHTML = trHTML;

$('#tableSCR').DataTable({
  "pageLength": 100,
  "language": {
  "lengthMenu": "Registros por p�gina: _MENU_ ",
  "zeroRecords": "Nada encontrado",
  "info": "P�gina _PAGE_ de _PAGES_",
  "infoEmpty": "Nenhum registro dispon�vel",
  "infoFiltered": "(filtrado de _MAX_ registros no total)",
  "search": "Filtrar:",
  "decimal": ",",
  "thousands": ".",
  "paginate": {
    "first":  "Primeira",
    "last":   "Ultima",
    "next":   "Pr�xima",
    "previous": "Anterior"
    }
   }
 });

}

loadTable();


async function getDC(f1empresa,f1recno,userlib) {
let url = 'http://10.139.0.30:8080/rest/RestLibDc/v1?empresa='+f1empresa+'&documento='+f1recno+'&userlib='+userlib;
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
	document.getElementById("btnlib").innerHTML = btn;
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
	anexos += '<a href="http://10.139.0.30:8080/rest/RestLibDc/v4?empresa='+f1empresa+'&documento='+object['F1_ENCODE']+'" class="link-primary">'+object['F1_ANEXO']+'</a></br>';
  })
}
document.getElementById("anexos").innerHTML = anexos;

document.getElementById("d1Table").innerHTML = itens;
foot = '<th scope="row" colspan="8" style="text-align:right;">'+documento['F1_GERAL']+'</th>'
document.getElementById("d1Foot").innerHTML = foot;


$("#titLib").text('Aprova��o de Documento de Entrada - Empresa: '+documento['EMPRESA'] + ' - Usu�rio: '+documento['USERNAME']);
$('#docModal').modal('show');
$('#docModal').on('hidden.bs.modal', function () {
	location.reload();
	})
}



async function libdoc(f1empresa,f1recno,userlib){
let dataObject = {liberacao:'ok'};
let resposta = ''

fetch('http://10.139.0.30:8080/rest/RestLibDc/v3?empresa='+f1empresa+'&documento='+f1recno+'&userlib='+userlib, {
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


async function getPC(f1empresa,f1recno,userlib) {
let url = 'http://10.139.0.30:8081/rest/RestLibDc/v5?empresa='+f1empresa+'&documento='+f1recno+'&userlib='+userlib;
try {
let res = await fetch(url);
  return await res.json();
  } catch (error) {
console.log(error);
  }
}

async function showPC(f1empresa,f1recno,userlib,canLib) {
let documento = await getPC(f1empresa,f1recno,userlib);
let itens = ''
let i = 0
let foot = ''
let anexos = ''

document.getElementById('pcDoc').value = documento['F1_DOC'];
document.getElementById('pcEmissao').value = documento['F1_SERIE'];
document.getElementById('pcComprador').value = documento['F1_DTDIGIT'];
document.getElementById('pcForn').value = documento['F1_XXPVPGT'];
if (canLib === 1){
let btn = '<button type="button" class="btn btn-outline-success" onclick="libdoc(\''+f1empresa+'\',\''+f1recno+'\',\'MjswNDEyMDM0MDA6OzIwMzEyMTAwMDI7Og--\')">Liberar</button>';
document.getElementById("btnlib").innerHTML = btn;
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

document.getElementById("d1Table").innerHTML = itens;
foot = '<th scope="row" colspan="8" style="text-align:right;">'+documento['F1_GERAL']+'</th>'
document.getElementById("d1Foot").innerHTML = foot;
$("#titPC").text('Libera��o de Pedido de Compra - Empresa: '+documento['EMPRESA'] + ' - Usu�rio: '+documento['USERNAME']);
$('#pcModal').modal('show');
$('#pcModal').on('hidden.bs.modal', function () {
location.reload();
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

//StrIConv( cHtml, "UTF-8", "CP1252")
//DecodeUtf8(cHtml)
cHtml := StrIConv( cHtml, "CP1252", "UTF-8")
//cPre  := StrIConv( "Pr�", "CP1252", "UTF-8")
//cHtml := STRTRAN(cHtml,"Pr�",cPre)

Memowrite("\tmp\dc.html",cHtml)

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
