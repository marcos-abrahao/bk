#include "protheus.ch"

/*/{Protheus.doc} MT100LOK
    Ponto-de-Entrada: MT100LOK - Alterações de Itens da NF de Despesas de Importação
    Localização : Function A119LinOk e A119TudOK - Função de Validação ( linha OK da Getdados) para Inclusão/Alteração do item da NF de Despesas de Importação e A103LinOk - Função de Validação da LinhaOk.Em que Ponto: No final das validações após a confirmação da inclusão ou alteração da linha, antes da gravação da NF de Despesas de Importação.
    Finalidade: Permite alterar itens da NF de Despesas de Importação.
    @type  Function
    @author Marcos Bispo Abrahão
    @since 18/10/2021
    @version 12.1.25
    /*/

User Function MT100LOK()
Local lExecuta  := ParamIxb[1] // Validações do usuário para inclusão ou alteração do item na NF de Despesas de Importação
Local nPosTES   := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_TES"})
Local nPosPrd   := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_COD"})
Local aAreaSF4	:= SF4->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local cTESn     := aCols[n][nPosTES]
Local cProdn    := aCols[n][nPosPrd]

If !Empty(cTESn)
    If SF4->(dbSeek(xFilial("SF4")+cTESn))
        If SA2->A2_TPJ == '3'
            If SF4->F4_CSTPIS == '50'
                u_MsgLog("MT100LOK","Não utilize TES com crédito PIS/COFINS para MEI","E")
                lExecuta := .F.
            Endif
        Endif
        If SB1->(dbSeek(xFilial("SB1")+cProdn))
            If SB1->B1_TIPO = "AI" .AND. SF4->F4_ATUATF <> "S"
                u_MsgLog("MT100LOK","Utilize a TES correta para produtos de Ativo Imobilizado","E")
                lExecuta := .F.
            EndIf
        EndIf
    EndIf

EndIf

SF4->(RestArea(aAreaSF4))
SB1->(RestArea(aAreaSB1))

Return (lExecuta)
