#include "rwmake.ch"

/*/{Protheus.doc} MT140ROT
BK - Ponto de Entrada para criar botões na pre-nota
@Return
@author Marcos Bispo Abrahão
@since 24/11/2009
@version P12
/*/

User Function MT140ROT()
Local aRotY	:= {}

// Menu Facilitador de digitação de Pré-Notas
AADD(aRotY,{OemToAnsi("Marcar como Modelo"), "U_BKCOMA17", 0, 2 })
AADD(aRotY,{OemToAnsi("Incluir via Modelo"), "U_BKCOMA16", 0, 3 })
AADD( aRotina, {OemToAnsi("Facilitador", aRotY, 0, 4 } )

AADD( aRotina, {OemToAnsi("Pesquisar Itens/NF"), "U_BKCOMC01", 0, 1 } )
AADD( aRotina, {OemToAnsi("Localizar NF"), "U_BKCOMC02", 0, 1 } )
AADD( aRotina, {OemToAnsi("Benefícios BK"), "U_BKCOMA03", 0, 3 } )
AADD( aRotina, {OemToAnsi("Dados Pgto BK"), "U_AltFPgto", 0, 4 } )
AADD( aRotina, {OemToAnsi("Validar Token BK"), "U_BKCOMA10", 0, 4 } )
AADD( aRotina, {OemToAnsi("Reavaliar Fornecedor"), "U_RAvalForn", 0, 4 } )
Return Nil


