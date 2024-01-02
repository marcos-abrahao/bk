#Include "Protheus.ch"
#Include "Tbiconn.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKDSCOMB
BK - Atualização da tabela COMBUSTIVEIS do banco de dados PowerBk
     Funcao que conecta no servidor de email para download das mensagens
@Return
@author Marcos Bispo Abrahão
@since 06/03/2023
@version P12.1.33
/*/

User Function BKDSCOMB(aParams)

Local nNumMsg 	 		:= 0
//Local nTam    			:= 0
Local nI     			:= 0
//Local oXml    			:= Nil
Local cXml    			:= ""
//Local nTpXML  			:= 0
//Local aNFe    	 		:= {}
//Local aXml   	  		:= {}
Local cServer	  		:= ""
Local cConta  	  		:= ""
Local cPass    			:= ""
Local cDigSep   		:= ""
Local nErro		  		:= 0
Local sErro				:= ""
Local lLido				:= .F.
Local lNLido			:= .F.
Local lXML				:= .F.
Local nLimAnexo			:= 0
Local nAnexo			:= 0
Local cMsgError			:= ""
Local cAnexo			:= ""
Local aContas			:= {}
Local aServer			:= {}
Local aPass				:= {}
Local nCntAnexo 		:= 0

Private oServer			:= Nil
Private oMessage		:= Nil
Private cLidosFolder	:= "INBOX.Lidos Automaticamente"
Private cErrosFolder	:= "INBOX.XML Nao Processado"
Private cLixeiraFolder	:= "INBOX.lixo"
Private lLidosFolder 	:= .F.
Private lErrosFolder 	:= .F.
Private lJob			:= .F.

Default aParams 		:= {"01","01"}

If Select("SX2") <= 0
	lJob	:= .T.
	cCodEmp := aParams[1]
	cCodFil := aParams[2]
	ConOut("Montando Ambiente: Empresa " + cCodEmp + " Filial: " + cCodFil)
	PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil
Endif

Conout( "Baixando Email...")

nLimAnexo	:= SuperGetMv("MV_XLIMANX"	,.T.,10,"")
cServer 	:= SuperGetMv("MV_XSRVEML"	,.T.,"","")
cConta  	:= SuperGetMv("MV_XCNTEML"	,.T.,"","")
cPass   	:= SuperGetMv("MV_XSENEML"	,.T.,"","")
cDigSep   	:= SuperGetMv("MV_XDIGSEP"	,.T.,";","")

aContas		:= Separa(cConta,cDigSep)
aServer		:= Separa(cServer,cDigSep)
aPass		:= Separa(cPass,cDigSep)
For nI := 1 To Len(aContas)
	cConta  := aContas[nI]
	If nI <= Len(aServer)
		If !Empty(aServer[nI])
			cServer := aServer[nI]
		EndIf
	EndIf
	If nI <= Len(aPass)
		If !Empty(aPass[nI])
			cPass := aPass[nI]
		EndIf
	EndIf
	
	nAteMail:=0
	If !ConectMail(cServer,cConta,cPass,@nNumMsg,lJob)
		Return (Nil)
	EndIf
	ConOut("Existem " + Alltrim(Str(nNumMsg)) + " a serem baixadas.")	
	//Sempre baixara o primeiro email, pois deleta o ultimo lido e assim por diante
	nCntMail := 1
	
	While nNumMsg > 0
	
		//Limpo o objeto da mensagem
		oMessage:Clear()
		//Recebo a mensagem do servidor
		oMessage:Receive( oServer, nCntMail )
		If Empty(oMessage:cFrom)
			If lJob
				Conout("Há email na Caixa de Entrada marcado como deletado, porem falta deleta-lo definitavemente, favor verificar a Caixa de Email e deleta-lo "+Date()+" "+Time())
			Else
				MsgStop("Há email na Caixa de Entrada marcado como deletado, porem falta deleta-lo definitavemente, favor verificar a Caixa de Email e deleta-lo ")
			EndIf
			Return (Nil)
		EndIf
		//Escreve no server os dados do e-mail recebido
		Conout( oMessage:cFrom )
		Conout( oMessage:cTo )
		Conout( oMessage:cSubject )
		Conout( oMessage:cBody )
		Conout( oMessage:cDate )
		lLido 		:= .F.
		lNLido 		:= .F.
		lXML		:= .F.
		nAnexo		:= oMessage:GETATTACHCOUNT(nCntMail)
	
		If nAnexo > nLimAnexo
			lNLido 		:= .T.
			cMsgError	:= "Email possui uma quantidade de anexos maior que o limitado de "+Alltrim(Str(nLimAnexo))
		Else
			cMsgError := ""
			For nCntAnexo := 1 To nAnexo			
				aAnexo := oMessage:GetAttachInfo(nCntAnexo)
				If At(".XML", Upper(aAnexo[2])) > 0
					cAnexo 	:= oMessage:GetAttachInfo(nCntAnexo)[2]
					lXML	:= .T.
					cXML    := ""
					cXML    := AllTrim(oMessage:GETATTACH(nCntAnexo))
					lLido 	:= U_LeXML(cXML,oMessage:cFrom,oMessage:cTo,oMessage:cDate,oMessage:CMESSAGEID,@cMsgError,cAnexo,"")
					If !lLido
						lNLido := .T.
					EndIf
				Elseif At(".XML", Upper(aAnexo[1])) > 0
					cAnexo 	:= oMessage:GetAttachInfo(nCntAnexo)[1]
					lXML	:= .T.
					cXML    := ""
					cXML    := AllTrim(oMessage:GETATTACH(nCntAnexo))
					lLido 	:= U_LeXML(cXML,oMessage:cFrom,oMessage:cTo,oMessage:cDate,oMessage:CMESSAGEID,@cMsgError,cAnexo,"")
					If !lLido
						lNLido := .T.
					EndIf
				EndIf
			Next nCntAnexo
			
			//Se todos os anexos foram lidos
			If !lNLido .AND. lXML
				oMessage:SetConfirmRead(.T.)
				//oServer:DeleteMsg( nCntMail ) //Deleta da pasta de Entrada
				//Se existir a pasta de Lidos Automaticamente
				If lLidosFolder
					If oServer:MoveMsg(nCntMail,cLidosFolder) //Move para a pasta de Lidos Automaticamente
						conout("Mensagem movida para a pasta "+cLidosFolder)
						//If oServer:MoveMsg(nCntMail,cLixeiraFolder) //Move para a pasta de Lixeira
							lPurge := oServer:Purge("INBOX")
						/*Else
							cMsgError := "ERRO ao mover a mensagem para a pasta de Lixeira"
							conout(cMsgError)
							U_ErrosEmail(oMessage:cFrom,oMessage:cSubject,oMessage:cDate,cMsgError)
						EndIf
						*/
					Else
						cMsgError := "ERRO ao mover a mensagem para a pasta de "+cLidosFolder
						conout(cMsgError)
						U_ErrosEmail(oMessage:cFrom,oMessage:cSubject,oMessage:cDate,cMsgError)
					EndIf
				EndIf
			EndIf
		EndIf
		
		//Se existir a pasta de XML Nao Processados e caso algum anexo nao foi lido
		If lErrosFolder .AND. lNLido
			oMessage:SetConfirmRead(.T.)		
			//oServer:DeleteMsg( nCntMail ) //Deleta da pasta de Entrada
			If oServer:MoveMsg(nCntMail,cErrosFolder)	//Move para a pasta de XML Nao Processados
				conout("Mensagem movida para a pasta "+cErrosFolder)			
				//If oServer:MoveMsg(nCntMail,cLixeiraFolder)//Move para a pasta de Lixeira
					lPurge := oServer:Purge("INBOX")
				/*Else
					cMsgError += "ERRO ao mover a mensagem para a pasta de Lixeira"+CRLF
				EndIf
				*/
			Else
				conout("ERRO ao mover a mensagem para a pasta "+cErrosFolder)
				cMsgError += "ERRO ao mover a mensagem para a pasta de "+cErrosFolder+CRLF
			EndIf
			U_ErrosEmail(oMessage:cFrom,oMessage:cSubject,oMessage:cDate,cMsgError)
		EndIf
		
		//Se nao existir xml no email deleta
		If !lXML
			oMessage:SetConfirmRead(.T.)
			oServer:DeleteMsg( nCntMail ) //Deleta da pasta de Entrada
			//If oServer:MoveMsg(nCntMail,cLixeiraFolder)
			lPurge := oServer:Purge("INBOX")
		 	//EndIf
		EndIf
		
		nErro := oServer:IMAPDisconnect()
		
		nNumMsg := 0
		If nErro == 0
			conout("Servidor Desconectado")
			If !ConectMail(cServer,cConta,cPass,@nNumMsg,lJob)
				Return (Nil)
			EndIf
		Else
			sErro := oServer:GetErrorString( nErro )
			If lJob				
			    Conout(sErro)
			Else
				MsgStop(sErro)
			EndIf
		Endif
	EndDo
Next nI
	
If lJob
	ConOut("Processamento da Analise dos Arquivos Importados")
	U_GeraNFe()
EndIf
ConOut("Processamento de NFE de Entrada Encerrado com Sucesso.")

Return (Nil)

Static Function ConectMail(cServer,cConta,cPass,nNumMsg,lJob)

	Local nErro		  		:= 0
	Local sErro				:= ""
	Local aFolder			:= {}
	Local lRet				:= .T.
	
	ConOut("")
	ConOut("Conectando ao Servidor: " + cServer + " atraves da conta: " + cConta)
	ConOut("")
	
	//Apos a conexão, crio o objeto da mensagem
	oMessage := TMailMessage():New()
	
	//Crio uma nova conexão
	oServer := TMailManager():New()
	//oServer:SetUseSSL(.T.)
	nErro	:= oServer:Init(cServer, "", cConta, cPass)
	If nErro != 0
		sErro := oServer:GetErrorString( nErro )
		If lJob				
		    Conout(sErro)
		Else
			MsgStop(sErro)
		EndIf
	    lRet := .F.
	EndIf
	
	//CASO SEJA CONEXAO IMAP NO INI [MAIL] Protocol=IMAP
	
	nErro := oServer:IMAPConnect()
	If nErro != 0
		sErro := oServer:GetErrorString( nErro )
		If lJob				
		    Conout(sErro)
		Else
			MsgStop(sErro)
		EndIf
		lRet := .F.
	EndIf
	
	
	//CASO SEJA CONEXAO POP3 NO INI [MAIL] Protocol=POP3
	/*
	nErro := oServer:SetPopTimeOut( 60 )
	If nErro != 0
		sErro := oServer:GetErrorString( nErro )
		Conout( sErro )
		Return .F.
	EndIf
	
	nErro := oServer:PopConnect()
	If nErro != 0
		sErro := oServer:GetErrorString( nErro )
		Conout( sErro )
		Return .F.
	EndIf
	*/
	//Recebo o número de mensagens do servidor
	oServer:GetNumMsgs( @nNumMsg )
	
	//Verifica se existe a pasta para mover os emails lidos, caso nao haja criara
	aFolder := oServer:GetAllFolderList()
	lLidosFolder	:= aScan(aFolder,{|aX| cLidosFolder == aX[1]}) > 0
	If !lLidosFolder
		lLidosFolder := oServer:CreateFolder(cLidosFolder)
	EndIf
	//Verifica se existe a pasta para mover os emails que possuem erro nos anexo
	lErrosFolder	:= aScan(aFolder,{|aX| cErrosFolder == aX[1]}) > 0
	If !lErrosFolder
		lErrosFolder := oServer:CreateFolder(cErrosFolder)
	EndIf
	
Return (lRet)


//Leitura dos XML no arquivo
User Function LerArqXML(aParams)
Local aFiles 	:= {} // O array receberá os nomes dos arquivos e do diretório
LOCAL nX		:= 0
LOCAL nY		:= 0
LOCAL nCount	:= 0
LOCAL cDIR 		:= "\Arquivei\dowload\" 
LOCAL cDIRMOVER	:= "\Arquivei\Lidodow\" 
LOCAL lLido		:= .F.
LOCAL lNLido	:= .F.
LOCAL lXML		:= .F.
LOCAL cMsgError	:= ""
LOCAL cAnexo	:= ""
LOCAL aAnexo	:= {}
LOCAL cQry		:= ""
LOCAL cSTATUS	:= "L"

PRIVATE lJob		:= .F.

Default aParams 		:= {"01","01"}

If Select("SX2") <= 0
	lJob	:= .T.
	cCodEmp := aParams[1]
	cCodFil := aParams[2]
	ConOut("Montando Ambiente: Empresa " + cCodEmp + " Filial: " + cCodFil)
	PREPARE ENVIRONMENT EMPRESA cCodEmp FILIAL cCodFil
Endif

cQry  := "IF OBJECT_ID('dbo.SEMMAFXML', 'U') IS NULL "
cQry  += "BEGIN "
cQry  += "CREATE TABLE [dbo].[SEMMAFXML]( "
cQry  += "[STATUS] [varchar](1) NOT NULL )"
cQry  += "END "

TCSQLEXEC(cQry)

cQry := "SELECT STATUS FROM [dbo].[SEMMAFXML] "

IF SELECT ("SEMXML") > 0
     SEMXML->(dbCloseArea())
EndIf		


TcQuery cQry New Alias "SEMXML" 

DbSelectArea("SEMXML")

SEMXML->(DbGoTop())
If !empty(SEMXML->STATUS)
	cSTATUS :=  SEMXML->STATUS
ELSE
	cQry  := "INSERT INTO [dbo].[SEMMAFXML] ([STATUS]) VALUES ('L')"
	TCSQLEXEC(cQry)
ENDIF
SEMXML->(dbCloseArea())

IF  cSTATUS == "L" 

	cQry  := " UPDATE [dbo].[SEMMAFXML] SET [STATUS]='B'"
	TCSQLEXEC(cQry)

	Conout( "LerArqXML: Lendo Pastas dos Aquivos XML...")

	//LENDO ARAQUIVOS NAS PASTAS E SUBPASTAS 
	aFiles := u_zRecurDir(cDIR, "*.XML", "")
	nCount := Len( aFiles )
	For nX := 1 to nCount

		lXML		:= .T.
		cXML    	:= ""
		cMsgError 	:= ""
		aAnexo		:= {}
		cAnexo	:= STRTRAN(aFiles[nX][1],cDIR,"")
		aAnexo:= U_StringToArray(cAnexo,"\")
		cAnexo:= aAnexo[len(aAnexo)]
		cXML :=  U_FReadStr(aFiles[nX][1]) //MemoRead(aFiles[nX][1])  
		lLido 	:= U_LeXML(cXML,"Pasta do Arquivei",aFiles[nX][1],DTOC(aFiles[nX][3]),STR(aFiles[nX][2]),@cMsgError,cAnexo,aFiles[nX][1])

		If !lLido
			lNLido := .T.
		EndIf
		cAnexo:= ""
		FOR nY := 1 to LEN(aAnexo)-1
			cAnexo += aAnexo[nY]
			MakeDir(cDIRMOVER+cAnexo)
			cAnexo +="\" 
		Next nY

		cAnexo:= ""
		cAnexo:= STRTRAN(aFiles[nX][1],cDIR,cDIRMOVER)
		__CopyFile( aFiles[nX][1], cAnexo )

		fErase(aFiles[nX][1])

	Next nX


	If lJob
		ConOut("Processamento da Analise dos Arquivos Importados")
		U_GeraNFe()
	EndIf

	//LIBERAR SEMAFARO
	cQry  := " UPDATE [dbo].[SEMMAFXML] SET [STATUS]='L'"
	TCSQLEXEC(cQry)

ELSEIF !lJob
	IF __CUSERID == '000000' 
		If MsgYesNo("Deseja Liberar Arquivos com xml iniciado em outra maquina?")
			cQry  := " UPDATE [dbo].[SEMMAFXML] SET [STATUS]='L'"
			TCSQLEXEC(cQry)
		ENDIF
	ELSE
		MSGSTOP("Processamento dos Arquivos com xml iniciado em outra maquina. Favor aguardar a finalização.")
	ENDIF
ENDIF

ConOut("Processamento de NFE de Entrada Encerrado com Sucesso.")

Return (Nil)
