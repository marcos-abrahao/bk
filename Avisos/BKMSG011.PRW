#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKMSG011
BK - Aviso de termino de vig�ncia de contratos

@Return
@author Marcos Bispo Abrah�o
@since 18/06/25
@version P12.1.2410
/*/

User Function BKMSG011

Local nE 		:= 0
Local aEmpresas := u_BKGrpGct()
Local cQuery	:= ""            
Local cAssunto	:= "Aviso de termino de vigencia de contratos em at� 150 dias - Excel"
Local cEmail	:= u_EmMGestao()
Local cEmailCC	:= u_EmailAdm()
Local cMsg		:= "Aviso de termino de vigencia de contratos em at� 150 dias. Segue planilha anexa."
Local cArqXls   := ""
Local cTabCN9   := ""
Local cTabSA1   := ""
Local cTabCTT   := ""
Local cTabSZD   := ""

//Local aUsers 	:= {}
//Local aGrupos	:= {u_GrpRepac()}
//Local aDeptos	:= {}

Private cProg := "BKMSG011" 

If IsBlind() .AND. (DOW(DATE()) <> 2 .OR. DOW(DATE()) <> 5)
	Return Nil
EndIf

If FWCodEmp() <> "01"
	u_MsgLog(cPrw,"Executar somente na empresa 01","E")
	Return Nil
EndIf

//cEmail	 := u_GprEmail(cEmail,aUsers,aGrupos,aDeptos)

u_MsgLog(cProg,cAssunto)

cQuery := "WITH AVISO AS ( "+CRLF

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]
	cTabCN9  := "CN9"+cEmpresa+"0"
	cTabSA1  := "SA1"+cEmpresa+"0"
	cTabCTT  := "CTT"+cEmpresa+"0"
	cTabSZD  := "SZD"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += "SELECT "+CRLF
	cQuery += "    '"+cEmpresa+"' AS EMPRESA"+CRLF
	cQuery += "    ,'"+cNomeEmp+"' AS NOMEEMP"+CRLF

	cQuery += "    ,CN9_NUMERO" + CRLF
	cQuery += "    ,CN9_REVISA" + CRLF
	cQuery += "    ,CN9_DTINIC" + CRLF
	cQuery += "    ,CN9_XXDVIG" + CRLF
	cQuery += "    ,CN9_SITUAC" + CRLF
	cQuery += "    ,CTT_DESC01" + CRLF
	cQuery += "    ,CN9_XCLIEN" + CRLF
	cQuery += "    ,CN9_XLOJA" + CRLF
	cQuery += "    ,A1_NOME" + CRLF
	cQuery += "    ,CN9_XXPROA" + CRLF
	cQuery += "    ,CN9_XXSPRO" + CRLF
	cQuery += "    ,CN9_XXNRBK" + CRLF
	cQuery += "    ,CN9_XPRZMA" + CRLF
	cQuery += "    ,CN9.R_E_C_N_O_ AS XXRECNO" + CRLF
	cQuery += "    ,DATEDIFF(DAY, GETDATE(), CONVERT(DATE, CN9_XXDVIG, 112)) AS DIASVIG" + CRLF
	cQuery += "    ,ZD_DATA" + CRLF
	cQuery += "    ,ZD_HORA" + CRLF
	cQuery += "    ,ZD_USUARIO" + CRLF
	cQuery += "    ,ZD_XXPROBS" + CRLF
	cQuery += " FROM "+cTabCN9+" CN9"

	cQuery += " LEFT JOIN "+cTabCTT+ " CTT ON CTT_CUSTO = CN9_NUMERO" + CRLF
	cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '" + CRLF

	cQuery += " LEFT JOIN "+cTabSA1+ " SA1 ON A1_COD = CN9_XCLIEN AND A1_LOJA = CN9_XLOJA" + CRLF
	cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '" + CRLF

	cQuery += " LEFT JOIN "+cTabSZD+ " SZD " + CRLF
	cQuery += "      ON  SZD.ZD_CONTRAT = CN9_NUMERO AND SZD.ZD_REVISAO = CN9_REVISA AND SZD.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "      AND SZD.ZD_DATA+SZD.ZD_HORA = "+CRLF
	cQuery += "          (SELECT MAX(SZDS.ZD_DATA+SZDS.ZD_HORA) "+CRLF
	cQuery += "          FROM "+cTabSZD+ " SZDS "+CRLF
	cQuery += "          WHERE SZDS.ZD_CONTRAT = CN9_NUMERO AND SZDS.ZD_REVISAO = CN9_REVISA AND SZDS.D_E_L_E_T_ = ' ' AND SZDS.ZD_FILIAL = '"+xFilial("SZD")+"')" + CRLF
	cQuery += "      AND SZD.D_E_L_E_T_ = ' ' AND SZD.ZD_FILIAL = '"+xFilial("SZD")+"'" + CRLF

	cQuery += " WHERE "
	cQuery += "   CN9_SITUAC IN ('02','05','09') " + CRLF
	cQuery += "   AND CN9_FILIAL = '"+xFilial("CN9")+"' " + CRLF
	cQuery += "   AND CN9.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "   AND ISDATE(CN9_XXDVIG) = 1 " + CRLF
	cQuery += "   AND CONVERT(DATE, CN9_XXDVIG, 112) BETWEEN CONVERT(DATE, GETDATE()) AND DATEADD(DAY, 150, CONVERT(DATE, GETDATE()))" + CRLF

Next
cQuery += ")" + CRLF
cQuery += "SELECT * FROM AVISO" + CRLF
cQuery += " ORDER BY CONVERT(DATE, CN9_XXDVIG, 112) ASC" + CRLF

u_LogMemo(cProg+".SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP",.T.,.T.)
TCSETFIELD("QTMP","CN9_DTINIC","D",8,0)
TCSETFIELD("QTMP","CN9_XXDVIG","D",8,0)
TCSETFIELD("QTMP","ZD_DATA","D",8,0)

cArqXls := Excel(cAssunto,"QTMP")

QTMP->(dbCloseArea())

u_BkSnMail(cProg,cAssunto,cEmail,cEmailCC,cMsg,{cArqXls},.F.)

// Gravar no SZ0 - Avisos Web
u_BKMsgUs(cEmpAnt,cProg,{},u_GrpRepac(),cAssunto,cAssunto,"F",cArqXls)

Return


Static Function Excel(cTitulo,cAlias)
Local cDescr 	:= cTitulo
Local cVersao	:= "18/06/2025"
Local oRExcel	AS Object
Local oPExcel	AS Object
Local aParam 	:= {}
Local cArqXls	:= ""

// Defini��o do Arq Excel
oRExcel := RExcel():New(cProg,u_STmpDir(),cProg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetVersao(cVersao)
oRExcel:SetDescr(cDescr)
oRExcel:SetParam(aParam)

// Defini��o da Planilha 1
oPExcel:= PExcel():New(cProg,cAlias)
oPExcel:SetTitulo("")


// Colunas da Planilha 1

oPExcel:AddCol("DIASVIG","DIASVIG","Dias de Vig�ncia","")
oPExcel:GetCol("DIASVIG"):SetFormat("#,##0")
oPExcel:GetCol("DIASVIG"):SetHAlign("C")
oPExcel:AddCol("EMPRESA","EMPRESA","Empresa","")
oPExcel:AddCol("NOMEEMP","NOMEEMP","Empresa","")
oPExcel:AddColX3("CN9_NUMERO")
oPExcel:GetCol("CN9_NUMERO"):SetHAlign("C")
oPExcel:AddColX3("CN9_REVISA")
oPExcel:GetCol("CN9_REVISA"):SetHAlign("C")
oPExcel:AddColX3("CTT_DESC01")
oPExcel:AddColX3("CN9_XXNRBK")
oPExcel:AddColX3("CN9_DTINIC")
oPExcel:AddColX3("CN9_XXDVIG")
oPExcel:AddColX3("CN9_XXPROA")
oPExcel:AddColX3("CN9_XPRZMA")
oPExcel:GetCol("CN9_XPRZMA"):SetFormat("#,##0")
oPExcel:GetCol("CN9_XPRZMA"):SetHAlign("C")
oPExcel:AddCol("CN9_XXSPRO","u_cProrrog(QTMP->CN9_XXSPRO)","Status","")
//oPExcel:GetCol("CN9_XXSPRO"):SetTamCol(30)

oPExcel:AddColX3("ZD_DATA")
oPExcel:AddColX3("ZD_HORA")
oPExcel:AddColX3("ZD_USUARIO")
oPExcel:AddColX3("ZD_XXPROBS")

// Adiciona a planilha 1
oRExcel:AddPlan(oPExcel)

// Cria arquivo Excel
cArqXls:= oRExcel:Create()

Return cArqXls
