
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINA26
Grupo Financeiro Produto BK   
@Return
@author Marcos Bispo Abrah�o
@since 20/02/2020
@version P12
/*/
//-------------------------------------------------------------------

User Function BKFINA26()
u_MsgLog("BKFINA26")
AxCadastro("SZU","Grupo Financeiro - Produto "+FWEmpName(cEmpAnt))
Return Nil
