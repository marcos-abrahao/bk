#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKFINR37
BK - Resumo Diário Contas a Pagar
@Return
@author Marcos Bispo Abrahão
@since 13/11/2023
@version P12
/*/

User Function BKFINR37

Local cDescricao	:= "Objetivo: Indicador de Pagamentos Antecipados"
Local cSolicit 		:= "22/04/24 - kelly.neto"
Local cVersao 		:= "07/05/24 - Versão inicial"
Local oRExcel		AS Object
Local oPExcel		AS Object

Local cAlias 		:= "QSE2"
Local aOpcoes		:= {"1-Todos","2-Em Aberto", "3-Compensados"} 

Private aParam		:= {}
Private cTitulo		:= "Contas a Pagar - Pagamentos Antecipados"
Private cProg		:= "BKFINR37"
Private dDtIni		:= dDataBase
Private dDtFim		:= dDataBase
Private nOpcao		:= 1

// Log de Versões
cVersao += CRLF + "09/05/24 - Filtrar LF, Saques e incluir coluna Mês - Kelly Neto"


aAdd( aParam ,{ 3, "Opção:"			, 1              , aOpcoes               , 100,'.T.',.T.})
aAdd( aParam, { 1, "Data Inicial:" 	, dDataBase		 , ""    , "", ""	, "" , 70  , .T. })
aAdd( aParam, { 1, "Data Final:" 	, dDataBase		 , ""    , "", ""	, "" , 70  , .F. })

If !BkPar()
	Return Nil
EndIf

u_WaitLog(cProg, {|| ProcGer1() },cTitulo)

QSE2->(dbGoTop())
If QSE2->(EOF())
	u_MsgLog(cProg,"Não foram encontrados PAs para esta seleção","I")
	Return Nil
EndIf


// Aba PAs

// Definição do Arq Excel
oRExcel := RExcel():New(cProg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetSolicit(cSolicit)
oRExcel:SetDescr(cDescricao)
oRExcel:SetVersao(cVersao)
oRExcel:SetParam(aParam)

// Definição da Planilha 1
oPExcel:= PExcel():New("Pagamentos Antecipados",cAlias)
oPExcel:SetTitulo(aOpcoes[nOpcao]+" - "+DTOC(dDtIni)+iIf(dDtFim <> dDtIni," até "+DTOC(dDtFim),""))

/* Resumo
oPExcel:AddResumos("Valor x Portador","E2_PORTADO","E2_VALOR")
oPExcel:AddResumos("Saldo x Portador","E2_PORTADO","SALDO")
*/

// Colunas da Planilha

oPExcel:AddCol("NOMEEMP","QSE2->NOMEEMP","Empresa","")
oPExcel:GetCol("NOMEEMP"):SetTamCol(15)
oPExcel:GetCol("NOMEEMP"):SetHAlign("C")

oPExcel:AddColX3("E2_TIPO")
oPExcel:GetCol("E2_TIPO"):SetHAlign("C")

//oPExcel:AddColX3("E2_XXTIPBK")
//oPExcel:GetCol("E2_XXTIPBK"):SetHAlign("C")

oPExcel:AddCol("TITULO","QSE2->E2_PREFIXO+QSE2->E2_NUM+QSE2->E2_PARCELA","Título","")
oPExcel:GetCol("TITULO"):SetTamCol(15)

oPExcel:AddColX3("E2_FORNECE")
oPExcel:GetCol("E2_FORNECE"):SetHAlign("C")
oPExcel:AddColX3("E2_LOJA")
oPExcel:GetCol("E2_LOJA"):SetHAlign("C")

oPExcel:AddColX3("A2_NOME")

oPExcel:AddCol("CNPJ","TRANSFORM(QSE2->A2_CGC,IIF(QSE2->A2_TIPO=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))","CNPJ/CPF","")
oPExcel:GetCol("CNPJ"):SetHAlign("C")
oPExcel:GetCol("CNPJ"):SetTamCol(21)

oPExcel:AddColX3("E2_EMISSAO")
oPExcel:AddColX3("E2_VENCREA")

oPExcel:AddCol("MESEXT","MesExtenso(Month(QSE2->E2_VENCREA)) + ' ' + Str(Year(QSE2->E2_VENCREA), 4)","Mês","")
oPExcel:GetCol("MESEXT"):SetHAlign("C")
oPExcel:GetCol("MESEXT"):SetTamCol(21)

oPExcel:AddColX3("E2_BAIXA")

oPExcel:AddColX3("E5_DOCUMEN")

oPExcel:AddCol("STATUS","IIF(EMPTY(QSE2->E2_BAIXA),'Em atraso',IIF(QSE2->SALDO > 0,'Parcial','Compensada'))","Status P.A.")
oPExcel:GetCol("STATUS"):SetTamCol(12)
oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'E'}	,"FF0000","",,,.T.)	// Vermelho
oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'C'}	,"008000","",,,.T.)	// Verde
oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'P'}	,"0000FF","",,,.T.)	// Azul
oPExcel:GetCol("STATUS"):SetHAlign("C")

oPExcel:AddCol("ATRASO","IIF(EMPTY(QSE2->E2_BAIXA),DATE(),QSE2->E2_BAIXA) - QSE2->E2_EMISSAO + 1","Atraso")
oPExcel:GetCol("ATRASO"):SetTamCol(12)
oPExcel:GetCol("ATRASO"):SetTipo("N")
oPExcel:GetCol("ATRASO"):SetTamanho(6)
oPExcel:GetCol("ATRASO"):SetDecimal(0)
oPExcel:GetCol("ATRASO"):SetHAlign("C")

oPExcel:AddColX3("E2_VALOR")
oPExcel:GetCol("E2_VALOR"):SetTotal(.T.)

oPExcel:AddCol("SALDO","SALDO","Saldo","E2_SALDO")
oPExcel:GetCol("SALDO"):SetTotal(.T.)

oPExcel:AddCol("RESPONSAVEL","QSE2->(FWLeUserlg('E2_USERLGI',1))","Responsável","")
oPExcel:GetCol("RESPONSAVEL"):SetTamCol(20)

oPExcel:AddCol("XXOPER","UsrRetName(QSE2->E2_XXOPER)","Operador","")
oPExcel:GetCol("XXOPER"):SetTamCol(20)

oPExcel:AddCol("HIST","QSE2->E2_HIST","Histórico","")
oPExcel:GetCol("HIST"):SetWrap(.T.)


// Adiciona a planilhA
oRExcel:AddPlan(oPExcel)

oRExcel:Create()

QSE2->(dbCloseArea())

Return


Static Function BkPar
Local aRet		:=	{}
Local lRet := .F.

//   Parambox(aParametros,@cTitle          ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cProg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cProg,.T.         ,.T.))
	lRet := .T.
	nOpcao  := mv_par01
	dDtIni  := mv_par02
	dDtFim  := mv_par03
Endif
Return lRet



Static Function ProcGer1()
Local cQuery	:= ""
Local aBKGrupo	:= u_BKGrupo()
Local nE 		:= 0

If SELECT("QSE2") > 0 
	dbSelectArea("QSE2")
   	dbCloseArea()
EndIf

cQuery := "WITH RESUMO AS ( " + CRLF

For nE := 1 To Len(aBKGrupo)
	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf
	cQuery += " SELECT "+CRLF
	cQuery += "	  '"+aBKGrupo[nE,1]+"' AS EMPRESA"+CRLF
	cQuery += "	 ,'"+aBKGrupo[nE,3]+"' AS NOMEEMP"+CRLF
	cQuery += "	 ,E2_TIPO"+CRLF
	cQuery += "	 ,E2_PREFIXO"+CRLF
	cQuery += "	 ,E2_NUM"+CRLF
	cQuery += "	 ,E2_PARCELA"+CRLF
	cQuery += "	 ,E2_FORNECE"+CRLF
	cQuery += "	 ,E2_LOJA"+CRLF
	cQuery += "	 ,E2_HIST"+CRLF
	cQuery += "	 ,E2_XXTIPBK"+CRLF
	cQuery += "	 ,E2_USERLGI"+CRLF 
	cQuery += "	 ,E2_EMISSAO"+CRLF
	cQuery += "	 ,E2_BAIXA"+CRLF
	cQuery += "	 ,E2_VENCREA"+CRLF
	cQuery += "	 ,E2_VALOR"+CRLF
	cQuery += "	 ,E2_XXOPER"+CRLF
	//cQuery += "	 ,SE2.R_E_C_N_O_ AS REGSE2"+CRLF
	cQuery += "	 ,A2_NOME"+CRLF
	cQuery += "	 ,A2_TIPO"+CRLF
	cQuery += "	 ,A2_CGC"+CRLF

	cQuery += "	 ,(CASE WHEN E2_SALDO = E2_VALOR "+CRLF
	cQuery += "	 		THEN E2_VALOR + E2_ACRESC - E2_DECRESC"+CRLF
	cQuery += "	 		ELSE E2_SALDO END) AS SALDO"+CRLF

	//cQuery += "	 ,"+IIF(dDtIni <> dDtFim,"+' '+E2_VENCREA",'')+"+ "
	/*
	cQuery += "	 ,(CASE WHEN E2_XTIPOPG <> ' ' "+CRLF
	cQuery += "			THEN E2_XTIPOPG "+CRLF
	cQuery += "			WHEN (F1_XTIPOPG IS NULL) AND (Z2_BANCO IS NULL) "+CRLF
	cQuery += "	 		THEN E2_TIPO+' '+E2_PORTADO"+CRLF
	cQuery += "	 		WHEN F1_XTIPOPG IS NULL AND (E2_PORTADO IS NOT NULL) THEN 'LF '+E2_PORTADO+' '+E2_TIPO"+CRLF
	cQuery += "	 		ELSE F1_XTIPOPG END)"+" AS FORMPGT"+CRLF
	*/

	cQuery += "	 ,(SELECT TOP 1 E5_DOCUMEN FROM SE5"+aBKGrupo[nE,1]+"0 SE5 "+CRLF
	cQuery += "	 WHERE SE5.D_E_L_E_T_ = ''"+CRLF
	cQuery += "	   AND E5_TIPO = 'PA' "+CRLF
	cQuery += "	   AND E5_MOTBX = 'CMP'"+CRLF
	cQuery += "	   AND E5_TIPODOC = 'BA'"+CRLF
	cQuery += "	   AND E5_RECPAG = 'P'"+CRLF
	cQuery += "	   AND E5_PREFIXO = E2_PREFIXO "+CRLF
	cQuery += "	   AND E5_NUMERO = E2_NUM  "+CRLF
	cQuery += "	   AND E5_CLIFOR = E2_FORNECE"+CRLF
	cQuery += "	   AND E5_LOJA = E2_LOJA"+CRLF
	cQuery += "	   AND E5_SITUACA <> 'C' "+CRLF
	cQuery += "	   AND E5_DTCANBX = '') AS E5_DOCUMEN"+CRLF

	//cQuery += "	 ,Z2_NOME"+CRLF

	//cQuery += "	 ,F1_USERLGI"+CRLF 
	//cQuery += "	 ,F1_XXUSER"+CRLF
	//cQuery += "	 ,D1_COD"+CRLF
	//cQuery += "	 ,B1_DESC"+CRLF
	//cQuery += "	 ,D1_CC"+CRLF
	//cQuery += "	 ,CTT_DESC01"+CRLF
	//cQuery += "  ,CONVERT(VARCHAR(800),CONVERT(Binary(800),D1_XXHIST)) AS D1_XXHIST "+CRLF

	cQuery += "	 FROM SE2"+aBKGrupo[nE,1]+"0 SE2 "+CRLF

	cQuery += "	 LEFT JOIN SA2"+aBKGrupo[nE,1]+"0  SA2 ON"+CRLF
	cQuery += "	 	SA2.A2_FILIAL      = '  '"+CRLF
	cQuery += "	 	AND SE2.E2_FORNECE = SA2.A2_COD"+CRLF
	cQuery += "	 	AND SE2.E2_LOJA    = SA2.A2_LOJA"+CRLF
	cQuery += "	 	AND SA2.D_E_L_E_T_ = ''"+CRLF

/*
	cQuery += "	 LEFT JOIN "+RetSqlName("SF1")+" SF1 ON"+CRLF
	cQuery += "	 	SE2.E2_FILIAL      = SF1.F1_FILIAL"+CRLF
	cQuery += "	 	AND SE2.E2_NUM     = SF1.F1_DOC "+CRLF
	cQuery += "	 	AND SE2.E2_PREFIXO = SF1.F1_SERIE"+CRLF
	cQuery += "	 	AND SE2.E2_FORNECE = SF1.F1_FORNECE"+CRLF
	cQuery += "	 	AND SE2.E2_LOJA    = SF1.F1_LOJA"+CRLF
	cQuery += "	 	AND SF1.D_E_L_E_T_ = ''"+CRLF

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
*/

	cQuery += "	 WHERE SE2.D_E_L_E_T_ = '' "+ CRLF
	cQuery +=  "  AND E2_FILIAL = '"+xFilial("SE2")+"' "+CRLF
	cQuery +=  "  AND E2_TIPO = 'PA' "+CRLF
	cQuery +=  "  AND E2_FORNECE <> '"+u_cFornBK()+"' "+CRLF  // Filtrar saques
	cQuery +=  "  AND E2_FORNECE <> '"+u_ForFolBK()+"' "+CRLF  // Filtrar saques
	cQuery +=  "  AND E2_XXTIPBK = ' ' "+CRLF  // Filtrar integração LF
	If dDtIni == dDtFim
		cQuery +=  "  AND E2_VENCREA = '"+DTOS(dDtIni)+"' "+CRLF
	Else
		cQuery +=  "  AND E2_VENCREA >= '"+DTOS(dDtIni)+"' "+CRLF
		cQuery +=  "  AND E2_VENCREA <= '"+DTOS(dDtFim)+"' "+CRLF
	EndIf

	If nOpcao == 2
		cQuery +=  "  AND E2_SALDO > 0 "+CRLF
	ElseIf nOpcao == 3
		cQuery +=  "  AND E2_SALDO <= 0 "+CRLF
	EndIf

Next

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  * " + CRLF
//cQuery += "  ,ISNULL(D1_XXHIST,E2_HIST) AS HIST"+CRLF
cQuery += "  FROM RESUMO " + CRLF
cQuery += " ORDER BY EMPRESA,E2_VENCREA,A2_NOME" + CRLF

u_LogMemo("BKFINR37.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QSE2"

TCSETFIELD("QSE2","E2_EMISSAO","D",8,0)
TCSETFIELD("QSE2","E2_BAIXA","D",8,0)
TCSETFIELD("QSE2","E2_VENCREA","D",8,0)
//TCSETFIELD("QSE2","HIST","M",10,0)

Dbselectarea("QSE2")
QSE2->(Dbgotop())

Return nil
