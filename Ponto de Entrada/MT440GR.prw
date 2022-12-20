#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT440GR
BK - Ponto de Entrada - gravação da liberação do pedido de venda 
@Return
@author  Marcos Bispo Abrahão
@since 12/12/22
@version P12
/*/

User Function MT440GR()
Local lRet  := .T.
Local nOk   := PARAMIXB[1]
lRet := u_BK440GR(nOk)
Return (lRet)


User Function BK440GR(nOk)
Local aArea := GetArea()
Local lRet  := .T.
Local cContra := PAD(SC5->C5_MDCONTR,15)
Local cCompAM := SUBSTR(SC5->C5_XXCOMPM,4,4)+SUBSTR(SC5->C5_XXCOMPM,1,2)
If nOK == 1

    // Aqui: posicionar no SZE e ver se o email já foi enviado, senão, envia e grava que foi    

    DbSelectArea("SZE")
    If DbSeek(xFilial("SZE")+cContra+cCompAM)
        If SZE->ZE_ENVEM  <> "S"  // Email não enviado para este contrato+competencia
            SC5Email()
            RecLock("SZE", .F.)
            SZE->ZE_ENVEM := "S" 
            MsUnlock()
        EndIf
    ElseIf !Empty(cContra) .AND. !Empty(cCompAM)
        SC5Email()
		RecLock("SZE", .T.)
		SZE->ZE_CONTRAT := cContra
		SZE->ZE_COMPET  := cCompAM
        SZE->ZE_ENVEM   := "S" 
		MsUnlock()
    EndIf

    //lRet := .F. // Para teste

Endif
RestArea(aArea)
Return (lRet)





Static Function SC5Email()
Local cEmail    := ""
Local cEmailCC  := "microsiga@bkconsultoria.com.br;" 
Local aCabs   	:= {}
Local aEmail 	:= {}
Local aAnexos   := {}
Local cMsg		:= ""
Local cAssunto  := ""
Local cContrato := ""
Local nTotal    := 0
Local aAreaSC6  := GetArea("SC6")  

aAnexos   := u_BKDocs(cEmpAnt,"SZE",PAD(SC5->C5_MDCONTR,15)+SUBSTR(SC5->C5_XXCOMPM,4,4)+SUBSTR(SC5->C5_XXCOMPM,1,2),2)
cEmail    := u_EmailFat(__cUserID)
cAssunto  := "Pedido de venda nº.:"+SC5->C5_NUM+ " - "+ALLTRIM(SA1->A1_NOME)+" liberado em "+DTOC(DATE())+"-"+TIME()+" - "+FWEmpName(cEmpAnt)
cContrato := iIf(Empty(SC5->C5_MDCONTR),SC5->C5_ESPECI1,SC5->C5_MDCONTR)

cEmailCC += UsrRetMail(__cUserId)+';'

SC6->(DbSeek(xFilial('SC6') + SC5->C5_NUM))
While !SC6->(EoF()) .And. SC6->C6_NUM == SC5->C5_NUM
   nTotal += SC6->C6_VALOR
   SC6->(DbSkip())
EndDo

aCabs   := {"Pedido nº.:" + TRIM(SC5->C5_NUM)}
aEmail 	:= {}
AADD(aEmail,{"Cliente    :"+SA1->A1_COD+"-"+SA1->A1_LOJA+" - "+SA1->A1_NOME})
AADD(aEmail,{"Contrato   :"+cContrato})
AADD(aEmail,{"Competencia:"+SC5->C5_XXCOMPM})
AADD(aEmail,{"Valor      :"+ALLTRIM(TRANSFORM(nTotal,"@E 99,999,999,999.99"))})

cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,"MT440GR")
U_BkSnMail("MT440GR",cAssunto,cEmail,cEmailCC,cMsg,aAnexos)

SC6->(RestArea(aAreaSC6))

Return Nil



