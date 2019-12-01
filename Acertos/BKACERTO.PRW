#include "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
Programa     : PAACERTO - Autor: Marcos B. Abrahao - Data: 10/06/2009
Objetivo     : Acertos diversos 
Uso          : Proqualit
/*/

User Function BKACERTO()
Private nRepl := 0

@ 200,01 TO 285,450 DIALOG oDlg1 TITLE "Acerto campos SZ2"
//@ 15,015 SAY "Arquivo: "
//@ 15,046 GET cArq SIZE 180,10
@ 30,060 BMPBUTTON TYPE 01 ACTION ProcImp()   
@ 30,110 BMPBUTTON TYPE 02 ACTION Close(Odlg1)

ACTIVATE DIALOG oDlg1 CENTER

RETURN


Static FUNCTION ProcImp()
If MsgBox("Confirma a execução do processo?","PQACERTO","YESNO")
   Processa( {|| AcSZ2() } )
Endif   
MSGBOX("Registros alterados: "+STR(nRepl,6),"PQACERTO","INFO")

Close(oDlg1)
Return



Static Function AcSz2()

dbSelectArea("SZ2")
dbGoTop()
DO WHILE !EOF()
   RecLock("SZ2",.F.)
   SZ2->Z2_E2PRF := SUBSTR(SZ2->Z2_TITULO,3,3)
   SZ2->Z2_E2NUM := SUBSTR(SZ2->Z2_TITULO,6,9)
   SZ2->Z2_E2PARC:= SUBSTR(SZ2->Z2_TITULO,15,2)
   SZ2->Z2_E2TIPO:= SUBSTR(SZ2->Z2_TITULO,17,3)
   SZ2->Z2_E2FORN:= SUBSTR(SZ2->Z2_TITULO,20,6)
   SZ2->Z2_E2LOJA:= SUBSTR(SZ2->Z2_TITULO,26,2)
   nRepl++
   MsUnlock()
   dbSkip()
ENDDO
Return Nil
