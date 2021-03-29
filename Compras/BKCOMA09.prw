//Bibliotecas
#Include 'Protheus.ch'
#Include 'FwMVCDef.ch'

/*/{Protheus.doc} BKCOMA09
BK- MarkBrow em MVC da tabela SZS-Facilitador p/ Doc de Entrada
@author Marcos Bispo Abrahão
@since 16/03/2021
@version 1.0
@obs Criar a coluna ZS_OK com o tamanho 2 no Configurador e deixar como não usado
/*/

User Function BKCOMA09()
	Private oMark

	//Criando o MarkBrow
	oMark := FWMarkBrowse():New()
	oMark:SetAlias('SZS')

	//Setando semáforo, descrição e campo de mark
	oMark:SetSemaphore(.T.)
	oMark:SetDescription('Facilitador p/ Doc de Entrada')
	oMark:SetFieldMark( 'ZS_OK' )

	// Exemplo de filtro
	//oMark:SetFilterDefault("SZS->ZS_STATUS == '1'")

	// Setando Legenda cores disponíveis: GREEN, RED, YELLOW, ORANGE, BLUE, GRAY, BROWNS, BLACK, PINK e WHITE
	// São criados filtros automáticos para as legendas
	oMark:AddLegend( "SZS->ZS_STATUS == '1'", "GREEN",  "Nota Gerada" )
	oMark:AddLegend( "SZS->ZS_STATUS == '2'", "RED",    "Nota não Gerada" )

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

	// Menu Padrão exemplo: FWMVCMenu('VIEWDEF.MVCSZS') -> cria menu com as opções padrões
    //Criação das opções
    ADD OPTION aRotina TITLE 'Visualizar'  ACTION 'VIEWDEF.MVCSZS' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'     ACTION 'VIEWDEF.MVCSZS' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'     ACTION 'VIEWDEF.MVCSZS' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'     ACTION 'VIEWDEF.MVCSZS' OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Processar'   ACTION 'StaticCall(BKCOMA09, SZSProc)'  OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Classificar' ACTION 'StaticCall(BKCOMA09, SZSClas)'  OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Visual.Doc'  ACTION 'StaticCall(BKCOMA09, SZSVDoc)'  OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Anexar Doc'  ACTION 'StaticCall(BKCOMA09, SZSConh)'  OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Legenda'     ACTION 'u_SZSLeg'       OPERATION 2 ACCESS 0
Return aRotina
 
/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Marcos Bispo Abrahão                                         |
 | Data:  06/03/2021                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
  
Static Function ModelDef()
Local oModel:= FWLoadModel('MVCSZSM')



Return oModel
 
/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Marcos Bispo Abrahão                                         |
 | Data:  06/03/2021                                                   |
 | Desc:  Criação da visão MVC                                         |
 *---------------------------------------------------------------------*/
  
Static Function ViewDef()
Return FWLoadView('MVCSZS')
 
/*/{Protheus.doc} SZSProc
Rotina para processamento dos registros marcados - inclusão de Doc de Entrada
@author Marcos Bispo Abrahão
@since 06/03/2021 
@version 1.0
/*/
Static Function SZSProc()

FWMsgRun(, {|oSay| SZSProc1() }, "", "BKCOMA09 - Gerando Doc. de Entrada...")

Return Nil

/*/{Protheus.doc} SZSProc
Rotina para inclusão de Doc de Entrada
@author Marcos Bispo Abrahão
@since 29/03/2021 
@version 1.0
/*/
Static Function SZSClas()

FWMsgRun(, {|oSay| GeraDocE(.T.) }, "", "BKCOMA09 - Gerando Doc. de Entrada...")

Return Nil


Static Function SZSProc1()

	Local aArea		:= GetArea()
	Local cMarca	:= oMark:Mark()
	//Local lInverte := oMark:IsInvert()
	Local nCt		:= 0
	Local cErro		:= ""

	//Percorrendo os registros da SZS
	SZS->(DbGoTop())
	While !SZS->(EoF())
		//Caso esteja marcado, aumenta o contador
		If oMark:IsMark(cMarca)
			nCt++
			cErro := ""
			//Limpando a marca
			GeraDocE(.F.)
		EndIf

		//Pulando registro
		SZS->(DbSkip())
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
	Local cDoc 		:= SZS->ZS_DOC
	Local cSerie	:= SZS->ZS_SERIE
	//Local cCodigo	:= SZS->ZS_FORNEC
	//Local cLoja	:= SZS->ZS_LOJA
	Local mParcel	:= ""
	Local cErro		:= ""

/* Tabela SZS
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
	mParcel := "01;"+DTOC(SZS->ZS_XXPVPGT)+";"+ALLTRIM(STR(SZS->ZS_TOTAL,14,2))+";"+CRLF
	aAdd(aCabec, {"F1_XXPARCE", mParcel,              Nil})

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


	//Chama a inclusão da pré nota
	SB1->(DbSetOrder(1))
	lMsErroAuto := .F.

	//MATA140(aCabec, aItens, 3)
    Begin Transaction	                                                            

        MSExecAuto({|x,y,z|Mata103(x,y,z)}, aCabec, aItens, 3,lTela)
            
        If lMsErroAuto
            DisarmTransaction()
            //cLogTxt 	+= MostraErro("\system\")
            break
        EndIf                            

    End Transaction

	//Se não houve erros
	If !lMsErroAuto
		cErro := "Documento "+cDoc+" Série "+cSerie+" incluido com sucesso em "+DtoC(Date())+"-"+Time()

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
		lRet :=.F.
		Aviso("Atenção", "Falha ao incluir Documento / Série ('"+cDoc+"/"+cSerie+"')!", {"Ok"}, 2)
		cErro:= MostraErro()
	EndIf

	If lRet
		RecLock('SZS', .F.)
		SZS->ZS_OK		:= ''
		SZS->ZS_STATUS	:= '1'
		SZS->ZS_DULT	:= dDataBase
		SZS->ZS_ERRO	:= cErro
		SZS->(MsUnlock())
	Else
		RecLock('SZS', .F.)
		SZS->ZS_STATUS	:= '2'
		SZS->ZS_ERRO	:= cErro
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
		MsgStop("Documento não encontrado!","Atenção")
	EndIf

	RestArea(aArea)

Return Nil
