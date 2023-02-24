#include "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#include "TopConn.ch"

/*/
BK -Inclusão Termo Transferencia / Responsabilidade / Recebimento controle de Estoque

@author Adilson do Prado
@since 18/01/2023
@version P12
@return Nil
/*/

User Function BKESTA03
Local cFiltra     := "D3_XXCODIG<>''"

Private cCadastro	:= "Inclusão Termo Transferencia / Responsabilidade / Recebimento"
Private cDelFunc	:= ".F." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString 	:= "SD3"
Private aIndexSz  	:= {}
Private aFixeFX     := {}
Private bFiltraBrw	:= { || FilBrowse(cString,@aIndexSz,@cFiltra) } 
Private aCores  := {}
Private aRotina	:= {}
Private oListSD3

//u_MsgLog("BKESTA03")

AADD(aCores,{"SD3->D3_XXDOC==''","BR_LARANJA"})
AADD(aCores,{"SD3->D3_XXDOC<>''","BR_VERDE"})

AADD(aRotina,{"Pesquisa"		        ,"AxPesquisa"   ,0,1})
AADD(aRotina,{"Visualizar"		        ,"AxVisual"     ,0,2})
AADD(aRotina,{"Incluir"	                ,"U_INCLSD3"    ,0,3})
AADD(aRotina,{"Recebimento Uniforme"	,"U_RECBUNISD3" ,0,4})
AADD(aRotina,{"Devolução Uniforme"		,"U_DEVOUNISD3" ,0,4})
AADD(aRotina,{"Impressão Termo"		    ,"U_PRINTSD3"   ,0,4})
AADD(aRotina,{"Legenda"			        ,"U_SD3LEG"     ,0,4})


dbSelectArea(cString)
dbSetOrder(1)
//+------------------------------------------------------------
//| Cria o filtro na MBrowse utilizando a função FilBrowse
//+------------------------------------------------------------
Eval(bFiltraBrw)

dbSelectArea(cString)
dbGoTop()

mBrowse(6,1,22,75,cString,aFixeFX,,,,,aCores)

//+------------------------------------------------
//| Deleta o filtro utilizado na função FilBrowse
//+------------------------------------------------
EndFilBrw(cString,aIndexSz)

RETURN NIL


User Function SD3LEG()
Local aCores2 := {}
Local cLegenda := ""

cLegenda	:= "Legenda de Cores"

AADD(aCores2,{"BR_VERDE"  , "Termo Transferencia"})
AADD(aCores2,{"BR_LARANJA", "Termo Recebimento"})

BrwLegenda(cLegenda,"Inclusão Termo Transferencia / Responsabilidade / Recebimento",aCores2)

RETURN NIL


USER FUNCTION INCLSD3
Local lOk		 := .F.
Local nSnd       := 15
Local nTLin      := 15
Local oDlg01     as Object
Local oButInv    as Object
Local aButtons   := {}

PRIVATE aItemSD3   := {}
PRIVATE cCusto     := SPACE(9)
PRIVATE cDESCTT	 := SPACE(80)
PRIVATE cENDSAID   := SPACE(250)
PRIVATE cENDENTR   := SPACE(250)
PRIVATE cRespDecl  := SPACE(80)
PRIVATE cCPFDecl   := SPACE(11)
PRIVATE dDataD	 := dDATABASE
PRIVATE cGestor  := SPACE(80)
PRIVATE cDCLIENT := SPACE(80)


    AADD(aItemSD3,{"","","","",SPACE(20),CTOD(""),0,"","","",""})


    Define MsDialog oDlg01 Title "Incluir Termo de Transferencia / Responsabilidade de Uso" From 000,000 To 450,830 Of oDlg01 Pixel
	
	@ 000,000 MSPANEL oPanelLeft OF oDlg01 SIZE 430,825 
	oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
	@ nSnd,010 SAY "Data de Emissão:" SIZE 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet dDataD Picture "@E"  Size 060,010 Pixel OF oPanelLeft WHEN .T.

	@ nSnd,130 MsGet cDCLIENT Picture '@!' Size 250,010 Pixel OF oPanelLeft PIXEL WHEN .F. 

	nSnd += nTLin

	@ nSnd,010 Say "Custo / Contrato:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cCusto Picture '@!' F3 "CTT" Size 060,010 Pixel OF oPanelLeft WHEN .T. VALID(!Empty(cCusto) .AND. VALIDCONTR(cCusto))

	@ nSnd,130 MsGet cDESCTT Picture '@!' Size 150,010 Pixel OF oPanelLeft PIXEL WHEN .F. 

	@ nSnd,285 SAY "Gestor:" SIZE 080,010 Pixel OF oPanelLeft
	@ nSnd,310 MsGet cGestor SIZE 100,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .T.
	nSnd += nTLin

	@ nSnd,010 Say "Endereço Saida:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cENDSAID Picture '@!' Size 350,010 Pixel OF oPanelLeft WHEN .T.
	nSnd += nTLin
	
	@ nSnd,010 Say "Endereço Entrega:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cENDENTR Picture "@E"  Size 350,010 Pixel OF oPanelLeft WHEN .T.
	nSnd += nTLin
		
	@ nSnd,010 Say "Resp. Declaração" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cRespDecl Picture '@!' Size 200,010 Pixel OF oPanelLeft WHEN .T.
	
	@ nSnd,265 Say "CPF Resp. Declaração:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,330 MsGet cCPFDecl SIZE 080,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .T.
	nSnd += nTLin

    @ nSnd,010 Button oButInv    Prompt "Seleciona Nota\Produtos"  Size 100, 12 Pixel Action ( BKESTA03A() ) ;
    Message "Seleciona Produtos" Of oPanelLeft
	nSnd += nTLin
	
	@ nSnd, 010 LISTBOX oListSD3 FIELDS HEADER "Item","Cod. Produto","Descrição","Quantidade","Cod. CA","Validade CA","Valor Total",'Nota Fiscal',"Serie","Fornece","Loja" SIZE 400,085  OF oPanelLeft PIXEL 
	
	oListSD3:SetArray(aItemSD3)
	oListSD3:bLine := {|| {	aItemSD3[oListSD3:nAt][1],;
							aItemSD3[oListSD3:nAt][2],;
							aItemSD3[oListSD3:nAt][3],;
							aItemSD3[oListSD3:nAt][4],;
							aItemSD3[oListSD3:nAt][5],;   
							aItemSD3[oListSD3:nAt][6],;                                                     
							TRANSFORM(aItemSD3[oListSD3:nAt][7],"@E 999,999,999.99"),;
							aItemSD3[oListSD3:nAt][8],;
							aItemSD3[oListSD3:nAt][9],;
							aItemSD3[oListSD3:nAt][10],;                                                                                    
							aItemSD3[oListSD3:nAt][11]}}

	oListSD3:bLDblClick := {|| EDITCNR2(@aItemSD3),oListSD3:DrawSelect(), }
	
	ACTIVATE MSDIALOG oDlg01 CENTERED Valid(ValidaSD3()) ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

	If ( lOk )
		lOk:=.F.
		If u_MsgLog("INCLSD3","Incluir Termo de Transferencia / Responsabilidade de Uso?","Y")
			//U_TMATA241()
			U_PRINTSD3()
		ENDIF
	Endif

RETURN lOk



STATIC FUNCTION VALIDCONTR(cNumContr)
LOCAL lOK := .F.

cDCLIENT := ""
cDESCTT	 := ""
cGestor  := ""


DBSELECTAREA("CN9")
CN9->(DBSETORDER(1))
CN9->(MsSEEK(xFILIAL("CN9")+cNumContr))
DO WHILE CN9->(!EOF())  .AND. ALLTRIM(CN9->CN9_NUMERO) == ALLTRIM(cNumContr)
	cDCLIENT := TRIM(CN9->CN9_NOMCLI)
	cDESCTT	 := TRIM(CN9->CN9_XXDESC)
	cGestor  := TRIM(CN9->CN9_XXNRBK)
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+CN9->CN9_CLIENT+CN9->CN9_LOJACL))
		cENDENTR := AllTrim(SA1->A1_END)
		cENDENTR += IIF(!EMPTY(SA1->A1_BAIRRO),", "+AllTrim(SA1->A1_BAIRRO),"")
		cENDENTR += ", "+AllTrim(SA1->A1_MUN)+" - "+AllTrim(SA1->A1_EST)
		cENDENTR +=  " CEP "+TRANSFORM(SA1->A1_CEP,"@R 99999-999")
	EndIf
	CN9->(dbSkip())
ENDDO

IF EMPTY(cDESCTT)
	DBSELECTAREA("CTT")
	CTT->(DBSETORDER(1))
	IF CTT->(MsSEEK(xFILIAL("CTT")+cNumContr))
		cDCLIENT := "Centro de Custo"
		cDESCTT	 := CTT->CTT_DESC01
		cGestor  := SPACE(80)
		lOK := .T.
		ENDERSAIDA()
	ELSE
		cDCLIENT := SPACE(80)
		cDESCTT	 := SPACE(80)
		cGestor  := SPACE(80)
		lOK := .F.
		MSGSTOP("Centro de Custo ou Contrato não Encontrado!", "Atenção" )
	ENDIF
ELSE
	lOK := .T.
	ENDERSAIDA()
ENDIF

RETURN lOK

STATIC FUNCTION ValidaSD3()
LOCAL lOK := .T.
LOCAL cMensag := ""

IF EMPTY(ALLTRIM(cENDSAID))
	cMensag += "Endereço de Saida não informado."+CRLF
	lOK := .F.
ENDIF
IF EMPTY(ALLTRIM(cENDENTR))
	cMensag += "Endereço de Entrega não informado."+CRLF
	lOK := .F.
ENDIF
IF EMPTY(ALLTRIM(cRespDecl))
	cMensag += "Responsavel pela Declaração não informado."+CRLF
	lOK := .F.
ENDIF
IF EMPTY(ALLTRIM(cCPFDecl))
	cMensag += "CPF do Responsavel pela Declaração não informado."+CRLF
	lOK := .F.
ELSE
	IF !ChkCPF(ALLTRIM(cCPFDecl))
		cMensag += "CPF do Responsavel pela Declaração Inválido."+CRLF
		lOK := .F.
	ENDIF
ENDIF
IF LEN(aItemSD3) <= 0
	cMensag += "Nota\Produtos não informado."+CRLF
	lOK := .F.
ENDIF
IF LEN(aItemSD3) == 1
	IF EMPTY(aItemSD3[1,1]) 
		cMensag += "Nota\Produtos não informado."+CRLF
		lOK := .F.
	ENDIF
ENDIF

IF !lOK
	MSGSTOP(cMensag,"Atenção!")
ENDIF
RETURN lOK


STATIC FUNCTION ENDERSAIDA()
Local aArea     := Getarea()
Local oOk
Local oNo
Local oDlg
Local oPanelLeft
Local aButtons 	:= {}
Local lOk      	:= .F.
Local cTitulo 	:= "Endereço de Saida"
Local aEndSaida := {}
Local cEndSaida := cENDSAID

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

nLin := 15

AADD(aEndSaida,"AV. LPIRANGA, 104, REPÚBLICA, SÃO PAULO - SP CEP 01046-010")
AADD(aEndSaida,"RUA BONNARD, 980 - BLOCO 9 - NÍVEL 7, ALPHAVILLE EMPRESARIAL, BARUERI - SP CEP 06473-000")

DO WHILE .T.	

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 160,800 PIXEL
	@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 800,150
	oPanelLeft:Align := CONTROL_ALIGN_LEFT

	@ nLin,010 SAY 'Endereço Saida:' PIXEL SIZE 60,10 OF oPanelLeft
 	@ nLin,080 COMBOBOX cEndSaida  ITEMS aEndSaida SIZE 250,010 Pixel OF oPanelLeft WHEN .T.
	nLin += 25

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , @aButtons)
		
	If ( lOk )
  		lOk := .F.
		cENDSAID := cEndSaida
  	EndIf
	EXIT
	
ENDDO
Restarea( aArea )
RETURN NIL

//ALTERA COLUNAS CA E VALIDADE CA
STATIC FUNCTION EDITCNR2(aItemSD3)

lEditCell(aItemSD3,oListSD3,'@!',5)
lEditCell(aItemSD3,oListSD3,'@!',6)

RETURN NIL


User Function TMATA241()
LOCAL _lOK		:= .T.
Local _aCab1    := {}
Local _aItem    := {}
Local _atotitem :={}
Local _IX       := 0


Private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
Private lMsErroAuto := .f. //necessario a criacao

//Private _acod:={"1","MP1"}
//PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "EST"

//"Item","Cod. Produto","Descrição","Quantidade","Cod. CA","Validade CA","Valor Total",'Nota Fiscal',"Serie","Fornece","Loja"

_aCab1 := {{"D3_DOC" ,NextNumero("SD3",2,"D3_DOC",.T.), NIL},;
          {"D3_TM" ,"D01" , NIL},;
          {"D3_CC" ,cCusto, NIL},;
          {"D3_EMISSAO" ,dDataD, NIL}}

FOR _IX:= 1 TO LEN(aItemSD3)


	_aItem:={	{"D3_COD" 	  ,aItemSD3[_IX,2] ,NIL},;
				{"D3_UM" 	  , Posicione("SB1",1,xFilial("SB1")+aItemSD3[_IX,2],"B1_UM"),NIL},; 
				{"D3_QUANT"   ,aItemSD3[_IX,4] ,NIL},;
				{"D3_CUSTO1"  ,aItemSD3[_IX,7] ,NIL},;
				{"D3_XXCC" 	  ,cCusto ,NIL},;
				{"D3_XXENDBK" ,cENDSAID ,NIL},;
				{"D3_XXENDCO" ,cENDENTR ,NIL},;
				{"D3_XXNOMRE" ,cRespDecl ,NIL},;
				{"D3_XXCPFRE" ,cCPFDecl ,NIL},;
				{"D3_XXGESTO" ,cGestor ,NIL},;
				{"D3_XXCODCA"  ,aItemSD3[_IX,5] ,NIL},;
				{"D3_XXVALIC"  ,aItemSD3[_IX,6] ,NIL},;
				{"D3_XXITEM"  ,aItemSD3[_IX,1] ,NIL},;
				{"D3_XXDOC"  ,aItemSD3[_IX,8] ,NIL},;
				{"D3_XXSER"  ,aItemSD3[_IX,9] ,NIL},;
				{"D3_XXFOR"  ,aItemSD3[_IX,10] ,NIL},;
				{"D3_XXLOJ"  ,aItemSD3[_IX,11] ,NIL},;
				{"D3_LOCAL"   ,"01" ,NIL}}

				//{"D3_LOTECTL" ,"",NIL},;
				//{"D3_LOCALIZ" , cCusto,NIL}}
/*
D3_XXRDEVO
D3_XXCPFRD
D3_XXEUSO
D3_XXPRONT
D3_XXNOME
D3_XXFUNCA
D3_XXCODIG
*/
																																																																																																					
	aadd(_atotitem,_aitem) 
NEXT _IX

Begin Transaction
	MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,3)
	If lMsErroAuto 
		Mostraerro() 
		DisarmTransaction() 
		_lOK := .T.
	EndIf
End Transaction

Return _lOK

USER FUNCTION PRINTSD3()
LOCAL cTermo 	:= 'TESTE0003'
LOCAL cENDEMPR 	:= cENDSAID
LOCAL cCLIENT 	:= cDCLIENT
LOCAL cENDCLI 	:= cENDENTR
LOCAL cRESPONS 	:= cRespDecl
LOCAL cCPFRESP 	:= cCPFDecl
LOCAL cMUNIC	:= "SÃO PAULO" 
LOCAL dDATA		:= dDataD
LOCAL aItens 	:= {}
LOCAL _IX		:= 0

IF "BARUERI" $ cENDSAID
	cMUNIC	:= "BARUERI" 
ENDIF

FOR _IX:= 1 TO LEN(aItemSD3)
	AADD(aItens,{TRIM(Posicione("SB1",1,xFilial("SB1")+aItemSD3[_IX,2],"B1_DESC")),Posicione("SB1",1,xFilial("SB1")+aItemSD3[_IX,2],"B1_UM"),aItemSD3[_IX,4]})
NEXT _IX

DTRANSTML(cTermo,dDATA,cMUNIC,cENDEMPR,cCLIENT,cENDCLI,cRESPONS,cCPFRESP,aItens)

Return NIL


STATIC FUNCTION BKESTA03A()
Local oOk
Local oNo
Local oDlg
Local oListId
Local oPanelLeft
Local lAll
Local oAll
Local aButtons := {}
Local lOk      := .F.
Local aNotas := {}
Local aParam 	:= {}
Local aRet		:=	{}
Local cTitulo   :=  "Selecionar Notas Fiscais"


aAdd( aParam, { 1, "Nota Fiscal ?"	, SPACE(TamSx3("F1_DOC")[1])	, ""            , "", "SF1"	, "" , 70  , .F. })
aAdd( aParam, { 1, "Serie?"		, SPACE(TamSx3("F1_SERIE")[1])	, ""            , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Fornecedor?"	, SPACE(TamSx3("A1_COD")[1])	, ""            , "", "SA2"	, "" , 70  , .F. })
aAdd( aParam, { 1, "Loja?"	, SPACE(TamSx3("A1_LOJA")[1])	, ""            , "", ""	, "" , 70  , .F. })


If (Parambox(aParam,"BKESTA03A - "+cTitulo,@aRet,,,.T.,,,,"BKESTA03A",.T.,.T.))
	lRet := .T.
	cNota 	:= MV_PAR01
	cSerie	:= MV_PAR02
	cFornec	:= MV_PAR03
	cLoja	:= MV_PAR04

    dbSelectArea("SD1")                   // * Itens da N.F. de Compra
	SD1->(DBSETORDER(1))
    IF DbSeek(xFilial("SD1")+cNota+cSerie+cFornec+cLoja)
       DO WHILE !EOF() .AND. SD1->D1_FILIAL+SD1->D1_DOC+ SD1->D1_SERIE+ SD1->D1_FORNECE+ SD1->D1_LOJA  == 	xFilial("SD1")+cNota+cSerie+cFornec+cLoja
  
			//"Item","Cod. Produto","Descrição","Quantidade","Valor Total",'Nota Fiscal',"Serie","Fornece","Loja" 
			AADD(aNOTAS,{.F.,SD1->D1_ITEM,SD1->D1_COD,TRIM(Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC")),SD1->D1_QUANT,SD1->D1_TOTAL,SD1->D1_DOC,SD1->D1_SERIE,SD1->D1_FORNECE,SD1->D1_LOJA,SD1->D1_CC})
        	SD1->(dbSkip())
       ENDDO
	ELSE
		MSGSTOP("Dados da Notas Fiscal não Encontrada!")
		RETURN aNotas
	ENDIF
Endif

IF LEN(aNotas) < 1
	AADD(aNotas,{.F.,"","","",0,0,"","","","",""})
ENDIF


oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE "Confirme os itens da Nota Fiscal" FROM 000,000 TO 450,830 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 430,825 
oPanelLeft:Align := CONTROL_ALIGN_LEFT
lAll := .F.
@ 005, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
oAll:bChange := {|| Aeval(aNotas,{|x| IIF(x[11]== cCusto,x[1]:=lAll,x[1]:=.F.) }), oListId:Refresh()}

			//"Item","Cod. Produto","Descrição","Quantidade","Valor Total",'Nota Fiscal',"Serie","Fornece","Loja","C.Custo"

@ 015, 010 LISTBOX oListID FIELDS HEADER "","Item","Produto","Descrição","Quantidade","Total","Nota Fiscal","Serie","Fornecedor","Loja","C.Custo" SIZE 400,180 OF oPanelLeft PIXEL 

oListID:SetArray(aNotas)
oListID:bLine := {||{If(aNotas[oListId:nAt][1],oOk,oNo),;
						aNotas[oListId:nAt][2],;
						aNotas[oListId:nAt][3],;
						aNotas[oListId:nAt][4],;
						aNotas[oListId:nAt][5],;
						TRANSFORM(aNotas[oListId:nAt][6],"@E 999,999,999.99"),;
						aNotas[oListId:nAt][7],;
						aNotas[oListId:nAt][8],;
						aNotas[oListId:nAt][9],;
						aNotas[oListId:nAt][10],;
						aNotas[oListId:nAt][11]}}

oListId:bLDblClick := {|| aNotas[oListId:nAt][1] := ValidaMrk(aNotas[oListId:nAt][1],aNotas[oListId:nAt][11]), oListId:DrawSelect()}


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

If ( lOk )
    GravaNOTAS(aNOTAS)
EndIf
Return lOk


Static Function ValidaMrk(lRet,cCCSD1)
LOCAL lOK := .T.

IF cCusto <> cCCSD1
	If !u_MsgLog("BKESTA03A","Contrato ou C.Custo diferente da Nota e Termo. Continua ?","N")
		lOK := .F.
		Return lOK 
	EndIf
ENDIF

Return lOK 


STATIC FUNCTION GravaNOTAS(aNOTAS)
Local _ix:=0
Local nSCAN:=0

IF LEN(aItemSD3) == 1 
	IF EMPTY(aItemSD3[1,1])
		aItemSD3:= {}
	ENDIF
ENDIF

FOR _ix:=1 TO LEN(aNOTAS)

	IF aNOTAS[_ix,1]

		//                  1        2             3           4           5           6             7            8          9        10       11
		//aItemSD3//    "Item","Cod. Produto","Descrição","Quantidade","Cod. CA","Validade CA","Valor Total",'Nota Fiscal',"Serie","Fornece","Loja" 
		//          1       2        3             4           5                                    6             7            8        9        10       11
		//aNOTAS//"MRK","Item","Cod. Produto","Descrição","Quantidade"                        ,"Valor Total",'Nota Fiscal',"Serie","Fornece","Loja","C.Custo"
	
		nScan:= 0
		nScan:= aScan(aItemSD3,{|x| x[1] == aNOTAS[_ix,2] .AND. x[8] == aNOTAS[_ix,7] .AND. x[9] == aNOTAS[_ix,8] .AND. x[10] == aNOTAS[_ix,9] .AND. x[11] == aNOTAS[_ix,10] })
		IF nScan == 0
			AADD(aItemSD3,{aNOTAS[_ix,2],aNOTAS[_ix,3],aNOTAS[_ix,4],aNOTAS[_ix,5],SPACE(20),CTOD(""),aNOTAS[_ix,6],aNOTAS[_ix,7],aNOTAS[_ix,8],aNOTAS[_ix,9],aNOTAS[_ix,10]})
		ENDIF
	ENDIF

NEXT _ix

oListSD3:SetArray(aItemSD3)
oListSD3:bLine := {|| {	aItemSD3[oListSD3:nAt][1],;
						aItemSD3[oListSD3:nAt][2],;
						aItemSD3[oListSD3:nAt][3],;
						aItemSD3[oListSD3:nAt][4],;
						aItemSD3[oListSD3:nAt][5],;   
						aItemSD3[oListSD3:nAt][6],;                                                     
						TRANSFORM(aItemSD3[oListSD3:nAt][7],"@E 999,999,999.99"),;
						aItemSD3[oListSD3:nAt][8],;
						aItemSD3[oListSD3:nAt][9],;
						aItemSD3[oListSD3:nAt][10],;                                                                                    
						aItemSD3[oListSD3:nAt][11]}}
oListSD3:bLDblClick := {|| EDITCNR2(@aItemSD3),oListSD3:DrawSelect(), }

RETURN NIL


STATIC FUNCTION DTRANSTML(cTermo,dEMISSAO,cMUNIC,cENDEMPR,cCLIENT,cENDCLI,cRESPONS,cCPFRESP,aItens)
LOCAL cTipoTit :="DECLARAÇÃO DE TRANSFERÊNCIA"
Local nHandle   := 0
Local cCrLf     := Chr(13) + Chr(10)
Local cDirTmp   := "C:\TMP"
Local cArqHtml  := ""
Local aHtml     := {}
Local _nI       := 0
Local nPag 		:= 1
Local cDtExtso  := ""

cDtExtso  := cMUNIC+", "+Day2Str(dEMISSAO)+" de "+MesExtenso(Month(dEMISSAO))+" de "+Year2Str(dEMISSAO)+"."

If SM0->M0_CODIGO == "01"      // BK
	cLogo := '<img src="http://www.bkconsultoria.com.br/Imagens/logo_header.png" border=0>'
Endif	


If nPag == 1
	AADD(aHtml,'<html lang="pt-BR">')
	AADD(aHtml,'<head>') 
	AADD(aHtml,'<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">' )
	AADD(aHtml,'<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">' )
	AADD(aHtml,'<title>Declaracao '+TRIM(cTermo)+' - '+DTOC(date())+' '+TIME()+'</title>' )
	AADD(aHtml,'<style type="text/css">')
	AADD(aHtml,'.tg  {border-collapse:collapse;border-spacing:0;margin:auto;}')
	AADD(aHtml,'.tg td{font-family:Arial, sans-serif;font-size:14px;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}')
	AADD(aHtml,'.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}')
	AADD(aHtml,'.tg tr { line-height: 18px; }')
	AADD(aHtml,'.tg .tg-logo{font-weight:bold;font-size:26px;text-align:left;line-height: 40px;}')
	AADD(aHtml,'.tg .tg-empr{font-weight:bold;font-size:26px;text-align:center;line-height: 40px;}')
	AADD(aHtml,'.tg .tg-assin{font-weight:bold;font-size:16px;text-align:center;line-height: 20px;}')
	AADD(aHtml,'.tg .tg-corpo{font-weight:bold;font-size:12px;text-align:justify}')
	AADD(aHtml,'.tg .tg-hndr{font-weight:bold;font-size:12px;background-color:#c0c0c0;text-align:center;vertical-align:top}')
	AADD(aHtml,'.tg .tg-sc{font-size:12px;vertical-align:middle;;text-align:left}')
	AADD(aHtml,'.tg .tg-sc2{font-size:12px;vertical-align:middle;;text-align:center}')
	AADD(aHtml,'.folha {page-break-after:always;page-break-inside:avoid;}')
	AADD(aHtml,'</style>' )
	AADD(aHtml,'</head>' )
	AADD(aHtml,'<body lang=PT-BR>' )
EndIf                                 

AADD(aHtml,'<div class="folha">')

AADD(aHtml,'<table class="tg">')

AADD(aHtml,'<colgroup>')
AADD(aHtml,'<col style="width: 700px">')
AADD(aHtml,'<col style="width: 40px">')
AADD(aHtml,'<col style="width: 40px">')
AADD(aHtml,'</colgroup>')

AADD(aHtml,'    <tr>')

If EMPTY(cLogo)
	AADD(aHtml,'    <td class="tg-logo" colspan="3">'+FWEmpName(cEmpAnt)+'</td>')
Else
	AADD(aHtml,'    <td class="tg-logo" colspan="3">'+cLogo+'</td>')
Endif
  
AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-empr" colspan="3">'+cTipoTit+'</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-corpo" colspan="3">Declaramos a quem interessar possa, que a Empresa '+ALLTRIM(SM0->M0_NOMECOM)+', estabelecida na')
AADD(aHtml,'      '+cENDEMPR+', devidamente inscrita no CNPJ sob o n° '+TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99")+', é isenta de Inscrição Estadual')
AADD(aHtml,'      , portanto desobrigada de emissão de Nota Fiscal, neste ato e através desta Declaração envia para o')
AADD(aHtml,'      '+cCLIENT+', com endereço à Endereço: '+cENDCLI+',o(s) seguinte(s) bem(ns), abaixo discriminado(s) de nossa')
AADD(aHtml,'      propriedade, para (Conserto, uso de nossos colaboradores, etc.) nesta localidade,')
AADD(aHtml,'      sem valor mercantil:</td>')
AADD(aHtml,'    </tr>')

If Len(aItens) > 0
	AADD(aHtml,'    <tr>')
	AADD(aHtml,'      <td class="tg-hndr">Produto</td>')
	AADD(aHtml,'      <td class="tg-hndr">Unidade</td>')
	AADD(aHtml,'      <td class="tg-hndr">Quantidade</td>')
	AADD(aHtml,'    </tr>')

	For _nI := 1 To Len(aItens)
			AADD(aHtml,'  <tr>')
			AADD(aHtml,'    <td class="tg-sc">'+aItens[_nI,1]+'</td>')
			AADD(aHtml,'    <td class="tg-sc2">'+aItens[_nI,2]+'</td>')
			AADD(aHtml,'    <td class="tg-sc2">'+TRANSFORM(aItens[_nI,3],"@E 999.99")+'</td>')
			AADD(aHtml,'  </tr>')
	Next

EndIf

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-assin" colspan="3">&nbsp;<br>'+cDtExtso+'&nbsp;<br>&nbsp;<br>&nbsp;<br>'+cRESPONS+'<br>'+cCPFRESP+'</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'</table>')


AADD(aHtml,'<p class="tg-sc" colspan="3">BK_FM_026 — Versão 01</p>')


AADD(aHtml,'<br>')

AADD(aHtml,'<br>')
AADD(aHtml,'</div>')

AADD(aHtml,'</body>')
AADD(aHtml,'</html>')


IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   

cArqHtml  := cDirTmp+"\"+"DECLARACAO_TRANS_"+ALLTRIM(cTermo)+".HTML"

fErase(cArqHtml)
nHandle := MsfCreate(cArqHtml,0)
If nHandle > 0
	For _nI := 1 TO LEN(aHtml)
		fWrite(nHandle, aHtml[_nI] + cCrLf )
	Next
	fClose(nHandle)
	ShellExecute("open", cArqHtml, "", "", 1)
ENDIF


RETURN NIL
