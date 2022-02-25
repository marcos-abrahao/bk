#include "rwmake.ch"
#include "protheus.ch"

/*/{Protheus.doc} XCADSZM()
BK - LP513BX - INCLUSAO PAGAMENTO ANTECIPADO
@author Marcos B. Abrahão
@since 
@version P12
@return Nil
/*/

User Function LP513BX()
Local lOk    := .F.
Local cTIPOPES  := ""

cTIPOPES  := Posicione("SZ2",3,xFilial("SZ2")+SM0->M0_CODIGO+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA,"Z2_TIPOPES")

lOK := ALLTRIM(cTIPOPES) $ "CLA/AC"

Return(lOk)
