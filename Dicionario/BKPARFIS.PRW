#include "Protheus.ch"       
#DEFINE FIN_LAST_UPDATED 		"30/09/2020"

/*/{Protheus.doc} BKPARFIS
BK - Atualização do Parâmetro MV_DATAFIS
@Return
@author Marcos Bispo Abrahão
@since  11/10/12 Frefer
@version P12
/*/

User Function BKPARFIS()
Local odParF as Object
Local oDlg1 as Object

Private dParF
Private aMarcadas := {}
Private cTexto:=""

If PswAdmin(,,__cUserId) > 0
    MsgStop("Função permitida apenas para administradores","BKPARFIS - Data do Fechamento Fiscal")
    Return Nil 
EndIf

dParF  := GETMV("MV_DATAFIS")

DEFINE MSDIALOG oDlg1 TITLE "BKPARFIS - Data limite Fiscal" FROM 200,001 TO 330,470 PIXEL

@ 12,040 SAY "Data limite (MV_DATAFIS):" Size 080,010 Pixel OF oDlg1
@ 10,120 MSGET odParF VAR dParF Size 60,010 HASBUTTON Pixel OF oDlg1

SButton():New( 40, 080,  1, {|| OkPar1(),oDlg1:End() },oDlg1,.T.,"Atualiza os parâmetros")
SButton():New( 40, 120,  2, {|| oDlg1:End() },oDlg1,.T.,"Cancela")

ACTIVATE DIALOG oDlg1 CENTER

RETURN


Static FUNCTION OkPar1()
Local oDlg as Object
Local nI          := 0
Local aAllCompany := {}
Local cMask       := "Arquivos Texto" + "(*.TXT)|*.txt|"
Local cFile       := ""


cTexto += Replicate( "-", 70 ) + CRLF
cTexto += " Data / Hora Inicial.: " + DtoC( Date() ) + " / " + Time()  + " - "+cUserName+ CRLF
cTexto += Replicate( "-", 70 ) + CRLF

aAllCompany := FWAllGrpCompany()
For nI := 1 TO LEN(aAllCompany)
    cTexto += "Empresa: "+aAllCompany[nI]+" - "+FWEmpName(aAllCompany[nI])+ CRLF
    AltX6(aAllCompany[nI])
Next

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


RETURN



STATIC FUNCTION AltX6(cEmpX6)
Local cArqTr := "SX6"+cEmpX6+"0"
// Abre tabela de outra empresa
IF SELECT("SZZX6") > 0
   SELECT SZZX6
   USE
ENDIF
USE (cArqTr) INDEX (cArqTr) ALIAS SZZX6 NEW
SELECT SZZX6
IF DBSEEK("  MV_DATAFIS",.F.)
    If MsgYesNo("Empresa "+FWEmpName(cEmpX6)+CRLF+"Conteudo atual: "+DTOC(STOD(ALLTRIM(SZZX6->X6_CONTEUD)))+CRLF+"Confirma a alteração para "+DTOC(dParF)+"?","Data do fechamento Fiscal")
    	cTexto += "Parametro " + SZZX6->X6_VAR + " conteudo anterior: " + SZZX6->X6_CONTEUD + CRLF

        RecLock("SZZX6",.F.)
        SZZX6->X6_CONTEUD := DTOS(dParF)

        cTexto += "Parametro " + SZZX6->X6_VAR + " conteudo alterado: " + SZZX6->X6_CONTEUD + CRLF
        MsUnlock()
    Else
        cTexto += "Parametro " + SZZX6->X6_VAR + " conteudo mantido:  " + SZZX6->X6_CONTEUD + CRLF
    EndIf
else
    cTexto += "Parametro não encontrado" + CRLF
ENDIF
SELECT SZZX6
USE
RETURN NIL
