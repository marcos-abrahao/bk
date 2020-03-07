#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CN120PED ºAutor  ³ Adilson do Prado   º Data ³  09/04/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada para carregar campos Estado e Cod. Munic. º±±
±±º          ³ IBGE e RECISS no pedido de VENDA                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ³Analista/Alterações                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CN121PED()
Return U_CN120PED()


User Function CN120PED()
Local ExpA1 := PARAMIXB[1]
Local ExpA2 := PARAMIXB[2]
Local cContrato := CN9->CN9_NUMERO
Local cRevisa   := CN9->CN9_REVISA
Local cPlanilha := ""
Local cXXNOISS  := ALLTRIM(GetMv("MV_XXNOISS")) // CLIENTE NÃO SAIR RETENÇÃO DE INSS
Local cCliente  := CN9->CN9_CLIENT

cPlanilha  := ExpA1[aScan(ExpA1, {|x| x[1]=="C5_MDPLANI"}),2]

dbSelectArea("CNA")
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

AADD(ExpA1,{"C5_ESTPRES" ,CNA->CNA_XXUF, Nil}) 
AADD(ExpA1,{"C5_MUNPRES" ,CNA->CNA_XXCMUN, Nil})

// Retenção Contratual
//If Type("CNA->CNA_XXRETC")<>"U"
	AADD(ExpA1,{"C5_XXRETC" ,CNA->CNA_XXRETC, Nil})   
//EndIf
AADD(ExpA1,{"C5_XXCOMPM" ,CND->CND_COMPET, Nil})  
Return {ExpA1,ExpA2}                           
