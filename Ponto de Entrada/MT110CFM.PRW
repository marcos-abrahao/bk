#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT110CFM ºAutor  ³Adilso do Prado   º Data ³  13/07/14     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºPonto de Entrada para envio Solicitação de Compra aos compradores apos º±±
±±º	aprovação      														  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
 
User Function MT110CFM()
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
Local lAlmox	:= .F.
Local aGrupo	:= {}
Local cAlEmail	:= ""
Local aUsers 	:= {}
Local cAlmox 	:= ALLTRIM(SuperGetMV("MV_XXGRALX",.F.,"000021"))+"/"+ALLTRIM(SuperGetMV("MV_XXMSALX",.F.,"000027"))
Local _cXXENDEN := ""
Local _cXXEN 	:= ""
Local _nXXEN 	:= 0
Local aSaldos 	:= {}
Local nSaldo 	:= 0
Local cQuery2 	:= ""
  

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

aUsers:=AllUsers()

For nX_ := 1 to Len(aUsers)
	If Len(aUsers[nX_][1][10]) > 0 .AND. !aUsers[nX_][1][17] //USUARIO BLOQUEADO
		aGrupo := {}
		//AADD(aGRUPO,aUsers[nX_][1][10])
		//FOR i:=1 TO LEN(aGRUPO[1])
		//	lAlmox := (aGRUPO[1,i] $ cAlmox)
		//NEXT
		//Ajuste nova rotina a antiga não funciona na nova lib MDI
		aGRUPO := UsrRetGrp(aUsers[nX_][1][2])
		IF LEN(aGRUPO) > 0
			FOR i:=1 TO LEN(aGRUPO)
				lAlmox := (ALLTRIM(aGRUPO[i]) $ cAlmox )
			NEXT
		ENDIF	
    	IF lAlmox
    		cAlEmail += ALLTRIM(aUsers[nX_][1][14])+";"
    	ENDIF
 	ENDIF
NEXT

IF !EMPTY(cAlEmail)
	cEmail += cAlEmail
ENDIF

//Monta corpo do email Solicitação de Compras
_cXXENDEN := ""  
DbSelectArea("SC1")
SC1->(DbSetOrder(1))
SC1->(DbSeek(xFilial("SC1")+cNumSol,.T.))
Do While SC1->(!eof()) .AND. SC1->C1_NUM == cNumSol
	IF EMPTY(_cXXENDEN) .AND. !EMPTY(SC1->C1_XXENDEN)
		_cXXENDEN := SC1->C1_XXENDEN
	ENDIF 
	IF (SC1->C1_QUANT-SC1->C1_XXQEST) > 0
    	AADD(aEmail,{SC1->C1_NUM,SC1->C1_SOLICIT,SC1->C1_ITEM,SC1->C1_PRODUTO,SC1->C1_DESCRI,SC1->C1_UM,SC1->C1_QUANT-SC1->C1_XXQEST,SC1->C1_DATPRF,SC1->C1_OBS,SC1->C1_CC,SC1->C1_XXDCC,SC1->C1_QUJE}) //aMotivo[val(SC1->C1_XXMTCM)]})
    ENDIF
    IF SC1->C1_APROV == "B"
    	lAprov := .F.
    ENDIF
    SC1->(dbskip())
Enddo

IF lAprov
	//Verifica Saldo em estoque
	aSaldos := {}
	FOR _IX:= 1 TO LEN(aEmail)
		nSaldo := 0
		IF aEmail[_IX,12] <= 0
			DBSELECTAREA("SB2")
			SB2->(DBSETORDER(1))
			SB2->(DBSEEK(xFILIAL("SB2")+aEmail[_IX,4],.T.))
			DO WHILE !EOF() .AND. SB2->B2_COD == aEmail[_IX,4]
				nSaldo += SB2->B2_QATU
				SB2->(DBSKIP())	
			ENDDO
			IF nSaldo > 0
				DBSELECTAREA("SCP")
				SCP->(DBSETORDER(2))
				SCP->(DBSEEK(xFILIAL("SCP")+aEmail[_IX,4],.T.))
				DO WHILE !EOF() .AND. SCP->CP_PRODUTO == aEmail[_IX,4]
					//A185BtVe Retorna o statusa da Req. Armazem
					IF !A185BtVe()
						nSaldo -= SCP->CP_QUANT
					ENDIF
					SCP->(DBSKIP())	
				ENDDO
			ENDIF
		ENDIF
		IF nSaldo > 0
			cQuery2 := ""
			cQuery2 += "Select COUNT(CP_XXNSCOM) AS nXXNSCOM FROM "+RETSQLNAME("SCP")+" SCP"
			cQuery2 += " WHERE SCP.D_E_L_E_T_ = '' AND CP_XXNSCOM='"+aEmail[_IX,1]+"'"
			cQuery2 += " AND CP_XXISCOM='"+aEmail[_IX,3]+"'"
		
			If SELECT("QSCP") > 0 
   				QSCP->(dbCloseArea())
			EndIf

			TCQUERY cQuery2 NEW ALIAS "QSCP"

            DBSELECTAREA("QSCP") 
			IF QSCP->nXXNSCOM == 0
				AADD(aSaldos,{	aEmail[_IX,1],; //N Solicit
								aEmail[_IX,3],; //Item
								aEmail[_IX,4],; //Cod. Prod
								aEmail[_IX,5],; //Dec. Prod
								aEmail[_IX,6],; //UN. Med.
								aEmail[_IX,7],; //Quand
								nSaldo,; //Saldo Estoque
								IIF(nSaldo < aEmail[_IX,7],nSaldo,aEmail[_IX,7]),; //Qnt Sol. Estoque
								aEmail[_IX,10],;  //CC
								aEmail[_IX,11],;  //Desc. CC
								aEmail[_IX,2]})   //Solicitante
			ENDIF
			QSCP->(dbCloseArea())
        ENDIF
    NEXT
    IF LEN(aSaldos) > 0
    	IF MsgYesNo("Produtos da solicitação em estoque. Deseja Utilizá-los?")
    		U_BKESTA01(aSaldos)
    		Return Nil
    	ENDIF
    ENDIF            

	//Adiciona Endereço de Entrega
	IF 	!EMPTY(_cXXENDEN)
    	_cXXEN := ""
		_nXXEN := 0
		_nXXEN := MLCOUNT(_cXXENDEN,80)
		FOR xi := 1 TO _nXXEN
   			_cXXEN += MemoLine(_cXXENDEN,80,xi)+" "
		NEXT    
		AADD(aEmail,{"<b>Endereço de Entrega: </b>"+_cXXEN+"</blockquote>"})  
		
	ENDIF
               
	cAssunto:= "Solicitação de Compra nº.:"+alltrim(cNumSol)+"       "+DTOC(DATE())+"-"+TIME()+" - "+ALLTRIM(SM0->M0_NOME)
	aCabs   := {"Cod. SC.","Solicitante","Ítem","Cod.Prod","Desc.Prod.","UM","Quant.","Data Limite Entrega","OBS","Centro de Custo","Descr. Centro de Custo","Qtd Entregue"}//"Motivo"}
	cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,"MT110CFM")
	IF 	!EMPTY(_cXXENDEN)
		cMsg    := STRTRAN(cMsg,"><b>Endereço de Entrega:"," colspan="+str(len(aCabs))+'><blockquote style="text-align:left;font-size:14.0"><b>Endereço de Entrega:')
    ENDIF
	U_SendMail("MT110CFM",cAssunto,cEmail,cEmailCC,cMsg,cAnexo,_lJob)
ENDIF

Return Nil
