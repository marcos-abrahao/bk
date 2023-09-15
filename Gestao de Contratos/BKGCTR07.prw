#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR07()
BK - Mapa de INSS retido

@author Marcos B. Abrahão
@since 05/05/11 rev 17/06/20
@version P12
@return Nil
/*/

Static aRecNo := {}
Static aChave := {}

User Function BKGCTR07()

Local cMes			:= ""
Local nTipo 		:= 1
Local titulo        := ""
Local aTitulos,aCampos,aCabs
//Local aPlans		:= {}

Private cPerg       := "BKGCTR07"
Private cString     := "CN9"

Private cMesEmis    := "01"
Private cAnoEmis    := "2011"
Private nPlan       := 1

Private _cTXPIS  	:= STR(GetMv("MV_TXPIS"))
Private _cTXCOF  	:= STR(GetMv("MV_TXCOFINS"))

Public XX_PESSOA    := ""
Public cMotMulta    := "N"
Private nValPrev	:= 0

dbSelectArea('SZR')

dbSelectArea('SA1')
dbSelectArea(cString)
dbSetOrder(1)

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
Endif
//u_MsgLog(cPerg) 

cMesEmis := mv_par01
cAnoEmis := mv_par02
//cCompet  := cMesEmis+"/"+cAnoEmis
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

u_WaitLog(cPerg,{|oSay| PrcGct07(nTipo,cMes) }, titulo)

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

AADD(aCampos,"X3COMBO('CNA_FLREAJ',QTMP->CNA_FLREAJ)")
AADD(aCabs  ,"Reajuste")

AADD(aCampos,"QTMP->CNF_COMPET")
AADD(aCabs  ,"Competencia")

AADD(aCampos,"QTMP->CXN_PARCEL")
AADD(aCabs  ,"Parcela")

AADD(aCampos,"QTMP->CND_XXRM")
AADD(aCabs  ,"RM")

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

AADD(aCampos,"QTMP->F2_SERIE")
AADD(aCabs  ,"Série NF")

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

//AADD(aCampos,"QTMP->CNF_VLPREV")
//AADD(aCabs  ,"Valor Previsto")

//AADD(aCampos,"nValPrev := U_GCTR7VP(QTMP->CNFRECNO,QTMP->CNF_VLPREV)")
AADD(aCampos,"nValPrev := U_GCTR7VPn(QTMP->(CNF_CONTRA+CNF_REVISA+CNA_NUMERO+CNF_COMPET+CXN_PARCEL),QTMP->CNF_VLPREV)")
AADD(aCabs  ,"Valor Previsto")

//AADD(aCampos,"QTMP->CNF_SALDO")
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

IF FWCodEmp() == "12"  .OR. FWCodEmp() == "02"
	AADD(aCampos,"VAL(STR(((QTMP->F2_VALFAT*0.32)*0.15),14,02))")
	AADD(aCabs  ,"IRPJ Apuração")
	
	AADD(aCampos,"VAL(STR(QTMP->F2_VALFAT*("+ALLTRIM(_cTXPIS)+"/100),14,02))")
	AADD(aCabs  ,"PIS Apuração")
	
	AADD(aCampos,"VAL(STR(QTMP->F2_VALFAT*("+ALLTRIM(_cTXCOF)+"/100),14,02))")
	AADD(aCabs  ,"COFINS Apuração")
	
	AADD(aCampos,"VAL(STR(((QTMP->F2_VALFAT*0.32)*0.09),14,02))")
	AADD(aCabs  ,"CSLL Apuração")
ELSE
	AADD(aCampos,"F2_VALIMP6")
	AADD(aCabs  ,"PIS Apuração")
	
	AADD(aCampos,"F2_VALIMP5")
	AADD(aCabs  ,"COFINS Apuração")
ENDIF

AADD(aCampos,"QTMP->D2_ALQIRRF")
AADD(aCabs  ,"IRRF%")

AADD(aCampos,"QTMP->F2_VALIRRF")
AADD(aCabs  ,"IRRF Retido")

AADD(aCampos,"QTMP->D2_ALIQINS")
AADD(aCabs  ,"INSS%")

AADD(aCampos,"QTMP->F2_VALINSS")
AADD(aCabs  ,"INSS Retido")

AADD(aCampos,"QTMP->F2_VALPIS")
AADD(aCabs  ,"PIS Retido")

AADD(aCampos,"QTMP->F2_VALCOFI")
AADD(aCabs  ,"COFINS Retido")

AADD(aCampos,"QTMP->F2_VALCSLL")
AADD(aCabs  ,"CSLL Retido")

AADD(aCampos,"IIF(QTMP->F2_RECISS <> '1',QTMP->F2_VALISS,0)")
AADD(aCabs  ,"ISS Apurado")

AADD(aCampos,"IIF(QTMP->F2_RECISS = '1',QTMP->F2_VALISS,0)")
AADD(aCabs  ,"ISS Retido")

AADD(aCampos,"QTMP->F2_VLCPM")
AADD(aCabs  ,"ISS Bitrib")

AADD(aCampos,"QTMP->XX_ISSBI")
AADD(aCabs  ,"ISS Bitrib Indevidamente")

AADD(aCampos,"QTMP->F2_XXVCVIN")
AADD(aCabs  ,"Cta. Vinculada")

AADD(aCampos,"QTMP->F2_XXVRETC")
AADD(aCabs  ,"Ret. Contratual")

AADD(aCampos,"QTMP->F2_VALFAT - QTMP->F2_VALIRRF - QTMP->F2_VALINSS - QTMP->F2_VALPIS - QTMP->F2_VALCOFI - QTMP->F2_VALCSLL - IIF(QTMP->F2_RECISS = '1',QTMP->F2_VALISS,0) - QTMP->F2_VLCPM - QTMP->XX_E5DESC + QTMP->XX_E5MULTA - QTMP->F2_XXVRETC - QTMP->F2_XXVCVIN")

AADD(aCabs  ,"Valor liquido")

IF cMotMulta = "S"
	AADD(aCampos,"U_BKCNR07(QTMP->CND_NUMMED,'2')")
	AADD(aCabs  ,"Motivo Bonificação")

	AADD(aCampos,"U_BKCNR07(QTMP->CND_NUMMED,'1')")
	AADD(aCabs  ,"Motivo Multa")
ENDIF

U_GeraCSV("QTMP",cPerg,aTitulos,aCampos,aCabs)

//AADD(aPlans,{"QTMP",cPerg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, .T. })
//U_PlanXlsx(aPlans,"",cPerg, .T.,)

Return


Static Function PrcGct07(nTipo,cMes)
Local cQuery := ""

cQuery := u_QGctR07(nTipo,cMes,cMes)
cQuery += " ORDER BY CNF_CONTRA,CNF_REVISA,CNF_COMPET,F2_SERIE,F2_DOC" + CRLF

u_LogMemo("BKGCTR07.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","F2_EMISSAO","D",8,0)
TCSETFIELD("QTMP","XX_VENCTO","D",8,0)
TCSETFIELD("QTMP","XX_VENCORI","D",8,0)
TCSETFIELD("QTMP","XX_BAIXA","D",8,0)

Return Nil


// Usada nas rotinas BKGCTR07 e BKCOMA13
User Function QGctR07(nTipo,cMes,cMesF)
Local cQuery as Character
//Local cRevAtu := Space(GetSx3Cache("CN9_REVATU","X3_TAMANHO"))

Local cJCNDCNE:= FWJoinFilial("CND", "CNE")
Local cJCXNCNE:= FWJoinFilial("CXN", "CNE")
//Local cJCN1CN9:= FWJoinFilial("CN1", "CN9")
//Local cJCNACN9:= FWJoinFilial("CNA", "CN9")
Local cJSC5CNE:= FWJoinFilial("SC5", "CNE")
Local cJSC6CNE:= FWJoinFilial("SC6", "CNE")
//Local cJSC6SC5:= FWJoinFilial("SC6", "SC5")
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
cQuery += "   F2_FILIAL," + CRLF 
cQuery += "   D2_CLIENTE AS XX_CLIENTE," + CRLF 
cQuery += "   D2_LOJA XX_LOJA," + CRLF 
cQuery += "   D2_ALIQINS," + CRLF 
cQuery += "   D2_ALQIRRF," + CRLF 
cQuery += "   C6_PRODUTO AS XX_PROD," + CRLF 
cQuery += "   B1_DESC," + CRLF 
cQuery += "   B1_CODISS," + CRLF 
cQuery += "   B1_ALIQISS," + CRLF 
cQuery += "   CNF_CONTRA," + CRLF 
cQuery += "   CNF_REVISA," + CRLF 
cQuery += "   CNF_COMPET," + CRLF 
cQuery += "   (CASE WHEN CN9_SITUAC = '05' THEN CNF_VLPREV ELSE CNF_VLREAL END) AS CNF_VLPREV," + CRLF 
cQuery += "   (CASE WHEN CN9_SITUAC = '05' THEN CNF_SALDO  ELSE 0 END) AS CNF_SALDO," + CRLF 
cQuery += "   CTT_DESC01," + CRLF 
cQuery += "   CNA_NUMERO," + CRLF 
cQuery += "   CNA_XXMUN," + CRLF 
cQuery += "   CNA_FLREAJ," + CRLF 
cQuery += "   CND_NUMMED," + CRLF 
//cQuery += "   CNF.R_E_C_N_O_ AS CNFRECNO," + CRLF 
cQuery += "   ISNULL(CXN_PARCEL,CND_PARCEL) AS CXN_PARCEL," + CRLF 
cQuery += "   (CASE WHEN CND_XXRM = ' ' THEN CXN_XXRM ELSE CND_XXRM END) AS CND_XXRM," + CRLF 
cQuery += "   C6_NUM," + CRLF 
cQuery += "   (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CNR_NUMMED = CNE_NUMMED AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))" + CRLF    // AND CNR_CODPLA = CNE_NUMERO
cQuery += "   	AND CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2') AS XX_BONIF," + CRLF 
cQuery += "   (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CNR_NUMMED = CNE_NUMMED AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))" + CRLF    // AND CNR_CODPLA = CNE_NUMERO
cQuery += "   	AND  CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '1') AS XX_MULTA," + CRLF 
cQuery += "   F2_SERIE," + CRLF 
cQuery += "   F2_DOC," + CRLF 
cQuery += "   F2_EMISSAO," + CRLF 
cQuery += "   F2_VALFAT," + CRLF 
cQuery += "   F2_VALIRRF," + CRLF 
cQuery += "   F2_VALINSS," + CRLF 
cQuery += "   F2_VALPIS," + CRLF 
cQuery += "   F2_VALCOFI," + CRLF 
cQuery += "   F2_VALCSLL," + CRLF 
cQuery += "   F2_RECISS," + CRLF 
cQuery += "   F2_VALISS," + CRLF 
cQuery += "   F2_VLCPM," + CRLF 
cQuery += "   F2_VALIMP6," + CRLF 
cQuery += "   F2_VALIMP5," + CRLF 
cQuery += "   F2_XXVRETC," + CRLF 
cQuery += "   F2_XXVCVIN," + CRLF 

cQuery += "   (SELECT TOP 1 E1_XXISSBI FROM "+RETSQLNAME("SE1") + " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC AND E1_TIPO = 'NF'"+ CRLF
cQuery += "   	  AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"   + xFilial("SE1")+"') AS XX_ISSBI, " + CRLF
cQuery += "   (SELECT TOP 1 E1_VENCTO  FROM "+RETSQLNAME("SE1") + " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC AND E1_TIPO = 'NF'" + CRLF
cQuery += "       AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"   + xFilial("SE1")+"') AS XX_VENCTO, " + CRLF
cQuery += "   (SELECT TOP 1 E1_VENCORI FROM "+RETSQLNAME("SE1") + " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC AND E1_TIPO = 'NF'" + CRLF
cQuery += "       AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"   + xFilial("SE1")+"') AS XX_VENCORI, " + CRLF
cQuery += "   (SELECT TOP 1 E1_BAIXA   FROM "+RETSQLNAME("SE1") + " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC AND E1_TIPO = 'NF'" + CRLF
cQuery += "       AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"   + xFilial("SE1")+"') AS XX_BAIXA, " + CRLF

cQuery += "   (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " + CRLF
cQuery += "   	AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5DESC, " + CRLF
cQuery += "   (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " + CRLF
cQuery += "   	AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5MULTA" + CRLF

cQuery += " FROM "+RETSQLNAME("CNE")+" CNE" + CRLF

cQuery += " INNER JOIN "+RETSQLNAME("SC5")+" SC5" + CRLF
cQuery += " 	ON (C5_NUM = CNE_PEDIDO AND C5_MDNUMED = CNE_NUMMED AND C5_MDPLANI = CNE_NUMERO AND C5_XXREV = CNE_REVISA" + CRLF
cQuery += " 		AND "+cJSC5CNE+" AND SC5.D_E_L_E_T_='')" + CRLF

cQuery += " INNER JOIN "+RETSQLNAME("CND")+" CND" + CRLF
cQuery += " 	ON (CND_NUMMED = CNE_NUMMED AND CND_CONTRA = CNE_CONTRA AND CND_REVISA = C5_XXREV " +CRLF  //CNE_REVISA
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
cQuery += " 	 	AND CN9.D_E_L_E_T_='')" + CRLF
//cQuery += " 	 	AND CN9_FILIAL = CND_FILCTR AND CN9.D_E_L_E_T_='')" + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CNF")+" CNF" + CRLF
cQuery += " 	ON (CNE_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CNE_NUMERO = CNF_NUMPLA AND C5_XXREV = CNF_REVISA" +CRLF   //CNE_REVISA = CNF_REVISA
cQuery += " 	    AND CNF_PARCEL = ISNULL(CXN_PARCEL,CND_PARCEL)" + CRLF
cQuery += " 	 	AND CNF_FILIAL = '01' AND CNF.D_E_L_E_T_='')" + CRLF

//cQuery += " INNER JOIN "+RETSQLNAME("CN1")+" CN1" + CRLF
//cQuery += " 	ON (CN1_CODIGO = CN9_TPCTO AND CN1_ESPCTR IN ('2')" + CRLF
//cQuery += " 		AND "+cJCN1CN9+" AND CN1.D_E_L_E_T_='')" + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+" CNA" + CRLF
cQuery += " 	ON (CNA_CONTRA = CNE_CONTRA AND CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA AND CNA_NUMERO = CNF_NUMPLA" +CRLF
cQuery += " 		AND CNA_FILIAL = CND_FILCTR AND CNA.D_E_L_E_T_='')"+CRLF // CNE_CONTRA

//cQuery += " INNER JOIN "+RETSQLNAME("SC5")+" SC5" + CRLF
//cQuery += " 	ON (C5_MDNUMED = CNE_NUMMED AND C5_MDPLANI = CNE_NUMERO" + CRLF
//cQuery += " 		AND "+cJSC5CNE+" AND SC5.D_E_L_E_T_='')" + CRLF

//cQuery += " INNER JOIN "+RETSQLNAME("SC6")+" SC6" + CRLF
//cQuery += " 	ON (C5_CLIENT = C6_CLI AND C5_LOJACLI = C6_LOJA AND C6_NUM = C5_NUM AND C6_ITEMED = CNE_ITEM" +CRLF
//cQuery += " 		AND "+cJSC6SC5+" AND SC6.D_E_L_E_T_='')" + CRLF

cQuery += " INNER JOIN "+RETSQLNAME("SC6")+" SC6" + CRLF
cQuery += " 	ON (C6_NUM = CNE_PEDIDO AND C6_ITEMED = CNE_ITEM" +CRLF
cQuery += " 		AND "+cJSC6CNE+" AND SC6.D_E_L_E_T_='')" + CRLF

cQuery += " INNER JOIN "+RETSQLNAME("SD2")+" SD2" + CRLF
//cQuery += " 	ON (D2_PEDIDO = C6_NUM AND D2_ITEMPV = C6_ITEM AND C5_CLIENT = D2_CLIENTE AND D2_LOJA = C5_LOJACLI" +CRLF
cQuery += " 	ON (D2_PEDIDO = C6_NUM AND D2_ITEMPV = C6_ITEM" +CRLF
cQuery += " 		AND "+cJSD2SC6+" AND SD2.D_E_L_E_T_='')" + CRLF

cQuery += " INNER JOIN "+RETSQLNAME("SF2")+" SF2" + CRLF
cQuery += " 	ON (C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND F2_CLIENTE = C6_CLI AND F2_LOJA = C6_LOJA AND F2_TIPO = 'N' AND F2_FORMUL = ' '" + CRLF
cQuery += " 		AND "+cJSF2SC6+" AND SF2.D_E_L_E_T_='')" + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+" SB1" + CRLF
cQuery += " 	ON (C6_PRODUTO = B1_COD" +CRLF
cQuery += " 		AND B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.D_E_L_E_T_='')"+CRLF

cQuery += " WHERE CNE.D_E_L_E_T_ = ' '"+ CRLF
//cQuery += "     AND CNE_FILIAL = '"+xFilial("CNE")+"'" Removido para co
///cQuery += " 	AND CN9.CN9_REVATU = '"+cRevAtu+"'"+ CRLF
// CN9->CN9_SITUAC <> '10' .AND. CN9->CN9_SITUAC <> '09'
IF nTipo == 1
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,6) = '"+cMes+"' "+ CRLF
ELSEIF nTipo == 2
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,4) = '"+cMes+"' "+ CRLF
ELSE
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,6) >= '"+cMes+"' "+ CRLF
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,6) <= '"+cMesF+"' "+ CRLF
ENDIF

cQuery += " UNION ALL "+ CRLF

cQuery += " SELECT DISTINCT" + CRLF 
cQuery += "   F2_FILIAL," + CRLF 
cQuery += "   F2_CLIENTE AS XX_CLIENTE," + CRLF 
cQuery += "   F2_LOJA AS XX_LOJA," + CRLF 
cQuery += "   D2_ALIQINS," + CRLF 
cQuery += "   D2_ALQIRRF," + CRLF 
cQuery += "   D2_COD AS XX_PROD," + CRLF 
cQuery += "   B1_DESC," + CRLF 
cQuery += "   B1_CODISS," + CRLF 
cQuery += "   B1_ALIQISS," + CRLF 
cQuery += "   CASE WHEN (C5_ESPECI1 = ' ' OR C5_ESPECI1 IS NULL) THEN 'XXXXXXXXXX' ELSE C5_ESPECI1 END AS CNF_CONTRA," + CRLF 
cQuery += "   ' '," + CRLF // CNF_REVISA
cQuery += "   SUBSTRING(C5_XXCOMPT,1,2)+'/'+SUBSTRING(C5_XXCOMPT,3,4) AS CNF_COMPET," + CRLF //CNF_COMPET 
cQuery += "   0," + CRLF  // CNF_VLPREV
cQuery += "   0," + CRLF  // CNF_SALDO
cQuery += "   A1_NOME," + CRLF // CTT_DESC01
cQuery += "   ' '," + CRLF // CNA_NUMERO
cQuery += "   CASE WHEN (C5_DESCMUN = ' ' OR C5_DESCMUN IS NULL) THEN SA1.A1_MUN ELSE C5_DESCMUN END AS CNA_XXMUN, " + CRLF  // CNA_XXMUN
cQuery += "   ' '," + CRLF // CNA_FLREAJ
cQuery += "   ' '," + CRLF // CND_NUMMED
//cQuery += "   0 AS CNFRECNO," + CRLF // CNF.R_E_C_N_O_
cQuery += "   ' '," + CRLF // CXN_PARCEL
cQuery += "   C5_XXRM," + CRLF 
cQuery += "   C5_NUM AS C6_NUM," + CRLF 
cQuery += "   0," + CRLF // XX_BONIF
cQuery += "   0," + CRLF // XX_MULTA
cQuery += "   F2_SERIE," + CRLF 
cQuery += "   F2_DOC," + CRLF 
cQuery += "   F2_EMISSAO," + CRLF 
cQuery += "   F2_VALFAT," + CRLF 
cQuery += "   F2_VALIRRF," + CRLF 
cQuery += "   F2_VALINSS," + CRLF 
cQuery += "   F2_VALPIS," + CRLF 
cQuery += "   F2_VALCOFI," + CRLF 
cQuery += "   F2_VALCSLL," + CRLF 
cQuery += "   F2_RECISS," + CRLF 
cQuery += "   F2_VALISS," + CRLF 
cQuery += "   F2_VLCPM," + CRLF 
cQuery += "   F2_VALIMP6," + CRLF 
cQuery += "   F2_VALIMP5," + CRLF 
cQuery += "   F2_XXVRETC," + CRLF 
cQuery += "   F2_XXVCVIN," + CRLF 

cQuery += "   (SELECT TOP 1 E1_XXISSBI FROM "+RETSQLNAME("SE1") + " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC AND E1_TIPO = 'NF'"+ CRLF
cQuery += "   	  AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"   + xFilial("SE1")+"') AS XX_ISSBI, " + CRLF
cQuery += "   (SELECT TOP 1 E1_VENCTO  FROM "+RETSQLNAME("SE1") + " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC AND E1_TIPO = 'NF'" + CRLF
cQuery += "       AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"   + xFilial("SE1")+"') AS XX_VENCTO, " + CRLF
cQuery += "   (SELECT TOP 1 E1_VENCORI FROM "+RETSQLNAME("SE1") + " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC AND E1_TIPO = 'NF'" + CRLF
cQuery += "       AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"   + xFilial("SE1")+"') AS XX_VENCORI, " + CRLF
cQuery += "   (SELECT TOP 1 E1_BAIXA   FROM "+RETSQLNAME("SE1") + " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC AND E1_TIPO = 'NF'" + CRLF
cQuery += "       AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"   + xFilial("SE1")+"') AS XX_BAIXA, " + CRLF

cQuery += "   (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' "  + CRLF
cQuery += "       AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5DESC, " + CRLF
cQuery += "   (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " + CRLF
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
cQuery += " WHERE (C5_MDCONTR = ' ' OR C5_MDCONTR IS NULL)"+ CRLF
cQuery += "      AND C5_NUM IS NOT NULL"+ CRLF

IF nTipo == 1
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,6) = '"+cMes+"' "+ CRLF
ELSEIF nTipo == 2
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,4) = '"+cMes+"' "+ CRLF
ELSE
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,6) >= '"+cMes+"' "+ CRLF
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,6) <= '"+cMesF+"' "+ CRLF
ENDIF
cQuery += "      AND SF2.D_E_L_E_T_ = ' '" + CRLF

Return cQuery


/*
Static Function ProcQuery
Local cQuery

cQuery := " SELECT DISTINCT F2_FILIAL,CNA_CLIENT AS XX_CLIENTE,CNA_LOJACL AS XX_LOJA,C6_PRODUTO AS XX_PROD,B1_DESC,B1_CODISS,B1_ALIQISS,CNF_CONTRA,CNF_REVISA,CNF_COMPET,"+ CRLF
cQuery += "    CASE WHEN CN9_SITUAC = '05' THEN CNF_VLPREV ELSE CNF_VLREAL END AS CNF_VLPREV,"+ CRLF
cQuery += "    CASE WHEN CN9_SITUAC = '05' THEN CNF_SALDO  ELSE 0 END AS CNF_SALDO, "+ CRLF
cQuery += "    CTT_DESC01, "+ CRLF
cQuery += "    CNA_NUMERO,CNA_XXMUN, "+ CRLF
cQuery += "    CND_NUMMED, CNF.R_E_C_N_O_ AS CNFRECNO,"+ CRLF
cQuery += "    CND_XXRM, "+ CRLF
cQuery += "    C6_NUM, "+ CRLF

cQuery += "    (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CND_NUMMED = CNR_NUMMED"+ CRLF
cQuery += "         AND  CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2') AS XX_BONIF,"+ CRLF

cQuery += "    (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CND_NUMMED = CNR_NUMMED"+ CRLF
cQuery += "         AND  CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '1') AS XX_MULTA,"+ CRLF

cQuery += "    F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS,F2_VLCPM,F2_XXVRETC, " + CRLF

cQuery += "    (SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "        AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"') AS XX_VENCTO, "+ CRLF

cQuery += "    (SELECT TOP 1 E1_VENCORI FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "        AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"') AS XX_VENCORI, "+ CRLF

cQuery += "    (SELECT TOP 1 E1_BAIXA FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "        AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"') AS XX_BAIXA, "+ CRLF

cQuery += "    (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " + CRLF
cQuery += "      AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5DESC, "+ CRLF
cQuery += "    (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " + CRLF
cQuery += "      AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5MULTA"+ CRLF

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
//cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON CNA_CLIENT = A1_COD AND CNA_LOJACL = A1_LOJA" + CRLF
//cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '" + CRLF
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
cQuery += "        CASE WHEN (C5_ESPECI1 = ' ' OR C5_ESPECI1 IS NULL) THEN 'XXXXXXXXXX' ELSE C5_ESPECI1 END AS CNF_CONTRA,"+ CRLF
cQuery += "        ' ',SUBSTRING(C5_XXCOMPT,1,2)+'/'+SUBSTRING(C5_XXCOMPT,3,4) AS CNF_COMPET,0,0, " + CRLF  // CNF_REVISA,CNF_COMPET,CNF_VLPREV,CNF_SALDO
cQuery += "        A1_NOME, "  + CRLF // CTT_DESC01
cQuery += "        ' ', CASE WHEN (C5_DESCMUN = ' ' OR C5_DESCMUN IS NULL) THEN SA1.A1_MUN ELSE C5_DESCMUN END AS CNA_XXMUN, " + CRLF  // CNA_NUMERO,CNA_XXMUN
cQuery += "        ' ', 0 AS CNFRECNO, "  + CRLF     // CND_NUMMED, CNF.R_E_C_N_O_
cQuery += "        C5_XXRM, "  + CRLF     // CND_XXRM
cQuery += "        D2_PEDIDO AS C6_NUM, " + CRLF   // C6_NUM
cQuery += "        0,0, "  + CRLF   // XX_BONIF,XX_MULTA
cQuery += "        F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS,F2_VLCPM,F2_XXVRETC, " + CRLF
cQuery += "        (SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+" SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC" + CRLF
cQuery += "            AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"') AS XX_VENCTO, " + CRLF
cQuery += "        (SELECT TOP 1 E1_VENCORI FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC" + CRLF
cQuery += "            AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"') AS XX_VENCORI, " + CRLF
cQuery += "        (SELECT TOP 1 E1_BAIXA FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC" + CRLF
cQuery += "            AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"') AS XX_BAIXA, " + CRLF
cQuery += "        (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' "  + CRLF
cQuery += "            AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5DESC, " + CRLF
cQuery += "        (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " + CRLF
cQuery += "            AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5MULTA "+ CRLF

cQuery += " FROM "+RETSQLNAME("SF2")+" SF2" + CRLF
//cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = "+cqContr
//cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '""
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA" + CRLF
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SD2")+ " SD2 ON D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA" + CRLF
cQuery += "      AND  D2_FILIAL = '"+xFilial("SD2")+"' AND  SD2.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON C5_NUM = D2_PEDIDO " + CRLF
cQuery += "      AND  C5_FILIAL = D2_FILIAL AND SC5.D_E_L_E_T_ = ' '" + CRLF
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
Return
*/


Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}
Local i,j

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

// Evitar previsões duplicadas                        
User Function GCTR7VP(nRec,nVlPrev)
If nRec > 0
	If AsCan(aRecNo,nRec) == 0
		aAdd(aRecno,nRec)
	Else
		nVlPrev := 0
	EndIf
EndIf
Return nVlPrev

// Evitar previsões duplicadas - nova
User Function GCTR7VPn(cChave,nVlPrev)
If !Empty(cChave)
	If AsCan(aChave,cChave) == 0
		aAdd(aChave,cChave)
	Else
		nVlPrev := 0
	EndIf
EndIf
Return nVlPrev
