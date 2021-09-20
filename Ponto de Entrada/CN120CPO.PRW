#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} CNA130INC
BK - Ponto de Entrada para carregar campos na inclusão das mediçoes
@Return
@author Marcos B Abrahão
@since 01/12/11
@version P11/P12
/*/

User Function C121VCPO()
//Local oStruCND := PARAMIXB[1]
Local oStruCXN := PARAMIXB[2]
//Local oStruCNE := PARAMIXB[3]
//Local bBloc

//bBloc:=FWBuildFeature(STRUCT_FEATURE_VALID,"U_CNACPOS(), .T.")
//oStruCXN:SetProperty("CXN_XXMUN", MODEL_FIELD_INIT, {|| "X"} ) 
//oStruCXN:SetFieldAction( "CXN_CHECK"   , {|| M->CXN_XXMUN  := "x"} )    

oStruCXN:SetProperty("CXN_XXOBS", MODEL_FIELD_WHEN, {|| .T.} ) 
oStruCXN:SetProperty("CXN_ZERO", MODEL_FIELD_WHEN, {|| .T.} ) 
Return


User Function CN120CPO()
Local aCpo  := {}

// Esta sendo executado na nova medição

IF FWIsInCallStack("CNTA121")
    //aAdd(aCpo,"CXN_XXOBS")
ELSE
    aAdd(aCpo,"CNA_XXMOT")
    aAdd(aCpo,"CNA_XXMUN")
ENDIF

Return aCpo





// Ponto de entrada para alterar a pesquisa padrão de contratos
User Function CN120CMP()
Local ExpA1  := PARAMIXB[1]
Local ExpA2  := PARAMIXB[2]

aAdd(ExpA1, "Descrição")
aAdd(Expa2, {"CN9_XXDESC",ExpA2[3,2],ExpA2[3,3],ExpA2[3,4]})

Return {ExpA1,ExpA2}



User Function CN120ESY()
Local ExpA1  := PARAMIXB[1]
Local cQuery

// Incluir o campo CN9_XXDESC na query
cQuery := STRTRAN( ExpA1,", CN9_FILCTR",", CN9_FILCTR, CN9_XXDESC")

Return cQuery


// Pesquisa padrão de contratos na medição (não usado na nova medição)
User Function CN120SXB()
Return "CN9001"


