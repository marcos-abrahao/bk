#include "rwmake.ch"
#include "protheus.ch"

// LP530BXD - Conta Débito baixas a pagar

User Function LP530BXD()
Local cCta := "21101002"
Local cTipBk := TRIM(SE2->E2_XXTIPBK)
Local cTipoPes := ""

If EMPTY(SE2->E2_XXTIPBK)
    If !EMPTY(SA2->A2_CONTA) 
       cCta := SA2->A2_CONTA
    Else
       cCta := "CTAFORNECEDOR"
    EndIf
Else
    Do Case
        Case cTipBk == "LAS" // adto salario
            cCta := "11301001"
        Case cTipBk == "CXA" // liberação caixa fixo
            cCta := "11301002"
        Case cTipBk == "SOL" // adto viagem
            cCta := "11301002"
        Case cTipBk == "HOS" // hospedagem
            cCta := "11301002"
        Case cTipBk == "LAD" // Adto fornecedor
            cCta := "11301003"
        Case cTipBk == "LPM" .OR. cTipBk == "COM" // salario a pagar ou Comissão
            cCta := "21301001"
            If !EMPTY(SE2->E2_XXCTRID)
                cTipoPes := RetPesZ2(SE2->E2_XXCTRID)
            Endif
            If cTipoPes == "RPA"
                cCta := "21301012"
            ElseIf "PJ" $ UPPER(SE2->E2_NUMBCO) .OR. "PAG" $ UPPER(SE2->E2_NUMBCO)
                cCta := "21101001"
            EndIf
        Case cTipBk == "LFE" // provisão férias
            cCta := "21301002"
        Case cTipBk == "LRC" // indenizações a pagar
            cCta := "21301007"
        Case cTipBk == "PEN" // pensões a pagar
            cCta := "21301010"
        Case cTipBk == "LD1" // adto 13 salario
            cCta := "11301004"
    EndCase
EndIf
Return(cCta)


// Buscar tipo de Pessoa no primeiro registro do SZ2 - 26/01/21
Static Function RetPesZ2(cCtrId)
Local aArea     := GetArea()
Local cTipoPes  := ""

dbSelectArea("SZ2")
If dbSeek(xFilial("SZ2")+cCtrId,.F.)
    cTipoPes := SZ2->Z2_TIPOPES
EndIf

RestArea(aArea)
Return cTipoPes
