#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function LogPrw
	Grava log de acesso aos rdmakes da empresa
	@type  Function
	@author Marcos Bispo Abrahão
	@since 21/03/2022
	@version 12.1.33
/*/

// Log de acesso a rdmakes BK
User Function LogPrw(cProg,cMens)
Local cArqLog := "\log\LogPrw.log"
Default cMens := "Acesso"
Return u_xxLog(cArqLog,cProg + ": "+cMens)


// Gravar erros na execução de MSExecAuto
User Function ErrExecA(cProg,cMens,lMens)
Local cArqLog := "\log\"+AllTrim(cProg)+".log"
Local cArqErr := AllTrim(cProg)+".err"
Local cErrLog := ""

Default cMens := "Problemas na execução do MSExecAuto:"
Default lMens := .T.

cErrLog:= cMens+CRLF+MostraErro("\log\",cArqErr)
u_xxLog(cArqLog,cErrLog)

If !IsBlind() .AND. lMens
	MsgStop(cErrLog, cProg)
EndIf

Return Nil


/*/{Protheus.doc} User Function xxLog
	Grava o arquivo de log.
	@type  Function
	@author João Carlos
	@since 10/06/18
	@version 12.1.25
/*/
User Function xxLog(cArqLog,cMens,lMens,cEnv)  //U_xxLog("jjErro.log","[Rotina][Funcao]"+"Erro...")
Local nPosFim,nHandle,cBuffer

DEFAULT lMens:= .T.  //Inicializa cMens com Data e Hora
DEFAULT cEnv := ""
       
u_xxConOut("INFO","xxLog",cMens)

If lMens  //Inicializa cMens com Data e Hora
	cMens := DtoC(Date())+"|"+Time()+"|"+cEmpAnt+"|"+__cUserId+"-"+cUserName+"|"+FunName()+"|"+cMens+"|"
EndIf

If !EMPTY(cEnv) .AND. !(UPPER(TRIM(cEnv)) $ GetEnvServer())
	Return(.F.)
EndIf

If !File(cArqLog)
	nHandle:=fCreate(cArqLog,0)
	If nHandle==-1
		If !IsBlind()
			Alert("LOG ERROR: "+STR(nHandle)+" ==> Nao foi possivel criar "+cArqLog)
		EndIf
		Return(.f.)
	EndIf
	fClose(nHandle)
EndIf

nHandle := fOpen(cArqLog,2)

If fError()<>0
	If !IsBlind()
		Alert("LOG ERROR: "+fError()+" ==> Nao foi possivel abrir "+cArqLog)
	EndIf
	Return(.f.)
EndIf

cBuffer := cMens + CRLF

nPosFim := fSeek(nHandle,0,2)  //Posiciona no Fim do Arquivo               

fWrite(nHandle,cBuffer,Len(cBuffer))

If fError() <> 0
	If !IsBlind()
		Alert("LOG ERROR: "+fError()+" ==> Nao foi possivel gravar "+cArqLog)
	EndIf
	fClose(nHandle)
	Return(.f.)
EndIf

nPosFim:=fSeek(nHandle,0,2)  //Posiciona no Fim do Arquivo               

fClose(nHandle)

Return(.t.)


/*/{Protheus.doc} User Function LogMemo
	Rotina de Log utilizada basicamente para gravar Queryes
	@type  Function
	@author Marcos Bispo Abrahão
	@since 10/06/18
	@version 12.1.25
/*/

User Function LogMemo(cProg,cTexto)
Local cDir  := "C:\TMP"
Local cMens := ""
IF __cUserId == "000000" //.OR. __cUserId == "000012"
	If IsBlind()
		cDir:= "\TMP"
	ENDIF
	cMens := "-- "+DtoC(Date())+"|"+Time()+"|"+cEmpAnt+"|"+__cUserId+"-"+cUserName+"|"+FunName()+"|"+CRLF
	cMens += cTexto
	If !("\" $ cProg)
		MakeDir(cDir)
		MemoWrite(cDir+"\"+cProg,cMens)
	Else
		MemoWrite(cProg,cMens)
	EndIf
EndIf
Return Nil


/*/{Protheus.doc} User Function LogTxt
	Rotina de Log utilizada basicamente para gravar Queryes (append em arquivo já existente)
	@type  Function
	@author Marcos Bispo Abrahão
	@since 20/06/22
	@version 12.1.33
/*/
User Function LogTxt(cArqLog,cTxt)
Local nPosFim := 0
Local nHandle := 0
Local cDir    := "C:\TMP"
Local cFile   := ""
Local cTexto  := ""
Default cTxt  := ""

If __cUserId == "000000" // .OR. __cUserId == "000012"

	cTexto := "--"+DtoC(Date())+"|"+Time()+"|"+cEmpAnt+"|"+__cUserId+"-"+cUserName+"|"+FunName()+"|"+CRLF
	If !Empty(cTxt)
		cTexto += cTxt + CRLF
	EndIf

	If IsBlind()
		cDir:= "\TMP"
	ENDIF

	cFile := cDir+"\"+cArqLog
	If !File(cFile)
		nHandle := fCreate(cFile,0)
		If nHandle == -1
			If !IsBlind()
				Alert("LOG ERROR: "+STR(nHandle)+" ==> Nao foi possivel criar "+cFile)
			EndIf
			Return(.F.)
		EndIf
		fClose(nHandle)
	EndIf

	nHandle := fOpen(cFile,2)

	If fError()<>0
		If !IsBlind()
			Alert("LOG ERROR: "+fError()+" ==> Nao foi possivel abrir "+cFile)
		EndIf
		Return(.F.)
	EndIf

	nPosFim := fSeek(nHandle,0,2)  //Posiciona no Fim do Arquivo               

	fWrite(nHandle,cTexto,Len(cTexto))

	If fError() <> 0
		If !IsBlind()
			Alert("LOG ERROR: "+fError()+" ==> Nao foi possivel gravar "+cFile)
		EndIf
		fClose(nHandle)
		Return(.F.)
	EndIf

	//nPosFim := fSeek(nHandle,0,2)  //Posiciona no Fim do Arquivo               

	fClose(nHandle)
EndIf

Return(.T.)




/*/{Protheus.doc} User Function xxLog
	Funcão para substituir ConOut()
	@type  Function
	@author Marcos Bispo Abrahão
	@since 20/09/21
	@version 12.1.25
/*/

//User Function xTestLog()
//u_xxConOut("INFO","xTestLog","teste de mensagem")
//Return Nil

User Function xxConOut(cSeverity,cGroup,cMessage)
Local cCategory := FunName()
Default cSeverity := "INFO" // INFO,WARN,ERROR,FATAL,DEBUG
If !TYPE("__cUserId") == "U"
	cCategory += "-"+__cUserID
EndIf

FWLogMsg(cSeverity, /*cTransactionId*/, cGroup, cCategory, ""/*cStep*/, "01" /*cMsgId*/, cMessage, /*nMensure*/, /*nElapseTime*/, /*aMessage*/)

Return Nil



