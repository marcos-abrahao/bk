#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} F050MCP
BK - Ponto de Entrada para liberar alteração de campos nos títulos a pagar

@Return
@author Marcos Bispo Abrahão
@since  19/05/20
@version P12
/*/

User Function F050MCP()
Local aCampos := PARAMIXB

//If Alltrim(SE2->E2_TIPO) = "NF"
IF __cUserId $ "000000/000012/000016" // Administrador / Xavier / Diego Oliveira
    AADD(aCampos,"E2_VENCTO")
    AADD(aCampos,"E2_VENCREA")     
Endif

//28/01/2022 - 12.1.33
AADD(aCampos,"E2_VALOR")     

Return aCampos 
