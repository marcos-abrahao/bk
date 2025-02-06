#Include "Protheus.ch"
#Include "AP5MAIL.CH"
 
/*/{Protheus.doc} BkSnMail
Fun��o para disparo do e-mail utilizando TMailMessage e tMailManager com op��o de m�ltiplos anexos
@author Atilio,Marcos Bispo Abrah�o
@since 08/01/2021
@version 1.0
@type function
    @param cPara, characters, Destinat�rio que ir� receber o e-Mail
    @param cAssunto, characters, Assunto do e-Mail
    @param cCorpo, characters, Corpo do e-Mail (com suporte � html)
    @param aAnexos, array, Anexos que estar�o no e-mail (devem estar na mesma pasta da protheus data)
    @param lMostraLog, logical, Define se ser� mostrado mensagem de log ao usu�rio (uma tela de aviso)
    @param lUsaTLS, logical, Define se ir� utilizar o protocolo criptogr�fico TLS
    @return lRet, Retorna se houve falha ou n�o no disparo do e-Mail
@example Exemplos:
    -----
    1 - Mensagem Simples de envio
    u_zEnvMail("teste@servidor.com.br", "Teste", "Teste TMailMessage - Protheus", , .T.)
 
    -----
    2 - Mensagem com anexos (devem estar dentro da Protheus Data)
    aAnexos := {}
    aAdd(aAnexos, "\pasta\arquivo1.pdf")
    aAdd(aAnexos, "\pasta\arquivo2.pdf")
    aAdd(aAnexos, "\pasta\arquivo3.pdf")
    u_zEnvMail("teste@servidor.com.br", "Teste", "Teste TMailMessage com anexos - Protheus", aAnexos)
 
@obs Deve-se configurar os par�metros:
    * MV_RELACNT - Conta de login do e-Mail    - Ex.: email@servidor.com.br
    * MV_RELPSW  - Senha de login do e-Mail    - Ex.: senha
    * MV_RELSERV - Servidor SMTP do e-Mail     - Ex.: smtp.servidor.com.br:587
    * MV_RELTIME - TimeOut do e-Mail           - Ex.: 120
/*/
                

User Function BkSnMail(cPrw, cAssunto, cPara, cCc, cCorpo, aAnexos, lAviso)
    Local aArea        := GetArea()
    Local nAtual       := 0
    Local lRet         := .T.
    Local oMsg         := Nil
    Local oSrv         := Nil
    Local nRet         := 0
    Local cFrom        := Alltrim(GetMV("MV_RELACNT"))
    Local cUser        := SubStr(cFrom, 1, At('@', cFrom)-1)
    Local cPass        := Alltrim(GetMV("MV_RELPSW"))
    Local cSrvFull     := Alltrim(GetMV("MV_RELSERV"))
    Local cServer      := Iif(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)
    Local nPort        := Iif(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 587)
    Local nTimeOut     := GetMV("MV_RELTIME")
    Local cLog         := ""
    Local cPath        := u_STmpDir()
    //Local cPathH       := U_STmpDir()
    Local cArqLog      := u_SLogDir()+"bksendmail.log"
    Local cArqAviso    := ""

    Local cDrive       := ""
    Local cDir         := ""
    Local cNome        := ""
    Local cExt         := ""
    Local lUsaTLS      := .T.
    Local aUsers       := {}

    Default cPara      := ""
    Default cAssunto   := ""
    Default cCorpo     := ""
    Default aAnexos    := {}
    Default lAviso     := .T.

    IF ValType(aAnexos) <> "A"
        aAnexos    := {}
    ENDIF
 
	u_xxLog(cArqLog,cPrw+"- Assunto: "+ALLTRIM(cAssunto)+" - Para: "+cPara+" - CC: "+cCC)

	// Para testes
	If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer())
		cPara := cCc := u_EmailAdm()
        u_MsgLog(cPrw,"E-mail simulado: "+TRIM(cAssunto))
	EndIf
	// Fim testes

    If lAviso
        aUsers := u_EmailUsr(cPara+";"+cCC)
        If LEN(aAnexos) > 0
            cArqAviso := aAnexos[1]
            /*
            SplitPath( aAnexos[1], @cDrive, @cDir, @cNome, @cExt )
            cArqAviso := cPathH+cNome+cExt

            If ":" $ aAnexos[1]
                CpyT2S( cArqAviso , cPathH, .T. )
            Else
                If aAnexos[1] <> cArqAviso
                    __CopyFile( aAnexos[1], cArqAviso )
                EndIf
            EndIf
            */
        EndIf
        u_BKMsgUs(cEmpAnt,cPrw,aUsers,"",cAssunto,cAssunto,"N",cArqAviso,DataValida(DATE()+1))
    EndIf

    //Se tiver em branco o destinat�rio, o assunto ou o corpo do email
    If Empty(cPara) .Or. Empty(cAssunto) .Or. Empty(cCorpo)
        cLog += "001 - Destinatario, Assunto ou Corpo do e-Mail vazio(s)!" + CRLF
        lRet := .F.
    EndIf
 
    If lRet
        //Cria a nova mensagem
        oMsg := TMailMessage():New()
        oMsg:Clear()
 
        //Define os atributos da mensagem
        oMsg:cFrom    := cFrom
        oMsg:cTo      := cPara
		If !Empty(cCC)
			oMsg:cCC  := cCC
		EndIf
        oMsg:cSubject := cAssunto
        oMsg:cBody    := cCorpo
 
        //Percorre os anexos
        For nAtual := 1 To Len(aAnexos)
            //Se o arquivo n�o existir, procura na pasta tmp
            If !File(aAnexos[nAtual])
                If !(":" $ aAnexos[nAtual]) .AND. !("\" $ aAnexos[nAtual])
                    aAnexos[nAtual] := U_STmpDir()+aAnexos[nAtual]
                EndIf
            EndIf

            //Se o arquivo existir
            If File(aAnexos[nAtual])

                If ":" $ aAnexos[nAtual]
                    CpyT2S( aAnexos[nAtual] , cPath, .T. )
                    SplitPath( aAnexos[nAtual], @cDrive, @cDir, @cNome, @cExt )
                    aAnexos[nAtual] := cPath+cNome+cExt
                EndIf    

                //Anexa o arquivo na mensagem de e-Mail
                nRet := oMsg:AttachFile(aAnexos[nAtual])
                If nRet < 0
                    cLog += "002 - Nao foi possivel anexar o arquivo '"+aAnexos[nAtual]+"'!" + CRLF
                EndIf
 
            //Senao, acrescenta no log
            ElseIf !Empty(aAnexos[nAtual])
                cLog += "003 - Arquivo '"+aAnexos[nAtual]+"' nao encontrado!" + CRLF
            EndIf
        Next
 
        //Cria servidor para disparo do e-Mail
        oSrv := tMailManager():New()
 
        //Define se ir� utilizar o TLS
        If lUsaTLS
            oSrv:SetUseTLS(.T.)
        EndIf
 
        //Inicializa conex�o
        nRet := oSrv:Init("", cServer, cUser, cPass, 0, nPort)
        If nRet != 0
            cLog += "004 - Nao foi possivel inicializar o servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
            lRet := .F.
        EndIf
 
        If lRet
            //Define o time out
            nRet := oSrv:SetSMTPTimeout(nTimeOut)
            If nRet != 0
                cLog += "005 - Nao foi possivel definir o TimeOut '"+cValToChar(nTimeOut)+"'" + CRLF
            EndIf
 
            //Conecta no servidor
            nRet := oSrv:SMTPConnect()
            If nRet <> 0
                cLog += "006 - Nao foi possivel conectar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                lRet := .F.
            EndIf
 
            If lRet
                //Realiza a autentica��o do usu�rio e senha
                nRet := oSrv:SmtpAuth(cFrom, cPass)
                If nRet <> 0
                    cLog += "007 - Nao foi possivel autenticar no servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                    lRet := .F.
                EndIf
 
                If lRet
                    //Envia a mensagem
                    nRet := oMsg:Send(oSrv)
                    If nRet <> 0
                        cLog += "008 - Nao foi possivel enviar a mensagem: " + oSrv:GetErrorString(nRet) + CRLF
                        lRet := .F.
                    EndIf
                EndIf
 
                //Disconecta do servidor
                nRet := oSrv:SMTPDisconnect()
                If nRet <> 0
                    cLog += "009 - Nao foi possivel desconectar do servidor SMTP: " + oSrv:GetErrorString(nRet) + CRLF
                EndIf
            EndIf
        EndIf
    EndIf
 
    //Se tiver log de avisos/erros
    If !Empty(cLog)
    	u_MsgLog(cPrw,"ERROR: "+ALLTRIM(cLog),"E")
    EndIf
 
    RestArea(aArea)
Return lRet




USER FUNCTION SendMail(cPrw,cAssunto,cPara,cCc,cMsg,cAnexo,lAviso)
Local lResulConn := .F.
Local lResulSend := .F.
Local cError     := ""
Local cServer    := AllTrim(GetMV("MV_RELSERV"))
Local cEmail     := AllTrim(GetMV("MV_RELACNT"))
Local cPass      := AllTrim(GetMV("MV_RELPSW"))
Local lRelauth   := GetMv("MV_RELAUTH")
Local cDe        := cEmail
Local nTent      := 0
Local cArqLog    := u_SLogDir()+"sendmail.log"
Local aUsers     := {}
Local lJob       := IsBlind()

Default lAviso     := .T.

Private lResult  := .T.

u_xxLog(cArqLog,cPrw+"- Assunto: "+ALLTRIM(cAssunto)+" - Para: "+cPara+" - CC: "+cCC)

// Para testes
If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer())
	cPara := cCc := u_EmailAdm()
    u_MsgLog(cPrw,"E-mail simulado em ambiente de teste: "+TRIM(cAssunto))
EndIf
// Fim testes

If lAviso
    aUsers := u_EmailUsr(cPara+";"+cCC)
    u_BKMsgUs(cEmpAnt,cPrw,aUsers,"",cAssunto,cAssunto,"N",cAnexo,DataValida(DATE()+1))
EndIf

CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn
If !lResulConn
	GET MAIL ERROR cError

    u_MsgLog(cPrw,"ERRO: Falha na conexao "+TRIM(cAssunto)+": "+cError,"E")
	
	Do While nTent < 10 .AND. lJob 

		Sleep( 900 * 1000 )  // Aguarda 15 minutos e tenta conectar novamente
		
		lResult := .T.

		CONNECT SMTP SERVER cServer ACCOUNT cEmail PASSWORD cPass RESULT lResulConn

		If lResulConn
			Exit
		Else
			GET MAIL ERROR cError
            u_MsgLog(cPrw,"ERRO: Falha na conexao "+TRIM(cAssunto)+": "+cError,"E")
		EndIf
		
	    nTent++
	EndDo
	If !lResulConn
		Return(.F.)
	EndIf
Endif

// Sintaxe: SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend
// Todos os e-mail ter�o: De, Para, Assunto e Mensagem, por�m precisa analisar
// se tem: Com C�pia e/ou Anexo

If lRelauth
	lResult := MailAuth(Alltrim(cEmail), Alltrim(cPass))
	//Se nao conseguiu fazer a Autenticacao usando o E-mail completo, tenta fazer
	//a autenticacao usando apenas o nome de usuario do E-mail
	If !lResult
		nA := At("@",cEmail)
		cUser := If(nA>0,Subs(cEmail,1,nA-1),cEmail)
		lResult := MailAuth(Alltrim(cUser), Alltrim(cPass))
	Endif
Endif


If lResult
	//lResultSend := MailSend(cFrom, aTo, aCc, aBcc, cSubject, cBody, aFiles, lText)
	If !Empty(cPara) .AND. Empty(cCc) .And. Empty(cAnexo)
		SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg RESULT lResulSend
	ElseIf !Empty(cPara) .AND. Empty(cCc) .And. !Empty(cAnexo)
		SEND MAIL FROM cDe TO cPara SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend
	ElseIf Empty(cPara) .AND. !Empty(cCc) .And. Empty(cAnexo)
		SEND MAIL FROM cDe TO cCc SUBJECT cAssunto BODY cMsg RESULT lResulSend
	ElseIf Empty(cPara) .And. !Empty(cCc) .And. !Empty(cAnexo)
		SEND MAIL FROM cDe TO cCc SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend
	ElseIf !Empty(cPara) .AND. !Empty(cCc) .And. Empty(cAnexo)
		SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg RESULT lResulSend
	ElseIf !Empty(cPara) .And. !Empty(cCc) .And. !Empty(cAnexo)
		SEND MAIL FROM cDe TO cPara CC cCc SUBJECT cAssunto BODY cMsg ATTACHMENT cAnexo RESULT lResulSend
	Endif
	
	If !lResulSend
		GET MAIL ERROR cError
        u_MsgLog(cPrw,"ERRO: Falha na conexao "+TRIM(cAssunto)+": "+cError,"E")
	Endif
Else
	lResultSend := .F.
    u_MsgLog(cPrw,"ERRO: Falha na conexao: "+cError,"E")
Endif

DISCONNECT SMTP SERVER

/*
IF lResulSend
	u_MsgLog(cPrw,"E-mail enviado com sucesso: " +TRIM(cAssunto),"S")
ENDIF
*/

RETURN lResulSend
