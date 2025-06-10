#include "rwmake.ch"

// Ponto de entrada para gravar UserId e Superior 
// 19/11/09 - Marcos B Abrahão

User Function SF1100I()
Local aUser,cSuper
Local aAreaE2 	 := SE2->(GetArea())
Local lAltPgt	 := .F.

Private cxTipoPg := SF1->F1_XTIPOPG
Private cxNumPa  := SF1->F1_XNUMPA
Private cxBanco  := SF1->F1_XBANCO
Private lxP1PA   := IIF(SF1->F1_XXP1PA=='S',.T.,.F.)
Private cxAgencia:= SF1->F1_XAGENC
Private cxConta  := SF1->F1_XNUMCON
Private cChvNfe  := SF1->F1_CHVNFE
Private dPrvPgt  := SF1->F1_XXPVPGT
Private cJsPgt	 := SF1->F1_XXJSPGT
Private cxTpPix  := SF1->F1_XXTPPIX
Private cxChPix  := SF1->F1_XXCHPIX
Private nTipoPg  := 0
Private cEspecie := SF1->F1_ESPECIE
Private cxCond	 := SF1->F1_COND
Private mParcel	 := SF1->F1_XXPARCE
Private dCompet  := IIF(EMPTY(SF1->F1_XXCOMPD),SF1->F1_DTDIGIT,SF1->F1_XXCOMPD)
Private cLibF1   := ""
Private cCnpj    := Posicione("SA2",1,Xfilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_CGC")

If EMPTY(SF1->F1_XXUSER) .AND. VAL(__cUserId) > 0  // Não Gravar Administrador
	PswOrder(1) 
	PswSeek(__cUserId) 
	aUser  := PswRet(1)
	cSuper := aUser[1,11]
	RecLock("SF1",.F.)
	SF1->F1_XXUSER  := __cUserId
	SF1->F1_XXUSERS := cSuper
	MsUnLock("SF1")
EndIf

If Empty(SF1->F1_XXCOMPD)
	RecLock("SF1",.F.)
	SF1->F1_XXCOMPD := dCompet
	MsUnLock("SF1")
EndIf

If Inclui .AND. !l103Auto

	If Empty(dPrvPgt) 
		dPrvPgt := SE2->E2_VENCREA
	EndIf
	If Empty(cxBanco)
		u_GetSa2(SF1->F1_FORNECE,SF1->F1_LOJA)
	EndIf

	lAltPgt := U_SelFPgto(.T.,u_SemAnexo(__cUserId),@cLibF1)

	If lAltPgt
		RecLock("SF1",.F.)
		SF1->F1_XTIPOPG := cxTipoPg
		SF1->F1_XXP1PA  := IIF(lxP1PA,'S','N')
		SF1->F1_XNUMPA  := cxNumPa
		If ALLTRIM(cxTipoPg) == "DEPOSITO"
			SF1->F1_XBANCO  := cxBanco
			SF1->F1_XAGENC  := cxAgencia
			SF1->F1_XNUMCON := cxConta
		Else
			SF1->F1_XBANCO  := " "
			SF1->F1_XAGENC  := " "
			SF1->F1_XNUMCON := " "
		EndIf
		SF1->F1_CHVNFE  := cChvNfe
		SF1->F1_XXPVPGT := dPrvPgt
		SF1->F1_XXJSPGT := cJsPgt
		SF1->F1_COND	:= cxCond
		SF1->F1_XXPARCE := mParcel
		If ALLTRIM(cxTipoPg) == "PIX"
			SF1->F1_XXTPPIX := cxTpPix
			SF1->F1_XXCHPIX := cxChPix
		Else
			SF1->F1_XXTPPIX := ""
			SF1->F1_XXCHPIX := ""
		EndIf
		SF1->F1_XXCOMPD := dCompet
		MsUnLock("SF1")

	EndIf
EndIf


If l103Class .OR. Inclui
	If SF1->F1_STATUS $ "AB"
		RecLock("SF1",.F.)
		If SF1->F1_STATUS == "A"
			SF1->F1_XXLIB  := "C"
		Else
			SF1->F1_XXLIB  := "B"
		EndIf
		If Empty(SF1->F1_XXULIB)
			SF1->F1_XXULIB  := __cUserId
		EndIf
		If Empty(SF1->F1_XXDLIB)
			SF1->F1_XXDLIB  := DtoC(Date())+"-"+Time()
		EndIf
		If Empty(SF1->F1_XXDINC)
			SF1->F1_XXDINC  := DtoC(Date())+"-"+Time()
		EndIf
		SF1->F1_XXUCLAS := __cUserId
		SF1->F1_XXDCLAS := DtoC(Date())+"-"+Time()
		MsUnLock("SF1")

		u_MsgLog("SF1100I",iIf(l103Class,"Doc classificado: ","Doc incluido: ")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+" "+SF1->F1_ESPECIE)

	EndIf
EndIf


// Gravar os campo  E2_XTIPOPG e E2_PORTADO
If l103Class .OR. Inclui .OR. lAltPgt
	// Se for Beneficiamento ou Devolucao, será Título a Receber, senão será Título a Pagar
	If !(SF1->F1_TIPO $ "B;D;") //.AND. !Empty(SF1->F1_XBANCO)
		DbSelectArea("SE2")
		SE2->(DbSetOrder(6))  //E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM			
		//Se conseguir posicionar, altera o banco
		SE2->(DbSeek(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC))
		Do While SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC == ;
					SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM .AND. !SE2->(EOF())
			If Empty(SE2->E2_BAIXA)
				RecLock("SE2",.F.)

				SE2->E2_XTIPOPG := SF1->F1_XTIPOPG

				If Empty(SE2->E2_PORTADO)
					SE2->E2_PORTADO  := SF1->F1_XBANCO
				EndIf

				// Parcelamento UNIAO e outros fornecedores com "I" na Natureza (INSS, PIS, COFINS) - Kelly 11/11/24
				SA2->(dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))

				If (SUBSTR(SE2->E2_FORNECE,1,5) == "UNIAO" .OR. ("I" $ SA2->A2_NATUREZ)) .AND. !EMPTY(SE2->E2_PARCELA)
					SE2->E2_PORTADO  := "001"
					SE2->E2_XXPGTO   := "L"
				EndIf

				// Cartão - Kelly 11/11/24
				If TRIM(SF1->F1_XTIPOPG) == "CARTAO"
					If Day(SE2->E2_VENCTO) > 10 .AND. Day(SE2->E2_VENCTO) < 20
					    //os cartões do Itáu são data vencimento 12 e 15
						SE2->E2_PORTADO  := "341"
					Else
						// já os BB são vencimento 28
						SE2->E2_PORTADO  := "001"
					EndIf
					SE2->E2_XXPGTO   := "T"
				EndIf

				If SF1->F1_XXP1PA == 'S' .AND. SE2->E2_PARCELA == '01'
					SE2->E2_XTIPOPG := "P.A."
				EndIf

				SE2->(MsUnLock())
			Endif
			SE2->(dbSkip())
		EndDo
	EndIf     
	RestArea(aAreaE2)
EndIF

Return

Return .T.


