#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSPRD
BK - Atualização da tabela PRODUTOS do banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 12/11/2024
@version P12
/*/

User Function BKDSPRD
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrupo()
Local nE 		:= 0
Local cTabSB1   := ""
Local cTabCT1   := ""
Local cTabSZI   := "SZI010"
Local cTabSBM   := "SBM010"
Local cProg		:= "BKDSPRD"

cQuery := "WITH PRODUTOS AS ( " + CRLF

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabSB1 := "SB1"+cEmpresa+"0"
	cTabCT1 := "CT1"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT"+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA"+CRLF
	cQuery += " ,'"+cNomeEmp+"' AS NOMEEMP"+CRLF
	cQuery += " ,GETDATE() AS DATAPRC " + CRLF
	cQuery += " ,B1_COD "+CRLF
	cQuery += " ,B1_DESC "+CRLF
	cQuery += " ,B1_UM "+CRLF
	cQuery += " ,B1_UREV "+CRLF
	cQuery += " ,B1_XXSGRP "+CRLF
	cQuery += " ,ZI_DESC "+CRLF
	cQuery += " ,B1_GRUPO "+CRLF
	cQuery += " ,BM_DESC "+CRLF
	cQuery += " ,B1_CONTA "+CRLF
	cQuery += " ,CT1_DESC01 "+CRLF
	cQuery += " ,(CASE WHEN B1_MSBLQL = '1' THEN 'BLOQUEADO' ELSE 'EM USO' END) AS BLOQUEIO "+CRLF

	cQuery += " FROM "+cTabSB1+" SB1 "+CRLF
	cQuery += " LEFT JOIN "+cTabCT1+" CT1 ON "+CRLF
	cQuery += "  	CT1_CONTA = B1_CONTA "+CRLF
	cQuery += "  	AND CT1.D_E_L_E_T_ = '' "+CRLF
	cQuery += " LEFT JOIN "+cTabSZI+" SZI ON ZI_COD = B1_XXSGRP AND SZI.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += " LEFT JOIN "+cTabSBM+" SBM ON BM_GRUPO = B1_GRUPO AND SBM.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += " WHERE SB1.D_E_L_E_T_ = '' "+CRLF
	cQuery += "     AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "+CRLF
Next

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  * " + CRLF
cQuery += "  INTO PowerBk.dbo.PRODUTOS" + CRLF
cQuery += "  FROM PRODUTOS " + CRLF
cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,B1_COD" + CRLF

If !TCIsConnected()
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.PRODUTOS', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.PRODUTOS "+CRLF
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
