//Bibliotecas
#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'

/*/{Protheus.doc} BKCOMA16
BK- MVC da tabela SZT-Facilitador p/ Doc de Entrada
@author Marcos Bispo Abrahão
@since 11/04/2024
@version 1.0
@obs Criar a coluna ZT_OK com o tamanho 2 no Configurador e deixar como não usado
/*/
User Function BKCOMP16()
Local aArea 	:= GetArea()

Private aParam 	:= {}
Private cTitulo	:= "Facilitador p/ Doc de Entrada"
Private cPerg	:= "BKCOMA16"
Private cDoc 	:= SPACE(9)
Private nValDoc	:= 0
Private cHelp1  := ""
Private cHelp2  := ""
Private cHelp3  := ""
Private cHelp4  := ""
Private cModelZT := SPACE(70)
Private cDepto 	:=  u_UsrCpo(__cUserId,"USR_DEPTO")

cHelp1 := "Informe um descritivo para o Modelo:"
cHelp2 := "Exemplo: CONTA DE LUZ AV IPIRANGA"
cHelp3 := "Série: "+SF1->F1_SERIE+" Doc: "+SF1->F1_DOC 
cHelp4 := TRIM(Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NREDUZ"))

If BKPar1()
	u_WaitLog(cPerg, {|| IncSZT()},"Incluindo modelo "+cModelZT)
ENDIF

RestArea(aArea)
Return Nil


Static Function BKPar1()
Local lRet := .F.
Local aRet := {}
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
Do While .T.

	aParam := {}
	aAdd( aParam, { 1, "Modelo:"	, cModelZT	, ""	, ""	, ""	, ""	, 100	, .F. })
	aAdd( aParam, { 9, cHelp1		, 190		, 10	, .T.})
	aAdd( aParam, { 9, cHelp2		, 190		, 10	, .T.})
	aAdd( aParam, { 9, cHelp3		, 190		, 10	, .T.})
	aAdd( aParam, { 9, cHelp4		, 190		, 10	, .T.})

	lRet := (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg      ,.T.         ,.T.))
	If !lRet
		Exit
	Else
		cModelZT	:= SemAcento(UPPER(mv_par01))
		If Empty(cModelZT)
			u_MsgLog(cPerg,"Informe o descritivo do modelo: somente letras e numeros","E")
		Else
			If u_MsgLog(cPerg,"Confirma o modelo "+TRIM(cModelZT),"Y")
				dbSelectArea("SZT")
				dbSetOrder(1)
				If dbSeek(xFilial("SZT")+cModelZT)
					u_MsgLog(cPerg,"Já existe modelo cadastrado com este nome","E")
				Else
					lRet := .T.
					Exit
				EndIf
			EndIf
		EndIf
	Endif
EndDo
Return lRet


// Corrige acentos e espaços no modelo
Static Function SemAcento(cStr)
Local cRet  := cStr
Local cRet1 := ""
Local cChar := ""
Local nI    := 0
Local nTam	:= LEN(cStr)

cRet := Alltrim(FwNoAccent(cRet))
Do While "  " $ cRet
    cRet := STRTRAN(cRet,"  "," ")
EndDo

// Remover ponto se houver mais de 1 ponto
cRet1 := ""
For nI := 1 To Len(cRet)
    cChar := SUBSTR(cRet,nI,1)
    If IsAlpha(cChar) .OR. cChar $ "0123456789 "
	    cRet1 := cRet1+cChar
    EndIf
Next
cRet := PAD(cRet1,nTam)

Return cRet


Static Function IncSZT()
dbSelectArea("SZT")
Reclock("SZT",.T.)
SZT->ZT_MODELO	:= cModelZT
SZT->ZT_SERIE	:= SF1->F1_SERIE
SZT->ZT_DOC		:= SF1->F1_DOC
SZT->ZT_FORNEC	:= SF1->F1_FORNECE
SZT->ZT_LOJA	:= SF1->F1_LOJA
SZT->ZT_USER	:= __cUserId
SZT->ZT_DEPTO	:= cDepto

SZT->(Msunlock())

Return Nil



User Function BKCOMA16()

	Private oMark
	Private cCadastro := 'Facilitador p/ Doc de Entrada'
	Private cDepto 	:=  u_UsrCpo(__cUserId,"USR_DEPTO")

	If !FWIsAdmin() .AND. !IsGesFin(__cUserId)
		u_MsgLog("BKCOMA16","Usuário sem permissão de acesso a esta rotina","E")
		Return
	EndIf

	u_MsgLog("BKCOMA16")

	//Criando o MarkBrow
	oMark := FWMarkBrowse():New()
	oMark:SetAlias('SZT')
	
	oMark:SetIgnoreARotina(.T.) 
	oMark:SetMenuDef("BKCOMA16")

	//Setando semáforo, descrição e campo de mark
	oMark:SetSemaphore(.T.)
	oMark:SetDescription('Facilitador p/ Doc de Entrada')
	
	oMark:SetFieldMark( 'ZT_OK' )

	// Exemplo de filtro
	//oMark:SetFilterDefault("SZT->ZS_STATUS == '1'")

	// Setando Legenda cores disponíveis: GREEN, RED, YELLOW, ORANGE, BLUE, GRAY, BROWNS, BLACK, PINK e WHITE
	// São criados filtros automáticos para as legendas
	oMark:AddLegend( "SZT->ZT_DEPTO == '"+cDepto+"' .OR.  SZT->ZT_USER == '"+__cUserId+"'", "GREEN",  "Uso permitido" )
	oMark:AddLegend( "SZT->ZT_DEPTO <> '"+cDepto+"' .AND. SZT->ZT_USER <> '"+__cUserId+"'", "RED",    "Uso não permitido" )

	//Ativando a janela
	oMark:Activate()
Return NIL



/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Marcos Bispo Abrahão                                         |
 | Data:  06/03/2021                                                   |
 | Desc:  Criação do menu MVC                                          |
 *---------------------------------------------------------------------*/
  
Static Function MenuDef()
    Local aRotina := {}

	// Menu Padrão exemplo: FWMVCMenu('MVCSZT') //-> cria menu com as opções padrões
    //Criação das opções
    ADD OPTION aRotina TITLE 'Gerar Doc'     ACTION 'StaticCall(BKCOMA16, SZTProc)'  OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Visualizar'    ACTION 'VIEWDEF.MVCSZT' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'       ACTION 'VIEWDEF.MVCSZT' OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Legenda'       ACTION 'u_SZTLeg'       OPERATION 2 ACCESS 0
	
Return aRotina
 

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Marcos Bispo Abrahão                                         |
 | Data:  06/03/2021                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
  
Static Function ModelDef()
//Local oModel:= FWLoadModel('MVCSZTM')
Local oModel:= FWLoadModel('MVCSZT')

Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Marcos Bispo Abrahão                                         |
 | Data:  06/03/2021                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
Local oView := FWLoadView('MVCSZT')
x:=0
Return oView

 
/*/{Protheus.doc} SZTProc
Rotina para processamento dos registros marcados - inclusão de Doc de Entrada
@author Marcos Bispo Abrahão
@since 06/03/2021 
@version 1.0
/*/
Static Function SZTProc()

u_WaitLog(, {|oSay| SZTProc1() }, "BKCOMA16 - Gerando Doc. de Entrada...")

Return Nil


Static Function SZTProc1()

	Local aArea		:= GetArea()
	Local cMarca	:= oMark:Mark()
	//Local lInverte := oMark:IsInvert()
	Local nCt		:= 0

	//Percorrendo os registros da SZT
	SZT->(DbGoTop())
	While !SZT->(EoF())
		//Caso esteja marcado, aumenta o contador
		If oMark:IsMark(cMarca) //If !Empty(SZT->ZS_OK)
			nCt++
			//Limpando a marca
			GeraDocE(.F.)
		EndIf

		//Pulando registro
		dbSelectArea("SZT")
		SZT->(DbSkip())
	EndDo

	//Mostrando a mensagem de registros marcados
	//MsgInfo('Foram marcados <b>' + cValToChar( nCt ) + ' artistas</b>.', "Atenção")

	//Restaurando área armazenada
	RestArea(aArea)
Return NIL


Static Function GeraDocE(lTela)
	Local aCabec    := {}
	Local aLinha    := {}
	Local aItens    := {}
	Local nItem     := 1
    //Local cTipoImp  := "2"  // 1=Pré-Nota, 2=Doc de Entrada
	Local lRet 		:= .T.
	Local cDoc 		:= SZT->ZS_DOC
	Local cSerie	:= SZT->ZS_SERIE
	//Local cCodigo	:= SZT->ZS_FORNEC
	//Local cLoja	:= SZT->ZS_LOJA
	Local mParcel	:= ""
	Local cErrLog	:= ""

/* Tabela SZT
ZS_OK C 2 Não usado
ZS_FORNEC
ZS_LOJA
ZS_DOC
ZS_SERIE
ZS_EMISSAO
ZS_ESPECIE
ZS_COND
ZS_XXPVPGT
ZS_XTIPOPG
ZS_XAGENC
ZS_XBANCO
ZS_XNUMCON
ZS_XNUMPA
ZS_STATUS
ZS_UDATA

ZS_COD
ZS_TOTAL
ZS_VALDESC
ZS_DESPESA
ZS_TES
ZS_CC
ZS_XXHIST

 */
	aAdd(aCabec, {"F1_TIPO",    'N',                  Nil})
	aAdd(aCabec, {"F1_FORMUL",  "N",                  Nil})
	aAdd(aCabec, {"F1_DOC",     SZT->ZS_DOC,          Nil})
	aAdd(aCabec, {"F1_SERIE",   SZT->ZS_SERIE,        Nil})
	aAdd(aCabec, {"F1_EMISSAO", SZT->ZS_EMISSAO,      Nil})
	aAdd(aCabec, {"F1_FORNECE", SZT->ZS_FORNEC,       Nil})
	aAdd(aCabec, {"F1_LOJA",    SZT->ZS_LOJA,         Nil})
	aAdd(aCabec, {"F1_ESPECIE", SZT->ZS_ESPECIE,      Nil})
	aAdd(aCabec, {"F1_COND",	SZT->ZS_COND,         Nil})
	aAdd(aCabec, {"F1_XXPVPGT",	SZT->ZS_XXPVPGT,      Nil})
	aAdd(aCabec, {"F1_XTIPOPG",	SZT->ZS_XTIPOPG,      Nil})
	aAdd(aCabec, {"F1_XAGENC",	SZT->ZS_XAGENC,       Nil})
	aAdd(aCabec, {"F1_XBANCO",	SZT->ZS_XBANCO,       Nil})
	aAdd(aCabec, {"F1_XNUMCON",	SZT->ZS_XNUMCON,      Nil})
	aAdd(aCabec, {"F1_XNUMPA",	SZT->ZS_XNUMPA,       Nil})
	aAdd(aCabec, {"F1_XXJSPGT",	SZT->ZS_XXJSPGT,      Nil})

	//01;29/03/2021;397.90;
	mParcel := "01;"+DTOC(SZT->ZS_XXPVPGT)+";"+ALLTRIM(STR(SZT->ZS_TOTAL-SZT->ZS_VALDESC+SZT->ZS_DESPESA,14,2))+";"+CRLF
	aAdd(aCabec, {"F1_XXPARCE", mParcel,              Nil})
	
	aAdd(aCabec, {"F1_DESCONT", SZT->ZS_VALDESC,      Nil})
	aAdd(aCabec, {"F1_DESPESA", SZT->ZS_DESPESA,      Nil})

	// Liberar automaticamente o Doc
	//aAdd(aCabec, {"F1_XXLIB",	"L",			      Nil})
	//aAdd(aCabec, {"F1_XXULIB",	__cUserId,		      Nil})
	//aAdd(aCabec, {"F1_XXDLIB",	DtoC(Date())+"-"+Time(), Nil})

	//aAdd(aCabec, {"F1_SEGURO",  nSeguro,                                   Nil})
	//aAdd(aCabec, {"F1_FRETE",   nFrete,                                    Nil})
	//aAdd(aCabec, {"F1_VALMERC", nTotalMerc,                                Nil})
	//aAdd(aCabec, {"F1_VALBRUT", nTotalMerc + nSeguro + nFrete + nIcmsSubs, Nil})
	//aAdd(aCabec, {"F1_CHVNFE",  cChaveNFE,                                 Nil})

	aAdd(aLinha,  {"D1_ITEM",    StrZero(nItem, 3),   Nil})
	aAdd(aLinha,  {"D1_FILIAL",  FWxFilial('SD1'),    Nil})
	aAdd(aLinha,  {"D1_COD",     SZT->ZS_COD,         Nil})
	aAdd(aLinha,  {"D1_QUANT",   1,                   Nil})
	aAdd(aLinha,  {"D1_VUNIT",   SZT->ZS_TOTAL,       Nil})
	aAdd(aLinha,  {"D1_TOTAL",   SZT->ZS_TOTAL,       Nil})
	//aAdd(aLinha,  {"D1_VALDESC", SZT->ZS_VALDESC,     Nil})
	//aAdd(aLinha,  {"D1_DESPESA", SZT->ZS_DESPESA,     Nil})
	aAdd(aLinha,  {"D1_TES",     SZT->ZS_TES,         Nil})
	aAdd(aLinha,  {"D1_CC",      SZT->ZS_CC,          Nil})
	aAdd(aLinha,  {"D1_XXHIST",  SZT->ZS_XXHIST,      Nil})
	aAdd(aLinha,  {"D1_LOCAL",   "01",                Nil})


	//aAdd(aLinha,     {"D1_X_TPCUS", "1",                 Nil})
	//aAdd(aLinha,     {"D1_VALDESC", nDescLote,           Nil})
	//aAdd(aLinha,     {"D1_LOTEFOR", cLote,               Nil})

	//If ! Empty(cPedAut)
	//	aAdd(aLinha, {"D1_PEDIDO",  cPedAut,             Nil})
	//	aAdd(aLinha, {"D1_ITEMPC",  cItPedAut,           Nil})
	//EndIf
	aAdd(aLinha,     {"AUTDELETA",  "N",                 Nil})
	aAdd(aItens, aLinha)


	//Chama a inclusão da pré nota
	SB1->(DbSetOrder(1))
	lMsErroAuto := .F.

	//MATA140(aCabec, aItens, 3)
    Begin Transaction	                                                            

        MSExecAuto({|x,y,z|Mata103(x,y,z)}, aCabec, aItens, 3,lTela)
            
		If lMsErroAuto 
			u_LogMsExec(,,)
            DisarmTransaction()
            break
        EndIf                            

    End Transaction

	//Se não houve erros
	If !lMsErroAuto
		cErrLog := "Documento "+cDoc+" Série "+cSerie+" incluido com sucesso em "+DtoC(Date())+"-"+Time()

		//Posiciona na SF1
		/*
		SF1->(DbSeek(FWxFilial("SF1") + cDoc + cSerie + cCodigo + cLoja))

		RecLock("SF1",.F.)
		SF1->F1_XXLIB  := "L"
		SF1->F1_XXULIB := __cUserId
		SF1->F1_XXDLIB := DtoC(Date())+"-"+Time()
		MsUnLock("SF1")

		//Se for apenas inclusão de pré nota, abre como alteração
		If cTipoImp == "1"
			aRotina	:= {;
				{ "Pesquisar",             "AxPesqui",    0, 1,0, .F.},;
				{ "Visualizar",            "A140NFiscal", 0, 2,0, .F.},;
				{ "Incluir",               "A140NFiscal", 0, 3,0, Nil},;
				{ "Alterar",               "A140NFiscal", 0, 4,0, Nil},;
				{ "Excluir",               "A140NFiscal", 0, 5,0, Nil},;
				{ "Imprimir",              "A140Impri",   0, 4,0, Nil},;
				{ "Estorna Classificacao", "A140EstCla",  0, 5,0, Nil},;
				{ "Legenda",               "A103Legenda", 0, 2,0, .F.}}

			//Chama a pré nota, como alteração
			aHeadSD1 := {}
			ALTERA   := .T.
			A140NFiscal('SF1', SF1->(RecNo()), 4)

			//Senão, se for classificação, abre o documento de Entrada
		ElseIf cTipoImp == "2" //Classifica
			aRotina := {;
				{ "Pesquisar",   "AxPesqui",    0, 1}, ;
				{ "Visualizar",  "A103NFiscal", 0, 2}, ;
				{ "Incluir",     "A103NFiscal", 0, 3}, ;
				{ "Classificar", "A103NFiscal", 0, 4}, ;
				{ "Retornar",    "A103Devol",   0, 3}, ;
				{ "Excluir",     "A103NFiscal", 3, 5}, ;
				{ "Imprimir",    "A103Impri",   0, 4}, ;
				{ "Legenda",     "A103Legenda", 0, 2} }

			//Abre a tela de documento de entrada

			A103NFiscal('SF1', SF1->(RecNo()), 4)
		EndIf
		*/
	Else 		//Senão, mostra o erro do execauto
		u_MsgLog("BKCOMA16", "Falha ao incluir Documento / Série ('"+cDoc+"/"+cSerie+"')!", "E")
		lRet :=.F.
	EndIf

	If lRet
		RecLock('SZT', .F.)
		SZT->ZS_OK		:= ''
		SZT->ZS_STATUS	:= '1'
		SZT->ZS_DULT	:= dDataBase
		SZT->ZS_ERRO	:= cErrLog
		SZT->(MsUnlock())
	Else
		RecLock('SZT', .F.)
		SZT->ZS_STATUS	:= '2'
		SZT->ZS_ERRO	:= cErrLog
		SZT->(MsUnlock())
	EndIf

return lRet


Static Function GeraDoc()
Private aParam 	:= {}
Private cTitulo	:= "Facilitador p/ Doc de Entrada"
Private cPerg	:= "BKCOMA16"
Private cDoc 	:= SPACE(9)
Private nValDoc	:= 0
Private cHelp1  := ""
Private cHelp2  := ""
Private cHelp3  := ""
Private cHelp4  := ""

cHelp1 := "Preeencha SOMENTE os campos que deseja na pesquisa, os outros, deixe em branco ou zero." 
cHelp2 := "A pesquisa é feita por parte do campo:"
cHelp3 := "Exemplo: Descrição do produdo = 'BOTA' irá retornar todas NFs que possuam a palavra BOTA na descrição dos produtos."
cHelp4 := "Após a pesquisa, posicione na linha e clique em OK para posicionar na NF."

aAdd( aParam, { 9, cHelp1					, 190		, 30	, .T.})
aAdd( aParam, { 9, cHelp2					, 190		, 20	, .T.})
aAdd( aParam, { 9, cHelp3					, 190		, 30	, .T.})
aAdd( aParam, { 9, cHelp4					, 190		, 40	, .T.})
aAdd( aParam, { 1, "Numero NF:"				, cDoc		, ""	, ""	, ""	, ""	, 70	, .F. })
aAdd( aParam, { 1, "Valor da NF:"			, nValDoc	, ""	, ""	, ""	, ""	, 70	, .F. })

If BKPar2()
	u_WaitLog(cPerg, {|| PRCOMC01()},"Aguarde o resultado da pesquisa...")
ENDIF
Return Nil

Static Function BKPar2()
Local lRet := .F.
Local aRet := {}
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
	If (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg      ,.T.         ,.T.))
		cDoc	:= mv_par05
		nValDoc	:= mv_par06
		lRet	:= .T.
	Endif
Return lRet

