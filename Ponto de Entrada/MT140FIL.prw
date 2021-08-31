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
Local cGerGestao 	:= ALLTRIM(GetMv("MV_XXGGCT"))
Local cGerCompras 	:= ALLTRIM(GetMv("MV_XXGCOM"))
Local i				:= 0
Local aGrupo 		:= {}
Local lStaf			:= .F.
Local lMDiretoria	:= .F.

Dbselectarea("SF1")

IF __cUserId <> "000000"  // Administrador: não filtrar

	//cStaf  := SuperGetMV("MV_XXUSERS",.F.,"000013/000027/000061")

	lStaf  := IsStaf(__cUserId)

	DBCLEARFILTER() 
	PswOrder(1) 
	PswSeek(__cUserId) 
	aUser  := PswRet(1)
	IF !EMPTY(aUser[1,11])
	   cSuper := SUBSTR(aUser[1,11],1,6)
	ENDIF   

 	cMDiretoria := SuperGetMV("MV_XXGRPMD",.F.,"000007") //SUBSTR(SuperGetMV("MV_XXGRPMD",.F.,"000007"),1,6)    
    lMDiretoria := .F.
    aGrupo := {}
//    AADD(aGrupo,aUser[1,10])
//    IF LEN(aUser[1,10]) > 0
//	    FOR i:=1 TO LEN(aGrupo[1])
//			lMDiretoria := (aGrupo[1,i] $ cMDiretoria)
//		NEXT
//	ENDIF
	//Ajuste nova rotina a antiga não funciona na nova lib MDI
	aGrupo := UsrRetGrp(aUser[1][2])
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
	      	cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+__cUserId + "' OR F1_XXUSERS = '"+cSuper+"')" // OR F1_XXUSERS $ '"+cGerCompras+"')"  
          ELSE
	      	cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+__cUserId + "' OR F1_XXUSERS = '"+cSuper+"') "
          ENDIF
       ENDIF
	ENDIF   
ENDIF
	
Return(cFilt)
                                 
