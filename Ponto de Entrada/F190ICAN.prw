#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} F190ICAN
    Ponto de entrada para controlar permissao de cancelamento do cheque
    @type  Ponto de Entrada: Cheques Emitidos FINA190
    @author Marcos B. Abrahão
    @since 08/09/2015
    @version Kloeckner
/*/

User Function F190ICAN()
Local lRet := .T.
Local nOpc := 0

If dDatabase <> SEF->EF_DATA
	nOpc := u_AvisoLog("F190ICAN","Atenção à data",;
	               "A data do estorno do cheque está diferente da data base do sistema."+Chr(13)+Chr(10)+;
	               "Antes de cancelar o cheque, altere a data base do sistema para "+Dtoc(SEF->EF_DATA)+".",;
	               {"Sair"}, 1 )
//	               {"Sair","Estornar"}, 2 )
	lRet := (nOpc == 2)
EndIf

Return lRet
