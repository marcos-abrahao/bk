#include "rwmake.ch"

// Ponto de entrada para gravar UserId e Superior 
// 19/11/09 - Marcos B Abrahão

User Function SF1100I()
Local aUser,cSuper
Local aAreaE2 	 := SE2->(GetArea())

Private cxTipoPg := SF1->F1_XTIPOPG
Private cxNumPa  := SF1->F1_XNUMPA
Private cxBanco  := SF1->F1_XBANCO
Private cxAgencia:= SF1->F1_XAGENC
Private cxConta  := SF1->F1_XNUMCON
Private cChvNfe  := SF1->F1_CHVNFE
Private dPrvPgt  := SF1->F1_XXPVPGT
Private cJsPgt	 := SF1->F1_XXJSPGT
Private nTipoPg  := 0
Private cEspecie := SF1->F1_ESPECIE
Private cxCond	 := SF1->F1_COND
Private mParcel	 := SF1->F1_XXPARCE
Private cLibF1   := ""

IF EMPTY(SF1->F1_XXUSER) .AND. VAL(__cUserId) > 0  // Não Gravar Administrador
	PswOrder(1) 
	PswSeek(__cUserId) 
	aUser  := PswRet(1)
	cSuper := aUser[1,11]
	RecLock("SF1",.F.)
	SF1->F1_XXUSER  := __cUserId
	SF1->F1_XXUSERS := cSuper
	MsUnLock("SF1")
ENDIF

If Inclui .AND. !l103Auto
	//If !__cUserId $ "000011/000012/000016"
	If Empty(dPrvPgt) 
		dPrvPgt := SE2->E2_VENCREA
	EndIf
	If Empty(cxBanco)
		u_GetSa2(SF1->F1_FORNECE,SF1->F1_LOJA)
	EndIf

	If U_SelFPgto(.T.,__cUserId $ "000000/000011/000012/000016/000170",@cLibF1) // 170-João Cordeiro
		RecLock("SF1",.F.)
		SF1->F1_XTIPOPG := cxTipoPg
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

		// Se for Beneficiamento ou Devolucao, será Título a Receber, senão será Título a Pagar
		If !(SF1->F1_TIPO $ "B;D;") .AND. !Empty(SF1->F1_XBANCO)
			DbSelectArea("SE2")
			SE2->(DbSetOrder(6))  //E2_FILIAL + E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM
			
			//Se conseguir posicionar, altera o banco
			SE2->(DbSeek(xFilial("SE2")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC))
			Do While SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_SERIE+SF1->F1_DOC == ;
					 SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_PREFIXO+SE2->E2_NUM .AND. !SE2->(EOF())
				RecLock("SE2",.F.)
				If Empty(SE2->E2_PORTADO)
					SE2->E2_PORTADO  := SF1->F1_XBANCO
					SE2->(MsUnLock())
				EndIf
				SE2->(dbSkip())
			EndDo
		EndIf
     
		RestArea(aAreaE2)

		u_MsgLog("SF1100I",iIf(l103Class,"Doc classificado: ","Doc incluido    : ")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+" "+SF1->F1_ESPECIE)

	EndIf
EndIf

Return

Return .T.


