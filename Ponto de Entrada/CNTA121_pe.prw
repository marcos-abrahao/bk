#Include "TOTVS.ch"
#Include "FWMVCDEF.ch"
#Include "TOPCONN.CH"

User Function CNTA121()
	Local aParam 	:= PARAMIXB
	Local oObj 		as Object
	Local xRet 		:= .T.
	Local cIdPonto 	:= ""
	Local cIdModel 	:= ""
	Local lIsGrid 	:= .F.
	Local nLinha 	:= 0
	Local nQtdLinhas:= 0
	Local cMsg 		:= ""
	Local cCampoIXB := ""
	Local nOpc 		:= 0

	If (aParam <> NIL)
		oObj     := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid  := (Len(aParam) > 3)
		If (LEN(aParam) >= 6)
			cCampoIXB := aParam[6]
		EndIf

		nOpc := oObj:GetOperation() // PEGA A OPERAÇÃO

		If (cIdPonto == "FORMPRE")
			If lIsGrid 
				//If (cIdModel == "CXNDETAIL" .AND.  aParam[5] == "ADDLINE" .OR. (aParam[5] == "SETVALUE" .AND. aParam[6]="CXN_CHECK")
				If cIdModel == "CNDMASTER" .AND.  aParam[5] == "CND_REVISA" .AND. aParam[4] == "SETVALUE"
					CnaMun()
				Endif
			EndIf

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

			//oObj:GetModel("CXNDETAIL"):GetStruct():SetProperty("CXN_XXVLND", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))

			//oObj:GetModel("CXNDETAIL"):GetStruct():SetProperty("CXN_NUMPLA",MODEL_FIELD_VALID,FwBuildFeatures(MODEL_FIELD_VALID,"U_CNACPOS()"))
			//xRet := MsgYesNo(cMsg + "Continua?")
			//MsgInfo(cMsg,cIdPonto)			
			
		ElseIf (cIdPonto == "FORMPOS")
			
			cMsg := "Chamada na validação total do formulário." + CRLF
			cMsg += "ID " + cIdModel + CRLF

			If (lIsGrid == .T.)
				cMsg += "É um FORMGRID com " + Alltrim(Str(nQtdLinhas)) + " linha(s)." + CRLF
				cMsg += "Posicionado na linha " + Alltrim(Str(nLinha)) + CRLF
			Else
				cMsg += "É um FORMFIELD" + CRLF
			EndIf

			//xRet := MsgYesNo(cMsg + "Continua?")
			//MsgInfo(cMsg,cIdPonto)			
			
		ElseIf (cIdPonto =="FORMLINEPRE")


			If (cIdModel == "CXNDETAIL" .And. LEN(aParam) >= 6 )   // Executa a função se clicar no checkbox da tela de medição
				CnaMun()
			Endif

			/*
			If cIdModel == "CXNDETAIL" .AND. aParam[5] <> "DELETE"
				oModel		:= FwModelActivate()
				oModelCXN	:= oModel:GetModel('CXNDETAIL')
				oModelCND	:= oModel:GetModel('CNDMASTER')

				oObj:GetModel("CNDMASTER"):GetModel("CXNDETAIL"):GetValue("CXN_NUMPLA")	
				cPlan		:= oModelCXN:GetValue('CXN_NUMPLA')
				cContra		:= oModelCND:GetValue('CND_CONTRA')
				cRevisa		:= oModelCND:GetValue('CND_CONTRA')
	
				//CNA_FILIAL+CNA_CONTRA+CNA_NUMERO



				oModelCXN:LoadValue("CXN_XXMUN","teste "+str(aparam[4]))
			Endif
			*/

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
				If aParam[5] <> "DELETE"
					CnaMun()

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
		ElseIf (cIdPonto =="FORMCOMMITTTSPRE")
			//MsgInfo("Chamada após a gravação da tabela do formulário.",cIdPonto)
		ElseIf (cIdPonto =="FORMCOMMITTTSPOS")
			//MsgInfo("Chamada após a gravação da tabela do formulário.",cIdPonto)
		ElseIf (cIdPonto =="MODELCANCEL")
			
			//cMsg := cIdPonto+" - Deseja realmente sair?"

			//xRet := MsgYesNo(cMsg)
			
		ElseIf (cIdPonto =="BUTTONBAR")
			//MsgInfo("Chamada para inclusão de botão.")
			//xRet := {{"Botão", "BOTÃO", {|| MsgInfo("Buttonbar","BUTTONBAR")}}}
		EndIf
	EndIf
Return (xRet)


// Carrega o nome do municipio na grido do CXN
Static Function CnaMun()

Local oModel,oMdlCND,oMdlCXN
Local nLin		:= 0
Local cContra	:= ""
Local cRevisa	:= ""
Local cPlan		:= ""
Local nCnt		:= 0

oModel  := FwModelActivate()
oMdlCND := oModel:GetModel("CNDMASTER")
oMdlCXN := oModel:GetModel("CXNDETAIL")
//oMdlCNE := oModel:GetModel("CNEDETAIL")

// Habilitar campos de usuário na CXN
oMdlCXN:GetStruct():SetProperty("CXN_XXRM"  , MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
oMdlCXN:GetStruct():SetProperty("CXN_XXVLND", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
oMdlCXN:GetStruct():SetProperty("CXN_XXOBS", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))
oMdlCXN:GetStruct():SetProperty("CXN_ZERO", MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".T."))

If oMdlCXN:Length() > 0
	nLin := oMdlCXN:nLine
	cContra	:= oMdlCND:GetValue("CND_CONTRA")
	cRevisa	:= oMdlCND:GetValue("CND_REVISA")

	For nCnt:=1 to oMdlCXN:Length()
		oMdlCXN:GoLine(nCnt)
		cPlan 	:= oMdlCXN:GetValue("CXN_NUMPLA")	
		oMdlCXN:LoadValue("CXN_XXMUN",Posicione("CNA",1,xFilial("CNA")+cContra+cRevisa+cPlan,"CNA_XXMUN"))
		oMdlCXN:LoadValue("CXN_XXMOT",Posicione("CNA",1,xFilial("CNA")+cContra+cRevisa+cPlan,"CNA_XXMOT"))
	Next
	If nLin > 0
		oMdlCXN:GoLine(nLin)
	Endif
EndIf

/*
If oObj:GetModel("CNDMASTER"):GetModel("CXNDETAIL"):Length() > 0
	nLin := oObj:GetModel("CNDMASTER"):GetModel("CXNDETAIL"):nLine
	cContra	:= oObj:GetModel("CNDMASTER"):GetModel("CNDMASTER"):GetValue("CND_CONTRA")
	cRevisa	:= oObj:GetModel("CNDMASTER"):GetModel("CNDMASTER"):GetValue("CND_REVISA")

	For nCnt:=1 to oObj:GetModel("CNDMASTER"):GetModel("CXNDETAIL"):Length()
		oObj:GetModel("CNDMASTER"):GetModel("CXNDETAIL"):GoLine(nCnt)
		cPlan 	:= oObj:GetModel("CNDMASTER"):GetModel("CXNDETAIL"):GetValue("CXN_NUMPLA")	
		oObj:GetModel("CNDMASTER"):GetModel("CXNDETAIL"):LoadValue("CXN_XXMUN",cContra+cRevisa+cPlan)
		oObj:GetModel("CNDMASTER"):GetModel("CXNDETAIL"):LoadValue("CXN_XXMUN",Posicione("CNA",1,xFilial("CNA")+cContra+cRevisa+cPlan,"CNA_XXMUN"))
	Next
	If nLin > 0
		oObj:GetModel("CNDMASTER"):GetModel("CXNDETAIL"):GoLine(nLin)
	Endif
EndIf
*/

Return Nil



Static Function GrvFinal(nOpc)
Local cSql		as Character
Local nMesComp	as Numeric
Local nAnoComp	as Numeric
Local cAliasSZ2 as Character

If nOpc == 3
	// Inclusão

	// Gravar Parcela no CND
	/*
	dbSelectArea("CXN")
	dbSetOrder(1)
	dbSeek(xFilial("CXN")+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED,.T.)
	Do While xFilial("CNX") == CNX->CNX_FILIAL .AND. CNX->(CNX_CONTRA+CNX_REVISA+CNX_NUMMED) == CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED .AND. !EOF()
		If CXN->CXN_CHECK 
			If Empty(M->CND_PARCEL)
				//  Gravar campos do CXN na CND
				RecLock("CND")
				//CND->CND_CLIENT  := CXN->CXN_CLIENT
				//CND->CND_LOJACL  := CXN->CXN_LJCLI
				//CND->CND_NUMERO  := CXN->CXN_NUMPLA
				CND->CND_PARCEL  := CXN->CXN_PARCEL
				CND->(MsUnLock())
				//Exit
			EndIf
		EndIf
		dbSkip()
	EndDo
	*/
	
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
	cSql += "WHERE SZ2.D_E_L_E_T_='' AND Z2_CODEMP='"+SM0->M0_CODIGO+"' AND Z2_TIPO='SOL' AND Z2_STATUS <> 'D' AND Z2_NDC = ' ' "
	//cSql += " AND SUBSTRING(Z2_DATAEMI,1,6)='"+SUBSTR(M->CND_COMPET,4,4)+SUBSTR(M->CND_COMPET,1,2)+"'"
	cSql += " AND SUBSTRING(Z2_DATAEMI,1,6)>='"+STRZERO(nAnoComp,4)+STRZERO(nMesComp,2)+"'"
	cSql += " AND Z2_CC='"+M->CND_CONTRA+"' "
	cSql += "GROUP BY Z2_CC "
		
	TCQUERY cSql NEW ALIAS (cAliasSZ2)
		
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
ElseIf nOpc == 5 .AND. !EMPTY(CND->CND_XXNDC)
	// Exclui a NDC
   	U_FIN040EXC(CND->(RECNO())) 
EndIf

Return nil
