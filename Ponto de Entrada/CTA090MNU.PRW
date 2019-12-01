#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"       


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CTA090MNUºAutor  ³Adilson do Prado    º Data ³  08/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto Baixa Caução Contrato                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function XXCTA090MNU()  //rotina desabilitada, corrigido padrao pela TOTVS - Adilson 19/05/2015

aRotina := {}

aRotina	:= { 	{ "Perquisar", "AxPesqui"  	 , 0, 1, 0, .F.},;	//"Pesquisar"
				{ "Visualizar", "CN090Manut" , 0, 2, 0, nil},;	//"Visualizar"
				{ "Incluir", "CN090Manut"    , 0, 3, 0, nil},;	//"Incluir"
				{ "Alterar", "CN090Manut"	 , 0, 4, 0, nil},;	//"Alterar"
				{ "Excluir", "CN090Manut"	 , 0, 5, 0, nil},;	//"Excluir"
				{ "Baixar", "U_CN090Bx_BK"	 , 0, 6, 0, nil} }	//"Baixar"	

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³CN090Bx    ³ Autor ³ Sergio Silveira       ³ Data ³17/04/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Baixa a caucao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := CN090Bx( ExpC1, ExpN2, ExpN3 )                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 -> Alias / ExpN2 -> Recno / ExpN3 -> Opcao do arotina ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 -> .T. - Validacao / .F. - Insucesso                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER Function CN090Bx_BK(cAlias,nReg,nOpcx)

Local cPicValor  := PesqPict("CN8","CN8_VLEFET")
Local nOpcA      := 0
Local lCaucDinhe := .T.
Local lRet       := .T.
Local oBold


Private oDlg
Private nValorJur := 0
Private nValorResg := 0

If !Empty(CN8->CN8_DTBX)
	//Aviso( STR0026, STR0032, { STR0028 } ) // "Atencao", "Esta Caução já esta Baixada.", "Ok"
	Aviso( "Atencao", "Esta Caução já esta Baixada.", { "OK" } )
	
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ verifica se existe contrato                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lRet .And. !Empty(CN8->CN8_CONTRA)
	dbSelectArea("CN9")
	dbSetOrder(1)
	If !MsSeek(xFilial("CN9")+CN8->CN8_CONTRA)
		//Aviso( STR0026 , STR0033, { STR0028 } )  // "Atencao","Contrato não encontrado.", "Ok"
  		Aviso("Atencao","Contrato não encontrado.", {"Ok"})
		lRet := .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ verifica se tipo de caucao eh dinheiro pra baixar a caucao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CN3")
dbSetOrder(1)
If lRet .And. CN3->( MsSeek(xFilial("CN3")+CN8->CN8_TPCAUC) )
	If !(CN3->CN3_LIGFIN = "1" .and. CN3->CN3_ABATI # "1")
		nValorResg := CN8->CN8_VLEFET
//		If Aviso( STR0026, STR0034,{ STR0035, STR0036 } ) <> 1 // "Atencao", "Confirma a Baixa da Caução?","Sim","Nao"
		If Aviso( "Atencao", "Confirma a Baixa da Caução?",{"Sim","Nao"} ) <> 1
			lRet := .F.
		EndIf
		lCaucDinhe := .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ valor do resgate quando a caução for em dinheiro           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	
	If lCaucDinhe
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a Tela ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
//		DEFINE MSDIALOG oDlg TITLE STR0037 FROM 0,0 TO 280, 360 OF oMainWnd PIXEL // "Baixa da caucao"
		DEFINE MSDIALOG oDlg TITLE "Baixa da Caução" FROM 0,0 TO 280, 360 OF oMainWnd PIXEL // "Baixa da Caução"
		
		DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
		
		@  0, -25 BITMAP oBmp RESNAME "PROJETOAP" oF oDlg SIZE 55, 1000 NOBORDER WHEN .F. PIXEL
		
//		@ 03, 40 SAY STR0037 FONT oBold PIXEL // "Baixa da caucao"
		@ 03, 40 SAY "Baixa da Caução" FONT oBold PIXEL // "Baixa da caucao"
		
		@ 14, 30 TO 16 ,400 LABEL '' OF oDlg   PIXEL
		
//		@ 30, 40 Say STR0038 Size 80,8 PIXEL // "Digite o Valor Total do Resgate"
		@ 30, 40 Say "Digite o Valor Total do Resgate" Size 80,8 PIXEL // "Digite o Valor Total do Resgate"
		
//		@ 45,  40 Say STR0039 Size 60,8 PIXEL // "Código da Caução :"
		@ 45,  40 Say "Código da Caução :" Size 60,8 PIXEL // "Código da Caução :"
		@ 45, 100 MsGet CN8->CN8_CODIGO SIZE 55,8 WHEN .F. PIXEL
		
//		@ 60,  40 Say STR0040 Size 60,8 PIXEL // "Valor Efetivo :"
		@ 60,  40 Say "Valor Efetivo :" Size 60,8 PIXEL // "Valor Efetivo :"
		@ 60, 100 MsGet CN8->CN8_VLEFET Picture cPicValor SIZE 55,8 WHEN .F. PIXEL
		
//		@ 75,  40 Say STR0041 Size 60,8 PIXEL // "Valor do Resgate :"
		@ 75,  40 Say "Valor do Resgate :" Size 60,8 PIXEL // "Valor do Resgate :"
		@ 75, 100 MsGet nValorResg Picture cPicValor Valid CN090VlBaix() SIZE 55,8 WHEN .T. PIXEL
		
//		@ 90,  40 Say STR0042 Size 60,8 Of oDlg PIXEL // "Valor dos Juros :"
		@ 90,  40 Say "Valor dos Juros :" Size 60,8 Of oDlg PIXEL // "Valor dos Juros :"
		@ 90, 100 MsGet nValorJur Picture cPicValor SIZE 55,8 WHEN .F. PIXEL
		
//		DEFINE SBUTTON FROM 110,090 TYPE 1 ACTION (nOpcA := 1,If( Aviso( STR0026, STR0034, { STR0035, STR0036 } )==1,; // "Atencao", "Confirma a Baixa da Caução?", Sim","Nao"
		DEFINE SBUTTON FROM 110,090 TYPE 1 ACTION (nOpcA := 1,If( Aviso( "Atencao", "Confirma a Baixa da Caução?", {"Sim","Nao"} )==1,;
		oDlg:End(), nOpcA:=0)) ENABLE OF oDlg
		DEFINE SBUTTON FROM 110,125 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
		
		ACTIVATE MSDIALOG oDlg CENTERED
		
		If nOpcA ==  1
			
			Begin Transaction
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gera Titulo a Pagar/Receber para o total baixado           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    
//	      Processa({|| lRet := CN090GrPgto(CN8->CN8_VLEFET, nValorJur)},,If(!Empty(CN8->CN8_CLIENT),STR0044,STR0055)) // "Gerando Titulo a Pagar..."##"Gerando Titulo a Receber..."
	      Processa({|| lRet := CN090GrPgto(CN8->CN8_VLEFET, nValorJur)},,If(!Empty(CN8->CN8_CLIENT),"Gerando Titulo a Pagar...","Gerando Titulo a Receber...")) // "Gerando Titulo a Pagar..."##"Gerando Titulo a Receber..."
			
			If lRet
				If nValorJur > 0
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gera a Movimentacao Bancaria de Entrada para os Juros      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//					Processa({|| CN090MvEntr(nValorJur,NIL,.T.)},,STR0043) // "Gerando Movimento de Juros..."
					Processa({|| CN090MvEntr(nValorJur,NIL,.T.)},,"Gerando Movimento de Juros...") // "Gerando Movimento de Juros..."
				EndIf
							
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ baixa a caucao                                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("CN8")
				dbSetOrder(1)
				RecLock("CN8",.F.)
				CN8->CN8_DTBX := dDataBase
				CN8->CN8_VLBX := nValorResg
				MsUnlock()
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ contabilizar baixa caucao                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				CN090Contab(3)
				
				If (__lSX8)
					ConfirmSX8()
				EndIf
				EvalTrigger()
			EndIf
			
			End Transaction
			
		Else
			lRet := .F.
		EndIf
	EndIf
	
	If lRet .And. !lCaucDinhe
		
		Begin transaction
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ baixa a caucao                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("CN8")
		dbSetOrder(1)
		RecLock("CN8",.F.)
		CN8->CN8_DTBX := dDataBase
		CN8->CN8_VLBX := nValorResg
		MsUnlock()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ contabilizar baixa caucao                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		CN090Contab(3)
		
		End transaction
		
	EndIf
	
EndIf

return( lRet )
