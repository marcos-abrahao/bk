#Include "Protheus.ch"
 
/*/{Protheus.doc} MDIOk
MDIOk - P.E. ao abrir o módulo SIGAMDI
@Return
@author Marcos Bispo Abrahão
@since 19/08/21
@version P12.1.33
/*/

User Function MDIOk()
    
Local dUtil := dDatabase
//Local dUltLog := FWUsrUltLog(__cUserId)[1] // Data do Ultimo login  

If nModulo == 5 .OR. nModulo == 69
   	If u_MsgLog("MDIOk","Deseja abrir a Liberação de Pedidos de Venda web?","Y")
		u_BKLibPV()
	EndIf

	If nModulo == 5
    	If u_MsgLog("MDIOk","Deseja abrir os Títulos a Receber web?","Y")
			u_BKTitCR()
		EndIf
	EndIf

ElseIf nModulo == 6 .OR. nModulo == 2  .OR. nModulo == 9
	If u_IsFiscal(__cUserId) .OR. u_IsStaf(__cUserId) .OR. u_IsSuperior(__cUserId)
		If u_MsgLog("MDIOk","Deseja abrir a Liberação de Docs de Entrada Web?","Y")
			u_BKLibPN()
		EndIf
	EndIf
EndIf

If nModulo == 6 .AND. (u_InGrupo(__cUserId,"000024") .OR. __cUserId == "000000")
	If u_MsgLog("MDIOk","Deseja abrir a tela Títulos a Pagar Web?","Y")
		dUtil := dDataBase + 1
		If DOW(dUtil) == 7
			dUtil++
		EndIf
		If DOW(dUtil) == 1
			dUtil++
		EndIf
		u_BKTitCP(dUtil)
	EndIf
EndIf

Return .T.
