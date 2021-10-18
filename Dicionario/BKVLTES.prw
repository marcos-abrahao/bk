/*/{Protheus.doc} BKVlTes
BK - Validação TES
@Return
@author Marcos Bispo Abrahão
@since  27/09/21 
@version P12
/*/

User Function BKVlTes()
Local lRet := .T.

If SA2->A2_TPJ == '3'
    If SF4->F4_CSTPIS == '50'
        If !IsBlind()
            MsgStop("Não utilize TES com crédito PIS/COFINS para MEI","BKVlTes")
        EndIf
        lRet := .F.
    Endif
Endif

Return lRet
