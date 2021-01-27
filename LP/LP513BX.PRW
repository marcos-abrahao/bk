#include "rwmake.ch"
#include "protheus.ch"

// LP513BX - INCLUSAO PAGAMENTO ANTECIPADO
  
User Function LP513BX()
Local lOk    := .F.
Local cTIPOPES  := ""

cTIPOPES  := Posicione("SZ2",3,xFilial("SZ2")+SM0->M0_CODIGO+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA,"Z2_TIPOPES")

lOK := ALLTRIM(cTIPOPES) $ "CLA/AC"

Return(lOk)
