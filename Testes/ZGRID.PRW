#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'
 
Static cTitle := "Exemplo 2 Grids"
Static cKey    := "FAKE"
Static nTamFake := 15
 
/*/{Protheus.doc} User Function zGrid
Visualizacao de Grupos de Produtos em MVC (com tabela temporaria)
@type  Function
@author Atilio
@since  14/06/2020
@version version
@obs Foi baseado no exemplo de Izac Ciszevski (https://centraldeatendimento.totvs.com/hc/pt-br/articles/360047143634-MP-ADVPL-Criando-uma-tela-MVC-s%C3%B3-com-GRID)
/*/
 
User Function zGrid()
    Local aArea := GetArea()
    Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,"Sair"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}    
    Local aFields1 := {}
    Local aFields2 := {}
    Local oTmpTbl1 As Object
    Local oTmpTbl2 As Object
    Private cAliasTmp1 := "TRB1"
    Private cAliasTmp2 := "TRB2"
 
    //Cria a temporária 1
    oTmpTbl1 := FWTemporaryTable():New(cAliasTmp1)
     
    //Adiciona no array das colunas as que serão incluidas (Nome do Campo, Tipo do Campo, Tamanho, Decimais)
    aFields1 := {}
    aAdd(aFields1, {"XXCODIGO",  "C", TamSX3('BM_GRUPO')[01],   0})
    aAdd(aFields1, {"XXDESCRI",  "C", TamSX3('BM_DESC')[01],    0})
     
    //Define as colunas usadas, adiciona indice e cria a temporaria no banco
    oTmpTbl1:SetFields( aFields1 )
    oTmpTbl1:AddIndex("1", {"XXCODIGO"} )
    oTmpTbl1:Create()
 
    RecLock(cAliasTmp1,.T.)
    (cAliasTmp1)->XXCODIGO := "XXXX"
    (cAliasTmp1)->XXDESCRI := "DESCRI XXXX"
    (cAliasTmp1)->(MsUnLock())

    RecLock(cAliasTmp1,.T.)
    (cAliasTmp1)->XXCODIGO := "XXX1"
    (cAliasTmp1)->XXDESCRI := "DESCRI XXX1"
    (cAliasTmp1)->(MsUnLock())

    RecLock(cAliasTmp1,.T.)
    (cAliasTmp1)->XXCODIGO := "XXX2"
    (cAliasTmp1)->XXDESCRI := "DESCRI XXX2"
    (cAliasTmp1)->(MsUnLock())

    //Cria a temporária 2
    oTmpTbl2 := FWTemporaryTable():New(cAliasTmp2)
     
    //Adiciona no array das colunas as que serão incluidas (Nome do Campo, Tipo do Campo, Tamanho, Decimais)
    aFields2 := {}
    aAdd(aFields2, {"YYCODIGO",  "C", TamSX3('BM_GRUPO')[01],   0})
    aAdd(aFields2, {"YYDESCRI",  "C", TamSX3('BM_DESC')[01],    0})
     
    //Define as colunas usadas, adiciona indice e cria a temporaria no banco
    oTmpTbl2:SetFields( aFields2 )
    oTmpTbl2:AddIndex("1", {"YYCODIGO"} )
    oTmpTbl2:Create()
 
    RecLock(cAliasTmp2,.T.)
    (cAliasTmp2)->YYCODIGO := "YYYY"
    (cAliasTmp2)->YYDESCRI := "DESCRI YYYY"
    (cAliasTmp2)->(MsUnLock())

    //Executa a inclusao na tela
    //FWExecView('GRID Sem Cabeçalho', "VIEWDEF.zGrid", MODEL_OPERATION_INSERT, , { || .T. }, , 30)
    FWExecView('GRID Sem Cabeçalho', "VIEWDEF.zGrid", MODEL_OPERATION_VIEW, , { || .T. }, , ,aButtons )
 
 
    //Deleta a temporaria
    oTmpTbl1:Delete()
    oTmpTbl2:Delete()
     
    RestArea(aArea)
Return
 
Static Function ModelDef()
    Local oModel  As Object
    Local oStrField As Object
    Local oStrGrid1 As Object
    Local oStrGrid2 As Object
 
    //Criamos aqui uma estrutura falsa que sera uma tabela que ficara escondida no cabecalho
    oStrField := FWFormModelStruct():New()
    oStrField:AddTable('' , { 'XXTABKEY' } , cTitle, {|| ''})
    oStrField:AddField('String 01' , 'Campo de texto' , 'XXTABKEY' , 'C' , nTamFake)
 
    //Criamos aqui a estrutura da grid 1
    oStrGrid1 := FWFormModelStruct():New() 
    //oStrGrid:AddTable(cAliasTmp, {'XXTABKEY', 'XXCODIGO', 'XXDESCRI'}, "Temporaria")
    oStrGrid1:AddTable(cAliasTmp1, {'XXCODIGO', 'XXDESCRI'}, "Temporaria")
      
    //Adiciona os campos da estrutura
    oStrGrid1:AddField(;
        "Codigo",;                                                                                  // [01]  C   Titulo do campo
        "Codigo",;                                                                                  // [02]  C   ToolTip do campo
        "XXCODIGO",;                                                                                // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        06,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp1+"->XXCODIGO" ),;                          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStrGrid1:AddField(;
        "Descricao",;                                                                               // [01]  C   Titulo do campo
        "Descricao",;                                                                               // [02]  C   ToolTip do campo
        "XXDESCRI",;                                                                                // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        50,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp1+"->XXDESCRI" ),;                          // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual
 

    //Criamos aqui a estrutura da grid 2
    oStrGrid2 := FWFormModelStruct():New() 
    oStrGrid2:AddTable(cAliasTmp2, {'YYCODIGO', 'YYDESCRI'}, "Temporaria2")
      
    //Adiciona os campos da estrutura
    oStrGrid2:AddField(;
        "Codigo",;                                                                                  // [01]  C   Titulo do campo
        "Codigo",;                                                                                  // [02]  C   ToolTip do campo
        "YYCODIGO",;                                                                                // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        06,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp2+"->YYCODIGO" ),;                          // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual

    oStrGrid2:AddField(;
        "Descricao",;                                                                               // [01]  C   Titulo do campo
        "Descricao",;                                                                               // [02]  C   ToolTip do campo
        "YYDESCRI",;                                                                                // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        50,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp2+"->YYDESCRI" ),;                          // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual


    //Agora criamos o modelo de dados da nossa tela
    oModel := MPFormModel():New('zGridM')
    //oModel:AddFields('CABID', , oStrField)
    oModel:addFields("CABID", /*cOwner*/, oStrField, /*bPre*/, /*bPost*/, {|oMdl| " "})

    oModel:addGrid("GRIDID1", "CABID", oStrGrid1, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oMdl| LoadGrid(oMdl,cAliasTmp1)})
    oModel:addGrid("GRIDID2", "CABID", oStrGrid2, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, {|oMdl| LoadGrid(oMdl,cAliasTmp2)})

    //oModel:AddGrid('GRIDID1', 'CABID', oStrGrid1)
    //oModel:AddGrid('GRIDID2', 'CABID', oStrGrid2)

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
 
    //Criamos agora a estrtutura falsa do cabeçalho na visualização dos dados
    oStrCab := FWFormViewStruct():New()
    oStrCab:AddField('XXTABKEY' , '01' , 'String 01' , 'Campo de texto', , 'C')
 
    //Agora a estrutura da Grid 1
    oStrGrid1 := FWFormViewStruct():New()
  
    //Adicionando campos da estrutura
    oStrGrid1:AddField(;
        "XXCODIGO",;                // [01]  C   Nome do Campo
        "01",;                      // [02]  C   Ordem
        "Codigo",;                  // [03]  C   Titulo do campo
        "Codigo",;                  // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
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

    oStrGrid1:AddField(;
        "XXDESCRI",;                // [01]  C   Nome do Campo
        "02",;                      // [02]  C   Ordem
        "Descricao",;               // [03]  C   Titulo do campo
        "Descricao",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
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



    //Agora a estrutura da Grid 2
    oStrGrid2 := FWFormViewStruct():New()
  
    //Adicionando campos da estrutura
    oStrGrid2:AddField(;
        "YYCODIGO",;                // [01]  C   Nome do Campo
        "01",;                      // [02]  C   Ordem
        "Codigo",;                  // [03]  C   Titulo do campo
        "Codigo",;                  // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
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

    oStrGrid2:AddField(;
        "YYDESCRI",;                // [01]  C   Nome do Campo
        "02",;                      // [02]  C   Ordem
        "Descricao",;               // [03]  C   Titulo do campo
        "Descricao",;               // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
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


    //Carrega o ModelDef
    oModel  := FWLoadModel('zGrid')
 
    //Agora na visualização, carrega o modelo, define o cabeçalho e a grid, e no cabeçalho coloca 0% de visualização, e na grid coloca 100%
    oView := FwFormView():New()
    oView:SetModel(oModel)

    oView:CreateHorizontalBox('FAKE', 0)
    oView:CreateHorizontalBox('PRINCIPAL', 100)
    oView:CreateFolder( 'PASTAS', 'PRINCIPAL' )

    oView:AddSheet( 'PASTAS'    , 'ABA_TRB1'	, "Temporario1")
    oView:AddSheet( 'PASTAS'    , 'ABA_TRB2' 	, "Temporário2")

    oView:AddField('CAB', oStrCab, 'CABID')
    oView:AddGrid('GRID1', oStrGrid1, 'GRIDID1')
    oView:AddGrid('GRID2', oStrGrid2, 'GRIDID2')

    oView:CreateHorizontalBox( 'TRB1',  100, , , 'PASTAS', 'ABA_TRB1' )
    oView:CreateHorizontalBox( 'TRB2',  100, , , 'PASTAS', 'ABA_TRB2' )

    oView:SetOwnerView('CAB'  , 'FAKE')
    oView:SetOwnerView('GRID1', 'TRB1')
    oView:SetOwnerView('GRID2', 'TRB2')

    oView:AddUserButton( 'Exporta Excel', 'CLIPS', { |oView| u_zGrdExc(oView) } )

    oView:SetDescription(cTitle)
Return oView


User Function zGrdExc(oView)
Local aInfo

aInfo := oView:GetFolderActive("PASTAS", 2)
If !Empty(aInfo)
   Alert( "FOLDER - Aba Ativa: "   + aInfo[2] )
EndIf

Return Nil



//-------------------------------------------------------------------
/*/{Protheus.doc} loadGrid
Função estática para efetuar o load dos dados do grid

@param oModel - Objeto do modelo de dados

@return aData - Array com os dados para exibição no grid

@author Daniel Mendes
@since 10/07/2020
@version 1.0
/*/
//-------------------------------------------------------------------
static function LoadGrid(oModel,cAlias)
local aData as array
//local cAlias as char
local cWorkArea as char
//local cTablename as char

cWorkArea := Alias()
//cAlias := GetNextAlias()
//cTablename := "%" + RetSqlName(MVC_ALIAS) + "%"

//BeginSql Alias cAlias
//    SELECT *, R_E_C_N_O_ RECNO
//      FROM %exp:cTablename%
//    WHERE D_E_L_E_T_ = ' '
//EndSql

aData := FwLoadByAlias(oModel, cAlias) //, MVC_ALIAS, "RECNO", /*lCopy*/, .T.)

(cAlias)->(DBCloseArea())

if !Empty(cWorkArea) .And. Select(cWorkArea) > 0
    DBSelectArea(cWorkArea)
endif

return aData
