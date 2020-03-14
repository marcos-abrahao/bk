#include "rwmake.ch"

// -------------------------------------------------------------------------------------------
// A T E N C A O 
// Esta rotina é para impressao de Notas Fiscais => NF DE SERVIÇO
// -------------------------------------------------------------------------------------------

User Function SCRNFS(mv_par01,mv_par02,mv_par03,mv_par04,mv_par05,mv_par06,cPerg)

SetPrvt ("WNREL,CNREL,CTITULO,CDESC1,CDESC2,CDESC3,ARETURN")
SetPrvt ("CIMPNORM,CIMPCOMP,CIMP20CPP,CIMPESP,CIMPON,CIMPOFF,CIMPRESET,NK,NLASTKEY,LCONTINUA,NPOSREG,CKEY")
SetPrvt ("AITENS,ASERV,CNAT,CCFOP,ANATOPER,ACFO,_CENDENT,CEND,ANUMPED,CNUMPED,ACODCLAS")
SetPrvt ("AMENPAD1,AMENPAD2,CMENS1,ADUPL,_CENDCOB,_CMUNCOB")
SetPrvt ("_CREDESP,_CPEDCLI,APEDCLI,ANOTAS,_CCONT,_NKY,LOPCA,_nNotas,CNOTA")
SetPrvt ("_CDESCPR,CNOMENT,_CDESSERV,_NVLRISS,_aNFDev")
SetPrvt ("NI,_CCODPROD,_CSITRIB,N,_cNumNF,_cSerNF,_cTipoNF,_dEmissao,NDUP,_NIRRF")
SetPrvt ("NLIN,NV,_NVLRDESP,_NCONT,_CCFO,_CNAT,_NTAMITEM, _NY,_cCondpag")
SetPrvt ("_cNumPed,_dDatPed,_cCodCli,_cNomCli,_cCGCCli,_cEndCli,_cBaiCli,_cCEPCli,_cMunCli,_cTelCli,_cEstCli,_cInsCli,_nBaseIcm,_nValIcm")
SetPrvt ("_nBICMRet,_nVICMRet,_nValMerc,_nValFret,_nValSeg,_nValIPI,_nValBrut,_cVolu1,_cEspec1,_nPBruto,_nPLiqui")
SetPrvt ("_cNomTra,_cCGCTra,_cEndTra,_cMunTra,_cEstTra,_cInETra,_cNfsOrig,_cSerOrig, _nBaseISS, _nValISS")
SetPrvt ("_cNomRed,_cCGCRed,_cEndRed,_cMunRed,_cEstRed,_cInERed,_nPerIrrf,aDriver,lAglutina, aModelo, cModelo")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³SCRNFS ³ Microsiga                  ³Data³05/09/07³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ N.Fiscal de Saida Padrao para Clientes Microsiga ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Emissao de NF de Saida - MP8                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Emissao de NF de Saida :                                        ³
³ . selecao por serie e numero de N.F.                            ³
³ . verificacao de filial                                         ³
³ . posicionamento na proxima folha do formulario continuo        ³                     
³ . consideracoes p/ diversos pedidos,aliquotas de icms, vend.    ³
³ . total de volumes somados pelos totais de volumes dos PV       ³
³ . mensagem padrao com varias linhas no arquivo SZZ              ³
³ .    deve seguir padrao cod=xxy   xx=cod.mens. / y=linha msg    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*/

Set Century On
lImpresso := .t.

lAglutina	:= .F.


While lImpresso
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wNrel      := "SCRSNF"
	cNrel      := "SCRSNF"
	cTitulo    := "Emissao Nota Fiscal Padrao Microsiga"
	cDesc1     := "Emissao de N.F. de Entrada e Saida Lay-Out Padrao "
	cDesc2     := "para clientes Microsiga"
	cDesc3     := ""
	aReturn    := {"Especial", 1, "Administracao", 2, 2, 1, "", 1}
	cTamanho    := "M"
	
	cImpNorm   := chr(18)                   //impressora - normal
	cImpComp   := chr(15)                   //             comprimido
	cImp20cpp  := chr(27) + "M"             //             20cpp CARACTER MAIS FINO
	cImpEsp    := chr(27) + "0"             //             1/8" altura da linha DISTANCIA ENTRE LINHAS
	cImpOn     := chr(17)                   //             on-line
	cImpOff    := chr(19)                   //             off-line
	cImpReset  := chr(27) + "@"             //             reset
	
	nK         := ""
	nLastKey   := 0
	lContinua  := .T.
	nPosReg    := 0                         //guarda recno() do 1§ item da NF
	cKey       := ""                        //auxiliar p/ chaves de acesso
	aItens     := {}                        //array p/ itens da NF
	aServ      := {}                        //array p/ servicos da NF
	cNat       := ""                        //string p/ naturezas da operacao
	cCFOP      := ""                        //string p/ codigos fiscais
	aNatOper   := {}                        //array para armazenar diferentes naturezas
	aCFO       := {}                        //array p/controle de CF ja considerados
	_cEndEnt   := _cEndCob := space(80)            //endereco de entrega/cobranca
	_cCidEnt   := ""
	_cFoneEnt  := ""
	_cCepEnt   := ""
	_cMunCob   := ""                        //municipio de entrega/cobranca
	aNumPed    := {}                        //array  p/ numeros de nossos pedidos
	cNumPed    := ""                        //string p/ impressao de num.ped
	aCodClas   := {}                        //array p/ cod.class.fiscal
	_nValExt   := 0
	aMenPad1   := {}                        //Array p/ codigo da msg. padrao do corpo da NF
	aMenPad2   := {}                        //Array p/ textos da msg. padrao do corpo da NF
	aMenPad3   := {}                        //Array p/ codigo da msg. padrao da Obs.
	aMenPad4   := {}                        //Array p/ textos da msg. padrao da Obs.

	cMens1     := ""
	aDupl      := {}                        //array p/ desdobramento de duplicatas
	nTD        := 22                        //num.de colunas p/ descricao do produto
	_cRedesp   := ""
	_cPedCli   := ""
	aPedCli    := {}
	_aPlPedido := {}
	_aKanBan   := {}
	aNotas     := {}
	_cCont     := "Z1"
	_nKy       := 0
	_nTotServ  := 0
	_nValISS   := 0
	aRedesp		:= {}
	aModelo		:= {}
	
	
	If LastKey () == 27 .or. nLastKey == 27 .or. nLastKey == 286
		lImpresso := .f.
		Return
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Prepara a array para impressao das Notas Fiscais de Saida.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbSelectArea ("SF2")           //cabecalho de N.F.
	dbSetOrder (1)                 //filial,documento,serie,cliente,loja
	dbSeek (xFilial ("SF2") + mv_par01 + mv_par03, .t.)  // Encontra a nota informada no parametro "De", ou a proxima caso exista.
	
	While ! eof () .and. F2_FILIAL == xFilial ("SF2") .and. F2_DOC <= mv_par02
		
		If F2_SERIE <> mv_par03
			dbSkip ()
			loop
		EndIf
		lOpca := .t.
		
		If ! Empty (SF2 -> F2_FIMP)
			lOpca := MsgBox ("Nota " + SF2 -> F2_DOC + "/" + SF2->F2_SERIE + " ja emitida. Deseja emiti-la novamente ?", "Atencao!!!", "YESNO")
		EndIf
		
		If lOpca == .t.
			aAdd (aNotas, SF2 -> F2_DOC)
		EndIf
		dbSkip ()
	EndDo
	
	If Len (aNotas) == 0
		MsgInfo ("Nao ha Notas Fiscais a imprimir para os parametros informados.","SCRNFS")
		Return
	EndIf
	
	If LastKey () == 27 .or. nLastKey == 27 .or. nLastKey == 286
		Return
	EndIf
	
	cNRel := SetPrint("SF2",cNRel,,cTitulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,cTamanho,,.T.)
	
	If LastKey () == 27 .or. nLastKey == 27 .or. nLastKey == 286
		Return
	EndIf
	
	SetDefault (aReturn, "SF2")
	
	If LastKey () == 27 .or. nLastKey == 27 .or. nLastKey == 286
		Return
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 00, 00 PSAY " "
	SetPrc (0, 0)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona Todos os Indices Necessarios                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea ("SA1")             //Clientes
	dbSetOrder (1)                 //filial,codigo,loja
	dbSelectArea ("SA3")             //Vendedores
	dbSetOrder (1)                 //filial,codigo
	dbSelectArea ("SA4")             //transportadoras
	dbSetOrder (1)                 //filial,codigo transport.
	dbSelectArea ("SB1")             //produtos
	dbSetOrder (1)                 //filial,codigo produto
	dbSelectArea ("SC5")             //Pedidos de Venda
	dbSetOrder (1)                 //filial, pedido
	dbSelectArea ("SC6")             //Itens dos Pedidos de Venda
	dbSetOrder (1)                 //filial, pedido, item
	dbSelectArea ("SD1")             //itens da NF de entrada
	dbSetOrder (1)                 //filial,doc,serie,fornece
	dbSelectArea ("SD2")             //itens de venda da NF
	dbSetOrder (3)                 //filial,doc,serie,cliente,loja,cod
	dbSelectArea ("SE1")             //contas a receber
	dbSetOrder (1)                 //filial,prefixo,num,parcela,tipo
	dbSelectArea ("SE4")             //cond.pagamento
	dbSetOrder (1)                 //filial,codigo
	dbSelectArea ("SF1")             //NF de Entrada
	dbSetOrder (1)                 //filial,doc,serie,cliente e loja
	dbSelectArea ("SF2")             //NF de Saida
	dbSetOrder (1)                 //filial,doc,serie,cliente e loja
	dbSelectArea ("SF4")             //tipos de entrada e saida
	dbSetOrder (1)                 //filial,codigo
	//dbSelectArea ("SZZ")             //mensagens
	//dbSetOrder (1)                 //filial,codigo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³                        PRINCIPAL                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For _nNotas := 1 to Len (aNotas)	// Loop para o numero de Notas Fiscais que atendem aos parametros.
		
		If LastKey () == 27 .or. nLastKey == 27 .or. nLastKey == 286
			@ 25, 01 PSAY "** CANCELADO PELO OPERADOR **"
			lContinua := .F.
			Exit
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa Variaveis p/ Nova NF                               ³
		//³ Ver Descricao das Variaveis no Trecho Define Variaveis        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_aNFDev     := {}
		aItens		:= {}
		aServ		:= {}
		aCodClas    := {}
		aMenSZZ     := {}
		aCFO        := {}
		aNatOper    := {}
		cNat        := ""
		cCFOP       := ""
		aNumPed     := {}                        // Array p/ numeros de nossos pedidos
		cNumPed     := ""                        // String p/ impressao de num.ped.
		aMensGer    := {}                        // Array para mensagens gerais (pedido)
		aMenPad1    := {}                        // Array p/ descr. de mensagem padrao do TES.
		aMenPad2    := {}                        // Array p/ textos das msg padrao do TES.
		_cEndEnt    := _cEndCob := space(80)            //endereco de entrega/cobranca
		_cMunCob    := ""                        //municipio de entrega/cobranca
		cMens1      :=  cComplE := cComp := ""
		cDesc1      := cDesc2 := ""
		_nValExt    := 0
		_cRedesp    := ""
		_cPedCli    := ""
		aPedCli     := {}
		_aPlPedido 	:= {}
		_aKanBan    := {}
		_cDescPr    := ""
		cNomEnt     := ""
		_cDesServ   := ""
		_nVlrIss    := 0
		_nKy        := 0
		aDupl       := {}                        //array p/ desdobramento de duplicatas
		_nPesoL     := 0
		_nTotServ   := 0
		_nValISS    := 0
		_dEmissao   := CToD("  /  /  ")
		_cChave     := ""
		_cEndEnt    := ""            //endereco de entrega
		_cCidEnt    := ""
		_cFoneEnt   := ""
		_cCepEnt    := ""
		_nDesc      := 0
		_nPerIrrf := 0
		_cCont      :=""
		_cClasFis   := ""
		_aClasFis   := {}
		_aContrat	:= {}
		_aLoteCtl	:= {}
		aRedesp		:= {}		
		aClFisIpi	:= {}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o SF2 - Cabecalho da Nota Fiscal de Saida              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//
		// ImpNFS - Informacoes tratadas na impressao da Nota Fiscal de Saida:
		// -------------------------------------------------------------------
		//
		// ** 1. Cabecalho / Rodape.
		// Numero, Serie, Emissao, Base de ICMS, Valor do ICMS, Base de ICMS Solidario, Valor de ICMS Solidario, Valor das Mercadorias,
		// Frete, Seguro, Despesas, IPI, Valor Bruto da NF, Volumes, Especie, Peso Bruto, Peso Liquido. Base de ISS, Valor do ISS.
		//
		// ** 2. Itens.
		// - Controle de impressao por item (um campo especifico indica se cada item deve ser impresso, ou nao, na NF).
		// - Alerta para produtos no SD2 que nao existam no SB1.
		// - Classificacao Fiscal (codigo na linha do item e descricao no campo de observacoes), CFOs e Naturezas de Operacao.
		// - Numero do Pedido de Venda.
		// - Linha de Detalhe: CodProd, Descr, ClasFis, SitTrib, UniMedida, Quant, PrcUnit, PrcTot, AliqIPI, ValIPI.
		//
		// ** 3. Mensagens.
		// - Mensagem da Nota, no Pedido de Venda (digitada pelo usuario na inclusao do pedido).
		// - Mensagem Padrao, no pedido de Venda (consulta ao cadastro especifico de mensagens, geralmente o SZZ).
		// - Mensagem Padrao, no TES. Podem ser tantas quanto necessario. O padrao e de quatro mensagens. (Cadastro de Mensagens)
		// - Mensagem Padrao, informada no cadastro de Produtos. (Cadastro de Mensagens)
		//
		// ** 4. Cliente / Fornecedor.
		// - As informacoes sao obtidas no cadastro correto, de clientes ou de fornecedores, apos avaliado o tipo do Pedido de Venda.
		// - Nome, Endereco de Cobranca, Bairro de Cobranca, CEP de Cobranca, Municipio de Cobranca, Estado de Cobranca,
		//   - CGC, Endereco, Bairro, CEP, Municipio, Estado, Telefone, Fax, Inscricao Estadual.
		//
		// ** 5. Transportadora.
		// - Nome, CGC, Endereco, Municipio, Estado, Inscricao Estadual.
		//
		// ** 6. Detalhamento de Duplicatas.
		// - Titulo, Parcela, Valor, Vencimento (Real).
		//
		// ** 7. Condicao de Pagamento
		// - Descricao (_cCondpag).
		
	//	cNota := Alltrim (aNotas [_nNotas])
		cNota := (aNotas [_nNotas])
		
		dbSelectArea ("SF2")
		dbSeek (xFilial("SF2") + cNota + mv_par03)	// Filial + Nota + Serie
		_cNumNF   := SF2 -> F2_DOC
		_cSerNF   := SF2 -> F2_SERIE
		_cTipoNF  := SF2 -> F2_TIPO
		_dEmissao := SF2 -> F2_EMISSAO
		_dDtSaida := SF2 -> F2_EMISSAO  // SF2 -> F2_XXDTSAI
		_cMarca   := ""  // SF2 -> F2_XXMARCA
		_cPlaca   := ""  // SF2 -> F2_XXPLACA
		_nBaseIcm := SF2 -> F2_BASEICM
		_nValIcm  := SF2 -> F2_VALICM
		_nBICMRet := SF2 -> F2_BRICMS
		_nVICMRet := SF2 -> F2_ICMSRET
		_nBaseISS := SF2 -> F2_BASEISS
		_nValISS  := SF2 -> F2_VALISS
		_nValMerc := SF2 -> F2_VALMERC
		_nValFret := SF2 -> F2_FRETE
		_nValSeg  := SF2 -> F2_SEGURO
		_nVlrDesp := SF2 -> F2_DESPESA
		_nValIPI  := SF2 -> F2_VALIPI
		_nValBrut := SF2 -> F2_VALBRUT
		_cVolu1   := SF2 -> F2_VOLUME1
		_cEspec1  := SF2 -> F2_ESPECI1
		_nPBruto  := SF2 -> F2_PBRUTO
		_nPLiqui  := SF2 -> F2_PLIQUI
		_cNumero  := "" //SF2 -> F2_XXNUMER
		
		_nValBrut  := SF2->F2_VALFAT          // Valor Total da Fatura
		If _nValBrut == 0
			_nValBrut := SF2->F2_VALMERC+SF2->F2_VALIPI+SF2->F2_SEGURO+SF2->F2_FRETE
		EndIf
//		_cRedesp	:= SF2->F2_XXREDES		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o SD2 - Itens da NF                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cKey := xFilial ("SD2") + SF2 -> F2_DOC + SF2 -> F2_SERIE
		dbSelectArea ("SD2")
		dbSeek (cKey)
		nPosReg := Recno ()                  //guarda posicao do 1§ item da NF
		_cCont := "A"
		cCompo := ""
		While ! eof () .and. D2_FILIAL + D2_DOC + D2_SERIE == cKey
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona o SB1 - Produtos                                 ³
			//³ E procura pelo Cod Clas Fiscal                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea ("SB1")
			if ! dbSeek (xFilial ("SB1") + SD2 -> D2_COD)
				msginfo ("O produto " + SD2 -> D2_COD + ", informado na NF " + SD2 -> D2_SERIE + "/" + SD2 -> D2_DOC + ", nao existe no cadastro de Produtos!","SCRNFS")
				dbSelectArea ("SD2")
				dbSkip ()
				loop
			endif
			
			If !Empty(SB1->B1_POSIPI)
				If Empty(SB1->B1_CLASFIS)
					nI := Ascan (_aClasFis, {|X|Alltrim(X[1]) == Alltrim(SB1 -> B1_POSIPI)})
					If nI == 0 								              // Posicao IPI nao existente
						aAdd (_aClasFis, {Alltrim(B1_POSIPI), _cCont})    // Adiciona Posicao IPI ao Array
						_cCont := Soma1 (_cCont)
						_nKy := _nKy + 1
						_cClasFis := _aClasFis [_nKy, 2]
					Else
						_cClasFis := _aClasFis [nI, 2]
					EndIf
				Else
					_cClasFis := Alltrim(SB1->B1_CLASFIS)
					
					
					SF4->(dbSetOrder(1))
					If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))					
						nI := ASCAN(aClFisIpi, {|X|Alltrim(X[1]) == Alltrim(SF4->F4_SITTRIB+SB1->B1_POSIPI)})						
						If nI == 0 
							AADD(aClFisIpi,{SF4->F4_SITTRIB+SB1->B1_POSIPI,SF4->F4_SITTRIB,SB1->B1_POSIPI})  
						EndIf						
					Endif
				Endif
				

			Endif
			
			
			dbSelectArea ("SC6")
			dbSeek (xFilial ("SC6") + SD2 -> D2_PEDIDO + SD2 -> D2_ITEMPV)

			dbSelectArea("SA7")			//Cliente x Produto
			dbsetorder(1)
			dbseek (xFilial("SA7") + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_COD)
			//Preenche item com Codigo e Descrição do Cliente
			_cCodProd:= Alltrim (SA7 -> A7_CODCLI)
			_cDescPr := Alltrim (SA7 -> A7_DESCCLI)
		
			// Buscar código do Fornecedor para Utilizar na Devolução de Remessa
			// Utilizar quando for Retorno de Industrializacao e/ou Retorno de Embalagem
			// Verificada ocorrência qdo !Empty(D2_NFORI)
			_cCodForn := ""
			_cDesForn := ""
			If !Empty(SD2->D2_NFORI)
				SA5->(DbSetOrder(1))
				SA5->(DbGoTop())
				If SA5->(DbSeek(xFilial("SA5") + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_COD))
					_cDescPr := SA5->A5_NOMPROD
					_cCodProd:= IF (!Empty(_cCodProd), _cCod_Prod, SA5->A5_CODPRF)

					_cCodForn := SA5->A5_CODPRF
					_cDesForn := SA5->A5_NOMPROD
				Endif
			Endif

			_nQuant  := 0
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona o SF4 - TES                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea ("SF4")
			dbSeek (xFilial ("SF4") + SD2 -> D2_TES)
			_cSitrib := Substr (SB1 -> B1_ORIGEM, 1, 1)+SF4->F4_SITTRIB
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o CFO ja foi considerado.                      ³
			//³ Se for novo CFO, le TES e complementa string com CFOs.     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nI := Ascan (aCFO, Alltrim (SD2 -> D2_CF))
			
			If nI == 0
				aAdd (aCFO, Alltrim (SD2 -> D2_CF))
				dbSelectArea ("SF4")
				dbSeek (xFilial ("SF4") + SD2 -> D2_TES)
				_nTemNat := aScan (aNatOper, Alltrim (SF4 -> F4_TEXTO))
				if _nTemNat == 0
					aAdd (aNatOper, Alltrim (SF4 -> F4_TEXTO))
				endif
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Preenche array dos Itens da N.F.                                                         ³
			//³ Estrutura do array de Itens da NF aItens[n][m]                                           ³
			//³ n = numero do item                                                                       ³
			//³ m = CodProd, Descr, ClasFis, SitTrib, UniMedida, Quant, PrcUnit, PrcTot, AliqIPI, ValIPI ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			dbSelectArea ("SD2")
			_cCodProd := If(Empty(_cCodProd), Alltrim(SD2 -> D2_COD), _cCodProd)
			_cUM      := SD2 -> D2_UM
			_nQuant   := SD2 -> D2_QUANT
			_nDesc    := 0 // (SD2 -> D2_DESCON * 100) / SD2 -> D2_TOTAL  (solicitação Marcos Freitas em 06/06/03
			_nPesoL   := SD2 -> D2_QUANT * SD2 -> D2_PESO
//			_cDescPr  := If(Empty(_cDescPr), If(SB1->(FieldPos("B1_XXPROCL"))>0, SB1->B1_XXPROCL, SB1->B1_DESC), _cDescPr)
			_cDescPr  := If(Empty(_cDescPr),SB1->B1_DESC, _cDescPr)
			_TipoProd := SB1->B1_TIPO
			cModelo		:= ""  // SB1->B1_XXMOD
			
			If ascan(_aLoteCtl, SD2->D2_LOTECTL) == 0 .and. !Empty(SD2->D2_LOTECTL)
				aadd(_aLoteCtl, SD2->D2_LOTECTL)
			Endif
			
			If _TipoProd == "CO" .and. Ascan(aCFO, Alltrim ("5902")) > 0
				//Possui Componente e NF industrializacao
				//Prepara string mensagem com componentes
				//Codigo/Nf.Original+SerieOriginal/Valor Total
				//Esses componentes são impressos como mensagem e não como item da NF.
				If !Empty(cCompo)
					cCompo += " / "
				Endif
				cCompo += Alltrim(If(Empty(_cCodForn), _cCodProd, _cCodForn)) + " " + Alltrim(SD2->D2_NFORI) + "-" + Alltrim(SD2->D2_SERIORI) + " " + Alltrim(Transform(_nQuant, "@E 99,999.99")) + " R$ " + Alltrim(Transform(SD2->D2_PRCVEN, "@E 99,999,999.99")) +" Tot.R$ " + Alltrim(Transform(SD2->D2_TOTAL, "@E 99,999,999.99"))
			Else
				If Empty(D2_CODISS) .and. _TipoProd <> "MO" 
					If !(_cTipoNF $ "I/P")                  
					
/*						If (nPos :=Ascan(aModelo,(SB1->B1_XXMOD+SB1->B1_POSIPI+Str(SB1->B1_IPI)+Str(SC6->C6_PRCVEN))))> 0 
							lAglutina	:= .T.
						Else                    
							AADD(aModelo,SB1->B1_XXMOD+SB1->B1_POSIPI+Str(SB1->B1_IPI)+Str(SC6->C6_PRCVEN))
							lAglutina	:= .F.
						EndIf
						
						If lAglutina
							aItens[nPos][6] += _nQuant													
							aItens[nPos][8] += SD2->D2_TOTAL
							aItens[nPos][11] += SD2->D2_VALIPI
						Else				*/
					    	//Código nao encontrado. Adiciona novo ao vetor.*/
							AAdd (aItens, {_cCodProd          ; 	// 1
							,  _cDescPr                         ; 	// 2
							,  _cClasFis	                   ; 	// 3
							,  _cSiTrib                         ; 	// 4
							,  If(!(SF2->F2_TIPO $ "IPC"),_cUM     , " ");	// 5
							,  If(!(SF2->F2_TIPO $ "IPC"),_nQuant  , 0  );	// 6
							,  If(!(SF2->F2_TIPO $ "IPC"),D2_PRCVEN,0); 	// 7
							,  If(!(SF2->F2_TIPO $ "IP"),D2_TOTAL ,0); 	// 8           
							,  D2_PICM  						; 	// 9               
							,  D2_IPI                           ; 	// 10
							,  D2_VALIPI                        ; 	// 11
							,  SB1->B1_PESO                     ; 	// 12
							,  _nDesc                           ; 	// 13
							,  SB1->B1_TIPO						;	// 14
							, SD2->D2_NFORI						; 	//15
							, SD2->D2_SERIORI					; 	//16
							, _cCodForn							;	// 17 - Código do produto no Fornecedor
							, _cDesForn							;	// 18 - Descricao do Produto no Fornecedor
							})
//						EndIf
					Endif
				Else
					AAdd (aServ, {_cDescPr    ;    // 1
					, _cUM        ;    // 2
					, _nQuant       ;    // 3
					, SD2->D2_PRCVEN;    // 4
					, SD2->D2_TOTAL ;    // 5
					})
					
					_nTotServ  := _nTotServ + SD2->D2_TOTAL // Acumula se necessario o total do iss
				EndIf
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o Pedido ja Foi Considerado                    ³
			//³ Se For Novo Pedido, Complementa String com Pedidos, Le     ³
			//³    Pedidos, Soma Volumes, Mensagens, Loja de Entrega       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nI := Ascan (aNumPed, SD2 -> D2_PEDIDO)
			
			If nI == 0          // Novo pedido.
				aAdd (aNumPed, SD2 -> D2_PEDIDO)

				cNumPed += If(!Empty(cNumPed), "-", "") + Alltrim (SD2 -> D2_PEDIDO)

				dbSelectArea ("SC6")
				dbSeek (xFilial ("SC6") + SD2 -> D2_PEDIDO + SD2 -> D2_ITEMPV)
				_nPedCli := aScan (aPedCli, Alltrim(SC6 -> C6_PEDCLI))
				if _nPedCli == 0 .and. !Empty(SC6 -> C6_PEDCLI)
					aAdd (aPedCli, Alltrim(SC6 -> C6_PEDCLI))
					If Empty(_cPedCli)
						_cPedCli := Alltrim(SC6 -> C6_PEDCLI)
					Else
						_cPedCli := _cPedCli + " / " + Alltrim(SC6 -> C6_PEDCLI)
					EndIf
				endif

				dbSelectArea ("SC5")
				dbSeek (xFilial ("SC5") + SD2 -> D2_PEDIDO)

				If ! Empty (SC5 -> C5_MENNOTA)
					AADD(aMenPad4,Alltrim(SC5 -> C5_MENNOTA))
				EndIf

			EndIf
			
			// Atribui numero de Pedido do Cliente
			dbSelectArea ("SC6")
			dbSeek (xFilial ("SC6") + SD2 -> D2_PEDIDO + SD2 -> D2_ITEMPV)
			_nPedCli := aScan (aPedCli, Alltrim(SC6 -> C6_PEDCLI))
			if _nPedCli == 0 .and. !Empty(SC6 -> C6_PEDCLI)
				aAdd (aPedCli, Alltrim(SC6 -> C6_PEDCLI))
				If Empty(_cPedCli)
					_cPedCli := SC6 -> C6_PEDCLI
				Else
					_cPedCli := _cPedCli + " / " + Alltrim(SC6 -> C6_PEDCLI)
				EndIf
			endif

			// Verifica nota fiscal de devolução ou poder de terceiro
			if ! empty(SD2->D2_NFORI)
				
				if ! empty(SD2->D2_IDENTB6)
					// Poder de Terceiro - captura data de emissão e valor
					if ! empty(posicione("SB6", 1, xfilial("SB6") + SD2->D2_COD + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_IDENTB6, "B6_PRODUTO"))
						aadd(_aNFDev, {SD2->D2_NFORI + SD2->D2_SERIORI + SD2->D2_CLIENTE + SD2->D2_LOJA, SB6->B6_EMISSAO, SD2->D2_TOTAL,"B"})
					endif
					
				else                                                                        
					If SD2->D2_TIPO $ "I/P/C"//Se for Nota Fiscal de Complemento de ICMS ,IPI ou Preço
							aadd(_aNFDev, {SD2->D2_NFORI + SD2->D2_SERIORI + SD2->D2_CLIENTE + SD2->D2_LOJA, SD1->D1_EMISSAO, SD2->D2_TOTAL,SD2->D2_TIPO})					
							If SD2->D2_TIPO == "I"              //Complemento de ICMS
								nRecSF2	:= SF2->(Recno())	
								SF2->(dbSetOrder(1))
								If SF2->(dbSeek(xFilial("SF2")+SD2->D2_NFORI + SD2->D2_SERIORI))
									_nBaseIcm	:= SF2 -> F2_BASEICM
								Endif                    
								SF2->(dbGoto(nRecSF2))
							    _nValMerc	:= 0 								
							ElseIf SD2->D2_TIPO == "P" //Complemento de IPI          
								If SC5->C5_TIPOCLI == "F" 
									_nBaseIcm	:= SF2->F2_BASEICM
									_nValIcm	:= SF2->F2_VALICM
								Else                
									_nBaseIcm	:= 0             
									_nValIcm	:= 0
							    EndIf 
							    _nValMerc	:= 0             
//					    _nValBrut	:= 0                      
							    _nValIPI	:= SF2->F2_VALMERC						    
							EndIf							
					Else
						// Verifica nota de devolução - sem poder de terceiro					
						if ! empty(posicione("SD1", 1, xfilial("SD1") + SD2->D2_NFORI + SD2->D2_SERIORI + SD2->D2_CLIENTE + SD2->D2_LOJA, "D1_DOC"))
							aadd(_aNFDev, {SD2->D2_NFORI + SD2->D2_SERIORI + SD2->D2_CLIENTE + SD2->D2_LOJA, SD1->D1_EMISSAO, SD2->D2_TOTAL,"D"})
						endif
					EndIF					
				endif
				
			endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se Msg Padrao Ja Foi Considerada               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_cMens  := ""
			_mTMens := 0
			
			
			dbSelectArea ("SD2")
			dbSkip ()
		EndDo
		
		Go nPosReg                          //reposiciona no primeiro item da NF
		
		//Verifica todas as mensagens fiscais gravadas para a nota fiscal
        /*
		dbSelectArea("SZZ")
		dbsetorder(1)
		dbgotop()
		dbSeek(xFilial("SZZ")+"S"+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
		While !Eof() .and. SZZ->ZZ_TIPODOC == "S"  .and.;
			SZZ->ZZ_DOC     == SF2->F2_DOC         .and.;
			SZZ->ZZ_SERIE   == SF2->F2_SERIE       .and.;
			SZZ->ZZ_CLIFOR  == SF2->F2_CLIENTE     .and.;
			SZZ->ZZ_LOJA 	== SF2->F2_LOJA

			If SZZ->ZZ_SEQMENS <= "03"			//Mensagens do corpo da nota fiscal
				nI := Ascan(aMenPad1,SZZ->ZZ_CODMENS+SZZ->ZZ_SEQMENS)
				If nI == 0
					_cMens  := AllTrim(SZZ->ZZ_TXTMENS)
					If !Empty(_cMens)
						AADD(aMenPad1,SZZ->ZZ_CODMENS+SZZ->ZZ_SEQMENS)
						AADD(aMenPad2,Alltrim(_cMens))
					Endif
				EndIf
			Else          						//Mensagens da Observação
				nI := Ascan(aMenPad3,SZZ->ZZ_CODMENS+SZZ->ZZ_SEQMENS)
				If nI == 0
					_cMens  := AllTrim(SZZ->ZZ_TXTMENS)
					If !Empty(_cMens)
						AADD(aMenPad3,SZZ->ZZ_CODMENS+SZZ->ZZ_SEQMENS)
						AADD(aMenPad4,Alltrim(_cMens))
					Endif
				EndIf			
			EndIf     
			
			dbSkip()
		End
		*/
		
		dbSelectArea ("SC5")
		dbSetOrder (1)
		dbSeek (xFilial ("SC5") + SD2 -> D2_PEDIDO)
		_cTpFrete   := SC5 -> C5_TPFRETE
		_cNumPed    := SC5 -> C5_NUM
		_dDatPed    := SC5 -> C5_EMISSAO
	
		
		If !lContinua
			Exit
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona SA1 (Cliente) ou SA2 (Fornecedor)                   ³
		//³ Verifica se NF Devolucao ou Beneficiamento                    ³
		//³ Preencher os campos de endereco de cobranca nas variaveis     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If _cTipoNF $ "D;B" //nf de devolucao/remessa->fornecedor
			dbSelectArea ("SA2")
			dbSetOrder (1)
			dbSeek (xFilial ("SA2") + SD2 -> D2_CLIENTE + SD2 -> D2_LOJA)
			cNomEnt  := Alltrim (A2_NOME)
			_cEndEnt := Alltrim (A2_END)
			_cCepEnt := Alltrim (A2_CEP)
			_cCidEnt := Alltrim (A2_MUN)
			_cEstEnt := A2_EST
			_cTelEnt := A2_TEL
			        
			_cCodCli  := SA2->A2_COD
			_cNomCli  := SA2 -> A2_NOME //+ " (" + SA2->A2_COD+"/"+SA2->A2_LOJA+")"
			_cCGCCli  := SA2 -> A2_CGC
			_cEndCli  := SA2 -> A2_END
			_cBaiCli  := SA2 -> A2_BAIRRO
			_cCEPCli  := SA2 -> A2_CEP
			_cMunCli  := SA2 -> A2_MUN
			_cTelCli  := If(!Empty(SA2->A2_DDD), "(" + Alltrim(SA2->A2_DDD) + ")", "") + SA2 -> A2_TEL
			_cEstCli  := SA2 -> A2_EST
			_cInsCli  := SA2 -> A2_INSCR
			
		Else
			
			dbSelectArea ("SA1")       //cad endereco cobranca
			dbSetOrder (1)
			dbSeek (xFilial ("SA1") + SD2 -> D2_CLIENTE + SD2 -> D2_LOJA)
			If !Empty(A1_ENDCOB)
				_cEndCob := Alltrim (A1_ENDCOB)
				_cEndCob := _cEndCob + " - " + Alltrim (A1_BAIRROC) + ", CEP: " + Alltrim (A1_CEPC)
				_cEndCob := _cEndCob + " " + Alltrim (A1_MUNC) + " - " + A1_ESTC
			EndIf
			
			If !Empty(A1_ENDENT)
				_cEndEnt := Alltrim (A1_ENDENT)
			Endif
			
			If !Empty(A1_MUNE)
				_cEndEnt := _cEndEnt + " "+Alltrim (A1_MUNE)
			EndIf
			
			If !Empty(A1_ESTE)
				_cEndEnt := _cEndEnt + "-" + A1_ESTE
			EndIf
			
			If !Empty(A1_CEPE)
				_cEndEnt := _cEndEnt + " CEP: " + Alltrim (A1_CEPE)
			EndIf
			
			_cCodCli  := SA1 -> A1_COD
			_cNomCli  := AllTrim(SA1 -> A1_NOME) //+ " (" + SA1->A1_COD+"/"+SA1->A1_LOJA+")"
			_cCGCCli  := SA1 -> A1_CGC
			_cEndCli  := SA1->A1_END
			_cBaiCli  := SA1->A1_BAIRRO
			_cCEPCli  := SA1->A1_CEP
			_cMunCli  := SA1->A1_MUN
			_cEstCli  := SA1->A1_EST
			_cTelCli  := If(!Empty(SA1->A1_DDD), "(" + Alltrim(SA1->A1_DDD) + ")", "") + AllTrim(SA1 -> A1_TEL)
			If !Empty(SA1->A1_INSCR) //Rodrigo Oliveira
			_cInsCli  := SA1 -> A1_INSCR
			Else
			_cInsCli  := SA1 -> A1_INSCRUR
			EndIf 
		EndIf
		
		dbSelectArea ("SA1")
		dbSeek (xFilial("SA1")+SD2->D2_CLIENTE+SD2->D2_LOJA)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o SA3 Para Buscar o vendedor                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea ("SA3")
		dbSeek (xFilial ("SA3") + SC5 -> C5_VEND1)
		_cNomeVen := SA3->A3_NOME
		_cCodVen  := SA3->A3_COD

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o SA4 Para Buscar o Redespacho                      ³
/*		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SF2->F2_REDESP)
			dbSelectArea ("SA4")
			If dbSeek (xFilial ("SA4") + SF2->F2_REDESP )
				
				_cNomRed := "REDESPACHO: "+ AllTrim(SA4 -> A4_NOME )
				If !Empty(SA4 -> A4_END)
					_cNomRed := _cNomRed + " "+ AllTrim(SA4 -> A4_END) +" "+ AllTrim(SA4 -> A4_MUN)+ " / "+SA4 -> A4_EST
				EndIf
				If !Empty(SA4 -> A4_CEP)
					_cNomRed := _cNomRed + " CEP: "+ AllTrim(SA4 -> A4_CEP)
				EndIf
				If !Empty(SA4 -> A4_TEL)
					_cNomRed := _cNomRed + " F.: "+AllTrim(SA4 -> A4_TEL)
				EndIf
				If !Empty(SA4 -> A4_CGC)
					_cNomRed := _cNomRed + " CGC: " +SA4 -> A4_CGC
				EndIf
				
				AADD(aMenPad2,Alltrim(_cNomRed))
			EndIf
		EndIf
*/		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o SA6 Para Buscar o Banco                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA6")
		dbSeek(xFilial("SA6")+SC5->C5_BANCO)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o SA4 Para Buscar a Transportadora e Redespacho     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea ("SA4")
		dbSeek (xFilial ("SA4") + SF2 -> F2_TRANSP)
		_cNomTra := SA4 -> A4_NOME
		_cCGCTra := SA4 -> A4_CGC
		_cEndTra := ALLTRIM(SA4 -> A4_END) + " - " + ALLTRIM(SA4->A4_BAIRRO)
		_cMunTra := SA4 -> A4_MUN
		_cEstTra := SA4 -> A4_EST
		_cInETra := SA4 -> A4_INSEST
		_cTelTra := If(!Empty(SA4->A4_DDD), "(" + SA4->A4_DDD + ")", "") + SA4->A4_TEL
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Mensagem de devolução de nota fiscal (c/ ou s/ poder terceiro) ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// ------------------------------------------------------------------------------------
		// Mensagem de devolução de nota fiscal (com ou sem poder de terceiro)
		if ! empty(_aNFDev)
			//_cStr := "RETORNO REF.S/NF: "
			
			for _nSeq := 1 to len(_aNFDev)
				If _aNFDev[_nSeq,4] == "B"
					_cStr := "Retorno da NF "+SubStr(_aNFDev[_nSeq,1],1,6)+"/"+AllTrim(SubStr(_aNFDev[_nSeq,1],7,3))
					_cStr += " de "+Dtoc(_aNFDev[_nSeq,2])
				ElseIf _aNFDev[_nSeq,4] == "D"
					_cStr := "Devolucao da NF "+SubStr(_aNFDev[_nSeq,1],1,6)+"/"+AllTrim(SubStr(_aNFDev[_nSeq,1],7,3))
					_cStr += " de "+Dtoc(_aNFDev[_nSeq,2])
				ElseIf  _aNFDev[_nSeq,4] == "I"	//Complemento de ICMS
					_cStr := "NF de Complemento de ICMS ref. NF "+SubStr(_aNFDev[_nSeq,1],1,6)+"/"+AllTrim(SubStr(_aNFDev[_nSeq,1],7,3))
					_cStr += " de "+Dtoc(_aNFDev[_nSeq,2])				
				ElseIf  _aNFDev[_nSeq,4] == "P"	//Complemento de IPI			
					_cStr := "NF de Complemento de IPI ref. NF "+SubStr(_aNFDev[_nSeq,1],1,6)+"/"+AllTrim(SubStr(_aNFDev[_nSeq,1],7,3))
					_cStr += " de "+Dtoc(_aNFDev[_nSeq,2])								
				ElseIf  _aNFDev[_nSeq,4] == "C"	//Complemento de Preço
					_cStr := "NF de Complemento de Preço ref. NF "+SubStr(_aNFDev[_nSeq,1],1,6)+"/"+AllTrim(SubStr(_aNFDev[_nSeq,1],7,3))
					_cStr += " de "+Dtoc(_aNFDev[_nSeq,2])													
				EndIf
				_nTMens := mlcount(_cStr, 60)
				aadd(aMenPad4, memoLine(_cStr, 60, 1))
				for _nI := 2 to _nTMens
					aadd(aMenPad4, memoline(_cStr, 60, _nI))
				next
			next
			
		endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Armazena pedido do cliente para ser impres. em dados adicion. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aPedCli) > 0
			_cPedCli := IIf(Len(aPedCli) == 1,"Pedido : ", "Pedidos : ")+_cPedCli
			aadd(aMenPad4, _cPedCli)
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona o SE4 Para Buscar a Condicao de Pagamento           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea ("SE4")
		dbSeek (xFilial ("SE4") + SF2 -> F2_COND)
		_cCondPag := SE4 -> E4_DESCRI
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona o SE1 - Contas a Receber                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Estrutura do array de Duplicatas aDupl [n] [m]
		// n = numero do item (maximo 6 duplicatas por NF)
		// m = Numero, Valor e Vencimento
		
		//Inicializa aDupl (8 vezes)
		aDupl := {}
		
		nDup    := 0
		_nIrrf  := 0
		_nTotDup := 0
		cKey    := xFilial ("SE1") + SF2 -> F2_SERIE + SF2 -> F2_DOC
		
		DbSelectArea ("SE1")
		DbSetOrder (1)
		DbSeek (cKey)
		
		cParcela := SE1 -> E1_PARCELA
		
		While ! eof() .and. E1_FILIAL + E1_PREFIXO + E1_NUM == cKey
			If SubStr (SE1 -> E1_TIPO, 1, 2) == "NF"
				aadd(aDupl, {SE1->E1_NUM+"/"+SE1->E1_PARCELA, SE1->E1_VALOR, SE1->E1_VENCTO})
			EndIf
			_nTotDup += E1_VALOR
			If SubStr(SE1->E1_TIPO,1,3) == "IR-"
				_nIrrf :=  _nIrrf + E1_VALOR
			EndIf
			
			DbSkip ()
		EndDo
		
		//Pesquisa pelo ercentual de Irrf
		If !Empty(_nIrrf)
			If !Empty(SA1->A1_NATUREZ)
				dbSelectArea("SED")
				dbSeek(xFilial("SED")+SA1->A1_NATUREZ)
				_nPerIrrf := If(SED->ED_CALCIRF == "1",SED->ED_PERCIRF,0)
			Else
				_nPerIrrf :=  GetMv("MV_ALIQIRF")
			EndIF
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega variaveis para impressao de ISS                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_nVlrIss  := _nVlrIss + SF2->F2_VALISS   // Acumula o vlr iss
		
		If !lContinua
			Exit
		Endif
		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³                                                               ³
		//³                          IMPRESSAO                            ³
		//³                                                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ScCabRod()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao dos itens da NF - Materiais.                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nLin      := 20
		_nContLi  := 0
		_lImpCont := .f.
		_xP := 0
		lFlag_CO := .F.			//Flag indicando se existem componentes e se CFOP 5902
		For nK := 1 To Len (aItens)
	
			If _lImpCont
				@ nLin, 002 PSAY "-cont."             					    // Codigo do Produto
				@ nLin, 015 PSAY MemoLine (aItens [nK-1, 02],55, _nImpCont+1, .T.) Picture "@!S55"  // Descr. Prod
			EndIf
			
			If _nContLi >= 25
				ImpAster()
				_xP := _xP + 1
				SCCabRod()
				_nContLi := 0
				nLin     := 20
			EndIf
			_nTamItem := MLCount (Alltrim (aItens [nK, 02]),55, , .T.)
			
			If _nTamItem >= 1    // Com quebra de item para impressao da descricao.
				For _nY := 1 To _nTamItem
					If _nY == 1
					               				
						@ nLin, 002 PSAY Alltrim(aItens [nK, 1])                     Picture "@!" // Codigo do Produto
						@ nLin, 015 PSAY MemoLine (Alltrim(aItens [nK, 02]),55, _nY, , .T.) // Descr. Prod
//						@ nLin, 074 PSAY aItens [nK, 03]                    Picture "!"        // Clas. Fisc.
//						@ nLin, 080 PSAY aItens [nK, 04]                    Picture "!!!"               // Sit. Trib.
						@ nLin, 104 PSAY aItens [nK, 05]                    Picture "!!"                // Unidade
						@ nLin, 110 PSAY aItens [nK, 06]                    Picture "@E 999,999"      // Quantidade
						@ nLin, 120 PSAY aItens [nK, 07]                    Picture "@E 999,999.9999"     // Vlr Unit
						@ nLin, 135 PSAY aItens [nK, 08]                    Picture "@E 999,999,999.99"    // Vlr Tot
//						@ nLin, 143 PSAY aItens [nK, 09]                    Picture "99"                // % ICM
//						@ nLin, 148 PSAY aItens [nK, 10]                    Picture "99"                // % IPI
//				    	@ nLin, 152 PSAY aItens [nK, 11]                    Picture "@E 9,999.99"     // Vlr Tot IPI
					Else
						@ nLin, 002 PSAY "-cont."
						@ nLin, 015 PSAY MemoLine (aItens [nK, 02],55, _nY) Picture "@!S55"             // Descr. Prod
					Endif
					nLin := nLin + 1
					_nContLi++
					_lImpCont := .f.
					_nImpCont := 0

					If (_nY < _nTamItem) .and. _nContLi >= 25
						_lImpCont := .t.
						_nImpCont := _nY
					EndIf
					
				Next
			Endif
		Next
		nLin++

		//Verifica se há espaço para impressão das mensagens 1 e 2 e Diversas no corpo da NF
		If _nContLi >= 25
			ImpAster()
			_xP := _xP + 1
			SCCabRod()
			_nContLi := 0
			nLin     := 20
		EndIf
		
		//Verifica se NF Devolucao e emite mensagens "Devolucao Ref.NF(s): " xxxxx
/*		IF !Empty(_aNfDev) .and. Empty(cCompo)
			cAuxStr := "Devolucao Ref.NF(s): "
			For iAux := 1 to Len(_aNfDev)
				cAuxStr += Alltrim(Substr(_aNfDev[iAux][1], 1, 6)) + "-" + Alltrim(Substr(_aNfDev[iAux][1], 7, 3))
				cAuxStr += " " + Alltrim(dToc(_aNFDev[iAux][2])) + " R$ " + Alltrim(Transform(_aNfDev[iAux][3], "@E 999,999.99")) + If(iAux < Len(_aNfDev), " / ", " ")
			Next iAux
			For iAux := 1 to MlCount(Alltrim(cAuxStr), 130, , .T.)
				@ nLin, 003 Psay MemoLine(Alltrim(cAuxStr), 130, iAux, , .T.)
				nLin++
			Next iAux
		Endif*/

		For iAux := 1 to Min(Len(aMenPad2), 25 - _nContLi)		
			For iAux1 := 1 to Len(aMenPad2[iAux]) STEP 140
				@ nLin, 02 PSay SUBSTR(Alltrim(aMenPad2[iAux]),iAux1,140)
				nLin++
			Next iAux1
		Next iAux
        
		aMenPad2	:= {}
		ImpRodape()                  
		
		
		//Grava o Flag de Impressao
		dbSelectArea("SF2")
		RecLock("SF2",.F.)
		SF2->F2_FIMP := "T"
		MsUnlock()
		
	Next

	nLin := 000
	@ nLin,000 PSAY ""
	SetPrc(0,0)

	
	nLin := 0
	dbSelectArea("SF2")
	If lContinua
		SetPgEject(.F.)
		If aReturn[5] == 1           //relatorio em tela
			Set Printer To
			dbcommitAll()
			ourspool(wNrel)
		EndIf
		MS_FLUSH()
	EndIf
	lImpresso := .f.
	
EndDo

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³SCCABROD  º Autor ³ Adriana Buscarini   º Data ³  05/08/04  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Imprime Cabecalho da nota onde as mensagens serao impressasº±±
±±º          ³ no rodape                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function SCCabRod()
Local _cEndEmp:= _cCidEmp:=_cTelEmp:=Space(75)
Local _cCepEmp:=_cHomePg:=_cEmail:=Space(75)

nLin := 0

_cEndEmp := " " //AllTrim(SM0->M0_ENDCOB)+" - "+AllTrim(SM0->M0_BAIRCOB)
_cCidEmp := " " //AllTrim(SM0->M0_CIDCOB)+" - "+ SM0->M0_ESTCOB+" CEP: "+SM0->M0_CEPCOB
_cTelEmp := " " //"FONE: "+AllTrim(SM0->M0_TEL)+" - FAX: "+AllTrim(SM0->M0_FAX)
_cHomePg := " " //Home Page: www.teste.com.br"
_cEmail  := " " //"E-mail: seiva@seivaagro.com.br"

nLin := 1

@ nLin, 0 PSAY Chr(15)                // Compressao de Impressao

nLin += 3

//@ nLin, 105 PSAY "XX"                // X
//@ nLin, 150 PSAY _cNumNF               // Numero da Nota Fiscal

nLin := 8

_cCFO := ""
For _nCont := 1 to Min(Len (aCFO), 2)
	_cCFO := _cCFO + aCFO [_nCont]
	if _nCont < len (aCFO)
		_cCFO := _cCFO + "/"
	endif
next

_cNat := ""
for _nCont := 1 to Min(len(aNatOper), 2)
	_cNat := _cNat + aNatOper [_nCont]
	if _nCont < len (aNatOper)
		_cNat := _cNat + "/"                      
	endif
next

//@ nLin, 004 PSAY substr (_cNat, 1, 40)
//@ nLin, 053 PSAY _cCFO Picture "@R 9.999"
//@ nLin, 035 PSAY " " 		//Reservado Substituto Tributario

//nLin := nLin + 3
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do cliente ou fornecedor - Parte 1                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(_cNomCli)
	@ nLin, 002 PSAY Alltrim(_cNomCli)
EndIf
If Len (Alltrim (_cCGCCli)) > 11
	@nLin, 105 PSAY _cCGCCli Picture "@R 99.999.999/9999-99"
Else
	@nLin, 105 PSAY _cCGCCli Picture "@R 999.999.999-99"
EndIf
@ nLin, 150 PSAY _dEmissao

nLin := nLin + 2
If !Empty(_cEndCli)
	@ nLin, 002 PSAY _cEndCli
EndIf
If !Empty(_cBaiCli)
	@ nLin,078 PSAY Substr (_cBaiCli, 1, 27) Picture "@!S27"
EndIf
If !Empty(_cCEPCli)
	@ nLin, 123 PSAY Substr (_cCEPCli, 1, 5) + "-" + Substr (_cCEPCli, 6, 3)
EndIf
@ nLin, 150 PSAY _dDtSaida

nLin := nLin + 2
If !Empty(_cMunCli)
	@ nLin, 002 PSAY _cMunCli 	    Picture "@!S30"
EndIf
If !Empty(AllTrim(_cTelCli))
	@ nLin, 060 PSAY AllTrim(_cTelCli)  Picture "@!S25"
EndIf
If !Empty(_cEstCli)
	@ nLin, 093 PSAY _cEstCli       Picture "!!"
EndIf
If !Empty(_cInsCli)
	@ nLin, 105 PSAY _cInsCli Picture "@R 999.999.999.999"
EndIf

nLin := nLin + 3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime dados da Fatura no campo Fatura                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//aColsDup := {10, 40, 55, 85, 100, 115}   
aColsDup := {27, 45, 75, 95, 120, 150}   
nColDup := 1                     

For _nSeq := 1 to Len(aDupl)

	@ nLin, aColsDup[nColDup]		PSay aDupl[_nSeq][1]  // numero
	@ nLin, aColsDup[nColDup+1]		PSay aDupl[_nSeq][2] picture "@E 99,999,999.99" // valor do titulo	
	@ nLin, aColsDup[nColDup+2]		PSay aDupl[_nSeq][3]  // vencimento
	                               
	If nColDup == 1
		nColDup += 3
	Else
	   nColDup := 1
		nLin++	   
	EndIf          
	
Next


Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³IMPRODAPE º Autor ³ AP7 IDE            º Data ³  05/08/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Imprime rodape da nota.                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ImpRodape()

Local cMensagem	:= "" 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valor dos impostos.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLin := 47               

For iAux := 1 to Len(aMenPad4)    
	For iAux1 := 1 to Len(aMenPad4[iAux]) STEP 080
		cMensagem += SUBSTR(Alltrim(aMenPad4[iAux]),iAux1,080)
	Next iAux1
Next iAux          

nTamMsg      := mlcount(cMensagem,80)
If !Empty(cMensagem)
	@ nLin,02 PSAY MemoLine(cMensagem,80,1)			
Endif
@ nLin, 140 PSAY _nValMerc Picture "@E 999,999,999.99" // Total do Servico
nLin++              

If nTamMsg > 1                                                                        
	For nS :=2 to 5
		@ nLin,02 PSAY MemoLine(cMensagem,80,nS)	
		nLin++               				
	Next          
EndIF

@ 051, 140 PSAY _nValBrut Picture "@E 999,999,999.99" // Valor Total da Nota

/*If nTamMsg > 5 
	For nS :=5 to 6
		@ nLin,02 PSAY MemoLine(cMensagem,80,nS)	
		nLin++               				
	Next          
EndIF*/

                                 
aMenPad4	:= {}
cMensagem	:= ""                         
                         
nLin := 66               
//@ nLin, 010 PSAY  _cNumNF

//nLin := 75               
@ nLin, 000 PSAY ""

SetPrc(0,0)

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³IMPASTER  º Autor ³ AP7 IDE            º Data ³  05/08/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Imprime asteriscos se houver quebra de nota.               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static Function ImpAster()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valor dos impostos.                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLin := 045


@ nLin, 005 PSAY "***,***,***.**"     // Base ICMS
@ nLin, 030 PSAY "***,***,***.**"     // Vlr. ICMS
@ nLin, 057 PSAY "***,***,***.**"     // Base de Calculo ICMS Retido
@ nLin, 090 PSAY "***,***,***.**"     // Vlr. ICMS Retido
If SF2->F2_TIPO <> "I"
	@ nLin, 140 PSAY "***,***,***.**" // Vlr. Mercadorias (c/ ISS).
EndIf
nLin := nLin + 2
@ nLin, 005 PSAY "***,***,***.**"         // Val. Frete
@ nLin, 030 PSAY "***,***,***.**"     // Val. Seguro
@ nLin, 057 PSAY "***,***,***.**"     // Vlr. Despesas Acessorias
@ nLin, 090 PSAY "***,***,***.**"     // Vlr. IPI
If SF2->F2_TIPO <> "I"
	@ nLin, 140 PSAY "***,***,***.**" // Vlr. Bruto
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados da transportadora                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLin := nLin + 3
@ nLin, 004 PSAY "***************************"
@ nLin, 090 PSAY "*"
@ nLin, 096 PSAY "********"
@ nLin, 118 PSAY "**"
@ nLin, 130 PSAY "******************"

nLin := nLin + 2
@ nLin, 004 PSAY "************************"
@ nLin, 072 PSAY "*****************"
@ nLin, 118 PSAY "**"
@ nLin, 130 PSAY "***************"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Peso Liquido, Peso Bruto, Especie, Volume                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLin := nLin + 2
@ nLin, 004 PSAY "******"
@ nLin, 023 PSAY "***************"
@ nLin, 047 PSAY "***************"
@ nLin, 077 PSAY "*********"
@ nLin, 105 PSAY "*********"
@ nLin, 145 PSAY "*********"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Numero da Nota no Rodape                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
           
                         
nLin := 74               
@ nLin, 010 PSAY  _cNumNF

nLin := 75               
@ nLin, 004 PSAY ""

SetPrc(0,0)

Return()
/*
nLin := 62
//@ nLin, 124 PSAY Chr(18) + _cNumNF + Chr(15)
@ nLin, 124 PSAY  _cNumNF
//nLin := 083
//@ nLin, 000 PSAY cImpReset
nLin += 4
@ nLin, 000 PSAY ""
//SetPrc(0,0)

Return()*/
