#INCLUDE "PROTHEUS.CH"
#INCLUDE "topconn.ch"

User Function NumSf1()
Local lRet := .T.
Local nPar := 0
Local cPar := ""

// Numero sequencial DNF - BK (doc de entrada)

If !FWIsInCallStack("MSEXECAUTO") .AND. !FWIsInCallStack("GERADOCE")  // MSEXECAUTO da funcao BKCOMA03 - Inclusao Benefícios VT/VR/VA Pré-Documento de Entrada e Assistência Médica
	If VAL(cNFiscal) == 0 
		If cSerie == "DNF"
			nPar := GetMv("MV_XXNUMF1",.F.,STRZERO(0,9))
			nPar++
			cPar := STRZERO(nPar,9)
			cNFiscal := cPar
			PutMv("MV_XXNUMF1",cPar)
		Else
			lRet := .F.
			u_MsgLog("NumSf1","Número do Documento não pode ser zero","E")
		EndIf
	EndIf
ENDIF

Return lRet



User Function ExistNF()
Local lOk      := .T.
Local cQuery1  := ""
Local cXDOC    := ""
Local cXSerie  := ""
Local cXFORNECE:= ""
Local cXLoja   := ""

If FWIsInCallStack("GERADOCE")
	// Veio pelo Facilitador de Docs de Entrada BKCOMA16
	Return lOk
EndIf

cXDOC     := CNFISCAL
cXSerie   := CSERIE
cXFORNECE := CA100FOR
cXLoja    := IIF(!EMPTY(CLOJA),CLOJA,"01")
                                                     
cQuery1 := "SELECT F1_DOC,F1_SERIE"
cQuery1 += " FROM "+RETSQLNAME("SF1")+" SF1" 
cQuery1 += " WHERE SF1.D_E_L_E_T_='' AND SF1.F1_FILIAL='"+xFilial('SF1')+"'  AND SF1.F1_DOC='"+cXDOC+"' "
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
	IF u_MsgLog("ExistNF","Já existe a NF "+cXDoc+" lançada para o Fornecedor "+cXFORNECE+" com a série: "+cXSerie+"! Incluir assim mesmo?","Y")
		lOk := .T.
	ENDIF
ENDIF

Return lOk
