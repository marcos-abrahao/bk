#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKTODOS
BK - Tela para executar todos os relatorios e rotinas espec�ficas da BK
@Return
@author Marcos Bispo Abrah�o
@since 21/11/2023
@version P12
/*/


User Function BKTODOS()
Local aCampos := {{ "MARCA"    , "C", 02, 0, "Marca"    ,"@!", .F., "" },;
				  { "ROTINA"   , "C", 15, 0, "Rotina"   ,"@!", .T., "" },;
				  { "MODULO"   , "C", 10, 0, "M�dulo"   ,"@!", .T., "" },;
				  { "DESCRICAO", "C", 70, 0, "Descri��o","@!", .T., "" } }

Local aDados  := {}
Local nX 	  := 0
Local bProg

Private cPerg   := "BKTODOS"

If !u_IsMDir(__cUserID)
	u_MsgLog(cPerg,"Usu�rio sem permiss�o para executar esta rotina","E")
	Return Nil
EndIf

If __cUserId == '000000'
	aAdd(aDados,{"","U_BKGCTR22()",		"GEST�O",		"Nova Rentabilidade dos Contratos"})
	aAdd(aDados,{"","u_ExBKCode()",	"TESTES",		"Teste da rotina de codifica��o web"})
	aAdd(aDados,{"","u_TabsBk()",	"GERAL",		"Cria��o de tabelas especificas - empresa nova"})
	aAdd(aDados,{"","u_BKDANFE()",	"GERAL",		"Teste de Danfe"})
EndIf

aAdd(aDados,{"","U_BKBATIDAS()",	"GERAL",		"Envio de e-mails via CSV"})
aAdd(aDados,{"","U_LISTUSR()",		"GERAL",		"Rela��o de usu�rios com E-Mail"})
aAdd(aDados,{"","U_LISTSUP()",		"GERAL",		"Rela��o de usu�rios e superiores"})
aAdd(aDados,{"","U_LISTRH()",		"GERAL",		"Rela��o de Tipos do RH"})
aAdd(aDados,{"","U_TESTEPOUI()",	"GERAL",		"Teste desenvolvimento PO-UI"})

aAdd(aDados,{"","U_BKMSG001()",		"AVISOS",		"Aviso de Documentos pendentes de aprova��o"})
aAdd(aDados,{"","U_BKMSG002()",     "AVISOS",		"Aviso de entidades com Conta Cont�bil Bloqueada"})
aAdd(aDados,{"","U_BKMSG003()",     "AVISOS",		"Aviso de Clientes sem virgula no endere�o"})
aAdd(aDados,{"","U_BKMSG004()",		"AVISOS",		"Aviso de Clientes sem Conta Banc�ria para Dep�sito"})
aAdd(aDados,{"","U_BKMSG005()",		"AVISOS",		"Aviso de Pedidos de Venda Liberados"})
aAdd(aDados,{"","U_BKMSG006()",		"AVISOS",		"Aviso de de lan�amentos de despesas"})
aAdd(aDados,{"","U_BKMSG007()",		"AVISOS",		"Aviso de lan�amentos de despesas em contratos vencidos a mais de 60 dias"})
aAdd(aDados,{"","U_BKMSG008()",		"AVISOS",		"Aviso de Pedidos de compras n�o entregues"})
aAdd(aDados,{"","U_BKMSG009()",		"AVISOS",		"Aviso de Solicita��es de compras em aberto"})

aAdd(aDados,{"","U_BKGCT06()",		"GEST�O",		"Avisos automaticos de Repactua��o de contratos e Compras"})
aAdd(aDados,{"","U_BKGCTA01()",		"GEST�O",		"Cadastro Codigos de Glosa Bonifica��o - BK"})
aAdd(aDados,{"","U_BKGCTR01()",		"GEST�O",		"Mapa de Medi�oes"})
aAdd(aDados,{"","U_BKGCTR1A()",		"GEST�O",		"Mapa de Medi�oes - Com motivos e multa e bonifica��o"})
aAdd(aDados,{"","U_BKGCTR02()",		"GEST�O",		"Previsto x Faturado - Todas empresas do Grupo BK"})
aAdd(aDados,{"","U_BKGCTR2B()",		"GEST�O",		"Gest�o do Recebimento - empresas: 01,02,14 e 18"})
aAdd(aDados,{"","U_BKGCTR07()",		"GEST�O",		"Mapa de Faturamento"})
aAdd(aDados,{"","U_BKGCTR08()",		"GEST�O",		"Mapa de Multas e Bonifica��es"})
aAdd(aDados,{"","U_BKGCTR09()",		"GEST�O",		"Proje��o Financeira dos Contratos"})
aAdd(aDados,{"","U_BKGCTR10()",		"GEST�O",		"Hist�rico de Multa e Bonifica��es"})
aAdd(aDados,{"","U_BKGCTR11()",		"GEST�O",		"Rentabilidade dos Contratos"})
aAdd(aDados,{"","U_BK2GCTR11()",	"GEST�O",		"Rentabilidade dos Contratos - Consorcios"})
aAdd(aDados,{"","U_BKGCTR14()",		"GEST�O",		"Rentabilidade dos Contratos - Proje��o X Realizado"})
aAdd(aDados,{"","U_BKGCTR_14()",	"GEST�O",		"Rentabilidade dos Contratos - Proje��o X Realizado - Sint�tico"})
aAdd(aDados,{"","U_BKGCTR15()",		"GEST�O",		"Informa��es de Contratos para Licita��o"})
aAdd(aDados,{"","U_BKGCTR16()",		"GEST�O",		"Rela��o de Contratos Vigentes no mes"})
aAdd(aDados,{"","U_BKGCTR17()",		"GEST�O",		"Situa��o dos Contratos"})
aAdd(aDados,{"","U_BKGCTR18()",		"GEST�O",		"Informa��es de Contratos Vigentes e encerrados por ano - Licita��o Mod. 2"})
aAdd(aDados,{"","U_BKGCTR21()",		"GEST�O",		"Relat�rio faturamento de reajustes, repactua��o e retroativo"})
aAdd(aDados,{"","U_BKGCTR23()",		"GEST�O",		"Relat�rio Dados do Dashboard (antigo) Funcion�rios e Glosas"})
aAdd(aDados,{"","U_BKGCTR24()",		"GEST�O",		"Consulta Planos de A��o (obsoleto)"})
aAdd(aDados,{"","U_BKGCTR25()",		"GEST�O",		"Rela��o de Contratos"})
aAdd(aDados,{"","U_BKGCTR26()",		"GEST�O",		"Fluxo de Caixa Por Contrato"})
aAdd(aDados,{"","U_BKGCTR27()",		"GEST�O",		"Planilhas de Contratos"})
aAdd(aDados,{"","U_BKGCTR28()",		"GEST�O",		"Pagamentos x Respons�veis"})
aAdd(aDados,{"","U_BKGCTV22()",		"GEST�O",		"Visualiza��o de Ocorr�ncias e Planos de a��o - Contratos (obsoleto)"})
aAdd(aDados,{"","U_XCADSE1()",		"GEST�O",		"Notas de Debito - Contratos"})
aAdd(aDados,{"","U_XCADSZM()",		"GEST�O",		"Cadastro Reajuste Projecao Financeira"})
aAdd(aDados,{"","U_MVCSZE()",		"GEST�O",		"Cadastro de Anexos de Contratos por Compet�ncia"})

aAdd(aDados,{"","U_BKCOMR04()",		"COMPRAS",		"Movimento Compras"})
aAdd(aDados,{"","U_BKCOMR6()",		"COMPRAS",		"Relat�rio Pedidos de Compra"})
aAdd(aDados,{"","U_BKCOMR08()",		"COMPRAS",		"Tomada de Pre�os Compras"})
aAdd(aDados,{"","U_BKCOMR09()",		"COMPRAS",		"Relat�rio Gerencial de Compras"})
aAdd(aDados,{"","U_BKCOMA09()",		"COMPRAS",		"Facilitador Doc Entrada (PJs)"})
aAdd(aDados,{"","U_BKCOMA12()",		"COMPRAS",		"Importar planilha excel em CSV para inclus�o de produtos"})
aAdd(aDados,{"","U_BKCOMA13()",		"COMPRAS",		"Inclus�o de Doc de Impostos com Rateio por CC"})
aAdd(aDados,{"","U_BKCOMA14()",		"COMPRAS",		"Rateio de impostos em titulos de impostos j� existentes"})
aAdd(aDados,{"","U_BKCOMA15()",		"COMPRAS",		"Inclus�o de Doc de Sindicatos com Rateio por CC"})
aAdd(aDados,{"","U_BKCOMC01()",		"COMPRAS",		"Pesquisa itens de Documentos de entrada"})
aAdd(aDados,{"","U_BKCOMR15()",		"COMPRAS",		"Rela��o de Fornecedores - (se j� foi avaliado ou n�o)"})
aAdd(aDados,{"","U_BKCOMR19()",		"COMPRAS",		"Rela��o de Prod. Grupos Subgrp Valor"})

aAdd(aDados,{"","U_BKFATA1A()",		"FATURAMENTO",	"Funcao gravar Informa��es do Faturamento na NF de saida"})

aAdd(aDados,{"","U_BKFINR10()",		"FINANCEIRO",	"Fluxo de Caixa - Realizado"})
aAdd(aDados,{"","U_BKFINR11()",		"FINANCEIRO",	"Fluxo de Caixa - Or�ado"})
aAdd(aDados,{"","U_BKFINR15()",		"FINANCEIRO",	"Saldos Bco Empresas"})
aAdd(aDados,{"","U_BKFINR17()",		"FINANCEIRO",	"Contas Recebidas"})
aAdd(aDados,{"","U_BKFINR18()",		"FINANCEIRO",	"Relat�rio de Notas Fiscais Canceladas"})
aAdd(aDados,{"","U_BKFINR19()",		"FINANCEIRO",	"Relat�rio de Notas Fiscais por contrato"})
aAdd(aDados,{"","U_BKFINR20()",		"FINANCEIRO",	"Mapa INSS retido Financeiro"})
aAdd(aDados,{"","U_BKFINR21()",		"FINANCEIRO",	"Bloqueio ou Desbloqueio judicial"})

aAdd(aDados,{"","U_BKFINR23()",		"FINANCEIRO",	"Saldos banc�rios consolidados"})
aAdd(aDados,{"","U_BKFINR24()",		"FINANCEIRO",	"Consulta Planos de A��o"})
aAdd(aDados,{"","U_BKFINR32()",		"FINANCEIRO",	"Fornecedores Ativos e ultima compra"})
aAdd(aDados,{"","U_BKFINR34()",		"FINANCEIRO",	"Resumo Di�rio Contas a Pagar"})
aAdd(aDados,{"","U_BKFINR37()",		"FINANCEIRO",	"Indicador Pagamentos Antecipados"})
aAdd(aDados,{"","U_BKTITCP(.T.,)",	"FINANCEIRO",	"T�tulos a Pagar WEB"})
aAdd(aDados,{"","U_FINR_470()",		"FINANCEIRO",	"Extrato Banc�rio BK - com CC"})  

aAdd(aDados,{"","U_BKDSDSP1()",		"DASHBOARD",	"Atualiza��o da tabela PREVDESP1"})
aAdd(aDados,{"","U_BKDSDSP2()",		"DASHBOARD",	"Atualiza��o da tabela PREVDESP2"})
aAdd(aDados,{"","U_BKDSEMP()",		"DASHBOARD",	"Atualiza��o da tabela EMPRESAS"})
aAdd(aDados,{"","U_BKDSCC()",		"DASHBOARD",	"Atualiza��o da tabela CCUSTOS"})
aAdd(aDados,{"","U_BKDSFOL()",		"DASHBOARD",	"Atualiza��o da tabela FOLHA"})
aAdd(aDados,{"","U_BKDSFER()",		"DASHBOARD",	"Atualiza��o da tabela FERIAS"})
aAdd(aDados,{"","U_BKDSUSR()",		"DASHBOARD",	"Atualiza��o da tabela USUARIOS"})
aAdd(aDados,{"","U_BKDSTUR()",		"DASHBOARD",	"Atualiza��o da tabela FOLHAFIL e FOLHATUR"})
aAdd(aDados,{"","U_BKDSBKTUR()",	"DASHBOARD",	"Atualiza��o da tabela FOLHAFILBK"})
aAdd(aDados,{"","U_BKDSBKFAL()",	"DASHBOARD",	"Atualiza��o da tabela FOLHAFAL"})
aAdd(aDados,{"","U_BK040PER()",		"DASHBOARD",	"Atualiza��o da tabela BK040PER"})
aAdd(aDados,{"","U_BKDSSC()",		"DASHBOARD",	"Atualiza��o da tabela SOLCOMPRAS"})
aAdd(aDados,{"","U_BKDSCFAT()",		"DASHBOARD",	"Atualiza��o da tabela CANCFATURAMENTO"})
aAdd(aDados,{"","U_BKDSGES()",		"DASHBOARD",	"Atualiza��o da tabela GESTORES"})
aAdd(aDados,{"","U_BKDSGLO()",		"DASHBOARD",	"Atualiza��o da tabela GLOSAS"})
aAdd(aDados,{"","U_BKDSCTR()",		"DASHBOARD",	"Atualiza��o da tabela CONTRATOS"})
aAdd(aDados,{"","U_BKDSPLA()",		"DASHBOARD",	"Atualiza��o da tabela PLANILHAS"})
aAdd(aDados,{"","U_BKDSCRO()",		"DASHBOARD",	"Atualiza��o da tabela CRONOGRAMAS"})
aAdd(aDados,{"","U_BKDSGG()",		"DASHBOARD",	"Atualiza��o da tabela GASTOSGERAIS"})
aAdd(aDados,{"","U_BKDSGCO()",      "DASHBOARD",    "Atualiza��o da tabela GASTOSCONSORCIOS"})
aAdd(aDados,{"","U_BKDSFAT()",		"DASHBOARD",	"Atualiza��o da tabela FATURAMENTO"})
aAdd(aDados,{"","U_BKDSGER()",		"DASHBOARD",	"Atualiza��o da tabela GERAL"})

aAdd(aDados,{"","U_BKDSPRTUR()",	"DASHBOARD",	"Cria��o/atualiza��o da Procedure BKTURNOVER"})
aAdd(aDados,{"","U_BKPRBKTUR()",	"DASHBOARD",	"Cria��o/atualiza��o da Procedure BKTURNOVER1"})
aAdd(aDados,{"","U_BKDSPRFAL()",	"DASHBOARD",	"Cria��o/atualiza��o da Procedure BKFALTAS"})

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
dbSelectArea("SZ0")
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
