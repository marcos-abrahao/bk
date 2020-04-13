#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKFINR26
BK - Planilha de Pedidos e Faturamento
v29/03/20
@Return
@author Marcos Bispo Abrahão
@since 15/03/2020
@version P12
/*/

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

Private cTTipos 	:= ""

Private cTitulo     := "Pedidos e Faturamento"
Private cPerg       := "BKFINR26"

Private aParam		:=	{}
Private aRet		:=	{}

Private dDataI  	:= CTOD("")
Private dDataF  	:= CTOD("")


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
aAdd( aParam, { 1, "Data Inicial:" 	 , dDataBase	, "" , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Data Final:" 	 , dDataBase	, "" , "", ""	, "" , 70  , .F. })  

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
aAdd(aFields,{"XX_NF"     ,"F2_DOC","","Nota Fiscal número"})
aAdd(aFields,{"XX_DATANF" ,"F2_EMISSAO","","Data Emissao NF"})
aAdd(aFields,{"XX_EMISSOR","F2_USERLGI","","Responsável emissão NF"})
aAdd(aFields,{"XX_VALNF"  ,"F2_VALBRUT","","Vl Bruto NF"})
aAdd(aFields,{"XX_VALLIQ" ,"","XX_VALLIQ","Vl Liq.NF",cPict,"N",18,2})
aAdd(aFields,{"XX_VENC"   ,"E1_VENCREA"})
aAdd(aFields,{"XX_BAIXA"  ,"E1_BAIXA"})
aAdd(aFields,{"XX_SALDO"  ,"E1_SALDO","","Saldo a Receber"})
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

Processa( {|| ProcBKR26() })

AADD(aPlans,{cAliasTrb,TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, .F. })
Processa( {|| U_GeraXlsx(aPlans,"",cPerg, .F., .T.)})

oTmpTb:Delete()

Return


Static Function BkFR26
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg      ,.T.         ,.T.))
	lRet     := .T.
	dDataI   := mv_par01
	dDataF   := mv_par02
	cTitulo  := "Pedidos e Faturamento - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
Endif
Return lRet



Static Function ProcBKR26
Local cQuery  := ""
Local nF      := 0
Local nSaldo  := 0

Private xCampo

/*
SELECT C5_CLIENTE,C5_LOJACLI,A1_NOME,CN9_XXNRBK,CN9_REVISA,CN9_NUMERO,CTT_DESC01,C5_NUM,CND_VLPREV,C5_EMISSAO,C5_LIBEROK,C5_XXULIB,C5_XXDLIB,C5_XXCOMPM,C5_MDNUMED,C5_MDPLANI,F2_DOC,F2_USERLGI,F2_VALBRUT,F2_EMISSAO,E1_VENCREA,E1_BAIXA,E1_SALDO,SC5.R_E_C_N_O_ AS C5RECNO,SF2.R_E_C_N_O_ AS F2RECNO, SE1.R_E_C_N_O_ AS E1RECNO,
 CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1 ELSE C5_MDCONTR END AS XX_CONTRAT,
 (SELECT SUM(C6_VALOR) FROM SC6010 SC6 WHERE SC6.C6_NUM = SC5.C5_NUM AND SC6.D_E_L_E_T_ = ' ' AND SC6.C6_FILIAL = '01') AS XX_VALPED,
 (SF2.F2_VALFAT - SF2.F2_VALIRRF - SF2.F2_VALINSS - SF2.F2_VALPIS - SF2.F2_VALCOFI - SF2.F2_VALCSLL - (CASE SF2.F2_RECISS WHEN '1' THEN SF2.F2_VALISS ELSE 0 END)) AS XX_VALLIQ,
 (SE1.E1_INSS + SE1.E1_PIS + SE1.E1_COFINS + SE1.E1_CSLL + SE1.E1_VRETISS + SE1.E1_VRETIRF) AS XX_IMPOST
 FROM SC5010 SC5
 LEFT JOIN SF2010 SF2 ON C5_NOTA = F2_DOC AND SF2.D_E_L_E_T_ = '' AND SF2.F2_FILIAL = '01' 
 LEFT JOIN SE1010 SE1 ON SF2.F2_DOC = SE1.E1_NUM AND SF2.F2_SERIE = SE1.E1_PREFIXO AND E1_CLIENTE=F2_CLIENTE AND E1_LOJA=F2_LOJA AND E1_TIPO='NF ' AND  SE1.D_E_L_E_T_ = ' ' AND SE1.E1_FILIAL = '01' 
 LEFT JOIN SA1010 SA1 ON SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI AND SA1.D_E_L_E_T_ = ' ' AND SA1.A1_FILIAL = '  ' 
 LEFT JOIN CN9010 CN9 ON CN9_NUMERO = C5_MDCONTR AND CN9.D_E_L_E_T_ = '' AND CN9.CN9_SITUAC <> '10' AND CN9.CN9_SITUAC <> '09' AND CN9.CN9_FILIAL = '01' 
 LEFT JOIN CND010 CND ON C5_MDNUMED = CND_NUMMED AND CN9_REVISA = CND_REVISA AND CND.D_E_L_E_T_ = '' AND CND.CND_FILIAL = '01' 
 LEFT JOIN CTT010 CTT ON CTT_CUSTO = (CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1 ELSE C5_MDCONTR END) AND  CTT_FILIAL = '01' AND  CTT.D_E_L_E_T_ = ' ' WHERE SC5.D_E_L_E_T_ = ' ' 
 AND SC5.C5_FILIAL = '01' 
 AND SC5.C5_EMISSAO >= '20200301'
 AND SC5.C5_EMISSAO <= '20200319'
 ORDER BY C5_NUM
*/


cQuery := "SELECT "
For nF := 1 To Len(aFields)
	If LEN(aFields[nF]) < 3 .OR. Empty(aFields[nF,3])
		cQuery += aFields[nF,2]+","
	EndIf
Next

cQuery += "SC5.R_E_C_N_O_ AS C5RECNO,SF2.R_E_C_N_O_ AS F2RECNO, SE1.R_E_C_N_O_ AS E1RECNO," + CRLF
cQuery += " CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1 ELSE C5_MDCONTR END AS XX_CONTRAT," + CRLF
cQuery += " (SELECT SUM(C6_VALOR) FROM "+RETSQLNAME("SC6")+" SC6 WHERE SC6.C6_NUM = SC5.C5_NUM AND SC6.D_E_L_E_T_ = ' ' AND SC6.C6_FILIAL = '" + xFilial("SC6") + "') AS XX_VALPED," + CRLF
cQuery += " (SF2.F2_VALFAT - SF2.F2_VALIRRF - SF2.F2_VALINSS - SF2.F2_VALPIS - SF2.F2_VALCOFI - SF2.F2_VALCSLL - (CASE SF2.F2_RECISS WHEN '1' THEN SF2.F2_VALISS ELSE 0 END)) AS XX_VALLIQ," + CRLF
cQuery += " (SE1.E1_INSS + SE1.E1_PIS + SE1.E1_COFINS + SE1.E1_CSLL + SE1.E1_VRETISS + SE1.E1_VRETIRF) AS XX_IMPOST"+ CRLF
cQuery += " FROM "+RETSQLNAME("SC5")+" SC5" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+" SF2 ON C5_NOTA = F2_DOC AND SF2.D_E_L_E_T_ = '' AND SF2.F2_FILIAL = '" + xFilial("SF2") + "' " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SE1")+" SE1 ON SF2.F2_DOC = SE1.E1_NUM AND SF2.F2_SERIE = SE1.E1_PREFIXO AND E1_CLIENTE=F2_CLIENTE AND E1_LOJA=F2_LOJA AND E1_TIPO='NF ' AND  SE1.D_E_L_E_T_ = ' ' AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI AND SA1.D_E_L_E_T_ = ' ' AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CN9")+" CN9 ON CN9_NUMERO = C5_MDCONTR AND CN9.D_E_L_E_T_ = '' AND CN9.CN9_SITUAC <> '10' AND CN9.CN9_SITUAC <> '09' AND CN9.CN9_FILIAL = '" + xFilial("CN9") + "' " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CND")+" CND ON C5_MDNUMED = CND_NUMMED AND CND_REVISA = CN9_REVISA AND CND.D_E_L_E_T_ = '' AND CND.CND_FILIAL = '" + xFilial("CND") + "' " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_CUSTO = (CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1 ELSE C5_MDCONTR END)  AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"
cQuery += " WHERE SC5.D_E_L_E_T_ = ' ' " + CRLF
cQuery += " AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' " + CRLF
If !Empty(dDataI)
	cQuery += " AND SC5.C5_EMISSAO >= '"+DTOS(dDataI)+"'" + CRLF
EndIf
If !Empty(dDataF)
	cQuery += " AND SC5.C5_EMISSAO <= '"+DTOS(dDataF)+"'" + CRLF
EndIf          
cQuery += " ORDER BY C5_NUM"

u_LogMemo("BKFINR26.SQL",cQuery)

cAliasQry := "TMPR26" //GetNextAlias()

//TCQUERY cQuery NEW ALIAS "TMPR26"

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
TCSETFIELD(cAliasQry,"C5_EMISSAO","D", 8,0)
TCSETFIELD(cAliasQry,"F2_EMISSAO","D", 8,0)
TCSETFIELD(cAliasQry,"E1_VENCREA","D", 8,0)
TCSETFIELD(cAliasQry,"E1_BAIXA","D", 8,0)
TCSETFIELD(cAliasQry,"C5_XXDLIB","D", 8,0)
ProcRegua((cAliasQry)->(RecCount()))

nCont := 0

dbSelectArea("CN9")
dbSetOrder(1)

dbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())
DO WHILE (cAliasQry)->(!EOF())
    nCont++
	IncProc("Consultando banco de dados...")
	dbSelectArea(cAliasTrb)
	Reclock(cAliasTrb,.T.)

	For nF := 1 To Len(aFields)
		If Len(aFields[nF]) > 2 .AND. !Empty(aFields[nF,3])
            If (cAliasQry)->(FieldPos(aFields[nF,3])) > 0
			    xCampo := &(cAliasQry+"->"+aFields[nF,3])
            EndIf
		Else
			xCampo := &(cAliasQry+"->"+aFields[nF,2])
		EndIf

		If aFields[nF,2] = "E1_SALDO"
			SE1->(dbGoTo((cAliasQry)->E1RECNO))
			nSaldo := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZA,"R",SE1->E1_CLIENTE,1,,dDataBase,SE1->E1_LOJA,,0/*nTxMoeda*/)
			If nSaldo > 0 
				nSaldo -= (cAliasQry)->XX_IMPOST
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
		EndIf

		&(cAliasTrb+"->"+aFields[nF,1]) :=  xCampo
	Next

	(cAliasTrb)->(MsUnLock())
		
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbSkip())
ENDDO

(cAliasQry)->(dbCloseArea())

dbSelectArea(cAliasTrb)
dbGoTop()

Return
