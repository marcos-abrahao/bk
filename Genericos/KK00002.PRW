#include "rwmake.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³KK00002   ºAutor  ³Gilberto Sales      º Data ³  29/04/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pesquisa de produto                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ³Analista/Alterações                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º  /  /    ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function KK00002(_cOrig,_cCpo,_cTipo,_plVenda)
// _cOrig = Produto ou parte da Descrição do Produto
// _cCpo  = Nome da Variável a ser atualizada
// Se _cTipo==1, sempre retorna TRUE
// Se _plVenda, então é para preparar dados conforme necessário para o Call Center

Local _aArea	:= GetArea()
Local _aAux 	:= {}
Local _nContador:= 0
Local _nConta2	:= 0
Local _lContinua:= .T.

Private _aCodigos := {}
Private _cOrigem := _cOrig
Private _cCampo := _cCpo
Private _lNaoCheca := .F.
Private _lVenda := IIf(_plVenda==NIL,.F.,_plVenda)


If Type("l120auto") == "L"
	If l120auto
		_lNaoCheca := .T.
	EndIf
EndIf

If Type("l103auto") == "L"
	If l103auto
		_lNaoCheca := .T.
	EndIf
EndIf

If Type("l140auto") == "L"
	If l140auto
		_lNaoCheca := .T.
	EndIf
EndIf

If Type("xRotAut") == "L"
	If xRotAut
		_lNaoCheca := .T.
	EndIf
EndIf

If Type("l410auto") == "L"
	If l410auto
		_lNaoCheca := .T.
	EndIf
EndIf

If  funname() == 'MATA241'   // Movimento Interno
	_lNaoCheca := .T.
EndIf

_lContinua := .T.

If !_lNaoCheca
	// Vai pesquisar o código no SB1
	If Len(AllTrim(_cOrig))>0
		//posiciona o vendedor para identificar o segmento
		If _lVenda .and. (ReadVar()=="M->CNB_PRODUT") //Contratos
			//Monta a query de pesquisa de produto
			_cQuery := "SELECT B1_COD,B1_DESC,B1_UM AS UNI  "
			_cQuery += "FROM "+RetSqlName("SB1")+" (NOLOCK) "
			_cQuery += "WHERE "+RetSqlName("SB1")+".D_E_L_E_T_ <> '*' "
			_cQuery += "AND B1_FILIAL = '"+xFilial("SB1")+"' "
			_cQuery += "AND B1_TIPO = 'MO' "
			_cOrigem := AllTrim(_cOrigem)
			_cQuery += "AND (B1_COD LIKE '%"+_cOrigem+"%' OR B1_DESC LIKE '%"+replace(_cOrigem,'[','%')+"%' ) "
			_cQuery += "GROUP BY B1_COD,B1_DESC,B1_PRV1,B1_UM "
			_cQuery += "ORDER BY B1_DESC "
	
			_aCodigos := U_KK00001(_cQuery)
		EndIf

		_cAux1 := "{'Código','Descrição','Unidade'}"

		_aCabec := &_cAux1

		//Formata os dados que serão apresentados
		If !_lVenda
			_cAux1 	:= ""
			_aAux	:= {}
			For _nContador := 1 To Len(_aCodigos)
				_nConta2++
				Aadd(_aAux,{_aCodigos[_nContador][1]}) //codigo
				Aadd(_aAux[_nConta2],_aCodigos[_nContador][2]) //descrição
				Aadd(_aAux[_nConta2],_aCodigos[_nContador][3]) //Unidade
			Next
			_aCodigos := aClone(_aAux)
		EndIf

		// Monta Diálogo
		If  funname()  <>  'MATA241'
			If Len(_aCodigos)<=0
				MsgBox("Nenhum Código Encontrado!!!", "Atenção")
				_lContinua := .F.
			EndIf
		EndIf

		If _lContinua
			oDlg := MSDIALOG():Create()
			oDlg:cName := "oDlg"
			oDlg:cCaption := "Produtos Semelhantes por Descrição"
			oDlg:nLeft := 0
			oDlg:nTop := 0
			oDlg:nWidth := 700
			oDlg:nHeight := 500
			oDlg:lShowHint := .T.
			oDlg:lCentered := .T.

			oPesq := RdListBox(0,0,341,210,_aCodigos,_aCabec)
			oPesq:nLeft := 6
			oPesq:nTop := 6
			oPesq:lColDrag := .F.
			oPesq:lJustific := .T.
			oPesq:lAdjustColSize := .T.
			oPesq:lVisibleControl := .T.
			oPesq:bLDblClick := {|| PPDFecha() }

			oSair := SBUTTON():Create(oDlg)
			oSair:cName := "oSair"
			oSair:nLeft := 640
			oSair:nTop := 440
			oSair:nWidth := 52
			oSair:nHeight := 22
			oSair:lShowHint := .F.
			oSair:lReadOnly := .F.
			oSair:Align := 0
			oSair:lVisibleControl := .T.
			oSair:nType := 1
			oSair:bAction := {|| PPDFecha() }

			oDlg:Activate()
		EndIf
		
		If _cTipo == 1
			_lContinua := .T.
		EndIf
	EndIf
EndIf

RestArea(_aArea)

Return _lContinua

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PPDFecha  ºAutor  ³Gilberto Sales      º Data ³  29/04/2008 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PPDFecha()

If oPesq:nAt > 0
	If _lVenda
		_cOrigem:=_aCodigos[oPesq:nAt][1]
		&("M->"+_cCampo) := aClone(_aCodigos[oPesq:nAt])
	Else
		_cOrigem:=_aCodigos[oPesq:nAt][1]
		&("M->"+_cCampo) := _aCodigos[oPesq:nAt][1]
	EndIf
EndIf
oDlg:End()
Return
