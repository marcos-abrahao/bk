#include "TOTVS.CH"
#include "PROTHEUS.CH"

// Funcoes com códigos embutidos no fonte

/*/{Protheus.doc} BKGRUPOS
BK - Array com as empresas do grupo BK

@Return
@author Marcos B. Abrahão
@since 24/08/21
@version P12
/*/

User Function BKGrupo()
// Empresas ativas
Local aEmpresas	:= {    {"01","BK"			,"BK"},;
                        {"02","MMDK"		,"MMDK"},;
                        {"12","BK CORRETORA","CORRETORA"},;
                        {"14","BALSA NOVA"	,"BALSA"},;
                        {"15","BHG INT 3"	,"BHG"},;
						{"16","MOOVE-SP"	,"MOOVE"},;
						{"17","DMAF"		,"DMAF"},;
						{"18","BK VIA"		,"BK VIA"},;
						{"19","BK SOLUÇÕES"	,"BK S.TEC."} }
Return aEmpresas


User Function BKGrpGct()
// Empresas que utilizam Gestão de Contratos
Local aEmpresas	:= {    {"01","BK"},;
                        {"02","MMDK"},;
                        {"14","BALSA NOVA"},;
                        {"18","BKVIA"}}
Return aEmpresas


User Function BKGrpDsp()
// Empresas que utilizam possuem despesas em contratos
Local aEmpresas	:= {    {"01","BK"},;
                        {"02","MMDK"},;
                        {"14","BALSA NOVA"},;
                        {"15","BHG INT 3"} ,; // Empresa 15 possui despesas
						{"16","MOOVE-SP"},;
                        {"18","BKVIA"}}
Return aEmpresas


User Function BKEmpr()
// Todas Empresas
Local aEmpresas	:= {    {"01","BK"              ,"BK"},;
                        {"02","MMDK"            ,"MMKD"},;
                        {"04","ESA"             ,"ESA"},;
                        {"06","BKDAHER SUZANO"  ,"BKDAHER S"},;
                        {"07","JUST SOFTWARE"   ,"JUST"},;
                        {"08","BHG CAMPINAS"    ,"BHG CAMP"},;
                        {"09","BHG OSASCO"      ,"BHG OSAS"},;
                        {"10","BKDAHER TABOAO"  ,"BKDAHER T"},;
                        {"11","BKDAHER LIMEIRA" ,"BKDAHER L"},;
                        {"12","BK CORRETORA"    ,"CORRETORA"},;
                        {"14","BALSA NOVA"      ,"BALSA"},;
                        {"15","BHG INT 3"       ,"BHG"},;
						{"16","MOOVE-SP"        ,"MOOVE"},; 
						{"17","DMAF"            ,"DMAF"},; 
                        {"18","BK VIA"          ,"BK VIA"},;
                        {"19","BK S. TECNOL."   ,"BK S.TEC."},;
                        {"97","CMOG"            ,"CMOG"},;
                        {"98","TERO"            ,"TERO"} }
Return aEmpresas


User Function BKNEmpr(cEmpr,nI)
Local aEmpr := u_BKEmpr()
Local nEmpr := Ascan(aEmpr,{|x| x[1] == cEmpr})
Local cNEmp := ""
If nEmpr > 0
	cNEmp := aEmpr[nEmpr,nI]
EndIf
Return cNEmp


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

cQuery += "SELECT USR_SUPER"+CRLF 
cQuery += " FROM SYS_USR_SUPER"+CRLF
cQuery += " WHERE USR_ID = '"+cId+"' AND D_E_L_E_T_ = ' ' "+CRLF
cQuery += " ORDER BY R_E_C_N_O_ "+CRLF

//aadd(aBinds,xFilial("SA1")) // Filial

// Ajustes de tratamento de retorno
aadd(aSetFields,{"USR_SUPER"   ,"C",6,0})

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

If nRet < 0
  u_MsgLog("ArSuper",tcsqlerror()+" - Falha ao executar a Query: "+cQuery,"E")
Endif

Return aReturn


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


// Listagem de usuarios x superiores
User Function ListSup()
Local nx		:= 0
Local ny		:= 0
Local aAllUsers 
Local aSup		:= {}
Local lRet 		:= .F.
Local aUsSup 	:= {}
Local aCabec	:= {"Usuários","Superiores"}

u_WaitLog(,{ || aAllUsers := FWSFALLUSERS(,,,,.T.)} )

For nx := 1 To Len(aAllUsers)
	If aAllUsers[nx,8] == '2' //usuário ativo
		aSup := FWSFUsrSup(aAllUsers[nx][2])
		If Len(aSup) > 0
			For ny := 1 To Len(aSup)
				//u_MsgLog("ListSup",aAllUsers[nx][2]+"-"+aAllUsers[nx][4]+" : "+aSup[ny]+"-"+UsrRetName(aSup[ny]))
				aAdd(aUsSup,{aAllUsers[nx][2]+"-"+aAllUsers[nx][3],aSup[ny]+"-"+UsrRetName(aSup[ny])})
			Next
		Else
			aAdd(aUsSup,{aAllUsers[nx][2]+"-"+aAllUsers[nx][3],""})
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
Local aGrp := FWSFUsrGrps(cId)
Local lRet := .F.

For nx := 1 To Len(aGrp)
	If aGrp[nx] $ cGrupos
		lRet := .T.
		Exit
	EndIf
Next

Return lRet



// Libera doc de entrada após o horário 
User Function IsLibDPH(cPrw,cId)
Local lRet := .T.
//           Admin/Lau   /Diego /Bruno /Luisinho 116 (provisório/removido)
If !(cId $ "000000/000012/000016/000153")
    If SUBSTR(TIME(),1,2) > '19' .OR. SUBSTR(TIME(),1,2) < '07'
        u_MsgLog(cPrw,"Não é permitido incluir, classificar ou liberar documentos entre 19h e 7h","E")
        lRet := .F.
    EndIf
EndIf

Return lRet


// Libera pedido de venda pela WEB
User Function IsLibPv(cId)
//            Admin  /Teste/Xavier/Diego O/Fabia/Bruno/João Cordeiro/Nelson/Marcelo Cavallari/Wiliam Lisboa
Return cId $ "000000/000038/000012/000016/000023/000153/000170/000165/000252/000288/"


// É do grupo Fiscal
User Function IsFiscal(cId)
Return u_InGrupo(cId,"000031")

// É do grupo Administrador ou Master Financeiro
User Function IsMasFin(cId)
Return u_InGrupo(cId,"000000/000005")

// Pertence a um dos grupos: Admin, Master Fin, Diretoria, Master Repac, Fiscal
User Function IsMDir(cId)
Return u_InGrupo(cId,"000000/000005/000007/000008/000031")

// Pertence a um dos grupos: Master Repac
User Function IsMRepac(cId)
Return u_InGrupo(cId,"000008")


// Retorna se o usuário pertence ao STAF 
// MV_XXUSER - Parametro especifico BK - Usuarios que visualizam doc de entrada de seus superiores e do depto todo
User Function IsStaf(cId)
Local lRet := .F.
// Laudecir/Diego.Oliveira/Edson/Fabio/Vanderleia/Nelson/Luis (000116/ removido)
//If cId $ "000011/000016/000076/000093/000056/000165/"
//    lRet := .T.
//EndIf
Return u_InGrupo(cId,"000039")
Return lRet


// Retorna se o usuário é o usuário Teste
User Function IsTeste(cId)
Local lRet := .F.
If Empty(cId)
	cId := __cUserID
EndIf
If cId $ "000038"
    lRet := .T.
EndIf
Return lRet


// Retorna se o usuário é Gestor Financeiro 
User Function IsGesFin(cId)
Local lRet := .F.
//      Laudecir/Xavier/Diego.Oliveira/Katia
If cId $ "000011/000012/000016/000276"
    lRet := .T.
EndIf
Return lRet


// Retorna se o usuário deve avaliar Fornecedores (Compras e Almox)
User Function IsAvalia(cId)
Local lRet := .F.
// Admin/Xavier/Michele/Bruno
If cId $ "000000/000012/000138/000153/"
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

// Contratos que devem ser avaliados na Pré-Nota 24/02/23
User Function CtrAval()
cRet := "281000577" // UTGCA
Return cRet


// Retornar se algum centro de custo foi usado na Nota/Prenota
User Function CtrInD1(cCtr,cChaveF1)
Local lRet := .F.
Local aAreaSD1   := SD1->(GetArea())

Default cCtr     := u_CtrAval()
Default cChaveF1 := SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

SD1->(dbSetOrder(1))  // * Itens da N.F. de Compra
If SD1->(DbSeek(xFilial("SD1")+cChaveF1))
	Do While !EOF() .AND. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)  == xFilial("SD1")+cChaveF1
		If ALLTRIM(SD1->D1_CC) $ cCtr
			lRet := .T.
			Exit
		EndIf
		SD1->(dbSkip())
	EndDo
EndIf

SD1->(RestArea(aAreaSD1))

Return lRet


// Gerente Compras
User Function GerCompras
// Michele,Luis /000116 (removido),Fabio
Return "000138/000093"


// Emails dos gerenciadores de compras
User Function EmGerCom(cxEmail)
Local aUsers := {"000138","000093"} // Michele,Luis (removido),Fabio
Return u_aUsrEmail(aUsers,cxEmail)


// Emails faturamento
User Function EmailFat(cxEmail)
Local aUsers := {"000170","000242","000016","000023","000249","000273","000306"} // João C/Elaine/Diego O/Fabia/Sabrina/Leandro/Isabela
Return u_aUsrEmail(aUsers,cxEmail)


// Gerente Gestão
User Function GerGestao
// Fabia
Return "000023"


// Gerente Gestão Petrobrás
User Function GerPetro
// Marcelo Cavalari
Return "000252"


// Grupo Almoxarifado
User Function GrpAlmox
Return "000021/000032"


// Usuarios Almoxarifado (para queries)
User Function UsrAlmox()
Return "'000093','000216','000225','000226'"


// Usuarios Master Almoxarifado (grupo 27)
User Function UsrMAlmox()
Return "000093/000216/000232/000225"  


// Email para Grupo do (Fabio,Barbara,Jose Amauri)
User Function EmEstAlm(cId,lAll,cxEmail)
Local aUsers := {"000093","000232","000216"}
Local cEmails:= ""

Default cxEmail := "-"

If Ascan(aUsers,cId) > 0 .OR. lAll
	cEmails := u_aUsrEmail(aUsers,cxEmail)
EndIf

Return cEmails


// Email para Grupo Master Gestão (Adm, Fabia, Bruno, Fernando Sampaio, Marcio M e Wiliam Lisboa)
User Function EmMGestao()
Local aUsers := {"000000","000023","000153","000240","000241","000288"}
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



// Financeiro
// Usuários que podem integrar PJ do Rubi pelo Financeiro BKFINA02
User Function FinUsrPj()
//      Admin  Lau    Xavier Diego  Andresa
Return "000000/000011/000012/000016/000197"


// Grupos de e-mail abaixo são paliativos enquanto não se resolve o problema do protheus não enviar para grupos do google

// E-mails do grupo financeiro 1 do google
User Function BKPgto1()
Local cRet := ""

cRet += "microsiga@bkconsultoria.com.br;"
cRet += u_BKEmRH()
cRet += u_BKEmGCT()
cRet += u_BKEmFin()
Return cRet

// E-mails do grupo financeiro 2 do google
User Function BKPgto2()
Local cRet := ""
cRet += "microsiga@bkconsultoria.com.br;"
//cRet += "jalielison.alves@bkconsultoria.com.br;"
cRet += u_BKEmFin()
cRet += u_BKEmRH()
Return cRet

// E-mails do grupo AC
User Function BKPgto3()
Local cRet := ""
cRet += "microsiga@bkconsultoria.com.br;"
cRet += "adalberto.xavier@bkconsultoria.com.br;"
//cRet += "christiane.almeida@bkconsultoria.com.br;"
cRet += "bruno.bueno@bkconsultoria.com.br;"
cRet += "laudecir.carpi@bkconsultoria.com.br;"
Return cRet

// E-mails do grupo qualidade do google
User Function BKEmQld()
Local cRet := ""
cRet += "microsiga@bkconsultoria.com.br;"
cRet += "ulisses.nunes@bkconsultoria.com.br;"
Return cRet


// E-mails do grupo financeiro do google
User Function BKEmFin()
Local cRet := ""

cRet += "adalberto.xavier@bkconsultoria.com.br;"
cRet += "andresa.cunha@bkconsultoria.com.br;"
cRet += "diego.oliveira@bkconsultoria.com.br;"
cRet += "elaine.magalhaes@bkconsultoria.com.br;"
cRet += "joao.cordeiro@bkconsultoria.com.br;"
cRet += "laudecir.carpi@bkconsultoria.com.br;"
cRet += "sabrina.nogueira@bkconsultoria.com.br;"
cRet += "kelly.neto@bkconsultoria.com.br;"
cRet += "isabela.silva@bkconsultoria.com.br;"

Return cRet

// E-mails do grupo financeiro do google
User Function BKEmRH()
Local cRet := ""

cRet += "ana.campos@bkconsultoria.com.br;"
cRet += "paula.botaro@bkconsultoria.com.br;"
cRet += "edson.silva@bkconsultoria.com.br;"
cRet += "karolaine.souza@bkconsultoria.com.br;"
cRet += "marcio.souza@bkconsultoria.com.br;"
cRet += "rafaela.lima@bkconsultoria.com.br;"
cRet += "acsa.souza@bkconsultoria.com.br;"
cRet += "deize.silva@bkconsultoria.com.br;"
cRet += "tany.sousa@bkconsultoria.com.br;"
cRet += "paloma.souza@bkconsultoria.com.br;"
cRet += "patricia.perin@bkconsultoria.com.br;"
cRet += "victor.silva@bkconsultoria.com.br;"
Return cRet


// E-mails do grupo Gestão do google
User Function BKEmGCT()
Local cRet := ""

cRet += "administrativo.bhg@bkconsultoria.com.br;"
cRet += "alexandre.teixeira@bkconsultoria.com.br;"
cRet += "carlos.ferreira@bkconsultoria.com.br;"
cRet += "christiane.rodrigues@bkconsultoria.com.br;"
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
cQuery += "   AND USR_ID = ? " + CRLF

//cQuery += "ORDER BY AC9.AC9_FILIAL, AC9.AC9_ENTIDA, AC9.AC9_CODENT, AC9.AC9_CODOBJ "

// Trata SQL para proteger de SQL injection.
oStatement := FWPreparedStatement():New()
oStatement:SetQuery(cQuery)

nSQLParam++
oStatement:SetString(nSQLParam, cUser)

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
