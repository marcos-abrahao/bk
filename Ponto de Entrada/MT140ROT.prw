#include "rwmake.ch"

/*/{Protheus.doc} MT140ROT
BK - Ponto de Entrada para criar bot�es na pre-nota
@Return
@author Marcos Bispo Abrah�o
@since 24/11/2009
@version P12
/*/

User Function MT140ROT()
Local aRotY	:= {}

// Menu Facilitador de digita��o de Pr�-Notas
AADD(aRotY,{("Incluir Doc via Modelo"), "U_BKCOMA16('P')", 0, 3 })
AADD(aRotY,{("Marcar Doc como Modelo"), "U_BKCOMP16('P')", 0, 2 })
AADD( aRotina, {("Facilitador"), aRotY, 0, 4 } )

AADD( aRotina, {("Pesquisar Itens/NF"), "U_BKCOMC01", 0, 1 } )
AADD( aRotina, {("Localizar NF"), "U_BKCOMC02", 0, 1 } )
AADD( aRotina, {("Benef�cios BK"), "U_BKCOMA03", 0, 3 } )
AADD( aRotina, {("Dados Pgto BK"), "U_AltFPgto", 0, 4 } )
AADD( aRotina, {("Validar Token BK"), "U_BKCOMA10", 0, 4 } )
AADD( aRotina, {("Reavaliar Fornecedor"), "U_RAvalForn", 0, 4 } )
AADD( aRotina, {("Doc PIS/COF/IRPJ/FGTS/INSS/IRRF"), "U_BKCOMA13", 0, 1 } )

Return Nil


