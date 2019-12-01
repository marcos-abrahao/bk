#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ M185GRV º Autor ³ Adilson do Prado         Data ³10/02/2015º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ponto Entrada gravar alteração na solicitação de compras	  º±±
±±º            apos baixa da solicitação ao Almoxarifado                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function M185GRV()
Local cQuery := ""

cQuery := "UPDATE "+RetSqlName("SC1")+" SET C1_QUJE=(C1_QUJE+CP_QUJE),C1_XXQEST=(C1_XXQEST+CP_QUJE)"
cQuery += " FROM "+RetSqlName("SC1")+" SC1" 
cQuery += " INNER JOIN "+RetSqlName("SCP")+" SCP ON SC1.D_E_L_E_T_=''"
cQuery += " AND SC1.C1_NUM = SCP.CP_XXNSCOM" 
cQuery += " AND SC1.C1_ITEM = SCP.CP_XXISCOM" 
cQuery += " WHERE SCP.D_E_L_E_T_='' AND CP_NUM='"+SCP->CP_NUM+"'"
cQuery += " AND C1_XXQEST=0 AND CP_QUJE<>0"

If TCSQLExec(cQuery) < 0 
	MsgStop(TCSQLERROR())
endif

U_EMAILSOL(SCP->CP_XXNSCOM)

Return Nil 


