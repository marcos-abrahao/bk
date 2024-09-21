#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKMSG005
BK - Aviso de Pedidos de Venda Liberados

@Return
@author Marcos Bispo Abrahão
@since 14/05/24
@version P12.1.2310
/*/

User Function BKMSG005
Local cQuery	:= ""
Local aEmpresas := u_BKGrpFat()
Local nE 		:= 0

Local cTabSC5	:= ""
Local cTabSC6   := ""
Local cTabSA1   := ""

Local cEmail 	:= ""
Local cAssunto  := "Pedidos de Venda Liberados - "+DTOC(DATE())+" "+Time()
Local cEmailCC  := u_EmailAdm() 
Local aCabs   	:= {"Empresa","Pedido","Cliente","Emissao","Contrato","Liberado por","Liberado em","Valor"}
Local aEmail 	:= {}
Local cMsg		:= ""
Local aUsers 	:= {}
Local aGrupos 	:= {u_GrpFat()} // Grupo Faturamento
Local aDeptos 	:= {}

Private cProg := "BKMSG005" 

cEmail := u_GprEmail("",@aUsers,@aGrupos,@aDeptos)

cQuery := "WITH MSG AS ( " + CRLF

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,3]

	cTabSC5 := "SC5"+cEmpresa+"0"
	cTabSC6 := "SC6"+cEmpresa+"0"
	cTabSA1 := "SA1"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT"+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA" + CRLF
	cQuery += "  ,'"+cNomeEmp+"' AS NOMEEMP" + CRLF
	cQuery += "  ,C5_NUM" + CRLF
	cQuery += "  ,C5_CLIENTE+'-'+C5_LOJACLI+'-'+A1_NOME AS C5CLIENTE "+ CRLF
	cQuery += "  ,C5_EMISSAO" + CRLF
	cQuery += "  ,SUBSTRING(CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1 ELSE C5_MDCONTR END,1,9) AS C5MDCONTR " + CRLF
	cQuery += "  ,C5_XXULIB" + CRLF
	cQuery += "  ,C5_XXDLIB" + CRLF
	cQuery += "  ,(SELECT SUM(C6_VALOR) FROM "+cTabSC6+" SC6" + CRLF 
    cQuery += "           WHERE SC6.D_E_L_E_T_ = '' AND SC6.C6_FILIAL = SC5.C5_FILIAL AND SC6.C6_NUM = SC5.C5_NUM)" + CRLF 
    cQuery += "           AS C6TOTAL" + CRLF 
	cQuery += " FROM " + CRLF
	cQuery += "  "+cTabSC5+" SC5 " + CRLF

	cQuery += " LEFT JOIN "+cTabSA1+" SA1 " + CRLF
	cQuery += "    ON SC5.C5_CLIENTE = SA1.A1_COD AND SC5.C5_LOJACLI = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = ''"+ CRLF

	cQuery += " WHERE SC5.D_E_L_E_T_=''" + CRLF
	cQuery += "	  AND SC5.C5_NOTA = '' AND SC5.C5_BLQ = '' AND SC5.C5_LIBEROK = 'S'" + CRLF
Next

cQuery += ")"+CRLF
cQuery += "SELECT * " + CRLF
cQuery += "  FROM MSG " + CRLF

cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,C5_NUM " + CRLF

u_LogMemo("BKMSG005.SQL",cQuery)

//cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP",.T.,.T.)

TCSetField("QTMP","C5_EMISSAO","D",8,0)
TCSetField("QTMP","C5_XXDLIB","D",8,0)

dbSelectArea("QTMP")
dbGoTop()

Do While !EOF()

	//{"Empresa","Pedido","Cliente","Emissao","Contrato","Liberado por","Liberado em","Valor"}

	AADD(aEmail,{QTMP->NOMEEMP,QTMP->C5_NUM,QTMP->C5CLIENTE,DTOC(QTMP->C5_EMISSAO),QTMP->C5MDCONTR,C5_XXULIB,DTOC(QTMP->C5_XXDLIB),QTMP->C6TOTAL})

	dbSkip()
EndDo
QTMP->(dbCloseArea())


If Len(aEmail) > 0
	cMsg := u_GeraHtmA(aEmail,cAssunto,aCabs,cProg)
	U_BkSnMail(cProg,cAssunto,cEmail,cEmailCC,cMsg)
EndIf

// Grava o anexo html
u_GrvAnexo(cProg+".html",cMsg,.T.)

// Gravar no SZ0 - Avisos Web
u_BKMsgUs(cEmpAnt,cProg,{},u_GrpFat(),"Pedidos de Venda liberados: "+ALLTRIM(STR(LEN(aEmail))),"Pedidos de Venda liberados: "+ALLTRIM(STR(LEN(aEmail))),"F",cProg+".html")

u_MsgLog(cProg,"Pedidos liberados: "+ALLTRIM(STR(LEN(aEmail))))

Return
