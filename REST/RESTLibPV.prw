#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"

//#Include "Protheus.ch"
//#include 'totvs.ch'
//#include 'RestFul.ch'
#Include "TBICONN.CH"


//User Function RestLibPV
//Return Nil

WSRESTFUL RestLibPV DESCRIPTION "Rest Liberação de Pedido de Venda"
	
	WSDATA mensagem     AS STRING
    WSDATA empresa      AS STRING
    WSDATA filial       AS STRING
	WSDATA pedido 		AS STRING

    WSDATA page         AS INTEGER OPTIONAL
    WSDATA pageSize     AS INTEGER OPTIONAL
	
	WSMETHOD GET ;
		DESCRIPTION "Listar pedido de venda em aberto";
		WSSYNTAX "/RestLibPV";
        PATH  "/RestLibPV";
        TTALK "v1"//;
        //PRODUCES APPLICATION_JSON

 	WSMETHOD PUT ;
   		DESCRIPTION "Liberação de Pedido de Venda" ;
   		WSSYNTAX "/RestLibPV/{empresa}/{filiall}/{pedido}";
   		PATH "/RestLibPV/{empresa}/{filiall}/{pedido}";
        TTALK "v1"//;
        //PRODUCES APPLICATION_JSON

END WSRESTFUL


WSMETHOD PUT WSRECEIVE empresa,filial,pedido WSSERVICE RestLibPV    
//  Local cJson        := Self:GetContent()   
  Local lRet         := .T.
  Local lLib         := .T.
  Local oJson        As Object
//  Local cCatch       As Character  
  Local oMessages    As Object


	//Define o tipo de retorno do servico
	::setContentType('application/json')

    oJson  := JsonObject():New()
    //cCatch := oJson:FromJSON(cJson)

    oMessages := JsonObject():New()

    //If cCatch == Nil
        //PrePareContexto(::empresa,::filial)
    
        lLib := fLibPed(::pedido)

        //If lLib
            //Objeto responsavel por tratar os dados e gerar como json
            oMessages['liberacao'] :=iIf(lLib,"OK","Nao liberado")
        
            //Retorna os dados no formato json
            cRet := oMessages:ToJson()
        
            //Retorno do servico
            ::SetResponse(cRet)

        //EndIf
    //Else
    //    oMessages["code"] 	:= "400"
    //    oMessages["message"]	:= "Bad Request"
    //    oMessages["detailMessage"] := cCatch
    //    lRet := .F.
    //EndIf

    //If !lRet
    //    SetRestFault(Val(oMessages["code"]),oMessages["detailMessage"])
    //EndIf

Return lRet

 
/*/{Protheus.doc} GET / salesorder
Retorna a lista de pedidos.
 
@param 
 Page , numerico, numero da pagina 
 PageSize , numerico, quantidade de registros por pagina
 
@return cResponse , caracter, JSON contendo a lista de pedidos
/*/


WSMETHOD GET WSRECEIVE page, pageSize WSREST RestLibPV
 
Local aListSales := {}
Local cQrySC5       := GetNextAlias()
Local cJsonCli      := ''
Local cWhereSC5     := "%AND SC5.C5_FILIAL = '"+xFilial('SC5')+"'%"
Local cWhereSA1     := "%AND SA1.A1_FILIAL = '"+xFilial('SA1')+"'%"
Local cPedido       := ''
 
Local lRet := .T.
 
Local nCount := 0
Local nStart := 1
Local nReg := 0
//Local nTamPag := 0
Local oJsonSales := JsonObject():New()
 
Default self:page := 1
Default self:pageSize := 100

//nStart := INT(self:pageSize * (self:page - 1))
//nTamPag := self:pageSize := 100

//-------------------------------------------------------------------
// Query para selecionar pedidos
//-------------------------------------------------------------------

 
BeginSQL Alias cQrySC5
    SELECT  SC5.C5_FILIAL,SC5.C5_NUM,SC5.C5_CLIENTE,SC5.C5_LOJACLI,SA1.A1_NOME
            
    FROM %Table:SC5% SC5
            INNER JOIN %Table:SA1% SA1 
                ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA
                %exp:cWhereSA1%
                AND SA1.%NotDel%

    WHERE   SC5.%NotDel%
            AND SC5.C5_LIBEROK = '' AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = ''
            %exp:cWhereSC5%
    ORDER BY SC5.C5_NUM
    
EndSQL

//Syntax abaixo somente para o SQL 2012 em diante
//ORDER BY SC5.C5_NUM OFFSET %exp:nStart% ROWS FETCH NEXT %exp:nTamPag% ROWS ONLY


//conout(cQrySC5)
 
If ( cQrySC5 )->( ! Eof() )
 
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
    ( cQrySC5 )->( DBGoTop() )
 
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
// Alimenta array de pedidos
//-------------------------------------------------------------------
Do While ( cQrySC5 )->( ! Eof() )

    cPedido := (cQrySC5)->C5_NUM
 
    nCount++
 
    If nCount >= nStart
 
        aAdd( aListSales , JsonObject():New() )
        nPos := Len(aListSales)
        aListSales[nPos]['NUM']       := (cQrySC5)->C5_NUM
        aListSales[nPos]['CLIENTE']   := TRIM((cQrySC5)->C5_CLIENTE)
        aListSales[nPos]['LOJACLI']   := TRIM((cQrySC5)->C5_LOJACLI)
        aListSales[nPos]['NOME']      := TRIM((cQrySC5)->A1_NOME)
        (cQrySC5)->(DBSkip())
        
        If Len(aListSales) >= self:pageSize
            Exit
        EndIf
    Else
        (cQrySC5)->(DBSkip())
    EndIf
 
EndDo
 
( cQrySC5 )->( DBCloseArea() )
 
oJsonSales := aListSales
 
//-------------------------------------------------------------------
// Serializa objeto Json
//-------------------------------------------------------------------
cJsonCli:= FwJsonSerialize( oJsonSales )
 
//-------------------------------------------------------------------
// Elimina objeto da memoria
//-------------------------------------------------------------------
FreeObj(oJsonSales)
 
Self:SetResponse( cJsonCli ) //-- Seta resposta

Return( lRet )






Static Function fLibPed(cNumPed)
Local lOk := .F.

    dbSelectArea("SC5")
    SC5->(dbSetOrder(1))
    SC5->(dbSeek(xFilial("SC5")+cNumPed))

    If Empty(SC5->C5_LIBEROK).And.Empty(SC5->C5_NOTA) .And. Empty(SC5->C5_BLQ)
        dbSelectArea("SC6")
        SC6->(dbSetOrder(1))
        SC6->(dbSeek(xFilial("SC6")+cNumPed))

        While SC6->(!EOF()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == cNumPed

            MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,.T.,.T.,.F.,.F.,)

            Begin Transaction
			    SC6->(MaLiberOk({cNumPed},.F.))
		    End Transaction

            SC6->(dbSkip())
        EndDo

        lOk := .T.
    Else
        lOk := .F.
    EndIf
Return lOk



Static Function PrePareContexto(cCodEmpresa , cCodFilial)
 
RESET ENVIRONMENT
RPCSetType(3)
PREPARE ENVIRONMENT EMPRESA cCodEmpresa FILIAL cCodFilial TABLES "SC5" MODULO "FAT" 		

Return .T.

