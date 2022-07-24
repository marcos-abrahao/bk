#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKFINA28
    Alteração de valor de ISS retido indevidamente
    @type  Function
    @author Marcos Bispo Abrahão
    @since 19/07/2022
    @version 12
/*/

User Function BKFINA28()
Local aArea     := Getarea()
Local oOk
Local oNo
Local oDlg
Local oPanelLeft
Local aButtons 	:= {}
Local lOk      	:= .F.
Local cTitulo 	:= "BKFINA28 - Valor ISS Retido Indevidamente: "+SE1->E1_NUM
Local nValII    := SE1->E1_XXISSBI

u_LogPrw("BKFINA28")

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

nLin := 15

DO WHILE .T.	

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 160,550 PIXEL
	@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 530,150
	oPanelLeft:Align := CONTROL_ALIGN_LEFT

	@ nLin+2,070 SAY 'ISS Bitributado Indevidamente:' PIXEL SIZE 100,10 OF oPanelLeft
    @ nLin,195 MSGET oGetDtAdt VAR nValII  OF oPanelLeft PICTURE "@E 99,999,999,999.99" HASBUTTON SIZE 60,10 PIXEL 
	nLin += 25

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , @aButtons)
		
	If ( lOk )
        RecLock("SE1",.F.)
	    SE1->E1_XXISSBI := nValII
		lOk := .F.
        MsUnlock()
	EndIf
	EXIT
	
ENDDO
		                   
Restarea( aArea )
          
RETURN lOk
