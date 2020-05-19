#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} F050MCP
BK - Ponto de Entrada para liberar campos de datas de vencimento nos títulos apagar

@Return
@author Marcos Bispo Abrahão
@since  19/05/20
@version P12
/*/

User Function F050MCP()
Local aCampos := PARAMIXB

//If Alltrim(SE2->E2_TIPO) = "NF"
IF __cUserId $ "000000/000012" // Administrador / Xavier
    AADD(aCampos,"E2_VENCTO")
    AADD(aCampos,"E2_VENCREA")     
Endif

Return aCampos 