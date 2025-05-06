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
	//aAdd(aDados,{"","U_BKStamp()",	"GERAL",		"Criar campo S_T_A_M_P_"})
	aAdd(aDados,{"","U_zVid0020()",	"TESTE",		"Teste Tela FwLayer"})
    aAdd(aDados,{"","U_BKMsgLmp()",	"AVISOS",		"Limpeza de registros da tabela SZ0"})
	aAdd(aDados,{"","u_ExBKCode()",	"TESTES",		"Teste da rotina de codificação web"})
	aAdd(aDados,{"","u_TabsBk()",	"GERAL",		"Criação de tabelas especificas - empresa nova"})
	aAdd(aDados,{"","u_BKDANFE()",	"GERAL",		"Teste de Danfe"})
	aAdd(aDados,{"","u_SelEndEnt()","GERAL",		"Teste Seleção End Entrega"})
	aAdd(aDados,{"","U_BKESTA05()",	"ESTOQUE",		"Importar saldo inicial"})
	aAdd(aDados,{"","U_BKESTA06()",	"ESTOQUE",		"Importar saldo por endereçamento"})
	aAdd(aDados,{"","U_BKESTA07()",	"ESTOQUE",		"Importar movimentos de estoque"})
	aAdd(aDados,{"","U_BKESTA08()",	"ESTOQUE",		"Importar cadastro de endereçamento de estoque"})
	aAdd(aDados,{"","U_BKESTA09()",	"ESTOQUE",		"Importar Inventário (SB7)"})
	//aAdd(aDados,{"","U_BKCOMA12()",	"COMPRAS",		"Importar planilha excel em CSV para inclusão de produtos"})
	//aAdd(aDados,{"","U_BKCOMI12()",	"COMPRAS",		"Importar inventario Barcas do PowerBK"})
	//aAdd(aDados,{"","U_BKCOMA06()",	"COMPRAS",		"Importar fornecedores Barcas do PowerBK"})
    aAdd(aDados,{"","U_BKBATIDAS()",	"GERAL",		"Envio de e-mails via CSV"})
    aAdd(aDados,{"","U_TESTEPOUI()",	"GERAL",		"Teste desenvolvimento PO-UI"})

EndIf

aAdd(aDados,{"","U_BKGCTR29()",		"GESTÃO",		"Despesas por Contrato"})
aAdd(aDados,{"","U_LISTUSR()",		"GERAL",		"Relação de usuários com E-Mail"})
aAdd(aDados,{"","U_LISTSUP()",		"GERAL",		"Relação de usuários e superiores"})
aAdd(aDados,{"","U_LISTRH()",		"GERAL",		"Relação de Tipos do RH"})

aAdd(aDados,{"","U_BKMSG001()",		"AVISOS",		"Aviso de Documentos pendentes de aprovação"})
aAdd(aDados,{"","U_BKMSG002()",     "AVISOS",		"Aviso de entidades com Conta Contábil Bloqueada"})
aAdd(aDados,{"","U_BKMSG003()",     "AVISOS",		"Aviso de Clientes sem virgula no endereço"})
aAdd(aDados,{"","U_BKMSG004()",		"AVISOS",		"Aviso de Clientes sem Conta Bancária para Depósito"})
aAdd(aDados,{"","U_BKMSG005()",		"AVISOS",		"Aviso de Pedidos de Venda Liberados"})
aAdd(aDados,{"","U_BKMSG006()",		"AVISOS",		"Aviso de de lançamentos de despesas"})
aAdd(aDados,{"","U_BKMSG007()",		"AVISOS",		"Aviso de lançamentos de despesas em contratos vencidos a mais de 60 dias"})
aAdd(aDados,{"","U_BKMSG008()",		"AVISOS",		"Aviso de Pedidos de compras não entregues"})
aAdd(aDados,{"","U_BKMSG009()",		"AVISOS",		"Aviso de Solicitações de compras em aberto"})
aAdd(aDados,{"","U_BKMSG010()",	    "AVISOS",		"Aviso de Novos eventos ADP cadastrados"})

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
aAdd(aDados,{"","U_BKGCTR22()",		"GESTÃO",		"Nova Rentabilidade dos Contratos"})
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
aAdd(aDados,{"","U_BKCOMR04()",		"COMPRAS",		"Movimento Compras"})
aAdd(aDados,{"","U_BKCOMR6()",		"COMPRAS",		"Relatório Pedidos de Compra"})
aAdd(aDados,{"","U_BKCOMR08()",		"COMPRAS",		"Tomada de Preços Compras"})
aAdd(aDados,{"","U_BKCOMR09()",		"COMPRAS",		"Relatório Gerencial de Compras"})
aAdd(aDados,{"","U_BKCOMA09()",		"COMPRAS",		"Facilitador Doc Entrada (PJs)"})
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
aAdd(aDados,{"","U_BKFINR32()",		"FINANCEIRO",	"Fornecedores Ativos e ultima compra"})
aAdd(aDados,{"","U_BKFINR34()",		"FINANCEIRO",	"Resumo Diário Contas a Pagar"})
aAdd(aDados,{"","U_BKFINR37()",		"FINANCEIRO",	"Indicador Pagamentos Antecipados"})
aAdd(aDados,{"","U_BKTITCP(.T.,)",	"FINANCEIRO",	"Títulos a Pagar WEB"})
aAdd(aDados,{"","U_FINR_470()",		"FINANCEIRO",	"Extrato Bancário BK - com CC"})  

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

dbSelectArea("SIG")
dbGoTop()
dbSelectArea("CD5")
dbGoTop()

dbGoTop()
dbSelectArea("CD2")
dbGoTop()
dbSelectArea("CN9")
dbGoTop()
dbSelectArea("CNA")
dbGoTop()
dbSelectArea("CNB")
dbGoTop()
dbSelectArea("CND")
dbGoTop()
dbSelectArea("CNR")
dbGoTop()
dbSelectArea("CXN")
dbGoTop()
dbSelectArea("CNE")
dbGoTop()
dbSelectArea("CNF")
dbGoTop()
dbSelectArea("CT1")
dbGoTop()
dbSelectArea("CT2")
dbGoTop()
dbSelectArea("CTT")
dbGoTop()
dbSelectArea("SA1")
dbGoTop()
dbSelectArea("SA2")
dbGoTop()
dbSelectArea("SB1")
dbGoTop()
dbSelectArea("SB5")
dbGoTop()
dbSelectArea("SC1")
dbGoTop()
dbSelectArea("SC5")
dbGoTop()
dbSelectArea("SC6")
dbGoTop()
dbSelectArea("SC7")
dbGoTop()
dbSelectArea("SC8")
dbGoTop()
dbSelectArea("SCR")
dbGoTop()
dbSelectArea("SD1")
dbGoTop()
dbSelectArea("SD2")
dbGoTop()
dbSelectArea("SE1")
dbGoTop()
dbSelectArea("SE2")
dbGoTop()
dbSelectArea("SE5")
dbGoTop()
dbSelectArea("SED")
dbGoTop()
dbSelectArea("SF1")
dbGoTop()
dbSelectArea("SF2")
dbGoTop()
dbSelectArea("SF3")
dbGoTop()
dbSelectArea("SF4")
dbGoTop()
dbSelectArea("SFT")
dbGoTop()
dbSelectArea("SZ0")
dbGoTop()
dbSelectArea("SZ4")
dbGoTop()
dbSelectArea("SZ5")
dbGoTop()
dbSelectArea("SZ7")
dbGoTop()
dbSelectArea("SZA")
dbGoTop()
dbSelectArea("SZB")
dbGoTop()
dbSelectArea("SZC")
dbGoTop()
dbSelectArea("SZD")
dbGoTop()
dbSelectArea("SZE")
dbGoTop()
dbSelectArea("SZG")
dbGoTop()
dbSelectArea("SZH")
dbGoTop()
dbSelectArea("SZK")
dbGoTop()
dbSelectArea("SZL")
dbGoTop()
dbSelectArea("SZM")
dbGoTop()
dbSelectArea("SZU")
dbGoTop()
dbSelectArea("SZT")
dbGoTop()
dbSelectArea("SZY")
dbGoTop()
dbSelectArea("SYP")
dbGoTop()

// Compras
dbSelectArea("NNR")
dbGoTop()
dbSelectArea("SAJ")
dbGoTop()
dbSelectArea("SAK")
dbGoTop()
dbSelectArea("SAL")
dbGoTop()
dbSelectArea("SY1")
dbGoTop()
dbSelectArea("DHL")
dbGoTop()

Return Nil



User Function BKStamp()

ZSTAMP('SAH',.T.,.F.)
ZSTAMP('CT1',.T.,.F.)
ZSTAMP('CTT',.T.,.F.)
ZSTAMP('SYD',.T.,.F.)
ZSTAMP('SF4',.T.,.F.)
ZSTAMP('SF1',.T.,.F.)
ZSTAMP('SD1',.T.,.F.)

Return Nil


Static Function zStamp(cTabAlias, lStamp, lInsDt)
    Local cTabSQL     := ""
    Local lOkStamp    := .F.
    Local lOkInsDt    := .F.
    Default cTabAlias := ""
    Default lStamp    := .T.
    Default lInsDt    := .T.

    //Se veio algum alias e ele existir na base
    If ! Empty(cTabAlias) .And. ExisteSX2(cTabAlias)
        
        //Valida se consegue ativar o recurso no BD
        lOkStamp    := (lStamp .And. (TCConfig('SETAUTOSTAMP = ON') == 'OK') .And. (TCConfig('SETUSEROWSTAMP = ON') == 'OK'))
        lOkInsDt    := (lInsDt .And. (TCConfig('SETAUTOINSDT = ON') == 'OK') .And. (TCConfig('SETUSEROWINSDT = ON') == 'OK'))
        If lOkStamp .Or. lOkInsDt

            //Busca o nome real da tabela, exemplo SB1 => SB1010
            cTabSQL := RetSQLName(cTabAlias)

            //Se a tabela já estiver aberta, fecha para depois abrir em modo exclusivo
            If Select(cTabAlias) > 0
                (cTabAlias)->(DbCloseArea())
            EndIf

            //Tenta Abrir em modo Exclusivo
            USE (cTabSQL) ALIAS (cTabAlias) EXCLUSIVE NEW VIA "TOPCONN"
            If ! NetErr()

                //Aciona o Refresh na tabela
                TCRefresh(cTabSQL)

            Else
                FWAlertError('Tabela "' + cTabAlias + '" - não foi possível abrir em modo Exclusivo', 'Falha #1')
            EndIf
            (cTabAlias)->(DbCloseArea())

            //Desativa os recursos
            TCConfig('SETAUTOSTAMP = OFF')
            TCConfig('SETUSEROWSTAMP = OFF')

        //Senão, não será possível criar os campos
        Else
            FWAlertError('Não foi possível ativar os recursos no BD', 'Falha #2')
        EndIf
    EndIf

Return
