#Include "Protheus.ch"
#Include "Parmtype.ch"
#Include "FWMVCDEF.CH"
#Include "FWTABLEATTACH.CH"
#Include "TopConn.ch"
/*/{Protheus.doc} FCTBMVC3)
@version 12.1.17
@type function
/*/
User Function FCTBMVC3()
	
	Local l_Cont	:= .F.
	Local aButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.F.,"Salvar"},{.T.,"Cancelar"},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}}
	
	FWMsgRun(, {|oSay| VerTrack(@l_Cont) }, "Processando", "Verificando contabilizacao...")
	If( l_Cont )
		Processa({|| CursorWait(), FWExecView( "Track contabil" , "FCTBMVC3", MODEL_OPERATION_VIEW, , { || .T. } ,{|| .T. } , ,aButtons ), CursorArrow() }, "Aguarde! Processando Track contabil...")
	EndIf
	
Return( Nil )
/*/{Protheus.doc} ModelDef
@version 12.1.17
@type function
/*/
Static Function ModelDef()
	//Criacao do objeto do modelo de dados
	Local oModel := Nil

	//Criacao da estrutura de dados utilizada na interface
	Local oStrCab := FWFormStruct(1, "SE5", { |x| AllTrim( x ) $ "E5_FILIAL, E5_IDMOVI, E5_DATA, E5_VALOR " } , .F. )
	Local oStrGri := FWFormStruct(1, "CT2", { |x| AllTrim( x ) $ "CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DC, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_HIST, CT2_ITEMC, CT2_CCC, CT2_ITEMD, CT2_CCD, CT2_ORIGEM, CT2_ROTINA, CT2_LP, CT2_KEY" } , .F. )

	//Instanciando o modelo, nao e recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("FCTBMVE")

	//Atribuindo formularios para o modelo
	oModel:AddFields("CABEC",/*cOwner*/,oStrCab, /*bPre*/ ,/* < bPost >*/, /*< bLoad >*/)

	//Adicionando ao modelo um componente de grid.
	oModel:AddGrid( 'GRID', 'CABEC', oStrGri)

	//Adicionando relacionamento entre MASTER E DETALHE
	oModel:SetRelation( 'GRID', { {'CT2_LOTE', "'DIS003'"}, {'CT2_ROTINA', "'FCTBA004'"}, { 'Substring(CT2_KEY,1,18)', 'xFilial("SE5")+E5_IDMOVI' } }, CT2->( IndexKey( 1 ) ) )

	//Setando a chave primaria da rotina
	oModel:SetPrimaryKey({'E5_FILIAL','E5_IDMOVI'})

	//Validacao de linha duplicada
	oModel:GetModel( 'GRID' ):SetUniqueLine( { 'CT2_DATA', 'CT2_LOTE', 'CT2_ROTINA', 'CT2_KEY' } )

	//Adicionando descricao ao modelo
	oModel:SetDescription( Capital( UsrFullName( RetCodUsr() ) ) )

	//Setando a descricao do formulario
	oModel:GetModel("CABEC"):SetDescription("Cabecalho")
	oModel:GetModel("GRID"):SetDescription("Detalhe")	 
Return( oModel ) 
/*/{Protheus.doc} ViewDef
@version 12.1.17
@type function
/*/
Static Function ViewDef()
	//Criacao do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("FCTBMVC3")

	//Criacao da estrutura de dados utilizada na interface do cadastro de etiquetas - cabecalho
	Local oStrCab := FWFormStruct(2, "SE5", { |x| AllTrim( x ) $ "E5_FILIAL, E5_IDMOVI, E5_DATA, E5_VALOR " } , .F. )
	Local oStrGri := FWFormStruct(2, "CT2", { |x| AllTrim( x ) $ "CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DC, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_HIST, CT2_ITEMC, CT2_CCC, CT2_ITEMD, CT2_CCD, CT2_ORIGEM, CT2_ROTINA, CT2_LP, CT2_KEY" } , .F. )

	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que sera o retorno da funcao e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formul�rios para interface
	oView:AddField("VIEW_CABEC", oStrCab, "CABEC")

	//Adicionamos na interface (View) um controle do tipo grid (antiga GetDados), para isso usamos o m�todo AddGrid.
	oView:AddGrid( 'VIEW_GRID', oStrGri, "GRID" )

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",15)
	oView:CreateHorizontalBox("DETALHE",85)

	//O formulario da interface sera colocado dentro do container
	oView:SetOwnerView( 'VIEW_CABEC', 'TELA' )
	oView:SetOwnerView( 'VIEW_GRID', 'DETALHE' )
	
	//Habilitando titulo
	oView:EnableTitleView('VIEW_CABEC','Financeiro - Movimento Bancario - Pagar')
	oView:EnableTitleView('VIEW_GRID','Lancamentos na Contabilidade')
Return( oView )
/*/{Protheus.doc} VerTrack
@version 12.1.17
@type function
/*/
Static Function VerTrack(l_Cont)
	Local c_Fils	:= ""
	Local a_Fils	:= {}
	Local cQryCT2   := ""
	Local n_Pos		:= 0
	Local a_Area	:= SE5->( GetArea() )
		
	cQryCT2 := "SELECT CT2_KEY, CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, CT2_DC, CT2_DEBITO, CT2_CREDIT, CT2_VALOR, CT2_HIST, CT2_ITEMC, CT2_ITEMD, CT2_CCC, CT2_CCD, CT2_ORIGEM, CT2_ROTINA , CT2_LP, CT2_SEQHIS, CT2_SEQLAN, R_E_C_N_O_" + chr(13)+chr(10)
	cQryCT2 += "FROM " + RetSQLName("CT2") +" with (nolock) "+chr(13)+chr(10)
	cQryCT2 += "WHERE D_E_L_E_T_ = '' " +chr(13)+chr(10)
	cQryCT2 += "AND CT2_DATA	= '" + Dtos(SE5->E5_DATA) + "'" +chr(13)+chr(10)
	cQryCT2 += "AND SUBSTRING(CT2_KEY,1,18) = '" + SE5->E5_FILIAL+SE5->E5_IDMOVI + "'" +chr(13)+chr(10)
	TCQUERY cQryCT2 ALIAS QRY NEW
	
	If (QRY->(Eof()))
		MsgAlert("Nao ha dados para serem exibidos.","Aviso")
		l_Cont:= .F.
	Else
		l_Cont:= .T.
	EndIf
	DbSelectArea("QRY")
	QRY->( DbCloseArea() )
	RestArea( a_Area )
Return()
