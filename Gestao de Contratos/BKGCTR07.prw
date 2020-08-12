#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKGCTR07()
BK - Mapa de INSS retido

@author Marcos B. Abrahão
@since 05/05/11 rev 17/06/20
@version P12
@return Nil
/*/
//-------------------------------------------------------------------

User Function BKGCTR07()

Local titulo         := ""
Local aTitulos,aCampos,aCabs

Private cPerg        := "BKGCTR07"
Private cString      := "CN9"

Private cMesEmis     := "01"
Private cAnoEmis     := "2011"
Private nPlan        := 1
Private nTipo		 := 1
Private cMes
Private _cTXPIS  	 := STR(GetMv("MV_TXPIS"))
Private _cTXCOF  	 := STR(GetMv("MV_TXCOFINS"))

Public XX_PESSOA     := ""
Public cMotMulta     := "N"

dbSelectArea('SA1')
dbSelectArea(cString)
dbSetOrder(1)

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
Endif

cMesEmis := mv_par01
cAnoEmis := mv_par02
cCompet  := cMesEmis+"/"+cAnoEmis
nPlan    := mv_par03
nTipo    := mv_par04

//nMes := VAL(cMesEmis) + 1
//nAno := VAL(cAnoEmis)
//IF nMes = 13
//   nMes := 1
//   nAno := nAno + 1
//ENDIF
//cMes := STR(nAno,4)+STRZERO(nMes,2)   
IF nTipo == 1
	cMes := cAnoEmis+cMesEmis
ELSE
	cMes := cAnoEmis
ENDIF

titulo   := "Mapa de INSS Retido :"+IIF(nTipo=1," Emissão "+cMesEmis+"/"+cAnoEmis," Anual "+cAnoEmis)

ProcRegua(1)
Processa( {|| ProcQuery() })

aCabs   := {}
aCampos := {}
aTitulos:= {}
   
AADD(aTitulos,titulo)

AADD(aCampos,"QTMP->F2_FILIAL")
AADD(aCabs  ,"Filial")

AADD(aCampos,"QTMP->XX_CLIENTE")
AADD(aCabs  ,"Cliente")

AADD(aCampos,"QTMP->XX_LOJA")
AADD(aCabs  ,"Loja")

AADD(aCampos,"Posicione('SA1',1,xFilial('SA1')+QTMP->XX_CLIENTE+QTMP->XX_LOJA,'A1_NOME')")
AADD(aCabs  ,"Nome")

AADD(aCampos,"M->XX_PESSOA := Posicione('SA1',1,xFilial('SA1')+QTMP->XX_CLIENTE+QTMP->XX_LOJA,'A1_PESSOA')")
AADD(aCabs  ,"Tipo Pes.")

AADD(aCampos,"Transform(Posicione('SA1',1,xFilial('SA1')+QTMP->XX_CLIENTE+QTMP->XX_LOJA,'A1_CGC'),IIF(M->XX_PESSOA=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))")
//AADD(aCampos,"Transform(  Posicione('SA1',1,xFilial('SA1')+QTMP->XX_CLIENTE+QTMP->XX_LOJA,'A1_CGC'),PicPes(M->XX_PESSOA) )")
AADD(aCabs  ,"CNPJ/CPF")

AADD(aCampos,"QTMP->CNF_CONTRA")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QTMP->CNF_REVISA")
AADD(aCabs  ,"Revisão")

AADD(aCampos,"QTMP->CTT_DESC01")
AADD(aCabs  ,"Centro de Custos")

AADD(aCampos,"QTMP->CNA_NUMERO")
AADD(aCabs  ,"Planilha")

AADD(aCampos,"QTMP->CNA_XXMUN")
AADD(aCabs  ,"Municipio")

AADD(aCampos,"QTMP->CNF_COMPET")
AADD(aCabs  ,"Competencia")

AADD(aCampos,"QTMP->XX_PROD")
AADD(aCabs  ,"Produto")

AADD(aCampos,"QTMP->B1_DESC")
AADD(aCabs  ,"Desc.Produto")

AADD(aCampos,"QTMP->B1_CODISS")
AADD(aCabs  ,"Cod Iss")

AADD(aCampos,"QTMP->B1_ALIQISS")
AADD(aCabs  ,"% Iss")

AADD(aCampos,"QTMP->CND_NUMMED")
AADD(aCabs  ,"Medição")

AADD(aCampos,"QTMP->C6_NUM")
AADD(aCabs  ,"Pedido")
   
AADD(aCampos,"QTMP->F2_DOC")
AADD(aCabs  ,"Nota Fiscal")

AADD(aCampos,"QTMP->F2_EMISSAO")
AADD(aCabs  ,"Emissao")
   
AADD(aCampos,"QTMP->XX_VENCTO")
AADD(aCabs  ,"Vencimento")

AADD(aCampos,"QTMP->XX_VENCORI")
AADD(aCabs  ,"Venc. Original")

AADD(aCampos,"QTMP->XX_BAIXA")
AADD(aCabs  ,"Recebimento")

AADD(aCampos,"QTMP->CNF_VLPREV")
AADD(aCabs  ,"Valor Previsto")

AADD(aCampos,"QTMP->CNF_SALDO")
AADD(aCabs  ,"Saldo Previsto")

AADD(aCampos,"QTMP->F2_VALFAT")
AADD(aCabs  ,"Valor faturado")

AADD(aCampos,"QTMP->CNF_VLPREV - QTMP->F2_VALFAT")
AADD(aCabs  ,"Previsto - Faturado")

AADD(aCampos,"QTMP->XX_BONIF")
AADD(aCabs  ,"Bonificações")

AADD(aCampos,"QTMP->XX_MULTA")
AADD(aCabs  ,"Multas")

AADD(aCampos,"QTMP->XX_E5DESC")
AADD(aCabs  ,"Desconto na NF")

AADD(aCampos,"QTMP->XX_E5MULTA")
AADD(aCabs  ,"Cliente não Reteve")

IF FWCodEmp() == "12"  .OR. FWCodEmp() == "02"
	AADD(aCampos,"VAL(STR(((QTMP->F2_VALFAT*0.32)*0.15),14,02))")
	AADD(aCabs  ,"IRPJ Apuração")
	
	AADD(aCampos,"VAL(STR(QTMP->F2_VALFAT*("+ALLTRIM(_cTXPIS)+"/100),14,02))")
	AADD(aCabs  ,"PIS Apuração")
	
	AADD(aCampos,"VAL(STR(QTMP->F2_VALFAT*("+ALLTRIM(_cTXCOF)+"/100),14,02))")
	AADD(aCabs  ,"COFINS Apuração")
	
	AADD(aCampos,"VAL(STR(((QTMP->F2_VALFAT*0.32)*0.09),14,02))")
	AADD(aCabs  ,"CSLL Apuração")
	
ENDIF

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

AADD(aCampos,"QTMP->F2_VALFAT - QTMP->F2_VALIRRF - QTMP->F2_VALINSS - QTMP->F2_VALPIS - QTMP->F2_VALCOFI - QTMP->F2_VALCSLL - IIF(QTMP->F2_RECISS = '1',QTMP->F2_VALISS,0) - QTMP->XX_E5DESC + QTMP->XX_E5MULTA")
AADD(aCabs  ,"Valor liquido")

IF cMotMulta = "S"
	AADD(aCampos,"U_BKCNR07(QTMP->CND_NUMMED,'1')")
	AADD(aCabs  ,"Motivo Bonificação")

	AADD(aCampos,"U_BKCNR07(QTMP->CND_NUMMED,'2')")
	AADD(aCabs  ,"Motivo Multa")
ENDIF

ProcRegua(QTMP->(LASTREC()))
Processa( {|| U_GeraCSV("QTMP",cPerg,aTitulos,aCampos,aCabs)})
Return


Static Function ProcQuery
Local cQuery

IncProc("Consultando o banco de dados...")

cQuery := " SELECT DISTINCT F2_FILIAL,CND_CLIENT AS XX_CLIENTE,CND_LOJACL AS XX_LOJA,C6_PRODUTO AS XX_PROD,B1_DESC,B1_CODISS,B1_ALIQISS,CNF_CONTRA,CNF_REVISA,CNF_COMPET,"+ CRLF
cQuery += "    CASE WHEN CN9_SITUAC = '05' THEN CNF_VLPREV ELSE CNF_VLREAL END AS CNF_VLPREV,"+ CRLF
cQuery += "    CASE WHEN CN9_SITUAC = '05' THEN CNF_SALDO  ELSE 0 END AS CNF_SALDO, "+ CRLF
cQuery += "    CTT_DESC01, "+ CRLF
cQuery += "    CNA_NUMERO,CNA_XXMUN, "+ CRLF
cQuery += "    CND_NUMMED, "+ CRLF
cQuery += "    C6_NUM, "+ CRLF

// 18/11/14 - Campos XX_BONIF alterado de '2' para '1' e XX_MULTA alterado de '1' para '2'
cQuery += "    (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CND_NUMMED = CNR_NUMMED"+ CRLF
//cQuery += "         AND  CNR_FILIAL = '"+xFilial("CNR")+"' AND  CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '1') AS XX_BONIF,"+ CRLF
cQuery += "         AND  CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '1') AS XX_BONIF,"+ CRLF

cQuery += "    (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CND_NUMMED = CNR_NUMMED"+ CRLF
//cQuery += "         AND  CNR_FILIAL = '"+xFilial("CNR")+"' AND  CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2') AS XX_MULTA,"+ CRLF
cQuery += "         AND  CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2') AS XX_MULTA,"+ CRLF

cQuery += "    F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS, " + CRLF

cQuery += "    (SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "        AND SE1.D_E_L_E_T_ = ' ') AS XX_VENCTO, "+ CRLF

cQuery += "    (SELECT TOP 1 E1_VENCORI FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "        AND SE1.D_E_L_E_T_ = ' ') AS XX_VENCORI, "+ CRLF

cQuery += "    (SELECT TOP 1 E1_BAIXA FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "        AND SE1.D_E_L_E_T_ = ' ') AS XX_BAIXA, "+ CRLF

cQuery += "    (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "      AND SE5.D_E_L_E_T_ = ' ') AS XX_E5DESC, "+ CRLF
cQuery += "    (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "      AND SE5.D_E_L_E_T_ = ' ') AS XX_E5MULTA "+ CRLF

cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+ CRLF

cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09' "+ CRLF
cQuery += "      AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+ CRLF
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA"+ CRLF
cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CND_PARCEL = CNF_PARCEL AND CNA_NUMERO = CND_NUMERO AND CND_REVISA = CNF_REVISA"+ CRLF
cQuery += "      AND  CND.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM"+ CRLF
cQuery += "      AND  C6_FILIAL = CND_FILIAL AND SC6.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+ " SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND C6_PRODUTO = B1_COD"+ CRLF
cQuery += "      AND  SB1.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+ " SF2 ON C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC"+ CRLF
cQuery += "      AND  F2_FILIAL = CND_FILIAL AND SF2.D_E_L_E_T_ = ' '"+ CRLF
//cQuery += " WHERE CNF_COMPET = '"+cCompet+"'"

cQuery += " WHERE CNF_FILIAL = '"+xFilial("CNF")+"' AND  CNF.D_E_L_E_T_ = ' '"+ CRLF

IF nTipo == 1
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,6) = '"+cMes+"' "+ CRLF
ELSE
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,4) = '"+cMes+"' "+ CRLF
ENDIF

//cqContr:= "(SELECT TOP 1 C5_MDCONTR FROM "+RETSQLNAME("SC6")+ " SC6 INNER JOIN "+RETSQLNAME("SC5")+" SC5 ON C5_FILIAL = C6_FILIAL AND C6_NUM = C5_NUM AND C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ') "
//cqEspec:= "(SELECT TOP 1 C5_ESPECI1 FROM "+RETSQLNAME("SC6")+ " SC6 INNER JOIN "+RETSQLNAME("SC5")+" SC5 ON C5_FILIAL = C6_FILIAL AND C6_NUM = C5_NUM AND C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ') "

cQuery += " UNION ALL "+ CRLF

cQuery += " SELECT DISTINCT F2_FILIAL,F2_CLIENTE AS XX_CLIENTE,F2_LOJA AS XX_LOJA,   D2_COD AS XX_PROD,    B1_DESC,B1_CODISS,B1_ALIQISS,"+ CRLF
//cQuery += "        CASE WHEN "+cqEspec+" = ' ' THEN 'XXXXXXXXXX' ELSE "+cqEspec+" END,"+ CRLF  // CNF_CONTRA,
cQuery += "        CASE WHEN (C5_ESPECI1 = ' ' OR C5_ESPECI1 IS NULL) THEN 'XXXXXXXXXX' ELSE C5_ESPECI1 END AS CNF_CONTRA,"
cQuery += "        ' ',SUBSTRING(C5_XXCOMPT,1,2)+'/'+SUBSTRING(C5_XXCOMPT,3,4) AS CNF_COMPET,0,0, " + CRLF  // CNF_REVISA,CNF_COMPET,CNF_VLPREV,CNF_SALDO
cQuery += "        A1_NOME, "  + CRLF // CTT_DESC01
cQuery += "        ' ', CASE WHEN (C5_DESCMUN = ' ' OR C5_DESCMUN IS NULL) THEN SA1.A1_MUN ELSE C5_DESCMUN END AS CNA_XXMUN, " + CRLF  // CNA_NUMERO,CNA_XXMUN
cQuery += "        ' ', "  + CRLF     // CND_NUMMED
cQuery += "        D2_PEDIDO AS C6_NUM, " + CRLF   // C6_NUM
cQuery += "        0,0, "  + CRLF   // XX_BONIF,XX_MULTA
cQuery += "        F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS, " + CRLF
cQuery += "        (SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+" SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC" + CRLF
cQuery += "            AND SE1.D_E_L_E_T_ = ' ') AS XX_VENCTO, " + CRLF
cQuery += "        (SELECT TOP 1 E1_VENCORI FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC" + CRLF
cQuery += "            AND SE1.D_E_L_E_T_ = ' ') AS XX_VENCORI, " + CRLF
cQuery += "        (SELECT TOP 1 E1_BAIXA FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC" + CRLF
cQuery += "            AND SE1.D_E_L_E_T_ = ' ') AS XX_BAIXA, " + CRLF
cQuery += "        (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' "  + CRLF
cQuery += "            AND SE5.D_E_L_E_T_ = ' ') AS XX_E5DESC, " + CRLF
cQuery += "        (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "            AND SE5.D_E_L_E_T_ = ' ') AS XX_E5MULTA "+ CRLF

cQuery += " FROM "+RETSQLNAME("SF2")+" SF2" + CRLF
//cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = "+cqContr
//cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '""
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA" + CRLF
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SD2")+ " SD2 ON D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA" + CRLF
cQuery += "      AND  D2_FILIAL = '"+xFilial("SD2")+"' AND  SD2.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON C5_NUM = D2_PEDIDO " + CRLF
cQuery += "      AND  C5_FILIAL = D2_FILIAL AND  SD2.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+ " SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D2_COD = B1_COD"+ CRLF
cQuery += "      AND  SB1.D_E_L_E_T_ = ' '"+ CRLF
//cQuery += " LEFT JOIN "+RETSQLNAME("CC2")+ " CC2 ON SF2.F2_ESTPRES = CC2_EST AND SF2.F2_MUNPRES = CC2_CODMUN AND CC2.D_E_L_E_T_ = '' "+ CRLF

//cQuery += " WHERE ("+cqContr+" = ' ' OR " + CRLF
//cQuery +=           cqContr+" IS NULL ) " + CRLF
cQuery += " WHERE (C5_MDCONTR = ' ' OR "+ CRLF
cQuery +=         "C5_MDCONTR IS NULL ) "+ CRLF
IF nTipo == 1
	cQuery += "      AND SUBSTRING(F2_EMISSAO,1,6) = '"+cMes+"' " 
ELSE
	cQuery += "      AND SUBSTRING(F2_EMISSAO,1,4) = '"+cMes+"' " 
ENDIF

//cQuery += "      AND F2_FILIAL = '"+xFilial("SF2")+"' AND SF2.D_E_L_E_T_ = ' '" + CRLF
cQuery += "      AND SF2.D_E_L_E_T_ = ' '" + CRLF

cQuery += " ORDER BY CNF_CONTRA,CNF_REVISA,CNF_COMPET,F2_DOC" + CRLF

u_LogMemo("BKGCTR07.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","F2_EMISSAO","D",8,0)
TCSETFIELD("QTMP","XX_VENCTO","D",8,0)
TCSETFIELD("QTMP","XX_VENCORI","D",8,0)
TCSETFIELD("QTMP","XX_BAIXA","D",8,0)

//U_SendMail(PROCNAME(),PROCNAME(1),"marcos@rkainformatica.com.br","",cQuery,"",.F.)

/*
dbSelectArea("QTMP")
dbGoTop()
DO WHILE !EOF()


	dbSelectArea("QTMP")
	dbSkip()
ENDDO
*/


Return



Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Mes de Emissao  "  ,"" ,"" ,"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Ano de Emissao  "  ,"" ,"" ,"mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Gerar Planilha? "  ,"" ,"" ,"mv_ch3","N",01,0,2,"C","","mv_par03","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Tipo? "  ,"" ,"" ,"mv_ch4","N",01,0,2,"C","","mv_par04","Mensal","Mensal","Mensal","","","Anual","Anual","Anual","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegistros)
	If !MsSeek(cPerg+aRegistros[i,2])
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


USER FUNCTION BKCNR07(cNumMed,cTipo)
LOCAL cQuery,cMotivo := ""

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


//cQuery += "        (SELECT SUM(CNR_VALOR) FROM CNR010 CNR WHERE CND_NUMMED = CNR_NUMMED
//cQuery += "             AND  CNR_FILIAL = '"+xFilial("CNR")+"' AND  CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2') AS XX_MULTA,
//cQuery += " ORDER BY CNF_CONTRA,CNF_REVISA,CNF_COMPET,F2_DOC"  

                        
