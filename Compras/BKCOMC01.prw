#include "PROTHEUS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} BKCOMC01()
BK - Pesquisa itens/NF de Documentos de entrada

** Chamada efetuada atraves dos pontos de entrada MA103OPC e MT140ROT

@author Marcos B. Abrahão
@since 29/09/2009
@version P12
@return Nil
/*/

User Function BKCOMC01()

Private aParam 	:= {}
Private cTitulo	:= "Pesquisar itens/NF de Documentos de entrada"
Private cPerg	:= "MT103PBK"
Private cProd	:= SPACE(15)
Private cHist	:= SPACE(30)
Private cCtC	:= SPACE(15)
Private nValIt	:= 0
Private cForn	:= SPACE(6)
Private cNForn	:= SPACE(30)
Private cDProd	:= SPACE(40)
Private cFiltU 	:= ""
Private cAndOr	:= ""
Private cSubs	:= ""
Private cDoc 	:= SPACE(9)
Private nValDoc	:= 0
Private cHelp1  := ""
Private cHelp2  := ""
Private cHelp3  := ""
Private cHelp4  := ""

cHelp1 := "Preeencha SOMENTE os campos que deseja na pesquisa, os outros, deixe em branco ou zero." 
cHelp2 := "A pesquisa é feita por parte do campo:"
cHelp3 := "Exemplo: Descrição do produdo = 'BOTA' irá retornar todas NFs que possuam a palavra BOTA na descrição dos produtos."
cHelp4 := "Após a pesquisa, posicione na linha e clique em OK para posicionar na NF."

// Tipo 11 -> MultiGet (Memo)
//            [2] = Descrição
//            [3] = Inicializador padrão
//            [4] = Validação
//            [5] = When
//            [6] = Campo com preenchimento obrigatório .T.=Sim .F.=Não (incluir a validação na função ParamOk)

// Tipo 1 -> MsGet()
//           [2]-Descricao
//           [3]-String contendo o inicializador do campo
//           [4]-String contendo a Picture do campo
//           [5]-String contendo a validacao
//           [6]-Consulta F3
//           [7]-String contendo a validacao When
//           [8]-Tamanho do MsGet
//           [9]-Flag .T./.F. Parametro Obrigatorio ?


// Tipo 9 -> Somente uma mensagem, formato de um título
//           [2]-Texto descritivo
//           [3]-Largura do texto
//           [4]-Altura do texto
//           [5]-Valor lógico sendo: .T. => fonte tipo VERDANA e .F. => fonte tipo ARIAL

//aAdd( aParam, {11, "Instruções:"			, cHelp		, ""   , ".F."	, .F.})
aAdd( aParam, { 9, cHelp1					, 190		, 30	, .T.})
aAdd( aParam, { 9, cHelp2					, 190		, 20	, .T.})
aAdd( aParam, { 9, cHelp3					, 190		, 30	, .T.})
aAdd( aParam, { 9, cHelp4					, 190		, 40	, .T.})
aAdd( aParam, { 1, "Código do produto:"		, cProd		, ""	, ""	, "SB1"	, ""	, 70	, .F. })
aAdd( aParam, { 1, "Descrição do produto:"	, cDProd	, ""	, ""	, ""	, ""	, 70	, .F. })
aAdd( aParam, { 1, "Código do Fornecedor:"	, cForn		, ""	, ""	, "SA2"	, ""	, 70	, .F. })
aAdd( aParam, { 1, "Nome do Fornecedor:"	, cNForn	, ""	, ""	, ""	, ""	, 70	, .F. })
aAdd( aParam, { 1, "Centro de Custo:"		, cCtc		, ""	, ""	, "CTT"	, ""	, 70	, .F. })
aAdd( aParam, { 1, "Histórico:"				, cHist		, ""	, ""	, ""	, ""	, 70	, .F. })
aAdd( aParam, { 1, "Numero NF:"				, cDoc		, ""	, ""	, ""	, ""	, 70	, .F. })
aAdd( aParam, { 1, "Valor do Item:"			, nValIt	, ""	, ""	, ""	, ""	, 70	, .F. })
aAdd( aParam, { 1, "Valor da NF:"			, nValDoc	, ""	, ""	, ""	, ""	, 70	, .F. })

If BKPar()
	u_WaitLog(cPerg, {|| PRCOMC01()},"Aguarde o resultado da pesquisa...")
ENDIF
Return Nil

Static Function BKPar()
Local lRet := .F.
Local aRet := {}
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
	If (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg      ,.T.         ,.T.))
		cProd	:= mv_par05
		cDProd	:= mv_par06
		cForn	:= mv_par07
		cNForn	:= mv_par08
		cCtc	:= mv_par09
		cHist	:= mv_par10
		cDoc	:= mv_par11
		nValIt	:= mv_par12
		nValDoc	:= mv_par13
		lRet	:= .T.
	Endif
Return lRet


Static Function PRCOMC01()
Local oDlg			as Object
Local oPanel		as Object
Local aButtons		:= {}
Local lOk			:= .F.
Local aAreaIni		:= GetArea()
Local cQuery		:= ""
Local oTmpTb
Local j

Private aSize   := MsAdvSize(,.F.,400)
Private aObjects:= { { 450, 450, .T., .T. } }
Private aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aPosObj := MsObjSize( aInfo, aObjects, .T. )
private aRotina := {{"","",0,1},{"","",0,2},{"","",0,2},{"","",0,2},{"","",0,2}}
Private aHeader	    := {}

u_MsgLog("BKCOMC01")

// Se o usuario pertence ao grupo Administradores ou Master Financeiro ou Master Diretoria: não filtrar
IF !u_IsMasFin(__cUserId) .AND. !u_IsFiscal(__cUserId) .AND. !lMDiretoria

	//cStaf  := SuperGetMV("MV_XXUSERS",.F.,"000013/000027/000061")
	lStaf  := u_IsStaf(__cUserId)

	cFiltU := "(F1_XXUSER = '"+__cUserId+"'  "
	cAndOr := " OR "

	// Incluir os subordinados
	If lStaf
		cSubs := U_cStaf(__cUserId)
	Else
		cSubs := U_cSubord(__cUserId)
	EndIf

	If !Empty(cSubs)
	   cFiltU += cAndOr+" (F1_XXUSER IN "+cSubs+") "
	EndIf
	cFiltU += ")"

ENDIF


cQuery  := "SELECT "+CRLF
cQuery  += " D1_FILIAL,D1_DOC,D1_SERIE,D1_ITEM,D1_FORNECE,A2_NOME,D1_LOJA,D1_COD,B1_DESC,D1_TOTAL,D1_EMISSAO,D1_DTDIGIT,D1_CC,Cast(Cast(D1_XXHIST As varbinary(max)) As varchar(300)) As D1_XXHIST, " +CRLF
cQuery  += " F1_VALBRUT,F1_XXUSER,F1_XXUSERS "+CRLF
cQuery  += " FROM "+RETSQLNAME("SD1")+" SD1 "+CRLF
cQuery  += " INNER JOIN "+RETSQLNAME("SF1")+" SF1 ON "+CRLF
cQuery  += "    F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1_TIPO = D1_TIPO "+CRLF
cQuery  += "    AND SF1.D_E_L_E_T_ = '' " +CRLF
cQuery  += " LEFT JOIN "+RETSQLNAME("SA2")+" SA2 ON A2_FILIAL = '"+xFilial("SA2")+"' AND D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "+CRLF
cQuery  += " LEFT JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D1_COD = B1_COD AND SB1.D_E_L_E_T_ = ' ' "+CRLF
cQuery  += "WHERE SD1.D_E_L_E_T_ = '' "+CRLF
IF !EMPTY(cFiltU)
	cQuery  += "AND "+cFiltU+CRLF
ENDIF
IF !EMPTY(cProd)
	cQuery  += "AND D1_COD LIKE '%"+ALLTRIM(cProd)+"%' "+CRLF
ENDIF
IF !EMPTY(cHist)
	cQuery  += "AND UPPER(Cast(Cast(D1_XXHIST As varbinary(max)) As varchar(max))) LIKE '%"+UPPER(ALLTRIM(cHist))+"%' "+CRLF
ENDIF
IF !EMPTY(cCtC)
	cQuery  += "AND D1_CC LIKE '%"+ALLTRIM(cCtc)+"%' "+CRLF
ENDIF
IF nValIt > 0
	nValIt := INT(nValIt)
	cQuery  += "AND ( D1_TOTAL >= "+ALLTRIM(STR(nValIt - 1))+" AND  D1_TOTAL <= "+ALLTRIM(STR(nValIt + 1))+" ) "+CRLF
ENDIF
IF !EMPTY(cForn)
	cQuery  += "AND D1_FORNECE LIKE '%"+ALLTRIM(cForn)+"%' "+CRLF
ENDIF
IF !EMPTY(cNForn)
	cQuery  += "AND UPPER(A2_NOME) LIKE '%"+ALLTRIM(UPPER(cNForn))+"%' "+CRLF
ENDIF

IF !EMPTY(cDProd)
	cQuery  += "AND UPPER(B1_DESC) LIKE '%"+ALLTRIM(UPPER(cDProd))+"%' "+CRLF
ENDIF

IF !EMPTY(cDoc)
	cQuery  += "AND F1_DOC LIKE '%"+ALLTRIM(cDoc)+"%' "+CRLF
ENDIF

IF nValDoc > 0
	nValDoc := INT(nValDoc)
	cQuery  += "AND ( F1_VALBRUT >= "+ALLTRIM(STR(nValDoc - 1))+" AND  F1_VALBRUT <= "+ALLTRIM(STR(nValDoc + 1))+" ) "+CRLF
ENDIF

//cQuery  += "ORDER BY D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_COD,D1_ITEM "+CRLF
cQuery  += "ORDER BY D1_DTDIGIT DESC ,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_COD,D1_ITEM "+CRLF

u_LogMemo("BKCOMC01.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QSD1"
TCSETFIELD("QSD1","D1_EMISSAO","D",8,0)
TCSETFIELD("QSD1","D1_DTDIGIT","D",8,0)
TCSETFIELD("QSD1","D1_XXHIST1","C",300,0)
TCSETFIELD("QSD1","D1_TOTAL"  ,"N",18,2)
TCSETFIELD("QSD1","F1_VALBRUT","N",18,2)

DbSelectArea("QSD1")
DbGoTop()
aStruc := dbStruct()

oTmpTb := FWTemporaryTable():New( "QSD11" )	
oTmpTb:SetFields( aStruc )
//oTmpTb:AddIndex("indice1", {"D1_DTDIGIT"} )
oTmpTb:Create()

//dbcreate(cArqTrb,aStruc)
//dbUseArea(.T.,,cArqTrb,"QSD11",.F.,.F.)

DbSelectArea("QSD1")
dbGoTop()
Do While !eof()
	DbSelectArea("QSD11")
    RecLock("QSD11",.T.)
	For j:=1 to QSD1->(FCount())
		FieldPut(j,QSD1->(FieldGet(j)))
	Next
     
	DbSelectArea("QSD1")
	dbSkip()
EndDo

DbSelectArea("QSD11")
dbGoTop()

aadd(aHeader, DefAHeader("QSD11","D1_FILIAL"))
aadd(aHeader, DefAHeader("QSD11","D1_DOC"))
aadd(aHeader, DefAHeader("QSD11","D1_SERIE"))
aadd(aHeader, DefAHeader("QSD11","D1_ITEM"))
aadd(aHeader, DefAHeader("QSD11","D1_FORNECE"))
aadd(aHeader, DefAHeader("QSD11","A2_NOME"))
aadd(aHeader, DefAHeader("QSD11","D1_LOJA"))
aadd(aHeader, DefAHeader("QSD11","D1_COD"))
aadd(aHeader, DefAHeader("QSD11","B1_DESC"))
aadd(aHeader, DefAHeader("QSD11","D1_TOTAL"))
aadd(aHeader, DefAHeader("QSD11","D1_EMISSAO"))
aadd(aHeader, DefAHeader("QSD11","D1_DTDIGIT"))
aadd(aHeader, DefAHeader("QSD11","D1_CC"))
aadd(aHeader, DefAHeader("QSD11","D1_XXHIST"))
aadd(aHeader, DefAHeader("QSD11","F1_XXUSER"))
aadd(aHeader, DefAHeader("QSD11","F1_XXUSERS"))
aadd(aHeader, DefAHeader("QSD11","F1_VALBRUT"))

//oOk := LoadBitmap( GetResources(), "LBTIK" )
//oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE "Pesquisa itens de Documentos de entrada" From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

oPanel := TPanel():New(20,0,'',oDlg,, .T., .T.,, ,aSize[6],aSize[5],.T.,.T. ) 
oPanel:Align:=CONTROL_ALIGN_TOP

@ 010,012 BUTTON "Excel" SIZE 060, 015 PIXEL OF oPanel ACTION (ComC01Xls(cPerg))
@ 010,090 BUTTON "Ok"    SIZE 060, 015 PIXEL OF oPanel ACTION (lOk:=.T.,oDlg:End())
@ 010,168 BUTTON "Sair"  SIZE 060, 015 PIXEL OF oPanel ACTION (lOk:=.F.,oDlg:End())

//@ 025,000 MSPANEL oPanelLeft OF oDlg SIZE aSize[6],aSize[5]
//oPanelLeft:Align := CONTROL_ALIGN_LEFT

_oGetDbSint := MsGetDb():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], 2, "AllwaysTrue()", "AllwaysTrue()",,,,,,"AllwaysTrue()","QSD11")
_oGetDbSint:oBrowse:BlDblClick := {|| lOk:=.T., oDlg:End()}        


//@ 000, 000 LISTBOX oListID FIELDS HEADER "Filial","Doc","Serie","Item","Produto","Total R$","Histórico" SIZE aSize[6],aSize[5] OF oPanelLeft PIXEL 
//oListID:SetArray(aSd1)
//oListID:bLine := {|| {aSd1[oListId:nAt][1],aSd1[oListId:nAt][2],aSd1[oListId:nAt][3],aSd1[oListId:nAt][4],aSd1[oListId:nAt][5],aSd1[oListId:nAt][6],aSd1[oListId:nAt][7]}}
//oListID:bLDblClick := {|| lOk:=.T.,nPos := oListId:nAt, oListID:DrawSelect(), oDlg:End()}

//ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T.,nPos := oListId:nAt, oDlg:End()},{|| nPos:=0,oDlg:End()}, , aButtons)
ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( EnchoiceBar(oDlg,{|| lOk:=.T.,oDlg:End()}, {||oDlg:End()},, aButtons), oPanel:Align:=CONTROL_ALIGN_TOP )

If ( lOk ) //.AND. nPos > 0
	dbSelectArea("SF1")
	dbSetOrder(1)
	//dbSeek(aSd1[nPos,8],.T.)
	dbSeek(QSD11->D1_FILIAL+QSD11->D1_DOC+QSD11->D1_SERIE+QSD11->D1_FORNECE+QSD11->D1_LOJA,.T.)
Else
	RestArea(aAreaIni)
Endif
QSD1->(DbCloseArea())
oTmpTb:Delete() 

//QSD11->(DbCloseArea())
//fErase(cArqTrb+GetDBExtension())

Return


Static Function DefAHeader(_cAlias,_cCampo)

Return {Alltrim(RetTitle(_cCampo)),;
        _cCampo,;
        GetSx3Cache( _cCampo , "X3_PICTURE" ),;
        GetSx3Cache( _cCampo , "X3_TAMANHO" ),;
        GetSx3Cache( _cCampo , "X3_DECIMAL" ),;
        GetSx3Cache( _cCampo , "X3_VALID" ),;
        "",;
        GetSx3Cache( _cCampo , "X3_TIPO" ),;
        GetSx3Cache( _cCampo , "X3_PICTVAR" ),;
        _cAlias,;
        "R"}



/*/{Protheus.doc} ComC01Xls
	Exportar consulta para o Excel
	@type  Static Function
	@author Marcos Bispo Abrahão
	@since 22/03/2022
	@version 12.1.33
/*/
Static Function ComC01Xls(cPerg)
Local aCabs   := {}
Local aCampos := {}
Local aTitulos:= {}
Local aPlans  := {}
Local aFormula:= {}
Local cTitulo := "Pesquisa itens de Documentos de entrada"

AADD(aTitulos,cTitulo)

aAdd(aCampos,"QSD11->D1_DOC")
aAdd(aCabs  ,GetSX3Cache("D1_DOC", "X3_TITULO"))

aAdd(aCampos,"QSD11->D1_SERIE")
aAdd(aCabs  ,GetSX3Cache("D1_SERIE", "X3_TITULO"))

aAdd(aCampos,"QSD11->D1_ITEM")
aAdd(aCabs  ,GetSX3Cache("D1_ITEM", "X3_TITULO"))

aAdd(aCampos,"QSD11->D1_FORNECE")
aAdd(aCabs  ,GetSX3Cache("D1_FORNECE", "X3_TITULO"))

aAdd(aCampos,"QSD11->A2_NOME")
aAdd(aCabs  ,GetSX3Cache("A2_NOME", "X3_TITULO"))

aAdd(aCampos,"QSD11->D1_LOJA")
aAdd(aCabs  ,GetSX3Cache("D1_LOJA", "X3_TITULO"))

aAdd(aCampos,"QSD11->A2_NOME")
aAdd(aCabs  ,GetSX3Cache("A2_NOME", "X3_TITULO"))

aAdd(aCampos,"QSD11->D1_COD")
aAdd(aCabs  ,GetSX3Cache("D1_COD", "X3_TITULO"))

aAdd(aCampos,"QSD11->B1_DESC")
aAdd(aCabs  ,GetSX3Cache("B1_DESC", "X3_TITULO"))

aAdd(aCampos,"QSD11->D1_TOTAL")
aAdd(aCabs  ,GetSX3Cache("D1_TOTAL", "X3_TITULO"))

aAdd(aCampos,"QSD11->D1_EMISSAO")
aAdd(aCabs  ,GetSX3Cache("D1_EMISSAO", "X3_TITULO"))

aAdd(aCampos,"QSD11->D1_DTDIGIT")
aAdd(aCabs  ,GetSX3Cache("D1_DTDIGIT", "X3_TITULO"))

aAdd(aCampos,"QSD11->D1_CC")
aAdd(aCabs  ,GetSX3Cache("D1_CC", "X3_TITULO"))

aAdd(aCampos,"QSD11->D1_XXHIST")
aAdd(aCabs  ,GetSX3Cache("D1_XXHIST", "X3_TITULO"))

aAdd(aCampos,"QSD11->F1_VALBRUT")
aAdd(aCabs  ,GetSX3Cache("F1_VALBRUT", "X3_TITULO"))

aAdd(aCampos,"UsrRetName(QSD11->F1_XXUSER)")
aAdd(aCabs  ,GetSX3Cache("F1_XXUSER", "X3_TITULO"))

aAdd(aCampos,"UsrRetName(QSD11->F1_XXUSERS)")
aAdd(aCabs  ,GetSX3Cache("F1_XXUSERS", "X3_TITULO"))

AADD(aPlans,{"QSD11",cPerg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, aFormula,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
U_PlanXlsx(aPlans,cTitulo,cPerg,.F.)
	
Return .T.
