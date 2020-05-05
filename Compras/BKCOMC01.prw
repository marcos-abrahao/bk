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

Local oDlg
Local oPanelLeft
Local aButtons := {}
Local lOk      := .F.
Local aAreaIni := GetArea()
Local cQuery
Local cPerg := "MT103PBK"
Local cProd,cHist,cCtC,nValIt,cForn
Local cFiltU := ""
Local cMDiretoria :="", cMFinanceiro:= ""
Local cGerGestao := ALLTRIM(GetMv("MV_XXGGCT"))
Local cGerCompras := ALLTRIM(GetMv("MV_XXGCOM"))
Local oTmpTb

cGerGestao := ALLTRIM(U_BKGetMv("MV_XXGGCT"))

Private aSize   := MsAdvSize(,.F.,400)
Private aObjects:= { { 450, 450, .T., .T. } }
Private aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aPosObj := MsObjSize( aInfo, aObjects, .T. )
private aRotina := {{"","",0,1},{"","",0,2},{"","",0,2},{"","",0,2},{"","",0,2}}
Private aHeader	    := {}

IF __cUserId <> "000000"  // Administrador
	cStaf  := SuperGetMV("MV_XXUSERS",.F.,"000013/000027/000061")
	//                                     Luis          Bruno Santiago
	lStaf  := (__cUserId $ cStaf)
	cMDiretoria := SuperGetMV("MV_XXGRPMD",.F.,"000007")
	cMFinanceiro:= SUBSTR(SuperGetMV("MV_XXGRPMF",.F.,"000005"),1,6)

	//DBCLEARFILTER() 
	PswOrder(1) 
	PswSeek(__CUSERID) 
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
    			cFiltU := "AND ( F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ' OR F1_XXUSERS = '000075' OR F1_XXUSERS = '000120') "
       		ELSE
    			cFiltU := "AND ( F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ') "
    		ENDIF
    	ELSE
    		//cFiltU := "AND ( F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+cSuper+"' OR F1_XXUSER = '      ' ) "
    		IF lStaf .AND. cSuper $ cGerGestao
  	      		cFiltU := "AND (F1_XXUSER = '"+__cUserId + "' OR F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+__cUserId + "' OR F1_XXUSERS = '"+cSuper+"' OR F1_XXUSER = '      ' OR F1_XXUSERS = '000075' OR F1_XXUSERS = '000120') "  
    		ELSEIF lStaf .AND. __cUserId $ cGerCompras
  	      		cFiltU := "AND (F1_XXUSER = '"+__cUserId + "' OR F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+__cUserId + "' OR F1_XXUSERS = '"+cSuper+"' OR F1_XXUSER = '      ' OR F1_XXUSERS $ '"+cGerCompras+"')"  
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

cQuery  := "SELECT "
cQuery  += "D1_FILIAL,D1_DOC,D1_SERIE,D1_ITEM,D1_FORNECE,D1_LOJA,D1_COD,D1_TOTAL,D1_EMISSAO,D1_DTDIGIT,D1_CC,Cast(Cast(D1_XXHIST As varbinary(max)) As varchar(300)) As D1_XXHIST, " 
cQuery  += "F1_XXUSER,F1_XXUSERS "
//cQuery  := "SELECT D1_FILIAL,D1_DOC,D1_SERIE,D1_ITEM,D1_FORNECE,D1_LOJA,D1_COD,D1_TOTAL,D1_EMISSAO,D1_DTDIGIT,D1_CC,D1_XXHIST " 
cQuery  += "FROM "+RETSQLNAME("SD1")+" SD1 "
cQuery  += "INNER JOIN "+RETSQLNAME("SF1")+" SF1 ON "
cQuery  += "F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1_TIPO = D1_TIPO "
cQuery  += "AND SF1.D_E_L_E_T_ <> '*' " 
cQuery  += cFiltU
cQuery  += "WHERE SD1.D_E_L_E_T_ <> '*' "
IF !EMPTY(cProd)
	cQuery  += "AND D1_COD LIKE '%"+ALLTRIM(cProd)+"%' "
ENDIF
IF !EMPTY(cHist)
	cQuery  += "AND UPPER(Cast(Cast(D1_XXHIST As varbinary(max)) As varchar(max))) LIKE '%"+UPPER(ALLTRIM(cHist))+"%' "
ENDIF
IF !EMPTY(cCtC)
	cQuery  += "AND D1_CC LIKE '%"+ALLTRIM(cCtc)+"%' "
ENDIF
IF nValIt > 0
	nValIt := INT(nValIt)
	cQuery  += "AND ( D1_TOTAL >= "+ALLTRIM(STR(nValIt - 1))+" AND  D1_TOTAL <= "+ALLTRIM(STR(nValIt + 1))+" ) "
ENDIF
IF !EMPTY(cForn)
	cQuery  += "AND D1_FORNECE LIKE '%"+ALLTRIM(cForn)+"%' "
ENDIF

cQuery  += "ORDER BY D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_COD,D1_ITEM "


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

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE aSize[6],aSize[5]
oPanelLeft:Align := CONTROL_ALIGN_LEFT

_oGetDbSint := MsGetDb():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], 2, "AllwaysTrue()", "AllwaysTrue()",,,,,,"AllwaysTrue()","QSD11")
_oGetDbSint:oBrowse:BlDblClick := {|| lOk:=.T., oDlg:End()}        

//@ 000, 000 LISTBOX oListID FIELDS HEADER "Filial","Doc","Serie","Item","Produto","Total R$","Histórico" SIZE aSize[6],aSize[5] OF oPanelLeft PIXEL 
//oListID:SetArray(aSd1)
//oListID:bLine := {|| {aSd1[oListId:nAt][1],aSd1[oListId:nAt][2],aSd1[oListId:nAt][3],aSd1[oListId:nAt][4],aSd1[oListId:nAt][5],aSd1[oListId:nAt][6],aSd1[oListId:nAt][7]}}
//oListID:bLDblClick := {|| lOk:=.T.,nPos := oListId:nAt, oListID:DrawSelect(), oDlg:End()}

//ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T.,nPos := oListId:nAt, oDlg:End()},{|| nPos:=0,oDlg:End()}, , aButtons)
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T.,oDlg:End()}, {||oDlg:End()},, aButtons)

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

Static Function  ValidPerg(cPerg)

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
//AADD(aRegistros,{cPerg,"06","Loja do Cliente(T):"   ,"Loja:"    ,"Loja:"    ,"mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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
