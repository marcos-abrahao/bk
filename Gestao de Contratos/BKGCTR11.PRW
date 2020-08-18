#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"
                                     
//-------------------------------------------------------------------
/*/{Protheus.doc} BKGCTR11()
BK - Rentabilidade dos Contratos

@author Adilson do Prado
@since 11/01/13 Rev 20/07/20
@version P12
@return Nil
/*/
//-------------------------------------------------------------------


User Function BKGCTR11(lJob)
Local _nI           := 0
Local aDbf 		    := {} //cArqTmp
Local oTmpTb1
Local aDbf2         := {} //,cArqTmp2
Local oTmpTb2
Local aDbf3         := {} //,cArqTmp3
Local oTmpTb3
Local cMes          := ""
Local cXXSEMAF		:= "N"

Private titulo      := "Rentabilidade dos Contratos"
Private aMeses		:= {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
Private aContratos 	:= {}
Private lConsorcio  := .F.
Private lFurnas		:= .F.
Private cPerg       := "BKGCTR11"

Private dDataInicio := dDatabase
Private dDataI		:= dDatabase
Private dDataFinal  := dDatabase
Private cSituac     := "05"
Private	cPict       := "@E 99,999,999,999.99"
Private nPeriodo    := 1
Private nPlan       := 1
Private cContrato   := ""
Private aPeriodo    := {}
Private aAnoMes     := {}
Private aAcrDcr 	:= {}
Private cLastE2     := ""
Private lPRat		:= .T.


Private nTamCodGct	:= 9
Private nTamCodigo	:= 16

Private cCtrCons    := ""
Private cCodEve     := ""
Private cPCodEve    := ""

Private nMImpContr  := 0
Private nTaxaAdm    := 0
Private nEncargos   := 0
Private nEncarIPT   := 0
Private nINCIDENCI  := 0
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
Private cExm_Prod	:= ""
Private cMFG_Prod	:= ""
Private cDCH_Prod	:= ""
Private aFixeFX     := {}
Private aHeader	    := {}
Private nConsolida	:= 2
Private nIndConsor	:= 1
Private nRateia     := 1
Private nConsol     := 0
Private cConsolida 	:= ""
Private aConsolida 	:= {}
Private aContConsol := {}
Private cTipoContra := ""
Private aXXMIMPC	:= {}
Private aMImpContr  := {}
Private ALIAS_TMP   := "TMPC"+ALLTRIM(SM0->M0_CODIGO)
Private ALIAS_FOL   := "TMPF"+ALLTRIM(SM0->M0_CODIGO)
Private cXXPLR 		:= ""
Private aFurnas     := {} 

Private aTitulos,aCampos,aCabs,aFormat
Private aCampos2,aCabs2
Private aCampos3,aCabs3

Default lJob		:= .F.

aFurnas  := U_StringToArray(ALLTRIM(SuperGetMV("MV_XXFURNAS",.F.,"105000381/105000391")), "/" )

IF !lJob
	ValidPerg()
	If !Pergunte(cPerg,.T.)
		Return Nil
	Endif
ENDIF


aXXMIMPC	:= {}
aXXMIMPC	:= StrTokArr(GetMv("MV_XXMIMPC"),"|") //%Media de Impostos e Contribuicoes calculo Rentabilidade dos Contratos 
aMImpContr  := {}
FOR IX := 1 TO LEN(aXXMIMPC)
    AADD(aMImpContr,StrTokArr(aXXMIMPC[IX],";"))
NEXT

IF !lJob
	cContrato  	:= mv_par01
ELSE
	cContrato  	:= "" 
	ConOut("BKGCTR11: Iniciado processando Rentabilidade dos Contratos - "+DTOC(DATE())+" "+TIME())   
ENDIF


nMImpContr 	:= VAL(aMImpContr[1,2]) //mv_par02                                   
nEncargos  	:= GetMv("MV_XXENCAP") //mv_par03
nEncarIPT	:= GetMv("MV_XXEIPT")  //mv_par04
nINCIDENCI	:= GetMv("MV_XXINCID") //mv_par05
nTaxaAdm	:= GetMv("MV_XXTXADM") //mv_par06
cProventos  := GetMv("MV_XXPROVE") //"|1|2|11|34|36|56|60|64|65|68|100|102|104|108|110|126|266|268|270|274|483|600|640|656|664|674|675|685|696|725|726|727|728|729|745|747|749|750|754|755|756|757|758|760|761|762|763|764|765|778|779|787|789|790|791|792|824|"
cDescontos  := GetMv("MV_XXDESCO") //"|112|114|120|122|177|181|187|636|650|680|683|691|780|783|784|"
cVT_Prov 	:= GetMv("MV_XXVTPRO") //"|671|"  // PROVENTO DE VT - Conforme verificado com Sr. Anderson esta verba é so pára funcionario que tem vt em dinheiro
cVT_Verb 	:= GetMv("MV_XXVTVER") //"|290|667|"
cVT_Prod   	:= GetMv("MV_XXVTPRD") //"|31201046|"
cVRVA_Verb  := GetMv("MV_XXVRVAV") //"|613|614|662|681|682|702|"
cVRVA_Prod  := GetMv("MV_XXVRVAP") //"|31201045|31201047|"

cASSM_Verb	:= GetMv("MV_XXASSMV") //"|605|689|733|734|742|770|771|773|794|796|832|856|"
cASSM_Prod	:= GetMv("MV_XXASSMP") //"|605|689|709|711|712|719|733|734|742|743|770|771|773|794|796|810|832|833|854|856|857|"

cSINO_Verb	:= GetMv("MV_XXSINOV") //"|510|607|665|679|724|739|825|900|"    
cSINO_Prod	:= GetMv("MV_XXSINOP") //"|510|607|665|679|724|732|739|825|900|" 

cCCRE_Verb	:= GetMv("MV_XXCCREV") //INUTILIZADO //"|774|775|776|812|814|"
cCCRE_Prod	:= GetMv("MV_XXCCREP") //INUTILIZADO //"|34202016|"

cCDPR_Prod	:= GetMv("MV_XXCDPRP") //"|320200111|34202034|000000000000112|34202057|34202086|"    cod produtos rateio no contrato
cCDPR_GRUP	:= GetMv("MV_XXCDPRG") //'|0008|0009|0010|'  *********                               cod grupo de produto rateio no contrato

cNINC_Verb	:= "|875|910|"  //GetMv("MV_XXNINCI") //"|875|"  VERBA SEM INCIDENCIAS   

aContrCons	:= {}
aContrCons	:= StrTokArr(ALLTRIM(GetMv("MV_XXCONS1"))+ALLTRIM(GetMv("MV_XXCONS2"))+ALLTRIM(GetMv("MV_XXCONS3"))+ALLTRIM(GetMv("MV_XXCONS4")),"/") //"163000240"

// Rateio        Contrato  x  Produtos                       15/01/20 - Marcos
aRatCtrPrd  := U_DefCtrPrd()

cExm_Prod	:= GetMv("MV_XXCEXMP") //"41201015"
cMFG_Prod	:= GetMv("MV_XXCMFGP") //"31201053"
cDCH_Prod	:= GetMv("MV_XXCDCH")  //"34202003"
cXXSEMAF	:= GetMv("MV_XXSEMAF")
cXXPLR	    := SuperGetMV("MV_XXPLR",.F.,"|430|") //|430|

IF EMPTY(cContrato)
	IF !lJob
		IF AVISO("Atenção","Incluir Contrato Consorcios??",{"Não","Sim"}) == 2
	   		lConsorcio := .T.
		ELSE
	   		lConsorcio := .F.
		ENDIF
		IF AVISO("Atenção","Incluir Contrato Furnas - Filial 381/391  ??",{"Não","Sim"}) == 2
			lFurnas := .T.
		ELSE
			lFurnas := .F.
		ENDIF
	ELSE
   		lConsorcio := .F.
		lFurnas := .F.
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
//cNINC_Verb	C   VERBA SEM INCIDENCIAS   

 		
IF ALLTRIM(cXXSEMAF) == 'N'
	ProcRegua(100)
	Processa( {|| AtualizaCC() }) 
ELSE
	IF !lJob
		Msginfo("Atualizando tabela Folha de Pagamento!!")
	ELSE
		ConOut("BKGCTR11: Atualizando tabela Folha de Pagamento - "+DTOC(DATE())+" "+TIME())   
	ENDIF
    Return Nil
ENDIF


IF !EMPTY(cContrato)
	cQuery := " SELECT TOP 1 MIN(CNF_DTVENC) AS CNF_INICIO,MAX(CNF_DTVENC) AS CNF_FIM,CN9_SITUAC,CN9_REVISA"+CRLF
	cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF
	cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA"+CRLF
	cQuery += "    AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"+CRLF
	cQuery += "  WHERE CNF.D_E_L_E_T_=''"+CRLF
   	cQuery += "    AND CNF_CONTRA ='"+ALLTRIM(cContrato)+"'"+CRLF
	cQuery += " GROUP BY CN9_REVISA,CN9_SITUAC"+CRLF
	cQuery += " ORDER BY CN9_REVISA DESC"+CRLF
ELSE
	cContrCons := ""
 	For IX:= 1 TO LEN(aConsorcio)
 		cContrCons += "'"+ALLTRIM(aConsorcio[IX,1])+"',"
 	NEXT
	cQuery := " SELECT MIN(CNF_DTVENC) AS CNF_INICIO,MAX(CNF_DTVENC) AS CNF_FIM,CN9_SITUAC"+CRLF
	cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF
	cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA"+CRLF
	cQuery += "    AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"+CRLF
	cQuery += " WHERE CNF.D_E_L_E_T_=''"+CRLF
	cQuery += "    AND CN9_SITUAC = '05'"+CRLF
	IF !lConsorcio
		IF !EMPTY(cContrCons)
			cQuery += " AND CNF_CONTRA NOT IN ("+SUBSTRING(ALLTRIM(cContrCons),1,LEN(cContrCons)-1)+") "+CRLF
		ENDIF
	ENDIF
	IF !lJob
		IF !lFurnas
			cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391'"+CRLF
		ENDIF
	ELSE
	    cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) <> '008' "+CRLF //IPT 
  	    //cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) <> '049' "  
	    cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) <> '258' "+CRLF
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '247' "+CRLF
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391' "+CRLF //FURNAS
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '438' "+CRLF
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '425' "+CRLF
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '455' "+CRLF
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '467' "+CRLF
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '507' "+CRLF
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '510' "+CRLF
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '521' "+CRLF
	    cQuery += " AND CNF_CONTRA NOT IN ('193000288','194000289','195000290','196000291')"+CRLF
	    cQuery += " AND CNF_CONTRA NOT IN ('197000292','198000293','199000294')"+CRLF
	    cQuery += " AND CNF_CONTRA NOT IN ('197001292','198001293','199001294')"+CRLF
	    IF SM0->M0_CODIGO <> "14"  
	    	cQuery += " AND CNF_CONTRA NOT IN ('302000508')"+CRLF
	    ENDIF  
	ENDIF
	
	cQuery += " GROUP BY CN9_SITUAC"+CRLF
ENDIF	

u_LogMemo("BKGCTR11.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP1"
TCSETFIELD("QTMP1","CNF_INICIO","D",8,0)	
TCSETFIELD("QTMP1","CNF_FIM","D",8,0)	

dbSelectArea("QTMP1")
dDataI		:= QTMP1->CNF_INICIO
dDataFinal	:= QTMP1->CNF_FIM

QTMP1->(Dbclosearea())



IF EMPTY(DTOS(dDataI)) .OR. EMPTY(DTOS(dDataFinal)) 
	MSGSTOP("Contrato não encontrado!!")
	RETURN NIL
ENDIF

//Determina quantos Meses utilizar no calculo
nPeriodo += DateDiffMonth( dDataI , dDataFinal )

titulo   := titulo+" - Período: "+DTOC(dDataI)+" até "+DTOC(dDataFinal)

aDbf    := {}
Aadd( aDbf, { 'XX_LINHA', 'N', 10,00 } )
Aadd( aDbf, { 'XX_CODGCT','C', 09,00 } )
Aadd( aDbf, { 'XX_DESC',  'C', 50,00 } )
FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,3)
	Aadd( aDbf, { 'XX_VAL'+cMes,'C', 25,00 } )
NEXT
Aadd( aDbf, { 'XX_TOTAL','C', 25,0 } )
Aadd( aDbf, { 'XX_INDIC','C', 25,0 } )

//Aadd( aDbf, { 'XX_STATUS','C', 2,00 } )


///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .T.,NIL,cArqTmp,'TRB',.F.,.F. )
///IndRegua("TRB",cArqTmp,"XX_LINHA",,,"Indexando Arquivo de Trabalho") 

oTmpTb1 := FWTemporaryTable():New( "TRB" ) 
oTmpTb1:SetFields( aDbf )
oTmpTb1:AddIndex("indice1", {"XX_LINHA"} )
oTmpTb1:Create()

aCabs   := {}
aCampos := {}
aTitulos:= {}
aFormat := {}

AADD(aTitulos,titulo)

//AADD(aCampos,"TRB->XX_LINHA")
//AADD(aCabs  ,"Linha")
//AADD(aFormat,"")

AADD(aCampos,"TRB->XX_CODGCT")
AADD(aCabs  ,"Contrato")
AADD(aFormat,"")

AADD(aCampos,"TRB->XX_DESC")
AADD(aCabs  ,"Descrição")
AADD(aFixeFX,{"Descrição","XX_DESC",'C', 50,00,'@!'})
AADD(aHeader,{"Descrição","XX_DESC" ,"@!",50,00,"","","C","TRB","R"})
AADD(aFormat,"")

dDataInicio := dDataI
FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,3)
	AADD(aCampos,"TRB->XX_VAL"+cMes)
	AADD(aCabs,STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4))
	AADD(aFixeFX,{STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4),"XX_VAL"+cMes,'C', 10,00,'@!'})
    AADD(aHeader,{STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4),"XX_VAL"+cMes,"@!",10,00,"","","C","TRB","R"})
	AADD(aFormat,"N")
 	dDataInicio := MonthSum(dDataInicio,1)
NEXT

AADD(aCampos,"TRB->XX_TOTAL")
AADD(aCabs  ,"TOTAL")
AAdd(aFixeFX,{"TOTAL","XX_TOTAL",'C', 10,00,'@!'})
AADD(aHeader,{"TOTAL","XX_TOTAL","@!",10,00,"","","C","TRB","R"})
AADD(aFormat,"N")

AADD(aCampos,"TRB->XX_INDIC")
AADD(aCabs  ,"INDICE")
AAdd(aFixeFX,{"INDICE","XX_INDIC",'C', 10,00,'@!'})
AADD(aHeader,{"INDICE","XX_INDIC" ,"@!",10,00,"","","C","TRB","R"})
AADD(aFormat,"N")

//AADD(aCampos,"TRB->XX_STATUS")

aDbf2    := {}

nTamCodGct := 9
nTamCodigo := 16

Aadd( aDbf2, { 'XX_CODGCT','C', nTamCodGct,00 } )
Aadd( aDbf2, { 'XX_CODIGO','C', nTamCodigo,00 } )
Aadd( aDbf2, { 'XX_DESC'  ,'C',         50,00 } )
FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,3)
	Aadd( aDbf2, { 'XX_VAL'+cMes,'N', 18,02 } )
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
dDataInicio := dDataI

FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,3)
	AADD(aCampos2,ALIAS_TMP+"->XX_VAL"+cMes)
	AADD(aCabs2,STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4))
  	AADD(aPeriodo,{STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4)})
	AADD(aAnoMes,STRZERO(YEAR(dDataInicio),4)+STRZERO(Month(dDataInicio),2))  
	dDataInicio := MonthSum(dDataInicio,1)
NEXT


IF !lJob

	// Criação de arquivo temporário para geração de planilha de Proventos e Descontos detalhados
	
	aDbf3    := {}
	aCabs3   := {}
	aCampos3 := {}
	
	Aadd( aDbf3, { 'YY_CODGCT','C', 9,00 } )
	AADD(aCampos3,ALIAS_FOL+"->YY_CODGCT")
	AADD(aCabs3  ,"Contrato")

	Aadd( aDbf3, { 'YY_CODIGO','C', 16,00 } )
	AADD(aCampos3,ALIAS_FOL+"->YY_CODIGO")
	AADD(aCabs3  ,"Cod.Evento")
	
	Aadd( aDbf3, { 'YY_DESC','C', 50,00 } )
	AADD(aCampos3,ALIAS_FOL+"->YY_DESC")
	AADD(aCabs3  ,"Descrição")

	Aadd( aDbf3, { 'YY_TIPO','C', 25,00 } )
	AADD(aCampos3,ALIAS_FOL+"->YY_TIPO")
	AADD(aCabs3  ,"Tipo")

	dDataInicio := dDataI

	FOR _nI := 1 TO nPeriodo
		cMes := STRZERO(_nI,3)
		Aadd( aDbf3, { 'YY_VAL'+cMes,'N', 18,02 } )
		AADD(aCampos3,ALIAS_FOL+"->YY_VAL"+cMes)
		AADD(aCabs3,STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4))
  		dDataInicio := MonthSum(dDataInicio,1)
	NEXT

	
	///cArqTmp3 := CriaTrab( aDbf3, .T. )
	///dbUseArea( .T.,NIL,cArqTmp3,ALIAS_FOL,.F.,.F. )
	///IndRegua(ALIAS_FOL,cArqTmp3,"YY_CODGCT+YY_TIPO+YY_CODIGO",,,"Indexando Arquivo de Trabalho") 
	///dbSetIndex(cArqTmp3+ordBagExt())

	oTmpTb3 := FWTemporaryTable():New( ALIAS_FOL ) 
	oTmpTb3:SetFields( aDbf3 )
	oTmpTb3:AddIndex("indice3", {"YY_CODGCT","YY_TIPO","YY_CODIGO"} )
	oTmpTb3:Create()

	//	

	ProcRegua(1)
	Processa( {|| ProcBKGCTR11(lJob) })
	Processa( {|| MBrwBKGCTR11() })

	///(ALIAS_FOL)->(Dbclosearea())
	///FErase(cArqTmp3+GetDBExtension())
	///FErase(cArqTmp3+OrdBagExt())
	oTmpTb3:Delete()

ELSE

	ProcBKGCTR11(lJob)

ENDIF


///(ALIAS_TMP)->(Dbclosearea())
///FErase(cArqTmp2+GetDBExtension())
///FErase(cArqTmp2+OrdBagExt())
oTmpTb2:Delete()

///TRB->(Dbclosearea())
///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())
oTmpTb1:Delete()
 
Return



Static Function MBrwBKGCTR11()
Local 	cAlias 		:= "TRB"
//Local 	aCores 		:= {}
//Local 	cFiltra   := "XX_LINHA>=0"

Private cCadastro	:= "Relatório de Rentabilidade dos Contratos"
Private aRotina		:= {}
Private aIndexSz  	:= {}
//Private bFiltraBrw	:= { || FilBrowse(cAlias,@aIndexSz,@cFiltra) }

Private aSize   := MsAdvSize(,.F.,400)
Private aObjects:= { { 450, 450, .T., .T. } }
Private aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aPosObj := MsObjSize( aInfo, aObjects, .T. )
Private lRefresh:= .T.
Private aButton := {}
Private _oGetDbSint
Private _oDlgSint

AADD(aRotina,{"Exp. Excel"	,"U_CBKGCTR11",0,6})
AADD(aRotina,{"Parametros"	,"U_PBKGCTR11",0,7})
AADD(aRotina,{"Legenda"		,"U_LBKGCTR11",0,8})

/*

AADD(aCores,{"XX_STATUS == '01'" ,"BR_AMARELO" })
AADD(aCores,{"XX_STATUS == '02'" ,"BR_AMARELO" })
AADD(aCores,{"XX_STATUS == '03'" ,"BR_AZUL" })
AADD(aCores,{"XX_STATUS == '04'" ,"BR_LARANJA" })
AADD(aCores,{"XX_STATUS == '05'" ,"BR_VERDE" })
AADD(aCores,{"XX_STATUS == '06'" ,"BR_CINZA" })
AADD(aCores,{"XX_STATUS == '07'" ,"BR_MARRON" })
AADD(aCores,{"XX_STATUS == '08'" ,"BR_PRETO" })
AADD(aCores,{"XX_STATUS == '09'" ,"BR_PINK" })
AADD(aCores,{"XX_STATUS == '10'" ,"BR_BRANCO" })


-- CORES DISPONIVEIS PARA LEGENDA --
BR_AMARELO
BR_AZUL
BR_BRANCO
BR_CINZA
BR_LARANJA
BR_MARRON
BR_VERDE
BR_VERMELHO
BR_PINK
BR_PRETO
*/

dbSelectArea(cAlias)
dbSetOrder(1)
//+------------------------------------------------------------
//| Cria o filtro na MBrowse utilizando a função FilBrowse
//+------------------------------------------------------------
//Eval(bFiltraBrw)

dbSelectArea(cAlias)
dbGoTop()

	
DEFINE MSDIALOG _oDlgSint ;
TITLE cCadastro ;
From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
_oGetDbSint := MsGetDb():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], 2, "AllwaysTrue()", "AllwaysTrue()",,,,,,"AllwaysTrue()","TRB")
	
//_oGetDbSint:oBrowse:BlDblClick := {|| ShowAnalit(TRB2->DATAMOV,_oGetDbSint:oBrowse:ncolpos), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}
	
//aadd(aButton , { "BMPTABLE" , { || U_GeraExcelH("TRB2",,,,aHeader,.T.), TRB2->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Gera Planilha Excel" } )
//aadd(aButton , { "BMPTABLE" , { || ShowAnalit(CTOD("01/01/2000"),_oGetDbSint:oBrowse:ncolpos), TRB2->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Analitico completo" } )

aadd(aButton , { "BMPTABLE" , { || U_CBKGCTR11(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Gera Planilha Excel" } )
aadd(aButton , { "BMPTABLE" , { || U_GCT11FOL(),  (ALIAS_FOL)->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Detalhes Folha" } )
aadd(aButton , { "BMPTABLE" , { || U_PBKGCTR11(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Parametros" } )
aadd(aButton , { "BMPTABLE" , { || U_LBKGCTR11()}, "Legenda" } )

//oBr := TBar():new(_oDlgSint,25,32,.T.,,,"FND_LGND",)
//oBr:nHeight := 52
	
//oPanelApo := TPanel():New(C(01),C(01),,_oDlgSint, NIL, .T., .F., NIL, NIL,C(240) ,C(150) , .T., .F. ) 

// ToolBar para os botôes de apontamentos



//oBtnBarApo := TBar():New( _oDlgSint, aSize[6] - 50, 45, .T.,"BOTTOM" , , , )
//                     New(oDLG      ,              ,20 ,    ,"TOP",)
//nIndBtn := 0
//DEFINE BUTTON oBtExcel OF oBtnBarApo RESOURCE "PMSEXCEL" ;
//	ACTION Eval({ || U_CBKGCTR11()}) ADJUST TOOLTIP "STR0112" PROMPT "STR0113" AT ++nIndBtn // "Exportar para Excel"##"Excel"

	
ACTIVATE MSDIALOG _oDlgSint ON INIT EnchoiceBar(_oDlgSint,{|| _oDlgSint:End()}, {||_oDlgSint:End()},, aButton)
	

//mBrowse(6,1,22,75,cAlias,aFixeFX,,,,,aCores)

//+------------------------------------------------
//| Deleta o filtro utilizado na função FilBrowse
//+------------------------------------------------
//EndFilBrw(cAlias,aIndexSz)

Return Nil


User Function LBKGCTR11()
Local aLegenda := {}



AADD(aLegenda,{"BR_AMARELO"," - Cancelado"})
AADD(aLegenda,{"BR_AMARELO"," - Em Elaboração" })
AADD(aLegenda,{"BR_AZUL" ," - Emitido"})
AADD(aLegenda,{"BR_LARANJA"," - Em Aprovação" })
AADD(aLegenda,{"BR_VERDE"," - Vigente" })
AADD(aLegenda,{"BR_CINZA"," - Paralisado" })
AADD(aLegenda,{"BR_MARRON"," - Sol. Finalização" })
AADD(aLegenda,{"BR_PRETO"," - Finalizado" })
AADD(aLegenda,{"BR_PINK"," - Resisão" })
AADD(aLegenda,{"BR_BRANCO"," - Revisado" })

BrwLegenda(cCadastro, "Legenda", aLegenda)

Return Nil



User FUNCTION PBKGCTR11()

ValidPerg()
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

cContrato   := mv_par01

ProcRegua(1)

Processa( {|| ProcBKGCTR11(lJob) })


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



User FUNCTION CBKGCTR11()
Local cAlias := "TRB"

dbSelectArea(cAlias)

ProcRegua(1)
Processa( {|| GeraXGCT11(cAlias,TRIM(cPerg),aTitulos,aCampos,aCabs,/*aImpr*/,/*aAlign*/,aFormat)})

Return Nil

  
 
Static Function ProcBKGCTR11(lJob)
Local cQuery := ""
Local nAuxVl :=0

LimpaBrw ("TRB")
LimpaBrw (ALIAS_TMP)

ProcRegua(nPeriodo)
FOR _nI := 1 TO nPeriodo

	IncProc("Consultando faturamento dos contratos...")
   
	//*********Faturamento do Contrato
	cQuery := " SELECT CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CNA_XXMUN,SUM(D2_TOTAL) AS D2_TOTAL,SUM(D2_VALISS) AS D2_VALISS, SUM(E5_VALOR) AS E5DESC"+CRLF
	cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF
    cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9.CN9_NUMERO = CNF.CNF_CONTRA AND CN9.CN9_REVISA = CNF.CNF_REVISA"+CRLF
    cQuery += "      AND CN9.CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+CRLF
	cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA"+CRLF
	cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CND_PARCEL = CNF_PARCEL"+CRLF
	cQuery += "      AND  CNA_NUMERO = CND_NUMERO AND CND_REVISA = CNF_REVISA"+CRLF
	cQuery += "      AND  CND.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM"+CRLF
	cQuery += "      AND  C6_FILIAL = CND_FILIAL AND SC6.D_E_L_E_T_ = ''"+CRLF
	cQuery += "	LEFT JOIN "+RETSQLNAME("SD2")+ " SD2 ON SC6.C6_NUM = SD2.D2_PEDIDO AND C6_ITEM = D2_ITEM "+CRLF
	cQuery += "      AND  D2_FILIAL = CND_FILIAL AND SD2.D_E_L_E_T_ = '' "+CRLF
// 27/02/20   
	cQuery += " LEFT JOIN "+RETSQLNAME("SE5")+" SE5 ON E5_PREFIXO = D2_SERIE AND E5_NUMERO = D2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = D2_CLIENTE AND E5_LOJA = D2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' "+CRLF //--AND E5_PARCELA = '  '
	cQuery += "      AND  E5_FILIAL = '"+xFilial("SE5")+"' AND  SE5.D_E_L_E_T_ = '' "+CRLF

	cQuery += " INNER JOIN "+RETSQLNAME("SA1")+" SA1 ON CN9.CN9_CLIENT = SA1.A1_COD " +CRLF
    cQuery += "      AND CN9.CN9_LOJACL = SA1.A1_LOJA AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ''"+CRLF

	cQuery += " WHERE CNF.D_E_L_E_T_='' AND CNF.CNF_COMPET='"+aPeriodo[_nI,1]+"' "+CRLF   	//AND CN9.CN9_SITUAC ='"+cSituac+"'"
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
				cQuery += " AND CN9_SITUAC <> '10' AND CN9.CN9_SITUAC <> '09'"+CRLF
   			ENDIF
		ELSE
   	 		cQuery += " AND CNF_CONTRA ='"+ALLTRIM(cContrato)+"'"+CRLF
			//cQuery += "AND CN9.CN9_SITUAC ='"+cSituac+"'"  
 			cQuery += " AND CN9.CN9_SITUAC <> '10' AND CN9.CN9_SITUAC <> '09'"+CRLF
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
		IF !lJob
			IF !lFurnas
				cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391'"+CRLF
			ENDIF
		ELSE
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) <> '008' "+CRLF//IPT 
	    	//cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) <> '049' "  
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) <> '258' "+CRLF 
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '247' "+CRLF  
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391' "+CRLF //FURNAS
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '438' "+CRLF  
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '425' "+CRLF  
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '455' "+CRLF
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '467' "+CRLF
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '507' "+CRLF
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '510' "+CRLF
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '521' "+CRLF
	    	cQuery += " AND CNF_CONTRA NOT IN ('193000288','194000289','195000290','196000291')"+CRLF 
	    	cQuery += " AND CNF_CONTRA NOT IN ('197000292','198000293','199000294')"+CRLF
	    	cQuery += " AND CNF_CONTRA NOT IN ('197001292','198001293','199001294')"+CRLF
	    	IF SM0->M0_CODIGO <> "14"  
	    		cQuery += " AND CNF_CONTRA NOT IN ('302000508')"+CRLF
	    	ENDIF  
		ENDIF

		cQuery += "AND CN9.CN9_SITUAC ='"+cSituac+"'" +CRLF
    ENDIF	

	cQuery += " GROUP BY CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CNA_XXMUN ORDER BY CNF_CONTRA"+CRLF
 
	u_LogMemo("BKGCTR11-CNF-1-"+STRZERO(_nI,3)+".SQL",cQuery)
	

	TCQUERY cQuery NEW ALIAS "QTMP"

	dbSelectArea("QTMP")
	QTMP->(dbGoTop())
	DO WHILE QTMP->(!EOF())
	
	    nScan:= 0
 		nScan:= aScan(aContConsol,{|x| x[1] =ALLTRIM(QTMP->CNF_CONTRA)})
		IF nScan == 0
			AADD(aContConsol,{ALLTRIM(QTMP->CNF_CONTRA),QTMP->A1_NOME,QTMP->CTT_DESC01})
		ENDIF

        //VERIFICA INDECE CONSORCIO CASO CONTRATO DE CONSORCIO
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
        AADD(aRentab,{"02","NUMERO-SIGA: ","S",ALLTRIM(QTMP->CNF_CONTRA)})              
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
        AADD(aRentab,{"12","VT","S",0}) 
        AADD(aRentab,{"13","(-) Recuperação de VT","S",0}) 
        AADD(aRentab,{"14","VR/VA","S",0}) 
        AADD(aRentab,{"15","(-) Recuperação de VR/VA","S",0}) 
        AADD(aRentab,{"16","ASSMEDICA","S",0}) 
        AADD(aRentab,{"17","(-) Recuperação de ASSMEDICA","S",0}) 
        AADD(aRentab,{"18","Sindicato (Odonto)","S",0}) 
        AADD(aRentab,{"19","(-) Recuperação de Sindicato (Odonto)","S",0}) 
        AADD(aRentab,{"20","CECREMEF/ADV","S",0}) 
        AADD(aRentab,{"21","(-) CECREMEF/ADV","S",0}) 
        AADD(aRentab,{"22-1","","S",0})
        AADD(aRentab,{"30","GASTOS GERAIS","S",0}) 
		//27/02/20
        AADD(aRentab,{"30-1","","S",0}) 
        AADD(aRentab,{"30-2","DESCONTOS NA NF","S",IIF(nIndTC>0,QTMP->E5DESC/(nIndTC/100),QTMP->E5DESC)}) 

        AADD(aRentab,{"YYYYYYYYY","TAXA DE ADMINISTRAÇÃO","S",0})
        AADD(aRentab,{"YYYYYYYYZ","","S",0}) 
        AADD(aRentab,{"ZZZZZZYYY","RESULTADO PARCIAL","S",0})
        AADD(aRentab,{"ZZZZZZZYY","% RES. PARCIAL","S",0})
        AADD(aRentab,{"ZZZZZZZZY","RESULTADO GLOBAL","S",0})
        AADD(aRentab,{"ZZZZZZZZZ","% RES. GLOBAL ","S",0})

		FOR _nJ := 1 TO LEN(aRentab)
			dbSelectArea(ALIAS_TMP)
			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+aRentab[_nJ,1],.F.)
				Reclock(ALIAS_TMP,.F.)
				(ALIAS_TMP)->XX_DESC   := IIF("|"+aRentab[_nJ,1]+"|" $ "|00|01|02|",aRentab[_nJ,2]+aRentab[_nJ,4],aRentab[_nJ,2])
			ELSE
				Reclock(ALIAS_TMP,.T.)
				(ALIAS_TMP)->XX_CODGCT := IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
				(ALIAS_TMP)->XX_CODIGO := aRentab[_nJ,1]
				(ALIAS_TMP)->XX_DESC   := IIF("|"+aRentab[_nJ,1]+"|" $ "|00|01|02|",aRentab[_nJ,2]+aRentab[_nJ,4],aRentab[_nJ,2])
			ENDIF
			IF "|"+aRentab[_nJ,1]+"|" $ "|03|04|05|06|07|30-2|"  // 28/02/20
				cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
				&cCampo2 += aRentab[_nJ,4]
			ENDIF
			//(ALIAS_TMP)->XX_STATUS := QTMP->CN9_SITUAC
			(ALIAS_TMP)->(Msunlock())
        NEXT

	   	dbSelectArea("QTMP")
	   	QTMP->(dbSkip())
	ENDDO


    QTMP->(dbCloseArea())
    

	//*********Contrato
	cQuery := " SELECT CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,SUM(D2_TOTAL) AS D2_TOTAL,SUM(D2_VALISS) AS D2_VALISS, SUM(E5_VALOR) AS E5DESC"+CRLF
	cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF
    cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9.CN9_NUMERO = CNF.CNF_CONTRA AND CN9.CN9_REVISA = CNF.CNF_REVISA"+CRLF
    cQuery += "      AND CN9.CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+CRLF
	cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA"+CRLF
	cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CND_PARCEL = CNF_PARCEL"+CRLF
	cQuery += "      AND  CNA_NUMERO = CND_NUMERO AND CND_REVISA = CNF_REVISA"+CRLF
	cQuery += "      AND  CND.D_E_L_E_T_ = ''"+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM"+CRLF
	cQuery += "      AND  C6_FILIAL = CND_FILIAL AND  SC6.D_E_L_E_T_ = ''"+CRLF
	cQuery += "	LEFT JOIN "+RETSQLNAME("SD2")+ " SD2 ON SC6.C6_NUM = SD2.D2_PEDIDO AND C6_ITEM = D2_ITEM  "+CRLF
	cQuery += "      AND  D2_FILIAL = CND_FILIAL AND  SD2.D_E_L_E_T_ = '' "+CRLF
	// 27/02/20   
	cQuery += "LEFT JOIN "+RETSQLNAME("SE5")+" SE5 ON E5_PREFIXO = D2_SERIE AND E5_NUMERO = D2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = D2_CLIENTE AND E5_LOJA = D2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' "+CRLF //--AND E5_PARCELA = '  '
	cQuery += "      AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = '' "+CRLF

    cQuery += " INNER JOIN "+RETSQLNAME("SA1")+" SA1 ON CN9.CN9_CLIENT = SA1.A1_COD "+CRLF 
    cQuery += "      AND CN9.CN9_LOJACL = SA1.A1_LOJA  AND  SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ''"+CRLF

	cQuery += " WHERE CNF.D_E_L_E_T_='' AND CNF.CNF_COMPET='"+aPeriodo[_nI,1]+"' "+CRLF   	//AND CN9.CN9_SITUAC ='"+cSituac+"'"
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
//			cQuery += "AND CN9.CN9_SITUAC ='"+cSituac+"'"
			cQuery += " AND CN9.CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
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
		IF !lJob
			IF !lFurnas
				cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391'"+CRLF
			ENDIF
		ELSE
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) <> '008' "+CRLF //IPT 
	    	//cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) <> '049' " //fundacao florestal
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '247' "+CRLF //IPT 
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391' "+CRLF //FURNAS
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) <> '008' " //IPT 
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) <> '258' "+CRLF
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391' "+CRLF //FURNAS
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '438' "+CRLF  
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '425' "+CRLF
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '455' "+CRLF
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '467' "+CRLF
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '507' "+CRLF
	   		cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '510' "+CRLF
	    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '521' "+CRLF
	    	cQuery += " AND CNF_CONTRA NOT IN ('193000288','194000289','195000290','196000291')"  +CRLF
	    	cQuery += " AND CNF_CONTRA NOT IN ('197000292','198000293','199000294')"  +CRLF
	    	cQuery += " AND CNF_CONTRA NOT IN ('197001292','198001293','199001294')" +CRLF
	    	IF SM0->M0_CODIGO <> "14"  
	    		cQuery += " AND CNF_CONTRA NOT IN ('302000508')"+CRLF
			ENDIF  

		ENDIF

		cQuery += "AND CN9.CN9_SITUAC ='"+cSituac+"'" +CRLF
    ENDIF	

	cQuery += " GROUP BY CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC ORDER BY CNF_CONTRA"+CRLF

 	u_LogMemo("BKGCTR11-CNF-2-"+STRZERO(_nI,3)+".SQL",cQuery)

	TCQUERY cQuery NEW ALIAS "QTMP"


	dbSelectArea("QTMP")
	QTMP->(dbGoTop())
	DO WHILE QTMP->(!EOF())
    

		//Calcula LF Avulso SZ2 - CLT
		cQuery1 := "SELECT Z2_CODEMP,Z2_CC,Z2_VALOR,Z2_TIPO,Z2_CC FROM "+RETSQLNAME("SZ2")+" SZ2"+CRLF
		cQuery1 += " WHERE  D_E_L_E_T_='' AND Z2_TIPO IN ('EXM','VT','VR','VA','DCH')"+CRLF  //REMOVIDO MULTA FGTS POR ENTENDER QUE ESTA EM INCIDENCIAS - TIPO = MFG
		cQuery1 += " AND Z2_TIPOPES='CLT' AND Z2_STATUS='S'"+CRLF

		nScan:= 0
		nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })

		IF nScan > 0 
			cQuery1 += " AND Z2_CODEMP='"+SUBSTR(ALLTRIM(aConsorcio[nScan,2]),1,2)+"'"+CRLF 
			cQuery1 += " AND Z2_CC IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"','"+ALLTRIM(aConsorcio[nScan,7])+"')" +CRLF
		ELSE
			cQuery1 += " AND Z2_CODEMP='"+SM0->M0_CODIGO+"'"+CRLF
			cQuery1 += " AND Z2_CC='"+ALLTRIM(QTMP->CNF_CONTRA)+"'"+CRLF
		ENDIF
		
		cQuery1 += " AND SUBSTRING(Z2_DATAPGT,1,6)='"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'"+CRLF

		u_LogMemo("BKGCTR11-SZ2-"+STRZERO(_nI,3)+".SQL",cQuery1)

		TCQUERY cQuery1 NEW ALIAS "TMPX2"

		dbSelectArea("TMPX2")
		dbGoTop()
		DO While !TMPX2->(EOF())

			IF ALLTRIM(TMPX2->Z2_TIPO) == 'VT'
		   		dbSelectArea(ALIAS_TMP)
		   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'12',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->Z2_VALOR
					(ALIAS_TMP)->(Msunlock())
				ENDIF
   				// GRAVA VALOR NO CUSTO
   				dbSelectArea(ALIAS_TMP)
   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
     				Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->Z2_VALOR
					(ALIAS_TMP)->(Msunlock())
				ENDIF
			ENDIF

			IF  ALLTRIM(TMPX2->Z2_TIPO)  $ 'VR/VA'
		   		dbSelectArea(ALIAS_TMP)
		   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'14',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->Z2_VALOR
					(ALIAS_TMP)->(Msunlock())
				ENDIF
   				// GRAVA VALOR NO CUSTO
   				dbSelectArea(ALIAS_TMP)
   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
     				Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->Z2_VALOR
					(ALIAS_TMP)->(Msunlock())
				ENDIF
			ENDIF
 

			IF  ALLTRIM(TMPX2->Z2_TIPO)  == 'EXM'
				dbSelectArea(ALIAS_TMP)
	   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+cExm_Prod,.F.)
					Reclock(ALIAS_TMP,.F.)
				ELSE
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF( nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
					(ALIAS_TMP)->XX_CODIGO := "W"+cExm_Prod
					(ALIAS_TMP)->XX_DESC   := Posicione("SB1",1,xFilial("SB1")+cExm_Prod,"B1_DESC")

					// Debug
					If EMPTY((ALIAS_TMP)->XX_DESC)
						(ALIAS_TMP)->XX_DESC := "1 - Produto "+cExm_Prod
					EndIf
					
				ENDIF
				cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
				&cCampo2 += TMPX2->Z2_VALOR
				(ALIAS_TMP)->(Msunlock())

	   			dbSelectArea(ALIAS_TMP)
	   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
	     			Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->Z2_VALOR
					(ALIAS_TMP)->(Msunlock())
				ENDIF
			ENDIF

			IF  ALLTRIM(TMPX2->Z2_TIPO)  == 'MFG'
				dbSelectArea(ALIAS_TMP)
	   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+cMFG_Prod,.F.)
					Reclock(ALIAS_TMP,.F.)
				ELSE
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
					(ALIAS_TMP)->XX_CODIGO := "W"+cMFG_Prod
					(ALIAS_TMP)->XX_DESC   := Posicione("SB1",1,xFilial("SB1")+cMFG_Prod,"B1_DESC")

					// Debug
					If EMPTY((ALIAS_TMP)->XX_DESC)
						(ALIAS_TMP)->XX_DESC := "2 - Produto "+cMFG_Prod
					EndIf


				ENDIF
				cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
				&cCampo2 += TMPX2->Z2_VALOR
				(ALIAS_TMP)->(Msunlock())

	   			dbSelectArea(ALIAS_TMP)
	   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
	     			Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->Z2_VALOR
					(ALIAS_TMP)->(Msunlock())
				ENDIF
			ENDIF

			IF  ALLTRIM(TMPX2->Z2_TIPO)  == 'DCH'
				dbSelectArea(ALIAS_TMP)
	   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+cDCH_Prod,.F.)
					Reclock(ALIAS_TMP,.F.)
				ELSE
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
					(ALIAS_TMP)->XX_CODIGO := "W"+cDCH_Prod
					(ALIAS_TMP)->XX_DESC   := Posicione("SB1",1,xFilial("SB1")+cDCH_Prod,"B1_DESC")
					// Debug
					If EMPTY((ALIAS_TMP)->XX_DESC)
						(ALIAS_TMP)->XX_DESC := "3 - Produto "+cDCH_Prod
					EndIf

				ENDIF
				cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
				&cCampo2 += TMPX2->Z2_VALOR
				(ALIAS_TMP)->(Msunlock())

	   			dbSelectArea(ALIAS_TMP)
	   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
	     			Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
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
			cQuery1 += " AND Z2_CC IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"','"+ALLTRIM(aConsorcio[nScan,7])+"')"
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
   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+cBK_Prod,.F.)
				Reclock(ALIAS_TMP,.F.)
			ELSE
				Reclock(ALIAS_TMP,.T.)
				(ALIAS_TMP)->XX_CODGCT := IIF( nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
				(ALIAS_TMP)->XX_CODIGO := "W"+cBK_Prod
				(ALIAS_TMP)->XX_DESC   := Posicione("SB1",1,xFilial("SB1")+cBK_Prod,"B1_DESC")
				// Debug
				If EMPTY((ALIAS_TMP)->XX_DESC)
					(ALIAS_TMP)->XX_DESC := "4 - Produto "+cBK_Prod
				EndIf
			ENDIF
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			&cCampo2 += TMPX2->Z2_VALOR
			(ALIAS_TMP)->(Msunlock())

   			dbSelectArea(ALIAS_TMP)
   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
     			Reclock(ALIAS_TMP,.F.)
				cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
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


		IncProc("Consultando Folha Pagamento...")
		//*********Folha Pagamento
		cQuery2 := "select bk_senior.bk_senior.R046VER.CodEve,bk_senior.bk_senior.R008EVC.DesEve,COUNT(bk_senior.bk_senior.R046VER.CodEve) AS nCont,SUM(bk_senior.bk_senior.R046VER.ValEve) as valevent,"+CRLF
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
 		cQuery2 += " INNER JOIN bk_senior.bk_senior.R008EVC ON bk_senior.bk_senior.R046VER.TabEve = bk_senior.bk_senior.R008EVC.CodTab" +CRLF
 		cQuery2 += " AND bk_senior.bk_senior.R046VER.CodEve = bk_senior.bk_senior.R008EVC.CodEve" +CRLF

 			//TRATAMENTO ESPECIAL CONTRATO BKDAHER

		nScan:= 0
		nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })   


		IF nScan > 0 
			cQuery2 += " Where bk_senior.bk_senior.R046VER.NumEmp='"+SUBSTR(ALLTRIM(aConsorcio[nScan,2]),1,2)+"' and Tipcal In(11) And Sitcal = 'T' "+CRLF
 			cQuery2 += " AND PerRef ='"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"01'"+CRLF
			cQuery2 += " AND BKIntegraRubi.dbo.CUSTOSIGA.ccSiga IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"','"+ALLTRIM(aConsorcio[nScan,7])+"')"+CRLF
		ELSE
			cQuery2 += " Where bk_senior.bk_senior.R046VER.NumEmp='"+SM0->M0_CODIGO+"' and Tipcal In(11) And Sitcal = 'T' "+CRLF
	 		cQuery2 += " AND PerRef ='"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"01'"+CRLF
 			cQuery2 += " AND BKIntegraRubi.dbo.CUSTOSIGA.ccSiga = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'"+CRLF
 		ENDIF

		cQuery2 += " group by bk_senior.bk_senior.R046VER.CodEve,bk_senior.bk_senior.R008EVC.DesEve"+CRLF
		     	
		u_LogMemo("BKGCTR11-FOL-"+STRZERO(_nI,3)+".SQL",cQuery2)

		TCQUERY cQuery2 NEW ALIAS "TMPX2"
		
		nProventos := 0
		nCusto     := 0
		nXXPLR	   := 0	
		dbSelectArea("TMPX2")  
		dbGoTop()
		DO While !TMPX2->(EOF())

			cCtrCons := IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
			cCodEve  := ALLTRIM(STR(TMPX2->CodEve))
			cPCodEve := "|"+cCodEve+"|"
			
			IF cPCodEve $ cProventos
		    	nProventos += TMPX2->valevent
				UpdTmpFol(lJob,cContrato,cCodEve,TMPX2->DesEve,"01-Proventos",TMPX2->valevent,_nI)
			ENDIF
			IF cPCodEve $ cDescontos
		    	nProventos -= TMPX2->valevent 
				UpdTmpFol(lJob,cContrato,cCodEve,TMPX2->DesEve,"02-Descontos",-TMPX2->valevent,_nI)
			ENDIF
			IF cPCodEve $ cXXPLR
		    	nXXPLR += TMPX2->valevent 
			ENDIF

			IF cPCodEve $ cVT_Prov
		   		dbSelectArea(ALIAS_TMP)
		   		IF MsSeek(cCtrCons+'12',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->valevent
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += TMPX2->valevent  
				ENDIF
			ENDIF

			IF cPCodEve  $ cVT_Verb
		   		dbSelectArea(ALIAS_TMP)
		   		IF MsSeek(cCtrCons+'13',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->valevent *-1)
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += (TMPX2->valevent *-1)  
				ENDIF
			ENDIF
			
			IF cPCodEve $ cVRVA_Verb
		   		dbSelectArea(ALIAS_TMP)
		   		IF MsSeek(cCtrCons+'15',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->valevent *-1)
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += (TMPX2->valevent *-1)  
				ENDIF
			ENDIF

			IF cPCodEve $ cASSM_Prod
		   		dbSelectArea(ALIAS_TMP)
		   		IF MsSeek(cCtrCons+'16',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->valevent
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += TMPX2->valevent  
				ENDIF
			ENDIF

			IF cPCodEve $ cASSM_Verb
		   		dbSelectArea(ALIAS_TMP)
		   		IF MsSeek(cCtrCons+'17',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->valevent *-1)
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += (TMPX2->valevent *-1)  
				ENDIF
			ENDIF

			IF cPCodEve $ cSINO_Prod
		   		dbSelectArea(ALIAS_TMP)
		   		IF MsSeek(cCtrCons+'18',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += IIF(TMPX2->VALASSOD<>0,TMPX2->VALASSOD * TMPX2->nCont,TMPX2->VALEVENT )
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += IIF(TMPX2->VALASSOD<>0,TMPX2->VALASSOD * TMPX2->nCont,TMPX2->VALEVENT )
				ENDIF
			ENDIF

			IF cPCodEve $ cSINO_Verb
		   		dbSelectArea(ALIAS_TMP)
		   		IF MsSeek(cCtrCons+'19',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->valevent *-1)
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += (TMPX2->valevent *-1)  
				ENDIF
			ENDIF

			IF cPCodEve $ cCCRE_Verb
		   		dbSelectArea(ALIAS_TMP)
		   		IF MsSeek(cCtrCons+'21',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->valevent *-1)
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += (TMPX2->valevent *-1)  
				ENDIF
			ENDIF

			IF cPCodEve $ cNINC_Verb
				UpdTmpFol(lJob,cContrato,cCodEve,TMPX2->DesEve,"03-Sem Encargos/Incidencias",TMPX2->valevent,_nI)
		   		dbSelectArea(ALIAS_TMP)
		   		IF MsSeek(cCtrCons+'111',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->valevent)
					(ALIAS_TMP)->(Msunlock())
		    		nCusto += (TMPX2->valevent)  
				ENDIF
			ENDIF

			
			dbSelectArea("TMPX2")
			dbSkip()
		ENDDO

   		dbSelectArea(ALIAS_TMP)
   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'09',.F.)
     		Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
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
   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'10',.F.)
     		Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			&cCampo2 += (nProventos*nEncargos)/100
			(ALIAS_TMP)->(Msunlock())
    		nCusto += (nProventos*nEncargos)/100  
		ENDIF

   		dbSelectArea(ALIAS_TMP)
   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'11',.F.)
     		Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			&cCampo2 += (nProventos*nINCIDENCI)/100
			(ALIAS_TMP)->(Msunlock())
    		nCusto += (nProventos*nINCIDENCI)/100 
		ENDIF

   		dbSelectArea(ALIAS_TMP)
   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'110',.F.)
     		Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			&cCampo2 += nXXPLR
			(ALIAS_TMP)->(Msunlock())
    		nCusto += nXXPLR
		ENDIF
		
		// GRAVA VALOR NO CUSTO
		dbSelectArea(ALIAS_TMP)
		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			&cCampo2 += nCusto
			(ALIAS_TMP)->(Msunlock())
		ENDIF

		TMPX2->(dbCloseArea())


		IncProc("Consultando Folha Pagamento - Autonomos...")
		//*********Folha Pagamento - Autonomos IPT
		cQuery2 := "SELECT SUM(ValorRPA) AS ValorRPA,SUM(Refeicao) AS Refeicao" 
		cQuery2 += " FROM  webLancamentoIPT.dbo.LancamentoIPT "
		cQuery2 += " WHERE (AC = 0) AND (adiantamento = 0) AND (integrado = 1) " 
		cQuery2 += "   AND competencia ='"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'"

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
			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
				Reclock(ALIAS_TMP,.F.)
				cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
				&cCampo2 += TMPX2->ValorRPA+((TMPX2->ValorRPA*nEncarIPT)/100)-TMPX2->Refeicao
				(ALIAS_TMP)->(Msunlock())
			ENDIF

	   		dbSelectArea(ALIAS_TMP)
	   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'09',.F.)
	     		Reclock(ALIAS_TMP,.F.)
				cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
				&cCampo2 += TMPX2->ValorRPA
				(ALIAS_TMP)->(Msunlock())
			ENDIF
	
	   		dbSelectArea(ALIAS_TMP)
	   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'10',.F.)
	     		Reclock(ALIAS_TMP,.F.)
				cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
				&cCampo2 += (TMPX2->ValorRPA*nEncarIPT)/100
				(ALIAS_TMP)->(Msunlock())
			ENDIF
	
	   		dbSelectArea(ALIAS_TMP)
	   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'15',.F.)
	     		Reclock(ALIAS_TMP,.F.)
				cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
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
		cQuery3 += " AND CN9_NUMERO = '"+ALLTRIM(QTMP->CNF_CONTRA)+"' AND CN9_SITUAC='"+ALLTRIM(QTMP->CN9_SITUAC)+"'" // ='"+cSituac+"'" 

		TCQUERY cQuery3 NEW ALIAS "QTMPX3"
		TCSETFIELD("QTMPX3","CNF_INICIO","D",8,0)	
		TCSETFIELD("QTMPX3","CNF_FIM","D",8,0)	

		dbSelectArea("QTMPX3")
		dDataVenc := QTMPX3->CNF_FIM

		QTMPX3->(Dbclosearea())



		nScan:= 0
		nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })

		IncProc("Consultando gastos gerais..."+STRZERO(_nI,3))


		//*********GASTOS GERAIS
		cQuery2 := "SELECT D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC,SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) AS D1_TOTAL"+CRLF
		cQuery2 += " FROM "+RETSQLNAME("SD1")+" SD1" +CRLF
		cQuery2 += " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D1_COD = B1_COD  AND SB1.D_E_L_E_T_ = '' " +CRLF
		cQuery2 += " WHERE SUBSTRING(D1_DTDIGIT,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"' AND SD1.D_E_L_E_T_ = '' "+CRLF
		cQuery2 += " AND D1_CC = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'"+CRLF
		IF SM0->M0_CODIGO == "01"  .AND. ALLTRIM(QTMP->CNF_CONTRA)=="313000504" // Despesas médicas 
			cQuery2 += " AND D1_FORNECE<>'002918'"+CRLF
		ENDIF 
		IF SM0->M0_CODIGO == "14"  // Despesas médicas 
			cQuery2 += " AND D1_FORNECE<>'000604'"+CRLF
		ENDIF 
		//// Para teste de alugueis: 
		//cQuery2 += " AND (D1_COD = '000000000000102' OR D1_COD = '320200301')  "+CRLF  // AND D1_FORNECE = '004190'

//		cQuery2 += IIF(nScan > 0," AND SUBSTRING(D1_CONTA,1,3) <> '113' "," AND (SUBSTRING(D1_CONTA,1,1) = '3' OR D1_CONTA in ('29104004','12201006','12201005','12201010'))")  +CRLF
		cQuery2 += IIF(nScan > 0," AND SUBSTRING(D1_CONTA,1,3) <> '113' "," AND (SUBSTRING(D1_CONTA,1,1) = '3' OR D1_CONTA in ('29104004') OR SUBSTRING(D1_CONTA,1,5) = '12201')") +CRLF
		cQuery2 += " GROUP BY D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC"+CRLF

		cQuery2 += " UNION ALL"+CRLF
		cQuery2 += " SELECT D3_FILIAL,MAX(' '),MAX(' '),MAX(' '),MAX(' '),D3_COD,B1_DESC,B1_GRUPO,D3_CC,SUM(D3_CUSTO1) FROM "+RETSQLNAME("SD3")+" SD3"+CRLF
		cQuery2 += " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D3_COD = B1_COD  AND SB1.D_E_L_E_T_ = '' "+CRLF
		cQuery2 += " WHERE SD3.D_E_L_E_T_='' AND D3_TM='5"+SM0->M0_CODIGO+"' AND SUBSTRING(D3_EMISSAO,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'"+CRLF
		cQuery2 += " AND D3_CC = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'"+CRLF
//		cQuery2 += IIF(nScan > 0," AND SUBSTRING(D3_CONTA,1,3) <> '113' "," AND (SUBSTRING(D3_CONTA,1,1) = '3' OR D3_CONTA in ('29104004','12201006','12201005','12201010'))") 
		cQuery2 += IIF(nScan > 0," AND SUBSTRING(D3_CONTA,1,3) <> '113' "," AND (SUBSTRING(D3_CONTA,1,1) = '3' OR D3_CONTA in ('29104004') OR SUBSTRING(D3_CONTA,1,5) = '12201')") +CRLF
		cQuery2 += " GROUP BY  D3_FILIAL,D3_COD,B1_DESC,B1_GRUPO,D3_CC"+CRLF

		//cQuery2 += " ORDER BY B1_DESC"+CRLF

		u_LogMemo("BKGCTR11-D1-1-"+STRZERO(_nI,3)+".SQL",cQuery2)
		        
		TCQUERY cQuery2 NEW ALIAS "TMPX2"
		cOUTROS := 'S'

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

				cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'12',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,"N",.T.,"")

				/*
		   		dbSelectArea(ALIAS_TMP)
		   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->D1_CC))+'12',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->D1_TOTAL
					(ALIAS_TMP)->(Msunlock())
					cOutros := 'N'
				ENDIF
				*/


				cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'08',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,"")

				/*
   				// GRAVA VALOR NO CUSTO
   				dbSelectArea(ALIAS_TMP)
   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->D1_CC))+'08',.F.)
     				Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->D1_TOTAL
					(ALIAS_TMP)->(Msunlock())
				ENDIF
				*/

			ENDIF

			IF "|"+ALLTRIM(TMPX2->D1_COD)+"|" $ cVRVA_Prod


				cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'14',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,"N",.T.,"")

				/*
		   		dbSelectArea(ALIAS_TMP)
		   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->D1_CC))+'14',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->D1_TOTAL
					(ALIAS_TMP)->(Msunlock())
					cOutros := 'N'
				ENDIF
				*/

				cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'08',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,"")

   				// GRAVA VALOR NO CUSTO
				/*
   				dbSelectArea(ALIAS_TMP)
   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->D1_CC))+'08',.F.)
     				Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->D1_TOTAL
					(ALIAS_TMP)->(Msunlock())
				ENDIF
				*/
			ENDIF

			IF "|"+ALLTRIM(TMPX2->D1_COD)+"|" $ cCCRE_Prod


				cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'20',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,"N",.T.,"")
				/*
		   		dbSelectArea(ALIAS_TMP)
		   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->D1_CC))+'20',.F.)
		     		Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->D1_TOTAL
					(ALIAS_TMP)->(Msunlock())
					cOutros := 'N'
				ENDIF
				*/

				cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'08',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,"")
   				// GRAVA VALOR NO CUSTO
				/*
   				dbSelectArea(ALIAS_TMP)
   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->D1_CC))+'08',.F.)
     				Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->D1_TOTAL
					(ALIAS_TMP)->(Msunlock())
				ENDIF
				*/
			ENDIF

			IF "|"+ALLTRIM(TMPX2->D1_COD)+"|" $ cCDPR_Prod .OR. "|"+ALLTRIM(TMPX2->B1_GRUPO)+"|" $ cCDPR_GRUP;
				 	.OR. U_RatCtrPrd(ALLTRIM(TMPX2->D1_CC),ALLTRIM(TMPX2->D1_COD),aRatCtrPrd)
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
				lPRat := .T.

			    FOR XI_ := _nI TO nParcela
	   				dbSelectArea(ALIAS_TMP)
					
					/*
	   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->D1_CC))+'30',.F.)
						Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(XI_,3)
						&cCampo2 += nValRat
						(ALIAS_TMP)->(Msunlock())

					ELSE
						Reclock(ALIAS_TMP,.T.)
						(ALIAS_TMP)->XX_CODGCT := IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->D1_CC))
						(ALIAS_TMP)->XX_CODIGO := '30'
						(ALIAS_TMP)->XX_DESC   := "GASTOS GERAIS"

						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(XI_,3)
						&cCampo2 += nValRat
						(ALIAS_TMP)->(Msunlock())
					ENDIF
					*/

					/* retirado em 20/07/20
	   				IF !dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->D1_CC))+'30',.F.)
						Reclock(ALIAS_TMP,.T.)
						(ALIAS_TMP)->XX_CODGCT := IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->D1_CC))
						(ALIAS_TMP)->XX_CODIGO := '30'
						(ALIAS_TMP)->XX_DESC   := "GASTOS GERAIS"
						(ALIAS_TMP)->(Msunlock())
					EndIf
					*/
					
					cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'30',XI_,nValRat,aAcrDcr,cOutros,cOutros,lPRat,"")

					/*
					dbSelectArea(ALIAS_TMP)
	   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->D1_CC))+"W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC)))),.F.)
						Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(XI_,3)
						&cCampo2 += nValRat
						(ALIAS_TMP)->(Msunlock())
					ELSE
						Reclock(ALIAS_TMP,.T.)
						(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(TMPX2->D1_CC))
						(ALIAS_TMP)->XX_CODIGO := "W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
						(ALIAS_TMP)->XX_DESC   := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(XI_,3)
						&cCampo2 += nValRat
						(ALIAS_TMP)->(Msunlock())
					ENDIF
					*/

					cCodCC := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
	   				///IF !dbSeek(IIF(nConsol>0,"999999999",PAD(TMPX2->D1_CC,nTamCodGct))+PAD("W"+cCodCC,nTamCodigo),.F.)
					///	Reclock(ALIAS_TMP,.T.)
					///	(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(TMPX2->D1_CC))
					///	(ALIAS_TMP)->XX_CODIGO := "W"+cCodCC
					///	(ALIAS_TMP)->XX_DESC   := cCodCC
					///	(ALIAS_TMP)->(Msunlock())
					///ENDIF

					cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,"W"+cCodCC,XI_,nValRat,aAcrDcr,cOutros,cOutros,lPRat,cCodCC)

					lPRat   := .F.
				NEXT
            ENDIF
			IF cOutros == 'S'
				dbSelectArea(ALIAS_TMP)
				/*
	   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->D1_CC))+"W"+ALLTRIM(TMPX2->D1_COD),.F.)
					Reclock(ALIAS_TMP,.F.)
				ELSE
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(TMPX2->D1_CC))
					(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->D1_COD)
					(ALIAS_TMP)->XX_DESC   := ALLTRIM(TMPX2->B1_DESC)
					// Debug
					If EMPTY((ALIAS_TMP)->XX_DESC)
						(ALIAS_TMP)->XX_DESC := "5 - Produto "+ALLTRIM(TMPX2->D1_COD)
					EndIf
				ENDIF
				cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
				&cCampo2 += TMPX2->D1_TOTAL
				(ALIAS_TMP)->(Msunlock())
				*/

				///IF !dbSeek(IIF(nConsol>0,"999999999",PAD(TMPX2->D1_CC,nTamCodGct))+"W"+PAD(TMPX2->D1_COD,nTamCodigo),.F.)
				///	Reclock(ALIAS_TMP,.T.)
				///	(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(TMPX2->D1_CC))
				///	(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->D1_COD)
				///	(ALIAS_TMP)->XX_DESC   := ALLTRIM(TMPX2->B1_DESC)
				///	// Debug
				///	If EMPTY((ALIAS_TMP)->XX_DESC)
				///		(ALIAS_TMP)->XX_DESC := "5 - Produto "+ALLTRIM(TMPX2->D1_COD)
				///	EndIf
				///ENDIF

				cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,"W"+TMPX2->D1_COD,_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,TMPX2->B1_DESC)

	   			/*
				   dbSelectArea(ALIAS_TMP)
	   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->D1_CC))+'30',.F.)
	     			Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->D1_TOTAL
					(ALIAS_TMP)->(Msunlock())
				ENDIF
				*/

				cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'30',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,"")


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
			cQuery2 += " FROM SD1"+ALLTRIM(aConsorcio[nScan,2])+" SD1"+CRLF
			//cQuery2 += " INNER JOIN SA2"+ALLTRIM(aConsorcio[nScan,2])+" SA2 ON D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ''"+CRLF
			cQuery2 += " INNER JOIN SB1"+ALLTRIM(aConsorcio[nScan,2])+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D1_COD = B1_COD  AND SB1.D_E_L_E_T_ = '' " +CRLF                                       
			//cQuery2 += " INNER JOIN CTT"+ALLTRIM(aConsorcio[nScan,2])+" CTT ON D1_FILIAL = CTT_FILIAL AND D1_CC = CTT_CUSTO AND CTT.D_E_L_E_T_ = ''"+CRLF
			cQuery2 += " WHERE SUBSTRING(D1_DTDIGIT,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"' AND SD1.D_E_L_E_T_ = '' "+CRLF
			//cQuery2 += " AND D1_CC = '000000001'"
			IF SM0->M0_CODIGO == "01"  .AND. ALLTRIM(QTMP->CNF_CONTRA)=="313000504" // Despesas médicas 
				cQuery2 += " AND D1_FORNECE<>'002918'"+CRLF
			ENDIF 
			IF SM0->M0_CODIGO == "14"   // Despesas médicas
				cQuery2 += " AND D1_FORNECE<>'000604'"+CRLF
			ENDIF 
			IF ALLTRIM(aConsorcio[nScan,2]) == "140"
				cQuery2 += " AND D1_CC IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"')" +CRLF
            ELSE
				cQuery2 += " AND D1_CC IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"','"+ALLTRIM(aConsorcio[nScan,7])+"')"+CRLF
			ENDIF
			cQuery2 += " AND SUBSTRING(D1_CONTA,1,1) <> '2' AND SUBSTRING(D1_CONTA,1,3) <> '113' " +CRLF 
			//cQuery2 += " GROUP BY  D1_FILIAL,D1_COD,B1_DESC,B1_GRUPO,D1_CC"+CRLF
			cQuery2 += " GROUP BY D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC"+CRLF
			//cQuery2 += " ORDER BY B1_DESC"+CRLF

			u_LogMemo("BKGCTR11-D1-2-"+STRZERO(_nI,3)+".SQL",cQuery2)
	        
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
						cLastE2 :=  TMPX2->D1_SERIE+TMPX2->D1_DOC+TMPX2->D1_FORNECE+TMPX2->D1_LOJA
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

					cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'12',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"")

					/*
			   		dbSelectArea(ALIAS_TMP)
			   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'12',.F.)
			     		Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
						&cCampo2 +=  IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
						(ALIAS_TMP)->(Msunlock())
						cOutros := 'N'
					ENDIF
					*/

					cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"")

					/*
	   				// GRAVA VALOR NO CUSTO
	   				dbSelectArea(ALIAS_TMP)
	   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
	     				Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
						&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
						(ALIAS_TMP)->(Msunlock())
					ENDIF
					*/

				ENDIF
	
				IF "|"+ALLTRIM(TMPX2->D1_COD)+"|" $ cVRVA_Prod

					cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'14',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"")

					/*
			   		dbSelectArea(ALIAS_TMP)
			   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'14',.F.)
			     		Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
						&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
						(ALIAS_TMP)->(Msunlock())
						cOUTROS := 'N'
					ENDIF
					*/

					cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"")
					/*
	   				// GRAVA VALOR NO CUSTO
	   				dbSelectArea(ALIAS_TMP)
	   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
	     				Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
						&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
						(ALIAS_TMP)->(Msunlock())
					ENDIF
					*/
				ENDIF

				IF "|"+ALLTRIM(TMPX2->D1_COD)+"|" $ cCCRE_Prod


					cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'20',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"")

					/*
			   		dbSelectArea(ALIAS_TMP)
			   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'20',.F.)
			     		Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
						&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
						(ALIAS_TMP)->(Msunlock())
						cOUTROS := 'N'
					ENDIF
					*/

					cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"")
	   				/*
					// GRAVA VALOR NO CUSTO
	   				dbSelectArea(ALIAS_TMP)
	   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
	     				Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
						&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
						(ALIAS_TMP)->(Msunlock())
					ENDIF
					*/
				ENDIF
	
				IF "|"+ALLTRIM(TMPX2->D1_COD)+"|" $ cCDPR_Prod .OR. "|"+ALLTRIM(TMPX2->B1_GRUPO)+"|" $ cCDPR_GRUP ;
						.OR. U_RatCtrPrd(ALLTRIM(TMPX2->D1_CC),ALLTRIM(TMPX2->D1_COD),aRatCtrPrd)
					cOUTROS := 'N'
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
					lPRat := .T.

				    FOR XI_ := _nI TO nParcela

		   				dbSelectArea(ALIAS_TMP)
						nAuxVl := IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)

						/*
		   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
							Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(XI_,3)
							&cCampo2 +=  IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
							(ALIAS_TMP)->(Msunlock())
						ELSE
							Reclock(ALIAS_TMP,.T.)
							(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
							(ALIAS_TMP)->XX_CODIGO := '30'
							(ALIAS_TMP)->XX_DESC   := "GASTOS GERAIS"
	
							cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(XI_,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
							(ALIAS_TMP)->(Msunlock())
						ENDIF
						*/

						cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,"")

						/*
						dbSelectArea(ALIAS_TMP)
		   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC)))),.F.)
							Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(XI_,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
							(ALIAS_TMP)->(Msunlock())
						ELSE
							Reclock(ALIAS_TMP,.T.)
							(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
							(ALIAS_TMP)->XX_CODIGO := "W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
							(ALIAS_TMP)->XX_DESC   := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
							cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(XI_,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
							(ALIAS_TMP)->(Msunlock())
						ENDIF
						*/

						cCodCC := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
						///IF !dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+cCodCC,.F.)
						///	Reclock(ALIAS_TMP,.T.)
						///	(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
						///	(ALIAS_TMP)->XX_CODIGO := "W"+cCodCC
						///	(ALIAS_TMP)->XX_DESC   := cCodCC
						///	(ALIAS_TMP)->(Msunlock())
						///ENDIF

						cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+cCodCC,XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,cCodCC)

						lPRat   := .F.
					NEXT
	            ENDIF

				IF cOutros == 'S'
					dbSelectArea(ALIAS_TMP)

					nAuxVl := IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)

					/*
		   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->D1_COD),.F.)
						Reclock(ALIAS_TMP,.F.)
					ELSE
						Reclock(ALIAS_TMP,.T.)
						(ALIAS_TMP)->XX_CODGCT := IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
						(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->D1_COD)
						(ALIAS_TMP)->XX_DESC   := ALLTRIM(TMPX2->B1_DESC)
						// Debug
						If EMPTY((ALIAS_TMP)->XX_DESC)
							(ALIAS_TMP)->XX_DESC := "6 - Produto "+ALLTRIM(TMPX2->D1_COD)
						EndIf
					ENDIF
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL /VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL )
					(ALIAS_TMP)->(Msunlock())
					*/

					///IF !dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->D1_COD),.F.)
					///	Reclock(ALIAS_TMP,.T.)
					///	(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
					///	(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->D1_COD)
					///	(ALIAS_TMP)->XX_DESC   := ALLTRIM(TMPX2->B1_DESC)
					///	// Debug
					///	If EMPTY((ALIAS_TMP)->XX_DESC)
					///		(ALIAS_TMP)->XX_DESC := "6 - Produto "+ALLTRIM(TMPX2->D1_COD)
					///	EndIf
					///ENDIF

					cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+TMPX2->D1_COD,_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,TMPX2->B1_DESC)


		   			/*
					dbSelectArea(ALIAS_TMP)
		   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
		     			Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
						&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL /VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL )
						(ALIAS_TMP)->(Msunlock())
					ENDIF
					*/

					cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"")

				ENDIF
				
				dbSelectArea("TMPX2")
				dbSkip()
			ENDDO
			TMPX2->(dbCloseArea())
			
			cQuery2 := "SELECT E5_CREDITO,E5_DEBITO,CT1_DESC01,E5_VALOR,E5_RECPAG,E5_CCC,E5_CCD,E5_VENCTO"+CRLF
			cQuery2 += " FROM SE5"+ALLTRIM(aConsorcio[nScan,2])+" SE5" +CRLF
			cQuery2 += " LEFT JOIN CT1"+ALLTRIM(aConsorcio[nScan,2])+" CT1 ON CT1_FILIAL = '"+xFilial("CT1")+"' AND (CT1_CONTA=E5_DEBITO OR CT1_CONTA=E5_CREDITO) AND CT1.D_E_L_E_T_=''"+CRLF
			cQuery2 += " WHERE SE5.D_E_L_E_T_='' AND (SUBSTRING(E5_DEBITO,1,1)='3' OR SUBSTRING(E5_CREDITO,1,1)='3' )  AND E5_SITUACA<>'C'"+CRLF
			cQuery2 += " AND SUBSTRING(E5_VENCTO,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'"+CRLF

			u_LogMemo("BKGCTR11-E5-1-"+STRZERO(_nI,3)+".SQL",cQuery2)


			TCQUERY cQuery2 NEW ALIAS "TMPX2"
			dbSelectArea("TMPX2")
			dbGoTop()
			DO While !TMPX2->(EOF()) 
				dbSelectArea(ALIAS_TMP)
	   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->CT1_DESC01),.F.)
					Reclock(ALIAS_TMP,.F.)
				ELSE
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
					(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->CT1_DESC01)
					(ALIAS_TMP)->XX_DESC   := ALLTRIM("*"+TMPX2->CT1_DESC01)
					// Debug
					If EMPTY(TMPX2->CT1_DESC01)
						(ALIAS_TMP)->XX_DESC := "*7 - CT1 "
					EndIf
				ENDIF
				cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
				&cCampo2 += (TMPX2->E5_VALOR /VAL(aConsorcio[nScan,5])) * IIF(TMPX2->E5_RECPAG=='R',-1,1)
				(ALIAS_TMP)->(Msunlock())

	   			dbSelectArea(ALIAS_TMP)
	   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
	     			Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->E5_VALOR /VAL(aConsorcio[nScan,5])) * IIF(TMPX2->E5_RECPAG=='R',-1,1)
					(ALIAS_TMP)->(Msunlock())
				ENDIF
				dbSelectArea("TMPX2")
				dbSkip()
			ENDDO
			TMPX2->(dbCloseArea())

			 //Consorcio balsa nova
	  		IF LEN(aConsorcio[nScan]) > 7
			   	cQuery2 := "SELECT D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC,SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) AS D1_TOTAL"
				cQuery2 += " FROM SD1"+ALLTRIM(aConsorcio[nScan,8])+" SD1" 
				cQuery2 += " INNER JOIN SB1"+ALLTRIM(aConsorcio[nScan,8])+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D1_COD = B1_COD  AND SB1.D_E_L_E_T_ = '' "                                        
				cQuery2 += " WHERE SUBSTRING(D1_DTDIGIT,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"' AND SD1.D_E_L_E_T_ = '' "
				IF SM0->M0_CODIGO == "01"  .AND. ALLTRIM(QTMP->CNF_CONTRA)=="313000504" // Despesas médicas 
					cQuery2 += " AND D1_FORNECE<>'002918'"
				ENDIF 
				IF SM0->M0_CODIGO == "14"   
					cQuery2 += " AND D1_FORNECE<>'000604'"
				ENDIF 
				cQuery2 += " AND D1_CC = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'"
				cQuery2 += " AND SUBSTRING(D1_CONTA,1,1) <> '2' AND SUBSTRING(D1_CONTA,1,3) <> '113' "  
				cQuery2 += " GROUP BY D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC"
				//cQuery2 += " ORDER BY B1_DESC"
				
				//u_xxLog("\TMP\BKGCTR11-D1-3.SQL",cQuery2,.F.,"TESTE")        
				cLastE2 := "-"
				aAcrDcr := {}

		        
				TCQUERY cQuery2 NEW ALIAS "TMPX2"
				cOUTROS := 'S'
				dbSelectArea("TMPX2")
				dbGoTop()
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

					cOUTROS := 'S'

					nAuxVl := IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)

					IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cVT_Prod

						cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'12',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"")

						cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"")
				   		/*
				   		dbSelectArea(ALIAS_TMP)
						IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'12',.F.)
				     		Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
							&cCampo2 +=  IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
							(ALIAS_TMP)->(Msunlock())
							cOUTROS := 'N'
						ENDIF
		   				// GRAVA VALOR NO CUSTO
		   				dbSelectArea(ALIAS_TMP)
		   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
		     				Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
							(ALIAS_TMP)->(Msunlock())
						ENDIF
						*/

					ENDIF
		
					IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cVRVA_Prod

						cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'14',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"")

						cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"")

						/*
				   		dbSelectArea(ALIAS_TMP)
				   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'14',.F.)
				     		Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
							(ALIAS_TMP)->(Msunlock())
							cOUTROS := 'N'
						ENDIF
		   				// GRAVA VALOR NO CUSTO
		   				dbSelectArea(ALIAS_TMP)
		   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
		     				Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
							(ALIAS_TMP)->(Msunlock())
						ENDIF
						*/
					ENDIF
	
					IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cCCRE_Prod

						cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'20',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"")

						cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"")

						/*
				   		dbSelectArea(ALIAS_TMP)
				   		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'20',.F.)
				     		Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
							(ALIAS_TMP)->(Msunlock())
							cOUTROS := 'N'
						ENDIF
		   				// GRAVA VALOR NO CUSTO
		   				dbSelectArea(ALIAS_TMP)
		   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'08',.F.)
		     				Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
							(ALIAS_TMP)->(Msunlock())
						ENDIF
						*/
					ENDIF
		
					IF "|"+ALLTRIM(TMPX2->D1_COD)+"|" $ cCDPR_Prod .OR. "|"+ALLTRIM(TMPX2->B1_GRUPO)+"|" $ cCDPR_GRUP;
							 .OR. U_RatCtrPrd(ALLTRIM(TMPX2->D1_CC),ALLTRIM(TMPX2->D1_COD),aRatCtrPrd)
						cOUTROS := 'N'
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
						lPRat := .T.
		
					    FOR XI_ := _nI TO nParcela
			   				dbSelectArea(ALIAS_TMP)
							
							nAuxVl := IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)

							/*   
			   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
								Reclock(ALIAS_TMP,.F.)
								cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(XI_,3)
								&cCampo2 +=  IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
								(ALIAS_TMP)->(Msunlock())
							ELSE
								Reclock(ALIAS_TMP,.T.)
								(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
								(ALIAS_TMP)->XX_CODIGO := '30'
								(ALIAS_TMP)->XX_DESC   := "GASTOS GERAIS"
		
								cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(XI_,3)
								&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
								(ALIAS_TMP)->(Msunlock())
							ENDIF
							*/

							cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,"")

							/*
							dbSelectArea(ALIAS_TMP)
			   				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC)))),.F.)
								Reclock(ALIAS_TMP,.F.)
								cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(XI_,3)
								&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
								(ALIAS_TMP)->(Msunlock())
							ELSE
								Reclock(ALIAS_TMP,.T.)
								(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
								(ALIAS_TMP)->XX_CODIGO := "W"+IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
								(ALIAS_TMP)->XX_DESC   := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
								cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(XI_,3)
								&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
								(ALIAS_TMP)->(Msunlock())
							ENDIF
							*/
							cCodCC := IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0008','UNIFORME',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0009','MATERIAL DE SEGURANCA',IIF(ALLTRIM(TMPX2->B1_GRUPO) == '0010','INSUMOS',ALLTRIM(TMPX2->B1_DESC))))
							///IF !dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+cCodCC,.F.)
							///	Reclock(ALIAS_TMP,.T.)
							///	(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
							///	(ALIAS_TMP)->XX_CODIGO := "W"+cCodCC
							///	(ALIAS_TMP)->XX_DESC   := cCodCC
							///	(ALIAS_TMP)->(Msunlock())
							///ENDIF

							cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+cCodCC,XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,cCodCC)

							lPRat   := .F.
						NEXT
		            ENDIF

					IF cOUTROS == 'S'

						nAuxVl := IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)

						/*
						dbSelectArea(ALIAS_TMP)
			   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->D1_COD),.F.)
							Reclock(ALIAS_TMP,.F.)
						ELSE
							Reclock(ALIAS_TMP,.T.)
							(ALIAS_TMP)->XX_CODGCT := IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
							(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->D1_COD)
							(ALIAS_TMP)->XX_DESC   := ALLTRIM(TMPX2->B1_DESC)
							// Debug
							If EMPTY((ALIAS_TMP)->XX_DESC)
								(ALIAS_TMP)->XX_DESC := "8 - Produto "+ALLTRIM(TMPX2->D1_COD)
							EndIf
						ENDIF
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
						&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL /VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL )
						(ALIAS_TMP)->(Msunlock())
						*/
		
						///IF !dbSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->D1_COD),.F.)
						///	Reclock(ALIAS_TMP,.T.)
						///	(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
						///	(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->D1_COD)
						///	(ALIAS_TMP)->XX_DESC   := ALLTRIM(TMPX2->B1_DESC)
						///	// Debug
						///	If EMPTY((ALIAS_TMP)->XX_DESC)
						///		(ALIAS_TMP)->XX_DESC := "8 - Produto "+ALLTRIM(TMPX2->D1_COD)
						///	EndIf
						///ENDIF

						cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+TMPX2->D1_COD,_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,TMPX2->B1_DESC)


						/*
			   			dbSelectArea(ALIAS_TMP)
			   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
			     			Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL /VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL )
							(ALIAS_TMP)->(Msunlock())
						ENDIF
						*/

						cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"")
					ENDIF
					
					dbSelectArea("TMPX2")
					dbSkip()
				ENDDO
				TMPX2->(dbCloseArea())
		  	

				cQuery2 := "SELECT E5_CREDITO,E5_DEBITO,CT1_DESC01,E5_VALOR,E5_RECPAG,E5_CCC,E5_CCD,E5_VENCTO"+CRLF
				cQuery2 += " FROM SE5"+ALLTRIM(aConsorcio[nScan,8])+" SE5" +CRLF
				cQuery2 += " LEFT JOIN CT1"+ALLTRIM(aConsorcio[nScan,8])+" CT1 ON CT1_FILIAL = '"+xFilial("CT1")+"' AND (CT1_CONTA=E5_DEBITO OR CT1_CONTA=E5_CREDITO) AND CT1.D_E_L_E_T_=''"+CRLF
				cQuery2 += " WHERE SE5.D_E_L_E_T_='' AND (SUBSTRING(E5_DEBITO,1,1)='3' OR SUBSTRING(E5_CREDITO,1,1)='3' )  AND E5_SITUACA<>'C'"+CRLF
				cQuery2 += " AND SUBSTRING(E5_VENCTO,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'"+CRLF
		        cQuery2 += " AND (E5_CCC='"+ALLTRIM(QTMP->CNF_CONTRA)+"' OR E5_CCD='"+ALLTRIM(QTMP->CNF_CONTRA)+"')"+CRLF

				u_LogMemo("BKGCTR11-E5-2-"+STRZERO(_nI,3)+".SQL",cQuery2)
		        
				TCQUERY cQuery2 NEW ALIAS "TMPX2"
				dbSelectArea("TMPX2")
				dbGoTop()
				DO While !TMPX2->(EOF()) 
					dbSelectArea(ALIAS_TMP)
		   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->CT1_DESC01),.F.)
						Reclock(ALIAS_TMP,.F.)
					ELSE
						Reclock(ALIAS_TMP,.T.)
						(ALIAS_TMP)->XX_CODGCT := IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
						(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->CT1_DESC01)
						(ALIAS_TMP)->XX_DESC   := ALLTRIM("*"+TMPX2->CT1_DESC01)
					ENDIF
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += (TMPX2->E5_VALOR /VAL(aConsorcio[nScan,5])) * IIF(TMPX2->E5_RECPAG=='R',-1,1)
					(ALIAS_TMP)->(Msunlock())
	
		   			dbSelectArea(ALIAS_TMP)
		   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
		     			Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
						&cCampo2 += (TMPX2->E5_VALOR /VAL(aConsorcio[nScan,5])) * IIF(TMPX2->E5_RECPAG=='R',-1,1)
						(ALIAS_TMP)->(Msunlock())
					ENDIF
					dbSelectArea("TMPX2")
					dbSkip()
				ENDDO
				TMPX2->(dbCloseArea())
		  		
	  		ENDIF
	  	ELSE

			cQuery2 := "SELECT E5_CREDITO,E5_DEBITO,CT1_DESC01,E5_VALOR,E5_RECPAG,E5_CCC,E5_CCD,E5_VENCTO"+CRLF
			cQuery2 += " FROM "+RETSQLNAME("SE5")+" SE5"  +CRLF
			cQuery2 += " LEFT JOIN "+RETSQLNAME("CT1")+" CT1 ON CT1_FILIAL = '"+xFilial("CT1")+"' AND (CT1_CONTA=E5_DEBITO OR CT1_CONTA=E5_CREDITO) AND CT1.D_E_L_E_T_=''"+CRLF
			cQuery2 += " WHERE SE5.D_E_L_E_T_='' AND (SUBSTRING(E5_DEBITO,1,1)='3' OR SUBSTRING(E5_CREDITO,1,1)='3' )  AND E5_SITUACA<>'C'"+CRLF
			cQuery2 += " AND SUBSTRING(E5_VENCTO,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'"+CRLF
	        cQuery2 += " AND (E5_CCC='"+ALLTRIM(QTMP->CNF_CONTRA)+"' OR E5_CCD='"+ALLTRIM(QTMP->CNF_CONTRA)+"')"+CRLF
	        
			u_LogMemo("BKGCTR11-E5-3-"+STRZERO(_nI,3)+".SQL",cQuery2)

			TCQUERY cQuery2 NEW ALIAS "TMPX2"
			
			dbSelectArea("TMPX2")
			dbGoTop()
			DO While !TMPX2->(EOF()) 
				dbSelectArea(ALIAS_TMP)
	   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+ALLTRIM(TMPX2->CT1_DESC01),.F.)
					Reclock(ALIAS_TMP,.F.)
				ELSE
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
					(ALIAS_TMP)->XX_CODIGO := "W"+ALLTRIM(TMPX2->CT1_DESC01)
					(ALIAS_TMP)->XX_DESC   := ALLTRIM("*"+TMPX2->CT1_DESC01)
				ENDIF
				cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
				&cCampo2 += TMPX2->E5_VALOR * IIF(TMPX2->E5_RECPAG=='R',-1,1)
				(ALIAS_TMP)->(Msunlock())

	   			dbSelectArea(ALIAS_TMP)
	   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
	     			Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->E5_VALOR  * IIF(TMPX2->E5_RECPAG=='R',-1,1)
					(ALIAS_TMP)->(Msunlock())
				ENDIF
				dbSelectArea("TMPX2")
				dbSkip()
			ENDDO
			TMPX2->(dbCloseArea())
	  	ENDIF

		IncProc("Consultando faturamento das medições avulsas...")
		//********* FATURAMENTO - Inclusão para medição avulso
		cQuery2 := "SELECT C5_ESPECI1,A1_NOME,CTT_DESC01,SUM(D2_TOTAL) AS D2_TOTAL,SUM(D2_VALISS) AS D2_VALISS, SUM(E5_VALOR) AS E5DESC"+CRLF
		cQuery2 += " FROM "+RETSQLNAME("SC5")+" SC5" +CRLF
		cQuery2 += " INNER JOIN "+RETSQLNAME("SC6")+" SC6 ON SC5.C5_NUM = SC6.C6_NUM" +CRLF
		cQuery2 += "       AND  SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.D_E_L_E_T_ = ''"+CRLF
		
	    cQuery2 += " INNER JOIN "+RETSQLNAME("SD2")+" SD2 ON C6_NUM = D2_PEDIDO AND C6_ITEM = D2_ITEM"+CRLF
		cQuery2 += "       AND  SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND SD2.D_E_L_E_T_ = ''"+CRLF

		// 27/02/20   
		cQuery2 += " LEFT JOIN "+RETSQLNAME("SE5")+" SE5 ON E5_PREFIXO = D2_SERIE AND E5_NUMERO = D2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = D2_CLIENTE AND E5_LOJA = D2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " +CRLF//--AND E5_PARCELA = '  '
		cQuery2 += "      AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = '' "+CRLF

	    cQuery2 += " INNER JOIN "+RETSQLNAME("SA1")+" SA1 ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA " +CRLF
	    cQuery2 += "      AND  SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ''"+CRLF
	    
	    cQuery2 += " INNER JOIN "+RETSQLNAME("CTT")+" CTT ON SC5.C5_ESPECI1 = CTT.CTT_CUSTO AND CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ''" +CRLF
	    cQuery2 += " WHERE SC5.D_E_L_E_T_ = '' AND SC5.C5_MDCONTR='' AND SC5.C5_XXCOMPT ='"+SUBSTR(aPeriodo[_nI,1],1,2)+SUBSTR(aPeriodo[_nI,1],4,4)+"'"+CRLF

	   	//cQuery2 += " AND C5_ESPECI1 <> '000000001'"+CRLF
	    //IF !EMPTY(cContrato)
	    //	cQuery2 += " AND C5_ESPECI1 ='"+ALLTRIM(cContrato)+"'"
	    //ENDIF	
    	cQuery2 += " AND C5_ESPECI1 ='"+ALLTRIM(QTMP->CNF_CONTRA)+"'"+CRLF
	    	
	    cQuery2 += " GROUP BY SC5.C5_ESPECI1,SA1.A1_NOME,CTT.CTT_DESC01" +CRLF
	      	
		u_LogMemo("BKGCTR11-SC5-1-"+STRZERO(_nI,3)+".SQL",cQuery2)

		TCQUERY cQuery2 NEW ALIAS "TMPX2"
		
		dbSelectArea("TMPX2")
		dbGoTop()
		DO While !TMPX2->(EOF())
	        aRentab  := {}
	        AADD(aRentab,{"00","CLIENTE: ","S",TMPX2->A1_NOME})              
	        AADD(aRentab,{"01","CONTRATO: ","S",TMPX2->CTT_DESC01})              
	        AADD(aRentab,{"02","NUMERO-SIGA: ","S",TMPX2->C5_ESPECI1})              
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
	        AADD(aRentab,{"19","(-) Recuperação de Sindicato (Odonto)","S",0}) 
        	AADD(aRentab,{"20","CECREMEF/ADV","S",0}) 
        	AADD(aRentab,{"21","(-) CECREMEF/ADV","S",0}) 
	        AADD(aRentab,{"22-1","","S",0}) 
	        AADD(aRentab,{"30","GASTOS GERAIS","S",0}) 
	        AADD(aRentab,{"30-1","","S",0}) 
	        AADD(aRentab,{"30-2","DESCONTOS NA NF","S",IIF(nIndTC>0,TMPX2->E5DESC/(nIndTC/100),TMPX2->E5DESC)}) 
	        AADD(aRentab,{"YYYYYYYYY","TAXA DE ADMINISTRAÇÃO","S",0})
	        AADD(aRentab,{"YYYYYYYYZ","","S",0}) 
        	AADD(aRentab,{"ZZZZZZYYY","RESULTADO PARCIAL","S",0})
        	AADD(aRentab,{"ZZZZZZZYY","% RES. PARCIAL","S",0})
        	AADD(aRentab,{"ZZZZZZZZY","RESULTADO GLOBAL","S",0})
        	AADD(aRentab,{"ZZZZZZZZZ","% RES. GLOBAL ","S",0})
			
			FOR _nJ := 1 TO LEN(aRentab)
				dbSelectArea(ALIAS_TMP)
				IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->C5_ESPECI1))+aRentab[_nJ,1],.F.)
					Reclock(ALIAS_TMP,.F.)
				ELSE
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODGCT := IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->C5_ESPECI1))
					(ALIAS_TMP)->XX_CODIGO := aRentab[_nJ,1]
					(ALIAS_TMP)->XX_DESC   := IIF("|"+aRentab[_nJ,1]+"|" $ "|00|01|02|",aRentab[_nJ,2]+aRentab[_nJ,4]+IIF("|"+aRentab[_nJ,1]+"|"="|01|"," - Medição Avulsa",""),aRentab[_nJ,2])

					// Debug
					If EMPTY((ALIAS_TMP)->XX_DESC)
						(ALIAS_TMP)->XX_DESC := "9 - "+aRentab[_nJ,1]
					EndIf

					
				ENDIF
				IF "|"+aRentab[_nJ,1]+"|" $ "|03|04|05|06|07|30-2|" // 28/02/20
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += aRentab[_nJ,4]
				ENDIF
				(ALIAS_TMP)->(Msunlock())
	        NEXT
	        //nScan:= 0
	 		//nScan:= aScan(aContratos,{|x| x=ALLTRIM(TMPX2->C5_ESPECI1)})
			//IF nScan == 0
			//	AADD(aContratos  ,ALLTRIM(TMPX2->C5_ESPECI1))
			//ENDIF
	
		   dbSelectArea("TMPX2")
		   dbSkip()
		ENDDO
		TMPX2->(dbCloseArea())
	

       nScan:= 0
 		nScan:= aScan(aContratos,{|x| x = IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))})
		IF nScan == 0
			AADD(aContratos  ,IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA)))
		ENDIF
 
	   	dbSelectArea("QTMP")
	   	QTMP->(dbSkip())
	ENDDO
    QTMP->(dbCloseArea())

NEXT


//CALCULA RESULTADOS
ProcRegua(Len(aContratos))
For Yi_ := 1 TO LEN(aContratos)
	FOR _nI := 1 TO nPeriodo
		IncProc("Calculando resultados...")
		//CALCULA TAXA ADM
        nValTaxaAdm := 0
        nFaturaOF := 0
		dbSelectArea(ALIAS_TMP)
		IF MsSeek(ALLTRIM(aContratos[Yi_])+'03',.F.)
			cCampo2   := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
        	nValTaxaAdm := (&cCampo2*nTaxaAdm)/100 
			nFaturaOF := &cCampo2
		ENDIF
		
		//GRAVA TAXA ADM
		dbSelectArea(ALIAS_TMP)
	   	IF MsSeek(ALLTRIM(aContratos[Yi_])+"YYYYYYYYY",.F.)
			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			&cCampo2 += nValTaxaAdm
			(ALIAS_TMP)->(Msunlock())
		ELSE
			Reclock(ALIAS_TMP,.T.)
			(ALIAS_TMP)->XX_CODGCT := ALLTRIM(aContratos[Yi_])
			(ALIAS_TMP)->XX_CODIGO := "YYYYYYYYY"
			(ALIAS_TMP)->XX_DESC   := "TAXA DE ADMINISTRAÇÃO"
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			&cCampo2 += nValTaxaAdm
			(ALIAS_TMP)->(Msunlock())
		ENDIF
		
		//SOMA TAXA ADM NOS GASTOS GERAIS
	    n2Resultado := 0
		dbSelectArea(ALIAS_TMP)
		IF MsSeek(ALLTRIM(aContratos[Yi_])+'30',.F.)
   			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			&cCampo2 += nValTaxaAdm
			n2Resultado += nValTaxaAdm
			(ALIAS_TMP)->(Msunlock())
		ENDIF


		//SOMA DESCONTOS DO SE5 NOS GASTOS GERAIS 28/02/20
	    nDescE5 := 0
		dbSelectArea(ALIAS_TMP)
		IF MsSeek(ALLTRIM(aContratos[Yi_])+'30-2',.F.)
   			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			nDescE5  := &cCampo2

			IF MsSeek(ALLTRIM(aContratos[Yi_])+'30',.F.)
				Reclock(ALIAS_TMP,.F.)
				cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
				&cCampo2 += nDescE5
				(ALIAS_TMP)->(Msunlock())
			ENDIF
			
		ENDIF

	    // Calculo do Resultado
	    nResultado := 0
		dbSelectArea(ALIAS_TMP)
		IF MsSeek(ALLTRIM(aContratos[Yi_])+'07',.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			nResultado += &cCampo2
			n2Resultado += &cCampo2
		ENDIF
		
		dbSelectArea(ALIAS_TMP)
		IF MsSeek(ALLTRIM(aContratos[Yi_])+'08',.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			nResultado -= &cCampo2
			n2Resultado -= &cCampo2
		ENDIF
		dbSelectArea(ALIAS_TMP)
		IF MsSeek(ALLTRIM(aContratos[Yi_])+'30',.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			nResultado -= &cCampo2
			n2Resultado -= &cCampo2
		ENDIF

        //CALCULA RESULTADO PARCIAL
		dbSelectArea(ALIAS_TMP)
		IF MsSeek(ALLTRIM(aContratos[Yi_])+'ZZZZZZYYY',.F.)
			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			&cCampo2 := nResultado
			(ALIAS_TMP)->(Msunlock())
		ENDIF
        //CALCULA % RES. PARCIAL
		dbSelectArea(ALIAS_TMP)
		IF MsSeek(ALLTRIM(aContratos[Yi_])+'ZZZZZZZYY',.F.)
			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			&cCampo2 := (nResultado/nFaturaOF)*100
			(ALIAS_TMP)->(Msunlock())
		ENDIF
        //CALCULA RESULTADO GLOBAL
		dbSelectArea(ALIAS_TMP)
		IF MsSeek(ALLTRIM(aContratos[Yi_])+'ZZZZZZZZY',.F.)
			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			&cCampo2 := n2Resultado
			(ALIAS_TMP)->(Msunlock())
		ENDIF
        //CALCULA % RES. GLOBAL
		dbSelectArea(ALIAS_TMP)
		IF MsSeek(ALLTRIM(aContratos[Yi_])+'ZZZZZZZZZ',.F.)
			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			&cCampo2 := (n2Resultado/nFaturaOF)*100
			(ALIAS_TMP)->(Msunlock())
		ENDIF

    NEXT
NEXT


//Verifica o Grupo do usuario - visualização do relatorio
PswOrder(1) 
PswSeek(__CUSERID) 
aUser  := PswRet(1)

cCodView := ""
cCodView := SuperGetMV("MV_XXRENTA")

IF !lJob
	cMaster := ""
	cMaster := SuperGetMV("MV_XXGRREN",.F.,"000000/000003/000004/000005/000007/000008/000010/000020")    
	lMaster := .F.
	aGRUPO := {}
//	AADD(aGRUPO,aUser[1,10])
//	FOR i:=1 TO LEN(aGRUPO[1])
//		lMaster := (aGRUPO[1,i] $ cMaster)
//	NEXT
//Ajuste nova rotina a antiga não funciona na nova lib MDI
	aGRUPO := UsrRetGrp(aUser[1][2])
	IF LEN(aGRUPO) > 0
		FOR i:=1 TO LEN(aGRUPO)
			lMaster := (ALLTRIM(aGRUPO[i]) $ cMaster )
		NEXT
	ENDIF	
ELSE
	lMaster := .T.
ENDIF


nLINHA := 1
aLINHA := {}
DbSelectArea(ALIAS_TMP)
(ALIAS_TMP)->(dbSetOrder(1))
(ALIAS_TMP)->(dbgotop())
cCodigo 	:= (ALIAS_TMP)->XX_CODGCT
nTotFat 	:=0
nTotCUSTO 	:=0

Do While (ALIAS_TMP)->(!eof())

	IF !lMaster
		IF ALLTRIM((ALIAS_TMP)->XX_CODIGO) $ cCodView 
		
		ELSE
			(ALIAS_TMP)->(dbSkip())
			LOOP
		ENDIF
    ENDIF

   IF cCodigo <> (ALIAS_TMP)->XX_CODGCT
		nTotFat :=0
		nTotCUSTO :=0
		
        nLINHA++
		dbSelectArea("TRB")
 		Reclock("TRB",.T.)
		TRB->XX_LINHA  := nLINHA
 		TRB->(Msunlock())
 		cCodigo := (ALIAS_TMP)->XX_CODGCT
 	ENDIF

	IF nConsolida == 1
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|00|"	
			FOR _IX := 1 TO LEN(aContConsol)
			
				dbSelectArea("TRB")
 				Reclock("TRB",.T.)
				TRB->XX_LINHA  	:= nLINHA
 				TRB->XX_CODGCT  := "999999999"
				TRB->XX_DESC	:= "CLIENTE: "+aContConsol[_IX,2]
 				TRB->(Msunlock())
				nLINHA++
				
				dbSelectArea("TRB")
 				Reclock("TRB",.T.)
				TRB->XX_LINHA  	:= nLINHA
 				TRB->XX_CODGCT  := "999999999"
				TRB->XX_DESC	:= "CONTRATO: "+aContConsol[_IX,3]
 				TRB->(Msunlock())
				nLINHA++

				dbSelectArea("TRB")
 				Reclock("TRB",.T.)
				TRB->XX_LINHA  	:= nLINHA
 				TRB->XX_CODGCT  := "999999999"
				TRB->XX_DESC	:= "NUMERO-SIGA: "+aContConsol[_IX,1]
 				TRB->(Msunlock())
				nLINHA++
				
			NEXT
	    ELSEIF !"|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|00|01|02|"	
			dbSelectArea("TRB")
			Reclock("TRB",.T.)
			TRB->XX_LINHA	:= nLINHA
 			TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
			TRB->XX_DESC	:= (ALIAS_TMP)->XX_DESC
	    ENDIF
	ELSE
		dbSelectArea("TRB")
		Reclock("TRB",.T.)
		TRB->XX_LINHA	:= nLINHA
 		TRB->XX_CODGCT  := (ALIAS_TMP)->XX_CODGCT
		TRB->XX_DESC	:= (ALIAS_TMP)->XX_DESC
	ENDIF
	
	nTotal = 0
	n2Total= 0
	FOR _nI := 1 TO nPeriodo
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|00|01|03-1|02|05-1|06-1|07-1|22-1|30-1|YYYYYYYYZ|"	
			cCampo		:= "TRB->XX_VAL"+STRZERO(_nI,3)
			&cCampo		:= ""
		ELSEIF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|ZZZZZZZYY|ZZZZZZZZZ|"	
			cCampo2		:= ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			cCampo		:= "TRB->XX_VAL"+STRZERO(_nI,3)
			&cCampo		:= transform(Round(&cCampo2,5),"@E 99999.99999")+"%"
		ELSE
			cCampo2		:= ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			cCampo		:= "TRB->XX_VAL"+STRZERO(_nI,3)
			&cCampo		:= transform(&cCampo2,cPict)
	        nTotal		+= &cCampo2
	        IF !"|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|YYYYYYYYY|"
				n2Total     += &cCampo2
			ENDIF
		ENDIF
	NEXT
	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|00|01|03-1|02|05-1|06-1|07-1|22-1|30-1|YYYYYYYYZ|"
		TRB->XX_TOTAL := ""
		TRB->XX_INDIC := ""
	ELSE		
		TRB->XX_TOTAL 	:= transform(nTotal,cPict)
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|03|"
	        nTotFat := nTotal
		ENDIF	
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|06|07|08|30|YYYYYYYYY|ZZZZZZYYY|"
	        TRB->XX_INDIC := transform(Round((nTotal/nTotFat)*100,5),"@E 99999.99999")+"%"
		ENDIF	
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|ZZZZZZZYY|"
	        TRB->XX_TOTAL := ""
        ENDIF
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|ZZZZZZZZY|"
	        TRB->XX_INDIC := transform(Round((n2Total/nTotFat)*100,5),"@E 99999.99999")+"%"
		ENDIF	
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|ZZZZZZZZZ|"
	        TRB->XX_TOTAL := ""
        ENDIF
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|09|"
	        nTotCusto := nTotal
		ENDIF	
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|10|11|"
	        TRB->XX_INDIC := transform(Round((nTotal/nTotCusto)*100,5),"@E 99999.99999")+"%"
		ENDIF	
	ENDIF

//	TRB->XX_STATUS	:= (ALIAS_TMP)->XX_STATUS 
	TRB->(Msunlock()) 
    nLINHA++
	DbSelectArea(ALIAS_TMP)
	(ALIAS_TMP)->(dbSkip())
ENDDO

dbSelectArea("TRB")
TRB->(dbgotop())
IF lJob
	IF nConsolida == 1
		dbSelectArea("TRB")
		TRB->(dbgotop())
    	DO WHILE TRB->(!EOF())

			dbSelectArea("TRB")
			Reclock("TRB",.F.)
 			TRB->XX_CODGCT  := aContConsol[1,1]
			TRB->(Msunlock())
			 			
			TRB->(dbSkip())
		ENDDO
	ENDIF

	ConOut("BKGCTR11: Gravando dados Rentabilidade dos contratos - "+DTOC(DATE())+" "+TIME())   

	nSCAN1 := 0    
	nSCAN2 := 0    
	nSCAN3 := 0    
	FOR _IX := 1 TO nPeriodo
        
        IF  STRZERO(Month(MonthSub(dDatabase,2)),2)+"/"+STRZERO(YEAR(MonthSub(dDatabase,2)),4) == aPeriodo[_IX,1]	
			nSCAN1 := _IX
		ENDIF		
        IF  STRZERO(Month(MonthSub(dDatabase,1)),2)+"/"+STRZERO(YEAR(MonthSub(dDatabase,1)),4) == aPeriodo[_IX,1]	
			nSCAN2 := _IX
		ENDIF		
        IF  STRZERO(Month(dDatabase),2)+"/"+STRZERO(YEAR(dDatabase),4) == aPeriodo[_IX,1]	
			nSCAN3 := _IX
		ENDIF		
    NEXT 
    
	dbSelectArea("TRB")
	TRB->(dbgotop())
    DO WHILE TRB->(!EOF())
    	cCODGCT := ""
    	cCODGCT := IIF(nConsolida==1,SUBSTR(aAglutGCT[len(aAglutGCT),2],1,9),TRB->XX_CODGCT)
            //CARREGA VALOR DO 1 PERIODO
    		IF nSCAN1 > 0
				IF ALLTRIM(TRB->XX_DESC) == "FATURAMENTO OFICIAL"
					cCampo := "" 
					cCampo := "TRB->XX_VAL"+STRZERO(nSCAN1,3)
					nVcampo := 0
					nVcampo := VAL(StrTran(StrTran(&cCampo,".",""),",","."))
					cXCompet := ""
					cXCompet := SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN1,1])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN1,1])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN1,1])),5,2) 
                	aPrev := {}
					aPrev := U_PREVCONTRA(TRB->XX_CODGCT,"01/"+aPeriodo[nSCAN1,1])					
					IF nVcampo > 0 .OR. aPrev[1,1] >0
						cQuery := ""
						cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[RentabilidadeContrato] "
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
						cQuery +="BEGIN "
						cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[RentabilidadeContrato] SET "
						cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"    
						cQuery +="				[NomeCliente]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[NomeContrato]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[GestorBK]='"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				[Faturamento]="+STR(nVcampo,14,2)+","
						cQuery +="            	[FaturamentoPrev]="+STR(aPrev[1,1],14,2)+","
						cQuery +="            	[ResultadoPrev]="+STR(aPrev[1,2],14,2)
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
						cQuery +="END "
						cQuery +="ELSE "
						cQuery +="BEGIN "
						cQuery +=" INSERT INTO [EstudoRentabilidade].[dbo].[RentabilidadeContrato] "
						cQuery +="            ([CodigoContrato] "
						cQuery +="            ,[Competencia] "
						cQuery +="            ,[CodigoCliente]"
						cQuery +="            ,[NomeCliente]"
						cQuery +="            ,[NomeContrato]"
						cQuery +="			  ,[GestorBK]"
						cQuery +="            ,[Faturamento]"
						cQuery +="            ,[FaturamentoPrev]"
						cQuery +="            ,[Resultado]"
						cQuery +="            ,[ResultadoPrev])"
						cQuery +="      VALUES ('"+cCODGCT+"',"
						cQuery +="              '"+cXCompet+" 00:00:00',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				 "+STR(nVcampo,14,2)+","
						cQuery +="				 "+STR(aPrev[1,1],14,2)+","
						cQuery +="				 0,"
						cQuery +="				 "+STR(aPrev[1,2],14,2)+")"
						cQuery +="END "						
						TcSqlExec(cQuery)
					ENDIF 
			    ENDIF
				IF ALLTRIM(TRB->XX_DESC) == "CUSTO"
					cCampo := "" 
					cCampo := "TRB->XX_VAL"+STRZERO(nSCAN1,3)
					nVcampo := 0
					nVcampo := VAL(StrTran(StrTran(&cCampo,".",""),",","."))
					cXCompet := ""
					cXCompet := SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN1,1])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN1,1])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN1,1])),5,2) 
                	aPrev := {}
					aPrev := U_PREVCONTRA(TRB->XX_CODGCT,"01/"+aPeriodo[nSCAN1,1])					
					IF nVcampo > 0 
						cQuery := ""
						cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[InsumosSalarios] "
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
						cQuery +="BEGIN "
						cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[InsumosSalarios] SET "
						cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				[NomeCliente]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[NomeContrato]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[GestorBK]='"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				[Salarios]="+STR(nVcampo,14,2)+","
						cQuery +="            	[SalariosPrev]="+STR(aPrev[1,3],14,2)
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
						cQuery +="END "
						cQuery +="ELSE "
						cQuery +="BEGIN "
						cQuery +=" INSERT INTO [EstudoRentabilidade].[dbo].[InsumosSalarios] "
						cQuery +="            ([CodigoContrato] "
						cQuery +="            ,[Competencia] "
						cQuery +="            ,[CodigoCliente]"
						cQuery +="            ,[NomeCliente]"
						cQuery +="            ,[NomeContrato]"
						cQuery +="			  ,[GestorBK]"
						cQuery +="            ,[Insumos]"
						cQuery +="            ,[InsumosPrev]"
						cQuery +="            ,[Salarios]"
						cQuery +="            ,[SalariosPrev])"
						cQuery +="      VALUES ('"+cCODGCT+"',"
						cQuery +="              '"+cXCompet+" 00:00:00',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				 0,"
						cQuery +="				 0,"
						cQuery +="				 "+STR(nVcampo,14,2)+","
						cQuery +="				 "+STR(aPrev[1,3],14,2)+")"
						cQuery +="END "						
						TcSqlExec(cQuery)
					ENDIF 
			    ENDIF
				IF ALLTRIM(TRB->XX_DESC) == "GASTOS GERAIS"
					cCampo := "" 
					cCampo := "TRB->XX_VAL"+STRZERO(nSCAN1,3)
					nVcampo := 0
					nVcampo := VAL(StrTran(StrTran(&cCampo,".",""),",","."))
					cXCompet := ""
					cXCompet := SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN1,1])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN1,1])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN1,1])),5,2) 
                	aPrev := {}
					aPrev := U_PREVCONTRA(TRB->XX_CODGCT,"01/"+aPeriodo[nSCAN1,1])					
					IF nVcampo > 0 
						cQuery := ""
						cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[InsumosSalarios] "
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
						cQuery +="BEGIN "
						cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[InsumosSalarios] SET "
						cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				[NomeCliente]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[NomeContrato]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[GestorBK]='"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				[Insumos]="+STR(nVcampo,14,2)+","
						cQuery +="            	[InsumosPrev]="+STR(aPrev[1,4],14,2)
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
						cQuery +="END "
						cQuery +="ELSE "
						cQuery +="BEGIN "
						cQuery +=" INSERT INTO [EstudoRentabilidade].[dbo].[InsumosSalarios] "
						cQuery +="            ([CodigoContrato] "
						cQuery +="            ,[Competencia] "
						cQuery +="            ,[CodigoCliente]"
						cQuery +="            ,[NomeCliente]"
						cQuery +="            ,[NomeContrato]"
						cQuery +="			  ,[GestorBK]"
						cQuery +="            ,[Insumos]"
						cQuery +="            ,[InsumosPrev]"
						cQuery +="            ,[Salarios]"
						cQuery +="            ,[SalariosPrev])"
						cQuery +="      VALUES ('"+cCODGCT+"',"
						cQuery +="              '"+cXCompet+" 00:00:00',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				 "+STR(nVcampo,14,2)+","
						cQuery +="				 "+STR(aPrev[1,4],14,2)+","
						cQuery +="				 0,"
						cQuery +="				 0)"
						cQuery +="END "						
						TcSqlExec(cQuery)
					ENDIF 
			    ENDIF
   				IF ALLTRIM(TRB->XX_DESC) == "TAXA DE ADMINISTRAÇÃO"
					cCampo := "" 
					cCampo := "TRB->XX_VAL"+STRZERO(nSCAN1,3)
					nVcampo := 0
					nVcampo := VAL(StrTran(StrTran(&cCampo,".",""),",","."))
					cXCompet := ""
					cXCompet := SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN1,1])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN1,1])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN1,1])),5,2) 
                	aPrev := {}
					aPrev := U_PREVCONTRA(TRB->XX_CODGCT,"01/"+aPeriodo[nSCAN1,1])					
					IF nVcampo > 0 
						cQuery := ""
						cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[InsumosSalarios] "
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
						cQuery +="BEGIN "
						cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[InsumosSalarios] SET "
						cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				[NomeCliente]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[NomeContrato]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[GestorBK]='"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				[Insumos]=[Insumos]-"+STR(nVcampo,14,2)+","
						cQuery +="            	[InsumosPrev]="+STR(aPrev[1,4],14,2)
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
						cQuery +="END "
						TcSqlExec(cQuery)
					ENDIF 
			    ENDIF
				IF ALLTRIM(TRB->XX_DESC) == "RESULTADO PARCIAL"
					cCampo := "" 
					cCampo := "TRB->XX_VAL"+STRZERO(nSCAN1,3)
					nVcampo := 0
					nVcampo := VAL(StrTran(StrTran(&cCampo,".",""),",","."))
					cXCompet := ""
					cXCompet := SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN1,1])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN1,1])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN1,1])),5,2) 
					cQuery := ""
					cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[RentabilidadeContrato] "
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
					cQuery +="BEGIN "
					cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[RentabilidadeContrato] SET "
					cQuery +="				[Resultado]="+STR(nVcampo,14,2)//+","
//					cQuery +="				[ResultadoPREV]="+STR(aPrev[1,2],14,2)
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59' "
					cQuery +="END "
					TcSqlExec(cQuery)
			    ENDIF
			ENDIF
            //CARREGA VALOR DO 2 PERIODO
    		IF nSCAN2 > 0
				IF ALLTRIM(TRB->XX_DESC) == "FATURAMENTO OFICIAL"
					cCampo := "" 
					cCampo := "TRB->XX_VAL"+STRZERO(nSCAN2,3)
					nVcampo := 0
					nVcampo := VAL(StrTran(StrTran(&cCampo,".",""),",","."))
					cXCompet := ""
					cXCompet := SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN2,1])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN2,1])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN2,1])),5,2) 
	                aPrev := {}
					aPrev := U_PREVCONTRA(TRB->XX_CODGCT,"01/"+aPeriodo[nSCAN2,1])					
					IF nVcampo > 0  .OR. aPrev[1,1] > 0
						cQuery := ""
						cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[RentabilidadeContrato] "
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
						cQuery +="BEGIN "
						cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[RentabilidadeContrato] SET "
						cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				[NomeCliente]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[NomeContrato]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[GestorBK]='"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				[Faturamento]="+STR(nVcampo,14,2)+","
						cQuery +="            	[FaturamentoPrev]="+STR(aPrev[1,1],14,2)+","
						cQuery +="            	[ResultadoPrev]="+STR(aPrev[1,2],14,2)
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
						cQuery +="END "
						cQuery +="ELSE "
						cQuery +="BEGIN "
						cQuery +=" INSERT INTO [EstudoRentabilidade].[dbo].[RentabilidadeContrato] "
						cQuery +="            ([CodigoContrato] "
						cQuery +="            ,[Competencia] "
						cQuery +="            ,[CodigoCliente]"
						cQuery +="            ,[NomeCliente]"
						cQuery +="            ,[NomeContrato]"
						cQuery +="			  ,[GestorBK]"
						cQuery +="            ,[Faturamento]"
						cQuery +="            ,[FaturamentoPrev]"
						cQuery +="            ,[Resultado]"
						cQuery +="            ,[ResultadoPrev])"
						cQuery +="      VALUES ('"+cCODGCT+"',"
						cQuery +="              '"+cXCompet+" 00:00:00',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				 "+STR(nVcampo,14,2)+","
						cQuery +="				 "+STR(aPrev[1,1],14,2)+","
						cQuery +="				 0,"
						cQuery +="				 "+STR(aPrev[1,2],14,2)+")"
						cQuery +="END "						
						TcSqlExec(cQuery)
					ENDIF 
			    ENDIF
				IF ALLTRIM(TRB->XX_DESC) == "CUSTO"
					cCampo := "" 
					cCampo := "TRB->XX_VAL"+STRZERO(nSCAN2,3)
					nVcampo := 0
					nVcampo := VAL(StrTran(StrTran(&cCampo,".",""),",","."))
					cXCompet := ""
					cXCompet := SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN2,1])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN2,1])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN2,1])),5,2) 
                	aPrev := {}
					aPrev := U_PREVCONTRA(TRB->XX_CODGCT,"01/"+aPeriodo[nSCAN2,1])					
					IF nVcampo > 0 
						cQuery := ""
						cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[InsumosSalarios] "
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
						cQuery +="BEGIN "
						cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[InsumosSalarios] SET "
						cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				[NomeCliente]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[NomeContrato]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[GestorBK]='"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				[Salarios]="+STR(nVcampo,14,2)+","
						cQuery +="            	[SalariosPrev]="+STR(aPrev[1,3],14,2)
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
						cQuery +="END "
						cQuery +="ELSE "
						cQuery +="BEGIN "
						cQuery +=" INSERT INTO [EstudoRentabilidade].[dbo].[InsumosSalarios] "
						cQuery +="            ([CodigoContrato] "
						cQuery +="            ,[Competencia] "
						cQuery +="            ,[CodigoCliente]"
						cQuery +="            ,[NomeCliente]"
						cQuery +="            ,[NomeContrato]"
						cQuery +="			  ,[GestorBK]"
						cQuery +="            ,[Insumos]"
						cQuery +="            ,[InsumosPREV]"
						cQuery +="            ,[Salarios]"
						cQuery +="            ,[SalariosPrev])"
						cQuery +="      VALUES ('"+cCODGCT+"',"
						cQuery +="              '"+cXCompet+" 00:00:00',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				 0,"
						cQuery +="				 0,"
						cQuery +="				 "+STR(nVcampo,14,2)+","
						cQuery +="				 "+STR(aPrev[1,3],14,2)+")"
						cQuery +="END "						
						TcSqlExec(cQuery)
					ENDIF 
			    ENDIF

				IF ALLTRIM(TRB->XX_DESC) == "GASTOS GERAIS"
					cCampo := "" 
					cCampo := "TRB->XX_VAL"+STRZERO(nSCAN2,3)
					nVcampo := 0
					nVcampo := VAL(StrTran(StrTran(&cCampo,".",""),",","."))
					cXCompet := ""
					cXCompet := SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN2,1])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN2,1])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN2,1])),5,2) 
                	aPrev := {}
					aPrev := U_PREVCONTRA(TRB->XX_CODGCT,"01/"+aPeriodo[nSCAN2,1])					
					IF nVcampo > 0 
						cQuery := ""
						cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[InsumosSalarios] "
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
						cQuery +="BEGIN "
						cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[InsumosSalarios] SET "
						cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				[NomeCliente]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[NomeContrato]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[GestorBK]='"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				[Insumos]="+STR(nVcampo,14,2)+","
						cQuery +="            	[InsumosPrev]="+STR(aPrev[1,4],14,2)
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
						cQuery +="END "
						cQuery +="ELSE "
						cQuery +="BEGIN "
						cQuery +=" INSERT INTO [EstudoRentabilidade].[dbo].[InsumosSalarios] "
						cQuery +="            ([CodigoContrato] "
						cQuery +="            ,[Competencia] "
						cQuery +="            ,[CodigoCliente]"
						cQuery +="            ,[NomeCliente]"
						cQuery +="            ,[NomeContrato]"
						cQuery +="			  ,[GestorBK]"
						cQuery +="            ,[Insumos]"
						cQuery +="            ,[InsumosPrev]"
						cQuery +="            ,[Salarios]"
						cQuery +="            ,[SalariosPrev])"
						cQuery +="      VALUES ('"+cCODGCT+"',"
						cQuery +="              '"+cXCompet+" 00:00:00',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				 "+STR(nVcampo,14,2)+","
						cQuery +="				 "+STR(aPrev[1,4],14,2)+","
						cQuery +="				 0,"
						cQuery +="				 0)"
						cQuery +="END "						
						TcSqlExec(cQuery)
					ENDIF 
			    ENDIF
				IF ALLTRIM(TRB->XX_DESC) == "TAXA DE ADMINISTRAÇÃO"
					cCampo := "" 
					cCampo := "TRB->XX_VAL"+STRZERO(nSCAN2,3)
					nVcampo := 0
					nVcampo := VAL(StrTran(StrTran(&cCampo,".",""),",","."))
					cXCompet := ""
					cXCompet := SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN2,1])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN2,1])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN2,1])),5,2) 
                	aPrev := {}
					aPrev := U_PREVCONTRA(TRB->XX_CODGCT,"01/"+aPeriodo[nSCAN2,1])					
					IF nVcampo > 0 
						cQuery := ""
						cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[InsumosSalarios] "
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
						cQuery +="BEGIN "
						cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[InsumosSalarios] SET "
						cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				[NomeCliente]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[NomeContrato]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[GestorBK]='"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				[Insumos]= [Insumos]-"+STR(nVcampo,14,2)+","
						cQuery +="            	[InsumosPrev]="+STR(aPrev[1,4],14,2)
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
						cQuery +="END "
						TcSqlExec(cQuery)
					ENDIF 
			    ENDIF

				IF ALLTRIM(TRB->XX_DESC) == "RESULTADO PARCIAL"
					cCampo := "" 
					cCampo := "TRB->XX_VAL"+STRZERO(nSCAN2,3)
					nVcampo := 0
					nVcampo := VAL(StrTran(StrTran(&cCampo,".",""),",","."))
					cXCompet := ""
					cXCompet := SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN2,1])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN2,1])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN2,1])),5,2) 
					cQuery := ""
					cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[RentabilidadeContrato] "
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
					cQuery +="BEGIN "
					cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[RentabilidadeContrato] SET "
					cQuery +="				[Resultado]="+STR(nVcampo,14,2)//+","
//					cQuery +="				[ResultadoPREV]="+STR(aPrev[1,2],14,2)
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59' "
					cQuery +="END "
					TcSqlExec(cQuery)
			    ENDIF
			ENDIF

            //CARREGA VALOR DO 3 PERIODO
    		IF nSCAN3 > 0
				IF ALLTRIM(TRB->XX_DESC) == "FATURAMENTO OFICIAL"
					cCampo := "" 
					cCampo := "TRB->XX_VAL"+STRZERO(nSCAN3,3)
					nVcampo := 0
					nVcampo := VAL(StrTran(StrTran(&cCampo,".",""),",","."))
					cXCompet := ""
					cXCompet := SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN3,1])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN3,1])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN3,1])),5,2) 
                	aPrev := {}
					aPrev := U_PREVCONTRA(TRB->XX_CODGCT,"01/"+aPeriodo[nSCAN3,1])					
					IF nVcampo > 0  .OR. aPrev[1,1] > 0
						cQuery := ""
						cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[RentabilidadeContrato] "
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
						cQuery +="BEGIN "
						cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[RentabilidadeContrato] SET "
						cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				[NomeCliente]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[NomeContrato]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[GestorBK]='"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				[Faturamento]="+STR(nVcampo,14,2)+","
						cQuery +="            	[FaturamentoPrev]="+STR(aPrev[1,1],14,2)+","
						cQuery +="            	[ResultadoPrev]="+STR(aPrev[1,2],14,2)
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
						cQuery +="END "
						cQuery +="ELSE "
						cQuery +="BEGIN "
						cQuery +=" INSERT INTO [EstudoRentabilidade].[dbo].[RentabilidadeContrato] "
						cQuery +="            ([CodigoContrato] "
						cQuery +="            ,[Competencia] "
						cQuery +="            ,[CodigoCliente]"
						cQuery +="            ,[NomeCliente]"
						cQuery +="            ,[NomeContrato]"
						cQuery +="			  ,[GestorBK]"
						cQuery +="            ,[Faturamento]"
						cQuery +="            ,[FaturamentoPrev]"
						cQuery +="            ,[Resultado]"
						cQuery +="            ,[ResultadoPrev])"
						cQuery +="      VALUES ('"+cCODGCT+"',"
						cQuery +="              '"+cXCompet+" 00:00:00',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				 "+STR(nVcampo,14,2)+","
						cQuery +="				 "+STR(aPrev[1,1],14,2)+","
						cQuery +="				 0,"
						cQuery +="				 "+STR(aPrev[1,2],14,2)+")"
						cQuery +="END "						
						TcSqlExec(cQuery)
					ENDIF 
			    ENDIF
				IF ALLTRIM(TRB->XX_DESC) == "CUSTO"
					cCampo := "" 
					cCampo := "TRB->XX_VAL"+STRZERO(nSCAN3,3)
					nVcampo := 0
					nVcampo := VAL(StrTran(StrTran(&cCampo,".",""),",","."))
					cXCompet := ""
					cXCompet := SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN3,1])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN3,1])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN3,1])),5,2) 
                	aPrev := {}
					aPrev := U_PREVCONTRA(TRB->XX_CODGCT,"01/"+aPeriodo[nSCAN3,1])					
					IF nVcampo > 0 
						cQuery := ""
						cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[InsumosSalarios] "
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
						cQuery +="BEGIN "
						cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[InsumosSalarios] SET "
						cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				[NomeCliente]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[NomeContrato]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[GestorBK]='"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				[Salarios]="+STR(nVcampo,14,2)+","
						cQuery +="            	[SalariosPrev]="+STR(aPrev[1,3],14,2)
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
						cQuery +="END "
						cQuery +="ELSE "
						cQuery +="BEGIN "
						cQuery +=" INSERT INTO [EstudoRentabilidade].[dbo].[InsumosSalarios] "
						cQuery +="            ([CodigoContrato] "
						cQuery +="            ,[Competencia] "
						cQuery +="            ,[CodigoCliente]"
						cQuery +="            ,[NomeCliente]"
						cQuery +="            ,[NomeContrato]"
						cQuery +="			  ,[GestorBK]"
						cQuery +="            ,[Insumos]"
						cQuery +="            ,[InsumosPrev]"
						cQuery +="            ,[Salarios]"
						cQuery +="            ,[SalariosPrev])"
						cQuery +="      VALUES ('"+cCODGCT+"',"
						cQuery +="              '"+cXCompet+" 00:00:00',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				 0,"
						cQuery +="				 0,"
						cQuery +="				 "+STR(nVcampo,14,2)+","
						cQuery +="				 "+STR(aPrev[1,3],14,2)+")"
						cQuery +="END "						
						TcSqlExec(cQuery)
					ENDIF 
			    ENDIF
				IF ALLTRIM(TRB->XX_DESC) == "GASTOS GERAIS"
					cCampo := "" 
					cCampo := "TRB->XX_VAL"+STRZERO(nSCAN3,3)
					nVcampo := 0
					nVcampo := VAL(StrTran(StrTran(&cCampo,".",""),",","."))
					cXCompet := ""
					cXCompet := SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN3,1])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN3,1])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN3,1])),5,2) 
                	aPrev := {}
					aPrev := U_PREVCONTRA(TRB->XX_CODGCT,"01/"+aPeriodo[nSCAN3,1])					
					IF nVcampo > 0 
						cQuery := ""
						cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[InsumosSalarios] "
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
						cQuery +="BEGIN "
						cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[InsumosSalarios] SET "
						cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				[NomeCliente]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[NomeContrato]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[GestorBK]='"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				[Insumos]="+STR(nVcampo,14,2)+","
						cQuery +="            	[InsumosPrev]="+STR(aPrev[1,4],14,2)
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
						cQuery +="END "
						cQuery +="ELSE "
						cQuery +="BEGIN "
						cQuery +=" INSERT INTO [EstudoRentabilidade].[dbo].[InsumosSalarios] "
						cQuery +="            ([CodigoContrato] "
						cQuery +="            ,[Competencia] "
						cQuery +="            ,[CodigoCliente]"
						cQuery +="            ,[NomeCliente]"
						cQuery +="            ,[NomeContrato]"
						cQuery +="			  ,[GestorBK]"
						cQuery +="            ,[Insumos]"
						cQuery +="            ,[InsumosPrev]"
						cQuery +="            ,[Salarios]"
						cQuery +="            ,[SalariosPrev])"
						cQuery +="      VALUES ('"+cCODGCT+"',"
						cQuery +="              '"+cXCompet+" 00:00:00',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				 "+STR(nVcampo,14,2)+","
						cQuery +="				 "+STR(aPrev[1,4],14,2)+","
						cQuery +="				 0,"
						cQuery +="				 0)"
						cQuery +="END "						
						TcSqlExec(cQuery)
					ENDIF 
			    ENDIF
   				IF ALLTRIM(TRB->XX_DESC) == "TAXA DE ADMINISTRAÇÃO"
					cCampo := "" 
					cCampo := "TRB->XX_VAL"+STRZERO(nSCAN3,3)
					nVcampo := 0
					nVcampo := VAL(StrTran(StrTran(&cCampo,".",""),",","."))
					cXCompet := ""
					cXCompet := SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN3,1])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN3,1])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN3,1])),5,2) 
                	aPrev := {}
					aPrev := U_PREVCONTRA(TRB->XX_CODGCT,"01/"+aPeriodo[nSCAN3,1])					
					IF nVcampo > 0 
						cQuery := ""
						cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[InsumosSalarios] "
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
						cQuery +="BEGIN "
						cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[InsumosSalarios] SET "
						cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_CLIENT")+"',"
						cQuery +="				[NomeCliente]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[NomeContrato]='"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
						cQuery +="				[GestorBK]='"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
						cQuery +="				[Insumos]=[Insumos]-"+STR(nVcampo,14,2)+","
						cQuery +="            	[InsumosPrev]="+STR(aPrev[1,4],14,2)
						cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
						cQuery +="END "
						TcSqlExec(cQuery)
					ENDIF 
			    ENDIF

				IF ALLTRIM(TRB->XX_DESC) == "RESULTADO PARCIAL"
					cCampo := "" 
					cCampo := "TRB->XX_VAL"+STRZERO(nSCAN3,3)
					nVcampo := 0
					nVcampo := VAL(StrTran(StrTran(&cCampo,".",""),",","."))
					cXCompet := ""
					cXCompet := SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN3,1])),1,4)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN3,1])),7,2)+"-"+SUBSTR(DTOS(CTOD("01/"+aPeriodo[nSCAN3,1])),5,2) 
					cQuery := ""
					cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[RentabilidadeContrato] "
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
					cQuery +="BEGIN "
					cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[RentabilidadeContrato] SET "
					cQuery +="				[Resultado]="+STR(nVcampo,14,2)//+","
//					cQuery +="				[ResultadoPREV]="+STR(aPrev[1,2],14,2)
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59' "
					cQuery +="END "
					TcSqlExec(cQuery)
			    ENDIF
			ENDIF
		TRB->(dbSkip())
	ENDDO
	ConOut("BKGCTR11: Finalizado processando Rentabilidade dos contratos - "+DTOC(DATE())+" "+TIME())   
ENDIF


Return



Static Function GeraXGCT11(_cAlias,cArqS,aTitulos,aCampos,aCabs,aImpr,aAlign,aFormat)

Local nHandle
Local cCrLf   	:= Chr(13) + Chr(10)
Local _ni,_nj
Local cPicN   	:= "@E 99999999.99999"
Local cDirTmp 	:= "C:\TMP"
Local cArqTmp 	:= cDirTmp+"\"+cArqS+".CSV"
Local lSoma,aSoma,nCab
Local cLetra	:= ""
Local cTpQuebra	:= ""
Local cQuebra	:= ""
Local aQuebra	:= {}

Local aPlans 	:= {}

Private xQuebra,xCampo


If MsgYesNo("Deseja gerar no formato Excel (.xlsx) ?")
   AADD(aPlans,{_cAlias,TRIM(cArqS),"",aTitulos,aCampos,aCabs,/*aImpr1*/, /* aAlign */,aFormat, /*aTotal */, /*cQuebra*/, lClose:= .F. })
   U_GeraXlsx(aPlans,"",cArqS, lClose:= .F.,)
   Return Nil
EndIf

MakeDir(cDirTmp)
fErase(cArqTmp)

lSoma := .F.
aSoma := {}
nCab  := 0

nHandle := MsfCreate(cArqTmp,0)
   
If nHandle > 0
      
   FOR _ni := 1 TO LEN(aTitulos)
      fWrite(nHandle, aTitulos[_ni])
      fWrite(nHandle, cCrLf ) // Pula linha
      nCab++
   NEXT

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
   
      IncProc("Gerando arquivo "+cArqS)   

      For _ni :=1 to LEN(aCampos)
         IF SUBSTR(aCampos[_ni],6,8) <> "XX_LINHA" //.AND. SUBSTR(aCampos[_ni],6,9) <> "XX_CODGCT"
         	xCampo := &(aCampos[_ni])
         	_uValor := ""
         	If VALTYPE(xCampo) == "D" // Trata campos data
            	_uValor := dtoc(xCampo)
         	Elseif VALTYPE(xCampo) == "N" // Trata campos numericos
            	_uValor := transform(xCampo,cPicN)
         	Elseif VALTYPE(xCampo) == "C"  .AND. SUBSTR(aCampos[_ni],6,6) <> "XX_VAL" .AND. SUBSTR(aCampos[_ni],6,8) <> "XX_TOTAL" .AND. SUBSTR(aCampos[_ni],6,8) <> "XX_INDIC"// Trata campos caracter
             	//_uValor := xCampo+CHR(160)
            	_uValor := '="'+ALLTRIM(xCampo)+'"'
         	ELSEIF SUBSTR(aCampos[_ni],6,6) == "XX_VAL" .OR. SUBSTR(aCampos[_ni],6,8) == "XX_TOTAL" .OR. SUBSTR(aCampos[_ni],6,8) == "XX_INDIC"// Trata campos numericos
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
                 	Elseif VALTYPE(xCampo) == "C" .AND. SUBSTR(aQuebra[_nj,1],6,8) <> "XX_VAL" .AND. SUBSTR(aCampos[_ni],6,8) <> "XX_TOTAL" .AND. SUBSTR(aCampos[_ni],6,8) <> "XX_INDIC" //Trata campos caracter
		            	_uValor := '="'+ALLTRIM(xCampo)+'"'
                 	ELSEIF SUBSTR(aQuebra[_nj,1],6,8) == "XX_VAL" .OR. SUBSTR(aCampos[_ni],6,8) == "XX_TOTAL" .OR. SUBSTR(aCampos[_ni],6,8) == "XX_INDIC"// Trata campos numericos
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

	MsgRun(cArqs,"Aguarde a abertura do Excel...",{|| ShellExecute("open", cArqTmp,"","",1) })

Else
   MsgAlert("Falha na criação do arquivo "+cArqTmp)
Endif
   
Return


//Atualiza tabela de custro 
Static Function  AtualizaCC()
Local _IX := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o Semaforo Tabela Centro de Custo                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
GetMv("MV_XXSEMAF")
RecLock("SX6",.F.)
SX6->X6_CONTEUD := "S"
msUnlock()
 
IncProc("Atualizando Tabela Centro de Custo...")

TCSQLExec("EXEC BKIntegraRubi.DBO.PROC_UPD_CUSTO "+SM0->M0_CODIGO)

IncProc("Atualizando Tabela Centro de Custo Consorcios...")

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


Static Function  ValidPerg

Local aArea      := GetArea()
Local aRegistros := {}
cPerg := "BKGCTR11"
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Contrato:","Contrato:","Contrato:","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","","BKGCTR11H1."})
AADD(aRegistros,{cPerg,"02","%Média Impostos e Contribuições:","%Média Impostos e Contribuições:" ,"%Média Impostos e Contribuições:" ,"mv_ch2","N",10,5,2,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","","BKGCTR11H2."})
AADD(aRegistros,{cPerg,"03","%Encargos CLT:","%Encargos:" ,"%Encargos:" ,"mv_ch3","N",10,5,2,"G","NaoVazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","","BKGCTR11H3."})
AADD(aRegistros,{cPerg,"04","%Encargos Autonomos:","%Encargos Autonomos:" ,"%Encargos Autonomos:" ,"mv_ch4","N",10,5,2,"G","NaoVazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","","BKGCTR11H4."})
AADD(aRegistros,{cPerg,"05","%Incidências:","%Incidências:" ,"%Incidências:" ,"mv_ch5","N",10,5,2,"G","NaoVazio()","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","S","","BKGCTR11H5."})
AADD(aRegistros,{cPerg,"06","%Taxa de Administração:","%Taxa de Administração:" ,"%Taxa de Administração:" ,"mv_ch6","N",10,5,2,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","S","","BKGCTR11H6."})

For i:=1 to Len(aRegistros)
	If !MsSeek(cPerg+aRegistros[i,2])
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



//********************VERSAO CONSOLIDA E RATEIA OU NAO AS DESPESAS ********************//
User Function BK2GCTR11(lJob,aAglContr)

Local _nI           := 0
Local aDbf 		    := {} //,cArqTmp
Local oTmpTb1
Local aDbf2         := {} //,cArqTmp2
Local oTmpTb2
Local cMes          := ""
Local cXXSEMAF		:= "N" 
Local aRetCons		:= {}
Local cLogCons   	:= ""
Local cCrLf   		:= Chr(13) + Chr(10) 

Private titulo      := "Rentabilidade dos Contratos"
Private aMeses		:= {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
Private aContratos 	:= {}
PRIVATE lConsorcio  := .F.
Private cPerg       := "BK2GCTR11"

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


PRIVATE nMImpContr  := 0
PRIVATE nTaxaAdm    := 0
PRIVATE nEncargos   := 0
PRIVATE nEncarIPT   := 0
PRIVATE nINCIDENCI  := 0
PRIVATE cProventos  := ""
PRIVATE cDescontos  := ""
PRIVATE cVT_Verb 	:= ""
PRIVATE cVT_Prov 	:= ""
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
PRIVATE cExm_Prod	:= ""
PRIVATE cMFG_Prod	:= ""
PRIVATE cDCH_Prod	:= ""
PRIVATE aFixeFX     := {}
Private aHeader	    := {}
PRIVATE nConsolida	:= 2
PRIVATE nIndConsor	:= 2
PRIVATE nRateia     := 1
PRIVATE nConsol     := 0
PRIVATE cConsolida 	:= ""
PRIVATE aConsolida 	:= {}
PRIVATE aContConsol := {}
PRIVATE cTipoContra := ""
PRIVATE aXXMIMPC	:= {}
PRIVATE aMImpContr  := {}
PRIVATE aTitulos,aCampos,aCabs,aFormat
PRIVATE aCampos2,aCabs2
PRIVATE ALIAS_TMP   := "TMPC"+ALLTRIM(SM0->M0_CODIGO)
PRIVATE ALIAS_FOL   := "TMPF"+ALLTRIM(SM0->M0_CODIGO)
PRIVATE cXXPLR 		:= ""
PRIVATE aFurnas:= {} 

Default lJob	:= .F.
Default aAglContr := {}

aFurnas  := U_StringToArray(ALLTRIM(SuperGetMV("MV_XXFURNAS",.F.,"105000381/105000391")), "/" )

IF !lJob
	ValidPerg2()
	If !Pergunte(cPerg,.T.)
		Return Nil
	Endif
ENDIF

aXXMIMPC	:= {}
aXXMIMPC	:= StrTokArr(GetMv("MV_XXMIMPC"),"|") //%Media de Impostos e Contribuicoes calculo Rentabilidade dos Contratos 
aMImpContr  := {}
FOR IX := 1 TO LEN(aXXMIMPC)
    AADD(aMImpContr,StrTokArr(aXXMIMPC[IX],";"))
NEXT

IF !lJob
	cContrato  	:= mv_par01
ELSE
	IF LEN(aAglContr) > 0
		AADD(aRetCons,aAglContr)
	ELSE 
	 	cContrato  	:= ""
	ENDIF
ENDIF

nMImpContr 	:= VAL(aMImpContr[1,2]) //mv_par02                                   
nEncargos  	:= GetMv("MV_XXENCAP") //mv_par03
nEncarIPT	:= GetMv("MV_XXEIPT")  //mv_par04
nINCIDENCI	:= GetMv("MV_XXINCID") //mv_par05
nTaxaAdm	:= GetMv("MV_XXTXADM") //mv_par06
IF !lJob
	nConsolida	:= mv_par07
	nIndConsor	:= mv_par08
	nRateia     := mv_par09 
ELSE
	IF LEN(aAglContr) > 0
		nConsolida	:= 1
		nIndConsor	:= 1
	ELSE
		nConsolida	:= 2
		nIndConsor	:= 2
	ENDIF
	nRateia     := 2  //NAO
ENDIF

//VERIFICA CHAMADA DE CONSOLIDAR
IF nConsolida == 1

	//Monta Tela para Consolidar
	IF !lJob
		aRetCons := MtaDlg01()
	ENDIF

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
			IF !MsSeek(xFilial("CN9") + cConsolida)
				IF !lJob
					MSGSTOP("Contrato n° "+cConsolida+" inválido. Verifique!!")
				ELSE
					ConOut("BK2GCTR11: Contrato n° "+cConsolida+" inválido. Verifique!!"+DTOC(DATE())+" "+TIME())   
				ENDIF
				RETURN NIl
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
			IF !MsSeek(xFilial("CN9") + cConsolida)
				IF !lJob
					MSGSTOP("Contrato n° "+cConsolida+" inválido. Verifique!!")
				ELSE
					ConOut("BK2GCTR11: Contrato n° "+cConsolida+" inválido. Verifique!!"+DTOC(DATE())+" "+TIME())   
				ENDIF
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
				IF MsSeek(xFilial("CN9") + ALLTRIM(aConsolida[_IX]))
					cConsolida += "'"+ALLTRIM(aConsolida[_IX])+"',"
				ELSE
				   cLogCons += "Contrato n° "+ALLTRIM(aConsolida[_IX])
				ENDIF
			NEXT
			IF LEN(cConsolida) > 1
				cConsolida := SUBSTR(cConsolida,1,LEN(cConsolida)-1)
			ENDIF
			IF !EMPTY(cLogCons)
				IF !lJob
			     	IF !MSGYESNO("- Contratos não encontrados e será desconsiderado da Consolidação -" +cCrLf+cCrLf+cLogCons+cCrLf+cCrLf+"Continua?")
			     	ENDIF
				ELSE
					ConOut("BK2GCTR11: - Contratos não encontrados e será desconsiderado da Consolidação - "+cLogCons+DTOC(DATE())+" "+TIME())   
				ENDIF
				RETURN NIL
			ENDIF		
		ENDIF
    ELSE
		IF !lJob
    		MSGSTOP("Informações para Consolidar invalida. Verifique!!")
		ELSE
			ConOut("BK2GCTR11: Informações para Consolidar invalida. Verifique!!"+cLogCons+DTOC(DATE())+" "+TIME())   
		ENDIF
		Return Nil
    ENDIF

ENDIF


cProventos  := GetMv("MV_XXPROVE") //"|1|2|11|34|36|56|60|64|65|68|100|102|104|108|110|126|266|268|270|274|483|600|640|656|664|674|675|685|696|725|726|727|728|729|745|747|749|750|754|755|756|757|758|760|761|762|763|764|765|778|779|787|789|790|791|792|824|"
cDescontos  := GetMv("MV_XXDESCO") //"|112|114|120|122|177|181|187|636|650|680|683|691|780|783|784"
cVT_Prov 	:= GetMv("MV_XXVTPRO") //"|671|"
cVT_Verb 	:= GetMv("MV_XXVTVER") //"|290|667|"
cVT_Prod   	:= GetMv("MV_XXVTPRD") //"|31201046|"
cVRVA_Verb  := GetMv("MV_XXVRVAV") //"|613|614|662|681|682|702|873|874|895|896|"
cVRVA_Prod  := GetMv("MV_XXVRVAP") //"|31201045|31201047|"
cASSM_Verb	:= GetMv("MV_XXASSMV") //"|605|689|733|734|742|770|771|773|794|796|832|856|"
cASSM_Prod	:= GetMv("MV_XXASSMP") //"|605|689|709|711|712|719|733|734|742|743|770|771|773|794|796|810|832|833|854|856|857|"
cSINO_Verb	:= GetMv("MV_XXSINOV") //"|510|607|665|679|724|739|825|900|"
cSINO_Prod	:= GetMv("MV_XXSINOP") //"|510|607|665|679|724|732|739|825|900|"
cCCRE_Verb	:= GetMv("MV_XXCCREV") //"|774|775|776|812|814|"
cCCRE_Prod	:= GetMv("MV_XXCCREP") //"|34202016|"
cCDPR_Prod	:= GetMv("MV_XXCDPRP") //"|320200111|34202034|000000000000112|34202057|34202086|"    cod produtos rateio no contrato
cCDPR_GRUP	:= GetMv("MV_XXCDPRG") //'|0008|0009|0010|'  *********                               cod grupo de produto rateio no contrato
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
	IF !lJob
		IF AVISO("Atenção","Incluir Contrato Consorcios??",{"Não","Sim"}) == 2
	   		lConsorcio := .T.
		ELSE
	   		lConsorcio := .F.
		ENDIF
	ELSE
  		lConsorcio := .T.
	ENDIF
ENDIF

FOR IX:= 1 TO LEN(aContrCons)
    AADD(aConsorcio,StrTokArr(aContrCons[IX],";"))
NEXT

 		
IF ALLTRIM(cXXSEMAF) == 'N'
	ProcRegua(100)
	Processa( {|| AtualizaCC() }) 
ELSE
	IF !lJob
		Msginfo("Atualizando tabela Folha de Pagamento!!")
	ELSE
		ConOut("BK2GCTR11: Atualizando tabela Folha de Pagamento"+cLogCons+DTOC(DATE())+" "+TIME())   
	ENDIF
    Return Nil
ENDIF


IF !EMPTY(cContrato)

	cQuery := "select MIN(CNF_DTVENC) AS CNF_INICIO, MAX(CNF_DTVENC) AS CNF_FIM FROM ( "
	cQuery += " SELECT CNF_DTVENC FROM "+RETSQLNAME("CNF")+" CNF "
	cQuery += " INNER JOIN "+RETSQLNAME("CN9")+" CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA " 
	cQuery += " AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = '' "
	cQuery += " WHERE CNF.D_E_L_E_T_='' " 
	IF nConsol == 1
   		cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) ='"+ALLTRIM(cConsolida)+"'"
   		IF cTipoContra == 'A'
			cQuery += " AND CN9_SITUAC = '05'"
   		ELSE
			cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"
   		ENDIF
	ELSEIF nConsol == 2
   		cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) ='"+ALLTRIM(cConsolida)+"'"
   		IF cTipoContra == 'A'
			cQuery += " AND CN9_SITUAC = '05'"
   		ELSE
			cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"
   		ENDIF
	ELSEIF nConsol == 3
   		cQuery += " AND CNF_CONTRA IN ("+ALLTRIM(cConsolida)+")"
   		IF cTipoContra == 'A'
			cQuery += " AND CN9_SITUAC = '05'"
   		ELSE
			cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"
   		ENDIF
	ELSE
   		cQuery += " AND CNF_CONTRA ='"+ALLTRIM(cContrato)+"'" 
		cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"
	ENDIF
	
	cQuery += "	) AS REGISTRO"

ELSE
	cContrCons := ""
 	For IX:= 1 TO LEN(aConsorcio)
 		cContrCons += "'"+ALLTRIM(aConsorcio[IX,1])+"',"
 	NEXT
	cQuery := " SELECT MIN(CNF_DTVENC) AS CNF_INICIO,MAX(CNF_DTVENC) AS CNF_FIM,CN9_SITUAC"
	cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"
	cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA"
	cQuery += " AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = '' WHERE CNF.D_E_L_E_T_=''"
	cQuery += " AND CN9_SITUAC = '05'"
	IF !lConsorcio
		IF !EMPTY(cContrCons)
			cQuery += " AND CNF_CONTRA NOT IN ("+SUBSTRING(ALLTRIM(cContrCons),1,LEN(cContrCons)-1)+") " 
		ENDIF
	ENDIF
	IF !lJob
		IF !lFurnas
			cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391'"
		ENDIF
	ELSE
 	    cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) <> '008' " //IPT 
 //	    cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) <> '049' "  
	    cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) <> '258' "  
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '247' "  
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391' " //FURNAS
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '438' "  
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '425' "  
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '455' "
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '467' "
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '507' "
	    cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '510' "
    	cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '521' "
	    cQuery += " AND CNF_CONTRA NOT IN ('193000288','194000289','195000290','196000291')"  
	    cQuery += " AND CNF_CONTRA NOT IN ('197000292','198000293','199000294')"  
    	cQuery += " AND CNF_CONTRA NOT IN ('197001292','198001293','199001294')" 
	    IF SM0->M0_CODIGO <> "14"  
	    	cQuery += " AND CNF_CONTRA NOT IN ('302000508')"
	    ENDIF  
	ENDIF

	cQuery += " GROUP BY CN9_SITUAC"

ENDIF	

TCQUERY cQuery NEW ALIAS "QTMP1"
TCSETFIELD("QTMP1","CNF_INICIO","D",8,0)	
TCSETFIELD("QTMP1","CNF_FIM","D",8,0)	

dbSelectArea("QTMP1")
dDataI		:= QTMP1->CNF_INICIO
dDataFinal	:= QTMP1->CNF_FIM
//cSituac 	:= QTMP1->CN9_SITUAC

QTMP1->(Dbclosearea())

IF EMPTY(DTOS(dDataI)) .OR. EMPTY(DTOS(dDataFinal)) 
	IF !lJob
		MSGSTOP("Contrato não encontrado!!")
	ELSE
		ConOut("BK2GCTR11: Contrato não encontrado!!"+cLogCons+DTOC(DATE())+" "+TIME())   
	ENDIF
    Return Nil

ENDIF

//Determina quantos Meses utilizar no calculo
nPeriodo += DateDiffMonth( dDataI , dDataFinal )

titulo   := titulo+" - Período: "+DTOC(dDataI)+" até "+DTOC(dDataFinal)

aDbf    := {}
Aadd( aDbf, { 'XX_LINHA', 'N', 10,00 } )
Aadd( aDbf, { 'XX_CODGCT','C', 09,00 } )
Aadd( aDbf, { 'XX_DESC',  'C', 50,00 } )
FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,3)
	Aadd( aDbf, { 'XX_VAL'+cMes,'C', 25,00 } )
NEXT
Aadd( aDbf, { 'XX_TOTAL','C', 25,0 } )
Aadd( aDbf, { 'XX_INDIC','C', 25,0 } )

//Aadd( aDbf, { 'XX_STATUS','C', 2,00 } )

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
aFormat := {}

AADD(aTitulos,titulo)

//AADD(aCampos,"TRB->XX_LINHA")
//AADD(aCabs  ,"Linha")
//AADD(aFormat,"")

AADD(aCampos,"TRB->XX_CODGCT")
AADD(aCabs  ,"Contrato")
AADD(aFormat,"")

AADD(aCampos,"TRB->XX_DESC")
AADD(aCabs  ,"Descrição")
AADD(aFixeFX,{"Descrição","XX_DESC",'C', 50,00,'@!'})
AADD(aHeader,{"Descrição","XX_DESC" ,"@!",50,00,"","","C","TRB","R"})
AADD(aFormat,"")

dDataInicio := dDataI
FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,3)
	AADD(aCampos,"TRB->XX_VAL"+cMes)
	AADD(aCabs,STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4))
	AADD(aFixeFX,{STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4),"XX_VAL"+cMes,'C', 10,00,'@!'})
    AADD(aHeader,{STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4),"XX_VAL"+cMes,"@!",10,00,"","","C","TRB","R"})
 	dDataInicio := MonthSum(dDataInicio,1)
	AADD(aFormat,"N")
NEXT

AADD(aCampos,"TRB->XX_TOTAL")
AADD(aCabs  ,"TOTAL")
AADD(aFixeFX,{"TOTAL","XX_TOTAL",'C', 10,00,'@!'})
AADD(aHeader,{"TOTAL","XX_TOTAL" ,"@!",10,00,"","","C","TRB","R"})
AADD(aFormat,"N")

AADD(aCampos,"TRB->XX_INDIC")
AADD(aCabs  ,"INDICE")
AADD(aFixeFX,{"INDICE","XX_INDIC",'C', 10,00,'@!'})
AADD(aHeader,{"INDICE","XX_INDIC" ,"@!",10,00,"","","C","TRB","R"})
AADD(aFormat,"N")

//AADD(aCampos,"TRB->XX_STATUS")

aDbf2    := {}

Aadd( aDbf2, { 'XX_CODGCT','C', 9,00 } )
Aadd( aDbf2, { 'XX_CODIGO','C', 16,00 } )
Aadd( aDbf2, { 'XX_DESC','C', 50,00 } )
FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,3)
	Aadd( aDbf2, { 'XX_VAL'+cMes,'N', 18,02 } )
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
dDataInicio := dDataI

FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,3)
	AADD(aCampos2,ALIAS_TMP+"->XX_VAL"+cMes)
	AADD(aCabs2,STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4))
  	AAdd(aPeriodo,{STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4)})
	AADD(aAnoMes,STRZERO(YEAR(dDataInicio),4)+STRZERO(Month(dDataInicio),2))	  
	dDataInicio := MonthSum(dDataInicio,1)
NEXT

IF !lJob

	// Criação de arquivo temporário para geração de planilha de Proventos e Descontos detalhados
	
	aDbf3    := {}
	aCabs3   := {}
	aCampos3 := {}
	
	Aadd( aDbf3, {'YY_CODGCT','C', 9,00 } )
	AADD(aCampos3,ALIAS_FOL+"->YY_CODGCT")
	AADD(aCabs3  ,"Contrato")

	Aadd( aDbf3, {'YY_CODIGO','C', 16,00 } )
	AADD(aCampos3,ALIAS_FOL+"->YY_CODIGO")
	AADD(aCabs3  ,"Cod.Evento")
	
	Aadd( aDbf3, {'YY_DESC','C', 50,00 } )
	AADD(aCampos3,ALIAS_FOL+"->YY_DESC")
	AADD(aCabs3  ,"Descrição")

	Aadd( aDbf3, {'YY_TIPO','C', 25,00 } )
	AADD(aCampos3,ALIAS_FOL+"->YY_TIPO")
	AADD(aCabs3  ,"Tipo")


	dDataInicio := dDataI

	FOR _nI := 1 TO nPeriodo
		cMes := STRZERO(_nI,3)
		Aadd( aDbf3, { 'YY_VAL'+cMes,'N', 18,02 } )
		AADD(aCampos3,ALIAS_FOL+"->YY_VAL"+cMes)
		AADD(aCabs3,STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4))
  		dDataInicio := MonthSum(dDataInicio,1)
	NEXT

	
	///cArqTmp3 := CriaTrab( aDbf3, .T. )
	///dbUseArea( .T.,NIL,cArqTmp3,ALIAS_FOL,.F.,.F. )
	///IndRegua(ALIAS_FOL,cArqTmp3,"YY_CODGCT+YY_TIPO+YY_CODIGO",,,"Indexando Arquivo de Trabalho") 
	///dbSetIndex(cArqTmp3+ordBagExt())

	oTmpTb3 := FWTemporaryTable():New( ALIAS_FOL ) 
	oTmpTb3:SetFields( aDbf3 )
	oTmpTb3:AddIndex("indice3", {"YY_CODGCT","YY_TIPO","YY_CODIGO"} )
	oTmpTb3:Create()

	//	

	ProcRegua(1)
	Processa( {|| ProcBKGCTR11(lJob) })
	Processa( {|| MBrwBKGCTR11() }) 

	///(ALIAS_FOL)->(Dbclosearea())
	///FErase(cArqTmp3+GetDBExtension())
	///FErase(cArqTmp3+OrdBagExt())
	oTmpTb3:Delete()
	
ELSE
	ProcBKGCTR11(lJob)
ENDIF

///(ALIAS_TMP)->(Dbclosearea())
oTmpTb2:Delete()
///TRB->(Dbclosearea())
oTmpTb1:Delete()
 
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

nSnd := 40

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



Static Function  ValidPerg2

Local aArea      := GetArea()
Local aRegistros := {}
cPerg := "BK2GCTR11"
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Contrato:","Contrato:","Contrato:","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"02","%Média Impostos e Contribuições:","%Média Impostos e Contribuições:" ,"%Média Impostos e Contribuições:" ,"mv_ch2","N",10,5,2,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","%Encargos CLT:","%Encargos:" ,"%Encargos:" ,"mv_ch3","N",10,5,2,"G","NaoVazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"04","%Encargos Autonomos:","%Encargos Autonomos:" ,"%Encargos Autonomos:" ,"mv_ch4","N",10,5,2,"G","NaoVazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"05","%Incidências:","%Incidências:" ,"%Incidências:" ,"mv_ch5","N",10,5,2,"G","NaoVazio()","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"06","%Taxa de Administração:","%Taxa de Administração:" ,"%Taxa de Administração:" ,"mv_ch6","N",10,5,2,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"07","Consolidar Contratos?","Consolidar Contratos?","Consolidar Contratos?","mv_ch7","N",01,0,2,"C","","mv_par07","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"08","Consorcio Aplicar Indice Total?","Consorcio Aplicar Indice Total","Consorcio Aplicar Indice Total","mv_ch8","N",01,0,2,"C","","mv_par08","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"09","Rateia Despesas no Cronograma?","Rateia Despesas no Cronograma?","Rateia Despesas no Cronograma?","mv_ch9","N",01,0,1,"C","","mv_par09","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegistros)
	If !MsSeek(cPerg+aRegistros[i,2])
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


USER FUNCTION GRFBKGCT11(lJob)
PRIVATE aAglutGCT := {}

Default lJob	:= .F.

IF !lJob
   IF !MsgNoYes("Esta rotina exige muito recurso do sistema! Gostaria mesmo de executar ?")
   		RETURN NIL
   ENDIF
ENDIF


IF SM0->M0_CODIGO == "01"      // BK
 
  	U_BK2GCTR11(.T.) // ALTERADO PARA ESTA FUNCAO PARA UTILIZAR 

	AADD(aAglutGCT,{'S','105000391','A'})
	U_BK2GCTR11(.T.,aAglutGCT[1])
  	AADD(aAglutGCT,{'P','008000300','A'})
	U_BK2GCTR11(.T.,aAglutGCT[2])
	AADD(aAglutGCT,{'S','157000247','A'})
  	U_BK2GCTR11(.T.,aAglutGCT[3])
	AADD(aAglutGCT,{'S','157000438','A'})
 	U_BK2GCTR11(.T.,aAglutGCT[4])
	AADD(aAglutGCT,{'N','163000240','A'})
  	U_BK2GCTR11(.T.,aAglutGCT[5])
	AADD(aAglutGCT,{'N','193000288;194000289;195000290;196000291;','A'})
  	U_BK2GCTR11(.T.,aAglutGCT[6])
	AADD(aAglutGCT,{'N','197000292;198000293;199000294;197001292;198001293;199001294;','A'})
 	U_BK2GCTR11(.T.,aAglutGCT[7])
	AADD(aAglutGCT,{'N','211000316','A'})
 	U_BK2GCTR11(.T.,aAglutGCT[8])
	AADD(aAglutGCT,{'N','215000318','A'})
 	U_BK2GCTR11(.T.,aAglutGCT[9])
	AADD(aAglutGCT,{'S','018000425','A'})
  	U_BK2GCTR11(.T.,aAglutGCT[10])
	AADD(aAglutGCT,{'P','258000429','A'})
	U_BK2GCTR11(.T.,aAglutGCT[11])
	AADD(aAglutGCT,{'S','012000467','A'})
  	U_BK2GCTR11(.T.,aAglutGCT[12])  
	AADD(aAglutGCT,{'S','281000455','A'})
  	U_BK2GCTR11(.T.,aAglutGCT[13])
	AADD(aAglutGCT,{'S','316000507','A'})
  	U_BK2GCTR11(.T.,aAglutGCT[14])
	AADD(aAglutGCT,{'S','281003510','A'})
  	U_BK2GCTR11(.T.,aAglutGCT[15])
	AADD(aAglutGCT,{'S','333000521','A'})
 	U_BK2GCTR11(.T.,aAglutGCT[16])
 	
ELSEIF SM0->M0_CODIGO == "02"      // BK

  	U_BK2GCTR11(.T.) // ALTERADO PARA ESTA FUNCAO PARA UTILIZAR 

 	AADD(aAglutGCT,{'P','008025001','A'})
  	U_BK2GCTR11(.T.,aAglutGCT[1])

ELSEIF SM0->M0_CODIGO == "14"      // BK

  	U_BK2GCTR11(.T.) // ALTERADO PARA ESTA FUNCAO PARA UTILIZAR 

ENDIF

RETURN NIL



USER FUNCTION PREVCONTRA(cCONTRA,cPERIODO)
LOCAL aPREV := {}
LOCAL lCOMPET := .F.

IF nConsolida == 1
	nTSZG03   := 0
	nTResult  := 0
	nTSalario := 0
	nTDespesa := 0

	FOR _IX := 1 TO LEN(aContConsol)
		//Calcula Valores da Projeção Financeira
		cCONTRA:= ALLTRIM(aContConsol[_IX,1])
		lCOMPET 	:= .F.
	    nSZG03 		:= 0
	    nSZG09 		:= 0
	    nSZG110		:= 0
	    nSZG12 		:= 0
	    nSZG30  	:= 0
	    nSZCSTBK 	:= 0
		nDespesa 	:= 0
		dDtProj     := CTOD("")
		cSeqProj	:= ""
		nIndTC 		:= 0
		nSalario 	:= 0
		nInsumos 	:= 0 

	    dbselectArea("SZG")
		cContRev := xFilial("SZG")+ALLTRIM(cCONTRA)
		SZG->(MsSeek(cContRev,.T.))
		Do While !EOF() .AND. ALLTRIM(cContRev) == ALLTRIM(SZG->ZG_FILIAL+SZG->ZG_CONTRAT) //+SZG->ZG_REVISAO
			IF SUBSTR(DTOS(SZG->ZG_DATA),1,6) <= SUBSTR(DTOS(CTOD(cPERIODO)),1,6)
	      		nDespesa	:= SZG->ZG_CLT+SZG->ZG_VLENCSO+SZG->ZG_AJCUSTO+SZG->ZG_VLENAC+SZG->ZG_BENEFIC+SZG->ZG_UNIFORM+SZG->ZG_DESPDIV+SZG->ZG_MATERIA+SZG->ZG_EQUIPAM+SZG->ZG_VLTRIBU             

	          	nInsumos :=	SZG->ZG_UNIFORM + SZG->ZG_DESPDIV + SZG->ZG_MATERIA + SZG->ZG_EQUIPAM            
          		//nInsumos :=	SZG->ZG_UNIFORM + SZG->ZG_MATERIA + SZG->ZG_EQUIPAM            
		
				dDtProj     := SZG->ZG_DATA
				cSeqProj	:= SZG->ZG_SEQ
	  					
	  			cQuery := " SELECT SUM(CNF_VLPREV) AS CNF_FATURA,COUNT(CNF_VLPREV) AS _NCONT"+CRLF
	    		cQuery += " FROM "+RETSQLNAME("CNF")+ " CNF"+CRLF
				cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA"+CRLF
				cQuery += " AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = '' WHERE CNF.D_E_L_E_T_=''"+CRLF
				cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
				cQuery += " AND CNF.CNF_CONTRA='"+ALLTRIM(cCONTRA)+"'AND "+CRLF
				cQuery += " CNF.CNF_FILIAL = '"+xFilial("CNF")+"' "+CRLF
				cQuery += " AND CNF.CNF_COMPET='"+SUBSTR(DTOS(CTOD(cPERIODO)),5,2)+"/"+SUBSTR(DTOS(CTOD(cPERIODO)),1,4)+"'"+CRLF
		      
				TCQUERY cQuery NEW ALIAS "TMPX2"
	
				lCOMPET 	:= .F.
				dbSelectArea("TMPX2")
				TMPX2->(dbGoTop())
				DO WHILE TMPX2->(!EOF())
					IF TMPX2->_NCONT > 0
						lCOMPET := .T.
					ENDIF
							
					//VERIFICA INDECE CONSORCIO CASO CONTRATO DE CONSORCIO
	        		nIndTC := 0
	        		IF nIndConsor == 1
						nScan:= 0
						nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(cCONTRA) })
			   			IF nScan > 0
			       			nIndTC := VAL(aConsorcio[nScan,6]) 
			    		ENDIF
			    	ENDIF
	
					nSZG03 := IIF(nIndTC>0,TMPX2->CNF_FATURA/(nIndTC/100),TMPX2->CNF_FATURA)
	
					TMPX2->(dbSkip())
				ENDDO
				TMPX2->(dbCloseArea())
	         	//PROVENTOS	
				nSZG09 := IIF(nIndTC>0,(SZG->ZG_CLT+SZG->ZG_VLENCSO)/(nIndTC/100),SZG->ZG_CLT+SZG->ZG_VLENCSO)
	            //BENEFICIOS
	         	nSZG12 := IIF(nIndTC>0,SZG->ZG_BENEFIC/(nIndTC/100),SZG->ZG_BENEFIC)
	            //GASTOS GERAIS-INSUMOS
	         	nSZG30 := IIF(nIndTC>0,(SZG->ZG_AJCUSTO+SZG->ZG_VLENAC+SZG->ZG_UNIFORM+SZG->ZG_DESPDIV+;
							SZG->ZG_MATERIA+SZG->ZG_EQUIPAM)/(nIndTC/100),(SZG->ZG_AJCUSTO+SZG->ZG_VLENAC+SZG->ZG_UNIFORM+;
							SZG->ZG_DESPDIV+SZG->ZG_MATERIA+SZG->ZG_EQUIPAM))
								
				nSZCSTBK := SZG->ZG_AJCUSTO+SZG->ZG_VLENAC	
			ENDIF
	        dbselectArea("SZG")
		   	SZG->(dbSkip())
		ENDDO
		
		nResult := 0
		nResult := IIF(nSZG03>0,nSZG03-nDespesa,0)
		//FATURAMENTOPREV/RESULTADOPREV/SALARIOSPREV/GASTOSGERAISPREV
		IF lCOMPET
			nTSZG03   += nSZG03
			nTResult  += nResult
			nTSalario += nSZG09+nSZG12 // Salarios
			nTDespesa += nSZG30 //nInsumos //nDespesa-nSalario
	    ENDIF
    NEXT
	AADD(aPrev,{nTSZG03,nTResult,nTSalario,nTDespesa})
ELSE
	//Calcula Valores da Projeção Financeira
    nSZG03 := 0
    nSZG09 := 0
    nSZG110:= 0
    nSZG12 := 0
    nSZG30  := 0
    nSZCSTBK := 0
	nDespesa := 0
	dDtProj     := CTOD("")
	cSeqProj	:= ""
	nIndTC := 0
	nSalario := 0
	nInsumos := 0 
    dbselectArea("SZG")
	cContRev := xFilial("SZG")+ALLTRIM(cCONTRA)
	SZG->(MsSeek(cContRev,.T.))
	Do While !EOF() .AND. ALLTRIM(cContRev) == ALLTRIM(SZG->ZG_FILIAL+SZG->ZG_CONTRAT) //+SZG->ZG_REVISAO
		IF SUBSTR(DTOS(SZG->ZG_DATA),1,6) <= SUBSTR(DTOS(CTOD(cPERIODO)),1,6)
      		nDespesa	:= SZG->ZG_CLT+SZG->ZG_VLENCSO+SZG->ZG_AJCUSTO+SZG->ZG_VLENAC+SZG->ZG_BENEFIC+SZG->ZG_UNIFORM+SZG->ZG_DESPDIV+SZG->ZG_MATERIA+SZG->ZG_EQUIPAM+SZG->ZG_VLTRIBU             

          	nInsumos :=	SZG->ZG_UNIFORM + SZG->ZG_DESPDIV + SZG->ZG_MATERIA + SZG->ZG_EQUIPAM
          	//nInsumos :=	SZG->ZG_UNIFORM + SZG->ZG_MATERIA + SZG->ZG_EQUIPAM            

			dDtProj     := SZG->ZG_DATA
			cSeqProj	:= SZG->ZG_SEQ
  					
  			cQuery := " SELECT SUM(CNF_VLPREV) AS CNF_FATURA"
    		cQuery += " FROM "+RETSQLNAME("CNF")+ " CNF"
			cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA"
			cQuery += " AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = '' WHERE CNF.D_E_L_E_T_=''"
			cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"
			cQuery += " AND CNF.CNF_CONTRA='"+ALLTRIM(cCONTRA)+"'AND "
			cQuery += " CNF.CNF_FILIAL = '"+xFilial("CNF")+"' "
			cQuery += " AND CNF.CNF_COMPET='"+SUBSTR(DTOS(CTOD(cPERIODO)),5,2)+"/"+SUBSTR(DTOS(CTOD(cPERIODO)),1,4)+"'"
	      
			TCQUERY cQuery NEW ALIAS "TMPX2"

			dbSelectArea("TMPX2")
			TMPX2->(dbGoTop())
			DO WHILE TMPX2->(!EOF())
				//VERIFICA INDECE CONSORCIO CASO CONTRATO DE CONSORCIO
        		nIndTC := 0
        		IF nIndConsor == 1
					nScan:= 0
					nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(cCONTRA) })
		   			IF nScan > 0
		       			nIndTC := VAL(aConsorcio[nScan,6]) 
		    		ENDIF
		    	ENDIF

				nSZG03 := IIF(nIndTC>0,TMPX2->CNF_FATURA/(nIndTC/100),TMPX2->CNF_FATURA)

				TMPX2->(dbSkip())
			ENDDO
			TMPX2->(dbCloseArea())
         	//PROVENTOS	
			nSZG09 := IIF(nIndTC>0,(SZG->ZG_CLT+SZG->ZG_VLENCSO)/(nIndTC/100),SZG->ZG_CLT+SZG->ZG_VLENCSO)
            //BENEFICIOS
         	nSZG12 := IIF(nIndTC>0,SZG->ZG_BENEFIC/(nIndTC/100),SZG->ZG_BENEFIC)
            //GASTOS GERAIS-INSUMOS
         	nSZG30 := IIF(nIndTC>0,(SZG->ZG_AJCUSTO+SZG->ZG_VLENAC+SZG->ZG_UNIFORM+SZG->ZG_DESPDIV+;
						SZG->ZG_MATERIA+SZG->ZG_EQUIPAM)/(nIndTC/100),(SZG->ZG_AJCUSTO+SZG->ZG_VLENAC+SZG->ZG_UNIFORM+;
						SZG->ZG_DESPDIV+SZG->ZG_MATERIA+SZG->ZG_EQUIPAM))
							
			nSZCSTBK := SZG->ZG_AJCUSTO+SZG->ZG_VLENAC	
		ENDIF
        dbselectArea("SZG")
	   	SZG->(dbSkip())
	ENDDO
	
	nResult := 0
	nResult := IIF(nSZG03>0,nSZG03-nDespesa,0)
	//FATURAMENTOPREV/RESULTADOPREV/SALARIOSPREV/GASTOSGERAISPREV
	AADD(aPrev,{nSZG03,nResult,nSZG09+nSZG12,nSZG30})//nSalario,nSZG30})//nInsumos}) //nDespesa-nSalario})
ENDIF

IF LEN(aPrev) == 0 
	AADD(aPrev,{0,0,0,0})
ENDIF

RETURN aPrev


USER FUNCTION BUSCACN9(cNumContr,cCampo)
Local cCmpDesc := ""
Local aArea    := GetArea()
Local lFIM     := .F.

cCampo := "CN9->"+ALLTRIM(cCampo)

DBSELECTAREA("CN9")
CN9->(DBSETORDER(1))
CN9->(MsSEEK(xFILIAL("CN9")+cNumContr))
DO WHILE CN9->(!EOF())  .AND. !lFIM
	IF ALLTRIM(CN9->CN9_NUMERO) == ALLTRIM(cNumContr)
		cCmpDesc := &cCampo
	ELSE
		lFIM     := .T.
	ENDIF
	CN9->(dbSkip())
ENDDO

RestArea(aArea)
RETURN cCmpDesc
 



// Gera Planilha Excel dos Proventos e  Descontos - 04/08/19
User FUNCTION GCT11FOL()
Local aPlans  := {}

AADD(aPlans,{ALIAS_FOL,TRIM(cPerg),"","Detalhes FP: "+titulo,aCampos3,aCabs3,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
U_GeraXml(aPlans,"Detalhes FP: "+titulo,TRIM(cPerg),.F.)

Return 



// Atualiza tabela de detalhamento da Folha de Pagamento
Static Function UpdTmpFol(lJob,cContrato,cEvento,cDesc,cTipo,nValor,_nI)
Local aArea3
Private cCampo3
If !lJob
	aArea3 := GetArea()
	dbSelectArea(ALIAS_FOL)
	If !MsSeek(cContrato+PAD(cTipo,25)+cEvento,.F.)
  		Reclock(ALIAS_FOL,.T.)
		(ALIAS_FOL)->YY_CODGCT := cContrato
		(ALIAS_FOL)->YY_CODIGO := cEvento
		(ALIAS_FOL)->YY_DESC   := cDesc
		(ALIAS_FOL)->YY_TIPO   := cTipo
		cCampo3  := ALIAS_FOL+"->YY_VAL"+STRZERO(_nI,3)
		&cCampo3 := nValor
	Else	
   		Reclock(ALIAS_FOL,.F.)
		cCampo3  := ALIAS_FOL+"->YY_VAL"+STRZERO(_nI,3)
		&cCampo3 += nValor
	EndIf
	(ALIAS_FOL)->(Msunlock())
	RestArea(aArea3)
EndIf
Return Nil


// Rateio Contrato x Produtos - Marcos 15/01/2020
User Function RatCtrPrd(cCtr,cPrd,aRatCtrPrd)
Local nCtr := 0
Local nPrd := 0
Local lRet := .F.

nCtr := ascan(aRatCtrPrd,{|x| x[1] == cCtr })
If nCtr > 0
	nPrd := ascan(aRatCtrPrd[nCtr,2],{|x| x == cPrd })
	If nPrd > 0
		lRet := .T.
	EndIf
EndIf

Return lRet


User Function DefCtrPrd()
Local aRet

// Rateio especifico por produtos ex. alugueis lançados em um unico doc de entrada
// Rateio  Contrato  x  Produtos                       15/01/20 - Marcos
aRet := {{"345000529",{"320200301","000000000000102"}}}

//		 {"302000508",{"000000000000102"}}}
Return aRet




// Buscar Titulos do contas a pagar por itens dos Documentos de Entrada
// 20/07//2020
User Function fAcrDcr()
Local aAcrDcr := {}
Local cQuery3 := ""
Local nTotE2  := 0
Local nACrDcr := 0
Local _nY	  := 0

cQuery3 := " SELECT E2_VENCTO,E2_VALOR,E2_DESCONT,E2_MULTA,E2_JUROS,E2_ACRESC,E2_DECRESC,E2_VRETPIS,E2_VRETCOF,E2_VRETCSL,E2_VRETINS,E2_VRETIRF,E2_VRETISS"+CRLF
cQuery3 += " FROM "+RETSQLNAME("SE2")+" SE2"+CRLF
cQuery3 += " WHERE SE2.D_E_L_E_T_='' AND SE2.E2_FILIAL = '"+xFilial("SE2")+"' AND E2_TIPO ='NF' "+CRLF
cQuery3 += "   AND E2_PREFIXO = '"+TMPX2->D1_SERIE+"'" +CRLF
cQuery3 += "   AND E2_NUM = '"+TMPX2->D1_DOC+"'" +CRLF
cQuery3 += "   AND E2_FORNECE = '"+TMPX2->D1_FORNECE+"'" +CRLF
cQuery3 += "   AND E2_LOJA = '"+TMPX2->D1_LOJA+"'" +CRLF

u_LogMemo("BKGCTR11-E2-1"+STRZERO(_nI,3)+".SQL",cQuery3)

TCQUERY cQuery3 NEW ALIAS "QTMPXE2"
dbSelectArea("QTMPXE2")
dbGoTop()

nTotE2  := 0
Do While !QTMPXE2->(EOF())
	nACrDcr := 0
	If QTMPXE2->E2_DECRESC > 0
		nACrDcr -= QTMPXE2->E2_DECRESC
	Else
		nACrDcr -= QTMPXE2->E2_DESCONT
	EndIf
	If QTMPXE2->E2_ACRESC > 0
		nACrDcr += QTMPXE2->E2_ACRESC
	Else
		nACrDcr += QTMPXE2->E2_MULTA + QTMPXE2->E2_JUROS
	EndIf
	// Guardar no Array o valor proporcional do decrescimo ou acrescimo no mes de referencia
	If ABS(nACrDcr) > 0
		aAdd(aAcrDcr,{SUBSTR(QTMPXE2->E2_VENCTO,1,6),nACrDcr,0})
	EndIf
	nTotE2 += QTMPXE2->(E2_VALOR+E2_VRETPIS+E2_VRETCOF+E2_VRETCSL+E2_VRETINS+E2_VRETIRF+E2_VRETISS)
	dbSkip()
Enddo

// Teste
//If TMPX2->D1_TOTAL > nTotE2
//	ixi := 0
//EndIf

For _nY := 1 To Len(aAcrDcr)
	//                        Val desc/Acr  / Tot Geral * Valor do Item   			
	aAcrDcr[_nY,3] := Round((aAcrDcr[_nY,2] / nTotE2) * TMPX2->D1_TOTAL,2)
NExt
QTMPXE2->(Dbclosearea())

Return aAcrDcr


// Gravar o custo dos Documentos de Entrada por Categoria/Produto
// 19/07/2020
Static Function GravaCCD1(cAliasTmp,nConsol,cCusto,cPrd,_nI,nValor,aAcrDcr,cOutros,cOutros1,lPRat,cDesc)

Local nY 			:= 0
Local nYMes 		:= 0
Local cRet 			:= cOutros

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

cCampo2  := cAliasTmp+"->XX_VAL"+STRZERO(_nI,3)
&cCampo2 += nValor
If lPRat // Só fazer no primeiro item do rateio
	// Gravar Acrescimos e Decrescimos Financeiros
	For nY := 1 To Len(aAcrDcr)
		nYMes := ASCAN(aAnoMes,{|x| x == aAcrDcr[nY,1]})
		If nYmes > 0
			cCampo2  := cAliasTmp+"->XX_VAL"+STRZERO(nYMes,3)
			&cCampo2 += aAcrDcr[nY,3]
		EndIf
	Next
EndIf
(cAliasTmp)->(Msunlock())
cRet := cOutros1

Return cRet
