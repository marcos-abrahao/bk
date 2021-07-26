#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

User Function NumSf1()
Local _nI := 1
Local _lRet := .T.
// Numero sequencial DNF - BK (doc de entrada)
If !FWIsInCallStack("MSEXECAUTO")   //ALLTRIM(ProcName(9)) <> "MSEXECAUTO" // MSEXECAUTO da funcao BKCOMA03 - Inclusao Benefícios VT/VR/VA Pré-Documento de Entrada e Assistência Médica
	If VAL(cNFiscal) == 0 
		If cSerie == "DNF"
			If !SX6->(DBSEEK("  MV_XXNUMF1",.F.))
				RecLock("SX6",.T.)
				SX6->X6_VAR     := "MV_XXNUMF1"
				SX6->X6_TIPO    := "N"
				SX6->X6_DESCRIC := "Numero sequencial DNF - "+ALLTRIM(FWEmpName(cEmpAnt))+" (doc de entrada)"
				SX6->X6_CONTEUD := STRZERO(_nI,9)
				SX6->(MsUnlock())
			Else
				RecLock("SX6",.F.)
				_nI := VAL(SX6->X6_CONTEUD)+1
				SX6->X6_CONTEUD := STRZERO(_nI,9)
				SX6->(MsUnlock())
			EndIf
			cNFiscal := STRZERO(_nI,9)
		Else
			_lRet := .F.
			MsgStop("Número do Documento não pode ser zero","NumSf1")
		EndIf
	EndIf
ENDIF
Return _lRet



User Function ExistNF()
Local lOk     := .T.
Local cQuery1 := ""
Local cXDOC    := ""
Local cXSerie  := ""
Local cXFORNECE:= ""
Local cXLoja   := ""


cXDOC     := CNFISCAL
cXSerie   := CSERIE
cXFORNECE := CA100FOR
cXLoja    := IIF(!EMPTY(CLOJA),CLOJA,"01")
                                                     
cQuery1 := "Select F1_DOC,F1_SERIE"
cQuery1 += " FROM "+RETSQLNAME("SF1")+" SF1" 
cQuery1 += " where SF1.D_E_L_E_T_='' AND SF1.F1_FILIAL='"+xFilial('SF1')+"'  AND SF1.F1_DOC='"+cXDOC+"' "
cQuery1 += " AND SF1.F1_FORNECE='"+cXFORNECE+"' AND SF1.F1_LOJA='"+cXLoja+"' AND SF1.F1_SERIE<>'"+cXSerie+"'"
        
        
TCQUERY cQuery1 NEW ALIAS "TMPSF1"

dbSelectArea("TMPSF1")
TMPSF1->(dbGoTop())
DO While !TMPSF1->(EOF())
	lOk := .F.
	cXSerie := TMPSF1->F1_SERIE
	TMPSF1->(dbskip())
Enddo
TMPSF1->(DbCloseArea())

IF !lOk
	IF MSGNOYES("Já existe a NF "+cXDoc+" lançada para o Fornecedor "+cXFORNECE+" com a série: "+cXSerie+"! Incluir assim mesmo?")
		lOk := .T.
	ENDIF
ENDIF

Return lOk


