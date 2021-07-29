#include 'totvs.ch'
#include 'RestFul.ch'

//User Function REST0001
//Return Nil

WSRESTFUL RestLibPV DESCRIPTION "Rest Liberação de Pedido de Venda"
	
	WSDATA mensagem as STRING
	
	WSMETHOD GET DESCRIPTION "Metodo get para Liberação de Pedido de Venda" WSSYNTAX "/RestLibPV/{}"
	
END WSRESTFUL


WSMETHOD GET WSRECEIVE mensagem WSSERVICE RestLibPV  

	Local lRet := .T.
	Local oJson:= JsonObject():New()
	Local cMsg := ''
	
	//Define o tipo de retorno do servico
	::setContentType('application/json')
	
	//Mensagem 
	cMsg := 'Hello World!'	
	Conout(cMsg)


	//via query string
	//If Valtype(::mensagem) <> 'U'
	//	cMsg += ::mensagem + ' via query string'
	//EndIf
			
	//via parametros de url
	//If Len(::aURLParms) > 0
	//	cMsg += ::aURLParms[1] + ' via parametro de url'
	//EndIf
	
	//Objeto responsavel por tratar os dados e gerar como json
	oJson['mensagem'] := cMsg
	
	//Retorna os dados no formato json
	cRet := oJson:ToJson()
	
	//Retorno do servico
	::SetResponse(cRet)
		
Return lRet


Static Function fLibPed(cNumPed)

    dbSelectArea("SC6")
    SC6->(dbSetOrder(1))
    SC6->(dbSeek(xFilial("SC6")+cNumPed))

    While SC6->(!EOF()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == cNumPed

        MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,.F.,.F.,.F.,.F.,)


        SC6->(dbSkip())
    EndDo

Return
