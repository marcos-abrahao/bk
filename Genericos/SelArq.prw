#include "shell.ch"
#include "fileio.ch"
#include "dbStruct.ch"
#include "RWMAKE.CH"
#include "PRCONST.CH"
#include "PROTHEUS.CH"

User Function SelArq(cArq)

Local cTipo			:= "Arquivo de retorno|*.ret|Arquivo TXT|*.txt"
Local cNewPathArq	:= ""
Default cArq := ""

cNewPathArq := AllTrim( cGetFile (cTipo,"Selecione o arquivo",1,U_DirFile(cArq),.T.,GETF_LOCALHARD,.T.,.T.) )

IF !Empty( cNewPathArq )
	IF Len( cNewPathArq ) > 50
    	ApMsgAlert( "Erro" , "O endereco completo do local onde está o arquivo excedeu o limite de 50 caracteres!")
    	Return ""			
	EndIf
ENDIF

Return(cNewPathArq)


// Retorna o drive+diretorio de um arquivo ou o corrente
User Function DirFile(cArq)
Local cDrive
Local cDir
Local cTempPath	:= GetTempPath(.T.)
IF !EMPTY(cArq)
	SplitPath(cArq,@cDrive,@cDir)
ELSE
	SplitPath(cTempPath,@cDrive,@cDir)	
ENDIF
Return(cDrive+cDir)


/* 
Exemplo
user function fDividePath()
   Local cPatharq := "C:\TEMP\DOC\DOCUMENTO.TXT"
   Local cDrive, cDir, cArq, cExt
   SplitPath( cPatharq, @cDrive, @cDir, @cArq, @cExt )
   msgalert(cDrive +chr(10)+ cDir +chr(10)+ cArq +chr(10)+ cExt, "Função SplitPath")
return
*/

