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
User Function BKCOMP16(cTipoDoc)
Local aArea 	:= GetArea()

Private aParam 	:= {}
Private cTitulo	:= "Facilitador p/ Doc de Entrada"
Private cPerg	:= "BKCOMP16"
Private cDoc 	:= SPACE(9)
Private nValDoc	:= 0
Private cHelp1  := ""
Private cHelp2  := ""
Private cHelp3  := ""
Private cHelp4  := ""
Private cModelZT := SPACE(70)
Private cDepto 	:=  u_UsrCpo(__cUserId,"USR_DEPTO")
Private xTpDoc  := cTipoDoc  // D=Doc, P=Pré-Nota

cHelp1 := "Informe um descritivo para o Modelo:"
cHelp2 := "Exemplo: "+TRIM(Posicione("SA2",1,xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NREDUZ"))

If BKPar1()
	u_WaitLog(cPerg, {|| IncSZT()},"Incluindo modelo "+cModelZT)

	RestArea(aArea)

	u_BKCOMA16(cTipoDoc)
Else
	RestArea(aArea)
EndIF

Return Nil


Static Function BKPar1()
Local lRet := .F.
Local aRet := {}
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
Do While .T.

	aParam := {}
	aAdd( aParam, { 9, cHelp1		, 190		, 10	, .T.})
	aAdd( aParam, { 9, cHelp2		, 190		, 10	, .T.})
	aAdd( aParam, { 1, "Modelo:"	, cModelZT	, ""	, ""	, ""	, ""	, 100	, .T. })

	lRet := (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg      ,.T.         ,.T.))
	If !lRet
		Exit
	Else
		cModelZT	:= SemAcento(UPPER(mv_par03))
		If Empty(cModelZT)
			u_MsgLog(cPerg,"Informe o descritivo do modelo: somente letras e números","E")
		Else
			If u_MsgLog(cPerg,"Confirma inclusão do modelo "+TRIM(cModelZT),"Y")
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



User Function BKCOMA16(cTipoDoc)

	Private oMark
	Private cCadastro := 'Facilitador p/ Doc de Entrada'
	Private cDepto 	:=  u_UsrCpo(__cUserId,"USR_DEPTO")
	Private xTpDoc  := cTipoDoc  // D=Doc, P=Pré-Nota
	Private cPerg	:= "BKCOMA16"

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

	// filtro
	If __cUserID <> "000000" .AND. __cUserID <> "000038"
		oMark:SetFilterDefault("SZT->ZT_DEPTO == '"+cDepto+"' .OR. EMPTY(SZT->ZT_DEPTO)")
	EndIf

	// Setando Legenda cores disponíveis: GREEN, RED, YELLOW, ORANGE, BLUE, GRAY, BROWNS, BLACK, PINK e WHITE
	// São criados filtros automáticos para as legendas
	oMark:AddLegend( "SZT->ZT_DEPTO == '"+cDepto+"' .OR.   EMPTY(SZT->ZT_DEPTO)", "GREEN",  "Uso permitido" )
	oMark:AddLegend( "SZT->ZT_DEPTO <> '"+cDepto+"' .AND. !EMPTY(SZT->ZT_DEPTO)", "RED",    "Uso não permitido" )

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
 ¬
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
			If GeraDocE()
				If SF1->(!EOF())
					dbSelectArea("SZT")
					RecLock("SZT",.F.)
					// Grava a nova NF como modelo
					SZT->ZT_SERIE	:= SF1->F1_SERIE
					SZT->ZT_DOC		:= SF1->F1_DOC
					SZT->ZT_FORNEC	:= SF1->F1_FORNECE
					SZT->ZT_LOJA	:= SF1->F1_LOJA
					//Limpando a marca
					SZT->ZT_OK		:= "  "
					SZT->(MsUnLock())
					u_MsgLog(cPerg,"Documento "+SF1->F1_DOC+" incluído via modelo "+TRIM(SZT->ZT_MODELO),"S")
				Else
					u_MsgLog(cPerg,"Documento não foi incluído (*)","E")
				EndIf
			Else
				u_MsgLog(cPerg,"Documento não foi incluído (**)","E")
			EndIf
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


Static Function GeraDocE()
	Local aCabec    := {}
	Local aLinha    := {}
	Local aItens    := {}
	Local nTotal 	:= 0
	Local nTotalR	:= 0
	Local nFator	:= 0
	Local nItem     := 0
	Local lRet 		:= .T.
	Local cDoc 		:= SZT->ZT_DOC
	Local cSerie	:= SZT->ZT_SERIE
	Local cCodigo	:= SZT->ZT_FORNEC
	Local cLoja		:= SZT->ZT_LOJA
	Local cTipo		:= "N"
	Local cHist		:= ""
	Local dEmissao  := DATE()
	Local dVenc 	:= DATE()
	Local aParc 	:= {}
	Local nX 		:= 0
	Local nValor 	:= 0

	Local nPosQtd	:= 0
	Local nPosVUn	:= 0
	Local nPosTot	:= 0
	Local nPosHis	:= 0

	SF1->(dbSetOrder(1))
	If !SF1->(DbSeek(FWxFilial("SF1") + cDoc + cSerie + cCodigo + cLoja + cTipo))
		u_MsgLog(cPerg,"Documento referenciado no modelo não foi encontrado, exclua este modelo!","E")
		Return .F.
	Else
		If xTpDoc == "D" .AND. SF1->F1_STATUS <> "A"
			u_MsgLog(cPerg,"Documento referenciado no modelo não foi classificado!","E")
			Return .F.
		EndIf
	EndIF

	//Variaveis utilizadas no P.E. SF1140i
	Private ycxTipoPg := SF1->F1_XTIPOPG
	Private ycxNumPa  := SF1->F1_XNUMPA
	Private ycxBanco  := SF1->F1_XBANCO
	Private ylxP1PA   := IIF(SF1->F1_XXP1PA=='S',.T.,.F.)
	Private ycxAgencia:= SF1->F1_XAGENC
	Private ycxConta  := SF1->F1_XNUMCON
	Private ycChvNfe  := SF1->F1_CHVNFE
	Private ydPrvPgt  := dVenc
	Private ycJsPgt	  := SF1->F1_XXJSPGT
	Private ycxTpPix  := SF1->F1_XXTPPIX
	Private ycxChPix  := SF1->F1_XXCHPIX
	Private ynTipoPg  := 0
	Private ycEspecie := SF1->F1_ESPECIE
	Private ycxCond	  := IIF(EMPTY(SF1->F1_COND),"092",SF1->F1_COND)

	//Private ymParcel  := SF1->F1_XXPARCE

	Private lMSErroAuto	:= .F.

	SD1->(dbSetOrder(1))
	If SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

		nItem := 0
		Do While !EOF() .AND. SD1->D1_FILIAL+SD1->D1_DOC+ SD1->D1_SERIE+ SD1->D1_FORNECE+ SD1->D1_LOJA  == 	xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA  

			aLinha := {}
			nItem++

			aAdd(aLinha,  {"D1_ITEM",    StrZero(nItem, 3),	Nil})

			aAdd(aLinha,  {"D1_FILIAL",  FWxFilial('SD1'),	Nil})

			aAdd(aLinha,  {"D1_COD",     SD1->D1_COD,		Nil})

			aAdd(aLinha,  {"D1_QUANT",   SD1->D1_QUANT,		Nil})
			nPosQtd	:= Len(aLinha)

			aAdd(aLinha,  {"D1_VUNIT",   SD1->D1_VUNIT,		Nil})
			nPosVUn	:= Len(aLinha)

			aAdd(aLinha,  {"D1_TOTAL",   SD1->D1_TOTAL,		Nil})
			nPosTot	:= Len(aLinha)

			//If !Empty(SD1->D1_TES) .AND. xTpDoc == 'D'
				aAdd(aLinha,  {"D1_TES", SD1->D1_TES,		Nil})
			//EndIf
			
			aAdd(aLinha,  {"D1_CC",      SD1->D1_CC,		Nil})

			If nItem == 1
				aAdd(aLinha,  {"D1_XXHIST",  cHist,			Nil})
			Else
				aAdd(aLinha,  {"D1_XXHIST",  "",			Nil})
			EndIf
			nPosHis	:= Len(aLinha)

			aAdd(aLinha,  {"D1_LOCAL",   SD1->D1_LOCAL,		Nil})

			aAdd(aLinha,  {"AUTDELETA",  "N",				Nil})

			aAdd(aItens, aLinha)

			If !Empty(SD1->D1_XXHIST) .AND. Empty(cHist)
				cHist := SD1->D1_XXHIST
			EndIf

			nTotal += SD1->D1_TOTAL
			SD1->(dbSkip())
		EndDo
	EndIf
	nValor := nTotal

	dVenc := DataValida(dVenc,.T.)
	If ExistCpo("SE4", ycxCond)
		aParc := Condicao(nTotal,ycxCond,,dDataBase)
		If Len(aParc) > 0
			dVenc 	:= DataValida(aParc[1,1],.T.)
		EndIf
	EndIf
	ydPrvPgt:= dVenc

	// Pegar os dados para o novo documento
	If !GetDoc(@cSerie,@cDoc,cCodigo,cLoja,@dEmissao,@dVenc,@nValor,@cHist)
		Return .F.
	EndIf

	aAdd(aCabec, {"F1_TIPO",    cTipo,				Nil})
	aAdd(aCabec, {"F1_FORMUL",  "N",				Nil})
	aAdd(aCabec, {"F1_DOC",     cDoc,				Nil})
	aAdd(aCabec, {"F1_SERIE",   cSerie,				Nil})
	aAdd(aCabec, {"F1_EMISSAO", dEmissao,			Nil})
	aAdd(aCabec, {"F1_FORNECE", cCodigo,			Nil})
	aAdd(aCabec, {"F1_LOJA",    cLoja,				Nil})
	aAdd(aCabec, {"F1_ESPECIE", SF1->F1_ESPECIE,	Nil})
	aAdd(aCabec, {"F1_EST", 	SF1->F1_EST,		Nil})
	aAdd(aCabec, {"F1_TPFRETE", SF1->F1_TPFRETE,	Nil})
	aAdd(aCabec, {"F1_COND",	ycxCond,			Nil})

/*
	aAdd(aCabec, {"F1_XXPVPGT",	dVenc,				Nil})
	aAdd(aCabec, {"F1_XTIPOPG",	SF1->F1_XTIPOPG,	Nil})
	aAdd(aCabec, {"F1_XAGENC",	SF1->F1_XAGENC,		Nil})
	aAdd(aCabec, {"F1_XBANCO",	SF1->F1_XBANCO,		Nil})
	aAdd(aCabec, {"F1_XNUMCON",	SF1->F1_XNUMCON,	Nil})
	aAdd(aCabec, {"F1_XNUMPA",	SF1->F1_XNUMPA,		Nil})
	aAdd(aCabec, {"F1_XXJSPGT",	SF1->F1_XXJSPGT,	Nil})
	aAdd(aCabec, {"F1_XXP1PA",	SF1->F1_XXP1PA,		Nil})
	aAdd(aCabec, {"F1_DESCONT", SF1->F1_DESCONT,	Nil})
	aAdd(aCabec, {"F1_DESPESA", SF1->F1_DESPESA,	Nil})
*/

	//01;29/03/2021;397.90;
	//mParcel := "01;"+DTOC(dVenc)+";"+ALLTRIM(STR(nValor,14,2))+";"+CRLF
	//aAdd(aCabec, {"F1_XXPARCE", mParcel,			Nil})
	

	// Liberar automaticamente o Doc
	If xTpDoc == 'D'
		aAdd(aCabec, {"F1_XXLIB",	"L",			      Nil})
		aAdd(aCabec, {"F1_XXULIB",	__cUserId,		      Nil})
		aAdd(aCabec, {"F1_XXDLIB",	DtoC(Date())+"-"+Time(), Nil})
	Endif

	//aAdd(aCabec, {"F1_SEGURO",  nSeguro,                                   Nil})
	//aAdd(aCabec, {"F1_FRETE",   nFrete,                                    Nil})
	//aAdd(aCabec, {"F1_VALMERC", nTotalMerc,                                Nil})
	//aAdd(aCabec, {"F1_VALBRUT", nTotalMerc + nSeguro + nFrete + nIcmsSubs, Nil})
	//aAdd(aCabec, {"F1_CHVNFE",  cChaveNFE,                                 Nil})

	// Rateio com o valor novo

	nFator  := nValor / nTotal
	nTotalR := 0 
	For nX := 1 To Len(aItens)
		nValIt := ROUND(aItens[nX,nPosTot,2] * nFator,2)
		aItens[nX,nPosTot,2] := nValIt  // Total
		aItens[nX,nPosVUn,2] := nValIt / aItens[nX,nPosQtd,2]

		nTotalR += nValIt
	Next
	
	// Acertar a diferença no primeiro item
	If nTotalR <> nValor
		aItens[1,nPosTot,2] += (nValor - nTotalR)
		aItens[1,nPosVUn,2] += (nValor - nTotalR) / aItens[1,4,2]
	EndIf

	// Gravar o histórico no item 1
	aItens[1,nPosHis,2] := cHist

	If xTpDoc == "D"  // Documento de Entrada
		MATA103(aCabec, aItens, 3, .T.) // inclusão Tela
	Else // Pré-Nota
		MATA140(aCabec, aItens, 3, .F., 5)
	EndIf

	If lMsErroAuto      
		MostraErro()
		lRet := .F.	
	Else
		SF1->(dbSetOrder(1))
		If !SF1->(DbSeek(FWxFilial("SF1") + cDoc + cSerie + cCodigo + cLoja + cTipo))
			// Documento não foi incluído
			lRet := .F.
		EndIf
	EndIf 

return lRet




Static Function GetDoc(cSerie,cDoc,cCodigo,cLoja,dEmissao,dVenc,nValor,cHist)
Local aArea		:= Getarea()
Local aAreaF1	:= SF1->(Getarea())
Local oDlg		as Object
Local oFont		as Object
Local oPanel01	as Object

Local aButtons	:= {}
Local lOk		:= .F.
Local cPict		:= "@E 99,999,999,999.99"
Local cTitulo2	:= "Dados para o novo Documento: "+TRIM(SUBSTR(SZT->ZT_MODELO,1,20))
Local nPar 		:= 0

Private oSerie	as Object
Private oDoc	as Object
Private oEmis	as Object
Private oVenc	as Object
Private oMemo	as Object

If cSerie == "DNF"
	nPar := GetMv("MV_XXNUMF1",.F.,STRZERO(0,9))
	nPar++
	cDoc := STRZERO(nPar,9)
	PutMv("MV_XXNUMF1",cDoc)
EndIf

//DO WHILE .T.	

    DEFINE MSDIALOG oDlg TITLE cTitulo2 FROM 000,000  TO 520,700  PIXEL
    
    	@ 000, 000 MSPANEL oPanel01 Size 500, 700 OF oDlg

		@ 035, 010 Say oSay		Prompt "Série:"  Size 65,07 OF oPanel01 PIXEL
		@ 034, 070 MSGet oSerie Var cSerie Size 50,10 OF oPanel01 PIXEL //HASBUTTON

		@ 047, 010 Say oSay		Prompt "Documento:"  Size 65,07 OF oPanel01 PIXEL
		@ 046, 070 MSGet oDoc	Var cDoc   Size 50,10 VALID !EMPTY(cDoc) OF oPanel01 PIXEL //HASBUTTON

		@ 059, 010 Say oSay		Prompt "Valor da Nota:" Size  100,10 Of oPanel01 Pixel
		@ 058, 070 MSGet oValor Var nValor Size  080,10 Of oPanel01 Pixel Picture cPict 

		@ 071, 010 Say oSay 	Prompt "Emissão:" Size  40,10 Of oPanel01 Pixel
		@ 070, 070 MSGet oEmis	Var dEmissao  Size  50,10 Of oPanel01 Pixel Picture "@E" HASBUTTON 

		@ 083, 010 Say oSay 	Prompt "Vencimento:" Size  40, 10 Of oPanel01 Pixel
		@ 082, 070 MSGet oVenc 	Var dVenc Size  50,10 Of oPanel01 Pixel Picture "@E" HASBUTTON 

		@ 095, 010 Say oSay 	Prompt "Histórico:" Size  40, 10 Of oPanel01 Pixel
		@ 094, 070 Get oMemo 	Var cHist Memo Size 200, 145 Of oDlg Pixel
		oMemo:bRClicked := { || AllwaysTrue() }
		oMemo:oFont     := oFont
		
	ACTIVATE MSDIALOG oDlg CENTERED Valid(ValidaDoc(cSerie,@cDoc,cCodigo,cLoja,dEmissao,dVenc,nValor,cHist)) ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , @aButtons)
	                   
Restarea( aArea )
SF1->(RestArea(aAreaF1))

RETURN lOk



Static Function ValidaDoc(cSerie,cDoc,cCodigo,cLoja,dEmissao,dVenc,nValor,cHist)
Local lRet	:= .T.
Local cTipo	:= "N"

If Val(cDoc) > 0
	cDoc := STRZERO(VAL(ALLTRIM(cDoc)),9)
	oDoc:Refresh()
Else
	u_MsgLog(cPerg,"Número do documento incorreto","E")
	lRet := .F.
EndIf

If lRet
	If SF1->(dbSeek(xFilial("SF1") + cDoc + cSerie + cCodigo + cLoja + cTipo))
		u_MsgLog(cPerg,"Número do documento já existe","E")
		lRet := .F.
	EndIf
EndIf

Return lRet
