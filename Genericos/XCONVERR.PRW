#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} XCONVERR
CONVERTE O ARRAY AAUTOERRO EM TEXTO CONTINUO
@Return
@author Marcos Bispo Abrahão
@since 24/02/2022
@version P12
/*/


USER FUNCTION XCONVERR(aAutoErro)
LOCAL cRet := ""
LOCAL nX := 1
FOR nX := 1 to Len(aAutoErro)
	cRet += aAutoErro[nX]+CHR(13)+CHR(10)
NEXT nX
RETURN cRet
