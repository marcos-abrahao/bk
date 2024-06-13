#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKFINR36
BK - Resumo Diário Contas a Pagar
@Return
@author Marcos Bispo Abrahão
@since 13/11/2023
@version P12
/*/

User Function BKFINR36

Local cDescricao	:= "Objetivo deste relatório é indicar o se o prazo de implantação de documentos está de acordo com as 48 horas estipuladas "+CRLF+"Solicitado pelo depto Financeiro em 12/04/2024."
Local cSolicit 		:= "15/04/24 - kelly.neto"
Local cVersao 		:= "15/04/24 - Versão inicial"
Local oRExcel		AS Object
Local oPExcel		AS Object

Local cAlias 		:= "QSE2"
Local aOpcoes		:= {"1-Vencimento", "2-Emissão", "3-Digitação"} 

Private aParam		:= {}
Private cTitulo		:= "Contas a Pagar - Prazo Lançamento"
Private cProg		:= "BKFINR36"
Private dDtIni		:= dDataBase
Private dDtFim		:= dDataBase
Private nOpcao		:= 1

cVersao += CRLF+"12/06/24 - Inclusão do campo mês"

aAdd( aParam, { 1, "Data Inicial:" 	, dDataBase		 , ""    , "", ""	, "" , 70  , .T. })
aAdd( aParam, { 1, "Data Final:" 	, dDataBase		 , ""    , "", ""	, "" , 70  , .F. })
aAdd( aParam ,{ 3, "Opção de datas:", 1              , aOpcoes               , 100,'.T.',.T.})

If !BkPar()
	Return Nil
EndIf

u_WaitLog(cProg, {|| ProcGer1() },cTitulo)

QSE2->(dbGoTop())
If QSE2->(EOF())
	u_MsgLog(cProg,"Não foram encontrados titulos a imprimir para esta seleção","I")
	Return Nil
EndIf

// Definição do Arq Excel
oRExcel := RExcel():New(cProg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetSolicit(cSolicit)
oRExcel:SetDescr(cDescricao)
oRExcel:SetVersao(cVersao)
oRExcel:SetParam(aParam)

// Definição da Planilha 1
oPExcel:= PExcel():New("TITULOS",cAlias)
oPExcel:SetTitulo("TITULOS")

// Colunas da Planilha

oPExcel:AddCol("NOMEEMP","QSE2->NOMEEMP","Empresa","")
oPExcel:GetCol("NOMEEMP"):SetTamCol(15)

oPExcel:AddColX3("E2_TIPO")

oPExcel:AddCol("TITULO","QSE2->E2_PREFIXO+QSE2->E2_NUM+QSE2->E2_PARCELA","Título","")
oPExcel:GetCol("TITULO"):SetTamCol(15)

oPExcel:AddColX3("A2_NOME")

oPExcel:AddColX3("F1_XTIPOPG")
oPExcel:AddColX3("E2_EMISSAO")
oPExcel:AddColX3("E2_EMIS1")
oPExcel:AddColX3("E2_VENCREA")

oPExcel:AddCol("MESEXT","MesExtenso(Month(QSE2->E2_VENCREA)) + ' ' + Str(Year(QSE2->E2_VENCREA), 4)","Mês","")
oPExcel:GetCol("MESEXT"):SetHAlign("C")
oPExcel:GetCol("MESEXT"):SetTamCol(21)

oPExcel:AddColX3("E2_VALOR")
oPExcel:GetCol("E2_VALOR"):SetTotal(.T.)

// Usuário
oPExcel:AddCol("XXUSER","IIF(!EMPTY(QSE2->F1_XXUSER),UsrRetName(QSE2->F1_XXUSER),IIF(EMPTY(QSE2->E2_XXRHUSR),QSE2->(FwLeUserLg('E2_USERLGI',1)),QSE2->E2_XXRHUSR))","Cadastrado por","")
oPExcel:GetCol("XXUSER"):SetTamCol(20)

oPExcel:AddCol("XXDEPTO","u_UsrCPO(IIF(!EMPTY(QSE2->F1_XXUSER),QSE2->F1_XXUSER,QSE2->(FwLeUserLg('E2_USERLGI',1))),'USR_DEPTO')","Departamento","")
oPExcel:GetCol("XXDEPTO"):SetTamCol(20)

oPExcel:AddColX3("F1_XXDINC")

// Aprovado por
oPExcel:AddCol("XXUAPRV","UsrRetName(QSE2->F1_XXUAPRV)","Aprovado por","")
oPExcel:GetCol("XXUAPRV"):SetTamCol(20)

oPExcel:AddColX3("F1_XXDAPRV")

// Liberado por
oPExcel:AddCol("XXULIB","IIF(!EMPTY(QSE2->F1_XXULIB),UsrRetName(QSE2->F1_XXULIB),QSE2->E2_XXRHLIB)","Liberado por","")
oPExcel:GetCol("XXULIB"):SetTamCol(20) 

oPExcel:AddColX3("F1_XXDLIB")

// Classificado por
oPExcel:AddCol("XXUCLAS","UsrRetName(QSE2->F1_XXUCLAS)","Classificado por","")
oPExcel:GetCol("XXUCLAS"):SetTamCol(20)

oPExcel:AddColX3("F1_XXDCLAS")

// Prazo
oPExcel:AddCol("PRAZO1","u_R36Prazo(QSE2->E2_TIPO,QSE2->F1_XXDINC,QSE2->E2_VENCREA,QSE2->F1_XXUSER,QSE2->(FwLeUserLg('E2_USERLGI',1)),1)","Prazo","")
oPExcel:GetCol("PRAZO1"):SetTamCol(20)
oPExcel:GetCol("PRAZO1"):AddCor({|x| SUBSTR(x,1,1) == 'F'}	,"FF0000","",,,.T.)	// Vermelho

oPExcel:AddCol("PRAZO2","u_R36Prazo(QSE2->E2_TIPO,QSE2->F1_XXDINC,QSE2->E2_VENCREA,QSE2->F1_XXUSER,QSE2->(FwLeUserLg('E2_USERLGI',1)),2)","Dias","")
oPExcel:GetCol("PRAZO2"):SetTamCol(20)

oPExcel:AddResumos("Total","PRAZO1","PRAZO1")

/*
oPExcel:AddCol("STATUS","u_DE2XXPgto(E2_XXPGTO)")
oPExcel:GetCol("STATUS"):SetTamCol(12)
oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'P'}	,"FF0000","",,,.T.)	// Vermelho
oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,3) == 'Con'},"008000","",,,.T.)	// Verde
oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'E'}	,"FFA500","",,,.T.)	// Laranja
oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,3) == 'Com'},"0000FF","",,,.T.)	// Azul
oPExcel:GetCol("STATUS"):AddCor({|x| SUBSTR(x,1,1) == 'D'}	,"000000","",,,.T.)	// Preto
*/


// Adiciona a planilha 
oRExcel:AddPlan(oPExcel)

// Cria arquivo Excel
oRExcel:Create()

QSE2->(dbCloseArea())

Return


Static Function BkPar
Local aRet		:=	{}
Local lRet := .F.

//   Parambox(aParametros,@cTitle          ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cProg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cProg,.T.         ,.T.))
	lRet := .T.
	dDtIni  := mv_par01
	dDtFim  := mv_par02
	nOpcao	:= mv_par03

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
cQuery += "	 ,'"+u_BKNEmpr(cEmpAnt,3)+"' AS NOMEEMP"+CRLF
cQuery += "	 ,E2_TIPO"+CRLF
cQuery += "	 ,E2_PREFIXO"+CRLF
cQuery += "	 ,E2_NUM"+CRLF
cQuery += "	 ,E2_PARCELA"+CRLF
cQuery += "	 ,E2_FORNECE"+CRLF
cQuery += "	 ,E2_LOJA"+CRLF
cQuery += "	 ,E2_XXTIPBK"+CRLF
cQuery += "	 ,E2_USERLGI"+CRLF 
cQuery += "	 ,E2_VENCREA"+CRLF
cQuery += "	 ,E2_EMISSAO"+CRLF
cQuery += "	 ,E2_EMIS1"+CRLF
cQuery += "	 ,E2_VALOR"+CRLF
cQuery += "	 ,A2_NOME"+CRLF
cQuery += "	 ,(CASE WHEN E2_XTIPOPG <> ' ' THEN E2_XTIPOPG ELSE F1_XTIPOPG END) AS F1_XTIPOPG"+CRLF
cQuery += "	 ,(CASE WHEN E2_XXRHLIB <> ' ' THEN E2_XXRHLIB ELSE Z2_APROV   END) AS E2_XXRHLIB"+CRLF
cQuery += "	 ,E2_XXRHUSR"+CRLF
cQuery += "	 ,E2_XXRHTDE"+CRLF
cQuery += "	 ,F1_XXUSER"+CRLF
cQuery += "	 ,ISNULL(F1_XXDINC,SUBSTRING(Z2_DATAEMI,7,2)+'/'+SUBSTRING(Z2_DATAEMI,5,2)+'/'+SUBSTRING(Z2_DATAEMI,1,4)) AS F1_XXDINC"+CRLF
cQuery += "	 ,F1_XXUAPRV"+CRLF
cQuery += "	 ,F1_XXDAPRV"+CRLF
cQuery += "	 ,F1_XXULIB"+CRLF
cQuery += "	 ,F1_XXDLIB"+CRLF
cQuery += "	 ,F1_XXUCLAS"+CRLF
cQuery += "	 ,F1_XXDCLAS"+CRLF
cQuery += "	 ,D1_CC"+CRLF
cQuery += "	 ,CTT_DESC01"+CRLF

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

cQuery += "	 WHERE SE2.D_E_L_E_T_ = '' "+ CRLF
cQuery +=  "  AND E2_FILIAL = '"+xFilial("SE2")+"' "+CRLF
If nOpcao == 1
	If dDtIni == dDtFim
		cQuery +=  "  AND E2_VENCREA = '"+DTOS(dDtIni)+"' "+CRLF
	Else
		cQuery +=  "  AND E2_VENCREA >= '"+DTOS(dDtIni)+"' "+CRLF
		cQuery +=  "  AND E2_VENCREA <= '"+DTOS(dDtFim)+"' "+CRLF
	EndIf
ElseIf nOpcao == 2
	If dDtIni == dDtFim
		cQuery +=  "  AND E2_EMISSAO = '"+DTOS(dDtIni)+"' "+CRLF
	Else
		cQuery +=  "  AND E2_EMISSAO >= '"+DTOS(dDtIni)+"' "+CRLF
		cQuery +=  "  AND E2_EMISSAO <= '"+DTOS(dDtFim)+"' "+CRLF
	EndIf
ElseIf nOpcao == 3
	If dDtIni == dDtFim
		cQuery +=  "  AND E2_EMIS1 = '"+DTOS(dDtIni)+"' "+CRLF
	Else
		cQuery +=  "  AND E2_EMIS1 >= '"+DTOS(dDtIni)+"' "+CRLF
		cQuery +=  "  AND E2_EMIS1 <= '"+DTOS(dDtFim)+"' "+CRLF
	EndIf
EndIf

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  * " + CRLF
cQuery += "  FROM RESUMO " + CRLF
If nOpcao == 1
	cQuery += " ORDER BY E2_VENCREA,A2_NOME,E2_NUM" + CRLF
ElseIf nOpcao == 2
	cQuery += " ORDER BY E2_EMISSAO,A2_NOME,E2_NUM" + CRLF
ElseIf nOpcao == 2
	cQuery += " ORDER BY E2_EMIS1,A2_NOME,E2_NUM" + CRLF
EndIf
//cQuery += "    EMPRESA,E2_VENCREA,FORMPGT " + CRLF

u_LogMemo("BKFINR36.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QSE2"

TCSETFIELD("QSE2","E2_VENCREA","D",8,0)
TCSETFIELD("QSE2","E2_EMISSAO","D",8,0)
TCSETFIELD("QSE2","E2_EMIS1","D",8,0)
TCSETFIELD("QSE2","E2_XXRHTDE","D",8,0)
TCSETFIELD("QSE2","HIST","M",10,0)

Dbselectarea("QSE2")
QSE2->(Dbgotop())

Return nil


User Function R36Prazo(cTipo,cIni,dFim,cF1User,cLgiUser,nTpRet)
Local cRet	:= ""
Local nDias	:= 0
Local dIni
Local dDtP
Local cDepto:= ""

dIni := CTOD(SUBSTR(cIni,1,10))
dDtP := dIni

If !Empty(dIni) .AND. !Empty(dFim) .AND. !(TRIM(cTipo) $ "DP/PA")

	cDepto := ALLTRIM(UPPER(u_UsrCPO(IIF(!EMPTY(cF1User),cF1User,cLgiUser),'USR_DEPTO')))

	If !(cDepto $ "FINANCEIRO/RH/JURIDICO/FISCAL")

		Do While dDtP < dFim
			dDtP++
			dDtP := DataValida(dDtP,.T.)
			nDias++
		EndDo

		If nTpRet == 1
			If nDias >= 3
				cRet := "Dentro do Prazo"
			Else
				cRet := "Fora do Prazo"
			EndIf
		Else
			cRet := ALLTRIM(STR(nDias,5))
		EndIf
	Else
		If nTpRet == 1
			cRet := "Não se Aplica"
		EndIf
	EndIf
Else
	If nTpRet == 1
		cRet := "Não se Aplica"
	EndIf
EndIf

Return cRet
