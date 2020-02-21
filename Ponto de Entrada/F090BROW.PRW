
/*/{Protheus.doc} F090BROW
    Alterar ordem inicial do browse de Baixas Automáticas a Pagar
    @type  Function
    @author Marcos
    @since 19/02/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function F090BROW()

SE2->(DBORDERNICKNAME("E2_VALOR"))
  
Return Nil