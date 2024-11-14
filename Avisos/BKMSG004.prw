#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKMSG004
BK - Aviso de Clientes sem Conta Bancária para Depósito
@Return
@author Marcos Bispo Abrahão
@since 25/04/24
@version P12.1.2310
/*/

User Function BKMSG004
Local cQuery	:= ""
Local aEmpresas := u_BKGrpFat()
Local nE 		:= 0
Local cTabSA1	:= ""
Local cEmail 	:= ""
Local cAssunto  := "Aviso de Clientes sem Conta Bancária para Depósito: "
Local cEmailCC  := u_EmailAdm()
Local aCabs   	:= {"Empresa","Código","Identificação","Endereço","Bairro","Municipio","UF","Ultima"}
Local aEmail 	:= {}
Local cMsg		:= ""
Local aUsers 	:= {}
Local aGrupos 	:= {}
Local aDeptos 	:= {"Financeiro"}

Private cProg := "BKMSG004"

cEmail := u_GprEmail("",@aUsers,@aGrupos,@aDeptos)

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
	cQuery += "	,A1_ULTCOM" + CRLF
	cQuery += "FROM "+cTabSA1+" SA1" + CRLF
	cQuery += "WHERE D_E_L_E_T_ = '' AND A1_XXCTABC = ' ' AND A1_MSBLQL = '2'" + CRLF

Next

cQuery += ")"+CRLF
cQuery += "SELECT * " + CRLF
cQuery += "  FROM MSG " + CRLF

cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,CODIGO" + CRLF

u_LogMemo("BKMSG004.SQL",cQuery)

//cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP",.T.,.T.)

dbSelectArea("QTMP")
dbGoTop()

aEmail := {}
Do While !Eof()
	AADD(aEmail,{QTMP->NOMEEMP,QTMP->CODIGO,QTMP->A1_NOME,QTMP->A1_END,QTMP->A1_BAIRRO,QTMP->A1_MUN,QTMP->A1_EST,DTOC(STOD(QTMP->A1_ULTCOM))})
	dbSkip()
EndDo

cAssunto += ALLTRIM(STR(LEN(aEmail)))

If Len(aEmail) > 0
	// Grava o anexo html

	cMsg   := u_GeraHtmB(aEmail,cAssunto,aCabs,cProg,"",cEmail,cEmailCC)

	u_GrvAnexo(cProg+".html",cMsg,.T.)

	U_BkSnMail(cProg,cAssunto,cEmail,cEmailCC,cMsg,{cProg+".html"},.T.)


	// Gravar no SZ0 - Avisos Web
	//u_BKMsgUs(cEmpAnt,cProg,{},aGrupos,"Clientes sem Conta bancaria: "+ALLTRIM(STR(LEN(aEmail))),"Clientes sem Conta bancaria: "+ALLTRIM(STR(LEN(aEmail))),"F",cProg+".html")
EndIf

u_MsgLog(cProg,cAssunto)

QTMP->(dbCloseArea())

Return


/*
	SELECT
		A1_COD+'-'+A1_LOJA AS CODIGO
		,A1_NOME
		,A1_END 
		,A1_BAIRRO
		,A1_MUN
		,A1_EST 
		,A1_ULTCOM
	FROM SA1010 SA1
	WHERE D_E_L_E_T_ = '' AND A1_XXCTABC = ' ' AND A1_MSBLQL = '2'

	/*


('000249-01',
'000345-01',
'000291-02',
'000281-51',
'000359-01',
'000281-52',
'000281-53',
'000281-54',
'000281-55',
'000281-56',
'000281-57',
'000281-58',
'000281-59',
'000281-60',
'000281-61',
'000281-62',
'000369-01',
'000281-63',
'000380-01',
'000383-01',
'000281-64',
'000386-01',
'000387-01',
'000389-01',
'000281-65',
'000400-02',
'000404-01',
'000404-02',
'000404-03',
'000404-04',
'000404-05',
'000404-06',
'000404-07',
'000404-08',
'000404-09',
'000404-10',
'000404-11',
'000404-12',
'000404-13',
'000404-14',
'000404-15',
'000404-16',
'000404-17')


('000003-01',
'000045-01',
'000014-01',
'000023-01',
'000024-01',
'000025-01',
'000027-01',
'000028-01',
'000029-01',
'000031-01',
'000034-01',
'000035-01',
'000037-01',
'000038-01',
'000069-01',
'000048-01',
'000081-01',
'000111-01',
'000112-01',
'000113-01',
'000114-01',
'000115-01',
'000116-01',
'000117-01',
'000119-01',
'000120-01',
'000121-01',
'000122-01',
'000123-01',
'000125-01',
'000126-01',
'000127-01',
'000131-01',
'000133-01',
'000134-01',
'000135-01',
'000136-01',
'000139-01',
'000141-01',
'000140-01',
'000143-01',
'000144-01',
'000146-01',
'000158-01',
'000159-01',
'000164-01',
'000167-01',
'000169-01',
'000173-01',
'000216-01',
'000217-01',
'000247-01',
'000248-01',
'000252-01',
'000257-01',
'000260-01',
'000263-01',
'000267-01',
'000270-01',
'000275-01',
'000276-01',
'105042-01',
'000282-01',
'000284-01',
'000307-01',
'000308-01',
'000313-01',
'000331-01',
'000337-01',
'000338-01',
'000342-01',
'000344-01',
'000350-01',
'000351-01',
'000352-01',
'000353-01',
'000354-01',
'105043-01',
'105044-01',
'000356-01',
'000357-01',
'000358-01',
'000289-02',
'000246-02',
'105045-01',
'000366-01',
'000080-09',
'000372-01',
'000373-01',
'000273-02',
'000273-03',
'000375-00',
'000375-01',
'000376-01',
'000381-01',
'000384-01',
'000392-01',
'000400-01',
