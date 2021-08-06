#include 'totvs.ch'
#include 'RestFul.ch'

//User Function REST0001
//Return Nil

WSRESTFUL helloworld DESCRIPTION "Rest Hello World"
	
	WSDATA mensagem AS STRING
	
	WSMETHOD GET DESCRIPTION "Metodo get para Hello World" WSSYNTAX "/helloworld/{}"
	

END WSRESTFUL


WSMETHOD GET WSRECEIVE mensagem WSSERVICE helloworld  

	Local lRet := .T.
	Local oJson:= JsonObject():New()
	Local cMsg := ''
	
	//Define o tipo de retorno do servico
	::setContentType('application/json')
	
	//Mensagem 
	cMsg := 'Hello World!'	
	Conout(cMsg)


	//via query string
	// exemplo: http://localhost:8080/sample?startIndex=1&count=10
	//If Valtype(::mensagem) <> 'U'
	//	cMsg += ::mensagem + ' via query string'
	//EndIf
			
	//via parametros de url
	// exemplo: http://localhost:8080/sample/1
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

