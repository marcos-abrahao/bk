#Include "PROTHEUS.CH"
#include "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} BKFINR10
BK - Fluxo de Caixa - Realizado
@Return
@author Adilson do Prado
@since 07/02/14
@version P12
/*/

User Function BKFINR10()

PRIVATE cASSM_Prod	:= GetMv("MV_XXASSMP") //"|605|689|709|711|712|719|733|734|742|743|770|771|773|794|796|810|832|833|854|856|857|"
PRIVATE cSINO_Prod	:= GetMv("MV_XXSINOP") //"|510|607|665|679|724|732|739|825|900|"
PRIVATE cTitulo	    := OemToAnsi("Fluxo de Caixa Realizado ")
PRIVATE cPerg		:= "BKFINR10"
PRIVATE nLastKey	:= 0
PRIVATE cNomePrg	:= "BKFINR10"
PRIVATE cIndiceSE5  := ""
PRIVATE aCtaFin     := {}
PRIVATE dDataI      := DATE()  			// Data Inicial
PRIVATE dDataF      := DATE()  			// Data Final
PRIVATE nSaldos     := 1
PRIVATE nTpData     := 1
PRIVATE nCaixinha   := 1
PRIVATE nFormato    := 1
PRIVATE nBancos     := 1 
PRIVATE nAplic      := 1 
PRIVATE nUsuario	:= 1
PRIVATE cFiltPrd    := ""
PRIVATE nImpostos	:= 2
PRIVATE cTitBanco   := ""
PRIVATE aCamposB2   := {}

PRIVATE aPlans      := {}
PRIVATE cFiltro     := ""

PRIVATE cAliasTmp1  := "TMP1"
PRIVATE oTmpTb1
PRIVATE aCabs1      := {}
PRIVATE aCampos1    := {}
PRIVATE aTitulos1   := {}
PRIVATE aStruct1    := {}
PRIVATE aImpr1      := {}

PRIVATE cAliasTmp2  := "TMP2"
PRIVATE oTmpTb2
PRIVATE aCabs2      := {}
PRIVATE aCampos2    := {}
PRIVATE aTitulos2   := {}
PRIVATE aStruct2    := {}
PRIVATE aImpr2      := {}

PRIVATE cAliasTmp3  := "TMP3"
PRIVATE oTmpTb3
PRIVATE aCabs3      := {}
PRIVATE aCampos3    := {}
PRIVATE aTitulos3   := {}
PRIVATE aStruct3    := {}
PRIVATE aImpr3      := {}

PRIVATE cAliasTmp4  := "TMP4"
PRIVATE oTmpTb4
PRIVATE aCabs4      := {}
PRIVATE aCampos4    := {}
PRIVATE aTitulos4   := {}
PRIVATE aStruct4    := {}
PRIVATE aImpr4      := {}
                         
PRIVATE cAliasTmp5  := "TMP5"
PRIVATE oTmpTb5
PRIVATE aCabs5      := {}
PRIVATE aCampos5    := {}
PRIVATE aTitulos5   := {}
PRIVATE aStruct5    := {}
PRIVATE aImpr5      := {}

PRIVATE cAliasTmp6  := "TMP6"
PRIVATE oTmpTb6
PRIVATE aCabs6      := {}
PRIVATE aCampos6    := {}
PRIVATE aTitulos6   := {}
PRIVATE aStruct6    := {}
PRIVATE aImpr6      := {}


PRIVATE aResumo     := ARRAY(12)
PRIVATE nSaldoAnt   := 0

PRIVATE nMoeda      := 1
PRIVATE nMoedaBco   := 1
PRIVATE nDecs       := 2
PRIVATE lLands  := .T.
PRIVATE aDESCRH := {}
PRIVATE aSitFin := {}

AADD(aDESCRH,{"LDV","DIVERSOS"})
AADD(aDESCRH,{"VA","VALE ALIMENTAÇÃO"})
AADD(aDESCRH,{"LFE","FÉRIAS"})
AADD(aDESCRH,{"COM","COMISSÃO"})
AADD(aDESCRH,{"VR","VALE REFEIÇÃO"})
AADD(aDESCRH,{"LAD" ,"ADTO"})
AADD(aDESCRH,{"LRC","RESCISÃO"})
AADD(aDESCRH,{"MFG","MULTA FGTS"})
AADD(aDESCRH,{"LFG","FGTS"})
AADD(aDESCRH,{"LPM","MENSAL"})
AADD(aDESCRH,{"VT","VALE TRANSPORTE"})
AADD(aDESCRH,{"LAS","ADTO SALARIAL"})
AADD(aDESCRH,{"LD1" ,"13.o PARC 1"})
AADD(aDESCRH,{"LD2","13.o PARC 2"})
AADD(aDESCRH,{"SOL","Despesas de Viagem - Prest. Contas"})
AADD(aDESCRH,{"CXA","Caixa - Prest. Contas"})
AADD(aDESCRH,{"HOS","HOSPEDAGEM"})
AADD(aDESCRH,{"DCH","Diaria de campo"})
AADD(aDESCRH,{"EXM","EXAME MÉDICO ADMISSÃO"})
AADD(aDESCRH,{"PEN","PENSÃO"})

AADD(aSitFin,"Total Clientes")
AADD(aSitFin,"A – RH")
AADD(aSitFin,"B – Fornecedores")
AADD(aSitFin,"C – Bancos")
AADD(aSitFin,"D – Rateio")
AADD(aSitFin,"E – Diretoria")
AADD(aSitFin,"F – Despesas com Veículos")
AADD(aSitFin,"G – Impostos")
AADD(aSitFin,"H – BK TER / ESA / Just / Consórcio")
AADD(aSitFin,"J – Outros")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

VldPerg(cPerg)
IF !Pergunte(cPerg,.T.)
	Return Nil
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dDataI   := MV_PAR01	// Data Inicial
dDataF   := MV_PAR02	// Data Final
nSaldos  := MV_PAR03	// Sim/Nao
nTpData  := MV_PAR04	// Data do Movimento/Data Extrato
nCaixinha:= MV_PAR05	// Inclui Movimento Caixinha
nFormato := MV_PAR06    // CSV / XML
nBancos  := MV_PAR07    // Selecionar / Todos
nAplic   := MV_PAR08    // Incluir aplicações (S/N)
nUsuario := MV_PAR09    // Incluir Usuário digitou ou Liberou
cFiltPrd := MV_PAR10    // Filtrar produto
nImpostos:= MV_PAR11    // Incluir Impostos (S/N)

cTitulo  := OemToAnsi(cTitulo+" de "+DTOC(MV_PAR01)+" até "+DTOC(MV_PAR02))+" - "+IIF(nTpData==1,"Data do Movimento","Data do Extrato")
If !EMPTY(cFiltPrd)
	cTitulo += " - Produto: "+TRIM(cFiltPrd)  
EndIf

aCamposB2 := {	{"A6_OK"      ,,"  ",""},;
				{"A6_COD"     ,,"Banco","@X"}   ,;
				{"A6_AGENCIA" ,,"Agencia","@X"} ,;
				{"A6_NUMCON"  ,,"Conta","@X"}   ,;
				{"A6_NREDUZ"  ,,"Nome","@X"}    ,;
				{"A6_SALDOA"  ,,"Saldo Anterior","@E 9,999,999,999.99"},;
				{"A6_SALDOF"  ,,"Saldo Final","@E 9,999,999,999.99"} }


If nAplic == 1
	AADD(aCamposB2,{"EH_VALREG"  ,,"Saldo Aplic.","@E 9,999,999,999.99"})
	AADD(aCamposB2,{"EH_VALOR"   ,,"Valor Aplic.","@E 9,999,999,999.99"})
EndIf

AADD(aTitulos1,cNomePrg+"/"+TRIM(SUBSTR(cUsuario,7,15))+" - "+cTitulo+OemToAnsi(" - Saldos bancários"))

AADD(aStruct1,{"A6_OK","C",2,0})
AADD(aCampos1,cAliasTmp1+"->A6_OK")
AADD(aCabs1  ,"Ok")

AADD(aStruct1,{"A6_DATA","D",8,0})
AADD(aCampos1,cAliasTmp1+"->A6_DATA")
AADD(aCabs1  ,"Data")

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek ("SA6")
Do While SX3->(!EOF()) .And. (SX3->x3_arquivo == "SA6")
	IF Alltrim(SX3->X3_CAMPO) $ "A6_COD#A6_AGENCIA#A6_NUMCON#A6_NREDUZ"
		AADD(aStruct1,{SX3->X3_CAMPO,SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})
		AADD(aCampos1,cAliasTmp1+"->"+SX3->X3_CAMPO)
		AADD(aCabs1  ,SX3->X3_TITULO)
	ENDIF
	SX3->(dbSkip())
Enddo

// Saldo Anterior
AADD(aStruct1,{"A6_SALDOA","N",20,2})
AADD(aCampos1,cAliasTmp1+"->A6_SALDOA")
AADD(aCabs1  ,"Saldo anterior")

// Saldo Anterior
AADD(aStruct1,{"A6_SALDOF","N",20,2})
AADD(aCampos1,cAliasTmp1+"->A6_SALDOF")
AADD(aCabs1  ,"Saldo final")

If nAplic == 1
	// Valor das aplicações
	AADD(aStruct1,{"EH_VALREG","N",15,2})
	AADD(aCampos1,cAliasTmp1+"->EH_VALREG")
	AADD(aCabs1  ,"Valor aplicado")
	
	// Saldo das aplicações
	AADD(aStruct1,{"EH_VALOR","N",15,2})
	AADD(aCampos1,cAliasTmp1+"->EH_VALOR")
	AADD(aCabs1  ,"Saldo das aplicações")


	AADD(aTitulos6,cNomePrg+"/"+TRIM(SUBSTR(cUsuario,7,15))+" - "+cTitulo+OemToAnsi(" - Aplicações"))
	
	AADD(aStruct6,{"EH_NUMERO","C",GetSx3Cache("EH_NUMERO", "X3_TAMANHO"),0})
	AADD(aCampos6,cAliasTmp6+"->EH_NUMERO")
	AADD(aCabs6  ,RetTitle("EH_NUMERO"))

	AADD(aStruct6,{"EH_BANCO","C",GetSx3Cache("EH_BANCO", "X3_TAMANHO"),0})
	AADD(aCampos6,cAliasTmp6+"->EH_BANCO")
	AADD(aCabs6  ,RetTitle("EH_BANCO"))

	AADD(aStruct6,{"EH_AGENCIA","C",GetSx3Cache("EH_AGENCIA", "X3_TAMANHO"),0})
	AADD(aCampos6,cAliasTmp6+"->EH_AGENCIA")
	AADD(aCabs6  ,RetTitle("EH_AGENCIA"))

	AADD(aStruct6,{"EH_CONTA","C",GetSx3Cache("EH_CONTA", "X3_TAMANHO"),0})
	AADD(aCampos6,cAliasTmp6+"->EH_CONTA")
	AADD(aCabs6  ,RetTitle("EH_CONTA"))

	AADD(aStruct6,{"EH_DATA","D",GetSx3Cache("EH_DATA", "X3_TAMANHO"),0})
	AADD(aCampos6,cAliasTmp6+"->EH_DATA")
	AADD(aCabs6  ,RetTitle("EH_DATA"))

	AADD(aStruct6,{"EH_VALOR","N",GetSx3Cache("EH_VALOR", "X3_TAMANHO"),GetSx3Cache("EH_VALOR", "X3_DECIMAL")})
	AADD(aCampos6,cAliasTmp6+"->EH_VALOR")
	AADD(aCabs6  ,RetTitle("EH_VALOR"))

	AADD(aStruct6,{"EH_VALIRF","N",GetSx3Cache("EH_VALIRF", "X3_TAMANHO"),GetSx3Cache("EH_VALIRF", "X3_DECIMAL")})
	AADD(aCampos6,cAliasTmp6+"->EH_VALIRF")
	AADD(aCabs6  ,RetTitle("EH_VALIRF"))

	AADD(aStruct6,{"EH_VALIOF","N",GetSx3Cache("EH_VALIOF", "X3_TAMANHO"),GetSx3Cache("EH_VALIOF", "X3_DECIMAL")})
	AADD(aCampos6,cAliasTmp6+"->EH_VALIOF")
	AADD(aCabs6  ,RetTitle("EH_VALIOF"))

	AADD(aStruct6,{"EH_VALJUR","N",GetSx3Cache("EH_VALJUR", "X3_TAMANHO"),GetSx3Cache("EH_VALJUR", "X3_DECIMAL")})
	AADD(aCampos6,cAliasTmp6+"->EH_VALJUR")
	AADD(aCabs6  ,RetTitle("EH_VALJUR"))

	AADD(aStruct6,{"EH_VALCOR","N",GetSx3Cache("EH_VALOR", "X3_TAMANHO"),GetSx3Cache("EH_VALOR", "X3_DECIMAL")})
	AADD(aCampos6,cAliasTmp6+"->EH_VALCOR")
	AADD(aCabs6  ,RetTitle("EH_VALCOR"))

	AADD(aStruct6,{"EH_VALLIQ","N",GetSx3Cache("EH_VALOR", "X3_TAMANHO"),GetSx3Cache("EH_VALOR", "X3_DECIMAL")})
	AADD(aCampos6,cAliasTmp6+"->EH_VALLIQ")
	AADD(aCabs6  ,"Saldo Líquido")

	AADD(aStruct6,{"EH_TAXA","N",GetSx3Cache("EH_TAXA", "X3_TAMANHO"),GetSx3Cache("EH_TAXA", "X3_DECIMAL")})
	AADD(aCampos6,cAliasTmp6+"->EH_TAXA")
	AADD(aCabs6  ,RetTitle("EH_TAXA"))

	AADD(aStruct6,{"EH_CALC1","N",GetSx3Cache("EH_VALOR", "X3_TAMANHO"),GetSx3Cache("EH_VALOR", "X3_DECIMAL")})
	AADD(aCampos6,cAliasTmp6+"->EH_CALC1")
	AADD(aCabs6  ,"Saldo Bruto")

	AADD(aStruct6,{"EH_SALDO","N",GetSx3Cache("EH_SALDO", "X3_TAMANHO"),GetSx3Cache("EH_SALDO", "X3_DECIMAL")})
	AADD(aCampos6,cAliasTmp6+"->EH_SALDO")
	AADD(aCabs6  ,"Saldo início")
	
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o arquivo temporario de bancos           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oTmpTb1 := FWTemporaryTable():New( cAliasTmp1 ) 
oTmpTb1:SetFields( aStruct1 )
oTmpTb1:AddIndex("indice1", {"A6_COD","A6_AGENCIA","A6_NUMCON"} )
oTmpTb1:Create()

///cArqTmp1	:= CriaTrab(aStruct1)

///IF SELECT(cAliasTmp1) > 0
///   dbSelectArea(cAliasTmp1)
///   dbCloseArea()
///ENDIF

//dbUseArea(.T.,,cArqTmp1,cAliasTmp1,if(.F. .OR. .F.,!.F., NIL),.F.)
//IndRegua (cAliasTmp1,cArqTmp1,"A6_COD+A6_AGENCIA+A6_NUMCON",,,OemToAnsi("Selecionando Registros...") ) 

dbSelectArea(cAliasTmp1)
dbSetOrder(1)

IF nSaldos == 1 .OR. nBancos == 1

	If nAplic == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria o arquivo temporario de aplicações       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		oTmpTb6 := FWTemporaryTable():New( cAliasTmp6 ) 
		oTmpTb6:SetFields( aStruct6 )
		oTmpTb6:AddIndex("indice6", {"EH_BANCO","EH_AGENCIA","EH_CONTA"} )
		oTmpTb6:Create()


		///cArqTmp6	:= CriaTrab(aStruct6)
		
		///IF SELECT(cAliasTmp6) > 0
		///   dbSelectArea(cAliasTmp6)
		///   dbCloseArea()
		///ENDIF
		
		///dbUseArea(.T.,,cArqTmp6,cAliasTmp6,if(.F. .OR. .F.,!.F., NIL),.F.)
		///IndRegua(cAliasTmp6,cArqTmp6,"EH_BANCO+EH_AGENCIA+EH_CONTA",,,"Indexando Aplicações")
	
	EndIf
	
	KFin01ExpSld()
ENDIF

KFin01ExpMov()

dbSelectArea("SA6")
dbSetOrder(1)

// Exportação dos saldos bancarios
If nSaldos == 1                                              
	If nFormato == 1
		ProcRegua((cAliasTmp1)->(LASTREC()))
		Processa( {|| U_GeraCSV(cAliasTmp1,cNomePrg+"-Saldos",aTitulos1,aCampos1,aCabs1,,,,.F.)})
        //                        cAlias,    cArqS             ,aTitulos, aCampos, aCabs,cTpQuebra,cQuebra,aQuebra,lClose)
  	EndIf
	//Else	
	//	aPlans := {}
	//	AADD(aPlans,{cAliasTmp1,cNomePrg,cFiltro,cTitulo+OemToAnsi(" - Saldos bancários"),aCampos1,aCabs1,aImpr1, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
	//	U_GeraXml(aPlans,cTitulo,cNomePrg,.F.)
	//EndIf
EndIf

If Select(cAliasTmp1) > 0
	oTmpTb1:Delete() 
EndIf
///dbSelectArea(cAliasTmp1)
///dbCloseArea()
///Ferase(cArqTmp1 + GetDBExtension())

Return( .T. )

   



// KFin01ExpSld() - Exportar os saldos Bancarios

Static Function KFin01ExpSld()

Local cMarca     := GetMark()
Local oDlg
Local oMark
Local lInverte   := .F.
Local nOpcA
Local nValApl    := 0
Local nVlrAplAtu := 0
Local nSaldoApl  := 0
Local nTotAplAtu := 0
Local nTotSaldo  := 0
Local nValBP     := 0				
Local nValJR     := 0				
Local nValRG     := 0				
Local nValI1     := 0				
Local nValI2     := 0				
Local nValVL     := 0				
Local cAplCotas  := GetMv("MV_APLCAL4")

PRIVATE nDecs	:= 2 		  // MsDecimais
PRIVATE dDtProc	:= dDataF 	  // Data do saldo final		
PRIVATE dDtAnt  := dDataI - 1 // Data do saldo anterior

dbSelectArea( "SA6" )
dbSetOrder( 1 )
dbSeek( xFilial("SA6") )
While SA6->A6_FILIAL == xFilial( "SA6" ) .And. SA6->(!Eof())

	IF nCaixinha <> 1
		If ALLTRIM(SA6->A6_COD) $ "CBX/CX1/DRS"
			SA6->(dbSkip())
			Loop
		EndIf
	ENDIF
	
	If SA6->A6_FLUXCAI <> "N"
                          
        nSaldoA := 0
        nSaldoF := 0

		// Saldo Anterior
		dbSelectArea("SE8")
		dbSetOrder(1)
		If ! dbSeek(xFilial("SE8")+SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON+DtoS( dDtAnt ),.T.)
			dbSkip( -1 )
		EndIf
	
		If SA6->A6_COD 		!= SE8->E8_BANCO	.or. ;
			SA6->A6_AGENCIA	!= SE8->E8_AGENCIA	.or. ;
			SA6->A6_NUMCON 	!= SE8->E8_CONTA	.or. ;
			SE8->E8_DTSALAT	>  dDtAnt
	
			dbSelectArea("SA6")
			dbSkip()
			Loop
		Else
			nMoedaBco := Iif(cPaisLoc=="BRA",1,Max(SA6->A6_MOEDA,1))
			nSaldoA   := xMoeda(SE8->E8_SALATUA,nMoedaBco,nMoeda,SE8->E8_DTSALAT,nDecs+1)
			nSaldoAnt += nSaldoA
		EndIf

		// Saldo Final
		dbSelectArea("SE8")
		dbSetOrder(1)
		If ! dbSeek(xFilial("SE8")+SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON+DtoS( dDtProc ),.T.)
		  	dbSkip( -1 )
		EndIf
	
		If SA6->A6_COD 		!= SE8->E8_BANCO	.or. ;
			SA6->A6_AGENCIA	!= SE8->E8_AGENCIA	.or. ;
			SA6->A6_NUMCON 	!= SE8->E8_CONTA	.or. ;
			SE8->E8_DTSALAT	>  dDtProc
	
			dbSelectArea("SA6")
			dbSkip()
			Loop
		Else
			nMoedaBco := Iif(cPaisLoc=="BRA",1,Max(SA6->A6_MOEDA,1))
			nSaldoF   := xMoeda(SE8->E8_SALATUA,nMoedaBco,nMoeda,SE8->E8_DTSALAT,nDecs+1)
		EndIf


		If nAplic == 1
			// Calculo das aplicações
			nValApl    := 0
			nVlrAplAtu := 0
			nSaldoApl  := 0
			nTotAplAtu := 0
			nTotSaldo  := 0
			
			dbSelectArea("SEH")
			dbGoTop()
			Do While !eof()
				If SEH->EH_BANCO == SA6->A6_COD .AND. SEH->EH_AGENCIA == SA6->A6_AGENCIA .AND. SEH->EH_CONTA == SA6->A6_NUMCON
					If !SEH->EH_TIPO $ cAplCotas .AND. SEH->EH_APLEMP == "APL" .AND. SEH->EH_DATA <= dDtProc
	
						//-- Calcular saldo pela movimentação, incluido em 05/05/15
						nValApl := SEH->EH_VALOR
						nValBP  := 0				
						nValJR  := 0				
						nValRG  := 0				
						nValI1  := 0				
						nValI2  := 0				
						nValVL  := 0				
						dbSelectArea("SEI")
						dbSetOrder(2)
	
						dbSeek(xFilial("SEI")+SEH->EH_APLEMP+SEH->EH_NUMERO+SEH->EH_REVISAO,.T.)
						Do While xFilial("SEI")+SEH->EH_APLEMP+SEH->EH_NUMERO+SEH->EH_REVISAO == xFilial("SEI")+SEI->EI_APLEMP+SEI->EI_NUMERO+SEI->EI_REVISAO .AND. !EOF()
					        If SEI->EI_VALOR > 0 .AND. SEI->EI_STATUS <> "C" .AND. SEI->EI_DATA <= dDtProc
						        If SEI->EI_TIPODOC = "BP"
									nValBP += SEI->EI_VALOR
						        ElseIf SEI->EI_TIPODOC = "JR"
									nValJR += SEI->EI_VALOR
						        ElseIf SEI->EI_TIPODOC = "RG"
									nValRG += SEI->EI_VALOR
						        ElseIf SEI->EI_TIPODOC = "I1"
									nValI1 += SEI->EI_VALOR
						        ElseIf SEI->EI_TIPODOC = "I2"
									nValI1 += SEI->EI_VALOR
						        ElseIf SEI->EI_TIPODOC = "VL"
									nValVL += SEI->EI_VALOR
								EndIf
							EndIf
							dbSkip()	
						EndDo
		
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Calculo da Aplicacao pelo CDI diario. A taxa informado refe-  ³
						//³ re-se ao %do valor do CDI que o banco paga pela aplicacao.    ³
						//³ Para uma melhor entendimento a taxa e' um percetual sobre uma ³
						//³ moeda cadastrada, sendo que o calculo e' atualizado dia a dia.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						/*
						Metodologia de calculo acumulado
				 
						O calculo do DI-CETIP acumulado entre datas eh efetuado atraves da seguinte formula:
						    n
						C = ä  (1+TDIk x (p / 100)), onde:
						    k-1
						    
						C -  Produtorio das taxas DI-CETIP Over com uso do percentual destacado, da data inicial (inclusive) ate a data final (exclusive), calculado com arredondamento de 8 (oito) casas decimais.
						n -  Numero total de taxas DI-CETIP Over, sendo "n" um numero inteiro.
						p -  Percentual destacado para a remuneracao, informado com 4 (quatro) casas decimais.
						TDIk- Taxa DI-CETIP Over, expressa ao dia, calculada com arredondamento de 8 (oito) casas decimais.
						
						--------------------------------------------
				
						Expressao de TDIk ate 31/12/1997
						
						TDIk = DIk / 3000, onde: k = 1, 2, ..., n
						 
						--------------------------------------------
						
						Expressao de TDIk a partir de 01/01/1998
						 
						TDIk = (((DIk / 100) + 1) ^(1/252)) - 1, onde: k = 1, 2, ..., n
						 
						
						DIk - Taxa DI-CETIP Over, informada com 2 (duas) casas decimais.
						
						Observacoes:
						
						1)    O fator resultante da expressao eh considerado com 16 (dezesseis) casas sem arredondamento.
						
						2)    Efetua-se o produtorio dos fatores diarios , sendo que a cada fator diario acumulado, trunca-se o resultado com 16 (dezesseis) casas decimais e 
								aplica-se o proximo fator diario, assim por diante ate o ultimo fator diario considerado.
						
						3)    Uma vez os fatores diarios estando acumulados como descrito acima, considera-se o fator resultante C com 8 (oito) decimais com arredondamento.
						*/
	
						nSaldoApl  := SEH->EH_VALOR - nValBP
						If ABS(nSaldoApl - SEH->EH_SALDO) <= 0.05
						   nSaldoApl := SEH->EH_SALDO
						EndIf
							
					    //--
						dbSelectArea("SEI")
						dbSetOrder(1)
					    
						//aCalculo	:= Fa171Calc(dDtProc,SEH->EH_SALDO,lResgate,,,,,,,,,.T.)     
						
	
						//If nVlrAplAtu > 0.02
						If nSaldoApl > 0
						
							aCalculo	:= Fa171Calc(dDtProc,nSaldoApl,.F.,,dDtProc)
							nIrfAplAtu  := xMoeda(aCalculo[2],1,1)   
							nIofAplAtu  := xMoeda(aCalculo[3],1,1)
							nJurAplAtu  := xMoeda(aCalculo[5],1,1)
							nVlrAplAtu  := xMoeda(aCalculo[1],1,1) //- xMoeda(aCalculo[5],1,1) //- xMoeda(nVlrImp1,1,1)	
	
							RecLock(cAliasTmp6,.T.)
							(cAliasTmp6)->EH_BANCO  	:= SA6->A6_COD
							(cAliasTmp6)->EH_AGENCIA 	:= SA6->A6_AGENCIA
							(cAliasTmp6)->EH_CONTA  	:= SA6->A6_NUMCON
							(cAliasTmp6)->EH_DATA   	:= SEH->EH_DATA
							(cAliasTmp6)->EH_VALOR  	:= SEH->EH_VALOR
							(cAliasTmp6)->EH_VALIRF    := nIrfAplAtu   //xMoeda(aCalculo[2],1,1)
							(cAliasTmp6)->EH_VALIOF    := nIofAplAtu   //xMoeda(aCalculo[3],1,1)
							(cAliasTmp6)->EH_VALJUR    := nJurAplAtu   //xMoeda(aCalculo[5],1,1)
							(cAliasTmp6)->EH_SALDO     := nSaldoApl
							(cAliasTmp6)->EH_VALCOR    := nVlrAplAtu   //xMoeda(aCalculo[1],1,1) - xMoeda(aCalculo[5],1,1) //- xMoeda(nVlrImp1,1,1)
							(cAliasTmp6)->EH_VALLIQ    := nVlrAplAtu - nIrfAplAtu - nIofAplAtu
							(cAliasTmp6)->EH_NUMERO    := SEH->EH_NUMERO
							(cAliasTmp6)->EH_TAXA      := SEH->EH_TAXA  
							(cAliasTmp6)->EH_CALC1     := aCalculo[1]
							MsUnlock()
	
							nTotAplAtu += nVlrAplAtu
							nTotSaldo  += nSaldoApl
	
						EndIf	
					EndIf
				EndIf	
				dbSelectArea("SEH")
				dbSkip()
			EndDo		
		EndIf		    

		dbSelectArea(cAliasTmp1)
		RecLock( cAliasTmp1, .T. )
		If nBancos <> 1
			(cAliasTmp1)->A6_OK  := "XX" 
		EndIf
		(cAliasTmp1)->A6_DATA    := dDataF 
		(cAliasTmp1)->A6_COD     := SA6->A6_COD	
		(cAliasTmp1)->A6_AGENCIA := SA6->A6_AGENCIA 	
		(cAliasTmp1)->A6_NUMCON  := SA6->A6_NUMCON 	
		(cAliasTmp1)->A6_NREDUZ  := SA6->A6_NREDUZ	
		(cAliasTmp1)->A6_SALDOA  := nSaldoA
		(cAliasTmp1)->A6_SALDOF  := nSaldoF 
		If nAplic == 1
			(cAliasTmp1)->EH_VALREG   := nTotSaldo
			(cAliasTmp1)->EH_VALOR    := nTotAplAtu
		EndIf		
		(cAliasTmp1)->(msUnlock())
	EndIf
	SA6->(dbSkip())
EndDo

If nBancos == 1
	(cAliasTmp1)->( dbGotop() )
	DEFINE MSDIALOG oDlg TITLE "Selecione os Bancos que deverão ser considerados" From 009,000 To 030,063 OF oMainWnd
	oMark := MsSelect():New(cAliasTmp1,"A6_OK","",aCamposB2,@lInverte,@cMarca,{20,2,140,248})
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{|| nOpca := 2}) CENTERED

	dbSelectArea(cAliasTmp1)
	dbGoTop()
	Do While !EOF()
		If !EMPTY((cAliasTmp1)->A6_OK)
		    cTitBanco += IIF(EMPTY(cTitBanco),"","/")+TRIM((cAliasTmp1)->A6_NREDUZ)
		EndIf
		dbSkip()
	EndDo
EndIf
		
Return Nil


/*/
Movimentação bancaria
*/

Static Function KFin01ExpMov()


aResumo[1]	:= 0
aResumo[2]	:= 0
aResumo[3]	:= 0
aResumo[4]	:= 0
aResumo[5]	:= 0
aResumo[6]	:= 0
aResumo[7]	:= 0
aResumo[8]	:= 0
aResumo[9]	:= 0
aResumo[10] := 0
aResumo[11] := 0
aResumo[12] := 0
         

// Temporário Sintético - Natureza Financeira
// ----------------------------------------------------------------------------------

AADD(aTitulos2,cNomePrg+"/"+TRIM(SUBSTR(cUsuario,7,15))+" - "+cTitulo+OemToAnsi(" - Sintético - Natureza Financeira"))

// Conta Financeira
AADD(aStruct2,{"CTFIN","C",10,0})
AADD(aCampos2,cAliasTmp2+"->CTFIN")
//AADD(aCabs2  ,"Cta Financeira")
AADD(aCabs2  ,"Natureza Financeira")

// Descricao da Conta Financeira
AADD(aStruct2,{"DESCRCT","C",50,0})
AADD(aCampos2,cAliasTmp2+"->DESCRCT")
AADD(aCabs2  ,"Descricao")

// Recebidos
AADD(aStruct2,{"RECEBIDOS","N",20,2})
AADD(aCampos2,cAliasTmp2+"->RECEBIDOS")
AADD(aCabs2  ,"Recebidos")

// Pagos
AADD(aStruct2,{"PAGOS","N",20,2})
AADD(aCampos2,cAliasTmp2+"->PAGOS")
AADD(aCabs2  ,"Pagos")


oTmpTb2 := FWTemporaryTable():New( cAliasTmp2 ) 
oTmpTb2:SetFields( aStruct2 )
oTmpTb2:AddIndex("indice2", {"CTFIN"} )
oTmpTb2:Create()

///cArqTmp2 := CriaTrab(aStruct2)
///dbUseArea(.T.,,cArqTmp2,cAliasTmp2,if(.F. .OR. .F.,!.F., NIL),.F.)

///IndRegua (cAliasTmp2,cArqTmp2,"CTFIN",,,OemToAnsi("Selecionando Registros...") )  //
dbSelectArea(cAliasTmp2)
dbSetOrder(1)


// Temporário Sintético - Centro de Custo
// ----------------------------------------------------------------------------------

AADD(aTitulos4,cNomePrg+"/"+TRIM(SUBSTR(cUsuario,7,15))+" - "+cTitulo+OemToAnsi(" - Sintético - Centro de Custo"))

// Centro de Custo
AADD(aStruct4,{"CC","C",09,0})
AADD(aCampos4,cAliasTmp4+"->CC")
AADD(aCabs4  ,"Centro de Custo")

// Descricao da Centro de Custo
AADD(aStruct4,{"DESCRCC","C",40,0})
AADD(aCampos4,cAliasTmp4+"->DESCRCC")
AADD(aCabs4  ,"Descricao CC")

// Recebidos
AADD(aStruct4,{"RECEBIDOS","N",20,2})
AADD(aCampos4,cAliasTmp4+"->RECEBIDOS")
AADD(aCabs4  ,"Recebidos")

// Pagos
AADD(aStruct4,{"PAGOS","N",20,2})
AADD(aCampos4,cAliasTmp4+"->PAGOS")
AADD(aCabs4  ,"Pagos")

oTmpTb4 := FWTemporaryTable():New( cAliasTmp4 ) 
oTmpTb4:SetFields( aStruct4 )
oTmpTb4:AddIndex("indice4", {"CC"} )
oTmpTb4:Create()


///cArqTmp4 := CriaTrab(aStruct4)
///dbUseArea(.T.,,cArqTmp4,cAliasTmp4,if(.F. .OR. .F.,!.F., NIL),.F.)

///IndRegua (cAliasTmp4,cArqTmp4,"CC",,,OemToAnsi("Selecionando Registros...") ) 

dbSelectArea(cAliasTmp4)
dbSetOrder(1)


// Temporário Sintético - Desc Financeiro
// ----------------------------------------------------------------------------------

AADD(aTitulos5,cNomePrg+"/"+TRIM(SUBSTR(cUsuario,7,15))+" - "+cTitulo+OemToAnsi(" - Sintético - Financeiro"))


// Descricao Financeiro
AADD(aStruct5,{"DESCFIN","C",40,0})
AADD(aCampos5,cAliasTmp5+"->DESCFIN")
AADD(aCabs5  ,"Descricao Financeiro")

// Recebidos
AADD(aStruct5,{"RECEBIDOS","N",20,2})
AADD(aCampos5,cAliasTmp5+"->RECEBIDOS")
AADD(aCabs5  ,"Recebidos")

// Pagos
AADD(aStruct5,{"PAGOS","N",20,2})
AADD(aCampos5,cAliasTmp5+"->PAGOS")
AADD(aCabs5  ,"Pagos")

oTmpTb5 := FWTemporaryTable():New( cAliasTmp5 ) 
oTmpTb5:SetFields( aStruct5 )
oTmpTb5:AddIndex("indice5", {"DESCFIN"} )
oTmpTb5:Create()

///cArqTmp5 := CriaTrab(aStruct5)
///dbUseArea(.T.,,cArqTmp5,cAliasTmp5,if(.F. .OR. .F.,!.F., NIL),.F.)

///IndRegua (cAliasTmp5,cArqTmp5,"DESCFIN",,,OemToAnsi("Selecionando Registros...") )  //
dbSelectArea(cAliasTmp5)
dbSetOrder(1)


// Temporário Analítico
// ----------------------------------------------------------------------------------

AADD(aTitulos3,cNomePrg+"/"+TRIM(SUBSTR(cUsuario,7,15))+" - "+cTitulo+OemToAnsi(" - Analitico"))

/*
// Conta Natureza
AADD(aStruct3,{"XXCTFIN","C",10,0})
AADD(aCampos3,cAliasTmp3+"->XXCTFIN")
AADD(aCabs3  ,"Natureza Financeira")

// Descricao da Conta Financeira
AADD(aStruct3,{"DESCRCT","C",50,0})
AADD(aCampos3,cAliasTmp3+"->DESCRCT")
AADD(aCabs3  ,"Descricao Natureza")
*/

// Centro de Custo
AADD(aStruct3,{"XXCC","C",09,0})
AADD(aCampos3,cAliasTmp3+"->XXCC")
AADD(aCabs3  ,"Centro de Custo")

// Centro de Custo
AADD(aStruct3,{"DESCRCC","C",40,0})
AADD(aCampos3,cAliasTmp3+"->DESCRCC")
AADD(aCabs3  ,"Descricao CC")

// Produto
AADD(aStruct3,{"B1_COD","C",GetSx3Cache("B1_COD", "X3_TAMANHO"),0})
AADD(aCampos3,cAliasTmp3+"->B1_COD")
AADD(aCabs3  ,"Produto")

// Descrição do Produto
AADD(aStruct3,{"B1_DESC","C",GetSx3Cache("B1_DESC", "X3_TAMANHO"),0})
AADD(aCampos3,cAliasTmp3+"->B1_DESC")
AADD(aCabs3  ,"Descrição do produto")


// Descricao Financeiro - Excluido em 24/09/15
//AADD(aStruct3,{"DESCFIN","C",40,0})
//AADD(aCampos3,cAliasTmp3+"->DESCFIN")
//AADD(aCabs3  ,"Descrição Financeiro")


// Data
AADD(aStruct3,{"E5_DATA","D",8,0})
AADD(aCampos3,cAliasTmp3+"->E5_DATA")
AADD(aCabs3  ,"Data")
                   
// Tipo
AADD(aStruct3,{"E5_TIPO","C",GetSx3Cache("E5_TIPO", "X3_TAMANHO"),0})
AADD(aCampos3,cAliasTmp3+"->E5_TIPO")
AADD(aCabs3  ,"Tipo")

// Valor
AADD(aStruct3,{"E5_VALOR","N",GetSx3Cache("E5_VALOR", "X3_TAMANHO"),GetSx3Cache("E5_VALOR", "X3_DECIMAL")})
AADD(aCampos3,cAliasTmp3+"->E5_VALOR")
AADD(aCabs3  ,"Valor")

// Banco
AADD(aStruct3,{"E5_BANCO","C",GetSx3Cache("E5_BANCO", "X3_TAMANHO"),0})
AADD(aCampos3,cAliasTmp3+"->E5_BANCO")
AADD(aCabs3  ,RetTitle("E5_BANCO"))

// Agencia
AADD(aStruct3,{"E5_AGENCIA","C",GetSx3Cache("E5_AGENCIA", "X3_TAMANHO"),0})
AADD(aCampos3,cAliasTmp3+"->E5_AGENCIA")
AADD(aCabs3  ,RetTitle("E5_AGENCIA"))

// Conta
AADD(aStruct3,{"E5_CONTA","C",GetSx3Cache("E5_CONTA", "X3_TAMANHO"),0})
AADD(aCampos3,cAliasTmp3+"->E5_CONTA")
AADD(aCabs3  ,"Conta")

// Cheque
AADD(aStruct3,{"E5_NUMCHEQ","C",GetSx3Cache("E5_NUMCHEQ", "X3_TAMANHO"),0})
AADD(aCampos3,cAliasTmp3+"->E5_NUMCHEQ")
AADD(aCabs3  ,RetTitle("E5_NUMCHEQ"))

// Beneficiario
AADD(aStruct3,{"E5_BENEF","C",GetSx3Cache("E5_BENEF", "X3_TAMANHO"),0})
AADD(aCampos3,cAliasTmp3+"->E5_BENEF")
AADD(aCabs3  ,RetTitle("E5_BENEF"))

// Histórico
If nFormato == 1
	AADD(aStruct3,{"E5_HISTOR","M",10,0})
	AADD(aCampos3,cAliasTmp3+"->E5_HISTOR")
	AADD(aCabs3  ,"Historico")
Else
	AADD(aStruct3,{"E5_HISTOR","C",200,0})
	AADD(aCampos3,cAliasTmp3+"->E5_HISTOR")
	AADD(aCabs3  ,"Historico")

	//AADD(aStruct3,{"E5_HISTOR2","C",200,0})
	//AADD(aCampos3,cAliasTmp3+"->E5_HISTOR2")
	//AADD(aCabs3  ,"Cont. Historico")
EndIf

// Titulo
AADD(aStruct3,{"E5_NUMERO","C",GetSx3Cache("E5_NUMERO", "X3_TAMANHO"),0})
AADD(aCampos3,cAliasTmp3+"->E5_NUMERO")
AADD(aCabs3  ,RetTitle("E5_NUMERO"))

// Recebidos
AADD(aStruct3,{"RECEBIDO","N",20,2})
AADD(aCampos3,cAliasTmp3+"->RECEBIDO")
AADD(aCabs3  ,"Recebido")

// Pagos
AADD(aStruct3,{"PAGO","N",20,2})
AADD(aCampos3,cAliasTmp3+"->PAGO")
AADD(aCabs3  ,"Pago")

IF nUsuario == 1

	// Digitado
	AADD(aStruct3,{"DIGITADO","C",100,0})
	AADD(aCampos3,cAliasTmp3+"->DIGITADO")
	AADD(aCabs3  ,"Digitado")

	// Liberado
	AADD(aStruct3,{"LIBERADO","C",100,0})
	AADD(aCampos3,cAliasTmp3+"->LIBERADO")
	AADD(aCabs3  ,"Liberado")

ENDIF

oTmpTb3 := FWTemporaryTable():New( cAliasTmp3 ) 
oTmpTb3:SetFields( aStruct3 )
oTmpTb3:AddIndex("indice3", {"XXCC"} )
oTmpTb3:Create()

///cArqTmp3 := CriaTrab(aStruct3)
///dbUseArea(.T.,,cArqTmp3,cAliasTmp3,if(.F. .OR. .F.,!.F., NIL),.F.)
///IndRegua (cAliasTmp3,cArqTmp3,"XXCC",,,OemToAnsi("Selecionando Registros...") )  //

dbSelectArea(cAliasTmp3)
dbSetOrder(1)


// Grava os arquivos temporários
// ----------------------------------------------------------------------------------


ProcRegua(100)
Processa( {|| KFin01Mov( nSaldoAnt)})

/* removido geração sintetico
ProcRegua((cAliasTmp2)->(LASTREC()))
Processa( {|| U_GeraCSV(cAliasTmp2,cNomePrg+"-Sintetico"+STR(nTpData,1),aTitulos2,aCampos2,aCabs2)})

ProcRegua((cAliasTmp4)->(LASTREC()))
Processa( {|| U_GeraCSV(cAliasTmp4,cNomePrg+"-Sintetico_CC"+STR(nTpData,1),aTitulos4,aCampos4,aCabs4)})

ProcRegua((cAliasTmp5)->(LASTREC()))
Processa( {|| U_GeraCSV(cAliasTmp5,cNomePrg+"-Sintetico_Fin"+STR(nTpData,1),aTitulos5,aCampos5,aCabs5)})
*/

If nFormato == 1
	ProcRegua((cAliasTmp3)->(LASTREC()))
	If !EMPTY(cFiltPrd)
		dbSelectArea(cAliasTmp3)
		cFiltro := "B1_COD = '"+cFiltPrd+"'"
		(cAliasTmp3)->(dbsetfilter({|| &cFiltro} , cFiltro))
	EndIf
	
	Processa( {|| U_GeraCSV(cAliasTmp3,cNomePrg+"-Analitico"+STR(nTpData,1),aTitulos3,aCampos3,aCabs3)})
Else
	//aPlans := {}
	
	If !EMPTY(cFiltPrd)
		cFiltro := "B1_COD = '"+cFiltPrd+"'"
	EndIf
	
	AADD(aPlans,{cAliasTmp3,cNomePrg+"-Analitico",cFiltro,cTitulo+OemToAnsi(" - Analitico"),aCampos3,aCabs3,aImpr3, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
	If nSaldos == 1                                              
		AADD(aPlans,{cAliasTmp1,cNomePrg+"-Saldos Bancários","!EMPTY("+cAliasTmp1+"->A6_OK)",OemToAnsi("Fluxo de Caixa Realizado - Saldos bancários"),aCampos1,aCabs1,aImpr1, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
		If nAplic == 1
			AADD(aPlans,{cAliasTmp6,cNomePrg+"-Aplicações","",OemToAnsi("Fluxo de Caixa Realizado - Aplicações"),aCampos6,aCabs6,aImpr6, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
		EndIf
	EndIf

	U_GeraXml(aPlans,cTitulo,cPerg,.F.)
EndIf

oTmpTb2:Delete() 
///(cAliasTmp2)->(dbCloseArea())
///fErase( cArqTmp2 + OrdBagExt() )
///fErase( cArqTmp2 + GetDBExtension() )

If SELECT(cAliasTmp3) > 0
	oTmpTb3:Delete() 
	//(cArqTmp3)->(dbCloseArea())
	///fErase( cArqTmp3 + OrdBagExt() )
	///fErase( cArqTmp3 + GetDBExtension() )
EndIf

oTmpTb4:Delete() 
///(cAliasTmp4)->(dbCloseArea())
///fErase( cArqTmp4 + OrdBagExt() )
///fErase( cArqTmp4 + GetDBExtension() )

oTmpTb5:Delete() 
///(cAliasTmp5)->(dbCloseArea())
///fErase( cArqTmp5 + OrdBagExt() )
///fErase( cArqTmp5 + GetDBExtension() )

If SELECT(cAliasTmp6) > 0
	oTmpTb6:Delete() 
	///(cAliasTmp6)->(dbCloseArea())
	///fErase( cArqTmp6 + OrdBagExt() )
	///fErase( cArqTmp6 + GetDBExtension() )
EndIf

dbSelectArea("SE5")
dbCloseArea()
ChKFile("SE5")
dbSetOrder(1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FrK01Grav³ Autor ³ Alessandro B. Freire  ³ Data ³ 07/04/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtra os registros do SE5 e Cria um arquivo Tempor rio		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FrK01Grava(nSaldoAnt, cArqTmp1)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nSaldoAnt - Saldo Anterior dos bancos							  ³±±
±±³			 ³ cArqTmp1	 - Nome do Arquivo tempor rio. Deve ser passado   ³±±
±±³			 ³ 				por parƒmetro. 										  ³±±
±±³			 ³ aResumo	 - Resumo financeiro, por tipo de aplica‡Æo. Deve ³±±
±±³			 ³ 				ser passado por parƒmetro. 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ BKFINR10																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION KFin01Mov( nSaldoAnt )

LOCAL dDataAnt
LOCAL nPagos     := 0
LOCAL nRecebidos := 0

LOCAL nPagar     := 0
LOCAL nReceber   := 0

LOCAL aStru 	 := SE5->(dbStruct())
LOCAL nI         := 0
LOCAL cOrder

LOCAL cCtaFin    := SPACE(12)
LOCAL cDescrCt   := ""
LOCAL cTHist 	 := ""

LOCAL cDigitado  := ""
LOCAL cLiberado  := ""
LOCAL cProduto   := ""
LOCAL lFiltPrd   := .F.


dbSelectArea("SE2")
dbSetOrder(1)

dbSelectArea("SE5")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria o indice para o SE5 por E5_DATA		  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dDataAnt 	:= MV_PAR01 - 1

IF nTpData == 1	
	cOrder := SqlOrder(IndexKey())
	cQuery := "SELECT *, R_E_C_N_O_ AS E5_XXRECNO,
	cQuery += "(SELECT TOP 1 'CANC' FROM "+RetSqlName("SE5")+" SE52 WHERE SE52.D_E_L_E_T_ = '' "
	cQuery += " AND SE52.E5_BANCO=SE5.E5_BANCO "
	cQuery += " AND SE52.E5_AGENCIA=SE5.E5_AGENCIA "
	cQuery += " AND SE52.E5_CONTA=SE5.E5_CONTA "
	cQuery += " AND SE52.E5_NUMCHEQ=SE5.E5_NUMCHEQ "
	cQuery += " AND SE52.E5_VALOR=SE5.E5_VALOR "
	cQuery += " AND SE52.E5_NATUREZ='NTCHEST' "
	cQuery += " AND SE52.R_E_C_N_O_>SE5.R_E_C_N_O_ "
	cQuery += "  ) AS CANC "
	cQuery += " FROM " + RetSqlName("SE5")+" SE5"
	cQuery += " WHERE E5_FILIAL = '" + xFilial("SE5") + "'"
	cQuery += " AND E5_DATA    >= '" + DTOS(dDataI) + "'"   
	cQuery += " AND E5_DATA    <= '" + DTOS(dDataF) + "'" 
	cQuery += " AND E5_TIPODOC NOT IN  ('BA','MT','CM','DC','JR','CP','M2','C2','D2','J2','V2')"
	cQuery += " AND E5_MOTBX   <> 'CMP'"
	cQuery += " AND E5_SITUACA <> 'C'"
	cQuery += " AND D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY " + cOrder
ELSE
	cOrder := StrTran(SqlOrder(IndexKey()), "E5_DATA", "E5_DTDISPO")
	cQuery := "SELECT *, R_E_C_N_O_ AS E5_XXRECNO, "
	cQuery += "(SELECT TOP 1 'CANC' FROM "+RetSqlName("SE5")+" SE52 WHERE SE52.D_E_L_E_T_ = '' "
	cQuery += " AND SE52.E5_BANCO=SE5.E5_BANCO "
	cQuery += " AND SE52.E5_AGENCIA=SE5.E5_AGENCIA "
	cQuery += " AND SE52.E5_CONTA=SE5.E5_CONTA "
	cQuery += " AND SE52.E5_NUMCHEQ=SE5.E5_NUMCHEQ "
	cQuery += " AND SE52.E5_VALOR=SE5.E5_VALOR "
	cQuery += " AND SE52.E5_NATUREZ='NTCHEST' "
	cQuery += " AND SE52.R_E_C_N_O_>SE5.R_E_C_N_O_ "
	cQuery += "  ) AS CANC "
	cQuery += " FROM " + RetSqlName("SE5")+" SE5"
	cQuery += " WHERE E5_FILIAL = '" + xFilial("SE5") + "'"
	cQuery += " AND E5_DTDISPO    >= '" + DTOS(dDataI) + "'"   
	cQuery += " AND E5_DTDISPO    <= '" + DTOS(dDataF) + "'" 
	cQuery += " AND E5_TIPODOC NOT IN  ('BA','MT','CM','DC','JR','CP','M2','C2','D2','J2','V2')"
	cQuery += " AND E5_MOTBX   <> 'CMP'"
	cQuery += " AND E5_SITUACA <> 'C'"
	cQuery += " AND D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY " + cOrder
ENDIF
cQuery := ChangeQuery(cQuery)

dbSelectArea("SE5")
dbCloseArea()

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'SE5', .T., .T.)

For nI := 1 to Len(aStru)
	If aStru[nI,2] != 'C'
		TCSetField('SE5', aStru[nI,1], aStru[nI,2],aStru[nI,3],aStru[nI,4])
	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procura pela 1a. Movim. na data indicada.	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

IF nTpData == 1
	dDataAnt 	:= SE5->E5_DATA
	bCondWhile := { || !SE5->(Eof()) .And. SE5->E5_DATA <= dDataF .And. xFilial("SE5") == SE5->E5_FILIAL }
ELSE
	dDataAnt 	:= SE5->E5_DTDISPO
	bCondWhile := { || !SE5->(Eof()) .And. SE5->E5_DTDISPO <= dDataF .And. xFilial("SE5") == SE5->E5_FILIAL }
ENDIF	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava as movimenta‡äes do E5 no tempor rio.   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//While ! SE5->( eof()) .And. SE5->E5_DATA <= dDataF .And. xFilial("SE5") == SE5->E5_FILIAL
ProcRegua(LastRec()) // Numero de registros a processar
While Eval(bCondWhile)


    IncProc()

	cDigitado := ""
	cLiberado := ""
	cProduto  := ""
	lFiltPrd  := .F.

	dbSelectArea("SE5")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava as movimenta‡äes do E5 no tempor rio.   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SA6->(dbSeek(xFilial()+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA))
		If SA6->A6_FLUXCAI == "N"
			SE5->( dbSkip() )
			Loop
		Endif
	Endif

	If nBancos == 1 
		if (cAliasTmp1)->(!dbseek(SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA)) .or. empty((cAliasTmp1)->A6_OK)
			SE5->( dbSkip() )
			Loop
		endif
	EndIf

    // INCLUI MOVIMENTO DE CAIXINHA 
	IF nCaixinha <> 1
		If ALLTRIM(SE5->E5_BANCO) $ "CBX/CX1/DRS"
			SE5->( dbSkip() )
			Loop
		EndIf
	ENDIF

    cCtaFin := ""
	If !Empty(SE5->E5_NUMERO)
		If SE5->E5_RECPAG == "R"
			If SE1->( dbSeek(xFilial()+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO) )
				If SE1->E1_FLUXO == "N"
					SE5->( dbSkip() )
					Loop
				Endif

				cCtaFin := SE1->E1_NATUREZ //SE1->E1_XXCTFIN
			Endif
		Else
			dbSelectArea("SE2")
			If SE2->( dbSeek(xFilial("SE2")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR) )
				If SE2->E2_FLUXO == "N"
					SE5->( dbSkip() )
					Loop
				Endif

				cCtaFin := SE2->E2_NATUREZ //SE2->E2_XXCTFIN
                
				// Em caso de PA, tentar achar a ctafin do titulo (isso parece desnecessário)
				IF EMPTY(cCtaFin) .AND. ALLTRIM(SE5->E5_TIPO) == "PA" .AND. !EMPTY(SE5->E5_DOCUMEN) 
					IF SE2->( dbSeek(xFilial("SE2")+SE5->E5_DOCUMEN) )
						cCtaFin := SE2->E2_NATUREZ  //SE2->E2_XXCTFIN
					ENDIF	
				ENDIF
							
			Endif
		Endif
	Endif
	
	If EMPTY(cCtaFin)
		cCtaFin :=  SE5->E5_NATUREZ //SE5->E5_XXCTFIN
	EndIf
	

	nReceber := 0
	nPagar   := 0
	
		
	If SE5->E5_RECPAG == "R"
	   nReceber    := SE5->E5_VALOR //xMoeda(SE5->E5_VALOR - SE5->E5_VLJUROS - SE5->E5_VLMULTA,nMoedaBco,nMoeda,SE5->E5_DATA,nDecs+1)
       nRecebidos  += nReceber
	Else                      
	   nPagar      := SE5->E5_VALOR //xMoeda(SE5->E5_VALOR - SE5->E5_VLJUROS - SE5->E5_VLMULTA,nMoedaBco,nMoeda,SE5->E5_DATA,nDecs+1)
       nPagos      += nPagar
	EndIf

	IF EMPTY(cCtaFin)
	   IF SED->(dbSeek(xFilial("SED")+SE5->E5_NATUREZ,.F.))
	   		cCtaFin := SED->ED_CLVLDB
			IF EMPTY(cCtaFin)
		   		cCtaFin := SED->ED_CLVLCR
		   	ENDIF	
	   ENDIF
	ENDIF 


	IF EMPTY(cCtaFin)
		cCtaFin := STRZERO(SE5->E5_XXRECNO,6)+"-"+SE5->E5_NATUREZ
	ENDIF	
		
		// Gravar sintetico
		
		dbSelectArea("SED")
		dbSetOrder(1)
		IF SED->(dbSeek(xFilial("SED")+cCtaFin,.F.))
			cDescrCt := SED->ED_DESCRIC
		ELSE
			cDescrCt := SE5->E5_TIPO+TRIM(SE5->E5_DOCUMEN)+ " "+ALLTRIM(SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA)+" "+TRIM(SE5->E5_BENEF)
		ENDIF   

		dbSelectArea(cAliasTmp2)
		IF !dbSeek(cCtaFin)
			RecLock( cAliasTmp2, .T. )
			(cAliasTmp2)->CTFIN    := cCtaFin
		ELSE 
			RecLock( cAliasTmp2, .F. )
		ENDIF
		(cAliasTmp2)->DESCRCT    := cDescrCt
		(cAliasTmp2)->RECEBIDOS  += nReceber
		(cAliasTmp2)->PAGOS      += nPagar
		msUnlock()

		nFin := 3 // DESCRIÇÃO FINANCEIROA
  	

		If SE5->E5_RECPAG == "R"

			aTot := {}
			nTot := 0
			cTHist := ""
			
   			cProduto := ""
   			lFiltPrd := .F.

			dbSelectArea ("SD2")   
			SD2->(dbSetOrder(3))               //filial,doc,serie,cliente,loja,cod
			SD2->(dbSeek(xFilial("SD2")+SE5->E5_NUMERO+SE5->E5_PREFIXO+SE5->E5_CLIFOR+SE5->E5_LOJA,.T.))
			DO WHILE SD2->(!EOF()) .and. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == ;
				xFilial("SD2")+SE5->E5_NUMERO+SE5->E5_PREFIXO+SE5->E5_CLIFOR+SE5->E5_LOJA
				nTot:= 0
				nTot:= aScan(aTot,{|x| x[1]==SD2->D2_CCUSTO })
                IF nTot > 0
                	aTot[nTot,2] += SD2->D2_TOTAL
                ELSE
					AADD(aTot,{SD2->D2_CCUSTO,SD2->D2_TOTAL})
				ENDIF
				cHist := ""
           		cHist := "Rec. NF nº:"+SD2->D2_DOC+" série:"+SD2->D2_SERIE
				IF !(cHist $ cTHist )
					cTHist += cHist
				ENDIF
                IF EMPTY(cTHist)
                	cTHist  := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")
                ENDIF
                nFin := 3
				
				// Se algum produto satisfazer o filtro, considerá-lo
				IF !EMPTY(cFiltPrd) .AND. TRIM(SD2->D2_COD) == TRIM(cFiltPrd)
				   lFiltPrd  := .T.
				   cProduto  := SD2->D2_COD
				ENDIF

				IF EMPTY(cProduto) .OR. cProduto == SD2->D2_COD // .OR. Incluído em 11/08/16 para considerar itens repetidos 
					cProduto := SD2->D2_COD
				ELSEIF !lFiltPrd 
					cProduto := "DIVERSOS"
				ENDIF

				SD2->(dbSkip())
			ENDDO
			
			IF LEN(aTot) > 0           
		
				aTot := U_Rateia(aTot,nReceber)
				IX := 0
				FOR IX := 1 TO LEN(aTot)
			    	cCC := aTot[IX,1]
			    	cDescrCC := Posicione("CTT",1,xFilial("CTT")+cCC,"CTT_DESC01")
 
					dbSelectArea(cAliasTmp4)
					IF !dbSeek(cCC)
						RecLock( cAliasTmp4, .T. )
						(cAliasTmp4)->CC    := cCC
					ELSE 
						RecLock( cAliasTmp4, .F. )
					ENDIF
					(cAliasTmp4)->DESCRCC    := cDescrCC
					(cAliasTmp4)->RECEBIDOS  += aTot[IX,2]
					(cAliasTmp4)->PAGOS      += nPagar
					msUnlock()
 
                   IF TRIM(cCC) <> "000000001"
                    	cDESCFIN := "" 
                    	cDESCFIN := ALLTRIM(aSitFin[1]) //Total Clientes
                    ELSE
                    	IF SE5->E5_TIPO $ "TX #ISS#TXA#INS"
                    		nFin := 8
                    	ENDIF
                     	cDESCFIN := "" 
                    	cDESCFIN := ALLTRIM(aSitFin[nFin]) //Descrição Financeira
                    ENDIF
 
 
					dbSelectArea(cAliasTmp5)
					IF !dbSeek(cDESCFIN)
						RecLock( cAliasTmp5, .T. )
						(cAliasTmp5)->DESCFIN := cDESCFIN
					ELSE 
						RecLock( cAliasTmp5, .F. )
					ENDIF
					(cAliasTmp5)->RECEBIDOS  += aTot[IX,2]
					(cAliasTmp5)->PAGOS      += nPagar
					msUnlock()
                    
					
					// Gravar analitico
					RecLock( cAliasTmp3, .T. )
					//(cAliasTmp3)->XXCTFIN    := cCtaFin
					//(cAliasTmp3)->DESCRCT    := cDescrCt
					(cAliasTmp3)->XXCC   	 := cCC
					(cAliasTmp3)->DESCRCC    := cDescrCC
					//(cAliasTmp3)->DESCFIN    := cDESCFIN
					(cAliasTmp3)->B1_COD     := cProduto
					IF !EMPTY(cProduto)
						(cAliasTmp3)->B1_DESC := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
					ENDIF
					(cAliasTmp3)->E5_TIPO    := SE5->E5_TIPO
					(cAliasTmp3)->E5_DATA    := IIF(nTpData == 1,SE5->E5_DATA,SE5->E5_DTDISPO)
					(cAliasTmp3)->E5_HISTOR  := IIF(!EMPTY(cTHist),STRTRAN(cTHist,';',','),SE5->E5_HISTOR)
					//If nFormato == 2
					//	(cAliasTmp3)->E5_HISTOR2  := SUBSTR(IIF(!EMPTY(cTHist),STRTRAN(cTHist,';',','),SE5->E5_HISTOR),201,200)
					//EndIf
					(cAliasTmp3)->E5_BENEF   := SE5->E5_BENEF
					//(cAliasTmp3)->E5_TIPODOC := SE5->E5_TIPODOC
					(cAliasTmp3)->E5_BANCO   := SE5->E5_BANCO
					(cAliasTmp3)->E5_AGENCIA := SE5->E5_AGENCIA
					(cAliasTmp3)->E5_CONTA   := SE5->E5_CONTA
					(cAliasTmp3)->E5_NUMCHEQ := SE5->E5_NUMCHEQ
					//(cAliasTmp3)->E5_PREFIXO := SE5->E5_PREFIXO
					(cAliasTmp3)->E5_NUMERO  := SE5->E5_NUMERO
					//(cAliasTmp3)->E5_PARCELA := SE5->E5_PARCELA
					//(cAliasTmp3)->E5_CLIFOR  := SE5->E5_CLIFOR
					//(cAliasTmp3)->E5_LOJA    := SE5->E5_LOJA
					(cAliasTmp3)->E5_VALOR   := aTot[IX,2]
					//(cAliasTmp3)->E5_RECPAG  := SE5->E5_RECPAG
					(cAliasTmp3)->RECEBIDO   := aTot[IX,2]
					(cAliasTmp3)->PAGO       := nPagar
					IF nUsuario == 1
						(cAliasTmp3)->DIGITADO   := Capital(cDigitado)
						(cAliasTmp3)->LIBERADO   := Capital(cLiberado)
                    ENDIF
					msUnlock()
				NEXT
			ELSE
			
			    IF 	EMPTY(SE5->E5_PREFIXO) .AND. EMPTY(SE5->E5_NUMERO) .AND. EMPTY(SE5->E5_PARCELA) .AND. EMPTY(SE5->E5_CLIFOR)
					nFin := 4
				ELSE
					nFin := 3
				ENDIF
			    cCC := ""
			    cDescrCC := ""
		    	cCC := "000000001"
			    cDescrCC := Posicione("CTT",1,xFilial("CTT")+cCC,"CTT_DESC01")

				dbSelectArea(cAliasTmp4)
				IF !dbSeek(cCC)
					RecLock( cAliasTmp4, .T. )
					(cAliasTmp4)->CC    := cCC
				ELSE 
					RecLock( cAliasTmp4, .F. )
				ENDIF
				(cAliasTmp4)->DESCRCC    := cDescrCC
				(cAliasTmp4)->RECEBIDOS  += nReceber
				(cAliasTmp4)->PAGOS      += nPagar
				msUnlock()

				IF TRIM(cCC) <> "000000001"
                   	cDESCFIN := "" 
                   	cDESCFIN := ALLTRIM(aSitFin[1]) //Total Clientes
                ELSE
                   	IF SE5->E5_TIPO $ "TX #ISS#TXA#INS"
                   		nFin := 8
                   	ENDIF
                
                   	cDESCFIN := "" 
                   	cDESCFIN := ALLTRIM(aSitFin[nFin]) //DESCRIÇÃO FINACEIRO
                ENDIF
 
				dbSelectArea(cAliasTmp5)
				IF !dbSeek(cDESCFIN)
					RecLock( cAliasTmp5, .T. )
					(cAliasTmp5)->DESCFIN := cDESCFIN
				ELSE 
					RecLock( cAliasTmp5, .F. )
				ENDIF
				(cAliasTmp5)->RECEBIDOS  += nReceber
				(cAliasTmp5)->PAGOS      += nPagar
				msUnlock()
			    
			
				// Gravar analitico
				RecLock( cAliasTmp3, .T. )
				//(cAliasTmp3)->XXCTFIN    := cCtaFin
				//(cAliasTmp3)->DESCRCT    := cDescrCt
				(cAliasTmp3)->XXCC   	 := cCC
				(cAliasTmp3)->DESCRCC    := cDescrCC
				//(cAliasTmp3)->DESCFIN    := cDESCFIN
				(cAliasTmp3)->B1_COD     := cProduto
				IF !EMPTY(cProduto)
					(cAliasTmp3)->B1_DESC := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
				ENDIF
				(cAliasTmp3)->E5_TIPO    := SE5->E5_TIPO
				(cAliasTmp3)->B1_COD     := cProduto
				IF !EMPTY(cProduto)
					(cAliasTmp3)->B1_DESC := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
				ENDIF
				(cAliasTmp3)->E5_DATA    := IIF(nTpData == 1,SE5->E5_DATA,SE5->E5_DTDISPO)
				(cAliasTmp3)->E5_HISTOR  := SE5->E5_HISTOR
				(cAliasTmp3)->E5_BENEF   := SE5->E5_BENEF
				//(cAliasTmp3)->E5_TIPODOC := SE5->E5_TIPODOC
				(cAliasTmp3)->E5_BANCO   := SE5->E5_BANCO
				(cAliasTmp3)->E5_AGENCIA := SE5->E5_AGENCIA
				(cAliasTmp3)->E5_CONTA   := SE5->E5_CONTA
				(cAliasTmp3)->E5_NUMCHEQ := SE5->E5_NUMCHEQ
				//(cAliasTmp3)->E5_PREFIXO := SE5->E5_PREFIXO
				(cAliasTmp3)->E5_NUMERO  := SE5->E5_NUMERO
				//(cAliasTmp3)->E5_PARCELA := SE5->E5_PARCELA
				//(cAliasTmp3)->E5_CLIFOR  := SE5->E5_CLIFOR
				//(cAliasTmp3)->E5_LOJA    := SE5->E5_LOJA
				(cAliasTmp3)->E5_VALOR   := SE5->E5_VALOR - SE5->E5_VLJUROS - SE5->E5_VLMULTA
				//(cAliasTmp3)->E5_RECPAG  := SE5->E5_RECPAG
				(cAliasTmp3)->RECEBIDO   := nReceber
				(cAliasTmp3)->PAGO       := nPagar
				IF nUsuario == 1
					(cAliasTmp3)->DIGITADO   := Capital(cDigitado)
					(cAliasTmp3)->LIBERADO   := Capital(cLiberado)
                ENDIF
				msUnlock()
			ENDIF
		ELSE   // PAGAR
    	    aSE5P:= {}
    	
    		IF SE5->E5_TIPODOC == "CH"  .AND. ALLTRIM(SE5->CANC) <> "CANC"
    		
    		
    // CHEQUE CANCELADO
      //	If ALLTRIM(SE5->CANC) == "CANC"
	//	SE5->( dbSkip() )
	 //	Loop
	//ENDIF
    		
		   		cQuery := ""
				cQuery += " SELECT * FROM "+RETSQLNAME("SEF")+" SEF WHERE SEF.D_E_L_E_T_=''"
				cQuery += " AND SEF.EF_BANCO='"+SE5->E5_BANCO+"'"
				cQuery += " AND EF_AGENCIA='"+SE5->E5_AGENCIA+"'"
				cQuery += " AND EF_CONTA='"+SE5->E5_CONTA+"'"
				cQuery += " AND EF_NUM='"+SE5->E5_NUMCHEQ+"'"
//				cQuery += " AND EF_DATA='"+DTOS(SE5->E5_DATA)+"'" 
				cQuery += "	AND EF_FORNECE<>''"
			
				TCQUERY cQuery NEW ALIAS "QTMPEF" 
			
				DO WHILE QTMPEF->(!EOF())
					AADD(aSE5P,{QTMPEF->EF_FORNECE,QTMPEF->EF_LOJA,QTMPEF->EF_PREFIXO,QTMPEF->EF_TITULO,QTMPEF->EF_PARCELA,QTMPEF->EF_TIPO,QTMPEF->EF_VALOR})
			   		QTMPEF->(DbSkip())
				ENDDO
				IF LEN(aSE5P) == 0
					AADD(aSE5P,{SE5->E5_CLIFOR,SE5->E5_LOJA,SE5->E5_PREFIXO,SE5->E5_NUMERO,SE5->E5_PARCELA,SE5->E5_TIPO,nPagar})
				ENDIF
				QTMPEF->(dbCloseArea())
		    ELSE
				AADD(aSE5P,{SE5->E5_CLIFOR,SE5->E5_LOJA,SE5->E5_PREFIXO,SE5->E5_NUMERO,SE5->E5_PARCELA,SE5->E5_TIPO,nPagar})
			ENDIF 

  	        
  			FOR _IY:= 1 TO LEN(aSE5P)
	    		cHist  := ""
	    		aTot := {}
				nTot := 0
			    cHist := ""
			    cTHist:= ""
	   			nLinHis := 0
	   			nMaxObs := 80 //Iif(lLands,120,090)
	            cChave	:= ""
	            lEntrada:= .T.
	            
	      		dbSelectArea("SE2")        
	    		SE2->(dbSetOrder(6))  //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO 
	   			IF SE2->(dbSeek(xFilial("SE2")+aSE5P[_IY,1]+aSE5P[_IY,2]+aSE5P[_IY,3]+aSE5P[_IY,4]+aSE5P[_IY,5]+aSE5P[_IY,6],.F.))
	   				IF SE2->E2_TIPO $ "TX #ISS#TXA#INS"
	   					IF !EMPTY(ALLTRIM(SE2->E2_TITPAI))
	   						cChave := SUBSTR(SE2->E2_TITPAI,4,9)+SUBSTR(SE2->E2_TITPAI,1,3)+SUBSTR(SE2->E2_TITPAI,18,8) //E  000000014  NF 00108501
	   					ELSE
	            			lEntrada:= .F.
	   						cChave  := aSE5P[_IY,4]+aSE5P[_IY,3] //SE5->E5_NUMERO+SE5->E5_PREFIXO
	   					ENDIF
	   				ELSE
	   					//IF SE5->E5_TIPO == "PA" .AND.  SE2->E2_SALDO <> SE2->E2_VALOR
	   					
	   				
	   					//ELSE
	   						cChave := aSE5P[_IY,4]+aSE5P[_IY,3]+aSE5P[_IY,1]+aSE5P[_IY,2] //SE5->E5_NUMERO+SE5->E5_PREFIXO+SE5->E5_CLIFOR+SE5->E5_LOJA
	   			    	//ENDIF
	   				ENDIF
	   			ELSE
	  				cChave := aSE5P[_IY,4]+aSE5P[_IY,3]+aSE5P[_IY,1]+aSE5P[_IY,2] //SE5->E5_NUMERO+SE5->E5_PREFIXO+SE5->E5_CLIFOR+SE5->E5_LOJA
	   			ENDIF
	   			nVALBRUT := 0
	    		IF lEntrada
	    		 
                    
		    		dbSelectArea("SD1")        
		    		SD1->(dbSetOrder(1))
		   			IF SD1->(dbSeek(xFilial("SD1")+cChave,.T.))

	    				dbSelectArea("SF1")
	    				SF1->(dbSetOrder(1))
	    				IF SF1->(dbSeek(xFilial("SF1")+cChave+"N"))
	    					IF (SF1->F1_VALIRF + SF1->F1_ISS + SF1->F1_INSS + SF1->F1_VALPIS + SF1->F1_VALCOFI + SF1->F1_VALCSLL) > 0 
	    						nVALBRUT := SF1->F1_VALBRUT
	    					ENDIF
          				ENDIF
          				
						IF nUsuario == 1
		   					aLIB:= {}
		   					aLIB:= U_BLibera(cChave,SD1->D1_PEDIDO) // Localiza liberação Alcada
		   			
		   					cDigitado := aLIB[1]
	   						cLiberado := aLIB[2]
                        ENDIF
		   			ENDIF
		   			cProduto := ""
		   			lFiltPrd := .F.
		    		DO WHILE SD1->(!EOF()) .AND. xFilial("SD1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == ;
		    			xFilial("SD1")+cChave
						
						// Se algum produto satisfazer o filtro, considerá-lo
						IF !EMPTY(cFiltPrd) .AND. TRIM(SD1->D1_COD) == TRIM(cFiltPrd)
						   lFiltPrd  := .T.
						   cProduto  := SD1->D1_COD
						ENDIF

						IF EMPTY(cProduto) .OR. cProduto == SD1->D1_COD
							cProduto := SD1->D1_COD
						ELSEIF !lFiltPrd 
							cProduto := "DIVERSOS"
						ENDIF
						
						
					    cHist  := ALLTRIM(SD1->D1_XXHIST)   //IIF(ALLTRIM(SD1->D1_XXHIST) $ cHist,"",cHist) 
		    			nLinHis:= MLCOUNT(cHist,nMaxObs)
			   			cHist2 := ""
			   			
						FOR xi := 1 TO nLinHis
			       			cHist2 := ALLTRIM(MemoLine(cHist,nMaxObs,xi))+" "
							IF !(cHist2 $ cTHist)
								cTHist += cHist2
							ENDIF
		       			NEXT 
		       			IF LEN(ALLTRIM(SD1->D1_PEDIDO)) <> 0
		                 	IF !(TRIM(SD1->D1_PEDIDO) $ cHist2)
		                		cHist2 := " Pedido de Compra n°: "+TRIM(SD1->D1_PEDIDO)
								IF !(cHist2 $ cTHist)
									cTHist += cHist2
								ENDIF
		                	ENDIF
		       			ENDIF
		       			
		       			IF nImpostos == 1
			       			//INSS
			       			IF ALLTRIM(SD1->D1_COD) $ "21301004" .AND. SD1->D1_CC='000000001'  .AND. SD1->D1_TOTAL > 100000 
			       				cRef := ""
			       				cRef := SUBSTR(DTOS(MonthSub(SD1->D1_EMISSAO,1)),1,6)+'01' 
			       				aTot := RetINSS(cRef,SD1->D1_TOTAL)
								nTot:= 0
								nTot:= aScan(aTot,{|x| x[1]=='193000288' })
			                	IF nTot > 0
			       					MSGINFO(aTot[nTot,1]+"     \"+STR(aTot[nTot,2],14,2))
			                	ENDIF
	
	
			       			//FGTS
			       			ELSEIF ALLTRIM(SD1->D1_COD) $ "21301005" .AND. SD1->D1_CC='000000001'  .AND. SD1->D1_TOTAL > 100000
			       				cRef := ""
			       				cRef := SUBSTR(DTOS(MonthSub(SD1->D1_EMISSAO,1)),1,6)+'01' 
			       				aTot := RetFGTS(cRef,SD1->D1_TOTAL)
							//PIS		       			
			       			ELSEIF ALLTRIM(SD1->D1_COD) $ "21401003" 
			       				cRef := ""
			       				cRef := SUBSTR(DTOS(MonthSub(SD1->D1_EMISSAO,1)),1,6)+'01' 
			       				aTot := RetPIS(cRef,SD1->D1_TOTAL)
							//COFINS		       			
			       			ELSEIF ALLTRIM(SD1->D1_COD) $ "21401004" 
			       				cRef := ""
			       				cRef := SUBSTR(DTOS(MonthSub(SD1->D1_EMISSAO,1)),1,6)+'01' 
			       				aTot := RetCOFINS(cRef,SD1->D1_TOTAL)
							//IRRF CLT		       			
			       			ELSEIF ALLTRIM(SD1->D1_COD) $ "21401005" 
			       				cRef := ""
			       				cRef := SUBSTR(DTOS(MonthSub(SD1->D1_EMISSAO,1)),1,6)+'01' 
			       				aTot := RetIRRF(cRef,SD1->D1_TOTAL)
							//IRRF AUTONOMO		       			
			       			ELSEIF ALLTRIM(SD1->D1_COD) $ "21401006" 
			       				cRef := ""
			       				cRef := SUBSTR(DTOS(MonthSub(SD1->D1_EMISSAO,1)),1,6)+'01' 
			       				aTot := RetIRAUT(cRef,SD1->D1_TOTAL)
			       			ELSE
								nTot:= 0
								nTot:= aScan(aTot,{|x| x[1]==SD1->D1_CC })
			                	IF nTot > 0
			                		aTot[nTot,2] += SD1->D1_TOTAL
			                	ELSE
									AADD(aTot,{SD1->D1_CC,SD1->D1_TOTAL})
								ENDIF
							ENDIF
	                    ENDIF
	                    
						IF LEN(aTot) == 0
							nTot:= 0
							nTot:= aScan(aTot,{|x| x[1]==SD1->D1_CC })
		                	IF nTot > 0
		                		aTot[nTot,2] += SD1->D1_TOTAL
		                	ELSE
								AADD(aTot,{SD1->D1_CC,SD1->D1_TOTAL})
							ENDIF
						ENDIF
						
						IF aSE5P[_IY,6] $ "TX #ISS#TXA#INS"   //SE5->E5_TIPO
							cHist2 := SE2->E2_NATUREZ+" Ref. NF ENTRADA nº:"+SD1->D1_DOC+" série:"+SD1->D1_SERIE+" Fornecedor:"+SD1->D1_FORNECE+" Loja:"+SD1->D1_LOJA
							IF !(cHist2 $ cTHist)
								cTHist += cHist2
							ENDIF
						ENDIF
		                
		                IF EMPTY(cTHist)
		                	cTHist  := "Pgto Ref. "+Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC")
		                ENDIF
		                IF ALLTRIM(SD1->D1_COD) $ "31201046/31201045/31201047"
		                	nFin := 2
		                ELSEIF ALLTRIM(SD1->D1_COD) $ "29104004"
		                	nFin := 5
		                ELSE 
		                	nFin := 3
		                ENDIF
		       			SD1->(dbSkip())
		    		ENDDO
	            ELSE
			
		   			cProduto := ""
		   			lFiltPrd := .F.
		   			
					dbSelectArea ("SD2")   
					SD2->(dbSetOrder(3))  //filial,doc,serie,cliente,loja,cod
					SD2->(dbSeek(xFilial("SD2")+cChave,.T.))
					DO WHILE SD2->(!EOF()) .and. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE == xFilial("SD2")+cChave

						// Se algum produto satisfazer o filtro, considerá-lo
						IF !EMPTY(cFiltPrd) .AND. TRIM(SD2->D2_COD) == TRIM(cFiltPrd)
						   lFiltPrd  := .T.
						   cProduto  := SD2->D2_COD
						ENDIF

						IF EMPTY(cProduto) .OR. cProduto == SD2->D2_COD
							cProduto := SD2->D2_COD
						ELSEIF !lFiltPrd 
							cProduto := "DIVERSOS"
						ENDIF
				
						nTot:= 0
						nTot:= aScan(aTot,{|x| x[1]==SD2->D2_CCUSTO })
		                IF nTot > 0
		                	aTot[nTot,2] += SD2->D2_TOTAL
		                ELSE
							AADD(aTot,{SD2->D2_CCUSTO,SD2->D2_TOTAL})
						ENDIF
						cTHist := ""
		           		cTHist := SE2->E2_NATUREZ+" Ref. NF SAIDA nº:"+SD2->D2_DOC+" série:"+SD2->D2_SERIE+" Cliente:"+SD2->D2_CLIENTE+" Loja:"+SD2->D2_SERIE
						SD2->(dbSkip())
					ENDDO
	            ENDIF
	            
			    //Movimento LF
			    IF LEN(aTot) == 0  .AND. ALLTRIM(aSE5P[_IY,3]) $ "LF/DV/CX" //SE5->E5_TIPO 
			    	nFin   := 2
					cQuery := ""
					cQuery += "SELECT Z2_E2NUM,Z2_E2PRF,Z2_CC,SUM(Z2_VALOR) AS Z2_VALOR"
					cQuery += " FROM "+RETSQLNAME("SZ2")+" SZ2 "
					cQuery += " WHERE SZ2.D_E_L_E_T_='' AND Z2_CODEMP = '"+SM0->M0_CODIGO+"' AND Z2_E2NUM='"+aSE5P[_IY,4]+"'"
					cQuery += " AND Z2_E2PRF='"+aSE5P[_IY,3]+"' AND Z2_E2PARC='"+aSE5P[_IY,5]+"' AND Z2_STATUS='S'"
					cQuery += " AND Z2_E2TIPO='"+aSE5P[_IY,6]+"'AND Z2_E2FORN='"+aSE5P[_IY,1]+"' AND Z2_E2LOJA='"+aSE5P[_IY,2]+"'" 
					cQuery += " GROUP BY  Z2_E2NUM,Z2_E2PRF,Z2_CC "				
	
	 				TCQUERY cQuery NEW ALIAS "QSZ2"
	
						
					DbSelectArea("QSZ2")
					QSZ2->(DbGoTop())
	
					aTot := {}
					nTot := 0
					cTHist := ""
	
					Do While QSZ2->(!eof())

						IF nUsuario == 1
		   					aLIB:= {}
		   					aLIB:= U_BLibera("LFRH",QSZ2->Z2_E2NUM) // Localiza liberação Alcada
		   			
		   					cDigitado := aLIB[1]
	   						cLiberado := aLIB[2]
					    ENDIF
						cHist := "PGTO RH "
	 					nDESCRH:= 0
						nDESCRH:= aScan(aDESCRH,{|x| x[1] $ QSZ2->Z2_E2NUM })
	    				IF nDESCRH > 0
	    					cHist += aDESCRH[nDESCRH,2]
	    				ENDIF
	  
						nTot:= 0
						nTot:= aScan(aTot,{|x| x[1]==QSZ2->Z2_CC })
	                	IF nTot > 0
	                		aTot[nTot,2] += QSZ2->Z2_VALOR
	                	ELSE
							AADD(aTot,{QSZ2->Z2_CC,QSZ2->Z2_VALOR})
						ENDIF
						
						IF !(cHist $ cTHist)
							cTHist += cHist
						ENDIF
					
						QSZ2->(dbSkip())
					ENDDO
					QSZ2->(DbCloseArea())
				ENDIF
				
				IF LEN(aTot)> 0           
					aTot := U_Rateia(aTot,aSE5P[_IY,7])
					IX := 0
					FOR IX := 1 TO LEN(aTot)
				    	cCC := aTot[IX,1]
				    	cDescrCC := Posicione("CTT",1,xFilial("CTT")+cCC,"CTT_DESC01")
	
						dbSelectArea(cAliasTmp4)
						IF !dbSeek(cCC)
							RecLock( cAliasTmp4, .T. )
							(cAliasTmp4)->CC    := cCC
						ELSE 
							RecLock( cAliasTmp4, .F. )
						ENDIF
						(cAliasTmp4)->DESCRCC    := cDescrCC
						(cAliasTmp4)->RECEBIDOS  += nReceber
						(cAliasTmp4)->PAGOS      += aTot[IX,2]
						msUnlock()
	
	
						IF TRIM(cCC) <> "000000001"
	                   		cDESCFIN := "" 
	                   		cDESCFIN := ALLTRIM(aSitFin[1]) //Total Clientes
	                	ELSE
	                       	IF aSE5P[_IY,6]  $ "TX #ISS#TXA#INS"  //SE5->E5_TIPO
	                    		nFin := 8
	                    	ENDIF
	                   		cDESCFIN := "" 
	                   		cDESCFIN := ALLTRIM(aSitFin[nFin]) //DESCRIÇÃO FINANCEIRO
	                	ENDIF
	 
						dbSelectArea(cAliasTmp5)
						IF !dbSeek(cDESCFIN)
							RecLock( cAliasTmp5, .T. )
							(cAliasTmp5)->DESCFIN := cDESCFIN
						ELSE 
							RecLock( cAliasTmp5, .F. )
						ENDIF
						(cAliasTmp5)->RECEBIDOS  += nReceber
						(cAliasTmp5)->PAGOS      += aTot[IX,2]
						msUnlock()

						IF nUsuario == 1
   							IF EMPTY(cDigitado) .AND. EMPTY(cLiberado)
   								cDigitado := SE2->(FWLeUserlg("E2_USERLGI",1))   //U_BUSER(SUBSTR(Embaralha(SE2->E2_USERLGI,1),3,6))
								cLiberado := SE2->E2_USUALIB
							ENDIF
		                ENDIF
						
						// Gravar analitico
						RecLock( cAliasTmp3, .T. )
						//(cAliasTmp3)->XXCTFIN    := cCtaFin
						//(cAliasTmp3)->DESCRCT    := cDescrCt
						(cAliasTmp3)->XXCC   	 := cCC
						(cAliasTmp3)->DESCRCC    := cDescrCC
						(cAliasTmp3)->B1_COD     := cProduto
						IF !EMPTY(cProduto)
							(cAliasTmp3)->B1_DESC := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
						ENDIF
						//(cAliasTmp3)->DESCFIN  := cDESCFIN
						(cAliasTmp3)->E5_TIPO    := aSE5P[_IY,6] //SE5->E5_TIPO
						(cAliasTmp3)->E5_DATA    := IIF(nTpData == 1,SE5->E5_DATA,SE5->E5_DTDISPO)
						(cAliasTmp3)->E5_HISTOR  := IIF(!EMPTY(cTHist),STRTRAN(cTHist,';',','),SE5->E5_HISTOR)
						//If nFormato == 2
						//	(cAliasTmp3)->E5_HISTOR2  := SUBSTR(IIF(!EMPTY(cTHist),STRTRAN(cTHist,';',','),SE5->E5_HISTOR),201,200)
						//EndIf
						(cAliasTmp3)->E5_BENEF   := SE5->E5_BENEF
						//(cAliasTmp3)->E5_TIPODOC := SE5->E5_TIPODOC
						(cAliasTmp3)->E5_BANCO   := SE5->E5_BANCO
						(cAliasTmp3)->E5_AGENCIA := SE5->E5_AGENCIA
						(cAliasTmp3)->E5_CONTA   := SE5->E5_CONTA
						(cAliasTmp3)->E5_NUMCHEQ := SE5->E5_NUMCHEQ
						//(cAliasTmp3)->E5_PREFIXO := SE5->E5_PREFIXO
						(cAliasTmp3)->E5_NUMERO  := aSE5P[_IY,4] //SE5->E5_NUMERO
						//(cAliasTmp3)->E5_PARCELA := SE5->E5_PARCELA
						//(cAliasTmp3)->E5_CLIFOR  := aSE5P[_IY,1] //SE5->E5_CLIFOR
						//(cAliasTmp3)->E5_LOJA    := SE5->E5_LOJA
						(cAliasTmp3)->E5_VALOR   := IIF(nVALBRUT>0,nVALBRUT,aTot[IX,2])
						//(cAliasTmp3)->E5_RECPAG  := SE5->E5_RECPAG
						(cAliasTmp3)->RECEBIDO   := nReceber
						(cAliasTmp3)->PAGO       := aTot[IX,2]
						IF nUsuario == 1
							(cAliasTmp3)->DIGITADO   := Capital(cDigitado)
							(cAliasTmp3)->LIBERADO   := Capital(cLiberado)
						ENDIF
						msUnlock()
					NEXT
				ELSE

					//Movimento Bancario
				    IF 	EMPTY(aSE5P[_IY,3]) .AND. EMPTY(aSE5P[_IY,4]) .AND. EMPTY(aSE5P[_IY,5]) .AND. EMPTY(aSE5P[_IY,1])
						nFin := 4
					ELSE
						nFin := 3
					ENDIF
				    cCC := ""
				    cDescrCC := ""
			    	cCC := "000000001"
				    cDescrCC := Posicione("CTT",1,xFilial("CTT")+cCC,"CTT_DESC01")
	
					dbSelectArea(cAliasTmp4)
					IF !dbSeek(cCC)
						RecLock( cAliasTmp4, .T. )
						(cAliasTmp4)->CC    := cCC
					ELSE 
						RecLock( cAliasTmp4, .F. )
					ENDIF
					(cAliasTmp4)->DESCRCC    := cDescrCC
					(cAliasTmp4)->RECEBIDOS  += nReceber
					(cAliasTmp4)->PAGOS      += aSE5P[_IY,7]
					msUnlock()
	
					IF TRIM(cCC) <> "000000001"
	               		cDESCFIN := "" 
	               		cDESCFIN := ALLTRIM(aSitFin[1]) //Total Clientes
	               	ELSE
	                   	IF aSE5P[_IY,6] $ "TX #ISS#TXA#INS"  //SE5->E5_TIPO 
	                   		nFin := 8
	                   	ENDIF
	               		cDESCFIN := "" 
	               		cDESCFIN := ALLTRIM(aSitFin[nFin]) //DESCRIÇÃO FINANCEIRO
	               	ENDIF
	 
					dbSelectArea(cAliasTmp5)
					IF !dbSeek(cDESCFIN)
						RecLock( cAliasTmp5, .T. )
						(cAliasTmp5)->DESCFIN := cDESCFIN
					ELSE 
						RecLock( cAliasTmp5, .F. )
					ENDIF
					(cAliasTmp5)->RECEBIDOS  += nReceber
					(cAliasTmp5)->PAGOS      += aSE5P[_IY,7]
					msUnlock()
					
					IF nUsuario == 1

					
						// Incluir usuário que fez o movimento bancário - 16/07/15
						//IF SE5->(FieldPos("E5_USERLGI")) <> 0
							// Nome do usuário no campo USERLGI/A -> FWLeUserlg("A1_USERLGI", 1)
							// Data no campo USERLGI/A -> FWLeUserlg("A1_USERLGI", 2)
							cDigitado := SE5->(FWLeUserlg("E5_USERLGI",1))
						//ENDIF

						IF EMPTY(cDigitado) .AND. !EMPTY(SE2->E2_USERLGI)
							cDigitado := SE2->(FWLeUserlg("E2_USERLGI",1))
						ENDIF

						IF EMPTY(cLiberado) .AND. !EMPTY(SE2->E2_USUALIB)
							cLiberado := SE2->E2_USUALIB
						ENDIF
				    ENDIF
					// Gravar analitico
					RecLock( cAliasTmp3, .T. )
					//(cAliasTmp3)->XXCTFIN    := cCtaFin
					//(cAliasTmp3)->DESCRCT    := cDescrCt
					(cAliasTmp3)->XXCC   	 := cCC
					(cAliasTmp3)->DESCRCC    := cDescrCC
					//(cAliasTmp3)->DESCFIN 	 := cDESCFIN
					(cAliasTmp3)->E5_TIPO    := aSE5P[_IY,6] //SE5->E5_TIPO
					(cAliasTmp3)->B1_COD     := cProduto
					IF !EMPTY(cProduto)
						(cAliasTmp3)->B1_DESC := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
					ENDIF
					(cAliasTmp3)->E5_DATA    := IIF(nTpData == 1,SE5->E5_DATA,SE5->E5_DTDISPO)
					(cAliasTmp3)->E5_HISTOR  := SE5->E5_HISTOR
					(cAliasTmp3)->E5_BENEF   := SE5->E5_BENEF
					//(cAliasTmp3)->E5_TIPODOC := SE5->E5_TIPODOC
					(cAliasTmp3)->E5_BANCO   := SE5->E5_BANCO
					(cAliasTmp3)->E5_AGENCIA := SE5->E5_AGENCIA
					(cAliasTmp3)->E5_CONTA   := SE5->E5_CONTA
					(cAliasTmp3)->E5_NUMCHEQ := SE5->E5_NUMCHEQ
					//(cAliasTmp3)->E5_PREFIXO := SE5->E5_PREFIXO
					(cAliasTmp3)->E5_NUMERO  := aSE5P[_IY,4] //SE5->E5_NUMERO
					//(cAliasTmp3)->E5_PARCELA := SE5->E5_PARCELA
					//(cAliasTmp3)->E5_CLIFOR  := aSE5P[_IY,1] //SE5->E5_CLIFOR
					//(cAliasTmp3)->E5_LOJA    := SE5->E5_LOJA
					(cAliasTmp3)->E5_VALOR   := aSE5P[_IY,7] //SE5->E5_VALOR - SE5->E5_VLJUROS - SE5->E5_VLMULTA
					//(cAliasTmp3)->E5_RECPAG  := SE5->E5_RECPAG
					(cAliasTmp3)->RECEBIDO   := nReceber
					(cAliasTmp3)->PAGO       := aSE5P[_IY,7]
					IF nUsuario == 1
						(cAliasTmp3)->DIGITADO   := Capital(cDigitado)
						(cAliasTmp3)->LIBERADO   := Capital(cLiberado)
					ENDIF
					msUnlock()
				ENDIF
        	NEXT
		ENDIF	
	dbSelectArea("SE5")
	SE5->( dbSkip() )
EndDo

Return NIL



Static Function RetFGTS(cRef,nValor)
Local aCC := {}
Local cSql:= ""
Local nTotFgts := 0


cSql := "SELECT NumEmp,BKIntegraRubi.dbo.fnCCSiga(NumEmp,TipCol,Numcad,'CLT') as CCsiga,SUM(ValEve) as ValEve " 
cSql += " FROM  bk_senior.dbo.Bk_vw_MicrosigaFGTS "
cSql += " Where Perref='"+cRef+"' And NumEmp = '"+SM0->M0_CODIGO+"' " 
cSql += " Group By NumEmp,BKIntegraRubi.dbo.fnCCSiga(NumEmp,TipCol,Numcad,'CLT') "

TCQUERY cSql NEW ALIAS "QFGTS" 

dbSelectArea("QFGTS")
QFGTS->(DbGotop())
DO WHILE QFGTS->(!EOF())
    AADD(aCC,{QFGTS->CCsiga,QFGTS->ValEve})
	nTotFgts += QFGTS->ValEve
	QFGTS->(dbSkip())
ENDDO
QFGTS->(Dbclosearea()) 

nTotFgts := nTotFgts - nValor
IF nTotFgts > 0
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== "000000001" })
	IF nScan > 0
		IF aCC[nScan,2] > nTotFgts
			aCC[nScan,2] -= nTotFgts
		ELSE
			aCC[nScan,2] += nTotFgts
		ENDIF
	ELSE
		AADD(aCC,{"000000001",nTotFgts})
	ENDIF
ELSE
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== "000000001" })
	IF nScan > 0
		IF aCC[nScan,2] > (nTotFgts* -1 )
			aCC[nScan,2] -= (nTotFgts* -1 )
		ELSE
			aCC[nScan,2] += (nTotFgts* -1 )
		ENDIF
	ELSE
		AADD(aCC,{"000000001",(nTotFgts* -1 )})
	ENDIF                                                
ENDIF

Return aCC


//BUSCA RATEIRO CC INSS
Static Function RetINSS(cRef,nValor)
Local aCC := {}
Local aCC2 := {}
Local cSql:= ""
Local nTotINSS := 0
Local aContrCons	:= {}
Local aConsorcio    := {}

aContrCons	:= StrTokArr(ALLTRIM(GetMv("MV_XXCONS1"))+ALLTRIM(GetMv("MV_XXCONS2"))+ALLTRIM(GetMv("MV_XXCONS3"))+ALLTRIM(GetMv("MV_XXCONS4")),"/") //"163000240"

FOR IX:= 1 TO LEN(aContrCons)
    AADD(aConsorcio,StrTokArr(aContrCons[IX],";"))
NEXT

cSql := "SELECT Z5_CC AS CCsiga,SUM(Z5_VALOR) AS VALOR "
cSql += " FROM "+RetSqlName("SZ5")+" SZ5 "
cSql += " WHERE SZ5.D_E_L_E_T_='' AND Z5_ANOMES='"+SUBSTR(cRef,1,6)+"' AND Z5_EVENTO IN ('INS-E','INS-T') "
cSql += " GROUP BY Z5_CC "

TCQUERY cSql NEW ALIAS "QINSS" 

nINSS := 0
dbSelectArea("QINSS")
QINSS->(DbGotop())
DO WHILE QINSS->(!EOF())
	nScan:= 0
	nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QINSS->CCsiga) })
	cCusto := ""
	IF nScan > 0
		cCusto := "000000001"
    ELSE
		cCusto := QINSS->CCsiga 
	ENDIF
	
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== cCusto })
	nINSS += QINSS->VALOR
	IF nScan > 0
		aCC[nScan,2] += QINSS->VALOR
    ELSE
    	AADD(aCC,{cCusto,QINSS->VALOR})
	ENDIF

	nTotINSS += QINSS->VALOR
	QINSS->(dbSkip())
ENDDO
QINSS->(Dbclosearea())

IF nINSS == 0
	MSGSTOP("Para Rateio do INSS favor rodar a rotina de calculo na Integração Rubi x Microsiga!!")
	aCC2 := {}
	Return aCC2 
ENDIF

cSql := "Select BKIntegraRubi.dbo.CUSTOSIGA.ccSiga AS CONTRATO,sum(bk_senior.bk_senior.R046VER.ValEve) AS VALOR  "
cSql += "  FROM bk_senior.bk_senior.R046VER "
cSql += "  INNER JOIN bk_senior.bk_senior.R044cal ON bk_senior.bk_senior.R046VER.NumEmp= bk_senior.bk_senior.R044cal.NumEmp "
cSql += "  AND bk_senior.bk_senior.R046VER.CodCal= bk_senior.bk_senior.R044cal.Codcal "
cSql += "  INNER JOIN BKIntegraRubi.dbo.CUSTOSIGA ON bk_senior.bk_senior.R046VER.NumEmp= BKIntegraRubi.dbo.CUSTOSIGA.NumEmp "
cSql += "  AND bk_senior.bk_senior.R046VER.NumCad = BKIntegraRubi.dbo.CUSTOSIGA.Numcad "
cSql += "  AND bk_senior.bk_senior.R046VER.TipCol = BKIntegraRubi.dbo.CUSTOSIGA.TipCol "
cSql += "  AND bk_senior.bk_senior.R044cal.Codcal = BKIntegraRubi.dbo.CUSTOSIGA.Codcal "
cSql += "  Where bk_senior.bk_senior.R046VER.NumEmp='"+SM0->M0_CODIGO+"' and Tipcal In(11) And Sitcal = 'T' " 
cSql += "  AND PerRef ='"+cRef+"' and bk_senior.bk_senior.R046VER.CodEve in ('301','302','303','307') "
cSql += "  group by BKIntegraRubi.dbo.CUSTOSIGA.ccSiga "

TCQUERY cSql NEW ALIAS "QINSS" 

dbSelectArea("QINSS")
QINSS->(DbGotop())
DO WHILE QINSS->(!EOF())

	nScan:= 0
	nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QINSS->CONTRATO) })
	cCusto := ""
	IF nScan > 0
		cCusto := "000000001"
    ELSE
		cCusto := QINSS->CONTRATO 
	ENDIF

	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== cCusto })
	IF nScan > 0
		aCC[nScan,2] += QINSS->VALOR
    ELSE
    	AADD(aCC,{cCusto,QINSS->VALOR})
	ENDIF

	nTotINSS += QINSS->VALOR
	QINSS->(dbSkip())
ENDDO
QINSS->(Dbclosearea())

//
cSql := "SELECT codempresa,CCsiga,SUM(TOTAL) as VALOR "
cSql += " FROM bk_senior.dbo.BK_vw_MicrosigaTotalAutIPT "
cSql += " INNER JOIN [BKIntegraRubi].[dbo].[FINANCE_INTREGRA_CONTABIL] "
cSql += " ON [BKIntegraRubi].[dbo].[FINANCE_INTREGRA_CONTABIL].NumEmpr=bk_senior.dbo.BK_vw_MicrosigaTotalAutIPT.codempresa "
cSql += " AND [BKIntegraRubi].[dbo].[FINANCE_INTREGRA_CONTABIL].Campo=bk_senior.dbo.BK_vw_MicrosigaTotalAutIPT.DesEv  collate Latin1_General_CI_AS "
cSql += " Where competencia='"+SUBSTR(cRef,1,6)+"' And codempresa = '"+SM0->M0_CODIGO+"' and total<> 0 AND DesEv='INSS' "
cSql += " group by codempresa,CCsiga "

TCQUERY cSql NEW ALIAS "QINSS" 

dbSelectArea("QINSS")
QINSS->(DbGotop())
DO WHILE QINSS->(!EOF())

	nScan:= 0
	nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QINSS->CCsiga) })
	cCusto := ""
	IF nScan > 0
		cCusto := "000000001"
    ELSE
		cCusto := QINSS->CCsiga
	ENDIF

	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== cCusto })
	IF nScan > 0
		aCC[nScan,2] += QINSS->VALOR
    ELSE
    	AADD(aCC,{cCusto,QINSS->VALOR})
	ENDIF

	nTotINSS += QINSS->VALOR
	QINSS->(dbSkip())
ENDDO
QINSS->(Dbclosearea()) 
 
cSql := "Select D2_CCUSTO,C5_ESPECI1,SUM(D2_VALINS) AS VALOR "
cSql += " FROM "+RetSqlName("SD2")+" SD2 "
cSql += " INNER JOIN " + RetSqlName("SF2")+" SF2 ON SF2.D_E_L_E_T_='' AND SD2.D2_DOC=SF2.F2_DOC AND SD2.D2_SERIE=SF2.F2_SERIE "
cSql += " LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON SC5.C5_NUM=SD2.D2_PEDIDO AND SC5.D_E_L_E_T_='' "
cSql += " AND SD2.D2_CLIENTE=SF2.F2_CLIENT AND SD2.D2_LOJA=SF2.F2_LOJA "  
cSql += " where SD2.D_E_L_E_T_='' AND D2_VALINS > 0 and F2_EMISSAO >='"+SUBSTR(cRef,1,6)+"01' AND F2_EMISSAO <='"+SUBSTR(cRef,1,6)+"31' "
cSql += " GROUP BY D2_CCUSTO,C5_ESPECI1 "

TCQUERY cSql NEW ALIAS "QINSS" 

dbSelectArea("QINSS")
QINSS->(DbGotop())
DO WHILE QINSS->(!EOF())


    cCusto := ""
    cCusto := ALLTRIM(IIF(!EMPTY(QINSS->D2_CCUSTO),QINSS->D2_CCUSTO,QINSS->C5_ESPECI1))

	nScan:= 0
	nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(cCusto) })
	IF nScan > 0
		cCusto := "000000001"
	ENDIF

	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== cCusto .AND. x[2]< 0})
	IF nScan > 0
		aCC[nScan,2] += QINSS->VALOR*-1
    ELSE
    	AADD(aCC,{cCusto,QINSS->VALOR*-1})
	ENDIF

	nTotINSS -= QINSS->VALOR
	QINSS->(dbSkip())
ENDDO
QINSS->(Dbclosearea()) 

/*
nTotINSS := nTotINSS - nValor
IF nTotINSS > 0
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== "000000001" })
	IF nScan > 0
		IF aCC[nScan,2] > nTotINSS
			aCC[nScan,2] -= nTotINSS
		ELSE
			aCC[nScan,2] += nTotINSS
		ENDIF
	ELSE
		AADD(aCC,{"000000001",nTotINSS})
	ENDIF
ELSE
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== "000000001" })
	IF nScan > 0
		IF aCC[nScan,2] > (nTotINSS* -1 )
			aCC[nScan,2] -= (nTotINSS* -1 )
		ELSE
			aCC[nScan,2] += (nTotINSS* -1 )
		ENDIF
	ELSE
		AADD(aCC,{"000000001",(nTotINSS* -1 )})
	ENDIF                                                
ENDIF

nValNeg := 0
FOR _X1:=1 TO LEN(aCC)

	IF aCC[_X1,1] <> "000000001" .AND. aCC[_X1,2] > 0
		AADD(aCC2,{aCC[_X1,1],aCC[_X1,2]})
	ELSEIF aCC[_X1,2] < 0
		nValNeg += (aCC[_X1,2]*-1)
	ENDIF
NEXT

aCC3 := {}
aCC3 := U_Rateia(aCC2,nValNeg)

FOR _X1:=1 TO LEN(aCC2)
	aCC2[_X1,2] -= aCC3[_X1,2]
NEXT

nScan := 0
nScan := aScan(aCC,{|x| x[1]== "000000001" })
IF nScan > 0
	AADD(aCC2,{aCC[nScan,1],aCC[nScan,2]})
ENDIF
*/

Return aCC 



//BUSCA RATEIRO CC IRRF CLT
Static Function RetIRRF(cRef,nValor)
Local aCC := {}
Local cSql:= ""
Local nTotIRRF := 0


cSql := "Select BKIntegraRubi.dbo.CUSTOSIGA.ccSiga AS CONTRATO,sum(bk_senior.bk_senior.R046VER.ValEve) AS VALOR  "
cSql += "  FROM bk_senior.bk_senior.R046VER "
cSql += "  INNER JOIN bk_senior.bk_senior.R044cal ON bk_senior.bk_senior.R046VER.NumEmp= bk_senior.bk_senior.R044cal.NumEmp "
cSql += "  AND bk_senior.bk_senior.R046VER.CodCal= bk_senior.bk_senior.R044cal.Codcal "
cSql += "  INNER JOIN BKIntegraRubi.dbo.CUSTOSIGA ON bk_senior.bk_senior.R046VER.NumEmp= BKIntegraRubi.dbo.CUSTOSIGA.NumEmp "
cSql += "  AND bk_senior.bk_senior.R046VER.NumCad = BKIntegraRubi.dbo.CUSTOSIGA.Numcad "
cSql += "  AND bk_senior.bk_senior.R046VER.TipCol = BKIntegraRubi.dbo.CUSTOSIGA.TipCol "
cSql += "  AND bk_senior.bk_senior.R044cal.Codcal = BKIntegraRubi.dbo.CUSTOSIGA.Codcal "
cSql += "  Where bk_senior.bk_senior.R046VER.NumEmp='"+SM0->M0_CODIGO+"' and Tipcal In(11) And Sitcal = 'T' " 
cSql += "  AND PerRef ='"+cRef+"' and bk_senior.bk_senior.R046VER.CodEve in ('00304','00310') "
cSql += "  group by BKIntegraRubi.dbo.CUSTOSIGA.ccSiga "

TCQUERY cSql NEW ALIAS "QIRRF" 

dbSelectArea("QIRRF")
QIRRF->(DbGotop())
DO WHILE QIRRF->(!EOF())
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== QIRRF->CONTRATO })
	IF nScan > 0
		aCC[nScan,2] += QIRRF->VALOR
    ELSE
    	AADD(aCC,{QIRRF->CONTRATO,QIRRF->VALOR})
	ENDIF

	nTotIRRF += QIRRF->VALOR
	QIRRF->(dbSkip())
ENDDO
QIRRF->(Dbclosearea())


nTotIRRF := nTotIRRF - nValor
IF nTotIRRF > 0
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== "000000001" })
	IF nScan > 0
		IF aCC[nScan,2] > nTotIRRF
			aCC[nScan,2] -= nTotIRRF
		ELSE
			aCC[nScan,2] += nTotIRRF
		ENDIF
	ELSE
		AADD(aCC,{"000000001",nTotIRRF})
	ENDIF
ELSE
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== "000000001" })
	IF nScan > 0
		IF aCC[nScan,2] > (nTotIRRF* -1 )
			aCC[nScan,2] -= (nTotIRRF* -1 )
		ELSE
			aCC[nScan,2] += (nTotIRRF* -1 )
		ENDIF
	ELSE
		AADD(aCC,{"000000001",(nTotIRRF* -1 )})
	ENDIF                                                
ENDIF

Return aCC


//BUSCA RATEIRO CC IRRF AUTONOMO
Static Function RetIRAUT(cRef,nValor)
Local aCC := {}
Local cSql:= ""
Local nTotIRRF := 0

cSql := "SELECT CCsiga as CONTRATO,SUM(TOTAL) as VALOR "
cSql += " FROM bk_senior.dbo.BK_vw_MicrosigaTotalAutIPT "
cSql += " INNER JOIN [BKIntegraRubi].[dbo].[FINANCE_INTREGRA_CONTABIL] "
cSql += " ON [BKIntegraRubi].[dbo].[FINANCE_INTREGRA_CONTABIL].NumEmpr=bk_senior.dbo.BK_vw_MicrosigaTotalAutIPT.codempresa "
cSql += " AND [BKIntegraRubi].[dbo].[FINANCE_INTREGRA_CONTABIL].Campo=bk_senior.dbo.BK_vw_MicrosigaTotalAutIPT.DesEv  collate Latin1_General_CI_AS "
cSql += " Where competencia='"+substr(cRef,1,6)+"' And codempresa = '"+SM0->M0_CODIGO+"' and total<> 0 AND DesEv='IRRF' "
cSql += " group by CCsiga "
   
TCQUERY cSql NEW ALIAS "QIRRF" 

dbSelectArea("QIRRF")
QIRRF->(DbGotop())
DO WHILE QIRRF->(!EOF())
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== QIRRF->CONTRATO })
	IF nScan > 0
		aCC[nScan,2] += QIRRF->VALOR
    ELSE
    	AADD(aCC,{QIRRF->CONTRATO,QIRRF->VALOR})
	ENDIF

	nTotIRRF += QIRRF->VALOR
	QIRRF->(dbSkip())
ENDDO
QIRRF->(Dbclosearea())


nTotIRRF := nTotIRRF - nValor
IF nTotIRRF > 0
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== "000000001" })
	IF nScan > 0
		IF aCC[nScan,2] > nTotIRRF
			aCC[nScan,2] -= nTotIRRF
		ELSE
			aCC[nScan,2] += nTotIRRF
		ENDIF
	ELSE
		AADD(aCC,{"000000001",nTotIRRF})
	ENDIF
ELSE
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== "000000001" })
	IF nScan > 0
		IF aCC[nScan,2] > (nTotIRRF* -1 )
			aCC[nScan,2] -= (nTotIRRF* -1 )
		ELSE
			aCC[nScan,2] += (nTotIRRF* -1 )
		ENDIF
	ELSE
		AADD(aCC,{"000000001",(nTotIRRF* -1 )})
	ENDIF                                                
ENDIF

Return aCC


//BUSCA RATEIRO CC COFINS
Static Function RetCOFINS(cRef,nValor)
Local aCC := {}
Local cSql:= ""
Local nTotCOFINS := 0
Local nCredCOF   := 0
Local cTXCOFINS  := STR(GetMv("MV_TXCOFINS"))

cSql := "Select D2_CCUSTO,C5_ESPECI1,ROUND(SUM(D2_VALBRUT*("+ALLTRIM(cTXCOFINS)+"/100)),2)-SUM(D2_VALCOF) AS VALCOF"
cSql += " FROM "+RetSqlName("SD2")+" SD2 "
cSql += " INNER JOIN " + RetSqlName("SF2")+" SF2 ON SF2.D_E_L_E_T_='' AND SD2.D2_DOC=SF2.F2_DOC AND SD2.D2_SERIE=SF2.F2_SERIE "
cSql += " LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON SC5.C5_NUM=SD2.D2_PEDIDO AND SC5.D_E_L_E_T_='' "
cSql += " AND SD2.D2_CLIENTE=SF2.F2_CLIENT AND SD2.D2_LOJA=SF2.F2_LOJA "  
cSql += " where SD2.D_E_L_E_T_='' AND F2_EMISSAO >='"+SUBSTR(cRef,1,6)+"01' AND F2_EMISSAO <='"+SUBSTR(cRef,1,6)+"31' "
cSql += " GROUP BY D2_CCUSTO,C5_ESPECI1 "
   
TCQUERY cSql NEW ALIAS "QCOFINS" 

dbSelectArea("QCOFINS")
QCOFINS->(DbGotop())
DO WHILE QCOFINS->(!EOF())
    cCusto := ""
    cCusto := ALLTRIM(IIF(!EMPTY(QCOFINS->D2_CCUSTO),QCOFINS->D2_CCUSTO,QCOFINS->C5_ESPECI1))
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== cCusto })
	IF nScan > 0
		aCC[nScan,2] -= QCOFINS->VALCOF
    ELSE
    	AADD(aCC,{cCusto,QCOFINS->VALCOF})
	ENDIF

	nTotCOFINS += QCOFINS->VALCOF
	QCOFINS->(dbSkip())
ENDDO
QCOFINS->(Dbclosearea()) 


cSql := "SELECT SUM(D1_VALIMP5) AS D1_VALIMP5 FROM "+RetSqlName("SD1")+" SD1 " 
cSql += " WHERE SD1.D_E_L_E_T_='' AND D1_TES = '104' "
cSql += " AND D1_DTDIGIT >='"+SUBSTR(cRef,1,6)+"01' AND D1_DTDIGIT <='"+SUBSTR(cRef,1,6)+"31' " 
   
TCQUERY cSql NEW ALIAS "QCOFINS" 

dbSelectArea("QCOFINS")
QCOFINS->(DbGotop())
DO WHILE QCOFINS->(!EOF())
	nCredCOF += QCOFINS->D1_VALIMP5
	QCOFINS->(dbSkip())
ENDDO
QCOFINS->(Dbclosearea())

IF nCredCOF > 0 
	aCC2 := {}
	aCC2 := U_Rateia(aCC,nCredCOF)
ENDIF

FOR _X1:=1 TO LEN(aCC)
	aCC[_X1,2] -= aCC2[_X1,2]
	nTotCOFINS -= aCC2[_X1,2]
NEXT

nTotCOFINS := nTotCOFINS - nValor 

IF nTotCOFINS > 0
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== "000000001" })
	IF nScan > 0
		IF aCC[nScan,2] > nTotCOFINS
			aCC[nScan,2] -= nTotCOFINS
		ELSE
			aCC[nScan,2] += nTotCOFINS
		ENDIF
	ELSE
		AADD(aCC,{"000000001",nTotCOFINS})
	ENDIF
ELSE
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== "000000001" })
	IF nScan > 0
		IF aCC[nScan,2] > (nTotCOFINS* -1 )
			aCC[nScan,2] -= (nTotCOFINS* -1 )
		ELSE
			aCC[nScan,2] += (nTotCOFINS* -1 )
		ENDIF
	ELSE
		AADD(aCC,{"000000001",(nTotCOFINS* -1 )})
	ENDIF                                                
ENDIF

Return aCC


//BUSCA RATEIO CC PIS
Static Function RetPIS(cRef,nValor)
Local aCC := {}
Local cSql:= ""
Local nTotPIS := 0
Local nCredPIS   := 0
Local cTXPIS  := STR(GetMv("MV_TXPIS"))

cSql := "Select D2_CCUSTO,C5_ESPECI1,ROUND(SUM(D2_VALBRUT*("+ALLTRIM(cTXPIS)+"/100)),2)-SUM(D2_VALPIS) AS VALPIS"
cSql += " FROM "+RetSqlName("SD2")+" SD2 "
cSql += " INNER JOIN " + RetSqlName("SF2")+" SF2 ON SF2.D_E_L_E_T_='' AND SD2.D2_DOC=SF2.F2_DOC AND SD2.D2_SERIE=SF2.F2_SERIE "
cSql += " LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON SC5.C5_NUM=SD2.D2_PEDIDO AND SC5.D_E_L_E_T_='' "
cSql += " AND SD2.D2_CLIENTE=SF2.F2_CLIENT AND SD2.D2_LOJA=SF2.F2_LOJA "  
cSql += " where SD2.D_E_L_E_T_='' AND F2_EMISSAO >='"+SUBSTR(cRef,1,6)+"01' AND F2_EMISSAO <='"+SUBSTR(cRef,1,6)+"31' "
cSql += " GROUP BY D2_CCUSTO,C5_ESPECI1 "
   
TCQUERY cSql NEW ALIAS "QPIS" 

dbSelectArea("QPIS")
QPIS->(DbGotop())
DO WHILE QPIS->(!EOF())
    cCusto := ""
    cCusto := ALLTRIM(IIF(!EMPTY(QPIS->D2_CCUSTO),QPIS->D2_CCUSTO,QPIS->C5_ESPECI1))
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== cCusto })
	IF nScan > 0
		aCC[nScan,2] -= QPIS->VALPIS
    ELSE
    	AADD(aCC,{cCusto,QPIS->VALPIS})
	ENDIF

	nTotPIS += QPIS->VALPIS
	QPIS->(dbSkip())
ENDDO
QPIS->(Dbclosearea()) 

cSql := "SELECT SUM(D1_VALIMP6) AS D1_VALIMP6 FROM "+RetSqlName("SD1")+" SD1 " 
cSql += " WHERE SD1.D_E_L_E_T_='' AND D1_TES = '104' "
cSql += " AND D1_DTDIGIT >='"+SUBSTR(cRef,1,6)+"01' AND D1_DTDIGIT <='"+SUBSTR(cRef,1,6)+"31' " 
   
TCQUERY cSql NEW ALIAS "QPIS" 

dbSelectArea("QPIS")
QPIS->(DbGotop())
DO WHILE QPIS->(!EOF())
	nCredPIS += QPIS->D1_VALIMP6
	QPIS->(dbSkip())
ENDDO
QPIS->(Dbclosearea()) 

IF nCredPIS <> 0
	aCC2 := {}
	aCC2 := U_Rateia(aCC,nCredPIS)
ENDIF

FOR _X1:=1 TO LEN(aCC)
	aCC[_X1,2] -= aCC2[_X1,2]
	nTotPIS -= aCC2[_X1,2]
NEXT
 
nTotPIS := nTotPIS - nValor 

IF nTotPIS > 0
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== "000000001" })
	IF nScan > 0
		IF aCC[nScan,2] > nTotPIS
			aCC[nScan,2] -= nTotPIS
		ELSE
			aCC[nScan,2] += nTotPIS
		ENDIF
	ELSE
		AADD(aCC,{"000000001",nTotPIS})
	ENDIF
ELSE
	nScan := 0
	nScan := aScan(aCC,{|x| x[1]== "000000001" })
	IF nScan > 0
		IF aCC[nScan,2] > (nTotPIS* -1 )
			aCC[nScan,2] := (nTotPIS* -1 ) - aCC[nScan,2]
		ELSE
			aCC[nScan,2] += (nTotPIS* -1 )
		ENDIF
	ELSE
		AADD(aCC,{"000000001",(nTotPIS* -1 )})
	ENDIF                                                
ENDIF

Return aCC

//Busca a Liberacao do Documento - Alcada
USER FUNCTION BLibera(cCHAVESD1,cPedido)
LOCAL cDIGTA := ""
LOCAL cAPROV := ""
LOCAL aRest  := {}
LOCAL cSQL	 := ""
LOCAL aAreaIni := GetArea()

//		AADD(aRest,cDIGTA)
//		AADD(aRest,cAPROV)


//Return aRest



//STATIC FUNCTION BLIB2()

IF ALLTRIM(cCHAVESD1) == "LFRH"

	cSQL:= "SELECT USUARIO.NOME,SZ2.Z2_USUARIO,Z2_TIPO,SZ2.Z2_PRONT,Z2_DATAPGT,SZ2.Z2_APROV "
  	cSQL+= " FROM dataP10.dbo.SZ2010  AS SZ2 "
  	cSQL+= "  LEFT JOIN [BKIntegraRubi].[dbo].[FINANCE_GRADE_CONSOLIDADA] as TBPGTO ON NumSiga=Z2_CODEMP "
  	cSQL+= "  AND PRONT=Z2_PRONT COLLATE SQL_Latin1_General_CP1_CI_AS "
  	cSQL+= "  AND TIPO=Z2_TIPO COLLATE SQL_Latin1_General_CP1_CI_AS "
//  	cSQL+= "  AND TBPGTO.Z2_CTRID= SZ2.Z2_CTRID COLLATE SQL_Latin1_General_CP1_CI_AS "

  	cSQL+= "  AND TBPGTO.DATAPGT=Z2_DATAPGT COLLATE SQL_Latin1_General_CP1_CI_AS "
  	cSQL+= "  AND TBPGTO.TIPOPES=Z2_TIPOPES COLLATE SQL_Latin1_General_CP1_CI_AS "
  	cSQL+= "  AND TBPGTO.tipcol=Z2_TIPCOL "
  
  	cSQL+= "  AND VALOR=Z2_VALOR "
  	cSQL+= "  LEFT JOIN  [BKIntegraRubi].[dbo].[FINANCE_USUARIOS] AS USUARIO ON TBPGTO.IDUSER=USUARIO.ID"
  	cSQL+= "  WHERE SZ2.D_E_L_E_T_='' AND Z2_E2NUM='"+cPedido+"' AND Z2_CODEMP='"+SM0->M0_CODIGO+"'"

	TCQUERY cSQL NEW ALIAS "QSZ2_2" 

	TCSETFIELD("QSZ2_2","Z2_DATAPGT","D",8,0)

	dbSelectArea("QSZ2_2")
	QSZ2_2->(DbGotop())
	DO WHILE QSZ2_2->(!EOF())
	
		IF ALLTRIM(QSZ2_2->Z2_TIPO) $ "LFE/LRC"
		
			cSQL:= "SELECT TOP 1 USU.CodUsu,NomUsu FROM bk_senior.bk_senior.R067LPR LPR"
			cSQL+= " INNER join bk_senior.bk_senior.R999USU USU on LPR.CodUsu=USU.CodUsu"
			cSQL+= " where "
			IF ALLTRIM(QSZ2_2->Z2_TIPO) == "LFE"
				cSQL+= " MsgLog like '%Tipo Féria%'"
			ELSE
				cSQL+= " MsgLog like '%Tipo Rescisão%'"
			ENDIF
			cSQL+= " AND MsgLog like '%NumEmp: "+ALLTRIM(STR(VAL(SM0->M0_CODIGO)))+"%'"
			cSQL+= " AND MsgLog like '%NumCad: "+ALLTRIM(STR(VAL(QSZ2_2->Z2_PRONT)))+"%'"
			cSQL+= " AND MsgLog like '%Data Pagamento: "+Day2Str(QSZ2_2->Z2_DATAPGT)+"/"+Month2Str(QSZ2_2->Z2_DATAPGT)+"/"+Year2Str(QSZ2_2->Z2_DATAPGT)+"%'"     

			TCQUERY cSQL NEW ALIAS "QLSenior" 

			dbSelectArea("QLSenior")
			IF !EMPTY(QLSenior->NomUsu)
				IF ! ALLTRIM(QLSenior->NomUsu) $ cDIGTA
					cDIGTA += ALLTRIM(QLSenior->NomUsu)+"/"
				ENDIF
			ELSE
				IF !EMPTY(QSZ2_2->NOME)
					cDIGTA := QSZ2_2->NOME
				ELSE
					cDIGTA := QSZ2_2->Z2_USUARIO
				ENDIF
			ENDIF
			QLSenior->(Dbclosearea()) 
		ELSE
			IF !EMPTY(QSZ2_2->NOME)
				cDIGTA := QSZ2_2->NOME
			ELSE
				cDIGTA := QSZ2_2->Z2_USUARIO
			ENDIF
		ENDIF

		IF !EMPTY(QSZ2_2->Z2_APROV)
			cAPROV := QSZ2_2->Z2_APROV
		ELSE
			cAPROV := QSZ2_2->Z2_USUARIO
		ENDIF

		QSZ2_2->(dbSkip())
	ENDDO
	QSZ2_2->(Dbclosearea()) 
	
	IF SUBSTR(cDIGTA,LEN(cDIGTA),1) == "/"
		AADD(aRest,SUBSTR(cDIGTA,1,LEN(cDIGTA)-1))
	ELSE
		AADD(aRest,cDIGTA)
	ENDIF  
	
	AADD(aRest,cAPROV)

ELSE
	IF !EMPTY(cPedido)
	    dbSelectArea("SF1")                   // * Cabeçalho da N.F. de Compra
	    SF1->(dbSetOrder(1))
	    IF SF1->(dbSeek(xFilial("SF1")+cCHAVESD1+"N"))
			cDIGTA := U_BUSER(SF1->F1_XXUSER)
	    ENDIF
	    
		dbSelectArea("SCR")        
		SCR->(dbSetOrder(1))
		SCR->(dbSeek(xFilial("SCR")+"PC"+cPedido,.T.))
		DO WHILE SCR->(!EOF()) .AND. ALLTRIM(SCR->CR_NUM) == ALLTRIM(cPedido)
		    IF !EMPTY(SCR->CR_LIBAPRO)
		    	cAPROV += U_BUSER(SCR->CR_USERLIB)+"/"
		    ENDIF
			SCR->(dbSkip())
		ENDDO
	
		AADD(aRest,cDIGTA)
		AADD(aRest,SUBSTR(cAPROV,1,LEN(cAPROV)-1))
	
	ELSE
	    dbSelectArea("SF1")                   // * Cabeçalho da N.F. de Compra
	    SF1->(dbSetOrder(1))
	    IF SF1->(dbSeek(xFilial("SF1")+cCHAVESD1+"N"))
			cDIGTA := U_BUSER(SF1->F1_XXUSER)
			IF !EMPTY(SF1->F1_XXUSERS)
				cAPROV := U_BUSER(SF1->F1_XXUSERS)
			ELSE
				cAPROV := U_BUSER(SF1->F1_XXUSER)
			ENDIF
	    ENDIF
		
		DbSelectArea("SCR")
		SCR->(DbSetOrder(1))
		DbSeek(xFilial("SCR")+'NF'+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.T.)
		Do While SCR->(!eof()) .AND. ALLTRIM(SCR->CR_NUM) == ALLTRIM(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
		    IF !EMPTY(SCR->CR_LIBAPRO)
		    	cAPROV += "/"+U_BUSER(SCR->CR_USERLIB)
		    ENDIF
			SCR->(dbSkip())
		EndDo
				
		AADD(aRest,cDIGTA)
		AADD(aRest,cAPROV)
		
	ENDIF
ENDIF

RestArea(aAreaIni)
	
Return aRest


STATIC FUNCTION VldPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Data inicial:","Data inicial:","Data inicial:" ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Data final  :","Data final  :","Data final  :" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Gera Saldos :","Gera Saldos :","Gera Saldos :" ,"mv_ch3","N",01,0,2,"C","","mv_par03","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"04","Usar data   :","Usar data   :","Usar data   :" ,"mv_ch4","N",01,0,2,"C","","mv_par04","Movimento","Movimento","Movimento","","","Extrato","Extrato","Extrato","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"05","Incluir CBX/CX1/DRS:","Incluir CBX/CX1/DRS:","Incluir CBX/CX1/DRS:" ,"mv_ch5","N",01,0,2,"C","","mv_par05","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"06","Formato     :","Formato     :","Formato     :" ,"mv_ch6","N",01,0,2,"C","","mv_par06","CSV","CSV","CSV","","","XML","XML","XML","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"07","Bancos:"      ,"Bancos:"      ,"Bancos:"       ,"mv_ch7","N",01,0,2,"C","","mv_par07","Selecionar","Selecionar","Selecionar","","","Todos","Todos","Todos","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"08","Aplicações  :","Aplicações  :","Aplicações  :" ,"mv_ch8","N",01,0,2,"C","","mv_par08","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"09","Usuário Dig/Liberou:","Usuário Dig/Liberou","Usuário Dig/Liberou" ,"mv_ch9","N",01,0,2,"C","","mv_par09","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"10","Filtrar produto","Produto"    ,"Produto"       ,"mv_cha","C",15,0,0,"G",'Vazio() .or. ExistCpo("SB1")',"mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","SB1","S","",""})
AADD(aRegistros,{cPerg,"11","Impostos :","Impostos :","Impostos :" ,"mv_chB","N",01,0,2,"C","","mv_par11","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","S","",""})

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

