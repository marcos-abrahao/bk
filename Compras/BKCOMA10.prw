#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKCOMA10
    BK - Informar token de liberação na Pré-Nota (gerado pela rotina web RESTLIBPN)
    @type  Function
    @author Marcos Bispo Abrahão
    @since 28/10/2022
    @version 12.1.33
/*/

User Function BKCOMA10()
Local aArea     := Getarea()
Local lOk      	:= .F.
Local cTitulo2 	:= "BKCOMA10 - Token Pré-Nota: "+SF1->F1_DOC
Local cToken    := SPACE(100)
Local aButtons 	:= {}
Local aParams   := {SF1->F1_DOC}
Local cMsg      := ""
Local oGetTk
Local oOk
Local oNo
Local oDlg
Local oPanelLeft

If SF1->F1_XXLIB <> "T" //.OR. SF1->F1_XXLIB <> " "
    u_MsgLog("BKCOMA10","Doc não está com status='Token': "+SF1->F1_DOC,"E")
    Return Nil
EndIf

u_MsgLog("BKCOMA10","Validar token Doc: "+SF1->F1_DOC)

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

nLin := 10

DEFINE MSDIALOG oDlg TITLE cTitulo2 FROM 000,000 TO 150,500 PIXEL
@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 530,230  // P12
oPanelLeft:Align := CONTROL_ALIGN_LEFT

@ nLin,010 SAY 'Token:' PIXEL SIZE 170,10 OF oPanelLeft
@ nLin,040 MSGET oGetTk VAR cToken  OF oPanelLeft SIZE 200,10 PIXEL 
nLin += 25

ACTIVATE MSDIALOG oDlg CENTERED Valid(!Empty(cToken)) ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| lOk:=.F.,oDlg:End()}, , @aButtons)

If lOk
    lOk := u_BKAvPar(cToken,aParams,cMsg)
    If lOk
        If aParams[4] == SF1->F1_DOC
            lOk := .F.
            If SF1->F1_XXLIB == "T" .OR. SF1->F1_XXLIB == " "
                RecLock("SF1",.F.)
                SF1->F1_XXLIB := "9"
                MsUnlock()
                u_MsgLog("BKCOMA10","Token validado - Doc: "+SF1->F1_DOC,"S")
                lOk := .T.
            Else
                u_MsgLog("BKCOMA10","Token não validado - Doc: "+SF1->F1_DOC,"E")
            EndIf
        Else
            u_MsgLog("BKCOMA10","Token invalido - Doc: "+SF1->F1_DOC,"E")
        EndIf
    Else
        u_MsgLog("BKCOMA10","Token invalido - Doc: "+SF1->F1_DOC,"E")
    EndIf
EndIf

Restarea( aArea )
          
RETURN lOk
