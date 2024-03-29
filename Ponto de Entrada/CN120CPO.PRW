#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} CNA130INC
BK - Ponto de Entrada para carregar campos na inclus�o das medi�oes
@Return
@author Marcos B Abrah�o
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


/*/{Protheus.doc} C121LCXN
    Possibilita carregar dados adicionais � CXN(Planilhas da Medi��o) durante sua carga
@since 04/10/2022
@param oModelCXN    , objeto    , inst�ncia de FwFormGrid do submodelo CXN
@param cAliasQry    , caractere , alias com o resultado da query
@return Nil
/*/
User Function C121LCXN()
    Local oModelCXN := PARAMIXB[1]
    Local cAliasQry := PARAMIXB[2]
 
    //Utilizar os campos da query (CN120CPO()) para realizar carga na CXN
    if oModelCXN:HasField("CXN_XXMOT") .And. (cAliasQry)->(FieldPos("CNA_XXMOT") > 0)       
        oModelCXN:LoadValue("CXN_XXMOT", (cAliasQry)->CNA_XXMOT) 
    endif

    if oModelCXN:HasField("CXN_XXMUN") .And. (cAliasQry)->(FieldPos("CNA_XXMUN") > 0)       
        oModelCXN:LoadValue("CXN_XXMUN", (cAliasQry)->CNA_XXMUN) 
    endif

Return Nil


/* Na nova medi��o(CNTA121) n�o h� mais uma tela de sele��o das planilhas, 
   todas elas s�o carregadas para aba Planilhas que cont�m a tabela CXN(Planilhas da Medi��o) 
   para sele��o, por�m durante a carga dos dados ainda � executada a consulta SQL � 
   tabela CNA(Planilhas do Contrato) que era executada anteriormente no CNTA120, 
   dessa forma o ponto de entrada CN120CPO continua tendo um prop�sito, 
   contudo para que os dados da consulta(query) sejam carregadas para CXN � necess�rio a 
   implementa��o do novo ponto de entrada C121LCXN. Com a utiliza��o desse novo ponto 
   de entrada � poss�vel utilizar os dados retornados na consulta para exibi��o no modelo da CXN.
*/

User Function CN120CPO()
Local aResult := {}

// Campos de usu�rio a serem adicionados a query

If CNA->(FieldPos("CNA_XXMOT") > 0)
    aAdd(aResult,"CNA_XXMOT") 
EndIf

If CNA->(FieldPos("CNA_XXMUN") > 0)
    aAdd(aResult,"CNA_XXMUN") 
EndIf

Return aResult


/* Update nos campos anteriores em branco
SELECT CXN_NUMMED,CXN_CONTRA,CNA_CONTRA,CXN_REVISA,CNA_REVISA,CXN_NUMPLA,CNA_NUMERO,
		CXN_XXMUN,CNA_XXMUN

--UPDATE CXN010 SET CXN_XXMUN = CNA_XXMUN, CXN_XXMOT = CNA_XXMOT
FROM CXN010 
LEFT JOIN CNA010 ON
	CXN_CONTRA = CNA_CONTRA AND CXN_REVISA = CNA_REVISA AND CXN_NUMPLA = CNA_NUMERO
	--WHERE CXN_XXMUN = ''
*/



// Ponto de entrada para alterar a pesquisa padr�o de contratos
User Function CN120CMP()
Local ExpA1  := PARAMIXB[1]
Local ExpA2  := PARAMIXB[2]

aAdd(ExpA1, "Descri��o")
aAdd(Expa2, {"CN9_XXDESC",ExpA2[3,2],ExpA2[3,3],ExpA2[3,4]})

Return {ExpA1,ExpA2}



User Function CN120ESY()
Local ExpA1  := PARAMIXB[1]
Local cQuery

// Incluir o campo CN9_XXDESC na query
cQuery := STRTRAN( ExpA1,", CN9_FILCTR",", CN9_FILCTR, CN9_XXDESC")

Return cQuery


// Pesquisa padr�o de contratos na medi��o (n�o usado na nova medi��o)
User Function CN120SXB()
Return "CN9001"


