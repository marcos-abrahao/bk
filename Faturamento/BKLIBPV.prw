#Include "Protheus.ch"
 
/*/{Protheus.doc} BKLIBPV
    Abre Liberação de Pedidos de Venda Web
    @type  Function
    @author user
    @since 12/09/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function BKLIBPV()
   
Local cToken  := u_BKEnCode()
    
    	//        Vanderleia/Zé Mario/Teste/Xavier/Fabia/Bruno/João Cordeiro/Nelson
If __cUserId $ "000000/000038/000012/000056/000175/000023/000153/000170/000165"
	If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer())
		ShellExecute("open", "http://10.139.0.30:8081/rest/RestLibPV/v2?userlib="+cToken, "", "", 1)
	Else
		ShellExecute("open", "http://10.139.0.30:8080/rest/RestLibPV/v2?userlib="+cToken, "", "", 1)
	EndIf
Else
    MsgStop("Acesso não concedido.","BKLIBPV")
EndIf

Return .T.
