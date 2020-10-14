/*/{Protheus.doc} CTA120MNU
BK - Localizado na rotina de Medição do Contrato, este ponto de entrada tem por finalidade adicionar botões ao menu

@Return
@author Adilson do Prado
@since 02/12/14
@version P11/P12
/*/

User function CNT121BT()
AADD(aRotina,{OemToAnsi("Consulta Pedido"), "U_BKFATR5C", 0, 2 })
Return

User function CTA120MNU()

//Apontar para medicao de servico 
//Local cRtMed := aRotina[3,2]

aRotina[3,2] := "CN120Serv"
aRotina[3,6] := .F.

AADD(aRotina,{OemToAnsi("Consulta Pedido"), "U_BKFATR5C", 0, 2 })

Return
