#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSGLF
BK - Atualização da tabela GASTOSLIQFOL do banco de dados PowerBk (Movimento Bancario)

@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/

User Function BKDSGLF
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0
Local cEmpresa  := ""
Local cNomeEmp  := ""
local cCusBK    := U_MVXCUSBK()

Local cTabSZ2	:= "SZ2010"
Local cTabCTT	:= ""

Local cDescExm  := Posicione("SB1",1,xFilial("SB1")+U_MVXCEXMP(),"B1_DESC")
Local cDescDCH 	:= Posicione("SB1",1,xFilial("SB1")+U_MVXCDCH(),"B1_DESC")
Local cDescCBK	:= Posicione("SB1",1,xFilial("SB1")+cCusBK,"B1_DESC")

//u_MsgLog("BKDSGLF","Inicio: Liquidos de Folha")

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabCTT := "CTT"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF
	cQuery += "  SUBSTRING(Z2_CC,1,9) AS CONTRATO, " + CRLF
	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
 	cQuery += "  SUBSTRING(Z2_DATAPGT,5,2)+'/'+SUBSTRING(Z2_DATAPGT,1,4) AS COMPET,"+CRLF
 	cQuery += "  SUBSTRING(Z2_DATAPGT,1,6) AS COMPETAM,"+CRLF
 	cQuery += "  CONVERT(DATE,SUBSTRING(Z2_DATAPGT,1,6)+'01',112) AS COMPETD,"+CRLF

	// Chave
	cQuery += "  ('"+cEmpresa+"' + "+CRLF
	cQuery += "   SUBSTRING(Z2_CC,1,9) + " + CRLF
	cQuery += "   SUBSTRING(Z2_DATAPGT,1,6)) AS CHAVE, " + CRLF

 	cQuery += "  Z2_PRONT,"+CRLF
 	cQuery += "  Z2_NOME,"+CRLF
 	cQuery += "  Z2_TIPO,"+CRLF
 	cQuery += "  Z2_TIPOPES,"+CRLF
 	cQuery += "  Z2_VALOR,"+CRLF
 	cQuery += "  UPPER(Z2_OBSTITU) AS Z2_OBSTITU,"+CRLF

	// PRODUTO CLT

	cQuery += "    (CASE "+CRLF
	cQuery += "    	WHEN Z2_TIPO = 'VT' THEN '12' "+CRLF
	cQuery += "    	WHEN Z2_TIPO IN ('VR','VA') THEN '14' "+CRLF
	cQuery += "    	WHEN Z2_TIPO = 'EXM' THEN '"+U_MVXCEXMP()+"'"+CRLF
	cQuery += "    	WHEN Z2_TIPO IN ('DCH','SOL','HOS','REE','CXA') THEN '"+U_MVXCDCH()+"'"+CRLF
	cQuery += "     ELSE Z2_TIPO "+CRLF
	cQuery += "     END"+CRLF
	cQuery += "    ) AS PRODUTO,"+CRLF

	cQuery += "    (CASE "+CRLF
	cQuery += "    	WHEN Z2_TIPO = 'VT' THEN 'VT' "+CRLF
	cQuery += "    	WHEN Z2_TIPO IN ('VR','VA') THEN 'VR/VA' "+CRLF
	cQuery += "    	WHEN Z2_TIPO = 'EXM' THEN '"+cDescExm+"'"+CRLF
	cQuery += "    	WHEN Z2_TIPO IN ('DCH','SOL','HOS','REE','CXA') THEN '"+cDescDCH+"'"+CRLF
	cQuery += "     ELSE Z2_TIPO "+CRLF
	cQuery += "     END"+CRLF
	cQuery += "    ) AS DESCPRD"+CRLF

	If nE = 1
		cQuery += "  INTO PowerBk.dbo.GASTOSLIQFOL  " + CRLF
	EndIf

	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabSZ2+" SZ2" + CRLF

	cQuery += "LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON (Z2_CC = CTT_CUSTO " + CRLF
	cQuery += " 		AND CTT_FILIAL = '01'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "WHERE Z2_FILIAL = '  ' " + CRLF
	cQuery += "      AND SZ2.D_E_L_E_T_ = '' " + CRLF
	cQuery += "      AND SZ2.Z2_CODEMP = '"+cEmpresa+"'" + CRLF
	cQuery += "      AND SZ2.Z2_TIPO IN ('EXM','VT','VR','VA','DCH','SOL','HOS','REE','CXA') " + CRLF
	cQuery += "      AND SZ2.Z2_TIPOPES = 'CLT' " + CRLF
	cQuery += "      AND SZ2.Z2_STATUS = 'S' " + CRLF

	cQuery += "UNION ALL "+CRLF

	cQuery += " SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF
	cQuery += "  SUBSTRING(Z2_CC,1,9) AS CONTRATO, " + CRLF
	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
 	cQuery += "  SUBSTRING(Z2_DATAPGT,5,2)+'/'+SUBSTRING(Z2_DATAPGT,1,4) AS COMPET,"+CRLF
 	cQuery += "  SUBSTRING(Z2_DATAPGT,1,6) AS COMPETAM,"+CRLF
 	cQuery += "  CONVERT(DATE,SUBSTRING(Z2_DATAPGT,1,6)+'01',112) AS COMPETD,"+CRLF

	// Chave
	cQuery += "  ('"+cEmpresa+"' + "+CRLF
	cQuery += "   SUBSTRING(Z2_CC,1,9) + " + CRLF
	cQuery += "   SUBSTRING(Z2_DATAPGT,1,6)) AS CHAVE, " + CRLF

 	cQuery += "  Z2_PRONT,"+CRLF
 	cQuery += "  Z2_NOME,"+CRLF
 	cQuery += "  Z2_TIPO,"+CRLF
 	cQuery += "  Z2_TIPOPES,"+CRLF
 	cQuery += "  Z2_VALOR,"+CRLF
 	cQuery += "  UPPER(Z2_OBSTITU) AS Z2_OBSTITU,"+CRLF
	// PRODUTO AC/CLA
	cQuery += "  '"+cCusBK+"' AS PRODUTO,"+CRLF
	cQuery += "  '"+cDescCBK+"' AS DESCPRD"+CRLF

	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabSZ2+" SZ2" + CRLF

	cQuery += "LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON (Z2_CC = CTT_CUSTO " + CRLF
	cQuery += " 		AND CTT_FILIAL = '01'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "WHERE Z2_FILIAL = '  ' " + CRLF
	cQuery += "      AND SZ2.D_E_L_E_T_ = '' " + CRLF
	cQuery += "      AND SZ2.Z2_CODEMP = '"+cEmpresa+"'" + CRLF
	cQuery += "      AND SZ2.Z2_TIPOPES IN ('AC','CLA') " + CRLF
	cQuery += "      AND SZ2.Z2_STATUS = 'S' " + CRLF

Next

//cQuery += " ORDER BY" + CRLF
//cQuery += "      EMPRESA,CONTRATO,COMPETAM,D1_SERIE,D1_DOC" + CRLF

u_LogMemo("BKDSGLF.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

//Begin Transaction

	cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.GASTOSLIQFOL', N'U') IS NOT NULL"  
	cQueryD += "   DROP TABLE PowerBk.dbo.GASTOSLIQFOL "+CRLF
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

//End Transaction

u_LogMemo("BKDSGLF.SQL",cErro1+cQueryD+cErro2+cQuery)
//u_MsgLog("BKDSGLF","Final: Liquidos de Folha")

Return

