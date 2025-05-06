// Exclusivo para Barcas Rio
// 26/03/2025
// Roberta Dionisio - RD SYSTEMS
// PONTO DE ENTRADA CTBNFEDT - Escolhe data de lançamento, será utilizada a Data de Emissão das Notas Fiscais de Entrada e não Data de Digitação
//https://tdn.totvs.com/pages/releaseview.action?pageId=6085677

#INCLUDE "PROTHEUS.CH"

User Function CTBNFEDT
Local lRet:= .F.
If cEmpAnt == "20" // Barcas
    lRet:= .T.
EndIf
Return lRet

