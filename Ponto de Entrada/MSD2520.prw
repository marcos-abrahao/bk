#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MSD2520
	BK - Ponto de Entrada executado na exclusao da nota fiscal de saida - Itens
	@type  Function
	@author Marcos Bispo Abrahão
	@since 27/12/2022
	@version 12.1.33
	/*/

User Function MSD2520() 
Local aArea 	:= GetArea()
Local cContra   := PAD(SC5->C5_MDCONTR,15)
Local cCompAM   := SUBSTR(SC5->C5_XXCOMPM,4,4)+SUBSTR(SC5->C5_XXCOMPM,1,2)

DbSelectArea("SZE")
If DbSeek(xFilial("SZE")+cContra+cCompAM)
    If SZE->ZE_ENVEM == "S"  // Email enviado para este contrato+competencia
        SD2Email()
    EndIf
    RecLock("SZE", .F.)
    SZE->ZE_ENVEM := "E" 
    MsUnlock()
EndIf

RestArea(aArea)
Return Nil



Static Function SD2Email()
Local cEmail    := ""
Local cEmailCC  := "microsiga@bkconsultoria.com.br;" 
Local aCabs   	:= {}
Local aEmail 	:= {}
Local aAnexos   := {}
Local cMsg		:= ""
Local cAssunto  := ""
Local cContra   := ""
Local nTotal    := 0

cEmail    := u_EmailFat(__cUserID)
cAssunto  := "Exclusão da NF nº.: "+SD2->D2_SERIE+"-"+SD2->D2_DOC+" - Pedido: "+SC5->C5_NUM+ " - "+ALLTRIM(SA1->A1_NOME)
cContra   := iIf(Empty(SC5->C5_MDCONTR),SC5->C5_ESPECI1,SC5->C5_MDCONTR)
cEmailCC  += UsrRetMail(__cUserId)+';'
cEmailCC  += UsrRetMail(SUBSTR(EMBARALHA(SC5->C5_USERLGI,1),3,6))+';'

// Dados do Pedido
//U_PMedPed(cPedido,cContra,cMedicao,cPlan,@cRev,@cCompM,@cParcel,@cObsMed,@cEmissor)

nTotal += SF2->F2_VALFAT

aCabs   := {"NF nº.: "+SD2->D2_SERIE+"-"+SD2->D2_DOC+" Pedido: "+SC5->C5_NUM}
aEmail 	:= {}
AADD(aEmail,{"Cliente    : "+SA1->A1_COD+"-"+SA1->A1_LOJA+" - "+SA1->A1_NOME})
AADD(aEmail,{"Contrato   : "+cContra+" - "+Posicione("CTT",1,xFilial("CTT")+cContra,"CTT_DESC01")})
AADD(aEmail,{"Competencia: "+SC5->C5_XXCOMPM})
AADD(aEmail,{"Valor      : "+ALLTRIM(TRANSFORM(nTotal,"@E 99,999,999,999.99"))})
AADD(aEmail,{"Observações: "+"Anexos serão enviados novamente após nova liberação do pedido"})
cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,"MSD2520")
U_BkSnMail("MSD2520",cAssunto,cEmail,cEmailCC,cMsg,aAnexos)

Return Nil
