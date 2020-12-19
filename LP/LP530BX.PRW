#include "rwmake.ch"
#include "protheus.ch"

// LP530BXD - Conta Débito baixas a pagar

User Function LP530BXD()
Local cCta := "21101002"
Local cTipBk := TRIM(SE2->E2_XXTIPBK)

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
        Case cTipBk == "LPM" // salario a pagar
            cCta := "21301001"
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
