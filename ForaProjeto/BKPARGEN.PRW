#include "Protheus.ch"       
#DEFINE FIN_LAST_UPDATED 		"30/09/2020"

/*/{Protheus.doc} BKPARGEN
BK - Atualização do Parâmetro MV_DATAFIS
@Return
@author Marcos Bispo Abrahão
@since  21/12/2020
@version P12
/*/

User Function BKPARGEN()
Local oDlg1         as Object
Local oConteud      as Object
Local cTitulo       := "BKPARGEN - Parâmetros empresas"
Local aParam        := {}
Local aRet          := {}

Private aMarcadas   := {}
Private cTexto      := ""
Private cParam      := ""
Private cConteudo   := SPACE(LEN(SX6->X6_CONTEUD))

If PswAdmin(,,__cUserId) > 0
    MsgStop("Função permitida apenas para administradores",cTitulo)
    Return Nil 
EndIf

aAdd( aParam, { 1, "Parametro:"	    , SPACE(LEN(SX6->X6_VAR))  	, ""            , ""   , "SX6", "" , 70  , .F. })

//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If !(Parambox(aParam     ,@cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKPARGEN",.T.         ,.T.))
    Return Nil
EndIf

cParam := mv_par01
If !SX6->(dbSeek("  "+cParam))
    MsgStop("Parametro "+cParam+" não encontrado",cTitulo)
    Return Nil 
EndIf
cConteudo := SX6->X6_CONTEUD


DEFINE MSDIALOG oDlg1 TITLE "BKPARGEN - Parametros Empresas: "+cParam FROM 200,001 TO 300,570 PIXEL

@ 12,10 SAY "Conteúdo:" Size 030,010 Pixel OF oDlg1
@ 10,50 MSGET oConteud VAR cConteudo Size 300,010 HASBUTTON Pixel OF oDlg1

SButton():New( 30, 080,  1, {|| OkPar1(),oDlg1:End() },oDlg1,.T.,"Atualiza os parâmetros")
SButton():New( 30, 120,  2, {|| oDlg1:End() },oDlg1,.T.,"Cancela")

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
IF DBSEEK("  "+cParam,.F.)
    If MsgYesNo("Empresa "+FWEmpName(cEmpX6)+CRLF+"Conteudo atual: "+ALLTRIM(SZZX6->X6_CONTEUD)+CRLF+"Confirma a alteração para "+ALLTRIM(cConteudo)+"?","Parâmetro "+cParam)
    	cTexto += "Parametro " + SZZX6->X6_VAR + " conteudo anterior: " + SZZX6->X6_CONTEUD + CRLF

        RecLock("SZZX6",.F.)
        SZZX6->X6_CONTEUD := cConteudo

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
