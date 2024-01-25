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
	If u_IsLibPv(__cUserId) .AND. cEmpAnt == '01'
    	If u_MsgLog("MDIOk","Deseja abrir a Liberação de Pedidos de Venda web?","Y")
			cToken  := u_BKEnCode()
			ShellExecute("open", u_BkRest()+"/RestLibPV/v2?userlib="+cToken, "", "", 1)
		EndIf
	EndIf
ElseIf nModulo = 6 .OR. nModulo = 2  .OR. nModulo = 9
	If u_IsFiscal(__cUserId) .OR. u_IsStaf(__cUserId) .OR. u_IsSuperior(__cUserId)
		If u_MsgLog("MDIOk","Deseja abrir a Liberação de Docs de Entrada Web?","Y")
			cToken  := u_BKEnCode()
			ShellExecute("open", u_BkRest()+"/RestLibPN/v2?userlib="+cToken, "", "", 1)
		EndIf
	EndIf
EndIf

If nModulo = 6 .AND. (u_InGrupo(__cUserId,"000024") .OR. __cUserId == "000000")
	If u_MsgLog("MDIOk","Deseja abrir a tela Títulos a Pagar Web??","Y")
		cToken  := u_BKEnCode()
		ShellExecute("open", u_BkRest()+'/RestTitCP/v2?empresa='+cEmpAnt+'&vencreal='+DTOS(dDataBase+1)+'&userlib='+cToken, "", "", 1)
		//ShellExecute("open", u_BkRest()+'/RestTitCP/v2?empresa='+cEmpAnt+'&vencreal='+DTOS(DATAVALIDA(dDataBase+1))+'&userlib='+cToken, "", "", 1)
	EndIf
EndIf

Return .T.
