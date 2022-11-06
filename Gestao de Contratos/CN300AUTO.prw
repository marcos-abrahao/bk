#Include "Protheus.CH"
#Include "FWMVCDEF.CH"
  
User Function CN300AUTO()
Local oModel    := Nil
Local cContra   := "005000114"
  
Local cTipRev   := "015" // NÚMERO_DA_REVISAO_ABERTA
Local cJustific := "Justificativa da revisão aberta do contrato"
//Local cCond     := "CONDICAO_DE_PAGAMENTO"
  
Local lRet      := .F.
  
//=== Preparação do contrato para revisão =============================================================================================
DbSelectArea("CN9")
CN9->(DBSetOrder(1))
If CN9->(DbSeek(xFilial("CN9")+cContra))             //- Posicionamento no contrato que será revisado.
    Do While !EOF() .AND. TRIM(CN9_NUMERO) == cContra .AND. !EMPTY(CN9->CN9_REVATU)
        dbSkip()
    EndDo
EndIf

If TRIM(CN9_NUMERO) == cContra .AND. EMPTY(CN9->CN9_REVATU)

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
 
    //oModel:SetValue( 'CXMDETAIL'    ,'CXM_VLMAX'   , 1000)       //- Alterando o valor máximo do agrupador de estoque

    oModelCNA:= oModel:getModel("CNADETAIL")
    oModelCNB:= oModel:getModel("CNBDETAIL")


    //Setando a linha atual das Planilhas
    oModelCNA:AddLine()
    //nLin := Len(oModelGrid:aCols)
    oModelCNA:SetValue("CNADETAIL", 'CNA_XXMOT', 'Motivo teste') 
    //oModelCNA:SetValue("CNADETAIL", 'A5_NOMPROD', oDet[nX]:_Prod:_xProd:TEXT)            
    oModelCNA:SetValue("CNADETAIL", 'CNA_CLIENT', '000005') 
    oModelCNA:SetValue("CNADETAIL", 'CNA_LOJACL', '01') 
    oModelCNA:SetValue("CNADETAIL", 'CNA_TIPPLA', '001') 
    oModelCNA:SetValue("CNADETAIL", 'CNA_FLREAJ', '2') 
    oModelCNA:SetValue("CNADETAIL", 'CNA_XXTPNF', 'N') 
    oModelCNA:SetValue("CNADETAIL", 'CNA_XXUF', 'SP') 
    oModelCNA:SetValue("CNADETAIL", 'CNA_XXCMUN', '50308') 
    oModelCNA:SetValue("CNADETAIL", 'CNA_XXMUN', 'SAO PAULO - TESTE') 
    //oModelCNA:SetValue("CNADETAIL", 'CNA_XXRISS', ' ') 
    oModelCNA:SetValue("CNADETAIL", 'CNA_XXTIPO', '2') 
    //oModelCNA:SetValue("CNADETAIL", 'CNA_XXNAT', ' ') 

    oModelCNB:AddLine()
    oModelCNB:SetValue("CNBDETAIL", 'CNB_PRODUT', '000000000000068') 
    oModelCNB:SetValue("CNBDETAIL", 'CNB_QUANT', 12) 
    oModelCNB:SetValue("CNBDETAIL", 'CNB_VLUNIT', 1000) 

    //== Validação e Gravação do Modelo
    lRet := oModel:VldData() 
    If lRet
        lRet := oModel:CommitData()
    Endif
else
    MsgStop("Contrato não encontrado")
EndIf
   
Return lRet    
