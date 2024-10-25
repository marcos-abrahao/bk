#INCLUDE 'PROTHEUS.CH' 
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT105FIM
BK - Ponto de Entrada enviar mensagem de aviso de inclusão de   º±±
     Solicitatção ao Almoxarifado
@Return
@author Adilson do Prado
@since 25/09/13
@version P11/P12
/*/

User Function MT105FIM()
Local nOpcap 	:= PARAMIXB
Local cSOLALMOX := SCP->CP_NUM
Local cSOLCOMPR := SCP->CP_XXNSCOM
Local nREC_SCP  := SCP->(Recno())
Local cAssunto	:= ""
Local cEmail	:= u_EmailAdm()
Local cEmailCC  := ""
Local cMsg 		:= "" 
Local cAnexo	:= ""
Local aCabs		:= {}
Local aEmail	:= {}
Local aUser     := {}
//Local aUsers    := {}
//Local aGrupo    := {}
//Local cAlmox    := ""
//Local lAlmox    := .F.
//Local nX,i

PswOrder(1) 
PswSeek(__cUserId)  
aUser  := PswRet(1)
IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
	cEmail += ALLTRIM(aUser[1,14])+';'
ENDIF

cEmail  += u_EmEstAlm(__cUserId,.T.,cEmail)

dbSelectArea("SCP")
SET ORDER TO 1               
dbGoTop()
IF DBSEEK(xFilial("SCP")+cSOLALMOX+"01",.T.)
	cAssunto:= "Solicitação ao Almoxarifado - nº.:"+cSOLALMOX+" de "+SCP->CP_SOLICIT+"    "+DTOC(DATE())+"-"+TIME()+" - "+FWEmpName(cEmpAnt)
	aCabs   := {}
	aCabs   := {"Nº Sol. Almox.","Item","Cod. Produto","Descr. Produto","UM","Quant. Solicitada","Centro de Custo","Descr. Centro de Custo"}

	DO While !SCP->(EOF())
	 	IF SCP->CP_NUM == cSOLALMOX
			AADD(aEmail,{SCP->CP_NUM,SCP->CP_ITEM,SCP->CP_PRODUTO,SCP->CP_DESCRI,SCP->CP_UM,SCP->CP_QUANT,SCP->CP_CC,Posicione("CTT",1,xFilial("CTT")+SCP->CP_CC,"CTT_DESC01")})   
 	    ENDIF
 		SCP->(dbskip())
	Enddo
	
	cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,"MT105FIM",cEmail,cEmailCC)

	cAnexo := "MT105FIM"+alltrim(cSOLALMOX)+".html"
	u_GrvAnexo(cAnexo,cMsg,.T.)	
	u_BkSnMail("MT105FIM",cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)
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

	U_EMAILSOL(cSOLCOMPR,"MT105FIM")
ENDIF

SCP->(dbGoTo(nREC_SCP))

Return 
