#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINA23
BK - Rotina para selecionar titulos e gerar baixas - Retenção Contratual
Copiado do BKFINA16.PRW

@Return
@author Marcos Bispo Abrahão
@since 27/08/2019
@version P11
/*/
//-------------------------------------------------------------------

User Function BKFINA23()

Local lOk     := .F.
Local cTitulo := "Selecionar Títulos e Gerar Baixa - Retenção Contratual - "+ALLTRIM(SM0->M0_NOME)
Local nLin1   := 10
Local nLin2   := 10

PRIVATE oDlg
PRIVATE oListId
PRIVATE oPanelLeft
PRIVATE oFatura

PRIVATE aButtons:= {}
PRIVATE aTitGer := {}
PRIVATE cPict   := "@E 999,999,999.99"
PRIVATE cFatura	:= SPACE(TamSX3("E1_NUM")[1])
PRIVATE cPrefix	:= SPACE(TamSX3("E1_PREFIXO")[1])
PRIVATE cParc	:= SPACE(TamSX3("E1_PARCELA")[1])
PRIVATE cTipo	:= SPACE(TamSX3("E1_TIPO")[1])
PRIVATE cCli	:= SPACE(TamSX3("E1_CLIENTE")[1])
PRIVATE cLoja	:= SPACE(TamSX3("E1_LOJA")[1])
PRIVATE cNCli   := SPACE(TamSX3("A1_NOME")[1])
PRIVATE dVencto := CTOD("") 

PRIVATE nVlrTit := 0
PRIVATE nVlrImp	:= 0
PRIVATE nVlrLi  := 0
PRIVATE nDesc   := 0
PRIVATE nMulta  := 0
PRIVATE nReceb  := 0
PRIVATE nTotBK	:= 0
PRIVATE nSaldo	:= 0
PRIVATE lCancelou := .F.

// BANCO: BAIXA
private cBanco   := SPACE(TamSX3("A6_COD")[1])
private cAgencia := SPACE(TamSX3("A6_AGENCIA")[1])
private cConta   := SPACE(TamSX3("A6_NUMCON")[1])
private dDtBaixa := dDataBase
private cHist    := PAD("VALOR RECEBIDO S/ TITULO",TamSX3("E5_HISTOR")[1])
private nValor   := 0

// BANCO: BAIXA RETENÇÃO CONTRATUAL
private cRBanco   := PAD("999",LEN(cBanco))
private cRAgencia := PAD("00001",LEN(cAgencia))
private cRConta   := PAD("99999",LEN(cConta))
private cRHist    := PAD("RETENCAO CONTRATUAL",TamSX3("E5_HISTOR")[1])
private nRValor   := 0 //SE1->E1_XXVRETC

// BANCO: BAIXA DIFERENÇA ISS
private cIBanco   := PAD("CX1",LEN(cBanco))
private cIAgencia := PAD("00001",LEN(cAgencia))
private cIConta   := PAD("0000000001",LEN(cConta))
private cIHist    := PAD("DIFERENCA ISS",TamSX3("E5_HISTOR")[1])
private nIValor   := 0

// BANCO: BAIXA JUROS ANTECIPADOS
private cJBanco   := PAD("CX1",LEN(cBanco))
private cJAgencia := PAD("00001",LEN(cAgencia))
private cJConta   := PAD("0000000001",LEN(cConta))
private cJHist    := PAD("DESCONTO JUROS ANTECIPADOS",TamSX3("E5_HISTOR")[1])
private nJValor   := 0


DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 600,950 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 520,525
oPanelLeft:Align := CONTROL_ALIGN_LEFT

nLin1 := 10
nLin2 := 20

@ nLin1, 010 SAY "Nr.Doc."  SIZE 49, 7 OF oPanelLeft PIXEL 
@ nLin2, 010 MSGET oFatura VAR cFatura Picture "@!"  When .T. SIZE 50, 11 OF oPanelLeft PIXEL F3 "SE1_2" HASBUTTON 

@ nLin1, 070 SAY "Serie" SIZE 21, 7 OF oPanelLeft PIXEL
@ nLin2, 070 MSGET cPrefix Picture "@!" When .T. SIZE 10, 11 OF oPanelLeft PIXEL  VALID BuscaSE1()

@ nLin1, 100 SAY "Parcela" SIZE 21, 7 OF oPanelLeft PIXEL
@ nLin2, 100 MSGET cParc Picture "@!" When .F. SIZE 10, 11 OF oPanelLeft PIXEL 

@ nLin1, 125 SAY "Tipo" SIZE 21, 7 OF oPanelLeft PIXEL
@ nLin2, 125 MSGET cTipo Picture "@!" When .F. SIZE 10, 11 OF oPanelLeft PIXEL 

@ nLin1, 160 SAY "Cliente" SIZE 35, 7 OF oPanelLeft PIXEL 
@ nLin2, 160 MSGET cCli	Picture "@!"  When .F.  SIZE 40, 11 OF oPanelLeft PIXEL

@ nLin1, 220 SAY "Loja" SIZE 30, 7 OF oPanelLeft PIXEL 
@ nLin2, 220 MSGET cLoja	Picture "@!"  When .F.  SIZE 21, 11 OF oPanelLeft PIXEL

@ nLin1, 250 SAY "Nome Cliente"  SIZE 35, 7 OF oPanelLeft PIXEL 
@ nLin2, 250 MSGET cNCli	Picture "@!"  When .F.  SIZE 140, 11 OF oPanelLeft PIXEL

@ nLin1, 400 SAY "Vencimento" SIZE 35, 7 OF oPanelLeft PIXEL
@ nLin2, 400 MSGET dVencto  When .F.	SIZE 50, 11 OF oPanelLeft PIXEL

nLin1 += 25
nLin2 := nLin1+10


@ nLin1, 010 SAY "Banco Ret. Ctr."  SIZE 50, 7 OF oPanelLeft PIXEL  
@ nLin2, 010 MSGET cRBanco Picture "@!"  When .T. SIZE 50, 11 OF oPanelLeft PIXEL F3 "SA6" VALID (NaoVazio(cRBanco)) HASBUTTON
                        
@ nLin1, 070 SAY "Agência Ret. Ctr." SIZE 50, 7 OF oPanelLeft PIXEL
@ nLin2, 070 MSGET cRAgencia Picture "@!" When .T. SIZE 30, 11 OF oPanelLeft PIXEL VALID (NaoVazio(cRAgencia))

@ nLin1, 120 SAY "Conta Ret. Ctr." SIZE 50, 7 OF oPanelLeft PIXEL
@ nLin2, 120 MSGET cRConta Picture "@!" When .T. SIZE 60, 11 OF oPanelLeft PIXEL VALID (NaoVazio(cRConta))

@ nLin1, 190 SAY "Histórico" SIZE 50, 7 OF oPanelLeft PIXEL 
@ nLin2, 190 MSGET cRHist	Picture "@!"  When .T.  SIZE 200, 11 OF oPanelLeft PIXEL VALID (NaoVazio(cRHist))

@ nLin1, 400 SAY "Valor Ret. Ctr." SIZE 35, 7 OF oPanelLeft PIXEL
@ nLin2, 400 MSGET nRValor Picture cPict When .T. SIZE 50, 11 OF oPanelLeft PIXEL VALID(POSITIVO(nRValor),SOMATAB())

nLin1 += 25
nLin2 := nLin1+10

@ nLin1, 010 SAY "Banco Juros"  SIZE 50, 7 OF oPanelLeft PIXEL 
@ nLin2, 010 MSGET cJBanco Picture "@!"  When .T. SIZE 50, 11 OF oPanelLeft PIXEL F3 "SA6" VALID (NaoVazio(cJBanco)) HASBUTTON
                        
@ nLin1, 070 SAY "Agência Juros" SIZE 50, 7 OF oPanelLeft PIXEL
@ nLin2, 070 MSGET cJAgencia Picture "@!" When .T. SIZE 30, 11 OF oPanelLeft PIXEL VALID NaoVazio(cJAgencia)

@ nLin1, 120 SAY "Conta Juros" SIZE 50, 7 OF oPanelLeft PIXEL
@ nLin2, 120 MSGET cJConta Picture "@!" When .T. SIZE 60, 11 OF oPanelLeft PIXEL VALID NaoVazio(cJConta)

@ nLin1, 190 SAY "Histórico" SIZE 50, 7 OF oPanelLeft PIXEL 
@ nLin2, 190 MSGET cJHist	Picture "@!"  When .T.  SIZE 200, 11 OF oPanelLeft PIXEL VALID (NaoVazio(cJHist))

@ nLin1, 400 SAY "Valor Juros Ant." SIZE 35, 7 OF oPanelLeft PIXEL
@ nLin2, 400 MSGET nJValor Picture cPict When .T. SIZE 50, 11 OF oPanelLeft PIXEL VALID(POSITIVO(nJValor),SOMATAB())

nLin1 += 25
nLin2 := nLin1+10

@ nLin1, 010 SAY "Banco Dif. ISS"  SIZE 50, 7 OF oPanelLeft PIXEL 
@ nLin2, 010 MSGET cIBanco Picture "@!"  When .T. SIZE 50, 11 OF oPanelLeft PIXEL F3 "SA6" VALID (NaoVazio(cIBanco)) HASBUTTON
                        
@ nLin1, 070 SAY "Agência Dif. ISS" SIZE 50, 7 OF oPanelLeft PIXEL
@ nLin2, 070 MSGET cIAgencia Picture "@!" When .T. SIZE 30, 11 OF oPanelLeft PIXEL VALID (NaoVazio(cIAgencia))

@ nLin1, 120 SAY "Conta Dif. ISS" SIZE 50, 7 OF oPanelLeft PIXEL
@ nLin2, 120 MSGET cIConta Picture "@!" When .T. SIZE 60, 11 OF oPanelLeft PIXEL VALID (NaoVazio(cIConta))

@ nLin1, 190 SAY "Histórico" SIZE 50, 7 OF oPanelLeft PIXEL 
@ nLin2, 190 MSGET cIHist	Picture "@!"  When .F.  SIZE 200, 11 OF oPanelLeft PIXEL VALID (NaoVazio(cIHist))

@ nLin1, 400 SAY "Valor Dif. ISS" SIZE 35, 7 OF oPanelLeft PIXEL
@ nLin2, 400 MSGET nIValor Picture cPict When .T. SIZE 50, 11 OF oPanelLeft PIXEL VALID(POSITIVO(nIValor),SOMATAB())

nLin1 += 25
nLin2 := nLin1+10

@ nLin1, 010 SAY "Banco Baixa"  SIZE 50, 7 OF oPanelLeft PIXEL 
@ nLin2, 010 MSGET cBanco Picture "@!"  When .T. SIZE 50, 11 OF oPanelLeft PIXEL F3 "SA6" VALID (NaoVazio(cBanco)) HASBUTTON
                        
@ nLin1, 070 SAY "Agência Baixa" SIZE 50, 7 OF oPanelLeft PIXEL
@ nLin2, 070 MSGET cAgencia Picture "@!" When .T. SIZE 30, 11 OF oPanelLeft PIXEL VALID NaoVazio(cAgencia)

@ nLin1, 120 SAY "Conta Baixa" SIZE 50, 7 OF oPanelLeft PIXEL
@ nLin2, 120 MSGET cConta Picture "@!" When .T. SIZE 60, 11 OF oPanelLeft PIXEL VALID NaoVazio(cConta)

@ nLin1, 190 SAY "Histórico" SIZE 50, 7 OF oPanelLeft PIXEL 
@ nLin2, 190 MSGET cHist	Picture "@!"  When .T.  SIZE 200, 11 OF oPanelLeft PIXEL

@ nLin1, 400 SAY "Valor Baixa" SIZE 35, 7 OF oPanelLeft PIXEL
@ nLin2, 400 MSGET nReceb Picture cPict When .F. SIZE 50, 11 OF oPanelLeft PIXEL 

nLin1 += 25
nLin2 := nLin1+10

@ nLin1, 010 SAY "Vlr. Título" SIZE 35, 7 OF oPanelLeft PIXEL
@ nLin2, 010 MSGET nVlrTit Picture cPict When .F. SIZE 50, 11 OF oPanelLeft PIXEL

@ nLin1, 070 SAY "Vlr.Impostos" SIZE 45, 7 OF oPanelLeft PIXEL
@ nLin2, 070 MSGET nVlrImp Picture cPict When .F. SIZE 50, 11 OF oPanelLeft PIXEL

@ nLin1, 130 SAY "Vlr. Líquido" SIZE 35, 7 OF oPanelLeft PIXEL
@ nLin2, 130 MSGET nVlrLi Picture cPict When .F. SIZE 50, 11 OF oPanelLeft PIXEL

@ nLin1, 190 SAY "- Desconto " SIZE 35, 7 OF oPanelLeft PIXEL
@ nLin2, 190 MSGET nDesc Picture cPict When .T. SIZE 50, 11 OF oPanelLeft PIXEL VALID(POSITIVO(nDesc),SOMATAB())

@ nLin1, 250 SAY "+ Multa " SIZE 35, 7 OF oPanelLeft PIXEL
@ nLin2, 250 MSGET nMulta Picture cPict When .T. SIZE 50, 11 OF oPanelLeft PIXEL VALID(POSITIVO(nMulta),SOMATAB())

//@ nLin1, 310 SAY "A Receber" SIZE 35, 7 OF oPanelLeft PIXEL
//@ nLin2, 310 MSGET nReceb Picture cPict When .F. SIZE 50, 11 OF oPanelLeft PIXEL

@ nLin1, 310 SAY "Saldo" SIZE 35, 7 OF oPanelLeft PIXEL
@ nLin2, 310 MSGET nSaldo Picture cPict When .F. SIZE 50, 11 OF oPanelLeft PIXEL

@ nLin2, 400 Button "Incluir" Size 050,013 OF oPanelLeft Pixel Action (InclTab())

nLin1 += 30
@ nLin1, 005 LISTBOX oListID FIELDS HEADER "N°Titulo","Prefixo","Parcela","Tipo","Natureza","Cliente","Loja","NomeCli","Emissao","VenctoReal",;
"Vlr.Titulo","Vlr.Impostos","Vlr.Liquido","Ret. Contratual","- Desconto ","+ Multa ","A Receber","Banco Baixa","Agencia Baixa","Conta Baixa","Banco Ret.","Agencia Ret.","Conta Ret.","Histórico" SIZE 470,80 OF oPanelLeft PIXEL 

aTitGer := {}

AADD(aTitGer,{"","","","","","","","","","",0,0,0,0,0,0,0,"","","","","","",""})

oListID:SetArray(aTitGer)
oListID:bLine := {|| {   aTitGer[oListId:nAt][1],;
                         aTitGer[oListId:nAt][2],;
                         aTitGer[oListId:nAt][3],;
                         aTitGer[oListId:nAt][4],;
                         aTitGer[oListId:nAt][5],;
                         aTitGer[oListId:nAt][6],;
                         aTitGer[oListId:nAt][7],;
                         aTitGer[oListId:nAt][8],;
                         aTitGer[oListId:nAt][9],;
                         aTitGer[oListId:nAt][10],;
                         TRANSFORM(aTitGer[oListId:nAt][11],cPict ),;
                         TRANSFORM(aTitGer[oListId:nAt][12],cPict ),;
                         TRANSFORM(aTitGer[oListId:nAt][13],cPict ),;
                         TRANSFORM(aTitGer[oListId:nAt][14],cPict ),;
                         TRANSFORM(aTitGer[oListId:nAt][15],cPict ),;
                         TRANSFORM(aTitGer[oListId:nAt][16],cPict ),;
                         TRANSFORM(aTitGer[oListId:nAt][17],cPict ),; 
                         aTitGer[oListId:nAt][18],;
                         aTitGer[oListId:nAt][19],;                         
                         aTitGer[oListId:nAt][20],;                         
                         aTitGer[oListId:nAt][21],;                         
                         aTitGer[oListId:nAt][22],;                         
                         aTitGer[oListId:nAt][23],;
                         aTitGer[oListId:nAt][24]}}

oListID:bLDblClick := {|| DeleTab(oListId:nAt), oListID:DrawSelect()} 


@ 255, 010 SAY "Total para Baixa: "+TRANSFORM(nTotBK,cPICT )  SIZE 200, 7 OF oPanelLeft PIXEL


ACTIVATE MSDIALOG oDlg CENTERED VALID(ValidaSE1()) ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| lOk:=.F., oDlg:End()}, , aButtons) 

If ( lOk )
	lOk := .F.
	IF  LEN(aTitGer) > 0
		IF TRIM(aTitGer[1,1]) <> ""
			IF msgyesno('Confirma Baixa dos Titulos Selecionados?')
				MsAguarde({|| BAIXATAB()},"Aguarde","Efetuando baixas...",.F.)
			ENDIF
		ENDIF   
	ENDIF
Endif

Return


STATIC FUNCTION ValidaSE1()
LOCAL lRET := .T. 

IF !EMPTY(cFatura)
	IF  LEN(aTitGer) > 0
		IF TRIM(aTitGer[1,1]) <> ""
			nScan:= 0
			nScan:= aScan(aTitGer,{|x| x[1]==cFatura })
    		IF nScan == 0
				IF !MsgYesNo("Titulo: '"+cFatura+"' não esta selecionado para baixa. Continuar baixa?")
					lRET := .F.
					RETURN lRET
				ENDIF
			ENDIF
		ELSE
			IF !MsgYesNo("Titulo: '"+cFatura+"' não selecionado. Sair da rotina?")
				lRET := .F.
				RETURN lRET
			ENDIF
		ENDIF
	ENDIF 
ENDIF


RETURN lRET


Static Function BuscaSE1()
Local lRet := .T.
Local cKey := ""

IF EMPTY(cPrefix)
	cPrefix := "1  "
ENDIF
    
IF EMPTY(cParc)
	cParc := "  "
ENDIF 

IF EMPTY(cTipo)
	cTipo := "NF "
ENDIF

cKey := xFilial ("SE1") + cPrefix  + cFatura + cParc + cTipo

DbSelectArea ("SE1")
DbSetOrder(1)
IF DbSeek (cKey,.F.)
   	IF SE1->E1_VALOR == SE1->E1_SALDO
		cCli	:= SE1->E1_CLIENTE
		cLoja	:= SE1->E1_LOJA
		cNCli   := Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_NOME")
		dVencto := SE1->E1_VENCREA 
		nVlrTit := SE1->E1_VALOR
		nRValor := SE1->E1_XXVRETC
		dbSelectArea ("SF2")
		dbSetOrder (1)
		IF dbSeek (xFilial("SF2")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA, .F.)
			nVlrImp 	:= SF2->F2_VALIRRF + SF2->F2_VALINSS + SF2->F2_VALPIS + SF2->F2_VALCOFI + SF2->F2_VALCSLL + IIF(SF2->F2_RECISS = '1',SF2->F2_VALISS,0) + SF2->F2_XXVFUMD
			nVlrLi 		:= SF2->F2_VALFAT - nVlrImp
		ENDIF 
		nDesc   := 0
		nMulta  := 0
		nReceb  := nVlrLi + nMulta - nDesc - nRValor
  	ELSE
  		if SE1->E1_SALDO > 0
			MSGSTOP("Titulo Baixado parcial, favor utilizar rotina padrao de sistema!!")
		ELSE
			MSGSTOP("Titulo ja foi Baixado !!")
		ENDIF
		//LIMPTAB()
		oFatura:SetFocus()
		//lRet := .F.
 	ENDIF
ELSE
	MSGSTOP("Titulo não Encontrado")
	//LIMPTAB()
	//lRet := .F.
	oFatura:SetFocus()
ENDIF

Return lRet 




STATIC FUNCTION SOMATAB()

nReceb  := 0
If nJValor > 0
	nReceb  := nVlrLi + nMulta - nDesc - nRValor - nJValor - nIValor - 1
	nSaldo  := 1
Else
	nReceb  := nVlrLi + nMulta - nDesc - nRValor - nIValor
	nSaldo  := 0
EndIf
		
RETURN NIL


STATIC FUNCTION LIMPTAB()

cFatura	:= SPACE(9)
cPrefix	:= SPACE(3)
cParc	:= SPACE(2)
cTipo	:= SPACE(3)
cCli	:= SPACE(6)
cLoja	:= SPACE(2)
cNCli   := SPACE(40)
dVencto := CTOD("") 
nVlrTit := 0
nVlrImp	:= 0
nVlrLi  := 0
nDesc   := 0
nMulta  := 0
nReceb  := 0
nRvalor := 0
nIvalor := 0
nJvalor := 0
nSaldo	:= 0

// BAIXA
//cBanco  := space(3)
//cAgencia := space(5)
//cConta   := space(15)
dDtBaixa := dDataBase
cHist    := PAD("VALOR RECEBIDO S/ TITULO",TamSX3("E5_HISTOR")[1])

RETURN NIL


STATIC FUNCTION VALIDTAB()
LOCAL lRET := .T. 
Local nScan:= 0

cKey := xFilial ("SE1") + cPrefix  + cFatura + cParc + cTipo 
		
DbSelectArea ("SE1")
DbSetOrder (1)
IF !DbSeek(cKey,.F.)
	MSGSTOP("Dados incorretos. Verifique!!")
	lRET := .F.
	RETURN lRET 
ENDIF

nScan:= 0
nScan:= aScan(aTitGer,{|x| x[1]==cFatura .AND. x[2]==cPrefix .AND. x[3]==cParc .AND. x[4]==cTipo })
IF nScan > 0
	MSGSTOP("Título / Doc já incluido. Verificar!")
	lRET := .F.
	RETURN lRET 
ENDIF

IF EMPTY(cBanco) .OR. EMPTY(cAgencia) .OR. EMPTY(cConta)
	MSGSTOP("Dados do Banco para baixa não informado. Verificar!")
	lRET := .F.
	RETURN lRET 
ENDIF

DbSelectArea("SA6")
SA6->(DbSetOrder(1))
IF SA6->(DbSeek(xFilial("SA6")+cBanco+cAgencia+cConta,.F.))
	IF SA6->A6_BLOCKED == '1'
		MSGSTOP("Banco informado para baixa bloqueada para movimentações. Verifique!")
		lRET := .F.
		RETURN lRET 
	ENDIF
ELSE
	MSGSTOP("Dados do Banco para baixa incorreto. Verifique!")
	lRET := .F.
	RETURN lRET 
ENDIF

IF nRValor > 0
	IF EMPTY(cRBanco) .OR. EMPTY(cRAgencia) .OR. EMPTY(cRConta)
		MSGSTOP("Dados do Banco para Baixa da Retenção Contratual não informados. Verificar!")
		lRET := .F.
		RETURN lRET 	
	ENDIF

	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	IF SA6->(DbSeek(xFilial("SA6")+cRBanco+cRAgencia+cRConta,.F.))
		IF SA6->A6_BLOCKED == '1'
			MSGSTOP("Banco informado para baixa de Retenção Contratual bloqueada para movimentações. Verifique!")
			lRET := .F.
			RETURN lRET 
		ENDIF
	ELSE
		MSGSTOP("Dados do Banco para baixa de Retenção Contratual incorretos. Verifique!")
		lRET := .F.
		RETURN lRET 
	ENDIF

ENDIF


IF nIValor > 0
	IF EMPTY(cIBanco) .OR. EMPTY(cIAgencia) .OR. EMPTY(cIConta)
		MSGSTOP("Dados do Banco para Baixa da Diferença de ISS não informados. Verificar!")
		lRET := .F.
		RETURN lRET 	
	ENDIF

	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	IF SA6->(DbSeek(xFilial("SA6")+cIBanco+cIAgencia+cIConta,.F.))
		IF SA6->A6_BLOCKED == '1'
			MSGSTOP("Banco informado para baixa da Diferença de ISS bloqueada para movimentações. Verifique!")
			lRET := .F.
			RETURN lRET 
		ENDIF
	ELSE
		MSGSTOP("Dados do Banco para baixa de Diferença de ISS incorretos. Verifique!")
		lRET := .F.
		RETURN lRET 
	ENDIF

ENDIF



IF nJValor > 0
	IF EMPTY(cJBanco) .OR. EMPTY(cJAgencia) .OR. EMPTY(cJConta)
		MSGSTOP("Dados do Banco para Baixa do Juros Antecipado não informados. Verificar!")
		lRET := .F.
		RETURN lRET 	
	ENDIF

	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	IF SA6->(DbSeek(xFilial("SA6")+cJBanco+cJAgencia+cJConta,.F.))
		IF SA6->A6_BLOCKED == '1'
			MSGSTOP("Banco informado para baixa do Juros Antecipado bloqueada para movimentações. Verifique!")
			lRET := .F.
			RETURN lRET 
		ENDIF
	ELSE
		MSGSTOP("Dados do Banco para baixa do Juros Antecipado incorretos. Verifique!")
		lRET := .F.
		RETURN lRET 
	ENDIF

ENDIF



RETURN lRET


Static Function InclTab()
Local aTitulo := {}

IF !VALIDTAB()
	RETURN NIL
ENDIF

IF aTitGer[1,1] == ""
	aTitGer := {}
ENDIF


//"N°Titulo","Prefixo","Parcela","Tipo","Natureza","Cliente","Loja","NomeCli","Emissao","VenctoReal",;
//"Vlr.Titulo","Vlr.Impostos","Vlr.Liquido","Vlr.C.Vinculada","- Desconto ","+ Multa ","A Receber","Banco Baixa","Agenica Baixa","Conta Baixa",;
//"Banco Vinc.","Agenica Vinc.","Conta Vinc." 

aTitulo := {}
AADD(aTitulo,SE1->E1_NUM)
AADD(aTitulo,SE1->E1_PREFIXO)
AADD(aTitulo,SE1->E1_PARCELA)
AADD(aTitulo,SE1->E1_TIPO)
AADD(aTitulo,SE1->E1_NATUREZ)
AADD(aTitulo,SE1->E1_CLIENTE)
AADD(aTitulo,SE1->E1_LOJA)
AADD(aTitulo,cNCli)
AADD(aTitulo,DTOC(SE1->E1_EMISSAO))
AADD(aTitulo,DTOC(SE1->E1_VENCREA))
AADD(aTitulo,SE1->E1_VALOR)
AADD(aTitulo,nVlrImp)
AADD(aTitulo,nVlrLi)
AADD(aTitulo,nRValor)
AADD(aTitulo,nDesc)
AADD(aTitulo,nMulta)
AADD(aTitulo,nReceb)
AADD(aTitulo,cBanco)
AADD(aTitulo,cAgencia)
AADD(aTitulo,cConta)
AADD(aTitulo,cHist)
AADD(aTitulo,cRBanco) // 22
AADD(aTitulo,cRAgencia)
AADD(aTitulo,cRConta)
AADD(aTitulo,cRHist)  // 25
AADD(aTitulo,nRValor)

AADD(aTitulo,cIBanco)  // 27
AADD(aTitulo,cIAgencia)
AADD(aTitulo,cIConta)
AADD(aTitulo,cIHist)
AADD(aTitulo,nIValor) // 31

AADD(aTitulo,cJBanco) // 32
AADD(aTitulo,cJAgencia)
AADD(aTitulo,cJConta)
AADD(aTitulo,cJHist)
AADD(aTitulo,nJValor)  // 36


AADD(aTitGer,aTitulo)

oListID:SetArray(aTitGer)
oListID:bLine := {|| {   aTitGer[oListId:nAt][1],;
   	                     aTitGer[oListId:nAt][2],;
       	                 aTitGer[oListId:nAt][3],;
           	             aTitGer[oListId:nAt][4],;
               	         aTitGer[oListId:nAt][5],;
                   	     aTitGer[oListId:nAt][6],;
                         aTitGer[oListId:nAt][7],;
   	                     aTitGer[oListId:nAt][8],;
       	                 aTitGer[oListId:nAt][9],;
           	             aTitGer[oListId:nAt][10],;
               	         TRANSFORM(aTitGer[oListId:nAt][11],cPict ),;
                   	     TRANSFORM(aTitGer[oListId:nAt][12],cPict ),;
                       	 TRANSFORM(aTitGer[oListId:nAt][13],cPict ),;
                         TRANSFORM(aTitGer[oListId:nAt][14],cPict ),;
   	                     TRANSFORM(aTitGer[oListId:nAt][15],cPict ),;
       	                 TRANSFORM(aTitGer[oListId:nAt][16],cPict ),;
           	             TRANSFORM(aTitGer[oListId:nAt][17],cPict ),; 
                         aTitGer[oListId:nAt][18],;
   	                     aTitGer[oListId:nAt][19],;                         
       	                 aTitGer[oListId:nAt][20],;                         
           	             aTitGer[oListId:nAt][21],;                         
               	         aTitGer[oListId:nAt][22],;                         
                         aTitGer[oListId:nAt][23],;
                         aTitGer[oListId:nAt][24]}}
oListID:Refresh()
nTotBK	+= nReceb
LIMPTAB()

Return nil


STATIC FUNCTION DeleTab(nItem)
LOCAL aItem := {}

IF nItem > 0 .AND. ALLTRIM(aTitGer[nItem,1]) <> ""
	IF MsgYesNo("Confirma a exclusão do Titulo: '"+aTitGer[nItem,1]+"' selecionado?")

		aItem := aClone(aTitGer)
        aTitGer := {}
        FOR _nx := 1 to LEN(aItem)
        	IF _nx <> nItem
        	   AADD(aTitGer,aItem[_nx])
        	ELSE
        		nTotBK	-= aItem[_nx,17]
        	ENDIF
        NEXT
        
        IF LEN(aTitGer) == 0 
			AADD(aTitGer,{"","","","","","","","","","",0,0,0,0,0,0,0,"","","","","","",""})
        ENDIF
         
		oListID:SetArray(aTitGer)
		oListID:bLine := {|| {   aTitGer[oListId:nAt][1],;
        		                 aTitGer[oListId:nAt][2],;
		                         aTitGer[oListId:nAt][3],;
        		                 aTitGer[oListId:nAt][4],;
                		         aTitGer[oListId:nAt][5],;
                        		 aTitGer[oListId:nAt][6],;
		                         aTitGer[oListId:nAt][7],;
        		                 aTitGer[oListId:nAt][8],;
                		         aTitGer[oListId:nAt][9],;
                        		 aTitGer[oListId:nAt][10],;
		                         TRANSFORM(aTitGer[oListId:nAt][11],cPict ),;
        		                 TRANSFORM(aTitGer[oListId:nAt][12],cPict ),;
                		         TRANSFORM(aTitGer[oListId:nAt][13],cPict ),;
                        		 TRANSFORM(aTitGer[oListId:nAt][14],cPict ),;
		                         TRANSFORM(aTitGer[oListId:nAt][15],cPict ),;
        		                 TRANSFORM(aTitGer[oListId:nAt][16],cPict ),;
                		         TRANSFORM(aTitGer[oListId:nAt][17],cPict ),; 
                        		 aTitGer[oListId:nAt][18],;
		                         aTitGer[oListId:nAt][19],;                         
        		                 aTitGer[oListId:nAt][20],;                         
                		         aTitGer[oListId:nAt][21],;                         
		                         aTitGer[oListId:nAt][22],;                         
        		                 aTitGer[oListId:nAt][23],;
        		                 aTitGer[oListId:nAt][24]}}

		oListID:Refresh()
	ENDIF
ENDIF

RETURN NIL


STATIC FUNCTION BAIXATAB()
Local nI := 0
Local aBaixa:= {}
Local lOK := .T.
Local cCrLf := Chr(13) + Chr(10)
Local cLOG  := ""

Private dDtBaixa   := dDataBase
Private MsErroAuto := .F.


For nI:=1 TO LEN(aTitGer)

	// Baixa da Retenção Contratual
	IF aTitGer[nI,14] > 0 

    	//Posiciona no titulo
		DbSelectArea("SE1")
		SE1->(DbSetOrder(1))
		SE1->(DbSeek(xFilial("SE1")+aTitGer[nI,2]+aTitGer[nI,1]+aTitGer[nI,3]+aTitGer[nI,4],.T.))

		cQuery 	:= ""
		cQuery 	:= " DELETE from "+RETSQLNAME("SE8")+"  where D_E_L_E_T_=''"
		cQuery 	+= " AND E8_MOEDA=' 1'AND E8_FILIAL='"+xFILIAL("SE8")+"' AND E8_DTSALAT='"+DTOS(dDtBaixa)+"'" 
		cQuery 	+= " AND E8_BANCO='"+aTitGer[nI,21]+"' AND E8_AGENCIA='"+aTitGer[nI,22]+"' AND E8_CONTA='"+aTitGer[nI,23]+"'"
	
		TcSqlExec(cQuery)

		aBaixa := {}
		// grava baixa da Retenção Contratual
		AADD( aBaixa, { "E1_PREFIXO" 	, aTitGer[nI,2]		, Nil } )	// 01
		AADD( aBaixa, { "E1_NUM"     	, aTitGer[nI,1]	 	, Nil } )	// 02
		AADD( aBaixa, { "E1_PARCELA" 	, aTitGer[nI,3]		, Nil } )	// 03
		AADD( aBaixa, { "E1_TIPO"    	, aTitGer[nI,4]		, Nil } )	// 04
		AADD( aBaixa, { "E1_CLIENTE"	, aTitGer[nI,5]		, Nil } )	// 05
		AADD( aBaixa, { "E1_LOJA"    	, aTitGer[nI,6]		, Nil } )	// 06
		AADD( aBaixa, { "AUTMOTBX"  	, "NOR"				, Nil } )	// 07
		AADD( aBaixa, { "AUTBANCO"  	, aTitGer[nI,22]	, Nil } )	// 08
		AADD( aBaixa, { "AUTAGENCIA"  	, aTitGer[nI,23]	, Nil } )	// 09
		AADD( aBaixa, { "AUTCONTA"  	, aTitGer[nI,24]	, Nil } )	// 10
		AADD( aBaixa, { "AUTDTBAIXA"	, dDtBaixa			, Nil } )	// 11
		AADD( aBaixa, { "AUTHIST"   	, aTitGer[nI,25]    , Nil } )	// 25
		AADD( aBaixa, { "AUTVALREC"  	, aTitGer[nI,14]	, Nil } )	// 20
	 //	AADD( aBaixa, { "AUTTXMOEDA"  	, 1 				, Nil } )	// 21

		lMsErroAuto := .F.
		
	   	Begin Transaction
			
			MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3) 
				
			IF lMsErroAuto
				lOK := .F.
				DisarmTransaction()
				Mostraerro()
				break
			ENDIF
	
  	   	End Transaction
	ENDIF


	// Baixa da Diferença de ISS
	IF aTitGer[nI,31] > 0 

    	//Posiciona no titulo
		DbSelectArea("SE1")
		SE1->(DbSetOrder(1))
		SE1->(DbSeek(xFilial("SE1")+aTitGer[nI,2]+aTitGer[nI,1]+aTitGer[nI,3]+aTitGer[nI,4],.T.))

		cQuery 	:= ""
		cQuery 	:= " DELETE from "+RETSQLNAME("SE8")+"  where D_E_L_E_T_=''"
		cQuery 	+= " AND E8_MOEDA=' 1'AND E8_FILIAL='"+xFILIAL("SE8")+"' AND E8_DTSALAT='"+DTOS(dDtBaixa)+"'" 
		cQuery 	+= " AND E8_BANCO='"+aTitGer[nI,21]+"' AND E8_AGENCIA='"+aTitGer[nI,22]+"' AND E8_CONTA='"+aTitGer[nI,23]+"'"
	
		TcSqlExec(cQuery)

		aBaixa := {}
		// grava baixa da Retenção Contratual
		AADD( aBaixa, { "E1_PREFIXO" 	, aTitGer[nI,2]		, Nil } )	// 01
		AADD( aBaixa, { "E1_NUM"     	, aTitGer[nI,1]	 	, Nil } )	// 02
		AADD( aBaixa, { "E1_PARCELA" 	, aTitGer[nI,3]		, Nil } )	// 03
		AADD( aBaixa, { "E1_TIPO"    	, aTitGer[nI,4]		, Nil } )	// 04
		AADD( aBaixa, { "E1_CLIENTE"	, aTitGer[nI,5]		, Nil } )	// 05
		AADD( aBaixa, { "E1_LOJA"    	, aTitGer[nI,6]		, Nil } )	// 06
		AADD( aBaixa, { "AUTMOTBX"  	, "NOR"				, Nil } )	// 07
		AADD( aBaixa, { "AUTBANCO"  	, aTitGer[nI,27]	, Nil } )	// 08
		AADD( aBaixa, { "AUTAGENCIA"  	, aTitGer[nI,28]	, Nil } )	// 09
		AADD( aBaixa, { "AUTCONTA"  	, aTitGer[nI,29]	, Nil } )	// 10
		AADD( aBaixa, { "AUTDTBAIXA"	, dDtBaixa			, Nil } )	// 11
		AADD( aBaixa, { "AUTHIST"   	, aTitGer[nI,30]    , Nil } )	// 25
		AADD( aBaixa, { "AUTVALREC"  	, aTitGer[nI,31]	, Nil } )	// 20
	 //	AADD( aBaixa, { "AUTTXMOEDA"  	, 1 				, Nil } )	// 21

		lMsErroAuto := .F.
		
	   	Begin Transaction
			
			MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3) 
				
			IF lMsErroAuto
				lOK := .F.
				DisarmTransaction()
				Mostraerro()
				break
			ENDIF
	
  	   	End Transaction
	ENDIF


	// Baixa dos Juros Antecipados
	IF aTitGer[nI,36] > 0 

    	//Posiciona no titulo
		DbSelectArea("SE1")
		SE1->(DbSetOrder(1))
		SE1->(DbSeek(xFilial("SE1")+aTitGer[nI,2]+aTitGer[nI,1]+aTitGer[nI,3]+aTitGer[nI,4],.T.))

		cQuery 	:= ""
		cQuery 	:= " DELETE from "+RETSQLNAME("SE8")+"  where D_E_L_E_T_=''"
		cQuery 	+= " AND E8_MOEDA=' 1'AND E8_FILIAL='"+xFILIAL("SE8")+"' AND E8_DTSALAT='"+DTOS(dDtBaixa)+"'" 
		cQuery 	+= " AND E8_BANCO='"+aTitGer[nI,21]+"' AND E8_AGENCIA='"+aTitGer[nI,22]+"' AND E8_CONTA='"+aTitGer[nI,23]+"'"
	
		TcSqlExec(cQuery)

		aBaixa := {}
		// grava baixa da Retenção Contratual
		AADD( aBaixa, { "E1_PREFIXO" 	, aTitGer[nI,2]		, Nil } )	// 01
		AADD( aBaixa, { "E1_NUM"     	, aTitGer[nI,1]	 	, Nil } )	// 02
		AADD( aBaixa, { "E1_PARCELA" 	, aTitGer[nI,3]		, Nil } )	// 03
		AADD( aBaixa, { "E1_TIPO"    	, aTitGer[nI,4]		, Nil } )	// 04
		AADD( aBaixa, { "E1_CLIENTE"	, aTitGer[nI,5]		, Nil } )	// 05
		AADD( aBaixa, { "E1_LOJA"    	, aTitGer[nI,6]		, Nil } )	// 06
		AADD( aBaixa, { "AUTMOTBX"  	, "NOR"				, Nil } )	// 07
		AADD( aBaixa, { "AUTBANCO"  	, aTitGer[nI,32]	, Nil } )	// 08
		AADD( aBaixa, { "AUTAGENCIA"  	, aTitGer[nI,33]	, Nil } )	// 09
		AADD( aBaixa, { "AUTCONTA"  	, aTitGer[nI,34]	, Nil } )	// 10
		AADD( aBaixa, { "AUTDTBAIXA"	, dDtBaixa			, Nil } )	// 11
		AADD( aBaixa, { "AUTHIST"   	, aTitGer[nI,35]    , Nil } )	// 25
		AADD( aBaixa, { "AUTVALREC"  	, aTitGer[nI,36]	, Nil } )	// 20
		//AADD( aBaixa, { "AUTDESCONT" 	, aTitGer[nI,15]	, Nil } )	// 13
		//AADD( aBaixa, { "AUTMULTA"	 	, aTitGer[nI,16]	, Nil } )	// 14

		lMsErroAuto := .F.
		
	   	Begin Transaction
			
			MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3) 
				
			IF lMsErroAuto
				lOK := .F.
				DisarmTransaction()
				Mostraerro()
				break
			ENDIF
	
  	   	End Transaction
	ENDIF



	dbSelectArea("SE8")
	dbSetOrder(1)
	dbSeek(xFilial("SE8")+aTitGer[nI,18]+aTitGer[nI,19]+aTitGer[nI,20]+DtoS(dDtBaixa),.T.)

	cQuery 	:= ""
	cQuery 	:= " DELETE from "+RETSQLNAME("SE8")+"  where D_E_L_E_T_=''"
	cQuery 	+= " AND E8_MOEDA=' 1'AND E8_FILIAL='"+xFILIAL("SE8")+"' AND E8_DTSALAT='"+DTOS(dDtBaixa)+"'" 
	cQuery 	+= " AND E8_BANCO='"+aTitGer[nI,18]+"' AND E8_AGENCIA='"+aTitGer[nI,19]+"' AND E8_CONTA='"+aTitGer[nI,20]+"'"
	
	TcSqlExec(cQuery)

    //Posiciona no titulo
	DbSelectArea("SE1")
	SE1->(DbSetOrder(1))
	SE1->(DbSeek(xFilial("SE1")+aTitGer[nI,2]+aTitGer[nI,1]+aTitGer[nI,3]+aTitGer[nI,4],.T.))

	aBaixa := {}		
	// grava baixa do titulo
	AADD( aBaixa, { "E1_PREFIXO" 	, aTitGer[nI,2]		, Nil } )	// 01
	AADD( aBaixa, { "E1_NUM"     	, aTitGer[nI,1]	 	, Nil } )	// 02
	AADD( aBaixa, { "E1_PARCELA" 	, aTitGer[nI,3]		, Nil } )	// 03
	AADD( aBaixa, { "E1_TIPO"    	, aTitGer[nI,4]		, Nil } )	// 04
	AADD( aBaixa, { "E1_CLIENTE"	, aTitGer[nI,5]		, Nil } )	// 05
	AADD( aBaixa, { "E1_LOJA"    	, aTitGer[nI,6]		, Nil } )	// 06
	AADD( aBaixa, { "AUTMOTBX"  	, "NOR"				, Nil } )	// 07
	AADD( aBaixa, { "AUTBANCO"  	, aTitGer[nI,18]	, Nil } )	// 08
	AADD( aBaixa, { "AUTAGENCIA"  	, aTitGer[nI,19]	, Nil } )	// 09
	AADD( aBaixa, { "AUTCONTA"  	, aTitGer[nI,20]	, Nil } )	// 10
	AADD( aBaixa, { "AUTDTBAIXA"	, dDtBaixa			, Nil } )	// 11
	AADD( aBaixa, { "AUTHIST"   	, aTitGer[nI,21], Nil } )
	AADD( aBaixa, { "AUTDESCONT" 	, aTitGer[nI,15]	, Nil } )	// 13
	AADD( aBaixa, { "AUTMULTA"	 	, aTitGer[nI,16]	, Nil } )	// 14
	AADD( aBaixa, { "AUTVALREC"  	, aTitGer[nI,17]	, Nil } )	// 20
	AADD( aBaixa, { "AUTTXMOEDA"  	, 1 				, Nil } )	// 21

	lMsErroAuto := .F.
	
   	Begin Transaction
		
		MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3) 
			
		IF lMsErroAuto
			lOK := .F.
			DisarmTransaction()
			Mostraerro()
			break
		ENDIF
  	End Transaction
 			
Next nI


cLOG := ""
For nI:=1 TO LEN(aTitGer)

	cKey    := ""
	cKey    := xFilial ("SE1") + aTitGer[nI,2]  + aTitGer[nI,1] + aTitGer[nI,3] + aTitGer[nI,4]
		
	DbSelectArea ("SE1")
	DbSetOrder (1)
	IF DbSeek (cKey,.F.)
   		IF SE1->E1_SALDO > 1
   		   cLOG += 	"PREFIXO:"+aTitGer[nI,2]+"    NUM:"+aTitGer[nI,1]+"    PARCELA:"+aTitGer[nI,3]+"    TIPO:"+aTitGer[nI,4]+"    CLIENTE:"+aTitGer[nI,5]+"    LOJA:"+aTitGer[nI,6]+cCrLf
			lOK := .F.
   		ENDIF
    ENDIF

Next nI

IF lOK
	Msginfo("Titulos Baixado com sucesso!!")
ELSE
	IF !EMPTY(cLOG)
		cLOG := "Titulo(s) com baixa parcial. Verifique!!"+cCrLf+cCrLf+cCrLf+cLOG
		Aviso("Atencao",cLOG, {"Ok"})
	ENDIF
ENDIF


RETURN NIL
