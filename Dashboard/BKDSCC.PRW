#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSCC
BK - Atualiza��o da tabela CCUSTOS do banco de dados PowerBk

@Return
@author Marcos Bispo Abrah�o
@since 27/09/2022
@version P12.1.25
/*/

User Function BKDSCC
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrupo()
Local nE 		:= 0
Local cTabCTT   := ""
Local cProg		:= "BKDSCC"

//u_MsgLog("BKDSCC","Inicio: Centros de Custo")
 
cQuery := "WITH CCUSTOS AS ( " + CRLF

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabCTT := "CTT"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT"+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC, " + CRLF
	cQuery += "  SUBSTRING(CTT_CUSTO,1,9) AS CCUSTO,"+CRLF
	cQuery += "  CTT_DESC01 AS DESCRCC"+CRLF
	cQuery += " FROM " + CRLF
	cQuery += "  "+cTabCTT+" CTT " + CRLF
	cQuery += " WHERE CTT.D_E_L_E_T_=''" + CRLF
Next

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  * " + CRLF
cQuery += "  INTO PowerBk.dbo.CCUSTOS" + CRLF
cQuery += "  FROM CCUSTOS " + CRLF
cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,CCUSTO" + CRLF

If !TCIsConnected()
  MsgAlert( "Sem conex�o com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.CCUSTOS', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.CCUSTOS "+CRLF
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
