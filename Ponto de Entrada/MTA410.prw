#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTA410    ºAutor  ³ Marcos             º Data ³  11/08/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada de validação do pedido de vendas.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */

User Function MTA410()
Local _lRet := .T.
If Empty(M->C5_MDCONTR) .and. (ALTERA .OR. INCLUI)
	If Empty(M->C5_ESPECI1)
		MsgBox("C.Custo (BK) deve ser obrigatoriamente preenchido!","TI - BK","MTA410")
		_lRet := .F.
	ElseIf Empty(M->C5_XXCOMPT)
		MsgBox("Para pedidos avulsos, a competência deve ser obrigatoriamente preenchida!","TI - BK","MTA410")
		_lRet := .F.
	Else
		If VAL(SUBSTR(M->C5_XXCOMPT,1,2)) < 1 .OR. VAL(SUBSTR(M->C5_XXCOMPT,1,2)) > 12
			MsgBox("Preencha corretamente o mes da competência!","TI - BK","MTA410")
			_lRet := .F.
		EndIf	
		If _lRet .AND. (VAL(SUBSTR(M->C5_XXCOMPT,3,4)) < 2009 .OR. VAL(SUBSTR(M->C5_XXCOMPT,3,4)) > 2100)
			MsgBox("Preencha corretamente o ano da competência!","TI - BK","MTA410")
			_lRet := .F.
    	EndIf
   EndIf
   If !Empty(M->C5_XXCOMPT) 
		M->C5_XXCOMPM := SUBSTR(M->C5_XXCOMPT,1,2)+"/"+SUBSTR(M->C5_XXCOMPT,3,4)
   EndIf
EndIf

Return(_lRet)
