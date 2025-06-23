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
	WSDATA vencini      AS STRING
	WSDATA vencfim      AS STRING
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

	WSMETHOD PUT BANCO;
		DESCRIPTION "Alterar o banco do titulo a receber" ;
		WSSYNTAX "/RestTitCR/v4";
		PATH "/RestTitCR/v4";
		TTALK "v1";
		PRODUCES APPLICATION_JSON

END WSRESTFUL


//v3
WSMETHOD PUT STATUS QUERYPARAM empresa,e1recno,userlib,banco WSREST RestTitCR 

Local cJson			:= Self:GetContent()   
Local lRet			:= .T.
Local oJson			As Object
Local aParams		As Array
Local cMsg			As Char

::setContentType('application/json')

oJson := JsonObject():New()
oJson:FromJSON(cJson)

If u_BkAvPar(::userlib,@aParams,@cMsg)

	lRet := fStatus(::empresa,::e1recno,::banco,@cMsg,oJson)

EndIf

oJson['liberacao'] := StrIConv(cMsg, "CP1252", "UTF-8")

cRet := oJson:ToJson()

FreeObj(oJson)
// CORS
Self:SetHeader("Access-Control-Allow-Origin", "*")

Self:SetResponse(cRet)
  
Return lRet



Static Function fStatus(empresa,e1recno,banco,cMsg,oJson)
Local lRet 		:= .F.
Local cQuery	:= ""
Local cTabSE1	:= "SE1"+empresa+"0"
Local cQrySE1	:= GetNextAlias()
Local cNum		:= ""
Local cTipo		:= ""

// Dados para gravar
Local cZyDtRec	:= STRTRAN(AllTrim(oJson['zyDtRec']),"-","")
Local cZYObs	:= AllTrim(oJson['zyobs'])
Local aAreaSZY
Local cNewAls
Local cModo
Local dPrev

Default cMsg	:= ""
Default cMotivo := ""

Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

dPrev  := STOD(cZyDtRec)
u_MsgLog("fStatus",cZyDtRec + " - "+DTOC(dPrev))

cQuery := "SELECT "
cQuery += "   SE1.E1_TIPO"
cQuery += "  ,SE1.E1_PREFIXO"
cQuery += "  ,SE1.E1_NUM"
cQuery += "  ,SE1.E1_PARCELA"
cQuery += "  ,SE1.D_E_L_E_T_ AS E1DELET"
cQuery += " FROM "+cTabSE1+" SE1 "
cQuery += " WHERE SE1.R_E_C_N_O_ = "+e1recno

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySE1,.T.,.T.)

// E1_XXTPPRV: 0=Sem Previsao;1=Aguardando Previsao;2=Previsao Informada

cNum := (cQrySE1)->E1_NUM
cTipo := (cQrySE1)->E1_TIPO
Do Case
	Case (cQrySE1)->(Eof()) 
		cMsg:= "não encontrado"
	Case (cQrySE1)->E1DELET = '*'
		cMsg:= "foi excluído"
	OtherWise 
		// Alterar o Status
		cMsg   := banco
		cQuery := "UPDATE "+cTabSE1+CRLF
		cQuery += "  SET  E1_BCOCLI = '"+banco+"'"+CRLF
		If !Empty(banco)
			cQuery += "      ,E1_XXDTREC = '"+cZyDtRec+"'"+CRLF
		Else
			cQuery += "      ,E1_XXDTREC = ''"+CRLF
		EndIf
		cQuery += "      ,E1_XXOPER  = '"+__cUserId+"'"+CRLF
		cQuery += "      ,E1_XXHISTM = CONVERT(VARBINARY(MAX),'"+cZYObs+"')"+CRLF
		cQuery += " FROM "+cTabSE1+" SE1"+CRLF
		cQuery += " WHERE SE1.R_E_C_N_O_ = "+e1recno+CRLF

		If TCSQLExec(cQuery) < 0 
			cMsg := "Erro: "+TCSQLERROR()
		Else
			lRet := .T.
		EndIf


		// Gravar Log de alterações na tabela SZY
		dbSelectArea("SZY")
		aAreaSZY	:= SZY->( GetArea() )
		cModo		:= FWModeAccess("SZY")
		cNewAls		:= GetNextAlias() //Obtem novo Alias

		IF EmpOpenFile(cNewAls,"SZY",1,.T.,empresa,@cModo)

			bBlock := ErrorBlock( { |e| u_LogMemo("RESTTITCR.LOG",e:Description) } )
			BEGIN SEQUENCE
				RecLock(cNewAls,.T.)
				(cNewAls)->ZY_FILIAL	:= xFilial("SZY")
				(cNewAls)->ZY_TIPO		:= cTipo
				(cNewAls)->ZY_NUM		:= cNum
				(cNewAls)->ZY_PREFIXO	:= (cQrySE1)->E1_PREFIXO
				(cNewAls)->ZY_PARCELA	:= (cQrySE1)->E1_PARCELA
				(cNewAls)->ZY_DATA		:= DATE()
				(cNewAls)->ZY_HORA		:= SUBSTR(TIME(),1,5)
				(cNewAls)->ZY_OBS		:= cZYObs
				(cNewAls)->ZY_BANCO		:= banco
				(cNewAls)->ZY_OPER		:= __cUserId
				(cNewAls)->ZY_DTREC		:= STOD(cZyDtRec)
				(cNewAls)->(MsUnlock())
				(cNewAls)->(dbCloseArea())
			RECOVER
				lRet := .F.
			END SEQUENCE
			ErrorBlock(bBlock)
		EndIF

		RestArea( aAreaSZY )

EndCase

cMsg := cNum+" "+cMsg

u_MsgLog("RESTTitCR",cMsg)

(cQrySE1)->(dbCloseArea())

Return lRet

//v4
WSMETHOD PUT BANCO QUERYPARAM empresa,e1recno,userlib,banco WSREST RestTitCR 

Local cJson			:= Self:GetContent()   
Local lRet			:= .T.
Local oJson			As Object
Local aParams		As Array
Local cMsg			As Char

::setContentType('application/json')

oJson := JsonObject():New()
oJson:FromJSON(cJson)

If u_BkAvPar(::userlib,@aParams,@cMsg)

	lRet := fBanco(::empresa,::e1recno,::banco,@cMsg)

EndIf

oJson['liberacao'] := StrIConv(cMsg, "CP1252", "UTF-8")

cRet := oJson:ToJson()

FreeObj(oJson)
// CORS
Self:SetHeader("Access-Control-Allow-Origin", "*")

Self:SetResponse(cRet)
  
Return lRet


Static Function fBanco(empresa,e1recno,banco,cMsg)
Local lRet 		:= .F.
Local cQuery	:= ""
Local cTabSE1	:= "SE1"+empresa+"0"
Local cQrySE1	:= GetNextAlias()
Local cNum		:= ""

Default cMsg	:= ""
Default cMotivo := ""

Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

cQuery := "SELECT "
cQuery += "  SE1.E1_NUM"
cQuery += "  ,SE1.D_E_L_E_T_ AS E1DELET"
cQuery += " FROM "+cTabSE1+" SE1 "
cQuery += " WHERE SE1.R_E_C_N_O_ = "+e1recno

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySE1,.T.,.T.)

cNum := (cQrySE1)->E1_NUM
Do Case
	Case (cQrySE1)->(Eof()) 
		cMsg:= "não encontrado"
	Case (cQrySE1)->E1DELET = '*'
		cMsg:= "foi excluído"
	OtherWise 
		// Alterar o Status
		cMsg 	:= banco
		cQuery := "UPDATE "+cTabSE1+CRLF
		cQuery += "  SET E1_BCOCLI = '"+banco+"',"+CRLF
		cQuery += "      E1_XXOPER = '"+__cUserId+"'"+CRLF
		cQuery += " FROM "+cTabSE1+" SE1"+CRLF
		cQuery += " WHERE SE1.R_E_C_N_O_ = "+e1recno+CRLF
		If TCSQLExec(cQuery) < 0
			cMsg := "Erro: "+TCSQLERROR()
		Else
			lRet := .T.
		EndIf
EndCase

cMsg := cNum+" Banco -"+cMsg+" - "+e1recno

u_MsgLog("RESTTitCR-V4",cMsg)

(cQrySE1)->(dbCloseArea())

Return lRet



// v5
WSMETHOD GET PLANCR QUERYPARAM empresa,vencini,vencfim WSREST RestTitCR
	Local cProg 	:= "RestTitCR"
	Local cTitulo	:= "Contas a Receber WEB"
	Local cDescr 	:= "Exportação Excel do Contas a Receber Web"
	Local cVersao	:= "16/04/2025"
	Local oRExcel	AS Object
	Local oPExcel	AS Object

    Local cFile  	:= ""
	Local cName  	:= "" //Decode64(self:documento)
	Local cFName 	:= ""
    Local oFile  	AS Object

	Local cQrySE1	:= GetNextAlias()

	u_MsgLog(cProg,cTitulo+" - Excel "+self:vencini+" "+self:vencfim)

	// Query para selecionar os Títulos a Receber
	TmpQuery(cQrySE1,self:empresa,self:vencini,self:vencfim)


	// Definição do Arq Excel
	oRExcel := RExcel():New(cProg)
	oRExcel:SetTitulo(cTitulo)
	oRExcel:SetVersao(cVersao)
	oRExcel:SetDescr(cDescr)

	// Definição da Planilha 1
	oPExcel:= PExcel():New(cProg,cQrySE1)
	oPExcel:SetTitulo("Empresa: "+self:empresa+" - Vencimento: "+DTOC(STOD(self:vencini)) +" a "+DTOC(STOD(self:vencfim)))

	oPExcel:AddCol("EMPRESA","EMPRESA","Empresa","")

	oPExcel:AddCol("TIPO"   ,"E1_TIPO","Tipo","E1_TIPO")

	oPExcel:AddCol("TITULO" ,"(E1_PREFIXO+E1_NUM+E1_PARCELA)","Título","")

	oPExcel:AddCol("CONTRATO","CONTRATO","Contrato","")
	oPExcel:GetCol("CONTRATO"):SetHAlign("C")

	oPExcel:AddCol("Cliente","A1_NOME","Cliente","A1_NOME")

	oPExcel:AddCol("VENC","STOD(E1_VENCREA)","Vencto","E1_VENCREA")

	oPExcel:AddCol("VENCORI","STOD(E1_VENCORI)","Vencto Original","E1_VENCORI")

	oPExcel:AddCol("EMISSAO","STOD(E1_EMISSAO)","Emissao","E1_EMISSAO")

	oPExcel:AddCol("EMISSAO","STOD(E1_BAIXA)","Baixa","E1_BAIXA")

	oPExcel:AddCol("BANCO","E1_BCOCLI","Banco","E1_BCOCLI")
	oPExcel:GetCol("BANCO"):SetHAlign("C")

	oPExcel:AddCol("COMPET","C5_XXCOMPM","Competência","C5_XXCOMPM")
	oPExcel:GetCol("COMPET"):SetHAlign("C")

	oPExcel:AddCol("VALOR","E1_VALOR","Valor","E1_VALOR")
	oPExcel:GetCol("VALOR"):SetDecimal(2)
	oPExcel:GetCol("VALOR"):SetTotal(.T.)

	oPExcel:AddCol("IRRF","E1_IRRF","IRRF","E1_IRRF")
	oPExcel:GetCol("IRRF"):SetDecimal(2)
	oPExcel:GetCol("IRRF"):SetTotal(.T.)

	oPExcel:AddCol("INSS","E1_INSS","INSS","E1_INSS")
	oPExcel:GetCol("INSS"):SetDecimal(2)
	oPExcel:GetCol("INSS"):SetTotal(.T.)

	oPExcel:AddCol("PIS","E1_PIS","PIS","E1_PIS")
	oPExcel:GetCol("PIS"):SetDecimal(2)
	oPExcel:GetCol("PIS"):SetTotal(.T.)

	oPExcel:AddCol("COFINS","E1_COFINS","COFINS","E1_COFINS")
	oPExcel:GetCol("COFINS"):SetDecimal(2)
	oPExcel:GetCol("COFINS"):SetTotal(.T.)

	oPExcel:AddCol("CSLL","E1_CSLL","CSLL","E1_CSLL")
	oPExcel:GetCol("CSLL"):SetDecimal(2)
	oPExcel:GetCol("CSLL"):SetTotal(.T.)

	oPExcel:AddCol("ISS","E1_ISS","ISS","E1_ISS")
	oPExcel:GetCol("ISS"):SetDecimal(2)
	oPExcel:GetCol("ISS"):SetTotal(.T.)

	oPExcel:AddCol("ISSBI","E1_XXISSBI","ISS BI","E1_XXISSBI")
	oPExcel:GetCol("ISSBI"):SetDecimal(2)
	oPExcel:GetCol("ISSBI"):SetTotal(.T.)

	oPExcel:AddCol("XXVCVIN","F2_XXVCVIN","vinculada","F2_XXVCVIN")
	oPExcel:GetCol("XXVCVIN"):SetDecimal(2)
	oPExcel:GetCol("XXVCVIN"):SetTotal(.T.)

	oPExcel:AddCol("XXVRETC","F2_XXVRETC","Retençao Ctr.","F2_XXVRETC")
	oPExcel:GetCol("XXVRETC"):SetDecimal(2)
	oPExcel:GetCol("XXVRETC"):SetTotal(.T.)

	oPExcel:AddCol("LIQUIDO","E1_VALOR - E1_IRRF - E1_INSS - E1_PIS - E1_COFINS - E1_CSLL - F2_XXVCVIN - F2_XXVFUMD - IIF(F2_RECISS = '1',E1_ISS,0) - E1_VRETBIS - F2_XXVRETC","Líquido","E1_VALOR")
	oPExcel:GetCol("LIQUIDO"):SetDecimal(2)
	oPExcel:GetCol("LIQUIDO"):SetTotal(.T.)

	oPExcel:AddCol("SALDO","SALDO","Saldo","E1_SALDO")
	oPExcel:GetCol("SALDO"):SetDecimal(2)
	oPExcel:GetCol("SALDO"):SetTotal(.T.)

	oPExcel:AddCol("RECEBIMENTO","STOD(E1_XXDTREC)","Recebimento","E1_XXDTREC")

	oPExcel:AddCol("OPER","UsrRetName(E1_XXOPER)","Operador","")


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
WSMETHOD GET LISTCR QUERYPARAM empresa,vencini,vencfim,userlib WSREST RestTitCR
Local aListCR 		:= {}
Local cQrySE1       := GetNextAlias()
Local cJsonCli      := ''
Local lRet 			:= .T.
Local oJsonTmp	 	:= JsonObject():New()
Local aParams      	As Array
Local cMsg         	As Character
Local cNumTit 		:= ""
Local nSaldo 		:= 0
Local nLiquido		:= 0

//u_MsgLog("RESTTITCR",VarInfo("vencini",self:vencini))

If !u_BkAvPar(::userlib,@aParams,@cMsg)
  oJsonTmp['liberacao'] := cMsg
  cRet := oJsonTmp:ToJson()
  FreeObj(oJsonTmp)
  //Retorno do servico
  ::SetResponse(cRet)
  Return lRet:= .T.
EndIf

// Usuários que podem executar alguma ação
//lPerm := u_InGrupo(__cUserId,"000000")

// Query para selecionar os Títulos a Receber
TmpQuery(cQrySE1,self:empresa,self:vencini,self:vencfim)


// Campos solicitados no chamado GLPI 1611:
// 1-Empresa
// 3-Cliente (Nome)
// 4-Contrato (numero)
// 5-Centro de Custos (descrição)
// 6-Competência
// Prefixo
// 2-Titulo
// 7-Data Pagamento (campo a ser preenchido)
// 8-Banco Pagamento (campo a ser preenchido)
// 9-Emissao
// 10-Venc. Original
// 11-Ultima Baixa
// 12-Valor Bruto / Parcela
// 13-IRRF Retido
// 14-INSS Retido
// 15-PIS Retido
// 16-Cofins Retido
// 17-CSLL Retido
// 18-ISS Retido
// 19-ISS Bitributado
// 20-Conta Vinculada (valor)
// 21-Retenção Contratual
// 22-Valor Líquido
// 23-Saldo a Receber

//-------------------------------------------------------------------
// Alimenta array de Pré-notas
//-------------------------------------------------------------------
Do While ( cQrySE1 )->( ! Eof() )

	aAdd( aListCR , JsonObject():New() )

	nPos	:= Len(aListCR)
	cNumTit	:= (cQrySE1)->(E1_PREFIXO+E1_NUM+E1_PARCELA)
	cNumTit := STRTRAN(cNumTit," ","&nbsp;")

	aListCR[nPos]['EMPRESA']	:= (cQrySE1)->EMPRESA
	aListCR[nPos]['TITULO']     := TRIM(cNumTit)
	aListCR[nPos]['CLIENTE'] 	:= TRIM((cQrySE1)->A1_NOME)
	aListCR[nPos]['CONTRATO']	:= (cQrySE1)->CONTRATO
	aListCR[nPos]['DESCCC']		:= (cQrySE1)->CTT_CUSTO
	aListCR[nPos]['COMPET']		:= TRIM((cQrySE1)->C5_XXCOMPM)

	// Falta Data e Pagamento (a ser preeenchida)
	If !Empty((cQrySE1)->E1_XXDTREC)
		aListCR[nPos]['DTREC'] 	:= (cQrySE1)->(SUBSTR(E1_XXDTREC,1,4)+"-"+SUBSTR(E1_XXDTREC,5,2)+"-"+SUBSTR(E1_XXDTREC,7,2))+" 12:00:00"  // Se não colocar 12:00 ele mostra a data anterior
	Else
		aListCR[nPos]['DTREC'] 	:= ""
	EndIf
	// Falta Banco de Pagamento (a ser preenchido)
	aListCR[nPos]['BANCO'] 		:= (cQrySE1)->E1_BCOCLI

	//aListCR[nPos]['VENC'] 		:= (cQrySE1)->(SUBSTR(E1_VENCREA,1,4)+"-"+SUBSTR(E1_VENCREA,5,2)+"-"+SUBSTR(E1_VENCREA,7,2))+" 12:00:00"  // Se não colocar 12:00 ele mostra a data anterior
	aListCR[nPos]['EMISSAO'] 	:= (cQrySE1)->(SUBSTR(E1_EMISSAO,1,4)+"-"+SUBSTR(E1_EMISSAO,5,2)+"-"+SUBSTR(E1_EMISSAO,7,2))+" 12:00:00"  // Se não colocar 12:00 ele mostra a data anterior
	aListCR[nPos]['VENCORI'] 	:= (cQrySE1)->(SUBSTR(E1_VENCORI,1,4)+"-"+SUBSTR(E1_VENCORI,5,2)+"-"+SUBSTR(E1_VENCORI,7,2))+" 12:00:00"  // Se não colocar 12:00 ele mostra a data anterior
	If !Empty((cQrySE1)->E1_BAIXA)
		aListCR[nPos]['BAIXA'] 	:= (cQrySE1)->(SUBSTR(E1_BAIXA,1,4)+"-"+SUBSTR(E1_BAIXA,5,2)+"-"+SUBSTR(E1_BAIXA,7,2))+" 12:00:00"  // Se não colocar 12:00 ele mostra a data anterior
	Else
		aListCR[nPos]['BAIXA'] 	:= ""
	EndIf
	aListCR[nPos]['VALOR']      := ALLTRIM(STR((cQrySE1)->E1_VALOR,14,2))
	aListCR[nPos]['IRRF']       := ALLTRIM(STR((cQrySE1)->E1_IRRF,14,2))
	aListCR[nPos]['INSS']       := ALLTRIM(STR((cQrySE1)->E1_INSS,14,2))
	aListCR[nPos]['PIS']        := ALLTRIM(STR((cQrySE1)->E1_PIS,14,2))
	aListCR[nPos]['COFINS']     := ALLTRIM(STR((cQrySE1)->E1_COFINS,14,2))
	aListCR[nPos]['CSLL']       := ALLTRIM(STR((cQrySE1)->E1_CSLL,14,2))
	aListCR[nPos]['ISS']        := ALLTRIM(STR(IIF((cQrySE1)->F2_RECISS = '1',(cQrySE1)->E1_ISS,0),14,2))
	aListCR[nPos]['ISSBI']      := ALLTRIM(STR((cQrySE1)->E1_VRETBIS,14,2))
	aListCR[nPos]['CVINC']      := ALLTRIM(STR((cQrySE1)->F2_XXVCVIN,14,2))
	aListCR[nPos]['RETCTR']     := ALLTRIM(STR((cQrySE1)->F2_XXVRETC,14,2))

	nLiquido := (cQrySE1)->(E1_VALOR - E1_IRRF - E1_INSS - E1_PIS - E1_COFINS - E1_CSLL - F2_XXVCVIN - F2_XXVFUMD - IIF(F2_RECISS = '1',E1_ISS,0) - E1_VRETBIS - F2_XXVRETC)
	aListCR[nPos]['LIQUIDO']	:= ALLTRIM(STR(nLiquido,14,2))
	
	//If SUBSTR((cQrySE1)->EMPRESA,1,2) <> '01'
	//	nSaldo := (cQrySE1)->E1_SALDO 
	//Else
	//	nSaldo := u_SaldoRec((cQrySE1)->E1RECNO)
	//EndIf
	nSaldo := (cQrySE1)->SALDO 

	aListCR[nPos]['SALDO'] 	    := ALLTRIM(STR(nSaldo,14,2))
	aListCR[nPos]['RETIDOS']    := ALLTRIM(STR((cQrySE1)->RETIDOS,14,2))
	aListCR[nPos]['RETENCOES']  := ALLTRIM(STR((cQrySE1)->RETENCOES,14,2))

	aListCR[nPos]['E1RECNO']	:= STRZERO((cQrySE1)->E1RECNO,7)

	aListCR[nPos]['STATUS']		:= (cQrySE1)->(E1_XXTPPRV)

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

//u_MsgLog("LISTCR-V0",cJsonCli)

Return( lRet )


// /v6
WSMETHOD GET CONSE1 QUERYPARAM empresa,e1recno,userlib WSREST RestTitCR

Local oJsonPN	:= JsonObject():New()
Local cRet		:= ""
Local cQuery	:= ""
Local cTabSE1	:= "SE1"+self:empresa+"0"
Local cTabSA1	:= "SA1"+self:empresa+"0"
Local cTabSF2	:= "SF2"+self:empresa+"0"
Local cTabSZY	:= "SZY"+self:empresa+"0"
Local cQrySE1	:= GetNextAlias()
Local cQrySZY	:= GetNextAlias()
Local aEmpresas	As Array
Local aParams	As Array
Local cMsg		As Character
Local nI 		:= 0
Local aItens 	As Array
Local nLiquido  := 0

// Chave ZY
Local cTipo		:= ""
Local cPrefixo	:= ""
Local cNum		:= ""
Local cParcela	:= ""

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
//cQuery += "	 ,E1_USERLGI"+CRLF 
cQuery += "	 ,E1_EMISSAO"+CRLF
cQuery += "	 ,E1_BAIXA"+CRLF
cQuery += "	 ,E1_BCOCLI"+CRLF
cQuery += "	 ,E1_VENCREA"+CRLF
cQuery += "	 ,E1_VENCORI"+CRLF
cQuery += "	 ,E1_VALOR"+CRLF
cQuery += "	 ,E1_XXOPER"+CRLF

cQuery += "  ,E1_IRRF"+CRLF
cQuery += "  ,E1_INSS"+CRLF
cQuery += "  ,E1_PIS"+CRLF
cQuery += "  ,E1_COFINS"+CRLF
cQuery += "  ,E1_CSLL"+CRLF
cQuery += "  ,E1_ISS"+CRLF
cQuery += "  ,E1_VRETBIS "+CRLF
cQuery += "  ,E1_XXDTREC"+CRLF
cQuery += "  ,E1_XXTPPRV"+CRLF
cQuery += "  ,CONVERT(VARCHAR(1000),CONVERT(Binary(1000),E1_XXHISTM)) E1_XXHISTM "+CRLF
cQuery += "  ,SE1.R_E_C_N_O_ AS E1RECNO"+CRLF
cQuery += "  ,F2_RECISS" + CRLF
cQuery += "  ,F2_XXVCVIN" + CRLF
cQuery += "  ,F2_XXVFUMD" + CRLF
cQuery += "  ,F2_XXVRETC" + CRLF
cQuery += "  ,E1_XXISSBI" +CRLF
cQuery += "	 ,SE1.R_E_C_N_O_ AS E1RECNO"+CRLF
cQuery += "  ,CONVERT(VARCHAR(800),CONVERT(Binary(800),E1_XXHISTM)) AS E1_XXHISTM "+CRLF
cQuery += "	 ,A1_NOME"+CRLF
cQuery += "	 ,A1_PESSOA"+CRLF
cQuery += "	 ,A1_CGC"+CRLF
cQuery += "  ,CASE WHEN E1_SALDO > 0 "+CRLF
cQuery += "	  THEN (E1_SALDO - COALESCE((SELECT SUM(E1_VALOR) "+CRLF
cQuery += "	  		FROM "+cTabSE1+ " AB "+CRLF
cQuery += "	  		WHERE AB.D_E_L_E_T_ <> '*' "+CRLF
cQuery += "	  		AND AB.E1_FILIAL 	= SE1.E1_FILIAL "+CRLF
cQuery += "	  		AND AB.E1_PREFIXO 	= SE1.E1_PREFIXO "+CRLF
cQuery += "	  		AND AB.E1_NUM 		= SE1.E1_NUM "+CRLF
cQuery += "	  		AND AB.E1_TITPAI 	= SE1.E1_PREFIXO+SE1.E1_NUM+SE1.E1_PARCELA+SE1.E1_TIPO+SE1.E1_CLIENTE+SE1.E1_LOJA "+CRLF
cQuery += "	  		AND AB.E1_TIPO IN ('AB-','FB-','FC-','FU-','FP-','FM-','IR-','IN-','IS-','PI-','CF-','CS-','FE-','IV-') "+CRLF  // +FormatIN(MVABATIM,'|') --
cQuery += "	  	),0) "+CRLF
cQuery += "	  	- E1_SDDECRE + E1_SDACRES) "+CRLF
cQuery += "	  	- CASE WHEN E1_BAIXA = ' ' THEN (E1_XXVRETC + E1_XXVCVIN) ELSE 0 END"+CRLF
cQuery += "	  ELSE 0 END  AS SALDO "+CRLF

cQuery += "	 FROM "+cTabSE1+" SE1 "+CRLF

cQuery += "	 LEFT JOIN "+cTabSF2+" SF2 ON"+CRLF
cQuery += "	 	SE1.E1_FILIAL      = SF2.F2_FILIAL"+CRLF
cQuery += "	 	AND SE1.E1_NUM     = SF2.F2_DOC "+CRLF
cQuery += "	 	AND SE1.E1_PREFIXO = SF2.F2_SERIE"+CRLF
cQuery += "	 	AND SE1.E1_CLIENTE = SF2.F2_CLIENTE"+CRLF
cQuery += "	 	AND SE1.E1_LOJA    = SF2.F2_LOJA"+CRLF
cQuery += "	 	AND SE1.D_E_L_E_T_ = ''"+CRLF

cQuery += "	 LEFT JOIN "+cTabSA1+" SA1 ON"+CRLF
cQuery += "	 	SA1.A1_FILIAL      = '  '"+CRLF
cQuery += "	 	AND SE1.E1_CLIENTE = SA1.A1_COD"+CRLF
cQuery += "	 	AND SE1.E1_LOJA    = SA1.A1_LOJA"+CRLF
cQuery += "	 	AND SA1.D_E_L_E_T_ = ''"+CRLF

cQuery += "WHERE SE1.R_E_C_N_O_ = "+self:e1recno + CRLF

u_LogMemo("RESTTITCR-E1.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySE1,.T.,.T.)

dbSelectArea(cQrySE1)
dbGoTop()
cTipo		:= (cQrySE1)->E1_TIPO
cPrefixo	:= (cQrySE1)->E1_PREFIXO
cNum		:= (cQrySE1)->E1_NUM
cParcela	:= (cQrySE1)->E1_PARCELA

oJsonPN['USERNAME']		:= cUserName
oJsonPN['EMPRESA']		:= aEmpresas[aScan(aEmpresas,{|x| x[1] == self:empresa }),2]
oJsonPN['E1_PREFIXO']	:= (cQrySE1)->E1_PREFIXO
oJsonPN['E1_NUM']		:= (cQrySE1)->E1_NUM
oJsonPN['A1_NOME']		:= (cQrySE1)->A1_NOME
oJsonPN['E1_EMISSAO']	:= DTOC(STOD((cQrySE1)->E1_EMISSAO))
oJsonPN['E1_VENCREA']	:= DTOC(STOD((cQrySE1)->E1_VENCREA))
oJsonPN['E1_XXOPER']	:= UsrRetName((cQrySE1)->E1_XXOPER)
oJsonPN['E1_PEDIDO']	:= (cQrySE1)->E1_PEDIDO
oJsonPN['E1_XXHISTM']	:= (cQrySE1)->E1_XXHISTM
oJsonPN['E1_VENCORI']	:= DTOC(STOD((cQrySE1)->E1_VENCORI))

oJsonPN['E1_BAIXA'] 	:= DTOC(STOD((cQrySE1)->E1_BAIXA))
oJsonPN['VALOR']        := TRANSFORM((cQrySE1)->E1_VALOR,"@E 999,999,999.99")
oJsonPN['IRRF']         := TRANSFORM((cQrySE1)->E1_IRRF,"@E 999,999,999.99")
oJsonPN['INSS']         := TRANSFORM((cQrySE1)->E1_INSS,"@E 999,999,999.99")
oJsonPN['PIS']          := TRANSFORM((cQrySE1)->E1_PIS,"@E 999,999,999.99")
oJsonPN['COFINS']       := TRANSFORM((cQrySE1)->E1_COFINS,"@E 999,999,999.99")
oJsonPN['CSLL']         := TRANSFORM((cQrySE1)->E1_CSLL,"@E 999,999,999.99")
oJsonPN['ISS']          := TRANSFORM(IIF((cQrySE1)->F2_RECISS = '1',(cQrySE1)->E1_ISS,0),"@E 999,999,999.99")
oJsonPN['ISSBI']        := TRANSFORM((cQrySE1)->E1_VRETBIS,"@E 999,999,999.99")
oJsonPN['CVINC']        := TRANSFORM((cQrySE1)->F2_XXVCVIN,"@E 999,999,999.99")
oJsonPN['RETCTR']       := TRANSFORM((cQrySE1)->F2_XXVRETC,"@E 999,999,999.99")

nLiquido := (cQrySE1)->(E1_VALOR - E1_IRRF - E1_INSS - E1_PIS - E1_COFINS - E1_CSLL - F2_XXVCVIN - F2_XXVFUMD - IIF(F2_RECISS = '1',E1_ISS,0) - E1_VRETBIS - F2_XXVRETC)
oJsonPN['LIQUIDO'] 		:= TRANSFORM(nLiquido,"@E 999,999,999.99")

nSaldo := (cQrySE1)->SALDO
oJsonPN['SALDO']        := TRANSFORM(nSaldo,"@E 999,999,999.99")

u_MsgLog("RESTTITCR",DTOC(STOD((cQrySE1)->E1_VENCORI)))

(cQrySE1)->(dbCloseArea())

cQuery := "SELECT " + CRLF
cQuery += "	  ZY_DATA"+CRLF
cQuery += "	 ,ZY_HORA"+CRLF
cQuery += "	 ,ZY_BANCO"+CRLF
cQuery += "	 ,ZY_OPER"+CRLF
cQuery += "	 ,ZY_DTREC"+CRLF
cQuery += "  ,CONVERT(VARCHAR(800),CONVERT(Binary(800),ZY_OBS)) AS ZY_OBS "+CRLF
cQuery += "	 ,USR_CODIGO"+CRLF

cQuery += " FROM "+cTabSZY+" SZY" + CRLF

cQuery += " LEFT JOIN SYS_USR USR ON ZY_OPER  = USR.USR_ID AND USR.D_E_L_E_T_ = ''" + CRLF

cQuery += " WHERE ZY_FILIAL = '"+xFilial("SZY")+"' " + CRLF
cQuery += " 	AND SZY.ZY_TIPO = '"+cTipo+"' " + CRLF
cQuery += " 	AND SZY.ZY_NUM = '"+cNum+"' " + CRLF
cQuery += " 	AND SZY.ZY_PREFIXO  = '"+cPrefixo+"' " + CRLF
cQuery += " 	AND SZY.ZY_PARCELA  = '"+cParcela+"' " + CRLF
cQuery += " 	AND SZY.D_E_L_E_T_ = ' '" + CRLF
cQuery += " ORDER BY ZY_DATA DESC,ZY_HORA DESC" + CRLF

//u_MsgLog(,"Aqui3")

u_LogMemo("RESTTITCR-E1.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQrySZY,.T.,.T.)

dbSelectArea(cQrySZY)
dbGoTop()

aItens := {}
nI := 0

Do While (cQrySZY)->(!EOF())
	aAdd(aItens,JsonObject():New())
	nI++

	aItens[nI]["ZY_DATA"]	:= DTOC(STOD((cQrySZY)->ZY_DATA))
	aItens[nI]["ZY_HORA"]	:= (cQrySZY)->ZY_HORA
	aItens[nI]["ZY_BANCO"]	:= (cQrySZY)->ZY_BANCO
	aItens[nI]["ZY_OPER"]	:= (cQrySZY)->USR_CODIGO
	aItens[nI]["ZY_DTREC"]	:= DTOC(STOD((cQrySZY)->ZY_DTREC))
	aItens[nI]["ZY_OBS"]	:= StrIConv(TRIM((cQrySZY)->ZY_OBS), "CP1252", "UTF-8")

	dbSkip()
EndDo

oJsonPN['DADOSZY']	:= aItens

cRet := oJsonPN:ToJson()

FreeObj(oJsonPN)

//Retorno do servico
Self:SetHeader("Access-Control-Allow-Origin", "*")
Self:SetResponse(cRet)

return .T.


// /v2
WSMETHOD GET BROWCR QUERYPARAM empresa,vencini,vencfim,userlib WSREST RestTitCR
Local aParams	As Array
Local cMsg		As Character
Local xEmpr		As Character
Local cHTML		As Character
Local cDropEmp	As Character
Local aEmpresas As Array
Local nE 		:= 0

u_BkAvPar(self:userlib,@aParams,@cMsg,@xEmpr)
aEmpresas := u_BKGrupo(5,xEmpr)

BEGINCONTENT var cHTML

<!doctype html>
<html lang="pt-BR">
<head>
<!-- Required meta tags -->
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"> 
<meta http-equiv="Content-Language" content="pt-BR"> <!-- Força o idioma -->

<!-- <meta http-equiv="Content-Type" content="text/html; charset=utf-8"> -->

<meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Styling CSS -->
#BKDTStyle#
 
<title>Títulos Contas a Receber #dataI# a #dataF# #NomeEmpresa#</title>

<!-- Favicon -->
#BKFavIco#

<style type="text/css">

html *
{
   font-size: 12px;
}

.bk-colors{
 background-color: #9E0000;
 color: white;
}
.bg-mynav {
  background-color: #9E0000;
  padding-left:5px;
  padding-right:5px;
  font-size: 1.2rem;
}
.font-condensed{
  font-size: 0.8em;
}
body {
	background-color: #f6f8fa;
}

table.dataTable td {
  font-size: 1em;
}

td {
line-height: 1rem;
	vertical-align: middle;
	}

table.dataTable.table-sm>thead>tr th.dt-orderable-asc,table.dataTable.table-sm>thead>tr th.dt-orderable-desc,table.dataTable.table-sm>thead>tr th.dt-ordering-asc,table.dataTable.table-sm>thead>tr th.dt-ordering-desc,table.dataTable.table-sm>thead>tr td.dt-orderable-asc,table.dataTable.table-sm>thead>tr td.dt-orderable-desc,table.dataTable.table-sm>thead>tr td.dt-ordering-asc,table.dataTable.table-sm>thead>tr td.dt-ordering-desc {
    padding-right: 3px;
}

thead input::placeholder {
    font-weight: bold !important;
    color: #6c757d !important;
    font-style: italic;
    letter-spacing: 0.5px;
    font-size: 0.8rem !important; /* Tamanho reduzido */
    opacity: 1 !important; /* Garante visibilidade total */
}
/* Borda destacada para os inputs do cabeçalho */
thead input {
    border: 2px solid #9E0000 !important; /* Cor do seu header (.bk-colors) */
    border-radius: 4px !important; /* Cantos arredondados */
    padding: 4px !important; /* Espaçamento interno */
    box-shadow: 0 0 2px rgba(158, 0, 0, 0.3) !important; /* Sombra sutil (opcional) */
}

/* Efeito hover para os inputs do cabeçalho */
thead input:hover {
    background-color: #FFF2F2 !important; /* Vermelho claro de fundo */
    border-color: #9E0000 !important; /* Borda vermelha mais intensa */
    transition: all 0.3s ease; /* Suaviza a transição */
}

/* Opcional: Efeito ao focar (quando clicado) */
thead input:focus {
    background-color: #FFE5E5 !important;
    box-shadow: 0 0 0 2px rgba(158, 0, 0, 0.2) !important;
}
</style>
</head>
<body>

	
<div id="conteudo-principal">
<nav class="navbar navbar-dark bg-mynav fixed-top justify-content-between">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Títulos a Receber - #cUserName#</a> 

	<div class="btn-group">
		<button type="button" id="btn-empresa" class="btn btn-dark dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">
			#NomeEmpresa#
		</button>
		<ul class="dropdown-menu dropdown-menu-dark">
			#DropEmpresas#
		</ul>
	</div>

	<div class="btn-group">
		<button type="button" id="btn-excel" class="btn btn-dark" aria-label="Excel" onclick="Excel()">Excel</button>
	</div>

    <form class="d-flex">
	  <label class="sr-only" for="DataI"></label>
	  <input class="form-control me-2" type="date" id="DataI" value="#dataI#" />
	  <label class="sr-only" for="DataF"></label>
	  <input class="form-control me-2" type="date" id="DataF" value="#dataF#" />
      <button type="button" class="btn btn-dark" aria-label="Atualizar" onclick="AltDatas()">Atualizar</button>
    </form>

  </div>
</nav>
<br>
<br>
<br>
<div class="container-fluid">
<div class="table-responsive-sm">
<table id="tableSE1" class="table table-sm table-hover" style="width:100%">
<thead>
<tr>
<th scope="col"></th>
<th scope="col">Empresa</th>
<th scope="col">Titulo</th>
<th scope="col">Cliente</th>
<th scope="col">Contrato</th>
<th scope="col">Compet</th>
<th scope="col">Pagamento</th>
<th scope="col">Banco</th>
<th scope="col">Emissão</th>
<th scope="col">Venc Ori.</th>
<th scope="col">Baixa</th>
<th scope="col">Valor</th>
<th scope="col">Retidos</th>
<th scope="col">Ret Ct + Vinc.</th>
<th scope="col">Liquido</th>
<th scope="col">Saldo</th>
</tr>
</thead>
<tbody id="mytable">
<tr>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col"></td>
</tr>
</tbody>
<tfoot>
  <tr>
    <th scope="col"></th>
    <th scope="col"></th>
    <th scope="col"></th>
    <th scope="col"></th>
    <th scope="col"></th>
    <th scope="col"></th>
    <th scope="col"></th>
    <th scope="col"></th>
    <th scope="col"></th>
    <th scope="col"></th>      
    <th scope="col" style="text-align:right;" width="5%" >Totais:</th>
    <th scope="col" style="text-align:right;">Valor</th>
    <th scope="col" style="text-align:right;">Retidos</th>
    <th scope="col" style="text-align:right;">Ret Ct + Vinc.</th>
    <th scope="col" style="text-align:right;">Líquido</th>
    <th scope="col" style="text-align:right;">Saldo Liq.</th>
  </tr>
</tfoot>
</table>
</div>
</div>


<!-- Modal -->
<div id="E1Modal" class="modal fade" role="dialog">
   <div class="modal-dialog modal-fullscreen">
     <!-- Conteúdo do modal-->
     <div class="modal-content">
       <!-- Cabeçalho do modal -->
       <div class="modal-header bk-colors">
         <h4 id="titE1Modal" class="modal-title">Título do modal</h4>
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
           <div class="col-md-4">
             <label for="E1NomCLI" class="form-label">Cliente</label>
             <input type="text" class="form-control form-control-sm" id="E1NomCLI" value="#E1NomCLI#" readonly="">
           </div>
           <div class="col-md-1">
             <label for="E1Emissao" class="form-label">Emissão</label>
             <input type="text" class="form-control form-control-sm text-center" id="E1Emissao" value="#E1Emissao#" readonly="">
           </div>

		   <div class="col-md-1">
             <label for="E1VencOri" class="form-label">Venc. Original</label>
             <input type="text" class="form-control form-control-sm text-center" id="E1VencOri" value="#E1VencOri#" readonly="">
           </div>

           <div class="col-md-1">
             <label for="E1VencRea" class="form-label">Vencimento</label>
             <input type="text" class="form-control form-control-sm text-center" id="E1VencRea" value="#E1VencRea#" readonly="">
           </div>

           <div class="col-md-1">
             <label for="E1Baixa" class="form-label">Baixa</label>
             <input type="text" class="form-control form-control-sm text-center" id="E1Baixa" value="#E1Baixa#" readonly="">
           </div>

           <div class="col-md-2">
             <label for="E1Oper" class="form-label">Operador</label>
             <input type="text" class="form-control form-control-sm" id="E1Oper" value="#E1Oper#" readonly="">
           </div>

           <div class="col-md-1">
             <label for="E1Pedido" class="form-label">Pedido</label>
             <input type="text" class="form-control form-control-sm" id="E1Pedido" value="#E1Pedido#" readonly="">
           </div>

           <div class="col-md-1">
             <label for="E1IRRF" class="form-label">IRRF</label>
             <input type="text" class="form-control form-control-sm text-end" id="E1IRRF" value="#E1IRRF#" readonly="">
           </div>

           <div class="col-md-1">
             <label for="E1INSS" class="form-label">INSS</label>
             <input type="text" class="form-control form-control-sm text-end" id="E1INSS" value="#E1INSS#" readonly="">
           </div>

          <div class="col-md-1">
             <label for="E1PIS" class="form-label">PIS</label>
             <input type="text" class="form-control form-control-sm text-end" id="E1PIS" value="#E1PIS#" readonly="">
          </div>

         <div class="col-md-1">
             <label for="E1COFINS" class="form-label">COFINS</label>
             <input type="text" class="form-control form-control-sm text-end" id="E1COFINS" value="#E1COFINS#" readonly="">
         </div>

         <div class="col-md-1">
             <label for="E1CSLL" class="form-label">CSLL</label>
             <input type="text" class="form-control form-control-sm text-end" id="E1CSLL" value="#E1CSLL#" readonly="">
         </div>

         <div class="col-md-1">
             <label for="E1ISS" class="form-label">ISS</label>
             <input type="text" class="form-control form-control-sm text-end" id="E1ISS" value="#E1ISS#" readonly="">
         </div>

         <div class="col-md-1">
             <label for="E1ISSBI" class="form-label">ISS BI</label>
             <input type="text" class="form-control form-control-sm text-end" id="E1ISSBI" value="#E1ISSBI#" readonly="">
         </div>

         <div class="col-md-1">
             <label for="E1CVINC" class="form-label">Vinculada</label>
             <input type="text" class="form-control form-control-sm text-end" id="E1CVINC" value="#E1CVINC#" readonly="">
         </div>

         <div class="col-md-1">
             <label for="E1RETCTR" class="form-label">Ret Ctr.</label>
             <input type="text" class="form-control form-control-sm text-end" id="E1RETCTR" value="#E1RETCTR#" readonly="">
         </div>

         <div class="col-md-1">
             <label for="E1LIQUIDO" class="form-label">Líquido</label>
             <input type="text" class="form-control form-control-sm text-end" id="E1LIQUIDO" value="#E1LIQUIDO#" readonly="">
         </div>

         <div class="col-md-1">
             <label for="E1SALDO" class="form-label">Saldo</label>
             <input type="text" class="form-control form-control-sm text-end" id="E1SALDO" value="#E1SALDO#" readonly="">
         </div>

           <div class="col-md-8">
             <label for="E1HistM" class="form-label">Histórico CR</label>
			 <textarea class="form-control form-control-sm" id="E1HistM" rows="3" value="#E1HistM#" readonly=""></textarea>
           </div>

			<div class="container">
				<div class="table-responsive-sm">
				<table class="table ">
					<thead>
						<tr>
							<th scope="col">Data</th>
							<th scope="col">Hora</th>
							<th scope="col">Banco</th>
							<th scope="col">Operador</th>
							<th scope="col">Recebimento</th>
							<th scope="col">Observações</th>
						</tr>
					</thead>
					<tbody id="E1Table">
						<tr>
							<th scope="row" colspan="6" style="text-align:center;">Carregando itens...</th>
						</tr>
					</tbody>

					<tfoot id="E1Foot">
						<th scope="row" colspan="6" style="text-align:right;"></th>
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

<div id="altStatus" class="modal" tabindex="-1">
   <div class="modal-dialog">
     <div class="modal-content">
       <div class="modal-header">
         <h5 id="AltTitulo" class="modal-title">Título:</h5>
         <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Fechar"></button>
       </div>
      <div class="modal-body">

        <label for="ZYDtRec" class="form-label">Informar Recebimento:</label>
		<input class="form-control me-2" type="date" id="ZYDtRec" value="#ZYDtRec#" />

        <label for="ZYObs" class="form-label">Histórico:</label>
	    <textarea class="form-control form-control-sm" id="ZYObs" rows="4" value="#ZYObs#"></textarea>
      </div>
       <div class="modal-footer">
         <button type="button" class="btn btn-outline-danger" data-bs-dismiss="modal">Fechar</button>
		 <div id="btnAlt"></div>
       </div>
     </div>
   </div>
</div>

<!-- JavaScript -->
#BKDTScript#

<script>

async function getCRs() {

let newvenci = document.getElementById("DataI").value;
let newvamdi = newvenci.substring(0, 4)+newvenci.substring(5, 7)+newvenci.substring(8, 10)
let newvencf = document.getElementById("DataF").value;
let newvamdf = newvencf.substring(0, 4)+newvencf.substring(5, 7)+newvencf.substring(8, 10)
let empresaTexto  = document.getElementById("btn-empresa").textContent;
const newempr = empresaTexto.split(' - ')[0]; 

let url = '#iprest#/RestTitCR/v0?empresa='+newempr+'&vencini='+newvamdi+'&vencfim='+newvamdf+'&userlib=#userlib#'
//	let url = '#iprest#/RestTitCR/v0?empresa=#empresa#&vencini=#vencini#&vencfim=#vencfim#&userlib=#userlib#'
const headers = new Headers();
headers.set('Authorization', 'Basic ' + btoa('#usrrest#' + ':' + '#pswrest#'));
headers.set("Access-Control-Allow-Origin", "*");

try {
	let res = await fetch(url,{	method: 'GET',	headers: headers});
	return await res.json();
	} catch (error) {
	console.log(error);
}

  try {
       let res = await fetch(url, {
        method: 'GET',
        headers: headers,
        mode: 'cors' // Adiciona o modo CORS explicitamente
    });
        
    if (!res.ok) {
        throw new Error(`HTTP error! status: ${res.status}`);
    }
        
    return await res.json();
} catch (error) {
    console.error('Erro na requisição:', error);
    return {
        error: true,
        message: 'Falha ao carregar dados: ' + error.message
    };
}
}

var tableSE1;

async function loadTable() {

$('#mytable').html('<tr><td colspan="16" style="text-align: center;"><div class="spinner-border text-primary" role="status"><span class="visually-hidden">Carregando...</span></div></td></tr>')

let titulos = await getCRs();
let trHTML = '';
let ccbtn = '';
let anexos = '';
let cbtne1  = '';
let nlin = 0;
let clin = '';

// Destrói a tabela se já existir (preservando o thead original)
if ($.fn.DataTable.isDataTable('#tableSE1')) {
    $('#tableSE1').DataTable().destroy();
    // Restaura o thead original (com os textos das colunas)
    $('#tableSE1 thead').html(`
	<tr>
	<th scope="col"></th>
	<th scope="col">Empresa</th>
	<th scope="col">Titulo</th>
	<th scope="col">Cliente</th>
	<th scope="col">Contrato</th>
	<th scope="col">Compet</th>
	<th scope="col">Pagamento</th>
	<th scope="col">Banco</th>
	<th scope="col">Emissão</th>
	<th scope="col">Venc Ori.</th>
	<th scope="col">Baixa</th>
	<th scope="col">Valor</th>
	<th scope="col">Retidos</th>
	<th scope="col">Ret Ct + Vinc.</th>
	<th scope="col">Liquido</th>
	<th scope="col">Saldo</th>
	</tr>
    `);
}

if (Array.isArray(titulos)) {
	titulos.forEach(object => {
	let cStatus  = object['STATUS'];
	let cEmpresa = object['EMPRESA'].substring(0,2);

	clin = nlin.toString()

	cbtne1  = 'btne1'+nlin;
	cbtnidp = 'btnpor'+nlin;

	if (cStatus == ' '){
	 ccbtn = 'dark';
	 cStatus = 'A Receber';
	} else if (cStatus == '0'){
	 ccbtn = 'danger';
	 cStatus = 'Sem Previsao';
	} else if (cStatus == '1'){
	 ccbtn = 'warning';
	 cStatus = 'Aguardando Previsao';
	} else if (cStatus == '2'){
	 ccbtn = 'primary';
	 cStatus = 'Previsao Informada';
	} else if (cStatus == '3'){
	 ccbtn = 'success';
	 cStatus = 'Recebido';
	}

	trHTML += '<tr>';
	trHTML += '<td></td>';
	trHTML += '<td>'+object['EMPRESA']+'</td>';

	trHTML += '<td>';
	trHTML += 	'<button type="button" id='+cbtne1+' class="btn btn-outline-'+ccbtn+' btn-sm" onclick="showE1(\''+cEmpresa+'\',\''+object['E1RECNO']+'\',\'#userlib#\','+'\''+cbtne1+'\')">'+object['TITULO']+'</button>';	
	trHTML += '</td>';

	trHTML += '<td id=cliente'+clin+'>'+object['CLIENTE']+'</td>';
	trHTML += '<td align="center">'+object['CONTRATO']+'</td>';	
	//trHTML += '<td>'+object['DESCCC']+'</td>';	
	trHTML += '<td align="center">'+object['COMPET']+'</td>';

	trHTML += '<td id=dtrec'+clin+' align="center">'+object['DTREC']+'</td>';

	// Botão para mudança de Banco

	trHTML += '<td>'
	trHTML += '<div class="btn-group">'
	trHTML += '<button type="button" title="Portador" id="'+cbtnidp+'" class="btn btn-dark dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">'
	trHTML += object['BANCO']
	trHTML += '</button>'

	trHTML += '<div class="dropdown-menu dropdown-menu-dark" aria-labelledby="dropdownMenu2">'
	trHTML += '<button class="dropdown-item" type="button" onclick="AltStatus(\''+cEmpresa+'\',\''+object['E1RECNO']+'\',\'#userlib#\',\'341\','+'\''+cbtnidp+'\','+'\''+clin+'\')">341-Itau</button>';
	trHTML += '<button class="dropdown-item" type="button" onclick="AltStatus(\''+cEmpresa+'\',\''+object['E1RECNO']+'\',\'#userlib#\',\'001\','+'\''+cbtnidp+'\','+'\''+clin+'\')">001-BB</button>';
	trHTML += '<button class="dropdown-item" type="button" onclick="AltStatus(\''+cEmpresa+'\',\''+object['E1RECNO']+'\',\'#userlib#\',\'104\','+'\''+cbtnidp+'\','+'\''+clin+'\')">104-CEF</button>';
	trHTML += '<button class="dropdown-item" type="button" onclick="AltStatus(\''+cEmpresa+'\',\''+object['E1RECNO']+'\',\'#userlib#\',\'   \','+'\''+cbtnidp+'\','+'\''+clin+'\')">Remover</button>';
	trHTML += '</div>'
	trHTML += '</td>'

	trHTML += '<td align="center">'+object['EMISSAO']+'</td>';
	trHTML += '<td align="center">'+object['VENCORI']+'</td>';
	trHTML += '<td align="center">'+object['BAIXA']+'</td>';

	trHTML += '<td align="right">'+object['VALOR']+'</td>';

	//trHTML += '<td align="right">'+object['IRRF']+'</td>';
	//trHTML += '<td align="right">'+object['INSS']+'</td>';
	//trHTML += '<td align="right">'+object['PIS']+'</td>';
	//trHTML += '<td align="right">'+object['COFINS']+'</td>';
	//trHTML += '<td align="right">'+object['CSLL']+'</td>';
	//trHTML += '<td align="right">'+object['ISS']+'</td>';
	//trHTML += '<td align="right">'+object['ISSBI']+'</td>';
	//trHTML += '<td align="right">'+object['CVINC']+'</td>';
	//trHTML += '<td align="right">'+object['RETCTR']+'</td>';

	trHTML += '<td align="right">'+object['RETIDOS']+'</td>';
	trHTML += '<td align="right">'+object['RETENCOES']+'</td>';
	trHTML += '<td align="right">'+object['LIQUIDO']+'</td>';
	trHTML += '<td align="right">'+object['SALDO']+'</td>';

	trHTML += '</tr>';

	nlin += 1;

	});
} else {
    //trHTML += '<tr>';
    //trHTML += ' <th scope="row" colspan="16" style="text-align:center;">'+titulos['liberacao']+'</th>';
    //trHTML += '</tr>';   
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="16" style="text-align:center;">Faça login novamente no sistema Protheus</th>';
    trHTML += '</tr>';   
}
document.getElementById("mytable").innerHTML = trHTML;


tableSE1 = $('#tableSE1').DataTable({
  "retrieve": true,
  "pageLength": 25,
  "processing": true,
  "scrollX": true,
  "scrollCollapse": true,
  "scrollY": "calc(100vh - 220px)",
  "language": {
	"lengthMenu": "Registros por página: _MENU_ ",
	"zeroRecords": "Nada encontrado",
	"emptyTable": "Nenhum registro disponível na tabela",
	"info": "Página _PAGE_ de _PAGES_",
	"infoEmpty": "Nenhum registro disponível",
	"infoFiltered": "(filtrado de _MAX_ registros no total)",
	"search": "Filtrar:",
	"processing": "Processando...",
	"loadingRecords": "Processando...",
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
        { data: 'Cliente' },
        { data: 'Contrato' },		
        { data: 'Compet' },
        { data: 'Pagamento' },
        { data: 'Banco' },
        { data: 'Emissao' },
        { data: 'VencOri' },
        { data: 'Baixa' },
        { data: 'Valor' },
        { data: 'Retidos' },
        { data: 'Retencoes' },
        { data: 'Liquido' },
        { data: 'Saldo' }
  ],
  "order": [[1,'asc']],

	initComplete: function () {
        this.api().columns().every(function () {
                var column = this;
                var title = column.header().textContent;
 
                // Create input element and add event listener
                //('<input class="form-control form-control-sm" style="width:100%;min-width:70px;" type="text" placeholder="' + 
				$('<input type="text" placeholder="' + title + '" class="form-control form-control-sm" />')
				    .appendTo($(column.header()).empty())
                    .on('keyup change clear', function () {
                        if (column.search() !== this.value) {
                            column.search(this.value).draw();
                        }
                    });
            });
    },
	footerCallback: function (row, data, start, end, display) {
       var api = this.api();
       // Remove the formatting to get integer data for summation
       var intVal = function (i) {
           var x = i;
           var y = 0;
           if (typeof x === 'string') {
             //x = x.replaceAll(' ', '');
             //x = x.replaceAll('.', '');
             //x = x.replace(',', '.');
             y = parseFloat(x)
           };
           if (typeof i === 'number'){
               y = i;
           };
           return y;
       };
       // Total filtrado
       total = api
           .column(11, {filter: 'applied'})
           .data()
           .reduce(function (a, b) {
               return intVal(a) + intVal(b);
           }, 0);
 
       // Update footer
       $(api.column(11).footer()).html(
           total.toLocaleString('pt-br', {minimumFractionDigits: 2})
       );

       // Total filtrado
       total = api
           .column(12, {filter: 'applied'})
           .data()
           .reduce(function (a, b) {
               return intVal(a) + intVal(b);
           }, 0);
 
       // Update footer
       $(api.column(12).footer()).html(
           total.toLocaleString('pt-br', {minimumFractionDigits: 2})
       );

       // Total filtrado
       total = api
           .column(13, {filter: 'applied'})
           .data()
           .reduce(function (a, b) {
               return intVal(a) + intVal(b);
           }, 0);
 
       // Update footer
       $(api.column(13).footer()).html(
           total.toLocaleString('pt-br', {minimumFractionDigits: 2})
       );

       // Total filtrado
       total = api
           .column(14, {filter: 'applied'})
           .data()
           .reduce(function (a, b) {
               return intVal(a) + intVal(b);
           }, 0);
 
       // Update footer
       $(api.column(14).footer()).html(
           total.toLocaleString('pt-br', {minimumFractionDigits: 2})
       );

       // Total filtrado
       total = api
           .column(15, {filter: 'applied'})
           .data()
           .reduce(function (a, b) {
               return intVal(a) + intVal(b);
           }, 0);
 
       // Update footer
       $(api.column(15).footer()).html(
           total.toLocaleString('pt-br', {minimumFractionDigits: 2})
       );
    },
	columnDefs: [
		{
			targets: [5,7],
			className: 'text-center',
    	},
		{
			targets: [11,12,13,14,15],
			className: 'text-right',
			render: DataTable.render.number('.', ',', 2) // Formato: 1.000,50
    	},
		{
            targets: [6,8,9,10], render: DataTable.render.datetime('DD/MM/YYYY')
        }
    ]

 });

}

// Formatting function for row details - modify as you need
function format(d) {
	var anexos = '';
    // `d` is the original data object for the row
	
    return (
        '<dl>' +
        '<dt>Contrato:&nbsp;&nbsp;'+d.Contrato+'</dt>' +
	    '<dt>Vencimento Original:&nbsp;&nbsp;'+d.VencOri+'</dt>' +
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

const headers = new Headers();
headers.set('Authorization', 'Basic ' + btoa('#usrrest#' + ':' + '#pswrest#'));

let urlE1 = '#iprest#/RestTitCR/v6?empresa='+empresa+'&e1recno='+e1recno+'&userlib='+userlib;
	try {
	let res = await fetch(urlE1,{method: 'GET',	headers: headers});
		return await res.json();
		} catch (error) {
	console.log(error);
		}
	}


async function showE1(empresa,e1recno,userlib,cbtne1) {

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
document.getElementById('E1VencOri').value = dadosE1['E1_VENCORI'];
document.getElementById('E1Baixa').value = dadosE1['E1_BAIXA'];
document.getElementById('E1Oper').value = dadosE1['E1_XXOPER'];
document.getElementById('E1HistM').value = dadosE1['E1_XXHISTM'];
document.getElementById('E1Pedido').value = dadosE1['E1_PEDIDO'];

document.getElementById('E1IRRF').value = dadosE1['IRRF'];
document.getElementById('E1INSS').value = dadosE1['INSS'];
document.getElementById('E1PIS').value = dadosE1['PIS'];
document.getElementById('E1COFINS').value = dadosE1['COFINS'];
document.getElementById('E1CSLL').value = dadosE1['CSLL'];
document.getElementById('E1ISS').value = dadosE1['ISS'];
document.getElementById('E1ISSBI').value = dadosE1['ISSBI'];
document.getElementById('E1CVINC').value = dadosE1['CVINC'];
document.getElementById('E1RETCTR').value = dadosE1['RETCTR'];
document.getElementById('E1LIQUIDO').value = dadosE1['LIQUIDO'];
document.getElementById('E1SALDO').value = dadosE1['SALDO'];

if (Array.isArray(dadosE1.DADOSZY)) {
   dadosE1.DADOSZY.forEach(object => {
    i++
	itens += '<tr>';
	itens += '<td>'+object['ZY_DATA']+'</td>';	
	itens += '<td>'+object['ZY_HORA']+'</td>';
	itens += '<td>'+object['ZY_BANCO']+'</td>';
	itens += '<td>'+object['ZY_OPER']+'</td>';
	itens += '<td>'+object['ZY_DTREC']+'</td>';
	itens += '<td>'+object['ZY_OBS']+'</td>';

	itens += '</tr>';

  })
}

document.getElementById("E1Table").innerHTML = itens;

$("#titE1Modal").text('Título do Contas a Receber - Empresa: '+dadosE1['EMPRESA'] + ' - Usuário: '+dadosE1['USERNAME']);
$('#E1Modal').modal('show');
//$('#E1Modal').on('hidden.bs.modal', function () {
//	location.reload();
//	})
}


async function AltStatus(empresa,e1recno,userlib,banco,btnids,clin){
let btnAlt = '<button type="button" class="btn btn-outline-success" onclick="ChgStatus(\''+empresa+'\',\''+e1recno+'\',\'#userlib#\',\''+banco+'\','+'\''+btnids+'\','+'\''+clin+'\')">Salvar</button>';
document.getElementById("btnAlt").innerHTML = btnAlt;
document.getElementById("AltTitulo").textContent = "Título "+document.getElementById("btne1"+clin).textContent + ' - '+document.getElementById("cliente"+clin).textContent;
//document.getElementById("AltTitulo").textContent = ' - '+document.getElementById("cliente"+clin).textContent;
document.getElementById("ZYObs").value = '';
if (banco.trim() === '') {
    document.getElementById("ZYDtRec").value = '';
}
$('#altStatus').modal('show');
}


async function ChgStatus(empresa,e1recno,userlib,banco,btnids,clin){
let resposta = '';
let ZYDtRec = document.getElementById("ZYDtRec").value;
let ZYObs  = document.getElementById("ZYObs").value;

let dataObject = {	liberacao:'ok',
					zyDtRec:ZYDtRec,
					zyobs:ZYObs,
				 };

let nlin = parseInt(clin,10);

$('#altStatus').modal('hide');

try {
	// Faz a requisição com autenticação básica

    const username = '#usrrest#';
    const password = '#pswrest#';
    const iprest = '#iprest#';
    const userlib = '#userlib#';

    // Codifica as credenciais em Base64
    const credentials = btoa(`${username}:${password}`);

    // Monta a URL da API
    const url = `${iprest}/RestTitCR/v3?empresa=${empresa}&e1recno=${e1recno}&userlib=${userlib}&banco=${banco}`;

	const response = await fetch(url, {
		method: 'PUT',
		headers: {
			'Authorization': `Basic ${credentials}`,
			'Content-Type': 'application/json', // Adiciona o tipo de conteúdo, se necessário
		},
		body: JSON.stringify(dataObject)});

    // Verifica se a resposta é válida
	if (!response.ok) {
		let errorDetails = "Erro desconhecido";
		try {
			// Tenta obter detalhes do erro da resposta (se for JSON)
			const errorResponse = await response.json();
				errorDetails = JSON.stringify(errorResponse);
			} catch (e) {
				// Se a resposta não for JSON, usa o texto da resposta
				errorDetails = await response.text();
			}
			throw new Error(`Erro ao baixar o arquivo: ${response.statusText}. Detalhes: ${errorDetails}`);
	}
} catch (error) {
    console.error("Erro durante a alteração de estatus:", error);
    alert(`Ocorreu um erro ao alterar o status: ${error.message}`);
} finally {
    // this is the data we get after putting our data,
	//	console.log(data);
	document.getElementById(btnids).textContent = banco;
	if (banco.trim() === '') {
    	document.getElementById('dtrec'+clin).textContent = '';
	} else {
		document.getElementById('dtrec'+clin).textContent = ZYDtRec.substring(8,10)+'/'+ZYDtRec.substring(5,7)+'/'+ZYDtRec.substring(0,4)
	}
	//document.getElementById('prev'+clin).value = ZYDtRec.value
	//document.getElementById('oper'+clin).textContent = '#cUserName#';
	//document.getElementById('hist'+clin).textContent = ZYObs;
}
}

async function ChgBanco(empresa,e1recno,userlib,banco,btnidp){
let resposta = ''
let dataObject = {	liberacao:'ok' };
let cbtn = '';
const username = '#usrrest#';
const password = '#pswrest#';

// Codifica as credenciais em Base64
const credentials = btoa(`${username}:${password}`);

fetch('#iprest#/RestTitCR/v4?empresa='+empresa+'&e1recno='+e1recno+'&userlib='+userlib+'&banco='+banco, {
	method: 'PUT',
	headers: {
		'Authorization': `Basic ${credentials}`,
		'Content-Type': 'application/json', // Adiciona o tipo de conteúdo, se necessário
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


async function Excel() {
    const btnExcel = document.getElementById("btn-excel");
    const cbtnh = btnExcel.innerHTML; // Salva o conteúdo original do botão

    try {
        // Desabilita o botão e exibe o spinner
        btnExcel.disabled = true;
        btnExcel.innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span> Processando...';

        // Obtém os valores dos campos de data e empresa
        let newvenci = document.getElementById("DataI").value;
        let newvamdi = newvenci.substring(0, 4) + newvenci.substring(5, 7) + newvenci.substring(8, 10);
        let newvencf = document.getElementById("DataF").value;
        let newvamdf = newvencf.substring(0, 4) + newvencf.substring(5, 7) + newvencf.substring(8, 10);
        let newempr = document.getElementById("btn-empresa").textContent;

        // Substitua os placeholders pelos valores reais
        const username = '#usrrest#'; // Substitua pelo valor real
        const password = '#pswrest#'; // Substitua pelo valor real
        const iprest = '#iprest#'; // Substitua pelo valor real
        const userlib = '#userlib#'; // Substitua pelo valor real

        // Codifica as credenciais em Base64
        const credentials = btoa(`${username}:${password}`);

        // Monta a URL da API
        const url = `${iprest}/RestTitCR/v5?empresa=${newempr}&vencini=${newvamdi}&vencfim=${newvamdf}&userlib=${userlib}`;

        // Faz a requisição com autenticação básica
        const response = await fetch(url, {
            method: 'GET',
            headers: {
                'Authorization': `Basic ${credentials}`,
                'Content-Type': 'application/json', // Adiciona o tipo de conteúdo, se necessário
            },
        });

        // Verifica se a resposta é válida
        if (!response.ok) {
            let errorDetails = "Erro desconhecido";
            try {
                // Tenta obter detalhes do erro da resposta (se for JSON)
                const errorResponse = await response.json();
                errorDetails = JSON.stringify(errorResponse);
            } catch (e) {
                // Se a resposta não for JSON, usa o texto da resposta
                errorDetails = await response.text();
            }
            throw new Error(`Erro ao baixar o arquivo: ${response.statusText}. Detalhes: ${errorDetails}`);
        }

        // Obtém o blob (arquivo) da resposta
        const blob = await response.blob();

        // Cria um link para download do arquivo
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = `Contas_a_receber_${newempr}_${newvamdi}_${newvamdf}.xlsx`; // Nome do arquivo personalizado
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    } catch (error) {
        console.error("Erro durante a execução da função Excel:", error);
        alert(`Ocorreu um erro ao tentar baixar o arquivo: ${error.message}`);
    } finally {
        // Restaura o botão ao estado original
        btnExcel.disabled = false;
        btnExcel.innerHTML = cbtnh;
    }
}


async function AltDatas(){
let newempr  = document.getElementById("btn-empresa").textContent;
AltEmpr(newempr)
}

async function AltEmpr(empresaTexto) {
    try {
		document.getElementById("btn-empresa").textContent = empresaTexto;
        // Atualizar a tabela com os novos dados
        await loadTable();
        
    } catch (error) {
        console.error("Erro ao atualizar:", error);
        $('#mytable').html('<tr><td colspan="16" style="text-align: center; color: red;">Erro ao carregar dados</td></tr>');
    }
}

</script>

</div>

</body>
</html>
ENDCONTENT

cHtml := STRTRAN(cHtml,"#iprest#"	 ,u_BkRest())
cHtml := STRTRAN(cHtml,"#usrrest#"	 ,u_BkUsrRest())
cHtml := STRTRAN(cHtml,"#pswrest#"	 ,u_BkPswRest())
//cHtml := STRTRAN(cHtml,"#usrpass#"	 ,Encode64(u_BkUsrRest()+":"+u_BkPswRest()))


cHtml := STRTRAN(cHtml,"#BKDTStyle#" ,u_BKDTStyle())
cHtml := STRTRAN(cHtml,"#BKDTScript#",u_BKDTScript())
cHtml := STRTRAN(cHtml,"#BKFavIco#"  ,u_BkFavIco())

If !Empty(::userlib)
	cHtml := STRTRAN(cHtml,"#userlib#",::userlib)
	cHtml := STRTRAN(cHtml,"#cUserName#",cUserName)  
EndIf

//cHtml := STRTRAN(cHtml,"#empresa#",::empresa)
cHtml := STRTRAN(cHtml,"#vencini#",::vencini)
cHtml := STRTRAN(cHtml,"#vencfim#",::vencfim)
cHtml := STRTRAN(cHtml,"#dataI#",SUBSTR(::vencini,1,4)+"-"+SUBSTR(::vencini,5,2)+"-"+SUBSTR(::vencini,7,2))   // Formato: 2023-10-24 input date
cHtml := STRTRAN(cHtml,"#dataF#",SUBSTR(::vencfim,1,4)+"-"+SUBSTR(::vencfim,5,2)+"-"+SUBSTR(::vencfim,7,2))   // Formato: 2023-10-24 input date
cHtml := STRTRAN(cHtml,"#ZYDtRec#",STR(YEAR(DATE()),4)+"-"+STRZERO(MONTH(DATE()),2)+"-"+STRZERO(DAY(DATE()),2))   // Formato: 2023-10-24 input date

// --> Seleção de Empresas
nE := aScan(aEmpresas,{|x| x[1] == SUBSTR(self:empresa,1,2) })
If nE > 0
	cHtml := STRTRAN(cHtml,"#NomeEmpresa#",aEmpresas[nE,1]+'-'+aEmpresas[nE,2])
Else
	cHtml := STRTRAN(cHtml,"#NomeEmpresa#","Todas "+self:empresa)
EndIf

cDropEmp := ""
For nE := 1 To Len(aEmpresas)
	//cDropEmp += '<li><a class="dropdown-item" href="'+u_BkRest()+'/RestTitCR/v2?empresa='+aEmpresas[nE,1]+'&vencini='+self:vencini+'&vencfim='+self:vencfim+'&userlib='+self:userlib+'">'+aEmpresas[nE,1]+'-'+aEmpresas[nE,2]+'</a></li>'+CRLF
	cDropEmp += '<li><a class="dropdown-item" href="javascript:AltEmpr('+"'"+aEmpresas[nE,1]+'-'+aEmpresas[nE,2]+"'"+')">'+aEmpresas[nE,1]+'-'+aEmpresas[nE,2]+'</a></li>'+CRLF
Next
cDropEmp +='<li><hr class="dropdown-divider"></li>'+CRLF
cDropEmp +='<li><a class="dropdown-item" href="javascript:AltEmpr('+'Todas'+')">Todas</a></li>'+CRLF

cHtml := STRTRAN(cHtml,"#DropEmpresas#",cDropEmp)
// <-- Seleção de Empresas

//cHtml := EncodeUtf8(cHtml)

cHtml := StrIConv( cHtml, "CP1252", "UTF-8")

// Caracteres iniciais de um arquivo UTF-8
cHtml := u_BKUtf8() + cHtml
//cHtml := DecodeUtf8(cHtml)

//u_MsgLog(,"BROWCR/2")

//If ::userlib == '000000'
//	Memowrite(u_STmpDir()+"cr.html",cHtml)
//EndIf

//u_MsgLog("RESTTITCR",__cUserId)

Self:SetHeader("Access-Control-Allow-Origin", "*")
Self:SetHeader("Accept", "UTF-8")

self:setResponse(cHTML)
self:setStatus(200)


//; charset=iso-8859-1
return .T.


// Montagem da Query
Static Function TmpQuery(cQrySE1,xEmpresa,xVencIni,xVencFim)

Local aEmpresas		:= {}
Local aGrupoBK 		:= {}
Local cEmpresa		:= ""
Local cNomeEmp		:= ""
Local cTabSE1		:= ""
Local cTabSF2		:= ""
Local cTabSC5		:= ""
Local cTabSA1		:= ""
Local cTabCTT		:= ""
Local cTabSE5		:= ""
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

u_MsgLog("TmpQuery",xEmpresa+"-"+cValToChar(aEmpresas))
//cQuery := "WITH RESUMO AS ( " + CRLF

For nE := 1 To Len(aEmpresas)
	cEmpr 	:= aEmpresas[nE,1]
	cTabSE1 := "SE1"+cEmpr+"0"
	cTabSA1 := "SA1"+cEmpr+"0"
	cTabSF2 := "SF2"+cEmpr+"0"
	cTabSC5 := "SC5"+cEmpr+"0"
	cTabCTT := "CTT"+cEmpr+"0"
	cTabSE5 := "SE5"+cEmpr+"0"

	cEmpresa := cEmpr
	cNomeEmp := aEmpresas[nE,3]

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += "SELECT DISTINCT "+CRLF
	cQuery += "	  '"+cEmpresa+"-"+cNomeEmp+"' AS EMPRESA"+CRLF
	cQuery += ",A1_NOME"+CRLF
	cQuery += ",A1_CGC"+CRLF
	cQuery += ",A1_PESSOA"+CRLF
	cQuery += ",E1_BCOCLI"+CRLF
	cQuery += ",E1_VENCREA"+CRLF
	cQuery += ",E1_VENCORI"+CRLF
	cQuery += ",E1_BAIXA"+CRLF
	cQuery += ",E1_VALOR"+CRLF
	cQuery += ",E1_SALDO" + CRLF

	cQuery += ",CASE WHEN E1_SALDO > 0 "+CRLF
	cQuery += "	THEN (E1_SALDO - COALESCE((SELECT SUM(E1_VALOR) "+CRLF
	cQuery += "			FROM "+cTabSE1+ " AB "+CRLF
	cQuery += "			WHERE AB.D_E_L_E_T_ <> '*' "+CRLF
	cQuery += "			AND AB.E1_FILIAL 	= SE1.E1_FILIAL "+CRLF
	cQuery += "			AND AB.E1_PREFIXO 	= SE1.E1_PREFIXO "+CRLF
	cQuery += "			AND AB.E1_NUM 		= SE1.E1_NUM "+CRLF
	cQuery += "			AND AB.E1_TITPAI 	= SE1.E1_PREFIXO+SE1.E1_NUM+SE1.E1_PARCELA+SE1.E1_TIPO+SE1.E1_CLIENTE+SE1.E1_LOJA "+CRLF
	cQuery += "			AND AB.E1_TIPO IN ('AB-','FB-','FC-','FU-','FP-','FM-','IR-','IN-','IS-','PI-','CF-','CS-','FE-','IV-') "+CRLF  // +FormatIN(MVABATIM,'|') --
	cQuery += "		),0) "+CRLF
	cQuery += "		- E1_SDDECRE + E1_SDACRES) "+CRLF
	cQuery += "		- CASE WHEN E1_BAIXA = ' ' THEN (E1_XXVRETC + E1_XXVCVIN) ELSE 0 END"+CRLF
	cQuery += "	ELSE 0 END  AS SALDO "+CRLF

	cQuery += ",COALESCE((SELECT SUM(E1_VALOR) "+CRLF
	cQuery += "			FROM "+cTabSE1+ " AB "+CRLF
	cQuery += "			WHERE AB.D_E_L_E_T_ <> '*' "+CRLF
	cQuery += "			AND AB.E1_FILIAL 	= SE1.E1_FILIAL "+CRLF
	cQuery += "			AND AB.E1_PREFIXO 	= SE1.E1_PREFIXO "+CRLF
	cQuery += "			AND AB.E1_NUM 		= SE1.E1_NUM "+CRLF
	cQuery += "			AND AB.E1_TITPAI 	= SE1.E1_PREFIXO+SE1.E1_NUM+SE1.E1_PARCELA+SE1.E1_TIPO+SE1.E1_CLIENTE+SE1.E1_LOJA "+CRLF
	cQuery += "			AND AB.E1_TIPO IN ('AB-','FB-','FC-','FU-','FP-','FM-','IR-','IN-','IS-','PI-','CF-','CS-','FE-','IV-') "+CRLF  // +FormatIN(MVABATIM,'|') --
	cQuery += "		),0) AS RETIDOS"+CRLF

	cQuery += ", E1_XXVRETC + E1_XXVCVIN AS RETENCOES"+CRLF

	cQuery += ",CASE WHEN E1_TIPO <> 'NDC' THEN C5_XXCOMPM ELSE SUBSTRING(E1_XXCOMPE,5,2)+'/'+SUBSTRING(E1_XXCOMPE,1,4) END AS C5_XXCOMPM"  + CRLF
	cQuery += ",E1_TIPO"+CRLF
	cQuery += ",E1_PREFIXO"+CRLF
	cQuery += ",E1_NUM"+CRLF
	cQuery += ",E1_PARCELA"+CRLF
	cQuery += ",E1_CLIENTE"+CRLF
	cQuery += ",E1_LOJA"+CRLF
	cQuery += ",E1_EMISSAO"+CRLF
	cQuery += ",E1_VALOR"+CRLF
	cQuery += ",E1_IRRF"+CRLF
	cQuery += ",E1_INSS"+CRLF
	cQuery += ",E1_PIS"+CRLF
	cQuery += ",E1_COFINS"+CRLF
	cQuery += ",E1_CSLL"+CRLF
	cQuery += ",E1_ISS"+CRLF
	cQuery += ",E1_VRETBIS "+CRLF
	cQuery += ",E1_XXDTREC"+CRLF
	cQuery += ",E1_XXTPPRV"+CRLF
	cQuery += ",E1_XXOPER"+CRLF
	cQuery += ",CONVERT(VARCHAR(1000),CONVERT(Binary(1000),E1_XXHISTM)) E1_XXHISTM "+CRLF
	cQuery += ",SE1.R_E_C_N_O_ AS E1RECNO"+CRLF
	cQuery += ",F2_RECISS" + CRLF
	cQuery += ",F2_XXVCVIN" + CRLF
	cQuery += ",F2_XXVFUMD" + CRLF
	cQuery += ",F2_XXVRETC" + CRLF
	cQuery += ",E1_XXISSBI" +CRLF
	cQuery += ",CASE E1_XXCUSTO WHEN '' THEN CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1
	cQuery += "     ELSE C5_MDCONTR END ELSE E1_XXCUSTO END AS CONTRATO" + CRLF
	cQuery += ",CTT_CUSTO" + CRLF
	cQuery += ",CASE WHEN E1_VALOR<>E1_SALDO THEN 'Baixa Parcial' ELSE '' END AS E1_XXOBX " + CRLF
	cQuery += ",(SELECT SUM(E5_VALOR) FROM "+cTabSE5+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " + CRLF
	cQuery += "   AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5DESC "+ CRLF
	cQuery += ",(SELECT SUM(E5_VALOR) FROM "+cTabSE5+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " + CRLF
	cQuery += "   AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5MULTA "+ CRLF
	cQuery += " FROM "+cTabSE1+ " SE1 " + CRLF
	cQuery += " LEFT JOIN "+cTabSF2+ " SF2 ON SF2.D_E_L_E_T_='' AND SE1.E1_NUM=SF2.F2_DUPL " + CRLF
	cQuery += "      AND SE1.E1_PREFIXO=SF2.F2_PREFIXO AND SE1.E1_CLIENTE=SF2.F2_CLIENTE AND SE1.E1_LOJA=SF2.F2_LOJA" + CRLF
	cQuery += " LEFT JOIN "+cTabSC5+ " SC5 ON SC5.D_E_L_E_T_='' AND SC5.C5_NUM=SE1.E1_PEDIDO " + CRLF
	cQuery += " LEFT JOIN "+cTabSA1+ " SA1 ON SA1.D_E_L_E_T_='' AND SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA" + CRLF
	cQuery += " LEFT JOIN "+cTabCTT+ " CTT ON CTT.D_E_L_E_T_='' AND (CASE E1_XXCUSTO WHEN '' THEN CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1 ELSE C5_MDCONTR END ELSE E1_XXCUSTO END) = CTT.CTT_CUSTO" + CRLF

	cQuery += " WHERE SE1.D_E_L_E_T_='' AND SE1.E1_TIPO IN('NF','NDC','BOL')" + CRLF

	cQuery += "  AND E1_VENCREA >= ? --" + xVencIni + CRLF
	cQuery += "  AND E1_VENCREA <= ? --" + xVencFim + CRLF

	aAdd(aBinds,xVencIni)
	aAdd(aBinds,xVencFim)
Next
/*
cQuery += ") "+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  * " + CRLF
cQuery += "  FROM RESUMO " + CRLF
*/
cQuery += " ORDER BY EMPRESA,E1_VENCREA,A1_NOME,E1_PREFIXO,E1_NUM " + CRLF

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
