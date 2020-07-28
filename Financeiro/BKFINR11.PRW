#Include "PROTHEUS.CH"
#include "rwmake.ch" 
#include "topconn.ch" 

/*   
E5_TIPODOC Descrição
AP Aplicação Financeira
BA Baixa Automática ou Baixa que não tenha movimentação bancária
BD Borderô em cobrança descontada
BL Baixa Aplicação Longo Prazo
C2 Correção Monetária na cobrança descontada
CB Cancelamento Bordero em Cobrança Descontada
CD Cheque Pré-Datado
CH Cheque
CM Correção Monetária
CP Compensação
CX Movimentação do Caixa
D2 Desconto na cobrança descontada
DB Despesas Bancárias
DC Desconto
DV Devolução - Sigaloja
EP Empréstimo
ES Estorno de movimentação
IB Impostos Bancários
J2 Juro na cobrança descontada
JR Juro
LJ Entrada Dinheiro pelo Caixa - SIGALOJA
M2 Multa na cobrança descontada
MT Multa
NCC Nota de Crédito Cliente
NDF Nota de Débito Fornecedor
PA Pagamento Antecipado
PE Pagamento Empréstimo
RA Recebimento Antecipado
RF Resgate de Aplicação Financeira
R$ Entrada em dinheiro - SIGALOJA
SG Sangria do Caixa - SIGALOJA
TC Entrada de Troco - SIGALOJA
TE Transferência Estornada
TL Valor de Tolerância Recebido sobre o título
TR Transferência
VL Movimentação Bancária ou Baixas que movimentem banco
V2 Movimentação Bancária na Cobrança Descontada
*/

/*/{Protheus.doc} BKFINR11
BK - Fluxo de Caixa - Orçado 
@Return
@author Adilson do Prado 
@since 08/02/14
@version P12
/*/


User Function BKFINR11()

//LOCAL cDesc1	:= "Este programa tem como objetivo imprimir o fluxo  "
//LOCAL cDesc2	:= "de Caixa Orçado "
//LOCAL cDesc3	:= ""

PRIVATE cTitulo	    := OemToAnsi("Projeção de Caixa")
PRIVATE cPerg		:= "BKFINR11"
PRIVATE nLastKey	:= 0
PRIVATE cNomePrg	:= "BKFINR11"
PRIVATE cIndiceSE5  := ""
PRIVATE aCtaFin     := {}
PRIVATE dDataI      := DATE()  			// Data Inicial
PRIVATE dDataF      := DATE()  			// Data Final
PRIVATE nSaldos     := 1
PRIVATE nTpData     := 1
PRIVATE nCaixinha   := 1
PRIVATE cFiltPrd    := ""
PRIVATE nUsuario 	:= 0
PRIVATE cAliasTmp1  := "TMP1"
PRIVATE aCabs1      := {}
PRIVATE aCampos1    := {}
PRIVATE aTitulos1   := {}
PRIVATE aStruct1    := {}
PRIVATE oTmpTb1


PRIVATE cAliasTmp2  := "TMP2"
PRIVATE aCabs2      := {}
PRIVATE aCampos2    := {}
PRIVATE aTitulos2   := {}
PRIVATE aStruct2    := {}
PRIVATE oTmpTb2

PRIVATE cAliasTmp3  := "TMP3"
PRIVATE aCabs3      := {}
PRIVATE aCampos3    := {}
PRIVATE aTitulos3   := {}
PRIVATE aStruct3    := {}
PRIVATE oTmpTb3

PRIVATE cAliasTmp4  := "TMP4"
PRIVATE aCabs4      := {}
PRIVATE aCampos4    := {}
PRIVATE aTitulos4   := {}
PRIVATE aStruct4    := {} 
PRIVATE oTmpTb4

PRIVATE cAliasTmp5  := "TMP5"
PRIVATE aCabs5      := {}
PRIVATE aCampos5    := {}
PRIVATE aTitulos5   := {}
PRIVATE aStruct5    := {}
PRIVATE oTmpTb5

PRIVATE aResumo     := ARRAY(12)
PRIVATE nSaldoAnt   := 0

PRIVATE nMoeda      := 1
PRIVATE nMoedaBco   := 1
PRIVATE nDecs       := 2
PRIVATE aDESCRH := {}
PRIVATE aSitFin := {}

PRIVATE aPlans      := {}
PRIVATE cFiltro     := ""

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

// Verifica as perguntas selecionadas
ValidPerg(cPerg)
IF !Pergunte(cPerg,.T.)
	Return Nil
ENDIF

// Variaveis utilizadas para parametros	
dDataI   := MV_PAR01	// Data Inicial
dDataF   := MV_PAR02	// Data Final
nSaldos  := MV_PAR03	// Sintética/Analítica
nTpData  := MV_PAR04	// Data do Movimento/Data Extrato
nCaixinha:= MV_PAR05	// Inclui Movimento Caixinha
cFiltPrd := MV_PAR06    // Filtrar produto
nUsuario := MV_PAR07    // QUEM DIGITOU

cTitulo  := OemToAnsi(cTitulo+" de "+DTOC(MV_PAR01)+" até "+DTOC(MV_PAR02))+" - "+IIF(nTpData==1,"Data do Movimento","Data do Extrato")+"  - Data Base: "+DTOC(dDataBase) 
If !EMPTY(cFiltPrd)
	cTitulo += " - Produto: "+TRIM(cFiltPrd)  
EndIf

IF nSaldos == 1
	KFin02ExpSld()
ENDIF

KFin02ExpMov()

dbSelectArea("SA6")
dbSetOrder(1)

Return( .T. )




// KFin02ExpSld() - Exportar os saldos Bancarios

Static Function KFin02ExpSld()

AADD(aTitulos1,cNomePrg+"/"+TRIM(SUBSTR(cUsuario,7,15))+" - "+TRIM(cTitulo))

// Data
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

// Saldo INICIAL
AADD(aStruct1,{"A6_SALDO","N",20,2})
AADD(aCampos1,cAliasTmp1+"->A6_SALDO")
AADD(aCabs1  ,"Saldo Inicial")

// Recebido
AADD(aStruct1,{"A6_REC","N",20,2})
AADD(aCampos1,cAliasTmp1+"->A6_REC")
AADD(aCabs1  ,"Entradas")

// Pago
AADD(aStruct1,{"A6_PAGO","N",20,2})
AADD(aCampos1,cAliasTmp1+"->A6_PAGO")
AADD(aCabs1  ,"Saidas")

// Entrada por transf
AADD(aStruct1,{"A6_TRREC","N",20,2})
AADD(aCampos1,cAliasTmp1+"->A6_TRREC")
AADD(aCabs1  ,"Transf. Entradas")

// Saida por transf
AADD(aStruct1,{"A6_TRPAGO","N",20,2})
AADD(aCampos1,cAliasTmp1+"->A6_TRPAGO")
AADD(aCabs1  ,"Transf. Saidas")

// Saldo Atual
AADD(aStruct1,{"A6_SATUAL","N",20,2})
AADD(aCampos1,cAliasTmp1+"->A6_SATUAL")
AADD(aCabs1  ,"Saldo Disponível")

// Cria o arquivo tempor rio das movimentacoes.

///cArqTmp1	:= CriaTrab(aStruct1)
///IF SELECT(cAliasTmp1) > 0
///   dbSelectArea(cAliasTmp1)
///   dbCloseArea()
//ENDIF
//dbUseArea(.T.,,cArqTmp1,cAliasTmp1,if(.F. .OR. .F.,!.F., NIL),.F.)
//IndRegua (cAliasTmp1,cArqTmp1,"A6_COD+A6_AGENCIA+A6_NUMCON",,,OemToAnsi("Selecionando Registros...") )  //
//dbSetOrder(1)

oTmpTb1 := FWTemporaryTable():New(cAliasTmp1)
oTmpTb1:SetFields( aStruct1 )
oTmpTb1:AddIndex("indice1", {"A6_COD","A6_AGENCIA","A6_NUMCON"} )
oTmpTb1:Create()


/*
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
		dbSelectArea(cAliasTmp1)
		RecLock( cAliasTmp1, .T. )
		(cAliasTmp1)->A6_DATA    := dDataF
		(cAliasTmp1)->A6_COD     := SA6->A6_COD	
		(cAliasTmp1)->A6_AGENCIA := SA6->A6_AGENCIA
		(cAliasTmp1)->A6_NUMCON  := SA6->A6_NUMCON	
		(cAliasTmp1)->A6_NREDUZ  := SA6->A6_NREDUZ	
		(cAliasTmp1)->A6_SALDO   := 0
		(cAliasTmp1)->A6_REC     := 0
		(cAliasTmp1)->A6_PAGO    := 0
		(cAliasTmp1)->A6_TRREC   := 0
		(cAliasTmp1)->A6_TRPAGO  := 0
		(cAliasTmp1)->A6_SATUAL  := 0
		msUnlock()

	EndIf
	SA6->(dbSkip())
EndDo
*/

ProcRegua(SA6->(LASTREC()))
Processa( {|| KFin02Sld()})

//ProcRegua((cAliasTmp1)->(LASTREC()))
//Processa( {|| U_GeraCSV(cAliasTmp1,cNomePrg+"-Saldos",aTitulos1,aCampos1,aCabs1)})

//Ferase(cArqTmp1 + GetDBExtension())

Return Nil



/*/
Busca os saldos bancarios
*/
Static Function KFin02Sld()

LOCAL cBanco
LOCAL cAgencia
LOCAL cConta
LOCAL nOrdSE5 	:= SE5->(IndexOrd())
LOCAL cChave
LOCAL cIndex
LOCAL nIndex
LOCAL nCasas	:= nDecs
LOCAL cFil

LOCAL nSaldoIni := 0
LOCAL nDisponiv	:= 0
LOCAL nAplic    := 0
LOCAL nRecBco   := 0
LOCAL nPagBco   := 0
LOCAL nTrRecBco := 0
LOCAL nTrPagBco := 0

dbSelectArea("SE5")
dbSetOrder(nOrdSE5)
cIndex  := GetNextAlias()
IF nTpData == 1
	cChave  := "E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA"
ELSE
	cChave  := "E5_FILIAL+DTOS(E5_DTDISPO)+E5_BANCO+E5_AGENCIA+E5_CONTA"
ENDIF

cFil	:= xFilial("SE5")

IndRegua("SE5",cIndex,cChave,,fr530Check(),OemToAnsi("Selecionando Registros...")) 
nIndex   := RetIndex("SE5")
dbSelectArea("SE5")		
//#IFNDEF TOP
//	dbSetIndex(cIndex+OrdBagExt())
//#ENDIF
dbSetOrder(nIndex+1)
dbGoTop()
//dbSeek(cFil+DtoS(dDataI),.T.)

cTab14 := ""
SX5->(MsSeek( xFilial("SX5") + "14" ) )
While !SX5->(Eof()) .And. SX5->X5_TABELA == "14"
	cTab14 += AllTrim(SX5->X5_CHAVE) + "/"
	SX5->(dbSkip( ))
Enddo

// Procura pelo 1.o banco no SA6
dbSelectArea( "SA6" )
dbSetOrder( 1 )
dbSeek( xFilial("SA6") )
ProcRegua(LastRec()) // Numero de registros a processar
While SA6->A6_FILIAL == xFilial( "SA6" ) .And. ! Eof()

    IncProc()
    
	IF lEnd
		Exit
	End


	IF nCaixinha <> 1
		If ALLTRIM(SA6->A6_COD) $ "CBX/CX1/DRS"
			SA6->(dbSkip())
			Loop
		EndIf
	ENDIF



	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se n„o considerar banco para o Fluxo de Caixa              	 	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SA6->A6_FLUXCAI == "N"
		dbSkip()
		Loop
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura pelo saldo anterior dos bancos no SE8 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//dbSelectArea("SE8")
	//dbSetOrder(1)
	//If ! dbSeek(xFilial("SE8")+SA6->A6_COD+SA6->A6_AGENCIA+SA6->A6_NUMCON+DtoS( dDtProc ),.T.)
	//	dbSkip( -1 )
	//EndIf
    //
	//If SA6->A6_COD 		!= SE8->E8_BANCO	.or. ;
	//	SA6->A6_AGENCIA	!= SE8->E8_AGENCIA	.or. ;
	//	SA6->A6_NUMCON 	!= SE8->E8_CONTA	.or. ;
	//	SE8->E8_DTSALAT	>  dDtProc
    //
	//	dbSelectArea("SA6")
	//	dbSkip()
	//	Loop
	//Else
	//	nMoedaBco := Iif(cPaisLoc=="BRA",1,Max(SA6->A6_MOEDA,1))
	//	nSaldoIni += xMoeda(SE8->E8_SALATUA,nMoedaBco,nMoeda,SE8->E8_DTSALAT,nDecs+1)
	//EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pesquisa saldo anterior                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cBanco    := A6_COD
	cAgencia  := A6_AGENCIA
	cConta    := A6_NUMCON
	nSaldoIni := 0
	nDisponiv := 0
	nAplic    := 0
	nRecBco   := 0
	nPagBco   := 0
	nTrRecBco := 0
	nTrPagBco := 0

	dbSelectArea("SE8")
	dbSeek( xFilial()+cBanco+cAgencia+cConta+DtoS(dDataI), .T. )
	dbSkip( -1 )
	If E8_BANCO!=cBanco .or. E8_AGENCIA!=cAgencia .or. E8_CONTA!=cConta ;
		.or. Bof()
		nSaldoIni := 0
	Else
		nSaldoIni += xMoeda(SE8->E8_SALATUA,nMoedaBco,nMoeda,SE8->E8_DTSALAT,nDecs+1)
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Localizar movimentacao bancaria deste banco                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE5")
	dbSetOrder(nIndex + 1 )
	dbSeek(cFil+dToS(dDataI)+cBanco+cAgencia+cConta,.T.)
	                                  
	IF nTpData == 1
		bCondWhile := { || !Eof() .And. E5_FILIAL == xFilial('SE5') .And. E5_DATA == dDataI .and. E5_BANCO+E5_AGENCIA+E5_CONTA == cBanco+cAgencia+cConta }
	ELSE
		bCondWhile := { || !Eof() .And. E5_FILIAL == xFilial('SE5') .And. E5_DTDISPO == dDataI .and. E5_BANCO+E5_AGENCIA+E5_CONTA == cBanco+cAgencia+cConta }
	ENDIF	
	ProcRegua(LastRec()) // Numero de registros a processar
	While Eval(bCondWhile)
		
		IncProc()
		
		
		If !Fr530Skip(cBanco,cAgencia,cConta)
			dbSkip()
			Loop
		EndIf
		

		IF E5_MOEDA $ "C1/C2/C3/C4/C5/CH" .and. Empty(E5_NUMCHEQ) .and. !(E5_TIPODOC $ "TR#TE")
			dbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Na transferencia somente considera nestes numerarios 		 ³
		//³ No Fina100 ‚ tratado desta forma.                    		 ³
		//³ As transferencias TR de titulos p/ Desconto/Cau‡Æo (FINA060) ³
		//³ nÆo sofrem mesmo tratamento dos TR bancarias do FINA100      ³
		//³ Aclaracao : Foi incluido o tipo $ para os movimentos en di-- ³
		//³ nheiro em QUALQUER moeda, pois o R$ nao e representativo     ³
		//³ fora do BRASIL. Bruno 07/12/2000 Paraguai                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If E5_TIPODOC $ "TR/TE" .and. Empty(E5_NUMERO)
         If !(E5_MOEDA $ "R$/DO/TB/TC/CH"+cTab14+IIf(cPaisLoc=="BRA","","/$ "))
				dbSkip()
				Loop
			Endif
		Endif

		If E5_TIPODOC $ "TR/TE" .and. (Substr(E5_NUMCHEQ,1,1)=="*" ;
			.or. Substr(E5_DOCUMEN,1,1) == "*" )
			dbSkip()
			Loop
		Endif

		If E5_MOEDA == "CH" .and. (IsCaixaLoja(E5_BANCO) .And. !lCxLoja .And. E5_TIPODOC $ "TR/TE")		// Sangria
			dbSkip()
			Loop
		Endif

		If SubStr(E5_NUMCHEQ,1,1)=="*"  .AND. E5_RECPAG=="P"    //cheque para juntar (PA)
			dbSkip()
			Loop
		Endif

		If !Empty( E5_MOTBX )
			If !MovBcoBx( E5_MOTBX )
				dbSkip( )
				Loop
			EndIf
		EndIf

		dbSelectArea("SE5")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³VerIfica se foi utilizada taxa contratada para moeda > 1          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE5->(FieldPos('E5_TXMOEDA')) > 0
			nTxMoedBc := SE5->E5_TXMOEDA	
		Else  	
			nTxMoedBc := 0
		Endif

	    nValor := xMoeda(E5_VALOR,nMoedaBco,nMoeda,E5_DATA,nDecs+1)
		//nValor := Round(xMoeda(E5_VALOR,nMoedaBco,nMoeda,E5_DATA,nCasas+1,nTxMoedBc),nCasas) 

		IF !(SE5->E5_RECPAG $ "PR" .and. SE5->E5_TIPODOC == "AP")
			IF !SE5->E5_TIPODOC $ "TR/TE"
				IF E5_RECPAG = "R"
					nRecBco+=nValor
				Else
					nPagBco+=nValor
				EndIF
			ELSE
				IF E5_RECPAG = "R"
					nTrRecBco+=nValor
				Else
					nTrPagBco+=nValor
				EndIF
			ENDIF	
		Else
			If SE5->E5_RECPAG == "P" .and. SE5->E5_TIPODOC == "AP"
				nAplic += xMoeda(E5_VALOR,nMoedaBco,1,E5_DATA,nCasas+1)
			Else	
				nAplic -= xMoeda(E5_VALOR,nMoedaBco,1,E5_DATA,nCasas+1)
			Endif	
		Endif

		dbSkip()
	Enddo

	nDisponiv := nSaldoIni+nRecBco-nPagBco+nTrRecBco-nTrPagBco-nAplic
	
	RecLock( cAliasTmp1, .T. )
	(cAliasTmp1)->A6_DATA    := SE8->E8_DTSALAT
	(cAliasTmp1)->A6_COD     := SE8->E8_BANCO	
	(cAliasTmp1)->A6_AGENCIA := SE8->E8_AGENCIA	
	(cAliasTmp1)->A6_NUMCON  := SE8->E8_CONTA	
	(cAliasTmp1)->A6_NREDUZ  := SA6->A6_NREDUZ	
	(cAliasTmp1)->A6_SALDO   := xMoeda(SE8->E8_SALATUA,nMoedaBco,nMoeda,SE8->E8_DTSALAT,nDecs+1)
	(cAliasTmp1)->A6_REC     := nRecBco
	(cAliasTmp1)->A6_PAGO    := nPagBco
	(cAliasTmp1)->A6_TRREC   := nTrRecBco
	(cAliasTmp1)->A6_TRPAGO  := nTrPagBco
	(cAliasTmp1)->A6_SATUAL  := nDisponiv
	msUnlock()
    
	nSaldoAnt += nDisponiv
	
	dbSelectArea("SA6")
	dbSkip()
	
EndDo

dbSelectArea("SA6")
dbSetOrder(1)
Set Filter To
	
dbSelectArea("SE5")
RetIndex("SE5")
dbSetOrder(1)
Set Filter To
	
If !Empty(cIndex)
	FErase(cIndex+OrdBagExt())
Endif

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fr530Skip ³ Autor ³ Pilar S. Albaladejo	  ³ Data ³ 13.10.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Pula registros de acordo com as condicoes (AS 400/CDX/ADS)  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINR530.PRX																  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fr530Skip(cBanco,cAgencia,cConta)

Local lRet := .T.

IF E5_TIPODOC $ "DC/JR/MT/CM/BA/D2/J2/M2/C2/V2"  //Valores de Baixas
	lRet := .F.
ElseIf E5_BANCO+E5_AGENCIA+E5_CONTA!=cBanco+cAgencia+cConta
	lRet := .F.
ElseIf E5_SITUACA = "C"		//Cancelado
	lRet := .F.
EndIF
Return lRet


Static Function fr530Check()
IF nTpData == 1
	cFiltro := 'DTOS(E5_DATA) == "'+DTOS(dDataI)+'"'
ELSE
	cFiltro := 'DTOS(E5_DTDISPO) == "'+DTOS(dDataI)+'"'
ENDIF
Return cFiltro



Static Function KFin02ExpMov()

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
         

// Temporário Sintético
// ----------------------------------------------------------------------------------

AADD(aTitulos2,cNomePrg+"/"+TRIM(SUBSTR(cUsuario,7,15))+" - "+cTitulo+OemToAnsi(" - Sintético"))


// Data do Movimento
AADD(aStruct2,{"XXDATA","D",8,0})
AADD(aCampos2,cAliasTmp2+"->XXDATA")
AADD(aCabs2  ,"Data")

// Conta Financeira munado para natureza
AADD(aStruct2,{"CTFIN","C",10,0})
AADD(aCampos2,cAliasTmp2+"->CTFIN")
AADD(aCabs2  ,"Natureza Financeira")
//AADD(aCabs2  ,"Cta Financeira")

// Descricao da Conta Financeira
AADD(aStruct2,{"DESCRCT","C",50,0})
AADD(aCampos2,cAliasTmp2+"->DESCRCT")
AADD(aCabs2  ,"Descricao")

// Receber
AADD(aStruct2,{"RECEBER","N",20,2})
AADD(aCampos2,cAliasTmp2+"->RECEBER")
AADD(aCabs2  ,"Receber")

// Pagar
AADD(aStruct2,{"PAGAR","N",20,2})
AADD(aCampos2,cAliasTmp2+"->PAGAR")
AADD(aCabs2  ,"Pagar")

///cArqTmp2 := CriaTrab(aStruct2)
///dbUseArea(.T.,,cArqTmp2,cAliasTmp2,if(.F. .OR. .F.,!.F., NIL),.F.)
///IndRegua (cAliasTmp2,cArqTmp2,"CTFIN+DTOS(XXDATA)",,,OemToAnsi("Selecionando Registros...") )  //
///dbSetOrder(1)
oTmpTb2 := FWTemporaryTable():New(cAliasTmp2)
oTmpTb2:SetFields( aStruct2 )
oTmpTb2:AddIndex("indice2", {"CTFIN","XXDATA"} )
oTmpTb2:Create()


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


///cArqTmp4 := CriaTrab(aStruct4)
///dbUseArea(.T.,,cArqTmp4,cAliasTmp4,if(.F. .OR. .F.,!.F., NIL),.F.)
///IndRegua (cAliasTmp4,cArqTmp4,"CC",,,OemToAnsi("Selecionando Registros...") )  //
///dbSetOrder(1)
oTmpTb4 := FWTemporaryTable():New(cAliasTmp4)
oTmpTb4:SetFields( aStruct4 )
oTmpTb4:AddIndex("indice4", {"CC"} )
oTmpTb4:Create()



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

///cArqTmp5 := CriaTrab(aStruct5)
///dbUseArea(.T.,,cArqTmp5,cAliasTmp5,if(.F. .OR. .F.,!.F., NIL),.F.)
///IndRegua (cAliasTmp5,cArqTmp5,"DESCFIN",,,OemToAnsi("Selecionando Registros...") )  //
///dbSetOrder(1)

oTmpTb5 := FWTemporaryTable():New(cAliasTmp5)
oTmpTb5:SetFields(aStruct5)
oTmpTb5:AddIndex("indice5", {"DESCFIN"} )
oTmpTb5:Create()


// Temporário Analítico
// ----------------------------------------------------------------------------------

AADD(aTitulos3,cNomePrg+"/"+TRIM(SUBSTR(cUsuario,7,15))+" - "+cTitulo+OemToAnsi(" - Analitico"))

// Data
//AADD(aStruct3,{"XX_DATA","D",8,0})
//AADD(aCampos3,cAliasTmp3+"->XX_DATA")
//AADD(aCabs3  ,"Data")

// Conta Financeira mudado para natureza
//AADD(aStruct3,{"XXCTFIN","C",10,0})
//AADD(aCampos3,cAliasTmp3+"->XXCTFIN")
//AADD(aCabs3  ,"Natureza Financeira")
//AADD(aCabs3  ,"Cta Financeira")

// Descricao da Conta Financeira
//AADD(aStruct3,{"DESCRCT","C",50,0})
//AADD(aCampos3,cAliasTmp3+"->DESCRCT")
//AADD(aCabs3  ,"Descricao Natureza")


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

// Descricao Financeiro
//AADD(aStruct3,{"DESCFIN","C",40,0})
//AADD(aCampos3,cAliasTmp3+"->DESCFIN")
//AADD(aCabs3  ,"Descrição Financeiro")

// Prefixo
//AADD(aStruct3,{"XX_Prefixo","C",3,0})
//AADD(aCampos3,cAliasTmp3+"->XX_Prefixo")
//AADD(aCabs3  ,"Prefixo")

// No. Titulo
AADD(aStruct3,{"XX_TITULO","C",9,0})
AADD(aCampos3,cAliasTmp3+"->XX_TITULO")
AADD(aCabs3  ,"No. Titulo")

// Parcela
//AADD(aStruct3,{"XX_PARCELA","C",1,0})
//AADD(aCampos3,cAliasTmp3+"->XX_PARCELA")
//AADD(aCabs3  ,"Parcela")

// Tipo
//AADD(aStruct3,{"XX_TIPO","C",3,0})
//AADD(aCampos3,cAliasTmp3+"->XX_TIPO")
//AADD(aCabs3  ,"Tipo")

// Cod. Cli Forn
//AADD(aStruct3,{"XX_CLIFOR","C",6,0})
//AADD(aCampos3,cAliasTmp3+"->XX_CLIFOR")
//AADD(aCabs3  ,"Cliente/Fornec.")

// Loja
//AADD(aStruct3,{"XX_Loja","C",4,0})
//AADD(aCampos3,cAliasTmp3+"->XX_Loja")
//AADD(aCabs3  ,"Loja")

// Loja
AADD(aStruct3,{"XX_NOME","C",20,0})
AADD(aCampos3,cAliasTmp3+"->XX_NOME")
AADD(aCabs3  ,"Nome Cli/Forn")


// Vencto real
AADD(aStruct3,{"XX_VENCREA","D",8,0})
AADD(aCampos3,cAliasTmp3+"->XX_VENCREA")
AADD(aCabs3  ,"Vencto real")

// Vlr.Titulo
AADD(aStruct3,{"XX_VALOR","N",20,2})
AADD(aCampos3,cAliasTmp3+"->XX_VALOR")
AADD(aCabs3  ,"Vlr.Titulo")

// Historico
AADD(aStruct3,{"XX_HIST","M",10,0})
AADD(aCampos3,cAliasTmp3+"->XX_HIST")
AADD(aCabs3  ,"Historico")


// Receber
AADD(aStruct3,{"RECEBER","N",20,2})
AADD(aCampos3,cAliasTmp3+"->RECEBER")
AADD(aCabs3  ,"Receber")


// Pagar
AADD(aStruct3,{"PAGAR","N",20,2})
AADD(aCampos3,cAliasTmp3+"->PAGAR")
AADD(aCabs3  ,"Pagar")

IF nUsuario == 1
	// Digitado
	AADD(aStruct3,{"DIGITADO","C",100,0})
	AADD(aCampos3,cAliasTmp3+"->DIGITADO")
	AADD(aCabs3  ,"Digitado por")

	// Liberado
	AADD(aStruct3,{"LIBERADO","C",100,0})
	AADD(aCampos3,cAliasTmp3+"->LIBERADO")
	AADD(aCabs3  ,"Liberado por")
ENDIF

///cArqTmp3 := CriaTrab(aStruct3)
///dbUseArea(.T.,,cArqTmp3,cAliasTmp3,if(.F. .OR. .F.,!.F., NIL),.F.)
///IndRegua (cAliasTmp3,cArqTmp3,"XX_VENCREA",,,OemToAnsi("Selecionando Registros...") )  //
///dbSetOrder(1)
oTmpTb3 := FWTemporaryTable():New(cAliasTmp3)
oTmpTb3:SetFields( aStruct3 )
oTmpTb3:AddIndex("indice3", {"XX_VENCREA"} )
oTmpTb3:Create()


// Grava os arquivos temporários
// ----------------------------------------------------------------------------------


ProcRegua(100)
Processa( {|| KFin02Mov( nSaldoAnt)})

/* removido geracao sintetico
ProcRegua((cAliasTmp2)->(LASTREC()))
Processa( {|| U_GeraCSV(cAliasTmp2,cNomePrg+"-Sintetico"+STR(nTpData,1),aTitulos2,aCampos2,aCabs2)})


ProcRegua((cAliasTmp4)->(LASTREC()))
Processa( {|| U_GeraCSV(cAliasTmp4,cNomePrg+"-Sintetico_CC"+STR(nTpData,1),aTitulos4,aCampos4,aCabs4)})

ProcRegua((cAliasTmp5)->(LASTREC()))
Processa( {|| U_GeraCSV(cAliasTmp5,cNomePrg+"-Sintetico_Fin"+STR(nTpData,1),aTitulos5,aCampos5,aCabs5)})
*/  

//ProcRegua((cAliasTmp3)->(LASTREC()))
//Processa( {|| U_GeraCSV(cAliasTmp3,cNomePrg+"-Analitico"+STR(nTpData,1),aTitulos3,aCampos3,aCabs3)})

//If nFormato == 1
//	ProcRegua((cAliasTmp3)->(LASTREC()))
//	Processa( {|| U_GeraCSV(cAliasTmp3,cNomePrg+"-Analitico"+STR(nTpData,1),aTitulos3,aCampos3,aCabs3)})
//Else  


	aPlans := {}
	If !EMPTY(cFiltPrd)
		cFiltro := "B1_COD = '"+cFiltPrd+"'"
		AADD(aPlans,{cAliasTmp3,cNomePrg+"-Analitico",cFiltro,cTitulo+OemToAnsi(" - Analítico"),aCampos3,aCabs3, /*aImpr3*/ , /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
    ELSE
		AADD(aPlans,{cAliasTmp3,cNomePrg+"-Analitico","",cTitulo+OemToAnsi(" - Analítico"),aCampos3,aCabs3, /*aImpr3*/ , /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
	EndIf
	If nSaldos == 1                                              
		AADD(aPlans,{cAliasTmp1,cNomePrg+"-Saldos Bancários","",OemToAnsi("Projeção de Caixa - Saldos bancários"),aCampos1,aCabs1, /* aImpr1 */ , /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
	EndIf
	U_GeraXml(aPlans,cTitulo,cNomePrg,.F.)
//EndIf

If nSaldos == 1  
	If SELECT(cAliasTmp1) > 0
		///(cAliasTmp1)->(dbCloseArea())
		oTmpTb1:Delete()
	EndIf
	///fErase( cArqTmp1 + OrdBagExt() )
	///fErase( cArqTmp1 + GetDBExtension() )
EndIf

If SELECT(cAliasTmp2) > 0
	//(cAliasTmp2)->(dbCloseArea())
	oTmpTb2:Delete()
EndIf
//fErase( cArqTmp2 + OrdBagExt() )
//fErase( cArqTmp2 + GetDBExtension() )

If SELECT(cAliasTmp3) > 0
	///(cAliasTmp3)->(dbCloseArea())
	oTmpTb3:Delete()
EndIf
///fErase( cArqTmp3 + OrdBagExt() )
///fErase( cArqTmp3 + GetDBExtension() )

If SELECT(cAliasTmp4) > 0
	///(cAliasTmp4)->(dbCloseArea())
	oTmpTb4:Delete()
EndIf

If SELECT(cAliasTmp5) > 0
	///(cAliasTmp5)->(dbCloseArea())
	oTmpTb5:Delete()
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
±±³Fun‡„o	 ³ FrK02Grav³ Autor ³ Alessandro B. Freire  ³ Data ³ 07/04/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Filtra os registros do SE5 e Cria um arquivo Tempor rio	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FrK02Grava(nSaldoAnt, cArqTmp1)					    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nSaldoAnt - Saldo Anterior dos bancos					  ³±±
±±³			 ³ cArqTmp1	 - Nome do Arquivo tempor rio. Deve ser passado   ³±±
±±³			 ³ 				por parƒmetro. 								  ³±±
±±³			 ³ aResumo	 - Resumo financeiro, por tipo de aplica‡Æo. Deve ³±±
±±³			 ³ 				ser passado por parƒmetro. 					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ KFINR01													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

STATIC FUNCTION KFin02Mov( nSaldoAnt )

LOCAL nDias		  := 0
LOCAL nPagar      := 0
LOCAL nReceber    := 0
LOCAL cCtaFin     := SPACE(12)
LOCAL cTHist	  := ""
LOCAL dDataBs 	  := dDataBase
LOCAL cProduto    := ""
LOCAL lFiltPrd    := .F.
LOCAL cDigitado   := ""
LOCAL cLiberado   := ""
LOCAL aLib        := {}

nDias := (dDataF-dDataI)+1
dDataBs:= dDataI

nFin := 3
For j := 1 To nDias
	
	dDataVenc := dDataBs+j-1

    // Contas a Pagar
    
	dbSelectArea("SE2")
	// ORDE Filial
	SE2->(dbSetOrder(3))
	SE2->(dbSeek(xFilial("SE2")+DTOS(dDataVenc) ,.t.))
	
    MVX_par02 := 1  // Moeda 
	MVX_par11 := 1	// Retroativo? 
 	MVX_par17 := 1	// Compoe Saldo por?		(Data da Baixa/  Data de Credito/Data Digitacao)  
 	
	ProcRegua(LastRec()) // Numero de registros a processar
	While !Eof() .And. E2_VENCREA == dDataVenc
		IncProc()

		cProduto  := ""
		lFiltPrd  := .F.
		cDigitado := ""
		cLiberado := ""
		
		//IF mv_par03 == 1 .and. E2_FILIAL != cFilial
		//	Exit
		//EndIF

		//If SE2->E2_SALDO == 0 .and. IIf(MVX_par11==1,SE2->E2_BAIXA <= dDataBase,.t.)
		//If SE2->E2_SALDO == 0 .and. IIf(MVX_par11==1,SE2->E2_BAIXA <= dDataVenc,.t.)
		//	SE2->(dbSkip())
		//	Loop
		//End
		
		If MVX_par11 == 1   	// Retroativo? 
			nPagar := SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZA,"P",SE2->E2_FORNECE,MVX_par02,SE2->E2_VENCREA,dDataBase,SE2->E2_LOJA,,If(cPaisLoc=="BRA",SE2->E2_TXMOEDA,0), MVX_par17)
			IF SE2->E2_SALDO == 0 
			    nPagar := nPagar - SE2->E2_DESCONT + SE2->E2_ACRESC
			ENDIF
		Else
			// Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
			lTxMoeda := SM2->(MsSeek(SE2->E2_VENCREA)) .And. SM2->&("M2_MOEDA"+Alltrim(Str(MVX_par02))) != 0
			nPagar   := xMoeda((SE2->E2_SALDO+SE2->E2_SDACRES-SE2->E2_SDDECRE),SE2->E2_MOEDA,MVX_par02,,,If(cPaisLoc=="BRA",SE2->E2_TXMOEDA,0))
		End



//		If E2_TIPO $ MVPAGANT
//			dbSkip( )
//			Loop
//		Endif
		
		If SE2->E2_FLUXO == "N" //.or. SE2->E2_EMIS1 > dDataBase //.and. mv_par14 == 2) //titulo com emissao futura
			dbSkip()
			Loop
		End
		
		dbSelectArea("SE2")
//		If mv_par03 == 1
			dbSetOrder(3)
//		Endif
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se existe cheque sobre titulo e busca no  ³
		//³SEF para verificar se cheque esta liberado para    ³
		//³imprimir ou nao o titulo.                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE2->E2_IMPCHEQ == "S" .And. lLibCheq
			aAreaSE2 := GetArea()
			dbSelectArea("SEF")
			SEF->(dbSetOrder(3))      
			SEF->(MsSeek(xFilial("SEF")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)))
			While SEF->(!Eof()) .And. lChqLiber .And.; 
					SEF->(EF_FILIAL+EF_PREFIXO+EF_TITULO+EF_PARCELA+EF_TIPO) ==;
					xFilial("SEF")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)
				If SEF->EF_ORIGEM = "FINA390TIT" .And. SEF->EF_LIBER == "S"
					lChqLiber := .F.
				EndIf
				SEF->(dbSkip())
			EndDo
			RestArea(aAreaSE2)
			If !lChqLiber
				SE2->(dbSkip())
				Loop
			EndIf
		EndIf

        // DESCONSIDERA TITULOS BAIXADOS NO PERIODO      
        IF SE2->E2_SALDO == 0
        	IF SE2->E2_BAIXA >= MV_PAR01  .AND. SE2->E2_BAIXA <= MV_PAR02
        		SE2->(dbSkip())
				Loop
			ENDIF
        ENDIF
  		

		// TITULO TIPO ABATIMENTO
		IF SE2->E2_TIPO $ MVABATIM .or. SE2->E2_TIPO $ MV_CPNEG
			nPagar  := nPagar * -1
		Endif

		nAbatim := 0
		nAbatim := SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",MVX_par02,,SE2->E2_FORNECE,SE2->E2_LOJA)

        IF nAbatim  > 0
        	nPagar  := nAbatim * -1
        ENDIF
        

		//IF EMPTY(cCtaFin)
	   		cCtaFin := SE2->E2_NATUREZ //SE2->E2_XXCTFIN
		//ENDIF	
		
		// Gravar sintetico
		
//		IF CTH->(dbSeek(xFilial("CTH")+cCtaFin,.F.))
//			cDescrCt := CTH->CTH_DESC01
//		ELSE
		IF SED->(dbSeek(xFilial("SED")+cCtaFin,.F.))
			cDescrCt := SED->ED_DESCRIC
		ELSE
			cDescrCt := ALLTRIM(SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA)+" "+TRIM(SE2->E2_NOMFOR)
		ENDIF   

		dbSelectArea(cAliasTmp2)
		IF !dbSeek(cCtaFin+DTOS(SE2->E2_VENCREA))
			RecLock( cAliasTmp2, .T. )
			(cAliasTmp2)->XXDATA   := SE2->E2_VENCREA
			(cAliasTmp2)->CTFIN    := cCtaFin
		ELSE 
			RecLock( cAliasTmp2, .F. )
		ENDIF
		(cAliasTmp2)->DESCRCT    := cDescrCt
		(cAliasTmp2)->RECEBER    += 0
		(cAliasTmp2)->PAGAR      += nPagar
		msUnlock()
     
   		cHist  := ""
   		aTot := {}
		nTot := 0
	    cTHist := ""
		nLinHis := 0
  		nMaxObs := 0
  		nMaxObs := 80 //Iif(lLands,120,090)
        cChave	:= ""
        lEntrada:= .T.
 		IF SE2->E2_TIPO $ "TX #ISS#TXA#INS"
 			IF !EMPTY(ALLTRIM(SE2->E2_TITPAI))
   				cChave := SUBSTR(SE2->E2_TITPAI,4,9)+SUBSTR(SE2->E2_TITPAI,1,3)+SUBSTR(SE2->E2_TITPAI,18,8) //E  000000014  NF 00108501
   			ELSE
            	lEntrada:= .F.
   				cChave := SE2->E2_NUM+SE2->E2_PREFIXO
   			ENDIF
   		ELSE
   			cChave := SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA
   		ENDIF
   			
   			 
		nVALBRUT := 0
   		IF lEntrada
   			cProduto := ""
   			lFiltPrd := .F.
		 
	    	dbSelectArea("SD1")        
	    	SD1->(dbSetOrder(1))
   			IF SD1->(dbSeek(xFilial("SD1")+cChave,.T.))
				aLIB:= {}
				IF nUsuario == 1
					aLIB:= U_BLibera(cChave,SD1->D1_PEDIDO) // Localiza liberação Alcada
					cDigitado := aLIB[1]
					cLiberado := aLIB[2]
				ENDIF

   				dbSelectArea("SF1")
   				SF1->(dbSetOrder(1))
   				IF SF1->(dbSeek(xFilial("SF1")+cChave+"N"))
   					IF (SF1->F1_VALIRF + SF1->F1_ISS + SF1->F1_INSS + SF1->F1_VALPIS + SF1->F1_VALCOFI + SF1->F1_VALCSLL) > 0 
   						nVALBRUT := SF1->F1_VALBRUT
   					ENDIF
				ENDIF
				
   			ENDIF

	    	DO WHILE SD1->(!EOF()) .AND. xFilial("SD1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == ;
	    		xFilial("SD1")+cChave

				// Se algum produto satisfazer o filtro, considerá-lo
				IF !EMPTY(cFiltPrd) .AND. TRIM(SD1->D1_COD) == TRIM(cFiltPrd)
				   lFiltPrd  := .T.
				   cProduto  := SD1->D1_COD
				ENDIF

				IF EMPTY(cProduto) 
					cProduto := SD1->D1_COD
				ELSEIF !lFiltPrd 
					cProduto := "DIVERSOS"
				ENDIF
	
				cHist := ""
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
	               	IF !(TRIM(SD1->D1_PEDIDO) $ cHist2 ) 
	               		cHist2 += " Pedido de Compra n°: "+TRIM(SD1->D1_PEDIDO)
	               	ENDIF
	   			ENDIF
	       			
				nTot:= 0
				nTot:= aScan(aTot,{|x| x[1]==SD1->D1_CC })
	            IF nTot > 0
	               	aTot[nTot,2] += SD1->D1_TOTAL
	            ELSE
					AADD(aTot,{SD1->D1_CC,SD1->D1_TOTAL})
				ENDIF
				IF SE2->E2_TIPO $ "TX #ISS#TXA#INS"
					cHist2 := SE2->E2_NATUREZ+" Ref. NF ENTRADA nº:"+SD1->D1_DOC+" série:"+SD1->D1_SERIE+" Fornecedor:"+SD1->D1_FORNECE+" Loja:"+SD1->D1_LOJA
				ENDIF
				IF !(cHist2 $ cTHist  )
					cTHist += cHist2
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
			SD2->(dbSetOrder(3))               //filial,doc,serie,cliente,loja,cod
			SD2->(dbSeek(xFilial("SD2")+cChave,.T.))
			DO WHILE SD2->(!EOF()) .and. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE == ;
				xFilial("SD2")+cChave
				nTot:= 0
				nTot:= aScan(aTot,{|x| x[1]==SD2->D2_CCUSTO })
                IF nTot > 0
                	aTot[nTot,2] += SD2->D2_TOTAL
                ELSE
					AADD(aTot,{SD2->D2_CCUSTO,SD2->D2_TOTAL})
				ENDIF
				cTHist := ""
           		cTHist := SE2->E2_NATUREZ+" Ref. NF SAIDA nº:"+SD2->D2_DOC+" série:"+SD2->D2_SERIE+" Cliente:"+SD2->D2_CLIENTE+" Loja:"+SD2->D2_SERIE

				// Se algum produto satisfazer o filtro, considerá-lo
				IF !EMPTY(cFiltPrd) .AND. TRIM(SD2->D2_COD) == TRIM(cFiltPrd)
				   lFiltPrd  := .T.
				   cProduto  := SD2->D2_COD
				ENDIF

				IF EMPTY(cProduto) 
					cProduto := SD2->D2_COD
				ELSEIF !lFiltPrd 
					cProduto := "DIVERSOS"
				ENDIF
           		
				SD2->(dbSkip())
			ENDDO
	    ENDIF
		
	    IF LEN(aTot) == 0  .AND. (ALLTRIM(SE2->E2_TIPO) == "DP"  .OR. (ALLTRIM(SE2->E2_TIPO) == "PA" .AND. ALLTRIM(SE2-> E2_PREFIXO) $ "LF/DV/CX"))
			nFin   := 2
			cQuery := ""
			cQuery += "SELECT Z2_E2NUM,Z2_E2PRF,Z2_CC,SUM(Z2_VALOR) AS Z2_VALOR"
			cQuery += " FROM "+RETSQLNAME("SZ2")+" SZ2 "
			cQuery += " WHERE SZ2.D_E_L_E_T_='' AND Z2_CODEMP = '"+SM0->M0_CODIGO+"' AND Z2_E2NUM='"+SE2->E2_NUM+"'"
			cQuery += " AND Z2_E2PRF='"+SE2->E2_PREFIXO+"' AND Z2_E2PARC='"+SE2->E2_PARCELA+"' AND Z2_STATUS='S'"
			cQuery += " AND Z2_E2TIPO='"+SE2->E2_TIPO+"'AND Z2_E2FORN='"+SE2->E2_FORNECE+"' AND Z2_E2LOJA='"+SE2->E2_LOJA+"'" 
			cQuery += " GROUP BY  Z2_E2NUM,Z2_E2PRF,Z2_CC "				

			TCQUERY cQuery NEW ALIAS "QSZ2"
  
			
			DbSelectArea("QSZ2")
			QSZ2->(DbGoTop())

			aTot := {}
			nTot := 0
			cTHist := ""

			Do While QSZ2->(!eof())   
			
				aLIB:= {}
				IF nUsuario == 1
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
			aTIT := {}
			aTIT := aTot          
			aTot := U_Rateia(aTot,nPagar)
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
				(cAliasTmp4)->RECEBIDOS  += 0
				(cAliasTmp4)->PAGOS      += aTot[IX,2]
				msUnlock()
  

				IF TRIM(cCC) <> "000000001"
                   	cDESCFIN := "" 
                   	cDESCFIN := ALLTRIM(aSitFin[1]) //Total Clientes
                ELSE
					IF SE2->E2_TIPO $ "TX #ISS#TXA#INS"
                   		nFin := 8
                   	ENDIF
                
                   	cDESCFIN := "" 
                   	cDESCFIN := ALLTRIM(aSitFin[nFin]) //Descrição Financeiro
                ENDIF
 
				dbSelectArea(cAliasTmp5)
				IF !dbSeek(cDESCFIN)
					RecLock( cAliasTmp5, .T. )
					(cAliasTmp5)->DESCFIN := cDESCFIN
				ELSE 
					RecLock( cAliasTmp5, .F. )
				ENDIF
				(cAliasTmp5)->RECEBIDOS  += 0
				(cAliasTmp5)->PAGOS      += aTot[IX,2]
				msUnlock()
				
				// Gravar analitico
				RecLock( cAliasTmp3, .T. )
				//(cAliasTmp3)->XX_DATA    := SE2->E2_VENCREA
			    //(cAliasTmp3)->XXCTFIN    := cCtaFin
				//(cAliasTmp3)->DESCRCT    := cDescrCt
				(cAliasTmp3)->XXCC   	 := cCC
				(cAliasTmp3)->DESCRCC    := cDescrCC
				//(cAliasTmp3)->XX_TIPO    := SE2->E2_TIPO
				(cAliasTmp3)->B1_COD     := cProduto
				IF !EMPTY(cProduto)
					(cAliasTmp3)->B1_DESC := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
				ENDIF
				//(cAliasTmp3)->DESCFIN 	 := cDESCFIN				
				(cAliasTmp3)->XX_VENCREA := SE2->E2_VENCREA
				(cAliasTmp3)->XX_HIST    := IIF(SE2->E2_SALDO  <> 0 .AND. SE2->E2_SALDO <> SE2->E2_VALOR,'Titulo com Baixa Parcial - ','')+IIF(!EMPTY(cTHist),STRTRAN(cTHist,';',','),SE2->E2_HIST)
				(cAliasTmp3)->XX_NOME    := SE2->E2_NOMFOR
				//(cAliasTmp3)->XX_PREFIXO := SE2->E2_PREFIXO
				(cAliasTmp3)->XX_TITULO  := SE2->E2_NUM
				//(cAliasTmp3)->XX_PARCELA := SE2->E2_PARCELA
				//(cAliasTmp3)->XX_CLIFOR  := SE2->E2_FORNECE
				//(cAliasTmp3)->XX_LOJA    := SE2->E2_LOJA
				(cAliasTmp3)->XX_VALOR   := IIF(nVALBRUT>0,nVALBRUT,aTIT[IX,2]) //SE2->E2_VALOR
				(cAliasTmp3)->RECEBER    := 0
				(cAliasTmp3)->PAGAR      := aTot[IX,2]
				IF nUsuario == 1
					(cAliasTmp3)->DIGITADO   := Capital(cDigitado)
					(cAliasTmp3)->LIBERADO   := Capital(cLiberado)
				ENDIF
				msUnlock()

			NEXT
		ELSE
			nFin := 3

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
			(cAliasTmp4)->RECEBIDOS  += 0
			(cAliasTmp4)->PAGOS      += nPagar
			msUnlock()

			IF TRIM(cCC) <> "000000001"
              	cDESCFIN := "" 
                cDESCFIN := ALLTRIM(aSitFin[1]) //Total Clientes
   			ELSE
            	cDESCFIN := "" 
                cDESCFIN := ALLTRIM(aSitFin[nFin]) //Decr. Financ
      		ENDIF
 
			dbSelectArea(cAliasTmp5)
			IF !dbSeek(cDESCFIN)
				RecLock( cAliasTmp5, .T. )
				(cAliasTmp5)->DESCFIN := cDESCFIN
			ELSE 
				RecLock( cAliasTmp5, .F. )
			ENDIF
			(cAliasTmp5)->RECEBIDOS  += 0
			(cAliasTmp5)->PAGOS      += nPagar
			msUnlock()
		    

			// Gravar analitico
			RecLock( cAliasTmp3, .T. )
			//(cAliasTmp3)->XX_DATA    := SE2->E2_VENCREA
			//(cAliasTmp3)->XXCTFIN    := cCtaFin
			//(cAliasTmp3)->DESCRCT    := cDescrCt
			(cAliasTmp3)->XXCC   	 := cCC
			(cAliasTmp3)->DESCRCC    := cDescrCC
			//(cAliasTmp3)->XX_TIPO    := SE2->E2_TIPO
			(cAliasTmp3)->B1_COD     := cProduto
			IF !EMPTY(cProduto)
				(cAliasTmp3)->B1_DESC := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
			ENDIF
			//(cAliasTmp3)->DESCFIN 	 := cDESCFIN
			(cAliasTmp3)->XX_VENCREA := SE2->E2_VENCREA
			(cAliasTmp3)->XX_HIST    := IIF(SE2->E2_SALDO  <> 0 .AND. SE2->E2_SALDO <> SE2->E2_VALOR,'Titulo com Baixa Parcial - ','')+SE2->E2_HIST
			(cAliasTmp3)->XX_NOME    := SE2->E2_NOMFOR
			//(cAliasTmp3)->XX_PREFIXO := SE2->E2_PREFIXO
			(cAliasTmp3)->XX_TITULO  := SE2->E2_NUM
			//(cAliasTmp3)->XX_PARCELA := SE2->E2_PARCELA
			//(cAliasTmp3)->XX_CLIFOR  := SE2->E2_FORNECE
			//(cAliasTmp3)->XX_LOJA    := SE2->E2_LOJA
			(cAliasTmp3)->XX_VALOR   := SE2->E2_VALOR
			(cAliasTmp3)->RECEBER    := 0
			(cAliasTmp3)->PAGAR      := nPagar
			IF nUsuario == 1
				(cAliasTmp3)->DIGITADO   := Capital(cDigitado)
				(cAliasTmp3)->LIBERADO   := Capital(cLiberado)
			ENDIF
			msUnlock()

		ENDIF
  
	
		SE2->(dbSkip())
	Enddo
    // Contas a Pagar
    
    // Contas a Receber
	dbSelectArea("SE1")
	dbSetOrder(7)
	dbseek(xFilial("SE1")+DTOS(dDataVenc),.T.)
	ProcRegua(LastRec()) // Numero de registros a processar
	While !Eof() .And. SE1->E1_VENCREA == dDataVenc
		IncProc()
//		IF mv_par03 == 1 .and. SE1->E1_FILIAL != cFilial
//			Exit
//		EndIF
 		If SE1->E1_TIPO $ MVRECANT
			dbSkip()
			Loop                                          
		Endif
	
	
		If SE1->E1_FLUXO == "N" //.or. SE1->E1_EMISSAO > dDatabase //.and. mv_par14 == 2)
			dbSkip()
			Loop
		EndIf
		
		///IF (SE1->E1_SALDO = 0 .and. IIF( MVX_par11 == 1, SE1->E1_BAIXA <= dDataBase, .T. )  ) .or. SE1->E1_SITUACA $ "27"    
		//	dbSkip()
		//	Loop
		//EndIF

		cProduto  := ""
		lFiltPrd  := .F.
	
		If MVX_par11 == 1
			nReceber := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZA,"R",SE1->E1_CLIENTE,MVX_par02,SE1->E1_VENCREA,dDataBase,SE1->E1_LOJA,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0), MVX_par17)
		Else
			// Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
			lTxMoeda := SM2->(MsSeek(SE1->E1_VENCREA)) .And. SM2->&("M2_MOEDA"+Alltrim(Str(MVX_par02))) != 0
			nReceber  := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),SE1->E1_MOEDA,MVX_par02,,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0))
		End

		// TITULO TIPO ABATIMENTO
		IF SE1->E1_TIPO $ MVABATIM+"/"+MV_CRNEG
			nReceber  := nReceber * -1
		Endif


		nAbatim := 0
        cHist := ""
		dbSelectArea ("SF2")           //cabecalho de N.F.
		dbSetOrder (1)                 //filial,documento,serie,cliente,loja
		IF dbSeek (xFilial("SF2")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA, .F.)  // Encontra a nota informada no parametro "De", ou a proxima caso exista.
			IF SE2->E2_VALOR == SE2->E2_SALDO
				nAbatim := IIF(SF2->F2_RECISS = '1',SE1->E1_ISS,0)+SE1->E1_IRRF+SE1->E1_INSS+SE1->E1_PIS+SE1->E1_COFINS+SE1->E1_CSLL
            ELSE
				nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",MVX_par02,,SE1->E1_CLIENTE,SE1->E1_LOJA)
            ENDIF
        ELSE
			nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",MVX_par02,,SE1->E1_CLIENTE,SE1->E1_LOJA)
        ENDIF

        IF nAbatim  <> 0
        	//nReceber  := nAbatim * -1
        	nReceber  -= nAbatim 
        ENDIF
            
        // Desconsiderar compensações
        IF (INT(nReceber * 100) / 100) == 0
           dbSelectArea("SE1")
		   dbSkip()
		   Loop
		ENDIF


        // Desconsiderar Titulos de provisoes e  ABATIMENTO - BK

       IF SE1->E1_PREFIXO == "CTR" .or. SE1->E1_TIPO $ MVABATIM+"/"+MV_CRNEG
           dbSelectArea("SE1")
		   SE1->(dbSkip())
		   Loop
		ENDIF

        // DESCONSIDERA TITULOS BAIXADOS NO PERIODO      
        IF SE1->E1_SALDO  == 0
        	IF SE1->E1_BAIXA >= MV_PAR01  .AND. SE1->E1_BAIXA <= MV_PAR02
        		SE1->(dbSkip())
				Loop
			ENDIF
        ENDIF


		//IF EMPTY(cCtaFin)
	   		cCtaFin := SE1->E1_NATUREZ //SE1->E1_XXCTFIN
		//ENDIF	
		
		// Gravar sintetico
		
//		IF CTH->(dbSeek(xFilial("CTH")+cCtaFin,.F.))
//			cDescrCt := CTH->CTH_DESC01
		//ELSE
		//	cDescrCt := 
		IF SED->(dbSeek(xFilial("SED")+cCtaFin,.F.))
			cDescrCt := SED->ED_DESCRIC
		ENDIF   

		dbSelectArea(cAliasTmp2)
		IF !dbSeek(cCtaFin+DTOS(SE1->E1_VENCREA))
			RecLock( cAliasTmp2, .T. )
			(cAliasTmp2)->XXDATA   := SE1->E1_VENCREA
			(cAliasTmp2)->CTFIN    := cCtaFin
		ELSE 
			RecLock( cAliasTmp2, .F. )
		ENDIF
		(cAliasTmp2)->DESCRCT    := cDescrCt
		(cAliasTmp2)->RECEBER    += nReceber
		(cAliasTmp2)->PAGAR      += 0
		msUnlock()
		
		aTot := {}
		nTot := 0
		aHist:= {}
		nHist:= 0
		cTHist:= ""
		cProduto := ""
		lFiltPrd := .F.

		dbSelectArea ("SD2")   
		SD2->(dbSetOrder(3))               //filial,doc,serie,cliente,loja,cod
		SD2->(dbSeek(xFilial("SD2")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.))
		DO WHILE SD2->(!EOF()) .and. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == ;
			xFilial("SD2")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA
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
            nFin := 3

			// Se algum produto satisfazer o filtro, considerá-lo
			IF !EMPTY(cFiltPrd) .AND. TRIM(SD2->D2_COD) == TRIM(cFiltPrd)
			   lFiltPrd  := .T.
			   cProduto  := SD2->D2_COD
			ENDIF

			IF EMPTY(cProduto) 
				cProduto := SD2->D2_COD
			ELSEIF !lFiltPrd 
				cProduto := "DIVERSOS"
			ENDIF

			SD2->(dbSkip())
		ENDDO
			
		IF LEN(aTot)> 0           
		
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
				(cAliasTmp4)->PAGOS      += 0
				msUnlock()

				IF TRIM(cCC) <> "000000001"
              		cDESCFIN := "" 
                	cDESCFIN := ALLTRIM(aSitFin[1]) //Total Clientes
   				ELSE
            		cDESCFIN := "" 
                	cDESCFIN := ALLTRIM(aSitFin[nFin]) //Descrição Finceiro
      			ENDIF
 
				dbSelectArea(cAliasTmp5)
				IF !dbSeek(cDESCFIN)
					RecLock( cAliasTmp5, .T. )
					(cAliasTmp5)->DESCFIN := cDESCFIN
				ELSE 
					RecLock( cAliasTmp5, .F. )
				ENDIF
				(cAliasTmp5)->RECEBIDOS  += aTot[IX,2]
				(cAliasTmp5)->PAGOS      += 0
				msUnlock() 

				// Gravar analitico
				RecLock( cAliasTmp3, .T. )
				//(cAliasTmp3)->XX_DATA    := SE1->E1_VENCREA
				//(cAliasTmp3)->XXCTFIN    := cCtaFin
				//(cAliasTmp3)->DESCRCT    := cDescrCt
				(cAliasTmp3)->XXCC   	 := cCC
				(cAliasTmp3)->DESCRCC    := cDescrCC
				//(cAliasTmp3)->XX_TIPO    := SE1->E1_TIPO
				(cAliasTmp3)->B1_COD     := cProduto
				IF !EMPTY(cProduto)
					(cAliasTmp3)->B1_DESC := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
				ENDIF
				//(cAliasTmp3)->DESCFIN 	 := cDESCFIN
				(cAliasTmp3)->XX_VENCREA := SE1->E1_VENCREA
				(cAliasTmp3)->XX_HIST    := IIF(SE1->E1_SALDO  <> 0 .AND. SE1->E1_SALDO <> SE1->E1_VALOR,'Titulo com Baixa Parcial - ','')+IIF(!EMPTY(cTHist),STRTRAN(cTHist,';',','),SE1->E1_HIST)
				(cAliasTmp3)->XX_NOME    := SE1->E1_NOMCLI
				//(cAliasTmp3)->XX_PREFIXO := SE1->E1_PREFIXO
				(cAliasTmp3)->XX_TITULO  := SE1->E1_NUM
				//(cAliasTmp3)->XX_PARCELA := SE1->E1_PARCELA
				//(cAliasTmp3)->XX_CLIFOR  := SE1->E1_CLIENTE
				//(cAliasTmp3)->XX_LOJA    := SE1->E1_LOJA
				(cAliasTmp3)->XX_VALOR   := SE1->E1_VALOR
				(cAliasTmp3)->RECEBER    := aTot[IX,2]
				(cAliasTmp3)->PAGAR      := 0
				msUnlock()

			NEXT
		ELSE
            nFin := 3 
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
			(cAliasTmp4)->PAGOS      += 0
			msUnlock()

			IF TRIM(cCC) <> "000000001"
            	cDESCFIN := "" 
                cDESCFIN := ALLTRIM(aSitFin[1]) //Total Clientes
   			ELSE
            	cDESCFIN := "" 
                cDESCFIN := ALLTRIM(aSitFin[nFin]) //Descr Financ
      		ENDIF
 
			dbSelectArea(cAliasTmp5)
			IF !dbSeek(cDESCFIN)
				RecLock( cAliasTmp5, .T. )
				(cAliasTmp5)->DESCFIN := cDESCFIN
			ELSE 
				RecLock( cAliasTmp5, .F. )
			ENDIF
			(cAliasTmp5)->RECEBIDOS  += nReceber
			(cAliasTmp5)->PAGOS      += 0
			msUnlock() 

			// Gravar analitico
			RecLock( cAliasTmp3, .T. )
			//(cAliasTmp3)->XX_DATA    := SE1->E1_VENCREA
			//(cAliasTmp3)->XXCTFIN    := cCtaFin
			//(cAliasTmp3)->DESCRCT    := cDescrCt
			(cAliasTmp3)->XXCC   	 := cCC
			(cAliasTmp3)->DESCRCC    := cDescrCC
			//(cAliasTmp3)->DESCFIN 	 := cDESCFIN
			//(cAliasTmp3)->XX_TIPO    := SE1->E1_TIPO
			(cAliasTmp3)->B1_COD     := cProduto
			IF !EMPTY(cProduto)
				(cAliasTmp3)->B1_DESC := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC")
			ENDIF
			(cAliasTmp3)->XX_VENCREA := SE1->E1_VENCREA
			(cAliasTmp3)->XX_HIST    := IIF(SE1->E1_SALDO  <> 0 .AND. SE1->E1_SALDO <> SE1->E1_VALOR,'Titulo com Baixa Parcial - ','')+SE1->E1_HIST
			(cAliasTmp3)->XX_NOME    := SE1->E1_NOMCLI
			//(cAliasTmp3)->XX_PREFIXO := SE1->E1_PREFIXO
			(cAliasTmp3)->XX_TITULO  := SE1->E1_NUM
			//(cAliasTmp3)->XX_PARCELA := SE1->E1_PARCELA
			//(cAliasTmp3)->XX_CLIFOR  := SE1->E1_CLIENTE
			//(cAliasTmp3)->XX_LOJA    := SE1->E1_LOJA
			(cAliasTmp3)->XX_VALOR   := SE1->E1_VALOR
			(cAliasTmp3)->RECEBER    := nReceber
			(cAliasTmp3)->PAGAR      := 0
			msUnlock()

		ENDIF
		
		dbSelectArea("SE1") // Faltou esta linha, acertado em 22/01/14
		SE1->(dbSkip())
	EndDO
    
    // Contas a Receber

NEXT j
 	


Return NIL



Static Function  ValidPerg(cPerg)

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
AADD(aRegistros,{cPerg,"06","Filtrar produto","Produto"    ,"Produto"       ,"mv_ch6","C",15,0,0,"G",'Vazio() .or. ExistCpo("SB1")',"mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SB1","S","",""})
AADD(aRegistros,{cPerg,"07","Usuário Dig/Liberou:","Usuário Dig/Liberou","Usuário Dig/Liberou" ,"mv_ch7","N",01,0,2,"C","","mv_par07","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","S","",""})

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

