#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MTA241MNU
BK - Ponto de Entrada para imprimir termo de retirada de materiais
@Return
@author Marcos Bispo Abrahão
@Applicant Roberta Dionisio / Jacksfran
@since 31/05/25
@version P12
/*/

User Function MTA241MNU()

If Type( "aRotina" ) == "A"
    Aadd( aRotina, { 'Termo Barcas Rio', 'U_BKESTR11', 0, 6, 0, Nil } )
EndIf

Return Nil
