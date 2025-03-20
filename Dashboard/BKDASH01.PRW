#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDASH01
BK - Geração de tabelas para o PowerBI no banco PowerBK - Gestão
@Return
@author Marcos Bispo Abrahão
@since 28/08/2022
@version P12.1.33
/*/
// Chamada do Schedule
// https://tdn.totvs.com/pages/releaseview.action?pageId=36800166


/*
Static Function Scheddef()
Local aParam
Local aOrd     := {}

aParam := {	"P",;		//Tipo R para relatorio P para processo   
			"PARAMDEF",;// Pergunte do relatorio, caso nao use passar ParamDef            
			"",;		// Alias            
			aOrd}		//Array de ordens   
//			"PowerBk"}

Return aParam
*/


User Function BKDASH01(aParam)
Local aCampos := {{ "MARCA"    , "C", 02, 0, "Marca"    ,"@!", .F., "" },;
				  { "ROTINA"   , "C", 15, 0, "Rotina"   ,"@!", .T., "" },;
				  { "MODULO"   , "C", 10, 0, "Módulo"   ,"@!", .T., "" },;
				  { "DESCRICAO", "C", 70, 0, "Descrição","@!", .T., "" } }

Local aDados  := {}
Local nX 	  := 0
Local aGrpDsp := u_BKGrpDsp()
Local bProg

Local cP1H	  := ""
Local cP0613  := ""
Local cP0712  := ""
Local cP12 	  := ""
Local cP19	  := ""
Local cP19D	  := ""

Local lOk     := .F.
Local cUser	  := "000000"

Private cTitulo     := "Dashboard PowerBk e Avisos"
Private cPerg       := "BKDASH01"

Private cEmpPar  := "01"
Private cFilPar  := "01"

default aParam := {"01","01"} // caso nao receba nenhum parametro

cEmpPar := aParam[1]
cFilPar := aParam[2]

If IsBlind()
	RpcSetType (3)
	RpcSetEnv(cEmpPar,cFilPar)
Else
	cEmpPar := cEmpAnt
	cFilPar := cFilAnt
	cUser	:= __cUserID
	aParam  := {cEmpAnt,cFilAnt}
EndIf

// Todas empresas de hora em hora

//u_WaitLog(cPerg,{|oSay| u_FINA05S({cEmpPar,cFilPar,cUser}) },"Importando txt financeiro ADP - Empresa "+FWCodEmp())

// Executar somente se a empresa for a BK
If FWCodEmp() == "01"

	aDados  := {}

	If IsBlind() 
		If SUBSTRING(TIME(),1,2) > '05' ;
			.AND. SUBSTRING(TIME(),1,2) < '20';
			.AND. DOW(DATE()) <> 7;
			.AND. DOW(DATE()) <> 1
			cP1H := "X"
		EndIf
		If cP1H == "X"
			If SUBSTRING(TIME(),1,2) $ '06/10/13'
				cP0613 := "X"
			EndIf

			If SUBSTRING(TIME(),1,2) $ '07/12'
				cP0712 := "X"
			EndIf

			If SUBSTRING(TIME(),1,2) == '19'
				cP19 := "X"
			EndIf
		Else
			If DOW(DATE()) == 1 .AND. SUBSTRING(TIME(),1,2) == '19'
				cP19D := "X"
			EndIf
		EndIf
	EndIf

	// Dashboard
	aAdd(aDados,{cP19	,"U_BKDSPRD()",		"DASHBOARD",	"Atualização da tabela PRODUTOS"})
	aAdd(aDados,{cP0613	,"U_BKDSDSP1()",	"DASHBOARD",	"Atualização da tabela PREVDESP1"})
	aAdd(aDados,{cP0613	,"U_BKDSDSP2()",	"DASHBOARD",	"Atualização da tabela PREVDESP2"})
	aAdd(aDados,{cP19	,"U_BKDSEMP()",		"DASHBOARD",	"Atualização da tabela EMPRESAS"})
	aAdd(aDados,{cP19	,"U_BKDSCC()",		"DASHBOARD",	"Atualização da tabela CCUSTOS"})
	aAdd(aDados,{cP0613	,"U_BKDSFOL()",		"DASHBOARD",	"Atualização da tabela FOLHA"})
	aAdd(aDados,{cP0613	,"U_BKDSFER()",		"DASHBOARD",	"Atualização da tabela FERIAS"})
	aAdd(aDados,{cP19	,"U_BKDSUSR()",		"DASHBOARD",	"Atualização da tabela USUARIOS"})
	aAdd(aDados,{cP0613	,"U_BKDSTUR()",		"DASHBOARD",	"Atualização da tabela FOLHAFIL e FOLHATUR"})
	aAdd(aDados,{cP0613	,"U_BKDSBKTUR()",	"DASHBOARD",	"Atualização da tabela FOLHAFILBK"})
	aAdd(aDados,{cP0613	,"U_BKDSBKFAL()",	"DASHBOARD",	"Atualização da tabela FOLHAFAL"})
	aAdd(aDados,{cP0712	,"U_BK040PER()",	"DASHBOARD",	"Atualização da tabela BK040PER"})
	aAdd(aDados,{cP0712	,"U_BKDSSC()",		"DASHBOARD",	"Atualização da tabela SOLCOMPRAS"})
	aAdd(aDados,{cP0712	,"U_BKDSCFAT()",	"DASHBOARD",	"Atualização da tabela CANCFATURAMENTO"})
	aAdd(aDados,{cP0712	,"U_BKDSGES()",		"DASHBOARD",	"Atualização da tabela GESTORES"})
	aAdd(aDados,{cP0712	,"U_BKDSGLO()",		"DASHBOARD",	"Atualização da tabela GLOSAS"})
	aAdd(aDados,{cP0712	,"U_BKDSCTR()",		"DASHBOARD",	"Atualização da tabela CONTRATOS"})
	aAdd(aDados,{cP0712	,"U_BKDSPLA()",		"DASHBOARD",	"Atualização da tabela PLANILHAS"})
	aAdd(aDados,{cP0712	,"U_BKDSCRO()",		"DASHBOARD",	"Atualização da tabela CRONOGRAMAS"})
	aAdd(aDados,{cP0712	,"U_BKDSGG()",		"DASHBOARD",	"Atualização da tabela GASTOSGERAIS"})
	aAdd(aDados,{cP0712	,"U_BKDSGCO()",     "DASHBOARD",    "Atualização da tabela GASTOSCONSORCIOS"})
	aAdd(aDados,{cP0712	,"U_BKDSFAT()",		"DASHBOARD",	"Atualização da tabela FATURAMENTO"})
	aAdd(aDados,{cP0712	,"U_BKDSGER()",		"DASHBOARD",	"Atualização da tabela GERAL"})
	aAdd(aDados,{cP19D	,"U_BKDSPRTUR()",	"DASHBOARD",	"Criação/atualização da Procedure BKTURNOVER"})
	aAdd(aDados,{cP19D	,"U_BKPRBKTUR()",	"DASHBOARD",	"Criação/atualização da Procedure BKTURNOVER1"})
	aAdd(aDados,{cP19D	,"U_BKDSPRFAL()",	"DASHBOARD",	"Criação/atualização da Procedure BKFALTAS"})

	// Outros programas
	aAdd(aDados,{cP19D	,"U_BKMsgLmp()",	"OUTROS",		"Limpeza de registros da tabela SZ0"})


	// EspelhoADP
	aAdd(aDados,{cP19	,"U_BKADPEVE()",	"ADP",			"Atualização da tabela EspelhoADP.dbo.EventosProtheus"})

	// Avisos
	aAdd(aDados,{cP0712	,"U_BKMSG001()",	"AVISOS",		"Aviso de documentos pendentes de aprovação"})
	aAdd(aDados,{cP19D	,"U_BKMSG002()",	"AVISOS",		"Aviso de entidades com Conta Contábil Bloqueada"})
	aAdd(aDados,{cP19D	,"U_BKMSG003()",	"AVISOS",		"Aviso de Clientes sem virgula no endereço"})
	aAdd(aDados,{cP19D	,"U_BKMSG004()",	"AVISOS",		"Aviso de Clientes sem Conta Bancária para Depósito"})
	aAdd(aDados,{cP1H	,"U_BKMSG005()",	"AVISOS",		"Aviso de Pedidos de Venda Liberados"})
	aAdd(aDados,{cP12	,"U_BKMSG006()",	"AVISOS",		"Aviso de lançamentos de despesas"})
	aAdd(aDados,{cP19D	,"U_BKMSG007()",	"AVISOS",		"Aviso de lançamentos de despesas em contratos vencidos a mais de 60 dias"})
	aAdd(aDados,{cP19	,"U_BKMSG008()",	"AVISOS",		"Aviso de Pedidos de compras não entregues"})
	aAdd(aDados,{cP19	,"U_BKMSG009()",	"AVISOS",		"Aviso de Solicitações de compras em aberto"})
	aAdd(aDados,{cP19	,"U_BKMSG010()",	"AVISOS",		"Aviso de Novos eventos ADP cadastrados"})

	// Financeiro
	//aAdd(aDados,{cP1H	,"U_BKFINA05()",	"FINANCEIRO",	"Importar txt lançamentos da Folha ADP"})

	If !IsBlind()
		u_TTMARKB(aCampos, aDados, .F.)
	EndIf

	For nX := 1 To Len(aDados) 
		If !Empty(aDados[nX,1])
			bProg := {|oSay| x:= &(aDados[nX,2]) }
			u_WaitLog(cPerg, bProg, aDados[nX,2]+": "+aDados[nX,4])
		EndIf
	Next nX

ElseIf Ascan(aGrpDsp,{|x| x[1] == cEmpAnt}) > 0

	If !IsBlind()
		If u_MsgLog(cPerg,"Confirma a atualização das tabelas de Fluxo de Caixa Por Contrato do banco de dados PowerBk?", "Y")
			lOk := .T.
		EndIf
	ElseIf SUBSTRING(TIME(),1,2) == '20'
		lOk := .T.
	EndIf
	If lOk
		u_WaitLog(cPerg,{|oSay| U_BKGCTR26(.T.) },"Atualizando as tabelas de Fluxo de Caixa Por Contrato do banco de dados PowerBk...")
	EndIf

EndiF

Return


// Log de erros das queries do dashboard
User Function QryResult(cProg,cQry,cErro)
Local cMens := ""

If !Empty(cErro)
	cErro 	:= "/* Erro na atualização: "+ CRLF + cErro + " */" +  CRLF
	cErro 	+= '/* <a href="javascript:history.back()">Voltar</a> */' + CRLF

	cMens 	:= "Ocorreram erros na execução do programa "+cProg+CRLF+cErro
	cErro	:= StrTran(cErro, CRLF, "<br>")

	u_GrvAnexo(cProg+".html",cErro,.F.)
	u_BKMsgUs(cEmpAnt,cProg,{},u_GrpAdmin(),cMens,cMens,"F",cProg+".html",DataValida(DATE()+1))
	u_MsgLog(cProg,cMens,"E")
Else

	cMens	:= "Programa "+cProg+" executado com sucesso!"
	cQry 	:= '/* <a href="javascript:history.back()">Voltar</a> */' + CRLF + cQry
	cQry	:= StrTran(cQry, CRLF, "<br>")

	u_GrvAnexo(cProg+".html",cQry,.F.)
	u_BKMsgUs(cEmpAnt,cProg,{},u_GrpAdmin(),cMens,cMens,"F",cProg+".html",DataValida(DATE()+1))
	u_MsgLog(cProg,cMens,"S")
EndIf

u_LogMemo(cProg+".SQL",cErro+cQry)

Return Nil

// Limpeza da tabela de avisos
User Function BKMsgLmp()
Local nCount := 0
Local cFile	 := ""
Local cProg  := "BKMSGLMP"
Local cMens  := ""
dbSelectArea("SZ0")
dbGoTop()
Do While !Eof()
	If SZ0->Z0_STATUS == "N" .AND. SZ0->Z0_DTFINAL < (DATE() - 3)
		cFile := u_STmpAnexos()+TRIM(SZ0->Z0_ANEXO)
		If File(cFile)
			fErase(cFile)
		EndIf
		RecLock("SZ0",.F.)
		SZ0->(dbDelete())
		SZ0->(MsUnlock())
		nCount++
	EndIf
	dbSkip()
EndDo
cMens := "Registros de avisos excluídos (SZ0): "+ALLTRIM(STR(nCount))
u_BKMsgUs(cEmpAnt,cProg,{},u_GrpAdmin(),cMens,cMens,"F","",DataValida(DATE()+1))

dbSelectArea("SZ0")
dbCloseArea()
USE ("SZ0010") ALIAS ("SZ0") EXCLUSIVE NEW VIA "TOPCONN"
If ! NetErr()
	//Aciona o Pack e Commit
	SZ0->(__DBPack())
	SZ0->(DbCommitAll())
	dbCloseArea()
EndIf
dbSelectArea("SZ0")
Return Nil



