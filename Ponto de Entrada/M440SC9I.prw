#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} M440SC9I
BK - Ponto de Entrada - gravação de dados na liberação do pedido de venda 
@Return
@author  Marcos Bispo Abrahão
@since 
@version P12
/*/
User Function M440SC9I()

RecLock("SC9",.F.)
IF !EMPTY(SC5->C5_MDCONTR)
   SC9->C9_XXORPED := "C" // Contrato

   //Gravar o numero do contrato na liberação dos pedidos de venda
   //SC9->C9_XXCONTR := SC5->C5_MDCONTR
   //SC9->C9_XXDESC  := Posicione("CTT",1,xFilial("CTT")+SC5->C5_MDCONTR,"CTT_DESC01")
ELSE
   SC9->C9_XXORPED := "A" // Avulso
ENDIF

SC9->(MsUnlock())

Return Nil
