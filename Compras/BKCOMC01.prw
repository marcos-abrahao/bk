#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} BKCOMC01()
BK - Pesquisa itens de Documentos de entrada

** Chamada efetuada atraves do ponto de entrada MA103OPC

@author Marcos B. Abrahão
@since 29/09/2009
@version P12
@return Nil
/*/
            

User Function BKCOMC01()

Local oDlg			as Object
Local oPanel		as Object
Local aButtons		:= {}
Local lOk			:= .F.
Local aAreaIni		:= GetArea()
Local cQuery		:= ""
Local cPerg 		:= "MT103PBK"
Local cProd			:= ""
Local cHist			:= ""
Local cCtC			:= ""
Local nValIt		:= 0
Local cForn			:= ""
Local cNForn		:= ""
Local cFiltU 		:= ""
Local cMDiretoria	:= ""
Local cMFinanceiro	:= ""
Local cGerGestao 	:= u_GerGestao()
Local cGerCompras	:= u_GerCompras()
Local oTmpTb
Local i,j

Private aSize   := MsAdvSize(,.F.,400)
Private aObjects:= { { 450, 450, .T., .T. } }
Private aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aPosObj := MsObjSize( aInfo, aObjects, .T. )
private aRotina := {{"","",0,1},{"","",0,2},{"","",0,2},{"","",0,2},{"","",0,2}}
Private aHeader	    := {}

u_MsgLog("BKCOMC01")

IF __cUserId <> "000000"  // Administrador

	//cStaf  := SuperGetMV("MV_XXUSERS",.F.,"000013/000027/000061")
	lStaf  := u_IsStaf(__cUserId)

	cMDiretoria := u_GrpMDir()
	cMFinanceiro:= SUBSTR(SuperGetMV("MV_XXGRPMF",.F.,"000005"),1,6)

	//DBCLEARFILTER() 
	PswOrder(1) 
	PswSeek(__cUserId) 
	aUser  := PswRet(1)
	IF !EMPTY(aUser[1,11])
	   cSuper := SUBSTR(aUser[1,11],1,6)
	ENDIF   

    lMDiretoria := .F.
    aGRUPO := {}
//    AADD(aGRUPO,aUser[1,10])
//    FOR i:=1 TO LEN(aGRUPO[1])
//		lMDiretoria := (aGRUPO[1,i] $ cMDiretoria)
//	NEXT
//Ajuste nova rotina a antiga não funciona na nova lib MDI
	aGRUPO := UsrRetGrp(aUser[1][2])
	IF LEN(aGRUPO) > 0
		FOR i:=1 TO LEN(aGRUPO)
			lMDiretoria := (ALLTRIM(aGRUPO[i]) $ cMDiretoria )
		NEXT
	ENDIF
    
	//cSuper := aUser[1,11]
	// Se o usuario pertence ao grupo Administradores ou Master Financeiro ou Master Diretoria: não filtrar
    IF ASCAN(aUser[1,10],"000000") = 0 .AND. ASCAN(aUser[1,10],cMFinanceiro) = 0  .AND. !lMDiretoria
       IF !lStaf .OR. EMPTY(cSuper)
       		IF EMPTY(cSuper) .AND. __cUserId $ cGerGestao
    			cFiltU := "AND ( F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ' OR F1_XXUSERS = '"+u_GerPetro()+"') "
       		ELSE
    			cFiltU := "AND ( F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ') "
    		ENDIF
    	ELSE
    		//cFiltU := "AND ( F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+cSuper+"' OR F1_XXUSER = '      ' ) "
    		IF lStaf .AND. cSuper $ cGerGestao
  	      		cFiltU := "AND (F1_XXUSER = '"+__cUserId + "' OR F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+__cUserId + "' OR F1_XXUSERS = '"+cSuper+"' OR F1_XXUSER = '      ' OR F1_XXUSERS = '"+u_GerPetro()+"') "  
    		ELSEIF lStaf .AND. __cUserId $ cGerCompras
  	      		cFiltU := "AND (F1_XXUSER = '"+__cUserId + "' OR F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+__cUserId + "' OR F1_XXUSERS = '"+cSuper+"' OR F1_XXUSER = '      ' OR F1_XXUSERS IN "+FormatIn(cGerCompras,"/")+")"  
    		ELSE 
  	      		cFiltU := "AND (F1_XXUSER = '"+__cUserId + "' OR F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+__cUserId + "' OR F1_XXUSERS = '"+cSuper+"' OR F1_XXUSER = '      ') "  
    		ENDIF
    	ENDIF
    ENDIF   
ENDIF

ValidPerg(cPerg)
	
IF !Pergunte(cPerg,.T.)
	RestArea(aAreaIni)
	Return
ENDIF

cProd  := mv_par01
cHist  := mv_par02
cCtc   := mv_par03
nValIt := mv_par04
cForn  := mv_par05
cNForn := mv_par06

cQuery  := "SELECT "+CRLF
cQuery  += " D1_FILIAL,D1_DOC,D1_SERIE,D1_ITEM,D1_FORNECE,D1_LOJA,D1_COD,D1_TOTAL,D1_EMISSAO,D1_DTDIGIT,D1_CC,Cast(Cast(D1_XXHIST As varbinary(max)) As varchar(300)) As D1_XXHIST, " +CRLF
cQuery  += " F1_XXUSER,F1_XXUSERS, A2_NOME "+CRLF
cQuery  += " FROM "+RETSQLNAME("SD1")+" SD1 "+CRLF
cQuery  += " INNER JOIN "+RETSQLNAME("SF1")+" SF1 ON "+CRLF
cQuery  += "    F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1_TIPO = D1_TIPO "+CRLF
cQuery  += "    AND SF1.D_E_L_E_T_ <> '*' " +CRLF
cQuery  += " LEFT JOIN "+RETSQLNAME("SA2")+" SA2 ON A2_FILIAL = '"+xFilial("SA2")+"' AND D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "+CRLF
cQuery  += cFiltU+CRLF
cQuery  += "WHERE SD1.D_E_L_E_T_ <> '*' "+CRLF
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
	cQuery  += "AND A2_NOME LIKE '%"+ALLTRIM(cNForn)+"%' "+CRLF
ENDIF

cQuery  += "ORDER BY D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_COD,D1_ITEM "+CRLF

u_LogMemo("BKCOMC01.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QSD1"
TCSETFIELD("QSD1","D1_EMISSAO","D",8,0)
TCSETFIELD("QSD1","D1_DTDIGIT","D",8,0)
TCSETFIELD("QSD1","D1_XXHIST1","C",300,0)
TCSETFIELD("QSD1","D1_TOTAL" ,"N",18,2)

DbSelectArea("QSD1")
DbGoTop()
aStruc := dbStruct()
/*
aSd1 := {}
Do While !eof()
	cKeyF1 := QSD1->D1_FILIAL+QSD1->D1_DOC+QSD1->D1_SERIE+QSD1->D1_FORNECE+QSD1->D1_LOJA
	AADD(aSd1,{QSD1->D1_FILIAL,QSD1->D1_DOC,QSD1->D1_SERIE,QSD1->D1_ITEM,D1_COD,TRANSFORM(QSD1->D1_TOTAL,"@E 999,999,999.99"),QSD1->D1_XXHIST1,cKeyF1})
	DbSelectArea("QSD1")
	DbSkip()
Enddo
*/


//QSD1->(DbCloseArea())


//ASORT(aSd1,,,{|x,y| x[2]<y[2]})


/*
If Empty(aSd1)
	MsgStop("Nenhum item encontrado", "Atenção")
	RestArea(aAreaIni)
	Return
EndIf
*/


//Private cArqTrb := CriaTrab(NIL,.F.)
		
oTmpTb := FWTemporaryTable():New( "QSD11" )	
oTmpTb:SetFields( aStruc )
oTmpTb:AddIndex("indice1", {"D1_XXHIST"} )
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

aadd(aHeader, DefAHeader("QSD11","D1_FILIAL"))
aadd(aHeader, DefAHeader("QSD11","D1_DOC"))
aadd(aHeader, DefAHeader("QSD11","D1_SERIE"))
aadd(aHeader, DefAHeader("QSD11","D1_ITEM"))
aadd(aHeader, DefAHeader("QSD11","D1_FORNECE"))
aadd(aHeader, DefAHeader("QSD11","D1_LOJA"))
aadd(aHeader, DefAHeader("QSD11","D1_COD"))
aadd(aHeader, DefAHeader("QSD11","D1_TOTAL"))
aadd(aHeader, DefAHeader("QSD11","D1_EMISSAO"))
aadd(aHeader, DefAHeader("QSD11","D1_DTDIGIT"))
aadd(aHeader, DefAHeader("QSD11","D1_CC"))
aadd(aHeader, DefAHeader("QSD11","D1_XXHIST"))
aadd(aHeader, DefAHeader("QSD11","F1_XXUSER"))
aadd(aHeader, DefAHeader("QSD11","F1_XXUSERS"))

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

aAdd(aCampos,"QSD11->D1_LOJA")
aAdd(aCabs  ,GetSX3Cache("D1_LOJA", "X3_TITULO"))

aAdd(aCampos,"QSD11->A2_NOME")
aAdd(aCabs  ,GetSX3Cache("A2_NOME", "X3_TITULO"))

aAdd(aCampos,"QSD11->D1_COD")
aAdd(aCabs  ,GetSX3Cache("D1_COD", "X3_TITULO"))

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

aAdd(aCampos,"UsrRetName(QSD11->F1_XXUSER)")
aAdd(aCabs  ,GetSX3Cache("F1_XXUSER", "X3_TITULO"))

aAdd(aCampos,"UsrRetName(QSD11->F1_XXUSERS)")
aAdd(aCabs  ,GetSX3Cache("F1_XXUSERS", "X3_TITULO"))

AADD(aPlans,{"QSD11",cPerg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, aFormula,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
U_PlanXlsx(aPlans,cTitulo,cPerg,.F.)
 
	
Return .T.


Static Function  ValidPerg(cPerg)
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Pesquisar produto"        ,"Produto"        ,"Produto"        ,"mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SB1","S","",""})
AADD(aRegistros,{cPerg,"02","Pesquisar histórico"      ,"Historico"      ,"Historico"      ,"mv_ch2","C",20,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Pesquisar Centro de Custo","Centro de Custo","Centro de Custo","mv_ch3","C",09,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"04","Pesquisar Valor item"     ,"Valor do item"  ,"Valor do Item"  ,"mv_ch4","N",12,2,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"05","Pesquisar Fornecedor"     ,"Fornecedor"     ,"Fornecedor"     ,"mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA2","S","",""})
AADD(aRegistros,{cPerg,"06","Pesquisar Nome Forn."     ,"Fornecedor"     ,"Fornecedor"     ,"mv_ch6","C",30,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

For i:=1 to Len(aRegistros)
	If !dbSeek(cPerg+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegistros[i])
				FieldPut(j,aRegistros[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(aArea)

Return(NIL)
