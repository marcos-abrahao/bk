#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BKGCTR07 º Autor ³ Marcos B. Abrahão         Data ³05/05/11º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Mapa de INSS retido                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BKGCTR07()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := ""
Local nLin           := 80
Local lPula          := .F.
Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd           := {}
Local aTitulos,aCampos,aCabs

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := "G"
Private limite       := 220
Private tamanho      := " "
Private nomeprog     := "BKGCTR07" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "BKGCTR07"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "BKGCTR07" // Coloque aqui o nome do arquivo usado para impressao em disco
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

If .f. //nPlan = 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	   Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	            
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	nomeprog := "BKGCTR07/"+TRIM(SUBSTR(cUsuario,7,15))
	ProcRegua(1)
	Processa( {|| ProcQuery() })
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	
Else
	ProcRegua(1)
	Processa( {|| ProcQuery() })

	aCabs   := {}
	aCampos := {}
	aTitulos:= {}
   
	nomeprog := "BKGCTR07/"+TRIM(SUBSTR(cUsuario,7,15))
	AADD(aTitulos,nomeprog+" - "+titulo)

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

	IF FWCodEmp() == "12"  
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

	AADD(aCampos,"QTMP->F2_VALFAT - QTMP->F2_VALIRRF - QTMP->F2_VALINSS - QTMP->F2_VALPIS - QTMP->F2_VALCOFI - QTMP->F2_VALCSLL - IIF(QTMP->F2_RECISS = '1',QTMP->F2_VALISS,0) - QTMP->XX_E5DESC")
	AADD(aCabs  ,"Valor liquido")

	IF cMotMulta = "S"
		AADD(aCampos,"U_BKCNR07(QTMP->CND_NUMMED,'1')")
		AADD(aCabs  ,"Motivo Bonificação")

		AADD(aCampos,"U_BKCNR07(QTMP->CND_NUMMED,'2')")
		AADD(aCabs  ,"Motivo Multa")
	ENDIF

	ProcRegua(QTMP->(LASTREC()))
	Processa( {|| U_GeraCSV("QTMP",wnrel,aTitulos,aCampos,aCabs)})
   
EndIf	
Return


Static Function ProcQuery
Local cQuery,dDt

IncProc("Consultando o banco de dados...")

/*

SELECT CNF_CONTRA,CNF_REVISA,CNF_COMPET,CNF_VLPREV,CNF_SALDO,
         CTT_DESC01,
         CNA_NUMERO,CNA_XXMUN,
         CND_NUMMED,
         C6_NUM,
         (SELECT SUM(CNR_VALOR) FROM CNR010 CNR WHERE CND_NUMMED = CNR_NUMMED AND  CNR_FILIAL = '01' AND  CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '1') AS XX_BONIF,
         (SELECT SUM(CNR_VALOR) FROM CNR010 CNR WHERE CND_NUMMED = CNR_NUMMED AND  CNR_FILIAL = '01' AND  CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2') AS XX_MULTA,
         F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS
  FROM CNF010 CNF 
         INNER JOIN CN9010 CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9_SITUAC = '05' AND CN9_FILIAL = '01' AND  CN9.D_E_L_E_T_ = ' '
         LEFT  JOIN CTT010 CTT ON CTT_CUSTO  = CNF_CONTRA AND CTT_FILIAL = '01' AND  CTT.D_E_L_E_T_ = ' '
         LEFT  JOIN CNA010 CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA AND  CNA_FILIAL = '01' AND CNA.D_E_L_E_T_ = ' ' 
         LEFT  JOIN CND010 CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CNA_NUMERO = CND_NUMERO AND CND_PARCEL = CNF_PARCEL AND CND_REVISA = CNA_REVISA AND  CND_FILIAL = '01' AND  CND.D_E_L_E_T_ = ' '
         LEFT  JOIN SC6010 SC6 ON CND_PEDIDO = C6_NUM     AND C6_FILIAL  = '01'  AND  SC6.D_E_L_E_T_ = ' ' 
         LEFT  JOIN SF2010 SF2 ON C6_SERIE   = F2_SERIE   AND C6_NOTA    = F2_DOC  AND  F2_FILIAL = '01'  AND  SF2.D_E_L_E_T_ = ' '
  WHERE CNF_COMPET = '05/2010' AND  CNF_FILIAL = '01' AND  CNF.D_E_L_E_T_ = ' ' 
  UNION ALL  
  SELECT 'XXXXXXXXX',' ',' ',0,0,         A1_NOME,         ' ',' ',         ' ',         ' ',         0,0,         
         F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS  
  FROM SF2010 SF2 
         LEFT JOIN SA1010 SA1 ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA  AND  A1_FILIAL = '  ' AND  SA1.D_E_L_E_T_ = ' ' 
         WHERE ((SELECT TOP 1 C5_MDCONTR FROM SC6010 SC6 INNER JOIN SC5010 SC5 ON C6_FILIAL = '01' AND C5_FILIAL = C6_FILIAL AND C6_NUM = C5_NUM AND C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ')  = ' ' OR
                (SELECT TOP 1 C5_MDCONTR FROM SC6010 SC6 INNER JOIN SC5010 SC5 ON C6_FILIAL = '01' AND C5_FILIAL = C6_FILIAL AND C6_NUM = C5_NUM AND C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ')  IS NULL ) AND
                SUBSTRING(F2_EMISSAO,1,6) = 201006 AND F2_FILIAL = '01' AND SF2.D_E_L_E_T_ = ' ' 
  
  ORDER BY CNF_CONTRA,CNF_REVISA,CNF_COMPET,F2_DOC

CASE WHEN C5_XXPROMO = 'S' THEN (D2_QUANT*2) ELSE D2_QUANT END AS XX_QTDPLAN
*/

cQuery := " SELECT DISTINCT CN9_CLIENT AS XX_CLIENTE,CN9_LOJACL AS XX_LOJA,CNF_CONTRA,CNF_REVISA,CNF_COMPET,"
cQuery += "    CASE WHEN CN9_SITUAC = '05' THEN CNF_VLPREV ELSE CNF_VLREAL END AS CNF_VLPREV,"
cQuery += "    CASE WHEN CN9_SITUAC = '05' THEN CNF_SALDO  ELSE 0 END AS CNF_SALDO, "
cQuery += "    CTT_DESC01, "
cQuery += "    CNA_NUMERO,CNA_XXMUN, "
cQuery += "    CND_NUMMED, "
cQuery += "    C6_NUM, "

// 18/11/14 - Campos XX_BONIF alterado de '2' para '1' e XX_MULTA alrterado de '1' para '2'
cQuery += "    (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CND_NUMMED = CNR_NUMMED"
cQuery += "         AND  CNR_FILIAL = '"+xFilial("CNR")+"' AND  CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '1') AS XX_BONIF,"

cQuery += "    (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CND_NUMMED = CNR_NUMMED"
cQuery += "         AND  CNR_FILIAL = '"+xFilial("CNR")+"' AND  CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2') AS XX_MULTA,"

cQuery += "    F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS, " 

cQuery += "    (SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"
cQuery += "        AND  E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' ') AS XX_VENCTO, "

cQuery += "    (SELECT TOP 1 E1_VENCORI FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"
cQuery += "        AND  E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' ') AS XX_VENCORI, "

cQuery += "    (SELECT TOP 1 E1_BAIXA FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"
cQuery += "        AND  E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' ') AS XX_BAIXA, "

cQuery += "    (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " 
cQuery += "      AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = ' ') AS XX_E5DESC "

cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"

cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9_SITUAC <> '10' "
cQuery += "      AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA"
cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CND_PARCEL = CNF_PARCEL AND CNA_NUMERO = CND_NUMERO AND CND_REVISA = CNF_REVISA"
cQuery += "      AND  CND_FILIAL = '"+xFilial("CND")+"' AND  CND.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM"
cQuery += "      AND  C6_FILIAL = '"+xFilial("SC6")+"'  AND  SC6.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+ " SF2 ON C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC"
cQuery += "      AND  F2_FILIAL = '"+xFilial("SF2")+"'  AND  SF2.D_E_L_E_T_ = ' '"

//cQuery += " WHERE CNF_COMPET = '"+cCompet+"'"

cQuery += " WHERE CNF_FILIAL = '"+xFilial("CNF")+"' AND  CNF.D_E_L_E_T_ = ' '"

IF nTipo == 1
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,6) = '"+cMes+"' "
ELSE
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,4) = '"+cMes+"' "
ENDIF

cqContr:= "(SELECT TOP 1 C5_MDCONTR FROM "+RETSQLNAME("SC6")+ " SC6 INNER JOIN "+RETSQLNAME("SC5")+" SC5 ON C6_FILIAL = '"+xFilial("SC6")+ "' AND C5_FILIAL = C6_FILIAL AND C6_NUM = C5_NUM AND C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ') "
cqEspec:= "(SELECT TOP 1 C5_ESPECI1 FROM "+RETSQLNAME("SC6")+ " SC6 INNER JOIN "+RETSQLNAME("SC5")+" SC5 ON C6_FILIAL = '"+xFilial("SC6")+ "' AND C5_FILIAL = C6_FILIAL AND C6_NUM = C5_NUM AND C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ') "


cQuery += " UNION ALL "
cQuery += " SELECT DISTINCT F2_CLIENTE AS XX_CLIENTE,F2_LOJA AS XX_LOJA,"
cQuery += "        CASE WHEN "+cqEspec+" = ' ' THEN 'XXXXXXXXXX' ELSE "+cqEspec+" END,"
cQuery += "        ' ',' ',0,0, "  // CNF_CONTRA,CNF_REVISA,CNF_COMPET,CNF_VLPREV,CNF_SALDO
cQuery += "        A1_NOME, "  // CTT_DESC01
cQuery += "        ' ',' ', "  // CNA_NUMERO,CNA_XXMUN
cQuery += "        ' ', "      // CND_NUMMED
cQuery += "        ' ', "      // C6_NUM
cQuery += "        0,0, "      // XX_BONIF,XX_MULTA
cQuery += "        F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS, " 
cQuery += "        (SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+" SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"
cQuery += "            AND  E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' ') AS XX_VENCTO, "
cQuery += "        (SELECT TOP 1 E1_VENCORI FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"
cQuery += "            AND  E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' ') AS XX_VENCORI, "
cQuery += "        (SELECT TOP 1 E1_BAIXA FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"
cQuery += "            AND  E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' ') AS XX_BAIXA, "
cQuery += "        (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " 
cQuery += "            AND  E5_FILIAL = '"+xFilial("SE5")+"'  AND  SE5.D_E_L_E_T_ = ' ') AS XX_E5DESC "

cQuery += " FROM "+RETSQLNAME("SF2")+" SF2"
//cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = "+cqContr
//cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '""
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA"
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"
cQuery += " WHERE ("+cqContr+" = ' ' OR "
cQuery +=           cqContr+" IS NULL ) "
IF nTipo == 1
	cQuery += "      AND SUBSTRING(F2_EMISSAO,1,6) = '"+cMes+"' " 
ELSE
	cQuery += "      AND SUBSTRING(F2_EMISSAO,1,4) = '"+cMes+"' " 
ENDIF

cQuery += "      AND F2_FILIAL = '"+xFilial("SF2")+"' AND SF2.D_E_L_E_T_ = ' '"

//cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = C6_CONTRA"
//cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '""

//cQuery += " ORDER BY F2_DOC"  

cQuery += " ORDER BY CNF_CONTRA,CNF_REVISA,CNF_COMPET,F2_DOC"  

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","F2_EMISSAO","D",8,0)
TCSETFIELD("QTMP","XX_VENCTO","D",8,0)
TCSETFIELD("QTMP","XX_VENCORI","D",8,0)
TCSETFIELD("QTMP","XX_BAIXA","D",8,0)

memowrite("\tmp\bkgctr07.sql",cQuery)
                             
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

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  08/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local nOrdem,lCabec

Dbselectarea("QTMP")
Dbgotop()

SetRegua(RecCount())

nEsp    := 2
cPicVlr := "@E 9,999,999.99"

Cabec1  := PAD("Banco",LEN(QTMP->Z2_BANCO)+nEsp)
Cabec1  += PAD("Nome",LEN(QTMP->Z2_NOME)+nEsp)
Cabec1  += PAD("Agencia",LEN(QTMP->Z2_AGENCIA)+LEN(QTMP->Z2_DIGAGEN)+1+nEsp)
Cabec1  += PAD("Conta",LEN(QTMP->Z2_CONTA)+LEN(QTMP->Z2_DIGCONT)+1+nEsp)
Cabec1  += PAD("Tipo",LEN(QTMP->Z2_TIPO)+nEsp)
Cabec1  += PAD("T.Pes.",LEN(QTMP->Z2_TIPOPES)+nEsp)
Cabec1  += PAD("Titulo",LEN(QTMP->E2_NUM)+nEsp)
Cabec1  += PAD("Usuario",20+nEsp)
Cabec1  += PAD("CtrId",LEN(QTMP->Z2_CTRID)+nEsp)
Cabec1  += PADL("Valor",LEN(cPicVlr)-3)+SPACE(nEsp)

IF LEN(Cabec1) > 132
   Tamanho := "G"
ENDIF   

Dbselectarea("QTMP")
Dbgotop()
SetRegua(RecCount())        

cBanco := QTMP->Z2_BANCO
nPos1  := nPos2 := nPos3 := nCont := 0
nTotTP := nTotBc := nTotG := 0

DO While !QTMP->(EOF())

   cTipoPes := QTMP->Z2_TIPOPES
   nTotTP   := 0

   //If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo+" Tipo Pes: "+cTipoPes,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
      lCabec := .T. 
      //@ nLin,0 PSAY TRIM(QTMP->C6_PRODUTO) + " - " +  Posicione("SB1",1,xFilial("SB1")+QTMP->C6_PRODUTO,"B1_DESC")
      //nLin += 2
   //Endif
   
   
   DO While !QTMP->(EOF()) .AND. cTipoPes == QTMP->Z2_TIPOPES
       IF !lCabec
         Cabec(Titulo+" Tipo Pes: "+cTipoPes,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
         nLin   := 9
         lCabec := .T. 
       ENDIF
       cBanco := QTMP->Z2_BANCO
       nTotBc := 0

	   nPos1  := 0
	   @ nLin,nPos1 PSAY QTMP->Z2_BANCO
	   nPos1  := PCOL()+nEsp

	   DO While !QTMP->(EOF()) .AND. cBanco == QTMP->Z2_BANCO .AND. cTipoPes == QTMP->Z2_TIPOPES
		  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  //³ Impressao do cabecalho do relatorio. . .                            ³
		  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		  IncRegua()
	      If lAbortPrint
			 @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			 QTMP->(DBGOBOTTOM())
			 dbSkip()
		     Exit
	      Endif
	      If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
	         Cabec(Titulo+" Tipo Pes: "+cTipoPes,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	         nLin := 9 
	         @ nLin,0 PSAY cBanco
	      Endif
	
	      @ nLin,nPos1 PSAY QTMP->Z2_NOME
	      nPos2  := PCOL()+nEsp
	      
	      @ nLin,nPos2 PSAY PAD(TRIM(QTMP->Z2_AGENCIA)+'-'+TRIM(QTMP->Z2_DIGAGEN),LEN(QTMP->Z2_AGENCIA)+LEN(QTMP->Z2_DIGAGEN)+1)
	      nPos2  := PCOL()+nEsp
	
	      @ nLin,nPos2 PSAY PAD(TRIM(QTMP->Z2_CONTA)+'-'+TRIM(QTMP->Z2_DIGCONTA),LEN(QTMP->Z2_CONTA)+LEN(QTMP->Z2_DIGCONTA)+1)
	      nPos2  := PCOL()+nEsp
	
	      @ nLin,nPos2 PSAY QTMP->Z2_TIPO
	      nPos2  := PCOL()+nEsp
	
	      @ nLin,nPos2 PSAY QTMP->Z2_TIPOPES
	      nPos2  := PCOL()+nEsp
	
	      @ nLin,nPos2 PSAY QTMP->E2_NUM
	      nPos2  := PCOL()+nEsp
	
	      @ nLin,nPos2 PSAY PAD(QTMP->Z2_USUARIO,20)
	      nPos2  := PCOL()+nEsp

	      @ nLin,nPos2 PSAY PAD(QTMP->Z2_CTRID,20)
	      nPos2  := PCOL()+nEsp
	      
	      @ nLin,nPos2 PSAY QTMP->Z2_VALOR PICTURE cPicVlr
	      nPos3  := nPos2
	      nPos2  := PCOL()+nEsp
	
	      nCont++
	      nLin++
	      
	      nTotBc += QTMP->Z2_VALOR
	      nTotTP += QTMP->Z2_VALOR
	      nTotG  += QTMP->Z2_VALOR
	
	      dbSkip()
	  ENDDO
	  IF nPos3 > 0
	    nLin++
	    @ nLin,nPos3-22 PSAY "TOTAL DO BANCO "+cBanco
	    @ nLin,nPos3 PSAY nTotBc PICTURE cPicVlr 
	    nLin+=2
	  ENDIF
      lCabec := .F.
  ENDDO
  IF nPos3 > 0
    @ nLin,nPos3-22 PSAY "TOTAL "+cTipoPes
    @ nLin,nPos3 PSAY nTotTP PICTURE cPicVlr 
    nLin++
  ENDIF
  
  nLin++
ENDDO

/*  Removido o total geral
nLin++
IF nPos3 > 0
   @ nLin,0 PSAY "TOTAL GERAL"
   @ nLin,nPos3 PSAY nTotG PICTURE cPicVlr 
ENDIF
*/


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

QTMP->(Dbclosearea())

Return


Static Function  ValidPerg

Local aArea      := GetArea()
Local aRegistros := {}
cPerg := "BKGCTR07"
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Mes de Emissao  "  ,"" ,"" ,"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Ano de Emissao  "  ,"" ,"" ,"mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Gerar Planilha? "  ,"" ,"" ,"mv_ch3","N",01,0,2,"C","","mv_par03","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Tipo? "  ,"" ,"" ,"mv_ch4","N",01,0,2,"C","","mv_par04","Mensal","Mensal","Mensal","","","Anual","Anual","Anual","","","","","","","","","","","","","","","","",""})

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

                        
