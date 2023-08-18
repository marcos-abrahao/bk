#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} ³BKCOMF01
BK - Funcao para Gerar descrição completa do Produto 
SZI->ZI_XXDESC+SB1->B1_DESC
@Return
@author Adilson do Prado
@since 06/02/13
@version P12
/*/

User Function BKCOMF01(cCodProd)
Local cDescProd  := ""
Local cCodSubPro := ""
Local cDesSubPro := ""

u_MsgLog("BKCOMF01")

cDescProd := ALLTRIM(Posicione("SB1",1,xFilial("SB1")+cCodProd,"B1_DESC"))
cCodSubPro := Posicione("SB1",1,xFilial("SB1")+cCodProd,"B1_XXSGRP")
cDesSubPro := ALLTRIM(Posicione("SZI",1,xFilial("SZI")+cCodSubPro,"ZI_DESC"))

IF ALLTRIM(cDescProd) $ ALLTRIM(cDesSubPro)
	cDescProd  := ALLTRIM(cDescProd)
ELSE
	cDescProd  := ALLTRIM(cDesSubPro+" "+cDescProd)
ENDIF

Return(cDescProd)
