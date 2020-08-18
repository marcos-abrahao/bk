#INCLUDE "PROTHEUS.CH"  
#INCLUDE "topconn.ch"                     
#include "tbiconn.ch"
                            
//-------------------------------------------------------------------
/*/{Protheus.doc} BKGCTR14()
BK - Rentabilidade dos Contrato - Projeção X Realizado

@author Adilson do Prado
@since 16/05/14 Rev 20/07/20
@version P12
@return Nil
/*/
//-------------------------------------------------------------------

User Function BKGCTR14(aParam)

Local titulo        := "Rentabilidade dos Contratos - Projeção X Realizado"
Local _nI           := 0
Local aDbf 		    := {} //cArqTmp
Local oTmpTb1
Local aDbf2         := {} //,cArqTmp2
Local oTmpTb2
Local cMes          := ""
Local cXXSEMAF		:= "N"
Local aRetCons		:= {}
Local cLogCons   	:= ""
Local cCrLf   		:= Chr(13) + Chr(10) 

// Exemplo a param do schedule: {.F.,.T.,'01','01','000000','004138000002'}
Default aParam 		:= {.F.,.F.}

Private lSintet  	:= .F.
Private lJob 		:= .F.

Private cEmpPar 	:= "01"
Private cFilPar		:= "01"
Private cPerg       := "BKGCTR14"
Private cStart		:= "Início: "+DtoC(Date())+" "+Time()

If Len(aParam) == 2
	lSintet  	:= aParam[1]
	lJob 		:= aParam[2]
Else
	lSintet  	:= aParam[1]
	lJob 		:= aParam[2]
	cEmpPar 	:= aParam[3]
	cFilPar 	:= aParam[4]
	WFPrepEnv(cEmpPar,cFilPar,cPerg,{"CN9"},"GCT")
EndIf

Private aMeses		:= {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
Private aContratos 	:= {}
Private lSintetico  := lSintet

PRIVATE dDataInicio := dDatabase
PRIVATE dDataI		:= dDatabase
PRIVATE dDataFinal  := dDatabase
PRIVATE cSituac     := "05"
PRIVATE	cPict       := "@E 99,999,999,999.99"
PRIVATE nPeriodo    := 1
PRIVATE nPlan       := 1
PRIVATE cContrato   := ""

Private aPeriodo    := {}
Private aAnoMes     := {}
Private aAcrDcr 	:= {}
Private cLastE2     := ""
Private lPRat		:= .T.

Private nTamCodGct	:= 9
Private nTamCodigo	:= 16

PRIVATE nMesC 		:= 0
PRIVATE nAnoC  		:= 0
PRIVATE nMImpContr  := 0
PRIVATE nTaxaAdm    := 0
PRIVATE nEncargos   := 0
PRIVATE nEncarIPT   := 0
PRIVATE nINCIDENCI  := 0
PRIVATE nRateia     := 1
PRIVATE nDespGeral  := 0
PRIVATE nCompras  	:= 0

PRIVATE nCompet		:= 0
PRIVATE cProventos  := ""
PRIVATE cDescontos  := ""
PRIVATE cVT_Prov 	:= ""
PRIVATE cVT_Verb 	:= ""
PRIVATE cVT_Prod   	:= ""
PRIVATE cVRVA_Verb  := ""
PRIVATE cVRVA_Prod  := ""
PRIVATE cASSM_Verb	:= ""
PRIVATE cASSM_Prod	:= ""
PRIVATE cSINO_Verb	:= ""
PRIVATE cSINO_Prod	:= ""
PRIVATE cCCRE_Verb	:= ""
PRIVATE cCCRE_Prod	:= ""
PRIVATE cCDPR_Prod	:= ""
PRIVATE cCDPR_GRUP  := ""
PRIVATE cNINC_Verb	:= ""
PRIVATE aConsorcio	:= {}
PRIVATE lConsorcio  := .F.
PRIVATE lFurnas		:= .F.
PRIVATE lPetro		:= .F.
PRIVATE cExm_Prod	:= ""
PRIVATE cMFG_Prod	:= "" 
PRIVATE cDCH_Prod	:= ""
PRIVATE aHeader	    := {}
PRIVATE aTitulos,aCampos,aCabs,aFormat,aFormula
PRIVATE aCampos2,aCabs2
PRIVATE ALIAS_TMP   := "TMPC"+ALLTRIM(SM0->M0_CODIGO)
PRIVATE cXXPLR 		:= ""
PRIVATE nConsolida	:= 0
PRIVATE nIndConsor	:= 0
PRIVATE nConsol     := 0
PRIVATE cConsolida 	:= ""
PRIVATE aConsolida 	:= {}
PRIVATE aContConsol := {}
PRIVATE cTipoContra := ""
PRIVATE nVContrat 	:= 0
PRIVATE aVContrat	:= {}
PRIVATE aXXMIMPC	:= {}
PRIVATE aMImpContr  := {}
PRIVATE dDtProj 	:= CTOD("")
PRIVATE cSeqProj	:= ""
PRIVATE aFurnas:= {} 
PRIVATE aPetro:= {} 

aFurnas  := U_StringToArray(ALLTRIM(SuperGetMV("MV_XXFURNAS",.F.,"105000381/105000391")), "/" )
//aPetro   := U_StringToArray(ALLTRIM(SuperGetMV("MV_XXPETRO",.F.,"281001455")), "/" )

mv_par03 := YEAR(dDataBase)

If !lJob
	ValidPerg(cPerg)
	If !Pergunte(cPerg,.T.)
		Return Nil
	Endif
Else
	MV_PAR01 := cContrato  	:= ""   // teste "005000114"
	MV_PAR02 := nMesC 		:= MONTH(dDataBase - DAY(dDatabase))
	MV_PAR03 := nAnoC  		:= YEAR(dDataBase - DAY(dDatabase))
	MV_PAR04 := 3
	MV_PAR05 := nConsolida	:= 2
	MV_PAR06 := nIndConsor	:= 1
	MV_PAR07 := nRATEIA     := 2
	MV_PAR08 := nDespGeral  := 1
EndIf

aXXMIMPC	:= {}
aXXMIMPC	:= StrTokArr(GetMv("MV_XXMIMPC"),"|") //%Media de Impostos e Contribuicoes calculo Rentabilidade dos Contratos 
aMImpContr  := {}
FOR IX := 1 TO LEN(aXXMIMPC)
    AADD(aMImpContr,StrTokArr(aXXMIMPC[IX],";"))
NEXT

cContrato  	:= mv_par01
nMesC 		:= mv_par02
nAnoC  		:= mv_par03
nConsolida	:= mv_par05
nIndConsor	:= mv_par06
nRATEIA     := mv_par07
nDespGeral  := mv_par08
IF nDespGeral == 2
	nDespGeral := 1
	nCompras := 1
ENDIF

nMImpContr 	:= VAL(aMImpContr[1,2])                      
nEncargos  	:= GetMv("MV_XXENCAP") 
nEncarIPT	:= GetMv("MV_XXEIPT")  
nINCIDENCI	:= GetMv("MV_XXINCID") 
nTaxaAdm	:= GetMv("MV_XXTXADM") 

                                                                                  
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
					u_xxLog("\TMP\BKGCTR14.LOG","- Contratos não encontrados e será desconsiderado da Consolidação: "+cLogCons,.T.,"")
				ELSE
					IF !MSGYESNO("- Contratos não encontrados e será desconsiderado da Consolidação -" +cCrLf+cCrLf+cLogCons+cCrLf+cCrLf+"Continua?")
						RETURN NIL
					ENDIF
				ENDIF
			ENDIF		
		ENDIF
    ELSE
		IF lJob
			u_xxLog("\TMP\BKGCTR14.LOG","Informações para Consolidar invalida. Verifique!!",.T.,"")
		ELSE
	    	MSGSTOP("Informações para Consolidar invalida. Verifique!!")
		ENDIF
		Return Nil
    ENDIF

ENDIF


cProventos  := GetMv("MV_XXPROVE") //"|1|2|11|34|36|56|60|64|65|68|100|102|104|108|110|126|266|268|270|274|483|600|640|656|664|674|675|685|696|725|726|727|728|729|745|747|749|750|754|755|756|757|758|760|761|762|763|764|765|778|779|787|789|790|791|792|824|"
cDescontos  := GetMv("MV_XXDESCO") //"|112|114|120|122|177|181|187|636|650|680|683|691|780|783|784"
cVT_Prov 	:= GetMv("MV_XXVTPRO") //"|671|"
cVT_Verb 	:= GetMv("MV_XXVTVER") //"|290|667|"
cVT_Prod   	:= GetMv("MV_XXVTPRD") //"|31201046|"
cVRVA_Verb  := GetMv("MV_XXVRVAV") //"|613|614|662|681|682|702| 
cVRVA_Prod  := GetMv("MV_XXVRVAP") //"|31201045|31201047|"
cASSM_Verb	:= GetMv("MV_XXASSMV") //"|605|689|733|734|742|770|771|773|794|796|832|856|"                
cASSM_Prod	:= GetMv("MV_XXASSMP") //"|605|689|709|711|712|719|733|734|742|743|770|771|773|794|796|810|832|833|854|856|857|" 
cSINO_Verb	:= GetMv("MV_XXSINOV") //"|510|607|665|679|724|739|825|900|"
cSINO_Prod	:= GetMv("MV_XXSINOP") //"|510|607|665|679|724|732|739|825|900|"
cCCRE_Verb	:= GetMv("MV_XXCCREV") //"|774|775|776|812|814|"
cCCRE_Prod	:= GetMv("MV_XXCCREP") //"|34202016|"
cCDPR_Prod	:= GetMv("MV_XXCDPRP") //"|320200111|34202034|000000000000112|34202057|34202086|"    cod produtos rateio no contrato
cCDPR_GRUP	:= GetMv("MV_XXCDPRG") //"|0008|0009|0010|"  *********                               cod grupo de produto rateio no contrato
cNINC_Verb	:= "|875|910|"  //GetMv("MV_XXNINCI") //"|875|"  VERBA SEM INCIDENCIAS   
aContrCons	:= {}
aContrCons	:= StrTokArr(ALLTRIM(GetMv("MV_XXCONS1"))+ALLTRIM(GetMv("MV_XXCONS2"))+ALLTRIM(GetMv("MV_XXCONS3"))+ALLTRIM(GetMv("MV_XXCONS4")),"/") //"163000240"
// Rateio        Contrato  x  Produtos                       15/01/20 - Marcos
aRatCtrPrd  := U_DefCtrPrd()

cExm_Prod	:= GetMv("MV_XXCEXMP") //"41201015"
cMFG_Prod	:= GetMv("MV_XXCMFGP") //"31201053"
cDCH_Prod	:= GetMv("MV_XXCDCH") //"34202003"
cXXSEMAF	:= GetMv("MV_XXSEMAF")
cXXPLR	    := SuperGetMV("MV_XXPLR",.F.,"|430|") //|430|

IF EMPTY(cContrato)
	IF lJob
		lConsorcio := .T.
		lFurnas := .T.
		lPetro := .T.
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
ENDIF

FOR IX:= 1 TO LEN(aContrCons)
    AADD(aConsorcio,StrTokArr(aContrCons[IX],";"))
NEXT

//MV_XXASSMP	C	Cod. Prod. desc. assist. medica calculo Rentabilid
//MV_XXASSMV	C	Verba desc. assist. medica calculo Rentabilidade
//MV_XXCONS1	C	Codigo contrato Consorcio BKDAHER calculo Rentabil
//MV_XXCDPRP	C	Cod. Prod. para rateio no calculo de rentabilidade
//MV_XXCDPRG	C	Cod. Prod. para rateio no calculo de rentabilidade
//MV_XXCEXMP	C	Cod. Prod. para rateio no calculo de rentabilidade
//MV_XXCMFGP	C	Cod. Prod. para rateio no calculo de rentabilidade
//MV_XXDESCO	C	Descontos calculo Rentabilidade dos Contratos
//MV_XXPROVE	C	Proventos calculo Rentabilidade dos Contratos
//MV_XXSINOP	C	Cod. Prod. desc. sind. odonto  calculo Rentabilida
//MV_XXSINOV	C	Verba desc. sind. odonto  calculo Rentabilidade
//MV_XXVRVAP	C	COD Produto de TR/VA calculo Rentabilidade
//MV_XXVRVAV	C	Verba desconto de TR/VA calculo Rentabilidade
//MV_XXVTPRD	C	Cod Produto VT custos calculo Rentabilidade
//MV_XXVTVER	C	Verba desconto de VT custos calculo Rentabilidade
//MV_XXSEMAF    C   Semaforo controle de execução da procedure de atualização tabela centro de custo integração Rubi X Microsiga

 		
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
		u_xxLog("\TMP\BKGCTR14.LOG","Atualizando tabela Folha de Pagamento!! - processo abortado.",.T.,"")
	EndIf
ENDIF

IF !EMPTY(cContrato)
	cQuery := " SELECT TOP 1 MIN(CNF_DTVENC) AS CNF_INICIO,MAX(CNF_DTVENC) AS CNF_FIM,CN9_SITUAC"+CRLF
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
	cQuery := " SELECT MIN(CNF_DTVENC) AS CNF_INICIO,MAX(CNF_DTVENC) AS CNF_FIM,CN9_SITUAC"+CRLF
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

u_LogMemo("BKGCTR14.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP1"
TCSETFIELD("QTMP1","CNF_INICIO","D",8,0)	
TCSETFIELD("QTMP1","CNF_FIM","D",8,0)	

dbSelectArea("QTMP1")
dDataI		:= QTMP1->CNF_INICIO
dDataFinal	:= QTMP1->CNF_FIM
cSituac 	:= QTMP1->CN9_SITUAC

QTMP1->(Dbclosearea())

IF EMPTY(DTOS(dDataI)) .OR. EMPTY(DTOS(dDataFinal)) 
	MSGSTOP("Contrato não encontrado!!")
	RETURN NIL
ENDIF

//Determina quantos Meses utilizar no calculo
nPeriodo += DateDiffMonth( dDataI , dDataFinal )

IF lSintetico
	titulo := "Sintético - "+titulo
ENDIF

titulo   := titulo+" - Competencia: "+STRZERO(nMesC,2)+" / "+STRZERO(nAnoC,4)

aDbf := {}
Aadd( aDbf, { 'XX_LINHA' ,'N', 10,00 } )
Aadd( aDbf, { 'XX_CODGCT','C', 09,00 } )
Aadd( aDbf, { 'XX_DESC'  ,'C', 50,00 } )
Aadd( aDbf, { 'XX_PROJ'  ,'C', 200,00 } )
Aadd( aDbf, { 'XX_REAL'  ,'C', 200,00 } )
Aadd( aDbf, { 'XX_DIF'   ,'C', 200,00 } )

///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,'TRB',.f.,.f. )
///IndRegua("TRB",cArqTmp,"XX_LINHA",,,"Indexando Arquivo de Trabalho") 

oTmpTb1 := FWTemporaryTable():New( "TRB" ) 
oTmpTb1:SetFields( aDbf )
oTmpTb1:AddIndex("indice1", {"XX_LINHA"} )
oTmpTb1:Create()

aCabs   := {}
aCampos := {}
aTitulos:= {}
aImpr	:= {}
aFormat := {}
aFormula:= {}

AADD(aTitulos,titulo)

//AADD(aCampos,"TRB->XX_LINHA")
//AADD(aCabs  ,"Linha")
//AADD(aImpr,.T.)
//AADD(aFormat,"")

AADD(aCampos,"TRB->XX_CODGCT")
AADD(aCabs  ,"Contrato")
AADD(aImpr,.T.)
AADD(aFormat,"")

AADD(aCampos,"TRB->XX_DESC")
AADD(aCabs  ,"Descrição")
AADD(aHeader,{"Descrição","XX_DESC" ,"@!",10,00,"","","C","TRB","R"})
AADD(aImpr,.T.)
AADD(aFormat,"")

AADD(aCampos,"TRB->XX_PROJ")
AADD(aCabs  ,"Previsão Financeira")
AADD(aHeader,{"Previsão Financeira","XX_PROJ" ,"@!",20,00,"","","C","TRB","R"})
AADD(aImpr,.T.)
AADD(aFormat,"N")

AADD(aCampos,"TRB->XX_REAL")
AADD(aCabs  ,"Realizado")
AADD(aHeader,{"Realizado","XX_REAL" ,"@!",20,00,"","","C","TRB","R"})
AADD(aImpr,.T.)
AADD(aFormat,"N")

AADD(aCampos,"TRB->XX_DIF")
AADD(aCabs  ,"% Diferença")
AADD(aHeader,{"% Diferença","XX_DIF" ,"@!",10,00,"","","C","TRB","R"})
AADD(aImpr,.T.)
AADD(aFormat,"N")

aDbf2    := {}

nTamCodGct := 9
nTamCodigo := 16

Aadd( aDbf2, { 'XX_CODGCT','C', nTamCodGct,00 } )
Aadd( aDbf2, { 'XX_CODIGO','C', nTamCodigo,00 } )
Aadd( aDbf2, { 'XX_DESC'  ,'C',         50,00 } )
FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,3)
	Aadd( aDbf2, { 'XX_VALP'+cMes,'N', 18,02 } )
	Aadd( aDbf2, { 'XX_VALR'+cMes,'N', 18,02 } )
	Aadd( aDbf2, { 'XX_VL2P'+cMes,'N', 18,02 } )
NEXT

///cArqTmp2 := CriaTrab( aDbf2, .T. )
///dbUseArea( .T.,NIL,cArqTmp2,ALIAS_TMP,.F.,.F. )
///IndRegua(ALIAS_TMP,cArqTmp2,"XX_CODGCT+XX_CODIGO",,,"Indexando Arquivo de Trabalho") 
///dbSetIndex(cArqTmp2+ordBagExt())

oTmpTb2 := FWTemporaryTable():New( ALIAS_TMP ) 
oTmpTb2:SetFields( aDbf2 )
oTmpTb2:AddIndex("indice2", {"XX_CODGCT","XX_CODIGO"} )
oTmpTb2:Create()

aCabs2   := {}
aCampos2 := {}

AADD(aCampos2,ALIAS_TMP+"->XX_CODGCT")
AADD(aCabs2  ,"Contrato")

AADD(aCampos2,ALIAS_TMP+"->XX_CODIGO")
AADD(aCabs2  ,"Cod.Rentab")

AADD(aCampos2,ALIAS_TMP+"->XX_DESC")
AADD(aCabs2  ,"Descrição")

aPeriodo := {}
nCompet		:= 0
dDataInicio := dDataI

FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,3)
	AADD(aCampos2,ALIAS_TMP+"->XX_VALP"+cMes)
	AADD(aCabs2,STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4))
	AADD(aCampos2,ALIAS_TMP+"->XX_VALR"+cMes)
	AADD(aCabs2,STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4))
  	AAdd(aPeriodo,{STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4)})
	AADD(aAnoMes,STRZERO(YEAR(dDataInicio),4)+STRZERO(Month(dDataInicio),2))  
  	IF Month(dDataInicio) == nMesC .AND. YEAR(dDataInicio)== nAnoC
  		nCompet	:= _nI
  	ENDIF
	dDataInicio := MonthSum(dDataInicio,1)
NEXT
If !lJob
	If nCompet <> 0
		ProcRegua(1)
		Processa( {|| ProcR14(lJob) })
		Processa( {|| MBrwR14() })
	Else
		MsgStop("Competencia não encontrada!!")
	EndIf
Else
	If nCompet <> 0
		ProcR14(lJob)
		U_CR14(lJob)
	Else
		u_xxLog("\TMP\BKGCTR14.LOG","Competencia não encontrada : "+STR(nCompet),.T.,"")
	EndIf
EndIf
///(ALIAS_TMP)->(Dbclosearea())
///FErase(cArqTmp2+GetDBExtension())
///FErase(cArqTmp2+OrdBagExt())
oTmpTb2:Delete()

///TRB->(Dbclosearea())
///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())
oTmpTb1:Delete()

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

AADD(aRotina,{"Exp. Excel"	,"U_CR14",0,6})
AADD(aRotina,{"Parametros"	,"U_PR14",0,7})


dbSelectArea(cAlias)
dbSetOrder(1)
	
DEFINE MSDIALOG _oDlgSint ;
TITLE cCadastro ;
From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
_oGetDbSint := MsGetDb():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], 2, "AllwaysTrue()", "AllwaysTrue()",,,,,,"AllwaysTrue()","TRB")
	
aadd(aButton , { "BMPTABLE" , { || U_CR14(.F.), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Gera Planilha Excel" } )
aadd(aButton , { "BMPTABLE" , { || U_PR14(.F.), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Parametros" } )

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

dbSelectArea(cAlias)

If !lJob
	ProcRegua(1)
	Processa( {|| GeraCR14(lJob,cAlias,TRIM(cPerg),aTitulos,aCampos,aCabs,aImpr,aFormula,aFormat)})
Else
	GeraCR14(lJob,cAlias,TRIM(cPerg),aTitulos,aCampos,aCabs,aImpr,aFormula,aFormat)
EndIf

Return Nil

  
 
Static Function ProcR14(lJob)
Local cQuery
Local cProcSZG := ""
Local nIndTC   := 0 
Local nVlp2    := 0
Local nPrev    := 0

LimpaBrw ("TRB")
LimpaBrw (ALIAS_TMP)
If !lJob
	ProcRegua(nPeriodo)
EndIf

FOR _nI := 1 TO nPeriodo

	//nDespesa := 0
	//nDespCon := 0
	If !lJob
		IncProc("Consultando faturamento dos contratos...")
	Else
		u_xxLog("\TMP\BKGCTR14.LOG","Consultando faturamento dos contratos..."+STR(_nI),.T.,"")
	EndIf
   
	//*********Faturamento do Contrato
	cQuery := " SELECT CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CN9_XXNRBK,CNA_XXMUN,CNF_COMPET,SUM(D2_TOTAL) AS D2_TOTAL,SUM(D2_VALISS) AS D2_VALISS, SUM(E5_VALOR) AS E5DESC"+CRLF
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

    cQuery += " INNER JOIN "+RETSQLNAME("SA1")+" SA1 ON CN9.CN9_CLIENT = SA1.A1_COD" +CRLF
    cQuery += "      AND CN9.CN9_LOJACL = SA1.A1_LOJA AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ''"+CRLF

	cQuery += " WHERE CNF.D_E_L_E_T_='' AND CNF.CNF_COMPET='"+aPeriodo[_nI,1]+"' "+CRLF
    IF !EMPTY(cContrato)
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
			cQuery += "AND CN9.CN9_SITUAC ='"+cSituac+"'"+CRLF 	 		
		ENDIF
    ELSE
		cContrCons := ""
 		For IX:= 1 TO LEN(aConsorcio)
 			cContrCons += "'"+ALLTRIM(aConsorcio[IX,1])+"',"
 		NEXT
		IF !lConsorcio
			IF !EMPTY(cContrCons)
   				cQuery += " AND CNF_CONTRA NOT IN ("+SUBSTRING(ALLTRIM(cContrCons),1,LEN(cContrCons)-1)+") "+CRLF //TRATAMENTO ESPECIAL CONTRATO BKDAHER
   			ENDIF
   		ENDIF
		IF !lFurnas
			cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391'"+CRLF
		ENDIF
		IF !lPetro
			cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '455'"+CRLF
		ENDIF
		cQuery += "AND CN9.CN9_SITUAC ='"+cSituac+"'"+CRLF   	 		
    ENDIF	

	cQuery += " GROUP BY CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CN9_XXNRBK,CNA_XXMUN,CNF_COMPET"+CRLF
	cQuery += " ORDER BY CNF_CONTRA"+CRLF
 
	u_LogMemo("BKGCTR14-1.SQL",cQuery)

	If Select("QTMP") > 0
		QTMP->(dbCloseArea())
	EndIf
	TCQUERY cQuery NEW ALIAS "QTMP" 

	dbSelectArea("QTMP")
	QTMP->(dbGoTop())
	DO WHILE QTMP->(!EOF())
	
        nScan:= 0
 		nScan:= aScan(aContConsol,{|x| x[1] =ALLTRIM(QTMP->CNF_CONTRA)})
		IF nScan == 0
			AADD(aContConsol,{ALLTRIM(QTMP->CNF_CONTRA),QTMP->A1_NOME,QTMP->CTT_DESC01,QTMP->CN9_XXNRBK})
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
        AADD(aRentab,{"00","CLIENTE: ","S",QTMP->A1_NOME})              
        AADD(aRentab,{"01","CONTRATO: ","S",QTMP->CTT_DESC01})              
        AADD(aRentab,{"02","GESTOR BK: ","S",QTMP->CN9_XXNRBK})              
        AADD(aRentab,{"03","FATURAMENTO OFICIAL","S",IIF(nIndTC>0,QTMP->D2_TOTAL/(nIndTC/100),QTMP->D2_TOTAL)})              
        AADD(aRentab,{"03-1","","S",0}) 
        AADD(aRentab,{"04","(-) Impostos e Contribuições","S",IIF(nIndTC>0,((QTMP->D2_TOTAL*nMImpContr)/100)/(nIndTC/100),(QTMP->D2_TOTAL*nMImpContr)/100)})            
		IF lISSFURNAS
        	AADD(aRentab,{"05","(-) ISS","S",nISSFURNAS})
        ELSE
        	AADD(aRentab,{"05","(-) ISS","S",IIF(nIndTC>0,QTMP->D2_VALISS/(nIndTC/100),QTMP->D2_VALISS)})            
        ENDIF
        AADD(aRentab,{"05-1","","S",0})
		IF lISSFURNAS
        	AADD(aRentab,{"06","Total dos Impostos + ISS","S",((QTMP->D2_TOTAL*nMImpContr)/100)+nISSFURNAS})              
        ELSE
        	AADD(aRentab,{"06","Total dos Impostos + ISS","S",IIF(nIndTC>0,(((QTMP->D2_TOTAL*nMImpContr)/100)+QTMP->D2_VALISS)/(nIndTC/100),((QTMP->D2_TOTAL*nMImpContr)/100)+QTMP->D2_VALISS)})            
        ENDIF
        AADD(aRentab,{"06-1","","S",0})
		IF lISSFURNAS
        	AADD(aRentab,{"07","FATURAMENTO LÍQUIDO","S",IIF(nIndTC>0,(QTMP->D2_TOTAL-(((QTMP->D2_TOTAL*nMImpContr)/100)+nISSFURNAS))/(nIndTC/100),QTMP->D2_TOTAL-(((QTMP->D2_TOTAL*nMImpContr)/100)+nISSFURNAS))}) 
        ELSE
        	AADD(aRentab,{"07","FATURAMENTO LÍQUIDO","S",IIF(nIndTC>0,(QTMP->D2_TOTAL-(((QTMP->D2_TOTAL*nMImpContr)/100)+QTMP->D2_VALISS))/(nIndTC/100),QTMP->D2_TOTAL-(((QTMP->D2_TOTAL*nMImpContr)/100)+QTMP->D2_VALISS))}) 
		ENDIF
        AADD(aRentab,{"07-1","","S",0})
        AADD(aRentab,{"08","CUSTO","S",0})
        AADD(aRentab,{"09","PROVENTOS","S",0}) 
        AADD(aRentab,{"10","ENCARGOS","S",0}) 
        AADD(aRentab,{"11","INCIDENCIAS","S",0})
        AADD(aRentab,{"110","PLR","S",0}) 
        AADD(aRentab,{"111","VERBAS SEM ENCARGOS/INCIDENCIAS","S",0}) 
        AADD(aRentab,{"12A","BENEFICIOS","S",0}) 
        AADD(aRentab,{"12","VT","S",0}) 
        AADD(aRentab,{"13","(-) Recuperação de VT","S",0}) 
        AADD(aRentab,{"14","VR/VA","S",0}) 
        AADD(aRentab,{"15","(-) Recuperação de VR/VA","S",0}) 
        AADD(aRentab,{"16","ASSMEDICA","S",0}) 
        AADD(aRentab,{"17","(-) Recuperação de ASSMEDICA","S",0}) 
        AADD(aRentab,{"18","Sindicato (Odonto)","S",0}) 
        //AADD(aRentab,{"19","(-) Recuperação de Sindicato (Odonto)","S",0}) 
        AADD(aRentab,{"20","CECREMEF/ADV","S",0}) 
        AADD(aRentab,{"21","(-) CECREMEF/ADV","S",0}) 
        AADD(aRentab,{"22-1","","S",0})
        AADD(aRentab,{"30","GASTOS GERAIS","S",0}) 
		//27/02/20
        AADD(aRentab,{"30-1","","S",0}) 
        AADD(aRentab,{"30-2","DESCONTOS NA NF","S",IIF(nIndTC>0,QTMP->E5DESC/(nIndTC/100),QTMP->E5DESC)}) 

        AADD(aRentab,{"YYYYYYYYY","TAXA DE ADMINISTRAÇÃO","S",0})
        AADD(aRentab,{"YYYYYYYYZ","","S",0}) 
        AADD(aRentab,{"ZZZZZZZZY","RESULTADO PARCIAL","S",0})
        AADD(aRentab,{"ZZZZZZZZZ","RESULTADO GLOBAL","S",0})
		
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
			ENDIF
			IF "|"+aRentab[_nJ,1]+"|" $ "|03|04|05|06|07|30-2|"  // 28/02/20
				cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
				&cCampo2 += aRentab[_nJ,4]
			ENDIF
			//(ALIAS_TMP)->XX_STATUS := QTMP->CN9_SITUAC
			(ALIAS_TMP)->(Msunlock())
        NEXT          
	   	dbSelectArea("QTMP")
	   	QTMP->(dbSkip())
	ENDDO

    QTMP->(dbCloseArea())

	//*********Faturamento do Contrato
	cQuery := " SELECT CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CN9_DTULST,CN9_XXNRBK,CNF_COMPET,SUM(D2_TOTAL) AS D2_TOTAL,SUM(D2_VALISS) AS D2_VALISS, SUM(E5_VALOR) AS E5DESC"+CRLF
	cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF
    cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9.CN9_NUMERO = CNF.CNF_CONTRA AND CN9.CN9_REVISA = CNF.CNF_REVISA AND  CN9.CN9_FILIAL = '"+xFilial("CN9")+"' AND CN9.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+CRLF
	cQuery += " AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA"+CRLF
	cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CND_PARCEL = CNF_PARCEL AND CNA_NUMERO = CND_NUMERO AND CND_REVISA = CNF_REVISA"+CRLF
	cQuery += "      AND  CND.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM"+CRLF
	cQuery += "      AND  C6_FILIAL = CND_FILIAL AND SC6.D_E_L_E_T_ = ''"+CRLF
	cQuery += "	LEFT JOIN "+RETSQLNAME("SD2")+ " SD2 ON SC6.C6_NUM = SD2.D2_PEDIDO AND C6_ITEM = D2_ITEM"+CRLF
	cQuery += "      AND  D2_FILIAL = CND_FILIAL AND SD2.D_E_L_E_T_ = ''"+CRLF
	// 27/02/20   
	cQuery += "LEFT JOIN "+RETSQLNAME("SE5")+" SE5 ON E5_PREFIXO = D2_SERIE AND E5_NUMERO = D2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = D2_CLIENTE AND E5_LOJA = D2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' "+CRLF //--AND E5_PARCELA = '  '
	cQuery += "      AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = '' "+CRLF

    cQuery += " INNER JOIN "+RETSQLNAME("SA1")+" SA1 ON CN9.CN9_CLIENT = SA1.A1_COD" +CRLF
    cQuery += "      AND CN9.CN9_LOJACL = SA1.A1_LOJA  AND  SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ''"

	cQuery += " WHERE CNF.D_E_L_E_T_='' AND CNF.CNF_COMPET='"+aPeriodo[_nI,1]+"' "+CRLF
    IF !EMPTY(cContrato)
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
			cQuery += "AND CN9.CN9_SITUAC ='"+cSituac+"'"+CRLF 		
		ENDIF
    ELSE
		cContrCons := ""
 		For IX:= 1 TO LEN(aConsorcio)
 			cContrCons += "'"+ALLTRIM(aConsorcio[IX,1])+"',"
 		NEXT
		IF !lConsorcio
			IF !EMPTY(cContrCons)
   				cQuery += " AND CNF_CONTRA NOT IN ("+SUBSTRING(ALLTRIM(cContrCons),1,LEN(cContrCons)-1)+") "+CRLF //TRATAMENTO ESPECIAL CONTRATO BKDAHER
   			ENDIF
   		ENDIF
		IF !lFurnas
			cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391'"+CRLF
		ENDIF
		IF !lPetro
			cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '455'"+CRLF
		ENDIF
		cQuery += "AND CN9.CN9_SITUAC ='"+cSituac+"'" +CRLF  	 		
    ENDIF	

	cQuery += " GROUP BY CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CN9_DTULST,CN9_XXNRBK,CNF_COMPET ORDER BY CNF_CONTRA"+CRLF
 
	u_LogMemo("BKGCTR14-CNF-2-"+STRZERO(_nI,3)+".SQL",cQuery)

	TCQUERY cQuery NEW ALIAS "QTMP" 

	dbSelectArea("QTMP")
	QTMP->(dbGoTop())
	DO WHILE QTMP->(!EOF())

        nScan:= 0
 		nScan:= aScan(aContratos,{|x| x = IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))})
		IF nScan == 0
			AADD(aContratos  ,IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA)))
		ENDIF
        
 		FOR _XI := 1 TO nPeriodo
        	IF aPeriodo[_XI,1] == STRZERO(nMesC,2)+"/"+STRZERO(nAnoC,4)  .AND. cProcSZG <> QTMP->CNF_CONTRA
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
				nDespCon := 0
				dDtProj  := CTOD("")
				cSeqProj := ""
        		dbselectArea("SZG")
				cContRev := xFilial("SZG")+ALLTRIM(QTMP->CNF_CONTRA) //+QTMP->CNF_REVISA
				SZG->(dbSeek(cContRev,.T.))
				Do While !EOF() .AND. ALLTRIM(cContRev) == ALLTRIM(SZG->ZG_FILIAL+SZG->ZG_CONTRAT) //+SZG->ZG_REVISAO
					IF SUBSTR(DTOS(SZG->ZG_DATA),1,6) <= STRZERO(nAnoC,4)+STRZERO(nMesC,2)

         				nDespesa := SZG->ZG_CLT+SZG->ZG_VLENCSO+SZG->ZG_AJCUSTO+SZG->ZG_VLENAC+SZG->ZG_BENEFIC+SZG->ZG_UNIFORM+SZG->ZG_DESPDIV+SZG->ZG_MATERIA+SZG->ZG_EQUIPAM+SZG->ZG_VLTRIBU
                        
						// --> Marcos - 03/06/19
					    //VERIFICA INDICE CONSORCIO CASO CONTRATO DE CONSORCIO
       					nIndTC := 0
       					IF nIndConsor == 1
							nScan:= 0
							nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })
	   						IF nScan > 0
	       						nIndTC := VAL(aConsorcio[nScan,6]) 
	    					ENDIF
	    				ENDIF
	    				If nIndTC > 0
							nDespesa := nDespesa / (nIndTC/100)
						EndIf
                        // <-- Marcos - 03/06/19
                        
                        nDespCon    += nDespesa
						dDtProj     := SZG->ZG_DATA
						cSeqProj	:= SZG->ZG_SEQ


  						cQuery := " SELECT SUM(CNF_VLPREV) AS CNF_FATURA"+CRLF
    					cQuery += " FROM "+RETSQLNAME("CNF")+ " CNF"+CRLF
						cQuery += " WHERE CNF.D_E_L_E_T_='' AND CNF.CNF_CONTRA='"+ALLTRIM(QTMP->CNF_CONTRA)+"'AND "+CRLF
						cQuery += "       CNF.CNF_REVISA='"+QTMP->CNF_REVISA+"' AND CNF.CNF_FILIAL = '"+xFilial("CNF")+"'"+CRLF
						cQuery += "       AND CNF.CNF_COMPET='"+aPeriodo[_XI,1]+"'"+CRLF
	      
						TCQUERY cQuery NEW ALIAS "TMPX2"

						dbSelectArea("TMPX2")
						TMPX2->(dbGoTop())
						DO WHILE TMPX2->(!EOF())
						
						    //VERIFICA INDICE CONSORCIO CASO CONTRATO DE CONSORCIO
        					nIndTC := 0
        					IF nIndConsor == 1
								nScan:= 0
								nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })
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
			ENDIF
		NEXT

        IF aPeriodo[_nI,1] == STRZERO(nMesC,2)+"/"+STRZERO(nAnoC,4)

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

			cBK_Prod := ""
			cBK_Prod := "29104004"
        	IF nSZCSTBK <> 0
      			dbSelectArea(ALIAS_TMP)
				IF !dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'W'+cBK_Prod,.F.)
					// 19/02/19 - Marcos - incluir registro se não existir
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF( nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
					(ALIAS_TMP)->XX_CODIGO := "W"+cBK_Prod
					(ALIAS_TMP)->XX_DESC   := Posicione("SB1",1,xFilial("SB1")+cBK_Prod,"B1_DESC")
				Else
  					Reclock(ALIAS_TMP,.F.)
				EndIf

				cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
				&cCampo2 += nSZCSTBK
				(ALIAS_TMP)->(Msunlock())
        	ENDIF

        	IF nDespesa <> 0 .OR. nDespCon <> 0 
      			dbSelectArea(ALIAS_TMP)
				IF !dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'PREVISTO',.F.)
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'PREVISTO'
					(ALIAS_TMP)->XX_CODIGO := "PREVISTO"
					cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
					&cCampo2 += ((nSZG03-nDespesa)*100)/nSZG03

					cCampo2  := ALIAS_TMP+"->XX_VL2P"+STRZERO(_nI,3)
					&cCampo2 += nSZG03 - nDespesa

					u_xxLog("\TMP\BKGCTR14-PREVISTO.TXT",QTMP->CNF_CONTRA+" nDespesa "+STR(nDespesa)+" - nSZG03 "+STR(nSZG03)+" - Previsto "+STR(nSZG03 - nDespesa),.T.,"TESTE")

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
					
					u_xxLog("\TMP\BKGCTR14-PREVISTO.TXT",QTMP->CNF_CONTRA+" nDespesa "+STR(nDespesa)+" - nSZG03 "+STR(nSZG03)+" - Previsto "+STR(nSZG03 - nDespesa),.T.,"TESTE")
					u_xxLog("\TMP\BKGCTR14-PREVISTO.TXT",QTMP->CNF_CONTRA+" nVlp2 "+STR(nVlp2)+" - nSZG03C "+STR(nSZG03C)+" - Previsto "+STR(&cCampo2),.T.,"TESTE")
				ENDIF

				//cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
				//&cCampo2 += ((nSZG03-nDespesa)*100)/nSZG03
				//u_xxLog("\TMP\BKGCTR14-PREVISTO.TXT",QTMP->CNF_CONTRA+" nDespesa "+STR(nDespesa)+" - nSZG03 "+STR(nSZG03)+" - nDespCon "+STR(nDespCon),.F.,"TESTE")
				
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

		ENDIF
		        
        
		//Calcula LF Avulso SZ2 - CLT
		cQuery1 := "SELECT Z2_CODEMP,Z2_CC,Z2_VALOR,Z2_TIPO,Z2_CC FROM "+RETSQLNAME("SZ2")+" SZ2"+CRLF
		cQuery1 += " WHERE  D_E_L_E_T_=''  AND Z2_TIPO IN ('EXM','VT','VR','VA','DCH')"+CRLF  //REMOVIDO MULTA FGTS POR ENTENDER QUE ESTA EM INCIDENCIAS - TIPO = MFG
		cQuery1 += " AND Z2_TIPOPES='CLT' AND Z2_STATUS='S'"+CRLF

		nScan:= 0
		nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })

		IF nScan > 0 
			cQuery1 += " AND Z2_CODEMP='"+SUBSTR(ALLTRIM(aConsorcio[nScan,2]),1,2)+"'" +CRLF
			cQuery1 += " AND Z2_CC IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"','"+ALLTRIM(aConsorcio[nScan,7])+"')" +CRLF
		ELSE
			cQuery1 += " AND Z2_CODEMP='"+SM0->M0_CODIGO+"'"+CRLF
			cQuery1 += " AND Z2_CC='"+ALLTRIM(QTMP->CNF_CONTRA)+"'"+CRLF
		ENDIF
		
		cQuery1 += " AND SUBSTRING(Z2_DATAPGT,1,6)='"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'"+CRLF

		u_LogMemo("BKGCTR14-SZ2-"+STRZERO(_nI,3)+".SQL",cQuery1)

		TCQUERY cQuery1 NEW ALIAS "TMPX2"

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
							SZL->ZL_DESC 	:= Posicione("SB1",1,xFilial("SB1")+cExm_Prod,"B1_DESC")
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
					(ALIAS_TMP)->XX_DESC   := Posicione("SB1",1,xFilial("SB1")+cExm_Prod,"B1_DESC")
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
							SZL->ZL_DESC 	:= Posicione("SB1",1,xFilial("SB1")+cDCH_Prod,"B1_DESC")
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
					(ALIAS_TMP)->XX_DESC   := Posicione("SB1",1,xFilial("SB1")+cDCH_Prod,"B1_DESC")
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
		cBK_Prod := ""
		cBK_Prod := "29104004"
		cQuery1 := "SELECT Z2_CODEMP,Z2_CC,Z2_VALOR,Z2_TIPO,Z2_CC FROM "+RETSQLNAME("SZ2")+" SZ2"
		cQuery1 += " WHERE  D_E_L_E_T_=''  AND Z2_DATAPGT>='20150101' " 
		cQuery1 += " AND Z2_TIPOPES IN ('AC','CLA') AND Z2_STATUS='S'"

		nScan:= 0
		nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })

		IF nScan > 0 
			cQuery1 += " AND Z2_CODEMP='"+SUBSTR(ALLTRIM(aConsorcio[nScan,2]),1,2)+"'" 
			cQuery1 += " AND Z2_CC  IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"','"+ALLTRIM(aConsorcio[nScan,7])+"')" 
		ELSE
			cQuery1 += " AND Z2_CODEMP='"+SM0->M0_CODIGO+"'"
			cQuery1 += " AND Z2_CC='"+ALLTRIM(QTMP->CNF_CONTRA)+"'"
		ENDIF
		
		cQuery1 += " AND SUBSTRING(Z2_DATAPGT,1,6)='"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'"

		TCQUERY cQuery1 NEW ALIAS "TMPX2"

		dbSelectArea("TMPX2")
		dbGoTop()
		DO While !TMPX2->(EOF())

			dbSelectArea(ALIAS_TMP)
   			IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+cBK_Prod,.F.)
				Reclock(ALIAS_TMP,.F.)
			ELSE
				Reclock(ALIAS_TMP,.T.)
				(ALIAS_TMP)->XX_CODGCT := IIF( nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
				(ALIAS_TMP)->XX_CODIGO := "W"+cBK_Prod
				(ALIAS_TMP)->XX_DESC   := Posicione("SB1",1,xFilial("SB1")+cBK_Prod,"B1_DESC")
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
				nINCIDENCI	:= 0
				_IXFUR := LEN(aFurnas)
			ELSE
				nINCIDENCI	:= GetMv("MV_XXINCID") //mv_par05
			ENDIF
		NEXT _IXFUR

		If !lJob
			IncProc("Consultando Folha Pagamento...")
		Else
			u_xxLog("\TMP\BKGCTR14.LOG","Consultando Folha Pagamento..."+STR(_nI),.T.,"")
		EndIf
		//*********Folha Pagamento
		cQuery2 := "select bk_senior.bk_senior.R046VER.CodEve,COUNT(bk_senior.bk_senior.R046VER.CodEve) AS nCont,SUM(bk_senior.bk_senior.R046VER.ValEve) as valevent,"+CRLF
		cQuery2 += " (SELECT TOP 1 [Total] FROM [BKIntegraRubi].[dbo].[EVENTOS_ASS_ODONT] " +CRLF

		nScan:= 0
		nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })

		IF nScan > 0 
			cQuery2 += " where [BKIntegraRubi].[dbo].[EVENTOS_ASS_ODONT].NumEmpr ='"+SUBSTR(ALLTRIM(aConsorcio[nScan,2]),1,2)+"' AND CodTab=1 AND "+CRLF
		ELSE
			cQuery2 += " where [BKIntegraRubi].[dbo].[EVENTOS_ASS_ODONT].NumEmpr ='"+SM0->M0_CODIGO+"' AND CodTab=1 AND "+CRLF
		ENDIF
		cQuery2 += " [BKIntegraRubi].[dbo].[EVENTOS_ASS_ODONT].CodEve=bk_senior.bk_senior.R046VER.CodEve AND "+CRLF
		cQuery2 += " SUBSTRING(CONVERT(VARCHAR,Validade,112),1,6) <= '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"' "+CRLF
		cQuery2 += "  ORDER BY [BKIntegraRubi].[dbo].[EVENTOS_ASS_ODONT].Validade DESC) as VALASSOD "+CRLF
		cQuery2 += " FROM bk_senior.bk_senior.R046VER "+CRLF
		cQuery2 += " INNER JOIN bk_senior.bk_senior.R044cal ON bk_senior.bk_senior.R046VER.NumEmp= bk_senior.bk_senior.R044cal.NumEmp" +CRLF
		cQuery2 += " AND bk_senior.bk_senior.R046VER.CodCal= bk_senior.bk_senior.R044cal.Codcal"+CRLF
		cQuery2 += " INNER JOIN BKIntegraRubi.dbo.CUSTOSIGA ON bk_senior.bk_senior.R046VER.NumEmp= BKIntegraRubi.dbo.CUSTOSIGA.NumEmp"+CRLF
		cQuery2 += " AND bk_senior.bk_senior.R046VER.NumCad = BKIntegraRubi.dbo.CUSTOSIGA.Numcad" +CRLF
 		cQuery2 += " AND bk_senior.bk_senior.R046VER.TipCol = BKIntegraRubi.dbo.CUSTOSIGA.TipCol"+CRLF
 		cQuery2 += " AND bk_senior.bk_senior.R044cal.Codcal = BKIntegraRubi.dbo.CUSTOSIGA.Codcal"+CRLF
 		//TRATAMENTO ESPECIAL CONTRATO BKDAHER

		nScan:= 0
		nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })

		IF nScan > 0 
			cQuery2 += " Where bk_senior.bk_senior.R046VER.NumEmp='"+SUBSTR(ALLTRIM(aConsorcio[nScan,2]),1,2)+"' and Tipcal In(11) And Sitcal = 'T' "+CRLF
 			cQuery2 += " AND PerRef ='"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"01'"+CRLF
			cQuery2 += " AND BKIntegraRubi.dbo.CUSTOSIGA.ccSiga  IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"','"+ALLTRIM(aConsorcio[nScan,7])+"')" +CRLF
		ELSE
			cQuery2 += " Where bk_senior.bk_senior.R046VER.NumEmp='"+SM0->M0_CODIGO+"' and Tipcal In(11) And Sitcal = 'T' "+CRLF
	 		cQuery2 += " AND PerRef ='"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"01'"+CRLF
 			cQuery2 += " AND BKIntegraRubi.dbo.CUSTOSIGA.ccSiga = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'"+CRLF
 		ENDIF

		cQuery2 += " group by bk_senior.bk_senior.R046VER.CodEve"+CRLF

		u_LogMemo("BKGCTR14-FOL-"+STRZERO(_nI,3)+".SQL",cQuery2)
	
		TCQUERY cQuery2 NEW ALIAS "TMPX2"
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
				IF nDespGeral == 1  .AND. nCompras == 0
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
							SZL->ZL_DESC 	:= "Sindicato (Odonto)"
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
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			&cCampo2 += nProventos
			(ALIAS_TMP)->(Msunlock())
    		nCusto += nProventos  
		ENDIF

		FOR _IXFUR:= 1 TO LEN(aFurnas)
			IF SUBSTR(ALLTRIM(QTMP->CNF_CONTRA),7,3) == SUBSTR(aFURNAS[_IXFUR],7,3)
				nEncargos	:= GetMv("MV_XXENCFU") //Encargo Furnas
				_IXFUR := LEN(aFurnas)
			ELSE
				nEncargos  	:= GetMv("MV_XXENCAP") //mv_par03
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
			&cCampo2 += (nProventos*nINCIDENCI)/100
			(ALIAS_TMP)->(Msunlock())
    		nCusto += (nProventos*nINCIDENCI)/100 
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

		If !lJob
			IncProc("Consultando Folha Pagamento - Autonomos...")
		Else
			u_xxLog("\TMP\BKGCTR14.LOG","Consultando Folha Pagamento - Autonomos..."+STR(_nI),.T.,"")
		EndIf
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
			cQuery2 += " AND codEmpresa='"+SM0->M0_CODIGO+"'"
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
		cQuery3 := " SELECT MIN(CNF_DTVENC) AS CNF_INICIO,MAX(CNF_DTVENC) AS CNF_FIM"
		cQuery3 += " FROM "+RETSQLNAME("CNF")+" CNF"
		cQuery3 += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA"
		cQuery3 += " AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = '' WHERE CNF.D_E_L_E_T_=''"
		cQuery3 += " AND CN9_NUMERO = '"+ALLTRIM(QTMP->CNF_CONTRA)+"' AND CN9_SITUAC ='"+cSituac+"'" 

		TCQUERY cQuery3 NEW ALIAS "QTMPX3"
		TCSETFIELD("QTMPX3","CNF_INICIO","D",8,0)	
		TCSETFIELD("QTMPX3","CNF_FIM","D",8,0)	

		dbSelectArea("QTMPX3")
		dDataVenc := QTMPX3->CNF_FIM
        
        nVContrat := 0
        nVContrat := aScan(aVContrat, {|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA)})
 		IF nVContrat == 0
			AADD(aVContrat,{ALLTRIM(QTMP->CNF_CONTRA),QTMPX3->CNF_INICIO,QTMPX3->CNF_FIM,0})
        ENDIF
        
		QTMPX3->(Dbclosearea())

		nScan:= 0
		nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })
		If !lJob
			IncProc("Consultando gastos gerais..."+STRZERO(_nI,3))
		Else
			u_xxLog("\TMP\BKGCTR14.LOG","Consultando gastos gerais..."+STR(_nI),.T.,"")
		EndIf
		
		//*********GASTOS GERAIS
		cQuery2 := "SELECT D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC,SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) AS D1_TOTAL"+CRLF
		cQuery2 += " FROM "+RETSQLNAME("SD1")+" SD1" +CRLF
		cQuery2 += " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D1_COD = B1_COD  AND SB1.D_E_L_E_T_ = '' "+CRLF
		cQuery2 += " WHERE SUBSTRING(D1_DTDIGIT,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"' AND SD1.D_E_L_E_T_ = '' "+CRLF
		cQuery2 += " AND D1_CC = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'" +CRLF
//		cQuery2 += IIF(nScan > 0," AND SUBSTRING(D1_CONTA,1,3) <> '113' "," AND (SUBSTRING(D1_CONTA,1,1) = '3' OR D1_CONTA in ('29104004','12201006','12201005','12201010'))") 
		cQuery2 += IIF(nScan > 0," AND SUBSTRING(D1_CONTA,1,3) <> '113' "," AND (SUBSTRING(D1_CONTA,1,1) = '3' OR D1_CONTA in ('29104004') OR SUBSTRING(D1_CONTA,1,5) = '12201')") +CRLF
		IF SM0->M0_CODIGO == "01"  .AND. ALLTRIM(QTMP->CNF_CONTRA)=="313000504" // Despesas médicas 
			cQuery2 += " AND D1_FORNECE<>'002918'"
		ENDIF 
		IF SM0->M0_CODIGO == "14"   // Despesas médicas
			cQuery2 += " AND D1_FORNECE<>'000604'"
		ENDIF 
		
		//// Para teste de alugueis: 
		//cQuery2 += " AND (D1_COD = '000000000000102' OR D1_COD = '320200301')  "+CRLF // AND D1_FORNECE = '004190'

		IF nCompras == 1
			cQuery2 += " AND D1_PEDIDO <> ''"
		ENDIF
		cQuery2 += " GROUP BY D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC"

		cQuery2 += " UNION ALL"
		cQuery2 += " SELECT D3_FILIAL,MAX(' '),MAX(' '),MAX(' '),MAX(' '),D3_COD,B1_DESC,B1_GRUPO,D3_CC,SUM(D3_CUSTO1) FROM "+RETSQLNAME("SD3")+" SD3"
		cQuery2 += " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D3_COD = B1_COD  AND SB1.D_E_L_E_T_ = '' "+CRLF
		cQuery2 += " WHERE SD3.D_E_L_E_T_='' AND D3_TM='5"+SM0->M0_CODIGO+"' AND SUBSTRING(D3_EMISSAO,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'" 
		cQuery2 += " AND D3_CC = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'"
//		cQuery2 += IIF(nScan > 0," AND SUBSTRING(D3_CONTA,1,3) <> '113' "," AND (SUBSTRING(D3_CONTA,1,1) = '3' OR D3_CONTA in ('29104004','12201006','12201005','12201010'))") 
		cQuery2 += IIF(nScan > 0," AND SUBSTRING(D3_CONTA,1,3) <> '113' "," AND (SUBSTRING(D3_CONTA,1,1) = '3' OR D3_CONTA in ('29104004') OR SUBSTRING(D3_CONTA,1,5) = '12201')") 
		cQuery2 += " GROUP BY D3_FILIAL,D3_COD,B1_DESC,B1_GRUPO,D3_CC"

		//cQuery2 += " ORDER BY B1_DESC"
        
		TCQUERY cQuery2 NEW ALIAS "TMPX2"

		u_LogMemo("BKGCTR14-D1-1-"+STRZERO(_nI,3)+".SQL",cQuery2)        
				
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
				EndIf
			Else
				aAcrDcr := {}
			EndIf
			//<--- Fim: Buscar Acrescimos e Decrescimos Financeiros da NFE

			dbSelectArea("TMPX2")

			cOutros := 'S'
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

				cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'12',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,"N",.T.,"")
				cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,"")
		   		
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

				cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'14',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,"N",.T.,"")
				cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,"")

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
			//CECREMEF
			IF "|"+ALLTRIM(TMPX2->D1_COD)+"|" $ cCCRE_Prod
				cVALGG := 0
				IF nDespGeral == 1  .AND. nCompras == 0
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

				cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'20',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,"N",.T.,"")
				cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,"")

				/*
		   		dbSelectArea(ALIAS_TMP)
		   		IF dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'20',.F.)
		     		Reclock(ALIAS_TMP,.F.)
		  //			cCampo2  := ALIAS_TMP+"->XX_VALP"+STRZERO(_nI,3)
		  //			&cCampo2 += cVALGG
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
			
			IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cCDPR_Prod .OR.  "|"+ALLTRIM(TMPX2->B1_GRUPO)+"|" $ cCDPR_GRUP;
				 	.OR. U_RatCtrPrd(ALLTRIM(TMPX2->D1_CC),ALLTRIM(TMPX2->D1_COD),aRatCtrPrd)

            	//BUSCA GASTOS GERAIS NA PROJEÇÃO FINANCEIRA - RATEIO
				cVALGG := 0
				IF nDespGeral == 1 .AND. ( nCompras == 0 .or. nCompras == 1)  
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
				IF nRATEIA == 1 .OR. U_RatCtrPrd(ALLTRIM(TMPX2->D1_CC),ALLTRIM(TMPX2->D1_COD),aRatCtrPrd)
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

					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+TMPX2->D1_COD,_nI, 0 ,aAcrDcr,cOutros,cOutros,.F.,TMPX2->B1_DESC)

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
					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+cCodCC,_nI, 0 ,aAcrDcr,cOutros,cOutros,.F.,cCodCC)
					
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

					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',XI_,nValRat,aAcrDcr,cOutros,cOutros,lPRat,"")

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

						cOutros := Grv14CCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,"W"+TMPX2->D1_COD,XI_,nValRat,aAcrDcr,cOutros,cOutros,lPRat,TMPX2->B1_DESC)
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
						cOutros := Grv14CCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,"W"+cCodCC,XI_,nValRat,aAcrDcr,cOutros,cOutros,lPRat,cCodCC)
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

				cOutros := Grv14CCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,"W"+TMPX2->D1_COD,_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,TMPX2->B1_DESC)
				cOutros := Grv14CCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'30',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,"")

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
			cQuery2 := "SELECT D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC,SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) AS D1_TOTAL"
			cQuery2 += " FROM SD1"+ALLTRIM(aConsorcio[nScan,2])+" SD1" 
			//cQuery2 += " INNER JOIN SA2"+ALLTRIM(aConsorcio[nScan,2])+" SA2 ON D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ''" 
			cQuery2 += " INNER JOIN SB1"+ALLTRIM(aConsorcio[nScan,2])+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D1_COD = B1_COD  AND SB1.D_E_L_E_T_ = ''"                                         
			//cQuery2 += " INNER JOIN CTT"+ALLTRIM(aConsorcio[nScan,2])+" CTT ON D1_FILIAL = CTT_FILIAL AND D1_CC = CTT_CUSTO AND CTT.D_E_L_E_T_ = ''"
			cQuery2 += " WHERE SUBSTRING(D1_DTDIGIT,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"' AND SD1.D_E_L_E_T_ = '' "
			//cQuery2 += " AND D1_CC = '000000001'"
			IF SM0->M0_CODIGO == "01" .AND. ALLTRIM(QTMP->CNF_CONTRA)=="313000504" // Despesas médicas 
				cQuery2 += " AND D1_FORNECE<>'002918'"
			ENDIF 
			IF SM0->M0_CODIGO == "14"   // Despesas médicas
				cQuery2 += " AND D1_FORNECE<>'000604'"
			ENDIF 
			IF ALLTRIM(aConsorcio[nScan,2]) == "140"
				cQuery2 += " AND D1_CC IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"')" 
			ELSE
				cQuery2 += " AND D1_CC IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"','"+ALLTRIM(aConsorcio[nScan,7])+"')" 
			ENDIF
			cQuery2 += " AND SUBSTRING(D1_CONTA,1,1) <> '2' AND SUBSTRING(D1_CONTA,1,3) <> '113' "
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
						aAcrDcr := u_fAcrDcr()
					EndIf
				Else
					aAcrDcr := {}
				EndIf
				//<--- Fim: Buscar Acrescimos e Decrescimos Financeiros da NFE
				
				dbSelectArea("TMPX2")

				cOutros := 'S'
				nAuxVl  := IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)

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

					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'12',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"")
					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"")

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

					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'14',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"")
					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"")

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
                //CECREMEF
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

					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'20',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"")
					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"")
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
	   				IF nRATEIA == 1	.OR. U_RatCtrPrd(ALLTRIM(TMPX2->D1_CC),ALLTRIM(TMPX2->D1_COD),aRatCtrPrd)
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

						cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+TMPX2->D1_COD,_nI, 0 ,aAcrDcr,cOutros,cOutros,.F.,TMPX2->B1_DESC)

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
						cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+cCodCC,_nI, 0 ,aAcrDcr,cOutros,cOutros,.F.,cCodCC)

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
					nAuxVl := IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)

				    FOR XI_ := _nI TO nParcela

						cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,"")

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

							cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+TMPX2->D1_COD,XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,TMPX2->B1_DESC)
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
							cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+cCodCC,XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,cCodCC)

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

					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+TMPX2->D1_COD,_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,TMPX2->B1_DESC)
					cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"")
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
	        
			TCQUERY cQuery2 NEW ALIAS "TMPX2"
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

				cQuery2 := "SELECT DISTINCT D1_FILIAL,D1_COD,B1_DESC,B1_GRUPO,D1_CC,SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) AS D1_TOTAL"
				cQuery2 += " FROM SD1"+ALLTRIM(aConsorcio[nScan,8])+" SD1" 
				cQuery2 += " INNER JOIN SA2"+ALLTRIM(aConsorcio[nScan,8])+" SA2 ON D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ''" 
				cQuery2 += " INNER JOIN SB1"+ALLTRIM(aConsorcio[nScan,8])+" SB1 ON D1_COD = B1_COD  AND SB1.D_E_L_E_T_ = ''"                                         
				cQuery2 += " INNER JOIN CTT"+ALLTRIM(aConsorcio[nScan,8])+" CTT ON D1_FILIAL = CTT_FILIAL AND D1_CC = CTT_CUSTO AND CTT.D_E_L_E_T_ = ''"
				cQuery2 += " WHERE SUBSTRING(D1_DTDIGIT,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"' AND SD1.D_E_L_E_T_ = '' "
				cQuery2 += " AND SUBSTRING(D1_CONTA,1,1) <> '2' AND SUBSTRING(D1_CONTA,1,3) <> '113' "
				IF SM0->M0_CODIGO == "01"  .AND. ALLTRIM(QTMP->CNF_CONTRA)=="313000504" // Despesas médicas 
					cQuery2 += " AND D1_FORNECE<>'002918'"
				ENDIF 
				IF SM0->M0_CODIGO == "14"   // Despesas médicas
					cQuery2 += " AND D1_FORNECE<>'000604'"
				ENDIF 
				IF nCompras == 1
					cQuery2 += " AND D1_PEDIDO <> ''"
				ENDIF 
				cQuery2 += " AND D1_CC = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'"
				cQuery2 += " GROUP BY  D1_FILIAL,D1_COD,B1_DESC,B1_GRUPO,D1_CC"
				//cQuery2 += " ORDER BY B1_DESC"
		        
				TCQUERY cQuery2 NEW ALIAS "TMPX2"

				//u_xxLog("\TMP\BKGCTR14-D1-2.SQL",cQuery2,.F.,"TESTE")        

				cOutros := 'S'
				dbSelectArea("TMPX2")
				dbGoTop()
				DO While !TMPX2->(EOF()) 
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
	                //CECREMEF
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
		   				IF nRATEIA == 1 .OR. U_RatCtrPrd(ALLTRIM(TMPX2->D1_CC),ALLTRIM(TMPX2->D1_COD),aRatCtrPrd)
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

						nAuxVl := IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)

					    FOR XI_ := _nI TO nParcela

							cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,"")

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

								cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+TMPX2->D1_COD,XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,TMPX2->B1_DESC)

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
								cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+cCodCC,XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,cCodCC)

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
	
						cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+TMPX2->D1_COD,_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,TMPX2->B1_DESC)
						cOutros := Grv14CCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"")


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
		        
				TCQUERY cQuery2 NEW ALIAS "TMPX2"
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
	        
			TCQUERY cQuery2 NEW ALIAS "TMPX2"
			
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

		If !lJob
			IncProc("Consultando faturamento de medições avulsas...")
		Else
			u_xxLog("\TMP\BKGCTR14.LOG","Consultando faturamento de medições avulsas..."+STR(_nI),.T.,"")
		EndIf
		
		//********* FATURAMENTO - Inclusão para medição avulso
		cQuery2 := "SELECT C5_ESPECI1,A1_NOME,CTT_DESC01,SUM(D2_TOTAL) AS D2_TOTAL,SUM(D2_VALISS) AS D2_VALISS, SUM(E5_VALOR) AS E5DESC"
		cQuery2 += " FROM "+RETSQLNAME("SC5")+" SC5" 
		cQuery2 += " INNER JOIN "+RETSQLNAME("SC6")+" SC6 ON SC5.C5_NUM = SC6.C6_NUM" 
		
	    cQuery2 += " INNER JOIN "+RETSQLNAME("SD2")+" SD2 ON C6_NUM = D2_PEDIDO AND C6_ITEM = D2_ITEM"
		cQuery2 += " AND  SD2.D2_FILIAL = '"+xFilial("SD2")+"'  AND  SD2.D_E_L_E_T_ = ''"
	    
		// 27/02/20   
		cQuery2 += "LEFT JOIN "+RETSQLNAME("SE5")+" SE5 ON E5_PREFIXO = D2_SERIE AND E5_NUMERO = D2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = D2_CLIENTE AND E5_LOJA = D2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " //--AND E5_PARCELA = '  '
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
	        AADD(aRentab,{"00","CLIENTE: ","S",TMPX2->A1_NOME})              
	        AADD(aRentab,{"01","CONTRATO: ","S",TMPX2->CTT_DESC01})              
	        AADD(aRentab,{"02","Gestor BK: ","S",""})              
			//AADD(aRentab,{"03","FATURAMENTO OFICIAL","S",TMPX2->D2_TOTAL})    
			AADD(aRentab,{"03","FATURAMENTO OFICIAL","S",IIF(nIndTC>0,TMPX2->D2_TOTAL/(nIndTC/100),TMPX2->D2_TOTAL)})              
			          
	        AADD(aRentab,{"03-1","","S",0}) 
			//AADD(aRentab,{"04","(-) Impostos e Contribuições","S",(TMPX2->D2_TOTAL*nMImpContr)/100})  
			AADD(aRentab,{"04","(-) Impostos e Contribuições","S",IIF(nIndTC>0,((TMPX2->D2_TOTAL*nMImpContr)/100)/(nIndTC/100),(TMPX2->D2_TOTAL*nMImpContr)/100)})            
			          
			//AADD(aRentab,{"05","(-) ISS","S",TMPX2->D2_VALISS}) 
        	AADD(aRentab,{"05","(-) ISS","S",IIF(nIndTC>0,TMPX2->D2_VALISS/(nIndTC/100),TMPX2->D2_VALISS)})            
			           
	        AADD(aRentab,{"05-1","","S",0}) 
	        //AADD(aRentab,{"06","Total dos Impostos + ISS","S",((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS})            
        	AADD(aRentab,{"06","Total dos Impostos + ISS","S",IIF(nIndTC>0,(((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS)/(nIndTC/100),((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS)})            

			AADD(aRentab,{"06-1","","S",0}) 
			//AADD(aRentab,{"07","FATURAMENTO LÍQUIDO","S",TMPX2->D2_TOTAL-(((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS)}) 
        	AADD(aRentab,{"07","FATURAMENTO LÍQUIDO","S",IIF(nIndTC>0,(TMPX2->D2_TOTAL-(((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS))/(nIndTC/100),TMPX2->D2_TOTAL-(((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS))}) 
			
	        AADD(aRentab,{"07-1","","S",0}) 
	        AADD(aRentab,{"08","CUSTO","S",0}) 
	        AADD(aRentab,{"09","PROVENTOS","S",0}) 
	        AADD(aRentab,{"10","ENCARGOS","S",0}) 
	        AADD(aRentab,{"11","INCIDENCIAS","S",0}) 
	        AADD(aRentab,{"110","PLR","S",0}) 
        	AADD(aRentab,{"111","VERBAS SEM ENCARGOS/INCIDENCIAS","S",0}) 
	        AADD(aRentab,{"12","VT","S",0}) 
	        AADD(aRentab,{"13","(-) Recuperação de VT","S",0}) 
	        AADD(aRentab,{"14","VR/VA","S",0}) 
	        AADD(aRentab,{"15","(-) Recuperação de VR/VA","S",0}) 
	        AADD(aRentab,{"16","ASSMEDICA","S",0}) 
	        AADD(aRentab,{"17","(-) Recuperação de ASSMEDICA","S",0}) 
	        AADD(aRentab,{"18","Sindicato (Odonto)","S",0}) 
	        //AADD(aRentab,{"19","(-) Recuperação de Sindicato (Odonto)","S",0}) 
        	AADD(aRentab,{"20","CECREMEF/ADV","S",0}) 
        	AADD(aRentab,{"21","(-) CECREMEF/ADV","S",0}) 
	        AADD(aRentab,{"22-1","","S",0}) 
	        AADD(aRentab,{"30","GASTOS GERAIS","S",0}) 
	        AADD(aRentab,{"30-1","","S",0}) 
	        AADD(aRentab,{"30-2","DESCONTOS NA NF","S",IIF(nIndTC>0,TMPX2->E5DESC/(nIndTC/100),TMPX2->E5DESC)}) 
	        AADD(aRentab,{"YYYYYYYYY","TAXA DE ADMINISTRAÇÃO","S",0})
	        AADD(aRentab,{"YYYYYYYYZ","","S",0}) 
        	AADD(aRentab,{"ZZZZZZZZY","RESULTADO PARCIAL","S",0})
        	AADD(aRentab,{"ZZZZZZZZZ","RESULTADO GLOBAL","S",0})
			
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
				IF "|"+aRentab[_nJ,1]+"|" $ "|03|04|05|06|07|30-2|"
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


//CALCULA RESULTADOS

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
	FOR _nI := 1 TO nPeriodo
		If !lJob
			IncProc("Calculando resultados...")
		Else
			u_xxLog("\TMP\BKGCTR14.LOG","Calculando resultados..."+STR(_nI),.T.,"")
		EndIf
		
		//CALCULA TAXA ADM
        nValTaxaAdm := 0
		dbSelectArea(ALIAS_TMP)
		IF dbSeek(ALLTRIM(aContratos[Yi_])+'03',.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
        	nValTaxaAdm := (&cCampo2*nTaxaAdm)/100 
		ENDIF
		
		//GRAVA TAXA ADM
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
		
		//SOMA TAXA ADM NOS GASTOS GERAIS
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

		//SOMA DESCONTOS DO SE5 NOS GASTOS GERAIS 28/02/20
	    nDescE5 := 0
		dbSelectArea(ALIAS_TMP)
		IF dbSeek(ALLTRIM(aContratos[Yi_])+'30-2',.F.)
   			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VALR"+STRZERO(_nI,3)
			nDescE5  := &cCampo2

			nResultado -= nDescE5
			n2Resultado -= nDescE5

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

//GERA TIPO DE RELATORIO SINTETICO OU NORMAL
IF lSintetico 
	Gera2Result()
ELSE
	GeraResult()
ENDIF

RETURN NIL


STATIC FUNCTION GeraResult()

Local aGeral := {}
Local aBenef := {}

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
//AADD(aGRUPO,aUser[1,10])
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
nDescE5  := 0
nValTADP := 0
InsumosR := 0
nValTADR := 0
nTXATMESR:= 0
nTXMESR  := 0
cCustoBk := ""
cCampoX	:= ""
cCampoX  := "XX_VALP"+STRZERO(nCompet,3)
cCampoY	:= ""
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
aGeral 		:= {}
aBenef		:= {}

Do While (ALIAS_TMP)->(!eof())


	IF cCodigo <> (ALIAS_TMP)->XX_CODGCT
		nTotFat :=0
		nTotFatMES := 0
		nTFATDOMES := 0
		nTotCUSTO  := 0
 		cCodigo    := (ALIAS_TMP)->XX_CODGCT
   		nTXATMESR  :=	0	
 	ENDIF
 	
	nTotal 		:= 0
	nTotalMES 	:= 0
	nTDOMES 	:= 0

	FOR _nI := 1 TO nPeriodo
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|00|01|03-1|02|05-1|06-1|07-1|22-1|30-1|YYYYYYYYZ|"	
		   //	cCampo		:= "TRB->XX_REAL"+STRZERO(_nI,3)
			//&cCampo		:= ""
		ELSE
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
				//GRAVA CABECALHO 
	 			Reclock("TRB",.T.)
				TRB->XX_LINHA   := nLINHA
	 			TRB->XX_CODGCT  := "999999999"
				TRB->XX_DESC	:= ""
				TRB->XX_PROJ 	:= "Num. Siga: "+aContConsol[_IX,1] 
				TRB->XX_REAL 	:= ""
				TRB->XX_DIF 	:= ""
				TRB->(Msunlock())
				AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})

		 		++nLINHA
	    	
				dbSelectArea("TRB")
				//GRAVA CABECALHO 
	 			Reclock("TRB",.T.)
				TRB->XX_LINHA   := nLINHA
	 			TRB->XX_CODGCT  := "999999999"
				TRB->XX_DESC	:= "Cliente:"
				TRB->XX_PROJ 	:= aContConsol[_IX,2]
				TRB->XX_REAL 	:= ""
				TRB->XX_DIF 	:= ""
				AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
				TRB->(Msunlock())
				
		 		++nLINHA
				dbSelectArea("TRB")
				//GRAVA CABECALHO 
	 			Reclock("TRB",.T.)
				TRB->XX_LINHA   := nLINHA
	 			TRB->XX_CODGCT  := "999999999"
				TRB->XX_DESC	:= "Contrato:"
				TRB->XX_PROJ 	:= aContConsol[_IX,3]
				TRB->XX_REAL 	:= ""
				TRB->XX_DIF 	:= ""
				AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
				TRB->(Msunlock()) 
				
		 		++nLINHA
	 			Reclock("TRB",.T.)
				TRB->XX_LINHA   := nLINHA
	 			TRB->XX_CODGCT  :="999999999"
				TRB->XX_DESC	:= "Gestor Responsável "+ALLTRIM(SM0->M0_NOME)+":"
				TRB->XX_PROJ 	:= aContConsol[_IX,4]
				TRB->XX_REAL 	:= ""
				TRB->XX_DIF 	:= ""
				AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
				TRB->(Msunlock())

				nVContrat := 0
        		nVContrat := aScan(aVContrat, {|x| x[1]==aContConsol[_IX,1] })
		 		++nLINHA
	 			Reclock("TRB",.T.)
				TRB->XX_LINHA   := nLINHA
	 			TRB->XX_CODGCT  :="999999999"
				TRB->XX_DESC	:= "Vigência:"
				TRB->XX_PROJ 	:= IIF(nVContrat > 0,DTOC(aVContrat[nVContrat,2])+" até "+DTOC(aVContrat[nVContrat,3]),"")
				TRB->XX_REAL 	:= ""
				TRB->XX_DIF 	:= ""
				AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
				TRB->(Msunlock())

			NEXT

	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Competência Analisada:"
			TRB->XX_PROJ 	:= aMeses[nMesC]+"/"+STRZERO(nAnoC,4)
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF		:= ""
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
			TRB->(Msunlock())
	
		 	++nLINHA
	
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Descrição Item"
			TRB->XX_PROJ 	:= "Previsão Financeira"
			TRB->XX_REAL 	:= "Realizado"
			TRB->XX_DIF 	:= "% Diferença"
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_DESC","","S","",""})
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","S","",""})
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_REAL","","S","",""})
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_DIF" ,"","S","",""})
			TRB->(Msunlock())
		
		ENDIF
	ELSE
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|00|"
	    	nRENTABIL	:= 0
			aGeral 		:= {}
			aBenef		:= {}
			dbSelectArea("TRB")
			//GRAVA CABECALHO 
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= ""
			TRB->XX_PROJ 	:= "Num. Siga: "+(ALIAS_TMP)->XX_CODGCT 
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
	
		 	++nLINHA
	    	
			dbSelectArea("TRB")
			//GRAVA CABECALHO 
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Cliente:"
			TRB->XX_PROJ 	:= (ALIAS_TMP)->XX_DESC
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
	    ENDIF
	
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|01|"
	 
			dbSelectArea("TRB")
			//GRAVA CABECALHO 
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Contrato:"
			TRB->XX_PROJ 	:= (ALIAS_TMP)->XX_DESC
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
	
	    ENDIF
	
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|02|"
	
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Gestor Responsável "+ALLTRIM(SM0->M0_NOME)+":"
			TRB->XX_PROJ 	:= (ALIAS_TMP)->XX_DESC
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
	
			nVContrat := 0
       		nVContrat := aScan(aVContrat, {|x| x[1]==(ALIAS_TMP)->XX_CODGCT })
	 		++nLINHA
 			Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
 			TRB->XX_CODGCT  :=(ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Vigência:"
			TRB->XX_PROJ 	:= IIF(nVContrat > 0,DTOC(aVContrat[nVContrat,2])+" até "+DTOC(aVContrat[nVContrat,3]),"")
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
			TRB->(Msunlock())

		 	++nLINHA
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Competência Analisada:"
			TRB->XX_PROJ 	:= aMeses[nMesC]+"/"+STRZERO(nAnoC,4)
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
			TRB->(Msunlock())

		 	++nLINHA
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Descrição Item"
			TRB->XX_PROJ 	:= "Previsão Financeira"
			TRB->XX_REAL 	:= "Realizado"
			TRB->XX_DIF 	:= "% Diferença"
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_DESC","","S","",""})
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","S","",""})
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_REAL","","S","",""})
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_DIF" ,"","S","",""})
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
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= (ALIAS_TMP)->XX_DESC
		TRB->XX_PROJ 	:= transform((ALIAS_TMP)->&cCampoX,cPict)
		AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ" ,"","N","PREVISTO"+cCodigo,"PREVISTO"+cCodigo})

		TRB->XX_REAL 	:= transform((ALIAS_TMP)->&cCampoY,cPict)
		AADD(aFormula,{TRB->(RECNO()),"TRB->XX_REAL" ,"","N","REALIZADO"+cCodigo,"REALIZADO"+cCodigo})

		TRB->XX_DIF 	:= transform((((ALIAS_TMP)->&cCampoX - (ALIAS_TMP)->&cCampoY) / (ALIAS_TMP)->&cCampoX * 100)*-1,"@E 99999.99999")+"%"

		nValTADP	:=  0
      	nValTADP 	:= ((ALIAS_TMP)->&cCampoX * nTaxaAdm)/100		
		nValTADR	:=  0
      	nValTADR 	:= ((ALIAS_TMP)->&cCampoY * nTaxaAdm)/100
		TRB->(Msunlock())
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
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= (ALIAS_TMP)->XX_DESC
		TRB->XX_PROJ 	:= transform( (ALIAS_TMP)->&cCampoX,cPict)
		TRB->XX_REAL 	:= transform( (ALIAS_TMP)->&cCampoY,cPict)
		TRB->XX_DIF 	:= transform((((ALIAS_TMP)->&cCampoX - (ALIAS_TMP)->&cCampoY) / (ALIAS_TMP)->&cCampoX * 100)*-1,"@E 99999.99999")+"%"
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
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "BENEFICIOS"
		TRB->XX_PROJ 	:= transform(nBficP,cPict)
		TRB->XX_REAL 	:= transform(nBficR,cPict)
		TRB->XX_DIF 	:= transform(((nBficP - nBficR) / nBficP * 100)*-1,"@E 99999.99999")+"%"
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
 			TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= ""
			TRB->XX_PROJ 	:= ""
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())

			dbSelectArea("TRB")
 			Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
 			TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "DETALHE DOS BENEFICIOS"
			TRB->XX_PROJ 	:= ""
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
			
			FOR _XI := 1 TO LEN(aBenef)
				IF VAL(aBenef[_XI,3]) <> 0 .OR. VAL(aBenef[_XI,4]) <> 0
					dbSelectArea("TRB")
					//GASTOS GERAIS
 					Reclock("TRB",.T.)
					TRB->XX_LINHA   := nLINHA
 					TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
					TRB->XX_DESC	:= aBenef[_XI,2]
					TRB->XX_PROJ 	:= aBenef[_XI,3]
					TRB->XX_REAL 	:= aBenef[_XI,4]
					TRB->XX_DIF 	:= aBenef[_XI,5]
				ENDIF
			NEXT

			dbSelectArea("TRB")
			//PULA LINHA
 			Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
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
	 		AADD(aBenef,{(ALIAS_TMP)->XX_CODGCT,(ALIAS_TMP)->XX_DESC,transform((ALIAS_TMP)->&cCampoX,cPict),transform((ALIAS_TMP)->&cCampoY,cPict),transform((((ALIAS_TMP)->&cCampoX - (ALIAS_TMP)->&cCampoY) / (ALIAS_TMP)->&cCampoX * 100)*-1,"@E 99999.99999")+"%"})
		ENDIF
	ENDIF

	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|30|"
		InsumosP := 0
		InsumosP :=  (ALIAS_TMP)->&cCampoX
		InsumosR := 0
		InsumosR :=  (ALIAS_TMP)->&cCampoY
	ENDIF

	// 28/02/20
	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|30-2|"
		dbSelectArea("TRB")
		//DESCONTO NA NF
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "DESCONTO NA NF"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform((ALIAS_TMP)->&cCampoY,cPict)
		TRB->XX_DIF 	:= ""
		TRB->(Msunlock())
		++nLINHA
	ENDIF


	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|W29104004|"
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
		IF SUBSTR((ALIAS_TMP)->XX_CODIGO,1,1) == "W"   .AND. !"|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|W29104004|"
        	AADD(aGeral,{(ALIAS_TMP)->XX_CODGCT,(ALIAS_TMP)->XX_DESC,transform((ALIAS_TMP)->&cCampoX,cPict),transform((ALIAS_TMP)->&cCampoY,cPict),transform((((ALIAS_TMP)->&cCampoX - (ALIAS_TMP)->&cCampoY) / (ALIAS_TMP)->&cCampoX * 100)*-1,"@E 99999.99999")+"%"})
		ENDIF
	ENDIF


	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|ZZZZZZZZZ|"

		dbSelectArea("TRB")
		//INSUMOS
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "INSUMOS"
		TRB->XX_PROJ 	:= transform(InsumosP,cPict)
		TRB->XX_REAL 	:= transform(InsumosR-nValTADR-nCustoBkR,cPict)
		TRB->XX_DIF 	:= transform((((InsumosP) - (InsumosR-nValTADR-nCustoBkR)) / InsumosP * 100)*-1,"@E 99999.99999")+"%"
		TRB->(Msunlock())
		++nLINHA

		dbSelectArea("TRB")
		//TAXA DE ADMINISTRAÇÃO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "TAXA DE ADMINISTRAÇÃO DO MÊS"
		TRB->XX_PROJ 	:= transform(nValTADP,cPict)
		TRB->XX_REAL 	:= transform(nValTADR,cPict)
		TRB->XX_DIF 	:= transform(((nValTADP - nValTADR) / nValTADP * 100)*-1,"@E 99999.99999")+"%"
		TRB->(Msunlock())
		++nLINHA

		dbSelectArea("TRB")
		//TAXA DE ADMINISTRAÇÃO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "TAXA DE ADMINISTRAÇÃO ATÉ O MÊS"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform(nTXATMESR,cPict)
		TRB->XX_DIF 	:= ""
		TRB->(Msunlock())
		++nLINHA
        
        IF nCustoBKR > 0 .OR. nCustoBKP > 0 // 19/02/19 - Imprimir tambem se houver somente projeção de Custo BK
        	//CUSTO BK
			dbSelectArea("TRB")
 			Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
 			TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= cCustoBk
			TRB->XX_PROJ 	:= transform(nCustoBKP,cPict)
			TRB->XX_REAL 	:= transform(nCustoBKR,cPict)
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
			++nLINHA
		ENDIF

/* REMOVIDO LINHA DE TOTAL INSUMOS - Em 04/11/14 - Conforme Marcos Rivera
		dbSelectArea("TRB")
		//TOTAL INSUMOS
 		Reclock("TRB",.T.)
		TRB->XX_LINHA  := nLINHA
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
		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RESULTADO PREVISTO"
		TRB->XX_PROJ 	:= transform(nVPREVISTO,cPict)
		TRB->XX_REAL 	:= ""
		TRB->XX_DIF 	:= transform(nRPREVISTO,"@E 99999.99999")+"%"
		TRB->(Msunlock())
		++nLINHA


		dbSelectArea("TRB")
		//RESULTADO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RESULTADO DO MÊS - PARCIAL"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform((nFatura*nRDOMES)/100,cPict)
		TRB->XX_DIF 	:= transform(nRDOMES,"@E 99999.99999")+"%"
		TRB->(Msunlock())
		++nLINHA

		dbSelectArea("TRB")
		//RESULTADO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RESULTADO ATÉ O MÊS - PARCIAL"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform((nTotFatMES*nRESULTMES)/100,cPict)
		TRB->XX_DIF 	:= transform(nRESULTMES,"@E 99999.99999")+"%"
		TRB->(Msunlock())
		++nLINHA


		dbSelectArea("TRB")
		//RESULTADO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RESULTADO DO MÊS - GLOBAL"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform((nFatura*nRGDOMES)/100,cPict)
		TRB->XX_DIF 	:= transform(nRGDOMES,"@E 99999.99999")+"%"
		TRB->(Msunlock())
		++nLINHA 
		
		dbSelectArea("TRB")
		//RESULTADO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RESULTADO ATÉ O MÊS - GLOBAL"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform((nTotFatMES*nRGATMES)/100,cPict)
		TRB->XX_DIF 	:= transform(nRGATMES,"@E 99999.99999")+"%"
		TRB->(Msunlock())
		++nLINHA

/*
		dbSelectArea("TRB")
		//RESULTADO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
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
 			TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= ""
			TRB->XX_PROJ 	:= ""
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())


			dbSelectArea("TRB")
 			Reclock("TRB",.T.)
			TRB->XX_LINHA  := nLINHA
 			TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "DETALHE DOS INSUMOS"
			TRB->XX_PROJ 	:= ""
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())

			FOR _XI := 1 TO LEN(aGeral)
				IF VAL(aGeral[_XI,3]) <> 0 .OR. VAL(aGeral[_XI,4]) <> 0
					dbSelectArea("TRB")
					//GASTOS GERAIS
 					Reclock("TRB",.T.)
					TRB->XX_LINHA   := nLINHA
 					TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
					TRB->XX_DESC	:= aGeral[_XI,2]
					TRB->XX_PROJ 	:= aGeral[_XI,3]
					TRB->XX_REAL 	:= aGeral[_XI,4]
					TRB->XX_DIF 	:= aGeral[_XI,5]
				ENDIF
			NEXT

	    ENDIF

		dbSelectArea("TRB")
		//PULA LINHA
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
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
ENDDO
                                                                                                                 

dbSelectArea("TRB")
TRB->(dbgotop())

Return NIL


//GERA RESULTADO SINTETICO - VISAO FINANCEIRO
STATIC FUNCTION Gera2Result()

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
AADD(aGRUPO,aUser[1,10])
FOR i:=1 TO LEN(aGRUPO[1])
	lMaster := (aGRUPO[1,i] $ cMaster)
NEXT


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


	IF cCodigo <> (ALIAS_TMP)->XX_CODGCT
		nTotFat    := 0
		nTotFatMES := 0
		nTFATDOMES := 0
		nTotCUSTO  := 0
 		cCodigo    := (ALIAS_TMP)->XX_CODGCT
 		nTXATMESR  := 0
 	ENDIF
 	
	nTotal := 0
	nTotalMES := 0
	nTDOMES := 0
	FOR _nI := 1 TO nPeriodo
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|00|01|03-1|02|05-1|06-1|07-1|22-1|30-1|YYYYYYYYZ|"	
		   //	cCampo		:= "TRB->XX_REAL"+STRZERO(_nI,3)
			//&cCampo		:= ""
		ELSE
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

				dbSelectArea("TRB")
				//GRAVA CABECALHO 
	 			Reclock("TRB",.T.)
				TRB->XX_LINHA  := nLINHA
	 			TRB->XX_CODGCT  := "999999999"
				TRB->XX_DESC	:= ""
				TRB->XX_PROJ 	:= "Num. Siga: "+aContConsol[_IX,1] 
				TRB->XX_REAL 	:= ""
				TRB->XX_DIF 	:= ""
				TRB->(Msunlock())
	
		 		++nLINHA
	    	
				dbSelectArea("TRB")
				//GRAVA CABECALHO 
	 			Reclock("TRB",.T.)
				TRB->XX_LINHA  := nLINHA
	 			TRB->XX_CODGCT  := "999999999"
				TRB->XX_DESC	:= "Cliente:"
				TRB->XX_PROJ 	:= aContConsol[_IX,2]
				TRB->XX_REAL 	:= ""
				TRB->XX_DIF 	:= ""
				AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
				TRB->(Msunlock())
				
		 		++nLINHA
				dbSelectArea("TRB")
				//GRAVA CABECALHO 
	 			Reclock("TRB",.T.)
				TRB->XX_LINHA   := nLINHA
	 			TRB->XX_CODGCT  := "999999999"
				TRB->XX_DESC	:= "Contrato:"
				TRB->XX_PROJ 	:= aContConsol[_IX,3]
				TRB->XX_REAL 	:= ""
				TRB->XX_DIF 	:= ""
				AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
				TRB->(Msunlock()) 
				
		 		++nLINHA
	 			Reclock("TRB",.T.)
				TRB->XX_LINHA   := nLINHA
	 			TRB->XX_CODGCT  :="999999999"
				TRB->XX_DESC	:= "Gestor Responsável "+ALLTRIM(SM0->M0_NOME)+":"
				TRB->XX_PROJ 	:= aContConsol[_IX,4]
				TRB->XX_REAL 	:= ""
				TRB->XX_DIF 	:= ""
				TRB->(Msunlock())

				nVContrat := 0
        		nVContrat := aScan(aVContrat, {|x| x[1]==aContConsol[_IX,1] })
		 		++nLINHA
	 			Reclock("TRB",.T.)
				TRB->XX_LINHA   := nLINHA
	 			TRB->XX_CODGCT  :="999999999"
				TRB->XX_DESC	:= "Vigência:"
				TRB->XX_PROJ 	:= IIF(nVContrat > 0,DTOC(aVContrat[nVContrat,2])+" até "+DTOC(aVContrat[nVContrat,3]),"")
				TRB->XX_REAL 	:= ""
				TRB->XX_DIF 	:= ""
				AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
				TRB->(Msunlock())

			NEXT

	 		Reclock("TRB",.T.)
			TRB->XX_LINHA  := nLINHA
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Competência Analisada:"
			TRB->XX_PROJ 	:= aMeses[nMesC]+"/"+STRZERO(nAnoC,4)
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
			TRB->(Msunlock())
	
		 	++nLINHA
	
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Descrição Item"
			TRB->XX_PROJ 	:= ""
			TRB->XX_REAL 	:= "Realizado"
			TRB->XX_DIF 	:= "% Diferença"
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_DESC","","S","",""})
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","S","",""})
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_REAL","","S","",""})
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_DIF" ,"","S","",""})
			TRB->(Msunlock())
		
		ENDIF
	ELSE
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|00|"
	    	nRENTABIL	:= 0
			aGeral 		:= {}
			aBenef		:= {}
			dbSelectArea("TRB")
			//GRAVA CABECALHO 
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= ""
			TRB->XX_PROJ 	:= "Num. Siga: "+(ALIAS_TMP)->XX_CODGCT 
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
	
		 	++nLINHA
	    	
			dbSelectArea("TRB")
			//GRAVA CABECALHO 
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Cliente:"
			TRB->XX_PROJ 	:= (ALIAS_TMP)->XX_DESC
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
	    ENDIF
	
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|01|"
	 
			dbSelectArea("TRB")
			//GRAVA CABECALHO 
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Contrato:"
			TRB->XX_PROJ 	:= (ALIAS_TMP)->XX_DESC
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
	
	    ENDIF
	
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|02|"
	
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA   := nLINHA
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Gestor Responsável "+ALLTRIM(SM0->M0_NOME)+":"
			TRB->XX_PROJ 	:= (ALIAS_TMP)->XX_DESC
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
	
			nVContrat := 0
       		nVContrat := aScan(aVContrat,{|x| x[1]==(ALIAS_TMP)->XX_CODGCT })
	 		++nLINHA
 			Reclock("TRB",.T.)
			TRB->XX_LINHA  := nLINHA
 			TRB->XX_CODGCT  :=(ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Vigência:"
			TRB->XX_PROJ 	:= IIF(nVContrat > 0,DTOC(aVContrat[nVContrat,2])+" até "+DTOC(aVContrat[nVContrat,3]),"")
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
			TRB->(Msunlock())

		 	++nLINHA
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA  := nLINHA
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Competência Analisada:"
			TRB->XX_PROJ 	:= aMeses[nMesC]+"/"+STRZERO(nAnoC,4)
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","C","",""})
			TRB->(Msunlock())
	
		 	++nLINHA
	
	 		Reclock("TRB",.T.)
			TRB->XX_LINHA  := nLINHA
	 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Descrição Item"
			TRB->XX_PROJ 	:= ""
			TRB->XX_REAL 	:= "Realizado"
			TRB->XX_DIF 	:= "% Diferença"
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_DESC","","S","",""})
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_PROJ","","S","",""})
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_REAL","","S","",""})
			AADD(aFormula,{TRB->(RECNO()),"TRB->XX_DIF" ,"","S","",""})
			TRB->(Msunlock())
		
		ENDIF
    ENDIF

	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|03|"
		nFatura := 0
		nFatura := (ALIAS_TMP)->&cCampoY 
		dbSelectArea("TRB")
		//FATURAMENTO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA  := nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= (ALIAS_TMP)->XX_DESC
		TRB->XX_PROJ 	:= "" //transform((ALIAS_TMP)->&cCampoX,cPict)
		TRB->XX_REAL 	:= transform((ALIAS_TMP)->&cCampoY,cPict)
		TRB->XX_DIF 	:= transform((((ALIAS_TMP)->&cCampoX - (ALIAS_TMP)->&cCampoY) / (ALIAS_TMP)->&cCampoX * 100)*-1,"@E 99999.99999")+"%"
		nValTADP	:=  0
      	nValTADP 	:= ((ALIAS_TMP)->&cCampoX * nTaxaAdm)/100		
		nValTADR	:=  0
      	nValTADR 	:= ((ALIAS_TMP)->&cCampoY * nTaxaAdm)/100		
		TRB->(Msunlock())
		nRNTBILP	:= 0
		nRNTBILP	:= (ALIAS_TMP)->&cCampoX
		nRNTBILR	:= 0
		nRNTBILR	:= (ALIAS_TMP)->&cCampoY
	ENDIF
/*
	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|09|"
		dbSelectArea("TRB")
		//PROVENTO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA  := nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= (ALIAS_TMP)->XX_DESC
		TRB->XX_PROJ 	:= transform( (ALIAS_TMP)->&cCampoX,cPict)
		TRB->XX_REAL 	:= transform( (ALIAS_TMP)->&cCampoY,cPict)
		TRB->XX_DIF 	:= transform((((ALIAS_TMP)->&cCampoX - (ALIAS_TMP)->&cCampoY) / (ALIAS_TMP)->&cCampoX * 100)*-1,"@E 99999.99999")+"%"
		TRB->(Msunlock())
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
		dbSelectArea("TRB")
		//BENEFICIOS 
 		Reclock("TRB",.T.)
		TRB->XX_LINHA  := nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "BENEFICIOS"
		TRB->XX_PROJ 	:= transform(nBficP,cPict)
		TRB->XX_REAL 	:= transform(nBficR,cPict)
		TRB->XX_DIF 	:= transform(((nBficP - nBficR) / nBficP * 100)*-1,"@E 99999.99999")+"%"
		TRB->(Msunlock())
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
		dbSelectArea("TRB")
		//DESCONTO NA NF
 		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "DESCONTO NA NF"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform((ALIAS_TMP)->&cCampoY,cPict)
		TRB->XX_DIF 	:= ""
		TRB->(Msunlock())
		++nLINHA
	ENDIF



	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|PREVISTO|"
		nRPREVISTO 	:= 0
		nRPREVISTO 	:= (ALIAS_TMP)->&cCampoX
	ENDIF


	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|ZZZZZZZZZ|"


		dbSelectArea("TRB")
		//RESULTADO PREVISTO"
		Reclock("TRB",.T.)
		TRB->XX_LINHA   := nLINHA
		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RESULTADO PREVISTO"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= ""
		TRB->XX_DIF 	:= transform(nRPREVISTO,"@E 99999.99999")+"%"
		TRB->(Msunlock())
		++nLINHA

		dbSelectArea("TRB")
		//RESULTADO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA  := nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RESULTADO DO MÊS - PARCIAL"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform((nFatura*nRDOMES)/100,cPict)
		TRB->XX_DIF 	:= transform(nRDOMES,"@E 99999.99999")+"%"
		TRB->(Msunlock())
		++nLINHA

		dbSelectArea("TRB")
		//RESULTADO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA  := nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RESULTADO ATÉ O MÊS - PARCIAL"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform((nTotFatMES*nRESULTMES)/100,cPict)
		TRB->XX_DIF 	:= transform(nRESULTMES,"@E 99999.99999")+"%"
		TRB->(Msunlock())
		++nLINHA

		dbSelectArea("TRB")
		//RESULTADO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA  := nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RESULTADO DO MÊS - GLOBAL"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform((nFatura*nRGDOMES)/100,cPict)
		TRB->XX_DIF 	:= transform(nRGDOMES,"@E 99999.99999")+"%"
		TRB->(Msunlock())
		++nLINHA 
		
		dbSelectArea("TRB")
		//RESULTADO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA  := nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= "RESULTADO ATÉ O MÊS - GLOBAL"
		TRB->XX_PROJ 	:= ""
		TRB->XX_REAL 	:= transform((nTotFatMES*nRGATMES)/100,cPict)
		TRB->XX_DIF 	:= transform(nRGATMES,"@E 99999.99999")+"%"
		TRB->(Msunlock())
		++nLINHA

/*
		dbSelectArea("TRB")
		//RESULTADO
 		Reclock("TRB",.T.)
		TRB->XX_LINHA  := nLINHA
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
			TRB->XX_LINHA  := nLINHA
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
			TRB->XX_LINHA  := nLINHA
 			TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= "Justificativa Funcionarios"
			TRB->XX_PROJ 	:= cJFun
			TRB->XX_REAL 	:= ""
			TRB->XX_DIF 	:= ""
			TRB->(Msunlock())
			++nLINHA
		ENDIF
 
		dbSelectArea("TRB")
		//PULA LINHA
 		Reclock("TRB",.T.)
		TRB->XX_LINHA  := nLINHA
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
ENDDO
                                                                                                                 

dbSelectArea("TRB")
TRB->(dbgotop())


Return NIL




STATIC Function GeraCR14(lJob,_cAlias,cArqS,aTitulos,aCampos,aCabs,aImpr,aFormula,aFormat)
Local nHandle
Local cCrLf   	:= Chr(13) + Chr(10)
Local _ni,_nj
Local cPicN  	:= "@E 99999999.99999"
Local cDirTmp	:= "C:\TMP"
Local cArqTmp	:= ""
Local lSoma,aSoma,nCab
Local cLetra	:= ""
Local cTpQuebra	:= ""
Local cQuebra	:= ""
Local aQuebra	:= {}
Local cArqXls   := ""
Local aPlans 	:= {}

Local cMsg		:= ""
Local cEmailTO	:= "bruno.bueno@bkconsultoria.com.br"
Local cEmailCC	:= "microsiga@bkconsultoria.com.br"

If lJob
	cDirTmp := "\TMP"
EndIf
cArqTmp := cDirTmp+"\"+cArqS+".CSV"

Private xQuebra,xCampo

If !lJob
	If MsgYesNo("Deseja gerar no formato Excel (.xlsx) ?")
		//Processa( {|| U_GeraXCSV(_cAlias,cArqS,aTitulos,aCampos,aCabs,cTpQuebra,cQuebra,aQuebra,.F.)})
		AADD(aPlans,{_cAlias,TRIM(cArqS),"",aTitulos,aCampos,aCabs,aImpr,aFormula,aFormat, /*aTotal */, /*cQuebra*/, lClose:= .F. , lJob})
		cArqXls := U_GeraXlsx(aPlans,"",cArqS, lClose:= .F.,)
		Return Nil
	EndIf
Else
	u_xxLog("\TMP\BKGCTR14.LOG","Gerando planilha xlsx",.T.,"")
	AADD(aPlans,{_cAlias,TRIM(cArqS),"",aTitulos,aCampos,aCabs,aImpr,aFormula,aFormat, /*aTotal */, /*cQuebra*/, lClose:= .F. , lJob})
	cArqXls := U_GeraXlsx(aPlans,"",cArqS, lClose:= .F.,,,.F.,lJob)

	cMsg :=aTitulos[1]+CRLF+cStart+" - final: "+DtoC(Date())+" "+Time()
	U_SENDMAIL("BKGCTR14",aTitulos[1],cEmailTO,cEmailCC,cMsg,cArqXls,lJob)

EndIf

MakeDir(cDirTmp)
fErase(cArqTmp)

lSoma := .F.
aSoma := {}
nCab  := 0

nHandle := MsfCreate(cArqTmp,0)
   
If nHandle > 0
      
   FOR _ni := 1 TO LEN(aTitulos)
      fWrite(nHandle, aTitulos[_ni] + cCrLf)
      nCab++
   NEXT
   fWrite(nHandle, cArqS+" - Emitido em: "+DTOC(DATE())+"-"+SUBSTR(TIME(),1,5)+" - "+cUserName + cCrLf)
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
                	AADD(aSoma,'=Soma('+cLetra+ALLTRIM(STR(nCab))+':')
             	Else
                	AADD(aSoma,"")
             	Endif
             ENDIF
         Next
         lSoma := .T.
      ENDIF
   
      If !lJob
         IncProc("Gerando arquivo "+cArqS)   
	  Else
	     u_xxLog("\TMP\BKGCTR14.LOG","Gerando arquivo "+cArqS,.T.,"")
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
		MsgRun(cArqs,"Aguarde a abertura do Excel...",{|| ShellExecute("open", cArqTmp,"","",1) })
   EndIf

Else
	If !lJob
   		MsgAlert("Falha na criação do arquivo "+cArqTmp)
	Else
		u_xxLog("\TMP\BKGCTR14.LOG","Falha na criação do arquivo "+cArqTmp,.T.,"")
	EndIf
Endif
   
Return


//Atualiza tabela de custro 
Static Function AtualizaCC(lJob)
Local _IX := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o Semaforo Tabela Centro de Custo                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
GetMv("MV_XXSEMAF")
RecLock("SX6",.F.)
SX6->X6_CONTEUD := "S"
msUnlock()

If !lJob 
	IncProc("Atualizando Tabela Centro de Custo...")
Else
    u_xxLog("\TMP\BKGCTR14.LOG","Atualizando Tabela Centro de Custo...",.T.,"")
EndIf

TCSQLExec("EXEC BKIntegraRubi.DBO.PROC_UPD_CUSTO "+SM0->M0_CODIGO)

If !lJob 
	IncProc("Atualizando Tabela Centro de Custo Consorcios...")
Else
    u_xxLog("\TMP\BKGCTR14.LOG","Atualizando Tabela Centro de Custo Consorcios...",.T.,"")
EndIf

FOR _IX:= 1 TO LEN(aConsorcio)

	TCSQLExec("EXEC BKIntegraRubi.DBO.PROC_UPD_CUSTO "+SUBSTR(ALLTRIM(aConsorcio[_IX,2]),1,2))

NEXT

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o Semaforo Tabela Centro de Custo                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
GetMv("MV_XXSEMAF")
RecLock("SX6",.F.)
SX6->X6_CONTEUD := "N"
msUnlock()
Return


//Monta Tela Para informações de Consolidação
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

AADD(aTpCons,"N° Contrato")
AADD(aTpCons,"Prefixo")
AADD(aTpCons,"Sufixo")

AADD(aAtivos,"Ativos")
AADD(aAtivos,"Todos")

IF !EMPTY(cContrato)
 	cConsolida := cContrato
ENDIF

////////////
//SOLICITACAO DE INFORMACAO - Consolidação:
////////////
  
Define MsDialog oDlg01 Title "Solicitação de Informações - Consolidação:" From 000,000 To 240+(nSin*nTLin),600 Of oDlg01 Pixel



If TYPE("CRELEASERPO") == "U"
	nSnd := 15	// Protheus 11  - P11
Else
	nSnd := 35  // Protheus 12 - P12
EndIf



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
  	AADD(aRet,{cTpCons,cConsolida,cAtivos})
EndIf

RestArea( aAreaAtu )

Return aRet


Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}


dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Contrato?","Contrato?","Contrato?","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"02","Mês Competência?","Mês Competência?","Mês Competência?","mv_ch2","N",02,0,0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Ano Competência?","Ano Competência?","Ano Competência?","mv_ch3","N",04,0,0,"G","NaoVazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"04","%Taxa de Administração?","%Taxa de Administração?" ,"%Taxa de Administração?" ,"mv_ch4","N",10,5,2,"G","NaoVazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"05","Consolidar Contratos?","Consolidar Contratos?","Consolidar Contratos?","mv_ch5","N",01,0,2,"C","","mv_par05","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"06","Consorcio Aplicar Indice Total?","Consorcio Aplicar Indice Total","Consorcio Aplicar Indice Total","mv_ch6","N",01,0,2,"C","","mv_par06","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"07","Rateia Despesas no Cronograma?","Rateia Despesas no Cronograma?","Rateia Despesas no Cronograma?","mv_ch7","N",01,0,1,"C","","mv_par07","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"08","Detalhar ?","Detalhar ?","Detalhar ?","mv_ch8","N",01,0,2,"C","","mv_par08","Benefíc.Desp.Gerais","Benefíc.Desp.Gerais","Benefíc.Desp.Gerais","","","Desp.Gerais","Desp.Gerais","Desp.Gerais","","","Nao Detalhar","Nao Detalhar","Nao Detalhar","","","","","","","","","","","",""})

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
Static Function Grv14CCD1(cAliasTmp,nConsol,cCusto,cPrd,_nI,nValor,aAcrDcr,cOutros,cOutros1,lPRat,cDesc)
Local nY := 0
Local nYMes := 0
Local cRet := cOutros
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

cCampo2  := cAliasTmp+"->XX_VALR"+STRZERO(_nI,3)
&cCampo2 += nValor
If lPRat // Só fazer no primeiro item do rateio
	// Gravar Acrescimos e Decrescimos Financeiros
	For nY := 1 To Len(aAcrDcr)
		nYMes := ASCAN(aAnoMes,{|x| x == aAcrDcr[nY,1]})
		If nYmes > 0
			cCampo2  := cAliasTmp+"->XX_VALR"+STRZERO(nYMes,3)
			&cCampo2 += aAcrDcr[nY,3]
		EndIf
	Next
EndIf
(cAliasTmp)->(Msunlock())
cRet := cOutros1

Return cRet

