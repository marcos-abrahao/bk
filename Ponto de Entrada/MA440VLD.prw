#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MA440VLD
BK - Ponto de Entrada para visualizar glosas e bonificações no pedido de venda
@Return
@author Adilson do Prado / Marcos Bispo Abrahão
@since 15/09/15 
@version P12
/*/

User Function MA440VLD()
Local aAreaIni  := GetArea()
//Local cAliasCNR := GetNextAlias()
Local lRet := .T.

lRet := U_VerGlosa(.F.)

RestArea(aAreaIni)

Return lRet
