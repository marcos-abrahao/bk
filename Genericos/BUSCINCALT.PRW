#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BUSCINCALT
BK - BUSCA USER INCLUIU USER ALTEROU E DATA
@Return cRet
@author  Adilson do Prado
@since 15/02/2023
@version P12
/*/

User Function BUSCINCALT(cAlias,nRecno,cCampo,nTipo)
Local cRet      := ""
Local aAreAntes := (cAlias)->(GetArea())


dbSelectArea(cAlias)
(cAlias)->(dbGoTo(nRecno))

cRet  := (cAlias)->(FWLeUserlg(cCampo,nTipo))

RestArea(aAreAntes)

Return cRet
