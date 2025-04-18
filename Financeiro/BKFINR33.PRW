#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKFINR33
BK - RESUMO DI�RIO
@Return
@author Marcos Bispo Abrah�o
@since 11/10/2023
@version P12
/*/

User Function BKFINR33

Local aCabs			:= {}
Local aCampos		:= {}
Local aResumo 		:= {}
Local aFiltros		:= {}
Local nColVal1		:= 0
Local nColVal2		:= 0
Local nColUnq1		:= 0

Local aCabsC		:= {}
Local aCamposC		:= {}
Local aResumoC 		:= {}
Local nColValC1		:= 0
Local nColValC2		:= 0
Local nColUnqC		:= 0


Local aPlans		:= {}
Local cHtml 		:= ""
Local nAbas			:= 0
Local aOp�oes		:= {"1-Completo Web","2-Simples Web", "3-Completo Excel","4-Simples Excel","5-Resumo Excel"} 
Local aImpSel		:= {"Todos","Impressos","N�o impressos","Desmarcar Impress�o"} 
Local nI 			:= 0

Private aParam		:= {}
Private cTitulo		:= "Contas a Pagar - Resumo Di�rio"
Private cPerg		:= "BKFINR33"
Private dDtIni		:= dDataBase
Private dDtFim		:= dDataBase
Private nFormato	:= 1
Private nImpSel		:= 1
Private aAnexos 	:= {}


aAdd( aParam, { 1, "Data Inicial:" 	, dDataBase		 , ""    , "", ""	, "" , 70  , .T. })
aAdd( aParam, { 1, "Data FInal:" 	, dDataBase		 , ""    , "", ""	, "" , 70  , .F. })
aAdd( aParam ,{ 3, "Formato"		, 1              , aOp�oes               , 100,'.T.',.T.})
aAdd( aParam ,{ 3, "Impress�o"		, 1              , aImpSel               , 100,'.T.',.T.})

If !BkPar()
	Return Nil
EndIf

u_WaitLog(cPerg, {|| ProcGer1() },cTitulo)

QSE2->(dbGoTop())
If QSE2->(EOF())
	u_MsgLog(cPerg,"N�o foram encontrados titulos a imprimir para esta sele��o","I")
	Return Nil
EndIf

If nFormato == 1 .OR. nFormato == 2
	// Completo Web
	u_WaitLog("BKFINR33", {|oSay| cHtml := CPHtml(nFormato) }, "Listando T�tulos a Pagar")	
	u_WaitLog("BKFINR33", {|oSay| RelHtml(cHtml) }, "Gerando html")	

ElseIf nFormato == 3 .OR. nFormato == 4 .OR. nFormato == 5 

	// Aba Resumo ou Consolidaddo
	aCabsC   := {}
	aCamposC := {}
	aResumoC := {}

	AADD(aCamposC,"QSE2->E2_PREFIXO+QSE2->E2_NUM+QSE2->E2_PARCELA")
	AADD(aCabsC  ,"T�tulo")

	If dDtIni <> dDtFim
		AADD(aCampos,"QSE2->E2_VENCREA")
		AADD(aCabs  ,"Vencimento")
	EndIf

	AADD(aCamposC,"QSE2->A2_NOME")
	AADD(aCabsC  ,"Raz�o Social")

	AADD(aCamposC,"QSE2->E2_VALOR")
	AADD(aCabsC  ,"Valor")
	nColValC1 := LEN(aCabsC)

	AADD(aCamposC,"QSE2->SALDO")
	AADD(aCabsC  ,"Saldo")
	nColValC2 := LEN(aCabsC)

	AADD(aCamposC,"QSE2->FORMPGT")
	AADD(aCabsC  ,"Forma pgto")
	nColUnqC := LEN(aCabsC)

	AADD(aCamposC,"QSE2->E2_PORTADO")
	AADD(aCabsC  ,"Portador")

	AADD(aCamposC,"QSE2->HIST")
	AADD(aCabsC  ,"Hist�rico")

	AADD(aResumoC,{nColUnqC,nColValC1,{}})  // Resumo por forma de pagto - Valor
	AADD(aResumoC,{nColUnqC,nColValC2,{}})  // Resumo por forma de pagto - Saldo

	AADD(aPlans,{"QSE2","Consolidado","",cTitulo,aCamposC,aCabsC,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, aResumoC, lClose:= .F. })

	If nFormato <> 5
		// 3-Completo Excel
		// 4-Simples Excel
		// 5-Resumo Excel

		aCabs   := {}
		aCampos := {}
		aResumo := {}

		//AADD(aCampos,"QSE2->EMPRESA")
		//AADD(aCabs  ,"C�digo")

		AADD(aCampos,"QSE2->NOMEEMP")
		AADD(aCabs  ,"Empresa")

		AADD(aCampos,"QSE2->FORMPGT")
		AADD(aCabs  ,"Forma pgto")
		nColUnq1 := LEN(aCabs)

		AADD(aCampos,"QSE2->E2_PREFIXO+QSE2->E2_NUM+QSE2->E2_PARCELA")
		AADD(aCabs  ,"T�tulo")

		AADD(aCampos,"QSE2->E2_TIPO")
		AADD(aCabs  ,"Tipo")

		If dDtIni <> dDtFim
			AADD(aCampos,"QSE2->E2_VENCREA")
			AADD(aCabs  ,"Vencimento")
		EndIf

		If nFormato == 3

			//AADD(aCampos,"QSE2->E2_PREFIXO")
			//AADD(aCabs  ,"Prefixo")

			//AADD(aCampos,"QSE2->E2_NUM")
			//AADD(aCabs  ,"T�tulo")

			//AADD(aCampos,"QSE2->E2_PARCELA")
			//AADD(aCabs  ,"Parcela")

			AADD(aCampos,"QSE2->E2_FORNECE")
			AADD(aCabs  ,"Fornecedor")

			AADD(aCampos,"QSE2->E2_LOJA")
			AADD(aCabs  ,"Loja")
		EndIf

		AADD(aCampos,"QSE2->A2_NOME")
		AADD(aCabs  ,"Raz�o Social")

		AADD(aCampos,"TRANSFORM(QSE2->A2_CGC,IIF(QSE2->A2_TIPO=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))")
		AADD(aCabs  ,"CNPJ/CPF")

		AADD(aCampos,"QSE2->E2_NATUREZ")
		AADD(aCabs  ,"Natureza")

		AADD(aCampos,"QSE2->E2_PORTADO")
		AADD(aCabs  ,"Portador")

		AADD(aCampos,"QSE2->E2_VALOR")
		AADD(aCabs  ,"Valor")
		nColVal1 := LEN(aCabs)

		AADD(aCampos,"QSE2->SALDO")
		AADD(aCabs  ,"Saldo")
		nColVal2 := LEN(aCabs)

		AADD(aCampos,"QSE2->HIST")
		AADD(aCabs  ,"Hist�rico")

		AADD(aCampos,"QSE2->F1_XNUMPA")
		AADD(aCabs  ,"PA")

		AADD(aCampos,"QSE2->F1_XBANCO")
		AADD(aCabs  ,"Banco")

		AADD(aCampos,"QSE2->F1_XAGENC")
		AADD(aCabs  ,"Ag�ncia")

		AADD(aCampos,"QSE2->F1_XNUMCON")
		AADD(aCabs  ,"Conta")

		AADD(aCampos,"QSE2->F1_XXTPPIX")
		AADD(aCabs  ,"Pix")

		AADD(aCampos,"QSE2->F1_XXCHPIX")
		AADD(aCabs  ,"Chave Pix")

		AADD(aCampos,"QSE2->(u_AnexosCP(@aAnexos))")
		AADD(aCabs  ,"Anexos")

		AADD(aCampos,"UsrRetName(QSE2->F1_XXUSER)")
		AADD(aCabs  ,"Respons�vel")

		If nFormato == 3

			AADD(aCampos,"QSE2->D1_COD")
			AADD(aCabs  ,"C�digo")

			AADD(aCampos,"QSE2->B1_DESC")
			AADD(aCabs  ,"Produto")

			AADD(aCampos,"QSE2->D1_CC")
			AADD(aCabs  ,"Centro de Custo")

			AADD(aCampos,"QSE2->CTT_DESC01")
			AADD(aCabs  ,"Descri��o CC")
		EndIf

		For nI := 1 To 10
			AADD(aCampos,"IIF(LEN(aAnexos) >= "+STR(nI,2,0)+",aAnexos["+STR(nI,2,0)+"],'')")
			AADD(aCabs  ,"Anexo "+STR(nI,2,0))
		Next

		If nImpSel == 1
			AADD(aCampos,"IIF(QSE2->E2_XXPRINT=='S','Sim','N�o')")
			AADD(aCabs  ,"Impress�o")
		EndIf

		//AADD(aCampos,"QSE2->REGSE2")
		//AADD(aCabs  ,"Registro E2")

		AADD(aResumo,{nColUnq1,nColVal1,{}})  // Resumo por forma de pagto - Valor
		AADD(aResumo,{nColUnq1,nColVal2,{}})  // Resumo por forma de pagto - Saldo

		u_WaitLog("BKFINR33", {|oSay| aFiltros := Abas() }, "Determinando Abas")

		For nAbas := 1 To Len(aFiltros)
			AADD(aPlans,{"QSE2",aFiltros[nAbas],"QSE2->FORMPGT == '"+aFiltros[nAbas]+"'",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, aResumo, lClose:= .F. })
		Next
	EndIf

	U_PlanXlsx(aPlans,cTitulo,cPerg,.F.)

EndIf

If nFormato > 2
	If nImpSel == 3  // Marcar como impresso
		If u_MsgLog(cPerg,"Deseja MARCAR estes t�tulos como impressos?","Y")
			u_WaitLog("BKFINR33", {|oSay| MarcarTit(nImpSel) }, "Marcando t�tulos")
		EndIf
	ElseIf nImpSel == 4  // Desmarcar os impressos
		If u_MsgLog(cPerg,"Deseja DESMARCAR estes t�tulos como impressos?","Y")
			u_WaitLog("BKFINR33", {|oSay| MarcarTit(nImpSel) }, "Desmarcando t�tulos")
		EndIf
	EndIf
EndIf

QSE2->(DBCLOSEAREA())

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
		u_MsgLog(cPerg,cTitulo+" Impress�o marcada: "+SE2->E2_NUM)
	Else
        SE2->E2_XXPRINT := "N"
		u_MsgLog(cPerg,cTitulo+" Impress�o desmarcada: "+SE2->E2_NUM)
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
	//If Len(aAbas) = 0
	//	cAbas := QSE2->FORMPGT
	//	aAdd(aAbas,QSE2->FORMPGT)
	//EndIf
	If aScan(aAbas,QSE2->FORMPGT) == 0
		aAdd(aAbas,QSE2->FORMPGT)
	EndIf
	QSE2->(dbSkip())
EndDo
QSE2->(dbGoTop())
Return aAbas



Static Function BkPar
Local aRet		:=	{}
Local lRet := .F.

//   Parambox(aParametros,@cTitle          ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg,.T.         ,.T.))
	lRet := .T.
	dDtIni  := mv_par01
	dDtFim  := mv_par02
	nFormato:= mv_par03
	nImpSel	:= mv_par04

	cTitulo := cTitulo +" - "+DTOC(dDtIni)+iIf(dDtFim <> dDtIni," at� "+DTOC(dDtFim),"")
Endif
Return lRet




Static Function ProcGer1()
Local cQuery

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
cQuery += "	 ,E2_PORTADO"+CRLF
cQuery += "	 ,E2_LOJA"+CRLF
cQuery += "	 ,E2_NATUREZ"+CRLF
cQuery += "	 ,E2_HIST"+CRLF
cQuery += "	 ,E2_USERLGI"+CRLF 
cQuery += "	 ,E2_BAIXA"+CRLF
cQuery += "	 ,E2_VENCREA"+CRLF
cQuery += "	 ,E2_VALOR"+CRLF
cQuery += "	 ,E2_XXPRINT"+CRLF
cQuery += "	 ,SE2.R_E_C_N_O_ AS REGSE2"+CRLF
cQuery += "	 ,A2_NOME"+CRLF
cQuery += "	 ,A2_TIPO"+CRLF
cQuery += "	 ,A2_CGC"+CRLF

cQuery += "	 ,(CASE WHEN E2_SALDO = E2_VALOR "+CRLF
cQuery += "	 		THEN E2_VALOR + E2_ACRESC - E2_DECRESC"+CRLF
cQuery += "	 		ELSE E2_SALDO END) AS SALDO"+CRLF

cQuery += "	 ,(CASE WHEN E2_XTIPOPG <> ' ' "+CRLF
cQuery += "			THEN E2_XTIPOPG "+CRLF
cQuery += "			WHEN (F1_XTIPOPG IS NULL) AND (Z2_BANCO IS NULL) "+CRLF
cQuery += "			THEN E2_TIPO+' '+E2_PORTADO"+CRLF
cQuery += "	 		WHEN F1_XTIPOPG IS NULL AND (E2_PORTADO IS NOT NULL) THEN 'LF '+E2_PORTADO+' '+E2_TIPO"+CRLF
cQuery += "	 		ELSE F1_XTIPOPG END)"+" AS FORMPGT"+CRLF

cQuery += "	 ,F1_DOC"+CRLF
cQuery += "	 ,F1_XTIPOPG"+CRLF
cQuery += "	 ,F1_XNUMPA"+CRLF
cQuery += "	 ,F1_XBANCO"+CRLF
cQuery += "	 ,F1_XAGENC"+CRLF
cQuery += "	 ,F1_XNUMCON"+CRLF
cQuery += "	 ,F1_XXTPPIX"+CRLF
cQuery += "	 ,F1_XXCHPIX "+CRLF
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
cQuery += "	 	 		AND SZ2.Z2_CODEMP  = '01' "+CRLF
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
cQuery += "	 	 		AND SZ2T.Z2_CODEMP = '01' "+CRLF
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
	IF nImpSel = 2      // Somente os j� impressos
		cQuery +=  "  AND E2_XXPRINT = 'S' "+CRLF
	ElseIf nImpSel = 3  // Somente os n�o impressos
		cQuery +=  "  AND E2_XXPRINT <> 'S' "+CRLF
	EndIf
EndIf

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  * " + CRLF
cQuery += "  ,ISNULL(D1_XXHIST,E2_HIST) AS HIST"+CRLF
cQuery += "  FROM RESUMO " + CRLF
cQuery += " ORDER BY FORMPGT" + CRLF
//cQuery += "    EMPRESA,E2_VENCREA,FORMPGT " + CRLF

u_LogMemo("BKFINR33.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QSE2"

TCSETFIELD("QSE2","E2_VENCREA","D",8,0)
TCSETFIELD("QSE2","HIST","M",10,0)

Dbselectarea("QSE2")
QSE2->(Dbgotop())

Return nil



Static Function RelHtml(cHtml) 
Local aArea     := GetArea()
Local aAreaSE2  := GetArea("SE2")
//Local nHandle   := 0
Local cDirTmp   := u_LTmpDir()
Local cArqHtml  := ""
//Local _nI       := 0

cArqHtml  := cDirTmp+"CP"+DTOS(dDataBase)+".HTML"

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   

fErase(cArqHtml)
//nHandle := MsfCreate(cArqHtml,0)
//If nHandle > 0
	//cHtml := CPHtml()
	//For _nI := 1 TO LEN(aHtml)
	//	fWrite(nHandle, aHtml[_nI] + cCrLf )
	//Next
	//fClose(nHandle)
	Memowrite(cArqHtml,cHtml)
	ShellExecute("open", cArqHtml, "", "", 1)
//EndIf
SE2->(RestArea(aAreaSE2))
RestArea(aArea)
Return


Static Function CPHtml(nFormato)
Local cHtml     := ""
Local nPag      := 1
Local cLogo     := ""
Local nI        := 0
Local cPict     := "@E 99,999,999,999.99"
Local aFilesF1  := {}
Local aFilesE2  := {}
Local cTipoTit  := cTitulo
Local cFormPgto := ""
Local dVencto	:= CTOD("")
Local aTotais	:= {}
Local nTValor	:= 0
Local nTSaldo	:= 0

// Dados da Empresa/Filial
Local cNomeCom  := ALLTRIM(SM0->M0_NOMECOM)
Local cEndereco := ALLTRIM(SM0->M0_ENDENT) + IIF(!EMPTY(SM0->M0_COMPENT)," - "+ALLTRIM(SM0->M0_COMPENT),"")
Local cCep      := "CEP: "+TRANSFORM(SM0->M0_CEPENT,"@R 99999-999")
Local cCidade   := ALLTRIM(SM0->M0_CIDENT)+" - "+SM0->M0_ESTENT
Local cTel      := "TEL: "+ALLTRIM(SM0->M0_TEL)
Local cCnpj     := "CNPJ: "+TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99")
Local cIE       := "I.E.: "+ALLTRIM(SM0->M0_INSC)
Local cSite     := IIF(cEmpAnt == "01","WWW.BKCONSULTORIA.COM.BR","")

//If cEmpAnt == "01"      // BK
	cLogo := u_BKLogos()
//Endif	

If nPag == 1
	cHtml += '<html lang="pt-BR">'+CRLF
	cHtml += '<head>'+CRLF
	//cHtml += '<meta charset="iso-8859-1">'+CRLF
	cHtml += '<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">' +CRLF
	cHtml += '<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">' +CRLF
	cHtml += '<title>Contas a Pagar '+DTOS(date())+' '+TIME()+'</title>' +CRLF
	cHtml += '<style type="text/css">'+CRLF

	cHtml += '.tg  {border-collapse:collapse;border-spacing:0;margin:auto;}'+CRLF
	cHtml += ''+CRLF
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

	cHtml += '.ti .ti-hvalor{font-weight:bold;background-color:#c0c0c0;font-size:12px;vertical-align:middle;min-width:40px;text-align:center}'+CRLF
	cHtml += '.ti .ti-valor{font-size:10px;vertical-align:middle;min-width:100px;text-align:center;padding-right:10px}'+CRLF
	cHtml += '.tg .ti-str{font-size:10px;vertical-align:middle;;text-align:center}'+CRLF
	
	cHtml += '.folha {page-break-after:always;page-break-inside:avoid;}'+CRLF
	
	cHtml += '</style>' +CRLF
	cHtml += '</head>' +CRLF
	cHtml += '<body lang=PT-BR>' +CRLF
EndIf                                 

cHtml += '<div class="folha">'+CRLF

cHtml += '<table class="tg">'+CRLF

cHtml += '<colgroup>'+CRLF
cHtml += '<col style="width: 100px">'+CRLF
cHtml += '<col style="width: 300px">'+CRLF
cHtml += '<col style="width: 060px">'+CRLF
cHtml += '<col style="width: 060px">'+CRLF
cHtml += '<col style="width: 100px">'+CRLF
cHtml += '<col style="width: 100px">'+CRLF
cHtml += '<col style="width: 120px">'+CRLF
cHtml += '</colgroup>'+CRLF

cHtml += '  <tr>'+CRLF
cHtml += '  	<td colspan="7">'+CRLF
cHtml += '  </tr>'+CRLF

cHtml += '    <tr>'+CRLF

If EMPTY(cLogo)
	cHtml += '    <td class="tg-empr" colspan="3">'+FWEmpName(cEmpAnt)+'</td>'+CRLF
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
cHtml += '      <td class="tg-empr" colspan="7">'+cTipoTit+'</td>'+CRLF
cHtml += '    </tr>'+CRLF

//aqui
QSE2->(dbGoTop())
DO while QSE2->(!Eof())

	If nPag == 1
		nPag++

		cFormPgto := QSE2->FORMPGT
		dVencto   := QSE2->E2_VENCREA

		// Cabe�alho forma de pgto

		/*
		cHtml += '</table>'+CRLF
		cHtml += '</br>'+CRLF
		//cHtml += '</div>'+CRLF
		//cHtml += '<div class="folha">'+CRLF

		cHtml += '<table class="tg">'+CRLF

		cHtml += '<colgroup>'+CRLF
		cHtml += '<col style="width: 100px">'+CRLF
		cHtml += '<col style="width: 300px">'+CRLF
		cHtml += '<col style="width: 060px">'+CRLF
		cHtml += '<col style="width: 060px">'+CRLF
		cHtml += '<col style="width: 100px">'+CRLF
		cHtml += '<col style="width: 100px">'+CRLF
		cHtml += '<col style="width: 120px">'+CRLF
		cHtml += '</colgroup>'+CRLF
		*/

		cHtml += '    <tr>'+CRLF
		cHtml += '      <td class="tg-empr" colspan="7"> Vencimento: '+DTOC(QSE2->E2_VENCREA)+" - Forma de Pgto: "+QSE2->FORMPGT+'</td>'+CRLF
		cHtml += '    </tr>'+CRLF

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

	//cHtml += '    <tr>'+CRLF
	//cHtml += '      <td class="ti-hvalor" colspan="7">T�tulo: '+ALLTRIM(QSE2->E2_PREFIXO)+' '+ALLTRIM(QSE2->E2_NUM)+' - '+TRIM(QSE2->A2_NOME)+'</td>'+CRLF
	//cHtml += '    </tr>'+CRLF

	cHtml += '    <tr>'+CRLF
	cHtml += '      <td class="ti-hvalor">T�tulo</td>'+CRLF
	cHtml += '      <td class="ti-hvalor" colspan="2">Fornecedor</td>'+CRLF
	cHtml += '      <td class="ti-hvalor">CNPJ/CPF</td>'+CRLF
	cHtml += '      <td class="ti-hvalor">Valor</td>'+CRLF
	cHtml += '      <td class="ti-hvalor">Saldo</td>'+CRLF
	cHtml += '    <tr>'+CRLF

	cHtml += '    <tr>'+CRLF
	cHtml += '      <td class="ti-valor">'+ALLTRIM(QSE2->E2_PREFIXO)+' '+ALLTRIM(QSE2->E2_NUM)+' '+ALLTRIM(QSE2->E2_PARCELA)+'</td>'+CRLF
	cHtml += '      <td class="ti-valor" colspan="2"> '+ALLTRIM(QSE2->E2_FORNECE)+'-'+ALLTRIM(QSE2->E2_LOJA)+" "+TRIM(QSE2->A2_NOME)+'</td>'+CRLF
	cHtml += '      <td class="ti-valor">'+TRANSFORM(QSE2->A2_CGC,IIF(QSE2->A2_TIPO=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))+'</td>'+CRLF
	cHtml += '      <td class="ti-valor">R$ '+ALLTRIM(TRANSFORM(QSE2->E2_VALOR,cPict))+'</td>'+CRLF
	cHtml += '      <td class="ti-valor">R$ '+ALLTRIM(TRANSFORM(QSE2->SALDO,cPict))+'</td>'+CRLF
	cHtml += '    <tr>'+CRLF

	If !Empty(QSE2->D1_COD) .OR. !Empty(QSE2->D1_CC)
		cHtml += '    <tr>'+CRLF
		cHtml += '      <td class="ti-hvalor">Produto</td>'+CRLF
		cHtml += '      <td class="ti-valor" colspan="2">'+TRIM(QSE2->D1_COD)+"-"+TRIM(QSE2->B1_DESC)+'</td>'+CRLF
		cHtml += '      <td class="ti-hvalor">C.Custo</td>'+CRLF
		cHtml += '      <td class="ti-valor" colspan="2">'+TRIM(QSE2->D1_CC)+"-"+TRIM(QSE2->CTT_DESC01)+'</td>'+CRLF
		cHtml += '    </tr>'+CRLF
	EndIf

	/*
	If !Empty(QSE2->D1_COD)
		cHtml += '    <tr>'+CRLF
		cHtml += '      <td class="ti-hvalor colspan="2">Produto<td>'+CRLF
		cHtml += '      <td class="ti-hvalor" colspan="5">Descri��o</td>'+CRLF
		cHtml += '    <tr>'+CRLF
		cHtml += '    <tr>'+CRLF
		cHtml += '      <td class="ti-valor colspan="2">'+TRIM(QSE2->D1_COD)+'</td>'+CRLF
		cHtml += '      <td class="ti-valor" colspan="5">'+TRIM(QSE2->B1_DESC)+'</td>'+CRLF
		cHtml += '    <tr>'+CRLF
	EndIF


	If !Empty(QSE2->D1_CC)
		cHtml += '    <tr>'+CRLF
		cHtml += '      <td class="ti-hvalor colspan="2">Centro de Custo</td>'+CRLF
		cHtml += '      <td class="ti-hvalor" colspan="5">Descri��o</td>'+CRLF
		cHtml += '    <tr>'+CRLF
		cHtml += '    <tr>'+CRLF
		cHtml += '      <td class="ti-valor colspan="2">'+TRIM(QSE2->D1_CC)+'</td>'+CRLF
		cHtml += '      <td class="ti-valor" colspan="5">'+TRIM(QSE2->CTT_DESC01)+'</td>'+CRLF
		cHtml += '    <tr>'+CRLF
	EndIF
	*/

	If !Empty(QSE2->HIST)
		cHtml += '    <tr>'+CRLF
		cHtml += '      <td class="ti-hvalor">Hist�rico</td>'+CRLF
		cHtml += '      <td class="ti-valor" colspan="5">'+TRIM(QSE2->HIST)+'</td>'+CRLF
		cHtml += '    </tr>'+CRLF
	EndIf


	/*
	If !Empty(QSE2->HIST)
		cHtml += '    <tr>'+CRLF
		cHtml += '      <td class="ti-hvalor" colspan="6">Hist�rico</td>'+CRLF
		cHtml += '    </tr>'+CRLF

		cHtml += '    <tr>'+CRLF
		cHtml += '      <td class="ti-valor" colspan="6">'+QSE2->HIST+CRLF
		cHtml += '      </td>'+CRLF
		cHtml += '    </tr>'+CRLF
	EndIf
	*/

	// Documentos anexos na Pr�-Nota
	aFilesF1 := u_BKDocs(cEmpAnt,"SF1",QSE2->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA),1)
	// Documentos anexos no Contas a Pagar
	aFilesE2 := u_BKDocs(cEmpAnt,"SE2",QSE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA),1)

	If Len(aFilesF1) > 0 .OR. Len(aFilesE2) > 0 
		cHtml += '  <tr>'+CRLF
		cHtml += '    <td class="ti-hvalor">Anexos</td>'+CRLF
		cHtml += '    <td colspan="5" style="text-align:center;">'+CRLF
		For nI := 1 To Len(aFilesF1)
			cHtml += '    <a href="'+u_BkRest()+'/RestLibPN/v4?empresa='+cEmpAnt+'&documento='+Encode64(aFilesF1[nI,2])+'&tpanexo=P" class="link-primary">'+aFilesF1[nI,2]+'</a>&nbsp;'+CRLF
		Next
		For nI := 1 To Len(aFilesE2)
			cHtml += '    <a href="'+u_BkRest()+'/RestLibPN/v4?empresa='+cEmpAnt+'&documento='+Encode64(aFilesE2[nI,2])+'&tpanexo=P" class="link-primary">'+aFilesE2[nI,2]+'</a>&nbsp;'+CRLF
		Next
		cHtml += '    </td>'+CRLF
		cHtml += '  </tr>'+CRLF
	EndIf



	cHtml += '    </table>'+CRLF
	cHtml += '    <br>'+CRLF
	cHtml += '   </td>'+CRLF
	cHtml += '  </tr>'+CRLF

	nTValor	  += QSE2->E2_VALOR
	nTSaldo   += QSE2->SALDO


	QSE2->(dbSkip())

	If cFormPgto <> QSE2->FORMPGT .OR. dVencto <> QSE2->E2_VENCREA .OR. QSE2->(EOF())

		// Total Parcial		
		cHtml += '<table class="tg">'+CRLF
		cHtml += ' <tr>'+CRLF
		cHtml += '   <td class="tg-hvalor colspan="5">Totais '+TRIM(cFormPgto)+' em '+DTOC(dVencto)+'</td>'+CRLF
		cHtml += '   <td class="tg-valor">R$ '+ALLTRIM(TRANSFORM(nTValor,cPict))+'</td>'+CRLF
		cHtml += '   <td class="tg-valor">R$ '+ALLTRIM(TRANSFORM(nTSaldo,cPict))+'</td>'+CRLF
		cHtml += ' <tr>'+CRLF
		cHtml += '</table>'+CRLF
		aAdd(aTotais,{TRIM(cFormPgto)+' em '+DTOC(dVencto),nTValor,nTSaldo})

		If !QSE2->(EOF())

			// Cabe�alho forma de pgto
			cHtml += '</table>'+CRLF
			cHtml += '</br>'+CRLF
			cHtml += '</div>'+CRLF
			
			cHtml += '<div class="folha">'+CRLF
			cHtml += '<table class="tg">'+CRLF

			cHtml += '<colgroup>'+CRLF
			cHtml += '<col style="width: 100px">'+CRLF
			cHtml += '<col style="width: 300px">'+CRLF
			cHtml += '<col style="width: 060px">'+CRLF
			cHtml += '<col style="width: 060px">'+CRLF
			cHtml += '<col style="width: 100px">'+CRLF
			cHtml += '<col style="width: 100px">'+CRLF
			cHtml += '<col style="width: 120px">'+CRLF
			cHtml += '</colgroup>'+CRLF

			cHtml += '    <tr>'+CRLF
			cHtml += '      <td class="tg-empr" colspan="7"> Vencimento: '+DTOC(QSE2->E2_VENCREA)+" - Forma de Pgto: "+QSE2->FORMPGT+'</td>'+CRLF
			cHtml += '    </tr>'+CRLF

		EndIf

		cFormPgto := QSE2->FORMPGT
		dVencto   := QSE2->E2_VENCREA

		nTValor	  := 0
		nTSaldo   := 0

	EndIF

EndDo

cHtml += '</table>'+CRLF
cHtml += '<br>'+CRLF

cHtml += '<table class="tg">'+CRLF
nTValor	  := 0
nTSaldo   := 0

cHtml += ' <tr>'+CRLF
cHtml += '   <td class="tg-hvalor colspan="5">TOTAIS '+FWEmpName(cEmpAnt)+'</td>'+CRLF
cHtml += '   <td class="tg-hvalor">VALOR DO T�TULO</td>'+CRLF
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

Return(cHtml)


// Retorna os Anexos do Documento de Entrada
User Function AnexosCP(aAnexos)
Local cFile		:= ""
Local aFiles	:= {}
Local nI 		:= 0

aAnexos := {}
aFiles := u_BKDocs(cEmpAnt,"SF1",QSE2->(E2_NUM+E2_PREFIXO+E2_FORNECE+E2_LOJA),1)
aFiles := u_BKDocs(cEmpAnt,"SE2",QSE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA),1,aFiles)

For nI := 1 To Len(aFiles)
	cFile := '=HYPERLINK("'+u_BkRest()+'/RestLibPN/v4?empresa='+cEmpAnt+'&documento='+Encode64(aFiles[nI,2])+'&tpanexo=P","'+aFiles[nI,2]+'") '+CRLF
	aAdd(aAnexos,cFile)
Next

//cFiles := '=HYPERLINK("https://www.totvs.com.br","TOTVS")'
Return Len(aAnexos)
