#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

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
	WSDATA vencini      AS STRING
	WSDATA vencfim      AS STRING
	WSDATA e2recno 		AS STRING
	WSDATA f1recno 		AS STRING
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

	WSMETHOD GET CONSE2;
		DESCRIPTION "Retorna dados do Título";
		WSSYNTAX "/RestTitCP/v6";
		PATH "/RestTitCP/v6";
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

	WSMETHOD GET HPDFCP;
		DESCRIPTION "Retorna relatório Html com PDF";
		WSSYNTAX "/RestTitCP/v7";
		PATH "/RestTitCP/v7";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

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

	WSMETHOD PUT MOTIVO;
		DESCRIPTION "Enviar motivo de dados incorretos de pagamento" ;
		WSSYNTAX "/RestTitCP/v8";
		PATH "/RestTitCP/v8";
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


// v8
WSMETHOD PUT MOTIVO QUERYPARAM empresa,f1recno,userlib WSREST RestTitCP 

Local cJson			:= Self:GetContent()   
Local lRet			:= .T.
Local oJson			As Object
Local aParams		As Array
Local cMsg			As Char
Local cMsFin		As Char

::setContentType('application/json')

oJson := JsonObject():New()
oJson:FromJSON(cJson)

If u_BkAvPar(::userlib,@aParams,@cMsg)

	cMsFin  := AllTrim(oJson['msfin'])
	lRet := fMsgFin(::empresa,::f1recno,@cMsg,cMsFin)

EndIf

oJson['liberacao'] := StrIConv(cMsg, "CP1252", "UTF-8")

cRet := oJson:ToJson()

FreeObj(oJson)
// CORS
Self:SetHeader("Access-Control-Allow-Origin", "*")

Self:SetResponse(cRet)
  
Return lRet


Static Function fMsgFin(empresa,f1recno,cMsg,cMsFin)
Local lRet 		:= .F.
Local cQuery	:= ""
Local cTabSF1	:= "SF1"+empresa+"0"
Local cTabSA2	:= "SA2"+empresa+"0"
Local cQrySF1	:= GetNextAlias()
Local cDoc		:= ""

Local cEmail 	:= ""
Local cAssunto  := "Informações insufIcientes para efetuar pagamento - "+DTOC(DATE())+" "+Time()
Local cEmailCC  := u_EmailAdm()
Local aCabs   	:= {"Empresa","Série","Documento","Fornecedor","Valor"}
Local aEmail 	:= {}
Local cCorpo	:= ""
Local cProg		:= "RESTTITCP"

Default cMsg	:= ""
Default cMotivo := ""

Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

cQuery := "SELECT "
cQuery += "   SF1.F1_SERIE"
cQuery += "  ,SF1.F1_DOC"
cQuery += "  ,SF1.F1_FORNECE"
cQuery += "  ,SF1.F1_LOJA"
cQuery += "  ,SF1.F1_XXUSER"
cQuery += "  ,SF1.F1_XXUSERS"
cQuery += "  ,SF1.F1_VALBRUT"
cQuery += "  ,SF1.D_E_L_E_T_ AS F1DELET"
cQuery += "  ,SA2.A2_NOME"
cQuery += " FROM "+cTabSF1+" SF1 "
cQuery += "	 LEFT JOIN "+cTabSA2+"  SA2 ON"+CRLF
cQuery += "	 	SA2.A2_FILIAL      = '  '"+CRLF
cQuery += "	 	AND F1_FORNECE     = SA2.A2_COD"+CRLF
cQuery += "	 	AND F1_LOJA        = SA2.A2_LOJA"+CRLF
cQuery += "	 	AND SA2.D_E_L_E_T_ = ''"+CRLF
cQuery += " WHERE SF1.R_E_C_N_O_ = "+f1recno

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySF1,.T.,.T.)

cDoc := (cQrySF1)->F1_DOC
Do Case
	Case (cQrySF1)->(Eof()) 
		cMsg:= "não encontrado"
	Case (cQrySF1)->F1DELET = '*'
		cMsg:= "foi excluído"
	OtherWise 
		// Alterar o Status
		cMsg   := PAD(cMsFin,50)
		cQuery := "UPDATE "+cTabSF1+CRLF
		cQuery += "  SET F1_XXMSFIN = '"+ALLTRIM(cMsFin)+"'"+CRLF
		cQuery += " FROM "+cTabSF1+" SF1"+CRLF
		cQuery += " WHERE SF1.R_E_C_N_O_ = "+f1recno+CRLF
		//u_LogMemo("RESTTitCP.SQL",cQuery)
		If TCSQLExec(cQuery) < 0
			cMsg := "Erro: "+TCSQLERROR()
		Else
			lRet := .T.
		EndIf
EndCase


If lRet


	aEmail := {}
	AADD(aEmail,{u_BKNEmpr(empresa,2),(cQrySF1)->F1_SERIE,(cQrySF1)->F1_DOC,(cQrySF1)->A2_NOME,(cQrySF1)->F1_VALBRUT})
	AADD(aEmail,{"","","","",""})
	AADD(aEmail,{"","","<b>Pendência:</b>","<b>"+cMsFin+"</b>"})
	If Len(aEmail) > 0
		cEmail := UsrRetMail((cQrySF1)->F1_XXUSER)+";"+UsrRetMail((cQrySF1)->F1_XXUSERS)+";"+UsrRetMail(__cUserID)
		cCorpo := u_GeraHtmA(aEmail,cAssunto,aCabs,cProg,"",cEmail,cEmailCC)
		U_BkSnMail(cProg,cAssunto,cEmail,cEmailCC,cCorpo)
	EndIf

	// Gravar no SZ0 - Avisos Web
	u_BKMsgUs(empresa,"RESTTITCP",{(cQrySF1)->F1_XXUSER},"","Titulo a Pagar "+(cQrySF1)->F1_SERIE+(cQrySF1)->F1_DOC+'-'+TRIM((cQrySF1)->A2_NOME),cMsFin,"N","")

EndIF


cMsg := cDoc+" - Mensagem: "+TRIM(cMsg)+" - "+f1recno

u_MsgLog("RESTTitCP",cMsg)

(cQrySF1)->(dbCloseArea())

Return lRet

// v5
WSMETHOD GET PLANCP QUERYPARAM empresa,vencini,vencfim WSREST RestTitCP
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

	u_MsgLog(cProg,cTitulo+" "+self:vencini+" "+self:vencfim)

	// Query para selecionar os Títulos a Pagar
	TmpQuery(cQrySE2,self:empresa,self:vencini,self:vencfim)


	// Definição do Arq Excel
	oRExcel := RExcel():New(cProg)
	oRExcel:SetTitulo(cTitulo)
	oRExcel:SetVersao(cVersao)
	oRExcel:SetDescr(cDescr)

	// Definição da Planilha 1
	oPExcel:= PExcel():New(cProg,cQrySE2)
	oPExcel:SetTitulo("Empresa: "+self:empresa+" - Vencimento: "+DTOC(STOD(self:vencfim))+" a "+DTOC(STOD(self:vencfim)))

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
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'L'}	,"8B008B","",,,.T.)	// Dark Magenta
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'T'}	,"4B0082","",,,.T.)	// Indigo

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

		oFile:Close()

		// Apagar o arquivo após o fechamento
		Ferase(cFName)

        lSuccess := .T. // CONTROLE DE SUCESSO DA REQUISIÇÃO

    Else
        SetRestFault(002, "Nao foi possivel carregar o arquivo "+cFName) // GERA MENSAGEM DE ERRO CUSTOMIZADA

        lSuccess := .F. // CONTROLE DE SUCESSO DA REQUISIÇÃO
    EndIf

Return (lSuccess)


///v7
WSMETHOD GET HPDFCP QUERYPARAM empresa,vencini,vencfim,userlib WSREST RestTitCP

Local cHtml		as char
Local cDirTmp   := u_STmpDir()
Local cArqHtml  := ""
Local cUrl 		:= ""
//Local oFile		AS Object
//Local cFile		:= ""
Local lSuccess  := .T.
Local cQrySE2	:= "QSE2"
//Local cLink 	:= ""
Local oJsonTmp	:= JsonObject():New()
Local cRet 		:= ""
Local aRet 		:= {}

Private nQuebra := 1

//u_MsgLog("RESTTITCP",VarInfo("vencini",self:vencini))

If Val(SUBSTR(self:empresa,1,2)) > 0
	// Query para selecionar os Títulos a Pagar
	TmpQuery(cQrySE2,self:empresa,self:vencini,self:vencfim)

	cHtml := u_BKFINH34(1,.T.,SUBSTR(self:empresa,1,2),"01")

	(cQrySE2)->(dbCloseArea())
Else

	SetRestFault(002, "Não é permitido emitir o relatório para todas as empresas") // GERA MENSAGEM DE ERRO CUSTOMIZADA

    lSuccess := .F. // CONTROLE DE SUCESSO DA REQUISIÇÃO

EndIf

//cHtml := StrIConv( cHtml, "CP1252", "UTF-8") aqui arrumar

cArqHtml  	:= cDirTmp+"cp"+SUBSTR(self:empresa,1,2)+DTOS(dDataBase)+"-"+__cUserID+".html"
cUrl 		:= u_BkIpServer()+u_STmpDir()+"cp"+SUBSTR(self:empresa,1,2)+DTOS(dDataBase)+"-"+__cUserID+".html"

u_MsgLog("RestTitCP-PDF",cArqHtml)

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   

fErase(cArqHtml)

Memowrite(cArqHtml,cHtml)

aAdd( aRet , JsonObject():New() )
aRet[1]['URLTMP']	:= cUrl

oJsonTmp := aRet
cRet	 := FwJsonSerialize( oJsonTmp )

FreeObj(oJsonTmp)

//Retorno do servico
Self:SetHeader("Access-Control-Allow-Origin", "*")
Self:SetResponse(cRet)

Return (lSuccess)



/*/{Protheus.doc} GET 
Retorna a lista de titulos.
/*/

// v0
WSMETHOD GET LISTCP QUERYPARAM empresa,vencini,vencfim,userlib WSREST RestTitCP
Local aListCP 		:= {}
Local cQrySE2       := GetNextAlias()
Local cJsonCli      := ''
Local lRet 			:= .T.
Local oJsonTmp	 	:= JsonObject():New()
Local aParams      	As Array
Local cMsg         	As Character
Local cNumTit 		:= ""
Local cFormaPgto	:= ""
Local aFiles 		:= {}
Local aAnexos		:= {}
Local nI 			:= 0

//u_MsgLog("RESTTITCP",VarInfo("vencini",self:vencini))

If !u_BkAvPar(::userlib,@aParams,@cMsg)
  oJsonTmp['liberacao'] := cMsg
  cRet := oJsonTmp:ToJson()
  FreeObj(oJsonTmp)
  //Retorno do servico
  ::SetResponse(cRet)
  Return lRet:= .T.
EndIf

// Usuários que podem executar alguma ação
//lPerm := u_InGrupo(__cUserId,"000000/")

// Query para selecionar os Títulos a Pagar
TmpQuery(cQrySE2,self:empresa,self:vencini,self:vencfim)

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
	aListCP[nPos]['FORMPGT']	:= iIf(!Empty((cQrySE2)->FORMPGT),TRIM((cQrySE2)->FORMPGT),"#CP#")
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
	aListCP[nPos]['TIPOBK']		:= TRIM((cQrySE2)->(E2_XXTIPBK))
	aListCP[nPos]['DADOSPGT']	:= cFormaPgto

	// Documentos anexos
	aAnexos := {}

	// Documentos anexos na Pré-Nota
	aFiles := u_BKDocs(SUBSTR((cQrySE2)->EMPRESA,1,2),"SF1",(cQrySE2)->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA),1)
	For nI := 1 To Len(aFiles)
		aAdd(aAnexos,JsonObject():New())
		aAnexos[nI]["F1_ANEXO"]		:= aFiles[nI,2]
		aAnexos[nI]["F1_ENCODE"]	:= Encode64(aFiles[nI,2])
	Next

	// Documentos anexos no Contas a Pagar
	aFiles := u_BKDocs(SUBSTR((cQrySE2)->EMPRESA,1,2),"SE2",(cQrySE2)->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA+E2_PARCELA+E2_TIPO),1)
	For nI := 1 To Len(aFiles)
		aAdd(aAnexos,JsonObject():New())
		aAnexos[nI]["F1_ANEXO"]		:= aFiles[nI,2]
		aAnexos[nI]["F1_ENCODE"]	:= Encode64(aFiles[nI,2])
	Next

	aListCP[nPos]['F1_ANEXOS']	:= aAnexos

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

// /v1
WSMETHOD GET CONSZ2 QUERYPARAM empresa,e2recno,userlib WSREST RestTitCP

Local oJsonPN	:= JsonObject():New()
Local cRet		:= ""
Local cQuery	:= ""
Local cTabSE2	:= "SE2"+self:empresa+"0"
Local cTabSZ2	:= "SZ2010"
Local cTabCTT	:= "CTT"+self:empresa+"0"
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
Local cLote		:= ""

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
cQuery += "		,SE2.E2_XXLOTEB" + CRLF
cQuery += "FROM "+cTabSE2+" SE2" + CRLF
cQuery += "WHERE SE2.R_E_C_N_O_ = "+self:e2recno + CRLF

//u_MsgLog("RESTTITCP",cQuery)

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
cLote 		:= (cQrySE2)->E2_XXLOTEB

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
cQuery += "		,Z2_TIPOPES" + CRLF
cQuery += "		,Z2_CC" + CRLF
cQuery += "		,CTT_DESC01" + CRLF
cQuery += "		,Z2_USUARIO" + CRLF
cQuery += "		,Z2_OBSTITU" + CRLF
cQuery += "		,Z2_NOMDEP" + CRLF
cQuery += "		,Z2_NOMMAE" + CRLF
cQuery += "		,Z2_CPF " + CRLF
cQuery += "		,Z2_BORDERO " + CRLF
cQuery += " FROM "+cTabSZ2+" SZ2" + CRLF
cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
cQuery += "     ON CTT.CTT_FILIAL='"+xFilial("CTT")+"' AND SZ2.Z2_CC = CTT.CTT_CUSTO AND CTT.D_E_L_E_T_=''" + CRLF
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

//u_LogMemo("RESTTITCP.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySZ2,.T.,.T.)

dbSelectArea(cQrySZ2)
dbGoTop()

oJsonPN['LOTE']			:= iIf(Empty((cQrySZ2)->Z2_BORDERO),cLote,(cQrySZ2)->Z2_BORDERO)  // Numero do Bordero
oJsonPN['Z2_USUARIO']	:= (cQrySZ2)->Z2_USUARIO

nI := 0
Do While (cQrySZ2)->(!EOF())
	aAdd(aItens,JsonObject():New())
	nI++
	aItens[nI]["Z2_PRONT"]	:= (cQrySZ2)->Z2_PRONT
	aItens[nI]["Z2_NOMDEP"]	:= StrIConv(ALLTRIM(IIF(!EMPTY((cQrySZ2)->Z2_NOMMAE),(cQrySZ2)->Z2_NOMMAE,(cQrySZ2)->Z2_NOMDEP)), "CP1252", "UTF-8")
	aItens[nI]["Z2_NOME"]	:= StrIConv((cQrySZ2)->Z2_NOME, "CP1252", "UTF-8")
	aItens[nI]["Z2_CPF"]	:= (cQrySZ2)->Z2_CPF
	aItens[nI]["DADOSBC"]	:= (cQrySZ2)->('Bco: '+Z2_BANCO+' Ag: '+Z2_AGENCIA+'-'+Z2_DIGAGEN+' C/C: '+Z2_CONTA+'-'+Z2_DIGCONT)
	aItens[nI]["Z2_CC"]		:= StrIConv(TRIM((cQrySZ2)->Z2_CC)+": "+ALLTRIM((cQrySZ2)->CTT_DESC01), "CP1252", "UTF-8")
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


// v6
WSMETHOD GET CONSE2 QUERYPARAM empresa,e2recno,userlib WSREST RestTitCP

Local oJsonPN	:= JsonObject():New()
Local cRet		:= ""
Local cQuery	:= ""
Local cTabSE2	:= "SE2"+self:empresa+"0"
Local cTabSA2	:= "SA2"+self:empresa+"0"
Local cTabSF1	:= "SF1"+self:empresa+"0"
Local cTabSD1	:= "SD1"+self:empresa+"0"
Local cTabSB1	:= "SB1"+self:empresa+"0"
Local cTabCTT	:= "CTT"+self:empresa+"0"
Local cQrySE2	:= GetNextAlias()
Local cQrySD1	:= GetNextAlias()
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
Local cLote		:= ""
Local cHist		:= ""
Local aFiles	:= {}
Local aAnexos	:= {}

Local nTotal	:= 0
Local cTipBk 	:= ""

aEmpresas := u_BKGrupo()
u_BkAvPar(::userlib,@aParams,@cMsg)

cQuery := "SELECT " + CRLF
cQuery += "	  E2_TIPO"+CRLF
cQuery += "	 ,E2_PREFIXO"+CRLF
cQuery += "	 ,E2_NUM"+CRLF
cQuery += "	 ,E2_PARCELA"+CRLF
cQuery += "	 ,E2_FORNECE"+CRLF
cQuery += "	 ,E2_PORTADO"+CRLF
cQuery += "	 ,E2_LOJA"+CRLF
cQuery += "	 ,E2_NATUREZ"+CRLF
cQuery += "	 ,E2_HIST"+CRLF
cQuery += "	 ,E2_USERLGA"+CRLF 
cQuery += "	 ,E2_EMISSAO"+CRLF
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

cQuery += "	 ,(CASE WHEN E2_XTIPOPG <> ' ' "+CRLF
cQuery += "			THEN E2_XTIPOPG "+CRLF
cQuery += "			WHEN (F1_XTIPOPG IS NULL)"+CRLF
cQuery += "	 		THEN E2_TIPO+' '+E2_PORTADO"+CRLF
cQuery += "	 		WHEN F1_XTIPOPG IS NULL AND (E2_PORTADO IS NOT NULL) THEN 'LF '+E2_PORTADO+' '+E2_TIPO"+CRLF
cQuery += "	 		ELSE F1_XTIPOPG END)"+" AS FORMPGT"+CRLF

cQuery += "	 ,F1_DOC"+CRLF
cQuery += "	 ,E2_XTIPOPG AS F1_XTIPOPG"+CRLF
cQuery += "	 ,F1_XNUMPA"+CRLF
cQuery += "	 ,F1_XBANCO"+CRLF
cQuery += "	 ,F1_XAGENC"+CRLF
cQuery += "	 ,F1_XNUMCON"+CRLF
cQuery += "	 ,F1_XXTPPIX"+CRLF
cQuery += "	 ,F1_XXCHPIX "+CRLF
cQuery += "	 ,F1_USERLGI"+CRLF 
cQuery += "	 ,F1_XXUSER"+CRLF
cQuery += "	 ,F1_XXMSFIN"+CRLF
cQuery += "	 ,SF1.R_E_C_N_O_ AS F1RECNO"+CRLF

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

cQuery += "WHERE SE2.R_E_C_N_O_ = "+self:e2recno + CRLF

//u_LogMemo("RESTTITCP-E2.SQL",cQuery)

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
cLote 		:= (cQrySE2)->E2_XXLOTEB

oJsonPN['USERNAME']		:= cUserName
oJsonPN['EMPRESA']		:= aEmpresas[aScan(aEmpresas,{|x| x[1] == self:empresa }),2]
oJsonPN['E2_PREFIXO']	:= (cQrySE2)->E2_PREFIXO
oJsonPN['E2_NUM']		:= (cQrySE2)->E2_NUM
oJsonPN['A2_NOME']		:= (cQrySE2)->A2_NOME
oJsonPN['E2_EMISSAO']	:= DTOC(STOD((cQrySE2)->E2_EMISSAO))
oJsonPN['E2_VENCREA']	:= DTOC(STOD((cQrySE2)->E2_VENCREA))
oJsonPN['F1_XXUSER']	:= UsrRetName((cQrySE2)->F1_XXUSER)
oJsonPN['E2_HIST']		:= (cQrySE2)->E2_HIST
oJsonPN['LOTE']			:= (cQrySE2)->E2_XXLOTEB
oJsonPN['F1_XXMSFIN']	:= (cQrySE2)->F1_XXMSFIN
oJsonPN['F1RECNO']		:= STRZERO((cQrySE2)->F1RECNO,7)

// Documentos anexos
aFiles := u_BKDocs(self:empresa,"SF1",(cQrySE2)->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA),1)
For nI := 1 To Len(aFiles)
	aAdd(aAnexos,JsonObject():New())
	aAnexos[nI]["F1_ANEXO"]		:= aFiles[nI,2]
	aAnexos[nI]["F1_ENCODE"]	:= Encode64(aFiles[nI,2])
Next

aFiles := u_BKDocs(self:empresa,"SE2",(cQrySE2)->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA+E2_PARCELA+E2_TIPO),1)
For nI := 1 To Len(aFiles)
	aAdd(aAnexos,JsonObject():New())
	aAnexos[nI]["F1_ANEXO"]		:= aFiles[nI,2]
	aAnexos[nI]["F1_ENCODE"]	:= Encode64(aFiles[nI,2])
Next

oJsonPN['F1_ANEXOS']	:= aAnexos

(cQrySE2)->(dbCloseArea())

cQuery := "SELECT " + CRLF
cQuery += "	  D1_COD"+CRLF
cQuery += "	 ,B1_DESC"+CRLF
cQuery += "	 ,D1_CC"+CRLF
cQuery += "	 ,CTT_DESC01"+CRLF
cQuery += "	 ,(D1_TOTAL - D1_VALDESC + D1_DESPESA) AS D1_TOTAL"+CRLF
cQuery += "  ,CONVERT(VARCHAR(800),CONVERT(Binary(800),D1_XXHIST)) AS D1_XXHIST "+CRLF

cQuery += " FROM "+cTabSD1+" SD1" + CRLF

cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
cQuery += "     ON CTT.CTT_FILIAL='"+xFilial("CTT")+"' AND SD1.D1_CC = CTT.CTT_CUSTO AND CTT.D_E_L_E_T_=''" + CRLF

cQuery += " LEFT JOIN "+cTabSB1+" SB1" + CRLF
cQuery += "     ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SD1.D1_COD = SB1.B1_COD AND SB1.D_E_L_E_T_=''" + CRLF

cQuery += " WHERE D1_FILIAL = '"+xFilial("SD1")+"' " + CRLF
cQuery += " 	AND SD1.D1_DOC = '"+cNum+"' " + CRLF
cQuery += " 	AND SD1.D1_SERIE  = '"+cPrefixo+"' " + CRLF
cQuery += " 	AND SD1.D1_FORNECE  = '"+cFornece+"' " + CRLF
cQuery += " 	AND SD1.D1_LOJA = '"+cLoja+"' " + CRLF
cQuery += " 	AND SD1.D_E_L_E_T_ = ' '" + CRLF
cQuery += " ORDER BY D1_ITEM" + CRLF

//u_MsgLog(,"Aqui3")

//u_LogMemo("RESTTITCP-D1.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySD1,.T.,.T.)

dbSelectArea(cQrySD1)
dbGoTop()

nI := 0
Do While (cQrySD1)->(!EOF())
	aAdd(aItens,JsonObject():New())
	nI++

	aItens[nI]["D1_COD"]	:= (cQrySD1)->D1_COD
	aItens[nI]["B1_DESC"]	:= StrIConv((cQrySD1)->B1_DESC, "CP1252", "UTF-8")
	aItens[nI]["D1_CC"]		:= StrIConv(TRIM((cQrySD1)->D1_CC)+": "+ALLTRIM((cQrySD1)->CTT_DESC01), "CP1252", "UTF-8")
	aItens[nI]["D1_VALOR"]	:= TRANSFORM((cQrySD1)->D1_TOTAL,"@E 99999999.99")

	nTotal += (cQrySD1)->D1_TOTAL

	If !ALLTRIM((cQrySD1)->D1_XXHIST) $ cHist                   
		cHist += ALLTRIM((cQrySD1)->D1_XXHIST)+" "
	EndIf

	dbSkip()
EndDo

oJsonPN['D1_XXHIST']	:= StrIConv(cHist, "CP1252", "UTF-8")

oJsonPN['DADOSD1']		:= aItens
oJsonPN['D1_TOTAL']		:= TRANSFORM(nTotal,"@E 999,999,999.99")

(cQrySD1)->(dbCloseArea())

cRet := oJsonPN:ToJson()

FreeObj(oJsonPN)

//Retorno do servico
Self:SetHeader("Access-Control-Allow-Origin", "*")
Self:SetResponse(cRet)

return .T.


// /v2
WSMETHOD GET BROWCP QUERYPARAM empresa,vencini,vencfim,userlib WSREST RestTitCP

Local cHTML		as char
Local cDropEmp	as char
Local aEmpresas := u_BKGrupo()
Local nE 		:= 0

BEGINCONTENT var cHTML

<!doctype html>
<html lang="pt-BR">
<head>
<!-- Required meta tags -->
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Styling CSS -->
#BKDTStyle#

<title>Títulos Contas a Pagar #datavencI# #datavencF# #NomeEmpresa#</title>

<!-- Favicon -->
#BKFavIco#

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

table.dataTable.table-sm>thead>tr th.dt-orderable-asc,table.dataTable.table-sm>thead>tr th.dt-orderable-desc,table.dataTable.table-sm>thead>tr th.dt-ordering-asc,table.dataTable.table-sm>thead>tr th.dt-ordering-desc,table.dataTable.table-sm>thead>tr td.dt-orderable-asc,table.dataTable.table-sm>thead>tr td.dt-orderable-desc,table.dataTable.table-sm>thead>tr td.dt-ordering-asc,table.dataTable.table-sm>thead>tr td.dt-ordering-desc {
    padding-right: 3px;
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
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Títulos a Pagar - #cUserName#</a> 

	<div class="btn-group">
		<button type="button" title="Seleção de empresa" class="btn btn-dark dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">
			#NomeEmpresa#
		</button>
		<ul class="dropdown-menu dropdown-menu-dark">
			#DropEmpresas#
		</ul>
	</div>

	<div class="btn-group">
		<button type="button" class="btn btn-dark" aria-label="Excel" onclick="Excel()">Excel</button>
		<span class="navbar-text">&nbsp;&nbsp;&nbsp;</span> 
		<button type="button" class="btn btn-dark" aria-label="PDF" onclick="HtmlPdf()">PDF</button>
	</div>

    <form class="d-flex">
	  <input class="form-control me-2" type="date" id="DataVencI" value="#datavencI#" />
	  <input class="form-control me-2" type="date" id="DataVencF" value="#datavencF#" />
      <button type="button" class="btn btn-dark" aria-label="Atualizar" onclick="AltVenc()">Atualizar</button>
    </form>

  </div>
</nav>
<br>
<br>
<br>
<div class="container-fluid">
<div class="table-responsive-sm">
<table id="tableSE2" class="table table-sm table-hover" style="width:100%">
<thead>
<tr>
<th scope="col"></th>
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
							<th scope="col">Nome</th>
							<th scope="col">Dependente</th>
							<th scope="col">CPF</th>
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
             <label for="E2Prefixo" class="form-label">Prefixo</label>
             <input type="text" class="form-control form-control-sm" id="E2Prefixo" value="#E2Prefixo#" readonly="">
           </div>
          <div class="col-md-2">
             <label for="E2Num" class="form-label">Título</label>
             <input type="text" class="form-control form-control-sm" id="E2Num" value="#E2Num#" readonly="">
           </div>
           <div class="col-md-2">
             <label for="E2NomFor" class="form-label">Fornecedor</label>
             <input type="text" class="form-control form-control-sm" id="E2NomFor" value="#E2NomFor#" readonly="">
           </div>
           <div class="col-md-1">
             <label for="E2Emissao" class="form-label">Emissão</label>
             <input type="text" class="form-control form-control-sm" id="E2Emissao" value="#E2Emissao#" readonly="">
           </div>
           <div class="col-md-1">
             <label for="E2VencRea" class="form-label">Vencimento</label>
             <input type="text" class="form-control form-control-sm" id="E2VencRea" value="#E2VencRea#" readonly="">
           </div>

           <div class="col-md-2">
             <label for="F1User" class="form-label">Usuário</label>
             <input type="text" class="form-control form-control-sm" id="F1User" value="#F1User#" readonly="">
           </div>

           <div class="col-md-1">
             <label for="E2Lote" class="form-label">Lote</label>
             <input type="text" class="form-control form-control-sm" id="E2Lote" value="#E2Lote#" readonly="">
           </div>

           <div class="col-md-8">
             <label for="E2Hist" class="form-label">Histórico CP</label>
			 <textarea class="form-control form-control-sm" id="E2Hist" rows="1" value="#E2Hist#" readonly=""></textarea>
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

            <div class="col-12" id="anexosE2">
				<!-- <button type="submit" class="btn btn-primary">Sign in</button> -->
            </div>

          </form>

       </div>
        <!-- Rodapé do modal-->
        <div class="modal-footer">

			<div class="input-group mb-3 col-sm-6">
				<span class="input-group-text" id="basic-addon3">Aviso ao usuário:</span>
				<input type="text" class="form-control" id="F1MsFin" value="#F1MsFin#" aria-describedby="basic-addon3">

				<div id="btnMsFin"></div>

				<button type="button" class="btn btn-outline-danger" data-bs-dismiss="modal">Fechar</button>
			</div>

        </div>
     </div>
   </div>
</div>

<!-- JavaScript -->
#BKDTScript#

<script>

async function getCPs() {
	let url = '#iprest#/RestTitCP/v0?empresa=#empresa#&vencini=#vencini#&vencfim=#vencfim#&userlib=#userlib#'
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
let ccbtn = 'light';
let cbtnidp = '';
let cbtnids = '';
let cbtnz2 = '';
let anexos = '';

if (Array.isArray(titulos)) {
	titulos.forEach(object => {
	let cStatus  = object['XSTATUS'];
	let cEmpresa = object['EMPRESA'].substring(0,2);
	let cDadosPgt = object['DADOSPGT'];
	let cTipoBk = object['TIPOBK'];

	nlin += 1; 
	cbtnz2 = 'btnz2'+nlin;

	if (cStatus == 'C' ){
	 ccbtn = 'success';
	} else if (cStatus == ' ' || cStatus == 'A'){
	 ccbtn = 'warning';
	} else if (cStatus == 'P'){
	 ccbtn = 'danger';
	} else if (cStatus == 'O'){
	 ccbtn = 'primary';
	} else if (cStatus == 'D'){
	 ccbtn = 'dark';
	} else if (cStatus == 'L'){
	 ccbtn = 'info';
	} else if (cStatus == 'T'){
	 ccbtn = 'secondary';
	}

	trHTML += '<tr>';
	trHTML += '<td></td>';
	trHTML += '<td>'+object['EMPRESA']+'</td>';
	trHTML += '<td>'+object['TITULO']+'</td>';
	trHTML += '<td>'+object['FORNECEDOR']+'</td>';

	trHTML += '<td>';
	if (cTipoBk === ''){
		trHTML += '<button type="button" id="'+cbtnz2+'" class="btn btn-outline-'+ccbtn+' btn-sm" onclick="showE2(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\','+'\''+cbtnz2+'\')">'+object['FORMPGT']+'</button>';
	} else {
		trHTML += '<button type="button" id="'+cbtnz2+'" class="btn btn-outline-'+ccbtn+' btn-sm" onclick="showZ2(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\','+'\''+cbtnz2+'\')">'+object['FORMPGT']+'</button>';
	}
	trHTML += '</td>';

	trHTML += '<td>'+object['VENC']+'</td>';

	// Botão para troca do portador
	cbtnidp = 'btnpor'+nlin;
	trHTML += '<td>'
	trHTML += '<div class="btn-group">'
	trHTML += '<button type="button" title="Portador" id="'+cbtnidp+'" class="btn btn-dark dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">'
	trHTML += object['PORTADO']
	trHTML += '</button>'

	trHTML += '<div class="dropdown-menu dropdown-menu-dark" aria-labelledby="dropdownMenu2">'
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

	cbtnids = 'btnac'+nlin;

	trHTML += '<td>'

	// Botão para mudança de status
	trHTML += '<div class="btn-group">'
	trHTML += '<button type="button" id="'+cbtnids+'" class="btn btn-outline-'+ccbtn+' dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">'
	trHTML += object['STATUS']
	trHTML += '</button>'

	trHTML += '<div class="dropdown-menu" aria-labelledby="dropdownMenu2">'
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgStatus(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'A\','+'\''+cbtnids+'\')">Em Aberto</button>';
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgStatus(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'C\','+'\''+cbtnids+'\')">Concluido</button>';
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgStatus(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'P\','+'\''+cbtnids+'\')">Pendente</button>';
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgStatus(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'O\','+'\''+cbtnids+'\')">Compensar PA</button>';
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgStatus(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'D\','+'\''+cbtnids+'\')">Deb Automatico</button>';
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgStatus(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'L\','+'\''+cbtnids+'\')">Parcelamento</button>';
	trHTML += '<button class="dropdown-item" type="button" onclick="ChgStatus(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\',\'T\','+'\''+cbtnids+'\')">Cartao</button>';

	trHTML += '</div>'

	trHTML += '</td>'

	trHTML += '<td>'+object['HIST']+'</td>';

	trHTML += '<td>';

	if (cDadosPgt.indexOf('#RH#') !== -1){
		trHTML += '<button type="button" id="'+cbtnz2+'" class="btn btn-outline-'+ccbtn+' btn-sm" onclick="showZ2(\''+cEmpresa+'\',\''+object['E2RECNO']+'\',\'#userlib#\','+'\''+cbtnz2+'\')">'+cDadosPgt+'</button>';
	} else {
		trHTML += cDadosPgt;
	}

	trHTML += '</td>'

	trHTML += '<td>'+object['OPER']+'</td>';

	anexos = '';
	if (Array.isArray(object['F1_ANEXOS'])) {
		object['F1_ANEXOS'].forEach(object => {
		anexos += '<a href="#iprest#/RestLibPN/v4?empresa='+cEmpresa+'&documento='+object['F1_ENCODE']+'&tpanexo=P" class="link-primary">'+object['F1_ANEXO']+'</a>&nbsp;&nbsp;';
	})
	}
	trHTML += '<td>'+anexos+'</td>';

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


tableSE2 = $('#tableSE2').DataTable({
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
        { data: 'Título' },
        { data: 'Fornecedor' },
        { data: 'Forma Pgto' },
        { data: 'Vencto' },
        { data: 'Portador' },
        { data: 'Lote' },
        { data: 'Valor' },
        { data: 'Saldo' },
        { data: 'Status' },
        { data: 'Histórico' },
        { data: 'Dados Pgto' },
        { data: 'Operador' },
        { data: 'Anexos' }
  ],
  "columnDefs": [
        {
            target: 14,
            visible: false,
            searchable: false
        }
  ],
  "order": [[1,'asc']],
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
$('#tableSE2 tbody').on('click', 'td.dt-control', function () {
    var tr = $(this).closest('tr');
    var row = tableSE2.row(tr);
 
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

async function getZ2(empresa,e2recno,userlib) {
let urlZ2 = '#iprest#/RestTitCP/v1?empresa='+empresa+'&e2recno='+e2recno+'&userlib='+userlib;
	try {
	let res = await fetch(urlZ2);
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
	itens += '<td>'+object['Z2_NOMDEP']+'</td>';
	itens += '<td>'+object['Z2_CPF']+'</td>';
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

async function getE2(empresa,e2recno,userlib) {
let urlE2 = '#iprest#/RestTitCP/v6?empresa='+empresa+'&e2recno='+e2recno+'&userlib='+userlib;
	try {
	let res = await fetch(urlE2);
		return await res.json();
		} catch (error) {
	console.log(error);
		}
	}

async function showE2(empresa,e2recno,userlib,cbtnz2) {

document.getElementById(cbtnz2).disabled = true;
document.getElementById(cbtnz2).innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>';

let dadosE2 = await getE2(empresa,e2recno,userlib);
let itens = '';
let i = 0;
let foot = '';
let anexos = '';
let f1recno = dadosE2['F1RECNO'];
let btnM = '';

document.getElementById('E2Prefixo').value = dadosE2['E2_PREFIXO'];
document.getElementById('E2Num').value = dadosE2['E2_NUM'];
document.getElementById('E2NomFor').value = dadosE2['A2_NOME'];
document.getElementById('E2Emissao').value = dadosE2['E2_EMISSAO'];
document.getElementById('E2VencRea').value = dadosE2['E2_VENCREA'];
document.getElementById('F1User').value = dadosE2['F1_XXUSER'];
document.getElementById('E2Hist').value = dadosE2['E2_HIST'];
document.getElementById('D1Hist').value = dadosE2['D1_XXHIST'];
document.getElementById('E2Lote').value = dadosE2['LOTE'];
document.getElementById('F1MsFin').value = dadosE2['F1_XXMSFIN'];

if (Array.isArray(dadosE2.DADOSD1)) {
   dadosE2.DADOSD1.forEach(object => {
    i++
	itens += '<tr>';
	itens += '<td>'+object['D1_COD']+'</td>';	
	itens += '<td>'+object['B1_DESC']+'</td>';
	itens += '<td>'+object['D1_CC']+'</td>';
	itens += '<td align="right">'+object['D1_VALOR']+'</td>';
	itens += '</tr>';
  })
}

if (Array.isArray(dadosE2.F1_ANEXOS)) {
	dadosE2.F1_ANEXOS.forEach(object => {
	anexos += '<a href="#iprest#/RestLibPN/v4?empresa='+empresa+'&documento='+object['F1_ENCODE']+'&tpanexo=P" class="link-primary">'+object['F1_ANEXO']+'</a></br>';
  })
}
document.getElementById("anexosE2").innerHTML = anexos;

document.getElementById("E2Table").innerHTML = itens;
foot = '<th scope="row" colspan="8" style="text-align:right;">'+dadosE2['D1_TOTAL']+'</th>'
document.getElementById("E2Foot").innerHTML = foot;

btnM = '<button type="button" class="btn btn-outline-secondary" onclick="envmot(\''+empresa+'\',\''+f1recno+'\',\'#userlib#\')">Enviar aviso</button>';
document.getElementById("btnMsFin").innerHTML = btnM;

$("#titE2Modal").text('Título do Contas a Pagar - Empresa: '+dadosE2['EMPRESA'] + ' - Usuário: '+dadosE2['USERNAME']);
$('#E2Modal').modal('show');
$('#E2Modal').on('hidden.bs.modal', function () {
	location.reload();
	})
}


async function envmot(empresa,f1recno,userlib){
let resposta = ''
let F1MsFin  = document.getElementById("F1MsFin").value;

let dataObject = { msfin:F1MsFin, };

fetch('#iprest#/RestTitCP/v8?empresa='+empresa+'&f1recno='+f1recno+'&userlib='+userlib, {
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

	  //$('#avalModal').modal('hide');
	  $('#E2Modal').modal('toggle');
	  
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
		} else if (acao == 'L'){
			cbtn = 'Parcelamento';
		} else if (acao == 'T'){
			cbtn = 'Cartao';
		} else {
			cbtn = 'Em Aberto';
		}
		document.getElementById(btnids).textContent = cbtn;
	})
}

async function Excel(){
let newvenci = document.getElementById("DataVencI").value;
let newvamdi = newvenci.substring(0, 4)+newvenci.substring(5, 7)+newvenci.substring(8, 10)
let newvencf = document.getElementById("DataVencF").value;
let newvamdf = newvencf.substring(0, 4)+newvencf.substring(5, 7)+newvencf.substring(8, 10)

window.open("#iprest#/RestTitCP/v5?empresa=#empresa#&vencini="+newvamdi+'&vencfim='+newvamdf+'&userlib=#userlib#',"_self");
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
let newvenci = document.getElementById("DataVencI").value;
let newvamdi = newvenci.substring(0, 4)+newvenci.substring(5, 7)+newvenci.substring(8, 10)
let newvencf = document.getElementById("DataVencF").value;
let newvamdf = newvencf.substring(0, 4)+newvencf.substring(5, 7)+newvencf.substring(8, 10)
let url1 = '#iprest#/RestTitCP/v7?empresa=#empresa#&vencini='+newvamdi+'&vencfim='+newvamdf+'&userlib=#userlib#';
let urlT = await getUrlTmp(url1);
let curlT = urlT[0].URLTMP;
window.open(curlT,"_self");

}

async function AltVenc(){
let newvenci = document.getElementById("DataVencI").value;
let newvamdi = newvenci.substring(0, 4)+newvenci.substring(5, 7)+newvenci.substring(8, 10)
let newvencf = document.getElementById("DataVencF").value;
let newvamdf = newvencf.substring(0, 4)+newvencf.substring(5, 7)+newvencf.substring(8, 10)
window.open("#iprest#/RestTitCP/v2?empresa=#empresa#&vencini="+newvamdi+'&vencfim='+newvamdf+'&userlib=#userlib#',"_self");
}

</script>
</body>
</html>
ENDCONTENT

cHtml := STRTRAN(cHtml,"#iprest#"	 ,u_BkRest())
cHtml := STRTRAN(cHtml,"#BKDTStyle#" ,u_BKDTStyle())
cHtml := STRTRAN(cHtml,"#BKDTScript#",u_BKDTScript())
cHtml := STRTRAN(cHtml,"#BKFavIco#"  ,u_BkFavIco())

If !Empty(::userlib)
	cHtml := STRTRAN(cHtml,"#userlib#",::userlib)
	cHtml := STRTRAN(cHtml,"#cUserName#",cUserName)
EndIf

cHtml := STRTRAN(cHtml,"#empresa#",::empresa)
cHtml := STRTRAN(cHtml,"#vencini#",::vencini)
cHtml := STRTRAN(cHtml,"#vencfim#",::vencfim)
cHtml := STRTRAN(cHtml,"#datavencI#",SUBSTR(::vencini,1,4)+"-"+SUBSTR(::vencini,5,2)+"-"+SUBSTR(::vencini,7,2))   // Formato: 2023-10-24 input date
cHtml := STRTRAN(cHtml,"#datavencF#",SUBSTR(::vencfim,1,4)+"-"+SUBSTR(::vencfim,5,2)+"-"+SUBSTR(::vencfim,7,2))   // Formato: 2023-10-24 input date

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
	cDropEmp += '<li><a class="dropdown-item" href="'+u_BkRest()+'/RestTitCP/v2?empresa='+aEmpresas[nE,1]+'&vencini='+self:vencini+'&vencfim='+self:vencfim+'&userlib='+self:userlib+'">'+aEmpresas[nE,1]+'-'+aEmpresas[nE,2]+'</a></li>'+CRLF
Next
cDropEmp +='<li><hr class="dropdown-divider"></li>'+CRLF
cDropEmp +='<li><a class="dropdown-item" href="'+u_BkRest()+'/RestTitCP/v2?empresa=Todas&vencini='+self:vencini+'&vencfim='+self:vencfim+'&userlib='+self:userlib+'">Todas</a></li>'+CRLF

cHtml := STRTRAN(cHtml,"#DropEmpresas#",cDropEmp)
// <-- Seleção de Empresas

//StrIConv( cHtml, "UTF-8", "CP1252")
//DecodeUtf8(cHtml)
cHtml := StrIConv( cHtml, "CP1252", "UTF-8")

// Desabilitar para testar o html
/*
If __cUserId == '000000'
	Memowrite(u_STmpDir()+"cp.html",cHtml)
EndIf
u_MsgLog("RESTTITCP",__cUserId+' - '+::userlib)
*/

Self:SetHeader("Access-Control-Allow-Origin", "*")
self:setResponse(cHTML)
self:setStatus(200)

return .T.


// Montagem da Query
Static Function TmpQuery(cQrySE2,xEmpresa,xVencIni,xVencFim)

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
		// Remover Tero e Cmog para a query não ficar muito grande
		If Substr(cEmpr,1,1) == "9"
			Loop
		EndIf
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += AllTrim(" SELECT "+CRLF)
	cQuery += AllTrim("	  '"+cEmpresa+"-"+cNomeEmp+"' AS EMPRESA"+CRLF)
	cQuery += AllTrim("	 ,E2_TIPO"+CRLF)
	cQuery += AllTrim("	 ,E2_PREFIXO"+CRLF)
	cQuery += AllTrim("	 ,E2_NUM"+CRLF)
	cQuery += AllTrim("	 ,E2_PARCELA"+CRLF)
	cQuery += AllTrim("	 ,E2_FORNECE"+CRLF)
	cQuery += AllTrim("	 ,E2_PORTADO"+CRLF)
	cQuery += AllTrim("	 ,E2_LOJA"+CRLF)
	//cQuery += AllTrim("	 ,E2_NATUREZ"+CRLF)
	cQuery += AllTrim("	 ,E2_HIST"+CRLF)
	//cQuery += AllTrim("	 ,E2_USERLGA"+CRLF )
	//cQuery += AllTrim("	 ,E2_BAIXA"+CRLF)
	cQuery += AllTrim("	 ,E2_VENCREA"+CRLF)
	cQuery += AllTrim("	 ,E2_VALOR"+CRLF)
	//cQuery += AllTrim("	 ,E2_XXPRINT"+CRLF)
	cQuery += AllTrim("	 ,E2_XXPGTO"+CRLF)
	cQuery += AllTrim("	 ,E2_XXOPER"+CRLF)
	cQuery += AllTrim("	 ,E2_XXTIPBK"+CRLF)
	cQuery += AllTrim("	 ,E2_XXLOTEB"+CRLF)
	//cQuery += AllTrim("	 ,E2_NUMBOR"+CRLF)
	cQuery += AllTrim("	 ,SE2.R_E_C_N_O_ AS E2RECNO"+CRLF)
	cQuery += AllTrim("	 ,A2_NOME"+CRLF)
	cQuery += AllTrim("	 ,A2_TIPO"+CRLF)
	cQuery += AllTrim("	 ,A2_CGC"+CRLF) //x
	cQuery += AllTrim("	 ,A2_BANCO"+CRLF)
	cQuery += AllTrim("	 ,A2_AGENCIA"+CRLF)
	cQuery += AllTrim("	 ,A2_NUMCON"+CRLF)
	cQuery += AllTrim("	 ,(CASE WHEN E2_SALDO = E2_VALOR "+CRLF)
	cQuery += AllTrim("	 		THEN E2_VALOR + E2_ACRESC - E2_DECRESC"+CRLF)
	cQuery += AllTrim("	 		ELSE E2_SALDO END) AS SALDO"+CRLF)

	//cQuery += AllTrim("	 ,"+IIF(dDtIni <> dDtFim,"+' '+E2_VENCREA",'')+"+ ")

	cQuery += AllTrim("	 ,(CASE WHEN E2_XTIPOPG <> ' ' ")+CRLF
	cQuery += AllTrim("			THEN E2_XTIPOPG ")+CRLF
	cQuery += AllTrim("			WHEN (F1_XTIPOPG IS NULL) AND (Z2_BANCO IS NULL) ")+CRLF
	cQuery += AllTrim("	 		THEN E2_TIPO+' '+E2_PORTADO"+CRLF)
	cQuery += AllTrim("	 		WHEN F1_XTIPOPG IS NULL AND (E2_PORTADO IS NOT NULL) THEN 'LF '+E2_PORTADO+' '+E2_TIPO"+CRLF)
	cQuery += AllTrim("	 		ELSE F1_XTIPOPG END)"+" AS FORMPGT"+CRLF)

	cQuery += AllTrim("	 ,Z2_NOME"+CRLF)
	cQuery += AllTrim("	 ,Z2_NOMMAE"+CRLF)
	cQuery += AllTrim("	 ,Z2_NOMDEP"+CRLF)
	cQuery += AllTrim("	 ,Z2_BORDERO"+CRLF)
	cQuery += AllTrim("	 ,(CASE WHEN (Z2_BANCO IS NOT NULL) AND "+CRLF)
	cQuery += AllTrim("	 					(SELECT COUNT(Z2_E2NUM) FROM "+cTabSZ2+" SZ2T"+CRLF)
	cQuery += AllTrim("	 			    		WHERE SZ2T.D_E_L_E_T_ = ''"+CRLF)
	cQuery += AllTrim("	  						AND SZ2T.Z2_FILIAL = ' '"+CRLF)
	cQuery += AllTrim("	  	 					AND SZ2T.Z2_CODEMP = '"+cEmpr+"'"+CRLF)
	cQuery += AllTrim("	 						AND SE2.E2_PREFIXO = SZ2T.Z2_E2PRF"+CRLF)
	cQuery += AllTrim("	 						AND SE2.E2_NUM     = SZ2T.Z2_E2NUM"+CRLF)
	cQuery += AllTrim("	 	 					AND SE2.E2_PARCELA = SZ2T.Z2_E2PARC"+CRLF)
	cQuery += AllTrim("	 	 					AND SE2.E2_TIPO    = SZ2T.Z2_E2TIPO"+CRLF)
	cQuery += AllTrim("	 	 					AND SE2.E2_FORNECE = SZ2T.Z2_E2FORN"+CRLF)
	cQuery += AllTrim("	 	 					AND SE2.E2_LOJA    = SZ2T.Z2_E2LOJA) = 1"+CRLF)
	cQuery += AllTrim("	 		THEN 'Bco: '+Z2_BANCO+' Ag: '+Z2_AGENCIA+'-'+Z2_DIGAGEN+' C/C: '+Z2_CONTA+'-'+Z2_DIGCONT"+CRLF)
	cQuery += AllTrim("	 		ELSE '' END)"+" AS Z2CONTA"+CRLF)

	cQuery += AllTrim("	 ,F1_DOC"+CRLF)
	cQuery += AllTrim("	 ,E2_XTIPOPG AS F1_XTIPOPG"+CRLF)

	cQuery += AllTrim("	 ,F1_XNUMPA"+CRLF)
	cQuery += AllTrim("	 ,F1_XBANCO"+CRLF)
	cQuery += AllTrim("	 ,F1_XAGENC"+CRLF)
	cQuery += AllTrim("	 ,F1_XNUMCON"+CRLF)
	cQuery += AllTrim("	 ,F1_XXTPPIX"+CRLF)
	cQuery += AllTrim("	 ,F1_XXCHPIX "+CRLF)
	//cQuery += AllTrim("	 ,F1_USERLGI"+CRLF )
	cQuery += AllTrim("	 ,F1_XXUSER"+CRLF)
	//cQuery += AllTrim("	 ,D1_COD"+CRLF)
	//cQuery += AllTrim("	 ,B1_DESC"+CRLF)
	//cQuery += AllTrim("	 ,D1_CC"+CRLF)
	//cQuery += AllTrim("	 ,CTT_DESC01"+CRLF)
	cQuery += AllTrim("  ,CONVERT(VARCHAR(800),CONVERT(Binary(800),D1_XXHIST)) AS D1_XXHIST "+CRLF)

	cQuery += AllTrim("	 FROM "+cTabSE2+" SE2 "+CRLF)

	cQuery += AllTrim("	 LEFT JOIN "+cTabSF1+" SF1 ON"+CRLF)
	cQuery += AllTrim("	 	SE2.E2_FILIAL      = SF1.F1_FILIAL"+CRLF)
	cQuery += AllTrim("	 	AND SE2.E2_NUM     = SF1.F1_DOC "+CRLF)
	cQuery += AllTrim("	 	AND SE2.E2_PREFIXO = SF1.F1_SERIE"+CRLF)
	cQuery += AllTrim("	 	AND SE2.E2_FORNECE = SF1.F1_FORNECE"+CRLF)
	cQuery += AllTrim("	 	AND SE2.E2_LOJA    = SF1.F1_LOJA"+CRLF)
	cQuery += AllTrim("	 	AND SF1.D_E_L_E_T_ = ''"+CRLF)

	cQuery += AllTrim("	 LEFT JOIN "+cTabSA2+"  SA2 ON"+CRLF)
	cQuery += AllTrim("	 	SA2.A2_FILIAL      = '  '"+CRLF)
	cQuery += AllTrim("	 	AND SE2.E2_FORNECE = SA2.A2_COD"+CRLF)
	cQuery += AllTrim("	 	AND SE2.E2_LOJA    = SA2.A2_LOJA"+CRLF)
	cQuery += AllTrim("	 	AND SA2.D_E_L_E_T_ = ''"+CRLF)
	
	cQuery += AllTrim(" LEFT JOIN "+cTabSD1+" SD1 ON SD1.D_E_L_E_T_=''"+ CRLF)
	cQuery += AllTrim("   AND D1_FILIAL  = '"+xFilial("SD1")+"' "+ CRLF)
	cQuery += AllTrim("   AND D1_DOC     = F1_DOC"+ CRLF)
	cQuery += AllTrim("   AND D1_SERIE   = F1_SERIE"+ CRLF)
	cQuery += AllTrim("   AND D1_FORNECE = F1_FORNECE"+ CRLF)
	cQuery += AllTrim("   AND D1_LOJA    = F1_LOJA"+ CRLF)
	cQuery += AllTrim("   AND SD1.R_E_C_N_O_ = "+ CRLF)
	cQuery += AllTrim("   	(SELECT TOP 1 R_E_C_N_O_ FROM "+cTabSD1+" SD1T "+ CRLF)
	cQuery += AllTrim("   	  WHERE SD1T.D_E_L_E_T_     = '' "+ CRLF)
	cQuery += AllTrim("   	        AND SD1T.D1_FILIAL  = '"+xFilial("SD1")+"' "+ CRLF)
	cQuery += AllTrim("   			AND SD1T.D1_DOC     = F1_DOC"+ CRLF)
	cQuery += AllTrim("   			AND SD1T.D1_SERIE   = F1_SERIE"+ CRLF)
	cQuery += AllTrim("   			AND SD1T.D1_FORNECE = F1_FORNECE"+ CRLF)
	cQuery += AllTrim("   			AND SD1T.D1_LOJA    = F1_LOJA"+ CRLF)
	cQuery += AllTrim("		 ORDER BY D1_ITEM)"+ CRLF)
	
	cQuery += AllTrim("	 LEFT JOIN "+cTabSZ2+" SZ2 ON SZ2.D_E_L_E_T_=''"+CRLF)
	cQuery += AllTrim("	 			AND SZ2.Z2_FILIAL  = ' '"+CRLF)
	cQuery += AllTrim("	 	 		AND SZ2.Z2_CODEMP  = '"+cEmpr+"' "+CRLF)
	cQuery += AllTrim("	 	 		AND SE2.E2_PREFIXO = SZ2.Z2_E2PRF"+CRLF)
	cQuery += AllTrim("	 	 		AND SE2.E2_NUM     = SZ2.Z2_E2NUM "+CRLF)
	cQuery += AllTrim("	 	 		AND SE2.E2_PARCELA = SZ2.Z2_E2PARC"+CRLF)
	cQuery += AllTrim("	 	 		AND SE2.E2_TIPO    = SZ2.Z2_E2TIPO"+CRLF)
	cQuery += AllTrim("	 	 		AND SE2.E2_FORNECE = SZ2.Z2_E2FORN"+CRLF)
	cQuery += AllTrim("	 	 		AND SE2.E2_LOJA    = SZ2.Z2_E2LOJA"+CRLF)
	cQuery += AllTrim("	 	 		AND SZ2.Z2_STATUS  = 'S'"+CRLF)
	cQuery += AllTrim("	 		    AND SZ2.R_E_C_N_O_ = "+CRLF)
	cQuery += AllTrim("	    	(SELECT TOP 1 R_E_C_N_O_ FROM "+cTabSZ2+" SZ2T "+CRLF)
	cQuery += AllTrim("	    	  WHERE SZ2T.D_E_L_E_T_   = ''"+CRLF)
	cQuery += AllTrim("	 			AND SZ2T.Z2_FILIAL = ' '")+CRLF
	cQuery += AllTrim("	 	 		AND SZ2T.Z2_CODEMP = '"+cEmpr+"'"+CRLF)
	cQuery += AllTrim("	 	 		AND SE2.E2_PREFIXO = SZ2T.Z2_E2PRF"+CRLF)
	cQuery += AllTrim("	 	 		AND SE2.E2_NUM     = SZ2T.Z2_E2NUM "+CRLF)
	cQuery += AllTrim("	 	 		AND SE2.E2_PARCELA = SZ2T.Z2_E2PARC"+CRLF)
	cQuery += AllTrim("	 	 		AND SE2.E2_TIPO    = SZ2T.Z2_E2TIPO"+CRLF)
	cQuery += AllTrim("	 	 		AND SE2.E2_FORNECE = SZ2T.Z2_E2FORN"+CRLF)
	cQuery += AllTrim("	 	 		AND SE2.E2_LOJA    = SZ2T.Z2_E2LOJA"+CRLF)
	cQuery += AllTrim("	 	 		AND SZ2T.Z2_STATUS = 'S'"+CRLF)
	cQuery += AllTrim("	 		 ORDER BY SZ2T.R_E_C_N_O_)"+CRLF)

	/*
	cQuery += AllTrim("  LEFT JOIN "+cTabCTT+" CTT ON CTT.D_E_L_E_T_=''"+CRLF)
	cQuery += AllTrim("    AND CTT.CTT_FILIAL = '"+xFilial("CTT")+"' "+CRLF)
	cQuery += AllTrim("    AND CTT.CTT_CUSTO  = SD1.D1_CC"+CRLF)

	cQuery += AllTrim("  LEFT JOIN "+cTabSB1+" SB1 ON SB1.D_E_L_E_T_=''"+CRLF)
	cQuery += AllTrim("    AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "+CRLF)
	cQuery += AllTrim("    AND SB1.B1_COD    = SD1.D1_COD"+CRLF)
	*/

	cQuery += AllTrim("	 WHERE SE2.D_E_L_E_T_ = '' "+ CRLF)
	cQuery += AllTrim("  AND E2_FILIAL = '"+xFilial("SE2")+"' "+CRLF)

	cQuery += AllTrim("  AND E2_VENCREA >= '"+xVencIni+"' "+CRLF)
	cQuery += AllTrim("  AND E2_VENCREA <= '"+xVencFim+"' "+CRLF)

Next

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  * " + CRLF
cQuery += "  ,ISNULL(D1_XXHIST,E2_HIST) AS HIST"+CRLF
//cQuery += "  ,ISNULL(Z2_BORDERO,E2_XXLOTEB) AS LOTE"+CRLF
cQuery += "  ,(CASE WHEN ISNULL(Z2_BORDERO,E2_XXLOTEB) = ' ' THEN E2_XXLOTEB ELSE ISNULL(Z2_BORDERO,E2_XXLOTEB) END) AS LOTE"+CRLF
cQuery += "  FROM RESUMO " + CRLF
cQuery += " ORDER BY EMPRESA,E2_VENCREA,E2_PORTADO,FORMPGT,E2_FORNECE" + CRLF

cQuery := STRTRAN(cQuery,CHR(9)," ")
cQuery := STRTRAN(cQuery,"  "," ")
//u_LogMemo("RESTTITCP1.SQL",cQuery)

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
		If Empty((cQrySE2)->F1_XBANCO) .AND. !u_IsFornBK((cQrySE2)->E2_FORNECE)
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
aadd(aSetFields,aSize(FWSX3Util():GetFieldStruct( "Z2_CODEMP" ),4))

//aadd(aSetFields,{"Z2_CODEMP","C",2,0})

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
