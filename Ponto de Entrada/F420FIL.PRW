#include "rwmake.ch"

//O ponto de entrada F420FIL tem como finalidade substituir a expressao de filtragem de titulos.
User Function F420FIL()
Local cRetFil := "" 
Local _aArea	:= GetArea()


dbSelectArea("SEA")
DbSetOrder(1)
DBSEEK(xFilial("SEA")+mv_par01)
While SEA->(!EOF()) .AND. SEA->EA_NUMBOR >= TRIM(mv_par01) .AND.  SEA->EA_NUMBOR <= TRIM(mv_par02)
    IF TRIM(SEA->EA_SITUANT) == "X" .AND. cRetFil # TRIM(SEA->EA_NUMBOR)
       cRetFil += TRIM(SEA->EA_NUMBOR)+"/"
    ENDIF
	SEA->(dbSkip())
Enddo

IF !EMPTY(cRetFil)
	cRetFil :=' TRIM(SE2->E2_NUMBOR) # "'+SUBSTR(cRetFil,1,LEN(cRetFil)-1)+'"'
ENDIF

RestArea(_aArea)

Return cRetFil
                






