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
Private aStruct 	:= {}
Private aDados		:= {}
Private aDadosR		:= {}
Private nPosSaldo 	:= 0
Private nPosValor 	:= 0
Private nPosBaixa   := 0
Private nPosVlPg 	:= 0
Private nPosSlTit 	:= 0
Private nPosAmor 	:= 0
Private nPosJur 	:= 0
Private nPosIOF 	:= 0
Private nPosTxBc 	:= 0

Private dDataI   	:= CTOD("")
Private dDataF   	:= CTOD("")
Private aParam 		:= {}

aAdd( aParam ,{ 2, "Emitir por:"    , "2-Vencimento" , aTipoEmis, 70,'.T.'  ,.T.})
aAdd( aParam, { 1, "Data inicial:"	, dDataBase	     , ""       , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Data final:"	, dDataBase	     , ""       , "", ""	, "" , 70  , .F. })  

If (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKCOMA09",.T.         ,.T.))

	cTipoEmis	:= SUBSTR(mv_par01,1,1)
	dDataI		:= mv_par02
	dDataF		:= mv_par03

	u_WaitLog(, {|oSay| ProcQuery(.T.) }, "Consultando dados...")
	u_WaitLog(, {|oSay| ProcRes1() }  	, "Resumindo dados com parcela...")
	u_WaitLog(, {|oSay| ProcQuery(.F.) }, "Consultando dados...")
	u_WaitLog(, {|oSay| ProcRes2() }  	, "Resumindo dados sem parcela...")
	u_WaitLog(, {|oSay| RunFR31(aDados)}, "Gerando relatório...")

Endif

Return Nil


Static Function RunFR31(aDados)
    
Local aCabec    := {}
Local aCabecR   := {}
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
aAdd(aCabec,"Saldo Emprestimo")
aAdd(aCabec,"Valor Pago")
aAdd(aCabec,"Saldo em aberto")
aAdd(aCabec,"Principal")
aAdd(aCabec,"Juros")
aAdd(aCabec,"IOF")
aAdd(aCabec,"Taxas Bancárias")

aAdd(aCabecR,"Titulo")
aAdd(aCabecR,"Valor")
aAdd(aCabecR,"Saldo Emprestimo")
aAdd(aCabecR,"Valor Pago")
aAdd(aCabecR,"Saldo em aberto")
aAdd(aCabecR,"Principal")
aAdd(aCabecR,"Juros")
aAdd(aCabecR,"IOF")
aAdd(aCabecR,"Taxas Bancárias")

AADD(aPlans,{aDadosR,"Resumo","Empréstimos Bancários - Resumo",aCabecR,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */ })   

For nI := 1 TO Len(aDados)
	AADD(aPlans,{aDados[nI,2],aDados[nI,1],"Empréstimos Bancários - "+aDados[nI,1],aCabec,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */ })   
Next

U_ArrToXlsx(aPlans,"Empréstimos Bancários",cPerg)

Return Nil


Static Function ProcQuery(lParc)
Local cQuery
Local nX 		:= 0

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
cQuery += "  ,0 AS SALDO" + CRLF
cQuery += "  ,E2_VALOR - E2_SALDO + E2_SDACRES - E2_SDDECRE + E2_MULTA + E2_JUROS + E2_CORREC - E2_DESCONT AS E2VALPG" + CRLF
cQuery += "  ,E2_SALDO + E2_SDACRES - E2_SDDECRE AS E2SALDO" + CRLF
cQuery += "  ,E2_XEAMOR" + CRLF
cQuery += "  ,E2_XEJUR" + CRLF
cQuery += "  ,E2_XEIOF" + CRLF
cQuery += "  ,E2_XETBANC" + CRLF

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

aStruct := QTMP->(dbStruct())

For nX := 1 to Len( aStruct )   // Até o campo anterior a TRB->E5_BLOQ
	If Field( nX ) == "SALDO"
		nPosSaldo := nX
	ElseIf Field( nX ) == "E2_VALOR"
		nPosValor := nX
	ElseIf Field( nX ) == "E2_BAIXA"
		nPosBaixa := nX
	ElseIf Field( nX ) == "E2VALPG"
		nPosVlPg := nX
	ElseIf Field( nX ) == "E2SALDO"
		nPosSlTit := nX
	ElseIf Field( nX ) == "E2_XEAMOR"
		nPosAmor := nX
	ElseIf Field( nX ) == "E2_XEJUR"
		nPosJur := nX
	ElseIf Field( nX ) == "E2_XEIOF"
		nPosIOF := nX
	ElseIf Field( nX ) == "E2_XETBANC"
		nPosTxBc := nX
	EndIf

Next

Return

// Titulos com parcelas
Static Function ProcRes1()
Local aLinha  	:= {}
Local aLinhas 	:= {}
Local cTitulo 	:= ""
Local cChave  	:= ""
Local nX	  	:= 0
Local nTotal  	:= 0
Local nSaldoE 	:= 0
Local nSaldoF 	:= 0
Local nVVlPg 	:= 0
Local nVSlTit 	:= 0
Local nVAmor 	:= 0
Local nVJur 	:= 0
Local nVIOF 	:= 0
Local nVTxBc 	:= 0

DbSelectArea("QTMP")
dbGoTop()

Do While !EOF()

	aLinhas 	:= {}
	nTotal  	:= 0
	nSaldoE		:= 0
	nSaldoF		:= 0
	nVVlPg 		:= 0
	nVSlTit	 	:= 0
	nVAmor 		:= 0
	nVJur 		:= 0
	nVIOF 		:= 0
	nVTxBc 		:= 0

	cTitulo := TRIM(QTMP->E2_NUM)+"-"+TRIM(QTMP->E2_NOMFOR)

	cChave  := QTMP->(E2_PREFIXO+E2_NUM)
	Do While !EOF() .AND. cChave == QTMP->(E2_PREFIXO+E2_NUM)

		aLinha  := {}
		For nX := 1 to Len( aStruct )   // Até o campo anterior a TRB->E5_BLOQ
			aAdd(aLinha,FieldGet( nX ))
		Next

		nTotal	+= aLinha[nPosValor]
		nVVlPg 	+= aLinha[nPosVlPg]
		nVSlTit	+= aLinha[nPosSlTiT]
		nVAmor 	+= aLinha[nPosAmor]
		nVJur 	+= aLinha[nPosJur ]
		nVIOF 	+= aLinha[nPosIOF ]
		nVTxBc 	+= aLinha[nPosTxBc]

		aAdd(aLinhas,aClone(aLinha))
		DbSelectArea("QTMP")
		dbSkip()
	EndDo

	For nX := 1 to Len(aLinhas)
		If !EMPTY(aLinhas[nX,nPosBaixa])
			nSaldoE += aLinhas[nX,nPosValor]
		EndIf
		nSaldoF := nTotal - nSaldoE
		aLinhas[nX,nPosSaldo] := nSaldoF
	Next

	aAdd(aDados,{cTitulo,aClone(aLinhas)})
	aAdd(aDadosR,{cTitulo,nTotal,nSaldoF,nVVlPg,nVSlTit,nVAmor,nVJur,nVIOF,nVTxBc})

EndDo

QTMP->(dbCloseArea())


Return Nil


// Titulos sem parcelas
Static Function ProcRes2()
Local aLinha  	:= {}
Local aLinhas 	:= {}
Local cTitulo 	:= ""
Local cChave  	:= ""
Local nX	  	:= 0
Local nTotal  	:= 0
Local nSaldoE 	:= 0
Local nSaldoF	:= 0
Local nVVlPg 	:= 0
Local nVSlTit 	:= 0
Local nVAmor 	:= 0
Local nVJur 	:= 0
Local nVIOF 	:= 0
Local nVTxBc 	:= 0

DbSelectArea("QTMP")
dbGoTop()

Do While !EOF()

	aLinhas 	:= {}
	nTotal  	:= 0
	nSaldoE		:= 0
	nSaldoF     := 0
	nVVlPg 		:= 0
	nVSlTit	 	:= 0
	nVAmor 		:= 0
	nVJur 		:= 0
	nVIOF 		:= 0
	nVTxBc 		:= 0

	cTitulo := TRIM(QTMP->E2_NOMFOR)

	cChave  := QTMP->(QTMP->E2_NOMFOR)
	Do While !EOF() .AND. cChave == QTMP->(QTMP->E2_NOMFOR)

		aLinha  := {}
		For nX := 1 to Len( aStruct )   // Até o campo anterior a TRB->E5_BLOQ
			aAdd(aLinha,FieldGet( nX ))
		Next

		nTotal	+= aLinha[nPosValor]
		nVVlPg 	+= aLinha[nPosVlPg]
		nVSlTit	+= aLinha[nPosSlTiT]
		nVAmor 	+= aLinha[nPosAmor]
		nVJur 	+= aLinha[nPosJur ]
		nVIOF 	+= aLinha[nPosIOF ]
		nVTxBc 	+= aLinha[nPosTxBc]

		aAdd(aLinhas,aClone(aLinha))
		DbSelectArea("QTMP")
		dbSkip()
	EndDo

	For nX := 1 to Len(aLinhas)
		If !EMPTY(aLinhas[nX,nPosBaixa])
			nSaldoE += aLinhas[nX,nPosValor]
		EndIf
		nSaldoF := nTotal - nSaldoE
		aLinhas[nX,nPosSaldo] := nSaldoF
	Next

	aAdd(aDados,{cTitulo,aClone(aLinhas)})
	aAdd(aDadosR,{cTitulo,nTotal,nSaldoF,nVVlPg,nVSlTit,nVAmor,nVJur,nVIOF,nVTxBc})

EndDo

QTMP->(dbCloseArea())

Return Nil



