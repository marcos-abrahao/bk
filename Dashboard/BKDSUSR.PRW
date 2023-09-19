#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSUSR
BK - Atualização da tabela USUARIOS do banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/

User Function BKDSUSR
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aUsersF	:= FWSFALLUSERS()
Local aGrupos   := AllGroups()
Local aGrpUsr   := {}
Local nZ 		:= 0
Local nX 		:= 0
Local xUsrCodigo:= ""
Local xUsrConta := ""
Local xUsrSenha := ""
Local xUsrNome  := ""
Local xUsrEmail := ""
Local xUsrGrupo := ""
Local xUsrDepto := ""
Local xUsrBloq  := ""
Local xUsrUltLog:= ""
Local nPosGrp   := 0

//u_MsgLog("BKDSUSR","Inicio: Usuários")

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.USUARIOS', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.USUARIOS "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	u_MsgLog(cPerg,cErro1,"E")
EndIf

cQuery := "CREATE TABLE PowerBk.dbo.USUARIOS " + CRLF
cQuery += "( " + CRLF
cQuery += "  CODIGO    VARCHAR(06), " + CRLF
cQuery += "  USUARIO   VARCHAR(50), " + CRLF
cQuery += "  NOME      VARCHAR(50), " + CRLF
cQuery += "  EMAIL     VARCHAR(50), " + CRLF
cQuery += "  GRUPO     VARCHAR(100)," + CRLF
cQuery += "  SENHA     VARCHAR(100)," + CRLF
cQuery += "  DEPTO     VARCHAR(100)," + CRLF
cQuery += "  ULTLOG    VARCHAR(100)," + CRLF
cQuery += "  BLOQUEADO VARCHAR(03), " + CRLF    
cQuery += "  DTRUN     VARCHAR(50), " + CRLF
cQuery += "  PRIMARY KEY (CODIGO)         " + CRLF
cQuery += ") " + CRLF

nErro   := TcSqlExec(cQuery)
If nErro != 0
	cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	u_MsgLog(cPerg,cErro2,"E")
EndIf

For nX := 1 To Len(aUsersF)
    // Popula elemento
    xUsrCodigo   := aUsersF[nX][02]                                              //CODIGO
    xUsrConta    := Upper(FWSFUser(xUsrCodigo,"DATAUSER","USR_CODIGO",.F.))      //USUARIO
    xUsrSenha    := RTrim(FWSFUser(xUsrCodigo,"DATAUSER","USR_PSWMD5",.F.))      //SENHA
    xUsrNome     := Upper(FWSFUser(xUsrCodigo,"DATAUSER","USR_NOME",.F.))        //NOME
    xUsrEmail    := Upper(FWSFUser(xUsrCodigo,"DATAUSER","USR_EMAIL",.F.))       //EMAIL
    xUsrGrupo    := ""
    xUsrDepto    := Upper(FWSFUser(xUsrCodigo,"DATAUSER","USR_DEPTO",.F.))       //DEPARTAMENTO
    xUsrBloq     := RTrim(FWSFUser(xUsrCodigo,"DATAUSER","USR_MSBLQL",.F.))      //BLOQUEADO
    xUsrUltLog   := FWUsrUltLog(xUsrCodigo)                                      //INFORMACOES DE LOGIN

    // Obtem grupos de acesso do usuario
    aGrpUsr := FWSFUsrGrps(xUsrCodigo)
    For nZ := 1 To Len(aGrpUsr)
        nPosGrp   := aScan(aGrupos, {|elem| AllTrim(elem[1][1]) == AllTrim(aGrpUsr[nZ])})
        xUsrGrupo += Upper(AllTrim(aGrupos[nPosGrp][1][2])) + "#"
    Next nZ
    cQuery := "INSERT INTO PowerBk.dbo.USUARIOS " + CRLF
    cQuery += "("         + CRLF
    cQuery += "CODIGO,"   + CRLF
    cQuery += "USUARIO,"  + CRLF
    cQuery += "NOME,"     + CRLF
    cQuery += "EMAIL,"    + CRLF
    cQuery += "GRUPO,"    + CRLF
    cQuery += "SENHA,"    + CRLF
    cQuery += "DEPTO,"    + CRLF
    cQuery += "ULTLOG,"   + CRLF
    cQuery += "BLOQUEADO,"+ CRLF
    cQuery += "DTRUN"     + CRLF
    cQuery += ")"         + CRLF
    cQuery += "VALUES"    + CRLF
    cQuery += "("         + CRLF
    cQuery += "'" + xUsrCodigo   + "',"    + CRLF
    cQuery += "'" + xUsrConta    + "',"    + CRLF
    cQuery += "'" + xUsrNome     + "',"    + CRLF
    cQuery += "'" + xUsrEmail    + "',"    + CRLF
    cQuery += "'" + xUsrGrupo    + "',"    + CRLF
    cQuery += "'" + xUsrSenha    + "',"    + CRLF
    cQuery += "'" + xUsrDepto    + "',"    + CRLF    
    cQuery += "'" + "DATA: " + DtoC(xUsrUltLog[1]) + " HORA: " + xUsrUltLog[2] + " WORKSTATION: " + xUsrUltLog[4] + "'," + CRLF
    cQuery += "'" + IIf( xUsrBloq == "1", "SIM", "NAO" ) + "'," + CRLF                 
    cQuery += "'" + DtoC(Date()) + "'  " + CRLF
    cQuery += ")"

	nErro   := TcSqlExec(cQuery)
	If nErro != 0
		cErro2  += "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	    u_MsgLog(cPerg,cErro2,"E")
	EndIf
Next nX

u_LogMemo("BKDSUSR.SQL",cErro1+cQueryD+cErro2+cQuery)
//u_MsgLog("BKDSUSR","Final: Usuários")

Return

