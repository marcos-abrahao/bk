#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"       


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MTA097MNUบAutor  ณAdilson do Prado    บ Data ณ  08/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Libera็ใo de Documentos Gestใo de Compras                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BK                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function MTA097MNU() 

aRotina := {}

aRotina	:= {{OemToAnsi("Pesquisar"),"Ma097Pesq",   0 , 1, 0, .F.},; //"Pesquisar"
			{OemToAnsi("Consulta pedido"),"A097Visual",  0 , 2, 0, nil},; //"Consulta pedido"
			{OemToAnsi("Consulta Saldos"),"A097Consulta",0 , 2, 0, nil},; //"Consulta Saldos"
			{OemToAnsi("Liberar"),"U_BKCOMA04",  0 , 4, 0, nil},; //"Liberar"
			{OemToAnsi("Estornar"),"A097Estorna", 0 , 4, 0, nil},; //"Estornar"
			{OemToAnsi("Superior"),"A097Superi",  0 , 4, 0, nil},; //"Superior"
			{OemToAnsi("Transf. para Superior"),"A097Transf",  0 , 4, 0, nil},; //"Transf. para Superior"
			{OemToAnsi("Ausencia Temporaria"),"A097Ausente", 0 , 3, 0, nil},; //"Ausencia Temporaria"
			{OemToAnsi("Legenda"),"A097Legend",  0 , 2, 0, .F.}}  //"Legenda"	

			//{OemToAnsi("Liberar"),"A097Libera",  0 , 4, 0, nil},; //"Liberar"



Return Nil


