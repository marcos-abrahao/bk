#include "protheus.ch"

/*/{Protheus.doc} MT100LOK
    Ponto-de-Entrada: MT100LOK - Altera��es de Itens da NF de Despesas de Importa��o
    Localiza��o : Function A119LinOk e A119TudOK - Fun��o de Valida��o ( linha OK da Getdados) para Inclus�o/Altera��o do item da NF de Despesas de Importa��o e A103LinOk - Fun��o de Valida��o da LinhaOk.Em que Ponto: No final das valida��es ap�s a confirma��o da inclus�o ou altera��o da linha, antes da grava��o da NF de Despesas de Importa��o.
    Finalidade: Permite alterar itens da NF de Despesas de Importa��o.
    @type  Function
    @author Marcos Bispo Abrah�o
    @since 18/10/2021
    @version 12.1.25
    /*/

User Function MT100LOK()
Local lExecuta  := ParamIxb[1] // Valida��es do usu�rio para inclus�o ou altera��o do item na NF de Despesas de Importa��o
Local nPosTES   := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_TES"})
Local nPosPrd   := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_COD"})
Local nPosCC    := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_CC"})
//Local nPosXH    := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_XXHIST"})

Local aAreaSF4	:= SF4->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local cTESn     := aCols[n][nPosTES]
Local cProdn    := aCols[n][nPosPrd]
Local cCC       := aCols[n][nPosCC]
Local cCCCum    := u_BKCCCum()
//Local cXHist    := aCols[n][nPosXH]

//If Empty(cXHist)
//    aCols[n][nPosXH] := ""
//EndIf

If !Empty(cTESn)
    If SF4->(dbSeek(xFilial("SF4")+cTESn))
        If SA2->A2_TPJ == '3'
            If SF4->F4_CSTPIS == '50'
                u_MsgLog("MT100LOK","N�o utilize TES com cr�dito PIS/COFINS para MEI","E")
                lExecuta := .F.
            Endif
        Endif
        If SB1->(dbSeek(xFilial("SB1")+cProdn))
            If SB1->B1_TIPO = "AI" .AND. SF4->F4_ATUATF <> "S"
                u_MsgLog("MT100LOK","Utilize a TES correta para produtos de Ativo Imobilizado","E")
                lExecuta := .F.
            EndIf
        EndIf

        // Regime Cumulativo
        If ALLTRIM(cCC) $ cCCCum .AND. SF4->F4_CSTPIS == '50'
            u_MsgLog("MT100LOK","Utilize a TES correta para contratos do regime cumulativo: 104->101/105->126/107->102/109->127/117->128/122->129","E")
        EndIf

    EndIf

EndIf

SF4->(RestArea(aAreaSF4))
SB1->(RestArea(aAreaSB1))

Return (lExecuta)
