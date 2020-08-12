#include "rwmake.ch"

/*/{Protheus.doc} CN120PED
BK - Ponto de Entrada para carregar campos Estado e Cod. Munic. IBGE e RECISS no pedido de VENDA

@Return
@author Adilson do Prado
@since 09/04/15
@version P11/P12
/*/

User Function CN121PED()
Return U_CN120PED()


User Function CN120PED()

Local ExpA1 	:= PARAMIXB[1]
Local ExpA2 	:= PARAMIXB[2]
Local cContrato := CN9->CN9_NUMERO
Local cRevisa   := CN9->CN9_REVISA
Local cPlanilha := ""
Local cXXNOISS  := ALLTRIM(GetMv("MV_XXNOISS")) // CLIENTE NÃO SAIR RETENÇÃO DE INSS
Local cCliente  := CND->CND_CLIENT
Local aArea		:= GetArea()
Local aAreaCNA	

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
	//A=Avulsa;C=Contrato;2=Serie2
ELSE
	AADD(ExpA1,{"C5_ESTPRES" ,CNA->CNA_XXUF, Nil}) 
	AADD(ExpA1,{"C5_MUNPRES" ,CNA->CNA_XXCMUN, Nil})
ENDIF

If Empty(CND->CND_XXTPNF)
	AADD(ExpA1,{"C5_XXTPNF" ,"N", Nil})    // N=Normal;A=Avulsa
Else
	AADD(ExpA1,{"C5_XXTPNF" ,CND->CND_XXTPNF, Nil})    // N=Normal;A=Avulsa
EndIf

// Retenção Contratual
//If Type("CNA->CNA_XXRETC")<>"U"
	AADD(ExpA1,{"C5_XXRETC" ,CNA->CNA_XXRETC, Nil})   
//EndIf
AADD(ExpA1,{"C5_XXCOMPM" ,CND->CND_COMPET, Nil})  

CNA->(RestArea(aAreaCNA))
RestArea(aArea)

Return {ExpA1,ExpA2}                           
