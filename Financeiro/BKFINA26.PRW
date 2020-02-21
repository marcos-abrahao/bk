
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINA26
Grupo Financeiro Produto BK   
@Return
@author Marcos Bispo Abrahão
@since 20/02/2020
@version P12
/*/
//-------------------------------------------------------------------

User Function BKFINA26()
AxCadastro("SZU","Grupo Financeiro - Produto "+ALLTRIM(SM0->M0_NOME))
Return Nil
