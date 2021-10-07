#Include 'Protheus.ch'

/*/{Protheus.doc} MA103BUT
BK - Ponto de Entrada para adicionar botões no EnchoiceBar do Documento de Entrada

@Return
@author Marcos B Abrahão
@since 31/05/21 
@version P12
/*/

User Function MA103BUT()
Local aButtons  := {}
Local aCabecalho:= {}
Local oLista    as Object
Local oMemo1    as Object
Local oMemo2    as Object
Local nAba
Local aaCampos	:= {"PARC","VENCTO","VALOR"} //Variável contendo o campo editável no Grid
Local cJust     := ""
Local cHist     := ""

Private aDados	:= {}
Private mParcel := ""

If !Inclui
    aadd(aButtons, {'Conhecimento', {|| MsDocument("SF1",SF1->(Recno()),6)}, 'Conhecimento'})

    cJust   := SF1->F1_HISTRET
    cHist   := HistD1()
    mParcel := SF1->F1_XXPARCE

    oFolder:AddItem("Info BK", .T.)
    nAba := Len(oFolder:aDialogs)

    aCabecalho	:= u_a103Cab()
    u_a103Load()

    @ 05,10 SAY 'Parcelas:' OF oFolder:aDialogs[nAba] PIXEL COLOR CLR_RED 
    oLista := MsNewGetDados():New(04, 040, 71, 200, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aACampos,, 99, "U_VldV140()", "", "", oFolder:aDialogs[nAba] , aCabecalho, aDados,"U_VldV140()")
    oLista:Refresh()

    @ 04,220 Get oMemo1 Var cHist Memo Size 180, 60 Of oFolder:aDialogs[nAba] Pixel
    oMemo1:bRClicked := { || AllwaysTrue() }

    @ 04,420 Get oMemo2 Var cJust Memo Size 180, 60 Of oFolder:aDialogs[nAba] Pixel
    oMemo2:bRClicked := { || AllwaysTrue() }

EndIf

Return (aButtons)


Static Function HistD1()
Local cHist := ""
Local aAreaSD1  := GetArea("SD1")

dbSelectArea("SD1") 
dbSetOrder(1)
dbSeek(xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
DO WHILE !EOF() .AND. xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == ; 
	                  SD1->D1_FILIAL+SD1->D1_DOC+ SD1->D1_SERIE+ SD1->D1_FORNECE+ SD1->D1_LOJA

	cHist += IIF(SD1->D1_XXHIST $ cHist,"",SD1->D1_XXHIST) 
	SD1->(dbskip())
Enddo
RestArea(aAreaSD1)
Return cHist



