#Include "Ctbr041.Ch"
#Include "PROTHEUS.Ch"


// 17/08/2009 -- Filial com mais de 2 caracteres

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ctbr041	³ Autor ³ Pilar S Albaladejo	³ Data ³ 12.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Balancete Analitico Sintetico Modelo 1			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/         
USER Function xCtbr041()   
PRIVATE titulo		:= ""
Private nomeprog	:= "CTBR041"
Private aSelFil	:= {}

If TYPE("CRELEASERPO") == "U"
	CtAjustSx1('CTR041')	// Protheus 11  - P11
Else
	// Protheus 12 - P12
EndIf


If FindFunction("TRepInUse") .And. TRepInUse() 
	XCTBR041R3() //CTBR040R4()
Else
	Return XCTBR041R3()
EndIf

Return

/*
-------------------------------------------------------- RELEASE 3 -------------------------------------------------------------
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctbr041R3 |Autor  ³ Pilar S Albaladejo	³ Data ³ 12.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Balancete Analitico Sintetico Modelo 1			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/         
STATIC Function XCtbR041R3()

//LOCAL cString		:= "CT1"
Local titulo 		:= ""
Local lRet			:= .T.
Local aCtbMoeda		:= {}

PRIVATE nLastKey 	:= 0
PRIVATE cPerg	 	:= "CTR041"
PRIVATE aLinha		:= {}
PRIVATE nomeProg 	 := "CTBR041"

m_pag		:= 1

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

If !Pergunte("CTR041",.T.)
	Return
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros					  		³
//³ mv_par01				// Data Inicial                   		³
//³ mv_par02				// Data Final                       	³
//³ mv_par03				// Conta Inicial                      	³
//³ mv_par04				// Conta Final  						³
//³ mv_par05				// Imprime Contas: Sintet/Analit/Ambas  ³
//³ mv_par06				// Set Of Books				    		³
//³ mv_par07				// Saldos Zerados?			     		³
//³ mv_par08				// Moeda?          			     	    ³
//³ mv_par09				// Pagina Inicial  		     			³
//³ mv_par10				// Saldos? Reais / Orcados	/Gerenciais ³
//³ mv_par11				// Quebra por Grupo Contabil?		    ³
//³ mv_par12				// Filtra Segmento?					    ³
//³ mv_par13				// Conteudo Inicial Segmento?		   	³
//³ mv_par14				// Conteudo Final Segmento?		    	³
//³ mv_par15				// Conteudo Contido em?				    ³
//³ mv_par16				// Imprime Coluna Mov ?				    	  ³
//³ mv_par17				// Salta linha sintetica ?			    	  ³
//³ mv_par18				// Imprime valor 0.00    ?			    	  ³
//³ mv_par19				// Imprimir Codigo? Normal / Reduzido  	³
//³ mv_par20				// Divide por ?                   		³
//³ mv_par21				// Imprimir Ate o segmento?			   	³
//³ mv_par22				// Posicao Ant. L/P? Sim / Nao         	³
//³ mv_par23				// Data Lucros/Perdas?                 	³
//³ mv_par24				// Rec./Desp. Anterior Zeradas?			³		
//³ mv_par25				// Grupo Receitas/Despesas?      		³		
//³ mv_par26				// Data de Zeramento Receita/Despesas?	³		
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := "CTBR041"            //Nome Default do relatorio em Disco

If lRet
	aCtbMoeda  	:= CtbMoeda(mv_par08)
	If Empty(aCtbMoeda[1])                       
      Help(" ",1,"NOMOEDA")
      lRet := .F.
   Endif
Endif

If lRet .And. mv_par27 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		lRet := .F.
	EndIf 
EndIf

if lRet
	If (mv_par24 == 1) .and. ( Empty(mv_par25) .or. Empty(mv_par26) )
		cMensagem	:= STR0019	//"Favor preencher os parametros Grupos Receitas/Despesas e "
		cMensagem	+= STR0020	//"Data Sld Ant. Receitas/Desp. "
		MsgAlert(cMensagem,"Ignora Sl Ant.Rec/Des")	
		lRet    	:= .F.	
	EndIf
EndIf

If mv_par05 == 1
	titulo:=	STR0009	//"BALANCETE DE VERIFICACAO SINTETICO DE "
ElseIf mv_par05 == 2
	titulo:=	STR0006	//"BALANCETE DE VERIFICACAO ANALITICO DE "
ElseIf mv_par05 == 3
	titulo:=	STR0013	//"BALANCETE DE VERIFICACAO DE "
EndIf

If !lRet
	Set Filter To
	Return
EndIf

titulo += Dtoc(mv_par01) + Space(01) + STR0007 + Space(01) + Dtoc(mv_par02)

//Personalizalçao BK
IF !EMPTY(mv_par28)
	Titulo +="           Diário Nº"+mv_par28
ENDIF


If mv_par10 > "1"			
	Titulo += " (" + Tabela("SL", mv_par10, .F.) + ")"
Endif
MsgRun(STR0017,"",{|| CursorWait(), Ctr041Cfg(titulo) ,CursorArrow()}) //"Gerando relatorio, aguarde..."

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Ctr041Det ³ Autor ³ Simone Mie Sato       ³ Data ³ 28.06.01 ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Detalhe do Relatorio                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctr041Det(ExpO1,ExpN1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±³          ³ ExpN1 = Contador de paginas                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*
STATIC Function XCtr041Det(oPrint,i,titulo)

Local aSetOfBook
Local aCtbMoeda		:= {}
//Local lin 			:= 298
//Local lin 			:= 2811
Local lin			:= 2351
Local cArqTmp
Local lRet 			:= .T.
Local cSeparador	:= ""
Local cPicture
Local cDescMoeda
Local cCodMasc
Local cMascara  
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nGrpDeb		:= 0
Local nGrpCrd		:= 0
Local nTotMov		:= 0
Local lFirstPage	:= .T.               
Local nTraco		:= 0
Local cSegAte   	:= mv_par21
Local nDigitAte		:= 0
Local lImpRes		:= Iif(mv_par19 == 1,.F.,.T.)	
Local lImpAntLP		:= Iif(mv_par22 == 1,.T.,.F.)
Local dDataLP		:= mv_par23
Local nDivide		:= mv_par20
Local lImpSint		:= Iif(mv_par05=1 .Or. mv_par05 ==3,.T.,.F.)
Local lVlrZerado	:= Iif(mv_par07==1,.T.,.F.)
Local lPrintZero	:= Iif(mv_par18==1,.T.,.F.)
Local lRecDesp0		:= Iif(mv_par24==1,.T.,.F.)
Local cRecDesp		:= mv_par25
Local dDtZeraRD		:= mv_par26
Local lJaPulou		:= .F.
Local lPula			:= Iif(mv_par17==1,.T.,.F.) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)	   	 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !ct040Valid(mv_par06)
	lRet := .F.
Else
   aSetOfBook := CTBSetOf(mv_par06)
Endif

If lRet
	aCtbMoeda  	:= CtbMoeda(mv_par08)
	If Empty(aCtbMoeda[1])                       
      Help(" ",1,"NOMOEDA")
      lRet := .F.
   Endif
Endif

cDescMoeda 	:= aCtbMoeda[2]
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par08)

If Empty(aSetOfBook[2])
	cMascara := GetMv("MV_MASCARA")
Else
	cMascara 	:= RetMasCtb(aSetOfBook[2],@cSeparador)
EndIf
cPicture 		:= aSetOfBook[4]

m_pag 			:= If(ValType(mv_par09)=="C",Val(mv_par09),mv_par09) //teve q convertei pois no SX1 estava como Caracter

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
 				mv_par01,mv_par02,"CT7","",mv_par03,mv_par04,,,,,,,mv_par08,;
				mv_par10,aSetOfBook,mv_par12,mv_par13,mv_par14,mv_par15,;
				mv_par16 = 2,.F.,mv_par11,,lImpAntLP,dDataLP, nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,,lRecDesp0,;
				cRecDesp,dDtZeraRD,,,,,,,,,aSelFil)},;
				STR0014,;  	//"Criando Arquivo Tempor rio..."
				STR0010) 	//"Balancete Verificacao"

// Verifica Se existe filtragem Ate o Segmento
If !Empty(cSegAte)
	nDigitAte := CtbRelDig(cSegAte,cMascara) 	
EndIf		
				
dbSelectArea("cArqTmp")
//dbSetOrder(1)
dbGoTop()

cGrupo := GRUPO

While !Eof()

	******************** "FILTRAGEM" PARA IMPRESSAO *************************

	If mv_par05 == 1					// So imprime Sinteticas
		If TIPOCONTA == "2"
			dbSkip()
			Loop
		EndIf
	ElseIf mv_par05 == 2				// So imprime Analiticas
		If TIPOCONTA == "1"
			dbSkip()
			Loop
		EndIf
	EndIf

	If mv_par07 == 2						// Saldos Zerados nao serao impressos
		If (Abs(SALDOANT)+Abs(SALDOATU)+Abs(SALDODEB)+Abs(SALDOCRD)) == 0
			dbSkip()
			Loop
		EndIf
	EndIf

	//Filtragem ate o Segmento ( antigo nivel do SIGACON)		
	If !Empty(cSegAte)
		If Len(Alltrim(CONTA)) > nDigitAte
			dbSkip()
			Loop
		Endif
	EndIf
	

	************************* ROTINA DE IMPRESSAO *************************	
	If mv_par11 == 1							// Grupo Diferente - Totaliza e Quebra
		If cGrupo != GRUPO                                   
			oPrint:Line( lin,180,lin,3150 )   	// horizontal                          			
			oPrint:Line( lin,180,lin+55, 180 )   	// vertical
			oPrint:Say(lin+5,0730,STR0015+cGrupo+") : ",oFont10 )//"T O T A I S  D O  G R U P O : "
			
			If mv_par16 = 1
				oPrint:Line(lin,1730,lin+55,1730)   	// vertical
				ValorCTB(nGrpDeb,lin+15,1730,16,nDecimais,.F.,cPicture,"1",CONTA,.T.,oPrint, , ,lPrintZero)				
				oPrint:Line(lin,2030,lin+55,2030)   	// vertical
				ValorCTB(nGrpCrd,lin+15,2090,16,nDecimais,.F.,cPicture,"2",CONTA,.T.,oPrint, , ,lPrintZero)				
				oPrint:Line(lin,2400,lin+55,2400)   	// vertical

				nTotMov := nTotMov + (nGrpCrd - nGrpDeb)
				If Round(NoRound(nTotMov,3),2) < 0
					ValorCTB(nTotMov,lin + 15,2420,16,nDecimais,.T.,cPicture,"1",, .T., oPrint, , ,lPrintZero)				
				ElseIf Round(NoRound(nTotMov,3),2) > 0
					ValorCTB(nTotMov,lin + 15,2420,16,nDecimais,.T.,cPicture,"2",, .T., oPrint, , ,lPrintZero)				
                EndIf

				oPrint:Line(lin,2740,lin+55,2740)   	// vertical
			Else
				oPrint:Line(lin,1850,lin+55,1850)   	// vertical
				ValorCTB(nGrpDeb,lin+5,1850,16,nDecimais,.F.,cPicture,"1",,.T.,oPrint, , ,lPrintZero)				
				oPrint:Line(lin,2250,lin+55,2250)   	// vertical
				ValorCTB(nGrpCrd,lin+5,2250,16,nDecimais,.F.,cPicture,"2",,.T.,oPrint, , ,lPrintZero)				
				oPrint:Line(lin,2700,lin+55,2700)   	// vertical	     
			Endif
			oPrint:Line( lin,3150,lin+55,3150 )   	// vertical  
			lin	+=55		                                   
			oPrint:Line( lin,180,lin,3150 )   	// horizontal
			cGrupo	:= GRUPO
			nGrpDeb	:= 0
			nGrpCrd	:= 0		        			
			//	lin := 2811
			lin		:= 2351
		EndIf		
	Else
		If NIVEL1 .And. cArqTmp->TIPOCONTA == '1' // Sintetica de 1o. grupo
//			lin		:= 2811    
			lin		:= 2351			
		EndIf
	EndIf                                       
	
		
//	If lin > 2810		
	If lin > 2350
		If !lFirstPage
			oPrint:Line( ntraco,180,ntraco,3150 )   	// horizontal                          			
			m_pag++			
		EndIf	
		i++                                                
		oPrint:EndPage() 	 			// Finaliza a pagina
		CtbCbcPad(oPrint,i,titulo) 	// Funcao que monta o cabecalho padrao 
		CTR041ESP(oPrint)				// Cabecalho especifico do CTBR041
		lin := 304        
		lFirstPage := .F.		
	End
	
	oPrint:Line( lin,180,lin+50,180 )   	// vertical
	If lImpRes .And. cArqTmp->TIPOCONTA == '2'	//Se imprime codigo reduzido da conta e a conta eh analititca		
		EntidadeCTB(CTARES,lin+15,215,20,.F.,cMascara,cSeparador,"CT1",1,.T.,oPrint)
	Else
		EntidadeCTB(cArqTMP->CONTA,lin+15,215,if(Len(cArqTMP->CONTA) > 20, 20 , 20+len(cMascara) ),.F.,cMascara,cSeparador,"CT1",1,.T.,oPrint)	
	Endif
	oPrint:Line(lin,555,lin+50,555)   		// vertical
	oPrint:Say(lin+15,570,Alltrim(DESCCTA),oFont08)
	oPrint:Line(lin,1400,lin+50,1400)    	// vertical
	ValorCTB(SALDOANT,lin+15,1400,17,nDecimais,.T.,cPicture,NORMAL,CONTA,.T.,oPrint, , ,lPrintZero)				
	If mv_par16 = 1
		oPrint:Line(lin,1730,lin+50,1730)   	// vertical
		ValorCTB(SALDODEB,lin+15,1730,16,nDecimais,.F.,cPicture,NORMAL,CONTA,.T.,oPrint, , ,lPrintZero)				
		oPrint:Line(lin,2030,lin+50,2030)   	// vertical
		ValorCTB(SALDOCRD,lin+15,2090,16,nDecimais,.F.,cPicture,NORMAL,CONTA,.T.,oPrint, , ,lPrintZero)				
		oPrint:Line(lin,2400,lin+50,2400)   	// vertical
		ValorCTB(MOVIMENTO,lin+15,2420,16,nDecimais,.F.,cPicture,NORMAL,CONTA,.T.,oPrint, , ,lPrintZero)				
		oPrint:Line(lin,2740,lin+50,2740)   	// vertical
		ValorCTB(SALDOATU,lin+15,2820,17,nDecimais,.T.,cPicture,NORMAL,CONTA,.T.,oPrint, , ,lPrintZero)				
	Else
		oPrint:Line(lin,1850,lin+50,1850)   	// vertical
		ValorCTB(SALDODEB,lin+15,1850,16,nDecimais,.F.,cPicture,NORMAL,CONTA,.T.,oPrint, , ,lPrintZero)				
		oPrint:Line(lin,2250,lin+50,2250)   	// vertical
		ValorCTB(SALDOCRD,lin+15,2250,16,nDecimais,.F.,cPicture,NORMAL,CONTA,.T.,oPrint, , ,lPrintZero)				
		oPrint:Line(lin,2700,lin+50,2700)   	// vertical
		ValorCTB(SALDOATU,lin+15,2700,17,nDecimais,.T.,cPicture,NORMAL,CONTA,.T.,oPrint, , ,lPrintZero)				
	Endif
	oPrint:Line(lin,3150,lin+50,3150)   	// vertical
	
	If lin > 2350		
		If !lFirstPage
			oPrint:Line( ntraco,180,ntraco,3150 )   	// horizontal                          			
			m_pag++			
		EndIf	
		i++                                                
		oPrint:EndPage() 	 			// Finaliza a pagina
		CtbCbcPad(oPrint,i,titulo) 	// Funcao que monta o cabecalho padrao 
		CTR041ESP(oPrint)				// Cabecalho especifico do CTBR041
		lin := 304        
		lFirstPage := .F.		
	Else
		lJaPulou := .F.
		If lPula .And. TIPOCONTA == "1"				// Pula linha entre sinteticas
			lin += 47
			oPrint:Line( lin,180,lin+50,180 )
			oPrint:Line(lin,555,lin+50,555)
			oPrint:Line(lin,1400,lin+50,1400)
			If mv_par16 = 1
				oPrint:Line(lin,1730,lin+50,1730)
				oPrint:Line(lin,2030,lin+50,2030)
				oPrint:Line(lin,2400,lin+50,2400)
				oPrint:Line(lin,2740,lin+50,2740)
			Else
				oPrint:Line(lin,1850,lin+50,1850)
				oPrint:Line(lin,2250,lin+50,2250)
				oPrint:Line(lin,2700,lin+50,2700)
			Endif
			oPrint:Line(lin,3150,lin+50,3150)
			lJaPulou := .T.
	   EndIf	   
	End


	lin +=47
	

	************************* FIM   DA  IMPRESSAO *************************

	If mv_par05 == 1					// So imprime Sinteticas - Soma Sinteticas
		If TIPOCONTA == "1"
			If NIVEL1
				nTotDeb += SALDODEB
				nTotCrd += SALDOCRD
				nGrpDeb += SALDODEB
				nGrpCrd += SALDOCRD
			EndIf
		EndIf
	Else									// Soma Analiticas
		If Empty(cSegAte)	//Se nao tiver filtragem ate o nivel
			If TIPOCONTA == "2"
				nTotDeb += SALDODEB
				nTotCrd += SALDOCRD
				nGrpDeb += SALDODEB
				nGrpCrd += SALDOCRD
			EndIf
		Else		//Se tiver filtragem, somo somente as sinteticas
			If TIPOCONTA == "1"
				If NIVEL1
					nTotDeb += SALDODEB
					nTotCrd += SALDOCRD
				EndIf
			EndIf
    	Endif					
	EndIf
	dbSelectArea("cArqTmp")
	dbSkip()

	If lPula .And. TIPOCONTA == "1"				// Pula linha entre sinteticas
		If !lJaPulou
			oPrint:Line( lin,180,lin+50,180 )
			oPrint:Line(lin,555,lin+50,555)
			oPrint:Line(lin,1400,lin+50,1400)
			If mv_par16 = 1
				oPrint:Line(lin,1730,lin+50,1730)
				oPrint:Line(lin,2030,lin+50,2030)
				oPrint:Line(lin,2400,lin+50,2400)
				oPrint:Line(lin,2740,lin+50,2740)
			Else
				oPrint:Line(lin,1850,lin+50,1850)
				oPrint:Line(lin,2250,lin+50,2250)
				oPrint:Line(lin,2700,lin+50,2700)
			Endif
			oPrint:Line(lin,3150,lin+50,3150)
			lin += 47
	   EndIf	   
	EndIf	
	ntraco := lin + 1
EndDO
oPrint:Line(lin,180,lin,3150)   	// horizontal

If mv_par11 == 1							// Grupo Diferente - Totaliza e Quebra
	If cGrupo != GRUPO
		oPrint:Line( lin,180,lin+50, 180 )   	// vertical
		oPrint:Say(lin+5,710,STR0015+cGrupo+") : ",oFont10 )//"T O T A I S  D O  G R U P O : "
		If mv_par16 = 1
			oPrint:Line(lin,1730,lin+55,1730)   	// vertical
			ValorCTB(nGrpDeb,lin+15,1730,16,nDecimais,.F.,cPicture,"1",CONTA,.T.,oPrint, , ,lPrintZero)				
			oPrint:Line(lin,2030,lin+55,2030)   	// vertical
			ValorCTB(nGrpCrd,lin+15,2090,16,nDecimais,.F.,cPicture,"2",CONTA,.T.,oPrint, , ,lPrintZero)				
			oPrint:Line(lin,2400,lin+55,2400)   	// vertical
			nTotMov := nTotMov + (nGrpCrd - nGrpDeb)
			If Round(NoRound(nTotMov,3),2) < 0
				ValorCTB(nTotMov,lin + 15,2420,16,nDecimais,.T.,cPicture,"1",,, oPrint, , ,lPrintZero)				
			ElseIf Round(NoRound(nTotMov,3),2) > 0
				ValorCTB(nTotMov,lin + 15,2420,16,nDecimais,.T.,cPicture,"2",,, oPrint, , ,lPrintZero)				
    		EndIf

			oPrint:Line(lin,2740,lin+55,2740)   	// vertical
		Else
			oPrint:Line(lin,1850,lin+50,1850)   	// vertical
			ValorCTB(nGrpDeb,lin+5,1850,16,nDecimais,.F.,cPicture,"1",,.T.,oPrint, , ,lPrintZero)				
			oPrint:Line(lin,2250,lin+50,2250)   	// vertical
			ValorCTB(nGrpCrd,lin+5,2250,16,nDecimais,.F.,cPicture,"2",,.T.,oPrint, , ,lPrintZero)				
			oPrint:Line(lin,2700,lin+50,2700)   	// vertical	     
		Endif
		oPrint:Line( lin,3150,lin+50,3150 )   	// vertical  
		lin	+=50		                                   
		oPrint:Line( lin,180,lin,3150 )   	// horizontal
		cGrupo	:= GRUPO
		nGrpDeb	:= 0
		nGrpCrd	:= 0		        		
	Endif		
EndIf

oPrint:Line( lin,180,lin+55,180 )   	// vertical
oPrint:Say(lin+15,0730,STR0011,oFont10 )//"T O T A I S  D O  P E R I O D O : "
If mv_par16 = 1
	oPrint:Line(lin,1730,lin+55,1730)   	// vertical
	ValorCTB(nTotDeb,lin+15,1730,16,nDecimais,.F.,cPicture,"1",CONTA,.T.,oPrint, , ,lPrintZero)				
	oPrint:Line(lin,2030,lin+55,2030)   	// vertical
	ValorCTB(nTotCrd,lin+15,2090,16,nDecimais,.F.,cPicture,"2",CONTA,.T.,oPrint, , ,lPrintZero)				
	oPrint:Line(lin,2400,lin+55,2400)   	// vertical
	nTotMov := nTotMov + (nGrpCrd - nGrpDeb)
	If Round(NoRound(nTotMov,3),2) < 0
		ValorCTB(nTotMov,lin + 15,2420,16,nDecimais,.T.,cPicture,"1",,.T., oPrint, , ,lPrintZero)				
	ElseIf Round(NoRound(nTotMov,3),2) > 0
		ValorCTB(nTotMov,lin + 15,2420,16,nDecimais,.T.,cPicture,"2",,.T., oPrint, , ,lPrintZero)				
	EndIf
	oPrint:Line(lin,2740,lin+55,2740)   	// vertical
Else
	oPrint:Line(lin,1850,lin+55,1850)   	// vertical
	ValorCTB(nTotDeb,lin+15,1850,16,nDecimais,.F.,cPicture,"1",,.T.,oPrint, , ,lPrintZero)				
	oPrint:Line(lin,2250,lin+55,2250)   	// vertical
	ValorCTB(nTotCrd,lin+15,2250,16,nDecimais,.F.,cPicture,"2",,.T.,oPrint, , ,lPrintZero)				
	oPrint:Line(lin,2700,lin+55,2700)   	// vertical	     
Endif
oPrint:Line(lin,3150,lin+55,3150)   	// vertical
oPrint:Line(lin+55,180,lin+55,3150)   	// horizontal

lin += 10
dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea() 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	
dbselectArea("CT2")

Return lin
*/


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctr041Cfg ³ Autor ³ Simone Mie Sato       ³ Data ³ 27.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria os objetos para relat. grafico.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
STATIC Function XCtr041Cfg(titulo)

Local oPrint
Local i 	:= 1
Local lin 	:= 0                        
 //Define se a folha de parametros sera impressa no inicio
Local lImpSX1	:= IF(GetMv("MV_IMPSX1")=="S",.T.,.F.)
Local cTitSX1:= ""
Local cStartPath		:= GetSrvProfString("Startpath","")
Local cNameFile		:= ""

Private oFont16, oFont08, oFont10 , oFont14


oFont08	:= TFont():New("Courier New",08,08,,.F.,,,,.T.,.F.)
oFont10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
oFont14	:= TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)
oFont16	:= TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)

oPrint:= TMSPrinter():New( titulo )
oPrint:SetLandscape()

If lImpSX1          
	cTitSX1 := STR0016 + titulo  // "Parametros - "
	CtbCbcPad(oPrint,i,cTitSX1) 	// Funcao que monta o cabecalho padrao 
	ImpCTBSX1(oPrint)					// Funcao que imprime os parametros
Endif
                             
lin := Ctr041Det(oPrint,i,titulo)  		   

cStartPath := AjuBarPath(cStartPath)
cNameFile  := cStartPath+"lgrl"+cEmpAnt+cFilAnt+".bmp"
If !File(cNameFile)
	cNameFile := cStartPath+"lgrl"+cEmpAnt+".bmp"
Endif

If lin > 1810				// Espaco minimo para colocacao do rodape	
	i++
	oPrint:EndPage() 		// Finaliza a pagina
	oPrint:StartPage() 		// Inicia uma nova pagina		
	oPrint:SayBitmap(05,05,cNameFile,474,112) // Tem que estar abaixo do RootPath
	lin := 150
Endif

lin:= 2000

CtbRodape(oPrint,lin)			// Funcao que monta o rodape

oPrint:Preview()  				// Visualiza antes de imprimir

Return Nil
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CTR041ESP ³ Autor ³ Simone Mie Sato       ³ Data ³ 27.06.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cabecalho Especifico do relatorio CTBR041.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTR041ESP(oPrint)			                             	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oPrint                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*
STATIC Function XCTR041Esp(oPrint)

oPrint:Line(235,180,300,180)   	// vertical
oPrint:Say(260,200,STR0001,oFont10)//CODIGO DA CONTA
oPrint:Line(250,555,300,555)   	// vertical
oPrint:Say(260,730,STR0002,oFont10)// D  E  S  C  R  I  C  A  O
oPrint:Line(250,1400,300,1400)    	// vertical
//oPrint:Say(260,1430,STR0003,oFont10)//SALDO ANTERIOR
If mv_par16 = 1
	oPrint:Say(260,1415,STR0003,oFont10)//SALDO ANTERIOR
	oPrint:Line(250,1730,300,1730)   	// vertical
	oPrint:Say(260,1860,STR0004,oFont10)//DEBITO
	oPrint:Line(250,2030,300,2030)   	// vertical
	oPrint:Say(260,2170,STR0005,oFont10)//CREDITO
	oPrint:Line(250,2400,300,2400)   	// vertical
//	oPrint:Say(260,2405,STR0018,oFont10)//SALDO ATUAL //"MOV. PERIODO"
	oPrint:Say(260,2425,STR0018,oFont10)//SALDO ATUAL //"MOV. PERIODO"	
	oPrint:Line(250,2740,300,2740)   	// vertical
	oPrint:Say(260,2840,STR0006,oFont10)
Else                                                    
	oPrint:Say(260,1430,STR0003,oFont10)//SALDO ANTERIOR
	oPrint:Line(250,1850,300,1850)   	// vertical
	oPrint:Say(260,1970,STR0004,oFont10)//DEBITO
	oPrint:Line(250,2250,300,2250)   	// vertical
	oPrint:Say(260,2370,STR0005,oFont10)//CREDITO
	oPrint:Line(250,2700,300,2700)   	// vertical
	oPrint:Say(260,2800,STR0006,oFont10)//SALDO ATUAL
Endif
oPrint:Line(250,3150,300,3150)   	// vertical
oPrint:Line(300,180,300,3150)   	// horizontal

Return Nil
*/
