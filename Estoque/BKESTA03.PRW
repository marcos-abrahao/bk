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
Local 	cFiltra     := "D3_XXCODIG<>''"

Private cCadastro	:= "Inclusão Termo Transferencia / Responsabilidade / Recebimento"
Private cDelFunc	:= ".F." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString 	:= "SD3"
Private aIndexSz  	:= {}
PRIVATE aFixeFX     := {}
Private bFiltraBrw	:= { || FilBrowse(cString,@aIndexSz,@cFiltra) } 
Private aCores  := {}
Private aRotina	:= {}

//u_MsgLog("BKESTA03")

AADD(aCores,{"SD3->D3_XXDOC==''","BR_LARANJAs"})
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


    AADD(aItemSD3,{"","","","","","",0,"","","",""})


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
	
	@ nSnd, 010 LISTBOX oListID FIELDS HEADER "Item","Cod. Produto","Descrição","Quantidade","Cod. CA","Validade CA","Valor Total",'Nota Fiscal',"Serie","Fornece","Loja" SIZE 400,085  OF oPanelLeft PIXEL 
	
	oListID:SetArray(aItemSD3)
	oListID:bLine := {|| {	aItemSD3[oListId:nAt][1],;
							aItemSD3[oListId:nAt][2],;
							aItemSD3[oListId:nAt][3],;
							aItemSD3[oListId:nAt][4],;
							aItemSD3[oListId:nAt][5],;   
							aItemSD3[oListId:nAt][6],;                                                     
							TRANSFORM(aItemSD3[oListId:nAt][7],"@E 999,999,999.99"),;
							aItemSD3[oListId:nAt][8],;
							aItemSD3[oListId:nAt][9],;
							aItemSD3[oListId:nAt][10],;                                                                                    
							aItemSD3[oListId:nAt][11]}}
	
	
	ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

	If ( lOk )
		lOk:=.F.
		//u_WaitLog(cProg, {|| IncluiNF(aItemCC)}, 'Incluido Pré-Documento de Entrada')
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
	ELSE
		cDCLIENT := SPACE(80)
		cDESCTT	 := SPACE(80)
		cGestor  := SPACE(80)
		lOK := .F.
		MSGSTOP("Centro de Custo ou Contrato não Encontrado!", "Atenção" )
	ENDIF
ELSE
	lOK := .T.
ENDIF


RETURN lOK


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
		MSGSTOP("Dados da Notas Fisca não Encontrado!")
		RETURN aNotas
	ENDIF
Endif


oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE "Confirme os itens da Nota Fiscal" FROM 000,000 TO 450,830 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 430,825 
oPanelLeft:Align := CONTROL_ALIGN_LEFT
lAll := .F.
@ 005, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
oAll:bChange := {|| Aeval(aNotas,{|x| x[1]:=lAll}), oListId:Refresh()}

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

oListId:bLDblClick := {|| aNotas[oListId:nAt][1] := ValidaMrk(aNotas[oListId:nAt][1],aCtrId[oListId:nAt][11]), oListId:DrawSelect()}


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

If ( lOk )
    //GravaSe2(aTitGer)
EndIf
Return lOk


Static Function ValidaMrk(lRet,cCCSD1)

IF cCusto <> cCCSD1

If !u_MsgLog(cPerg,"Gerar proximo código de produto?","Y")
	cCod := ""
	Return cCod 
EndIf



Return lRet


