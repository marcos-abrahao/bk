#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} RunQuery
Generico - Rodar query genérica 
@Return
@author Marcos Bispo Abrahão
@since 03/11/23
@version P12
*/

User Function RunQuery(cProg,cQuery,cAlias,aTcFields)
u_WaitLog(cProg,{ || ProcQuery(cProg,cQuery,cAlias,aTcFields)},"Consultando banco de dados...")
Return


Static Function ProcQuery(cProg,cQuery,cAlias,aTcFields)
Local nCpo

Default cAlias		:= "TMP"
Default aTcFields	:= {}

// Fecha o Alias, se já estiver aberto
If Select(cAlias) > 0 
	dbSelectArea(cAlias)
   	dbCloseArea()
EndIf

u_LogMemo(cProg+".sql",cQuery)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)


For nCpo := 1 To Len(aTcFields)
	If aTcFields[nCpo][2] <> "C"
		TCSetField(cAlias,aTcFields[nCpo][1],aTcFields[nCpo][2],aTcFields[nCpo][3], aTcFields[nCpo][4])
	EndIf
Next

dbSelectArea(cAlias)
dbGoTop()

Return
