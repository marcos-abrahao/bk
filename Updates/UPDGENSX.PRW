#include "Protheus.ch"       

//#include "FIN.ch"   
//#INCLUDE "SET.CH"

// Define tamanho de 8 posicoes para os campos de Lote Financeiro
#DEFINE N_TAM_LOTE		8
#DEFINE FIN_LAST_UPDATED 		"27/01/2020"
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
User Function UPDGENSX()

Local   aSay      := {}
Local   aButton   := {}
Local   aMarcadas := {}
Local   cTitulo   := "Atualização de campos de tabelas SX em todas as empresas"
Local   cDesc1    := "** Atualização " + FIN_LAST_UPDATED
Local   cDesc2    := "" //"Alterar o parâmetro MV_MIGGCT para .T."
Local   cDesc3    := "" //"Acertar compartilhamento da tabela FIL (c/c fornecedores) com a tabela SA2 (1,2,2)"
Local   cDesc4    := "" //"Acertar nome dos campos CN9_CLIENT e CN9_LOJACL."
Local   cDesc5    := "" //"Acertar o dicionario do campo A1_NATUREZ (usado em todos os módulos)"
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
		If  MsgNoYes( "Confirma a atualização dos campos?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lOk
				Final( "Atualização Concluída." )
			Else
				Final( "Atualização não Realizada." )
			EndIf

		Else
			MsgStop( "Atualização não Realizada.", "UPDBK" )

		EndIf

	Else
		MsgStop( "Atualização não Realizada.", "UPDBK" )

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

			If !( lOpen := MyOpenSm0(.T.) )  // Era .F.
				MsgStop( "Atualização da empresa " + aRecnoSM0[nI][2] + " não efetuada." )
				Exit
			EndIf

			SM0->( dbGoTo( aRecnoSM0[nI][1] ) )

			RpcSetType( 3 )
			RpcSetEnv( SM0->M0_CODIGO, SM0->M0_CODFIL )

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			cTexto += Replicate( "-", 70 ) + CRLF
			cTexto += "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF + CRLF

			oProcess:SetRegua1( 2 )

			oProcess:IncRegua1( "Atualizando - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//AtuGenP12( @cTexto )

			oProcess:IncRegua1( "Atualizando - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//AtuGenDic( @cTexto )

			AtuGenPar( @cTexto )
			//AtuGenE1( @cTexto )
			//AtuGenX3( @cTexto )
			//AtuGenP12( @cTexto )


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
			
			//cTexto := cAux + cTexto + CRLF - retirado em 08/11/19 para não inchar o log
			//cTexto += CRLF
			cTexto += Replicate( "-", 70 ) + CRLF
			cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
			cTexto += Replicate( "-", 70 ) + CRLF
			
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


Static Function AtuGenPar( cTexto )
Local cAlias    := ""
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0
Local nCamp	    := 0
Local aParXX    := {}

//cTexto  += "Inicio da Atualizacao" + CRLF + CRLF

dbSelectArea( "SX6" )
SX6->( dbSetOrder( 1 ) )
SX6->( dbGoTop() )

oProcess:SetRegua2( 2 )

/*
oProcess:IncRegua2( "Atualizando parametro MV_XXMIMPC..." )

If dbSeek(xFilial()+"MV_XXMIMPC")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	//SX6->X6_CONTEUD := ".T." 
	//cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf

oProcess:IncRegua2( "Atualizando parametro MV_XXINCID..." )
If dbSeek(xFilial()+"MV_XXINCID")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	//SX6->X6_CONTEUD := ".T." 
	//cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf

oProcess:IncRegua2( "Atualizando parametro MV_XXCOMPE..." )
If dbSeek(xFilial()+"MV_XXCOMPE")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	//SX6->X6_CONTEUD := ".T." 
	//cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/

/*
oProcess:IncRegua2( "Atualizando parametro MV_XXGFIN..." )
If dbSeek(xFilial()+"MV_XXGFIN")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	//SX6->X6_CONTEUD := "000011/000177/000016"
	//cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/

/*
oProcess:IncRegua2( "Atualizando parametro MV_XXUSERS..." )
If dbSeek(xFilial()+"MV_XXUSERS")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "000006/000011/000016/000076/000093/000177/000171/000056/000175"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/

/*
oProcess:IncRegua2( "Atualizando parametro MV_XXGRPMD - Grupo Master Diretoria..." )
If dbSeek(xFilial()+"MV_XXGRPMD")
	RecLock( "SX6", .F. )
    // 04/04/19
	//cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	//SX6->X6_CONTEUD := "000007/000010/000171/000027/000008"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf

oProcess:IncRegua2( "Atualizando parametro MV_XXGGCT - Gerente de Gestao de Contratos..." )
If dbSeek(xFilial()+"MV_XXGGCT")
	RecLock( "SX6", .F. )
    // 04/04/19
	//cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	//SX6->X6_CONTEUD := "000171"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/



/*
oProcess:IncRegua2( "Atualizando parametro MV_XXVRVAV - cVRVA_Verb..." )
If dbSeek(xFilial()+"MV_XXVRVAV")
	RecLock( "SX6", .F. )
    // 16/04/19
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "|613|614|662|681|682|702|873|874|895|896"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/

/*
//"|510|607|665|679|724|739|825|900|"
oProcess:IncRegua2( "Atualizando parametro MV_XXSINOV - cSINO_Verb..." )
If dbSeek(xFilial()+"MV_XXSINOV ")
	RecLock( "SX6", .F. )
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "|510|607|665|679|724|739|825|900|"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/

/*
//"|510|607|665|679|724|732|739|825|900|"
oProcess:IncRegua2( "Atualizando parametro MV_XXSINOP - cSINO_Prod..." )
If dbSeek(xFilial()+"MV_XXSINOP ")
	RecLock( "SX6", .F. )
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "|510|607|665|679|724|732|739|825|900|"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/


/*

aParXX := {"MV_XXPROVE","MV_XXDESCO","MV_XXVTVER","MV_XXVTPRD","MV_XXVRVAV","MV_XXVRVAP","MV_XXASSMV","MV_XXASSMP","MV_XXSINOV","MV_XXSINOP","MV_XXCCREV","MV_XXCCREP","MV_XXCDPRP","MV_XXCDPRG","MV_XXCEXMP","MV_XXCMFGP","MV_XXCDCH","MV_XXSEMAF","MV_XXPLR","MV_XXGFIN"}
oProcess:IncRegua2( "Atualizando parametro MV_XXPLR..." )
For ni:= 1 To Len(aParXX)

	If dbSeek(xFilial()+aParXX[nI])
		RecLock( "SX6", .F. )
	
		cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
		//SX6->X6_CONTEUD := ".T." 
		//cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF
	
		dbCommit()
		MsUnLock()
	EndIf
	
Next
*/

/*
oProcess:IncRegua2( "Atualizando parametro MV_VALCNPJ - Bloqueio de forn. duplicado..." )
If dbSeek(xFilial()+"MV_VALCNPJ")
	RecLock( "SX6", .F. )
    // 05/11/19
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "2"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf

oProcess:IncRegua2( "Atualizando parametro MV_VALCPF - Bloqueio de forn. duplicado..." )
If dbSeek(xFilial()+"MV_VALCPF")
	RecLock( "SX6", .F. )
    // 05/11/19
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "2"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/

/*
oProcess:IncRegua2( "Atualizando parametro MV_CNNOPED - Não gerar pedido zerado na medição..." )
If dbSeek(xFilial()+"MV_CNNOPED")
	RecLock( "SX6", .F. )
    // 05/11/19
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	//SX6->X6_CONTEUD := "2"
	//cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/

// 16/12/19 - Inclusão Nelson Oliveira
//oProcess:IncRegua2( "Atualizando parametro MV_XXUSERS..." )
//If dbSeek(xFilial()+"MV_XXUSERS")
//	RecLock( "SX6", .F. )

//	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
//	SX6->X6_CONTEUD := "000006/000011/000016/000076/000093/000177/000171/000056/000175/000103/000165/"
//	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

//	dbCommit()
//	MsUnLock()
//EndIf

// 14/01/20 - Alterar parametro MV_CTBAPLA
/*
oProcess:IncRegua2( "Atualizando parametro MV_CTBAPLA..." )
If dbSeek(xFilial()+"MV_CTBAPLA")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "4"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf


// Permitir digitar dados da DIRF no Ducumento de Entrada
oProcess:IncRegua2( "Atualizando parametro MV_VISDIRF..." )
If dbSeek(xFilial()+"MV_VISDIRF")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "1"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/

/*
oProcess:IncRegua2( "Atualizando parametro MV_XXGFIN..." )
If dbSeek(xFilial()+"MV_XXGFIN")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "000011/000194/000016/000103/ "
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf


oProcess:IncRegua2( "Atualizando parametro MV_XXUSERS..." )
If dbSeek(xFilial()+"MV_XXUSERS")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "000006/000011/000016/000076/000093/000194/000171/000056/000175/000103/000165/"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/

oProcess:IncRegua2( "Atualizando parametro MV_FRTBASE..." )
If dbSeek(xFilial()+"MV_FRTBASE")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := ".T."
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf

cTexto += CRLF + "Final da Atualizacao" + CRLF 

Return


Static Function AtuGenDic( cTexto )

//cTexto  += "Inicio da Atualizacao" + CRLF 

// Acerto do dicionario X3_USADO para o campo A1_NATUREZ

oProcess:IncRegua2( "Acerto do dicionario X3_FOLDER campo CTT_XXDESC.." )
dbSelectArea( "SX3" )
dbSetOrder( 2 )

If SX3->( dbSeek( "CTT_XXDESC" ) )

	cTexto += "Conteudo anterior X3_FOLDER " + SX3->X3_FOLDER  + CRLF

	RecLock( "SX3", .F. )
	SX3->X3_FOLDER := "1"
	SX3->X3_BROWSE := "S"

	cTexto += "Conteudo alterado X3_FOLDER " + SX3->X3_FOLDER  + CRLF

	dbCommit()
	MsUnLock()

EndIf

//cTexto += CRLF + "Final da Atualizacao" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return



Static Function AtuGenX3( cTexto )


cTexto  += "Inicio da Atualizacao X31UPDTABLE" + CRLF 


oProcess:IncRegua2( "Incluir campo no banco de dados via X31UPDTABLE(“ALIAS”)" )

dbSelectArea( "SX3" )
//APPEND FROM \sx3c1alm1.dtc

// 18/08/19 - Retenção Contratual
//APPEND FROM \sx3cna.dtc
//X31UPDTABLE("CNA")
//APPEND FROM \sx3sf2.dtc
//X31UPDTABLE("SF2")

// 21/08/19 - Retenção Contratual
//APPEND FROM \sx3sc5.dtc
//X31UPDTABLE("SC5")

// 22/08/19 - Retenção Contratual
//APPEND FROM \sx3se1.dtc
//X31UPDTABLE("SE1")

// 23/09/19
//APPEND FROM \sx3e1nd.dtc
//X31UPDTABLE("SE1")

// 25/09/19
//APPEND FROM \sx3e1ndc.dtc
//X31UPDTABLE("SE1")

//dbSelectArea( "SX3" )
//APPEND FROM \sx3cndndc.dtc
//X31UPDTABLE("CND")

// 30/09/19 - NDC
//APPEND FROM \sx3sc5.dtc
//X31UPDTABLE("SC5")

//APPEND FROM \x3nd.dtc
//X31UPDTABLE("CND")

// 10/10/19
//APPEND FROM \x3e1comp.dtc
//X31UPDTABLE("SE1")

// 07/01/20 - Numeração Bordero BK
//dbSelectArea( "SIX" )
//APPEND FROM \xiszu.dtc

//dbSelectArea( "SX2" )
//APPEND FROM \x2szu.dtc

//dbSelectArea( "SX3" )
//APPEND FROM \x3szu.dtc

// Incluir competência da Medição no browse do SC5
dbSelectArea( "SX3" )
APPEND FROM \x3sc5.dtc

X31UPDTABLE("SC5")

cTexto += CRLF + "Final da Atualizacao" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return




Static Function AtuGenE1( cTexto )


cTexto  += "Inicio da Atualizacao" + CRLF 

// Acerto do dicionario X3_USADO para o campo A1_NATUREZ

oProcess:IncRegua2( "Acerto do dicionario X3_USADO para o campo E1_VENCORI.." )
dbSelectArea( "SX3" )
dbSetOrder( 2 )

If SX3->( dbSeek( "E1_VENCORI" ) )

	RecLock( "SX3", .F. )
	SX3->X3_USADO := "€€€€€€€€€€€€€€ "
	SX3->X3_WHEN  := ".F."

	dbCommit()
	MsUnLock()

EndIf

cTexto += CRLF + "Final da Atualizacao" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return







Static Function AtuGenP12( cTexto )
Local cAlias    := ""
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0
Local nCamp	  := 0

cTexto  += "Inicio da Atualizacao" + CRLF 

/*
dbSelectArea( "SX6" )
SX6->( dbSetOrder( 1 ) )
SX6->( dbGoTop() )

oProcess:SetRegua2( 1 )

oProcess:IncRegua2( "Atualizando parametro MV_MIGGCT..." )

If dbSeek(xFilial()+"MV_MIGGCT")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo anterior " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := ".T." 
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/

oProcess:IncRegua2( "Acertando o compartilhamento da tabela FIL.." )
dbSelectArea( "SX2" )
dbSetOrder( 1 )

aSx2 := {"FIL"}
For nI := 1 To Len( aSX2 )

	If SX2->( dbSeek( aSX2[nI] ) )

		RecLock( "SX2", .F. )
		cTexto += "Tabela " + aSX2[nI] + " conteudo anterior " + SX2->X2_MODO + CRLF
		SX2->X2_MODO := "C"
		cTexto += "Tabela " + aSX2[nI] + " conteudo alterado " + SX2->X2_MODO + CRLF
		dbCommit()
		MsUnLock()

	EndIf

Next nI

oProcess:IncRegua2( "Acertando nome dos campos CN9_CLIENT e CN9_LOJACL.." )
dbSelectArea( "SX3" )
dbSetOrder( 2 )

aSx2 := {"CN9_CLIENT","CN9_LOJACL"}
aSx3 := {"Cliente","Loja"}
For nI := 1 To Len( aSX2 )

	If SX3->( dbSeek( aSX2[nI] ) )

		RecLock( "SX3", .F. )
		cTexto += "Campo " + aSX2[nI] + " conteudo anterior " + SX3->X3_TITULO + CRLF
		SX3->X3_TITULO := aSX3[nI]
		cTexto += "Campo " + aSX2[nI] + " conteudo alterado " + SX3->X3_TITULO + CRLF
		dbCommit()
		MsUnLock()

	EndIf

Next nI


// Acerto do dicionario X3_USADO para o campo A1_NATUREZ
/*
oProcess:IncRegua2( "Acerto do dicionario X3_USADO para o campo A1_NATUREZ.." )
dbSelectArea( "SX3" )
dbSetOrder( 2 )

If SX3->( dbSeek( "A1_NATUREZ" ) )

	RecLock( "SX3", .F. )
	SX3->X3_USADO := "€€€€€€€€€€€€€€ "

	dbCommit()
	MsUnLock()

EndIf
*/




cTexto += CRLF + "Final da Atualizacao" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return




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


If !MyOpenSm0(.T.)  // ERA .F.
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
