#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A103CND2  ºAutor  ³Marcos B Abrahao    º Data ³  04/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada para nao permitir vencimentos com data    º±±
±±º          ³ anterior a 2 dias uteis                                    º±±
±±º          ³ Alterado para não aceitar data inferior ao prox dia util   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ³Analista/Alterações                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
// Validação da condiçao de pgto na tela de doc de entrada
User Function A103CND2()
Local nV
Local dDtUtil

dDtUtil := DataValida(dDatabase,.T.)
//dDtUtil := DataValida(dDatabase+1,.T.)
//dDtUtil := DataValida(dDtUtil+1,.T.)
FOR nV := 1 TO LEN(PARAMIXB)
	If LEN(PARAMIXB) == 1 .AND. cCondicao == "999"
		If !Empty(SF1->F1_XXPVPGT)
			PARAMIXB[nV,1] := SF1->F1_XXPVPGT
		EndIf
	EndIf

    IF PARAMIXB[nV,1] < dDtUtil
       PARAMIXB[nV,1] := dDtUtil
    ENDIF
NEXT

Return(PARAMIXB)


// Validação da alteração data de vencimento na tela de Doc. de Saída - duplicatas
User Function BkVencto(dVenBk)
Local dDtUtil,lRet := .T.

IF nModulo = 2
	dDtUtil := DataValida(dDatabase,.T.)
	//dDtUtil := DataValida(dDatabase+1,.T.)
	//dDtUtil := DataValida(dDtUtil+1,.T.)
	If Len(aCols) == 1 .AND. cCondicao == "999"
		If !Empty(SF1->F1_XXPVPGT)
			aCols[1,2] := SF1->F1_XXPVPGT
		EndIf
	EndIf
	IF dVenBk < dDtUtil
	   lRet := .F.
	ENDIF
ENDIF

RETURN lRet
