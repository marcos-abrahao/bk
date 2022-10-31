#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKEncode
    (long_description)
    @type  Function
    @author Marcos B. Abrahão
    @since 13/08/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function BKEnCode(aParam)
Local cEnCode As Character
Local nI      As Numeric

Default aParam := {}

cEnCode   := __cUserId+";"+DTOS(DATE())+";"+TIME()+";"
For nI := 1 To Len(aParam)
    cEnCode += aParam[nI]+";"
Next

//cEnCode   := Embaralha(cEnCode,0)
cEnCode   := WebEncript(cEnCode,.F.)
cEnCode   := Encode64(cEnCode)
cEnCode   := STRTRAN(cEncode,"+",".")
cEnCode   := STRTRAN(cEncode,"/","_")
cEnCode   := STRTRAN(cEncode,"=","-")

Return cEnCode


User Function BKDeCode(cCode)
Local aDeCode As Array
Local cEnCode As Character

aDecode   := {}
cEnCode   := STRTRAN(cCode,".","+")
cEnCode   := STRTRAN(cEncode,"_","/")
cEnCode   := STRTRAN(cEncode,"-","=")
cEnCode   := Decode64(cEncode)
//cEnCode   := Embaralha(cEncode,1)
cEnCode   := WebEncript(cEnCode,.T.)
aDecode   := StrTokArr(cEncode,";")

Return aDecode


User Function ExBKCode()
Local cMensagem As Character
Local cEnCode   As Character
Local aDeCode   As Array
Local nI        As Numeric

__cUserId := "000000"

cEncode := u_BKEnCode({"A","b","c"})
aDeCode := u_BKDeCode(cEnCode)

cMensagem := "Entrada : [" + cEncode + "]"
For nI := 1 To Len(aDecode)
    cMensagem += CRLF + "Saida["+Str(nI)+"]: [" + aDeCode[nI]+ "]"
Next

MsgInfo(cMensagem, "Exemplo BKEnCode")

Return



User Function BKAvPar(cToken,aParams,cMsg)
Local lRet As Logical
lRet := .F.

If !Empty(cToken)
  
	aParams := u_BKDeCode(cToken)
    If !Len(aParams) < 3
    	__cUserId := aParams[1]
    	cUserName := UsrRetName(__cUserId)
		If !Empty(cUserName)
			If STOD(aParams[2]) == DATE()
          		lRet := .T.
          		cMsg := "Ok"
        	Else
          		cMsg := "Token expirado"
        	EndIf
      	Else
        	cMsg := "Usuário inválido"
      	EndIf
    Else
    	cMsg := "Token incorreto"
    EndIf
Else
	cMsg := "Token não informado"
EndIf
Return lRet




