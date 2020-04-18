#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} BKFINR17()
BK - Contas Recebidas

@author Adilson do Prado
@since 09/02/15
@version P12
@return Nil
/*/


User Function BKFINR17()

Local cTitulo	:= ""
Local aTitulos	:= {}
Local aCampos	:= {}
Local aCabs		:= {}
Local aPlans	:= {}
Local oDlg01
Local aButtons	:= {}
Local lOk		:= .F.
Local oPanelLeft
Local aStruct	:= {}
Local nValRec	:= 0
Local nValLiq	:= 0
Local lFirst	:= .T.
Local cObsX     := ""
Local oTmpTb

Private cPerg        := "BKFINR17"
Private nEmissao 	 := 1
Private cMesComp     := ""
Private cAnoComp     := ""
Private cCompet      := ""
Private dDataI   	 := CTOD("")
Private dDataF   	 := CTOD("")
Private cContrato	 := ""
Private cNFIni       := ""
Private cNFFim       := ""
Private aTipoEmis    := {"1-Competência","2-Vencimento","3-Emissão","4-Centro de Custo","5-NF/Título","6-Data de Baixa"}
Private cTipoEmis    := ""

cTipoEmis := aTipoEmis[1] 

Define MsDialog oDlg01 Title "BKFINR17 - Relação de Contas recebidas - v29/03/20b" From 000,000 To 150,330 Of oDlg01 Pixel
	
@ 000,000 MSPANEL oPanelLeft OF oDlg01 SIZE 380,600 
oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
@ 15,10 SAY 'Emitir por'   SIZE 080,010 OF oPanelLeft PIXEL
@ 15,45 COMBOBOX cTipoEmis  ITEMS aTipoEmis SIZE 100,010 Pixel OF oPanelLeft 
	
ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

If ( !lOk )
	RETURN NIL
EndIf

                                                                                                                                     
//nEmissao := mv_par01

If VALTYPE(cTipoEmis) <> "N"
	nEmissao := VAL(SUBSTR(cTipoEmis,1,1))
Else
	nEmissao := cTipoEmis
EndIf

IF nEmissao = 1
	cPerg	:= "2BKFINR17"
	ValidPerg2(cPerg)
	If !Pergunte(cPerg,.T.)
		Return
	Endif
	cMesComp := mv_par01
	cAnoComp := mv_par02
	cCompet  := cMesComp+"/"+cAnoComp
	cTitulo  := "Contas Recebidas : Competência "+cCompet

	IF LEN(ALLTRIM(cAnoComp)) < 4
   		MSGSTOP('Ano deve conter 4 digitos!!',"Atenção")
   		Return
	ENDIF 

ELSEIF nEmissao = 2
	cPerg	:= "3BKFINR17"
	ValidPerg3(cPerg)
	If !Pergunte(cPerg,.T.)
		Return
	Endif
	dDataI   := mv_par01
	dDataF   := mv_par02
	cTitulo  := "Contas Recebidas : Vencimento de "+DTOC(dDataI)+" até "+DTOC(dDataF)
ELSEIF nEmissao = 3
	cPerg	:= "4BKFINR17"
	ValidPerg4(cPerg)
	If !Pergunte(cPerg,.T.)
		Return
	Endif
	dDataI   := mv_par01
	dDataF   := mv_par02
	cTitulo  := "Contas Recebidas : Emissão de "+DTOC(dDataI)+" até "+DTOC(dDataF)
ELSEIF nEmissao = 4
	cPerg	:= "5BKFINR17"
	ValidPerg5(cPerg)
	If !Pergunte(cPerg,.T.)
		Return
	Endif
	cContrato:= mv_par01 
	cAnoComp := mv_par02
	IF !EMPTY(cContrato) 
		cTitulo := "Contas Recebidas : Contrato "+cContrato+" - "+ALLTRIM(Posicione("CTT",1,xFilial("CTT")+cContrato,"CTT_DESC01"))
    ELSEIF !EMPTY(cAnoComp) 
		cTitulo := "Contas Recebidas : Ano vencimento "+cAnoComp
	ENDIF
	IF EMPTY(cContrato) .AND. EMPTY(cAnoComp)
		cTitulo   := "Contas a Recebidas "
	ENDIF

ELSEIF nEmissao = 5
	cPerg	:= "6BKFINR17"
	ValidPerg6(cPerg)
	If !Pergunte(cPerg,.T.)
		Return
	Endif
	
	cNFIni   := mv_par01 
	cNFFim   := mv_par02
	
	IF !EMPTY(cNFIni) 
		cTitulo := "Contas Recebidas : NF/Titulo de "+TRIM(cNFIni)+IIF(!EMPTY(cNFFim)," até "+TRIM(cNFFim),"")
    ELSEIF !EMPTY(cNFFim) 
		cTitulo := "Contas Recebidas : NF/Titulo até "+TRIM(cNFFim)
	ENDIF
	IF EMPTY(cNFIni) .AND. EMPTY(cNFFim)
		cTitulo := "Contas Recebidas "
	ENDIF     
	
ELSEIF nEmissao = 6
	cPerg	:= "7BKFINR17"
	ValidPerg7(cPerg)
	If !Pergunte(cPerg,.T.)
		Return
	Endif
	dDataI   := mv_par01
	dDataF   := mv_par02
	cTitulo  := "Contas Recebidas : Baixa de "+DTOC(dDataI)+" até "+DTOC(dDataF)

ENDIF

ProcRegua(1)
Processa( {|| ProcQuery() })

// Incluir as baixas parciais

aStruct := QTMP1->(dbStruct())
aadd(aStruct,{"XX_VALBX","N",18,2})
aadd(aStruct,{"XX_VALDCAC","N",18,2})
aadd(aStruct,{"E1_XXOBX","C",15,0})
aadd(aStruct,{"E5_TIPODOC","C",2,0})

///cTbl := CriaTrab(aStruct)
///IF SELECT("QTMP") > 0
///   dbSelectArea("QTMP")
///   dbCloseArea()
///ENDIF
///dbUseArea(.T.,,cTbl,"QTMP",if(.F. .OR. .F.,!.F., NIL),.F.)

oTmpTb := FWTemporaryTable():New( "QTMP" )
oTmpTb:SetFields( aStruct )
oTmpTb:Create()

dbSelectArea("QTMP1")
dbGotop()
Do While !Eof()

	dbSelectArea("QTMP")
	RecLock("QTMP",.T.)
	For j:=1 to QTMP1->(FCount())
		FieldPut(j,QTMP1->(FieldGet(j)))
	Next
	MsUnlock()

	// Verificar se tem baixa parcial

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava as baixas do titulo															³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE5")
	dbSetOrder(7)
    lFirst := .T.
		
	If dbSeek(xFilial("SE5")+QTMP1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA))
		While !SE5->(Eof()).AND. ;
				SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO) == ;
				xFilial("SE5")+QTMP1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
			
			*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			*³ Verifica se NCC de mesmo numero pertence a outro cliente		³
			*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SE5->E5_CLIFOR+SE5->E5_LOJA != QTMP1->(E1_CLIENTE+E1_LOJA)
				SE5->( dbSkip() )
				Loop
			Endif

			If	(SE5->E5_RECPAG == "R" .AND. SE5->E5_TIPODOC == "ES") .OR. ;
				(SE5->E5_RECPAG == "P" .AND. SE5->E5_TIPODOC != "ES" .AND. ;
				!(SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG))
				SE5->(dbSkip())
				Loop
			Endif
			
			/*
			If !Empty(xFilial("SE5"))
				//Busca movimento de compensacao em outra filial
				cFilOrig := SE5->E5_FILORIG
				If SE5->E5_MOTBX == "CMP" .AND. SE5->E5_TIPO $ MV_CRNEG+"#"+MVRECANT
					If Empty(SE5->E5_FILORIG)
						nRecSe5 := Recno()
						dbGoto(nRecSE5-1)
						cFilOrig := SE5->E5_FILORIG
						dbGoto(nRecSe5)
					Else
						cFilOrig := SE5->E5_FILIAL
					Endif			
				Endif	
				//Verifico se o movimento pertence ao titulo pois posso, quando os arquivos 
				// forem exclusivos, ter titulos com mesma chave nas diferentes filiais
				If cFilOrig != QTMP1->E1_FILIAL
					SE5->(dbSkip())
					Loop
				Endif		
			Endif
            */
			cSeq   := SE5->E5_SEQ
		    
			While !SE5->(Eof()) .AND. ;
				SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) == ;
				xFilial("SE5")+QTMP1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)+cSeq
					
   				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    			//³ PE - Validacao para inclusao do titulo na tabela temporaria ³
	    		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//If lF040FilTit
				//	If !ExecBlock("F040FILTIT")
				//		SE5->(dbSkip())
				//		Loop
				//	Endif	
				//Endif
		
		        //Movimento de inclusão do RA
				If SE5->E5_TIPODOC == "RA"
					SE5->(dbSkip())
					Loop
				Endif

				IF SE5->E5_SITUACAO == "C" //.OR. ;
					//SE5->E5_TIPODOC == "E2"
					//SE5->E5_TIPODOC == "ES" .OR. ;
					SE5->(dbSkip())
					Loop
				Endif
				
		        /*
				IF SE5->E5_SITUACAO == "C" .OR. ;
					SE5->E5_TIPODOC == "ES" .OR. ;
					SE5->E5_TIPODOC == "E2"
					nSituaca := 2
				Else
					If SE5->E5_TIPODOC == "TR"
						nSituaca := 3
					Else
						nSituaca := 1
					Endif	
				Endif
                */
                
				If TemBxCanc(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)
					SE5->(dbSkip())
					Loop
				Endif
                
				//nCorrec	:= 0
				//nJuros	:= 0
				//nMulta	:= 0
				//nDescont := 0
				nValRec	:= 0
				//cMotivo	:= ""
		
				If SE5->E5_TIPODOC $ "VLüBAüV2üCP#ES#DB#LJ" //+"CMüC2|VM" + "DCüD2" + "MTüM2" + "JRüJ2"
					If SE5->E5_TIPODOC == "ES"
						nValRec	:= -SE5->E5_VALOR
					Else
						nValRec	:= SE5->E5_VALOR
					EndIf
					//cMotivo	:= SE5->E5_MOTBX
					//If SE5->E5_MOTBX == "CMP"
					//	nJuros := SE5->E5_VLJUROS
					//	nDescont := SE5->E5_VLDESCO
					//Endif
				Endif
                
				/*
				IF SE5->E5_TIPODOC$"CMüC2|VM"
					nCorrec := SE5->E5_VALOR
				ElseIf SE5->E5_MOTBX == "CMP" .AND. SE5->E5_VLCORRE <> 0
					nCorrec := SE5->E5_VLCORRE					
				Endif
				IF SE5->E5_TIPODOC=="CX"
					nCorrec := SE5->E5_VALOR
				Endif
				If SE5->E5_TIPODOC$"DCüD2"
					nDescont := SE5->E5_VALOR
				Endif
				IF SE5->E5_TIPODOC$"MTüM2"
					nMulta  := SE5->E5_VALOR
				Endif
				If SE5->E5_TIPODOC$"JRüJ2"
					nJuros  := SE5->E5_VALOR
				Endif
		        */
                
                nValLiq := QTMP->F2_VALFAT - QTMP->F2_VALIRRF - QTMP->F2_VALINSS - QTMP->F2_VALPIS - QTMP->F2_VALCOFI - QTMP->F2_VALCSLL - QTMP->F2_XXVCVIN - QTMP->F2_XXVFUMD - IIF(QTMP->F2_RECISS = '1',QTMP->F2_VALISS,0)
				If nValliq <> (nValRec - SE5->(E5_VLJUROS + E5_VLMULTA + E5_VLCORRE - E5_VLDESCO))
				   cObsX := "Baixa parcial"
				Else
				   cObsX := "Baixa normal"
				EndIf
				  
				If nValRec <> 0 .OR. SE5->(E5_VLJUROS + E5_VLMULTA + E5_VLCORRE - E5_VLDESCO) <> 0                
					dbSelectArea("QTMP")
					If lFirst 
						RecLock("QTMP",.F.)
						lFirst := .F.
					Else
						RecLock("QTMP",.T.)
						QTMP->A1_NOME    := QTMP1->A1_NOME
						QTMP->CONTRATO   := QTMP1->CONTRATO 
						QTMP->CND_COMPET := QTMP1->CND_COMPET 
						QTMP->F2_DOC     := QTMP1->F2_DOC  
					EndIf
					QTMP->E1_XXOBX   := cObsX //QTMP1->E1_XXOBX  
					QTMP->E5_TIPODOC := SE5->E5_TIPODOC
					QTMP->E1_BAIXA   := SE5->E5_DATA
					QTMP->XX_VALBX   := nValRec 
					QTMP->XX_VALDCAC := SE5->(E5_VLJUROS + E5_VLMULTA + E5_VLCORRE - E5_VLDESCO)
					MsUnlock()
				EndIf

				//Reclock("cNomeArq",.T.)
				//cNomeArq->OK		 :=	nSituaca
				//cNomeArq->DATAX		 :=	SE5->E5_DATA
				//cNomeArq->JUROS		 :=	nJuros
				//cNomeArq->MULTA		 :=	nMulta
				//cNomeArq->CORRECAO	 :=	nCorrec
				//cNomeArq->DESCONTOS  :=	nDescont
				//cNomeArq->VALORRECEB :=	nValRec
				//cNomeArq->MOTIVO 	 :=	cMotivo
				//cNomeArq->DATACONT	 :=	SE5->E5_DTDIGIT
				//cNomeArq->DATADISP	 :=	SE5->E5_DTDISPO
				//cNomeArq->LOTE		 :=	SE5->E5_LOTE
				//cNomeArq->HISTORICO  :=	SE5->E5_HISTOR
				//cNomeArq->BANCO		 :=	SE5->E5_BANCO
				//cNomeArq->AGENCIA	 :=	SE5->E5_AGENCIA
				//cNomeArq->CONTA		 :=	SE5->E5_CONTA
				//cNomeArq->DOCUMENTO  :=	Substr(SE5->E5_DOCUMEN,1,3)+"-"+;
				//					    Substr(SE5->E5_DOCUMEN,4,aTamSx3[1])+"-"+;
				//						Substr(SE5->E5_DOCUMEN,aTamsx3[1]+4,1)+"-"+;
				//						Substr(SE5->E5_DOCUMEN,aTamsx3[1]+5,3)
				//cNomeArq->FILIAL  	 := SE5->E5_FILIAL
				//cNomeArq->RECONC	 := SE5->E5_RECONC

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Permite ao usuario gravar os campos manipulados para uso     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//If lFi040MnCp .AND. lFi040TpCp .AND. lFi040GrCp
				//	ExecBlock("FI040GRCP",.F.,.F.)
				//Endif
			
				//MsUnlock()

				SE5->( dbSkip() )
				dbSelectArea("SE5")
			Enddo
		Enddo
	Endif
	
	dbSelectArea("QTMP1")
    dbSkip()
EndDo

dbSelectArea("SE5")
dbSetOrder(1)

//U_QryToXml("QTMP")

QTMP1->(dbCloseArea())

aCabs   := {}
aCampos := {}
aTitulos:= {}
   
AADD(aTitulos,"BKFINR17/"+TRIM(SUBSTR(cUsuario,7,15))+" - "+cTitulo)

AADD(aCampos,"QTMP->A1_NOME")
AADD(aCabs  ,"Cliente")

AADD(aCampos,"QTMP->CONTRATO")
AADD(aCabs  ,"Contrato")

AADD(aCampos,'IIF(!EMPTY(QTMP->CONTRATO),ALLTRIM(Posicione("CTT",1,xFilial("CTT")+QTMP->CONTRATO,"CTT_DESC01")),"")')
AADD(aCabs  ,"Centro de Custos")

AADD(aCampos,"QTMP->CND_COMPET")
AADD(aCabs  ,"Competencia")

AADD(aCampos,"QTMP->F2_DOC")
AADD(aCabs  ,"Nota Fiscal")

AADD(aCampos,"QTMP->E1_XXOBX")
AADD(aCabs  ,"Observação de Baixa")

AADD(aCampos,"QTMP->F2_EMISSAO")
AADD(aCabs  ,"Emissao")

AADD(aCampos,"QTMP->E1_VENCREA")
AADD(aCabs  ,"Vencimento")

AADD(aCampos,"QTMP->E1_BAIXA")
AADD(aCabs  ,"Data da Baixa")

AADD(aCampos,"QTMP->XX_VALBX")
AADD(aCabs  ,"Valor da Baixa")

AADD(aCampos,"QTMP->XX_VALDCAC")
AADD(aCabs  ,"Multas/Juros/Desc")

AADD(aCampos,"QTMP->F2_VALFAT")
AADD(aCabs  ,"Valor Bruto")

AADD(aCampos,"QTMP->F2_VALIRRF")
AADD(aCabs  ,"IRRF Retido")

AADD(aCampos,"QTMP->F2_VALINSS")
AADD(aCabs  ,"INSS Retido")

AADD(aCampos,"QTMP->F2_VALPIS")
AADD(aCabs  ,"PIS Retido")

AADD(aCampos,"QTMP->F2_VALCOFI")
AADD(aCabs  ,"COFINS Retido")

AADD(aCampos,"QTMP->F2_VALCSLL")
AADD(aCabs  ,"CSLL Retido")

AADD(aCampos,"IIF(QTMP->F2_RECISS = '1',QTMP->F2_VALISS,0)")
AADD(aCabs  ,"ISS Retido")

AADD(aCampos,"QTMP->F2_XXVCVIN")
AADD(aCabs  ,"Conta Vinculada") 

AADD(aCampos,"QTMP->F2_XXVFUMD")
AADD(aCabs  ,"FUMDIP OSASCO")

AADD(aCampos,"QTMP->F2_VALFAT - QTMP->F2_VALIRRF - QTMP->F2_VALINSS - QTMP->F2_VALPIS - QTMP->F2_VALCOFI - QTMP->F2_VALCSLL - QTMP->F2_XXVCVIN - QTMP->F2_XXVFUMD - IIF(QTMP->F2_RECISS = '1',QTMP->F2_VALISS,0)")
AADD(aCabs  ,"Valor liquido")

AADD(aCampos,"IIF(QTMP->E1_SALDO > 0,(QTMP->F2_VALFAT - QTMP->F2_VALIRRF - QTMP->F2_VALINSS - QTMP->F2_VALPIS - QTMP->F2_VALCOFI - QTMP->F2_VALCSLL - QTMP->F2_XXVCVIN - QTMP->F2_XXVFUMD - IIF(QTMP->F2_RECISS = '1',QTMP->F2_VALISS,0)) - (QTMP->F2_VALFAT - QTMP->E1_SALDO),0)")
AADD(aCabs  ,"Saldo a Receber")


//ProcRegua(QTMP->(LASTREC()))
//Processa( {|| U_GeraCSV("QTMP",cPerg,aTitulos,aCampos,aCabs)})

AADD(aPlans,{"QTMP",cPerg,"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
U_GeraXml(aPlans,cTitulo,cPerg,.F.)

oTmpTb:Delete()

//Ferase(cTbl + GetDBExtension())
  
Return


Static Function ProcQuery
Local cQuery  := ""

IncProc("Consultando o banco de dados...")

cQuery := "SELECT DISTINCT A1_NOME,E1_VENCREA,E1_VALOR,E1_SALDO,E1_BAIXA,CND_COMPET,F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,"
cQuery += " E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,"
cQuery += " F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS,F2_XXVCVIN,F2_XXVFUMD, "
cQuery += " CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1 ELSE C5_MDCONTR END AS CONTRATO "
//cQuery += " ,CASE WHEN E1_SALDO > 0 THEN 'Baixa Parcial' ELSE 'Baixa Normal' END AS E1_XXOBX "
cQuery += " FROM "+RETSQLNAME("SE1")+ " SE1 "
cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+ " SF2 ON SE1.E1_NUM=SF2.F2_DOC AND SE1.E1_PREFIXO=SF2.F2_SERIE "
cQuery += " AND SE1.E1_CLIENTE=SF2.F2_CLIENTE AND SE1.E1_LOJA=SF2.F2_LOJA AND SF2.D_E_L_E_T_=''"
cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON SC5.C5_NUM=SE1.E1_PEDIDO AND SC5.D_E_L_E_T_='' "
cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON SC5.C5_NUM=CND.CND_PEDIDO AND CND.D_E_L_E_T_=''"
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON SA1.D_E_L_E_T_='' AND SE1.E1_CLIENTE=SA1.A1_COD AND SE1.E1_LOJA=SA1.A1_LOJA"

cQuery += " WHERE SE1.D_E_L_E_T_='' AND SE1.E1_VALOR <> SE1.E1_SALDO AND SE1.E1_VALOR = SF2.F2_VALFAT " 

IF nEmissao == 1
	cQuery += " AND CND_COMPET='"+cCompet+"'"
ELSEIF nEmissao == 2
	cQuery += " AND E1_VENCREA>='"+DTOS(dDataI)+"' AND E1_VENCREA<='"+DTOS(dDataF)+"'"
ELSEIF nEmissao == 3
	cQuery += " AND E1_EMISSAO>='"+DTOS(dDataI)+"' AND E1_EMISSAO<='"+DTOS(dDataF)+"'"
ELSEIF nEmissao == 4
	IF !EMPTY(cContrato) 
		cQuery += " AND (C5_MDCONTR='"+ALLTRIM(cContrato)+"' OR  C5_ESPECI1='"+ALLTRIM(cContrato)+"' )"
    ELSEIF !EMPTY(cAnoComp) 
		cQuery += " AND SUBSTRING(E1_VENCREA,1,4)="+cAnoComp
	ENDIF
ELSEIF nEmissao == 5
	IF !EMPTY(cNFIni) 
		cQuery += " AND E1_NUM >= '"+ALLTRIM(cNFIni)+"'"
	ENDIF
	IF !EMPTY(cNFFim) 
		cQuery += " AND E1_NUM <= '"+ALLTRIM(cNFFim)+"'"
	ENDIF
ELSEIF nEmissao == 6
	cQuery += " AND E1_BAIXA >='"+DTOS(dDataI)+"' AND E1_BAIXA <='"+DTOS(dDataF)+"'"
ENDIF 

cQuery += "ORDER BY E1_VENCREA"

TCQUERY cQuery NEW ALIAS "QTMP1"
TCSETFIELD("QTMP1","F2_EMISSAO","D", 8,0)
TCSETFIELD("QTMP1","E1_VENCREA","D", 8,0)
TCSETFIELD("QTMP1","E1_BAIXA"  ,"D", 8,0)
TCSETFIELD("QTMP1","E1_VALOR"  ,"N",18,2)
TCSETFIELD("QTMP1","E1_SALDO"  ,"N",18,2)
TCSETFIELD("QTMP1","F2_VALFAT" ,"N",18,2)

Return


/*
Static Function  ValidPerg1(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)


AADD(aRegistros,{cPerg,"01","Emitir por:","Emitir por:","Emitir por:","mv_ch1","N",01,0,2,"C","","mv_par01","Competência","Competência","Competência","","","Vencimento","Vencimento","Vencimento","","","Emissão","Emissão","Emissão","","","Centro de Custo","Centro de Custo","Centro de Custo","","","","","","",""})

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
*/

Static Function  ValidPerg2(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Mes de Competencia"  ,"" ,"" ,"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Ano de Competencia"  ,"" ,"" ,"mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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


Static Function  ValidPerg3(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)


AADD(aRegistros,{cPerg,"01","Vencimento de :"     ,"" ,"" ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Vencimento até:"     ,"" ,"" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})


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


Static Function  ValidPerg4(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)


AADD(aRegistros,{cPerg,"01","Emissão de :"     ,"" ,"" ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Emissão até:"     ,"" ,"" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})


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


Static Function  ValidPerg5(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Contrato:" ,"Contrato:" ,"Contrato:","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"02","Do Ano:"   ,"Do Ano:"   ,"Do Ano:"  ,"mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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



Static Function  ValidPerg6(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","NF/Titulo de :" ,"NF/Titulo de:" ,"NF/Titulo de:" ,"mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","NF/Titulo até:" ,"NF/Titulo até:","NF/Titulo até:","mv_ch2","C",09,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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



Static Function  ValidPerg7(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Baixa de :"     ,"" ,"" ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Baixa até:"     ,"" ,"" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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

