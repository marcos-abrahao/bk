#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT120FIM
Ponto de Entrada para envio Pedido de Compras para Libera��o Al�ada apos a altera��o ou inclusao
@Return
@author Adilson do Prado
@since 05/11/15 - rev 23/09/20
@version P12
/*/
User Function MT120FIM()
Local nOpcao := PARAMIXB[1]   // Op��o Escolhida pelo usuario 
Local cNumPC := PARAMIXB[2]   // Numero do Pedido de Compras
Local nOpcA  := PARAMIXB[3]   // Indica se a a��o foi Cancelada = 0  ou Confirmada = 1
Local lAprov := .T.
Local cAssunto	:= ""
Local cEmail	:= ""
Local cEmailCC  := ""
Local cMsg 		:= "" 
Local cAnexo	:= ""
Local aCabs		:= {}
Local aEmail	:= {}
Local aPedAlmx	:= {}
Local aMotivo	:= {}
Local cNUser	:= ""
Local cUser 	:= ""
Local cForPagto := ""
Local aUser 	:= {}
Local aSuper	:= {}
Local cGerGestao  := u_GerGestao()
Local cGerCompras := u_GerCompras()
Local nTotPed 	:= 0
Local cXXJUST 	:= ""
Local aSC1USER  := {}
Local IY_,xi,_IX
//Local cCrLf   	:= Chr(13) + Chr(10)

IF (nOpcao == 3 .OR. nOpcao == 4) .AND. nOpcA == 1

	AADD(aMotivo,"In�cio de Contrato")
	AADD(aMotivo,"Reposi��o Programada")
	AADD(aMotivo,"Reposi��o Eventual") 
	
	cAlEmail := u_EmailAdm()
	
	/*
	//aUsers:=AllUsers()
	
	For nX_ := 1 to Len(aUsers)
		If Len(aUsers[nX_][1][10]) > 0 .AND. !aUsers[nX_][1][17] //USUARIO BLOQUEADO
			aGrupo := {}
			//AADD(aGRUPO,aUsers[nX_][1][10])
			//FOR i:=1 TO LEN(aGRUPO[1])
			//	lAlmox := (aGRUPO[1,i] $ cAlmox)
			//NEXT
			//Ajuste nova rotina a antiga n�o funciona na nova lib MDI
			aGRUPO := UsrRetGrp(aUsers[nX_][1][2])
			IF LEN(aGRUPO) > 0
				FOR i:=1 TO LEN(aGRUPO)
					lAlmox := (ALLTRIM(aGRUPO[i]) $ cAlmox )
				NEXT
			ENDIF	
	    	If lAlmox
	    		cAlEmail += ALLTRIM(aUsers[nX_][1][14])+";"
	    	ENDIF
	 	ENDIF
	NEXT
	*/

	cAlEmail  += u_EmEstAlm(__cUserId,.T.)

	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	SC7->(DbSeek(xFilial("SC7")+cNumPC,.T.))
    DO WHILE SC7->(!EOF()) .AND. SC7->C7_NUM==cNumPC
	
		If Empty(SC7->C7_XXNCC) .AND. !EMPTY(SC7->C7_CC)
			RecLock("SC7",.F.)
			SC7->C7_XXNCC := Posicione("CTT",1,xFilial("CTT")+SC7->C7_CC,"CTT_DESC01")
			SC7->(MsUnLock())
		EndIf

    	IF SC7->C7_CONAPRO=="B"
 			lAprov := .F.
    	ENDIF
		SC7->(dbskip())
	ENDDO    

	IF !lAprov
		cAssunto:= "Solicita��o de Libera��o do Pedido de Compra "+alltrim(cNumPC)+" - "+FWEmpName(cEmpAnt)
		DbSelectArea("SC7")
		DbSeek(xFilial("SC7")+cNumPC,.T.)
		cUser := SC7->C7_USER
		cNumPC:= SC7->C7_NUM
		aEmail:= {}
		aPedAlmx := {}
		
		PswOrder(1) 
		PswSeek(cUser) 
		aUser  := PswRet(1)
		IF !EMPTY(aUser)
			cNUser := aUser[1,2]
		ENDIF
		
		nTotPed := 0
		Do While SC7->(!eof()) .AND. SC7->C7_NUM == cNumPC
			nTotPed += SC7->C7_TOTAL
			SC7->(DbSkip())
		ENDDO
		
		AADD(aEmail,{"Pedido Compra N�: "+cNumPC,"","","","","<b>Total do Pedido:</b>","<b>"+TRANSFORM(nTotPed,"@E 999,999,999.99")+"</b>","","","","","","","","","Comprador: "+cNUser})
		AADD(aEmail,{"","","","","","","","","","","","","","","",""})
	  
		lContrato := .T.
		DbSelectArea("SC7")
		DbSeek(xFilial("SC7")+cNumPC,.T.)
	
		cXXJUST := ""
		aSC1USER := {}
						
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)
		
		DbSelectArea("SC7")
		Do While SC7->(!eof()) .AND. SC7->C7_NUM == cNumPC
			DbSelectArea("SC1")
			SC1->(DbSetOrder(1))
			IF SC1->(DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC,.F.))
			
				cXXJUST += IIF(SC1->C1_XXJUST $ cXXJUST,"",SC1->C1_XXJUST) 

				nScan:= 0
   				nScan:= aScan(aSC1USER,{|x| x[1]== SC1->C1_USER }) 
				IF nScan == 0 
					AADD(aSC1USER,{SC1->C1_USER})
        		ENDIF

				AADD(aPedAlmx,{SC7->C7_ITEM,SC7->C7_PRODUTO,SC7->C7_DESCRI,SC7->C7_UM,STR(SC7->C7_QUANT,6,2),TRANSFORM(SC7->C7_PRECO,"@E 999,999,999.99"),TRANSFORM(SC7->C7_TOTAL,"@E 999,999,999.99"),SC7->C7_OBS,SC1->C1_CC,SC1->C1_XXDCC,SC1->C1_SOLICIT})
	 
		   		AADD(aEmail,{SC1->C1_SOLICIT,SC1->C1_NUM,SC1->C1_ITEM,SC1->C1_PRODUTO,SC1->C1_DESCRI,SC1->C1_UM,STR(SC1->C1_QUANT,6,2),DTOC(SC1->C1_EMISSAO),DTOC(SC1->C1_DATPRF),aMotivo[val(SC1->C1_XXMTCM)],TRANSFORM(SC1->C1_XXLCVAL,"@E 999,999,999.99"),TRANSFORM(SC1->C1_XXLCTOT,"@E 999,999,999.99"),"<b>Obs: "+SC1->C1_OBS,"<b>Contrato: "+SC1->C1_CC,"<b>Desc.Contr: "+SC1->C1_XXDCC,"<b>Objeto: "+SC1->C1_XXOBJ})
		   		IF SM0->M0_CODIGO == "01" .AND. SC1->C1_CC >= '000000001' .AND. SC1->C1_CC <= '000008001'
					lContrato := .F.
		   		ELSE
		   			lContrato := .T.
		   		ENDIF

	   			aITx_ := {}
				DbSelectArea("SC8")
				SC8->(DbSetOrder(1))
				SC8->(DbSeek(xFilial("SC8")+SC7->C7_NUMCOT,.T.))
		    	Do While SC8->(!eof()) .AND. SC8->C8_NUM==SC7->C7_NUMCOT 
					IF SC8->C8_NUMSC==SC1->C1_NUM  .AND. SC8->C8_ITEMSC == SC1->C1_ITEM    		
		    	    	cForPagto := "For.Pgto: "+IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,SC7->C7_COND,SC8->C8_COND)+" - "+Posicione("SE4",1,xFilial("SE4")+IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,SC7->C7_COND,SC8->C8_COND),"E4_DESCRI")
			   		    AADD(aITx_,{"",SC8->C8_NUM,SC8->C8_ITEM,SC8->C8_PRODUTO,C8_XXDESCP,SC8->C8_UM,STR(SC8->C8_QUANT,6,2),SC8->C8_EMISSAO,IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,SC7->C7_DATPRF,""),IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,"Vencedor",""),TRANSFORM(SC8->C8_PRECO,"@E 999,999,999.99"),TRANSFORM(SC8->C8_TOTAL,"@E 999,999,999.99"),cForPagto,"Cod.For: "+SC8->C8_FORNECE,"Fornecedor: "+SC8->C8_XXNFOR,"Validade da Proposta: "+DTOC(SC8->C8_VALIDA)+"      "+IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM,IIF(ALLTRIM(SC8->C8_MOTIVO) == "ENCERRADO AUTOMATICAMENTE","X - Vencedor Indicado Pelo Sistema","* - Fornecedor Selecionado Pelo Usu�rio"),"")+IIF(!EMPTY(SC8->C8_OBS),"   OBS:"+SC8->C8_OBS,"")})
					ENDIF
					SC8->(DbSkip())
				ENDDO                                                                                                                                                                                                  
				For IY_ := 1 TO LEN(aITx_)
		 			AADD(aEmail,{"Cota��o: "+STRZERO(IY_,2)+"/"+STRZERO(LEN(aITx_),2),aITx_[IY_,2],aITx_[IY_,3],aITx_[IY_,4],aITx_[IY_,5],aITx_[IY_,6],aITx_[IY_,7],aITx_[IY_,8],aITx_[IY_,9],aITx_[IY_,10],aITx_[IY_,11],aITx_[IY_,12],aITx_[IY_,13],aITx_[IY_,14],aITx_[IY_,15],aITx_[IY_,16]})
				NEXT
	
			ENDIF
		
			//PULA LINHA
			AADD(aEmail,{"","","","","","","","","","","","","","","",""})
			AADD(aEmail,{"","","","","","","","","","","","","","","",""})
			
			SC7->(DbSkip())
		ENDDO
		
	 	cEmail := u_EmailAdm()
		DbSelectArea("SCR")
		SCR->(DbSetOrder(1))
		DbSeek(xFilial("SCR")+'PC'+cNumPC,.T.)
		Do While SCR->(!eof()) .AND. ALLTRIM(SCR->CR_NUM) == ALLTRIM(cNumPC)
			IF lContrato
				IF SCR->CR_USER $ cGerGestao
					PswOrder(1) 
					PswSeek(SCR->CR_USER) 
					aUser  := PswRet(1)
					IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
						cEmail += ALLTRIM(aUser[1,14])+';'
					ENDIF
				// 13/07/23 - Remover Trecho para Michele Liberar
				//ELSEIF SCR->CR_USER $ cGerCompras
				//	RecLock("SCR",.F.)
				//	SCR->(dbDelete())
				//	SCR->(MsUnlock())
				ENDIF
			ELSE
				IF SCR->CR_USER $ cGerCompras
					PswOrder(1) 
					PswSeek(SCR->CR_USER) 
					aUser  := PswRet(1)
					IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
						cEmail += ALLTRIM(aUser[1,14])+';'
					ENDIF
				ELSEIF SCR->CR_USER $ cGerGestao .AND. cEmpAnt <> "20" // Barcas 17/02/25
					RecLock("SCR",.F.)
					SCR->(dbDelete())
					SCR->(MsUnlock())
				ENDIF
			ENDIF
	
		    SCR->(dbskip())
		Enddo

		IF !EMPTY(cXXJUST)
		    cJust := ""
  			nJust := 0
  			nJust := MLCOUNT(cXXJUST,80)
	   		FOR xi := 1 TO nJust
	       		cJust += MemoLine(cXXJUST,80,xi)+" "
       		NEXT    
  			AADD(aEmail,{"<b>Justificativa: </b>"+cJust+"</blockquote>"})
		ENDIF

 		//EMAIL SOLICITANTE
 		FOR _IX := 1 TO LEN(aSC1USER)
			//PswOrder(1) 
			//PswSeek(aSC1USER[_IX,1]) 
			//aUser  := PswRet(1)
			//IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
			//	cEmail += ALLTRIM(aUser[1,14])+';'
			//ENDIF

			cEmail += u_aUsrEmail({aSC1USER[_IX,1]},cEmail)
			// Barcas 02/04/25
			If cEmpAnt == "20"
				aSuper := u_ArSuper(aSC1USER[_IX,1])
				cEmail += u_aUsrEmail(aSuper,cEmail)
			EndIf				
 		NEXT
		
		aCabs   := {"Solicitante/Cota��o","Cod.","Item","Cod Prod.","Descri��o Produto","UM","Quant","Emissao","Limite Entrega","Motivo/Status Cota��o","Val.Licita��o/Val.Cotado","Tot.Licita��o/Tot.Cotado","OBS/For.Pgto","Contrato/Forn.","Descri��o Contrato/Nome Forn.","Detalhes"}
		  
		cMsg    := u_GeraHtmB(aEmail,cAssunto,aCabs,"MT120FIM","",cEmail,cEmailCC)

		cMsg    := STRTRAN(cMsg,"><b>Justificativa:"," colspan="+str(len(aCabs))+'><blockquote style="text-align:left;font-size:14.0"><b>Justificativa:')

		cAnexo := "MT120FIM"+alltrim(cNumPC)+"a.html"
		u_GrvAnexo(cAnexo,cMsg,.T.)			

		u_BkSnMail("MT120FIM",cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)

	
		//Pedido de Compras para Almoxarifado    
	
		cAssunto:= "Pedido de Compra "+alltrim(cNumPC)+" - Fornecedor: "+SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+TRIM(SA2->A2_NOME)+"  "+DTOC(DATE())+"-"+TIME()+" - "+FWEmpName(cEmpAnt)
		aCabs   := {"Item","Cod. Produto","Descr. Produto","UM","Quant.","Valor Unit.","Total Item","OBS","Centro de Custo","Descr. Centro de Custo","Solicitante"} 
		cMsg    := u_GeraHtmB(aPedAlmx,cAssunto,aCabs,"MT120FIM","",cEmail,cEmailCC)

		cAnexo := "MT120FIM"+alltrim(cNumPC)+"b.html"
		u_GrvAnexo(cAnexo,cMsg,.T.)

		u_BkSnMail("MT120FIM",cAssunto,cAlEmail,cEmailCC,cMsg,{cAnexo},.T.)

	ENDIF
ENDIF

Return nil
