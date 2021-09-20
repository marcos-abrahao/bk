#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MS520VLD
MS520VLD - Ponto de entrada para validar exclusão de NFs de saída
@Return
@author Marcos Bispo Abrahão
@since 19/09/21
@version P12.1.25
/*/

User Function MS520VLD()
Local lRet := .T.

If MONTH(SF2->F2_EMISSAO) <> MONTH(dDataBase) .OR. YEAR(SF2->F2_EMISSAO) <> YEAR(dDataBase)
    lRet := .F.
    Aviso("MS520VLD","Exclusão de NF somente permitida dentro do mes de emissão",{"Ok"})
EndIf

Return lRet
