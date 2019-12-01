#include "rwmake.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MTASF2 - BK
Gravar campos adicionais no SF2

@Return
@author Marcos Bispo Abrahão
@since 21/08/2019
@version P11/P12
/*/
//-------------------------------------------------------------------


User Function MTASF2()

IF !EMPTY(SC5->C5_XXRETC)
	// Gravar o percentual e valor da Retenção Contratual
	SF2->F2_XXRETC  := SC5->C5_XXRETC
	SF2->F2_XXVRETC := ROUND(SC5->C5_XXRETC * SF2->F2_VALBRUT / 100,2) 
ENDIF

Return Nil

