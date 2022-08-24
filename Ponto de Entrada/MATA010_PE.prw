#Include "Protheus.ch" 
/*/{Protheus.doc} MATA010_PE
BK - Ponto de entrada MVC - Cadastro de Produtos
@Return
@author Marcos Bispo Abrahão
@since 24/08/2022
@version P12.33
/*/
 
User Function ITEM() 
    Local aParam := PARAMIXB 
    Local xRet := .T. 
    Local oObj := Nil 
    Local cIdPonto := ""
    Local cIdModel := ""
    Local nOper := 0 
    Local cCod  := ""
    //Local cCampo := ""
    //Local cTipo := ""
    //Local lEnd

    Local oModel
    Local oModelSB1
 
    //Se tiver parâmetros
    If aParam != Nil 
        ConOut("> "+aParam[2]) 
 
        //Pega informações dos parâmetros
        oObj := aParam[1] 
        cIdPonto := aParam[2] 
        cIdModel := aParam[3] 
 
        //Valida a abertura da tela
        If cIdPonto == "MODELVLDACTIVE"
            xRet := .T. 
            //nOper := oObj:nOperation
 
            //Pré configurações do Modelo de Dados
        ElseIf cIdPonto == "MODELPRE"
            xRet := .T. 
 
            //Pré configurações do Formulário de Dados
        ElseIf cIdPonto == "FORMPRE"
            xRet := .T. 
 
            //nOper := oObj:GetModel(cIdPonto):nOperation
            //cTipo := aParam[4]
            //cCampo := aParam[5]
 
            //Se for Alteração
            //If nOper == 4
            //Não permite alteração dos campos
            //    If cTipo == "CANSETVALUE" .And. Alltrim(cCampo) $ ("CAMPO1;CAMPO2;CAMPO3")
            //        xRet := .F.
            //    EndIf
            //EndIf
 
            //Adição de opções no Ações Relacionadas dentro da tela

            // Copy
            /*
            If cIdModel == "SB1MASTER"
                oModelX := FwModelActive()// Instancia modelo ativo
                //oModelB1 := oModelX:GetModel("SB1MASTER") //Instancia sub-modelo SB1
                
                If oModelX:IsCopy() //Verifica se é uma operação de copia
                
                    // CUSTOMIZAÇÕES DO USUÁRIO (VALIDAÇÃO DE CAMPO, INSERÇÃO DE VALORES E ETC)
                
                    //MsgInfo("FORMPRE - Operação de cópia","MATA010_PE")
                    Public B1_XXCODCP := SB1->B1_COD
                    xRet := .T.//Mantem o retorno para validação FORMPOS como .T., alterar se for necessário 
                EndIf
            EndIf
            */

        ElseIf cIdPonto == "BUTTONBAR"
            xRet := {}
            //aAdd(xRet, {"* Titulo 1", "", {|| Alert("Botão 1")}, "Tooltip 1"})
            //aAdd(xRet, {"* Titulo 2", "", {|| Alert("Botão 2")}, "Tooltip 2"})
            //aAdd(xRet, {"* Titulo 3", "", {|| Alert("Botão 3")}, "Tooltip 3"})
 
            //Pós configurações do Formulário
        ElseIf cIdPonto == "FORMPOS"
            nOper := oObj:GetModel(cIdPonto):nOperation
 
            xRet := .T. 
            /*
            If nOper == 3 .OR. nOper == 4
                //Validação ao clicar no Botão Confirmar
                oModel		:= FwModelActivate()
                oModelSB1	:= oModel:GetModel('SB1MASTER') 

                cPrefix    	:= ALLTRIM(oModelSB1:GetValue('B1_XPREFIX'))
                cEstruc    	:= ALLTRIM(oModelSB1:GetValue('B1_XESTRUC'))

                If cPrefix == "TOD" .AND. Empty(cEstruc)
                    MsgStop("Para produtos TOD, é obrigatório informar a Estrutura",cIdPonto)
                    xRet := .F.
                EndIf
            EndIf
            */
        ElseIf cIdPonto == "MODELPOS"
            xRet := .T. 
 
            //Pré validações do Commit
        ElseIf cIdPonto == "FORMCOMMITTTSPRE"
 
            //Pós validações do Commit
        ElseIf cIdPonto == "FORMCOMMITTTSPOS"
 
            //Commit das operações (antes da gravação)
        ElseIf cIdPonto == "MODELCOMMITTTS"
 
            //Commit das operações (após a gravação)
        ElseIf cIdPonto == "MODELCOMMITNTTS"
            nOper := oObj:nOperation

            oModel		:= FwModelActivate()
            oModelSB1	:= oModel:GetModel('SB1MASTER') 

            cCod   	:= ALLTRIM(oModelSB1:GetValue('B1_COD'))+"-"+ALLTRIM(oModelSB1:GetValue('B1_DESC'))

            //Mostrando mensagens no fim da operação
            
            If nOper == 3
                u_LogPrw("MATA010_PE","Inclusão do produto "+cCod)                 
            ElseIf nOper == 4  
                u_LogPrw("MATA010_PE","Alteração do produto "+cCod)                 
            ElseIf nOper == 5
                u_LogPrw("MATA010_PE","Exclusão do produto "+cCod)                 
            Else
                u_LogPrw("MATA010_PE","Produto "+cCod+" operação "+STR(nOper))                 
            EndIf
            
        EndIf 
    EndIf 
Return xRet
