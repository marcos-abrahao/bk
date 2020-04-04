#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"       

/*/{Protheus.doc} MT150ROT
BK - Ponto de entrada utilizado para inserir novas opcoes no array aBotões na Atualiza Cotação.
@Return
@author Adilson do Prado
@since 14/02/2017
@version P11/P12
/*/

User Function MT150ROT() 

AADD(aRotina,{"Espelho Cotação","U_ESPELCOT()",0,9})
AADD(aRotina,{"Copia valores SC","U_CPVALSC()",0,9})

Return aRotina


// Rotina para copiar valores da SC na Cotação (usado quando a compra foi feita sem pedido)
// 13/07/2019 - Alterado para pegar o campo C1_XXVLALM 

User Function CPVALSC() 
Local aArea      := GetArea()
Local cAliasTmp  := GetNextAlias()
Local cNumCot    := SC8->C8_NUM
Local cFornece   := SC8->C8_FORNECE+SC8->C8_LOJA
Local nAtual     := 0
Local lOk        := .F.
Local nTamBtn    := 50
Local lEncerrada := .F.
Local lDigitada  := .F.

Private aHeader  := {}
Private aCols    := {}
Private aEdit    := {}
Private aStrut   := {}
Private aAux     := {}
Private oDlgPvt
Private oMGet19
Private oGrpDad
Private oTmpTb
//Tamanho da Janela
Private aTamanho := MsAdvSize()
Private nJanLarg := aTamanho[5]
Private nJanAltu := aTamanho[6]
Private nColMeio := (nJanLarg)/4

//              Campo           Tipo    Tamanho                 						Decimal
aAdd( aStrut, { "XX_XXNFOR",    "C",    TamSX3("C8_XXNFOR")[1],    						0} )
aAdd( aStrut, { "XX_CODIGO",    "C",    TamSX3("B1_COD")[1],    						0} )
aAdd( aStrut, { "XX_DESCR",     "C",    TamSX3("B1_DESC")[1],   						0} )
aAdd( aStrut, { "XX_VALOR",     "N",    15,                     						2} )
aAdd( aStrut, { "XX_SC",     	"C",    TamSX3("C8_NUMSC")[1]+TamSX3("C8_ITEMSC")[1]+1, 0} )
aAdd( aStrut, { "XX_VLALM",     "N",    15,                     						2} )
aAdd( aStrut, { "XX_RECNO",     "N",    15,                     						0} )

//Cabeçalho ...	Titulo          Campo				Mask		        Tamanho				    						Dec					Valid       Usado	Tip		F3	    CBOX
aAdd(aHeader,{	"Fornecedor",	"XX_XXNFOR"     ,	"@!"            ,	TamSX3("C8_XXNFOR")[1],							0                ,	".T."   ,	".T.",	"C",	""  ,	""})
aAdd(aHeader,{	"Produto",		"XX_CODIGO"     ,	"@!"            ,	TamSX3("B1_COD")[1]	,							0                ,	".T."   ,	".T.",	"C",	""  ,	""})
aAdd(aHeader,{	"Descrição",	"XX_DESCR"      ,	"@E"            ,	TamSX3("B1_DESC")[1],							0                ,	".T."  ,	".T.",	"C",	""  ,	""})
aAdd(aHeader,{	"Preço",		"XX_VALOR"      ,	"@E 99999999.99",	09					,							2                ,	".T."  ,	".T.",	"N",	""  ,	""})
aAdd(aHeader,{	"Sol.Compras",	"XX_SC"			,	"@E"            ,	TamSX3("C8_NUMSC")[1]+TamSX3("C8_ITEMSC")[1]+1,	0                ,	".T."  ,	".T.",	"C",	""  ,	""})
aAdd(aHeader,{	"Valor Almox",	"XX_VLALM"      ,	"@E 99999999.99",	09					,							2                ,	".T."    ,	".T.",	"N",	""	,	""})

 
//Excluindo dados da tabela temporária, se tiver aberta, fecha a tabela
If Select(cAliasTmp)>0
    (cAliasTmp)->(DbCloseArea())
EndIf
 
//Criando tabela temporária
///cArq:= CriaTrab( aStrut, .T. )             
///dbUseArea( .T.,NIL, cArq, cAliasTmp, .T., .F. )
///dbSelectArea(cAliasTmp)
oTmpTb := FWTemporaryTable():New(cAliasTmp)
oTmpTb:SetFields( aStrut )
oTmpTb:Create()

SC1->(DbSetOrder(1))
SC8->(DbSetOrder(1))

DbSelectArea("SC8")
DbGoTop()

SC8->(DbSeek(xFilial("SC8")+cNumCot+cFornece,.T.))

Do While SC8->(!eof()) .AND. xFilial("SC8") == SC8->C8_FILIAL .AND. SC8->C8_NUM == cNumCot .AND. SC8->C8_FORNECE+SC8->C8_LOJA == cFornece

	SC1->(dbSeek(xFilial("SC1")+SC8->C8_NUMSC+SC8->C8_ITEMSC,.F.))	   

	dbSelectArea(cAliasTmp)
	Reclock(cAliasTmp,.T.)
	(cAliasTmp)->XX_XXNFOR := SC8->C8_XXNFOR
	(cAliasTmp)->XX_CODIGO := SC8->C8_PRODUTO
	(cAliasTmp)->XX_DESCR  := Posicione("SB1",1,xFilial("SB1")+SC8->C8_PRODUTO,"B1_DESC")
	(cAliasTmp)->XX_VALOR  := SC8->C8_PRECO
	(cAliasTmp)->XX_SC     := SC8->C8_NUMSC+"-"+SC8->C8_ITEMSC
	(cAliasTmp)->XX_VLALM  := IIF(EMPTY(SC1->C1_XXVLALM),SC1->C1_XXLCVAL,SC1->C1_XXVLALM)
	(cAliasTmp)->XX_RECNO  := SC8->(RECNO())
    MsUnLock()

	//Montando a linha atual
	aAux := Array(Len(aHeader)+1)
	For nAtual := 1 To Len(aStrut)
		aAux[nAtual] := &((cAliasTmp)->(aStrut[nAtual,1]))
	Next
	aAux[Len(aHeader)+1] := .F.
	
	//Adiciona no aCols
	aAdd(aCols, aClone(aAux))

	If !EMPTY(SC8->C8_NUMPED)
		lEncerrada := .T.
    EndIf
    
    If !EMPTY(SC8->C8_PRECO)
        lDigitada := .T.
    EndIf
    
	SC8->(DbSkip())
ENDDO

If lEncerrada
	MsgStop("Cotação encerrada!","Atenção")
ElseIf lDIgitada
	MsgStop("Cotação já foi digitada!","Atenção")
EndIf

//Montando a tela
DEFINE MSDIALOG oDlgPvt TITLE "Cotação: "+TRIM(cNumCot)+" - Cópia de valores da Solicitação de Compras" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Dados
	@ 000, 003  GROUP oGrpDad TO (nJanAltu/2)-030, (nJanLarg/2)-003  PROMPT "Produtos: "  OF oDlgPvt PIXEL

		oMGet := MsNewGetDados():New(	010,;          					//nTop
										006,;          					//nLeft
										(nJanAltu/2)-033,;        		//nBottom
										(nJanLarg/2)-006,;       		//nRight
										,;								//nStyle
										"",;			 	      		//cLinhaOk
										,;           					//cTudoOk
										"",;          					//cIniCpos
										,;		          				//aAlter
										,;           					//nFreeze
										9999999,;         				//nMax
										,;           					//cFieldOK
										,;           					//cSuperDel
										"",;							//cDelOk
										oDlgPvt,;     					//oWnd
										aHeader,;        				//aHeader
										aCols)         					//aCols

			
	//Ações
	@ (nJanAltu/2)-25, 03 GROUP oGrpAco TO (nJanAltu/2)-003, (nJanLarg/2)-003  PROMPT "Ações: "  OF oDlgPvt PIXEL
	@ (nJanAltu/2)-19  , (nJanLarg/2)-((nTamBtn*1)+06) BUTTON oBtnConf PROMPT "Cancelar"   SIZE nTamBtn, 013 OF oDlgPvt ACTION(oDlgPvt:End(),lOk:= .F.)  PIXEL
	If !lEncerrada .AND. !lDigitada
		@ (nJanAltu/2)-19  , (nJanLarg/2)-((nTamBtn*2)+09) BUTTON oBtnLimp PROMPT "Copiar"     SIZE nTamBtn, 013 OF oDlgPvt ACTION(oDlgPvt:End(),lOk:= .T.)  PIXEL
	EndIf

ACTIVATE MSDIALOG oDlgPvt CENTERED

If lOk
	dbSelectArea(cAliasTmp)
	dbGoTop()
	Do While !EOF()
		SC8->(dbGoTo((cAliasTmp)->XX_RECNO))
		If (cAliasTmp)->XX_VLALM > 0  .AND. SC8->C8_PRECO = 0
			dbSelectArea("SC8")
		    Reclock("SC8",.F.)
		    SC8->C8_PRECO := (cAliasTmp)->XX_VLALM
		    
		    // Copiado do gatilho
		    SC8->C8_TOTAL := NoRound(SC8->C8_PRECO * SC8->C8_QUANT,TamSX3("C8_TOTAL")[2])    
		    MsUnLock()
		EndIf
		dbSelectArea(cAliasTmp)
		dbSkip()
	EndDo
	MsgInfo("Valores copiados com sucesso!","") 
EndIf

///(cAliasTmp)->(DbCloseArea())
///FErase(cArq+GetDBExtension())
///FErase(cArq+OrdBagExt())

oTmpTb:Delete()

RestArea(aArea)

Return Nil




// Espelho da cotação (Gera HTML e abre browse)
User Function ESPELCOT() 
Local aArea     := GetArea()
//Local cPath     := "\tmp\"
Local nHandle   := 0
Local cCrLf     := Chr(13) + Chr(10)
Local cDirTmp   := "C:\TMP"
Local cArqHtml  := cDirTmp+"\"+"COTACAO.HTML"
//Local cTxt      := ""
Local aHtml     := ""
Local _nI       := 0

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   
 
fErase(cArqHtml)

nHandle := MsfCreate(cArqHtml,0)
   
If nHandle > 0

	aHtml := CotacaoHtml()   
      
	FOR _nI := 1 TO LEN(aHtml)
		fWrite(nHandle, aHtml[_nI] + cCrLf )
	NEXT
      
	fClose(nHandle)

	ShellExecute("open", cArqHtml, "", "", 1)

EndIf

RestArea(aArea)

Return




Static Function CotacaoHtml()
Local aHtml    := {}
Local aCotacao := {}
Local aItens   := {}
Local aForn    := {}
Local nQtdCols := 3

Local nColI := 1
Local nColF := 0 
Local nForn := 0
Local nPag  := 1
Local lUPag := .F.

// Inicialização do array aCotacao
AADD(aCotacao,"")  // Obs
AADD(aCotacao,"")  // End. Entrega
AADD(aCotacao,.F.) // Urgente

GeraMatriz(aCotacao,aItens,aForn)

Do While .T.

	nForn += nQtdCols
	nColF := nForn
	
	If nColF >= LEN(aForn)
		nColF := LEN(aForn)
		lUPag := .T.
	ENdIf
	
	PagCotHtml(aHtml,aCotacao,aItens,aForn,nColI,nColF,nPag,lUPag)
    
	If nForn >= LEN(aForn)
		Exit
	EndIf

	nColI  += nQtdCols
    nPag++
	
EndDo

AADD(aHtml,'</body>')
AADD(aHtml,'</html>')

Return aHtml



Static Function PagCotHtml(aHtml,aCotacao,aItens,aForn,nColI,nColF,nPag,lUPag)
Local nX,nY,nZ
Local nMenor    := 0
Local nTotEco   := 0
Local nTotVlNeg := 0
Local cUrgente  := ""

Local nPObs     := 1
Local nPEndEnt  := 2
Local nPUrgente := 3

Local nPNome    := 3
Local nPCGC     := 4
Local nPContato := 5
Local nPTel		:= 6
Local nPCond    := 7
Local nPSubTot  := 8
Local nPDesconto:= 9
Local nPFrete   := 10
Local nPOutros  := 11
Local nPTotal   := 12
Local nPPrazo   := 13
Local nPEmail   := 14

Local nPItem    := 1
Local nPProd    := 2
Local nPDProd   := 3
Local nPUM      := 4
Local nPSC      := 5
Local nPQuant   := 6
Local nPVlLic   := 7
Local nPMedia   := 8
Local nPEcon    := 9
Local nPMenor   := 10 
Local nPVlNeg   := 11
Local nPArray   := 12
Local cLogo     := ""

If SM0->M0_CODIGO == "01"      // BK
	cLogo := '<img src="http://www.bkconsultoria.com.br/Imagens/logo_header.png" border=0>'
Endif	

If nPag == 1
	AADD(aHtml,'<html>')
	AADD(aHtml,'<head>') 
	AADD(aHtml,'<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">' )
	AADD(aHtml,'<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">' )
	AADD(aHtml,'<title>Espelho de Cotação - '+DTOC(date())+' '+TIME()+'</title>' )
	
	AADD(aHtml,'<style type="text/css">')
	AADD(aHtml,'.tg  {border-collapse:collapse;border-spacing:0;}')
	AADD(aHtml,'.tg td{font-family:Arial, sans-serif;font-size:14px;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}')
	AADD(aHtml,'.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}')
	
	AADD(aHtml,'.tg .tg-forn{font-weight:bold;font-size:10px;vertical-align:middle}')
	AADD(aHtml,'.tg .tg-hforn{font-size:10px;background-color:#c0c0c0;vertical-align:top;width:120px}')
	
	AADD(aHtml,'.tg .tg-data{font-weight:bold;font-size:12px;text-align:center}')
	
	AADD(aHtml,'.tg .tg-empr{font-weight:bold;font-size:28px;text-align:center}')
	
	AADD(aHtml,'.tg .tg-urgente{font-weight:bold;font-size:14px;color:red;text-align:center;margin-top: 5px}')
	
	AADD(aHtml,'.tg .tg-cab2{font-size:10px;background-color:#c0c0c0;vertical-align:top;min-width:100px}')
	
	
	AADD(aHtml,'.tg .tg-item{font-size:10px;vertical-align:middle;min-width:30px;text-align:center}')
	AADD(aHtml,'.tg .tg-hitem{background-color:#c0c0c0;font-size:10px;vertical-align:middle;min-width:30px;text-align:center}')
	
	AADD(aHtml,'.tg .tg-prod{font-size:10px;vertical-align:middle;min-width:50px;text-align:left}')
	AADD(aHtml,'.tg .tg-hprod{background-color:#c0c0c0;font-size:10px;vertical-align:middle;min-width:50px;text-align:left}')
	
	AADD(aHtml,'.tg .tg-desc{font-size:10px;vertical-align:middle;min-width:200px}')
	AADD(aHtml,'.tg .tg-hdesc{background-color:#c0c0c0;font-size:10px;vertical-align:middle;min-width:200px}')
	
	AADD(aHtml,'.tg .tg-umed{font-size:10px;vertical-align:middle;min-width:20px;text-align:center}')
	AADD(aHtml,'.tg .tg-humed{background-color:#c0c0c0;font-size:10px;vertical-align:middle;min-width:20px;text-align:center}')
	
	AADD(aHtml,'.tg .tg-sc{font-size:10px;vertical-align:middle;min-width:40px;text-align:center}')
	AADD(aHtml,'.tg .tg-hsc{background-color:#c0c0c0;font-size:10px;vertical-align:middle;min-width:40px;text-align:center}')
	
	AADD(aHtml,'.tg .tg-quant{font-size:10px;vertical-align:middle;min-width:40px;text-align:right;padding-right:10px}')
	AADD(aHtml,'.tg .tg-hquant{background-color:#c0c0c0;font-size:10px;vertical-align:middle;min-width:40px;text-align:center}')
	
	AADD(aHtml,'.tg .tg-vunit{font-size:10px;text-align:right;background-color:#efefef;vertical-align:middle;padding-right:10px}')
	AADD(aHtml,'.tg .tg-vunitB{font-weight:bold;font-size:10px;text-align:right;background-color:#efefef;vertical-align:middle;padding-right:10px}')
	AADD(aHtml,'.tg .tg-hvunit{background-color:#c0c0c0;font-size:10px;text-align:right;vertical-align:middle;padding-right:10px}')
	
	AADD(aHtml,'.tg .tg-vtotal{font-size:10px;text-align:right;vertical-align:middle;padding-right:10px}')
	AADD(aHtml,'.tg .tg-vtotalB{font-weight:bold;font-size:10px;text-align:right;vertical-align:middle;padding-right:10px}')
	AADD(aHtml,'.tg .tg-hvtotal{background-color:#c0c0c0;font-size:10px;text-align:right;vertical-align:middle;padding-right:10px}')
	
	
	AADD(aHtml,'.tg .tg-cond{font-size:10px;text-align:center;background-color:#efefef;vertical-align:middle}')
	AADD(aHtml,'.tg .tg-endent{font-size:10px;vertical-align:middle;min-width:200px;text-align:center}')

	AADD(aHtml,'.tg .tg-obs{font-size:10px;vertical-align:middle;max-width:200px}')
	AADD(aHtml,'.tg .tg-hobs{font-weight:bold;font-size:10px;background-color:#c0c0c0;text-align:center;vertical-align:top}')
	
	AADD(aHtml,'.tg .vertical-text {width:20px;transform:rotate(90deg);font-size:10px;padding:0px;}')


	AADD(aHtml,'.tg .tg-baqh{text-align:center;vertical-align:top}')
	
	AADD(aHtml,'.tg .tg-lhw6{font-size:10px;text-align:right;vertical-align:middle}')
	AADD(aHtml,'.tg .tg-q2kn{font-size:10px;background-color:#c0c0c0;text-align:center;vertical-align:top}')
	AADD(aHtml,'.tg .tg-ie2s{font-weight:bold;font-size:14px;background-color:#c0c0c0;text-align:right}')
	AADD(aHtml,'.tg .tg-yw4l{font-size:10px;vertical-align:middle;max-width:200px}')
	AADD(aHtml,'.tg .tg-25al{font-size:10px;text-align:center;vertical-align:middle}')
	AADD(aHtml,'.tg .tg-5tog{font-size:10px;background-color:#c0c0c0;text-align:right;vertical-align:top}')
	AADD(aHtml,'.tg .tg-huh2{font-size:14px;text-align:center}')
	AADD(aHtml,'.tg .tg-trly{font-weight:bold;font-size:10px;background-color:#c0c0c0;vertical-align:top}')
	
	AADD(aHtml,'.folha {page-break-after:always;page-break-inside:avoid;}')
	
	AADD(aHtml,'</style>' )
	AADD(aHtml,'</head>' )
	AADD(aHtml,'<body lang=PT-BR>' )
EndIf                                 

AADD(aHtml,'<div class="folha">')

AADD(aHtml,'<table class="tg">')
AADD(aHtml,'  <tr>')

If aCotacao[nPUrgente]
	cUrgente := '<p class="tg-urgente">Urgente!</p>'
EndIf

AADD(aHtml,'    <td class="tg-q2kn" colspan="6">Empresa</td>')
AADD(aHtml,'    <td class="tg-q2kn">Data</td>')

For nX := nColI TO nColF
	AADD(aHtml,'    <th class="tg-25al" rowspan="50"></th>')
	AADD(aHtml,'    <th class="tg-hforn" colspan="2">Fornecedor: '+ALLTRIM(STR(nX))+'</th>')
Next

If lUPag // Ultima Pagina
	AADD(aHtml,'    <th class="vertical-text"  rowspan="9">Média</th>') 
   	AADD(aHtml,'    <th class="vertical-text"  rowspan="9">Economia</th>')
   	AADD(aHtml,'    <th class="vertical-text"  rowspan="9">Valor negociado</th>')
EndIf

AADD(aHtml,'  </tr>')
AADD(aHtml,'  <tr>')

If EMPTY(cLogo)
	AADD(aHtml,'    <td class="tg-empr" colspan="6" rowspan="3">'+TRIM(SM0->M0_NOME)+'</td>')
Else
	AADD(aHtml,'    <td class="tg-empr" colspan="6" rowspan="3">'+cLogo+'</td>')
Endif

AADD(aHtml,'    <td class="tg-data" rowspan="3">'+DTOC(SC8->C8_EMISSAO)+'</td>')
    
For nX := nColI TO nColF
	AADD(aHtml,'    <td class="tg-forn" colspan="2">'+ALLTRIM(aForn[nX,nPNome])+'</td>')
Next	

AADD(aHtml,'  </tr>')
AADD(aHtml,'  <tr>')
For nX := nColI TO nColF
	AADD(aHtml,'    <td class="tg-cab2">CNPJ</td>')
	AADD(aHtml,'    <td class="tg-cab2">Contato</td>')
Next
AADD(aHtml,'  </tr>')
AADD(aHtml,'  <tr>')

For nX := nColI TO nColF
	AADD(aHtml,'    <td class="tg-yw4l">'+aForn[nX,nPCGC]+'</td>')
	AADD(aHtml,'    <td class="tg-yw4l">'+aForn[nX,nPContato]+'</td>')
Next

AADD(aHtml,'  </tr>')
AADD(aHtml,'  <tr>')


AADD(aHtml,'    <th class="tg-empr" colspan="7" rowspan="4">Cotação '+SC8->C8_NUM+cUrgente+'</th>')

For nX := nColI TO nColF
	AADD(aHtml,'    <td class="tg-cab2" colspan="2">Telefones</td>')
Next
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')

For nX := nColI TO nColF
    AADD(aHtml,'<td class="tg-yw4l" colspan="2">'+TRIM(aForn[nX,nPTel])+'</td>')
Next
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
For nX := nColI TO nColF
    AADD(aHtml,'<td class="tg-cab2" colspan="2">E-Mail</td>')
Next
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
For nX := nColI TO nColF
    AADD(aHtml,'<td class="tg-yw4l" colspan="2">'+ALLTRIM(aForn[nX,nPEmail])+'</td>')
Next
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-yw4l" colspan="7"></td>')
For nX := nColI TO nColF
	AADD(aHtml,'    <td class="tg-yw4l" colspan="2"></td>')
Next

AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-hitem">Item</td>')
AADD(aHtml,'    <td class="tg-hprod">Código</td>')
AADD(aHtml,'    <td class="tg-hdesc">Descrição</td>')
AADD(aHtml,'    <td class="tg-humed">Unid</td>')
AADD(aHtml,'    <td class="tg-hsc">SC</td>')
AADD(aHtml,'    <td class="tg-hquant">Quant.</td>')
AADD(aHtml,'    <td class="tg-hquant">Vl.Lic.</td>')
For nX := nColI TO nColF
	//AADD(aHtml,'    <td class="tg-cab2">R$ Unit.</td>')
	//AADD(aHtml,'    <td class="tg-cab2">R$ Total</td>')
	//AADD(aHtml,'    <td class="tg-cab2">R$ Unit.</td>')
	//AADD(aHtml,'    <td class="tg-cab2">R$ Total</td>')
	AADD(aHtml,'    <td class="tg-hvunit">R$ Unit</td>')
	AADD(aHtml,'    <td class="tg-hvtotal">R$ Total</td>')
Next	

If lUPag // Ultima Pagina
	AADD(aHtml,'    <td class="tg-hvunit">R$</td>')
	AADD(aHtml,'    <td class="tg-hvtotal">R$</td>')
	AADD(aHtml,'    <td class="tg-hvtotal">R$</td>')
EndIf

AADD(aHtml,'  </tr>')
    
// Itens

For nX := 1 TO LEN(aItens)
	AADD(aHtml,'<tr>')
    AADD(aHtml,'<td class="tg-item">'+TRIM(aItens[nX,nPItem])+'</td>')
    AADD(aHtml,'<td class="tg-prod">'+TRIM(aItens[nX,nPProd])+'</td>')
    AADD(aHtml,'<td class="tg-desc">'+TRIM(aItens[nX,nPDProd])+'</td>')
    AADD(aHtml,'<td class="tg-umed">'+TRIM(aItens[nX,nPUM])+'</td>')
    AADD(aHtml,'<td class="tg-sc">'+TRIM(aItens[nX,nPSC])+'</td>')
    AADD(aHtml,'<td class="tg-quant">'+ALLTRIM(TRANSFORM(aItens[nX,nPQuant],"@E 99999999.99"))+'</td>')
    AADD(aHtml,'<td class="tg-vunit">'+ALLTRIM(TRANSFORM(aItens[nX,nPVlLic],"@E 999,999,999.99"))+'</td>')
    
	// Negritar o menor preço
	nMenor := aItens[nX,nPMenor]
    For nY := nColI To nColF
    	If aItens[nX,nY+nPArray-1,1] == nMenor .AND. aItens[nX,nY+nPArray-1,1] > 0
		    AADD(aHtml,'<td class="tg-vunitB">'+ALLTRIM(TRANSFORM(aItens[nX,nY+nPArray-1,1],"@E 999,999,999.99"))+'</td>')
		    AADD(aHtml,'<td class="tg-vtotalB">'+ALLTRIM(TRANSFORM(aItens[nX,nY+nPArray-1,2],"@E 999,999,999.99"))+'</td>')
		Else
		    AADD(aHtml,'<td class="tg-vunit">'+ALLTRIM(TRANSFORM(aItens[nX,nY+nPArray-1,1],"@E 999,999,999.99"))+'</td>')
		    AADD(aHtml,'<td class="tg-vtotal">'+ALLTRIM(TRANSFORM(aItens[nX,nY+nPArray-1,2],"@E 999,999,999.99"))+'</td>')
		EndIf
	Next
	If lUPag // Ultima Pagina
		AADD(aHtml,'<td class="tg-vunit">'+ALLTRIM(TRANSFORM(aItens[nX,nPMedia],"@E 999,999,999.99"))+'</td>')
		AADD(aHtml,'<td class="tg-vunit">'+ALLTRIM(TRANSFORM(aItens[nX,nPEcon],"@E 999,999,999.99"))+'</td>')
		AADD(aHtml,'<td class="tg-vunit">'+ALLTRIM(TRANSFORM(aItens[nX,nPVlNeg],"@E 999,999,999.99"))+'</td>')
		nTotEco   += aItens[nX,nPEcon]
		nTotVlNeg += aItens[nX,nPVlNeg]
	EndIf
	AADD(aHtml,'</tr>')


	// Cabeçalho de mudança de pagina entre itens
	If Mod(nX,25) == 0	
		AADD(aHtml,'</table>')
		AADD(aHtml,'</br>')
		AADD(aHtml,'</div>')
		
		AADD(aHtml,'<div class="folha">')
		AADD(aHtml,'<table class="tg">')
		AADD(aHtml,'  <tr>')
		AADD(aHtml,'    <th class="tg-empr" colspan="7" rowspan="4">Cotação '+SC8->C8_NUM+'</th>')
		//AADD(aHtml,'    <th class="tg-ie2s" rowspan="2">S.C.</th>')
		
		For nZ := nColI TO nColF
			//AADD(aHtml,'    <th class="tg-yw4l" rowspan="23"></th>')
			//AADD(aHtml,'    <th class="tg-cab2" colspan="2">Empresa 1:</th>')
			//AADD(aHtml,'    <th class="tg-yw4l" rowspan="23"></th>')
			//AADD(aHtml,'    <th class="tg-cab2" colspan="2">Empresa 2:</th>')
			//AADD(aHtml,'    <th class="tg-25al" rowspan="23"></th>')
			//AADD(aHtml,'    <th class="tg-cab2" colspan="2">Empresa3:</th>')
			AADD(aHtml,'    <th class="tg-25al" rowspan="50"></th>')
			AADD(aHtml,'    <th class="tg-hforn" colspan="2">Fornecedor: '+ALLTRIM(STR(nZ))+'</th>')
		Next
		
		If lUPag // Ultima Pagina
			AADD(aHtml,'<th class="vertical-text"  rowspan="4">Média</th>') 
		   	AADD(aHtml,'<th class="vertical-text"  rowspan="4">Economia</th>')
		   	AADD(aHtml,'<th class="vertical-text"  rowspan="4">Valor negociado</th>')
		EndIf
		AADD(aHtml,'  </tr>')

		AADD(aHtml,'  <tr>')
		
		
		For nZ := nColI TO nColF
			//AADD(aHtml,'    <td class="tg-forn" colspan="2">Especial xxxxxxxxxxxxxxxxxxxxxx</td>')
			//AADD(aHtml,'    <td class="tg-forn" colspan="2">Faxinandoxxxxxxxxxxxxxxxxxxxxx</td>')
			//AADD(aHtml,'    <td class="tg-forn" colspan="2">Multipla xxxxxxxxxxxxxxxxxxxxxx</td>')
			AADD(aHtml,'    <td class="tg-forn" colspan="2">'+ALLTRIM(aForn[nZ,nPNome])+'</td>')
		Next	
		
		AADD(aHtml,'  </tr>')
		AADD(aHtml,'  <tr>')
		For nZ := nColI TO nColF
			//AADD(aHtml,'    <td class="tg-cab2">CNPJ</td>')
			//AADD(aHtml,'    <td class="tg-cab2">Contato</td>')
			//AADD(aHtml,'    <td class="tg-cab2">CNPJ</td>')
			//AADD(aHtml,'    <td class="tg-cab2">Contato</td>')
			//AADD(aHtml,'    <td class="tg-cab2">CNPJ</td>')
			//AADD(aHtml,'    <td class="tg-cab2">Contato</td>')
			AADD(aHtml,'    <td class="tg-cab2">CNPJ</td>')
			AADD(aHtml,'    <td class="tg-cab2">Contato</td>')
		Next
		AADD(aHtml,'  </tr>')

		AADD(aHtml,'  <tr>')
		For nZ := nColI TO nColF
			//AADD(aHtml,'    <td class="tg-yw4l"></td>')
			//AADD(aHtml,'    <td class="tg-yw4l"></td>')
			//AADD(aHtml,'    <td class="tg-yw4l"></td>')
			//AADD(aHtml,'    <td class="tg-yw4l"></td>')
			//AADD(aHtml,'    <td class="tg-yw4l"></td>')
			//AADD(aHtml,'    <td class="tg-yw4l"></td>')
			
			AADD(aHtml,'    <td class="tg-yw4l">'+aForn[nZ,nPCGC]+'</td>')
			AADD(aHtml,'    <td class="tg-yw4l">'+aForn[nZ,nPContato]+'</td>')
		Next
		AADD(aHtml,'  </tr>')
		
		AADD(aHtml,'  <tr>')
		AADD(aHtml,'    <td class="tg-hitem">Item</td>')
		AADD(aHtml,'    <td class="tg-hprod">Código</td>')
		AADD(aHtml,'    <td class="tg-hdesc">Descrição</td>')
		AADD(aHtml,'    <td class="tg-humed">Unid</td>')
		AADD(aHtml,'    <td class="tg-hsc">SC</td>')
		AADD(aHtml,'    <td class="tg-hquant">Quant.</td>')
		AADD(aHtml,'    <td class="tg-hquant">Vl.Lic.</td>')
		For nZ := nColI TO nColF
			//AADD(aHtml,'    <td class="tg-cab2">R$ Unit.</td>')
			//AADD(aHtml,'    <td class="tg-cab2">R$ Total</td>')
			//AADD(aHtml,'    <td class="tg-cab2">R$ Unit.</td>')
			//AADD(aHtml,'    <td class="tg-cab2">R$ Total</td>')
			AADD(aHtml,'    <td class="tg-hvunit">R$ Unit</td>')
			AADD(aHtml,'    <td class="tg-hvtotal">R$ Total</td>')
		Next	
		If lUPag // Ultima Pagina
			AADD(aHtml,'    <td class="tg-hvunit">R$</td>')
			AADD(aHtml,'    <td class="tg-hvtotal">R$</td>')
			AADD(aHtml,'    <td class="tg-hvtotal">R$</td>')
		EndIf		
		AADD(aHtml,'  </tr>')
					
    EndIf

Next    

AADD(aHtml,'<tr>')
AADD(aHtml,'<td class="tg-hobs" colspan="7">Local de entrega</td>')
For nY := nColI To nColF
	AADD(aHtml,'<td class="tg-cab2">Sub Total</td>')
	AADD(aHtml,'<td class="tg-vtotal">'+ALLTRIM(TRANSFORM(aForn[nY,nPSubTot],"@E 999,999,999.99"))+'</td>')
Next
If lUPag // Ultima Pagina
	AADD(aHtml,'<td class="tg-vunit" colspan="2">'+ALLTRIM(TRANSFORM(nTotEco,"@E 999,999,999.99"))+'</td>')
//	AADD(aHtml,'<td class="tg-vunit">'+ALLTRIM(TRANSFORM(nTotVlNeg,"@E 999,999,999.99"))+'</td>')
EndIf
AADD(aHtml,'</tr>')


AADD(aHtml,'<tr>')
AADD(aHtml,'<td class="tg-endent" colspan="7" rowspan="2">'+aCotacao[nPEndEnt]+'</td>')
For nY := nColI To nColF
	AADD(aHtml,'<td class="tg-cab2">Desconto</td>')
	AADD(aHtml,'<td class="tg-vtotal">'+ALLTRIM(TRANSFORM(aForn[nY,nPDesconto],"@E 999,999,999.99"))+'</td>')
Next
AADD(aHtml,'</tr>')

AADD(aHtml,'<tr>')
For nY := nColI To nColF
	AADD(aHtml,'<td class="tg-cab2">Frete</td>')
	AADD(aHtml,'<td class="tg-vtotal">'+ALLTRIM(TRANSFORM(aForn[nY,nPFrete],"@E 999,999,999.99"))+'</td>')
Next
AADD(aHtml,'</tr>')

AADD(aHtml,'<tr>')
AADD(aHtml,'<td class="tg-hobs" colspan="7">Observações</td>')
For nY := nColI To nColF
	AADD(aHtml,'<td class="tg-cab2">Outros</td>')
	AADD(aHtml,'<td class="tg-vtotal">'+ALLTRIM(TRANSFORM(aForn[nY,nPOutros],"@E 999,999,999.99"))+'</td>')
Next
AADD(aHtml,'</tr>')


AADD(aHtml,'<tr>')
AADD(aHtml,'<td class="tg-obs" colspan="7" rowspan="4">'+aCotacao[nPObs]+'</td>')
For nY := nColI To nColF
	AADD(aHtml,'<td class="tg-cab2">Total</td>')
	AADD(aHtml,'<td class="tg-vtotal">'+ALLTRIM(TRANSFORM(aForn[nY,nPTotal],"@E 999,999,999.99"))+'</td>')
Next
AADD(aHtml,'</tr>')

AADD(aHtml,'<tr>')
For nY := nColI To nColF
	AADD(aHtml,'<td class="tg-25al" colspan="2"></td>')
Next
AADD(aHtml,'</tr>')


AADD(aHtml,'<tr>')
For nY := nColI To nColF
	AADD(aHtml,'<td class="tg-cab2">Cond Pgto</td>')
	AADD(aHtml,'<td class="tg-cond">'+aForn[nY,nPCond]+'</td>')
Next
AADD(aHtml,'</tr>')

AADD(aHtml,'<tr>')
For nY := nColI To nColF
	AADD(aHtml,'<td class="tg-cab2">Prazo Entrega</td>')
	AADD(aHtml,'<td class="tg-cond">'+aForn[nY,nPPrazo]+' DIAS</td>')
Next
AADD(aHtml,'</tr>')

AADD(aHtml,'</table>')
AADD(aHtml,'<br>')
AADD(aHtml,'<br>')
AADD(aHtml,'</div>')


Return Nil

 

Static Function GeraMatriz(aCotacao,aItens,aForn)
// Carregar Dados 

Local aArea     := GetArea()
Local cFilSx8   := ""
Local aItem     := {}
Local aFornN    := {}
Local cNumCot   := SC8->C8_NUM
Local nPosForn  := 0
Local nPosIt    := 0

Local nPObs     := 1
Local nPEndEnt  := 2
Local nPUrgente := 3

//Local nPNome    := 3
//Local nPCGC     := 4
Local nPContato := 5
//Local nPTel		:= 6
//Local nPCond    := 7
Local nPSubTot  := 8
Local nPDesconto:= 9
Local nPFrete   := 10
Local nPOutros  := 11
Local nPTotal   := 12
Local nPPrazo   := 13
//Local nPEmail   := 14

//Local nPItem    := 1
//Local nPProd    := 2
//Local nPDProd   := 3
//Local nPUM      := 4
//Local nPSC      := 5
Local nPQuant   := 6
//Local nPVlLic   := 7
Local nPMedia   := 8
Local nPEcon    := 9
Local nPMenor   := 10 
Local nPVlNeg   := 11
Local nPArray   := 12

Local nMedia    := 0
Local nMenor    := 0
Local nQtdMed   := 0
Local nDesconto := 0

Local aAreaSC8  := SC8->(GetArea())
Local aAreaSA2  := SA2->(GetArea())
Local aAreaSC1  := SC1->(GetArea())
Local aAreaSC7  := SC7->(GetArea())

SC8->(DbSetOrder(1))
SA2->(DbSetOrder(1))
SC1->(DbSetOrder(1))
SC7->(DbSetOrder(1))

cFilSx8   := xFilial("SC8")
DbSelectArea("SC8")
SC8->(DbSeek(xFilial("SC8")+cNumCot,.T.))
Do While SC8->(!eof()) .AND. xFilial("SC8") == cFilSx8 .AND. SC8->C8_NUM == cNumCot

	nPosForn := aScan(aForn, {|x| x[1]==SC8->C8_FORNECE .AND. x[2]==SC8->C8_LOJA}) 
	If nPosForn == 0
		aFornN := {}
		
		SA2->(dbSeek(xFilial("SA2")+SC8->C8_FORNECE+SC8->C8_LOJA))
		SC1->(dbSeek(xFilial("SC1")+SC8->C8_NUMSC+SC8->C8_ITEMSC))
		SC7->(dbSeek(xFilial("SC7")+SC8->C8_NUMPED+SC8->C8_ITEMPED))

		AADD(aFornN,SC8->C8_FORNECE)
		AADD(aFornN,SC8->C8_LOJA)
		AADD(aFornN,ALLTRIM(SA2->A2_NOME))
		AADD(aFornN,SA2->A2_CGC)
		AADD(aFornN,ALLTRIM(SA2->A2_CONTATO))
		AADD(aFornN,'('+ALLTRIM(SA2->A2_DDD)+')'+ALLTRIM(SA2->A2_TEL)+" "+ALLTRIM(SA2->A2_FAX))
		AADD(aFornN,Posicione("SE4",1,xFilial("SE4")+SC8->C8_COND,"E4_DESCRI"))
		AADD(aFornN,0)  // 8-SubTotal
		AADD(aFornN,0)  // 9-Desconto
		AADD(aFornN,0)  // 10-Frete
		AADD(aFornN,0)  // 11-Outros
		AADD(aFornN,0)  // 12-Total
		AADD(aFornN,ALLTRIM(STR(SC8->C8_PRAZO))) // 13-Prazo de Entrega
		AADD(aFornN,ALLTRIM(SA2->A2_EMAIL))		 // 14-Email
		AADD(aForn,aFornN)
	EndIf

	If !EMPTY(SC8->C8_OBS)
		If !ALLTRIM(SC8->C8_OBS) $ aCotacao[nPObs]
			aCotacao[nPObs] += ALLTRIM(SC8->C8_OBS)+" "  
		EndIf
	EndIf	

	If EMPTY(aCotacao[nPEndEnt])
		aCotacao[nPEndEnt] := ALLTRIM(SC1->C1_XXENDENT)
	EndIf

	If !aCotacao[nPUrgente] .AND. SC7->C7_XXURGEN == "S"
		aCotacao[nPUrgente] := .T.
	EndIf

	SC8->(DbSkip())

ENDDO

SC8->(DbSeek(xFilial("SC8")+cNumCot,.T.))
Do While SC8->(!eof()) .AND. xFilial("SC8") == cFilSx8 .AND. SC8->C8_NUM == cNumCot

	nPosForn := aScan(aForn, {|x| x[1]==SC8->C8_FORNECE .AND. x[2]==SC8->C8_LOJA}) 
	nPosIt   := aScan(aItens, {|x| x[2]==SC8->C8_PRODUTO})
	
	If nPosIt == 0
	   aItem := {}

	   // Buscar valor licitado na Solicitação de compras
	   SC1->(dbSeek(xFilial("SC1")+SC8->C8_NUMSC+SC8->C8_ITEMSC,.F.))	   

	   AADD(aItem,SC8->C8_ITEM)
	   AADD(aItem,SC8->C8_PRODUTO)
	   AADD(aItem,Posicione("SB1",1,xFilial("SB1")+SC8->C8_PRODUTO,"B1_DESC"))
	   AADD(aItem,SC8->C8_UM)
	   AADD(aItem,SC8->C8_NUMSC)
	   AADD(aItem,SC8->C8_QUANT)
	   AADD(aItem,SC1->C1_XXLCVAL)
	   AADD(aItem,0) // Media
	   AADD(aItem,0) // Economia
	   AADD(aItem,0) // Menor Preço
	   AADD(aItem,0) // Valor negociado (preço - desconto)
	   For nY := 1 TO LEN(aForn)
		   AADD(aItem,{0,0,0})  // Preço,Total,Desconto
	   Next
	   
	   If !EMPTY(SC8->C8_CONTATO)
	      aForn[nPosForn,nPContato] := SC8->C8_CONTATO
	   EndIf
	   
	   AADD(aItens,aItem)
	   nPosIt := LEN(aItens)
	EndIf
    
	aItens[nPosIt,nPArray+nPosForn-1] := {SC8->C8_PRECO,SC8->C8_QUANT*SC8->C8_PRECO,SC8->C8_VLDESC}
	
	aForn[nPosForn,nPSubTot]   += (SC8->C8_QUANT*SC8->C8_PRECO)  // Sub-Total
	aForn[nPosForn,nPDesconto] += (SC8->C8_VLDESC)  // Desconto
	aForn[nPosForn,nPFrete]    += (SC8->C8_VALFRE)  // Frete
	aForn[nPosForn,nPOutros]   += (SC8->C8_DESPESA+SC8->C8_SEGURO)  // Outros
	aForn[nPosForn,nPTotal]    += ((SC8->C8_QUANT*SC8->C8_PRECO) - SC8->C8_VLDESC + SC8->C8_VALFRE + SC8->C8_DESPESA+SC8->C8_SEGURO)
    
	If EMPTY(aForn[nPosForn,nPPrazo])
		aForn[nPosForn,nPPrazo] := ALLTRIM(STR(SC8->C8_PRAZO))
	EndIf
	
	SC8->(DbSkip())
ENDDO


For nPosIt := 1 TO LEN(aItens)
    
	nMedia := 0
	nMenor := 0
	nQtdMed:= 0
	nDesconto := 0
	For nPosForn := 1 TO LEN(aForn)
		nPreco := aItens[nPosIt,nPArray+nPosForn-1,1]
		If nPreco > 0
	    	nMedia += nPreco
	    	nQtdMed++
		    If nPreco <= nMenor .OR. nMenor == 0 
		    	// Menor preço
		    	nMenor    := nPreco
		    	aItens[nPosIt,nPMenor] := nMenor
		    	nDesconto := aItens[nPosIt,nPArray+nPosForn-1,3]
		    EndIf
	 	EndIf
	Next
	
	// Calculo da Média
   	aItens[nPosIt,nPMedia] := ROUND(nMedia / nQtdMed,2)
   	
   	// Calculo da Economia
   	aItens[nPosIt,nPEcon] := aItens[nPosIt,nPQuant] * (aItens[nPosIt,nPMedia] - aItens[nPosIt,nPMenor])

	// Valor negociado
   	aItens[nPosIt,nPVlNeg] := nMenor - (nDesconto / aItens[nPosIt,nPQuant])
	
Next

SC8->(RestArea(aAreaSC8))
SA2->(RestArea(aAreaSA2))
SC1->(RestArea(aAreaSC1))
SC7->(RestArea(aAreaSC7))

RestArea(aArea)
Return Nil








// Html gerado
/*
<style type="text/css">
.tg  {border-collapse:collapse;border-spacing:0;}
.tg td{font-family:Arial, sans-serif;font-size:14px;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}
.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}
.tg .tg-gcz1{font-size:14px;text-align:right}
.tg .tg-nrw1{font-size:10px;text-align:center;vertical-align:top}
.tg .tg-cond{font-weight:bold;font-size:10px;background-color:#efefef;vertical-align:top}
.tg .tg-baqh{text-align:center;vertical-align:top}
.tg .tg-mwni{font-weight:bold;font-size:28px;text-align:center}
.tg .tg-s5wt{font-size:10px;background-color:#efefef;vertical-align:top}
.tg .tg-lhw6{font-size:10px;text-align:right;vertical-align:top}
.tg .tg-q2kn{font-size:10px;background-color:#c0c0c0;text-align:center;vertical-align:top}
.tg .tg-oazg{font-weight:bold;font-size:14px;text-align:right}
.tg .tg-by3v{font-weight:bold;font-size:14px;text-align:center}
.tg .tg-ie2s{font-weight:bold;font-size:14px;background-color:#c0c0c0;text-align:right}
.tg .tg-yw4l{vertical-align:top}
.tg .tg-cab2{font-size:10px;background-color:#c0c0c0;vertical-align:top}
.tg .tg-25al{font-size:10px;vertical-align:top}
.tg .tg-3cwu{font-weight:bold;font-size:10px;vertical-align:top}
.tg .tg-5tog{font-size:10px;background-color:#c0c0c0;text-align:right;vertical-align:top}
.tg .tg-huh2{font-size:14px;text-align:center}
.tg .tg-nxmw{font-weight:bold;font-size:10px;background-color:#c0c0c0;text-align:center;vertical-align:top}
.tg .tg-trly{font-weight:bold;font-size:10px;background-color:#c0c0c0;vertical-align:top}
</style>
<table class="tg">
  <tr>
    <th class="tg-mwni" colspan="5" rowspan="4">Cotação</th>
    <th class="tg-ie2s" rowspan="2">S.C.</th>
    <th class="tg-yw4l" rowspan="23"></th>
    <th class="tg-cab2" colspan="2">Empresa 1:</th>
    <th class="tg-yw4l" rowspan="23"></th>
    <th class="tg-cab2" colspan="2">Empresa 2:</th>
    <th class="tg-25al" rowspan="23"></th>
    <th class="tg-cab2" colspan="2">Empresa3:</th>
  </tr>
  <tr>
    <td class="tg-3cwu" colspan="2">Especial xxxxxxxxxxxxxxxxxxxxxx</td>
    <td class="tg-3cwu" colspan="2">Faxinandoxxxxxxxxxxxxxxxxxxxxx</td>
    <td class="tg-3cwu" colspan="2">Multipla xxxxxxxxxxxxxxxxxxxxxx</td>
  </tr>
  <tr>
    <td class="tg-gcz1" rowspan="2">188</td>
    <td class="tg-cab2">CNPJ</td>
    <td class="tg-cab2">Contato</td>
    <td class="tg-cab2">CNPJ</td>
    <td class="tg-cab2">Contato</td>
    <td class="tg-cab2">CNPJ</td>
    <td class="tg-cab2">Contato</td>
  </tr>
  <tr>
    <td class="tg-yw4l"></td>
    <td class="tg-yw4l"></td>
    <td class="tg-yw4l"></td>
    <td class="tg-yw4l"></td>
    <td class="tg-yw4l"></td>
    <td class="tg-yw4l"></td>
  </tr>
  <tr>
    <td class="tg-q2kn" colspan="2">Estab.</td>
    <td class="tg-q2kn" colspan="3">Nome Estab</td>
    <td class="tg-5tog">Data</td>
    <td class="tg-cab2">Fone</td>
    <td class="tg-cab2">Fax</td>
    <td class="tg-cab2">Fone</td>
    <td class="tg-cab2">Fax</td>
    <td class="tg-cab2">Fone</td>
    <td class="tg-cab2">Fax</td>
  </tr>
  <tr>
    <td class="tg-huh2" colspan="2" rowspan="3"></td>
    <td class="tg-by3v" colspan="3" rowspan="3">ARARAS</td>
    <td class="tg-oazg" rowspan="3">16/02/2017</td>
    <td class="tg-yw4l"></td>
    <td class="tg-yw4l"></td>
    <td class="tg-yw4l"></td>
    <td class="tg-yw4l"></td>
    <td class="tg-yw4l"></td>
    <td class="tg-yw4l"></td>
  </tr>
  <tr>
    <td class="tg-cab2">Cel</td>
    <td class="tg-cab2">Outro</td>
    <td class="tg-cab2">Cel</td>
    <td class="tg-cab2">Outro</td>
    <td class="tg-cab2">Cel</td>
    <td class="tg-cab2">Outro</td>
  </tr>
  <tr>
    <td class="tg-yw4l"></td>
    <td class="tg-yw4l"></td>
    <td class="tg-yw4l"></td>
    <td class="tg-yw4l"></td>
    <td class="tg-yw4l"></td>
    <td class="tg-yw4l"></td>
  </tr>
  <tr>
    <td class="tg-yw4l" colspan="6"></td>
    <td class="tg-yw4l" colspan="2"></td>
    <td class="tg-yw4l" colspan="2"></td>
    <td class="tg-yw4l" colspan="2"></td>
  </tr>
  <tr>
    <td class="tg-q2kn">Item</td>
    <td class="tg-cab2">Código</td>
    <td class="tg-q2kn">Descrição</td>
    <td class="tg-cab2">Unid</td>
    <td class="tg-cab2"></td>
    <td class="tg-5tog">Quant.</td>
    <td class="tg-cab2">R$ Unit.</td>
    <td class="tg-cab2">R$ Total</td>
    <td class="tg-cab2">R$ Unit.</td>
    <td class="tg-cab2">R$ Total</td>
    <td class="tg-cab2">R$ Unit</td>
    <td class="tg-cab2">R$ Total</td>
  </tr>

--


  <tr>
    <td class="tg-nrw1">01</td>
    <td class="tg-25al">0000000001</td>
    <td class="tg-nrw1">Papel Toalha bobina c/ 8 rolos</td>
    <td class="tg-25al">Un</td>
    <td class="tg-25al"></td>
    <td class="tg-lhw6">1000,000</td>
    <td class="tg-s5wt">22,00</td>
    <td class="tg-25al">22.000,00</td>
    <td class="tg-s5wt">200,00</td>
    <td class="tg-25al">100.000,00</td>
    <td class="tg-s5wt">300,00</td>
    <td class="tg-25al">10000,00</td>
  </tr>
  <tr>
    <td class="tg-nrw1"></td>
    <td class="tg-25al"></td>
    <td class="tg-nrw1"></td>
    <td class="tg-25al"></td>
    <td class="tg-25al"></td>
    <td class="tg-lhw6"></td>
    <td class="tg-s5wt"></td>
    <td class="tg-25al"></td>
    <td class="tg-s5wt"></td>
    <td class="tg-25al"></td>
    <td class="tg-s5wt"></td>
    <td class="tg-25al"></td>
  </tr>
  <tr>
    <td class="tg-nrw1"></td>
    <td class="tg-25al"></td>
    <td class="tg-nrw1"></td>
    <td class="tg-25al"></td>
    <td class="tg-25al"></td>
    <td class="tg-lhw6"></td>
    <td class="tg-s5wt"></td>
    <td class="tg-25al"></td>
    <td class="tg-s5wt"></td>
    <td class="tg-25al"></td>
    <td class="tg-s5wt"></td>
    <td class="tg-25al"></td>
  </tr>
  <tr>
    <td class="tg-nrw1"></td>
    <td class="tg-25al"></td>
    <td class="tg-nrw1"></td>
    <td class="tg-25al"></td>
    <td class="tg-25al"></td>
    <td class="tg-lhw6"></td>
    <td class="tg-s5wt"></td>
    <td class="tg-25al"></td>
    <td class="tg-s5wt"></td>
    <td class="tg-25al"></td>
    <td class="tg-s5wt"></td>
    <td class="tg-25al"></td>
  </tr>
  <tr>
    <td class="tg-nrw1"></td>
    <td class="tg-25al"></td>
    <td class="tg-nrw1"></td>
    <td class="tg-25al"></td>
    <td class="tg-25al"></td>
    <td class="tg-lhw6"></td>
    <td class="tg-25al"></td>
    <td class="tg-25al"></td>
    <td class="tg-25al"></td>
    <td class="tg-25al"></td>
    <td class="tg-25al"></td>
    <td class="tg-25al"></td>
  </tr>
  <tr>
    <td class="tg-nxmw" colspan="6">Local de entrega</td>
    <td class="tg-25al">Sub Total</td>
    <td class="tg-trly">1.011,00</td>
    <td class="tg-25al">Sub Total</td>
    <td class="tg-trly">0,00</td>
    <td class="tg-25al">Sub Total</td>
    <td class="tg-trly">0</td>
  </tr>
  <tr>
    <td class="tg-baqh" colspan="6" rowspan="2"></td>
    <td class="tg-25al">Desconto</td>
    <td class="tg-s5wt"></td>
    <td class="tg-25al">Desconto</td>
    <td class="tg-s5wt"></td>
    <td class="tg-25al">Desconto</td>
    <td class="tg-s5wt"></td>
  </tr>
  <tr>
    <td class="tg-25al">Frete</td>
    <td class="tg-s5wt"></td>
    <td class="tg-25al">Frete</td>
    <td class="tg-s5wt"></td>
    <td class="tg-25al">Frete</td>
    <td class="tg-s5wt"></td>
  </tr>
  <tr>
    <td class="tg-nxmw" colspan="6">Observações</td>
    <td class="tg-25al">Outros</td>
    <td class="tg-s5wt"></td>
    <td class="tg-25al">Outros</td>
    <td class="tg-s5wt"></td>
    <td class="tg-25al">Outros</td>
    <td class="tg-s5wt"></td>
  </tr>
  <tr>
    <td class="tg-yw4l" colspan="6" rowspan="4"></td>
    <td class="tg-25al">TOTAL -&gt;&gt;</td>
    <td class="tg-trly">0,00</td>
    <td class="tg-25al">Total -&gt;&gt;</td>
    <td class="tg-trly">0</td>
    <td class="tg-25al">Total -&gt;&gt;</td>
    <td class="tg-trly">0</td>
  </tr>
  <tr>
    <td class="tg-25al" colspan="2"></td>
    <td class="tg-25al" colspan="2"></td>
    <td class="tg-25al" colspan="2"></td>
  </tr>
  <tr>
    <td class="tg-forn">Cond Pgto</td>
    <td class="tg-cond">28ddl</td>
    <td class="tg-forn">Cond Pgto</td>
    <td class="tg-cond">28 ddl</td>
    <td class="tg-forn">Cond Pgto</td>
    <td class="tg-cond">28 ddl</td>
  </tr>
  <tr>
    <td class="tg-forn">Prazo Entrega</td>
    <td class="tg-cond">10 dias</td>
    <td class="tg-forn">Prazo Entrega</td>
    <td class="tg-cond">20 dias</td>
    <td class="tg-forn">Prazo Entrega</td>
    <td class="tg-cond">30 dias</td>
  </tr>
</table>
*/



