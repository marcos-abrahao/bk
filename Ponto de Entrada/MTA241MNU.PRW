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
    AAdd( aRotina, { 'Conhecimento'    ,'U_BKDocSd3', 0, 4, 0, Nil } )
EndIf

Return Nil

User Function BKDocSd3()

//If VAL(SD3->D3_ITEM) < 2
    MsDocument('SD3', SD3->(recno()), 4)
//Else
//    u_MsgLog("BKDocSd3","Posicione no item 1 para acessar ou anexar documentos","W")
//EndIf

Return Nil
