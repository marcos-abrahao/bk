#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � MTA105LIN �Autor  �Adilson do Prado    � Data �  14/07/16  ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto-de-Entrada para valida os dados na linha da          ���
���          � solicita��o ao almoxarifado digitada.                      ���
�������������������������������������������������������������������������͹��
���Uso       � BK                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� 
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

If !u_IsBarcas() // Barcas n�o usar isso
	cPROSC1  := aCols[n,nPRODUTO]
	nQNT     := aCols[n,nQUANT]
	cXXNSCOM := aCols[n,nXXNSCOM]
	cXXISCOM := aCols[n,nXXISCOM]

	DbSelectArea("SC1")
	SC1->(DbSetOrder(1))
	IF SC1->(DbSeek(xFilial("SC1")+cXXNSCOM+cXXISCOM,.F.))
		IF SC1->C1_PRODUTO <> cPROSC1
			MSGSTOP("Informe o Numero e Item da Solicita��o de Compras correspondente ao produto informado!!")	
			lRet := .F.
		ENDIF
		IF nQNT > SC1->C1_QUANT
			MSGSTOP("Quantidade informada � maior que a quantidade da Solicita��o de Compras correspondente informada!!")	
			lRet := .F.
		ENDIF
		IF SC1->C1_QUJE == SC1->C1_QUANT
			MSGSTOP("Solicita��o de Compras informada est� totalmente atendida!!")	
			lRet := .F.
		ENDIF
	ELSE
		MSGSTOP("Informe o Numero e Item da Solicita��o de Compras correspondente ao produto informado!!")	
		lRet := .F.
	ENDIF
EndIf
Return lRet
