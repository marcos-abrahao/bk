#include "rwmake.ch"
#include "protheus.ch"

/*/{Protheus.doc} XCADSZM()
BK - LP530BXD - Conta D�bito baixas a pagar
@author Marcos B. Abrah�o
@since 
@version P12
@return Nil
/*/


Static aCodRH := u_BkCodRH()

User Function LP530BXD()
Local cCta      := "21101002"
Local cTipBk    := TRIM(SE2->E2_XXTIPBK)
Local cTipoPes  := ""
Local nCta      := 0

If EMPTY(SE2->E2_XXTIPBK)
    If !EMPTY(SA2->A2_CONTA) 
       cCta := SA2->A2_CONTA
    Else
       cCta := "CTAFORNECEDOR"
    EndIf
Else
    nCta := AsCan(aCodRH,{ |x| x[1] == cTipBK })
    If nCta > 0
        cCta := aCodRh[nCta,3]
    EndIf
    If cTipBk == "LPM" .OR. cTipBk == "COM" // salario a pagar ou Comiss�o
        cCta := "21301001"
        If !EMPTY(SE2->E2_XXCTRID)
            cTipoPes := RetPesZ2(SE2->E2_XXCTRID)
        Endif
        If cTipoPes == "RPA"
            cCta := "21301012"
        ElseIf "PJ" $ UPPER(SE2->E2_NUMBCO) .OR. "PAG" $ UPPER(SE2->E2_NUMBCO)
            cCta := "21101001"
        EndIf
    EndIf
    /*
    Do Case
        Case cTipBk == "LAS" // adto salario
            cCta := "11301001"
        Case cTipBk == "CXA" // libera��o caixa fixo
            cCta := "11301002"
        Case cTipBk == "SOL" // adto viagem
            cCta := "11301002"
        Case cTipBk == "HOS" // hospedagem
            cCta := "11301002"
        Case cTipBk == "LAD" // Adto fornecedor
            cCta := "11301003"
        Case cTipBk == "LPM" .OR. cTipBk == "COM" // salario a pagar ou Comiss�o
            cCta := "21301001"
            If !EMPTY(SE2->E2_XXCTRID)
                cTipoPes := RetPesZ2(SE2->E2_XXCTRID)
            Endif
            If cTipoPes == "RPA"
                cCta := "21301012"
            ElseIf "PJ" $ UPPER(SE2->E2_NUMBCO) .OR. "PAG" $ UPPER(SE2->E2_NUMBCO)
                cCta := "21101001"
            EndIf
        Case cTipBk == "LFE" // provis�o f�rias
            cCta := "11301005" // Era "21301002" at� 18/03/2021
        Case cTipBk == "LRC" // indeniza��es a pagar
            cCta := "21301007"
        Case cTipBk == "PEN" // pens�es a pagar
            cCta := "21301010"
        Case cTipBk == "LD1" // adto 13 salario
            cCta := "11301004"
        Case cTipBk == "MFG" // Multa 40% FGTS
            cCta := "31201053"
        Case cTipBk == "VA" // Vale Alimenta��o
            cCta := "31201101"
        Case cTipBk == "VR" // Vale Refei��o
            cCta := "31201045"
        Case cTipBk == "VT" // Vale Transporte
            cCta := "31201046"
        Case cTipBk == "EXM" // Exames Adm. e Dem.
            cCta := "34202090"
        Case cTipBk == "REE" // Reemb. Desc. Indev.
            cCta := "31201092"
    EndCase
    */
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
