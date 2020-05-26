#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
 
/*/{Protheus.doc} BKGCTR18
BK - Informações de Contratos Vigentes e encerrados por ano - Licitação Mod. 2
@Return
@author Adilson do Prado / Marcos Bispo Abrahão
@since 22/09/16 Rev 26/05/20
@version P12
/*/

User Function BKGCTR18()

Local aCampos       := {}
Local aCabs         := {}
Local aPlans        := {}
Local aDbf			:= {}

Local oTmpTb1
Local oTmpTb2
Local oTmpTb3
Local oTmpTb4

Private cPerg       := "BKGCTR18"
Private cTitulo     := "Informações de Contratos Vigentes e encerrados "
Private cTitulo1    := "Informações de Contratos Vigentes e encerrados "
Private cTitulo2    := "Informações de Contratos Vigentes e encerrados "
Private cTitulo3    := "Informações de Contratos Vigentes e encerrados "
Private cCompet     := STRZERO(YEAR(dDataBase),4)+STRZERO(Month(dDataBase),2) 
Private cAliasTmp   := "QTMP"
Private cAliasTmp1  := "QTMP1"
Private cAliasTmp2  := "QTMP2"
Private cAliasTmp3  := "QTMP3"
Private cANOTAB		:= STRZERO(YEAR(dDataBase),4)
Private cANOTAB1	:= STRZERO(YEAR(dDataBase),4)
Private cANOTAB2	:= STRZERO(YEAR(dDataBase),4)
Private cANOTAB3	:= STRZERO(YEAR(dDataBase),4)

If !MsgYesNo("Confirma a execução do relatório 'Licitação Mod. 2'?","BKFINR18")
   Return
EndIf
 
aCabs    := {}
aCampos  := {}
nomeprog := ""
cTitulo  := "Tabela 1 - Contratos Vigentes em "+cANOTAB

cANOTAB		:= STRZERO(VAL(cANOTAB)-1,4)

aDbf    := {}
Aadd( aDbf, { 'XX_CONTRAT','C',10,0})
Aadd( aDbf, { 'XX_NOMCLI' ,'C',100,0})
Aadd( aDbf, { 'XX_XXDESC' ,'C',100,0})
Aadd( aDbf, { 'XX_DTASSI' ,'D',8,0 })
Aadd( aDbf, { 'XX_VIGMESE','N',8,0 }) 
Aadd( aDbf, { 'XX_DENCER' ,'D',10,0 })
Aadd( aDbf, { 'XX_VMENSAL','N',14,2 })
Aadd( aDbf, { 'XX_VALTOT' ,'N',14,2 })
Aadd( aDbf, { 'XX_TMPCONT','N',10,0 }) 
Aadd( aDbf, { 'XX_VALFAT' ,'N',14,2 })

///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,cAliasTmp,.f.,.f. )
oTmpTb1 := FWTemporaryTable():New(cAliasTmp)
oTmpTb1:SetFields( aDbf )
oTmpTb1:Create()

// Campos para exportar
AADD(aCampos,cAliasTmp+"->XX_CONTRAT")
AADD(aCabs  ,"Contrato" )

AADD(aCampos,cAliasTmp+"->XX_NOMCLI")
AADD(aCabs  ,"Nome do Órgão/Empresa (A)")

AADD(aCampos,cAliasTmp+"->XX_XXDESC")
AADD(aCabs  ,"N° Contrato ou aditivo (B)")

AADD(aCampos,cAliasTmp+"->XX_DTASSI")
AADD(aCabs  ,"Data de assinatura (C)")

AADD(aCampos,cAliasTmp+"->XX_VIGMESE")
AADD(aCabs  ,"Prazo vigência do contrato ou aditivo (meses) (D)")

AADD(aCampos,cAliasTmp+"->XX_DENCER")
AADD(aCabs  ,"Data de encerramento do contrato ou aditivo (E)")

AADD(aCampos,cAliasTmp+"->XX_VMENSAL")
AADD(aCabs  ,"Valor mensal (F)")

AADD(aCampos,cAliasTmp+"->XX_VALTOT")
AADD(aCabs  ,"Valor total do contrato ou aditivo (G)=(D)x(F)")

AADD(aCampos,cAliasTmp+"->XX_TMPCONT")
AADD(aCabs  ,"Tempo de contrato ou aditivo "+cANOTAB+" (meses) (H)")

AADD(aCampos,cAliasTmp+"->XX_VALFAT")
AADD(aCabs  ,"Valor Faturado "+cANOTAB+" (I)")

cANOTAB1 := STRZERO(VAL(cANOTAB)-1,4)

//cArqTmp1 := CriaTrab( aDbf, .t. )
//dbUseArea( .t.,NIL,cArqTmp1,cAliasTmp1,.f.,.f. )
oTmpTb2 := FWTemporaryTable():New(cAliasTmp1)
oTmpTb2:SetFields( aDbf )
oTmpTb2:Create()

aCabs1    := {}
aCampos1  := {}
nomeprog1 := ""
cTitulo1  := "Tabela 2 - Contratos encerrados em "+cANOTAB1

// Campos para exportar
AADD(aCampos1,cAliasTmp1+"->XX_CONTRAT")
AADD(aCabs1  ,"Contrato" )

AADD(aCampos1,cAliasTmp1+"->XX_NOMCLI")
AADD(aCabs1  ,"Nome do Órgão/Empresa (A)")

AADD(aCampos1,cAliasTmp1+"->XX_XXDESC")
AADD(aCabs1  ,"N° Contrato ou aditivo (B)")

AADD(aCampos1,cAliasTmp1+"->XX_DTASSI")
AADD(aCabs1  ,"Data de assinatura (C)")

AADD(aCampos1,cAliasTmp1+"->XX_VIGMESE")
AADD(aCabs1  ,"Prazo vigência do contrato ou aditivo (meses) (D)")

AADD(aCampos1,cAliasTmp1+"->XX_DENCER")
AADD(aCabs1  ,"Data de encerramento do contrato ou aditivo (E)")

AADD(aCampos1,cAliasTmp1+"->XX_VMENSAL")
AADD(aCabs1  ,"Valor mensal (F)")

AADD(aCampos1,cAliasTmp1+"->XX_VALTOT")
AADD(aCabs1  ,"Valor total do contrato ou aditivo (G)=(D)x(F)")

AADD(aCampos1,cAliasTmp1+"->XX_TMPCONT")
AADD(aCabs1  ,"Tempo de contrato ou aditivo "+cANOTAB1+" (meses) (H)")

AADD(aCampos1,cAliasTmp1+"->XX_VALFAT")
AADD(aCabs1  ,"Valor Faturado "+cANOTAB1+" (I)")


cANOTAB2 := cANOTAB

//cArqTmp2 := CriaTrab( aDbf, .t. )
//dbUseArea( .t.,NIL,cArqTmp2,cAliasTmp2,.f.,.f. )
oTmpTb3 := FWTemporaryTable():New(cAliasTmp2)
oTmpTb3:SetFields( aDbf )
oTmpTb3:Create()


aCampos2  := {}
cTitulo2  := "Tabela 3 - Contratos encerrados em "+cANOTAB2

// Campos para exportar
AADD(aCampos2,cAliasTmp2+"->XX_CONTRAT")
AADD(aCampos2,cAliasTmp2+"->XX_NOMCLI")
AADD(aCampos2,cAliasTmp2+"->XX_XXDESC")
AADD(aCampos2,cAliasTmp2+"->XX_DTASSI")
AADD(aCampos2,cAliasTmp2+"->XX_VIGMESE")
AADD(aCampos2,cAliasTmp2+"->XX_DENCER")
AADD(aCampos2,cAliasTmp2+"->XX_VMENSAL")
AADD(aCampos2,cAliasTmp2+"->XX_VALTOT")
AADD(aCampos2,cAliasTmp2+"->XX_TMPCONT")
AADD(aCampos2,cAliasTmp2+"->XX_VALFAT")

//cArqTmp3 := CriaTrab( aDbf, .t. )
//dbUseArea( .t.,NIL,cArqTmp3,cAliasTmp3,.f.,.f. )
oTmpTb4 := FWTemporaryTable():New(cAliasTmp3)
oTmpTb4:SetFields( aDbf )
oTmpTb4:Create()

aCampos3  := {}
cTitulo3  := "Tabela 4 - Contratos encerrados em "+cANOTAB3

// Campos para exportar
AADD(aCampos3,cAliasTmp3+"->XX_CONTRAT")
AADD(aCampos3,cAliasTmp3+"->XX_NOMCLI")
AADD(aCampos3,cAliasTmp3+"->XX_XXDESC")
AADD(aCampos3,cAliasTmp3+"->XX_DTASSI")
AADD(aCampos3,cAliasTmp3+"->XX_VIGMESE")
AADD(aCampos3,cAliasTmp3+"->XX_DENCER")
AADD(aCampos3,cAliasTmp3+"->XX_VMENSAL")
AADD(aCampos3,cAliasTmp3+"->XX_VALTOT")
AADD(aCampos3,cAliasTmp3+"->XX_TMPCONT")
AADD(aCampos3,cAliasTmp3+"->XX_VALFAT")


ProcRegua(1)
Processa( {|| ProcQuery() })

AADD(aPlans,{cAliasTmp ,"Tabela 1","",cTitulo  ,aCampos ,aCabs ,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
AADD(aPlans,{cAliasTmp1,"Tabela 2","",cTitulo1 ,aCampos1,aCabs1,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
AADD(aPlans,{cAliasTmp2,"Tabela 3","",cTitulo2 ,aCampos2,aCabs ,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
AADD(aPlans,{cAliasTmp3,"Tabela 4","",cTitulo3 ,aCampos3,aCabs ,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
U_GeraXlsx(aPlans,cTitulo,cPerg,.F.)

oTmpTb1:Delete()
oTmpTb2:Delete()
oTmpTb3:Delete()
oTmpTb4:Delete()

///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())

///FErase(cArqTmp1+GetDBExtension())
///FErase(cArqTmp1+OrdBagExt())

///FErase(cArqTmp2+GetDBExtension())
///FErase(cArqTmp2+OrdBagExt())

///FErase(cArqTmp3+GetDBExtension())
///FErase(cArqTmp3+OrdBagExt())

Return


Static Function ProcQuery
Local DtCorte := CTOD("")
Local nVALFAT := 0

DtCorte := MonthSub(dDataBase, 1)

DtCorte := LastDate(DtCorte)          

	dbSelectArea("CN9")
	CN9->(DBSETORDER(1))
	CN9->(DBGOTOP())
	ProcRegua(CN9->(LASTREC()))
	DO WHILE CN9->(!EOF())
	
		IncProc("Consultando banco de dados...")

		IF CN9->CN9_SITUAC == '10'
			CN9->(dbSkip())
			Loop
		ENDIF
		
		cQuery := " SELECT SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2) AS CNF_COMPET,CNF_VLPREV,CNF_VLREAL,"
		cQuery += " CNF_DTVENC FROM "+RETSQLNAME("CNF")+" CNF"
		cQuery += " WHERE CNF.D_E_L_E_T_='' AND CNF.CNF_CONTRA='"+ALLTRIM(CN9->CN9_NUMERO)+"' AND CNF.CNF_REVISA='"+ALLTRIM(CN9->CN9_REVISA)+"' "
		cQuery += " ORDER BY CNF_DTVENC" 
	 
		TCQUERY cQuery NEW ALIAS "QCNF"
		TCSETFIELD("QCNF","CNF_DTVENC","D",8,0)	
	
		nPRAZOMES := 0
		nVTOTAL   := 0
		nSALDOAT  := 0
		nTMPCONT  := 0
		nTMPCONT1  := 0
		nTMPCONT2  := 0
		nTMPCONT3  := 0
		dbSelectArea("QCNF")
		QCNF->(dbGoTop())
	
		dDataI		:= CTOD("")
		dDataI		:= QCNF->CNF_DTVENC
		dDataFinal	:= CTOD("")
		aCompet		:= {}
		dUltimoFat 	:= CTOD("")
		
		DO WHILE QCNF->(!EOF())
			nVTOTAL   += QCNF->CNF_VLPREV
			dDataFinal	:= QCNF->CNF_DTVENC
			IF ASCAN(aCompet, {|x| x[1]==QCNF->CNF_COMPET}) == 0
				AADD(aCompet,{QCNF->CNF_COMPET})
			ENDIF
			IF QCNF->CNF_VLREAL > 0 .AND. QCNF->CNF_DTVENC > dUltimoFat
				dUltimoFat 	:= QCNF->CNF_DTVENC
			ENDIF
			QCNF->(DBSKIP())
		ENDDO

		FOR _IX := 1 TO LEN(aCompet)
			IF SUBSTR(aCompet[_IX,1],1,4) == cANOTAB
				++nTMPCONT
			ENDIF
			IF SUBSTR(aCompet[_IX,1],1,4) == cANOTAB1
				++nTMPCONT1
			ENDIF
			IF SUBSTR(aCompet[_IX,1],1,4) == cANOTAB2
				++nTMPCONT2
			ENDIF
			IF SUBSTR(aCompet[_IX,1],1,4) == cANOTAB
				++nTMPCONT3
			ENDIF
		NEXT
	    
		IF CN9->CN9_SITUAC <> '05'  .and. !EMPTY(dUltimoFat)
			nPRAZOMES += DateDiffMonth( dDataI , dUltimoFat )
		ELSE
			nPRAZOMES += DateDiffMonth( dDataI , dDataFinal )
		ENDIF
		
		IF nPRAZOMES == 0
			nPRAZOMES := 1
        ENDIF

		QCNF->(dbCloseArea())
	    
	    cENDER := TRIM(Posicione("SA1",1,xFilial("SA1")+CN9->CN9_CLIENT+CN9->CN9_LOJACL,"A1_END")) 
	    cENDER += TRIM(SA1->A1_END)+' - '+TRIM(SA1->A1_BAIRRO)+' - '+TRIM(SA1->A1_MUN)+' - '+SA1->A1_EST   
	
	    dtFIM  := CTOD("")
	    dtFIM  := MonthSum( CN9->CN9_DTINIC , nPRAZOMES ) 
	    dtFIM  := DaySum( dtFIM  , 1 )

		IF STRZERO(YEAR(dtFIM),4) < cANOTAB1
			CN9->(dbSkip())
			Loop
    	ENDIF
    	
		//*********Faturamento do Contrato
 //		cQuery := " SELECT SUBSTRING(CNF.CNF_COMPET,4,4) AS CNF_COMPET,SUM(D2_TOTAL) AS D2_TOTAL " 
		cQuery := " SELECT SUBSTRING(F2_EMISSAO,1,4) AS CNF_COMPET,SUM(F2_VALBRUT) AS F2_VALBRUT " 
		cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"
	    cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9.CN9_NUMERO = CNF.CNF_CONTRA AND CN9.CN9_REVISA = CNF.CNF_REVISA AND  CN9.CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"
		cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"
		cQuery += " AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ''"
		cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA"
		cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CND_PARCEL = CNF_PARCEL AND CNA_NUMERO = CND_NUMERO AND CND_REVISA = CNF_REVISA"
		cQuery += "      AND  CND_FILIAL = '"+xFilial("CND")+"' AND  CND.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON CND_PEDIDO = C5_NUM"
		cQuery += "      AND  C5_FILIAL = CND_FILIAL AND SC5.D_E_L_E_T_ = ' '"
		cQuery += "	LEFT JOIN "+RETSQLNAME("SF2")+ " SF2 ON C5_NOTA = F2_DOC AND C5_SERIE=F2_SERIE AND C5_CLIENTE=F2_CLIENTE AND C5_LOJACLI=F2_LOJA"  
		cQuery += "      AND  F2_FILIAL = CND_FILIAL AND SF2.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE CNF.D_E_L_E_T_=''  AND CN9_SITUAC <> '10'"
		cQuery += "	 AND CNF_CONTRA ='"+ALLTRIM(CN9->CN9_NUMERO)+"'"
//		cQuery += " GROUP BY SUBSTRING(CNF.CNF_COMPET,4,4)"
		cQuery += " GROUP BY SUBSTRING(F2_EMISSAO,1,4)"
	
		TCQUERY cQuery NEW ALIAS "QCN9"
	
		nVALFAT  := 0
		nVALFAT1 := 0
		nVALFAT2 := 0
		nVALFAT3 := 0
		dbSelectArea("QCN9")
		QCN9->(dbGoTop())
		DO WHILE QCN9->(!EOF())
			IF QCN9->CNF_COMPET == cANOTAB
		 		nVALFAT := QCN9->F2_VALBRUT
		 	ENDIF
			IF QCN9->CNF_COMPET == cANOTAB1
		 		nVALFAT1 := QCN9->F2_VALBRUT
		 	ENDIF
			IF QCN9->CNF_COMPET == cANOTAB2
		 		nVALFAT2 := QCN9->F2_VALBRUT
		 	ENDIF
			IF QCN9->CNF_COMPET == cANOTAB
		 		nVALFAT3 := QCN9->F2_VALBRUT
		 	ENDIF
			QCN9->(DBSKIP())
		ENDDO
	    QCN9->(Dbclosearea())
	    

		//********* FATURAMENTO - Inclusão para medição avulso
		cQuery2 := "SELECT SUM(F2_VALBRUT) AS F2_VALBRUT, SUBSTRING(F2_EMISSAO,1,4) AS F2_EMISSAO"
		cQuery2 += " FROM "+RETSQLNAME("SC5")+" SC5" 
	    cQuery2 += " INNER JOIN "+RETSQLNAME("SF2")+" SF2 ON C5_NOTA = F2_DOC AND C5_SERIE=F2_SERIE AND C5_CLIENTE=F2_CLIENTE AND C5_LOJACLI=F2_LOJA"
		cQuery2 += "  AND SF2.F2_FILIAL = SC5.C5_FILIAL AND SF2.D_E_L_E_T_ = ' '"
	    cQuery2 += " WHERE SC5.D_E_L_E_T_ = ' ' AND SC5.C5_MDCONTR='' 
    	cQuery2 += "  AND C5_ESPECI1 ='"+ALLTRIM(CN9->CN9_NUMERO)+"'"
		cQuery2 += " GROUP BY SUBSTRING(F2_EMISSAO,1,4)"
	    
		TCQUERY cQuery2 NEW ALIAS "QSC5"
	
		nFATAVU  := 0
		nFATAVU1 := 0
		nFATAVU2 := 0
		nFATAVU3 := 0
		dbSelectArea("QSC5")
		QSC5->(dbGoTop())
		DO WHILE QSC5->(!EOF())
			IF QSC5->F2_EMISSAO == cANOTAB
		 		nFATAVU := QSC5->F2_VALBRUT
		 	ENDIF
			IF QSC5->F2_EMISSAO == cANOTAB1
		 		nFATAVU1 := QSC5->F2_VALBRUT
		 	ENDIF
			IF QSC5->F2_EMISSAO == cANOTAB2
		 		nFATAVU2 := QSC5->F2_VALBRUT
		 	ENDIF
			IF QSC5->F2_EMISSAO == cANOTAB
		 		nVALFAT3 := QSC5->F2_VALBRUT
		 	ENDIF
			QSC5->(DBSKIP())
		ENDDO
	    QSC5->(Dbclosearea())
	    
		nVALFAT  += nFATAVU	    
		nVALFAT1 += nFATAVU1	    
		nVALFAT2 += nFATAVU2	    
		nVALFAT3 += nFATAVU3	    
	    
	    IF STRZERO(YEAR(dtFIM),4) == cANOTAB2  .AND. nVALFAT1 > 0  .AND. STRZERO(YEAR(dUltimoFat),4) < cANOTAB2
			nPRAZOMES += DateDiffMonth( dDataI , dUltimoFat )
			IF nPRAZOMES == 0
				nPRAZOMES := 1
        	ENDIF
	    	dtFIM  := CTOD("")
	    	dtFIM  := MonthSum( CN9->CN9_DTINIC , nPRAZOMES ) 
	    	dtFIM  := DaySum( dtFIM  , 1 )
	    ENDIF

		IF dtFIM > DtCorte 
			dbSelectArea(cAliasTmp)
			Reclock(cAliasTmp,.T.)
			(cAliasTmp)->XX_CONTRAT	:= CN9->CN9_NUMERO
			(cAliasTmp)->XX_NOMCLI	:= SA1->A1_NOME
			(cAliasTmp)->XX_XXDESC	:= CN9->CN9_XXDESC
			(cAliasTmp)->XX_DTASSI	:= CN9->CN9_DTASSI
			(cAliasTmp)->XX_VIGMESE	:= nPRAZOMES 
			(cAliasTmp)->XX_DENCER	:= dtFIM
			(cAliasTmp)->XX_VMENSAL := nVTOTAL/nPRAZOMES
			(cAliasTmp)->XX_VALTOT	:= nVTOTAL
			(cAliasTmp)->XX_TMPCONT := nTMPCONT 
			(cAliasTmp)->XX_VALFAT  := nVALFAT
			(cAliasTmp)->(Msunlock())
		ELSEIF STRZERO(YEAR(dtFIM),4) == cANOTAB1
			dbSelectArea(cAliasTmp1)
			Reclock(cAliasTmp1,.T.)
			(cAliasTmp1)->XX_CONTRAT := CN9->CN9_NUMERO
			(cAliasTmp1)->XX_NOMCLI	 := SA1->A1_NOME
			(cAliasTmp1)->XX_XXDESC	 := CN9->CN9_XXDESC
			(cAliasTmp1)->XX_DTASSI	 := CN9->CN9_DTASSI
			(cAliasTmp1)->XX_VIGMESE := nPRAZOMES 
			(cAliasTmp1)->XX_DENCER	 := dtFIM
			(cAliasTmp1)->XX_VMENSAL := nVTOTAL/nPRAZOMES
			(cAliasTmp1)->XX_VALTOT	 := nVTOTAL
			(cAliasTmp1)->XX_TMPCONT := nTMPCONT1 
			(cAliasTmp1)->XX_VALFAT  := nVALFAT1
			(cAliasTmp1)->(Msunlock())
		ELSEIF STRZERO(YEAR(dtFIM),4) == cANOTAB2
			dbSelectArea(cAliasTmp2)
			Reclock(cAliasTmp2,.T.)
			(cAliasTmp2)->XX_CONTRAT := CN9->CN9_NUMERO
			(cAliasTmp2)->XX_NOMCLI	 := SA1->A1_NOME
			(cAliasTmp2)->XX_XXDESC	 := CN9->CN9_XXDESC
			(cAliasTmp2)->XX_DTASSI	 := CN9->CN9_DTASSI
			(cAliasTmp2)->XX_VIGMESE := nPRAZOMES 
			(cAliasTmp2)->XX_DENCER	 := dtFIM
			(cAliasTmp2)->XX_VMENSAL := nVTOTAL/nPRAZOMES
			(cAliasTmp2)->XX_VALTOT	 := nVTOTAL
			(cAliasTmp2)->XX_TMPCONT := nTMPCONT2 
			(cAliasTmp2)->XX_VALFAT  := nVALFAT2
			(cAliasTmp2)->(Msunlock())
		ELSEIF dtFIM <= DtCorte 
			dbSelectArea(cAliasTmp3)
			Reclock(cAliasTmp3,.T.)
			(cAliasTmp3)->XX_CONTRAT := CN9->CN9_NUMERO
			(cAliasTmp3)->XX_NOMCLI	 := SA1->A1_NOME
			(cAliasTmp3)->XX_XXDESC	 := CN9->CN9_XXDESC
			(cAliasTmp3)->XX_DTASSI	 := CN9->CN9_DTASSI
			(cAliasTmp3)->XX_VIGMESE := nPRAZOMES 
			(cAliasTmp3)->XX_DENCER	 := dtFIM
			(cAliasTmp3)->XX_VMENSAL := nVTOTAL/nPRAZOMES
			(cAliasTmp3)->XX_VALTOT	 := nVTOTAL
			(cAliasTmp3)->XX_TMPCONT := nTMPCONT3 
			(cAliasTmp3)->XX_VALFAT  := nVALFAT3
			(cAliasTmp3)->(Msunlock())
		ENDIF
	
		CN9->(DBSKIP())
	ENDDO
	
Return




