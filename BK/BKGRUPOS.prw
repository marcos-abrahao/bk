#include "totvs.ch"
#include "protheus.ch"

// Funcoes com códigos embutidos no fonte

/*/{Protheus.doc} BKGRUPO
BK - Array com as empresas do grupo BK

@Return
@author Marcos B. Abrahão
@since 24/08/21
@version P12
/*/

User Function BKGrupo()

Local aEmpresas	:= {    {"01","BK"},;
                        {"02","BKTER"},;
                        {"14","BALSA NOVA"},;
                        {"15","BHG INT 3"} }
Return aEmpresas


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



// Retorna se o usuário pertence ao grupo informado
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


// Retorna se o usuário pertence ao STAF 
// MV_XXUSER - Parametro especifico BK - Usuarios que visualizam doc de entrada de seus superiores e do depto todo
User Function IsStaf(cId)
Local lRet := .F.
If cId $ "000011/000016/000076/000093/000194/000056/000165/000116/"
    lRet := .T.
EndIf
Return (lRet)


// Retorna se o usuário deve avaliar Fornecedores (Compras e Almox)

User Function IsAvalia(cId)
Local lRet := .F.
// Admin/Fabio/Anderson/Luis/Michele/Caio
If cId $ "000000/000093/000005/000116/000138/000126/"
    lRet := .T.
EndIf
Return (lRet)



// Grupo Almoxarifado
User Function GrpAlmox
Return "000021"


// Usuarios Almoxarifado (para queries)
User Function UsrAlmox
Return "'000093','000126','000139','000159','000216','000225','000226','000227'"


// Usuarios Master Almoxarifado (grupo 27)
User Function UsrMAlmox()
Return "000093/000216/000126/000232/000227"  

// Email para Grupo do (Fabio,Caio,Barbara,Jose Amauri)
User Function EmEstAlm(cId,lAll)
Local aUsers := {"000093","000126","000232","000216",'000227'}
Local cEmail := ""
Local cEmails:= ""
Local nI	 := 0

If Ascan(aUsers,cId) > 0 .OR. lAll
	For nI := 1 To Len(aUsers)
		If aUsers[nI] <> cId
			cEmail  := ALLTRIM(UsrRetMail(aUsers[nI]))
			If !Empty(cEmail)
				cEmails += cEmail+';'
			EndIf
		EndIf
	Next
EndIf

Return (cEmails)


// Financeiro
// Usuários que podem integrar PJ do Rubi pelo Financeiro BKFINA02
User Function FinUsrPj()
Return "000011/000012/000000/000016"  // Diego 16 incluido nas ferias do Lau

