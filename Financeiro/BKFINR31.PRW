#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKFINR31
BK - Títulos de Empréstimos Bancários
@Return
@author Marcos Bispo Abrahão
@since 23/06/2022
@version P12.1.33
/*/

User Function BKFINR31()

Local aRet			:= {}

Private cTitulo     := "Títulos de Empréstimos Bancários"
Private cPerg       := "BKFINR31"
Private aTipoEmis   := {"1-Emissão", "2-Vencimento"}
Private cTipoEmis   := "2"
Private aDados		:= {}

Private dDataI   	:= CTOD("")
Private dDataF   	:= CTOD("")
Private aParam 		:= {}

aAdd( aParam ,{ 2, "Emitir por:"    , "2-Vencimento" , aTipoEmis, 70,'.T.'  ,.T.})
aAdd( aParam, { 1, "Data inicial:"	, dDataBase	     , ""       , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Data final:"	, dDataBase	     , ""       , "", ""	, "" , 70  , .F. })  

If (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKCOMA09",.T.         ,.T.))

	u_LogPrw("BKFINR31")

	cTipoEmis	:= SUBSTR(mv_par01,1,1)
	dDataI		:= mv_par02
	dDataF		:= mv_par03
		

	FWMsgRun(, {|oSay| ProcQuery(.T.) }	, "", cPerg+" - Consultando dados...")
	FWMsgRun(, {|oSay| ProcRes1() }  	, "", cPerg+" - Resumindo dados com parcela...")
	FWMsgRun(, {|oSay| ProcQuery(.F.) }	, "", cPerg+" - Consultando dados...")
	FWMsgRun(, {|oSay| ProcRes2() }  	, "", cPerg+" - Resumindo dados sem parcela...")
	FWMsgRun(, {|oSay| RunFR31(aDados) }, "", cPerg+" - Gerando relatório...")

Endif

Return Nil


Static Function RunFR31(aDados)
    
Local aCabec    := {}
Local aPlans    := {}
Local nI        := 0

aAdd(aCabec,"Fornecedor")
aAdd(aCabec,"Prefixo")
aAdd(aCabec,"Número")
aAdd(aCabec,"Parcela")
aAdd(aCabec,"Codigo")
aAdd(aCabec,"Loja")
aAdd(aCabec,"Emissao")
aAdd(aCabec,"Vencimento")
aAdd(aCabec,"Baixa")
aAdd(aCabec,"Valor")
aAdd(aCabec,"Valor Pago")
aAdd(aCabec,"Saldo em aberto")

For nI := 1 TO Len(aDados)
	AADD(aPlans,{aDados[nI,2],aDados[nI,1],"Empréstimos Bancários",aCabec,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */ })   
Next

U_ArrToXlsx(aPlans,"Empréstimos Bancários",cPerg)


Return Nil


Static Function ProcQuery(lParc)
Local cQuery

cQuery := "SELECT " + CRLF
cQuery += "   E2_NOMFOR"+ CRLF
cQuery += "  ,E2_PREFIXO" + CRLF
cQuery += "  ,E2_NUM" + CRLF
cQuery += "  ,E2_PARCELA" + CRLF
cQuery += "  ,E2_FORNECE" + CRLF
cQuery += "  ,E2_LOJA" + CRLF
cQuery += "  ,E2_EMISSAO" + CRLF
cQuery += "  ,E2_VENCREA" + CRLF
cQuery += "  ,E2_BAIXA" + CRLF
cQuery += "  ,E2_VALOR" + CRLF
cQuery += "  ,E2_VALOR - E2_SALDO + E2_SDACRES - E2_SDDECRE AS E2VALPG" + CRLF
cQuery += "  ,E2_SALDO + E2_SDACRES - E2_SDDECRE AS E2SALDO" + CRLF
cQuery += " FROM "+RETSQLNAME("SE2")+ " SE2 " + CRLF
cQuery += " WHERE " + CRLF
cQuery += "   SE2.D_E_L_E_T_=''" + CRLF
cQuery += "   AND E2_NATUREZ = '0000000016'" + CRLF
If lParc
	cQuery += "   AND E2_PARCELA <> '  '" + CRLF
Else
	cQuery += "   AND E2_PARCELA = '  '" + CRLF
EndIf
IF cTipoEmis == '1'
	If !Empty(dDataI)
		cQuery += "   AND E2_EMISSAO >= '"+DTOS(dDataI)+"'" + CRLF
	EndIf
	If !Empty(dDataF)
		cQuery += "   AND E2_EMISSAO <= '"+DTOS(dDataF)+"'" + CRLF
	EndIf
ELSEIF cTipoEmis == '2'
	If !Empty(dDataI)
		cQuery += " AND E2_VENCREA >= '"+DTOS(dDataI)+"'" + CRLF
	EndIf
	If !Empty(dDataF)
		cQuery += " AND E2_VENCREA <= '"+DTOS(dDataF)+"'" + CRLF
	EndIf
ENDIF
If lParc
	cQuery += "ORDER BY E2_PREFIXO,E2_NUM,E2_PARCELA,E2_FORNECE" + CRLF
Else
	cQuery += "ORDER BY E2_NOMFOR,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_FORNECE" + CRLF
EndIf

u_LogMemo("BKFINR31.SQL",cQuery)

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP",.T.,.T.)

TCSetField("QTMP","E2_EMISSAO","D",8,0)
TCSetField("QTMP","E2_VENCREA","D",8,0)
TCSetField("QTMP","E2_BAIXA","D",8,0)

Return

// Titulos com parcelas
Static Function ProcRes1()
Local aLinha  := {}
Local aLinhas := {}
Local cTitulo := ""
Local cChave  := ""
Local nX	  := 0
Local aStruct := QTMP->(dbStruct())

DbSelectArea("QTMP")
dbGoTop()

Do While !EOF()

	aLinhas := {}
	cTitulo := TRIM(QTMP->E2_NUM)+"-"+TRIM(QTMP->E2_NOMFOR)

	cChave  := QTMP->(E2_PREFIXO+E2_NUM)
	Do While !EOF() .AND. cChave == QTMP->(E2_PREFIXO+E2_NUM)

		aLinha  := {}
		For nX := 1 to Len( aStruct )   // Até o campo anterior a TRB->E5_BLOQ
			aAdd(aLinha,FieldGet( nX ))
		Next

		aAdd(aLinhas,aClone(aLinha))

		DbSelectArea("QTMP")
		dbSkip()
	EndDo

	aAdd(aDados,{cTitulo,aClone(aLinhas)})

EndDo

QTMP->(dbCloseArea())

Return Nil


// Titulos sem parcelas
Static Function ProcRes2()
Local aLinha  := {}
Local aLinhas := {}
Local cTitulo := ""
Local cChave  := ""
Local nX	  := 0
Local aStruct := QTMP->(dbStruct())

DbSelectArea("QTMP")
dbGoTop()

Do While !EOF()

	aLinhas := {}
	cTitulo := TRIM(QTMP->E2_NOMFOR)

	cChave  := QTMP->(QTMP->E2_NOMFOR)
	Do While !EOF() .AND. cChave == QTMP->(QTMP->E2_NOMFOR)

		aLinha  := {}
		For nX := 1 to Len( aStruct )   // Até o campo anterior a TRB->E5_BLOQ
			aAdd(aLinha,FieldGet( nX ))
		Next

		aAdd(aLinhas,aClone(aLinha))

		DbSelectArea("QTMP")
		dbSkip()
	EndDo

	aAdd(aDados,{cTitulo,aClone(aLinhas)})

EndDo

QTMP->(dbCloseArea())

Return Nil

