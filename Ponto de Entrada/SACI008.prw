
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} SACI008
BK - Ponto de entrada após a gravação da baixa a receber  - Gravar data de Adiantamento
@Return
@author Marcos Bispo Abrahão
@since 24/02/2022
@version P12
/*/

User Function SACI008()
Local aArea := GetArea()
Local aAreaE1 := SE1->(GetArea())
     
// Gravar data de adiantamento se o título ficou em aberto
If SE1->E1_STATUS == "A" .AND. EMPTY(SE1->E1_XXDTADT)
    If u_IsPetro(SE1->E1_CLIENTE)
        RecLock("SE1", .F.)
        SE1->E1_XXDTADT := SE1->E1_BAIXA
        SE1->(MsUnlock())
    EndIf
EndIf

RestArea(aAreaE1)
RestArea(aArea)

Return Nil 
