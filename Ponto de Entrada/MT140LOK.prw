#include "rwmake.ch"

/*/{Protheus.doc} SD1140I
BK - Este ponto de entrada tem o objetivo de validar as
	 informações preenchidas no aCols de cada item do pré-documento de 
	 entrada, para usuário do grupo Almoxarifado 	
@Return
@author Adilson do Prado
@since 04/06/2013
@version P12
/*/
 
User Function MT140LOK
Local lRet	 := ParamIXB[1]
//Local aTotais:= ParamIXB[2]
//Local aDesp  := ParamIXB[3]
Local nPosXH := aScan(aHeader,{|x| AllTrim(x[2])=="D1_XXHIST"})
Local nI := 0

For nI := 1 TO LEN(aCols)
	// Ajuste 20/03/25 - D1_XXHIST com valor NIL
	IF Empty(aCols[nI,nPosXH])
		aCols[nI,nPosXH] := ""
	ENDIF
Next

Return lRet

/*
Local nPosPc := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
Local aUser:={},aGrupo:={}
Local cAlmox := ""
Local lAlmox := .F.
Local iX     := 0

aUser  := PswRet(1)
cAlmox := u_GrpAlmox()
lAlmox := .F.

aGRUPO := {}
aGRUPO := UsrRetGrp(aUser[1][2])
IF LEN(aGRUPO) > 0
	FOR iX:=1 TO LEN(aGRUPO)
		lAlmox := (ALLTRIM(aGRUPO[iX]) $ lAlmox )
	NEXT
ENDIF	

IF lAlmox
	For iX:=1 TO LEN(aCols)
		IF Empty(aCols[iX,nPosPC]) 
			u_AvisoLog("MT140LOK","Atenção","Informe o No. do Pedido de Compras ("+alltrim(STR(iX,0))+")",{"Ok"}, 2 )
			lRet := .F.
			EXIT
		ENDIF
	Next
ENDIF 

Return lRet
*/




