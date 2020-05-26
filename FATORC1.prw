
#include "Protheus.Ch"
#include "MSOle.Ch"

#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#include "TopConn.ch"

#define oleWdFormatDocument "0"
#define oleWdFormatHTML "102"
#define oleWdFormatPDF "17"

User Function FATORC1()

	Local nOpc := 0

	Private cCadastro := "IntegraÁ„oo Protheus com Ms-Word"
	Private aSay := {}
	Private aButton := {}

	aAdd( aSay, "Esta rotina efetua a impress„o da Nota Fiscal de Venda(Saida) conforme parametros informados." )

	aAdd( aButton, { 1,.T.,{|| nOpc := 1,FechaBatch()}})
	aAdd( aButton, { 2,.T.,{|| FechaBatch() }} )

	FormBatch( cCadastro, aSay, aButton )

	If nOpc == 1
		Processa( {|| ImpWord() }, cCadastro, "Processando..." )
	Endif
Return



//////////////////////////////////////////////////////////////////////////////////////////
//+------------------------------------------------------------------------------------+//
//| PROGRAMA  | AP_Word.prw          | AUTOR |  | DATA |  |//
//+------------------------------------------------------------------------------------+//
//| DESCRICAO | Funcao - ImpWord()                                                     |//
//|           | Fonte utilizado no curso oficina de programacao.                       |//
//|           | Funcao que descarrega as variaveis nas variaveis do word               |//
//+------------------------------------------------------------------------------------+//
//////////////////////////////////////////////////////////////////////////////////////////
Static Function ImpWord()
	Local oWord := Nil
	Local cFileOpen := ""
	Local cFileSave := ""
	local cMainPath := "c:\" //Local onde ser salvo o modelo em Word
	Local cPedido := ""
	Local cCond := ""
	Local cSerie := ""
	Local cPICTURE := "@E 99,999,999.99"
	Local aPARAM := {}
	Local aRET := {}
	Local aSD2 := {}
	Local nTOTAL := 0
	Local cChave := 0
	Local nI := 0
	Local aAreaAnt := GetArea()
	Local nSaida := 0
	Local aSaida := {'1-Imprimir','2-Salvar formato DOC','3-Salvar formato PDF','4-Salvar formato HTML','5-Nenhum'}

	// aAdd( aPARAM, { 1, "N¬∫ Pedido de venda" , Space(6) , ""    , "", "SC5", "" , 0  , .T. })
	/// aAdd( aPARAM, { 1, "N¬∫ Nota fiscal" ,  , ""    , "", "SF2", "" , 0  , .T. })
	//aAdd( aPARAM, { 1, "SÈrie" , Space(3) , ""    , "", , "" , 0  , .T. })
	//aAdd( aPARAM, { 1, "SÈrie" , Space(3) , ""    , "", , "" , 0  , .T. })
	//	aAdd( aPARAM, { 3, "Arquivo Modelo Word", Space(50), ""    , "", ""   , 50 , .T., "Modelo MS-Word |*.dot", cMainPath })
	//aAdd( aPARAM, { 2, "Qual sa√≠da"         , 1        , aSaida, 80, ""   , .F.})

	aAdd(aPARAM, {1, "N∫ Nota fiscal" , criaVar("F2_DOC", .F.),,,"SF2",,50,.F.})
	aAdd(aPARAM, {1, "SÈrie"    , criaVar("F2_SERIE", .F.),,,     ,,50,.F.})
	aAdd( aPARAM, { 6, "Arquivo Modelo Word", Space(50), ""    , "", ""   , 50 , .T., "Modelo MS-Word |*.dot", cMainPath })
	aAdd( aPARAM, { 2, "Qual saÌda"         , 1        , aSaida, 80, ""   , .F.})

	If !ParamBox(aPARAM,"Par√¢metros",@aRET)
		Return
	Endif

	cFileOpen := aRET[3]

	If !File(cFileOpen)
		MsgInfo("Arquivo n„o localizado",cCadastro)
		Return
	Endif



	cPedido := aRET[1]
	cSerie := aRET[2]

 	dbSelectArea("SF2")
	dbSetOrder(1)
   	IF !dbSeek(xFilial("SF2") + cPedido + cSerie)
        MsgInfo("Nota Fiscal n„o encontrado",cCadastro)
        Return(.F.)
    Endif

	//nSaida := Val(Left(aRET[3],1))
	cCond := Posicione("SE4",1,xFilial("SE4")+SF2->F2_COND,"E4_DESCRI")

	//Cadastro do Cliente  + Tabela CabeÁalho das NotasFiscaisSaida SF2 //
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek( xFilial("SA1") + SF2->( F2_CLIENTE + F2_LOJA) )

	//ITENS DA NOTA FISCAL DE SAIDA (SD2) e SF2 NOTA FISCAL CABE«ALHO ///

	dbSelectArea("SD2")
	dbSetOrder(3)
	dbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE),.F.)

	nTOTAL := 0


	While !EOF() .And. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE)

		nTOTAL += SD2->D2_TOTAL
		aAdd( aSD2, {SD2->D2_ITEM,;
			Alltrim(Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")), ;
			SD2->D2_QUANT, ;
			SD2->D2_PRCVEN, ;
			SD2->D2_TOTAL} )
		SD2->(dbSkip())

	Enddo


    cChave := 0

	If !Empty(SF2->F2_DUPL)

 		dbSelectArea("SE1")
        dbSetOrder(1)

		If dbSeek(xFilial("SE1")+SF2->F2_DUPL,.F.)
      
	     	cChave := SE1->(E1_FILIAL+E1_NUM+E1_PARCELA)
              
			While ! Eof() .And. SE1->(E1_FILIAL+E1_NUM+E1_PARCELA) == (cChave)
        
		          			aAdd(aSE1,{SE1->E1_PREFIXO,;
					 			SE1->E1_NUM,;
								SE1->E1_PARCELA,;
					  			SE1->E1_VALOR,;
					 			SE1->E1_VENCTO})
     	  					SE1->(dbSkip())
			Enddo
		EndIf


	

	ENDIF
	
	// Criar o link do Protheus com o Word.
	oWord := OLE_CreateLink()

	// Cria um novo baseado no modelo.
	OLE_NewFile( oWord, cFileOpen )

	// Exibe ou oculta a janela da aplicacao Word no momento em que estiver descarregando os valores.
	OLE_SetProperty( oWord, oleWdVisible, .F. )

	// Exibe ou oculta a aplicacao Word.
	OLE_SetProperty( oWord, oleWdWindowState, '1' )

	// ATRIBUI OS VALORES AS  VARIAVEIS DA NOTA FISCAL DE SAIDA E DO ITEM DA NF DE VENDA SAIDA //

    OLE_SetDocumentVar( oWord, 'w_C5_NUM'    , SF2->F2_DOC )
	OLE_SetDocumentVar( oWord, 'w_C5_EMISSAO', Dtoc(SF2->F2_EMISSAO) )
	OLE_SetDocumentVar( oWord, 'w_C5_CONDPAG', cCond )
	OLE_SetDocumentVar( oWord, 'w_C5_CLIENTE', SA1->A1_COD+"-"+SA1->A1_LOJA+"/"+SA1->A1_NOME )
	OLE_SetDocumentVar( oWord, 'w_VlrTotal'  , LTrim(TransForm(nTOTAL,cPICTURE)) )
    OLE_SetDocumentVar( oWord, 'w_NumItens'  , SD2->D2_ITEM)
	OLE_SetDocumentVar( oWord, 'w_C6_PRODUTO', SD2->D2_COD )
	OLE_SetDocumentVar( oWord, 'w_C6_QTDE'   , SD2->D2_QUANT)
	OLE_SetDocumentVar( oWord, 'w_C6_UNIT'   , LTrim(Transform(SD2->D2_PRCVEN,cPICTURE)))
	OLE_SetDocumentVar( oWord, 'w_C6_TOTAL'  , LTrim(Transform(SD2->D2_TOTAL,cPICTURE)))
	OLE_SetDocumentVar( oWord, 'w_C6_VENCIMENTO',Dtoc(SE1->E1_VENCTO))
    OLE_SetDocumentVar( oWord, 'w_C6_PARCELA'  ,LTrim(Transform(SE1->E1_PARCELA,cPICTURE)))


		For nI := 1 To Len( aSD2 )
		OLE_SetDocumentVar( oWord, 'w_C6_ITEM'   , aSD2[nI,1] )
		OLE_SetDocumentVar( oWord, 'w_C6_PRODUTO', aSD2[nI,2] )
		OLE_SetDocumentVar( oWord, 'w_C6_QTDE'   , aSD2[nI,3] )
		OLE_SetDocumentVar( oWord, 'w_C6_UNIT'   , aSD2[nI,4] )
		OLE_SetDocumentVar( oWord, 'w_C6_TOTAL'  , aSD2[nI,5] )
		Next nI

		For nI := 1 To Len( aSE1 )

	   		OLE_SetDocumentVar( oWord, 'w_C6_PREFIXO'    , aSE1[nI,1] )
			OLE_SetDocumentVar( oWord, 'w_C6_NUMERO'     , aSE1[nI,2] )
			OLE_SetDocumentVar( oWord, 'w_C6_PARCELA'    , aSE1[nI,3] )
			OLE_SetDocumentVar( oWord, 'w_C6_VALOR'      , aSE1[nI,4] )
			OLE_SetDocumentVar( oWord, 'w_C6_VENCIMENTO' , aSE1[nI,5] )
		Next nI

	// Executa a macro do Word.
	OLE_ExecuteMacro( oWord , "PedidoVenda" )

	// Atualiza todos os campos.
	OLE_UpDateFields( oWord )

		If nSaida <> 5
			If nSaida == 1
			// 1-Imprimir
			// Ativa ou desativa impressao em segundo plano. (opcional)
			OLE_SetProperty( oWord, oleWdPrintBack, .F. )
			//Caso fosse parcial a impress√£o informar o intervalo e trocar ALL por PART.
			OLE_PrintFile( oWord, 'ALL', , ,  )
			// Esperar 2 segundos para imprimir.
			Sleep( 2000 )
			Else
			cFileSave := SubStr(cFileOpen,1,At(".",Trim(cFileOpen))-1)
				If nSaida == 2
				// 2-Salvar formato DOC
				OLE_SaveAsFile( oWord, cFileSave+SF2->F2_DOC+"_protheus.doc" )
				Else
				OLE_SaveAsFile( oWord, cFileSave+SF2->F2_DOC+"_protheus.doc",'','',.F.,oleWdFormatDocument )
				Sleep(1000)
				OLE_OpenFile( oWord, cFileSave+SF2->F2_DOC+"_protheus.doc" )
				Sleep(1000)
					If nSaida == 3
					// 3-Salvar formato PDF
					OLE_SaveAsFile( oWord, cFileSave+SF2->F2_DOC+"_protheus.pdf",'','',.F.,oleWdFormatPDF )
					Else
					// 4-Salvar formado HTML
					OLE_SaveAsFile( oWord, cFileSave+SF2->F2_DOC+"_protheus.htm",'','',.F.,oleWdFormatHTML )
					Endif
				Endif
			// Fecha o documento.
			OLE_CloseFile( oWord )
			Endif
		Endif
	// Fechar o link com a aplica√ß√£o.
	OLE_CloseLink( oWord, .F. )

	RestArea(aAreaAnt)
Return

*/

//+-----------------------------------------------------------------
//+-----------------------------------------------------------------
//| Descritivo de cada fun√ß√£o para integrar o Protheus com o Ms-Word
//+-----------------------------------------------------------------
//+-----------------------------------------------------------------
/*

- Funcao que abre o Link com o Word tendo como parametro a versao
  oWord := OLE_CreateLink( "TMSOLEWORD97" )

- Funcao que faz o Word aparecer na Area de Transferencia do Windows, sendo que para habilitar/desabilitar e so colocar .T. ou .F.
  OLE_SetProperty( oWord, OLEWDVISIBLE, .T. )
  OLE_SetProperty( oWord, OLEWDPRINTBACK,.T. )

- Funcoes que configuram o tamanho da janela do Word
  OLE_SetProperty( oWord, OLEWDLEFT  , 000 )
  OLE_SetProperty( oWord, OLEWDTOP   , 090 )
  OLE_SetProperty( oWord, OLEWDWIDTH , 480 )
  OLE_SetProperty( oWord, OLEWDHEIGHT, 250 )
  OLE_SetProperty( oWord, oleWdWindowState, "MAX" )
  
- Funcao de abertura do Documento com os parametros lReadOnly (Somente Leitura), com SENHAXXX (senha de abertura do Documento) 
  e com SENHAWWW (senha de gravacao)
  OLE_OPENFILE( oWord, "C:\WINDOWS\TEMP\EXEMPLO.DOC", lReadOnly, "SENHAXXX","SENHAWWW")

- Funcao para criar um Documento com Modelo(DOT) especificado no parametro
  OLE_NewFile( oWord, "C:\WINDOWS\TEMP\EXEMPLO.DOT" )

- Funcao que salva o Documento com o nome especificado, com senha e no formato Word
  OLE_SaveAsFile( oWord, 
                  "C:\WINDOWS\TEMP\EXEMPLO1.DOC", 
                  "SENHAXXX", 
                  "SENHAWWW", 
                  .F., 
                  oleWdFormatDocument ) ... oleWdFormatHTML ... oleWdFormatPDF

- Funcao salva o Documento corrente
  OLE_SaveFile( oWord )

- Funcao que atualiza as variaveis do Word, conforme exemplo ira atualizar a variavel "AdvNomeFilial" com o conteudo 
  "Microsiga Software S/A". O RdMake GPEWORD podera servir de exemplo para atualizacao de variaveis
  OLE_SetDocumentVar( oWord, "Adv_NomeFilial", "Microsiga Software S/A" )

- Funcao que atualiza os campos da memoria para o Documento, utilizada logo apos a funcao OLE_SetDocumentVar()
  OLE_Updatefields( oWord )

- Funcao que imprime o Documento corrente podendo ser especificado o numero de copias, podedo tambem imprimir 
  com um intervalo especificado nos parametros "nPagInicial" ate "nPagFinal" retirando o parametro"ALL"
  OLE_PrintFile( oWord, "ALL" , nPagInicial, nPagFinal, nCopias )
  OLE_PrintFile( oWord, "PART", nPagInicial, nPagFinal, nCopias )

- Funcao que fecha o Documento sem fechar o Link com o Word, utilizado para manipulacao de dois ou mais arquivos 
  (recomendado fechar todos os arquivos antes de fechar o Link com Word)
  OLE_CloseFile( oWord )

- Funcao que fecha o Link com o Word
  OLE_CloseLink( oWord )
*/