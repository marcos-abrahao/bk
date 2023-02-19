#include "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MTASF2 - BK
Gravar campos adicionais no SF2

@Return
@author Marcos Bispo Abrahão
@since 21/08/2019
@version P11/P12
/*/
//-------------------------------------------------------------------


User Function MTASF2()
//Local cEmailTO,cEmailCC,cMsg
IF !EMPTY(SC5->C5_XXRETC)
	// Gravar o percentual e valor da Retenção Contratual
	SF2->F2_XXRETC  := SC5->C5_XXRETC
	SF2->F2_XXVRETC := ROUND(SC5->C5_XXRETC * SF2->F2_VALBRUT / 100,2) 
ENDIF

// 09/12/2021 - Marcos/Xavier
/*

Removido em 17/02/2023
If SF2->F2_CLIENTE == '000367' //.AND. SF2->F2_VLCPM > 0

	cEmailTO := 'fiscal@conlinecontabil.com.br;financeiro@bkconsultoria.com.br;'
	cEmailCC := 'microsiga@bkconsultoria.com.br'
	
	cMsg := 'Sr(a) responsável pelo Depto Fiscal'+CRLF+CRLF
	cMsg += 'Será necessária a geração de guia de recolhimento do ISS para esta NF na Prefeitura do Rio de Janeiro no valor de R$ '+ ALLTRIM(TRANSFORM(SF2->F2_VLCPM,"@E 999,999,999.99"))+"."+CRLF+CRLF
	cMsg += 'Atenção: Inclua um Documento Financeiro para pagamento.'

	u_BkSnMail("MTASF2","Nota Fiscal "+SF2->F2_DOC+" emitida para o Ministério Públido do RJ",cEmailTO,cEmailCC,cMsg,)

EndIf
*/
Return Nil

