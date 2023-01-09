#INCLUDE "PROTHEUS.CH"
 
/*/{Protheus.doc} BKCOMR09
BK - Relatório Gerencial de Compras
(Originado de cópia do BKCOMR6)
@Return
@author Adilson do Prado
@since 14/02/17
@version P12
/*/

User Function BKCOMR09()

Local _nI           := 0
Local aDbf 		    := {}
Local oTmpTb
Local titulo        := "Relatório Gerencial de Compras"

Private cTitulo     := "Relatório Gerencial de Compras"
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 220
Private tamanho     := "G"
Private nomeprog    := "BKCOMR9" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private cPerg       := "BKCOMR9"
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "BKCOMR9" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString     := "SC7"

PRIVATE	cPict       := "@E 99,999,999,999.99"
PRIVATE nPeriodo    := 1
PRIVATE nPlan       := 1
Private aHeader	    := {}
PRIVATE aTitulos,aCampos,aCabs,aTotal,aPlans := {}
PRIVATE cPEDI  		:= ""
PRIVATE cPEDF  		:= ""
PRIVATE dDataI  	:= ""
PRIVATE dDataF  	:= ""
PRIVATE cFornI  	:= ""
PRIVATE cFornF  	:= ""
PRIVATE cContraI  	:= ""
PRIVATE cContraF  	:= ""
PRIVATE dLimMedia   := DATE()
PRIVATE nNumCols    := 3
PRIVATE nAnteriores := 1

ValidPerg()
If !Pergunte(cPerg,.T.)
	Return Nil
Endif
u_MsgLog(cPerg)

cPEDI  		:= mv_par01
cPEDF 	 	:= mv_par02
dDataI  	:= mv_par03
dDataF  	:= mv_par04
cFornI  	:= mv_par05
cFornF  	:= mv_par06
cContraI  	:= mv_par07
cContraF  	:= mv_par08
dLimMedia   := mv_par09
nAnteriores := mv_par10
nNumCols    := mv_par11 
If nNumCols <= 0
	nNumCols := 3
EndIf

titulo   := "Relatório Gerencial de Compras - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
cTitulo  := titulo

aDbf    := {}
Aadd( aDbf, { 'XX_NFORNEC',	'C', 80,00 } ) 
Aadd( aDbf, { 'XX_CGC',		'C', 18,00 } ) 
Aadd( aDbf, { 'XX_PED',		'C', TamSx3("C7_NUM")[1],00 } )
Aadd( aDbf, { 'XX_EMISSAO',	'D', 08,00 } )
Aadd( aDbf, { 'XX_PRODT',  	'C', 15,00 } )
Aadd( aDbf, { 'XX_DESCP',  	'C', 60,00 } )
Aadd( aDbf, { 'XX_UM' ,   	'C', 03,00 } )
Aadd( aDbf, { 'XX_QTDE',   	'N', 11,02 } )
Aadd( aDbf, { 'XX_VUNIT',  	'N', 14,02 } )
Aadd( aDbf, { 'XX_TOTAL',  	'N', 14,02 } )
Aadd( aDbf, { 'XX_CC',     	'C', 09,00 } )
Aadd( aDbf, { 'XX_DESCC',  	'C', 40,00 } ) 
Aadd( aDbf, { 'XX_LIB',  	'C', 05,00 } ) 
Aadd( aDbf, { 'XX_ENTR',  	'C', 15,00 } ) 
Aadd( aDbf, { 'XX_QENTR',  	'N', 11,02 } )
Aadd( aDbf, { 'XX_XXURGEN', 'C', 03,00 } ) 
Aadd( aDbf, { 'XX_XXSGRP',  'C', TamSX3("B1_XXSGRP")[1],00 } )
Aadd( aDbf, { 'XX_DESCZI',  'C', TamSX3("ZI_DESC")[1],00 } )

Aadd( aDbf, { 'XX_MEDIA',   'N', 16,02 } )
Aadd( aDbf, { 'XX_ECONP',   'N', 10,02 } )
Aadd( aDbf, { 'XX_ECONV',   'N', 16,02 } )

FOR _nI := nNumCols TO 1 STEP -1
	Aadd( aDbf, { 'XX_FOR'+STRZERO(_nI,2),'C', 254,00 } )
	Aadd( aDbf, { 'XX_PED'+STRZERO(_nI,2),'C', TamSx3("C7_NUM")[1],00 } )
	Aadd( aDbf, { 'XX_DATA'+STRZERO(_nI,2),'D', 8,00 } )
	Aadd( aDbf, { 'XX_UNIT'+STRZERO(_nI,2),'N', 16,02 } )
	Aadd( aDbf, { 'XX_TOTAL'+STRZERO(_nI,2),'N', 16,02 } )
NEXT

///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,'TRB',.f.,.f. )
///IndRegua("TRB",cArqTmp,"XX_PED",,,"Indexando Arquivo de Trabalho") 
oTmpTb := FWTemporaryTable():New( "TRB")
oTmpTb:SetFields( aDbf )
oTmpTb:AddIndex("indice1", {"XX_PED"} )
oTmpTb:Create()

aCabs   := {}
aCampos := {}
aTotal  := {}
aTitulos:= {}

nomeprog := "BKCOMR9/"+TRIM(SUBSTR(cUsuario,7,15))

aAdd(aTitulos,nomeprog+" - "+titulo)
 
//aAdd(aCampos,"TRB->XX_CGC")
//aAdd(aCabs  ,"CNPJ")
//aAdd(aHeader,{"CNPJ","XX_CGC" ,"@!",18,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_PRODT")
aAdd(aCabs  ,"Produto")
aAdd(aTotal ,.F.)
aAdd(aHeader,{"Produto","XX_PRODT" ,"@!",15,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_DESCP")
aAdd(aCabs  ,"Desc. Produto")
aAdd(aTotal ,.F.)
aAdd(aHeader,{"Desc. Produto","XX_DESCP" ,"@!",60,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_XXSGRP")
aAdd(aCabs  ,"Grupo")
aAdd(aTotal ,.F.)
aAdd(aHeader,{"Grupo","XX_XXSGRP" ,"@!",TamSX3("B1_XXSGRP")[1],00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_DESCZI")
aAdd(aCabs  ,"Desc. Grupo")
aAdd(aTotal ,.F.)
aAdd(aHeader,{"Desc. Grupo","XX_DESCZI" ,"@!",TamSX3("ZI_DESC")[1],00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_UM")
aAdd(aCabs  ,"UM")
aAdd(aTotal ,.F.)
aAdd(aHeader,{"UM","XX_UM" ,"@!",03,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_QTDE")
aAdd(aCabs  ,"Qtde")
aAdd(aTotal ,.T.)
aAdd(aHeader,{"Qtde","XX_QTDE" ,"@E 99999999.99",11,02,"","","N","TRB","R"})


//aAdd(aCampos,"TRB->XX_CC")
//aAdd(aCabs  ,"Contrato")
//aAdd(aHeader,{"Contrato","XX_CC" ,"@!",09,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_DESCC")
aAdd(aCabs  ,"Descrição Contrato")
aAdd(aTotal ,.F.)
aAdd(aHeader,{"Descrição Contrato","XX_DESCC" ,"@!",40,00,"","","C","TRB","R"})

//aAdd(aCampos,"TRB->XX_LIB")
//aAdd(aCabs  ,"Liberado")
//aAdd(aHeader,{"Liberado","XX_LIB" ,"@!",5,00,"","","C","TRB","R"})

//aAdd(aCampos,"TRB->XX_ENTR")
//aAdd(aCabs  ,"Entregue")
//aAdd(aHeader,{"Entregue","XX_ENTR" ,"@!",15,00,"","","C","TRB","R"})

//aAdd(aCampos,"TRB->XX_QENTR")
//aAdd(aCabs  ,"Qtde Entregue")
//aAdd(aHeader,{"Qtde Entregue","XX_QENTR" ,"@E 99999999.99",11,02,"","","N","TRB","R"})

aAdd(aCampos,"TRB->XX_XXURGEN")
aAdd(aCabs  ,"Urgente")
aAdd(aTotal ,.F.)
aAdd(aHeader,{"Urgente","XX_XXURGEN" ,"@!",03,00,"","","C","TRB","R"})

FOR _nI := nNumCols TO 1 STEP -1
	aAdd(aCampos,"TRB->XX_FOR"+STRZERO(_nI,2))
	aAdd(aCabs  ,"Fornecedor "+STRZERO(_nI,2))
	aAdd(aTotal ,.F.)
	aAdd(aHeader,{"Fornecedor "+STRZERO(_nI,2),"XX_FOR"+STRZERO(_nI,2) ,"@!",10,0,"","","C","TRB","R"})  

	aAdd(aCampos,"TRB->XX_PED"+STRZERO(_nI,2))
	aAdd(aCabs  ,"Pedido "+STRZERO(_nI,2))
	aAdd(aTotal ,.F.)
	aAdd(aHeader,{"Pedido "+STRZERO(_nI,2),"XX_PED"+STRZERO(_nI,2) ,"@!",TamSx3("C7_NUM")[1],0,"","","C","TRB","R"})  

	aAdd(aCampos,"TRB->XX_DATA"+STRZERO(_nI,2))
	aAdd(aCabs  ,"Data pedido "+STRZERO(_nI,2))
	aAdd(aTotal ,.F.)
	aAdd(aHeader,{"Data pedido "+STRZERO(_nI,2),"XX_DATA"+STRZERO(_nI,2) ,"@E",8,0,"","","D","TRB","R"})  

	aAdd(aCampos,"TRB->XX_UNIT"+STRZERO(_nI,2))
	aAdd(aCabs  ,"Valor Unit. "+STRZERO(_nI,2))
	aAdd(aTotal ,.F.)
	aAdd(aHeader,{"Valor Unit. "+STRZERO(_nI,2),"XX_UNIT"+STRZERO(_nI,2) ,"@E 999,999,999.99",14,02,"","","N","TRB","R"})

	aAdd(aCampos,"TRB->XX_TOTAL"+STRZERO(_nI,2))
	aAdd(aCabs  ,"Valor Total "+STRZERO(_nI,2))
	aAdd(aTotal ,.T.)
	aAdd(aHeader,{"Valor Total "+STRZERO(_nI,2),"XX_TOTAL"+STRZERO(_nI,2) ,"@E 999,999,999.99",14,02,"","","N","TRB","R"})	
NEXT

aAdd(aCampos,"TRB->XX_NFORNEC")
aAdd(aCabs  ,"Fornecedor")
aAdd(aTotal ,.F.)
aAdd(aHeader,{"Fornecedor","XX_NFORNEC" ,"@!",80,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_PED")
aAdd(aCabs  ,"Pedido")
aAdd(aTotal ,.F.)
aAdd(aHeader,{"Pedido","XX_PED" ,"@!",6,00,"","","C","TRB","R"})

aAdd(aCampos,"TRB->XX_EMISSAO")
aAdd(aCabs  ,"Data pedido")
aAdd(aTotal ,.F.)
aAdd(aHeader,{"Data pedido","XX_EMISSAO" ,"",8,00,"","","D","TRB","R"})

aAdd(aCampos,"TRB->XX_VUNIT")
aAdd(aCabs  ,"Valor Unitário")
aAdd(aTotal ,.F.)
aAdd(aHeader,{"Valor Unitário","XX_VUNIT" ,"@E 999,999,999.99",16,02,"","","N","TRB","R"})

aAdd(aCampos,"TRB->XX_TOTAL")
aAdd(aCabs  ,"Valor Total")
aAdd(aTotal ,.T.)
aAdd(aHeader,{"Valor Total","XX_TOTAL" ,"@E 999,999,999.99",16,02,"","","N","TRB","R"})

aAdd(aCampos,"TRB->XX_MEDIA")
aAdd(aCabs  ,"Média")
aAdd(aTotal ,.F.)
aAdd(aHeader,{"Média","XX_MEDIA" ,"@E 999,999,999.99",16,02,"","","N","TRB","R"})

aAdd(aCampos,"TRB->XX_ECONP")
aAdd(aCabs  ,"Economia %")
aAdd(aTotal ,.F.)
aAdd(aHeader,{"Economia %","XX_ECONP" ,"@E 999.99",10,02,"","","N","TRB","R"})

aAdd(aCampos,"TRB->XX_ECONV")
aAdd(aCabs  ,"Economia R$")
aAdd(aTotal ,.T.)
aAdd(aHeader,{"Economia R$","XX_ECONV" ,"@E 999,999,999.99",16,02,"","","N","TRB","R"})

u_WaitLog(, {|| ProcBKCOMR9() })
u_WaitLog(, {|| MBrwBKCOMR9() })

oTmpTb:Delete()
///TRB->(Dbclosearea())
///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())
 
Return


Static Function MBrwBKCOMR9()
Local 	cAlias 		:= "TRB"

Private cCadastro	:= "Relatório Gerencial de Compras"
Private aRotina		:= {}
Private aIndexSz  	:= {}

Private aSize   := MsAdvSize(,.F.,400)
Private aObjects:= { { 450, 450, .T., .T. } }
Private aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aPosObj := MsObjSize( aInfo, aObjects, .T. )
Private lRefresh:= .T.
Private aButton := {}
Private _oGetDbSint
Private _oDlgSint

AADD(aRotina,{"Exp. Excel"	,"U_CBKCOMR9",0,6})
//AADD(aRotina,{"Imprimir"    ,"U_RBKCOMR9",0,7})
AADD(aRotina,{"Parametros"	,"U_PBKCOMR9",0,8})

dbSelectArea(cAlias)
dbSetOrder(1)
	
DEFINE MSDIALOG _oDlgSint ;
TITLE cCadastro ;
From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
_oGetDbSint := MsGetDb():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], 2, "AllwaysTrue()", "AllwaysTrue()",,,,,,"AllwaysTrue()","TRB")
	
aadd(aButton , { "BMPTABLE" , { || U_CBKCOMR9(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Gera Planilha Excel" } )
aadd(aButton , { "BMPTABLE" , { || U_RBKCOMR9(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Imprimir" } )
aadd(aButton , { "BMPTABLE" , { || U_PBKCOMR9(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Parametros" } )
	
ACTIVATE MSDIALOG _oDlgSint ON INIT EnchoiceBar(_oDlgSint,{|| _oDlgSint:End()}, {||_oDlgSint:End()},, aButton)

Return Nil



User FUNCTION PBKCOMR9()

ValidPerg()
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

cPEDI 	 	:= mv_par01
cPEDF 	 	:= mv_par02
dDataI  	:= mv_par03
dDataF  	:= mv_par04
cFornI  	:= mv_par05
cFornF  	:= mv_par06
cContraI  	:= mv_par07
cContraF  	:= mv_par08
dLimMedia   := mv_par09
nAnteriores := mv_par10
nNumCols    := mv_par11 
If nNumCols <= 0
	nNumCols := 3
EndIf

titulo   := "Pedidos de Compras - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
cTitulo  := titulo

u_WaitLog(, {|| ProcBKCOMR9() })

Return Nil
   

Static Function LimpaBrw(cAlias)
	DbSelectArea(cAlias)
	(cAlias)->(dbgotop())
	Do While (cAlias)->(!eof())
		RecLock(cAlias,.F.)
		(cAlias)->(dbDelete())
		(cAlias)->(MsUnlock())
       	dbselectArea(cAlias)
   		(cAlias)->(dbskip())
	ENDDO

Return (.T.) 


// Gera Excel
User FUNCTION CBKCOMR9()
Local aPlans  := {}

AADD(aPlans,{"TRB",TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */,aTotal /*aTotal */, /*cQuebra*/, lClose:= .F. })
U_GeraXml(aPlans,cTitulo,TRIM(cPerg),.F.)

Return 



Static Function ProcBKCOMR9
Local cQuery  := ""
Local nReg    := 0
Local Iy_     := 0
Local Ix_	  := 0
Local naITx_  := 0
Local dMedia
Local nMedia  := 0
Local nEconP  := 0
Local nEconV  := 0
Local nQtdMed := 0
Local aITx_   := {}
Local nPreco  := 0
Local nTotal  := 0

LimpaBrw("TRB")

cQuery := "SELECT C7_FORNECE,C7_LOJA,C7_NUM,C7_NUMCOT,C7_ITEM,C7_XXURGEN,C7_EMISSAO,C7_PRODUTO,SB1.B1_DESC,SB1.B1_XXSGRP,C7_UM,C7_QUANT,C7_QUJE,C7_PRECO,C7_TOTAL,C7_CC,"+CRLF
cQuery += " C7_VLDESC,C7_CONAPRO,CTT.CTT_DESC01, SA2.A2_NREDUZ, SA2.A2_NOME,SA2.A2_CGC"+CRLF
cQuery += " FROM "+RETSQLNAME("SC7")+" SC7"+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+" SB1 ON  SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SC7.C7_PRODUTO=SB1.B1_COD AND SB1.D_E_L_E_T_=''" +CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON  CTT.CTT_FILIAL='"+xFilial("CTT")+"' AND SC7.C7_CC=CTT.CTT_CUSTO AND CTT.D_E_L_E_T_=''" +CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SA2")+" SA2 ON  SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SC7.C7_FORNECE=SA2.A2_COD AND SC7.C7_LOJA=SA2.A2_LOJA AND SA2.D_E_L_E_T_=''" +CRLF
cQuery += " WHERE SC7.D_E_L_E_T_='' AND SC7.C7_EMISSAO>='"+DTOS(dDataI)+"' AND SC7.C7_EMISSAO<='"+DTOS(dDataF)+"'"+CRLF
cQuery += " AND SC7.C7_NUM >='"+ALLTRIM(cPEDI)+"' AND SC7.C7_NUM <='"+ALLTRIM(cPEDF)+"'" +CRLF
cQuery += " AND SC7.C7_FORNECE >='"+ALLTRIM(cFornI)+"' AND SC7.C7_FORNECE <='"+ALLTRIM(cFornF)+"'" +CRLF
cQuery += " AND SC7.C7_CC >='"+ALLTRIM(cContraI)+"' AND SC7.C7_CC <='"+ALLTRIM(cContraF)+"'"+CRLF

u_LogMemo("BKCOMR09.SQL",cQuery)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP",.T.,.T.)
tcSetField("QTMP","C7_EMISSAO","D",8,0)

ProcRegua(QTMP->(LASTREC()))

nReg := 0

DbSelectArea("SC7")
SC7->(DbSetOrder(4))


dbSelectArea("QTMP")
QTMP->(dbGoTop())
DO WHILE QTMP->(!EOF())
    nReg++
	//IncProc("Consultando banco de dados...")
	
	aITx_ := {}

/*
	cForPagto :=  ""
	DbSelectArea("SC8")
	SC8->(DbSetOrder(1))
	SC8->(DbSeek(xFilial("SC8")+QTMP->C7_NUMCOT,.T.))
    Do While SC8->(!eof()) .AND. SC8->C8_NUM==QTMP->C7_NUMCOT
        IF SC8->C8_ITEM==QTMP->C7_ITEM
   	    	cForPagto := "For.Pgto: "+Posicione("SE4",1,xFilial("SE4")+SC8->C8_COND,"E4_DESCRI")
	    	AADD(aITx_,{Posicione("SA2",1,Xfilial("SA2")+SC8->C8_FORNECE+SC8->C8_LOJA,"A2_NOME")+IIF(SC8->C8_NUMPED==QTMP->C7_NUM .AND. SC8->C8_ITEMPED ==QTMP->C7_ITEM ,"-Vencedor","")+" - "+cForPagto,SC8->C8_PRECO,SC8->C8_TOTAL})
		ENDIF
		SC8->(DbSkip())
	ENDDO
*/
    nPreco := 0
    nTotal := 0
	SC7->(DbSeek(xFilial("SC7")+QTMP->C7_PRODUTO,.T.))
    Do While SC7->(!eof()) .AND. SC7->C7_PRODUTO == QTMP->C7_PRODUTO
		IF (nAnteriores = 1) .OR. (SC7->C7_EMISSAO >= dLimMedia)
	        IF SC7->C7_NUM <> QTMP->C7_NUM
	            nTotal := SC7->C7_TOTAL - SC7->C7_VLDESC
	            nPreco := SC7->C7_PRECO
	            IF SC7->C7_VLDESC > 0
	               nPreco := nTotal / SC7->C7_QUANT
	            ENDIF
		    	AADD(aITx_,{Posicione("SA2",1,Xfilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME"),SC7->C7_NUM,SC7->C7_EMISSAO,nPreco,nTotal})
			ENDIF
		ENDIF
		SC7->(DbSkip())
	ENDDO

    nTotal := QTMP->C7_TOTAL - QTMP->C7_VLDESC
    nPreco := QTMP->C7_PRECO
    IF QTMP->C7_VLDESC > 0
       nPreco := nTotal / QTMP->C7_QUANT
    ENDIF
	
	Reclock("TRB",.T.)
	TRB->XX_NFORNEC := QTMP->A2_NOME
	TRB->XX_CGC     := QTMP->A2_CGC
	TRB->XX_PED 	:= QTMP->C7_NUM
	TRB->XX_PRODT 	:= QTMP->C7_PRODUTO
	TRB->XX_DESCP 	:= QTMP->B1_DESC
	TRB->XX_UM 		:= QTMP->C7_UM
	TRB->XX_QTDE 	:= QTMP->C7_QUANT
	TRB->XX_VUNIT 	:= nPreco
	TRB->XX_TOTAL 	:= nTotal
	TRB->XX_EMISSAO	:= QTMP->C7_EMISSAO
	TRB->XX_CC 		:= QTMP->C7_CC
	TRB->XX_DESCC 	:= QTMP->CTT_DESC01
	TRB->XX_LIB 	:= IIF(QTMP->C7_CONAPRO="L","Sim","Não")
	TRB->XX_ENTR 	:= IIF(QTMP->C7_QUANT==QTMP->C7_QUJE,"Total",IIF(QTMP->C7_QUJE>0,"Parcial","Não Entregue"))
	TRB->XX_QENTR	:= QTMP->C7_QUJE
	TRB->XX_XXURGEN	:= IIF(QTMP->C7_XXURGEN=="S","Sim","Não")
	TRB->XX_XXSGRP	:= QTMP->B1_XXSGRP
	TRB->XX_DESCZI	:= Posicione("SZI",1,xFilial("SZI")+QTMP->B1_XXSGRP,"ZI_DESC")

   	naITx_  := LEN(aITx_)
	cCampo  := ""    
    Iy_     := 1
    
	nMedia  := 0
	nEconP  := 0
	nEconV  := 0
	nQtdMed := 0

	FOR Ix_ := naITx_ TO 1 STEP -1
		cCampo  := "TRB->XX_FOR"+STRZERO(Iy_,2)
		&cCampo	:= aITx_[Ix_,1]
		
		cCampo  := "TRB->XX_PED"+STRZERO(Iy_,2)
		&cCampo	:= aITx_[Ix_,2]

		cCampo  := "TRB->XX_DATA"+STRZERO(Iy_,2)
		&cCampo	:= aITx_[Ix_,3]
		dMedia  := aITx_[Ix_,3]
		
		cCampo  := "TRB->XX_UNIT"+STRZERO(Iy_,2)
		nValUn  := aITx_[Ix_,4]
		&cCampo	:= nValUn
		
		IF dMedia > dLimMedia 
		   nMedia += nValUn
		   nQtdMed++
		ENDIF

		cCampo  := "TRB->XX_TOTAL"+STRZERO(Iy_,2)
		&cCampo	:= aITx_[Ix_,5]
		
		Iy_++
		IF Iy_ > nNumCols
			EXIT
		ENDIF
	NEXT
	
    IF nQtdMed > 0
		TRB->XX_MEDIA	:= nMedia / nQtdMed
		TRB->XX_ECONP   := 100 - (TRB->XX_VUNIT / TRB->XX_MEDIA * 100)
    	TRB->XX_ECONV   := (TRB->XX_ECONP * TRB->XX_TOTAL) / 100
    ENDIF
    
 	TRB->(Msunlock())
	dbSelectArea("QTMP")
	QTMP->(dbSkip())
ENDDO

DbSelectArea("SC7")
SC7->(DbSetOrder(1))

IF nReg < 1
	Reclock("TRB",.T.)
	TRB->XX_PED 	:= "Null"
 	TRB->(Msunlock())
ENDIF

TRB->(dbGoTop())

QTMP->(dbCloseArea())

Return



User Function RBKCOMR9()
Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cDesc3        := ""
Local nLin          := 80
Local Cabec1        := ""
Local Cabec2        := ""
Local aOrd          := {}
Local titulo        := ""

titulo := "Relatório Gerencial de Compras - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	wnrel := SetPrint(cString,"BKCOMR9",cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.) 
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	   Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	            
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	m_pag   := 01 
	
RETURN


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  08/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

nEsp    := 2
cPicQ 	:= "@E 99999999.99"
cPicV 	:= "@E 999,999,999.99"

Cabec1  += PAD("Razão Social",15+nEsp)
Cabec1  += PAD("CNPJ",LEN(TRB->XX_CGC)+nEsp)
Cabec1  += PAD("Pedido",LEN(TRB->XX_PED)+nEsp)
Cabec1  += PAD("Emissão",8+nEsp)
Cabec1  += PAD("Produto",LEN(TRB->XX_PRODT)+nEsp)
Cabec1  += PAD("Desc.Prod.",33+nEsp)
Cabec1  += PAD("UM",LEN(TRB->XX_UM)+nEsp)
Cabec1  += PADL("Qtd.",LEN(cPicQ)-1)+SPACE(nEsp)
Cabec1  += PADL("Unit. R$",LEN(cPicV)-3)+SPACE(nEsp)
Cabec1  += PADL("Total R$",LEN(cPicV)-3)+SPACE(nEsp)
Cabec1  += PAD("Contrato",LEN(TRB->XX_CC)+nEsp)
Cabec1  += PAD("Desc. Contrato",15+nEsp)
Cabec1  += PAD("Liberado",LEN(TRB->XX_LIB)+nEsp)
Cabec1  += PAD("Entregue",LEN(TRB->XX_ENTR)+nEsp)
Cabec1  += PADL("Qtde Entregue",LEN(cPicQ)-1)+SPACE(nEsp)


IF LEN(Cabec1) > 132
   Tamanho := "G"
ENDIF   

Titulo   := TRIM(Titulo)

nomeprog := "BKCOMR9/"+TRIM(SUBSTR(cUsuario,7,15))
   
Dbselectarea("TRB")
Dbgotop()
SetRegua(LastRec())

DO While !TRB->(EOF())

   IncRegua()
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio. . .                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If nLin > 75 // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,nomeprog,Tamanho,nTipo,,.F.)
      nLin := 9
   Endif

   nPos := 0
   @ nLin,nPos PSAY PAD(TRB->XX_NFORNEC,15) 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_CGC 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_PED
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_EMISSAO 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_PRODT
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY PAD(TRB->XX_DESCP,35)
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_UM 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_QTDE PICTURE cPicQ
   nPos := PCOL()+nEsp
   
   @ nLin,nPos PSAY TRB->XX_VUNIT PICTURE cPicV
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_TOTAL PICTURE cPicV 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_CC 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY PAD(TRB->XX_DESCC,15) 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_LIB 
   nPos := PCOL()+nEsp
   
   @ nLin,nPos PSAY TRB->XX_ENTR 
   nPos := PCOL()+nEsp 
   
   @ nLin,nPos PSAY TRB->XX_QENTR PICTURE cPicQ
   nPos := PCOL()+nEsp

   nLin++
  
   dbSkip()
EndDo


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return




Static Function  ValidPerg
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}
cPerg := "BKCOMR9"
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Pedido de:"                    ,"Pedido de:"     ,"Pedido de:"     ,"mv_ch1","C",06,0,0,"G",""          ,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SC7","S","",""})
AADD(aRegistros,{cPerg,"02","Pedido até:"                   ,"Pedido até:"    ,"Pedido até:"    ,"mv_ch2","C",06,0,0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SC7","S","",""})
AADD(aRegistros,{cPerg,"03","Período de:"                   ,"Período de:"    ,"Período de:"    ,"mv_ch3","D",08,0,0,"G","NaoVazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"04","Período de até:"               ,"Período de até:","Período de até:","mv_ch4","D",08,0,0,"G","NaoVazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"05","Fornecedor de:"                ,"Fornecedor de:" ,"Fornecedor de:" ,"mv_ch5","C",06,0,0,"G",""          ,"mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA2","S","",""})
AADD(aRegistros,{cPerg,"06","Fornecedor até:"               ,"Fornecedor até:","Fornecedor até:","mv_ch6","C",06,0,0,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SA2","S","",""})
AADD(aRegistros,{cPerg,"07","Contrato de:"                  ,"Contrato de:"   ,"Contrato de:"   ,"mv_ch7","C",09,0,0,"G",""          ,"mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"08","Contrato até:"                 ,"Contrato até:"  ,"Contrato até:"  ,"mv_ch8","C",09,0,0,"G","NaoVazio()","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"09","Dt limite média"               ,"Dt limite média","Dt limite média","mv_ch9","D",08,0,0,"G","NaoVazio()","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})   
AADD(aRegistros,{cPerg,"10","Mostrar compras anteriores    ","Compras anter." ,"Compras anter." ,"mv_cha","N",01,0,2,"C",""          ,"mv_par10","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"11","Qtd Compras                   ","Qtd Compras    ","Qtd Compras    ","mv_chb","N",01,0,0,"G","NaoVazio()","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})   


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

