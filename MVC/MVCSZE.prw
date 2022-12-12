//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"

//Variveis Estaticas
Static cTitulo := "Anexos de Contratos por Competência"
Static cAliasMVC := "SZE"

/*/{Protheus.doc} User Function MVCSZE
Cadastro de AAnexos de Contratos por Competência
@author Marcos Bispo Abrahao
@since 12/12/2022
@version 1.0
@type function
/*/

User Function MVCSZE()
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
Menu de opcoes na funcao MVCSZE
@author Marcos Bispo Abrahao
@since 05/11/2020
@version 1.0
@type function
/*/

Static Function MenuDef()
	Local aRotina := {}

	//Adicionando opcoes do menu
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.MVCSZE" OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Incluir"    ACTION "VIEWDEF.MVCSZE" OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"    ACTION "VIEWDEF.MVCSZE" OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"    ACTION "VIEWDEF.MVCSZE" OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE "Anexos"     ACTION "u_SZEConh()"    OPERATION 6 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados na funcao MVCSZE
@author Marcos Bispo Abrahao
@since 05/11/2020
@version 1.0
@type function
/*/

Static Function ModelDef()
	Local oStruct := FWFormStruct(1, cAliasMVC)
	Local oModel
	Local bPre := Nil
	Local bPos := Nil
	Local bCommit := Nil
	Local bCancel := Nil


	//Cria o modelo de dados para cadastro
	oModel := MPFormModel():New("MVCSZEM", bPre, bPos, bCommit, bCancel)
	oModel:AddFields("SZEMASTER", /*cOwner*/, oStruct)
	oModel:SetDescription("Modelo de dados - " + cTitulo)
	oModel:GetModel("SZEMASTER"):SetDescription( "Dados de - " + cTitulo)
	oModel:SetPrimaryKey({})
Return oModel

/*/{Protheus.doc} ViewDef
Visualizacao de dados na funcao MVCSZE
@author Marcos Bispo Abrahao
@since 05/11/2020
@version 1.0
@type function
/*/

Static Function ViewDef()
	Local oModel := FWLoadModel("MVCSZE")
	Local oStruct := FWFormStruct(2, cAliasMVC)
	Local oView

	//Cria a visualizacao do cadastro
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("VIEW_SZE", oStruct, "SZEMASTER")
	oView:CreateHorizontalBox("TELA" , 100 )
	oView:SetCloseOnOk({||.T.})
	oView:SetOwnerView("VIEW_SZE", "TELA")

Return oView



// Anexar documentos
User Function SZEConh()
MsDocument("SZE",SZE->(RECNO()),4)
Return Nil
