#include "Protheus.ch"       

//#include "FIN.ch"   
//#INCLUDE "SET.CH"

// Define tamanho de 8 posicoes para os campos de Lote Financeiro
#DEFINE N_TAM_LOTE		8
#DEFINE FIN_LAST_UPDATED 		"03/08/2017"
#DEFINE X3_USADO_EMUSO 			"€€€€€€€€€€€€€€ "
#DEFINE X3_USADO_NAOUSADO 		"€€€€€€€€€€€€€€€" 
#DEFINE X3_USADO_OBRIGATO 		"€€€€€€€€€€€€€€°"   
#DEFINE X3_USADONAOOBRIG 		"‚À"   
#DEFINE X3_NAOOBRIGAT 			"Á€" 
#DEFINE X3_RESER 			    "þÀ" 
#DEFINE X3_RESEROBRIG 			"ƒ€"  
#DEFINE X3_RESER_NUMERICO 		"øÇ" 
#DEFINE X3_RES					"€"
#DEFINE X3_RES_NUM_TAMANHO		"š€"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ UPDBK07   º Autor ³ TOTVS Protheus     º Data ³ 06/06/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de update dos dicionários para compatibilização     ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ UPDBK07     - SZP Ocorrencias / SZQ Planos de ação         ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function UPDBK07()

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "Atualização de Dicionários de Dados"
Local   cDesc1    := "Esta rotina tem como função fazer  a atualização  dos dicionários de Dados do Sistema     "
Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja não podem haver outros        "
Local   cDesc3    := "  usuários  ou  jobs utilizando  o sistema.  É extremamente recomendavél  que  se  faça um"
Local   cDesc4    := "  BACKUP  dos DICIONÁRIOS  e da  BASE DE DADOS antes desta atualização.                   "
Local   cDesc5    := "** Atualização " + FIN_LAST_UPDATED
Local   cDesc6    := ""
Local   cDesc7    := ""
Local   lOk       := .F.

Private oMainWnd  := NIL
Private oProcess  := NIL

#IFDEF TOP
    TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
#ENDIF

__cInterNet := NIL
__lPYME     := .F.

Set Dele On

// Mensagens de Tela Inicial
aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
aAdd( aSay, cDesc4 )
aAdd( aSay, "     ")
aAdd( aSay, cDesc5 )

// Botoes Tela Inicial
aAdd(  aButton, {  1, .T., { || lOk := .T., FechaBatch() } } )
aAdd(  aButton, {  2, .T., { || lOk := .F., FechaBatch() } } )

FormBatch(  cTitulo,  aSay,  aButton )

If lOk
	aMarcadas := EscEmpresa()

	If !Empty( aMarcadas )
		If  MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lOk
				Final( "Atualização Concluída." )
			Else
				Final( "Atualização não Realizada." )
			EndIf

		Else
			MsgStop( "Atualização não Realizada.", "UPDBK01" )

		EndIf

	Else
		MsgStop( "Atualização não Realizada.", "UPDBK01" )

	EndIf

EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FSTProc  º Autor ³ TOTVS Protheus     º Data ³  14/09/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento da gravação dos arquivos           ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ FSTProc    - Gerado por EXPORDIC / Upd. V.4.7.2 EFS        ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FSTProc( lEnd, aMarcadas )
Local   aInfo     := {}
Local   aRecnoSM0 := {}
Local   cAux      := ""
Local   cFile     := ""
Local   cFileLog  := ""
Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
Local   nRecno    := 0
Local   nX        := 0
Local   oDlg      := NIL
Local   oFont     := NIL
Local   oMemo     := NIL

Private aArqUpd   := {}

If ( lOpen := MyOpenSm0(.T.) )

	dbSelectArea( "SM0" )
	dbGoTop()

	While !SM0->( EOF() )
		// So adiciona no aRecnoSM0 se a empresa for diferente
		If aScan( aRecnoSM0, { |x| x[2] == SM0->M0_CODIGO } ) == 0 ;
		   .AND. aScan( aMarcadas, { |x| x[1] == SM0->M0_CODIGO } ) > 0
			aAdd( aRecnoSM0, { Recno(), SM0->M0_CODIGO } )
		EndIf
		SM0->( dbSkip() )
	End

	SM0->( dbCloseArea() )

	If lOpen

		For nI := 1 To Len( aRecnoSM0 )

			If !( lOpen := MyOpenSm0(.F.) )
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF + CRLF

			oProcess:SetRegua1( 8 )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o dicionário SX2         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oProcess:IncRegua1( "Dicionário de arquivos - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FinAtuSX2( @cTexto )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o dicionário SX3         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			FinAtuSX3( @cTexto )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o dicionário SIX         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oProcess:IncRegua1( "Dicionário de índices - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FinAtuSIX( @cTexto )

			oProcess:IncRegua1( "Dicionário de dados - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

			// Alteracao fisica dos arquivos
			__SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					cTexto += "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] + CRLF
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o dicionário SX6         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oProcess:IncRegua1( "Dicionário de parâmetros - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FinAtuSX6( @cTexto )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o dicionário SX7         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oProcess:IncRegua1( "Dicionário de gatilhos - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FinAtuSX7( @cTexto )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o dicionário SXA         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oProcess:IncRegua1( "Dicionário de pastas - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FinAtuSXA( @cTexto )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o dicionário SXB         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oProcess:IncRegua1( "Dicionário de consultas padrão - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FinAtuSXB( @cTexto )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o dicionário SX5         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oProcess:IncRegua1( "Dicionário de tabelas sistema - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FinAtuSX5( @cTexto )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o dicionário SX9         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oProcess:IncRegua1( "Dicionário de relacionamentos - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FinAtuSX9( @cTexto )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza o dicionário SX1         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oProcess:IncRegua1( "Dicionário de perguntas - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FinAtuSX1( @cTexto )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Atualiza os helps                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oProcess:IncRegua1( "Helps de Campo - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			FinAtuHlp( @cTexto )
			FinAtuHlpX1( @cTexto )


			cAux += Replicate( "-", 128 ) + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += "LOG DA ATUALIZACAO DOS DICIONÁRIOS" + CRLF
			cAux += Replicate( " ", 128 ) + CRLF
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF
			cAux += " Dados Ambiente" + CRLF
			cAux += " --------------------"  + CRLF
			cAux += " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt  + CRLF
			cAux += " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
			cAux += " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) + CRLF
			cAux += " DataBase...........: " + DtoC( dDataBase )  + CRLF
			cAux += " Data / Hora Inicio.: " + DtoC( Date() )  + " / " + Time()  + CRLF
			cAux += " Environment........: " + GetEnvServer()  + CRLF
			cAux += " StartPath..........: " + GetSrvProfString( "StartPath", "" )  + CRLF
			cAux += " RootPath...........: " + GetSrvProfString( "RootPath" , "" )  + CRLF
			cAux += " Versao.............: " + GetVersao(.T.)  + CRLF
			cAux += " Usuario TOTVS .....: " + __cUserId + " " +  cUserName + CRLF
			cAux += " Computer Name......: " + GetComputerName() + CRLF

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				cAux += " "  + CRLF
				cAux += " Dados Thread" + CRLF
				cAux += " --------------------"  + CRLF
				cAux += " Usuario da Rede....: " + aInfo[nPos][1] + CRLF
				cAux += " Estacao............: " + aInfo[nPos][2] + CRLF
				cAux += " Programa Inicial...: " + aInfo[nPos][5] + CRLF
				cAux += " Environment........: " + aInfo[nPos][6] + CRLF
				cAux += " Conexao............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) )  + CRLF
			EndIf

			
			RpcClearEnv()

		Next nI

		If MyOpenSm0(.T.)
		
			cAux += Replicate( "-", 128 ) + CRLF
			cAux += CRLF
			
			cTexto := cAux + cTexto + CRLF
			cTexto += Replicate( "-", 128 ) + CRLF
			cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
			cTexto += Replicate( "-", 128 ) + CRLF
			
			cFileLog := MemoWrite( CriaTrab( , .F. ) + ".log", cTexto )

			Define Font oFont Name "Mono AS" Size 5, 12

			Define MsDialog oDlg Title "Atualizacao concluida." From 3, 0 to 340, 417 Pixel

			@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
			oMemo:bRClicked := { || AllwaysTrue() }
			oMemo:oFont     := oFont

			Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
			Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
			MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

			Activate MsDialog oDlg Center

		EndIf

	EndIf

Else

	lRet := .F.

EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FintuSX2 º Autor ³ Jose.Gavetti       º Data ³  10/07/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento da gravacao do SX2 - Arquivos      ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ FinAtuSX2   -                                              ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinAtuSX2( cTexto )
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0
Local nCamp	  := 0

cTexto  += "Inicio da Atualizacao" + " SX2" + CRLF + CRLF

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"  , "X2_NOMESPA", "X2_NOMEENG", ;
             "X2_DELET"  , "X2_MODO"   , "X2_TTS"    , "X2_ROTINA", "X2_PYME"   , "X2_UNICO"  , ;
             "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }

dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )


//
// Tabela SZO
//
aAdd( aSX2, {'SZP',cPath,'SZP'+cEmpr,'OCORRENCIAS CONTRATO','OCORRENCIAS CONTRATO','OCORRENCIAS CONTRATO',0,'C','','','S','','E','E'} )
aAdd( aSX2, {'SZQ',cPath,'SZQ'+cEmpr,'PLANOS DE AÇÃO CONTRATO','PLANOS DE AÇÃO CONTRATO','PLANOS DE AÇÃO CONTRATO',0,'C','','','S','','E','E'} )


//aadd(aSX2, {"FJU","","FJU990","Grava Titulos Excluidos","Escribe Título Excluidos","Writes Title Excluded",0,"E","N"," ","S","FJU_FILIAL+FJU_CART+STR(FJU_RECORI)","E","E"})

//
// Tabela FR4
//
//aAdd( aSX2, {'FR4',cPath,'FR4'+cEmpr,'Apuracao IRPJ/CSLL Lucro Real','Calculo IRPJ/CSLLGanancia Real','Calc IRPJ/CSLL Accompl Profit',0,'E','','','S','FR4_FILIAL+FR4_CODAPU','E','E',6} )
//
// Tabela FR5
//
//aAdd( aSX2, {'FR5',cPath,'FR5'+cEmpr,'Componente Apuracao IRPJ/CSLL','Componente Calculo IRPJ/CSLL','Calc Component IRPJ/CSLL',0,'E','','','S','FR5_FILIAL+FR5_CODAPU+FR5_TIPO+FR5_ITEM+FR5_ENTID','E','E',6} )
//
// Tabela FR6
//
//aAdd( aSX2, {'FR6',cPath,'FR6'+cEmpr,'Titulos da Apuração','Titulos de Calculo','Calculation Documents',0,'E','','','S','FR6_FILIAL+FR6_CODAPU+FR6_ITEM','E','E',6} )
//
// Tabela FR6
//



oProcess:SetRegua2( Len( aSX2 ) )

//FINUpdField("SX2", 1, "FJU", "X2_UNICO", "FJU_FILIAL+FJU_CART+STR(FJU_RECORI)")

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2)..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			cTexto += "Foi incluída a tabela " + aSX2[nI][1] + CRLF
		EndIf

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
				cTexto += "Foi alterada chave unica da tabela " + aSX2[nI][1] + CRLF
			Else
				cTexto += "Foi criada   chave unica da tabela " + aSX2[nI][1] + CRLF
			EndIf
		EndIf

	EndIf

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return aClone( aSX2 )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FintuSX3 º Autor ³ Jose.Gavetti       º Data ³  10/07/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento da gravacao do SX3 - Campos        ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ FinAtuSX3                                                  ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinAtuSX3( cTexto )
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cMsg      := ""
Local cSeqAtu   := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nSeqAtu   := 0
Local aPHelpPor := {}
Local aPHelpEng := {}
Local aPHelpSpa := {} 
Local nTamSeek  := Len( SX3->X3_CAMPO )
Local nTamFor 	:= FinTamSXG("001",TAMSX3("E2_FORNECE")[1])[1]
Local nTamLj  	:= FinTamSXG("002",TAMSX3("E2_LOJA")[1])[1]
Local nTamFil 	:= FinTamSXG("033",TAMSX3("E2_FILIAL")[1])[1]
Local nTamParc	:= FinTamSXG("011",TAMSX3("E2_PARCELA")[1])[1]
Local nTamTit 	:= FinTamSXG("018",TAMSX3("E2_NUM")[1])[1]
Local nTamPref 	:= TAMSX3("E2_PREFIXO")[1]
Local nTamEmis 	:= TAMSX3("E2_EMISSAO")[1]
Local nTamVal	   	:= TAMSX3("E2_VALOR")[1]
Local nTamTipo	:= TAMSX3("E2_TIPO")[1]
Local nTamVRea	:= TAMSX3("E2_VENCREA")[1]
Local nTamLA		:= TAMSX3("E2_LA")[1]
Local nTamMoed	:= TAMSX3("E2_MOEDA")[1]
Local nTamHist	:= TAMSX3("E2_HIST")[1]
Local nTamTitPai 	:= TAMSX3("E2_TITPAI")[1]
Local nTamCtr   := TAMSX3("CN9_NUMERO")[1]


cTexto  += "Inicio da Atualizacao" + " SX3" + CRLF + CRLF

//--------------------------------------------------------------
// Estrutura dos campos
//--------------------------------------------------------------
aEstrut := { "X3_ARQUIVO", "X3_ORDEM"  , "X3_CAMPO"  , "X3_TIPO"   , "X3_TAMANHO", "X3_DECIMAL", ;
             "X3_TITULO" , "X3_TITSPA" , "X3_TITENG" , "X3_DESCRIC", "X3_DESCSPA", "X3_DESCENG", ;
             "X3_PICTURE", "X3_VALID"  , "X3_USADO"  , "X3_RELACAO", "X3_F3"     , "X3_NIVEL"  , ;
             "X3_RESERV" , "X3_CHECK"  , "X3_TRIGGER", "X3_PROPRI" , "X3_BROWSE" , "X3_VISUAL" , ;
             "X3_CONTEXT", "X3_OBRIGAT", "X3_VLDUSER", "X3_CBOX"   , "X3_CBOXSPA", "X3_CBOXENG", ;
             "X3_PICTVAR", "X3_WHEN"   , "X3_INIBRW" , "X3_GRPSXG" , "X3_FOLDER" , "X3_PYME"   }


Aadd(aSX3,{"SZP",; 					// "X3_ARQUIVO"
			"01",;					// "X3_ORDEM"  
			"ZP_FILIAL",;           // "X3_CAMPO"
			"C" ,;                  // "X3_TIPO"
			nTamFil,;               // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Filial",;              // "X3_TITULO"
			"Sucursal",;            // "X3_TITSPA" 
			"Branch",;              // "X3_TITENG"
			"Filial do sistema",;   // "X3_DESCRIC"
			"Sucursal de Sistema",; // "X3_DESCSPA"
			"Branch of System",;    // "X3_DESCENG"
			"@!",;                  // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_NAOUSADO,;     // "X3_USADO"
			"",;                    // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			"š€" ,;                 // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"S",;                   // "X3_PROPRI"
			"N",;                   // "X3_BROWSE"
			" ",;                   // "X3_VISUAL" 
			" ",;                   // "X3_CONTEXT" 
			"",;                    // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"033",;                 // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"


Aadd(aSX3,{"SZP",; 					// "X3_ARQUIVO"
			"02",;					// "X3_ORDEM"  
			"ZP_CONTRAT",;          // "X3_CAMPO"
			"C" ,;                  // "X3_TIPO"
			nTamCtr,;               // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Contrato",;            // "X3_TITULO"
			"Contrato",;            // "X3_TITSPA" 
			"Contrato",;            // "X3_TITENG"
			"Contrato ",;           // "X3_DESCRIC"
			"Contrato ",;           // "X3_DESCSPA"
			"Contrato ",;           // "X3_DESCENG"
			"@!",;                  // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"cZPContrat",;          // "X3_RELACAO"
			"CN9",;                 // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			"",;                    // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			".F.",;                 // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"


Aadd(aSX3,{"SZP",; 					// "X3_ARQUIVO"
			"03",;					// "X3_ORDEM"  
			"ZP_SEQ" ,;             // "X3_CAMPO"
			"C" ,;                  // "X3_TIPO"
			4,;                     // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Sequência",;           // "X3_TITULO"
			"Sequência",;           // "X3_TITSPA" 
			"Sequência",;           // "X3_TITENG"
			"Sequência",;           // "X3_DESCRIC"
			"Sequência",;           // "X3_DESCSPA"
			"Sequência",;           // "X3_DESCENG"
			"9999",;                // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"cZPSeq",;              // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			"",;                    // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			".F.",;                 // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"


Aadd(aSX3,{"SZP",; 					// "X3_ARQUIVO"
			"04",;					// "X3_ORDEM"  
			"ZP_DATA"   ,;          // "X3_CAMPO"
			"D" ,;                  // "X3_TIPO"
			8  ,;                   // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Data"        ,;        // "X3_TITULO"
			"Data"        ,;        // "X3_TITSPA" 
			"Data	",;             // "X3_TITENG"
			"Data ocorrência" ,;    // "X3_DESCRIC"
			"Data ocorrência" ,;    // "X3_DESCSPA"
			"Data ocorrência" ,;    // "X3_DESCENG"
			"",;                    // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"dDataBase",;           // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			"",;                    // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			".F.",;                 // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"

Aadd(aSX3,{"SZP",; 					// "X3_ARQUIVO"
			"05",;					// "X3_ORDEM"  
			"ZP_OCORR",;            // "X3_CAMPO"
			"C" ,;                  // "X3_TIPO"
			100,;                   // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Ocorrência"   ,;       // "X3_TITULO"
			"Ocorrência"   ,;       // "X3_TITSPA" 
			"Ocorrência"   ,;       // "X3_TITENG"
			"Ocorrência"   ,;       // "X3_DESCRIC"
			"Ocorrência"   ,;       // "X3_DESCSPA"
			"Ocorrência"   ,;       // "X3_DESCENG"
			"@!",;                  // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"",;                    // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			X3_RES,;                // "X3_OBRIGAT"
			"",;                    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"


Aadd(aSX3,{"SZP",; 					// "X3_ARQUIVO"
			"06",;					// "X3_ORDEM"  
			"ZP_DETOCOR",;          // "X3_CAMPO"
			"M" ,;                  // "X3_TIPO"
			10	,;                  // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Det. Ocorr.",;         // "X3_TITULO"
			"Det. Ocorr.",;         // "X3_TITSPA" 
			"Det. Ocorr.",;         // "X3_TITENG"
			"Det. ocorrência" ,;    // "X3_DESCRIC"
			"Det. ocorrência" ,;    // "X3_DESCSPA"
			"Det. ocorrência" ,;    // "X3_DESCENG"
			"",;                    // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"",;                    // "X3_RELACAO"
			"",;                    // "X3_F3" 
			0,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"N",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			X3_RES,;                // "X3_OBRIGAT"
			"",;                    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"

Aadd(aSX3,{"SZP",; 					// "X3_ARQUIVO"
			"07",;					// "X3_ORDEM"  
			"ZP_QUEM",;             // "X3_CAMPO"
			"C" ,;                  // "X3_TIPO"
			06,;                    // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Responsavel ?"  ,;     // "X3_TITULO"
			"Responsavel ?"   ,;    // "X3_TITSPA" 
			"Responsavel ?"   ,;    // "X3_TITENG"
			"Responsavel ?"  ,;     // "X3_DESCRIC"
			"Responsavel ?"   ,;    // "X3_DESCSPA"
			"Responsavel ?"   ,;    // "X3_DESCENG"
			"@!",;                  // "X3_PICTURE"  
			"UsrExist(M->ZP_QUEM)",;// "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"RetCodUsr()",;         // "X3_RELACAO"
			"USA",;                 // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			X3_RES,;                // "X3_OBRIGAT"
			"U_ZPNQUEM()",;         // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"

Aadd(aSX3,{"SZP",; 					// "X3_ARQUIVO"
			"08",;					// "X3_ORDEM"  
			"ZP_NQUEM",;            // "X3_CAMPO"
			"C" ,;                  // "X3_TIPO"
			17,;                    // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Quem"   ,;             // "X3_TITULO"
			"Quem"   ,;             // "X3_TITSPA" 
			"Quem"   ,;             // "X3_TITENG"
			"Quem"   ,;             // "X3_DESCRIC"
			"Quem"   ,;             // "X3_DESCSPA"
			"Quem"   ,;             // "X3_DESCENG"
			"@!",;                  // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"",;                    // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"V",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			"",;                    // "X3_OBRIGAT"
			"",;                    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"


Aadd(aSX3,{"SZP",; 					// "X3_ARQUIVO"
			"09",;					// "X3_ORDEM"  
			"ZP_FINALIZ" ,;         // "X3_CAMPO"
			"C" ,;                  // "X3_TIPO"
			1  ,;                   // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Finalizada",;          // "X3_TITULO"
			"Finalizada",;          // "X3_TITSPA" 
			"Finalizada",;          // "X3_TITENG"
			"Finalizada",;          // "X3_DESCRIC"
			"Finalizada",;          // "X3_DESCSPA"
			"Finalizada",;          // "X3_DESCENG"
			"@!",;                  // "X3_PICTURE"  
			"Pertence('SN')",;      // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"'N'",;                 // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			X3_RES,;                // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"S=Sim;N=Nao",;         // "X3_CBOX"
			"S=Sim;N=Nao",;         // "X3_CBOXSPA"
			"S=Sim;N=Nao",;         // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;              		// "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"

Aadd(aSX3,{"SZP",; 					// "X3_ARQUIVO"
			"10",;					// "X3_ORDEM"  
			"ZP_DATAPRV",;          // "X3_CAMPO"
			"D" ,;                  // "X3_TIPO"
			8  ,;                   // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Previsão",;            // "X3_TITULO"
			"Previsão",;            // "X3_TITSPA" 
			"Previsão",;            // "X3_TITENG"
			"Previsão",;            // "X3_DESCRIC"
			"Previsão",;            // "X3_DESCSPA"
			"Previsão",;            // "X3_DESCENG"
			"",;                    // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"",;                    // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			X3_RES,;                // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"



Aadd(aSX3,{"SZP",; 					// "X3_ARQUIVO"
			"11",;					// "X3_ORDEM"  
			"ZP_USERLGA",;          // "X3_CAMPO"
			"C",;                   // "X3_TIPO"
			17,;                    // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Log de Alter",;        // "X3_TITULO"
			"Log de Alter",;        // "X3_TITSPA" 
			"Log de Alter",;        // "X3_TITENG"
			"Log de Alteracao",;    // "X3_DESCRIC"
			"Log de Alteracao",;    // "X3_DESCSPA"
			"Log de Alteracao",;    // "X3_DESCENG"
			"",;                    // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"",;                    // "X3_RELACAO"
			"",;                    // "X3_F3" 
			9,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"L",;                   // "X3_PROPRI"
			"N",;                   // "X3_BROWSE"
			"V",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			"",;                    // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"

Aadd(aSX3,{"SZP",; 					// "X3_ARQUIVO"
			"13",;					// "X3_ORDEM"  
			"ZP_DESCCON",;          // "X3_CAMPO"
			"C",;                   // "X3_TIPO"
			40,;                    // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Desc.Contrat",;        // "X3_TITULO"
			"Desc.Contrat",;        // "X3_TITSPA" 
			"Desc.Contrat",;        // "X3_TITENG"
			"Desc.Contrat",;        // "X3_DESCRIC"
			"Desc.Contrat",;        // "X3_DESCSPA"
			"Desc.Contrat",;        // "X3_DESCENG"
			"@!",;                  // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			'POSICIONE("CN9",1,XFILIAL("CN9")+M->ZP_CONTRAT,"CN9_XXDESC")',;// "X3_RELACAO"
			"",;                    // "X3_F3" 
			0,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"V",;                   // "X3_VISUAL" 
			"V",;                   // "X3_CONTEXT" 
			"",;                    // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			".F.",;                 // "X3_WHEN" 
			'POSICIONE("CN9",1,XFILIAL("CN9")+SZP->ZP_CONTRAT,"CN9_XXDESC")',; // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"


Aadd(aSX3,{"SZP",; 					// "X3_ARQUIVO"
			"12",;					// "X3_ORDEM"  
			"ZP_USER",;             // "X3_CAMPO"
			"C",;                   // "X3_TIPO"
			17,;                    // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Usuário",;             // "X3_TITULO"
			"Usuário",;             // "X3_TITSPA" 
			"Usuário",;             // "X3_TITENG"
			"Usuário",;             // "X3_DESCRIC"
			"Usuário",;             // "X3_DESCSPA"
			"Usuário",;             // "X3_DESCENG"
			"",;                    // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			'cUserName',;           // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"L",;                   // "X3_PROPRI"
			"N",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			"",;                    // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			".F.",;                 // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"



Aadd(aSX3,{"SZQ",; 					// "X3_ARQUIVO"
			"01",;					// "X3_ORDEM"  
			"ZQ_FILIAL",;           // "X3_CAMPO"
			"C" ,;                  // "X3_TIPO"
			nTamFil,;               // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Filial",;              // "X3_TITULO"
			"Sucursal",;            // "X3_TITSPA" 
			"Branch",;              // "X3_TITENG"
			"Filial do sistema",;   // "X3_DESCRIC"
			"Sucursal de Sistema",; // "X3_DESCSPA"
			"Branch of System",;    // "X3_DESCENG"
			"@!",;                  // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_NAOUSADO,;     // "X3_USADO"
			"",;                    // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			"š€" ,;                 // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"S",;                   // "X3_PROPRI"
			"N",;                   // "X3_BROWSE"
			" ",;                   // "X3_VISUAL" 
			" ",;                   // "X3_CONTEXT" 
			"",;                    // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"033",;                 // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"


Aadd(aSX3,{"SZQ",; 					// "X3_ARQUIVO"
			"02",;					// "X3_ORDEM"  
			"ZQ_CONTRAT",;          // "X3_CAMPO"
			"C" ,;                  // "X3_TIPO"
			nTamCtr,;               // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Contrat",;             // "X3_TITULO"
			"Contrat",;             // "X3_TITSPA" 
			"Contrat",;             // "X3_TITENG"
			"Contrato ",;           // "X3_DESCRIC"
			"Contrato ",;           // "X3_DESCSPA"
			"Contrato ",;           // "X3_DESCENG"
			"@!",;                  // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"cZQContrat",;          // "X3_RELACAO"
			"CN9",;                 // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			X3_RES,;                // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			".F.",;                 // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"


Aadd(aSX3,{"SZQ",; 					// "X3_ARQUIVO"
			"03",;					// "X3_ORDEM"  
			"ZQ_SEQ" ,;             // "X3_CAMPO"
			"C" ,;                  // "X3_TIPO"
			4,;                     // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Sequência",;           // "X3_TITULO"
			"Sequência",;           // "X3_TITSPA" 
			"Sequência",;           // "X3_TITENG"
			"Sequência",;           // "X3_DESCRIC"
			"Sequência",;           // "X3_DESCSPA"
			"Sequência",;           // "X3_DESCENG"
			"9999",;                // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"cZQSeq",;              // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			X3_RES,;                // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			".F.",;                 // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"

Aadd(aSX3,{"SZQ",; 					// "X3_ARQUIVO"
			"04",;					// "X3_ORDEM"  
			"ZQ_ITEM",;             // "X3_CAMPO"
			"C" ,;                  // "X3_TIPO"
			4,;                     // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Item",;                // "X3_TITULO"
			"Item",;                // "X3_TITSPA" 
			"Item",;                // "X3_TITENG"
			"Item",;                // "X3_DESCRIC"
			"Item",;                // "X3_DESCSPA"
			"Item",;                // "X3_DESCENG"
			"9999",;                // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"cZQItem",;             // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			X3_RES,;                // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			".F.",;                 // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"

Aadd(aSX3,{"SZQ",; 					// "X3_ARQUIVO"
			"05",;					// "X3_ORDEM"  
			"ZQ_DATA"   ,;          // "X3_CAMPO"
			"D" ,;                  // "X3_TIPO"
			8  ,;                   // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Data"        ,;        // "X3_TITULO"
			"Data"        ,;        // "X3_TITSPA" 
			"Data	",;             // "X3_TITENG"
			"Data ocorrência" ,;    // "X3_DESCRIC"
			"Data ocorrência" ,;    // "X3_DESCSPA"
			"Data ocorrência" ,;    // "X3_DESCENG"
			"",;                    // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"dDataBase",;           // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			X3_RES,;                // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"

Aadd(aSX3,{"SZQ",; 					// "X3_ARQUIVO"
			"06",;					// "X3_ORDEM"  
			"ZQ_OQUE",;             // "X3_CAMPO"
			"C" ,;                  // "X3_TIPO"
			100,;                   // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"O que?",;              // "X3_TITULO"
			"O que?",;              // "X3_TITSPA" 
			"O que?",;              // "X3_TITENG"
			"O que?",;              // "X3_DESCRIC"
			"O que?",;              // "X3_DESCSPA"
			"O que?",;              // "X3_DESCENG"
			"@!",;                  // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"",;                    // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			X3_RES,;                // "X3_OBRIGAT"
			"",;                    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"

Aadd(aSX3,{"SZQ",; 					// "X3_ARQUIVO"
			"07",;					// "X3_ORDEM"  
			"ZQ_PORQUE",;           // "X3_CAMPO"
			"C" ,;                  // "X3_TIPO"
			100,;                   // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Porque?",;             // "X3_TITULO"
			"Porque?",;             // "X3_TITSPA" 
			"Porque?",;             // "X3_TITENG"
			"Porque?",;             // "X3_DESCRIC"
			"Porque?",;             // "X3_DESCSPA"
			"Porque?",;             // "X3_DESCENG"
			"@!",;                  // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"",;                    // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			X3_RES,;                // "X3_OBRIGAT"
			"",;                    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"


Aadd(aSX3,{"SZQ",; 					// "X3_ARQUIVO"
			"08",;					// "X3_ORDEM"  
			"ZQ_QUANDO" ,;          // "X3_CAMPO"
			"D" ,;                  // "X3_TIPO"
			8  ,;                   // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Quando?",;             // "X3_TITULO"
			"Quando?",;             // "X3_TITSPA" 
			"Quando?",;             // "X3_TITENG"
			"Quando?",;             // "X3_DESCRIC"
			"Quando?",;             // "X3_DESCSPA"
			"Quando?",;             // "X3_DESCENG"
			"",;                    // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"",;                    // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			X3_RES,;                // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"

Aadd(aSX3,{"SZQ",; 					// "X3_ARQUIVO"
			"09",;					// "X3_ORDEM"  
			"ZQ_ONDE",;             // "X3_CAMPO"
			"C" ,;                  // "X3_TIPO"
			050,;                   // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Onde?",;               // "X3_TITULO"
			"Onde?",;               // "X3_TITSPA" 
			"Onde?",;               // "X3_TITENG"
			"Onde?",;               // "X3_DESCRIC"
			"Onde?",;               // "X3_DESCSPA"
			"Onde?",;               // "X3_DESCENG"
			"@!",;                  // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"",;                    // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			X3_RES,;                // "X3_OBRIGAT"
			"",;                    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"

Aadd(aSX3,{"SZQ",; 					// "X3_ARQUIVO"
			"10",;					// "X3_ORDEM"  
			"ZQ_QUANTO" ,;          // "X3_CAMPO"
			"N" ,;                  // "X3_TIPO"
			14,;                    // "X3_TAMANHO"
			2,;                     // "X3_DECIMAL"
			"Quanto?",;             // "X3_TITULO"
			"Quanto?",;             // "X3_TITSPA" 
			"Quanto?",;             // "X3_TITENG"
			"Quanto?",;             // "X3_DESCRIC"
			"Quanto?",;             // "X3_DESCSPA"
			"Quanto?",;             // "X3_DESCENG"
			"@E 999,999,999.99",;   // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"",;                    // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			"",;                    // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"

Aadd(aSX3,{"SZQ",; 					// "X3_ARQUIVO"
			"11",;					// "X3_ORDEM"  
			"ZQ_FINALIZ" ,;         // "X3_CAMPO"
			"C" ,;                  // "X3_TIPO"
			1  ,;                   // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Finalizada",;          // "X3_TITULO"
			"Finalizada",;          // "X3_TITSPA" 
			"Finalizada",;          // "X3_TITENG"
			"Finalizada",;          // "X3_DESCRIC"
			"Finalizada",;          // "X3_DESCSPA"
			"Finalizada",;          // "X3_DESCENG"
			"@!",;                  // "X3_PICTURE"  
			"Pertence('SN')",;      // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"'N'",;                 // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			X3_RES,;                // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"S=Sim;N=Nao",;         // "X3_CBOX"
			"S=Sim;N=Nao",;         // "X3_CBOXSPA"
			"S=Sim;N=Nao",;         // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"

Aadd(aSX3,{"SZQ",; 					// "X3_ARQUIVO"
			"12",;					// "X3_ORDEM"  
			"ZQ_RESULT",;           // "X3_CAMPO"
			"M" ,;                  // "X3_TIPO"
			10	,;                  // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Resultado",;           // "X3_TITULO"
			"Resultado",;           // "X3_TITSPA" 
			"Resultado",;           // "X3_TITENG"
			"Resultado",;           // "X3_DESCRIC"
			"Resultado",;           // "X3_DESCSPA"
			"Resultado",;           // "X3_DESCENG"
			"",;                    // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"",;                    // "X3_RELACAO"
			"",;                    // "X3_F3" 
			0,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"U",;                   // "X3_PROPRI"
			"N",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			"",;                    // "X3_OBRIGAT"
			"",;                    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"

Aadd(aSX3,{"SZQ",; 					// "X3_ARQUIVO"
			"13",;					// "X3_ORDEM"  
			"ZQ_USERLGA",;          // "X3_CAMPO"
			"C",;                   // "X3_TIPO"
			17,;                    // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Log de Alter",;        // "X3_TITULO"
			"Log de Alter",;        // "X3_TITSPA" 
			"Log de Alter",;        // "X3_TITENG"
			"Log de Alteracao",;    // "X3_DESCRIC"
			"Log de Alteracao",;    // "X3_DESCSPA"
			"Log de Alteracao",;    // "X3_DESCENG"
			"",;                    // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			"",;                    // "X3_RELACAO"
			"",;                    // "X3_F3" 
			9,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"L",;                   // "X3_PROPRI"
			"S",;                   // "X3_BROWSE"
			"V",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			"",;                    // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			"",;                    // "X3_WHEN" 
			'FWLeUserlg("ZQ_USERLGA", 1)',;  // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"

Aadd(aSX3,{"SZQ",; 					// "X3_ARQUIVO"
			"14",;					// "X3_ORDEM"  
			"ZQ_USER",;             // "X3_CAMPO"
			"C",;                   // "X3_TIPO"
			17,;                    // "X3_TAMANHO"
			0,;                     // "X3_DECIMAL"
			"Usuário",;             // "X3_TITULO"
			"Usuário",;             // "X3_TITSPA" 
			"Usuário",;             // "X3_TITENG"
			"Usuário",;             // "X3_DESCRIC"
			"Usuário",;             // "X3_DESCSPA"
			"Usuário",;             // "X3_DESCENG"
			"",;                    // "X3_PICTURE"  
			"",;                    // "X3_VALID" 
			X3_USADO_EMUSO,;        // "X3_USADO"
			'cUserName',;           // "X3_RELACAO"
			"",;                    // "X3_F3" 
			1,;                     // "X3_NIVEL"
			X3_RESER,;              // "X3_RESERV"
			"",;                    // "X3_CHECK"
			"",;                    // "X3_TRIGGER"
			"L",;                   // "X3_PROPRI"
			"N",;                   // "X3_BROWSE"
			"A",;                   // "X3_VISUAL" 
			"R",;                   // "X3_CONTEXT" 
			"",;                    // "X3_OBRIGAT"
			"",;				    // "X3_VLDUSER"
			"",;                    // "X3_CBOX"
			"",;                    // "X3_CBOXSPA"
			"",;                    // "X3_CBOXENG"
			"",;                    // "X3_PICTVAR" 
			".F.",;                 // "X3_WHEN" 
			"",;                    // "X3_INIBRW" 
			"",;                    // "X3_GRPSXG"
			"",;                    // "X3_FOLDER"
			""})                    // "X3_PYME"

/*
// Tabela FJU

Aadd(aSX3,{"FJU" ,"01" ,"FJU_FILIAL"	,"C" , nTamFil ,         0, "Filial"		    ,"Sucursal" 	    	, "branch"           , "Filial do sistema "  , "Sucursal de Sistema "        , "Branch of System      " , "@!"  						, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,"033","","S"})
Aadd(aSX3,{"FJU" ,"02" ,"FJU_PREFIX"	,"C" , nTamPref ,        0, "Prefixo"		    ,"Prefijo" 	    	, "Prefix"           , "Prefixo do titulo "  , "Prefijo del Titulo "        , "Bill Prefix       " , "@!"  						, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,"","","S"})
Aadd(aSX3,{"FJU" ,"03" ,"FJU_NUM"		,"C" , nTamTit ,         0, "Numero"		    ,"Num. Titulo" 	    , "Number"           , "Numero do titulo "  , "Numero del Titulo    "        , "Bill Number      " , "@!"  						, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,"018","","S"})
Aadd(aSX3,{"FJU" ,"04" ,"FJU_PARCEL"	,"C" , nTamParc ,        0, "Parcela"		    ,"Cuota" 	    		, "Installment"           , "Parcela do titulo "  , "Cuota del Titulo "        , "Bill Installment        " , "@!"  						, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,"011","","S"})
Aadd(aSX3,{"FJU" ,"05" ,"FJU_CLIFOR"	,"C" , nTamFor ,         0,"Cli/For"			,"Clien/Provee"		,"Cust./Sup."				,"Codigo Cliente/Fornecedor"	,"Codigo Cliente/Proveedor "	,"Cust./Supplier Code"		,"@!                  ","fA100CliFor()"			,X3_USADO_EMUSO,"","",1,X3_USADONAOOBRIG,"",""," ","N","A","R"," ","","","","","","","","001","","S"}) 
Aadd(aSX3,{"FJU" ,"06" ,"FJU_LOJA"	    ,"C" , nTamLj ,          0, "Loja"		       ,"Tienda" 	        	, "Unit"           		, "Loja do Cli/For "  , "Tienda del Proveedor/Clie"        		, "Supplier/Customer´s" , "@!"  				, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,"002","","S"})
Aadd(aSX3,{"FJU" ,"07" ,"FJU_CART"	    ,"C" , 02 ,              0, "Carteira"		,"Titulo" 	    		, "Title"           		, "Carteira do titulo "  , "Titulo para reposicion"        	, "Bill for replacement" , "@!"  					, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,""  ,"","S"})
Aadd(aSX3,{"FJU" ,"08" ,"FJU_EMIS"	    ,"D" , nTamEmis ,        0, "Emissao"		    ,"Fch Emision" 	    , "issue Date"           		, " Data de emissao do tit"  , "Fecha de Emision del Tit. "        	, "Bill Issue Date" , ""  					, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,""  ,"","S"})
Aadd(aSX3,{"FJU" ,"09" ,"FJU_DTEXCL"	 ,"D" , nTamEmis ,        0, "Exclusao"		,"Exclusión" 	        , "Deleting"           		, " Data da exclusão do tit"  , "Fecha de borrar del tit. "        	, "Date of deleting the tit" , ""  					, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,""  ,"","S"})
Aadd(aSX3,{"FJU" ,"10" ,"FJU_VALOR"	 ,"N" , nTamVal ,         2, "Valor"		    ,"Valor Titulo" 	    , "Bill Value"           		, " Valor do Titulo "  , "Valor del Titulo"        	, "Bill Value" , "@!"  					, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,""  ,"","S"})
Aadd(aSX3,{"FJU" ,"11" ,"FJU_TIPO"		 ,"C" , nTamTipo ,        0,  "Tipo"		    ,"Tipo" 	    		, "Type"           				, "Tipo do Titulo "  , "Clase del Titulo "        , "Type of Bill" , "@!"  						, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,""  ,"","S"})
Aadd(aSX3,{"FJU" ,"12" ,"FJU_VENREA"	 ,"D" , nTamVRea ,        0, "Vencto.Real"	,"Vencto. Real" 	 	, "Real Matur. "           		, " Vencimento real do Tit."  , "Vencimiento Real del Tit. "        	, "Real Maturity of Bill" , ""  					, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,""  ,"","S"})
Aadd(aSX3,{"FJU" ,"13" ,"FJU_LA"		 ,"C" , nTamLa  ,         0,  "Ident. Lanc."	,"Ident.Reg.  " 	    , "Entry Ident."           			, "Identificador de LA "  , "Identificador de Registro "        , "Identifier of Entries       " , "@!"  						, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,""  ,"","S"})
Aadd(aSX3,{"FJU" ,"14" ,"FJU_VLCRUZ"	 ,"N" , nTamVal ,         2, "Vlr R$"		    ,"Val. R$" 	        , "Vl R$      "           		, "Valor na moeda nacional"  , "Valor en moneda nacional"        	, "Value in local currency  " , "@!"  					, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,""  ,"","S"})
Aadd(aSX3,{"FJU" ,"15" ,"FJU_EMIS1"	 ,"D" , nTamEmis ,        0, "DT Contab."		 ,"Fch Contab." 	    , "Accoun. Date"           		, "Data de Contabilizacao"  , "Fecha de Contabilizacion"        	, "Accounting Date "         , ""  					, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,""  ,"","S"})
Aadd(aSX3,{"FJU" ,"16" ,"FJU_MOEDA "	 ,"N",  2,					  0, "Moeda"		     ,"Moneda"		    ,"Currency"		              ,"Codigo da Moeda"			,"Codigo de la Moneda"		,"Currency Code"		,"                    ","                                            ","€€€€€€€€€€€€€€ ","","SM2",1,"‡À","",""," ","N","A","R"," ",""," "," "," ","","","","   ","","S"}) 
Aadd(aSX3,{"FJU" ,"17" ,"FJU_HIST"		 ,"C" , nTamHist ,        0, "Historico"		 ,"Historial" 	   , "History"                 , "Historico do Titulo"  , "Historial del Titulo "                    , "Bill History   " , "@!"  						, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,""  ,"","S"})
Aadd(aSX3,{"FJU" ,"18" ,"FJU_TITPAI"	 ,"C" , nTamTitPai,       0, "Tit. Pai"		 ,"Tit. Padre" 	   	, "Tit. Father"                 , "Titulo Pai dos impostos"  , "Título impuestos Padre"    , "Title Father taxes" , "@!"  						, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,""  ,"","S"})
Aadd(aSX3,{"FJU" ,"19" ,"FJU_RECORI"	 ,"N" , 10 		,       0, "Rec.Orig    "		 ,"Rec.Orig    " 	   	, "Rec.Orig    "            , "Recno Origem  "  , "Recno Origem "    , "Recno Origem " , "9999999999"  										, ""  , X3_USADO_EMUSO      ,   "" ,    "", 1 , "š€","" ,"" ,"S" ,"N" ,""  ,""  ,"" ,"" ,"","","","","" ,"" ,""  ,"","S"})
// Tabela FR4
aAdd( aSX3, {'FR4','01','FR4_FILIAL','C',nTamFil,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal del Sistema','System Branch','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),'','',1,	Chr(128) + Chr(128),'','','','','','','','','','','','','','','033','','S'} )
aAdd( aSX3, {'FR4','02','FR4_CODAPU','C',6,0,'Codigo','Codigo','Code','Codigo da Apuração','Codigo de Calculo','Calculation Code','@!',"ExistChav('FR4')",Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(176),'','',1,	Chr(133) + Chr(128),'','','','S','A','R','','','','','','','','','','1','S'} )
aAdd( aSX3, {'FR4','03','FR4_DESC','C',40,0,'Descricao','Descripcion','Description','Descricao da apuração','Descripcion de calculo','Calculation Description','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(133) + Chr(128),'','','','S','A','R','','','','','','','','','','1','S'} )
aAdd( aSX3, {'FR4','04','FR4_TIPAPU','C',1,0,'Tipo','Tipo','Type','Tipo de apuração','Tipo de calculo','Calculation Type','@!',"Pertence('12')",Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(176),"'1'",'',1,	Chr(133) + Chr(128),'','','','S','A','R','','','1=IRPJ;2=CSLL','1=IRPJ;2=CSLL','','','','','','1','S'} )
aAdd( aSX3, {'FR4','05','FR4_DTINI','D',8,0,'Data Inicial','Fch Inicial','Start Date','Data Inicial da apuração','Fecha Inicial de calculo','Calculation Start Date','','F960VlData()',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(133) + Chr(128),'','','','S','A','R','','','','','','','','','','1','S'} )
aAdd( aSX3, {'FR4','06','FR4_DTFIM','D',8,0,'Data Final','Fecha Final','End Date','Data Final','Fecha Final','End Date','','F960VlData()',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(133) + Chr(128),'','','','S','A','R','','','','','','','','','','1','S'} )
aAdd( aSX3, {'FR4','07','FR4_QTMES','N',3,0,'Meses Ap','Meses Cal','Months Ap','Quantidade de Meses','Cantidad de Meses','Number of Months','@E 999','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','1','S'} )
aAdd( aSX3, {'FR4','08','FR4_TPVAL','C',1,0,'Tipo Valor','Tipo Valor','Value Type','Tipo Valor','Tipo Valor','Type Value','','Pertence(" 12")',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),"'1'",'',1,	Chr(133) + Chr(128),'','','','N','A','R','','','1=Movimento do Período;2=Saldo Acumulado','1=Movimiento del Periodo;2=Saldo Acumulado','','','','','','1','S'} )
aAdd( aSX3, {'FR4','09','FR4_LIVRES','C',3,0,'L Res CTB','L Res CTB','Acct Res B','Livro Resultado Contábil','Libro Resultado Contable','Account Result Book','@!','F960ValLiv(.T.)',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','CTN',1,	Chr(133) + Chr(128),'','','','N','A','R','','','','','','','','','','1','S'} )
aAdd( aSX3, {'FR4','10','FR4_LIVADI','C',3,0,'L Adição','L Inclusion',' Addition B','Livro Adição','Libro Inclusion','Add Book','@!','F960ValLiv()',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','CTN',1,	Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','','1','S'} )
aAdd( aSX3, {'FR4','11','FR4_LIVEXC','C',3,0,'L Exclusão','L Borrado','Deletion B','Livro Exclusão','Libro Borrado','Deletion Book','@!','F960ValLiv()',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','CTN',1,	Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','','1','S'} )
aAdd( aSX3, {'FR4','12','FR4_LIVCOM','C',3,0,'L Compensa','L Compensa','Compensat B','Livro Compensação','Libro Compensacion','Compensation Book','@!','F960ValLiv()',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','CTN',1,	Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','','1','S'} )
aAdd( aSX3, {'FR4','13','FR4_LIVDED','C',3,0,'L Dedução','L Deduccion','Deduction B','Livro de Dedução','Libro de Deduccion','Deduction Book','@!','F960ValLiv()',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','CTN',1,	Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','','1','S'} )
aAdd( aSX3, {'FR4','14','FR4_RESCTB','N',16,2,'Res CTB','Res CTB','CTB Res','Resultado Contábil','Resultado Contable','Accounting Result','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','2','S'} )
aAdd( aSX3, {'FR4','15','FR4_ADICAO','N',16,2,'Adição','Inclusion','Addition','Total da aba Adição','Total de solapa Inclusion','Add tab Total','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','2','S'} )
aAdd( aSX3, {'FR4','16','FR4_EXCLUS','N',16,2,'Exclusao','Borrado','Deletion','Total de Exclusão','Total de Borrado','Total Deletion','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','2','S'} )
aAdd( aSX3, {'FR4','17','FR4_BACOMP','N',16,2,'Base Ant Com','Base Ant Com','Base Bef Com','Base antes compensação','Base antes compensacion','Base before compensation','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','2','S'} )
aAdd( aSX3, {'FR4','18','FR4_COMP','N',16,2,'Compensação','Compensacion','Compensation','Total das Compensações','Total de Compensaciones','Total Compensation','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','2','S'} )
aAdd( aSX3, {'FR4','19','FR4_RECTRI','N',16,2,'Res Tribut','Res Tribut','Tax Res','Resultado Tributavel','Resultado Tributable','Taxable Result','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','2','S'} )
aAdd( aSX3, {'FR4','20','FR4_DEDUC','N',16,2,'Deduções','Deducciones','Deductions','Total das deduções','Total de deducciones','Total Deductions','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','2','S'} )
aAdd( aSX3, {'FR4','21','FR4_IRNORM','N',16,2,'IRPJ Normal','IRPJ Normal','IRPJ Normal','IRPJ Normal','IRPJ Normal','Normal IRPJ','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','3','S'} )
aAdd( aSX3, {'FR4','22','FR4_ALINOR','N',6,2,'Aliq IR Norm','Alic IR Norm','IR Norm Rate','Aliquota IRPJ Normal','Alicuota IRPJ Normal','IRPJ Nomal Rage','@E 999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','3','S'} )
aAdd( aSX3, {'FR4','23','FR4_PISENT','N',16,2,'Parc Isenta','Cuot Exenta','Excempt Inst','Parcela Isenta','Cuota Exenta','','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','3','S'} )
aAdd( aSX3, {'FR4','24','FR4_ALIADI','N',6,2,'Aliq Adic','Alic  Adic','Addit Rate','Aliquota IRPJ Adicional','Alicuota IRPJ Adicional','Excempt Installment','@E 999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','3','S'} )
aAdd( aSX3, {'FR4','25','FR4_BASADI','N',16,2,'Base IR Adic','Base IR Adic','Add IR Base','Base IR Adicional','Base IR Adicional','Additional IR Base','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','3','S'} )
aAdd( aSX3, {'FR4','26','FR4_IRADIC','N',16,2,'IR Adicional','IR Adicional','IR Additiona','IR Adicional','IR Adicional','Additional IR','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','3','S'} )
aAdd( aSX3, {'FR4','27','FR4_IRTOT','N',16,2,'IRPJ Total','IRPJ Total','IRPJ Total','IRPJ Total','IRPJ Total','Total IRPJ','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','3','S'} )
aAdd( aSX3, {'FR4','28','FR4_IRPAG','N',16,2,'IRPJ Pagar','IRPJ Pagar','IRPJ Payable','IRPJ a pagar','IRPJ por pagar','Payable IRPJ','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','3','S'} )
aAdd( aSX3, {'FR4','29','FR4_ALICSL','N',6,2,'Aliq CSLL','Alic CSLL','CSLL Rate','Aliquota CSLL','Alicuota CSLL','CSLL Rate','@E 999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','4','S'} )
aAdd( aSX3, {'FR4','30','FR4_CSLL','N',16,2,'CSLL Total','CSLL Total','CSLL Total','CSLL Total','CSLL Total','CSLL Total','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','4','S'} )
aAdd( aSX3, {'FR4','31','FR4_CSLP','N',16,2,'CSLL Pagar','CSLL Pagar','CSLL Pay','CSLL a pagar','CSLL por pagar','CSL Pay ','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','4','S'} )
aAdd( aSX3, {'FR4','32','FR4_PREFIX','C',3,0,'Prefixo','Prefijo','Prefix','Prefixo','Prefijo','Prefix','@!','F960ValTit()',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','','5','S'} )
aAdd( aSX3, {'FR4','33','FR4_NUM','C',9,0,'Numero','Numero','Number','Numero do Titulo','Numero del Titulo','Document Number','@!','F960ValTit()',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','018','5','S'} )
aAdd( aSX3, {'FR4','34','FR4_COND','C',3,0,'Cond Pag','Cond Pag','Pay Cond.','Condição de Pagamento','Condicion de Pago','Payment Condition','@!','ExistCPO("SE4", M->FR4_COND)',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','SE4',1,	Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','','5','S'} )
aAdd( aSX3, {'FR4','35','FR4_CODRET','C',4,0,'Cod Ret','Cod Ret','Withh Code','Codigo de Retenção','Codigo de Retencion','Withholding Code','@!','ExistCPO("SX5", "37" + M->FR4_CODRET)',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','37',1,	Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','','5','S'} )
aAdd( aSX3, {'FR4','36','FR4_STATUS','C',1,0,'Status','Estatus','Status','Status','Estatus','Status','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','1=Aberto;2=Apurado;3=Título Gerado;4=Contabilizado','1=Pendiente;2=Calculado;3=Titulo Generado;4=Contabilizado','','','','','','1','S'} )
aAdd( aSX3, {'FR4','37','FR4_EMISSA','D',8,0,'Dt Emissao','Fc Emision','Issue Date','Data de Emissao','Fecha de Emision','Issue Date','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','','5','S'} )
aAdd( aSX3, {'FR4','38','FR4_LA','C',1,0,'Ident. Lanc.','Ident.Reg.','Entry Ident.','Identificador de LA.','Identificador de Registro','Identifier of Entries','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),'','',1,	Chr(130) + Chr(65),'','','','N','V','R','','','','','','','','','','1','S'} )

// Tabela FR5
aAdd( aSX3, {'FR5','01','FR5_FILIAL','C',nTamFil,0,'Filial','Sucursal','Branch','Filial do sistema','Sucursal del sistema','System Branch','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),'','',1,	Chr(128) + Chr(128),'','','','','','','','','','','','','','','033','','S'} )
aAdd( aSX3, {'FR5','02','FR5_CODAPU','C',6,0,'Codigo','Codigo','Code','Codigo Apuracao','Codigo Calculo','Calculation Code','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','S','A','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR5','03','FR5_TIPO','C',1,0,'Tipo','Tipo','Type','Tipo de Componente','Tipo de Componente','','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','S','A','R','','','1=Resultado CTB;2=Adição;3=Exclusao;4=Compensação;5=Dedução','1=Resultado CTB;2=Inclusion;3=Borrado;4=Compensacion;5=Deduccion','','','','','','','S'} )
aAdd( aSX3, {'FR5','04','FR5_ITEM','C',4,0,'Item','Item','Item','Item Componente','Item Componente','','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR5','05','FR5_ENTID','C',20,0,'Entid Gerenc','Entid Gestio','Manag Entit ','Entidade Gerencial','Entidad de Gestion','','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','003','','S'} )
aAdd( aSX3, {'FR5','06','FR5_DESC','C',40,0,'Descrição','Descripcion','Description ','Descrição da Entidade','Descripcion de Entidad','','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR5','07','FR5_VALOR','N',16,2,'Valor','Valor','Value','Valor Entidade','Valor Ente','','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','A','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR5','08','FR5_DC','C',1,0,'Deb/Cred','Deb/Cred','Deb/Cred','Tipo do valor','Tipo de valor','','@!','Pertence(" 12")',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),"'1'",'',1,	Chr(132) + Chr(128),'','','','N','A','R','','','1=Devedor;2=Credor','1=Deudor;2=Acreedor','','','','','','','S'} )
aAdd( aSX3, {'FR5','09','FR5_TPREG','C',1,0,'Tipo Reg','Tipo Reg','Type Reg','Tipo do Registro','Tipo de Registro','','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),"'2'",'',1,	Chr(132) + Chr(128),'','','','N','V','R','','','1=Sistema;2=Usuário','1=Sistema;2=Usuario','','','','','','','S'} )
aAdd( aSX3, {'FR5','10','FR5_TOTVIS','C',1,0,'Total Vis','Total Vis','Total View','Total da Visão','Total de Vision','','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','1=Sim;2=Não','1=Si;2=No','','','','','','','S'} )
aAdd( aSX3, {'FR5','11','FR5_USER','C',6,0,'Cod Usuario','Cod Usuario','User Code','Codigo do Usuário','Codigo de Usuario','','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR5','12','FR5_NOMEUS','C',40,0,'Nome Usuario','Nombre Usuar','User Name','Nome do Usuário','Nombre de Usuario','User Name','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR5','13','FR5_DTALT','D',8,0,'Data Alt','Fecha Mod','Change Date','Data alteração','Fecha modificacion','Change Date','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR5','14','FR5_LA','C',1,0,'Ident. Lanc.','Ident.Reg.','Entry Ident.','Identificador de LA.','Identificador de Registro','Identifier of Entries','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),'','',1,	Chr(130) + Chr(65),'','','','N','V','R','','','','','','','','','','1','S'} )

// Tabela FR6
aAdd( aSX3, {'FR6','01','FR6_FILIAL','C',nTamFil,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal del Sistema','System Branch','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),'','',1,	Chr(128) + Chr(128),'','','','','','','','','','','','','','','033','','S'} )
aAdd( aSX3, {'FR6','02','FR6_CODAPU','C',6,0,'Codigo','Codigo','Code','Codigo da Apuração','Codigo de Calculo','Calculation Code','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','S','A','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR6','03','FR6_ITEM','C',4,0,'Item','Item','Item','Item','Item','Item','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR6','04','FR6_FILTIT','C',nTamFil,0,'Fil Titulo','Suc Titulo','Branch Doc','Filial do Título','Sucursal del Titulo','Branch Document','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','033','','S'} )
aAdd( aSX3, {'FR6','05','FR6_PREFIX','C',3,0,'Prefixo','Prefijo','Prefix','Prefixo','Prefijo','Prefix','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR6','06','FR6_NUM','C',9,0,'Num Titulo','Num Titulo','Doc Numb','Numero do Título','Numero del Titulo','Document Number','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','018','','S'} )
aAdd( aSX3, {'FR6','07','FR6_PARC','C',1,0,'Parcela','Cuota','Installment','Parcela do Título','Cuota del Titulo','Document Installment','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','011','','S'} )
aAdd( aSX3, {'FR6','08','FR6_TIPO','C',3,0,'Tipo','Tipo','Type','Tipo do Título','Tipo del Titulo','Document Type','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR6','09','FR6_FORNEC','C',6,0,'Forncedor','Proveedor','Supplier','Codigo do Fornecedor','Codigo del Proveedor','Supplier Code','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','001','','S'} )
aAdd( aSX3, {'FR6','10','FR6_LOJA','C',2,0,'Loja','Tienda','Store','Loja do Fornecedor','Tienda del Proveedor','Supplier Store','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),'','',1,	Chr(128) + Chr(128),'','','','N','V','R','','','','','','','','','002','','S'} )
aAdd( aSX3, {'FR6','11','FR6_EMISSA','D',8,0,'DT Emissao','FC Emision','Issue Date','Data de Emissao do Titulo','Fecha Emision de Titulo','Document Issue Date','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR6','12','FR6_VENCTO','D',8,0,'Vencimento','Vencimiento','Due Date','Vencimento do Titulo','Vencimiento del Titulo','Document Due Date','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR6','13','FR6_VALOR','N',16,2,'Vlr.Titulo','Vlr.Titulo','Vl Doc','Valor do Titulo','Valor del Titulo','Document Value','@E 9,999,999,999,999.99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','S'} )

// Tabela FR7
aAdd( aSX3, {'FR7','01','FR7_FILIAL','C',nTamFil,0,'Filial','Sucursal','Branch','Filial do Sistema','Sucursal del Sistema','System Branch','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128),'','',1,	Chr(128) + Chr(128),'','','','','','','','','','','','','','','033','','S'} )
aAdd( aSX3, {'FR7','02','FR7_CODAPU','C',6,0,'Codigo','Codigo','Code','Codigo da Apuração','Codigo de Calculo','Calculation Code','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','S','A','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR7','03','FR7_ITEM','C',4,0,'Item','Item','Item','Item','Item','Item','@!','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR7','04','FR7_GRUEMP','C',2,0,'Grp/Empresa','Grp/Empresa','Grp/Empresa','Código do Grupo / Empresa','Código do Grupo / Empresa','Código do Grupo / Empresa','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR7','05','FR7_GRUDES','C',15,0,'Desc Emp','Desc Emp','Desc Emp','Descrição do Grupo / Emp ','Descrição do Grupo / Emp ','Descrição do Grupo / Emp ','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR7','06','FR7_FILTIT','C',nTamFil,0,'Cod Fil','Cod Fil','Cod Fil','Código da Entidade','Código da Entidade','Código da Entidade','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR7','07','FR7_FILDES','C',15,0,'Desc Filial','Desc Filial','Desc Filial','Descrição da Filial','Descrição da Filial','Descrição da Filial','','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','S'} )
aAdd( aSX3, {'FR7','08','FR7_CNPJ','C',14,0,'CNPJ','CNPJ','CNPJ','CNPJ da Filial','CNPJ da Filial','CNPJ da Filial','@R 99.999.999/9999-99','',Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160),'','',1,	Chr(132) + Chr(128),'','','','N','V','R','','','','','','','','','','','S'} )


Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)
Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) +Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160)

aPHelpPor :={}
aPHelpEng :={} 	   
aPHelpSpa :={}
aAdd(aPHelpPor,"Data de vencimento real do titulo")
aAdd(aPHelpPor,"para efeito de fluxo de caixa")
aAdd(aPHelpPor,"Considera fins de semana e a")
aAdd(aPHelpPor,"e a retenção bancária.")
PutHelp("PFJU_VENREA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

aPHelpPor :={}
aPHelpEng :={} 	   
aPHelpSpa :={}
aAdd(aPHelpPor,"Tipo de Titulo. Relacionado a tabela")
aAdd(aPHelpPor,"deparametrização, faz parte da chave")
aAdd(aPHelpPor,"de acesso")
PutHelp("PFJU_TIPO",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

aPHelpPor :={}
aPHelpEng :={} 	   
aPHelpSpa :={}
aAdd(aPHelpPor,"Identificadores de Lançamentos. O")
aAdd(aPHelpPor,"sistema identifica se já foi efetuada a")
aAdd(aPHelpPor,"rotina de lançamento automático para o")
aAdd(aPHelpPor,"título")
PutHelp("PFJU_LA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

aPHelpPor :={}
aPHelpEng :={} 	   
aPHelpSpa :={}
aAdd(aPHelpPor,"Valor do título expresso em moeda")
aAdd(aPHelpPor,"corrente EX: Reais(R$)")
PutHelp("PFJU_VLCRUZ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

aPHelpPor :={}
aPHelpEng :={} 	   
aPHelpSpa :={}
aAdd(aPHelpPor,"Data de contabilização do título.")
PutHelp("PFJU_EMIS1",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

aPHelpPor :={}
aPHelpEng :={} 	   
aPHelpSpa :={}
aAdd(aPHelpPor,"Identifica qual a moeda que está sendo")
aAdd(aPHelpPor,"digitada no título. Poderá ser aceita")
aAdd(aPHelpPor,"umas das 5 Moedas válidas no sistema.")
PutHelp("PFJU_MOEDA",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

aPHelpPor :={}
aPHelpEng :={} 	   
aPHelpSpa :={}
aAdd(aPHelpPor,"Campo utilizado para informar um")
aAdd(aPHelpPor,"breve comentário sobre o título.")
PutHelp("PFJU_HIST",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

aPHelpPor :={}
aPHelpEng :={} 	   
aPHelpSpa :={}
aAdd(aPHelpPor,"Identificação do titulo pai quando")
aAdd(aPHelpPor,"utilizada natureza que calcula impostos.")
PutHelp("PFJU_TITPAI",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

aPHelpPor :={}
aPHelpEng :={} 	   
aPHelpSpa :={}
aAdd(aPHelpPor,"Identificação do titulo quando")
aAdd(aPHelpPor,"é gerado o relatório.")
PutHelp("PFJU_RECORI",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 

// Tabela SED - Naturezas
aAdd(aSX3, {"SED", "zz", "ED_RECIRRF", "C", 01, 0, "Recolhe IRRF", "Paga IRRF", "Pay IRRF",;
			 "Cliente recolhera IRRF", "Cliente paga IRRF", "Customer will pay IRRF", "@!", "Pertence('123')", "€€€€€€€€€€€€€€ ", "'3'", "", 1,;
			 "†A", "", "", "", "S", "A", "R", "", "",;
			 "1=Sim;2=Nao;3=Cad.Cliente", "1=Si;2=No;3=Reg. Cliente", "1=Yes;2=No;3=Customer", "", "", "", "", "2","S"} )
aPHelpPor :={}
aPHelpEng :={} 	   
aPHelpSpa :={}
aAdd(aPHelpPor,"Indica se o recolhimento do IRRF será")
aAdd(aPHelpPor," feito pelo:")
aAdd(aPHelpPor,"1-Cliente (Sim)")
aAdd(aPHelpPor,"2-Emitente do Documento (Não)")
aAdd(aPHelpPor,"3-Conforme Cad.Cliente (Cad.Cliente)")
PutHelp("PED_RECIRRF",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
			 
// Tabela SED - Naturezas
aAdd(aSX3, {"SED", "zz", "ED_RECFUN", "C", 01, 0, "Rec.Funrural", "Paga Funrural", "Pay Funrural",;
			 "Cliente recolhe Funrural", "Cliente paga Funrural", "Customer will pay Funrural", "@!", "Pertence('12')", "€€€€€€€€€€€€€€ ", "", "", 1,;
			 "†A", "", "", "", "S", "A", "R", "", "",;
			 "1=Sim;2=Nao", "1=Si;2=No", "1=Yes;2=No", "", "", "", "", "2","S"} )
aPHelpPor :={}
aPHelpEng :={} 	   
aPHelpSpa :={}
aAdd(aPHelpPor,"Indica se o recolhimento do Funrural será")
aAdd(aPHelpPor," feito pelo cliente:")
aAdd(aPHelpPor,"1-Sim")
aAdd(aPHelpPor,"2-Não")
PutHelp("PED_RECFUN",aPHelpPor,aPHelpEng,aPHelpSpa,.T.) 
// Tabela SC5 - Pedido de Vendas			 
aAdd(aSX3, {"SC5", "zz", "C5_NATUREZ", "C", 10, 0, "Natureza", "Naturaleza", "Nature",;
			 "Codigo da Nat Financeira", "Codigo de Nat Financeiro", "Financial Code of Nat", "@!", 'MafisGet("NF_NATUREZA")', X3_USADO_EMUSO, "", "SED", 1,;
			 X3_RES, "", "", "", "N", "A", "R", "", "",;
			 "", "", "", "", "", "", "", ""} )						  
aPHelpPor :={}
aPHelpEng :={} 	   
aPHelpSpa :={}
aAdd(aPHelpPor,"Campo utilizado para informar a natureza ")
aAdd(aPHelpPor,"do título, quando gerado para o módulo ")
aAdd(aPHelpPor,"financeiro. ")
PutHelp("PC5_NATUREZ",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)  


If cPaisLoc == "BRA" //INSS Baixa para Contas a Pagar			                  		
	//Campos para controle de cumulatividade de INSS na Baixa
	Aadd(aSX3,{"SE5" ,"ZZ" ,"E5_VRETINS" ,"N" ,14     ,2 ,"Vlr Ret INSS","Vlr Ret INSS","Amt With.INS","Valor Retido - INSS      ","Valor Retenido - INSS    ","Amount Withheld - INSS   ","@E 99,999,999,999.99","","€€€€€€€€€€€€€€€","","",1 ,"åÇ","" ,"" ,"" ,"" ,"V" ,"" ,"" ,"" ,"","","","","" ,"" ,"" ,"","S"})
	Aadd(aSX3,{"SE5" ,"ZZ" ,"E5_PRETINS" ,"C" ,1      ,0 ,"Pend.Rt.INSS","Pend.Rt.INSS","INSS Wt.Open","Pendente Retenção - INSS ","Pendiente Retencion-INSS ","INSS - Withhoil Open     ","","","€€€€€€€€€€€€€€€","","",1 ,"åÇ","" ,"" ,"" ,"" ,"V" ,"" ,"" ,"" ,"","","","","" ,"" ,"" ,"","S"})
	
	aPHelpSpa := {"Valor Retenido  INSS "}
	aPHelpEng := {"Amount Withheld  INSS"}
	aPHelpPor := {"Valor retido de INSS  "  , " em contas a pagar." }	
	                                                         
	PutHelp("PE5_VRETINS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)   
 	
 	aPHelpSpa := {"Pendiente Retencion INSS "}
	aPHelpEng := {"INSS - Withhoil Open     "}
	aPHelpPor := {"Pendente de retencao INSS " }	
	                                                         
	PutHelp("PE5_PRETINS",aPHelpPor,aPHelpEng,aPHelpSpa,.T.)  
		  
Endif

//-- Criação do campo de controle de cancelamento de baixa que não gerou movimento bancário, pois a mesma não é estornada, apenas recebe uma flag de cancelada
Aadd(aSX3,{"SE5" ,"ZZ" ,"E5_DTCANBX" ,"D" ,8 ,0 ,"Dt cancel bx","Dt cancel bx","Dt cancel bx","Data cancelamento baixa","Data cancelamento baixa","Data cancelamento baixa","","","€€€€€€€€€€€€€€€","","",1 ,X3_NAOOBRIGAT,"" ,"" ,"" ,"" ,"R" ,"" ,"" ,"" ,"","","","","" ,"" ,"" ,"","S"})

aHlpPor := {}
aAdd( aHlpPor, 'Data de cancelamento da baixa,' )
aAdd( aHlpPor, 'preenchida quando a baixa não gerou' )
aAdd( aHlpPor, 'movimento bancário.' )
aHlpEng := {}
aHlpSpa := {}
PutHelp( "PE5_DTCANBX", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "E5_DTCANBX" + CRLF
//-- Criação do campo de controle de cancelamento de baixa que não gerou movimento bancário, pois a mesma não é estornada, apenas recebe uma flag de cancelada

// Tabela SEE - Comunicação Remota
If cPaisLoc == "BRA"
	aAdd(aSX3,{"SEE" ,"ZZ" ,"EE_TAMOCOR" ,"N" ,3 ,0 ,"Tam. Ocorre" ,"Tam. Ocorre" ,"Tam. Ocorre" ,"Tamanho da Ocorrencia" ,"Tamanho da Ocorrencia" ,"Tamanho da Ocorrencia" ,"999","",X3_USADO_EMUSO,"2","",1,X3_USADONAOOBRIG,"" ,"" ,"" ,"" ,"R" ,"" ,"" ,"" ,"","","","","" ,"" ,"" ,"1","S"})
	aHlpPor := {}
	aAdd( aHlpPor, 'Tamanho da Ocorrencia         ' )
	aAdd( aHlpPor, 'retornada pelo banco.              ' )
	aAdd( aHlpPor, '(EB_REFBAN)        ' )
	aHlpEng := {}
	aHlpSpa := {}
	PutHelp( "PEE_TAMOCOR", aHlpPor, aHlpEng, aHlpSpa, .T. )
	cTexto += "Atualizado o Help do campo " + "EE_TAMOCOR" + CRLF
EndIf
//
// Helps Tabela FR4
//
aHlpPor := {}
aAdd( aHlpPor, 'Filial do sistema' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_FILIAL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_FILIAL" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Código da Apuração' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_CODAPU", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_CODAPU" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Descrição da Apuração' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_DESC  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_DESC" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Selecione o imposto a ser apurado.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_TIPAPU", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_TIPAPU" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Data inicial da Apuração. Essa data será' )
aAdd( aHlpPor, 'utilizada para o processamento das' )
aAdd( aHlpPor, 'visões gerenciais.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_DTINI ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_DTINI" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Data Final da Apuração. Essa data será' )
aAdd( aHlpPor, 'utilizada para o processamento das' )
aAdd( aHlpPor, 'visões gerenciais.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_DTFIM ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_DTFIM" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Quantidade de meses da apuração, esse' )
aAdd( aHlpPor, 'valor será calculo pela diferença do' )
aAdd( aHlpPor, 'mês/ano da data inicial e da data final' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_QTMES ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_QTMES" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Identifique qual o tipo de Valor que' )
aAdd( aHlpPor, 'será processado das visões gerenciais:' )
aAdd( aHlpPor, '- Movimento do Período -> os valores da' )
aAdd( aHlpPor, 'visão gerencial serão os movimentos do' )
aAdd( aHlpPor, 'período entre as datas inicial e final,' )
aAdd( aHlpPor, 'definidas no cadastro de apuração.' )
aAdd( aHlpPor, '- Saldo Acumulado -> os valores da visão' )
aAdd( aHlpPor, 'gerencial serão os saldos acumulados da' )
aAdd( aHlpPor, 'entidade na data final, definidas no' )
aAdd( aHlpPor, 'cadastro de apuração.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_TPVAL ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_TPVAL" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Esse livro irá preencher o componente de' )
aAdd( aHlpPor, 'Resultado Contabil.' )
aAdd( aHlpPor, 'A entidade gerencial do resultado' )
aAdd( aHlpPor, 'contábil deverá ser marcada como' )
aAdd( aHlpPor, 'resultado da visão (CTS_TOTVIS = SIM)' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_LIVRES", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_LIVRES" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Esse livro irá preencher o componente de' )
aAdd( aHlpPor, 'Adição.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_LIVADI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_LIVADI" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Esse livro irá preencher o componente de' )
aAdd( aHlpPor, 'Exclusão' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_LIVEXC", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_LIVEXC" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Esse livro irá preencher o componente de' )
aAdd( aHlpPor, 'Compensação' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_LIVCOM", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_LIVCOM" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Esse livro irá preencher o componente de' )
aAdd( aHlpPor, 'Dedução' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_LIVDED", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_LIVDED" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Esse componente é a soma de todas as' )
aAdd( aHlpPor, 'receitas menos as despesas apuradas na' )
aAdd( aHlpPor, 'contabilidade no período do cálculo.' )
aAdd( aHlpPor, 'Resultado Contábil = Total de Receita –' )
aAdd( aHlpPor, 'Total das despesas.' )
aAdd( aHlpPor, 'Se o resultado dessa equação for' )
aAdd( aHlpPor, 'positivo, significa que a empresa apurou' )
aAdd( aHlpPor, 'Lucro Contábil.' )
aAdd( aHlpPor, 'negativo, significa que a empresa apurou' )
aAdd( aHlpPor, 'Prejuízo Contábil.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_RESCTB", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_RESCTB" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Soma dos valores da aba Adição. Esse' )
aAdd( aHlpPor, 'valor irá somar ao resultado contábil' )
aAdd( aHlpPor, 'para formar o lucro tributável.' )
aAdd( aHlpPor, 'Adições = Soma dos Créditos - Soma dos' )
aAdd( aHlpPor, 'Debitos' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_ADICAO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_ADICAO" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Soma dos valores da aba exclusão.O valor' )
aAdd( aHlpPor, 'irá subtrair do resultado contábil para' )
aAdd( aHlpPor, 'formar o lucro tributável.' )
aAdd( aHlpPor, 'Deduções = Soma dos Debitos - Soma dos' )
aAdd( aHlpPor, 'Créditos' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_EXCLUS", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_EXCLUS" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Base de calculo de imposto antes das' )
aAdd( aHlpPor, 'compensações.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_BACOMP", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_BACOMP" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Soma dos valores da aba Compensação.Esse' )
aAdd( aHlpPor, 'Valor irá subtrair do resultado contábil' )
aAdd( aHlpPor, 'para formar o lucro tributável.' )
aAdd( aHlpPor, 'Compensações = Soma dos Debitos - Soma' )
aAdd( aHlpPor, 'dos Créditos' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_COMP  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_COMP" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'O resultado tributável é o valor que' )
aAdd( aHlpPor, 'será utilizado como lucro real para' )
aAdd( aHlpPor, 'apuração do imposto.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_RECTRI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_RECTRI" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Soma dos valores da aba Dedução. Esse' )
aAdd( aHlpPor, 'valor irá subtrair do valor do total de' )
aAdd( aHlpPor, 'imposto a pagar' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_DEDUC ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_DEDUC" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'IRPJ normal, calculado com base no' )
aAdd( aHlpPor, 'resultado tributável multiplicado pela' )
aAdd( aHlpPor, 'aliquota' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_IRNORM", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_IRNORM" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Aliquota utilizada para o calculo do' )
aAdd( aHlpPor, 'IRPJ Normal' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_ALINOR", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_ALINOR" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Valor da parcela isenta. Esse valor é' )
aAdd( aHlpPor, 'calculado pela quantidade de meses' )
aAdd( aHlpPor, 'multiplicado pela parcela isenta.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_PISENT", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_PISENT" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Aliquota do IRPJ adicional' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_ALIADI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_ALIADI" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Base de calculo do IRPJ adicional.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_BASADI", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_BASADI" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Valor do IRPJ adicional' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_IRADIC", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_IRADIC" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'IRPJ Total. É composto pela soma do IR' )
aAdd( aHlpPor, 'Normal e IR Adicional' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_IRTOT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_IRTOT" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'IRPJ a pagar. Esse campo será utilizado' )
aAdd( aHlpPor, 'para gerar o título a pagar' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_IRPAG ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_IRPAG" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Aliquota CSLL' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_ALICSL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_ALICSL" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Valor do CSLL Total' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_CSLL  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_CSLL" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'CSLL a pagar. Esse campo será utilizado' )
aAdd( aHlpPor, 'para gerar o título a pagar' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_CSLP  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_CSLP" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Prefixo do titulo de imposto a pagar' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_PREFIX", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_PREFIX" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Número do titulo de imposto a pagar' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_NUM   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_NUM" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Condição de pagamento do titulo de' )
aAdd( aHlpPor, 'imposto a pagar' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_COND  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_COND" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Código de retenção do título de imposto' )
aAdd( aHlpPor, 'a pagar' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_CODRET", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_CODRET" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Status da apuração' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR4_STATUS", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR4_STATUS" + CRLF

//
// Helps Tabela FR5
//
aHlpPor := {}
aAdd( aHlpPor, 'Filial do sistema' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR5_FILIAL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR5_FILIAL" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Código da Apuração' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR5_CODAPU", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR5_CODAPU" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Tipo do componente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR5_TIPO  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR5_TIPO" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Item do Componente' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR5_ITEM  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR5_ITEM" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Entidade gerencial.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR5_ENTID ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR5_ENTID" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Descrição da entidade gerencial' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR5_DESC  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR5_DESC" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Valor do saldo da entidade' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR5_VALOR ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR5_VALOR" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Tipo do valor da entidade' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR5_DC    ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR5_DC" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Tipo do registro' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR5_TPREG ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR5_TPREG" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Indica se a entidade é o total do' )
aAdd( aHlpPor, 'componente.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR5_TOTVIS", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR5_TOTVIS" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Código do ultimo usuário a alterar a' )
aAdd( aHlpPor, 'linha. Utilizado quando o tipo de' )
aAdd( aHlpPor, 'registo é Usuário.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR5_USER  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR5_USER" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Nome do ultimo usuário a alterar a' )
aAdd( aHlpPor, 'linha. Utilizado quando o tipo de' )
aAdd( aHlpPor, 'registo é Usuário.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR5_NOMEUS", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR5_NOMEUS" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Data da ultima alteração da linha.' )
aAdd( aHlpPor, 'Utilizado quando o tipo de registo é' )
aAdd( aHlpPor, 'Usuário.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR5_DTALT ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR5_DTALT" + CRLF

//
// Helps Tabela FR6
//
aHlpPor := {}
aAdd( aHlpPor, 'Filial do Sistema' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR6_FILIAL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR6_FILIAL" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Codigo da Apuração' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR6_CODAPU", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR6_CODAPU" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Item da linha' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR6_ITEM  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR6_ITEM" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Filial do Titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR6_FILTIT", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR6_FILTIT" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Prefixo do titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR6_PREFIX", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR6_PREFIX" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Numero do titulo gerado' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR6_NUM   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR6_NUM" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Parcela do Título' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR6_PARC  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR6_PARC" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Tipo do Título' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR6_TIPO  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR6_TIPO" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Codigo do Fornecedor' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR6_FORNEC", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR6_FORNEC" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Loja do Fornecedor' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR6_LOJA  ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR6_LOJA" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Data de Emissao do Titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR6_EMISSA", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR6_EMISSA" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Vencimento do Titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR6_VENCTO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR6_VENCTO" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Valor do Titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR6_VALOR ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + "FR6_VALOR" + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Valor do Titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR6_VALOR ", aHlpPor, aHlpEng, aHlpSpa, .T. )

//
// Helps Tabela FR7
//
aHlpPor := {}
aAdd( aHlpPor, 'Filial do Sistema' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR7_FILIAL", aHlpPor, aHlpEng, aHlpSpa, .T. )

aHlpPor := {}
aAdd( aHlpPor, 'Codigo da Apuração' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR7_CODAPU", aHlpPor, aHlpEng, aHlpSpa, .T. )

aHlpPor := {}
aAdd( aHlpPor, 'Item da linha' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR7_ITEM  ", aHlpPor, aHlpEng, aHlpSpa, .T. )

aHlpPor := {}
aAdd( aHlpPor, 'Código do Grupo / Empresa' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR7_GRUEMP  ", aHlpPor, aHlpEng, aHlpSpa, .T. )

aHlpPor := {}
aAdd( aHlpPor, 'Descrição do Grupo / Empresa' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR7_GRUDES  ", aHlpPor, aHlpEng, aHlpSpa, .T. )

aHlpPor := {}
aAdd( aHlpPor, 'Código da Entidade' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR7_CODFIL  ", aHlpPor, aHlpEng, aHlpSpa, .T. )

aHlpPor := {}
aAdd( aHlpPor, 'Descrição da Filial' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR7_FILDES  ", aHlpPor, aHlpEng, aHlpSpa, .T. )

aHlpPor := {}
aAdd( aHlpPor, 'CNPJ da Filial' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFR7_CNPJ  ", aHlpPor, aHlpEng, aHlpSpa, .T. )


dbSelectArea( "SX3" )
SX3->(DbSetOrder(2))
//Inclui o campo FIF_PARCEL no grupo de campos
If DbSeek("FIF_PARCEL")
	RecLock("SX3")
	Replace X3_GRPSXG  With "011"
	MsUnlock()
EndIf

//Altera o campo E1_TXMDCOR no tamanho do decimal
If DbSeek("E1_TXMDCOR") .And. X3_DECIMAL != 4
	RecLock("SX3")
	Replace X3_DECIMAL With 4
	Replace X3_PICTURE With "@E 999,999,999.9999"                
	MsUnlock()
	aADD(aArqUpd,"SE1")
EndIf
 
//Altera o campo E2_TXMDCOR no tamanho do decimal
If DbSeek("E2_TXMDCOR") .And. X3_DECIMAL != 4
	RecLock("SX3")
	Replace X3_DECIMAL With 4
	Replace X3_PICTURE With "@E 999,999,999.9999"
	MsUnlock()
	aADD(aArqUpd,"SE2")
EndIf

If DbSeek("E1_ACRESC") 
	RecLock("SX3")
	Replace X3_WHEN With "!(MVRECANT == M->E1_TIPO )"
	MsUnlock()
EndIf

If DbSeek("E1_DECRESC") 
	RecLock("SX3")
	Replace X3_WHEN With "!(MVRECANT == M->E1_TIPO )"
	MsUnlock()
EndIf

If DbSeek("E2_ACRESC") 
	RecLock("SX3")
	Replace X3_WHEN With "!(MVPAGANT == M->E2_TIPO )"
	MsUnlock()
EndIf

If DbSeek("E2_DECRESC") 
	RecLock("SX3")
	Replace X3_WHEN With "!(MVPAGANT == M->E2_TIPO )"
	MsUnlock()
EndIf

If DbSeek("C5_NATUREZ")
	RecLock("SX3")
	Replace X3_VALID With 'MafisGet("NF_NATUREZA")'
	MsUnlock()
EndIf

If DbSeek("E2_EMISSAO")
	RecLock("SX3")	 		
	Replace X3_VALID With "iif(Empty(m->e2_vencto),.T.,m->e2_emissao <= m->e2_vencto) .and. Iif(!DtMovFin(m->e2_emissao),.F.,.T.)" 
	MsUnlock()
EndIf
*/




//--------------------------------------------------------------
// Atualizando dicionário
//--------------------------------------------------------------
nPosArq := aScan( aEstrut, { |x| AllTrim( x ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x ) == "X3_GRPSXG"  } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )
	// Verifica se o campo faz parte de um grupo e ajsuta tamanho
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				cTexto += "O tamanho do campo " + aSX3[nI][nPosCpo] + " nao atualizado e foi mantido em ["
				cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF
				cTexto += "   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF + CRLF
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )
		// Busca ultima ocorrencia do alias
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == 2    // Ordem
				FieldPut( FieldPos( aEstrut[nJ] ), cSeqAtu )

			ElseIf FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		cTexto += "Criado o campo " + aSX3[nI][nPosCpo] + CRLF

	Else

		// Verifica se o campo faz parte de um grupo e ajsuta tamanho
		If !Empty( SX3->X3_GRPSXG ) .AND. SX3->X3_GRPSXG <> aSX3[nI][nPosSXG]
			SXG->( dbSetOrder( 1 ) )
			If SXG->( MSSeek( SX3->X3_GRPSXG ) )
				If aSX3[nI][nPosTam] <> SXG->XG_SIZE
					aSX3[nI][nPosTam] := SXG->XG_SIZE
					cTexto +=  "O tamanho do campo " + aSX3[nI][nPosCpo] + " nao atualizado e foi mantido em ["
					cTexto += AllTrim( Str( SXG->XG_SIZE ) ) + "]"+ CRLF
					cTexto +=  "   por pertencer ao grupo de campos [" + SX3->X3_GRPSXG + "]" + CRLF + CRLF
				EndIf
			EndIf
		EndIf

		// Verifica todos os campos
		For nJ := 1 To Len( aSX3[nI] )

			// Se o campo estiver diferente da estrutura
			If aEstrut[nJ] == SX3->( FieldName( nJ ) ) .AND. ;
				PadR( StrTran( AllToChar( SX3->( FieldGet( nJ ) ) ), " ", "" ), 250 ) <> ;
				PadR( StrTran( AllToChar( aSX3[nI][nJ] )           , " ", "" ), 250 ) .AND. ;
				AllTrim( SX3->( FieldName( nJ ) ) ) <> "X3_ORDEM"

				cMsg := "O campo " + aSX3[nI][nPosCpo] + " está com o " + SX3->( FieldName( nJ ) ) + ;
				" com o conteúdo" + CRLF + ;
				"[" + RTrim( AllToChar( SX3->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
				"que será substituido pelo NOVO conteúdo" + CRLF + ;
				"[" + RTrim( AllToChar( aSX3[nI][nJ] ) ) + "]" + CRLF + ;
				"Deseja substituir ? "

				If lTodosSim
					nOpcA := 1
				ElseIf  lTodosNao
					nOpcA := 2
				Else
					nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SX3" )
					lTodosSim := ( nOpcA == 3 )
					lTodosNao := ( nOpcA == 4 )

					If lTodosSim
						nOpcA := 1
						lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SX3 e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
					EndIf

					If lTodosNao
						nOpcA := 2
						lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SX3 que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
					EndIf
				EndIf

				If nOpcA == 1
					cTexto += "Alterado o campo " + aSX3[nI][nPosCpo] + CRLF
					cTexto += "   " + PadR( SX3->( FieldName( nJ ) ), 10 ) + " de [" + AllToChar( SX3->( FieldGet( nJ ) ) ) + "]" + CRLF
					cTexto += "            para [" + AllToChar( aSX3[nI][nJ] )          + "]" + CRLF + CRLF

					RecLock( "SX3", .F. )
					FieldPut( FieldPos( aEstrut[nJ] ), aSX3[nI][nJ] )
					dbCommit()
					MsUnLock()
				EndIf
			EndIf
		Next
	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI


cTexto += CRLF + "Final da Atualizacao" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

/*
If AliasIndic("FJU")
	X31UpdTable("FJU")
	DbSelectArea("FJU")
	nCamp :=  FieldPos("FJU_FILIAL") 
	FJU->(DbCloseArea())
	If nCamp > 0
		UpdUnique(RetSqlName("FJU"),"FJU_FILIAL+FJU_CART+FJU_RECORI" )
	EndIf	
EndIf
*/


Return aClone( aSX3 )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FinAtuSIX º Autor ³ Jose.Gavetti      º Data ³  10/07/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento da gravacao do SIX - Indices       ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ FinAtuSIX         ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinAtuSIX( cTexto )
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

cTexto  += "Inicio da Atualizacao" + " SIX" + CRLF + CRLF

//--------------------------------------------------------------
// Estrutura dos campos
//--------------------------------------------------------------
aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
             "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

// Tabela SZO
aAdd( aSIX, { ;
	'SZP'																	  	, ; //INDICE
	'1'																		  	, ; //ORDEM
	'ZP_FILIAL+ZP_CONTRAT+ZP_SEQ'												, ; //CHAVE
	'Filial + Contrato + Sequencia'												, ; //DESCRICAO
	'Filial + Contrato + Sequencia'												, ; //DESCSPA
	'Filial + Contrato + Sequencia'												, ; //DESCENG
	'U'																			, ; //PROPRI
	''																			, ; //F3
	''																			, ; //NICKNAME
	'S'																			} ) //SHOWPESQ

aAdd( aSIX, { ;
	'SZQ'																	  	, ; //INDICE
	'1'																		  	, ; //ORDEM
	'ZQ_FILIAL+ZQ_CONTRAT+ZQ_SEQ+ZQ_ITEM'										, ; //CHAVE
	'Filial + Contrato + Sequencia + Item'										, ; //DESCRICAO
	'Filial + Contrato + Sequencia + Item'										, ; //DESCSPA
	'Filial + Contrato + Sequencia + Item'										, ; //DESCENG
	'U'																			, ; //PROPRI
	''																			, ; //F3
	''																			, ; //NICKNAME
	'S'																			} ) //SHOWPESQ


// Tabela FR4
//aAdd( aSIX, {'FR4','1','FR4_FILIAL+FR4_CODAPU','Codigo','Codigo','Code','S','','','S'} )
// Tabela FR5
//aAdd( aSIX, {'FR5','1','FR5_FILIAL+FR5_CODAPU+FR5_TIPO+FR5_ITEM+FR5_ENTID','Codigo + Tipo + Item','Codigo + Tipo + Item','Code + Type + Item','S','','','S'} )
// Tabela FR6
//aAdd( aSIX, {'FR6','1','FR6_FILIAL+FR6_CODAPU+FR6_ITEM','Codigo + Item','Codigo + Item','Code + Item','S','','','S'} )
// Tabela FR7
//aAdd( aSIX, {'FR7','1','FR7_FILIAL+FR7_CODAPU+FR7_ITEM','Codigo + Item','Codigo + Item','Code + Item','S','','','S'} )



//--------------------------------------------------------------
// Atualizando dicionário
//--------------------------------------------------------------
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		RecLock( "SIX", .T. )
		lDelInd := .F.
		cTexto += "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF
	Else
		lAlt := .F.
		RecLock( "SIX", .F. )
	EndIf

	If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "") == ;
	    StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
		aAdd( aArqUpd, aSIX[nI][1] )

		If lAlt
			lDelInd := .T. // Se for alteracao precisa apagar o indice do banco
			cTexto += "Índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] + CRLF
		EndIf

		For nJ := 1 To Len( aSIX[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
			EndIf
		Next nJ

		If lDelInd
			TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] ) // Exclui sem precisar baixar o TOP
		EndIf

	EndIf

	dbCommit()
	MsUnLock()

	oProcess:IncRegua2( "Atualizando índices..." )

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return aClone( aSIX )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FinAtuSX6 º Autor ³ TOTVS Protheus     º Data ³  14/09/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento da gravacao do SX6 - Parâmetros    ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ FinAtuSX6   - Gerado por EXPORDIC / Upd. V.4.7.2 EFS        ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinAtuSX6( cTexto )
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local nJ        := 0
Local nI			:= 0	
Local nTamFil   := Len( SX6->X6_FIL )
Local lSX6			:= .F.

cTexto  += "Inicio da Atualizacao" + " SX6" + CRLF + CRLF

//--------------------------------------------------------------
//Estrutura dos Campos
//--------------------------------------------------------------
aEstrut := { "X6_FIL"    , "X6_VAR"  , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , "X6_DSCSPA1",;
             "X6_DSCENG1", "X6_DESC2", "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG", "X6_PROPRI" , "X6_PYME" }


/*
If (cPaisLoc == "BRA") //Inss Baixa - Define o momento do tratamento da retenção do imposto INSS e se terá controle de valores minimos e maximo retidos.
	aAdd( aSX6, { SPACE(nTamFil) , "MV_INSBXCP" ,'C','Define momento do tratamento da retencäo do ',' ',' ',;
			'imposto INSS.',' ',' ','1 = Na Baixa ou 2 = Na Emissäo (Default)','','','2','2','2',''} )
			
	aAdd( aSX6, {SPACE(nTamFil),'MV_INSPUB','L','Indica se o inss retido na baixa para ',' ',' ',;
			'contas a pagar é para uma empresa publica.',' ','','Ou seja, sem controle de valores.','','','.F.','.F.','.F.',''} ) 
			
	aAdd( aSX6, {SPACE(nTamFil),'MV_TIPOLOG','N','Informe 1 para gerar o arquivo de log em txt ou ',' ',' ',;
			'2 para gerar o relatório.                         ',' ','','','','','1','1','1',''} )			 			
EndIf

If (cPaisLoc == "BRA") //Acumula ou não o IRRF
	aAdd( aSX6, { SPACE(nTamFil) , "MV_ACMIRRF" ,'C','Define se acumula o valor minimo do ',' ',' ',;
				'imposto IRRF.',' ',' ','1 = Acumula (Default) ou 2 = Não Acumula ','','','1','1','1',''} )
Endif

If cPaisLoc == "BRA"	
	//Chamado TPUNZQ - 18/08/2014
	aAdd( aSX6, { ;
			SPACE(nTamFil)														, ; //X6_FIL
			'MV_BDVCIMP'															, ; //X6_VAR
			'L'																		, ; //X6_TIPO
			'Alterar vencimento dos impostos (IR, PIS,COFINS e   '         , ; //X6_DESCRIC
			'                                                    '			, ; //X6_DSCSPA
			'                                                    '  		, ; //X6_DSCENG
			'CSLL)considerando o vencimento do titulo principal'				, ; //X6_DESC1
			'                                                  '				, ; //X6_DSCSPA1
			'                                                  '				, ; //X6_DSCENG1
			' quando transferido via borderô de impostos.      '				, ; //X6_DESC2
			'                                                  '				, ; //X6_DSCSPA2
			'                                                  '				, ; //X6_DSCENG2
			'F'																		, ; //X6_CONTEUD
			'F'																		, ; //X6_CONTSPA
			'F'																		, ; //X6_CONTENG
			'S'																		, ; //X6_PROPRI
			'S'																		} ) //X6_PYME
			
	//Chamado TPWVRJ - 12/09/2014 
	aAdd( aSX6, { ;
			SPACE(nTamFil)														, ; //X6_FIL
			'MV_DIAUISS'															, ; //X6_VAR
			'N'																		, ; //X6_TIPO
			'Indica a qtde de dias uteis usada para gerar a '              , ; //X6_DESCRIC			
			'                                                  '		    	, ; //X6_DSCSPA
			'                                                  '  		   , ; //X6_DSCENG
			'data do vencimento do titulo do imposto ISS.		  '		    	, ; //X6_DESC1			
			'                                                  '				, ; //X6_DSCSPA1
			'                                                  '				, ; //X6_DSCENG1
			'                                                  '				, ; //X6_DESC2
			'                                                  '				, ; //X6_DSCSPA2
			'                                                  '				, ; //X6_DSCENG2
			' '																		, ; //X6_CONTEUD
			' '																		, ; //X6_CONTSPA
			' '																		, ; //X6_CONTENG
			'S'																		, ; //X6_PROPRI
			'S'																		} ) //X6_PYME

	//Chamado TQIDF7 - 17/12/2014
	aAdd( aSX6, { ;
			SPACE(nTamFil)														, ; //X6_FIL
			'MV_CTBAGP'															, ; //X6_VAR
			'L'																		, ; //X6_TIPO
			'Define se os títulos do PCC são contabilizados    '         , ; //X6_DESCRIC
			'                                                    '			, ; //X6_DSCSPA
			'                                                    '  		, ; //X6_DSCENG
			'pelos seus aglutinados ou não (Default = .F.)	'				, ; //X6_DESC1
			'                                                  '				, ; //X6_DSCSPA1
			'                                                  '				, ; //X6_DSCENG1
			'												      '				, ; //X6_DESC2
			'                                                  '				, ; //X6_DSCSPA2
			'                                                  '				, ; //X6_DSCENG2
			'.F.'																	, ; //X6_CONTEUD
			'.F.'																	, ; //X6_CONTSPA
			'.F.'																	, ; //X6_CONTENG
			'S'																		, ; //X6_PROPRI
			'S'																		} ) //X6_PYME
						
EndIf

aAdd( aSX6, { ;
	SPACE(nTamFil)														, ; //X6_FIL
	'MV_NCCIR'															, ; //X6_VAR
	'C'																		, ; //X6_TIPO
	'Cria ou não o título de adiantamento quando o       '         , ; //X6_DESCRIC
	'                                                    '			, ; //X6_DSCSPA
	'                                                    '  		, ; //X6_DSCENG
	'título retentor for menor que o imposto.          '				, ; //X6_DESC1
	'                                                  '				, ; //X6_DSCSPA1
	'                                                  '				, ; //X6_DSCENG1
	'(1=Cria;2=Não Cria)                               '				, ; //X6_DESC2
	'                                                  '				, ; //X6_DSCSPA2
	'                                                  '				, ; //X6_DSCENG2
	'2'																		, ; //X6_CONTEUD
	'2'																		, ; //X6_CONTSPA
	'2'																		, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME

aAdd( aSX6, { ;
	Space(nTamFil)														, ; //X6_FIL
	'MV_F330TIT'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Indica se o sistema deve ignorar o registro do '				, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'arquivo de retorno do CNAB quando o IDCNAB está '				, ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'vazio.'																, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME
	
aAdd( aSX6, { ;
	Space(nTamFil)														, ; //X6_FIL
	'MV_USAMEP'															, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Indica se a rotina Conciliador Sitef deve utilizar'				, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'a tabela MEP, para realizar a conciliação dos'				   , ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	'arquivos SITEF. '													, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.T.'																	, ; //X6_CONTEUD
	'.T.'																	, ; //X6_CONTSPA
	'.T.'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME

aAdd( aSX6, {SPACE(nTamFil),'MV_FINACS','N','Aliquota CSLL Lucro Real','Alicuota CSLL Ganancia Real','CSLL Rate Real Profit','','','','','','','9','9','9','S','S'} )
aAdd( aSX6, {SPACE(nTamFil),'MV_FINAIRA','N','Aliquota IRPJ Adicional Lucro Real','Alicuota IRPJ Adicional Ganacia Real','IRPJ Rate Add Real Profit','','','','','','','10','10','10','S','S'} )
aAdd( aSX6, {SPACE(nTamFil),'MV_FINAIRN','N','Aliquota IRPJ Normal para o Lucro Real','Alicuota IRPJ Normal para la Ganancia Real','IRPJ Normal Rate for Real Profit','','','','','','','15','15','15','S','S'} )
aAdd( aSX6, {SPACE(nTamFil),'MV_FINNCS','C','Natureza para inclusao do titulo de apuracao','Modalidad para inclusion del titulo de calculo','Class to add calculation document','de CSLL','','from CSLL','','','','','','','',''} )
aAdd( aSX6, {SPACE(nTamFil),'MV_FINNIR','C','Natureza para inclusao do titulo de apuracao','Modalidad para inclusion del titulo de calculo','Class to add calculation document','de IRPJ','','from IRPJ','','','','','','','S','S'} )
aAdd( aSX6, {SPACE(nTamFil),'MV_FINPIR','N','Valor da parcela mensal isenta IRPJ Adicional','Valor de la cuota mensual exenta IRPJ Adicional','Value of monthly installment exempt IRPJ Add','Lucro Real','Ganancia Real','Real Profit','','','','20000','20000','20000','S','S'} )


aAdd( aSX6, { ;
	Space(nTamFil)														, ; //X6_FIL
	'MV_MV_ITLBCPG'														, ; //X6_VAR
	'L'																		, ; //X6_TIPO
	'Libera campos de juros, multa se possuir'						, ; //X6_DESCRIC
	''																		, ; //X6_DSCSPA
	''																		, ; //X6_DSCENG
	'integração TIN x PROTHEUS, para contas a pagar'				   , ; //X6_DESC1
	''																		, ; //X6_DSCSPA1
	''																		, ; //X6_DSCENG1
	''																		, ; //X6_DESC2
	''																		, ; //X6_DSCSPA2
	''																		, ; //X6_DSCENG2
	'.F.'																	, ; //X6_CONTEUD
	'.F.'																	, ; //X6_CONTSPA
	'.F.'																	, ; //X6_CONTENG
	'S'																		, ; //X6_PROPRI
	'S'																		} ) //X6_PYME
*/

ProcRegua(Len(aSX6))

dbSelectArea("SX6")
dbSetOrder(1)
For nI:= 1 To Len(aSX6)
	If !Empty(aSX6[nI][2])
		If !dbSeek(aSX6[nI,1]+aSX6[nI,2])
			lSX6	:= .T.
			If !(aSX6[nI,2]$cAlias)
				cAlias += aSX6[nI,2]+"/"
			EndIf
			RecLock("SX6",.T.)
			For nJ:=1 To Len(aSX6[nI])
				If !Empty(FieldName(FieldPos(aEstrut[nJ])))
					FieldPut(FieldPos(aEstrut[nJ]),aSX6[nI,nJ])
				EndIf
			Next nJ
			
			dbCommit()
			MsUnLock()
			IncProc("Atualizando Parametros...") // //"Atualizando Parametros..."
		EndIf
	EndIf
Next nI

If lSX6
	cTexto += CRLF + "Final da Atualizacao" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF		
EndIf

Return aClone( aSX6 )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FinAtuSX7 º Autor ³ TOTVS Protheus     º Data ³  14/09/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento da gravacao do SX7 - Gatilhos      ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ FinAtuSX7   - Gerado por EXPORDIC / Upd. V.4.7.2 EFS        ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinAtuSX7( cTexto )
Local aEstrut   := {}
Local aSX7      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX7->X7_CAMPO )

cTexto  += "Inicio da Atualizacao" + " SX7" + CRLF + CRLF

//--------------------------------------------------------------
// Estrutura dos campos
//--------------------------------------------------------------
aEstrut := { "X7_CAMPO", "X7_SEQUENC", "X7_REGRA", "X7_CDOMIN", "X7_TIPO", "X7_SEEK", ;
             "X7_ALIAS", "X7_ORDEM"  , "X7_CHAVE", "X7_PROPRI", "X7_CONDIC" }

dbSelectArea("SX7")
dbSetOrder(1) 

/*
If cPaisLoc == "BRA"
	If !MsSeek("ED_CGE    001")
		If aScan(aSx7, {|x| AllTrim(x[1]) == "ED_CGE"}) == 0
			Aadd(aSX7,{"ED_CGE ","001","CGE->CGE_COD"  ,"ED_CDRECA","P","N","",0,"","S",""})
		EndIf
	EndIf
	If !MsSeek("ED_CGG    001")
		If aScan(aSx7, {|x| AllTrim(x[1]) == "ED_CGG"}) == 0
			Aadd(aSX7,{"ED_CGG ","001","CGG->CGG_COD"  ,"ED_CDDEDA","P","N","",0,"","S",""})
		EndIf
	EndIf
EndIf
*/

ProcRegua(Len(aSX7))

dbSelectArea("SX7")
dbSetOrder(1)
For nI:= 1 To Len(aSX7)
	If !Empty(aSX7[nI][1])
		If !dbSeek(aSX7[nI,1]+aSX7[nI,2])
			lSX7 := .T.
			If !(aSX7[nI,1]$cAlias)
				cAlias += aSX7[nI,1]+"/"
			EndIf
			RecLock("SX7",.T.)
			
			For nJ:=1 To Len(aSX7[nI])
				If !Empty(FieldName(FieldPos(aEstrut[nJ])))
					FieldPut(FieldPos(aEstrut[nJ]),aSX7[nI,nJ])
				EndIf
			Next nJ
			
			dbCommit()
			MsUnLock()
			IncProc("Atualizando Gatilhos...") // //"Atualizando Gatilhos..."
		EndIf
	EndIf
Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX7" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return aClone( aSX7 )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FinAtuSXA º Autor ³ TOTVS Protheus     º Data ³  14/09/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento da gravacao do SXA - Pastas        ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ FinAtuSXA   - Gerado por EXPORDIC / Upd. V.4.7.2 EFS        ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinAtuSXA( cTexto )
Local aEstrut   := {}
Local aSXA      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0

Local aEstrut   := {}
Local aSXA      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0

cTexto  += "Inicio da Atualizacao" + " SXA" + CRLF + CRLF//"Inicio da Atualizacao"

aEstrut := { "XA_ALIAS", "XA_ORDEM", "XA_DESCRIC", "XA_DESCSPA", "XA_DESCENG", "XA_PROPRI" }

//
// Tabela FR4
//
//aAdd( aSXA, {'FR4','1','Configuração','Configuracion','Configuration','S'} )
//aAdd( aSXA, {'FR4','2','Base de Cálculo','Base de Calculo','Calculation Base','S'} )
//aAdd( aSXA, {'FR4','3','IRPJ','IRPJ','IRPJ','S'} )
//aAdd( aSXA, {'FR4','4','CSLL','CSLL','CSLL','S'} )
//aAdd( aSXA, {'FR4','5','Informações Financeiras','Informaciones Financieras','Financial Information','S'} )
//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSXA ) )

dbSelectArea( "SXA" )
dbSetOrder( 1 )

For nI := 1 To Len( aSXA )

	If !SXA->( dbSeek( aSXA[nI][1] + aSXA[nI][2] ) )

		If !( aSXA[nI][1] $ cAlias )
			cAlias += aSXA[nI][1] + "/"
		EndIf

		RecLock( "SXA", .T. )
		For nJ := 1 To Len( aSXA[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSXA[nI][nJ] )
			EndIf
		Next nJ
		dbCommit()
		MsUnLock()

		cTexto += "Foi incluída a pasta " + aSXA[nI][1] + "/" + aSXA[nI][2]  + CRLF//"Foi incluída a pasta "

		oProcess:IncRegua2( "Atualizando Arquivos (SXA)..." )//"Atualizando Arquivos (SXA)..."

	EndIf

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SXA" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF//

Return aClone( aSXA )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FinAtuSXB º Autor ³ TOTVS Protheus     º Data ³  14/09/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento da gravacao do SXB - Consultas Pad ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ FinAtuSXB   - Gerado por EXPORDIC / Upd. V.4.7.2 EFS        ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinAtuSXB( cTexto )
Local aEstrut   := {}
Local aSXB      := {}
Local cAlias    := ""
Local cMsg      := ""
Local lTodosNao := .F.
Local lTodosSim := .F.
Local nI        := 0
Local nJ        := 0
Local nOpcA     := 0

cTexto  += "Inicio da Atualizacao" + " SXB" + CRLF + CRLF

//--------------------------------------------------------------
// Estrutura dos campos
//--------------------------------------------------------------
aEstrut := { "XB_ALIAS",  "XB_TIPO"   , "XB_SEQ"    , "XB_COLUNA" , ;
             "XB_DESCRI", "XB_DESCSPA", "XB_DESCENG", "XB_CONTEM" }

//--------------------------------------------------------------
// Atualizando dicionário
//--------------------------------------------------------------
//aAdd( aSXB, {'FR4','1','01','DB','Apuracao IRPJ/CSLL','Apuracao IRPJ/CSLL','Apuracao IRPJ/CSLL','FR4'} )
//aAdd( aSXB, {'FR4','2','01','01','Codigo','Codigo','Code',''} )
//aAdd( aSXB, {'FR4','4','01','01','Filial','Sucursal','Branch','FR4_FILIAL'} )
//aAdd( aSXB, {'FR4','4','01','02','Codigo','Codigo','Code','FR4_CODAPU'} )
//aAdd( aSXB, {'FR4','4','01','03','Descricao','Descripcion','Description','FR4_DESC'} )
//aAdd( aSXB, {'FR4','4','01','04','Tipo','Tipo','Type','FR4_TIPAPU'} )
//aAdd( aSXB, {'FR4','4','01','05','Data Inicial','Fch Inicial','Start Date','FR4_DTINI'} )
//aAdd( aSXB, {'FR4','4','01','06','Data Final','Fecha Final','Data Final','FR4_DTFIM'} )
//aAdd( aSXB, {'FR4','5','01','','','','','FR4->FR4_CODAPU'} )

oProcess:SetRegua2( Len( aSXB ) )

dbSelectArea( "SXB" )
dbSetOrder( 1 )



For nI := 1 To Len( aSXB )

	If !Empty( aSXB[nI][1] )

		If !SXB->( dbSeek( PadR( aSXB[nI][1], Len( SXB->XB_ALIAS ) ) + aSXB[nI][2] + aSXB[nI][3] + aSXB[nI][4] ) )

			If !( aSXB[nI][1] $ cAlias )
				cAlias += aSXB[nI][1] + "/"
				cTexto += "Foi incluída a consulta padrão " + aSXB[nI][1] + CRLF
			EndIf

			RecLock( "SXB", .T. )

			For nJ := 1 To Len( aSXB[nI] )
				If !Empty( FieldName( FieldPos( aEstrut[nJ] ) ) )
					FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
				EndIf
			Next nJ

			dbCommit()
			MsUnLock()

		Else

			// Verifica todos os campos
			For nJ := 1 To Len( aSXB[nI] )

				// Se o campo estiver diferente da estrutura
				If aEstrut[nJ] == SXB->( FieldName( nJ ) ) .AND. ;
					!StrTran( AllToChar( SXB->( FieldGet( nJ ) ) ), " ", "" ) == ;
					 StrTran( AllToChar( aSXB[nI][nJ]            ), " ", "" )

					cMsg := "A consulta padrao " + aSXB[nI][1] + " está com o " + SXB->( FieldName( nJ ) ) + ;
					" com o conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( SXB->( FieldGet( nJ ) ) ) ) + "]" + CRLF + ;
					", e este é diferente do conteúdo" + CRLF + ;
					"[" + RTrim( AllToChar( aSXB[nI][nJ] ) ) + "]" + CRLF +;
					"Deseja substituir ? "

					If      lTodosSim
						nOpcA := 1
					ElseIf  lTodosNao
						nOpcA := 2
					Else
						nOpcA := Aviso( "ATUALIZAÇÃO DE DICIONÁRIOS E TABELAS", cMsg, { "Sim", "Não", "Sim p/Todos", "Não p/Todos" }, 3, "Diferença de conteúdo - SXB" )
						lTodosSim := ( nOpcA == 3 )
						lTodosNao := ( nOpcA == 4 )

						If lTodosSim
							nOpcA := 1
							lTodosSim := MsgNoYes( "Foi selecionada a opção de REALIZAR TODAS alterações no SXB e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma a ação [Sim p/Todos] ?" )
						EndIf

						If lTodosNao
							nOpcA := 2
							lTodosNao := MsgNoYes( "Foi selecionada a opção de NÃO REALIZAR nenhuma alteração no SXB que esteja diferente da base e NÃO MOSTRAR mais a tela de aviso." + CRLF + "Confirma esta ação [Não p/Todos]?" )
						EndIf

					EndIf

					If nOpcA == 1
						RecLock( "SXB", .F. )
						FieldPut( FieldPos( aEstrut[nJ] ), aSXB[nI][nJ] )
						dbCommit()
						MsUnLock()

						If !( aSXB[nI][1] $ cAlias )
							cAlias += aSXB[nI][1] + "/"
							cTexto += "Foi Alterada a consulta padrao " + aSXB[nI][1] + CRLF
						EndIf
					EndIf
				EndIf
			Next
		EndIf
	EndIf

	oProcess:IncRegua2( "Atualizando Consultas Padroes (SXB)..." )

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SXB" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return aClone( aSXB )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FinAtuSX5 º Autor ³ TOTVS Protheus     º Data ³  14/09/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento da gravacao do SX5 - Indices       ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ FinAtuSX5   - Gerado por EXPORDIC / Upd. V.4.7.2 EFS        ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinAtuSX5( cTexto )
Local aEstrut   := {}
Local aSX5      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0

cTexto  += "Inicio Atualizacao SX5" + CRLF + CRLF

//--------------------------------------------------------------
//Estrutura dos campos
//--------------------------------------------------------------
aEstrut := { "X5_FILIAL", "X5_TABELA", "X5_CHAVE", "X5_DESCRI", "X5_DESCSPA", "X5_DESCENG" }

//--------------------------------------------------------------
// Atualizando dicionário
//--------------------------------------------------------------
oProcess:SetRegua2( Len( aSX5 ) )

dbSelectArea( "SX5" )
SX5->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSX5 )

	oProcess:IncRegua2( "Atualizando tabelas..." )

	If !SX5->( dbSeek( aSX5[nI][1] + aSX5[nI][2] + aSX5[nI][3]) )
		cTexto += "Item da tabela criado. Tabela " + AllTrim( aSX5[nI][1] ) + aSX5[nI][2] + "/" + aSX5[nI][3] + CRLF
		RecLock( "SX5", .T. )
	Else
		cTexto += "Item da tabela alterado. Tabela " + AllTrim( aSX5[nI][1] ) + aSX5[nI][2] + "/" + aSX5[nI][3] + CRLF
		RecLock( "SX5", .F. )
	EndIf

	For nJ := 1 To Len( aSX5[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSX5[nI][nJ] )
		EndIf
	Next nJ

	MsUnLock()

	aAdd( aArqUpd, aSX5[nI][1] )

	If !( aSX5[nI][1] $ cAlias )
		cAlias += aSX5[nI][1] + "/"
	EndIf

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX5" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return aClone( aSX5 )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FinAtuSX1 º Autor ³ TOTVS Protheus     º Data ³ 10/07/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento da gravacao do SX1 - Perguntas     ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ FinAtuSX1           ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinAtuSX1( cTexto )
Local aEstrut   := {}
Local aSX1      := {}
Local aStruDic  := SX1->( dbStruct() )
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTam1     := Len( SX1->X1_GRUPO )
Local nTam2     := Len( SX1->X1_ORDEM )
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}
Local cPerg240	:= PadR("F240BR",Len(SX1->X1_GRUPO))

cTexto  += "Inicio Atualizacao " + cAlias + CRLF + CRLF

//--------------------------------------------------------------
// Estrutura dos campos
//--------------------------------------------------------------
aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"   }


// Perguntas FIN130

/*
aAdd(aSx1, {"FIN130    ","43","Considera Titulos Excluidos?","?Considere Título Excluidos?","Consider Title Excluded?",;
			"MV_CHX","N",1,0,2,"C","",;
			"mv_par43","Sim","Si","Yes","",;
			"","Nao","No","No","",;
			"","","","","",;
			"","","","","",;
			"","","","","",;
			"","","S","",""})
Aadd( aHelpPor, "Seleciona a opção (Sim) para que" )
Aadd( aHelpPor, "seja considerado na posição financeira os ")
Aadd( aHelpPor, " títulos excluídos conforme DataBase. " )
Aadd( aHelpPor, "Seleciona a opção (Não) sera " )
Aadd( aHelpPor, "considerado na posição financeira os ")
Aadd( aHelpPor, "títulos que nao foram deletados conforme DataBase. " )
Aadd( aHelpSpa, "Seleccione opción sino ser considerados" )
Aadd( aHelpSpa, "valores excluidos de acuerdo a DataBase" )
Aadd( aHelpEng, "Select option but to be considered  " )
Aadd( aHelpEng, "securities excluded as DateBase .  " )
PutHelp("P.FIN13043.",aHelpPor,aHelpEng,aHelpSpa,.T.)


			
aAdd(aSx1, {"FIN150    ","37","Considera Titulos Excluidos?","?Considere Título Excluidos?","Consider Title Excluded?",;
			"MV_CHX","N",1,0,2,"C","",;
			"mv_par37","Sim","Si","Yes","",;
			"","Nao","No","No","",;
			"","","","","",;
			"","","","","",;
			"","","","","",;
			"","","S","",""})
aHelpPor	:= {}
aHelpEng	:= {}
aHelpSpa	:= {}
Aadd( aHelpPor, "Seleciona a opção (Sim) para que" )
Aadd( aHelpPor, "seja considerado na posição financeira os títulos")
Aadd( aHelpPor, "excluídos conforme DataBase." )
Aadd( aHelpPor, " Seleciona a opção (Não) sera " )
Aadd( aHelpPor, "considerado na posição financeira os ")
Aadd( aHelpPor, "títulos que nao foram deletados conforme DataBase. " )
Aadd( aHelpSpa, "Seleccione opción sino ser considerados" )
Aadd( aHelpSpa, "valores excluidos de acuerdo a DataBase" )
Aadd( aHelpEng, "Select option but to be considered  " )
Aadd( aHelpEng, "securities excluded as DateBase .  " )
PutHelp("P.FIN15037.",aHelpPor,aHelpEng,aHelpSpa,.T.)
			
//Perguntes FINA240/241
If SX1->(dbSeek(cPerg240+"08"))
	If Alltrim(SX1->X1_PERGUNT) <> Alltrim("Seleciona Filiais?")
		RecLock("SX1",.F.)
		SX1->(dbDelete())
		SX1->(MsUnLock())
		
		If SX1->(dbSeek(cPerg240+"09"))
		   RecLock("SX1",.F.)
		   SX1->(dbDelete())
		   SX1->(MsUnLock())
		EndIf                        
		If SX1->(dbSeek(cPerg240+"10"))
			RecLock("SX1",.F.)
			SX1->(dbDelete())
			SX1->(MsUnLock())
		EndIf    
		If SX1->(dbSeek(cPerg240+"11")) .And. Alltrim(SX1->X1_PERGUNT) == Alltrim("Seleciona Filiais?")
			RecLock("SX1",.F.)
			SX1->(dbDelete())
			SX1->(MsUnLock())
		EndIf
		Aadd(aSx1,{ "F240BR","08","Seleciona Filiais?" ,"¿Selecciona sucursales?" ,"Select Branches?","mv_ch8","C",;
		1,0,2,"C","","mv_par08","Sim","Si","Yes","","","Nao","No","No","","","","","","","","","","","","","",""})
		aHelpPor:={}
		aHelpSpa:={}
		aHelpEng:={}
		Aadd(aHelpPor,"Escolha Sim se deseja selecionar ")
		Aadd(aHelpPor,"as filiais. Esta pergunta somente") 
		Aadd(aHelpPor,"terá efeito em ambiente          ")
		Aadd(aHelpPor," TOPCONNECT / TOTVSDBACCESS.     ")		
		Aadd(aHelpEng,"Enter Yes if you want to select  ")
		Aadd(aHelpEng,"the branches. This question      ")
		Aadd(aHelpEng,"affects TOPCONNECT /TOTVSDBACCESS")
		Aadd(aHelpEng," environment only.")
		Aadd(aHelpSpa,"La opción Sí, permite seleccionar")
		Aadd(aHelpSpa,"las sucursales. Esta pregunta    ")
		Aadd(aHelpSpa,"solo tendra efecto en el entorno ")
		Aadd(aHelpSpa,"TOPCONNECT / TOTVSDBACCESS.")		
		PutSX1Help("P.F240BR08.",aHelpPor,aHelpEng,aHelpSpa)
	EndIf
	
	If SX1->(dbSeek(cPerg240+"09")) .And. Alltrim(SX1->X1_PERGUNT) == Alltrim("Data Agend. Ate")
		RecLock("SX1",.F.)
		SX1->(dbDelete())
		SX1->(MsUnLock())
	EndIf			
	Aadd(aSx1,{ "F240BR",  '09','Considera Agendamento','Considera Agendamiento?','Considerate Schedule?','mv_ch9','C',;
	01 ,0,0,'C','','mv_par09','Sim','Si','Yes','','' ,'Nao','No','No','' ,'','','','','','','','','','','','','',''})
	aHelpPor:={}
	aHelpSpa:={}
	aHelpEng:={}
	Aadd(aHelpPor,'Se considera agendamento, sistema ')
	Aadd(aHelpPor,'exibe os titulos definido no      ')
	Aadd(aHelpPor,'intervalo de agendamento, caso    ')
	Aadd(aHelpPor,'não, considera o intervalo da     ')
	Aadd(aHelpPor,'data de vencimento.               ')
	Aadd(aHelpSpa,'Si considera agendamiento, el     ')
	Aadd(aHelpSpa,'sistema presenta los titulos      ')
	Aadd(aHelpSpa,'solamente del rango de fecha de   ')            
	Aadd(aHelpSpa,'agendamiento, si no, presente del ')
	Aadd(aHelpSpa,' rango de fecha de vencimiento.   ')	
	Aadd(aHelpEng,'If considerate schedule, the system')
	Aadd(aHelpEng,'show recepiet only schedule date  ')
	Aadd(aHelpEng,'range, Ifnot show recepiet        ')
	Aadd(aHelpEng,'only payment date.                ')
	PutSX1Help("P.F240BR09.",aHelpPor, aHelpEng, aHelpSpa)
	
	Aadd(aSx1,{ "F240BR",  '10','Data Agend.De?'	      ,'Fecha Agend. De ?','Schedule Date From?','mv_cha','D',;
	08 ,0,0,'G','','mv_par10','','','','','' ,'','','','01/01/08' ,'','','','','','','','','','','','','',''})
	aHelpPor:={}
	aHelpSpa:={}
	aHelpEng:={}
	Aadd(aHelpPor,'Preencher a data de agendamento     ')
	Aadd(aHelpPor,'inicial se considera agendamento.   ')
	Aadd(aHelpSpa,'Llenar la fecha de agendamiento     ')
	Aadd(aHelpSpa,'inicial si opto por considera       ')
	Aadd(aHelpSpa,'agendamiento.                       ')            
	Aadd(aHelpEng,'Fill the schedule start date if the ')
	Aadd(aHelpEng,'choice equal considerate schedule.  ')
	PutSX1Help("P.F240BR10.",aHelpPor, aHelpEng, aHelpSpa)	
	
	Aadd(aSx1,{ "F240BR",  '11','Data Agend.Ate?' 		  ,'Fecha Agend. Ate?','Schedule Date To?'	,'mv_chb','D',;
	08 ,0,0,'G','','mv_par11','','','','','' ,'','','','30/12/99' ,'','','','','','','','','','','','','',''})	
	aHelpPor:={}
	aHelpSpa:={}
	aHelpEng:={}
	Aadd(aHelpPor,'Preencher a data de agendamento     ')
	Aadd(aHelpPor,'final se considera agendamento.     ')
	Aadd(aHelpSpa,'Llenar la fecha de agendamiento     ')
	Aadd(aHelpSpa,'final si opto por considera         ')
	Aadd(aHelpSpa,'agendamiento                        ')
	Aadd(aHelpEng,'Fill the schedule final date if the ')
	Aadd(aHelpEng,'choice equal considerate schedule.  ')
	PutSX1Help("P.F240BR11.",aHelpPor, aHelpEng, aHelpSpa)			
EndIf
*/

			
//--------------------------------------------------------------
// Atualizando dicionário
//--------------------------------------------------------------
oProcess:SetRegua2( Len( aSX1 ) )

dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSX1 )

	oProcess:IncRegua2( "Atualizando perguntas..." )

	If !SX1->( dbSeek( PadR( aSX1[nI][1], nTam1 ) + PadR( aSX1[nI][2], nTam2 ) ) )
		cTexto +=  "Pergunta Criada. Grupo/Ordem "  + aSX1[nI][1] + "/" + aSX1[nI][2] + CRLF
		RecLock( "SX1", .T. )
	Else
		cTexto +=  "Pergunta Alterada. Grupo/Ordem " + aSX1[nI][1] + "/" + aSX1[nI][2] + CRLF
		RecLock( "SX1", .F. )
	EndIf

	For nJ := 1 To Len( aSX1[nI] )
		If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
			SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aSX1[nI][nJ] ) )
		EndIf
	Next nJ

	MsUnLock()

Next nI

cTexto += CRLF + "Final da Atualizacao" + " SX1" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return aClone( aSX1 )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FinAtuSX9 º Autor ³ TOTVS Protheus     º Data ³  14/09/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento da gravacao do SX9 - Relacionament ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ FinAtuSX9   - Gerado por EXPORDIC / Upd. V.4.7.2 EFS        ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinAtuSX9( cTexto )
Local aEstrut   := {}
Local aSX9      := {}
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTamSeek  := Len( SX9->X9_DOM )

cTexto  += "Inicio da Atualizacao" + " SX9" + CRLF + CRLF

aEstrut := { "X9_DOM"   , "X9_IDENT"  , "X9_CDOM"   , "X9_EXPDOM", "X9_EXPCDOM" ,"X9_PROPRI", ;
             "X9_LIGDOM", "X9_LIGCDOM", "X9_CONDSQL", "X9_USEFIL", "X9_ENABLE" }

cTexto += CRLF + "Final da Atualizacao" + " SX9" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return aClone( aSX9 )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FinAtuHlp º Autor ³ TOTVS Protheus     º Data ³  14/09/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento da gravacao dos Helps de Campos    ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ FinAtuHlp   - Gerado por EXPORDIC / Upd. V.4.7.2 EFS        ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinAtuHlp( cTexto )
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {}

cTexto  += "Inicio da Atualizacao" + " " + "Helps de Campos" + CRLF + CRLF


oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

// Helps Tabela FJU

/*

aHlpPor := {}
aAdd( aHlpPor, 'Código da filial do sistema' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFJU_FILIAL", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + SX3->X3_CAMPO + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Campo que permite ao usuário indentificar' )
aAdd( aHlpPor, 'um conjunto de titulos que pertence ao mesmo grupo ou filial.' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFJU_PREFIX", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + SX3->X3_CAMPO + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Campo que identifica o numero do titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFJU_NUM", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + SX3->X3_CAMPO + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Sistema permite o controle de cada' )
aAdd( aHlpPor, 'um dos desdobramentos de um titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFJU_PARCEL   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + SX3->X3_CAMPO + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Cliente/Fornecedor do Titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFJU_CLIFOR   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + SX3->X3_CAMPO + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Campo que indentifica cada loja' )
aAdd( aHlpPor, 'de um cliente ou fornecedor' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFJU_LOJA   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + SX3->X3_CAMPO + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Campo que indentifica a origem' )
aAdd( aHlpPor, 'da carteita do titulo Pagar/Receber' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFJU_CART   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + SX3->X3_CAMPO + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Data de emissao do titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFJU_EMIS   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + SX3->X3_CAMPO + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Valor do Titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFJU_VALOR   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + SX3->X3_CAMPO + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Data da exclusão do titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFJU_DTEXCL   ", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + SX3->X3_CAMPO + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Vencimento Real do titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFJU_VENREA", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + SX3->X3_CAMPO + CRLF

aHlpPor := {}
aAdd( aHlpPor, 'Tipo do titulo' )
aHlpEng := {}
aHlpSpa := {}

PutHelp( "PFJU_TIPO", aHlpPor, aHlpEng, aHlpSpa, .T. )
cTexto += "Atualizado o Help do campo " + SX3->X3_CAMPO + CRLF


cTexto += "Atualizado o Help do campo " + SX3->X3_CAMPO + CRLF

cTexto += CRLF + "Final da Atualizacao" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF
*/

Return {}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ FSAtuHlpXº Autor ³ TOTVS Protheus     º Data ³  14/09/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento da gravacao dos Helps de Perguntas ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ FinAtuHlpX1 - Gerado por EXPORDIC / Upd. V.4.7.2 EFS        ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinAtuHlpX1( cTexto )
Local aHlpPor   := {}
Local aHlpEng   := {}
Local aHlpSpa   := {} 
Local aSX1      := {}
Local cChave 	:= ""

cTexto  += "Inicio da Atualizacao" + " " + "Helps de Perguntas" + CRLF + CRLF


oProcess:IncRegua2( "Atualizando Helps de Perguntas ..." )

cTexto += "Atualizado o Help de Perguntas" + cChave + CRLF

cTexto += CRLF + "Final da Atualizacao" + " " + "Helps de Perguntas" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return {}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³ESCEMPRESAºAutor  ³ Ernani Forastieri  º Data ³  27/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao Generica para escolha de Empresa, montado pelo SM0_ º±±
±±º          ³ Retorna vetor contendo as selecoes feitas.                 º±±
±±º          ³ Se nao For marcada nenhuma o vetor volta vazio.            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EscEmpresa()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametro  nTipo                           ³
//³ 1  - Monta com Todas Empresas/Filiais      ³
//³ 2  - Monta so com Empresas                 ³
//³ 3  - Monta so com Filiais de uma Empresa   ³
//³                                            ³
//³ Parametro  aMarcadas                       ³
//³ Vetor com Empresas/Filiais pre marcadas    ³
//³                                            ³
//³ Parametro  cEmpSel                         ³
//³ Empresa que sera usada para montar selecao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local   aSalvAmb := GetArea()
Local   aSalvSM0 := {}
Local   aRet     := {}
Local   aVetor   := {}
Local   oDlg     := NIL
Local   oChkMar  := NIL
Local   oLbx     := NIL
Local   oMascEmp := NIL
Local   oMascFil := NIL
Local   oButMarc := NIL
Local   oButDMar := NIL
Local   oButInv  := NIL
Local   oSay     := NIL
Local   oOk      := LoadBitmap( GetResources(), "LBOK" )
Local   oNo      := LoadBitmap( GetResources(), "LBNO" )
Local   lChk     := .F.
Local   lOk      := .F.
Local   lTeveMarc:= .F.
Local   cVar     := ""
Local   cNomEmp  := ""
Local   cMascEmp := "??"
Local   cMascFil := "??"

Local   aMarcadas  := {}


If !MyOpenSm0(.F.)
	Return aRet
EndIf


dbSelectArea( "SM0" )
aSalvSM0 := SM0->( GetArea() )
dbSetOrder( 1 )
dbGoTop()

While !SM0->( EOF() )

	If aScan( aVetor, {|x| x[2] == SM0->M0_CODIGO} ) == 0
		aAdd(  aVetor, { aScan( aMarcadas, {|x| x[1] == SM0->M0_CODIGO .and. x[2] == SM0->M0_CODFIL} ) > 0, SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOME, SM0->M0_FILIAL } )
	EndIf

	dbSkip()
End

RestArea( aSalvSM0 )

Define MSDialog  oDlg Title "" From 0, 0 To 270, 396 Pixel

oDlg:cToolTip := "Tela para Múltiplas Seleções de Empresas/Filiais"

oDlg:cTitle   := "Selecione a(s) Empresa(s) para Atualização"

@ 10, 10 Listbox  oLbx Var  cVar Fields Header " ", " ", "Empresa" Size 178, 095 Of oDlg Pixel
oLbx:SetArray(  aVetor )
oLbx:bLine := {|| {IIf( aVetor[oLbx:nAt, 1], oOk, oNo ), ;
aVetor[oLbx:nAt, 2], ;
aVetor[oLbx:nAt, 4]}}
oLbx:BlDblClick := { || aVetor[oLbx:nAt, 1] := !aVetor[oLbx:nAt, 1], VerTodos( aVetor, @lChk, oChkMar ), oChkMar:Refresh(), oLbx:Refresh()}
oLbx:cToolTip   :=  oDlg:cTitle
oLbx:lHScroll   := .F. // NoScroll

@ 112, 10 CheckBox oChkMar Var  lChk Prompt "Todos"   Message  Size 40, 007 Pixel Of oDlg;
on Click MarcaTodos( lChk, @aVetor, oLbx )

@ 123, 10 Button oButInv Prompt "&Inverter"  Size 32, 12 Pixel Action ( InvSelecao( @aVetor, oLbx, @lChk, oChkMar ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Inverter Seleção" Of oDlg

// Marca/Desmarca por mascara
@ 113, 51 Say  oSay Prompt "Empresa" Size  40, 08 Of oDlg Pixel
@ 112, 80 MSGet  oMascEmp Var  cMascEmp Size  05, 05 Pixel Picture "@!"  Valid (  cMascEmp := StrTran( cMascEmp, " ", "?" ), cMascFil := StrTran( cMascFil, " ", "?" ), oMascEmp:Refresh(), .T. ) ;
Message "Máscara Empresa ( ?? )"  Of oDlg
@ 123, 50 Button oButMarc Prompt "&Marcar"    Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .T. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Marcar usando máscara ( ?? )"    Of oDlg
@ 123, 80 Button oButDMar Prompt "&Desmarcar" Size 32, 12 Pixel Action ( MarcaMas( oLbx, aVetor, cMascEmp, .F. ), VerTodos( aVetor, @lChk, oChkMar ) ) ;
Message "Desmarcar usando máscara ( ?? )" Of oDlg

Define SButton From 111, 125 Type 1 Action ( RetSelecao( @aRet, aVetor ), oDlg:End() ) OnStop "Confirma a Seleção"  Enable Of oDlg
Define SButton From 111, 158 Type 2 Action ( IIf( lTeveMarc, aRet :=  aMarcadas, .T. ), oDlg:End() ) OnStop "Abandona a Seleção" Enable Of oDlg
Activate MSDialog  oDlg Center

RestArea( aSalvAmb )
dbSelectArea( "SM0" )
dbCloseArea()

Return  aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³MARCATODOSºAutor  ³ Ernani Forastieri  º Data ³  27/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao Auxiliar para marcar/desmarcar todos os itens do    º±±
±±º          ³ ListBox ativo                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MarcaTodos( lMarca, aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := lMarca
Next nI

oLbx:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³INVSELECAOºAutor  ³ Ernani Forastieri  º Data ³  27/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao Auxiliar para inverter selecao do ListBox Ativo     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function InvSelecao( aVetor, oLbx )
Local  nI := 0

For nI := 1 To Len( aVetor )
	aVetor[nI][1] := !aVetor[nI][1]
Next nI

oLbx:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³RETSELECAOºAutor  ³ Ernani Forastieri  º Data ³  27/09/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao Auxiliar que monta o retorno com as selecoes        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RetSelecao( aRet, aVetor )
Local  nI    := 0

aRet := {}
For nI := 1 To Len( aVetor )
	If aVetor[nI][1]
		aAdd( aRet, { aVetor[nI][2] , aVetor[nI][3], aVetor[nI][2] +  aVetor[nI][3] } )
	EndIf
Next nI

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³ MARCAMAS ºAutor  ³ Ernani Forastieri  º Data ³  20/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para marcar/desmarcar usando mascaras               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MarcaMas( oLbx, aVetor, cMascEmp, lMarDes )
Local cPos1 := SubStr( cMascEmp, 1, 1 )
Local cPos2 := SubStr( cMascEmp, 2, 1 )
Local nPos  := oLbx:nAt
Local nZ    := 0

For nZ := 1 To Len( aVetor )
	If cPos1 == "?" .or. SubStr( aVetor[nZ][2], 1, 1 ) == cPos1
		If cPos2 == "?" .or. SubStr( aVetor[nZ][2], 2, 1 ) == cPos2
			aVetor[nZ][1] :=  lMarDes
		EndIf
	EndIf
Next

oLbx:nAt := nPos
oLbx:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³ VERTODOS ºAutor  ³ Ernani Forastieri  º Data ³  20/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao auxiliar para verificar se estao todos marcardos    º±±
±±º          ³ ou nao                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VerTodos( aVetor, lChk, oChkMar )
Local lTTrue := .T.
Local nI     := 0

For nI := 1 To Len( aVetor )
	lTTrue := IIf( !aVetor[nI][1], .F., lTTrue )
Next nI

lChk := IIf( lTTrue, .T., .F. )
oChkMar:Refresh()

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ MyOpenSM0º Autor ³ TOTVS Protheus     º Data ³  14/09/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao³ Funcao de processamento abertura do SM0 modo exclusivo     ³±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³ Uso      ³ MyOpenSM0  - Gerado por EXPORDIC / Upd. V.4.7.2 EFS        ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MyOpenSM0(lShared)

Local lOpen := .F.
Local nLoop := 0

For nLoop := 1 To 20
	dbUseArea( .T., , "SIGAMAT.EMP", "SM0", lShared, .F. )

	If !Empty( Select( "SM0" ) )
		lOpen := .T.
		dbSetIndex( "SIGAMAT.IND" )
		Exit
	EndIf

	Sleep( 500 )

Next nLoop

If !lOpen
	MsgStop( "Não foi possível a abertura da tabela " + ;
	IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
EndIf

Return lOpen

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³FinTamSXG ³ Autor ³ Totvs                 ³ Data ³ 28/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o tamanho do grupo de campo 033 	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Implantacao FIN                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FinTamSXG( cGrupo, nTamPad )
Local aRet

DbSelectArea( "SXG" )
SXG->( DbSetOrder( 1 ) )
If SXG->( DbSeek( cGrupo ) )
	nTamPad	:= SXG->XG_SIZE
	aRet := { nTamPad, "@!", nTamPad, nTamPad }
Else
	aRet := { nTamPad, "@!", nTamPad, nTamPad }
EndIf

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FINUpdField
Atualiza pontualmente a propriedade de tabelas do dicionário de dados                                                   

@param cAlias
@param nOrder
@param cIndexKey
@param cField
@param uNewValue
@param uTestValue
@param bBlockValue

@return lRet

@author Marylly A. Silva
@since 16/02/2012
@version P11 
/*/
//-------------------------------------------------------------------
Static Function FINUpdField(cAlias, nOrder, cIndexKey, cField, uNewValue, uTestValue, bBlockValue)
Local aArea       := (cAlias)->(GetArea())
Local lRet        := .F.
Local nFieldPos   := 0
Local aStruct     := {}
Local nPosField   := 0
Local uValueField := 0

dbSelectArea(cAlias)
(cAlias)->(dbSetOrder(nOrder))

// verifica se o registro existe no alias
If !(cAlias)->(dbSeek(cIndexKey))
	RestArea(aArea)
	Return lRet
EndIf

// verificar se o campo existe no alias
nFieldPos := (cAlias)->(FieldPos(cField))

If nFieldPos == 0
	RestArea(aArea)
	Return lRet
EndIf

aStruct := (cAlias)->(dbStruct())
nPosFIELD := aScan( aStruct ,{|aField|Alltrim(Upper(aField[1])) == Alltrim(Upper(cField)) } )
uValueField := (cAlias)->(FieldGet(nFieldPos))
If bBlockValue == Nil
	// teste por valor
	If uTestValue == Nil	
		If nPosFIELD >0
			If aStruct[nPosFIELD][2] == "C"
				uValueField := AllTrim(uValueField)
				uTestValue  := AllTrim(uNewValue)
			EndIf
		EndIf
		
		// Somente atualiza se o valor gravado no campo (uValueField) for diferente do novo valor (uNewValue)
		lRet := !(uValueField == uTestValue)		
		If lRet
			RecLock(cAlias, .F.)
			(cAlias)->(FieldPut(nFieldPos, uNewValue))
			MsUnlock()
		EndIf
		RestArea(aArea)		
	Else		
		If nPosFIELD >0
			// se for caracter deve retirar os brancos e maiusculas antes de comparar.
			If aStruct[nPosFIELD][2] == "C"
				uValueField := AllTrim(Upper(uValueField))
				uTestValue  := AllTrim(Upper(uTestValue))
			EndIf
		EndIf		
		// se o teste existe, testa e altera o valor
		If uTestValue == uValueField
			RecLock(cAlias, .F.)
			(cAlias)->(FieldPut(nFieldPos, uNewValue))
			MsUnlock()			
			RestArea(aArea)
			lRet := .T.
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} UpdUnique
Alterar chave unica da tabela, sem precisar dropar.

@param cTable - Tabela em questão.
@param cChave - Nova Chave


@author Caique 
@since 19/12/2014
@version P11 
/*/
//-------------------------------------------------------------------

// Static aqui
Static Function UpdUnique(cTable,cChave)

Local lRet:= .F.

IF Select("__TRB__") > 0
	dbSelectArea("__TRB__")
	dbCloseArea()
Endif

USE &cTable ALIAS "__TRB__" Exclusive New Via 'TOPCONN'

lIntransaction := .f.

IF !NetErr() .and. ( TCUNIQUE(cTable,"") == 0 )
	conout("Sucesso: "+cTable+" - Chave unica deletada" )
else
	conout("Error: "+cTable+"- Ao deletar chave " )
EndIf

IF !NetErr() .and. ( TCUNIQUE(cTable,cChave) == 0 )
	conout("Sucesso: "+cTable+" - Chave unica criada : "+cChave)
	lRet:= .T.
else
	conout("Error: "+cTable+" ao criar chave. ")
EndIf

IF Select("__TRB__") > 0
	dbSelectArea("__TRB__")
	dbCloseArea()
Endif

Return
