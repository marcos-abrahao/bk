#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKCOMA04
Aprovação do Pedido de Compras - Alçada
@Return
@author Adilson do Prado
@since 07/02/2013
@version P12
/*/

User Function BKCOMA04()
/*
Local oDlg
Local oListId
Local oPanelLeft
Local aButtons := {}
*/
Local Ix_		:= 0
Local _IX		:= 0
Local lOk      	:= .F.
Local nTotal 	:= 0
Local cNUser	:= ""
Local cUser 	:= ""
Local cNumPC	:= ""
Local cForPagto := ""
Local aCabs 	:= {"Solic./Cotação","Num.","Item","Cod Prod.","Descrição Produto","UM","Quant","Emissao","Limite Entrega","Motivo/Status Cotação","Val.Licit./Cotado","Tot.Licit./Cotado","OBS/Forma de Pgto","Contrato/Forn.","Descrição Contrato/Nome Forn.","Detalhes"}
Local aItens	:= {}
Local aMotivo	:= {}
Local lMDiretoria := .F.
Local cXXJUST 	:= ""

Private cPrw 	:= "BKCOMA04"
u_MsgLog(cPrw)

AADD(aMotivo,"Início de Contrato")
AADD(aMotivo,"Reposição Programada")
AADD(aMotivo,"Reposição Eventual")


lMDiretoria := u_IsMDir(__cUserId)

If !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS $ "03#05"
	//Help(" ",1,"A097LIB")
	//Aviso(STR0038,STR0039,{STR0037},2) //"Atencao!"###"Este pedido ja foi liberado anteriormente. Somente os pedidos que estao aguardando liberacao (destacado em vermelho no Browse) poderao ser liberados."###"Voltar"
	u_MsgLog("A097BLQ","Este pedido ja foi liberado anteriormente. Somente os pedidos que estao aguardando liberacao poderão ser liberados","w") 
	Return NIL
ElseIf  SCR->CR_STATUS $ "01"
	u_MsgLog("A097BLQ","Esta operação não poderá ser realizada pois este registro se encontra bloqueado pelo sistema (aguardando outros niveis)","w") 
	Return NIL
EndIf

IF !u_IsMasFin(__cUserId) .AND. !u_IsFiscal(__cUserId) .AND. !lMDiretoria
	DbSelectArea("SC7")
	SC7->(Dbsetorder(1))
	IF DbSeek(xFilial("SC7")+ALLTRIM(SCR->CR_NUM),.T.)
		Do While SC7->(!eof()) .AND. SCR->CR_NUM == SC7->C7_NUM
			DbSelectArea("SC1")
			SC1->(DbSetOrder(1))
			IF SC1->(DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC,.F.))
    	   		IF SC1->C1_USER == __cUserId
					u_MsgLog("BKCOMA04","Usuário não autorizado Liberar o próprio Pedido!!","E") 
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
aItens:= {}
Do While SC7->(!eof()) .AND. cNumPC == SC7->C7_NUM
	cUser := SC7->C7_USER
	lPedido := .T.

	DbSelectArea("SC1")
	SC1->(DbSetOrder(1))
	IF SC1->(DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC,.F.))
   		//AADD(aItens,{SC1->C1_SOLICIT,SC1->C1_NUM,SC1->C1_ITEM,SC1->C1_PRODUTO,SC1->C1_DESCRI,SC1->C1_UM,SC1->C1_QUANT-SC1->C1_XXQEST,SC1->C1_EMISSAO,SC1->C1_DATPRF,aMotivo[val(SC1->C1_XXMTCM)],TRANSFORM(SC1->C1_XXLCVAL,"@E 999,999,999.99"),TRANSFORM(SC1->C1_XXLCTOT,"@E 999,999,999.99"),"Obs: "+TRIM(SC1->C1_OBS),"Contrato: "+SC1->C1_CC,"Desc.Contr: "+SC1->C1_XXDCC,"Objeto: "+SC1->C1_XXOBJ})
   		AADD(aItens,{SC1->C1_SOLICIT,SC1->C1_NUM,SC1->C1_ITEM,SC1->C1_PRODUTO,SC1->C1_DESCRI,SC1->C1_UM,SC1->C1_QUANT-SC1->C1_XXQEST,SC1->C1_EMISSAO,SC1->C1_DATPRF,aMotivo[val(SC1->C1_XXMTCM)],SC1->C1_XXLCVAL,SC1->C1_XXLCTOT,"Obs: "+TRIM(SC1->C1_OBS),"Contrato: "+SC1->C1_CC,"Desc.Contr: "+SC1->C1_XXDCC,"Objeto: "+SC1->C1_XXOBJ})
		cXXJUST += IIF(SC1->C1_XXJUST $ cXXJUST,"",SC1->C1_XXJUST) 
   		aITx_ := {}
		DbSelectArea("SC8")
		SC8->(DbSetOrder(1))
		SC8->(DbSeek(xFilial("SC8")+SC7->C7_NUMCOT,.T.))
	    Do While SC8->(!eof()) .AND. SC8->C8_NUM==SC7->C7_NUMCOT 
	    	IF SC8->C8_NUMSC==SC1->C1_NUM  .AND. SC8->C8_ITEMSC == SC1->C1_ITEM
	    	    cForPagto := TRIM("For.Pgto: "+IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,SC7->C7_COND,SC8->C8_COND)+" - "+Posicione("SE4",1,xFilial("SE4")+IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,SC7->C7_COND,SC8->C8_COND),"E4_DESCRI"))
	   		    AADD(aITx_,{"",;
				   			SC8->C8_NUM,;
							SC8->C8_ITEM,;
							SC8->C8_PRODUTO,;
							SC8->C8_XXDESCP,;
							SC8->C8_UM,;
							SC8->C8_QUANT,;
							SC8->C8_EMISSAO,;
							IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED == SC7->C7_ITEM ,SC7->C7_DATPRF,""),;
							IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED == SC7->C7_ITEM ,"Vencedor",""),;
							SC8->C8_PRECO,;
							SC8->C8_TOTAL,;
							TRIM(cForPagto),;
							"Cod.Forn: "+SC8->C8_FORNECE,;
							"Forn.: "+SC8->C8_XXNFOR,;
							"Validade da Proposta: "+DTOC(SC8->C8_VALIDA)+"      "+IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM,IIF(ALLTRIM(SC8->C8_MOTIVO) == "ENCERRADO AUTOMATICAMENTE","X - Vencedor Indicado Pelo Sistema","* - Fornecedor Selecionado Pelo Usuário"),"")+IIF(!EMPTY(SC8->C8_OBS),"   OBS:"+SC8->C8_OBS,"")})

//							TRANSFORM(SC8->C8_PRECO,"@E 999,999,999.99"),;
//							TRANSFORM(SC8->C8_TOTAL,"@E 999,999,999.99"),;

			ENDIF
			SC8->(DbSkip())
		ENDDO
		For Ix_ := 1 TO LEN(aITx_)
	 		AADD(aItens,{"Cotação: "+STRZERO(Ix_,2)+"/"+STRZERO(LEN(aITx_),2),aITx_[Ix_,2],aITx_[Ix_,3],aITx_[Ix_,4],aITx_[Ix_,5],aITx_[Ix_,6],aITx_[Ix_,7],aITx_[Ix_,8],aITx_[Ix_,9],aITx_[Ix_,10],aITx_[Ix_,11],aITx_[Ix_,12],aITx_[Ix_,13],aITx_[Ix_,14],aITx_[Ix_,15],aITx_[Ix_,16]})
		NEXT
		                                                                                                                                                                                                  
	ENDIF

	//PULA LINHA
	AADD(aItens,{"","","","","","","","","","","","","","","",""})
	AADD(aItens,{"","","","","","","","","","","","","","","",""})
 
	
	SC7->(DbSkip())
ENDDO


IF !EMPTY(cUser)
	cNUser := UsrRetName(cUser)
EndIf

IF !lPedido
	lOk:=.T.
	Return lOk
ENDIF

lOk := LibWeb(cNumPC,cNUser,aCabs,aItens,@cXXJUST,nTotal)

/*
DEFINE MSDIALOG oDlg TITLE "Liberar Pedido de Compra" FROM 000,000 TO 500,800 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 500,600
oPanelLeft:Align := CONTROL_ALIGN_LEFT

@ 005, 005 SAY "Pedido Nº: "+cNumPC OF oPanelLeft SIZE 100,10 PIXEL

@ 005, 300 SAY "Comprador: "+cNUser OF oPanelLeft SIZE 200,10 PIXEL

//@ 015, 005 LISTBOX oListID FIELDS HEADER "Solicitante/Cotação","Cod.","Item","Cod Prod.","Descrição Produto","UM","Quant","Emissao","Limite Entrega","Motivo/Status Cotação","Val.Licitação/Val.Cotado","Tot.Licitação/Tot.Cotado","OBS/For.Pgto","Contrato/Forn.","Descrição Contrato/Nome Forn.","Detalhes" SIZE 393,160 OF oPanelLeft PIXEL 

oListID := TCBrowse():New(;
				015,;	// [ nRow ]
				005,;	// [ nCol ]
				393,;	// [ nWidth ]
				160,;	// [ nHeight ]
				,;		// [ bLine ]
				{"Solic./Cotação","Cod.","Item","Cod Prod.","Descrição Produto","UM","Quant","Emissao","Limite Entrega","Motivo/Status Cotação","Val.Licit./Cotado","Tot.Licit./Cotado","OBS/Forma de Pgto","Contrato/Forn.","Descrição Contrato/Nome Forn.","Detalhes"},; //[ aHeaders ]
				{ 45,			   20,    18,    50,         100,                8,   20,     20,       20,              100,                    45,                 45,                 100,                50,              100,                            200},; 	  //[ aColSizes ]
				oPanelLeft,;	// [ oWnd ]
				,;		// [ cField ]
				,;		// [ uValue1 ]
				,;		// [ uValue2 ]
				,;		// [ bChange ]
				{||},;	// [ bLDblClick ]
				,;		// [ bRClicked ]
				,;		// [ oFont ]
				,;		// [ oCursor ]
				,;		// [ nClrFore ]
				,;		// [ nClrBack ]
				,;		// [ cMsg ]
				.F.,;	// [ uParam20 ]
				,;		// [ cAlias ]
				.T.,;	// [ lPixel ]
				,;		// [ bWhen ]
				.F.,;	// [ uParam24 ]
				,;		// [ bValid ]
				.T.,;		// [ lHScroll ]
				.T., )		// [ lVScroll ]

oListID:SetArray(aItens)
IF LEN(aItens) > 1
	oListID:bLine := {|| {	aItens[oListId:nAt][1],;
							aItens[oListId:nAt][2],;
							aItens[oListId:nAt][3],;
							aItens[oListId:nAt][4],;
							aItens[oListId:nAt][5],;
							aItens[oListId:nAt][6],;
							aItens[oListId:nAt][7],;
							aItens[oListId:nAt][8],;
							aItens[oListId:nAt][9],;
							aItens[oListId:nAt][10],;
							aItens[oListId:nAt][11],;
							aItens[oListId:nAt][12],;
							aItens[oListId:nAt][13],;
							aItens[oListId:nAt][14],;
							aItens[oListId:nAt][15],;
							aItens[oListId:nAt][16]	}}

ENDIF

@ 180, 005 SAY 'Justificativa:' OF oPanelLeft SIZE 50,10 PIXEL
oMemo:= tMultiget():New(180,040,{|u|if(Pcount()>0,cXXJUST:=u,cXXJUST)},oPanelLeft,265,35,,,,,,.T.) 

  
@ 180, 315 SAY "Total do Pedido: "+TRANSFORM(nTotal,"@E 999,999,999.99") OF oPanelLeft SIZE 100,10 PIXEL


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| lOk:=.F., oDlg:End()}, , aButtons)
*/


IF ( lOk )
	IF !EMPTY(cXXJUST)
	    cSC1NUM := ""
        FOR _IX:= 1 TO LEN(aItens)
        	IF cSC1NUM <> aItens[_IX,2]
    			DbSelectArea("SC1")
				SC1->(DbSetOrder(1))
				SC1->(DbSeek(xFilial("SC1")+aItens[_IX,2],.T.))
				Do While SC1->(!eof()) .AND. SC1->C1_NUM == aItens[_IX,2]
					Reclock("SC1",.F.)
        			SC1->C1_XXJUST := cXXJUST
		   			SC1->(Msunlock())
        			SC1->(DbSkip())
				ENDDO
				cSC1NUM := aItens[_IX,2]
			ENDIF
        NEXT
   	ENDIF
EndIf
Return lOk



Static Function LibWeb(cNumPC,cNUser,aCabs,aItens,cXXJUST,nTotal)
Local aSize     := FWGetDialog(oMainWnd)   // GetScreenRes() 
Local nTop		:= 0
Local nLeft		:= 0
Local nJanLarg	:= 0
Local nJanAltu	:= 0
Local nPosBt 	:= 0
Local nTamBt 	:= 75
Local nEsps		:= 15
Local cTitulo	:= "Liberação de Pedido de Compra: "+TRIM(cNumPC)+" - Comprador: "+TRIM(cNUser)+" - Total do Pedido: "+ALLTRIM(TRANSFORM(nTotal,"@E 999,999,999.99"))
//Local cUrl 		:= ""
//Local cFile		:= ""
Local lOk		:= .F.

Local oDlg
Local oLayer
Local oPanelUp
Local oPanelDown

Private nPort
Private oWebEngine as Object
Private oWebChannel := TWebChannel():New()

// GetScreenRes()
//nJanLarg	:= aSize[1] - 40
//nJanAltu	:= aSize[2] - 200

// FWGetDialog
nJanLarg	:= aSize[4]
nJanAltu	:= aSize[3]

nTop		:= 0
nLeft		:= 0

// Montagem do HTML
cHtml := HtmlPC(aCabs,aItens,cTitulo)

oDlg := MsDialog():New( nTop, nLeft, nJanAltu, nJanLarg,cTitulo,,,,,,,,, .T.,,,, .F. )

//oDlg:Align := CONTROL_ALIGN_ALLCLIENT
oDlg:nClientHeight  := nJanAltu
oDlg:nClientWidth   := nJanLarg

oDlg:Refresh()

oLayer := FWLayer():new()
oLayer:init(oDlg,.F.)

oLayer:addCollumn ('Col1',100,.F.)

oLayer:addWindow('Col1', 'WinTop' ,'Ações' ,20,.F.,.F.,,,)
oLayer:addWindow('Col1', 'WinGrid','Cotações' ,80,.F.,.F.,,,)

oPanelUp := oLayer:getWinPanel('Col1','WinTop')
oPanelDown := oLayer:getWinPanel('Col1','WinGrid')

nPosBt := 12

@ 05,nPosBt SAY 'Justificativa:' OF oPanelUp SIZE 50,10 PIXEL
nPosbt += 60
oMemo:= tMultiget():New(01,nPosBt,{|u|if(Pcount()>0,cXXJUST:=u,cXXJUST)},oPanelUp,265,33,,,,,,.T.) 

nPosbt += nTamBt + 250 + nEsps 

//nPosBt := (nJanLarg)-((nTamBt*3)+12)
@ 05,nPosBt BUTTON "Voltar do anexo" SIZE nTamBt, 12 PIXEL OF oPanelUp ACTION (oWebEngine:goHome())
//oBtn := TBtnBmp2():New( 05,nPosbt,nTamBt,12,'FW_HOME',,,,{||oWebEngine:goHome()},oPanelUp,"Voltar do anexo",,.T. )

nPosbt += nTamBt + nEsps 
//nPosBt := (nJanLarg)-((nTamBt*1)+06)
@ 05,nPosBt BUTTON "Sair" SIZE nTamBt, 12 PIXEL OF oPanelUp ACTION (lOk:=.F.,oDlg:End())

nPosbt += nTamBt + nEsps 
//nPosBt := (nJanLarg)-((nTamBt*2)+09)
@ 05,nPosBt BUTTON "Liberar" SIZE nTamBt, 12 PIXEL OF oPanelUp ACTION (lOk:=.T.,oDlg:End())



//Prepara o conector
nPort := oWebChannel::connect()
 
//Cria o componente que irá carregar a url
oWebEngine := TWebEngine():New(oPanelDown, 100, 100, 100, 100,/*cUrl*/, nPort)
//oWebEngine:bLoadFinished := {|self, url| /*conout("Fim do carregamento da pagina " + url)*/ }

//oWebEngine:navigate(cUrl)
oWebEngine:setHtml(cHtml, u_BkIpServer()+"/tmp/")
oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
//msgAlert(oWebEngine:cUrl)
oDlg:Activate()

Return lOk


Static Function HtmlPC(aCabs,aDet,cTitulo)
Local cHtm := ""
Local nI,nJ
//Local lCorNao := .T.
Local cPicN   := "@E 99999999.99"
Local cAlign  := ""
Local aSC8 	  := {}

cHtm += CabHtml(cPrw,cTitulo)  

cHtm += '<table width="100%" Align="center" border="0" cellspacing="0" cellpadding="0" bordercolor="#CCCCCC" >' 
cHtm += '<thead style="vertical-align: top; background-color: #9E0000; color: #FFFFFF; font-size: 9pt; line-height: 120%;">' + CRLF
For nI := 1 TO LEN(aCabs)

   cAlign  :=	"text-align: left;"
   If Len(aDet) > 0
      xCampo := aDet[1,nI]
 			            
      if VALTYPE(xCampo) == "D" // Trata campos data
         cAlign := 'text-align: center;'
      elseif VALTYPE(xCampo) == "N" // Trata campos numericos
         cAlign := 'text-align: right;'
      endif      
   EndIf

	cHtm += '<th style="padding: 5px 2px 5px 2px;font-family: Arial;'+cAlign+';"><b>'+ALLTRIM(aCabs[nI])+'</b></th>' 
Next
cHtm += '</thead>' 

cHtm += '<tbody style="vertical-align: top; font-size: 8pt; line-height: 120%;">'
For nJ := 1 TO LEN(aDet)

    //If lCorNao   
       cHtm += '<tr>'
    //Else   
    //   cHtm += '<tr style="background-color:#fdf1f1;">'
    //EndIf   
    //lCorNao := !lCorNao
	
    For nI :=1 to LEN(aDet[nj])
	
         xCampo := aDet[nJ,nI]
	            
         _uValor := ""
         cAlign  := "text-align: left;"
			            
         if VALTYPE(xCampo) == "D" // Trata campos data
            _uValor := dtoc(xCampo)
            cAlign := 'text-align: center;'
         elseif VALTYPE(xCampo) == "N" // Trata campos numericos
            _uValor := ALLTRIM(transform(xCampo,cPicN))
            cAlign := 'text-align: right'
         elseif VALTYPE(xCampo) == "C" // Trata campos caracter
            _uValor := ALLTRIM(xCampo)
         endif
            
         //cHtm += '<td style="padding: 5px 2px 5px 2px;font-family: Arial; white-space: nowrap;'+cAlign+'">'+TRIM(_uValor)+'</td>'
         cHtm += '<td style="padding: 5px 2px 5px 2px;font-family: Arial;'+cAlign+'">'+TRIM(_uValor)+'</td>'
	            
      Next nI

      cHtm += '</tr>'
	
Next nJ
cHtm += '</tbody>'

cHtm += '</table>' 

cHtm += '<br>'


/*
If !EMPTY(cPrw) 
	cHtm += '<p style="font-size:8.0pt;font-family: Arial;">Origem: '+TRIM(cPrw)+' '+DTOC(DATE())+' '+TIME()+' - '+FWEmpName(cEmpAnt)+' - '+cUser+'</p>'
EndIf
*/

//cHtm += '<br>'

// Documentos anexos

cHtm += '<table>'
cHtm += '<table width="100%" Align="center" border="0" cellspacing="0" cellpadding="0" bordercolor="#CCCCCC" >' 

cHtm += '<thead style="vertical-align: top; background-color: #9E0000; color: #FFFFFF; font-size: 9pt; line-height: 120%;">' + CRLF
cHtm += '	<th style="padding: 5px 2px 5px 2px;font-family: Arial;text-align: center;"><b>Anexos das cotações</b></th>' 
cHtm += '</thead>' 

aFiles := {}
For nJ := 1 To Len(aDet)
	If Ascan(aSC8,aDet[nJ,2]+aDet[nJ,3]) == 0
		aAdd(aSC8,aDet[nJ,2]+aDet[nJ,3])
		aFiles := u_BKDocs(cEmpAnt,"SC8","01"+aDet[nJ,2]+aDet[nJ,3],1,aFiles,.T.)
	EndIf
Next

If Len(aFiles) > 0
	For nI := 1 To Len(aFiles)
		cHtm += '<tr>'
		cHtm += '	<td style="text-align:center;">'
		cHtm += '     <a href="'+u_BkRest()+'/RestLibPN/v4?empresa='+cEmpAnt+'&documento='+Encode64(aFiles[nI,2])+'&tpanexo=P" class="link-primary">'+aFiles[nI,2]+'</a></br>'
		cHtm += '  </td>'
		cHtm += '</tr>'
	Next
EndIf

cHtm += '</table>'
cHtm += '<br>'

cHtm += '</body>' 
cHtm += '</html>'

Return cHtm


Static Function CabHtml(cPrw,cTitulo)
Local cHtm  := ""
Local cLogo := ""
Local cUser := ""

If ValType(cUserName) == "U"
   cUser := "Admin"
Else
   cUser := cUserName
EndIf

cLogo := u_BkLogos(FWCodEmp())

cHtm += '<html lang="pt-BR" xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:v="urn:schemas-microsoft-com:vml">' 

cHtm += '<head>' 
cHtm += '<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">' 
//cHtm += '<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">' 
cHtm += '<title>'+cTitulo+' - '+DTOC(date())+' '+TIME()+'</title>' 
cHtm += u_BkFavIco()
cHtm += '<style>' 
//cHtm += '.Normal{font-size:11.0pt;font-family:"Arial";}' 
//cHtm += '.F8A{font-size:8.0pt;font-family:"Arial"}' 
//cHtm += '.F10A{font-size:10.0pt;font-family:"Arial"}' 
cHtm += '</style>' 
cHtm += '</head>' 
cHtm += '<body bgcolor=#ffffff lang=PT-BR>' 

cHtm += '<table border=0 align="center" cellpadding=0 width="100%" style="center" >' 
/*
cHtm += ' <tr>' 
cHtm += '  <td width=15%>' 
cHtm += '    <p align=center style="text-align:center">'+cLogo+'</p>' 
cHtm += '  </td>' 
cHtm += '  <td width=85% style="center">' 
cHtm += '    <p align=center style="text-align:center;font-size:16;"><b></b></p>' 
cHtm += '  </td>' 
cHtm += ' </tr>' 
*/
cHtm += ' <tr>' 
//cHtm += '  <td colspan="2">' 
cHtm += '  <td>' 
cHtm += '    <p align=center style="text-align:center;font-size:16;"><b>'+cTitulo+'</b></p>' 
cHtm += '  </td>' 
cHtm += ' </tr>' 

cHtm += ' <tr>' 
cHtm += '  <td>' 
cHtm += '    <p align=center style="text-align:center;font-size:10;"><b>'+TRIM(cPrw)+' '+DTOC(DATE())+' '+TIME()+' - '+cUser+'</b></p>' 
cHtm += '  </td>' 
cHtm += ' </tr>' 
cHtm += '</table>' 
cHtm += '<br>' 
Return cHtm



Static Function xLibWeb(cNumPC,cNUser,aCabs,aItens,cXXJUST,nTotal) as logical
    local aButtons as array

	Local cTitulo	:= "Liberação de Pedido de Compra: "+TRIM(cNumPC)+" - Comprador: "+TRIM(cNUser)+" - Total do Pedido: "+ALLTRIM(TRANSFORM(nTotal,"@E 999,999,999.99"))

    local nTop as numeric
    local nLeft as numeric
    local nBottom as numeric
    local nRight as numeric
    local jButtons:=JSONObject():New() as json
    local oDlg as object
    local oGrp as object
    local oTWebEngine as object
    local oFWDefSize as object

    //private cCadastro := cTitulo as character

	// Montagem do HTML
	cHtml := HtmlPC(aCabs,aItens,cTitulo)

    oFWDefSize:=FWDefSize():New(.F.)
    oFWDefSize:lLateral:=.F.
    oFWDefSize:AddObject("ButtonActions",100,30,.T.,.T.)
	oFWDefSize:AddObject("TWebEngine",100,70,.T.,.T.)
    oFWDefSize:Process()

    nTop:=oFWDefSize:aWindSize[1]
    nLeft:=oFWDefSize:aWindSize[2]
    nBottom:=oFWDefSize:aWindSize[3]
    nRight:=oFWDefSize:aWindSize[4]

    aButtons:=array(0)
    aAdd(aButtons,{"Liberar",{||lOk:=.T.,oDlg:End()},OemToAnsi("Liberar"),OemtoAnsi("Liberar")})
    aAdd(aButtons,{"Sair",{||lOk:=.F.,oDlg:End()},OemToAnsi("Sair"),OemtoAnsi("Sair")})
	aAdd(aButtons,{"Go Home",{||oTWebEngine:goHome()},OemToAnsi("Go Home"),OemtoAnsi("Go Home")})
    //aAdd(aButtons,{"Go Back",{||oTWebEngine:goForward()},OemToAnsi("Go Back"),OemtoAnsi("Go Back")})
    aAdd(aButtons,{"Go Forward",{||oTWebEngine:goHome()},OemToAnsi("Go Forward"),OemtoAnsi("Go Forward")})
    aAdd(aButtons,{"Reload",{||oTWebEngine:Reload()},OemToAnsi("Reload"),OemtoAnsi("Reload")})
    aAdd(aButtons,{"Print",{||oTWebEngine:Print()},OemToAnsi("Print"),OemtoAnsi("Print Home")})
    aAdd(aButtons,{"Print PDF",{||oTWebEngine:PrintPDF()},OemToAnsi("Print PDF"),OemtoAnsi("Print PDF")})


    DEFINE MSDIALOG oDlg TITLE cTitulo FROM nTop,nLeft TO nBottom,nRight OF GetWndDefault() STYLE DS_MODALFRAME STATUS PIXEL

        nTop:=oFWDefSize:GetDimension("ButtonActions","LININI")
        nLeft:=oFWDefSize:GetDimension("ButtonActions","COLINI")
        nBottom:=oFWDefSize:GetDimension("ButtonActions","LINEND")
        //nRight:=oFWDefSize:GetDimension("ButtonActions","COLEND")

        //nTop-=3
        nRight+=3

        @ nTop,03 GROUP oGrp TO nBottom+2,nRight PROMPT "" OF oDlg COLOR 0,16777215 PIXEL

        nTop+=1
        nRight+=5

		//@ nTop,10 SAY 'Justificativa:' OF oGrp SIZE 40,10 PIXEL
		//oMemo:= tMultiget():New(nTop,50,{|u|if(Pcount()>0,cXXJUST:=u,cXXJUST)},oGrp,265,35,,,,,,.T.) 

        //Botoes (da direita pra a esquerda)
        @ nTop,(nRight)-((50*1)+06) BUTTON jButtons["1"] PROMPT aButtons[1][1] SIZE 50,10 OF oGrp ACTION Eval(aButtons[1][2]) PIXEL
        @ nTop,(nRight)-((50*2)+09) BUTTON jButtons["2"] PROMPT aButtons[2][1] SIZE 50,10 OF oGrp ACTION Eval(aButtons[2][2]) PIXEL
        @ nTop,(nRight)-((50*3)+12) BUTTON jButtons["3"] PROMPT aButtons[3][1] SIZE 50,10 OF oGrp ACTION Eval(aButtons[3][2]) PIXEL
        @ nTop,(nRight)-((50*4)+15) BUTTON jButtons["4"] PROMPT aButtons[4][1] SIZE 50,10 OF oGrp ACTION Eval(aButtons[4][2]) PIXEL
        @ nTop,(nRight)-((50*5)+18) BUTTON jButtons["5"] PROMPT aButtons[5][1] SIZE 50,10 OF oGrp ACTION Eval(aButtons[5][2]) PIXEL
        @ nTop,(nRight)-((50*6)+21) BUTTON jButtons["6"] PROMPT aButtons[6][1] SIZE 50,10 OF oGrp ACTION Eval(aButtons[6][2]) PIXEL
        @ nTop,(nRight)-((50*7)+24) BUTTON jButtons["7"] PROMPT aButtons[7][1] SIZE 50,10 OF oGrp ACTION Eval(aButtons[7][2]) PIXEL


        nTop:=oFWDefSize:GetDimension("TWebEngine","LININI")
        nLeft:=oFWDefSize:GetDimension("TWebEngine","COLINI")
        nBottom:=oFWDefSize:GetDimension("TWebEngine","LINEND")
        nRight:=oFWDefSize:GetDimension("TWebEngine","COLEND")

        //nTop-=5
        nBottom-=5 //+=1
        nRight-=5

        oTWebEngine:=TWebEngine():New(oDlg,nTop,nLeft,nRight,nBottom,/*"http://localhost/ConnectiPainelRH"*/)
		oTWebEngine:setHtml(cHtml, u_BkIpServer()+"/tmp/")
        oTWebEngine:SetAsMain()

        oDlg:lEscClose:=.F.

    ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oTWebEngine:Navigate())

    FWFreeArray(@aButtons)

    FWFreeObj(oGrp)
    FWFreeObj(oDlg)
    FWFreeObj(jButtons)
    FWFreeObj(oTWebEngine)
    FWFreeObj(oFWDefSize)

    DelClassIntF()

return(lOk)
