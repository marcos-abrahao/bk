#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MC090MNU
MC090MNU - Ponto de Entrada para criar opções no menu da Consulta de NFs de saída
@Return
@author Adilson do Prado
@since 11/06/15
@version P12.1.25
/*/

User Function MC090MNU() 

AADD( aRotina,{OemToAnsi("Inf. do Faturamento "+FWEmpName(cEmpAnt)),"U_BKFATA01", 0, 6 })

Return Nil



