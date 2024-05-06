#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} FA100CA2
    Ponto de entrada: Impede que exclusoes de mov bancario sejam feitas em data diferente da original, para nao causar erros na contabilidade.
    @type  Ponto de Entrada - Movimentos bancários FINA100 - Confirmação de Exclusão
    @author Marcos B. Abrahão
    @since 14/06/2015
    @version Kloeckner
/*/

User Function FA100CA2()
Local lRet := .T.
Local nOpc := 0

If dDatabase <> SE5->E5_DATA
	nOpc := u_AvisoLog("FA100CA2","Atenção à data",;
	               "A data do estorno do mov. bancário está diferente da data base do sistema."+Chr(13)+Chr(10)+;
	               "Antes de cancelar/excluir a baixa, favor alterar a data base do sistema para "+Dtoc(SE5->E5_DATA)+".",;
	               {"Sair"}, 1 )
//	               {"Sair","Estornar"}, 2 )
	lRet := (nOpc == 2)
EndIf

Return lRet
