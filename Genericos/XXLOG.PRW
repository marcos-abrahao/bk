#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ xxLog    ºAutor  ³ João Carlos        º Data ³  10/06/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Grava o arquivo de log.                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ DRS                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

// Rotina de Log utilizada basicamente para gravar Queryes

User Function LogMemo(cProg,cTexto)
Local cDir:= "C:\TMP"

IF __cUserId == "000000"
	If !("\" $ cProg)
		MakeDir(cDir)
		MemoWrite(cDir+"\"+cProg,cTexto)
	Else
		MemoWrite(cProg,cTexto)
	EndIf
EndIf
Return Nil
//-----------------------------------------------------------------------------





//-----------------------------------------------------------------------------

User Function xxLog(cArqLog,cMens,lMens,cEnv)  //U_xxLog("jjErro.log","[Rotina][Funcao]"+"Erro...")
Local nPosFim,nHandle,cBuffer

DEFAULT lMens:= .t.  //Inicializa cMens com Data e Hora
DEFAULT cEnv := ""
       
If !EMPTY(cEnv) .AND. !(UPPER(TRIM(cEnv)) $ GetEnvServer())
	Return(.F.)
EndIf

If lMens  //Inicializa cMens com Data e Hora
	cMens:=DtoC(Date())+" "+Time()+" "+__cUserId+" => "+cMens
EndIf

If !File(cArqLog)
	nHandle:=fCreate(cArqLog,0)
	If nHandle==-1
		Alert("LOG ERROR: "+nHandle+" ==> Nao foi possivel criar "+cArqLog)
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


