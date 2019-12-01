#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BKESTC02   ºAutor  ³ Microsiga         º Data ³  28/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cria tela de consulta ao sb2                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP7 -                                                      º±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BKESTC02()
Local cAliasTopConst := ""
Local cQuery := ""

Private cArqTemp2    := ""
Private cArqTempConst := {}  
Private _cSelect 
Private _aCampos := {}
Private _aStru := {}
Private cGrupo := "", cCodigo := "", cArmazem := "", cDescricao := "", cFabric :="", cClaEs := ""  
Private nAtual, nEmpenhado, nPedVenda, nReservas,nPedidos, nDisponivel, nMPQ
Private cCodMat := space(15)
Private oCombo  := ""
Private cCombo  := Space(15)
Private aCombo  := {}

_cAlias := Alias()
_nOrder := IndexOrd()
_nRecno := Recno()

aAdd( aCombo, "Por Codigo" )
aAdd( aCombo, "Por Descrição" )
aAdd( aCombo, "Por Grupo" )

AADD(_aStru,{"OK"  ,"C",2,0})
AADD(_aStru,{"CODIGO" ,"C",15,0})
AADD(_aStru,{"ARMAZEM","C",2,0})
AADD(_aStru,{"DESCRICAO","C",40,0})
AADD(_aStru,{"MPQ","N",9,0})   
AADD(_aStru,{"MKUP","N",4,0})
AADD(_aStru,{"MARGEM","N",6,2})
AADD(_aStru,{"ATUAL","N",17,2})
AADD(_aStru,{"EMPENHADO","N",17,2})
AADD(_aStru,{"PEDVENDA","N",17,2})
AADD(_aStru,{"RESERVAS","N",17,2})
AADD(_aStru,{"PEDIDOS","N",17,2})
AADD(_aStru,{"DISPONIVEL","N",17,2})
AADD(_aStru,{"PRECO","N",12,5})
AADD(_aStru,{"COMISSAO","N",5,2}) 
AADD(_aStru,{"CUSTODOLAR","N",12,5})
AADD(_aStru,{"CLAES","C",1,0})  
AADD(_aStru,{"GRUPO"  ,"C",4,0})
AADD(_aStru,{"CM1"    ,"N",14,6})			// Custo Medio 1
AADD(_aStru,{"CM2"    ,"N",14,6})			// Custo Medio 2
AADD(_aStru,{"PIPI"   ,"N", 5,2})			// Percentual IPI
AADD(_aStru,{"PICMS"  ,"N", 5,2})			// Percentual ICMS
AADD(_aStru,{"LOCALIZ","C",20,0})			// Localizacao
AADD(_aStru,{"NCM"    ,"C",10,0})			// NCM

cArqTemp2:=CriaTrab(_aStru,.T.)
cArqTempConst:=CriaTrab(NIL,.F.)
cAliasTopConst := cArqTempConst

If Select("ARQTEMP")>0
	DbSelectArea("ARQTEMP")
	DbCLoseArea()
End If
DbUseArea(.T.,,cArqTemp2,"ARQTEMP")

//DbClearIndex()

//_cIndex :=Substr(CriaTrab(NIL,.F.),1,7)+"1"   
//_cIndex2:=Substr(CriaTrab(NIL,.F.),1,7)+"2"   
//_cIndex3:=Substr(CriaTrab(NIL,.F.),1,7)+"3"    

//_cChave :="CODIGO+ARMAZEM"
//_cChave2:="DESCRICAO+CODIGO+ARMAZEM"
//_cChave3:="GRUPO+CODIGO+ARMAZEM"

//Indregua("ARQTEMP",_cIndex,_cchave,,,"Selecionando Registros...")
//Indregua("ARQTEMP",_cIndex2,_cchave2,,,"Selecionando Registros...")
//Indregua("ARQTEMP",_cIndex3,_cchave3,,,"Selecionando Registros...")

//dBSETINDEX(_cIndex+ordbagext())
//dBSETINDEX(_cIndex2+ordbagext())
//dBSETINDEX(_cIndex3+ordbagext())

//dbSetorder(1)

DbSelectArea("ARQTEMP")
Dbgotop()

aadd( _aCampos, {"CODIGO"    ,"CODIGO"     ,"@!"} )
aadd( _aCampos, {"DESCRICAO" ,"DESCRICAO"  ,"@X"} )
aadd( _aCampos, {"ARMAZEM"   ,"ARM."       ,"@X"} )
aadd( _aCampos, {"DISPONIVEL","DISPONIVEL" ,"999999999999999.99"} )
aadd( _aCampos, {"CM1"       ,"Custo 1"    ,"@E 9,999,999.999999"} )
aadd( _aCampos, {"CM2"       ,"Custo 2"    ,"@E 9,999,999.999999"} )
aadd( _aCampos, {"PIPI"      ,"% IPI"      ,"@E 99.99"} )
aadd( _aCampos, {"PICMS"     ,"% ICMS"     ,"@E 99.99"} )
aadd( _aCampos, {"ATUAL"     ,"ATUAL"      ,"999999999999999.99"} )
aadd( _aCampos, {"EMPENHADO" ,"EMPENHO"    ,"999999999999999.99"} )
aadd( _aCampos, {"PEDVENDA"  ,"PED.VENDA"  ,"999999999999999.99"} )
aadd( _aCampos, {"PEDIDOS"   ,"COMPRAS"    ,"999999999999999.99"} )
aadd( _aCampos, {"ARMAZEM"   ,"Localização","@X"} )
aadd( _aCampos, {"GRUPO"     ,"GRUPO"      ,"@!"} )
aadd( _aCampos, {"NCM"       ,"NCM"        ,"@R 99.99.9999"} )

@ 050,001 TO 600,990 DIALOG oDlg2 TITLE "Saldos"
@ 003,002 TO 250,497 BROWSE "ARQTEMP" MARK "OK" OBJECT oBrowse fields _aCampos 
@ 260,010 COMBOBOX oCombo ITEMS aCombo SIZE 60,10 
@ 260,080 GET cCodMat picture "@!" F3 "SB1" SIZE 100,10

//SButton():New( 260, 190, 17, {|| FiltraCod(cCodMat,oCombo,.T.)},oDlg2,.T.,"Filtra em qualquer posição")
//SButton():New( 260, 230, 19, {|| FiltraCod(cCodMat,oCombo,.F.)},oDlg2,.T.,"Pesquisa texto exato")

TButton():New( 260, 190, "Filtrar"   , oDlg2,{|| MsgRun("Aguarde, filtrando produdos..."  ,"Processando",{|| FiltraCod(cCodMat,oCombo,.T.) }) },35,12,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( 260, 230, "Pesquisar" , oDlg2,{|| MsgRun("Aguarde, pesquisando produdos...","Processando",{|| FiltraCod(cCodMat,oCombo,.F.) }) },35,12,,,.F.,.T.,.F.,,.F.,,,.F. )


TButton():New( 260, 300, "Últimas Compras", oDlg2,{|| UltCompras() },50,12,,,.F.,.T.,.F.,,.F.,,,.F. )
TButton():New( 260, 370, "Últimas NFS" , oDlg2,{|| UltVendas()  },50,12,,,.F.,.T.,.F.,,.F.,,,.F. )

SButton():New( 260, 460,  2, {|| Close(oDlg2) },oDlg2,.T.,"Fecha a Consulta")

ACTIVATE DIALOG oDlg2 CENTERED 

DbSelectArea("ARQTEMP")
DBCLOSEAREA()
FERASE(cArqTempConst+getDbExtension())
FERASE(cArqTemp2+getDbExtension())
//FERASE(_cIndex+getDbExtension())
//FERASE(_cIndex2+getDbExtension())
//FERASE(_cIndex3+getDbExtension())

DbSelectArea(_cAlias)
DbSetOrder(_nOrder)
DbGoTo(_nRecno)
Return



//-------------------------------------------------------
Static Function UltCompras()
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cQuery, aTmp, oDlg, oLbx
Local  aItem    := {}

	cQuery := "select top 10 SD1.R_E_C_N_O_ D1RECNO, isnull(SC7.R_E_C_N_O_, 0) C7RECNO, D1_CC, A2_NOME from "+RetSqlName("SD1") + " SD1 (nolock) "
	cQuery += " join "+RetSqlName("SB1")+" SB1 (nolock) on B1_FILIAL='"+xFilial("SB1")+"' and B1_COD=D1_COD and SB1.D_E_L_E_T_ = '' "
	cQuery += " join "+RetSqlName("SA2")+" SA2 (nolock) on A2_FILIAL='"+xFilial("SA2")+"' and A2_COD=D1_FORNECE and A2_LOJA=D1_LOJA and SA2.D_E_L_E_T_ = '' "
	cQuery += " left join "+RetSqlName("SC7")+" SC7 (nolock) on C7_FILIAL='"+xFilial("SC7")+"' and C7_NUM=D1_PEDIDO and C7_ITEM=D1_ITEMPC and SC7.D_E_L_E_T_ = '' "
	cQuery += " where D1_FILIAL='"+xFilial("SD1")+"' "
	cQuery += " and D1_COD='"+ARQTEMP->CODIGO+"' "
	cQuery += " and D1_CF in ('1102','1201','1202','1411','2201','2202','1403','1556','1911','1912','2102','2912','3102') "
	cQuery += " and SD1.D_E_L_E_T_ = ''"
	cQuery += " order by D1_EMISSAO desc"
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)

	while ! (cAliasQry)->( EOF() )

		SD1->( dbGoto( (cAliasQry)->D1RECNO ) )
		
		aTmp := {}
		aadd( aTmp, SD1->D1_COD )
		aadd( aTmp, SD1->D1_XXDESCP )
		aadd( aTmp, SD1->D1_QUANT )

		if (cAliasQry)->C7RECNO > 0
			SC7->( dbGoto( (cAliasQry)->C7RECNO ) )

			aadd( aTmp, SC7->C7_MOEDA )
			aadd( aTmp, SC7->C7_PRECO )
			aadd( aTmp, SC7->C7_TOTAL )
		else
			aadd( aTmp, 1 )
			aadd( aTmp, SD1->D1_VUNIT )
			aadd( aTmp, SD1->D1_TOTAL )
		endif

		aadd( aTmp, SD1->D1_DOC +" "+SC7->C7_NUM+" "+SC7->C7_XXDESCP )
		aadd( aTmp, SD1->D1_DTDIGIT )
		aadd( aTmp, SD1->D1_FORNECE + " " + If (alltrim(SD1->D1_CF)$ "1201/1202/1411/2201/2202",Posicione("SA1",1,FWxFilial("SA1")+SD1->D1_FORNECE,"A1_NOME"),(cAliasQry)->A2_NOME))
		aadd( aTmp, (cAliasQry)->D1_CC )
		aadd( aItem, aTmp )

		(cAliasQry)->( dbSkip() )
	end

	if Select( cAliasQry ) > 0
		dbSelectArea( cAliasQry )
		dbCloseArea()
	endif

	if len( aItem ) == 0
		MsgAlert("Não há histórico","Últimas Compras")
		RestArea( aArea )
		Return nil
	endif

	@ 0,0 TO 260,700 DIALOG oDlg TITLE "Últimas Compras"

	@ 0,0 ListBox oLbx Fields Header 'Produto','Descrição','Quantidade','Moeda','Unitário','Total','NF + Pedido + Cod.For 2 + Fornecedor 2','Digitação','Fornecedor','CC' ColSizes 40, 60 Size 351,115 Of oDlg Pixel

	oLbx:SetArray(aItem)
	oLbx:bLine := { || { aItem[oLbx:nAt,01] ,;
						 aItem[oLbx:nAt,02] ,;
						 Transform(aItem[oLbx:nAt,03], "@E 99,999,999.99") ,;
						 StrZero(aItem[oLbx:nAt,04], 2) ,;
						 Transform(aItem[oLbx:nAt,05], "@E 9,999,999.999999") ,;
						 Transform(aItem[oLbx:nAt,06], "@E 9,999,999.999999") ,;
						 aItem[oLbx:nAt,07] ,;
						 aItem[oLbx:nAt,08] ,;
 						 aItem[oLbx:nAt,09] ,;
						 aItem[oLbx:nAt,10] } }
	oLbx:Refresh()

	SButton():New( 118, 322,  2, {|| Close(oDlg) }              ,oDlg,.T.,"Fechar")
	ACTIVATE MSDIALOG oDlg CENTERED

	RestArea( aArea )
Return nil




//-------------------------------------------------------
Static Function UltVendas()
Local _NomeUser := alltrim(UsrRetName(__cUserId))
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local cQuery, aTmp, oDlg, oLbx
Local  aItem    := {}
Local cCondVend := ""

	DBSelectArea("SA3")
	DBSetOrder(7)

	If dbSeek(xFilial("SA3")+__cUserId)
		If _NomeUser <> 'Administrador' .AND. _NomeUser <> 'Eduardo' .and. _NomeUser <> 'Neia' .and. _NomeUser <> 'Eliane' .and. _NomeUser <> 'Rosa' .and. _NomeUser <> 'Ellen'  
			cCondVend := " and C5_VEND1 = '" + SA3->A3_COD + "' "
		Endif
	ELSE
		If _NomeUser <> 'Administrador' .AND. _NomeUser <> 'Eduardo' .and. _NomeUser <> 'Neia' .and. _NomeUser <> 'Eliane' .and. _NomeUser <> 'Rosa' .and. _NomeUser <> 'Ellen'
			cCondVend := " and C5_VEND1 != 'PAT' "
		Endif
	Endif

	cQuery := "select top 10 SD2.R_E_C_N_O_ D2RECNO, D2_CCUSTO, B1_DESC, A1_NOME from "+RetSqlName("SD2") + " SD2 (nolock) "  
	cQuery += " join "+RetSqlName("SC5")+" SC5 (nolock) on C5_FILIAL='"+xFilial("SC5")+"' and C5_NUM=D2_PEDIDO and SC5.D_E_L_E_T_ = '' "
	cQuery += " join "+RetSqlName("SB1")+" SB1 (nolock) on B1_FILIAL='"+xFilial("SB1")+"' and B1_COD=D2_COD and SB1.D_E_L_E_T_ = '' "
	cQuery += " join "+RetSqlName("SA1")+" SA1 (nolock) on A1_FILIAL='"+xFilial("SA1")+"' and A1_COD=D2_CLIENTE and A1_LOJA=D2_LOJA and SA1.D_E_L_E_T_ = '' "
	cQuery += " where D2_FILIAL='"+xFilial("SD2")+"' "
	cQuery += " and D2_COD='"+ARQTEMP->CODIGO+"' "
	if ! Empty( cCondVend )
		cQuery += cCondVend
	endif
	cQuery += " and SD2.D_E_L_E_T_ = ''"
	cQuery += " order by D2_EMISSAO desc"
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.F.)

	while ! (cAliasQry)->( EOF() )

		SD2->( dbGoto( (cAliasQry)->D2RECNO ) )
		
		aTmp := {}
		aadd( aTmp, SD2->D2_COD )
		aadd( aTmp, (cAliasQry)->B1_DESC )
		aadd( aTmp, SD2->D2_QUANT )
		aadd( aTmp, SD2->D2_PRCVEN )
		aadd( aTmp, SD2->D2_TOTAL )
		aadd( aTmp, SD2->D2_EMISSAO )
		aadd( aTmp, SD2->D2_DOC )
		aadd( aTmp, SD2->D2_CLIENTE + " " + (cAliasQry)->A1_NOME )
		aadd( aTmp, SD2->D2_CCUSTO )
		aadd( aItem, aTmp )

		(cAliasQry)->( dbSkip() )
	end

	if Select( cAliasQry ) > 0
		dbSelectArea( cAliasQry )
		dbCloseArea()
	endif

	if len( aItem ) == 0
		MsgAlert("Não há histórico","Últimas NFS")
		RestArea( aArea )
		Return nil
	endif

	@ 0,0 TO 260,700 DIALOG oDlg TITLE "Últimas NFS"
	@ 0,0 ListBox oLbx Fields Header 'Produto','Descrição','Quantidade','Unitário','Total','Emissão','NF','Cliente','CC' ColSizes 40, 60 Size 351,115 Of oDlg Pixel

	oLbx:SetArray(aItem)
	oLbx:bLine := { || { aItem[oLbx:nAt,01] ,;
						 aItem[oLbx:nAt,02] ,;
						 Transform(aItem[oLbx:nAt,03], "@E 99,999,999.99") ,;
						 Transform(aItem[oLbx:nAt,04], "@E 9,999,999.999999") ,;
						 Transform(aItem[oLbx:nAt,05], "@E 9,999,999.999999") ,;
						 aItem[oLbx:nAt,06] ,;
						 aItem[oLbx:nAt,07] ,;
						 aItem[oLbx:nAt,08] ,;
						 aItem[oLbx:nAt,09] } }
	oLbx:Refresh()

	SButton():New( 118, 322,  2, {|| Close(oDlg) },oDlg,.T.,"Fechar")
	ACTIVATE MSDIALOG oDlg CENTERED

	RestArea( aArea )
Return nil





//-------------------------------------------------------
Static Function FiltraCod(cCodMat,oCombo,lLike)

	If Select("ARQTEMP") > 0
		DbSelectArea("ARQTEMP")
		DbCLoseArea()
		FERASE(cArqTemp2+getDbExtension())
	EndIf
	
	cArqTemp2 := CriaTrab(_aStru,.T.)
	DbUseArea(.T.,,cArqTemp2,"ARQTEMP")
                      
	cQuery := "SELECT  SB1.B1_GRUPO AS GRUPO,SB2.B2_COD AS CODIGO, SB2.B2_LOCAL AS ARMAZEM, SB1.B1_DESC AS DESCRICAO, SB1.B1_PRV1 AS PRECO "
	cQuery += 				", SB2.B2_QATU AS ATUAL, SB2.B2_QEMP AS EMPENHADO, SB2.B2_QPEDVEN AS PEDIDOVENDA, SB2.B2_RESERVA AS RESERVAS "
	cQuery += 				", SB2.B2_SALPEDI AS SALPEDIDOS "
	cQuery += 				", B2_CM1, B2_CM2, B1_IPI, B1_PICM, B1_POSIPI "
	cQuery += "FROM "+RetSqlName("SB2")+ " SB2, "+RetSqlName("SB1")+ " SB1 "
	cQuery += "WHERE  SB1.B1_FILIAL = '" + xfilial("SB1") + "' AND  SB2.B2_FILIAL = '" + xfilial("SB2") + "' AND "
	cQuery += "SB1.B1_COD = SB2.B2_COD AND "

	If oCombo == "Por Codigo"
		If lLike
			cQuery += "SB2.B2_COD LIKE '%"+ALLTRIM(cCodMat)+"%' AND "
		Else
			cQuery += "SB2.B2_COD = '"+ALLTRIM(cCodMat)+"' AND "
		EndIf
	ElseIf oCombo == "Por Descrição"                          
		cQuery += "SB1.B1_DESC LIKE '%"+ALLTRIM(cCodMat)+"%' AND "
	Else  //por grupo
		If lLike
			cQuery += "SB1.B1_GRUPO LIKE '%"+ALLTRIM(cCodMat)+"%' AND "
		Else
			cQuery += "SB1.B1_GRUPO = '"+ALLTRIM(cCodMat)+"' AND "
		EndIf
	EndIf

	cQuery += "SB1.D_E_L_E_T_ <> '*' AND "
	cQuery += "SB2.D_E_L_E_T_ <> '*'  "
	
	If oCombo == "Por Codigo"
		cQuery += "ORDER BY SB2.B2_COD,SB2.B2_LOCAL "
	ElseIf oCombo == "Por Descrição"                          
		cQuery += "ORDER BY SB1.B1_DESC,SB2.B2_COD,SB2.B2_LOCAL"
	Else  //por grupo
		cQuery += "ORDER BY SB1.B1_GRUPO,SB2.B2_COD,SB2.B2_LOCAL"
	EndIf
	
	If Select(cArqTempConst)>0
		DbSelectArea(cArqTempConst)
		DbCLoseArea()
	EndIf
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cArqTempConst,.T.,.F.)

	While !eof()
	   cGrupo 		:= GRUPO
	   cCodigo 		:= CODIGO
	   cArmazem		:= ARMAZEM
	   cDescricao	:= DESCRICAO
	   nAtual		:= ATUAL
	   nEmpenhado	:= EMPENHADO
	   nPedVenda	:= PEDIDOVENDA
	   nReservas	:= RESERVAS
	   nPedidos		:= SALPEDIDOS
   
	   nDisponivel	:= nAtual-(nEmpenhado+nReservas+nPedVenda)
   
	   DbSelectArea("ARQTEMP")
	   Reclock("ARQTEMP",.T.)

	   ARQTEMP->GRUPO 		:= cGrupo
	   ARQTEMP->CODIGO 		:= cCodigo
	   ARQTEMP->ARMAZEM 	:= cArmazem
	   ARQTEMP->DESCRICAO 	:= cDescricao
	   ARQTEMP->ATUAL 		:= nAtual
	   ARQTEMP->EMPENHADO 	:= nEmpenhado
	   ARQTEMP->PEDVENDA 	:= nPedVenda
	   ARQTEMP->RESERVAS 	:= nReservas
	   ARQTEMP->PEDIDOS 	:= nPedidos
	   ARQTEMP->DISPONIVEL  := nDisponivel

		ARQTEMP->CM1		:= (cArqTempConst)->B2_CM1
		ARQTEMP->CM2		:= (cArqTempConst)->B2_CM2
		ARQTEMP->PIPI		:= (cArqTempConst)->B1_IPI
		ARQTEMP->PICMS		:= (cArqTempConst)->B1_PICM
		ARQTEMP->NCM		:= (cArqTempConst)->B1_POSIPI

	   MsUnlock()
	   DbSelectArea(cArqTempConst)
	   DbSkip()
	Enddo

	DbSelectArea("ARQTEMP")
	Dbgotop()
	oBrowse:oBrowse:Refresh()
   
   Dbgotop()
Return
 