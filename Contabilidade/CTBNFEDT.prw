// Exclusivo para Barcas Rio
// 26/03/2025
// Roberta Dionisio - RD SYSTEMS
// PONTO DE ENTRADA CTBNFEDT - Escolhe data de lan�amento, ser� utilizada a Data de Emiss�o das Notas Fiscais de Entrada e n�o Data de Digita��o
//https://tdn.totvs.com/pages/releaseview.action?pageId=6085677

#INCLUDE "PROTHEUS.CH"

User Function CTBNFEDT
Local lRet:= .F.
If cEmpAnt == "20" // Barcas
    lRet:= .T.
EndIf
Return lRet

