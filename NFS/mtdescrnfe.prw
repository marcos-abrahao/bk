#include "rwmake.ch"
#INCLUDE "topconn.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} MtDescrNFE
BK - Montagem do corpo da NF de serviços
@author Marcos Bispo Abrahão
@since 
@version P12
@return Nil
/*/

User Function MtDescrNFE()

Local cDescr   := ""
Local cDescr1  := ""
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
Local cPedido	:= ""
Local cContrato := ""
Local cPlanilha := ""
Local cMedicao  := ""
Local cRevisa   := ""
Local cCompet   := ""
Local cParcel	:= ""
Local cEmissor	:= ""
//Local nReg		:= 0

Local cObjeto   := ""
Local cObsMed   := ""
Local cxCompet  := ""
Local cxParcel  := ""
Local cConta    := ""
Local cMun      := ""

Local cVencto   := ""
Local nI
//Local aTmp
Local cImpDtV   := "S"
Local cMenNota  := ""
Local aBancos   := {}
Local nINSSME   := 0 // % REDUCAO BASE ISS MATERIAS
Local nINSSMAT  := 0 // % REDUCAO BASE ISS MATERIAS
Local nREDINSS  := 0 // REDUCAO BASE ISS MATERIAS
Local nBINSS    := 0 // REDUCAO BASE ISS MATERIAS
Local nVALINSS  := 0 // REDUCAO BASE ISS MATERIAS
Local cXXNOISS  := ALLTRIM(GetMv("MV_XXNOISS")) // CLIENTE NÃO SAIR RETENÇÃO DE ISS
Local cXXDSISS  := ALLTRIM(GetMv("MV_XXDSISS"))  // DESCRIÇÃO DA LEI PARA CLIENTE NÃO SAIR RETENÇÃO DE INSS
Local cXXCVLIQ  := ALLTRIM(GetMv("MV_XXCVLIQ")) // CLIENTE SAIR VALOR LIQUIDO NA NF
Local cXXMEDIC  := ALLTRIM(SuperGetMV("MV_XXMEDIC",.F.,"000302")) // CLIENTE SAIR A PALAVRA MEDIÇÃO AO INVES DE PARCELA
Local cXXCOMPE  := ALLTRIM(SuperGetMV("MV_XXCOMPE",.F.,"000058/000163/000193/000194/000195/000196/000197/000198/000199/000211/000215/000239/000241/000242/000245/000305/000316/000317/000318/000319/000320/000321/")) // CLIENTE NAO SAIR COMPETENCIA
Local nQTDIMP   := 0
Local nTOTIMP   := 0
Local lImp 		:= .F.
Local nScan		:= 0
Local aBCVINC 	:= {}
Local cAgVinc 	:= ""
Local cCCVinc 	:= ""
/*
Conforme falamos há alguns dias,das notas do ministerio deverão constar as informações abaixo:
1 - Nº do contrato (dispensando objeto,se for o caso)
2 - Subtotais em linha de "secretarias"/"copeira"/"cargos"
3 - Valor da folha e valor da retenção (conta vinculada)
4 - Dados bancários e retenções de tributos
*/
Local cSemObj	:= "142000579/"
Local lSemObj	:= .F.

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
Local aAreaCNC

Local nMaxTLin := 95

IF FWSM0Util():GetSM0Data( , , { "M0_CIDENT" } )[1][2] = "BARUERI" // Barueri - SP
	nMaxTLin := 100
ENDIF

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

// Aqui
IF !EMPTY(SF2->F2_XXCORPO) .AND. SUBSTR(cNF,1,1) <> "9" // Nota teste começa com 9
//If .F.
	cDescr := TRIM(SF2->F2_XXCORPO)
	cDescr := AltCorpo(cDescr,cNF,cSerie)

	RecLock("SF2",.F.)
	// Aqui
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
aAreaCNC   := GetArea("CNC")
   
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
	cPedido := SD2->D2_PEDIDO
	IF dbSeek(xFilial("SC5") + cPedido)
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

cDescr := ""

IF !Empty(cContrato)

	lSemObj := (TRIM(cContrato)+"/" $ cSemObj)
    // QryProc(cAlias,nCampos,cCampos,cWhere)
    //aTmp := U_QryProc("CND",1,"R_E_C_N_O_","CND_FILIAL = '"+xFilial("CND")+"' AND CND_NUMMED = '"+cMedicao+"' AND CND_REVISA = CND_REVGER")

	dbSelectArea("CN9")
    cRevisa := Space(Len(CN9->CN9_REVISA))
    cObsMed := ""
	cParcel := ""
	cCompet := ""

	/*
	If !Empty(aTmp)
		nReg := aTmp[1]
		dbSelectArea("CND")
    	dbGoTo(nReg)
		cObsMed := TRIM(CND->CND_OBS)
		cRevisa := CND->CND_REVISA
		If TRIM(CND->CND_CONTRA) == '132000464' // CPRM (Obs: pendente de criar campo no CNA para esta função)
			cObsMed += " A gestão financeira do contrato é feita pela CPRM/BH"
		EndIf
	EndIf
	*/

	// Nova Medição
	U_PMedPed(cPedido,cContrato,cMedicao,cPlanilha,@cRevisa,@cCompet,@cParcel,@cObsMed,@cEmissor)

	// Descrição do contrato = descrição do centro de custo
	dbSelectArea("CTT")
	dbSetOrder(1)
	IF dbSeek(xFilial("CTT") + cContrato)
		IF !EMPTY(CTT->CTT_XXDESC)
			cDescr := TRIM(CTT->CTT_XXDESC)+"|"
		ELSE
			cDescr := TRIM(CTT->CTT_DESC01)+"|"
		ENDIF	
	ENDIF

	// Objeto
	cObjeto := ""
	nINSSME := 0
	dbSelectArea("CN9")
	dbSetOrder(1)
	If dbSeek(xFilial("CN9") + cContrato + cRevisa)
		cImpDtV := CN9->CN9_XXIDTV
		nINSSME := CN9->CN9_INSSME
		dbSelectArea ("SYP")
		dbSetOrder(1)
		dbSeek(xFilial("SYP") + CN9->CN9_CODOBJ)
		Do While !EOF() .AND. (xFilial("SYP") + CN9->CN9_CODOBJ) = (SYP->YP_FILIAL + SYP->YP_CHAVE)
		    cObjeto += STRTRAN(TRIM(SYP->YP_TEXTO),"\13\10","")   //+"|"
			dbSkip()
		Enddo
		cObjeto := STRTRAN(TRIM(cObjeto),"|"," ")
	EndIf
	
	If !lSemObj
		For nI:= 1 To MLCOUNT(cObjeto,nMaxTLin)
			cDescr += TRIM(MEMOLINE(cObjeto,nMaxTLin,nI))+"|"
		Next
	EndIf

	//IF !EMPTY(cObjeto)
	//	cObjeto1 += "|"
	//ENDIF	
	//FOR nI:= 1 to MLCOUNT(cObsMed,nMaxTLin)
	//	cLin := 
	//	cObjeto1 += TRIM(MEMOLINE(cObsMed,nMaxTLin,nI))+"|"
	//NEXT

	//cLastLin := ""
	//FOR nI:= 1 to MLCOUNT(cObsMed,nMaxTLin)
	//	cNewLin := STRTRAN(TRIM(MEMOLINE(cObsMed,nMaxTLin,nI)),CHR(13)+CHR(10),"")
	//	nTamLast := LEN(cLastLin)
	//	If nTamLast > 0
	//		nTamLast += 3
	//	EndIf
	//	If !Empty(cNewLin)
	//		If (LEN(cNewLin) + nTamLast) > nMaxTlin 
	//			cObjeto1 += IIF(!EMPTY(cLastLin),cLastLin+"|","")
	//			cLastLin := cNewLin
	//		ElseIf (LEN(cNewLin) + nTamLast) = nMaxTlin
	//			cObjeto1 += IIF(!EMPTY(cLastLin),cLastLin+"|","")
	//			cObjeto1 += IIF(!EMPTY(cNewLin),cNewLin+"|","")
	//			cLastLin := ""
	//		Else
	//			cLastLin += IIF(!EMPTY(cLastLin)," - ","")+cNewLin
	//		EndIf
	//	EndIf
	//NEXT
	//If !Empty(cLastLin)
	//	cObjeto1 += cLastLin+"|"
	//EndIf

	If !lSemObj
		cDescr1 += cObsMed+CRLF
	EndIf

	cxCompet := ""
	cxParcel := ""
	If AllTrim(cContrato) <> '307000496' .AND. AllTrim(cContrato) <> '385000596' // VOA-SE //.AND. ALLTRIM(cContrato) <> "305000554" //criado para atendimento emergencial - 10/02/2023
		If !(AllTrim(cCliente) $ cXXCOMPE)
   			cxCompet  := "Competencia: "+cCompet
		EndIf
		If AllTrim(cCliente) $ cXXMEDIC
   			cxParcel := " "+cParcel+"ª Medicao"
   		Else
	   		cxParcel := "Parcela: "+cParcel
   		EndIf
    EndIf

	/*
	dbSelectArea("CND")
	dbSetOrder(4)
	IF dbSeek(xFilial("CND") + cMedicao)
		IF AllTrim(CND->CND_CONTRA) <> '307000496'
			IF !(AllTrim(CND->CND_CLIENT) $ cXXCOMPE)
	   			cxCompet  := "Competencia: "+CND->CND_COMPET
			ENDIF
			IF AllTrim(CND->CND_CLIENT) $ cXXMEDIC
				// Aqui, verificar se existe CXN e pegar a parcela do CXN
	   			cxParcel := " "+CND->CND_PARCELA+"ª MEDICAO"
	   		ELSE
	   			cxParcel := "Parcela: "+CND->CND_PARCELA
	   		ENDIF
	   ENDIF
	ENDIF
	*/

	cMun   := ""
	cConta := ""
	dbSelectArea("SA1")
	dbSetOrder(1)
	IF dbSeek(xFilial("SA1")+cCliente+cLoja)
	   IF !EMPTY(SA1->A1_XXCTABC)
	      cConta := TRIM(SA1->A1_XXCTABC)
	   ENDIF   
	   // cMun := "Municipio: "+TRIM(Posicione("CC2",1,xFilial("CC2")+SA1->A1_EST+SA1->A1_COD_MUN,"CC2_MUN"))+" - "+SA1->A1_EST
	ENDIF
	// Se tiver conta no CNC, usar - 31/01/2021.
	dbSelectArea("CNC")
	dbSetOrder(3)
	IF dbSeek(xFilial("CNC")+cContrato+cRevisa+cCliente+cLoja)
	   IF !EMPTY(CNC->CNC_XCTABC)
	      cConta := TRIM(CNC->CNC_XCTABC)
	   ENDIF   
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
    	   cxCompet := IIF(!EMPTY(cxCompet),cxCompet+" - ","") + cxParcel
    	ENDIF
    ENDIF

ELSE
	// NF que não é serviço de contrato
	IF !EMPTY(SC5->C5_XXDNFS)
		//cXXDNFS := ""
		//cXXDNFS := TRIM(SC5->C5_XXDNFS)
		//FOR nI:= 1 to MLCOUNT(cXXDNFS,nMaxTLin)
		//	cDescr1 += TRIM(MEMOLINE(cXXDNFS,nMaxTLin,nI))+"|"
		//NEXT

		cDescr1 += TRIM(SC5->C5_XXDNFS)+CRLF
   		cDescr1 += cMenNota+CRLF
    	nPIss:= SB1->B1_ALIQISS
    ELSE
    	IF !EMPTY(cProduto)
    		SB1->(dbSeek(xFilial("SB1")+cProduto))
    		cDescr1 := TRIM(SB1->B1_DESC)+CRLF
    		cDescr1 += cMenNota+CRLF
   	    	nPIss:= SB1->B1_ALIQISS
    	ENDIF
    ENDIF

	cConta := ""
	dbSelectArea("SA1")
	dbSetOrder(1)
	IF dbSeek(xFilial("SA1")+cCliente+cLoja)
	   IF !EMPTY(SA1->A1_XXCTABC)
	      cConta := TRIM(SA1->A1_XXCTABC)
	   ENDIF   
	ENDIF
ENDIF 
  
cVencto := ""
SE1->(Dbsetorder(1))
SE1->(DbSeek(xFilial("SE1")+SF2->F2_PREFIXO+SF2->F2_DOC,.T.))
DO WHILE !SE1->(EOF()) .AND. SE1->E1_FILIAL == xFilial("SE1") .AND. SE1->E1_PREFIXO == SF2->F2_PREFIXO .AND. SE1->E1_NUM == SF2->F2_DOC
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

//criado para atendimento emergencial - 10/02/2023
//IF ALLTRIM(cContrato) == "305000554" 
//	cVencto := "Posto Adicional Poupatempo 4.0 - Modelo"
//ENDIF


cDescr1 += cVencto+IIF(!EMPTY(cVencto) .AND. !EMPTY(cxCompet)," - ","")+cxCompet+CRLF

IF !EMPTY(cMun)
	cDescr1 += cMun+CRLF
ENDIF	

IF !EMPTY(cConta)
	cDescr1 += cConta+CRLF
ENDIF	

If lSemObj // Não encurtar a observação da medição
	cDescr += STRTRAN(ALLTRIM(cObsMed),CHR(13)+CHR(10),"|")+"|"
EndIf

//// AQUI
cDescr += TextoNF(cDescr1,nMaxTLin)

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
   cImpost += "IRRF: "+PicPer(nPIrrf,5,2)+"% R$"+ALLTRIM(TRANSFORM(SF2->F2_VALIRRF,"@E 999,999.99"))+CRLF //IIF(nQTDIMP==3,"|",SPACE(4))//+IIF(lImp,"|",SPACE(10))
   lImp := !lImp
   IF nQTDIMP==3
   		nQTDIMP := 0
   ENDIF
ENDIF
IF SF2->F2_VALPIS > 0
   nTOTIMP += SF2->F2_VALPIS
   ++nQTDIMP
   cImpost += "PIS: "+PicPer(nPPis,5,2)+"% R$"+ALLTRIM(TRANSFORM(SF2->F2_VALPIS,"@E 999,999.99"))+CRLF //IIF(nQTDIMP==3,"|",SPACE(4))//+IIF(nQTDIMP==3,"|",SPACE(4))//+IIF(lImp,"|",SPACE(10))
   lImp := !lImp
   IF nQTDIMP==3
   		nQTDIMP := 0
   ENDIF
ENDIF
IF SF2->F2_VALCOFI > 0
   nTOTIMP += SF2->F2_VALCOFI
   ++nQTDIMP
   cImpost += "COFINS: "+PicPer(nPCofins,5,2)+"% R$"+ALLTRIM(TRANSFORM(SF2->F2_VALCOFI,"@E 999,999.99"))+CRLF  //IIF(nQTDIMP==3,"|",SPACE(4))//+IIF(lImp,"|",SPACE(10))
   lImp := !lImp
   IF nQTDIMP==3
   		nQTDIMP := 0
   ENDIF
ENDIF
IF SF2->F2_VALCSLL > 0
   nTOTIMP += SF2->F2_VALCSLL
   ++nQTDIMP
   cImpost += "CSLL: "+PicPer(nPCsll,5,2)+"% R$"+ALLTRIM(TRANSFORM(SF2->F2_VALCSLL,"@E 999,999.99"))+CRLF //+IIF(nQTDIMP==3,"|",SPACE(4))//+IIF(lImp,"|",SPACE(10))
   lImp := !lImp
   IF nQTDIMP==3
   		nQTDIMP := 0
   ENDIF
ENDIF
IF !cCliente $ cXXNOISS .AND. !STRZERO(VAL(SUBSTR(cCliente,1,3)),6) $ cXXNOISS
	IF SF2->F2_VALISS > 0  .AND. SF2->F2_RECISS = "1"
   		nTOTIMP += SF2->F2_VALISS
  	 	++nQTDIMP
  	 	cImpost += "ISS: "+PicPer(nPIss,5,2)+"% R$"+ALLTRIM(TRANSFORM(SF2->F2_VALISS,"@E 999,999.99"))+CRLF //+IIF(nQTDIMP==3,"|",SPACE(4))//+IIF(lImp,"|",SPACE(10))
  	 	lImp := !lImp
  	 	IF nQTDIMP==3
   			nQTDIMP := 0
  	 	ENDIF
	ENDIF
ENDIF

IF SF2->F2_VALINSS > 0
   nTOTIMP += SF2->F2_VALINSS
   ++nQTDIMP
   IF cCliente == "000044"  // CPOS
      cImpost += "Retencao para a previdencia social: "
   ELSEIF cCliente == '000142'
      cImpost += "BASE INSS: "+ALLTRIM(TRANSFORM(SF2->F2_BASEINS,"@E 9,999,999.99")+ " INSS: ")
   ELSE
      cImpost += "INSS: "
   ENDIF
   cImpost += PicPer(nPInss,5,2)+"% R$"+ALLTRIM(TRANSFORM(SF2->F2_VALINSS,"@E 999,999.99"))+CRLF //+IIF(nQTDIMP==3,"|",SPACE(4))//+IIF(lImp,"|",SPACE(10))
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
	cImpost += "FUMDIP: "+PicPer(SF2->F2_XXAFUMD,5,2)+"% R$"+ALLTRIM(TRANSFORM(SF2->F2_XXVFUMD,"@E 999,999.99"))+CRLF //+IIF(nQTDIMP==3,"|",SPACE(4))
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
   cImpost := "Impostos a serem retidos: "+cImpost
   cDescr  += TextoNF(cImpost,nMaxTLin)
ENDIF

IF cCliente $ cXXNOISS .OR. STRZERO(VAL(SUBSTR(cCliente,1,3)),6) $ cXXNOISS //ADICIONA DESCRIÇÃO DA LEI PARA CLIENTE NÃO SAIR RETENÇÃO DE INSS
	IF !EMPTY(cXXDSISS)
		IF SUBSTR(cDescr,LEN(cDescr),1) == "|"
			cDescr += cXXDSISS+"|"+aBancos
		ELSE
			cDescr += "|"+cXXDSISS+"|"
		ENDIF
	ENDIF 
ENDIF

cDescr1 := "" 

//INFORMACAO CONTA VINCULADA 
IF !EMPTY(SF2->F2_XXCVINC) .OR. SF2->F2_XXVCVIN > 0 
	IF ContVinc(cContrato,cRevisa,cPlanilha)
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
		cDescr1 += "Deposito para vinculada = "+aBancos[nScan,2]+"-Ag.: "+ALLTRIM(cAgVinc)+" C/C: "+ALLTRIM(cCCVinc)+CRLF //  IIF(nMaxTLin>80," ","|")
		cDescr1 += "R$"+ALLTRIM(TRANSFORM(SF2->F2_XXVCVIN,"@E 999,999,999.99"))+CRLF
	ENDIF
ELSE
	//IF MsgYesNo("Nota Fiscal N°:"+TRIM(SF2->F2_DOC)+"/"+TRIM(SF2->F2_SERIE)+" possui dados conta vinculada?" )
	
	// 07/02/2022 - Filtrar somente os clientes abaixo para pedir conta vinculada (Pedido pelo João Cordeiro) provisoriamente.
	If cEmpAnt == '01' .AND. (SF2->F2_CLIENTE + SF2->F2_LOJA + "/" $ "00014201/00014202/00014801/00023001/00016401/00038701/")

		/*
		000142	01	MINISTERIO DA FAZENDA                   
		000148	01	MINISTERIO DA FAZENDA 
		000230	01	MINISTERIO DA FAZENDA                   
		000164	01	TRIBUNAL REGIONAL FEDERAL DA 3A REGIAO
		000387	01	AMAZONIA AZUL TECNOLOGIAS DE DEFESA S.A - AMAZUL                                
		*/

		IF ContVinc(cContrato,cRevisa,cPlanilha)
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
			cDescr1 += "Deposito para vinculada = "+aBancos[nScan,2]+"-Ag.: "+ALLTRIM(cAgVinc)+" C/C: "+ALLTRIM(cCCVinc)+CRLF //IIF(nMaxTLin>80," ","|")
			cDescr1 += "R$ "+ALLTRIM(TRANSFORM(SF2->F2_XXVCVIN,"@E 999,999,999.99"))+CRLF

		ENDIF
	ENDIF
ENDIF

cDescr  += TextoNF(cDescr1,nMaxTLin)

//INFORMACAO RETENÇÃO CONTRATUAL
IF !EMPTY(SF2->F2_XXVRETC)
	IF SUBSTR(cDescr,LEN(cDescr),1) <> "|"
		cDescr += "|"
	ENDIF
	cDescr += "Retenção Contratual ("+PicPer(SF2->F2_XXRETC,5,2)+"%): R$ "+ALLTRIM(TRANSFORM(SF2->F2_XXVRETC,"@E 999,999,999.99"))+"|"
ENDIF

IF nINSSME > 0
	nINSSMAT := 100 - nINSSME
	cDescr1  := ""
	nREDINSS := 0
	nBINSS 	 := 0
	nVALINSS := 0

	nREDINSS := SF2->F2_VALBRUT - SF2->F2_BASEINS //SF2->F2_VALBRUT * (nINSSME/100)
	nBINSS 	 := SF2->F2_BASEINS //SF2->F2_VALBRUT - nREDINSS
	nVALINSS := SF2->F2_VALINSS //nBINSS * (nPInss/100)
	If ALLTRIM(cContrato) == '386000609'
		cDescr1 += "FORNECIMENTO DE MATERIAIS "+PicPer(nINSSMAT,5,2)+"% = R$ "+ALLTRIM(TRANSFORM(nREDINSS,"@E 999,999,999.99"))+" FORNECIMENTO DE MAO DE OBRA "+PicPer(nINSSME,5,2)+"% = R$ "+ALLTRIM(TRANSFORM(nBINSS,"@E 999,999,999.99"))+CRLF
	Else
		cDescr1 += "VALOR DA NOTA FISCAL R$ "+ALLTRIM(TRANSFORM(SF2->F2_VALBRUT,"@E 999,999,999.99"))+CRLF
		cDescr1 += "(-) "+PicPer(nINSSME,5,2)+"% REDUÇÃO DO INSS POR FORNECIMENTO DE MATERIAIS R$ "+ALLTRIM(TRANSFORM(nREDINSS,"@E 999,999,999.99"))+CRLF
		cDescr1 += "BASE DE CALCULO DE INSS R$ "+ALLTRIM(TRANSFORM(nBINSS,"@E 999,999,999.99"))+" x "+PicPer(nPInss,5,2)+"% A SER RETIDO R$ "+ALLTRIM(TRANSFORM(nVALINSS,"@E 999,999,999.99"))+CRLF
	EndIf

	cDescr  += TextoNF(cDescr1,nMaxTLin)

ENDIF

cDescr1 := ""
IF cCliente $ cXXCVLIQ .OR. STRZERO(VAL(SUBSTR(cCliente,1,3)),6) $ cXXCVLIQ  // CLIENTE SAIR VALOR LIQUIDO NA NF
	cDescr1 += "VALOR LÍQUIDO A PAGAR: R$ "+ALLTRIM(TRANSFORM(SF2->F2_VALBRUT - nTOTIMP,"@E 999,999,999.99"))+CRLF
ENDIF

cDescr  += TextoNF(cDescr1,nMaxTLin)

IF cEmpAnt == '14' // Balsa - Solicitado pelo Jalielison em 01/02/2022
	cDescr += "O serviço desta Nota Fiscal foi prestado na seguinte proporção:|"
	cDescr += "97,75% pela BK Consultoria e Serviços Ltda 03.022.122/0001-77|"
	cDescr += "2,25% pela Trairi Comércio de Derivados de Petroleo Ltda 04.811.052/0001-07"
ELSEIF cEmpAnt == '18' // BK VIA
	cDescr += "O serviço desta Nota Fiscal foi prestado na seguinte proporção:|"
	cDescr += "95% pela BK Consultoria e Serviços Ltda 03.022.122/0001-77|"
	cDescr += "5% pela INNOVIA Soluções Inteligentes Ltda 30.097.217/0001-01"
ENDIF

//criado para atendimento emergencial - 10/02/2023
//IF ALLTRIM(cContrato) == "305000554" 
//	cDescr := Acento( cDescr )
//	cDescr := STRTRAN( cDescr, "PRODESP PRO 00 7647 CONS.BHG INTERIOR L-03", "PRODESP PRO 00 7647 CONS.BHG INTERIOR L-03 - REAJUSTE")
//	cDescr := STRTRAN( cDescr, "PRESTACAO DE SERVICO DE GESTAO  OPERACAO E MANUTENCAO DOS POSTOS DE ATENDIMENTO DO POUPATEMPO DO", "PRESTACAO DE SERVICO DE GESTAO,OPERACAO E MANUTENCAO DOS POSTOS DE ATENDIMENTO DO POUPATEMPO")
//	cDescr := STRTRAN( cDescr, "|LOTE 3 DO PREGAO ELETRONICO Nº 008/2020.|", "|")
//	cDescr := STRTRAN( cDescr, "Banco do Brasil Ag:3320-0 Cc:177676-2", "")
//ENDIF
If SF2->F2_CLIENTE == '000367'
	cDescr += "|ISS DEVIDO AO MUNICIPIO DE BARUERI CONFORME LEI COMPLEMENTAR 235 DE| 03/11/2021 - MUNICIPAL - RIO DE JANEIRO - EM SEU ARTIGO NUMERO 35"
EndIf
If ALLTRIM(cContrato) == '386000609'  // CICLOFAIXA 19/06/23
	//cDescr += '"Conforme item 6.3 do Instrumento Particular de Constituição do Consórcio Moove-SP, o faturamento é|segregado de acordo com as atribuições das consorciadas: '
	//cDescr += 'INNOVIA SOLUÇÕES INTELIGENTES LTDA.- dispon|ibilização dos equipamentos, sinalização e montagem da ciclofaixa '
	//cDescr += 'BK CONSULTORIA E SERVIÇOS LTDA.- contratação e disponibilização da mão de obra alocada no contrato."'
	cDescr += '"CONFORME ITEM 6.3 DO INSTRUMENTO DE CONSTITUICAO DO CONSORCIO MOOVE-SP, O FATURAMENTO E SEGREGADO |'
	cDescr += 'DE ACORDO COM AS ATRIBUICOES DAS CONSORCIADAS: INNOVIA SOLUCOES INTELIGENTES LTDA.-DISPONIBILIZACAO|'
	cDescr += 'DOS EQUIPAMENTOS, SINALIZACAO E MONTAGEM DA CICLOFAIXA, BK CONSULTORIA E SERVICOS LTDA.-MAO DE OBRA|'
	cDescr += 'ALOCADA" '
EndIf
//"CONFORME ITEM 6.3 DO INSTRUMENTO DE CONSTITUICAO DO CONSORCIO MOOVE-SP: INNOVIA SOLUCOES INTELIGENT
//TES LTDA.- DISPONIBILIZACAO DOS EQUIPAMENTOS, SINALIZACAO E MONTAGEM DA CICLOFAIXA 
//BK CONSULTORIA E SERVICOS LTDA.- MAO DE OBRA ALOCADA"                                               

IF ALLTRIM(GetMv("MV_CODREG")) == "1"
	cDescr1 := "|Empresa Optante pelo Simples Nacional"
	cDescr  += TextoNF(cDescr1,nMaxTLin)
ENDIF

IF !EMPTY(ALLTRIM(GetMv("MV_XXDNFSE")))
	cDescr1 := "|"+ALLTRIM(GetMv("MV_XXDNFSE"))+CRLF
	cDescr  += TextoNF(cDescr1,nMaxTLin)
ENDIF 

cDescr := AltCorpo(cDescr,cNF,cSerie)


RecLock("SF2",.F.)
// Aqui 
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
CNC->(RestArea(aAreaCNC))

RestArea(aAreaAtu)

return cDescr


// Retorna o Percentual em caracteres sem .00 no final
Static Function PicPer(nAliq,nT,nD)
Local cAliq := ALLTRIM(STR(nAliq,nT,nD))
If ("."+Replicate("0",nD)) $ cAliq
	cAliq := STRTRAN(cAliq,"."+Replicate("0",nD),"")
EndIf
Return cAliq

Static Function Acento( cTexto )
Local cAcentos:= "Ç ç Ä À Â Ã Å à á ã ä å É È Ê Ë è é ê ë Ì Í Î Ï Ò Ó Ô Õ Ö ò ó ô õ ö Ù Ú Û Ü ù ú û ü Ñ ñ , ; "
Local cAcSubst:= "C c A A A A A a a a a a E E E E e e e e I I I I O O O O O o o o o o U U U U u u u u N n     "
Local cImpCar := ""
Local cImpLin := ""
Local nChar   := 0.00
Local nChars  := 0.00
Local nAt     := 0.00     

cTexto := IF( Empty( cTexto ) .or. ValType( cTexto ) != "C", "" , cTexto )

nChars := Len( cTexto )
For nChar := 1 To nChars
     cImpCar := SubStr( cTexto , nChar , 1 )
     IF ( nAt := At( cImpCar , cAcentos ) ) > 0
          cImpCar := SubStr( cAcSubst , nAt , 1 )
     EndIF
     cImpLin += cImpCar
Next nChar

Return( cImpLin )


// Tela para alterar o corpo da NF
Static Function AltCorpo(cCorpo,cNF,cSerie)
LOCAL aLin ,cLin,xLin
LOCAL nI,nJ
Local cTexto
LOCAL oDlgE
Local nMaxTLin := 95
Local nMaxLin  := 22
Local nMaxGet  := 22

If FWSM0Util():GetSM0Data( , , { "M0_CIDENT" } )[1][2] = "BARUERI" //  Barueri - SP
	nMaxTLin := 100
	nMaxGet  := 13
EndIf

If cSerie == '006'   // Rio de Janeiro
	nMaxTLin := 95
EndIf'

aLin   := ARRAY(nMaxLin)
cTexto := cCorpo+"|"

AFILL(aLin,SPACE(nMaxTLin))

cLin := ""
xLin := ""
nJ   := 1
FOR nI := 1 TO LEN(cTexto)
    xLin := SUBSTR(cTexto,nI,1)
    IF xLin = "|"
    	aLin[nJ] := PAD(cLin,nMaxTLin)
    	nJ++
    	IF nJ > nMaxLin
    	   Exit                                          
    	ENDIF
    	cLin := ""
    ELSE
    	cLin += xLin
    ENDIF
NEXT 

Define MsDialog oDlgE Title OemToAnsi ("Descrição do Serviço da NFS "+cNF) From 100, 010  To 610,690 Of oDlgE Pixel Style DS_MODALFRAME

@ 012, 005  Say OemToAnsi ("01")  Pixel Of oDlgE
@ 010, 015 MSGET aLin[01] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 022, 005  Say OemToAnsi ("02")  Pixel Of oDlgE
@ 020, 015 MSGET aLin[02] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 032, 005  Say OemToAnsi ("03")  Pixel Of oDlgE
@ 030, 015 MSGET aLin[03] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 042, 005  Say OemToAnsi ("04")  Pixel Of oDlgE
@ 040, 015 MSGET aLin[04] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 052, 005  Say OemToAnsi ("05")  Pixel Of oDlgE
@ 050, 015 MSGET aLin[05] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 062, 005  Say OemToAnsi ("06")  Pixel Of oDlgE
@ 060, 015 MSGET aLin[06] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 072, 005  Say OemToAnsi ("07")  Pixel Of oDlgE
@ 070, 015 MSGET aLin[07] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 082, 005  Say OemToAnsi ("08")  Pixel Of oDlgE
@ 080, 015 MSGET aLin[08] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 092, 005  Say OemToAnsi ("09")  Pixel Of oDlgE
@ 090, 015 MSGET aLin[09] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 102, 005  Say OemToAnsi ("10")  Pixel Of oDlgE
@ 100, 015 MSGET aLin[10] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 112, 005  Say OemToAnsi ("11")  Pixel Of oDlgE
@ 110, 015 MSGET aLin[11] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 122, 005  Say OemToAnsi ("12")  Pixel Of oDlgE
@ 120, 015 MSGET aLin[12] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 132, 005  Say OemToAnsi ("13")  Pixel Of oDlgE
@ 130, 015 MSGET aLin[13] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 142, 005  Say OemToAnsi ("14")  Pixel Of oDlgE
@ 140, 015 MSGET aLin[14] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 152, 005  Say OemToAnsi ("15")  Pixel Of oDlgE
@ 150, 015 MSGET aLin[15] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 162, 005  Say OemToAnsi ("16")  Pixel Of oDlgE
@ 160, 015 MSGET aLin[16] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 172, 005  Say OemToAnsi ("17")  Pixel Of oDlgE
@ 170, 015 MSGET aLin[17] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 182, 005  Say OemToAnsi ("18")  Pixel Of oDlgE
@ 180, 015 MSGET aLin[18] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 192, 005  Say OemToAnsi ("19")  Pixel Of oDlgE
@ 190, 015 MSGET aLin[19] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 	
@ 202, 005  Say OemToAnsi ("20")  Pixel Of oDlgE
@ 200, 015 MSGET aLin[20] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 212, 005  Say OemToAnsi ("21")  Pixel Of oDlgE
@ 210, 015 MSGET aLin[21] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 
@ 222, 005  Say OemToAnsi ("22")  Pixel Of oDlgE
@ 220, 015 MSGET aLin[22] Valid .T. SIZE 320, 010 OF oDlgE PIXEL PICTURE "@!" 

@ 240, 150 BMPBUTTON TYPE 01 ACTION (cTexto:= MontaTxt(aLin),Close(oDlgE))


ACTIVATE MSDIALOG oDlgE CENTERED Valid(VldGets(aLin,nMaxGet)) 
//Activate Dialog oDlgE Center

Return cTexto


Static Function VldGets(aLin,nMaxGets)
Local lTxtOk	:= .T.
Local nX 		:= 0
Local yTexto    := ""

For nX := 1 TO LEN(aLin)
	If nX > nMaxGets .and. !Empty(aLin[nX])
		lTxtOk := .F.
		MSGSTOP("Maximo de linhas permitidas "+ALLTRIM(STR(nMaxGets))+", corrija o texto!!","MTDESCRNFE")
		Exit
	EndIf
Next

If lTxtOk
	yTexto := MontaTxt(aLin)
	If Len(yTexto) > 1000
		lTxtOk := .F.
		MSGSTOP("Maximo de 1000 caracteres permitidos foi excedido: "+ALLTRIM(STR(LEN(yTexto)))+", corrija o texto!!","MTDESCRNFE")
	EndIf
EndIf

Return lTxtOk


Static Function MontaTxt(aLin)
Local nI
Local cTxt := ""


FOR nI := 1 TO LEN(aLin)
   	cTxt += ALLTRIM(aLin[nI])+"|" 
NEXT


// Removendo linha em branco do final
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
  




User Function PMedPed(cPedido,cContrato,cMedicao,cPlanilha,cRevisa,cCompet,cParcel,cObsMed,cEmissor)

Local cQuery 	:= ""
Local aAreaTmp


aAreaTmp   := GetArea()

cQuery := "SELECT CND_CONTRA,CND_NUMMED,CND_REVISA,CND_COMPET,CND_PARCEL,CND_USUAR,CONVERT(VARCHAR(1024),CONVERT(Binary(1024),CND_OBS)) CND_OBS"
cQuery += " FROM "+RETSQLNAME("CND")+" CND "
cQuery += " WHERE CND.D_E_L_E_T_ = ' ' AND CND_FILIAL = '"+xFilial("CND")+"' "
cQuery += "       AND CND_NUMMED = '"+cMedicao+"' AND CND_REVISA = CND_REVGER"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP",.T.,.T.)
dbSelectArea("QTMP")
dbGotop()
If !Eof()
	cRevisa := QTMP->CND_REVISA
	cCompet	:= QTMP->CND_COMPET
	cParcel := QTMP->CND_PARCEL
	cObsMed := QTMP->CND_OBS
	cEmissor:= QTMP->CND_USUAR
EndIf
dbCloseArea()

// Nova Medição
cQuery := "SELECT CXN_CONTRA,CXN_NUMMED,CXN_REVISA,CXN_PARCEL,CND_COMPET,CND_USUAR,CONVERT(VARCHAR(1024),CONVERT(Binary(1024),CXN_XXOBS)) CXN_XXOBS"
cQuery += " FROM "+RETSQLNAME("CXN")+" CXN "
cQuery += " INNER JOIN "+RETSQLNAME("CND")+" CND "
cQuery += "       ON CND.D_E_L_E_T_='' AND CND_FILIAL = '"+xFilial("CND")+"' "
cQuery += "       AND CND_NUMMED = CXN_NUMMED AND CXN_REVISA = CND_REVGER AND CND_REVISA = CND_REVGER"
cQuery += " WHERE CXN.D_E_L_E_T_ = '' AND CXN_FILIAL = '"+xFilial("CXN")+"' "
cQuery += "       AND CXN_NUMMED = '"+cMedicao+"' AND CXN_NUMPLA = '"+cPlanilha+"' AND CXN_CHECK = 'T'"
cQuery := ChangeQuery(cQuery)

//u_LogMemo("MTDESCRNFE.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP",.T.,.T.)
dbSelectArea("QTMP")
dbGotop()
If !EOF()
	cRevisa := QTMP->CXN_REVISA
	cCompet	:= QTMP->CND_COMPET
	cParcel := QTMP->CXN_PARCEL
	cObsMed := QTMP->CXN_XXOBS
	cEmissor:= QTMP->CND_USUAR
EndIf
dbCloseArea()

If Trim(cContrato) == '132000464' // CPRM (Obs: pendente de criar campo no CNA para esta função)
	cObsMed += " A gestão financeira do contrato é feita pela CPRM/BH"
EndIf

RestArea(aAreaTmp)

Return Nil



User Function QryProc(cAlias,nCampos,cCampos,cWhere,cInner)
Local cQuery	:= ""
Local aRet 		:= {}
Local nX		:= 0
Local aAreaTmp
Default cInner	:= ""

aAreaTmp   := GetArea()

cQuery := "SELECT "+cCampos+" "
cQuery += "FROM "+RETSQLNAME(cAlias)+" "+cAlias+" "
If !Empty(cInner)
	cQuery += "INNER JOIN "+cInner
EndIf
cQuery += "WHERE "+cWhere+" AND "+cAlias+".D_E_L_E_T_ = ' ' "
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

/*/{Protheus.doc} ContVinc
	Inclusao Informação conta vinculada emissão da NF 
	@type  Function
	@author Adilson do Prado 
	@since 23/03/14
	@version 12.1.33
	/*/
/*
Static Function xContVinc()
Local cConta := SF2->F2_XXCVINC
Local nValor := SF2->F2_XXVCVIN
Local oTELA01
Local lRet := .T.

Define MsDialog oTELA01 Title "Dados conta vinculada NF N°:"+TRIM(SF2->F2_DOC)+"/"+TRIM(SF2->F2_SERIE) From 000,000 To 110,320 Of oTELA01 Pixel Style DS_MODALFRAME
@ 010,010 Say "Conta Vinculada :" Size 060,025 Pixel Of oTELA01
@ 010,075 MSGET cConta SIZE 080,010 OF oTELA01 PIXEL PICTURE "@!" HASBUTTON  F3 "SA6_2" //VALID NaoVazio(cConta)

@ 025,010 Say "Valor Conta Vinculada:" Size 080,008 Pixel Of oTELA01
@ 025,075 MsGet nValor  Size 060,008 Pixel Of oTELA01 Picture "@E 999,999,999,999.99" //VALID nValor > 0

@ 040,010 Button "&Ok" Size 036,013 Pixel Action (GrvSF2(cConta,nValor),oTELA01:End())
@ 040,060 Button "&Cancelar" Size 036,013 Pixel Action (lRet := .F.,oTELA01:End())
Activate MsDialog oTELA01 Centered
If nValor == 0
	lRet := .F.
Endif
Return lRet
*/

Static Function ContVinc(cContrato,cRevisa,cPlanilha)
	Local lRet 		:= .T.
	Local aSize 	as Array
	Local oDlg  	as Object
	Local nTop		:= 200
	Local nLeft		:= 600
	Local cMot		:= ""
	Local cMun 		:= ""
	Local cCli 		:= ""

	Local oCliente 	as Object
	Local oPlanilha as Object
	Local oMotivo	as Object

	/* Teste
	dbSelectArea("SF2")
	dbGoTo(60120)
	cContrato :="387000608"
	cPlanilha := "000003"
	cRevisa   := "003"
	*/

	MotCNA(cContrato,cRevisa,cPlanilha,@cMot,@cMun)

	cCli := SF2->F2_CLIENTE+"-"+SF2->F2_LOJA+" "+Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NOME")
	cConta := SF2->F2_XXCVINC
	nValor := SF2->F2_XXVCVIN

	aSize := FWGetDialogSize( oMainWnd )

	oDlg := TDialog():New(nTop,nLeft,aSize[3],aSize[4],"Dados conta vinculada NF:"+TRIM(SF2->F2_SERIE)+'-'+TRIM(SF2->F2_DOC),,,,,CLR_BLACK,CLR_WHITE,,,.T.,,,,,,)

    oDlg:nClientHeight  := aSize[3]
    oDlg:nClientWidth   := aSize[4]

	oDlg:Refresh()

	EnchoiceBar(oDlg,{|| lRet:= .T.,oDlg:End() },{|| lRet:= .F.,oDlg:End() })

   	oLayer := FWLayer():new()
    oLayer:init(oDlg,.F.)

    oLayer:addCollumn ('Col1',100,.F.)

    oLayer:addWindow('Col1', 'WinTop' ,'Dados da Medição' ,30,.F.,.F.,,,)
    oLayer:addWindow('Col1', 'WinGrid','Dados conta vinculada' ,70,.F.,.F.,,,)

	oPanelUp := oLayer:getWinPanel('Col1','WinTop')
	oPanelDown := oLayer:getWinPanel('Col1','WinGrid')
   
	// Painel Top
	@ 04, 010 SAY   "Cliente:" SIZE 050,007 OF oPanelUp PIXEL
	@ 04, 075 MSGET oCliente Var cCli SIZE 300,010	OF oPanelUp PIXEL WHEN .F. 

	@ 14, 010 SAY   "Planilha "+cPlanilha SIZE 050,007 OF oPanelUp PIXEL
	@ 14, 075 MSGET oPlanilha Var cMun SIZE 300,010	OF oPanelUp PIXEL WHEN .F. 

	@ 24, 010 SAY   "Motivo:" SIZE 050,007 OF oPanelUp PIXEL
	@ 24, 075 MSGET oMotivo Var cMot SIZE 300,010	OF oPanelUp PIXEL WHEN .F. 

	@ 010,010 SAY   "Conta Vinculada :" SIZE 060,025 Pixel Of oPanelDown
	@ 010,075 MSGET cConta SIZE 080,010 OF oPanelDown PIXEL PICTURE "@!" HASBUTTON  F3 "SA6_2"

	@ 025,010 SAY   "Valor Conta Vinculada:" SIZE 080,008 Pixel Of oPanelDown
	@ 025,075 MSGET nValor  SIZE 060,008 Pixel Of oPanelDown Picture "@E 999,999,999,999.99" HASBUTTON

	oDlg:Activate()

	If lRet
		GrvSF2(cConta,nValor)
		//u_MsgLog(,"OK","I")
	EndIf

Return lRet


Static Function MotCNA(cContrato,cRevisa,cPlanilha,cMot,cMun)
Local cQuery 	 := "SELECT CNA_XXMUN,CNA_XXMOT FROM "+RETSQLNAME("CNA") + ;
					" WHERE CNA_FILIAL = '"+xFilial("CNA")+"' "+;
					"   AND CNA_CONTRA = '"+cContrato+"' "+;
					"   AND CNA_NUMERO = '"+cPlanilha+"' "+;
					"   AND CNA_REVISA = '"+cRevisa+"' "+;
					"   AND D_E_L_E_T_ = '' "

Local aReturn 	 := {}
Local aBinds 	 := {}
Local aSetFields := {}
Local nRet		 := 0
Local lRet       := .F.

Default cMot	:= ""
Default cMun	:= ""

// Ajustes de tratamento de retorno
aadd(aSetFields,FWSX3Util():GetFieldStruct( "CNA_XXMUN" ))
aadd(aSetFields,FWSX3Util():GetFieldStruct( "CNA_XXMOT" ))

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

If nRet < 0
	u_MsgLog("MotCNA",tcsqlerror()+" Falha ao executar a Query: "+cQuery)
Else
  //Alert(VarInfo("aReturn",aReturn))
  If Len(aReturn) > 0
	cMun := aReturn[1][1]
	cMot := aReturn[1][2]
  EndIf
Endif

Return lRet



Static Function GrvSF2(cConta,nValor)
Local aAreaSE1
Local cE1Tipo

// Grava conta no cabecalho da nota
RecLock("SF2",.F.)
SF2->F2_XXCVINC := cConta
SF2->F2_XXVCVIN := nValor
MsUnlock("SF2")

// Grava SE1
aAreaSE1  := SE1->(GetArea()) 
cE1Tipo   := Left(MVNOTAFIS, TamSX3("E1_TIPO")[1]) 
			
SE1->(dbSetOrder(2)) // SE1->(dbSetOrder(RETORDEM("SE1","E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO")))             

If SE1->(MsSeek(xFilial("SE1") + SF2->(F2_CLIENTE) + SF2->(F2_LOJA) + SF2->(F2_SERIE) + SF2->(F2_DOC) + SPACE(LEN(SE1->E1_PARCELA))+cE1Tipo,.T.))     
	SE1->(RECLOCK("SE1",.F.))
	SE1->E1_XXVCVIN := SF2->F2_XXVCVIN
	SE1->(MSUNLOCK())
ENDIF 
SE1->(RestArea(aAreaSE1))

Return


//BUSCAR CONTA VINCULADA
USER FUNCTION BCTAVINC(cCTAVINC)
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



//Ajusta o Texto para o tamanho máximo de caracteres por linha
// 26/07/20 - Marcos
Static Function TextoNF(cTexto,nMaxTLin)

Local cLastLin	:= ""
Local cNewLin	:= ""
Local cRetTexto	:= ""
Local nTamLast	:= 0
Local nI 		:= 0

For nI:= 1 To MLCOUNT(cTexto,nMaxTLin)
	cNewLin := STRTRAN(TRIM(MEMOLINE(cTexto,nMaxTLin,nI)),CHR(13)+CHR(10),"")
	nTamLast := LEN(cLastLin)
	If nTamLast > 0
		nTamLast += 3
	EndIf
	If !Empty(cNewLin)
		If (LEN(cNewLin) + nTamLast) > nMaxTlin 
			cRetTexto += IIF(!EMPTY(cLastLin),cLastLin+"|","")
			cLastLin := cNewLin
		ElseIf (LEN(cNewLin) + nTamLast) = nMaxTlin
			cRetTexto += IIF(!EMPTY(cLastLin),cLastLin+IIF(!EMPTY(cNewLin)," - ",""),"")
			cRetTexto += IIF(!EMPTY(cNewLin),cNewLin+"|","")
			cLastLin := ""
		Else
			cLastLin += IIF(!EMPTY(cLastLin)," - ","")+cNewLin
		EndIf
	EndIf
Next
If !Empty(cLastLin)
	cRetTexto += cLastLin+"|"
EndIf
Return cRetTexto



// Função para incrementar a remessa da Prefeitura de Barueri: NFBARUE.INI
/*
...
[XXX Chamada do Wizard]

(PRE) _aTotal[06] := (xMagWizard(_aTotal[04],_aTotal[05],"NFESP"))
(PRE) Iif(_aTotal[06],xMagLeWiz("NFESP",@_aTotal[07],.T.),Nil)
(PRE) Iif(_aTotal[06],u_ProxRem("NFESP"),Nil)
(PRE) lAbtMT950	:= !_aTotal[06]
...
*/

User Function ProxRem(cArqIni)
Local cIni		:= TRIM(cArqIni)+".CFP"
Local cLinha	:= ""
Local cArqBkp	:= ""
Local aLinhas	:= {}
Local nHandle	:= 0
Local lProx		:= .F.
Local i 		:= 0

If !Empty(cArqIni) .AND. File(cIni)
	FT_FUse(cIni)
	FT_FGoTop()
	While ( !FT_FEof() )
		cLinha := FT_FReadLn()
		If ("{OBJ002;011}" $ cLinha) .and. !lProx
			cLinha := "{OBJ002;011}"+STRZERO(VAL(SUBSTR(cLinha,13,11))+1,11)
			lProx  := .T.
		EndIf
		aAdd(aLinhas,cLinha+CRLF)
		FT_FSkip()
	Enddo
	FT_FUse()

	cArqBkp := StrTran(cIni,".CFP",".BAK")
	Ferase(cArqBkp)
	FRename(cIni,cArqBkp)
	nHandle := MSFCREATE(cIni)

	For i:=1 to Len(aLinhas)
		FWrite(nHandle,aLinhas[i],Len(aLinhas[i]))
	Next
	FClose(nHandle)
EndIf

Return .T.





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MATA916   ºAutor  ³Marcelo Alexandre   º Data ³  13/04/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o codigo do imposto e o valor                       º±±
±±º          ³Impostsos: IRRF, PIS, COFINS e CSLL retencao.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaFis                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function XRetImpost(cFilF3,cNF,cSerie,cCliFor,cLoja,nValTot,lLimpa,cIdentFT)

Local nX      := 0
Local cNFE	  := ""
Local aCampos := {}
Local aArqRet := {}
Local aIndice := {}
Local nValPis := 0
Local nValCsl := 0
Local nValCof := 0
Local nValIrf := 0
Local aVn     := {}
Local cParcela  := " "
Local cChaveSE1 := " "
Local cPrefixo := Padr(cSerie , TamSx3("E1_SERIE")[1])
Local cRetencao := SuperGetMv("MV_BR10925")
Local lMV_NFSEPCC := SuperGetMv("MV_NFSEPCC", .F., .F.)
Local lMV_NFSEIR := SuperGetMv("MV_NFSEIR", .F., .F.)
Local nValPisNF := 0
Local nValCslNF := 0
Local nValCofNF := 0
Local nValIrfNF := 0
Local cChaveSFT := ""
Local aAreaSFT := SFT->(getArea())

Default lLimpa := .F.
Default nValTot:= 0
Default cIdentFT := ""

If lLimpa
	aArqRet := {}
EndIf

AADD(aCampos,{"TIPOIMP","C",002,0})
AADD(aCampos,{"VALIMP" ,"N",015,2})

cNFE :=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cNFE,"NFE")
IndRegua("NFE",cNFE,"TIPOIMP")
DbClearIndex()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para utilizar indice de usuario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("MT916IND")
	aIndice := ExecBlock("MT916IND", .F., .F.,{SF3->F3_NFISCAL,SF3->F3_SERIE,SF3->F3_CLIEFOR,SF3->F3_LOJA})
Else
	AADD(aIndice,2)
	AADD(aIndice,(xFilial("SE1")+cCliFor+cLoja+cPrefixo+cNF))
EndIf

DbSelectArea ("SE1")
SE1->(dbSetOrder(aIndice[1]))
SE1->(dbSeek(aIndice[2]))

DbSelectArea("SFT")
SFT->(dbSetOrder(3))
SFT->(dbGoTop())

If ExistBlock("MT916IND")
	SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"V",SE1->E1_BAIXA,,@nValIrf,@nValCsl,@nValPis,@nValCof,@nValINSS)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Titulos Parcelados   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cChaveSE1 := xFilial("SE1")+cCliFor+cLoja+cPrefixo+cNF
	While SE1->(!Eof()) .And. cChaveSE1 == xFilial("SE1")+cCliFor+cLoja+cPrefixo+cNF
		If Alltrim(cRetencao) == '1' //Retenção na Baixa do Titulo
			If SE1->E1_TIPO = 'IR-'
				nValIrf += SE1->E1_VALOR
			ElseIf SE1->E1_TIPO = 'COF'
				nValCof += SE1->E1_VALOR
			ElseIf SE1->E1_TIPO = 'CSL'
				nValCsl += SE1->E1_VALOR
			ElseIf SE1->E1_TIPO = 'PIS'
				nValPis += SE1->E1_VALOR
			EndIF
		Else
			If AT("-",SE1->E1_TIPO)==0
				SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"V",SE1->E1_BAIXA,,@nValIrf,@nValCsl,@nValPis,@nValCof,0)//,@nValINSS)
			EndIf
		EndIf
		// --> BK
		SE1->(dbSkip())
		// <-- BK
		cParcela :=SE1->E1_PARCELA
		cChaveSE1 := xFilial("SE1")+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM
		// skip estava aqui
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados da NF          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (!Empty(cIdentFT) .And. (lMV_NFSEPCC .Or. lMV_NFSEIR))
		
		cChaveSFT := xFilial("SFT")+"S"+cCliFor+cLoja+cSerie+cNF+cIdentFT
		 
		If SFT->(MsSeek(cChaveSFT))
		
			While SFT->(!Eof()) .And. xFilial("SFT")+"S"+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_IDENTF3 == cChaveSFT
			
				If Empty(SFT->FT_DTCANC)
					nValIrfNF += SFT->FT_VALIRR
					nValPisNF += SFT->FT_VRETPIS
					nValCofNF += SFT->FT_VRETCOF
					nValCslNF += SFT->FT_VRETCSL
				EndIf
				
				SFT->(dbSkip())
				
			EndDo
		
		EndIf
		
		// Substituo os valores obtidos da SE1 pelos valores da NF.
		
		If lMV_NFSEIR
			nValIrf := nValIrfNF 	
		EndIf
		
		If lMV_NFSEPCC
			nValPis := nValPisNF 
			nValCof := nValCofNF
			nValCsl := nValCslNF
		EndIf
		
	EndIf
	
Endif

RestArea(aAreaSFT)	

If nValIrf > 0
	aadd(aArqRet,{nValIrf,"01"})
EndIf
If nValPis > 0
	aadd(aArqRet,{nValPis,"02"})
EndIf
If nValCof > 0
	aadd(aArqRet,{nValCof,"03"})
EndIf
If nValCsl > 0
	aadd(aArqRet,{nValCsl,"04"})
EndIf

aVn := RetNotConj(cNF, cSerie, cCliFor, cLoja, "S")

If Len(aVn)>0
	For nX :=1 to Len (aVn)
		aadd(aArqRet,{aVn[nX][2],"VN"})
	Next nX
EndIf

nValTot := nValIrf+nValPis+nValCof+nValCsl

If len(aArqRet)>0
	For nX :=1 to Len(aArqRet)
		RECLOCK("NFE",.T.)
		NFE->TIPOIMP := aArqRet[nX][2]
		NFE->VALIMP  := aArqRet[nX][1]
		MsUnlock()
	Next nX
EndIf

Return(cNFE)
