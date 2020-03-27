#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINR19
BK - Digitação de mov bancario em lote
@Return
@author Marcos Bispo Abrahão
@since 23/08/2016
@version P12
/*/
//-------------------------------------------------------------------

User Function BKFINA19()
Local aArea     := GetArea()
Local cAliasTmp := GetNextAlias()
Local oTmpTb
Local aStrut    := {}
Local cTx       := ""
Private aFacil  := {}
Private cBanco  := PAD("CBX",TamSX3("A6_COD")[1])
Private cAgencia:= PAD("00001",TamSX3("A6_AGENCIA")[1])
Private cNumCon := PAD("0000000001",TamSX3("A6_NUMCON")[1])
Private cNomeBc := PAD("",TamSX3("A6_NOME")[1]) 
Private dDataMov:= dDataBase

cNomeBC := Posicione("SA6",1,xFilial("SA6")+cBanco+cAgencia,"A6_NOME")

aFacil := LoadFacil()

//              Campo           Tipo    Tamanho                 Decimal
aAdd( aStrut, { "XX_MOV",       "C",    01,	                    0} )
aAdd( aStrut, { "XX_DATA",      "D",    08,                     0} )
aAdd( aStrut, { "XX_HIST",      "C",    TamSX3("E5_HISTOR")[1], 0} )
aAdd( aStrut, { "XX_CCUS",      "C",    TamSX3("CTT_CUSTO")[1], 0} )
aAdd( aStrut, { "XX_DESCC",     "C",    TamSX3("CTT_DESC01")[1],0} )
aAdd( aStrut, { "XX_VALOR",     "N",    15,                     2} )
aAdd( aStrut, { "XX_CONTA",     "C",    TamSX3("CT1_CONTA")[1], 0} )
aAdd( aStrut, { "XX_DESC",      "C",    TamSX3("CT1_DESC01")[1],0} )
 
//Excluindo dados da tabela temporária, se tiver aberta, fecha a tabela
If Select(cAliasTmp)>0
    (cAliasTmp)->(DbCloseArea())
EndIf
 

//Criando tabela temporária
//cArq:= CriaTrab( aStrut, .T. )             
//dbUseArea( .T.,NIL, cArq, cAliasTmp, .T., .F. )
//dbSelectArea(cAliasTmp)

oTmpTb := FWTemporaryTable():New( cAliasTmp ) 
oTmpTb:SetFields( aStrut )
oTmpTb:Create()

cTx := FA19Dlg01(cTx,cAliasTmp)
//cTx := FA19Dlg01(cTx,NIL)
    
FA19EdtCx(cAliasTmp)

//(cAliasTmp)->(DbCloseArea())
//FErase(cArq+GetDBExtension())
//FErase(cArq+OrdBagExt())

oTmpTb:Delete() 

RestArea(aArea)

Return Nil


Static Function FA19EdtCx(cAliasTmp)

Local aArea      := GetArea()
Local nTamBtn    := 50

Private nColunas := 0
Private nLinhas  := 0
Private aDados   := {}
Private oDlgPvt
Private oMGet19 
Private oSayTot
Private aHeader  := {}
Private aCols    := {}
Private aEdit    := {}
Private aStrut   := {}
Private aAux     := {}

//Tamanho da Janela
Private aTamanho := MsAdvSize()
Private nJanLarg := aTamanho[5]
Private nJanAltu := aTamanho[6]
Private nColMeio := (nJanLarg)/4

Private bValMov  := {|| fValid("XX_MOV")}
Private bValData := {|| fValid("XX_DATA")}
Private bValHist := {|| fValid("XX_HIST")}
Private bValCC   := {|| fValid("XX_CCUS")}
Private bValValor:= {|| fValid("XX_VALOR")}
Private bValConta:= {|| fValid("XX_CONTA")}
Private bLinOk   := {|| fValid("LINHA")}
Private bfDeleta := {|| fDeleta()}

Private nPosMov
Private nPosData
Private nPosHist
Private nPosCC
Private nPosValor
Private nPosConta
Private nPosDescC
Private nPosDesc
Private nColDel
Private nTotPg := 0
Private nTotRc := 0

// Tabela temporária
dbSelectArea(cAliasTmp)
Count To nLinhas
nColunas := fCount()
aStrut   := (cAliasTmp)->(DbStruct())
(cAliasTmp)->(DbGoTop())

//Cabeçalho ...	Titulo          Campo				Mask		        Tamanho				    Dec					Valid               Usado	Tip		F3	    CBOX
aAdd(aHeader,{	"Mov"       ,	"XX_MOV"         ,	"@!"            ,	01                    ,	0                ,	"Eval(bValMov)"   ,	".T.",	"C",	""   ,	"P=Pagar;R=Receber;"})
aAdd(aHeader,{	"Data"      ,	"XX_DATA"        ,	"@E"            ,	08                    ,	0                ,	"Eval(bValData)"  ,	".T.",	"D",	""   ,	""})
aAdd(aHeader,{	"Histórico" ,	"XX_HIST"        ,	"@!"            ,	TamSX3("E5_HISTOR")[1],	0                ,	"Eval(bValHist)"  ,	".T.",	"C",	""   ,	""})
aAdd(aHeader,{	"C.Custos"  ,	"XX_CCUS"        ,	"@!"            ,	TamSX3("CTT_CUSTO")[1],	0                ,	"Eval(bValCC)"    ,	".T.",	"C",	"CTT",	""})
aAdd(aHeader,{	"C.Custos"  ,	"XX_DESCC"       ,	"@!"            ,	TamSX3("CTT_DESC01")[1],0                ,	".T."             ,	".T.",	"C",	""   ,	""})
aAdd(aHeader,{	"Valor"     ,	"XX_VALOR"       ,	"@E 99999999.99",	09                    ,	0                ,	"Eval(bValValor)" ,	".T.",	"N",	""   ,	""})
aAdd(aHeader,{	"C.Contabil",	"XX_CONTA"       ,	"@!"            ,	TamSX3("CT1_CONTA")[1],	0                ,	"Eval(bValConta)" ,	".T.",	"C",	"CT1",	""})
aAdd(aHeader,{	"C.Contabil",	"XX_DESC"        ,	"@!"            ,	TamSX3("CT1_DESC01")[1],0                ,	".T."             ,	".T.",	"C",	""   ,	""})

aAdd(aEdit, "XX_MOV" )
aAdd(aEdit, "XX_DATA" )
aAdd(aEdit, "XX_HIST" )
aAdd(aEdit, "XX_CCUS" )
aAdd(aEdit, "XX_VALOR" )
aAdd(aEdit, "XX_CONTA" )

nPosMov   := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_MOV"})
nPosData  := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_DATA"})
nPosHist  := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_HIST"})
nPosCC    := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_CCUS"})
nPosDescC := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_DESCC"})
nPosValor := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_VALOR"})
nPosConta := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_CONTA"})
nPosDesc  := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_DESC"})
nColDel   := LEN(aHeader) + 1

//Percorrendo as linhas e adicionando no aCols
While ! (cAliasTmp)->(EoF())
	//Montando a linha atual
	aAux := Array(Len(aHeader)+1)
	For nAtual := 1 To Len(aStrut)
		aAux[nAtual] := &((cAliasTmp)->(aStrut[nAtual,1]))
	Next
	aAux[Len(aHeader)+1] := .F.
	
	//Adiciona no aCols
	aAdd(aCols, aClone(aAux))
		
	(cAliasTmp)->(DbSkip())
EndDo
	
//Montando a tela
DEFINE MSDIALOG oDlgPvt TITLE "Movimento do caixinha" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Dados
	@ 000, 003  GROUP oGrpBc  TO 027, (nJanLarg/2)-003  PROMPT "Dados da conta para movimentação financeira:"  OF oDlgPvt PIXEL

	@ 012, 010 SAY "Banco:"  SIZE 50, 7 OF oDlgPvt PIXEL 
    @ 010, 030 MSGET cBanco Picture "@!"  When .T. SIZE 50, 11 OF oDlgPvt PIXEL F3 "SA6" VALID (NaoVazio(cBanco) .AND. ExistCpo("SA6") .AND. !EMPTY(cNomeBc:=SA6->A6_NOME) )
                        
    @ 012, 090 SAY "Agência:" SIZE 50, 7 OF oDlgPvt PIXEL
    @ 010, 120 MSGET cAgencia Picture "@!" When .F. SIZE 30, 11 OF oDlgPvt PIXEL VALID NaoVazio(cAgencia)

    @ 012, 160 SAY "Conta:" SIZE 50, 7 OF oDlgPvt PIXEL
    @ 010, 180 MSGET cNumCon Picture "@!" When .F. SIZE 60, 11 OF oDlgPvt PIXEL VALID NaoVazio(cNumCon)

    @ 010, 250 MSGET cNomeBc Picture "@!" When .F. SIZE 120, 11 OF oDlgPvt PIXEL 

    @ 012, 380 SAY "Data:" SIZE 50, 7 OF oDlgPvt PIXEL
    @ 010, 400 MSGET dDataMov Picture "@E" When .F. SIZE 50, 11 OF oDlgPvt PIXEL


	@ 030, 003  GROUP oGrpDad TO (nJanAltu/2)-030, (nJanLarg/2)-003  PROMPT "Dados: "  OF oDlgPvt PIXEL

		oMGet19 := MsNewGetDados():New(	040,;          					//nTop
										006,;          					//nLeft
										(nJanAltu/2)-033,;        		//nBottom
										(nJanLarg/2)-006,;       		//nRight
										GD_INSERT+GD_DELETE+GD_UPDATE,;	//nStyle
										"Eval(bLinOk)",; 	      		//cLinhaOk
										,;           					//cTudoOk
										"",;          					//cIniCpos
										aEdit,;          				//aAlter
										,;           					//nFreeze
										9999999,;         				//nMax
										,;           					//cFieldOK
										,;           					//cSuperDel
										"Eval(bfDeleta)",;				//cDelOk
										oDlgPvt,;     					//oWnd
										aHeader,;        				//aHeader
										aCols)         					//aCols

			
	//Ações
	@ (nJanAltu/2)-25, 03 GROUP oGrpAco TO (nJanAltu/2)-003, (nJanLarg/2)-003  PROMPT "Ações: "  OF oDlgPvt PIXEL

	@ (nJanAltu/2)-19+5, 10 SAY oSayTot PROMPT "Total a pagar: "+TRANSFORM(nTotPg,"@E 999,999,999.99")+"        Total a receber: "+TRANSFORM(nTotRc,"@E 999,999,999.99") SIZE 250, 10 OF oDlgPvt COLORS RGB(0,0,0) PIXEL
	@ (nJanAltu/2)-19  , (nJanLarg/2)-((nTamBtn*1)+06) BUTTON oBtnConf PROMPT "Cancelar"   SIZE nTamBtn, 013 OF oDlgPvt ACTION(oDlgPvt:End())                   PIXEL
	@ (nJanAltu/2)-19  , (nJanLarg/2)-((nTamBtn*2)+09) BUTTON oBtnLimp PROMPT "Salvar"     SIZE nTamBtn, 013 OF oDlgPvt ACTION(If(fValid("TODOS"),fSalvar(),))  PIXEL


ACTIVATE MSDIALOG oDlgPvt CENTERED
	 
RestArea(aArea)

Return 



Static Function fDeleta()
If !EMPTY(oMGet19)
	oMGet19:aCols[oMGet19:nAt, nColDel] := !oMGet19:aCols[oMGet19:nAt, nColDel]
	oMGet19:Refresh() 
	SomaTot()
EndIf
Return()


Static Function SomaTot()
Local nY := 0
nTotPg := 0
nTotRc := 0
For nY := 1 to Len(oMGet19:aCols)
	If !oMGet19:aCols[nY][nColDel]
		If oMGet19:aCols[nY][nPosMov] = "P"
			nTotPg += oMGet19:aCols[nY][nPosValor]
		Else
			nTotRc += oMGet19:aCols[nY][nPosValor]
		EndIf
	EndIf
Next nY
oSayTot:Refresh()
Return Nil



Static Function fValid(cCampo)

Local lRet := .T.
Local nY

If cCampo == "TODOS"
	// Valida todas as linhas
	For nY := 1 to Len(oMGet19:aCols)
		If !oMGet19:aCols[nY][nColDel]
			If !fValCampo("XX_MOV",nY,.F.) .Or.;
				!fValCampo("XX_DATA",nY,.F.) .Or.;
				!fValCampo("XX_HIST",nY,.F.) .Or.;
				!fValCampo("XX_CCUS",nY,.F.) .Or.;
				!fValCampo("XX_VALOR",nY,.F.) .Or.;
				!fValCampo("XX_CONTA",nY,.F.)
				MsgStop("Problema encontrado na linha "+AllTrim(Str(nY)),"Atenção!")
				oMGet19:GoTo(nY)
				Return .F.
			EndIf
		EndIf
	Next nY
ElseIf cCampo == "LINHA"
	// Valida a linha
	nY := oMGet19:nAt
	If !oMGet19:aCols[nY][nColDel]
		If !fValCampo("XX_MOV",nY,.F.) .Or.;
			!fValCampo("XX_DATA",nY,.F.) .Or.;
			!fValCampo("XX_HIST",nY,.F.) .Or.;
			!fValCampo("XX_CCUS",nY,.F.) .Or.;
			!fValCampo("XX_VALOR",nY,.F.) .Or.;
			!fValCampo("XX_CONTA",nY,.F.)
			Return .F.
		EndIf
		//SomaTot()
	EndIf
Else
	// Valida o campo digitado
	lRet := fValCampo(cCampo,oMGet19:nAt,.T.)
EndIf
Return (lRet)

 

Static Function fValCampo(cCampo,nY,lDigitado)
Local cHist := ""
Local cConta
Local cTipoMov

If cCampo == "XX_MOV"
	If !IIf(lDigitado,M->XX_MOV,oMGet19:aCols[nY][nPosMov]) $ "RP"
		MsgStop("Preencha corretamente tipo de movimento!","Atenção!")
		Return(.F.)
	EndIf
	If lDigitado
		oMGet19:aCols[nY][nPosMov] := M->XX_MOV
	EndIf
	SomaTot()
ElseIf cCampo == "XX_DATA"
	If Empty(If(lDigitado,M->XX_DATA,oMGet19:aCols[nY][nPosData]))
		MsgStop("Preencha a data do movimento!","Atenção!")
		Return(.F.)
	EndIf
ElseIf cCampo == "XX_HIST"
	cHist := If(lDigitado,M->XX_HIST,oMGet19:aCols[nY][nPosHist])
	If Empty(cHist)
		MsgStop("Preencha o histórico do movimento!","Atenção!")
		Return(.F.)
	EndIf
        
	If lDigitado .OR. Empty(oMGet19:aCols[nY][nPosConta])
		cConta   := SPACE(LEN(CT1->CT1_CONTA))
		cTipoMov := " "
		BuscaFacil(cHist,@cConta,@cTipoMov)
		oMGet19:aCols[nY][nPosConta] := cConta

		CT1->(DbSetOrder(1))
		If CT1->(DbSeek(xFilial("CT1")+cConta)) 
			oMGet19:aCols[nY][nPosDesc] := CT1->CT1_DESC01
		Else
			oMGet19:aCols[nY][nPosDesc] := SPACE(LEN(CT1->CT1_DESC01))
		EndIf
    EndIf

ElseIf cCampo == "XX_CCUS"
	If Empty(If(lDigitado,M->XX_CCUS,oMGet19:aCols[nY][nPosCC]))
		MsgStop("Preencha o centro de custos do movimento!","Atenção!")
		Return(.F.)
	EndIf

	CTT->(DbSetOrder(1))
	If !CTT->(DbSeek(xFilial("CTT")+If(lDigitado,M->XX_CCUS,oMGet19:aCols[nY][nPosCC]))) 
		MsgStop("Centro de custos não encontrado!","Atenção!")
		oMGet19:aCols[nY][nPosDescC] := ""
		Return(.F.)
	Else
		oMGet19:aCols[nY][nPosDescC] := CTT->CTT_DESC01
		If CTT->CTT_CLASSE == "1"
			MsgStop("Conta do centro de custos dever ser analítica!","Atenção!")
			Return(.F.)
		EndIf
	EndIf
	If lDigitado
		If M->XX_CCUS != oMGet19:aCols[nY][nPosCC]
//			oMGet19:aCols[nY][nPosDesc] := CTT->CTT_DESC
		EndIf
	EndIf
ElseIf cCampo == "XX_VALOR"
	If Empty(If(lDigitado,M->XX_VALOR,oMGet19:aCols[nY][nPosValor]))
		MsgStop("Preencha o valor do movimento!","Atenção!")
		Return(.F.)
	EndIf
	If lDigitado
		oMGet19:aCols[nY][nPosValor] := M->XX_VALOR
	EndIf
	SomaTot()
ElseIf cCampo == "XX_CONTA"
	If Empty(If(lDigitado,M->XX_CONTA,oMGet19:aCols[nY][nPosConta]))
		MsgStop("Preencha a conta contábil!","Atenção!")
		Return(.F.)
	EndIf

	CT1->(DbSetOrder(1))
	If !CT1->(DbSeek(xFilial("CT1")+If(lDigitado,M->XX_CONTA,oMGet19:aCols[nY][nPosConta]))) 
		MsgStop("Conta não encontrada!","Atenção!")
		oMGet19:aCols[nY][nPosDesc] := ""
		Return(.F.)
	Else
		oMGet19:aCols[nY][nPosDesc] := CT1->CT1_DESC01
		If CT1->CT1_CLASSE == "1"
			MsgStop("Conta dever ser analítica!","Atenção!")
			Return(.F.)
		EndIf
	EndIf

	If lDigitado
		If M->XX_CONTA != oMGet19:aCols[nY][nPosConta]
//			oMGet19:aCols[nY][nPosDesc] := CTT->CTT_DESC
		EndIf
	EndIf
EndIf

Return(.T.)



Static Function fSalvar()
Local lRet := .F.

MsgRun("Aguarde, gerando movimentação bancária…","",{|| CursorWait(), lRet := fProcessa1() ,CursorArrow()})

If lRet
	oDlgPvt:End()
EndIf

Return

 
 

Static Function fProcessa1()

Local nX, nY
Local aUsuarios := ALLUSERS()
Local nOpc      := 0
Local aFina100  := {}
Local lSucess	:= .T.

Private lMsErroAuto := .F.

nX := aScan(aUsuarios,{|x| x[1][1] == __cUserID})

If nX > 0
	cUsuario := aUsuarios[nX][1][2]
EndIf

BEGIN TRANSACTION
	
	For nY := 1 to Len(oMGet19:aCols)

		If !oMGet19:aCols[nY][nColDel] 	

			// Movimento bancário
	/*
	nPosMov   := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_MOV"})
	nPosData  := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_DATA"})
	nPosHist  := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_HIST"})
	nPosCC    := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_CCUS"})
	nPosValor := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_VALOR"})
	nPosConta := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_CONTA"})
	nPosDesc  := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_DESC"})
	*/
	
			 aFina100 := {    {"E5_DATA"    ,oMGet19:aCols[nY][nPosData]  ,Nil},;
	                          {"E5_MOEDA"   ,"01"                         ,Nil},;
	                          {"E5_VALOR"   ,oMGet19:aCols[nY][nPosValor] ,Nil},;
	                          {"E5_NATUREZ" ,"0000000056"                 ,Nil},;
	                          {"E5_BANCO"   ,cBanco                       ,Nil},;
	                          {"E5_AGENCIA" ,cAgencia                     ,Nil},;
	                          {"E5_CONTA"   ,cNumCon                      ,Nil},;
	                          {"E5_BENEF"   ,cNomeBc                      ,Nil},;
	                          {"E5_HISTOR"  ,oMGet19:aCols[nY][nPosHist]  ,Nil}}
	    
			lMsErroAuto := .F.
			If oMGet19:aCols[nY][nPosMov] = "P"
				nOpc := 3  
				AADD(aFina100,{"E5_DEBITO"  ,oMGet19:aCols[nY][nPosConta] ,Nil})
				AADD(aFina100,{"E5_CCD"     ,oMGet19:aCols[nY][nPosCC]    ,Nil})
			Else
				nOpc := 4
				AADD(aFina100,{"E5_CREDITO" ,oMGet19:aCols[nY][nPosConta] ,Nil})
				AADD(aFina100,{"E5_CCC"     ,oMGet19:aCols[nY][nPosCC]    ,Nil})
			Endif
			
	        MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,nOpc)
			
			If lMsErroAuto
				MostraErro()
				DisarmTransaction()
				lSucess := .F.
			EndIf
		EndIf
	Next

END TRANSACTION

If lSucess
	Aviso("Sucesso","Movimentos bancários realizadas com sucesso.",{"OK"})
Else
	Aviso("Erro!","Alguns movimentos bancários não foram realizadas",{"OK"})
EndIf

Return lSucess



//Tela para colagem de dados do excel 
// Para cada linha:
// 1- O sistema busca uma primeira barra para encontrar a data do lançamento 
// 2- Depois procura o padrão de um centro de custos 999.999.999 ou 999999999
// 3- O que ficou entre a data e o centro de custos, condidera-se o histórico
// 4- O que sobrou depois do centro de custos, considera-se o valor

STATIC Function FA19Dlg01(cTexto1,cAliasTmp)
Local aAreaAtu			:= GetArea()
Local oDlg01,aButtons 	:= {},lOk := .F.
Local nSnd    			:= 0,nTLin := 15
Local nSin    			:= 5

Local cCrLf   			:= Chr(13) + Chr(10)
Local cTexto            := cTexto1 
Local cChar             := ""
Local cRet              := ""
Local cLinha            := ""
Local nPosCC            := 0
Local nPosVal           := 0
Local cConta            := ""
Local cTipoMov          := ""
Local cDesc             := ""
Local cCC               := ""
Local cData             := ""
Local cVal              := ""
Local cHist             := ""
Local nI,nTamTex,nJ,nK,nL

Define MsDialog oDlg01 Title "Importação de dados: Excel --> Mov. Bancário" From 000,000 To 260+(nSin*nTLin),600 Of oDlg01 Pixel

nSnd := 35
@ nSnd,010 Say 'Cole as colunas do excel: data (dd/mm/aaaa),historico,ccusto,vl. entrada, vl saida'  Size 240,010 Pixel Of oDlg01
nSnd += nTLin
oMemo:= tMultiget():New(nSnd,10,{|u|if(Pcount()>0,cTexto :=u,cTexto )},oDlg01,280,100,,,,,,.T.)
nSnd += nTLin

ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

If ( lOk ) 
	lOk:=.F.
	cTexto  := FwNoAccent(cTexto) 
	nTamTex := mlCount(cTexto, 200)
	
	For nI := 1 To nTamTex
		cLinha := memoline(cTexto, 200, nI)
		
		nK := 0
		// Data
		For nJ := 1 TO LEN(cLinha)
			If SUBSTR(cLinha,nJ,1) == "/" .and. nJ > 2
				cData := SUBSTR(cLinha,nJ-2,10)
				nK := nJ-2 + 10 + 1
				Exit
			EndIf
		Next
        
		nPosCC  := 0
		nPosVal := 0
		// Centro de custo -> padrão 999.999.999 ou 999999999
		For nJ := nK TO LEN(cLinha)
			cCC := ""
			cChar := SUBSTR(cLinha,nJ,1)
			If cChar $ "0123456789"
				nPosCC := nJ
				For nL := nJ to LEN(cLinha)
					cChar := SUBSTR(cLinha,nL,1)
					If cChar $ "0123456789"
					    cCC += SUBSTR(cLinha,nL,1)
					ElseIf cChar <> "."
						If Len(cCC) < 9
							cCC := ""
						Else
							nPosVal := nL + 1	
							EXIT
						EndIf 
					EndIf
				Next
			EndIf
			If Len(cCC) >= 9
				EXIT
			EndIf			
		Next			
						
		// Histórico
		If nPosCC > nK .AND. nK > 0 .AND. nPosCC > 0
			cHist := ALLTRIM(SUBSTR(cLinha,nK,nPosCC - nK))
		EndIf
		
		// Valor de Entrada
		cVal := ""
		If nPosVal > 0
			cVal := SUBSTR(cLinha,nPosVal,LEN(cLinha) - nPosVal + 1)
			cVal := STRTRAN(cVal,",",".")
		EndIf

		// Conta 
		cConta   := ""
		cTipoMov := "P"
		BuscaFacil(cHist,@cConta,@cTipoMov)		
			
		cRet += "Data: "+cData+" Hist.: "+cHist+"  CC: "+cCC+ " Valor: "+ALLTRIM(cVal) + " Conta: "+cConta+cCrLf 
		
		If !EMPTY(cAliasTmp)
			cDesc := ""
			If !EMPTY(cConta)
				If CT1->(DbSeek(xFilial("CT1")+cConta))
					cDesc := CT1->CT1_DESC01
				EndIf
			EndIf	

			cDescC := ""
			If !EMPTY(cCC)
				If CTT->(DbSeek(xFilial("CTT")+cCC))
					cDescC := CTT->CTT_DESC01
				EndIf
			EndIf	
				
			dbSelectArea(cAliasTmp)
			Reclock(cAliasTmp,.T.)
			(cAliasTmp)->XX_MOV   := cTipoMov
			(cAliasTmp)->XX_DATA  := dDataMov //CTOD(cData)
			(cAliasTmp)->XX_HIST  := cHist
			(cAliasTmp)->XX_CCUS  := cCC
			(cAliasTmp)->XX_DESCC := cDescC
			(cAliasTmp)->XX_VALOR := VAL(ALLTRIM(cVal))
			(cAliasTmp)->XX_CONTA := cConta
			(cAliasTmp)->XX_DESC  := cDesc
		EndIf		
		
	Next

	//cTexto := STRTRAN(cTexto,cCrLf,"")
	
EndIf

RestArea( aAreaAtu )

Return cRet
                  

Static Function LoadFacil()
Local aRet := {}
Local aPalavras := {} 
Local nI := 0 
Local cDocumen := ""

dbSelectArea("SZK")
dbGoTop()
Do While !EOF()
	If ZK_COD == "99"
		cDocumen := SZK->ZK_DOCUMEN
		If LEN(ALLTRIM(cDocumen)) > 0 .AND. !(";" $ cDocumen)
		   cDocumen := ALLTRIM(cDocumen)+";"
		EndIf
		aPalavras := StrTokArr(cDocumen,";")
		For nI := 1 TO Len(aPalavras)
			If !EMPTY(aPalavras[nI])  
				aAdd(aRet, { UPPER(aPalavras[nI]), SZK->ZK_TIPO, IIF(EMPTY(SZK->ZK_DEBITO),SZK->ZK_CREDITO,SZK->ZK_DEBITO) } )
			EndIf
		Next
    EndIf
    dbSkip()
EndDo

Return aRet




Static Function BuscaFacil(cHist,cConta,cTipoMov)

Local aPalavras   := {}
Local cPalavra    := ""
Local cPalavraPos := ""
Local nP          := 0
Local nPalavra    := 0

aPalavras := StrTokArr(cHist," ")

For nP := 1 TO Len(aPalavras)
	cPalavra    := ALLTRIM(UPPER(aPalavras[nP]))
	If LEN(cPalavra) > 1
		cPalavraPos := ""
		If nP < LEN(aPalavras)
			cPalavraPos := ALLTRIM(UPPER(aPalavras[nP+1]))
			If !EMPTY(cPalavraPos)
				nPalavra := ASCAN(aFacil, { |x| x[1] == cPalavra+" "+cPalavraPos } )
				If nPalavra > 0 
					cTipoMov := aFacil[nPalavra,2]
					cConta   := aFacil[nPalavra,3]
					Exit
				EndIf
			EndIf
		EndIf
		nPalavra := ASCAN(aFacil, { |x| x[1] == cPalavra } )
		If nPalavra > 0 
			cTipoMov := aFacil[nPalavra,2]
			cConta   := aFacil[nPalavra,3]
			Exit
		EndIf
	EndIf
Next
Return Nil
