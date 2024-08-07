
/*/{Protheus.doc} F090BROW
    Alterar ordem inicial do browse de Baixas Autom�ticas a Pagar
    @type  Function
    @author Marcos
    @since 19/02/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    @since 12/01/2021
    /*/
User Function F090BROW()

SE2->(DBORDERNICKNAME("E2_VALOR"))
  
Return Nil

// N�o filtrar titulos em bordero quando selecionar portador - Andresa 17/07/2024
User Function F090QFIL()

    Local cFiltro    := ParamIXB[1] //Filtro padr�o
    Local nTipoBx    := ParamIXB[2] //Tipo de Baixa
    Local cRetFiltro := cFiltro //Novo Filtro
 
    If (nTipoBx == 1) //T�tulos
        cRetFiltro := STRTRAN(cFiltro,"E2_NUMBOR = '" + Space(TamSx3("E2_NUMBOR")[1]) + "' AND ","")
    //Else //Border�s
    EndIf

    SE2->(DBORDERNICKNAME("E2_VALOR"))

Return cRetFiltro 





// Remover tipo PA das baixas - Andresa 17/07/2024
User Function F090TIPO()

Local cTipo    := ParamIXB[1] //Filtro padr�o
Local cTipoRet := cTipo += "/PA "

Return cTipoRet
