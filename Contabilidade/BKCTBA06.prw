#INCLUDE "PROTHEUS.CH"
 
/*/{Protheus.doc} BKCTBA06    
Alterção de Lançamento Automático CTBA102
ROTINA NÃO INCLUIDA EM MENUS 

@author Marcos Bispo Abrahão
@since 03/05/2021
@version 12.25
/*/
 
User Function BKCTBA06()
 
Local nRec          := 0
Local aArea         := GetArea()
Local aCab          := {}
Local aItens        := {}
Local aLinha        := {}
Local cLinha        := '001'
Local cDebito       := ""
Local cCredito      := ""
 
Local cContaDe      := "11102001"
Local cContaPara    := "11102002"

Local cArqLog		:= "\LOG\BKCTBA06-"+cEmpAnt+".LOG"
Local cErrLog       := ""

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private CTF_LOCK    := 0
Private lSubLote    := .T.

u_MsgLog("BKCTBA06")

dbselectArea("CT2")
//dbGoTo(13069)
dbGoTop()

Do While !CT2->(Eof())

    cDebito     := CT2->CT2_DEBITO
    cCredito    := CT2->CT2_CREDIT

    If  CT2->CT2_DATA >= CTOD("07/01/2021") .AND. (AllTrim(cDebito) == cContaDe .OR. AllTrim(cCredito) == cContaDe)

        nRec   := CT2->(RECNO())
        aCab   := {}
        aItens := {}
        aLinha := {}
    
        aAdd(aCab,  {'DDATALANC'     ,CT2->CT2_DATA    ,NIL} )
        aAdd(aCab,  {'CLOTE'         ,CT2->CT2_LOTE    ,NIL} )
        aAdd(aCab,  {'CSUBLOTE'      ,CT2->CT2_SBLOTE  ,NIL} )
        aAdd(aCab,  {'CDOC'          ,CT2->CT2_DOC     ,NIL} )
        aAdd(aCab,  {'CPADRAO'       ,''               ,NIL} )
        aAdd(aCab,  {'NTOTINF'       ,0                ,NIL} )
        aAdd(aCab,  {'NTOTINFLOT'    ,0                ,NIL} )
    
        
        cLinha      := CT2->CT2_LINHA

        If AllTrim(cDebito) == cContaDe
            cDebito := cContaPara
        EndIf

        If AllTrim(cCredito) == cContaDe
            cCredito := cContaPara
        EndIf


        aAdd(aItens,{   {'CT2_FILIAL'    ,CT2->CT2_FILIAL ,NIL},;
                        {'CT2_LINHA'     ,cLinha          ,NIL},;
                        {'CT2_MOEDLC'    ,CT2->CT2_MOEDLC ,NIL},;
                        {'CT2_DC'        ,CT2->CT2_DC     ,NIL},;
                        {'CT2_DEBITO'    ,cDebito         ,NIL},;
                        {'CT2_CREDIT'    ,cCredito        ,NIL},;
                        {'CT2_VALOR'     ,CT2->CT2_VALOR  ,NIL},;
                        {'CT2_ORIGEM'    ,CT2->CT2_ORIGEM ,NIL},;
                        {'CT2_HP'        ,CT2->CT2_HP     ,NIL},;
                        {'CT2_EMPORI'    ,CT2->CT2_EMPORI ,NIL},;
                        {'CT2_FILORI'    ,CT2->CT2_FILORI ,NIL},;                       
                        {'CT2_HIST'      ,CT2->CT2_HIST   ,NIL},;
                        {'LINPOS'        ,'CT2_LINHA'     ,cLinha}})  

        cErrLog := ""
        
        Begin Transaction
            lMsErroAuto := .F.
            MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab ,aItens, 4)

            IF lMsErroAuto
                cErrLog:= CRLF+MostraErro("\LOG\","BKCTBA06.ERR")
                u_xxLog("\LOG\BKCTBA06.LOG",cErrLog)
                MsgStop("Problemas na execução do MsExecAuto, informe o setor de T.I.:"+cErrLog,"Atenção")
                DisarmTransaction()
            Else
                u_xxLog(cArqLog,"Recno: "+STRZERO(nRec,9))            
            EndIf

        End Transaction

        dbSelectArea("CT2")
        dbGoTo(nRec)
    EndIf
    dbSelectArea("CT2")
    dbSkip()
EndDo

RestArea(aArea)

Return
