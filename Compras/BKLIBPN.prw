#Include "Protheus.ch"
 
/*/{Protheus.doc} BKLIBPN
    Abre Liberação de Documentos de Entrada Web
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

User Function BKLIBPN()
   
Local cToken  := u_BKEnCode()
    
    
If u_IsSuperior(__cUserId) .OR. u_IsGrupo(__cUserId,"000031") .OR. u_IsStaf(__cUserId) .OR. (__cUserId == "000000")
	If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer())
		ShellExecute("open", "http://10.139.0.30:8081/rest/RestLibPN/v2?userlib="+cToken, "", "", 1)
	Else
		ShellExecute("open", "http://10.139.0.30:8080/rest/RestLibPN/v2?userlib="+cToken, "", "", 1)
	EndIf
Else
    MsgStop("Acesso não concedido.","BKLIBPN")
EndIf

Return .T.
