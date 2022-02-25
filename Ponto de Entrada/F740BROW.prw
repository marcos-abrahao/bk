#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ F740BROW บAutor  ณAdilson do Prado    บ Data ณ  15/01/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada para criar op็๕es na tela de Func๕es      บฑฑ
ฑฑบ          ณ Contas a Receber                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BK                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function F740BROW() 
           
AADD( aRotina, {OemToAnsi("Baixa Portal Transpar๊ncia "+FWEmpName(cEmpAnt)),   "U_BKFINA16", 0, 4 } )
AADD( aRotina, {OemToAnsi("Baixa Portal Petrobras "+FWEmpName(cEmpAnt)),   "U_BKFINA23", 0, 4 } )
AADD( aRotina, {OemToAnsi("Alterar data de Antecipa็ใo "+FWEmpName(cEmpAnt)),   "U_BKFINA24", 0, 4 } )
AADD( aRotina, {OemToAnsi("Incluir NDC - Nota de Debito "+FWEmpName(cEmpAnt)),  "U_FN40INCMNU", 0, 4 } )
AADD( aRotina, {OemToAnsi("Imprimir NDC - Nota de Debito "+FWEmpName(cEmpAnt)),  "U_BKFINR24", 0, 4 } )
AADD( aRotina, {OemToAnsi("Anexar Arq. "+FWEmpName(cEmpAnt)),   "U_BKANXA01('1','SE1')", 0, 4 } )
AADD( aRotina, {OemToAnsi("Abrir Anexos "+FWEmpName(cEmpAnt)),  "U_BKANXA02('1','SE1')", 0, 4 } )

Return Nil
