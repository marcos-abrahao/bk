#INCLUDE "PROTHEUS.CH"

User Function SF2520E() 

Local oDlgEx
Local cMotEx  := SPACE(LEN(SF2->F2_XXMOTEX)) 
Local cAprEx  := SPACE(LEN(SF2->F2_XXAPREX))

Define MsDialog oDlgEx Title "Exclusão da NF "+SF2->F2_DOC From 000,000 To 110,400 Of oDlgEx Pixel Style DS_MODALFRAME

@ 010,005 Say  'Motivo do cancelamento: ' Of oDlgEx Pixel                                  	
@ 010,080 MsGet cMotEx Valid !Empty(cMotEx) Size 110,007 Pixel Of oDlgEx

@ 025,005 Say  'Aprovador do cancelamento: ' Of oDlgEx Pixel                                  	
@ 025,080 MsGet cAprEx Valid !Empty(cAprEx) Picture "@!" Size 070,007 Pixel Of oDlgEx

@ 040,080 Button "&Ok" Size 036,013 Pixel Action (GrvMotEx(cMotEx,cAprEx),oDlgEx:End())
Activate MsDialog oDlgEx Centered

Return Nil


// Grava o Motivo do Estorno
Static Function GrvMotEx(cMotEx,cAprEx)
RecLock("SF2",.F.)
SF2->F2_XXMOTEX := cMotEx
SF2->F2_XXAPREX := cAprEx
MsUnlock("SF2")

//EXCLUI TITULO FUMDIP - OSASCO
U_BKFATA02(5)

Return()

