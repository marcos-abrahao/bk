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
Local aButtons := {}

Local aCtrId
Local lOk      := .F.
Local aAreaIni := GetArea()
Local cQuery
Local lTitOk   := .T.
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
LOCAL aCabec := {}
LOCAL aItens := {}

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
					{"D1_QUANT"  , 1, NIL },;
					{"D1_VUNIT"  , _nValor, NIL },;
					{"D1_TOTAL"  , _nValor, NIL },;
					{"D1_XXHIST" , _cHist, NIL },; 
					{"D1_CC"     , _cCCus, NIL },; 
					{"D1_EMISSAO", _dDtEmis , NIL },; 
					{"D1_DTDIGIT", _dDtEmis , NIL },;
					{"D1_LOCAL"  , "01", NIL } } 

//					{"D1_UM"     , "PC", NIL },;

  		AADD(aItens,aItem)

		Begin Transaction
			IncProc('Incluido DNF')
	
			nOpc := 3
 			MSExecAuto({|x,y,z| MATA140(x,y,z)}, aCabec, aItens, nOpc)   
			IF lMsErroAuto
		
		   		MsgStop("Problemas Inclusใo da "+cSerie+"-"+cNFiscal+", informe o setor de T.I. ", "Aten็ใo")
	    		MostraErro()
				DisarmTransaction()
				Return
			Else
				Msginfo("DNF incluido com sucesso! "+cSerie+"-"+cNFiscal)
			EndIf
		End Transaction
    ENDIF
NEXT

RETURN NIL



Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

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




USER FUNCTION RBKFINXX()
LOCAL aCabec := {}, aItens := {}
LOCAL aTITULO := {}
//Local cLogSF1 := ""
LOCAL _cHist := "VALOR REFERENTE ALUGUEL POR 36 MESES PARA CONTRATO DERSA - LOCALIZADO A RUA BANDEIRANTES NUMERO 59 CASA 2 CENTRO DE CANANEIA.  DEPOSITAR CONFORME ABAIXO:    ALEXANDRE NEPOMUCENO ALMEIDA  CPF nฐ 117.957.328-57  BANCO ITAฺ AG. 9231 CONTA 12623-7 "
PRIVATE lMsHelpAuto := .F.
PRIVATE lMsErroAuto := .F.
Private cNFiscal := ""
Private cSerie   := "DNF


AADD(aTITULO,{'000796','10/02/2020',2500})
AADD(aTITULO,{'000796','10/03/2020',2500})
AADD(aTITULO,{'000796','10/04/2020',2500})

/*AADD(aTITULO,{'000796','10/05/2020',2500})
AADD(aTITULO,{'000796','10/06/2020',2500})
AADD(aTITULO,{'000796','10/07/2020',2500})
AADD(aTITULO,{'000796','10/08/2020',2500})
AADD(aTITULO,{'000796','10/09/2020',2500})
AADD(aTITULO,{'000796','10/10/2020',2500})
AADD(aTITULO,{'000796','10/11/2020',2500})
AADD(aTITULO,{'000796','10/12/2020',2500})
AADD(aTITULO,{'000796','10/01/2021',2500})
AADD(aTITULO,{'000796','10/02/2021',2500})
AADD(aTITULO,{'000796','10/03/2021',2500})
AADD(aTITULO,{'000796','10/04/2021',2500})
AADD(aTITULO,{'000796','10/05/2021',2500})
AADD(aTITULO,{'000796','10/06/2021',2500})
AADD(aTITULO,{'000796','10/07/2021',2500})
AADD(aTITULO,{'000796','10/08/2021',2500})
AADD(aTITULO,{'000796','10/09/2021',2500})
AADD(aTITULO,{'000796','10/10/2021',2500})
AADD(aTITULO,{'000796','10/11/2021',2500})
AADD(aTITULO,{'000796','10/12/2021',2500})
AADD(aTITULO,{'000796','10/01/2022',2500})
AADD(aTITULO,{'000796','10/02/2022',2500})
AADD(aTITULO,{'000796','10/03/2022',2500})
AADD(aTITULO,{'000796','10/04/2022',2500})
AADD(aTITULO,{'000796','10/05/2022',2500})
AADD(aTITULO,{'000796','10/06/2022',2500})
AADD(aTITULO,{'000796','10/07/2022',2500})
AADD(aTITULO,{'000796','10/08/2022',2500})
AADD(aTITULO,{'000796','10/09/2022',2500})
AADD(aTITULO,{'000796','10/10/2022',2500})
AADD(aTITULO,{'000796','10/11/2022',2500})
AADD(aTITULO,{'000796','10/12/2022',2500})
*/


FOR IX_:=1 TO LEN(aTITULO)
   
	dbSelectArea("SX6")

	cNFiscal := ""
	U_NumSf1() 

	dDataBase := CTOD(aTITULO[IX_,2]) - DAY(CTOD(aTITULO[IX_,2]))
	aCabec := { {"F1_FILIAL"    , xFILIAL("SF1") , NIL},;
			    {"F1_TIPO"      , "N" , NIL},;
				{"F1_FORMUL"    , "N" , NIL },;
				{"F1_DOC"       , cNFiscal, NIL },;
				{"F1_SERIE"     , cSerie, NIL },;
				{"F1_EMISSAO"   , CTOD('30/11/2019') , NIL },;
				{"F1_DTDIGIT"   , dDataBase, NIL },;
				{"F1_FORNECE"   , aTITULO[IX_,1], NIL },;
				{"F1_LOJA"      , "01", NIL },;
				{"F1_EST"       , "SP", NIL },;
				{"F1_ESPECIE"   , "", NIL },;
				{"F1_XXUSER"    , "000012", NIL },;
				{"F1_XXUSERS"   , "000012", NIL },;
				{"F1_COND"		,"002", Nil},;
				{"E2_NATUREZ"	,"0000000052", Nil},;
				{"E2_VENCTO"	,CTOD(aTITULO[IX_,2]), Nil}} 

           
	aItem  := {	{"D1_FILIAL" , xFILIAL("SD1") , NIL},;
				{"D1_COD"    , "000000000000102", NIL },;
				{"D1_QUANT"  , 1, NIL },;
				{"D1_VUNIT"  , aTITULO[IX_,3], NIL },;
				{"D1_TOTAL"  , aTITULO[IX_,3], NIL },;
				{"D1_XXHIST" , _cHist, NIL },; 
				{"D1_CC"     , "302000508", NIL },; 
				{"D1_LOCAL"  , "01", NIL } } 

/*
				{"D1_UM"     , "UN", NIL },;
				{"D1_FORNECE", aTITULO[IX_,1], NIL },;
				{"D1_LOJA"   , "01", NIL },;
				{"D1_DOC"       , cNFiscal, NIL },;
				{"D1_SERIE"     , cSerie, NIL },;
				{"D1_EMISSAO", CTOD('10/12/2019') , NIL },; 
				{"D1_DTDIGIT", CTOD('10/12/2019') , NIL },;
*/


//				{"D1_TES"    ,"106"},;
//				{"D1_CF"     ,"1933"},;
//				{"D1_CONTA"  ,"34202001"},;
//				{"D1_TOTAL"  , aTITULO[IX_,3], NIL },;


    AADD(aItens,aItem)           

	Begin Transaction
		IncProc('Incluido DNF')
	
		nOpc := 3
		MSExecAuto({|x, y, z| MATA103(x, y, z)}, aCabec, aItens, nOpc) 
		IF lMsErroAuto
		   	MsgStop("Problemas Inclusใo da "+cSerie+"-"+cNFiscal+", informe o setor de T.I. ", "Aten็ใo")
	    	MostraErro()
			DisarmTransaction()
			Return
		Else
			Msginfo("DNF incluido com sucesso! "+cSerie+"-"+cNFiscal)
		EndIf
	End Transaction
NEXT

RETURN NIL