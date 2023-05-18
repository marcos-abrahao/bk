#Include "PROTHEUS.CH"
#include "FWMVCDEF.CH"

Static cSContra := ""

User Function CNTA121()
Local aParam 	:= PARAMIXB
Local oObj 		As Object
Local xRet 		:= .T.
Local cIdPonto 	:= ""
Local cIdModel 	:= ""

Local cIDForm       := ''
Local cEvento       := ''
Local cCampo        := ''
Local cConteudo     := ''

Local lIsGrid 	:= .F.
//Local nLinha 	:= 0
//Local nQtdLinhas:= 0
//Local cMsg 		:= ""
Local cCampoIXB := ""
Local nOpc 		:= 0
Local oModel	as Object
Local oModelCND as Object
Local cContra	as Character
Local cRevisa 	as Character


	If (aParam <> NIL)
		oObj     := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid  := (Len(aParam) > 3)
		If (LEN(aParam) >= 6)
			cCampoIXB := aParam[6]
		EndIf

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

		nOpc := oObj:GetOperation() // PEGA A OPERAÇÃO

		///ShwParam(aParam,nOpc)   // Utilize para debugar

		If (cIdPonto == "FORMPRE")

			If ((nOpc == 1 .OR. nOpc == 4 )  .AND. cIdModel == "CXNDETAIL" .AND. cCampo == "ISENABLE") .AND. aParam[6] == "CXNDETAIL"
				////CnaMun()

			ElseIf (cIdModel == "CNDMASTER" .AND. aParam[4] == "SETVALUE" .AND. aParam[5]="CND_REVGER")

				oModel		:= FwModelActivate()
				oModelCND	:= oModel:GetModel('CNDMASTER')

				cContra	:= oModelCND:GetValue("CND_CONTRA")
				cRevisa	:= oModelCND:GetValue("CND_REVISA")

				oModelCND:LoadValue("CND_XXDESC",Posicione("CTT",1,xFilial("CTT")+cContra,"CTT_DESC01"))
				oModelCND:LoadValue("CND_NOMCLI",Posicione("CN9",1,xFilial("CN9",cFilCtr)+cContra+cRevisa,"CN9_NOMCLI"))
				//oModelCND:LoadValue("CND_NOMCLI",SUBSTR(Posicione("SA1",1,xFilial("SA1")+CN9->(CN9_XCLIEN+CN9_XLOJA),"A1_NOME"),1,30))

			ElseIf	lIsGrid .AND. (cIdModel == "CXNDETAIL" .AND. aParam[4] == Nil .AND. aParam[5]="ADDLINE") //.OR.;
				//CnaMun()
			ElseIf (cIdModel == "CNDMASTER" .AND. aParam[4] == "CANSETVALUE" .AND. aParam[5]="CND_XXRM")
				//CnaMun()
			EndIf
			//If lIsGrid 
				//If (cIdModel == "CXNDETAIL" .AND.  aParam[5] == "ADDLINE" .OR. (aParam[5] == "SETVALUE" .AND. aParam[6]="CXN_CHECK")
				//If cIdModel == "CNDMASTER" .AND.  aParam[5] == "CND_REVISA" .AND. aParam[4] == "SETVALUE"
				//	CnaMun()
				//Endif

				///If (cIdModel == "CXNDETAIL" .AND.  aParam[5] == "SETVALUE" .AND. aParam[6]="CXN_CHECK")
				///	CnaMun()
				///EndIf

			//EndIf

		ElseIf (cIdPonto == "MODELPOS")
			/*
			cMsg := "Chamada na validação total do modelo." + CRLF
			cMsg += "ID " + cIdModel + CRLF
			IF nOp == 3
				Alert('inclusão')
			ENDIF

			//xRet := MsgYesNo(cMsg + "Continua?")
			*/
			
			//MsgInfo(cMsg,cIdPonto)			
			//U_CN130INC(nOpc)

			/* Exemplo de validação de campo
			cModel := cIdModel+'_'+"ST9" //Concatena o identificado do modelo com o identificador da tabela.
					
			If oObj:GetModel(cModel):HasField('T9_BARCODE') //Verifica se campo existe no modelo.
						
				If Empty(oObj:GetValue(cModel,'T9_BARCODE')) //Verifica se o campo foi preenchido.
						
					Help('',1,"PE MNTA080K e MNTA0804" ,,"Campo"+Space(1)+"T9_BARCODE"+Space(1)+;
					"não foi preenchido e é obrigatório.",2,0,,,,,,{"Preencha o campo T9_BARCODE"}) //Mensagem help que será apresentada em tela.
					
					xRet := .F. //Determina o retorno .F., barrando a gravação do modelo.
				EndIf
			EndIf
			*/

		ElseIf (cIdPonto == "MODELVLDACTIVE")
			
			//cMsg := "Chamada na ativação do modelo de dados."

            // MODELO -> SUBMODELO -> ESTRUTURA -> PROPRIEDADE -> BLOCO DE CÓDIGO -> X3_WHEN := .F.
            oObj:GetModel("CNDMASTER"):GetStruct():SetProperty("CND_XXRM"  , MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
            oObj:GetModel("CNDMASTER"):GetStruct():SetProperty("CND_XXVLND", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
            oObj:GetModel("CNDMASTER"):GetStruct():SetProperty("CND_XXTPNF", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
            oObj:GetModel("CNDMASTER"):GetStruct():SetProperty("CND_OBS"   , MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))

			oObj:GetModel("CXNDETAIL"):GetStruct():SetProperty("CXN_XXOBS" , MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))

			//oObj:GetModel("CXNDETAIL"):GetStruct():SetProperty("CXN_XXVLND", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))

			//oObj:GetModel("CXNDETAIL"):GetStruct():SetProperty("CXN_NUMPLA",MODEL_FIELD_VALID,FwBuildFeatures(MODEL_FIELD_VALID,"U_CNACPOS()"))
			//xRet := MsgYesNo(cMsg + "Continua?")
			//MsgInfo(cMsg,cIdPonto)			
			
		ElseIf (cIdPonto == "FORMPOS")
			
			/*
			cMsg := "Chamada na validação total do formulário." + CRLF
			cMsg += "ID " + cIdModel + CRLF

			If (lIsGrid == .T.)
				cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
				cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
			Else
				cMsg += "É um FORMFIELD" + CRLF
			EndIf

			xRet := MsgYesNo(cMsg + "Continua?")
			*/
			//MsgInfo(cMsg,cIdPonto)			

			If (cIdModel == "CNDMASTER")
				xRet := MFormPos()
			EndIf


		ElseIf (cIdPonto =="FORMLINEPRE")

			///
			If (cIdModel == "CXNDETAIL" .And. LEN(aParam) >= 6 ) ;
				 .AND. cCampoIXB == "CXN_CHECK";
				 .AND. aParam[5] == "SETVALUE"   // Executa a função se clicar no checkbox da tela de medição
				////CnaMunP()
			Endif
			
			/* Exemplo
			If aParam[5] =="DELETE"
				cMsg := "Chamada na pré validação da linha do formulário." + CRLF
				cMsg += "Onde esta se tentando deletar a linha" + CRLF
				cMsg += "ID " + cIdModel + CRLF
				cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
				cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
				xRet := MsgYesNo(cMsg + " Continua?")
				EndIf
			EndIf
			*/

		ElseIf (cIdPonto =="FORMLINEPOS")
			If cIdModel == "CXNDETAIL" 
				If lIsGrid .AND. aParam[5] <> "DELETE"
					////CnaMunP()

				//	cMsg := "Chamada na validação da linha do formulário." + CRLF
				//	cMsg += "ID " + cIdModel + CRLF
				//	cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
				//	cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF

				//	xRet := MsgYesNo(cMsg + " Continua?")
				Endif
			EndIf
		ElseIf (cIdPonto =="MODELCOMMITTTS")
			//MsgInfo("Chamada após a gravação total do modelo e dentro da transação.",cIdPonto)
		ElseIf (cIdPonto =="MODELCOMMITNTTS")
			//MsgInfo("Chamada após a gravação total do modelo e fora da transação.",cIdPonto)
			GrvFinal(nOpc)
			cSContra := ""
		ElseIf (cIdPonto =="FORMCOMMITTTSPRE")
			//MsgInfo("Chamada após a gravação da tabela do formulário.",cIdPonto)
		ElseIf (cIdPonto =="FORMCOMMITTTSPOS")
			//MsgInfo("Chamada após a gravação da tabela do formulário.",cIdPonto)
		ElseIf (cIdPonto =="MODELCANCEL")
			cSContra := ""
			
			//cMsg := cIdPonto+" - Deseja realmente sair?"

			//xRet := MsgYesNo(cMsg)
			
		ElseIf (cIdPonto == "BUTTONBAR")
			//MsgInfo("Chamada para inclusão de botão.")
			xRet := {{"Anexos Medição", "Anexos da Medição", {|| u_DocSZE()}}}

		EndIf
	EndIf
Return (xRet)



Static Function MFormPos

Local lRet    := .T.
Local aAnexos := {}
Local oModel
Local oModelCND
Local cContra
Local cCompet
Local cCompAM

oModel		:= FwModelActivate()
oModelCND	:= oModel:GetModel('CNDMASTER')

cContra		:= oModelCND:GetValue("CND_CONTRA")
cCompet		:= oModelCND:GetValue("CND_COMPET")
cCompAM 	:= SUBSTR(cCompet,4,4)+SUBSTR(cCompet,1,2)

If CN9->CN9_XXANEX == 'S' // Somente para contratos que são obrigatorios anexar docs de medição
	aAnexos   := u_BKDocs(cEmpAnt,"SZE",PAD(cContra,15)+cCompAM,2)

	If Len(aAnexos) == 0
		//lRet := u_MsgLog("CNTA121_PE","Não foram anexados documentos para este contrato/competência, confirma assim mesmo?","N")
		// Aqui: obrigar anexar arquivos
		lRet := .F.
		u_MsgLog("CNTA121_PE","Não foram anexados documentos para este contrato/competência!","E")
	EndIf
EndIf

Return lRet




// Anexar Documentos para a Medição (Contrato + Competência)
User Function DocSZE()
Local aArea	 := GetArea()
Local nRecZE := 0
Local oModel
Local oModelCND
Local cContra
Local cCompet
Local cCompAM

oModel		:= FwModelActivate()
oModelCND	:= oModel:GetModel('CNDMASTER')

cContra		:= oModelCND:GetValue("CND_CONTRA")
cCompet		:= oModelCND:GetValue("CND_COMPET")

If !Empty(cContra) .AND. !EMPTY(cCompet)
	cCompAM := SUBSTR(cCompet,4,4)+SUBSTR(cCompet,1,2)
	dbSelectArea("SZE")
	dbSetOrder(1)
	If !dbSeek(xFilial("SZE")+cContra+cCompAM,.F.)
		RecLock("SZE", .T.)
		SZE->ZE_CONTRAT := cContra
		SZE->ZE_COMPET  := cCompAM
		SZE->ZE_ENVEM   := "N" 
		MsUnlock()
	EndIf
	nRecZE := RecNo()
	MsDocument("SZE",nRecZE,4) //6
Else
	u_MsgLog("CNTA121_PE","Informe o contrato e a competência","W")
EndIf

RestArea( aArea )

Return NIL


// Carrega o nome do municipio na grid do CXN
Static Function CnaMun()

Local oModel,oMdlCND,oMdlCXN
Local nLin		:= 0
Local cContra	:= ""
Local cRevisa	:= ""
Local cPlan		:= ""
Local nCnt		:= 0
Local oView     := FwViewActive()

//U_MsgLog("CNTA121_PE","CnaMun" )

oModel  := FwModelActivate()
oMdlCND := oModel:GetModel("CNDMASTER")
oMdlCXN := oModel:GetModel("CXNDETAIL")
//oMdlCNE := oModel:GetModel("CNEDETAIL")

// Habilitar campos de usuário na CXN
//oMdlCXN:GetStruct():SetProperty("CXN_XXRM"  , MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
//oMdlCXN:GetStruct():SetProperty("CXN_XXVLND", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
//oMdlCXN:GetStruct():SetProperty("CXN_XXOBS", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
//oMdlCXN:GetStruct():SetProperty("CXN_ZERO", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
//oMdlCXN:GetStruct():SetProperty("CXN_XXMUN", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))

nLin := oMdlCXN:Length()
If oMdlCXN:Length() > 0
	nLin := oMdlCXN:nLine
	cContra	:= oMdlCND:GetValue("CND_CONTRA")
	cRevisa	:= oMdlCND:GetValue("CND_REVISA")

	If cSContra <> cContra
		cSContra := cContra
		//cPlan 	:= oMdlCXN:GetValue("CXN_NUMPLA")	
		//	oMdlCXN:LoadValue("CXN_XXMUN",Posicione("CNA",1,xFilial("CNA",cFilCtr)+cContra+cRevisa+cPlan,"CNA_XXMUN"))
		//	oMdlCXN:LoadValue("CXN_XXMOT",Posicione("CNA",1,xFilial("CNA",cFilCtr)+cContra+cRevisa+cPlan,"CNA_XXMOT"))

		For nCnt:=1 to oMdlCXN:Length()
			//oMdlCXN:SetLine(nCnt)
			oMdlCXN:GoLine(nCnt)
			cPlan 	:= oMdlCXN:GetValue("CXN_NUMPLA")	
			oMdlCXN:LoadValue("CXN_XXMUN",Posicione("CNA",1,xFilial("CNA",cFilCtr)+cContra+cRevisa+cPlan,"CNA_XXMUN"))
			oMdlCXN:LoadValue("CXN_XXMOT",Posicione("CNA",1,xFilial("CNA",cFilCtr)+cContra+cRevisa+cPlan,"CNA_XXMOT"))
			//oMdlCXN:GoLine(nCnt)
			//oMdlCXN:SetLine(nCnt)
		Next
		
		If nLin > 0
			//oMdlCXN:SetLine(nLin)
			oMdlCXN:GoLine(nLin)
		Endif

		If oView != Nil .And. oView:IsActive() .And. !isBlind()
			//oView:Refresh()
			oView:Refresh('VIEW_CXN')
		EndIf

	EndIf

	u_xxLog("\log\cnta121_pe.log","CNTA121_PE" + ": cnamun" )

EndIf

Return Nil



// Carrega o nome do municipio na grid do CXN
Static Function CnaMunP()

Local oModel,oMdlCND,oMdlCXN
Local nLin		:= 0
Local cContra	:= ""
Local cRevisa	:= ""
Local cPlan		:= ""
//Local nCnt		:= 0
Local oView     := FwViewActive()

//U_MsgLog("CNTA121_PE","CnaMunP" )

oModel  := FwModelActivate()
oMdlCND := oModel:GetModel("CNDMASTER")
oMdlCXN := oModel:GetModel("CXNDETAIL")

If oMdlCXN:Length() > 0
	nLin := oMdlCXN:nLine
	cContra	:= oMdlCND:GetValue("CND_CONTRA")
	cRevisa	:= oMdlCND:GetValue("CND_REVISA")

	cPlan 	:= oMdlCXN:GetValue("CXN_NUMPLA")	
	oMdlCXN:LoadValue("CXN_XXMUN",Posicione("CNA",1,xFilial("CNA",cFilCtr)+cContra+cRevisa+cPlan,"CNA_XXMUN"))
	oMdlCXN:LoadValue("CXN_XXMOT",Posicione("CNA",1,xFilial("CNA",cFilCtr)+cContra+cRevisa+cPlan,"CNA_XXMOT"))
	//oMdlCXN:SetLine(nLin)
	//oMdlCXN:GoLine(nLin)
	oView:Refresh('VIEW_CXN')
EndIf

Return Nil



Static Function GrvFinal(nOpc)
Local cSql		as Character
Local nMesComp	as Numeric
Local nAnoComp	as Numeric
Local cAliasSZ2 as Character

If nOpc == 3
	// Inclusão

	// Não emitir NDC para a Petrobrás 10/05/22 
	If !u_IsPetro(CXN->CXN_CLIENT)
		cAliasSZ2:= GetNextAlias()

		// Buscar solicitações de até 3 meses atras
		nMesComp := VAL(SUBSTR(M->CND_COMPET,1,2))
		nAnoComp := VAL(SUBSTR(M->CND_COMPET,4,4))

		nMesComp := nMesComp - 3
		If nMesComp < 1
			nMesComp := 12 + nMesComp
			nAnoComp--
		EndIf
			
		cSql := "SELECT Z2_CC,SUM(Z2_VALOR)AS TOTAL,"
		cSql += " (SELECT TOP 1 CND_XXDV FROM CND010 CND WHERE CND.D_E_L_E_T_='' "
		cSql += "  AND CND_CONTRA='"+M->CND_CONTRA+"' AND CND_COMPET='"+M->CND_COMPET+"' AND CND_XXDV<>'' ) AS CND_XXDV " 
		cSql += "FROM SZ2010 SZ2 "
		cSql += "WHERE SZ2.D_E_L_E_T_='' AND Z2_CODEMP='"+cEmpAnt+"' AND Z2_TIPO='SOL' AND Z2_STATUS <> 'D' AND Z2_NDC = ' ' "
		//cSql += " AND SUBSTRING(Z2_DATAEMI,1,6)='"+SUBSTR(M->CND_COMPET,4,4)+SUBSTR(M->CND_COMPET,1,2)+"'"
		cSql += " AND SUBSTRING(Z2_DATAEMI,1,6)>='"+STRZERO(nAnoComp,4)+STRZERO(nMesComp,2)+"'"
		cSql += " AND Z2_CC='"+M->CND_CONTRA+"' "
		cSql += "GROUP BY Z2_CC "

		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAliasSZ2,.T.,.T.)

		//TCQUERY cSql NEW ALIAS (cAliasSZ2)
			
		dbSelectArea(cAliasSZ2)
		(cAliasSZ2)->(DbGotop()) 
		If (cAliasSZ2)->TOTAL > 0 
			If MsgYesNo("Faturado solicitação de viagens contrato: "+TRIM(M->CND_CONTRA)+" - Valor R$ "+ALLTRIM(TRANSFORM((cAliasSZ2)->TOTAL,"@E 999,999,999.99")))
				M->CND_XXDV   := "S"
				M->CND_XXVLND := (cAliasSZ2)->TOTAL
				//Inclui a NDC
				U_FIN040INC(CND->(RECNO()),(cAliasSZ2)->TOTAL)
			Else
				M->CND_XXDV   := "N"
			EndIf
		EndIf
	EndIf
ElseIf nOpc == 5 .AND. !EMPTY(CND->CND_XXNDC)
	// Exclui a NDC
   	U_FIN040EXC(CND->(RECNO())) 
EndIf

Return nil


/*
// Retornar CNA_XXMOT via dic
User Function BkPosCna(cOrigem,cCampo)
Local cRet := ""
If cOrigem == "R"   // x3_relacao
	cRet := IIf(Inclui,"",Posicione("CNA",1,xFilial("CNA",cFilCtr)+CXN->CXN_CONTRA+CXN->CXN_REVISA+CXN->CXN_NUMPLA,cCampo))
	cRet := Posicione("CNA",1,xFilial("CNA",cFilCtr)+CXN->CXN_CONTRA+CXN->CXN_REVISA+CXN->CXN_NUMPLA,cCampo)
ElseIf cOrigem == "I"  // x3_inibrw
	cRet := Posicione("CNA",1,xFilial("CNA",cFilCtr)+FWFldGet("CXN_CONTRA")+FWFldGet("CXN_REVISA")+FWFldGet("CXN_NUMPLA"),cCampo)      
EndIf
Return cRet
*/


//-------------------------------------------------------------------
/*/{Protheus.doc} ShwParam
Exibe os parâmetros do Ponto de Entrada do Cadastro de Clientes (MVC)
@param      aParam
@return     NIL
@author     Faturamento
@version    12.1.17 / Superior
@since      Mai/2021
/*/
//-------------------------------------------------------------------
Static Function ShwParam(aParam,nOpc)
 
Local nInd          := 1
Local cAuxMsg       := ''
Local cAuxMsg2      := ''
//Local cSeparador    := Repl('-', 40)
Local cMsg			:= ""
/*
cMsg := ""
If  !aParam[2] $ 'FORMPRE//FORMPOS//FORMCOMMITTTSPRE//FORMCOMMITTTSPOS'
	If ValType(aParam[nInd]) == 'O' .and. valtype(aParam[01]:NOPERATION) <> NIL
		cMsg:= 'OPERATION = ' + AllTrim(Str(aParam[01]:NOPERATION)) + CRLF
	EndIf
Else
	cMsg  := ""
EndIf
*/

cMsg += "Opção: "+ALLTRIM(STR(nOpc))+CRLF

For nInd := 1 to Len(aParam)
 
    cAuxMsg     := ''
    cAuxMsg2    := ''
 
    If ValType(aParam[nInd]) == 'U'
        cAuxMsg2         := '= ' + ' NIL'
    ElseIf ValType(aParam[nInd]) == 'O'
        cAuxMsg2         := ' (OBJETO)'
    ElseIf ValType(aParam[nInd]) == 'C'
        cAuxMsg2         := "= '" + aParam[nInd] + "'"
    ElseIf ValType(aParam[nInd]) == "N"
        cAuxMsg2         := '= ' + AllTrim(Str(aParam[nInd]))
    ElseIf ValType(aParam[nInd]) == "D"
        cAuxMsg2         := '= ' + DtoC(aParam[nInd])
    ElseIf ValType(aParam[nInd]) == 'L'
        cAuxMsg2         := '= ' + If(aParam[4], '.T.', '.F.')
    EndIf
 
    If nInd == 2
        cAuxMsg        := 'IDPonto (Evento)'
    ElseIf nInd == 3
        cAuxMsg        := 'IDModelo'
    ElseIf (nInd == 4 .OR. nInd == 5 .OR. nInd == 6)
        If aParam[2] == 'FORMPRE'
            If nInd == 4
                cAuxMsg    := 'Evento'
            ElseIf nInd == 5
                cAuxMsg    := 'Campo'
            ElseIf nInd == 6 //.AND. aParam[4] == 'SETVALUE'
                cAuxMsg    := 'Conteúdo'
            EndIf
        ElseIf (aParam[2] $ 'FORMCOMMITTTSPRE//FORMCOMMITTTSPOS') .AND. nInd == 6
            cAuxMsg        := 'Conteúdo'
        EndIf
    EndIf
 
    cMsg  += 'PARAMIXB[' + StrZero(nInd,2) + '] => ' + If(!Empty(cAuxMsg),cAuxMsg + ' ', '') + cAuxMsg2 + CRLF
 
Next nInd
 
u_xxLog("\log\cnta121_pe.log","CNTA121_PE" + ": " + cMsg)

Return NIL
 

