#include "protheus.ch"

/*/{Protheus.doc} MT103PBLQ
    Ponto-de-Entrada: MT103PBLQ - Permitir Doc de Entrada Com Produtos Bloqueados
    @type  Function
    @author Marcos Bispo Abrahão
    @since 14/05/2024
    @version 12.1023
    /*/

User Function MT103PBLQ()
//Local aProd:=PARAMIXB[1]
Local lRet := .F.

If FWIsInCallStack("GERADOCE") .AND. FWIsInCallStack("MATA103")
    lRet:= u_MsgLog("MT103PBLQ","Existem Produtos Bloqueados na Nota Fiscal, substitua-os", "N")
EndIf

Return lRet
