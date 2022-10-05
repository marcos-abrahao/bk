#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TOTVS.CH"

//-----------------------------------------------------------
/*/{Protheus.doc} TTMARKB
MarkBrowse Dinâmico
@author Felipe Caiado
@since 24/05/2019
@version 1.0
@param aCampos, array, Campos do MarkBrowse
@param aDados, array, Valores do MarkBrowse
@param aDados, logical, Campo Totalizador?
@param aDados, char, Cmpo do Totalizado
@param aDados, char, Marcado?

@type Function
/*/
//-----------------------------------------------------------
User Function TestMrk()

Local aCampos := {{ "MARCA"    , "C", 02, 0, "Marca"    ,"@!", .F., "" },;
				  { "ROTINA"   , "C", 15, 0, "Rotina"   ,"@!", .T., "" },;
				  { "DESCRICAO", "C", 50, 0, "Descrição","@!", .T., "" } }

Local aDados  := {{"","Rotina1","Rotina11"},{"","Rotina2","Rotina22"}}

u_TTMARKB(aCampos, aDados, .F., "", .F.)

Return NIL



User Function TTMARKB(aCampos, aDados, lCmpTot, cCmpTot, lMarcado)

	Local aSize as array
	Local aObjects as array
	Local oDlgBrw as object
	Local cAliasBrw as character
	Local aField as array
	Local nX as numeric
	Private cMark as character
	Private oTotSel as Object
	Private nTotSel as numeric
	Private oQtdSel as Object
	Private nQtdSel as numeric

	Default aCampos := {}
	Default aDados := {}
	Default lCmpTot := .F.
	Default cCmpTot := ""
	Default lMarcado := .T.

	//Verifica o campo totalizado
	If lCmpTot .And. Empty(cCmpTot)
		Alert("Parâmetro do campo do total inválido")
		Return()
	EndIf

	//Verifica se os campos do MarkBrowse foram passados como parâmetros
	If Len(aCampos) == 0
		Alert("Campos do MarkBrowse inexistentes")
		Return()
	EndIf

	//Verifica se os dados do MarkBrowse foram passados como parâmetros
	If Len(aDados) == 0
		Alert("Dados do MarkBrowse inexistentes")
		Return()
	EndIf

	nX := 0
	cMark := GetMark()
	nTotSel := 0
	nQtdSel := 0
	cAliasBrw := GetNextAlias()
	aRer := {}
	aField := {}

	//Definição do campo MARK
	aAdd( aField, { "MARK"		, "C", 002, 0, "Mark",, .F., "" } )

	//Definição dos campos conforme parâmetro
	For nX:=1 To Len(aCampos)
		aAdd(aField, aCampos[nX])
	Next nX

	aObjects := {}
	AAdd( aObjects, { 100, 30, .T., .F., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T., .F. } )
	aSize := MsAdvSize( .T. ) //Parametros verifica se exist enchoice

	//Cria Arquivo Temporário
	oTempTable := FWTemporaryTable():New( cAliasBrw )

	//Seta os campos
	oTemptable:SetFields( aField )

	//Cria a tabela temporária
	oTempTable:Create()

	//Ajusta as colunas para o FWMarkBrowse
	aColumn := FGetColumn( aField )

	//Alimenta a tabela temporária do FWMarkBrose
	CrgMarkB(@cAliasBrw, aCampos, aDados)

	Define MsDialog oDlgBrw FROM aSize[7],00 To aSize[6],aSize[5] Title "MarkBrowse" Pixel

	// Cria o conteiner onde serão colocados os paineis
	oTela     := FWFormContainer():New( oDlgBrw )
	cIdTela	  := oTela:CreateHorizontalBox( 10 )
	cIdRod	  := oTela:CreateHorizontalBox( 80 )

	oTela:Activate( oDlgBrw, .F. )

	//Cria os paineis onde serao colocados os browses
	oPanelUp  	:= oTela:GeTPanel( cIdTela )
	oPanelDown  := oTela:GeTPanel( cIdRod )

	oBrowse := FWMarkBrowse():New()
	oBrowse:SetColumns( aColumn )
	oBrowse:SetOwner( oPanelDown )
	oBrowse:SetDataTable()
	oBrowse:SetAlias( cAliasBrw )
	oBrowse:SetDescription("MarkBrowse")
	oBrowse:SetMenuDef( "" )
	oBrowse:SetWalkThru( .F. )
	oBrowse:SetAmbiente( .F. )
	oBrowse:DisableReport()
	oBrowse:DisableConfig()
	oBrowse:DisableFilter()
	oBrowse:SetFieldMark( "MARK" )
	oBrowse:SetAllMark( { || FMarkAll( oBrowse, aDados, lCmpTot, cCmpTot ) } )
	oBrowse:bMark := {|| FMArkOne(oBrowse, aDados, lCmpTot, cCmpTot )}

	oBrowse:Activate()

	//Quantidade Selecionado
	@ oPanelUp:nTop + 02, oPanelUp:nLeft + 10 	SAY   "Marcados:" SIZE 038,007 OF oPanelUp PIXEL
	@ oPanelUp:nTop + 10, oPanelUp:nLeft + 10	MSGET oQtdSel Var nQtdSel SIZE 080,015	OF oPanelUp PIXEL WHEN .F. PICTURE "@E 999,999,999" HASBUTTON

	//Verifica se existe o campo de Total
	If lCmpTot
		//Total Selecionado
		@ oPanelUp:nTop + 02, oPanelUp:nLeft + 110	SAY   "Total Selecionado:" SIZE 038,007 OF oPanelUp PIXEL
		@ oPanelUp:nTop + 10, oPanelUp:nLeft + 110 	MSGET oTotSel Var nTotSel SIZE 080,015	OF oPanelUp PIXEL WHEN .F. PICTURE "@E 999,999,999.99" HASBUTTON
	EndIf

	//Verifica se já traz o MarkBrowse Selecionado
	If lMarcado
		FMarkAll( oBrowse, aDados, lCmpTot, cCmpTot )
	EndIf

	//ACTIVATE MSDIALOG oDlgBrw CENTERED ON INIT (EnchoiceBar(oDlgBrw,{||FwMsgRun(Nil,{||ExecBlock("TTMARKEX",.F.,.F.,{cAliasBrw}) },Nil,"Aguarde, Atualizando Dados"),oDlgBrw:End()},{||oDlgBrw:End()},,))


	ACTIVATE MSDIALOG oDlgBrw CENTERED ON INIT (EnchoiceBar(oDlgBrw,{||oDlgBrw:End()},{||FwMsgRun(Nil,{|| Aeval(aDados,{|x| x[1]:="" }) },Nil,"Aguarde, Atualizando Dados"),oDlgBrw:End()},,))	
	//ACTIVATE MSDIALOG oDlgBrw CENTERED ON INIT (EnchoiceBar(oDlgBrw,{||oDlgBrw:End()},,),{||FwMsgRun(Nil,{|| Aeval(aDados,{|x| x[1]:="" }) },Nil,"Aguarde, Atualizando Dados"),oDlgBrw:End()})

	//Exclui a tabela temporária
	oTempTable:Delete()

Return(aDados)


/*/{Protheus.doc} FGetColumn
Alteração das colunas do FWMARKBROWSE
@author Felipe Caiado
@since 24/05/2019
@version 1.0
@type Function
/*/
Static Function FGetColumn( aStruct )

	Local cCombo		as character
	Local nPos			as numeric
	Local nI			as numeric
	Local aColumns		as array
	Local aCombo		as array

	cCombo		:=	""
	nPos		:=	0
	nI			:=	0
	aColumns	:=	{}
	aCombo		:=	{}

	//Alimenta array com as colunas
	For nI := 1 to Len( aStruct )
		If aStruct[nI,7]

			nPos ++

			aAdd( aColumns, FWBrwColumn():New() )

			aColumns[nPos]:SetData( &( "{ || " + aStruct[nI,1] + " }" ) )
			aColumns[nPos]:SetTitle( aStruct[nI,5] )
			aColumns[nPos]:SetSize( aStruct[nI,3] )
			aColumns[nPos]:SetDecimal( aStruct[nI,4] )
			aColumns[nPos]:SetPicture( aStruct[nI,6] )
			aColumns[nPos]:SetType( aStruct[nI,2] )
			aColumns[nPos]:SetAlign( Iif( aStruct[nI,2] == "N", 2, 1 ) )

		EndIf
	Next nI

Return( aColumns )

/*/{Protheus.doc} FMarkAll
Inverte a seleção
@author Felipe Caiado
@since 24/05/2019
@version 1.0
@type Function
/*/
Static Function FMarkAll( oBrowse, aDados, lCmpTot, cCmpTot )

	Local cAlias as character
	Local cMark	as character

	cAlias	:=	oBrowse:Alias()
	cMark	:=	oBrowse:Mark()

	lMarkAll	:= .T.

	( cAlias )->( DBGoTop() )

	While ( cAlias )->( !Eof() )

		If RecLock( cAlias, .F. )
			( cAlias )->MARK := Iif( ( cAlias )->MARK == cMark, "  ", cMark )

			// Marca/Desmarca o aDados
			aDados[(cAlias)->(RECNO()),1] := (cAlias)->MARK

			( cAlias )->( MsUnlock() )

			If ( cAlias )->MARK == cMark
				nQtdSel++
			Else
				nQtdSel--
			EndIf

			//Verifica se existe o campo de Total
			If lCmpTot

				If ( cAlias )->MARK == cMark
					nTotSel += ( cAlias )->&(cCmpTot)
				Else
					ntotSel -= ( cAlias )->&(cCmpTot)
				EndIf

			EndIf

		EndIf

		( cAlias )->( DBSkip() )
	EndDo

	( cAlias )->( DBGoTop() )

	//Atualiza o Browse
	oBrowse:Refresh()

	//Atualiza a Quantidade
	oQtdSel:Refresh()

	//Verifica se existe o campo de Total
	If lCmpTot
		//Atualiza o Total
		oTotSel:Refresh()
	EndIf

Return()

/*/{Protheus.doc} FMarkOne
Inverte a seleção
@author Felipe Caiado
@since 24/05/2019
@version 1.0
@type Function
/*/
Static Function FMarkOne( oBrowse, aDados, lCmpTot, cCmpTot )

	Local cAlias as character
	Local cMark	as character

	cAlias	:=	oBrowse:Alias()
	cMark	:=	oBrowse:Mark()

	lMarkAll	:= .T.

	// Marca/Desmarca o aDados
	aDados[(cAlias)->(RECNO()),1] := cMark

	If ( cAlias )->MARK == cMark
		nQtdSel ++
	Else
		nQtdSel --
	EndIf

	//Verifica se existe o campo de Total
	If lCmpTot

		If ( cAlias )->MARK == cMark
			nTotSel += ( cAlias )->&(cCmpTot)
		Else
			ntotSel -= ( cAlias )->&(cCmpTot)
		EndIf

	EndIf

	//Atualiza o Browse
	//oBrowse:Refresh()

	//Atualiza a Quantidade
	oQtdSel:Refresh()

	//Verifica se existe o campo de Total
	If lCmpTot
		//Atualiza o Total
		oTotSel:Refresh()
	EndIf

Return()

//-----------------------------------------------------------
/*/{Protheus.doc} CrgMarkB
Carrega o MArkBrowse
@author Felipe Caiado
@since 24/05/2019
@version 1.0

@type Function
/*/
//-----------------------------------------------------------
Static Function CrgMarkB(cAliasBrw, aCampos, aDados)

	Local nX as numeric
	Local ny as numeric

	nX := 0
	ny := 0

	For nX:=1 To Len(aDados)

		Reclock(cAliasBrw,.T.)
			For nY:=1 To Len(aCampos)
				(cAliasBrw)->&(aCampos[nY][1]) := aDados[nX][nY]
			Next nY
		(cAliasBrw)->(MsUnlock())

	Next nX

Return()
