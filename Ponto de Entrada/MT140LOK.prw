#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MT140LOK  �Autor  �Adilson do Prado    � Data �  04/06/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Este ponto de entrada tem o objetivo de validar as         ���
���informa��es preenchidas no aCols de cada item do pr�-documento de      ���
���entrada, para usu�rio do grupo Almoxarifado                            ���
���                                                                       ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

 
User Function xMT140LOK
Local lRet	 := ParamIXB[1]
//Local aTotais:= ParamIXB[2]
//Local aDesp  := ParamIXB[3]
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
			u_AvisoLog("MT140LOK","Aten��o","Informe o No. do Pedido de Compras ("+alltrim(STR(iX,0))+")",{"Ok"}, 2 )
			lRet := .F.
			EXIT
		ENDIF
	Next
ENDIF 

Return lRet





