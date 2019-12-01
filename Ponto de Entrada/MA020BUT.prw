#INCLUDE "PROTHEUS.CH"

User Function ma020but()

Local _aMyBtn := {}

//aButtons[x][1] = String com o nome do bitmap padrao incluido na dll padrao do SIGA.
//aButtons[x][2] = Bloco de codigo com a fun‡ao a executar (pode ser um execblock, fun‡ao SIGA,etc.).
//aButtons[x][3] = Texto a ser exibido na legenda do Botao.
//aButtons[x][4] = Texto a ser exibido abaixo do bitmap.

Aadd(_aMyBtn, { "WEB", {|| U_xConsCNPJ( M->A2_CGC ) }, OemToAnsi("Consultar CNPJ junto � Receita Federal"), "CNPJ"} )
//AADD( aRotina, {OemToAnsi("Consulta CNPJ"), "U_xConsCNPJ( M->A1_CGC )", 0, 4 } )

Return _aMyBtn


// User Function xConsCNPJ( cCNPJ ) SE ENCONTRA NO FONTE MA030BUT.PRW
