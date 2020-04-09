#include "rwmake.ch"
#INCLUDE "topconn.ch"
#Include "Protheus.ch"

// Montagem do corpo da NF de serviços

User Function MtDescrNFE()
Local cDescr   := ""
Local cImpost  := ""
Local cNaturez := ""
Local nPIrrf   := 0
Local nPInss   := 0
Local nPPis    := 0
Local nPCofins := 0
Local nPCsll   := 0
Local nPIss    := 0
Local cNF,cSerie,cCliente,cLoja
Local cKeyD2
Local cProduto  := ""
Local cContrato := ""
Local cPlanilha := ""
Local cMedicao  := ""
Local nReg		:= 0

Local cDescrCTT := ""
Local cObjeto   := ""
Local cObjeto1  := ""
Local cCompet   := ""
Local cConta    := ""
Local cMun      := ""

Local cVencto   := ""
Local cParcela  := ""
Local nI
Local aTmp,cRevisa,cObsMed
Local cImpDtV   := "S"
Local cMenNota  := ""
Local aBancos   := {}
Local nINSSME   := 0 // REDUCAO BASE ISS MATERIAS
Local nREDINSS  := 0 // REDUCAO BASE ISS MATERIAS
Local nBINSS    := 0 // REDUCAO BASE ISS MATERIAS
Local nVALINSS  := 0 // REDUCAO BASE ISS MATERIAS
Local cXXNOISS  := ALLTRIM(GetMv("MV_XXNOISS")) // CLIENTE NÃO SAIR RETENÇÃO DE INSS
Local cXXDSISS  := ALLTRIM(GetMv("MV_XXDSISS"))  // DESCRIÇÃO DA LEI PARA CLIENTE NÃO SAIR RETENÇÃO DE INSS
Local cXXCVLIQ  := ALLTRIM(GetMv("MV_XXCVLIQ")) // CLIENTE SAIR VALOR LIQUIDO NA NF
Local cXXMEDIC  := ALLTRIM(SuperGetMV("MV_XXMEDIC",.F.,"000302")) // CLIENTE SAIR A PALAVRA MEDIÇÃO AO INVES DE PARCELA
Local cXXCOMPE  := ALLTRIM(SuperGetMV("MV_XXCOMPE",.F.,"000058/000163/000193/000194/000195/000196/000197/000198/000199/000211/000215/000239/000241/000242/000245/000305/000316/000317/000318/000319/000320/000321/")) // CLIENTE NAO SAIR COMPETENCIA
Local cXXDNFS	:= ""
Local nQTDIMP   := 0
Local nTOTIMP   := 0
Local lImp 		:= .F.
Local nScan		:= 0
Local aBCVINC 	:= {}
Local cAgVinc 	:= ""
Local cCCVinc 	:= ""

Local aAreaAtu
Local aAreaSE1
Local aAreaSA1
Local aAreaSF2
Local aAreaSD2
Local aAreaSED
Local aAreaSC5
Local aAreaCN9
Local aAreaSYP
Local aAreaCTT
Local aAreaCND

//If !EMPTY(SF3->F3_DTCANC)
	//Return "NF CANCELADA"
//EndIf

AADD(aBancos,{"001","Banco do Brasil"})
AADD(aBancos,{"033","Santander"})
AADD(aBancos,{"104","Caixa Economica Federal"})
AADD(aBancos,{"237","Bradesco"})
AADD(aBancos,{"341","Itau"})

cNF     := PARAMIXB[1]
cSerie  := PARAMIXB[2] 
cCliente:= PARAMIXB[3]
cLoja   := PARAMIXB[4]

aAreaAtu   := GetArea()
aAreaSF2   := SF2->(GetArea("SF2"))

SF2->(Dbsetorder(2))
IF !SF2->(DbSeek(xFilial("SF2")+cCliente+cLoja+cNF+cSerie,.F.))
   SF2->(RestArea(aAreaSF2))
   RestArea(aAreaAtu)
   Return cDescr
ENDIF

IF !EMPTY(SF2->F2_XXCORPO)
	cDescr := TRIM(SF2->F2_XXCORPO)
	cDescr += "|"
	cDescr := AltCorpo(cDescr,cNF)

	RecLock("SF2",.F.)
	SF2->F2_XXCORPO := cDescr
	SF2->(MsUnlock())
	
   SF2->(RestArea(aAreaSF2))
   RestArea(aAreaAtu)
   Return cDescr
ENDIF
 
aAreaSE1   := GetArea("SE1")
aAreaSA1   := GetArea("SA1")
aAreaSD2   := GetArea("SD2")     
aAreaSED   := GetArea("SED")     
aAreaSC5   := GetArea("SC5")     
aAreaCN9   := GetArea("CN9")     
aAreaSYP   := GetArea("SYP")     
aAreaCTT   := GetArea("CTT")     
aAreaCND   := GetArea("CND")     
   
dbSelectArea ("SD2")             //itens de venda da NF
dbSetOrder (3)                 //filial,doc,serie,cliente,loja,cod

cKeyD2 := xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE
dbSelectArea("SD2")
dbSeek(cKeyD2)
DO WHILE !EOF() .and. SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE == cKeyD2
	IF EMPTY(cProduto)
		cProduto := SD2->D2_COD
	ENDIF
	dbSelectArea("SC5")
	IF dbSeek(xFilial("SC5") + SD2->D2_PEDIDO)
		cMenNota := TRIM(SC5->C5_MENNOTA)
		IF EMPTY(cContrato)
			cContrato := SC5->C5_MDCONTR
			cMedicao  := SC5->C5_MDNUMED
			cPlanilha := SC5->C5_MDPLANI
		ENDIF   
	ENDIF
	dbSelectArea("SD2")
	dbSkip()
ENDDO

IF !EMPTY(cContrato)

    // QryProc(cAlias,nCampos,cCampos,cWhere)
    aTmp := QryProc("CND",1,"R_E_C_N_O_","CND_FILIAL = '"+xFilial("CND")+"' AND CND_NUMMED = '"+cMedicao+"'")

	dbSelectArea("CN9")
    cRevisa := SPACE(LEN(CN9->CN9_REVISA))
    cObsMed := ""
	IF !EMPTY(aTmp)
	   nReg := aTmp[1]
	   dbSelectArea("CND")
       dbGoTo(nReg)
	   cObsMed := CND->CND_OBS
	   cRevisa := CND->CND_REVISA
	ENDIF
    

	// Descrição do contrato = descrição do centro de custo
	cDescrCTT := ""
	dbSelectArea("CTT")
	dbSetOrder(1)
	IF dbSeek(xFilial("CTT") + cContrato)
		IF !EMPTY(CTT->CTT_XXDESC)
			cDescrCTT := TRIM(CTT->CTT_XXDESC)+"|"
		ELSE
			cDescrCTT := TRIM(CTT->CTT_DESC01)+"|"
		ENDIF	
	ENDIF

	
	cObjeto := ""
	nINSSME := 0
	dbSelectArea("CN9")
	dbSetOrder(1)
	IF dbSeek(xFilial("CN9") + cContrato + cRevisa)
		cImpDtV := CN9->CN9_XXIDTV
		nINSSME := CN9->CN9_INSSME
		dbSelectArea ("SYP")
		dbSetOrder(1)
		dbSeek(xFilial("SYP") + CN9->CN9_CODOBJ)
		DO WHILE !EOF() .AND. (xFilial("SYP") + CN9->CN9_CODOBJ) = (SYP->YP_FILIAL + SYP->YP_CHAVE)
		    cObjeto += STRTRAN(TRIM(SYP->YP_TEXTO),"\13\10","")   //+"|"
			dbSkip()
		ENDDO 
	ENDIF
	
	cObjeto1 := ""
	FOR nI:= 1 to MLCOUNT(cObjeto,80)
		cObjeto1 += TRIM(MEMOLINE(cObjeto,80,nI))+"|"
	NEXT
	IF !EMPTY(cObjeto)
		cObjeto1 += "|"
	ENDIF	
	FOR nI:= 1 to MLCOUNT(cObsMed,80)
		cObjeto1 += TRIM(MEMOLINE(cObsMed,80,nI))+"|"
	NEXT
    
	cCompet := ""
	cParcela:= ""
	dbSelectArea("CND")
	dbSetOrder(4)
	IF dbSeek(xFilial("CND") + cMedicao)
		IF  ALLTRIM(CND->CND_CONTRA) <> '307000496'
			IF !(ALLTRIM(CND->CND_CLIENT) $ cXXCOMPE)
	   			cCompet  := "Competencia: "+CND->CND_COMPET
			ENDIF
			IF ALLTRIM(CND->CND_CLIENT) $ cXXMEDIC
	   			cParcela := " "+CND->CND_PARCELA+"ª MEDICAO"
	   		ELSE
	   			cParcela := "Parcela: "+CND->CND_PARCELA
	   		ENDIF
	   ENDIF
	ENDIF

	cMun   := ""
	cConta := ""
	dbSelectArea("SA1")
	dbSetOrder(1)
	IF dbSeek(xFilial("SA1")+cCliente+cLoja)
	   IF !EMPTY(SA1->A1_XXCTABC)
	      cConta := TRIM(SA1->A1_XXCTABC)+"|"
	   ENDIF   
	   // cMun := "Municipio: "+TRIM(Posicione("CC2",1,xFilial("CC2")+SA1->A1_EST+SA1->A1_COD_MUN,"CC2_MUN"))+" - "+SA1->A1_EST
	ENDIF

    IF !EMPTY(cProduto)
    	SB1->(dbSeek(xFilial("SB1")+cProduto))
    	IF !EMPTY(SB1->B1_XXMUN)
    	   cMun := "Municipio: "+TRIM(SB1->B1_XXMUN)
    	ENDIF   
   	    nPIss:= SB1->B1_ALIQISS
    ENDIF

    IF !EMPTY(cPlanilha)
		dbSelectArea("CNA")
		dbSetOrder(1)
        CNA->(dbSeek(xFilial("CNA")+cContrato+cRevisa+cPlanilha)) 
    	IF !EMPTY(CNA->CNA_XXMUN)
    	   cMun := "Municipio: "+TRIM(CNA->CNA_XXMUN)
    	ENDIF
    	IF CNA->CNA_XXIMPP = "S"
    	   cCompet := IIF(!EMPTY(cCompet),cCompet+" - ","") + cParcela
    	ENDIF
    ENDIF

ELSE
	// NF que não é serviço de contrato
	IF !EMPTY(SC5->C5_XXDNFS)
		cXXDNFS := ""
		cXXDNFS := TRIM(SC5->C5_XXDNFS)
		FOR nI:= 1 to MLCOUNT(cXXDNFS,80)
			cObjeto1 += TRIM(MEMOLINE(cXXDNFS,80,nI))+"|"
		NEXT
   		cObjeto1 += cMenNota+"|"
    	nPIss:= SB1->B1_ALIQISS
    ELSE
    	IF !EMPTY(cProduto)
    		SB1->(dbSeek(xFilial("SB1")+cProduto))
    		cObjeto1 := TRIM(SB1->B1_DESC)+"|"
    		cObjeto1 += cMenNota+"|"
   	    	nPIss:= SB1->B1_ALIQISS
    	ENDIF
    ENDIF

	cConta := ""
	dbSelectArea("SA1")
	dbSetOrder(1)
	IF dbSeek(xFilial("SA1")+cCliente+cLoja)
	   IF !EMPTY(SA1->A1_XXCTABC)
	      cConta := TRIM(SA1->A1_XXCTABC)+"|"
	   ENDIF   
	ENDIF
ENDIF 
  
cVencto := ""
SE1->(Dbsetorder(1))
SE1->(DbSeek(SF2->F2_FILIAL+SF2->F2_PREFIXO+SF2->F2_DOC,.T.))
DO WHILE !SE1->(EOF()) .AND. SE1->E1_FILIAL == SF2->F2_FILIAL .AND. SE1->E1_PREFIXO == SF2->F2_PREFIXO .AND. SE1->E1_NUM == SF2->F2_DOC
   IF SE1->E1_TIPO == "NF "
      IF EMPTY(cNaturez)
      	cNaturez := SE1->E1_NATUREZ
      ENDIF
      cVencto := "Vencimento: "+DTOC(SE1->E1_VENCTO)
   ENDIF
   SE1->(DbSkip(1))   
ENDDO

IF cImpDtV <> "S"
	cVencto := "Vencimento: conforme contrato"
ENDIF	

cDescr += cDescrCTT+cObjeto1
cDescr += cVencto+IIF(!EMPTY(cVencto) .AND. !EMPTY(cCompet)," - ","")+cCompet+"|"

IF !EMPTY(cMun)
	cDescr += cMun+"|"
ENDIF	

IF !EMPTY(cConta)
	cDescr += cConta //+"|"
ENDIF	

IF !EMPTY(cNaturez)
   SED->(Dbsetorder(1))
   IF SED->(DbSeek(xFilial("SED")+cNaturez,.F.))
      nPIrrf   := SED->ED_PERCIRF
      nPInss   := SED->ED_PERCINS
      nPPis    := SED->ED_PERCPIS
      nPCofins := SED->ED_PERCCOF
      nPCsll   := SED->ED_PERCCSL
   ENDIF   
ENDIF

lImp := .F.
nQTDIMP := 0
nTOTIMP := 0
IF SF2->F2_VALIRRF > 0
   nTOTIMP += SF2->F2_VALIRRF
   IF nPIrrf = 0
      nPIrrf := GETMV("MV_ALIQIRF")
   ENDIF
   ++nQTDIMP
   cImpost += PAD("IRRF.....",8)+STR(nPIrrf,5,2)+"%"+TRANSFORM(SF2->F2_VALIRRF,"@E 999,999.99")+IIF(nQTDIMP==3,"|",SPACE(4))//+IIF(lImp,"|",SPACE(10))
   lImp := !lImp
   IF nQTDIMP==3
   		nQTDIMP := 0
   ENDIF
ENDIF
IF SF2->F2_VALPIS > 0
   nTOTIMP += SF2->F2_VALPIS
   ++nQTDIMP
   cImpost += PAD("PIS......",8)+STR(nPPis,5,2)+"%"+TRANSFORM(SF2->F2_VALPIS,"@E 999,999.99")+IIF(nQTDIMP==3,"|",SPACE(4))//+IIF(nQTDIMP==3,"|",SPACE(4))//+IIF(lImp,"|",SPACE(10))
   lImp := !lImp
   IF nQTDIMP==3
   		nQTDIMP := 0
   ENDIF
ENDIF
IF SF2->F2_VALCOFI > 0
   nTOTIMP += SF2->F2_VALCOFI
   ++nQTDIMP
   cImpost += PAD("COFINS...",8)+STR(nPCofins,5,2)+"%"+TRANSFORM(SF2->F2_VALCOFI,"@E 999,999.99")+IIF(nQTDIMP==3,"|",SPACE(4))//+IIF(lImp,"|",SPACE(10))
   lImp := !lImp
   IF nQTDIMP==3
   		nQTDIMP := 0
   ENDIF
ENDIF
IF SF2->F2_VALCSLL > 0
   nTOTIMP += SF2->F2_VALCSLL
   ++nQTDIMP
   cImpost += PAD("CSLL.....",8)+STR(nPCsll,5,2)+"%"+TRANSFORM(SF2->F2_VALCSLL,"@E 999,999.99")+IIF(nQTDIMP==3,"|",SPACE(4))//+IIF(lImp,"|",SPACE(10))
   lImp := !lImp
   IF nQTDIMP==3
   		nQTDIMP := 0
   ENDIF
ENDIF
IF !cCliente $ cXXNOISS .AND. !STRZERO(VAL(SUBSTR(cCliente,1,3)),6) $ cXXNOISS
	IF SF2->F2_VALISS > 0  .AND. SF2->F2_RECISS = "1"
   		nTOTIMP += SF2->F2_VALISS
  	 	++nQTDIMP
  	 	cImpost += PAD("ISS......",8)+STR(nPIss,5,2)+"%"+TRANSFORM(SF2->F2_VALISS,"@E 999,999.99")+IIF(nQTDIMP==3,"|",SPACE(4))//+IIF(lImp,"|",SPACE(10))
  	 	lImp := !lImp
  	 	IF nQTDIMP==3
   			nQTDIMP := 0
  	 	ENDIF
	ENDIF
ENDIF

IF SF2->F2_VALINSS > 0
   nTOTIMP += SF2->F2_VALINSS
   ++nQTDIMP
   IF cCliente = "000044"  // CPOS
      cImpost += IIF(lImp,"|","")+"Retencao para a previdencia social: "
   ELSE
      cImpost += PAD("INSS.....",8)
   ENDIF
   cImpost += STR(nPInss,5,2)+"%"+TRANSFORM(SF2->F2_VALINSS,"@E 999,999.99")+IIF(nQTDIMP==3,"|",SPACE(4))//+IIF(lImp,"|",SPACE(10))
   lImp := !lImp
   IF nQTDIMP==3
   		nQTDIMP := 0
   ENDIF
ENDIF

IF SA1->A1_XXFUMDI == "S" .OR. SF2->F2_XXVFUMD > 0

	IF SF2->F2_XXVFUMD == 0
		//GRAVA ALIQUOTA E VALOR FUMDIP - OSASCO
		RecLock("SF2",.F.)
		SF2->F2_XXAFUMD := SA1->A1_XXAFUMD
		SF2->F2_XXVFUMD := SF2->F2_VALBRUT * (SA1->A1_XXAFUMD/100)
		MsUnlock("SF2")
	ENDIF
	nTOTIMP += SF2->F2_XXVFUMD
	++nQTDIMP
	cImpost += PAD("FUMDIP......",8)+STR(SF2->F2_XXAFUMD,5,2)+"%"+TRANSFORM(SF2->F2_XXVFUMD,"@E 999,999.99")+IIF(nQTDIMP==3,"|",SPACE(4))
 	lImp := !lImp
 	IF nQTDIMP==3
		nQTDIMP := 0
	ENDIF
	
    // GERA TITULO DE ABATIMENTO FUMDIP
	IF SF2->F2_XXVFUMD > 0
		U_BKFATA02() 
    ENDIF
ENDIF


IF !EMPTY(cImpost)
   cImpost := "- - - Impostos a serem retidos - - -|"+cImpost
   cDescr  += cImpost
ENDIF

IF cCliente $ cXXNOISS .OR. STRZERO(VAL(SUBSTR(cCliente,1,3)),6) $ cXXNOISS //ADICIONA DESCRIÇÃO DA LEI PARA CLIENTE NÃO SAIR RETENÇÃO DE INSS
	IF !EMPTY(cXXDSISS)
		IF SUBSTR(cDescr,LEN(cDescr),1) == "|"
			cDescr += cXXDSISS+"|"
		ELSE
			cDescr += "|"+cXXDSISS+"|"
		ENDIF
	ENDIF 
ENDIF

//cDescr += "|" 

//INFORMACAO CONTA VINCULADA 
IF !EMPTY(SF2->F2_XXCVINC) .OR. SF2->F2_XXVCVIN > 0 
	ContVinc()
    nScan:= 0
    nScan:= aScan(aBancos,{|x| x[1]==SUBSTR(SF2->F2_XXCVINC,1,3) })
    aBCVINC := {}
    aBCVINC := U_BCTAVINC(SF2->F2_XXCVINC)
   	cAgVinc := ""
   	cAgVinc := aBCVINC[2]
   	//cAgVinc := IIF(EMPTY(SUBSTR(SF2->F2_XXCVINC,9,1)),SUBSTR(SF2->F2_XXCVINC,4,4)+"-"+SUBSTR(SF2->F2_XXCVINC,8,1),SUBSTR(SF2->F2_XXCVINC,4,5)+"-"+SUBSTR(SF2->F2_XXCVINC,9,1)) 
    cCCVinc := ""
   	cCCVinc := aBCVINC[3]
 
    // 11/08/16 - Alterada a posição do dígito da conta de 20 para 25
  	//cCCVinc := TRIM(SUBSTR(SF2->F2_XXCVINC,10,10))+IIF(!EMPTY(SUBSTR(SF2->F2_XXCVINC,25,1)),"-"+SUBSTR(SF2->F2_XXCVINC,25,1),"")
	cDescr += "Deposito para vinculada = "+aBancos[nScan,2]+"-Ag.: "+ALLTRIM(cAgVinc)+" C/C: "+ALLTRIM(cCCVinc)+"|"
	cDescr += "valor R$"+TRANSFORM(SF2->F2_XXVCVIN,"@E 999,999,999.99")+"|"
ELSE
	IF MsgYesNo("Nota Fiscal N°:"+TRIM(SF2->F2_DOC)+"/"+TRIM(SF2->F2_SERIE)+" possui dados conta vinculada?" )
		ContVinc()
   		nScan:= 0
   		nScan:= aScan(aBancos,{|x| x[1]==SUBSTR(SF2->F2_XXCVINC,1,3) })
    	aBCVINC := U_BCTAVINC(SF2->F2_XXCVINC)
   		cAgVinc := ""
   		cAgVinc := aBCVINC[2]
		//cAgVinc := IIF(EMPTY(SUBSTR(SF2->F2_XXCVINC,9,1)),SUBSTR(SF2->F2_XXCVINC,4,4)+"-"+SUBSTR(SF2->F2_XXCVINC,8,1),SUBSTR(SF2->F2_XXCVINC,4,5)+"-"+SUBSTR(SF2->F2_XXCVINC,9,1)) 
   		cCCVinc := ""
   		cAgVinc := aBCVINC[3]
	    // 11/08/16 - Alterada a posição do dígito da conta de 20 para 25
   		//cCCVinc := TRIM(SUBSTR(SF2->F2_XXCVINC,10,10))+IIF(!EMPTY(SUBSTR(SF2->F2_XXCVINC,25,1)),"-"+SUBSTR(SF2->F2_XXCVINC,25,1),"")
		cDescr += "Deposito para vinculada = "+aBancos[nScan,2]+"-Ag.: "+ALLTRIM(cAgVinc)+" C/C: "+ALLTRIM(cCCVinc)+"|"
		cDescr += "valor R$ "+ALLTRIM(TRANSFORM(SF2->F2_XXVCVIN,"@E 999,999,999.99"))+"|"
	ENDIF
ENDIF

//INFORMACAO RETENÇÃO CONTRATUAL
IF !EMPTY(SF2->F2_XXVRETC)
	cDescr += "Retenção Contratual ("+ALLTRIM(TRANSFORM(SF2->F2_XXRETC,"@E 99.99"))+"%): R$ "+ALLTRIM(TRANSFORM(SF2->F2_XXVRETC,"@E 999,999,999.99"))+"|"
ENDIF


cDescr += "|" 

IF nINSSME > 0
	nREDINSS := 0
	nBINSS 	 := 0
	nVALINSS := 0

	nREDINSS := SF2->F2_VALBRUT * (nINSSME/100)
	nBINSS 	 := SF2->F2_VALBRUT - nREDINSS
	nVALINSS := nBINSS * (nPInss/100)
	
	cDescr += "VALOR DA NOTA FISCAL R$"+TRANSFORM(SF2->F2_VALBRUT,"@E 999,999,999.99")+"|"
	cDescr += "(-) "+STR(nINSSME,2)+"% REDUÇÃO DO INSS POR FORNECIMENTO DE MATERIAIS R$"+TRANSFORM(nREDINSS,"@E 999,999,999.99")+"|"
	cDescr += "BASE DE CALCULO DE INSS R$"+TRANSFORM(nBINSS,"@E 999,999,999.99")+" x "+STR(nPInss,5,2)+"% A SER RETIDO R$"+TRANSFORM(nVALINSS,"@E 999,999,999.99")+"|"
ENDIF

IF cCliente $ cXXCVLIQ .OR. STRZERO(VAL(SUBSTR(cCliente,1,3)),6) $ cXXCVLIQ  // CLIENTE SAIR VALOR LIQUIDO NA NF
	IF SUBSTR(cDescr,LEN(cDescr),1) == "|"
   		cDescr += "VALOR LÍQUIDO A PAGAR: R$"+TRANSFORM(SF2->F2_VALBRUT - nTOTIMP,"@E 999,999,999.99")+"|" 
 	ELSE
   		cDescr += "|VALOR LÍQUIDO A PAGAR: R$"+TRANSFORM(SF2->F2_VALBRUT - nTOTIMP,"@E 999,999,999.99")+"|" 
 	ENDIF
ENDIF

IF ALLTRIM(GetMv("MV_CODREG")) == "1"
	cDescr += "Empresa Optante pelo Simples Nacional|" 
ELSE
	cDescr += "|" 
ENDIF

IF !EMPTY(ALLTRIM(GetMv("MV_XXDNFSE")))
	cDescr += ALLTRIM(GetMv("MV_XXDNFSE"))+"|" 
ELSE
	cDescr += "|" 
ENDIF 

cDescr += "|"
cDescr := AltCorpo(cDescr,cNF)

RecLock("SF2",.F.)
SF2->F2_XXCORPO := cDescr
SF2->(MsUnlock())

SA1->(RestArea(aAreaSA1))
SE1->(RestArea(aAreaSE1))
SF2->(RestArea(aAreaSF2))
SD2->(RestArea(aAreaSD2))
SED->(RestArea(aAreaSED))
SC5->(RestArea(aAreaSC5))
CN9->(RestArea(aAreaCN9))
SYP->(RestArea(aAreaSYP))
CTT->(RestArea(aAreaCTT))
CND->(RestArea(aAreaCND))

RestArea(aAreaAtu)

return cDescr
                       

Static Function AltCorpo(cCorpo,cNF)
LOCAL aLin := ARRAY(22),cLin,xLin
LOCAL nI,nJ
Local cTexto
LOCAL oDlgE

cTexto := cCorpo
AFILL(aLin,SPACE(80))

cLin := ""
xLin := ""
nJ   := 1
FOR nI := 1 TO LEN(cTexto)
    xLin := SUBSTR(cTexto,nI,1)
    IF xLin = "|"
    	aLin[nJ] := PAD(cLin,80)
    	nJ++
    	IF nJ > 22
    	   Exit                                          
    	ENDIF
    	cLin := ""
    ELSE
    	cLin += xLin
    ENDIF
NEXT 


Define MsDialog oDlgE Title OemToAnsi ("Edição do Corpo da NFS "+cNF) From 100, 010  To 580,580 Of oDlgE Pixel Style DS_MODALFRAME

@ 010, 002  Say OemToAnsi ("Lin1")  Pixel Of oDlgE
@ 010, 015 MSGET aLin[01] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 020, 002  Say OemToAnsi ("Lin2")  Pixel Of oDlgE
@ 020, 015 MSGET aLin[02] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 030, 015 MSGET aLin[03] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 040, 015 MSGET aLin[04] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 050, 015 MSGET aLin[05] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 060, 015 MSGET aLin[06] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 070, 015 MSGET aLin[07] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 080, 015 MSGET aLin[08] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 090, 015 MSGET aLin[09] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 100, 015 MSGET aLin[10] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 110, 015 MSGET aLin[11] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 120, 015 MSGET aLin[12] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 130, 015 MSGET aLin[13] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 140, 015 MSGET aLin[14] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 150, 015 MSGET aLin[15] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 160, 015 MSGET aLin[16] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 170, 015 MSGET aLin[17] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 180, 015 MSGET aLin[18] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 190, 015 MSGET aLin[19] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 	
@ 200, 015 MSGET aLin[20] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 210, 015 MSGET aLin[21] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 220, 015 MSGET aLin[22] Valid .T. SIZE 210, 010 OF oDlgE PIXEL PICTURE "@!" 

@ 010, 235 BMPBUTTON TYPE 01 ACTION (cTexto:= MontaTxt(aLin),Close(oDlgE))
//@ 025, 235 BMPBUTTON TYPE 02 ACTION MontaTxt()

Activate Dialog oDlgE Center

Return cTexto


Static Function MontaTxt(aLin)
Local nI
Local cTxt := ""


FOR nI := 1 TO LEN(aLin)
   	cTxt += TRIM(aLin[nI])+"|" 
NEXT


// Removendo linhadmin	as em branco do final
DO WHILE .T.
   	IF LEN(cTxt) > 1
	    IF SUBSTR(cTxt,LEN(cTxt),1) = "|"
	       cTxt := SUBSTR(cTxt,1,LEN(cTxt)-1)
	    ELSE
	       EXIT   
	    ENDIF
	ELSE
		EXIT    
	ENDIF
ENDDO	

Return TRIM(cTxt)
  



Static Function QryProc(cAlias,nCampos,cCampos,cWhere)
LOCAL cQuery,aRet := {},nX
LOCAL aAreaTmp

aAreaTmp   := GetArea()

cQuery := "SELECT "+cCampos+" "
cQuery += "FROM "+RETSQLNAME(cAlias)+" "+cAlias+" "
cQuery += "WHERE "+cWhere+" AND D_E_L_E_T_ = ' ' "
TCQUERY cQuery NEW ALIAS "QTMP"
dbSelectArea("QTMP")
dbGotop()
IF !EOF()
	FOR nX := 1 TO nCampos
        AADD(aRet,FIELDGET(nX))
    NEXT    
ENDIF 
dbCloseArea()

RestArea(aAreaTmp)

Return aRet 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BKFATDNFº      Adilson do Prado              Data ³23/03/14º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Inclusao Informação conta vinculada emissão da NF 	      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK Consultoria                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

STATIC Function ContVinc()
Local cCONTA := SF2->F2_XXCVINC
Local nVALOR := SF2->F2_XXVCVIN
Local oTELA01



Define MsDialog oTELA01 Title "Dados conta vinculada NF N°:"+TRIM(SF2->F2_DOC)+"/"+TRIM(SF2->F2_SERIE) From 000,000 To 110,320 Of oTELA01 Pixel Style DS_MODALFRAME
@ 010,010 Say "Conta Vinculada :" Size 060,025 Pixel Of oTELA01
@ 010,075 MSGET cCONTA SIZE 080,010 OF oTELA01 PIXEL PICTURE "@!" HASBUTTON  F3 "SA6_2" VALID NaoVazio(cCONTA)

@ 025,010 Say "Valor Conta Vinculada:" Size 080,008 Pixel Of oTELA01
@ 025,075 MsGet nVALOR  Size 060,008 Pixel Of oTELA01 Picture "@E 999,999,999,999.99" VALID nVALOR > 0

@ 040,010 Button "&Ok" Size 036,013 Pixel Action (GrvSF2(cCONTA,nVALOR),oTELA01:End())
@ 040,060 Button "&Cancelar" Size 036,013 Pixel Action oTELA01:End()
Activate MsDialog oTELA01 Centered


Return .T.


Static Function GrvSF2(cCONTA,nVALOR)

//GRAVA CONTA NO CABECALHO DA NOTA
RecLock("SF2",.F.)
SF2->F2_XXCVINC := cCONTA
SF2->F2_XXVCVIN := nVALOR
MsUnlock("SF2")


Return




//BUSCAR CONTA VINCULADA
USER FUNCTION  BCTAVINC(cCTAVINC)
LOCAL cBcVC := ""
LOCAL cAgVC := ""
LOCAL cCtVC := ""
LOCAL cQuery:= ""
LOCAL aBcVC := {}

cQuery += " SELECT A6_COD,A6_AGENCIA,A6_DVAGE,A6_NUMCON,A6_DVCTA " 
cQuery += " FROM "+RETSQLNAME("SA6")+" SA6"
cQuery += " WHERE SA6.D_E_L_E_T_ = '' "
cQuery += " AND A6_COD+A6_AGENCIA+A6_DVAGE+A6_NUMCON+A6_DVCTA='"+ALLTRIM(cCTAVINC)+"'"

//0011607  1400118774927

If Select("QSA6") > 0
	QSA6->(DbCloseArea())
EndIf

TCQUERY cQuery NEW ALIAS "QSA6"

dbSelectArea("QSA6")
QSA6->(dbGoTop())

If QSA6->(!EOF())
	cBcVC := QSA6->A6_COD                                                                                                                                                                                    
	cAgVC := QSA6->A6_AGENCIA+IIF(!EMPTY(QSA6->A6_DVAGE),"-"+QSA6->A6_DVAGE,"")
	cCtVC := QSA6->A6_NUMCON +IIF(!EMPTY(QSA6->A6_DVCTA),"-"+QSA6->A6_DVCTA,"")
	AADD(aBcVC,cBcVC)
	AADD(aBcVC,cAgVC)
	AADD(aBcVC,cCtVC)
//	QSA6->(dbSkip())
Else
	cBcVC := SUBSTR(cCTAVINC,1, TamSx3("A6_COD")[1])
	cDvAg := SUBSTR(cCTAVINC,9, TamSx3("A6_DVAGE")[1])
	cAgVC := SUBSTR(cCTAVINC,4, TamSx3("A6_AGENCIA")[1])+IIF(!EMPTY(cDvAg),"-"+cDvAg,"")
	cDvCta:= SUBSTR(cCTAVINC,24, TamSx3("A6_DVCTA")[1])
	cCtVC := SUBSTR(cCTAVINC,10, TamSx3("A6_NUMCON")[1])+IIF(!EMPTY(cDvCta),"-"+cDvCta,"")
	AADD(aBcVC,cBcVC)
	AADD(aBcVC,cAgVC)
	AADD(aBcVC,cCtVC)
EndIf

QSA6->(DbCloseArea())

RETURN aBcVC