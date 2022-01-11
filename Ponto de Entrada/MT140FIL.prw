#include "rwmake.ch"

/*/{Protheus.doc} MT140FIL
    Ponto de Entrada para filtrar SF1 antes do Browse
    @type  Function
    @author Marcos B. Abrahão
    @since 17/11/09
    @version 12.1.25
/*/

User Function MT140FIL()

Local cFilt  		:= ""
Local aUser			:= {}
Local cSuper 		:= ""
Local cMDiretoria 	:= ""
Local cGerGestao 	:= u_GerGestao()
Local cGerCompras 	:= u_GerCompras()
Local i				:= 0
Local aGrupo 		:= {}
Local lStaf			:= .F.
Local lMDiretoria	:= .F.

Dbselectarea("SF1")

IF __cUserId <> "000000"  // Administrador: não filtrar

	//cStaf  := SuperGetMV("MV_XXUSERS",.F.,"000013/000027/000061")

	lStaf  := u_IsStaf(__cUserId)

	DBCLEARFILTER() 
	PswOrder(1) 
	PswSeek(__cUserId) 
	aUser  := PswRet(1)
	IF !EMPTY(aUser[1,11])
	   cSuper := SUBSTR(aUser[1,11],1,6)
	ENDIF   

 	cMDiretoria := u_GrpMDir()
    lMDiretoria := .F.
    aGrupo := {}
	aGrupo := UsrRetGrp(cUserName)
	IF LEN(aGrupo) > 0
		FOR i:=1 TO LEN(aGrupo)
			lMDiretoria := (ALLTRIM(aGrupo[i]) $ cMDiretoria )
		NEXT
	ENDIF	

 	// Se o usuario pertence ao grupo Administradores: não filtrar
    IF ASCAN(aUser[1,10],"000000") = 0 .AND. !lMDiretoria
       IF !lStaf .OR. EMPTY(cSuper)
          IF EMPTY(cSuper) .AND. __cUserId $ cGerGestao
	      	cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSERS = '000175') "
	      ELSE
	      	cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSERS = '"+__cUserId+"') "
	      ENDIF
	   ELSE
	      IF lStaf .AND. cSuper $ cGerGestao
	      	cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+__cUserId + "' OR F1_XXUSERS = '"+cSuper+"' OR F1_XXUSERS = '000175') "
	      ELSEIF lStaf .AND. __cUserId $ cGerCompras
	      	cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+__cUserId + "' OR F1_XXUSERS = '"+cSuper+"') OR F1_XXUSERS IN "+FormatIn(cGerCompras)+")"
          ELSE
	      	cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+__cUserId + "' OR F1_XXUSERS = '"+cSuper+"') "
          ENDIF
       ENDIF
	ENDIF   
ENDIF
	
Return(cFilt)
                                 
