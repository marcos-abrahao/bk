#Include "Protheus.ch" 
/*/{Protheus.doc} MATA010_PE
BK - Ponto de entrada MVC - Cadastro de Produtos
@Return
@author Marcos Bispo Abrahão
@since 24/08/2022
@version P12.33
/*/
 
User Function ITEM() 
    Local aParam    := PARAMIXB 
    Local xRet      := .T. 
    Local oObj      := Nil 
    Local cIdPonto  := ""
    Local cIdModel  := ""
    Local nOper     := 0 
    Local cEvento   := ''
    Local cCampo    := ''
    Local cConteudo := ''

    //Se tiver parâmetros
    If aParam != Nil 
        //ConOut("> "+aParam[2]) 
 
        //Pega informações dos parâmetros
        oObj := aParam[1] 
        cIdPonto := aParam[2] 
        cIdModel := aParam[3] 
 
        If cIDPonto == 'FORMPRE'
    
            cEvento     := aParam[4]
            cCampo      := aParam[5]
            cConteudo   := If( ValType(aParam[6]) == 'C',;
                            "'" + aParam[6] + "'",;
                            If( ValType(aParam[6]) == 'N',;
                                AllTrim(Str(aParam[6])),;
                                If( ValType(aParam[6]) == 'D',;
                                    DtoC(aParam[6]),;
                                    If(ValType(aParam[4]) == 'L',;
                                        If(aParam[4], '.T.', '.F.'),;
                                        ''))))
            cIDForm     := oObj:GetID()
    
        ElseIf cIDPonto == 'FORMPOS'
    
            cIDForm     := oObj:GetID()
    
        ElseIf cIDPonto == 'FORMCOMMITTTSPRE' .OR. cIDPonto == 'FORMCOMMITTTSPOS'
    
            cConteudo   := If( ValType(aParam[4]) == 'L',;
                            If( aParam[4], '.T.', '.F.'),;
                            '')
    
        EndIf
 

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
            If __cUserID == "000000"
                aAdd(xRet, {"Substituição de Produto", "", {|| u_BKCOMA01()}, "Somente produtos de compras"})
            EndIf

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
            //Pré validações do Commit

            xRet := .T. 

        ElseIf cIdPonto == "FORMCOMMITTTSPRE"
            //Pós validações do Commit

            MyFTTSPre(oObj, cIDPonto, cIDModel, cConteudo)

        ElseIf cIdPonto == "FORMCOMMITTTSPOS"
 
            //Commit das operações (antes da gravação)
        ElseIf cIdPonto == "MODELCOMMITTTS"
           //Commit das operações (após a gravação)

          // MyMCOMMTTS(oObj, cIDPonto, cIDModel, cConteudo)

        ElseIf cIdPonto == "MODELCOMMITNTTS"
            //Mostrando mensagens no fim da operação
           
        EndIf 
    EndIf 
Return xRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MyFTTSPre
Função específica que será executada no momento FORMCOMMITTTSPRE
@param      oObj, cIDPonto, cIDModel, cConteudo
@return     NIL
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------
Static Function MyFTTSPre(oObj, cIDPonto, cIDModel, cConteudo)
Local oModel    := FwModelActive()
Local nOper     := oObj:GetOperation()

//ApMsgInfo("Esta é a minha função específica que será executada no momento 'FORMCOMMITTTSPRE'.")

HistLog(oModel, nOper)

Return NIL




/*/{Protheus.doc} HistLog
	Realiza gravação de histórico de log das informações do cliente.
	@type  Static Function
	@author Josuel Silva
	@since 07/06/2022
	@version 12.1.033
	@param oModel, objeto, modelo de dados utilizado
	@param nOperation, numerico, operação realizada.
	@return Nil
/*/
Static Function HistLog(oModel, nOper)
Local aArea     := GetArea()
Local aNoFields := {}
Local oModelSB1 := oModel:GetModel("SB1MASTER")
Local cId       := ""

cId := "Produto "+TRIM(FwFldGet('B1_COD')) + "-"+TRIM(FwFldGet('B1_DESC'))

U_LogMvc("MATA010_PE","SB1",nOper,oModelSB1,cID,aNoFields)

RestArea(aArea)

Return
