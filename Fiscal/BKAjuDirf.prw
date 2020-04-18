#Include "PROTHEUS.CH"

/*/{Protheus.doc} User Function nomeFunction
	Programa para realizacao de acerto na base de dados para ajustar os campos "E2_DIRF" e  "E2_CODRET" dos titulos a pagar
	@type  Function
	@author Marcos Bispo Abrahão
	@since 20/01/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (Base TMSAJUDIRF)
/*/

User Function BKAjuDIRF()
Local cTitulo  := "BK - Ajuste DIRF - Contas a Pagar" 
Local aSays    := {}
Local aButtons := {}
Local nOpcA    := 0
Local cLockBy  := ""


cLockBy := "BKAJUDIRF"
If LockByName(cLockBy)
	
	//--Atualiza perguntas da Rotina:
	ValidPerg("BKAJUDIRF")
	Pergunte("BKAJUDIRF",.F.)

	AADD(aSays, "Este programa tem como objetivo ajustar os dados necessários")
	AADD(aSays, "para geração da DIRF. Apenas serão considerados para ajuste")
	AADD(aSays, "os títulos que tiveram retenção de IRF")

	AADD(aButtons, { 5,.T.,{|| Pergunte("BKAJUDIRF",.T. ) } } )
	AADD(aButtons, { 1,.T.,{|o| nOpcA:= 1,o:oWnd:End()}} )
	AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )

	FormBatch( cTitulo, aSays, aButtons ,,,450)

	If nOpcA == 1

		// Ajustar o IRRF ***************************
		Processa( {|lEnd| BKAjuSE2()} )

		// Ajustar o PIS/COFINS**********************
		Processa( {|lEnd| BKAjuPCC()} )

		//--Exibe log de processamento:
		ShowLog()
	EndIf
	UnLockByName(cLockBy)
Else
	Aviso("BKAJUDIRF", "O processamento do ajuste já foi iniciado por outra estação!", {"OK"})		
EndIf
Return



Static Function BKAjuSE2()
Local cQuery    := ''
Local cAliasQry := ''
Local nOpc      := 0
Local lProcessa := .T.
Local cCodRet   := ""   //Alltrim(&(GetMv("MV_TMSCRET",,''))) //-- Codigo de Retencao da DIRF - TMS
Local cUniao    := PadR( GetMV("MV_UNIAO",,""), Len(SA2->A2_COD) )		//-- Codigo do fornecedor para pagamento do Imposto de Renda
Local cPref     := ""
Local cNum      := ""
Local cParcela  := ""
Local cTipo     := ""
Local nHdlArqIR := 0


//-- Trata LOG de execucao do Ajuste:
If !File("BKRegIR.TXT")
	nHdlArqIR := MSFCREATE( "BKRegIR.TXT" )
Else
	nOpc := Aviso("Atenção", "O ajuste já foi processado anteriormente. Processar novamente?", {"SIM", "NÃO"})
	If nOpc == 1
		FErase("BKRegIR.TXT")
		nHdlArqIR := MSFCREATE( "BKRegIR.TXT" )
	Else
		lProcessa := .F.
	EndIf
EndIf

If lProcessa

	// LOG DE PROCESSAMENTO
	fWrite(nHdlArqIR, "BK - Ajuste de titulos para processamento da DIRF" + Chr(13) + Chr(10))
	fWrite(nHdlArqIR, "Processamento iniciado em: " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
	fWrite(nHdlArqIR, Chr(13) + Chr(10))

	//--Monta Query para selecao dos titulos:
	cQuery := "SELECT SE2.R_E_C_N_O_ SE2Recno, A2_TIPO"
	cQuery += " FROM " + RetSQLTab('SE2')
	cQuery += " INNER JOIN "+RETSQLNAME("SA2")+" SA2 ON SA2.D_E_L_E_T_='' AND A2_COD=E2_FORNECE AND A2_LOJA=E2_LOJA"
	cQuery += " WHERE SE2.E2_FILIAL = '" + xFilial('SE2') + "' AND "
	If MV_PAR01 == 1 //--Data de emissao
		cQuery += " SE2.E2_EMISSAO BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "' AND "
	ElseIf MV_PAR01 == 2 //--Vencimento
		cQuery += " SE2.E2_VENCTO BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "' AND "
	ElseIf MV_PAR01 == 3 //--Vencimento real
		cQuery += " SE2.E2_VENCREA BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "' AND "
	ElseIf MV_PAR01 == 4 //--Data de Baixa
		cQuery += " SE2.E2_BAIXA BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "' AND "
	EndIf
	cQuery += "SE2.E2_PARCIR  <> '  ' AND "
	cQuery += "SE2.D_E_L_E_T_ = ''"

	fWrite(nHdlArqIR, cQuery + Chr(13) + Chr(10))
	fWrite(nHdlArqIR, Chr(13) + Chr(10))

	//--Processa a Query
	cQuery    := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	ProcRegua( (cAliasQry)->(LastRec()) )

	// LOG DE PROCESSAMENTO
	fWrite(nHdlArqIR, "Titulos Ajustados:" + Chr(13) + Chr(10)) 
	fWrite(nHdlArqIR, "===================================================" + Chr(13) + Chr(10)) 
	fWrite(nHdlArqIR, "PREFIXO NUMERO    PARCELA TIPO FORNECEDOR LOJA COD." + Chr(13) + Chr(10)) 
	fWrite(nHdlArqIR, "===================================================" + Chr(13) + Chr(10)) 

	While !(cAliasQry)->(Eof())

		SE2->(MsGoTo((cAliasQry)->SE2Recno))
		
		If (cAliasQry)->A2_TIPO == "F"
			cCodRet := "3208"
		Else
			cCodRet := "1708"
		EndIf
		
		/*// (1) D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		SD1->(DbSetOrder(1))
		SD1->(DbSeek(xFilial("SD1")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA,.T.))
		cTes := ""
		If !EOF() .AND. D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA 
			cTes := SD1->D1_TES
			If cTes == "105"
				//cCodRet := 
			ElseIf cTes == "106" // Aluguel, pessoa Física
				cCodRet := "3208"
			EndIf
		EndIf
		*/

		If !(SE2->E2_TIPO $ MVISS+"/"+MVTAXA+"/"+MVTXA+"/"+MVINSS+"/"+"SES"+"/"+"AB-")

			SED->(DbSetOrder(1)) //--ED_FILIAL+ED_CODIGO
			If SED->(DbSeek(xFilial('SED')+SE2->E2_NATUREZ))

				If SED->ED_CALCIRF == "S"

					If SE2->E2_IRRF > 0 
						//--Se houve retencao de IRRF, indica que o
						//--titulo de IR deve ser considerado na DIRF e 
						//--atualiza o titulo "pai" para que o mesmo nao
						//--seja considerado na DIRF:
						cPref    := SE2->E2_PREFIXO
						cNum     := SE2->E2_NUM
						cParcela := SE2->E2_PARCIR
						cTipo    := MVTAXA						

						//--Atualiza o titulo "pai"
						RecLock("SE2", .F.)
						SE2->E2_DIRF   := "2" //--NAO
						SE2->E2_CODRET := cCodRet
						SE2->(MsUnLock())
										 
						//--Atualiza os dados do titulo de imposto (Tx)
						SE2->( DbSetOrder(6) ) //--E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
						If SE2->( DbSeek( xFilial("SE2") + cUniao + Padr('00',Len(SE2->E2_LOJA)) + cPref + cNum + cParcela + cTipo ) )
							RecLock("SE2", .F.)
							SE2->E2_DIRF   := "1" //--SIM
							SE2->E2_CODRET := cCodRet
							SE2->(MsUnLock())
                        Else
							//--Se nao encontrou o titulo de retencao
							//--de IRRF, posiciona novamente no titulo
							//--principal e ajusta os dados:
                        	SE2->(MsGoTo((cAliasQry)->SE2Recno))
							RecLock("SE2", .F.)
							SE2->E2_DIRF   := "1" //--SIM
							SE2->E2_CODRET := cCodRet
							SE2->(MsUnLock())
						EndIf					
					Else
						//--Se nao houve retencao de IRRF, mas a
						//--natureza indica que deve-se calcular o IRRF,
						//--atualiza o titulo para ser considerado na DIRF:
						RecLock("SE2", .F.)
						SE2->E2_DIRF   := "1" //--SIM
						SE2->E2_CODRET := cCodRet
						SE2->(MsUnLock())
					EndIf

					// LOG DE PROCESSAMENTO
					fWrite(nHdlArqIR, SE2->(E2_PREFIXO + Space(5) + E2_NUM + Space(1) + E2_PARCELA + Space(5) + E2_TIPO + Space(2) + E2_FORNECE + Space(3) + E2_LOJA) + Space(3) + cCodRet + Chr(13) + Chr(10))
				EndIf
			EndIf
		EndIf
		(cAliasQry)->(DbSkip())
		IncProc()
	End

	
	// LOG DE PROCESSAMENTO
	
	fWrite(nHdlArqIR, "==============================================" + Chr(13) + Chr(10)) 
	fWrite(nHdlArqIR, Chr(13) + Chr(10))
	fWrite(nHdlArqIR, Chr(13) + Chr(10))
	fWrite(nHdlArqIR, "Término do processamento" + Chr(13) + Chr(10))
	fWrite(nHdlArqIR, "Processamento finalizado em: " + DtoC(Date()) + " - " + Time())
	fClose(nHdlArqIR)
EndIf

Return



Static Function BKAjuPCC()
Local cQuery    := ''
Local cAliasQry := ''
Local nOpc      := 0
Local lProcessa := .T.
Local cCodRet   := ""   //Alltrim(&(GetMv("MV_TMSCRET",,''))) //-- Codigo de Retencao da DIRF - TMS
Local cUniao    := PadR( GetMV("MV_UNIAO",,""), Len(SA2->A2_COD) )		//-- Codigo do fornecedor para pagamento do Imposto de Renda
Local cPref     := ""
Local cNum      := ""
Local cParcela  := ""
Local cTipo     := ""
Local nHdlArqIR := 0

//-- Trata LOG de execucao do Ajuste:
If !File("BKRegIR.TXT")
	nHdlArqIR := MSFCREATE( "BKRegIR.TXT" )
Else
	nOpc := Aviso("Atenção", "O ajuste já foi processado anteriormente. Processar novamente?", {"SIM", "NÃO"})
	If nOpc == 1
		FErase("BKRegIR.TXT")
		nHdlArqIR := MSFCREATE( "BKRegIR.TXT" )
	Else
		lProcessa := .F.
	EndIf
EndIf

If lProcessa

	// LOG DE PROCESSAMENTO
	fWrite(nHdlArqIR, "BK - Ajuste de titulos para processamento da DIRF" + Chr(13) + Chr(10))
	fWrite(nHdlArqIR, "Processamento iniciado em: " + DtoC(Date()) + " - " + Time() + Chr(13) + Chr(10))
	fWrite(nHdlArqIR, Chr(13) + Chr(10))

	//--Monta Query para selecao dos titulos:
	cQuery := "SELECT SE2.R_E_C_N_O_ SE2Recno, A2_TIPO"
	cQuery += " FROM " + RetSQLTab('SE2')
	cQuery += " INNER JOIN "+RETSQLNAME("SA2")+" SA2 ON SA2.D_E_L_E_T_='' AND A2_COD=E2_FORNECE AND A2_LOJA=E2_LOJA"
	cQuery += " WHERE SE2.E2_FILIAL = '" + xFilial('SE2') + "' AND "
	If MV_PAR01 == 1 //--Data de emissao
		cQuery += " SE2.E2_EMISSAO BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "' AND "
	ElseIf MV_PAR01 == 2 //--Vencimento
		cQuery += " SE2.E2_VENCTO BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "' AND "
	ElseIf MV_PAR01 == 3 //--Vencimento real
		cQuery += " SE2.E2_VENCREA BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "' AND "
	ElseIf MV_PAR01 == 4 //--Data de Baixa
		cQuery += " SE2.E2_BAIXA BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "' AND "
	EndIf
	cQuery += "(SE2.E2_PARCCOF  <> '  ' OR SE2.E2_PARCPIS <> '  ' OR SE2.E2_PARCSLL <> '  ') AND "
	cQuery += "SE2.D_E_L_E_T_ = ''"

	fWrite(nHdlArqIR, cQuery + Chr(13) + Chr(10))
	fWrite(nHdlArqIR, Chr(13) + Chr(10))

	//--Processa a Query
	cQuery    := ChangeQuery(cQuery)
	cAliasQry := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	ProcRegua( (cAliasQry)->(LastRec()) )

	// LOG DE PROCESSAMENTO
	fWrite(nHdlArqIR, "Titulos Ajustados:" + Chr(13) + Chr(10)) 
	fWrite(nHdlArqIR, "===================================================" + Chr(13) + Chr(10)) 
	fWrite(nHdlArqIR, "PREFIXO NUMERO    PARCELA TIPO FORNECEDOR LOJA COD." + Chr(13) + Chr(10)) 
	fWrite(nHdlArqIR, "===================================================" + Chr(13) + Chr(10)) 

	While !(cAliasQry)->(Eof())

		SE2->(MsGoTo((cAliasQry)->SE2Recno))
		
		//If (cAliasQry)->A2_TIPO == "F"
		//	cCodRet := "3208"
		//Else
		//	cCodRet := "1708"
		//EndIf
		
		/*// (1) D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		SD1->(DbSetOrder(1))
		SD1->(DbSeek(xFilial("SD1")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA,.T.))
		cTes := ""
		If !EOF() .AND. D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA 
			cTes := SD1->D1_TES
			If cTes == "105"
				//cCodRet := 
			ElseIf cTes == "106" // Aluguel, pessoa Física
				cCodRet := "3208"
			EndIf
		EndIf
		*/

		cCodRet := "5952"
		If !(SE2->E2_TIPO $ MVISS+"/"+MVTAXA+"/"+MVTXA+"/"+MVINSS+"/"+"SES"+"/"+"AB-")

			//SED->(DbSetOrder(1)) //--ED_FILIAL+ED_CODIGO
			//If SED->(DbSeek(xFilial('SED')+SE2->E2_NATUREZ))

				//If SED->ED_CALCIRF == "S"

					If SE2->E2_PIS > 0 
						//--Se houve retencao de IRRF, indica que o
						//--titulo de IR deve ser considerado na DIRF e 
						//--atualiza o titulo "pai" para que o mesmo nao
						//--seja considerado na DIRF:
						cPref    := SE2->E2_PREFIXO
						cNum     := SE2->E2_NUM
						cParcela := SE2->E2_PARCPIS
						cTipo    := "TX "						

						//--Atualiza o titulo "pai"
						RecLock("SE2", .F.)
						SE2->E2_DIRF   := "2" //--NAO
						IF EMPTY(SE2->E2_CODRET)
							SE2->E2_CODRET := cCodRet
						ENDIF
						SE2->(MsUnLock())
										 
						//--Atualiza os dados do titulo de imposto (Tx)
						SE2->( DbSetOrder(6) ) //--E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
						If SE2->( DbSeek( xFilial("SE2") + cUniao + Padr('00',Len(SE2->E2_LOJA)) + cPref + cNum + cParcela + cTipo ) )
							RecLock("SE2", .F.)
							SE2->E2_DIRF   := "1" //--SIM
							SE2->E2_CODRET := cCodRet
							SE2->(MsUnLock())
                        Else
							//--Se nao encontrou o titulo de retencao
							//--de IRRF, posiciona novamente no titulo
							//--principal e ajusta os dados:
                        	//SE2->(MsGoTo((cAliasQry)->SE2Recno))
							//RecLock("SE2", .F.)
							//SE2->E2_DIRF   := "1" //--SIM
							//SE2->E2_CODRET := cCodRet
							//SE2->(MsUnLock())
						EndIf					
					Else
						//--Se nao houve retencao de IRRF, mas a
						//--natureza indica que deve-se calcular o IRRF,
						//--atualiza o titulo para ser considerado na DIRF:
						//RecLock("SE2", .F.)
						//SE2->E2_DIRF   := "1" //--SIM
						//SE2->E2_CODRET := cCodRet
						//SE2->(MsUnLock())
					EndIf

					SE2->(MsGoTo((cAliasQry)->SE2Recno))
					If SE2->E2_COFINS > 0 
						//--Se houve retencao de IRRF, indica que o
						//--titulo de IR deve ser considerado na DIRF e 
						//--atualiza o titulo "pai" para que o mesmo nao
						//--seja considerado na DIRF:
						cPref    := SE2->E2_PREFIXO
						cNum     := SE2->E2_NUM
						cParcela := SE2->E2_PARCCOF
						cTipo    := "TX "						

						//--Atualiza o titulo "pai"
						RecLock("SE2", .F.)
						SE2->E2_DIRF   := "2" //--NAO
						IF EMPTY(SE2->E2_CODRET)
							SE2->E2_CODRET := cCodRet
						ENDIF
						SE2->(MsUnLock())
										 
						//--Atualiza os dados do titulo de imposto (Tx)
						SE2->( DbSetOrder(6) ) //--E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
						If SE2->( DbSeek( xFilial("SE2") + cUniao + Padr('00',Len(SE2->E2_LOJA)) + cPref + cNum + cParcela + cTipo ) )
							RecLock("SE2", .F.)
							SE2->E2_DIRF   := "1" //--SIM
							SE2->E2_CODRET := cCodRet
							SE2->(MsUnLock())
						EndIf					
					EndIf

					SE2->(MsGoTo((cAliasQry)->SE2Recno))
					If SE2->E2_CSLL > 0 
						//--Se houve retencao de IRRF, indica que o
						//--titulo de IR deve ser considerado na DIRF e 
						//--atualiza o titulo "pai" para que o mesmo nao
						//--seja considerado na DIRF:
						cPref    := SE2->E2_PREFIXO
						cNum     := SE2->E2_NUM
						cParcela := SE2->E2_PARCSLL
						cTipo    := "TX "						

						//--Atualiza o titulo "pai"
						RecLock("SE2", .F.)
						SE2->E2_DIRF   := "2" //--NAO
						IF EMPTY(SE2->E2_CODRET)
							SE2->E2_CODRET := cCodRet
						ENDIF
						SE2->(MsUnLock())
										 
						//--Atualiza os dados do titulo de imposto (Tx)
						SE2->( DbSetOrder(6) ) //--E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
						If SE2->( DbSeek( xFilial("SE2") + cUniao + Padr('00',Len(SE2->E2_LOJA)) + cPref + cNum + cParcela + cTipo ) )
							RecLock("SE2", .F.)
							SE2->E2_DIRF   := "1" //--SIM
							SE2->E2_CODRET := cCodRet
							SE2->(MsUnLock())
						EndIf					
					EndIf

					// LOG DE PROCESSAMENTO
					fWrite(nHdlArqIR, SE2->(E2_PREFIXO + Space(5) + E2_NUM + Space(1) + E2_PARCELA + Space(5) + E2_TIPO + Space(2) + E2_FORNECE + Space(3) + E2_LOJA) + Space(3) + cCodRet + Chr(13) + Chr(10))
				//EndIf
			//EndIf
		EndIf
		(cAliasQry)->(DbSkip())
		IncProc()
	End

	
	// LOG DE PROCESSAMENTO
	
	fWrite(nHdlArqIR, "==============================================" + Chr(13) + Chr(10)) 
	fWrite(nHdlArqIR, Chr(13) + Chr(10))
	fWrite(nHdlArqIR, Chr(13) + Chr(10))
	fWrite(nHdlArqIR, "Término do processamento" + Chr(13) + Chr(10))
	fWrite(nHdlArqIR, "Processamento finalizado em: " + DtoC(Date()) + " - " + Time())
	fClose(nHdlArqIR)
EndIf

Return





// Exibe o Log de Processamento 
Static Function ShowLog()
Local oDlg
Local oFont
Local oMemo
Local cMemo

cMemo := MemoRead("BKRegIR.TXT")

DEFINE FONT oFont NAME "Courier New" SIZE 5,0
DEFINE MSDIALOG oDlg TITLE "BKRegIR.TXT" From 3,0 to 340,417 PIXEL
	@ 5,5 GET oMemo VAR cMemo MEMO SIZE 200,145 OF oDlg PIXEL 
	oMemo:bRClicked := {|| AllwaysTrue()}
	oMemo:oFont     := oFont

	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL
	DEFINE SBUTTON  FROM 153,145 TYPE 6 ACTION (Processa( {|| PrintLog("BKRegIR.TXT",cMemo)})		,oDlg:End()) ENABLE OF oDlg PIXEL //Imprime e Apaga

ACTIVATE MSDIALOG oDlg CENTER

Return


// Imprime Log de Processamento 

Static Function PrintLog(cArq, cMemo)
Local nLin      := 100
Local cLinha    := ''
Local nX        := 0
Local wnrel     := ''

Private aReturn := {"", 1, "", 1, 2, 1, "",1 }

ProcRegua( Len(cMemo) )

wnrel := SetPrint(,cArq,,"BK - Ajuste DIRF - Contas a Pagar", cArq,'','',.F.,"",.F.,"M")
If nLastKey <> 27		
	SetDefault(aReturn,"")
	cLinha := MLCount(cMemo,132)
	For nX:= 1 To cLinha
		nLin++
		If nLin > 65
			nLin := 1
			@ 00,00 PSAY AvalImp(132)
		Endif
		@ nLin,000 PSAY Memoline(cMemo,132,nX)        	
		IncProc()
	Next nX
	MS_FLUSH()   

	If ( aReturn[5] = 1 )
		OurSpool(wnrel)
	Endif

EndIf
Return


Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}


dbSelectArea("SX1")
dbSetOrder(1)

cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Datas","Datas","Datas","mv_ch1","N",01,0,2,"C","","mv_par01","Emissao","Emissao","Emissao","","","Vencimento","Vencimento","Vencimento","","","Venc. Real","Venc. Real","Venc. Real","","","Baixa","Baixa","Baixa","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Data Inicial","Data Inicial","Data Inicial","mv_ch2","D",08,0,0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Data Final","Data Final","Data Final","mv_ch3","D",08,0,0,"G","NaoVazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

For i:=1 to Len(aRegistros)
	If !dbSeek(cPerg+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()                                                           
			If j <= Len(aRegistros[i])
				FieldPut(j,aRegistros[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(aArea)

Return(NIL)



User Function MT103DRF()
Local nCombo  := PARAMIXB[1] 
Local cCodRet := PARAMIXB[2] 
Local aImpRet := {}
nCombo  := 1
cCodRet := "1700"
aadd(aImpRet,{"IRR",nCombo,cCodRet})
nCombo  := 2
cCodRet := "1708"
aadd(aImpRet,{"ISS",nCombo,cCodRet})
nCombo  := 1
cCodRet := "2008"
aadd(aImpRet,{"PIS",nCombo,cCodRet})
nCombo  := 1
cCodRet := "2010"
aadd(aImpRet,{"COF",nCombo,cCodRet})              
nCombo  := 2
cCodRet := "2050"
aadd(aImpRet,{"CSL",nCombo,cCodRet})
Return aImpRet