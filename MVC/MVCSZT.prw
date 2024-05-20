//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"

//Variveis Estaticas
Static cTitulo := "Facilitador de Docs de Entrada e Pré Notas"
Static cAliasMVC := "SZT"

/*/{Protheus.doc} User Function MVCSZT
Facilitador de Docs de Entrada e Pré Notas
@author Marcos Bispo Abrahao
@since 11/04/2024
@version 1.0
@type function
/*/

User Function MVCSZT()
	Local aArea   := GetArea()
	Local oBrowse
	Private aRotina := {}

	//Definicao do menu
	aRotina := MenuDef()

	//Instanciando o browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(cAliasMVC)
	oBrowse:SetDescription(cTitulo)
	oBrowse:DisableDetails()

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
Menu de opcoes na funcao MVCSZT
@author Marcos Bispo Abrahao
@since 11/04/2024
@version 1.0
@type function
/*/

Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.MVCSZT" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.MVCSZT" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.MVCSZT" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.MVCSZT" OPERATION 5 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao MVCSZT
@author Marcos Bispo Abrahao
@since 11/04/2024
@version 1.0
@type function
/*/

Static Function ModelDef()
	Local oStruct := FWFormStruct(1, cAliasMVC)
	Local oModel
	Local bPre := Nil
	Local bPos := Nil
	//Local bCommit := Nil
	Local bCancel := Nil


	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("MVCSZTM", bPre, bPos, /*bCommit*/, bCancel)
	oModel:AddFields("SZTMASTER", /*cOwner*/, oStruct)
	oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel("SZTMASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:SetPrimaryKey({})
Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao MVCSZT
@author Marcos Bispo Abrahao
@since 11/04/2024
@version 1.0
@type function
/*/

Static Function ViewDef()
	Local oModel := FWLoadModel("MVCSZT")
	Local oStruct := FWFormStruct(2, cAliasMVC)
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_SZT", oStruct, "SZTMASTER")
	oView:CreateHorizontalBox("TELA" , 100 )
	oView:SetCloseOnOk({||.T.})
	oView:SetOwnerView("VIEW_SZT", "TELA")

Return oView


User Function SZTLeg()
	Local aLegenda := {}
	
	//Monta as cores
	AADD(aLegenda,{"BR_VERDE",		"Uso permitido"  })
	AADD(aLegenda,{"BR_VERMELHO",	"Uso não permitido"})
	
	BrwLegenda(cTitulo, "Status", aLegenda)
Return
