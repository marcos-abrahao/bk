#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} F740BROW
BK - Ponto de Entrada para criar opções na tela de Funcões Contas a Receber 
@Return
@author Adilson do Prado
@since 15/01/2015
@version P12
/*/

User Function F740BROW() 
           
AADD( aRotina, {OemToAnsi("Baixa Portal Transparência"),   "U_BKFINA16", 0, 4 } )
AADD( aRotina, {OemToAnsi("Baixa Portal Petrobras"),       "U_BKFINA23", 0, 4 } )
AADD( aRotina, {OemToAnsi("Alterar data de Antecipação"),  "U_BKFINA24", 0, 4 } )
AADD( aRotina, {OemToAnsi("ISS Bitrib. indevidamente"),    "U_BKFINA28", 0, 4 } )
AADD( aRotina, {OemToAnsi("Incluir NDC - Nota de Debito"), "U_FN40INCMNU", 0, 4 } )
AADD( aRotina, {OemToAnsi("Imprimir NDC - Nota de Debito"),"U_BKFINR24", 0, 4 } )
AADD( aRotina, {OemToAnsi("Anexar Arq."),   "U_BKANXA01('1','SE1')", 0, 4 } )
AADD( aRotina, {OemToAnsi("Abrir Anexos"),  "U_BKANXA02('1','SE1')", 0, 4 } )

Return Nil
