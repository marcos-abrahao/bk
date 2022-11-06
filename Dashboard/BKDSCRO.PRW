#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSCRO
BK - Atualização da tabela CRONOGRAMAS do banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/

User Function BKDSCRO
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0


Local cTabCN9   := ""
Local cTabCNF   := ""

u_MsgLog("BKDSCRO","Inicio: Cronogramas")
 
cQuery := "WITH CRON AS ( " + CRLF

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
	cQuery += "  GETDATE() AS DATAPRC, " + CRLF
	cQuery += "  SUBSTRING(CNF_CONTRA,1,9) AS CONTRATO,"+CRLF
	cQuery += "  CNF_NUMPLA,"+CRLF
	cQuery += "  CNF_NUMERO,"+CRLF
	cQuery += "  CNF_REVISA,"+CRLF
	cQuery += "  CNF_PARCEL,"+CRLF
	cQuery += "  CNF_COMPET,"+CRLF
	cQuery += "  CNF_VLPREV,"+CRLF
	cQuery += "  CNF_VLREAL,"+CRLF
	cQuery += "  CNF_SALDO"+CRLF

	cQuery += " FROM "+cTabCNF+ " CNF " + CRLF

	cQuery += " INNER JOIN "+cTabCN9+" CN9 ON "+ CRLF
	cQuery += "    CN9_NUMERO = CNF_CONTRA" + CRLF
	cQuery += "	   AND CN9_REVISA = CNF_REVISA" + CRLF
	cQuery += "    AND CN9_FILIAL = '01' AND  CN9.D_E_L_E_T_ = ''" + CRLF

	cQuery += " WHERE CNF.D_E_L_E_T_=''" + CRLF
	//cQuery += "      AND CN9_REVATU = ' '" + CRLF
	
Next

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  *, " + CRLF
cQuery += "  (EMPRESA+CONTRATO+CNF_REVISA) AS CHAVE " + CRLF
cQuery += "  INTO PowerBk.dbo.CRONOGRAMAS  " + CRLF
cQuery += "  FROM CRON " + CRLF

cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,CONTRATO,CNF_REVISA,CNF_NUMPLA,CNF_PARCEL" + CRLF

u_LogMemo("BKDSCRO.SQL",cQuery)

If !TCIsConnected()
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.CRONOGRAMAS', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.CRONOGRAMAS "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro1, cPerg)
	EndIf
EndIf

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro2, cPerg)
	EndIf
EndIf

u_LogMemo("BKDSCRO.SQL",cErro1+cQueryD+cErro2+cQuery)
u_MsgLog("BKDSCRO","Final: Cronogramas")

Return
