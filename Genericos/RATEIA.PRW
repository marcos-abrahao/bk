#INCLUDE "rwmake.ch"

/*/{Protheus.doc} BKFINR12
BK - Função Generica para rateio de valores conforme parâmetros
@Return aRat
@author Adilson do Prado / Marcos Bispo Abrahão
@since 14/02/14
@version P12
/*/

USER FUNCTION Rateia(aRTot,nVal)
Local aRat	:= {}
Local nTot	:= 0
Local nRes	:= 0
//Local nTot1 := 0
Local nIx	:= 0

FOR nIx := 1 TO LEN(aRTot)
	nTot += aRTot[nIx,2]
Next

FOR nIx := 1 TO LEN(aRTot)
	nRes := ROUND( (aRTot[nIx,2] * 100 / nTot ) * nVal / 100,2)
	AADD(aRAT,{aRTot[nIx,1],nRes,iIf(Len(aRTot[nIx])>2,aRTot[nIx,3],"")})
	//nTot1 += nRes
Next

Return aRat
