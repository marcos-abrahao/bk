/*/{Protheus.doc} MT140TOK
// Validação para evitar NF em duplicaidade.
@author Marcos Bispo Abrahão
@since 11/12/2019
@version 1.0
@return .F. / .T.
@type function
/*/

#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"

User Function MT140TOK()
Local aNfs := {}
Local lRet	:= .T.

	IF !FWIsInCallStack("U_BKFINJ18")

		aNfs := BKMT140QRY()
		
		// Declaração de variaveis
		If LEN(aNfs) > 0
			MsgInfo("Existem Nfs com o mesmo valor para este fornecedor")
			lRet := BK140OK(aNFs)
			If lRet
				If !MsgYesNo("MT140OK","Existem lançamentos para este fornecedor com o mesmo valor, confirma esta Pré-nota assim mesmo?")
					lRet := .F.
				EndIf
			EndIf
		ENDIF

		


	ENDIF

Return lRet



Static Function BK140OK(aNFs)
	Local oDlg
	Local oListId
	Local oPanelLeft
	Local aButtons := {}
	Local lOk      := .F.
	
	DEFINE MSDIALOG oDlg TITLE "Últimas NFs do fornecedor "+CA100FOR+": " FROM 000,000 TO 450,640 PIXEL 
	
	@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 330,225
	oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
	@ 005, 005 LISTBOX oListID FIELDS HEADER "Série","Doc","Data","Valor","Usuário" SIZE 310,185 OF oPanelLeft PIXEL 
	oListID:SetArray(aNfs)
	oListID:bLine := {|| {aNfs[oListId:nAt][1],aNfs[oListId:nAt][2],aNFs[oListId:nAt][3],aNfs[oListId:nAt][4],aNfs[oListId:nAt][5]}}
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

RETURN lOk
	
/*/{Protheus.doc} BKMT140QRY
	(long_description)
	@type  Static Function
	@author Marcos Bispo Abrahão
	@since 11/12/2019
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function BKMT140QRY
Local aRet := {}
Local cQuery := ""
Local dIni   := dDataBase - 60
Local nTotal := A140TOTAL[1]
Local aArea  := GetArea()

//SELECT D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_DTDIGIT,SUM(D1_TOTAL) FROM SD1010 WHERE D1_DTDIGIT >= '20191100'
//AND SD1010.D_E_L_E_T_ <> '*' AND D1_FORNECE ='000001'
//GROUP BY D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_DTDIGIT
//ORDER BY D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_DTDIGIT

	cQuery  := "SELECT D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_DTDIGIT,SUM(D1_TOTAL) AS D1TOTAL FROM "+RETSQLNAME("SD1")+" SD1"
	cQuery  += " WHERE SD1.D_E_L_E_T_='' AND D1_FORNECE='"+CA100FOR+"' AND D1_LOJA='"+CLOJA+"'"
	cQuery  += " AND D1_DTDIGIT >='"+DTOS(dIni)+"'"
	 
	cQuery  += " GROUP BY D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_DTDIGIT"
	cQuery  += " ORDER BY D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_DTDIGIT"
	
	TCQUERY cQuery NEW ALIAS "QSD1"
	
	DbSelectArea("QSD1")
	DbGoTop()
	Do While !eof()
		If QSD1->D1TOTAL = nTotal
			SF1->(dbSetOrder(1))
			SF1->(dbSeek(xFilial("SF1")+QSD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA),.F.))
			AADD(aRet,{QSD1->D1_SERIE,QSD1->D1_DOC,DTOC(STOD(QSD1->D1_DTDIGIT)),TRANSFORM(QSD1->D1TOTAL,"@E 999,999,999.99"),SF1->(FWLeUserlg("F1_USERLGI",1))})
		EndIf
		QSD1->(DbSkip())
	Enddo
	QSD1->(DbCloseArea())

	RestArea(aArea)

Return aRet

