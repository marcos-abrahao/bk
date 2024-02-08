#include "rwmake.ch"

/*/{Protheus.doc} MT140FIL
    Ponto de Entrada para filtrar SF1 antes do Browse
    @type  Function
    @author Marcos B. Abrahão
    @since 17/11/09
    @version 12.1.25
/*/

User Function MT140FIL()

//Local cFilt  		:= ""
Local cFiltro1 		:= ""
Local cSuper 		:= ""
//Local cGerGestao 	:= u_GerGestao()
//Local cGerCompras 	:= u_GerCompras()
Local lStaf			:= .F.
Local lMDiretoria	:= .F.

Dbselectarea("SF1")

lStaf  := u_IsStaf(__cUserId)
cSuper := u_cSuper(__cUserId)

lMDiretoria := u_IsMDir(__cUserId)

// Se o usuario pertence ao grupo Administradores: não filtrar
/*
IF !lMDiretoria
   IF !lStaf .OR. EMPTY(cSuper)
      IF EMPTY(cSuper) .AND. __cUserId $ cGerGestao
     	cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSERS = '"+u_GerPetro()+"') "
      ELSE
      	cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSERS = '"+__cUserId+"') "
      ENDIF
   ELSE
		IF lStaf .AND. cSuper $ cGerGestao
			cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+__cUserId + "' OR F1_XXUSERS = '"+cSuper+"' OR F1_XXUSERS = '"+u_GerPetro+"') "
		ELSEIF lStaf .AND. __cUserId $ cGerCompras
			cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+__cUserId + "' OR F1_XXUSERS = '"+cSuper+"' OR F1_XXUSERS IN "+FormatIn(cGerCompras,"/")+" ) "
		ELSE
			cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+__cUserId + "' OR F1_XXUSERS = '"+cSuper+"') "
		ENDIF
	ENDIF
ENDIF   

u_MsgLog("MT140FIL","Super: "+cSuper+" - Staf:"+iif(lStaf,"S","N")+" - Dire:"+IIF(lMDiretoria,"S","N")+" - "+cFilt)
*/


If !lMDiretoria
	cFiltro1 := "(F1_XXUSER = '"+__cUserId+"'  "
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
EndIf

u_MsgLog("MT140FIL1","Super: "+cSuper+" - Staf:"+iif(lStaf,"S","N")+" - Dire:"+IIF(lMDiretoria,"S","N")+" - "+cFiltro1)

Return(cFiltro1)
                                 
