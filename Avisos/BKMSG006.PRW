#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKMSG006
BK - Aviso de Pedidos de Venda Liberados

@Return
@author Marcos Bispo Abrahão
@since 14/05/24
@version P12.1.2310
/*/

User Function BKMSG006

Local nE 		:= 0
Local nI 		:= 0
Local aEmpresas := u_BKGrpDsp()
Local cQuery	:= ""            
Local cAssunto	:= "Aviso de lançamentos de despesas: "
Local cEmailCC	:= u_EmailAdm()
Local cEmail	:= ""
Local cMsg		:= ""
Local cTabSZ2	:= "SZ2010"
Local cTabCN9   := ""
Local cTabSE2   := ""
Local cTabSD1   := ""
Local cTabSF1   := ""
Local cTabSB1   := ""
Local cTabCTT   := ""
Local dData		:= Date()
Local aTmp 		:= {}
Local aCabs   	:= {"Empresa","Prefixo","Numero","Parcela","Vencimento","Entrada","Centro de Custo","Descr. Centro de Custo","Produto","Descrição","Valor Item","Valor Despesa","Usuário","Vigência"}
Local aEmail 	:= {}
Local cCCCons	:= ""
Local cFat 		:= ""
Local cGestor	:= ""
Local aSuper	:= {}
Local nCont 	:= 0
Local cFile  	:= ""

Private cProg := "BKMSG006" 

dData := DataValida(dData-1,.F.)

cAssunto += "de "+DTOC(dData)+" até "+DTOC(Date())+" "+TIME()

u_MsgLog(cProg,cAssunto)

cQuery := "WITH AVISO AS ( "+CRLF

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]
	cCCCons  := aEmpresas[nE,9]
	cFat     := aEmpresas[nE,7]
	If cFat == "S"
		cTabCN9 := "CN9"+cEmpresa+"0"
	Else
		cTabCN9 := "CN9010"
	EndIf
	cTabSE2 := "SE2"+cEmpresa+"0"
	cTabSD1 := "SD1"+cEmpresa+"0"
	cTabSF1 := "SF1"+cEmpresa+"0"
	cTabSB1 := "SB1"+cEmpresa+"0"
	cTabCTT := "CTT"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += "SELECT "+CRLF
	cQuery += "    '"+cEmpresa+"' AS EMPRESA"+CRLF
	cQuery += "    ,'"+cNomeEmp+"' AS NOMEEMP"+CRLF
	cQuery += "    ,E2_VENCREA "+CRLF
	cQuery += "    ,E2_EMIS1 "+CRLF
	cQuery += "    ,E2_PREFIXO "+CRLF
	cQuery += "    ,E2_NUM "+CRLF
	cQuery += "    ,E2_PARCELA "+CRLF
	If !Empty(cCCCons)
		cQuery += "    ,'"+cCCCons+"' AS D1_CC "+CRLF
	Else
		cQuery += "    ,ISNULL(Z2_CC, D1_CC) AS D1_CC "+CRLF
	EndIf
	cQuery += "    ,CTT_DESC01 "+CRLF
	cQuery += "    ,ISNULL(D1_COD, 'RH') AS D1_COD "+CRLF
	cQuery += "    ,ISNULL(Z2_NOME, B1_DESC) AS B1_DESC "+CRLF
	cQuery += "    ,ISNULL(D1_TOTAL, Z2_VALOR) AS D1_TOTAL "+CRLF

	cQuery += "    ,(SELECT SUM(D1_TOTAL) FROM "+cTabSD1+" SD1 "+CRLF
	cQuery += "       WHERE D1_DOC = E2_NUM "+CRLF
	cQuery += "    		AND D1_SERIE = E2_PREFIXO "+CRLF
	cQuery += "    		AND D1_FORNECE = E2_FORNECE "+CRLF
	cQuery += "    		AND D1_LOJA = E2_LOJA "+CRLF
	cQuery += "    		AND D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_ = '' ) AS D1TOTAL"+CRLF

	cQuery += "    ,Z2_VALOR "+CRLF
	cQuery += "    ,Z2_USUARIO "+CRLF
	cQuery += "    ,E2_VALOR "+CRLF
	cQuery += "    ,F1_XXUSER "+CRLF
	cQuery += "    ,CN9_XXDVIG "+CRLF
	cQuery += "    ,CN9_GESTC "+CRLF
	cQuery += "    ,USR1.USR_EMAIL"+CRLF
	cQuery += "    ,USR1.USR_ID"+CRLF
	cQuery += "    ,USR1.USR_CODIGO AS GESTOR"+CRLF
	cQuery += "    ,USR2.USR_CODIGO"+CRLF

	cQuery += "  FROM "+CRLF
	cQuery += "    "+cTabSE2+" SE2 "+CRLF

	cQuery += "    LEFT JOIN "+cTabSZ2+" SZ2 "+CRLF
	cQuery += "    	ON Z2_CODEMP = '"+cEmpresa+"' "+CRLF
	cQuery += "    	AND Z2_E2PRF = E2_PREFIXO "+CRLF
	cQuery += "    	AND Z2_E2NUM = E2_NUM "+CRLF
	cQuery += "    	AND Z2_E2PARC = E2_PARCELA "+CRLF
	cQuery += "    	AND Z2_E2TIPO = E2_TIPO "+CRLF
	cQuery += "    	AND Z2_E2FORN = E2_FORNECE "+CRLF
	cQuery += "    	AND Z2_E2LOJA = E2_LOJA "+CRLF
	cQuery += "    	AND SZ2.D_E_L_E_T_ = '' "+CRLF

	cQuery += "    LEFT JOIN "+cTabSD1+" SD1 "+CRLF
	cQuery += "    	ON  D1_DOC = E2_NUM "+CRLF
	cQuery += "    	AND D1_SERIE = E2_PREFIXO "+CRLF
	cQuery += "    	AND D1_FORNECE = E2_FORNECE "+CRLF
	cQuery += "    	AND D1_LOJA = E2_LOJA "+CRLF
	cQuery += "    	AND D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_ = '' "+CRLF

	cQuery += "    LEFT JOIN "+cTabSF1+" SF1 "+CRLF
	cQuery += "    	ON  F1_DOC = D1_DOC "+CRLF
	cQuery += "    	AND F1_SERIE = D1_SERIE "+CRLF
	cQuery += "    	AND F1_FORNECE = D1_FORNECE "+CRLF
	cQuery += "    	AND F1_LOJA = D1_LOJA "+CRLF
	cQuery += "    	AND F1_FILIAL = D1_FILIAL AND SF1.D_E_L_E_T_ = '' "+CRLF

	cQuery += "    LEFT JOIN "+cTabSB1+" SB1 "+CRLF
	cQuery += "    	ON  B1_COD = D1_COD "+CRLF
	cQuery += "    	AND B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.D_E_L_E_T_ = '' "+CRLF

	cQuery += "    LEFT JOIN "+cTabCTT+" CTT "+CRLF
	If !Empty(cCCCons)
		cQuery += "    	ON  CTT_CUSTO = '"+cCCCons+"' "+CRLF
	Else
		cQuery += "    	ON  CTT_CUSTO = ISNULL(D1_CC, Z2_CC) "+CRLF
	EndIf
	cQuery += "    	AND CTT_FILIAL = '"+xFilial("CTT")+"' AND CTT.D_E_L_E_T_ = '' "+CRLF

	cQuery += "    LEFT JOIN "+cTabCN9+" CN9 "+CRLF
	cQuery += "     ON  CN9.D_E_L_E_T_ = ''"+CRLF
	cQuery += "     AND CN9_FILIAL = '"+xFilial("CN9")+"'"+CRLF
	cQuery += "     AND CN9_REVATU = ' '"+CRLF
	If !Empty(cCCCons)
		cQuery += "     AND CN9_NUMERO = '"+cCCCons+"' "+CRLF
	Else
		cQuery += "     AND CN9_NUMERO = ISNULL(Z2_CC, D1_CC) "+CRLF
	EndIf

	cQuery += "    LEFT JOIN SYS_USR USR1 ON CN9_GESTC = USR1.USR_ID AND USR1.D_E_L_E_T_ = ''" + CRLF
	cQuery += "    LEFT JOIN SYS_USR USR2 ON F1_XXUSER = USR2.USR_ID AND USR2.D_E_L_E_T_ = ''" + CRLF

	cQuery += "  WHERE "+CRLF
	cQuery += "    E2_FILIAL = '"+xFilial("SE2")+"' AND SE2.D_E_L_E_T_ = ''"+CRLF
	cQuery += "    AND E2_EMIS1 >= '"+DTOS(dData)+"' "+CRLF
	cQuery += "    AND E2_PREFIXO <> 'LF ' "+CRLF // Não incluir Lançamentos de Folha
	// 21/08/23 - Remover UNIAO - Bruno Bueno
	cQuery += "    AND SUBSTRING(E2_FORNECE,1,5) <> 'UNIAO' "+CRLF
	If Empty(cCCCons)
		cQuery += " AND SUBSTRING(ISNULL(Z2_CC, D1_CC),1,3) <> '000'"+CRLF
	EndIf
Next
cQuery += ") "+CRLF
cQuery += "SELECT "+CRLF
cQuery += "  *"+CRLF
cQuery += " ,ISNULL(Z2_VALOR,((D1_TOTAL / D1TOTAL) * 100 * (E2_VALOR / 100))) AS DESPESA "+CRLF
cQuery += "FROM "+CRLF
cQuery += "  AVISO "+CRLF
cQuery += "ORDER BY "+CRLF
cQuery += "  USR_EMAIL,EMPRESA,D1_CC,E2_EMIS1,E2_NUM"+CRLF

u_LogMemo(cProg+".SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP",.T.,.T.)
tcSetField("QTMP","E2_EMIS1","D",8,0)
tcSetField("QTMP","E2_VENCREA","D",8,0)
tcSetField("QTMP","CN9_XXDVIG","D",8,0)
tcSetField("QTMP","DESPESA","N",12,2)

dbSelectArea("QTMP")
dbGoTop()

Do While !Eof()
	cEmail 	:= QTMP->USR_EMAIL
	cGestor	:= QTMP->GESTOR
	If Empty(cGestor)
		cGestor := "Gestor não informado"
	EndIf
	aEmail	:= {}

	// Envia o e-mail para os superiores do usuário também
	aSuper := u_ArSuper(QTMP->USR_ID)
	aAdd(aSuper,"000023") // Fabia
	aAdd(aSuper,"000288") // Wiliam Lisboa

	lDtInf	:= .F.
	Do While !EOF() .AND. cEmail == QTMP->USR_EMAIL
		aTmp := {}
		aAdd(aTmp,QTMP->NOMEEMP)
		aAdd(aTmp,QTMP->E2_PREFIXO)
		aAdd(aTmp,QTMP->E2_NUM)
		aAdd(aTmp,QTMP->E2_PARCELA)
		aAdd(aTmp,QTMP->E2_VENCREA)
		aAdd(aTmp,QTMP->E2_EMIS1)
		aAdd(aTmp,QTMP->D1_CC)
		aAdd(aTmp,QTMP->CTT_DESC01)
		aAdd(aTmp,QTMP->D1_COD)
		aAdd(aTmp,QTMP->B1_DESC)
		aAdd(aTmp,QTMP->D1_TOTAL)
		aAdd(aTmp,QTMP->DESPESA)
		aAdd(aTmp,IIf(Empty(QTMP->USR_CODIGO),Lower(QTMP->Z2_USUARIO),QTMP->USR_CODIGO))
		If QTMP->CN9_XXDVIG < (dDataBase - 60)
			aAdd(aTmp,'<font color="red">'+DTOC(QTMP->CN9_XXDVIG)+'</font>')
		Else
			aAdd(aTmp,QTMP->CN9_XXDVIG)
		EndIf
		aAdd(aEmail,aTmp)

		dbSkip()
		nCont++
	EndDo

	cEmail += ";"+u_aUsrEmail(aSuper,cEmail)

	If Len(aEmail) > 0
		cMsg     := u_GeraHtmA(aEmail,cAssunto + " - "+cGestor,aCabs,cProg,cEmail,cEmailCC)
		
		// Grava o anexo html
		cFile := cProg+DTOS(Date())+STRTRAN(TIME(),":","")+STRZERO(nI++,2)+".html"
		u_GrvAnexo(cFile,cMsg,.T.)		

		U_BkSnMail(cProg,cAssunto,cEmail,cEmailCC,cMsg,{cFile},.F.)
	EndIf
EndDo

QTMP->(dbCloseArea())

u_MsgLog(cProg,"Aviso de lançamentos de despesas "+ALLTRIM(STR(nCont)))

Return

