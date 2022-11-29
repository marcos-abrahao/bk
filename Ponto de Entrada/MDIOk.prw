#Include "Protheus.ch"
 
/*/{Protheus.doc} MDIOk
MDIOk - P.E. ao abrir o módulo SIGAMDI
@Return
@author Marcos Bispo Abrahão
@since 19/08/21
@version P12.1.33
/*/

User Function MDIOk()
    
Local cToken
//Local dUltLog := FWUsrUltLog(__cUserId)[1] // Data do Ultimo login  

If nModulo = 5 .OR. nModulo = 69
	//              Admin /Teste /Xavier/Fabia/Vanderle/Bruno/Nelson/João Cordeiro/
	If __cUserId $ "000000/000038/000012/000023/000056/000153/000165/000170"
    	If MsgYesNo("Deseja abrir a liberação de pedidos web?")
			cToken  := u_BKEnCode()
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
			cToken  := u_BKEnCode()
			If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer())
				ShellExecute("open", "http://10.139.0.30:8081/rest/RestLibPN/v2?userlib="+cToken, "", "", 1)
			Else
				ShellExecute("open", "http://10.139.0.30:8080/rest/RestLibPN/v2?userlib="+cToken, "", "", 1)
			EndIf
		EndIf
	EndIf
EndIf

Return .T.
