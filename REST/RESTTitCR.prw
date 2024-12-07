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

	lRet := fStatus(::empresa,::e1recno,::acao,@cMsg,oJson)

EndIf

oJson['liberacao'] := StrIConv(cMsg, "CP1252", "UTF-8")

cRet := oJson:ToJson()

FreeObj(oJson)
// CORS
Self:SetHeader("Access-Control-Allow-Origin", "*")

Self:SetResponse(cRet)
  
Return lRet



Static Function fStatus(empresa,e1recno,acao,cMsg,oJson)
Local lRet 		:= .F.
Local cQuery	:= ""
Local cTabSE1	:= "SE1"+empresa+"0"
Local cQrySE1	:= GetNextAlias()
Local cNum		:= ""
Local cTipo		:= ""

// Dados para gravar
Local cZyPrev	:= STRTRAN(AllTrim(oJson['zyprev']),"-","")
Local cZYObs	:= AllTrim(oJson['zyobs'])
Local aAreaSZY
Local cNewAls
Local cModo

Default cMsg	:= ""
Default cMotivo := ""

Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

cQuery := "SELECT "
cQuery += "   SE1.E1_TIPO"
cQuery += "  ,SE1.E1_PREFIXO"
cQuery += "  ,SE1.E1_NUM"
cQuery += "  ,SE1.E1_PARCELA"
cQuery += "  ,SE1.E1_XXTPPRV"
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
		cMsg   := acao
		cQuery := "UPDATE "+cTabSE1+CRLF
		cQuery += "  SET  E1_XXTPPRV = '"+SUBSTR(acao,1,1)+"'"+CRLF
		cQuery += "      ,E1_XXDTPRV = '"+cZyPrev+"'"+CRLF
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
				(cNewAls)->ZY_STATUS	:= SUBSTR(acao,1,1)
				(cNewAls)->ZY_OPER		:= __cUserId
				(cNewAls)->ZY_DTPREV	:= STOD(cZyPrev)
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


// v5
WSMETHOD GET PLANCR QUERYPARAM empresa,vencini,vencfim WSREST RestTitCR
	Local cProg 	:= "RestTitCR"
	Local cTitulo	:= "Contas a Receber WEB"
	Local cDescr 	:= "Exportação Excel do Contas a Receber Web"
	Local cVersao	:= "15/05/2024"
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

	oPExcel:AddCol("CONTRATO","IIF(EMPTY(C5_MDCONTR),E1_MDCONTR,C5_MDCONTR)","Contrato","")
	oPExcel:GetCol("CONTRATO"):SetHAlign("C")

	oPExcel:AddCol("Cliente","A1_NOME","Cliente","A1_NOME")

	oPExcel:AddCol("VENC","STOD(E1_VENCREA)","Vencto","E1_VENCREA")

	oPExcel:AddCol("EMISSAO","STOD(E1_EMISSAO)","Emissao","E1_EMISSAO")

	oPExcel:AddCol("PEDIDO","E1_PEDIDO","Pedido","E1_PEDIDO")
	oPExcel:GetCol("PEDIDO"):SetHAlign("C")

	oPExcel:AddCol("COMPET","C5_XXCOMPM","Competência","C5_XXCOMPM")
	oPExcel:GetCol("COMPET"):SetHAlign("C")

	oPExcel:AddCol("VALOR","E1_VALOR","Valor","E1_VALOR")
	oPExcel:GetCol("VALOR"):SetTotal(.T.)

	oPExcel:AddCol("SALDO","u_SaldoRec(E1RECNO)","Saldo Liq.","E1_SALDO")
	oPExcel:GetCol("SALDO"):SetDecimal(2)
	oPExcel:GetCol("SALDO"):SetTotal(.T.)

	oPExcel:AddCol("PREVISAO","STOD(E1_XXDTPRV)","Previsão","E1_XXDTPRV")

	oPExcel:AddCol("OPER","UsrRetName(E1_XXOPER)","Operador","")

	oPExcel:AddCol("STATUS","u_DE1XXTPPrv(E1_XXTPPRV)","Status","")
	oPExcel:GetCol("STATUS"):SetHAlign("C")
	oPExcel:GetCol("STATUS"):SetTamCol(18)
	oPExcel:GetCol("STATUS"):AddCor({|x| TRIM(x) == 'A Receber'}			,"000000","",,,.T.)	// Preto
	oPExcel:GetCol("STATUS"):AddCor({|x| TRIM(x) == 'Sem Previsao'}			,"FF0000","",,,.T.)	// Vermelho
	oPExcel:GetCol("STATUS"):AddCor({|x| TRIM(x) == 'Aguardando Previsao'}	,"FFA500","",,,.T.)	// Laranja
	oPExcel:GetCol("STATUS"):AddCor({|x| TRIM(x) == 'Previsao Informada'}	,"0000FF","",,,.T.)	// Azul
	oPExcel:GetCol("STATUS"):AddCor({|x| TRIM(x) == 'Recebido'}				,"008000","",,,.T.)	// Verde

	oPExcel:AddCol("HISTM","E1_XXHISTM","Histórico","E1_XXHISTM")
	oPExcel:GetCol("HISTM"):SetWrap(.T.)

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

//-------------------------------------------------------------------
// Alimenta array de Pré-notas
//-------------------------------------------------------------------
Do While ( cQrySE1 )->( ! Eof() )

	aAdd( aListCR , JsonObject():New() )

	nPos	:= Len(aListCR)
	cNumTit	:= (cQrySE1)->(E1_PREFIXO+E1_NUM+E1_PARCELA)
	cNumTit := STRTRAN(cNumTit," ","&nbsp;")
	nSaldo := u_SaldoRec((cQrySE1)->E1RECNO)
	aListCR[nPos]['EMPRESA']	:= (cQrySE1)->EMPRESA
	aListCR[nPos]['TIPO']     	:= (cQrySE1)->E1_TIPO
	aListCR[nPos]['TITULO']     := TRIM(cNumTit)
	aListCR[nPos]['CLIENTE'] 	:= TRIM((cQrySE1)->A1_NOME)
	//aListCR[nPos]['VENC'] 	:= DTOC(STOD((cQrySE1)->E1_VENCREA))
	aListCR[nPos]['VENC'] 		:= (cQrySE1)->(SUBSTR(E1_VENCREA,1,4)+"-"+SUBSTR(E1_VENCREA,5,2)+"-"+SUBSTR(E1_VENCREA,7,2))+" 12:00:00"  // Se não colocar 12:00 ele mostra a data anterior
	//aListCR[nPos]['EMISSAO'] 	:= DTOC(STOD((cQrySE1)->E1_EMISSAO))
	aListCR[nPos]['EMISSAO'] 	:= (cQrySE1)->(SUBSTR(E1_EMISSAO,1,4)+"-"+SUBSTR(E1_EMISSAO,5,2)+"-"+SUBSTR(E1_EMISSAO,7,2))+" 12:00:00"  // Se não colocar 12:00 ele mostra a data anterior
	aListCR[nPos]['COMPET']		:= TRIM((cQrySE1)->C5_XXCOMPM)
	aListCR[nPos]['PEDIDO']		:= TRIM((cQrySE1)->E1_PEDIDO)
	aListCR[nPos]['VALOR']      := TRANSFORM((cQrySE1)->E1_VALOR,"@E 999,999,999.99")
	aListCR[nPos]['SALDO'] 	    := TRANSFORM(nSaldo,"@E 999,999,999.99")
	aListCR[nPos]['STATUS']		:= (cQrySE1)->(E1_XXTPPRV)
	//aListCR[nPos]['PREVISAO']	:= DTOC(STOD((cQrySE1)->(E1_XXDTPRV)))
	If !Empty((cQrySE1)->(E1_XXDTPRV))
		aListCR[nPos]['PREVISAO']	:= (cQrySE1)->(SUBSTR(E1_XXDTPRV,1,4)+"-"+SUBSTR(E1_XXDTPRV,5,2)+"-"+SUBSTR(E1_XXDTPRV,7,2))+" 12:00:00"  // Se não colocar 12:00 ele mostra a data anterior
	Else
		aListCR[nPos]['PREVISAO']	:= ""
	EndIf
	aListCR[nPos]['HISTM']		:= StrIConv(ALLTRIM((cQrySE1)->E1_XXHISTM), "CP1252", "UTF-8") 
	aListCR[nPos]['OPER']		:= (cQrySE1)->(UsrRetName(E1_XXOPER)) //(cQrySE1)->(FwLeUserLg('E1_USERLGA',1))
	aListCR[nPos]['CONTRATO']	:= IIF(!EMPTY((cQrySE1)->C5_MDCONTR),ALLTRIM((cQrySE1)->C5_MDCONTR),ALLTRIM((cQrySE1)->E1_MDCONTR))
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
Local cTabSA1	:= "SA1"+self:empresa+"0"
//Local cTabSF2	:= "SF2"+self:empresa+"0"
Local cTabSZY	:= "SZY"+self:empresa+"0"
Local cQrySE1	:= GetNextAlias()
Local cQrySZY	:= GetNextAlias()
Local aEmpresas	As Array
Local aParams	As Array
Local cMsg		As Character
Local nI 		:= 0
Local aItens 	As Array

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
cQuery += "	 ,E1_VENCREA"+CRLF
cQuery += "	 ,E1_VALOR"+CRLF
cQuery += "	 ,E1_XXOPER"+CRLF
cQuery += "	 ,SE1.R_E_C_N_O_ AS E1RECNO"+CRLF
cQuery += "  ,CONVERT(VARCHAR(800),CONVERT(Binary(800),E1_XXHISTM)) AS E1_XXHISTM "+CRLF
cQuery += "	 ,A1_NOME"+CRLF
cQuery += "	 ,A1_PESSOA"+CRLF
cQuery += "	 ,A1_CGC"+CRLF
cQuery += "	 ,(CASE WHEN E1_SALDO = E1_VALOR "+CRLF
cQuery += "	 		THEN E1_VALOR + E1_ACRESC - E1_DECRESC"+CRLF
cQuery += "	 		ELSE E1_SALDO END) AS SALDO"+CRLF

cQuery += "	 FROM "+cTabSE1+" SE1 "+CRLF

/*
cQuery += "	 LEFT JOIN "+cTabSF2+" SF2 ON"+CRLF
cQuery += "	 	SE1.E1_FILIAL      = SF2.F2_FILIAL"+CRLF
cQuery += "	 	AND SE1.E1_NUM     = SF2.F2_DOC "+CRLF
cQuery += "	 	AND SE1.E1_PREFIXO = SF2.F2_SERIE"+CRLF
cQuery += "	 	AND SE1.E1_CLIENTE = SF2.F2_CLIENTE"+CRLF
cQuery += "	 	AND SE1.E1_LOJA    = SF2.F2_LOJA"+CRLF
cQuery += "	 	AND SE1.D_E_L_E_T_ = ''"+CRLF
*/
cQuery += "	 LEFT JOIN "+cTabSA1+" SA1 ON"+CRLF
cQuery += "	 	SA1.A1_FILIAL      = '  '"+CRLF
cQuery += "	 	AND SE1.E1_CLIENTE = SA1.A1_COD"+CRLF
cQuery += "	 	AND SE1.E1_LOJA    = SA1.A1_LOJA"+CRLF
cQuery += "	 	AND SA1.D_E_L_E_T_ = ''"+CRLF

cQuery += "WHERE SE1.R_E_C_N_O_ = "+self:e1recno + CRLF

//u_LogMemo("RESTTITCR-E2.SQL",cQuery)

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

(cQrySE1)->(dbCloseArea())

cQuery := "SELECT " + CRLF
cQuery += "	  ZY_DATA"+CRLF
cQuery += "	 ,ZY_HORA"+CRLF
cQuery += "	 ,ZY_STATUS"+CRLF
cQuery += "	 ,ZY_OPER"+CRLF
cQuery += "	 ,ZY_DTPREV"+CRLF
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
	aItens[nI]["ZY_STATUS"]	:= u_DE1XXTPPrv((cQrySZY)->ZY_STATUS)
	aItens[nI]["ZY_OPER"]	:= (cQrySZY)->USR_CODIGO
	aItens[nI]["ZY_DTPREV"]	:= DTOC(STOD((cQrySZY)->ZY_DTPREV))
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
Local cMsg		As Char
Local cHTML		As char
Local cDropEmp	As char
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

<!-- Styling CSS -->
#BKDTStyle#
 
<title>Títulos Contas a Receber #datavencI# a #datavencF# #NomeEmpresa#</title>

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
	</div>

    <form class="d-flex">
	  <label class="sr-only" for="DataVencI"></label>
	  <input class="form-control me-2" type="date" id="DataVencI" value="#datavencI#" />
	  <label class="sr-only" for="DataVencF"></label>
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
<table id="tableSE1" class="table table-sm table-hover" style="width:100%">
<thead>
<tr>
<th scope="col"></th>
<th scope="col">Empresa</th>
<th scope="col">Tipo</th>
<th scope="col" width="7%" >Título</th>
<th scope="col" style="text-align:center;" width="5%" >Contrato</th>
<th scope="col" width="20%">Cliente</th>
<th scope="col" style="text-align:center;" width="5%" >Emissão</th>
<th scope="col" style="text-align:center;" width="5%" >Vencto</th>
<th scope="col" style="text-align:center;" width="5%" >Pedido</th>
<th scope="col" style="text-align:center;" width="5%" >Compet</th>
<th scope="col" style="text-align:right;">Valor</th>
<th scope="col" style="text-align:right;">Saldo Liq.</th>
<th scope="col" style="text-align:center;">Status</th>
<th scope="col" style="text-align:center;">Previsão</th>
<th scope="col">Operador</th>
<th scope="col">Histórico</th>
</tr>
</thead>
<tbody id="mytable">
<tr>
  <td scope="col"></td>
  <td scope="col"><b>Carregando Títulos...</b></td>
  <td scope="col"></td>
  <td scope="col"></td>
  <td scope="col" style="text-align:center;"></td>
  <td scope="col"></td>
  <td scope="col" style="text-align:center;"></td>
  <td scope="col" style="text-align:center;"></td>
  <td scope="col" style="text-align:center;"></td>
  <td scope="col" style="text-align:center;"></td>
  <td scope="col" style="text-align:right;"></td>
  <td scope="col" style="text-align:right;"></td>
  <td scope="col" style="text-align:center;"></td>
  <td scope="col" style="text-align:center;"></td>
  <td scope="col"></td>
  <td scope="col"></td>
</tr>
</tbody>
<tfoot>
  <tr>
    <th scope="col"></th>
    <th scope="col"></th>
    <th scope="col"></th>
    <th scope="col" width="7%" ></th>
    <th scope="col" style="text-align:center;" width="5%" ></th>
    <th scope="col" width="20%"></th>
    <th scope="col" style="text-align:center;" width="5%" ></th>
    <th scope="col" style="text-align:center;" width="5%" ></th>
    <th scope="col" style="text-align:center;" width="5%" ></th>
    <th scope="col" style="text-align:right;" width="5%" >Totais:</th>
    <th scope="col" style="text-align:right;">Valor</th>
    <th scope="col" style="text-align:right;">Saldo Liq.</th>
    <th scope="col" style="text-align:center;"></th>
    <th scope="col" style="text-align:center;"></th>
    <th scope="col"></th>
    <th scope="col"></th>      
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
             <label for="E1Oper" class="form-label">Operador</label>
             <input type="text" class="form-control form-control-sm" id="E1Oper" value="#E1Oper#" readonly="">
           </div>

           <div class="col-md-1">
             <label for="E1Pedido" class="form-label">Pedido</label>
             <input type="text" class="form-control form-control-sm" id="E1Pedido" value="#E1Pedido#" readonly="">
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
							<th scope="col">Status</th>
							<th scope="col">Operador</th>
							<th scope="col">Previsão</th>
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

        <label for="ZYPrev" class="form-label">Previsão de Recebimento:</label>
		<input class="form-control me-2" type="date" id="ZYPrev" value="#ZYPrev#" />

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
	let url = '#iprest#/RestTitCR/v0?empresa=#empresa#&vencini=#vencini#&vencfim=#vencfim#&userlib=#userlib#'
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
let ccbtn = '';
let anexos = '';
let cbtne1  = '';
let cbtnids = '';
let nlin = 0;
let clin = '';

if (Array.isArray(titulos)) {
	titulos.forEach(object => {
	let cStatus  = object['STATUS'];
	let cEmpresa = object['EMPRESA'].substring(0,2);

	clin = nlin.toString()

	cbtne1  = 'btne1'+nlin;
	cbtnids = 'btnac'+nlin;

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
	trHTML += '<td>'+cStatus+'</td>';
	trHTML += '<td>'+object['EMPRESA']+'</td>';
	trHTML += '<td>'+object['TIPO']+'</td>';

	//trHTML += '<td id=titulo'+clin+'>'+object['TITULO']+'</td>';
	trHTML += '<td>';
		trHTML += '<button type="button" id='+cbtne1+' class="btn btn-outline-'+ccbtn+' btn-sm" onclick="showE1(\''+cEmpresa+'\',\''+object['E1RECNO']+'\',\'#userlib#\','+'\''+cbtne1+'\')">'+object['TITULO']+'</button>';	
	trHTML += '</td>';
	trHTML += '<td align="center">'+object['CONTRATO']+'</td>';	
	trHTML += '<td id=cliente'+clin+'>'+object['CLIENTE']+'</td>';
	trHTML += '<td align="center">'+object['EMISSAO']+'</td>';
	trHTML += '<td align="center">'+object['VENC']+'</td>';
	trHTML += '<td align="center">'+object['PEDIDO']+'</td>';
	trHTML += '<td align="center">'+object['COMPET']+'</td>';

	trHTML += '<td align="right">'+object['VALOR']+'</td>';
	trHTML += '<td align="right">'+object['SALDO']+'</td>';

	trHTML += '<td>'

	// Botão para mudança de status
	trHTML += '<div class="btn-group">'
		trHTML += '<button type="button" id="'+cbtnids+'" class="btn btn-outline-'+ccbtn+' btn-sm dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">'
		trHTML += cStatus
		trHTML += '</button>'

		trHTML += '<div class="dropdown-menu" aria-labelledby="dropdownMenu2">'
		trHTML += '<button class="dropdown-item" type="button" onclick="AltStatus(\''+cEmpresa+'\',\''+object['E1RECNO']+'\',\'#userlib#\',\' \','+'\''+cbtnids+'\','+'\''+clin+'\')">A Receber</button>';
		trHTML += '<button class="dropdown-item" type="button" onclick="AltStatus(\''+cEmpresa+'\',\''+object['E1RECNO']+'\',\'#userlib#\',\'0\','+'\''+cbtnids+'\','+'\''+clin+'\')">Sem Previsao</button>';
		trHTML += '<button class="dropdown-item" type="button" onclick="AltStatus(\''+cEmpresa+'\',\''+object['E1RECNO']+'\',\'#userlib#\',\'1\','+'\''+cbtnids+'\','+'\''+clin+'\')">Aguardando Previsao</button>';
		trHTML += '<button class="dropdown-item" type="button" onclick="AltStatus(\''+cEmpresa+'\',\''+object['E1RECNO']+'\',\'#userlib#\',\'2\','+'\''+cbtnids+'\','+'\''+clin+'\')">Previsao Informada</button>';
		trHTML += '<button class="dropdown-item" type="button" onclick="AltStatus(\''+cEmpresa+'\',\''+object['E1RECNO']+'\',\'#userlib#\',\'3\','+'\''+cbtnids+'\','+'\''+clin+'\')">Recebido</button>';
		trHTML += '</div>'
		
	trHTML += '</td>'

	trHTML += '<td id=prev'+clin+' align="center">'+object['PREVISAO']+'</td>';

	trHTML += '<td id=oper'+clin+'>'+object['OPER']+'</td>';

	trHTML += '<td id=hist'+clin+'>'+object['HISTM']+'</td>';

	trHTML += '</tr>';

	nlin += 1;

	});
} else {
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="15" style="text-align:center;">'+titulos['liberacao']+'</th>';
    trHTML += '</tr>';   
    trHTML += '<tr>';
    trHTML += ' <th scope="row" colspan="15" style="text-align:center;">Faça login novamente no sistema Protheus</th>';
    trHTML += '</tr>';   
}
document.getElementById("mytable").innerHTML = trHTML;


tableSE1 = $('#tableSE1').DataTable({
  "pageLength": 25,
  "processing": true,
  "scrollX": true,
  "scrollCollapse": true,
  "scrollY": "72vh",
  "language": {
	"lengthMenu": "Registros por página: _MENU_ ",
	"zeroRecords": "Nada encontrado",
	"info": "Página _PAGE_ de _PAGES_",
	"infoEmpty": "Nenhum registro disponível",
	"infoFiltered": "(filtrado de _MAX_ registros no total)",
	"search": "Filtrar:",
	"decimal": ",",
	"thousands": ".",
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
        { data: 'Tipo' },
        { data: 'Título' },
        { data: 'Contrato' },		
        { data: 'Cliente' },
        { data: 'Emissão' },
        { data: 'Vencto' },
        { data: 'Pedido' },
        { data: 'Compet' },
        { data: 'Valor' },
        { data: 'Saldo' },
        { data: 'Status' },
        { data: 'Previsão' },
        { data: 'Operador' },
        { data: 'Histórico' }

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
    },
footerCallback: function (row, data, start, end, display) {
       var api = this.api();
       // Remove the formatting to get integer data for summation
       var intVal = function (i) {
           var x = i;
           var y = 0;
           if (typeof x === 'string') {
             x = x.replaceAll(' ', '');
             x = x.replaceAll('.', '');
             x = x.replace(',', '.');
             y = parseFloat(x)
           };
           if (typeof i === 'number'){
               y = i;
           };
           return y;
       };
       // Total filtrado
       total = api
           .column(10, {filter: 'applied'})
           .data()
           .reduce(function (a, b) {
               return intVal(a) + intVal(b);
           }, 0);
 
       // Update footer
       $(api.column(10).footer()).html(
           total.toLocaleString('pt-br', {minimumFractionDigits: 2})
       );


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
    },
	columnDefs: [
    	{
            target: 15,
            visible: false,
            searchable: false
        },
		{
			target: 4,
			className: 'text-center'
    	},
		{
			targets: [10,11],
			className: 'text-right'
    	},
		{
            targets: [6,7,13], render: DataTable.render.date()
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

//document.getElementById(cbtne1).disabled = true;
//document.getElementById(cbtne1).innerHTML = '<span class="spinner-border spinner-border-sm me-1" role="status" aria-hidden="true"></span>';

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
document.getElementById('E1Oper').value = dadosE1['E1_XXOPER'];
document.getElementById('E1HistM').value = dadosE1['E1_XXHISTM'];
document.getElementById('E1Pedido').value = dadosE1['E1_PEDIDO'];

if (Array.isArray(dadosE1.DADOSZY)) {
   dadosE1.DADOSZY.forEach(object => {
    i++
	itens += '<tr>';
	itens += '<td>'+object['ZY_DATA']+'</td>';	
	itens += '<td>'+object['ZY_HORA']+'</td>';
	itens += '<td>'+object['ZY_STATUS']+'</td>';
	itens += '<td>'+object['ZY_OPER']+'</td>';
	itens += '<td>'+object['ZY_DTPREV']+'</td>';
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


async function AltStatus(empresa,e1recno,userlib,acao,btnids,clin){
let btnAlt = '<button type="button" class="btn btn-outline-success" onclick="ChgStatus(\''+empresa+'\',\''+e1recno+'\',\'#userlib#\',\''+acao+'\','+'\''+btnids+'\','+'\''+clin+'\')">Salvar</button>';
document.getElementById("btnAlt").innerHTML = btnAlt;
document.getElementById("AltTitulo").textContent = "Título "+document.getElementById("btne1"+clin).textContent + ' - '+document.getElementById("cliente"+clin).textContent;
//document.getElementById("AltTitulo").textContent = ' - '+document.getElementById("cliente"+clin).textContent;
document.getElementById("ZYObs").value = '';

$('#altStatus').modal('show');
}


async function ChgStatus(empresa,e1recno,userlib,acao,btnids,clin){
let resposta = ''
let cbtn = '';

let ZYPrev = document.getElementById("ZYPrev").value;
let ZYObs  = document.getElementById("ZYObs").value;

let dataObject = {	liberacao:'ok',
					zyprev:ZYPrev,
					zyobs:ZYObs,
				 };

let nlin = parseInt(clin,10)

$('#altStatus').modal('hide');

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
			cbtn = 'A Receber';
		} else if (acao == '0'){
			cbtn = 'Sem Previsao';
		} else if (acao == '1'){
			cbtn = 'Aguardando Previsao';
		} else if (acao == '2'){
			cbtn = 'Previsao Informada';
		} else {
			cbtn = 'Recebido';
		}
		document.getElementById(btnids).textContent = cbtn;
		document.getElementById('prev'+clin).textContent = ZYPrev.substring(8,10)+'/'+ZYPrev.substring(5,7)+'/'+ZYPrev.substring(0,4)
		//document.getElementById('prev'+clin).value = ZYPrev.value
		document.getElementById('oper'+clin).textContent = '#cUserName#';
		document.getElementById('hist'+clin).textContent = ZYObs;
   		//var tr = $(this).closest('tr');
    	//var row = tableSE1.row(tr);
 
		//tableSE1.row(nlin).data().Histórico = ZYObs
 	    //tableSE1.row(nlin).invalidate().draw();

	})
}

async function Excel(){
let newvenci  = document.getElementById("DataVencI").value;
let newvamdi  = newvenci.substring(0, 4)+newvenci.substring(5, 7)+newvenci.substring(8, 10)
let newvencf  = document.getElementById("DataVencF").value;
let newvamdf  = newvencf.substring(0, 4)+newvencf.substring(5, 7)+newvencf.substring(8, 10)

window.open("#iprest#/RestTitCR/v5?empresa=#empresa#&vencini="+newvamdi+"&vencfim="+newvamdf+"&userlib=#userlib#","_self");
}


async function getUrlTmp(url1) {
	try {
	let res = await fetch(url1);
		return await res.json();
		} catch (error) {
	console.log(error);
		}
	}

async function AltVenc(){
let newvenci = document.getElementById("DataVencI").value;
let newvamdi  = newvenci.substring(0, 4)+newvenci.substring(5, 7)+newvenci.substring(8, 10)
let newvencf = document.getElementById("DataVencF").value;
let newvamdf  = newvencf.substring(0, 4)+newvencf.substring(5, 7)+newvencf.substring(8, 10)

window.open("#iprest#/RestTitCR/v2?empresa=#empresa#&vencini="+newvamdi+"&vencfim="+newvamdf+"&userlib=#userlib#","_self");
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

	u_BkAvPar(self:userlib,@aParams,@cMsg)

	cHtml := STRTRAN(cHtml,"#userlib#",::userlib)
	cHtml := STRTRAN(cHtml,"#cUserName#",cUserName)  
EndIf

cHtml := STRTRAN(cHtml,"#empresa#",::empresa)
cHtml := STRTRAN(cHtml,"#vencini#",::vencini)
cHtml := STRTRAN(cHtml,"#vencfim#",::vencfim)
cHtml := STRTRAN(cHtml,"#datavencI#",SUBSTR(::vencini,1,4)+"-"+SUBSTR(::vencini,5,2)+"-"+SUBSTR(::vencini,7,2))   // Formato: 2023-10-24 input date
cHtml := STRTRAN(cHtml,"#datavencF#",SUBSTR(::vencfim,1,4)+"-"+SUBSTR(::vencfim,5,2)+"-"+SUBSTR(::vencfim,7,2))   // Formato: 2023-10-24 input date
cHtml := STRTRAN(cHtml,"#ZYPrev#",STR(YEAR(DATE()),4)+"-"+STRZERO(MONTH(DATE()),2)+"-"+STRZERO(DAY(DATE()),2))   // Formato: 2023-10-24 input date

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
	cDropEmp += '<li><a class="dropdown-item" href="'+u_BkRest()+'/RestTitCR/v2?empresa='+aEmpresas[nE,1]+'&vencini='+self:vencini+'&vencfim='+self:vencfim+'&userlib='+self:userlib+'">'+aEmpresas[nE,1]+'-'+aEmpresas[nE,2]+'</a></li>'+CRLF
Next
cDropEmp +='<li><hr class="dropdown-divider"></li>'+CRLF
cDropEmp +='<li><a class="dropdown-item" href="'+u_BkRest()+'/RestTitCR/v2?empresa=Todas&vencini='+self:vencini+'&vencfim='+self:vencfim+'&userlib='+self:userlib+'">Todas</a></li>'+CRLF

cHtml := STRTRAN(cHtml,"#DropEmpresas#",cDropEmp)
// <-- Seleção de Empresas

//StrIConv( cHtml, "UTF-8", "CP1252")
//DecodeUtf8(cHtml)
cHtml := StrIConv( cHtml, "CP1252", "UTF-8")

//u_MsgLog(,"BROWCR/2")
//If ::userlib == '000000'
	Memowrite(u_STmpDir()+"cr.html",cHtml)
//EndIf
//u_MsgLog("RESTTITCR",__cUserId)

Self:SetHeader("Access-Control-Allow-Origin", "*")
self:setResponse(cHTML)
self:setStatus(200)

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
	cQuery += "  ,CONVERT(VARCHAR(800),CONVERT(Binary(800),E1_XXHISTM)) AS E1_XXHISTM "+CRLF
	cQuery += "	 ,E1_VENCREA"+CRLF
	cQuery += "	 ,E1_EMISSAO"+CRLF
	cQuery += "	 ,E1_VALOR"+CRLF
	cQuery += "	 ,E1_PEDIDO"+CRLF
	cQuery += "	 ,E1_XXTPPRV"+CRLF
	cQuery += "	 ,E1_XXDTPRV"+CRLF
	cQuery += "	 ,E1_XXOPER"+CRLF
	cQuery += "	 ,SUBSTRING(CASE E1_MDCONTR WHEN '' THEN E1_XXCUSTO ELSE E1_MDCONTR END,1,9) AS E1_MDCONTR " + CRLF

	cQuery += "	 ,SE1.R_E_C_N_O_ AS E1RECNO"+CRLF
	cQuery += "	 ,A1_NOME"+CRLF
	//cQuery += "	 ,A1_PESSOA"+CRLF
	//cQuery += "	 ,A1_CGC"+CRLF
	cQuery += "	 ,(CASE WHEN E1_SALDO = E1_VALOR "+CRLF
	cQuery += "	 		THEN E1_VALOR + E1_ACRESC - E1_DECRESC "+CRLF
	cQuery += "	 		ELSE E1_SALDO END) AS SALDO"+CRLF

	//cQuery += "	 ,F2_USERLGI"+CRLF
	cQuery += "	 ,ISNULL(C5_XXCOMPM,SUBSTRING(E1_XXCOMPE,5,2)+'/'+SUBSTRING(E1_XXCOMPE,1,4)) AS C5_XXCOMPM"+CRLF

	cQuery += "	 ,SUBSTRING(CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1 ELSE C5_MDCONTR END,1,9) AS C5_MDCONTR " + CRLF

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

	//cQuery += "  AND E1_VENCREA >= '"+xVencIni+"' "+CRLF
	//cQuery += "  AND E1_VENCREA <= '"+xVencFim+"' "+CRLF

	cQuery += "  AND E1_VENCREA >= ? --"+xVencIni+CRLF
	cQuery += "  AND E1_VENCREA <= ? --"+xVencFim+CRLF
	aAdd(aBinds,xVencIni)
	aAdd(aBinds,xVencFim)
Next
/*
cQuery += ") "+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  * " + CRLF
cQuery += "  FROM RESUMO " + CRLF
*/
cQuery += " ORDER BY EMPRESA,E1_VENCREA,A1_NOME " + CRLF


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
