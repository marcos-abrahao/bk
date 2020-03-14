#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT140SAI  ºAutor  ³Adilson do Prado    º Data ³  04/06/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este ponto de entrada tem o objetivo de eviar a-mail       º±±
±±º            para o grupo de compras, quando NF diferente do pedido     º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


USER FUNCTION MT140SAI()
Local nOrdem := SF1->( IndexOrd() )
Local cAssunto	:= ""
Local cEmail	:= "microsiga@bkconsultoria.com.br;"
Local cEmailCC  := "" 
Local cMsg 		:= "" 
Local cAnexo	:= ""
Local _lJob		:= .F.
Local aCabs		:= {}
Local aEmail	:= {}
//Local cGerGestao := ALLTRIM(GetMv("MV_XXGGCT"))
//Local cGerCompras := ALLTRIM(GetMv("MV_XXGCOM"))

If EMPTY(ParamIxb[2] + ParamIxb[3] + ParamIxb[4] + ParamIxb[5])
   // 09/01/15 ->Para evitar execução duas vezes no retorno para o browser
   Return Nil
EndIf

If ParamIxb[1] == 3 .OR. ParamIxb[1] == 4 .OR. ParamIxb[1] == 5 // Inclusão ou Alteração ou exclusão
   SF1->( dbSetOrder( 1 ) )
   IF ParamIxb[1] == 5     // 09/01/15 -> Enviar mensagem de cancelamento de solicitação de liberação
   		SET DELETED OFF
   ENDIF
   SF1->( MsSeek( xFilial( 'SF1' ) + ParamIxb[2] + ParamIxb[3] + ParamIxb[4] + ParamIxb[5] ) ) 
   IF SF1->F1_STATUS == 'B'

		lContrato := .T.
   		dbSelectArea("SD1") 
    	dbSetOrder(1)
		dbSeek(xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
		DO WHILE !EOF() .AND. xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == ;
                          SD1->D1_FILIAL+SD1->D1_DOC+ SD1->D1_SERIE+ SD1->D1_FORNECE+ SD1->D1_LOJA
	   		IF SM0->M0_CODIGO == "01" .AND. SD1->D1_CC >= '000000001' .AND. SD1->D1_CC <= '000008001'
	   			lContrato := .F.
	   		ELSE
	   			lContrato := .T.
	   		ENDIF

/*
	   		IF SM0->M0_CODIGO == "01" .AND. SD1->D1_CC > '000008001'
	   			lContrato := .T.
	   		ELSEIF SM0->M0_CODIGO == "02" .AND. SD1->D1_CC >= '000000001'
	   			lContrato := .T.
	   		ELSEIF SM0->M0_CODIGO == "04" .AND. SD1->D1_CC >= '000000001'
	   			lContrato := .T.
	   		ELSEIF SM0->M0_CODIGO == "06" //.AND. SD1->D1_CC >= '000000001'
	   			lContrato := .T.
	   		ELSEIF SM0->M0_CODIGO == "07" .AND. SD1->D1_CC >= '000000001'
	   			lContrato := .T.
	   		ELSEIF SM0->M0_CODIGO == "08" //.AND. SD1->D1_CC >= '000000001'
	   			lContrato := .T.
	   		ELSEIF SM0->M0_CODIGO == "09" //.AND. SD1->D1_CC >= '000000001'
	   			lContrato := .T.
	   		ELSEIF SM0->M0_CODIGO == "10" //.AND. SD1->D1_CC >= '000000001'
	   			lContrato := .T.
	   		ELSEIF SM0->M0_CODIGO == "11" //.AND. SD1->D1_CC >= '000000001'
	   			lContrato := .T.
	   		ELSE
	   			lContrato := .F.
            ENDIF
*/
       		SD1->(dbSkip())
    	ENDDO

		cEmail := "microsiga@bkconsultoria.com.br;"  
    	
		DbSelectArea("SCR")
		SCR->(DbSetOrder(1))
		DbSeek(xFilial("SCR")+'NF'+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.T.)
		Do While SCR->(!eof()) .AND. ALLTRIM(SCR->CR_NUM) == ALLTRIM(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
			/*
			IF lContrato
				IF SCR->CR_USER $ cGerCompras .OR. (SCR->CR_USER $ cGerGestao .AND. SCR->CR_APROV $ "000008/000027/000028/000029/000030/000031/000032/000033/000034/000035" )
					RecLock("SCR",.F.)
					SCR->(dbDelete())
					SCR->(MsUnlock())
				ENDIF
				IF SCR->CR_USER $ cGerGestao
					PswOrder(1) 
					PswSeek(SCR->CR_USER) 
					aUser  := PswRet(1)
					IF !EMPTY(aUser[1,14])  .AND. !aUser[1][17]
						cEmail += ALLTRIM(aUser[1,14])+';'
					ENDIF
				ENDIF
			ELSE
				IF SCR->CR_USER $ cGerGestao .OR. (SCR->CR_USER $ cGerCompras  .AND. SCR->CR_APROV="000004" )
					RecLock("SCR",.F.)
					SCR->(dbDelete())
					SCR->(MsUnlock())
				ENDIF
				IF SCR->CR_USER $ cGerCompras 
					PswOrder(1) 
					PswSeek(SCR->CR_USER) 
					aUser  := PswRet(1)
					IF !EMPTY(aUser[1,14])  .AND. !aUser[1][17]
						cEmail += ALLTRIM(aUser[1,14])+';'
					ENDIF
				ENDIF
			ENDIF
            */
			IF ALLTRIM(SCR->CR_APROV)  $ '000013/000014' //enviar e-mail apenas para Sr. Marcio e Xavier
				PswOrder(1) 
				PswSeek(SCR->CR_USER) 
				aUser  := PswRet(1)
				IF !EMPTY(aUser[1,14])  .AND. !aUser[1][17]
					cEmail += ALLTRIM(aUser[1,14])+';'
				ENDIF
			ENDIF
                        
	    	SCR->(dbskip())
		Enddo
	
        IF ParamIxb[1] == 5
	  		cAssunto:= "Cancelamento de Solicitação de Liberação de Nota Fiscal excluida nº.:"+SF1->F1_DOC+" Série:"+SF1->F1_SERIE+"    "+DTOC(DATE())+"-"+TIME()+" - "+ALLTRIM(SM0->M0_NOME)
			aCabs   := {}
			aCabs   := {"Nota Fiscal nº.:","Série:"," Cod.For.:"," Loja:"}
			aEmail := {}
			AADD(aEmail,{SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA})

        ELSE
			cAssunto:= "Solicitação de Liberação de Nota Fiscal nº.:"+SF1->F1_DOC+" Série:"+SF1->F1_SERIE+"    Fornecedor: " +SA2->A2_COD+"-"+SA2->A2_LOJA+" - "+SA2->A2_NOME+"   "+DTOC(DATE())+"-"+TIME()+" - "+ALLTRIM(SM0->M0_NOME)

			aEmail := {}
			AADD(aEmail,{"Solicitante:"+UsrFullName(RetCodUsr())})
			AADD(aEmail,{"Fornecedor: "+SA2->A2_COD+"-"+SA2->A2_LOJA+" - "+SA2->A2_NOME,,,,,,"Total da NF:",U_GetValTot(.F.),,})
	
			cHIST:= ""
			dbSelectArea("SD1") 
   			dbSetOrder(1)
			dbSeek(xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
			DO WHILE !EOF() .AND. xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == ; 
					SD1->D1_FILIAL+SD1->D1_DOC+ SD1->D1_SERIE+ SD1->D1_FORNECE+ SD1->D1_LOJA

					AADD(aEmail,{"",SD1->D1_ITEM,SD1->D1_COD,SD1->D1_XXDESCP,SD1->D1_UM,SD1->D1_QUANT,SD1->D1_VUNIT,SD1->D1_TOTAL,SD1->D1_CC,SD1->D1_XXDCC})
					cHIST += IIF(SD1->D1_XXHIST $ cHIST,"",cHIST) 
				SD1->(dbskip())
			Enddo
  			AADD(aEmail,{"<b>Histórico: </b>"+cHIST})

			aCabs   := {}
			aCabs   := {"Solicitante/Fornecedor","Item","Cod. Produto","Descr. Produto","UM","Quant.","Valor Unit.","Total Item","Centro de Custo","Descr. Centro de Custo"}
   
	    ENDIF

		//cMsg    := "Solicitação de Liberação divergência com o pedido de compras Nota Fiscal nº.:"+SF1->F1_DOC+" Série:"+SF1->F1_SERIE+" Cod.For.:"+SF1->F1_FORNECE+" Loja:"+SF1->F1_LOJA+DTOC(DATE())+"-"+TIME()+" - "+ALLTRIM(SM0->M0_NOME)
		cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,"MT140SAI")
		cMsg    := STRTRAN(cMsg,"><b>Histórico:"," colspan=10 ><b>Histórico:")
		U_SendMail("MT140SAI",cAssunto,cEmail,cEmailCC,cMsg,cAnexo,_lJob)
   
   ENDIF
   IF ParamIxb[1] == 5
   		SET DELETED ON
   ENDIF
   SF1->( dbSetOrder( nOrdem ) )
EndIf
Return( NIL )
