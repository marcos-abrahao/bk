#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKDocs
BK - Lista de arquivos anexos da base de conhecimento
@Return aFiles (array com arquivos anexos)
@author  Marcos Bispo Abrahão
@since 12/12/22
@version P12
/*/

User Function BKDocs(cEmp,cEntidade,cChave,nOpc,aFiles,lParte)
Local oStatement := nil
Local cQuery     := ""
Local cAliasSQL  := ""
Local nSQLParam  := 0
Local cTabAC9	 := "AC9"+cEmp+"0" 
Local cTabACB	 := "ACB"+cEmp+"0"
Local cLen 		 := 0

Local cFile      := ""
Local cDir       := "/dirdoc/co"+cEmp+"/shared/"

Default nOpc     := 1
Default aFiles	 := {}
Default lParte   := .F.


cQuery := "SELECT DISTINCT ACB.ACB_OBJETO " + CRLF
cQuery += " FROM " + cTabAC9 + " AC9 " + CRLF // Entidade x objeto.
cQuery += "LEFT JOIN " + cTabACB + " ACB ON ACB.D_E_L_E_T_ = ' ' " + CRLF // Objeto.
cQuery += " AND ACB.ACB_FILIAL = AC9.AC9_FILIAL " + CRLF
cQuery += " AND ACB.ACB_CODOBJ = AC9.AC9_CODOBJ " + CRLF
cQuery += "WHERE AC9.D_E_L_E_T_ = '' " + CRLF
cQuery += " AND AC9.AC9_FILIAL = ? " + CRLF
cQuery += " AND AC9.AC9_ENTIDA = ? " + CRLF
If !lParte
	cQuery += " AND AC9.AC9_CODENT = ? " + CRLF
Else
	cLen := STR(LEN(cChave),0)
	cQuery += " AND SUBSTRING(AC9.AC9_CODENT,1,"+cLen+") = ? " + CRLF
EndIf

//cQuery += "ORDER BY AC9.AC9_FILIAL, AC9.AC9_ENTIDA, AC9.AC9_CODENT, AC9.AC9_CODOBJ "

// Trata SQL para proteger de SQL injection.
oStatement := FWPreparedStatement():New()
oStatement:SetQuery(cQuery)

nSQLParam++
oStatement:SetString(nSQLParam, xFilial("AC9"))  // Filial

nSQLParam++
oStatement:SetString(nSQLParam, cEntidade)  // Entidade.

nSQLParam++
oStatement:SetString(nSQLParam, cChave) // Chave.

cQuery := oStatement:GetFixQuery()
oStatement:Destroy()
oStatement := nil

cAliasSQL := MPSysOpenQuery(cQuery)

Do While (cAliasSQL)->(!eof())
	//cFile  := cDir+AllTrim((cAliasSQL)->ACB_OBJETO)
	cFile  := AllTrim((cAliasSQL)->ACB_OBJETO)
    If nOpc == 1  // Diretorio , arquivo
		If Ascan(aFiles,{ |x| x[1] == cDir .and. x[2] == cFile }) == 0
		    aAdd(aFiles,{cDir,cFile})
		EndIf
    Else  // Diretorio + arquivo
		If Ascan(aFiles,cDir+cFile) == 0
		    aAdd(aFiles,cDir+cFile)
		EndIf
    EndIf
	(cAliasSQL)->(dbSkip())
EndDo
(cAliasSQL)->(dbCloseArea())

Return (aFiles)
