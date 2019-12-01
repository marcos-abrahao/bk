#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MTA105LIN ºAutor  ³Adilson do Prado    º Data ³  14/07/16  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto-de-Entrada para valida os dados na linha da          º±±
±±º          ³ solicitação ao almoxarifado digitada.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß 
*/ 

User Function MTA105LIN()
Local lRet	 := .T.
Local nPRODUTO := aScan(aHeader,{|x| AllTrim(x[2])=="CP_PRODUTO"})
Local nQUANT   := aScan(aHeader,{|x| AllTrim(x[2])=="CP_QUANT"})
Local nXXNSCOM := aScan(aHeader,{|x| AllTrim(x[2])=="CP_XXNSCOM"})
Local nXXISCOM := aScan(aHeader,{|x| AllTrim(x[2])=="CP_XXISCOM"})
Local cPROSC1  := ""
Local nQNT     := 0
Local cXXNSCOM := ""
Local cXXISCOM := ""

cPROSC1  := aCols[n,nPRODUTO]
nQNT     := aCols[n,nQUANT]
cXXNSCOM := aCols[n,nXXNSCOM]
cXXISCOM := aCols[n,nXXISCOM]

DbSelectArea("SC1")
SC1->(DbSetOrder(1))
IF SC1->(DbSeek(xFilial("SC1")+cXXNSCOM+cXXISCOM,.F.))
	IF SC1->C1_PRODUTO <> cPROSC1
		MSGSTOP("Informe o Numero e Item da Solicitação de Compras correspondente ao produto informado!!")	
		lRet := .F.
	ENDIF
	IF nQNT > SC1->C1_QUANT
		MSGSTOP("Quantidade informada é maior que a quantidade da Solicitação de Compras correspondente informada!!")	
		lRet := .F.
	ENDIF
	IF SC1->C1_QUJE == SC1->C1_QUANT
		MSGSTOP("Solicitação de Compras informada está totalmente atendida!!")	
		lRet := .F.
	ENDIF
ELSE
	MSGSTOP("Informe o Numero e Item da Solicitação de Compras correspondente ao produto informado!!")	
	lRet := .F.
ENDIF

Return lRet