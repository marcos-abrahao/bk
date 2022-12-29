#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} SF2520E
	BK - Informar o responsável pelo cancelamento da NF
	@type  Function
	@author Marcos Bispo Abrahão
	@since 
	@version version
	/*/

User Function SF2520E() 
Local aArea 	:= GetArea()
Local aAreaSF3	:= SF3->(GetArea("SF3"))
Local aAreaSFT  := SFT->(GetArea()) 

//Local oDlgEx
Local cMotEx	:= PAD("SISTEMA",LEN(SF2->F2_XXMOTEX)) 
Local cAprEx	:= PAD(cUserName,LEN(SF2->F2_XXAPREX))
Private aMCanc  := U_StringToArray(GetSx3Cache("F2_XXMCANC", "X3_CBOX"),";") 
Private cMCanc  := iIf(Len(aMCanc) > 0 ,aMCanc[1],'1')

Define MsDialog oDlgEx Title "Exclusão da NF "+SF2->F2_DOC From 000,000 To 140,400 Of oDlgEx Pixel Style DS_MODALFRAME

@ 010,005 Say  'Obs. do cancelamento: ' Of oDlgEx Pixel                                  	
@ 010,080 MsGet cMotEx Valid !Empty(cMotEx) Picture "@!" Size 110,007 Pixel Of oDlgEx

@ 025,005 Say  'Motivo do cancelamento: ' Of oDlgEx Pixel                                  	
@ 025,080 COMBOBOX cMCanc ITEMS aMCanc SIZE 100,010 Pixel Of oDlgEx VALID(Pertence("12345"))

@ 040,005 Say  'Aprovador do cancelamento: ' Of oDlgEx Pixel                                  	
@ 040,080 MsGet cAprEx Valid !Empty(cAprEx) Picture "@!" Size 070,007 Pixel Of oDlgEx

@ 055,080 Button "&Ok" Size 036,013 Pixel Action (GrvMotEx(cMotEx,cAprEx,cMCanc),oDlgEx:End())
Activate MsDialog oDlgEx Centered

GrvMotEx(cMotEx,cAprEx)

dbSelectArea("SF3")
dbSetOrder(4)
If DbSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
	If "CANCEL" $ SF3->F3_OBSERV .AND. SF3->F3_TIPO =="S"

		aAreaSFT  := SFT->(GetArea()) 
		SFT->(dbSetOrder(1))
		SFT->(dbSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA))
		Do While !SFT->(EOF()) .And. SFT->FT_FILIAL+SFT->FT_TIPOMOV+SFT->FT_SERIE+SFT->FT_NFISCAL+SFT->FT_CLIEFOR+SFT->FT_LOJA == xFilial("SFT")+"S"+SF3->F3_SERIE+SF3->F3_NFISCAL+SF3->F3_CLIEFOR+SF3->F3_LOJA
			SFT->(Reclock("SFT",.F.))
        	SFT->(dbDelete())
			SFT->(Msunlock())		
			SFT->(dbSkip())
		EndDo

		Reclock("SF3",.F.)
        SF3->(dbDelete())
		SF3->(Msunlock())

	EndIf
EndIf

SF3->(RestArea(aAreaSF3))
SFT->(RestArea(aAreaSFT))

RestArea(aArea)
Return Nil


// Grava o Motivo do Estorno
Static Function GrvMotEx(cMotEx,cAprEx,cMCanc)
RecLock("SF2",.F.)
SF2->F2_XXMOTEX := cMotEx
SF2->F2_XXAPREX := cAprEx
SF2->F2_XXMCANC := cMCanc
MsUnlock("SF2")

//EXCLUI TITULO FUMDIP - OSASCO
IF SF2->F2_XXVFUMD > 0
	U_BKFATA02() 
ENDIF

Return()

