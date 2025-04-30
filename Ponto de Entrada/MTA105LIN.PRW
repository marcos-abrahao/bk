#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MTA105LIN บAutor  ณAdilson do Prado    บ Data ณ  14/07/16  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto-de-Entrada para valida os dados na linha da          บฑฑ
ฑฑบ          ณ solicita็ใo ao almoxarifado digitada.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BK                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿ 
*/ 

User Function MTA105LIN()
Local lRet	   := .T.
Local nPRODUTO := aScan(aHeader,{|x| AllTrim(x[2])=="CP_PRODUTO"})
Local nQUANT   := aScan(aHeader,{|x| AllTrim(x[2])=="CP_QUANT"})
Local nXXNSCOM := aScan(aHeader,{|x| AllTrim(x[2])=="CP_XXNSCOM"})
Local nXXISCOM := aScan(aHeader,{|x| AllTrim(x[2])=="CP_XXISCOM"})
Local cPROSC1  := ""
Local nQNT     := 0
Local cXXNSCOM := ""
Local cXXISCOM := ""

If cEmpAnt <> "20" // Barcas nใo usar isso
	cPROSC1  := aCols[n,nPRODUTO]
	nQNT     := aCols[n,nQUANT]
	cXXNSCOM := aCols[n,nXXNSCOM]
	cXXISCOM := aCols[n,nXXISCOM]

	DbSelectArea("SC1")
	SC1->(DbSetOrder(1))
	IF SC1->(DbSeek(xFilial("SC1")+cXXNSCOM+cXXISCOM,.F.))
		IF SC1->C1_PRODUTO <> cPROSC1
			MSGSTOP("Informe o Numero e Item da Solicita็ใo de Compras correspondente ao produto informado!!")	
			lRet := .F.
		ENDIF
		IF nQNT > SC1->C1_QUANT
			MSGSTOP("Quantidade informada ้ maior que a quantidade da Solicita็ใo de Compras correspondente informada!!")	
			lRet := .F.
		ENDIF
		IF SC1->C1_QUJE == SC1->C1_QUANT
			MSGSTOP("Solicita็ใo de Compras informada estแ totalmente atendida!!")	
			lRet := .F.
		ENDIF
	ELSE
		MSGSTOP("Informe o Numero e Item da Solicita็ใo de Compras correspondente ao produto informado!!")	
		lRet := .F.
	ENDIF
EndIf
Return lRet
