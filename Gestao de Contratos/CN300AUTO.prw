#Include "Protheus.CH"
#Include "FWMVCDEF.CH"
  
User Function CN300AUTO()
Local oModel    := Nil
Local cContra   := " < NÚMERO_DO_CONTRATO > "
  
Local cTipRev   := "015" // NÚMERO_DA_REVISAO_ABERTA
Local cJustific := "Justificativa da revisão aberta do contrato"
//Local cCond     := "CONDICAO_DE_PAGAMENTO"
  
Local lRet      := .F.
  
//=== Preparação do contrato para revisão =============================================================================================
CN9->(DBSetOrder(1))
If CN9->(DbSeek(xFilial("CN9")+cContra))             //- Posicionamento no contrato que será revisado.
      
    A300STpRev("G")                                 //- Define o tipo de revisão que será realizado.
      
    oModel := FWLoadModel("CNTA300")                //- Carrega o modelo de dados do contrato.
    oModel:SetOperation(MODEL_OPERATION_INSERT)     //- Define operação do modelo. Será INSERIDA uma revisão.
       
    oModel:Activate(.T.)                            //- Ativa o modelo. É necessária a utilização do parâmetro como true (.T.) para realizar uma copia.
  
  
    //=== Preenchimento das alterações da revisão. =======================================================================================
    //== Cabeçalho
    oModel:SetValue( 'CN9MASTER'    , 'CN9_TIPREV' , cTipRev)       //- É obrigatório o preenchimento do tipo de revisão do contrato.
  
    oModel:SetValue( 'CN9MASTER'    , 'CN9_JUSTIF' , cJustific)    //- É obrigatório o preenchimento da justificativa de revisão do contrato.
 
    //oModel:SetValue( 'CN9MASTER'    , 'CN9_CONDPG' , cCond)       //- Nesse exemplo, estamos utilizando a revisão aberta para alterar a condição de pagamento
      
    //== Qualquer alteração possível na execução manual pode ser automatizada.
 
    oModel:SetValue( 'CXMDETAIL'    ,'CXM_VLMAX'   , 1000)       //- Alterando o valor máximo do agrupador de estoque
      
    //== Validação e Gravação do Modelo
    lRet := oModel:VldData() .And. oModel:CommitData()
EndIf
   
Return lRet    
