#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BKFINR06 ³ Autor ³ Marcos b. Abrahão     ³ Data ³05.01.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao de Titulo a Pagar                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Especifico BK                                               ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BKFINR06()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aArea     := GetArea()

PRIVATE nParImpr:= 1
PRIVATE dParVenc:= DATE()
PRIVATE nParPlan:= 1
PRIVATE nImpPCT := 1
PRIVATE nImpNDF := 1
PRIVATE nImpSel := 1
PRIVATE nParForm:= 1

PRIVATE titulo 	:= ""
PRIVATE wnrel   := FunName()            //Nome Default do relatorio em Disco
PRIVATE cTitulo := "Impressão de Titulo a Pagar"
Private cPerg   := "BKFINR06"

Private nLin    := 1650 // Linha de inicio da impressao
PRIVATE oPrn    := NIL
PRIVATE oFont1  := NIL
PRIVATE oFont2  := NIL
PRIVATE oFont3  := NIL
PRIVATE oFont4  := NIL
PRIVATE oFont5  := NIL
PRIVATE oFont6  := NIL
PRIVATE oFont8  := NIL
PRIVATE lLands  := .T.
PRIVATE cDescCC := ""
PRIVATE aFurnas  := {} 

aFurnas  := U_StringToArray(ALLTRIM(SuperGetMV("MV_XXFURNAS",.F.,"105000381/105000391")), "/" )


DEFINE FONT oFont1 NAME "Times New Roman" SIZE 0,20 BOLD  OF oPrn
DEFINE FONT oFont2 NAME "Times New Roman" SIZE 0,14 BOLD OF oPrn
DEFINE FONT oFont3 NAME "Times New Roman" SIZE 0,14 OF oPrn
DEFINE FONT oFont4 NAME "Times New Roman" SIZE 0,14 ITALIC OF oPrn
DEFINE FONT oFont5 NAME "Times New Roman" SIZE 0,14 OF oPrn
DEFINE FONT oFont6 NAME "Courier New" BOLD

oFont06	 := TFont():New("Courier New",06,06,,.F.,,,,.T.,.F.)
oFont06N := TFont():New("Courier New",06,06,,.T.,,,,.T.,.F.)
oFont07	 := TFont():New("Courier New",07,07,,.F.,,,,.T.,.F.)
oFont07N := TFont():New("Courier New",07,07,,.T.,,,,.T.,.F.)

oFont08	 := TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
oFont08N := TFont():New("Courier New",08,08,,.T.,,,,.T.,.F.)
oFont10	 := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
oFont11  := TFont():New("Courier New",11,11,,.F.,,,,.T.,.F.)
oFont14	 := TFont():New("Courier New",14,14,,.F.,,,,.T.,.F.)
oFont16	 := TFont():New("Courier New",16,16,,.F.,,,,.T.,.F.)
oFont10N := TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)
oFont12  := TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
oFont12N := TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)
oFont13N := TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)
oFont14N := TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)
oFont16N := TFont():New("Courier New",16,16,,.T.,,,,.T.,.F.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio do lay-out / impressao                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

ValidPerg(cPerg)
	
IF Pergunte(cPerg,.T.)

	nParImpr := mv_par01
	dParVenc := mv_par02
	nParPlan := mv_par03
	nImpPCT  := mv_par04
	nImpNDF  := mv_par05
    nImpSel  := mv_par06
    
	IF nParPlan = 2 // Relatorio 
		IF nParImpr = 1  // Unico titulo
			oPrn := TMSPrinter():New(cTitulo)
			IF lLands
			   oPrn:SetLandscape()
			ELSE   
			   oPrn:SetPortrait()
			ENDIF
			oPrn:Setup()
			RptStatus({|lEnd| ImprE2()},"Imprimindo Título a pagar...")
			oPrn:End()
			oPrn:Preview()//Visualiza antes de imprimir

		ELSE // Por data de venc real
			oPrn := TMSPrinter():New(cTitulo)
			IF lLands
			   oPrn:SetLandscape()
			ELSE   
			   oPrn:SetPortrait()
			ENDIF
			oPrn:Setup()
			RptStatus({|lEnd| ImprE2V()},"Imprimindo Títulos a pagar...")
			oPrn:End()
			oPrn:Preview()   //Visualiza antes de imprimir
		ENDIF
	ELSE
		IF nParImpr = 1  // Unico titulo
		    IF !EMPTY(SE2->E2_XXCTRID)
				ProcRegua(1)
				Processa( {|| ProcQuery() })
				DBSELECTAREA("QSZ2")
				DBGOTOP()
				
				aCabs   := {}
				aCampos := {}
				aTitulos:= {}
   
				AADD(aTitulos,titulo)

			    cParcela := IIF(!EMPTY(SE2->E2_PARCELA),"-"+SE2->E2_PARCELA,"")
			    // Tratamento para visualização de Acrescimo ou Decrescimo na impressão do Titulo
				nSaldo := 0
				IF TRANSFORM(SE2->E2_SALDO,"@e 999,999,999.99") == TRANSFORM(SE2->E2_VALOR,"@e 999,999,999.99")
					nSaldo := SE2->E2_VALOR + (SE2->E2_ACRESC - SE2->E2_DECRESC)
				ELSE
					nSaldo := SE2->E2_SALDO
    			ENDIF 

				AADD(aTitulos,"Titulo: "+TRIM(SE2->E2_PREFIXO)+" "+TRIM(SE2->E2_NUM)+cParcela+" - Venc.: "+DTOC(SE2->E2_VENCREA)+" - Saldo: R$ "+ALLTRIM(TRANSFORM(nSaldo,"@e 999,999,999.99")))

				dbSelectArea("SA2")
				dbSetOrder(1)
				dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
				AADD(aTitulos,"Fornecedor: " +SA2->A2_COD+"-"+SA2->A2_LOJA+" - "+SA2->A2_NOME)
    
				DBSELECTAREA("QSZ2")
                DBGOTOP()
                
				AADD(aCampos,"QSZ2->Z2_NOME")
				AADD(aCabs  ,"Nome")

				AADD(aCampos,"QSZ2->Z2_BANCO")
				AADD(aCabs  ,"Banco")
				
				IF TRIM(QSZ2->Z2_TIPO) <> "MFG" // Não sair agencia e conta para tipobk = MFG
					AADD(aCampos,"TRIM(QSZ2->Z2_AGENCIA)+'-'+TRIM(QSZ2->Z2_DIGAGEN)")
					AADD(aCabs  ,"Agencia")
	
					AADD(aCampos,"TRIM(QSZ2->Z2_CONTA)+'-'+TRIM(QSZ2->Z2_DIGCONTA)")
					AADD(aCabs  ,"Conta")
	            ENDIF
	            
				AADD(aCampos,"QSZ2->Z2_TIPO")
				AADD(aCabs  ,"Tipo")

				AADD(aCampos,"QSZ2->Z2_TIPOPES")
				AADD(aCabs  ,"Tipo Pessoa")

				AADD(aCampos,"Capital(U_BUSERRUBI(QSZ2->Z2_TIPO,QSZ2->Z2_PRONT,QSZ2->Z2_DATAPGT,QSZ2->Z2_USUARIO))")
				AADD(aCabs  ,"Usuario")

				AADD(aCampos,"QSZ2->Z2_VALOR")
				AADD(aCabs  ,"Valor")

				AADD(aCampos,"QSZ2->Z2_OBSTITU")
				AADD(aCabs  ,"Observações")

				ProcRegua(QSZ2->(LASTREC()))
				Processa( {|| U_GeraCSV("QSZ2",cPerg,aTitulos,aCampos,aCabs)})
   
		    ELSE
				MsgStop("Opção disponivel apenas para titulos gerados pelo Depto Pessoal (Liquidos "+ALLTRIM(SM0->M0_NOME)+")")
		    ENDIF
		ELSE
			MsgStop("Opção não disponivel, escolha titulo unico")
		ENDIF
		
	ENDIF	
ENDIF	
RestArea(aArea)
Return(.T.)



STATIC FUNCTION ImprE2V()
dbSelectArea("SE2")
dbsetorder(3)  // VENCREA
dbseek(xFilial("SE2")+DTOS(dParVenc),.T.)
SetRegua(100)
DO WHILE !SE2->(EOF()) .AND. SE2->E2_FILIAL == xFilial("SE2") .AND. SE2->E2_VENCREA = dParVenc 

	IncRegua()
	
	dbselectarea("SE2")
	IF nImpPCT = 2 .AND. TRIM(SE2->E2_XXTIPBK) = "PCT"
		SE2->(dbSkip())
		LOOP
	ENDIF
	
	IF nImpNDF = 2 .AND. TRIM(SE2->E2_TIPO) = "NDF"
		SE2->(dbSkip())
		LOOP
	ENDIF

	IF nImpSel = 2 .AND. SE2->E2_XXPRINT <> "S" // Somente os já impressos
		SE2->(dbSkip())
		LOOP
	ENDIF

	IF nImpSel = 3 .AND. SE2->E2_XXPRINT == "S" // Somente os não impressos
		SE2->(dbSkip())
		LOOP
	ENDIF

    ImprE2()
    
	IF nImpSel = 3 .AND. SE2->E2_XXPRINT <> "S" // Marcar como impresso
		RecLock("SE2",.F.)
        SE2->E2_XXPRINT := "S"
		MsUnlock()
	ENDIF
	
	IF nImpSel = 4  // Desmarcar os impressos
		RecLock("SE2",.F.)
        SE2->E2_XXPRINT := "N"
		MsUnlock()
	ENDIF
    
	SE2->(dbSkip())
ENDDO
RETURN NIL



STATIC FUNCTION ImprE2()
Local nPos
Local cTipoPes   := ""
Local aCC,aPrd,aValCC,nI
Local cFilD1,cFilF1,cUser
Local cDigUser   := ""
Local cLibUser   := ""
Local aLib       := {}
Local xO
Local nMaxLin    := 0
Local nMaxObs    := 0
Local cDtHoraLib := ""
Local cDadosBanc := ""
Local cxTipoPg   := ""
Local cxNumPa    := ""
Local cFormaPgto := ""
Local nIniBox    := 0
Local cLinObs    := ""

nMaxLin := Iif(lLands,2300,3100)
nMaxObs := Iif(lLands,120,090)

nLin := 1650 // Linha de inicio da impressao
cDia := SubStr(DtoS(dDataBase),7,2)
cMes := SubStr(DtoS(dDataBase),5,2)
cAno := SubStr(DtoS(dDataBase),1,4)
cMesExt := MesExtenso(Month(dDataBase))
cDataImpressao := cDia+" de "+cMesExt+" de "+cAno

oPrn:StartPage()
cBitMap := FisxLogo("1")
oPrn:SayBitmap(0030,0050,cBitMap,300,150)			// Imprime logo da Empresa: comprimento X altura

oPrn:Say(0030,0400,SM0->M0_NOMECOM,oFont14N)


dbSelectArea("SE2")

Begin Sequence
	
	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)
	cDadosBanc := ""
	//If !Empty(SA2->A2_BANCO) .AND. SA2->A2_COD <> "000084"
    //   cDadosBanc := "Bco: "+ALLTRIM(SA2->A2_BANCO)+" Ag: "+ALLTRIM(SA2->A2_AGENCIA)+" C/C: "+ALLTRIM(SA2->A2_NUMCON)
 	//EndIf
 	
    dbSelectArea("SF1")                   // * Cabeçalho da N.F. de Compra
    dbSetOrder(1)
    cFilF1     := xFilial("SF1")
    cUser      := ""
    cDigUser   := ""
    cFormaPgto := ""
    
    IF dbSeek(cFilF1+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA+"N")
       cUser := SF1->F1_XXUSER
	   PswOrder(1) 
	   PswSeek(cUser) 
	   aUser  := PswRet(1)
	   IF !EMPTY(aUser)
          cDigUser := aUser[1,2]
       ENDIF
       cDtHoraLib := FWLeUserlg("F1_USERLGA", 2)+TRIM(" "+SF1->F1_HORA)
		cxTipoPg := SF1->F1_XTIPOPG
		cxNumPa  := SF1->F1_XNUMPA
		If !Empty(cxTipoPg)
			cFormaPgto := TRIM(cxTipoPg)
			If TRIM(cxTipoPg) == "DEPOSITO" //.AND. SF1->F1_FORNECE <> "000084"
				If Empty(SF1->F1_XBANCO) .AND. SF1->F1_FORNECE <> "000084"
			 		cDadosBanc := "Bco: "+ALLTRIM(SA2->A2_BANCO)+" Ag: "+ALLTRIM(SA2->A2_AGENCIA)+" C/C: "+ALLTRIM(SA2->A2_NUMCON)
                Else
					cDadosBanc := "Bco: "+ALLTRIM(SF1->F1_XBANCO)+" Ag: "+ALLTRIM(SF1->F1_XAGENC)+" C/C: "+ALLTRIM(SF1->F1_XNUMCON)
			 	EndIf
				cFormaPgto += ": "+cDadosBanc
			ElseIf TRIM(cxTipoPg) == "P.A."
				cFormaPgto += " "+cxNumPa
			EndIf
		EndIf
    ENDIF
    IF EMPTY(cDigUser) .AND. !EMPTY(SE2->E2_USERLGI)
    	//cDigUser := USRFULLNAME(SUBSTR(EMBARALHA(SE2->E2_USERLGI,1),3,6))
    	cDigUser := USRRETNAME(SUBSTR(EMBARALHA(SE2->E2_USERLGI,1),3,6))
    ENDIF   
    cLibUser := SE2->E2_USUALIB
    
    dbSelectArea("SD1")                   // * Itens da N.F. de Compra
    dbSetOrder(1)
    cFilD1 := xFilial("SD1")
    cHist  := "" 
	aCC    := {}
	aValCC := {}
	aPrd   := {}
	aLib   := {} 
	
    IF SM0->M0_CODIGO == '12'
		oPrn:Say(0180,0050,"CORRETORA",oFont16N)
	ENDIF

    IF ALLTRIM(SE2->E2_PREFIXO) $ "LF/DV/CX"
    	DbSelectArea("SZ2")
		DbSetOrder(3)
		dbSeek(xFilial("SZ2")+SM0->M0_CODIGO+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO,.T.)
		IF ALLTRIM(SZ2->Z2_CC) == aFurnas[1]
			oPrn:Say(0180,0050,"FURNAS",oFont14N)
        ENDIF
		IF ALLTRIM(SZ2->Z2_CC) == aFurnas[2]
			oPrn:Say(0180,0050,"FURNAS LOTE BK",oFont14N)
        ENDIF
		aLib := U_BLibera("LFRH",SE2->E2_NUM) // Localiza liberação Alcada
  		cDigUser := aLib[1]
		cLibUser := aLib[2]
    ENDIF

    dbSelectArea("SD1")                   // * Itens da N.F. de Compra
    IF dbSeek(cFilD1+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA)

		IF ALLTRIM(SD1->D1_CC) == aFurnas[1]
			oPrn:Say(0180,0050,"FURNAS",oFont14N)
        ENDIF
		IF ALLTRIM(SD1->D1_CC) == aFurnas[2]
			oPrn:Say(0180,0050,"FURNAS LOTE BK",oFont14N)
        ENDIF

       aLib := U_BLibera(SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA,SD1->D1_PEDIDO) // Localiza liberação Alcada
       IF LEN(aLib) > 0
    	  cDigUser := aLib[1]
	   	  cLibUser := aLib[2]
       ENDIF
       DO WHILE !EOF() .AND. cFilD1+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA == ;
                          SD1->D1_FILIAL+SD1->D1_DOC+ SD1->D1_SERIE+ SD1->D1_FORNECE+ SD1->D1_LOJA
          IF !ALLTRIM(SD1->D1_XXHIST) $ cHist                   
			cHist += ALLTRIM(SD1->D1_XXHIST)+" "  //IIF(ALLTRIM(SD1->D1_XXHIST) $ cHist,"",cHist+" ") 
          ENDIF
          AADD(aPrd,SD1->D1_COD)
          AADD(aCC,SD1->D1_CC)
          // 16/03/17 - Total - Desconto + Despesa:  Marcos
          AADD(aValCC,SD1->D1_TOTAL - SD1->D1_VALDESC + SD1->D1_DESPESA)
          SD1->(dbSkip())
       ENDDO
    ENDIF
	cHist := TRIM(cHist)
    nLinHis := MLCOUNT(cHist,nMaxObs)
    
    If !EMPTY(SE2->E2_XXCTRID)
	   Processa( {|| ProcQuery() })
       DBSELECTAREA("QSZ2")
       DBGOTOP()
       cTipoPes := " / "+QSZ2->Z2_TIPOPES
    Endif

    // Inicio da Impressao
    
	dataHora:=DTOC(Date())+"-"+Time()
	IF lLands
	   oPrn:Say(0030,2630,dataHora,oFont14N)
	ELSE
	   oPrn:Say(0030,1890,dataHora,oFont14N)
	ENDIF   

    cParcela := IIF(!EMPTY(SE2->E2_PARCELA),"-"+SE2->E2_PARCELA,"")
    
	// Tratamento para visualização de Acrescimo ou Decrescimo na impressão do Titulo
	nSaldo := 0
	IF TRANSFORM(SE2->E2_SALDO,"@e 999,999,999.99") == TRANSFORM(SE2->E2_VALOR,"@e 999,999,999.99")
		nSaldo := SE2->E2_VALOR + (SE2->E2_ACRESC - SE2->E2_DECRESC)
	ELSE
		nSaldo := SE2->E2_SALDO
    ENDIF 

    nLin    := 300
    nIniBox := 280
    
	IF lLands
		oPrn:Say(0180,0900, "Titulo: "+TRIM(SE2->E2_PREFIXO)+" "+TRIM(SE2->E2_NUM)+cParcela+" - Vencimento: "+DTOC(SE2->E2_VENCREA)+" - Saldo: R$ "+ALLTRIM(TRANSFORM(nSaldo,"@e 999,999,999.99")),oFont14N)
//		If !Empty(cFormaPgto)
//			oPrn:Say(0250,1300,cFormaPgto,oFont14N)
//			nLin    += 60
//			nIniBox += 60
//		EndIf
	ELSE
		oPrn:Say(0180,500, "Titulo: "+TRIM(SE2->E2_PREFIXO)+" "+TRIM(SE2->E2_NUM)+cParcela+" - Venc.: "+DTOC(SE2->E2_VENCREA)+" - Saldo: R$ "+ALLTRIM(TRANSFORM(nSaldo,"@e 999,999,999.99")),oFont14N)
//		If !Empty(cFormaPgto)
//			oPrn:Say(0250,1100,cFormaPgto,oFont14N)
//			nLin += 60
//			nIniBox += 60
//		EndIf
	ENDIF

//    oPrn:Box(nIniBox,0050,0650+(nLinHis*50)+(LEN(aPrd)*50),2350)
    
	oPrn:Say(nLin,0100,"Fornecedor:",oFont12N)
	oPrn:Say(nLin,0400,OemToAnsi(SA2->A2_COD+"-"+SA2->A2_LOJA+" - "+SA2->A2_NOME),oFont12N)

	If lLands
		//oPrn:Say(nLin,2500, "Impostos Retidos:",oFont13N)
	Endif	

    nLin += 50
	oPrn:Say(nLin,0100,"Tipo:",oFont12N)
	oPrn:Say(nLin,0400,OemToAnsi(SE2->E2_TIPO),oFont12N)

	oPrn:Say(nLin,1300,"Vencimento:",oFont12N)
	oPrn:Say(nLin,1700,DTOC(SE2->E2_VENCREA),oFont12N)
	
	If lLands
		oPrn:Say(nLin,2400,"Inss:",oFont12N)
		oPrn:Say(nLin,2800,TRANSFORM(SE2->E2_VRETINS,"@ze 999,999,999.99"),oFont12N)
	Endif	
	
    nLin += 50
	oPrn:Say(nLin,0100,"Natureza:",oFont12N)
	oPrn:Say(nLin,0400,OemToAnsi(SE2->E2_NATUREZ),oFont12N)

	oPrn:Say(nLin,1300,"Emissao:",oFont12N)
	oPrn:Say(nLin,1700,DTOC(SE2->E2_EMISSAO),oFont12N)

	If lLands
		oPrn:Say(nLin,2400,"Irrf:",oFont12N)
		oPrn:Say(nLin,2800,TRANSFORM(SE2->E2_VRETIRF,"@ze 999,999,999.99"),oFont12N)
	Endif	

    nLin += 50
	oPrn:Say(nLin,0100,"Histórico:",oFont12N)
	oPrn:Say(nLin,0400,OemToAnsi(SE2->E2_HIST),oFont12N)
	

	// Tratamento para visualização de Acrescimo ou Decrescimo na impressão do Titulo
	nSaldo := 0
	IF TRANSFORM(SE2->E2_SALDO,"@e 999,999,999.99") == TRANSFORM(SE2->E2_VALOR,"@e 999,999,999.99")
		nSaldo := SE2->E2_VALOR + (SE2->E2_ACRESC - SE2->E2_DECRESC)
	ELSE
		nSaldo := SE2->E2_SALDO
    ENDIF 
	oPrn:Say(nLin,1300,"Saldo:",oFont12N)
	oPrn:Say(nLin,1700,TRANSFORM(nSaldo,"@e 999,999,999.99"),oFont12N)

	If lLands
		oPrn:Say(nLin,2400,"Iss:",oFont12N)
		oPrn:Say(nLin,2800,TRANSFORM(SE2->E2_ISS,"@ze 999,999,999.99"),oFont12N)
	Endif	

	//If SE2->E2_DECRESC > 0 .OR. SE2->E2_ACRESC > 0
	    nLin += 50
		oPrn:Say(nLin,0100,"Decrescimo:",oFont12N)
		oPrn:Say(nLin,0400,"("+ALLTRIM(TRANSFORM(SE2->E2_DECRESC,"@e 999,999,999.99"))+")",oFont12N)
		
		oPrn:Say(nLin,1300,"Acrescimo:",oFont12N)
		oPrn:Say(nLin,1700,TRANSFORM(SE2->E2_ACRESC,"@e 999,999,999.99"),oFont12N)
	//EndIf		

	If lLands
		oPrn:Say(nLin,2400,"Pis:",oFont12N)
		oPrn:Say(nLin,2800,TRANSFORM(SE2->E2_VRETPIS,"@ze 999,999,999.99"),oFont12N)
	Endif	

    nLin += 50
	oPrn:Say(nLin,0100,"Portador:",oFont12N)
	oPrn:Say(nLin,0400,OemToAnsi(SE2->E2_PORTADO),oFont12N)

	oPrn:Say(nLin,1300,"Valor:",oFont12N)
	oPrn:Say(nLin,1700,TRANSFORM(SE2->E2_VALOR,"@e 999,999,999.99"),oFont12N)

	If lLands
		oPrn:Say(nLin,2400,"Cofins:",oFont12N)
		oPrn:Say(nLin,2800,TRANSFORM(SE2->E2_VRETCOF,"@ze 999,999,999.99"),oFont12N)
	Endif	

    nLin += 50
	oPrn:Say(nLin,0100,"Tipo "+ALLTRIM(SM0->M0_NOME)+" / Pes.:  "+OemToAnsi(SE2->E2_XXTIPBK+cTipoPes),oFont12N)
   //	oPrn:Say(nLin,0400,OemToAnsi(SE2->E2_XXTIPBK+cTipoPes),oFont12N)
	
	oPrn:Say(nLin,1300,"Lote "+ALLTRIM(SM0->M0_NOME)+":",oFont12N)
	oPrn:Say(nLin,1700,OemToAnsi(SE2->E2_XXCTRID),oFont12N)

	If lLands
		oPrn:Say(nLin,2400,"Csll:",oFont12N)
		oPrn:Say(nLin,2800,TRANSFORM(SE2->E2_VRETCSL,"@ze 999,999,999.99"),oFont12N)
	Endif	

    nLin += 50
	oPrn:Say(nLin,0100,"Usuário:",oFont12N)
	oPrn:Say(nLin,0400,OemToAnsi(Capital(cDigUser)),oFont12N)

	oPrn:Say(nLin,1300,"Liberado por:",oFont12N)
	oPrn:Say(nLin,1700,OemToAnsi(Capital(cLibUser)+IIF(!EMPTY(cDtHoraLib)," em "+cDtHoraLib,"")),oFont12N)

    nLin += 50
  
  	If !Empty(cFormaPgto)
		oPrn:Say(nLin,1300,"Forma pgto:",oFont12N)
		oPrn:Say(nLin,1700,cFormaPgto,oFont14N)
		nLin    += 50
//		nIniBox += 60
	EndIf

  
    lquebra := .F.
    IF !EMPTY(cHist)
       oPrn:Say(nLin,0100,"Historico NF:",oFont12N)
	   FOR xi := 1 TO nLinHis
	       oPrn:Say(nLin,0400,MemoLine(cHist,nMaxObs,xi),oFont12)
           nLin+=50
			IF nLin > nMaxLin
   				oPrn:Box(IIF(lquebra,0100,nIniBox),0050,nLin,IIf(lLands,3140,2350))
				oPrn:EndPage()
			    nLin := 100
			    nLinFim := nLin 
			    oPrn:StartPage()
    			lquebra := .T.
			 ENDIF
     NEXT    
    ENDIF

    IF LEN(aPrd) > 0
       IF !EMPTY(cHist)
          nLin += 20
       ENDIF   
       oPrn:Say(nLin,0100,"Produtos:",oFont12N)
       cXXPROD := ""
	   FOR xi := 1 TO LEN(aPrd)
			IF !aPrd[xi] $ cXXPROD 
	       		oPrn:Say(nLin,0400,TRIM(aPrd[xi])+" - "+Posicione("SB1",1,xFilial("SB1")+aPrd[xi],"B1_DESC"),oFont12)
           		nLin+=50
			 	cXXPROD += aPrd[xi]+"/"  
				IF nLin > nMaxLin
    				oPrn:Box(IIF(lquebra,0100,nIniBox),0050,nLin,IIf(lLands,3140,2350))
					oPrn:EndPage()
			    	nLin := 100
			    	nLinFim := nLin 
			    	oPrn:StartPage()
    				lquebra := .T.
			 	ENDIF
           ENDIF
       NEXT    
    ENDIF

    oPrn:Box(IIF(lquebra,0100,nIniBox),0050,nLin,IIf(lLands,3140,2350))

	If !lLands .AND. (SE2->E2_VRETINS <> 0 .OR.;  // Era E2_INSSRET  - 25-09-14
	                  SE2->E2_VRETIRF <> 0 .OR.;
	                  SE2->E2_ISS <> 0 .OR.;      // Era E2_VRETISS  - 25-09-14
	                  SE2->E2_VRETPIS <> 0 .OR.;
	                  SE2->E2_VRETCOF <> 0 .OR.;
	                  SE2->E2_VRETCSL <> 0)
	    
	    nLin +=80
		oPrn:Say(nLin,1050, "Impostos Retidos",oFont14N)
		
	    nLin +=100
	    oPrn:Box(nLin,0050,nLin+170,2350)
	    
	    nLin +=20
		oPrn:Say(nLin,0100,"Inss:",oFont12N)
		oPrn:Say(nLin,0400,TRANSFORM(SE2->E2_VRETINS,"@ze 999,999,999.99"),oFont12N)
	
		oPrn:Say(nLin,1300,"Irrf:",oFont12N)
		oPrn:Say(nLin,1700,TRANSFORM(SE2->E2_VRETIRF,"@ze 999,999,999.99"),oFont12N)
		
	    nLin+=50
		oPrn:Say(nLin,0100,"Iss:",oFont12N)
		oPrn:Say(nLin,0400,TRANSFORM(SE2->E2_ISS,"@ze 999,999,999.99"),oFont12N)
	
		oPrn:Say(nLin,1300,"Pis:",oFont12N)
		oPrn:Say(nLin,1700,TRANSFORM(SE2->E2_VRETPIS,"@ze 999,999,999.99"),oFont12N)
	
	    nLin+=50
		oPrn:Say(nLin,0100,"Cofins:",oFont12N)
		oPrn:Say(nLin,0400,TRANSFORM(SE2->E2_VRETCOF,"@ze 999,999,999.99"),oFont12N)
	
		oPrn:Say(nLin,1300,"Csll:",oFont12N)
		oPrn:Say(nLin,1700,TRANSFORM(SE2->E2_VRETCSL,"@ze 999,999,999.99"),oFont12N)

		nLin+=100

    Else

		nLin+=50
    
	EndIf
		

    If !EMPTY(SE2->E2_XXCTRID)
       DBSELECTAREA("QSZ2")
       QSZ2->(DBGOTOP())
       nCont := 0

       Cab(nLin)
       
       nLin += 50
       nTot := 0
       DO WHILE QSZ2->(!EOF())
       
          IF nLin > nMaxLin
             oPrn:EndPage()
             nLin := 100
             Cab(nLin)
             nLin += 50
             oPrn:StartPage()
          ENDIF
          
          nCont++
          nPos := 050

          cLin := QSZ2->Z2_PRONT
          oPrn:Say(nLin,nPos,cLin,oFont07)
          nPos += 110
          
          cLin := QSZ2->Z2_NOME
          oPrn:Say(nLin,nPos,cLin,oFont07)
          nPos += 680

          IF TRIM(QSZ2->Z2_TIPO) <> "MFG" // Não sair agencia e conta para tipobk = MFG
	         cLin := PAD(TRIM(QSZ2->Z2_AGENCIA)+'-'+TRIM(QSZ2->Z2_DIGAGEN),LEN(QSZ2->Z2_AGENCIA)+LEN(QSZ2->Z2_DIGAGEN)+1)
             oPrn:Say(nLin,nPos,cLin,oFont07)
             nPos += 110

	         cLin := PAD(TRIM(QSZ2->Z2_CONTA)+'-'+TRIM(QSZ2->Z2_DIGCONTA),LEN(QSZ2->Z2_CONTA)+LEN(QSZ2->Z2_DIGCONTA)+1)
             oPrn:Say(nLin,nPos,cLin,oFont07)
             nPos += 190
          ELSE
             nPos += 300
          ENDIF

          cDescCC := ALLTRIM(Posicione("CTT",1,xFilial("CTT")+QSZ2->Z2_CC,"CTT_DESC01"))
          IF EMPTY(cDescCC)
          	cDescCC := ALLTRIM(SM0->M0_NOME)+" ("+TRIM(QSZ2->Z2_CC)+")"
          ENDIF   

	      cLin := SUBSTR(cDescCC,1,40)
          oPrn:Say(nLin,nPos,cLin,oFont07)
	      
          nPos += (640)
          
	      //cLin := QSZ2->Z2_TIPO
          //oPrn:Say(nLin,nPos,cLin,oFont07)
          //nPos += 190

	      //cLin := QSZ2->Z2_TIPOPES
          //oPrn:Say(nLin,nPos,cLin,oFont07)
          //nPos += 190

	      cLin  := PAD(Capital(U_BUSERRUBI(QSZ2->Z2_TIPO,QSZ2->Z2_PRONT,QSZ2->Z2_DATAPGT,QSZ2->Z2_USUARIO)),20)
          oPrn:Say(nLin,nPos,cLin,oFont07)
          nPos  += 335
		  cLinObs := ""

		  IF lLands
			  IF TRIM(QSZ2->Z2_TIPO) == "PEN"
				cLinObs += ALLTRIM(IIF(!EMPTY(QSZ2->Z2_NOMMAE),QSZ2->Z2_NOMMAE,QSZ2->Z2_NOMDEP))
			  ENDIF
			  IF !EMPTY(cLinObs) .and. !EMPTY(QSZ2->Z2_OBSTITU)
				cLinObs += " - "
			  ENDIF

			  cLinObs += ALLTRIM(QSZ2->Z2_OBSTITU)
			  
		      IF QSZ2->Z2_DATAPGT <= QSZ2->Z2_DATAEMI
		      		cLinObs += " - Aprovado Integração após Horário"
		      ENDIF
		      nPosObs := nPos
              oPrn:Say(nLin,nPosObs,MemoLine(cLinObs,45,1),oFont07)
              nPos  += 360
              
              cDesVig := ""
	          cDesVig := U_Vig2Contrat(TRIM(QSZ2->Z2_CC),QSZ2->Z2_DATAPGT)
	          
  	          nPosVig := nPos
              oPrn:Say(nLin,nPosVig,cDesVig,oFont07)
              nPos  += 440

              nPos1 := nPos
      	      cLin  := TRANSFORM(QSZ2->Z2_VALOR,"@ze 999,999,999.99")
              oPrn:Say(nLin,nPos,cLin,oFont08)
              nTot  += QSZ2->Z2_VALOR
              nLin  += 40

		      nLinObs := MLCOUNT(cLinObs,45)
			  IF nLinObs > 1
			     FOR xO := 2 TO nLinObs
	                 oPrn:Say(nLin,nPosObs,MemoLine(cLinObs,45,xO),oFont07)
			         nLin+=40
			         IF nLin > nMaxLin
			            oPrn:EndPage()
			            nLin := 100
			            Cab(nLin)
			            nLin += 50
			            nLinFim := nLin 
			            oPrn:StartPage()
			         ENDIF
			     NEXT    
			  ENDIF
          ELSE
             nPos1 := nPos
      	     cLin  := TRANSFORM(QSZ2->Z2_VALOR,"@e 999,999,999.99")
             oPrn:Say(nLin,nPos,cLin,oFont08)
             nTot  += QSZ2->Z2_VALOR
		  ENDIF	  	

          QSZ2->(DBSKIP())
       ENDDO
       IF nTot > 0
          cLin := "Total de "+ALLTRIM(TRANSFORM(nCont,"999999"))+" registros"
          oPrn:Say(nLin,50,cLin,oFont08N)

          cLin := TRANSFORM(nTot,"@e 999,999,999.99")
          oPrn:Say(nLin,nPos1,cLin,oFont08N)
          nLin += 40
       ENDIF
       QSZ2->(Dbclosearea())
    EndIf   
    IF LEN(aCC) > 0
       nCont := 0
       CabCC(nLin)
       
       nLin  += 50
       nTot  := 0
       nPos1 := 0
       
       FOR nI := 1 TO LEN(aCC)
       
          IF nLin > nMaxLin
             oPrn:EndPage()
             nLin := 100
             CabCC(nLin)
             nLin += 50
             oPrn:StartPage()
          ENDIF
          
          nCont++
          nPos := 050

          cLin := aCC[nI]
          oPrn:Say(nLin,nPos,cLin,oFont08)
          nPos += 220

	      //cLin := Posicione("CTT",1,xFilial("CTT")+aCC[nI],"CTT_DESC01")
	      
          cDescCC := Posicione("CTT",1,xFilial("CTT")+aCC[nI],"CTT_DESC01")
          IF EMPTY(cDescCC)
             cDescCC := "BK CONSULTORIA ("+TRIM(aCC[nI])+")"
          ENDIF   
	      cLin := SUBSTR(cDescCC,1,40)
	      
	      
          oPrn:Say(nLin,nPos,cLin,oFont08)
          nPos += (600+140+140+(190+190+140+100))

          cDesVig := ""
 		  cDesVig := U_Vig2Contrat(TRIM(aCC[nI]),SE2->E2_VENCREA)
	          
  	      nPosVig := nPos
          oPrn:Say(nLin,nPosVig,cDesVig,oFont07)
          nPos  += 410

          nPos1 := nPos
	      cLin := TRANSFORM(aValCC[nI],"@ze 999,999,999.99")
          oPrn:Say(nLin,nPos,cLin,oFont08)
          nTot += aValCC[nI]
          nLin += 40
  

		  nLinDESC := MLCOUNT(cDescCC,40)
		  IF nLinDESC > 1
			 FOR xO := 2 TO nLinDESC
	  			oPrn:Say(nLin,nPosDESC,MemoLine(cDescCC,40,xO),oFont07)
			    nLin+=40
			    IF nLin > nMaxLin
			         oPrn:EndPage()
			         nLin := 100
			         Cab(nLin)
			         nLin += 50
			         oPrn:StartPage()
			    ENDIF
		  	 NEXT    
		  ENDIF
          
       NEXT
       IF nTot > 0
          cLin := "Total de "+ALLTRIM(TRANSFORM(nCont,"999999"))+" registros"
          oPrn:Say(nLin,50,cLin,oFont08N)

          cLin := TRANSFORM(nTot,"@ze 999,999,999.99")
          oPrn:Say(nLin,nPos1,cLin,oFont08N)
          nLin += 40
       ENDIF
    ENDIF 
    
    nLin += 20
    
   	nPos := nLin
    
    dbSelectArea("SE5")
    SET ORDER TO 7
    GO TOP

    lBaixas := .F.

    DbSeek(xFilial("SE5")+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA,.T.)

    DO WHILE !SE5->(Eof()) .and. ;
			 SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == ;
			 xFilial("SE5")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
   
		If !Empty(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)) .or. SE5->E5_SITUACA == "C"
			If SE5->E5_SITUACA =="C" .Or. TemBxCanc(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)
				SE5->(dbSkip())
				Loop
			EndIf
		EndIf
	
        IF nLin > nMaxLin
           oPrn:EndPage()
           nLin := 100
           CabMov(nLin)
           nLin += 50
		   nPos := nLin
           oPrn:StartPage()
        ENDIF
 
       //If (SE5->E5_RECPAG == "P" .AND. SE5->E5_TIPODOC == "ES") .OR. ;
       //   (SE5->E5_RECPAG == "R" .AND. SE5->E5_TIPODOC != "ES" .AND. !(SE5->E5_TIPO $ MVPAGANT+"/"+MV_CPNEG)) .OR.;
       //   (SE5->E5_SITUACA == "C")
       //   
       //   SE5->(dbSkip())
       //   Loop
       //EndIF
       
       /*
       nValPago := SE5->E5_VALOR
       cCodBx   := "90550"
      
       IF SE5->E5_TIPODOC $ "VL/V2/BA"
          cCodBx := "90550"
       ELSEIF SE5->E5_TIPODOC $ "CP"
          cCodBx := "90557"
       ELSEIF SE5->E5_TIPODOC $ "ES"
          nValPago := - SE5->E5_VALOR
       ELSEIF SE5->E5_TIPODOC $ "JR/J2/TL/MT/M2/CM/C2"
          SKIP
          LOOP
       ENDIF
       */
       
       IF !lBaixas
	      lBaixas := .T.
		  nPos := nLin
          nLin += 20
		  oPrn:Say(nLin,1400,"Movimentações",oFont14N)
          nLin += 60
          CabMov(nLin)
          nLin+=50
	   ENDIF    

       oPrn:Say(nLin,0080,SE5->E5_SEQ,oFont08)
       oPrn:Say(nLin,0155,DTOC(SE5->E5_DATA),oFont08)
       oPrn:Say(nLin,0350,ALLTRIM(SE5->E5_HISTOR)+" "+ALLTRIM(SUBSTR(SE5->E5_DOCUMEN,1,16)),oFont08)
       oPrn:Say(nLin,1370,SE5->E5_TIPODOC,oFont08)
       oPrn:Say(nLin,1430,SE5->E5_MOTBX,oFont08)
       oPrn:Say(nLin,1510,SE5->E5_NUMCHEQ,oFont08)
       oPrn:Say(nLin,1760,SE5->E5_BANCO+" "+E5_CONTA,oFont08)
       oPrn:Say(nLin,2180,TRANSFORM(SE5->E5_VALOR,"@ze 999,999,999.99"),oFont08)
       nLin+=50

	   dbSelectArea("SE5")
       dbSkip()
	ENDDO

	IF lBaixas
	    oPrn:Box(nPos,0050,nLin,IIf(lLands,3140,2350))
	    nLin += 50
	ENDIF

End Sequence
oPrn:EndPage()

Return



Static Function ProcQuery
Local cQuery
Local cPrefixo := SE2->E2_PREFIXO
Local cNum     := SE2->E2_NUM
Local cParcela := SE2->E2_PARCELA
Local cTipo    := SE2->E2_TIPO
Local cFornece := SE2->E2_FORNECE
Local cLoja    := SE2->E2_LOJA


//IncProc("Consultando o banco de dados...")

cQuery := "SELECT ""
cQuery += " Z2_NOME,Z2_PRONT,Z2_BANCO,Z2_AGENCIA,Z2_DATAEMI,Z2_DATAPGT,Z2_DIGAGEN,Z2_CONTA,Z2_DIGCONT,Z2_TIPO,Z2_VALOR,"
cQuery += " Z2_TIPOPES,Z2_CC,Z2_USUARIO,Z2_OBSTITU,Z2_NOMDEP,Z2_NOMMAE "
cQuery += " FROM "+RETSQLNAME("SZ2")+" SZ2"
cQuery += " WHERE Z2_CODEMP = '"+SM0->M0_CODIGO+"' "
cQuery += " AND Z2_E2PRF  = '"+cPrefixo+"' "
cQuery += " AND Z2_E2NUM  = '"+cNum+"' "
cQuery += " AND Z2_E2PARC = '"+cParcela+"' "
cQuery += " AND Z2_E2TIPO = '"+cTipo+"' "
cQuery += " AND Z2_E2FORN = '"+cFornece+"' "
cQuery += " AND Z2_E2LOJA = '"+cLoja+"' "
cQuery += " AND Z2_STATUS = 'S'"
cQuery += " AND SZ2.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY Z2_NOME"  

TCQUERY cQuery NEW ALIAS "QSZ2"
TCSETFIELD("QSZ2","Z2_DATAEMI","D",8,0)
TCSETFIELD("QSZ2","Z2_DATAPGT","D",8,0)


Return


Static Function Cab(nLin)
Local nPos := 50

cLin := "Pront."
oPrn:Say(nLin,nPos,cLin,oFont08N)
nPos += 110

cLin := "Nome"
oPrn:Say(nLin,nPos,cLin,oFont08N)
nPos += 680
       
cLin := "Ag."
oPrn:Say(nLin,nPos,cLin,oFont08N)
nPos += 110

cLin := "Conta"
oPrn:Say(nLin,nPos,cLin,oFont08N)
nPos += 190

cLin := "Centro de Custo"
oPrn:Say(nLin,nPos,cLin,oFont08N)
nPos += (640)

//cLin := "Tipo"
//oPrn:Say(nLin,nPos,cLin,oFont12N)
//nPos += 190

//cLin := "T.Pes."
//oPrn:Say(nLin,nPos,cLin,oFont12N)
//nPos += 190

cLin := "Usuario"
oPrn:Say(nLin,nPos,cLin,oFont08N)
nPos += 335

IF lLands
   cLin := "Observaçoes"
   oPrn:Say(nLin,nPos,cLin,oFont08N)
   nPos += 800
ENDIF


cLin := PADL("Valor",14)
oPrn:Say(nLin,nPos,cLin,oFont08N)
//999,999,999.99
//nPos += 200


Return nil
                  


Static Function CabCC(nLin)
Local nPos := 50

cLin := "Codigo"
oPrn:Say(nLin,nPos,cLin,oFont12N)
nPos += 220

cLin := "Centro de Custo"
oPrn:Say(nLin,nPos,cLin,oFont12N)
nPos += (600+140+140+(190+190+140+110)+400)

cLin := "Valor"
oPrn:Say(nLin,nPos,PADL(cLin,11),oFont12N)
Return nil


Static Function CabMov(nLin)

oPrn:Say(nLin,0080,"Sq",oFont12N)
oPrn:Say(nLin,0155,"Data",oFont12N)
oPrn:Say(nLin,0350,"Histórico",oFont12N)
oPrn:Say(nLin,1370,"Tp",oFont12N)
oPrn:Say(nLin,1430,"Mov",oFont12N)
oPrn:Say(nLin,1510,"Cheque",oFont12N)
oPrn:Say(nLin,1760,"Bco/CC",oFont12N)
oPrn:Say(nLin,2180,PADL("Valor",11),oFont12N)
Return nil


USER Function Vig2Contrat(cContrato,dPGTO)
Local cVig  := ""
Local dDTIN := CTOD("")
Local dDVIG := CTOD("")
Local cContRev := ""

cQuery := "SELECT TOP 1 CN9_NUMERO,CN9_REVISA,CN9_DTINIC,CN9_XXDVIG "
cQuery += " FROM "+RETSQLNAME("CN9")+" CN9 WHERE CN9_FILIAL='"+xFilial("CN9")+"' AND CN9.D_E_L_E_T_='' AND"
cQuery += " CN9_SITUAC<>'10' AND CN9_NUMERO='"+cContrato+"'
cQuery += " ORDER BY CN9_REVISA DESC"

TCQUERY cQuery NEW ALIAS "QCN9"
TCSETFIELD("QCN9","CN9_DTINIC","D",8,0)
TCSETFIELD("QCN9","CN9_XXDVIG","D",8,0) 

DBSELECTAREA("QCN9")
QCN9->(DBGOTOP())
DO WHILE QCN9->(!EOF())
	dDTIN := QCN9->CN9_DTINIC
	dDVIG := QCN9->CN9_XXDVIG
   // Buscar o ultimo vencto dos Cronogramas
   dbSelectArea("CNF")
   dbSetOrder(3)
   cContRev := xFilial("CNF")+QCN9->CN9_NUMERO+QCN9->CN9_REVISA
   dbSeek(cContRev,.T.)
   Do While !EOF() .AND. cContRev == CNF_FILIAL+CNF_CONTRA+CNF_REVISA
      IF dDVIG < CNF->CNF_DTVENC
         dDVIG := CNF->CNF_DTVENC
         ENDIF
		CNF->(dbSkip())
	EndDo
	QCN9->(dbSkip())
ENDDO
QCN9->(Dbclosearea())

IF dDVIG <= dPGTO .AND. !EMPTY(dDVIG)  
	cVig := " - Vig.: "+DTOC(dDTIN)+" até "+DTOC(dDVIG) 
ENDIF

Return cVig


USER FUNCTION BUSERRUBI(cTIPO,cPRONT,dDTPGTO,cUSER)
LOCAL cSQL   := ""
LOCAL cDIGTA := ""

IF ALLTRIM(cTIPO) $ "LFE/LRC"

	cSQL:= "SELECT TOP 1 USU.CodUsu,NomUsu FROM bk_senior.bk_senior.R067LPR LPR"
	cSQL+= " INNER join bk_senior.bk_senior.R999USU USU on LPR.CodUsu=USU.CodUsu"
	cSQL+= " where "
	IF ALLTRIM(cTIPO) == "LFE"
		cSQL+= " MsgLog like '%Tipo Féria%'"
	ELSE
		cSQL+= " MsgLog like '%Tipo Rescisão%'"
	ENDIF
	cSQL+= " AND MsgLog like '%NumEmp: "+ALLTRIM(STR(VAL(SM0->M0_CODIGO)))+"%'"
	cSQL+= " AND MsgLog like '%NumCad: "+ALLTRIM(STR(VAL(cPRONT)))+"%'"	
	cSQL+= " AND MsgLog like '%Data Pagamento: "+DTOC(dDTPGTO)+"%'"

	TCQUERY cSQL NEW ALIAS "QLSenior" 

	dbSelectArea("QLSenior")

	IF !EMPTY(QLSenior->NomUsu)
		cDIGTA := ALLTRIM(QLSenior->NomUsu)
	ENDIF

	QLSenior->(Dbclosearea())
ENDIF

IF EMPTY(cDIGTA)
	cDIGTA := cUSER
ENDIF 

RETURN cDIGTA



Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Imprimir:"           ,"Imprimir"    ,"Imprimir"    ,"mv_ch1","N",01,0,2,"C","","mv_par01","Titulo unico","Titulo unico","Titulo unico","","","Por Vencto","Por Vencto","Por Vencto","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Data de Vencimento:" ,"Da Data "    ,"Da Data"     ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Gerar Planilha? "    ,"Planilha"    ,"Planilha"    ,"mv_ch3","N",01,0,2,"C","","mv_par03","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Imprimir TipoBk PCT:","Imprimir PCT","Imprimir PCT","mv_ch4","N",01,0,2,"C","","mv_par04","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"05","Imprimir Tipo NDF: " ,"Imprimir NDF","Imprimir NDF","mv_ch5","N",01,0,2,"C","","mv_par05","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"06","Selecionar:"         ,"Selecionar:" ,"Selecionar:" ,"mv_ch6","N",01,0,2,"C","","mv_par06","Todos","Todos","Todos","","","Impressos","Impressos","Impressos","","","Não impressos","Não impressos","Não impressos","","","Desmarcar Impr.","Desmarcar Impr.","Desmarcar Impr.","","","","","","",""})

For i:=1 to Len(aRegistros)
	If !dbSeek(cPerg+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegistros[i])
				FieldPut(j,aRegistros[i,j])
			Endif
		Next
		MsUnlock()
	//Else
		//RecLock("SX1",.F.)
		//For j:=1 to FCount()
		//	If j <= Len(aRegistros[i])
		//		FieldPut(j,aRegistros[i,j])
		//	Endif
		//Next
		//MsUnlock()
	Endif
Next

RestArea(aArea)

Return(NIL)