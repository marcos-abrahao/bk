#Include 'Protheus.ch'

/*/{Protheus.doc} F580FAUT
	BK - O ponto de entrada F580FAUT sera utilizado para que se informe 
	     um filtro que sera executado na execucao da liberacao automatica
	@type  Function
	@author Adilson do Prado
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

If !__cUserId $ u_GerFin() .AND. !__cUserId $ "000000/000012"
	cFiltro += " AND E2_TIPO <> 'PA'"
ENDIF

Return(cFiltro)
