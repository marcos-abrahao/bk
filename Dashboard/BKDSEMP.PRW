#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSEMP
BK - Atualização da tabela EMPRESAS do banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/

User Function BKDSEMP
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local nX 		:= 0
Local aEmpresas := u_BKGrupo(1)

//u_MsgLog("BKDSEMP","Inicio: Empresas")

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.EMPRESAS', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.EMPRESAS "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	u_MsgLog(cPerg,cErro1,"E")
EndIf

cQuery := "CREATE TABLE PowerBk.dbo.EMPRESAS " + CRLF
cQuery += "( " + CRLF
cQuery += "  EMPRESA VARCHAR(02), " + CRLF
cQuery += "  NOMEEMP VARCHAR(15), " + CRLF
cQuery += "  PRIMARY KEY (EMPRESA)" + CRLF
cQuery += ") " + CRLF

nErro   := TcSqlExec(cQuery)
If nErro != 0
	cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	u_MsgLog(cPerg,cErro2,"E")
EndIf

For nX := 1 To Len(aEmpresas)
    // Popula elemento
    cQuery := "INSERT INTO PowerBk.dbo.EMPRESAS " + CRLF
    cQuery += "("         + CRLF
    cQuery += "EMPRESA,"  + CRLF
    cQuery += "NOMEEMP"   + CRLF
    cQuery += ")"         + CRLF
    cQuery += "VALUES"    + CRLF
    cQuery += "("         + CRLF
    cQuery += "'" + aEmpresas[nX,1] + "',"    + CRLF
    cQuery += "'" + aEmpresas[nX,2] + "'"    + CRLF
    cQuery += ")"

	nErro   := TcSqlExec(cQuery)
	If nErro != 0
		cErro2  += "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		u_MsgLog(cPerg,cErro2,"E")
	EndIf
Next nX

u_LogMemo("BKDSEMP.SQL",cErro1+cQueryD+cErro2+cQuery)
//u_MsgLog("BKDSEMP","Final: Empresas")

Return
