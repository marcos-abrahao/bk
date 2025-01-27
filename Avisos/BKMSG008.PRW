#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKMSG008
BK - Aviso de Pedidos de compras não entregues

@Return
@author Marcos Bispo Abrahão
@since 
@version P12.1.2310
/*/

User Function BKMSG008

Local cQuery            
Local cAlias 	:= "QSC7"
Local aArea     := GetArea()
Local cAssunto	:= "Pedidos de compras não entregues: "
Local cEmail	:= ""
Local cEmailCC	:= u_EmailAdm()
Local cMsg    	:= ""
Local cAnexo    := ""
Local aCabs		:= {}
Local aEmail	:= {}
Local cProg		:= "BKMSG008"
Local aBKGrupo	:= u_BKGrupo()
Local nE		:= 0
Local aUsers 	:= {}
Local aGrupos 	:= {u_GrpMCompras(),u_GrpUCompras()}
Local aDeptos 	:= {}

cEmail := u_GprEmail("",aUsers,aGrupos,aDeptos)
lJobV2 := IsBlind()

If FWCodEmp() <> "01"
	u_MsgLog(cProg,"Esta Funcao Rodar somente na empresa 01")
	Return Nil
EndIf

u_MsgLog("BKMSG008",cAssunto)

//EMAIL - GRUPO DE COMPRAS
/*
SY1->(dbgotop())
Do While SY1->(!eof())                                                                                                               
	PswOrder(1) 
	PswSeek(SY1->Y1_USER) 
	aUser  := PswRet(1)
	IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
		cEmail += ALLTRIM(aUser[1,14])+';'
	ENDIF
	aAdd(aUsers,SY1->Y1_USER)
	SY1->(dbskip())
Enddo
*/

For nE := 1 To Len(aBKGrupo)  

	cQuery := "SELECT C7_NUM,C7_DATPRF,C7_FORNECE,A2_NOME,C1_SOLICIT,CTT_CUSTO,CTT_DESC01"
	cQuery += " FROM SC7"+aBkGrupo[nE,1]+"0 SC7"
	cQuery += " INNER JOIN SC1"+aBkGrupo[nE,1]+"0 SC1 ON SC1.D_E_L_E_T_='' AND C7_NUMSC = C1_NUM"
	cQuery += " INNER JOIN SA2"+aBkGrupo[nE,1]+"0 SA2 ON SA2.D_E_L_E_T_='' AND C7_FORNECE = A2_COD"
	cQuery += " INNER JOIN CTT"+aBkGrupo[nE,1]+"0 CTT ON CTT.D_E_L_E_T_='' AND C7_CC = CTT_CUSTO"
	cQuery += "  WHERE SC7.D_E_L_E_T_='' AND C7_RESIDUO='' AND C7_QUJE < C7_QUANT"
	cQuery += "   AND C7_QTDACLA < C7_QUANT"  // Não lista pedidos em pré-nota (02/07/2021)
	cQuery += " GROUP BY C7_NUM,C7_DATPRF,C7_FORNECE,A2_NOME,C1_SOLICIT,CTT_CUSTO,CTT_DESC01"
	cQuery += " ORDER BY C7_NUM,C7_DATPRF,C7_FORNECE,A2_NOME,C1_SOLICIT,CTT_CUSTO,CTT_DESC01"
	
	TCQUERY cQuery NEW ALIAS "QSC7"
	TCSETFIELD("QSC7","C7_DATPRF","D",8,0)

	(cAlias)->(dbgotop())

	Do While (cAlias)->(!eof())
	
		IF DATE() - QSC7->C7_DATPRF > 0 // Era 2, alterada para zero - Solicitado pela Michele em 26/07/21 
    
  			AADD(aEmail,{aBkGrupo[nE,3],;
   	   					(cAlias)->C7_NUM,;
   	   					(cAlias)->C7_DATPRF,;
   	   					(cAlias)->C7_FORNECE,;
   	   					(cAlias)->A2_NOME,;
   	   					(cAlias)->C1_SOLICIT,;
   	   					(cAlias)->CTT_CUSTO,;
   	   					(cAlias)->CTT_DESC01})
   	   	ENDIF

		(cAlias)->(dbskip())
	EndDo

	(cAlias)->(Dbclosearea())

Next

cAssunto += ALLTRIM(STR(LEN(aEmail)))

aCabs	:= {"Empresa","N°Pedido","Dt Entrega","Fornecedor","Nome Fornecedor","Solicitante","C.Custo","Descrição C.Custo"}

cMsg	:= u_GeraHtmB(aEmail,cAssunto,aCabs,cProg,"",cEmail,cEmailCC)

cAnexo	:= cProg+".html"
u_GrvAnexo(cAnexo,cMsg,.T.)

// Gravar no SZ0 - Avisos Web
u_BKMsgUs(cEmpAnt,cProg,{},u_GrpMCompras(),cAssunto,cAssunto,"F",cAnexo)
u_BKMsgUs(cEmpAnt,cProg,{},u_GrpUCompras(),cAssunto,cAssunto,"F",cAnexo)

U_BkSnMail(cProg,cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.F.)

RestArea(aArea)
