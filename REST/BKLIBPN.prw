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
    
ShellExecute("open", u_BkRest()+"/RestLibPN/v2?userlib="+cToken, "", "", 1)

Return .T.
