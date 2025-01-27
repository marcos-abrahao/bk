#include "TOTVS.CH"
#include "PROTHEUS.CH"

// Funcoes com códigos embutidos no fonte

/*/{Protheus.doc} BKUSERS
BK - Funções de Usuário especificas

@Return
@author Marcos B. Abrahão
@since 24/08/21
@version P12
/*/


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
/*
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
*/
lRet := ( Len(u_ArSubord(cId)) > 0 )

Return lRet


/*/{Protheus.doc} cSubord
    Retorna string com a lista dos subordinados de um usuário em formato de query para filtro
    @type  Function
    @author Marcos Bispo Abrahão
    @since 12/09/2023
    @version version
    @param cId (Id do usuário)
    @return lRet
    /*/
User Function cSubord(cId)
Local cUsers	:= ""
Local aUsers	:= u_ArSubord(cId)
Local nI		:= 0
Local cRet 		:= ""

For nI := 1 To Len(aUsers)
	If nI > 1
		cUsers += "|"
	EndIf
	cUsers += aUsers[nI,1]
Next

If Len(cUsers) > 0
	cRet := FormatIn(cUsers,"|")
EndIf

Return cRet


/*/{Protheus.doc} ArSubord
    Retorna array com os subordinados de um usuário
    @type  Function
    @author Marcos Bispo Abrahão
    @since 04/09/2023
    @version version
    @param cId (Id do usuário)
    @return lRet
    /*/

User Function ArSubord(cId)
Local cQuery        := ""
Local aReturn       := {}
Local aBinds        := {}
Local aSetFields    := {}
Local nRet          := 0

cQuery += "SELECT USR_ID"+CRLF 
cQuery += " FROM SYS_USR_SUPER"+CRLF
cQuery += " WHERE USR_SUPER = '"+cId+"' AND D_E_L_E_T_ = ' ' "+CRLF

//aadd(aBinds,xFilial("SA1")) // Filial

// Ajustes de tratamento de retorno
aadd(aSetFields,{"USR_ID"   ,"C",6,0})

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

If nRet < 0
  u_MsgLog("ArSubord",tcsqlerror()+" - Falha ao executar a Query: "+cQuery,"E")
Endif

Return aReturn


/*/{Protheus.doc} cSuper
    Retorna string com a lista dos superiores de um usuário em formato de query para filtro
    @type  Function
    @author Marcos Bispo Abrahão
    @since 13/09/2023
    @version version
    @param cId (Id do usuário)
    @return lRet
    /*/
User Function cSuper(cId)
Local cUsers	:= ""
Local aUsers	:= FWSFUsrSup(cId)
Local nI		:= 0
Local cRet 		:= ""

For nI := 1 To Len(aUsers)
	If nI > 1
		cUsers += "|"
	EndIf
	cUsers += aUsers[nI]
Next

If Len(cUsers) > 0
	cRet := FormatIn(cUsers,"|")
EndIf

Return cRet


// Retorna o primeiro Superior do usuario
User Function cSuper1(cId)
Local aUsers	:= FWSFUsrSup(cId)
Local cRet 		:= ""

If Len(aUsers) > 0
	cRet := aUsers[1]
EndIf

Return cRet



/*/{Protheus.doc} ArSuper
    Retorna array com os superiores de um usuário
    @type  Function
    @author Marcos Bispo Abrahão
    @since 13/09/2023
    @version version
    @param cId (Id do usuário)
    @return lRet
    /*/

User Function ArSuper(cId)
Local cQuery        := ""
Local aReturn       := {}
Local aBinds        := {}
Local aSetFields    := {}
Local nRet          := 0
Local nI            := 0
Local aSup          := {}

cQuery += "SELECT USR_SUPER"+CRLF 
cQuery += " FROM SYS_USR_SUPER"+CRLF
cQuery += " WHERE USR_ID = ? AND D_E_L_E_T_ = ' ' "+CRLF
cQuery += " ORDER BY R_E_C_N_O_ "+CRLF

aadd(aBinds,cId)

// Ajustes de tratamento de retorno
aadd(aSetFields,{"USR_SUPER"   ,"C",6,0})

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

If nRet < 0
    u_MsgLog("ArSuper",tcsqlerror()+" - Falha ao executar a Query: "+cQuery,"E")
Else
    For nI := 1 To Len(aReturn)
        aAdd(aSup,aReturn[nI,1])
    Next
Endif
Return aSup


/*/{Protheus.doc} cStaf
    Retorna array com os seus subordinados e dos seus superiores de um usuário
    @type  Function
    @author Marcos Bispo Abrahão
    @since 13/09/2023
    @version version
    @param cId (Id do usuário)
    @return lRet
    /*/
User Function cStaf(cId)
Local cUsers	:= ""
Local aSupers	:= FWSFUsrSup(cId)
Local aSubs		:= {}
Local nI		:= 0
Local nJ		:= 0
Local cRet 		:= ""
Local cBarra	:= ""

// Subordinados do Staf
aAdd(aSupers,cId)

// + Subordinados dos seus superiores
For nI := 1 To Len(aSupers)
	aSubs := u_ArSubord(aSupers[nI])
	For nJ := 1 To Len(aSubs)
		If !Empty(aSubs[nJ,1])
			cUsers += cBarra+aSubs[nJ,1]
			cBarra := "|"
		EndIf
	Next
Next

If Len(cUsers) > 0
	cRet := FormatIn(cUsers,"|")
EndIf

Return cRet

/*/{Protheus.doc} EmailUsr
    Retorna array de usuarios atraves de string de e-mails
    @type  Function
    @author Marcos Bispo Abrahão
    @since 19/09/2024
    @version version
    @param cEmails (string com e-mails já montados, separados por ";")
    @return lRet
/*/
User Function EmailUsr(cEmails)
Local cQuery        := ""
Local aReturn       := {}
Local aBinds        := {}
Local aSetFields    := {}
Local nRet          := 0
Local cFEmails      := FormatIn(cEmails,";")
Local aUsers        := {}
Local nU            := 0

// Remover brancos
cFEmails := STRTRAN(cFEmails,",''","")

cQuery := "SELECT " + CRLF
cQuery += "    USR_ID  AS USRID" + CRLF

cQuery += "  FROM [dataP10].[dbo].[SYS_USR] USR" + CRLF
cQuery += "  WHERE USR.D_E_L_E_T_ = '' " + CRLF
cQuery += "		AND USR.USR_MSBLQD = ' '" + CRLF   // Data de Bloqueio em branco
cQuery += "		AND USR.USR_EMAIL IN "+cFEmails + CRLF
cQuery += "	ORDER BY USR_ID" + CRLF
// Parametros
//aAdd(aBinds,cFEmails)
// Ajustes de tratamento de retorno
aadd(aSetFields,{"USRID"    ,"C",  6,0})

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

If nRet < 0
    u_MsgLog("EmailUsr",TCSqlError()+" - Falha ao executar a Query: "+cQuery,"E")
Else
    For nU := 1 To Len(aReturn)
        aAdd(aUsers,aReturn[nU,1])
    Next
Endif

Return aUsers

//-------------------------------

/*/{Protheus.doc} GprEmail
    Retorna string com todos emails de um grupo
    @type  Function
    @author Marcos Bispo Abrahão
    @since 25/04/24
    @version version
    @param cEmails (string com e-mails já montados, para não repetir,aUsers, aGrupo (opcional),cDepto (Opcional))
    @return lRet
/*/
User Function GprEmail(cEmails,aUsers,aGrupos,aDeptos)
Local nG        := 0
Local nU        := 0
Local aGTmp     := {}

Default cEmails := ""
Default aUsers  := {}
Default aGrupos := {}
Default aDeptos := {}

// Agrega Usuarios
For nG := 1 To Len(aUsers)
    aGTmp  := u_GrpUsers(aUsers[nG],"","")
    For nU := 1 To Len(aGTmp)
        If !(ALLTRIM(aGTmp[nU,3])+";" $ cEmails)
            cEmails += ALLTRIM(aGTmp[nU,3])+";"
        EndIf
    Next     
Next

// Agrega Grupos
For nG := 1 To Len(aGrupos)
    aGTmp  := u_GrpUsers("",aGrupos[nG],"")
    For nU := 1 To Len(aGTmp)
        If !(ALLTRIM(aGTmp[nU,3])+";" $ cEmails)
            cEmails += ALLTRIM(aGTmp[nU,3])+";"
        EndIf
    Next
Next

// Agrega Deptos
For nG := 1 To Len(aDeptos)
    aGTmp  := u_GrpUsers("","",aDeptos[nG])
    For nU := 1 To Len(aGTmp)
        If !(ALLTRIM(aGTmp[nU,3])+";" $ cEmails)
            cEmails += ALLTRIM(aGTmp[nU,3])+";"
        EndIf
    Next
Next

Return cEmails

/*/{Protheus.doc} GrpUsers
    Retorna array com os usuários de um grupo e/ou departamento
    @type  Function
    @author Marcos Bispo Abrahão
    @since 23/04/24
    @version version
    @param cGrupo (Id do grupo)
    @return lRet
/*/
User Function GrpUsers(cUser,cGrupo,cDepto)
Local cQuery        := ""
Local aReturn       := {}
Local aBinds        := {}
Local aSetFields    := {}
Local nRet          := 0

If !Empty(cUser) .OR. !Empty(cGrupo) .OR. !Empty(cDepto)
    cQuery := "SELECT " + CRLF
    cQuery += "    USRGRP.USR_ID  AS USRID" + CRLF
    cQuery += "   ,USR.USR_CODIGO AS USRCODIGO" + CRLF
    cQuery += "   ,USR.USR_EMAIL  AS USREMAIL" + CRLF
    cQuery += "   ,USRGRP.USR_GRUPO  AS USRGRUPO" + CRLF
    cQuery += "   ,GRP.GR__NOME   AS GRPNOME" + CRLF
    cQuery += "   ,USR.USR_DEPTO  AS USRDEPTO" + CRLF
    //cQuery += "   ,USR.USR_DATABLQ  AS DATABLQ" + CRLF

    cQuery += "  FROM [dataP10].[dbo].[SYS_USR_GROUPS] USRGRP" + CRLF
    cQuery += "  LEFT JOIN [dataP10].[dbo].[SYS_GRP_GROUP] GRP ON  GR__ID = USR_GRUPO" + CRLF
    cQuery += "  LEFT JOIN [dataP10].[dbo].[SYS_USR] USR ON USRGRP.USR_ID = USR.USR_ID" + CRLF
    cQuery += "  WHERE GRP.D_E_L_E_T_ = '' " + CRLF
    cQuery += "		AND USRGRP.D_E_L_E_T_ = ''" + CRLF
    cQuery += "		AND USR.D_E_L_E_T_ = ''" + CRLF
    cQuery += "		AND USR.USR_MSBLQD = ' '" + CRLF   // Data de Bloqueio em branco
    If !Empty(cUser)
        cQuery += "		AND USRGRP.USR_ID = ? " + CRLF
        aAdd(aBinds,cUser)
    EndIf
    If !Empty(cGrupo)
        cQuery += "		AND USRGRP.USR_GRUPO = ? " + CRLF
        aAdd(aBinds,cGrupo)
    EndIf
    If !Empty(cDepto)
        cQuery += "		AND UPPER(USR.USR_DEPTO) = ? "+CRLF  //'"+UPPER(cDepto)+"' " + CRLF
        aAdd(aBinds,UPPER(cDepto))
    EndIf
    cQuery += "	ORDER BY USRGRP.USR_ID" + CRLF

    // Ajustes de tratamento de retorno
    aadd(aSetFields,{"USRID"    ,"C",  6,0})
    aadd(aSetFields,{"USRCODIGO","C", 25,0})
    aadd(aSetFields,{"USREMAIL" ,"C",150,0})
    aadd(aSetFields,{"USRGRUPO" ,"C",  6,0})
    aadd(aSetFields,{"GRPNOME"  ,"C", 30,0})
    aadd(aSetFields,{"USRDEPTO" ,"C", 40,0})

    nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

    If nRet < 0
        u_MsgLog("GrpUsers",TCSqlError()+" - Falha ao executar a Query: "+cQuery,"E")
    Endif

EndIf

u_MsgLog("GrpUsers",cUser+"-"+cGrupo+"-"+cDepto+" : "+cValToChar(aReturn))

Return aReturn


/*/{Protheus.doc} UserGrps
    Retorna array com os grupos de um usuario ou de todos usuarios
    @type  Function
    @author Marcos Bispo Abrahão
    @since 22/08/24
    @version version
    @param cUser (Id do Usuario)
    @return lRet
/*/
User Function aUserGrps(cUser)
Local cQuery        := ""
Local aReturn       := {}
Local aBinds        := {}
Local aSetFields    := {}
Local nRet          := 0

cQuery := "SELECT " + CRLF
cQuery += "    USRGRP.USR_ID  AS USRID" + CRLF
cQuery += "   ,USR.USR_CODIGO AS USRCODIGO" + CRLF
cQuery += "   ,USR_GRUPO      AS USRGRUPO" + CRLF
cQuery += "   ,GRP.GR__NOME   AS GRPNOME" + CRLF

cQuery += "  FROM [dataP10].[dbo].[SYS_USR_GROUPS] USRGRP" + CRLF
cQuery += "  LEFT JOIN [dataP10].[dbo].[SYS_GRP_GROUP] GRP ON  GR__ID = USR_GRUPO" + CRLF
cQuery += "  LEFT JOIN [dataP10].[dbo].[SYS_USR] USR ON USRGRP.USR_ID = USR.USR_ID" + CRLF
cQuery += "  WHERE GRP.D_E_L_E_T_ = '' " + CRLF
cQuery += "		AND USRGRP.D_E_L_E_T_ = ''" + CRLF
cQuery += "		AND USR.D_E_L_E_T_ = ''" + CRLF
cQuery += "		AND USR.USR_MSBLQD = ' '" + CRLF   // Data de Bloqueio em branco
If !Empty(cUser)
    cQuery += "		AND USRGRP.USR_ID = ? " + CRLF
    aAdd(aBinds,cUser)
EndIf
cQuery += "	ORDER BY USRGRP.USR_ID" + CRLF

// Ajustes de tratamento de retorno
aadd(aSetFields,{"USRID"     ,"C",  6,0})
aadd(aSetFields,{"USRCODIGO" ,"C", 25,0})
aadd(aSetFields,{"USUSRGRUPO","C",  6,0})
aadd(aSetFields,{"GRPNOME"   ,"C", 30,0})

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

If nRet < 0
    u_MsgLog("GrpUsers",TCSqlError()+" - Falha ao executar a Query: "+cQuery,"E")
Endif

Return aReturn


User Function cUserGrps(cId)
Local cGrps	    := ""
Local aUsers	:= u_aUserGrps(cId)
Local nI		:= 0
Local cRet 		:= ""

For nI := 1 To Len(aUsers)
	If nI > 1
		cGrps += "|"
	EndIf
	cGrps += aUsers[nI,3]
Next

If Len(cGrps) > 0
	cRet := FormatIn(cGrps,"|")
EndIf

Return cRet





/*/{Protheus.doc} ArStaf
    Retorna array com os stafs de um usuário
    @type  Function
    @author Marcos Bispo Abrahão
    @since 22/04/24
    @version version
    @param cIdSup (Id do usuário Superior)
    @return lRet
/*/
User Function ArStaf(cIdSup)
Local cQuery        := ""
Local aReturn       := {}
Local aBinds        := {}
Local aSetFields    := {}
Local nRet          := 0
Local cGrpStaf      := u_GrpStaf()

cQuery := "SELECT " + CRLF
cQuery += "     USRSUP.USR_ID AS USRID" + CRLF
//cQuery += "     ,USR1.USR_CODIGO" + CRLF
cQuery += "     ,USR1.USR_EMAIL AS USREMAIL" + CRLF
//cQuery += "     ,USRSUP.USR_SUPER" + CRLF
//cQuery += "     ,USR2.USR_CODIGO" + CRLF
cQuery += " FROM SYS_USR_SUPER USRSUP" + CRLF
cQuery += "     LEFT JOIN [dataP10].[dbo].[SYS_USR] USR1 ON USRSUP.USR_ID = USR1.USR_ID AND USR1.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "     LEFT JOIN [dataP10].[dbo].[SYS_USR] USR2 ON USRSUP.USR_SUPER = USR2.USR_ID AND USR2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "     INNER JOIN [dataP10].[dbo].[SYS_USR_GROUPS] USRGRP ON USRSUP.USR_ID = USRGRP.USR_ID AND USRGRP.USR_GRUPO = '"+cGrpStaf+"' AND USRGRP.D_E_L_E_T_ = ' ' " + CRLF
cQuery += " WHERE  USRSUP.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "     AND USR1.USR_MSBLQD = ' '" + CRLF
cQuery += "     AND USRSUP.USR_SUPER = ? " + CRLF
cQuery += " ORDER BY USRSUP.USR_ID,USRSUP.R_E_C_N_O_" + CRLF

aadd(aBinds,cIdSup) // Usuário Superior

// Ajustes de tratamento de retorno
aadd(aSetFields,{"USRID"    ,"C",  6,0})
aadd(aSetFields,{"USREMAIL" ,"C",150,0})

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

If nRet < 0
    u_MsgLog("ArSubord",TCSqlError()+" - Falha ao executar a Query: "+cQuery,"E")
Endif

Return aReturn


// Listagem de usuarios x superiores
User Function ListSup()
Local nx		:= 0
Local ny		:= 0
Local aAllUsers 
Local aSup		:= {}
Local lRet 		:= .F.
Local aUsSup 	:= {}
Local aCabec	:= {"Usuários","Superiores","E-Mail","Depto","Cargo"}

u_WaitLog(,{ || aAllUsers := FWSFALLUSERS(,,,,.T.)} )

For nx := 1 To Len(aAllUsers)
	If aAllUsers[nx,8] == '2' //usuário ativo
		aSup := FWSFUsrSup(aAllUsers[nx][2])
		If Len(aSup) > 0
			For ny := 1 To Len(aSup)
				//u_MsgLog("ListSup",aAllUsers[nx][2]+"-"+aAllUsers[nx][4]+" : "+aSup[ny]+"-"+UsrRetName(aSup[ny]))
				aAdd(aUsSup,{aAllUsers[nx][2]+"-"+aAllUsers[nx][3],aSup[ny]+"-"+UsrRetName(aSup[ny]),aAllUsers[nx][5],aAllUsers[nx][6],aAllUsers[nx][7]})
			Next
		Else
			aAdd(aUsSup,{aAllUsers[nx][2]+"-"+aAllUsers[nx][3],"",aAllUsers[nx][5],aAllUsers[nx][6],aAllUsers[nx][7]})
		EndIf	
	EndIf
Next

u_ArrXls("LISTSUP",aUsSup,"Usuários x Superiores",aCabec)

Return lRet

/*
Usuários por depto

	SELECT USR_ID,USR_CODIGO,USR_DEPTO,USR_CARGO FROM SYS_USR USR
		WHERE USR.D_E_L_E_T_ = '' AND USR.USR_MSBLQL = '2'
		ORDER BY USR_DEPTO,USR_ID


Usuários vs Grupo

SELECT USRGRP.[USR_ID]
      ,USR.USR_CODIGO
	  ,USR_GRUPO
	  ,GRP.GR__NOME
	  ,USRGRP.USR_ID
	  ,[USR_PRIORIZA]
	  ,USR_DEPTO
	  
  FROM [dataP10].[dbo].[SYS_USR_GROUPS] USRGRP
  LEFT JOIN [dataP10].[dbo].[SYS_GRP_GROUP] GRP ON  GR__ID = USR_GRUPO
  LEFT JOIN [dataP10].[dbo].[SYS_USR] USR ON USRGRP.USR_ID = USR.USR_ID
  WHERE GRP.D_E_L_E_T_ = '' 
		AND USRGRP.D_E_L_E_T_ = ''
		AND USR.D_E_L_E_T_ = ''
		AND USR.USR_MSBLQL = '2'

		--AND USRGRP.USR_GRUPO = '000029'
		--AND USRGRP.USR_ID = '000029'
        --AND USR_DEPTO = 'RH'
	ORDER BY USRGRP.USR_ID

*/


// Listagem de usuarios
User Function ListUsr()
Local nx		:= 0
Local aAllUsers := {}
Local aUsers    := {}
Local lRet 		:= .F.
Local aCabec	:= {"Usuário","E-Mail"}

u_WaitLog(,{ || aAllUsers := FWSFALLUSERS(,,,,.T.)} )

For nx := 1 To Len(aAllUsers)
	If aAllUsers[nx,8] == '2' //usuário ativo
		aAdd(aUsers,{aAllUsers[nx][2]+"-"+aAllUsers[nx][3],ALLTRIM(UsrRetMail(aAllUsers[nX,2]))})
    EndIf
Next

u_ArrXls("LISTUSR",aUsers,"Usuários Ativos",aCabec)

Return lRet



// Retorna se o usuário pertence ao grupo ou grupos informados
User Function InGrupo(cId,cGrupos)
Local nx
Local aGrp := {}
Local lRet := .F.

If FWIsAdmin(cId)
    lRet := .T.
Else
    aGrp := FWSFUsrGrps(cId)
    For nx := 1 To Len(aGrp)
        If aGrp[nx] $ cGrupos
            lRet := .T.
            Exit
        EndIf
    Next
EndIf

Return lRet



// Libera doc de entrada após o horário 
User Function IsLibDPH(cPrw,cId)
Local lRet := .T.
//           Admin/Diego /Bruno /Katia /Andresa
If !(cId $ "000000/000016/000153/000276/000197")
    If SUBSTR(TIME(),1,2) > '19' .OR. SUBSTR(TIME(),1,2) < '07'
        u_MsgLog(cPrw,"Não é permitido incluir, classificar ou liberar documentos entre 19h e 7h","E")
        lRet := .F.
    EndIf
EndIf

Return lRet


// Libera pedido de venda pela WEB
User Function IsLibPv(cId)
//            Admin  /Teste/Diego O/Fabia/Bruno/João Cordeiro/Nelson/Marcelo Cavallari/Wiliam Lisboa/Andresa
Return cId $ "000000/000038/000016/000023/000153/000170/000165/000252/000288/000197/"


// É do grupo Fiscal
User Function IsFiscal(cId)
Return u_InGrupo(cId,u_GrpFisc())

// É do grupo Administrador ou Master Financeiro
User Function IsMasFin(cId)
Return u_InGrupo(cId,u_GrpMFin())

// Pertence a um dos grupos: Admin, Master Fin, Diretoria, Master Repac, Fiscal
User Function IsMDir(cId)
Return u_InGrupo(cId,u_cGrpMD1())

// Pertence a um dos grupos: Master Repac
User Function IsMRepac(cId)
Return u_InGrupo(cId,u_GrpRepac())

// Retorna se o usuário pertence ao STAF 
// MV_XXUSER - Parametro especifico BK - Usuarios que visualizam doc de entrada de seus superiores e do depto todo
User Function IsStaf(cId)
Return u_InGrupo(cId,u_GrpStaf())

User Function IsMRH(cId)
Return u_InGrupo(cId,u_GrpMRH())

// Retorna se o usuário é o usuário Teste
User Function IsTeste(cId)
Local lRet := .F.
If Empty(cId)
	cId := __cUserID
EndIf
If cId $ u_UsrTeste()
    lRet := .T.
EndIf
Return lRet


// Retorna se o usuário é Gestor Financeiro 
User Function IsGesFin(cId)
Local lRet := .F.
//        Diego.Oliveira/Katia/Andresa
If cId $ "000016/000276/000197/"
    lRet := .T.
EndIf
Return lRet


// Retorna se o usuário deve avaliar Fornecedores
User Function IsAvalia(cId)
Local lRet := .F.
//        Admin/Michele/Bruno
If cId $ "000000/000138/000153/"
    lRet := .T.
EndIf
Return lRet


User Function IsAvalPN(cId,cCtr,cChaveF1)
Local lRet := .F.
// Yasmin/Noé
If cId $ "000246/000247/"
    lRet := .T.
Else
	lRet := u_CtrInD1(cCtr,cChaveF1)
EndIf

Return lRet

// Grupos ----------------------------------------


// Administradores
User Function GrpAdmin()
Return "000000"

// Master Gestão
User Function GrpMGct()
Return "000003"

// User Gestão
User Function GrpUGct()
Return "000004"

// Master Financeiro
User Function GrpMFin()
Return "000005"

// Master Diretoria
User Function GrpMDir()
Return "000007"

// Master Repac
User Function GrpRepac()
Return "000008"

// Basic Gestão
User Function GrpBGct()
Return "000033"

// Staf Docs
User Function GrpStaf()
Return "000039"

// Faturamento
User Function GrpFat()
Return "000043"

// Master Compras
User Function GrpMCompras()
Return "000015"

// User Compras
User Function GrpUCompras()
Return "000016"

// Fiscal
User Function GrpFisc()
Return "000031"

// Master RH
User Function GrpMRH()
Return "000041"

User Function GrpRHPJ()
Return "000044"

// Grupo Almoxarifado
User Function GrpAlmox()
Return u_GrpUAlm()+'/'+u_GrpUAAlm()+"/"+u_GrpMAlm()

// User Almoxarifado
User Function GrpUAlm()
Return "000021"

// Master Almoxarifado
User Function GrpMAlm()
Return "000027"

// User Almoxarifado / Ativo Fixo
User Function GrpUAAlm()
Return "000032"


// User User Controladoria
User Function GrpUCtrl()
Return "000037"


// User Master Lib Docs
User Function GrpMLibDc()
Return "000038"

// Grupos de Grupos (caracter) -----------------------

// Master Dir 1
User Function cGrpMD1()
Return u_GrpAdmin()+"/"+u_GrpMFin()+"/"+u_GrpMDir()+"/"+u_GrpRepac()+"/"+u_GrpFisc()

// Master Dir 2
User Function cGrpMD2()
//000000/000005/000007/000038
Return u_GrpAdmin()+"/"+u_GrpMFin()+"/"+u_GrpMDir()+"/"+u_GrpMLibDc()+"/"+u_GrpFisc()

// Usuários ----------------------------------------

User Function UsrTeste()
Return "000038"

User Function GerFin()
// Diego Oliveira/ Andresa 
Return "000016/000197/000276/000000"

// Usuário Gerente Compras
User Function GerCompras()
// Michele
Return "000138"


// Usuário Gerente Gestão
User Function GerGestao()
// Fabia
Return "000023"


// Usuário Gerente Gestão Petrobras
User Function GerPetro()
// Marcelo Cavalari
Return "000252"

// Financeiro
// Usuários que podem integrar PJ do Rubi pelo Financeiro BKFINA02
User Function FinUsrPj()
//      Admin  Diego  Andresa/Katia
Return "000000/000016/000197/000276"


//--------------------------------------

// Emails dos gerenciadores de compras
User Function EmGerCom(cxEmail)
Local aUsers := {u_GerCompras()}
Return u_aUsrEmail(aUsers,cxEmail)


// Emails faturamento
User Function EmailFat(cUEmail)
Local aUsers 	:= {cUEmail,Substr(u_GerFin(),1,6),u_GerGestao()}
Local aGrupos 	:= {u_GrpFat()} // Grupo Faturamento
Local aDeptos 	:= {}
Local cEmail    := ""
//Local aUsers := {"000170","000242","000016","000023","000249","000273","000306"} // João C/Elaine/Diego O/Fabia/Sabrina/Leandro/Isabela

cEmail := u_GprEmail("",aUsers,aGrupos,aDeptos)

Return cEMail


// Email para Grupo do (Fabio (removido),Barbara,Jose Amauri,Bianca,Wendell)
User Function EmEstAlm(cId,lAll,cxEmail)
Local aUsers := {"000232","000216","000310","000321"}
Local cEmails:= ""

Default cxEmail := "-"

If Ascan(aUsers,cId) > 0 .OR. lAll
	cEmails := u_aUsrEmail(aUsers,cxEmail)
EndIf

Return cEmails

// Grupo Master Gestão (Adm, Fabia, Bruno, Fernando Sampaio, Marcio M, Wiliam Lisboa, Edelcio)
User Function aUsrGestao()
Local aUsers := {"000000","000023","000153","000240","000241","000288","000309"}
Return aUsers

// Email para Grupo Master Gestão
User Function EmMGestao()
Local aUsers := u_aUsrGestao()
Return u_aUsrEmail(aUsers)


// Retorna emails de diversos usuarios (array de codigos)
User Function aUsrEmail(aUsers,cxEmail)
Local cEmail := ""
Local cEmails:= ""
Local nI	 := 0

Default cxEmail := "-;"

For nI := 1 To Len(aUsers)
	If !Empty(aUsers[nI])
		cEmail  := ALLTRIM(UsrRetMail(aUsers[nI]))
		If !Empty(cEmail) .AND. !cEmail $ cxEmail
			cEmails += cEmail+";"
			cxEmail += cEmail+";"
		EndIf
	EndIf
Next

Return cEmails

User Function EmailAdm()
Return "microsiga@bkconsultoria.com.br;"

// Grupos de e-mail abaixo são paliativos enquanto não se resolve o problema do protheus não enviar para grupos do google

// E-mails do grupo financeiro 1 do google
User Function BKPgto1()
Local cRet := ""

cRet += u_EmailAdm()
cRet += u_BKEmRH()
cRet += u_BKEmGCT()
cRet += u_BKEmFin()
Return cRet

// E-mails do grupo financeiro 2 do google
User Function BKPgto2()
Local cRet := ""
cRet += u_EmailAdm()
cRet += u_BKEmFin()
cRet += u_BKEmRH()
Return cRet

// E-mails do grupo AC
User Function BKPgto3()
Local cRet := ""
cRet += u_EmailAdm()
cRet += "bruno.bueno@bkconsultoria.com.br;"
cRet += "diego.oliveira@bkconsultoria.com.br;"
cRet += "ana.campo@bkconsultoria.com.br;"
Return cRet

// E-mails do grupo qualidade do google
User Function BKEmQld()
Local cRet := ""
cRet += u_EmailAdm()
cRet += "ulisses.nunes@bkconsultoria.com.br;"
Return cRet


// E-mails do Depto financeiro
User Function BKEmFin()
Local cRet := ""

cRet := u_GprEmail("",{},{},{"Financeiro"})

/*
cRet += "andresa.cunha@bkconsultoria.com.br;"
cRet += "diego.oliveira@bkconsultoria.com.br;"
cRet += "elaine.magalhaes@bkconsultoria.com.br;"
cRet += "joao.cordeiro@bkconsultoria.com.br;"
cRet += "sabrina.nogueira@bkconsultoria.com.br;"
cRet += "kelly.neto@bkconsultoria.com.br;"
cRet += "isabela.silva@bkconsultoria.com.br;"
*/

Return cRet

// E-mails do grupo RH do google
User Function BKEmRH()
Local cRet := ""

cRet := u_GprEmail("",{},{u_GrpMRH()},{"RH"})

/*
cRet += "ana.campos@bkconsultoria.com.br;" 41
cRet += "paula.botaro@bkconsultoria.com.br;"
cRet += "edson.silva@bkconsultoria.com.br;"
cRet += "karolaine.souza@bkconsultoria.com.br;" 41
cRet += "marcio.souza@bkconsultoria.com.br;"
cRet += "rafaela.lima@bkconsultoria.com.br;"
cRet += "acsa.souza@bkconsultoria.com.br;"
cRet += "deize.silva@bkconsultoria.com.br;"
*/
cRet += "tany.sousa@bkconsultoria.com.br;"
cRet += "paloma.souza@bkconsultoria.com.br;"
cRet += "patricia.perin@bkconsultoria.com.br;"

Return cRet


// E-mails do Gestão de Contratos / Petrobras
User Function BKEmGCT()
Local cRet := ""

cRet := u_GprEmail("",{},{u_GrpMGct(),u_GrpUGct(),u_GrpRepa(),u_GrpBGct()},{})
/*

cRet += "administrativo.bhg@bkconsultoria.com.br;"
cRet += "alexandre.teixeira@bkconsultoria.com.br;"
cRet += "carlos.ferreira@bkconsultoria.com.br;"
cRet += "fabia.pesaro@bkconsultoria.com.br;"
cRet += "fernando.sampaio@bkconsultoria.com.br;"
cRet += "graziele.silva@bkconsultoria.com.br;"
cRet += "guilherme.moreira@bkconsultoria.com.br;"
cRet += "joao.gouvea@bkconsultoria.com.br;"
cRet += "joao.vitor@bkconsultoria.com.br;"
cRet += "jose.braz@bkconsultoria.com.br;"
cRet += "lincoln.santana@bkconsultoria.com.br;"
cRet += "marcelo.cavallari@bkconsultoria.com.br;"
cRet += "marcelo.soares@bkconsultoria.com.br;"
cRet += "moacyr.dalate@bkconsultoria.com.br;"
cRet += "nelson.oliveira@bkconsultoria.com.br;"
cRet += "noe.braga@bkconsultoria.com.br;"
cRet += "wiliam.lisboa@bkconsultoria.com.br;"
cRet += "edelcio.meggiolaro@bkconsultoria.com.br;"
*/

Return cRet


/*/{Protheus.doc} USRCPO
BK - Retorna campo do cadastro de usuarios
@Return cCampo
@author  Marcos Bispo Abrahão
@since 12/04/24
@version P12
/*/

User Function UsrCpo(cUser,cCampo)
Local oStatement := nil
Local cQuery     := ""
Local cAliasSQL  := ""
Local nSQLParam  := 0
Local cRet       := ""
Local aArea      := GetArea()

cQuery := "SELECT "+cCampo + CRLF
cQuery += " FROM SYS_USR" + CRLF
cQuery += "   WHERE D_E_L_E_T_ = '' AND USR_MSBLQL = '2' " + CRLF
IF VAL(cUser) > 0
    cQuery += "   AND USR_ID = ? " + CRLF
ELSE
    cQuery += "   AND UPPER(USR_CODIGO) = ? " + CRLF
ENDIF

//cQuery += "ORDER BY AC9.AC9_FILIAL, AC9.AC9_ENTIDA, AC9.AC9_CODENT, AC9.AC9_CODOBJ "

// Trata SQL para proteger de SQL injection.
oStatement := FWPreparedStatement():New()
oStatement:SetQuery(cQuery)

nSQLParam++
oStatement:SetString(nSQLParam, UPPER(cUser))

cQuery := oStatement:GetFixQuery()
oStatement:Destroy()
oStatement := nil

cAliasSQL := MPSysOpenQuery(cQuery)

Do While (cAliasSQL)->(!eof())
    cRet := (cAliasSQL)->(&cCampo)
	(cAliasSQL)->(dbSkip())
EndDo
(cAliasSQL)->(dbCloseArea())

RestArea(aArea)
Return (cRet)
