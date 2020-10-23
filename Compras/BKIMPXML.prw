#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} zImpXML
Função criada para importar os xmls de fornecedores com opção de pré nota ou classificar direto em Documento de Entrada
@author Atilio
@since 06/07/2017
@version 1.0
@type function
/*/

User Function BKIMPXML()
	Local aArea       := GetArea()
	Local aPergs      := {}
	Local aRetorn     := {}
	Local oProcess    := Nil
	Local aButtons    := {}
	Local lOk         := .F.
	//Conteúdos dos parâmetros
	Private cDirect   := "C:\xmls\" + Space(100)
	Private cTipoImp  := "2"
	Private cPedCom   := "1"
	Private cVldCNPJ  := "1"
	Private cAmarra   := "1"
	Private cCamFull  := cDirect + "*.xml"
	//Variáveis usadas na importação
	Private aProd     := {}
	Private aCabec    := {}
	Private aItens    := {}
	Private cCadastro := "Importação XML"
	//Variáveis usadas no MarkBrowse
	Private aCampos   := {}
	Private oMark
	Private oDlgXML
	Private aCpos     := {}
	Private cMarca    := GetMark()
	Private cArq
	Private lInvert
	//Dimensionamentos
	Private aTamanho  := MsAdvSize()
	Private	nJanLarg  := aTamanho[5]
	Private	nJanAltu  := aTamanho[6]
	Private nTopAux   := Iif(GetSrvProfString("RPOVERSION", "") == '120', aTamanho[1]+35, aTamanho[1]+5)
	Private aPos      := {nTopAux, aTamanho[1]+5, aTamanho[4]-15, aTamanho[3]}
	//Outras variáveis
	Private nXML      := 0
	
	//Adiciona os parametros para a pergunta
	aAdd(aPergs, {1, "Diretório com arquivos xml",	cDirect, "", ".T.", "", ".T.", 80, .T.})
	aAdd(aPergs, {2, "Tipo Importação",				Val(cTipoImp), {"1=Pré Nota",              "2=Classificação em Documento de Entrada"},     122, ".T.", .F.})
	aAdd(aPergs, {2, "Vincula Pedido de Compra",	Val(cPedCom),  {"1=Sim (Automaticamente)", "2=Não"},                                       090, ".T.", .F.})
	aAdd(aPergs, {2, "Valida CNPJ Destinatário",	Val(cVldCNPJ), {"1=Sim",                   "2=Não"},                                       040, ".T.", .F.})
	aAdd(aPergs, {2, "Incl Amarração Prod x Forn",	Val(cAmarra),  {"1=Sim",                   "2=Não"},                                       040, ".T.", .F.})
	
	//Se a pergunta for confirmada
	If ParamBox(aPergs, "Informe os parâmetros", @aRetorn, , , , , , , , .F., .F.)
		cDirect  := Alltrim(aRetorn[1])
		cTipoImp := cValToChar(aRetorn[2])
		cPedCom  := cValToChar(aRetorn[3])
		cVldCNPJ := cValToChar(aRetorn[4])
		cAmarra  := cValToChar(aRetorn[5])
		
		//Se o último caracter não for uma barra, será uma barra
		If SubStr(cDirect, Len(cDirect), 1) != '\'
			cDirect += "\"
		EndIf
		
		//Define o caminho full
		cCamFull := cDirect + "*.xml"
		
		//Campos para criar a estrutura da temporária
		aAdd(aCampos, {"OK",        "C", 002,                   0})
		aAdd(aCampos, {"TIPO",      "C", 010,                   0})
		aAdd(aCampos, {"CODIGO",    "C", TamSX3('A2_COD')[1],   0})
		aAdd(aCampos, {"LOJA",      "C", TamSX3('A2_LOJA')[1],  0})
		aAdd(aCampos, {"RAZAO",     "C", TamSX3('A2_NOME')[1],  0})
		aAdd(aCampos, {"DOCUMENTO", "C", TamSX3('F1_DOC')[1],   0})
		aAdd(aCampos, {"SERIE",     "C", TamSX3('F1_SERIE')[1], 0})
		aAdd(aCampos, {"XML",       "C", 100,                   0})
		
		//Cria a Temporária
		cArq := CriaTrab(aCampos)
		DbUseArea(.T., , cArq, "TMP", .T., .F.)
		IndRegua("TMP", cArq, "DOCUMENTO+SERIE", , , "Criando Controles")
		
		//Carregando os dados da temporária
		oProcess := MsNewProcess():New({|| fCarrega(@oProcess) }, "Carregando temporária", "Processando", .F.)
		oProcess:Activate()
		
		//Campos que serão mostrados na dialog
		aAdd(aCpos, {"OK"        , , " "            })
		aAdd(aCpos, {"TIPO"      , , "Tipo"         })
		aAdd(aCpos, {"CODIGO"    , , "Codigo"       })
		aAdd(aCpos, {"LOJA"      , , "Loja"         })
		aAdd(aCpos, {"RAZAO"     , , "Razão Social" })
		aAdd(aCpos, {"DOCUMENTO" , , "Documento"    })
		aAdd(aCpos, {"SERIE"     , , "Serie"        })
		aAdd(aCpos, {"XML"       , , "XML"          })
		
		//Botão de Pesquisar Nota
		aAdd(aButtons, {"PESQUISA", {|| u_zXMLPesq()}, "Pesquisar Nota" })
		
		DbSelectArea("TMP")
		TMP->(DbGoTop())
		
		//Se tem arquivos xml para importação
		If nXML > 0
			
			//Cria a janela para seleção dos dados
			DEFINE MSDIALOG oDlgXML TITLE "Importacao XML" FROM 000, 000 To nJanAltu, nJanLarg PIXEL
				//Cria o objeto de seleção dos dados
				lInvert := .F.
				oMark := MsSelect():New("TMP", "OK", , aCpos, @lInvert, cMarca, aPos)
				oMark:oBrowse:lHasMark    := .T.
				oMark:oBrowse:lCanAllMark := .T.
				oMark:oBrowse:bAllMark    := {|| fMarkAll(cMarca), oMark:oBrowse:Refresh()}
				oMark:bMark               := {|| oMark:oBrowse:Refresh()}
			ACTIVATE MSDIALOG oDlgXML CENTERED ON INIT EnchoiceBar(oDlgXML, {|| lOk := .T., oDlgXML:End()}, {|| lOk := .F., oDlgXML:End()}, , aButtons)
			
			//Se a tela foi confirmada, gera a importação dos dados
			If lOk
				oProcess := MsNewProcess():New({|| fGeraNfe(@oProcess) }, "Importando os documentos", "Processando", .F.)
				oProcess:Activate()
			EndIf
		Else
			MsgAlert("Não há XML(s) para importação!", "Atenção")
		EndIf
		
		//Exclui a temporária
		TMP->(DbCloseArea())
		fErase(cArq)
	EndIf
	
	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fCarrega                                                     |
 | Desc:  Função que carrega os dados dos xml na temporária            |
 *---------------------------------------------------------------------*/

Static Function fCarrega(oProc)
	Local nI            := 0
	Local aFiles        := {}
	Local cFile         := ""
	Local nHdl          := 0
	Local nTamFile      := 0
	Local cBuffer       := ""
	Local nBtLidos      := 0
	Local cAviso        := ""
	Local cErro         := ""
	Local cDocBranco    := Replicate('0', TamSX3('F1_DOC')[1])
	Local nTamSerie     := TamSX3('F1_SERIE')[1]
	Private oNfe
	Private oNF
	Private oEmitente
	Private oIdent
	Private oDestino
	Private oDet
	Private cCgcDest    := Space(14)
	Private cTipo       := ''
	Private cCodigo     := ''
	Private cLoja       := ''
	Private cRazao      := ''
	Private cCgcEmit    := ''
	Private cDoc        := ''
	Private cSerie      := ''
	
	DbSelectArea('SA2')
	SA2->(DbSetOrder(3))
	DbSelectArea('SA1')
	SA1->(DbSetOrder(3))
	
	//Identificando os arquivos e colocando no array aFile
	aFiles := Directory(cCamFull)
	oProc:SetRegua1(Len(aFiles))
	
	//Percorre todos os arquivos
	For nI := 1 To Len(aFiles)
		//Pegando o arquivo
		cFile := cDirect + aFiles[nI][1]
		
		oProc:IncRegua1("Analisando arquivo "+cValToChar(nI)+" de "+cValToChar(Len(aFiles))+"...")
		oProc:SetRegua2(1)
		oProc:IncRegua2("...")
		
		//Se for a extensão xml, abre o arquivo
		If Upper(Right(cFile, 4)) == ".XML"
			nHdl  := fOpen(cFile, 0)
		
			//Se não foi possí­vel abrir
			If nHdl == -1
				If !Empty(cFile)
					Aviso("Atenção", "Erro #001:"+ CRLF +"O arquivo de nome '"+cFile+"' não pode ser aberto!", {"Ok"}, 2)
				EndIf
			Else
				oProc:SetRegua2(4)
				oProc:IncRegua2("Analisando arquivo "+cFile+"...")
				
				//Pega o conteúdo do arquivo (não foi usado MemoRead pois o limite de uma variável caracter pode mudar)
				nTamFile := fSeek(nHdl, 0, 2)
				fSeek(nHdl, 0, 0)
				cBuffer  := Space(nTamFile)
				nBtLidos := fRead(nHdl, @cBuffer, nTamFile)
				fClose(nHdl)
				
				//Transforma o XML em Objeto
				cAviso := ""
				cErro  := ""
				oNfe   := XmlParser(cBuffer, "_", @cAviso, @cErro)
				
				//Caso não tenha erro
				If (Empty(cErro))
					oNF      := Nil
					cTipo    := ''
					cCodigo  := ''
					cLoja    := ''
					cRazao   := ''
					
					//Se tiver a tag NfeProc, pega dela
					If Type("oNFe:_NfeProc") != "U"
						If Type("oNFe:_NfeProc:_NFe") != "U"
							oNF := oNFe:_NFeProc:_NFe
						EndIf
						
					//Senão pega direto da tag NFe
					ElseIf Type("oNFe:_Nfe") != "U"
						oNF := oNFe:_NFe
					EndIf
					
					//Se tiver dados de NF
					If oNF != Nil
						oProc:IncRegua2("Transformando em objeto...")
						
						//Pega as tags para definir as variáveis
						oEmitente  := oNF:_InfNfe:_Emit
						oIdent     := oNF:_InfNfe:_IDE
						oDestino   := oNF:_InfNfe:_Dest
						oDet       := oNF:_InfNfe:_Det
						cCgcDest   := Space(14)
						oDet       := IIf(ValType(oDet)=="O", {oDet}, oDet)
						cCgcEmit   := Alltrim(IIf(Type("oEmitente:_CPF")=="U", oEmitente:_CNPJ:TEXT, oEmitente:_CPF:TEXT))
						cCgcDest   := Alltrim(IIf(Type("oDestino:_CPF")=="U", oDestino:_CNPJ:Text, oDestino:_CPF:Text))
						cDoc       := Right(cDocBranco+Alltrim(oIdent:_nNF:TEXT), Len(cDocBranco))
						cSerie     := PadR(oIdent:_serie:TEXT, nTamSerie)
					    
					    oProc:IncRegua2("Pegando atributos...")
					    
						//Se não conseguir posicionar no fornecedor
						If ! SA2->(DbSeek(FWxFilial("SA2") + cCgcEmit))
							//Se não conseguir posicionar no cliente
							If ! SA1->(DbSeek(FWxFilial("SA1") + cCgcEmit))
								Aviso("Atenção", "Erro #002:"+ CRLF +"CNPJ Origem não encontrado - arquivo '"+cFile+"'!", {"Ok"}, 2)
		
							Else
								//Caso o cliente esteja bloqueado, percorre os clientes enquanto for o mesmo CNPJ atÃ© encontrar 1 que não esteja bloqueado
								If SA1->A1_MSBLQL == '1'
									While ! SA1->(EoF()) .And. SA1->A1_FILIAL == FWxFilial('SA1') .And. SA1->A1_CGC == cCgcEmit .And. SA1->A1_MSBLQL == '1'
										SA1->(DbSkip())
									EndDo
								EndIf
								
								//Define as variáveis para inclusão no browse
								cTipo   := 'CLIENTE'
								cCodigo := SA1->A1_COD
								cLoja   := SA1->A1_LOJA
								cRazao  := SA1->A1_NOME
								lInclui := .T.
								If SA1->A1_CGC != cCgcEmit
									lInclui := .F.
								EndIf
							EndIf
		
						Else
							//Caso o fornecedor esteja bloqueado, percorre os fornecedores até encontrar 1 que não esteja
							If SA2->A2_MSBLQL == '1'
								While ! SA2->(EoF()) .And. SA2->A2_FILIAL == FWxFilial('SA2') .And. SA2->A2_CGC == cCgcEmit .And. SA2->A2_MSBLQL == '1'
									SA2->(DbSkip())
								EndDo
							EndIf
							
							//Define as variáveis para inclusão no browse
							cTipo   := 'FORNECEDOR'
							cCodigo := SA2->A2_COD
							cLoja   := SA2->A2_LOJA
							cRazao  := SA2->A2_NOME
							lInclui := .T.
							If SA2->A2_CGC != cCgcEmit
								lInclui := .F.
							EndIf
						EndIf
						
						//Se for para validar o CNPJ do Destinatário
						If cVldCNPJ == "1"
							//Caso seja diferente do CNPJ, não será inclusão
							If cCgcDest != SM0->M0_CGC
								Aviso("Atenção", "Erro #009:"+ CRLF +"Documento/série '"+cDoc+"/"+cSerie+"' foi emitido com destinatário para '"+cCgcDest+"' e não para '"+SM0->M0_CGC+"'!"+CRLF+CRLF+"Arquivo: "+cFile, {"Ok"}, 2)
								lInclui := .F.
							EndIf
						EndIf
						
						oProc:IncRegua2("Incluindo na temporária...")
						
						//Caso seja inclusão
						If lInclui
							//Se tiver um tipo
							If ! Empty(cTipo)
								RecLock('TMP', .T.)
									OK        := ''
									TIPO      := cTipo
									CODIGO    := cCodigo
									LOJA      := cLoja
									RAZAO     := cRazao
							        DOCUMENTO := cDoc
							        SERIE     := cSerie
									XML       := aFiles[nI][1]
								TMP->(MsUnlock())
								
								nXML++
							EndIf
						EndIf
					EndIf
				Else
					Aviso("Atenção", "Erro #003:"+ CRLF +"Falha ao transformar em objeto o XML - '"+cFile+"'!"+CRLF+cErro, {"Ok"}, 2)
				EndIf
			EndIf
	    EndIf
	Next
Return

/*---------------------------------------------------------------------*
 | Func:  fGeraNfe                                                     |
 | Desc:  Função que gera os dados da nota                             |
 *---------------------------------------------------------------------*/

Static Function fGeraNfe(oProc)
	Local nCont
	Local nContLote
	Local cQuery
	Local nItem        := 0
	Local lGera        := .T.
	Local cFile        := ''
	Local nHdl         := 0
	Local nTamFile     := 0
	Local cBuffer      := ''
	Local nBtLidos     := 0
	Local cAviso       := ''
	Local cErro        := ''
	Local cDocBranco   := Replicate('0', TamSX3('F1_DOC')[1])
	Local nTamSerie    := TamSX3('F1_SERIE')[1]
	Local cCodFornAx   := ''
	Local lOkItem
	Local cDescProF    := ''
	Local nFator
	Local lMed
	Local nTotalMed
	Local nQtdeLote
	Local cLote
	Local cValidade
	Local nDescTT
	Local nValorTT
	Local nDescLote
	Local nValLote
	Local cPedAut
	Local cItPedAut
	Local nTamProd     := TamSX3('B1_COD')[1]
	Local nTamForn     := TamSX3('A2_COD')[1]
	Local nTamLoja     := TamSX3('A2_LOJA')[1]
	Local nPosProd
	Local nFrete
	Local nSeguro
	Local nIcmsSubs
	Local nTotalMerc
	Local cData
	Local dData
	Local cChaveNFE
	Local cFileImp
	Local nAtuMark     := 0
	Local nTotalMark   := 0
	Private cCodPro
	Private oNfe
	Private oNF
	Private oEmitente
	Private oIdent
	Private oDet
	Private oDlgAmarra
	Private oGetProd, cGetProd := Space(nTamProd)
	Private oSayForn
	Private oSaySemA
	Private oSayProd
	Private oBtnGrav
	Private oBtnFech
	Private oNFAux
	Private aProd        := {}
	Private aCabec       := {}
	Private aItens       := {}
	Private lMsErroAuto  := .F.
	Private aRotina      := {}
	Private aHeadSD1     := {}
	Private cCodigo
	Private cLoja
	Private cRazao
	Private cCodForn
	Private cUnidad
	
	DbSelectArea('SA2')
	SA2->(DbSetOrder(3))
	DbSelectArea('SA1')
	SA1->(DbSetOrder(3))
	DbSelectArea('SF1')
	SF1->(DbSetOrder(1))
	DbSelectArea("SA5")
	DbSelectArea("SB1")
	DbSelectArea("SLK")
	
	//Enquanto houver registros
	TMP->(DbGoTop())
	While ! TMP->(EoF())
	
		//Se o registro tiver marcado, incrementa a variável
		If TMP->OK == cMarca
			nTotalMark++
		EndIf
		
		TMP->(DbSkip())
	EndDo
	oProc:SetRegua1(nTotalMark)
	
	//Percorre os dados da temporária
	DbSelectArea('TMP')
	TMP->(DbGoTop())
	While ! TMP->(EoF())
		aProd := {}
		
		//Se o registro tiver marcado
		If TMP->OK == cMarca
			nAtuMark++
			oProc:IncRegua1("Analisando documento '"+TMP->DOCUMENTO+"' ("+cValToChar(nAtuMark)+" de "+cValToChar(nTotalMark)+")...")
			oProc:SetRegua2(1)
			oProc:IncRegua2("...")
			
			nItem  := 0
			lGera  := .T.
			aCabec := {}
			aItens := {}
			
			//Abrindo o arquivo
			cFile    := cDirect + Alltrim(TMP->XML)
			nHdl     := fOpen(cFile, 0)
			nTamFile := fSeek(nHdl, 0, 2)
			fSeek(nHdl, 0, 0)
			cBuffer  := Space(nTamFile)
			nBtLidos := fRead(nHdl, @cBuffer, nTamFile)
			fClose(nHdl)
			
			//Transformando texto em um objeto
			cAviso := ""
			cErro  := ""
			oNfe := XmlParser(cBuffer, "_", @cAviso, @cErro)
			
			//Caso tenha a tag NfeProc, pega dentro dela a tag NFe
			If Type("oNFe:_NfeProc") != "U"
				oNF := oNFe:_NFeProc:_NFe
			Else
				oNF := oNFe:_NFe
			EndIf
			
			//Pegando os atributos das tags
			oEmitente  := oNF:_InfNfe:_Emit
			oIdent     := oNF:_InfNfe:_IDE
			oDet       := oNF:_InfNfe:_Det
			oDet       := IIf(ValType(oDet)=="O", {oDet}, oDet)
			cCgcEmit   := Alltrim(IIf(Type("oEmitente:_CPF")=="U", oEmitente:_CNPJ:TEXT, oEmitente:_CPF:TEXT))
			cDoc       := Right(cDocBranco + Alltrim(oIdent:_nNF:TEXT), Len(cDocBranco))
			cSerie     := PadR(oIdent:_Serie:TEXT, nTamSerie)
			cTipo      := ''
			cCodigo    := TMP->CODIGO
			cLoja      := TMP->LOJA
			cRazao     := TMP->RAZAO
			
			oProc:SetRegua2(Len(oDet) +3)
			oProc:IncRegua2("Analisando dados do documento...")
			
			//Se não conseguir posicionar no fornecedor
			If !SA2->(DbSeek(FWxFilial("SA2") + cCgcEmit))
				
				//Caso não encontre o cliente
				If !SA1->(DbSeek(FWxFilial("SA1") + cCgcEmit))
					Aviso("Atenção", "Erro #004:"+ CRLF +"CNPJ Origem Não Localizado, verificar o xml - '"+cFile+"'!", {"Ok"}, 2)
					lGera := .F.
				Else
					cTipo   := 'C'
				EndIf
			
			Else
				cTipo   := 'F'
			EndIf
			
			//Se conseguir posicionar na nota
			If SF1->(DbSeek(FWxFilial("SF1") + cDoc + cSerie + cCodigo + cLoja))
				//Se a nota for da Espécie SPED
				If Alltrim(SF1->F1_ESPECIE) == 'SPED'
					Aviso("Atenção", "Erro #005:"+ CRLF +"Nota '"+cDoc+"' com a Série '"+cSerie+"' já foi importada para o "+Iif(cTipo=='F', "Fornecedor", "Cliente")+" '"+cCodigo+"/"+cLoja+"'!", {"Ok"}, 2)
					lGera := .F.
					TMP->(DbSkip())
					Loop
				EndIf
			EndIf
			
			//Percorre os itens da Nota
			cCodFornAx := Alltrim(oDet[01]:_Prod:_cProd:Text)
			For nCont := 1 To Len(oDet)
				cDescProF := oDet[nCont]:_Prod:_xProd:Text
				cCodBarra := oDet[nCont]:_Prod:_CEAN:Text
				cCodForn  := Alltrim(oDet[nCont]:_Prod:_CPROD:Text)
				nQuant    := Val(oDet[nCont]:_Prod:_QCOM:Text)
				nPrcUnBrt := Val(oDet[nCont]:_Prod:_VUNCOM:Text)
				nPrcTtBrt := nQuant * nPrcUnBrt
				nValDesc  := 0
				lOkItem   := .F.
				cCodPro   := ''
				cUnidad   := ''
				
				oProc:IncRegua2("Analisando produto ("+cValToChar(nCont)+" de "+cValToChar(Len(oDet))+")...")
				
				//Se tiver a tag VDESC, pega o valor de desconto
				If XmlChildEx(oDet[nCont]:_PROD, "_VDESC")!= Nil
					nValDesc := Val(oDet[nCont]:_Prod:_VDESC:Text)
				EndIf
				
				//Irá ser verificado se existem zeros a esquerda
				If Alltrim(Str(Val(cCodForn))) != cCodForn .And. Val(cCodForn) > 0
					cCodForn     := Alltrim(Str(val(cCodForn)))
					
					//Caso exista o produto na SA5
					SA5->(DbSetOrder(5))
					If SA5->(DbSeek(FWxFilial("SA5") + cCodForn))
						//Enquanto houver dados na SA5 para esse código
						While ! SA5->(EoF()) .And. Alltrim(SA5->A5_CODPRF) == cCodForn
							//Se for o mesmo Fornecedor e Loja
							If SA5->(A5_FORNECE+A5_LOJA) == cCodigo+cLoja
								lOkItem    := .T.
								cCodFornAx := cCodForn
								cCodPro    := SA5->A5_PRODUTO
								cUnidad    := SA5->A5_UNID
								Exit
							EndIf
							
							SA5->(DbSkip())
						EndDo
					EndIf
				EndIf
				
				//Caso não tenha encontrado
				If ! lOkItem
					//Procura pelo código na SA5 com o código do fornecedor
					SA5->(DbSetOrder(5))
					If SA5->(DbSeek(FWxFilial("SA5") + cCodForn))
						//Enquanto houver dados na SA5 para esse código
						While  ! SA5->(EoF()) .And. Alltrim(SA5->A5_CODPRF) == cCodForn
							//Se for o mesmo fornecedor
							If SA5->(A5_FORNECE+A5_LOJA) == cCodigo+cLoja
								lOkItem := .T.
								cCodPro := SA5->A5_PRODUTO
								cUnidad := SA5->A5_UNID
								Exit
							EndIf
							SA5->(DbSkip())
						EndDo
					EndIf
				EndIf
				
				//Se tiver código de barras
				If ! lOkItem .And. ! Empty(cCodBarra)
					//Busca pelo Codigo de Barras no cadastro do produto
					SB1->(DbSetOrder(5))
					If SB1->(DbSeek(FWxFilial("SB1")+cCodBarra))
						cCodPro := SB1->B1_COD
						
						//Verifica se existe uma amarracao para o produto encontrado
						SA5->(DbSetOrder(2))
						If ! (SA5->(DbSeek(FWxFilial("SA5") + cCodPro + cCodigo + cLoja)))
							//Inclui a amarracao do produto X Fornecedor
							lOkItem := .T.
							RecLock("SA5", .T.)
								A5_FILIAL  := FWxFilial("SA5")
								A5_FORNECE := cCodigo
								A5_LOJA    := cLoja
								A5_NOMEFOR := SA2->A2_NOME
								A5_PRODUTO := cCodPro
								A5_NOMPROD := SB1->B1_DESC
								A5_CODPRF  := cCodForn
							SA5->(MsUnLock())
						Else
							//Atualiza a amarracao se nao tiver o codigo do fornecedor cadastrado.
							If Empty(SA5->A5_CODPRF) .Or. SA5->A5_CODPRF == "0"
								lOkItem := .T.
								RecLock("SA5", .F.)
									A5_CODPRF := cCodForn
								SA5->(MsUnLock())
							EndIf
						EndIf
					EndIf
					
					//Caso não esteja ok, procura na tabela SLK pelo código de barras
					If !lOkItem
						SLK->(DbSetOrder(1))
						If SLK->(DbSeek(FWxFilial("SLK") + cCodBarra))
							lOkItem := .T.
							cUnidad := "3"
							cCodigo := SLK->LK_CODIGO
						EndIf
					EndIf
				EndIf
				
				//Se o código do fornecedor estiver diferente
				If Alltrim(cCodForn) != Alltrim(cCodFornAx)
					lOkItem    := .F.
					cCodFornAx := cCodForn
				EndIf
				
				//Se não tiver OK
				If ! lOkItem
					//Se for para incluir amarração entre produto e fornecedor
					If cAmarra == "1"
						//Seleciona a quantidade de registros existente entre Fornecedor e Produto
						cQuery := " SELECT "
						cQuery += "    COUNT(*) QTDE "
						cQuery += " FROM "
						cQuery += "    "+RetSqlName('SA5')+" SA5 "
						cQuery += " WHERE "
						cQuery += "    A5_FORNECE = '"+cCodigo+"' "
						cQuery += "    AND A5_LOJA = '"+cLoja+"' "
						cQuery += "    AND A5_CODPRF = '"+cCodForn+"' "
						cQuery += "    AND SA5.D_E_L_E_T_ = ' ' "
						TcQuery cQuery New Alias "QSA5"
						
						//Caso não tenha a amarração
						If (QSA5->QTDE == 0)
							cGetProd := Space(nTamProd)
							
							//Mostra a janela para criação da amarração
							DEFINE MSDIALOG oDlgAmarra TITLE "Incluir Amarração" FROM 000, 000  To 150, 420 COLORS 0, 16777215 PIXEL
								@ 010, 015 SAY    oSayForn PROMPT "Fornecedor: "+ cCodigo +"/"+ cLoja +" ("+ Alltrim(SubStr(cRazao, 1, 40)) +")"     SIZE 150, 007 OF oDlgAmarra COLORS 0, 16777215 PIXEL
								@ 020, 015 SAY    oSaySemA PROMPT "Produto Sem Amarração: "+ cCodForn +" ("+ Alltrim(SubStr(cDescProF, 1, 50)) +")"  SIZE 150, 007 OF oDlgAmarra COLORS 0, 16777215 PIXEL
								@ 030, 015 SAY    oSayProd PROMPT "Produto : "                                                              SIZE 150, 007 OF oDlgAmarra COLORS 0, 16777215 PIXEL
								@ 030, 040 MSGET  oGetProd VAR    cGetProd                                                                  SIZE 060, 010 OF oDlgAmarra COLORS 0, 16777215 F3 'SB1' PIXEL
								@ 050, 120 BUTTON oBtnGrav PROMPT "&OK"                                                                     SIZE 037, 012 ACTION (fGravaProd(), oDlgAmarra:End()) OF oDlgAmarra PIXEL
								@ 050, 160 BUTTON oBtnFech PROMPT "&Fechar"                                                                 SIZE 037, 012 ACTION oDlgAmarra:End() OF oDlgAmarra PIXEL
							Activate Dialog oDlgAmarra Centered
						EndIf
						QSA5->(DbCloseArea())
					EndIf
					
					//Se tiver em branco o código do produto
					If Empty(cCodPro)
						Aviso("Atenção", "Erro #006:"+ CRLF +"Produto sem amarração '"+cCodForn+"' ("+cDescProF+")!"+CRLF+"CÃ³digo de Barras: "+cCodBarra, {"Ok"}, 2)
						lGera := .F.
						TMP->(DbSkip())
						Loop
					EndIf
				EndIf
				
				//Se não encontrar o item, adiciona no array
				If (aScan(aProd, {|x| x[01] == StrZero(nCont, 3)}) == 0)
					aAdd(aProd, {StrZero(nCont, 3), cCodPro})
				EndIf
				
				//Posiciona no produto encontrado
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(FWxFilial("SB1")+cCodPro))
				
				//Se o produto estiver bloqueado
				If SB1->B1_MSBLQL == '1'
					Aviso("Atenção", "Erro #007:"+ CRLF +"Produto '"+Alltrim(SB1->B1_COD)+"' ("+Alltrim(SB1->B1_DESC)+") está bloqueado!", {"Ok"}, 2)
					lGera := .F.
					TMP->(DbSkip())
					Loop
				EndIf
				
				//Pegando o fator de múltiplicação
				nFator := 1
				If cUnidad == "2"
					nFator := SB1->B1_CONV
				ElseIf cUnidad == "3" .And. SLK->LK_QUANT > 1
					nFator := SLK->LK_QUANT
				EndIf
				
				//Possui a tag MED
				lMed := XmlChildEx(oDet[nCont]:_Prod , "_MED" ) != Nil
				
				//Se existir a tag
				If lMed
					//Converte a tag em um array, caso exista mais de um lote para o produto
					If ValType(oDet[nCont]:_PROD:_MED) == "O"
						XmlNode2Arr(oDet[nCont]:_PROD:_MED, "_MED")
					EndIf
					nTotalMed := Len(oDet[nCont]:_PROD:_MED)
				Else
					nTotalMed := 1
					nQtdeLote := nQuant
					cLote     := ""
					cValidade := ""
				EndIf
				nDescTT  := 0
				nValorTT := 0
				
				//Percorre os lotes para o produto
				For nContLote := 1 To nTotalMed
					//Se tiver a tag MED
					If lMed
						cLote     := oDet[nCont]:_Prod:_MED[nContLote]:_NLote:Text
						cValidade := oDet[nCont]:_Prod:_MED[nContLote]:_DVal:Text
						cValidade := SubStr(cValidade, 9, 2)+"/"+SubStr(cValidade, 6, 2)+"/"+SubStr(cValidade, 1, 4)
						nQtdeLote := Val(oDet[nCont]:_Prod:_MED[nContLote]:_QLote:Text)
					EndIf
					
					//Se o numero atual for diferente do total de lotes
					If nContLote != nTotalMed
						nDescLote := Round(nValDesc/nQuant*nQtdeLote, 2)  //Desconto do Lote Atual
						nValLote  := Round(nPrcTtBrt/nQuant*nQtdeLote, 2) //Valor do Lote Atual
						
						nDescTT   += nDescLote
						nValorTT  += nValLote
					Else
						nDescLote := nValDesc  - nDescTT  //Desconto do Lote Atual - Diferenca
						nValLote  := nPrcTtBrt - nValorTT //Valor do Lote Atual - Diferenca
					EndIf
					
					//Se tiver fator de conversão, multiplica a quantidade
					If nFator > 1
						nQtdeLote := nQtdeLote*SB1->B1_CONV
					EndIf
					
					//Se for buscar pedido de compra automaticamente
					cPedAut   := ''
					cItPedAut := ''
					If cPedCom == "1"
						/*
						DbSelectArea('SC7')
						SC7->(DbSetOrder(2))
						
						//Se conseguir posicionar no pedido
						If SC7->(DbSeek( FWxFilial('SC7') + PadR(cCodPro, nTamProd) + PadR(cCodigo, nTamForn) + PadR(cLoja, nTamLoja) ))
							
							//Se ainda houver quantidade a ser utilizada
							If  C7_FILIAL  == FWxFilial('SC7')        .And. ;
								C7_PRODUTO == PadR(cCodPro, nTamProd) .And. ;
								C7_FORNECE == PadR(cCodigo, nTamForn) .And. ;
								C7_LOJA    == PadR(cLoja,   nTamLoja) .And. ;
								C7_QUANT - C7_QUJE >= nQtdeLote
								
								cPedAut   := C7_NUM
								cItPedAut := C7_ITEM
							EndIf
						EndIf
						*/
						
						//Mudando a forma de buscar o pedido de compra, da outra forma se o primeiro pedido não desse certo, ele não buscava outros
						cQryPedC := " SELECT "
						cQryPedC += " 	C7_NUM, C7_ITEM "
						cQryPedC += " FROM "
						cQryPedC += " 	"+RetSQLName('SC7')+" SC7 " 
						cQryPedC += " WHERE "
						cQryPedC += " 	C7_FILIAL = '"+FWxFilial('SC7')+"' "
						cQryPedC += " 	AND C7_PRODUTO = '"+cCodPro+"' "
						cQryPedC += " 	AND C7_FORNECE = '"+cCodigo+"' "
						cQryPedC += " 	AND C7_LOJA = '"+cLoja+"' "
						cQryPedC += " 	AND (C7_QUANT - C7_QUJE) >= "+cValToChar(nQtdeLote)+" "
						cQryPedC += " 	AND C7_ENCER != 'E' "
						cQryPedC += " 	AND C7_RESIDUO = '' "
						cQryPedC += " 	AND D_E_L_E_T_ = ' ' "
						TCQuery cQryPedC New Alias "QRY_PED"
						
						//Se existir pedido
						If ! QRY_PED->(EoF())
							cPedAut   := QRY_PED->C7_NUM
							cItPedAut := QRY_PED->C7_ITEM
						EndIf
						
						QRY_PED->(DbCloseArea())
					EndIf
					
					//Incrementa o item e procura por ele no array aProd
					nItem++
					aLinha := {}
					nPosProd := aScan(aProd, {|x| x[01] == StrZero(nItem, 3)})
					
					//Se não encontrar, será o primeiro item
					If (nPosProd == 0)
						nPosProd := 1
					EndIf
					
					cDescAux := Posicione('SB1', 1, FWxFilial('SB1') + aProd[nPosProd][02], 'B1_DESC')
					
					//Adiciona os dados do item atual do documento de entrada
					aAdd(aLinha,     {"D1_ITEM",    StrZero(nItem, 3),   Nil})
					aAdd(aLinha,     {"D1_FILIAL",  FWxFilial('SD1'),    Nil})
					aAdd(aLinha,     {"D1_COD",     aProd[nPosProd][02], Nil})
					aAdd(aLinha,     {"D1_X_DESC",  cDescAux,            Nil})
					aAdd(aLinha,     {"D1_QUANT",   nQtdeLote,           Nil})
					aAdd(aLinha,     {"D1_VUNIT",   nValLote/nQtdeLote,  Nil})
					aAdd(aLinha,     {"D1_TOTAL",   nValLote,            Nil})
					aAdd(aLinha,     {"D1_TES",     "",                  Nil})
					aAdd(aLinha,     {"D1_LOCAL",   "01",                Nil})
					aAdd(aLinha,     {"D1_X_TPCUS", "1",                 Nil})
					aAdd(aLinha,     {"D1_VALDESC", nDescLote,           Nil})
					aAdd(aLinha,     {"D1_LOTEFOR", cLote,               Nil})
					If ! Empty(cPedAut)
						aAdd(aLinha, {"D1_PEDIDO",  cPedAut,             Nil})
						aAdd(aLinha, {"D1_ITEMPC",  cItPedAut,           Nil})
					EndIf
					aAdd(aLinha,     {"AUTDELETA",  "N",                 Nil})
					aAdd(aItens, aLinha)
				Next
			Next
			
			//Se houver itens e não houver falhas para geração
			If Len(aItens) > 0 .And. lGera
				oNFAux := Nil
				
				oProc:IncRegua2("Finalizando dados do documento...")
				
				//Se existir a tag NfeProc pega dela, senão pega da tag Nfe
				If Type("oNFe:_NfeProc") != "U"
					oNFAux := oNFe:_NFeProc:_NFe
				Else
					oNFAux := oNFe:_NFe
				EndIf
				
				//Pegando os dados que serÃ§a
				nFrete        := 0
				nSeguro       := Val(oNFAux:_INFNFE:_TOTAL:_ICMSTOT:_VSeg:Text)
				nIcmsSubs     := Val(oNFAux:_INFNFE:_TOTAL:_ICMSTOT:_VST:Text)
				nTotalMerc    := Val(oNFAux:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:Text) //Valor Mercadorias
				cData         := Alltrim(oIdent:_dHEmi:TEXT)
				dData         := cToD(SubStr(cData, 9, 2) +'/'+ SubStr(cData, 6, 2) +'/'+ SubStr(cData, 1, 4))
				cChaveNFE     := SubStr(oNFAux:_INFNFE:_ID:TEXT, 4, 44)
				
				//Monta o cabeçalho do execauto
				aAdd(aCabec, {"F1_TIPO",    Iif(cTipo=='F', 'N', 'D'),                 Nil})
				aAdd(aCabec, {"F1_FORMUL",  "N",                                       Nil})
				aAdd(aCabec, {"F1_DOC",     cDoc,                                      Nil})
				aAdd(aCabec, {"F1_SERIE",   cSerie,                                    Nil})
				aAdd(aCabec, {"F1_EMISSAO", dData,                                     Nil})
				aAdd(aCabec, {"F1_FORNECE", cCodigo,                                   Nil})
				aAdd(aCabec, {"F1_LOJA",    cLoja,                                     Nil})
				aAdd(aCabec, {"F1_ESPECIE", "SPED",                                    Nil})
				aAdd(aCabec, {"F1_SEGURO",  nSeguro,                                   Nil})
				aAdd(aCabec, {"F1_FRETE",   nFrete,                                    Nil})
				aAdd(aCabec, {"F1_VALMERC", nTotalMerc,                                Nil})
				aAdd(aCabec, {"F1_VALBRUT", nTotalMerc + nSeguro + nFrete + nIcmsSubs, Nil})
				aAdd(aCabec, {"F1_CHVNFE",  cChaveNFE,                                 Nil})
				
				oProc:IncRegua2("Gerando documento...")
				
				//Chama a inclusão da pré nota
				SB1->(DbSetOrder(1))
				lMsErroAuto := .F.
				MATA140(aCabec, aItens, 3)
				
				//Se não houve erros
				If !lMsErroAuto
					//Posiciona na SF1
					SF1->(DbSeek(FWxFilial("SF1") + cDoc + cSerie + cCodigo + cLoja))
					
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
					
					//Se não existir o diretório de importados, será criado
					If !ExistDir(cDirect + 'Importados\')
						MakeDir(cDirect + 'Importados\')
					EndIf
					
					//Copia o arquivo para o diretório de importados
					cFileImp := cDirect + 'Importados\' + Alltrim(TMP->XML)
					FRename(cFile, cFileImp)
					
					//Exclui o xml atual da temporária
					RecLock('TMP', .F.)
						DbDelete()
					TMP->(MsUnlock())
				
				//Senão, mostra o erro do execauto
				Else
					Aviso("Atenção", "Erro #008:"+ CRLF +"Falha ao incluir Documento / Série ('"+cDoc+"/"+cSerie+"')!", {"Ok"}, 2)
					MostraErro()
				EndIf
			EndIf
		EndIf
		
		TMP->(DbSkip())
	EndDo
Return

/*---------------------------------------------------------------------*
 | Func:  fGravaProd                                                   |
 | Desc:  Função para gravar o produto na SA5                          |
 *---------------------------------------------------------------------*/

Static Function fGravaProd()
	Local aArea := GetArea()
	cCodPro := ''
	
	//Se tiver produto digitado
	If ! Empty(cGetProd)
		//Se conseguir posicionar no produto
		SB1->(DbSetOrder(1))
		If SB1->(DbSeek(FWxFilial('SB1')+cGetProd))
	    	cCodPro := SB1->B1_COD
	    	cUnidad := ''
		EndIf
		
		//Se conseguir posicionar na tabela de preço do fornecedor
		DbSelectArea("SA5")
		SA5->(DbSetOrder(1)) //A5_FILIAL + A5_FORNECE + A5_LOJA + A5_PRODUTO
		If (SA5->(DbSeek(FWxFilial('SA5') + cCodigo + cLoja + cCodPro)))
			//Se tiver em branco o código do fornecedor, sobrepõe
			If (Empty(SA5->A5_CODPRF))
				RecLock('SA5', .F.)
					A5_CODPRF := cCodForn
				SA5->(MsUnlock())
			EndIf
			
		//Senão, será incluÃ­do um registro na tabela de preço do fornecedor
		Else
			RecLock("SA5", .T.)
		    	A5_FILIAL   := FWxFilial("SA5")
		    	A5_FORNECE  := cCodigo
		    	A5_LOJA     := cLoja
		    	A5_NOMEFOR  := cRazao
		    	A5_PRODUTO  := cCodPro
		    	A5_NOMPROD  := SB1->B1_DESC
		    	A5_CODPRF   := cCodForn
	    	SA5->(MSUnLock())
	  	EndIf
	EndIf
	
	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fMarkAll                                                     |
 | Desc:  Função para marcar todos os registros                        |
 *---------------------------------------------------------------------*/

Static Function fMarkAll(cMarca)
	TMP->(DbGoTop())
	
	//Enquanto houver dados
	While ! TMP->(EoF())
		//Atualiza a marca
		RecLock("TMP", .F.)
			OK := Iif(cMarca != TMP->OK, cMarca, Space(Len(cMarca)))
		TMP->(MsUnlock())
		
		TMP->(DbSkip())
	EndDo
	
	TMP->(DbGoTop())
Return

/*/{Protheus.doc} zXMLPesq
Função para pesquisar um Documento e série no Browse
@author Atilio
@since 19/07/2017
@version 1.0
@type function
/*/

User Function zXMLPesq()
	Local oDlgPesq
	Local oBtnConf
	Local oBtnCanc
	Local oCmbOrdem, cCmbOrdem := "1"
	Local oGetChave, cGetChave := Space(TamSX3('F1_DOC')[01] + TamSX3('F1_SERIE')[01])
	Local aOrdens  := {"1=Documento + Série"}
	Local lOk      := .F.
	
	//Cria a janela de pesquisa
	DEFINE MSDIALOG oDlgPesq TITLE "Pesquisa" FROM 000, 000 To 100, 500 PIXEL
		//Cria o combo e o get
		@ 005, 005 MSCOMBOBOX oCmbOrdem VAR cCmbOrdem ITEMS aOrdens SIZE 210, 08 OF oDlgPesq PIXEL
		@ 020, 005 MSGET      oGetChave VAR cGetChave               SIZE 210, 08 OF oDlgPesq PIXEL
		
		//Cria os botões
		DEFINE SBUTTON oBtnConf FROM 005, 218 TYPE 1 ACTION (lOk := .T., oDlgPesq:End()) ENABLE OF oDlgPesq PIXEL
		DEFINE SBUTTON oBtnCanc FROM 020, 218 TYPE 2 ACTION (lOk := .F., oDlgPesq:End()) ENABLE OF oDlgPesq PIXEL
	ACTIVATE MSDIALOG oDlgPesq CENTERED

	//Se a tela foi confirmada, posiciona no registro procurado
	If lOk
		TMP->(DbSetOrder(Val(cOrdem)))
		TMP->(DbSeek(Alltrim(cGetChave)))
	EndIf
Return
