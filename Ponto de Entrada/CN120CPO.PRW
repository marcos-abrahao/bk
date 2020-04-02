#include "rwmake.ch"

/*/{Protheus.doc} CNA130INC
BK - Ponto de Entrada para carregar campos na inclusão das mediçoes

@Return
@author Marcos B Abrahão
@since 01/12/11
@version P11/P12
/*/

User Function C121VCPO()

//Local oStruCND := PARAMIXB[1]
//Local oStruCXN := PARAMIXB[2]
//Local oStruCNE := PARAMIXB[3]

Local X
X:=0

Return

User Function CN120CPO()
Local aCpo  := {"CNA_XXMOT","CNA_XXMUN"}
IF FWIsInCallStack("CNTA121")
    FWFLDPUT("CND_XXMUN",CNA->CNA_XXMUN)
ENDIF
Return aCpo


User Function CN120CMP()

Local aCpo  := {"CNA_XXMOT","CNA_XXMUN"}

Return aCpo           


User Function CN120SXB()
// Pesquisa padrão de contratos na medição
Return "CN9001"


