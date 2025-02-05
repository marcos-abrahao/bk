//Bibliotecas
#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'

/*/{Protheus.doc} BKCOMA09
BK- MarkBrow em MVC da tabela SZS-Facilitador p/ Doc de Entrada
@author Marcos Bispo Abrah�o
@since 16/03/2021
@version 1.0
@obs Criar a coluna ZS_OK com o tamanho 2 no Configurador e deixar como n�o usado
/*/

User Function BKCOMA09()

	Private oMark
	Private cCadastro := 'Facilitador p/ Doc de Entrada'

	If !FWIsAdmin() .AND. !u_IsMasFin(__cUserId)
		u_MsgLog("BKCOMA09","Usu�rio sem permiss�o de acesso a esta rotina","E")
		Return
	EndIf

	u_MsgLog("BKCOMA09")

	//Criando o MarkBrow
	oMark := FWMarkBrowse():New()
	oMark:SetAlias('SZS')
	
	oMark:SetIgnoreARotina(.T.) 
	oMark:SetMenuDef("BKCOMA09")

	//Setando sem�foro, descri��o e campo de mark
	oMark:SetSemaphore(.T.)
	oMark:SetDescription('Facilitador p/ Doc de Entrada')
	oMark:SetFieldMark( 'ZS_OK' )

	// Exemplo de filtro
	//oMark:SetFilterDefault("SZS->ZS_STATUS == '1'")

	// Setando Legenda cores dispon�veis: GREEN, RED, YELLOW, ORANGE, BLUE, GRAY, BROWNS, BLACK, PINK e WHITE
	// S�o criados filtros autom�ticos para as legendas
	oMark:AddLegend( "SZS->ZS_STATUS == '1'", "GREEN",  "Nota Gerada" )
	oMark:AddLegend( "SZS->ZS_STATUS == '2'", "RED",    "Nota n�o Gerada" )

	//Ativando a janela
	oMark:Activate()
Return NIL



/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Marcos Bispo Abrah�o                                         |
 | Data:  06/03/2021                                                   |
 | Desc:  Cria��o do menu MVC                                          |
 *---------------------------------------------------------------------*/
  
Static Function MenuDef()
    Local aRotina := {}

	// Menu Padr�o exemplo: FWMVCMenu('MVCSZS') //-> cria menu com as op��es padr�es
    //Cria��o das op��es
    ADD OPTION aRotina TITLE 'Visualizar'    ACTION 'VIEWDEF.MVCSZS' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'       ACTION 'VIEWDEF.MVCSZS' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'       ACTION 'VIEWDEF.MVCSZS' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'       ACTION 'VIEWDEF.MVCSZS' OPERATION 5 ACCESS 0
	
    ADD OPTION aRotina TITLE 'Processar'     ACTION 'StaticCall(BKCOMA09, SZSProc)'  OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Classificar'   ACTION 'StaticCall(BKCOMA09, SZSClas)'  OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Visual.Doc'    ACTION 'StaticCall(BKCOMA09, SZSVDoc)'  OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Anexar Doc'    ACTION 'StaticCall(BKCOMA09, SZSConh)'  OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar Datas' ACTION 'StaticCall(BKCOMA09, SZSData)'  OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Legenda'       ACTION 'u_SZSLeg'       OPERATION 2 ACCESS 0
	
Return aRotina
 

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Marcos Bispo Abrah�o                                         |
 | Data:  06/03/2021                                                   |
 | Desc:  Cria��o do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
  
Static Function ModelDef()
//Local oModel:= FWLoadModel('MVCSZSM')
Local oModel:= FWLoadModel('MVCSZS')

Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Marcos Bispo Abrah�o                                         |
 | Data:  06/03/2021                                                   |
 | Desc:  Cria��o da vis�o MVC                                         |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
Local oView := FWLoadView('MVCSZS')
x:=0
Return oView

 
/*/{Protheus.doc} SZSProc
Rotina para processamento dos registros marcados - inclus�o de Doc de Entrada
@author Marcos Bispo Abrah�o
@since 06/03/2021 
@version 1.0
/*/
Static Function SZSProc()

u_WaitLog(, {|oSay| SZSProc1() }, "BKCOMA09 - Gerando Doc. de Entrada...")

Return Nil

/*/{Protheus.doc} SZSProc
Rotina para inclus�o de Doc de Entrada
@author Marcos Bispo Abrah�o
@since 29/03/2021 
@version 1.0
/*/
Static Function SZSClas()

u_WaitLog(, {|oSay| GeraDocE(.T.) }, "BKCOMA09 - Gerando Doc. de Entrada...")

Return Nil


Static Function SZSProc1()

	Local aArea		:= GetArea()
	Local cMarca	:= oMark:Mark()
	//Local lInverte := oMark:IsInvert()
	Local nCt		:= 0

	//Percorrendo os registros da SZS
	SZS->(DbGoTop())
	While !SZS->(EoF())
		//Caso esteja marcado, aumenta o contador
		If oMark:IsMark(cMarca) //If !Empty(SZS->ZS_OK)
			nCt++
			//Limpando a marca
			GeraDocE(.F.)
		EndIf

		//Pulando registro
		dbSelectArea("SZS")
		SZS->(DbSkip())
	EndDo

	//Mostrando a mensagem de registros marcados
	//MsgInfo('Foram marcados <b>' + cValToChar( nCt ) + ' artistas</b>.', "Aten��o")

	//Restaurando �rea armazenada
	RestArea(aArea)
Return NIL


Static Function GeraDocE(lTela)
	Local aCabec    := {}
	Local aLinha    := {}
	Local aItens    := {}
	Local nItem     := 1
    //Local cTipoImp  := "2"  // 1=Pr�-Nota, 2=Doc de Entrada
	Local lRet 		:= .T.
	Local cDoc 		:= SZS->ZS_DOC
	Local cSerie	:= SZS->ZS_SERIE
	//Local cCodigo	:= SZS->ZS_FORNEC
	//Local cLoja	:= SZS->ZS_LOJA
	Local mParcel	:= ""
	Local cErrLog	:= ""

/* Tabela SZS
ZS_OK C 2 N�o usado
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
	aAdd(aCabec, {"F1_DOC",     SZS->ZS_DOC,          Nil})
	aAdd(aCabec, {"F1_SERIE",   SZS->ZS_SERIE,        Nil})
	aAdd(aCabec, {"F1_EMISSAO", SZS->ZS_EMISSAO,      Nil})
	aAdd(aCabec, {"F1_FORNECE", SZS->ZS_FORNEC,       Nil})
	aAdd(aCabec, {"F1_LOJA",    SZS->ZS_LOJA,         Nil})
	aAdd(aCabec, {"F1_ESPECIE", SZS->ZS_ESPECIE,      Nil})
	aAdd(aCabec, {"F1_COND",	SZS->ZS_COND,         Nil})
	aAdd(aCabec, {"F1_XXPVPGT",	SZS->ZS_XXPVPGT,      Nil})
	aAdd(aCabec, {"F1_XTIPOPG",	SZS->ZS_XTIPOPG,      Nil})
	aAdd(aCabec, {"F1_XAGENC",	SZS->ZS_XAGENC,       Nil})
	aAdd(aCabec, {"F1_XBANCO",	SZS->ZS_XBANCO,       Nil})
	aAdd(aCabec, {"F1_XNUMCON",	SZS->ZS_XNUMCON,      Nil})
	aAdd(aCabec, {"F1_XNUMPA",	SZS->ZS_XNUMPA,       Nil})
	aAdd(aCabec, {"F1_XXJSPGT",	SZS->ZS_XXJSPGT,      Nil})

	//01;29/03/2021;397.90;
	mParcel := "01;"+DTOC(SZS->ZS_XXPVPGT)+";"+ALLTRIM(STR(SZS->ZS_TOTAL-SZS->ZS_VALDESC+SZS->ZS_DESPESA,14,2))+";"+CRLF
	aAdd(aCabec, {"F1_XXPARCE", mParcel,              Nil})
	
	aAdd(aCabec, {"F1_DESCONT", SZS->ZS_VALDESC,      Nil})
	aAdd(aCabec, {"F1_DESPESA", SZS->ZS_DESPESA,      Nil})

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
	aAdd(aLinha,  {"D1_COD",     SZS->ZS_COD,         Nil})
	aAdd(aLinha,  {"D1_QUANT",   1,                   Nil})
	aAdd(aLinha,  {"D1_VUNIT",   SZS->ZS_TOTAL,       Nil})
	aAdd(aLinha,  {"D1_TOTAL",   SZS->ZS_TOTAL,       Nil})
	//aAdd(aLinha,  {"D1_VALDESC", SZS->ZS_VALDESC,     Nil})
	//aAdd(aLinha,  {"D1_DESPESA", SZS->ZS_DESPESA,     Nil})
	aAdd(aLinha,  {"D1_TES",     SZS->ZS_TES,         Nil})
	aAdd(aLinha,  {"D1_CC",      SZS->ZS_CC,          Nil})
	aAdd(aLinha,  {"D1_XXHIST",  SZS->ZS_XXHIST,      Nil})
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


	//Chama a inclus�o da pr� nota
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

	//Se n�o houve erros
	If !lMsErroAuto
		cErrLog := "Documento "+cDoc+" S�rie "+cSerie+" incluido com sucesso em "+DtoC(Date())+"-"+Time()

		//Posiciona na SF1
		/*
		SF1->(DbSeek(FWxFilial("SF1") + cDoc + cSerie + cCodigo + cLoja))

		RecLock("SF1",.F.)
		SF1->F1_XXLIB  := "L"
		SF1->F1_XXULIB := __cUserId
		SF1->F1_XXDLIB := DtoC(Date())+"-"+Time()
		MsUnLock("SF1")

		//Se for apenas inclus�o de pr� nota, abre como altera��o
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

			//Chama a pr� nota, como altera��o
			aHeadSD1 := {}
			ALTERA   := .T.
			A140NFiscal('SF1', SF1->(RecNo()), 4)

			//Sen�o, se for classifica��o, abre o documento de Entrada
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
	Else 		//Sen�o, mostra o erro do execauto
		u_MsgLog("BKCOMA09", "Falha ao incluir Documento / S�rie ('"+cDoc+"/"+cSerie+"')!", "E")
		lRet :=.F.
	EndIf

	If lRet
		RecLock('SZS', .F.)
		SZS->ZS_OK		:= ''
		SZS->ZS_STATUS	:= '1'
		SZS->ZS_DULT	:= dDataBase
		SZS->ZS_ERRO	:= cErrLog
		SZS->(MsUnlock())
	Else
		RecLock('SZS', .F.)
		SZS->ZS_STATUS	:= '2'
		SZS->ZS_ERRO	:= cErrLog
		SZS->(MsUnlock())
	EndIf

return lRet



Static Function SZSConh()
	Local aArea		:= GetArea()
	Local cDoc 		:= SZS->ZS_DOC
	Local cSerie	:= SZS->ZS_SERIE
	Local cCodigo	:= SZS->ZS_FORNEC
	Local cLoja		:= SZS->ZS_LOJA
	Local cTipo		:= "N"
	Local nRecF1	:= 0

	//Posiciona na SF1
	SF1->(dbSetOrder(1))
	If SF1->(DbSeek(FWxFilial("SF1") + cDoc + cSerie + cCodigo + cLoja + cTipo))
		nRecF1 := SF1->(RecNo())
		MsDocument("SF1",nRecF1,6)
	EndIf

	RestArea( aArea )
Return Nil



Static Function SZSVDoc()

	Local aArea		:= GetArea()
	Local cDoc 		:= SZS->ZS_DOC
	Local cSerie	:= SZS->ZS_SERIE
	Local cCodigo	:= SZS->ZS_FORNEC
	Local cLoja		:= SZS->ZS_LOJA

	//Posiciona na SF1
	If SF1->(DbSeek(FWxFilial("SF1") + cDoc + cSerie + cCodigo + cLoja))
		aRotina := {;
				{ "Pesquisar",   "AxPesqui",    0, 1}, ;
				{ "Visualizar",  "A103NFiscal", 0, 2}, ;
				{ "Incluir",     "A103NFiscal", 0, 3}, ;
				{ "Classificar", "A103NFiscal", 0, 4}, ;
				{ "Excluir",     "A103NFiscal", 3, 5}, ;
				{ "Imprimir",    "A103Impri",   0, 4}, ;
				{ "Dados Pgto ", "U_AltFPgto",  0, 4}, ;
				{ "Conhecimento","MsDocument",  0, 6}  }

		A103NFiscal('SF1', SF1->(RecNo()), 2)
	Else
		u_MsgLog(,"Documento n�o encontrado!","E")
	EndIf

	RestArea(aArea)

Return Nil


Static Function SZSData()
Local aParam 	:= {}
Local aRet		:=	{}
Local cTitulo   := "Alterar datas em Lote"
Local dDataE	:= SZS->ZS_EMISSAO
Local dDataP	:= SZS->ZS_XXPVPGT
Local lTodos	:= .T.

aAdd( aParam, { 1, "Emiss�o:"		, dDataBase	, ""    , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Pagamento:"		, dDataBase	, ""    , "", ""	, "" , 70  , .F. })  
aAdd( aParam ,{ 2, "Sele��o:"       , "Todos"   , {"Todos", "Marcados"}, 70,'.T.'  ,.T.})

If (Parambox(aParam     ,"BKCOMA09 - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKCOMA09",.T.         ,.T.))
	lRet := .T.
	dDataE  := mv_par01
	dDataP  := mv_par02
	lTodos  := (substr(mv_par03,1,1) == "T")	

	u_WaitLog(, {|oSay| SZSProc2(dDataE,dDataP,lTodos) }, "BKCOMA09 - Alterando datas...")

Endif

Return Nil


Static Function SZSProc2(dDataE,dDataP,lTodos)

	Local aArea		:= GetArea()
	Local cMarca	:= oMark:Mark()
	//Local lInverte := oMark:IsInvert()

	//Percorrendo os registros da SZS
	SZS->(DbGoTop())
	While !SZS->(EoF())

		If lTodos .OR. oMark:IsMark(cMarca)

			RecLock('SZS', .F.)
			SZS->ZS_OK		:= ''
			SZS->ZS_STATUS  := '2'
			SZS->ZS_EMISSAO	:= dDataE
			SZS->ZS_XXPVPGT	:= dDataP
			SZS->(MsUnlock())

		EndIf

		//Pulando registro
		SZS->(DbSkip())
	EndDo

	//Mostrando a mensagem de registros marcados
	u_MsgLog("BKCOMA09",'Datas alteradas', "S")

	//Restaurando �rea armazenada
	RestArea(aArea)
Return .T.
