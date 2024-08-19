#Include "Protheus.ch"
 
/*/{Protheus.doc} BKLIBCR
    Abre Titulos a Receber Web
    @type  Function
    @author user Marcos Abrahão
    @since 18/06/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function BKTITCR(lShell)
   
Local cToken  := u_BKEnCode()
Local dUtil   := dDatabase
Local cUrl    := u_BkRest()+'/RestTitCR/v2?empresa='+cEmpAnt+'&vencini='+DTOS(dUtil-3650)+'&vencfim='+DTOS(dUtil+365)+'&userlib='+cToken

Default lShell := .T.

If lShell
    ShellExecute("open",cUrl, "", "", 1)
    Return .T.
EndIf

Return cUrl
