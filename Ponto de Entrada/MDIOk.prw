//Bibliotecas
#Include "Protheus.ch"
 
/*------------------------------------------------------------------------------------------------------*
 | P.E.:  MDIOk                                                                                         |
 | Desc:  P.E. ao abrir o módulo SIGAMDI                                                                |
 *------------------------------------------------------------------------------------------------------*/
 
User Function MDIOk()
    
Local cToken  := u_BKEnCode()

If nModulo = 5 .OR. nModulo = 69
	//        Vanderleia/Zé Mario/Teste/Xavier/Fabia/Bruno/João Cordeiro
	If __cUserId $ "000000/000038/000012/000056/000175/000023/000153/000170"
    	If MsgYesNo("Deseja abrir a liberação de pedidos web?")
			If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer())
				ShellExecute("open", "http://10.139.0.30:8081/rest/RestLibPV/v2?userlib="+cToken, "", "", 1)
			Else
				ShellExecute("open", "http://10.139.0.30:8080/rest/RestLibPV/v2?userlib="+cToken, "", "", 1)
			EndIf
		EndIf
	EndIf
ElseIf nModulo = 6 .OR. nModulo = 2  .OR. nModulo = 9
	If u_IsSuperior(__cUserId) .OR. u_IsGrupo(__cUserId,"000031") .OR. u_IsStaf(__cUserId) .OR. (__cUserId == "000000")
		If MsgYesNo("Deseja abrir a liberação de Docs de Entrada web?")
			If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer())
				ShellExecute("open", "http://10.139.0.30:8081/rest/RestLibPN/v2?userlib="+cToken, "", "", 1)
			Else
				ShellExecute("open", "http://10.139.0.30:8080/rest/RestLibPN/v2?userlib="+cToken, "", "", 1)
			EndIf
		EndIf
	EndIf
EndIf

Return .T.
