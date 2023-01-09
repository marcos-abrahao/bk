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
Local cContra   := ""
Local cPedido	:= SC5->C5_NUM
Local cMedicao  := SC5->C5_MDNUMED
Local cPlan     := SC5->C5_MDPLANI
Local nTotal    := 0
Local aAreaSC6  := GetArea("SC6")  
Local cRev      := ""
Local cCompM    := ""
Local cParcel	:= ""
Local cObsMed   := ""
Local cEmissor  := ""
Local cNomeCl   := ALLTRIM(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"))

cContra   := iIf(Empty(SC5->C5_MDCONTR),SC5->C5_ESPECI1,SC5->C5_MDCONTR)
aAnexos   := u_BKDocs(cEmpAnt,"SZE",PAD(cContra,15)+SUBSTR(SC5->C5_XXCOMPM,4,4)+SUBSTR(SC5->C5_XXCOMPM,1,2),2)
cEmail    := u_EmailFat(__cUserID)
cEmailCC  += UsrRetMail(__cUserId)+';'
cEmailCC  += UsrRetMail(SUBSTR(EMBARALHA(SC5->C5_USERLGI,1),3,6))+';'

cAssunto  := "Pedido(s) de venda liberado(s) - Contrato: "+ALLTRIM(cContra)+" - "+cNomeCl

// Dados do Pedido
U_PMedPed(cPedido,cContra,cMedicao,cPlan,@cRev,@cCompM,@cParcel,@cObsMed,@cEmissor)

SC6->(DbSeek(xFilial('SC6') + SC5->C5_NUM))
While !SC6->(EoF()) .And. SC6->C6_NUM == SC5->C5_NUM
   nTotal += SC6->C6_VALOR
   SC6->(DbSkip())
EndDo

aCabs   := {"","","Medição","Valor"}
aEmail 	:= {}
AADD(aEmail,{"Emissão:"    ,TRIM(SC5->C5_NUM),DTOC(SC5->C5_EMISSAO),"",""})
AADD(aEmail,{"Cliente:"    ,SC5->C5_CLIENTE+"-"+SC5->C5_LOJACLI+" - "+cNomeCl,"",""})
AADD(aEmail,{"Contrato:"   ,cContra+" - Rev. "+cRev+" - "+Posicione("CTT",1,xFilial("CTT")+cContra,"CTT_DESC01"),"",""})
AADD(aEmail,{"Competencia:",SC5->C5_XXCOMPM+" - Parcela "+cParcel,"",""})
AADD(aEmail,{"Valor:"      ,ALLTRIM(TRANSFORM(nTotal,"@E 99,999,999,999.99")),"",""})
AADD(aEmail,{"Observações:",ALLTRIM(cObsMed),"",""})

ListPed(@aEmail,cContra,SC5->C5_XXCOMPM)

If LEN(aAnexos) == 0
    AADD(aEmail,{"Atenção    : ","não foram anexados arquivos para este contrato/competência","",""})
EndIf

cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,"MT440GR")
U_BkSnMail("MT440GR",cAssunto,cEmail,cEmailCC,cMsg,aAnexos)

SC6->(RestArea(aAreaSC6))

Return Nil


Static Function ListPed(aEmail,cContra,cCompet)
Local cQuery
Local aArea := GetArea()

cQuery := "SELECT C5_NUM,C5_MDCONTR,C5_MDNUMED,C5_XXCOMPM,SUM(C6_VALOR) AS C6VALOR "+CRLF
cQuery += " FROM "+RETSQLNAME("SC5")+ " SC5 "+CRLF
cQuery += " INNER JOIN "+RETSQLNAME("SC6")+ " SC6 ON C5_NUM = C6_NUM "+CRLF
cQuery += "      AND  C6_FILIAL = C5_FILIAL AND SC6.D_E_L_E_T_ = '' "+CRLF
cQuery += "  WHERE SC5.D_E_L_E_T_ = ' ' " +CRLF
cQuery += "        AND C5_MDCONTR = '"+cContra+"' AND C5_XXCOMPM = '"+cCompet+"' " +CRLF
cQuery += "GROUP BY C5_NUM,C5_MDCONTR,C5_MDNUMED,C5_XXCOMPM "+CRLF
cQuery += "ORDER BY C5_NUM,C5_MDCONTR,C5_MDNUMED,C5_XXCOMPM "+CRLF

u_LogMemo("LISTPED.SQL",cQuery)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QSC5",.T.,.T.)

Dbselectarea("QSC5")
QSC5->(Dbgotop())
Do While !QSC5->(EOF())
    aAdd(aEmail,{"Pedido:",ALLTRIM(QSC5->C5_NUM),QSC5->C5_MDNUMED,QSC5->C6VALOR})
    dbSkip()
Enddo
QSC5->(dbCloseArea())

RestArea(aArea)

Return aEmail
