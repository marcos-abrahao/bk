#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'
 
//Static 
Static cKey     := "FAKE"
Static nTamFake := 15


/*/{Protheus.doc} User Function zGrid
Visualizacao de Grupos de Produtos em MVC (com tabela temporaria)
@type  Function
@author Atilio
@since  14/06/2020
@version version
@obs Foi baseado no exemplo de Izac Ciszevski (https://centraldeatendimento.totvs.com/hc/pt-br/articles/360047143634-MP-ADVPL-Criando-uma-tela-MVC-s%C3%B3-com-GRID)
/*/
 
User Function BKGCTM14()
    Local aArea         := GetArea()
    Local aButtons      := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Sair"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}    
    Private cAliasTmp1  := "TRB2"
    Private cAliasTmp2  := "TRB3"
    Private cTitle      := aTitulos1[1]
 
    //Executa a inclusao na tela
    //FWExecView('GRID Sem Cabeçalho', "VIEWDEF.zGrid", MODEL_OPERATION_INSERT, , { || .T. }, , 30)
    FWExecView(cTitle, "VIEWDEF.BKGCTM14", MODEL_OPERATION_VIEW, , { || .T. }, , ,aButtons )
     
    RestArea(aArea)
Return
 
Static Function ModelDef()
    Local oModel    As Object
    Local oStrField As Object
    Local oStrGrid1 As Object
    Local oStrGrid2 As Object
    Local nS        := 0
    Local aCpos     := {}
 
    //Criamos aqui uma estrutura falsa que sera uma tabela que ficara escondida no cabecalho
    oStrField := FWFormModelStruct():New()
    oStrField:AddTable('' , { 'XXTABKEY' } , ":" /*cTitle*/, {|| ''})
    oStrField:AddField('String 01' , 'Campo de texto' , 'XXTABKEY' , 'C' , nTamFake)
 
    //Criamos aqui a estrutura da grid 1
    oStrGrid1 := FWFormModelStruct():New() 
    //oStrGrid:AddTable(cAliasTmp, {'XXTABKEY', 'XXCODIGO', 'XXDESCRI'}, "Temporaria")
    aCpos := {}
    For nS := 1 to Len(aDbf2)
        aAdd(aCpos,aDbf2[nS,1])
    Next
    //oStrGrid1:AddTable(cAliasTmp1, {'XXCODIGO', 'XXDESCRI'}, "Temporaria")
    oStrGrid1:AddTable(cAliasTmp1, aCpos, "Sintético")
      
    //Adiciona os campos da estrutura da Grid 1
    For nS := 1 to Len(aDbf2)

        oStrGrid1:AddField(;
            aCabs2[nS],;                                                                                 // [01]  C   Titulo do campo
            aCabs2[nS],;                                                                                 // [02]  C   ToolTip do campo
            aDbf2[nS,1],;                                                                                // [03]  C   Id do Field
            aDbf2[nS,2],;                                                                                // [04]  C   Tipo do campo
            aDbf2[nS,3],;                                                                                // [05]  N   Tamanho do campo
            aDbf2[nS,4],;                                                                                // [06]  N   Decimal do campo
            Nil,;                                                                                       // [07]  B   Code-block de validação do campo
            Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
            {},;                                                                                        // [09]  A   Lista de valores permitido do campo
            .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
            FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp1+"->"+aDbf2[nS,1] ),;                          // [11]  B   Code-block de inicializacao do campo
            .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
            .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
            .F.)                                                                                        // [14]  L   Indica se o campo é virtual
 
    Next

    //Criamos aqui a estrutura da grid 2
    oStrGrid2 := FWFormModelStruct():New() 
    aCpos := {}
    For nS := 1 to Len(aDbf3)
        aAdd(aCpos,aDbf3[nS,1])
    Next
    oStrGrid2:AddTable(cAliasTmp2, aCpos, "Demonstrativo de Rentabilidades")
      
    //Adiciona os campos da estrutura da Grid 2
    For nS := 1 to Len(aDbf3)

        oStrGrid2:AddField(;
            aCabs3[nS],;                                                                                // [01]  C   Titulo do campo
            aCabs3[nS],;                                                                                // [02]  C   ToolTip do campo
            aDbf3[nS,1],;                                                                               // [03]  C   Id do Field
            aDbf3[nS,2],;                                                                               // [04]  C   Tipo do campo
            aDbf3[nS,3],;                                                                               // [05]  N   Tamanho do campo
            aDbf3[nS,4],;                                                                               // [06]  N   Decimal do campo
            Nil,;                                                                                       // [07]  B   Code-block de validação do campo
            Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
            {},;                                                                                        // [09]  A   Lista de valores permitido do campo
            .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
            FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp2+"->"+aDbf3[nS,1] ),;                          // [11]  B   Code-block de inicializacao do campo
            .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
            .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
            .F.)                                                                                        // [14]  L   Indica se o campo é virtual
 
    Next

    //Agora criamos o modelo de dados da nossa tela
    oModel := MPFormModel():New('GCTM14M')
    
    oModel:addFields("CABID", /*cOwner*/, oStrField, /*bPre*/, /*bPost*/, {|oMdl| " "})

    oModel:addGrid("GRIDID1", "CABID", oStrGrid1, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oMdl| LoadGrid(oMdl,cAliasTmp1)})
    oModel:addGrid("GRIDID2", "CABID", oStrGrid2, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oMdl| LoadGrid(oMdl,cAliasTmp2)})


    //oModel:SetRelation('GRIDID1', { { 'XXTABKEY', 'XXTABKEY' } })
    //oModel:SetRelation('GRIDID2', { { 'XXTABKEY', 'XXTABKEY' } })

    oModel:SetDescription(cTitle)
    //oModel:SetPrimaryKey({ 'XXTABKEY' })
 
    //Ao ativar o modelo, irá alterar o campo do cabeçalho mandando o conteúdo FAKE pois é necessário alteração no cabeçalho
    //oModel:SetActivate({ | oModel | FwFldPut("XXTABKEY", cKey) })
Return oModel
 
Static Function ViewDef()
    Local oView     As Object
    Local oModel    As Object
    Local oStrCab   As Object
    Local oStrGrid1 As Object
    Local oStrGrid2 As Object
    Local nS        As Numeric

    //Criamos agora a estrtutura falsa do cabeçalho na visualização dos dados
    oStrCab := FWFormViewStruct():New()
    oStrCab:AddField('XXTABKEY' , '01' , 'String 01' , 'Campo de texto', , 'C')
 
    //Agora a estrutura da Grid 1
    oStrGrid1 := FWFormViewStruct():New()
  
    //Adicionando campos da estrutura da grid 1
    For nS := 1 to Len(aDbf2)
        oStrGrid1:AddField(;
            aDbf2[nS,1],;               // [01]  C   Nome do Campo
            STRZERO(nS,2),;             // [02]  C   Ordem
            aCabs2[nS],;                // [03]  C   Titulo do campo
            aCabs2[nS],;                // [04]  C   Descricao do campo
            Nil,;                       // [05]  A   Array com Help
            aDbf2[nS,2],;               // [06]  C   Tipo do campo
            aPict2[nS],;                // [07]  C   Picture
            Nil,;                       // [08]  B   Bloco de PictTre Var
            Nil,;                       // [09]  C   Consulta F3
            .F.,;                       // [10]  L   Indica se o campo é alteravel
            Nil,;                       // [11]  C   Pasta do campo
            Nil,;                       // [12]  C   Agrupamento do campo
            Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
            Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
            Nil,;                       // [15]  C   Inicializador de Browse
            Nil,;                       // [16]  L   Indica se o campo é virtual
            Nil,;                       // [17]  C   Picture Variavel
            Nil)                        // [18]  L   Indica pulo de linha após o campo
    Next

    //Agora a estrutura da Grid 2
    oStrGrid2 := FWFormViewStruct():New()
  
    //Adicionando campos da estrutura
    For nS := 1 to Len(aDbf3)
        oStrGrid2:AddField(;
            aDbf3[nS,1],;               // [01]  C   Nome do Campo
            STRZERO(nS,2),;             // [02]  C   Ordem
            aCabs3[nS],;                // [03]  C   Titulo do campo
            aCabs3[nS],;                // [04]  C   Descricao do campo
            Nil,;                       // [05]  A   Array com Help
            aDbf3[nS,2],;               // [06]  C   Tipo do campo
            aPict3[nS],;                // [07]  C   Picture
            Nil,;                       // [08]  B   Bloco de PictTre Var
            Nil,;                       // [09]  C   Consulta F3
            .F.,;                       // [10]  L   Indica se o campo é alteravel
            Nil,;                       // [11]  C   Pasta do campo
            Nil,;                       // [12]  C   Agrupamento do campo
            Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
            Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
            Nil,;                       // [15]  C   Inicializador de Browse
            Nil,;                       // [16]  L   Indica se o campo é virtual
            Nil,;                       // [17]  C   Picture Variavel
            Nil)                        // [18]  L   Indica pulo de linha após o campo
    Next

    //Carrega o ModelDef
    oModel  := FWLoadModel('BKGCTM14')
 
    //Agora na visualização, carrega o modelo, define o cabeçalho e a grid, e no cabeçalho coloca 0% de visualização, e na grid coloca 100%
    oView := FwFormView():New()
    oView:SetModel(oModel)

    oView:CreateHorizontalBox('FAKE', 0)
    oView:CreateHorizontalBox('PRINCIPAL', 100)
    oView:CreateFolder( 'PASTAS', 'PRINCIPAL' )

    oView:AddSheet( 'PASTAS'    , 'ABA_TRB2'	, "Sintético")
    oView:AddSheet( 'PASTAS'    , 'ABA_TRB3' 	, "Demonstrativo de Rentabilidades")

    oView:AddField('CAB', oStrCab, 'CABID')
    oView:AddGrid('GRID1', oStrGrid1, 'GRIDID1')
    oView:AddGrid('GRID2', oStrGrid2, 'GRIDID2')

    oView:CreateHorizontalBox( 'TRB2',  100, , , 'PASTAS', 'ABA_TRB2' )
    oView:CreateHorizontalBox( 'TRB3',  100, , , 'PASTAS', 'ABA_TRB3' )

    oView:SetOwnerView('CAB'  , 'FAKE')
    oView:SetOwnerView('GRID1', 'TRB2')
    oView:SetOwnerView('GRID2', 'TRB3')

    oView:AddUserButton( 'Exporta Excel', 'CLIPS', { |oView| u_GM14Exc(oView) } )

    oView:SetDescription(cTitle)
Return oView


Static Function LoadGrid(oModel,cAlias)
local aData as array
local cWorkArea as char

cWorkArea := Alias()

aData := FwLoadByAlias(oModel, cAlias) //, MVC_ALIAS, "RECNO", /*lCopy*/, .T.)

//(cAlias)->(DBCloseArea())

if !Empty(cWorkArea) .And. Select(cWorkArea) > 0
    DBSelectArea(cWorkArea)
endif

return aData



User Function GM14Exc(oView)
//Local aInfo

//aInfo := oView:GetFolderActive("PASTAS", 2)
//If !Empty(aInfo)
//   Alert( "FOLDER - Aba Ativa: "   + aInfo[2] )
//EndIf

U_CR14(lJob)

Return Nil
