#include "rwmake.ch"
#include "protheus.ch"

// Ponto de entrada para Atribui valores a serem alterados e transportados para o ISS corrigir tipo variavel data campo E2_VENCISS dVcIss
// PARAMIXB[5]
// 05/06/15 - Adilson do Prdo

User Function xMT103ISS
Local cFornIss  := PARAMIXB[1]      // Código do fornecedor de ISS atual para gravação.
Local cLojaIss  := PARAMIXB[2]      // Loja do fornecedor de ISS atual para gravação.
Local cDirf     := PARAMIXB[3]      // Indicador de gera dirf atual para gravação.
Local cCodRet   := PARAMIXB[4]      // Código de retenção do título de ISS atual para gravação.
Local dVcIss    := CTOD("") //PARAMIXB[5]      // Data de vencimento do título de ISS atual para gravação.
Local aRet      := {}
Local nDia    	:= 0
Local nDiaUtil  := 0
Local nTamData	:= 0
Local dVencRIss := CTOD("")
Local lVcAntIss := (SuperGetMV("MV_ANTVISS",.T.,"2") == "1")  //Antecipa ou nao o vencimento do ISS em caso de vencimento em dia nao util
//Local nTamData := 0

//CALCULA DATA DE VENCIMENTO TITULO ISS
Do Case
	Case GetNewPar("MV_VENCISS","E")=="E"
		dVcIss := dDEmissao
		dVcIss += 28
		If ( Month(dVcIss) == Month(dDEmissao) )
			dVcIss := dVcIss+28
		EndIf
		nTamData := Iif(Len(Dtoc(dVcIss)) == 10, 7, 5)
		dVcIss	:= Ctod(StrZero(SuperGetMv("MV_DIAISS"),2)+"/"+Subs(Dtoc(dVcIss),4,nTamData))
	Case GetNewPar("MV_VENCISS","E")=="Q" //Ultimo dia util da quinzena subsequente a dDEmissao
		If Day(dDEmissao) <= 15
			dVcIss	:= LastDay(dDEmissao)
			dVcIss := DataValida(dVcIss,.F.)
		Else
			dVcIss := DataValida((LastDay(dDEmissao)+1)+14,.F.)
		EndIf
	Case GetNewPar("MV_VENCISS","E")=="U" //Ultimo dia util do mes subsequente da dDEmissao
		dVcIss := DataValida(LastDay(LastDay(dDEmissao)+1),.F.)
	Case GetNewPar("MV_VENCISS","E")=="D"
		dVcIss := (LastDay(dDEmissao)+1)
		nDiaUtil:= SuperGetMv("MV_DIAISS")
		For nDia := 1 To nDiaUtil-1
			If !(dVcIss == DataValida(dVcIss,.T.))
				nDia-=1
			EndIf
			dVcIss+=1
		Next nDia
	Case GetNewPar("MV_VENCISS","E")=="F" //Qtd de dia do parametro MV_DIAISS apos o fechamento da quinzena.
		If Day(dDEmissao) <= 15
			dVcIss := CtoD("15"+SUBSTR(DtoC(dDEmissao),3,Len(DtoC(dDEmissao))))+SuperGetMv("MV_DIAISS")
		Else
			dVcIss := LastDay(dDEmissao)+SuperGetMv("MV_DIAISS")
		EndIf
		OtherWise
		dVcIss := dVencto
		dVcIss += 28
		If ( Month(dVcIss) == Month(dDEmissao) )
			dVcIss := dVcIss+28
		EndIf
		nTamData := Iif(Len(Dtoc(dVcIss)) == 10, 7, 5)
		dVcIss	:= Ctod(StrZero(SuperGetMv("MV_DIAISS"),2)+"/"+Subs(Dtoc(dVcIss),4,nTamData))
EndCase

dVencRIss := DataValida(dVcIss,IIF(lVcAntIss,.F.,.T.))
dVcIss := IIF(dVcIss > dVencRIss, dVencRISS, dVcIss)


aAdd( aRet , cFornIss ) //Cod Forn ISS
aAdd( aRet , cLojaIss)     //Cod Loja Forn ISS
aAdd( aRet , cDirf)      //Gera Dirf ? - 1=Sim, 2=Nao
aAdd( aRet , cCodRet)   //Codigo de Receita
aAdd( aRet , IIF( VALTYPE(dVcIss) == "D",dVcIss,CTOD(dVcIss)))   //Vencimento ISS

Return (aRet)