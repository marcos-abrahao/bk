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

Static Function Scheddef()
Local aParam
Local aOrd     := {}

aParam := {	"P",;		//Tipo R para relatorio P para processo   
			"PARAMDEF",;// Pergunte do relatorio, caso nao use passar ParamDef            
			"CN9",;		// Alias            
			aOrd,;		//Array de ordens   
			"PowerBk"}

Return aParam



User Function BKDASH01()
Local aCampos := {{ "MARCA"    , "C", 02, 0, "Marca"    ,"@!", .F., "" },;
				  { "ROTINA"   , "C", 15, 0, "Rotina"   ,"@!", .T., "" },;
				  { "DESCRICAO", "C", 70, 0, "Descrição","@!", .T., "" } }

Local aDados  := {}
Local nX 	  := 0
Local aGrpDsp := u_BKGrpDsp()
Local bProg
Local cBlind1 := ""
Local cBlind2 := ""
Local lOk     := .F.

Private cTitulo     := "Dashboard PowerBk e Avisos"
Private cPerg       := "BKDASH01"

If FWCodEmp() == "01"

	aDados  := {}
	cBlind1 := ""
	cBlind2 := ""

	If IsBlind(); 
			.AND. SUBSTRING(TIME(),1,2) > '05' ;
			.AND. SUBSTRING(TIME(),1,2) < '22';
		 	.AND. DOW(DATE()) <> 7;
		 	.AND. DOW(DATE()) <> 1
		cBlind1 := "X"
	EndIf

	// 19h
	If cBlind1 == "X" .AND. SUBSTRING(TIME(),1,2) == '19'
		cBlind2 := "X"
	EndIf
	aAdd(aDados,{cBlind2,"U_BKGCTR26(.T.)","Tabelas de Fluxo de Caixa Por Contrato"})

	// 6h e 14h
	cBlind2 := ""
	If cBlind1 == "X" .AND. SUBSTRING(TIME(),1,2) $ '06/14'
		cBlind2 := "X"
	EndIf
	aAdd(aDados,{cBlind2,"U_BKDSDSP1()"  ,"Atualização da tabela PREVDESP1"})
	aAdd(aDados,{cBlind2,"U_BKDSDSP2()"  ,"Atualização da tabela PREVDESP2"})
	aAdd(aDados,{cBlind2,"U_BKDSEMP()"   ,"Atualização da tabela EMPRESAS"})
	aAdd(aDados,{cBlind2,"U_BKDSCC()"    ,"Atualização da tabela CCUSTOS"})
	aAdd(aDados,{cBlind2,"U_BKDSFOL()"   ,"Atualização da tabela FOLHA"})
	aAdd(aDados,{cBlind2,"U_BKDSFER()"   ,"Atualização da tabela FERIAS"})
	aAdd(aDados,{cBlind2,"U_BKDSUSR()"   ,"Atualização da tabela USUARIOS"})
	aAdd(aDados,{cBlind2,"U_BKDSTUR()"   ,"Atualização da tabela FOLHAFIL e FOLHATUR"})
	aAdd(aDados,{cBlind2,"U_BKDSBKTUR()" ,"Atualização da tabela FOLHAFILBK"})
	aAdd(aDados,{cBlind2,"U_BKDSBKFAL()" ,"Atualização da tabela FOLHAFAL"})
	aAdd(aDados,{cBlind2,"U_BK040PER()"  ,"Atualização da tabela BK040PER"})
	aAdd(aDados,{cBlind2,"U_BKDSSC()"    ,"Atualização da tabela SOLCOMPRAS"})
	aAdd(aDados,{cBlind2,"U_BKDSCFAT()"  ,"Atualização da tabela CANCFATURAMENTO"})

	// 7,11,14 e 17h
	cBlind2 := ""
	If cBlind1 == "X" .AND. SUBSTRING(TIME(),1,2) $ '07/11/14/17'
		cBlind2 := "X"
	EndIf

	aAdd(aDados,{cBlind2,"U_BKDSGES()"   ,"Atualização da tabela GESTORES"})
	aAdd(aDados,{cBlind2,"U_BKDSGLO()"   ,"Atualização da tabela GLOSAS"})
	aAdd(aDados,{cBlind2,"U_BKDSCTR()"   ,"Atualização da tabela CONTRATOS"})
	aAdd(aDados,{cBlind2,"U_BKDSPLA()"   ,"Atualização da tabela PLANILHAS"})
	aAdd(aDados,{cBlind2,"U_BKDSCRO()"   ,"Atualização da tabela CRONOGRAMAS"})
	aAdd(aDados,{cBlind2,"U_BKDSGG()"    ,"Atualização da tabela GASTOSGERAIS"})
	aAdd(aDados,{cBlind2,"U_BKDSGCO()"   ,"Atualização da tabela GASTOSCONSORCIOS"})

	aAdd(aDados,{cBlind1,"U_BKDSFAT()"   ,"Atualização da tabela FATURAMENTO"})
	aAdd(aDados,{cBlind1,"U_BKDSGER()"   ,"Atualização da tabela GERAL"})

	aAdd(aDados,{"","U_BKDSPRTUR()"      ,"Criação/atualização da Procedure BKTURNOVER"})
	aAdd(aDados,{"","U_BKPRBKTUR()"      ,"Criação/atualização da Procedure BKTURNOVER1"})
	aAdd(aDados,{"","U_BKDSPRFAL()"      ,"Criação/atualização da Procedure BKFALTAS"})
	//aAdd(aDados,{"","U_PRODESPC()"       ,"Atualização da Tabela PRODESPCARGA"})
	//aAdd(aDados,{"","U_PRODESPI()"       ,"Atualização da Tabela PRODESPINSERIR"})
	//aAdd(aDados,{"","U_PRODESPA()"       ,"Atualização da Tabela PRODESPATUALIZAR"})
	//aAdd(aDados,{"","U_PRODESPE()"       ,"Atualização da Tabela PRODESPEXCLUIR"})

	// Avisos
	aAdd(aDados,{cBlind2,"U_BKMSG001()"   ,"Aviso de documentos pendentes de aprovação"})

	// 11h
	cBlind2 := ""
	If cBlind1 == "X" .AND. SUBSTRING(TIME(),1,2) $ '11'
		cBlind2 := "X"
	EndIf	
	aAdd(aDados,{cBlind2,"U_BKMSG002()"   ,"Aviso de entidades com Conta Contábil Bloqueada"})
	aAdd(aDados,{cBlind2,"U_BKMSG003()"   ,"Aviso de Clientes sem virgula no endereço"})

	// 11h segunda-feira
	cBlind2 := ""
	If cBlind1 == "X" .AND. SUBSTRING(TIME(),1,2) $ '11' .AND. DOW(DATE()) == 2
		cBlind2 := "X"
	EndIf	
	aAdd(aDados,{cBlind2,"U_BKMSG004()"   ,"Aviso de Clientes sem Conta Bancária para Depósito"})
	
	aAdd(aDados,{cBlind1,"U_BKMSG005()"   ,"Aviso de Pedidos de Venda Liberados"})

	// 12h
	cBlind2 := ""
	If cBlind1 == "X" .AND. SUBSTRING(TIME(),1,2) $ '12'
		cBlind2 := "X"
	EndIf
	aAdd(aDados,{cBlind2,"U_BKMSG006()"   ,"Aviso de lançamentos de despesas"})


	// 21h
	cBlind2 := ""
	If cBlind1 == "X" .AND. SUBSTRING(TIME(),1,2) $ '21'
		cBlind2 := "X"
	EndIf
	aAdd(aDados,{cBlind2,"U_BKMSG007()"   ,"Aviso de lançamentos de despesas em contratos vencidos a mais de 60 dias"})


	If !IsBlind()
		u_TTMARKB(aCampos, aDados, .F.)
	EndIf

	For nX := 1 To Len(aDados) 
		If !Empty(aDados[nX,1])
			bProg := {|oSay| x:= &(aDados[nX,2]) }
			u_WaitLog(cPerg, bProg, aDados[nX,2]+": "+aDados[nX,3])
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
	cQry 	+= '/* <a href="javascript:history.back()">Voltar</a> */' + CRLF
	cQry	:= StrTran(cQry, CRLF, "<br>")

	u_GrvAnexo(cProg+".html",cQry,.F.)
	u_BKMsgUs(cEmpAnt,cProg,{},u_GrpAdmin(),cMens,cMens,"F",cProg+".html",DataValida(DATE()+1))
	u_MsgLog(cProg,cMens,"S")
EndIf

u_LogMemo(cProg+".SQL",cErro+cQry)

Return Nil
