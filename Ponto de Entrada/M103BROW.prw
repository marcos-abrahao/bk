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
Local aSup			:= {}
Local lStaf 		:= .F.
Local cFiltro		:= ""
Local cMDiretoria	:= ""
Local lMDiretoria   := .F.
Local laClas		:= .F.
Local lAdmFiscal	:= .F.
Local cGerGestao	:= u_GerGestao()
Local cGerCompras	:= u_GerCompras()
Local aGrupo		:= {}
Local cSuper		:= ""
Local cAlmox		:= ""
Local i:= 0

Dbselectarea("SF1")
If __cUserId <> "000000" 

	lStaf  := u_IsStaf(__cUserId)
	
	If !IsBlind()
		lAClas := MsgBox("Filtrar os Docs a Classificar", "M103FILB", "YESNO")
	Else
		lAClas := .T.
	EndIf

	DBCLEARFILTER() 

	aSup := FWSFUsrSup(__cUserId)
	If Len(aSup) > 0
		cSuper := aSup[1]
	EndIf

	//PswOrder(1) 
	//PswSeek(__cUserId) 
	//aUser  := PswRet(1)

 	cMDiretoria := u_GrpMDir()
    lMDiretoria := .F.
    aGrupo := {}
	aGrupo := UsrRetGrp(cUserName)
	If LEN(aGrupo) > 0
		For i:=1 To LEN(aGrupo)
			If !lMDiretoria
				lMDiretoria := (ALLTRIM(aGrupo[i]) $ cMDiretoria)
			EndIf
		Next
	EndIf	

	If __cUserId $ cGerCompras
		cAlmox := u_UsrAlmox() 
	EndIf
	
	cFiltro := ""
	// Se o usuario pertence ao grupo Administradores, User Fiscal ou Master Diretoria : não filtrar                     
    If ASCAN(aGrupo,"000000") == 0 .AND. ASCAN(aGrupo,"000031") == 0 .AND. !lMDiretoria .AND. !(__cUserId $ cGerGestao) // luis.souza removido: .AND. !(__cUserId $ '000116')
       If !lStaf .OR. EMPTY(cSuper)
          If lAClas
          	 If EMPTY(cSuper)  .AND. __cUserId $ cGerGestao 
             	// Filtro 1
             	cFiltro := "(F1_XXUSER <> '"+__cUserId+"' AND (F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSERS = '"+u_GerPetro()+"') AND F1_STATUS = ' ' AND F1_XXLIB <> 'L') " 
             Else
             	// Filtro 2 
				 If !IsBlind()
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
	   If ASCAN(aGrupo,"000000") <> 0
	   		If !IsBlind()
				lAdmFiscal := MsgBox("Filtrar os Doc a liberar", "M103FILB", "YESNO")
			Else
				lAdmFiscal := .F.
			EndIf
	   EndIf

	   If ASCAN(aGrupo,"000031") <> 0 .OR. lAdmFiscal
			If !IsBlind()
      	   		cFiltro := "(F1_STATUS IN (' ','B') AND F1_XXLIB IN ('B','E','L'))"
			Else // Mostrar as Notas a Liberar também
	       		cFiltro := "(F1_STATUS IN (' ','B'))"
			EndIf
	   ElseIf ASCAN(aGrupo,"000005") <> 0 .OR. ASCAN(aGrupo,"000007") <> 0
       	   cFiltro := "(F1_STATUS IN (' ','B'))"
	   Else
       	   cFiltro := "(F1_STATUS IN (' ','B') AND F1_XXLIB <> 'L')"
       EndIf
    EndIf
    //If !Empty(cFiltro)
    //    cFiltro := " F1_FILIAL='"+xFilial("SF1")+"' AND "+cFiltro
    //EndIf
EndIf
If IsBlind() .AND. Empty(cFiltro)
	cFiltro := "(F1_STATUS IN (' ','B'))"
EndIf

u_MsgLog("M103FILB","Super: "+cSuper+" - Staf:"+iif(lStaf,"S","N")+" - Dire:"+IIF(lMDiretoria,"S","N")+" - Class:"+IIF(lAClas,"S","N")+" - "+cFiltro)

Return cFiltro

