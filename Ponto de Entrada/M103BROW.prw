#include "rwmake.ch"
#include "protheus.ch"

/*/{Protheus.doc} M103FILB
BK - Ponto de entrada para filtrar UserId e Superior
@Return
@author Marcos Bispo Abrahão
@since 26/11/09
@version P12
/*/


User Function M103FILB()

//Local aUser			:= {}
//Local aSup			:= {}
//Local cMDiretoria	:= ""
//Local lMDiretoria   := .F.
//Local cGerGestao	:= u_GerGestao()
//Local cGerCompras	:= u_GerCompras()
//Local aGrupo		:= {}
//Local cSuper		:= ""
//Local cAlmox		:= ""
//Local i:= 0
//Local cFiltro		:= ""


Local laClas		:= .F.
Local lAdmLib		:= .F.
Local lRPC 			:= IsBlind()
Local lStaf 		:= .F.

// Variaveis novo filtro
Local cFiltro1 		:= ""
Local lGrupo   		:= .F.
Local cSubs	 		:= ""
Local cAndOr		:= ""

Dbselectarea("SF1")
DBCLEARFILTER() 

lStaf  := u_IsStaf(__cUserId)
	
If !lRPC
	//lAClas := MsgBox("Filtrar os Docs a Classificar/Aprovar", "M103FILB", "YESNO")
	lAClas := u_MsgLog("M103FILB","Filtrar os Docs a Classificar?","Y")
	If lAClas
		If FWIsAdmin(__cUserId)
			lAdmLib := u_MsgLog("M103FILB","Filtrar os Doc a liberar?","Y")
		EndIf
	EndIf
Else
	lAClas := .T.
EndIf


/*
	aSup := FWSFUsrSup(__cUserId)
	If Len(aSup) > 0
		cSuper := aSup[1]
	EndIf

	lMDiretoria := u_IsMDir(__cUserId)

	If __cUserId $ cGerCompras
		cAlmox := u_UsrAlmox() 
	EndIf
	
	cFiltro := ""
	// Se o usuario pertence ao grupo Administradores, User Fiscal ou Master Diretoria : não filtrar                     
    If !FWIsAdmin(__cUserId) .AND. !u_IsFiscal(__cUserId) .AND. !lMDiretoria .AND. !(__cUserId $ cGerGestao)
       If !lStaf .OR. EMPTY(cSuper)
          If lAClas
          	 If EMPTY(cSuper)  .AND. __cUserId $ cGerGestao 
             	// Filtro 1
             	cFiltro := "(F1_XXUSER <> '"+__cUserId+"' AND (F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSERS = '"+u_GerPetro()+"') AND F1_STATUS = ' ' AND F1_XXLIB <> 'L') " 
             Else
             	// Filtro 2 
				 If !lRPC
             		cFiltro := "(F1_XXUSER <> '"+__cUserId+"' AND (F1_XXUSERS = '"+__cUserId+"') AND F1_STATUS = ' ' AND F1_XXLIB <> 'L')"
				 Else
					cFiltro := "((F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"') AND F1_STATUS = ' ' AND F1_XXLIB <> 'L')"
				 EndIf
             EndIf
          Else   
          	 If EMPTY(cSuper) .AND. __cUserId $ cGerGestao
             	// Filtro 3
             	cFiltro := "(F1_XXUSER = '"+__cUserId+"' AND F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSERS = '"+u_GerPetro()+"')"
             Else
             	If __cUserId $ cGerCompras
             		// Filtro 4
             		cFiltro := "(F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"'"+IIF(!empty(cAlmox)," OR F1_XXUSER IN ("+cAlmox+")","")+")"
             	Else
             		// Filtro 5
             		cFiltro := "(F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"')"
             	EndIf
             EndIf  
          EndIf
       Else
		  // Staf

          If lAClas

       		// Filtro 6
            cFiltro := "("+IIF(lStaf .AND. __cUserId $ cGerCompras,""," F1_XXUSER <> '"+__cUserId+"' AND")+" (F1_XXUSERS = '"+__cUserId+"'"+IIF(lStaf .AND. cSuper $ cGerGestao," OR F1_XXUSERS = '"+u_GerPetro()+"'","")+" OR "
          	cFiltro += " F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+cSuper+"'"+IIF(lStaf .AND. __cUserId $ cGerCompras," OR F1_XXUSERS IN "+FormatIn(cGerCompras,"/"),"")+") AND F1_STATUS = ' ' AND F1_XXLIB <> 'L')"
			//u_xxLog("\LOG\M103BROW.LOG","f6 "+__cUserId+":"+cFiltro)
          Else
              				 
       		// Filtro 7
            cFiltro := "(F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"'"+IIF(lStaf .AND. cSuper $ cGerGestao," OR F1_XXUSERS = '"+u_GerPetro()+"'","")+" OR "
          	cFiltro += " F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+cSuper+"'"+IIF(lStaf .AND. __cUserId $ cGerCompras," OR F1_XXUSERS IN "+FormatIn(cGerCompras,"/"),"")+")"          	 
			//u_xxLog("\LOG\M103BROW.LOG","f7 "+__cUserId+":"+cFiltro)
          	 
          EndIf
       EndIf
    ElseIf lAClas
       //SET FILTER TO (SF1->F1_STATUS = ' ')
       // Filtro 8
	   If FWIsAdmin(__cUserId)
	   		If !lRPC
				lAdmLib := u_MsgLog("M103FILB","Filtrar os Doc a liberar?","Y")
			Else
				lAdmLib := .F.
			EndIf
	   EndIf

	   If u_IsFiscal(__cUserId) .OR. lAdmLib
			If !lRPC
      	   		cFiltro := "(F1_STATUS IN (' ','B') AND F1_XXLIB IN ('B','E','L'))"
			Else // Mostrar as Notas a Liberar também
	       		cFiltro := "(F1_STATUS IN (' ','B'))"
			EndIf
	   ElseIf lMDiretoria
       	   cFiltro := "(F1_STATUS IN (' ','B'))"
	   Else
       	   cFiltro := "(F1_STATUS IN (' ','B') AND F1_XXLIB <> 'L')"
       EndIf
    EndIf
    //If !Empty(cFiltro)
    //    cFiltro := " F1_FILIAL='"+xFilial("SF1")+"' AND "+cFiltro
    //EndIf
EndIf
If lRPC .AND. Empty(cFiltro)
	cFiltro := "(F1_STATUS IN (' ','B'))"
EndIf

u_MsgLog("M103FILB","Super: "+cSuper+" - Staf:"+iif(lStaf,"S","N")+" - Dire:"+IIF(lMDiretoria,"S","N")+" - Class:"+IIF(lAClas,"S","N")+" - Filtra a liberar:"+IIF(lAdmLib,"S","N")+" - "+cFiltro)

*/


// Novo Filtro - Aprovação em duas etapas

If u_InGrupo(__cUserId,"000000/000007/000038") // Administradores/Diretoria/Master Libera
	If lAClas .OR. lRPC
		If lAdmLib
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
			// Mostrar as Notas a Liberar também
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
Só acessam os seus lançamentos e quando superiores, os lançamentos dos seus subordinados: 
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

u_MsgLog("M103FILB1","Staf:"+iif(lStaf,"S","N")+" - Class:"+IIF(lAClas,"S","N")+" - Filtra a liberar:"+IIF(lAdmLib,"S","N")+" - "+cFiltro1)

Return cFiltro1

