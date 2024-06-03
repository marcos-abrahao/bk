//Bibliotecas

#Include "Protheus.ch"

USER Function DeprContrat()
Local nPERC     := 0
Local dDVIG     := CTOD("")
Local dtAQUI    := M->N1_AQUISIC
Local cGRUPO    := M->N1_GRUPO
Local cContrato := M->N3_CUSTBEM

dbSelectArea("SNG")
SNG->(DBSETORDER(1))
IF SNG->(dbSeek(xFilial("SNG")+cGRUPO,.T.))
    nPERC  := SNG->NG_TXDEPR1
ENDIF

IF !(cGRUPO >= '101' .AND. cGRUPO < '999')
    Return nPERC
ENDIF

IF nPERC == 0
    dbSelectArea("CN9")
    CN9->(DBSETORDER(1))
    IF !CN9->(dbSeek(xFilial("CN9")+cContrato,.T.))
        Return nPERC
    ENDIF
    DO WHILE CN9->(!EOF()) .AND. cContrato == ALLTRIM(xFilial("CN9")+CN9->CN9_NUMERO)
        IF Empty(CN9->CN9_REVATU)
            dDVIG := CN9->CN9_XXDVIG
            Exit
        ENDIF
        CN9->(DBSKIP())
    ENDDO

    nPERC := DateDiffYear(dDVIG,dtAQUI)

    IF nPERC < 2
        nPERC := 100
    ELSE
        nPERC := 100/nPERC
    ENDIF
ENDIF

Return nPERC
