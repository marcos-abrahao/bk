#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR22
BK - Rentabilidade Contratos
@Return
@author Marcos Bispo Abrahão
@since 10/07/2024
@version P12
/*/

User Function BKGCTR22

Local cDescricao	:= "Objetivo deste relatório é a emissão de relatório de acompanhamento das rentabilidades dos contratos "+CRLF+"Solicitado pelo Planejamento em junho de 2024."
Local cVersao 		:= "10/07/24 - Versão inicial"
Local oRExcel		AS Object
Local oPExcel		AS Object

Private aParam		:= {}
Private cTitulo		:= "Rentabilidade Contratos"
Private cProg		:= "BKGCTR22"
Private cContraI    := SPACE(9)
Private cContraF    := SPACE(9)
Private dDtIni		:= dDataBase
Private dDtFim		:= dDataBase
Private nQuebra		:= 1
Private nFormato	:= 1
Private nImpSel		:= 1
Private aAnexos 	:= {}

aAdd( aParam, { 1, "Contrato Inicial:" 	, cContraI	, ""    , "", "CTT"	, "" , 70  , .T. })
aAdd( aParam, { 1, "Contrato Final:" 	, cContraF	, ""    , "", ""	, "" , 70  , .F. })
/*
aAdd( aParam ,{ 3, "Abas por:"		, 1              , aQuebra               , 100,'.T.',.T.})
*/

If BkPar()
	Return Nil
EndIf

u_WaitLog(cProg, {|| PrcPer() },cTitulo)

Return Nil


Static Function BkPar
Local aRet  :=	{}
Local lRet  := .F.

//   Parambox(aParametros,@cTitle          ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cProg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cProg,.T.         ,.T.))
	lRet := .T.
	cContraI  := mv_par01
	cContraF  := mv_par02
Endif
Return lRet


Static Function PrcPer
Local cQuery := ""

cQuery := "SELECT TOP 1" + CRLF
cQuery += "   MIN(CN9_DTOSER) AS CN9_DTOSER" + CRLF
cQuery += "  ,MIN(CN9_DTINIC) AS CN9_DTINIC" + CRLF
cQuery += "  ,MIN(CNF_DTVENC) AS CNF_INICIO" + CRLF
cQuery += "  ,MAX(CNF_DTVENC) AS CNF_FIM" + CRLF
cQuery += "  ,CN9_SITUAC" + CRLF
cQuery += "  ,CN9_REVISA" + CRLF
cQuery += "  ,MAX((SUBSTRING(CNF_COMPET,4,4))+SUBSTRING(CNF_COMPET,1,2))+'01' AS MAXCOMPET" + CRLF
cQuery += " FROM "+RETSQLNAME("CNF")+" CNF" + CRLF
cQuery += " INNER JOIN "+RETSQLNAME("CN9") + " CN9 ON " + CRLF
cQuery += "    CN9_NUMERO = CNF_CONTRA " + CRLF
cQuery += "    AND CN9_REVISA = CNF_REVISA " + CRLF
cQuery += "    AND CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''" + CRLF
cQuery += " WHERE CNF.D_E_L_E_T_=''" + CRLF
cQuery += "    AND CNF_CONTRA ='"+ALLTRIM(cContrato)+"'" + CRLF
cQuery += " GROUP BY CN9_REVISA,CN9_SITUAC" + CRLF
cQuery += " ORDER BY CN9_REVISA DESC" + CRLF

u_LogTxt("BKGCTR22-CNF.SQL",cQuery)

Return Nil




Static Function PrcGct22()
Local nI := 0
Local nAbas := 0

QSE2->(dbGoTop())
If QSE2->(EOF())
	u_MsgLog(cProg,"Não foram encontrados titulos a imprimir para esta seleção","I")
	Return Nil
EndIf

If nFormato == 1 .OR. nFormato == 2
	// Completo Web
	u_WaitLog("BKGCTR22", {|oSay| cHtml := U_BKFINH34(nFormato,.F.,cEmpAnt,cFilAnt) }, "Listando os Títulos a Pagar")	
	u_WaitLog("BKGCTR22", {|oSay| RelHtml(cHtml) }, "Gerando html")	

ElseIf nFormato == 3 .OR. nFormato == 4 .OR. nFormato == 5 

	// Aba Resumo ou Consolidado

	// Definição do Arq Excel
	oRExcel := RExcel():New(cProg)
	oRExcel:SetTitulo(cTitulo)
	oRExcel:SetDescr(cDescricao)
	oRExcel:SetVersao(cVersao)
	oRExcel:SetParam(aParam)

	// Definição da Planilha 1
	oPExcel:= PExcel():New("CONSOLIDADO",cAlias)
	oPExcel:SetTitulo("CONSOLIDADO")
	If nQuebra = 1
		oPExcel:AddResumos("Valor x Portador","E2_PORTADO","E2_VALOR")
		oPExcel:AddResumos("Saldo x Portador","E2_PORTADO","SALDO")
	Else
		oPExcel:AddResumos("Valor x Forma de Pagamento","FORMPGT","E2_VALOR")
		oPExcel:AddResumos("Saldo x Forma de Pagamento","FORMPGT","SALDO")
	EndIf
	// Colunas da Planilha
	oPExcel:AddCol("TITULO","QSE2->E2_PREFIXO+QSE2->E2_NUM+QSE2->E2_PARCELA","Título","")
	oPExcel:GetCol("TITULO"):SetTamCol(15)

	If dDtIni <> dDtFim
		oPExcel:AddColX3("E2_VENCREA")
	EndIf

	oPExcel:AddColX3("A2_NOME")

	oPExcel:AddColX3("E2_VALOR")
	oPExcel:GetCol("E2_VALOR"):SetTotal(.T.)

	oPExcel:AddCol("SALDO","SALDO","Saldo","E2_SALDO")
	oPExcel:GetCol("SALDO"):SetTotal(.T.)

	oPExcel:AddCol("FORMPGT","QSE2->FORMPGT","Forma Pgto","")
	oPExcel:GetCol("FORMPGT"):SetHAlign("C")

	oPExcel:AddColX3("E2_PORTADO")
	oPExcel:GetCol("E2_PORTADO"):SetHAlign("C")

	oPExcel:AddCol("LOTE","QSE2->LOTE","Lote","")
	oPExcel:GetCol("LOTE"):SetHAlign("C")

	oPExcel:AddCol("HIST","QSE2->HIST","Histórico","")
	oPExcel:GetCol("HIST"):SetWrap(.T.)

	oPExcel:AddCol("DADOSPGT","u_CPDadosPgt('QSE2')","Dados Pagamento","")
	oPExcel:GetCol("DADOSPGT"):SetTamCol(40)

	oPExcel:AddCol("XXOPER","UsrRetName(QSE2->E2_XXOPER)","Operador","")
	oPExcel:GetCol("XXOPER"):SetTamCol(20)

	oPExcel:AddCol("STATUS","u_DE2XXPgto(E2_XXPGTO)")
	oPExcel:GetCol("STATUS"):SetTamCol(12)
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'P'}	,"FF0000","",,,.T.)	// Vermelho
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,3) == 'Con'},"008000","",,,.T.)	// Verde
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'E'}	,"FFA500","",,,.T.)	// Laranja
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,3) == 'Com'},"0000FF","",,,.T.)	// Azul
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'D'}	,"000000","",,,.T.)	// Preto
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'L'}	,"8B008B","",,,.T.)	// Dark Magenta
	oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'T'}	,"4B0082","",,,.T.)	// Indigo

	// Adiciona a planilha consolidada
	oRExcel:AddPlan(oPExcel)

	If nFormato <> 5
		// 3-Completo Excel
		// 4-Simples Excel
		// 5-Resumo Excel

		u_WaitLog("BKGCTR22", {|oSay| aFiltros := Abas() }, "Determinando Abas")

		For nAbas := 1 To Len(aFiltros)

			oPExcel:= PExcel():New(aFiltros[nAbas],cAlias)

			If nQuebra == 1 // Se for Banco, quebra por Forma de Pgto nas abas detalhadas, cuidado com a inversão
				oPExcel:AddResumos("Valor x Forma de Pagamento","FORMPGT","E2_VALOR")
				oPExcel:AddResumos("Saldo x Forma de Pagamento","FORMPGT","SALDO")
				oPExcel:SetFiltro("QSE2->E2_PORTADO == '"+aFiltros[nAbas]+"'")
				oPExcel:SetTitulo("Portador: "+aFiltros[nAbas])
			Else
				oPExcel:AddResumos("Valor x Portador","E2_PORTADO","E2_VALOR")
				oPExcel:AddResumos("Saldo x Portador","E2_PORTADO","SALDO")
				oPExcel:SetFiltro("QSE2->FORMPGT == '"+aFiltros[nAbas]+"'")
				oPExcel:SetTitulo("Forma de Pagamento: "+aFiltros[nAbas])
			EndIf


			oPExcel:AddCol("NOMEEMP","QSE2->NOMEEMP","Empresa","")
			oPExcel:GetCol("NOMEEMP"):SetTamCol(30)

			oPExcel:AddCol("FORMPGT","QSE2->FORMPGT","Forma Pgto","")

			oPExcel:AddCol("TITULO","QSE2->E2_PREFIXO+QSE2->E2_NUM+QSE2->E2_PARCELA","Título","")
			oPExcel:GetCol("TITULO"):SetTamCol(15)

			oPExcel:AddColX3("E2_TIPO")

			If dDtIni <> dDtFim
				oPExcel:AddColX3("E2_VENCREA")
			EndIf

			If nFormato == 3
				oPExcel:AddColX3("E2_FORNECE")
				oPExcel:AddColX3("E2_LOJA")
			EndIf

			oPExcel:AddColX3("A2_NOME")

			oPExcel:AddCol("CNPJ","TRANSFORM(QSE2->A2_CGC,IIF(QSE2->A2_TIPO=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))","CNPJ/CPF","")
			oPExcel:GetCol("CNPJ"):SetHAlign("C")
			oPExcel:GetCol("CNPJ"):SetTamCol(21)
			
			oPExcel:AddColX3("E2_NATUREZ")
			oPExcel:GetCol("E2_NATUREZ"):SetHAlign("C")

			oPExcel:AddColX3("E2_PORTADO")
			oPExcel:GetCol("E2_PORTADO"):SetHAlign("C")

			oPExcel:AddCol("LOTE","QSE2->LOTE","Lote","")
			oPExcel:GetCol("LOTE"):SetHAlign("C")

			oPExcel:AddColX3("E2_VALOR")
			oPExcel:GetCol("E2_VALOR"):SetTotal(.T.)

			oPExcel:AddCol("SALDO","QSE2->SALDO","Saldo","E2_SALDO")
			oPExcel:GetCol("SALDO"):SetTotal(.T.)

			oPExcel:AddCol("HIST","QSE2->HIST","Histórico","")
			oPExcel:GetCol("HIST"):SetWrap(.T.)

			oPExcel:AddCol("DADOSPGT","u_CPDadosPgt('QSE2')","Dados Pagamento","")
			oPExcel:GetCol("DADOSPGT"):SetTamCol(40)

			//oPExcel:AddColX3("F1_XNUMPA")
			//oPExcel:AddColX3("F1_XBANCO")
			//oPExcel:AddColX3("F1_XAGENC")
			//oPExcel:AddColX3("F1_XNUMCON")
			//oPExcel:AddColX3("F1_XXTPPIX")
			//oPExcel:AddColX3("F1_XXCHPIX")

			oPExcel:AddCol("XXOPER","UsrRetName(QSE2->E2_XXOPER)","Operador","")
			oPExcel:GetCol("XXOPER"):SetTamCol(20)

			oPExcel:AddCol("RESPONSAVEL","UsrRetName(QSE2->F1_XXUSER)","Responsável","")
			oPExcel:GetCol("RESPONSAVEL"):SetTamCol(20)

			If nFormato == 3
				oPExcel:AddColX3("D1_COD")
				oPExcel:AddColX3("B1_DESC")
				oPExcel:AddColX3("D1_CC")
				oPExcel:AddColX3("CTT_DESC01")
			EndIf

			oPExcel:AddCol("ANEXOS","QSE2->(u_AnexosCP(@aAnexos))","Anexos","")
			oPExcel:GetCol("ANEXOS"):SetTamCol(10)

			For nI := 1 To 10
				oPExcel:AddCol("ANEXO"+STRZERO(nI,2),"IIF(LEN(aAnexos) >= "+STR(nI,2,0)+",aAnexos["+STR(nI,2,0)+"],'')","Anexo "+STRZERO(nI,2),"")
				oPExcel:GetCol("ANEXO"+STRZERO(nI,2)):SetTamCol(30)
				oPExcel:GetCol("ANEXO"+STRZERO(nI,2)):SetTipo("F")
			Next

			If nImpSel == 1
				oPExcel:AddCol("IMPRESSAO","IIF(QSE2->E2_XXPRINT=='S','Sim','Não')","Impressão","")
				oPExcel:GetCol("IMPRESSAO"):SetTamCol(10)
			EndIf

			oRExcel:AddPlan(oPExcel)
		Next
	EndIf

	//U_PlanXlsx(aPlans,cTitulo,cProg,.F.)

	// Cria arquivo Excel
	oRExcel:Create()

EndIf

If nFormato > 2
	If nImpSel == 3  // Marcar como impresso
		If u_MsgLog(cProg,"Deseja MARCAR estes títulos como impressos?","Y")
			u_WaitLog("BKGCTR22", {|oSay| MarcarTit(nImpSel) }, "Marcando títulos")
		EndIf
	ElseIf nImpSel == 4  // Desmarcar os impressos
		If u_MsgLog(cProg,"Deseja DESMARCAR estes títulos como impressos?","Y")
			u_WaitLog("BKGCTR22", {|oSay| MarcarTit(nImpSel) }, "Desmarcando títulos")
		EndIf
	EndIf
EndIf

QSE2->(dbCloseArea())

Return

