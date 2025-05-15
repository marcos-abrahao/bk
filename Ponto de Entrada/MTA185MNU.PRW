#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} A440BUT
BK - Ponto de Entrada para incluir botão na enchoice da liberação do pedido de venda
@Return
@author Marcos Bispo Abrahão
@Applicant Roberta Dionisio / Jacksfran
@since 12/05/25
@version P12
/*/

User Function MTA185MNU()

If Type( "aRotina" ) == "A"
    Aadd( aRotina, { 'Termo Barcas Rio', 'U_BKESTR10', 0, 6, 0, Nil } )
EndIf

Return Nil
