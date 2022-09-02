#Include "PROTHEUS.CH"
#include "FWMVCDEF.CH"

/*/{Protheus.doc} FINA010_PE
BK - Ponto de entrada MVC - Cadastro de Naturezas
@Return
@author Marcos Bispo Abrahão
@since 30/08/2022
@version P12.33
/*/

User Function FINA010()
 
Local aParam        := PARAMIXB
Local xRet          := .T.
Local lIsGrid       := .F.
Local cIDPonto      := ''
Local cIDModel      := ''
Local cIDForm       := ''
Local cEvento       := ''
Local cCampo        := ''
Local cConteudo     := ''
Local oObj          := NIL

If aParam <> NIL
 
    oObj        := aParam[1]
    cIDPonto    := aParam[2]
    cIDModel    := aParam[3]
    lIsGrid     := (Len(aParam) > 3)
 
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
 
    ///ShwParam(aParam)
 
    If cIDPonto == 'MODELVLDACTIVE'
        /*
        ApMsgInfo("Valida se o Modelo do Cadastro de Clientes pode ou não ser exibido ao usuário (PE '" + cIDPonto + "')." + CRLF +;
                  "ID '" + cIDModel + "'")
 
        If (xRet    := ApMsgYesNo("Valida se a opção escolhida pelo usuário poderá abrir o Modelo da rotina." + CRLF +;
                                  "Continua ?"))
            ApMsgInfo("O PE '" + cIDPonto + "' do '" + cRotMVC + "' retornará .T.")
 
            // Como a tela do Modelo será exibida ao usuário, então, por exemplo, pode-se customizar a sua exibição...
            If ApMsgYesNo("Deseja customizar o Modelo ? - ID '" + cIDModel + "'")
                ModifModel(oObj, cIDPonto, cIDModel)
            EndIf
 
        Else
            Help( ,, 'Help',, "O PE '" + cIDPonto + "' do '" + cRotMVC + "' retornará .F.", 1, 0 )
        EndIf
        */

    ElseIf cIDPonto == 'MODELPRE'
        /*
       ApMsgInfo("Antes da alteração de qualquer campo do Modelo. (PE '" + cIDPonto + "')." + CRLF +;
                  "ID '" + cIDModel + "'")
        */
    ElseIf cIDPonto == 'FORMPRE'
        /*
        ApMsgInfo("Antes da alteração de qualquer campo do Formulário. (PE '" + cIDPonto + "' / Evento '" + cEvento + "' no campo '" + cCampo + "')." + CRLF +;
                  "ID '" + cIDModel + "' - FormID '" + cIDForm + "'")
 
        cMsg    := "Execução do ('" + cIDPonto + "' / Evento '" + cEvento + "' no campo '" + cCampo + "'" + If(cEvento == "SETVALUE", " Conteúdo = " + cConteudo, "") + ")." + CRLF
        If (xRet    := ApMsgYesNo(cMsg + CRLF + 'É permitido ?'))
            ApMsgInfo("O PE '" + cIDPonto + "' / Evento '" + cEvento + "' do '" + cRotMVC + "' retornará .T.")
        Else
            Help( ,, 'Help',, "O PE '" + cIDPonto + "' / Evento '" + cEvento + "' do '" + cRotMVC + "' retornará .F.", 1, 0 )
        EndIf
        */
    ElseIf cIDPonto == 'BUTTONBAR'
        /*
        ApMsgInfo("Adicionando um botão na barra de botões da rotina (PE '" + cIDPonto + "')." + CRLF +;
                  "ID '" + cIDModel + "'")
        */
 
    ElseIf cIDPonto == 'FORMPOS'
        /*
        cMsg := "Chamada na validação final do formulário (PE '" + cIDPonto + "')." + CRLF +;
                "ID '" + cIDModel + "' - FormID '" + cIDForm + "'" + CRLF
        */
        SetField(oObj, cIDPonto, cIDModel, cIDForm)
        /*
        If (xRet    := ApMsgYesNo(cMsg + CRLF + 'Continua ?'))
            ApMsgInfo("O PE '" + cIDPonto + "' do PE '" + cRotMVC + "' retornará .T.")
        Else
            Help( ,, 'Help',, "O PE '" + cIDPonto + "' do '" + cRotMVC + "' retornará .F.", 1, 0 )
        EndIf
        */
    ElseIf  cIDPonto == 'MODELPOS'
        /*
        cMsg := "Chamada na validação total do modelo (PE '" + cIDPonto + "')." + CRLF +;
                "ID '" + cIDModel + "'" + CRLF
 
        If (xRet    := ApMsgYesNo(cMsg + CRLF + 'Continua ?'))
            ApMsgInfo("O PE '" + cIDPonto + "' do '" + cRotMVC + "' retornará .T.")
        Else
            Help( ,, 'Help',, "O PE '" + cIDPonto + "' do '" + cRotMVC + "' retornará .F.", 1, 0 )
        EndIf
        */
    ElseIf cIDPonto == 'FORMCOMMITTTSPRE'
        /*
        ApMsgInfo("Chamada antes da gravação da tabela do formulário (PE '" + cIDPonto + "')." + CRLF +;
                  "ID " + cIDModel)
        */

        xRet    := MyFTTSPre(oObj, cIDPonto, cIDModel, cConteudo)

    ElseIf cIDPonto == 'FORMCOMMITTTSPOS'
        /*
        ApMsgInfo("Chamada após a gravação da tabela do formulário (PE '" + cIDPonto + "')." + CRLF +;
                  "ID " + cIDModel)
        xRet    := MyFTTSPos(oObj, cIDPonto, cIDModel, cConteudo)
        */
    ElseIf cIDPonto == 'MODELCOMMITTTS'
        /*
        ApMsgInfo("Chamada após a gravação total do modelo e dentro da transação (PE '" + cIDPonto + "')." + CRLF +;
                  "ID " + cIDModel)
        xRet    := MyMTTS(oObj, cIDPonto, cIDModel, cConteudo)
        */
    ElseIf cIDPonto == 'MODELCOMMITNTTS'
        /*
        ApMsgInfo("Chamada após a gravação total do modelo e fora da transação (PE '" + cIDPonto + "')." + CRLF +;
                  "ID " + cIDModel)
        __LogTela   := NIL
        */
        xRet        := MyMNTTS(oObj, cIDPonto, cIDModel, cConteudo)
    ElseIf cIDPonto == 'MODELCANCEL'
        /*
        If (xRet := ApMsgYesNo("O botão 'FECHAR' foi acionado no modelo do Cadastro de Clientes (PE '" + cIDPonto + "')." + CRLF +;
                              'Deseja realmente sair ?'))
            ApMsgInfo("O PE '" + cIDPonto + "' do '" + cRotMVC + "' retornará .T.")
            __LogTela   := NIL
        Else
            ApMsgInfo("O PE '" + cIDPonto + "' do '" + cRotMVC + "' retornará .F.")
        EndIf
        */
    EndIf
 
EndIf
 
Return xRet
 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ModifModel
Customizações nas propriedades dos campos do Modelo do Cadastro de Clientes (MVC)
@param      oObj, cIDPonto, cIDModel
@return     NIL
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------
Static Function ModifModel(oObj, cIDPonto, cIDModel)
/* 
If ApMsgYesNo("Vamos bloquear a digitação do campo 'A1_TELEX' no IDPonto '" + cIDPonto + "' - Modelo '" + cIDModel + "' ?")
 
    // Bloqueando a edição de um campo no Modelo...
    ApMsgInfo("Como a tela do Modelo será exibida ao usuário, vamos bloquear a edição do campo 'A1_TELEX'")
//  MODELO     -> SUBMODELO -> ESTRUTURA -> PROPRIEDADE                             -> BLOCO DE CÓDIGO                 -> X3_WHEN := .F.
    oObj:GetModel("SA1MASTER"):GetStruct():SetProperty("A1_TELEX", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
    //
 
EndIf
*/
Return NIL
 
//-------------------------------------------------------------------
/*/{Protheus.doc} SetField
Exemplo de preenchimento de um campo do Modelo do Cadastro de Clientes (MVC)
@param      oObj, cIDPonto, cIDModel, cIDForm
@return     NIL
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------
Static Function SetField(oObj, cIDPonto, cIDModel, cIDForm)
/*
If cIDModel == 'SA1MASTER'
    If oObj:GetValue('A1_EST') $ 'AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MG/MS/MT/PA/PB/PE/PI/PR/RJ/RN/RO/RR/RS/SC/SE/SP/TO' .AND.;
       Empty(oObj:GetValue('A1_PAIS'))
 
        If ApMsgYesNo("Foi informado o campo 'A1_EST' com uma Unidade Federativa do Brasil, e não foi informado o código do país." + CRLF +;
                      "Então, vamos preencher o campo 'A1_PAIS' no IDPonto '" +;
                      cIDPonto + "' - Modelo '" + cIDModel + "' ?")
            oObj:SetValue('A1_PAIS', '105')
        EndIf
 
    EndIf
EndIf
*/
Return NIL
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MyFTTSPre
Função específica que será executada no momento FORM COMMIT TTS PRE
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

//ApMsgInfo("Esta é a minha função específica que será executada no momento 'FORM COMMIT TTS PRE'.")

HistLog(oModel, nOper)

Return NIL
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MyFTTSPos
Função específica que será executada no momento FORM COMMIT TTS POS
@param      oObj, cIDPonto, cIDModel, cConteudo
@return     NIL
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------
Static Function MyFTTSPos(oObj, cIDPonto, cIDModel, cConteudo)
 
//ApMsgInfo("Esta é a minha função específica que será executada no momento 'FORM COMMIT TTS POS'.")
Return NIL
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MyMTTS
Função específica que será executada no momento MODEL COMMIT TTS
@param      oObj, cIDPonto, cIDModel, cConteudo
@return     NIL
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------
Static Function MyMTTS(oObj, cIDPonto, cIDModel, cConteudo)
 
//ApMsgInfo("Esta é a minha função específica que será executada no momento 'MODEL COMMIT TTS'.")

Return NIL
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MyMNTTS
Função específica que será executada no momento MODEL COMMIT NÃO TTS
@param      oObj, cIDPonto, cIDModel, cConteudo
@return     NIL
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------
Static Function MyMNTTS(oObj, cIDPonto, cIDModel, cConteudo)
//Local nOper := oObj:nOperation

//ApMsgInfo("Esta é a minha função específica que será executada no momento 'MODEL COMMIT NÃO TTS'.")

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
Local oModelSA1 := oModel:GetModel("SEDMASTER")
Local cId       := ""

cId := "Natureza "+FwFldGet('ED_CODIGO ') + " - "+TRIM(FwFldGet('ED_DESCRIC'))

//aAdd(aNoFields, 'A1_SALPEDL'	)

U_LogMvc("FINA010_PE","SED",nOper,oModelSA1,cID,aNoFields)

RestArea(aArea)

Return
