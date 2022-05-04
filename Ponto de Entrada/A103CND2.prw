#include "rwmake.ch"

/*/{Protheus.doc} A103CND2
BK - Validação da condiçao de pgto na tela de doc de entrada
@Return
@author Marcos Bispo Abrahão
@since 04/11/09
@version P12
/*/

User Function A103CND2()
Local nV 		As Numeric
Local nI		As Numeric
Local dDtUtil
Local mParcel	:= SF1->F1_XXPARCE
Local aDados	:= {}
Local aArea		:= GetArea()

//SF1->(dbSetOrder(1))
//If SF1->(DbSeek(FWxFilial("SF1") + cNFiscal + cSerie + cA100For + cLoja + cTipo))
//	mParcel	:= SF1->F1_XXPARCE
//EndIf
If l103Auto
	nI := Ascan(aAutoCab,{ |x| x[1] == "F1_XXPARCE"})
	If nI > 0
		mParcel := aAutoCab[nI,2]
	EndIf
ElseIf inclui
	mParcel := ""
EndIf

dDtUtil := DataValida(dDatabase,.T.)
//dDtUtil := DataValida(dDatabase+1,.T.)
//dDtUtil := DataValida(dDtUtil+1,.T.)

If cCondicao == "999" .OR. cCondicaoOld = ''
	If !Empty(mParcel) .AND. (cCondicao <> cCondicaoOld .OR. cCondicao = '999')
		LoadVenc(@aDados,mParcel)
		If Len(aDados) == Len(PARAMIXB)
			For nV := 1 TO Len(PARAMIXB)
				PARAMIXB[nV,1] := aDados[nV,2]
				PARAMIXB[nV,2] := aDados[nV,3]
				If PARAMIXB[nV,1] < dDtUtil
					PARAMIXB[nV,1] := dDtUtil
				EndIf
			Next
		Else
			PARAMIXB := {}
			For nV := 1 TO Len(aDados)
				aAdd(PARAMIXB,{aDados[nV,2],aDados[nV,3]})
				If PARAMIXB[nV,1] < dDtUtil
					PARAMIXB[nV,1] := dDtUtil
				EndIf
			Next
		EndIf
		If !inclui .AND. cCondicao == "999"
			cCondicao := SF1->F1_COND
		EndIf
	EndIf
ElseIf cCondicao == "101" 
	// 28/04/22 - Configurar condição de pagamento 101 para não postegar pagamentos em feriados e finais de semana
	For nV := 1 TO Len(PARAMIXB)
		PARAMIXB[nV,1] := DataValida(PARAMIXB[nV,1],.F.)
	Next
Else
	For nV := 1 TO Len(PARAMIXB)
		If PARAMIXB[nV,1] < dDtUtil
			PARAMIXB[nV,1] := dDtUtil
		EndIf
	Next
EndIf

RestArea(aArea)
Return(PARAMIXB)



Static Function LoadVenc(aDados,mParcel)
Local aTmp		:= {}
Local nX 		:= 0
Local nTamTex	:= 0

nTamTex := mlCount(mParcel, 200)
For nX := 1 To nTamTex	
	aTmp := StrTokArr(memoline(mParcel, 200, nX),";")
	If !Empty(aTmp[1])
		aAdd(aDados,{aTmp[1],CTOD(aTmp[2]),VAL(aTmp[3]),.F.})
	EndIf
Next

Return


// Validação da alteração data de vencimento na tela de Doc. de Saída - duplicatas
User Function BkVencto(dVenBk)
Local dDtUtil,lRet := .T.

IF nModulo = 2
	dDtUtil := DataValida(dDatabase,.T.)
	//dDtUtil := DataValida(dDatabase+1,.T.)
	//dDtUtil := DataValida(dDtUtil+1,.T.)
	/*
	If Len(aCols) == 1 .AND. cCondicao == "999"
		If !Empty(SF1->F1_XXPVPGT)
			aCols[1,2] := SF1->F1_XXPVPGT
		EndIf
	EndIf
	*/
	IF dVenBk < dDtUtil
	   lRet := .F.
	ENDIF
ENDIF


RETURN lRet
