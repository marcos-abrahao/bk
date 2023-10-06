#include "rwmake.ch"

/*/{Protheus.doc} MT140CAB
BK - Ponto de entrada que permite o preenchimento automático dos dados do cabeçalho 
     da pre-nota e define se continua a rotina
     Solicitado por Xavier
@Return
@author Marcos Bispo Abrahão
@since 23/08/2022
@version P12
/*/

User Function MT140CAB()
Local lRet := .T.

If !u_IsLibDPH("MT140CAB",__cUserId)
    lRet := .F.
EndIf

Return lRet


