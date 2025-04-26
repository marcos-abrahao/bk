#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT110TOK
BK - Responsável pela validação da GetDados da Solicitação de Compras
@Return
@author Adilson do Prado
@since 05/04/2016
@version P12
/*/

User Function  MT110TOK()
Local nDATPRF  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_DATPRF'})
Local nEndEnt  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XXENDEN'})
//Local nCC      := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CC'})
//Local nJust    := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XXJUST'})
Local lValido  := .T. 
LOcal aCols1
Local i			as Numeric

//Private cEndEnt := Space(TamSX3("C1_XXENDEN")[1])
Private cCusto  := Space(TamSX3("C1_CC")[1])

aCols1 := aCols

FOR i := 1 TO LEN(aCols)
	IF !EMPTY(dDATPRF)
		aCols[i,nDATPRF] := dDATPRF
	ENDIF
	//aCols[_IX,nCC] := cCC
NEXT

IF dDATPRF <= DA110DATA
	lValido 	:= .F. 
ENDIF

IF !lValido
	u_MsgLog("MT110TOK","Data Limite Entrega deve ser maior que a Emissão","E")
	Return(.F.) 
ENDIF

// 02/04/2025 - Justificativa Obrigatória
IF Empty(cXXJUST)
	u_MsgLog("MT110TOK","Justificativa deve ser preenchida","E")
	Return(.F.) 
ENDIF

IF Empty(cXXENDEN)
	u_MsgLog("MT110TOK","Endereço de entrega não preenchido","E")
	Return(.F.) 
ELSE
	FOR i :=1 TO LEN(aCols)
		aCols[i,nEndEnt] := cXXENDEN
	NEXT
ENDIF

/*
If cEmpAnt <> '20'
	lValido  := BKALTENT()

	FOR i :=1 TO LEN(aCols)
		aCols[i,nEndEnt] := cXXENDEN
	NEXT
EndIf
*/
Return(lValido) 



// Alteração do Endereço de Entrega - Marcos - BK 31/01/17
// Removida em 25/04/2025
Static Function BKALTENT()
Local aArea := Getarea()             

Local oOk
Local oNo
Local oDlg
Local oPanelLeft
Local aButtons := {}
Local lOk      := .F.
Local cTitulo2 := "BKALTENT - Dados complementares - Pedido de Compras"
Local cEndBK   := ALLTRIM(SM0->M0_ENDENT)+" "+Rtrim(SM0->M0_CIDENT)+" - "+SM0->M0_ESTENT+" "+Trans(Alltrim(SM0->M0_CEPENT),PesqPict("SA2","A2_CEP"))
Local cEndCli  := Space(LEN(cXXENDEN))

dbSelectArea("CN9")
If CN9->(dbSeek(xFilial("CN9")+cCC,.F.))
	dbSelectArea("SA1")
	If SA1->(dbSeek(xFIlial("SA1")+CN9->CN9_XCLIEN+CN9->CN9_XLOJA,.F.))
       cEndCli := ALLTRIM(SA1->A1_END)+" "+Rtrim(SA1->A1_MUN)+" - "+SA1->A1_EST+" "+Trans(Alltrim(SA1->A1_CEP),PesqPict("SA1","A1_CEP"))
 	EndIf
EndIf

cEndBK  := PAD(cEndBk,LEN(cXXENDEN))
cEndCli := PAD(cEndCli,LEN(cXXENDEN))
	
oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DO WHILE .T.	
	DEFINE MSDIALOG oDlg TITLE cTitulo2 FROM 000,000 TO 170,450 PIXEL 
		
	@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 220,125  // P12
	oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
	@ 010, 005 BUTTON "Endereço do Contrato:"  SIZE 60,12 OF oPanelLeft PIXEL ACTION (cXXENDEN := cEndCli)
	@ 010, 070 MSGET cEndCli SIZE 150,10 OF oPanelLeft PIXEL HASBUTTON WHEN .F.

	@ 025, 005 BUTTON "Nosso endereço:"  SIZE 60,12 OF oPanelLeft PIXEL ACTION (cXXENDEN := cEndBK)
	@ 025, 070 MSGET cEndBK  SIZE 150,10 OF oPanelLeft PIXEL HASBUTTON WHEN .F.
	
	@ 040, 005 SAY "Endereço de Entrega:"  SIZE 60,12 OF oPanelLeft PIXEL
	@ 040, 070 MSGET cXXENDEN SIZE 200,10  OF oPanelLeft PIXEL HASBUTTON

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , @aButtons)
		
	If ( lOk )
		If !Empty(cXXENDEN)
			EXIT
		Else 
			MsgStop("O endereço de entrega deve ser preenchido")
		EndIf 
	Else
		EXIT
	EndIf
	lOk := .F.
	
ENDDO
		                   
Restarea( aArea )

RETURN lOk
