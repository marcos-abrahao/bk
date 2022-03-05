#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKFINR26
BK - Planilha de Pedidos e Faturamento
v29/03/20
@Return
@author Marcos Bispo Abrahão
@since 15/03/2020 rev 25/02/2022
@version P12
/*/
//Static __oTBxCanc
//Static __oTipoBa
//Static __oHash
//Static __aTtImp


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
Private cSaldo      := "Não"

Private cOpcBco		:= "1"	// 1 - Imprime 3 bancos em 9 colunas (Banco,Nome e valor) - 2 Imprime um valor de banco por coluna, até 30 bancos

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

aAdd( aParam, { 1, "Emissão Inicial:" , dDataBase, "" 				, "", ""	, "" , 60  , .F. })
aAdd( aParam, { 1, "Emissão Final:"   , dDataBase, "" 				, "", ""	, "" , 60  , .F. })  
aAdd( aParam ,{ 2, "Emissão por"      , cTipoEm  , {"Pedido", "NF"}	, 60,'.T.'  ,.T.})
aAdd( aParam ,{ 2, "Somente com saldo", cSaldo	  ,{"Sim", "Não"}	, 60,'.T.'  ,.T.})

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
Número Medição
Número Planilha
Número da Nota Fiscal
Data Emissão da Nota Fiscal
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
aAdd(aFields,{"XX_DESC01" ,"CTT_DESC01","","Descrição do Contrato"})
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
aAdd(aFields,{"XX_SERIE"  ,"F2_SERIE","","Série NF"})
aAdd(aFields,{"XX_NF"     ,"F2_DOC","","Nota Fiscal numero"})
aAdd(aFields,{"XX_NDC"    ,"E1_NUM","XX_NDC","Nota Debito número"})
aAdd(aFields,{"XX_DATANF" ,"F2_EMISSAO","","Data Emissao NF/ND"})
aAdd(aFields,{"XX_EMISSOR","F2_USERLGI","","Responsável emissão NF"})
aAdd(aFields,{"XX_VALNF"  ,"F2_VALBRUT","","Vl Bruto NF"})
aAdd(aFields,{"XX_VRETC"  ,"F2_XXVRETC","","Retenção Contratual"})
aAdd(aFields,{"XX_VCVIN"  ,"F2_XXVCVIN","","Conta Vinculada"})

aAdd(aFields,{"XX_VALLIQ" ,"","XX_VALLIQ","Vl Liq.NF",cPict,"N",18,2})
aAdd(aFields,{"XX_E5DESC" ,"E5_VLDESCO","XX_E5DESC"  ,"Desconto - Imp. Cli não reteve"})
aAdd(aFields,{"XX_VENC"   ,"E1_VENCREA"})
aAdd(aFields,{"XX_BAIXA"  ,"E1_BAIXA"})
aAdd(aFields,{"XX_XXDTADT","E1_XXDTADT"})
If cOpcBco == "1"
	aAdd(aFields,{"XX_TOTBX" ,"","XX_TOTBX","Total Bcos",cPict,"N",18,2})
EndIf

aAdd(aFields,{"XX_SALDO"  ,"E1_SALDO",  "" ,"Saldo a Receber"})
aAdd(aFields,{"XX_SITUACA","FRV_DESCRI","" ,"Situação"})

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
//Criação da tabela temporária
//----------------------------
oTmpTb := FWTemporaryTable():New( cAliasTrb )
oTmpTb:SetFields( aDbf )
oTmpTb:Create()

/*
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
*/
Processa( {|| ProcBKR26() })

AADD(aPlans,{cAliasTrb,TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, .F. })
U_PlanXlsx(aPlans,cTitulo,cPerg, .F.,aParam)

oTmpTb:Delete()

/*
If !Empty( __oTBxCanc )
	__oTBxCanc:Destroy()
	__oTBxCanc := Nil
EndIf
If !Empty( __oTipoBa )
	__oTipoBa:Destroy()
	__oTipoBa := Nil
EndIf
*/
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
	cTitulo  := "Pedidos e Faturamento - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
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

// --> FINC040
Local lClcMultLj := ( SuperGetMv("MV_JURTIPO",,"") == "L" ) .Or. ( SuperGetMv("MV_LJINTFS", ,.F.) )
Private nJuros 	:= 0
Private nMulta 	:= 0
// <-- FINC040

Private xCampo

Procregua(5)
IncProc("Consultando o banco de dados...")

//cQuery := "SELECT "
//For nF := 1 To Len(aFields)
//	If LEN(aFields[nF]) < 3 .OR. Empty(aFields[nF,3])
//		cQuery += aFields[nF,2]+","
//	EndIf
//Next
cQuery := "SELECT "+ CRLF
cQuery += "		A1_NOME" + CRLF
cQuery += "		,C5_CLIENTE" + CRLF
cQuery += "		,C5_LOJACLI" + CRLF
cQuery += "		,CTT_DESC01" + CRLF
cQuery += "		,CN9_XXNRBK" + CRLF
cQuery += "		,C5_XXCOMPM" + CRLF
cQuery += "		,C5_MDNUMED" + CRLF
cQuery += "		,C5_MDPLANI" + CRLF
cQuery += "		,C5_NUM" + CRLF
cQuery += "		,C5_EMISSAO" + CRLF
cQuery += "		,ISNULL(CXN_VLPREV,CND_VLPREV) AS CND_VLPREV" + CRLF
cQuery += "		,C5_LIBEROK" + CRLF
cQuery += "		,C5_XXULIB" + CRLF
cQuery += "		,C5_XXDLIB" + CRLF
cQuery += "		,F2_SERIE" + CRLF
cQuery += "		,F2_DOC" + CRLF
cQuery += "		,F2_EMISSAO" + CRLF
cQuery += "		,F2_USERLGI" + CRLF
cQuery += "		,F2_VALBRUT" + CRLF
cQuery += "		,F2_XXVRETC" + CRLF
cQuery += "		,F2_XXVCVIN" + CRLF
cQuery += "		,E1_VENCREA" + CRLF
cQuery += "		,E1_BAIXA" + CRLF
cQuery += "		,E1_SALDO" + CRLF // CASE E1_SALDO WHEN 0 THEN 0 ELSE E1_SALDO - E1_XXVRETC END AS E1_SALDO
cQuery += "		,E1_XXDTADT" + CRLF
cQuery += "		,FRV_DESCRI" + CRLF
cQuery += "		,SC5.R_E_C_N_O_ AS C5RECNO" + CRLF
cQuery += "		,SF2.R_E_C_N_O_ AS F2RECNO" + CRLF
cQuery += "		,SE1.R_E_C_N_O_ AS E1RECNO" + CRLF
cQuery += "		,CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1 ELSE C5_MDCONTR END AS XX_CONTRAT" + CRLF
cQuery += "		,(SELECT SUM(C6_VALOR) FROM "+RETSQLNAME("SC6")+" SC6 WHERE SC6.C6_NUM = SC5.C5_NUM AND SC6.D_E_L_E_T_ = ' ' AND SC6.C6_FILIAL = C5_FILIAL) AS XX_VALPED" + CRLF
cQuery += "		,(SF2.F2_VALFAT - SF2.F2_VALIRRF - SF2.F2_VALINSS - SF2.F2_VALPIS - SF2.F2_VALCOFI - SF2.F2_VALCSLL - SF2.F2_VLCPM - F2_XXVRETC - F2_XXVCVIN - (CASE SF2.F2_RECISS WHEN '1' THEN SF2.F2_VALISS ELSE 0 END)) AS XX_VALLIQ" + CRLF
cQuery += "		,(SE1.E1_IRRF + SE1.E1_INSS + SE1.E1_PIS + SE1.E1_COFINS + SE1.E1_CSLL + (CASE SF2.F2_RECISS WHEN '1' THEN SE1.E1_ISS ELSE 0 END)) AS XX_IMPOST"+ CRLF
cQuery += "		,(SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "			AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = ' ') AS XX_E5DESC"+ CRLF
cQuery += "		,(SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "			AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = ' ') AS XX_E5MULTA"+ CRLF
cQuery += "		,'' AS XX_NDC" + CRLF

cQuery += " FROM "+RETSQLNAME("SC5")+" SC5" + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+" SF2" + CRLF
cQuery += " 	ON C5_NOTA = F2_DOC AND C5_SERIE = F2_SERIE" + CRLF
cQuery += "		AND SF2.D_E_L_E_T_ = '' AND SF2.F2_FILIAL = C5_FILIAL " + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("SE1")+" SE1" + CRLF 
cQuery += "		ON SF2.F2_DOC = SE1.E1_NUM AND SF2.F2_SERIE = SE1.E1_PREFIXO" + CRLF
cQuery += "		AND E1_CLIENTE=F2_CLIENTE AND E1_LOJA=F2_LOJA AND E1_TIPO='NF '" + CRLF
cQuery += "		AND SE1.D_E_L_E_T_ = ' ' AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' " + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("FRV")+" FRV" + CRLF
cQuery += " 	ON FRV.FRV_CODIGO = SE1.E1_SITUACA" + CRLF
cQuery += "		AND FRV.D_E_L_E_T_ = ' ' AND FRV.FRV_FILIAL = '" + xFilial("FRV") + "' " + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1" + CRLF
cQuery += "		ON SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI" + CRLF
cQuery += "		AND SA1.D_E_L_E_T_ = ' ' AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' " + CRLF

// Pegar a revisão do CNE de apenas um registro
cQuery += " LEFT JOIN "+RETSQLNAME("CNE")+" CNE" + CRLF
cQuery += "		ON CNE_NUMMED = C5_MDNUMED AND CNE_NUMERO = C5_MDPLANI AND CNE_PEDIDO = C5_NUM" + CRLF
cQuery += "		AND CNE_FILIAL = C5_FILIAL AND CNE.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "		AND CNE.R_E_C_N_O_ = " + CRLF
cQuery += "			(SELECT TOP 1 R_E_C_N_O_ FROM "+RETSQLNAME("CNE")+" CNE" + CRLF
cQuery += "					WHERE CNE_NUMMED = C5_MDNUMED AND CNE_NUMERO = C5_MDPLANI AND CNE_PEDIDO = C5_NUM" + CRLF
cQuery += "					      AND CNE_FILIAL = C5_FILIAL AND  CNE.D_E_L_E_T_ = ' ')"  + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CND")+" CND" + CRLF
cQuery += "		ON C5_MDNUMED = CND_NUMMED AND CND_REVISA = CNE_REVISA" + CRLF
cQuery += "		AND CND.D_E_L_E_T_ = '' AND CND.CND_FILIAL = SC5.C5_FILIAL" + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CXN")+" CXN" + CRLF
cQuery += "		ON C5_MDNUMED = CXN_NUMMED AND CXN_NUMPLA = C5_MDPLANI AND CXN_CHECK = 'T' AND CXN_REVISA = CND_REVISA" + CRLF
cQuery += "		AND CXN.CXN_FILIAL = SC5.C5_FILIAL AND CXN.D_E_L_E_T_ = '' " + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CN9")+" CN9" + CRLF
cQuery += "		ON CN9_NUMERO = C5_MDCONTR AND CN9_REVISA = CND_REVISA
cQuery += "		AND CN9.D_E_L_E_T_ = '' AND CN9.CN9_FILIAL = CND.CND_FILCTR " + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+" CTT" + CRLF
cQuery += "		ON CTT_CUSTO = (CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1 ELSE C5_MDCONTR END)" + CRLF
cQuery += "		AND CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '" + CRLF

cQuery += " WHERE SC5.D_E_L_E_T_ = ' ' " + CRLF   // AND SF2.F2_DOC='000000758'

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

cQuery += " SELECT"+ CRLF
cQuery += "		A1_NOME" + CRLF
cQuery += "		,E1_CLIENTE AS C5_CLIENTE" + CRLF
cQuery += "		,E1_LOJA AS C5_LOJACLI" + CRLF
cQuery += "		,CTT_DESC01,CN9_XXNRBK" + CRLF
cQuery += "		,'' AS C5_XXCOMPM" + CRLF
cQuery += "		,E1_XXMED AS C5_MDNUMED" + CRLF
cQuery += "		,'' AS C5_MDPLANI" + CRLF
cQuery += "		,'' AS C5_NUM" + CRLF
cQuery += "		,E1_EMISSAO AS C5_EMISSAO" + CRLF
cQuery += "		,0 AS CND_VLPREV" + CRLF
cQuery += "		,'' AS C5_LIBEROK" + CRLF
cQuery += "		,'' AS C5_XXULIB" + CRLF
cQuery += "		,'' AS C5_XXDLIB" + CRLF
cQuery += "		,'' AS F2_SERIE" + CRLF
cQuery += "		,'' AS F2_DOC,E1_EMISSAO AS F2_EMISSAO" + CRLF
cQuery += "		,'' AS F2_USERLGI" + CRLF
cQuery += "		,E1_VALOR AS F2_VALBRUT" + CRLF
cQuery += "		,E1_XXVRETC AS F2_XXVRETC"+ CRLF
cQuery += "		,0 AS F2_XXVCVIN"+ CRLF
cQuery += "		,E1_VENCREA,E1_BAIXA" + CRLF
cQuery += "		,E1_SALDO" + CRLF // CASE E1_SALDO WHEN 0 THEN 0 ELSE E1_SALDO - E1_XXVRETC END AS E1_SALDO
cQuery += "		,E1_XXDTADT" + CRLF
cQuery += "		,FRV_DESCRI" + CRLF
cQuery += "		,0 AS C5RECNO" + CRLF
cQuery += "		,0 AS F2RECNO" + CRLF
cQuery += "		,SE1.R_E_C_N_O_ AS E1RECNO" + CRLF
cQuery += "		,E1_XXCUSTO AS XX_CONTRAT" + CRLF
cQuery += "		,0 AS XX_VALPED" + CRLF
cQuery += "		,(E1_VALOR - E1_XXVRETC) AS XX_VALLIQ" + CRLF
cQuery += "		,(SE1.E1_IRRF + SE1.E1_INSS + SE1.E1_PIS + SE1.E1_COFINS + SE1.E1_CSLL + SE1.E1_ISS) AS XX_IMPOST" + CRLF
cQuery += "		,(SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = E1_PREFIXO AND E5_NUMERO = E1_NUM  AND E5_TIPO = 'NDC' AND  E5_CLIFOR = E1_CLIENTE AND E5_LOJA = E1_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "			AND E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = ' ') AS XX_E5DESC" + CRLF
cQuery += "		,(SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = E1_PREFIXO AND E5_NUMERO = E1_NUM  AND E5_TIPO = 'NDC' AND  E5_CLIFOR = E1_CLIENTE AND E5_LOJA = E1_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "			AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = ' ') AS XX_E5MULTA" + CRLF
cQuery += "		,E1_NUM AS XX_NDC" + CRLF

cQuery += "  FROM "+RETSQLNAME("SE1")+" SE1" + CRLF

cQuery += "  LEFT JOIN "+RETSQLNAME("FRV")+" FRV" + CRLF
cQuery += " 	ON FRV.FRV_CODIGO = SE1.E1_SITUACA" + CRLF
cQuery += "		AND FRV.D_E_L_E_T_ = ' ' AND FRV.FRV_FILIAL = '" + xFilial("FRV") + "' " + CRLF

cQuery += "  LEFT JOIN "+RETSQLNAME("SA1")+" SA1" + CRLF
cQuery += "		ON SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA = SE1.E1_LOJA" + CRLF
cQuery += "		AND SA1.D_E_L_E_T_ = ' ' AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' " + CRLF

cQuery += "  LEFT JOIN "+RETSQLNAME("CN9")+" CN9" + CRLF
cQuery += "		ON CN9_NUMERO = E1_XXCUSTO AND CN9_REVISA = E1_XXREV AND CN9.CN9_SITUAC <> '10' AND CN9.CN9_SITUAC <> '09'" + CRLF
cQuery += "		AND CN9.D_E_L_E_T_ = '' AND CN9.CN9_FILIAL = '"+xFilial("CN9")+"' " + CRLF

//cQuery += "  LEFT JOIN "+RETSQLNAME("CND")+" CND" + CRLF
//cQuery += "		ON E1_XXMED = CND_NUMMED AND E1_XXREV = CN9_REVISA" + CRLF
//cQuery += "		AND CND.D_E_L_E_T_ = ''" + CRLF

cQuery += "  LEFT JOIN "+RETSQLNAME("CTT")+" CTT" + CRLF
cQuery += "		ON CTT_CUSTO = E1_XXCUSTO" + CRLF
cQuery += "		AND CTT_FILIAL = '"+xFilial("CTT")+"' AND CTT.D_E_L_E_T_ = ' ' " + CRLF

cQuery += " WHERE SE1.D_E_L_E_T_ = ' '" + CRLF
cQuery += "   AND SE1.E1_TIPO = 'NDC'" + CRLF
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
TCSETFIELD(cAliasQry,"E1_XXDTADT","D", 8,0)
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
		//nSaldo := U_SaldoSe1(dDataBase)

		// --> Copiado do FINC040
		nAbatim  := 0
		nDescFin := 0
		nMultaTit:= 0
		nValAces := 0
		nJuros	 := 0  // Private
		nMulta	 := 0  // Private

		If SE1->E1_SALDO = 0
   			//dBaixa := SE1->E1_BAIXA
			nSaldo := SE1->E1_VALOR
		Else
			nSaldo := SaldoTit( SE1->E1_PREFIXO ,SE1->E1_NUM  ,SE1->E1_PARCELA ,SE1->E1_TIPO , ;
							SE1->E1_NATUREZ ,"R"           ,SE1->E1_CLIENTE , 1           , ;
							NIL             ,NIL           ,SE1->E1_LOJA    ,NIL          , ;
							If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0) )
		EndIf
		//Desconto Financeiro e Abatimento
		IF !(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)

			//Abatimento
			nAbatim	 := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,"R",SE1->E1_MOEDA,,SE1->E1_CLIENTE,SE1->E1_LOJA)
			//Desconto Financeiro
			If SE1->E1_VENCREA >= dDataBase .AND. SE1->E1_SALDO > 0
				nDescFin   := FaDescFin("SE1",dDataBase,SE1->E1_SALDO-nAbatim,SE1->E1_MOEDA)
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se o Saldo ja estiver Zero, nao calcular os juros.           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SE1->E1_SALDO > 0
				If lClcMultLj
					//*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//*³ Calcula o valor da Multa  :funcao LojxRMul :fonte Lojxrec          ³
					//*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nMultaTit := LojxRMul(,,,nSaldo,SE1->E1_ACRESC,SE1->E1_VENCREA,dDataBase,,SE1->E1_MULTA,,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,"SE1",.T.)
				EndIf
				fa070Juros(1, nSaldo)
				
				If	ExistFunc('FValAcess')
					nValAces := FValAcess(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA, SE1->E1_NATUREZ,!Empty(SE1->E1_BAIXA),,"R",SE1->E1_BAIXA,,SE1->E1_MOEDA)		
				EndIf
			Endif
		Endif
		nJuros   += nMulta

		If Empty(SE1->E1_BAIXA)
			//@ 012, 055 SAY Trans(SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE + nJuros + nValAces + nMultaTit - nAbatim - nDescFin, tm(SE1->E1_SALDO, 17, ncasas)) SIZE 50,16 OF oPanel3 PIXEL //"Saldo T¡tulo (Impostos)"
			nSaldo := SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE + nJuros + nValAces + nMultaTit - nAbatim - nDescFin
		Else	
			If SE1->E1_SALDO = 0 
				//@ 012, 055 SAY Trans(SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE + nJuros + nValAces + nMultaTit, tm(SE1->E1_SALDO, 17, ncasas)) SIZE 50,16 OF oPanel3 PIXEL //"Saldo T¡tulo (Impostos)"
				nSaldo := SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE + nJuros + nValAces + nMultaTit
			Else
				//@ 012, 055 SAY Trans(SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE + nJuros + nValAces + nMultaTit - nAbatim - nDescFin, tm(SE1->E1_SALDO, 17, ncasas)) SIZE 50,16 OF oPanel3 PIXEL //"Saldo T¡tulo (Impostos)"
				nSaldo := SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE + nJuros + nValAces + nMultaTit - nAbatim - nDescFin
			EndIf
		EndIf

		//<-- FINC040

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

			Calculo antigo (está correto também !!!)
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
			If nSaldo > 0
				nSaldo -= (cAliasQry)->F2_XXVRETC
				nSaldo -= (cAliasQry)->F2_XXVCVIN
			EndIf
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
//If SE1->E1_NUM = '000000467'
//	x:=0
//EndIf
If dbSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA))
	While !SE5->(Eof()).AND. ;
		SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO) == ;
		xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
			
		*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		*³ Verifica se NCC de mesmo numero pertence a outro cliente		³
		*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
					
	        //Movimento de inclusão do RA
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



