#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSCTR
BK - Atualização da tabela CONTRATOS do banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/

User Function BKDSCTR
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0

Local cTabCN9   := ""
Local cTabSYP   := ""

//u_MsgLog("BKDSCTR","Inicio: Contratos")
 
cQuery := "WITH CTR AS ( " + CRLF

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabCN9 := "CN9"+cEmpresa+"0"
	cTabSYP := "SYP"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT"+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC, " + CRLF
	cQuery += "  SUBSTRING(CN9_NUMERO,1,9) AS CONTRATO,"+CRLF
	cQuery += "  CN9_REVISA,"+CRLF
	cQuery += "  CONVERT(DATE,CN9_DTREV,112) AS CN9_DTREV, "+CRLF
	cQuery += "  CN9_SITUAC,"+CRLF
	cQuery += "  CASE CN9_SITUAC WHEN '01' THEN 'CANCELADO' "+CRLF
	cQuery += "                  WHEN '02' THEN 'EM ELABORAÇÃO' "+CRLF
	cQuery += "                  WHEN '03' THEN 'EMITIDO' "+CRLF
	cQuery += "                  WHEN '04' THEN 'EM APROVAÇÃO' "+CRLF
	cQuery += "                  WHEN '05' THEN 'VIGENTE' "+CRLF
	cQuery += "                  WHEN '06' THEN 'PARALISADO' "+CRLF
	cQuery += "                  WHEN '07' THEN 'SOL. FINALIZAÇÃO' "+CRLF
	cQuery += "                  WHEN '08' THEN 'FINALIZADO' "+CRLF
	cQuery += "                  WHEN '09' THEN 'EM REVISÃO' "+CRLF
	cQuery += "                  WHEN '10' THEN 'REVISADO' "+CRLF
	cQuery += "                  WHEN 'A'  THEN 'EM REVISÃO - APROVAÇÃO POR ALÇADAS' "+CRLF
	cQuery += "                  ELSE 'INDEFINIDO' END AS SITUACAO, "+CRLF
	cQuery += "  CN9_NOMCLI,"+CRLF
	cQuery += "  CN9_GESTC, "+CRLF
	cQuery += "  CN9_XXNRBK,"+CRLF
	cQuery += "  CN9_XXNGC, "+CRLF
	cQuery += "  CN9_XXEGC, "+CRLF
	cQuery += "  CN9_XXTELS,"+CRLF
	cQuery += "  CN9_VLINI, "+CRLF
	cQuery += "  CN9_VLATU, "+CRLF
	cQuery += "  CN9_SALDO, "+CRLF
	cQuery += "  CONVERT(DATE,CN9_DTINIC,112) AS CN9_DTINIC,"+CRLF
	cQuery += "  CONVERT(DATE,CN9_DTASSI,112) AS CN9_DTASSI,"+CRLF
	cQuery += "  CONVERT(DATE,CN9_DTOSER,112) AS CN9_DTOSER,"+CRLF
	cQuery += "  CONVERT(DATE,CN9_XXDVIG,112) AS CN9_XXDVIG,"+CRLF
	cQuery += "  CONVERT(DATE,CN9_XXDREP,112) AS CN9_XXDREP,"+CRLF
	cQuery += "  CN9_XXOREP,"+CRLF
	cQuery += "  CN9_XX5DIA,"+CRLF

	cQuery += "  UPPER(REPLACE ("+CRLF
	cQuery += "    ("+CRLF
	cQuery += "      SELECT "+CRLF
	cQuery += "        RTRIM(YP_TEXTO) "+CRLF
	cQuery += "      FROM "+CRLF
	cQuery += "        "+cTabSYP+" SYP"+CRLF
	cQuery += "      WHERE "+CRLF
	cQuery += "        CN9.CN9_CODOBJ = SYP.YP_CHAVE"+CRLF
	cQuery += "        AND SYP.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "      ORDER BY "+CRLF
	cQuery += "        YP_CHAVE + YP_SEQ FOR XML PATH (''), "+CRLF
	cQuery += "        TYPE"+CRLF
	cQuery += "    ).value('.', 'varchar(1000)'),'\13\10',' '))"+CRLF
	cQuery += "    AS OBJETO, "+CRLF

	cQuery += "  CONVERT(VARCHAR(600),CONVERT(Binary(600),CN9_XXOBS)) CN9_XXOBS,"+CRLF

	cQuery += "  UPPER(REPLACE ("+CRLF
	cQuery += "    ("+CRLF
	cQuery += "      SELECT "+CRLF
	cQuery += "        RTRIM(YP_TEXTO) "+CRLF
	cQuery += "      FROM "+CRLF
	cQuery += "        "+cTabSYP+" SYP"+CRLF
	cQuery += "      WHERE "+CRLF
	cQuery += "        CN9.CN9_CODJUS = SYP.YP_CHAVE"+CRLF
	cQuery += "        AND SYP.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "      ORDER BY "+CRLF
	cQuery += "        YP_CHAVE + YP_SEQ FOR XML PATH (''), "+CRLF
	cQuery += "        TYPE"+CRLF
	cQuery += "    ).value('.', 'varchar(1000)'),'\13\10',' '))"+CRLF
	cQuery += "    AS JUSTIF "+CRLF

	cQuery += " FROM " + CRLF
	cQuery += "  "+cTabCN9+" CN9 " + CRLF

	cQuery += " WHERE CN9.D_E_L_E_T_=''" + CRLF
	//cQuery += "      AND CN9_REVATU = ' ' OR CN9_SITUAC = '05' " + CRLF
	
Next

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  *, " + CRLF
cQuery += "  (EMPRESA+CONTRATO+CN9_REVISA) AS CHAVE " + CRLF
cQuery += "  INTO PowerBk.dbo.CONTRATOS  " + CRLF
cQuery += "  FROM CTR " + CRLF

cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,CONTRATO,CN9_REVISA" + CRLF

u_LogMemo("BKDSCTR.SQL",cQuery)

If !TCIsConnected()
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.CONTRATOS', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.CONTRATOS "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	u_MsgLog(cPerg,cErro1,"E")
EndIf

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	u_MsgLog(cPerg,cErro2,"E")
EndIf

u_LogMemo("BKDSCTR.SQL",cErro1+cQueryD+cErro2+cQuery)
//u_MsgLog("BKDSCTR","Final: Contratos")

Return
