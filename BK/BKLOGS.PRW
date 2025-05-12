#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} User Function MsgLog
	Grava log de acesso aos rdmakes da empresa
	@type  Function
	@author Marcos Bispo Abrahão
	@since 21/03/2022
	@version 12.1.33
/*/

/*
Log e mensagens - rdmakes BK

FWAlertError: Mostra uma mensagem com um círculo vermelho e um x no meio
FWAlertExitPage: Mostra uma pergunta com 3 opções (Continuar editando, Salvar, Sair da Página)
FWAlertHelp: Mostra uma mensagem de help e solução
FWAlertInfo: Mensagem informativa com um círculo azul e um i no meio
FWAlertNoYes: Mensagem que tem 2 opções (Não e Sim)
FWAlertSuccess: Mostra uma mensagem com um círculo verde e um ícone de check
FWAlertWarning: Mostra uma mensagem com um triângulo amarelo e uma exclamação no meio
FWAlertYesNo: Mensagem que tem 2 opções (Sim e Não)
*/

// Gerar log Somente para o Admin
User Function MsgLogAdm(cProg,cMens,cAlert,cTxt)
Local lRet := .F.
If __cUserId == "000000"
	lRet := u_MsgLog(cProg,cMens,cAlert,cTxt)
EndIf
Return lRet


User Function MsgLog(cProg,cMens,cAlert,cTxt)
Local cArqLog  := u_SlogDir()+"msglog-"+SUBSTR(DTOS(DATE()),1,6)+".log"
Local lRet     := .T.

Default cProg  := FunName()
Default cMens  := "Acesso"
Default cAlert := " "
Default cTxt   := ""

If !IsBlind() .AND. !Empty(cAlert)
	If cAlert == "I"
		FWAlertInfo(cMens,cProg)
	ElseIf cAlert == "W"
		FWAlertWarning(cMens,cProg)
	ElseIf cAlert == "E"
		FWAlertError(cMens,cProg)
	ElseIf cAlert == "S"
		FWAlertSuccess(cMens,cProg)
	ElseIf cAlert == "Y"
		lRet := FWAlertYesNo(cMens,cProg)
		If lRet
			cMens += ": Sim"
		Else
			cMens += ": Nao"
		EndIf
	ElseIf cAlert == "N"
		lRet := FWAlertNoYes(cMens,cProg)
		If lRet
			cMens += ": Sim"
		Else
			cMens += ": Nao"
		EndIf
	Else
		If Empty(cTxt)
			FWAlertHelp(cMens,cProg)
		EndIf
	EndIf
EndIf

u_xxLog(cArqLog,cProg + ": "+cMens)
If !Empty(cTxt)
	u_xxLog(u_SlogDir()+AllTrim(cProg)+".log",cProg + ": "+cMens,cTxt)
	If !IsBlind() .AND. !Empty(cAlert)
		FWAlertHelp(AllTrim(cTxt),cProg)
	EndIf
EndIf
Return lRet


/*/{Protheus.doc} User Function AvisoLog
	Grava log de resposta para a função Aviso()
	@type  Function
	@author Marcos Bispo Abrahão
	@since 23/12/2022
	@param
		cProg			Caracter	Nome da rotina para gravar no log.
		cTitulo	        Caracter	Título da janela.	
		cMsg	        Caracter	Texto a ser apresentado na janela.	
		aBotoes	        Vetor	    Array com as opções dos botões.	
		nSize	        Numérico	Tamanho da janela. Pode ser 1, 2 ou 3.	
		cText	        Caracter	Titulo da Descrição (Dentro da Janela)	cTitulo	
		nRotAutDefault	Numérico	Opção padrão usada pela rotina automática.	
		cBitmap	        Caracter	Nome do bitmap a ser apresentado (AVISO: O parâmetro cBitmap foi depreciado, para que a função fique de acordo com o layout do Protheus 12)	
		lEdit	        Lógico	    Determina se permite a edição do campo memo.	.F.	
		nTimer	        Numérico	Tempo para exibição da mensagem em segundos.	
		nOpcPadrao	    Numérico	Opção padrão apresentada na mensagem.	
	@version 12.1.33
*/

User Function AvisoLog(cProg,cTitulo,cMsg,aBotoes,nSize,cText,nRotAutDefault,cBitmap,lEdit,nTimer,nOpcPadrao)
Local cArqLog  := u_SlogDir()+"msglog-"+SUBSTR(DTOS(DATE()),1,6)+".log"
Local nRet     := 0
Local cMens    := cMsg
Default cProg  := FunName()
Default cText  := cProg
Default nSize  := 2

nRet := Aviso(cTitulo,cMsg,aBotoes,nSize,cText,nRotAutDefault,cBitmap,lEdit,nTimer,nOpcPadrao)
If !Empty(nRet)
	cMens += ": "+aBotoes[nRet]
EndIf

u_xxLog(cArqLog,cProg + ": "+cMens)

Return nRet



/*/{Protheus.doc} User Function xxLog
	Grava o arquivo de log.
	@type  Function
	@author João Carlos
	@since 10/06/18
	@version 12.1.25
/*/
Static cPorta := GetPvProfString("TCP", "Port", "", GetAdv97())
User Function xxLog(cArqLog,cMens,cTxt)
Local nPosFim := 0
Local nHandle := 0
Local cBuffer := ""

Default cTxt  := ""

Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

cMens := STRTRAN( cMens, CRLF, " ")
If Type("cEmpAnt") == "U"
	cMens := DtoC(Date())+"|"+Time()+"||||||"+cMens+"|"
Else
	//cMens := DtoC(Date())+"|"+Time()+"|"+cEmpAnt+"|"+__cUserId+"-"+cUserName+"|"+cValToChar(nModulo)+"|"+IIF(!FWIsInCallStack("HISTLOG"),FWGetMnuFile(),"HISTLOG")+"|"+FunName()+"|"+GetEnvServer()+"-"+cPorta+"|"+cMens+"|" 
	cMens := DtoC(Date())+"|"+Time()+"|"+cEmpAnt+"|"+__cUserId+"-"+cUserName+"|"+cValToChar(nModulo)+"|"+cArqLog+"|"+FunName()+"|"+GetEnvServer()+"-"+cPorta+"|"+cMens+"|" 
EndIf

If !Empty(cTxt)
	cMens += CRLF+cTxt+CRLF
EndIf

If !File(cArqLog)
	nHandle:=fCreate(cArqLog,0)
	If nHandle==-1
		If !IsBlind()
			FWAlertError("LOG ERROR: "+STR(nHandle),"Nao foi possivel criar o arquivo"+cArqLog)
		EndIf
		Return(.f.)
	EndIf
	fClose(nHandle)
EndIf

nHandle := fOpen(cArqLog,2)

If fError() <> 0
	If !IsBlind()
		FWAlertError("LOG ERROR: "+fError(),"Nao foi possivel abrir o arquivo "+cArqLog)
	EndIf
	Return(.f.)
EndIf

cBuffer := cMens + CRLF

nPosFim := fSeek(nHandle,0,2)  //Posiciona no Fim do Arquivo               

fWrite(nHandle,cBuffer,Len(cBuffer))

If fError() <> 0
	If !IsBlind()
		FWAlertError("LOG ERROR: "+fError(),"Nao foi possivel gravar o arquivo "+cArqLog)
	EndIf
	fClose(nHandle)
	Return(.f.)
EndIf

nPosFim:=fSeek(nHandle,0,2)  //Posiciona no Fim do Arquivo               

fClose(nHandle)

Return(.t.)



// Gravar log de processamentos

User Function WaitLog(cProg,bFunction,cMens)
Local cTimeI := Time()
Default cProg := FunName()
Default cMens := "Aguarde o processamento..."
If !IsBlind()
	FWMsgRun(, {|oSay| Eval(bFunction,oSay) }, "", cProg+": "+cMens)
Else
	Eval(bFunction)
EndIf
u_MsgLog(cProg,cMens + " ("+elapTime(cTimeI,Time())+")")

// Para atualizar a mensagem
//		oSay:SetText("Aguarde...")
//		ProcessMessages()

Return Nil


// Mensagens e log de erros na execução de MSExecAuto
User Function LogMsExec(cProg,cMens,cAlerta)
Local cArqErr := AllTrim(cProg)+".err"
Local cErrLog := ""
Default cAlerta := "E"

Default cProg := FunName()
Default cMens := "Problemas na execução do MSExecAuto:"

cErrLog := MostraErro(u_SLogDir(),cArqErr)
u_MsgLog(cProg,cMens,cAlerta,cErrLog)

Return cErrLog


/*/{Protheus.doc} User Function LogMemo
	Rotina de Log utilizada basicamente para gravar Queryes
	@type  Function
	@author Marcos Bispo Abrahão
	@since 10/06/18
	@version 12.1.25
/*/

User Function LogMemo(cProg,cTexto)
Local cDir  := u_LTmpDir()
Local cMens := ""
IF __cUserId $ "000000/000038" .OR. IsBlind() //Usuários admin e teste
	If IsBlind()
	ENDIF
	//cMens := "-- "+DtoC(Date())+"|"+Time()+"|"+cEmpAnt+"|"+__cUserId+"-"+cUserName+"|"+FunName()+"|"+CRLF
	//cMens := "-- "+DtoC(Date())+"|"+Time()+"|"+cEmpAnt+"|"+__cUserId+"-"+cUserName+"|"+cValToChar(nModulo)+"|"+FWGetMnuFile()+"|"+FunName()+"|"+GetEnvServer()+"|"+CRLF
	cMens := "-- "+DtoC(Date())+"|"+Time()+"|"+cEmpAnt+"|"+__cUserId+"-"+cUserName+"|"+cValToChar(nModulo)+"|"+cProg+"|"+FunName()+"|"+GetEnvServer()+"|"+CRLF

	cMens += cTexto
	If !("\" $ cProg)
		MakeDir(cDir)
		MemoWrite(cDir+cProg,cMens)
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
User Function LogTxt(cArqLog,cTxt,aBinds)
Local nPosFim 	:= 0
Local nHandle 	:= 0
Local cDir    	:= u_LTmpDir()
Local cFile   	:= ""
Local cTexto  	:= ""
Local nI 		:= 0

Default cTxt  	:= ""
Default aBinds	:= {}

If __cUserId == "000000" //.OR. IsBlind()

	cTexto := "--"+DtoC(Date())+"|"+Time()+"|"+cEmpAnt+"|"+__cUserId+"-"+cUserName+"|"+FunName()+"|"+CRLF
	
	If Len(aBinds) > 0
		cTexto += "-- Parametros:"
		For nI := 1 To Len(aBinds)
			cTexto += " "+cValToChar(aBinds[nI])
		Next
		cTexto += CRLF
	EndIf
	If !Empty(cTxt)
		cTexto += cTxt + CRLF
	EndIf
	
	If IsBlind()
		cDir:= u_SLogDir()
	ENDIF

	cFile := cDir+cArqLog
	If !File(cFile)
		nHandle := fCreate(cFile,0)
		If nHandle == -1
			If !IsBlind()
				FWAlertError("LOG ERROR: "+STR(nHandle),"Nao foi possivel criar "+cFile)
			EndIf
			Return(.F.)
		EndIf
		fClose(nHandle)
	EndIf

	nHandle := fOpen(cFile,2)

	If fError()<>0
		If !IsBlind()
			FWAlertError("LOG ERROR: "+STR(fError()),"Nao foi possivel abrir "+cFile)
		EndIf
		Return(.F.)
	EndIf

	nPosFim := fSeek(nHandle,0,2)  //Posiciona no Fim do Arquivo               

	fWrite(nHandle,cTexto,Len(cTexto))

	If fError() <> 0
		If !IsBlind()
			FWAlertError("LOG ERROR: "+STR(fError()),"Nao foi possivel gravar "+cFile)
		EndIf
		fClose(nHandle)
		Return(.F.)
	EndIf

	//nPosFim := fSeek(nHandle,0,2)  //Posiciona no Fim do Arquivo               

	fClose(nHandle)
EndIf

Return(.T.)


/*/{Protheus.doc} User Function xxConOut
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



/*/{Protheus.doc} LogMvc
    Gerar log de alteração em cadastros MVC
    Usar no ponto de entrada FORMCOMMITTTSPRE

    @type  Function
    @author Marcos Bispo Abrahão
    @since 25/08/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (Veja CRMA980_PE)
    @see (links_or_references)
    /*/

User Function LogMvc(cPrw,cAlias,nOper,oModelMVC,cID,aNoFields)
Local aFields   := {}
Local nX        := 0
Local nY 		:= 0
Local cAntes    := ""
Local cDepois   := ""

Default aNoFields := {}

IF nOper == 3 //Caso seja Inclusao

    u_MsgLog(cPrw,"Inclusão "+cID)

ElseIF nOper == 4 // Alteração

    aFields   := oModelMVC:GetStruct():GetFields()

    IF Len(aFields) > 0

        For nX := 1 To Len( aFields )

            cAntes  := ""
            cDepois := ""
                    
            IF aScan(aNoFields, Alltrim(aFields[nX][MODEL_FIELD_IDFIELD]) ) == 0 
                If oModelMVC:IsFieldUpdated( aFields[nX][MODEL_FIELD_IDFIELD] ) .And. !aFields[nX][MODEL_FIELD_VIRTUAL]

                    IF aFields[nX][MODEL_FIELD_TIPO] $ 'N/L'
                        cAntes  := Alltrim(AlltoChar((cAlias)->&(aFields[nX][MODEL_FIELD_IDFIELD])))
                        cDepois := Alltrim(AlltoChar(FwFldGet( aFields[nX][MODEL_FIELD_IDFIELD] )))

                    ElseIF aFields[nX][MODEL_FIELD_TIPO] == 'D'
                        cAntes  := DtoC((cAlias)->&(aFields[nX][MODEL_FIELD_IDFIELD]))
                        cDepois := DtoC(FwFldGet( aFields[nX][MODEL_FIELD_IDFIELD] ))

                    ElseIF aFields[nX][MODEL_FIELD_TIPO] $ 'CM'
                        IF Len(aFields[nX][MODEL_FIELD_VALUES]) > 0
                            aCombo := aFields[nX][MODEL_FIELD_VALUES]

                            IF Empty((cAlias)->&(aFields[nX][MODEL_FIELD_IDFIELD]))
                                cAntes := (cAlias)->&(aFields[nX][MODEL_FIELD_IDFIELD])
                            Else
								nY := Ascan( aCombo , (cAlias)->&(aFields[nX][MODEL_FIELD_IDFIELD]) + "=" )
								If nY > 0
                                	cValorAnt := aCombo[ nY ]
                                	cAntes := cValorAnt
								EndIf
                            EndIF

                            IF Empty(FwFldGet( aFields[nX][MODEL_FIELD_IDFIELD	]))
                                cDepois := FwFldGet( aFields[nX][MODEL_FIELD_IDFIELD])
                            Else
								nY := Ascan( aCombo , FwFldGet( aFields[nX][MODEL_FIELD_IDFIELD]) + "=" )
								If nY > 0
                                	cValorAtu := aCombo[nY]
                                	cDepois := cValorAtu
								EndIf
                            EndIF
                        Else
                            cAntes := (cAlias)->&(aFields[nX][MODEL_FIELD_IDFIELD])
                            cDepois := FwFldGet( aFields[nX][MODEL_FIELD_IDFIELD] )
                        EndIF
                    EndIF

                    u_MsgLog(cPrw,"Alteração "+cID+" : "+aFields[nX][MODEL_FIELD_IDFIELD]+ " Antes: "+TRIM(cAntes)+" - Depois: "+TRIM(cDepois))

                EndIF
            EndIF
        Next nX
    EndIF
ElseIF nOper == 5 // Exclusão
    u_MsgLog(cPrw,"Exclusão "+cID)
Else
    u_MsgLog(cPrw,"Operação ("+ALLTRIM(STR(nOper))+") "+cID)
EndIf

Return Nil

