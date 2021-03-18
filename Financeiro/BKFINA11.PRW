#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKFINA11()
BK - Cadastro Codigo Fluxo de Caixa

@author Marcos B. Abrahão
@since 02/02/2012
@version P12
@return Nil
/*/

User Function BKFINA11()
AxCadastro("SZE","Cadastro Codigo Fluxo de Caixa "+FWEmpName(cEmpAnt))
Return Nil
