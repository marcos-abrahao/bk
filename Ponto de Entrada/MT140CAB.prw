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
Local cMsg := ""

If !u_IsLibDPH(__cUserId)
    If SUBSTR(TIME(),1,2) > '23' .OR. SUBSTR(TIME(),1,2) < '03'
        cMsg := "Não é permitido incluir pré-notas entre 18h e 7h"
        u_MsgLog("MT140CAB",cMsg)
        MsgStop(cMsg,"MT140CAB")
        lRet := .F.
    EndIf
EndIf

Return lRet


