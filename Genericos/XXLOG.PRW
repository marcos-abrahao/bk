#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function xxLog
	Grava o arquivo de log.
	@type  Function
	@author João Carlos
	@since 10/06/18
	@version 12.1.25
/*/

User Function xxLog(cArqLog,cMens,lMens,cEnv)  //U_xxLog("jjErro.log","[Rotina][Funcao]"+"Erro...")
Local nPosFim,nHandle,cBuffer

DEFAULT lMens:= .t.  //Inicializa cMens com Data e Hora
DEFAULT cEnv := ""
       
u_xxConOut("INFO","xxLog",cMens)

If lMens  //Inicializa cMens com Data e Hora
	cMens:=DtoC(Date())+" "+Time()+" "+__cUserId+" => "+cMens
EndIf

If !EMPTY(cEnv) .AND. !(UPPER(TRIM(cEnv)) $ GetEnvServer())
	Return(.F.)
EndIf

If !File(cArqLog)
	nHandle:=fCreate(cArqLog,0)
	If nHandle==-1
		Alert("LOG ERROR: "+STR(nHandle)+" ==> Nao foi possivel criar "+cArqLog)
		Return(.f.)
	EndIf
	fClose(nHandle)
EndIf

nHandle:=fOpen(cArqLog,2)

If fError()<>0
	Alert("LOG ERROR: "+fError()+" ==> Nao foi possivel abrir "+cArqLog)
	Return(.f.)
EndIf

cBuffer:=cMens+Chr(13)+Chr(10)

nPosFim:=fSeek(nHandle,0,2)  //Posiciona no Fim do Arquivo               

fWrite(nHandle,cBuffer,Len(cBuffer))

If fError()<>0
	Alert("LOG ERROR: "+fError()+" ==> Nao foi possivel gravar "+cArqLog)
	fClose(nHandle)
	Return(.f.)
EndIf

nPosFim:=fSeek(nHandle,0,2)  //Posiciona no Fim do Arquivo               

fClose(nHandle)

Return(.t.)


/*/{Protheus.doc} User Function xxLog
	Rotina de Log utilizada basicamente para gravar Queryes
	@type  Function
	@author Marcos Bispo Abrahão
	@since 10/06/18
	@version 12.1.25
/*/

User Function LogMemo(cProg,cTexto)
Local cDir:= "C:\TMP"

IF __cUserId == "000000" .OR. __cUserId == "000012"
	If !("\" $ cProg)
		MakeDir(cDir)
		MemoWrite(cDir+"\"+cProg,cTexto)
	Else
		MemoWrite(cProg,cTexto)
	EndIf
EndIf
Return Nil


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

