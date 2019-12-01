#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
 
                                       
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BKCOMR6  º Autor ³ Adilson do Prado          Data ³18/07/14º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório Pedidos de Compra - BK                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BKCOMR6()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cDesc3        := ""
Local nLin          := 80
Local lPula         := .F.
Local Cabec1        := ""
Local Cabec2        := ""
Local imprime       := .T.
Local aOrd          := {}
Local _nI           := 0
Local aDbf 		    := {},cArqTmp
Local aDbf2         := {},cArqTmp2
Local cMes          := ""
Local titulo        := "Pedidos de Compras"

Private cTitulo     := "Pedidos de Compras"
Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt        := ""
Private limite      := 220
Private tamanho     := "G"
Private nomeprog    := "BKCOMR6" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey    := 0
Private cPerg       := "BKCOMR6"
Private cbtxt        := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "BKCOMR6" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString     := "SC7"

PRIVATE	cPict       := "@E 99,999,999,999.99"
PRIVATE nPeriodo    := 1
PRIVATE nPlan       := 1
Private aHeader	    := {}
PRIVATE aTitulos,aCampos,aCabs,aCampos2,aCabs2,aPlans := {}
PRIVATE cPEDI  	:= ""
PRIVATE cPEDF  	:= ""
PRIVATE dDataI  	:= ""
PRIVATE dDataF  	:= ""
PRIVATE cFornI  	:= ""
PRIVATE cFornF  	:= ""
PRIVATE cContraI  	:= ""
PRIVATE cContraF  	:= ""


ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif
 

cPEDI  		:= mv_par01
cPEDF 	 	:= mv_par02
dDataI  	:= mv_par03
dDataF  	:= mv_par04
cFornI  	:= mv_par05
cFornF  	:= mv_par06
cContraI  	:= mv_par07
cContraF  	:= mv_par08


titulo   := "Pedidos de Compras - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
cTitulo  := titulo

aDbf    := {}
Aadd( aDbf, { 'XX_NFORNEC',	'C', 80,00 } ) 
Aadd( aDbf, { 'XX_CGC',		'C', 18,00 } ) 
Aadd( aDbf, { 'XX_PED',		'C', 06,00 } )
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
FOR _nI := 1 TO 10
	Aadd( aDbf, { 'XX_FOR'+STRZERO(_nI,2),'C', 254,00 } )
	Aadd( aDbf, { 'XX_UNIT'+STRZERO(_nI,2),'N', 16,02 } )
	Aadd( aDbf, { 'XX_TOTAL'+STRZERO(_nI,2),'N', 16,02 } )
NEXT


cArqTmp := CriaTrab( aDbf, .t. )
dbUseArea( .t.,NIL,cArqTmp,'TRB',.f.,.f. )

IndRegua("TRB",cArqTmp,"XX_PED",,,"Indexando Arquivo de Trabalho") 

aCabs   := {}
aCampos := {}
aTitulos:= {}

nomeprog := "BKCOMR6/"+TRIM(SUBSTR(cUsuario,7,15))

AADD(aTitulos,nomeprog+" - "+titulo)
 

AADD(aCampos,"TRB->XX_NFORNEC")
AADD(aCabs  ,"Razão Social")
AAdd(aHeader,{"Razão Social","XX_NFORNEC" ,"@!",80,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_CGC")
AADD(aCabs  ,"CNPJ")
AAdd(aHeader,{"CNPJ","XX_CGC" ,"@!",18,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_PED")
AADD(aCabs  ,"Pedido")
AAdd(aHeader,{"Pedido","XX_PED" ,"@!",6,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_EMISSAO")
AADD(aCabs  ,"Emissão")
AAdd(aHeader,{"Emissão","XX_EMISSAO" ,"",8,00,"","","D","TRB","R"})

AADD(aCampos,"TRB->XX_PRODT")
AADD(aCabs  ,"Produtos")
AAdd(aHeader,{"Produtos","XX_PRODT" ,"@!",15,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_DESCP")
AADD(aCabs  ,"Desc. Produtos")
AAdd(aHeader,{"Desc. Produtos","XX_DESCP" ,"@!",60,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_UM")
AADD(aCabs  ,"UM")
AAdd(aHeader,{"UM","XX_UM" ,"@!",03,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_QTDE")
AADD(aCabs  ,"Qtde")
AAdd(aHeader,{"Qtde","XX_QTDE" ,"@E 99999999.99",11,02,"","","N","TRB","R"})

AADD(aCampos,"TRB->XX_VUNIT")
AADD(aCabs  ,"Valor Unitário")
AAdd(aHeader,{"Valor Unitário","XX_VUNIT" ,"@E 999,999,999.99",14,02,"","","N","TRB","R"})

AADD(aCampos,"TRB->XX_TOTAL")
AADD(aCabs  ,"Valor Total")
AAdd(aHeader,{"Valor Total","XX_TOTAL" ,"@E 999,999,999.99",14,02,"","","N","TRB","R"})

AADD(aCampos,"TRB->XX_CC")
AADD(aCabs  ,"Contrato")
AAdd(aHeader,{"Contrato","XX_CC" ,"@!",09,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_DESCC")
AADD(aCabs  ,"Descrição Contrato")
AAdd(aHeader,{"Descrição Contrato","XX_DESCC" ,"@!",40,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_LIB")
AADD(aCabs  ,"Liberado")
AAdd(aHeader,{"Liberado","XX_LIB" ,"@!",5,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_ENTR")
AADD(aCabs  ,"Entregue")
AAdd(aHeader,{"Entregue","XX_ENTR" ,"@!",15,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_QENTR")
AADD(aCabs  ,"Qtde Entregue")
AAdd(aHeader,{"Qtde Entregue","XX_QENTR" ,"@E 99999999.99",11,02,"","","N","TRB","R"})

AADD(aCampos,"TRB->XX_XXURGEN")
AADD(aCabs  ,"Urgente")
AAdd(aHeader,{"Urgente","XX_XXURGEN" ,"@!",03,00,"","","C","TRB","R"})

FOR _nI := 1 TO 10
	AADD(aCampos,"TRB->XX_FOR"+STRZERO(_nI,2))
	AADD(aCabs  ,"Cotação Empresa "+STRZERO(_nI,2))
	AAdd(aHeader,{"Cotação Empresa "+STRZERO(_nI,2),"XX_FOR"+STRZERO(_nI,2) ,"@!",10,0,"","","C","TRB","R"})  

	AADD(aCampos,"TRB->XX_UNIT"+STRZERO(_nI,2))
	AADD(aCabs  ,"Valor Unit. "+STRZERO(_nI,2))
	AAdd(aHeader,{"Valor Unit. "+STRZERO(_nI,2),"XX_UNIT"+STRZERO(_nI,2) ,"@E 999,999,999.99",14,02,"","","N","TRB","R"})

	AADD(aCampos,"TRB->XX_TOTAL"+STRZERO(_nI,2))
	AADD(aCabs  ,"Valor Total "+STRZERO(_nI,2))
	AAdd(aHeader,{"Valor Total "+STRZERO(_nI,2),"XX_TOTAL"+STRZERO(_nI,2) ,"@E 999,999,999.99",14,02,"","","N","TRB","R"})	
NEXT



Processa( {|| ProcBKCOMR6() })

Processa( {|| MBrwBKCOMR6() })


TRB->(Dbclosearea())

FErase(cArqTmp+GetDBExtension())
FErase(cArqTmp+OrdBagExt())
 
Return


Static Function MBrwBKCOMR6()
Local 	cAlias 		:= "TRB"
Local 	aCores 		:= {}

Private cCadastro	:= "Relatório de Pedidos de Compras"
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

AADD(aRotina,{"Exp. Excel"	,"U_CBKCOMR6",0,6})
AADD(aRotina,{"Imprimir"    ,"U_RBKCOMR6",0,7})
AADD(aRotina,{"Parametros"	,"U_PBKCOMR6",0,8})

dbSelectArea(cAlias)
dbSetOrder(1)
	
DEFINE MSDIALOG _oDlgSint ;
TITLE cCadastro ;
From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
_oGetDbSint := MsGetDb():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], 2, "AllwaysTrue()", "AllwaysTrue()",,,,,,"AllwaysTrue()","TRB")
	
aadd(aButton , { "BMPTABLE" , { || U_CBKCOMR6(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Gera Planilha Excel" } )
aadd(aButton , { "BMPTABLE" , { || U_RBKCOMR6(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Imprimir" } )
aadd(aButton , { "BMPTABLE" , { || U_PBKCOMR6(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Parametros" } )
	
ACTIVATE MSDIALOG _oDlgSint ON INIT EnchoiceBar(_oDlgSint,{|| _oDlgSint:End()}, {||_oDlgSint:End()},, aButton)

Return Nil



User FUNCTION PBKCOMR6()

ValidPerg(cPerg)
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

titulo   := "Pedidos de Compras - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
cTitulo  := titulo

Processa( {|| ProcBKCOMR6() })

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
User FUNCTION CBKCOMR6()
Local aQuebra := {}
Local aPlans  := {}

//Processa( {|| U_GeraCSV("TRB",TRIM(cPerg),aTitulos,aCampos,aCabs,"","",aQuebra,.F.)})

AADD(aPlans,{"TRB",TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
MsAguarde({|| U_GeraXml(aPlans,cTitulo,TRIM(cPerg),.F.)},"Aguarde","Gerando planilha...",.F.)

Return 



Static Function ProcBKCOMR6
Local cQuery := ""
Local nReg := 0

LimpaBrw("TRB")


cQuery := "SELECT C7_FORNECE,C7_LOJA,C7_NUM,C7_NUMCOT,C7_ITEM,C7_XXURGEN,C7_EMISSAO,C7_PRODUTO,SB1.B1_DESC,C7_UM,C7_QUANT,C7_QUJE,C7_PRECO,C7_TOTAL,C7_CC,"
cQuery += " C7_CONAPRO,CTT.CTT_DESC01, SA2.A2_NREDUZ, SA2.A2_NOME,SA2.A2_CGC"
cQuery += " FROM "+RETSQLNAME("SC7")+" SC7"
cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+" SB1 ON SB1.B1_FILIAL='" +xFilial("SB1")+"' AND SC7.C7_PRODUTO=SB1.B1_COD AND SB1.D_E_L_E_T_=''" 
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON CTT.CTT_FILIAL='"+xFilial("CTT")+"' AND SC7.C7_CC=CTT.CTT_CUSTO AND CTT.D_E_L_E_T_=''" 
cQuery += " LEFT JOIN "+RETSQLNAME("SA2")+" SA2 ON SA2.A2_FILIAL='" +xFilial("SA2")+"' AND SC7.C7_FORNECE=SA2.A2_COD AND SC7.C7_LOJA=SA2.A2_LOJA AND SA2.D_E_L_E_T_=''" 
 
cQuery += " WHERE SC7.D_E_L_E_T_='' AND SC7.C7_EMISSAO>='"+DTOS(dDataI)+"' AND SC7.C7_EMISSAO<='"+DTOS(dDataF)+"'
cQuery += " AND SC7.C7_NUM >='"+ALLTRIM(cPEDI)+"' AND SC7.C7_NUM <='"+ALLTRIM(cPEDF)+"'" 

cQuery += " AND SC7.C7_FORNECE >='"+ALLTRIM(cFornI)+"' AND SC7.C7_FORNECE <='"+ALLTRIM(cFornF)+"'" 
cQuery += " AND SC7.C7_CC >='"+ALLTRIM(cContraI)+"' AND SC7.C7_CC <='"+ALLTRIM(cContraF)+"'"

 
TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","C7_EMISSAO","D",8,0)


ProcRegua(QTMP->(LASTREC()))

nReg := 0

dbSelectArea("QTMP")
QTMP->(dbGoTop())
DO WHILE QTMP->(!EOF())
    nReg++
	IncProc("Consultando banco de dados...")
	
	aITx_ := {}
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
	
	Reclock("TRB",.T.)
	TRB->XX_NFORNEC := QTMP->A2_NOME
	TRB->XX_CGC     := QTMP->A2_CGC
	TRB->XX_PED 	:= QTMP->C7_NUM
	TRB->XX_PRODT 	:= QTMP->C7_PRODUTO
	TRB->XX_DESCP 	:= QTMP->B1_DESC
	TRB->XX_UM 		:= QTMP->C7_UM
	TRB->XX_QTDE 	:= QTMP->C7_QUANT
	TRB->XX_VUNIT 	:= QTMP->C7_PRECO
	TRB->XX_TOTAL 	:= QTMP->C7_TOTAL
	TRB->XX_EMISSAO	:= QTMP->C7_EMISSAO
	TRB->XX_CC 		:= QTMP->C7_CC
	TRB->XX_DESCC 	:= QTMP->CTT_DESC01
	TRB->XX_LIB 	:= IIF(QTMP->C7_CONAPRO="L","Sim","Não")
	TRB->XX_ENTR 	:= IIF(QTMP->C7_QUANT==QTMP->C7_QUJE,"Total",IIF(QTMP->C7_QUJE>0,"Parcial","Não Entregue"))
	TRB->XX_QENTR	:= QTMP->C7_QUJE
	TRB->XX_XXURGEN	:= IIF(QTMP->C7_XXURGEN=="S","Sim","Não")

    naITx_ := 0
    IF LEN(aITx_) > 10
    	naITx_ := 10
    ELSE
    	naITx_ := LEN(aITx_)
	ENDIF
	cCampo  := ""    
	For Ix_ := 1 TO naITx_
		cCampo  := "TRB->XX_FOR"+STRZERO(Ix_,2)
		&cCampo	:= aITx_[Ix_,1]
		cCampo  := "TRB->XX_UNIT"+STRZERO(Ix_,2)
		&cCampo	:= aITx_[Ix_,2]
		cCampo  := "TRB->XX_TOTAL"+STRZERO(Ix_,2)
		&cCampo	:= aITx_[Ix_,3]
	NEXT


 	TRB->(Msunlock())
	dbSelectArea("QTMP")
	QTMP->(dbSkip())
ENDDO


IF nReg < 1
	Reclock("TRB",.T.)
	TRB->XX_PED 	:= "Null"
 	TRB->(Msunlock())
ENDIF

TRB->(dbGoTop())

QTMP->(dbCloseArea())

Return



User Function RBKCOMR6()
Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cDesc3        := ""
Local cPict         := ""
Local nLin          := 80
Local lPula         := .F.
Local Cabec1        := ""
Local Cabec2        := ""
Local imprime       := .T.
Local aOrd          := {}
Local titulo        := ""

titulo := "Pedidos de Compras - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	wnrel := SetPrint(cString,"BKCOMR6",cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.) 
	
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
Local nOrdem

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

nomeprog := "BKCOMR6/"+TRIM(SUBSTR(cUsuario,7,15))
   
Dbselectarea("TRB")
Dbgotop()
SetRegua(RecCount())

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

Local aArea      := GetArea()
Local aRegistros := {}
cPerg := "BKCOMR6"
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Pedido de:"     ,"Pedido de:"     ,"Pedido de:"     ,"mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SC7","S","",""})
AADD(aRegistros,{cPerg,"02","Pedido até:"    ,"Pedido até:"    ,"Pedido até:"    ,"mv_ch2","C",06,0,0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SC7","S","",""})
AADD(aRegistros,{cPerg,"03","Período de:"    ,"Período de:"    ,"Período de:"    ,"mv_ch3","D",08,0,0,"G","NaoVazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"04","Período de até:","Período de até:","Período de até:","mv_ch4","D",08,0,0,"G","NaoVazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"05","Fornecedor de:" ,"Fornecedor de:" ,"Fornecedor de:" ,"mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","SA2","S","",""})
AADD(aRegistros,{cPerg,"06","Fornecedor até:","Fornecedor até:","Fornecedor até:","mv_ch6","C",06,0,0,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SA2","S","",""})
AADD(aRegistros,{cPerg,"07","Contrato de:"   ,"Contrato de:"   ,"Contrato de:"   ,"mv_ch7","C",09,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"08","Contrato até:"  ,"Contrato até:"  ,"Contrato até:"  ,"mv_ch8","C",09,0,0,"G","NaoVazio()","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})

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

