#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKCOMA19
BK - Incluir itens na Sol. de Compras via copia e cola do excel
Chamar no PE MA110BAR
@Return
@author Marcos Bispo Abrahão
@since 31/08/2022
@version P12
/*/

User Function BKCOMA19()
Local aArea     := GetArea()
Local oTmpTb
Local aStrut    := {}
Local cTx       := ""
Private cProg   := "BKCOMA19"
Private cAliasTmp := GetNextAlias()

//              Campo          Tipo    Tamanho                Decimal
aAdd( aStrut, { "XX_COD",      "C",    TamSX3("B1_COD")[1],   0                     } )
aAdd( aStrut, { "XX_DESC",     "C",    TamSX3("B1_DESC")[1],  0                     } )
aAdd( aStrut, { "XX_QUANT",    "N",    TamSX3("C1_QUANT")[1], TamSX3("C1_QUANT")[2] } )
 
//Excluindo dados da tabela temporária, se tiver aberta, fecha a tabela
If Select(cAliasTmp)>0
    (cAliasTmp)->(DbCloseArea())
EndIf
 
//Criando tabela temporária

oTmpTb := FWTemporaryTable():New( cAliasTmp ) 
oTmpTb:SetFields( aStrut )
oTmpTb:Create()

If CA19Dlg01(cTx,cAliasTmp)
    CA19EdtCx(cAliasTmp)
EndIf

oTmpTb:Delete() 

RestArea(aArea)

Return Nil


Static Function CA19EdtCx(cAliasTmp)

Local aArea      := GetArea()
Local nTamBtn    := 50
//Local nAtual	 := 0
Local nLin		 := 10
Local aMTCM      := U_StringToArray(GetSx3Cache("C1_XXMTCM", "X3_CBOX"),";") 
Local cFontUti    := "Tahoma"
Local oFontBtn    := TFont():New(cFontUti,,-14)

Private nColunas := 0
Private nLinhas  := 0
Private aDados   := {}
Private oDlgPvt
Private oMGet19 
Private oSayTot
Private aHeaderA := {}
Private aColunas := {}
Private aEdit    := {}
Private aStrut   := {}
Private aAux     := {}

//Tamanho da Janela
Private aTamanho := MsAdvSize()
Private nJanLarg := aTamanho[5]
Private nJanAltu := aTamanho[6]
Private nColMeio := (nJanLarg)/4

Private dDatPrf  := CTOD("")	
Private cXXMTCM  := "1"
Private cCC		 := TamSX3("C1_CC")[1]
Private cXXJUST  := ""
Private cXXDCC   := TamSX3("CTT_CUSTO")[1]
Private cXXENDEN := SC1->C1_XXENDENT

Private nPosCod
Private nPosDesc
Private nPosQuant
Private nColDel

// Tabela temporária
dbSelectArea(cAliasTmp)
(cAliasTmp)->(DbGoTop())

//Monta o cabecalho
fMontaHead()

// Variaveis do cabeçalho
dDatPrf := dDataBase+30 //CTOD("")	
cXXMTCM := "1"
cCC		:= PAD(u_CCPadrao(),TamSX3("C1_CC")[1])
cXXJUST := ""
cXXDCC  := SPACE(TamSX3("CTT_CUSTO")[1])

//Montando a tela
DEFINE MSDIALOG oDlgPvt TITLE "Inclusão de Itens Sol. de Compras" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Dados
	@ 000, 003  GROUP oGrpBc  TO 047, (nJanLarg/2)-003  PROMPT "Dados da Solicitação de Compras:"  OF oDlgPvt PIXEL

	@ nLin+2, 010 SAY "Limite Entrega:"  SIZE 50, 7 OF oDlgPvt PIXEL 
	@ nLin,   060 MSGET dDATPRF PIXEL VALID (dDatPrf > dDataBase) SIZE 50,10 Of oDlgPvt    


	@ nLin+2, 120 SAY 'Motivo da Compra' PIXEL SIZE 50,10 Of oDlgPvt
	@ nLin,   180 COMBOBOX cXXMTCM  ITEMS aMTCM SIZE 100,010 Pixel Of oDlgPvt  VALID(Pertence("123"))

	@ nLin+2, 290  SAY 'Centro Custo' PIXEL SIZE 50,10 Of oDlgPvt
	@ nLin,   340  MSGET cCC PIXEL SIZE 50,10 Of oDlgPvt  F3 "CTT" VALID(!Empty(cCC) .AND. Ctb105CC() .AND. !EMPTY(cXXDCC:= CTT->CTT_DESC01))  
	@ nLin,   400  MSGET cXXDCC PIXEL SIZE 100,10 Of oDlgPvt WHEN .F.  

	nLin += 15

	@ nLin+2, 010 SAY 'Justificativa' PIXEL SIZE 50,10 Of oDlgPvt
	oMemo:= tMultiget():New(nLin,60,{|u|if(Pcount()>0,cXXJUST:=u,cXXJUST)},oDlgPvt,250,20,,,,,,.T.) 

	nLin += 23

	@ nLin, 003 GROUP oGrpDad TO (nJanAltu/2)-nLin+20, (nJanLarg/2)-003  PROMPT "Produtos: " OF oDlgPvt PIXEL

    oPanGrid := tPanel():New(nLin+7, 006, "", oDlgPvt, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2 - 13), ((nJanAltu/2) - nLin - 40))
	oGetGrid := FWBrowse():New()
	oGetGrid:DisableFilter()
	oGetGrid:DisableConfig()
	oGetGrid:DisableReport()
	oGetGrid:DisableSeek()
	oGetGrid:DisableSaveConfig()
	oGetGrid:SetFontBrowse(oFontBtn)
	oGetGrid:SetAlias(cAliasTmp)
	oGetGrid:SetDataTable()
	oGetGrid:SetInsert(.F.)
	oGetGrid:SetDelete(.F., { || .F. })
	oGetGrid:lHeaderClick := .F.
	oGetGrid:AddLegend( "Empty("+cAliasTmp + "->XX_DESC)", "RED",  "Erro: produto incorreto ou quantidade zerada")
	oGetGrid:AddLegend("!Empty("+cAliasTmp + "->XX_DESC)", "GREEN",  "Ok")
	oGetGrid:SetColumns(aColunas)
	oGetGrid:SetOwner(oPanGrid)
	oGetGrid:Activate()
			
	//Ações
	@ (nJanAltu/2)-25, 03 GROUP oGrpAco TO (nJanAltu/2)-003, (nJanLarg/2)-003  PROMPT "Ações: "  OF oDlgPvt PIXEL

	@ (nJanAltu/2)-19  , (nJanLarg/2)-((nTamBtn*1)+06) BUTTON oBtnConf PROMPT "Cancelar"   SIZE nTamBtn, 013 OF oDlgPvt ACTION(oDlgPvt:End())            PIXEL
	@ (nJanAltu/2)-19  , (nJanLarg/2)-((nTamBtn*2)+09) BUTTON oBtnLimp PROMPT "Salvar"     SIZE nTamBtn, 013 OF oDlgPvt ACTION(If(fValid(),fSalvar(),))  PIXEL


ACTIVATE MSDIALOG oDlgPvt CENTERED //VALID(fValid())

RestArea(aArea)

Return 


Static Function fValid()
Local lRet := .T.

If (dDatPrf <= dDataBase)
	u_MsgLog(cProg,"Data limite de entrega deve ser maior que a database!","E")
	lRet := .F.
ElseIf Empty(cCC) .OR. !ValidaCusto(cCC,,,,.T.) 
	u_MsgLog(cProg,"Centro de Custos não encontrado!","E")
	lRet := .F.
EndIf
Return (lRet)



Static Function fSalvar()
Local lRet := .F.

u_WaitLog(cProg, { |oSay| lRet := fGravaSC1()}, "Incluindo solicitação de compras...")
If lRet
	oDlgPvt:End()
EndIf

Return

  

Static Function fGravaSC1()

Local nY		:= 0
Local aCab		:= {}
Local aItem 	:= {}
Local lSucess	:= .T.

Private lMsErroAuto := .F.

aCab :={{"C1_XXMTCM"	,cXXMTCM	,Nil },;
		{"C1_XXJUST"	,cXXJUST	,Nil },;
		{"C1_SOLICIT"	,cUserName	,Nil }}

DbSelectArea(cAliasTmp)
dbGoTop()
Do While !EOF()

	SB1->(dbsetorder(1))
	SB1->(DbSeek(xFilial("SB1")+(cAliasTmp)->XX_COD,.F.))

	AADD(aItem,{ {"C1_ITEM"   	,STRZERO(++nY,4) 			,Nil },;
				 {"C1_PRODUTO"	,TRIM((cAliasTmp)->XX_COD)	,Nil },;
				 {"C1_DATPRF"	,dDatPrf					,Nil },;
				 {"C1_QUANT"   	,(cAliasTmp)->XX_QUANT		,Nil },;
				 {"C1_CC" 		,cCC						,Nil }})
	dbSkip()
EndDo

BEGIN TRANSACTION
	
	MSExecAuto({|x,y| MATA110(x,y)},aCab,aItem)

	If lMsErroAuto

		u_LogMsExec("BKCOMA19")
		DisarmTransaction()
		lSucess := .F.
	EndIf

END TRANSACTION
SC1->(dbGoBottom())
If lSucess
	u_MsgLog("BKCOMA19","Solicitação de Compras "+SC1->C1_NUM+" incluida.","S")
Else
	u_MsgLog("BKCOMA19","Solicitação de Compras não foi incluida","E")
EndIf

Return lSucess



//Tela para colagem de dados do excel 
// Para cada linha:
// 1- Primeiros caracteres até encontrar um espaço: Código do Produto 
// 2- Caracteres depois do codigo do Produto: quantidade

STATIC Function CA19Dlg01(cTexto1,cAliasTmp)
Local aAreaAtu	:= GetArea()
Local oDlg01	As Object
Local aButtons 	:= {}
Local lOk 		:= .F.
Local nSnd    	:= 0
Local nTLin 	:= 15
Local nSin    	:= 5
Local cTexto	:= cTexto1 

Define MsDialog oDlg01 Title "Importação de dados: Excel --> Sol. Compra" From 000,000 To 260+(nSin*nTLin),600 Of oDlg01 Pixel

nSnd := 35
@ nSnd,010 Say 'Cole as colunas do excel: Codigo do Produto,,, Quantidade'  Size 240,010 Pixel Of oDlg01
nSnd += nTLin
oMemo:= tMultiget():New(nSnd,10,{|u|if(Pcount()>0,cTexto :=u,cTexto )},oDlg01,280,100,,,,,,.T.)
nSnd += nTLin

ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| iIf(lOk:= VldGrvTx(cTexto,.F.),oDlg01:End(),lOk:= .F.)},{|| lOk:=.F., oDlg01:End()}, , aButtons)

If ( lOk ) 
	lOk := VldGrvTx(cTexto,.T.)
EndIf

RestArea( aAreaAtu )

Return lOk


Static Function VldGrvTx(cTexto,lGrava)
Local nJ		:= 0
Local nI 		:= 0
Local nK 		:= 0
Local lOk 		:= .T.
Local cLinha	:= ""
Local cDesc 	:= ""
Local cCod  	:= ""
Local cQuant	:= ""
Local nTamTex	:= 0
Local cErro 	:= ""

cTexto  := FwNoAccent(cTexto) 
nTamTex := mlCount(cTexto, 200)
	
For nI := 1 To nTamTex
	cLinha := TRIM(memoline(cTexto, 200, nI))
	If !Empty(cLinha)
		
		nK     := 0
		cCod   := ""
		cDesc  := ""
		cQuant := ""

		// Codigo
		For nJ := 1 TO LEN(cLinha)
			If SUBSTR(cLinha,nJ,1) == " "
				If nK == 0
					cCod := SUBSTR(cLinha,1,nJ)
				EndIf
				nK   := nJ
			EndIf
		Next
			
		// Quantidade
		If nk > 0
			cQuant := SUBSTR(cLinha,nK+1,LEN(cLinha))
			cQuant := STRTRAN(cQuant,",",".")
		EndIf
			
		cDesc := ""
		If !EMPTY(cCod)
			If SB1->(DbSeek(xFilial("SB1")+cCod))
				cDesc := SB1->B1_DESC
			EndIf
		EndIf	

		If Empty(cCod) .OR. Empty(cDesc)
			cErro += STRZERO(nI,4)+" Produto: "+cCod+" não encontrado"+CRLF
		EndIf
		If VAL(ALLTRIM(cQuant)) == 0
			cErro += STRZERO(nI,4)+" Produto: "+cCod+" sem quantidade informada"+CRLF
		EndIf

		If lGrava		
			dbSelectArea(cAliasTmp)
			Reclock(cAliasTmp,.T.)
			(cAliasTmp)->XX_COD   := cCod
			(cAliasTmp)->XX_DESC  := cDesc
			(cAliasTmp)->XX_QUANT := VAL(ALLTRIM(cQuant))
		EndIf
	EndIf
Next

If !Empty(cErro)
	u_MsgLog(cProg,cErro,"E")
	lOk := .F.
EndIf

Return lOk


Static Function fMontaHead()
    Local nAtual	:= 0
    Local aHeadAux	:= {}
	Local oColumn 	AS Object
 
    //Adicionando colunas
    //[1] - Campo da Temporaria
    //[2] - Titulo
    //[3] - Tipo
    //[4] - Tamanho
    //[5] - Decimais
    //[6] - Máscara
    aAdd(aHeadAux, {"XX_COD"  , "Produto",     "C", TamSX3('B1_COD')[01]  , 0						, ""						})
    aAdd(aHeadAux, {"XX_DESC" , "Descricao",   "C", TamSX3('B1_DESC')[01] , 0						, ""						})
    aAdd(aHeadAux, {"XX_QUANT", "Quantidade",  "N", TamSX3("C1_QUANT")[1] ,	TamSX3("C1_QUANT")[2]	, PesqPict("SC1","C1_QUANT")})

    //Percorrendo e criando as colunas
    For nAtual := 1 To Len(aHeadAux)
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&("{|| " + cAliasTmp + "->" + aHeadAux[nAtual][1] +"}"))
        oColumn:SetTitle(aHeadAux[nAtual][2])
        oColumn:SetType(aHeadAux[nAtual][3])
        oColumn:SetSize(aHeadAux[nAtual][4])
        oColumn:SetDecimal(aHeadAux[nAtual][5])
        oColumn:SetPicture(aHeadAux[nAtual][6])
        aAdd(aColunas, oColumn)
    Next
Return
