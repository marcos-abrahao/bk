#include "Protheus.ch"       
//#include "RwMAKE.ch"       

//#include "FIN.ch"   
//#INCLUDE "SET.CH"

// Define tamanho de 8 posicoes para os campos de Lote Financeiro
#DEFINE N_TAM_LOTE		8
#DEFINE FIN_LAST_UPDATED 		"30/07/2020"
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
//Local   cTCBuild  := "TCGetBuild"
Local   cTexto    := ""
//Local   cTopBuild := ""
Local   lOpen     := .F.
Local   lRet      := .T.
Local   nI        := 0
Local   nPos      := 0
//Local   nRecno    := 0
//Local   nX        := 0
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

			AtuGenPar( @cTexto )  // 30/07/20
			
			//AtuGenXX( @cTexto )

			////AtuGenFil( @cTexto )

			//AtuGenX3( @cTexto )   //29/07/20

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
			
			cFileLog := MemoWrite( GetNextAlias() + ".log", cTexto )

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
// Local cAlias    := ""
// Local cEmpr     := ""
// Local cPath     := ""
// Local nI        := 0
// Local nJ        := 0
// Local nCamp	    := 0
// Local aParXX    := {}

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

/*
oProcess:IncRegua2( "Atualizando parametro MV_FRTBASE..." )
If dbSeek(xFilial()+"MV_FRTBASE")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := ".T."
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/

/*
oProcess:IncRegua2( "Atualizando parametro MV_CNPEDVE (medição direto no pedido de venda)..." )
If dbSeek(xFilial()+"MV_CNPEDVE")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := ".T."
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf


oProcess:IncRegua2( "Atualizando parametro MV_DATAFIS..." )
If dbSeek(xFilial()+"MV_DATAFIS")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "20191231"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf

oProcess:IncRegua2( "Atualizando parametro MV_DATAFIN..." )
If dbSeek(xFilial()+"MV_DATAFIN")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "20191231"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/

//MV_VENCIRF 03/03/20
/*
If dbSeek(xFilial()+"MV_VENCIRF")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "E"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/

/*
If dbSeek(xFilial()+"MV_XXSINOP")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + TRIM(SX6->X6_CONTEUD) + CRLF
	//SX6->X6_CONTEUD := "E"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + TRIM(SX6->X6_CONTEUD) + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/


// 28/01/20 - Alterar parametro MV_CTBAPLA PARA 2
/*
oProcess:IncRegua2( "Atualizando parametro MV_CTBAPLA..." )
If dbSeek(xFilial()+"MV_CTBAPLA")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "2"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/

// 30/07/20
/*
oProcess:IncRegua2( "Atualizando parametro MV_DATAFIS..." )
If dbSeek(xFilial()+"MV_DATAFIS")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "20200630"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf
*/

// 31/07/20 -------> Email

oProcess:IncRegua2( "Atualizando parametro MV_RELFROM..." )
If dbSeek(xFilial()+"MV_RELFROM")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "microsiga@bkconsultoria.com.br"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf


oProcess:IncRegua2( "Atualizando parametro MV_RELACNT..." )
If dbSeek(xFilial()+"MV_RELACNT")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "microsiga@bkconsultoria.com.br"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf

oProcess:IncRegua2( "Atualizando parametro MV_RELAUSR..." )
If dbSeek(xFilial()+"MV_RELAUSR")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "microsiga@bkconsultoria.com.br"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf


oProcess:IncRegua2( "Atualizando parametro MV_RELPSW..." )
If dbSeek(xFilial()+"MV_RELPSW")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "Prosig@99"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf

oProcess:IncRegua2( "Atualizando parametro MV_RELAPSW..." )
If dbSeek(xFilial()+"MV_RELAPSW")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "Prosig@99"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf


oProcess:IncRegua2( "Atualizando parametro MV_RELSERV..." )
If dbSeek(xFilial()+"MV_RELSERV")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "smtp.gmail.com"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf

oProcess:IncRegua2( "Atualizando parametro MV_PORSMTP..." )
If dbSeek(xFilial()+"MV_PORSMTP")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "587"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf

oProcess:IncRegua2( "Atualizando parametro MV_RELTLS..." )
If dbSeek(xFilial()+"MV_RELTLS")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := ".T."
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf

oProcess:IncRegua2( "Atualizando parametro MV_RELSSL..." )
If dbSeek(xFilial()+"MV_RELSSL")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := ".T."
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf

oProcess:IncRegua2( "Atualizando parametro MV_RELAUTH..." )
If dbSeek(xFilial()+"MV_RELAUTH")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := ".T."
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf

oProcess:IncRegua2( "Atualizando parametro MV_RELTIME..." )
If dbSeek(xFilial()+"MV_RELTIME")
	RecLock( "SX6", .F. )

	cTexto += "Parametro " + SX6->X6_VAR + " conteudo: " + SX6->X6_CONTEUD + CRLF
	SX6->X6_CONTEUD := "120"
	cTexto += "Parametro " + SX6->X6_VAR + " conteudo alterado " + SX6->X6_CONTEUD + CRLF

	dbCommit()
	MsUnLock()
EndIf

// ------------> Fim e-mail


cTexto += CRLF + "Final da Atualizacao" + CRLF 

Return


Static Function AtuGenDic( cTexto )

//cTexto  += "Inicio da Atualizacao" + CRLF 

// Acerto do dicionario X3_USADO para o campo A1_NATUREZ

oProcess:IncRegua2( "Acerto do dicionario X3_FOLDER campo CTT_XXDESC.." )
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
//dbSelectArea( "SX3" )
//APPEND FROM \x3sc5.dtc

// Incluir competência da Medição no browse do SC5
//dbSelectArea( "SX3" )
//APPEND FROM \x3sB1.dtc

// Incluir campo do usuario que liberou o pedido de venda
//dbSelectArea( "SX3" )
//APPEND FROM \x3sc5.dtc

//X31UPDTABLE("SC5")


// Filtro Bancos/ Origem Ped 15/07/2020
//dbSelectArea( "SX3" )
//APPEND FROM \sx3jul20.dtc

//X31UPDTABLE("SC5")
//X31UPDTABLE("SC9")
//X31UPDTABLE("SA6")


// Nota Avulsa/Normal - 29/07/20
dbSelectArea( "SX3" )
dbSetOrder( 2 )
If SX3->( dbSeek( "C5_XXTPNF" ) )

	RecLock( "SX3", .F. )
	SX3->X3_RELACAO := "N"
	SX3->X3_CBOX    := "N=Normal;A=Avulsa"
	SX3->X3_VALID   := 'Pertence("NA")'
	dbCommit()
	MsUnLock()

EndIf

If SX3->( dbSeek( "C9_XXORPED" ) )

	RecLock( "SX3", .F. )
	SX3->X3_RELACAO := "N"
	SX3->X3_CBOX    := "N=Normal;A=Avulsa"

	dbCommit()
	MsUnLock()

EndIf

If SM0->M0_CODIGO <> "02"
	APPEND FROM \sx3cnd.dtc
EndIf
X31UPDTABLE("CND")


Return




Static Function AtuGenXX( cTexto )
//Local aSBrowse := {}
//Local aNBrowse := {}
//Local nI := 0

//cTexto  += "Inicio da Atualizacao" + CRLF 

// Acerto do dicionario X3_USADO para o campo A1_NATUREZ

oProcess:IncRegua2( "Acertos no dicionario.." )
dbSelectArea( "SX3" )
dbSetOrder( 2 )

/*
If SX3->( dbSeek( "E1_VENCORI" ) )

	RecLock( "SX3", .F. )
	SX3->X3_USADO := "€€€€€€€€€€€€€€ "
	SX3->X3_WHEN  := ".F."

	dbCommit()
	MsUnLock()

EndIf
*/

/*
If SX3->( dbSeek( "B1_XXGRPF" ) )
	RecLock( "SX3", .F. )
	SX3->X3_PICTURE := "@!"
	SX3->X3_VALID   := "Vazio() .OR. ExistCpo('SZU')"
	SX3->X3_F3      := "SZU"
	SX3->X3_FOLDER  := "1"
	dbCommit()
	MsUnLock()
EndIf
*/

/*
If SX3->( dbSeek( "ZU_PLAN" ) )
	RecLock( "SX3", .F. )
	SX3->X3_PICTURE := "@!"
	dbCommit()
	MsUnLock()
EndIf
*/

/*
If SX3->( dbSeek( "A1_CODPAIS" ) )
	RecLock( "SX3", .F. )
	SX3->X3_RELACAO := '"01058"'
	dbCommit()
	MsUnLock()
EndIf

If SX3->( dbSeek( "A1_PAIS" ) )
	RecLock( "SX3", .F. )
	SX3->X3_RELACAO := '"105"'
	dbCommit()
	MsUnLock()
EndIf

If SX3->( dbSeek( "A2_CODPAIS" ) )
	RecLock( "SX3", .F. )
	SX3->X3_RELACAO := '"01058"'
	dbCommit()
	MsUnLock()
EndIf

If SX3->( dbSeek( "A2_PAIS" ) )
	RecLock( "SX3", .F. )
	SX3->X3_RELACAO := '"105"'
	dbCommit()
	MsUnLock()
EndIf

If SX3->( dbSeek( "A1_RECIRRF" ) )
	RecLock( "SX3", .F. )
	SX3->X3_OBRIGAT := '€'
	dbCommit()
	MsUnLock()
EndIf
*/

// 05/05/2020
If SX3->( dbSeek( "A1_RECINSS" ) )
	RecLock( "SX3", .F. )
	SX3->X3_OBRIGAT := '€'
	dbCommit()
	MsUnLock()
EndIf

If SX3->( dbSeek( "A1_RECISS" ) )
	RecLock( "SX3", .F. )
	SX3->X3_OBRIGAT := '€'
	dbCommit()
	MsUnLock()
EndIf

If SX3->( dbSeek( "A1_RECPIS" ) )
	RecLock( "SX3", .F. )
	SX3->X3_OBRIGAT := '€'
	dbCommit()
	MsUnLock()
EndIf

If SX3->( dbSeek( "A1_RECCOFI" ) )
	RecLock( "SX3", .F. )
	SX3->X3_OBRIGAT := '€'
	dbCommit()
	MsUnLock()
EndIf

If SX3->( dbSeek( "A1_RECCSLL" ) )
	RecLock( "SX3", .F. )
	SX3->X3_OBRIGAT := '€'
	dbCommit()
	MsUnLock()
EndIf

If SX3->( dbSeek( "A2_RECINSS" ) )
	RecLock( "SX3", .F. )
	SX3->X3_RELACAO := '"N"'
	dbCommit()
	MsUnLock()
EndIf

If SX3->( dbSeek( "A2_RECISS" ) )
	RecLock( "SX3", .F. )
	SX3->X3_RELACAO := '"N"'
	dbCommit()
	MsUnLock()
EndIf

/*
dbSelectArea( "SXB" )
APPEND FROM \sxbszu.dtc
*/


/*
cTexto  += "Inicio da Atualizacao - Campo X3_BROWSE" + CRLF 
aSBrowse := {"B1_CODISS","B1_IRRF","B1_INSS","B1_PIS","B1_COFINS","B1_CSLL","F4_CF","F4_ISS","F4_CODBCC","F4_CSTPIS"}
aNBrowse := {"B1_XXDESCP","B1_ESPECIF","B1_MAT_PRI","B1_TAB_IPI","B1_TRIBMUN","B1_RPRODEP","B1_PRN9441","B1_CLASSE","B1_PRODREC","B1_RICM65","B1_TNATREC","B1_CNATREC","B1_SELOEN"}

AADD(aNBrowse,"F4_ICM")
AADD(aNBrowse,"F4_IPI")
AADD(aNBrowse,"F4_CREDICM")
AADD(aNBrowse,"F4_CREDIPI")
AADD(aNBrowse,"F4_LIVRO")
AADD(aNBrowse,"B1_POSIPI")


dbSelectArea( "SX3" )
dbSetOrder( 2 )

For nI := 1 To Len(aSBrowse)
	If dbSeek(aSBrowse[nI])
		If TRIM(SX3->X3_CAMPO) == aSBrowse[nI]
			RecLock( "SX3", .F. )
			SX3->X3_BROWSE := 'S'
			MsUnLock()
			cTexto += aSBrowse[nI]+"-S "
		Else
			cTexto += aSBrowse[nI]+"-sErro "
		EndIf
	EndIf
Next

For nI := 1 To Len(aNBrowse)
	If dbSeek(aNBrowse[nI])
		If TRIM(SX3->X3_CAMPO) == aNBrowse[nI]
			RecLock( "SX3", .F. )
			SX3->X3_BROWSE := 'N'
			MsUnLock()
			cTexto += aNBrowse[nI]+"-N "
		Else
			cTexto += aNBrowse[nI]+"-nErro "
		EndIf
	EndIf
Next
*/

//cTexto += CRLF + "Final da Atualizacao" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return



Static Function AtuGenFil( cTexto )
Local aSx2   := {}
Local cQuery := ""
Local cNFil  := ""
Local cTable := ""

/*
Bom dia a todos,

Conforme solicitado pelo Dep. Fiscal e Contabilidade, iremos cadastrar no sistema as seguintes filiais para a Empresa BK:

03.022.122/0005-09 – BK BRASILIA - DF
03.022.122/0006-81 – BK RIO DE JANEIRO - RJ
03.022.122/0007-62 – BK SALVADOR - BA
03.022.122/0008-43 – BK BETIM - MG
03.022.122/0009-24 – BK IPOJUCA - PE
03.022.122/0010-68 - BK SAO FRANCISCO DE ITABAPOANA -  RJ
03.022.122/0011-49 - BK SAO JOAO DA BARRA - RJ
03.022.122/0012-20 - BK CABO FRIO - RJ
03.022.122/0013-00 - BK CAMPOS DOS GOYTACAZES - RJ
03.022.122/0014-91 - BK CASIMIRO DE ABREU - RJ
03.022.122/0015-72 - BK ARMACAO DOS BUZIOS - RJ
03.022.122/0016-53 - BK ARRAIAL DO CABO - RJ
03.022.122/0017-34 - BK RIO DAS OSTRAS - RJ

A definição de uso de filiais é definida no momento da implantação do sistema, que foi realizada em 2009, portanto o analista da Totvs que implantou o sistema nesta época, seguiu o seguinte conceito:
Módulo Faturamento: Exclusivo
Módulo de Compras: Exclusivo
Módulo de Fiscal: Exclusivo
Módulo Financeiro: Exclusivo
Modulo Contábil: Exclusivo
Módulo de Gestão de Contratos: Exclusivo

Para adequarmos o sistema a incorporação de novas filiais, iremos alterar para a seguinte configuração:

Módulo Faturamento: Exclusivo
Módulo de Compras: Exclusivo (utilizará somente a Matriz)
Módulo de Fiscal: Exclusivo
Módulo Financeiro: ** Exclusivo
Modulo Contábil: Compartilhado
Módulo de Gestão de Contratos: Exclusivo (utilizará somente a matriz, com opção em contratos específicos de se efetuar medições em outras filiais).

OBS: 
Modo exclusivo: O usuário seleciona a filial que vai trabalhar na entrada do sistema e todas as operações serão válidas apenas pela filial selecionada 
Modo compartilhado: Todas as operações serão consolidadas  

Foi feito o levantamento das tabelas que terão seu modo de acesso alterado de Exclusivo para Compartilhado e um programa para efetuar as alterações e gerar as queries para adequar o banco de dados.

Provavelmente, na segunda-feira, estarei disponibilizando o ambiente de testes, com a base de dados atualizada. Deixarei algumas medições faturadas em algumas filiais.

Os testes deverão incorporar todas as operações realizadas no dia a dia de cada departamento, inclusive relatórios.

O prazo de término para homologação será definido pela Sra. Andrea da Contabilidade, que necessita desta implantação com urgência.

Informo que esta alteração no sistema é muito delicada, portanto não negligenciem nos testes para não termos problemas futuros.


As tabelas do sistema que a princípio terão seu mode de compartilhamento alteradas são as seguintes

*/


cTexto  += "Inicio da Atualizacao - filiais BK" + CRLF 

oProcess:IncRegua2( "Acertando o compartilhamento das tabelas..." )
dbSelectArea( "SX2" )
dbSetOrder( 1 )

aAdd(aSx2,"SF4") // - *-Tipos de Entradas e Saídas
aAdd(aSx2,"SF5") // - *-Tipos de Movimentação   
aAdd(aSx2,"SF7") // - -Grupo de Tributação    

// Produtos e tabelas filhas
aAdd(aSx2,"SB1") // - *Produtos
aAdd(aSx2,"SB4") // - *Referência de Produto 
aAdd(aSx2,"SB5") // - -Complemento Produtos
//aAdd(aSx2,"SBE") // *Localização Física
aAdd(aSx2,"SBM") // - *Grupos
aAdd(aSx2,"SBV") // - *Tabela Itens Grade
aAdd(aSx2,"D3E") // - -Dados complementares produto  
aAdd(aSx2,"SZI") // - *Sub Grupos
//aAdd(aSx2,"SBZ") // - Indicadores (exclusiva)
// F3 - Produtos
aAdd(aSx2,"AC4") // - *Parceiros                     
//aAdd(aSx2,"ALT") // - *Tipos de Despesas             
aAdd(aSx2,"CCZ") // - *Natureza da Receita           
aAdd(aSx2,"CDZ") // - *Codigo de Lancamento CAT83    
aAdd(aSx2,"DB0") // - -Modelos de Carga              
aAdd(aSx2,"EE5") // - *Embalagens                    
aAdd(aSx2,"EEI") // - *Tabela de Normas              
aAdd(aSx2,"EI6") // - *Tabela de IPI de Pauta        
aAdd(aSx2,"F08") // - *Cód. Enquadramento Legal IPI  
aAdd(aSx2,"NNR") // - *Locais de Estoque             
aAdd(aSx2,"QAD") // - *Departamentos/Setor           
aAdd(aSx2,"SAH") // - *Unidades de Medida            

aAdd(aSx2,"SAJ") // - -Grupos de Compras             
aAdd(aSx2,"SAK") // - *Aprovadores                 
aAdd(aSx2,"SAL") // - -Grupos de Aprovação               
//aAdd(aSx2,"SBP") // - *Base de Código Estruturado    
//aAdd(aSx2,"SG1") // - *Estruturas dos Produtos 
//aAdd(aSx2,"SG2") // - *Roteiro de Operações          
//aAdd(aSx2,"SG5") // - *Revisões Estrutura
//aAdd(aSx2,"SGG") // - *Pré-Estrutura   
aAdd(aSx2,"SJ1") // - *Naladi SH                     
aAdd(aSx2,"SJ2") // - *Naladi NCCA                   
aAdd(aSx2,"SJC") // - *Aladi                         
aAdd(aSx2,"SYC") // - *Família de Produtos           
aAdd(aSx2,"SYD") // - *Nomenclatura Comum do Mercosul
aAdd(aSx2,"SZU") // - *Grupo Financeiro Produto BK   
//aAdd(aSx2,"VE5") // - Grupos de Desconto            
//aAdd(aSx2,"WD2") // - Status do Workflow                   
//aAdd(aSx2,"WD3") // - Rastreabilidade do Workflow   


// Financeiro

//Quando a  tabela SE2 - contas a pagar estiver compartilhada.
//Para utilização deste modo é necessário o compartilhamento das tabelas abaixo da seguinte forma:

//SB1 (Produto) - Completamente compartilhado ou exclusivo
//SA2 (Fornecedores) - Totalmente compartilhado
//SF1 (Cabeçalho de Doc entrada.) - Completamente exclusivo
//SD1 (Itens de doc de  entrada.) - Completamente exclusivo
//SF2 (Cabeçalho de Doc Saída)- Completamente exclusivo
//SD2 (Itens de Doc Saída) - Completamente exclusivo
//SE4 (Condições de Pagamento) - Totalmente compartilhado
//SEK (ordens de pagamento) - Totalmente compartilhado
//SFE (Imposto Retido na Fonte) - Totalmente compartilhado
//SFH (Lucro Bruto) - Totalmente compartilhado
//SFF (ganancias / Fundo Cooperativo) - Completamente compartilhado ou exclusivo
  

//aAdd(aSx2,"FI0") // - *Cabec Log Processamento CNAB  
//aAdd(aSx2,"FI1") // - *Detalhe do Log Processamento  
aAdd(aSx2,"FI2") // - *Ocorrências CNAB              
//aAdd(aSx2,"FI4") // - *Ocorrências Gestor Financeiro 
//aAdd(aSx2,"FI5") // - *Cenários Gestor Financeiro    
//aAdd(aSx2,"FI6") // - *Itens Cenários Gestor Financei
aAdd(aSx2,"FI7") // - *Rastreamento CR               
aAdd(aSx2,"FI8") // - *Rastreamento CP               
aAdd(aSx2,"FI9") // - *Controle de DARF              
//aAdd(aSx2,"FIA") // - *Provisao para cobrança duvidos
//aAdd(aSx2,"FIB") // - *Header Caixa Tesouraria       
//aAdd(aSx2,"FIC") // - *Itens do Lote do Cxa Tesourari
//aAdd(aSx2,"FID") // - *Cadastro Operadores Caixa     
//aAdd(aSx2,"FIE") // - *Relacionamento Pedidos x Adian
aAdd(aSx2,"FIF") // - *ARQUIVO CONCILIACAO SITEF     
aAdd(aSx2,"FIG") // - *Conciliacao DDA               
aAdd(aSx2,"FIH") // - *Contr. Oper. Contas a Receber 
aAdd(aSx2,"FII") // - *Contr.Oper.Contas a pagar     
aAdd(aSx2,"FIJ") // - *Saldos Caixinhas              
aAdd(aSx2,"FIK") // - -Titulo x Valor Liberado Pgto  
aAdd(aSx2,"FIL") // - *C/C Fornecedores              
aAdd(aSx2,"FIM") // - *ALIQUOTA DE ISS               
aAdd(aSx2,"FIN") // - *AVP Titulos CR                
aAdd(aSx2,"FIO") // - *Proc AVP CR                   
aAdd(aSx2,"FIP") // - *Mov AVP CR                    
aAdd(aSx2,"FIQ") // - *AVP Titulos CP                
aAdd(aSx2,"FIR") // - *Proc AVP CP                   
aAdd(aSx2,"FIS") // - *Mov AVP CP                    
aAdd(aSx2,"FIT") // - *Indices Financeiros           
aAdd(aSx2,"FIU") // - *Variação Indices Fin          
aAdd(aSx2,"FIV") // - *MOVIMENTOS DIARIOS P/NATUREZA 
aAdd(aSx2,"FIW") // - *SALDO MENSAL POR NATUREZA     
aAdd(aSx2,"FIX") // - *CABEC DE PERSISTENCIA FLUXO CX
aAdd(aSx2,"FIY") // - *PERSISTENCIA DO FLUXO DE CAIXA
aAdd(aSx2,"FJ0") // - -Lançamentos TOP               
aAdd(aSx2,"FJ1") // - *Visão Gerencial               
aAdd(aSx2,"FJ2") // - *Estrutura da Visão            
aAdd(aSx2,"FJ3") // - *Visoes Gerenciais             

//aAdd(aSx2,"FJ4") // - *Rateios Jurídicos             
//aAdd(aSx2,"FJ5") // - *Captacao de Recurso Terceiro  
//aAdd(aSx2,"FJ6") // - *Parcela da Captação           
//aAdd(aSx2,"FJ7") // - *Custo Transação Captação      
//aAdd(aSx2,"FJ8") // - *Pagamento Parcela Captação    
//aAdd(aSx2,"FJ9") // - *Recurso Captado               
//aAdd(aSx2,"FJA") // - *Solicitação de fundo para PA  
//aAdd(aSx2,"FJH") // - *Movimento da Captação         
//aAdd(aSx2,"FJI") // - *Tipos de Captação             
//aAdd(aSx2,"FJJ") // - *Taxa TIR da Captação          
//aAdd(aSx2,"FJM") // - *Rateio da Pre-ordens de pago  
//aAdd(aSx2,"FJP") // - *Processamento MCMV            
//aAdd(aSx2,"FJQ") // - *CADASTRO CODIGO RET X VENCIMEN
//aAdd(aSx2,"FJR") // - *Cabeçalho Ordem de Pago       
//aAdd(aSx2,"FJS") // - *Modo de Pagamento             
//aAdd(aSx2,"FJU") // - *Grava titulos excluidos       

aAdd(aSx2,"FJV") // - *Movimento Analitico P/Natureza
//aAdd(aSx2,"FJW") // - *Cabeçalho de Previas de INSS  
aAdd(aSx2,"FJX") // - *Processamento PDD             
aAdd(aSx2,"FJY") // - *Clientes Cadastrados em PDD   
aAdd(aSx2,"FJZ") // - *Títulos Provisionados         

aAdd(aSx2,"FK0") // - -Tit. Gerados Impostos         
aAdd(aSx2,"FK1") // - -Baixas a Receber              
aAdd(aSx2,"FK2") // - -Baixas a Pagar                
aAdd(aSx2,"FK3") // - -Impostos Calculados           
aAdd(aSx2,"FK4") // - -Impostos Retidos              
aAdd(aSx2,"FK5") // - -Movimentos Bancários          
aAdd(aSx2,"FK6") // - -Valores Acessórios            
aAdd(aSx2,"FK7") // - -Tabela Auxiliar               
aAdd(aSx2,"FK8") // - -Dados contábeis               
aAdd(aSx2,"FK9") // - -Auxiliar de integração        
aAdd(aSx2,"FKA") // - -Rastreio de Movimentos        
aAdd(aSx2,"FKB") // - -Tipos de Movimentos           
aAdd(aSx2,"FKC") // - -Tipo de Valores Acessórios    
aAdd(aSx2,"FKD") // - -Títulos x Valores acessórios  
aAdd(aSx2,"FKE") // - -Complemento do Imposto        
aAdd(aSx2,"FKF") // - -COMPLEMENTO DO TITULO         
aAdd(aSx2,"FKG") // - -COMPLEMENTO IMPOSTO X TITULOS 
aAdd(aSx2,"FKH") // - -TABELA DE REVISAO EXCLUSAO TAF
aAdd(aSx2,"FKI") // - -DEDUCAO IR MENSAL POR DEP.    
aAdd(aSx2,"FKJ") // - -CADASTRO DE CPF IR PROGRESSIVO
aAdd(aSx2,"FKK") // - -Regras Financeiras Retenção   
aAdd(aSx2,"FKL") // - -Motor - Regras de Titulos     
aAdd(aSx2,"FKM") // - -Cabeçalho de tipos de retenção
aAdd(aSx2,"FKN") // - -MOTOR - Regra de Cálculo      
aAdd(aSx2,"FKO") // - -MOTOR - Regras de Retenção    
aAdd(aSx2,"FKP") // - -MOTOR - Regras de Vencimento  
aAdd(aSx2,"FKQ") // - -Tributos Fiscais Calculados   
aAdd(aSx2,"FKS") // - -Cabeçalho Tabelas Financeiras 
aAdd(aSx2,"FKT") // - -Cabeçalho Regra Cumulatividade
aAdd(aSx2,"FKU") // - -Cabeçalho Regra Val.Acessorios
aAdd(aSx2,"FKV") // - -Cabeçalho Regra Deduções 

aAdd(aSx2,"FL0") // - -Log de Integração             
aAdd(aSx2,"FL1") // - -Pedidos Reserve com Erro      
aAdd(aSx2,"FL2") // - -BKO Agência x BKO Protheus    
aAdd(aSx2,"FL3") // - -Niveis de Cargo               
aAdd(aSx2,"FL4") // - -Campos Obrigatório SRA/RD0    
aAdd(aSx2,"FL5") // - -Solicitacoes de Viagem        
aAdd(aSx2,"FL6") // - -Reservas                      
aAdd(aSx2,"FL7") // - -Passagens Aereas              
aAdd(aSx2,"FL8") // - -Rodoviario                    
aAdd(aSx2,"FL9") // - -Hospedagem                    
aAdd(aSx2,"FLA") // - -Seguro Viagem                 
aAdd(aSx2,"FLB") // - -Locacao                       
aAdd(aSx2,"FLC") // - -Passageiros                   
aAdd(aSx2,"FLD") // - -Adiantamento de Viagem        
aAdd(aSx2,"FLE") // - -Item da prestação de contas   
aAdd(aSx2,"FLF") // - -Prestação de Contas           
aAdd(aSx2,"FLG") // - -Tipos de Despesa              
aAdd(aSx2,"FLH") // - -Rateio por Centro de Custo    
aAdd(aSx2,"FLI") // - -Grupos de Acesso              
aAdd(aSx2,"FLJ") // - -Aprovadores da Reserva        
aAdd(aSx2,"FLK") // - -Gupo de Despesa               
aAdd(aSx2,"FLL") // - -ParticipantesxGrupo de Acesso 
aAdd(aSx2,"FLM") // - -Liberação do Adiantamento     
aAdd(aSx2,"FLN") // - -Aprovação Prestação de Contas 
aAdd(aSx2,"FLO") // - -Histórico Reserve Pendente    
aAdd(aSx2,"FLP") // - -Aprovador por Centro de Custo 
aAdd(aSx2,"FLQ") // - -Confirmação Valores Viagem    
aAdd(aSx2,"FLR") // - -Itens Confirmação de Valores  
aAdd(aSx2,"FLS") // - -Vigência de Tipos de Despesa  
aAdd(aSx2,"FLT") // - -Vigência do Grupo de Despesa  
aAdd(aSx2,"FLU") // - -Passageiro por Pedido         
aAdd(aSx2,"FLV") // - -Pedido vs. Conferência        
aAdd(aSx2,"FLW") // - -Comparação do Fluxo de Caixa  
aAdd(aSx2,"FLX") // - -Itens de Previas de INSS      
//aAdd(aSx2,"FLY") // - *RPS x NFe                     
aAdd(aSx2,"FLZ") // - -CABEC.COMP. FLUXO CAIXA       

aAdd(aSx2,"FO0") // - -Cabeçalho de Simulaçao        
aAdd(aSx2,"FO1") // - -Títulos Negociados            
aAdd(aSx2,"FO2") // - -Títulos Gerados               
aAdd(aSx2,"FO4") // - -Extrato x Pedidos             
aAdd(aSx2,"FO6") // - -Pedido Reserve x PCO          
aAdd(aSx2,"FO7") // - -Títulos da Prestação de Contas
aAdd(aSx2,"FO8") // - -Fatura de Hotel               
aAdd(aSx2,"FO9") // - -Fatura Hotel x Notas          
aAdd(aSx2,"FOA") // - -Fatura Hotel x Titulo         
aAdd(aSx2,"FOB") // - -Fatura Hotel x Comissao       
aAdd(aSx2,"FOC") // - -Fatura Hotel x NFe            
aAdd(aSx2,"FOD") // - -CADASTROS SOCIOS SCP          
aAdd(aSx2,"FOE") // - -LUCROS/DIVIDENDOS DO SOCIO SCP
aAdd(aSx2,"FOF") // - -Processo de Compesação        
aAdd(aSx2,"FOI") // - -Tipo de retenção x Natureza   
aAdd(aSx2,"FOJ") // - -Tipo de Retenção X Clientes   
aAdd(aSx2,"FOK") // - -Tipo Retenção X Fornecedores  
aAdd(aSx2,"FOL") // - -Tipo de Retenção X Produtos   
aAdd(aSx2,"FOM") // - -Cabeçalho Repasse IRPJ        
aAdd(aSx2,"FON") // - -Itens do Repasse IRPJ         
aAdd(aSx2,"FOO") // - -Tipos de Impostos             
aAdd(aSx2,"FOP") // - -CADASTRO CONFIGURAÇÃO CNAB    
aAdd(aSx2,"FOQ") // - -CADASTRO DE ARQUIVOS CNAB     
aAdd(aSx2,"FOS") // - -Tabela de Valores tp Retenção 
aAdd(aSx2,"FOT") // - -Cumulatividade por tipo de ret
aAdd(aSx2,"FOU") // - -Val Acessórios tipo retencão  
aAdd(aSx2,"FOV") // - -FOV – Deduções tipo retenção  
aAdd(aSx2,"FOZ") // - -Cabeçalho Cad. Config. CNAB   

aAdd(aSx2,"FR0") // - -Dados Auxiliares FIN          
aAdd(aSx2,"FR1") // - -Detalhes financeiros e imposto
aAdd(aSx2,"FR2") // - -Det. financeiros e impostos CP
aAdd(aSx2,"FR3") // - -Relacionamento Pedidos x Compe
aAdd(aSx2,"FR4") // - -Apuracao IRPJ/CSLL Lucro Real 
aAdd(aSx2,"FR5") // - -Componente Apuracao IRPJ/CSLL 
aAdd(aSx2,"FR6") // - -Titulos da Apuração           
aAdd(aSx2,"FR7") // - -Filiais da Apuração           
aAdd(aSx2,"FR9") // - -REGRAS DE DOCUMENTO POR EVENTO
aAdd(aSx2,"FRD") // - -CHECKLIST DE DOC.FINANCEIRO   
aAdd(aSx2,"FRH") // - -Header Descontos Condicionais 
aAdd(aSx2,"FRI") // - -Itens Desconto Condicional.   
aAdd(aSx2,"FRJ") // - -Header NF-e Educacional     
aAdd(aSx2,"FRK") // - -Itens NF-e Educacional        
aAdd(aSx2,"FRL") // - -Filtros NF-e Educacional      
aAdd(aSx2,"FRO") // - -Analistas Financeiros         
aAdd(aSx2,"FRP") // - -Gestores Financeiros          
aAdd(aSx2,"FRQ") // - -Grupo de Analistas Financeiros
aAdd(aSx2,"FRR") // - -Grupo de Gestores Financeiros 
aAdd(aSx2,"FRS") // - -Amarra Aprovador X Superiores 
aAdd(aSx2,"FRT") // - -Saldos de Fundo Fixo          
aAdd(aSx2,"FRU") // - -Componentes do Financiamento  
aAdd(aSx2,"FRV") // - -Situação de Cobrança          

aAdd(aSx2,"FV0") // - -Cabeçalho do Documento Hábil  
aAdd(aSx2,"FV1") // - -Documentos de Origem          
aAdd(aSx2,"FV2") // - -Principal com Orçamento       
aAdd(aSx2,"FV3") // - -Detalhe Log de Importação Tef 
aAdd(aSx2,"FV4") // - -Campos Variáveis da Situação  
aAdd(aSx2,"FV5") // - -Situação X NE X DH            
aAdd(aSx2,"FV6") // - -Dados Pagamento Favorecidos   
aAdd(aSx2,"FV7") // - -Pré-Doc                       
aAdd(aSx2,"FV8") // - -Principal sem Orçamento       
aAdd(aSx2,"FV9") // - -Itens principais sem orçamento
aAdd(aSx2,"FVA") // - -Outros Lançamentos            
aAdd(aSx2,"FVB") // - -Encargos                      
aAdd(aSx2,"FVD") // - -Dedução                       
aAdd(aSx2,"FVE") // - -Recolhedores                  
aAdd(aSx2,"FVF") // - -Acréscimos                    
aAdd(aSx2,"FVG") // - -Imóveis X Pessoas             
aAdd(aSx2,"FVH") // - -Tipo de Documento X Seção     
aAdd(aSx2,"FVI") // - -Relacionamentos               
aAdd(aSx2,"FVJ") // - -Situação do Documento Hábil   
aAdd(aSx2,"FVK") // - -Tp. Doc. X Seção X Situação   
aAdd(aSx2,"FVL") // - -Despesas a Anular             
aAdd(aSx2,"FVM") // - -Itens a Anular                
aAdd(aSx2,"FVN") // - -Campos Variáveis DH           
aAdd(aSx2,"FVO") // - -Unidade Gestora Responsável   
aAdd(aSx2,"FVP") // - -Situação X Títulos Impostos   
aAdd(aSx2,"FVQ") // - -Ordens Bancárias do Doc. Hábil
aAdd(aSx2,"FVR") // - -Logs importação TEF           
aAdd(aSx2,"FVU") // - -Pessoas                       
aAdd(aSx2,"FVV") // - -Imóveis                       
aAdd(aSx2,"FVW") // - -Logs Importação Sitef.        
aAdd(aSx2,"FVX") // - -Cadastro de Justificativas    
aAdd(aSx2,"FVY") // - -Cadastro Motivos da Operadora 
aAdd(aSx2,"FVZ") // - -Filiais a Considerar          

aAdd(aSx2,"FW0") // - -Configuração de Aprovadores   
aAdd(aSx2,"FW1") // - -Processos para Bloqueio CR    
aAdd(aSx2,"FW2") // - -Sit. Cobrança x Proc. Bloquear
aAdd(aSx2,"FW3") // - -Cabeçalho Solicitação Viagem  
aAdd(aSx2,"FW4") // - -Itens da Solicitação de Viagem
aAdd(aSx2,"FW5") // - -Participantes                 
aAdd(aSx2,"FW6") // - -Centro de Custo               
aAdd(aSx2,"FW7") // - -Outros                        
aAdd(aSx2,"FW8") // - -Cabeçalho de Lotes Serasa     
aAdd(aSx2,"FW9") // - -Detalhes do Lote Serasa       
aAdd(aSx2,"FWA") // - -Situação de Titulo Serasa     
aAdd(aSx2,"FWB") // - -Movimentos do Titulo no Serasa
aAdd(aSx2,"FWC") // - -Despesas x Localização        
aAdd(aSx2,"FWD") // - -Itens Despesas x Localização  
aAdd(aSx2,"FWM") // - -Aglutinação de INSS           
aAdd(aSx2,"FWN") // - -Itens Conciliados             
aAdd(aSx2,"FWP") // - -Cartas de Cobrança            
aAdd(aSx2,"FWQ") // - -Dados dos Títulos             
aAdd(aSx2,"FWS") // - -Dados dos Títulos             
aAdd(aSx2,"FWT") // - -Cartas Enviadas               
aAdd(aSx2,"FWZ") // - -Rateio Títulos PDD            

aAdd(aSx2,"FX0") // - -Cab. Programação Financeira   
aAdd(aSx2,"FX1") // - -Itens Programação Financeira  
aAdd(aSx2,"FX2") // - -Prog. Financeira x Doc. Hábil 
aAdd(aSx2,"FXV") // - -Cafir X Imóvel                

aAdd(aSx2,"NV3") // - *Historico de Movimentação     
aAdd(aSx2,"NV9") // - *SINCRONIZAÇÃO JURÍDICA    
aAdd(aSx2,"NVR") // - -Dados Juridicos(Cabecalho)    
aAdd(aSx2,"NVS") // - -Dados Juridicos (Detalhe)     
aAdd(aSx2,"NVT") // - -Rateios Juridicos (Cabecalhos)
aAdd(aSx2,"NVU") // - -Rateio Juridico Pre-Configurad

aAdd(aSx2,"SA6") // - *Bancos                        
aAdd(aSx2,"SAQ") // - -Cobradores                    
aAdd(aSx2,"SAR") // - -Cliente x Cobrador 

aAdd(aSx2,"SE0") // - *Cotações Diarias por Contrato 
aAdd(aSx2,"SE1") // - *Contas a Receber              
aAdd(aSx2,"SE2") // - *Contas a Pagar                
aAdd(aSx2,"SE3") // - *Comissões de Vendas 
aAdd(aSx2,"SE4") // - *-Cond. Pgto
aAdd(aSx2,"SE5") // - *Movimentação Bancaria         
aAdd(aSx2,"SE6") // - *Solicitação de Transferência  
aAdd(aSx2,"SE7") // - *Orçamentos                    
aAdd(aSx2,"SE8") // - *Saldos Bancários              
aAdd(aSx2,"SE9") // - *Contratos Bancários           
aAdd(aSx2,"SEA") // - *Títulos Enviados ao Banco     
aAdd(aSx2,"SEB") // - *Ocorrências da Transm Bancária
aAdd(aSx2,"SED") // - *Naturezas                     
aAdd(aSx2,"SEE") // - *Comunicação Remota            
aAdd(aSx2,"SEF") // - *Cheques                       
aAdd(aSx2,"SEG") // - *Controle de Aplicações        
aAdd(aSx2,"SEH") // - *Controle Aplicação/Emprestimo 
aAdd(aSx2,"SEI") // - *Movimento Aplicação/Emprestimo
aAdd(aSx2,"SEJ") // - *Ocorrências Extrato           
aAdd(aSx2,"SEL") // - *Recibos de Cobranças          
aAdd(aSx2,"SEK") // - *Ordens de pagamento        
aAdd(aSx2,"SEM") // - -Contrato CDCI                 
aAdd(aSx2,"SEN") // - -Planos de Venda               
aAdd(aSx2,"SEO") // - -IOC                           
aAdd(aSx2,"SEP") // - -Índices Praticados            
aAdd(aSx2,"SEQ") // - -Cabeçalho do Bordero          
aAdd(aSx2,"SER") // - -Itens do Bordero              
aAdd(aSx2,"SES") // - *Tabela de Tipos de Titulos    
aAdd(aSx2,"SET") // - *Caixinhas                     
aAdd(aSx2,"SEU") // - *Movimentos do Caixinha        
aAdd(aSx2,"SEV") // - *Múltiplas Naturezas por Título
aAdd(aSx2,"SEW") // - -Rateio para Orçamentos        
aAdd(aSx2,"SEX") // - -Comissões de Cobradores       
aAdd(aSx2,"SEY") // - -Recibo x Cobradores           
aAdd(aSx2,"SEZ") // - -Distrib de Naturezas em CC    

aAdd(aSx2,"SFE") // - *Retenções de Impostos         
aAdd(aSx2,"SFF") // - *Ganancias / Fundo Cooperativo         
aAdd(aSx2,"SFH") // - *Lucro Bruto         
aAdd(aSx2,"SFQ") // - -Amarração de Parcelas         
aAdd(aSx2,"SIE") // - Indice de Ajuste por Inflação 
aAdd(aSx2,"SM2") // - Moedas do Sistema             

// Contabilidade Gerencial
// Cadastros: CT1, CT5, CT8, CT9, CTA, CTB, CTD, CTE, CTG CQD, CTH, CTJ, CTL, CTN, CTO, CTP, CTR, CTS, CTT, CV5, CV9, CVA, CVB, CVC, CVD,CVE,CVF
// Movimentos e Saldos: CT2, CT3, CT4, ,CT7, CTI, CTU, CTV, CTW, CTX, CTY, CT6, CTC, CTF, CTK, CTZ, CV1, CV2, CV3, CV4, CV6, CV7, CV8 e CVO.
// P12: CQ0, CQ1, CQ2, CQ3, CQ4, CQ5, CQ6, CQ07 CQ8, CQ9, CQA e CSQ

aAdd(aSx2,"C1H") // - *Cadastro de Participantes     
aAdd(aSx2,"C1I") // - *Alteracao Participante  
aAdd(aSx2,"C1J") // - *Unidade de Medida 
aAdd(aSx2,"C1K") // - -Fatores de Conversão da UM   
aAdd(aSx2,"C1L") // - *Identificação do Item  
aAdd(aSx2,"C1M") // - *Controle Alteração Item   
aAdd(aSx2,"C1O") // - *Plano de Contas Contábeis   
aAdd(aSx2,"C1P") // - *Centros de Custo


aAdd(aSx2,"CH5") // - *Plano de Contas Referencial  
aAdd(aSx2,"CHH") // - *Subcontas Correlatas      

//aAdd(aSx2,"C3Q") // - Informações Complementares    
//aAdd(aSx2,"C3R") // - Plano de Contas Referencial  
//aAdd(aSx2,"C6D") // - Plano de Contas Referencial  
//aAdd(aSx2,"C6O") // - Plano de Contas Referencial  


aAdd(aSx2,"CT0") // - *Conf. De Entidades Contábeis
aAdd(aSx2,"CT1") // - *Plano de Contas
aAdd(aSx2,"CT2") // - *Lançamentos Contábeis
aAdd(aSx2,"CT3") // - *Saldos Centro de Custo
aAdd(aSx2,"CT4") // - *Saldos Item Contábil
aAdd(aSx2,"CT5") // - *Lançamento Padrão
aAdd(aSx2,"CT6") // - *Totais de Lotes
aAdd(aSx2,"CT7") // - *Saldos Planos de Contas
aAdd(aSx2,"CT8") // - *Historico Padrão
aAdd(aSx2,"CT9") // - *Rateio On-Line
aAdd(aSx2,"CTA") // - *Regras de Amarração
aAdd(aSx2,"CTB") // - *Roteiro Consolidação
aAdd(aSx2,"CTC") // - *Saldos do Documento
aAdd(aSx2,"CTD") // - *Item Contábil
aAdd(aSx2,"CTE") // - *Amarração Moeda x Calendário
aAdd(aSx2,"CTF") // - *Numeração de Documento
aAdd(aSx2,"CTG") // - *Calendário Contábil
aAdd(aSx2,"CTH") // - *Classes de Valores
aAdd(aSx2,"CTI") // - *Saldos da Classe de Valores
aAdd(aSx2,"CTJ") // - *Critérios de Rateio
aAdd(aSx2,"CTK") // - *Arquivo de Contra-Prova
aAdd(aSx2,"CTL") // - *Relacionamentos Contábeis
aAdd(aSx2,"CTM") // - *Segmentos Entidades Contábeis
aAdd(aSx2,"CTN") // - *Configuração Livros Contábeis
aAdd(aSx2,"CTO") // - *Moedas Contábeis
aAdd(aSx2,"CTP") // - *Câmbio
aAdd(aSx2,"CTQ") // - *Rateios Off-Line
aAdd(aSx2,"CTR") // - *Grupos Contábeis
aAdd(aSx2,"CTS") // - *Visões Gerenciais
aAdd(aSx2,"CTT") // - *Centro de Custo
aAdd(aSx2,"CTU") // - *Saldos Totais por Entidade
aAdd(aSx2,"CTV") // - *Saldos Item x Centro de Custo
aAdd(aSx2,"CTW") // - *Saldos Cl Valor x Centro Custo
aAdd(aSx2,"CTX") // - *Saldos Cl Valor x Item
aAdd(aSx2,"CTY") // - *Saldos CCusto x Item x ClValor
aAdd(aSx2,"CTZ") // - *Lançam Luc/Perd C/ Cta Ponte

aAdd(aSx2,"CV0") // - *Cadastro de Entidades
aAdd(aSx2,"CV1") // - *Itens do Orçamento
aAdd(aSx2,"CV2") // - *Cabeçalho Orçamentos
aAdd(aSx2,"CV3") // - *Rastreamento Lançamento
aAdd(aSx2,"CV4") // - *Rateio Contabilizado
aAdd(aSx2,"CV5") // - *Configuraçao Intercompany
aAdd(aSx2,"CV6") // - *Backup Lançamentos Contábeis
aAdd(aSx2,"CV7") // - *Flag de Atualizaçao de Saldos
aAdd(aSx2,"CV8") // - *Log de Processamento
aAdd(aSx2,"CV9") // - *Historico de Rateios Offline
aAdd(aSx2,"CVA") // - *Pontos de Lançamento Padrão
aAdd(aSx2,"CVB") // - *Dados do Contabilista
aAdd(aSx2,"CVC") // - *Participantes
aAdd(aSx2,"CVD") // - *Plano de Contas Referênciais
aAdd(aSx2,"CVE") // - *Visão Gerencial
aAdd(aSx2,"CVF") // - *Estrutura da Visão
aAdd(aSx2,"CVG") // - *Operações
aAdd(aSx2,"CVH") // - -Natureza Contabil
aAdd(aSx2,"CVI") // - *Operações Vs. Seq. Lançamentos
aAdd(aSx2,"CVJ") // - *Processos
aAdd(aSx2,"CVK") // - -Carga Lançamento Padrão
aAdd(aSx2,"CVL") // - -Controle de Diário
aAdd(aSx2,"CVM") // - -Sequencial de Diário
aAdd(aSx2,"CVN") // - *Planos de Contas de Referencia
aAdd(aSx2,"CVO") // - -Fila de Saldos 2
aAdd(aSx2,"CVQ") // - *Quadros Contab. Configuraveis
aAdd(aSx2,"CVR") // - *Cadastro Auditores
aAdd(aSx2,"CVS") // - *Cadastro SCP
aAdd(aSx2,"CVT") // - *Subcontas Correlatas
aAdd(aSx2,"CVX") // - -Saldos Diários
aAdd(aSx2,"CVY") // - -Saldos Mensais Acumulados
aAdd(aSx2,"CVZ") // - -Saldo de Fechamento

aAdd(aSx2,"CW0") // - *Dados Auxiliares CTB
aAdd(aSx2,"CW1") // - -CADASTRO DE GRUPOS DE RATEIO
aAdd(aSx2,"CW2") // - -AMARRACAO DE GRUPOS DE RATEIO
aAdd(aSx2,"CW3") // - -INDICES ESTATISTICOS
aAdd(aSx2,"CW8") // - -HISTORICO DE ALTERAÃ?ES
aAdd(aSx2,"CWG") // - -Moeda x Calendário
aAdd(aSx2,"CWH") // - -TABELAS PARA MNEMÔNICOS
aAdd(aSx2,"CWI") // - -CAMPOS PARA UTILIZAR MNÊMONICO
aAdd(aSx2,"CWJ") // - -MNEMÔNICOS
aAdd(aSx2,"CWK") // - -FÓRMULAS
aAdd(aSx2,"CWL") // - -ITENS DA FORMULAÇÃO
aAdd(aSx2,"CWM") // - -FÓRMULAS USADAS POR LANÇAMENTO
aAdd(aSx2,"CWN") // - -Funções

aAdd(aSx2,"CQ0") // – *Saldo Conta no mês, 
aAdd(aSx2,"CQ1") // – *Saldo Conta no Dia, 
aAdd(aSx2,"CQ2") // - *Saldo C.Custo no Mês, 
aAdd(aSx2,"CQ3") // – *Saldo C.Custo no Dia, 
aAdd(aSx2,"CQ4") // – *Saldo Item no Mês, 
aAdd(aSx2,"CQ5") // – *Saldo Item no Mês, 
aAdd(aSx2,"CQ6") // – *Saldo Classe de Valor no Mês,
aAdd(aSx2,"CQ7") // – *Saldo Classe de Valor no Dia
aAdd(aSx2,"CQ8") // - *Saldo Entidades no Mes
aAdd(aSx2,"CQ9") // - *Saldo Entidades no Dia
aAdd(aSx2,"CQA") // - *Fila de Saldos
aAdd(aSx2,"CQB") // - -Variação Cambial
aAdd(aSx2,"CQC") // - -Processamento Variação Cambial
aAdd(aSx2,"CQD") // - *Bloqueio de Calendário Contábil
aAdd(aSx2,"CQE") // - -Config. Apuração Cont. de Proj
aAdd(aSx2,"CQF") // - -Tipos de Saldos Apr Contrato
aAdd(aSx2,"CQG") // - -Períodos Apuração do Contrato
aAdd(aSx2,"CQH") // - -Apontamentos do Período
aAdd(aSx2,"CQI") // - -Movimentos das apurações
aAdd(aSx2,"CQJ") // - *Cabeçalho do Evento           
aAdd(aSx2,"CQK") // - *Itens do Evento               
aAdd(aSx2,"CQL") // - *IDENT.DOS TIPOS DE PROGRAMAS  
aAdd(aSx2,"CQM") // - *Registro W100-Inf.Grupo Multin
aAdd(aSx2,"CQN") // - *Registro W200- Declaracao Pais
aAdd(aSx2,"CQO") // - *Registro W250-Entid.Integrante
aAdd(aSx2,"CQP") // - *Registro W300-Observações Adic
aAdd(aSx2,"CQQ") // - *PERIODO ESC CONSOL BL K       
aAdd(aSx2,"CQR") // - *Rel Empr Consolidadas Bl K    
aAdd(aSx2,"CQS") // - *REL EVENTOS SOCIETARIOS BL K  
aAdd(aSx2,"CQT") // - *EMPR PARTIC EV SOC BL K       
aAdd(aSx2,"CQU") // - *SALDO CONTAS CONSOL BL K      
aAdd(aSx2,"CQV") // - *SALDO CONTAS CONSOL BL K      
aAdd(aSx2,"CQX") // - *SALDO CONTAS CONSOL BL K      
aAdd(aSx2,"CQY") // - *SALDO CONTAS CONSOL BL K      
aAdd(aSx2,"CQZ") // - *EMP CONTRAPARTES VL ELIM BL K 

/* Grupo CS já está compartilhado
aAdd(aSx2,"CS0") // - Revisão                       
aAdd(aSx2,"CS1") // - Dados complementares da revis.
aAdd(aSx2,"CS2") // - Empresa                       
aAdd(aSx2,"CS3") // - Plano de Contas               
aAdd(aSx2,"CS4") // - Plano de Contas Ref.          
aAdd(aSx2,"CS5") // - Centro de Custo               
aAdd(aSx2,"CS6") // - Visão Gerencial / Conta       
aAdd(aSx2,"CS7") // - Histórico Padrão              
aAdd(aSx2,"CS8") // - Contabilistas                 
aAdd(aSx2,"CS9") // - Participante                  
aAdd(aSx2,"CSA") // - Cabeçalho da movimentação     
aAdd(aSx2,"CSB") // - Itens de movimentações        
aAdd(aSx2,"CSC") // - Balancete                     
aAdd(aSx2,"CSD") // - Balanços cabeçalho            
aAdd(aSx2,"CSE") // - Balanços Itens                
aAdd(aSx2,"CSF") // - Balanços RTF 300b             
aAdd(aSx2,"CSG") // - Balancete Diário              
aAdd(aSx2,"CSH") // - Pré-validação                 
aAdd(aSx2,"CSI") // - Fórmula da Pré-Validação      
aAdd(aSx2,"CSJ") // - Identificação das Contas      
aAdd(aSx2,"CSK") // - Saldo Conta Referencial       
aAdd(aSx2,"CSL") // - Itens movimentações ref.      
aAdd(aSx2,"CSM") // - Dados FCONT                   
aAdd(aSx2,"CSN") // - Cadastro Fatos Contábeis      
aAdd(aSx2,"CSO") // - Detalhe do Fato Contábil      
aAdd(aSx2,"CSP") // - Escrit.Auditores - Reg J935   
aAdd(aSx2,"CSQ") // - Lançamento Extemporaneo       
aAdd(aSx2,"CSR") // - Escrit.SCP - Reg 0035         
aAdd(aSx2,"CST") // - Escrit.Subcontas Correlatas   
aAdd(aSx2,"CSU") // - ECF-DEREX ANO CALENDARIO      
aAdd(aSx2,"CSV") // - Layout de Diarios             
aAdd(aSx2,"CSW") // - Itens Layouts de Diarios      
aAdd(aSx2,"CSX") // - Importacao de Diarios         
aAdd(aSx2,"CSY") // - Importacao de Diarios Quebras 
aAdd(aSx2,"CSZ") // - Dados ECF                     
*/

cQuery := ""
For nI := 1 To Len( aSX2 )

	If SX2->( dbSeek( aSX2[nI] ) )
		
		lOpen := .F.
		cTable := aSX2[nI]+SM0->M0_CODIGO+"0
		cTexto += "Tabela " + cTable + " modo anterior " + SX2->X2_MODO + CRLF

		If  SUBSTR(aSx2[nI],1,2) == "CS"
 			
			If TCCanOpen(cTable)
	   			DBUseArea(.T., 'TOPCONN', cTable, (cTable), .F., .F.)
				//Se conseguir abrir em modo exclusivo, limpa os deletados
				dbSelectArea(cTable)
				cTexto += "Pack " + cTable + CRLF
				MsgRun("Limpando registros - " + cTable, "", {|| __dbPack(), DbCommitAll() })
				dbCloseArea()
				dbSelectArea("SX2")
				lOpen := .T.
			EndIf

		EndIf

		If SX2->X2_MODO <> "C" //.OR. .T.
			RecLock( "SX2", .F. )
			SX2->X2_MODO := "C"
			cTexto += "Tabela " + cTable + " modo alterado " + SX2->X2_MODO + CRLF

			If SUBSTR(aSx2[nI],1,1) == "S"
				cNFil := SUBSTR(aSX2[nI],2,2)
			Else
				cNFil := aSX2[nI]
			EndIf

			If TCCanOpen(cTable) .OR. lOpen
				cQuery += "UPDATE "+aSX2[nI]+SM0->M0_CODIGO+"0 SET "+cNFil+"_FILIAL = '' " + CRLF
			EndIf
			//dbCommit()
			//MsUnLock()
		EndIf

	EndIf

Next nI
Memowrite("C:\TMP\QRYFIL"+SM0->M0_CODIGO+".SQL",cQuery)

cTexto += CRLF + "Final da Atualizacao" + CRLF + Replicate( "-", 128 ) + CRLF + CRLF

Return



Static Function AtuGenP12( cTexto )
//Local cAlias    := ""
//Local cEmpr     := ""
//Local cPath     := ""
//Local nI        := 0
//Local nJ        := 0
//Local nCamp	  := 0

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
