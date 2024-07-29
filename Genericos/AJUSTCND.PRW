#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH"                     
#INCLUDE "TBICONN.CH"
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} BKTestes
BK - Acertos diversos
@Return
@author Marcos B. Abrahao
@since 29/01/2011
@version P12
/*/
//-------------------------------------------------------------------


User Function AJUSTCND()
LOCAL dDia := CTOD("")
LOCAL cCompAM  := ""  


DBSELECTAREA("CN9")
CN9->(DBSETORDER(1))
If CN9->(DBSEEK(xFILIAL("CN9"),.T.))
	Do While CN9->(!eof()) 
		If CN9->CN9_SITUAC <> '10' .AND. CN9->CN9_SITUAC <> '09'

            DBSELECTAREA("CND")
            CND->(DBSETORDER(1))
            CND->(DBSEEK(xFILIAL("CND")+CN9->CN9_NUMERO,.F.))
            DO While CND->(!eof()) .AND. CND->CND_CONTRA==CN9->CN9_NUMERO

                IF CND->CND_CONTRA==CN9->CN9_NUMERO
                    // Contratos que devem ser faturados até o quinto dia util do mes subsequente a competencia
                    If CN9->CN9_XX5DIA == 'S'
                        dDia := CTOD("") 
                        cCompAM := ""
                        cCompAM := SUBSTR(CND->CND_COMPET,4,4)+SUBSTR(CND->CND_COMPET,1,2)   
                        dDia := STOD(cCompAM+"01")
                        dDia := MonthSum(dDia,1)
                        dDia := DataValida(dDia+1)
                        dDia := DataValida(dDia+1)
                        dDia := DataValida(dDia+1)
                        dDia := DataValida(dDia+1)
                        If CND->CND_DTINIC > dDia
                            RecLock("CND",.F.)
                            CND->CND_XX5DIA := "S"
                            CND->(MsUnLock())
                        Else
                            RecLock("CND",.F.)
                            CND->CND_XX5DIA := "N"
                            CND->(MsUnLock())
                        EndIf
                    Else
                        RecLock("CND",.F.)
                        CND->CND_XX5DIA := "N"
                        CND->(MsUnLock())
                    EndIf
                ENDIF
                CND->(dbSkip())
            EndDo
        ENDIF

    CN9->(dbSkip())
    EndDo
ENDIF            
MSGINFO("Finalizado!")

RETURN NIL
