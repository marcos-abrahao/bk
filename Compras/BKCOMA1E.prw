#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKCOMA1E()
BK - exclusão de Produtos em massa

@author Marcos B. Abrahão
@since 30/04/2024
@version P12
@return Nil
/*/

User Function BKCOMA1E()
Local aArea 	:= GetArea()
Local cRet     := ""

Private aParam 	:= {}
Private cTitulo	:= "Exclusão de Produtos"
Private cPerg	:= "BKCOMA1E"
Private cProdI	:= SB1->B1_COD
Private cProdF	:= SB1->B1_COD

If BKPar1E()
	u_WaitLog(cPerg, {|oSay| cRet := ExcPrd(oSay)},"Excluindo produtos "+TRIM(cProdI)+" até "+TRIM(cProdF))
	u_MsgLog(cPerg,cRet,"I")
EndIF

RestArea(aArea)

Return Nil


Static Function BKPar1E()
Local lRet := .F.
Local aRet := {}
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
Do While .T.

	aParam := {}
    aAdd( aParam, { 1, "Produto inicial:", cProdI	, ""	, ""	, "SB1"	, ""	, 70	, .F. })
    aAdd( aParam, { 1, "Produto Final:"  , cProdF	, ""	, ""	, "SB1"	, ""	, 70	, .F. })

	lRet := (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg      ,.T.         ,.T.))
	If !lRet
		Exit
	Else
      cProdI := MV_PAR01
	  cProdF := MV_PAR02
      
      If !Empty(cProdI) .AND. !Empty(cProdF)
			If u_MsgLog(cPerg,"Confirma a exclusão dos produtos de "+TRIM(cProdI)+" até "+cProdF,"N")
				lRet := .T.
   				Exit
			EndIf
		EndIf
	Endif
EndDo
Return lRet


Static Function ExcPrd(oSay)
Local cRet      := ""
Local nRecNo    := 0
Local nExcluido := 0
Local nErro     := 0
Local nOk       := .T.
Local lDel      := .F.

dbSelectArea("SB2")
dbSetOrder(1)

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+cProdI)

Do While !Eof() .and. SB1->B1_COD <= cProdF

    oSay:SetText(SB1->B1_COD)

    nRecno := SB1->(RecNo())
    nOk := Exclui(SB1->B1_COD)

    If nOk == 3
        oSay:SetText("Delete SB2: "+SB1->B1_COD)
        dbSelectArea("SB2")
        dbSetOrder(1)
        dbSeek(xFilial("SB2")+SB1->B1_COD,.T.)
        lDel := .F.
        Do While !EOF() .AND. SB2->B2_COD == SB1->B1_COD
			RecLock("SB2",.F.)
			SB2->(dbDelete())
			SB2->(MsUnlock())
            dbSkip()
            lDel := .T.
        EndDo
        u_MsgLog(cPerg,"Delete SB2: "+SB1->B1_COD)

        oSay:SetText("Delete SA5: "+SB1->B1_COD)
        dbSelectArea("SA5")
        dbSetOrder(2)
        dbSeek(xFilial("SA5")+SB1->B1_COD,.T.)
        Do While !EOF() .AND. SA5->A5_PRODUTO == SB1->B1_COD
			RecLock("SA5",.F.)
			SA5->(dbDelete())
			SA5->(MsUnlock())
            dbSkip()
            lDel := .T.
        EndDo

        u_MsgLog(cPerg,"Delete SA5: "+SB1->B1_COD)

        dbSelectArea("SB1")

        If lDel
            Loop
        EndIf
    ElseIf nOk > 1 .AND. lDel
		SET DELETED OFF
        oSay:SetText("Recall SB2: "+SB1->B1_COD)

        dbSelectArea("SB2")
        dbSetOrder(1)
        dbSeek(xFilial("SB2")+SB1->B1_COD,.T.)
        lDel := .F.
        Do While !EOF() .AND. SB2->B2_COD == SB1->B1_COD
			RecLock("SB2",.F.)
			SB2->(dbRecall())
			SB2->(MsUnlock())
            dbSkip()
        EndDo
        u_MsgLog(cPerg,"Recall SB2: "+SB1->B1_COD)

        oSay:SetText("Recall SA5: "+SB1->B1_COD)

        dbSelectArea("SA5")
        dbSetOrder(2)
        dbSeek(xFilial("SA5")+SB1->B1_COD,.T.)
        Do While !EOF() .AND. SA5->A5_PRODUTO == SB1->B1_COD
			RecLock("SA5",.F.)
			SA5->(dbRecall())
			SA5->(MsUnlock())
            dbSkip()
        EndDo

		SET DELETED ON
        u_MsgLog(cPerg,"Recall SA5: "+SB1->B1_COD)


        dbSelectArea("SB1")
    EndIf

    lDel := .F.

    If nOk == 1
        nExcluido++
    Else
        nErro++
    EndIf
    dbSelectArea("SB1")
    dbGoTo(nRecNo)
    dbSkip()
EndDo
cRet := "Registros excluídos: "+STRZERO(nExcluido,6)+" - Registros com erro: "+STRZERO(nErro,6)
Return cRet



Static Function Exclui(cCod)
Local oModel    As Object
Local aFields   := {}
Local nOk       := 0
Local aErro     := {}
Local cRet      := ""

//Pegando o modelo de dados, setando os campos
oModel := FWLoadModel("MATA010")

aAdd(aFields, {"B1_COD", cCod, Nil})
 
//Se conseguir executar a operação automática
If FWMVCRotAuto(oModel, "SB1", 5, {{"SB1MASTER", aFields}} ,,.T.)
    nOk := 1
Else
    nOk := 2
EndIf
   
//Se não deu certo a inclusão, mostra a mensagem de erro
If nOk <> 1
    //Busca o Erro do Modelo de Dados
    aErro := oModel:GetErrorMessage()
    cMessage := ""
    //Monta o Texto que será mostrado na tela
    //cMessage += "Id do formulário de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
    //cMessage += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
    //cMessage += "Id do formulário de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
    //cMessage += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
    //cMessage += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
    cMessage += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
    //cMessage += "Mensagem da solução: "        + ' [' + cValToChar(aErro[07]) + '], '
    //cMessage += "Valor atribuído: "            + ' [' + cValToChar(aErro[08]) + '], '
    //cMessage += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
     
    //Mostra mensagem de erro
    cRet := "Produto "+TRIM(cCod)+" erro: " + cMessage
    If "SB2" $ cMessage .OR. "SA5" $ cMessage
        nOk := 3
    ElseIf "SB7" $ cMessage
        nOk := 4
    ElseIf "SB9" $ cMessage
        nOk := 5
    EndIf
Else
    cRet := "Produto "+TRIM(cCod)+" excluido"
EndIf
u_MsgLog(cPerg,cRet)

//Desativa o modelo de dados
oModel:DeActivate()

Return nOk
