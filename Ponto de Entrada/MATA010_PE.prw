#Include "Protheus.ch" 
/*/{Protheus.doc} MATA010_PE
BK - Ponto de entrada MVC - Cadastro de Produtos
@Return
@author Marcos Bispo Abrah�o
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

    //Se tiver par�metros
    If aParam != Nil 
        //ConOut("> "+aParam[2]) 
 
        //Pega informa��es dos par�metros
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
 
            //Pr� configura��es do Modelo de Dados
        ElseIf cIdPonto == "MODELPRE"
            xRet := .T. 
 
            //Pr� configura��es do Formul�rio de Dados
        ElseIf cIdPonto == "FORMPRE"
            xRet := .T. 
 
            //nOper := oObj:GetModel(cIdPonto):nOperation
            //cTipo := aParam[4]
            //cCampo := aParam[5]
 
            //Se for Altera��o
            //If nOper == 4
            //N�o permite altera��o dos campos
            //    If cTipo == "CANSETVALUE" .And. Alltrim(cCampo) $ ("CAMPO1;CAMPO2;CAMPO3")
            //        xRet := .F.
            //    EndIf
            //EndIf
 
            //Adi��o de op��es no A��es Relacionadas dentro da tela

            // Copy
            /*
            If cIdModel == "SB1MASTER"
                oModelX := FwModelActive()// Instancia modelo ativo
                //oModelB1 := oModelX:GetModel("SB1MASTER") //Instancia sub-modelo SB1
                
                If oModelX:IsCopy() //Verifica se � uma opera��o de copia
                
                    // CUSTOMIZA��ES DO USU�RIO (VALIDA��O DE CAMPO, INSER��O DE VALORES E ETC)
                
                    //MsgInfo("FORMPRE - Opera��o de c�pia","MATA010_PE")
                    Public B1_XXCODCP := SB1->B1_COD
                    xRet := .T.//Mantem o retorno para valida��o FORMPOS como .T., alterar se for necess�rio 
                EndIf
            EndIf
            */

        ElseIf cIdPonto == "BUTTONBAR"
            xRet := {}
            If __cUserID == "000000"
                aAdd(xRet, {"Substitui��o de Produto", "", {|| u_BKCOMA01()}, "Somente produtos de compras"})
            EndIf

            //aAdd(xRet, {"* Titulo 2", "", {|| Alert("Bot�o 2")}, "Tooltip 2"})
            //aAdd(xRet, {"* Titulo 3", "", {|| Alert("Bot�o 3")}, "Tooltip 3"})
 
            //P�s configura��es do Formul�rio
        ElseIf cIdPonto == "FORMPOS"
            nOper := oObj:GetModel(cIdPonto):nOperation
 
            xRet := .T. 
            /*
            If nOper == 3 .OR. nOper == 4
                //Valida��o ao clicar no Bot�o Confirmar
                oModel		:= FwModelActivate()
                oModelSB1	:= oModel:GetModel('SB1MASTER') 

                cPrefix    	:= ALLTRIM(oModelSB1:GetValue('B1_XPREFIX'))
                cEstruc    	:= ALLTRIM(oModelSB1:GetValue('B1_XESTRUC'))

                If cPrefix == "TOD" .AND. Empty(cEstruc)
                    MsgStop("Para produtos TOD, � obrigat�rio informar a Estrutura",cIdPonto)
                    xRet := .F.
                EndIf
            EndIf
            */
        ElseIf cIdPonto == "MODELPOS"
            //Pr� valida��es do Commit

            xRet := .T. 

        ElseIf cIdPonto == "FORMCOMMITTTSPRE"
            //P�s valida��es do Commit

            MyFTTSPre(oObj, cIDPonto, cIDModel, cConteudo)

        ElseIf cIdPonto == "FORMCOMMITTTSPOS"
 
            //Commit das opera��es (antes da grava��o)
        ElseIf cIdPonto == "MODELCOMMITTTS"
           //Commit das opera��es (ap�s a grava��o)

          // MyMCOMMTTS(oObj, cIDPonto, cIDModel, cConteudo)

        ElseIf cIdPonto == "MODELCOMMITNTTS"
            //Mostrando mensagens no fim da opera��o
           
        EndIf 
    EndIf 
Return xRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MyFTTSPre
Fun��o espec�fica que ser� executada no momento FORMCOMMITTTSPRE
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

//ApMsgInfo("Esta � a minha fun��o espec�fica que ser� executada no momento 'FORMCOMMITTTSPRE'.")

HistLog(oModel, nOper)

Return NIL




/*/{Protheus.doc} HistLog
	Realiza grava��o de hist�rico de log das informa��es do cliente.
	@type  Static Function
	@author Josuel Silva
	@since 07/06/2022
	@version 12.1.033
	@param oModel, objeto, modelo de dados utilizado
	@param nOperation, numerico, opera��o realizada.
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
