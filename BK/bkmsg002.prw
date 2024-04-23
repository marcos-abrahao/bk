#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKMSG002
BK - Aviso de Documentos pendentes de aprovação

@Return
@author Marcos Bispo Abrahão
@since 18/04/24
@version P12.1.2310
/*/

User Function BKMSG002
Local cQuery	:= ""
Local aEmpresas := u_BKGrupo()
Local nE 		:= 0

Local cTabSA1	:= ""
Local cTabSA2   := ""
Local cTabSA6   := ""
Local cTabSB1   := ""
Local cTabSED   := ""
Local cTabCT1   := ""

Local cEmail 	:= ""
Local cAssunto  := "Aviso de Entidades com Conta Contábil Bloqueada - "+DTOC(DATE())+" "+Time()
Local cEmailCC  := "microsiga@bkconsultoria.com.br;" 
Local aCabs   	:= {"Empresa","Origem","Código","Identificação","Conta Contábil","Descrição"}
Local aEmail 	:= {}
Local cMsg		:= ""
Local aUsers 	:= {}

Private cProg := "BKMSG002"

cQuery := "WITH MSG AS ( " + CRLF

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabSA1 := "SA1"+cEmpresa+"0"
	cTabSA2 := "SA2"+cEmpresa+"0"
	cTabSA6 := "SA6"+cEmpresa+"0"
	cTabSB1 := "SB1"+cEmpresa+"0"
	cTabSED := "SED"+cEmpresa+"0"
	cTabCT1 := "CT1"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT"+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA" + CRLF
	cQuery += " ,'"+cNomeEmp+"' AS NOMEEMP" + CRLF
	cQuery += "	,'CLIENTE' AS ORIGEM" + CRLF
	cQuery += "	,A1_COD+'-'+A1_LOJA AS CODIGO" + CRLF
	cQuery += "	,A1_NOME  AS DESCR" + CRLF
	cQuery += "	,A1_CONTA AS CONTA" + CRLF
	cQuery += "	,CT1_DESC01" + CRLF
	cQuery += "FROM "+cTabSA1+" SA1" + CRLF
	cQuery += "LEFT JOIN "+cTabCT1+" CT1 " + CRLF
	cQuery += "	ON A1_CONTA = CT1_CONTA AND CT1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE SA1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	AND A1_MSBLQL = '2' " + CRLF
	cQuery += "	AND CT1_BLOQ = '1'" + CRLF

	cQuery += "UNION ALL" + CRLF
	cQuery += "SELECT " + CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA" + CRLF
	cQuery += " ,'"+cNomeEmp+"' AS NOMEEMP" + CRLF
	cQuery += "	,'FORNECEDOR' AS ORIGEM" + CRLF
	cQuery += "	,A2_COD+'-'+A2_LOJA AS CODIGO" + CRLF
	cQuery += "	,A2_NOME  AS DESCR" + CRLF
	cQuery += "	,A2_CONTA AS CONTA" + CRLF
	cQuery += "	,CT1_DESC01 " + CRLF
	cQuery += "FROM "+cTabSA2+" SA2" + CRLF
	cQuery += "LEFT JOIN "+cTabCT1+" CT1 " + CRLF
	cQuery += "	ON A2_CONTA = CT1_CONTA AND CT1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE SA2.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	AND A2_MSBLQL = '2' " + CRLF
	cQuery += "	AND CT1_BLOQ = '1'" + CRLF

	cQuery += "UNION ALL" + CRLF
	cQuery += "SELECT " + CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA" + CRLF
	cQuery += " ,'"+cNomeEmp+"' AS NOMEEMP" + CRLF
	cQuery += "	,'PRODUTO' AS ORIGEM" + CRLF
	cQuery += "	,B1_COD    AS CODIGO" + CRLF
	cQuery += "	,B1_DESC   AS DESCR" + CRLF
	cQuery += "	,B1_CONTA  AS CONTA" + CRLF
	cQuery += "	,CT1_DESC01 " + CRLF
	cQuery += "FROM "+cTabSB1+" SB1" + CRLF
	cQuery += "LEFT JOIN "+cTabCT1+" CT1 " + CRLF
	cQuery += "	ON B1_CONTA = CT1_CONTA AND CT1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE SB1.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	AND B1_MSBLQL = '2' " + CRLF
	cQuery += "	AND CT1_BLOQ = '1'" + CRLF

	cQuery += "UNION ALL" + CRLF
	cQuery += "SELECT " + CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA" + CRLF
	cQuery += " ,'"+cNomeEmp+"' AS NOMEEMP" + CRLF
	cQuery += "	,'BANCO'  AS ORIGEM" + CRLF
	cQuery += "	,A6_COD+' '+A6_AGENCIA+' '+A6_NUMCON AS CODIGO" + CRLF
	cQuery += "	,A6_NOME  AS DESCR" + CRLF
	cQuery += "	,A6_CONTA AS CONTA" + CRLF
	cQuery += "	,CT1_DESC01 " + CRLF
	cQuery += "FROM "+cTabSA6+" SA6" + CRLF
	cQuery += "LEFT JOIN "+cTabCT1+" CT1 " + CRLF
	cQuery += "	ON A6_CONTA = CT1_CONTA AND CT1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE SA6.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	AND A6_BLOCKED = '2' " + CRLF
	cQuery += "	AND CT1_BLOQ = '1'" + CRLF

	cQuery += "UNION ALL" + CRLF
	cQuery += "SELECT " + CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA" + CRLF
	cQuery += " ,'"+cNomeEmp+"' AS NOMEEMP" + CRLF
	cQuery += "	,'NATUREZA' AS ORIGEM" + CRLF
	cQuery += "	,ED_CODIGO  AS CODIGO" + CRLF
	cQuery += "	,ED_DESCRIC AS DESCR" + CRLF
	cQuery += "	,ED_CONTA   AS CONTA" + CRLF
	cQuery += "	,CT1_DESC01 " + CRLF
	cQuery += "FROM "+cTabSED+" SED" + CRLF
	cQuery += "LEFT JOIN "+cTabCT1+" CT1 " + CRLF
	cQuery += "	ON ED_CONTA = CT1_CONTA AND CT1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "WHERE SED.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "	AND ED_MSBLQL = '2' " + CRLF
	cQuery += "	AND CT1_BLOQ = '1'" + CRLF

Next

cQuery += ")"+CRLF
cQuery += "SELECT * " + CRLF
cQuery += "  FROM MSG " + CRLF

cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,ORIGEM,CODIGO" + CRLF

u_LogMemo("BKMSG002.SQL",cQuery)

//cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP",.T.,.T.)

dbSelectArea("QTMP")
dbGoTop()

aEmail := {}
Do While !Eof()
	AADD(aEmail,{QTMP->NOMEEMP,QTMP->ORIGEM,QTMP->CODIGO,QTMP->DESCR,QTMP->CONTA,QTMP->CT1_DESC01})
	dbSkip()
EndDo

If Len(aEmail) > 0

	// Incluir os stafs na cópia do e-mail
	aUsers 	 := u_ArGrupo(u_GrpFisc())
	cEmail	 := ""
	For nE := 1 To Len(aUsers)
		cEmail += ALLTRIM(aUsers[nE,3])+";"
	Next

	cMsg     := u_GeraHtmA(aEmail,cAssunto,aCabs,cProg)
	U_BkSnMail(cProg,cAssunto,cEmail,cEmailCC,cMsg)
EndIf

QTMP->(dbCloseArea())

Return



/*
SELECT F1_DOC
,A2_NOME
,F1_DTDIGIT
,F1_XXPVPGT
,F1_XXUSER
,USR1.USR_CODIGO AS USUARIO
,USR1.USR_DEPTO  AS DEPTO
,F1_XXUSERS
,USR2.USR_CODIGO AS APROVADOR
,USR2.USR_EMAIL  AS EMAIL
FROM SF1010 SF1
LEFT JOIN SA2010 SA2 ON A2_COD = F1_FORNECE AND A2_LOJA = F1_LOJA AND SA2.D_E_L_E_T_ = ''
LEFT JOIN SYS_USR USR1 ON F1_XXUSER  = USR1.USR_ID AND USR1.D_E_L_E_T_ = ''
LEFT JOIN SYS_USR USR2 ON F1_XXUSERS = USR2.USR_ID AND USR2.D_E_L_E_T_ = ''
WHERE (F1_STATUS IN (' ','B') AND F1_XXLIB = '9') AND SF1.D_E_L_E_T_ = ''
*/
