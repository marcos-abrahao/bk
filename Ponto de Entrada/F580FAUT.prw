#Include 'Protheus.ch'

/*/{Protheus.doc} F580FAUT
	BK - O ponto de entrada F580FAUT sera utilizado para que se informe 
	     um filtro que sera executado na execucao da liberacao automatica
	@type  Function
	@author Adilso do Prado
	@since 28/07/15
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

User Function F580FAUT() 
Local cFiltro := PARAMIXB[1]
Local cGerFin := ALLTRIM(SuperGetMV("MV_XXGFIN", .T., "000011/000194/000016"))

If !__cUserId $ cGerFin .AND. !__cUserId $ "000000/000012"
	cFiltro += " AND E2_TIPO <> 'PA'"
ENDIF

Return(cFiltro)
