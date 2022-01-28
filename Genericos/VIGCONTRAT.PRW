//Bibliotecas
#Include "Protheus.ch"

USER Function VigContrat(cContrato,dDVIG)
Local cContRev := ""

dbSelectArea("CN9")
CN9->(DBSETORDER(1))
CN9->(dbSeek(xFilial("CN9")+cContrato,.T.))
cContrato := ALLTRIM(xFilial("CN9")+CN9->CN9_NUMERO)
DO WHILE CN9->(!EOF()) .AND. cContrato == ALLTRIM(xFilial("CN9")+CN9->CN9_NUMERO)
	IF Empty(CN9->CN9_REVATU)
		cContRev := CN9->CN9_FILIAL+CN9->CN9_NUMERO+CN9->CN9_REVISA
	ENDIF
	CN9->(DBSKIP())
ENDDO

// Buscar o ultimo vencto dos Cronogramas
dbSelectArea("CNF")
CNF->(DBSETORDER(3))
CNF->(dbSeek(cContRev,.T.))
Do While !EOF() .AND. ALLTRIM(cContRev) == ALLTRIM(CNF->CNF_FILIAL+CNF->CNF_CONTRA+CNF->CNF_REVISA)
	IF dDVIG < CNF->CNF_DTVENC
		dDVIG := CNF->CNF_DTVENC
	ENDIF
	CNF->(dbSkip())
EndDo

Return dDVIG
