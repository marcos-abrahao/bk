#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKFINA24
    Alteração da data de Antecipação
    @type  Function
    @author Marcos Bispo Abrahão
    @since 25/02/2022
    @version 12
/*/

User Function BKFINA24()
Local aArea     := Getarea()
Local oOk
Local oNo
Local oDlg
Local oPanelLeft
Local aButtons 	:= {}
Local lOk      	:= .F.
Local cTitulo 	:= "BKFINA24 - Alteração da data de Antecipação: "+SE1->E1_NUM
Local dDtAdt    := SE1->E1_XXDTADT


oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

nLin := 15

DO WHILE .T.	

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 160,550 PIXEL
	@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 530,150
	oPanelLeft:Align := CONTROL_ALIGN_LEFT

	@ nLin+2,070 SAY 'Data de Antecipação:' PIXEL SIZE 60,10 OF oPanelLeft
    @ nLin,145 MSGET oGetDtAdt VAR dDtAdt  OF oPanelLeft PICTURE "@E" HASBUTTON SIZE 50,10 PIXEL 
	nLin += 25

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , @aButtons)
		
	If ( lOk )
        RecLock("SE1",.F.)
	    SE1->E1_XXDTADT := dDtAdt
		lOk := .F.
        MsUnlock()
	EndIf
	EXIT
	
ENDDO
		                   
Restarea( aArea )
          
RETURN lOk
