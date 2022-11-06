#include "Protheus.ch"       

/*/{Protheus.doc} BKPARISS
BK - Atualização do Parâmetro MV_DEISSBS
ISS sera descontada na base do PIS/COF/CSLL conforme IN 475/04
@Return
@author Marcos Bispo Abrahão
@since  01/06/2022 BK
@version P12
/*/

User Function BKPARISS()
Local oDlg1 as Object
Local oSay  as Object
Local aGrp  := UsrRetGrp()
Local lOk   := .F.
Local nI    := 0
Local oFont := TFont():New('Courier new',,-14,.T.,.T.)

Private lParIss := .F.
Private cTexto  := ""

If cEmpAnt <> '01'
    MsgStop("Válido apenas para a empresa BK!","BKPARISS - Parâmetro MV_DEISSBS")
    Return Nil 
EndIf

For nI := 1 TO Len(aGrp)
    //             Admin /Fatur./Fiscal
	If aGrp[nI] $ "000000/000024/000031"
        lOk := .T.
        Exit 
	EndIf
Next

If !lOk
    MsgStop("Acesso não permitido para este usuário!","BKPARISS - Parâmetro MV_DEISSBS")
    Return Nil 
EndIf

lParIss  := GETMV("MV_DEISSBS")

DEFINE MSDIALOG oDlg1 TITLE "BKPARISS - Data limite Fiscal" FROM 200,001 TO 330,470 PIXEL

@ 12,070 SAY "Situação do parâmetro: (MV_DEISSBS): "+cValToChar( lParIss ) Size 250,010 Pixel OF oDlg1
//@ 10,120 MSGET olParIss VAR lParIss Size 60,010 HASBUTTON Pixel OF oDlg1

oSay := tSay():New(25,100,{ || IIf(lParIss,'DESATIVADO','ATIVADO')},oDlg1,,oFont,,,,.T.,IIf(lParIss,CLR_RED,CLR_BLUE),CLR_WHITE,200,20)

/*
If lParIss
    @ 040,060 BUTTON "Ativar"    SIZE 050, 015 PIXEL OF oDlg1 ACTION (OkPar1(.T.),oDlg1:End())
Else
    @ 040,060 BUTTON "Desativar" SIZE 050, 015 PIXEL OF oDlg1 ACTION (OkPar1(.F.),oDlg1:End())
EndIf
*/

@ 040,130 BUTTON "Sair" SIZE 050, 015 PIXEL OF oDlg1 ACTION (oDlg1:End())

ACTIVATE DIALOG oDlg1 CENTER

Return Nil


Static Function OkPar1(lAtivar)
Local oDlg as Object
Local cMask       := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local cFile       := ""

cTexto += Replicate( "-", 70 ) + CRLF
cTexto += " Data / Hora Inicial.: " + DtoC( Date() ) + " / " + Time()  + " - "+cUserName+ CRLF
cTexto += Replicate( "-", 70 ) + CRLF

If SX6->(DBSEEK("  MV_DEISSBS",.F.))
    RecLock("SX6",.F.)
    If lAtivar
        SX6->X6_CONTEUD := '.F.'
        cTexto += "Parâmetro ativado "+SX6->X6_CONTEUD + CRLF
        u_MsgLog("BKPARISS","Parâmetro ativado "+SX6->X6_CONTEUD)
    Else
        SX6->X6_CONTEUD := '.T.'
        cTexto += "Parâmetro desativado "+SX6->X6_CONTEUD + CRLF
        u_MsgLog("BKPARISS","Parâmetro desativado "+SX6->X6_CONTEUD)
    EndIf
    MsUnlock()
EndIf

cTexto += Replicate( "-", 70 ) + CRLF
cTexto += " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time()  + CRLF
cTexto += Replicate( "-", 70 ) + CRLF

Define Font oFont Name "Mono AS" Size 5, 12

Define MsDialog oDlg Title "Atualizacao concluida." From 3, 0 to 340, 417 Pixel

@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
oMemo:bRClicked := { || AllwaysTrue() }
oMemo:oFont     := oFont

Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

Activate MsDialog oDlg Center

u_BkSnMail("BKPARISS","Parametro desconta ISS da base PIS/COFINS "+IIF(lAtivar,"ativado","desativado"),"microsiga@bkconsultoria.com.br","",STRTRAN(cTexto,CRLF,"<br>"),)

Return Nil

