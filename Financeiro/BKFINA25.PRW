#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BKBXBNCOบ      Adilson do Prado              Data ณ22/08/14บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Baixa retorno Banco Lancamentos LF						  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BK Consultoria                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/


User Function BKFINA25()
Local oOk
Local oNo
Local oDlg
Local oListId
Local oPanelLeft
Local lAll
Local oAll
Local aButtons := {}

Local aCtrId,aTitGer,xCtrId
Local lOk      := .F.
Local aAreaIni := GetArea()
Local cQuery
Local nI,cPrf,cTitulo,nProxTit
Local lTitOk   := .T.
Local lAltOk1,lAltOk2
Local cMsgEx   := SPACE(50)

PRIVATE cxFilial,cPrefixo,cNum,cParcela,cTipo,cFornece,cLoja,nValTit
PRIVATE cObs

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

cQuery  := "SELECT E2_FORNECE,A2_NOME,E2_LOJA,SUM(E2_VALOR) AS E2_VALOR FROM "+RETSQLNAME("SE2")+" SE2"
cQuery  += " INNER JOIN "+RETSQLNAME("SA2")+" SA2 ON SA2.D_E_L_E_T_='' AND A2_COD=E2_FORNECE AND A2_LOJA=E2_LOJA"
cQuery  += " WHERE SE2.D_E_L_E_T_='' AND E2_PREFIXO='DV' AND E2_XXTIPBK<>'' AND E2_SALDO=E2_VALOR"
cQuery  += " AND E2_VENCREA>='"+DTOS(MV_PAR01)+"' AND E2_VENCREA<='"+DTOS(MV_PAR02)+"'"
 
cQuery  += " GROUP BY E2_FORNECE,A2_NOME,E2_LOJA"

TCQUERY cQuery NEW ALIAS "QSE2"


DbSelectArea("QSE2")
DbGoTop()
aCtrId := {}
Do While !eof()
	AADD(aCtrId,{.T.,QSZ2->Z2_NOME,DTOC(QSZ2->Z2_DATAPGT),TRANSFORM(QSZ2->Z2_VALOR,"@E 999,999,999.99"),QSZ2->Z2_BANCO,QSZ2->Z2_TIPOPES,QSZ2->Z2_VALOR,QSZ2->Z2_OBS,QSZ2->XX_RECNO})
	QSE2->(DbSkip())
Enddo
QSE2->(DbCloseArea())

If Empty(aCtrId)
	MsgStop("Nใo existem Itens associados", "Aten็ใo")
	RestArea(aAreaIni)
	Return
EndIf

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE "Liquidos do titulo: "+SE2->E2_NUM+cMsgEx FROM 000,000 TO 400,630 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 320,225
oPanelLeft:Align := CONTROL_ALIGN_LEFT

@ 000, 005 LISTBOX oListID FIELDS HEADER "","Nome","Pgto","Valor R$","Bco","Tipo","Obs." SIZE 310,185 OF oPanelLeft PIXEL 
oListID:SetArray(aCtrId)
oListID:bLine := {|| {If(aCtrId[oListId:nAt][1],oOk,oNo),aCtrId[oListId:nAt][2],aCtrId[oListId:nAt][3],aCtrId[oListId:nAt][4],aCtrId[oListId:nAt][5],aCtrId[oListId:nAt][6],aCtrId[oListId:nAt][8]}}
oListID:bLDblClick := {|| aCtrId[oListId:nAt][1] := ValidaMrk(aCtrId[oListId:nAt][1],lTitOk,aCtrId[oListId:nAt][2],aCtrId[oListId:nAt][8],cMsgEx),aCtrId[oListId:nAt][8] := cObs, oListID:DrawSelect()}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

If ( lOk )
	lOk:=.F.
	//Processa( {|| U_RBKFINA25()})
ENDIF	

RETURN NIL


USER FUNCTION RBKFINA25()
LOCAL aCabec := {}, aLinha := {}, aItens := {}
LOCAL nX := 0, nItem := 0
PRIVATE lMsHelpAuto := .T.
PRIVATE lMsErroAuto := .F.
Private cNFiscal := ""
Private cSerie   := "DNF


FOR IX_:=1 TO LEN(aCtrId)
	IF aCtrId[IX_,1] 
		cHist := "Aporte: "+TRIM(SM0->M0_NOME)+" "+TRIM(SE2->E2_PREFIXO)+" "+TRIM(SE2->E2_NUM)+" - R$ "+ALLTRIM(STR(SE2->E2_VALOR,15,2))
		aParametros := {"01","01",cHist,cForn,cLoja,cProd,cCCus,SE2->E2_VALOR,SE2->E2_VENCREA,cUsuario,cSuper}
   
		dbSelectArea("SX6")                      
		U_NumSf1() 

		aCabec := {	{"F1_TIPO"      , "N" , NIL},;
  					{"F1_FORMUL"    , "N" , NIL },;
  					{"F1_DOC"       , cNFiscal, NIL },;
					{"F1_SERIE"     , cSerie, NIL },;
					{"F1_EMISSAO"   , _dDtEmis , NIL },;
					{"F1_DTDIGIT"   , _dDtEmis , NIL },;
					{"F1_FORNECE"   , _cForn, NIL },;
					{"F1_LOJA"      , _cLoja, NIL },;
					{"F1_EST"       , "SP", NIL },;
					{"F1_ESPECIE"   , "", NIL },;
					{"F1_XXUSER"    , _cUsuario, NIL },;
					{"F1_XXUSERS"   , _cSuper, NIL }}          

           
		aItem  := {	{"D1_COD"    , _cProd, NIL },;
					{"D1_UM"     , "PC", NIL },;
					{"D1_QUANT"  , 1, NIL },;
					{"D1_VUNIT"  , _nValor, NIL },;
					{"D1_TOTAL"  , _nValor, NIL },;
					{"D1_XXHIST" , _cHist, NIL },; 
					{"D1_CC"     , _cCCus, NIL },; 
					{"D1_EMISSAO", _dDtEmis , NIL },; 
					{"D1_DTDIGIT", _dDtEmis , NIL },;
					{"D1_LOCAL"  , "01", NIL } } 


		Begin Transaction
			IncProc('Incluido DNF')
	
			nOpc := 3
 			MSExecAuto({|x,y,z| MATA140(x,y,z)}, aCabec, aItens, nOpc)   
			IF lMsErroAuto
		
		   		MsgStop("Problemas Inclusใo da DNF "+cDoc+"    "+cSerie+", informe o setor de T.I. ", "Aten็ใo")
	    		MostraErro()
				DisarmTransaction()
				Return
			Else
				Msginfo("DNF incluido com sucesso! "+cDoc+"    "+cSerie)
			EndIf
		End Transaction
    ENDIF
NEXT

RETURN NIL



Static Function  ValidPerg

Local aArea      := GetArea()
Local aRegistros := {}
LOCAL cPerg := "BKFINA25"

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Vencimento de:" ,"Vencimento de:"  ,"Vencimento de:"  ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Vencimento at้:","Vencimento at้:" ,"Vencimento at้:" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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
