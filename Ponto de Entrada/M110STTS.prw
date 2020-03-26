#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M110STTS ºAutor  ³Adilso do Prado   º Data ³  14/02/13     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºPonto de Entrada para envio Solicitação de Compra aos compradores      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
 
User Function M110STTS()
Local cNumSol	:= Paramixb[1]
Local cAssunto	:= ""
Local cEmail	:= "microsiga@bkconsultoria.com.br;vanderleia.silva@bkconsultoria.com.br;"
Local cEmailCC  := "" //microsiga@bkconsultoria.com.br;"
Local cMsg 		:= "" 
Local cAnexo	:= ""
Local _lJob		:= .F.
Local aCabs		:= {}
Local aEmail	:= {}
Local aMotivo	:= {} 
Local lAprov	:= .T.
Local aSaldos 	:= {}
Local nSaldo 	:= 0

AADD(aMotivo,"Início de Contrato")
AADD(aMotivo,"Reposição Programada")
AADD(aMotivo,"Reposição Eventual")

PswOrder(1) 
PswSeek(__CUSERID)  
aUser  := PswRet(1)
IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17] 
	cEmail += ALLTRIM(aUser[1,14])+';'
ENDIF


SY1->(dbgotop())
Do While SY1->(!eof())                                                                                                               
	PswOrder(1) 
	PswSeek(SY1->Y1_USER) 
	aUser  := PswRet(1)
	IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
		cEmail += ALLTRIM(aUser[1,14])+';'
	ENDIF
    SY1->(dbskip())
Enddo

//Monta corpo do email Solicitação de Compras
DbSelectArea("SC1")
SC1->(DbSetOrder(1))
SC1->(DbSeek(xFilial("SC1")+cNumSol,.T.))
Do While SC1->(!eof()) .AND. SC1->C1_NUM == cNumSol
    AADD(aEmail,{SC1->C1_NUM,SC1->C1_SOLICIT,SC1->C1_ITEM,SC1->C1_PRODUTO,SC1->C1_DESCRI,SC1->C1_UM,SC1->C1_QUANT-SC1->C1_XXQEST,SC1->C1_DATPRF,SC1->C1_OBS,SC1->C1_CC,SC1->C1_XXDCC}) //aMotivo[val(SC1->C1_XXMTCM)]})
    IF SC1->C1_APROV == "B"
    	lAprov := .F.
    ENDIF
    SC1->(dbskip())
Enddo


/* 
IF INCLUI
	cAssunto:= "Solicitação de Compra incluída  nº.:"+alltrim(cNumSol)+DTOC(DATE())+"-"+TIME()
ELSEIF ALTERA 
	cAssunto:= "Solicitação de Compra alterada  nº.:"+alltrim(cNumSol)+DTOC(DATE())+"-"+TIME()
ELSEIF EXCLUI               
	cAssunto:= "Solicitação de Compra excluída  nº.:"+alltrim(cNumSol)+DTOC(DATE())+"-"+TIME()
ENDIF
*/
 
_nMax 	:= 0
_nMax 	:= Len(PROCNAME())

// Variavel logica utilizada em conjunto com nMax 											 
_lProc	:= .F.

// Processa todo conteudo de nMax para encontrar A110DELETA solicitacao de compras			 
For _i:= 0 To _nMax
	If Alltrim(PROCNAME(_i)) == "A110DELETA" 
		 _lProc := .T.
		 exit
	Endif
Next

aCabs   := {}
IF _lProc 
	cAssunto:= "Solicitação de Compra excluída  nº.:"+alltrim(cNumSol)+"       "+DTOC(DATE())+"-"+TIME()+" - "+ALLTRIM(SM0->M0_NOME)
	aCabs   := {"Cod. SC.","Solicitante","Ítem","Cod.Prod","Desc.Prod.","UM","Quant.","Data Limite Entrega","OBS","Centro de Custo","Descr. Centro de Custo"}//"Motivo"}
	cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,"M110STTS")
	U_SendMail("M110STTS",cAssunto,cEmail,cEmailCC,cMsg,cAnexo,_lJob)
ELSE
	IF lAprov 
		aSaldos := {}
		FOR _IX:= 1 TO LEN(aEmail)
			nSaldo := 0
			nSaldo := CalcEst(aEmail[_IX,4],"01", dDataBase+1)
			IF nSaldo > 0
				AADD(aSaldos,{aEmail[_IX,3],aEmail[_IX,3],aEmail[_IX,4],aEmail[_IX,5],aEmail[_IX,6],aEmail[_IX,7],nSaldo})
	        ENDIF
	    NEXT
	    IF LEN(aSaldos) > 0
	    	IF MsgYesNo("Produtos da solicitação em estoque. Deseja utilizalos??")
	    	   //U_BKSADO(aSaldos)
	    	ENDIF
	    ENDIF            
		cAssunto:= "Solicitação de Compra nº.:"+alltrim(cNumSol)+"       "+DTOC(DATE())+"-"+TIME()+" - "+ALLTRIM(SM0->M0_NOME)
		aCabs   := {"Cod. SC.","Solicitante","Ítem","Cod.Prod","Desc.Prod.","UM","Quant.","Data Limite Entrega","OBS","Centro de Custo","Descr. Centro de Custo"}//"Motivo"}
		cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,"M110STTS")
		U_SendMail("M110STTS",cAssunto,cEmail,cEmailCC,cMsg,cAnexo,_lJob)
	ENDIF
ENDIF

Return Nil