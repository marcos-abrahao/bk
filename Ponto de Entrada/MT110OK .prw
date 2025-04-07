
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MTA110OK  
    LOCALIZA��O : Function A110INCLUI - Fun��o da Solicita��o de Compras responsavel pela inclus�o, e c�pia das SCs.
    EM QUE PONTO : Ap�s a montagem da dialog da Solicita��o de compras. � acionado quando o usuario clica nos bot�es OK (Ctrl O) ou CANCELAR (Ctrl X) na inclus�o de uma SC, deve ser utilizado para validar se a SC deve ser inclu�da  'retorno .T.' ou n�o 'retorno .F.' , ap�s a confirma��o do sistema.

    @type  Function
    @author Marcos Bispo Abrah�o
    @since 02/04/2025
    @version 12.2410
    @param PARAMIXB[1] = NUMERO DA SOLICITA��O ; PARAMIXB[2] = NOME DO SOLICITANTE ; PARAMIXB[3] = DATA DA SOLICITA��O
    @return MTA110OK - Valida inclus�o da SC ( < PARAMIXB> ) --> lRet
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
