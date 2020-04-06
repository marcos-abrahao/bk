#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³BKFINA16       ºAutor Adilson do Prado      ºData ³15/01/2015º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Rotina para Selecionar Títulos e Gerar Baixa - Portal        ±±
±±º			  Transparencia 			                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³BK                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

/*/
User Function BKFINA16()

Local lOk      := .F.
Local cTitulo := "Selecionar Títulos e Gerar Baixa - Portal Transparencia - "+ALLTRIM(SM0->M0_NOME)

PRIVATE oDlg
PRIVATE oListId
PRIVATE oPanelLeft
PRIVATE aButtons := {}
PRIVATE aTitGer  := {}
PRIVATE cPICT := "@E 999,999,999.99"
PRIVATE cFatura	:= SPACE(9)
PRIVATE cPrefix	:= SPACE(3)
PRIVATE cParc	:= SPACE(2)
PRIVATE cTipo	:= SPACE(3)
PRIVATE cCli	:= SPACE(6)
PRIVATE cLoja	:= SPACE(2)
Private cNCli   := SPACE(40)
PRIVATE dVencto := CTOD("") 
PRIVATE nVlrTit := 0
Private nVlrCVinc := 0
PRIVATE nVlrImp	:= 0
PRIVATE nVlrLi  := 0
PRIVATE nDesc   := 0
PRIVATE nMulta  := 0
PRIVATE nReceb  := 0
PRIVATE nTotBK	:= 0

// BAIXA
private cBanco  := space(3)
private cAgencia := space(5)
private cConta   := space(15)
private dDtBaixa := dDataBase
private cHist    := PAD("VALOR RECEBIDO S/ TITULO",40)
private lCancelou := .F.
// BAIXA VINCULADA
private cVBanco  := space(3)
private cVAgencia := space(5)
private cVConta   := space(15)


DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 600,950 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 520,525
oPanelLeft:Align := CONTROL_ALIGN_LEFT

@ 010, 010 SAY "Nr.Doc."  SIZE 49, 7 OF oPanelLeft PIXEL 
@ 020, 010 MSGET cFatura Picture "@!"  When .T. SIZE 50, 11 OF oPanelLeft PIXEL F3 "SE1_2" VALID (BuscaSE1(),NaoVazio(cFatura))  //BuscaSE1()

@ 010, 070 SAY "Serie" SIZE 21, 7 OF oPanelLeft PIXEL
@ 020, 070 MSGET cPrefix Picture "@!" When .F. SIZE 10, 11 OF oPanelLeft PIXEL 

@ 010, 100 SAY "Parcela" SIZE 21, 7 OF oPanelLeft PIXEL
@ 020, 100 MSGET cParc Picture "@!" When .F. SIZE 10, 11 OF oPanelLeft PIXEL 

@ 010, 125 SAY "Tipo" SIZE 21, 7 OF oPanelLeft PIXEL
@ 020, 125 MSGET cTipo Picture "@!" When .F. SIZE 10, 11 OF oPanelLeft PIXEL 

@ 010, 160 SAY "Cliente" SIZE 35, 7 OF oPanelLeft PIXEL 
@ 020, 160 MSGET cCli	Picture "@!"  When .F.  SIZE 40, 11 OF oPanelLeft PIXEL

@ 010, 220 SAY "Loja" SIZE 30, 7 OF oPanelLeft PIXEL 
@ 020, 220 MSGET cLoja	Picture "@!"  When .F.  SIZE 21, 11 OF oPanelLeft PIXEL

@ 010, 250 SAY "Nome Cliente"  SIZE 35, 7 OF oPanelLeft PIXEL 
@ 020, 250 MSGET cNCli	Picture "@!"  When .F.  SIZE 140, 11 OF oPanelLeft PIXEL

@ 010, 400 SAY "Vencimento" SIZE 35, 7 OF oPanelLeft PIXEL
@ 020, 400 MSGET dVencto  When .F.	SIZE 50, 11 OF oPanelLeft PIXEL

@ 035, 010 SAY "Banco Baixa"  SIZE 50, 7 OF oPanelLeft PIXEL 
@ 045, 010 MSGET cBanco Picture "@!"  When .T. SIZE 50, 11 OF oPanelLeft PIXEL F3 "SA6" VALID (NaoVazio(cBanco))  //BuscaSE1()
                        
@ 035, 070 SAY "Agência Baixa" SIZE 50, 7 OF oPanelLeft PIXEL
@ 045, 070 MSGET cAgencia Picture "@!" When .T. SIZE 30, 11 OF oPanelLeft PIXEL VALID NaoVazio(cAgencia)

@ 035, 120 SAY "Conta Baixa" SIZE 50, 7 OF oPanelLeft PIXEL
@ 045, 120 MSGET cConta Picture "@!" When .T. SIZE 60, 11 OF oPanelLeft PIXEL VALID NaoVazio(cConta)

@ 035, 210 SAY "Banco Vinc."  SIZE 50, 7 OF oPanelLeft PIXEL 
@ 045, 210 MSGET cVBanco Picture "@!"  When .T. SIZE 50, 11 OF oPanelLeft PIXEL F3 "SA6" 
                        
@ 035, 270 SAY "Agência Vinc." SIZE 50, 7 OF oPanelLeft PIXEL
@ 045, 270 MSGET cVAgencia Picture "@!" When .T. SIZE 30, 11 OF oPanelLeft PIXEL 

@ 035, 320 SAY "Conta Vinc." SIZE 50, 7 OF oPanelLeft PIXEL
@ 045, 320 MSGET cVConta Picture "@!" When .T. SIZE 60, 11 OF oPanelLeft PIXEL 

@ 060, 010 SAY "Vlr. Título" SIZE 35, 7 OF oPanelLeft PIXEL
@ 070, 010 MSGET nVlrTit Picture "@E 999,999,999.99" When .F. SIZE 50, 11 OF oPanelLeft PIXEL

@ 060, 070 SAY "Vlr.Impostos" SIZE 45, 7 OF oPanelLeft PIXEL
@ 070, 070 MSGET nVlrImp Picture "@E 999,999,999.99" When .F. SIZE 50, 11 OF oPanelLeft PIXEL

@ 060, 130 SAY "Vlr. Líquido" SIZE 35, 7 OF oPanelLeft PIXEL
@ 070, 130 MSGET nVlrLi Picture "@E 999,999,999.99" When .F. SIZE 50, 11 OF oPanelLeft PIXEL

@ 060, 190 SAY "Vlr.C.Vinculada" SIZE 45, 7 OF oPanelLeft PIXEL
@ 070, 190 MSGET nVlrCVinc Picture "@E 999,999,999.99" When .T. SIZE 50, 11 OF oPanelLeft PIXEL VALID(POSITIVO(nVlrCVinc),SOMATAB())

@ 060, 250 SAY "- Desconto " SIZE 35, 7 OF oPanelLeft PIXEL
@ 070, 250 MSGET nDesc Picture "@E 999,999,999.99" When .T. SIZE 50, 11 OF oPanelLeft PIXEL VALID(POSITIVO(nDesc),SOMATAB())

@ 060, 310 SAY "+ Multa " SIZE 35, 7 OF oPanelLeft PIXEL
@ 070, 310 MSGET nMulta Picture "@E 999,999,999.99" When .T. SIZE 50, 11 OF oPanelLeft PIXEL VALID(POSITIVO(nMulta),SOMATAB())

@ 060, 370 SAY "A Receber" SIZE 35, 7 OF oPanelLeft PIXEL
@ 070, 370 MSGET nReceb Picture "@E 999,999,999.99" When .F. SIZE 50, 11 OF oPanelLeft PIXEL

@ 085, 010 SAY "Histórico" SIZE 50, 7 OF oPanelLeft PIXEL 
@ 095, 010 MSGET cHist	Picture "@!"  When .T.  SIZE 200, 11 OF oPanelLeft PIXEL

@ 095, 430 Button "Incluir" Size 040,013 OF oPanelLeft Pixel Action (InclTab())

@ 115, 005 LISTBOX oListID FIELDS HEADER "N°Titulo","Prefixo","Parcela","Tipo","Natureza","Cliente","Loja","NomeCli","Emissao","VenctoReal",;
"Vlr.Titulo","Vlr.Impostos","Vlr.Liquido","Vlr.C.Vinculada","- Desconto ","+ Multa ","A Receber","Banco Baixa","Agencia Baixa","Conta Baixa","Banco Vinc.","Agencia Vinc.","Conta Vinc.","Histórico" SIZE 470,130 OF oPanelLeft PIXEL 

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
                         TRANSFORM(aTitGer[oListId:nAt][11],cPICT ),;
                         TRANSFORM(aTitGer[oListId:nAt][12],cPICT ),;
                         TRANSFORM(aTitGer[oListId:nAt][13],cPICT ),;
                         TRANSFORM(aTitGer[oListId:nAt][14],cPICT ),;
                         TRANSFORM(aTitGer[oListId:nAt][15],cPICT ),;
                         TRANSFORM(aTitGer[oListId:nAt][16],cPICT ),;
                         TRANSFORM(aTitGer[oListId:nAt][17],cPICT ),; 
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

cKey    := xFilial ("SE1") + cPrefix  + cFatura + cParc + cTipo
		
DbSelectArea ("SE1")
DbSetOrder (1)
IF DbSeek (cKey,.F.)
   	IF SE1->E1_VALOR == SE1->E1_SALDO
		cCli	:= SE1->E1_CLIENTE
		cLoja	:= SE1->E1_LOJA
		cNCli   := Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_NOME")
		dVencto := SE1->E1_VENCREA 
		nVlrTit := SE1->E1_VALOR
		dbSelectArea ("SF2")
		dbSetOrder (1)
		IF dbSeek (xFilial("SF2")+SE1->E1_NUM+SE1->E1_PREFIXO+SE1->E1_CLIENTE+SE1->E1_LOJA, .F.)
			nVlrCVinc 	:= SF2->F2_XXVCVIN
			nVlrImp 	:= SF2->F2_VALIRRF + SF2->F2_VALINSS + SF2->F2_VALPIS + SF2->F2_VALCOFI + SF2->F2_VALCSLL + IIF(SF2->F2_RECISS = '1',SF2->F2_VALISS,0) + SF2->F2_XXVFUMD
			nVlrLi 		:= SF2->F2_VALFAT - nVlrImp
			cVBanco 	:= SUBSTR(SF2->F2_XXCVINC,1,3)
	   		cVAgencia	:= SUBSTR(SF2->F2_XXCVINC,4,5)
			cVConta  	:= SUBSTR(SF2->F2_XXCVINC,10,15)
		ENDIF 
		nDesc   := 0
		nMulta  := 0
		nReceb  := nVlrLi + nMulta - nDesc - nVlrCVinc
  	ELSE
  		if SE1->E1_SALDO > 0
			MSGSTOP("Titulo Baixado parcial, favor utilizar rotina padrao de sistema!!")
		ELSE
			MSGSTOP("Titulo ja foi Baixado !!")
		ENDIF
		LIMPTAB()
 	ENDIF
ELSE
	MSGSTOP("Titulo não Encontrado")
	LIMPTAB()
	lRet := .F.
ENDIF

Return lRet 

STATIC FUNCTION SOMATAB()
	nReceb  := 0
	nReceb  := nVlrLi + nMulta - nDesc - nVlrCVinc
		
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
nVlrCVinc := 0
nVlrImp	:= 0
nVlrLi  := 0
nDesc   := 0
nMulta  := 0
nReceb  := 0

// BAIXA
//cBanco  := space(3)
//cAgencia := space(5)
//cConta   := space(15)
dDtBaixa := dDataBase
cHist    := PAD("VALOR RECEBIDO S/ TITULO",40)

// BAIXA VINCULADA
cVBanco  := space(3)
cVAgencia := space(5)
cVConta   := space(15)

RETURN NIL


STATIC FUNCTION VALIDTAB()
LOCAL lRET := .T. 
Local nScan:= 0

cKey    := xFilial ("SE1") + cPrefix  + cFatura + cParc + cTipo 

		
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

IF nVlrCVinc > 0
	IF EMPTY(cVBanco) .OR. EMPTY(cVAgencia) .OR. EMPTY(cVConta)
		MSGSTOP("Dados do Banco para Baixa conta Vinculada não informado. Verificar!")
		lRET := .F.
		RETURN lRET 	
	ENDIF

	DbSelectArea("SA6")
	SA6->(DbSetOrder(1))
	IF SA6->(DbSeek(xFilial("SA6")+cVBanco+cVAgencia+cVConta,.F.))
		IF SA6->A6_BLOCKED == '1'
			MSGSTOP("Banco informado para baixa Vinculada bloqueada para movimentações. Verifique!")
			lRET := .F.
			RETURN lRET 
		ENDIF
	ELSE
		MSGSTOP("Dados do Banco para baixa Vinculada incorreto. Verifique!")
		lRET := .F.
		RETURN lRET 
	ENDIF

ENDIF

RETURN lRET


Static Function InclTab()

IF !VALIDTAB()
	RETURN NIL
ENDIF

IF aTitGer[1,1] == ""
	aTitGer := {}
ENDIF


//"N°Titulo","Prefixo","Parcela","Tipo","Natureza","Cliente","Loja","NomeCli","Emissao","VenctoReal",;
//"Vlr.Titulo","Vlr.Impostos","Vlr.Liquido","Vlr.C.Vinculada","- Desconto ","+ Multa ","A Receber","Banco Baixa","Agenica Baixa","Conta Baixa",;
//"Banco Vinc.","Agenica Vinc.","Conta Vinc." 
AADD(aTitGer,{SE1->E1_NUM,SE1->E1_PREFIXO,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,SE1->E1_CLIENTE,SE1->E1_LOJA,;
cNCli,DTOC(SE1->E1_EMISSAO),DTOC(SE1->E1_VENCREA),SE1->E1_VALOR,nVlrImp,nVlrLi,nVlrCVinc,nDesc,nMulta,nReceb,;
cBanco,cAgencia,cConta,cVBanco,cVAgencia,cVConta,cHist})


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
               	         TRANSFORM(aTitGer[oListId:nAt][11],cPICT ),;
                   	     TRANSFORM(aTitGer[oListId:nAt][12],cPICT ),;
                       	 TRANSFORM(aTitGer[oListId:nAt][13],cPICT ),;
                         TRANSFORM(aTitGer[oListId:nAt][14],cPICT ),;
   	                     TRANSFORM(aTitGer[oListId:nAt][15],cPICT ),;
       	                 TRANSFORM(aTitGer[oListId:nAt][16],cPICT ),;
           	             TRANSFORM(aTitGer[oListId:nAt][17],cPICT ),; 
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
		                         TRANSFORM(aTitGer[oListId:nAt][11],cPICT ),;
        		                 TRANSFORM(aTitGer[oListId:nAt][12],cPICT ),;
                		         TRANSFORM(aTitGer[oListId:nAt][13],cPICT ),;
                        		 TRANSFORM(aTitGer[oListId:nAt][14],cPICT ),;
		                         TRANSFORM(aTitGer[oListId:nAt][15],cPICT ),;
        		                 TRANSFORM(aTitGer[oListId:nAt][16],cPICT ),;
                		         TRANSFORM(aTitGer[oListId:nAt][17],cPICT ),; 
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
LOCAL nI := 0
LOCAL aBaixa:= {}
LOCAL lOK := .T.
Local cCrLf := Chr(13) + Chr(10)
Local cLOG  := ""

Private dDtBaixa  := dDataBase
Private MsErroAuto := .F.


For nI:=1 TO LEN(aTitGer)


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
	AADD( aBaixa, { "AUTHIST"   	, aTitGer[nI,24], Nil } )	// 12 //"Diferencia de cambio"

//	{"AUTDTCREDITO",dDtBaixa,Nil},;

	AADD( aBaixa, { "AUTDESCONT" 	, aTitGer[nI,15]	, Nil } )	// 13
	AADD( aBaixa, { "AUTMULTA"	 	, aTitGer[nI,16]	, Nil } )	// 14
	AADD( aBaixa, { "AUTVALREC"  	, aTitGer[nI,13] - aTitGer[nI,14]- aTitGer[nI,15] + aTitGer[nI,16]					, Nil } )	// 20
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
		// grava baixa do titulo CONTA VINCULADA
		AADD( aBaixa, { "E1_PREFIXO" 	, aTitGer[nI,2]		, Nil } )	// 01
		AADD( aBaixa, { "E1_NUM"     	, aTitGer[nI,1]	 	, Nil } )	// 02
		AADD( aBaixa, { "E1_PARCELA" 	, aTitGer[nI,3]		, Nil } )	// 03
		AADD( aBaixa, { "E1_TIPO"    	, aTitGer[nI,4]		, Nil } )	// 04
		AADD( aBaixa, { "E1_CLIENTE"	, aTitGer[nI,5]		, Nil } )	// 05
		AADD( aBaixa, { "E1_LOJA"    	, aTitGer[nI,6]		, Nil } )	// 06
		AADD( aBaixa, { "AUTMOTBX"  	, "NOR"				, Nil } )	// 07
		AADD( aBaixa, { "AUTBANCO"  	, aTitGer[nI,21]	, Nil } )	// 08
		AADD( aBaixa, { "AUTAGENCIA"  	, aTitGer[nI,22]	, Nil } )	// 09
		AADD( aBaixa, { "AUTCONTA"  	, aTitGer[nI,23]	, Nil } )	// 10
		AADD( aBaixa, { "AUTDTBAIXA"	, dDtBaixa			, Nil } )	// 11
		AADD( aBaixa, { "AUTHIST"   	, "VALOR RECEBIDO S/ TITULO", Nil } )	// 12 //"Diferencia de cambio"
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
    
 			
Next nI

cLOG := ""
For nI:=1 TO LEN(aTitGer)

	cKey    := ""
	cKey    := xFilial ("SE1") + aTitGer[nI,2]  + aTitGer[nI,1] + aTitGer[nI,3] + aTitGer[nI,4]
		
	DbSelectArea ("SE1")
	DbSetOrder (1)
	IF DbSeek (cKey,.F.)
   		IF SE1->E1_SALDO > 0
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