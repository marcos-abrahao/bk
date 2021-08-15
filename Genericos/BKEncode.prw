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

cEnCode   := Embaralha(cEnCode,0)
cEnCode   := Encode64(cEnCode)

Return cEnCode


User Function BKDeCode(cCode)
Local aDeCode As Array
Local cEnCode As Character

aDecode   := {}
cEnCode   := Decode64(cCode)
cEnCode   := Embaralha(cEncode,1)
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




