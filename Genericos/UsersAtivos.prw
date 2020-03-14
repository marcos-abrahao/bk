//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

User Function BkAllUsr()
If TYPE("_bkAllUsers") == "U"
	PUBLIC _bkAllUsers := {}
	_bkAllUsers := AllUsers()
EndIf
Return _bkAllUsers


User Function USRCONS(nPosCpo)            
Local oDlg, oPswBrw, oPswCbx, oPswGet, oBtn1, oBtn2
Local cPswGet := Space(6), cPswOrd, aPswOrd := {"Código","Nome"}
Local aHeaders, aColsizes, bLine,  cCaption, nAt := 1
Local cCodigo, lExport := .F.
Local nTop
Local nLeft
Local nBottom
Local nRight
Local lCenter
Local oTopPanel
Local oMainPanel
Local oBtnPanel1
Local oBtnPanel2
Local lBrwPos := .T.
Local cVarRet := ReadVar()
Static aData := {}
Static aPswBrw := {}

If Empty(nPosCpo)
	nPosCpo := 1
EndIf

cCaption := "Usuário"
//aAllusers := {}	
//aAllusers := FWSFALLUSERS()

If EMPTY(aPswBrw)
	//Processa({|| aData := AllUsers(),aEval(aData,{|cVal,nInd| Aadd(aPswBrw,{aData[nInd][1][1],aData[nInd][1][2],If(aData[nInd][1][1] <> "000000",aData[nInd][1][4],""),aData[nInd][1][14]})}) },"Carregando usuários")
	Processa({|| aData := U_BkAllUsr(),aEval(aData,{|cVal,nInd| iif(!aData[nInd][1][17],Aadd(aPswBrw,{aData[nInd][1][1],aData[nInd][1][2],If(aData[nInd][1][1] <> "000000",aData[nInd][1][4],""),aData[nInd][1][14]}),x:=0) }) },"Aguarde...","Carregando usuários")

	//PswOrder(1) 
	//For nI := 1 TO LEN(aAllUsers)
	//	cUser := aAllUsers[nI,2]
	//	PswSeek(cUser) 
	//	aUser  := PswRet(1)
	//	If !aUser[1,17] .AND. aUser[1,1] <> "000000"
	//	   Aadd(aPswBrw,{aUser[1][1],aUser[1][2],aUser[1][4],aUser[1][14]})
	//	EndIf
	//Next

EndIf

aHeaders := { "Código", "Nome", "Nome Completo"}//####
aColSizes := {50,100,100}
bLine := {|| {aPswBrw[oPswBrw:nAt][1],;
	OemToAnsi(aPswBrw[oPswBrw:nAt][2]),;
	OemToAnsi(aPswBrw[oPswBrw:nAt][3])}}

nTop := 0
nLeft := 0
nBottom := 390
nRight := 515
lCenter := .T.

DEFINE MSDIALOG oDlg FROM nTop,nLeft TO nBottom,nRight TITLE "Consulta Padrão - " + OemToAnsi(cCaption) PIXEL OF oMainWnd  

oDlg:SetMinimumSize(515,390)

@00,00 MSPANEL oTopPanel SIZE 250,43
oTopPanel:Align := CONTROL_ALIGN_TOP

@00,00 MSPANEL oMainPanel SIZE 250,39
oMainPanel:Align := CONTROL_ALIGN_ALLCLIENT

@00,00 MSPANEL oBtnPanel1 SIZE 250,15
oBtnPanel1:Align := CONTROL_ALIGN_BOTTOM

@03,03 COMBOBOX oPswCbx VAR cPswOrd ITEMS aPswOrd SIZE 210,36 OF oDlg PIXEL ;
ON CHANGE (If(oPswCbx:nAt==1,cPswGet:=Space(6),cPswGet:=Space(15)),;
aPswBrw := ASort(aPswBrw,,,{|x,y| x[oPswCbx:nAt]<y[oPswCbx:nAt]}),oPswBrw:Refresh(),oPswGet:cText(cPswGet),;
FastSeek(@aPswBrw,cCodigo,1,@oPswBrw))

@17,03 MSGET oPswGet VAR cPswGet SIZE 210,10 OF oDlg PIXEL
oPswGet:bLostFocus := {|| FastSeek(@aPswBrw,@cPswGet,oPswCbx:nAt,@oPswBrw)}

@03,215 BUTTON "Pesquisar" SIZE 40,11 PIXEL OF oTopPanel ; //	
ACTION FastSeek(@aPswBrw,@cPswGet,oPswCbx:nAt,@oPswBrw)

@31,03 CHECKBOX lBrwPos PROMPT "Posicionar no browse na abertura"  SIZE 210,10 PIXEL OF oTopPanel FONT oTopPanel:oFont	//

oPswBrw := TwBrowse():New(10,12,nRight,nBottom,,aHeaders,aColSizes,oMainPanel, , , ,{|| cCodigo := aPswBrw[oPswBrw:nAt][1]},{|| nAt := oPswBrw:nAt,lExport := .T., oDlg:End()}, , , , , , , , ,.T.)
oPswBrw:Align := CONTROL_ALIGN_ALLCLIENT
oPswBrw:SetArray(aPswBrw)
oPswBrw:bLine := bLine

@00,00 MSPANEL oBtnPanel2 SIZE 250,15 OF oBtnPanel1
oBtnPanel2:Align := CONTROL_ALIGN_ALLCLIENT

DEFINE SBUTTON oBtn1 FROM 02,02 TYPE 1 ENABLE OF oBtnPanel2 ACTION (nAt := oPswBrw:nAt,lExport := .T., oDlg:End())
oBtn1:lAutDisable := .f.

DEFINE SBUTTON oBtn2 FROM 02,32 TYPE 2 ENABLE OF oBtnPanel2 ACTION oDlg:End()

If lBrwPos
	oPswBrw:SetFocus()
Else
	oPswGet:SetFocus()
EndIf

oDlg:Activate(,,,lCenter,{|| .T.},,;
{|| oDlg:ReadClientCoors(.T.),oDlg:Cargo := {oDlg:nWidth,oDlg:nHeight},SetKey(15,oBtn1:bAction),;
SetKey(24,oBtn2:bAction),oDlg:bSet15 := oBtn1:bAction,oDlg:bSet24 := oBtn2:bAction},,)
            
If ( lExport )                             
	&(cVarRet) := aPswBrw[nAt][nPosCpo]
EndIf

Return lExport


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GCRUSRF3     ºAutor  ³ Totvs              º Data ³  01/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao de busca de usuario da funcao GCRUSRF3()            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FastSeek(aBrw,cGet,nAt,oBrw)

Local nPos := 0

If (nPos := Ascan(aBrw,{|x| SubStr(x[nAt],1,Len(Trim(cGet)))==Trim(cGet)})) <> 0
	If ( oBrw:nAt <> nPos )
		oBrw:Skip(nPos - oBrw:nAt)
		oBrw:Refresh()
	EndIf
EndIf
Return NIL
