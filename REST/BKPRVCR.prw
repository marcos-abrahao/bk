#Include "Protheus.ch"
 
/*/{Protheus.doc} BKPRVCR
    Abre Previsão Titulos a Receber Web
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

User Function BKPRVCR(lShell)

Local cToken  := u_BKEnCode()
Local dUtil   := dDatabase - Day(dDatabase) + 1
//Local cUrl    := u_BkRest()+'/RestTitCR/v2?empresa='+cEmpAnt+'&vencini='+DTOS(dUtil-90)+'&vencfim='+DTOS(dUtil+365)+'&userlib='+cToken
Local cUrl     := u_BKIpServer()+'/recursos/loadprvcr.html?empresa='+cEmpAnt+'&vencini='+DTOS(dUtil-60)+'&vencfim='+DTOS(dUtil+365)+'&userlib='+cToken+'&bkip='+u_BKRest()+'/RestPrvCR/v2&username='+u_BKUsrRest()+'&password='+u_BKPswRest()

u_LoadPrvCR()

Default lShell := .T.


If lShell
    ShellExecute("open",cUrl, "", "", 1)
    Return .T.
EndIf

Return cUrl

