/*/{Protheus.doc} MT110LOK
// Validação das entidades contábeis quando não for utilizado rateio.
@author Marcos Bispo Abrahão
@since 05/04/2019
@version 1.0
@return .F. / .T.
@type function
/*/
User Function MT110LOK()
	
	// Declaração de variaveis
	Local _lRet	:= .T.
	
	// Busca posição do campos
	Local _nPosLcV	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XXLCVAL'})
	Local _nPosQtd	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_QUANT'})
	Local _nPosLcT	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XXLCTOT'})
	Local _nPosPrd	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_PRODUTO'})
	Local _nPosDesc	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_DESCRI'})
	Local _nPosFor	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_FORNECE'})
	Local _nPosCC	:= aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_CC'})

	Local dDataInc
	Local aAreaSC1	:= SC1->(GetArea())
	
	If Empty(cCC) .AND. !Empty(aCols[n][_nPosCC])
		cCC := aCols[n][_nPosCC]
	EndIf

	If Empty( aCols[n][_nPosDesc] )
		aCols[n][_nPosDesc] := Posicione("SB1",1,xFilial("SB1")+aCols[n][_nPosPrd],"B1_DESC")
	EndIf

	// Validação a ser executada
	//If __cUserId $ cAlmox
		//aCols[n][_nPosLcV] := 0
	If Empty( aCols[n][_nPosLcV] ) .AND. Empty( aCols[n][_nPosFor] )// Valor estimado não informado
		If "UNI" $ aCols[n][_nPosPrd] .OR. "EPI" $ aCols[n][_nPosPrd]
			CN9->(dbSetOrder(1))
			If CN9->(dbSeek(xFilial("CN9")+cCC,.F.))  // Existe contrato para este centro de custo

				dDataInc := CTOD(CN9->(FWLeUserlg("CN9_USERGI", 2)))
				//If EMPTY(CN9->CN9_REVISA) .AND. dDataInc > CTOD("04/04/2019")
				If CN9->CN9_DTINIC > CTOD("04/04/2019") .OR. dDataInc > CTOD("04/04/2019")
					MsgStop("Preencha o valor estimado do produto","MT110LOK - A T E N Ç Ã O !!")
					_lRet := .F. // Quando false o sistema não permitirá que o usuário prossiga para a proxima linha
				EndIf
			Else
				CTT->(dbSetOrder(1))
				If CTT->(dbSeek(xFilial("CTT")+cCC,.F.))
					dDataInc := CTOD(CTT->(FWLeUserlg("CTT_USERGI", 2)))
					If dDataInc > CTOD("04/04/2019")
						MsgStop("Preencha o valor estimado do produto","MT110LOK - A T E N Ç Ã O !!")
						_lRet := .F. // Quando false o sistema não permitirá que o usuário prossiga para a proxima linha
					EndIf
				EndIf
			EndIf	                                                               
		Else
			u_MsgLog("MT110LOK","O valor estimado do produto não foi informado","W")
		EndIf
		//EndIf
		//If Empty( aCols[n][_nPosCc] ) // Se o campo Centro de Custo estiver vazio
		//	MsgStop("Preencha o campo Centro de Custo"	,"A T E N Ç Ã O !!")
		//	_lRet := .F. // Quando false o sistema não permitirá que o usuário prossiga para a proxima linha
		//EndIf
	EndIf
	
	// Total estimado
	aCols[n][_nPosLcT] := aCols[n][_nPosLcV] * aCols[n][_nPosQtd]

	SC1->(RestArea(aAreaSC1))
Return _lRet
