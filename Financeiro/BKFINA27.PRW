#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINA27
Balsa Nova - Baixas de contas a pagar - titulos pagos na BK 
@Return
@author Marcos Bispo Abrahão
@since 16/11/2021
@version P12
/*/
//-------------------------------------------------------------------

User Function BKFINA27()
Local aArea     := GetArea()
Local cAliasTmp := GetNextAlias()
Local oTmpTb
Local aStrut    := {}
Local cTx       := ""
Private aFacil  := {}
Private cBanco  := PAD("",TamSX3("A6_COD")[1])
Private cAgencia:= PAD("",TamSX3("A6_AGENCIA")[1])
Private cNumCon := PAD("",TamSX3("A6_NUMCON")[1])
Private cNomeBc := PAD("",TamSX3("A6_NOME")[1]) 
Private dDataMov:= dDataBase


//              Campo        Tipo    Tamanho            Decimal
aAdd( aStrut, { "XX_PREFIXO","C", TamSX3("E2_PREFIXO")[1], 0} )
aAdd( aStrut, { "XX_NUM",    "C", TamSX3("E2_NUM")[1]    , 0} )
aAdd( aStrut, { "XX_PARCELA","C", TamSX3("E2_PARCELA")[1], 0} )
aAdd( aStrut, { "XX_TIPO",   "C", TamSX3("E2_TIPO")[1]   , 0} )
aAdd( aStrut, { "XX_FORNECE","C", TamSX3("E2_FORNECE")[1], 0} )
aAdd( aStrut, { "XX_LOJA",   "C", TamSX3("E2_LOJA")[1]   , 0} )
aAdd( aStrut, { "XX_NOMFOR", "C", TamSX3("E2_NOMFOR")[1] , 0} )
aAdd( aStrut, { "XX_EMISSAO","D", TamSX3("E2_EMISSAO")[1], 0} )
aAdd( aStrut, { "XX_VENCTO", "D", TamSX3("E2_VENCTO")[1] , 0} )
aAdd( aStrut, { "XX_VENCREA","D", TamSX3("E2_VENCREA")[1] , 0} )
aAdd( aStrut, { "XX_VALOR",  "N", TamSX3("E2_VALOR")[1], TamSX3("E2_VALOR")[2]} )
aAdd( aStrut, { "XX_PORTADO", "C", TamSX3("E2_PORTADO")[1] , 0} )

//Criando tabela temporária
//cArq:= CriaTrab( aStrut, .T. )             
//dbUseArea( .T.,NIL, cArq, cAliasTmp, .T., .F. )
//dbSelectArea(cAliasTmp)
 
oTmpTb := FWTemporaryTable():New( cAliasTmp ) 
oTmpTb:SetFields( aStrut )
oTmpTb:Create()

cTx := FA27Dlg01(cTx,cAliasTmp)
    
FA22EdtCx(cAliasTmp)

oTmpTb:Delete() 
//(cAliasTmp)->(DbCloseArea())
//FErase(cArq+GetDBExtension())
//FErase(cArq+OrdBagExt())

RestArea(aArea)

Return Nil


Static Function FA22EdtCx(cAliasTmp)

Local aArea      := GetArea()
Local nTamBtn    := 50
Local nAtual	 := 0

Private nColunas := 0
Private nLinhas  := 0
Private aDados   := {}
Private oDlgPvt
Private oMGet22 
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

Private bfDeleta := {|| fDeleta()}

Private nPosPrefixo
Private nPosNUM
Private nPosPARCELA
Private nPosTIPO
Private nPosFORNECE
Private nPosLOJA
Private nPosValor

Private nColDel
Private nTotPg := 0
Private nTotRc := 0

// Tabela temporária
dbSelectArea(cAliasTmp)
Count To nLinhas
nColunas := fCount()
aStrut   := (cAliasTmp)->(DbStruct())
(cAliasTmp)->(DbGoTop())

//Cabeçalho ...	Titulo          Campo				Mask		        Tamanho				    Dec									Valid               Usado	Tip		F3	       CBOX
aAdd(aHeader,{	"Prefixo"   ,	"XX_PREFIXO"  	,	"@!"            ,TamSX3("E2_PREFIXO")[1],	0                				,	".T."   		,	".T.",	"C",	""   	,	""})
aAdd(aHeader,{	"No. Titulo"  ,	"XX_NUM"        ,	"@!"            ,TamSX3("E2_NUM")[1]    ,	0                				,	".T."  			,	".T.",	"C",	""   	,	""})
aAdd(aHeader,{	"Parcela"   ,	"XX_PARCELA"    ,	"@!"            ,TamSX3("E2_PARCELA")[1],	0                				,	".T."  			,	".T.",	"C",	""   	,	""})
aAdd(aHeader,{	"Tipo"      ,	"XX_TIPO"       ,	"@!"            ,TamSX3("E2_TIPO")[1],		0                				,	".T."    		,	".T.",	"C",	"05"   	,	""})
aAdd(aHeader,{	"Fornecedor" ,	"XX_FORNECE"    ,	"@!"            ,TamSX3("E2_FORNECE")[1],	0               				,	".T."           ,	".T.",	"C",	""   	,	""})
aAdd(aHeader,{	"LOJA"      ,	"XX_LOJA"       ,	"@!"            ,TamSX3("E2_LOJA")[1],		0                				,	".T."           ,	".T.",	"C",	""   	,	""})
aAdd(aHeader,{	"Nome Fornece",	"XX_NOMFOR"     ,	"@!"            ,TamSX3("E2_NOMFOR")[1],	0                				,	".T."           ,	".T.",	"C",	"FOR"   ,	""})
aAdd(aHeader,{	"DT Emissao"  ,	"XX_EMISSAO"    ,	"@!"            ,TamSX3("E2_EMISSAO")[1],	0              					,	".T." 			,	".T.",	"D",	""   	,	""})
aAdd(aHeader,{	"Vencimento",	"XX_VENCTO"     ,	"@!"            ,TamSX3("E2_VENCTO")[1],	0               				,	".T."           ,	".T.",	"D",	""   	,	""})
aAdd(aHeader,{	"Vencto Real" ,	"XX_VENCTO"     ,	"@!"            ,TamSX3("E2_VENCREA")[1],	0              				  	,	".T."           ,	".T.",	"D",	""   	,	""})
aAdd(aHeader,{	"Valor"     ,	"XX_VALOR"    	,	"@E 999,999,999,999,999.99",TamSX3("E2_VALOR")[1],TamSX3("E2_VALOR")[2] 	,	".T." 			,	".T.",	"N",	""   	,	""})
aAdd(aHeader,{	"Portado" ,		"XX_PORTADO"    ,	"@!"            ,TamSX3("E2_PORTADO")[1],	0                				,	".T."           ,	".T.",	"C",	"BCO"   ,	""})

nPosPrefixo := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_PREFIXO"})
nPosNUM 	:= aScan(aHeader, {|x| AllTrim(x[2]) == "XX_NUM"})
nPosPARCELA := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_PARCELA"})
nPosTIPO	:= aScan(aHeader, {|x| AllTrim(x[2]) == "XX_TIPO"})
nPosFORNECE := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_FORNECE"})
nPosLOJA  	:= aScan(aHeader, {|x| AllTrim(x[2]) == "XX_LOJA"})
nPosVALOR 	:= aScan(aHeader, {|x| AllTrim(x[2]) == "XX_VALOR"})
nColDel   	:= LEN(aHeader) + 1

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
DEFINE MSDIALOG oDlgPvt TITLE "Baixa Contas a Pagar" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
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

		oMGet22 := MsNewGetDados():New(	040,;          					//nTop
										006,;          					//nLeft
										(nJanAltu/2)-033,;        		//nBottom
										(nJanLarg/2)-006,;       		//nRight
										GD_DELETE,;	                    //nStyle
										"",; 	      	   				//cLinhaOk
										,;           					//cTudoOk
										"",;          					//cIniCpos
										,;          			    	//aAlter
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

	@ (nJanAltu/2)-19+5, 10 SAY oSayTot PROMPT "Total a pagar: "+TRANSFORM(nTotPg,"@E 999,999,999.99") SIZE 250, 10 OF oDlgPvt COLORS RGB(0,0,0) PIXEL
	@ (nJanAltu/2)-19  , (nJanLarg/2)-((nTamBtn*1)+06) BUTTON oBtnConf PROMPT "Cancelar"   SIZE nTamBtn, 013 OF oDlgPvt ACTION(oDlgPvt:End())                   PIXEL
	@ (nJanAltu/2)-19  , (nJanLarg/2)-((nTamBtn*2)+09) BUTTON oBtnLimp PROMPT "Baixar"     SIZE nTamBtn, 013 OF oDlgPvt ACTION(If(fValid("TODOS"),fSalvar(),))  PIXEL


ACTIVATE MSDIALOG oDlgPvt CENTERED
	 
RestArea(aArea)

Return 



Static Function fDeleta()
If !EMPTY(oMGet22)
	oMGet22:aCols[oMGet22:nAt, nColDel] := !oMGet22:aCols[oMGet22:nAt, nColDel]
	oMGet22:Refresh() 
	SomaTot()
EndIf
Return()


Static Function SomaTot()
Local nY := 0
nTotPg := 0
nTotRc := 0
For nY := 1 to Len(oMGet22:aCols)
	If !oMGet22:aCols[nY][nColDel]
		nTotPg += oMGet22:aCols[nY][nPosValor]
	EndIf
Next nY
oSayTot:Refresh()
Return Nil



Static Function fValid(cCampo)

Local lRet := .T.

/*
Local nY
If cCampo == "TODOS"
	// Valida todas as linhas
	For nY := 1 to Len(oMGet22:aCols)
		If !oMGet22:aCols[nY][nColDel]
			If !fValCampo("XX_MOV",nY,.F.) .Or.;
				!fValCampo("XX_DATA",nY,.F.) .Or.;
				!fValCampo("XX_HIST",nY,.F.) .Or.;
				!fValCampo("XX_CCUS",nY,.F.) .Or.;
				!fValCampo("XX_VALOR",nY,.F.) .Or.;
				!fValCampo("XX_CONTA",nY,.F.)
				MsgStop("Problema encontrado na linha "+AllTrim(Str(nY)),"Atenção!")
				oMGet22:GoTo(nY)
				Return .F.
			EndIf
		EndIf
	Next nY
ElseIf cCampo == "LINHA"
	// Valida a linha
	nY := oMGet22:nAt
	If !oMGet22:aCols[nY][nColDel]
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
	lRet := fValCampo(cCampo,oMGet22:nAt,.T.)
EndIf 
*/
If .F. // Remover Warning de Compilação
	fValCampo(cCampo,0,.F.)
EndIf

Return (lRet)

 

Static Function fValCampo(cCampo,nY,lDigitado)
Local cHist := ""
Local cConta
Local cTipoMov

If cCampo == "XX_MOV"
	If !IIf(lDigitado,M->XX_MOV,oMGet22:aCols[nY][nPosMov]) $ "RP"
		MsgStop("Preencha corretamente tipo de movimento!","Atenção!")
		Return(.F.)
	EndIf
	If lDigitado
		oMGet22:aCols[nY][nPosMov] := M->XX_MOV
	EndIf
	SomaTot()
ElseIf cCampo == "XX_DATA"
	If Empty(If(lDigitado,M->XX_DATA,oMGet22:aCols[nY][nPosData]))
		MsgStop("Preencha a data do movimento!","Atenção!")
		Return(.F.)
	EndIf
ElseIf cCampo == "XX_HIST"
	cHist := If(lDigitado,M->XX_HIST,oMGet22:aCols[nY][nPosHist])
	If Empty(cHist)
		MsgStop("Preencha o histórico do movimento!","Atenção!")
		Return(.F.)
	EndIf
        
	If lDigitado .OR. Empty(oMGet22:aCols[nY][nPosConta])
		cConta   := SPACE(LEN(CT1->CT1_CONTA))
		cTipoMov := " "
		BuscaFacil(cHist,@cConta,@cTipoMov)
		oMGet22:aCols[nY][nPosConta] := cConta

		CT1->(DbSetOrder(1))
		If CT1->(DbSeek(xFilial("CT1")+cConta)) 
			oMGet22:aCols[nY][nPosDesc] := CT1->CT1_DESC01
		Else
			oMGet22:aCols[nY][nPosDesc] := SPACE(LEN(CT1->CT1_DESC01))
		EndIf
    EndIf

ElseIf cCampo == "XX_CCUS"
	If Empty(If(lDigitado,M->XX_CCUS,oMGet22:aCols[nY][nPosCC]))
		MsgStop("Preencha o centro de custos do movimento!","Atenção!")
		Return(.F.)
	EndIf

	CTT->(DbSetOrder(1))
	If !CTT->(DbSeek(xFilial("CTT")+If(lDigitado,M->XX_CCUS,oMGet22:aCols[nY][nPosCC]))) 
		MsgStop("Centro de custos não encontrado!","Atenção!")
		oMGet22:aCols[nY][nPosDescC] := ""
		Return(.F.)
	Else
		oMGet22:aCols[nY][nPosDescC] := CTT->CTT_DESC01
		If CTT->CTT_CLASSE == "1"
			MsgStop("Conta do centro de custos dever ser analítica!","Atenção!")
			Return(.F.)
		EndIf
	EndIf
	If lDigitado
		If M->XX_CCUS != oMGet22:aCols[nY][nPosCC]
//			oMGet22:aCols[nY][nPosDesc] := CTT->CTT_DESC
		EndIf
	EndIf
ElseIf cCampo == "XX_VALOR"
	If Empty(If(lDigitado,M->XX_VALOR,oMGet22:aCols[nY][nPosValor]))
		MsgStop("Preencha o valor do movimento!","Atenção!")
		Return(.F.)
	EndIf
	If lDigitado
		oMGet22:aCols[nY][nPosValor] := M->XX_VALOR
	EndIf
	SomaTot()
ElseIf cCampo == "XX_CONTA"
	If Empty(If(lDigitado,M->XX_CONTA,oMGet22:aCols[nY][nPosConta]))
		MsgStop("Preencha a conta contábil!","Atenção!")
		Return(.F.)
	EndIf

	CT1->(DbSetOrder(1))
	If !CT1->(DbSeek(xFilial("CT1")+If(lDigitado,M->XX_CONTA,oMGet22:aCols[nY][nPosConta]))) 
		MsgStop("Conta não encontrada!","Atenção!")
		oMGet22:aCols[nY][nPosDesc] := ""
		Return(.F.)
	Else
		oMGet22:aCols[nY][nPosDesc] := CT1->CT1_DESC01
		If CT1->CT1_CLASSE == "1"
			MsgStop("Conta dever ser analítica!","Atenção!")
			Return(.F.)
		EndIf
	EndIf

	If lDigitado
		If M->XX_CONTA != oMGet22:aCols[nY][nPosConta]
//			oMGet22:aCols[nY][nPosDesc] := CTT->CTT_DESC
		EndIf
	EndIf
EndIf

Return(.T.)



Static Function fSalvar()
Local lRet := .F.

MsgRun("Aguarde, gerando Baixa a Pagar…","",{|| CursorWait(), lRet := ProcBaixa() ,CursorArrow()})

If lRet
	oDlgPvt:End()
EndIf

Return

 
 

Static Function ProcBaixa()

Local nY
//Local aUsuarios := ALLUSERS()
Local aBaixa    := {}
Local lSucess	:= .T.

Private lMsErroAuto := .F.

/*
nX := aScan(aUsuarios,{|x| x[1][1] == __cUserID})

If nX > 0
	cUsuario := aUsuarios[nX][1][2]
EndIf
*/

BEGIN TRANSACTION
	
	For nY := 1 to Len(oMGet22:aCols)

		If !oMGet22:aCols[nY][nColDel] 	

	
	                          aBaixa := {}
	                          AADD(aBaixa, {"E2_FILIAL" , xFILIAL("SE2") , Nil})
	                          AADD(aBaixa, {"E2_PREFIXO" , oMGet22:aCols[nY][nPosPREFIXO] , Nil})
	                          AADD(aBaixa, {"E2_NUM" , oMGet22:aCols[nY][nPosNUM] , Nil})
	                          AADD(aBaixa, {"E2_PARCELA" , oMGet22:aCols[nY][nPosPARCELA] , Nil})
	                          AADD(aBaixa, {"E2_TIPO" , oMGet22:aCols[nY][nPosTIPO] , Nil})
	                          AADD(aBaixa, {"E2_FORNECE" , oMGet22:aCols[nY][nPosFORNECE] , Nil})
	                          AADD(aBaixa, {"E2_LOJA" , oMGet22:aCols[nY][nPosLOJA] , Nil}) 
	                          AADD(aBaixa, {"AUTMOTBX" , "DEBITO CC" , Nil})
	                          AADD(aBaixa, {"AUTBANCO" , cBanco , Nil})
	                          AADD(aBaixa, {"AUTAGENCIA" , cAgencia , Nil})
	                          AADD(aBaixa, {"AUTCONTA" , cNumCon , Nil})
	                          AADD(aBaixa, {"AUTDTBAIXA" , dDataMov , Nil}) 
	                          AADD(aBaixa, {"AUTDTCREDITO", dDataMov , Nil})
 //	                          AADD(aBaixa, {"AUTHIST" , cHistBaixa , Nil})
	                          AADD(aBaixa, {"AUTVLRPG" , oMGet22:aCols[nY][nPosValor] , Nil})

	                          ACESSAPERG("FIN080", .F.)

			lMsErroAuto := .F.
			MSEXECAUTO({|x,y| FINA080(x,y)}, aBaixa, 3)
			
			If lMsErroAuto
				MostraErro()
				DisarmTransaction()
				lSucess := .F.
			EndIf
		EndIf
	Next

END TRANSACTION

Aviso("Sucesso","Baixa contas a Pagar.",{"OK"})
If lSucess
	Aviso("Sucesso!","Baixas de contas a Pagar realizadas com sucesso.",{"OK"})
Else
	Aviso("Erro!","Algumas baixas de contas a Pagar não foram realizadas",{"OK"})
EndIf

Return lSucess


//Tela para colagem de dados do excel 
// Para cada linha:
// 1- O sistema busca uma primeira barra para encontrar a data do lançamento 
// 2- Depois procura o padrão de um centro de custos 999.999.999 ou 999999999
// 3- O que ficou entre a data e o centro de custos, condidera-se o histórico
// 4- O que sobrou depois do centro de custos, considera-se o valor

STATIC Function FA27Dlg01(cAliasTmp)
Local aAreaAtu			:= GetArea()
Local _cQuery 			:= ""

_cQuery := "SELECT E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,E2_NOMFOR,"
_cQuery += "E2_EMISSAO,E2_VENCTO,E2_VENCREA,E2_VALOR,E2_PORTADO,R_E_C_N_O_ as NREG"
_cQuery += " FROM "+RetSqlName("SE2")+" SE2"
_cQuery += " WHERE SE2.D_E_L_E_T_=''" 
_cQuery += " AND E2_VENCREA='"+DTOS(CTOD(cData))+"'"
_cQuery += " AND E2_VALOR="+ALLTRIM(cVal) 
_cQuery += " AND E2_BAIXA=''"
_cQuery += " AND E2_TIPO<>'PA'"
_cQuery += " AND E2_VALOR = E2_SALDO" 
	
TCQUERY _cQuery NEW ALIAS "QSE2"
	
TCSETFIELD("QSE2","E2_EMISSAO","D",8,0)
TCSETFIELD("QSE2","E2_VENCTO","D",8,0)
TCSETFIELD("QSE2","E2_VENCREA","D",8,0)

DbSelectArea("QSE2")
QSE2->(dbgotop())

Do While QSE2->(!eof())
	dbSelectArea(cAliasTmp)
	Reclock(cAliasTmp,.T.)
	(cAliasTmp)->XX_PREFIXO := QSE2->E2_PREFIXO
	(cAliasTmp)->XX_NUM 	:= QSE2->E2_NUM
	(cAliasTmp)->XX_PARCELA := QSE2->E2_PARCELA
	(cAliasTmp)->XX_TIPO 	:= QSE2->E2_TIPO
	(cAliasTmp)->XX_FORNECE := QSE2->E2_FORNECE
	(cAliasTmp)->XX_LOJA 	:= QSE2->E2_LOJA
	(cAliasTmp)->XX_NOMFOR 	:= QSE2->E2_NOMFOR
	(cAliasTmp)->XX_EMISSAO := QSE2->E2_EMISSAO
	(cAliasTmp)->XX_VENCTO 	:= QSE2->E2_VENCTO
	(cAliasTmp)->XX_VENCREA := QSE2->E2_VENCREA
	(cAliasTmp)->XX_VALOR 	:= VAL(ALLTRIM(cVal))
	(cAliasTmp)->XX_PORTADO := QSE2->E2_PORTADO
	(cAliasTmp)->(MsUnlock())         
	QSE2->(dbSkip())
ENDDO
QSE2->(dbCloseArea())

RestArea( aAreaAtu )

Return cRet
                  
