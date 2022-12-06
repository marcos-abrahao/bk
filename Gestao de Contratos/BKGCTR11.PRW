#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

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
	Local iX			:= 0
	Local aDbf 		    := {} //cArqTmp
	Local oTmpTb1
	Local aDbf2         := {} //,cArqTmp2
	Local oTmpTb2
	Local aDbf3         := {} //,cArqTmp3
	Local oTmpTb3
	Local cMes          := ""
	Local cXXSEMAF		:= "N"
	Local dMaxCompet	:= CTOD("")

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
	Private cParAnoMes  := ""
	Private aPeriodo    := {}
	Private aAnoMes     := {}
	Private aAcrDcr 	:= {}
	Private cLastE2     := ""
	Private lPRat		:= .T.

	Private nTamCodGct	:= 9
	Private nTamCodigo	:= 16

	Private cCtrCons    := ""

	Private nMImpContr  := 0
	Private nTaxaAdm    := 0
	Private nEncargos   := 0
	Private nEncarIPT   := 0
	Private nIncidenci  := 0
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
	Private cDViagens	:= "34202003"
	Private cCusBK		:= U_MVXCUSBK()
	Private aFixeFX     := {}
	Private aHeader	    := {}
	Private nConsolida	:= 2
	Private nIndConsor	:= 1
	Private nIndDesp	:= 1
	Private nRateia     := 2
	Private nConsol     := 0
	Private cConsolida 	:= ""
	Private aConsolida 	:= {}
	Private aContConsol := {}
	Private cTipoContra := ""
	Private aXMIMPC		:= {}
	Private aMImpContr  := {}
	Private ALIAS_TMP   := "TMPC"+ALLTRIM(SM0->M0_CODIGO)
	Private ALIAS_FOL   := "TMPF"+ALLTRIM(SM0->M0_CODIGO)
	Private cXXPLR 		:= ""
	Private aFurnas		:= U_MVXFURNAS()

	Private aTitulos,aCampos,aCabs,aFormat
	Private aCampos2,aCabs2
	Private aCampos3,aCabs3

	Default lJob		:= .F.

	IF !lJob
		ValidPerg()
		If !Pergunte(cPerg,.T.)
			Return Nil
		Endif
		u_MsgLog(cPerg)
	ENDIF


	aXMIMPC	:= {}
	aXMIMPC	:= StrTokArr(U_MVXMIMPC(),"|") //%Media de Impostos e Contribuicoes calculo Rentabilidade dos Contratos
	aMImpContr  := {}
	FOR IX := 1 TO LEN(aXMIMPC)
		AADD(aMImpContr,StrTokArr(aXMIMPC[IX],";"))
	NEXT

	IF !lJob
		cContrato  	:= mv_par01
		cParAnoMes  := mv_par07
		If Val(Substr(cParAnoMes,1,4)) < 2008 .OR. VAL(SUBSTR(cParAnoMes,5,2)) < 0 .OR. VAL(SUBSTR(cParAnoMes,5,2)) > 12
			cParAnoMes  := ""
		EndIf
	ELSE
		cContrato  	:= ""
		cParAnoMes  := ""
		//u_xxConOut("INFO","BKGCTR11","Inicio do processamento: Rentabilidade dos Contratos")
	ENDIF

	nMImpContr 	:= VAL(aMImpContr[1,2])// mv_par02
	nEncargos  	:= U_MVXENCAP()        // BK 37.1328 MMDK 8
	nEncarIPT	:= U_MVXEIPT()         // BK 20      MMDK 1
	nIncidenci	:= U_MVXINCID()        // BK 28.860  MMDK 20.700
	nTaxaAdm	:= U_MVXTXADM()	       // mv_par06
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
	cCCRE_Verb	:= "" //GetMv("MV_XXCCREV") //"|774|775|776|812|814|"
	cCCRE_Prod	:= "" //GetMv("MV_XXCCREP") //INUTILIZADO //"|34202016|"
	cCDPR_Prod	:= U_MVXCDPRP()
	cCDPR_GRUP	:= U_MVXCDPRG()
	cNINC_Verb	:= U_MVXNINCI()

	aContrCons	:= {}
	aContrCons	:= U_MVXCONS()

// Rateio        Contrato  x  Produtos                       15/01/20 - Marcos
	aRatCtrPrd  := U_DefCtrPrd()

	cExm_Prod	:= U_MVXCEXMP()
	cMFG_Prod	:= U_MVXCMFGP()
	cDCH_Prod	:= U_MVXCDCH()
	cXXPLR	    := U_MVXPLR()

//MV_XXSEMAF    C   Semaforo controle de execução da procedure de atualização tabela centro de custo integração Rubi X Microsiga
	cXXSEMAF	:= u_BkGetMv("MV_XXSEMAF",.F.,"N",,cEmpAnt)
	IF EMPTY(cContrato)
		IF !lJob
			//IF AVISO("Atenção","Incluir Contrato Consorcios??",{"Não","Sim"}) == 2
			//	lConsorcio := .T.
			//ELSE
			lConsorcio := .F.
			//ENDIF
			//IF AVISO("Atenção","Incluir Contrato Furnas - Filial 381/391  ??",{"Não","Sim"}) == 2
			//	lFurnas := .T.
			//ELSE
			lFurnas := .F.
			//ENDIF
		ELSE
			lConsorcio := .F.
			lFurnas := .F.
		ENDIF

	ENDIF

	FOR IX:= 1 TO LEN(aContrCons)
		AADD(aConsorcio,StrTokArr(aContrCons[IX],";"))
	NEXT

	IF ALLTRIM(cXXSEMAF) == 'N'
		u_WaitLog(cPerg, {|oSay| AtualizaCC()}, titulo)
	ELSE
		u_MsgLog(cPerg,"Atualizando tabela Folha de Pagamento!!")
		Return Nil
	ENDIF

	If !Empty(cParAnoMes)
		dDataI := CTOD('01/'+SUBSTR(cParAnoMes,5,2)+'/'+SUBSTR(cParAnoMes,1,4))
		dDataFinal := LastDay(dDataI)
	Else
		IF !EMPTY(cContrato)
			cQuery := "SELECT TOP 1 MIN(CN9_DTOSER) AS CN9_DTOSER,MIN(CN9_DTINIC) AS CN9_DTINIC,MIN(CNF_DTVENC) AS CNF_INICIO,MAX(CNF_DTVENC) AS CNF_FIM,CN9_SITUAC,CN9_REVISA,"+CRLF
			cQuery += " MAX((SUBSTRING(CNF_COMPET,4,4))+SUBSTRING(CNF_COMPET,1,2))+'01' AS MAXCOMPET"+CRLF
			cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF
			cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA"+CRLF
			cQuery += "    AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"+CRLF
			cQuery += " WHERE CNF.D_E_L_E_T_=''"+CRLF
			cQuery += "    AND CNF_CONTRA ='"+ALLTRIM(cContrato)+"'"+CRLF
			cQuery += " GROUP BY CN9_REVISA,CN9_SITUAC"+CRLF
			cQuery += " ORDER BY CN9_REVISA DESC"+CRLF
		ELSE
			cContrCons := ""
			For IX:= 1 TO LEN(aConsorcio)
				cContrCons += "'"+ALLTRIM(aConsorcio[IX,1])+"',"
			NEXT
			cQuery := " SELECT MIN(CN9_DTOSER) AS CN9_DTOSER,MIN(CN9_DTINIC) AS CN9_DTINIC,MIN(CNF_DTVENC) AS CNF_INICIO,MAX(CNF_DTVENC) AS CNF_FIM,CN9_SITUAC,"+CRLF
			cQuery += " MAX((SUBSTRING(CNF_COMPET,4,4))+SUBSTRING(CNF_COMPET,1,2))+'01' AS MAXCOMPET"+CRLF
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
		TCSETFIELD("QTMP1","CNF_FIM"   ,"D",8,0)
		TCSETFIELD("QTMP1","CN9_DTINIC","D",8,0)
		TCSETFIELD("QTMP1","CN9_DTOSER","D",8,0)

		dbSelectArea("QTMP1")
	//dDataI		:= QTMP1->CNF_INICIO
		dDataI		:= QTMP1->CN9_DTOSER
		If Empty(dDataI)
			dDataI	:= QTMP1->CN9_DTINIC
		EndIf
		If !Empty(QTMP1->CNF_INICIO) .AND. QTMP1->CNF_INICIO < dDataI
			dDataI	:= QTMP1->CNF_INICIO
		EndIf

		dDataFinal	:= QTMP1->CNF_FIM
		dMaxCompet  := STOD(QTMP1->MAXCOMPET)
		If dMaxCompet > dDataFinal
			dDataFinal := LastDay(dMaxCompet)
		EndIf


		QTMP1->(Dbclosearea())

		IF EMPTY(DTOS(dDataI)) .OR. EMPTY(DTOS(dDataFinal))
			MSGSTOP("Contrato não encontrado!!")
			RETURN NIL
		ENDIF

	// Voltar 1 mes
		dDataI := dDataI - Day(dDataI)
		dDataI := dDataI - Day(dDataI)+1
 
	EndIf


//Determina quantos Meses utilizar no calculo
	nPeriodo += DateDiffMonth( dDataI , dDataFinal )

	titulo   := titulo+IIf(!Empty(cContrato)," - "+TRIM(cContrato),"")+" - Período: "+DTOC(dDataI)+" até "+DTOC(dDataFinal)

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
		AADD(aFormat,"N2")
		dDataInicio := MonthSum(dDataInicio,1)
	NEXT

	AADD(aCampos,"TRB->XX_TOTAL")
	AADD(aCabs  ,"TOTAL")
	AAdd(aFixeFX,{"TOTAL","XX_TOTAL",'C', 10,00,'@!'})
	AADD(aHeader,{"TOTAL","XX_TOTAL","@!",10,00,"","","C","TRB","R"})
	AADD(aFormat,"N2")

	AADD(aCampos,"TRB->XX_INDIC")
	AADD(aCabs  ,"INDICE")
	AAdd(aFixeFX,{"INDICE","XX_INDIC",'C', 10,00,'@!'})
	AADD(aHeader,{"INDICE","XX_INDIC" ,"@!",10,00,"","","C","TRB","R"})
	AADD(aFormat,"N2")

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

		u_WaitLog(cPerg, {|oSay| ProcBKGCTR11(lJob)}, titulo)
		u_WaitLog(cPerg, {|oSay| MBrwBKGCTR11()}, "Browse")

		///(ALIAS_FOL)->(Dbclosearea())
		///FErase(cArqTmp3+GetDBExtension())
		///FErase(cArqTmp3+OrdBagExt())
		oTmpTb3:Delete()

	ELSE
		u_WaitLog(cPerg, {|oSay| ProcBKGCTR11(lJob)}, titulo)
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


	AADD(aLegenda,{"BR_VERMELHO"," - 01 Cancelado"})
	AADD(aLegenda,{"BR_AMARELO"," - 02 Em Elaboração" })
	AADD(aLegenda,{"BR_AZUL" ," - 03 Emitido"})
	AADD(aLegenda,{"BR_LARANJA"," - 04 Em Aprovação" })
	AADD(aLegenda,{"BR_VERDE"," - 05 Vigente" })
	AADD(aLegenda,{"BR_CINZA"," - 06 Paralisado" })
	AADD(aLegenda,{"BR_MARRON"," - 07 Sol. Finalização" })
	AADD(aLegenda,{"BR_PRETO"," - 08 Finalizado" })
	AADD(aLegenda,{"BR_PINK"," - 09 Revisão" })
	AADD(aLegenda,{"BR_VIOLETA"," - 'A' Revisão - Aprovação por alçadas" })
	AADD(aLegenda,{"BR_BRANCO"," - Revisado" })

	BrwLegenda(cCadastro, "Legenda", aLegenda)

Return Nil



User FUNCTION PBKGCTR11()

	ValidPerg()
	If !Pergunte(cPerg,.T.)
		Return Nil
	Endif

	cContrato   := mv_par01

	u_WaitLog(cPerg, {|oSay| ProcBKGCTR11(lJob)}, cContrato)

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

	u_WaitLog(cPerg, {|oSay| GeraXGCT11(cAlias,TRIM(cPerg),aTitulos,aCampos,aCabs,/*aImpr*/,/*aAlign*/,aFormat)}, titulo)

Return Nil



Static Function ProcBKGCTR11(lJob)
	Local cQuery	:= ""
	Local cQueryA	:= ""
	Local cQueryX	:= ""
	Local nAuxVl	:= 0
	Local _nI		:= 0
	Local aNDC		:= {}
	Local IX		:= 0
	Local _IX2		:= 0
	Local _IXFUR	:= 0
	Local XI_		:= 0
	Local _IX		:= 0
	Local i
	Local Yi_
	Local _nj
	Local cContraA	:= ""
	Local cAnoMes	:= ""
	Local nVarLog	:= 0
	Local cVarLog	:= 0
	Local dMaxCompet:= CTOD("")
	Local cJCNDCNE	:= FWJoinFilial("CND", "CNE")
	Local cJCXNCNE	:= FWJoinFilial("CXN", "CNE")
//Local cJCN1CN9	:= FWJoinFilial("CN1", "CN9")
//Local cJCNACN9  := FWJoinFilial("CNA", "CN9")
//Local cJSC5CNE	:= FWJoinFilial("SC5", "CNE")
//Local cJSC6SC5	:= FWJoinFilial("SC6", "SC5")
	Local cJSC6CNE	:= FWJoinFilial("SC6", "CNE")
	Local cJSD2SC6	:= FWJoinFilial("SD2", "SC6")
//Local cJSF2SC6	:= FWJoinFilial("SF2", "SC6")
//Local cJSB1SC6:= FWJoinFilial("SB1", "SC6")
	Local cRevAtu   := Space(GetSx3Cache("CN9_REVATU","X3_TAMANHO"))
	Local cCodEve   := ""
	Local cPCodEve  := ""

	LimpaBrw ("TRB")
	LimpaBrw (ALIAS_TMP)

	//ProcRegua(nPeriodo)
	FOR _nI := 1 TO nPeriodo

		//IncProc("Processando competência "+SUBSTR(aPeriodo[_nI,1],1,2)+"/"+SUBSTR(aPeriodo[_nI,1],4,4))

		//IncProc("Consultando faturamento dos contratos...")

		cAnoMes := aAnoMes[_nI]

		//*********Faturamento do Contrato

		cQuery := " SELECT"+CRLF
		cQuery += "   CNF_CONTRA" +CRLF
		cQuery += "   ,CNF_REVISA"+CRLF
		cQuery += "   ,A1_NOME"   +CRLF
		cQuery += "   ,CTT_DESC01"+CRLF
		cQuery += "   ,CN9_SITUAC"+CRLF
		cQuery += "   ,CNA_XXMUN" +CRLF
		cQuery += "   ,SUM(D2_TOTAL)  AS D2_TOTAL"   +CRLF
		cQuery += "   ,SUM(D2_VALISS) AS D2_VALISS"  +CRLF
		cQuery += "   ,SUM(D2_VALCPM) AS D2_VALCPM"  +CRLF
		cQuery += "   ,SUM(E1_XXISSBI) AS E1_XXISSBI"+CRLF
		cQuery += "   ,SUM(E5_VALOR)  AS E5DESC"     +CRLF

		// Nova Medição
		cQuery += " FROM "+RETSQLNAME("CNE")+" CNE"+CRLF

		cQuery += " INNER JOIN "+RETSQLNAME("CND")+" CND" + CRLF
		cQuery += " 	ON (CND_NUMMED = CNE_NUMMED AND CND_CONTRA = CNE_CONTRA AND CND_REVISA = CNE_REVISA" +CRLF
		cQuery += " 		AND "+cJCNDCNE+" AND CND.D_E_L_E_T_='')" + CRLF

		cQuery += " LEFT JOIN "+RETSQLNAME("CXN")+" CXN" + CRLF
		cQuery += " 	ON (CXN_CONTRA = CNE_CONTRA AND CXN_REVISA = CNE_REVISA AND CXN_NUMMED = CNE_NUMMED AND CXN_NUMPLA = CNE_NUMERO AND CXN.CXN_CHECK = 'T'" +CRLF
		cQuery += " 		AND "+cJCXNCNE+" AND CXN.D_E_L_E_T_='')" + CRLF

		cQuery += " INNER JOIN "+RETSQLNAME("CTT")+" CTT" + CRLF
		cQuery += " 	ON (CTT_CUSTO = CNE_CONTRA" + CRLF
		cQuery += " 		AND CTT_FILIAL = '"+xFilial("CTT")+"' AND CTT.D_E_L_E_T_='')" + CRLF

		cQuery += " INNER JOIN "+RETSQLNAME("CN9")+" CN9" + CRLF
		cQuery += " 	ON (CN9_FILCTR = CND_FILCTR AND CN9_NUMERO = CNE_CONTRA AND CN9_REVISA = CNE_REVISA" +CRLF
		cQuery += " 	 	AND CN9.D_E_L_E_T_='')" + CRLF
		//cQuery += " 	 	AND CN9_FILIAL = CND_FILCTR AND CN9.D_E_L_E_T_='')" + CRLF

		cQuery += " INNER JOIN "+RETSQLNAME("CNF")+" CNF" + CRLF
		cQuery += " 	ON (CNE_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CNE_NUMERO = CNF_NUMPLA AND CNE_REVISA = CNF_REVISA" +CRLF
		cQuery += " 	    AND CNF_PARCEL = ISNULL(CXN_PARCEL,CND_PARCEL)" + CRLF
		cQuery += " 	 	AND CNF_FILIAL = '01' AND CNF.D_E_L_E_T_='')" + CRLF

		//cQuery += " INNER JOIN "+RETSQLNAME("CN1")+" CN1" + CRLF
		//cQuery += " 	ON (CN1_CODIGO = CN9_TPCTO AND CN1_ESPCTR IN ('2')" + CRLF
		//cQuery += " 		AND "+cJCN1CN9+" AND CN1.D_E_L_E_T_='')" + CRLF

		cQuery += " INNER JOIN "+RETSQLNAME("CNA")+" CNA" + CRLF
		cQuery += " 	ON (CNA_CONTRA = CNE_CONTRA AND CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA AND CNA_NUMERO = CNF_NUMPLA" +CRLF
		cQuery += " 		AND CNA_FILIAL = '01' AND CNA.D_E_L_E_T_='')"+CRLF // CNE_CONTRA

		//cQuery += " INNER JOIN "+RETSQLNAME("CNA")+" CNA" + CRLF
		//cQuery += " 	ON (CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA" +CRLF
		//cQuery += " 		AND "+cJCNACNF+" AND CNA.D_E_L_E_T_='')"+CRLF

		//cQuery += " INNER JOIN "+RETSQLNAME("SC5")+" SC5" + CRLF
		//cQuery += " 	ON (C5_MDNUMED = CNE_NUMMED AND C5_MDPLANI = CNE_NUMERO" + CRLF
		//cQuery += " 		AND "+cJSC5CNE+" AND SC5.D_E_L_E_T_='')" + CRLF

		cQuery += " INNER JOIN "+RETSQLNAME("SC6")+" SC6" + CRLF
		//cQuery += " 	ON (C5_CLIENT = C6_CLI AND C5_LOJACLI = C6_LOJA AND C6_NUM = C5_NUM AND C6_ITEMED = CNE_ITEM" +CRLF
		//cQuery += " 		AND "+cJSC6SC5+" AND SC6.D_E_L_E_T_='')" + CRLF
		cQuery += " 	ON (C6_NUM = CNE_PEDIDO AND C6_ITEMED = CNE_ITEM" +CRLF
		cQuery += " 		AND "+cJSC6CNE+" AND SC6.D_E_L_E_T_='')" + CRLF

		cQuery += " INNER JOIN "+RETSQLNAME("SD2")+" SD2" + CRLF
		//cQuery += " 	ON (D2_PEDIDO = C5_NUM AND D2_ITEMPV = C6_ITEM AND C5_CLIENT = D2_CLIENTE AND D2_LOJA = C5_LOJACLI" +CRLF
		cQuery += " 	ON (D2_PEDIDO = C6_NUM AND D2_ITEMPV = C6_ITEM" +CRLF
		cQuery += " 		AND "+cJSD2SC6+" AND SD2.D_E_L_E_T_='')" + CRLF

		cQuery += " LEFT JOIN "+RETSQLNAME("SE5")+" SE5" + CRLF
		cQuery += " 	ON (E5_PREFIXO = D2_SERIE AND E5_NUMERO = D2_DOC  AND E5_TIPO = 'NF' AND  " + CRLF
		cQuery += " 	    E5_CLIFOR = D2_CLIENTE AND E5_LOJA = D2_LOJA AND E5_TIPODOC = 'DC' AND " + CRLF
		cQuery += " 	    E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' AND " + CRLF
		cQuery += "         E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = '') "+CRLF

		cQuery += " LEFT JOIN "+RETSQLNAME("SE1")+" SE1" + CRLF
		cQuery += " 	ON (E1_PREFIXO = D2_SERIE AND E1_NUM = D2_DOC  AND E1_TIPO = 'NF' AND  " + CRLF
		cQuery += "         E1_FILIAL = '"+xFilial("SE1")+"' AND SE1.D_E_L_E_T_ = '') "+CRLF

		cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1 "+CRLF
		cQuery += "     ON (CN9.CN9_XCLIEN = SA1.A1_COD "+CRLF
		cQuery += "         AND CN9.CN9_XLOJA = SA1.A1_LOJA  AND "+CRLF
		cQuery += "         SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = '')"+CRLF

		cQuery += " WHERE CNE.D_E_L_E_T_ = ' '"+ CRLF
		cQuery += "       AND CNE_FILIAL = '"+xFilial("CNE")+"'"+ CRLF //Removido para considerar todas as filiais
		cQuery += " 	  AND CN9.CN9_REVATU = '"+cRevAtu+"'"+ CRLF
		cQuery += "       AND CNF.CNF_COMPET='"+aPeriodo[_nI,1]+"' "+CRLF
		// Medição Antiga
	/*
	cQuery := " SELECT CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CNA_XXMUN,SUM(D2_TOTAL) AS D2_TOTAL,SUM(D2_VALISS) AS D2_VALISS,SUM(D2_VALCPM) AS D2_VALCPM, SUM(E5_VALOR) AS E5DESC"+CRLF
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

	cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON CN9.CN9_XCLIEN = SA1.A1_COD " +CRLF
    cQuery += "      AND CN9.CN9_XLOJA = SA1.A1_LOJA AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ''"+CRLF

	cQuery += " WHERE CNF.D_E_L_E_T_='' AND CNF.CNF_COMPET='"+aPeriodo[_nI,1]+"' "+CRLF   	//AND CN9.CN9_SITUAC ='"+cSituac+"'"
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
					cQueryX += " AND CN9_SITUAC <> '10' AND CN9.CN9_SITUAC <> '09'"+CRLF
				ENDIF
			ELSE
				cQueryX += " AND CNF_CONTRA ='"+ALLTRIM(cContrato)+"'"+CRLF
				//cQueryX += "AND CN9.CN9_SITUAC ='"+cSituac+"'"
				cQueryX += " AND CN9.CN9_SITUAC <> '10' AND CN9.CN9_SITUAC <> '09'"+CRLF
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
			IF !lJob
				IF !lFurnas
					cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391'"+CRLF
				ENDIF
			ELSE
				cQueryX += " AND SUBSTRING(CNF_CONTRA,1,3) <> '008' "+CRLF//IPT
				//cQueryX += " AND SUBSTRING(CNF_CONTRA,1,3) <> '049' "
				cQueryX += " AND SUBSTRING(CNF_CONTRA,1,3) <> '258' "+CRLF
				cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '247' "+CRLF
				cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391' "+CRLF //FURNAS
				cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '438' "+CRLF
				cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '425' "+CRLF
				cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '455' "+CRLF
				cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '467' "+CRLF
				cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '507' "+CRLF
				cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '510' "+CRLF
				cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '521' "+CRLF
				cQueryX += " AND CNF_CONTRA NOT IN ('193000288','194000289','195000290','196000291')"+CRLF
				cQueryX += " AND CNF_CONTRA NOT IN ('197000292','198000293','199000294')"+CRLF
				cQueryX += " AND CNF_CONTRA NOT IN ('197001292','198001293','199001294')"+CRLF
				IF SM0->M0_CODIGO <> "14"
					cQueryX += " AND CNF_CONTRA NOT IN ('302000508')"+CRLF
				ENDIF
			ENDIF

			//cQueryX += "AND CN9.CN9_SITUAC ='"+cSituac+"'" +CRLF
		ENDIF

		cQuery += cQueryX
		cQuery += " GROUP BY CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CNA_XXMUN"+CRLF


		// Juntar os cronogramas que não tiveram faturamento
		cQuery += " UNION ALL "+CRLF
		cQuery += "  SELECT DISTINCT"+CRLF
		cQuery += "   CNF_CONTRA" +CRLF
		cQuery += "   ,CNF_REVISA"+CRLF
		cQuery += "   ,A1_NOME"   +CRLF
		cQuery += "   ,CTT_DESC01"+CRLF
		cQuery += "   ,CN9_SITUAC"+CRLF
		cQuery += "   ,' ' AS CNA_XXMUN" +CRLF
		cQuery += "   ,0 AS D2_TOTAL"+CRLF
		cQuery += "   ,0 AS D2_VALISS"+CRLF
		cQuery += "   ,0 AS D2_VALCPM"+CRLF
		cQuery += "   ,0 AS E1_XXISSBI"+CRLF
		cQuery += "   ,0 AS E5DESC"+CRLF
		cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF

		cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA"+CRLF
		cQuery += "       AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"+CRLF

		cQuery += " INNER JOIN "+RETSQLNAME("CTT")+" CTT" + CRLF
		cQuery += " 	ON (CTT_CUSTO = CNF_CONTRA" + CRLF
		cQuery += " 		AND CTT_FILIAL = '"+xFilial("CTT")+"' AND CTT.D_E_L_E_T_='')" + CRLF

		//cQuery += " INNER JOIN "+RETSQLNAME("CNA")+" CNA" + CRLF
		//cQuery += " 	ON (CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA" +CRLF
		//cQuery += " 		AND "+cJCNACNF+" AND CNA.D_E_L_E_T_='')"+CRLF

		cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1 "+CRLF
		cQuery += "     ON (CN9.CN9_XCLIEN = SA1.A1_COD "+CRLF
		cQuery += "         AND CN9.CN9_XLOJA = SA1.A1_LOJA  AND "+CRLF
		cQuery += "         SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = '')"+CRLF

		cQuery += " WHERE CNF.D_E_L_E_T_=''"+CRLF
		cQuery += "       AND CNF.CNF_COMPET='"+aPeriodo[_nI,1]+"' "+CRLF
		cQuery += " 	  AND CN9.CN9_REVATU = '"+cRevAtu+"'"+ CRLF
		cQuery += cQueryX
		cQuery += " ORDER BY CNF_CONTRA"+CRLF

		u_LogMemo("BKGCTR11-CNF-1N-"+STRZERO(_nI,3)+"-"+cAnoMes+".SQL",cQuery)

		If Select("QTMP") > 0
			QTMP->(DbCloseArea())
		EndIf

		TCQUERY cQuery NEW ALIAS "QTMP"

		dbSelectArea("QTMP")
		QTMP->(dbGoTop())

		If QTMP->(EOF())
			//Não tem cronograma neste mes

			QTMP->(dbCloseArea())
			cQueryA := " SELECT TOP 1 CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,' ' AS CNA_XXMUN,0 AS D2_TOTAL,0 AS D2_VALISS,0 AS D2_VALCPM,0 AS E1_XXISSBI,0 AS E5DESC"+CRLF
			cQueryA += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF
			cQueryA += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9.CN9_NUMERO = CNF.CNF_CONTRA AND CN9.CN9_REVISA = CNF.CNF_REVISA"+CRLF
			cQueryA += "      AND CN9.CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"+CRLF
			cQueryA += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+CRLF
			cQueryA += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ''"+CRLF
			cQueryA += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON CN9.CN9_XCLIEN = SA1.A1_COD " +CRLF
			cQueryA += "      AND CN9.CN9_XLOJA = SA1.A1_LOJA AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ''"+CRLF

			cQueryA += " WHERE CNF.D_E_L_E_T_='' "+CRLF
			cQueryA += cQueryX

			u_LogMemo("BKGCTR11-CNF-A-"+STRZERO(_nI,3)+"-"+cAnoMes+".SQL",cQueryA)

			TCQUERY cQueryA NEW ALIAS "QTMP"
			dbSelectArea("QTMP")
			QTMP->(dbGoTop())

		EndIf

		aNDC := {}
		DO WHILE QTMP->(!EOF())

			nScan:= 0
			nScan:= aScan(aContConsol,{|x| x[1] =ALLTRIM(QTMP->CNF_CONTRA)})
			IF nScan == 0
				AADD(aContConsol,{ALLTRIM(QTMP->CNF_CONTRA),QTMP->A1_NOME,QTMP->CTT_DESC01})
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
			AADD(aRentab,{"02","NUMERO-SIGA: ","S",ALLTRIM(QTMP->CNF_CONTRA)})
			AADD(aRentab,{"03","FATURAMENTO OFICIAL","S",IIF(nIndTC>0,QTMP->D2_TOTAL/(nIndTC/100),QTMP->D2_TOTAL)})
			AADD(aRentab,{"03-2","","S",0})
			AADD(aRentab,{"04","(-) Impostos e Contribuições","S",IIF(nIndTC>0,((QTMP->D2_TOTAL*nMImpContr)/100)/(nIndTC/100),(QTMP->D2_TOTAL*nMImpContr)/100)})
			IF lISSFURNAS
				AADD(aRentab,{"05","(-) ISS","S",nISSFURNAS})
			ELSE
				AADD(aRentab,{"05","(-) ISS","S",IIF(nIndTC>0,QTMP->D2_VALISS/(nIndTC/100),QTMP->D2_VALISS)})
			ENDIF
			AADD(aRentab,{"05-1","(-) ISS Bitributado","S",IIF(nIndTC>0,QTMP->D2_VALCPM/(nIndTC/100),QTMP->D2_VALCPM)})
			AADD(aRentab,{"05-2","(-) ISS Bitributado Indev.","S",IIF(nIndTC>0,QTMP->E1_XXISSBI/(nIndTC/100),QTMP->E1_XXISSBI)})
			IF lISSFURNAS
				AADD(aRentab,{"06","Total dos Impostos + ISS","S",((QTMP->D2_TOTAL*nMImpContr)/100)+nISSFURNAS+QTMP->D2_VALCPM+QTMP->E1_XXISSBI})
			ELSE
				AADD(aRentab,{"06","Total dos Impostos + ISS","S",IIF(nIndTC>0,(((QTMP->D2_TOTAL*nMImpContr)/100)+QTMP->D2_VALISS+QTMP->D2_VALCPM+QTMP->E1_XXISSBI)/(nIndTC/100),((QTMP->D2_TOTAL*nMImpContr)/100)+QTMP->D2_VALISS+QTMP->D2_VALCPM+QTMP->E1_XXISSBI)})
			ENDIF
			AADD(aRentab,{"06-1","","S",0})
			IF lISSFURNAS
				AADD(aRentab,{"07","FATURAMENTO LÍQUIDO","S",IIF(nIndTC>0,(QTMP->D2_TOTAL-(((QTMP->D2_TOTAL*nMImpContr)/100)+nISSFURNAS+QTMP->D2_VALCPM+QTMP->E1_XXISSBI))/(nIndTC/100),QTMP->D2_TOTAL-(((QTMP->D2_TOTAL*nMImpContr)/100)+nISSFURNAS+QTMP->D2_VALCPM+QTMP->E1_XXISSBI))})
			ELSE
				AADD(aRentab,{"07","FATURAMENTO LÍQUIDO","S",IIF(nIndTC>0,(QTMP->D2_TOTAL-(((QTMP->D2_TOTAL*nMImpContr)/100)+QTMP->D2_VALISS+QTMP->D2_VALCPM+QTMP->E1_XXISSBI))/(nIndTC/100),QTMP->D2_TOTAL-(((QTMP->D2_TOTAL*nMImpContr)/100)+QTMP->D2_VALISS+QTMP->D2_VALCPM+QTMP->E1_XXISSBI))})
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

			nNDC := 0
			nNDC := U_VALNDCE(ALLTRIM(QTMP->CNF_CONTRA),aPeriodo[_nI,1],_nI,@aNDC)
			aAdd(aRentab,{"30-3","NDC","S",-nNDC})

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
				IF "|"+aRentab[_nJ,1]+"|" $ "|03|03-1|04|05|05-1|05-2|06|07|30-2|30-3|"
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += aRentab[_nJ,4]
				ENDIF
				//(ALIAS_TMP)->XX_STATUS := QTMP->CN9_SITUAC
				(ALIAS_TMP)->(Msunlock())
			NEXT

			dbSelectArea("QTMP")
			QTMP->(dbSkip())
		ENDDO


/* ===================================================================

    QTMP->(dbCloseArea())
    

	//*********Contrato
	cQuery := " SELECT"+CRLF 
	cQuery += "   CNF_CONTRA" +CRLF
	cQuery += "   ,CNF_REVISA"+CRLF
	cQuery += "   ,A1_NOME"   +CRLF
	cQuery += "   ,CTT_DESC01"+CRLF
	cQuery += "   ,CN9_SITUAC"+CRLF
	cQuery += "   ,SUM(D2_TOTAL)  AS D2_TOTAL"+CRLF
	cQuery += "   ,SUM(D2_VALISS) AS D2_VALISS"+CRLF
	cQuery += "   ,SUM(D2_VALCPM) AS D2_VALCPM"+CRLF
	cQuery += "   ,SUM(E5_VALOR)  AS E5DESC"+CRLF

	// Nova Medição
	cQuery += " FROM "+RETSQLNAME("CNE")+" CNE"+CRLF

	cQuery += " INNER JOIN "+RETSQLNAME("CND")+" CND" + CRLF
	cQuery += " 	ON (CND_NUMMED = CNE_NUMMED AND CND_CONTRA = CNE_CONTRA AND CND_REVISA = CNE_REVISA" +CRLF
	cQuery += " 		AND "+cJCNDCNE+" AND CND.D_E_L_E_T_='')" + CRLF

	cQuery += " LEFT JOIN "+RETSQLNAME("CXN")+" CXN" + CRLF
	cQuery += " 	ON (CXN_CONTRA = CNE_CONTRA AND CXN_REVISA = CNE_REVISA AND CXN_NUMMED = CNE_NUMMED AND CXN_NUMPLA = CNE_NUMERO AND CXN.CXN_CHECK = 'T'" +CRLF
	cQuery += " 		AND "+cJCXNCNE+" AND CXN.D_E_L_E_T_='')" + CRLF

	cQuery += " INNER JOIN "+RETSQLNAME("CTT")+" CTT" + CRLF
	cQuery += " 	ON (CTT_CUSTO = CNE_CONTRA" + CRLF
	cQuery += " 		AND CTT_FILIAL = "+xFilial("CTT")+" AND CTT.D_E_L_E_T_='')" + CRLF

	cQuery += " INNER JOIN "+RETSQLNAME("CN9")+" CN9" + CRLF
	cQuery += " 	ON (CN9_FILCTR = CND_FILCTR AND CN9_NUMERO = CNE_CONTRA AND CN9_REVISA = CNE_REVISA" +CRLF
	cQuery += " 	 	AND CN9.D_E_L_E_T_='')" + CRLF

	cQuery += " INNER JOIN "+RETSQLNAME("CNF")+" CNF" + CRLF
	cQuery += " 	ON (CNE_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CNE_NUMERO = CNF_NUMPLA AND CNE_REVISA = CNF_REVISA" +CRLF
	cQuery += " 	    AND CNF_PARCEL = ISNULL(CXN_PARCEL,CND_PARCEL)" + CRLF
	cQuery += " 	 	AND CNF.D_E_L_E_T_='')" + CRLF

	cQuery += " INNER JOIN "+RETSQLNAME("CN1")+" CN1" + CRLF
	cQuery += " 	ON (CN1_CODIGO = CN9_TPCTO AND CN1_ESPCTR IN ('2')" + CRLF
	cQuery += " 		AND "+cJCN1CN9+" AND CN1.D_E_L_E_T_='')" + CRLF

	// Não há necessidade do CNA
	//cQuery += " INNER JOIN "+RETSQLNAME("CNA")+" CNA" + CRLF
	//cQuery += " 	ON (CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA" +CRLF
	//cQuery += " 		AND "+cJCNACN9+" AND CNA.D_E_L_E_T_='')"+CRLF

	cQuery += " INNER JOIN "+RETSQLNAME("SC5")+" SC5" + CRLF
	cQuery += " 	ON (C5_MDNUMED = CNE_NUMMED AND C5_MDPLANI = CNE_NUMERO" + CRLF
	cQuery += " 		AND "+cJSC5CNE+" AND SC5.D_E_L_E_T_='')" + CRLF

	cQuery += " INNER JOIN "+RETSQLNAME("SC6")+" SC6" + CRLF
	cQuery += " 	ON (C5_CLIENT = C6_CLI AND C5_LOJACLI = C6_LOJA AND C6_NUM = C5_NUM AND C6_ITEMED = CNE_ITEM" +CRLF
	cQuery += " 		AND "+cJSC6SC5+" AND SC6.D_E_L_E_T_='')" + CRLF

	cQuery += " INNER JOIN "+RETSQLNAME("SD2")+" SD2" + CRLF
	cQuery += " 	ON (D2_PEDIDO = C5_NUM AND D2_ITEMPV = C6_ITEM AND C5_CLIENT = D2_CLIENTE AND D2_LOJA = C5_LOJACLI" +CRLF
	cQuery += " 		AND "+cJSD2SC6+" AND SD2.D_E_L_E_T_='')" + CRLF

	cQuery += " LEFT JOIN "+RETSQLNAME("SE5")+" SE5" + CRLF
	cQuery += " 	ON (E5_PREFIXO = D2_SERIE AND E5_NUMERO = D2_DOC  AND E5_TIPO = 'NF' AND  " + CRLF
	cQuery += " 	    E5_CLIFOR = D2_CLIENTE AND E5_LOJA = D2_LOJA AND E5_TIPODOC = 'DC' AND " + CRLF
	cQuery += " 	    E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND " + CRLF
	cQuery += "         E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = '') "+CRLF

    cQuery += " INNER JOIN "+RETSQLNAME("SA1")+" SA1 "+CRLF 
	cQuery += "     ON (CN9.CN9_XCLIEN = SA1.A1_COD "+CRLF 
    cQuery += "         AND CN9.CN9_XLOJA = SA1.A1_LOJA  AND "+CRLF 
	cQuery += "         SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = '')"+CRLF

	cQuery += " WHERE CNE_FILIAL = '"+xFilial("CNE")+"' AND CNE.D_E_L_E_T_ = ' '"+ CRLF
	cQuery += "      AND CNF.CNF_COMPET='"+aPeriodo[_nI,1]+"' "+CRLF   	//AND CN9.CN9_SITUAC ='"+cSituac+"'"

	//cQuery += " 	AND CN9.CN9_REVATU = '"+cRevAtu+"'"+ CRLF

=========================================================*/

	// Medição Antiga
	/*
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
	cQuery += " LEFT JOIN "+RETSQLNAME("SE5")+" SE5 ON E5_PREFIXO = D2_SERIE AND E5_NUMERO = D2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = D2_CLIENTE AND E5_LOJA = D2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' "+CRLF //--AND E5_PARCELA = '  '
	cQuery += "      AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = '' "+CRLF

    cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON CN9.CN9_XCLIEN = SA1.A1_COD "+CRLF 
    cQuery += "      AND CN9.CN9_XLOJA = SA1.A1_LOJA  AND  SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ''"+CRLF

	cQuery += " WHERE CNF.D_E_L_E_T_='' "
	*/


/*====================================================================================
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
//			cQueryX += "AND CN9.CN9_SITUAC ='"+cSituac+"'"
			cQueryX += " AND CN9.CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
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
		IF !lJob
			IF !lFurnas
				cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391'"+CRLF
			ENDIF
		ELSE
	    	cQueryX += " AND SUBSTRING(CNF_CONTRA,1,3) <> '008' "+CRLF //IPT 
	    	//cQueryX += " AND SUBSTRING(CNF_CONTRA,1,3) <> '049' " //fundacao florestal
	    	cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '247' "+CRLF //IPT 
	    	cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391' "+CRLF //FURNAS
	    	cQueryX += " AND SUBSTRING(CNF_CONTRA,1,3) <> '008' " //IPT 
	    	cQueryX += " AND SUBSTRING(CNF_CONTRA,1,3) <> '258' "+CRLF
	    	cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391' "+CRLF //FURNAS
	    	cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '438' "+CRLF  
	    	cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '425' "+CRLF
	    	cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '455' "+CRLF
	    	cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '467' "+CRLF
	    	cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '507' "+CRLF
	   		cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '510' "+CRLF
	    	cQueryX += " AND SUBSTRING(CNF_CONTRA,7,3) <> '521' "+CRLF
	    	cQueryX += " AND CNF_CONTRA NOT IN ('193000288','194000289','195000290','196000291')"  +CRLF
	    	cQueryX += " AND CNF_CONTRA NOT IN ('197000292','198000293','199000294')"  +CRLF
	    	cQueryX += " AND CNF_CONTRA NOT IN ('197001292','198001293','199001294')" +CRLF
	    	IF SM0->M0_CODIGO <> "14"  
	    		cQueryX += " AND CNF_CONTRA NOT IN ('302000508')"+CRLF
			ENDIF  

		ENDIF

		cQueryX += "AND CN9.CN9_SITUAC ='"+cSituac+"'" +CRLF
    ENDIF	

	cQuery += cQueryX
	cQuery += " GROUP BY CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC"
	cQuery += " ORDER BY CNF_CONTRA"+CRLF

 	u_LogMemo("BKGCTR11-CNF-2N-"+STRZERO(_nI,3)+".SQL",cQuery)

	TCQUERY cQuery NEW ALIAS "QTMP"


	dbSelectArea("QTMP")
	QTMP->(dbGoTop())

	If QTMP->(EOF())
		//Não tem cronograma neste mes

	    QTMP->(dbCloseArea())
		cQueryA := " SELECT TOP 1 CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,0 AS D2_TOTAL,0 AS D2_VALISS,0 AS D2_VALCPM, 0 AS E5DESC"+CRLF
		cQueryA += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF
		cQueryA += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9.CN9_NUMERO = CNF.CNF_CONTRA AND CN9.CN9_REVISA = CNF.CNF_REVISA"+CRLF
		cQueryA += "      AND CN9.CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"+CRLF
		cQueryA += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+CRLF
		cQueryA += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ''"+CRLF
		cQueryA += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON CN9.CN9_XCLIEN = SA1.A1_COD " +CRLF
		cQueryA += "      AND CN9.CN9_XLOJA = SA1.A1_LOJA AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ''"+CRLF

		cQueryA += " WHERE CNF.D_E_L_E_T_='' "+CRLF 
		cQueryA += cQueryX

		u_LogMemo("BKGCTR11-CNF-B-"+STRZERO(_nI,3)+".SQL",cQueryA)

		TCQUERY cQueryA NEW ALIAS "QTMP"
		dbSelectArea("QTMP")
		QTMP->(dbGoTop())
	EndIf

========================================================================*/


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

		//Calcula LF Avulso SZ2 - CLT
		cQuery1 := "SELECT Z2_CODEMP,Z2_CC,Z2_VALOR,Z2_TIPO,Z2_CC FROM "+RETSQLNAME("SZ2")+" SZ2"+CRLF
		cQuery1 += " WHERE  D_E_L_E_T_='' AND Z2_TIPO IN ('EXM','VT','VR','VA','DCH','SOL','HOS','REE','CXA')"+CRLF  //REMOVIDO MULTA FGTS POR ENTENDER QUE ESTA EM INCIDENCIAS - TIPO = MFG
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

		u_LogMemo("BKGCTR11-SZ2-"+cVarLog+".SQL",cQuery1)

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

			ELSEIF ALLTRIM(TMPX2->Z2_TIPO)  $ 'VR/VA'

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

			ELSEIF ALLTRIM(TMPX2->Z2_TIPO)  == 'EXM'

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
			/*
			ELSEIF ALLTRIM(TMPX2->Z2_TIPO)  == 'MFG'

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
			*/
	ELSEIF ALLTRIM(TMPX2->Z2_TIPO)  == 'DCH'

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

	ELSEIF ALLTRIM(TMPX2->Z2_TIPO) $ 'SOL/HOS/REE/CXA' // Despesas de Viagens 04/04/2022

		dbSelectArea(ALIAS_TMP)
		IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+cDViagens,.F.)
			Reclock(ALIAS_TMP,.F.)
		ELSE
			Reclock(ALIAS_TMP,.T.)
			(ALIAS_TMP)->XX_CODGCT := IIF(nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
			(ALIAS_TMP)->XX_CODIGO := "W"+cDViagens
			(ALIAS_TMP)->XX_DESC   := Posicione("SB1",1,xFilial("SB1")+cDViagens,"B1_DESC")
			// Debug
			If EMPTY((ALIAS_TMP)->XX_DESC)
				(ALIAS_TMP)->XX_DESC := "3 - Produto "+cDViagens
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
	IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+"W"+cCusBK,.F.)
		Reclock(ALIAS_TMP,.F.)
	ELSE
		Reclock(ALIAS_TMP,.T.)
		(ALIAS_TMP)->XX_CODGCT := IIF( nConsol > 0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
		(ALIAS_TMP)->XX_CODIGO := "W"+cCusBK
		(ALIAS_TMP)->XX_DESC   := Posicione("SB1",1,xFilial("SB1")+cCusBK,"B1_DESC")
		// Debug
		If EMPTY((ALIAS_TMP)->XX_DESC)
			(ALIAS_TMP)->XX_DESC := "4 - Produto "+cCusBK
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
		nIncidenci	:= 0
		_IXFUR := LEN(aFurnas)
	ELSE
		nIncidenci	:= U_MVXINCID()
	ENDIF
NEXT _IXFUR


//IncProc("Consultando Folha Pagamento...")
//*********Folha Pagamento
cQuery2 := "SELECT bk_senior.bk_senior.R046VER.CodEve AS CodEve,bk_senior.bk_senior.R008EVC.DesEve,COUNT(bk_senior.bk_senior.R046VER.CodEve) AS nCont,SUM(bk_senior.bk_senior.R046VER.ValEve) as valevent,"+CRLF
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
	cQuery2 += " Where bk_senior.bk_senior.R046VER.NumEmp='"+cEmpAnt+"' and Tipcal In(11) And Sitcal = 'T' "+CRLF
	cQuery2 += " AND PerRef ='"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"01'"+CRLF
	If cEmpAnt <> '14'
		cQuery2 += " AND BKIntegraRubi.dbo.CUSTOSIGA.ccSiga = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'"+CRLF
	EndIf
ENDIF

cQuery2 += " GROUP BY bk_senior.bk_senior.R046VER.CodEve,bk_senior.bk_senior.R008EVC.DesEve"+CRLF
cQuery2 += " ORDER BY bk_senior.bk_senior.R046VER.CodEve,bk_senior.bk_senior.R008EVC.DesEve"+CRLF

u_LogMemo("BKGCTR11-FOL-"+cVarLog+".SQL",cQuery2)

TCQUERY cQuery2 NEW ALIAS "TMPX2"
TCSETFIELD("TMPX2","CodEve","N",5,0)

nProventos := 0
nCusto     := 0
nXXPLR	   := 0
dbSelectArea("TMPX2")
dbGoTop()


//If SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2) = '202205'
//	x:= 0
//EndIf
DO While !TMPX2->(EOF())

	cCtrCons := IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))
	cCodEve  := ALLTRIM(STR(TMPX2->CodEve))
	cPCodEve := "|"+cCodEve+"|"
	lFolha   := .F.
	//If cCodEve == '2' .or. cCodEve == '270'
	//	x:=0 
	//EndIf
	IF cPCodEve $ cProventos
		nProventos += TMPX2->valevent
		UpdTmpFol(lJob,cContrato,cCodEve,TMPX2->DesEve,"01-Proventos",TMPX2->valevent,_nI)
		lFolha   := .T.
	ENDIF
	IF cPCodEve $ cDescontos
		nProventos -= TMPX2->valevent
		UpdTmpFol(lJob,cContrato,cCodEve,TMPX2->DesEve,"02-Descontos",-TMPX2->valevent,_nI)
		lFolha   := .T.
	ENDIF
	IF cPCodEve $ cXXPLR
		nXXPLR += TMPX2->valevent
		UpdTmpFol(lJob,cContrato,cCodEve,TMPX2->DesEve,"04-PLR",TMPX2->valevent,_nI)
		lFolha   := .T.
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
		UpdTmpFol(lJob,cContrato,cCodEve,TMPX2->DesEve,"12-VT Prov",TMPX2->valevent,_nI)
		lFolha   := .T.
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
		UpdTmpFol(lJob,cContrato,cCodEve,TMPX2->DesEve,"13-VT Verba",-TMPX2->valevent,_nI)
		lFolha   := .T.
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
		UpdTmpFol(lJob,cContrato,cCodEve,TMPX2->DesEve,"15-VRVA Verba",-TMPX2->valevent,_nI)
		lFolha   := .T.
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
		UpdTmpFol(lJob,cContrato,cCodEve,TMPX2->DesEve,"16-Ass Med Prod",TMPX2->valevent,_nI)
		lFolha   := .T.
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
		UpdTmpFol(lJob,cContrato,cCodEve,TMPX2->DesEve,"17-Ass Med Verba",-TMPX2->valevent,_nI)
		lFolha   := .T.
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
		UpdTmpFol(lJob,cContrato,cCodEve,TMPX2->DesEve,"18-Sind Odonto",TMPX2->valevent,_nI)
		lFolha   := .T.
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
		UpdTmpFol(lJob,cContrato,cCodEve,TMPX2->DesEve,"19-Sind Odonto Verba",-TMPX2->valevent,_nI)
		lFolha   := .T.
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
		UpdTmpFol(lJob,cContrato,cCodEve,TMPX2->DesEve,"21-CCRE",-TMPX2->valevent,_nI)
		lFolha   := .T.
	ENDIF

	IF cPCodEve $ cNINC_Verb
		dbSelectArea(ALIAS_TMP)
		IF MsSeek(cCtrCons+'111',.F.)
			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			&cCampo2 += (TMPX2->valevent)
			(ALIAS_TMP)->(Msunlock())
			nCusto += (TMPX2->valevent)
		ENDIF
		UpdTmpFol(lJob,cContrato,cCodEve,TMPX2->DesEve,"03-Sem Encargos/Incidencias",TMPX2->valevent,_nI)
		lFolha   := .T.
	ENDIF
	If !lFolha
		UpdTmpFol(lJob,cContrato,cCodEve,TMPX2->DesEve,"XX-Evento Não considerado",TMPX2->valevent,_nI)
	Endif
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
// Aqui - dashboard
FOR _IXFUR:= 1 TO LEN(aFurnas)
	IF SUBSTR(ALLTRIM(QTMP->CNF_CONTRA),7,3) == SUBSTR(aFURNAS[_IXFUR],7,3)
		nEncargos := U_MVXENCFU()
		_IXFUR	  := LEN(aFurnas)
	ELSE
		nEncargos := U_MVXENCAP()
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
	&cCampo2 += (nProventos*nIncidenci)/100
	(ALIAS_TMP)->(Msunlock())
	nCusto += (nProventos*nIncidenci)/100
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


//IncProc("Consultando Folha Pagamento - Autonomos...")
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
cQuery3 := " SELECT MIN(CNF_DTVENC) AS CNF_INICIO,MAX(CNF_DTVENC) AS CNF_FIM,"
cQuery3 += " MAX((SUBSTRING(CNF_COMPET,4,4))+SUBSTRING(CNF_COMPET,1,2))+'01' AS MAXCOMPET"+CRLF
cQuery3 += " FROM "+RETSQLNAME("CNF")+" CNF"
cQuery3 += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA"
cQuery3 += " AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = '' WHERE CNF.D_E_L_E_T_=''"
cQuery3 += " AND CN9_NUMERO = '"+ALLTRIM(QTMP->CNF_CONTRA)+"' AND CN9_SITUAC='"+ALLTRIM(QTMP->CN9_SITUAC)+"'" // ='"+cSituac+"'"

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

QTMPX3->(Dbclosearea())

nScan:= 0
nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })

//IncProc("Consultando gastos gerais: "+SUBSTR(aPeriodo[_nI,1],1,2)+"/"+SUBSTR(aPeriodo[_nI,1],4,4))

//*********GASTOS GERAIS
cQuery2 := "SELECT D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC,SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) AS D1_TOTAL"+CRLF
cQuery2 += " FROM "+RETSQLNAME("SD1")+" SD1" +CRLF
cQuery2 += " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D1_COD = B1_COD  AND SB1.D_E_L_E_T_ = '' " +CRLF
cQuery2 += " WHERE SUBSTRING(D1_DTDIGIT,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"' AND SD1.D_E_L_E_T_ = '' "+CRLF
cQuery2 += " AND D1_CC = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'"+CRLF
cQuery2 += " AND D1_FILIAL = '"+xFilial("SD1")+"'"+CRLF
IF SM0->M0_CODIGO == "01"  .AND. ALLTRIM(QTMP->CNF_CONTRA)=="313000504" // Despesas médicas
	cQuery2 += " AND D1_FORNECE<>'002918'"+CRLF
ENDIF
IF SM0->M0_CODIGO == "14"  // Despesas médicas
	cQuery2 += " AND D1_FORNECE<>'000604'"+CRLF
ENDIF

// 12105 - Alugueis 06/07/2021
// 19/11/2021 - Contas alteradas de 113 para 121
If nScan > 0
	cQuery2 +=  " AND SUBSTRING(B1_CONTA,1,3) <> '113' " +CRLF
	cQuery2 +=  " AND (SUBSTRING(B1_CONTA,1,3) <> '121' OR SUBSTRING(B1_CONTA,1,5) IN ('12201','12105'))" +CRLF
Else
	cQuery2 += " AND (SUBSTRING(B1_CONTA,1,1) = '3' OR B1_CONTA IN ('"+cCusBK+"') OR SUBSTRING(B1_CONTA,1,5) IN ('12201','12105'))" +CRLF
EndIf
cQuery2 += " GROUP BY D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC"+CRLF

cQuery2 += " UNION ALL"+CRLF
cQuery2 += " SELECT D3_FILIAL,MAX(' '),MAX(' '),MAX(' '),MAX(' '),D3_COD,B1_DESC,B1_GRUPO,D3_CC,SUM(D3_CUSTO1) FROM "+RETSQLNAME("SD3")+" SD3"+CRLF
cQuery2 += " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D3_COD = B1_COD  AND SB1.D_E_L_E_T_ = '' "+CRLF
cQuery2 += " WHERE SD3.D_E_L_E_T_='' AND D3_TM='5"+cEmpAnt+"' AND SUBSTRING(D3_EMISSAO,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'"+CRLF
cQuery2 += " AND D3_CC = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'"+CRLF

// 19/11/2021 - Contas alteradas de 113 para 121
//cQuery2 += IIF(nScan > 0," AND SUBSTRING(D3_CONTA,1,3) <> '113' "," AND (SUBSTRING(D3_CONTA,1,1) = '3' OR D3_CONTA in ('29104004') OR SUBSTRING(D3_CONTA,1,5) IN ('12201','12105'))") +CRLF
If nScan > 0
	cQuery2 +=  " AND SUBSTRING(D3_CONTA,1,3) <> '113' " +CRLF
	cQuery2 +=  " AND (SUBSTRING(D3_CONTA,1,3) <> '121' OR SUBSTRING(D3_CONTA,1,5) IN ('12201','12105'))" +CRLF
Else
	cQuery2 += " AND (SUBSTRING(D3_CONTA,1,1) = '3' OR D3_CONTA IN ('"+cCusBK+"') OR SUBSTRING(D3_CONTA,1,5) IN ('12201','12105'))" +CRLF
EndIf

cQuery2 += " GROUP BY  D3_FILIAL,D3_COD,B1_DESC,B1_GRUPO,D3_CC"+CRLF

//cQuery2 += " ORDER BY B1_DESC"+CRLF

u_LogMemo("BKGCTR11-D1-1-"+cVarLog+".SQL",cQuery2)

TCQUERY cQuery2 NEW ALIAS "TMPX2"
cOUTROS := 'S'

dbSelectArea("TMPX2")
dbGoTop()

cLastE2 := "-"
aAcrDcr := {}

DO While !TMPX2->(EOF())

	//IF TMPX2->D1_DOC = '000050737' //'000053049'
	//	XBK:= 0
	//ENDIF

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

		cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'12',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,"N",.T.,"",.F.,nIndDesp)

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


		cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'08',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)

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


		cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'14',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,"N",.T.,"",.F.,nIndDesp)

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

		cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'08',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)

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


		cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'20',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,"N",.T.,"",.F.,nIndDesp)
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

		cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'08',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)
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

			cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'30',XI_,nValRat,aAcrDcr,cOutros,cOutros,lPRat,"",.T.,nIndDesp)

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

			cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,"W"+cCodCC,XI_,nValRat,aAcrDcr,cOutros,cOutros,lPRat,cCodCC,.T.,nIndDesp)

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

		cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,"W"+TMPX2->D1_COD,_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,TMPX2->B1_DESC,.F.,nIndDesp)

	   			/*
				   dbSelectArea(ALIAS_TMP)
	   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(TMPX2->D1_CC))+'30',.F.)
	     			Reclock(ALIAS_TMP,.F.)
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += TMPX2->D1_TOTAL
					(ALIAS_TMP)->(Msunlock())
				ENDIF
				*/

		cOutros := GravaCCD1(ALIAS_TMP,nConsol,TMPX2->D1_CC,'30',_nI,TMPX2->D1_TOTAL,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)


	ENDIF

	dbSelectArea("TMPX2")
	dbSkip()
ENDDO
TMPX2->(dbCloseArea())


//*********GASTOS GERAIS - TRATAMENTO ESPECIAL CONSORCIOS
nScan:= 0
nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })

IF nScan > 0

	//IncProc("Consultando gastos gerais consorcios: "+SUBSTR(aPeriodo[_nI,1],1,2)+"/"+SUBSTR(aPeriodo[_nI,1],4,4))

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
	ELSEIF ALLTRIM(aConsorcio[nScan,2]) == "150"
		//cQuery2 += " AND D1_CC BETWEEN '000000000' AND '999999999'" +CRLF
	ELSE
		cQuery2 += " AND D1_CC IN ('"+ALLTRIM(aConsorcio[nScan,3])+"','"+ALLTRIM(aConsorcio[nScan,4])+"','"+ALLTRIM(aConsorcio[nScan,7])+"')"+CRLF
	ENDIF

	cQuery2 += " AND SUBSTRING(B1_CONTA,1,1) <> '2' AND SUBSTRING(B1_CONTA,1,3) <> '113' " +CRLF
	// 19/11/2021 - Contas alteradas de 113 para 121
	cQuery2 += " AND (SUBSTRING(B1_CONTA,1,3) <> '121' OR SUBSTRING(B1_CONTA,1,5) IN ('12201','12105'))" +CRLF

	cQuery2 += " AND D1_FILIAL = '"+xFilial("SD1")+"'"+CRLF
	//cQuery2 += " GROUP BY  D1_FILIAL,D1_COD,B1_DESC,B1_GRUPO,D1_CC"+CRLF
	cQuery2 += " GROUP BY D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC"+CRLF
	//cQuery2 += " ORDER BY B1_DESC"+CRLF

	u_LogMemo("BKGCTR11-D1-2-"+cVarLog+".SQL",cQuery2)

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
		nIndDesp:= IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),VAL(aConsorcio[nScan,5]),1)
		nAuxVl  := TMPX2->D1_TOTAL/nIndDesp

		IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cVT_Prod


			//If TMPX2->D1_DOC == '000051817'
			//	xbk := 0
			//EndIf

			cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'12',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"",.F.,nIndDesp)

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

			cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)

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

			cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'14',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"",.F.,nIndDesp)

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

			cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)
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


			cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'20',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"",.F.,nIndDesp)

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

			cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)
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
			lPRat := .T.

			FOR XI_ := _nI TO nParcela

				dbSelectArea(ALIAS_TMP)
				//nAuxVl := IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)

				nIndDesp:= IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),VAL(aConsorcio[nScan,5]),1)
				nAuxVl  := nValRat/nIndDesp

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

				cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,"",.T.,nIndDesp)

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

				cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+cCodCC,XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,cCodCC,.T.,nIndDesp)

				lPRat   := .F.
			NEXT
		ENDIF

		IF cOutros == 'S'
			dbSelectArea(ALIAS_TMP)

			//nAuxVl := IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)

			nIndDesp:= IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),VAL(aConsorcio[nScan,5]),1)
			nAuxVl  := TMPX2->D1_TOTAL/nIndDesp

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

			cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+TMPX2->D1_COD,_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,TMPX2->B1_DESC,.F.,nIndDesp)


		   			/*
					dbSelectArea(ALIAS_TMP)
		   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
		     			Reclock(ALIAS_TMP,.F.)
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
						&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL /VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL )
						(ALIAS_TMP)->(Msunlock())
					ENDIF
					*/

			cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)

		ENDIF

		dbSelectArea("TMPX2")
		dbSkip()
	ENDDO
	TMPX2->(dbCloseArea())

	//IncProc("Consultando movimento bancário ..."+STRZERO(_nI,3))

	cQuery2 := "SELECT E5_CREDITO,E5_DEBITO,CT1_DESC01,E5_VALOR,E5_RECPAG,E5_CCC,E5_CCD,E5_VENCTO"+CRLF
	cQuery2 += " FROM SE5"+ALLTRIM(aConsorcio[nScan,2])+" SE5" +CRLF
	cQuery2 += " LEFT JOIN CT1"+ALLTRIM(aConsorcio[nScan,2])+" CT1 ON CT1_FILIAL = '"+xFilial("CT1")+"' AND (CT1_CONTA=E5_DEBITO OR CT1_CONTA=E5_CREDITO) AND CT1.D_E_L_E_T_=''"+CRLF
	cQuery2 += " WHERE SE5.D_E_L_E_T_='' AND (SUBSTRING(E5_DEBITO,1,1)='3' OR SUBSTRING(E5_CREDITO,1,1)='3' )  AND E5_SITUACA<>'C'"+CRLF
	cQuery2 += " AND SUBSTRING(E5_VENCTO,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"'"+CRLF
	cQuery2 += " AND E5_FILIAL = '"+xFilial("SE5")+"'"+CRLF

	u_LogMemo("BKGCTR11-E5-1-"+cVarLog+".SQL",cQuery2)


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
		cQuery2 := "SELECT D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC,SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) AS D1_TOTAL"+CRLF
		cQuery2 += " FROM SD1"+ALLTRIM(aConsorcio[nScan,8])+" SD1"+CRLF
		cQuery2 += " LEFT JOIN SB1"+ALLTRIM(aConsorcio[nScan,8])+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D1_COD = B1_COD  AND SB1.D_E_L_E_T_ = '' "+CRLF
		cQuery2 += " WHERE SUBSTRING(D1_DTDIGIT,1,6) = '"+SUBSTR(aPeriodo[_nI,1],4,4)+SUBSTR(aPeriodo[_nI,1],1,2)+"' AND SD1.D_E_L_E_T_ = '' "+CRLF
		IF SM0->M0_CODIGO == "01"  .AND. ALLTRIM(QTMP->CNF_CONTRA)=="313000504"+CRLF // Despesas médicas
			cQuery2 += " AND D1_FORNECE<>'002918'"+CRLF
		ENDIF
		IF SM0->M0_CODIGO == "14"
			cQuery2 += " AND D1_FORNECE<>'000604'"+CRLF
		ENDIF
		cQuery2 += " AND D1_CC = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'"+CRLF
		cQuery2 += " AND SUBSTRING(B1_CONTA,1,1) <> '2' AND SUBSTRING(B1_CONTA,1,3) <> '113' "+CRLF
		// 19/11/2021 - Contas alteradas de 113 para 121
		cQuery2 += " AND (SUBSTRING(B1_CONTA,1,3) <> '121' OR SUBSTRING(B1_CONTA,1,5) IN ('12201','12105'))" +CRLF
		cQuery2 += " AND D1_FILIAL = '"+xFilial("SD1")+"'"+CRLF
		cQuery2 += " GROUP BY D1_FILIAL,D1_SERIE,D1_DOC,D1_FORNECE,D1_LOJA,D1_COD,B1_DESC,B1_GRUPO,D1_CC"+CRLF
		//cQuery2 += " ORDER BY B1_DESC"+CRLF

		u_LogMemo("BKGCTR11-D1-3-"+cVarLog+".SQL",cQuery2)
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
					aAcrDcr := u_fAcrDcr(ALLTRIM(aConsorcio[nScan,8]))
				Else
					aAcrDcr := u_fAcrDcr(ALLTRIM(aConsorcio[nScan,8]),aAcrDcr)
				EndIf
			Else
				aAcrDcr := {}
			EndIf
			//<--- Fim: Buscar Acrescimos e Decrescimos Financeiros da NFE
			dbSelectArea("TMPX2")

			cOUTROS := 'S'

			//nAuxVl := IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
			nIndDesp:= IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),VAL(aConsorcio[nScan,5]),1)
			nAuxVl  := TMPX2->D1_TOTAL/nIndDesp

			IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cVT_Prod


				//If TMPX2->D1_DOC == '000051817'
				//	xbk := 0
				//EndIf

				cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'12',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"",.F.,nIndDesp)

				cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)
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

				cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'14',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"",.F.,nIndDesp)

				cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)

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

				cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'20',_nI,nAuxVl,aAcrDcr,cOutros,"N",.T.,"",.F.,nIndDesp)

				cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'08',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)

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
				lPRat := .T.

				FOR XI_ := _nI TO nParcela
					dbSelectArea(ALIAS_TMP)

					//nAuxVl := IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),nValRat/VAL(aConsorcio[nScan,5]),nValRat)
					nIndDesp:= IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),VAL(aConsorcio[nScan,5]),1)
					nAuxVl  := nValRat/nIndDesp


					//CONSIDERAR O RATEIO DOS CONSORCIOS
					//VERIFICAR PORQUE ESTÁ GERANDO RESULTADO NEGATIVO EM NOV/2020



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

					cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,"",.T.,nIndDesp)

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

					cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+cCodCC,XI_,nAuxVl,aAcrDcr,cOutros,cOutros,lPRat,cCodCC,.T.,nIndDesp)

					lPRat   := .F.
				NEXT
			ENDIF

			IF cOUTROS == 'S'

				//nAuxVl := IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL/VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL)
				nIndDesp:= IIF(ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),VAL(aConsorcio[nScan,5]),1)
				nAuxVl  := TMPX2->D1_TOTAL/nIndDesp

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

				cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,"W"+TMPX2->D1_COD,_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,TMPX2->B1_DESC,.F.,nIndDesp)


						/*
			   			dbSelectArea(ALIAS_TMP)
			   			IF MsSeek(IIF(nConsol>0,"999999999",ALLTRIM(QTMP->CNF_CONTRA))+'30',.F.)
			     			Reclock(ALIAS_TMP,.F.)
							cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
							&cCampo2 += IIF( ALLTRIM(TMPX2->D1_CC) == ALLTRIM(aConsorcio[nScan,4]),TMPX2->D1_TOTAL /VAL(aConsorcio[nScan,5]),TMPX2->D1_TOTAL )
							(ALIAS_TMP)->(Msunlock())
						ENDIF
						*/

				cOutros := GravaCCD1(ALIAS_TMP,nConsol,QTMP->CNF_CONTRA,'30',_nI,nAuxVl,aAcrDcr,cOutros,cOutros,.T.,"",.F.,nIndDesp)
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
		cQuery2 += " AND E5_FILIAL = '"+xFilial("SE5")+"'"+CRLF

		u_LogMemo("BKGCTR11-E5-2-"+cVarLog+".SQL",cQuery2)

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
	cQuery2 += " AND E5_FILIAL = '"+xFilial("SE5")+"'"+CRLF

	u_LogMemo("BKGCTR11-E5-3-"+cVarLog+".SQL",cQuery2)

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

//IncProc("Consultando faturamento das medições avulsas...")
//********* FATURAMENTO - Inclusão para medição avulso
cQuery2 := "SELECT C5_ESPECI1,A1_NOME,CTT_DESC01,SUM(D2_TOTAL) AS D2_TOTAL,SUM(D2_VALISS) AS D2_VALISS,SUM(D2_VALCPM) AS D2_VALCPM,SUM(E1_XXISSBI) AS E1_XXISSBI,SUM(E5_VALOR) AS E5DESC"+CRLF
cQuery2 += " FROM "+RETSQLNAME("SC5")+" SC5" +CRLF
cQuery2 += " INNER JOIN "+RETSQLNAME("SC6")+" SC6 ON SC5.C5_NUM = SC6.C6_NUM" +CRLF
cQuery2 += "       AND  SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.D_E_L_E_T_ = ''"+CRLF

cQuery2 += " INNER JOIN "+RETSQLNAME("SD2")+" SD2 ON C6_NUM = D2_PEDIDO AND C6_ITEM = D2_ITEM"+CRLF
cQuery2 += "       AND  SD2.D2_FILIAL = '"+xFilial("SD2")+"' AND SD2.D_E_L_E_T_ = ''"+CRLF

// 27/02/20
cQuery2 += " LEFT JOIN "+RETSQLNAME("SE5")+" SE5 ON E5_PREFIXO = D2_SERIE AND E5_NUMERO = D2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = D2_CLIENTE AND E5_LOJA = D2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " +CRLF//--AND E5_PARCELA = '  '
cQuery2 += "      AND  E5_FILIAL = '"+xFilial("SE5")+"' AND SE5.D_E_L_E_T_ = '' "+CRLF

cQuery2 += " LEFT JOIN "+RETSQLNAME("SE1")+" SE1" + CRLF
cQuery2 += " 	  ON (E1_PREFIXO = D2_SERIE AND E1_NUM = D2_DOC AND E1_TIPO = 'NF' AND  " + CRLF
cQuery2 += "         E1_FILIAL = '"+xFilial("SE1")+"' AND  SE1.D_E_L_E_T_ = '') "+CRLF

cQuery2 += " INNER JOIN "+RETSQLNAME("SA1")+" SA1 ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA " +CRLF
cQuery2 += "      AND  SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ''"+CRLF

cQuery2 += " INNER JOIN "+RETSQLNAME("CTT")+" CTT ON SC5.C5_ESPECI1 = CTT.CTT_CUSTO AND CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ''" +CRLF
cQuery2 += " WHERE SC5.D_E_L_E_T_ = '' AND SC5.C5_MDCONTR='' AND SC5.C5_XXCOMPT ='"+SUBSTR(aPeriodo[_nI,1],1,2)+SUBSTR(aPeriodo[_nI,1],4,4)+"'"+CRLF
cQuery2 += " AND C5_FILIAL = '"+xFilial("SC5")+"'"+CRLF

//cQuery2 += " AND C5_ESPECI1 <> '000000001'"+CRLF
//IF !EMPTY(cContrato)
//	cQuery2 += " AND C5_ESPECI1 ='"+ALLTRIM(cContrato)+"'"
//ENDIF
cQuery2 += " AND C5_ESPECI1 ='"+ALLTRIM(QTMP->CNF_CONTRA)+"'"+CRLF

cQuery2 += " GROUP BY SC5.C5_ESPECI1,SA1.A1_NOME,CTT.CTT_DESC01" +CRLF

u_LogMemo("BKGCTR11-SC5-1-"+cVarLog+".SQL",cQuery2)

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
	//AADD(aRentab,{"03-1","NDC","S",0})
	AADD(aRentab,{"03-2","","S",0})
	//AADD(aRentab,{"04","(-) Impostos e Contribuições","S",(TMPX2->D2_TOTAL*nMImpContr)/100})
	AADD(aRentab,{"04","(-) Impostos e Contribuições","S",IIF(nIndTC>0,((TMPX2->D2_TOTAL*nMImpContr)/100)/(nIndTC/100),(TMPX2->D2_TOTAL*nMImpContr)/100)})

	//AADD(aRentab,{"05","(-) ISS","S",TMPX2->D2_VALISS})
	AADD(aRentab,{"05","(-) ISS","S",IIF(nIndTC>0,TMPX2->D2_VALISS/(nIndTC/100),TMPX2->D2_VALISS)})
	AADD(aRentab,{"05-1","(-) ISS Bitributado","S",IIF(nIndTC>0,TMPX2->D2_VALCPM/(nIndTC/100),TMPX2->D2_VALCPM)})
	AADD(aRentab,{"05-2","(-) ISS Bitributado Indev.","S",IIF(nIndTC>0,TMPX2->E1_XXISSBI/(nIndTC/100),TMPX2->E1_XXISSBI)})
	//AADD(aRentab,{"06","Total dos Impostos + ISS","S",((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS})
	AADD(aRentab,{"06","Total dos Impostos + ISS","S",IIF(nIndTC>0,(((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS+TMPX2->D2_VALCPM+TMPX2->E1_XXISSBI)/(nIndTC/100),((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS+TMPX2->D2_VALCPM+TMPX2->E1_XXISSBI)})
	AADD(aRentab,{"06-1","","S",0})
	//AADD(aRentab,{"07","FATURAMENTO LÍQUIDO","S",TMPX2->D2_TOTAL-(((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS)})
	AADD(aRentab,{"07","FATURAMENTO LÍQUIDO","S",IIF(nIndTC>0,(TMPX2->D2_TOTAL-(((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS+TMPX2->D2_VALCPM+TMPX2->E1_XXISSBI))/(nIndTC/100),TMPX2->D2_TOTAL-(((TMPX2->D2_TOTAL*nMImpContr)/100)+TMPX2->D2_VALISS+TMPX2->D2_VALCPM+TMPX2->E1_XXISSBI))})
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
	aAdd(aRentab,{"30-3","NDC","S",0})
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
		IF "|"+aRentab[_nJ,1]+"|" $ "|03|03-1|04|05|05-1|05-2|06|07|30-2|30-3|"
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
For Yi_ := 1 TO LEN(aContratos)
	FOR _nI := 1 TO nPeriodo
		//IncProc("Calculando resultados...")
		//CALCULA TAXA ADM
		nValTaxaAdm := 0
		nFaturaOF := 0
		dbSelectArea(ALIAS_TMP)
		IF MsSeek(ALLTRIM(aContratos[Yi_])+'03',.F.)
			cCampo2   := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			nValTaxaAdm := (&cCampo2*nTaxaAdm)/100
			nFaturaOF := &cCampo2
		ENDIF

		//VALOR DA NDC
		//nNDC := 0
		//dbSelectArea(ALIAS_TMP)
		//IF MsSeek(ALLTRIM(aContratos[Yi_])+'03-1',.F.)
		//	cCampo2   := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
		//	nNDC := &cCampo2
		//ENDIF

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

		nNDC := 0
		dbSelectArea(ALIAS_TMP)
		IF dbSeek(ALLTRIM(aContratos[Yi_])+'30-3',.F.)
			Reclock(ALIAS_TMP,.F.)
			cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
			nNDC  := &cCampo2
			IF MsSeek(ALLTRIM(aContratos[Yi_])+'30',.F.)
				Reclock(ALIAS_TMP,.F.)
				cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
				&cCampo2 += nNDC
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
			//&cCampo2 := (nResultado/(nFaturaOF+nNDC))*100
			&cCampo2 := (nResultado/(nFaturaOF))*100
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
			//&cCampo2 := (n2Resultado/(nFaturaOF+nNDC))*100
			&cCampo2 := (n2Resultado/(nFaturaOF))*100
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
		IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|00|01|02|03-2|06-1|07-1|22-1|30-1|YYYYYYYYZ|"
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
	IF "|"+ALLTRIM((ALIAS_TMP)->XX_CODIGO)+"|" $ "|00|01|02|03-2|06-1|07-1|22-1|30-1|YYYYYYYYZ|"
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

	u_xxConOut("INFO","BKGCTR11","Gravando dados Rentabilidade dos contratos")

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
					cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
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
					cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
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
					cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
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
					cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
					cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
					cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
					cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
					cQuery +="				 0,"
					cQuery +="				 0,"
					cQuery +="				 "+STR(nVcampo,14,2)+","
					cQuery +="				 "+STR(aPrev[1,3],14,2)+")"
					cQuery +="END "
					TcSqlExec(cQuery)

					cEmpresa := ""
					cEmpresa := U_BUSCAEMPR(cCODGCT)
					//TABELA DE Previsao Proventos
					cQuery := ""
					cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[PrevisaoProventos] "
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
					cQuery +="BEGIN "
					cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[PrevisaoProventos] SET [PrevisaoProventos]="+STR(aPrev[1,5],14,2)
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
					cQuery +="END "
					cQuery +="ELSE "
					cQuery +="BEGIN "
					cQuery +=" INSERT INTO [EstudoRentabilidade].[dbo].[PrevisaoProventos] "
					cQuery +="            ([Empresa] "
					cQuery +="            ,[CodigoContrato] "
					cQuery +="            ,[Competencia] "
					cQuery +="            ,[PrevisaoProventos])"
					cQuery +="      VALUES ("+cEmpresa+","
					cQuery +="              '"+cCODGCT+"',"
					cQuery +="              '"+cXCompet+" 00:00:00',"
					cQuery +="				 "+STR(aPrev[1,5],14,2)+")"
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
					cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
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
					cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
					cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
					cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
					cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
					cQuery +="				 "+STR(nVcampo,14,2)+","
					cQuery +="				 "+STR(aPrev[1,4],14,2)+","
					cQuery +="				 0,"
					cQuery +="				 0)"
					cQuery +="END "
					TcSqlExec(cQuery)

					cEmpresa := ""
					cEmpresa := U_BUSCAEMPR(cCODGCT)
					//TABELA DE Previsao Proventos
					cQuery := ""
					cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[PrevisaoProventos] "
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
					cQuery +="BEGIN "
					cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[PrevisaoProventos] SET [PrevisaoProventos]="+STR(aPrev[1,5],14,2)
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
					cQuery +="END "
					cQuery +="ELSE "
					cQuery +="BEGIN "
					cQuery +=" INSERT INTO [EstudoRentabilidade].[dbo].[PrevisaoProventos] "
					cQuery +="            ([Empresa] "
					cQuery +="            ,[CodigoContrato] "
					cQuery +="            ,[Competencia] "
					cQuery +="            ,[PrevisaoProventos])"
					cQuery +="      VALUES ("+cEmpresa+","
					cQuery +="              '"+cCODGCT+"',"
					cQuery +="              '"+cXCompet+" 00:00:00',"
					cQuery +="				 "+STR(aPrev[1,5],14,2)+")"
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
					cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
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
					cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
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
					cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
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
					cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
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
					cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
					cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
					cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
					cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
					cQuery +="				 0,"
					cQuery +="				 0,"
					cQuery +="				 "+STR(nVcampo,14,2)+","
					cQuery +="				 "+STR(aPrev[1,3],14,2)+")"
					cQuery +="END "
					TcSqlExec(cQuery)

					cEmpresa := ""
					cEmpresa := U_BUSCAEMPR(cCODGCT)
					//TABELA DE Previsao Proventos
					cQuery := ""
					cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[PrevisaoProventos] "
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
					cQuery +="BEGIN "
					cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[PrevisaoProventos] SET [PrevisaoProventos]="+STR(aPrev[1,5],14,2)
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
					cQuery +="END "
					cQuery +="ELSE "
					cQuery +="BEGIN "
					cQuery +=" INSERT INTO [EstudoRentabilidade].[dbo].[PrevisaoProventos] "
					cQuery +="            ([Empresa] "
					cQuery +="            ,[CodigoContrato] "
					cQuery +="            ,[Competencia] "
					cQuery +="            ,[PrevisaoProventos])"
					cQuery +="      VALUES ("+cEmpresa+","
					cQuery +="              '"+cCODGCT+"',"
					cQuery +="              '"+cXCompet+" 00:00:00',"
					cQuery +="				 "+STR(aPrev[1,5],14,2)+")"
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
					cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
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
					cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
					cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
					cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
					cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
					cQuery +="				 "+STR(nVcampo,14,2)+","
					cQuery +="				 "+STR(aPrev[1,4],14,2)+","
					cQuery +="				 0,"
					cQuery +="				 0)"
					cQuery +="END "
					TcSqlExec(cQuery)

					cEmpresa := ""
					cEmpresa := U_BUSCAEMPR(cCODGCT)
					//TABELA DE Previsao Proventos
					cQuery := ""
					cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[PrevisaoProventos] "
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
					cQuery +="BEGIN "
					cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[PrevisaoProventos] SET [PrevisaoProventos]="+STR(aPrev[1,5],14,2)
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
					cQuery +="END "
					cQuery +="ELSE "
					cQuery +="BEGIN "
					cQuery +=" INSERT INTO [EstudoRentabilidade].[dbo].[PrevisaoProventos] "
					cQuery +="            ([Empresa] "
					cQuery +="            ,[CodigoContrato] "
					cQuery +="            ,[Competencia] "
					cQuery +="            ,[PrevisaoProventos])"
					cQuery +="      VALUES ("+cEmpresa+","
					cQuery +="              '"+cCODGCT+"',"
					cQuery +="              '"+cXCompet+" 00:00:00',"
					cQuery +="				 "+STR(aPrev[1,5],14,2)+")"
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
					cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
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
					cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
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
					cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
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
					cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
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
					cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
					cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
					cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
					cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
					cQuery +="				 0,"
					cQuery +="				 0,"
					cQuery +="				 "+STR(nVcampo,14,2)+","
					cQuery +="				 "+STR(aPrev[1,3],14,2)+")"
					cQuery +="END "
					TcSqlExec(cQuery)

					cEmpresa := ""
					cEmpresa := U_BUSCAEMPR(cCODGCT)
					//TABELA DE Previsao Proventos
					cQuery := ""
					cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[PrevisaoProventos] "
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
					cQuery +="BEGIN "
					cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[PrevisaoProventos] SET [PrevisaoProventos]="+STR(aPrev[1,5],14,2)
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
					cQuery +="END "
					cQuery +="ELSE "
					cQuery +="BEGIN "
					cQuery +=" INSERT INTO [EstudoRentabilidade].[dbo].[PrevisaoProventos] "
					cQuery +="            ([Empresa] "
					cQuery +="            ,[CodigoContrato] "
					cQuery +="            ,[Competencia] "
					cQuery +="            ,[PrevisaoProventos])"
					cQuery +="      VALUES ("+cEmpresa+","
					cQuery +="              '"+cCODGCT+"',"
					cQuery +="              '"+cXCompet+" 00:00:00',"
					cQuery +="				 "+STR(aPrev[1,5],14,2)+")"
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
					cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
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
					cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
					cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_NOMCLI"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
					cQuery +="				'"+PAD(ALLTRIM(U_BUSCACN9(cCODGCT,"CN9_XXDESC"))+IIF(nConsolida==1,"-Consolidado",""),80)+"',"
					cQuery +="				'"+U_BUSCACN9(cCODGCT,"CN9_XXNRBK")+"',"
					cQuery +="				 "+STR(nVcampo,14,2)+","
					cQuery +="				 "+STR(aPrev[1,4],14,2)+","
					cQuery +="				 0,"
					cQuery +="				 0)"
					cQuery +="END "
					TcSqlExec(cQuery)

					cEmpresa := ""
					cEmpresa := U_BUSCAEMPR(cCODGCT)
					//TABELA DE Previsao Proventos
					cQuery := ""
					cQuery +=" IF  (SELECT TOP 1 [CodigoContrato] FROM [EstudoRentabilidade].[dbo].[PrevisaoProventos] "
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59') <> '' "
					cQuery +="BEGIN "
					cQuery +=" UPDATE  [EstudoRentabilidade].[dbo].[PrevisaoProventos] SET [PrevisaoProventos]="+STR(aPrev[1,5],14,2)
					cQuery +="     WHERE [CodigoContrato]= '"+cCODGCT+"' AND Competencia BETWEEN '"+cXCompet+" 00:00:00' AND '"+cXCompet+" 23:59:59'"
					cQuery +="END "
					cQuery +="ELSE "
					cQuery +="BEGIN "
					cQuery +=" INSERT INTO [EstudoRentabilidade].[dbo].[PrevisaoProventos] "
					cQuery +="            ([Empresa] "
					cQuery +="            ,[CodigoContrato] "
					cQuery +="            ,[Competencia] "
					cQuery +="            ,[PrevisaoProventos])"
					cQuery +="      VALUES ("+cEmpresa+","
					cQuery +="              '"+cCODGCT+"',"
					cQuery +="              '"+cXCompet+" 00:00:00',"
					cQuery +="				 "+STR(aPrev[1,5],14,2)+")"
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
					cQuery +="				[CodigoCliente]='"+U_BUSCACN9(cCODGCT,"CN9_XCLIEN")+"',"
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
	//u_xxConOut("INFO","BKGCTR11","Finalizado processamento Rentabilidade dos contratos")

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
		U_PlanXlsx(aPlans,"",cArqS, lClose:= .F.,)
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

			//IncProc("Gerando arquivo "+cArqS)

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

		u_WaitLog(cArqs,{|| ShellExecute("open", cArqTmp,"","",1) },"Aguarde a abertura do Excel...")

	Else
		u_MsgLog(,"Falha na criação do arquivo "+cArqTmp,"E")
	Endif

Return


//Atualiza tabela de custro 
Static Function AtualizaCC()
	Local _IX := 0

	// Grava o Semaforo Tabela Centro de Custo 
	U_BKPutMv("MV_XXSEMAF","S","C",1,0,"Semaforo Tabela Centro de Custo")

	TCSQLExec("EXEC BKIntegraRubi.DBO.PROC_UPD_CUSTO "+SM0->M0_CODIGO)

	FOR _IX:= 1 TO LEN(aConsorcio)

		TCSQLExec("EXEC BKIntegraRubi.DBO.PROC_UPD_CUSTO "+SUBSTR(ALLTRIM(aConsorcio[_IX,2]),1,2))

	NEXT

	// Grava o Semaforo Tabela Centro de Custo 
	U_BKPutMv("MV_XXSEMAF","N","C",1,0,"Semaforo Tabela Centro de Custo")

Return


Static Function ValidPerg
	Local i		:= 0
	Local j		:= 0
	Local aArea	:= GetArea()
	Local aRegs	:= {}


	cPerg := "BKGCTR11"
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)

	AADD(aRegs,{cPerg,"01","Contrato:","Contrato:","Contrato:","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","","BKGCTR11H1."})
	AADD(aRegs,{cPerg,"02","%Média Impostos e Contribuições:","%Média Impostos e Contribuições:" ,"%Média Impostos e Contribuições:" ,"mv_ch2","N",10,5,2,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","","BKGCTR11H2."})
	AADD(aRegs,{cPerg,"03","%Encargos CLT:","%Encargos:" ,"%Encargos:" ,"mv_ch3","N",10,5,2,"G","NaoVazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","","BKGCTR11H3."})
	AADD(aRegs,{cPerg,"04","%Encargos Autonomos:","%Encargos Autonomos:" ,"%Encargos Autonomos:" ,"mv_ch4","N",10,5,2,"G","NaoVazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","","BKGCTR11H4."})
	AADD(aRegs,{cPerg,"05","%Incidências:","%Incidências:" ,"%Incidências:" ,"mv_ch5","N",10,5,2,"G","NaoVazio()","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","S","","BKGCTR11H5."})
	AADD(aRegs,{cPerg,"06","%Taxa de Administração:","%Taxa de Administração:" ,"%Taxa de Administração:" ,"mv_ch6","N",10,5,2,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","S","","BKGCTR11H6."})
	AADD(aRegs,{cPerg,"07","Ano/Mes somente (AAAAMM):","Ano/Mes somente (AAAAMM):" ,"Ano/Mes somente (AAAAMM):" ,"mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","S","","BKGCTR11H7."})

	For i:=1 to Len(aRegs)
		If !MsSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
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
	Local cMes          := ""
	Local cXXSEMAF		:= "N"
	Local aRetCons		:= {}
	Local cLogCons   	:= ""
	Local cCrLf   		:= Chr(13) + Chr(10)
	Local _IX			:= 0
	Local IX			:= 0
	Local dMaxCompet	:= CTOD("")

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
	PRIVATE nIncidenci  := 0
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
	Private cDViagens	:= "34202003"
	Private cCusBK		:= U_MVXCUSBK()
	PRIVATE aFixeFX     := {}
	Private aHeader	    := {}
	PRIVATE nConsolida	:= 2
	PRIVATE nIndConsor	:= 2
	PRIVATE nIndDesp	:= 1
	PRIVATE nRateia     := 2
	PRIVATE nConsol     := 0
	PRIVATE cConsolida 	:= ""
	PRIVATE aConsolida 	:= {}
	PRIVATE aContConsol := {}
	PRIVATE cTipoContra := ""
	PRIVATE aXMIMPC		:= {}
	PRIVATE aMImpContr  := {}
	PRIVATE aTitulos,aCampos,aCabs,aFormat
	PRIVATE aCampos2,aCabs2
	PRIVATE ALIAS_TMP   := "TMPC"+ALLTRIM(SM0->M0_CODIGO)
	PRIVATE ALIAS_FOL   := "TMPF"+ALLTRIM(SM0->M0_CODIGO)
	PRIVATE cXXPLR 		:= ""
	Private aFurnas		:= U_MVXFURNAS()
	PRIVATE lFurnas		:= .F.

	Default lJob	:= .F.
	Default aAglContr := {}

	IF !lJob
		ValidPerg2()
		If !Pergunte(cPerg,.T.)
			Return Nil
		Endif
	ENDIF


	aXMIMPC	:= {}
	aXMIMPC	:= StrTokArr(U_MVXMIMPC(),"|") //%Media de Impostos e Contribuicoes calculo Rentabilidade dos Contratos
	aMImpContr  := {}
	FOR IX := 1 TO LEN(aXMIMPC)
		AADD(aMImpContr,StrTokArr(aXMIMPC[IX],";"))
	NEXT

	IF !lJob
		cContrato  	:= mv_par01
		If Empty(cContrato) // Bruno Santiago 04/10/21
			lFurnas := .T.
		EndIf
	ELSE
		IF LEN(aAglContr) > 0
			AADD(aRetCons,aAglContr)
		ELSE
			cContrato  	:= ""
		ENDIF
	ENDIF

	nMImpContr 	:= VAL(aMImpContr[1,2])// mv_par02
	nEncargos  	:= U_MVXENCAP()        // BK 37.1328 MMDK 8
	nEncarIPT	:= U_MVXEIPT()         // BK 20      MMDK 1
	nIncidenci	:= U_MVXINCID()        // BK 28.860  MMDK 20.700
	nTaxaAdm	:= U_MVXTXADM()        // mv_par06
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
						u_xxConOut("ERROR","BKGCTR11","Contrato n° "+cConsolida+" inválido. Verifique!!")
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
						u_xxConOut("ERROR","BK2GCTR11","Contrato n° "+cConsolida+" inválido. Verifique!!")
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
						u_xxConOut("ERROR","BK2GCTR11","Contratos não encontrados, serão desconsiderados da Consolidação - "+cLogCons)
					ENDIF
					RETURN NIL
				ENDIF
			ENDIF
		ELSE
			IF !lJob
				MSGSTOP("Informações para Consolidar invalida. Verifique!!")
			ELSE
				u_xxConOut("ERROR","BK2GCTR11","Informações para Consolidar invalidas. Verifique!!")
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
	cCCRE_Verb	:= "" //GetMv("MV_XXCCREV") //"|774|775|776|812|814|"
	cCCRE_Prod	:= "" //GetMv("MV_XXCCREP") //"|34202016|"
	cCDPR_Prod	:= GetMv("MV_XXCDPRP") //"|320200111|34202034|000000000000112|34202057|34202086|"    cod produtos rateio no contrato
	cCDPR_GRUP	:= GetMv("MV_XXCDPRG") //'|0008|0009|0010|'  *********                               cod grupo de produto rateio no contrato
	cNINC_Verb	:= U_MVXNINCI()

	aContrCons	:= {}
	aContrCons	:= U_MVXCONS()

// Rateio        Contrato  x  Produtos                       15/01/20 - Marcos
	aRatCtrPrd  := U_DefCtrPrd()

	cExm_Prod	:= U_MVXCEXMP()
	cMFG_Prod	:= U_MVXCMFGP()
	cDCH_Prod	:= U_MVXCDCH()
	cXXPLR	    := U_MVXPLR()

//MV_XXSEMAF    C   Semaforo controle de execução da procedure de atualização tabela centro de custo integração Rubi X Microsiga
	cXXSEMAF	:= u_BkGetMv("MV_XXSEMAF",.F.,"N",,cEmpAnt)

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
		u_WaitLog(cPerg, {|oSay| AtualizaCC()}, titulo)
	ELSE
		u_MsgLog(cPerg,"Atualizando tabela Folha de Pagamento!!")
		Return Nil
	ENDIF

	IF !EMPTY(cContrato)

		cQuery := "SELECT MIN(CNF_DTVENC) AS CNF_INICIO, MAX(CNF_DTVENC) AS CNF_FIM,"+CRLF
		cQuery += " MAX((SUBSTRING(CNF_COMPET,4,4))+SUBSTRING(CNF_COMPET,1,2))+'01' AS MAXCOMPET"+CRLF
		cQuery += " FROM ( "+CRLF
		cQuery += " SELECT CNF_DTVENC,CNF_COMPET "+CRLF
		cQuery += " FROM "+RETSQLNAME("CNF")+" CNF "+CRLF
		cQuery += " INNER JOIN "+RETSQLNAME("CN9")+" CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA " +CRLF
		cQuery += " AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = '' "+CRLF
		cQuery += " WHERE CNF.D_E_L_E_T_='' " +CRLF
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
			cQuery += " AND CNF_CONTRA ='"+ALLTRIM(cContrato)+"'" +CRLF
			cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
		ENDIF

		cQuery += "	) AS REGISTRO"+CRLF

	ELSE
		cContrCons := ""
		For IX:= 1 TO LEN(aConsorcio)
			cContrCons += "'"+ALLTRIM(aConsorcio[IX,1])+"',"
		NEXT
		cQuery := " SELECT MIN(CNF_DTVENC) AS CNF_INICIO,MAX(CNF_DTVENC) AS CNF_FIM,CN9_SITUAC,"+CRLF
		cQuery += " MAX((SUBSTRING(CNF_COMPET,4,4))+SUBSTRING(CNF_COMPET,1,2))+'01' AS MAXCOMPET"+CRLF
		cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+CRLF
		cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA"+CRLF
		cQuery += " AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = '' WHERE CNF.D_E_L_E_T_=''"+CRLF
		//cQuery += " AND CN9_SITUAC = '05'"+CRLF   // aqui bruno 01/10/2021 SAIR TODOS OS CONTRATOS
		cQuery += " AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+CRLF
		IF !lConsorcio
			IF !EMPTY(cContrCons)
				cQuery += " AND CNF_CONTRA NOT IN ("+SUBSTRING(ALLTRIM(cContrCons),1,LEN(cContrCons)-1)+") " +CRLF
			ENDIF
		ENDIF
		IF !lJob
			IF !lFurnas
				cQuery += " AND SUBSTRING(CNF_CONTRA,7,3) <> '381' AND SUBSTRING(CNF_CONTRA,7,3) <> '391'"+CRLF
			ENDIF
		ELSE
			cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) <> '008' "+CRLF //IPT
			//	    cQuery += " AND SUBSTRING(CNF_CONTRA,1,3) <> '049' "
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
			cQuery += " AND CNF_CONTRA NOT IN ('193000288','194000289','195000290','196000291')"  +CRLF
			cQuery += " AND CNF_CONTRA NOT IN ('197000292','198000293','199000294')"  +CRLF
			cQuery += " AND CNF_CONTRA NOT IN ('197001292','198001293','199001294')" +CRLF
			IF SM0->M0_CODIGO <> "14"
				cQuery += " AND CNF_CONTRA NOT IN ('302000508')"+CRLF
			ENDIF
		ENDIF

		cQuery += " GROUP BY CN9_SITUAC"+CRLF

	ENDIF

	TCQUERY cQuery NEW ALIAS "QTMP1"
	TCSETFIELD("QTMP1","CNF_INICIO","D",8,0)
	TCSETFIELD("QTMP1","CNF_FIM","D",8,0)

	dbSelectArea("QTMP1")
	dDataI		:= QTMP1->CNF_INICIO
	dDataFinal	:= QTMP1->CNF_FIM
	dMaxCompet  := STOD(QTMP1->MAXCOMPET)
	If dMaxCompet > dDataFinal
		dDataFinal := LastDay(dMaxCompet)
	EndIf


	If !lJob .AND. EMPTY(cContrato) // Bruno Santiago 04/10/2021
		//dDataI := CTOD("01/01/2018")
	EndIf
//cSituac 	:= QTMP1->CN9_SITUAC

	QTMP1->(Dbclosearea())

	IF EMPTY(DTOS(dDataI)) .OR. EMPTY(DTOS(dDataFinal))
		IF !lJob
			MSGSTOP("Contrato não encontrado!!")
		ELSE
			u_xxConOut("INFO","BK2GCTR11","Contrato não encontrado!! "+cLogCons+CRLF+cQuery)
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
		AADD(aFormat,"N2")
	NEXT

	AADD(aCampos,"TRB->XX_TOTAL")
	AADD(aCabs  ,"TOTAL")
	AADD(aFixeFX,{"TOTAL","XX_TOTAL",'C', 10,00,'@!'})
	AADD(aHeader,{"TOTAL","XX_TOTAL" ,"@!",10,00,"","","C","TRB","R"})
	AADD(aFormat,"N2")

	AADD(aCampos,"TRB->XX_INDIC")
	AADD(aCabs  ,"INDICE")
	AADD(aFixeFX,{"INDICE","XX_INDIC",'C', 10,00,'@!'})
	AADD(aHeader,{"INDICE","XX_INDIC" ,"@!",10,00,"","","C","TRB","R"})
	AADD(aFormat,"N2")

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

		u_WaitLog(cPerg, {|oSay| ProcBKGCTR11(lJob)}, titulo)
		u_WaitLog(cPerg, {|oSay| MBrwBKGCTR11()}, "Browse")

		oTmpTb3:Delete()

	ELSE
		u_WaitLog(cPerg, {|oSay| ProcBKGCTR11(lJob)}, titulo)
	ENDIF

	oTmpTb2:Delete()
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
	Local i		:= 0
	Local j		:= 0
	Local aArea	:= GetArea()
	Local aRegs := {}

	cPerg := "BK2GCTR11"
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)

	AADD(aRegs,{cPerg,"01","Contrato:","Contrato:","Contrato:","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
	AADD(aRegs,{cPerg,"02","%Média Impostos e Contribuições:","%Média Impostos e Contribuições:" ,"%Média Impostos e Contribuições:" ,"mv_ch2","N",10,5,2,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
	AADD(aRegs,{cPerg,"03","%Encargos CLT:","%Encargos:" ,"%Encargos:" ,"mv_ch3","N",10,5,2,"G","NaoVazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
	AADD(aRegs,{cPerg,"04","%Encargos Autonomos:","%Encargos Autonomos:" ,"%Encargos Autonomos:" ,"mv_ch4","N",10,5,2,"G","NaoVazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
	AADD(aRegs,{cPerg,"05","%Incidências:","%Incidências:" ,"%Incidências:" ,"mv_ch5","N",10,5,2,"G","NaoVazio()","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
	AADD(aRegs,{cPerg,"06","%Taxa de Administração:","%Taxa de Administração:" ,"%Taxa de Administração:" ,"mv_ch6","N",10,5,2,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
	AADD(aRegs,{cPerg,"07","Consolidar Contratos?","Consolidar Contratos?","Consolidar Contratos?","mv_ch7","N",01,0,2,"C","","mv_par07","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"08","Consorcio Aplicar Indice Total?","Consorcio Aplicar Indice Total","Consorcio Aplicar Indice Total","mv_ch8","N",01,0,2,"C","","mv_par08","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"09","Rateia Despesas no Cronograma?","Rateia Despesas no Cronograma?","Rateia Despesas no Cronograma?","mv_ch9","N",01,0,1,"C","","mv_par09","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})

	For i:=1 to Len(aRegs)
		If !MsSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
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
	LOCAL aPREV		:= {}
	LOCAL lCOMPET	:= .F.
	LOCAL _IX		:= 0

	IF nConsolida == 1
		nTSZG03   := 0
		nTResult  := 0
		nTSalBenef:= 0
		nTDespesa := 0
		nTSalario := 0

		FOR _IX := 1 TO LEN(aContConsol)
			//Calcula Valores da Projeção Financeira
			cCONTRA:= ALLTRIM(aContConsol[_IX,1])
			lCOMPET 	:= .F.
			nSZG03 		:= 0
			nSZG09 		:= 0
			n2SZG09 	:= 0
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
					n2SZG09 := IIF(nIndTC>0,SZG->ZG_CLT/(nIndTC/100),SZG->ZG_CLT) // Sem Encargos Sociais
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
			//FATURAMENTOPREV/RESULTADOPREV/SALARIOSPREV/GASTOSGERAISPREV/SALARIOSPREV
			IF lCOMPET
				nTSZG03   += nSZG03
				nTResult  += nResult
				nTSalBenef+= nSZG09+nSZG12 // Salarios +Encargos Sociais+ Beneficios
				nTDespesa += nSZG30 //nInsumos //nDespesa-nSalario
				nTSalario += n2SZG09 // Proventos Sem Encargos Sociais
			ENDIF
		NEXT
		AADD(aPrev,{nTSZG03,nTResult,nTSalBenef,nTDespesa,nTSalario})
	ELSE
		//Calcula Valores da Projeção Financeira
		nSZG03 := 0
		nSZG09 := 0
		n2SZG09:= 0
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
				n2SZG09 := IIF(nIndTC>0,SZG->ZG_CLT/(nIndTC/100),SZG->ZG_CLT) // Sem Encargos Sociais
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
		//FATURAMENTOPREV/RESULTADOPREV/SALARIOSPREV+BENEF/GASTOSGERAISPREV/SALARIOSPREV
		AADD(aPrev,{nSZG03,nResult,nSZG09+nSZG12,nSZG30,n2SZG09})//nSalario,nSZG30})//nInsumos}) //nDespesa-nSalario})
	ENDIF

	IF LEN(aPrev) == 0
		AADD(aPrev,{0,0,0,0,0})
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

	AADD(aPlans,{ALIAS_FOL,TRIM(cPerg)+"-FOLHA","",{"Detalhes Folha: "+titulo},aCampos3,aCabs3,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
	U_PlanXlsx(aPlans,"",TRIM(cPerg)+"-FOLHA", lClose:= .F.,)

Return



// Atualiza tabela de detalhamento da Folha de Pagamento
Static Function UpdTmpFol(lJob,cContrato,cEvento,cDesc,cTipo,nValor,_nI)
	Local aArea3
	Private cCampo3
	If !lJob
		aArea3 := GetArea()
		dbSelectArea(ALIAS_FOL)
		//If !MsSeek(cContrato+PAD(cTipo,25)+cEvento,.F.)
			Reclock(ALIAS_FOL,.T.)
			(ALIAS_FOL)->YY_CODGCT := cContrato
			(ALIAS_FOL)->YY_CODIGO := STRZERO(VAL(cEvento),4)
			(ALIAS_FOL)->YY_DESC   := cDesc
			(ALIAS_FOL)->YY_TIPO   := cTipo
			cCampo3  := ALIAS_FOL+"->YY_VAL"+STRZERO(_nI,3)
			&cCampo3 := nValor
		//Else
		//	Reclock(ALIAS_FOL,.F.)
		//	cCampo3  := ALIAS_FOL+"->YY_VAL"+STRZERO(_nI,3)
		//	&cCampo3 += nValor
		//EndIf
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


// Buscar Titulos do contas a pagar por itens dos Documentos de Entrada
// 20/07/2020
User Function fAcrDcr(cEmpC,aLAcrDcr)

	Local cQuery3 := ""
	Local nTotE2  := 0
	Local nACrDcr := 0
	Local _nY	  := 0
	Local nValTit := 0
//Local _nI	  := 0 

	Default cEmpC := ""
	Default aLAcrDcr := {}

	If Len(aLAcrDcr) = 0
		cQuery3 := " SELECT E2_VENCREA,E2_VALOR,E2_DESCONT,E2_MULTA,E2_JUROS,E2_ACRESC,E2_DECRESC,E2_VRETPIS,E2_VRETCOF,E2_VRETCSL,E2_VRETINS,E2_VRETIRF,E2_VRETISS"+CRLF
		If EMPTY(cEmpC)
			cQuery3 += " FROM "+RETSQLNAME("SE2")+" SE2"+CRLF
		Else
			cQuery3 += " FROM SE2"+cEmpC+" SE2"+CRLF
		EndIf
		cQuery3 += " WHERE SE2.D_E_L_E_T_='' AND SE2.E2_FILIAL = '"+xFilial("SE2")+"' AND E2_TIPO ='NF' "+CRLF
		cQuery3 += "   AND E2_PREFIXO = '"+TMPX2->D1_SERIE+"'" +CRLF
		cQuery3 += "   AND E2_NUM = '"+TMPX2->D1_DOC+"'" +CRLF
		cQuery3 += "   AND E2_FORNECE = '"+TMPX2->D1_FORNECE+"'" +CRLF
		cQuery3 += "   AND E2_LOJA = '"+TMPX2->D1_LOJA+"'" +CRLF

		u_LogTxt("BKGCTR11-E2.SQL")
		TCQUERY cQuery3 NEW ALIAS "QTMPXE2"
		u_LogTxt("BKGCTR11-E2.SQL",cQuery3)

		dbSelectArea("QTMPXE2")
		dbGoTop()

		If TMPX2->D1_DOC == "100330299"
			nTotE2  := 0
		EndIf

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
			nValTit := QTMPXE2->(E2_VALOR+E2_VRETPIS+E2_VRETCOF+E2_VRETCSL+E2_VRETINS+E2_VRETIRF+E2_VRETISS)
			nTotE2  += nValTit

			aAdd(aLAcrDcr,{SUBSTR(QTMPXE2->E2_VENCREA,1,6),nACrDcr,0,nValTit,0,nTotE2})

			dbSkip()
		Enddo

		For _nY := 1 To Len(aLAcrDcr)
			//                        Val desc/Acr  / Tot Geral * Valor do Item
			//aLAcrDcr[_nY,3] := Round((aLAcrDcr[_nY,2] / nTotE2) * TMPX2->D1_TOTAL,2)
			//                        Val titulo    / Tot Geral * Valor do Item
			//aLAcrDcr[_nY,5] := Round((aLAcrDcr[_nY,4] / nTotE2) * TMPX2->D1_TOTAL,2)
			aLAcrDcr[_nY,6] := nTotE2
		Next

		QTMPXE2->(Dbclosearea())
	EndIf

	For _nY := 1 To Len(aLAcrDcr)
		//                        Val desc/Acr  / Tot Geral * Valor do Item
		nTotE2 := aLAcrDcr[_nY,6]

		aLAcrDcr[_nY,3] := Round((aLAcrDcr[_nY,2] / nTotE2) * TMPX2->D1_TOTAL,2)
		//                        Val titulo    / Tot Geral * Valor do Item
		aLAcrDcr[_nY,5] := Round((aLAcrDcr[_nY,4] / nTotE2) * TMPX2->D1_TOTAL,2)
	Next

Return aLAcrDcr


// Gravar o custo dos Documentos de Entrada por Categoria/Produto
// 19/07/2020
Static Function GravaCCD1(cAliasTmp,nConsol,cCusto,cPrd,_nI,nValor,aAcrDcr,cOutros,cOutros1,lPRat,cDesc,lRat,nIndDesp)

	Local nY 			:= 0
	Local nYMes 		:= 0
	Local cRet 			:= cOutros
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
						cCampo2  := cAliasTmp+"->XX_VAL"+STRZERO(nYMes,3)
						&cCampo2 += (aAcrDcr[nY,3]/nIndDesp)
						If lNoRat
							&cCampo2 += (aAcrDcr[nY,5]/nIndDesp)
						EndIf
					EndIf
				Next
			EndIf

			If !lNoRat
				cCampo2  := cAliasTmp+"->XX_VAL"+STRZERO(_nI,3)
				&cCampo2 += nValor
			EndIf

		Else
			For nY := 1 To Len(aAcrDcr)
				nYMes := ASCAN(aAnoMes,{|x| x == aAcrDcr[nY,1]})
				If nYmes > 0
					cCampo2  := cAliasTmp+"->XX_VAL"+STRZERO(nYMes,3)
					&cCampo2 += aAcrDcr[nY,3]
					&cCampo2 += aAcrDcr[nY,5]
				EndIf
			Next
		EndIf
	EndIf

	(cAliasTmp)->(Msunlock())
	cRet := cOutros1

Return cRet


//NOTAS DE DEBITO DO CLIENTE - NDC - Emissão
USER FUNCTION VALNDCE(cNumContr,cCompt,_nI,aNDC)
	LOCAL nTotSE1	:= 0
	LOCAL cQuery	:= ""
	STATIC nCount	:= 1
	If aScan(aNDC,cNumContr+cCompt) == 0
		aAdd(aNDC,cNumContr+cCompt)

		cQuery += " SELECT
		cQuery += "    E1_VALOR," + CRLF
		cQuery += "    E1_NUM AS XX_NDC" + CRLF
		cQuery += "  FROM "+RETSQLNAME("SE1")+" SE1" + CRLF
		cQuery += " WHERE
		cQuery += "    SE1.D_E_L_E_T_ = ' ' AND " + CRLF
		cQuery += "    SE1.E1_FILIAL = '"+xFilial("SE1")+"' AND " + CRLF
		cQuery += "    SE1.E1_TIPO = 'NDC'" + CRLF
		//cQuery += "    AND SE1.E1_SALDO=0" + CRLF
		//cQuery += "    AND SUBSTRING(E1_EMISSAO,1,6) ='"+SUBSTR(cCompt,4,4)+SUBSTR(cCompt,1,2)+"'"
		cQuery += "    AND E1_XXCOMPE = '"+SUBSTR(cCompt,4,4)+SUBSTR(cCompt,1,2)+"'"
		cQuery += "    AND E1_XXCUSTO = '"+cNumContr+"'" + CRLF

		u_LogTxt("BKGCTR11-NDC.SQL")
		TCQUERY cQuery NEW ALIAS "QTMPXE1"
		u_LogTxt("BKGCTR11-NDC.SQL",cQuery)

		dbSelectArea("QTMPXE1")
		dbGoTop()

		nTotSE1  := 0
		Do While !QTMPXE1->(EOF())
			nTotSE1 += QTMPXE1->E1_VALOR
			QTMPXE1->(dbSkip())
		Enddo
		QTMPXE1->(Dbclosearea())
	EndIf

RETURN nTotSE1



//NOTAS DE DEBITO DO CLIENTE - NDC - Pagamento
USER FUNCTION VALNDCP(cNumContr,cCompt,_nI,aNDC)
	LOCAL nTotSE1	:= 0
	LOCAL cQuery	:= ""
	STATIC nCount	:= 1
	If aScan(aNDC,cNumContr+cCompt) == 0
		aAdd(aNDC,cNumContr+cCompt)

		cQuery += " SELECT
		cQuery += "    (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = E1_PREFIXO AND E5_NUMERO = E1_NUM  AND E5_TIPO = 'NDC' AND  E5_CLIFOR = E1_CLIENTE AND E5_LOJA = E1_LOJA AND E5_TIPODOC NOT IN ('MT','JR','CM','DC') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' AND E5_DTCANBX = ''" + CRLF
		cQuery += "    AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = ' ') AS XX_VALOR ," + CRLF
		cQuery += "    (SE1.E1_IRRF + SE1.E1_INSS + SE1.E1_PIS + SE1.E1_COFINS + SE1.E1_CSLL + SE1.E1_ISS) AS XX_IMPOST," + CRLF
		cQuery += "    (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = E1_PREFIXO AND E5_NUMERO = E1_NUM  AND E5_TIPO = 'NDC' AND  E5_CLIFOR = E1_CLIENTE AND E5_LOJA = E1_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = ''" + CRLF
		cQuery += "    AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = ' ') AS XX_E5DESC, " + CRLF
		cQuery += "    (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = E1_PREFIXO AND E5_NUMERO = E1_NUM  AND E5_TIPO = 'NDC' AND  E5_CLIFOR = E1_CLIENTE AND E5_LOJA = E1_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = ''" + CRLF
		cQuery += "    AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = ' ') AS XX_E5MULTA ," + CRLF
		cQuery += "    E1_NUM AS XX_NDC" + CRLF
		cQuery += "  FROM "+RETSQLNAME("SE1")+" SE1" + CRLF
		cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' AND " + CRLF
		cQuery += "    SE1.E1_TIPO = 'NDC'" + CRLF
		cQuery += "    AND SE1.E1_SALDO=0" + CRLF
		cQuery += "    AND SUBSTRING(E1_BAIXA,1,6) ='"+SUBSTR(cCompt,4,4)+SUBSTR(cCompt,1,2)+"'"
		cQuery += "    AND E1_XXCUSTO='"+cNumContr+"'" + CRLF

		u_LogMemo("BKGCTR11-NDC-"+STRZERO(_nI,3)+"-"+STRZERO(nCount++,3)+".SQL",cQuery)

		TCQUERY cQuery NEW ALIAS "QTMPXE1"
		dbSelectArea("QTMPXE1")
		dbGoTop()

		nTotSE1  := 0
		Do While !QTMPXE1->(EOF())
			nTotSE1 += QTMPXE1->XX_VALOR - QTMPXE1->XX_E5DESC + QTMPXE1->XX_E5MULTA
			QTMPXE1->(dbSkip())
		Enddo
		QTMPXE1->(Dbclosearea())
	EndIf

RETURN nTotSE1

//BUSCA CODIGO DA EMPRESA RUBI
USER FUNCTION BUSCAEMPR(cCUSTO)
	LOCAL cCODEMP 	:= ""
	LOCAL nScan		:= 0
	LOCAL _SQL 		:= ""

	nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(cCUSTO) })
	IF nScan > 0
		cCODEMP := SUBSTR(aConsorcio[nScan,2],1,2)
	ELSE

		_SQL := "SELECT TOP 1 [NumEmp]  FROM [BKIntegraRubi].[dbo].[CUSTOSIGA]"
		_SQL += " WHERE ccSIGA='"+cCUSTO+"'"

		TCQUERY _SQL NEW ALIAS "QCDEMP"

		dbSelectArea("QCDEMP")
		QCDEMP->(dbGoTop())
		DO WHILE QCDEMP->(!EOF())
			cCODEMP := STR(QCDEMP->NumEmp)
			QCDEMP->(dbSkip())
		ENDDO
		QCDEMP->(Dbclosearea())

	ENDIF

	IF VAL(cCODEMP) < 1
		cCODEMP := SUBSTR(FWCodEmp(),1,2)
	ENDIF

RETURN cCODEMP
