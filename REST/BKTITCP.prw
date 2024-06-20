#Include "Protheus.ch"
 
/*/{Protheus.doc} BKTITCP
BKTITCP - Abrir tela REST - Titulos a Pagar
@Return
@author Marcos Bispo Abrahão
@since 24/08/23
@version P12
/*/

User Function BKTITCP(dUtil)
    
Local cToken  := u_BKEnCode()

If ValType(dUtil) <> 'D'
	dUtil := DATAVALIDA(dDataBase+1)
EndIf

ShellExecute("open", u_BkRest()+'/RestTitCP/v2?empresa='+cEmpAnt+'&vencini='+DTOS(dUtil)+'&vencfim='+DTOS(dUtil)+'&userlib='+cToken, "", "", 1)

Return .T.
