#Include "Protheus.ch"

/*/{Protheus.doc} NFSEMAIL
BK - Email para instrução normativa de NFS de Barueri
@Return
@author Marcos Bispo Abrahão
@since 10/01/2021
@version P12
/*/
User Function NFSEMAIL()
Local cEmail    := ""
Local cKeyD2    := ""
Local cContrato := ""
Local cNumMed   := ""
Local cRevisa   := ""
Local aAreaSD2
Local aAreaSC5
Local aAreaCNC

u_MsgLog("NFSEMAIL",SF3->F3_SERIE+SF3->F3_NFISCAL)

dbSelectArea("SD2")
aAreaSD2   := GetArea("SD2")
dbSelectArea("SC5")
aAreaSC5   := GetArea("SC5")
dbSelectArea("CNC")
aAreaCNC   := GetArea("CNC")
dbSelectArea("CND")
aAreaCND   := GetArea("CND")

cEmail := SA1->A1_EMAIL

dbSelectArea("SD2")
dbSetOrder(3)                 //filial,doc,serie,cliente,loja,cod

cKeyD2 := xFilial("SD2")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA
dbSelectArea("SD2")
dbSeek(cKeyD2)
Do While !EOF() .and. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == cKeyD2
	dbSelectArea("SC5")
	If dbSeek(xFilial("SC5") + SD2->D2_PEDIDO)
		cContrato   := SC5->C5_MDCONTR
        cNumMed     := SC5->C5_MDNUMED
        Exit
	EndIf
	dbSelectArea("SD2")
	dbSkip()
EndDo
If !Empty(cContrato)
    DbSelectArea("CND")
	CND->(DBSETORDER(4))
	CND->(DBSEEK(xFilial("CND")+cNumMed,.F.))
	Do While !Eof() .AND. xFilial("CND")+cNumMed == CND->CND_FILIAL+CND->CND_NUMMED
		If CND->CND_REVISA == CND->CND_REVGER
            cRevisa := CND->CND_REVISA
			Exit
		EndIf
		CND->(dbSkip())
	EndDo

	dbSelectArea("CNC")
    dbSetOrder(3)
    If dbSeek(xFilial("CNC")+cContrato+cRevisa+SA1->A1_COD+SA1->A1_LOJA)
        If !Empty(CNC_XEMAIL)
            cEmail := CNC->CNC_XEMAIL
        EndIf
    EndIf
EndIf

If Empty(cEmail)
    cEmail := "microsiga@bkconsultoria.com.br"
EndIf
cEmail := STRTRAN(cEmail,";","|")

SD2->(RestArea(aAreaSD2))
SC5->(RestArea(aAreaSC5))
CNC->(RestArea(aAreaCNC))
CND->(RestArea(aAreaCND))

Return cEmail
