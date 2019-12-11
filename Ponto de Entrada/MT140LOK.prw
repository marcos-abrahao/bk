#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT140LOK  ºAutor  ³Adilson do Prado    º Data ³  04/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este ponto de entrada tem o objetivo de validar as         º±±
±±ºinformações preenchidas no aCols de cada item do pré-documento de      º±±
±±ºentrada, para usuário do grupo Almoxarifado                            º±±
±±º                                                                       º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

 
User Function xMT140LOK
Local lRet	 := ParamIXB[1]
Local aTotais:= ParamIXB[2]
Local aDesp  := ParamIXB[3]
Local nPosPc := aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
Local aUser:={},aGrupo:={}
Local cAlmox := ""
Local lAlmox := .F.
Local iX     := 0

aUser  := PswRet(1)
cAlmox := SuperGetMV("MV_XXGRALX",.F.,"000021") 
lAlmox := .F.
aGRUPO := {}
//AADD(aGRUPO,aUser[1,10])
//FOR i:=1 TO LEN(aGRUPO[1])
//	lAlmox := (aGRUPO[1,i] $ cAlmox)
//NEXT
//Ajuste nova rotina a antiga não funciona na nova lib MDI
aGRUPO := UsrRetGrp(aUser[1][2])
IF LEN(aGRUPO) > 0
	FOR iX:=1 TO LEN(aGRUPO)
		lAlmox := (ALLTRIM(aGRUPO[iX]) $ lAlmox )
	NEXT
ENDIF	

IF lAlmox
	For iX:=1 TO LEN(aCols)
		IF Empty(aCols[iX,nPosPC]) 
			Aviso("Atenção","Informe o No. do Pedido de Compras ("+alltrim(STR(iX,0))+")",{"Ok"}, 2 )
			lRet := .F.
			EXIT
		ENDIF
	Next
ENDIF 

Return lRet





