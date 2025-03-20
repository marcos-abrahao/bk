
/*/{Protheus.doc} SD1140I
BK - Ponto de Entrada: Carrega valor Descr. Produto e Descr. Centro de Custo na Pre-Nota de Entrada
@Return
@author Adilson do Prado
@since 21/05/2013
@version P12
/*/

User Function SD1140I()
Local aAreaSD1 := SD1->(GetArea())

If RecLock("SD1",.f.)
	//If Empty(SD1->D1_XXHIST) .OR. VALTYPE("D1_XXHIST") <> "C"
	//	SD1->D1_XXHIST := " "
	//	M->D1_XXHIST := " "
	//EndIf
	SD1->D1_XXDESCP := Posicione("SB1",1,Xfilial("SB1")+SD1->D1_COD,"B1_DESC")
	SD1->D1_XXDCC 	:= Posicione("CTT",1,xFilial("CTT")+SD1->D1_CC,"CTT_DESC01")
	MsUnlock()
Endif


RestArea(aAreaSD1)
Return .t.

