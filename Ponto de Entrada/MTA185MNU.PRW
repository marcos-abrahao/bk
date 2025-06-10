#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MTA185MNU
BK - Ponto de Entrada para imprimir termo de retirada de materiais
@Return
@author Marcos Bispo Abrahão
@Applicant Roberta Dionisio / Jacksfran
@since 12/05/25
@version P12
/*/

User Function MTA185MNU()

If Type( "aRotina" ) == "A"
    Aadd( aRotina, { 'Termo Barcas Rio', 'U_BKESTR10',  0, 6, 0, Nil } )
    //AAdd( aRotina, { 'Anexar Documentos', 'U_BKDocSCP', 0, 4, 0, Nil } )
EndIf

Return Nil


/*
User Function BKDocSCP()

MsDocument('SCP', SCP->(recno()), 4)

Return Nil
*/
