#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} F050MCP
BK - Ponto de Entrada para liberar altera��o de campos nos t�tulos a pagar

@Return
@author Marcos Bispo Abrah�o
@since  19/05/20
@version P12
/*/

User Function F050MCP()
Local aCampos := PARAMIXB

IF __cUserId $ u_GerFin() // Gerente Financeiro
    AADD(aCampos,"E2_VENCTO")
    AADD(aCampos,"E2_VENCREA")     
Endif

//28/01/2022 - 12.1.33
AADD(aCampos,"E2_VALOR")     

Return aCampos 
