#INCLUDE 'PROTHEUS.CH' 
#INCLUDE "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT105FIM   ºAutor  ³Adilson do Prado    º Data ³  25/09/13  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada enviar mensagem de aviso de inclusão de   º±±
±±º          ³ Solicitatção ao Almoxarifado                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ³Analista/Alterações                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function MT105FIM()
Local nOpcap 	:= PARAMIXB
Local cSOLALMOX := SCP->CP_NUM
Local cSOLCOMPR := SCP->CP_XXNSCOM
Local nREC_SCP  := SCP->(Recno())
Local cAssunto	:= ""
Local cEmail	:= "microsiga@bkconsultoria.com.br;"
Local cEmailCC  := ""
Local cMsg 		:= "" 
Local cAnexo	:= ""
Local _lJob		:= .F.
Local aCabs		:= {}
Local aEmail	:= {}
Local aUser     := {}
Local aUsers    := {}
Local aGrupo    := {}
Local cAlmox    := ""
Local lAlmox    := .F.

cAlmox := SuperGetMV("MV_XXGRALX",.F.,"000021")  

PswOrder(1) 
PswSeek(__CUSERID)  
aUser  := PswRet(1)
IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
	cEmail += ALLTRIM(aUser[1,14])+';'
ENDIF

aUsers:=AllUsers()

For nX := 1 to Len(aUsers)
	If Len(aUsers[nX][1][10]) > 0 .AND. !aUsers[nX][1][17] //USUARIO BLOQUEADO
		aGrupo := {}
		//AADD(aGRUPO,aUsers[nX][1][10])
		//FOR i:=1 TO LEN(aGRUPO[1])
		//	lAlmox := (aGRUPO[1,i] $ cAlmox)
		//NEXT
		//Ajuste nova rotina a antiga não funciona na nova lib MDI
		aGRUPO := UsrRetGrp(aUsers[nX][1][2])
		IF LEN(aGRUPO) > 0
			FOR i:=1 TO LEN(aGRUPO)
				lAlmox := (ALLTRIM(aGRUPO[i]) $ cAlmox )
			NEXT
		ENDIF	
    	If lAlmox
    		cEmail += ALLTRIM(aUsers[nX][1][14])+";"
    	ENDIF
 	ENDIF
NEXT


dbSelectArea("SCP")
SET ORDER TO 1               
dbGoTop()
IF DBSEEK(xFilial("SCP")+cSOLALMOX+"01",.T.)
	cAssunto:= "Solicitação ao Almoxarifado - nº.:"+cSOLALMOX+" de "+SCP->CP_SOLICIT+"    "+DTOC(DATE())+"-"+TIME()+" - "+ALLTRIM(SM0->M0_NOME)
	aCabs   := {}
	aCabs   := {"Nº Sol. Almox.","Item","Cod. Produto","Descr. Produto","UM","Quant. Solicitada","Centro de Custo","Descr. Centro de Custo"}

	DO While !SCP->(EOF())
	 	IF SCP->CP_NUM == cSOLALMOX
			AADD(aEmail,{SCP->CP_NUM,SCP->CP_ITEM,SCP->CP_PRODUTO,SCP->CP_DESCRI,SCP->CP_UM,SCP->CP_QUANT,SCP->CP_CC,Posicione("CTT",1,xFilial("CTT")+SCP->CP_CC,"CTT_DESC01")})   
 	    ENDIF
 		SCP->(dbskip())
	Enddo
	
	cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,"MT105FIM")
	U_SendMail("MT105FIM",cAssunto,cEmail,cEmailCC,cMsg,cAnexo,_lJob)
ENDIF

IF nOpcap  == 3

	cQuery := "UPDATE "+RetSqlName("SC1")+" SET C1_QUJE=(C1_QUJE-C1_XXQEST),C1_XXQEST=0"
	cQuery += " FROM "+RetSqlName("SC1")+" SC1" 
	cQuery += " INNER JOIN "+RetSqlName("SCP")+" SCP ON SC1.D_E_L_E_T_=''"
	cQuery += " AND SC1.C1_NUM = SCP.CP_XXNSCOM" 
	cQuery += " AND SC1.C1_ITEM = SCP.CP_XXISCOM" 
	cQuery += " WHERE SCP.D_E_L_E_T_='*' AND CP_NUM='"+cSOLALMOX+"' AND C1_XXQEST<>0"

	If TCSQLExec(cQuery) < 0 
		MsgStop(TCSQLERROR())
	endif

	cQuery := "UPDATE "+RetSqlName("SCP")+" SET CP_XXNSCOM='',CP_XXISCOM=''" 
	cQuery += " WHERE D_E_L_E_T_='*' AND CP_NUM='"+cSOLALMOX+"'

	If TCSQLExec(cQuery) < 0 
		MsgStop(TCSQLERROR())
	endif

	U_EMAILSOL(cSOLCOMPR)
ENDIF

SCP->(dbGoTo(nREC_SCP))

Return 
