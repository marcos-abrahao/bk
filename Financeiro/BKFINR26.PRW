#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKFINR26
BK - Planilha de Pedidos e Faturamento
v29/03/20
@Return
@author Marcos Bispo Abrahใo
@since 15/03/2020
@version P12
/*/
Static __oTBxCanc
Static __oTipoBa
//Static __oHash
Static __aTtImp


User Function BKFINR26()

Local nF    	:= 0
Local NIL		:= 0
Local cCampo	:= ""
Local cTipo 	:= ""
Local nTam  	:= 0
Local nDec  	:= 0
Local cPict 	:= PesqPict("SF2","F2_VALBRUT")
Local cTitC 	:= ""
Local nTamCol   := 0
Local lTotal    := .F.
Local oTmpTb
Local aAreaSE5	

Private cTTipos 	:= ""

Private cTitulo     := "Pedidos e Faturamento"
Private cPerg       := "BKFINR26"

Private aParam		:=	{}
Private aRet		:=	{}

Private dDataI  	:= CTOD("")
Private dDataF  	:= CTOD("")
Private cTipoEm		:= "Pedido"
Private cSaldo      := "Nใo"

Private cOpcBco		:= "1"	// 1 - Imprime 3 bancos em 9 colunas (Banco,Nome e valor) - 2 Imprime um valor de banco por coluna, at้ 30 bancos

Private aFields     := {}
Private aCabs       := {}
Private aCampos     := {}
Private aTitulos    := {}
Private aPlans      := {}
Private aDbf        := {}
Private aTamCol		:= {}
Private aTotal		:= {}
Private cAliasQry   := ""
Private cAliasTrb   := GetNextAlias()
Private nCont       := 0
Private aTotais     := {}
Private aLF         := {}
Private nTop		:= 3
Private nTopV		:= nTop + 1
Private nIniBc		:= 0
Private nMaxBco		:= iIf(cOpcBco=="1",4,30)
Private cNBanco		:= ""

aAreaSE5 := se5->(GetArea("SE5"))

aAdd( aParam, { 1, "Emissใo Inicial:" , dDataBase, "" 				, "", ""	, "" , 60  , .F. })
aAdd( aParam, { 1, "Emissใo Final:"   , dDataBase, "" 				, "", ""	, "" , 60  , .F. })  
aAdd( aParam ,{ 2, "Emissใo por"      , cTipoEm  , {"Pedido", "NF"}	, 60,'.T.'  ,.T.})
aAdd( aParam ,{ 2, "Somente com saldo", cSaldo	  ,{"Sim", "Nใo"}	, 60,'.T.'  ,.T.})

If !BkFR26()
   Return
EndIf

/*
Codigo Cliente
Loja
Nome Cliente
Nome Gestor do Contrato
Centro de Custos
Numero Contrato
Competencia
Data Pedido Faturamento
N๚mero Medi็ใo
N๚mero Planilha
N๚mero da Nota Fiscal
Data Emissใo da Nota Fiscal
Vencimento da Nota Fiscal
Valor Bruto
Valor Liquido
Saldo a Receber
*/

aAdd(aTitulos,cPerg+"/"+TRIM(cUserName)+" - "+cTitulo)

//C5_CLIENTE,C5_LOJACLI,C5_MDCONTR,C5_EMISSAO,C5_XXCOMPM,C5_MDNUMED,C5_MDPLANI,C5_NOTA,F2_DOC,F2_EMISSAO,E1_VALOR,E1_VENCREA,E1_BAIXA,E1_SALDO
aAdd(aFields,{"XX_NOMCLI" ,"A1_NOME"})
aAdd(aFields,{"XX_CLIENTE","C5_CLIENTE"})
aAdd(aFields,{"XX_LOJA"   ,"C5_LOJACLI"})
aAdd(aFields,{"XX_CONTRAT","","XX_CONTRAT","Contrato","@!","C",9,0})
aAdd(aFields,{"XX_DESC01" ,"CTT_DESC01","","Descri็ใo do Contrato"})
aAdd(aFields,{"XX_NOMGES" ,"CN9_XXNRBK"})
aAdd(aFields,{"XX_COMPET" ,"C5_XXCOMPM"})
aAdd(aFields,{"XX_MEDICAO","C5_MDNUMED"})
aAdd(aFields,{"XX_PLANI"  ,"C5_MDPLANI"})
aAdd(aFields,{"XX_PEDIDO" ,"C5_NUM","","Pedido"})
aAdd(aFields,{"XX_EMISSAO","C5_EMISSAO","","Emissao Ped."})
aAdd(aFields,{"XX_VLPREV" ,"CND_VLPREV"})
aAdd(aFields,{"XX_VALPED" ,"","XX_VALPED","Vl.Pedido",cPict,"N",18,2})
aAdd(aFields,{"XX_LIBEROK","C5_LIBEROK","","Ped. liberado"})
aAdd(aFields,{"XX_LIBERAD","C5_XXULIB"})
aAdd(aFields,{"XX_DATALIB","C5_XXDLIB","","Data Lib. Pedido"})
aAdd(aFields,{"XX_NF"     ,"F2_DOC","","Nota Fiscal n๚mero"})
aAdd(aFields,{"XX_NDC"    ,"E1_NUM","XX_NDC","Nota Debito n๚mero"})
aAdd(aFields,{"XX_DATANF" ,"F2_EMISSAO","","Data Emissao NF/ND"})
aAdd(aFields,{"XX_EMISSOR","F2_USERLGI","","Responsแvel emissใo NF"})
aAdd(aFields,{"XX_VALNF"  ,"F2_VALBRUT","","Vl Bruto NF"})

aAdd(aFields,{"XX_VALLIQ" ,"","XX_VALLIQ","Vl Liq.NF",cPict,"N",18,2})
aAdd(aFields,{"XX_E5DESC" ,"E5_VLDESCO","XX_E5DESC" ,"Desconto - Imp. Cli nใo reteve"})
aAdd(aFields,{"XX_VENC"   ,"E1_VENCREA"})
aAdd(aFields,{"XX_BAIXA"  ,"E1_BAIXA"})
If cOpcBco == "1"
	aAdd(aFields,{"XX_TOTBX" ,"","XX_TOTBX","Total Bcos",cPict,"N",18,2})
EndIf

aAdd(aFields,{"XX_SALDO"  ,"E1_SALDO",  ""          ,"Saldo a Receber"})

If cOpcBco == "1"
	nIniBc := Len(aFields)
	For nF := 1 TO nMaxBco
		If nf <= (nMaxBco - 2)
			aAdd(aFields,{"XX_BCO"+STRZERO(nF,2) ,"","XX_BCO"+STRZERO(nF,2),"Banco "+cValToChar(nF),"@!","C",18,0})
			aAdd(aFields,{"XX_NBC"+STRZERO(nF,2) ,"A6_NOME", "XX_NBC"+STRZERO(nF,2),"Nome Banco "+cValToChar(nF)})
		EndIf
		If nF == (nMaxBco)
			cNBanco := "CX1"		
		ElseIf nF == (nMaxBco - 1)
			cNBanco := "999"
		Else
			cNBanco := cValToChar(nF)
		EndIf
		
		aAdd(aFields,{"XX_VLB"+STRZERO(nF,2) ,"E5_VALOR","XX_BCO"+STRZERO(nF,2),"Vl. Banco "+cNBanco})
	Next
EndIf

If cOpcBco == "2"
	nIniBc := Len(aFields)
	For nF := 1 TO nMaxBco
		aAdd(aFields,{"XX_BCO"+STRZERO(nF,2) ,"E5_VALOR","XX_BCO"+STRZERO(nF,2),"Vl Bco "+cValToChar(nF)})
	Next
EndIf
//aAdd(aFields,{"XX_ABATIM" ,"","XX_ABATIM","Abatimento",cPict,"N",18,2})
//aAdd(aFields,{"XX_IMPOST" ,"","XX_IMPOST","Imp.Retidos",cPict,"N",18,2})

aDbf := {}

For nF := 1 To Len(aFields)

	aAdd(aCampos,"(cAliasTrb)->"+aFields[nF,1])
	cCampo := aFields[nF,1]
	cTipo  := ""
	nTam   := 0
	nDec   := 0
	cPict  := ""
	cTitC  := ""

	If Len(aFields[NF]) > 3
		If !Empty(aFields[nF,4])
			cTitC := aFields[nF,4]
		EndIf
	EndIf

	If Len(aFields[NF]) > 4
		If !Empty(aFields[nF,5])
			cPict := aFields[nF,5]
		EndIf
	EndIf

	If Len(aFields[NF]) > 5
		If !Empty(aFields[nF,6])
			cTipo := aFields[nF,6]
		EndIf
	EndIf

	If Len(aFields[NF]) > 6
		If !Empty(aFields[nF,7])
			nTam := aFields[nF,7]
		EndIf
	EndIf

	If Len(aFields[NF]) > 7
		If !Empty(aFields[nF,8])
			nDec := aFields[nF,8]
		EndIf
	EndIf

	If Empty(cTitC)
		cTitC := RetTitle(aFields[nF,2])
	EndIf
	If Empty(cPict)
		cPict := GetSX3Cache(aFields[nF,2],"X3_PICTURE")
	EndIf
	If Empty(cTipo)
		cTipo := GetSX3Cache(aFields[nF,2],"X3_TIPO")
	EndIf
	If nTam = 0
		nTam  := GetSX3Cache(aFields[nF,2],"X3_TAMANHO")
	EndIf
	If nDec = 0 .and. GetSX3Cache(aFields[nF,2],"X3_DECIMAL") <> Nil
		nDec  := GetSX3Cache(aFields[nF,2],"X3_DECIMAL")			
	EndIf
		
	aAdd( aDbf,  {cCampo , cTipo, nTam, nDec } )
	aAdd( aCabs, cTitC)

	nTamCol := 0
	lTotal  := .F.
	If cTipo == "N"
		nTamCol := 17
		lTotal  := .T.
	ElseIf cTipo == "D"
		nTamCol := 15
	Else
		If nTam > 8
			nTamCol := nTam + 1
		EndIf
	EndIf
	aAdd( aTamCol, nTamCol)
	aAdd( aTotal,lTotal)
Next

//----------------------------
//Cria็ใo da tabela temporแria
//----------------------------
oTmpTb := FWTemporaryTable():New( cAliasTrb )
oTmpTb:SetFields( aDbf )
oTmpTb:Create()

If !Empty( __oTBxCanc )
	__oTBxCanc:Destroy()
	__oTBxCanc := Nil
EndIf
If !Empty( __oTipoBa )
	__oTipoBa:Destroy()
	__oTipoBa := Nil
EndIf

__oTBxCanc	:= FWPreparedStatement():New( '' )
__oTipoBa	:= FWPreparedStatement():New( '' )
//__oHash		:= tHashMap():New() //Cria o Objeto do Hash Map

Processa( {|| ProcBKR26() })

AADD(aPlans,{cAliasTrb,TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, .F. })
U_GeraXlsx(aPlans,"",cPerg, .F.,aParam)

oTmpTb:Delete()

If !Empty( __oTBxCanc )
	__oTBxCanc:Destroy()
	__oTBxCanc := Nil
EndIf
If !Empty( __oTipoBa )
	__oTipoBa:Destroy()
	__oTipoBa := Nil
EndIf

SE5->(RestArea(aAreaSE5))

Return


Static Function BkFR26
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg      ,.T.         ,.T.))
	lRet     := .T.
	dDataI   := mv_par01
	dDataF   := mv_par02
	cTipoEm	 := mv_par03
	cSaldo   := mv_par04
	cTitulo  := "Pedidos e Faturamento - Perํodo: "+DTOC(dDataI)+" at้ "+DTOC(dDataF)
Endif
Return lRet



Static Function ProcBKR26
Local cQuery  := ""
Local nF      := 0
Local nB	  := 0
Local nSaldo  := 0
//Local nAbatim := 0
Local cBanco  := ""
Local cAgencia:= ""
Local cConta  := ""
Local aBcoRec := {}
Local aBcos   := {}
Local cNomeBco:= ""
Local nTotBx  := 0

Private xCampo

Procregua(5)
IncProc("Consultando o banco de dados...")

//cQuery := "SELECT "
//For nF := 1 To Len(aFields)
//	If LEN(aFields[nF]) < 3 .OR. Empty(aFields[nF,3])
//		cQuery += aFields[nF,2]+","
//	EndIf
//Next
cQuery := "SELECT A1_NOME,C5_CLIENTE,C5_LOJACLI,CTT_DESC01,CN9_XXNRBK,C5_XXCOMPM,C5_MDNUMED,C5_MDPLANI,C5_NUM,C5_EMISSAO,CND_VLPREV,C5_LIBEROK,C5_XXULIB,C5_XXDLIB,F2_DOC,F2_EMISSAO,F2_USERLGI,F2_VALBRUT,E1_VENCREA,E1_BAIXA,E1_SALDO," + CRLF
cQuery += "SC5.R_E_C_N_O_ AS C5RECNO,SF2.R_E_C_N_O_ AS F2RECNO, SE1.R_E_C_N_O_ AS E1RECNO," + CRLF
cQuery += "  CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1 ELSE C5_MDCONTR END AS XX_CONTRAT," + CRLF
cQuery += "  (SELECT SUM(C6_VALOR) FROM "+RETSQLNAME("SC6")+" SC6 WHERE SC6.C6_NUM = SC5.C5_NUM AND SC6.D_E_L_E_T_ = ' ' AND SC6.C6_FILIAL = C5_FILIAL) AS XX_VALPED," + CRLF
cQuery += "  (SF2.F2_VALFAT - SF2.F2_VALIRRF - SF2.F2_VALINSS - SF2.F2_VALPIS - SF2.F2_VALCOFI - SF2.F2_VALCSLL - (CASE SF2.F2_RECISS WHEN '1' THEN SF2.F2_VALISS ELSE 0 END)) AS XX_VALLIQ," + CRLF
cQuery += "  (SE1.E1_IRRF + SE1.E1_INSS + SE1.E1_PIS + SE1.E1_COFINS + SE1.E1_CSLL + (CASE SF2.F2_RECISS WHEN '1' THEN SE1.E1_ISS ELSE 0 END)) AS XX_IMPOST,"+ CRLF
cQuery += "  (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "    AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = ' ') AS XX_E5DESC, "+ CRLF
cQuery += "  (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "    AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = ' ') AS XX_E5MULTA,"+ CRLF
cQuery += "  '' AS XX_NDC" + CRLF
cQuery += " FROM "+RETSQLNAME("SC5")+" SC5" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+" SF2 ON C5_NOTA = F2_DOC AND SF2.D_E_L_E_T_ = '' AND SF2.F2_FILIAL = C5_FILIAL " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SE1")+" SE1 ON SF2.F2_DOC = SE1.E1_NUM AND SF2.F2_SERIE = SE1.E1_PREFIXO AND E1_CLIENTE=F2_CLIENTE AND E1_LOJA=F2_LOJA AND E1_TIPO='NF ' AND  SE1.D_E_L_E_T_ = ' ' AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI AND SA1.D_E_L_E_T_ = ' ' AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CN9")+" CN9 ON CN9_NUMERO = C5_MDCONTR AND CN9.D_E_L_E_T_ = '' AND CN9.CN9_SITUAC <> '10' AND CN9.CN9_SITUAC <> '09' AND CN9.CN9_FILIAL = '" + xFilial("CN9") + "' " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CND")+" CND ON C5_MDNUMED = CND_NUMMED AND CND_REVISA = CN9_REVISA AND CND.D_E_L_E_T_ = '' " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_CUSTO = (CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1 ELSE C5_MDCONTR END)  AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"
cQuery += " WHERE SC5.D_E_L_E_T_ = ' ' " + CRLF
//cQuery += " AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' " + CRLF
If Substr(cTipoEm,1,1) == "P"
	If !Empty(dDataI)
		cQuery += " AND SC5.C5_EMISSAO >= '"+DTOS(dDataI)+"'" + CRLF
	EndIf
	If !Empty(dDataF)
		cQuery += " AND SC5.C5_EMISSAO <= '"+DTOS(dDataF)+"'" + CRLF
	EndIf
Else          
	If !Empty(dDataI)
		cQuery += " AND SF2.F2_EMISSAO >= '"+DTOS(dDataI)+"'" + CRLF
	EndIf
	If !Empty(dDataF)
		cQuery += " AND SF2.F2_EMISSAO <= '"+DTOS(dDataF)+"'" + CRLF
	EndIf
EndIf

// NDC
cQuery += " UNION ALL"+CRLF

cQuery += " SELECT A1_NOME,E1_CLIENTE AS C5_CLIENTE,E1_LOJA AS C5_LOJACLI,CTT_DESC01,CN9_XXNRBK,'' AS C5_XXCOMPM,E1_XXMED AS C5_MDNUMED,'' AS C5_MDPLANI,'' AS C5_NUM,E1_EMISSAO AS C5_EMISSAO,0 AS CND_VLPREV,'' AS C5_LIBEROK,'' AS C5_XXULIB,'' AS C5_XXDLIB,'' AS F2_DOC,E1_EMISSAO AS F2_EMISSAO,'' AS F2_USERLGI,E1_VALOR AS F2_VALBRUT,E1_VENCREA,E1_BAIXA,E1_SALDO,0 AS C5RECNO,0 AS F2RECNO, SE1.R_E_C_N_O_ AS E1RECNO," + CRLF
cQuery += "    E1_XXCUSTO AS XX_CONTRAT," + CRLF
cQuery += "    0 AS XX_VALPED," + CRLF
cQuery += "    E1_VALOR AS XX_VALLIQ," + CRLF
cQuery += "    (SE1.E1_IRRF + SE1.E1_INSS + SE1.E1_PIS + SE1.E1_COFINS + SE1.E1_CSLL + SE1.E1_ISS) AS XX_IMPOST," + CRLF
cQuery += "    (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = E1_PREFIXO AND E5_NUMERO = E1_NUM  AND E5_TIPO = 'NDC' AND  E5_CLIFOR = E1_CLIENTE AND E5_LOJA = E1_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "    AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = ' ') AS XX_E5DESC, " + CRLF
cQuery += "    (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = E1_PREFIXO AND E5_NUMERO = E1_NUM  AND E5_TIPO = 'NDC' AND  E5_CLIFOR = E1_CLIENTE AND E5_LOJA = E1_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "    AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = ' ') AS XX_E5MULTA ," + CRLF
cQuery += "    E1_NUM AS XX_NDC" + CRLF
cQuery += "  FROM "+RETSQLNAME("SE1")+" SE1" + CRLF
cQuery += "  LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA AND SA1.D_E_L_E_T_ = ' ' AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' " + CRLF
cQuery += "  LEFT JOIN "+RETSQLNAME("CN9")+" CN9 ON CN9_NUMERO = E1_XXCUSTO AND CN9.D_E_L_E_T_ = '' AND CN9.CN9_SITUAC <> '10' AND CN9.CN9_SITUAC <> '09' AND CN9.CN9_FILIAL = '"+xFilial("CN9")+"' " + CRLF
cQuery += "  LEFT JOIN "+RETSQLNAME("CND")+" CND ON E1_XXMED = CND_NUMMED AND E1_XXREV = CN9_REVISA AND CND.D_E_L_E_T_ = ''" + CRLF
cQuery += "  LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_CUSTO = E1_XXCUSTO AND CTT_FILIAL = '"+xFilial("CTT")+"' AND CTT.D_E_L_E_T_ = ' ' " + CRLF
cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' AND " + CRLF
cQuery += "    SE1.E1_TIPO = 'NDC'" + CRLF
cQuery += "   AND SE1.E1_EMISSAO >= '"+DTOS(dDataI)+"'" + CRLF
cQuery += "   AND SE1.E1_EMISSAO <= '"+DTOS(dDataF)+"'" + CRLF
 
If Substr(cTipoEm,1,1) == "P"
	cQuery += " ORDER BY C5_NUM" + CRLF
Else          
	cQuery += " ORDER BY F2_DOC" + CRLF
EndIf

u_LogMemo("BKFINR26.SQL",cQuery)

cAliasQry := "TMPR26" //GetNextAlias()

//TCQUERY cQuery NEW ALIAS "TMPR26"

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
TCSETFIELD(cAliasQry,"C5_EMISSAO","D", 8,0)
TCSETFIELD(cAliasQry,"F2_EMISSAO","D", 8,0)
TCSETFIELD(cAliasQry,"E1_VENCREA","D", 8,0)
TCSETFIELD(cAliasQry,"E1_BAIXA","D", 8,0)
TCSETFIELD(cAliasQry,"C5_XXDLIB","D", 8,0)
ProcRegua((cAliasQry)->(LastRec()))

nCont := 0

dbSelectArea("CN9")
dbSetOrder(1)

dbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())
DO WHILE (cAliasQry)->(!EOF())
    nCont++
	IncProc("Processando consulta...")

	cBanco   := ""
	cAgencia := ""
	cConta   := ""
	nSaldo   := 0
	aBcoRec  := {}

	SF2->(dbGoTo((cAliasQry)->F2RECNO))
	If (cAliasQry)->E1RECNO > 0
		SE1->(dbGoTo((cAliasQry)->E1RECNO))
		SF2->(dbGoTo((cAliasQry)->F2RECNO))
		nSaldo := U_SaldoSe1(dDataBase)

		// Posiciona nos Bancos
		SE1->(dbGoTo((cAliasQry)->E1RECNO))
		aBcoRec := BcoSe5()
		dbSelectArea(cAliasQry)
	EndIf

	If Substr(cSaldo,1,1) == "S" .AND. ABS(nSaldo) <= 0.01
		dbSelectArea(cAliasQry)
		dbSkip()
		Loop
	EndIf

	dbSelectArea(cAliasTrb)
	Reclock(cAliasTrb,.T.)
	For nF := 1 To Len(aFields)
		If Len(aFields[nF]) > 2 .AND. !Empty(aFields[nF,3])
            If (cAliasQry)->(FieldPos(aFields[nF,3])) > 0
			    xCampo := &(cAliasQry+"->"+aFields[nF,3])
			Else
				Loop
            EndIf
		Else
			xCampo := &(cAliasQry+"->"+aFields[nF,2])
		EndIf

		If aFields[nF,2] = "E1_SALDO"

			/*

			Calculo antigo (estแ correto tamb้m !!!)
			nAbatim:= 0
			nSaldo := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZA,"R",SE1->E1_CLIENTE,1,SE1->E1_VENCREA,dDataBase,SE1->E1_LOJA,,0,1)
 					//SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZA,"R",SE1->E1_CLIENTE,1,SE1->E1_VENCREA,dDataBase,SE1->E1_LOJA,,If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0), MVX_par17)

			nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
			//	nAbatim := IIF(SF2->F2_RECISS = '1',SE1->E1_ISS,0)+SE1->E1_IRRF+SE1->E1_INSS+SE1->E1_PIS+SE1->E1_COFINS+SE1->E1_CSLL

			If STR(nSaldo,17,2) == STR(nAbatim,17,2)
				nSaldo := 0
			Else
				nSaldo-= nAbatim
				If nSaldo < 0
					nSaldo := 0
				EndIf
			Endif
			*/
			xCampo := nSaldo

		ElseIf aFields[nF,2] = "F2_USERLGI" .AND. !EMPTY((cAliasQry)->F2RECNO)
			SF2->(dbGoTo((cAliasQry)->F2RECNO))
			xCampo := SF2->(FWLeUserlg("F2_USERLGI",1))
		ElseIf aFields[nF,2] = "C5_USERLGA" //.AND. (cAliasQry)->C5_LIBEROK = 'S'
			SC5->(dbGoTo((cAliasQry)->C5RECNO))
			xCampo := SF2->(FWLeUserlg("C5_USERLGA",1))

		ElseIf aFields[nF,2] = "CN9_XXNRBK"
			If Empty(xCampo)
				If CN9->(dbSeek(xFilial("CN9")+(cAliasQry)->XX_CONTRAT))
					Do While CN9->CN9_NUMERO == (cAliasQry)->XX_CONTRAT
						xCampo := CN9->CN9_XXNRBK
						CN9->(dbSkip())
					EndDo
				EndIf
			EndIf
		ElseIf aFields[nF,2] = "E5_BANCO"
			xCampo := cBanco
		ElseIf aFields[nF,2] = "E5_AGENCIA"
			xCampo := cAgencia
		ElseIf aFields[nF,2] = "E5_CONTA"
			xCampo := cConta
		ElseIf aFields[nF,2] = "E5_VLDESCO"
			xCampo := (cAliasQry)->XX_E5DESC - (cAliasQry)->XX_E5MULTA
		EndIf

		&(cAliasTrb+"->"+aFields[nF,1]) :=  xCampo
	Next


	If cOpcBco == "1"
		nTotBx := 0
		aBcos  := {}
		aSort(aBcoRec,,,{|x,y| x[4]>y[4]})
		For nF := 1 To Len(aBcoRec)
			If nF <= nMaxBco
				If aBcoRec[nF,1] == "CX1"
					nB := nMaxBco
					&(cAliasTrb+"->XX_VLB"+STRZERO(nB,2)) += aBcoRec[nF,4]
				ElseIf aBcoRec[nF,1] == "999"
					nB := (nMaxBco - 1)
					&(cAliasTrb+"->XX_VLB"+STRZERO(nB,2)) += aBcoRec[nF,4]
				Else
					nB := aScan(aBcos,{ |x| x == aBcoRec[nF,1]+aBcoRec[nF,2]+aBcoRec[nF,3]})
					If nB == 0
						aAdd(aBcos,aBcoRec[nF,1]+aBcoRec[nF,2]+aBcoRec[nF,3])
						nB := Len(aBcos)
					EndIf
					If nB <= (nMaxBco - 2)
						cNomeBco:= ALLTRIM(Posicione("SA6",1,xFilial("SA6")+aBcoRec[nF,1]+aBcoRec[nF,2]+aBcoRec[nF,3],"A6_NOME"))
						&(cAliasTrb+"->XX_BCO"+STRZERO(nB,2)) := Trim(aBcoRec[nF,1])+"/"+Trim(aBcoRec[nF,2])+"/"+Trim(aBcoRec[nF,3])
						&(cAliasTrb+"->XX_NBC"+STRZERO(nB,2)) := cNomeBco
						&(cAliasTrb+"->XX_VLB"+STRZERO(nB,2)) += aBcoRec[nF,4]
					EndIf
				EndIf
			EndIf
			nTotBx += aBcoRec[nF,4]
		Next
		&(cAliasTrb+"->XX_TOTBX") := nTotBx

		/*
		nTotBx := 0
		For nF := 1 To Len(aBcoRec)
			If nF <= nMaxBco
				cNomeBco:= ALLTRIM(Posicione("SA6",1,xFilial("SA6")+aBcoRec[nF,1]+aBcoRec[nF,2]+aBcoRec[nF,3],"A6_NOME"))
				&(cAliasTrb+"->XX_BCO"+STRZERO(nF,2)) := Trim(aBcoRec[nF,1])+"/"+Trim(aBcoRec[nF,2])+"/"+Trim(aBcoRec[nF,3])
				&(cAliasTrb+"->XX_NBC"+STRZERO(nF,2)) := cNomeBco
				&(cAliasTrb+"->XX_VLB"+STRZERO(nF,2)) := aBcoRec[nF,4]
			EndIf
			nTotBx += aBcoRec[nF,4]
		Next
		&(cAliasTrb+"->XX_TOTBX") := nTotBx
		*/
	Else

		For nF := 1 To Len(aBcoRec)
			nB := aScan(aBcos,{ |x| x == aBcoRec[nF,1]+aBcoRec[nF,2]+aBcoRec[nF,3]})
			If nB == 0
				If Len(aBcos) < nMaxBco
					aAdd(aBcos,aBcoRec[nF,1]+aBcoRec[nF,2]+aBcoRec[nF,3])
				EndIf
				nB := Len(aBcos)
				If nB < 30
					cNomeBco:= ALLTRIM(Posicione("SA6",1,xFilial("SA6")+aBcoRec[nF,1]+aBcoRec[nF,2]+aBcoRec[nF,3],"A6_NOME"))
					aCabs[nB+nIniBc] := Trim(aBcoRec[nF,1])+"/"+Trim(aBcoRec[nF,2])+"/"+Trim(aBcoRec[nF,3])+" "+cNomeBco
				Else
					aCabs[nB+nIniBc] := "Outros"
				EndIf
			EndIf 
			&(cAliasTrb+"->"+aFields[nB+nIniBc,1]) := aBcoRec[nF,4]
		Next

	EndIf


	(cAliasTrb)->(MsUnLock())
		
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbSkip())
ENDDO

(cAliasQry)->(dbCloseArea())

dbSelectArea(cAliasTrb)
dbGoTop()

Return



// Buscar Banco, Agencia e Conta

Static Function BcoSe5()
Local cSeq		:= ""
Local nValrec	:= 0
Local aBcoRec	:= {}
Local nPosBco	:= 0
Local cBanco	:= ""
Local cAgencia	:= ""
Local cConta	:= ""

dbSelectArea("SE5")
dbSetOrder(7)
		
If dbSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA))
	While !SE5->(Eof()).AND. ;
		SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO) == ;
		xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
			
		*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		*ณ Verifica se NCC de mesmo numero pertence a outro cliente		ณ
		*ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If SE5->E5_CLIFOR+SE5->E5_LOJA != SE1->(E1_CLIENTE+E1_LOJA)
		SE5->( dbSkip() )
			Loop
		Endif

		If	(SE5->E5_RECPAG == "R" .AND. SE5->E5_TIPODOC == "ES") .OR. ;
			(SE5->E5_RECPAG == "P" .AND. SE5->E5_TIPODOC != "ES" .AND. ;
			!(SE5->E5_TIPO $ MVRECANT+"/"+MV_CRNEG))
			SE5->(dbSkip())
			Loop
		Endif
			
		cSeq   := SE5->E5_SEQ
		    
		While !SE5->(Eof()) .AND. ;
			SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ) == ;
			xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)+cSeq
					
	        //Movimento de inclusใo do RA
			If SE5->E5_TIPODOC == "RA"
				SE5->(dbSkip())
				Loop
			Endif

			IF SE5->E5_SITUACAO == "C" //.OR. ;
				//SE5->E5_TIPODOC == "E2"
				//SE5->E5_TIPODOC == "ES" .OR. ;
				SE5->(dbSkip())
				Loop
			Endif
				
	        /*
			IF SE5->E5_SITUACAO == "C" .OR. ;
				SE5->E5_TIPODOC == "ES" .OR. ;
				SE5->E5_TIPODOC == "E2"
				nSituaca := 2
			Else
				If SE5->E5_TIPODOC == "TR"
					nSituaca := 3
				Else
					nSituaca := 1
				Endif	
			Endif
            */
                
			If TemBxCanc(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)
				SE5->(dbSkip())
				Loop
			Endif
                
			//nCorrec	:= 0
			//nJuros	:= 0
			//nMulta	:= 0
			//nDescont := 0
			nValRec	:= 0
			//cMotivo	:= ""
	
			If SE5->E5_TIPODOC $ "VLüBAüV2üCP#ES#DB#LJ" //+"CMüC2|VM" + "DCüD2" + "MTüM2" + "JRüJ2"
				If SE5->E5_TIPODOC == "ES"
					nValRec	 := -SE5->E5_VALOR // + SE5->E5_VLDESCO //-E5_VLJUROS-E5_VLMULTA-E5_VLCORRE+E5_VLDESCO)
				Else
					nValRec	 := SE5->E5_VALOR //- SE5->E5_VLDESCO //-E5_VLJUROS-E5_VLMULTA-E5_VLCORRE+E5_VLDESCO)
				EndIf
				cBanco	 := SE5->E5_BANCO
				cAgencia := SE5->E5_AGENCIA
				cConta   := SE5->E5_CONTA

				nPosBco  := aScan(aBcoRec,{ |x| x[1]+x[2]+x[3] == cBanco+cAgencia+cConta})
				If nPosBco > 0
					aBcoRec[nPosBco,4] += nValRec
				Else
					aAdd(aBcoRec,{cBanco,cAgencia,cConta,nValRec})
				EndIf 
				//cMotivo	:= SE5->E5_MOTBX
				//If SE5->E5_MOTBX == "CMP"
				//	nJuros := SE5->E5_VLJUROS
				//	nDescont := SE5->E5_VLDESCO
				//Endif
			Endif
                
			SE5->( dbSkip() )
			dbSelectArea("SE5")
		Enddo
	Enddo
Endif
Return aBcoRec

// salto Contas a Receber
// BKFINR26/BKFINR29
User Function SaldoSe1(dDtBase)
Local dDataReaj 	
Local dOldData		:= dDataBase

Local nSaldo		:= 0
Local nDecs			:= 2		// Casas Decimais era Msdecimais(mv_par15)
Local nValPcc	  	:= 0
Local nRecSA1		:= 0
Local cSeq			:= ""
Local nTamSeq		:= TamSX3("E5_SEQ")[1]
Local cMvDesFin		:= SuperGetMV("MV_DESCFIN",,"I")
Local lTemGem		:= ExistTemplate("GEMDESCTO") .And. HasTemplate("LOT")
Local nDescont		:= 0
Local cFilNat 		:= SE1->E1_NATUREZ
Local lExistAba		:= .F. // Verifica se existem tํtulos de abatimento
Local cTipoIn		:= ""
Local nPos			:= 0
Local aTitImp		:= {}
Local nBx			:= 0


Static aAbatBaixa 	:= {}
Static __lBQ10925

Private cMVBR10925	:= SuperGetMv("MV_BR10925", ,"2")
Private xMV_PAR20	:= 1		// Considera Data Base
Private xmv_par15	:= 1		// Qual Moeda
Private xmv_par17	:= 1		// Reajuste pelo vecto
Private xmv_par36	:= dDtBase	// Data Base
Private xmv_par37	:= 1		// Compoe Saldo por: Data da Baixa, Credito ou DtDigit
Private xmv_par39	:= 1		// Compoe Saldo por ?
Private xmv_par38	:= 1		// Tit. Emissao Futura
Private xmv_par33	:= 2		// Abatimentos  - Lista/Nao Lista/Despreza


// ----> Inicializa็ใo de variแveis

__lBQ10925		:= SuperGetMV("MV_BQ10925",,"2") == "1"

//Acerta a database de acordo com o parametro
If xmv_par20 == 1    // Considera Data Base
	dBaixa := dDataBase := xmv_par36
Else
	If dDataBase < xMV_PAR36
		dBaixa := dDataBase := xmv_par36
	EndIf
Endif

// <---- Inicializa็ใo de variแveis


// Verifica se existe a taxa na data do vencimento do titulo, se nao existir, utiliza a taxa da database
If SE1->E1_VENCREA < dDataBase
	If xmv_par17 == 2 .And. RecMoeda(SE1->E1_VENCREA,cMoeda) > 0
		dDataReaj := SE1->E1_VENCREA
	Else
		dDataReaj := dDataBase
	EndIf
Else
	dDataReaj := dDataBase
EndIf

Dbselectarea("SE5")
DbSetorder(7) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
MSSeek(xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+ SE1->E1_PARCELA + SE1->E1_TIPO +SE1->E1_CLIENTE )                                                                                 
If xMV_PAR20 == 1	// Considera Data Base
				
	nSaldo := SaldoTit( SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, "R", SE1->E1_CLIENTE, xmv_par15, dDataReaj,;
						xMV_PAR36, SE1->E1_LOJA,	xFilial('SE5') , Iif(xmv_par39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0),;
						xmv_par37, .F., __oTBxCanc )
									
	/*
	//Verifica se existem compensa็๕es em outras filiais para descontar do saldo, pois a SaldoTit() somente
	//verifica as movimenta็๕es da filial corrente. Nao deve processar quando existe somente uma filial.
	If lVerCmpFil .and. ( mv_par41 == 1 ) .and. ( nSaldo != SE1->E1_SALDO ) .and.;
						 aScan( aRecSE1Cmp , { |x| x[1] == SE1->( R_E_C_N_O_ )} ) > 0
		proclogatu("INICIO",STR0085) //"PESQUISA DE COMPENSAวรO DE MULTI-FILIIAS"
		nSaldo -= Round(NoRound( xMoeda( FRVlCompFil("R",SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,xmv_par37,aFiliais,cFilQry,lAS400),;
						SE1->E1_MOEDA,xmv_par15,dDataReaj,ndecs+1,Iif(xmv_par39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA) ),0 ) ),;
						nDecs+1),nDecs)
		proclogatu("FIM",STR0085)//Log pesquisa de compensa็ใo
	EndIf
	*/			


	//Subtrai decrescimo para recompor o saldo na data escolhida
	//Converte o decrescimo e acrescimo para a moeda do nsaldo
	If SE1->E1_DECRESC > 0
		If  xmv_par15 = SE1->E1_MOEDA .and. Str(SE1->E1_VALOR,17,2) == Str(nSaldo,17,2)
			nSaldo -= SE1->E1_DECRESC
		ElseIf Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,xmv_par15,dDataReaj,nDecs+1,Iif(xmv_par39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),nDecs+1),nDecs) == nSaldo
			nSaldo := Round(NoRound(xMoeda(SE1->E1_VALOR-SE1->E1_DECRESC,SE1->E1_MOEDA,xmv_par15,dDataReaj,nDecs+1,Iif(xmv_par39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),nDecs+1),nDecs)
		Endif
	EndIf

	// Soma Acrescimo para recompor o saldo na data escolhida.
	If SE1->E1_ACRESC > 0
		If  xmv_par15 = SE1->E1_MOEDA .and. Str(SE1->E1_VALOR,17,2) == Str(nSaldo,17,2)
			nSaldo += SE1->E1_ACRESC
		ElseIf Round(NoRound(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,xmv_par15,dDataReaj,nDecs+1,Iif(xmv_par39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),nDecs+1),nDecs) == nSaldo
			nSaldo := Round(NoRound(xMoeda(SE1->E1_VALOR+SE1->E1_ACRESC,SE1->E1_MOEDA,xmv_par15,dDataReaj,nDecs+1,Iif(xmv_par39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0)),nDecs+1),nDecs)
		EndIf
	EndIf

	//Se abatimento verifico a data da baixa.
	//Por nao possuirem movimento de baixa no SE5, a saldotit retorna
	//sempre saldo em aberto quando xmv_par33 = 1 (Abatimentos = Lista)
	If SE1->E1_TIPO $ MVABATIM	+"/"+MVFUABT .and. ;
		((SE1->E1_BAIXA <= dDataBase .and. !Empty(SE1->E1_BAIXA)) .or. ;
		 (SE1->E1_MOVIMEN <= dDataBase .and. !Empty(SE1->E1_MOVIMEN))	) .and.;
		 SE1->E1_SALDO == 0
		nSaldo := 0
		If !Empty(SE1->E1_TITPAI)
			aAdd( aAbatBaixa , { SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) , SE1->E1_TITPAI } )
		Else
			cMTitPai := FTITPAI()
			aAdd( aAbatBaixa , { SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) , cMTitPai } )
		EndIf

		aAdd( aAbatBaixa , { SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) , SE1->E1_TITPAI } )
	EndIf

	//certifica-se de que estแ posicionado no cliente correto, para que seja deduzido corretamente o IR baixado do saldo do tํtulo.
	If AllTrim(SA1->A1_COD)+AllTrim(SA1->A1_LOJA) <> AllTrim(SE1->E1_CLIENTE)+AllTrim(SE1->E1_LOJA) .and. cMVBR10925 == "1" .And. __lBQ10925 
		nRecSA1 := SA1->(Recno())															
		If !SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)) 																	 
			SA1->(DbGoto(nRecSA1))
			nRecSA1 := 0						
		EndIf
	ElseIf cMVBR10925 == "1" .And. __lBQ10925
		nRecSA1 := SA1->(Recno())									
	EndIf

	If cPaisLoc == "BRA"
		If (( cMVBR10925 == "1" .and. SE1->E1_EMISSAO <= xMV_PAR36 .and. !(SE1->E1_TIPO $ "PIS/COF/CSL").and. !(SE1->E1_TIPO $ MVABATIM) ) ;
			.AND. ( "S" $ (SA1->(A1_RECPIS+A1_RECCOFI+A1_RECCSLL) ) ) ) .Or. (SA1->A1_IRBAX == '1' .And. SE1->E1_EMISSAO <= xMV_PAR36 .and. ;
			!(SE1->E1_TIPO $ MVIRF).and. !(SE1->E1_TIPO $ MVABATIM) .AND. ( (SA1->(A1_RECIRRF) $ "1 " ) .And. SA1->A1_TPESSOA == 'EP' ) )
	
			nValPcc := SumBxPCC(SE1->E1_PREFIXO,SE1->E1_NUM,dBaixa,SE1->E1_CLIENTE,SE1->E1_LOJA,xmv_par15)
			nSaldo -= nValPcc
								
			//tratamento para emissใo correta do saldo do tํtulo, quando o PCC+IR estiver na baixa e for realizado baixa parcial.
			If nRecSA1 > 0
				SE5->(DbSetOrder(7))
				while  SE5->(!EOF()) .And. SE5->(MsSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)+cSeq));
					.And. nSaldo <> SE1->E1_SALDO .And. AllTrim(SA1->A1_IRBAX) = "1" .And. SE5->E5_VRETIRF > 0			
					nSaldo	:= Iif(SE5->E5_DATA <= xmv_par36,  (nSaldo - SE5->E5_VRETIRF), nSaldo)
					cSeq	:= ALLTRIM(STR(VAL(SE5->E5_SEQ)+1))
					cSeq	:= Replicate("0", nTamSeq - Len(Alltrim(Str(Val(cSeq))))) + cSeq
				EndDo										
			Endif					
		EndIf
	EndIf


	nRecSA1 := 0				
	If SE1->E1_TIPO == "RA "   //somente para titulos ref adiantamento verifica se nao houve cancelamento da baixa posterior data base (xmv_par36)
		nSaldo -= F130TipoBA()
	EndIf
Else
	nSaldo := xMoeda((SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE),SE1->E1_MOEDA,xmv_par15,dDataReaj,ndecs+1,Iif(xMV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0))
Endif

/*
// Se titulo do Template GEM
If __lTempLOT .And.  !Empty(SE1->E1_NCONTR)
	nGem := CMDtPrc(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_VENCREA,SE1->E1_VENCREA)[2]
	If SE1->E1_VALOR==SE1->E1_SALDO
		nSaldo += nGem
	EndIf
EndIf
*/

//Caso exista desconto financeiro (cadastrado na inclusao do titulo),
//subtrai do valor principal.
If !(!Empty( SE1->E1_BAIXA ) .AND. SE1->E1_BAIXA < dDatabase) .Or. cMvDesFin == "P" 
	nDescont := FaDescFin("SE1",dBaixa,SE1->E1_SALDO,1,.T.,lTemGem)
	If xMv_par15 > 1
		If SE1->E1_MOEDA == xMv_par15
			nDescont := xMoeda((nDescont),1,xMv_par15,dDataReaj,ndecs+1,Iif(xMV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0))
		Else
			nDescont := xMoeda((nDescont),SE1->E1_MOEDA,xmv_par15,dDataReaj,ndecs+1,Iif(xMV_PAR39==2,Iif(!Empty(SE1->E1_TXMOEDA),SE1->E1_TXMOEDA,RecMoeda(SE1->E1_EMISSAO,SE1->E1_MOEDA)),0))
		EndIf
	EndIf
	If nDescont > 0
		nSaldo := nSaldo - nDescont
	Endif
EndIf

If ! SE1->E1_TIPO $ MVABATIM	+"/"+MVFUABT
	If ! (SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG) .And. ;
			!( xMV_PAR20 == 2 .And. nSaldo == 0 )  	// deve olhar abatimento pois e zerado o saldo na liquidacao final do titulo

		cFilNat		:= SE1->E1_NATUREZ
		lExistAba	:= HashNatur(@cTipoIn)
					
		//Busca as informa็๕es para alimentar a array aTitImp utilizando a fun็ใo F130RETIMP
		If lExistAba
			If __aTtImp == Nil
				__aTtImp := {}
			EndIf

			If ( nPos := (aScan(__aTtImp, {|x| x[1] == cFilNat}))) == 0
				aTitImp		:= F130RETIMP(cFilNat)
				aAdd(__aTtImp, {cFilNat, aTitImp} )
			Else
				aTitImp := aClone(__aTtImp[nPos,2])
			EndIf
		Else				        
			aTitImp:= {}
		EndIf
					
		If ((nPos := (aScan(aTitImp, {|x| x[1] <> SE1->E1_TIPO }))) > 0 .and. aTitImp[nPos][2]) .OR.;
			aScan(aAbatBaixa, {|x| ALLTRIM(x[2])==ALLTRIM(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)) }) > 0

			//Quando considerar Titulos com emissao futura, eh necessario
			//colocar-se a database para o futuro de forma que a Somaabat()
			//considere os titulos de abatimento
			If xmv_par38 == 1
				//dOldData := dDataBase
				dDataBase := CTOD("31/12/40")
			Endif

			// Somente verifica abatimentos se existirem titulos deste tipo para o cliente
			If lExistAba
				nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",xmv_par15,dDataReaj,SE1->E1_CLIENTE,SE1->E1_LOJA)
			Else
				nAbatim := 0
			EndIf

			If xmv_par38 == 1
   				dDataBase := dOldData
			Endif

			If xmv_par33 != 1  //somente deve considerar abatimento no saldo se nao listar
				If STR(nSaldo,17,2) == STR(nAbatim,17,2)
					nSaldo := 0
				ElseIf xmv_par33 == 2  //Se nao listar ele diminui do saldo								
					nSaldo-= nAbatim
				Endif
			Else
			    // Subtrai o Abatimento caso o mesmo jแ tenho sido baixado ou nใo esteja listado no relatorios
			  	nBx := aScan( aAbatBaixa, {|x| x[2]= SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) } )
			  	If (SE1->E1_BAIXA <= dDataBase .and. !Empty(SE1->E1_BAIXA) .and. nBx>0)
			  		aDel( aAbatBaixa , nBx)
			  		aSize(aAbatBaixa, Len(aAbatBaixa)-1)
					nSaldo -= nAbatim
				EndIf
			EndIf
		Endif
	Endif
Endif

nSaldo:=Round(NoRound(nSaldo,3),2)

//__oHash:Clean()
dDataBase := dOldData

Return nSaldo



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF130TipoBAบAutor  ณMicrosiga           บ Data ณ  13/08/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para buscar na SE5 quando titulo eh tipo RA para    บฑฑ
ฑฑบ          ณ verificar a data de cancelamento que sera gravado no       บฑฑ
ฑฑบ          ณ campo E5_HIST entre ###[AAAAMMDD]### a fim de compor o     บฑฑ
ฑฑบ          ณ saldo adequadamente                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F130TipoBA()
	Local aSavArea		:= GetArea()
	Local nPosDtCanc	:= 0
	Local nValor		:= 0
	Local cQuery		:= ''
	Local cTipoBA		:= '' 

	If !Empty( __oTipoBa )
		If Empty( __oTipoBa:cBaseQuery )

			cQuery += "SELECT E5_DATA, E5_HISTOR, E5_VALOR "
			cQuery += " FROM " + RetSqlName("SE5") + " SE5 "
			cQuery += " WHERE SE5.E5_FILIAL = ? "
			cQuery += " AND SE5.E5_PREFIXO = ? "
			cQuery += " AND SE5.E5_NUMERO = ? "
			cQuery += " AND SE5.E5_PARCELA = ? "
			cQuery += " AND SE5.E5_TIPO = ? "
			cQuery += " AND SE5.E5_CLIFOR = ? "
			cQuery += " AND SE5.E5_LOJA = ? "
			cQuery += " AND SE5.E5_DATA <= ? "
			cQuery += " AND SE5.E5_TIPODOC = 'BA' "
			cQuery += " AND SE5.E5_SITUACA = 'C' "
			cQuery += " AND SE5.E5_HISTOR LIKE '%###%' "
			cQuery += " AND SE5.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			__oTipoBa:SetQuery( cQuery )
		EndIf

		__oTipoBa:SetString( 1, xFilial("SE5")	)
		__oTipoBa:SetString( 2, SE1->E1_PREFIXO	)
		__oTipoBa:SetString( 3, SE1->E1_NUM		)
		__oTipoBa:SetString( 4, SE1->E1_PARCELA	)
		__oTipoBa:SetString( 5, SE1->E1_TIPO	)
		__oTipoBa:SetString( 6, SE1->E1_CLIENTE	)
		__oTipoBa:SetString( 7, SE1->E1_LOJA	)
		__oTipoBa:SetDate(	8, mv_par36			)

		cQuery := __oTipoBa:GetFixQuery()
		cTipoBA := MpSysOpenQuery( cQuery )

		While ( cTipoBA )->(!EOF()) 
			nPosDtCanc := At( "###[", ( cTipoBA )->E5_HISTOR ) 
			If StoD( Subs( ( cTipoBA )->E5_HISTOR, nPosDtCanc + 4, 8 ) ) > xMV_PAR36
				nValor := ( cTipoBA )->E5_VALOR
				Exit
			EndIf
			( cTipoBA )->(dbSkip())
		EndDo

		( cTipoBA )->( dbCloseArea() )
	EndIf

	RestArea(aSavArea)

Return nValor


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHashNatur  ณ Ronaldo Tapia             บ Data ณ  05/04/16   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Faz querypara verificar se existe abatimento para determi- บฑฑ
ฑฑบ          ณ cliente                                                   .บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function HashNatur(cTipoIn)

Local cQuery 
Local cAreaAtu // := Alias()//- salvo o alias aberto 
Local lTemCli := .F.
Local lFlag

Static __oHash	:= tHashMap():New() //Cria o Objeto do Hash Map

Default cTipoIn := ""

lTemCli := __oHash:Get( SE1->(E1_CLIENTE+E1_LOJA) , lFlag )

If !lTemCli
	cAreaAtu := Alias()//- salvo o alias aberto 
	cQuery := " SELECT Max(R_E_C_N_O_) AS RECNO"
	cQuery += "   FROM " + RetSqlName("SE1")+" SE1 "
	cQuery += "  WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"'"
	cQuery += "    AND SE1.E1_CLIENTE = '"+SE1->E1_CLIENTE+"'"
	cQuery += "    AND SE1.E1_LOJA = '"+SE1->E1_LOJA+"'"
	cQuery += "    AND SE1.E1_TIPO IN "  + F130MontaIn(@cTipoIn)
	cQuery += "    AND SE1.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"HashNatur",.T.,.T.)

	If !Eof()
		lTemCli := __oHash:Set( SE1->(E1_CLIENTE+E1_LOJA) , .T. )
	Endif

	HashNatur->(dbCloseArea())		

	//- restauro o alias anterior 
	dbSelectArea(cAreaAtu)
EndIf 

Return (lTemCli)


//-------------------------------------------------------------------
/*/{Protheus.doc} F130MontaIn
Formata a expressใo para IN ou NOT IN

@author Mauricio Pequim Jr
@since 02/05/2016
@version 12.1.7
/*/
//-------------------------------------------------------------------
Static Function F130MontaIn(cTipoIn)
Local cTiposAbt	:= MVABATIM +"|"+MVFUABT
Default cTipoIn   := ""

If cTipoIn == ""
	cTipoIn	:=	StrTran(cTiposAbt,',','/')
	cTipoIn	:=	StrTran(cTipoIn,';','/')
	cTipoIn	:=	StrTran(cTipoIn,'|','/')
	cTipoIn	:=	StrTran(cTipoIn,'\','/')

	cTipoIn := Formatin(cTipoIn,"/")
Endif

Return cTipoIn


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณF040RETIMPบAutor  ณ Totvs              บ Data ณ  30/07/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua a validacao na exclusao do titulo                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function F130RETIMP(cFiltro)

Local aTitulos := {}
Local aAreaSE1	:= SE1->(GetArea())

dbSelectArea("SED")
dbSetOrder(1)
If MSSeek (xFilial("SED")+cFiltro)
	If SED->ED_CALCIRF=="S"
     	AADD(aTitulos,{MVIRABT, .T.})
 	EndIf
   	If SED->ED_CALCINS=="S"
       	AADD(aTitulos,{MVINABT,.T.})
   	EndIf
 	If SED->ED_CALCPIS=="S"
    	 AADD(aTitulos,{MVPIABT,.T.})
 	EndIf
   	If SED->ED_CALCCOF=="S"
     	AADD(aTitulos,{MVCFABT,.T.})
 	EndIf
   	If SED->ED_CALCCSL=="S"
     	AADD(aTitulos,{MVCSABT,.T.})
   	EndIf
 	If SED->ED_CALCISS=="S"
     	AADD(aTitulos,{MVISABT,.T.})
	EndIf
	//ISS Bitributado
	If SED->ED_CALCISS=="S"
     	AADD(aTitulos,{MVI2ABT,.T.})
	EndIf
EndIf

RestArea(aAreaSE1)

Return aTitulos
