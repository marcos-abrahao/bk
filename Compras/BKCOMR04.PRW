#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
 
/*/{Protheus.doc} BKCOMR04
BK - Movimento Compras

@Return
@author Adilson do Prado
@since 12/03/13
@version P12
/*/


User Function BKCOMR04()

Local aDbf 		    := {}
Local oTmpTb
Local titulo        := "Movimento Compras"

Private cTitulo     := "Movimento Compras"
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 220
Private tamanho     := "G"
Private nomeprog    := "BKCOMR04" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private cPerg       := "BKCOMR04"
Private cbtxt        := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "BKCOMR04" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString     := "SD1"

PRIVATE dDataInicio := dDatabase
PRIVATE dDataFinal  := dDatabase
PRIVATE cSituac     := "05"
PRIVATE	cPict       := "@E 99,999,999,999.99"
PRIVATE nPeriodo    := 1
PRIVATE nPlan       := 1
Private aHeader	    := {}
PRIVATE aTitulos,aCampos,aCabs,aCampos2,aCabs2
PRIVATE cGrupoPI  	:= ""
PRIVATE cGrupoPF  	:= ""
PRIVATE cSGrupoPI  	:= ""
PRIVATE cSGrupoPF  	:= ""
PRIVATE cProdI  	:= ""
PRIVATE cProdF  	:= ""
PRIVATE dDataI		:= dDatabase
PRIVATE dDataF  	:= dDatabase
PRIVATE cFornI  	:= ""
PRIVATE cLojaI  	:= ""
PRIVATE cFornF  	:= ""
PRIVATE cLojaF  	:= ""
PRIVATE cContraI  	:= ""
PRIVATE cContraF  	:= ""
PRIVATE cConta  	:= ""


ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

cGrupoPI  	:= mv_par01
cGrupoPF  	:= mv_par02
cSGrupoPI  	:= mv_par03
cSGrupoPF  	:= mv_par04
cProdI  	:= mv_par05
cProdF  	:= mv_par06
dDataI  	:= mv_par07
dDataF  	:= mv_par08
cFornI  	:= mv_par09
cLojaI  	:= mv_par10
cFornF  	:= mv_par11
cLojaF  	:= mv_par12
cContraI  	:= mv_par13
cContraF  	:= mv_par14
cConta  	:= mv_par15

titulo   := "Movimento Compras - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
cTitulo  := titulo

aDbf    := {}
Aadd( aDbf, { 'XX_DOC',		'C', 09,00 } )
Aadd( aDbf, { 'XX_SERIE',	'C', 03,00 } )
Aadd( aDbf, { 'XX_GRPPROD',	'C', 04,00 } )
Aadd( aDbf, { 'XX_SGRPROD',	'C', 04,00 } )
Aadd( aDbf, { 'XX_PRODT',  	'C', 15,00 } )
Aadd( aDbf, { 'XX_DESCP',  	'C', 60,00 } )
Aadd( aDbf, { 'XX_CONTA',  	'C', TamSx3("B1_CONTA")[1],00 } )
Aadd( aDbf, { 'XX_QTDE',   	'N', 11,02 } )
Aadd( aDbf, { 'XX_VUNIT',  	'N', 14,02 } )
Aadd( aDbf, { 'XX_TOTAL',  	'N', 14,02 } )
Aadd( aDbf, { 'XX_DATAC',  	'D', 08,00 } )
Aadd( aDbf, { 'XX_CC',     	'C', 09,00 } )
Aadd( aDbf, { 'XX_DESCC',  	'C', 40,00 } ) 
Aadd( aDbf, { 'XX_FORNEC', 	'C', 06,00 } )
Aadd( aDbf, { 'XX_LOJA',   	'C', 02,00 } ) 
Aadd( aDbf, { 'XX_FANTASI',	'C', 20,00 } ) 
Aadd( aDbf, { 'XX_NFORNEC',	'C', 80,00 } ) 


///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,'TRB',.f.,.f. )
///IndRegua("TRB",cArqTmp,"DTOS(XX_DATAC)+XX_FORNEC+XX_LOJA+XX_PRODT",,,"Indexando Arquivo de Trabalho") 

oTmpTb := FWTemporaryTable():New( "TRB")
oTmpTb:SetFields( aDbf )
oTmpTb:AddIndex("indice1", {"XX_DATAC","XX_FORNEC","XX_LOJA","XX_PRODT"} )
oTmpTb:Create()

aCabs   := {}
aCampos := {}
aTitulos:= {}

nomeprog := "BKCOMR04/"+TRIM(SUBSTR(cUsuario,7,15))

AADD(aTitulos,nomeprog+" - "+titulo)


AADD(aCampos,"TRB->XX_DOC")
AADD(aCabs  ,"Num. NF")
aadd(aHeader,{"Num. NF","XX_DOC" ,"@!",9,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_SERIE")
AADD(aCabs  ,"Serie")
aadd(aHeader,{"Serie","XX_SERIE" ,"@!",3,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_GRPPROD")
AADD(aCabs  ,"Grupo de Produtos")
aadd(aHeader,{"Grupo de Produtos","XX_GRPPROD" ,"@!",30,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_SGRPROD")
AADD(aCabs  ,"Sub Grupo de Produtos")
aadd(aHeader,{"Sub Grupo de Produtos","XX_SGRPROD" ,"@!",30,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_PRODT")
AADD(aCabs  ,"Produtos")
aadd(aHeader,{"Produtos","XX_PRODT" ,"@!",15,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_DESCP")
AADD(aCabs  ,"Desc. Produtos")
aadd(aHeader,{"Desc. Produtos","XX_DESCP" ,"@!",60,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_CONTA")
AADD(aCabs  ,"Conta")
aadd(aHeader,{"Conta","XX_CONTA" ,"@!",TamSx3("B1_CONTA")[1],00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_QTDE")
AADD(aCabs  ,"Qtde")
aadd(aHeader,{"Qtde","XX_QTDE" ,"@E 99999999.99",11,02,"","","N","TRB","R"})

AADD(aCampos,"TRB->XX_VUNIT")
AADD(aCabs  ,"Valor Unitário")
aadd(aHeader,{"Valor Unitário","XX_VUNIT" ,"@E 999,999,999.99",14,02,"","","N","TRB","R"})

AADD(aCampos,"TRB->XX_TOTAL")
AADD(aCabs  ,"Valor Total")
aadd(aHeader,{"Valor Total","XX_TOTAL" ,"@E 999,999,999.99",14,02,"","","N","TRB","R"})

AADD(aCampos,"TRB->XX_DATAC")
AADD(aCabs  ,"Data Compra")
AADD(aHeader,{"Data Compra","XX_DATAC" ,"",08,00,"","","D","TRB","R"})

AADD(aCampos,"TRB->XX_CC")
AADD(aCabs  ,"Contrato")
AADD(aHeader,{"Contrato","XX_CC" ,"@!",09,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_DESCC")
AADD(aCabs  ,"Descrição Contrato")
AADD(aHeader,{"Descrição Contrato","XX_DESCC" ,"@!",40,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_FORNEC")
AADD(aCabs  ,"Cod. Fornecedor")
AADD(aHeader,{"Cod. Fornecedor","XX_FORNEC" ,"@!",06,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_LOJA")
AADD(aCabs  ,"Loja Fornecedor")
AADD(aHeader,{"Cod. Fornecedor","XX_LOJA" ,"@!",02,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_FANTASI")
AADD(aCabs  ,"Nome Fantasia")
AADD(aHeader,{"Nome Fantasia","XX_FANTASI" ,"@!",20,00,"","","C","TRB","R"})


AADD(aCampos,"TRB->XX_NFORNEC")
AADD(aCabs  ,"Razão Social")
AADD(aHeader,{"Razão Social","XX_NFORNEC" ,"@!",80,00,"","","C","TRB","R"})

Processa( {|| ProcBKCOMR04() })
Processa( {|| MBrwBKCOMR04() })

///TRB->(Dbclosearea())
///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())
oTmpTb:Delete()

Return


Static Function MBrwBKCOMR04()
Local 	cAlias 		:= "TRB"

Private cCadastro	:= "Movimento Compras - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
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

AADD(aRotina,{"Exp. Excel"	,"U_CBKCOMR04",0,6})
AADD(aRotina,{"Imprimir"    ,"U_RBKCOMR04",0,7})
AADD(aRotina,{"Parametros"	,"U_PBKCOMR04",0,8})
AADD(aRotina,{"Legenda"		,"U_LBKCOMR04",0,9})

dbSelectArea(cAlias)
dbSetOrder(1)
	
DEFINE MSDIALOG _oDlgSint ;
TITLE cCadastro ;
From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
_oGetDbSint := MsGetDb():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], 2, "AllwaysTrue()", "AllwaysTrue()",,,,,,"AllwaysTrue()","TRB")
	
aadd(aButton , { "BMPTABLE" , { || U_CBKCOMR04(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Gera Planilha Excel" } )
aadd(aButton , { "BMPTABLE" , { || U_RBKCOMR04(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Imprimir" } )
aadd(aButton , { "BMPTABLE" , { || U_PBKCOMR04(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Parametros" } )
aadd(aButton , { "BMPTABLE" , { || U_LBKCOMR04()}, "Legenda" } )
	
ACTIVATE MSDIALOG _oDlgSint ON INIT EnchoiceBar(_oDlgSint,{|| _oDlgSint:End()}, {||_oDlgSint:End()},, aButton)

Return Nil




User Function LBKCOMR04()
Local aLegenda := {}

AADD(aLegenda,{"BR_VERMELHO"," - Cancelado"})
AADD(aLegenda,{"BR_AMARELO"," - Em Elaboração" })
AADD(aLegenda,{"BR_AZUL" ," - Emitido"})
AADD(aLegenda,{"BR_LARANJA"," - Em Aprovação" })
AADD(aLegenda,{"BR_VERDE"," - Vigente" })
AADD(aLegenda,{"BR_CINZA"," - Paralisado" })
AADD(aLegenda,{"BR_MARRON"," - Sol. Finalização" })
AADD(aLegenda,{"BR_PRETO"," - Finalizado" })
AADD(aLegenda,{"BR_PINK"," - Revisão" })
AADD(aLegenda,{"BR_BRANCO"," - Revisado" })

BrwLegenda(cCadastro, "Legenda", aLegenda)

Return Nil



User FUNCTION PBKCOMR04()

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

cGrupoPI  	:= mv_par01
cGrupoPF  	:= mv_par02
cSGrupoPI  	:= mv_par03
cSGrupoPF  	:= mv_par04
cProdI  	:= mv_par05
cProdF  	:= mv_par06
dDataI  	:= mv_par07
dDataF  	:= mv_par08
cFornI  	:= mv_par09
cLojaI  	:= mv_par10
cFornF  	:= mv_par11
cLojaF  	:= mv_par12
cContraI  	:= mv_par13
cContraF  	:= mv_par14
cConta  	:= mv_par15

titulo   := "Movimento Compras - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
cTitulo  := titulo

Processa( {|| ProcBKCOMR04() })

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
User FUNCTION CBKCOMR04()
Local aPlans  := {}

AADD(aPlans,{"TRB",TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
U_GeraXml(aPlans,cTitulo,TRIM(cPerg),.F.)

Return 



Static Function ProcBKCOMR04
Local cQuery := ""
Local nReg   := 0
Local nLenCt := 0

LimpaBrw("TRB")

cQuery := "SELECT SD1.D1_DOC,SD1.D1_SERIE, SBM.BM_DESC, SZI.ZI_DESC, SD1.D1_COD, SB1.B1_DESC,SB1.B1_CONTA, SD1.D1_QUANT, SD1.D1_VUNIT, SD1.D1_TOTAL,"
cQuery += " SD1.D1_DTDIGIT, SD1.D1_CC, CTT.CTT_DESC01, SD1.D1_FORNECE, SD1.D1_LOJA , SA2.A2_NREDUZ, SA2.A2_NOME"
cQuery += " FROM "+RETSQLNAME("SD1")+" SD1"
cQuery += " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON  SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SD1.D1_COD=SB1.B1_COD AND SB1.D_E_L_E_T_=''" 
cQuery += " LEFT JOIN "+RETSQLNAME("SBM")+" SBM ON  SBM.BM_FILIAL='"+xFilial("SBM")+"' AND SB1.B1_GRUPO=SBM.BM_GRUPO AND SBM.D_E_L_E_T_=''"
cQuery += " LEFT JOIN "+RETSQLNAME("SZI")+" SZI ON  SZI.ZI_FILIAL='"+xFilial("SZI")+"' AND SB1.B1_XXSGRP=SZI.ZI_COD AND SB1.D_E_L_E_T_=''" 
cQuery += " INNER JOIN "+RETSQLNAME("CTT")+" CTT ON  CTT.CTT_FILIAL='"+xFilial("CTT")+"' AND SD1.D1_CC=CTT.CTT_CUSTO AND CTT.D_E_L_E_T_=''" 
cQuery += " INNER JOIN "+RETSQLNAME("SA2")+" SA2 ON  SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SD1.D1_FORNECE=SA2.A2_COD AND SD1.D1_LOJA=SA2.A2_LOJA AND SA2.D_E_L_E_T_=''" 
 
cQuery += " WHERE SD1.D_E_L_E_T_='' AND SD1.D1_DTDIGIT>='"+DTOS(dDataI)+"' AND SD1.D1_DTDIGIT<='"+DTOS(dDataF)+"'
cQuery += " AND SB1.B1_GRUPO >='"+ALLTRIM(cGrupoPI)+"' AND SB1.B1_GRUPO <='"+ALLTRIM(cGrupoPF)+"'" 
cQuery += " AND SB1.B1_XXSGRP >='"+ALLTRIM(cSGrupoPI)+"' AND SB1.B1_XXSGRP <='"+ALLTRIM(cSGrupoPF)+"'" 
cQuery += " AND SD1.D1_COD >='"+ALLTRIM(cProdI)+"' AND SD1.D1_COD <='"+ALLTRIM(cProdF)+"'" 

cQuery += " AND SD1.D1_FORNECE >='"+ALLTRIM(cFornI)+"' AND SD1.D1_FORNECE <='"+ALLTRIM(cFornF)+"'" 
cQuery += " AND SD1.D1_LOJA >='"+ALLTRIM(cLojaI)+"' AND SD1.D1_LOJA <='"+ALLTRIM(cLojaF)+"'" 

cQuery += " AND SD1.D1_CC >='"+ALLTRIM(cContraI)+"' AND SD1.D1_CC <='"+ALLTRIM(cContraF)+"'"
If !Empty(cConta)
	nLenCt := LEN(ALLTRIM(cConta))
	cQuery += " AND SUBSTRING(SD1.D1_CONTA,1,"+STR(nLenCt)+") = '"+ALLTRIM(cConta)+"'"
EndIf		
 
TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","D1_DTDIGIT","D",8,0)


ProcRegua(QTMP->(LASTREC()))

nReg := 0

dbSelectArea("QTMP")
QTMP->(dbGoTop())
DO WHILE QTMP->(!EOF())
    nReg++
	IncProc("Consultando banco de dados...")
	Reclock("TRB",.T.)
	TRB->XX_DOC 	:= QTMP->D1_DOC
	TRB->XX_SERIE 	:= QTMP->D1_SERIE
	TRB->XX_GRPPROD := QTMP->BM_DESC
	TRB->XX_SGRPROD := QTMP->ZI_DESC
	TRB->XX_PRODT 	:= QTMP->D1_COD
	TRB->XX_DESCP 	:= QTMP->B1_DESC
	TRB->XX_CONTA	:= QTMP->B1_CONTA
	TRB->XX_QTDE 	:= QTMP->D1_QUANT
	TRB->XX_VUNIT 	:= QTMP->D1_VUNIT
	TRB->XX_TOTAL 	:= QTMP->D1_TOTAL
	TRB->XX_DATAC 	:= QTMP->D1_DTDIGIT
	TRB->XX_CC 		:= QTMP->D1_CC
	TRB->XX_DESCC 	:= QTMP->CTT_DESC01
	TRB->XX_FORNEC	:= QTMP->D1_FORNECE
	TRB->XX_LOJA 	:= QTMP->D1_LOJA
	TRB->XX_FANTASI := QTMP->A2_NREDUZ
	TRB->XX_NFORNEC := QTMP->A2_NOME
 	TRB->(Msunlock())
	dbSelectArea("QTMP")
	QTMP->(dbSkip())
ENDDO

IF nReg < 1
	Reclock("TRB",.T.)
	TRB->XX_DOC 	:= "Null"
 	TRB->(Msunlock())
ENDIF

TRB->(dbGoTop())

QTMP->(dbCloseArea())

Return



User Function RBKCOMR04()
Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cDesc3        := ""
Local nLin          := 80
Local Cabec1        := ""
Local Cabec2        := ""
Local aOrd          := {}
Local titulo        := ""

titulo := "Movimento Compras - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	wnrel := SetPrint(cString,"BKCOMR04",cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.) 
	
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

Cabec1  := PAD("Num. NF",LEN(TRB->XX_DOC)+nEsp)
Cabec1  += PAD("Serie",LEN(TRB->XX_SERIE)+nEsp)
Cabec1  += PAD("Grupo",LEN(TRB->XX_GRPPROD)+nEsp)
Cabec1  += PAD("SubGrupo",LEN(TRB->XX_SGRPROD)+nEsp)
Cabec1  += PAD("Produto",LEN(TRB->XX_PRODT)+nEsp)
Cabec1  += PAD("Desc.Prod.",33+nEsp)
Cabec1  += PADL("Qtd.",LEN(cPicQ)-1)+SPACE(nEsp)
Cabec1  += PADL("Unit. R$",LEN(cPicV)-3)+SPACE(nEsp)
Cabec1  += PADL("Total R$",LEN(cPicV)-3)+SPACE(nEsp)
Cabec1  += PAD("Data",8+nEsp)
Cabec1  += PAD("Contrato",LEN(TRB->XX_CC)+nEsp)
Cabec1  += PAD("Desc. Contrato",15+nEsp)
Cabec1  += PAD("Fornec",LEN(TRB->XX_FORNEC)+nEsp)
Cabec1  += PAD("Lj",LEN(TRB->XX_LOJA)+nEsp)
Cabec1  += PAD("Nome Fantasia",LEN(TRB->XX_FANTASI)+nEsp)
Cabec1  += PAD("Razão Social",15+nEsp)

IF LEN(Cabec1) > 132
   Tamanho := "G"
ENDIF   

Titulo   := TRIM(Titulo)

nomeprog := "BKCOMR04/"+TRIM(SUBSTR(cUsuario,7,15))
   
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
   @ nLin,nPos PSAY TRB->XX_DOC
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_SERIE
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_GRPPROD
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_SGRPROD
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_PRODT
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY PAD(TRB->XX_DESCP,35)
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_QTDE PICTURE cPicQ
   nPos := PCOL()+nEsp
   
   @ nLin,nPos PSAY TRB->XX_VUNIT PICTURE cPicV
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_TOTAL PICTURE cPicV 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_DATAC 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_CC 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY PAD(TRB->XX_DESCC,15) 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_FORNEC 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_LOJA 
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY TRB->XX_FANTASI
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY PAD(TRB->XX_NFORNEC,15) 
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




Static Function  ValidPerg(cPerg)
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Grupo Produtos de:","Grupo Produtos de:","Grupo Produtos de:","mv_ch1","C",04,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SBM","S","",""})
AADD(aRegistros,{cPerg,"02","Grupo Produtos até:","Grupo Produtos até:","Grupo Produtos até:","mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SBM","S","",""})
AADD(aRegistros,{cPerg,"03","Sub Grupo Prod. de:","Sub Grupo Prod. de:","Sub Grupo Prod. de:","mv_ch3","C",04,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SZI","S","",""})
AADD(aRegistros,{cPerg,"04","Sub Grupo Prod. até:","Sub Grupo Prod. até:","Sub Grupo Prod. até:","mv_ch4","C",04,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SZI","S","",""})
AADD(aRegistros,{cPerg,"05","Produto de:","Produto de:","Produto de:","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SB1","S","",""})
AADD(aRegistros,{cPerg,"06","Produto até:","Produto até:","Produto até:","mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SB1","S","",""})
AADD(aRegistros,{cPerg,"07","Data da Compra de:"  ,"Data da Compra de:" ,"Data da Compra de:" ,"mv_ch7","D",08,0,0,"G","NaoVazio()","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"08","Data da Compra até:"  ,"Data da Compra até:" ,"Data da Compra até:" ,"mv_ch8","D",08,0,0,"G","NaoVazio()","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"09","Fornecedor de:"  ,"Fornecedor de:" ,"Fornecedor de:" ,"mv_ch9","C",06,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","SA2","S","",""})
AADD(aRegistros,{cPerg,"10","Loja de:"  ,"Loja de" ,"Loja de" ,"mv_chA","C",02,0,0,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"11","Fornecedor até:"  ,"Fornecedor até:" ,"Fornecedor até:" ,"mv_chB","C",06,0,0,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","SA2","S","",""})
AADD(aRegistros,{cPerg,"12","Loja até:"  ,"Loja até:" ,"Loja até:" ,"mv_chC","C",02,0,0,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"13","Contrato de:"  ,"Contrato de:" ,"Contrato de:" ,"mv_chD","C",09,0,0,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"14","Contrato até:"  ,"Contrato até:" ,"Contrato até:" ,"mv_chE","C",09,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"15","Conta(prefixo):"  ,"Conta(prefixo):" ,"Conta(prefixo):" ,"mv_chf","C",12,0,0,"G","","mv_par15","","","","","","","","","","","","","","","","","","","","","","","","","CT1","S","",""})

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
