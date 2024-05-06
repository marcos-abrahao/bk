#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} FA100TRF
    Ponto de entrada: Impede que exclusoes de transferências bancárias sejam feitas em data diferente da original, para nao causar erros na contabilidade.
    @type  Ponto de Entrada - Movimentos bancários FINA100 - Confirmação de Exclusão
    @author Marcos B. Abrahão
    @since 14/06/2015
    @version Kloeckner
/*/

User Function FA100TRF()
Local lRet := .T.
Local nOpc := 0
Local lEstorno  := ParamIXB[15]
Local ddtdisp   := ParamIXB[16]
//Local ddtcred   := ParamIXB[17]

If lEstorno
	//If ddtcred <> ddtdisp
	If dDatabase <> ddtdisp
		nOpc := u_AvisoLog("FA100TRF","Atenção à data",;
			               "A data da transferencia está diferente da data base do sistema."+Chr(13)+Chr(10)+;
	        		       "Antes de cancelar/excluir a baixa, favor alterar a data base do sistema para "+Dtoc(SE5->E5_DATA)+".",;
	               {"Sair"}, 1 )
//	               {"Sair","Estornar"}, 2 )
		lRet := (nOpc == 2)
	EndIf
EndIf

Return lRet
