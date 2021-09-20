#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BKCOMA04º      Adilson do Prado              Data ³07/02/13º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Aprovação do Pedido de Compras - Alçada					  º±±
±±º																		  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK Consultoria                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


User Function BKCOMA04()
Local oDlg
Local oListId
Local oPanelLeft
Local aButtons := {}
Local I		:= 0
Local Ix_	:= 0
Local _IX	:= 0
Local lOk      := .F.
Local nTotal := 0
Local cNUser:= ""
Local cUser := ""
Local cNumPC:= ""
Local cForPagto := ""
Local aUser := {}
Local aGRUPO := {}
Local aItems:= {}
Local aMotivo:= {}
Local nReg1 := SCR->(RecNo())
Local cMDiretoria := SuperGetMV("MV_XXGRPMD",.F.,"000007")
Local lMDiretoria := .F.
Local cMFinanceiro:= SUBSTR(SuperGetMV("MV_XXGRPMF",.F.,"000005"),1,6)
Local cXXJUST := ""

AADD(aMotivo,"Início de Contrato")
AADD(aMotivo,"Reposição Programada")
AADD(aMotivo,"Reposição Eventual")

//DBCLEARFILTER() 
PswOrder(1) 
PswSeek(__CUSERID) 
aUser  := PswRet(1)
IF !EMPTY(aUser[1,11])
   cSuper := SUBSTR(aUser[1,11],1,6)
ENDIF   

lMDiretoria := .F.
aGRUPO := {}
//AADD(aGRUPO,aUser[1,10])
//FOR i:=1 TO LEN(aGRUPO[1])
//	lMDiretoria := (aGRUPO[1,i] $ cMDiretoria)
//NEXT
//Ajuste nova rotina a antiga não funciona na nova lib MDI
aGRUPO := UsrRetGrp(aUser[1][2])
IF LEN(aGRUPO) > 0
	FOR i:=1 TO LEN(aGRUPO)
		lMDiretoria := (ALLTRIM(aGRUPO[i]) $ cMDiretoria )
	NEXT
ENDIF

If !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS $ "03#05"
	Help(" ",1,"A097LIB")
	  //Aviso(STR0038,STR0039,{STR0037},2) //"Atencao!"###"Este pedido ja foi liberado anteriormente. Somente os pedidos que estao aguardando liberacao (destacado em vermelho no Browse) poderao ser liberados."###"Voltar"
	Return NIL
ElseIf  SCR->CR_STATUS $ "01"
	Aviso("A097BLQ","Atenção",{"Esta operação não poderá ser realizada pois este registro se encontra bloqueado pelo sistema (aguardando outros niveis)"}) 
	Return NIL
EndIf

IF ASCAN(aUser[1,10],"000000") = 0 .AND. ASCAN(aUser[1,10],cMFinanceiro) = 0  .AND. !lMDiretoria
	DbSelectArea("SC7")
	SC7->(Dbsetorder(1))
	IF DbSeek(xFilial("SC7")+ALLTRIM(SCR->CR_NUM),.T.)
		Do While SC7->(!eof()) .AND. SCR->CR_NUM == SC7->C7_NUM
			DbSelectArea("SC1")
			SC1->(DbSetOrder(1))
			IF SC1->(DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC,.F.))
    	   		IF SC1->C1_USER == __cUserId
					Aviso("Atenção","Usuário não autorizado Liberar o próprio Pedido!!",{"OK"}) 
					Return NIL
    	   		ENDIF
    		ENDIF
			SC7->(DbSkip())
    	ENDDO
	ENDIF
ENDIF

nTotal := SCR->CR_TOTAL

lPedido := .F.   

DbSelectArea("SC7")
DbSeek(xFilial("SC7")+ALLTRIM(SCR->CR_NUM),.T.)
cNumPC:= ALLTRIM(SCR->CR_NUM)
aItems:= {}
Do While SC7->(!eof()) .AND. cNumPC == SC7->C7_NUM
	cUser := SC7->C7_USER
	lPedido := .T.

	DbSelectArea("SC1")
	SC1->(DbSetOrder(1))
	IF SC1->(DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC,.F.))
   		AADD(aItems,{SC1->C1_SOLICIT,SC1->C1_NUM,SC1->C1_ITEM,SC1->C1_PRODUTO,SC1->C1_DESCRI,SC1->C1_UM,SC1->C1_QUANT-SC1->C1_XXQEST,SC1->C1_EMISSAO,SC1->C1_DATPRF,aMotivo[val(SC1->C1_XXMTCM)],TRANSFORM(SC1->C1_XXLCVAL,"@E 999,999,999.99"),TRANSFORM(SC1->C1_XXLCTOT,"@E 999,999,999.99"),"Obs: "+SC1->C1_OBS,"Contrato: "+SC1->C1_CC,"Desc.Contr: "+SC1->C1_XXDCC,"Objeto: "+SC1->C1_XXOBJ})
		cXXJUST += IIF(SC1->C1_XXJUST $ cXXJUST,"",SC1->C1_XXJUST) 
   		aITx_ := {}
		DbSelectArea("SC8")
		SC8->(DbSetOrder(1))
		SC8->(DbSeek(xFilial("SC8")+SC7->C7_NUMCOT,.T.))
	    Do While SC8->(!eof()) .AND. SC8->C8_NUM==SC7->C7_NUMCOT 
	    	IF SC8->C8_NUMSC==SC1->C1_NUM  .AND. SC8->C8_ITEMSC == SC1->C1_ITEM
	    	    cForPagto := "For.Pgto: "+IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,SC7->C7_COND,SC8->C8_COND)+" - "+Posicione("SE4",1,xFilial("SE4")+IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,SC7->C7_COND,SC8->C8_COND),"E4_DESCRI")
	   		    AADD(aITx_,{"",SC8->C8_NUM,SC8->C8_ITEM,SC8->C8_PRODUTO,SC8->C8_XXDESCP,SC8->C8_UM,SC8->C8_QUANT,SC8->C8_EMISSAO,IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,SC7->C7_DATPRF,""),IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,"Vencedor",""),TRANSFORM(SC8->C8_PRECO,"@E 999,999,999.99"),TRANSFORM(SC8->C8_TOTAL,"@E 999,999,999.99"),cForPagto,"Cod.For: "+SC8->C8_FORNECE,"Fornecedor: "+SC8->C8_XXNFOR,"Validade da Proposta: "+DTOC(SC8->C8_VALIDA)+"      "+IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM,IIF(ALLTRIM(SC8->C8_MOTIVO) == "ENCERRADO AUTOMATICAMENTE","X - Vencedor Indicado Pelo Sistema","* - Fornecedor Selecionado Pelo Usuário"),"")+IIF(!EMPTY(SC8->C8_OBS),"   OBS:"+SC8->C8_OBS,"")})
			ENDIF
			SC8->(DbSkip())
		ENDDO
		For Ix_ := 1 TO LEN(aITx_)
	 		AADD(aItems,{"Cotação: "+STRZERO(Ix_,2)+"/"+STRZERO(LEN(aITx_),2),aITx_[Ix_,2],aITx_[Ix_,3],aITx_[Ix_,4],aITx_[Ix_,5],aITx_[Ix_,6],aITx_[Ix_,7],aITx_[Ix_,8],aITx_[Ix_,9],aITx_[Ix_,10],aITx_[Ix_,11],aITx_[Ix_,12],aITx_[Ix_,13],aITx_[Ix_,14],aITx_[Ix_,15],aITx_[Ix_,16]})
		NEXT
		                                                                                                                                                                                                  
	ENDIF

	//PULA LINHA
	AADD(aItems,{"","","","","","","","","","","","","","","",""})
	AADD(aItems,{"","","","","","","","","","","","","","","",""})
 
	
	SC7->(DbSkip())
ENDDO

PswOrder(1) 
PswSeek(cUser) 
aUser  := PswRet(1)
IF !EMPTY(aUser)
	cNUser := aUser[1,2]
ENDIF

IF !lPedido
	lOk:=.T.
	If TYPE("CRELEASERPO") == "U"  // P11
	    A097Libera("SCR",nReg1,4)
	EndIf
	Return lOk
ENDIF


   
DEFINE MSDIALOG oDlg TITLE "Liberar Pedido de Compra" FROM 000,000 TO 500,800 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 500,600
oPanelLeft:Align := CONTROL_ALIGN_LEFT

@ 005, 005 SAY "Pedido Nº: "+cNumPC OF oPanelLeft SIZE 100,10 PIXEL

@ 005, 300 SAY "Comprador: "+cNUser OF oPanelLeft SIZE 200,10 PIXEL

@ 015, 005 LISTBOX oListID FIELDS HEADER "Solicitante/Cotação","Cod.","Item","Cod Prod.","Descrição Produto","UM","Quant","Emissao","Limite Entrega","Motivo/Status Cotação","Val.Licitação/Val.Cotado","Tot.Licitação/Tot.Cotado","OBS/For.Pgto","Contrato/Forn.","Descrição Contrato/Nome Forn.","Detalhes" SIZE 393,160 OF oPanelLeft PIXEL 

oListID:SetArray(aItems)
IF LEN(aItems) > 1
oListID:bLine := {|| {	aItems[oListId:nAt][1],;
						aItems[oListId:nAt][2],;
						aItems[oListId:nAt][3],;
						aItems[oListId:nAt][4],;
						aItems[oListId:nAt][5],;
						aItems[oListId:nAt][6],;
						aItems[oListId:nAt][7],;
						aItems[oListId:nAt][8],;
						aItems[oListId:nAt][9],;
						aItems[oListId:nAt][10],;
						aItems[oListId:nAt][11],;
						aItems[oListId:nAt][12],;
						aItems[oListId:nAt][13],;
						aItems[oListId:nAt][14],;
						aItems[oListId:nAt][15],;
						aItems[oListId:nAt][16]	}}

ENDIF

@ 180, 005 SAY 'Justificativa:' OF oPanelLeft SIZE 50,10 PIXEL
oMemo:= tMultiget():New(180,040,{|u|if(Pcount()>0,cXXJUST:=u,cXXJUST)},oPanelLeft,265,35,,,,,,.T.) 

  
@ 180, 315 SAY "Total do Pedido: "+TRANSFORM(nTotal,"@E 999,999,999.99") OF oPanelLeft SIZE 100,10 PIXEL


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| lOk:=.F., oDlg:End()}, , aButtons)

IF ( lOk )
	IF !EMPTY(cXXJUST)
	    cSC1NUM := ""
        FOR _IX:= 1 TO LEN(aItems)
        	IF cSC1NUM <> aItems[_IX,2]
    			DbSelectArea("SC1")
				SC1->(DbSetOrder(1))
				SC1->(DbSeek(xFilial("SC1")+aItems[_IX,2],.T.))
				Do While SC1->(!eof()) .AND. SC1->C1_NUM == aItems[_IX,2]
					Reclock("SC1",.F.)
        			SC1->C1_XXJUST := cXXJUST
		   			SC1->(Msunlock())
        			SC1->(DbSkip())
				ENDDO
				cSC1NUM := aItems[_IX,2]
			ENDIF
        NEXT
   	ENDIF
	If TYPE("CRELEASERPO") == "U"  // P11
	    A097Libera("SCR",nReg1,4)
	EndIf
EndIf
Return lOk


