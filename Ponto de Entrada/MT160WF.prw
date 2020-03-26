#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT160WF    ºAutor  ³Adilso do Prado     º Data ³  15/02/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºPonto de Entrada para envio Pedido de Compras para Liberação Alçada    º±±
±±ºapos a cotação                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MT160WF()
Return U_MT161WF()

User Function MT161WF()
Local nCotacao  := PARAMIXB[1]
Local cAssunto	:= ""
Local cEmail	:= ""
Local cEmailCC  := "" //microsiga@bkconsultoria.com.br;"
Local cMsg 		:= "" 
Local cAnexo	:= ""
Local _lJob		:= .F.
Local aCabs		:= {}
Local aEmail	:= {}
Local aPedAlmx	:= {}
Local aMotivo	:= {}
Local aPedido	:= {}
Local cNUser	:= ""
Local cUser 	:= ""
Local cNumPC	:= ""
Local cForPagto := ""
Local aUser 	:= {}
Local cGerGestao  := ALLTRIM(GetMv("MV_XXGGCT"))
Local cGerCompras := ALLTRIM(GetMv("MV_XXGCOM"))
Local nTotPed 	:= 0
Local cXXJUST 	:= ""
Local aSC1USER 	:= {} 

Private cXXOBS   := Space(TamSX3("C7_XXOBS")[1]) 
Private cXXURGEN := Space(TamSX3("C7_XXURGEN")[1])

AADD(aMotivo,"Início de Contrato")
AADD(aMotivo,"Reposição Programada")
AADD(aMotivo,"Reposição Eventual") 

cAlmox := ""
cAlmox := SuperGetMV("MV_XXGRALX",.F.,"000021")  
cAlEmail := ""
cAlEmail := "microsiga@bkconsultoria.com.br;"

aUsers:=AllUsers()

For nX_ := 1 to Len(aUsers)
	If Len(aUsers[nX_][1][10]) > 0 .AND. !aUsers[nX_][1][17] //USUARIO BLOQUEADO
		aGrupo := {}
//		AADD(aGRUPO,aUsers[nX_][1][10])
//		FOR i:=1 TO LEN(aGRUPO[1])
//			lAlmox := (aGRUPO[1,i] $ cAlmox)
//		NEXT
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


aPedido := {}

DbSelectArea("SC8")
SC8->(DbSetOrder(1))
SC8->(DbSeek(xFilial("SC8")+nCotacao,.T.))
Do While SC8->(!eof()) .AND. SC8->C8_NUM == nCotacao 
   	IF SC8->C8_NUM == nCotacao  .AND. SC8->C8_NUMPED <> "XXXXXX" .AND.  !EMPTY(SC8->C8_NUMPED)
		nPedido := 0
		nPedido := ASCAN(aPedido,{|x| x == ALLTRIM(SC8->C8_NUMPED)})
		IF nPedido == 0	
			AADD(aPedido,ALLTRIM(SC8->C8_NUMPED))
		ENDIF		         
	ENDIF
	SC8->(DbSkip())
ENDDO                                                                                                                                                                                                  


IF LEN(aPedido) < 1
   RETURN NIL
ENDIF


// Alterar dados complementares do pedido de compras
DbSelectArea("SC7")
DbSeek(xFilial("SC7")+aPedido[1],.T.)
cXXOBS   := SC7->C7_XXOBS
cXXURGEN := SC7->C7_XXURGEN

U_BKALTSC7()

cXXJUST := ""
aSC1USER:= {} 

FOR IX_ := 1 TO LEN(aPedido)
	cAssunto:= "Solicitação de Liberação do Pedido de Compra nº.:"+alltrim(aPedido[IX_])+"       "+DTOC(DATE())+"-"+TIME()+" - "+ALLTRIM(SM0->M0_NOME)
	DbSelectArea("SC7")
	DbSeek(xFilial("SC7")+aPedido[IX_],.T.)
	
	// Gravar os campos da tela 
	RecLock("SC7",.F.)
	SC7->C7_XXOBS   := cXXOBS
	SC7->C7_XXURGEN := cXXURGEN
	MsUnlock()
	
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
	
	AADD(aEmail,{"Pedido Compra Nº: "+cNumPC,"","","","","<b>Total do Pedido:</b>","<b>"+TRANSFORM(nTotPed,"@E 999,999,999.99")+"</b>","","","","","","","","","Comprador: "+cNUser})
	AADD(aEmail,{"","","","","","","","","","","","","","","",""})
  
	lContrato := .T.
	DbSelectArea("SC7")
	DbSeek(xFilial("SC7")+aPedido[IX_],.T.)
	
	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)
	
	DbSelectArea("SC7")
	Do While SC7->(!eof()) .AND. SC7->C7_NUM == cNumPC
		DbSelectArea("SC1")
		SC1->(DbSetOrder(1))
		IF SC1->(DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC,.F.))

			cXXJUST  += IIF(SC1->C1_XXJUST $ cXXJUST,"",SC1->C1_XXJUST)
			nScan:= 0
    		nScan:= aScan(aSC1USER,{|x| x[1]== SC1->C1_USER }) 
			IF nScan == 0 
				AADD(aSC1USER,{SC1->C1_USER})
            ENDIF
            
			AADD(aPedAlmx,{SC7->C7_ITEM,SC7->C7_PRODUTO,SC7->C7_DESCRI,SC7->C7_UM,STR(SC7->C7_QUANT,6,2),TRANSFORM(SC7->C7_PRECO,"@E 999,999,999.99"),TRANSFORM(SC7->C7_TOTAL,"@E 999,999,999.99"),SC7->C7_OBS,SC1->C1_CC,SC1->C1_XXDCC,SC1->C1_SOLICIT})
 
	   		AADD(aEmail,{SC1->C1_SOLICIT,SC1->C1_NUM,SC1->C1_ITEM,SC1->C1_PRODUTO,SC1->C1_DESCRI,SC1->C1_UM,STR(SC1->C1_QUANT-SC1->C1_XXQEST,6,2),DTOC(SC1->C1_EMISSAO),DTOC(SC1->C1_DATPRF),aMotivo[val(SC1->C1_XXMTCM)],TRANSFORM(SC1->C1_XXLCVAL,"@E 999,999,999.99"),TRANSFORM(SC1->C1_XXLCTOT,"@E 999,999,999.99"),"<b>Obs: "+SC1->C1_OBS,"<b>Contrato: "+SC1->C1_CC,"<b>Desc.Contr: "+SC1->C1_XXDCC,"<b>Objeto: "+SC1->C1_XXOBJ})
	   		IF SM0->M0_CODIGO == "01" .AND. SC1->C1_CC >= '000000001' .AND. SC1->C1_CC <= '000008001'
				lContrato := .F.
	   		ELSE
	   			lContrato := .T.
	   		ENDIF
/*

	   		IF SM0->M0_CODIGO == "01" .AND. SC1->C1_CC > '000008001'
	   			lContrato := .T.
	   		ELSEIF SM0->M0_CODIGO == "02" .AND. SC1->C1_CC >= '000000001'
	   			lContrato := .T.
	   		ELSEIF SM0->M0_CODIGO == "04" .AND. SC1->C1_CC >= '000000001'
	   			lContrato := .T.
	   		ELSEIF SM0->M0_CODIGO == "06" //.AND. SC1->C1_CC >= '000000001'
	   			lContrato := .T.
	   		ELSEIF SM0->M0_CODIGO == "07" .AND. SC1->C1_CC <> '000000001'
	   			lContrato := .T.
	   		ELSEIF SM0->M0_CODIGO == "08" //.AND. SC1->C1_CC <> '000000001'
	   			lContrato := .T.
	   		ELSEIF SM0->M0_CODIGO == "09" //.AND. SC1->C1_CC <> '000000001'
	   			lContrato := .T.
	   		ELSEIF SM0->M0_CODIGO == "10" //.AND. SC1->C1_CC <> '000000001'
	   			lContrato := .T.
	   		ELSE
	   			lContrato := .F.
	   		ENDIF
  */	   		
   			aITx_ := {}
			DbSelectArea("SC8")
			SC8->(DbSetOrder(1))
			SC8->(DbSeek(xFilial("SC8")+SC7->C7_NUMCOT,.T.))
	    	Do While SC8->(!eof()) .AND. SC8->C8_NUM==SC7->C7_NUMCOT 
				IF SC8->C8_NUMSC==SC1->C1_NUM  .AND. SC8->C8_ITEMSC == SC1->C1_ITEM    		
	    	    	cForPagto := "For.Pgto: "+IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,SC7->C7_COND,SC8->C8_COND)+" - "+Posicione("SE4",1,xFilial("SE4")+IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,SC7->C7_COND,SC8->C8_COND),"E4_DESCRI")
		   		    AADD(aITx_,{"",SC8->C8_NUM,SC8->C8_ITEM,SC8->C8_PRODUTO,C8_XXDESCP,SC8->C8_UM,STR(SC8->C8_QUANT,6,2),SC8->C8_EMISSAO,IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,SC7->C7_DATPRF,""),IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,"Vencedor",""),TRANSFORM(SC8->C8_PRECO,"@E 999,999,999.99"),TRANSFORM(SC8->C8_TOTAL,"@E 999,999,999.99"),cForPagto,"Cod.For: "+SC8->C8_FORNECE,"Fornecedor: "+SC8->C8_XXNFOR,"Validade da Proposta: "+DTOC(SC8->C8_VALIDA)+"      "+IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM,IIF(ALLTRIM(SC8->C8_MOTIVO) == "ENCERRADO AUTOMATICAMENTE","X - Vencedor Indicado Pelo Sistema","* - Fornecedor Selecionado Pelo Usuário"),"")+IIF(!EMPTY(SC8->C8_OBS),"   OBS:"+SC8->C8_OBS,"")})
				ENDIF
				SC8->(DbSkip())
			ENDDO                                                                                                                                                                                                  
			For IY_ := 1 TO LEN(aITx_)
	 			AADD(aEmail,{"Cotação: "+STRZERO(IY_,2)+"/"+STRZERO(LEN(aITx_),2),aITx_[IY_,2],aITx_[IY_,3],aITx_[IY_,4],aITx_[IY_,5],aITx_[IY_,6],aITx_[IY_,7],aITx_[IY_,8],aITx_[IY_,9],aITx_[IY_,10],aITx_[IY_,11],aITx_[IY_,12],aITx_[IY_,13],aITx_[IY_,14],aITx_[IY_,15],aITx_[IY_,16]})
			NEXT

		ENDIF
	
		//PULA LINHA
		AADD(aEmail,{"","","","","","","","","","","","","","","",""})
		AADD(aEmail,{"","","","","","","","","","","","","","","",""})
		
		SC7->(DbSkip())
	ENDDO
	
 	cEmail := "microsiga@bkconsultoria.com.br;"
	
	DbSelectArea("SCR")
	SCR->(DbSetOrder(1))
	DbSeek(xFilial("SCR")+'PC'+cNumPC,.T.)
	Do While SCR->(!eof()) .AND. ALLTRIM(SCR->CR_NUM) == ALLTRIM(cNumPC)
		IF lContrato
			IF SCR->CR_USER $ cGerGestao
				PswOrder(1) 
				PswSeek(SCR->CR_USER) 
				aUser  := PswRet(1)
				IF !EMPTY(aUser[1,14])  .AND. !aUser[1][17]
					cEmail += ALLTRIM(aUser[1,14])+';'
				ENDIF
			ELSEIF SCR->CR_USER $ cGerCompras
				RecLock("SCR",.F.)
				SCR->(dbDelete())
				SCR->(MsUnlock())
			ENDIF
		ELSE
			IF SCR->CR_USER $ cGerCompras
				PswOrder(1) 
				PswSeek(SCR->CR_USER) 
				aUser  := PswRet(1)
				IF !EMPTY(aUser[1,14])  .AND. !aUser[1][17]
					cEmail += ALLTRIM(aUser[1,14])+';'
				ENDIF
			ELSEIF SCR->CR_USER $ cGerGestao
				RecLock("SCR",.F.)
				SCR->(dbDelete())
				SCR->(MsUnlock())
			ENDIF
		ENDIF

	    SCR->(dbskip())
	Enddo

 	//EMAIL SOLICITANTE
 	FOR _IX := 1 TO LEN(aSC1USER)
		PswOrder(1) 
		PswSeek(aSC1USER[_IX,1]) 
		aUser  := PswRet(1)
		IF !EMPTY(aUser[1,14])  .AND. !aUser[1][17]
			cEmail += ALLTRIM(aUser[1,14])+';'
		ENDIF
 	NEXT

	IF 	!EMPTY(cXXJUST)
    	cJust := ""
		nJust := 0
		nJust := MLCOUNT(cXXJUST,80)
		FOR xi := 1 TO nJust
   			cJust += MemoLine(cXXJUST,80,xi)+" "
		NEXT    
		AADD(aEmail,{"<b>Justificativa: </b>"+cJust+"</blockquote>"})
	ENDIF
	
	aCabs   := {"Solicitante/Cotação","Cod.","Item","Cod Prod.","Descrição Produto","UM","Quant","Emissao","Limite Entrega","Motivo/Status Cotação","Val.Licitação/Val.Cotado","Tot.Licitação/Tot.Cotado","OBS/For.Pgto","Contrato/Forn.","Descrição Contrato/Nome Forn.","Detalhes"}
	
	  
	cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,"MT160WF")

	cMsg    := STRTRAN(cMsg,"><b>Justificativa:"," colspan="+str(len(aCabs))+'><blockquote style="text-align:left;font-size:14.0"><b>Justificativa:')

	
	U_SendMail("MT160WF",cAssunto,cEmail,cEmailCC,cMsg,cAnexo,_lJob)
	_lJob		:= .T.

	//Pedido de Compras para Almoxarifado    

	cAssunto:= "Pedido de Compra nº.: "+alltrim(aPedido[IX_])+"   Fornecedor: "+SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+SA2->A2_NOME+"  "+DTOC(DATE())+"-"+TIME()+" - "+ALLTRIM(SM0->M0_NOME)
	aCabs   := {"Item","Cod. Produto","Descr. Produto","UM","Quant.","Valor Unit.","Total Item","OBS","Centro de Custo","Descr. Centro de Custo","Solicitante"} 
	cMsg    := u_GeraHtmA(aPedAlmx,cAssunto,aCabs,"MT160WF")
	U_SendMail("MT160WF",cAssunto,cAlEmail,cEmailCC,cMsg,"",.T.)
	
NEXT

Return Nil




// Alteração da observação e da urgencia do pedido de compras - Marcos - BK 31/01/17

// Alteração da observação e da urgencia do pedido de compras - Marcos - BK 31/01/17

User Function BKALTSC7()
Local aArea := Getarea()             
Local oOk
Local oNo
Local oDlg
Local oPanelLeft
Local aButtons 	:= {}
Local lOk      	:= .F.
Local cTitulo2 	:= "BKALTSC7 - Dados complementares - Pedido de Compras"
Local cXXOBS2	:= ""
Local cItens 	:= ""
Local aItens 	:= {'Sim','Não'}

// PARA TESTE
cXXOBS   := SC7->C7_XXOBS
cXXURGEN := SC7->C7_XXURGEN
	
oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

cItens := IIF(SUBSTR(cXXURGEN,1,1)='S',"Sim","Não")
cXXOBS2:= cXXOBS

nLin := 10

DO WHILE .T.	

	DEFINE MSDIALOG oDlg TITLE cTitulo2 FROM 000,000 TO 240,550 PIXEL
	@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 530,230  // P12
	oPanelLeft:Align := CONTROL_ALIGN_LEFT

	@ nLin,010 SAY 'Pedido urgente?' PIXEL SIZE 50,10 OF oPanelLeft
	@ nLin,070 COMBOBOX cItens ITEMS aItens SIZE 100,50  PIXEL SIZE 130,10 OF oPanelLeft    
	nLin += 25
	  
	@ nLin,010 SAY 'Observação' PIXEL SIZE 50,10 OF oPanelLeft
	oMemo:= tMultiget():New(35,70,{|u|if(Pcount()>0,cXXOBS2:=u,cXXOBS2)},oPanelLeft,190,30,,,,,,.T.) 

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , @aButtons)
		
	If ( lOk )
	    cXXURGEN 	:= cItens
	    cXXOBS		:= cXXOBS2
		lOk := .F.
		EXIT
	Else
		EXIT
	EndIf
	
ENDDO
		                   
Restarea( aArea )
          
RETURN lOk

