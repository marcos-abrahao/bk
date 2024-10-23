#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSDSP1
BK - Atualização da tabela PREVDESP1 do banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/

User Function BKDSDSP1
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0
Local cProg		:= "BKDSDSP1"
Local cTabSZG   := ""

//u_MsgLog("BKDSDSP1","Inicio: Previsão de despesas 1")
 
For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabSZG := "SZG"+cEmpresa+"0"
	cTabCTT := "CTT"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT"+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF
	cQuery += "  SUBSTRING(ZG_CONTRAT,1,9) AS CONTRATO,"+CRLF
	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
 	cQuery += "  SUBSTRING(ZG_DATA,5,2)+'/'+SUBSTRING(ZG_DATA,1,4) AS COMPET,"+CRLF
 	cQuery += "  SUBSTRING(ZG_DATA,1,6) AS COMPETAM,"+CRLF
 	cQuery += "  CONVERT(DATE,SUBSTRING(ZG_DATA,1,6)+'01',112) AS COMPETD,"+CRLF

	// Chave
	cQuery += "  '"+cEmpresa+"' + "+CRLF
	cQuery += "     SUBSTRING(ZG_CONTRAT,1,9) +  " + CRLF
	cQuery += "     SUBSTRING(ZG_DATA,1,6) AS CHAVE, " + CRLF
 	cQuery += "  SUBSTRING(ZG_DATA,1,6) + ZG_SEQ AS CHAVEZG,"+CRLF

   	cQuery += "  ZG_DATA,"+CRLF
   	cQuery += "  ZG_HORA,"+CRLF
   	cQuery += "  ZG_CLT,"+CRLF
   	cQuery += "  ZG_ENCSOC,"+CRLF
   	cQuery += "  ZG_VLENCSO,"+CRLF
   	cQuery += "  ZG_AJCUSTO,"+CRLF
   	cQuery += "  ZG_ENCAC,"+CRLF
   	cQuery += "  ZG_VLENAC,"+CRLF
   	cQuery += "  ZG_INSUMOS,"+CRLF
   	cQuery += "  ZG_BENEFIC,"+CRLF
   	cQuery += "  ZG_EQUIPAM,"+CRLF
   	cQuery += "  ZG_UNIFORM,"+CRLF
   	cQuery += "  ZG_DESPDIV,"+CRLF
   	cQuery += "  ZG_TRIBUTO,"+CRLF
   	cQuery += "  ZG_VLTRIBU,"+CRLF
   	cQuery += "  ZG_RENTABI,"+CRLF
   	cQuery += "  ZG_VLRENTA,"+CRLF
   	cQuery += "  ZG_TOTAL,"+CRLF
   	cQuery += "  ZG_USUARIO,"+CRLF
   	cQuery += "  ZG_SEQ,"+CRLF
   	cQuery += "  ZG_DATAI,"+CRLF
   	cQuery += "  ZG_HORAI"+CRLF
	If nE = 1
		cQuery += "  INTO PowerBk.dbo.PREVDESP1  " + CRLF
	EndIf
	cQuery += " FROM "+cTabSZG+" SZG " + CRLF
	cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON (ZG_CONTRAT = CTT_CUSTO " + CRLF
	cQuery += " 		AND CTT_FILIAL = '01'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF
	cQuery += " WHERE SZG.D_E_L_E_T_ = '' " + CRLF
Next
cQuery += " ORDER BY" + CRLF
cQuery += "      EMPRESA,CONTRATO,ZG_DATA,ZG_SEQ" + CRLF

If !TCIsConnected()
  u_MsgLog("BKDSDSP1","Sem conexão com o banco de dados")
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.PREVDESP1', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.PREVDESP1 "+CRLF
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
