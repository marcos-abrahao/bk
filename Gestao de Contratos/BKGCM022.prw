#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKGCM022

Cadastro MVC de Tela de Chamado por atendente

@author Rogério O Candisani
@since 
@version 
/*/
//-------------------------------------------------------------------
User Function BKGCM022()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription("Ocorrências") 
oBrw:SetAlias("SZP")

oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rogério O Candisani
@since 
@version 
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local oModel		:= Nil
Local oStruSZP  := FwFormStruct(1,"SZP")
Local oStruSZQ  := FwFormStruct(1,"SZQ")

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("BKGCM022_M", /*bPreValidacao*/,/*bPosValidacao*/,/*bCommit*/,/*bCancel*/ )

// Adiciona ao modelo um componente de formulário
oModel:AddFields("SZPMASTER",/*cOwner*/,oStruSZP, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

//Relacionamento das tabelas
oModel:AddGrid( "SZQDETAIL", "SZPMASTER", oStruSZQ,/*bLinePre*/,,/*bPreVal*/ , , /*bLoad*/)
oModel:SetRelation( "SZQDETAIL", { { "SZQ_FILIAL", "xFilial('SZP')" }, { "SZQ_CONTRAT", "SZP_CONTRAT" }, { "SZQ_SEQ", "SZP_SEQ" } }, SZQ->(IndexKey(1)) )
oModel:SetDescription("Planos de Ação") 

// Adiciona a descrição do Componente do Modelo de Dados
oModel:GetModel("SZPMASTER" ):SetDescription("Ocorrências")

oModel:GetModel('SZQDETAIL'):SetOptional(.T.)
oModel:SetActivate()

// Retorna o Modelo de dados 
Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rogério O Candisani 
@since 
@version 
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oModel   := FwLoadModel("BKGCM022")

// Cria a estrutura a ser usada na View 
Local oStrSZP := FWFormStruct( 2, "SZP"  )
Local oStrSZQ := FWFormStruct( 2, "SZQ"  )

// Interface de visualização construída 
Local oView 

oStrSZQ:SetNoFolder()

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado na View
oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo formulário  
// (antiga Enchoice
oView:AddField( 'VIEW_SZP' , oStrSZP, 'SZPMASTER' )
oView:AddGrid ( 'VIEW_SZQ' , oStrSZQ, 'SZQDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view 
oView:CreateHorizontalBox ( 'SUPERIOR' , 15 )
oView:CreateHorizontalBox ( 'INFERIOR' , 85 )

// Relaciona o identificador (ID) da View com o "box" para exibição 
oView:SetOwnerView( 'VIEW_SZP' , 'SUPERIOR' ) 
oView:SetOwnerView( 'VIEW_SZQ' , 'INFERIOR' )

// Retorna o objeto de View criado
Return(oView)

//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()
MenuDef   

@author Rogério O Candisani 
@since 
@version 
/*/
//----------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE "Planos de Ação" ACTION 'U_VisPlano(SZP->SZP_CONTRAT)' OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"     ACTION "VIEWDEF.BGCM022" OPERATION 2 ACCESS 0

Return(aRotina)

//----------------------------------------------------------
/*/{Protheus.doc} U_ChamAten
Função para os chamados do atendente   

@author Rogério O Candisani 
@since 
@version 
/*/
//----------------------------------------------------------
User Function VisPlano(cContrat)

Local lRetorno := .T. 		// Retorno na rotina.

If !Empty(cContrat)
	
	DbSelectArea("SZQ")
	DbSetOrder(1)
	
	If DbSeek(xFilial("SZQ")+cContrat)
		FWExecView(Upper("Visualizar"),"VIEWDEF.BKGCM022",1,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,/*nPercReducao*/)    // Visualizar
	EndIf
	
Else
	MsgAlert("Selecione uma ocorrência","Atenção") 
EndIf

Return( lRetorno )