#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKFINR38
BK - Relação de Titulos ADP
@Return
@author Marcos Bispo Abrahão
@since 13/11/2023
@version P12
/*/

User Function BKFINR38

Local cDescricao	:= "Objetivo: Titulos integrados Folha ADP"
Local cSolicit 		:= "28/01/25 - ADP"
Local cVersao 		:= "28/01/25 - Versão inicial"
Local oRExcel		AS Object
Local oPExcel		AS Object

Local cAlias 		:= "QSE2"
Local aOpcoes		:= {"1-Emissao","2-Vencimento"} 

Private aParam		:= {}
Private cTitulo		:= "Contas a Pagar - Titulos integrados Folha ADP"
Private cProg		:= "BKFINR38"
Private dDtIni		:= dDataBase
Private dDtFim		:= dDataBase
Private nOpcao		:= 1

// Log de Versões
//cVersao += CRLF + "XX/XX/XXXX - "

aAdd( aParam ,{ 3, "Opção:"			, 1              , aOpcoes               , 100,'.T.',.T.})
aAdd( aParam, { 1, "Data Inicial:" 	, dDataBase		 , ""    , "", ""	, "" , 70  , .T. })
aAdd( aParam, { 1, "Data Final:" 	, dDataBase		 , ""    , "", ""	, "" , 70  , .F. })

If !BkPar()
	Return Nil
EndIf

u_WaitLog(cProg, {|| ProcGer1() },cTitulo)

QSE2->(dbGoTop())
If QSE2->(EOF())
	u_MsgLog(cProg,"Não foram encontrados títulos para esta seleção","I")
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
oPExcel:= PExcel():New("Titulos ADP",cAlias)
oPExcel:SetTitulo(aOpcoes[nOpcao]+" - "+DTOC(dDtIni)+iIf(dDtFim <> dDtIni," até "+DTOC(dDtFim),""))


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

oPExcel:AddColX3("E2_EMISSAO")
oPExcel:AddColX3("E2_VENCREA")

oPExcel:AddColX3("E2_BAIXA")

oPExcel:AddColX3("E2_VALOR")
oPExcel:GetCol("E2_VALOR"):SetTotal(.T.)

oPExcel:AddCol("SALDO","SALDO","Saldo","E2_SALDO")
oPExcel:GetCol("SALDO"):SetTotal(.T.)

//oPExcel:AddCol("RESPONSAVEL","QSE2->(FWLeUserlg('E2_USERLGI',1))","Responsável","")
//oPExcel:GetCol("RESPONSAVEL"):SetTamCol(20)

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
	cQuery += "	 ,A2_NOME"+CRLF

	cQuery += "	 ,(CASE WHEN E2_SALDO = E2_VALOR "+CRLF
	cQuery += "	 		THEN E2_VALOR + E2_ACRESC - E2_DECRESC"+CRLF
	cQuery += "	 		ELSE E2_SALDO END) AS SALDO"+CRLF

	cQuery += "	 FROM SE2"+aBKGrupo[nE,1]+"0 SE2 "+CRLF

	cQuery += "	 LEFT JOIN SA2"+aBKGrupo[nE,1]+"0  SA2 ON"+CRLF
	cQuery += "	 	SA2.A2_FILIAL      = '  '"+CRLF
	cQuery += "	 	AND SE2.E2_FORNECE = SA2.A2_COD"+CRLF
	cQuery += "	 	AND SE2.E2_LOJA    = SA2.A2_LOJA"+CRLF
	cQuery += "	 	AND SA2.D_E_L_E_T_ = ''"+CRLF

	cQuery += "	 WHERE SE2.D_E_L_E_T_ = '' "+ CRLF
	cQuery +=  "  AND E2_FILIAL = '"+xFilial("SE2")+"' "+CRLF
	cQuery +=  "  AND E2_XXORIG = 'ADP' "+CRLF

	If nOpcao == 1
		If dDtIni == dDtFim
			cQuery +=  "  AND E2_EMISSAO = '"+DTOS(dDtIni)+"' "+CRLF
		Else
			cQuery +=  "  AND E2_EMISSAO >= '"+DTOS(dDtIni)+"' "+CRLF
			cQuery +=  "  AND E2_EMISSAO <= '"+DTOS(dDtFim)+"' "+CRLF
		EndIf
	Else
		If dDtIni == dDtFim
			cQuery +=  "  AND E2_VENCREA = '"+DTOS(dDtIni)+"' "+CRLF
		Else
			cQuery +=  "  AND E2_VENCREA >= '"+DTOS(dDtIni)+"' "+CRLF
			cQuery +=  "  AND E2_VENCREA <= '"+DTOS(dDtFim)+"' "+CRLF
		EndIf
	EndIf

Next

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  * " + CRLF
cQuery += "  FROM RESUMO " + CRLF
If nOpcao == 1
	cQuery += " ORDER BY EMPRESA,E2_EMISSAO,E2_NUM" + CRLF
Else
	cQuery += " ORDER BY EMPRESA,E2_VENCREA,E2_NUM" + CRLF
EndIf

u_LogMemo("BKFINR38.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QSE2"

TCSETFIELD("QSE2","E2_EMISSAO","D",8,0)
TCSETFIELD("QSE2","E2_BAIXA","D",8,0)
TCSETFIELD("QSE2","E2_VENCREA","D",8,0)

Dbselectarea("QSE2")
QSE2->(Dbgotop())

Return nil
