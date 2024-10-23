#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSGES
BK - Atualização da tabela GESTORES do banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/

User Function BKDSGES
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0
Local cProg		:= "BKDSGES"
Local cTabCN9   := ""
Local cTabCNF   := ""

cQuery := "WITH VIG AS ( " + CRLF

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabCN9 := "CN9"+cEmpresa+"0"
	cTabCNF := "CNF"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT"+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  SUBSTRING(CN9_NUMERO,1,9) AS CONTRATO,"+CRLF
	cQuery += "  CN9_SITUAC,"+CRLF
	cQuery += "  CN9_GESTC, "+CRLF
    cQuery += "  CN9_XXNRBK, "+CRLF
	cQuery += "  MIN(CN9_DTOSER) AS CN9DTOSER,"+CRLF
	cQuery += "  MIN(CN9_DTINIC) AS CN9DTINIC,"+CRLF
	cQuery += "  MIN(CNF_DTVENC) AS CNFINICIO,"+CRLF
	cQuery += "  MAX(CNF_DTVENC) AS CNFFIM,"+CRLF
	cQuery += "  CN9_XXDVIG,"+CRLF
	cQuery += "  MAX((SUBSTRING(CNF_COMPET,4,4))+SUBSTRING(CNF_COMPET,1,2))+'01' AS MAXCOMPET"+CRLF
	cQuery += " FROM " + CRLF
	cQuery += "  "+cTabCNF+" CNF " + CRLF

	cQuery += " INNER JOIN "+cTabCN9+" CN9 ON "+ CRLF
	cQuery += "    CN9_NUMERO = CNF_CONTRA" + CRLF
	cQuery += "	   AND CN9_REVISA = CNF_REVISA" + CRLF
	cQuery += "    AND CN9_FILIAL = '01' AND  CN9.D_E_L_E_T_ = ''" + CRLF
	cQuery += " WHERE CNF.D_E_L_E_T_=''" + CRLF
	cQuery += "      AND CN9_REVATU = ' '" + CRLF
	cQuery += " GROUP BY " + CRLF
	cQuery += "      CN9_NUMERO," + CRLF
	cQuery += "      CN9_GESTC, " + CRLF
	cQuery += "      CN9_SITUAC," + CRLF
	cQuery += "      CN9_XXNRBK," + CRLF
	cQuery += "      CN9_XXDVIG"+CRLF
Next

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  EMPRESA, " + CRLF
cQuery += "  NOMEEMP, " + CRLF
cQuery += "  GETDATE() AS DATAPRC, " + CRLF
cQuery += "  CONTRATO,  " + CRLF
cQuery += "  EMPRESA + CONTRATO AS CHAVE," + CRLF
cQuery += "  CN9_GESTC,  " + CRLF
cQuery += "  CN9_XXNRBK,  " + CRLF
cQuery += "  VIG.CN9_SITUAC, " + CRLF
cQuery += "  VIG.CN9DTOSER, " + CRLF
cQuery += "  VIG.CN9DTINIC, " + CRLF
cQuery += "  VIG.CNFINICIO, " + CRLF
cQuery += "  VIG.CNFFIM, " + CRLF
cQuery += "  VIG.MAXCOMPET, " + CRLF
cQuery += "  -- Inicio do contrato " + CRLF
cQuery += "  CASE WHEN VIG.CN9DTOSER > ' ' AND VIG.CN9DTOSER < CN9DTINIC AND VIG.CN9DTOSER < VIG.CNFINICIO THEN CONVERT(DATE,VIG.CN9DTOSER,112) " + CRLF
cQuery += "       WHEN VIG.CN9DTINIC > ' ' AND VIG.CN9DTINIC < VIG.CNFINICIO THEN CONVERT(DATE,VIG.CN9DTINIC,112) " + CRLF
cQuery += "       ELSE CONVERT(DATE,VIG.CNFINICIO,112) " + CRLF
cQuery += "       END AS VIGINICIO, " + CRLF
cQuery += "  -- Final do contrato " + CRLF
cQuery += "  CONVERT(DATE,VIG.CN9_XXDVIG,112) AS CTFINAL,"
cQuery += "  CASE WHEN VIG.MAXCOMPET > VIG.CNFFIM THEN CONVERT(DATE,VIG.MAXCOMPET,112) ELSE CONVERT(DATE,VIG.CNFFIM,112) END AS VIGFINAL " + CRLF
cQuery += "  INTO PowerBk.dbo.GESTORES  " + CRLF
cQuery += "  FROM VIG " + CRLF

cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,CONTRATO" + CRLF

u_LogMemo("BKDSGES.SQL",cQuery)

If !TCIsConnected()
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.GESTORES', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.GESTORES "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1 := TcSqlError()
EndIf

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2 := TcSqlError()
EndIf

u_QryResult(cProg,cQueryD+cQuery,cErro1+cErro2)

Return
