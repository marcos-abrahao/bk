#include "rwmake.ch"

/*/{Protheus.doc} MTA410T
    Ponto de Entrada para gravar quem liberou o Pedido de Vendas
    @type  Function
    @author Marcos Bispo Abrahão
    @since 21/03/2020
    @version 1
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function MTA410T()
    
If SC5->C5_LIBEROK == "S"

   RecLock("SC5",.F.)
   SC5->C5_XXULIB := cUserName
   SC5->C5_XXDLIB := Date()
// Gravar o nome do contrato na liberação dos pedidos de venda
// SC5->C5_XXDESC  := Posicione("CTT",1,xFilial("CTT")+SC5->C5_MDCONTR,"CTT_DESC01")
   MsUnlock()
EndIf

Return Nil
