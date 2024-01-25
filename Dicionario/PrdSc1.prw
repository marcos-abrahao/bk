#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} PrdSc1
Sugerir ultimo valor digitado previsto na licitação (validação C1_PRODUTO)

@Return  .T.
@author Marcos Bispo Abrahão
@since 13/06/2019
@version P12
/*/



User Function PrdSc1()
Local aArea1   := GetArea()
Local nXXLCVAL := M->C1_XXLCVAL

IF EMPTY(M->C1_XXLCVAL) // .AND. nOpcx = 1
   nXXLCVAL := u_GPrdSc1(M->C1_PRODUTO,cCC,nXXLCVAL)
EndIf

M->C1_XXLCVAL := nXXLCVAL
M->C1_XXLCTOT := nXXLCVAL * M->C1_QUANT

RestArea(aArea1)

Return .T.

