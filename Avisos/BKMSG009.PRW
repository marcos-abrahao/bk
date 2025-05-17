#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKMSG009
BK - Aviso de Solicitações de compras em aberto

@Return
@author Marcos Bispo Abrahão
@since 
@version P12.1.2310
/*/

User Function BKMSG009

Local cQuery            
Local _cAlias 	:= "QSC1"
Local aArea     := GetArea()
Local cAssunto	:= "Solicitações de compras em aberto: "
Local cEmail	:= ""
Local cEmailCC	:= u_EmailAdm()
Local cMsg    	:= ""
Local aCabs		:= {}
Local aEmail	:= {}
//Local aUser     := {}
Local cCrLf   	:= Chr(13) + Chr(10)
Local _ni
Local cProg		:= "BKMSG009"
Local aBKGrupo  := u_BKGrupo(2,FWCodEmp(),.F.)
Local nE		:= 0
Local mCSV 		:= ""
Local cAnexo 	:= ""
Local cAnexo1 	:= ""
Local cRodape   := ""
Local aUsers 	:= {}
Local aGrupos 	:= {u_GrpMCompras(),u_GrpUCompras()}
Local aDeptos 	:= {}

lJobV2 := IsBlind()

If FWCodEmp() <> "01" .AND. FWCodEmp() <> "20" // Barcas
	u_MsgLog(cProg,"Esta funcao somente rodar na empresa 01 ou 20","I")
	Return Nil
EndIf

u_MsgLog(cProg,cAssunto)

cEmail := u_GprEmail("",aUsers,aGrupos,aDeptos)

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

	cQuery := "SELECT C1_SOLICIT,C1_EMISSAO,C1_DATPRF,C1_NUM,C1_ITEM,C1_PRODUTO,B1_DESC,C1_UM,C1_QUANT,C1_QUJE,C1_CC,CTT_DESC01,C1_XDTAPRV" + CRLF
	cQuery += " FROM SC1"+aBKGrupo[nE,1]+"0 SC1" + CRLF
	cQuery += " LEFT JOIN SB1"+aBKGrupo[nE,1]+"0 SB1 ON SB1.D_E_L_E_T_='' AND B1_COD = C1_PRODUTO" + CRLF
	cQuery += " LEFT JOIN CTT"+aBKGrupo[nE,1]+"0 CTT ON CTT.D_E_L_E_T_='' AND C1_CC = CTT_CUSTO" + CRLF
	cQuery += " LEFT JOIN SC8"+aBKGrupo[nE,1]+"0 SC8 ON SC8.D_E_L_E_T_='' AND C8_NUM= C1_COTACAO AND C8_ITEMSC=C1_ITEM" + CRLF
	cQuery += " WHERE SC1.D_E_L_E_T_=''"   + CRLF
	cQuery += " AND C1_RESIDUO='' AND C1_APROV<>'B'" + CRLF
	cQuery += " AND C1_QUJE < C1_QUANT " + CRLF
	cQuery += " AND C8_NUMSC IS NULL" + CRLF
	cQuery += " GROUP BY C1_NUM,C1_ITEM,C1_SOLICIT,C1_EMISSAO,C1_DATPRF,C1_PRODUTO,B1_DESC,C1_UM,C1_QUANT,C1_QUJE,C1_CC,CTT_DESC01,C1_XDTAPRV" + CRLF
	cQuery += " ORDER BY C1_NUM,C1_ITEM,C1_SOLICIT,C1_EMISSAO,C1_DATPRF,C1_PRODUTO,B1_DESC,C1_UM,C1_QUANT,C1_QUJE,C1_CC,CTT_DESC01,C1_XDTAPRV" + CRLF
	
	TCQUERY cQuery NEW ALIAS "QSC1"
	TCSETFIELD("QSC1","C1_EMISSAO","D",8,0)
	TCSETFIELD("QSC1","C1_DATPRF","D",8,0)
	TCSETFIELD("QSC1","C1_XDTAPRV","D",8,0)

	u_LogMemo(cProg+TRIM(aBKGrupo[nE,1])+".SQL",cQuery)

	(_cAlias)->(dbgotop())

	Do While (_cAlias)->(!eof())
	
 		IF DATE() - QSC1->C1_EMISSAO > 2 // 7 // Alterado de 2 para 7, a pedido da Sra. Michele Moraes em 31/01/2019 
  			AADD(aEmail,{aBKGrupo[nE,3],;
   	   					(_cAlias)->C1_SOLICIT,;
   	   					(_cAlias)->C1_EMISSAO,;
   	   					(_cAlias)->C1_DATPRF,;
   	   					(_cAlias)->C1_NUM,;
   	   					(_cAlias)->C1_ITEM,;
   	   					(_cAlias)->C1_PRODUTO,;
   	   					(_cAlias)->B1_DESC,;
   	   					(_cAlias)->C1_UM,;
   	   					(_cAlias)->C1_QUANT,;
   	   					(_cAlias)->C1_QUJE,;
   	   					(_cAlias)->C1_CC,;
   	   					(_cAlias)->CTT_DESC01,; 
   	   					(_cAlias)->C1_XDTAPRV}) 
   	 	ENDIF

		(_cAlias)->(dbskip())
	EndDo

	(_cAlias)->(Dbclosearea())

Next

aCabs   := {"Empresa","Solicitante","Emissao","Limite Entrega","Solicitação N°","Item","Cod. Produto","Desc. Produto","Un.","Quant.","Qtd. Entregue","Contrato","Descrição Contrato","Aprov."}

IF LEN(aEmail) > 0

	FOR _ni := 1 TO LEN(aCabs)
		mCSV += aCabs[_ni] + IIF(_ni < LEN(aCabs),";","")
	NEXT

	FOR _ni := 1 TO LEN(aEmail)
    	cLinha := aEmail[_ni,01]+";"+aEmail[_ni,02]+";"+DTOC(aEmail[_ni,03])+";"+DTOC(aEmail[_ni,04])+";"+aEmail[_ni,05]+;
        	      ";"+aEmail[_ni,06]+";"+aEmail[_ni,07]+";"+aEmail[_ni,08]+";"+aEmail[_ni,09]+";"+STR(aEmail[_ni,10],6)+;
           		  ";"+STR(aEmail[_ni,11],6)+";"+aEmail[_ni,12]+";"+aEmail[_ni,13]+";"+DTOC(aEmail[_ni,14])
		mCSV += cLinha+cCrLf
	NEXT

	cAnexo1 := u_GrvAnexo(cProg+".csv",mCSV, .T.)

ENDIF

If LEN(aEmail) > 0
	cRodape := "Segue arquivo anexo"
Else
	cRodape := "Não há solicitações de compras em aberto"
EndIf

cAssunto += ALLTRIM(STR(LEN(aEmail)))

cMsg   := u_GeraHtmB(aEmail,cAssunto+" - "+DTOC(DATE())+" "+TIME(),aCabs,cProg,cRodape,cEmail,cEmailCC)
cAnexo := u_GrvAnexo(cProg+".html",cMsg, .T.)
U_BkSnMail(cProg,cAssunto,cEmail,cEmailCC,cMsg,{cAnexo1},.F.)

// Gravar no SZ0 - Avisos Web
u_BKMsgUs(cEmpAnt,cProg,{},u_GrpMCompras(),cAssunto,cAssunto,"F",cAnexo)
u_BKMsgUs(cEmpAnt,cProg,{},u_GrpUCompras(),cAssunto,cAssunto,"F",cAnexo)

RestArea(aArea)

