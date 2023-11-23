#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} M440SC9I
BK - Ponto de Entrada - gravação de dados na liberação do pedido de venda 
@Return
@author  Marcos Bispo Abrahão
@since 15/07/20
@version P12
/*/
User Function M440SC9I()
Local aArea := GetArea()
RecLock("SC9",.F.)
IF EMPTY(SC5->C5_XXTPNF)
   SC9->C9_XXORPED := "N"
ELSE
   SC9->C9_XXORPED := SC5->C5_XXTPNF // N=Normal;B=Balcão;F=Filial
ENDIF
SC9->C9_XXRM := SC5->C5_XXRM

// 23/11/23 - Gravar motivo da planilha
IF !EMPTY(SC5->C5_MDCONTR)
   dbSelectArea("CNA")
   dbSetOrder(1)
   IF dbSeek(xFilial("CNA")+SC5->C5_MDCONTR+SC5->C5_XXREV+SC5->C5_MDPLANI)
      SC9->C9_XXMOT := CNA_XXMOT
   ENDIF
ELSE
   SC9->C9_XXMOT := PAD("PEDIDO AVULSO "+SC5->C5_ESPECI1+" "+TRIM(SC5->C5_DESCMUN),60)
ENDIF

SC9->(MsUnlock())

RestArea(aArea)

Return Nil
