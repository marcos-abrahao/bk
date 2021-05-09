#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR01
BK - Mapa de Mediçoes 
@Return
@author Marcos Bispo Abrahão
@since 09/06/10 - rev 18/05/20
@version P12
/*/

User Function BKGCTR01()
Public cMotMulta := "N"
BKGCTR1X()
Return 


User Function BKGCTR1A()
Public cMotMulta := "S"
BKGCTR1X()
Return 

Static aRecNo := {}

STATIC Function BKGCTR1X()

Local titulo        := ""
Local aTitulos		:= {}
Local aCampos		:= {}
Local aCabs			:= {}
Local aPlans		:= {}

Private cPerg       := "BKGCTR01"

Private cMesComp    := "01"
Private cAnoComp    := "2010"
Private nPlan       := 1
Private cMes 
Private nValPrev	:= 0

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
Endif
                                                                                                                                     
cMesComp := mv_par01
cAnoComp := mv_par02
cCompet  := cMesComp+"/"+cAnoComp
nPlan    := mv_par03

//nMes := VAL(cMesComp) + 1
//nAno := VAL(cAnoComp)
//IF nMes = 13
//   nMes := 1
//   nAno := nAno + 1
//ENDIF
//cMes := STR(nAno,4)+STRZERO(nMes,2)   

IF LEN(ALLTRIM(cAnoComp)) < 4
   MSGSTOP('Ano deve conter 4 digitos!!',"Atenção")
   Return
ENDIF 

cMes := cAnoComp+STRZERO(VAL(cMesComp),2)

titulo   := "Mapa de Medições : Competencia "+cMesComp+"/"+cAnoComp

FWMsgRun(, {|oSay| ProcQuery() }, "", "Consultando o banco de dados...")	

AADD(aTitulos,titulo)


AADD(aCampos,"QTMP->CNF_CONTRA")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QTMP->CNF_REVISA")
AADD(aCabs  ,"Revisão")

AADD(aCampos,"QTMP->CTT_DESC01")
AADD(aCabs  ,"Centro de Custos")

AADD(aCampos,"U_BUSCACN9(QTMP->CNF_CONTRA,'CN9_XXNRBK')")
AADD(aCabs  ,"Gestor "+FWEmpName(cEmpAnt))

AADD(aCampos,"QTMP->CNA_NUMERO")
AADD(aCabs  ,"Planilha")

AADD(aCampos,"QTMP->CNA_XXMUN")
AADD(aCabs  ,"Municipio")

AADD(aCampos,"QTMP->CNF_COMPET")
AADD(aCabs  ,"Competencia")

AADD(aCampos,"QTMP->CND_NUMMED")
AADD(aCabs  ,"Medição")

AADD(aCampos,"QTMP->C6_NUM")
AADD(aCabs  ,"Pedido")

AADD(aCampos,"QTMP->C5_EMISSAO")
AADD(aCabs  ,"Emissao Ped.")

AADD(aCampos,"QTMP->F2_EMISSAO")
AADD(aCabs  ,"Emissao NF")

AADD(aCampos,"QTMP->F2_DOC")
AADD(aCabs  ,"Nota Fiscal")
   
AADD(aCampos,"QTMP->XX_VENCTO")
AADD(aCabs  ,"Vencimento")

AADD(aCampos,"QTMP->XX_BAIXA")
AADD(aCabs  ,"Recebimento")

//AADD(aCampos,"QTMP->CNF_VLPREV")
//AADD(aCabs  ,"Valor Previsto")

AADD(aCampos,"nValPrev := U_GCTR1VP(QTMP->CNFRECNO,QTMP->CNF_VLPREV)")
AADD(aCabs  ,"Valor Previsto")

AADD(aCampos,"iIf(nValPrev>0,QTMP->CNF_SALDO,0)")
AADD(aCabs  ,"Saldo Previsto")

AADD(aCampos,"QTMP->F2_VALFAT")
AADD(aCabs  ,"Valor faturado")

AADD(aCampos,"nValPrev - QTMP->F2_VALFAT")
AADD(aCabs  ,"Previsto - Faturado")

AADD(aCampos,"QTMP->XX_BONIF")
AADD(aCabs  ,"Bonificações")

AADD(aCampos,"QTMP->XX_MULTA")
AADD(aCabs  ,"Multas")

AADD(aCampos,"QTMP->XX_E5DESC")
AADD(aCabs  ,"Desconto na NF")

AADD(aCampos,"QTMP->XX_E5MULTA")
AADD(aCabs  ,"Cliente não Reteve")

AADD(aCampos,"QTMP->F2_VALIRRF")
AADD(aCabs  ,"IRRF Retido")

AADD(aCampos,"QTMP->F2_VALINSS")
AADD(aCabs  ,"INSS Retido")

AADD(aCampos,"QTMP->F2_VALPIS")
AADD(aCabs  ,"PIS Retido")

AADD(aCampos,"QTMP->F2_VALCOFI")
AADD(aCabs  ,"COFINS Retido")

AADD(aCampos,"QTMP->F2_VALCSLL")
AADD(aCabs  ,"CSLL Retido")

AADD(aCampos,"IIF(QTMP->F2_RECISS = '1',QTMP->F2_VALISS,0)")
AADD(aCabs  ,"ISS Retido")

AADD(aCampos,"QTMP->F2_VLCPM")
AADD(aCabs  ,"ISS Bitrib")

AADD(aCampos,"QTMP->F2_XXVRETC")
AADD(aCabs  ,"Ret. Contratual")

AADD(aCampos,"QTMP->F2_VALFAT - QTMP->F2_VALIRRF - QTMP->F2_VALINSS - QTMP->F2_VALPIS - QTMP->F2_VALCOFI - QTMP->F2_VALCSLL - IIF(QTMP->F2_RECISS = '1',QTMP->F2_VALISS,0) - QTMP->F2_VLCPM - QTMP->XX_E5DESC + QTMP->XX_E5MULTA - QTMP->F2_XXVRETC")
AADD(aCabs  ,"Valor liquido")

If cMotMulta = "S"
	// 18/11/14 - Campos XX_BONIF alterado de '2' para '1' e XX_MULTA alterado de '1' para '2'

	AADD(aCampos,"U_BKCNR01(QTMP->CND_NUMMED,'1')")
	AADD(aCabs  ,"Motivo Bonificação")

	AADD(aCampos,"U_BKCNR01(QTMP->CND_NUMMED,'2')")
	AADD(aCabs  ,"Motivo Multa")
EndIf


AADD(aPlans,{"QTMP",cPerg,"",Titulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
U_GeraXlsx(aPlans,Titulo,cPerg,.F.)
	   
Return


Static Function ProcQuery()
Local cQuery as Character
Local cRevAtu := Space(GetSx3Cache("CN9_REVATU","X3_TAMANHO"))

Local cJCNDCNE:= FWJoinFilial("CND", "CNE")
Local cJCXNCNE:= FWJoinFilial("CXN", "CNE")
//Local cJCN1CN9:= FWJoinFilial("CN1", "CN9")
Local cJCNACN9:= FWJoinFilial("CNA", "CN9")
Local cJSC5CNE:= FWJoinFilial("SC5", "CNE")
Local cJSC6SC5:= FWJoinFilial("SC6", "SC5")
Local cJSD2SC6:= FWJoinFilial("SD2", "SC6")
Local cJSF2SC6:= FWJoinFilial("SF2", "SC6")
//Local cJSB1SC6:= FWJoinFilial("SB1", "SC6")

/*
Resposta Totvs 15/03/21
Obs: Qualquer consulta realizada atualmente na CND, pode adicionar um  LEFT join com a CXN, e utilizar  o ISNULL na seleção dos campos:
Exemplo: ISNULL(CXN.CXN_NUMPLA, CND.CND_NUMERO) CND_NUMERO, ISNULL(CXN.CXN_FORNEC, CND.CND_FORNEC) CND_FORNEC, ISNULL(CXN.CXN_CLIENT, CND.CND_CLIENT) CND_CLIENT,
A chave do LEFT JOIN seria entre os campos abaixo: CXN.CXN_FILIAL = CND.CND_FILIAL AND CXN.CXN_CONTRA = CND.CND_CONTRA AND CXN.CXN_REVISA = CND.CND_REVISA AND CXN.CXN_NUMMED = CND.CND_NUMMED AND CXN.CXN_CHECK = 'T'
*/

cQuery := " SELECT DISTINCT" + CRLF
cQuery += "   CNF_CONTRA"+ CRLF
cQuery += "   ,CNF_REVISA"+ CRLF
cQuery += "   ,CNF_COMPET"+ CRLF
cQuery += "   ,CN9_XXNRBK"+ CRLF
cQuery += "   ,CASE WHEN CN9_SITUAC = '05' THEN CNF_VLPREV ELSE CNF_VLREAL END AS CNF_VLPREV"+ CRLF
cQuery += "   ,CASE WHEN CN9_SITUAC = '05' THEN CNF_SALDO  ELSE 0 END AS CNF_SALDO"+ CRLF
cQuery += "   ,CTT_DESC01"+ CRLF
cQuery += "   ,CNA_NUMERO"+ CRLF
cQuery += "   ,CNA_XXMUN"+ CRLF
cQuery += "   ,CND_NUMMED"+ CRLF
cQuery += "   ,CNF.R_E_C_N_O_ AS CNFRECNO"+ CRLF
cQuery += "   ,C6_NUM"+ CRLF
cQuery += "   ,C6_DATCPL AS C5_EMISSAO"+ CRLF

// 18/11/14 - Campos XX_BONIF alterado de '2' para '1' e XX_MULTA alterado de '1' para '2'
cQuery += "   ,(SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CNR_NUMMED = CNE_NUMMED AND CNR_CODPLA = ISNULL(CXN_NUMPLA,'      ')" + CRLF    // AND CNR_CODPLA = CNE_NUMERO
cQuery += "   	AND CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '1') AS XX_BONIF" + CRLF 

cQuery += "   ,(SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CNR_NUMMED = CNE_NUMMED AND CNR_CODPLA = ISNULL(CXN_NUMPLA,'      ')" + CRLF    // AND CNR_CODPLA = CNE_NUMERO
cQuery += "   	AND  CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2') AS XX_MULTA" + CRLF 

cQuery += "   ,F2_DOC
cQuery += "   ,F2_EMISSAO" + CRLF
cQuery += "   ,F2_VALFAT" + CRLF
cQuery += "   ,F2_VALIRRF" + CRLF
cQuery += "   ,F2_VALINSS" + CRLF
cQuery += "   ,F2_VALPIS" + CRLF
cQuery += "   ,F2_VALCOFI" + CRLF
cQuery += "   ,F2_VALCSLL" + CRLF
cQuery += "   ,F2_RECISS" + CRLF
cQuery += "   ,F2_VALISS" + CRLF
cQuery += "   ,F2_VLCPM" + CRLF
cQuery += "   ,F2_XXVRETC" + CRLF

cQuery += "   ,(SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "      AND  SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"') AS XX_VENCTO"+ CRLF

cQuery += "   ,(SELECT TOP 1 E1_BAIXA FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "      AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"') AS XX_BAIXA"+ CRLF

cQuery += "   ,(SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "      AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5DESC"+ CRLF
cQuery += "   ,(SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "      AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5MULTA "+ CRLF

cQuery += " FROM "+RETSQLNAME("CNE")+" CNE" + CRLF

cQuery += " INNER JOIN "+RETSQLNAME("CND")+" CND" + CRLF
cQuery += " 	ON (CND_NUMMED = CNE_NUMMED AND CND_CONTRA = CNE_CONTRA AND CND_REVISA = CNE_REVISA" +CRLF
cQuery += " 		AND "+cJCNDCNE+" AND CND.D_E_L_E_T_='')" + CRLF

//cQuery += " INNER JOIN "+RETSQLNAME("CXN")+" CXN" + CRLF
//cQuery += " 	ON (CXN_NUMMED = CNE_NUMMED AND CXN_CONTRA = CNE_CONTRA AND CXN_REVISA = CNE_REVISA AND CXN_NUMPLA = CNE_NUMERO" +CRLF
//cQuery += " 		AND "+cJCXNCNE+" AND CXN.D_E_L_E_T_='')" + CRLF
// Sugestão Totvs: CXN.CXN_FILIAL = CND.CND_FILIAL AND CXN.CXN_CONTRA = CND.CND_CONTRA AND CXN.CXN_REVISA = CND.CND_REVISA AND CXN.CXN_NUMMED = CND.CND_NUMMED AND CXN.CXN_CHECK = 'T'

cQuery += " LEFT JOIN "+RETSQLNAME("CXN")+" CXN" + CRLF
cQuery += " 	ON (CXN_CONTRA = CNE_CONTRA AND CXN_REVISA = CNE_REVISA AND CXN_NUMMED = CNE_NUMMED AND CXN_NUMPLA = CNE_NUMERO AND CXN.CXN_CHECK = 'T'" +CRLF
cQuery += " 		AND "+cJCXNCNE+" AND CXN.D_E_L_E_T_='')" + CRLF

cQuery += " INNER JOIN "+RETSQLNAME("CTT")+" CTT" + CRLF
cQuery += " 	ON (CTT_CUSTO = CNE_CONTRA" + CRLF
cQuery += " 		AND CTT_FILIAL = '"+xFilial("CTT")+"' AND CTT.D_E_L_E_T_='')" + CRLF

cQuery += " INNER JOIN "+RETSQLNAME("CN9")+" CN9" + CRLF
cQuery += " 	ON (CN9_FILCTR = CND_FILCTR AND CN9_NUMERO = CNE_CONTRA AND CN9_REVISA = CNE_REVISA" +CRLF
cQuery += " 	 	AND CN9_FILIAL = '"+xFilial("CN9")+"' AND CN9.D_E_L_E_T_='')" + CRLF

cQuery += " INNER JOIN "+RETSQLNAME("CNF")+" CNF" + CRLF
cQuery += " 	ON (CNE_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CNE_NUMERO = CNF_NUMPLA AND CNE_REVISA = CNF_REVISA" +CRLF
cQuery += " 	    AND CNF_PARCEL = ISNULL(CXN_PARCEL,CND_PARCEL)" + CRLF
cQuery += " 	 	AND CNF_FILIAL = CN9_FILIAL AND CNF.D_E_L_E_T_='')" + CRLF

//cQuery += " INNER JOIN "+RETSQLNAME("CN1")+" CN1" + CRLF
//cQuery += " 	ON (CN1_CODIGO = CN9_TPCTO AND CN1_ESPCTR IN ('2')" + CRLF
//cQuery += " 		AND "+cJCN1CN9+" AND CN1.D_E_L_E_T_='')" + CRLF

cQuery += " INNER JOIN "+RETSQLNAME("CNA")+" CNA" + CRLF
cQuery += " 	ON (CNA_CONTRA = CNE_CONTRA AND CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA AND CNA_NUMERO = CNF_NUMPLA" +CRLF
cQuery += " 		AND "+cJCNACN9+" AND CNA.D_E_L_E_T_='')"+CRLF // CNE_CONTRA

cQuery += " INNER JOIN "+RETSQLNAME("SC5")+" SC5" + CRLF
cQuery += " 	ON (C5_MDNUMED = CNE_NUMMED AND C5_MDPLANI = CNE_NUMERO" + CRLF
cQuery += " 		AND "+cJSC5CNE+" AND SC5.D_E_L_E_T_='')" + CRLF

cQuery += " INNER JOIN "+RETSQLNAME("SC6")+" SC6" + CRLF
cQuery += " 	ON (C5_CLIENT = C6_CLI AND C5_LOJACLI = C6_LOJA AND C6_NUM = C5_NUM AND C6_ITEMED = CNE_ITEM" +CRLF
cQuery += " 		AND "+cJSC6SC5+" AND SC6.D_E_L_E_T_='')" + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("SD2")+" SD2" + CRLF
cQuery += " 	ON (D2_PEDIDO = C5_NUM AND D2_ITEMPV = C6_ITEM AND C5_CLIENT = D2_CLIENTE AND D2_LOJA = C5_LOJACLI" +CRLF
cQuery += " 		AND "+cJSD2SC6+" AND SD2.D_E_L_E_T_='')" + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+" SF2" + CRLF
cQuery += " 	ON (C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND F2_CLIENTE = C6_CLI AND F2_LOJA = C6_LOJA AND F2_TIPO = 'N' AND F2_FORMUL = ' '" + CRLF
cQuery += " 		AND "+cJSF2SC6+" AND SF2.D_E_L_E_T_='')" + CRLF

cQuery += " INNER JOIN "+RETSQLNAME("SB1")+" SB1" + CRLF
cQuery += " 	ON (C6_PRODUTO = B1_COD" +CRLF
cQuery += " 		AND B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.D_E_L_E_T_='')"+CRLF

cQuery += " WHERE CNE_FILIAL = '"+xFilial("CNE")+"' AND CNE.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " 	AND CN9.CN9_REVATU = '"+cRevAtu+"'"+ CRLF
cQuery += "     AND CNF_COMPET = '"+cCompet+"'"+ CRLF

// Faturamento avulso - sem medição
cQuery += " UNION ALL "+ CRLF

cQuery += " SELECT DISTINCT" + CRLF 
cQuery += "   CASE WHEN (C5_ESPECI1 = ' ' OR C5_ESPECI1 IS NULL) THEN 'XXXXXXXXXX' ELSE C5_ESPECI1 END AS CNF_CONTRA"+ CRLF
cQuery += "   ,' ' AS CNF_REVISA"+ CRLF
cQuery += "   ,SUBSTRING(C5_XXCOMPT,1,2)+'/'+SUBSTRING(C5_XXCOMPT,3,4) AS CNF_COMPET"+CRLF
cQuery += "   ,' ' AS CN9_XXNRBK"+ CRLF
cQuery += "   ,0   AS CNF_VLPREV
cQuery += "   ,0   AS CNF_SALDO
cQuery += "   ,A1_NOME AS CTT_DESC01"+ CRLF
cQuery += "   ,' ' AS CNA_NUMERO"+CRLF
cQuery += "   ,CASE WHEN (C5_DESCMUN = ' ' OR C5_DESCMUN IS NULL) THEN SA1.A1_MUN ELSE C5_DESCMUN END AS CNA_XXMUN" + CRLF
cQuery += "   ,' ' AS CND_NUMMED"+CRLF
cQuery += "   ,0 AS CNFRECNO"+ CRLF
cQuery += "   ,D2_PEDIDO AS C6_NUM"+ CRLF
cQuery += "   ,C5_EMISSAO"+ CRLF
cQuery += "   ,0 AS XX_BONIF"+ CRLF
cQuery += "   ,0 AS XX_MULTA"+ CRLF
cQuery += "   ,F2_DOC"+ CRLF
cQuery += "   ,F2_EMISSAO"+ CRLF
cQuery += "   ,F2_VALFAT"+ CRLF
cQuery += "   ,F2_VALIRRF"+ CRLF
cQuery += "   ,F2_VALINSS"+ CRLF
cQuery += "   ,F2_VALPIS"+ CRLF
cQuery += "   ,F2_VALCOFI"+ CRLF
cQuery += "   ,F2_VALCSLL"+ CRLF
cQuery += "   ,F2_RECISS"+ CRLF
cQuery += "   ,F2_VALISS"+ CRLF
cQuery += "   ,F2_VLCPM"+ CRLF
cQuery += "   ,F2_XXVRETC"+ CRLF
cQuery += "   ,(SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+" SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "       AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"') AS XX_VENCTO "+ CRLF
cQuery += "   ,(SELECT TOP 1 E1_BAIXA FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC" + CRLF
cQuery += "       AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"') AS XX_BAIXA " + CRLF
cQuery += "   ,(SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' "  + CRLF
cQuery += "       AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5DESC " + CRLF
cQuery += "   ,(SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "       AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5MULTA "+ CRLF

cQuery += " FROM "+RETSQLNAME("SF2")+" SF2" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA" + CRLF
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SD2")+ " SD2 ON D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA" + CRLF
cQuery += "      AND  D2_FILIAL = '"+xFilial("SD2")+"' AND  SD2.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON C5_NOTA = F2_DOC AND C5_SERIE = F2_SERIE " + CRLF
cQuery += "      AND  C5_FILIAL = F2_FILIAL AND SC5.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+ " SB1 ON D2_COD = B1_COD"+ CRLF
cQuery += "      AND  B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " WHERE (C5_MDCONTR = ' ' OR "+ CRLF
cQuery +=         "C5_MDCONTR IS NULL ) "+ CRLF
cQuery += "      AND SUBSTRING(F2_EMISSAO,1,6) = '"+cMes+"' " 
cQuery += "      AND SF2.D_E_L_E_T_ = ' '" + CRLF

// Cronograma não faturado
cQuery += " UNION ALL "+ CRLF

cQuery += " SELECT DISTINCT" + CRLF 
cQuery += "   CNF_CONTRA"+ CRLF
cQuery += "   ,CNF_REVISA"+ CRLF
cQuery += "   ,CNF_COMPET"+CRLF
cQuery += "   ,CN9_XXNRBK"+ CRLF
cQuery += "   ,CNF_VLPREV
cQuery += "   ,CNF_SALDO
cQuery += "   ,CTT_DESC01"+ CRLF
cQuery += "   ,CNA_NUMERO"+CRLF
cQuery += "   ,CNA_XXMUN" + CRLF
cQuery += "   ,' ' AS CND_NUMMED"+CRLF
cQuery += "   ,CNF.R_E_C_N_O_ AS CNFRECNO"+ CRLF
cQuery += "   ,' ' AS C6_NUM"+ CRLF
cQuery += "   ,' ' AS C5_EMISSAO"+ CRLF
cQuery += "   ,0 AS XX_BONIF"+ CRLF
cQuery += "   ,0 AS XX_MULTA"+ CRLF
cQuery += "   ,' ' AS F2_DOC"+ CRLF
cQuery += "   ,' ' AS F2_EMISSAO"+ CRLF
cQuery += "   ,0   AS F2_VALFAT"+ CRLF
cQuery += "   ,0   AS F2_VALIRRF"+ CRLF
cQuery += "   ,0   AS F2_VALINSS"+ CRLF
cQuery += "   ,0   AS F2_VALPIS"+ CRLF
cQuery += "   ,0   AS F2_VALCOFI"+ CRLF
cQuery += "   ,0   AS F2_VALCSLL"+ CRLF
cQuery += "   ,' ' AS F2_RECISS"+ CRLF
cQuery += "   ,0   AS F2_VALISS"+ CRLF
cQuery += "   ,0   AS F2_VLCPM"+ CRLF
cQuery += "   ,0   AS F2_XXVRETC"+ CRLF
cQuery += "   ,' ' AS XX_VENCTO "+ CRLF
cQuery += "   ,' ' AS XX_BAIXA " + CRLF
cQuery += "   ,0   AS XX_E5DESC " + CRLF
cQuery += "   ,0   AS XX_E5MULTA "+ CRLF

cQuery += " FROM "+RETSQLNAME("CNF")+" CNF" + CRLF

cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9_REVATU = ' '"+ CRLF
cQuery += "      AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"+ CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+ CRLF
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"+ CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_CONTRA = CNF_CONTRA AND CNA_REVISA = CNF_REVISA"+ CRLF
cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '"+ CRLF

cQuery += " WHERE CNF_COMPET = '"+cCompet+"'"+ CRLF
cQuery += "      AND  CNF_SALDO = CNF_VLPREV"+ CRLF
cQuery += "      AND  CNF_FILIAL = '"+xFilial("CNF")+"' AND  CNF.D_E_L_E_T_ = ' '"+ CRLF

cQuery += " ORDER BY CNF_CONTRA,CNF_REVISA,CNF_COMPET,F2_DOC" + CRLF

u_LogMemo("BKGCTR01.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","F2_EMISSAO","D",8,0)
TCSETFIELD("QTMP","C5_EMISSAO","D",8,0)
TCSETFIELD("QTMP","XX_VENCTO","D",8,0)
TCSETFIELD("QTMP","XX_VENCORI","D",8,0)
TCSETFIELD("QTMP","XX_BAIXA","D",8,0)
Return



/*
Static Function ProcQueryAntes
Local cQuery

IncProc("Consultando o banco de dados...")

cQuery := " SELECT DISTINCT"+ CRLF
cQuery += "   CNF_CONTRA"+ CRLF
cQuery += "   ,CNF_REVISA"+ CRLF
cQuery += "   ,CNF_COMPET"+ CRLF
cQuery += "   ,CN9_XXNRBK"+ CRLF
cQuery += "   ,CASE WHEN CN9_SITUAC = '05' THEN CNF_VLPREV ELSE CNF_VLREAL END AS CNF_VLPREV"+ CRLF
cQuery += "   ,CASE WHEN CN9_SITUAC = '05' THEN CNF_SALDO  ELSE 0 END AS CNF_SALDO"+ CRLF
cQuery += "   ,CTT_DESC01"+ CRLF
cQuery += "   ,CNA_NUMERO"+ CRLF
cQuery += "   ,CNA_XXMUN"+ CRLF
cQuery += "   ,CND_NUMMED"+ CRLF
cQuery += "   ,CNF.R_E_C_N_O_ AS CNFRECNO"+ CRLF
cQuery += "   ,C6_NUM"+ CRLF
cQuery += "   ,C6_DATCPL AS C5_EMISSAO"+ CRLF

// 18/11/14 - Campos XX_BONIF alterado de '2' para '1' e XX_MULTA alterado de '1' para '2'
cQuery += "   ,(SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CNR_NUMMED = CNE_NUMMED AND CNR_CODPLA = ISNULL(CXN_NUMPLA,'      ')" + CRLF    // AND CNR_CODPLA = CNE_NUMERO
cQuery += "   	AND CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '1') AS XX_BONIF" + CRLF 

cQuery += "   ,(SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CNR_NUMMED = CNE_NUMMED AND CNR_CODPLA = ISNULL(CXN_NUMPLA,'      ')" + CRLF    // AND CNR_CODPLA = CNE_NUMERO
cQuery += "   	AND  CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2') AS XX_MULTA" + CRLF 

cQuery += "   ,F2_DOC
cQuery += "   ,F2_EMISSAO" + CRLF
cQuery += "   ,F2_VALFAT" + CRLF
cQuery += "   ,F2_VALIRRF" + CRLF
cQuery += "   ,F2_VALINSS" + CRLF
cQuery += "   ,F2_VALPIS" + CRLF
cQuery += "   ,F2_VALCOFI" + CRLF
cQuery += "   ,F2_VALCSLL" + CRLF
cQuery += "   ,F2_RECISS" + CRLF
cQuery += "   ,F2_VALISS" + CRLF
cQuery += "   ,F2_VLCPM" + CRLF
cQuery += "   ,F2_XXVRETC" + CRLF

cQuery += "   ,(SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "      AND  SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"') AS XX_VENCTO"+ CRLF

cQuery += "   ,(SELECT TOP 1 E1_BAIXA FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "      AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"') AS XX_BAIXA"+ CRLF

cQuery += "   ,(SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "      AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5DESC"+ CRLF
cQuery += "   ,(SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "      AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5MULTA "+ CRLF

cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+ CRLF

cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+ CRLF
cQuery += "      AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"+ CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+ CRLF
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"+ CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_CONTRA = CNF_CONTRA AND CNA_REVISA = CNF_REVISA"+ CRLF
cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '"+ CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CNA_NUMERO = CND_NUMERO AND CND_REVISA = CNA_REVISA"+ CRLF
cQuery += "      AND  CND.D_E_L_E_T_ = ' '"+ CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CXN")+" CXN" + CRLF
cQuery += " 	ON (CXN_CONTRA = CNF_CONTRA AND CXN_REVISA = CNF_REVISA AND CXN_NUMMED = CND_NUMMED AND CXN_NUMPLA = CNF_NUMERO AND CXN.CXN_CHECK = 'T'" +CRLF
cQuery += " 		AND CXN_FILIAL = CND_FILIAL AND CXN.D_E_L_E_T_='')" + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CNE")+" CNE" + CRLF
cQuery += " 	ON (CNE_CONTRA = CNF_CONTRA AND CNE_REVISA = CNF_REVISA AND CNE_NUMMED = CND_NUMMED AND CNE_NUMERO = CNF_NUMERO" +CRLF
cQuery += " 		AND CNE_FILIAL = CND_FILIAL AND CNE.D_E_L_E_T_='')" + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON CNE_PEDIDO = C6_NUM"+ CRLF
cQuery += "      AND  C6_FILIAL = CND_FILIAL AND SC6.D_E_L_E_T_ = ' '"+ CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+ " SF2 ON C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC"+ CRLF
cQuery += "      AND  F2_FILIAL = CND_FILIAL AND SF2.D_E_L_E_T_ = ' '"+ CRLF

cQuery += " WHERE CNF_COMPET = '"+cCompet+"'"+ CRLF
// para teste cQuery += " WHERE SUBSTRING(F2_EMISSAO,1,6) = "+cMes

cQuery += "      AND  CNF_FILIAL = '"+xFilial("CNF")+"' AND  CNF.D_E_L_E_T_ = ' '"+ CRLF


//cqContr:= "(SELECT TOP 1 C5_MDCONTR FROM "+RETSQLNAME("SC6")+ " SC6 INNER JOIN "+RETSQLNAME("SC5")+" SC5 ON C5_FILIAL = C6_FILIAL AND C6_NUM = C5_NUM AND C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ') "
//cqEspec:= "(SELECT TOP 1 C5_ESPECI1 FROM "+RETSQLNAME("SC6")+ " SC6 INNER JOIN "+RETSQLNAME("SC5")+" SC5 ON C5_FILIAL = C6_FILIAL AND C6_NUM = C5_NUM AND C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ') "

cQuery += " UNION ALL "+ CRLF
cQuery += " SELECT DISTINCT "+ CRLF
//cQuery += "        CASE WHEN "+cqEspec+" = ' ' THEN 'XXXXXXXXXX' ELSE "+cqEspec+" END,"+ CRLF   // CNF_CONTRA
cQuery += "        CASE WHEN (C5_ESPECI1 = ' ' OR C5_ESPECI1 IS NULL) THEN 'XXXXXXXXXX' ELSE C5_ESPECI1 END AS CNF_CONTRA,"+ CRLF   // CNF_CONTRA
cQuery += "        ' ',SUBSTRING(C5_XXCOMPT,1,2)+'/'+SUBSTRING(C5_XXCOMPT,3,4) AS CNF_COMPET,' ',0,0, "  // CNF_REVISA,CNF_COMPET,CN9_XXNRBK,CNF_VLPREV,CNF_SALDO
cQuery += "        A1_NOME, " + CRLF // CTT_DESC01
cQuery += "        ' ',CASE WHEN (C5_DESCMUN = ' ' OR C5_DESCMUN IS NULL) THEN SA1.A1_MUN ELSE C5_DESCMUN END AS CNA_XXMUN, " + CRLF // CNA_NUMERO,CNA_XXMUN
cQuery += "        ' ',0 AS CNFRECNO," + CRLF  // CND_NUMMED
cQuery += "        D2_PEDIDO AS C6_NUM, "      // C6_NUM
cQuery += "        C5_EMISSAO, "+ CRLF
cQuery += "        0,0, " + CRLF     // XX_BONIF,XX_MULTA
cQuery += "        F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS,F2_VLCPM,F2_XXVRETC, " + CRLF
cQuery += "        (SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+" SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "            AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"') AS XX_VENCTO, "+ CRLF
cQuery += "        (SELECT TOP 1 E1_BAIXA FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC" + CRLF
cQuery += "            AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"') AS XX_BAIXA, " + CRLF
cQuery += "        (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' "  + CRLF
cQuery += "            AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5DESC, " + CRLF
cQuery += "        (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "            AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5MULTA "+ CRLF

cQuery += " FROM "+RETSQLNAME("SF2")+" SF2"+ CRLF
//cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = "+cqContr
//cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '""
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA"+ CRLF
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SD2")+ " SD2 ON D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA" + CRLF
cQuery += "      AND  D2_FILIAL = F2_FILIAL AND SD2.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON C5_NUM = D2_PEDIDO " + CRLF
cQuery += "      AND  C5_FILIAL = D2_FILIAL AND SC5.D_E_L_E_T_ = ' '" + CRLF
//cQuery += " WHERE ("+cqContr+" = ' ' OR "+ CRLF
//cQuery +=           cqContr+" IS NULL ) "+ CRLF
cQuery += " WHERE (C5_MDCONTR = ' ' OR "+ CRLF
cQuery +=           "C5_MDCONTR IS NULL ) "+ CRLF
cQuery += "      AND SUBSTRING(F2_EMISSAO,1,6) = '"+cMes+"'" + CRLF
cQuery += "      AND SF2.D_E_L_E_T_ = ' '"+ CRLF

//cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = C6_CONTRA"
//cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '""

//cQuery += " ORDER BY F2_DOC"  

cQuery += " ORDER BY CNF_CONTRA,CNF_REVISA,CNF_COMPET,F2_DOC" + CRLF

u_LogMemo("BKGCTR01.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","F2_EMISSAO","D",8,0)
TCSETFIELD("QTMP","XX_VENCTO","D",8,0)
TCSETFIELD("QTMP","C5_EMISSAO","D",8,0)
TCSETFIELD("QTMP","XX_BAIXA","D",8,0)
u_LogMemo("BKGCTR01.SQL",cQuery)

Return
*/

Static Function  ValidPerg(cPerg)
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Mes de Competencia"  ,"" ,"" ,"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Ano de Competencia"  ,"" ,"" ,"mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Gerar Planilha? "    ,"" ,"" ,"mv_ch3","N",01,0,2,"C","","mv_par03","CSV","CSV","CSV","","","XLSX","XLSX","XLSX","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegistros)
	If !dbSeek(cPerg+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegistros[i])
				FieldPut(j,aRegistros[i,j])
			Endif
		Next
		MsUnlock()
	//Else	
	//	RecLock("SX1",.F.)
	//	For j:=1 to FCount()
	//		If j <= Len(aRegistros[i])
	//			FieldPut(j,aRegistros[i,j])
	//		Endif
	//	Next
	//	MsUnlock()
	Endif
Next

RestArea(aArea)

Return(NIL)


User Function BKCNR01(cNumMed,cTipo)
Local cQuery  := ""
Local cMotivo := ""

cQuery := " SELECT CNR_DESCRI FROM "+RETSQLNAME("CNR")+" CNR WHERE CNR_NUMMED = '"+cNumMed+"' "
cQuery += "             AND  CNR_FILIAL = '"+xFilial("CNR")+"' AND  CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '"+cTipo+"' "
TCQUERY cQuery NEW ALIAS "QTMP1"
dbSelectArea("QTMP1")
dbGoTop()
DO WHILE !EOF()
    cMotivo += ALLTRIM(QTMP1->CNR_DESCRI)+" "
	dbSelectArea("QTMP1")
	dbSkip()
ENDDO

QTMP1->(Dbclosearea())
Return cMotivo


// Evitar previsões duplicadas                        
User Function GCTR1VP(nRec,nVlPrev)
If nRec > 0
	If AsCan(aRecNo,nRec) == 0
		aAdd(aRecno,nRec)
	Else
		nVlPrev := 0
	EndIf
EndIf
Return nVlPrev
