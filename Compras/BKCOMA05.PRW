#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} BKCOMA05()
BK - Cadastro Sub Grupo Produtos Modulo Compras

@author Adilson do Prado
@since 30/04/2013
@version P12
@return Nil
/*/

User Function BKCOMA05()
AxCadastro("SZI","Cadastro Sub Grupos Produtos - "+FWEmpName(cEmpAnt))
Return Nil
