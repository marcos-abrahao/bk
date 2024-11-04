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
Local cEmailCC  := u_EmailAdm()
Local aCabs   	:= {}
Local aEmail 	:= {}
Local cAnexo    := ""
Local cMsg		:= ""
Local cAssunto  := ""
Local cContra   := ""
Local nTotal    := 0
Local cNomeCl   := ALLTRIM(Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NOME"))

cEmail    := u_EmailFat(__cUserID)
cAssunto  := "Exclusão da NF nº.: "+SD2->D2_SERIE+"-"+SD2->D2_DOC+" - Pedido: "+SC5->C5_NUM+ " - "+cNomeCl
cContra   := iIf(Empty(SC5->C5_MDCONTR),SC5->C5_ESPECI1,SC5->C5_MDCONTR)
cEmailCC  += UsrRetMail(__cUserId)+';'
cEmailCC  += UsrRetMail(SUBSTR(EMBARALHA(SC5->C5_USERLGI,1),3,6))+';'

// Dados do Pedido
//U_PMedPed(cPedido,cContra,cMedicao,cPlan,@cRev,@cCompM,@cParcel,@cObsMed,@cEmissor)

nTotal  := SF2->F2_VALFAT

aCabs   := {"NF nº.: "+SD2->D2_SERIE+"-"+SD2->D2_DOC+" Pedido: "+SC5->C5_NUM}
aEmail 	:= {}
AADD(aEmail,{"Cliente    : "+SF2->F2_CLIENTE+"-"+SF2->F2_LOJA+" - "+cNomeCl})
AADD(aEmail,{"Contrato   : "+cContra+" - "+Posicione("CTT",1,xFilial("CTT")+cContra,"CTT_DESC01")})
AADD(aEmail,{"Competencia: "+SC5->C5_XXCOMPM})
AADD(aEmail,{"Valor      : "+ALLTRIM(TRANSFORM(nTotal,"@E 99,999,999,999.99"))})
AADD(aEmail,{"Observações: "+"Anexos serão enviados novamente após nova liberação do pedido"})
cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,"MSD2520","",cEmail,cEmailCC)

cAnexo  := "MSD2520"+alltrim(SD2->D2_DOC)+".html"
u_GrvAnexo(cAnexo,cMsg,.T.)

U_BkSnMail("MSD2520",cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)

Return Nil
