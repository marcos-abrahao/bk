#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "topconn.ch"

// Para identificar alteração em NF alteradas após liberação
// 07/07/15 - Marcos B Abrahão

User Function MT100TOK()
Local cQuery2   := ""
Local cAliasD1  := GetNextAlias()
Local nValTot   := 0
Local nTelTot   := 0
Local nPosTotal := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
Local lRet      := .T.
Local lClas     := .F.
Local nI        := 0

If lMT100TOK
	lMT100TOK := .F. 
	If Type( "l103Class" ) == "L"
		lClas := l103Class
	EndIf

	If lClas .AND. !EMPTY(SF1->F1_APROV)

		cQuery2 := "SELECT SUM(D1_TOTAL) AS D1TOTAL "
		cQuery2 += " FROM "+RETSQLNAME("SD1")+" SD1" 
		cQuery2 += " WHERE SD1.D1_FILIAL='"+xFilial('SD1')+"' AND SD1.D_E_L_E_T_=''"
		cQuery2 += "       AND SD1.D1_DOC='"+SF1->F1_DOC+"' AND SD1.D1_SERIE='"+SF1->F1_SERIE+"'"
		cQuery2 += "       AND SD1.D1_FORNECE='"+SF1->F1_FORNECE+"' AND SD1.D1_LOJA='"+SF1->F1_LOJA+"'"
			        
		TCQUERY cQuery2 NEW ALIAS (cAliasD1)
		TCSETFIELD(cAliasD1,"D1TOTAL","N",18,2)
		
		dbSelectArea(cAliasD1)
		dbGoTop()
		nValTot := (cAliasD1)->D1TOTAL 
		
		(cAliasD1)->(DbCloseArea())
	
		For nI:=1 to len(aCols)
	 		If aCols[n,Len(aHeader)+1] == .F.   // Se .T. a "linha" esta deletada 
	 	    	nTelTot += aCols[nI,nPosTotal]
	 	 	EndIf
		Next	
	
		If nTelTot > nValTot
			lRet := !U_BlqDoc(nTelTot,.T.)	
			If !lRet 
				Alert("Este Doc já foi liberado no valor de "+ALLTRIM(STR(nValTot,2))+", exclua este documento.")
				lMT100TOK := .T.
			EndIf 

		EndIf
		
	EndIf
		
EndIf	

Return lRet
