#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH"                     
#INCLUDE "TBICONN.CH"
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'
                            
//-------------------------------------------------------------------
/*/{Protheus.doc} BKGCTR14()
BK - Rentabilidade dos Contrato - Projeção X Realizado
@author Adilson do Prado
@since 16/05/14 Rev 21/06/22
@version P12
@return Nil
/*/
//-------------------------------------------------------------------

User Function BKGCTR14(aParam)

Local titulo        := "Rentabilidade dos Contratos - Projeção X Realizado"
Local cTitulo		:= ""
Local _nI           := 0
Local iX			:= 0
Local _IX			:= 0

Local oTmpTb1		as Object
Local oTmpTb2		as Object
Local oTmpTb3		as Object
Local oTmpTbT		as Object

Local cMes          := ""
Local cXXSEMAF		:= "N"
Local aRetCons		:= {}
Local cLogCons   	:= ""
Local cCrLf   		:= Chr(13) + Chr(10) 
Local dAgJob		:= DATE()
Local dMaxCompet	:= CTOD("")

// Exemplo a param do schedule: {.F.,.T.,'01','01','000000','004138000002'}
Default aParam 		:= {.F.,.F.}

Private lSintet  	:= .F.
Private lJob 		:= .F.

Private cEmpPar 	:= "01"
Private cFilPar		:= "01"
Private cPerg       := "BKGCTR14"
Private cStart		:= "Início: "+DtoC(Date())+" "+Time()
Private cArqLog		:= ""
Private cContrato   := ""

If Len(aParam) == 2
	lSintet  	:= aParam[1]
	lJob 		:= aParam[2]
	cArqLog		:= "\LOG\BKGCTR14-"+cEmpAnt+".LOG"
Else

	lSintet  	:= aParam[1]
	lJob 		:= aParam[2]
	cEmpPar 	:= aParam[3]
	cFilPar 	:= aParam[4]

	WFPrepEnv(cEmpPar,cFilPar,cPerg,{"CN9","SZX"},"GCT")

	cArqLog		:= "\LOG\BKGCTR14-"+cEmpPar+".LOG"

	// Data de Agendamento do Job
	dAgJob		:= U_BKGetMv("BKGCTR1410",.F.,CTOD(""))
	cContrato  	:= U_BKGetMv("BKGCTR1401")
	If DAY(DATE()) <> 9 .AND. !("*" $ cContrato)
		If Empty(dAgJob) .OR. !(dAgJob == DATE())
		
			u_xxLog(cArqLog,cStart+": "+titulo+" - ultimo agendamento: "+IIF(!EMPTY(dAgJob),DTOC(dAgJob),""),.T.,"")
			Reset Environment
			Return Nil
		EndIf
	Endif
EndIf

Private aMeses		:= {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
Private aContratos 	:= {}
Private lSintetico  := lSintet

Private dDataInicio := dDatabase
Private dDataI		:= dDatabase
Private dDataFinal  := dDatabase
Private cSituac     := "05"
Private	cPict       := "@E 99,999,999,999.99"
Private nPeriodo    := 1
Private nPlan       := 1

Private aPeriodo    := {}
Private aAnoMes     := {}
Private aAcrDcr 	:= {}
Private cLastE2     := ""
Private lPRat		:= .T.

Private nTamCodGct	:= 9
Private nTamCodigo	:= 16

Private nMesC 		:= 0
Private nAnoC  		:= 0
Private nMImpContr  := 0
Private nTaxaAdm    := 0
Private nEncargos   := 0
Private nEncarIPT   := 0
Private nIncidenci  := 0
Private nRateia     := 2
Private nDespGeral  := 0
Private nCompAtual  := 3
Private nAgendar    := 2
Private nCompras  	:= 0

Private nCompet		:= 0
Private nProventos	:= 0
Private cProventos  := ""
Private cDescontos  := ""
Private cVT_Prov 	:= ""
Private cVT_Verb 	:= ""
Private cVT_Prod   	:= ""
Private cVRVA_Verb  := ""
Private cVRVA_Prod  := ""
Private cASSM_Verb	:= ""
Private cASSM_Prod	:= ""
Private cSINO_Verb	:= ""
Private cSINO_Prod	:= ""
Private cCCRE_Verb	:= ""
Private cCCRE_Prod	:= ""
Private cCDPR_Prod	:= ""
Private cCDPR_GRUP  := ""
Private cNINC_Verb	:= ""
Private aConsorcio	:= {}
Private lConsorcio  := .F.
Private lFurnas		:= .F.
Private lPetro		:= .F.
Private cExm_Prod	:= ""
Private cDescExm    := ""
Private cMFG_Prod	:= "" 
Private cDCH_Prod	:= ""
Private cDescDCH	:= ""
Private cDViagens	:= "34202003"
Private cCusBK		:= U_MVXCUSBK()
Private cDescCBK	:= ""

Private aHeader	    := {}
Private aDbf1 	    := {}
Private aTitulos1,aCampos1,aCabs1,aFormat1,aFormula1,aImpr1,aPict1
Private cRealTb1	:= ""

Private aDbf2       := {}
Private aTitulos2,aCampos2,aCabs2,aFormat2,aFormula2,aImpr2,aPict2

Private aDbf3	    := {}
Private aTitulos3,aCampos3,aCabs3,aFormat3,aFormula3,aImpr3,aPict3

Private aDbfT		:= {}
Private aCamposT,aCabsT
Private cRealTbT	:= ""

Private ALIAS_TMP   := "TMPC"+cEmpAnt

Private cXXPLR 		:= ""
Private nConsolida	:= 0
Private nIndConsor	:= 0
Private nIndDesp	:= 1
Private nConsol     := 0
Private cConsolida 	:= ""
Private aConsolida 	:= {}
Private aContConsol := {}
Private cTipoContra := "A" // 04/05/22 - SOMENTE CONTRATOS VIGENTES
Private nVContrat 	:= 0
Private aVContrat	:= {}
Private aXMIMPC		:= {}
Private aMImpContr  := {}
Private dDtProj 	:= CTOD("")
Private cSeqProj	:= ""
Private aFurnas		:= U_MVXFURNAS()
Private aPetro		:= {} 

mv_par03 := YEAR(dDataBase)

If !lJob
	ValidPerg(cPerg)
	If !Pergunte(cPerg,.T.)
		Return Nil
	Endif
	u_LogPrw(cPerg)

	nAgendar := MV_PAR09
	If nAgendar == 1 
		If  MV_PAR10 < (dDatabase + 1)
			MV_PAR10 := (dDatabase + 1)
		EndIf
		If LEN(ALLTRIM(MV_PAR11)) < 5
			MV_PAR11 := "bruno.bueno@bkconsultoria.com.br"
		EndIf
		MV_PAR01 := " " // Sempre agendar todos os contratos
		U_BKPutMv("BKGCTR1401",MV_PAR01,"C",10,0,"Contrato?")
		U_BKPutMv("BKGCTR1402",MV_PAR02,"N", 2,0,"Mês Competência?")
		U_BKPutMv("BKGCTR1403",MV_PAR03,"N", 4,0,"Ano Competência?")
		U_BKPutMv("BKGCTR1404",MV_PAR04,"N", 6,3,"%Taxa de Administração?")
		U_BKPutMv("BKGCTR1405",MV_PAR05,"N", 1,0,"Consolidar Contratos?")
		U_BKPutMv("BKGCTR1406",MV_PAR06,"N", 1,0,"Consórcio Aplicar Índice Total?")
		U_BKPutMv("BKGCTR1407",MV_PAR07,"N", 1,0,"Rateia Despesas no Cronograma?")
		U_BKPutMv("BKGCTR1408",MV_PAR08,"N", 1,0,"Detalhar ?")
		U_BKPutMv("BKGCTR1409",MV_PAR09,"N", 1,0,"Agendar ?")
		U_BKPutMv("BKGCTR1410",MV_PAR10,"D", 8,0,"Agendar para:")
		U_BKPutMv("BKGCTR1411",MV_PAR11,"C",70,0,"E-Mail?")
		U_BKPutMv("BKGCTR1412",MV_PAR12,"N", 1,0,"Somente Competência Atual?")
		u_xxLog(cArqLog,cStart+": "+titulo+" - agendamento efetuado para: "+DTOC(MV_PAR10),.T.,"")
		MsgInfo("Agendamento efetuado para "+DTOC(MV_PAR10)+" 1h")
		Return Nil
	EndIf
Else
	MV_PAR01 := cContrato  	:= U_BKGetMv("BKGCTR1401") // teste "005000114"
	MV_PAR02 := nMesC 		:= U_BKGetMv("BKGCTR1402") // MONTH(dDataBase - DAY(dDatabase))
	MV_PAR03 := nAnoC  		:= U_BKGetMv("BKGCTR1403") // YEAR(dDataBase - DAY(dDatabase))
	MV_PAR04 := U_BKGetMv("BKGCTR1404")                // 3
	MV_PAR05 := nConsolida	:= 0 //U_BKGetMv("BKGCTR1405") // 2
	MV_PAR06 := nIndConsor	:= U_BKGetMv("BKGCTR1406") // 1
	MV_PAR07 := nRateia     := U_BKGetMv("BKGCTR1407") // 2
	MV_PAR08 := nDespGeral  := U_BKGetMv("BKGCTR1408") // 1
	MV_PAR12 := nCompAtual  := U_BKGetMv("BKGCTR1412")
	u_xxLog(cArqLog,titulo+": "+cStart,.T.,"")

EndIf

aXMIMPC	:= {}
aXMIMPC	:= StrTokArr(U_MVXMIMPC(),"|") //%Media de Impostos e Contribuicoes calculo Rentabilidade dos Contratos 
aMImpContr  := {}
FOR IX := 1 TO LEN(aXMIMPC)
    aAdd(aMImpContr,StrTokArr(aXMIMPC[IX],";"))
NEXT

cContrato  	:= mv_par01
nMesC 		:= mv_par02
nAnoC  		:= mv_par03
nConsolida	:= mv_par05
nIndConsor	:= mv_par06
nRateia     := mv_par07
nDespGeral  := mv_par08
nCompAtual  := mv_par12

IF nDespGeral == 2
	nDespGeral := 1
	nCompras := 1
ENDIF

nMImpContr 	:= VAL(aMImpContr[1,2])                      
nEncargos  	:= U_MVXENCAP()  // BK 37.1328 BK TER 8 
nEncarIPT	:= U_MVXEIPT()   // BK 20      BK TER 1
nIncidenci	:= U_MVXINCID()  // BK 28.860  BK TER 20.700
nTaxaAdm	:= U_MVXTXADM()  // 3

                                                                                  
//VERIFICA CHAMADA DE CONSOLIDAR
IF nConsolida == 1

	//Monta Tela para Consolidar
	aRetCons := MtaDlg01()

    //ZERA VARIAVEL DE CONTRATO
	cContrato  	:= "XXXXXXXXX"

	IF LEN(aRetCons) > 0
	
		IF SUBSTR(aRetCons[1,1],1,1) == "P"
			nConsol := 1
			cConsolida := ""
			cConsolida := ALLTRIM(aRetCons[1,2])
			cConsolida := STRTRAN(cConsolida,";","")
			cTipoContra:= SUBSTR(aRetCons[1,3],1,1)

			dbSelectArea("CN9")
			dbSetOrder(1)
			IF !dbSeek(xFilial("CN9") + cConsolida)
				MSGSTOP("Contrato n° "+cConsolida+" inválido. Verifique!!")
				RETURN NIL
			ENDIF
			cConsolida := SUBSTR(cConsolida,1,3)

		ELSEIF SUBSTR(aRetCons[1,1],1,1) == "S"
			nConsol := 2
			cConsolida := ""
			cConsolida := ALLTRIM(aRetCons[1,2])
			cConsolida := STRTRAN(cConsolida,";","")
			cTipoContra:= SUBSTR(aRetCons[1,3],1,1)

			dbSelectArea("CN9")
			dbSetOrder(1)
			IF !dbSeek(xFilial("CN9") + cConsolida)
				MSGSTOP("Contrato n° "+cConsolida+" inválido. Verifique!!")
				RETURN NIL
			ENDIF
			cConsolida := SUBSTR(cConsolida,7,3)

		ELSEIF SUBSTR(aRetCons[1,1],1,1) == "N"
			nConsol := 3
			aConsolida := U_StringToArray(aRetCons[1,2], ";" )
			cTipoContra:= SUBSTR(aRetCons[1,3],1,1)
			cConsolida := ""
			cLogCons   := ""
			FOR _IX := 1 TO LEN(aConsolida)
				dbSelectArea("CN9")
				dbSetOrder(1)
				IF dbSeek(xFilial("CN9") + ALLTRIM(aConsolida[_IX]))
					cConsolida += "'"+ALLTRIM(aConsolida[_IX])+"',"
				ELSE
				   cLogCons += "Contrato n° "+ALLTRIM(aConsolida[_IX])
				ENDIF
			NEXT
			IF LEN(cConsolida) > 1
				cConsolida := SUBSTR(cConsolida,1,LEN(cConsolida)-1)
			ENDIF
			IF !EMPTY(cLogCons)
				IF lJob
					u_xxLog(cArqLog,"- Contratos não encontrados e será desconsiderado da Consolidação: "+cLogCons,.T.,"")
				ELSE
					IF !MSGYESNO("- Contratos não encontrados e será desconsiderado da Consolidação -" +cCrLf+cCrLf+cLogCons+cCrLf+cCrLf+"Continua?")
						RETURN NIL
					ENDIF
				ENDIF
			ENDIF		
		ENDIF
    ELSE
		IF lJob
			u_xxLog(cArqLog,"Informações para Consolidar invalida. Verifique!!",.T.,"")
		ELSE
	    	MSGSTOP("Informações para Consolidar invalida. Verifique!!")
		ENDIF
		Return Nil
    ENDIF

ENDIF

cProventos  := U_MVXPROVE()
cDescontos  := U_MVXDESCO()        //"|112|114|120|122|177|181|187|636|650|680|683|691|780|783|784|"
cVT_Prov 	:= U_MVXVTPRO()	       //"|671|" // PROVENTO DE VT - Conforme verificado com Sr. Anderson esta verba é so pára funcionario que tem vt em dinheiro
cVT_Verb 	:= U_MVXVTVER()        //"|290|667|"
cVT_Prod   	:= U_MVXVTPRD()        //"|31201046|"
cVRVA_Verb  := U_MVXVRVAV()        //"|613|614|662|681|682|702|873|874|895|896|"
cVRVA_Prod  := U_MVXVRVAP()        //"|31201045|31201047|"
cASSM_Verb	:= U_MVXASSMV()        //"|605|689|733|734|742|770|771|773|794|796|832|856|"
cASSM_Prod	:= U_MVXASSMP()        //"|605|689|709|711|712|719|733|734|742|743|770|771|773|794|796|810|832|833|854|856|857|" 
cSINO_Verb	:= U_MVXSINOV()        //"|510|607|665|679|724|739|825|900|"
cSINO_Prod	:= U_MVXSINOP()        //"|510|607|665|679|724|732|739|825|900|"
cCCRE_Verb	:= ""                  //GetMv("MV_XXCCREV") //"|774|775|776|812|814|"
cCCRE_Prod	:= ""                  //GetMv("MV_XXCCREP") //"|34202016|"
cCDPR_Prod	:= U_MVXCDPRP()
cCDPR_GRUP	:= U_MVXCDPRG()
cNINC_Verb	:= U_MVXNINCI()
aContrCons	:= {}
//aContrCons	:= StrTokArr(ALLTRIM(GetMv("MV_XXCONS1"))+ALLTRIM(GetMv("MV_XXCONS2"))+ALLTRIM(GetMv("MV_XXCONS3"))+ALLTRIM(GetMv("MV_XXCONS4")),"/") //"163000240"
aContrCons	:= U_MVXCONS()
// Rateio        Contrato  x  Produtos                       15/01/20 - Marcos
aRatCtrPrd  := U_DefCtrPrd()

cExm_Prod	:= U_MVXCEXMP()
cDescExm    := Posicione("SB1",1,xFilial("SB1")+cExm_Prod,"B1_DESC")

cMFG_Prod	:= U_MVXCMFGP()

cDCH_Prod	:= U_MVXCDCH()
cDViagens   := cDCH_Prod
cDescDCH	:= Posicione("SB1",1,xFilial("SB1")+cDCH_Prod,"B1_DESC")
cDescCBK	:= Posicione("SB1",1,xFilial("SB1")+cCusBK,"B1_DESC")

cXXPLR	    := U_MVXPLR()

//MV_XXSEMAF    C   Semaforo controle de execução da procedure de atualização tabela centro de custo integração Rubi X Microsiga
cXXSEMAF	:= GetMv("MV_XXSEMAF")

IF EMPTY(cContrato)
	IF lJob
		lConsorcio := .T.
		lFurnas    := .T.
		lPetro     := .T.
		If nCompAtual == 1
			nCompAtual := 3
		EndIf
	ELSE
		IF AVISO("Atenção","Incluir Contrato Consorcios ?",{"Não","Sim"}) == 2
			lConsorcio := .T.
		ELSE
			lConsorcio := .F.
		ENDIF
		IF AVISO("Atenção","Incluir Contrato Furnas - Filial 381/391 ?",{"Não","Sim"}) == 2
			lFurnas := .T.
		ELSE
			lFurnas := .F.
		ENDIF
		IF AVISO("Atenção","Incluir Contrato Petro - Filial 455 ?",{"Não","Sim"}) == 2
			lPetro := .T.
		ELSE
			lPetro := .F.
		ENDIF
	ENDIF
ELSEIF nConsolida == 0
	cTipoContra := "" // Se informar o contrato, permitir contratos não vigentes
ENDIF

FOR IX:= 1 TO LEN(aContrCons)
    aAdd(aConsorcio,StrTokArr(aContrCons[IX],";"))
NEXT

IF ALLTRIM(cXXSEMAF) == 'N'
	If !lJob
		ProcRegua(100)
		Processa( {|| AtualizaCC(lJob) }) 
	Else
		AtualizaCC(lJob)
	EndIf
ELSE
	If !lJob
		Msginfo("Atualizando tabela Folha de Pagamento!!")
	    Return Nil
	Else
		u_xxLog(cArqLog,"Atenção: tabela Folha de Pagamento não foi atualizada.",.T.,"")
	EndIf
ENDIF

If nCompAtual <> 1  // Periodo total do(s) contrato(s)

	IF !EMPTY(cContrato)
		cQuery := " SELECT TOP 1 "+CRLF
		cQuery += "   MIN(CN9_DTOSER) AS CN9_DTOSER,"+CRLF
		cQuery += "   MIN(CN9_DTINIC) AS CN9_DTINIC,"+CRLF
		cQuery += "   MIN(CNF_DTVENC) AS CNF_INICIO,"+CRLF
		cQuery += "   MAX(CNF_DTVENC) AS CNF_FIM,"+CRLF
		cQuery += "   CN9_SITUAC,"+CRLF
		cQuery += "   MAX((SUBSTRING(CNF_COMPET,4,4))+SUBSTRING(CNF_COMPET,1,2))+'01' AS MAXCOMPET"+CRLF
		cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF
		cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA"+CRLF
		cQuery += "       AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"+CRLF
		cQuery += " WHERE CNF.D_E_L_E_T_=''"+CRLF
		IF nConsol == 1
			cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) ='"+ALLTRIM(cConsolida)+"'"+CRLF
			IF cTipoContra == 'A'
				cQuery += " AND CN9_SITUAC = '05'"+CRLF
			ELSE
				cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
			ENDIF
		ELSEIF nConsol == 2
			cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) ='"+ALLTRIM(cConsolida)+"'"+CRLF
			IF cTipoContra == 'A'
				cQuery += " AND CN9_SITUAC = '05'"+CRLF
			ELSE
				cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
			ENDIF
		ELSEIF nConsol == 3
			cQuery += " AND CNF_CONTRA IN ("+ALLTRIM(cConsolida)+")"+CRLF
			IF cTipoContra == 'A'
				cQuery += " AND CN9_SITUAC = '05'"+CRLF
			ELSE
				cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
			ENDIF
		ELSE
			cQuery += " AND CNF_CONTRA ='"+ALLTRIM(cContrato)+"'"+CRLF 
			cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
		ENDIF
			
		cQuery += " GROUP BY CN9_SITUAC"+CRLF
	//	cQuery += " GROUP BY CN9_REVISA,CN9_SITUAC ORDER BY CN9_REVISA DESC"

	ELSE
		cContrCons := ""
		For IX:= 1 TO LEN(aConsorcio)
			cContrCons += "'"+ALLTRIM(aConsorcio[IX,1])+"',"
		NEXT
		cQuery := " SELECT "+CRLF
		cQuery += "   MIN(CN9_DTOSER) AS CN9_DTOSER,"+CRLF
		cQuery += "   MIN(CN9_DTINIC) AS CN9_DTINIC,"+CRLF
		cQuery += "   MIN(CNF_DTVENC) AS CNF_INICIO,"+CRLF
		cQuery += "   MAX(CNF_DTVENC) AS CNF_FIM,"+CRLF
		cQuery += "   CN9_SITUAC,"+CRLF
		cQuery += "   MAX((SUBSTRING(CNF_COMPET,4,4))+SUBSTRING(CNF_COMPET,1,2))+'01' AS MAXCOMPET"+CRLF
		cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF
		cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA"+CRLF
		cQuery += "       AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"+CRLF
		cQuery += " WHERE CNF.D_E_L_E_T_=''"+CRLF
		cQuery += "       AND CN9_SITUAC = '05'"+CRLF
		IF !lConsorcio
			IF !EMPTY(cContrCons)
				cQuery += " AND CNF_CONTRA NOT IN ("+SUBSTRING(ALLTRIM(cContrCons),1,LEN(cContrCons)-1)+") "+CRLF
			ENDIF
		ENDIF
		IF !lFurnas
			cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391'"+CRLF
		ENDIF
		IF !lPetro
			cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '455'"+CRLF
		ENDIF
		cQuery += " GROUP BY CN9_SITUAC"+CRLF
	ENDIF	

	u_LogTxt("BKGCTR14-CN9.SQL")

	TCQUERY cQuery NEW ALIAS "QTMP1"
	TCSETFIELD("QTMP1","CNF_INICIO","D",8,0)	
	TCSETFIELD("QTMP1","CNF_FIM"   ,"D",8,0)	
	TCSETFIELD("QTMP1","CN9_DTINIC","D",8,0)	
	TCSETFIELD("QTMP1","CN9_DTOSER","D",8,0)	

	u_LogTxt("BKGCTR14-CN9.SQL",cQuery)

	dbSelectArea("QTMP1")
	dDataI		:= QTMP1->CN9_DTOSER
	If Empty(dDataI)
		dDataI	:= QTMP1->CN9_DTINIC
	EndIf
	If (!Empty(QTMP1->CNF_INICIO) .AND. QTMP1->CNF_INICIO < dDataI) .OR. Empty(dDataI)
		dDataI	:= QTMP1->CNF_INICIO
	EndIf

	dDataFinal	:= QTMP1->CNF_FIM
	dMaxCompet  := STOD(QTMP1->MAXCOMPET)
	If dMaxCompet > dDataFinal
		dDataFinal := LastDay(dMaxCompet)
	EndIf

	cSituac 	:= QTMP1->CN9_SITUAC

	QTMP1->(Dbclosearea())

	IF EMPTY(DTOS(dDataI)) .OR. EMPTY(DTOS(dDataFinal)) 
		If !lJob
			MSGSTOP("Contrato não encontrado!!")
		Else
			u_xxLog(cArqLog,"Período de competência não encontrado: "+DTOC(dDataI) +" a "+ DTOC(dDataFinal),.T.,"")
		EndIf
		Return Nil
	ENDIF

	// Voltar 1 mes
	dDataI := dDataI - Day(dDataI)
	dDataI := dDataI - Day(dDataI)+1

	//Determina quantos Meses utilizar no calculo
	nPeriodo += DateDiffMonth( dDataI , dDataFinal )
Else
	// Somente o mês de competência Informado	
	dDataI := CTOD("01/"+STRZERO(nMesC,2)+"/"+STRZERO(nAnoC,4))
	dDataFinal := LastDay(dDataI)
	nPeriodo := 1
EndIf

cTitulo  := titulo + " - Competencia: "+STRZERO(nMesC,2)+" / "+STRZERO(nAnoC,4)

u_xxLog(cArqLog,cTitulo,.T.,"")

aDbf1		:= {}
aCabs1   	:= {}
aCampos1 	:= {}
aTitulos1	:= {}
aImpr1		:= {}
aFormat1 	:= {}
aFormula1	:= {}
aPict1		:= {}

aAdd(aTitulos1,cTitulo)

aAdd(aDbf1, { 'XX_COMPET','C', 07,00 } )
aAdd(aCampos1,"TRB->XX_COMPET")
aAdd(aCabs1  ,"Competência")
aAdd(aHeader,{"Competência","XX_COMPET" ,"@!",7,00,"","","C","TRB","R"})
aAdd(aImpr1,.T.)
aAdd(aFormat1,"")
aAdd(aPict1,"")

aAdd(aDbf1, { 'XX_LINHA' ,'N', 10,00 } )
aAdd(aCampos1,"TRB->XX_LINHA")
aAdd(aCabs1  ,"Linha")
aAdd(aImpr1,.T.)
aAdd(aFormat1,"")
aAdd(aPict1,"")

aAdd(aDbf1, { 'XX_CODGCT','C', 09,00 } )
aAdd(aCampos1,"TRB->XX_CODGCT")
aAdd(aCabs1  ,"Contrato")
aAdd(aImpr1,.T.)
aAdd(aFormat1,"")
aAdd(aPict1,"")


aAdd(aDbf1, { 'XX_DESC'  ,'C', 50,00 } )
aAdd(aCampos1,"TRB->XX_DESC")
aAdd(aCabs1  ,"Descrição")
aAdd(aHeader,{"Descrição","XX_DESC" ,"@!",10,00,"","","C","TRB","R"})
aAdd(aImpr1,.T.)
aAdd(aFormat1,"")
aAdd(aPict1,"@!")

aAdd(aDbf1, { 'XX_PROJ'  ,'C', 200,00 } )
aAdd(aCampos1,"TRB->XX_PROJ")
aAdd(aCabs1  ,"Previsão Financeira")
aAdd(aHeader,{"Previsão Financeira","XX_PROJ" ,"@!",20,00,"","","C","TRB","R"})
aAdd(aImpr1,.T.)
aAdd(aFormat1,"N")
aAdd(aPict1,"")

aAdd(aDbf1, { 'XX_REAL'  ,'C', 200,00 } )
aAdd(aCampos1,"TRB->XX_REAL")
aAdd(aCabs1  ,"Realizado")
aAdd(aHeader,{"Realizado","XX_REAL" ,"@!",20,00,"","","C","TRB","R"})
aAdd(aImpr1,.T.)
aAdd(aFormat1,"N")
aAdd(aPict1,"")

aAdd(aDbf1, { 'XX_DIF'   ,'C', 200,00 } )
aAdd(aCampos1,"TRB->XX_DIF")
aAdd(aCabs1  ,"Diferença %")
aAdd(aHeader,{"Diferença %","XX_DIF" ,"@!",10,00,"","","C","TRB","R"})
aAdd(aImpr1,.T.)
aAdd(aFormat1,"N")
aAdd(aPict1,"@E 99999.99999")

// PowerBK

aAdd(aDbf1, { 'XX_PROJN'  ,'N', 18,02 } )
aAdd(aCampos1,"TRB->XX_PROJN")
aAdd(aCabs1  ,"Previsão Financeira N")
aAdd(aImpr1,.T.)
aAdd(aFormat1,"")
aAdd(aPict1,"")

aAdd(aDbf1, { 'XX_REALN'  ,'N', 18,02 } )
aAdd(aCampos1,"TRB->XX_REALN")
aAdd(aCabs1  ,"Realizado N")
aAdd(aImpr1,.T.)
aAdd(aFormat1,"")
aAdd(aPict1,"")

aAdd(aDbf1, { 'XX_DIFN'   ,'N', 18,05 } )
aAdd(aCampos1,"TRB->XX_DIFN")
aAdd(aCabs1  ,"Diferença % N")
aAdd(aImpr1,.T.)
aAdd(aFormat1,"")
aAdd(aPict1,"")

aAdd(aDbf1, { 'XX_POWERBK','C',  1,00 } )
aAdd(aCampos1,"TRB->XX_POWERBK")
aAdd(aCabs1  ,"Power BK")
aAdd(aImpr1,.T.)
aAdd(aFormat1,"")
aAdd(aPict1,"")


oTmpTb1 := FWTemporaryTable():New( "TRB" ) 
oTmpTb1:SetFields( aDbf1 )
oTmpTb1:AddIndex("indice1", {"XX_COMPET","XX_LINHA"} )
oTmpTb1:Create()
cRealTb1 := oTmpTb1:GetRealName()

If lSintetico .OR. lJob

	aDbf2		:= {}
	aCabs2   	:= {}
	aCampos2 	:= {}
	aTitulos2	:= {}
	aImpr2		:= {}
	aFormat2 	:= {}
	aFormula2	:= {}
	aPict2		:= {}

	aAdd(aTitulos2,"Sintético: "+cTitulo)

	aAdd(aDbf2, { 'XX_LINHA' ,'N', 10,00 } )
	aAdd(aCampos2,"TRB2->XX_LINHA")
	aAdd(aCabs2  ,"Linha")
	aAdd(aImpr2,.T.)
	aAdd(aFormat2,"")
	aAdd(aPict2,"")

	aAdd(aDbf2, { 'XX_CODGCT','C', 09,00 } )
	aAdd(aCampos2,"TRB2->XX_CODGCT")
	aAdd(aCabs2  ,"Contrato")
	aAdd(aImpr2,.T.)
	aAdd(aFormat2,"")
	aAdd(aPict2,"")

	aAdd(aDbf2, { 'XX_DESC'  ,'C', 50,00 } )
	aAdd(aCampos2,"TRB2->XX_DESC")
	aAdd(aCabs2  ,"Descrição")
	aAdd(aImpr2,.T.)
	aAdd(aFormat2,"")
	aAdd(aPict2,"@!")

	aAdd(aDbf2, { 'XX_PROJ'  ,'C', 200,00 } )
	aAdd(aCampos2,"TRB2->XX_PROJ")
	aAdd(aCabs2  ,"Previsão Financeira")
	aAdd(aImpr2,.T.)
	aAdd(aFormat2,"N")
	aAdd(aPict2,"")

	aAdd(aDbf2, { 'XX_REAL'  ,'C', 200,00 } )
	aAdd(aCampos2,"TRB2->XX_REAL")
	aAdd(aCabs2  ,"Realizado")
	aAdd(aImpr2,.T.)
	aAdd(aFormat2,"N")
	aAdd(aPict2,"")

	aAdd(aDbf2, { 'XX_DIF'   ,'C', 200,00 } )
	aAdd(aCampos2,"TRB2->XX_DIF")
	aAdd(aCabs2  ,"Diferença %")
	aAdd(aImpr2,.T.)
	aAdd(aFormat2,"N")
	aAdd(aPict2,"@E 99999.99999")

	oTmpTb2 := FWTemporaryTable():New( "TRB2" ) 
	oTmpTb2:SetFields( aDbf2 )
	oTmpTb2:AddIndex("indice1", {"XX_LINHA"} )
	oTmpTb2:Create()


	// Modelo Diretoria

	aDbf3     := {}
	aCabs3    := {}
	aCampos3  := {}
	aTitulos3 := {}
	aImpr3	  := {}
	aFormat3  := {}
	aFormula3 := {}
	aPict3	  := {}

	aAdd(aTitulos3,"Demonstrativo de Rentabilidades - Competencia: "+STRZERO(nMesC,2)+" / "+STRZERO(nAnoC,4))

	aAdd(aDbf3		,{ 'XX_CODGCT' ,'C', 09,00 } )
	aAdd(aCampos3	,"TRB3->XX_CODGCT")
	aAdd(aCabs3		,"Contrato")
	aAdd(aImpr3		,.T.)
	aAdd(aFormat3	,"")
	aAdd(aPict3		,"")

	aAdd(aDbf3		,{ 'XX_DESC'   ,'C', 50,00 } )
	aAdd(aCampos3	,"TRB3->XX_DESC")
	aAdd(aCabs3  	,"Descrição")
	aAdd(aImpr3		,.T.)
	aAdd(aFormat3	,"")
	aAdd(aPict3		,"@!")

	aAdd(aDbf3		,{ 'XX_OBJETO' ,'C', 50,00 } )
	aAdd(aCampos3	,"TRB3->XX_OBJETO")
	aAdd(aCabs3 	,"Objeto")
	aAdd(aImpr3		,.T.)
	aAdd(aFormat3	,"")
	aAdd(aPict3		,"@!")

	aAdd(aDbf3		,{ 'XX_FATRM'  ,'N', 18,02 } )
	aAdd(aCampos3	,"TRB3->XX_FATRM")
	aAdd(aCabs3 	,"Fat Real Mês")
	aAdd(aImpr3		,.T.)
	aAdd(aFormat3	,"")
	aAdd(aPict3		,"@E 99,999,999,999.99")

	aAdd(aDbf3		,{ 'XX_RENTM'  ,'N', 18,02 } )
	aAdd(aCampos3	,"TRB3->XX_RENTM")
	aAdd(aCabs3 	,"Rent. Mes")
	aAdd(aImpr3		,.T.)
	aAdd(aFormat3	,"")
	aAdd(aPict3		,"@E 99,999,999,999.99")

	aAdd(aDbf3		,{ 'XX_RENTMP' ,'N', 11,02 } )
	aAdd(aCampos3	,"TRB3->XX_RENTMP")
	aAdd(aCabs3 	,"Rent. Mes %")
	aAdd(aImpr3		,.T.)
	aAdd(aFormat3	,"")
	aAdd(aPict3		,"@E 99999.99999")

	aAdd(aDbf3		,{ 'XX_RENTAC' ,'N', 18,02 } )
	aAdd(aCampos3	,"TRB3->XX_RENTAC")
	aAdd(aCabs3 	,"Rent. Acum.")
	aAdd(aImpr3		,.T.)
	aAdd(aFormat3	,"")
	aAdd(aPict3		,"@E 99,999,999,999.99")

	aAdd(aDbf3		,{ 'XX_RENTACP','N', 11,02 } )
	aAdd(aCampos3	,"TRB3->XX_RENTACP")
	aAdd(aCabs3 	,"Rent. Acum. %")
	aAdd(aImpr3		,.T.)
	aAdd(aFormat3	,"")
	aAdd(aPict3		,"@E 99999.99999")

	oTmpTb3 := FWTemporaryTable():New( "TRB3" ) 
	oTmpTb3:SetFields( aDbf3 )
	oTmpTb3:Create()

EndIf


aDbfT		:= {}
aCabsT		:= {}
aCamposT 	:= {}

nTamCodGct	:= 9
nTamCodigo	:= 16
aPeriodo	:= {}
nCompet		:= 0
dDataInicio := dDataI

aAdd(aDbfT, { 'XX_CODGCT','C', nTamCodGct,00 } )
aAdd(aCamposT,ALIAS_TMP+"->XX_CODGCT")
aAdd(aCabsT  ,"Contrato")

aAdd(aDbfT, { 'XX_CODIGO','C', nTamCodigo,00 } )
aAdd(aCamposT,ALIAS_TMP+"->XX_CODIGO")
aAdd(aCabsT  ,"Cod.Rentab")

aAdd(aDbfT, { 'XX_DESC'  ,'C',         50,00 } )
aAdd(aCamposT,ALIAS_TMP+"->XX_DESC")
aAdd(aCabsT  ,"Descrição")

FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,3)
	aAdd(aDbfT, { 'XX_VALP'+cMes,'N', 18,02 } )
	aAdd(aCamposT,ALIAS_TMP+"->XX_VALP"+cMes)
	aAdd(aCabsT,STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4))

	aAdd( aDbfT, { 'XX_VALR'+cMes,'N', 18,02 } )
	aAdd(aCamposT,ALIAS_TMP+"->XX_VALR"+cMes)
	aAdd(aCabsT,STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4))

	aAdd( aDbfT, { 'XX_VL2P'+cMes,'N', 18,02 } )

  	aAdd(aPeriodo,{STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4)})
	aAdd(aAnoMes,STRZERO(YEAR(dDataInicio),4)+STRZERO(Month(dDataInicio),2))  
  	IF Month(dDataInicio) == nMesC .AND. YEAR(dDataInicio)== nAnoC
  		nCompet	:= _nI
  	ENDIF
	dDataInicio := MonthSum(dDataInicio,1)

NEXT

oTmpTbT := FWTemporaryTable():New( ALIAS_TMP ) 
oTmpTbT:SetFields( aDbfT )
oTmpTbT:AddIndex("indice2", {"XX_CODGCT","XX_CODIGO"} )
oTmpTbT:Create()
cRealTbT := oTmpTbT:GetRealName()


If !lJob
	If nCompet <> 0
		ProcRegua(1)
		Processa( {|| ProcR14(lJob) })
		If !lSintetico
			//Processa( {|| MBrwR14() })

			DbSelectArea("TRB")
			dbSetOrder(1)

			Processa( {|| U_CR14(.F.) })

		Else
			U_BKGCTM14()
		EndIf
	Else
		MsgStop("Competencia não encontrada!!")
	EndIf
Else
	If nCompet <> 0
		ProcR14(lJob)
		U_CR14(lJob)
	Else
		u_xxLog(cArqLog,"Competencia não encontrada : "+STR(nCompet),.T.,"")
	EndIf
EndIf


oTmpTb1:Delete()
If lSintetico .OR. lJob
	oTmpTb2:Delete()
	oTmpTb3:Delete()
EndIf
oTmpTbT:Delete()

If lJob
	Reset Environment
EndIf

Return



Static Function MBrwR14()
Local 	cAlias 		:= "TRB"
//Local 	aCores 		:= {}

Private cCadastro	:= IIF(lSintetico,"Sintético - ","")+"Relatório de Rentabilidade dos Contratos - Projeção X Realizado "
Private aRotina		:= {}
Private aIndexSz  	:= {}

Private aSize   := MsAdvSize(,.F.,400)
Private aObjects:= { { 450, 450, .T., .T. } }
Private aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aPosObj := MsObjSize( aInfo, aObjects, .T. )
Private lRefresh:= .T.
Private aButton := {}
Private _oGetDbSint
Private _oDlgSint

aAdd(aRotina,{"Exp. Excel"	,"U_CR14",0,6})
aAdd(aRotina,{"Parametros"	,"U_PR14",0,7})


dbSelectArea(cAlias)
dbSetOrder(1)
	
DEFINE MSDIALOG _oDlgSint ;
TITLE cCadastro ;
From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
_oGetDbSint := MsGetDb():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], 2, "AllwaysTrue()", "AllwaysTrue()",,,,,,"AllwaysTrue()","TRB")
	
aAdd(aButton , { "BMPTABLE" , { || U_CR14(.F.), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Gera Planilha Excel" } )
aAdd(aButton , { "BMPTABLE" , { || U_PR14(.F.), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Parametros" } )

ACTIVATE MSDIALOG _oDlgSint ON INIT EnchoiceBar(_oDlgSint,{|| _oDlgSint:End()}, {||_oDlgSint:End()},, aButton)

Return Nil



User FUNCTION PR14(lJob)
LOCAL cPerg     := "BKGCTR14"
DEFAULT lJob	:= .F.

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

cContrato   := mv_par01
nMesC 		:= mv_par02
nAnoC  		:= mv_par03

ProcRegua(1)

Processa( {|| ProcR14(.F.) })

Return Nil
   

Static Function LimpaBrw(cAlias)
	DbSelectArea(cAlias)
	(cAlias)->(dbgotop())
	Do While (cAlias)->(!eof())
		RecLock(cAlias,.F.)
		(cAlias)->(dbDelete())
		(cAlias)->(MsUnlock())
       	dbselectArea(cAlias)
   		(cAlias)->(dbskip())
	ENDDO

Return (.T.)



User FUNCTION CR14(lJob)
Local cAlias := "TRB"
//Local cQuery := ""

dbSelectArea(cAlias)

If !lJob
	ProcRegua(1)
	If lSintetico
		Processa( {|| GeraCR14(lJob,"TRB2",TRIM(cPerg)+"S",aTitulos2,aCampos2,aCabs2,aImpr2,aFormula2,aFormat2)})
		Processa( {|| GeraCR14(lJob,"TRB3",TRIM(cPerg)+"D",aTitulos3,aCampos3,aCabs3,aImpr3,aFormula3,aFormat3)})
	Else
		/*
		If Empty(cContrato)	
			cQuery := "DROP TABLE PowerBk.dbo.PROJXREALTELA"+cEmpAnt+CRLF
			nErro  := TcSqlExec(cQuery)

			//cQuery := "SELECT * INTO PowerBk.dbo.PROJXREALT"+cEmpAnt+" FROM "+cRealTb1 //+" WHERE XX_POWERBK = 'S' "

			cNomeEmp := ""
			If cEmpAnt == '01'
				cNomeEmp := "BK"
			ElseIf cEmpAnt == '02'
				cNomeEmp := "BKTER"
			ElseIf cEmpAnt == '14'
				cNomeEmp := "BALSA NOVA"
			EndIf
			cQuery := " SELECT "+CRLF
			cQuery += "    '"+cEmpAnt+"' AS EMPRESA,"+CRLF
			cQuery += "    '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
			cQuery += "    '"+DTOS(DATE())+"' AS DATAPRC,"+CRLF
			cQuery += "    '"+SUBSTR(TIME(),1,5)+"' AS HORAPRC,"+CRLF
			cQuery += "    *"+CRLF
			cQuery += " INTO PowerBk.dbo.PROJXREALTELA"+cEmpAnt+" FROM "+cRealTb1+" WHERE XX_POWERBK = 'S' "

			u_xxLog(cArqLog,"BKGCTR14: Gerando tabela PowerBk.dbo.PROJXREALTELA"+cEmpAnt,.T.,"")

			If TCSQLExec(cQuery) < 0 
				MsgStop(TCSQLERROR())
			EndIf
		EndIf
		*/

		Processa( {|| GeraCR14(lJob,cAlias,TRIM(cPerg),aTitulos1,aCampos1,aCabs1,aImpr1,aFormula1,aFormat1)})

	EndIf
Else

	// Gerar tabela no banco PowerBk
	If Empty(cContrato)
		u_xxLog(cArqLog,"BKGCTR14: Gerando tabela PowerBk.dbo.PROJXREAL"+cEmpAnt,.T.,"")
		GeraPwBk()
	EndIf

	// Gerar o analitico e os sintéticos no Schedule
	GeraCR14(lJob,cAlias,TRIM(cPerg),    aTitulos1,aCampos1,aCabs1,aImpr1,aFormula1,aFormat1)
	GeraCR14(lJob,"TRB2",TRIM(cPerg)+"S",aTitulos2,aCampos2,aCabs2,aImpr2,aFormula2,aFormat2)
	GeraCR14(lJob,"TRB3",TRIM(cPerg)+"D",aTitulos3,aCampos3,aCabs3,aImpr3,aFormula3,aFormat3)

EndIf

Return Nil


Static Function GeraPwBK()
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0
Local cQuery 	:= ""
Local cQueryV	:= ""
Local nErro		:= 0
Local cEmpresa  := ""
Local cNomeEmp  := ""

cQuery := "DROP TABLE PowerBk.dbo.PROJXREAL"+cEmpAnt+CRLF
nErro  := TcSqlExec(cQuery)
cQuery := "SELECT * INTO PowerBk.dbo.PROJXREAL"+cEmpAnt+" FROM "+cRealTb1+" WHERE XX_POWERBK = 'S' "
nErro  := TcSqlExec(cQuery)

If cEmpAnt == '01' 
	cQuery := "DROP TABLE PowerBk.dbo.PROJXREAL"+CRLF
	nErro  := TcSqlExec(cQuery)

	cQuery := ""
	For nE := 1 TO Len(aEmpresas)

		cEmpresa := aEmpresas[nE,1]
		cNomeEmp := aEmpresas[nE,2]

		If nE > 1
			cQueryV := "SELECT TOP 1 * FROM PowerBk.dbo.PROJXREAL"+cEmpresa+" "+CRLF
			nErro   := TcSqlExec(cQueryV)
			If nErro < 0 
				Loop
			EndIf
			cQuery += "UNION ALL "+CRLF
		EndIf
		cQuery += " SELECT "+CRLF
		cQuery += "    '"+cEmpresa+"' AS EMPRESA,"+CRLF
		cQuery += "    '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
		cQuery += "    '"+DTOS(DATE())+"' AS DATAPRC,"+CRLF
		cQuery += "    '"+SUBSTR(TIME(),1,5)+"' AS HORAPRC,"+CRLF
		cQuery += "    *"+CRLF
		If nE == 1
			cQuery += " INTO PowerBk.dbo.PROJXREAL "+CRLF
		EndIf
		cQuery += " FROM PowerBk.dbo.PROJXREAL"+cEmpresa+" "+CRLF

		//SELECT * INTO RESULTADOGLOBAL FROM PROJXREAL  WHERE XX_DESC = 'RESULTADO DO MÊS - GLOBAL'

	Next
	nErro  := TcSqlExec(cQuery)
EndIf

Return Nil


 
Static Function ProcR14(lJob)
Local cQuery	:= ""
Local cQueryA	:= ""
Local cQueryX	:= ""
Local cProcSZG	:= ""
Local nIndTC	:= 0 
Local nVlp2		:= 0
Local nPrev		:= 0
Local aNDC		:= {}
Local cAnoMes	:= ""

Local cContraA	:= ""
Local nVarLog	:= 0
Local cVarLog	:= 0
Local cJCNDCNE	:= FWJoinFilial("CND", "CNE")
Local cJCXNCNE	:= FWJoinFilial("CXN", "CNE")
//Local cJCN1CN9	:= FWJoinFilial("CN1", "CN9")
Local cJCNACNF	:= FWJoinFilial("CNA", "CNF")
//Local cJCNACN9	:= FWJoinFilial("CNA", "CN9")
Local cJSC5CNE	:= FWJoinFilial("SC5", "CNE")
Local cJSC6SC5	:= FWJoinFilial("SC6", "SC5")
Local cJSD2SC6	:= FWJoinFilial("SD2", "SC6")
Local IX		:= 0
Local _IX2		:= 0
Local _IXFUR	:= 0
Local XI_		:= 0
Local Yi_		:= 0
Local _XI		:= 0
Local _nI		:= 0
Local _nJ		:= 0
Local dMaxCompet:= CTOD("")
Local cCompet	:= ""
Local cNMeses	:= ""
Local nNMeses	:= 3
Local nMesA		:= 0
Local nAnoA 	:= 0

LimpaBrw("TRB")
LimpaBrw(ALIAS_TMP)
If lSintetico
	LimpaBrw("TRB3")
EndIf

If !lJob
	ProcRegua(nPeriodo)
EndIf

FOR _nI := 1 TO nPeriodo

	//nDespesa := 0
	//nDespCon := 0
	If !lJob
		IncProc("Processando competência "+SUBSTR(aPeriodo[_nI,1],1,2)+"/"+SUBSTR(aPeriodo[_nI,1],4,4))
	EndIf
	u_xxLog(cArqLog,"BKGCTR14: Processando competencia "+aPeriodo[_nI,1],.T.,"")

    cAnoMes := aAnoMes[_nI] 

	//*********Faturamento do Contrato

	cQuery := "WITH FATPREV AS ("+CRLF 
	cQuery += " SELECT"+CRLF 
	cQuery += "   CNF_CONTRA" +CRLF
	cQuery += "   ,CNF_REVISA"+CRLF
	cQuery += "   ,A1_NOME"   +CRLF
	cQuery += "   ,CTT_DESC01"+CRLF
	cQuery += "   ,CN9_SITUAC"+CRLF
	cQuery += "   ,CN9_XXNRBK"+CRLF
	cQuery += "   ,CNA_XXMUN" +CRLF
	cQuery += "   ,SUM(D2_TOTAL)  AS D2_TOTAL"+CRLF
	cQuery += "   ,SUM(D2_VALISS) AS D2_VALISS"+CRLF
	cQuery += "   ,SUM(D2_VALCPM) AS D2_VALCPM"+CRLF
	cQuery += "   ,SUM(E5_VALOR)  AS E5DESC"+CRLF

	// Nova Medição
	cQuery += " FROM "+RETSQLNAME("CNE")+" CNE"+CRLF

	cQuery += " LEFT JOIN "+RETSQLNAME("CND")+" CND" + CRLF
	cQuery += " 	ON (CND_NUMMED = CNE_NUMMED AND CND_CONTRA = CNE_CONTRA AND CND_REVISA = CNE_REVISA" +CRLF
	cQuery += " 		AND "+cJCNDCNE+" AND CND.D_E_L_E_T_='')" + CRLF

	cQuery += " LEFT JOIN "+RETSQLNAME("CXN")+" CXN" + CRLF
	cQuery += " 	ON (CXN_CONTRA = CNE_CONTRA AND CXN_REVISA = CNE_REVISA AND CXN_NUMMED = CNE_NUMMED AND CXN_NUMPLA = CNE_NUMERO AND CXN.CXN_CHECK = 'T'" +CRLF
	cQuery += " 		AND "+cJCXNCNE+" AND CXN.D_E_L_E_T_='')" + CRLF

	cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+" CTT" + CRLF
	cQuery += " 	ON (CTT_CUSTO = CNE_CONTRA" + CRLF
	cQuery += " 		AND CTT_FILIAL = '"+xFilial("CTT")+"' AND CTT.D_E_L_E_T_='')" + CRLF

	cQuery += " LEFT JOIN "+RETSQLNAME("CN9")+" CN9" + CRLF
	cQuery += " 	ON (CN9_FILCTR = CND_FILCTR AND CN9_NUMERO = CNE_CONTRA AND CN9_REVISA = CNE_REVISA" +CRLF
	cQuery += " 	 	AND CN9_FILIAL = CND_FILCTR AND CN9.D_E_L_E_T_='')" + CRLF

	cQuery += " LEFT JOIN "+RETSQLNAME("CNF")+" CNF" + CRLF
	cQuery += " 	ON (CNE_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CNE_NUMERO = CNF_NUMPLA AND CNE_REVISA = CNF_REVISA" +CRLF
	cQuery += " 	    AND CNF_PARCEL = ISNULL(CXN_PARCEL,CND_PARCEL)" + CRLF
	cQuery += " 	 	AND CNF_FILIAL = '01' AND CNF.D_E_L_E_T_='')" + CRLF

	//cQuery += " INNER JOIN "+RETSQLNAME("CN1")+" CN1" + CRLF
	//cQuery += " 	ON (CN1_CODIGO = CN9_TPCTO AND CN1_ESPCTR IN ('2')" + CRLF
	//cQuery += " 		AND "+cJCN1CN9+" AND CN1.D_E_L_E_T_='')" + CRLF

	cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+" CNA" + CRLF
	cQuery += " 	ON (CNA_CONTRA = CNE_CONTRA AND CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA AND CNA_NUMERO = CNF_NUMPLA" +CRLF
	cQuery += " 		AND "+cJCNACNF+" AND CNA.D_E_L_E_T_='')"+CRLF

	cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+" SC5" + CRLF
	cQuery += " 	ON (C5_MDNUMED = CNE_NUMMED AND C5_MDPLANI = CNE_NUMERO" + CRLF
	cQuery += " 		AND "+cJSC5CNE+" AND SC5.D_E_L_E_T_='')" + CRLF

	cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+" SC6" + CRLF
	cQuery += " 	ON (C5_CLIENT = C6_CLI AND C5_LOJACLI = C6_LOJA AND C6_NUM = C5_NUM AND C6_ITEMED = CNE_ITEM" +CRLF
	cQuery += " 		AND "+cJSC6SC5+" AND SC6.D_E_L_E_T_='')" + CRLF

	cQuery += " LEFT JOIN "+RETSQLNAME("SD2")+" SD2" + CRLF
	cQuery += " 	ON (D2_PEDIDO = C5_NUM AND D2_ITEMPV = C6_ITEM AND C5_CLIENT = D2_CLIENTE AND D2_LOJA = C5_LOJACLI" +CRLF
	cQuery += " 		AND "+cJSD2SC6+" AND SD2.D_E_L_E_T_='')" + CRLF

	cQuery += " LEFT JOIN "+RETSQLNAME("SE5")+" SE5" + CRLF
	cQuery += " 	ON (E5_PREFIXO = D2_SERIE AND E5_NUMERO = D2_DOC  AND E5_TIPO = 'NF' AND  " + CRLF
	cQuery += " 	    E5_CLIFOR = D2_CLIENTE AND E5_LOJA = D2_LOJA AND E5_TIPODOC = 'DC' AND " + CRLF
	cQuery += " 	    E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' AND " + CRLF
	cQuery += "         E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = '') "+CRLF

    cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1 "+CRLF 
	cQuery += "     ON (CN9.CN9_CLIENT = SA1.A1_COD "+CRLF 
    cQuery += "         AND CN9.CN9_LOJACL = SA1.A1_LOJA  AND "+CRLF 
	cQuery += "         SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = '')"+CRLF

	cQuery += " WHERE CNE.D_E_L_E_T_ = ' '"+ CRLF
	//cQuery += "       AND CNE_FILIAL = '"+xFilial("CNE")+"'"  Removido para considerar todas as filiais
	cQuery += "       AND CNF.CNF_COMPET='"+aPeriodo[_nI,1]+"' "+CRLF


	// Medição antiga
	/*
	cQuery := " SELECT CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CN9_XXNRBK,CNA_XXMUN,SUM(D2_TOTAL) AS D2_TOTAL,SUM(D2_VALISS) AS D2_VALISS,SUM(D2_VALCPM) AS D2_VALCPM, SUM(E5_VALOR) AS E5DESC"+CRLF
	cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF
    cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9.CN9_NUMERO = CNF.CNF_CONTRA AND CN9.CN9_REVISA = CNF.CNF_REVISA"+CRLF
	cQuery += "      AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND CN9.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+CRLF
	cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND CTT.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA"+CRLF
	cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CND_PARCEL = CNF_PARCEL AND CNA_NUMERO = CND_NUMERO AND CND_REVISA = CNF_REVISA"+CRLF
	cQuery += "      AND  CND.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM"+CRLF
	cQuery += "      AND  C6_FILIAL = CND_FILIAL AND SC6.D_E_L_E_T_ = ''"+CRLF
	cQuery += "	LEFT JOIN "+RETSQLNAME("SD2")+ " SD2 ON SC6.C6_NUM = SD2.D2_PEDIDO AND C6_ITEM = D2_ITEM"+CRLF
	// BKGCTR11 está diferente: LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM"+CRLF
	cQuery += "      AND  D2_FILIAL = CND_FILIAL AND SD2.D_E_L_E_T_ = ''"+CRLF
// 27/02/20   
	cQuery += " LEFT JOIN "+RETSQLNAME("SE5")+" SE5 ON E5_PREFIXO = D2_SERIE AND E5_NUMERO = D2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = D2_CLIENTE AND E5_LOJA = D2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' "+CRLF //--AND E5_PARCELA = '  '
	cQuery += "      AND  E5_FILIAL = '"+xFilial("SE5")+"' AND SE5.D_E_L_E_T_ = '' "+CRLF

    cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON CN9.CN9_CLIENT = SA1.A1_COD" +CRLF
    cQuery += "      AND CN9.CN9_LOJACL = SA1.A1_LOJA AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ''"+CRLF

	cQuery += " WHERE CNF.D_E_L_E_T_='' AND CNF.CNF_COMPET='"+aPeriodo[_nI,1]+"' "+CRLF
	*/

	cQueryX:= ""
    IF !EMPTY(cContrato)
		IF nConsol == 1
   			cQueryX += " AND SUBSTRING(CNF_CONTRA,1,3) ='"+ALLTRIM(cConsolida)+"'"+CRLF
   			IF cTipoContra == 'A'
				cQueryX += " AND CN9_SITUAC = '05'"+CRLF
   			ELSE
				cQueryX += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
   			ENDIF
		ELSEIF nConsol == 2
   			cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) ='"+ALLTRIM(cConsolida)+"'"+CRLF
   			IF cTipoContra == 'A'
				cQueryX += " AND CN9_SITUAC = '05'"+CRLF
   			ELSE
				cQueryX += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
   			ENDIF
		ELSEIF nConsol == 3
   			cQueryX += " AND CNF_CONTRA IN ("+ALLTRIM(cConsolida)+")"+CRLF
   			IF cTipoContra == 'A'
				cQueryX += " AND CN9_SITUAC = '05'"+CRLF
   			ELSE
				cQueryX += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
   			ENDIF
		ELSE
   	 		cQueryX += " AND CNF_CONTRA ='"+ALLTRIM(cContrato)+"'"+CRLF
			cQueryX += "AND CN9.CN9_SITUAC ='"+cSituac+"'"+CRLF 	 		
		ENDIF
    ELSE
		cContrCons := ""
 		For IX:= 1 TO LEN(aConsorcio)
 			cContrCons += "'"+ALLTRIM(aConsorcio[IX,1])+"',"
 		NEXT
		IF !lConsorcio
			IF !EMPTY(cContrCons)
   				cQueryX += " AND CNF_CONTRA NOT IN ("+SUBSTRING(ALLTRIM(cContrCons),1,LEN(cContrCons)-1)+") "+CRLF //TRATAMENTO ESPECIAL CONTRATO BKDAHER
   			ENDIF
   		ENDIF
		IF !lFurnas
			cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391'"+CRLF
		ENDIF
		IF !lPetro
			cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '455'"+CRLF
		ENDIF
		cQueryX += "AND CN9.CN9_SITUAC ='"+cSituac+"'"+CRLF   	 		
    ENDIF	

	cQuery += cQueryX
	cQuery += " GROUP BY CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CN9_XXNRBK,CNA_XXMUN"+CRLF

	// Juntar os cronogramas que não tiveram faturamento
	cQuery += " UNION ALL "+CRLF
	cQuery += "  SELECT DISTINCT"+CRLF
	cQuery += "   CNF_CONTRA" +CRLF
	cQuery += "   ,CNF_REVISA"+CRLF
	cQuery += "   ,A1_NOME"   +CRLF
	cQuery += "   ,CTT_DESC01"+CRLF
	cQuery += "   ,CN9_SITUAC"+CRLF
	cQuery += "   ,CN9_XXNRBK"+CRLF
	cQuery += "   ,CNA_XXMUN" +CRLF
	cQuery += "   ,0 AS D2_TOTAL"+CRLF
	cQuery += "   ,0 AS D2_VALISS"+CRLF
	cQuery += "   ,0 AS D2_VALCPM"+CRLF
	cQuery += "   ,0 AS E5DESC"+CRLF
	cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF

	cQuery += " LEFT JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA"+CRLF
	cQuery += "       AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"+CRLF

	cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+" CTT" + CRLF
	cQuery += " 	ON (CTT_CUSTO = CNF_CONTRA" + CRLF
	cQuery += " 		AND CTT_FILIAL = "+xFilial("CTT")+" AND CTT.D_E_L_E_T_='')" + CRLF

	cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+" CNA" + CRLF
	cQuery += " 	ON (CNA_CONTRA = CNF_CONTRA AND CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA AND CNA_NUMERO = CNF_NUMPLA" +CRLF
	cQuery += " 		AND "+cJCNACNF+" AND CNA.D_E_L_E_T_='')"+CRLF

    cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1 "+CRLF 
	cQuery += "     ON (CN9.CN9_CLIENT = SA1.A1_COD "+CRLF 
    cQuery += "         AND CN9.CN9_LOJACL = SA1.A1_LOJA  AND "+CRLF 
	cQuery += "         SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = '')"+CRLF

	cQuery += " WHERE CNF.D_E_L_E_T_=''"+CRLF
	cQuery += "       AND CNF.CNF_COMPET='"+aPeriodo[_nI,1]+"' "+CRLF
	cQuery += cQueryX

	/*
	IF nConsol == 1
   		cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) ='"+ALLTRIM(cConsolida)+"'"+CRLF
   		IF cTipoContra == 'A'
			cQuery += " AND CN9_SITUAC = '05'"+CRLF
   		ELSE
			cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
   		ENDIF
	ELSEIF nConsol == 2
   		cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) ='"+ALLTRIM(cConsolida)+"'"+CRLF
   		IF cTipoContra == 'A'
			cQuery += " AND CN9_SITUAC = '05'"+CRLF
   		ELSE
			cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
   		ENDIF
	ELSEIF nConsol == 3
   		cQuery += " AND CNF_CONTRA IN ("+ALLTRIM(cConsolida)+")"+CRLF
   		IF cTipoContra == 'A'
			cQuery += " AND CN9_SITUAC = '05'"+CRLF
   		ELSE
			cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
   		ENDIF
	ELSE
   		cQuery += " AND CNF_CONTRA ='"+ALLTRIM(cContrato)+"'"+CRLF 
		cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
	ENDIF
	*/
	cQuery += ")"+CRLF

 	cQuery += "SELECT " + CRLF
    cQuery += "  CNF_CONTRA" + CRLF
   	cQuery += "  ,CNF_REVISA" + CRLF
   	cQuery += "  ,A1_NOME" + CRLF
   	cQuery += "  ,CTT_DESC01" + CRLF
   	cQuery += "  ,CN9_SITUAC" + CRLF
   	cQuery += "  ,CN9_XXNRBK" + CRLF
   	cQuery += "  ,CNA_XXMUN" + CRLF
   	cQuery += "  ,SUM(D2_TOTAL)  AS D2_TOTAL" + CRLF
   	cQuery += "  ,SUM(D2_VALISS) AS D2_VALISS" + CRLF
   	cQuery += "  ,SUM(D2_VALCPM) AS D2_VALCPM" + CRLF
   	cQuery += "  ,SUM(E5DESC)    AS E5DESC " + CRLF
 
  	cQuery += " FROM FATPREV "+CRLF
   	cQuery += " GROUP BY CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CN9_XXNRBK,CNA_XXMUN"+CRLF
   	cQuery += " ORDER BY CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CN9_XXNRBK,CNA_XXMUN"+CRLF
 
	If Select("QTMP") > 0
		QTMP->(dbCloseArea())
	EndIf

	u_LogTxt("BKGCTR14-CNF.SQL")

	TCQUERY cQuery NEW ALIAS "QTMP" 

	u_LogTxt("BKGCTR14-CNF.SQL",cQuery)

	dbSelectArea("QTMP")
	QTMP->(dbGoTop())

	If QTMP->(EOF())
		//Não tem cronograma neste mes

	    QTMP->(dbCloseArea())
		cQueryA := " SELECT TOP 1 CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CN9_XXNRBK,' ' AS CNA_XXMUN,0 AS D2_TOTAL,0 AS D2_VALISS,0 AS D2_VALCPM, 0 AS E5DESC"+CRLF
		cQueryA += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF
		cQueryA += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9.CN9_NUMERO = CNF.CNF_CONTRA AND CN9.CN9_REVISA = CNF.CNF_REVISA"+CRLF
		cQueryA += "      AND CN9.CN9_FILIAL = '"+xFilial("CN9")+"' AND CN9.D_E_L_E_T_ = ''"+CRLF
		cQueryA += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+CRLF
		cQueryA += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ''"+CRLF
		cQueryA += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON CN9.CN9_CLIENT = SA1.A1_COD " +CRLF
		cQueryA += "      AND CN9.CN9_LOJACL = SA1.A1_LOJA AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_ = ''"+CRLF

		cQueryA += " WHERE CNF.D_E_L_E_T_='' "+CRLF 
		cQueryA += cQueryX

		u_LogTxt("BKGCTR14-CNF-A.SQL")

		TCQUERY cQueryA NEW ALIAS "QTMP"

		u_LogTxt("BKGCTR14-CNF-A.SQL",cQueryA)

		dbSelectArea("QTMP")
		QTMP->(dbGoTop())

	EndIf

	aNDC := {}

	DO WHILE QTMP->(!EOF())
	
        nScan:= 0
 		nScan:= aScan(aContConsol,{|x| x[1] =ALLTRIM(QTMP->CNF_CONTRA)})
		IF nScan == 0
			aAdd(aContConsol,{ALLTRIM(QTMP->CNF_CONTRA),QTMP->A1_NOME,QTMP->CTT_DESC01,QTMP->CN9_XXNRBK})
		ENDIF

        //VERIFICA INDICE CONSORCIO CASO CONTRATO DE CONSORCIO
        nIndTC := 0
        IF nIndConsor == 1
			nScan:= 0
			nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })
		    IF nScan > 0
		       nIndTC := VAL(aConsorcio[nScan,6]) 
		    ENDIF
        ENDIF

		//Localiza a Media de Impostos 
        FOR _IX2 := 1 TO LEN(aMImpContr)
        	IF aMImpContr[_IX2,1] <= SUBSTR(aPeriodo[_nI,1],4,4)+"/"+SUBSTR(aPeriodo[_nI,1],1,2)
        		nMImpContr := VAL(aMImpContr[_IX2,2])
        	ENDIF
        NEXT

        lISSFURNAS := .F.
        nISSFURNAS := 0
   		FOR _IXFUR:= 1 TO LEN(aFurnas)
			IF SUBSTR(ALLTRIM(QTMP->CNF_CONTRA),7,3) == SUBSTR(aFURNAS[_IXFUR],7,3)
       			lISSFURNAS := .T.
				IF "REMUNERACAO" $ QTMP->CNA_XXMUN
			        nISSFURNAS := QTMP->D2_VALISS
                ENDIF
				_IXFUR := LEN(aFurnas)
			ENDIF
		NEXT _IXFUR

        aRentab  := {}
        aAdd(aRentab,{"00","CLIENTE: ","S",TRIM(QTMP->A1_NOME)})              
        aAdd(aRentab,{"01","CONTRATO: ","S",TRIM(QTMP->CTT_DESC01)})              
        aAdd(aRentab,{"02","GESTOR BK: ","S",TRIM(QTMP->CN9_XXNRBK)})              
        aAdd(aRentab,{"03","FATURAMENTO OFICIAL","S",IIF(nIndTC>0,QTMP->D2_TOTAL/(nIndTC/100),QTMP->D2_TOTAL)})

        aAdd(aRentab,{"03-2","","S",0}) 
        aAdd(aRentab,{"04","(-) Impostos e Contribuições","S",IIF(nIndTC>0,((QTMP->D2_TOTAL*nMImpContr)/100)/(nIndTC/100),(QTMP->D2_TOTAL*nMImpContr)/100)})            
		IF lISSFURNAS
        	aAdd(aRentab,{"05","(-) ISS","S",nISSFURNAS})
        ELSE
        	aAdd(aRentab,{"05","(-) ISS","S",IIF(nIndTC>0,QTMP->D2_VALISS/(nIndTC/100),QTMP->D2_VALISS)})            
        ENDIF
        aAdd(aRentab,{"05-1","(-) ISS Bitributado","S",IIF(nIndTC>0,QTMP->D2_VALCPM/(nIndTC/100),QTMP->D2_VALCPM)})
        aAdd(aRentab,{"05-2","","S",0})
		IF lISSFURNAS
        	aAdd(aRentab,{"06","Total dos Impostos + ISS","S",((QTMP->D2_TOTAL*nMImpContr)/100)+nISSFURNAS})              
        ELSE
        	aAdd(aRentab,{"06","Total dos Impostos + ISS","S",IIF(nIndTC>0,(((QTMP->D2_TOTAL*nMImpContr)/100)+QTMP->D2_VALISS+QTMP->D2_VALCPM)/(nIndTC/100),((QTMP->D2_TOTAL*nMImpContr)/100)+QTMP->D2_VALISS+QTMP->D2_VALCPM)})            
        ENDIF
        aAdd(aRentab,{"06-1","","S",0})
		IF lISSFURNAS
        	aAdd(aRentab,{"07","FATURAMENTO LÍQUIDO","S",IIF(nIndTC>0,(QTMP->D2_TOTAL-(((QTMP->D2_TOTAL*nMImpContr)/100)+nISSFURNAS))/(nIndTC/100),QTMP->D2_TOTAL-(((QTMP->D2_TOTAL*nMImpContr)/100)+nISSFURNAS+QTMP->D2_VALCPM)) /*+nNDC*/}) 
        ELSE
        	aAdd(aRentab,{"07","FATURAMENTO LÍQUIDO","S",IIF(nIndTC>0,(QTMP->D2_TOTAL-(((QTMP->D2_TOTAL*nMImpContr)/100)+QTMP->D2_VALISS+QTMP->D2_VALCPM))/(nIndTC/100),QTMP->D2_TOTAL-(((QTMP->D2_TOTAL*nMImpContr)/100)+QTMP->D2_VALISS+QTMP->D2_VALCPM)) /*+nNDC*/ }) 
		ENDIF
        aAdd(aRentab,{"07-1","","S",0})
        aAdd(aRentab,{"08","CUSTO.","S",0})
        aAdd(aRentab,{"09","PROVENTOS","S",0}) 
        aAdd(aRentab,{"10","ENCARGOS","S",0}) 
        aAdd(aRentab,{"11","INCIDENCIAS","S",0})
        aAdd(aRentab,{"110","PLR","S",0}) 
        aAdd(aRentab,{"111","VERBAS SEM ENCARGOS/INCIDENCIAS","S",0}) 
        aAdd(aRentab,{"12A","BENEFICIOS","S",0}) 
        aAdd(aRentab,{"12","VT","S",0}) 
        aAdd(aRentab,{"13","(-) Recuperação de VT","S",0}) 
        aAdd(aRentab,{"14","VR/VA","S",0}) 
        aAdd(aRentab,{"15","(-) Recuperação de VR/VA","S",0}) 
        aAdd(aRentab,{"16","ASSMEDICA","S",0}) 
        aAdd(aRentab,{"17","(-) Recuperação de ASSMEDICA","S",0}) 
        aAdd(aRentab,{"18","SINDICATO (ODONTO)","S",0}) 
        //aAdd(aRentab,{"19","(-) Recuperação de Sindicato (Odonto)","S",0}) 
        aAdd(aRentab,{"20","CECREMEF/ADV","S",0}) 
        aAdd(aRentab,{"21","(-) CECREMEF/ADV","S",0}) 
        aAdd(aRentab,{"22-1","","S",0})
        aAdd(aRentab,{"30","GASTOS GERAIS","S",0}) 
		//27/02/20
        aAdd(aRentab,{"30-1","","S",0}) 
        aAdd(aRentab,{"30-2","DESCONTOS NA NF","S",IIF(nIndTC>0,QTMP->E5DESC/(nIndTC/100),QTMP->E5DESC)}) 

		nNDC := 0 
		nNDC := U_VALNDCE(ALLTRIM(QTMP->CNF_CONTRA),aPeriodo[_nI,1],_nI,@aNDC)
        aAdd(aRentab,{"30-3","NDC","S",-nNDC}) 

        aAdd(aRentab,{"YYYYYYYYY","TAXA DE ADMINISTRAÇÃO","S",0})
        aAdd(aRentab,{"YYYYYYYYZ","","S",0}) 
        aAdd(aRentab,{"ZZZZZZZZY","RESULTADO PARCIAL","S",0})
        aAdd(aRentab,{"ZZZZZZZZZ","RESULTADO GLOBAL","S",0})
		
		FOR _nJ := 1 TO LEN(aRentab)
			dbSelectArea(ALIAS_TMP)
			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+aRentab[_nJ,1],.F.)
				Reclock(ALIAS_TMP,.F.)
				(ALIAS_TMP)->XX_DESC   := IIF("|"+aRentab[_nJ,1]+"|" $ "|00|01|02|",aRentab[_nJ,4],aRentab[_nJ,2])
			ELSE
				Reclock(ALIAS_TMP,.T.)

				(ALIAS_TMP)->XX_CODGCT := IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
				(ALIAS_TMP)->XX_CODIGO := aRentab[_nJ,1]
				(ALIAS_TMP)->XX_DESC   := IIF("|"+aRentab[_nJ,1]+"|" $ "|00|01|02|",aRentab[_nJ,4],aRentab[_nJ,2])

				//teste
				//(ALIAS_TMP)->XX_DESC   := aPeriodo[_nI,1]+IIF("|"+aRentab[_nJ,1]+"|" $ "|00|01|02|",aRentab[_nJ,4],aRentab[_nJ,2])+TRANSFORM(QTMP->D2_TOTAL,"@E 99999999.99999")

			ENDIF
			IF "|"+aRentab[_nJ,1]+"|" $ "|03|03-1|04|05|05-1|06|07|30-2|30-3|"  // 28/10/20
				cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
				&cCampo2 += aRentab[_nJ,4]
			ENDIF
			//(ALIAS_TMP)->XX_STATUS := QTMP->CN9_SITUAC
			(ALIAS_TMP)->(Msunlock())
        NEXT          
	   	dbSelectArea("QTMP")
	   	QTMP->(dbSkip())
	ENDDO

	/*

    QTMP->(dbCloseArea())

	//*********Faturamento do Contrato
	cQuery := " SELECT CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CN9_DTULST,CN9_XXNRBK,SUM(D2_TOTAL) AS D2_TOTAL,SUM(D2_VALISS) AS D2_VALISS,SUM(D2_VALCPM) AS D2_VALCPM, SUM(E5_VALOR) AS E5DESC"+CRLF
	cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF
    cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9.CN9_NUMERO = CNF.CNF_CONTRA AND CN9.CN9_REVISA = CNF.CNF_REVISA AND  CN9.CN9_FILIAL = '"+xFilial("CN9")+"' AND CN9.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+CRLF
	cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA"+CRLF
	cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CND_PARCEL = CNF_PARCEL AND CNA_NUMERO = CND_NUMERO AND CND_REVISA = CNF_REVISA"+CRLF
	cQuery += "      AND  CND.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM"+CRLF
	cQuery += "      AND  C6_FILIAL = CND_FILIAL AND SC6.D_E_L_E_T_ = ''"+CRLF
	cQuery += "	LEFT JOIN "+RETSQLNAME("SD2")+ " SD2 ON SC6.C6_NUM = SD2.D2_PEDIDO AND C6_ITEM = D2_ITEM"+CRLF
	cQuery += "      AND  D2_FILIAL = CND_FILIAL AND SD2.D_E_L_E_T_ = ''"+CRLF
	// 27/02/20   
	cQuery += " LEFT JOIN "+RETSQLNAME("SE5")+" SE5 ON E5_PREFIXO = D2_SERIE AND E5_NUMERO = D2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = D2_CLIENTE AND E5_LOJA = D2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' "+CRLF //--AND E5_PARCELA = '  '
	cQuery += "      AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = '' "+CRLF

    cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON CN9.CN9_CLIENT = SA1.A1_COD" +CRLF
    cQuery += "      AND CN9.CN9_LOJACL = SA1.A1_LOJA  AND  SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ''"

	cQuery += " WHERE CNF.D_E_L_E_T_='' AND CNF.CNF_COMPET='"+aPeriodo[_nI,1]+"' "+CRLF

	cQueryX:= ""
    IF !EMPTY(cContrato)
		IF nConsol == 1
   			cQueryX += " AND SUBSTRING(CNF_CONTRA,1,3) ='"+ALLTRIM(cConsolida)+"'"+CRLF
   			IF cTipoContra == 'A'
				cQueryX += " AND CN9_SITUAC = '05'"+CRLF
   			ELSE
				cQueryX += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
   			ENDIF
		ELSEIF nConsol == 2
   			cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) ='"+ALLTRIM(cConsolida)+"'"+CRLF
   			IF cTipoContra == 'A'
				cQueryX += " AND CN9_SITUAC = '05'"+CRLF
   			ELSE
				cQueryX += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
   			ENDIF
		ELSEIF nConsol == 3
   			cQueryX += " AND CNF_CONTRA IN ("+ALLTRIM(cConsolida)+")"+CRLF
   			IF cTipoContra == 'A'
				cQueryX += " AND CN9_SITUAC = '05'"+CRLF
   			ELSE
				cQueryX += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
   			ENDIF
		ELSE
   	 		cQueryX += " AND CNF_CONTRA ='"+ALLTRIM(cContrato)+"'"+CRLF
			cQueryX += "AND CN9.CN9_SITUAC ='"+cSituac+"'"+CRLF 		
		ENDIF
    ELSE
		cContrCons := ""
 		For IX:= 1 TO LEN(aConsorcio)
 			cContrCons += "'"+ALLTRIM(aConsorcio[IX,1])+"',"
 		NEXT
		IF !lConsorcio
			IF !EMPTY(cContrCons)
   				cQueryX += " AND CNF_CONTRA NOT IN ("+SUBSTRING(ALLTRIM(cContrCons),1,LEN(cContrCons)-1)+") "+CRLF //TRATAMENTO ESPECIAL CONTRATO BKDAHER
   			ENDIF
   		ENDIF
		IF !lFurnas
			cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391'"+CRLF
		ENDIF
		IF !lPetro
			cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '455'"+CRLF
		ENDIF
		cQueryX += "AND CN9.CN9_SITUAC ='"+cSituac+"'" +CRLF  	 		
    ENDIF	

	cQuery += cQueryX
	cQuery += " GROUP BY CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CN9_DTULST,CN9_XXNRBK ORDER BY CNF_CONTRA"+CRLF
 
	u_LogMemo("BKGCTR14-CNF-2-"+STRZERO(_nI,3)+".SQL",cQuery)

	TCQUERY cQuery NEW ALIAS "QTMP" 

	dbSelectArea("QTMP")
	QTMP->(dbGoTop())

	If QTMP->(EOF())
		//Não tem cronograma neste mes

	    QTMP->(dbCloseArea())

		cQueryA := " SELECT TOP 1 CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CN9_DTULST,CN9_XXNRBK,0 AS D2_TOTAL,0 AS D2_VALISS,0 AS D2_VALCPM, 0 AS E5DESC"+CRLF
		cQueryA += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF
		cQueryA += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9.CN9_NUMERO = CNF.CNF_CONTRA AND CN9.CN9_REVISA = CNF.CNF_REVISA"+CRLF
		cQueryA += "      AND CN9.CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"+CRLF
		cQueryA += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+CRLF
		cQueryA += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ''"+CRLF
		cQueryA += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON CN9.CN9_CLIENT = SA1.A1_COD " +CRLF
		cQueryA += "      AND CN9.CN9_LOJACL = SA1.A1_LOJA AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ''"+CRLF

		cQueryA += " WHERE CNF.D_E_L_E_T_='' "+CRLF 
		cQueryA += cQueryX

		u_LogMemo("BKGCTR14-CNF-B-"+STRZERO(_nI,3)+".SQL",cQueryA)

		TCQUERY cQueryA NEW ALIAS "QTMP"
		dbSelectArea("QTMP")
		QTMP->(dbGoTop())
	EndIf
	*/


	dbSelectArea("QTMP")
	QTMP->(dbGoTop())
	
	cContraA := ""
	nVarLog  := 0
	DO WHILE QTMP->(!EOF())

		If cContraA == QTMP->CNF_CONTRA
			dbSelectArea("QTMP")
			dbSkip()
			Loop
		EndIf

		cContraA := QTMP->CNF_CONTRA
		nVarLog++
		cVarLog := STRZERO(nVarLog,3)+"-"+cAnoMes+"-"+ALLTRIM(cContraA)

        nScan:= 0
 		nScan:= aScan(aContratos,{|x| x = IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))})
		IF nScan == 0
			aAdd(aContratos  ,IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA)))
		ENDIF
        
 		////FOR _XI := 1 TO nPeriodo
			_XI		 := _nI
        	/////IF aPeriodo[_XI,1] == STRZERO(nMesC,2)+"/"+STRZERO(nAnoC,4)  .AND. cProcSZG <> QTMP->CNF_CONTRA
	        	cProcSZG := QTMP->CNF_CONTRA
				//Calcula Valores da Projeção Financeira
            	nSZG03   := 0
            	nSZG09   := 0
            	nSZG110  := 0
            	nSZG111  := 0
            	nSZG12   := 0
            	nSZG30   := 0
            	nSZCSTBK := 0
				nDespesa := 0
				//nDespCon := 0

				nScan:= 0
				nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })

				// Previsão de Faturamento
				cQuery := " SELECT SUM(CNF_VLPREV) AS CNF_FATURA"+CRLF
				cQuery += " FROM "+RETSQLNAME("CNF")+ " CNF"+CRLF
				cQuery += " WHERE CNF.D_E_L_E_T_='' AND CNF.CNF_CONTRA='"+ALLTRIM(QTMP->CNF_CONTRA)+"'AND "+CRLF
				cQuery += "       CNF.CNF_REVISA='"+QTMP->CNF_REVISA+"' AND CNF.CNF_FILIAL = '"+xFilial("CNF")+"'"+CRLF
				cQuery += "       AND CNF.CNF_COMPET='"+aPeriodo[_XI,1]+"'"+CRLF
	      
				u_LogTxt("BKGCTR14-CNF-P.SQL")

				TCQUERY cQuery NEW ALIAS "TMPX2"

				u_LogTxt("BKGCTR14-CNF-P.SQL",cQuery)

				dbSelectArea("TMPX2")
				TMPX2->(dbGoTop())
				DO WHILE TMPX2->(!EOF())
						
				    //VERIFICA INDICE CONSORCIO CASO CONTRATO DE CONSORCIO
   					nIndTC := 0
   					IF nIndConsor == 1
   						IF nScan > 0
       						nIndTC := VAL(aConsorcio[nScan,6]) 
    					ENDIF
    				ENDIF

					IF QTMP->CN9_SITUAC $ "01/08" .AND. SUBSTR(aPeriodo[_XI,1],4,4)+SUBSTR(aPeriodo[_XI,1],1,2) > SUBSTR(QTMP->CN9_DTULST,1,6)
						nPrev := 0
					ELSE
						nPrev := TMPX2->CNF_FATURA
					ENDIF

					nSZG03 := IIF(nIndTC>0,nPrev/(nIndTC/100),nPrev)

   					TMPX2->(dbSkip())
				ENDDO
						
				TMPX2->(dbCloseArea())


				// Previsão de despesas
				dDtProj  := CTOD("")
				cSeqProj := ""
        		dbselectArea("SZG")
				cContRev := xFilial("SZG")+ALLTRIM(QTMP->CNF_CONTRA) //+QTMP->CNF_REVISA
				SZG->(dbSeek(cContRev,.T.))
				Do While !EOF() .AND. ALLTRIM(cContRev) == ALLTRIM(SZG->ZG_FILIAL+SZG->ZG_CONTRAT) //+SZG->ZG_REVISAO
					IF SUBSTR(DTOS(SZG->ZG_DATA),1,6) <= aAnoMes[_nI] //STRZERO(nAnoC,4)+STRZERO(nMesC,2)

         				nDespesa := SZG->ZG_CLT+SZG->ZG_VLENCSO+SZG->ZG_AJCUSTO+SZG->ZG_VLENAC+SZG->ZG_BENEFIC+SZG->ZG_UNIFORM+SZG->ZG_DESPDIV+SZG->ZG_MATERIA+SZG->ZG_EQUIPAM+SZG->ZG_VLTRIBU
                        
						// --> Marcos - 03/06/19
					    //VERIFICA INDICE CONSORCIO CASO CONTRATO DE CONSORCIO
       					nIndTC := 0
       					IF nIndConsor == 1
	   						IF nScan > 0
	       						nIndTC := VAL(aConsorcio[nScan,6]) 
	    					ENDIF
	    				ENDIF
	    				If nIndTC > 0
							nDespesa := nDespesa / (nIndTC/100)
						EndIf
                        // <-- Marcos - 03/06/19
                        
                        //nDespCon    += nDespesa
						dDtProj     := SZG->ZG_DATA
						cSeqProj	:= SZG->ZG_SEQ
         		
						nSZG09 := IIF(nIndTC>0,SZG->ZG_CLT/(nIndTC/100),SZG->ZG_CLT)

         				nSZG12 := IIF(nIndTC>0,SZG->ZG_BENEFIC/(nIndTC/100),SZG->ZG_BENEFIC)

         				nSZG30 := IIF(nIndTC>0,(SZG->ZG_AJCUSTO+SZG->ZG_VLENAC+SZG->ZG_UNIFORM+SZG->ZG_DESPDIV+;
							SZG->ZG_MATERIA+SZG->ZG_EQUIPAM)/(nIndTC/100),(SZG->ZG_AJCUSTO+SZG->ZG_VLENAC+SZG->ZG_UNIFORM+;
							SZG->ZG_DESPDIV+SZG->ZG_MATERIA+SZG->ZG_EQUIPAM))
							
						nSZCSTBK := SZG->ZG_AJCUSTO+SZG->ZG_VLENAC	
            		ENDIF
        			dbselectArea("SZG")
	   				SZG->(dbSkip())
				ENDDO
			//////ENDIF
		////NEXT

        /////IF aPeriodo[_nI,1] == STRZERO(nMesC,2)+"/"+STRZERO(nAnoC,4)

			//Carrega Valores da Projeção Financeira
			IF nSZG03 <> 0
				dbSelectArea(ALIAS_TMP)
   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'03',.F.)
     				Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
					&cCampo2 += nSZG03
					(ALIAS_TMP)->(Msunlock())
				ENDIF
			ENDIF
        	IF nSZG09 <> 0
        		dbSelectArea(ALIAS_TMP)
   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'09',.F.)
     				Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
					&cCampo2 += nSZG09
					(ALIAS_TMP)->(Msunlock())
				ENDIF
       		ENDIF
       		IF nSZG12 <> 0
   				dbSelectArea(ALIAS_TMP)
				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'12A',.F.)
     				Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
					&cCampo2 += nSZG12
					(ALIAS_TMP)->(Msunlock())
				ENDIF
   			ENDIF
        	IF nSZG30 <> 0
      			dbSelectArea(ALIAS_TMP)
				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
  					Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
					&cCampo2 += nSZG30
					(ALIAS_TMP)->(Msunlock())
				ENDIF
        	ENDIF

        	IF nSZCSTBK <> 0
      			dbSelectArea(ALIAS_TMP)
				IF !dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'W'+cCusBK,.F.)
					// 19/02/19 - Marcos - incluir registro se não existir
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF( nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
					(ALIAS_TMP)->XX_CODIGO := "W"+cCusBK
					(ALIAS_TMP)->XX_DESC   := cDescCBK
				Else
  					Reclock(ALIAS_TMP,.F.)
				EndIf

				cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
				&cCampo2 += nSZCSTBK
				(ALIAS_TMP)->(Msunlock())
        	ENDIF

        	IF nDespesa <> 0 //.OR. nDespCon <> 0 
      			dbSelectArea(ALIAS_TMP)
				IF !dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'PREVISTO',.F.)
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'PREVISTO'
					(ALIAS_TMP)->XX_CODIGO := "PREVISTO"
					cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
					&cCampo2 += ((nSZG03-nDespesa)*100)/nSZG03

					cCampo2  := ALIAS_TMP+"->XX_VL2P"+STRZERO(_nI,3)
					&cCampo2 += nSZG03 - nDespesa

				ELSE
					nSZG03C := 1
					dbSelectArea(ALIAS_TMP)
	   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'03',.F.)
						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
						nSZG03C  := &cCampo2
					ENDIF

					dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'PREVISTO',.F.)

					Reclock(ALIAS_TMP,.F.)

					cCampo2  := ALIAS_TMP+"->XX_VL2P"+STRZERO(_nI,3)
					&cCampo2 += nSZG03 - nDespesa
	                nVlp2    := &cCampo2

					cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
					&cCampo2 := (nVlp2*100)/nSZG03C
					
				ENDIF
			
				(ALIAS_TMP)->(Msunlock())
				
        	ENDIF   

			IF nDespGeral == 1  //.AND. nCompras == 0
	        	// CARREGA VALORES DETALHE PROJECAO
				dbSelectArea("SZL")
				SZL->(dbSetOrder(1))
				SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj,.T.))
				DO WHILE SZL->(!EOF()) .AND. SZL->ZL_CONTRAT==ALLTRIM(QTMP->CNF_CONTRA)
					IF SZL->ZL_DATA==dDtProj .AND. SZL->ZL_SEQ==cSeqProj
						dbSelectArea(ALIAS_TMP)
   						IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+SZL->ZL_CODIGO,.F.)
							Reclock(ALIAS_TMP,.F.)
						ELSE
							Reclock(ALIAS_TMP,.T.)
							(ALIAS_TMP)->XX_CODGCT := IIF( nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
							(ALIAS_TMP)->XX_CODIGO := SZL->ZL_CODIGO
							(ALIAS_TMP)->XX_DESC   := SZL->ZL_DESC
						ENDIF
						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
						&cCampo2 += IIF(nIndTC>0,SZL->ZL_VALOR/(nIndTC/100),SZL->ZL_VALOR)
						(ALIAS_TMP)->(Msunlock())
   	
    	        	ENDIF
					SZL->(dbskip())
				ENDDO
        	ENDIF

		/////ENDIF
		        
        
		//Calcula LF Avulso SZ2 - CLT
		cQuery1 := "SELECT Z2_CODEMP,Z2_CC,Z2_VALOR,Z2_TIPO,Z2_CC FROM "+RETSQLNAME("SZ2")+" SZ2"+CRLF
		cQuery1 += " WHERE  D_E_L_E_T_=''  AND Z2_TIPO IN ('EXM','VT','VR','VA','DCH','SOL','HOS','REE','CXA')"+CRLF  //REMOVIDO MULTA FGTS POR ENTENDER QUE ESTA EM INCIDENCIAS - TIPO = MFG
		cQuery1 += " AND Z2_TIPOPES='CLT' AND Z2_STATUS='S'"+CRLF

		nScan:= 0
		nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })

		IF nScan > 0 
			cQuery1 += " AND Z2_CODEMP='"+SUBSTR(ALLTRIM(aConsorcio[nScan,2]),1,2)+"'" +CRLF
			cQuery1 += " AND Z2_CC IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"','"+ALLTRIM(aConsorcio[nScan,7])+"')" +CRLF
		ELSE
			cQuery1 += " AND Z2_CODEMP='"+cEmpAnt+"'"+CRLF
			cQuery1 += " AND Z2_CC='"+ALLTRIM(QTMP->CNF_CONTRA)+"'"+CRLF
		ENDIF
		
		cQuery1 += " AND SUBSTRING(Z2_DATAPGT,1,6)='"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'"+CRLF

		u_LogTxt("BKGCTR14-SZ2.SQL")

		TCQUERY cQuery1 NEW ALIAS "TMPX2"

		u_LogTxt("BKGCTR14-SZ2.SQL",cQuery1)

		dbSelectArea("TMPX2")
		dbGoTop()
		DO While !TMPX2->(EOF())

			IF ALLTRIM(TMPX2->Z2_TIPO) == 'VT'

				//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - VT
				cVALGG := 0
				IF nDespGeral == 1  .AND. nCompras == 0
					IF !EMPTY(cSeqProj)
           				dbSelectArea("SZL")
						SZL->(dbSetOrder(1))
						IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj+'12',.F.))
							cVALGG := SZL->ZL_VALOR
						ELSE
							DbSelectArea("SZL")
							RecLock("SZL",.T.)
							SZL->ZL_FILIAL 	:= xFilial("SZL")
							SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
							SZL->ZL_TIPO	:= '01'
							SZL->ZL_DATA   	:= dDtProj
							SZL->ZL_SEQ   	:= cSeqProj
							SZL->ZL_CODIGO 	:= '12'
							SZL->ZL_DESC 	:= "VT"
							SZL->ZL_VALOR  	:= 0
							SZL->(msUnlock())
                   		ENDIF
					ENDIF
           		ENDIF

		   		dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'12',.F.)
		     		Reclock(ALIAS_TMP,.F.)
				//	cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
				//	&cCampo2 := cVALGG
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->Z2_VALOR
					(ALIAS_TMP)->(Msunlock())
				ENDIF
   				// GRAVA VALOR NO CUSTO
   				dbSelectArea(ALIAS_TMP)
   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
     				Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->Z2_VALOR
					(ALIAS_TMP)->(Msunlock())
				ENDIF
				
			ENDIF

			IF  ALLTRIM(TMPX2->Z2_TIPO)  $ 'VR/VA'
				//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - VR/VA
				cVALGG := 0
				IF nDespGeral == 1  .AND. nCompras == 0
					IF !EMPTY(cSeqProj)
           				dbSelectArea("SZL")
						SZL->(dbSetOrder(1))
						IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj+'14',.F.))
							cVALGG := SZL->ZL_VALOR
						ELSE
							DbSelectArea("SZL")
							RecLock("SZL",.T.)
							SZL->ZL_FILIAL 	:= xFilial("SZL")
							SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
							SZL->ZL_TIPO	:= '01'
							SZL->ZL_DATA   	:= dDtProj
							SZL->ZL_SEQ   	:= cSeqProj
							SZL->ZL_CODIGO 	:= '14'
							SZL->ZL_DESC 	:= 'VR/VA'
							SZL->ZL_VALOR  	:= 0
							SZL->(msUnlock())
                   		ENDIF
					ENDIF
           		ENDIF

		   		dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'14',.F.)
		     		Reclock(ALIAS_TMP,.F.)
				//	cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
				//	&cCampo2 += cVALGG
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->Z2_VALOR
					(ALIAS_TMP)->(Msunlock())
				ENDIF
   				// GRAVA VALOR NO CUSTO
   				dbSelectArea(ALIAS_TMP)
   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
     				Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->Z2_VALOR
					(ALIAS_TMP)->(Msunlock())
				ENDIF

			ENDIF
 

			IF  ALLTRIM(TMPX2->Z2_TIPO)  == 'EXM'

				//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - EXAME MEDICO
				cVALGG := 0
				IF nDespGeral == 1  .AND. nCompras == 0
					IF !EMPTY(cSeqProj)
           				dbSelectArea("SZL")
						SZL->(dbSetOrder(1))
						IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"02"+DTOS(dDtProj)+cSeqProj+"W"+cExm_Prod,.F.))
							cVALGG := SZL->ZL_VALOR
						ELSE
							DbSelectArea("SZL")
							RecLock("SZL",.T.)
							SZL->ZL_FILIAL 	:= xFilial("SZL")
							SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
							SZL->ZL_TIPO	:= '02'
							SZL->ZL_DATA   	:= dDtProj
							SZL->ZL_SEQ   	:= cSeqProj
							SZL->ZL_CODIGO 	:= "W"+cExm_Prod
							SZL->ZL_DESC 	:= cDescExm
							SZL->ZL_VALOR  	:= 0
							SZL->(msUnlock())
                   		ENDIF
					ENDIF
           		ENDIF

				dbSelectArea(ALIAS_TMP)
	   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+cExm_Prod,.F.)
					Reclock(ALIAS_TMP,.F.)
				ELSE
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF( nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
					(ALIAS_TMP)->XX_CODIGO := "W"+cExm_Prod
					(ALIAS_TMP)->XX_DESC   := cDescExm
				ENDIF
				//cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
				//&cCampo2 += cVALGG
				cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
				&cCampo2 += TMPX2->Z2_VALOR
				(ALIAS_TMP)->(Msunlock())

	   			dbSelectArea(ALIAS_TMP)
	   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
	     			Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->Z2_VALOR
					(ALIAS_TMP)->(Msunlock())
				ENDIF

			ENDIF

/*
			IF  ALLTRIM(TMPX2->Z2_TIPO)  == 'MFG'
				//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - MULTA FGTS
				cVALGG := 0
				IF nDespGeral == 1  .AND. nCompras == 0
					IF !EMPTY(cSeqProj)
           				dbSelectArea("SZL")
						SZL->(dbSetOrder(1))
						IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"02"+DTOS(dDtProj)+cSeqProj+"W"+cMFG_Prod,.F.))
							cVALGG := SZL->ZL_VALOR
						ELSE
							DbSelectArea("SZL")
							RecLock("SZL",.T.)
							SZL->ZL_FILIAL 	:= xFilial("SZL")
							SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
							SZL->ZL_TIPO	:= '02'
							SZL->ZL_DATA   	:= dDtProj
							SZL->ZL_SEQ   	:= cSeqProj
							SZL->ZL_CODIGO 	:= "W"+cMFG_Prod
							SZL->ZL_DESC 	:= Posicione("SB1",1,xFilial("SB1")+cMFG_Prod,"B1_DESC")
							SZL->ZL_VALOR  	:= 0
							SZL->(msUnlock())
                   		ENDIF
					ENDIF
           		ENDIF

				dbSelectArea(ALIAS_TMP)
	   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+cMFG_Prod,.F.)
					Reclock(ALIAS_TMP,.F.)
				ELSE
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
					(ALIAS_TMP)->XX_CODIGO := "W"+cMFG_Prod
					(ALIAS_TMP)->XX_DESC   := Posicione("SB1",1,xFilial("SB1")+cMFG_Prod,"B1_DESC")
				ENDIF
				//cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
				//&cCampo2 += cVALGG
				cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
				&cCampo2 += TMPX2->Z2_VALOR
				(ALIAS_TMP)->(Msunlock())

	   			dbSelectArea(ALIAS_TMP)
	   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
	     			Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->Z2_VALOR
					(ALIAS_TMP)->(Msunlock())
				ENDIF

			ENDIF

			IF  ALLTRIM(TMPX2->Z2_TIPO)  == 'DCH'

				//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - DCH
				cVALGG := 0
				IF nDespGeral == 1  .AND. nCompras == 0
					IF !EMPTY(cSeqProj)
           				dbSelectArea("SZL")
						SZL->(dbSetOrder(1))
						IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"02"+DTOS(dDtProj)+cSeqProj+"W"+cDCH_Prod,.F.))
							cVALGG := SZL->ZL_VALOR
						ELSE
							DbSelectArea("SZL")
							RecLock("SZL",.T.)
							SZL->ZL_FILIAL 	:= xFilial("SZL")
							SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
							SZL->ZL_TIPO	:= '02'
							SZL->ZL_DATA   	:= dDtProj
							SZL->ZL_SEQ   	:= cSeqProj
							SZL->ZL_CODIGO 	:= "W"+cDCH_Prod
							SZL->ZL_DESC 	:= cDescDCH
							SZL->ZL_VALOR  	:= 0
							SZL->(msUnlock())
                   		ENDIF
					ENDIF
           		ENDIF

				dbSelectArea(ALIAS_TMP)
	   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+cDCH_Prod,.F.)
					Reclock(ALIAS_TMP,.F.)
				ELSE
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
					(ALIAS_TMP)->XX_CODIGO := "W"+cDCH_Prod
					(ALIAS_TMP)->XX_DESC   := cDescDCH
				ENDIF
				//cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
				//&cCampo2 += cVALGG
				cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
				&cCampo2 += TMPX2->Z2_VALOR
				(ALIAS_TMP)->(Msunlock())

	   			dbSelectArea(ALIAS_TMP)
	   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
	     			Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->Z2_VALOR
					(ALIAS_TMP)->(Msunlock())
				ENDIF
			ENDIF

*/

			IF  ALLTRIM(TMPX2->Z2_TIPO) $ 'DCH/SOL/HOS/REE/CXA' // Despesas de Viagens 04/04/2022

				//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - DCH
				cVALGG := 0
				IF nDespGeral == 1 .AND. nCompras == 0
					IF !EMPTY(cSeqProj)
           				dbSelectArea("SZL")
						SZL->(dbSetOrder(1))
						IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"02"+DTOS(dDtProj)+cSeqProj+"W"+cDViagens,.F.))
							cVALGG := SZL->ZL_VALOR
						ELSE
							DbSelectArea("SZL")
							RecLock("SZL",.T.)
							SZL->ZL_FILIAL 	:= xFilial("SZL")
							SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
							SZL->ZL_TIPO	:= '02'
							SZL->ZL_DATA   	:= dDtProj
							SZL->ZL_SEQ   	:= cSeqProj
							SZL->ZL_CODIGO 	:= "W"+cDViagens
							SZL->ZL_DESC 	:= cDescDCH
							SZL->ZL_VALOR  	:= 0
							SZL->(msUnlock())
                   		ENDIF
					ENDIF
           		ENDIF

				dbSelectArea(ALIAS_TMP)
	   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+cDViagens,.F.)
					Reclock(ALIAS_TMP,.F.)
				ELSE
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
					(ALIAS_TMP)->XX_CODIGO := "W"+cDViagens
					(ALIAS_TMP)->XX_DESC   := cDescDCH
				ENDIF
				//cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
				//&cCampo2 += cVALGG
				cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
				&cCampo2 += TMPX2->Z2_VALOR
				(ALIAS_TMP)->(Msunlock())

	   			dbSelectArea(ALIAS_TMP)
	   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
	     			Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->Z2_VALOR
					(ALIAS_TMP)->(Msunlock())
				ENDIF
			ENDIF

			dbSelectArea("TMPX2")
			dbSkip()
		ENDDO
		TMPX2->(dbCloseArea())
		
		
		//Calcula LF Avulso SZ2 - AC e CLA CUSTO BK - produto 29104004 - Data emissão apartir de 01/01/2015
		cQuery1 := "SELECT Z2_CODEMP,Z2_CC,Z2_VALOR,Z2_TIPO,Z2_CC FROM "+RETSQLNAME("SZ2")+" SZ2"
		cQuery1 += " WHERE  D_E_L_E_T_=''  AND Z2_DATAPGT>='20150101' " 
		cQuery1 += " AND Z2_TIPOPES IN ('AC','CLA') AND Z2_STATUS='S'"

		nScan:= 0
		nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })

		IF nScan > 0 
			cQuery1 += " AND Z2_CODEMP='"+SUBSTR(ALLTRIM(aConsorcio[nScan,2]),1,2)+"'" 
			cQuery1 += " AND Z2_CC IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"','"+ALLTRIM(aConsorcio[nScan,7])+"')" 
		ELSE
			cQuery1 += " AND Z2_CODEMP='"+cEmpAnt+"'"
			cQuery1 += " AND Z2_CC='"+ALLTRIM(QTMP->CNF_CONTRA)+"'"
		ENDIF
		
		cQuery1 += " AND SUBSTRING(Z2_DATAPGT,1,6)='"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'"

		TCQUERY cQuery1 NEW ALIAS "TMPX2"

		dbSelectArea("TMPX2")
		dbGoTop()
		DO While !TMPX2->(EOF())

			dbSelectArea(ALIAS_TMP)
   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+cCusBK,.F.)
				Reclock(ALIAS_TMP,.F.)
			ELSE
				Reclock(ALIAS_TMP,.T.)
				(ALIAS_TMP)->XX_CODGCT := IIF( nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
				(ALIAS_TMP)->XX_CODIGO := "W"+cCusBK
				(ALIAS_TMP)->XX_DESC   := cDescCBK
			ENDIF
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			&cCampo2 += TMPX2->Z2_VALOR
			(ALIAS_TMP)->(Msunlock())

   			dbSelectArea(ALIAS_TMP)
   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
     			Reclock(ALIAS_TMP,.F.)
				cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
				&cCampo2 += TMPX2->Z2_VALOR
				(ALIAS_TMP)->(Msunlock())
			ENDIF

			
			dbSelectArea("TMPX2")
			dbSkip()
		ENDDO
		TMPX2->(dbCloseArea())
		
		FOR _IXFUR:= 1 TO LEN(aFurnas)
			IF SUBSTR(ALLTRIM(QTMP->CNF_CONTRA),7,3) == SUBSTR(aFURNAS[_IXFUR],7,3)
				nIncidenci	:= 0
				_IXFUR := LEN(aFurnas)
			ELSE
				nIncidenci	:= U_MVXINCID()
			ENDIF
		NEXT _IXFUR

		/*
		If !lJob
			//IncProc("Consultando Folha Pagamento...")
		Else
			//u_xxLog(cArqLog,"Consultando Folha Pagamento..."+STR(_nI),.T.,"")
		EndIf
		*/

		//*********Folha Pagamento

		nScan	:= 0
		nScan	:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })

		cQuery2 := " SELECT "+CRLF
		cQuery2 += "	bk_senior.bk_senior.R046VER.CodEve,"+CRLF
		cQuery2 += "	COUNT(bk_senior.bk_senior.R046VER.CodEve) AS nCont,"+CRLF
		cQuery2 += "	SUM(bk_senior.bk_senior.R046VER.ValEve) AS valevent,"+CRLF
		cQuery2 += "	(SELECT TOP 1 [Total] FROM [BKIntegraRubi].[dbo].[EVENTOS_ASS_ODONT] " +CRLF
		cQuery2 += "		WHERE "+CRLF
		cQuery2 += "  			[BKIntegraRubi].[dbo].[EVENTOS_ASS_ODONT].NumEmpr = "
		cQuery2 +=   				"'"+IIF(nScan > 0,SUBSTR(ALLTRIM(aConsorcio[nScan,2]),1,2),cEmpAnt)+"'"+CRLF
		cQuery2 += "  			AND CodTab = 1 "+CRLF
		cQuery2 += " 			AND [BKIntegraRubi].[dbo].[EVENTOS_ASS_ODONT].CodEve=bk_senior.bk_senior.R046VER.CodEve "+CRLF
		cQuery2 += " 			AND SUBSTRING(CONVERT(VARCHAR,Validade,112),1,6) <= '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"' "+CRLF
		cQuery2 += "  		ORDER BY [BKIntegraRubi].[dbo].[EVENTOS_ASS_ODONT].Validade DESC) AS VALASSOD "+CRLF
		cQuery2 += " FROM bk_senior.bk_senior.R046VER "+CRLF
		cQuery2 += " INNER JOIN bk_senior.bk_senior.R044cal ON"+CRLF
		cQuery2 += "		bk_senior.bk_senior.R046VER.NumEmp= bk_senior.bk_senior.R044cal.NumEmp" +CRLF
		cQuery2 += "		AND bk_senior.bk_senior.R046VER.CodCal= bk_senior.bk_senior.R044cal.Codcal"+CRLF
		cQuery2 += " INNER JOIN BKIntegraRubi.dbo.CUSTOSIGA ON"
		cQuery2 += " 		bk_senior.bk_senior.R046VER.NumEmp= BKIntegraRubi.dbo.CUSTOSIGA.NumEmp"+CRLF
		cQuery2 += " 		AND bk_senior.bk_senior.R046VER.NumCad = BKIntegraRubi.dbo.CUSTOSIGA.Numcad" +CRLF
 		cQuery2 += " 		AND bk_senior.bk_senior.R046VER.TipCol = BKIntegraRubi.dbo.CUSTOSIGA.TipCol"+CRLF
 		cQuery2 += " 		AND bk_senior.bk_senior.R044cal.Codcal = BKIntegraRubi.dbo.CUSTOSIGA.Codcal"+CRLF

 		//TRATAMENTO ESPECIAL CONTRATO BKDAHER
		IF nScan > 0 
			cQuery2 += " WHERE bk_senior.bk_senior.R046VER.NumEmp='"+SUBSTR(ALLTRIM(aConsorcio[nScan,2]),1,2)+"' "+CRLF
			cQuery2 += " 	AND Tipcal In(11)"+CRLF 
			cQuery2 += " 	AND Sitcal = 'T' "+CRLF
 			cQuery2 += " 	AND PerRef ='"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"01'"+CRLF
			cQuery2 += " 	AND BKIntegraRubi.dbo.CUSTOSIGA.ccSiga  IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"','"+ALLTRIM(aConsorcio[nScan,7])+"')" +CRLF
		ELSE
			cQuery2 += " WHERE bk_senior.bk_senior.R046VER.NumEmp='"+cEmpAnt+"' "+CRLF
			cQuery2 += " 	AND Tipcal In(11) "+CRLF
			cQuery2 += " 	AND Sitcal = 'T' "+CRLF
	 		cQuery2 += " 	AND PerRef ='"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"01'"+CRLF
 			cQuery2 += " 	AND BKIntegraRubi.dbo.CUSTOSIGA.ccSiga = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'"+CRLF
 		ENDIF

		cQuery2 += " GROUP BY bk_senior.bk_senior.R046VER.CodEve"+CRLF

		u_LogTxt("BKGCTR14-FOL.SQL")
	
		TCQUERY cQuery2 NEW ALIAS "TMPX2"

		u_LogTxt("BKGCTR14-FOL.SQL",cQuery2)

		nProventos := 0
		nCusto     := 0
		nXXPLR	   := 0	
		nXXSEMINC  := 0	
		dbSelectArea("TMPX2")
		dbGoTop()
		DO While !TMPX2->(EOF())

			IF "|"+ALLTRIM(STR(TMPX2->CodEve))+"|" $ cProventos
		    	nProventos += TMPX2->valevent
			ENDIF
			IF "|"+ALLTRIM(STR(TMPX2->CodEve))+"|" $ cDescontos
		    	nProventos -= TMPX2->valevent 
			ENDIF
			IF "|"+ALLTRIM(STR(TMPX2->CodEve))+"|" $ cXXPLR
		    	nXXPLR += TMPX2->valevent 
			ENDIF
			IF "|"+ALLTRIM(STR(TMPX2->CodEve))+"|" $ cNINC_Verb
		    	nXXSEMINC += TMPX2->valevent 
			ENDIF

			IF "|"+ALLTRIM(STR(TMPX2->CodEve))+"|" $ cVT_Prov
		   		dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'12',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->valevent
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += TMPX2->valevent  
				ENDIF
			ENDIF

			IF "|"+ALLTRIM(STR(TMPX2->CodEve))+"|"  $ cVT_Verb
		   		dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'13',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->valevent *-1)
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += (TMPX2->valevent *-1)  
				ENDIF
		   		dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'12',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->valevent *-1)
					(ALIAS_TMP)->(Msunlock())
				ENDIF
			ENDIF
			
			IF "|"+ALLTRIM(STR(TMPX2->CodEve))+"|"  $ cVRVA_Verb
		   		dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'15',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->valevent *-1)
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += (TMPX2->valevent *-1)  
				ENDIF
		   		dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'14',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->valevent *-1)
					(ALIAS_TMP)->(Msunlock())
				ENDIF
			ENDIF

			IF "|"+ALLTRIM(STR(TMPX2->CodEve))+"|"  $ cASSM_Prod
				//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - ASSMEDICA
				cVALGG := 0
				IF nDespGeral == 1 .AND. nCompras == 0
					IF !EMPTY(cSeqProj)
           				dbSelectArea("SZL")
						SZL->(dbSetOrder(1))
						IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj+'16',.F.))
							cVALGG := SZL->ZL_VALOR
						ELSE
							DbSelectArea("SZL")
							RecLock("SZL",.T.)
							SZL->ZL_FILIAL 	:= xFilial("SZL")
							SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
							SZL->ZL_TIPO	:= '01'
							SZL->ZL_DATA   	:= dDtProj
							SZL->ZL_SEQ   	:= cSeqProj
							SZL->ZL_CODIGO 	:= '16'
							SZL->ZL_DESC 	:= 'ASSMEDICA'
							SZL->ZL_VALOR  	:= 0
							SZL->(msUnlock())
                   		ENDIF
					ENDIF
           		ENDIF

		   		dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'16',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
				  //	&cCampo2 += cVALGG
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->valevent
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += TMPX2->valevent  
				ENDIF
			ENDIF

			IF "|"+ALLTRIM(STR(TMPX2->CodEve))+"|"  $ cASSM_Verb
		   		dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'17',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->valevent *-1)
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += (TMPX2->valevent *-1)  
				ENDIF
		   		dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'16',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->valevent *-1)
					(ALIAS_TMP)->(Msunlock())
				ENDIF
			ENDIF

			IF "|"+ALLTRIM(STR(TMPX2->CodEve))+"|"  $ cSINO_Prod
				//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - ASS ODONTO
				cVALGG := 0
				IF nDespGeral == 1 .AND. nCompras == 0
					IF !EMPTY(cSeqProj)
           				dbSelectArea("SZL")
						SZL->(dbSetOrder(1))
						IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj+'18',.F.))
							cVALGG := SZL->ZL_VALOR
						ELSE
							DbSelectArea("SZL")
							RecLock("SZL",.T.)
							SZL->ZL_FILIAL 	:= xFilial("SZL")
							SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
							SZL->ZL_TIPO	:= '01'
							SZL->ZL_DATA   	:= dDtProj
							SZL->ZL_SEQ   	:= cSeqProj
							SZL->ZL_CODIGO 	:= '18'
							SZL->ZL_DESC 	:= "SINDICATO (ODONTO)"
							SZL->ZL_VALOR  	:= 0
							SZL->(msUnlock())
                   		ENDIF
					ENDIF
           		ENDIF

		   		dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'18',.F.)
		     		Reclock(ALIAS_TMP,.F.)
				//	cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
				//	&cCampo2 += cVALGG
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->VALASSOD * TMPX2->nCont
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += TMPX2->VALASSOD * TMPX2->nCont 
				ENDIF
			ENDIF

			IF "|"+ALLTRIM(STR(TMPX2->CodEve))+"|"  $ cSINO_Verb
		   		dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'18',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->valevent *-1)
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += (TMPX2->valevent *-1)  
				ENDIF
				// 28/02/20
		   		//dbSelectArea(ALIAS_TMP)
		   		//IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'18',.F.)
		     	//	Reclock(ALIAS_TMP,.F.)
				//	cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
				//	&cCampo2 += (TMPX2->valevent)   //  *-1  28/02/20
				//	(ALIAS_TMP)->(Msunlock())
				//	nCusto += TMPX2->valevent
				//ENDIF
			ENDIF
			
			IF "|"+ALLTRIM(STR(TMPX2->CodEve))+"|"  $ cCCRE_Verb
		   		dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'21',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->valevent *-1)
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += (TMPX2->valevent *-1)  
				ENDIF
		   		dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'20',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->valevent *-1)
					(ALIAS_TMP)->(Msunlock())
				ENDIF
			ENDIF

			dbSelectArea("TMPX2")
			dbSkip()
		ENDDO

   		dbSelectArea(ALIAS_TMP)
   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'09',.F.)
     		Reclock(ALIAS_TMP,.F.)
			
			// Debug
			// If cAnoMes = '202103'
			// 	x:= 0
			// EndIf

			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			&cCampo2 += nProventos
			(ALIAS_TMP)->(Msunlock())
    		nCusto += nProventos  
		ENDIF

		FOR _IXFUR:= 1 TO LEN(aFurnas)
			IF SUBSTR(ALLTRIM(QTMP->CNF_CONTRA),7,3) == SUBSTR(aFURNAS[_IXFUR],7,3)
				nEncargos := U_MVXENCFU()
				_IXFUR	  := LEN(aFurnas)
			ELSE
				nEncargos := U_MVXENCAP()
			ENDIF
		NEXT _IXFUR

   		dbSelectArea(ALIAS_TMP)
   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'10',.F.)
     		Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			&cCampo2 += (nProventos*nEncargos)/100
			(ALIAS_TMP)->(Msunlock())
    		nCusto += (nProventos*nEncargos)/100  
		ENDIF

   		dbSelectArea(ALIAS_TMP)
   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'11',.F.)
     		Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			&cCampo2 += (nProventos*nIncidenci)/100
			(ALIAS_TMP)->(Msunlock())
    		nCusto += (nProventos*nIncidenci)/100 
		ENDIF

   		//PLR
   		dbSelectArea(ALIAS_TMP)
   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'110',.F.)
			cVALGG := 0
			IF nDespGeral == 1 .AND. nCompras == 0
				IF !EMPTY(cSeqProj)
        			dbSelectArea("SZL")
					SZL->(dbSetOrder(1))
					IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj+'110',.F.))
						cVALGG := SZL->ZL_VALOR
					ELSE
						DbSelectArea("SZL")
						RecLock("SZL",.T.)
						SZL->ZL_FILIAL 	:= xFilial("SZL")
						SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
						SZL->ZL_TIPO	:= '01'
						SZL->ZL_DATA   	:= dDtProj
						SZL->ZL_SEQ   	:= cSeqProj
						SZL->ZL_CODIGO 	:= '110'
						SZL->ZL_DESC 	:= 'PLR'
						SZL->ZL_VALOR  	:= 0
						SZL->(msUnlock())
                	ENDIF
				ENDIF
    		ENDIF

     		Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			&cCampo2 += nXXPLR
			(ALIAS_TMP)->(Msunlock())
    		nCusto += nXXPLR
		ENDIF

   		//VERBA SEM INCIDENCIAS
   		dbSelectArea(ALIAS_TMP)
   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'111',.F.)
			cVALGG := 0
			IF nDespGeral == 1 .AND. nCompras == 0
				IF !EMPTY(cSeqProj)
        			dbSelectArea("SZL")
					SZL->(dbSetOrder(1))
					IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj+'111',.F.))
						cVALGG := SZL->ZL_VALOR
					ELSE
						DbSelectArea("SZL")
						RecLock("SZL",.T.)
						SZL->ZL_FILIAL 	:= xFilial("SZL")
						SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
						SZL->ZL_TIPO	:= '01'
						SZL->ZL_DATA   	:= dDtProj
						SZL->ZL_SEQ   	:= cSeqProj
						SZL->ZL_CODIGO 	:= '111'
						SZL->ZL_DESC 	:= 'VERBAS SEM INCIDENCIAS'
						SZL->ZL_VALOR  	:= 0
						SZL->(msUnlock())
                	ENDIF
				ENDIF
    		ENDIF

     		Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			&cCampo2 += nXXSEMINC
			(ALIAS_TMP)->(Msunlock())
    		nCusto += nXXSEMINC
		ENDIF

		// GRAVA VALOR NO CUSTO
		dbSelectArea(ALIAS_TMP)
		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			&cCampo2 += nCusto
			(ALIAS_TMP)->(Msunlock())
		ENDIF

		TMPX2->(dbCloseArea())

		/*
		If !lJob
			//IncProc("Consultando Folha Pagamento - Autonomos...")
		Else
			//u_xxLog(cArqLog,"Consultando Folha Pagamento - Autonomos..."+STR(_nI),.T.,"")
		EndIf
		*/

		//*********Folha Pagamento - Autonomos IPT
		cQuery2 := "SELECT SUM(ValorRPA) AS ValorRPA,SUM(Refeicao) AS Refeicao" 
		cQuery2 += " FROM  webLancamentoIPT.dbo.LancamentoIPT"
		cQuery2 += " WHERE (AC = 0) AND (adiantamento = 0) AND (integrado = 1)" 
		cQuery2 += " AND competencia ='"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'"

		nScan:= 0
		nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })

		IF nScan > 0 
			cQuery2 += " AND codEmpresa='"+SUBSTR(ALLTRIM(aConsorcio[nScan,2]),1,2)+"'"
			cQuery2 += " AND centroCusto IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"','"+ALLTRIM(aConsorcio[nScan,7])+"')" 
		ELSE
			cQuery2 += " AND codEmpresa='"+cEmpAnt+"'"
			cQuery2 += " AND centroCusto='"+ALLTRIM(QTMP->CNF_CONTRA)+"'"
		ENDIF

		     	
		TCQUERY cQuery2 NEW ALIAS "TMPX2"
		dbSelectArea("TMPX2")
		dbGoTop()
		DO While !TMPX2->(EOF())
			
			// GRAVA VALOR NO CUSTO
			dbSelectArea(ALIAS_TMP)
			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
				Reclock(ALIAS_TMP,.F.)
				cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
				&cCampo2 += TMPX2->ValorRPA+((TMPX2->ValorRPA*nEncarIPT)/100)-TMPX2->Refeicao
				(ALIAS_TMP)->(Msunlock())
			ENDIF

	   		dbSelectArea(ALIAS_TMP)
	   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'09',.F.)
	     		Reclock(ALIAS_TMP,.F.)
				cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
				&cCampo2 += TMPX2->ValorRPA
				(ALIAS_TMP)->(Msunlock())
			ENDIF
	
	   		dbSelectArea(ALIAS_TMP)
	   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'10',.F.)
	     		Reclock(ALIAS_TMP,.F.)
				cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
				&cCampo2 += (TMPX2->ValorRPA*nEncarIPT)/100
				(ALIAS_TMP)->(Msunlock())
			ENDIF
	
	   		dbSelectArea(ALIAS_TMP)
	   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'15',.F.)
	     		Reclock(ALIAS_TMP,.F.)
				cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
				&cCampo2 += (TMPX2->Refeicao *-1)
				(ALIAS_TMP)->(Msunlock())
			ENDIF

			dbSelectArea("TMPX2")
			dbSkip()
		ENDDO
		TMPX2->(dbCloseArea())
		
		
        //Calcula vigencia do contrato - PARA GASTOS GERAIS
 		dDataVenc := CTOD("")
		cQuery3 := " SELECT MIN(CNF_DTVENC) AS CNF_INICIO,MAX(CNF_DTVENC) AS CNF_FIM,"
		cQuery3 += " MAX((SUBSTRING(CNF_COMPET,4,4))+SUBSTRING(CNF_COMPET,1,2))+'01' AS MAXCOMPET"+CRLF
		cQuery3 += " FROM "+RETSQLNAME("CNF")+" CNF"
		cQuery3 += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA"
		cQuery3 += " AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = '' WHERE CNF.D_E_L_E_T_=''"
		cQuery3 += " AND CN9_NUMERO = '"+ALLTRIM(QTMP->CNF_CONTRA)+"' AND CN9_SITUAC ='"+cSituac+"'" 

		TCQUERY cQuery3 NEW ALIAS "QTMPX3"
		TCSETFIELD("QTMPX3","CNF_INICIO","D",8,0)	
		TCSETFIELD("QTMPX3","CNF_FIM","D",8,0)	

		dbSelectArea("QTMPX3")
		dDataVenc := QTMPX3->CNF_FIM
		dMaxCompet  := STOD(QTMPX3->MAXCOMPET)
		If dMaxCompet > dDataVenc
			dDataVenc := dMaxCompet
		EndIf
		dDataVenc := LastDay(dDataVenc)
        
        nVContrat := 0
        nVContrat := aScan(aVContrat, {|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA)})
 		IF nVContrat == 0
			aAdd(aVContrat,{ALLTRIM(QTMP->CNF_CONTRA),QTMPX3->CNF_INICIO,QTMPX3->CNF_FIM,0})
        ENDIF
        
		QTMPX3->(Dbclosearea())

		nScan:= 0
		nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })

		/*
		If !lJob
			//IncProc("Consultando gastos gerais..."+aPeriodo[_nI,1]) //STRZERO(_nI,3))
		Else
			//u_xxLog(cArqLog,"Consultando gastos gerais..."+STR(_nI),.T.,"")
		EndIf
		*/

		//*********GASTOS GERAIS
		cQuery2 := "SELECT D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC,SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) AS D1_TOTAL"+CRLF
		cQuery2 += " FROM "+RETSQLNAME("SD1")+" SD1" +CRLF
		cQuery2 += " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D1_COD = B1_COD  AND SB1.D_E_L_E_T_ = '' "+CRLF
		cQuery2 += " WHERE SD1.D_E_L_E_T_ = '' "+CRLF
		If nCompAtual = 1
			cQuery2 += " AND SUBSTRING(D1_DTDIGIT,1,6) <= '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"' "+CRLF
		Else
			cQuery2 += " AND SUBSTRING(D1_DTDIGIT,1,6)  = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"' "+CRLF
		EndIf
		
		cQuery2 += " AND D1_CC = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'" +CRLF
		cQuery2 += " AND D1_FILIAL = '"+xFilial("SD1")+"'"+CRLF
		// 12105 - Alugueis 06/07/2021
		// 19/11/2021 - Contas alteradas de 113 para 121
		//cQuery2 += IIF(nScan > 0," AND SUBSTRING(B1_CONTA,1,3) <> '113' "," AND (SUBSTRING(B1_CONTA,1,1) = '3' OR B1_CONTA in ('29104004') OR SUBSTRING(B1_CONTA,1,5) IN ('12201','12105'))") +CRLF

		If nScan > 0
			cQuery2 += " AND SUBSTRING(B1_CONTA,1,3) <> '113' " +CRLF
			cQuery2 += " AND (SUBSTRING(B1_CONTA,1,3) <> '121' OR SUBSTRING(B1_CONTA,1,5) IN ('12201','12105'))" +CRLF
		Else
			cQuery2 += " AND (SUBSTRING(B1_CONTA,1,1) = '3' OR B1_CONTA IN ('"+cCusBK+"') OR SUBSTRING(B1_CONTA,1,5) IN ('12201','12105'))" +CRLF
		EndIf

		IF cEmpAnt == "01"  .AND. ALLTRIM(QTMP->CNF_CONTRA)=="313000504" // Despesas médicas 
			cQuery2 += " AND D1_FORNECE<>'002918'"+CRLF
		ENDIF 
		IF cEmpAnt == "14"   // Despesas médicas
			cQuery2 += " AND D1_FORNECE<>'000604'"+CRLF
		ENDIF 
		
		//// Para teste de alugueis: 
		//cQuery2 += " AND (D1_COD = '000000000000102' OR D1_COD = '320200301')  "+CRLF // AND D1_FORNECE = '004190'

		IF nCompras == 1
			cQuery2 += " AND D1_PEDIDO <> ''"+CRLF
		ENDIF
		cQuery2 += " GROUP BY D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC"+CRLF

		cQuery2 += " UNION ALL"+CRLF
		cQuery2 += " SELECT D3_FILIAL,MAX(' '),MAX(' '),MAX(' '),MAX(' '),D3_COD,B1_DESC,B1_GRUPO,D3_CC,SUM(D3_CUSTO1) FROM "+RETSQLNAME("SD3")+" SD3"+CRLF
		cQuery2 += " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D3_COD = B1_COD  AND SB1.D_E_L_E_T_ = '' "+CRLF
		cQuery2 += " WHERE SD3.D_E_L_E_T_='' AND D3_TM='5"+cEmpAnt+"' AND SUBSTRING(D3_EMISSAO,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'" 
		cQuery2 += " AND D3_CC = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'"

		// 19/11/2021 - Contas alteradas de 113 para 121
		//cQuery2 += IIF(nScan > 0," AND SUBSTRING(D3_CONTA,1,3) <> '113' "," AND (SUBSTRING(D3_CONTA,1,1) = '3' OR D3_CONTA in ('29104004') OR SUBSTRING(D3_CONTA,1,5) IN ('12201','12105'))") 
		If nScan > 0
			cQuery2 +=  " AND SUBSTRING(D3_CONTA,1,3) <> '113' " +CRLF
			cQuery2 +=  " AND (SUBSTRING(D3_CONTA,1,3) <> '121' OR SUBSTRING(D3_CONTA,1,5) IN ('12201','12105'))" +CRLF
		Else
			cQuery2 += " AND (SUBSTRING(D3_CONTA,1,1) = '3' OR D3_CONTA IN ('"+cCusBK+"') OR SUBSTRING(D3_CONTA,1,5) IN ('12201','12105'))" +CRLF
		EndIf


		cQuery2 += " GROUP BY D3_FILIAL,D3_COD,B1_DESC,B1_GRUPO,D3_CC"+CRLF

		//cQuery2 += " ORDER BY B1_DESC"

		u_LogTxt("BKGCTR14-D1-1.SQL")

		TCQUERY cQuery2 NEW ALIAS "TMPX2"

		u_LogTxt("BKGCTR14-D1-1.SQL",cQuery2)
				
		cOutros := 'S'
		dbSelectArea("TMPX2")
		dbGoTop()

		cLastE2 := "-"
		aAcrDcr := {}

		DO While !TMPX2->(EOF())

			//---> Inicio: Buscar Acrescimos e Decrescimos Financeiros da NFE
			If !Empty(TMPX2->D1_DOC)
				If cLastE2 <> TMPX2->D1_SERIE+TMPX2->D1_DOC+TMPX2->D1_FORNECE+TMPX2->D1_LOJA
					cLastE2 :=  TMPX2->D1_SERIE+TMPX2->D1_DOC+TMPX2->D1_FORNECE+TMPX2->D1_LOJA
					aAcrDcr := u_fAcrDcr()
				Else
					aAcrDcr := u_fAcrDcr(,aAcrDcr)
				EndIf
			Else
				aAcrDcr := {}
			EndIf
			//<--- Fim: Buscar Acrescimos e Decrescimos Financeiros da NFE

			dbSelectArea("TMPX2")

			nIndDesp := 1
			cOutros  := 'S'

			IF "|"+ALLTRIM(TMPX2->D1_COD)+"|" $ cVT_Prod

				//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - VT
				cVALGG := 0
				IF nDespGeral == 1 .AND. nCompras == 0
					IF !EMPTY(cSeqProj)
           				dbSelectArea("SZL")
						SZL->(dbSetOrder(1))
						IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj+'12',.F.))
							cVALGG := SZL->ZL_VALOR
						ELSE
							DbSelectArea("SZL")
							RecLock("SZL",.T.)
							SZL->ZL_FILIAL 	:= xFilial("SZL")
							SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
							SZL->ZL_TIPO	:= '01'
							SZL->ZL_DATA   	:= dDtProj
							SZL->ZL_SEQ   	:= cSeqProj
							SZL->ZL_CODIGO 	:= '12'
							SZL->ZL_DESC 	:= "VT"
							SZL->ZL_VALOR  	:= 0
							SZL->(msUnlock())
                   		ENDIF
					ENDIF
           		ENDIF

				cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'12',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,"N",.T.,"",.F.,nIndDesp)
				cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)
		   		
				/*
				dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'12',.F.)
		     		Reclock(ALIAS_TMP,.F.)
		//			cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
		//			&cCampo2 += cVALGG
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->D1_TOTAL
					(ALIAS_TMP)->(Msunlock())
					cOutros := 'N'
				ENDIF
   				// GRAVA VALOR NO CUSTO (TOTALIZADOR)
   				dbSelectArea(ALIAS_TMP)
   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
     				Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->D1_TOTAL
					(ALIAS_TMP)->(Msunlock())
				ENDIF
				*/

			ENDIF

			IF "|"+ALLTRIM(TMPX2->D1_COD)+"|" $ cVRVA_Prod
				//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - VR/VA
				cVALGG := 0
				IF nDespGeral == 1 .AND. nCompras == 0
					IF !EMPTY(cSeqProj)
           				dbSelectArea("SZL")
						SZL->(dbSetOrder(1))
						IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj+'14',.F.))
							cVALGG := SZL->ZL_VALOR
						ELSE
							DbSelectArea("SZL")
							RecLock("SZL",.T.)
							SZL->ZL_FILIAL 	:= xFilial("SZL")
							SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
							SZL->ZL_TIPO	:= '01'
							SZL->ZL_DATA   	:= dDtProj
							SZL->ZL_SEQ   	:= cSeqProj
							SZL->ZL_CODIGO 	:= '14'
							SZL->ZL_DESC 	:= "VR/VA"
							SZL->ZL_VALOR  	:= 0
							SZL->(msUnlock())
                   		ENDIF
					ENDIF
           		ENDIF

				cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'14',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,"N",.T.,"",.F.,nIndDesp)
				cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)

				/*
		   		dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'14',.F.)
		     		Reclock(ALIAS_TMP,.F.)
			//		cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
		  //		&cCampo2 += cVALGG
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->D1_TOTAL
					(ALIAS_TMP)->(Msunlock())
					cOutros := 'N'
				ENDIF
   				// GRAVA VALOR NO CUSTO
   				dbSelectArea(ALIAS_TMP)
   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
     				Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->D1_TOTAL
					(ALIAS_TMP)->(Msunlock())
				ENDIF
				*/
			ENDIF

			//CECREMEF - DESATIVADO
			/*
			IF "|"+ALLTRIM(TMPX2->D1_COD)+"|" $ cCCRE_Prod
				cVALGG := 0
				IF nDespGeral == 1 .AND. nCompras == 0
					IF !EMPTY(cSeqProj)
           				dbSelectArea("SZL")
						SZL->(dbSetOrder(1))
						IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj+'20',.F.))
							cVALGG := SZL->ZL_VALOR
						ELSE
							DbSelectArea("SZL")
							RecLock("SZL",.T.)
							SZL->ZL_FILIAL 	:= xFilial("SZL")
							SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
							SZL->ZL_TIPO	:= '01'
							SZL->ZL_DATA   	:= dDtProj
							SZL->ZL_SEQ   	:= cSeqProj
							SZL->ZL_CODIGO 	:= '20'
							SZL->ZL_DESC 	:= "CECREMEF/ADV"
							SZL->ZL_VALOR  	:= 0
							SZL->(msUnlock())
                   		ENDIF
					ENDIF
           		ENDIF

				cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'20',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,"N",.T.,"",.F.,nIndDesp)
				cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)

			ENDIF
			*/

			IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cCDPR_Prod .OR.  "|"+ALLTRIM(TMPX2->B1_GRUPO)+"|" $ cCDPR_GRUP;
				 	.OR. U_RatCtrPrd(ALLTRIM(TMPX2->D1_CC),ALLTRIM(TMPX2->D1_COD),aRatCtrPrd)

            	//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - RATEIO
				cVALGG := 0
				IF nDespGeral == 1 .AND. (nCompras == 0 .or. nCompras == 1)  
					IF !EMPTY(cSeqProj)
            			dbSelectArea("SZL")
						SZL->(dbSetOrder(1))
						IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"02"+DTOS(dDtProj)+cSeqProj+"W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC)))),.F.))
							cVALGG := SZL->ZL_VALOR
						ELSE
							DbSelectArea("SZL")
							RecLock("SZL",.T.)
							SZL->ZL_FILIAL 	:= xFilial("SZL")
							SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
							SZL->ZL_TIPO	:= '02'
							SZL->ZL_DATA   	:= dDtProj
							SZL->ZL_SEQ   	:= cSeqProj
							SZL->ZL_CODIGO 	:= "W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
							SZL->ZL_DESC 	:= IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC)))) //ALLTRIM(TMPX2->B1_DESC)
							SZL->ZL_VALOR  	:= 0
							SZL->(msUnlock())
                    	ENDIF
					ENDIF
            	ENDIF

				cOutros := 'N'
				nNumRat := 0
				nValRat := 0
				//Determina quantos Meses utilizar no calculo
				IF nRateia == 1 .OR. U_RatCtrPrd(ALLTRIM(TMPX2->D1_CC),ALLTRIM(TMPX2->D1_COD),aRatCtrPrd)
					nNumRat := 1 + DateDiffMonth( CTOD("01/"+SUBSTR(aPeriodo[_nI,1],1,2)+"/"+SUBSTR(aPeriodo[_nI,1],4,4)) , dDataVenc )
                ELSE
                	nNumRat := 1
                ENDIF
 
				IF nNumRat > 1
					nValRat := TMPX2->D1_TOTAL / nNumRat
			    ELSE
					nValRat := TMPX2->D1_TOTAL
			    ENDIF
			    
			    nParcela := 0 
			    nParcela := (_nI+nNumRat)-1
			    IF nParcela > nPeriodo
			    	nParcela := nPeriodo
			    ENDIF 
                
				IF nCompras == 1

					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+TMPX2->D1_COD,_nI, 0 ,aAcrDcr,cOutros,cOutros,.F.,TMPX2->B1_DESC,.F.,nIndDesp)

					/*
					dbSelectArea(ALIAS_TMP)
   					IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->D1_COD),.F.)
						Reclock(ALIAS_TMP,.F.)
//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
//						&cCampo2 += cVALGG  //(cVALGG/IIF(nNumRat > 1,nNumRat,1))
						(ALIAS_TMP)->(Msunlock())
					ELSE
						Reclock(ALIAS_TMP,.T.)
						(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
						(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->D1_COD)
						(ALIAS_TMP)->XX_DESC   := ALLTRIM(TMPX2->B1_DESC)
//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
//						&cCampo2 += cVALGG //(cVALGG/nNumRat)
						(ALIAS_TMP)->(Msunlock())
					ENDIF
					*/

 				ELSE

					cCodCC := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+cCodCC,_nI, 0 ,aAcrDcr,cOutros,cOutros,.F.,cCodCC,.F.,nIndDesp)
					
					/*
					dbSelectArea(ALIAS_TMP)
   					IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC)))),.F.)
						Reclock(ALIAS_TMP,.F.)
//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
//						&cCampo2 += cVALGG  //(cVALGG/IIF(nNumRat > 1,nNumRat,1))
						(ALIAS_TMP)->(Msunlock())
					ELSE
						Reclock(ALIAS_TMP,.T.)
						(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
						(ALIAS_TMP)->XX_CODIGO := "W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
						(ALIAS_TMP)->XX_DESC   := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
//						&cCampo2 += cVALGG //(cVALGG/nNumRat)
						(ALIAS_TMP)->(Msunlock())
					ENDIF
					*/
                ENDIF
                                  
                // Marcos - 30/05/19
                If nParcela <= 0
                   nParcela := 1
                EndIf
				lPRat := .T.
                
			    FOR XI_ := _nI TO nParcela

					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',XI_,nValRat,aAcrDcr,cOutros,cOutros,lPRat,"",.T.,nIndDesp)

					/*
	   				dbSelectArea(ALIAS_TMP)
	   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
						Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
						&cCampo2 += nValRat
						(ALIAS_TMP)->(Msunlock())
					ELSE
						Reclock(ALIAS_TMP,.T.)
						(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
						(ALIAS_TMP)->XX_CODIGO := '30'
						(ALIAS_TMP)->XX_DESC   := "GASTOS GERAIS"

						cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
						&cCampo2 += nValRat
						(ALIAS_TMP)->(Msunlock())
					ENDIF
                    */

					IF nCompras == 1

						cOutros := Grv14CCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,"W"+TMPX2->D1_COD,XI_,nValRat,aAcrDcr,cOutros,cOutros,lPRat,TMPX2->B1_DESC,.T.,nIndDesp)
						/*
						dbSelectArea(ALIAS_TMP)
	   					IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->D1_CC))+"W"+ALLTRIM(TMPX2->D1_COD),.F.)
							Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
							&cCampo2 += nValRat
							(ALIAS_TMP)->(Msunlock())
						ELSE
							Reclock(ALIAS_TMP,.T.)
							(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(TMPX2->D1_CC))
							(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->B1_DESC)
							(ALIAS_TMP)->XX_DESC   := ALLTRIM(TMPX2->B1_DESC)
							cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
							&cCampo2 += nValRat
							(ALIAS_TMP)->(Msunlock())
						ENDIF
						*/
					ELSE

						cCodCC := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
						cOutros := Grv14CCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,"W"+cCodCC,XI_,nValRat,aAcrDcr,cOutros,cOutros,lPRat,cCodCC,.T.,nIndDesp)
						/*
						dbSelectArea(ALIAS_TMP)
	   					IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->D1_CC))+"W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC)))),.F.)
							Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
							&cCampo2 += nValRat
							(ALIAS_TMP)->(Msunlock())
						ELSE
							Reclock(ALIAS_TMP,.T.)
							(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(TMPX2->D1_CC))
							(ALIAS_TMP)->XX_CODIGO := "W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
							(ALIAS_TMP)->XX_DESC   := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
							cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
							&cCampo2 += nValRat
							(ALIAS_TMP)->(Msunlock())
						ENDIF
						*/
					ENDIF
					lPRat := .F.
				NEXT
            
            ENDIF
            
			IF cOutros == 'S'

				//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA
				cVALGG := 0
				IF nDespGeral == 1
					IF !EMPTY(cSeqProj)
            			dbSelectArea("SZL")
						SZL->(dbSetOrder(1))
						IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"02"+DTOS(dDtProj)+cSeqProj+"W"+ALLTRIM(TMPX2->D1_COD),.F.))
							cVALGG := SZL->ZL_VALOR
						ELSE
							DbSelectArea("SZL")
							RecLock("SZL",.T.)
							SZL->ZL_FILIAL 	:= xFilial("SZL")
							SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
							SZL->ZL_TIPO	:= '02'
							SZL->ZL_DATA   	:= dDtProj
							SZL->ZL_SEQ   	:= cSeqProj
							SZL->ZL_CODIGO 	:= "W"+ALLTRIM(TMPX2->D1_COD)
							SZL->ZL_DESC 	:= ALLTRIM(TMPX2->B1_DESC)
							SZL->ZL_VALOR  	:= 0
							SZL->(msUnlock())
                    	ENDIF
					ENDIF
            	ENDIF

				cOutros := Grv14CCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,"W"+TMPX2->D1_COD,_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,TMPX2->B1_DESC,.F.,nIndDesp)
				cOutros := Grv14CCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'30',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)

				/*
				dbSelectArea(ALIAS_TMP)
	   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->D1_COD),.F.)
					Reclock(ALIAS_TMP,.F.)
				ELSE
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
					(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->D1_COD)
					(ALIAS_TMP)->XX_DESC   := ALLTRIM(TMPX2->B1_DESC)
				ENDIF
//				cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
//				&cCampo2 += cVALGG
				cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
				&cCampo2 += TMPX2->D1_TOTAL
				(ALIAS_TMP)->(Msunlock())

	   			dbSelectArea(ALIAS_TMP)
	   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
	     			Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->D1_TOTAL
					(ALIAS_TMP)->(Msunlock())
				ENDIF
				*/
			ENDIF
			
			dbSelectArea("TMPX2")
			dbSkip()
		ENDDO
		TMPX2->(dbCloseArea())


		//*********GASTOS GERAIS - TRATAMENTO ESPECIAL CONSORCIOS
		nScan:= 0
		nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })

		IF nScan > 0 
			cQuery2 := "SELECT D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC,SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) AS D1_TOTAL"+CRLF
			cQuery2 += " FROM SD1"+ALLTRIM(aConsorcio[nScan,2])+" SD1" +CRLF
			//cQuery2 += " INNER JOIN SA2"+ALLTRIM(aConsorcio[nScan,2])+" SA2 ON D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ''" 
			cQuery2 += " INNER JOIN SB1"+ALLTRIM(aConsorcio[nScan,2])+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D1_COD = B1_COD  AND SB1.D_E_L_E_T_ = ''"+CRLF
			//cQuery2 += " INNER JOIN CTT"+ALLTRIM(aConsorcio[nScan,2])+" CTT ON D1_FILIAL = CTT_FILIAL AND D1_CC = CTT_CUSTO AND CTT.D_E_L_E_T_ = ''"
			cQuery2 += " WHERE SD1.D_E_L_E_T_ = '' "+CRLF
			If nCompAtual == 1
				cQuery2 += " AND SUBSTRING(D1_DTDIGIT,1,6) <= '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"' AND SD1.D_E_L_E_T_ = '' "+CRLF
			Else
				cQuery2 += " AND SUBSTRING(D1_DTDIGIT,1,6)  = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"' AND SD1.D_E_L_E_T_ = '' "+CRLF
			EndIf
			//cQuery2 += " AND D1_CC = '000000001'"
			cQuery2 += " AND D1_FILIAL = '"+xFilial("SD1")+"'"+CRLF
			IF cEmpAnt == "01" .AND. ALLTRIM(QTMP->CNF_CONTRA)=="313000504" // Despesas médicas 
				cQuery2 += " AND D1_FORNECE<>'002918'"
			ENDIF 
			IF cEmpAnt == "14"   // Despesas médicas
				cQuery2 += " AND D1_FORNECE<>'000604'"
			ENDIF 
			IF ALLTRIM(aConsorcio[nScan,2]) == "140"
				cQuery2 += " AND D1_CC IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"')" 
			ELSEIF ALLTRIM(aConsorcio[nScan,2]) == "150"
				cQuery2 += " AND D1_CC BETWEEN '000000000' AND '999999999'" +CRLF
            ELSE
				cQuery2 += " AND D1_CC IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"','"+ALLTRIM(aConsorcio[nScan,7])+"')" 
			ENDIF
			cQuery2 += " AND SUBSTRING(B1_CONTA,1,1) <> '2' AND SUBSTRING(B1_CONTA,1,3) <> '113' "
			// 19/11/2021 - Contas alteradas de 113 para 121
			cQuery2 += " AND (SUBSTRING(B1_CONTA,1,3) <> '121' OR SUBSTRING(B1_CONTA,1,5) IN ('12201','12105'))" +CRLF
			IF nCompras == 1
				cQuery2 += " AND D1_PEDIDO <> ''"
			ENDIF 
			cQuery2 += " GROUP BY D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC"
			//cQuery2 += " ORDER BY B1_DESC"
	        
			TCQUERY cQuery2 NEW ALIAS "TMPX2"
			cOutros := 'S'
			dbSelectArea("TMPX2")
			dbGoTop()

			cLastE2 := "-"
			aAcrDcr := {}

			DO While !TMPX2->(EOF()) 

				//---> Inicio: Buscar Acrescimos e Decrescimos Financeiros da NFE
				If !Empty(TMPX2->D1_DOC)
					If cLastE2 <> TMPX2->D1_SERIE+TMPX2->D1_DOC+TMPX2->D1_FORNECE+TMPX2->D1_LOJA
						cLastE2 := TMPX2->D1_SERIE+TMPX2->D1_DOC+TMPX2->D1_FORNECE+TMPX2->D1_LOJA
						aAcrDcr := u_fAcrDcr(ALLTRIM(aConsorcio[nScan,2]))
					Else
						aAcrDcr := u_fAcrDcr(ALLTRIM(aConsorcio[nScan,2]),aAcrDcr)
					EndIf
				Else
					aAcrDcr := {}
				EndIf
				//<--- Fim: Buscar Acrescimos e Decrescimos Financeiros da NFE
				
				dbSelectArea("TMPX2")

				cOutros := 'S'
				nIndDesp := IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),VAL(aConsorcio[nScan,5]),1) 
				nAuxVl   := TMPX2->D1_TOTAL/nIndDesp

				IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cVT_Prod

					//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - VT
					cVALGG := 0
					IF nDespGeral == 1 .AND. nCompras == 0
						IF !EMPTY(cSeqProj)
           					dbSelectArea("SZL")
							SZL->(dbSetOrder(1))
							IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj+'12',.F.))
								cVALGG := SZL->ZL_VALOR
							ELSE
								DbSelectArea("SZL")
								RecLock("SZL",.T.)
								SZL->ZL_FILIAL 	:= xFilial("SZL")
								SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
								SZL->ZL_TIPO	:= '01'
								SZL->ZL_DATA   	:= dDtProj
								SZL->ZL_SEQ   	:= cSeqProj
								SZL->ZL_CODIGO 	:= '12'
								SZL->ZL_DESC 	:= "VT"
								SZL->ZL_VALOR  	:= 0
								SZL->(msUnlock())
                   			ENDIF
						ENDIF
           			ENDIF

					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'12',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"",.F.,nIndDesp)
					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)

					/*
			   		dbSelectArea(ALIAS_TMP)
			   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'12',.F.)
			     		Reclock(ALIAS_TMP,.F.)
//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
//						&cCampo2 += cVALGG  //IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),cVALGG/VAL(aConsorcio[nScan,5]),cVALGG)
						cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
						&cCampo2 +=  IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
						(ALIAS_TMP)->(Msunlock())
						cOutros := 'N'
					ENDIF
	   				// GRAVA VALOR NO CUSTO
	   				dbSelectArea(ALIAS_TMP)
	   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
	     				Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
						&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
						(ALIAS_TMP)->(Msunlock())
					ENDIF
					*/
				ENDIF
	
				IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cVRVA_Prod
					//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - VRVA
					cVALGG := 0
					IF nDespGeral == 1 .AND. nCompras == 0
						IF !EMPTY(cSeqProj)
           					dbSelectArea("SZL")
							SZL->(dbSetOrder(1))
							IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj+'14',.F.))
								cVALGG := SZL->ZL_VALOR
							ELSE
								DbSelectArea("SZL")
								RecLock("SZL",.T.)
								SZL->ZL_FILIAL 	:= xFilial("SZL")
								SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
								SZL->ZL_TIPO	:= '01'
								SZL->ZL_DATA   	:= dDtProj
								SZL->ZL_SEQ   	:= cSeqProj
								SZL->ZL_CODIGO 	:= '14'
								SZL->ZL_DESC 	:= "VR/VA"
								SZL->ZL_VALOR  	:= 0
								SZL->(msUnlock())
                   			ENDIF
						ENDIF
           			ENDIF

					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'14',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"",.F.,nIndDesp)
					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)

					/*
			   		dbSelectArea(ALIAS_TMP)
			   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'14',.F.)
			     		Reclock(ALIAS_TMP,.F.)
//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
//						&cCampo2 += cVALGG //IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),cVALGG/VAL(aConsorcio[nScan,5]),cVALGG)

						cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
						&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
						(ALIAS_TMP)->(Msunlock())
						cOutros := 'N'
					ENDIF
	   				// GRAVA VALOR NO CUSTO
	   				dbSelectArea(ALIAS_TMP)
	   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
	     				Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
						&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
						(ALIAS_TMP)->(Msunlock())
					ENDIF
					*/
				ENDIF

                //CECREMEF - DESATIVADO
				/*
				IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cCCRE_Prod
					cVALGG := 0
					IF nDespGeral == 1 .AND. nCompras == 0
						IF !EMPTY(cSeqProj)
           					dbSelectArea("SZL")
							SZL->(dbSetOrder(1))
							IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj+'20',.F.))
								cVALGG := SZL->ZL_VALOR
							ELSE
								DbSelectArea("SZL")
								RecLock("SZL",.T.)
								SZL->ZL_FILIAL 	:= xFilial("SZL")
								SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
								SZL->ZL_TIPO	:= '01'
								SZL->ZL_DATA   	:= dDtProj
								SZL->ZL_SEQ   	:= cSeqProj
								SZL->ZL_CODIGO 	:= '20'
								SZL->ZL_DESC 	:= "CECREMEF/ADV"
								SZL->ZL_VALOR  	:= 0
								SZL->(msUnlock())
                   			ENDIF
						ENDIF
           			ENDIF

					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'20',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"",.F.,nIndDesp)
					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)
				ENDIF
				*/

				IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cCDPR_Prod .OR. "|"+ALLTRIM(TMPX2->B1_GRUPO)+"|" $ cCDPR_GRUP;
				 	.OR. U_RatCtrPrd(ALLTRIM(TMPX2->D1_CC),ALLTRIM(TMPX2->D1_COD),aRatCtrPrd)
            		//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - RATEIO
					cVALGG := 0
					IF nDespGeral == 1 .AND. (nCompras == 0 .OR. nCompras == 1)
						IF !EMPTY(cSeqProj)
            				dbSelectArea("SZL")
							SZL->(dbSetOrder(1))
							IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"02"+DTOS(dDtProj)+cSeqProj+"W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC)))),.F.))
								cVALGG := SZL->ZL_VALOR
							ELSE
								DbSelectArea("SZL")
								RecLock("SZL",.T.)
								SZL->ZL_FILIAL 	:= xFilial("SZL")
								SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
								SZL->ZL_TIPO	:= '02'
								SZL->ZL_DATA   	:= dDtProj
								SZL->ZL_SEQ   	:= cSeqProj
								SZL->ZL_CODIGO 	:= "W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
								SZL->ZL_DESC 	:= IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
								SZL->ZL_VALOR  	:= 0
								SZL->(msUnlock())
                    		ENDIF
						ENDIF
            		ENDIF
					
					cOutros := 'N'
					nNumRat := 0
					nValRat := 0
					//Determina quantos Meses utilizar no calculo
	   				IF nRateia == 1	.OR. U_RatCtrPrd(ALLTRIM(TMPX2->D1_CC),ALLTRIM(TMPX2->D1_COD),aRatCtrPrd)
						nNumRat := 1 + DateDiffMonth( CTOD("01/"+SUBSTR(aPeriodo[_nI,1],1,2)+"/"+SUBSTR(aPeriodo[_nI,1],4,4)) , dDataVenc )
                    ELSE
                    	nNumRat := 1
					ENDIF

					IF nNumRat > 1
						nValRat := TMPX2->D1_TOTAL / nNumRat 
				    ELSE
						nValRat := TMPX2->D1_TOTAL
				    ENDIF

				    nParcela := 0 
				    nParcela := (_nI+nNumRat)-1
				    IF nParcela > nPeriodo
				    	nParcela := nPeriodo
				    ENDIF 

					IF nCompras == 1

						cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+TMPX2->D1_COD,_nI, 0 ,aAcrDcr,cOutros,cOutros,.F.,TMPX2->B1_DESC,.F.,nIndDesp)

						/*
						dbSelectArea(ALIAS_TMP)
		   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->D1_COD),.F.)
							Reclock(ALIAS_TMP,.F.)
	//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
	//						&cCampo2 += cVALGG //IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),(cVALGG/IIF(nNumRat > 1,nNumRat,1))/VAL(aConsorcio[nScan,5]),(cVALGG/IIF(nNumRat > 1,nNumRat,1)))
							(ALIAS_TMP)->(Msunlock())
						ELSE
							Reclock(ALIAS_TMP,.T.)
							(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
							(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->D1_COD)
							(ALIAS_TMP)->XX_DESC   := ALLTRIM(TMPX2->B1_DESC)
	//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
	//						&cCampo2 += cVALGG //IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),(cVALGG/IIF(nNumRat > 1,nNumRat,1))/VAL(aConsorcio[nScan,5]),(cVALGG/IIF(nNumRat > 1,nNumRat,1)))
							(ALIAS_TMP)->(Msunlock())
						ENDIF	
						*/				
					ELSE


						cCodCC := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
						cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+cCodCC,_nI, 0 ,aAcrDcr,cOutros,cOutros,.F.,cCodCC,.F.,nIndDesp)

						/*
						dbSelectArea(ALIAS_TMP)
		   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC)))),.F.)
							Reclock(ALIAS_TMP,.F.)
	//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
	//						&cCampo2 += cVALGG //IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),(cVALGG/IIF(nNumRat > 1,nNumRat,1))/VAL(aConsorcio[nScan,5]),(cVALGG/IIF(nNumRat > 1,nNumRat,1)))
							(ALIAS_TMP)->(Msunlock())
						ELSE
							Reclock(ALIAS_TMP,.T.)
							(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
							(ALIAS_TMP)->XX_CODIGO := "W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
							(ALIAS_TMP)->XX_DESC   := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
	//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
	//						&cCampo2 += cVALGG //IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),(cVALGG/IIF(nNumRat > 1,nNumRat,1))/VAL(aConsorcio[nScan,5]),(cVALGG/IIF(nNumRat > 1,nNumRat,1)))
							(ALIAS_TMP)->(Msunlock())
						ENDIF
						*/
					ENDIF

	                // Marcos - 30/05/19
	                If nParcela <= 0
	                   nParcela := 1
	                EndIf
					lPRat := .T.
					nIndDesp := IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),VAL(aConsorcio[nScan,5]),1)
					nAuxVl   := nValRat/nIndDesp

				    FOR XI_ := _nI TO nParcela

						cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,"",.T.,nIndDesp)

		   				/*
						dbSelectArea(ALIAS_TMP)
		   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
							Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
							&cCampo2 +=  IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
							(ALIAS_TMP)->(Msunlock())
						ELSE
							Reclock(ALIAS_TMP,.T.)
							(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
							(ALIAS_TMP)->XX_CODIGO := '30'
							(ALIAS_TMP)->XX_DESC   := "GASTOS GERAIS"
							cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
							(ALIAS_TMP)->(Msunlock())
						ENDIF
						*/

						IF nCompras == 1

							cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+TMPX2->D1_COD,XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,TMPX2->B1_DESC,.T.,nIndDesp)
							/*
							dbSelectArea(ALIAS_TMP)
			   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->D1_COD),.F.)
								Reclock(ALIAS_TMP,.F.)
								cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
								&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
								(ALIAS_TMP)->(Msunlock())
							ELSE
								Reclock(ALIAS_TMP,.T.)
								(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
								(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->D1_COD)
								(ALIAS_TMP)->XX_DESC   := ALLTRIM(TMPX2->B1_DESC)
								cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
								&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
								(ALIAS_TMP)->(Msunlock())
							ENDIF
							*/
						ELSE
							cCodCC := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
							cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+cCodCC,XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,cCodCC,.T.,nIndDesp)

							/*
							dbSelectArea(ALIAS_TMP)
			   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC)))),.F.)
								Reclock(ALIAS_TMP,.F.)
								cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
								&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
								(ALIAS_TMP)->(Msunlock())
							ELSE
								Reclock(ALIAS_TMP,.T.)
								(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
								(ALIAS_TMP)->XX_CODIGO := "W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
								(ALIAS_TMP)->XX_DESC   := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
								cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
								&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
								(ALIAS_TMP)->(Msunlock())
							ENDIF
							*/
						ENDIF
						lPRat := .F.
					NEXT

	            ENDIF
				IF cOutros == 'S'
					//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA
					cVALGG := 0
					IF nDespGeral == 1 .AND. (nCompras == 0 .OR. nCompras == 1)
						IF !EMPTY(cSeqProj)
            				dbSelectArea("SZL")
							SZL->(dbSetOrder(1))
							IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"02"+DTOS(dDtProj)+cSeqProj+"W"+ALLTRIM(TMPX2->D1_COD),.F.))
								cVALGG := SZL->ZL_VALOR
							ELSE
								DbSelectArea("SZL")
								RecLock("SZL",.T.)
								SZL->ZL_FILIAL 	:= xFilial("SZL")
								SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
								SZL->ZL_TIPO	:= '02'
								SZL->ZL_DATA   	:= dDtProj
								SZL->ZL_SEQ   	:= cSeqProj
								SZL->ZL_CODIGO 	:= "W"+ALLTRIM(TMPX2->D1_COD)
								SZL->ZL_DESC 	:= ALLTRIM(TMPX2->B1_DESC)
								SZL->ZL_VALOR  	:= 0
								SZL->(msUnlock())
                    		ENDIF
						ENDIF
            		ENDIF

					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+TMPX2->D1_COD,_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,TMPX2->B1_DESC,.F.,nIndDesp)
					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)
					/*
					dbSelectArea(ALIAS_TMP)
		   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->D1_COD),.F.)
						Reclock(ALIAS_TMP,.F.)
					ELSE
						Reclock(ALIAS_TMP,.T.)
						(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
						(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->D1_COD)
						(ALIAS_TMP)->XX_DESC   := ALLTRIM(TMPX2->B1_DESC)
					ENDIF
//					cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
//					&cCampo2 += cVALGG //IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),cVALGG /VAL(aConsorcio[nScan,5]),cVALGG )
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL /VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL )
					(ALIAS_TMP)->(Msunlock())
	
		   			dbSelectArea(ALIAS_TMP)
		   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
		     			Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
						&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL /VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL )
						(ALIAS_TMP)->(Msunlock())
					ENDIF
					*/

				ENDIF
				
				dbSelectArea("TMPX2")
				dbSkip()
			ENDDO
			TMPX2->(dbCloseArea())

			cQuery2 := "SELECT E5_CREDITO,E5_DEBITO,CT1_DESC01,E5_VALOR,E5_RECPAG,E5_CCC,E5_CCD,E5_VENCTO"
			cQuery2 += " FROM SE5"+ALLTRIM(aConsorcio[nScan,2])+" SE5" 
			cQuery2 += " LEFT JOIN CT1"+ALLTRIM(aConsorcio[nScan,2])+" CT1 ON (CT1_CONTA=E5_DEBITO OR CT1_CONTA=E5_CREDITO) AND CT1.D_E_L_E_T_=''"
			cQuery2 += " WHERE SE5.D_E_L_E_T_='' AND (SUBSTRING(E5_DEBITO,1,1)='3' OR SUBSTRING(E5_CREDITO,1,1)='3' )  AND E5_SITUACA<>'C'"
			cQuery2 += " AND SUBSTRING(E5_VENCTO,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'"
   			cQuery2 += " AND E5_FILIAL = '"+xFilial("SE5")+"'"+CRLF

			u_LogTxt("BKGCTR14-E5-1.SQL")
			TCQUERY cQuery2 NEW ALIAS "TMPX2"
			u_LogTxt("BKGCTR14-E5-1-.SQL",cQuery2)

			dbSelectArea("TMPX2")
			dbGoTop()
			DO While !TMPX2->(EOF()) 
				//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - MOVIMENTO BANCARIO
				cVALGG := 0
				IF nDespGeral == 1 .AND. nCompras == 0
					IF !EMPTY(cSeqProj)
           				dbSelectArea("SZL")
						SZL->(dbSetOrder(1))
						IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"02"+DTOS(dDtProj)+cSeqProj+"W"+ALLTRIM(TMPX2->CT1_DESC01),.F.))
							cVALGG := SZL->ZL_VALOR
						ELSE
							DbSelectArea("SZL")
							RecLock("SZL",.T.)
							SZL->ZL_FILIAL 	:= xFilial("SZL")
							SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
							SZL->ZL_TIPO	:= '02'
							SZL->ZL_DATA   	:= dDtProj
							SZL->ZL_SEQ   	:= cSeqProj
							SZL->ZL_CODIGO 	:= "W"+ALLTRIM(TMPX2->CT1_DESC01)
							SZL->ZL_DESC 	:= ALLTRIM("*"+TMPX2->CT1_DESC01)
							SZL->ZL_VALOR  	:= 0
							SZL->(msUnlock())
                   		ENDIF
					ENDIF
           		ENDIF

				dbSelectArea(ALIAS_TMP)
	   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->CT1_DESC01),.F.)
					Reclock(ALIAS_TMP,.F.)
				ELSE
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
					(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->CT1_DESC01)
					(ALIAS_TMP)->XX_DESC   := ALLTRIM("*"+TMPX2->CT1_DESC01)
				ENDIF
//				cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
//				&cCampo2 += cVALGG //(cVALGG /VAL(aConsorcio[nScan,5]))
				cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
				&cCampo2 += (TMPX2->E5_VALOR /VAL(aConsorcio[nScan,5])) * IIF(TMPX2->E5_RECPAG=='R',-1,1)
				(ALIAS_TMP)->(Msunlock())

	   			dbSelectArea(ALIAS_TMP)
	   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
	     			Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->E5_VALOR /VAL(aConsorcio[nScan,5])) * IIF(TMPX2->E5_RECPAG=='R',-1,1)
					(ALIAS_TMP)->(Msunlock())
				ENDIF

				TMPX2->(dbSkip())
			ENDDO
			TMPX2->(dbCloseArea()) 

// 12/02/19 - Inicio inclusão de despesas BK na Balsa Nova
	  		IF LEN(aConsorcio[nScan]) > 7

				cQuery2 := "SELECT DISTINCT D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC,SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) AS D1_TOTAL"
				cQuery2 += " FROM SD1"+ALLTRIM(aConsorcio[nScan,8])+" SD1" 
				cQuery2 += " INNER JOIN SA2"+ALLTRIM(aConsorcio[nScan,8])+" SA2 ON D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ''" 
				cQuery2 += " INNER JOIN SB1"+ALLTRIM(aConsorcio[nScan,8])+" SB1 ON D1_COD = B1_COD  AND SB1.D_E_L_E_T_ = ''"                                         
				cQuery2 += " INNER JOIN CTT"+ALLTRIM(aConsorcio[nScan,8])+" CTT ON D1_FILIAL = CTT_FILIAL AND D1_CC = CTT_CUSTO AND CTT.D_E_L_E_T_ = ''"
				cQuery2 += " WHERE SD1.D_E_L_E_T_ = '' "+CRLF
				If nCompAtual = 1
					cQuery2 += " AND SUBSTRING(D1_DTDIGIT,1,6) <= '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"' "+CRLF
				Else
					cQuery2 += " AND SUBSTRING(D1_DTDIGIT,1,6)  = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"' "+CRLF
				EndIf
				cQuery2 += " AND SUBSTRING(B1_CONTA,1,1) <> '2' AND SUBSTRING(B1_CONTA,1,3) <> '113' "
				// 19/11/2021 - Contas alteradas de 113 para 121
				cQuery2 += " AND (SUBSTRING(B1_CONTA,1,3) <> '121' OR SUBSTRING(B1_CONTA,1,5) IN ('12201','12105'))" +CRLF

				IF cEmpAnt == "01"  .AND. ALLTRIM(QTMP->CNF_CONTRA)=="313000504" // Despesas médicas 
					cQuery2 += " AND D1_FORNECE<>'002918'"
				ENDIF 
				IF cEmpAnt == "14"   // Despesas médicas
					cQuery2 += " AND D1_FORNECE<>'000604'"
				ENDIF 
				IF nCompras == 1
					cQuery2 += " AND D1_PEDIDO <> ''"
				ENDIF 
				cQuery2 += " AND D1_CC = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'"
				cQuery2 += " AND D1_FILIAL = '"+xFilial("SD1")+"'"+CRLF
				cQuery2 += " GROUP BY  D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC"
				//cQuery2 += " ORDER BY B1_DESC"
		        
				u_LogTxt("BKGCTR14-D1-2.SQL") 

				TCQUERY cQuery2 NEW ALIAS "TMPX2"

				u_LogTxt("BKGCTR14-D1-2.SQL",cQuery2) 

				cOutros := 'S'
				dbSelectArea("TMPX2")
				dbGoTop()
				DO While !TMPX2->(EOF()) 

					//---> Inicio: Buscar Acrescimos e Decrescimos Financeiros da NFE
					If !Empty(TMPX2->D1_DOC)
						If cLastE2 <> TMPX2->D1_SERIE+TMPX2->D1_DOC+TMPX2->D1_FORNECE+TMPX2->D1_LOJA
							cLastE2 := TMPX2->D1_SERIE+TMPX2->D1_DOC+TMPX2->D1_FORNECE+TMPX2->D1_LOJA
							aAcrDcr := u_fAcrDcr(ALLTRIM(aConsorcio[nScan,8]))
						Else
							aAcrDcr := u_fAcrDcr(ALLTRIM(aConsorcio[nScan,8]),aAcrDcr)
						EndIf
					Else
						aAcrDcr := {}
					EndIf
					//<--- Fim: Buscar Acrescimos e Decrescimos Financeiros da NFE

					cOutros := 'S'
					IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cVT_Prod
	
						//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - VT
						cVALGG := 0
						IF nDespGeral == 1 .AND. nCompras == 0
							IF !EMPTY(cSeqProj)
	           					dbSelectArea("SZL")
								SZL->(dbSetOrder(1))
								IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj+'12',.F.))
									cVALGG := SZL->ZL_VALOR
								ELSE
									DbSelectArea("SZL")
									RecLock("SZL",.T.)
									SZL->ZL_FILIAL 	:= xFilial("SZL")
									SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
									SZL->ZL_TIPO	:= '01'
									SZL->ZL_DATA   	:= dDtProj
									SZL->ZL_SEQ   	:= cSeqProj
									SZL->ZL_CODIGO 	:= '12'
									SZL->ZL_DESC 	:= "VT"
									SZL->ZL_VALOR  	:= 0
									SZL->(msUnlock())
	                   			ENDIF
							ENDIF
	           			ENDIF
	
				   		dbSelectArea(ALIAS_TMP)
				   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'12',.F.)
				     		Reclock(ALIAS_TMP,.F.)
	//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
	//						&cCampo2 += cVALGG  //IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),cVALGG/VAL(aConsorcio[nScan,5]),cVALGG)
							cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
							&cCampo2 +=  IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
							(ALIAS_TMP)->(Msunlock())
							cOutros := 'N'
						ENDIF
		   				// GRAVA VALOR NO CUSTO
		   				dbSelectArea(ALIAS_TMP)
		   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
		     				Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
							(ALIAS_TMP)->(Msunlock())
						ENDIF
						
					ENDIF
		
					IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cVRVA_Prod
						//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - VRVA
						cVALGG := 0
						IF nDespGeral == 1 .AND. nCompras == 0
							IF !EMPTY(cSeqProj)
	           					dbSelectArea("SZL")
								SZL->(dbSetOrder(1))
								IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj+'14',.F.))
									cVALGG := SZL->ZL_VALOR
								ELSE
									DbSelectArea("SZL")
									RecLock("SZL",.T.)
									SZL->ZL_FILIAL 	:= xFilial("SZL")
									SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
									SZL->ZL_TIPO	:= '01'
									SZL->ZL_DATA   	:= dDtProj
									SZL->ZL_SEQ   	:= cSeqProj
									SZL->ZL_CODIGO 	:= '14'
									SZL->ZL_DESC 	:= "VR/VA"
									SZL->ZL_VALOR  	:= 0
									SZL->(msUnlock())
	                   			ENDIF
							ENDIF
	           			ENDIF
	
				   		dbSelectArea(ALIAS_TMP)
				   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'14',.F.)
				     		Reclock(ALIAS_TMP,.F.)
	//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
	//						&cCampo2 += cVALGG //IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),cVALGG/VAL(aConsorcio[nScan,5]),cVALGG)
	
							cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
							(ALIAS_TMP)->(Msunlock())
							cOutros := 'N'
						ENDIF
		   				// GRAVA VALOR NO CUSTO
		   				dbSelectArea(ALIAS_TMP)
		   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
		     				Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
							(ALIAS_TMP)->(Msunlock())
						ENDIF
					ENDIF
	                //CECREMEF - DESATIVADO
					/*
					IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cCCRE_Prod
						cVALGG := 0
						IF nDespGeral == 1 .AND. nCompras == 0
							IF !EMPTY(cSeqProj)
	           					dbSelectArea("SZL")
								SZL->(dbSetOrder(1))
								IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj+'20',.F.))
									cVALGG := SZL->ZL_VALOR
								ELSE
									DbSelectArea("SZL")
									RecLock("SZL",.T.)
									SZL->ZL_FILIAL 	:= xFilial("SZL")
									SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
									SZL->ZL_TIPO	:= '01'
									SZL->ZL_DATA   	:= dDtProj
									SZL->ZL_SEQ   	:= cSeqProj
									SZL->ZL_CODIGO 	:= '20'
									SZL->ZL_DESC 	:= "CECREMEF/ADV"
									SZL->ZL_VALOR  	:= 0
									SZL->(msUnlock())
	                   			ENDIF
							ENDIF
	           			ENDIF
	
				   		dbSelectArea(ALIAS_TMP)
				   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'14',.F.)
				     		Reclock(ALIAS_TMP,.F.)
	//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
	//						&cCampo2 += cVALGG //IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),cVALGG/VAL(aConsorcio[nScan,5]),cVALGG)
	
							cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
							(ALIAS_TMP)->(Msunlock())
							cOutros := 'N'
						ENDIF
		   				// GRAVA VALOR NO CUSTO
		   				dbSelectArea(ALIAS_TMP)
		   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
		     				Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
							(ALIAS_TMP)->(Msunlock())
						ENDIF
					ENDIF
					*/

					IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cCDPR_Prod .OR.  "|"+ALLTRIM(TMPX2->B1_GRUPO)+"|" $ cCDPR_GRUP;
					 	.OR. U_RatCtrPrd(ALLTRIM(TMPX2->D1_CC),ALLTRIM(TMPX2->D1_COD),aRatCtrPrd)
	            		//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - RATEIO
						cVALGG := 0
						IF nDespGeral == 1 .AND. (nCompras == 0 .OR. nCompras == 1)
							IF !EMPTY(cSeqProj)
	            				dbSelectArea("SZL")
								SZL->(dbSetOrder(1))
								IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"02"+DTOS(dDtProj)+cSeqProj+"W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC)))),.F.))
									cVALGG := SZL->ZL_VALOR
								ELSE
									DbSelectArea("SZL")
									RecLock("SZL",.T.)
									SZL->ZL_FILIAL 	:= xFilial("SZL")
									SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
									SZL->ZL_TIPO	:= '02'
									SZL->ZL_DATA   	:= dDtProj
									SZL->ZL_SEQ   	:= cSeqProj
									SZL->ZL_CODIGO 	:= "W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
									SZL->ZL_DESC 	:= IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
									SZL->ZL_VALOR  	:= 0
									SZL->(msUnlock())
	                    		ENDIF
							ENDIF
	            		ENDIF
						
	
						cOutros := 'N'
						nNumRat := 0
						nValRat := 0
						//Determina quantos Meses utilizar no calculo
		   				IF nRateia == 1 .OR. U_RatCtrPrd(ALLTRIM(TMPX2->D1_CC),ALLTRIM(TMPX2->D1_COD),aRatCtrPrd)
							nNumRat := 1 + DateDiffMonth( CTOD("01/"+SUBSTR(aPeriodo[_nI,1],1,2)+"/"+SUBSTR(aPeriodo[_nI,1],4,4)) , dDataVenc )
	                    ELSE
	                    	nNumRat := 1
						ENDIF
	
						IF nNumRat > 1
							nValRat := TMPX2->D1_TOTAL / nNumRat 
					    ELSE
							nValRat := TMPX2->D1_TOTAL
					    ENDIF
	
					    nParcela := 0 
					    nParcela := (_nI+nNumRat)-1
					    IF nParcela > nPeriodo
					    	nParcela := nPeriodo
					    ENDIF 
	
						IF nCompras == 1
							dbSelectArea(ALIAS_TMP)
			   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->D1_COD),.F.)
								Reclock(ALIAS_TMP,.F.)
		//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
		//						&cCampo2 += cVALGG //IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),(cVALGG/IIF(nNumRat > 1,nNumRat,1))/VAL(aConsorcio[nScan,5]),(cVALGG/IIF(nNumRat > 1,nNumRat,1)))
								(ALIAS_TMP)->(Msunlock())
							ELSE
								Reclock(ALIAS_TMP,.T.)
								(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
								(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->D1_COD)
								(ALIAS_TMP)->XX_DESC   := ALLTRIM(TMPX2->B1_DESC)
		//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
		//						&cCampo2 += cVALGG //IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),(cVALGG/IIF(nNumRat > 1,nNumRat,1))/VAL(aConsorcio[nScan,5]),(cVALGG/IIF(nNumRat > 1,nNumRat,1)))
								(ALIAS_TMP)->(Msunlock())
							ENDIF					
						ELSE
							dbSelectArea(ALIAS_TMP)
			   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC)))),.F.)
								Reclock(ALIAS_TMP,.F.)
		//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
		//						&cCampo2 += cVALGG //IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),(cVALGG/IIF(nNumRat > 1,nNumRat,1))/VAL(aConsorcio[nScan,5]),(cVALGG/IIF(nNumRat > 1,nNumRat,1)))
								(ALIAS_TMP)->(Msunlock())
							ELSE
								Reclock(ALIAS_TMP,.T.)
								(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
								(ALIAS_TMP)->XX_CODIGO := "W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
								(ALIAS_TMP)->XX_DESC   := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
		//						cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
		//						&cCampo2 += cVALGG //IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),(cVALGG/IIF(nNumRat > 1,nNumRat,1))/VAL(aConsorcio[nScan,5]),(cVALGG/IIF(nNumRat > 1,nNumRat,1)))
								(ALIAS_TMP)->(Msunlock())
							ENDIF
						ENDIF
		
		                // Marcos - 30/05/19
		                If nParcela <= 0
		                   nParcela := 1
		                EndIf
						lPRat  := .T.

						nIndDesp := IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),VAL(aConsorcio[nScan,5]),1)
						nAuxVl   := nValRat/nIndDesp

					    FOR XI_ := _nI TO nParcela

							cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,"",.T.,nIndDesp)

							/*
			   				dbSelectArea(ALIAS_TMP)
			   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
								Reclock(ALIAS_TMP,.F.)
								cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
								&cCampo2 +=  IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
								(ALIAS_TMP)->(Msunlock())
							ELSE
								Reclock(ALIAS_TMP,.T.)
								(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
								(ALIAS_TMP)->XX_CODIGO := '30'
								(ALIAS_TMP)->XX_DESC   := "GASTOS GERAIS"
								cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
								&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
								(ALIAS_TMP)->(Msunlock())
							ENDIF
							*/

							IF nCompras == 1

								cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+TMPX2->D1_COD,XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,TMPX2->B1_DESC,.T.,nIndDesp)

								/*
								dbSelectArea(ALIAS_TMP)
				   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->D1_COD),.F.)
									Reclock(ALIAS_TMP,.F.)
									cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
									&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
									(ALIAS_TMP)->(Msunlock())
								ELSE
									Reclock(ALIAS_TMP,.T.)
									(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
									(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->D1_COD)
									(ALIAS_TMP)->XX_DESC   := ALLTRIM(TMPX2->B1_DESC)
									cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
									&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
									(ALIAS_TMP)->(Msunlock())
								ENDIF
								*/
							ELSE
								cCodCC := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
								cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+cCodCC,XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,cCodCC,.T.,nIndDesp)

								/*
								dbSelectArea(ALIAS_TMP)
				   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC)))),.F.)
									Reclock(ALIAS_TMP,.F.)
									cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
									&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
									(ALIAS_TMP)->(Msunlock())
								ELSE
									Reclock(ALIAS_TMP,.T.)
									(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
									(ALIAS_TMP)->XX_CODIGO := "W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
									(ALIAS_TMP)->XX_DESC   := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
									cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(XI_,3)
									&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
									(ALIAS_TMP)->(Msunlock())
								ENDIF
								*/
							ENDIF
							lPRat := .F.
						NEXT
	
		            ENDIF
					IF cOutros == 'S'
						//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA
						cVALGG := 0
						IF nDespGeral == 1 .AND. (nCompras == 0 .OR. nCompras == 1)
							IF !EMPTY(cSeqProj)
	            				dbSelectArea("SZL")
								SZL->(dbSetOrder(1))
								IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"02"+DTOS(dDtProj)+cSeqProj+"W"+ALLTRIM(TMPX2->D1_COD),.F.))
									cVALGG := SZL->ZL_VALOR
								ELSE
									DbSelectArea("SZL")
									RecLock("SZL",.T.)
									SZL->ZL_FILIAL 	:= xFilial("SZL")
									SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
									SZL->ZL_TIPO	:= '02'
									SZL->ZL_DATA   	:= dDtProj
									SZL->ZL_SEQ   	:= cSeqProj
									SZL->ZL_CODIGO 	:= "W"+ALLTRIM(TMPX2->D1_COD)
									SZL->ZL_DESC 	:= ALLTRIM(TMPX2->B1_DESC)
									SZL->ZL_VALOR  	:= 0
									SZL->(msUnlock())
	                    		ENDIF
							ENDIF
	            		ENDIF
	
						nAuxVl  := IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL /VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL )

						cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+TMPX2->D1_COD,_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,TMPX2->B1_DESC,.F.,nIndDesp)
						cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)


						/*
						dbSelectArea(ALIAS_TMP)
			   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->D1_COD),.F.)
							Reclock(ALIAS_TMP,.F.)
						ELSE
							Reclock(ALIAS_TMP,.T.)
							(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
							(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->D1_COD)
							(ALIAS_TMP)->XX_DESC   := ALLTRIM(TMPX2->B1_DESC)
						ENDIF
	//					cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
	//					&cCampo2 += cVALGG //IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),cVALGG /VAL(aConsorcio[nScan,5]),cVALGG )
						cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
						&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL /VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL )
						(ALIAS_TMP)->(Msunlock())
		
			   			dbSelectArea(ALIAS_TMP)
			   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
			     			Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL /VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL )
							(ALIAS_TMP)->(Msunlock())
						ENDIF
						*/
	
					ENDIF
					
					dbSelectArea("TMPX2")
					dbSkip()
				ENDDO
				TMPX2->(dbCloseArea())
	
				cQuery2 := "SELECT E5_CREDITO,E5_DEBITO,CT1_DESC01,E5_VALOR,E5_RECPAG,E5_CCC,E5_CCD,E5_VENCTO"
				cQuery2 += " FROM SE5"+ALLTRIM(aConsorcio[nScan,8])+" SE5" 
				cQuery2 += " LEFT JOIN CT1"+ALLTRIM(aConsorcio[nScan,8])+" CT1 ON (CT1_CONTA=E5_DEBITO OR CT1_CONTA=E5_CREDITO) AND CT1.D_E_L_E_T_=''"
				cQuery2 += " WHERE SE5.D_E_L_E_T_='' AND (SUBSTRING(E5_DEBITO,1,1)='3' OR SUBSTRING(E5_CREDITO,1,1)='3' )  AND E5_SITUACA<>'C'"
				cQuery2 += " AND SUBSTRING(E5_VENCTO,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'"
		        cQuery2 += " AND (E5_CCC='"+ALLTRIM(QTMP->CNF_CONTRA)+"' OR E5_CCD='"+ALLTRIM(QTMP->CNF_CONTRA)+"')"
				cQuery2 += " AND E5_FILIAL = '"+xFilial("SE5")+"'"+CRLF
		        
				u_LogTxt("BKGCTR14-E5-2.SQL")        
				TCQUERY cQuery2 NEW ALIAS "TMPX2"
				u_LogTxt("BKGCTR14-E5-2.SQL",cQuery2)        

				dbSelectArea("TMPX2")
				dbGoTop()
				DO While !TMPX2->(EOF()) 
					//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - MOVIMENTO BANCARIO
					cVALGG := 0
					IF nDespGeral == 1 .AND. nCompras == 0
						IF !EMPTY(cSeqProj)
	           				dbSelectArea("SZL")
							SZL->(dbSetOrder(1))
							IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"02"+DTOS(dDtProj)+cSeqProj+"W"+ALLTRIM(TMPX2->CT1_DESC01),.F.))
								cVALGG := SZL->ZL_VALOR
							ELSE
								DbSelectArea("SZL")
								RecLock("SZL",.T.)
								SZL->ZL_FILIAL 	:= xFilial("SZL")
								SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
								SZL->ZL_TIPO	:= '02'
								SZL->ZL_DATA   	:= dDtProj
								SZL->ZL_SEQ   	:= cSeqProj
								SZL->ZL_CODIGO 	:= "W"+ALLTRIM(TMPX2->CT1_DESC01)
								SZL->ZL_DESC 	:= ALLTRIM("*"+TMPX2->CT1_DESC01)
								SZL->ZL_VALOR  	:= 0
								SZL->(msUnlock())
	                   		ENDIF
						ENDIF
	           		ENDIF
	
					dbSelectArea(ALIAS_TMP)
		   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->CT1_DESC01),.F.)
						Reclock(ALIAS_TMP,.F.)
					ELSE
						Reclock(ALIAS_TMP,.T.)
						(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
						(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->CT1_DESC01)
						(ALIAS_TMP)->XX_DESC   := ALLTRIM("*"+TMPX2->CT1_DESC01)
					ENDIF
	//				cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
	//				&cCampo2 += cVALGG //(cVALGG /VAL(aConsorcio[nScan,5]))
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->E5_VALOR /VAL(aConsorcio[nScan,5])) * IIF(TMPX2->E5_RECPAG=='R',-1,1)
					(ALIAS_TMP)->(Msunlock())
	
		   			dbSelectArea(ALIAS_TMP)
		   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
		     			Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
						&cCampo2 += (TMPX2->E5_VALOR /VAL(aConsorcio[nScan,5])) * IIF(TMPX2->E5_RECPAG=='R',-1,1)
						(ALIAS_TMP)->(Msunlock())
					ENDIF
	
					TMPX2->(dbSkip())
				ENDDO
				TMPX2->(dbCloseArea()) 
	        ENDIF
// 12/02/19 - Fim inclusão de despesas BK na Balsa Nova
//aqui
	  	ELSE
			cQuery2 := "SELECT E5_CREDITO,E5_DEBITO,CT1_DESC01,E5_VALOR,E5_RECPAG,E5_CCC,E5_CCD,E5_VENCTO"
			cQuery2 += " FROM "+RETSQLNAME("SE5")+" SE5" 
			cQuery2 += " LEFT JOIN "+RETSQLNAME("CT1")+" CT1 ON (CT1_CONTA=E5_DEBITO OR CT1_CONTA=E5_CREDITO) AND CT1.D_E_L_E_T_=''"
			cQuery2 += " WHERE SE5.D_E_L_E_T_='' AND (SUBSTRING(E5_DEBITO,1,1)='3' OR SUBSTRING(E5_CREDITO,1,1)='3' )  AND E5_SITUACA<>'C'"
			cQuery2 += " AND SUBSTRING(E5_VENCTO,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'"
	        cQuery2 += " AND (E5_CCC='"+ALLTRIM(QTMP->CNF_CONTRA)+"' OR E5_CCD='"+ALLTRIM(QTMP->CNF_CONTRA)+"')"
			cQuery2 += " AND E5_FILIAL = '"+xFilial("SE5")+"'"+CRLF
	        
			u_LogTxt("BKGCTR14-E5-3.SQL")
			TCQUERY cQuery2 NEW ALIAS "TMPX2"
			u_LogTxt("BKGCTR14-E5-3.SQL",cQuery2)
			
			dbSelectArea("TMPX2")
			dbGoTop()
			DO While !TMPX2->(EOF()) 

				//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - MOVIMENTO BANCARIO
				cVALGG := 0
				IF nDespGeral == 1 .AND. nCompras == 0
					IF !EMPTY(cSeqProj)
           				dbSelectArea("SZL")
						SZL->(dbSetOrder(1))
						IF SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"02"+DTOS(dDtProj)+cSeqProj+"W"+ALLTRIM(TMPX2->CT1_DESC01),.F.))
							cVALGG := SZL->ZL_VALOR
						ELSE
							DbSelectArea("SZL")
							RecLock("SZL",.T.)
							SZL->ZL_FILIAL 	:= xFilial("SZL")
							SZL->ZL_CONTRAT	:= ALLTRIM(QTMP->CNF_CONTRA)
							SZL->ZL_TIPO	:= '02'
							SZL->ZL_DATA   	:= dDtProj
							SZL->ZL_SEQ   	:= cSeqProj
							SZL->ZL_CODIGO 	:= "W"+ALLTRIM(TMPX2->CT1_DESC01)
							SZL->ZL_DESC 	:= ALLTRIM("*"+TMPX2->CT1_DESC01)
							SZL->ZL_VALOR  	:= 0
							SZL->(msUnlock())
                   		ENDIF
					ENDIF
           		ENDIF
           		
           		IF nCompras == 0
					dbSelectArea(ALIAS_TMP)
	   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->CT1_DESC01),.F.)
						Reclock(ALIAS_TMP,.F.)
					ELSE
						Reclock(ALIAS_TMP,.T.)
						(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
						(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->CT1_DESC01)
						(ALIAS_TMP)->XX_DESC   := ALLTRIM("*"+TMPX2->CT1_DESC01)
					ENDIF
//					cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
//					&cCampo2 += cVALGG
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->E5_VALOR * IIF(TMPX2->E5_RECPAG=='R',-1,1)
					(ALIAS_TMP)->(Msunlock())

	   				dbSelectArea(ALIAS_TMP)
	   				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
	     				Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
						&cCampo2 += TMPX2->E5_VALOR  * IIF(TMPX2->E5_RECPAG=='R',-1,1)
						(ALIAS_TMP)->(Msunlock())
					ENDIF
				ENDIF
				TMPX2->(dbSkip())
			ENDDO
			TMPX2->(dbCloseArea())
	  	ENDIF

		/*
		If !lJob
			IncProc("Consultando faturamento de medições avulsas...")
		Else
			u_xxLog(cArqLog,"Consultando faturamento de medições avulsas..."+STR(_nI),.T.,"")
		EndIf
		*/

		//********* FATURAMENTO - Inclusão para medição avulso
		cQuery2 := "SELECT C5_ESPECI1,A1_NOME,CTT_DESC01,SUM(D2_TOTAL) AS D2_TOTAL,SUM(D2_VALISS) AS D2_VALISS,SUM(D2_VALCPM) AS D2_VALCPM, SUM(E5_VALOR) AS E5DESC"
		cQuery2 += " FROM "+RETSQLNAME("SC5")+" SC5" 
		cQuery2 += " INNER JOIN "+RETSQLNAME("SC6")+" SC6 ON SC5.C5_NUM = SC6.C6_NUM" 
		
	    cQuery2 += " INNER JOIN "+RETSQLNAME("SD2")+" SD2 ON C6_NUM = D2_PEDIDO AND C6_ITEM = D2_ITEM"
		cQuery2 += " AND  SD2.D2_FILIAL = '"+xFilial("SD2")+"'  AND  SD2.D_E_L_E_T_ = ''"
	    
		// 27/02/20   
		cQuery2 += "LEFT JOIN "+RETSQLNAME("SE5")+" SE5 ON E5_PREFIXO = D2_SERIE AND E5_NUMERO = D2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = D2_CLIENTE AND E5_LOJA = D2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C'  AND E5_DTCANBX = ''" //--AND E5_PARCELA = '  '
		cQuery2 += "      AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = '' "

	    cQuery2 += " INNER JOIN "+RETSQLNAME("SA1")+" SA1 ON SC5.C5_CLIENTE = SA1.A1_COD" 
	    cQuery2 += " AND SC5.C5_LOJACLI = SA1.A1_LOJA  AND  SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ''"
	    
	    cQuery2 += " INNER  JOIN "+RETSQLNAME("CTT")+" CTT ON SC5.C5_ESPECI1 = CTT.CTT_CUSTO AND CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ''" 
	    cQuery2 += " WHERE SC5.D_E_L_E_T_ = '' AND SC5.C5_MDCONTR='' AND SC5.C5_XXCOMPT ='"+SUBSTR(aPeriodo[_nI,1],1,2)+SUBSTR(aPeriodo[_nI,1],4,4)+"'"
	   	cQuery2 += " AND C5_ESPECI1 <> '000000001'"
	    //IF !EMPTY(cContrato)
	    //	cQuery2 += " AND C5_ESPECI1 ='"+ALLTRIM(cContrato)+"'"
	    //ENDIF	
    	cQuery2 += " AND C5_ESPECI1 ='"+ALLTRIM(QTMP->CNF_CONTRA)+"'"
	    	
	    cQuery2 += " GROUP BY SC5.C5_ESPECI1,SA1.A1_NOME,CTT.CTT_DESC01" 
	      	
		TCQUERY cQuery2 NEW ALIAS "TMPX2"
		
		dbSelectArea("TMPX2")
		dbGoTop()
		DO While !TMPX2->(EOF())
	        aRentab  := {}
	        aAdd(aRentab,{"00","CLIENTE: ","S",TRIM(TMPX2->A1_NOME)})              
	        aAdd(aRentab,{"01","CONTRATO: ","S",TRIM(TMPX2->CTT_DESC01)})              
	        aAdd(aRentab,{"02","Gestor BK: ","S",""})              
			//aAdd(aRentab,{"03","FATURAMENTO OFICIAL","S",TMPX2->D2_TOTAL})    
			aAdd(aRentab,{"03","FATURAMENTO OFICIAL","S",IIF(nIndTC>0,TMPX2->D2_TOTAL/(nIndTC/100),TMPX2->D2_TOTAL)})              
			          
	        aAdd(aRentab,{"03-2","","S",0}) 
			//aAdd(aRentab,{"04","(-) Impostos e Contribuições","S",(TMPX2->D2_TOTAL*nMImpContr)/100})  
			aAdd(aRentab,{"04","(-) Impostos e Contribuições","S",IIF(nIndTC>0,((TMPX2->D2_TOTAL*nMImpContr)/100)/(nIndTC/100),(TMPX2->D2_TOTAL*nMImpContr)/100)})            
			          
			//aAdd(aRentab,{"05","(-) ISS","S",TMPX2->D2_VALISS}) 
        	aAdd(aRentab,{"05","(-) ISS","S",IIF(nIndTC>0,TMPX2->D2_VALISS/(nIndTC/100),TMPX2->D2_VALISS)})            
        	aAdd(aRentab,{"05-01","(-) ISS Bitributado","S",IIF(nIndTC>0,TMPX2->D2_VALCPM/(nIndTC/100),TMPX2->D2_VALCPM)})
			           
	        aAdd(aRentab,{"05-2","","S",0}) 
	        //aAdd(aRentab,{"06","Total dos Impostos + ISS","S",((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS})            
        	aAdd(aRentab,{"06","Total dos Impostos + ISS","S",IIF(nIndTC>0,(((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS+TMPX2->D2_VALCPM)/(nIndTC/100),((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS+TMPX2->D2_VALCPM)})            

			aAdd(aRentab,{"06-1","","S",0}) 
			//aAdd(aRentab,{"07","FATURAMENTO LÍQUIDO","S",TMPX2->D2_TOTAL-(((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS)}) 
        	aAdd(aRentab,{"07","FATURAMENTO LÍQUIDO","S",IIF(nIndTC>0,(TMPX2->D2_TOTAL-(((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS+TMPX2->D2_VALCPM))/(nIndTC/100),TMPX2->D2_TOTAL-(((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS+TMPX2->D2_VALCPM))}) 
			
	        aAdd(aRentab,{"07-1","","S",0}) 
	        aAdd(aRentab,{"08","CUSTO","S",0}) 
	        aAdd(aRentab,{"09","PROVENTOS","S",0}) 
	        aAdd(aRentab,{"10","ENCARGOS","S",0}) 
	        aAdd(aRentab,{"11","INCIDENCIAS","S",0}) 
	        aAdd(aRentab,{"110","PLR","S",0}) 
        	aAdd(aRentab,{"111","VERBAS SEM ENCARGOS/INCIDENCIAS","S",0}) 
	        aAdd(aRentab,{"12","VT","S",0}) 
	        aAdd(aRentab,{"13","(-) Recuperação de VT","S",0}) 
	        aAdd(aRentab,{"14","VR/VA","S",0}) 
	        aAdd(aRentab,{"15","(-) Recuperação de VR/VA","S",0}) 
	        aAdd(aRentab,{"16","ASSMEDICA","S",0}) 
	        aAdd(aRentab,{"17","(-) Recuperação de ASSMEDICA","S",0}) 
	        aAdd(aRentab,{"18","SINDICATO (ODONTO)","S",0}) 
	        aAdd(aRentab,{"19","(-) Recuperação de SINDICATO (ODONTO)","S",0}) 
        	aAdd(aRentab,{"20","CECREMEF/ADV","S",0}) 
        	aAdd(aRentab,{"21","(-) CECREMEF/ADV","S",0}) 
	        aAdd(aRentab,{"22-1","","S",0}) 
	        aAdd(aRentab,{"30","GASTOS GERAIS","S",0}) 
	        aAdd(aRentab,{"30-1","","S",0}) 
	        aAdd(aRentab,{"30-2","DESCONTOS NA NF","S",IIF(nIndTC>0,TMPX2->E5DESC/(nIndTC/100),TMPX2->E5DESC)}) 
	        aAdd(aRentab,{"30-3","NDC","S",0}) 
	        aAdd(aRentab,{"YYYYYYYYY","TAXA DE ADMINISTRAÇÃO","S",0})
	        aAdd(aRentab,{"YYYYYYYYZ","","S",0}) 
        	aAdd(aRentab,{"ZZZZZZZZY","RESULTADO PARCIAL","S",0})
        	aAdd(aRentab,{"ZZZZZZZZZ","RESULTADO GLOBAL","S",0})
			
			FOR _nJ := 1 TO LEN(aRentab)
				dbSelectArea(ALIAS_TMP)
				IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->C5_ESPECI1))+aRentab[_nJ,1],.F.)
					Reclock(ALIAS_TMP,.F.)
				ELSE
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",TMPX2->C5_ESPECI1)
					(ALIAS_TMP)->XX_CODIGO := aRentab[_nJ,1]
					(ALIAS_TMP)->XX_DESC   := IIF("|"+aRentab[_nJ,1]+"|" $ "|00|01|02|",aRentab[_nJ,4]+IIF("|"+aRentab[_nJ,1]+"|"="|01|"," - Medição Avulsa",""),aRentab[_nJ,2])
				ENDIF
				IF "|"+aRentab[_nJ,1]+"|" $ "|03|03-1|04|05|05-1|06|07|30-2|30-3|"
					cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
					&cCampo2 += aRentab[_nJ,4]
				ENDIF
				(ALIAS_TMP)->(Msunlock())
	        NEXT
	
		   dbSelectArea("TMPX2")
		   dbSkip()
		ENDDO
		TMPX2->(dbCloseArea())
	

	   	QTMP->(dbSkip())
	ENDDO
    QTMP->(dbCloseArea())

NEXT


//Calcular resultados

nRDOMES 	:= 0
nRESULTMES 	:= 0
nRGDOMES 	:= 0
nRGATMES 	:= 0
nRESULT 	:= 0
nRPREVISTO 	:= 0
nVPREVSITO  := 0 
If !lJob
	ProcRegua(Len(aContratos))
EndIf

For Yi_ := 1 TO LEN(aContratos)

	If !lJob
		IncProc("Calculando resultados "+aContratos[Yi_]+"...")
	EndIf
	u_xxLog(cArqLog,"Calculando resultados "+aContratos[Yi_],.T.,"")

	FOR _nI := 1 TO nPeriodo
		
		//Calcular taxa adm
        nValTaxaAdm := 0
		dbSelectArea(ALIAS_TMP)
		IF dbSeek(ALLTRIM(aContratos[Yi_])+'03',.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
        	nValTaxaAdm := (&cCampo2*nTaxaAdm)/100 
		ENDIF

      	//Valor da ndc
		//nNDC := 0
		//dbSelectArea(ALIAS_TMP)
		//IF MsSeek(ALLTRIM(aContratos[Yi_])+'30-3',.F.)
		//	cCampo2   := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
		//	nNDC := &cCampo2
		//ENDIF

		//Gravar taxa adm
		dbSelectArea(ALIAS_TMP)
	   	IF dbSeek(ALLTRIM(aContratos[Yi_])+"YYYYYYYYY",.F.)
			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			&cCampo2 += nValTaxaAdm 
			(ALIAS_TMP)->(Msunlock())
		ELSE
			Reclock(ALIAS_TMP,.T.)
			(ALIAS_TMP)->XX_CODGCT := ALLTRIM(aContratos[Yi_])
			(ALIAS_TMP)->XX_CODIGO := "YYYYYYYYY"
			(ALIAS_TMP)->XX_DESC   := "TAXA DE ADMINISTRAÇÃO"
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			&cCampo2 += nValTaxaAdm 
			(ALIAS_TMP)->(Msunlock())
		ENDIF
		
		//Somar taxa adm nos gastos gerais
		dbSelectArea(ALIAS_TMP)
		IF dbSeek(ALLTRIM(aContratos[Yi_])+'30',.F.)
   			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			&cCampo2 += nValTaxaAdm
		    n2Resultado := nValTaxaAdm
			(ALIAS_TMP)->(Msunlock())
		ENDIF

	    // Calculo do Resultado
	    nResultado := 0
		
		dbSelectArea(ALIAS_TMP)
		IF dbSeek(ALLTRIM(aContratos[Yi_])+'07',.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			nResultado += &cCampo2
			n2Resultado += &cCampo2
		ENDIF
		dbSelectArea(ALIAS_TMP)
		IF dbSeek(ALLTRIM(aContratos[Yi_])+'08',.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			nResultado -= &cCampo2
			n2Resultado -= &cCampo2
		ENDIF

		//Somar descontos do SE5 nos gastos gerais 28/02/20
	    nDescE5 := 0
		dbSelectArea(ALIAS_TMP)
		IF dbSeek(ALLTRIM(aContratos[Yi_])+'30-2',.F.)
   			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			nDescE5  := &cCampo2

			nResultado -= nDescE5
			n2Resultado -= nDescE5
		ENDIF

	    nNDC := 0
		dbSelectArea(ALIAS_TMP)
		IF dbSeek(ALLTRIM(aContratos[Yi_])+'30-3',.F.)
   			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			nNDC  := &cCampo2

			nResultado -= nNDC
			n2Resultado -= nNDC
		ENDIF

		dbSelectArea(ALIAS_TMP)
		IF dbSeek(ALLTRIM(aContratos[Yi_])+'30',.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			nResultado -= &cCampo2
			n2Resultado -= &cCampo2
		ENDIF

		dbSelectArea(ALIAS_TMP)
		IF dbSeek(ALLTRIM(aContratos[Yi_])+'ZZZZZZZZY',.F.)
			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			&cCampo2 := nResultado
			(ALIAS_TMP)->(Msunlock())
		ENDIF
		dbSelectArea(ALIAS_TMP)
		IF dbSeek(ALLTRIM(aContratos[Yi_])+'ZZZZZZZZZ',.F.)
			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			&cCampo2 := n2Resultado
			(ALIAS_TMP)->(Msunlock())
		ENDIF
    NEXT
NEXT


cCompet	:= STRZERO(nMesC,2)+"/"+STRZERO(nAnoC,4)

// Calcular os ultimos n meses
If lJob
	cNMeses := STRZERO(YEAR(DATE()),4)+STRZERO(MONTH(DATE()),2) +"|"
Else
	cNMeses := STRZERO(nAnoC,4)+STRZERO(nMesC,2) +"|"
EndIf

nMesA   := MONTH(DATE())
nAnoA	:= YEAR(DATE())
If nCompAtual == 3
	For _nj := 1 TO nNmeses
		nMesA--
		If nMesA < 1
			nMesA := 12
			nAnoA--
		EndIf
		cNMeses += STRZERO(nAnoA,4) + STRZERO(nMesA,2) + "|"
	Next
EndIf

u_xxLog(cArqLog,"Calculando resultados de "+STRZERO(nNMeses,2)+" meses",.T.,"")
For _nJ := 1 To nPeriodo
	cCompet	:= aPeriodo[_nJ,1]
	If nCompAtual == 2 .OR. (aAnoMes[_nJ] +"|") $ cNMeses 
		If !lJob
			IncProc("Calculando resultados "+cCompet+"...")
		EndIf
		u_xxLog(cArqLog,"Calculando resultados "+cCompet,.T.,"")
		GeraResult(_nJ,cCompet)
	EndIf
Next

// Gerar tipo de relatorio sintetico ou normal
If lSintetico .or. lJob
	Gera2Result()
EndIf

Return Nil



STATIC FUNCTION GeraResult(nCompet,cCompet)

Local aGeral 	:= {}
Local aBenef 	:= {}
//Local I			:= 0
Local _IX		:= 0
Local _XI		:= 0
Local _nI		:= 0
Local nI		:= 0

/*
//Verifica o Crupo do usuario - visualização do relatorio
PswOrder(1) 
PswSeek(__CUSERID) 
aUser  := PswRet(1)

cCodView := ""
cCodView := SuperGetMV("MV_XXRENTA")


cMaster := ""
cMaster := SuperGetMV("MV_XXGRREN",.F.,"000000/000003/000007/000008/000010/000020")
lMaster := .F.
aGRUPO := {}
//aAdd(aGRUPO,aUser[1,10])
//FOR i:=1 TO LEN(aGRUPO[1])
//	lMaster := (aGRUPO[1,i] $ cMaster)
//NEXT
//Ajuste nova rotina a antiga não funciona na nova lib MDI
aGRUPO := UsrRetGrp(aUser[1][2])
IF LEN(aGRUPO) > 0
	FOR i:=1 TO LEN(aGRUPO)
		lMaster := (ALLTRIM(aGRUPO[i]) $ cMaster )
	NEXT
ENDIF	
*/

nLINHA := 1
aLINHA := {}
DbSelectArea(ALIAS_TMP)
(ALIAS_TMP)->(dbSetOrder(1))
(ALIAS_TMP)->(dbgotop())
cCodigo  := (ALIAS_TMP)->XX_CODGCT

nBficP 	 := 0
nBficR 	 := 0
nCustoBkP:= 0
nCustoBkR:= 0
nRNTBILP := 0
nRNTBILR := 0
InsumosP := 0
nDescE5  := 0
nValTADP := 0
InsumosR := 0
nValTADR := 0
nTXATMESR:= 0
nTXMESR  := 0
cCustoBk := ""

cCampoX  := "XX_VALP"+STRZERO(nCompet,3)
cCampoY  := "XX_VALR"+STRZERO(nCompet,3)
cCampoZ  := "XX_VL2P"+STRZERO(nCompet,3)

nFatura     := 0
nTotFat 	:= 0
nTotCUSTO 	:= 0
nTotFatMES 	:= 0
nTotalMES  	:= 0
nTFATDOMES 	:= 0
nTDOMES 	:= 0
nRPREVISTO 	:= 0
nVPREVISTO 	:= 0

Do While (ALIAS_TMP)->(!eof())
	
	nTotal 		:= 0
	nTotalMES 	:= 0
	nTDOMES 	:= 0

	FOR _nI := 1 TO nPeriodo
		IF !("|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|00|01|03-2|02|05-2|06-1|07-1|22-1|30-1|30-3|YYYYYYYYZ|")	
			cCampo2		:= ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
	        nTotal		 += &cCampo2
	        IF _nI == nCompet
	        	nRDOMES += &cCampo2
	        	nTDOMES  += &cCampo2
				IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|03|"
			 		cCampo2	:= ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
      				nTXMESR := (&cCampo2 * nTaxaAdm)/100
		    	ENDIF
	        ENDIF
	        IF _nI <= nCompet
	        	nRESULTMES += &cCampo2
	        	nTotalMES  += &cCampo2
	        ENDIF
		ENDIF
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|03|"
			IF _nI <= nCompet
			    cCampo2		:= ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
      			nTXATMESR 	+= (&cCampo2 * nTaxaAdm)/100
		    ENDIF
		ENDIF
	NEXT
 
	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|03|"
        nTotFat := nTotal
        nTotFatMES := nTotalMES
        nTFATDOMES := nTDOMES
	ENDIF	
	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|06|07|08|30|YYYYYYYYY|ZZZZZZZZZ|"
        nRESULT := Round((nTotal/nTotFat)*100,5)
        nRDOMES := Round(((nTDOMES-nTXMESR)/nTFATDOMES)*100,5)
        nRESULTMES := Round(((nTotalMES-nTXATMESR)/nTotFatMES)*100,5)
        nRGDOMES := Round((nTDOMES/nTFATDOMES)*100,5)
        nRGATMES := Round((nTotalMES/nTotFatMES)*100,5)
 	ENDIF	
 
	IF nConsolida == 1
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|00|"
	    	nRENTABIL	:= 0
			aGeral 		:= {}
			aBenef		:= {}
			FOR _IX := 1 TO LEN(aContConsol)

				dbSelectArea("TRB")
				//Gravar cabeçalho 
	 			Reclock("TRB",.T.)
				TRB->XX_LINHA   := nLINHA
				TRB->XX_COMPET  := cCompet
	 			TRB->XX_CODGCT  := "999999999"
				TRB->XX_DESC	:= ""
				TRB->XX_PROJ 	:= "Num. Siga: "+TRIM(aContConsol[_IX,1] )
				TRB->XX_REAL 	:= ""
				TRB->XX_DIF 	:= ""
				TRB->(Msunlock())
				aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})

		 		++nLINHA
	    	
				dbSelectArea("TRB")
				//Gravar cabeçalho 
	 			Reclock("TRB",.T.)
				TRB->XX_LINHA   := nLINHA
				TRB->XX_COMPET  := cCompet
	 			TRB->XX_CODGCT  := "999999999"
				TRB->XX_DESC	:= "Cliente:"
				TRB->XX_PROJ 	:= TRIM(aContConsol[_IX,2])
				TRB->XX_REAL 	:= ""
				TRB->XX_DIF 	:= ""
				aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
				TRB->(Msunlock())
				
		 		++nLINHA
				dbSelectArea("TRB")
				//Gravar cabeçalho 
	 			Reclock("TRB",.T.)
				TRB->XX_LINHA   := nLINHA
				TRB->XX_COMPET  := cCompet
	 			TRB->XX_CODGCT  := "999999999"
				TRB->XX_DESC	:= "Contrato:"
				TRB->XX_PROJ 	:= TRIM(aContConsol[_IX,3])
				TRB->XX_REAL 	:= ""
				TRB->XX_DIF 	:= ""
				aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
				TRB->(Msunlock()) 
				
		 		++nLINHA
	 			Reclock("TRB",.T.)
				TRB->XX_LINHA   := nLINHA
				TRB->XX_COMPET  := cCompet
	 			TRB->XX_CODGCT  :="999999999"
				TRB->XX_DESC	:= "Gestor Responsável "+FWEmpName(cEmpAnt)+":"
				TRB->XX_PROJ 	:= TRIM(aContConsol[_IX,4])
				TRB->XX_REAL 	:= ""
				TRB->XX_DIF 	:= ""
				aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
				TRB->(Msunlock())

				nVContrat := 0
        		nVContrat := aScan(aVContrat, {|x| x[1]==aContConsol[_IX,1] })
		 		++nLINHA
	 			Reclock("TRB",.T.)
				TRB->XX_LINHA   := nLINHA
				TRB->XX_COMPET  := cCompet
	 			TRB->XX_CODGCT  :="999999999"
				TRB->XX_DESC	:= "Vigência:"
				TRB->XX_PROJ 	:= IIF(nVContrat > 0,DTOC(aVContrat[nVContrat,2])+" até "+DTOC(aVContrat[nVContrat,3]),"")
				TRB->XX_REAL 	:= ""
				TRB->XX_DIF 	:= ""
				aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
				TRB->(Msunlock())

			NEXT

	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
			TRB->XX_COMPET  := cCompet
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Competência Analisada:"
			TRB->XX_PROJ 	:= aMeses[nMesC]+"/"+STRZERO(nAnoC,4)
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF		:= ""
			aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
			TRB->(Msunlock())
	
		 	++nLINHA
	
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
			TRB->XX_COMPET  := cCompet
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Descrição Item"
			TRB->XX_PROJ 	:= "Previsão Financeira"
			TRB->XX_REAL 	:= "Realizado"
			TRB->XX_DIF 	:= "Diferença %"
			aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_DESC","","S","",""})
			aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_PROJ","","S","",""})
			aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_REAL","","S","",""})
			aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_DIF" ,"","S","",""})
			TRB->(Msunlock())
		
		ENDIF
	ELSE
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|00|"
	    	nRENTABIL	:= 0
			aGeral 		:= {}
			aBenef		:= {}
			dbSelectArea("TRB")
			//Gravar cabeçalho 
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
			TRB->XX_COMPET  := cCompet
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= ""
			TRB->XX_PROJ 	:= "Num. Siga: "+(ALIAS_TMP)->XX_CODGCT 
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
	
		 	++nLINHA
	    	
			dbSelectArea("TRB")
			//Gravar cabeçalho 
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
			TRB->XX_COMPET  := cCompet
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Cliente:"
			TRB->XX_PROJ 	:= TRIM((ALIAS_TMP)->XX_DESC)
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
	    ENDIF
	
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|01|"
	 
			dbSelectArea("TRB")
			//Gravar cabeçalho 
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
			TRB->XX_COMPET  := cCompet
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Contrato:"
			TRB->XX_PROJ 	:= TRIM((ALIAS_TMP)->XX_DESC)
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
	
	    ENDIF
	
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|02|"
	
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
			TRB->XX_COMPET  := cCompet
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Gestor Responsável "+FWEmpName(cEmpAnt)+":"
			TRB->XX_PROJ 	:= TRIM((ALIAS_TMP)->XX_DESC)
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
	
			nVContrat := 0
       		nVContrat := aScan(aVContrat, {|x| x[1]==(ALIAS_TMP)->XX_CODGCT })
	 		++nLINHA
 			Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
			TRB->XX_COMPET  := cCompet
 			TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Vigência:"
			TRB->XX_PROJ 	:= IIF(nVContrat > 0,DTOC(aVContrat[nVContrat,2])+" até "+DTOC(aVContrat[nVContrat,3]),"")
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
			TRB->(Msunlock())

		 	++nLINHA
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
			TRB->XX_COMPET  := cCompet
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Competência Analisada:"
			TRB->XX_PROJ 	:= aMeses[nMesC]+"/"+STRZERO(nAnoC,4)
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
			TRB->(Msunlock())

		 	++nLINHA
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
			TRB->XX_COMPET  := cCompet
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Descrição Item"
			TRB->XX_PROJ 	:= "Previsão Financeira"
			TRB->XX_REAL 	:= "Realizado"
			TRB->XX_DIF 	:= "Diferença %"
			aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_DESC","","S","",""})
			aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_PROJ","","S","",""})
			aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_REAL","","S","",""})
			aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_DIF" ,"","S","",""})
			TRB->(Msunlock())
		
		ENDIF
    ENDIF

	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|03|"
		nFatura := 0
		nFatura := (ALIAS_TMP)->&cCampoY 
		dbSelectArea("TRB")
		//FATURAMENTO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
		TRB->XX_COMPET  := cCompet
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= (ALIAS_TMP)->XX_DESC

		TRB->XX_PROJ 	:= transform((ALIAS_TMP)->&cCampoX,cPict)
		TRB->XX_PROJN 	:= (ALIAS_TMP)->&cCampoX

		//aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_PROJ" ,"","N","PREVISTO"+cCodigo,"PREVISTO"+cCodigo})

		TRB->XX_REAL 	:= transform((ALIAS_TMP)->&cCampoY,cPict)
		TRB->XX_REALN 	:= (ALIAS_TMP)->&cCampoY

		//aAdd(aFormula1,{TRB->(RECNO()),"TRB->XX_REAL" ,"","N","REALIZADO"+cCodigo,"REALIZADO"+cCodigo})

		TRB->XX_DIF 	:= transform((((ALIAS_TMP)->&cCampoX - (ALIAS_TMP)->&cCampoY) / (ALIAS_TMP)->&cCampoX * 100)*-1,"@E 99999.99999")+"%"
		TRB->XX_DIFN 	:= (((ALIAS_TMP)->&cCampoX - (ALIAS_TMP)->&cCampoY) / (ALIAS_TMP)->&cCampoX * 100)*-1
		TRB->XX_POWERBK := "S"
		TRB->(Msunlock())

		nValTADP	:=  0
      	nValTADP 	:= ((ALIAS_TMP)->&cCampoX * nTaxaAdm)/100		
		nValTADR	:=  0
      	nValTADR 	:= ((ALIAS_TMP)->&cCampoY * nTaxaAdm)/100
		nRNTBILP	:= 0
		nRNTBILP	:= (ALIAS_TMP)->&cCampoX
		nRNTBILR	:= 0
		nRNTBILR	:= (ALIAS_TMP)->&cCampoY
	ENDIF

	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|09|"
		dbSelectArea("TRB")
		//PROVENTO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA  := nLINHA
		TRB->XX_COMPET  := cCompet
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= (ALIAS_TMP)->XX_DESC
		TRB->XX_PROJ 	:= transform( (ALIAS_TMP)->&cCampoX,cPict)
		TRB->XX_PROJN 	:= (ALIAS_TMP)->&cCampoX
		TRB->XX_REAL 	:= transform( (ALIAS_TMP)->&cCampoY,cPict)
		TRB->XX_REALN 	:= (ALIAS_TMP)->&cCampoY
		TRB->XX_DIF 	:= transform((((ALIAS_TMP)->&cCampoX - (ALIAS_TMP)->&cCampoY) / (ALIAS_TMP)->&cCampoX * 100)*-1,"@E 99999.99999")+"%"
		TRB->XX_DIFN 	:= (((ALIAS_TMP)->&cCampoX - (ALIAS_TMP)->&cCampoY) / (ALIAS_TMP)->&cCampoX * 100)*-1
		TRB->XX_POWERBK := "S"
		TRB->(Msunlock())
		nRNTBILP	-=  (ALIAS_TMP)->&cCampoX
		nRNTBILR	-=  (ALIAS_TMP)->&cCampoY
	ENDIF


	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|12A|"
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|12A|"
			nBficP		:= 0
		endif
  		nBficP		+= (ALIAS_TMP)->&cCampoX
	ENDIF

	// 28/02/20 incluido |111"
	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|110|111|12A|12|14|16|18|19|20|"   
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|110|"
			nBficR		:= 0
		endif
        nBficR		+= (ALIAS_TMP)->&cCampoY
	ENDIF 

	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|21|"
		dbSelectArea("TRB")
		//BENEFICIOS 
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
		TRB->XX_COMPET  := cCompet
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "BENEFICIOS"
		TRB->XX_PROJ 	:= transform(nBficP,cPict)
		TRB->XX_PROJN 	:= nBficP
		TRB->XX_REAL 	:= transform(nBficR,cPict)
		TRB->XX_REALN 	:= nBficR
		TRB->XX_DIF 	:= transform(((nBficP - nBficR) / nBficP * 100)*-1,"@E 99999.99999")+"%"
		TRB->XX_DIFN 	:= ((nBficP - nBficR) / nBficP * 100)*-1
		TRB->XX_POWERBK := "S"
		TRB->(Msunlock())
		nRNTBILP	-= nBficP
		nRNTBILR	-= nBficR
		nBficP		:= 0
		nBficR		:= 0

		IF nDespGeral == 1 .AND. nCompras == 0 .AND. LEN(aBenef) > 0
		
			dbSelectArea("TRB")
			//PULA LINHA
 			Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
			TRB->XX_COMPET  := cCompet
 			TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= ""
			TRB->XX_PROJ 	:= ""
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())

			dbSelectArea("TRB")
 			Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
			TRB->XX_COMPET  := cCompet
 			TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "DETALHE DOS BENEFICIOS"
			TRB->XX_PROJ 	:= ""
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
			
			FOR _XI := 1 TO LEN(aBenef)
				IF aBenef[_XI,3] <> 0 .OR. aBenef[_XI,4] <> 0
					dbSelectArea("TRB")
					//GASTOS GERAIS
 					Reclock("TRB",.T.)
					TRB->XX_LINHA   := nLINHA
					TRB->XX_COMPET  := cCompet
 					TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT

					TRB->XX_DESC	:= aBenef[_XI,2]
					TRB->XX_PROJ 	:= transform(aBenef[_XI,3],cPict)
					TRB->XX_PROJN 	:= aBenef[_XI,3]
					TRB->XX_REAL 	:= transform(aBenef[_XI,4],cPict)
					TRB->XX_REALN 	:= aBenef[_XI,4]
					TRB->XX_DIF 	:= transform(aBenef[_XI,5],"@E 99999.99999")+"%"
					TRB->XX_DIFN 	:= aBenef[_XI,5]
					TRB->XX_POWERBK := "S"
				ENDIF
			NEXT

			dbSelectArea("TRB")
			//PULA LINHA
 			Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
			TRB->XX_COMPET  := cCompet
 			TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= ""
			TRB->XX_PROJ 	:= ""
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())

	    ENDIF


	ENDIF

	IF nDespGeral == 1 .AND. nCompras == 0
		// 28/02/20 incluido |111"
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|110|111|12|14|16|18|19|20|"  .OR. SUBSTR((ALIAS_TMP)->XX_CODIGO,1,4) == "18-1"
	 		aAdd(aBenef,{(ALIAS_TMP)->XX_CODGCT,(ALIAS_TMP)->XX_DESC,(ALIAS_TMP)->&cCampoX,(ALIAS_TMP)->&cCampoY,(((ALIAS_TMP)->&cCampoX - (ALIAS_TMP)->&cCampoY) / (ALIAS_TMP)->&cCampoX * 100)*-1})
		ENDIF
	ENDIF

	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|30|"
		InsumosP := 0
		InsumosP :=  (ALIAS_TMP)->&cCampoX
		InsumosR := 0
		InsumosR :=  (ALIAS_TMP)->&cCampoY
	ENDIF


	// 21/01/21
	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|30-3|"
		dbSelectArea("TRB")
		//NDC
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
		TRB->XX_COMPET  := cCompet
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "NDC"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform((ALIAS_TMP)->&cCampoY,cPict)
		TRB->XX_REALN 	:= (ALIAS_TMP)->&cCampoY
		TRB->XX_DIF 	:= ""
		TRB->XX_POWERBK := "S"
		TRB->(Msunlock())
		++nLINHA
	ENDIF

	// 28/02/20
	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|30-2|"
		dbSelectArea("TRB")
		//Desconto na nf
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
		TRB->XX_COMPET  := cCompet
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "DESCONTO NA NF"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform((ALIAS_TMP)->&cCampoY,cPict)
		TRB->XX_REALN 	:= (ALIAS_TMP)->&cCampoY
		TRB->XX_DIF 	:= ""
		TRB->XX_POWERBK := "S"
		TRB->(Msunlock())
		++nLINHA
	ENDIF


	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|W"+cCusBK+"|"
		nCustoBkP := 0
		nCustoBkP :=  (ALIAS_TMP)->&cCampoX
		nCustoBkR := 0
		nCustoBkR :=  (ALIAS_TMP)->&cCampoY
		cCustoBk := ""
		cCustoBk := (ALIAS_TMP)->XX_DESC
	ENDIF

	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|PREVISTO|"
		nRPREVISTO 	:= 0
		nRPREVISTO 	:= (ALIAS_TMP)->&cCampoX
		nVPREVISTO  := (ALIAS_TMP)->&cCampoZ
	ENDIF
	
	IF nDespGeral == 1 .AND. (nCompras == 0  .OR. nCompras == 1)
		IF SUBSTR((ALIAS_TMP)->XX_CODIGO,1,1) == "W"   .AND. !"|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|W"+cCusBK+"|"
        	//aAdd(aGeral,{(ALIAS_TMP)->XX_CODGCT,(ALIAS_TMP)->XX_DESC,transform((ALIAS_TMP)->&cCampoX,cPict),transform((ALIAS_TMP)->&cCampoY,cPict),transform((((ALIAS_TMP)->&cCampoX - (ALIAS_TMP)->&cCampoY) / (ALIAS_TMP)->&cCampoX * 100)*-1,"@E 99999.99999")+"%"})
        	aAdd(aGeral,{(ALIAS_TMP)->XX_CODGCT,(ALIAS_TMP)->XX_DESC,(ALIAS_TMP)->&cCampoX,(ALIAS_TMP)->&cCampoY,(((ALIAS_TMP)->&cCampoX - (ALIAS_TMP)->&cCampoY) / (ALIAS_TMP)->&cCampoX * 100)*-1})
		ENDIF
	ENDIF


	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|ZZZZZZZZZ|"

		dbSelectArea("TRB")
		//INSUMOS
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
		TRB->XX_COMPET  := cCompet
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "INSUMOS."
		TRB->XX_PROJ 	:= transform(InsumosP,cPict)
		TRB->XX_PROJN 	:= InsumosP
		TRB->XX_REAL 	:= transform(InsumosR-nValTADR-nCustoBkR,cPict)
		TRB->XX_REALN 	:= InsumosR-nValTADR-nCustoBkR
		TRB->XX_DIF 	:= transform((((InsumosP) - (InsumosR-nValTADR-nCustoBkR)) / InsumosP * 100)*-1,"@E 99999.99999")+"%"
		TRB->XX_DIFN 	:= (((InsumosP) - (InsumosR-nValTADR-nCustoBkR)) / InsumosP * 100)*-1
		TRB->XX_POWERBK := "S"
		TRB->(Msunlock())
		++nLINHA

		dbSelectArea("TRB")
		//TAXA DE ADMINISTRAÇÃO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
		TRB->XX_COMPET  := cCompet
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "TAXA DE ADMINISTRAÇÃO DO MÊS"
		TRB->XX_PROJ 	:= transform(nValTADP,cPict)
		TRB->XX_PROJN 	:= nValTADP
		TRB->XX_REAL 	:= transform(nValTADR,cPict)
		TRB->XX_REALN 	:= nValTADR
		TRB->XX_DIF 	:= transform(((nValTADP - nValTADR) / nValTADP * 100)*-1,"@E 99999.99999")+"%"
		TRB->XX_DIFN 	:= ((nValTADP - nValTADR) / nValTADP * 100)*-1
		TRB->XX_POWERBK := "S"
		TRB->(Msunlock())
		++nLINHA

		dbSelectArea("TRB")
		//TAXA DE ADMINISTRAÇÃO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
		TRB->XX_COMPET  := cCompet
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "TAXA DE ADMINISTRAÇÃO ATÉ O MÊS"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform(nTXATMESR,cPict)
		TRB->XX_REALN 	:= nTXATMESR
		TRB->XX_DIF 	:= ""
		TRB->XX_POWERBK := "S"
		TRB->(Msunlock())
		++nLINHA
        
        IF nCustoBKR > 0 .OR. nCustoBKP > 0 // 19/02/19 - Imprimir tambem se houver somente projeção de Custo BK
        	//CUSTO BK
			dbSelectArea("TRB")
 			Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
			TRB->XX_COMPET  := cCompet
 			TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= cCustoBk
			TRB->XX_PROJ 	:= transform(nCustoBKP,cPict)
			TRB->XX_PROJN 	:= nCustoBKP
			TRB->XX_REAL 	:= transform(nCustoBKR,cPict)
			TRB->XX_REALN 	:= nCustoBKR
			TRB->XX_DIF 	:= ""
			TRB->XX_POWERBK := "S"
			TRB->(Msunlock())
			++nLINHA
		ENDIF

/* REMOVIDO LINHA DE TOTAL INSUMOS - Em 04/11/14 - Conforme Marcos Rivera
		dbSelectArea("TRB")
		//TOTAL INSUMOS
 		Reclock("TRB",.T.)
		TRB->XX_LINHA  := nLINHA
		TRB->XX_COMPET  := cCompet
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "TOTAL INSUMOS"
		TRB->XX_PROJ 	:= transform(InsumosP+nValTADP,cPict)
		TRB->XX_REAL 	:= transform(InsumosR+nValTADR,cPict)
		TRB->XX_DIF 	:= transform((((InsumosP+nValTADP) - (InsumosR+nValTADR)) / (InsumosP+nValTADP) * 100)*-1,"@E 99999.99999")+"%"
		TRB->(Msunlock())
		++nLINHA

		nRNTBILP	-= (InsumosP+nValTADP)
		nRNTBILR	-= (InsumosR+nValTADR)

		dbSelectArea("TRB")
		//RENTABILIDADE
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
		TRB->XX_COMPET  := cCompet
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RENTABILIDADE"
		TRB->XX_PROJ 	:= transform(nRNTBILP,cPict)
		TRB->XX_REAL 	:= transform(nRNTBILR,cPict)
		TRB->XX_DIF 	:= transform(((nRNTBILP - nRNTBILR) / nRNTBILP * 100)*-1,"@E 99999.99999")+"%"
		TRB->(Msunlock())
		++nLINHA

*/
		dbSelectArea("TRB")
		//RESULTADO PREVISTO"
		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
		TRB->XX_COMPET  := cCompet
		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RESULTADO PREVISTO"
		TRB->XX_PROJ 	:= transform(nVPREVISTO,cPict)
		TRB->XX_PROJN 	:= nVPREVISTO
		TRB->XX_REAL 	:= ""
		TRB->XX_DIF 	:= transform(nRPREVISTO,"@E 99999.99999")+"%"
		TRB->XX_DIFN 	:= nRPREVISTO
		TRB->XX_POWERBK := "S"
		TRB->(Msunlock())
		++nLINHA


		dbSelectArea("TRB")
		//RESULTADO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
		TRB->XX_COMPET  := cCompet
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RESULTADO DO MÊS - PARCIAL"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform((nFatura*nRDOMES)/100,cPict)
		TRB->XX_REALN 	:= (nFatura*nRDOMES)/100
		TRB->XX_DIF 	:= transform(nRDOMES,"@E 99999.99999")+"%"
		TRB->XX_DIFN 	:= nRDOMES
		TRB->XX_POWERBK := "S"
		TRB->(Msunlock())
		++nLINHA

		dbSelectArea("TRB")
		//RESULTADO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
		TRB->XX_COMPET  := cCompet
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RESULTADO ATÉ O MÊS - PARCIAL"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform((nTotFatMES*nRESULTMES)/100,cPict)
		TRB->XX_REALN 	:= (nTotFatMES*nRESULTMES)/100
		TRB->XX_DIF 	:= transform(nRESULTMES,"@E 99999.99999")+"%"
		TRB->XX_DIFN 	:= nRESULTMES
		TRB->XX_POWERBK := "S"
		TRB->(Msunlock())
		++nLINHA


		dbSelectArea("TRB")
		//RESULTADO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
		TRB->XX_COMPET  := cCompet
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RESULTADO DO MÊS - GLOBAL"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform((nFatura*nRGDOMES)/100,cPict)
		TRB->XX_REALN 	:= (nFatura*nRGDOMES)/100
		TRB->XX_DIF 	:= transform(nRGDOMES,"@E 99999.99999")+"%"
		TRB->XX_DIFN 	:= nRGDOMES
		TRB->XX_POWERBK := "S"
		TRB->(Msunlock())
		++nLINHA 
		
		dbSelectArea("TRB")
		//RESULTADO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
		TRB->XX_COMPET  := cCompet
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RESULTADO ATÉ O MÊS - GLOBAL"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform((nTotFatMES*nRGATMES)/100,cPict)
		TRB->XX_REALN 	:= (nTotFatMES*nRGATMES)/100
		TRB->XX_DIF 	:= transform(nRGATMES,"@E 99999.99999")+"%"
		TRB->XX_DIFN 	:= nRGATMES
		TRB->XX_POWERBK := "S"
		TRB->(Msunlock())
		++nLINHA

/*
		dbSelectArea("TRB")
		//RESULTADO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
		TRB->XX_COMPET  := cCompet
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RESULTADO"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= ""
		TRB->XX_DIF 	:= transform(nRESULT,"@E 99999.99999")+"%"
		TRB->(Msunlock())
		++nLINHA
 */

		cDescFun1 	:= ""
		cJustFun1 	:= ""
		cDFun1 		:= ""
		dbSelectArea ("CND")
		dbSetOrder(1)
		dbSeek(xFilial("CND")+(ALIAS_TMP)->XX_CODGCT)
		DO WHILE CND->(!EOF()) .AND. ALLTRIM(xFilial("CND")+CND->CND_CONTRA) == ALLTRIM(xFilial("CND") + (ALIAS_TMP)->XX_CODGCT) 
			IF ALLTRIM(CND->CND_COMPET) == STRZERO(nMesC,2)+"/"+STRZERO(nAnoC,4)
				cDescFun1 += IIF(cDescFun1 # CND->CND_XXDFUN,CND->CND_XXDFUN,"")
				cJustFun1 += IIF(cJustFun1 # CND->CND_XXJFUN,CND->CND_XXJFUN,"")
				cDFun1    := "Qtd. Postos: "+cValToChar(CND->CND_XXPOST)+" Qtd. Funcionarios: "+cValToChar(CND->CND_XXFUNC)+" Qtd. Func. Atual: "+cValToChar(CND->CND_XXNFUN)
			ENDIF 
			CND->(dbSkip())
		ENDDO
		 
		cDFun :=""		
		FOR nI:= 1 to MLCOUNT(cDescFun1,80)
			cDFun += TRIM(MEMOLINE(cDescFun1,80,nI))+" "
		NEXT
		

		IF !EMPTY(cDFun)
			//REMOVENDO CODIGOS DESCR SEVICO
			cDFun := STRTRAN(cDFun,"|","")
			cDFun := STRTRAN(cDFun,"1 - T","T")
			cDFun := STRTRAN(cDFun,"2 - F","F")
			cDFun := STRTRAN(cDFun,"3 - A","A")
			cDFun := STRTRAN(cDFun,"4 - A","A")
			cDFun := STRTRAN(cDFun,"6 - L","L")
			cDFun := STRTRAN(cDFun,"7 - D","D")
			cDFun := STRTRAN(cDFun,"8 - L","L")
			cDFun := STRTRAN(cDFun,"9 - L","L")

			dbSelectArea("TRB")
			//PULA LINHA
 			Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
			TRB->XX_COMPET  := cCompet
 			TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Qtd. Funcionarios: "
			TRB->XX_PROJ 	:= cDFun1
			TRB->XX_REAL 	:= "Descr.: "+STRTRAN(cDFun,"|","")
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
			++nLINHA
		ENDIF

		cJFun :=""		
		FOR nI:= 1 to MLCOUNT(cJustFun1,80)
			cJFun += TRIM(MEMOLINE(cJustFun1,80,nI))+" "
		NEXT

		IF !EMPTY(cJFun)
			dbSelectArea("TRB")
			//PULA LINHA
 			Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
			TRB->XX_COMPET  := cCompet
 			TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Justificativa Funcionarios"
			TRB->XX_PROJ 	:= cJFun
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
			++nLINHA
		ENDIF
 
		IF nDespGeral == 1   .AND. LEN(aGeral) > 0
		
			dbSelectArea("TRB")
			//PULA LINHA
 			Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
			TRB->XX_COMPET  := cCompet
 			TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= ""
			TRB->XX_PROJ 	:= ""
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())


			dbSelectArea("TRB")
 			Reclock("TRB",.T.)
			TRB->XX_LINHA  := nLINHA
			TRB->XX_COMPET  := cCompet
 			TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "DETALHE DOS INSUMOS"
			TRB->XX_PROJ 	:= ""
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())

			FOR _XI := 1 TO LEN(aGeral)
				IF aGeral[_XI,3] <> 0 .OR. aGeral[_XI,4] <> 0
					dbSelectArea("TRB")
					//GASTOS GERAIS
 					Reclock("TRB",.T.)
					TRB->XX_LINHA   := nLINHA
					TRB->XX_COMPET  := cCompet
 					TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
					TRB->XX_DESC	:= aGeral[_XI,2]
					TRB->XX_PROJ 	:= transform(aGeral[_XI,3],cPict)
					TRB->XX_PROJN 	:= aGeral[_XI,3]
					TRB->XX_REAL 	:= transform(aGeral[_XI,4],cPict)
					TRB->XX_REALN 	:= aGeral[_XI,4]
					TRB->XX_DIF 	:= Transform(aGeral[_XI,5],"@E 99999.99999")+"%"
					TRB->XX_DIFN 	:= aGeral[_XI,5]
					TRB->XX_POWERBK := "S"
				ENDIF
			NEXT

	    ENDIF

		dbSelectArea("TRB")
		//PULA LINHA
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
		TRB->XX_COMPET  := cCompet
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= ""
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= ""
		TRB->XX_DIF 	:= ""
		TRB->(Msunlock())

		nCustoBkP 	:= 0
		nCustoBkR 	:= 0
		InsumosP	:= 0
		nValTADP	:= 0
		InsumosR	:= 0
		nValTADR	:= 0

	ENDIF


 	++nLINHA
 	DbSelectArea(ALIAS_TMP)
	(ALIAS_TMP)->(dbSkip())

	IF cCodigo <> (ALIAS_TMP)->XX_CODGCT .OR. (ALIAS_TMP)->(EOF())

		nTotFat    := 0
		nFatura    := 0
		nTotFatMES := 0
		nTFATDOMES := 0
		nTotCUSTO  := 0
 		cCodigo    := (ALIAS_TMP)->XX_CODGCT
   		nTXATMESR  := 0	
		nRGATMES   := 0
		nRGDOMES   := 0
		nTXMESR    := 0
 	ENDIF

ENDDO

dbSelectArea("TRB")
TRB->(dbgotop())

Return NIL


//GERA RESULTADO SINTETICO - VISAO FINANCEIRO
STATIC FUNCTION Gera2Result()
//Local i		As Numeric
Local _IX	As Numeric
Local nI	As Numeric
Local nJ	As Numeric

/*
//Verifica o Crupo do usuario - visualização do relatorio
PswOrder(1) 
PswSeek(__CUSERID) 
aUser  := PswRet(1)

cCodView := ""
cCodView := SuperGetMV("MV_XXRENTA")


cMaster := ""
cMaster := SuperGetMV("MV_XXGRREN",.F.,"000000/000003/000007/000008/000010/000020")
lMaster := .F.
aGRUPO := {}
aAdd(aGRUPO,aUser[1,10])
FOR i:=1 TO LEN(aGRUPO[1])
	lMaster := (aGRUPO[1,i] $ cMaster)
NEXT
*/

nLINHA := 1
aLINHA := {}
DbSelectArea(ALIAS_TMP)
(ALIAS_TMP)->(dbSetOrder(1))
(ALIAS_TMP)->(dbgotop())
cCodigo  := (ALIAS_TMP)->XX_CODGCT
nBficP 	 := 0
nBficR 	 := 0
nCustoBkP := 0
nCustoBkR := 0
nRNTBILP := 0
nRNTBILR := 0
InsumosP := 0
nValTADP := 0
InsumosR := 0
nValTADR := 0

cCustoBk := ""

cCampoX	:= ""
cCampoX  := "XX_VALP"+STRZERO(nCompet,3)
cCampoY	:= ""
cCampoY  := "XX_VALR"+STRZERO(nCompet,3)

nFatura     := 0
nTotFat 	:= 0
nTotCUSTO 	:= 0
nTotFatMES 	:= 0
nTotalMES  	:= 0
nTFATDOMES 	:= 0
nTXMESR 	:= 0
nTDOMES 	:= 0
nRDOMES 	:= 0
nRESULTMES 	:= 0
nRGDOMES 	:= 0
nRGATMES 	:= 0
nTXATMESR 	:= 0

Do While (ALIAS_TMP)->(!eof())

	nTotal := 0
	nTotalMES := 0
	nTDOMES := 0
	FOR nJ := 1 TO nPeriodo
		IF !("|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|00|01|03-2|02|05-2|06-1|07-1|22-1|30-1|YYYYYYYYZ|")	
			cCampo2		:= ALIAS_TMP+"->XX_VALR"+STRZERO(nJ,3)
	        nTotal		 += &cCampo2
	        IF nJ == nCompet
	        	nRDOMES += &cCampo2
	        	nTDOMES  += &cCampo2
				IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|03|"
			 		cCampo2	:= ALIAS_TMP+"->XX_VALR"+STRZERO(nJ,3)
      				nTXMESR := (&cCampo2 * nTaxaAdm)/100
		    	ENDIF
	        ENDIF
	        IF nJ <= nCompet
	        	nRESULTMES += &cCampo2
	        	nTotalMES  += &cCampo2
	        ENDIF
		ENDIF
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|03|"
			IF nJ <= nCompet
			    cCampo2		:= ALIAS_TMP+"->XX_VALR"+STRZERO(nJ,3)
      			nTXATMESR 	+= (&cCampo2 * nTaxaAdm)/100
		    ENDIF
		ENDIF
	NEXT
 
	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|03|"
        nTotFat := nTotal
        nTotFatMES := nTotalMES
        nTFATDOMES := nTDOMES
	ENDIF	
	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|06|07|08|30|YYYYYYYYY|ZZZZZZZZZ|"
        nRESULT    := Round((nTotal/nTotFat)*100,5)
        nRDOMES    := Round((nTDOMES/nTFATDOMES)*100,5)
        nRESULTMES := Round((nTotalMES/nTotFatMES)*100,5)
        nRGDOMES   := Round(((nTDOMES+nTXMESR)/nTFATDOMES)*100,5)
        nRGATMES   := Round(((nTotalMES+nTXATMESR)/nTotFatMES)*100,5)
 	ENDIF	
 
	IF nConsolida == 1
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|00|"
	    	nRENTABIL	:= 0
			aGeral 		:= {}
			aBenef		:= {}
			FOR _IX := 1 TO LEN(aContConsol)

				dbSelectArea("TRB2")
				//Gravar cabeçalho 
	 			Reclock("TRB2",.T.)
				TRB2->XX_LINHA  := nLINHA
	 			TRB2->XX_CODGCT  := "999999999"
				TRB2->XX_DESC	:= ""
				TRB2->XX_PROJ 	:= "Num. Siga: "+aContConsol[_IX,1] 
				TRB2->XX_REAL 	:= ""
				TRB2->XX_DIF 	:= ""
				TRB2->(Msunlock())
	
		 		++nLINHA
	    	
				dbSelectArea("TRB2")
				//Gravar cabeçalho 
	 			Reclock("TRB2",.T.)
				TRB2->XX_LINHA  := nLINHA
	 			TRB2->XX_CODGCT  := "999999999"
				TRB2->XX_DESC	:= "Cliente:"
				TRB2->XX_PROJ 	:= aContConsol[_IX,2]
				TRB2->XX_REAL 	:= ""
				TRB2->XX_DIF 	:= ""
				aAdd(aFormula2,{TRB2->(RECNO()),"TRB2->XX_PROJ","","C","",""})
				TRB2->(Msunlock())
				
		 		++nLINHA
				dbSelectArea("TRB2")
				//Gravar cabeçalho 
	 			Reclock("TRB2",.T.)
				TRB2->XX_LINHA   := nLINHA
	 			TRB2->XX_CODGCT  := "999999999"
				TRB2->XX_DESC	:= "Contrato:"
				TRB2->XX_PROJ 	:= aContConsol[_IX,3]
				TRB2->XX_REAL 	:= ""
				TRB2->XX_DIF 	:= ""
				aAdd(aFormula2,{TRB2->(RECNO()),"TRB2->XX_PROJ","","C","",""})
				TRB2->(Msunlock()) 
				
		 		++nLINHA
	 			Reclock("TRB2",.T.)
				TRB2->XX_LINHA   := nLINHA
	 			TRB2->XX_CODGCT  :="999999999"
				TRB2->XX_DESC	:= "Gestor Responsável "+FWEmpName(cEmpAnt)+":"
				TRB2->XX_PROJ 	:= aContConsol[_IX,4]
				TRB2->XX_REAL 	:= ""
				TRB2->XX_DIF 	:= ""
				TRB2->(Msunlock())

				nVContrat := 0
        		nVContrat := aScan(aVContrat, {|x| x[1]==aContConsol[_IX,1] })
		 		++nLINHA
	 			Reclock("TRB2",.T.)
				TRB2->XX_LINHA   := nLINHA
	 			TRB2->XX_CODGCT  :="999999999"
				TRB2->XX_DESC	:= "Vigência:"
				TRB2->XX_PROJ 	:= IIF(nVContrat > 0,DTOC(aVContrat[nVContrat,2])+" até "+DTOC(aVContrat[nVContrat,3]),"")
				TRB2->XX_REAL 	:= ""
				TRB2->XX_DIF 	:= ""
				aAdd(aFormula2,{TRB2->(RECNO()),"TRB2->XX_PROJ","","C","",""})
				TRB2->(Msunlock())

			NEXT

	 		Reclock("TRB2",.T.)
			TRB2->XX_LINHA  := nLINHA
	 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB2->XX_DESC	:= "Competência Analisada:"
			TRB2->XX_PROJ 	:= aMeses[nMesC]+"/"+STRZERO(nAnoC,4)
			TRB2->XX_REAL 	:= ""
			TRB2->XX_DIF 	:= ""
			aAdd(aFormula2,{TRB2->(RECNO()),"TRB2->XX_PROJ","","C","",""})
			TRB2->(Msunlock())
	
		 	++nLINHA
	
	 		Reclock("TRB2",.T.)
			TRB2->XX_LINHA   := nLINHA
	 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB2->XX_DESC	:= "Descrição Item"
			TRB2->XX_PROJ 	:= ""
			TRB2->XX_REAL 	:= "Realizado"
			TRB2->XX_DIF 	:= "Diferença %"
			aAdd(aFormula2,{TRB2->(RECNO()),"TRB2->XX_DESC","","S","",""})
			aAdd(aFormula2,{TRB2->(RECNO()),"TRB2->XX_PROJ","","S","",""})
			aAdd(aFormula2,{TRB2->(RECNO()),"TRB2->XX_REAL","","S","",""})
			aAdd(aFormula2,{TRB2->(RECNO()),"TRB2->XX_DIF" ,"","S","",""})
			TRB2->(Msunlock())
		
		ENDIF
	ELSE
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|00|"
	    	nRENTABIL	:= 0
			aGeral 		:= {}
			aBenef		:= {}
			dbSelectArea("TRB2")
			//Gravar cabeçalho 
	 		Reclock("TRB2",.T.)
			TRB2->XX_LINHA   := nLINHA
	 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB2->XX_DESC	:= ""
			TRB2->XX_PROJ 	:= "Num. Siga: "+(ALIAS_TMP)->XX_CODGCT 
			TRB2->XX_REAL 	:= ""
			TRB2->XX_DIF 	:= ""
			TRB2->(Msunlock())
	
		 	++nLINHA
	    	
			dbSelectArea("TRB2")
			//Gravar cabeçalho 
	 		Reclock("TRB2",.T.)
			TRB2->XX_LINHA   := nLINHA
	 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB2->XX_DESC	:= "Cliente:"
			TRB2->XX_PROJ 	:= (ALIAS_TMP)->XX_DESC
			TRB2->XX_REAL 	:= ""
			TRB2->XX_DIF 	:= ""
			TRB2->(Msunlock())
	    ENDIF
	
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|01|"
	 
			dbSelectArea("TRB2")
			//Gravar cabeçalho 
	 		Reclock("TRB2",.T.)
			TRB2->XX_LINHA   := nLINHA
	 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB2->XX_DESC	:= "Contrato:"
			TRB2->XX_PROJ 	:= (ALIAS_TMP)->XX_DESC
			TRB2->XX_REAL 	:= ""
			TRB2->XX_DIF 	:= ""
			TRB2->(Msunlock())
	
	    ENDIF
	
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|02|"
	
	 		Reclock("TRB2",.T.)
			TRB2->XX_LINHA   := nLINHA
	 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB2->XX_DESC	:= "Gestor Responsável "+FWEmpName(cEmpAnt)+":"
			TRB2->XX_PROJ 	:= (ALIAS_TMP)->XX_DESC
			TRB2->XX_REAL 	:= ""
			TRB2->XX_DIF 	:= ""
			TRB2->(Msunlock())
	
			nVContrat := 0
       		nVContrat := aScan(aVContrat,{|x| x[1]==(ALIAS_TMP)->XX_CODGCT })
	 		++nLINHA
 			Reclock("TRB2",.T.)
			TRB2->XX_LINHA  := nLINHA
 			TRB2->XX_CODGCT  :=(ALIAS_TMP)->XX_CODGCT
			TRB2->XX_DESC	:= "Vigência:"
			TRB2->XX_PROJ 	:= IIF(nVContrat > 0,DTOC(aVContrat[nVContrat,2])+" até "+DTOC(aVContrat[nVContrat,3]),"")
			TRB2->XX_REAL 	:= ""
			TRB2->XX_DIF 	:= ""
			aAdd(aFormula2,{TRB2->(RECNO()),"TRB2->XX_PROJ","","C","",""})
			TRB2->(Msunlock())

		 	++nLINHA
	 		Reclock("TRB2",.T.)
			TRB2->XX_LINHA  := nLINHA
	 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB2->XX_DESC	:= "Competência Analisada:"
			TRB2->XX_PROJ 	:= aMeses[nMesC]+"/"+STRZERO(nAnoC,4)
			TRB2->XX_REAL 	:= ""
			TRB2->XX_DIF 	:= ""
			aAdd(aFormula2,{TRB2->(RECNO()),"TRB2->XX_PROJ","","C","",""})
			TRB2->(Msunlock())
	
		 	++nLINHA
	
	 		Reclock("TRB2",.T.)
			TRB2->XX_LINHA  := nLINHA
	 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB2->XX_DESC	:= "Descrição Item"
			TRB2->XX_PROJ 	:= ""
			TRB2->XX_REAL 	:= "Realizado"
			TRB2->XX_DIF 	:= "Diferença %"
			aAdd(aFormula2,{TRB2->(RECNO()),"TRB2->XX_DESC","","S","",""})
			aAdd(aFormula2,{TRB2->(RECNO()),"TRB2->XX_PROJ","","S","",""})
			aAdd(aFormula2,{TRB2->(RECNO()),"TRB2->XX_REAL","","S","",""})
			aAdd(aFormula2,{TRB2->(RECNO()),"TRB2->XX_DIF" ,"","S","",""})
			TRB2->(Msunlock())
		
		ENDIF
    ENDIF
	//calculca a taxa de administração 
	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|03|"
		nFatura := 0
		nFatura := (ALIAS_TMP)->&cCampoY 
		dbSelectArea("TRB2")
		//FATURAMENTO
 		Reclock("TRB2",.T.)
		TRB2->XX_LINHA  := nLINHA
 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB2->XX_DESC	:= TRIM((ALIAS_TMP)->XX_DESC)
		TRB2->XX_PROJ 	:= "" //transform((ALIAS_TMP)->&cCampoX,cPict)
		TRB2->XX_REAL 	:= transform((ALIAS_TMP)->&cCampoY,cPict)
		TRB2->XX_DIF 	:= transform((((ALIAS_TMP)->&cCampoX - (ALIAS_TMP)->&cCampoY) / (ALIAS_TMP)->&cCampoX * 100)*-1,"@E 99999.99999")+"%"
		nValTADP	:=  0
      	nValTADP 	:= ((ALIAS_TMP)->&cCampoX * nTaxaAdm)/100		
		nValTADR	:=  0
      	nValTADR 	:= ((ALIAS_TMP)->&cCampoY * nTaxaAdm)/100		
		TRB2->(Msunlock())
		nRNTBILP	:= 0
		nRNTBILP	:= (ALIAS_TMP)->&cCampoX
		nRNTBILR	:= 0
		nRNTBILR	:= (ALIAS_TMP)->&cCampoY
	ENDIF

/*
	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|09|"
		dbSelectArea("TRB2")
		//PROVENTO
 		Reclock("TRB2",.T.)
		TRB2->XX_LINHA  := nLINHA
 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB2->XX_DESC	:= (ALIAS_TMP)->XX_DESC
		TRB2->XX_PROJ 	:= transform( (ALIAS_TMP)->&cCampoX,cPict)
		TRB2->XX_REAL 	:= transform( (ALIAS_TMP)->&cCampoY,cPict)
		TRB2->XX_DIF 	:= transform((((ALIAS_TMP)->&cCampoX - (ALIAS_TMP)->&cCampoY) / (ALIAS_TMP)->&cCampoX * 100)*-1,"@E 99999.99999")+"%"
		TRB2->(Msunlock())
		nRNTBILP	-=  (ALIAS_TMP)->&cCampoX
		nRNTBILR	-=  (ALIAS_TMP)->&cCampoY
	ENDIF


	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|12|13|14|15|16|17|18|19|20|21|"
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|12|"
			nBficP		:= 0
			nBficR		:= 0
		ENDIF
        nBficP		+= (ALIAS_TMP)->&cCampoX
        nBficR		+= (ALIAS_TMP)->&cCampoY
	ENDIF

	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|19|"
		dbSelectArea("TRB2")
		//BENEFICIOS 
 		Reclock("TRB2",.T.)
		TRB2->XX_LINHA  := nLINHA
 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB2->XX_DESC	:= "BENEFICIOS"
		TRB2->XX_PROJ 	:= transform(nBficP,cPict)
		TRB2->XX_REAL 	:= transform(nBficR,cPict)
		TRB2->XX_DIF 	:= transform(((nBficP - nBficR) / nBficP * 100)*-1,"@E 99999.99999")+"%"
		TRB2->(Msunlock())
		nRNTBILP	-= nBficP
		nRNTBILR	-= nBficR
		nBficP		:= 0
		nBficR		:= 0
	ENDIF

	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|30|"
		InsumosP := 0
		InsumosP :=  (ALIAS_TMP)->&cCampoX
		InsumosR := 0
		InsumosR :=  (ALIAS_TMP)->&cCampoY
	ENDIF

	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|W29104004|"
		nCustoBkP := 0
		nCustoBkP :=  (ALIAS_TMP)->&cCampoX
		nCustoBkR := 0
		nCustoBkR :=  (ALIAS_TMP)->&cCampoY
		cCustoBk := ""
		cCustoBk := (ALIAS_TMP)->XX_DESC
	ENDIF
*/


	// 28/02/20
	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|30-2|"
		dbSelectArea("TRB2")
		//DESCONTO NA NF
 		Reclock("TRB2",.T.)
		TRB2->XX_LINHA   := nLINHA
 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB2->XX_DESC	:= "DESCONTO NA NF"
		TRB2->XX_PROJ 	:= ""
		TRB2->XX_REAL 	:= transform((ALIAS_TMP)->&cCampoY,cPict)
		TRB2->XX_DIF 	:= ""
		TRB2->(Msunlock())
		++nLINHA
	ENDIF

	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|PREVISTO|"
		nRPREVISTO 	:= 0
		nRPREVISTO 	:= (ALIAS_TMP)->&cCampoX
	ENDIF


	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|ZZZZZZZZZ|"
		dbSelectArea("TRB2")
		//RESULTADO PREVISTO"
		Reclock("TRB2",.T.)
		TRB2->XX_LINHA  := nLINHA
		TRB2->XX_CODGCT := (ALIAS_TMP)->XX_CODGCT
		TRB2->XX_DESC	:= "RESULTADO PREVISTO"
		TRB2->XX_PROJ 	:= ""
		TRB2->XX_REAL 	:= ""
		TRB2->XX_DIF 	:= transform(nRPREVISTO,"@E 99999.99999")+"%"
		TRB2->(Msunlock())
		++nLINHA

		dbSelectArea("TRB2")
		//RESULTADO
 		Reclock("TRB2",.T.)
		TRB2->XX_LINHA  := nLINHA
 		TRB2->XX_CODGCT := (ALIAS_TMP)->XX_CODGCT
		TRB2->XX_DESC	:= "RESULTADO DO MÊS - PARCIAL"
		TRB2->XX_PROJ 	:= ""
		TRB2->XX_REAL 	:= transform((nFatura*nRDOMES)/100,cPict)
		TRB2->XX_DIF 	:= transform(nRDOMES,"@E 99999.99999")+"%"
		TRB2->(Msunlock())
		++nLINHA

		dbSelectArea("TRB2")
		//RESULTADO
 		Reclock("TRB2",.T.)
		TRB2->XX_LINHA  := nLINHA
 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB2->XX_DESC	:= "RESULTADO ATÉ O MÊS - PARCIAL"
		TRB2->XX_PROJ 	:= ""
		TRB2->XX_REAL 	:= transform((nTotFatMES*nRESULTMES)/100,cPict)
		TRB2->XX_DIF 	:= transform(nRESULTMES,"@E 99999.99999")+"%"
		TRB2->(Msunlock())
		++nLINHA

		dbSelectArea("TRB2")
		//RESULTADO
 		Reclock("TRB2",.T.)
		TRB2->XX_LINHA  := nLINHA
 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB2->XX_DESC	:= "RESULTADO DO MÊS - GLOBAL"
		TRB2->XX_PROJ 	:= ""
		TRB2->XX_REAL 	:= transform((nFatura*nRGDOMES)/100,cPict)
		TRB2->XX_DIF 	:= transform(nRGDOMES,"@E 99999.99999")+"%"
		TRB2->(Msunlock())
		++nLINHA 
		
		dbSelectArea("TRB2")
		//RESULTADO
 		Reclock("TRB2",.T.)
		TRB2->XX_LINHA  := nLINHA
 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB2->XX_DESC	:= "RESULTADO ATÉ O MÊS - GLOBAL"
		TRB2->XX_PROJ 	:= ""
		TRB2->XX_REAL 	:= transform((nTotFatMES*nRGATMES)/100,cPict)
		TRB2->XX_DIF 	:= transform(nRGATMES,"@E 99999.99999")+"%"
		TRB2->(Msunlock())
		++nLINHA

/*
		dbSelectArea("TRB2")
		//RESULTADO
 		Reclock("TRB2",.T.)
		TRB2->XX_LINHA  := nLINHA
 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB2->XX_DESC	:= "RESULTADO"
		TRB2->XX_PROJ 	:= ""
		TRB2->XX_REAL 	:= ""
		TRB2->XX_DIF 	:= transform(nRESULT,"@E 99999.99999")+"%"
		TRB2->(Msunlock())
		++nLINHA
  */

		cDescFun1 	:= ""
		cJustFun1 	:= ""
		cDFun1 		:= ""
		dbSelectArea ("CND")
		dbSetOrder(1)
		dbSeek(xFilial("CND")+(ALIAS_TMP)->XX_CODGCT)
		DO WHILE CND->(!EOF()) .AND. ALLTRIM(xFilial("CND")+CND->CND_CONTRA) == ALLTRIM(xFilial("CND") + (ALIAS_TMP)->XX_CODGCT) 
			IF ALLTRIM(CND->CND_COMPET) == STRZERO(nMesC,2)+"/"+STRZERO(nAnoC,4)
				cDescFun1 += IIF(cDescFun1 # CND->CND_XXDFUN,CND->CND_XXDFUN,"")
				cJustFun1 += IIF(cJustFun1 # CND->CND_XXJFUN,CND->CND_XXJFUN,"")
				cDFun1    := "Qtd. Postos: "+cValToChar(CND->CND_XXPOST)+" Qtd. Funcionarios: "+cValToChar(CND->CND_XXFUNC)+" Qtd. Func. Atual: "+cValToChar(CND->CND_XXNFUN)
			ENDIF 
			CND->(dbSkip())
		ENDDO
		 
		cDFun :=""		
		FOR nI:= 1 to MLCOUNT(cDescFun1,80)
			cDFun += TRIM(MEMOLINE(cDescFun1,80,nI))+" "
		NEXT
		

		IF !EMPTY(cDFun)
			//REMOVENDO CODIGOS DESCR SEVICO
			cDFun := STRTRAN(cDFun,"|","")
			cDFun := STRTRAN(cDFun,"1 - T","T")
			cDFun := STRTRAN(cDFun,"2 - F","F")
			cDFun := STRTRAN(cDFun,"3 - A","A")
			cDFun := STRTRAN(cDFun,"4 - A","A")
			cDFun := STRTRAN(cDFun,"6 - L","L")
			cDFun := STRTRAN(cDFun,"7 - D","D")
			cDFun := STRTRAN(cDFun,"8 - L","L")
			cDFun := STRTRAN(cDFun,"9 - L","L")

			dbSelectArea("TRB2")
			//PULA LINHA
 			Reclock("TRB2",.T.)
			TRB2->XX_LINHA  := nLINHA
 			TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB2->XX_DESC	:= "Qtd. Funcionarios: "
			TRB2->XX_PROJ 	:= cDFun1
			TRB2->XX_REAL 	:= "Descr.: "+STRTRAN(cDFun,"|","")
			TRB2->XX_DIF 	:= ""
			TRB2->(Msunlock())
			++nLINHA
		ENDIF

		cJFun :=""		
		FOR nI:= 1 to MLCOUNT(cJustFun1,80)
			cJFun += TRIM(MEMOLINE(cJustFun1,80,nI))+" "
		NEXT

		IF !EMPTY(cJFun)
			dbSelectArea("TRB2")
			//PULA LINHA
 			Reclock("TRB2",.T.)
			TRB2->XX_LINHA  := nLINHA
 			TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB2->XX_DESC	:= "Justificativa Funcionarios"
			TRB2->XX_PROJ 	:= cJFun
			TRB2->XX_REAL 	:= ""
			TRB2->XX_DIF 	:= ""
			TRB2->(Msunlock())
			++nLINHA
		ENDIF
 
		dbSelectArea("TRB2")
		//PULA LINHA
 		Reclock("TRB2",.T.)
		TRB2->XX_LINHA  := nLINHA
 		TRB2->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB2->XX_DESC	:= ""
		TRB2->XX_PROJ 	:= ""
		TRB2->XX_REAL 	:= ""
		TRB2->XX_DIF 	:= ""
		TRB2->(Msunlock())

		nCustoBkP 	:= 0
		nCustoBkR 	:= 0
		InsumosP	:= 0
		nValTADP	:= 0
		InsumosR	:= 0
		nValTADR	:= 0

	ENDIF
	
	
 	++nLINHA
 	DbSelectArea(ALIAS_TMP)
	(ALIAS_TMP)->(dbSkip())

	IF cCodigo <> (ALIAS_TMP)->XX_CODGCT .OR. (ALIAS_TMP)->(EOF())
		
		// Grava modelo para diretoria


 		Reclock("TRB3",.T.)
		TRB3->XX_CODGCT := cCodigo
		TRB3->XX_DESC	:= TRIM(Posicione("CN9",1,xFilial("CN9")+cCodigo,"CN9_NOMCLI"))
		TRB3->XX_OBJETO	:= TRIM(Posicione("CN9",1,xFilial("CN9")+cCodigo,"CN9_XXDESC"))
		TRB3->XX_FATRM	:= nFatura
		TRB3->XX_RENTM	:= ((nFatura*nRGDOMES)/100)        //Resultado do Mês em valor - com a taxa de administração
		TRB3->XX_RENTMP	:= nRGDOMES    //Resultado do Mês em percentual - com a taxa de administração
		TRB3->XX_RENTAC	:= ((nTotFatMES*nRGATMES)/100)     //Resultado até o Mês em valor - com a taxa de administração
		TRB3->XX_RENTACP:= nRGATMES  //Resultado até o Mês em percentual - com a taxa de administração
		TRB3->(Msunlock())

		nTotFat    := 0
		nFatura    := 0
		nTotFatMES := 0
		nTFATDOMES := 0
		nTotCUSTO  := 0
 		cCodigo    := (ALIAS_TMP)->XX_CODGCT
   		nTXATMESR  := 0	
		nRGATMES   := 0
		nRGDOMES   := 0
		nTXMESR    := 0
 	ENDIF

ENDDO
                                                                                                                 

dbSelectArea("TRB2")
TRB2->(dbgotop())


Return NIL




STATIC Function GeraCR14(lJob,_cAlias,cArqS,aTitulos,aCampos,aCabs,aImpr,aFormula,aFormat)
Local nHandle
Local cCrLf   	:= Chr(13) + Chr(10)
Local _ni,_nj
Local cPicN  	:= "@E 99999999.99999"
Local cDirTmp	:= "c:\tmp"
Local cArqTmp	:= ""
Local lSoma,aSoma,nCab
Local cLetra	:= ""
Local cTpQuebra	:= ""
Local cQuebra	:= ""
Local aQuebra	:= {}
Local cArqXls   := ""
Local aPlans 	:= {}

Local cMsg		:= ""
Local cEmailTO	:= ""
Local cEmailCC	:= "microsiga@bkconsultoria.com.br"
Local cArqE		:= cArqS+"-"+cEmpAnt

Private xQuebra,xCampo

cEmailTO := LOWER(U_BKGetMv("BKGCTR1411"))

If !Empty(cEmailTO)
	If ! "bruno.bueno" $ cEmailTO
		cEmailTO += ";bruno.bueno@bkconsultoria.com.br"
	EndIf
Else
	cEmailTO := "bruno.bueno@bkconsultoria.com.br"
EndIf

If lJob
	cDirTmp := "\tmp"
EndIf
cArqTmp := cDirTmp+"\"+cArqE+".CSV"

If !lJob
	If MsgYesNo(aTitulos[1]+": Deseja gerar no formato Excel (.xlsx) ?")
		aAdd(aPlans,{_cAlias,cArqS,"",aTitulos,aCampos,aCabs,aImpr,aFormula,aFormat, /*aTotal */, /*cQuebra*/, lClose:= .F. , lJob})
		//cArqXls := U_GeraXlsx(aPlans,"",cArqS, lClose:= .F.,)
		cArqXls := U_PlanXlsx(aPlans,"",cArqS, lClose:= .F.,)
		Return Nil
	EndIf
Else
	u_xxLog(cArqLog,"Gerando planilha xlsx",.T.,"")
	aAdd(aPlans,{_cAlias,cArqS,"",aTitulos,aCampos,aCabs,aImpr,aFormula,aFormat, /*aTotal */, /*cQuebra*/, lClose:= .F. , lJob})
	//cArqXls := U_GeraXlsx(aPlans,"",cArqS, lClose:= .F.,,,.F.,lJob)
	cArqXls := U_PlanXlsx(aPlans,"",cArqS, lClose:= .F.,,,.F.,lJob)
	u_xxLog(cArqLog,"Planilha "+cArqXls+" gerada...",.T.,"")
EndIf

MakeDir(cDirTmp)
fErase(cArqTmp)

lSoma := .F.
aSoma := {}
nCab  := 0

nHandle := MsfCreate(cArqTmp,0)
   
If nHandle > 0
      
	If lJob
		u_xxLog(cArqLog,"Gerando "+cArqTmp+"...",.T.,"")
	EndIf

   FOR _ni := 1 TO LEN(aTitulos)
      fWrite(nHandle, aTitulos[_ni] + cCrLf)
      nCab++
   NEXT
   fWrite(nHandle, cArqE+" - Emitido em: "+DTOC(DATE())+"-"+SUBSTR(TIME(),1,5)+" - "+cUserName + cCrLf)
   nCab++

   FOR _ni := 1 TO LEN(aCabs)
   		IF aCabs[_ni] <> "Linha" //.and. aCabs[_ni] <> "Contrato"
       		fWrite(nHandle, aCabs[_ni] + IIF(_ni < LEN(aCabs),";",""))
     	ENDIF
   NEXT
   nCab++

   fWrite(nHandle, cCrLf ) // Pula linha

   (_cAlias)->(dbgotop())
   Do While (_cAlias)->(!eof())
      IF !lSoma
         For _ni :=1 to LEN(aCampos)
   	         IF SUBSTR(aCampos[_ni],6,8) <> "XX_LINHA" //.AND. SUBSTR(aCampos[_ni],6,9) <> "XX_CODGCT"  
             	xCampo := &(aCampos[_ni])
             	If VALTYPE(xCampo) == "N" // Trata campos numericos                                               
                	cLetra := CHR(_ni+64)
                	IF cLetra > "Z"
                   		cLetra := "A"+CHR(_ni+64-26)
                	ENDIF
                	aAdd(aSoma,'=Soma('+cLetra+ALLTRIM(STR(nCab))+':')
             	Else
                	aAdd(aSoma,"")
             	Endif
             ENDIF
         Next
         lSoma := .T.
      ENDIF
   
      If !lJob
         IncProc("Gerando arquivo "+cArqE)   
	  Else
	     //u_xxLog(cArqLog,"Gerando arquivo "+cArqE,.T.,"")
      EndIf 

      For _ni :=1 to LEN(aCampos)
         IF SUBSTR(aCampos[_ni],6,8) <> "XX_LINHA" //.AND. SUBSTR(aCampos[_ni],6,9) <> "XX_CODGCT"
         	xCampo := &(aCampos[_ni])
         	_uValor := ""
         	If VALTYPE(xCampo) == "D" // Trata campos data
            	_uValor := dtoc(xCampo)
         	Elseif VALTYPE(xCampo) == "N" // Trata campos numericos
            	_uValor := transform(xCampo,cPicN)
         	Elseif VALTYPE(xCampo) == "C"  .AND. SUBSTR(aCampos[_ni],6,6) <> "XX_DIF" .AND. SUBSTR(aCampos[_ni],6,7) <> "XX_REAL" .AND. SUBSTR(aCampos[_ni],6,7) <> "XX_PROJ" // Trata campos caracter
             	//_uValor := xCampo+CHR(160)
            	_uValor := '="'+ALLTRIM(xCampo)+'"'
         	ELSEIF SUBSTR(aCampos[_ni],6,6) == "XX_DIF" .OR. SUBSTR(aCampos[_ni],6,7) =="XX_REAL" .OR. SUBSTR(aCampos[_ni],6,7) == "XX_PROJ" // Trata campos numericos
            	_uValor := xCampo
         	Endif
            
         	fWrite(nHandle, _uValor + IIF(_ni < LEN(aCampos),";",""))
         ENDIF
      Next _ni
      nCab++   
      
      If !EMPTY(cTpQuebra)
         lSoma := .F.
         xQuebra := &(cQuebra)
         Do While !EOF() .AND. xQuebra == &(cQuebra)
            If cTpQuebra == "V"   
	           fWrite(nHandle, cCrLf )
            Endif
            For _nj := 1 To LEN(aQuebra)
		    	IF SUBSTR(aCampos[_ni],6,8) <> "XX_LINHA" //.AND. SUBSTR(aCampos[_ni],6,9) <> "XX_CODGCT"
                 	xCampo := &(aQuebra[_nj,1])
            
                 	_uValor := ""
            
                 	If VALTYPE(xCampo) == "D" // Trata campos data
                    	_uValor := dtoc(xCampo)
                 	Elseif VALTYPE(xCampo) == "N" 
                    	_uValor := transform(xCampo,cPicN)
                 	Elseif VALTYPE(xCampo) == "C"  .AND. SUBSTR(aCampos[_ni],6,6) <> "XX_DIF" .AND. SUBSTR(aCampos[_ni],6,7) <> "XX_REAL" .AND. SUBSTR(aCampos[_ni],6,7) <> "XX_PROJ"  //Trata campos caracter
		            	_uValor := '="'+ALLTRIM(xCampo)+'"'
                 	ELSEIF  SUBSTR(aCampos[_ni],6,6) == "XX_DIF" .OR. SUBSTR(aCampos[_ni],6,7) == "XX_REAL" .OR. SUBSTR(aCampos[_ni],6,7) == "XX_PROJ"  // Trata campos numericos
                    	_uValor := xCampo
                 	Endif
            
            		fWrite(nHandle, _uValor + IIF(_ni < LEN(aQuebra),";",""))
            	ENDIF
            Next _nj
            (_cAlias)->(dbskip())
            
         Enddo
      ENDIF
      fWrite(nHandle, cCrLf )

      (_cAlias)->(dbskip())
         
   Enddo
   IF lSoma
	   FOR _ni := 1 TO LEN(aSoma)
           cLetra := CHR(_ni+64)
           IF cLetra > "Z"
              cLetra := "A"+CHR(_ni+64-26)
           ENDIF
	       IF !EMPTY(aSoma[_ni])
              aSoma[_ni] += cLetra+ALLTRIM(STR(nCab))+')'
	       ENDIF
	       fWrite(nHandle, aSoma[_ni] + IIF(_ni < LEN(aSoma),";",""))
	   NEXT
   ENDIF	
      
   fClose(nHandle)
   If !lJob   
		MsgRun(cArqE,"Aguarde a abertura do Excel...",{|| ShellExecute("open", cArqTmp,"","",1) })
   EndIf

Else
	If !lJob
   		MsgAlert("Falha na criação do arquivo "+cArqTmp)
	Else
		u_xxLog(cArqLog,"Falha na criação do arquivo "+cArqTmp,.T.,"")
	EndIf
Endif

If lJob
	cMsg := aTitulos[1]+CRLF+cStart+" - final: "+DtoC(Date())+" "+Time()
	u_xxLog(cArqLog,cMsg,.T.,"")
	u_BkSnMail("BKGCTR14",FWEmpName(cEmpAnt)+" - "+aTitulos[1],cEmailTO,cEmailCC,cMsg,{cArqXls,cArqTmp})
	u_xxLog(cArqLog,"Email ("+FWEmpName(cEmpAnt)+" - "+aTitulos[1]+") enviado, anexos: "+cArqXls+","+cArqTmp,.T.,"")
EndIf

Return


//Atualizar tabela de custo
Static Function AtualizaCC(lJob)
Local _IX := 0

// Gravar o Semaforo Tabela Centro de Custo
dbSelectArea("SX6")
GetMv("MV_XXSEMAF")
RecLock("SX6",.F.)
SX6->X6_CONTEUD := "S"
msUnlock()

If !lJob 
	IncProc("Atualizando Tabela Centro de Custo...")
Else
    //u_xxLog(cArqLog,"Atualizando Tabela Centro de Custo...",.T.,"")
EndIf

TCSQLExec("EXEC BKIntegraRubi.DBO.PROC_UPD_CUSTO "+cEmpAnt)

If !lJob 
	IncProc("Atualizando Tabela Centro de Custo Consorcios...")
Else
    //u_xxLog(cArqLog,"Atualizando Tabela Centro de Custo Consorcios...",.T.,"")
EndIf

FOR _IX:= 1 TO LEN(aConsorcio)

	TCSQLExec("EXEC BKIntegraRubi.DBO.PROC_UPD_CUSTO "+SUBSTR(ALLTRIM(aConsorcio[_IX,2]),1,2))

NEXT

//Gravar o Semaforo Tabela Centro de Custo
dbSelectArea("SX6")
GetMv("MV_XXSEMAF")
RecLock("SX6",.F.)
SX6->X6_CONTEUD := "N"
msUnlock()
Return


//Montar Tela Para informações de Consolidação
STATIC Function MtaDlg01()
Local aAreaAtu			:= GetArea()
Local oDlg01,aButtons 	:= {},lOk := .F.
Local nSnd    			:= 0,nTLin := 15
Local nSin    			:= 0
Local cConsolida 		:= SPACE(243)
Local aTpCons 	  		:= {}
Local cTpCons           := {}
Local aRet				:= {}
Local cCrLf   			:= Chr(13) + Chr(10)
Local cAtivos			:= "N"
Local aAtivos			:= {}

aAdd(aTpCons,"N° Contrato")
aAdd(aTpCons,"Prefixo")
aAdd(aTpCons,"Sufixo")

aAdd(aAtivos,"Ativos")
aAdd(aAtivos,"Todos")

IF !EMPTY(cContrato)
 	cConsolida := cContrato
ENDIF

//Solicitacao de informacao - consolidação:
  
Define MsDialog oDlg01 Title "Solicitação de Informações - Consolidação:" From 000,000 To 240+(nSin*nTLin),600 Of oDlg01 Pixel

nSnd := 35  // Protheus 12 - P12

@ nSnd,010 SAY "Consolidar por?"   SIZE 080,010 Pixel Of oDlg01
@ nSnd,100 COMBOBOX cTpCons  ITEMS aTpCons SIZE 100,010 Pixel Of oDlg01
nSnd += nTLin

@ nSnd,010 Say 'Informe o(s) Contrato(s)? Obs: separar por  " ; "'                  Size 080,030 Pixel Of oDlg01
//@ nSnd,100 MsGet cConsolida                 Size 100,030 Pixel Of oDlg01
oMemo:= tMultiget():New(nSnd,100,{|u|if(Pcount()>0,cConsolida :=u,cConsolida )},oDlg01,190,18,,,,,,.T.)
nSnd += nTLin

nSnd += nTLin
@ nSnd,010 SAY "Tipo de Contratos?"   SIZE 080,010 Pixel Of oDlg01
@ nSnd,100 COMBOBOX cAtivos  ITEMS aAtivos SIZE 100,010 Pixel Of oDlg01
nSnd += nTLin



ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

If ( lOk ) 
	lOk:=.F.
	cConsolida := STRTRAN(cConsolida,cCrLf,"")
	cConsolida := STRTRAN(cConsolida,",","")
	cConsolida := STRTRAN(cConsolida," ","")
  	aAdd(aRet,{cTpCons,cConsolida,cAtivos})
EndIf

RestArea( aAreaAtu )

Return aRet


Static Function ValidPerg(cPerg)
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}


dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg,10)

aAdd(aRegistros,{cPerg,"01","Contrato?","Contrato?","Contrato?","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
aAdd(aRegistros,{cPerg,"02","Mês Competência?","Mês Competência?","Mês Competência?","mv_ch2","N",02,0,0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
aAdd(aRegistros,{cPerg,"03","Ano Competência?","Ano Competência?","Ano Competência?","mv_ch3","N",04,0,0,"G","NaoVazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
aAdd(aRegistros,{cPerg,"04","%Taxa de Administração?","%Taxa de Administração?" ,"%Taxa de Administração?" ,"mv_ch4","N",10,5,2,"G","NaoVazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
aAdd(aRegistros,{cPerg,"05","Consolidar Contratos?","Consolidar Contratos?","Consolidar Contratos?","mv_ch5","N",01,0,2,"C","","mv_par05","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
aAdd(aRegistros,{cPerg,"06","Consórcio Aplicar Índice Total?","Consórcio Aplicar Índice Total","Consórcio Aplicar Índice Total","mv_ch6","N",01,0,2,"C","","mv_par06","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
aAdd(aRegistros,{cPerg,"07","Rateia Despesas no Cronograma?","Rateia Despesas no Cronograma?","Rateia Despesas no Cronograma?","mv_ch7","N",01,0,1,"C","","mv_par07","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
aAdd(aRegistros,{cPerg,"08","Detalhar ?","Detalhar ?","Detalhar ?","mv_ch8","N",01,0,2,"C","","mv_par08","Benefíc.Desp.Gerais","Benefíc.Desp.Gerais","Benefíc.Desp.Gerais","","","Desp.Gerais","Desp.Gerais","Desp.Gerais","","","Nao Detalhar","Nao Detalhar","Nao Detalhar","","","","","","","","","","","",""})
aAdd(aRegistros,{cPerg,"09","Agendar ?","Agendar ?","Agendar ?","mv_ch9","N",01,0,1,"C","","mv_par09","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
aAdd(aRegistros,{cPerg,"10","Agendar para:" ,"Agendar para:" ,"Agendar para:" ,"mv_cha","D",8,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
aAdd(aRegistros,{cPerg,"11","E-Mail?","E-Mail?","E-Mail?","mv_chb","C",70,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
aAdd(aRegistros,{cPerg,"12","Somente competência atual?","Somente competência atual?","Somente competência atual?","mv_chc","N",01,0,2,"C","","mv_par12","Sim","Sim","Sim","","","Nao","Nao","Nao","","","x Meses","x Meses","x Meses","","","","","","","","","","","",""})

For i:=1 to Len(aRegistros)
	If !dbSeek(cPerg+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()                                                           
			If j <= Len(aRegistros[i])
				FieldPut(j,aRegistros[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(aArea)

Return(NIL)


User Function BKGCTR_14()
	U_BKGCTR14({.T.,.F.})
Return



// Gravar o custo dos Documentos de Entrada por Categoria/Produto
// 19/07/2020
Static Function Grv14CCD1(cAliasTmp,nConsol,cCusto,cPrd,_nI,nValor,aAcrDcr,cOutros,cOutros1,lPRat,cDesc,lRat,nIndDesp)

Local nY := 0
Local nYMes := 0
Local cRet := cOutros
Local lNoRat		:= .F.

Private cCampo2

cCusto := PAD(IIF(nConsol>0,"999999999",cCusto),nTamCodGct)
cPrd   := PAD(cPrd,nTamCodigo)

dbSelectArea(cAliasTmp)
If !dbSeek(cCusto+cPrd,.F.)
	Reclock(ALIAS_TMP,.T.)
	(ALIAS_TMP)->XX_CODGCT := cCusto
	(ALIAS_TMP)->XX_CODIGO := cPrd

	If EMPTY(cDesc)
		(ALIAS_TMP)->XX_DESC := cPrd
	Else
		(ALIAS_TMP)->XX_DESC := ALLTRIM(cDesc)
	EndIf
Else
	Reclock(cAliasTmp,.F.)
EndIf

If nValor <> 0
	If lRat

		// Se for rateio e o titulo for parcelado, não rateia
		If Len(aAcrDcr) > 0
			lNoRat := .T.
		EndIf

		If lPRat // Só fazer no primeiro item do rateio
			// Gravar Acrescimos e Decrescimos Financeiros
			For nY := 1 To Len(aAcrDcr)
				nYMes := ASCAN(aAnoMes,{|x| x == aAcrDcr[nY,1]})
				If nYmes > 0
					cCampo2  := cAliasTmp+"->XX_VALR"+STRZERO(nYMes,3)
					&cCampo2 += aAcrDcr[nY,3]/nIndDesp
					If lNoRat
						&cCampo2 += (aAcrDcr[nY,5]/nIndDesp)
					EndIf		
				EndIf
			Next
		EndIf

		If !lNoRat
			cCampo2  := cAliasTmp+"->XX_VALR"+STRZERO(_nI,3)
			&cCampo2 += nValor
		EndIf

	Else
		For nY := 1 To Len(aAcrDcr)
			nYMes := ASCAN(aAnoMes,{|x| x == aAcrDcr[nY,1]})
			If nYmes > 0
				cCampo2  := cAliasTmp+"->XX_VALR"+STRZERO(nYMes,3)
				&cCampo2 += aAcrDcr[nY,3]
				&cCampo2 += aAcrDcr[nY,5]
			EndIf
		Next
	EndIf
EndIf

(cAliasTmp)->(Msunlock())
cRet := cOutros1

Return cRet

