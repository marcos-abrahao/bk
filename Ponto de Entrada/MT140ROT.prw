#include "rwmake.ch"

/*/{Protheus.doc} MT140ROT
BK - Ponto de Entrada para criar bot�es na pre-nota
@Return
@author Marcos Bispo Abrah�o
@since 24/11/2009
@version P12
/*/

User Function MT140ROT()
AADD( aRotina, {OemToAnsi("Pesquisar Itens/NF"), "U_BKCOMC01", 0, 1 } )
AADD( aRotina, {OemToAnsi("Localizar NF"), "U_BKCOMC02", 0, 1 } )
AADD( aRotina, {OemToAnsi("Benef�cios BK"), "U_BKCOMA03", 0, 3 } )
AADD( aRotina, {OemToAnsi("Dados Pgto BK"), "U_AltFPgto", 0, 4 } )
AADD( aRotina, {OemToAnsi("Validar Token BK"), "U_BKCOMA10", 0, 4 } )
AADD( aRotina, {OemToAnsi("Reavaliar Fornecedor"), "U_RAvalForn", 0, 4 } )
Return Nil


