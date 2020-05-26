#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR15()
BK - Informações de Contratos para Licitação

@author Adilson do Prado
@since 02/12/14 Rev 26/05/20
@version P12
@return Nil
/*/

User Function BKGCTR15()
Local aTitulos,aCampos,aCabs,aPlans
Local aDbf 		    := {} 
Local oTmpTb1

Private cTitulo     := "Relatório de Informações dos Contratos para Licitações - Competência: "+STRZERO(Month(dDataBase),2)+"/"+STRZERO(YEAR(dDataBase),4) 
Private cCompet     := STRZERO(YEAR(dDataBase),4)+STRZERO(Month(dDataBase),2) 
Private cPerg    	:= "BKGCTR15"

Aadd( aDbf, { 'XX_CONTRAT', 'C', 10,00 } )
Aadd( aDbf, { 'XX_NOMCLI', 'C', 100,00 } )
Aadd( aDbf, { 'XX_ENDER','C', 200,00 } )
Aadd( aDbf, { 'XX_TELS','C', 30,00 } )
Aadd( aDbf, { 'XX_XXDESC',  'C', 100,00 } )
Aadd( aDbf, { 'XX_CODOBJ','M', 10,0 } )
Aadd( aDbf, { 'XX_UF','C', 2,0 } )
Aadd( aDbf, { 'XX_DTINIC','D', 8,0 } )
Aadd( aDbf, { 'XX_DTASSI','D', 8,0 } )
Aadd( aDbf, { 'XX_PRAZO','C', 15,0 } ) 
Aadd( aDbf, { 'XX_DTFIM','D', 8,0 } )
Aadd( aDbf, { 'XX_VTOTAL','N', 14,2 } )
Aadd( aDbf, { 'XX_PEXEC','N', 4,0 } )
Aadd( aDbf, { 'XX_PAEXEC','N', 4,0 } )
Aadd( aDbf, { 'XX_SALDOAT','N', 14,2 } )

///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,'TRB',.f.,.f. )

oTmpTb1 := FWTemporaryTable():New( "TRB" ) 
oTmpTb1:SetFields( aDbf )
oTmpTb1:Create()

ProcRegua(1)
Processa( {|| ProcQuery() })

aCabs   := {}
aCampos := {}
aTitulos:= {}
aPlans  := {}
   
//nomeprog := "BKGCTR15/"+TRIM(SUBSTR(cUsuario,7,15))
//AADD(aTitulos,nomeprog+" - "+cTitulo)

AADD(aCampos,"TRB->XX_CONTRAT")
AADD(aCabs  ,"Nº SIGA")

AADD(aCampos,"TRB->XX_NOMCLI")
AADD(aCabs  ,"Contratante")

AADD(aCampos,"TRB->XX_ENDER")
AADD(aCabs  ,"Endereço Completo do Cliente")

AADD(aCampos,"TRB->XX_TELS")
AADD(aCabs  ,"Telefone do Cliente")

AADD(aCampos,"TRB->XX_XXDESC")
AADD(aCabs  ,"Nº Contrato")

AADD(aCampos,"U_CN9OBJ(TRB->XX_CODOBJ)")
AADD(aCabs  ,"Objeto")

AADD(aCampos,"TRB->XX_UF")
AADD(aCabs  ,"Local da Obra/Seviços")

AADD(aCampos,"TRB->XX_DTINIC")
AADD(aCabs  ,"Data de Início")

AADD(aCampos,"TRB->XX_DTASSI")
AADD(aCabs  ,"Data de Assinatura")

AADD(aCampos,"TRB->XX_PRAZO")
AADD(aCabs  ,"Prazo de Execução")

AADD(aCampos,"TRB->XX_DTFIM")
AADD(aCabs  ,"Data Fim do Contrato")

AADD(aCampos,"TRB->XX_VTOTAL")
AADD(aCabs  ,"Valor da Obra/Serviço")

AADD(aCampos,"TRB->XX_PEXEC")
AADD(aCabs  ,"% executado")

AADD(aCampos,"TRB->XX_PAEXEC")
AADD(aCabs  ,"% a Executar")

AADD(aCampos,"TRB->XX_SALDOAT")
AADD(aCabs  ,"Situação Atual")

//ProcRegua(TRB->(LASTREC()))
//Processa( {|| U_GeraCSV("TRB",cPerg,aTitulos,aCampos,aCabs,,,,.F.)})

AADD(aPlans,{"TRB",cPerg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
U_GeraXlsx(aPlans,cTitulo,cPerg,.T.)

oTmpTb1:Delete()

Return


Static Function ProcQuery

dbSelectArea("CN9")
CN9->(DBSETORDER(1))
CN9->(DBGOTOP())
DO WHILE CN9->(!EOF())
	IF CN9->CN9_SITUAC <> '05'
		CN9->(dbSkip())
		Loop
	ENDIF
	cQuery := " SELECT SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2) AS CNF_COMPET,CNF_VLPREV,"
	cQuery += " CNF_DTVENC FROM "+RETSQLNAME("CNF")+" CNF"
	cQuery += " WHERE CNF.D_E_L_E_T_='' AND CNF.CNF_CONTRA='"+ALLTRIM(CN9->CN9_NUMERO)+"' AND CNF.CNF_REVISA='"+ALLTRIM(CN9->CN9_REVISA)+"' " 
	cQuery += " ORDER BY CNF_DTVENC" 
 
	TCQUERY cQuery NEW ALIAS "QCNF"
	TCSETFIELD("QCNF","CNF_DTVENC","D",8,0)	

	nPRAZOMES := 1
	nVTOTAL   := 0
	nSALDOAT  := 0
	dbSelectArea("QCNF")
	QCNF->(dbGoTop())

	dDataI		:= CTOD("")
	dDataI		:= QCNF->CNF_DTVENC
	dDataFinal	:= CTOD("")
	
	DO WHILE QCNF->(!EOF())
		nVTOTAL   += QCNF->CNF_VLPREV
		IF QCNF->CNF_COMPET >= cCompet
			nSALDOAT  += QCNF->CNF_VLPREV
		ENDIF
		dDataFinal	:= QCNF->CNF_DTVENC
		QCNF->(DBSKIP())
	ENDDO
    
	nPRAZOMES += DateDiffMonth( dDataI , dDataFinal )
	
	QCNF->(dbCloseArea())

    
    IF nSALDOAT == 0
		CN9->(dbSkip())
		Loop
    ENDIF
    
    cENDER := TRIM(Posicione("SA1",1,xFilial("SA1")+CN9->CN9_CLIENT+CN9->CN9_LOJACL,"A1_END")) 
    cENDER := TRIM(SA1->A1_END)+' - '+TRIM(SA1->A1_BAIRRO)+' - '+TRIM(SA1->A1_MUN)+' - '+SA1->A1_EST   

    dtFIM  := CTOD("")
    dtFIM  := MonthSum( CN9->CN9_DTINIC , nPRAZOMES ) 
    dtFIM  := DaySum( dtFIM  , 1 )

	dbSelectArea("TRB")
	Reclock("TRB",.T.)
	TRB->XX_CONTRAT := CN9->CN9_NUMERO
	TRB->XX_NOMCLI  := SA1->A1_NOME
	TRB->XX_ENDER   := cENDER
	TRB->XX_TELS    := CN9->CN9_XXTELS
	TRB->XX_XXDESC  := CN9->CN9_XXDESC
	TRB->XX_CODOBJ  := CN9->CN9_CODOBJ 
	TRB->XX_UF      := SA1->A1_EST
	TRB->XX_DTINIC  := CN9->CN9_DTINIC
	TRB->XX_DTASSI  := CN9->CN9_DTASSI
	TRB->XX_PRAZO   := STR(nPRAZOMES,4)+" Meses"
	TRB->XX_DTFIM   := dtFIM
	TRB->XX_VTOTAL  := nVTOTAL
	TRB->XX_PEXEC   := ((nVTOTAL - nSALDOAT) * 100) / nVTOTAL
	TRB->XX_PAEXEC  := (nSALDOAT * 100) / nVTOTAL
	TRB->XX_SALDOAT := nSALDOAT
	TRB->(Msunlock())

	CN9->(DBSKIP())
ENDDO
Return



User Function xBKGCTR15()
Local aTitulos,aCampos,aCabs,aPlans
Local aDbf 		    := {} 
Local oTmpTb1

Private cTitulo     := "Relatorio de Informações dos Contratos para Licitações - Competência: "+STRZERO(Month(dDataBase),2)+"/"+STRZERO(YEAR(dDataBase),4) 
Private cCompet     := STRZERO(YEAR(dDataBase),4)+STRZERO(Month(dDataBase),2) 
Private cPerg    	:= "BKGCTR15"
Private aSITUAC 	:= {}

AADD(aSITUAC,"01 - Cancelado")
AADD(aSITUAC,"02 - Em Elaboração")
AADD(aSITUAC,"03 - Emitido")
AADD(aSITUAC,"04 - Em Aprovação")
AADD(aSITUAC,"05 - Vigente")
AADD(aSITUAC,"06 - Paralisado")
AADD(aSITUAC,"07 - Sol. Finalização")
AADD(aSITUAC,"08 - Finalizado")
AADD(aSITUAC,"09 - Resisão")
AADD(aSITUAC,"10 - Revisado")

Aadd( aDbf, { 'XX_NOMCLI', 'C', 100,00 } )
Aadd( aDbf, { 'XX_ENDER','C', 200,00 } )
Aadd( aDbf, { 'XX_TELS','C', 30,00 } )
Aadd( aDbf, { 'XX_CNPJ',  'C', 14,00 } )
Aadd( aDbf, { 'XX_XXDESC',  'C', 100,00 } )
Aadd( aDbf, { 'XX_CONTRAT', 'C', 10,00 } )
Aadd( aDbf, { 'XX_DTINIC','D', 8,0 } )
Aadd( aDbf, { 'XX_DTFIM','D', 8,0 } )
Aadd( aDbf, { 'XX_PRAZO','C', 15,0 } ) 
Aadd( aDbf, { 'XX_VLIQ','N', 14,2 } )
Aadd( aDbf, { 'XX_VFAT','N', 14,2 } )
Aadd( aDbf, { 'XX_CODOBJ','M', 10,0 } )
Aadd( aDbf, { 'XX_MUNIC','C', 60,0 } )
Aadd( aDbf, { 'XX_SITUAC','C', 40,0 } )

///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,'TRB',.f.,.f. )

oTmpTb1 := FWTemporaryTable():New( "TRB" ) 
oTmpTb1:SetFields( aDbf )
oTmpTb1:Create()

ProcRegua(1)
Processa( {|| xProcQuery() })

aCabs   := {}
aCampos := {}
aTitulos:= {}
aPlans  := {}
   
//nomeprog := "BKGCTR15/"+TRIM(SUBSTR(cUsuario,7,15))
//AADD(aTitulos,nomeprog+" - "+cTitulo)

AADD(aCampos,"TRB->XX_NOMCLI")
AADD(aCabs  ,"Cliente / Contratante")

AADD(aCampos,"TRB->XX_ENDER")
AADD(aCabs  ,"Endereço Completo do Cliente")

AADD(aCampos,"TRB->XX_TELS")
AADD(aCabs  ,"Telefone do Cliente")

AADD(aCampos,"TRB->XX_CNPJ")
AADD(aCabs  ,"CNPJ")

AADD(aCampos,"TRB->XX_XXDESC")
AADD(aCabs  ,"Nº Contrato")

AADD(aCampos,"TRB->XX_CONTRAT")
AADD(aCabs  ,"Nº SIGA")

AADD(aCampos,"TRB->XX_DTINIC")
AADD(aCabs  ,"Data de Início")

AADD(aCampos,"TRB->XX_DTFIM")
AADD(aCabs  ,"Data de Termino")

AADD(aCampos,"TRB->XX_PRAZO")
AADD(aCabs  ,"Prazo de Execução")

AADD(aCampos,"TRB->XX_VLIQ")
AADD(aCabs  ,"Valor Total Líquido")

AADD(aCampos,"TRB->XX_VFAT")
AADD(aCabs  ,"Valor Total Faturado")

AADD(aCampos,"U_CN9OBJ(TRB->XX_CODOBJ)")
AADD(aCabs  ,"Objeto")

AADD(aCampos,"TRB->XX_MUNIC")
AADD(aCabs  ,"Município do Cliente")

AADD(aCampos,"TRB->XX_SITUAC")
AADD(aCabs  ,"Situação atual do Contrato")
  
//ProcRegua(TRB->(LASTREC()))
//Processa( {|| U_GeraCSV("TRB",cPerg,aTitulos,aCampos,aCabs,,,,.F.)})

AADD(aPlans,{"TRB",cPerg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
U_GeraXlsx(aPlans,cTitulo,cPerg,.T.)

oTmpTb1:Delete()

Return


Static Function xProcQuery
LOCAL cSITUAC := ""

dbSelectArea("CN9")
CN9->(DBSETORDER(1))
CN9->(DBGOTOP())
DO WHILE CN9->(!EOF())
	
	IF CN9->CN9_SITUAC <> '10' .AND. CN9->CN9_SITUAC <> '09'
	
		cSITUAC := ""
		cSITUAC := aSITUAC[VAL(CN9->CN9_SITUAC)]
		
		cQuery := " SELECT SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2) AS CNF_COMPET,CNF_VLPREV,"
		cQuery += " CNF_DTVENC FROM "+RETSQLNAME("CNF")+" CNF"
		cQuery += " WHERE CNF.D_E_L_E_T_='' AND CNF.CNF_CONTRA='"+ALLTRIM(CN9->CN9_NUMERO)+"' AND CNF.CNF_REVISA='"+ALLTRIM(CN9->CN9_REVISA)+"' "
		cQuery += " ORDER BY CNF_DTVENC" 
	 
		TCQUERY cQuery NEW ALIAS "QCNF"
		TCSETFIELD("QCNF","CNF_DTVENC","D",8,0)	
	
		nPRAZOMES := 1
		nVLIQ     := 0
		dbSelectArea("QCNF")
		QCNF->(dbGoTop())

		dDataI		:= CTOD("")
		dDataI		:= CN9->CN9_DTINIC //QCNF->CNF_DTVENC
		dDataFinal	:= CTOD("")
		
		DO WHILE QCNF->(!EOF())
			dDataFinal	:= QCNF->CNF_DTVENC
			QCNF->(DBSKIP())
		ENDDO
	    
		nPRAZOMES += DateDiffMonth( dDataI , dDataFinal )
		
		QCNF->(dbCloseArea())
	
	    
	    cENDER := TRIM(Posicione("SA1",1,xFilial("SA1")+CN9->CN9_CLIENT+CN9->CN9_LOJACL,"A1_END")) 
	    cENDER += TRIM(SA1->A1_END)+' - '+TRIM(SA1->A1_BAIRRO)+' - '+TRIM(SA1->A1_MUN)+' - '+SA1->A1_EST   
	
	    dtFIM  := CTOD("")
	    dtFIM  := MonthSum( CN9->CN9_DTINIC , nPRAZOMES ) 
	    dtFIM  := DaySum( dtFIM  , 1 ) 
	
	
		//*********Faturamento do Contrato
		cQuery := " SELECT F2_VALBRUT,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS" 
		cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"
	    cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9.CN9_NUMERO = CNF.CNF_CONTRA "
	    cQuery += " AND CN9.CN9_REVISA = CNF.CNF_REVISA AND  CN9.CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"
		cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"
		cQuery += " AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ''"
		cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA"
		cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET"
		cQuery += " AND CND_PARCEL = CNF_PARCEL AND CNA_NUMERO = CND_NUMERO AND CND_REVISA = CNF_REVISA"
		cQuery += " AND  CND.D_E_L_E_T_ = ' '"
		cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON CND_PEDIDO = C5_NUM"
		cQuery += "      AND  C5_FILIAL = CND_FILIAL AND SC5.D_E_L_E_T_ = ' '"
		cQuery += "	LEFT JOIN "+RETSQLNAME("SF2")+ " SF2 ON C5_NOTA = F2_DOC AND C5_SERIE=F2_SERIE AND C5_CLIENTE=F2_CLIENTE AND C5_LOJACLI=F2_LOJA"  
		cQuery += "      AND  F2_FILIAL = CND_FILIAL AND SF2.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE CNF.D_E_L_E_T_=''  AND CN9_SITUAC = '"+ALLTRIM(CN9->CN9_SITUAC)+"'"
		cQuery += "	 AND CNF_CONTRA ='"+ALLTRIM(CN9->CN9_NUMERO)+"' AND CNF_REVISA='"+ALLTRIM(CN9->CN9_REVISA)+"'"
		
		TCQUERY cQuery NEW ALIAS "QCN9"
		
		nVALFAT  := 0
		dbSelectArea("QCN9")
		QCN9->(dbGoTop())
		DO WHILE QCN9->(!EOF())
			nVLIQ   += QCN9->F2_VALFAT - QCN9->F2_VALIRRF - QCN9->F2_VALINSS - QCN9->F2_VALPIS - QCN9->F2_VALCOFI - QCN9->F2_VALCSLL - IIF(QCN9->F2_RECISS = '1',QCN9->F2_VALISS,0)
	 		nVALFAT += QCN9->F2_VALBRUT
			QCN9->(DBSKIP())
		ENDDO
	    QCN9->(Dbclosearea())
		    
	
		//********* FATURAMENTO - Inclusão para medição avulso
		cQuery2 := " SELECT F2_VALBRUT,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS" 
		cQuery2 += " FROM "+RETSQLNAME("SC5")+" SC5" 
	    cQuery2 += " INNER JOIN "+RETSQLNAME("SF2")+" SF2 ON C5_NOTA = F2_DOC AND C5_SERIE=F2_SERIE 
	    cQuery2 += "  AND C5_CLIENTE=F2_CLIENTE AND C5_LOJACLI=F2_LOJA"
		cQuery2 += "  AND SF2.D_E_L_E_T_ = ' '"
	    cQuery2 += " WHERE SC5.D_E_L_E_T_ = ' ' AND SC5.C5_MDCONTR='' 
	   	cQuery2 += " AND C5_ESPECI1 ='"+ALLTRIM(CN9->CN9_NUMERO)+"'"
		    
		TCQUERY cQuery2 NEW ALIAS "QSC5"
		
		dbSelectArea("QSC5")
		QSC5->(dbGoTop())
		DO WHILE QSC5->(!EOF())
			nVLIQ   += QSC5->F2_VALFAT - QSC5->F2_VALIRRF - QSC5->F2_VALINSS - QSC5->F2_VALPIS - QSC5->F2_VALCOFI - QSC5->F2_VALCSLL - IIF(QSC5->F2_RECISS = '1',QSC5->F2_VALISS,0)
	 		nVALFAT += QSC5->F2_VALBRUT
			QSC5->(DBSKIP())
		ENDDO
	    QSC5->(Dbclosearea())
	
		dbSelectArea("TRB")
		Reclock("TRB",.T.)
		TRB->XX_NOMCLI  := SA1->A1_NOME
		TRB->XX_ENDER   := cENDER
		TRB->XX_TELS    := CN9->CN9_XXTELS
		TRB->XX_CNPJ    := SA1->A1_CGC
		TRB->XX_XXDESC  := CN9->CN9_XXDESC
		TRB->XX_CONTRAT := CN9->CN9_NUMERO
		TRB->XX_DTINIC  := CN9->CN9_DTINIC
		TRB->XX_DTFIM   := dtFIM
		TRB->XX_PRAZO   := STR(nPRAZOMES,4)+" Meses"
		TRB->XX_VLIQ    := nVLIQ
		TRB->XX_VFAT  	:= nVALFAT
		TRB->XX_CODOBJ  := CN9->CN9_CODOBJ 
		TRB->XX_MUNIC   := TRIM(SA1->A1_MUN)+' - '+SA1->A1_EST   
		TRB->XX_SITUAC 	:= cSITUAC
		TRB->(Msunlock())
    ENDIF
	CN9->(DBSKIP())
ENDDO 

RETURN NIL

