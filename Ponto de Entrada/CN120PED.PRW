#include "rwmake.ch"

/*/{Protheus.doc} CN120PED
BK - Ponto de Entrada para carregar campos Estado e Cod. Munic. IBGE e RECISS no pedido de VENDA

@Return
@author Adilson do Prado
@since 09/04/15
@version P11/P12
/*/

User Function CN121PED()  //executado na nova medição
Return U_CN120PED()






User Function CN120PED()

Local ExpA1 	:= PARAMIXB[1]
Local ExpA2 	:= PARAMIXB[2]
Local cContrato := CN9->CN9_NUMERO
Local cRevisa   := CN9->CN9_REVISA
Local cPlanilha := ""
Local cXXNOISS  := ALLTRIM(GetMv("MV_XXNOISS")) // CLIENTE NÃO SAIR RETENÇÃO DE ISS
Local cCliente  := CND->CND_CLIENT
Local aArea		:= GetArea()
Local aAreaCNA	
Local cNaturez  := ""
Local cTpNf		:= "N"

cPlanilha  := ExpA1[aScan(ExpA1, {|x| x[1]=="C5_MDPLANI"}),2]

dbSelectArea("CNA")
aAreaCNA := CNA->(getArea())

dbSetOrder(1)
CNA->(dbSeek(xFilial("CNA")+cContrato+cRevisa+cPlanilha)) 

If SM0->M0_CODIGO == "01"      // BK
	IF cCliente $ cXXNOISS .OR. STRZERO(VAL(SUBSTR(cCliente,1,3)),6) $ cXXNOISS 
		IF CNA->CNA_XXUF == SM0->M0_ESTENT .AND. ALLTRIM(SUBSTR(SM0->M0_CODMUN,3,LEN(SM0->M0_CODMUN))) == ALLTRIM(CNA->CNA_XXCMUN) 
			AADD(ExpA1,{"C5_RECISS" ,'2', Nil})
		ENDIF 
	ENDIF

	IF CNA->CNA_XXRISS == "1"
		AADD(ExpA1,{"C5_RECISS" ,'1', Nil})
	ELSEIF CNA->CNA_XXRISS == "2"
		AADD(ExpA1,{"C5_RECISS" ,'2', Nil})
	ENDIF
ENDIF                     

IF (CND->CND_CLIENT <> CNA->CNA_CLIENT) .OR. (CND->CND_LOJACL <> CNA->CNA_LOJACL)
	AADD(ExpA1,{"C5_ESTPRES" ,SA1->A1_EST, Nil}) 
	AADD(ExpA1,{"C5_MUNPRES" ,SA1->A1_COD_MUN, Nil})
ELSE
	AADD(ExpA1,{"C5_ESTPRES" ,CNA->CNA_XXUF, Nil}) 
	AADD(ExpA1,{"C5_MUNPRES" ,CNA->CNA_XXCMUN, Nil})
ENDIF

If FWIsInCallStack("U_CN121PED")
	cTpNF := CNA->CNA_XXTPNF
Else
	// Remover quando a medição antiga for desabilitada
	If Empty(CND->CND_XXTPNF)
		If !Empty(CNA->CNA_XXTPNF)
			cTpNF := CNA->CNA_XXTPNF
		EndIf
	Else
		cTpNf := CND->CND_XXTPNF
	EndIf
EndIf

AADD(ExpA1,{"C5_XXTPNF" ,cTpNF, Nil})    // N=Normal;B=Balcão;F=Filial

// Retenção Contratual
If !EMPTY(CNA->CNA_XXNAT)
	AADD(ExpA1,{"C5_NATUREZ" ,CNA->CNA_XXNAT, Nil}) 
Else
	cNaturez := Posicione("SA1",1,xFilial("SA1")+CND->CND_CLIENT+CND->CND_LOJACL,"A1_NATUREZ")
	AADD(ExpA1,{"C5_NATUREZ",cNaturez, Nil}) 
EndIf

AADD(ExpA1,{"C5_XXRETC" ,CNA->CNA_XXRETC, Nil})   

AADD(ExpA1,{"C5_XXCOMPM",CND->CND_COMPET, Nil})  
AADD(ExpA1,{"C5_XXRM"   ,CND->CND_XXRM  , Nil})  

CNA->(RestArea(aAreaCNA))
RestArea(aArea)

Return {ExpA1,ExpA2}                           
