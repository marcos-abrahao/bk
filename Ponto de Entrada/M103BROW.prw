#include "rwmake.ch"
#include "protheus.ch"

/*/{Protheus.doc} M103FILB
BK - Ponto de entrada para filtrar UserId e Superior
@Return
@author Marcos Bispo Abrah�o
@since 26/11/09
@version P12
/*/


User Function M103FILB()
Local laClas		:= .F.
Local lFiltLib		:= .F.
Local lRPC 			:= IsBlind()
Local lStaf 		:= .F.
Local lMaster		:= .F.

// Variaveis novo filtro
Local cFiltro1 		:= ""
Local lGrupo   		:= .F.
Local cSubs	 		:= ""
Local cAndOr		:= ""
Local cMaster		:= "000000/000007/000037/000038/000050"+IIF(!lRPC,"/000045","")

If FWIsInCallStack("GERADOCE")
	Return cFiltro1
EndIf

Dbselectarea("SF1")
DBCLEARFILTER() 

lStaf   := u_IsStaf(__cUserId)
lMaster := u_InGrupo(__cUserId,cMaster)

If !lRPC
	//lAClas := MsgBox("Filtrar os Docs a Classificar/Aprovar", "M103FILB", "YESNO")
	lAClas := u_MsgLog("M103FILB","Filtrar os Docs a Classificar?","Y")
	If lAClas
		If lMaster  //FWIsAdmin(__cUserId)
			lFiltLib := u_MsgLog("M103FILB","Filtrar os Doc a liberar?","Y")
		EndIf
	EndIf
Else
	lAClas := .T.
EndIf

// Novo Filtro - Aprova��o em duas etapas

If lMaster // Administradores/Diretoria/Controladoria/Master Libera/Master Libera Barcas/Jur�dico
	If lAClas .OR. lRPC
		If lFiltLib .OR. lRPC
			cFiltro1 := "(F1_STATUS IN (' ','B') AND F1_XXLIB IN ('B','E','L'))"
		Else
			cFiltro1 := "(F1_STATUS IN (' ','B') AND F1_XXLIB <> 'L')"
		EndIf
	EndIf
	lGrupo   := .T.
EndIf


// Master Financeiro ----------------------------------------------------------

If u_IsMasFin(__cUserId)
	If lAClas .OR. lRPC
		cFiltro1 := "(F1_STATUS IN (' ','B'))"
	EndIf
	lGrupo   := .T.
EndIf

// Fiscal: ----------------------------------------------------------

If u_IsFiscal(__cUserId)
	If lAClas
		If lRPC
			// Mostrar as Notas a Liberar tamb�m
			cFiltro1 := "(F1_STATUS IN (' ','B'))"
		Else
			cFiltro1 := "(F1_STATUS IN (' ','B') AND F1_XXLIB IN ('B','E','L'))"
		EndIf
	EndIf
	lGrupo   := .T.
EndIf


/*
--------------------------
Normal:
S� acessam os seus lan�amentos e quando superiores, os lan�amentos dos seus subordinados: 
*/

If !lGrupo
	cFiltro1 := "((F1_XXUSER = '"+__cUserId+"'  "
	cAndOr := " OR "

	// Incluir os subordinados
	If lStaf
		cSubs := U_cStaf(__cUserId)
	Else
		cSubs := U_cSubord(__cUserId)
	EndIf

	If !Empty(cSubs)
	   cFiltro1 += cAndOr+" (F1_XXUSER IN "+cSubs+") "
	EndIf
	cFiltro1 += ")"

	If lAClas
		cFiltro1 += " AND F1_STATUS = ' ' AND F1_XXLIB <> 'L' "
	EndIF
	cFiltro1 += ")"
EndIf

If lRPC .AND. Empty(cFiltro1)
	cFiltro1 := "(F1_STATUS IN (' ','B'))"
EndIf

u_MsgLog("M103FILB1","Staf:"+iif(lStaf,"S","N")+" - Class:"+IIF(lAClas,"S","N")+" - Filtra a liberar:"+IIF(lFiltLib,"S","N")+" - "+cFiltro1)

Return cFiltro1

