#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSDSP2
BK - Atualização da tabela PREVDESP2 do banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/

User Function BKDSDSP2
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0
Local cProg		:= "BKDSDSP2"
Local cTabSZL   := ""
 
For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabSZL := "SZL"+cEmpresa+"0"
	cTabCTT := "CTT"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT"+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF
	cQuery += "  SUBSTRING(ZL_CONTRAT,1,9) AS CONTRATO,"+CRLF
	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
 	cQuery += "  SUBSTRING(ZL_DATA,5,2)+'/'+SUBSTRING(ZL_DATA,1,4) AS COMPET,"+CRLF
 	cQuery += "  SUBSTRING(ZL_DATA,1,6) AS COMPETAM,"+CRLF
 	cQuery += "  CONVERT(DATE,SUBSTRING(ZL_DATA,1,6)+'01',112) AS COMPETD,"+CRLF

	// Chave
	cQuery += "  '"+cEmpresa+"' + "+CRLF
	cQuery += "     SUBSTRING(ZL_CONTRAT,1,9) +  " + CRLF
	cQuery += "     SUBSTRING(ZL_DATA,1,6) AS CHAVE, " + CRLF
 	cQuery += "  SUBSTRING(ZL_DATA,1,6) + ZL_SEQ AS CHAVEZG,"+CRLF

   	cQuery += "  ZL_TIPO,"+CRLF
	cQuery += "  (CASE WHEN ZL_TIPO = '01' THEN 'BENEFICIOS' ELSE 'GASTOS GERAIS' END) AS ZLDESCTIPO,"
   	cQuery += "  ZL_DATA,"+CRLF
   	cQuery += "  ZL_HORA,"+CRLF
   	cQuery += "  ZL_CODIGO,"+CRLF
   	cQuery += "  ZL_DESC,"+CRLF
   	cQuery += "  ZL_VALOR,"+CRLF
   	cQuery += "  ZL_SEQ"+CRLF
	If nE = 1
		cQuery += "  INTO PowerBk.dbo.PREVDESP2  " + CRLF
	EndIf
	cQuery += " FROM "+cTabSZL+" SZL " + CRLF
	cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON (ZL_CONTRAT = CTT_CUSTO " + CRLF
	cQuery += " 		AND CTT_FILIAL = '01'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF
	cQuery += " WHERE SZL.D_E_L_E_T_ = '' AND ZL_DATA <> ''" + CRLF
Next
cQuery += " ORDER BY" + CRLF
cQuery += "      EMPRESA,CONTRATO,ZL_DATA,ZL_SEQ" + CRLF

If !TCIsConnected()
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.PREVDESP2', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.PREVDESP2 "+CRLF
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
