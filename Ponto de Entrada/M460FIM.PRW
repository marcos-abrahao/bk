#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} M460FIM
Ponto de entrada para gravar valor de Retenção Contratual no SE1 - BK

@Return
@author Marcos Bispo Abrahão
@since 27/08/2019
@version P11/P12
/*/
//-------------------------------------------------------------------

USER FUNCTION M460FIM()
Local aArea     := GetArea()
Local aAreaSE1  := SE1->(GetArea())
Local cE1Tipo   := ""

IF SF2->F2_XXVRETC  > 0
	aAreaSE1  := SE1->(GetArea()) 
	cE1Tipo   := Left(MVNOTAFIS, TamSX3("E1_TIPO")[1]) 
	
	SE1->(dbSetOrder(2)) // SE1->(dbSetOrder(RETORDEM("SE1","E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO")))             
	
 	If SE1->(MsSeek(xFilial("SE1") + SF2->(F2_CLIENTE) + SF2->(F2_LOJA) + SF2->(F2_SERIE) + SF2->(F2_DOC) + SPACE(LEN(SE1->E1_PARCELA))+cE1Tipo,.T.))     
		SE1->(RECLOCK("SE1",.F.))
		SE1->(E1_XXVRETC) 	:= SF2->F2_XXVRETC
		SE1->(MSUNLOCK())
	ENDIF 
	SE1->(RestArea(aAreaSE1))
ENDIF

RestArea(aArea)

RETURN NIL
