
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MTA110OK  
    LOCALIZAÇÃO : Function A110INCLUI - Função da Solicitação de Compras responsavel pela inclusão, e cópia das SCs.
    EM QUE PONTO : Após a montagem da dialog da Solicitação de compras. É acionado quando o usuario clica nos botões OK (Ctrl O) ou CANCELAR (Ctrl X) na inclusão de uma SC, deve ser utilizado para validar se a SC deve ser incluída  'retorno .T.' ou não 'retorno .F.' , após a confirmação do sistema.

    @type  Function
    @author Marcos Bispo Abrahão
    @since 02/04/2025
    @version 12.2410
    @param PARAMIXB[1] = NUMERO DA SOLICITAÇÃO ; PARAMIXB[2] = NOME DO SOLICITANTE ; PARAMIXB[3] = DATA DA SOLICITAÇÃO
    @return MTA110OK - Valida inclusão da SC ( < PARAMIXB> ) --> lRet
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function xMTA110OK
Local lRet := .T.

/*
If EMPTY(SC1->C1_XXJUST) .AND. EMPTY(cXXJUST)
   u_MsgLog("MTA110OK","Justificativa deve ser preenchida","E")
   lRet := .F.
EndIf
*/
Return lRet
