#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKFINA31
    Alteração da dados de Títulos de Empréstimos
    @type  Function
    @author Marcos Bispo Abrahão
    @since 15/08/2022
    @version 12
/*/

User Function BKFINA31()
Local aArea			:= Getarea()
Local oOk			AS OBJECT
Local oNo			AS OBJECT
Local oDlg			AS OBJECT
Local oPanelLeft	AS OBJECT
Local aButtons 		:= {}
Local lOk			:= .F.
Local cTitulo		:= "BKFINA31 - Alteração da dados de Títulos de Empréstimo: "+SE2->E2_NUM
Local nPrincipal	:= SE2->E2_XEAMOR
Local nJuros		:= SE2->E2_XEJUR
Local nIof			:= SE2->E2_XEIOF
Local nTxBanc		:= SE2->E2_XETBANC
Local oPrincipal	AS OBJECT
Local oJuros		AS OBJECT
Local oIOF			AS OBJECT
Local oTxBanc		AS OBJECT


u_LogPrw("BKFINA31")

If SE2->E2_NATUREZ <> '0000000016'
	MsgStop("Opção válida apenas para títulos com natureza 0000000016","BKFINA31")
	Return Nil
EndIf

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

nLin := 15

DO WHILE .T.	

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 300,550 PIXEL
	@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 530,300
	oPanelLeft:Align := CONTROL_ALIGN_LEFT

	@ nLin+2,070 SAY 'Valor Principal:' PIXEL SIZE 60,10 OF oPanelLeft
    @ nLin,145 MSGET oPrincipal VAR nPrincipal OF oPanelLeft PICTURE "@E 999,999,999.99" HASBUTTON SIZE 50,10 PIXEL 
	nLin += 15

	@ nLin+2,070 SAY 'Juros:' PIXEL SIZE 60,10 OF oPanelLeft
    @ nLin,145 MSGET oJuros VAR nJuros OF oPanelLeft PICTURE "@E 999,999,999.99" HASBUTTON SIZE 50,10 PIXEL 
	nLin += 15

	@ nLin+2,070 SAY 'IOF:' PIXEL SIZE 60,10 OF oPanelLeft
    @ nLin,145 MSGET oIOF VAR nIOF OF oPanelLeft PICTURE "@E 999,999,999.99" HASBUTTON SIZE 50,10 PIXEL 
	nLin += 15

	@ nLin+2,070 SAY 'Taxas Bancarias:' PIXEL SIZE 60,10 OF oPanelLeft
    @ nLin,145 MSGET oTxBanc VAR nTxBanc OF oPanelLeft PICTURE "@E 999,999,999.99" HASBUTTON SIZE 50,10 PIXEL 
	nLin += 15

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , @aButtons)
		
	If ( lOk )
        RecLock("SE2",.F.)
		SE2->E2_XEAMOR	:= nPrincipal
		SE2->E2_XEJUR	:= nJuros
		SE2->E2_XEIOF	:= nIof
		SE2->E2_XETBANC	:= nTxBanc
		lOk := .F.
        MsUnlock()
	EndIf
	EXIT
	
ENDDO
		                   
Restarea( aArea )
          
RETURN lOk
