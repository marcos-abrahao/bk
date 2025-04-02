#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKMSG003
BK - Aviso de Clientes sem virgula (,) no endereço (Barueri)
@Return
@author Marcos Bispo Abrahão
@since 23/04/24
@version P12.1.2310
/*/

User Function BKMSG003
Local cQuery	:= ""
Local aEmpresas := u_BKBarueri()
Local nE 		:= 0

Local cTabSA1	:= ""

Local cEmail 	:= ""
Local cAssunto  := "Aviso de Clientes sem virgula no endereço"
Local cEmailCC  := u_EmailAdm() 
Local aCabs   	:= {"Empresa","Código","Identificação","Endereço","Bairro","Municipio","UF"}
Local aEmail 	:= {}
Local cMsg		:= ""
Local aUsers 	:= {}
Local aGrupos 	:= {u_GrpMLibDc()} // Grupo Master Lib Docs
Local aDeptos 	:= {}

Private cProg := "BKMSG003"

cEmail := u_GprEmail("",aUsers,aGrupos,aDeptos)

cQuery := "WITH MSG AS ( " + CRLF

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabSA1 := "SA1"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT"+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA" + CRLF
	cQuery += " ,'"+cNomeEmp+"' AS NOMEEMP" + CRLF
	cQuery += "	,A1_COD+'-'+A1_LOJA AS CODIGO" + CRLF
	cQuery += "	,A1_NOME" + CRLF
	cQuery += "	,A1_END" + CRLF
	cQuery += "	,A1_BAIRRO" + CRLF
	cQuery += "	,A1_MUN" + CRLF
	cQuery += "	,A1_EST" + CRLF
	cQuery += "FROM "+cTabSA1+" SA1" + CRLF
	cQuery += "WHERE D_E_L_E_T_ = '' AND A1_END NOT LIKE '%,%' AND A1_MSBLQL = '2'" + CRLF

Next

cQuery += ")"+CRLF
cQuery += "SELECT * " + CRLF
cQuery += "  FROM MSG " + CRLF

cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,CODIGO" + CRLF

u_LogMemo("BKMSG003.SQL",cQuery)

//cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP",.T.,.T.)

dbSelectArea("QTMP")
dbGoTop()

aEmail := {}
Do While !Eof()
	AADD(aEmail,{QTMP->NOMEEMP,QTMP->CODIGO,QTMP->A1_NOME,QTMP->A1_END,QTMP->A1_BAIRRO,QTMP->A1_MUN,QTMP->A1_EST})
	dbSkip()
EndDo

If Len(aEmail) > 0
	cMsg     := u_GeraHtmB(aEmail,cAssunto,aCabs,cProg,"",cEmail,cEmailCC)
	u_GrvAnexo(cProg+".html",cMsg,.T.)
	U_BkSnMail(cProg,cAssunto,cEmail,cEmailCC,cMsg,{cProg+".html"})
EndIf

QTMP->(dbCloseArea())

u_MsgLog(cProg,"Clientes sem virgula no endereço: "+ALLTRIM(STR(LEN(aEmail))))

Return



/*
SELECT * FROM SA1010 WHERE D_E_L_E_T_ = '' AND A1_END NOT LIKE '%,%' AND A1_MSBLQL = '2'
*/
