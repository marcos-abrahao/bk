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
    
If u_IsLibPv(__cUserId)
	ShellExecute("open", u_BkRest()+"/RestLibPV/v2?userlib="+cToken, "", "", 1)
Else
    u_MsgLog("BKLIBPV","Acesso não concedido.","E")
EndIf

Return .T.
