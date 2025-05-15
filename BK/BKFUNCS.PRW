#include "TOTVS.CH"
#include "PROTHEUS.CH"

/*/{Protheus.doc} BKFUNCS
BK - Funções diversas

@Return
@author Marcos B. Abrahão
@since 15/05/2025
@version P12
/*/

// Retorna o Percentual em caracteres sem .00 no final
User Function PicPer(nAliq,nT,nD)
Local cAliq := ALLTRIM(STR(nAliq,nT,nD))
If ("."+Replicate("0",nD)) $ cAliq
	cAliq := STRTRAN(cAliq,"."+Replicate("0",nD),"")
EndIf
Return cAliq

