#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKFINR34
BK - Resumo Diário Contas a Pagar
@Return
@author Marcos Bispo Abrahão
@since 13/11/2023
@version P12
/*/

User Function BKFINR34

Local cDescricao	:= "Objetivo deste relatório é facilitar a operação diária do contas a pagar. "+CRLF+"Solicitado pelo depto Financeiro em novembro de 2023."
Local cVersao 		:= "21/11/2023 - Quebra por Banco"
Local oRExcel		AS Object
Local oPExcel		AS Object

Local cAlias 		:= "QSE2"
Local aFiltros		:= {}
Local cHtml 		:= ""
Local nAbas			:= 0
Local aOpçoes		:= {"1-Completo Web c/ PDF","2-Simples Web", "3-Completo Excel","4-Simples Excel","5-Resumo Excel"} 
Local aImpSel		:= {"Todos","Impressos","Não impressos","Desmarcar Impressão"}
Local aQuebra		:= {"Banco","Forma Pagamento"}
Local nI 			:= 0

Private aParam		:= {}
Private cTitulo		:= "Contas a Pagar - Resumo Diário"
Private cProg		:= "BKFINR34"
Private dDtIni		:= dDataBase
Private dDtFim		:= dDataBase
Private nQuebra		:= 1
Private nFormato	:= 1
Private nImpSel		:= 1
Private aAnexos 	:= {}

aAdd( aParam, { 1, "Data Inicial:" 	, dDataBase		 , ""    , "", ""	, "" , 70  , .T. })
aAdd( aParam, { 1, "Data Final:" 	, dDataBase		 , ""    , "", ""	, "" , 70  , .F. })
aAdd( aParam ,{ 3, "Abas por:"		, 1              , aQuebra               , 100,'.T.',.T.})
aAdd( aParam ,{ 3, "Formato"		, 1              , aOpçoes               , 100,'.T.',.T.})
aAdd( aParam ,{ 3, "Impressão"		, 1              , aImpSel               , 100,'.T.',.T.})

If !BkPar()
	Return Nil
EndIf

u_WaitLog(cProg, {|| ProcGer1() },cTitulo)

QSE2->(dbGoTop())
If QSE2->(EOF())
	u_MsgLog(cProg,"Não foram encontrados titulos a imprimir para esta seleção","I")
	Return Nil
EndIf

If nFormato == 1 .OR. nFormato == 2
	// Completo Web
	u_WaitLog(cProg, {|oSay| cHtml := U_BKFINH34(nFormato,.F.,cEmpAnt,cFilAnt) }, "Listando os Títulos a Pagar")	
	u_WaitLog(cProg, {|oSay| TmpHtml(cHtml,cProg,.T.) }, "Gerando html")	

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

	oPExcel:AddCol("LOTE","IIF(EMPTY(QSE2->LOTE),QSE2->E2_XXORIG,QSE2->LOTE)","Lote","")
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

		u_WaitLog("BKFINR34", {|oSay| aFiltros := Abas() }, "Determinando Abas")

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

			oPExcel:AddCol("LOTE","IIF(EMPTY(QSE2->LOTE),QSE2->E2_XXORIG,QSE2->LOTE)","Lote","")
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
			u_WaitLog("BKFINR34", {|oSay| MarcarTit(nImpSel) }, "Marcando títulos")
		EndIf
	ElseIf nImpSel == 4  // Desmarcar os impressos
		If u_MsgLog(cProg,"Deseja DESMARCAR estes títulos como impressos?","Y")
			u_WaitLog("BKFINR34", {|oSay| MarcarTit(nImpSel) }, "Desmarcando títulos")
		EndIf
	EndIf
EndIf

QSE2->(dbCloseArea())

Return


// Marcar ou desmarcar Titulos como impressos
Static Function MarcarTit(nImpSel)

QSE2->(dbClearFilter())
QSE2->(dbGoTop())

Do While QSE2->(!Eof())

	SE2->(dbGoTo(QSE2->REGSE2))

	RecLock("SE2",.F.)
	If nImpSel == 3
        SE2->E2_XXPRINT := "S"
		u_MsgLog(cProg,cTitulo+" Impressão marcada: "+SE2->E2_NUM)
	Else
        SE2->E2_XXPRINT := "N"
		u_MsgLog(cProg,cTitulo+" Impressão desmarcada: "+SE2->E2_NUM)
	EndIF
	MsUnlock()

	QSE2->(dbSkip())
EndDo

Return NIL



Static Function Abas()
Local aAbas := {}
cAba := ""
QSE2->(dbGoTop())
Do While QSE2->(!Eof())
	If nQuebra == 1
		If aScan(aAbas,QSE2->E2_PORTADO) == 0
			aAdd(aAbas,QSE2->E2_PORTADO)
		EndIf
	Else
		If aScan(aAbas,QSE2->FORMPGT) == 0
			aAdd(aAbas,QSE2->FORMPGT)
		EndIf
	EndIf
	QSE2->(dbSkip())
EndDo
QSE2->(dbGoTop())
Return aAbas



Static Function BkPar
Local aRet		:=	{}
Local lRet := .F.

//   Parambox(aParametros,@cTitle          ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cProg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cProg,.T.         ,.T.))
	lRet := .T.
	dDtIni  := mv_par01
	dDtFim  := mv_par02
	nQuebra := mv_par03
	nFormato:= mv_par04
	nImpSel	:= mv_par05

	cTitulo := cTitulo +" - "+DTOC(dDtIni)+iIf(dDtFim <> dDtIni," até "+DTOC(dDtFim),"")
Endif
Return lRet




Static Function ProcGer1()
Local cQuery
Local cEmpr := cEmpAnt
If SELECT("QSE2") > 0 
	dbSelectArea("QSE2")
   	dbCloseArea()
EndIf

cQuery := "WITH RESUMO AS ( " + CRLF

cQuery += " SELECT "+CRLF
cQuery += "	  '"+cEmpAnt+"' AS EMPRESA"+CRLF
cQuery += "	 ,'"+FWEmpName(cEmpAnt)+"' AS NOMEEMP"+CRLF
cQuery += "	 ,E2_TIPO"+CRLF
cQuery += "	 ,E2_PREFIXO"+CRLF
cQuery += "	 ,E2_NUM"+CRLF
cQuery += "	 ,E2_PARCELA"+CRLF
cQuery += "	 ,E2_FORNECE"+CRLF
cQuery += "	 ,E2_LOJA"+CRLF
cQuery += "	 ,E2_PORTADO"+CRLF
cQuery += "	 ,E2_NATUREZ"+CRLF
cQuery += "	 ,E2_HIST"+CRLF
cQuery += "	 ,E2_XXTIPBK"+CRLF
cQuery += "	 ,E2_XXCTRID"+CRLF
cQuery += "	 ,E2_XXORIG"+CRLF
cQuery += "	 ,E2_USERLGI"+CRLF 
cQuery += "	 ,E2_BAIXA"+CRLF
cQuery += "	 ,E2_VENCREA"+CRLF
cQuery += "	 ,E2_VALOR"+CRLF
cQuery += "	 ,E2_XXPRINT"+CRLF
cQuery += "	 ,E2_XXLOTEB"+CRLF
cQuery += "	 ,E2_NUMBOR"+CRLF
cQuery += "	 ,SE2.R_E_C_N_O_ AS REGSE2"+CRLF
cQuery += "	 ,A2_NOME"+CRLF
cQuery += "	 ,A2_BANCO"+CRLF
cQuery += "	 ,A2_AGENCIA"+CRLF
cQuery += "	 ,A2_NUMCON"+CRLF
cQuery += "	 ,A2_TIPO"+CRLF
cQuery += "	 ,A2_CGC"+CRLF

cQuery += "	 ,(CASE WHEN E2_SALDO = E2_VALOR "+CRLF
cQuery += "	 		THEN E2_VALOR + E2_ACRESC - E2_DECRESC"+CRLF
cQuery += "	 		ELSE E2_SALDO END) AS SALDO"+CRLF


//cQuery += "	 ,"+IIF(dDtIni <> dDtFim,"+' '+E2_VENCREA",'')+"+ "
cQuery += "	 ,(CASE WHEN E2_XTIPOPG <> ' ' "+CRLF
cQuery += "			THEN E2_XTIPOPG "+CRLF
cQuery += "			WHEN (F1_XTIPOPG IS NULL) AND (Z2_BANCO IS NULL) "+CRLF
cQuery += "	 		THEN E2_TIPO+' '+E2_PORTADO"+CRLF
cQuery += "	 		WHEN F1_XTIPOPG IS NULL AND (E2_PORTADO IS NOT NULL) THEN 'LF '+E2_PORTADO+' '+E2_TIPO"+CRLF
cQuery += "	 		ELSE F1_XTIPOPG END)"+" AS FORMPGT"+CRLF

cQuery += "	 ,Z2_NOME"+CRLF
cQuery += "	 ,Z2_NOMMAE"+CRLF
cQuery += "	 ,Z2_NOMDEP"+CRLF
cQuery += "	 ,Z2_BORDERO"+CRLF
cQuery += "	 ,(CASE WHEN (Z2_BANCO IS NOT NULL) AND "+CRLF
cQuery += "	 					(SELECT COUNT(Z2_E2NUM) FROM "+RetSqlName("SZ2")+" SZ2T"+CRLF
cQuery += "	 			    		WHERE SZ2T.D_E_L_E_T_ = ''"+CRLF
cQuery += "	  						AND SZ2T.Z2_FILIAL = ' '"+CRLF
cQuery += "	  	 					AND SZ2T.Z2_CODEMP = '"+cEmpr+"'"+CRLF
cQuery += "	 						AND SE2.E2_PREFIXO = SZ2T.Z2_E2PRF"+CRLF
cQuery += "	 						AND SE2.E2_NUM     = SZ2T.Z2_E2NUM"+CRLF
cQuery += "	 	 					AND SE2.E2_PARCELA = SZ2T.Z2_E2PARC"+CRLF
cQuery += "	 	 					AND SE2.E2_TIPO    = SZ2T.Z2_E2TIPO"+CRLF
cQuery += "	 	 					AND SE2.E2_FORNECE = SZ2T.Z2_E2FORN"+CRLF
cQuery += "	 	 					AND SE2.E2_LOJA    = SZ2T.Z2_E2LOJA) = 1"+CRLF
cQuery += "	 		THEN 'Bco: '+Z2_BANCO+' Ag: '+Z2_AGENCIA+'-'+Z2_DIGAGEN+' C/C: '+Z2_CONTA+'-'+Z2_DIGCONT"+CRLF
cQuery += "	 		ELSE '' END)"+" AS Z2CONTA"+CRLF

cQuery += "	 ,F1_DOC"+CRLF
cQuery += "	 ,(CASE WHEN E2_XTIPOPG <> ' ' THEN E2_XTIPOPG ELSE F1_XTIPOPG END) AS F1_XTIPOPG"+CRLF
cQuery += "	 ,F1_XNUMPA"+CRLF
cQuery += "	 ,F1_XBANCO"+CRLF
cQuery += "	 ,F1_XAGENC"+CRLF
cQuery += "	 ,F1_XNUMCON"+CRLF
cQuery += "	 ,F1_XXTPPIX"+CRLF
cQuery += "	 ,F1_XXCHPIX "+CRLF
cQuery += "	 ,E2_XXPGTO"+CRLF
cQuery += "	 ,E2_XXOPER"+CRLF
cQuery += "	 ,F1_USERLGI"+CRLF 
cQuery += "	 ,F1_XXUSER"+CRLF
cQuery += "	 ,D1_COD"+CRLF
cQuery += "	 ,B1_DESC"+CRLF
cQuery += "	 ,D1_CC"+CRLF
cQuery += "	 ,CTT_DESC01"+CRLF
cQuery += "  ,CONVERT(VARCHAR(800),CONVERT(Binary(800),D1_XXHIST)) AS D1_XXHIST "+CRLF

//cQuery += "	 ,(SELECT TOP 1 Z2_BANCO "+CRLF
//cQuery += "	 	FROM "+RetSqlName("SZ2")+" SZ2"+CRLF
//cQuery += "	 	WHERE SZ2.Z2_FILIAL    = '  '"+CRLF
//cQuery += "	 		AND SZ2.Z2_CODEMP  = '"+cEmpAnt+"' "+CRLF
//cQuery += "	 		AND SE2.E2_PREFIXO = SZ2.Z2_E2PRF"+CRLF
//cQuery += "	 		AND SE2.E2_NUM     = SZ2.Z2_E2NUM "+CRLF
//cQuery += "	 		AND SE2.E2_PARCELA = SZ2.Z2_E2PARC"+CRLF
//cQuery += "	 		AND SE2.E2_TIPO    = SZ2.Z2_E2TIPO"+CRLF
//cQuery += "	 		AND SE2.E2_FORNECE = SZ2.Z2_E2FORN"+CRLF
//cQuery += "	 		AND SE2.E2_LOJA    = SZ2.Z2_E2LOJA"+CRLF
//cQuery += "	 		AND SZ2.Z2_STATUS  = 'S'"+CRLF
//cQuery += "	 		AND SZ2.D_E_L_E_T_ = '') AS Z2_BANCO"+CRLF

cQuery += "	 FROM "+RetSqlName("SE2")+" SE2 "+CRLF

cQuery += "	 LEFT JOIN "+RetSqlName("SF1")+" SF1 ON"+CRLF
cQuery += "	 	SE2.E2_FILIAL      = SF1.F1_FILIAL"+CRLF
cQuery += "	 	AND SE2.E2_NUM     = SF1.F1_DOC "+CRLF
cQuery += "	 	AND SE2.E2_PREFIXO = SF1.F1_SERIE"+CRLF
cQuery += "	 	AND SE2.E2_FORNECE = SF1.F1_FORNECE"+CRLF
cQuery += "	 	AND SE2.E2_LOJA    = SF1.F1_LOJA"+CRLF
cQuery += "	 	AND SF1.D_E_L_E_T_ = ''"+CRLF

cQuery += "	 LEFT JOIN "+RetSqlName("SA2")+"  SA2 ON"+CRLF
cQuery += "	 	SA2.A2_FILIAL      = '  '"+CRLF
cQuery += "	 	AND SE2.E2_FORNECE = SA2.A2_COD"+CRLF
cQuery += "	 	AND SE2.E2_LOJA    = SA2.A2_LOJA"+CRLF
cQuery += "	 	AND SA2.D_E_L_E_T_ = ''"+CRLF

cQuery += " LEFT JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D_E_L_E_T_=''"+ CRLF
cQuery += "   AND D1_FILIAL  = '"+xFilial("SD1")+"' "+ CRLF
cQuery += "   AND D1_DOC     = F1_DOC"+ CRLF
cQuery += "   AND D1_SERIE   = F1_SERIE"+ CRLF
cQuery += "   AND D1_FORNECE = F1_FORNECE"+ CRLF
cQuery += "   AND D1_LOJA    = F1_LOJA"+ CRLF
cQuery += "   AND SD1.R_E_C_N_O_ = "+ CRLF
cQuery += "   	(SELECT TOP 1 R_E_C_N_O_ FROM "+RetSqlName("SD1")+" SD1T "+ CRLF
cQuery += "   	  WHERE SD1T.D_E_L_E_T_     = '' "+ CRLF
cQuery += "   	        AND SD1T.D1_FILIAL  = '"+xFilial("SD1")+"' "+ CRLF
cQuery += "   			AND SD1T.D1_DOC     = F1_DOC"+ CRLF
cQuery += "   			AND SD1T.D1_SERIE   = F1_SERIE"+ CRLF
cQuery += "   			AND SD1T.D1_FORNECE = F1_FORNECE"+ CRLF
cQuery += "   			AND SD1T.D1_LOJA    = F1_LOJA"+ CRLF
cQuery += "		 ORDER BY D1_ITEM)"+ CRLF

cQuery += "	 LEFT JOIN "+RetSqlName("SZ2")+" SZ2 ON SZ2.D_E_L_E_T_=''"+CRLF
cQuery += "	 			AND SZ2.Z2_FILIAL  = ' '"+CRLF
cQuery += "	 	 		AND SZ2.Z2_CODEMP  = '"+cEmpr+"'"+CRLF
cQuery += "	 	 		AND SE2.E2_PREFIXO = SZ2.Z2_E2PRF"+CRLF
cQuery += "	 	 		AND SE2.E2_NUM     = SZ2.Z2_E2NUM "+CRLF
cQuery += "	 	 		AND SE2.E2_PARCELA = SZ2.Z2_E2PARC"+CRLF
cQuery += "	 	 		AND SE2.E2_TIPO    = SZ2.Z2_E2TIPO"+CRLF
cQuery += "	 	 		AND SE2.E2_FORNECE = SZ2.Z2_E2FORN"+CRLF
cQuery += "	 	 		AND SE2.E2_LOJA    = SZ2.Z2_E2LOJA"+CRLF
cQuery += "	 	 		AND SZ2.Z2_STATUS  = 'S'"+CRLF
cQuery += "	 		    AND SZ2.R_E_C_N_O_ = "+CRLF
cQuery += "	    	(SELECT TOP 1 R_E_C_N_O_ FROM "+RetSqlName("SZ2")+" SZ2T "+CRLF
cQuery += "	    	  WHERE SZ2T.D_E_L_E_T_     = ''"+CRLF
cQuery += "	 			AND SZ2T.Z2_FILIAL = ' '"+CRLF
cQuery += "	 	 		AND SZ2T.Z2_CODEMP = '"+cEmpr+"'"+CRLF
cQuery += "	 	 		AND SE2.E2_PREFIXO = SZ2T.Z2_E2PRF"+CRLF
cQuery += "	 	 		AND SE2.E2_NUM     = SZ2T.Z2_E2NUM "+CRLF
cQuery += "	 	 		AND SE2.E2_PARCELA = SZ2T.Z2_E2PARC"+CRLF
cQuery += "	 	 		AND SE2.E2_TIPO    = SZ2T.Z2_E2TIPO"+CRLF
cQuery += "	 	 		AND SE2.E2_FORNECE = SZ2T.Z2_E2FORN"+CRLF
cQuery += "	 	 		AND SE2.E2_LOJA    = SZ2T.Z2_E2LOJA"+CRLF
cQuery += "	 	 		AND SZ2T.Z2_STATUS  = 'S'"+CRLF
cQuery += "	 		 ORDER BY SZ2T.R_E_C_N_O_)"+CRLF

cQuery += "  LEFT JOIN "+RetSqlName("CTT")+" CTT ON CTT.D_E_L_E_T_=''"+CRLF
cQuery += "    AND CTT.CTT_FILIAL = '"+xFilial("CTT")+"' "+CRLF
cQuery += "    AND CTT.CTT_CUSTO  = SD1.D1_CC"+CRLF

cQuery += "  LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.D_E_L_E_T_=''"+CRLF
cQuery += "    AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "+CRLF
cQuery += "    AND SB1.B1_COD    = SD1.D1_COD"+CRLF

cQuery += "	 WHERE SE2.D_E_L_E_T_ = '' "+ CRLF
cQuery +=  "  AND E2_FILIAL = '"+xFilial("SE2")+"' "+CRLF
If dDtIni == dDtFim
	cQuery +=  "  AND E2_VENCREA = '"+DTOS(dDtIni)+"' "+CRLF
Else
	cQuery +=  "  AND E2_VENCREA >= '"+DTOS(dDtIni)+"' "+CRLF
	cQuery +=  "  AND E2_VENCREA <= '"+DTOS(dDtFim)+"' "+CRLF
EndIf
If nFormato > 2
	IF nImpSel = 2      // Somente os já impressos
		cQuery +=  "  AND E2_XXPRINT = 'S' "+CRLF
	ElseIf nImpSel = 3  // Somente os não impressos
		cQuery +=  "  AND E2_XXPRINT <> 'S' "+CRLF
	EndIf
EndIf

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  * " + CRLF
cQuery += "  ,ISNULL(D1_XXHIST,E2_HIST) AS HIST"+CRLF
//cQuery += "  ,ISNULL(Z2_BORDERO,E2_XXLOTEB) AS LOTE"+CRLF
cQuery += "  ,(CASE WHEN ISNULL(Z2_BORDERO,E2_XXLOTEB) = ' ' THEN E2_XXLOTEB ELSE ISNULL(Z2_BORDERO,E2_XXLOTEB) END) AS LOTE"+CRLF

cQuery += "  FROM RESUMO " + CRLF
If nQuebra == 1
	cQuery += " ORDER BY E2_PORTADO,FORMPGT,E2_FORNECE" + CRLF
Else
	cQuery += " ORDER BY FORMPGT,E2_PORTADO,E2_FORNECE" + CRLF
EndIf
//cQuery += "    EMPRESA,E2_VENCREA,FORMPGT " + CRLF

u_LogMemo("BKFINR34.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QSE2"

TCSETFIELD("QSE2","E2_VENCREA","D",8,0)
TCSETFIELD("QSE2","HIST","M",10,0)

Dbselectarea("QSE2")
QSE2->(Dbgotop())

Return nil


User Function BKFINH34(nFormato,lWeb,cEmpresa,cFil)

Local cHtml     := ""
Local nPag      := 1
Local cLogo     := ""
Local nI        := 0
Local cPict     := "@E 99,999,999,999.99"
Local aFiles	:= {}
Local cRefFile	:= ""
Local cFormPgto := ""
Local cPortado 	:= ""
Local dVencto	
Local aTotais	:= {}
Local nTValor	:= 0
Local nTSaldo	:= 0
Local aSM0Data	:= {}

Local aFieldSM0 := { ;
	"M0_CODIGO",;    //Posição [1]
    "M0_CODFIL",;    //Posição [2]
    "M0_NOMECOM",;   //Posição [3]
    "M0_CGC",;       //Posição [4]
    "M0_INSCM",;     //Posição [5]
    "M0_CIDENT",;    //Posição [6]
    "M0_ESTENT",;    //Posição [7]
    "M0_ENDENT",;    //Posição [8]
    "M0_BAIRENT",;   //Posição [9]
    "M0_CEPENT",;    //Posição [10]
    "M0_COMPENT",;   //Posição [11]
    "M0_TEL",;       //Posição [12]
    "M0_NOME";       //Posição [13]
	}
Local cNomeCom  := ""
Local cEndereco := ""
Local cCep      := ""
Local cCidade   := ""
Local cTel      := ""
Local cCnpj     := ""
Local cIE       := ""
Local cSite     := ""
Local cNome 	:= ""

// Variaveis SZ2 - Colaboradores
Local nTot 		:= 0
Local nCont 	:= 0
Local cDescCC	:= ""
Local cAgConta 	:= ""
Local cLinObs 	:= ""
//Local cDesVig 	:= ""

// Variaveis pdf
Local aPdfs 	:= {} // Urls dos PDFs
Local cCanvas	:= ""
Local cScriptPdf:= ""

Default lWeb 	:= .F.

// Dados da Empresa/Filial
aSM0Data  := FWSM0Util():GetSM0Data(cEmpresa, cFil, aFieldSM0)
cNomeCom  := ALLTRIM(aSM0Data[3][2])
cNome	  := ALLTRIM(aSM0Data[13][2])
cEndereco := ALLTRIM(aSM0Data[8][2]) + IIF(!EMPTY(aSM0Data[11][2])," - "+ALLTRIM(aSM0Data[11][2]),"")
cCep      := "CEP: "+TRANSFORM(aSM0Data[10][2],"@R 99999-999")
cCidade   := ALLTRIM(aSM0Data[6][2])+" - "+aSM0Data[7][2]
cTel      := "TEL: "+ALLTRIM(aSM0Data[12][2])
cCnpj     := "CNPJ: "+TRANSFORM(aSM0Data[4][2],"@R 99.999.999/9999-99")
cIE       := "I.E.: "+ALLTRIM(aSM0Data[5][2])
cSite     := IIF(cEmpresa == "01","WWW.BKCONSULTORIA.COM.BR","")

//If cEmpresa == "01"      // BK
	cLogo := u_BKLogos()
//Endif	

If nPag == 1
	cHtml += '<html lang="pt-BR">'+CRLF
	cHtml += '<head>'+CRLF
	//cHtml += '<meta charset="iso-8859-1">'+CRLF
	cHtml += '<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">' +CRLF
	cHtml += '<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">' +CRLF
	cHtml += '<title>Contas a Pagar '+DTOS(date())+' '+TIME()+'</title>' +CRLF
	cHtml += u_BkFavIco()
	cHtml += '<style type="text/css">'+CRLF

	cHtml += '.tg  {border-collapse:collapse;border-spacing:0;margin:auto;}'+CRLF

	cHtml += '.tg td{font-family:Arial, sans-serif;font-size:12px;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}'+CRLF
	cHtml += '.tg th{font-family:Arial, sans-serif;font-size:12px;font-weight:normal;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}'+CRLF

	cHtml += '.tg tr { line-height: 18px; }'+CRLF

	cHtml += '.tg .tg-empr{font-weight:bold;font-size:20px;text-align:center;line-height: 40px;}'+CRLF
	cHtml += '.tg .tg-data{font-weight:bold;font-size:10px;text-align:center}'+CRLF
	cHtml += '.tg .tg-hcliente{font-weight:bold;font-size:10px;background-color:#c0c0c0;vertical-align:top}'+CRLF

	cHtml += '.tg .tg-hndr{font-weight:bold;font-size:10px;background-color:#c0c0c0;text-align:center;vertical-align:top}'+CRLF

	cHtml += '.tg .tg-cliente{font-weight:bold;font-size:12px;vertical-align:top}'+CRLF
	cHtml += '.tg .tg-ndr{font-weight:bold;font-size:12px;text-align:center;vertical-align:top}'+CRLF
	
	cHtml += '.tg .tg-hmens{font-weight:bold;font-size:12px;text-align:center;vertical-align:center;line-height: 30px;background-color:#c0c0c0;}'+CRLF
	cHtml += '.tg .tg-mens{font-weight:bold;font-size:10px;text-align:center;vertical-align:center;line-height: 30px;}'+CRLF

	cHtml += '.tg .tg-hdesc{font-weight:bold;background-color:#c0c0c0;font-size:12px;vertical-align:middle;min-width:300px}'+CRLF
	cHtml += '.tg .tg-desc{font-size:10px;vertical-align:middle;min-width:300px}'+CRLF

	cHtml += '.tg .tg-hrdv{font-weight:bold;background-color:#c0c0c0;font-size:12px;vertical-align:middle;text-align:center}'+CRLF
	cHtml += '.tg .tg-rdv{font-size:10px;vertical-align:middle;text-align:center}'+CRLF

	cHtml += '.tg .tg-hsc{font-weight:bold;background-color:#c0c0c0;font-size:12px;vertical-align:middle;text-align:center}'+CRLF
	cHtml += '.tg .tg-sc{font-size:10px;vertical-align:middle;;text-align:center}'+CRLF
	
	cHtml += '.tg .tg-hvalor{font-weight:bold;background-color:#c0c0c0;font-size:12px;vertical-align:middle;min-width:40px;text-align:center}'+CRLF
	cHtml += '.tg .tg-valor{font-size:10px;vertical-align:middle;min-width:100px;text-align:center;padding-right:10px}'+CRLF
	
	cHtml += '.tg .tg-hobs{font-weight:bold;font-size:10px;background-color:#c0c0c0;text-align:center;vertical-align:top}'+CRLF
	cHtml += '.tg .tg-obs{font-weight:bold;font-size:10px;vertical-align:middle;max-width:200px;text-align:center;}'+CRLF

	cHtml += '.tg .tg-vtotal{font-weight:bold;font-size:12px;vertical-align:middle;min-width:100px;text-align:center;padding-right:10px}'+CRLF

// Tabela de Impostos
	cHtml += '.ti  {border-collapse:collapse;border-spacing:0;width:100%;margin-left:0%;margin-right:0%;}'+CRLF
	cHtml += ''+CRLF
	cHtml += '.ti td{font-family:Arial, sans-serif;font-size:12px;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}'+CRLF
	cHtml += '.ti th{font-family:Arial, sans-serif;font-size:12px;font-weight:normal;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}'+CRLF

	cHtml += '.t1 tr { line-height: 18px; }'+CRLF

	cHtml += '.ti .ti-hvalor{font-weight:bold;background-color:#c0c0c0;font-size:11px;vertical-align:middle;min-width:40px;text-align:center}'+CRLF
	cHtml += '.ti .ti-valor{font-size:10px;vertical-align:middle;min-width:100px;text-align:center;padding-right:10px}'+CRLF
	cHtml += '.ti .ti-str{font-size:8px;vertical-align:middle;line-height:8px;text-align:center}'+CRLF
	
	cHtml += '.folha {page-break-after:always;page-break-inside:avoid;}'+CRLF
	
	// Css para uso com pdfs
	cHtml += u_CssCanvas()

	cHtml += '</style>' +CRLF

	cHtml += '</head>' +CRLF

	// Script para ler pdfs
	cHtml += "#scriptpdf#"

	cHtml += '<body lang=PT-BR>' +CRLF
EndIf                                 


QSE2->(dbGoTop())
DO while QSE2->(!Eof())

	cHtml += '<div class="folha">'+CRLF

	cHtml += '<table class="tg">'+CRLF

	cHtml += '<colgroup>'+CRLF
	cHtml += '<col style="width: 100px">'+CRLF
	cHtml += '<col style="width: 300px">'+CRLF
	cHtml += '<col style="width: 060px">'+CRLF
	cHtml += '<col style="width: 060px">'+CRLF
	cHtml += '<col style="width: 100px">'+CRLF
	cHtml += '<col style="width: 100px">'+CRLF
	cHtml += '<col style="width: 130px">'+CRLF
	cHtml += '</colgroup>'+CRLF

	cHtml += '  <tr>'+CRLF
	cHtml += '  	<td colspan="7">'+CRLF
	cHtml += '  </tr>'+CRLF

	cHtml += '    <tr>'+CRLF

	If EMPTY(cLogo)
		cHtml += '    <td class="tg-empr" colspan="3">'+cNome+'</td>'+CRLF
	Else
		cHtml += '    <td class="tg-empr" colspan="3">'+cLogo+'</td>'+CRLF
	Endif

	cHtml += '      <td class="tg-data" colspan="3" >'+CRLF
	cHtml += '      '+cNomeCom+'<br>'+CRLF
	cHtml += '      '+cEndereco+'<br>'+CRLF
	cHtml += '      '+cCep+" - "+cCidade+'<br>'+CRLF
	cHtml += '      '+cSite+'</td>'+CRLF
	cHtml += '      <td class="tg-data">'+CRLF
	cHtml += '      '+cTel+'<br>'+CRLF
	cHtml += '      '+cCnpj+'<br>'+CRLF
	cHtml += '      '+cIE+'<br>'+CRLF
	cHtml += '      </td>'+CRLF
	cHtml += '    </tr>'+CRLF
	
	cHtml += '    <tr>'+CRLF
	//cHtml += '      <td class="tg-empr" colspan="7">'+cTitulo+'</td>'+CRLF
	cHtml += '      <td class="tg-empr" colspan="7"> Título: '+ALLTRIM(QSE2->E2_PREFIXO)+' '+ALLTRIM(QSE2->E2_NUM)+' '+ALLTRIM(QSE2->E2_PARCELA)+'</td>'+CRLF
	cHtml += '    </tr>'+CRLF

	If nPag == 1
		nPag++

		If nQuebra == 1
			cPortado := QSE2->E2_PORTADO
		Else
			cFormPgto := QSE2->FORMPGT
		EndIf
		dVencto   := QSE2->E2_VENCREA

	EndIF

	cHtml += ' <tr>'+CRLF
	cHtml += '	<td colspan="7">'+CRLF
	cHtml += '    <table class="ti">'+CRLF
	cHtml += '      <colgroup>'+CRLF
	cHtml += '       <col style="width: 230px">'+CRLF
	cHtml += '       <col style="width: 230px">'+CRLF
	cHtml += '       <col style="width: 230px">'+CRLF
	cHtml += '       <col style="width: 230px">'+CRLF
	cHtml += '       <col style="width: 230px">'+CRLF
	cHtml += '       <col style="width: 230px">'+CRLF
	cHtml += '      </colgroup>'+CRLF

	cHtml += '    <tr>'+CRLF
	cHtml += '      <td class="ti-hvalor">Vencimento</td>'+CRLF
	cHtml += '      <td class="ti-hvalor" colspan="2">Fornecedor</td>'+CRLF
	cHtml += '      <td class="ti-hvalor">CNPJ/CPF</td>'+CRLF
	cHtml += '      <td class="ti-hvalor">Valor</td>'+CRLF
	cHtml += '      <td class="ti-hvalor">Saldo</td>'+CRLF
	cHtml += '    <tr>'+CRLF

	cHtml += '    <tr>'+CRLF
	If ValType(QSE2->E2_VENCREA) == "D"
		cHtml += '      <td class="ti-valor">'+DTOC(QSE2->E2_VENCREA)+'</td>'+CRLF
	Else
		cHtml += '      <td class="ti-valor">'+DTOC(STOD(QSE2->E2_VENCREA))+'</td>'+CRLF
	EndIf

	cHtml += '      <td class="ti-valor" colspan="2"> '+ALLTRIM(QSE2->E2_FORNECE)+'-'+ALLTRIM(QSE2->E2_LOJA)+" "+TRIM(QSE2->A2_NOME)+'</td>'+CRLF
	cHtml += '      <td class="ti-valor">'+TRANSFORM(QSE2->A2_CGC,IIF(QSE2->A2_TIPO=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))+'</td>'+CRLF
	cHtml += '      <td class="ti-valor">R$ '+ALLTRIM(TRANSFORM(QSE2->E2_VALOR,cPict))+'</td>'+CRLF
	cHtml += '      <td class="ti-valor">R$ '+ALLTRIM(TRANSFORM(QSE2->SALDO,cPict))+'</td>'+CRLF
	cHtml += '    <tr>'+CRLF

	cHtml += '    <tr>'+CRLF
	cHtml += '      <td class="ti-hvalor">Portador</td>'+CRLF
	cHtml += '      <td class="ti-valor">'+QSE2->E2_PORTADO+'</td>'+CRLF
	cHtml += '      <td class="ti-valor">'+iIf(!EMPTY(QSE2->E2_XXTIPBK),QSE2->FORMPGT,QSE2->E2_TIPO)+'</td>'+CRLF
	cHtml += '      <td class="ti-hvalor">Dados Pgto</td>'+CRLF
	cHtml += '      <td class="ti-valor" colspan="2">'+u_CPDadosPgt('QSE2')+'</td>'+CRLF
	cHtml += '    </tr>'+CRLF

	If !lWeb
		If !Empty(QSE2->D1_COD) .OR. !Empty(QSE2->D1_CC)
			cHtml += '    <tr>'+CRLF
			cHtml += '      <td class="ti-hvalor">Produto</td>'+CRLF
			cHtml += '      <td class="ti-valor" colspan="2">'+TRIM(QSE2->D1_COD)+"-"+TRIM(QSE2->B1_DESC)+'</td>'+CRLF
			cHtml += '      <td class="ti-hvalor">C.Custo</td>'+CRLF
			cHtml += '      <td class="ti-valor" colspan="2">'+TRIM(QSE2->D1_CC)+"-"+TRIM(QSE2->CTT_DESC01)+'</td>'+CRLF
			cHtml += '    </tr>'+CRLF
		EndIf
	EndIf

	If !Empty(QSE2->HIST)
		cHtml += '    <tr>'+CRLF
		cHtml += '      <td class="ti-hvalor">Histórico</td>'+CRLF
		cHtml += '      <td class="ti-valor" colspan="5">'+TRIM(QSE2->HIST)+'</td>'+CRLF
		cHtml += '    </tr>'+CRLF
	EndIf

    If !EMPTY(QSE2->E2_XXTIPBK)

		cHtml += '    <table class="ti">'+CRLF
		cHtml += '    <tr>'+CRLF
		cHtml += '      <td class="ti-hvalor" colspan="7">Tipo de Pagamento: '+u_BKDescRH(QSE2->E2_XXTIPBK)+'</td>'+CRLF
		cHtml += '    </tr>'+CRLF
		cHtml += '    <tr>'+CRLF
		cHtml += '      <td class="ti-hvalor">Prontuário</td>'+CRLF
		cHtml += '      <td class="ti-hvalor">Nome</td>'+CRLF
		cHtml += '      <td class="ti-hvalor">Conta</td>'+CRLF
		cHtml += '      <td class="ti-hvalor">Centro de Custo</td>'+CRLF
		cHtml += '      <td class="ti-hvalor">Usuário</td>'+CRLF
		cHtml += '      <td class="ti-hvalor">Observações</td>'+CRLF
		cHtml += '      <td class="ti-hvalor">Valor</td>'+CRLF
		cHtml += '    </tr>'+CRLF

		ProcSZ2()
		dbSelectArea("QSZ2")
		QSZ2->(dbGoTop())
		nCont := 0
		nTot := 0

		Do While QSZ2->(!EOF())
       
			nCont++

			cHtml += '    <tr>'+CRLF
			cHtml += '      <td class="ti-str">'+TRIM(QSZ2->Z2_PRONT)+'</td>'+CRLF
			cHtml += '      <td class="ti-str">'+TRIM(QSZ2->Z2_NOME)+'</td>'+CRLF

			If TRIM(QSZ2->Z2_TIPO) <> "MFG" // Não sair agencia e conta para tipobk = MFG
				cAgConta := TRIM(QSZ2->Z2_BANCO)
				cAgConta += " "
				cAgConta += TRIM(QSZ2->Z2_AGENCIA)+iIf(!Empty(QSZ2->Z2_DIGAGEN),'/'+TRIM(QSZ2->Z2_DIGAGEN),'')
				cAgConta += " "
				//If lWeb
				//	cAgConta += TRIM(QSZ2->Z2_CONTA)
				//Else
					cAgConta += TRIM(QSZ2->Z2_CONTA)+iIf(!Empty(QSZ2->Z2_DIGCONT),'/'+TRIM(QSZ2->Z2_DIGCONT),'')
				//EndIf
				cHtml += '      <td class="ti-str">'+cAgConta+'</td>'+CRLF
			Else
				cHtml += '      <td class="ti-str">'+'</td>'+CRLF
			EndIf

			cDescCC := ALLTRIM(Posicione("CTT",1,xFilial("CTT")+QSZ2->Z2_CC,"CTT_DESC01"))
			cHtml += '      <td class="ti-str">'+cDescCC+'</td>'+CRLF
			
			cHtml += '      <td class="ti-str">'+Capital(QSZ2->Z2_USUARIO)+'</td>'+CRLF

			cLinObs := ""

			IF TRIM(QSZ2->Z2_TIPO) == "PEN"
				cLinObs += ALLTRIM(IIF(!EMPTY(QSZ2->Z2_NOMMAE),QSZ2->Z2_NOMMAE,QSZ2->Z2_NOMDEP))
			ENDIF
			IF !EMPTY(cLinObs) .and. !EMPTY(QSZ2->Z2_OBSTITU)
				cLinObs += " - "
			ENDIF

			cLinObs += ALLTRIM(QSZ2->Z2_OBSTITU)

			IF QSZ2->Z2_DATAPGT <= QSZ2->Z2_DATAEMI
				cLinObs += " - Aprovado após Horário"
			ENDIF

			cHtml += '      <td class="ti-str">'+cLinObs+'</td>'+CRLF

			//cDesVig := U_Vig2Contrat(TRIM(QSZ2->Z2_CC),QSZ2->Z2_DATAPGT,cEmpAnt)
	          
			//cHtml += '      <td class="ti-str">'+cDesVig+'</td>'+CRLF

			cHtml += '      <td class="ti-valor">'+TRANSFORM(QSZ2->Z2_VALOR,"@ZE 999,999,999.99")+'</td>'+CRLF

			cHtml += '    </tr>'+CRLF

			QSZ2->(DBSKIP())

		EndDo

		cHtml += '    </table>'+CRLF

		QSZ2->(Dbclosearea())
    EndIf   


	// Documentos anexos na Pré-Nota
	aFiles := u_BKDocs(cEmpresa,"SF1",QSE2->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA),1)
	// Documentos anexos no Contas a Pagar
	aFiles := u_BKDocs(cEmpresa,"SE2",QSE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA),1,aFiles)

	cCanvas := ""

	If Len(aFiles) > 0

		cHtml += '  <tr>'+CRLF
		cHtml += '    <td class="ti-hvalor">Anexos</td>'+CRLF
		cHtml += '    <td colspan="5" style="text-align:center;">'+CRLF
		For nI := 1 To Len(aFiles)
			//cRefFile := '    <a href="'+u_BkRest()+'/RestLibPN/v4?empresa='+cEmpresa+'&documento='+Encode64(aFiles[nI,2])+'&tpanexo=P" class="link-primary">'+aFiles[nI,2]+'</a>&nbsp;'+CRLF
			cRefFile := '    <a href="'+u_BkRest()+'/RestLibPN/v4?empresa='+cEmpresa+'&documento='+Encode64(aFiles[nI,2])+'&tpanexo=P" class="link-primary">'+aFiles[nI,2]+'</a>&nbsp;'+CRLF
			If ".PDF" $ UPPER(aFiles[nI,2]) // eRRO AQUI
				aAdd(aPdfs,aFiles[nI,2])
				cCanvas += "<p>"+cRefFile+"</p>"+CRLF
				cCanvas += '<canvas id="the-canvas'+ALLTRIM(STR(Len(aPdfs)))+'"></canvas>'+CRLF
			Else
				cHtml 	 += cRefFile
			EndIf
		Next
		/*
		For nI := 1 To Len(aFilesE2)
			cRefFile := '    <a href="'+u_BkRest()+'/RestLibPN/v4?empresa='+cEmpresa+'&documento='+Encode64(aFilesE2[nI,2])+'&tpanexo=P" class="link-primary">'+aFilesE2[nI,2]+'</a>&nbsp;'+CRLF
			If ".PDF" $ UPPER(aFilesE2[nI,2])
				aAdd(aPdfs,aFilesE2[nI,2])
				cCanvas += "<p>"+cRefFile+"</p>"+CRLF
				cCanvas += '<canvas id="the-canvas'+ALLTRIM(STR(Len(aPdfs)))+'"></canvas>'+CRLF
			Else
				cHtml 	 += cRefFile
			EndIf
		Next
		*/
		cHtml += '    </td>'+CRLF
		cHtml += '  </tr>'+CRLF

		// Embutir PDFs
		If !Empty(cCanvas)
			cHtml += '  <tr>'+CRLF
			cHtml += '   <td colspan="6" style="text-align:center;">'+CRLF
			cHtml += cCanvas+CRLF
			cHtml += '   </td>'+CRLF
			cHtml += '  </tr>'+CRLF
		EndIf

	EndIf

	cHtml += '    </table>'+CRLF
	cHtml += '    <br>'+CRLF


	cHtml += '   </td>'+CRLF
	cHtml += '  </tr>'+CRLF


	nTValor	  += QSE2->E2_VALOR
	nTSaldo   += QSE2->SALDO


	cHtml += '</table>'+CRLF
	cHtml += '</br>'+CRLF
	cHtml += '</div>'+CRLF

	QSE2->(dbSkip())

	If nQuebra == 1
		If cPortado <> QSE2->E2_PORTADO .OR. dVencto <> QSE2->E2_VENCREA .OR. QSE2->(EOF())

			If ValType(dVencto) == "D"
				aAdd(aTotais,{TRIM(cPortado)+' em '+DTOC(dVencto),nTValor,nTSaldo})
			Else'
				aAdd(aTotais,{TRIM(cPortado)+' em '+DTOC(STOD(dVencto)),nTValor,nTSaldo})
			EndIf
			cPortado  := QSE2->E2_PORTADO
			dVencto   := QSE2->E2_VENCREA

			nTValor	  := 0
			nTSaldo   := 0
		EndIf
	Else
		If cFormPgto <> QSE2->FORMPGT .OR. dVencto <> QSE2->E2_VENCREA .OR. QSE2->(EOF())

			If ValType(dVencto) == "D"
				aAdd(aTotais,{TRIM(cFormPgto)+' em '+DTOC(dVencto),nTValor,nTSaldo})
			Else
				aAdd(aTotais,{TRIM(cFormPgto)+' em '+DTOC(STOD(dVencto)),nTValor,nTSaldo})
			EndIF

			cFormPgto := QSE2->FORMPGT
			dVencto   := QSE2->E2_VENCREA

			nTValor	  := 0
			nTSaldo   := 0
		EndIf
	EndIF

EndDo

cHtml += '</table>'+CRLF
cHtml += '<br>'+CRLF

cHtml += '<table class="tg">'+CRLF
nTValor	  := 0
nTSaldo   := 0

cHtml += ' <tr>'+CRLF
cHtml += '   <td class="tg-hvalor colspan="5">TOTAIS '+cNome+'</td>'+CRLF
cHtml += '   <td class="tg-hvalor">VALOR DO TÍTULO</td>'+CRLF
cHtml += '   <td class="tg-hvalor">SALDO ATUAL</td>'+CRLF
cHtml += ' <tr>'+CRLF

For nI := 1 To Len(aTotais)
	cHtml += ' <tr>'+CRLF
	cHtml += '   <td class="tg-hvalor colspan="5">'+TRIM(aTotais[nI,1])+'</td>'+CRLF
	cHtml += '   <td class="tg-valor">R$ '+ALLTRIM(TRANSFORM(aTotais[nI,2],cPict))+'</td>'+CRLF
	cHtml += '   <td class="tg-valor">R$ '+ALLTRIM(TRANSFORM(aTotais[nI,3],cPict))+'</td>'+CRLF
	cHtml += ' <tr>'+CRLF
	nTValor	  += aTotais[nI,2]
	nTSaldo   += aTotais[nI,3]
Next
cHtml += ' <tr>'+CRLF
cHtml += '   <td class="tg-hvalor colspan="5">Total Geral</td>'+CRLF
cHtml += '   <td class="tg-valor">R$ '+ALLTRIM(TRANSFORM(nTValor,cPict))+'</td>'+CRLF
cHtml += '   <td class="tg-valor">R$ '+ALLTRIM(TRANSFORM(nTSaldo,cPict))+'</td>'+CRLF
cHtml += ' <tr>'+CRLF

cHtml += '</table>'+CRLF
cHtml += '<br>'+CRLF


cHtml += '<br>'+CRLF
cHtml += '</div>'+CRLF

cHtml += '</body>'+CRLF
cHtml += '</html>'+CRLF

cScriptPdf := ""
If Len(aPdfs) > 0
	cScriptPdf := u_PdfHtml(cEmpresa,aPdfs)
	cHtml := STRTRAN(cHtml,"#scriptpdf#",cScriptPdf)
EndIf

Return(cHtml)


Static Function ProcSZ2()
Local cQuery
Local cPrefixo := QSE2->E2_PREFIXO
Local cNum     := QSE2->E2_NUM
Local cParcela := QSE2->E2_PARCELA
Local cTipo    := QSE2->E2_TIPO
Local cFornece := QSE2->E2_FORNECE
Local cLoja    := QSE2->E2_LOJA


cQuery := "SELECT ""
cQuery += " Z2_NOME,Z2_PRONT,Z2_BANCO,Z2_AGENCIA,Z2_DATAEMI,Z2_DATAPGT,Z2_DIGAGEN,Z2_CONTA,Z2_DIGCONT,Z2_TIPO,Z2_VALOR,"
cQuery += " Z2_TIPOPES,Z2_CC,Z2_USUARIO,Z2_OBSTITU,Z2_NOMDEP,Z2_NOMMAE "
cQuery += " FROM SZ2010 SZ2"
cQuery += " WHERE Z2_FILIAL = '"+xFilial("SZ2")+"' " 
cQuery += " AND Z2_CODEMP = '"+cEmpAnt+"' "
cQuery += " AND Z2_E2PRF  = '"+cPrefixo+"' "
cQuery += " AND Z2_E2NUM  = '"+cNum+"' "
cQuery += " AND Z2_E2PARC = '"+cParcela+"' "
cQuery += " AND Z2_E2TIPO = '"+cTipo+"' "
cQuery += " AND Z2_E2FORN = '"+cFornece+"' "
cQuery += " AND Z2_E2LOJA = '"+cLoja+"' "
cQuery += " AND Z2_STATUS = 'S'"
cQuery += " AND SZ2.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY Z2_NOME"  

TCQUERY cQuery NEW ALIAS "QSZ2"
TCSETFIELD("QSZ2","Z2_DATAEMI","D",8,0)
TCSETFIELD("QSZ2","Z2_DATAPGT","D",8,0)

Return
