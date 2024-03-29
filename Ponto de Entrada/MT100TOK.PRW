#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "topconn.ch"

// Para identificar altera��o em NF alteradas ap�s libera��o
// 07/07/15 - Marcos B Abrah�o

User Function MT100TOK()
Local cQuery2   := ""
Local cAliasD1  := GetNextAlias()
Local nValTot   := 0
Local nTelTot   := 0
Local nPosTotal := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
Local lRet      := .T.
Local lClas     := .F.
Local nI        := 0
Local dDataFis  := SuperGetMv("MV_DATAFIS",.F.)

If lMT100TOK
	lMT100TOK := .F. 
	If Type( "l103Class" ) == "L"
		lClas := l103Class
	EndIf

	// 22/10/20 - Solicitado pelo Jadair
	If Inclui .OR. Altera .OR. lClas
		If dDEmissao <= dDataFis 
			//If !((ALLTRIM(cEspecie)+"/") $ "SPED/CTE/CTEOS/NF3E/NFCE/") .OR. EMPTY(cEspecie)
			If !(ALLTRIM(cEspecie)+"/" $ "SPED/CTE/CTEOS/NF3E/NFCE/") .OR. EMPTY(cEspecie)
				If !u_MsgLog("MT100OK "+cEspecie,"A data de emiss�o deve ser maior que a data de fechamento fiscal: "+DTOC(dDataFis),"Y")
					lRet := .F.
				eNDiF
			EndIf
		EndIf

		If lRet .AND. dDEmissao <= dDataFis
			If !u_MsgLog("MT100OK","Data de emiss�o menor que a data de fechamento fiscal: "+DTOC(dDataFis)+", confirma","N")
				lRet := .F.
			EndIf
		EndIf
	EndIf

	/*
	If Inclui
		If dDEmissao <> dDataBase
			MsgStop("A data de emiss�o deve ser a mesma do sistema","MT100OK")
			lRet := .F.
		EndIf
	ElseIf Altera .OR. lClas
		If dDEmissao <> SF1->F1_EMISSAO
			MsgStop("A data de emiss�o n�o pode ser alterada","MT100OK")
			lRet := .F.
		EndIf
	EndIf
	*/

	If lRet

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
					u_MsgLog("MT100OK","Este Doc j� foi liberado no valor de "+ALLTRIM(STR(nValTot,2))+", exclua este documento.","E")
					lMT100TOK := .T.
				EndIf 

			EndIf
			
		EndIf
	EndIf
EndIf	

Return lRet
