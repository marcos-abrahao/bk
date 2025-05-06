#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"


/*/{Protheus.doc} MT094END
Ponto de Entrada para envio Pedido de Compras para Libera��o Al�ada
Retorno ao 02 Nivel e ao grupo de compras
@Return
@author Adilson do Prado
@since 18/02/13 - rev 11/02/22
@version P12
/*/

User Function MT094END(nPedido,cTipoDoc,nOpcao) 
/*
ParamIXB = {cDocto,cTipo,nOpc,cFilDoc} onde :
cDocto == Numero do Documento
cTipo == Tipo do Documento "PC" "AE" "CP"
Quando o ponto � acionado pela rotina de Libera��o e Superior:
nOpc == 1 --> Cancela
nOpc == 2 --> Libera
nOpc == 3 --> Bloqueia
Quando o ponto � acionado pela rotina de Transf. Superior
nOpc == 1 --> Transfere
nOpc == 2 --> Cancela
Obs.: Para esta rotina, caso n�o exista o superior cadastrado, a vari�vel ser�enviada como Nil. 
Deve ser tratado no ponto de entrada.
cFilDoc == Filial do Documento
*/
//Local nPedido   := SCR->CR_NUM
//Local cTipoDoc  := SCR->CR_TIPO
//Local nOpcao    := nOpc
//Local cFilDoc   := PARAMIXB[4]
Local nCotacao  := ""
Local cAssunto	:= ""
Local cEmail	:= u_EmailAdm()
Local cEmailCC  := "" 
Local cMsg 		:= "" 
Local cAnexo	:= ""
Local aCabs		:= {}
Local aEmail	:= {}
Local aMotivo	:= {}
Local cNUser	:= ""
Local cUser 	:= ""
Local cNumPC	:= ""
Local cForPagto := ""
Local cOBS		:= ""
Local aUser 	:= {}
Local dLiberado := dDataBase
Local cQuery  	:= ""
Local cGerGestao  := u_GerGestao()
Local cGerCompras := u_GerCompras()
Local cMCompras   := ALLTRIM(GetMv("MV_XXUMCOM"))

// Emails colocados manualmente para atender a demanda com urg�ncia / Alterar para grupo posteriormente 25/11/2019 - Marcos - a pedido do Fabio Querino
// 10/08/20 Removido aprendiz.almoxarifado e ricardo.monaco
Local cEmLibPed := IIF(cEmpAnt <> "20","joao.vitor@bkconsultoria.com.br;","") // Barcas

Local nTotPed   := 0
Local cEmUser   := ""
Local cXXJUST   := ""
Local aSC1USER  := {}
Local IT_
Local Ix_
Local xi
Local _IX

//MsgInfo(nPedido)
//MsgInfo(cTipoDoc)

If Empty(nOpcao)
	Return Nil
EndIf

//MsgInfo(str(nOpcao,3))

// 23/07/15 - Incluir no email o usu�rio que liberou
cEmail += u_aUsrEmail({__cUserID},cEmail)

IF ALLTRIM(cTipoDoc) <> "PC"

	IF nOpcao == 1
		Return Nil
	ENDIF

	cEmail  += u_aUsrEmail({SF1->F1_XXUSER,SF1->F1_XXUSERS},cEmail)

	u_xxLog(u_SLogDir()+"MT094END.LOG","1-"+cEmail) 
	       
	RecLock("SF1",.F.)
	cAssunto := "("+STR(nOpcao,1)+") "
	IF nOpcao = 5  //3
		cAssunto+= "Bloqueada a "
		SF1->F1_XXLIB  := "B"
	ELSE
		cAssunto+= "Liberada a "
		SF1->F1_XXLIB  := "L"
	ENDIF
	MsUnLock("SF1")
                                                                                                
	cAssunto += "Classifica��o da Nota Fiscal n�.:"+SF1->F1_DOC+" S�rie:"+SF1->F1_SERIE+" - "+FWEmpName(cEmpAnt)

	aCabs   := {"Nota Fiscal n�.:","S�rie:"," Cod.For.:"," Loja:","Valor:","Usu�rio"}
	AADD(aEmail,{SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_VALBRUT,UsrFullName(RetCodUsr())})

	cMsg    := u_GeraHtmB(aEmail,cAssunto,aCabs,"MT094END","",cEmail,cEmailCC)

	cAnexo := "MT094END"+ALLTRIM(SF1->F1_DOC)+".html"
	u_GrvAnexo(cAnexo,cMsg,.T.)

	u_BkSnMail("MT094END",cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)

	Return Nil
ENDIF

AADD(aMotivo,"In�cio de Contrato")
AADD(aMotivo,"Reposi��o Programada")
AADD(aMotivo,"Reposi��o Eventual")

u_xxLog(u_SLogDir()+"MT094END.LOG","2-"+cEmail)

cTPLIBER := ""
cOBS := ""

cQuery  := "SELECT CR_NUM,CR_USER,CR_DATALIB,CR_APROV, CONVERT(VARCHAR(4096),CONVERT(Binary(4096),CR_OBS)) CR_OBS" 
cQuery  += " FROM "+RETSQLNAME("SCR")+" SCR"
cQuery  += " WHERE CR_NUM = '"+ALLTRIM(nPedido)+"' AND SCR.D_E_L_E_T_ = ''"

TCQUERY cQuery NEW ALIAS "QSCR"
TCSETFIELD("QSCR","CR_DATALIB","D",8,0)
 	
aSCR := {}
DbSelectArea("QSCR")
QSCR->(dbgotop())
Do While QSCR->(!eof())
	DbSelectArea("SAL")
	SAL->(dbgotop())
	Do While SAL->(!eof())                                                                                                               
		IF SAL->AL_USER == __cUserId  .AND. SAL->AL_APROV == QSCR->CR_APROV
			cTPLIBER := SAL->AL_TPLIBER
			dLiberado:= QSCR->CR_DATALIB
			cOBS     := QSCR->CR_OBS
		ENDIF
		IF SAL->AL_USER == QSCR->CR_USER .AND. SAL->AL_APROV == QSCR->CR_APROV
			cEmUSER := ""
			PswOrder(1) 
			PswSeek(QSCR->CR_USER) 
			aUser  := PswRet(1)
			IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
				cEmUSER := ALLTRIM(aUser[1,14])+';'
			ENDIF                                                                                                
			AADD(aSCR,{QSCR->CR_USER,QSCR->CR_APROV,SAL->AL_TPLIBER,cEmUSER})
		ENDIF
		SAL->(dbskip())
	Enddo
	QSCR->(dbskip())
ENDDO
QSCR->(DbCloseArea())    


IF nOpcao == 4 //Era 2
	IF cTPLIBER == "P"
	
		//ATUALIZA DATA PREVISTA DE ENTREGA
		U_ALTDPRVC7(nPedido) 

        cEmail += cEmLibPed

		IF __cUserId $ cGerGestao+"/"+cGerCompras

		ELSE
			FOR IT_ := 1 TO LEN(aSCR)
				If !aSCR[IT_,4] $ cEmail .AND. !Empty(aSCR[IT_,4])
		    		cEmail += aSCR[IT_,4]+';'
				EndIf
			NEXT
        ENDIF
         
       	u_xxLog(u_SLogDir()+"MT094END.LOG","3-"+cEmail)
        
		cAssunto:= "Pedido de Compra: "+alltrim(nPedido)+" Liberado "+" - "+FWEmpName(cEmpAnt)
		IF __cUserId $ cGerGestao+"/"+cGerCompras+"/"+cMCompras
			AADD(aEmail,{"Liberado em "+DTOC(dLiberado)+" por: "+cNUser,"","","","","","","","","","","","","","",IIF(!EMPTY(cOBS),"OBS: "+cOBS,"")})
		ELSE
       		AADD(aEmail,{"Liberado Diretoria em "+DTOC(dLiberado)+" por: "+cNUser,"","","","","","","","","","","","","","",IIF(!EMPTY(cOBS),"OBS: "+cOBS,"")})
  		ENDIF
  		AADD(aEmail,{"","","","","","","","","","","","","","","",""})

    ELSE
  		FOR IT_ := 1 TO LEN(aSCR)
			IF aSCR[IT_,1] $ cGerGestao+"/"+cGerCompras
		    ELSE
				If !aSCR[IT_,4] $ cEmail .AND. !Empty(aSCR[IT_,4])
		    		cEmail += aSCR[IT_,4]+';'
				EndIf
			ENDIF
		NEXT
		u_xxLog(u_SLogDir()+"MT094END.LOG","4-"+cEmail)

		cAssunto:= "Solicita��o de Libera��o do Pedido de Compra: "+alltrim(nPedido)+" - "+FWEmpName(cEmpAnt)
     	AADD(aEmail,{"Aguardando Libera��o - Liberado em "+DTOC(dLiberado)+" por: "+cNUser,"","","","","","","","","","","","","","",IIF(!EMPTY(cOBS),"OBS: "+cOBS,"")})
       	AADD(aEmail,{"","","","","","","","","","","","","","","",""})
    
	ENDIF
	
ELSEIF nOpcao == 5 // era3
	IF __cUserId $ cGerGestao+"/"+cGerCompras
		IF cTPLIBER == "U"
			FOR IT_ := 1 TO LEN(aSCR)
				If !aSCR[IT_,4] $ cEmail .AND. !Empty(aSCR[IT_,4])
    				cEmail += aSCR[IT_,4]+';'
				EndIf
			NEXT
		ENDIF
	ELSE
		FOR IT_ := 1 TO LEN(aSCR)
			If !aSCR[IT_,4] $ cEmail .AND. !Empty(aSCR[IT_,4])
    			cEmail += aSCR[IT_,4]+';'
			EndIf
		NEXT
    ENDIF
	u_xxLog(u_SLogDir()+"MT094END.LOG","5-"+cEmail)

	cAssunto:= "Pedido de Compra  n�.:"+alltrim(nPedido)+" Bloqueado "+" - "+FWEmpName(cEmpAnt)
    AADD(aEmail,{"Bloqueado em "+DTOC(dLiberado)+" por: "+cNUser,"","","","","","","","","","","","","","",IIF(!EMPTY(cOBS),"OBS: "+cOBS,"")})
    AADD(aEmail,{"","","","","","","","","","","","","","","",""})
ELSE
	RETURN NIL
ENDIF


//EMAIL - GRUPO DE COMPRAS
SY1->(dbgotop())
Do While SY1->(!eof())                                                                                                               
	PswOrder(1) 
	PswSeek(SY1->Y1_USER) 
	aUser  := PswRet(1)
	IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
		If !ALLTRIM(aUser[1,14]) $ cEmail
			cEmail += ALLTRIM(aUser[1,14])+';'
		EndIf
	ENDIF
	SY1->(dbskip())
Enddo

u_xxLog(u_SLogDir()+"MT094END.LOG","6-"+cEmail)


DbSelectArea("SC7")
DbSeek(xFilial("SC7")+nPedido,.T.)
cUser    := SC7->C7_USER
cNumPC   := SC7->C7_NUM
nCotacao := SC7->C7_NUMCOT 		         

PswOrder(1) 
PswSeek(cUser) 
aUser  := PswRet(1)
IF !EMPTY(aUser)
	cNUser := aUser[1,2]
ENDIF

nTotPed := 0
Do While SC7->(!eof()) .AND. SC7->C7_NUM == cNumPC
	If Empty(SC7->C7_XXNCC) .AND. !EMPTY(SC7->C7_CC)
		RecLock("SC7",.F.)
		SC7->C7_XXNCC := Posicione("CTT",1,xFilial("CTT")+SC7->C7_CC,"CTT_DESC01")
		SC7->(MsUnLock())
	EndIf
	nTotPed += SC7->C7_TOTAL
	SC7->(DbSkip())
ENDDO


AADD(aEmail,{"Pedido Compra N�: "+cNumPC,"","","","","<b>Total do Pedido:</b>","<b>"+TRANSFORM(nTotPed,"@E 999,999,999.99")+"</b>","","","","","","","","","Comprador: "+cNUser})
AADD(aEmail,{"","","","","","","","","","","","","","","",""})

cXXJUST := ""
aSC1USER := {}
DbSelectArea("SC7")
DbSeek(xFilial("SC7")+nPedido,.T.)
Do While SC7->(!eof()) .AND. SC7->C7_NUM == cNumPC

	DbSelectArea("SC1")
	SC1->(DbSetOrder(1))
	IF SC1->(DbSeek(xFilial("SC1")+SC7->C7_NUMSC+SC7->C7_ITEMSC,.F.))
 		AADD(aEmail,{SC1->C1_SOLICIT,SC1->C1_NUM,SC1->C1_ITEM,SC1->C1_PRODUTO,SC1->C1_DESCRI,SC1->C1_UM,STR(SC1->C1_QUANT-SC1->C1_XXQEST,6,2),DTOC(SC1->C1_EMISSAO),DTOC(SC1->C1_DATPRF),aMotivo[val(SC1->C1_XXMTCM)],TRANSFORM(SC1->C1_XXLCVAL,"@E 999,999,999.99"),TRANSFORM(SC1->C1_XXLCTOT,"@E 999,999,999.99"),"<b>Obs: "+SC1->C1_OBS,"<b>Contrato: "+SC1->C1_CC,"<b>Desc.Contr: "+SC1->C1_XXDCC,"<b>Objeto: "+SC1->C1_XXOBJ})

		cXXJUST += IIF(SC1->C1_XXJUST $ cXXJUST,"",SC1->C1_XXJUST) 
		nScan:= 0
   		nScan:= aScan(aSC1USER,{|x| x[1]== SC1->C1_USER }) 
		IF nScan == 0 
			AADD(aSC1USER,{SC1->C1_USER})
        ENDIF

   		aITx_ := {}
		DbSelectArea("SC8")
		SC8->(DbSetOrder(1))
		SC8->(DbSeek(xFilial("SC8")+SC7->C7_NUMCOT,.T.))
    	Do While SC8->(!eof()) .AND. SC8->C8_NUM==SC7->C7_NUMCOT 
			IF SC8->C8_NUMSC==SC1->C1_NUM  .AND. SC8->C8_ITEMSC == SC1->C1_ITEM    		
    	    	cForPagto := "For.Pgto: "+IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,SC7->C7_COND,SC8->C8_COND)+" - "+Posicione("SE4",1,xFilial("SE4")+IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,SC7->C7_COND,SC8->C8_COND),"E4_DESCRI")
	   		    AADD(aITx_,{"",SC8->C8_NUM,SC8->C8_ITEM,SC8->C8_PRODUTO,SC8->C8_XXDESCP,SC8->C8_UM,STR(SC8->C8_QUANT,6,2),SC8->C8_EMISSAO,IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,SC7->C7_DATPRF,""),IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM ,"Vencedor",""),TRANSFORM(SC8->C8_PRECO,"@E 999,999,999.99"),TRANSFORM(SC8->C8_TOTAL,"@E 999,999,999.99"),cForPagto,"Cod.For: "+SC8->C8_FORNECE,"Fornecedor: "+SC8->C8_XXNFOR,"Validade da Proposta: "+DTOC(SC8->C8_VALIDA)+"      "+IIF(SC8->C8_NUMPED==SC7->C7_NUM .AND. SC8->C8_ITEMPED ==SC7->C7_ITEM,IIF(ALLTRIM(SC8->C8_MOTIVO) == "ENCERRADO AUTOMATICAMENTE","X - Vencedor Indicado Pelo Sistema","* - Fornecedor Selecionado Pelo Usu�rio"),"")+IIF(!EMPTY(SC8->C8_OBS),"   OBS:"+SC8->C8_OBS,"")})
			ENDIF
			SC8->(DbSkip())
		ENDDO                                                                                                                                                                                                  
		For Ix_ := 1 TO LEN(aITx_)
	 		AADD(aEmail,{"Cota��o: "+STRZERO(Ix_,2)+"/"+STRZERO(LEN(aITx_),2),aITx_[Ix_,2],aITx_[Ix_,3],aITx_[Ix_,4],aITx_[Ix_,5],aITx_[Ix_,6],aITx_[Ix_,7],aITx_[Ix_,8],aITx_[Ix_,9],aITx_[Ix_,10],aITx_[Ix_,11],aITx_[Ix_,12],aITx_[Ix_,13],aITx_[Ix_,14],aITx_[Ix_,15],aITx_[Ix_,16]})
		NEXT
	ENDIF

	//PULA LINHA
	AADD(aEmail,{"","","","","","","","","","","","","","","",""})
	AADD(aEmail,{"","","","","","","","","","","","","","","",""})
 
	
	SC7->(DbSkip())
ENDDO

IF 	!EMPTY(cXXJUST)
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
	PswOrder(1) 
	PswSeek(aSC1USER[_IX,1]) 
	aUser  := PswRet(1)
	IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17] 
		cEmail += ALLTRIM(aUser[1,14])+';'
	ENDIF
NEXT

u_xxLog(u_SLogDir()+"MT094END.LOG","7-"+cEmail)

aCabs   := {"Solicitante/Cota��o","Cod.","Item","Cod Prod.","Descri��o Produto","UM","Quant","Emissao","Limite Entrega","Motivo/Status Cota��o","Val.Licita��o/Val.Cotado","Tot.Licita��o/Tot.Cotado","OBS/For.Pgto","Contrato/Forn.","Descri��o Contrato/Nome Forn.","Detalhes"}

cMsg    := u_GeraHtmB(aEmail,cAssunto,aCabs,"MT094END","",cEmail,cEmailCC)

cMsg    := STRTRAN(cMsg,"><b>Justificativa:"," colspan="+str(len(aCabs))+'><blockquote style="text-align:left;font-size:14.0"><b>Justificativa:')

cEmail  := STRTRAN(cEmail,';;',';')

cAnexo := "MT094END"+ALLTRIM(cNumPC)+".html"
u_GrvAnexo(cAnexo,cMsg,.T.)

u_BkSnMail("MT094END",cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)

Return nil



USER FUNCTION ALTDPRVC7(cNUMPED)
LOCAL cQuery  := ""
Local nDIAPRF := 0
Local dDATPRF := CTOD("")

cQuery  :="SELECT C7_NUM,C7_ITEM,C8_EMISSAO,C8_DATPRF FROM "+RETSQLNAME("SC7")+" SC7"
cQuery  += " INNER JOIN "+RETSQLNAME("SC8")+" SC8 ON SC8.D_E_L_E_T_=''"
cQuery  += " AND C7_NUM=C8_NUMPED AND C7_ITEM=C8_ITEMPED"
cQuery  += " WHERE SC7.D_E_L_E_T_='' AND C7_NUM='"+ALLTRIM(cNUMPED)+"'"

IF SELECT("QSC7") > 0 
	QSC7->(DbCloseArea())
ENDIF

TCQUERY cQuery NEW ALIAS "QSC7"
TCSETFIELD("QSC7","C8_EMISSAO","D",8,0)
TCSETFIELD("QSC7","C8_DATPRF","D",8,0)

DbSelectArea("QSC7")
QSC7->(dbgotop())
Do While QSC7->(!eof())
	nDIAPRF := 0
   	dDATPRF := CTOD("")
	nDIAPRF :=  DateDiffDay( QSC7->C8_EMISSAO , QSC7->C8_DATPRF )
    IF nDIAPRF > 0
     	dDATPRF := DaySum( Date(), nDIAPRF ) 
    ELSE
    	dDATPRF := Date() 
    ENDIF 
   	cQuery  := "UPDATE "+RETSQLNAME("SC7")+" SET C7_DATPRF='"+DTOS(dDATPRF)+"'"
	cQuery  += " WHERE D_E_L_E_T_='' AND C7_NUM='"+ALLTRIM(QSC7->C7_NUM)+"'"
	cQuery  += " AND C7_ITEM='"+ALLTRIM(QSC7->C7_ITEM)+"'" 
    TcSqlExec(cQuery)
    
	QSC7->(DbSkip())
ENDDO
QSC7->(DbCloseArea())


RETURN NIL

