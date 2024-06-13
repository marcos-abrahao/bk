#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKTODOS
BK - Tela para executar todos os relatorios e rotinas específicas da BK
@Return
@author Marcos Bispo Abrahão
@since 21/11/2023
@version P12
/*/


User Function BKTODOS()
Local aCampos := {{ "MARCA"    , "C", 02, 0, "Marca"    ,"@!", .F., "" },;
				  { "ROTINA"   , "C", 15, 0, "Rotina"   ,"@!", .T., "" },;
				  { "MODULO"   , "C", 10, 0, "Módulo"   ,"@!", .T., "" },;
				  { "DESCRICAO", "C", 70, 0, "Descrição","@!", .T., "" } }

Local aDados  := {}
Local nX 	  := 0
Local bProg

Private cPerg   := "BKTODOS"

If !u_IsMDir(__cUserID)
	u_MsgLog(cPerg,"Usuário sem permissão para executar esta rotina","E")
	Return Nil
EndIf

If __cUserId == '000000'
	aAdd(aDados,{"","u_ExBKCode()",	"TESTES",		"Teste da rotina de codificação web"})
	aAdd(aDados,{"","u_TabsBk()",	"GERAL",		"Criação de tabelas especificas - empresa nova"})
EndIf

aAdd(aDados,{"","U_BKBATIDAS()",	"GERAL",		"Envio de e-mails via CSV"})
aAdd(aDados,{"","U_LISTUSR()",		"GERAL",		"Relação de usuários com E-Mail"})
aAdd(aDados,{"","U_LISTSUP()",		"GERAL",		"Relação de usuários e superiores"})
aAdd(aDados,{"","U_LISTRH()",		"GERAL",		"Relação de Tipos do RH"})
aAdd(aDados,{"","U_TESTEPOUI()",	"GERAL",		"Teste desenvolvimento PO-UI"})

aAdd(aDados,{"","U_BKMSG001()",		"AVISOS",		"Aviso de Documentos pendentes de aprovação"})
aAdd(aDados,{"","U_BKMSG002()",     "AVISOS",		"Aviso de entidades com Conta Contábil Bloqueada"})
aAdd(aDados,{"","U_BKMSG003()",     "AVISOS",		"Aviso de Clientes sem virgula no endereço"})
aAdd(aDados,{"","U_BKMSG004()",		"AVISOS",		"Aviso de Clientes sem Conta Bancária para Depósito"})
aAdd(aDados,{"","U_BKMSG005()",		"AVISOS",		"Aviso de Pedidos de Venda Liberados"})
aAdd(aDados,{"","U_BKMSG006()",		"AVISOS",		"Aviso de Aviso de lançamentos de despesas"})
aAdd(aDados,{"","U_BKMSG007()",		"AVISOS",		"Aviso de lançamentos de despesas em contratos vencidos a mais de 60 dias"})

aAdd(aDados,{"","U_BKGCT06()",		"GESTÃO",		"Avisos automaticos de Repactuação de contratos e Compras"})
aAdd(aDados,{"","U_BKGCTA01()",		"GESTÃO",		"Cadastro Codigos de Glosa Bonificação - BK"})
aAdd(aDados,{"","U_BKGCTR01()",		"GESTÃO",		"Mapa de Mediçoes"})
aAdd(aDados,{"","U_BKGCTR1A()",		"GESTÃO",		"Mapa de Mediçoes - Com motivos e multa e bonificação"})
aAdd(aDados,{"","U_BKGCTR02()",		"GESTÃO",		"Previsto x Faturado - Todas empresas do Grupo BK"})
aAdd(aDados,{"","U_BKGCTR2B()",		"GESTÃO",		"Gestão do Recebimento - empresas: 01,02,14 e 18"})
aAdd(aDados,{"","U_BKGCTR07()",		"GESTÃO",		"Mapa de Faturamento"})
aAdd(aDados,{"","U_BKGCTR08()",		"GESTÃO",		"Mapa de Multas e Bonificações"})
aAdd(aDados,{"","U_BKGCTR09()",		"GESTÃO",		"Projeção Financeira dos Contratos"})
aAdd(aDados,{"","U_BKGCTR10()",		"GESTÃO",		"Histórico de Multa e Bonificações"})
aAdd(aDados,{"","U_BKGCTR11()",		"GESTÃO",		"Rentabilidade dos Contratos"})
aAdd(aDados,{"","U_BK2GCTR11()",	"GESTÃO",		"Rentabilidade dos Contratos - Consorcios"})
aAdd(aDados,{"","U_BKGCTR14()",		"GESTÃO",		"Rentabilidade dos Contratos - Projeção X Realizado"})
aAdd(aDados,{"","U_BKGCTR_14()",	"GESTÃO",		"Rentabilidade dos Contratos - Projeção X Realizado - Sintético"})
aAdd(aDados,{"","U_BKGCTR15()",		"GESTÃO",		"Informações de Contratos para Licitação"})
aAdd(aDados,{"","U_BKGCTR16()",		"GESTÃO",		"Relação de Contratos Vigentes no mes"})
aAdd(aDados,{"","U_BKGCTR17()",		"GESTÃO",		"Situação dos Contratos"})
aAdd(aDados,{"","U_BKGCTR18()",		"GESTÃO",		"Informações de Contratos Vigentes e encerrados por ano - Licitação Mod. 2"})
aAdd(aDados,{"","U_BKGCTR21()",		"GESTÃO",		"Relatório faturamento de reajustes, repactuação e retroativo"})
aAdd(aDados,{"","U_BKGCTR23()",		"GESTÃO",		"Relatório Dados do Dashboard (antigo) Funcionários e Glosas"})
aAdd(aDados,{"","U_BKGCTR24()",		"GESTÃO",		"Consulta Planos de Ação (obsoleto)"})
aAdd(aDados,{"","U_BKGCTR25()",		"GESTÃO",		"Relação de Contratos"})
aAdd(aDados,{"","U_BKGCTR26()",		"GESTÃO",		"Fluxo de Caixa Por Contrato"})
aAdd(aDados,{"","U_BKGCTR27()",		"GESTÃO",		"Planilhas de Contratos"})
aAdd(aDados,{"","U_BKGCTR28()",		"GESTÃO",		"Pagamentos x Responsáveis"})
aAdd(aDados,{"","U_BKGCTV22()",		"GESTÃO",		"Visualização de Ocorrências e Planos de ação - Contratos (obsoleto)"})
aAdd(aDados,{"","U_XCADSE1()",		"GESTÃO",		"Notas de Debito - Contratos"})
aAdd(aDados,{"","U_XCADSZM()",		"GESTÃO",		"Cadastro Reajuste Projecao Financeira"})
aAdd(aDados,{"","U_MVCSZE()",		"GESTÃO",		"Cadastro de Anexos de Contratos por Competência"})

aAdd(aDados,{"","U_BKCOMR04()",		"COMPRAS",		"Movimento Compras"})
aAdd(aDados,{"","U_BKCOMR6()",		"COMPRAS",		"Relatório Pedidos de Compra"})
aAdd(aDados,{"","U_BKCOMR08()",		"COMPRAS",		"Tomada de Preços Compras"})
aAdd(aDados,{"","U_BKCOMR09()",		"COMPRAS",		"Relatório Gerencial de Compras"})
aAdd(aDados,{"","U_BKCOMA09()",		"COMPRAS",		"Facilitador Doc Entrada (PJs)"})
aAdd(aDados,{"","U_BKCOMA12()",		"COMPRAS",		"Importar planilha excel em CSV para inclusão de produtos"})
aAdd(aDados,{"","U_BKCOMA13()",		"COMPRAS",		"Inclusão de Doc de Impostos com Rateio por CC"})
aAdd(aDados,{"","U_BKCOMA14()",		"COMPRAS",		"Rateio de impostos em titulos de impostos já existentes"})
aAdd(aDados,{"","U_BKCOMA15()",		"COMPRAS",		"Inclusão de Doc de Sindicatos com Rateio por CC"})
aAdd(aDados,{"","U_BKCOMC01()",		"COMPRAS",		"Pesquisa itens de Documentos de entrada"})
aAdd(aDados,{"","U_BKCOMR15()",		"COMPRAS",		"Relação de Fornecedores - (se já foi avaliado ou não)"})
aAdd(aDados,{"","U_BKCOMR19()",		"COMPRAS",		"Relação de Prod. Grupos Subgrp Valor"})

aAdd(aDados,{"","U_BKFATA1A()",		"FATURAMENTO",	"Funcao gravar Informações do Faturamento na NF de saida"})

aAdd(aDados,{"","U_BKFINR10()",		"FINANCEIRO",	"Fluxo de Caixa - Realizado"})
aAdd(aDados,{"","U_BKFINR11()",		"FINANCEIRO",	"Fluxo de Caixa - Orçado"})
aAdd(aDados,{"","U_BKFINR15()",		"FINANCEIRO",	"Saldos Bco Empresas"})
aAdd(aDados,{"","U_BKFINR17()",		"FINANCEIRO",	"Contas Recebidas"})
aAdd(aDados,{"","U_BKFINR18()",		"FINANCEIRO",	"Relatório de Notas Fiscais Canceladas"})
aAdd(aDados,{"","U_BKFINR19()",		"FINANCEIRO",	"Relatório de Notas Fiscais por contrato"})
aAdd(aDados,{"","U_BKFINR20()",		"FINANCEIRO",	"Mapa INSS retido Financeiro"})
aAdd(aDados,{"","U_BKFINR21()",		"FINANCEIRO",	"Bloqueio ou Desbloqueio judicial"})

aAdd(aDados,{"","U_BKFINR23()",		"FINANCEIRO",	"Saldos bancários consolidados"})
aAdd(aDados,{"","U_BKFINR24()",		"FINANCEIRO",	"Consulta Planos de Ação"})
aAdd(aDados,{"","U_BKFINR34()",		"FINANCEIRO",	"Resumo Diário Contas a Pagar"})
aAdd(aDados,{"","U_BKFINR37()",		"FINANCEIRO",	"Indicador Pagamentos Antecipados"})
aAdd(aDados,{"","U_BKFINA05()",		"FINANCEIRO",	"Títulos a Pagar WEB"})
aAdd(aDados,{"","U_FINR_470()",		"FINANCEIRO",	"Extrato Bancário BK - com CC"})  

aAdd(aDados,{"","U_BKDSDSP1()",		"DASHBOARD",	"Atualização da tabela PREVDESP1"})
aAdd(aDados,{"","U_BKDSDSP2()",		"DASHBOARD",	"Atualização da tabela PREVDESP2"})
aAdd(aDados,{"","U_BKDSEMP()",		"DASHBOARD",	"Atualização da tabela EMPRESAS"})
aAdd(aDados,{"","U_BKDSCC()",		"DASHBOARD",	"Atualização da tabela CCUSTOS"})
aAdd(aDados,{"","U_BKDSFOL()",		"DASHBOARD",	"Atualização da tabela FOLHA"})
aAdd(aDados,{"","U_BKDSFER()",		"DASHBOARD",	"Atualização da tabela FERIAS"})
aAdd(aDados,{"","U_BKDSUSR()",		"DASHBOARD",	"Atualização da tabela USUARIOS"})
aAdd(aDados,{"","U_BKDSTUR()",		"DASHBOARD",	"Atualização da tabela FOLHAFIL e FOLHATUR"})
aAdd(aDados,{"","U_BKDSBKTUR()",	"DASHBOARD",	"Atualização da tabela FOLHAFILBK"})
aAdd(aDados,{"","U_BKDSBKFAL()",	"DASHBOARD",	"Atualização da tabela FOLHAFAL"})
aAdd(aDados,{"","U_BK040PER()",		"DASHBOARD",	"Atualização da tabela BK040PER"})
aAdd(aDados,{"","U_BKDSSC()",		"DASHBOARD",	"Atualização da tabela SOLCOMPRAS"})
aAdd(aDados,{"","U_BKDSCFAT()",		"DASHBOARD",	"Atualização da tabela CANCFATURAMENTO"})
aAdd(aDados,{"","U_BKDSGES()",		"DASHBOARD",	"Atualização da tabela GESTORES"})
aAdd(aDados,{"","U_BKDSGLO()",		"DASHBOARD",	"Atualização da tabela GLOSAS"})
aAdd(aDados,{"","U_BKDSCTR()",		"DASHBOARD",	"Atualização da tabela CONTRATOS"})
aAdd(aDados,{"","U_BKDSPLA()",		"DASHBOARD",	"Atualização da tabela PLANILHAS"})
aAdd(aDados,{"","U_BKDSCRO()",		"DASHBOARD",	"Atualização da tabela CRONOGRAMAS"})
aAdd(aDados,{"","U_BKDSGG()",		"DASHBOARD",	"Atualização da tabela GASTOSGERAIS"})
aAdd(aDados,{"","U_BKDSGCO()",      "DASHBOARD",    "Atualização da tabela GASTOSCONSORCIOS"})
aAdd(aDados,{"","U_BKDSFAT()",		"DASHBOARD",	"Atualização da tabela FATURAMENTO"})
aAdd(aDados,{"","U_BKDSGER()",		"DASHBOARD",	"Atualização da tabela GERAL"})

aAdd(aDados,{"","U_BKDSPRTUR()",	"DASHBOARD",	"Criação/atualização da Procedure BKTURNOVER"})
aAdd(aDados,{"","U_BKPRBKTUR()",	"DASHBOARD",	"Criação/atualização da Procedure BKTURNOVER1"})
aAdd(aDados,{"","U_BKDSPRFAL()",	"DASHBOARD",	"Criação/atualização da Procedure BKFALTAS"})

u_TTMARKB(aCampos, aDados, .F.)

For nX := 1 To Len(aDados) 
	If !Empty(aDados[nX,1])
		bProg := {|oSay| x:= &(aDados[nX,2]) }
		u_WaitLog(cPerg, bProg, aDados[nX,2]+": "+aDados[nX,3])
	EndIf
Next nX

Return

// Criar Tabelas
User Function TabsBk()

dbSelectArea("CD2")
dbSelectArea("CN9")
dbSelectArea("CNA")
dbSelectArea("CNB")
dbSelectArea("CND")
dbSelectArea("CNR")
dbSelectArea("CXN")
dbSelectArea("CNE")
dbSelectArea("CNF")
dbSelectArea("CT1")
dbSelectArea("CTT")
dbSelectArea("SA1")
dbSelectArea("SA2")
dbSelectArea("SB1")
dbSelectArea("SB5")
dbSelectArea("SC1")
dbSelectArea("SC5")
dbSelectArea("SC6")
dbSelectArea("SC7")
dbSelectArea("SC8")
dbSelectArea("SCR")
dbSelectArea("SD1")
dbSelectArea("SD2")
dbSelectArea("SE1")
dbSelectArea("SE2")
dbSelectArea("SE5")
dbSelectArea("SF1")
dbSelectArea("SF2")
dbSelectArea("SF3")
dbSelectArea("SF4")
dbSelectArea("SFT")
dbSelectArea("SZ4")
dbSelectArea("SZ5")
dbSelectArea("SZ7")
dbSelectArea("SZA")
dbSelectArea("SZB")
dbSelectArea("SZC")
dbSelectArea("SZD")
dbSelectArea("SZE")
dbSelectArea("SZG")
dbSelectArea("SZH")
dbSelectArea("SZK")
dbSelectArea("SZL")
dbSelectArea("SZM")
dbSelectArea("SZU")
dbSelectArea("SZT")
dbSelectArea("SYP")

Return Nil
