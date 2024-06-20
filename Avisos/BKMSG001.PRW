#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKMSG001
BK - Aviso de Documentos pendentes de aprovação

@Return
@author Marcos Bispo Abrahão
@since 18/04/24
@version P12.1.2310
/*/

User Function BKMSG001
Local cQuery	:= ""
Local aEmpresas := u_BKGrupo()
Local nE 		:= 0

Local cTabSF1	:= ""
Local cTabSA2   := ""

Local cEmail 	:= ""
Local cIdSup	:= ""
Local cAssunto  := "Aviso de Documentos pendentes de aprovação - "+DTOC(DATE())+" "+Time()
Local cEmailCC  := "microsiga@bkconsultoria.com.br;" 
Local cEmailMs  := "microsiga@bkconsultoria.com.br;glaciana.oliveira@bkconsultoria.com.br" 
Local aCabs   	:= {"Empresa","Documento","Fornecedor","Digitação","Pagamento","Responsável","Departamento"}
Local aEmail 	:= {}
Local cMsg		:= ""
Local dUtil3	:= DATE()
Local lDtInf	:= .F.
Local aStaf 	:= {}

dUtil3 := DataValida(dUtil3+1,.T.)
dUtil3 := DataValida(dUtil3+1,.T.)
dUtil3 := DataValida(dUtil3+1,.T.)


Private cProg := "BKMSG001" 

cQuery := "WITH MSG AS ( " + CRLF

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabSF1 := "SF1"+cEmpresa+"0"
	cTabSA2 := "SA2"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT"+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA" + CRLF
	cQuery += "  ,'"+cNomeEmp+"' AS NOMEEMP" + CRLF
	cQuery += "  ,F1_DOC" + CRLF
	cQuery += "  ,A2_NOME" + CRLF
	cQuery += "  ,F1_DTDIGIT" + CRLF
	cQuery += "  ,F1_XXPVPGT" + CRLF
	cQuery += "  ,F1_XXUSER" + CRLF
	cQuery += "  ,USR1.USR_CODIGO AS USUARIO" + CRLF
	cQuery += "  ,USR1.USR_DEPTO  AS DEPTO" + CRLF
	cQuery += "  ,F1_XXUSERS" + CRLF
	cQuery += "  ,USR2.USR_ID 	  AS IDAPROV" + CRLF
	cQuery += "  ,USR2.USR_CODIGO AS APROVADOR" + CRLF
	cQuery += "  ,USR2.USR_EMAIL  AS EMAIL " + CRLF

	cQuery += " FROM " + CRLF
	cQuery += "  "+cTabSF1+" SF1 " + CRLF

	cQuery += " LEFT JOIN "+cTabSA2+" SA2 ON " + CRLF
	cQuery += "    A2_COD = F1_FORNECE AND A2_LOJA = F1_LOJA AND SA2.D_E_L_E_T_ = ''"+ CRLF

	cQuery += " LEFT JOIN SYS_USR USR1 ON F1_XXUSER  = USR1.USR_ID AND USR1.D_E_L_E_T_ = ''" + CRLF

	cQuery += " LEFT JOIN SYS_USR USR2 ON F1_XXUSERS = USR2.USR_ID AND USR2.D_E_L_E_T_ = ''" + CRLF

	cQuery += " WHERE SF1.D_E_L_E_T_=''" + CRLF
	cQuery += "	  AND (F1_STATUS IN (' ','B') AND F1_XXLIB = '9')" + CRLF
Next

cQuery += ")"+CRLF
cQuery += "SELECT * " + CRLF
cQuery += "  FROM MSG " + CRLF

cQuery += " ORDER BY" + CRLF
cQuery += "    EMAIL,EMPRESA,F1_XXPVPGT,A2_NOME" + CRLF

u_LogMemo("BKMSG001.SQL",cQuery)

//cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP",.T.,.T.)

TCSetField("QTMP","F1_DTDIGIT","D",8,0)
TCSetField("QTMP","F1_XXPVPGT","D",8,0)

dbSelectArea("QTMP")
dbGoTop()
Do While !Eof()
	cEmail := QTMP->EMAIL
	cIdSup := QTMP->IDAPROV
	aEmail := {}

	lDtInf	:= .F.
	Do While !EOF() .AND. cIdSup == QTMP->IDAPROV
		AADD(aEmail,{QTMP->NOMEEMP,QTMP->F1_DOC,QTMP->A2_NOME,DTOC(QTMP->F1_DTDIGIT),DTOC(QTMP->F1_XXPVPGT),QTMP->USUARIO,QTMP->DEPTO})

		If QTMP->F1_XXPVPGT <= dUtil3
			lDtInf	:= .T.
		EndIf

		dbSkip()
	EndDo

	// Somente enviar o e-mail se houver pagamentos vencendo em até 3 dias úteis
	If lDtInf

		// Incluir os stafs na cópia do e-mail
		aStaf 	 := u_ArStaf(cIdSup)
		cEmailCC := cEmailMs
		For nE := 1 To Len(aStaf)
			cEmailCC += ALLTRIM(aStaf[nE,2])+";"
		Next

		cMsg     := u_GeraHtmA(aEmail,cAssunto,aCabs,cProg)
		U_BkSnMail(cProg,cAssunto,cEmail,cEmailCC,cMsg)
	EndIf
EndDo

QTMP->(dbCloseArea())

u_MsgLog(cProg,"Documentos pendentes de aprovação: "+ALLTRIM(STR(LEN(aEmail))))
Return
