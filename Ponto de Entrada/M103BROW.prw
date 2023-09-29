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
Local lRPC 			:= IsBlind()

// Variaveis novo filtro
Local cFiltro1 		:= ""
Local lGrupo   		:= .F.
Local cSubs	 		:= ""
Local cAndOr		:= ""


Dbselectarea("SF1")
If __cUserId <> "000000" 

	lStaf  := u_IsStaf(__cUserId)
	
	If !lRPC
		//lAClas := MsgBox("Filtrar os Docs a Classificar/Aprovar", "M103FILB", "YESNO")
		lAClas := u_MsgLog("M103FILB","Filtrar os Docs a Classificar?","Y")
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
	   If ASCAN(aGrupo,"000000") <> 0
	   		If !lRPC
				//lAdmFiscal := MsgBox("Filtrar os Doc a liberar", "M103FILB", "YESNO")
				lAdmFiscal := u_MsgLog("M103FILB","Filtrar os Doc a liberar?","Y")
			Else
				lAdmFiscal := .F.
			EndIf
	   EndIf

	   If ASCAN(aGrupo,"000031") <> 0 .OR. lAdmFiscal
			If !lRPC
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
If lRPC .AND. Empty(cFiltro)
	cFiltro := "(F1_STATUS IN (' ','B'))"
EndIf

u_MsgLog("M103FILB","Super: "+cSuper+" - Staf:"+iif(lStaf,"S","N")+" - Dire:"+IIF(lMDiretoria,"S","N")+" - Class:"+IIF(lAClas,"S","N")+" - Filtra a liberar:"+IIF(lAdmFiscal,"S","N")+" - "+cFiltro)


// Novo Filtro - Aprovação em duas etapas


// Dados pesquisados em 03/09/23
// Controladoria e Diretoria ----------------------------------------------------------

/*
BeginContent var cGrpCtr

000000-Administrador 
000012-Xavier
000153-bruno.bueno
000056-vanderleia.silva

Grupo 0 - Administradores
000012	Xavier                   
000029	mkogan                   
000040	tobias.kogan             
000098	caroline                 
000113	Pierre                   
000240	marcio.menezes           

Grupo 7 - Diretoria
000029	mkogan                   
000065	Diego                    
000240	marcio.menezes                     

EndContent
*/

/*
Staf:N - Dire:S - Class:N - 
Staf:N - Dire:S - Class:S - (F1_STATUS IN (' ','B') AND F1_XXLIB <> 'L')
Staf:N - Dire:S - Class:S - (F1_STATUS IN (' ','B') AND F1_XXLIB <> 'L') (RPC)
Staf:N - Dire:N - Class:S - (F1_STATUS IN (' ','B') AND F1_XXLIB IN ('B','E','L'))  (Xavier)
*/
If u_InGrupo(__cUserId,"000000/000007/000038") // Administradores/Diretoria/Master Libera
	If lAClas .OR. lRPC
		If lAdmFiscal
			cFiltro1 := "(F1_STATUS IN (' ','B') AND F1_XXLIB IN ('B','E','L'))"
		Else
			cFiltro1 := "(F1_STATUS IN (' ','B') AND F1_XXLIB <> 'L')"
		EndIf
	EndIf
	lGrupo   := .T.
EndIf


// Master Financeiro ----------------------------------------------------------

/*
BeginContent var cGrpFin
000011-Laudecir
000016-diego.oliveira
000241-fernando.sampaio
EndContent
*/

/*
Staf:S - Dire:S - Class:N - 
Staf:S - Dire:S - Class:S - (F1_STATUS IN (' ','B'))
Staf:S - Dire:S - Class:S - (F1_STATUS IN (' ','B')) (RPC)
*/
If u_IsMasFin(__cUserId)
	If lAClas .OR. lRPC
		cFiltro1 := "(F1_STATUS IN (' ','B'))"
	EndIf
	lGrupo   := .T.
EndIf


// Fiscal: ----------------------------------------------------------

/*
BeginContent var cGrpFis
000256-elber.moura
000229-jalielison.alves
000261-glaciana.oliveira
EndContent
*/

/*
Staf:N - Dire:S - Class:N - 
Staf:N - Dire:S - Class:S - (F1_STATUS IN (' ','B') AND F1_XXLIB IN ('B','E','L'))
RPC Staf:N - Dire:S - Class:S - (F1_STATUS IN (' ','B'))
*/

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

Staf:N - Dire:N - Class:N - (F1_XXUSER = '000064' OR F1_XXUSERS = '000064')
Staf:N - Dire:N - Class:S - (F1_XXUSER <> '000186' AND (F1_XXUSERS = '000186') AND F1_STATUS = ' ' AND F1_XXLIB <> 'L')
RPC                         ((F1_XXUSER = '000216' OR F1_XXUSERS = '000216') AND F1_STATUS = ' ' AND F1_XXLIB <> 'L')

000064-marcelo.soares
000112-tiago.ribeiro
000176-joao.vitor
000192-guilherme.moreira
000186-allan.assis
000125-ana.campos
000216-jose.amauri
000232-barbara.santos
000234-bruna.alves
000239-juliana.villegas 
000245-rafaela.lima
000246-yasmin.teixeira
000248-pericles.turrini
000250-camila.gomes
000252-marcelo.alves
000254-janaina.silva
000277-ticiane.alves
000286-lucas.silva
000274-priscila.nunes
000276-katia.galdino
000116-luis.souza

--------------------------
Staf:
Staf:S - Dire:N - Class:N - (F1_XXUSER = '000076' OR F1_XXUSERS = '000076' OR  F1_XXUSER = '000257' OR F1_XXUSERS = '000257')
Staf:S - Dire:N - Class:S - ( F1_XXUSER <> '000165' AND (F1_XXUSERS = '000165' OR F1_XXUSERS = '000056' OR  F1_XXUSER = '000056' OR F1_XXUSERS = '000056') AND F1_STATUS = ' ' AND F1_XXLIB <> 'L')

000076-edson.silva
000165-nelson.oliveira
000093-fabio.quirino
--------------------------

--------------------------
Compras e Almoxarifado
000093-fabio.quirino MATA103 M103FILB: Super: 000116 - Staf:S - Dire:N - Class:N - (F1_XXUSER = '000093' OR F1_XXUSERS = '000093' OR  F1_XXUSER = '000116' OR F1_XXUSERS = '000116' OR F1_XXUSERS IN ('000138','000093'))
000093-fabio.quirino MATA103 M103FILB: Super: 000116 - Staf:S - Dire:N - Class:S - ( (F1_XXUSERS = '000093' OR  F1_XXUSER = '000116' OR F1_XXUSERS = '000116' OR F1_XXUSERS IN ('000138','000093')) AND F1_STATUS = ' ' AND F1_XXLIB <> 'L')
000093-fabio.quirino RPC M103FILB: Super: 000116 - Staf:S - Dire:N - Class:S - ( (F1_XXUSERS = '000093' OR  F1_XXUSER = '000116' OR F1_XXUSERS = '000116' OR F1_XXUSERS IN ('000138','000093')) AND F1_STATUS = ' ' AND F1_XXLIB <> 'L')

000138-michele.moraes MATA103 M103FILB: Super: 000116 - Staf:N - Dire:N - Class:N - (F1_XXUSER = '000138' OR F1_XXUSERS = '000138' OR F1_XXUSER IN ('000093','000126','000216','000225','000226','000227'))
000138-michele.moraes MATA103 M103FILB: Super: 000116 - Staf:N - Dire:N - Class:N - (F1_XXUSER = '000138' OR F1_XXUSERS = '000138' OR F1_XXUSER IN ('000093','000216','000225','000226'))
000138-michele.moraes MATA103 M103FILB: Super: 000116 - Staf:N - Dire:N - Class:S - (F1_XXUSER <> '000138' AND (F1_XXUSERS = '000138') AND F1_STATUS = ' ' AND F1_XXLIB <> 'L')
000138-michele.moraes RPC M103FILB: Super: 000116 - Staf:N - Dire:N - Class:S - ((F1_XXUSER = '000138' OR F1_XXUSERS = '000138') AND F1_STATUS = ' ' AND F1_XXLIB <> 'L')

*/

If !lGrupo
	//If lAClas .AND. !lRPC
	//	cFiltro1 := "((F1_XXUSER <> '"+__cUserId+"' "
	//	cAndOr := " AND "
	//Else
		cFiltro1 := "((F1_XXUSER = '"+__cUserId+"'  "
		cAndOr := " OR "
	//EndIf

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

u_MsgLog("M103FILB1","Super: "+cSuper+" - Staf:"+iif(lStaf,"S","N")+" - Dire:"+IIF(lMDiretoria,"S","N")+" - Class:"+IIF(lAClas,"S","N")+" - Filtra a liberar:"+IIF(lAdmFiscal,"S","N")+" - "+cFiltro1)

Return cFiltro1

