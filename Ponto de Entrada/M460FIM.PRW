#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} M460FIM
Ponto de entrada para gravar valor de Retenção Contratual no SE1 - BK

@Return
@author Marcos Bispo Abrahão
@since 27/08/2019
@version P11/P12
/*/
//-------------------------------------------------------------------

USER FUNCTION M460FIM()
Local aArea     := GetArea()
Local aAreaSE1  := SE1->(GetArea())
Local cE1Tipo   := ""
Local lBsCsll	:= .F.
Local nBaseCSLL := 0
Local nValCSLL  := 0
Local nAValCSLL := 0
Local aAreaFIV
Local aAreaFJV
Local aAreaSD2
Local aAreaSFT

IF SF2->F2_XXVRETC > 0 .OR. SF2->F2_XXVCVIN > 0
	aAreaSE1  := SE1->(GetArea()) 
	cE1Tipo   := Left(MVNOTAFIS, TamSX3("E1_TIPO")[1]) 
	
	SE1->(dbSetOrder(2)) // SE1->(dbSetOrder(RETORDEM("SE1","E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO")))             
	
 	If SE1->(MsSeek(xFilial("SE1") + SF2->(F2_CLIENTE) + SF2->(F2_LOJA) + SF2->(F2_SERIE) + SF2->(F2_DOC) + SPACE(LEN(SE1->E1_PARCELA))+cE1Tipo,.T.))     
		SE1->(RECLOCK("SE1",.F.))
		SE1->E1_XXVRETC	:= SF2->F2_XXVRETC
		SE1->E1_XXVCVIN := SF2->F2_XXVCVIN
		SE1->(MSUNLOCK())
	ENDIF 
	SE1->(RestArea(aAreaSE1))
ENDIF

// Recalculo da Base do CSLL - 07/06/22 - Solicitado pelo Sr.Pierre (MANTER DESATIVADO ESTE CÓDIGO)
If lBsCsll .AND. SF2->F2_VALCSLL > 0 .AND. SF2->F2_BASCSLL <> SF2->F2_VALMERC
	// Acerta a Base do CSLL retido
	aAreaSE1  := SE1->(GetArea()) 
	
	cE1Tipo   := Left(MVNOTAFIS, TamSX3("E1_TIPO")[1]) 
	nAValCSLL := SF2->F2_VALCSLL
	nBaseCSLL := SF2->F2_VALMERC
	nValCSLL  := ROUND(SF2->F2_VALMERC * 1 /100,2)   // Considerar o CSLL 1%

	// Alterar a tabela SF2 - Cabeçalho das NF de Saída
	SF2->(RECLOCK("SF2",.F.))
	SF2->F2_VALCSLL := nValCSLL
	SF2->F2_BASCSLL := nBaseCSLL
	SF2->(MSUNLOCK())

	// Alterar a tabela SE1 - Contas a Receber
	SE1->(dbSetOrder(2)) // SE1->(dbSetOrder(RETORDEM("SE1","E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO")))             
	
 	If SE1->(MsSeek(xFilial("SE1") + SF2->(F2_CLIENTE) + SF2->(F2_LOJA) + SF2->(F2_SERIE) + SF2->(F2_DOC) + SPACE(LEN(SE1->E1_PARCELA))+cE1Tipo,.T.))     
		SE1->(RECLOCK("SE1",.F.))
		SE1->E1_CSLL	:= nValCSLL
		SE1->E1_BASECSL := nBaseCSLL
		SE1->(MSUNLOCK())
	ENDIF 

 	If SE1->(MsSeek(xFilial("SE1") + SF2->(F2_CLIENTE) + SF2->(F2_LOJA) + SF2->(F2_SERIE) + SF2->(F2_DOC) + SPACE(LEN(SE1->E1_PARCELA))+"CS-",.T.))     
		SE1->(RECLOCK("SE1",.F.))
		SE1->E1_VALOR	:= nValCSLL
		SE1->E1_SALDO	:= nValCSLL
		SE1->E1_VLCRUZ	:= nValCSLL
		SE1->(MSUNLOCK())

		// Alterar a tabela FIV - MOVIMENTOS DIARIOS P/NATUREZA 
		aAreaFIV  := FIV->(GetArea()) 
		FIV->(dbSetOrder(1)) // FIV_FILIAL+FIV_NATUR+FIV_MOEDA+FIV_TPSALD+FIV_CARTEI+DTOS(FIV_DATA)
		If FIV->(MsSeek(xFilial("FIV") + PAD("CSLL",TamSX3("FIV_NATUR")[1])+"01"+"2"+"R"+DTOS(SE1->E1_VENCREA),.T.))
			FIV->(RECLOCK("FIV",.F.))
			FIV->FIV_VALOR := FIV->FIV_VALOR - nAValCSLL
			FIV->FIV_VALOR := FIV->FIV_VALOR + nValCSLL
			FIV->(MSUNLOCK())
		EndIf

		// Alterar a tabela FJV - Movimento Analitico P/Natureza
		aAreaFJV  := FJV->(GetArea()) 
		FJV->(dbSetOrder(1)) // FJV_FILIAL+FJV_NATUR+FJV_MOEDA+FJV_TPSALD+FJV_CARTEI+DTOS(FJV_DATA)
		If FJV->(MsSeek(xFilial("FJV") + PAD("CSLL",TamSX3("FJV_NATUR")[1])+"01"+"2"+"R"+DTOS(SE1->E1_VENCREA),.T.))
			FJV->(RECLOCK("FJV",.F.))
			FJV->FJV_VALOR := FJV->FJV_VALOR - nAValCSLL
			FJV->FJV_VALOR := FJV->FJV_VALOR + nValCSLL
			FJV->(MSUNLOCK())
		EndIf
	ENDIF 

	// Alterar a tabela SD2 - Itens de Venda da NF
	aAreaSD2  := SD2->(GetArea()) 
	SD2->(dbSetOrder(3))
	If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		aItens := {}
		While SD2->(!Eof()) .And. xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA==xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
			SD2->(RECLOCK("SD2",.F.))
			SD2->D2_BASECSL := SD2->D2_TOTAL
			SD2->D2_VALCSLL := ROUND(SD2->D2_BASECSL * 1 /100,2)   // Considerar o CSLL 1%

			SD2->(MSUNLOCK())
			SD2->(dbSkip())
		Enddo 
	Endif 

	// Alterar a tabela SFT - Livro Fiscal por Item de NF   
	aAreaSFT  := SFT->(GetArea()) 
	SFT->(dbSetOrder(1))
	SFT->(dbSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA))
	While !SFT->(EOF()) .And. SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == xFilial("SFT")+"S"+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA
		SFT->(RECLOCK("SFT",.F.))
		SFT->FT_BRETCSL := SFT->FT_VALCONT
		SFT->FT_VRETCSL := SFT->FT_BRETCSL * SFT->FT_ARETCSL /100
		SFT->(MSUNLOCK())		
		SFT->(dbSkip())
	EndDo

	/*
	// Alterar a tabela CD2 - Livro digital de Impostos-SPED
	If !(cAliasSD2)->D2_TIPO $ "DB"
		CD2->(dbSetOrder(1))
	Else
		CD2->(dbSetOrder(2))
	EndIf	   
	CD2->(DbSeek(xFilial("CD2")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA+PadR((cAliasSD2)->D2_ITEM,4)+(cAliasSD2)->D2_COD))
	While !Eof() .And. xFilial("CD2") == CD2->CD2_FILIAL .And.;
			"S" == CD2->CD2_TPMOV .And.;
			SF2->F2_SERIE == CD2->CD2_SERIE .And.;
			SF2->F2_DOC == CD2->CD2_DOC .And.;
			SF2->F2_CLIENTE == IIF(!(cAliasSD2)->D2_TIPO $ "DB",CD2->CD2_CODCLI,CD2->CD2_CODFOR) .And.;
			SF2->F2_LOJA == IIF(!(cAliasSD2)->D2_TIPO $ "DB",CD2->CD2_LOJCLI,CD2->CD2_LOJFOR) .And.;
			(cAliasSD2)->D2_ITEM == SubStr(CD2->CD2_ITEM,1,Len((cAliasSD2)->D2_ITEM)) .And.;
			(cAliasSD2)->D2_COD == CD2->CD2_CODPRO
		dbSelectArea("CD2")
		dbSkip()
	EndDo
	*/


	// Restaurar as áreas envolvidas
	SFT->(RestArea(aAreaSFT))
	SD2->(RestArea(aAreaSD2))
	FJV->(RestArea(aAreaFJV))
	FIV->(RestArea(aAreaFIV))
	SE1->(RestArea(aAreaSE1))
EndIf

RestArea(aArea)

RETURN NIL
