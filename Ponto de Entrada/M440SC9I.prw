#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} M440SC9I
BK - Ponto de Entrada - gravação de dados na liberação do pedido de venda 
@Return
@author  Marcos Bispo Abrahão
@since 15/07/20
@version P12
/*/
User Function M440SC9I()

RecLock("SC9",.F.)
IF EMPTY(SC5->C5_XXTPNF)
   SC9->C9_XXORPED := "N" // N=Normal;A=Avulsa
ELSE
   SC9->C9_XXORPED := SC5->C5_XXTPNF // N=Normal;A=Avulsa
ENDIF

SC9->(MsUnlock())


Return Nil
