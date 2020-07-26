#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT140FIL  บAutor  ณMarcos B Abrahao    บ Data ณ  17/11/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de Entrada para filtrar SF1 antes do Browse          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BK                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบData      ณAnalista/Altera็๕es                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MT140FIL()
Local cFilt  := ""
Local aUser,cSuper := ""
Local cMDiretoria := ""
Local cGerGestao := ALLTRIM(GetMv("MV_XXGGCT"))
Local cGerCompras := ALLTRIM(GetMv("MV_XXGCOM"))

Dbselectarea("SF1")

IF __cUserId <> "000000"  // Administrador: nใo filtrar

	cStaf  := SuperGetMV("MV_XXUSERS",.F.,"000013/000027/000061")
	//                                     Luis          Bruno Santiago
	lStaf  := (__cUserId $ cStaf)

	DBCLEARFILTER() 
	PswOrder(1) 
	PswSeek(__CUSERID) 
	aUser  := PswRet(1)
	IF !EMPTY(aUser[1,11])
	   cSuper := SUBSTR(aUser[1,11],1,6)
	ENDIF   

 	cMDiretoria := SuperGetMV("MV_XXGRPMD",.F.,"000007") //SUBSTR(SuperGetMV("MV_XXGRPMD",.F.,"000007"),1,6)    
    lMDiretoria := .F.
    aGRUPO := {}
//    AADD(aGRUPO,aUser[1,10])
//    IF LEN(aUser[1,10]) > 0
//	    FOR i:=1 TO LEN(aGRUPO[1])
//			lMDiretoria := (aGRUPO[1,i] $ cMDiretoria)
//		NEXT
//	ENDIF
	//Ajuste nova rotina a antiga nใo funciona na nova lib MDI
	aGRUPO := UsrRetGrp(aUser[1][2])
	IF LEN(aGRUPO) > 0
		FOR i:=1 TO LEN(aGRUPO)
			lMDiretoria := (ALLTRIM(aGRUPO[i]) $ cMDiretoria )
		NEXT
	ENDIF	

 	// Se o usuario pertence ao grupo Administradores: nใo filtrar
    IF ASCAN(aUser[1,10],"000000") = 0 .AND. !lMDiretoria
       IF !lStaf .OR. EMPTY(cSuper)
          IF EMPTY(cSuper) .AND. __cUserId $ cGerGestao
	      	cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ' OR F1_XXUSERS = '000175') "
	      ELSE
	      	cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ') "
	      ENDIF
	   ELSE
	      IF lStaf .AND. cSuper $ cGerGestao
	      	cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+__cUserId + "' OR F1_XXUSERS = '"+cSuper+"' OR F1_XXUSER = '      ' OR F1_XXUSERS = '000175') "
	      ELSEIF lStaf .AND. __cUserId $ cGerCompras
	      	cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+__cUserId + "' OR F1_XXUSERS = '"+cSuper+"' OR F1_XXUSER = '      ' OR F1_XXUSERS $ '"+cGerCompras+"')"  
          ELSE
	      	cFilt  := "(F1_XXUSER = '"+__cUserId + "' OR F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+__cUserId + "' OR F1_XXUSERS = '"+cSuper+"' OR F1_XXUSER = '      ') "
          ENDIF
       ENDIF
	ENDIF   
ENDIF
	
Return(cFilt)
                                 
