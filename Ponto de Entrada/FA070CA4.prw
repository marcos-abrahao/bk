#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} FA070CA4
    Ponto de entrada: Impede que exclusoes de baixa sejam feitas em data diferente da baixa, para nao causar erros na contabilidade
    @type  Ponto de Entrada - Confirmação de exclusão FINA070 - Baixas a Receber
    @author Marcos B. Abrahão
    @since 02/06/2015
    @version Kloeckner
/*/

User Function FA070CA4()
Local lRet := .T.
Local nOpc := 0

If dDatabase <> SE5->E5_DATA
	nOpc := u_AvisoLog("FA070CA4","Atenção à data",;
	               "A data do estorno da baixa (CR) está diferente da data base do sistema."+Chr(13)+Chr(10)+;
	               "Antes de cancelar/excluir a baixa, favor alterar a data base do sistema para "+Dtoc(SE5->E5_DATA)+".",;
	               {"Sair"}, 1 )
//	               {"Sair","Estornar"}, 2 )
	lRet := (nOpc == 2)
EndIf

Return lRet
