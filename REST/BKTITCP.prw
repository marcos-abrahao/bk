#Include "Protheus.ch"
 
/*/{Protheus.doc} BKTITCP
BKTITCP - Abrir tela REST - Titulos a Pagar
@Return
@author Marcos Bispo Abrahão
@since 24/08/23
@version P12
/*/

User Function BKTITCP(lShell)
Local dUtil   := dDataBase + 1
Local cToken  := u_BKEnCode()
Local cUrl 	  := ""

Default lShell := .T.

If Select("SX2")==0
	If DOW(dUtil) == 7
		dUtil++
	EndIf
	If DOW(dUtil) == 1
		dUtil++
	EndIf
Else
	dUtil := DATAVALIDA(dDataBase+1)
EndIf

cUrl := u_BkRest()+'/RestTitCP/v2?empresa='+cEmpAnt+'&vencini='+DTOS(dUtil)+'&vencfim='+DTOS(dUtil)+'&userlib='+cToken
If lShell
	ShellExecute("open", cUrl , "", "", 1)
	Return .T.
EndIf
Return cUrl

