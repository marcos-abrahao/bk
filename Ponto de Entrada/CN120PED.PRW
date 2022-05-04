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
Local cNumMed	:= ""
//Local cIteMed	:= ""
Local cXXNOISS  := ALLTRIM(GetMv("MV_XXNOISS")) // CLIENTE NÃO SAIR RETENÇÃO DE ISS
Local cCliente  := ""
Local cLoja		:= ""
Local aArea		:= GetArea()
Local aAreaCNA	
Local aAreaCXN
//Local aAreaCNE
Local cNaturez  := ""
Local cTpNf		:= "N"
Local lRec		:= .F.
//Local nI		:= 0

cCliente	:= ExpA1[aScan(ExpA1, {|x| x[1]=="C5_CLIENTE"}),2]
cLoja		:= ExpA1[aScan(ExpA1, {|x| x[1]=="C5_LOJACLI"}),2]
cPlanilha	:= ExpA1[aScan(ExpA1, {|x| x[1]=="C5_MDPLANI"}),2]
cNumMed		:= ExpA1[aScan(ExpA1, {|x| x[1]=="C5_MDNUMED"}),2]

dbSelectArea("CXN")
aAreaCXN := CXN->(getArea())
CXN->(dbSetOrder(3))
CXN->(dbSeek(xFilial("CXN",cFilCtr)+cContrato+cNumMed+cPlanilha)) 

dbSelectArea("CNA")
aAreaCNA := CNA->(getArea())
dbSetOrder(1)
CNA->(dbSeek(xFilial("CNA",cFilCtr)+cContrato+cRevisa+cPlanilha)) 

If cEmpAnt == "01"      // BK
	If cCliente $ cXXNOISS .OR. STRZERO(VAL(SUBSTR(cCliente,1,3)),6) $ cXXNOISS 
		If CNA->CNA_XXUF == SM0->M0_ESTENT .AND. ALLTRIM(SUBSTR(SM0->M0_CODMUN,3,LEN(SM0->M0_CODMUN))) == ALLTRIM(CNA->CNA_XXCMUN) 
			AADD(ExpA1,{"C5_RECISS" ,'2', Nil})
			lRec := .T.
		EndIf 
	EndIf
EndIf

If !lRec
	If CNA->CNA_XXRISS == "1"
		AADD(ExpA1,{"C5_RECISS" ,'1', Nil})
	ElseIf CNA->CNA_XXRISS == "2"
		AADD(ExpA1,{"C5_RECISS" ,'2', Nil})
	EndIf
EndIf                 

IF (cCliente <> CNA->CNA_CLIENT) .OR. (cLoja <> CNA->CNA_LOJACL)
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

If Empty(cTpNF)
	cTpNF := "N"
EndIf

AADD(ExpA1,{"C5_XXTPNF" ,cTpNF, Nil})    // N=Normal;B=Balcão;F=Filial

// Retenção Contratual
If !EMPTY(CNA->CNA_XXNAT)
	AADD(ExpA1,{"C5_NATUREZ" ,CNA->CNA_XXNAT, Nil}) 
Else
	cNaturez := Posicione("SA1",1,xFilial("SA1")+cCliente+cLoja,"A1_NATUREZ")
	AADD(ExpA1,{"C5_NATUREZ",cNaturez, Nil}) 
EndIf

AADD(ExpA1,{"C5_XXRETC" ,CNA->CNA_XXRETC, Nil})   

AADD(ExpA1,{"C5_XXCOMPM",CND->CND_COMPET, Nil}) 

// Aqui acertar quando for nova medição CXN_XXRM
If FWIsInCallStack("U_CN121PED")
	AADD(ExpA1,{"C5_XXRM"   ,CXN->CXN_XXRM  , Nil})  
Else
	AADD(ExpA1,{"C5_XXRM"   ,CND->CND_XXRM  , Nil})  
EndIf

// Acertar valor total dos itens do pedido de vendas
/*
dbSelectArea("CNE")
aAreaCNE := CNE->(getArea())
dbSetOrder(1)
For nI := 1 To Len(ExpA2)

    //Chave 1 do CNE: CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED+CNE_ITEM
	cIteMed	:= ExpA2[nI,aScan(ExpA2[nI], {|x| x[1]=="C6_ITEMED"}),2]
	
	If CNE->(dbSeek(xFilial("CNE")+cContrato+cRevisa+cPlanilha+cNumMed+cIteMed)) 
		AADD(ExpA2[nI],{"C6_VALOR"   ,CNE->CNE_VLLIQD , Nil}) 
	EndIf

Next

CNE->(RestArea(aAreaCNE))

*/

CNA->(RestArea(aAreaCNA))
CXN->(RestArea(aAreaCXN))

RestArea(aArea)

u_LogPrw("CN120PED","Medição "+cNumMed)

Return {ExpA1,ExpA2}                           
