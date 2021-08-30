/*/{Protheus.doc} IsSuperior
    Retorna se o usuario informado é superior de algum outro
    @type  Function
    @author Marcos Bispo Abrahão
    @since 30/08/2021
    @version version
    @param cId (Id do usuário)
    @return lRet
    /*/

User Function IsSuperior(cId)
Local nx,ny
Local aAllusers := FWSFALLUSERS()
Local aSup		:= {}
Local lRet := .F.

For nx := 1 To Len(aAllusers)
    //conout(aAllusers[nx][4] + " -" + aAllusers[nx][5])
	aSup := FWSFUsrSup(aAllusers[nx][2])
	For ny := 1 To Len(aSup)
		If cId == aSup[ny]
			lRet := .T.
			Exit
		EndIf
	Next
	If lRet
		Exit
	Endif
Next

Return (lRet)



( xSeek )


// Retorna se o usuário está no grupo informado
User Function IsGrupo(cId,cIdGrupo)
Local nx
Local aGrp := FWSFUsrGrps(cId)
Local lRet := .F.

For nx := 1 To Len(aGrp)
	If cIdGrupo == aGrp[nx]
		lRet := .T.
		Exit
	EndIf
Next

Return (lRet)


