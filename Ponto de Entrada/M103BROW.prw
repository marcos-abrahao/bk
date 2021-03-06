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

Local aUser,cStaf,lStaf
Local cFiltro		:= ""
Local cMDiretoria	:= ""
Local laClas		:= .F.
Local lAdmFiscal	:= .F.
Local cGerGestao	:= ALLTRIM(GetMv("MV_XXGGCT"))
Local cGerCompras	:= ALLTRIM(SuperGetMV("MV_XXGCOM",.F.,"000015")) 
Local aGrupo		:= {}
Local cSuper		:= "" 
//Local lAlmox		:= .F.
Local cAlmox		:= ""
Local i:= 0

Private cGrupAlmox	:= SuperGetMV("MV_XXGRALX",.F.,"000021")
 
cGerCompras := "'"+cGerCompras+"'"

/*
Retirado em 27/09/11 - Marcos

aUsers:=AllUsers()
For nX_ := 1 to Len(aUsers)
	If Len(aUsers[nX_][1][10]) > 0 
		aGrupo := {}
		//AADD(aGRUPO,aUsers[nX_][1][10])
		//FOR i:=1 TO LEN(aGRUPO[1])
		//	lAlmox := (aGRUPO[1,i] $ cGrupAlmox)
		//NEXT
		//Ajuste nova rotina a antiga n�o funciona na nova lib MDI
		aGRUPO := UsrRetGrp(aUsers[nX_][1][2])
		IF LEN(aGRUPO) > 0
			FOR i:=1 TO LEN(aGRUPO)
				lAlmox := (ALLTRIM(aGRUPO[i]) $ cGrupAlmox )
			NEXT
		ENDIF			
    	If lAlmox
    		If !EMPTY(cAlmox)
    			cAlmox += ","
    		EndIf
    		cAlmox += "'"+ALLTRIM(aUsers[nX_][1][1])+"'"
    	ENDIF
 	ENDIF
NEXT
*/


Dbselectarea("SF1")
IF __cUserId <> "000000" // .AND. __cUserId <> "000029" // Administrador e Marcio Kogan
	cStaf  := SuperGetMV("MV_XXUSERS",.F.,"000013/000027/000061")
	//                                     Luis          Bruno Santiago
	lStaf  := (__cUserId $ cStaf)
	lAClas := MsgBox("Filtrar os Doc a Classificar", "M103FILB", "YESNO")

	DBCLEARFILTER() 
	PswOrder(1) 
	PswSeek(__CUSERID) 
	aUser  := PswRet(1)
	IF !EMPTY(aUser[1,11])
	   cSuper := SUBSTR(aUser[1,11],1,6)
	ENDIF   
 	cMDiretoria := SuperGetMV("MV_XXGRPMD",.F.,"000007") //SUBSTR(SuperGetMV("MV_XXGRPMD",.F.,"000007"),1,6) 
    lMDiretoria := .F.
    aGrupo := {}
	aGrupo := UsrRetGrp(aUser[1][2])
	IF LEN(aGrupo) > 0
		FOR i:=1 TO LEN(aGrupo)
		
			If !lMDiretoria
				lMDiretoria := (ALLTRIM(aGrupo[i]) $ cMDiretoria)
			EndIf

			// 27/11/19 - Marcos	
			//If !lAlmox
			//	lAlmox := (ALLTRIM(aGrupo[i]) $ cGrupAlmox)
			//EndIf

		NEXT
	ENDIF	

	If __cUserId $ cGerCompras
		cAlmox := GrpAlmox() 
	EndIf

	// Log dos Filtros
	/*
   	cFiltro := "(F1_XXUSER <> '"+__cUserId+"' AND (F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ' OR F1_XXUSERS = '000075' OR F1_XXUSERS = '000120') AND F1_STATUS = ' ')" 
	u_xxLog("\TMP\MT103FILB.LOG","1-"+cFiltro,.T.,"TST")
		
   	cFiltro := "(F1_XXUSER <> '"+__cUserId+"' AND (F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ' ) AND F1_STATUS = ' ')"
	u_xxLog("\TMP\MT103FILB.LOG","2-"+cFiltro,.T.,"TST")

   	cFiltro := "(F1_XXUSER = '"+__cUserId+"' AND F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ' OR F1_XXUSERS = '000075' OR F1_XXUSERS = '000120')"
	u_xxLog("\TMP\MT103FILB.LOG","3-"+cFiltro,.T.,"TST")
	
	cFiltro := "(F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      '"+IIF(!empty(cAlmox)," OR F1_XXUSER IN ("+cAlmox+")","")+")"
	u_xxLog("\TMP\MT103FILB.LOG","4-"+cFiltro,.T.,"TST")


	cFiltro := "(F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ')"
	u_xxLog("\TMP\MT103FILB.LOG","5-"+cFiltro,.T.,"TST")
	
	
    cFiltro := "(F1_XXUSER <> '"+__cUserId+"' AND (F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      '"+IIF(lStaf .AND. cSuper $ cGerGestao," OR F1_XXUSERS = '000075' OR F1_XXUSERS = '000120'","")+" OR "
  	cFiltro += " F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+cSuper+"'"+IIF(lStaf .AND. __cUserId $ cGerCompras," OR F1_XXUSERS IN ("+cGerCompras+")","")+") AND F1_STATUS = ' ')"
	u_xxLog("\TMP\MT103FILB.LOG","6-"+cFiltro,.T.,"TST")


    cFiltro := "(F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      '"+IIF(lStaf .AND. cSuper $ cGerGestao," OR F1_XXUSERS = '000075' OR F1_XXUSERS = '000120'","")+" OR "
    cFiltro += " F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+cSuper+"'"+IIF(lStaf .AND. __cUserId $ cGerCompras," OR F1_XXUSERS IN ("+cGerCompras+")","")+")"          	 
	u_xxLog("\TMP\MT103FILB.LOG","7-"+cFiltro,.T.,"TST")

    cFiltro := "(F1_STATUS = ' ')"
	u_xxLog("\TMP\MT103FILB.LOG","8-"+cFiltro,.T.,"TST")
	*/
	
	
	cFiltro := ""
	// Se o usuario pertence ao grupo Administradores, User Fiscal ou Master Diretoria : n�o filtrar
    IF ASCAN(aUser[1,10],"000000") = 0 .AND. ASCAN(aUser[1,10],"000031") = 0 .AND. !lMDiretoria 
       IF !lStaf .OR. EMPTY(cSuper)
          IF lAClas
          	 IF EMPTY(cSuper)  .AND. __cUserId $ cGerGestao 
             	//SET FILTER TO (SF1->F1_XXUSER <> __cUserId .AND. ( SF1->F1_XXUSERS = __cUserId .OR. SF1->F1_XXUSER = '      ' .OR. F1_XXUSERS = '000075' .OR. F1_XXUSERS = '000120') .AND.  SF1->F1_STATUS = ' ')
             	// Filtro 1
             	cFiltro := "(F1_XXUSER <> '"+__cUserId+"' AND (F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ' OR F1_XXUSERS = '000175') AND F1_STATUS = ' ' AND F1_XXLIB <> 'L') " 
             ELSE
             	//SET FILTER TO (SF1->F1_XXUSER <> __cUserId .AND. ( SF1->F1_XXUSERS = __cUserId .OR. SF1->F1_XXUSER = '      ' ) .AND.  SF1->F1_STATUS = ' ')
             	// Filtro 2
             	cFiltro := "(F1_XXUSER <> '"+__cUserId+"' AND (F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ' ) AND F1_STATUS = ' ' AND F1_XXLIB <> 'L')"
             ENDIF
          ELSE   
          	 IF EMPTY(cSuper)   .AND. __cUserId $ cGerGestao
             	//SET FILTER TO (SF1->F1_XXUSER = __cUserId .AND. SF1->F1_XXUSERS = __cUserId .OR. SF1->F1_XXUSER = '      ' .OR. F1_XXUSERS = '000075' .OR. F1_XXUSERS = '000120')
             	// Filtro 3
             	cFiltro := "(F1_XXUSER = '"+__cUserId+"' AND F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ' OR F1_XXUSERS = '000175')"
             ELSE
             	IF __cUserId $ cGerCompras
             		//SET FILTER TO (SF1->F1_XXUSER = __cUserId .OR. SF1->F1_XXUSERS = __cUserId .OR. SF1->F1_XXUSER = '      '  .OR. SF1->F1_XXUSER $ cAlmox)
             		// Filtro 4
             		cFiltro := "(F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      '"+IIF(!empty(cAlmox)," OR F1_XXUSER IN ("+cAlmox+")","")+")"
             	ELSE
             		//SET FILTER TO (SF1->F1_XXUSER = __cUserId .OR. SF1->F1_XXUSERS = __cUserId .OR. SF1->F1_XXUSER = '      ')
             		// Filtro 5
             		cFiltro := "(F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ')"
             	ENDIF
             ENDIF  
          ENDIF
       ELSE
          IF lAClas
             //SET FILTER TO	((SF1->F1_XXUSER = __cUserId .OR. SF1->F1_XXUSERS = __cUserId .OR. SF1->F1_XXUSER = '      ' .OR. ;
          	 //			      SF1->F1_XXUSER = '&cSuper' .OR. SF1->F1_XXUSERS = '&cSuper' ) .AND.  SF1->F1_STATUS = ' ')

       		 // Filtro 6
             cFiltro := "(F1_XXUSER <> '"+__cUserId+"' AND (F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      '"+IIF(lStaf .AND. cSuper $ cGerGestao," OR F1_XXUSERS = '000175'","")+" OR "
          	 cFiltro += " F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+cSuper+"'"+IIF(lStaf .AND. __cUserId $ cGerCompras," OR F1_XXUSERS IN ("+cGerCompras+")","")+") AND F1_STATUS = ' ' AND F1_XXLIB <> 'L')"

          ELSE
              				 
             //SET FILTER TO	(SF1->F1_XXUSER = __cUserId .OR. SF1->F1_XXUSERS = __cUserId .OR. SF1->F1_XXUSER = '      ' .OR. ;
          	 //			     SF1->F1_XXUSER = "&cSuper" .OR. SF1->F1_XXUSERS = "&cSuper" )  

       		 // Filtro 7
             cFiltro := "(F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      '"+IIF(lStaf .AND. cSuper $ cGerGestao," OR F1_XXUSERS = '000175'","")+" OR "
          	 cFiltro += " F1_XXUSER = '"+cSuper+"' OR F1_XXUSERS = '"+cSuper+"'"+IIF(lStaf .AND. __cUserId $ cGerCompras," OR F1_XXUSERS IN ("+cGerCompras+")","")+")"          	 
          	 
          ENDIF
       ENDIF
    ELSEIF lAClas
       //SET FILTER TO (SF1->F1_STATUS = ' ')
       // Filtro 8
	   If ASCAN(aUser[1,10],"000000") <> 0
			lAdmFiscal := MsgBox("Filtrar os Doc a liberar", "M103FILB", "YESNO")
	   EndIf

	   If ASCAN(aUser[1,10],"000031") <> 0 .OR. lAdmFiscal
       	   cFiltro := "(F1_STATUS IN (' ','B') AND F1_XXLIB IN ('B','E','L'))"
	   ElseIf ASCAN(aUser[1,10],"000005") <> 0 .OR. ASCAN(aUser[1,10],"000007") <> 0
       	   cFiltro := "(F1_STATUS IN (' ','B'))"
	   Else
       	   cFiltro := "(F1_STATUS IN (' ','B') AND F1_XXLIB <> 'L')"
       EndIf
    ENDIF
    //If !Empty(cFiltro)
    //    cFiltro := " F1_FILIAL='"+xFilial("SF1")+"' AND "+cFiltro
    //EndIf
ENDIF

Return cFiltro




Static Function GrpAlmox()
Local cAlmox := ""
Local aUsers  := {}
Local aGrupo := {}
Local nX_ := 0
Local lAlmox := .F.
Local i:= 0

aUsers:=AllUsers()
For nX_ := 1 to Len(aUsers)
	If Len(aUsers[nX_][1][10]) > 0 
		aGrupo := {}
		aGrupo := UsrRetGrp(aUsers[nX_][1][2])
		IF LEN(aGrupo) > 0
			FOR i:=1 TO LEN(aGrupo)
				If !lAlmox
					lAlmox := (ALLTRIM(aGrupo[i]) $ cGrupAlmox )
				EndIf
			NEXT
		ENDIF			
    	If lAlmox
    		If !EMPTY(cAlmox)
    			cAlmox += ","
    		EndIf
    		cAlmox += "'"+ALLTRIM(aUsers[nX_][1][1])+"'"
    	ENDIF
 	ENDIF
NEXT

Return cAlmox
