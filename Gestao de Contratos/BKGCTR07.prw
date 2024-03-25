#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR07()
BK - Mapa de Faturamento

@author Marcos B. Abrahão
@since 05/05/11 rev 18/03/24
@version P12
@return Nil
/*/

Static aChave := {}

User Function BKGCTR07()

Private cPerg       := "BKGCTR07"
Private cTitulo		:= "Mapa de Faturamento"
Private aParam	 	:=	{}
Private aRet	 	:=	{}

Private nMesI		:= Month(MonthSub(dDataBase,1))
Private nAnoI		:= Year(MonthSub(dDataBase,1))
Private nMesF		:= Month(MonthSub(dDataBase,1))
Private nAnoF		:= Year(MonthSub(dDataBase,1))

Private cMesIni		:= STRZERO(nMesI,2)
Private cAnoIni		:= STRZERO(nAnoI,4)
Private cMesFim		:= STRZERO(nMesF,2)
Private cAnoFim		:= STRZERO(nAnoF,4)

Private _cTXPIS  	:= STR(GetMv("MV_TXPIS"))
Private _cTXCOF  	:= STR(GetMv("MV_TXCOFINS"))

Private cMotMulta   := "N"
Private nValPrev	:= 0


aAdd(aParam, { 1,"Mes inicial",nMesI   ,"99"  ,"mv_par01 > 0 .AND. mv_par01 <= 12"      ,""   ,"",20,.T.})
aAdd(aParam, { 1,"Ano inicial",nAnoI   ,"9999","mv_par02 >= 2009 .AND. mv_par02 <= 2040",""   ,"",20,.T.})
aAdd(aParam, { 1,"Mes final"  ,nMesF   ,"99"  ,"mv_par03 > 0 .AND. mv_par03 <= 12"      ,""   ,"",20,.T.})
aAdd(aParam, { 1,"Ano final"  ,nAnoF   ,"9999","mv_par04 >= 2009 .AND. mv_par04 <= 2040",""   ,"",20,.T.})

If ParBk()
	dbSelectArea('SZR')
	dbSelectArea('SA1')
	dbSetOrder(1)

	cTitulo   := "Mapa de Faturamento: "+cMesIni+"/"+cAnoIni+iIf(cMesIni+cAnoIni <> cMesFim+cAnoFim," até "+cMesFim+"/"+cAnoFim,"")

	u_WaitLog(cPerg,{|oSay| PrcGct07(cAnoIni+cMesIni,cAnoFim+cMesFim) }, "Processando faturamento...")

	u_WaitLog(cPerg,{|oSay| QGctR7A(cAnoIni+cMesIni,cAnoFim+cMesFim) }, "Processando notas de débito...")

	u_WaitLog(cPerg,{|oSay| GeraExcel() }, "Gerando Arquivo Excel...")

EndIf
Return Nil


Static Function GeraExcel()

Local cDescricao	:= "Objetivo deste relatório é demonstrar o faturamento detalhado."
Local cVersao 		:= "05/05/2011: Mapa de INSS Retido"
Local cAlias 		:= "QTMP"
Local cAliasD 		:= "QTMP2"
Local oRExcel		AS Object
Local oPExcel		AS Object

cVersao += CRLF+"18/03/2024: Reformulação com RExcel"
cVersao += CRLF+"18/03/2024: Inclusão da aba Notas de Débito"

// Definição do Arq Excel
oRExcel := RExcel():New(cPerg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetDescr(cDescricao)
oRExcel:SetVersao(cVersao)
oRExcel:SetParam(aParam)

// Aba Faturamento
oPExcel:= PExcel():New("Faturamento",cAlias)
oPExcel:SetTitulo("Faturamento")

oPExcel:AddColX3("F2_FILIAL")
oPExcel:GetCol("F2_FILIAL"):SetHAlign("C")

oPExcel:AddColX3("F2_CLIENTE")
oPExcel:GetCol("F2_CLIENTE"):SetHAlign("C")

oPExcel:AddColX3("F2_LOJA")
oPExcel:GetCol("F2_LOJA"):SetHAlign("C")

oPExcel:AddColX3("A1_NOME")

oPExcel:AddColX3("A1_PESSOA")
oPExcel:GetCol("A1_PESSOA"):SetHAlign("C")

oPExcel:AddCol("A1_CGC","Transform(QTMP->A1_CGC,IIF(QTMP->A1_PESSOA=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))","CNPJ","")
oPExcel:GetCol("A1_CGC"):SetHAlign("C")

oPExcel:AddColX3("CNE_CONTRA")
oPExcel:GetCol("CNE_CONTRA"):SetHAlign("C")

oPExcel:AddColX3("CNE_REVISA")
oPExcel:GetCol("CNE_REVISA"):SetHAlign("C")

oPExcel:AddColX3("CTT_DESC01")

oPExcel:AddColX3("CNA_NUMERO")
oPExcel:GetCol("CNA_NUMERO"):SetHAlign("C")

oPExcel:AddColX3("CNA_XXMUN")

oPExcel:AddCol("CNA_FLREAJ","X3COMBO('CNA_FLREAJ',QTMP->CNA_FLREAJ)","Reajuste","")
oPExcel:GetCol("CNA_FLREAJ"):SetHAlign("C")
oPExcel:GetCol("CNA_FLREAJ"):SetTamCol(15)

oPExcel:AddColX3("CND_COMPET")
oPExcel:GetCol("CND_COMPET"):SetHAlign("C")

oPExcel:AddColX3("CXN_PARCEL")
oPExcel:GetCol("CXN_PARCEL"):SetHAlign("C")

oPExcel:AddColX3("CND_XXRM")
oPExcel:GetCol("CND_XXRM"):SetHAlign("C")

oPExcel:AddCol("XX_PROD","QTMP->XX_PROD","Produto","C6_PRODUTO")

oPExcel:AddColX3("B1_DESC")

oPExcel:AddColX3("B1_CODISS")
oPExcel:GetCol("B1_CODISS"):SetHAlign("C")

oPExcel:AddColX3("B1_ALIQISS")
oPExcel:GetCol("B1_ALIQISS"):SetHAlign("C")

oPExcel:AddColX3("CND_NUMMED")
oPExcel:GetCol("CND_NUMMED"):SetHAlign("C")

oPExcel:AddColX3("C6_NUM")
oPExcel:GetCol("C6_NUM"):SetHAlign("C")

oPExcel:AddColX3("F2_SERIE")
oPExcel:GetCol("F2_SERIE"):SetHAlign("C")

oPExcel:AddColX3("F2_DOC")
oPExcel:GetCol("F2_DOC"):SetTitulo("Nota Fiscal")
oPExcel:GetCol("F2_DOC"):SetHAlign("C")

oPExcel:AddColX3("D2_TES")
oPExcel:GetCol("D2_TES"):SetHAlign("C")

oPExcel:AddColX3("F2_EMISSAO")

oPExcel:AddCol("E1_VENCTO","QTMP->XX_VENCTO","Vencimento","E1_VENCTO")

oPExcel:AddCol("E1_VENCORI","QTMP->XX_VENCORI","Venc. Original","E1_VENCORI")

oPExcel:AddCol("E1_BAIXA","QTMP->XX_BAIXA","Recebimento","E1_BAIXA")

oPExcel:AddCol("CNF_VLPREV","nValPrev := U_GCTR7VPn(QTMP->(CNE_CONTRA+CNE_REVISA+CNA_NUMERO+CND_COMPET+CXN_PARCEL),QTMP->CNF_VLPREV)","Valor Previsto","F2_VALFAT")
oPExcel:GetCol("CNF_VLPREV"):SetTotal(.T.)

oPExcel:AddCol("CNF_SALDO","iIf(nValPrev>0,QTMP->CNF_SALDO,0)","Saldo Previsto","F2_VALFAT")
oPExcel:GetCol("CNF_SALDO"):SetTotal(.T.)

oPExcel:AddColX3("F2_VALFAT")
oPExcel:GetCol("F2_VALFAT"):SetTotal(.T.)
oPExcel:GetCol("F2_VALFAT"):SetTitulo("Valor Faturado")

oPExcel:AddCol("PREVFAT","nValPrev - QTMP->F2_VALFAT","Previsto - Faturado","F2_VALFAT")
oPExcel:GetCol("PREVFAT"):SetTotal(.T.)

oPExcel:AddCol("XX_BONIF","QTMP->XX_BONIF","Bonificações","CNR_VALOR")
oPExcel:GetCol("XX_BONIF"):SetTotal(.T.)

oPExcel:AddCol("XX_MULTA","QTMP->XX_MULTA","Multas","CNR_VALOR")
oPExcel:GetCol("XX_MULTA"):SetTotal(.T.)

oPExcel:AddCol("XX_E5DESC","QTMP->XX_E5DESC","Desconto na NF","E5_VALOR")
oPExcel:GetCol("XX_E5DESC"):SetTotal(.T.)

oPExcel:AddCol("XX_E5MULTA","QTMP->XX_E5MULTA","Cliente não Reteve","E5_VALOR")
oPExcel:GetCol("XX_E5MULTA"):SetTotal(.T.)


IF FWCodEmp() == "12"  .OR. FWCodEmp() == "02"

	oPExcel:AddCol("XX_IRPJ","VAL(STR(((QTMP->F2_VALFAT*0.32)*0.15),14,02))","IRPJ Apuração","F2_VALFAT")
	oPExcel:GetCol("XX_IRPJ"):SetTotal(.T.)

	oPExcel:AddCol("XX_PISAP","VAL(STR(QTMP->F2_VALFAT*("+ALLTRIM(_cTXPIS)+"/100),14,02))","PIS Apuração","F2_VALFAT")
	oPExcel:GetCol("XX_PISAP"):SetTotal(.T.)

	oPExcel:AddCol("XX_COFAP","VAL(STR(QTMP->F2_VALFAT*("+ALLTRIM(_cTXCOF)+"/100),14,02))","COFINS Apuração","F2_VALFAT")
	oPExcel:GetCol("XX_COFAP"):SetTotal(.T.)
	
	oPExcel:AddCol("XX_CSLLAP","VAL(STR(((QTMP->F2_VALFAT*0.32)*0.09),14,02))","CSLL Apuração","F2_VALFAT")
	oPExcel:GetCol("XX_CSLLAP"):SetTotal(.T.)
	
ELSE
	oPExcel:AddColX3("F2_VALIMP6")
	oPExcel:GetCol("F2_VALIMP6"):SetTitulo("PIS Apuração")
	oPExcel:GetCol("F2_VALIMP6"):SetTotal(.T.)

	oPExcel:AddColX3("F2_VALIMP5")
	oPExcel:GetCol("F2_VALIMP5"):SetTitulo("COFINS Apuração")
	oPExcel:GetCol("F2_VALIMP5"):SetTotal(.T.)
ENDIF

oPExcel:AddColX3("D2_ALQIRRF")
oPExcel:GetCol("D2_ALQIRRF"):SetTitulo("IRRF%")
oPExcel:GetCol("D2_ALQIRRF"):SetHAlign("C")

oPExcel:AddColX3("F2_VALIRRF")
oPExcel:GetCol("F2_VALIRRF"):SetTitulo("IRRF Retido")
oPExcel:GetCol("F2_VALIRRF"):SetTotal(.T.)

oPExcel:AddColX3("D2_ALIQINS")
oPExcel:GetCol("D2_ALIQINS"):SetTitulo("INSS%")
oPExcel:GetCol("D2_ALIQINS"):SetHAlign("C")

oPExcel:AddColX3("F2_VALINSS")
oPExcel:GetCol("F2_VALINSS"):SetTitulo("INSS Retido")
oPExcel:GetCol("F2_VALINSS"):SetTotal(.T.)

oPExcel:AddColX3("F2_VALPIS")
oPExcel:GetCol("F2_VALPIS"):SetTitulo("PIS Retido")
oPExcel:GetCol("F2_VALPIS"):SetTotal(.T.)

oPExcel:AddColX3("F2_VALCOFI")
oPExcel:GetCol("F2_VALCOFI"):SetTitulo("COFINS Retido")
oPExcel:GetCol("F2_VALCOFI"):SetTotal(.T.)

oPExcel:AddColX3("F2_VALCSLL")
oPExcel:GetCol("F2_VALCSLL"):SetTitulo("CSLL Retido")
oPExcel:GetCol("F2_VALCSLL"):SetTotal(.T.)

oPExcel:AddCol("XX_ISSAP","IIF(QTMP->F2_RECISS <> '1',QTMP->F2_VALISS,0)","ISS Apuração","F2_VALISS")
oPExcel:GetCol("XX_ISSAP"):SetTotal(.T.)

oPExcel:AddCol("XX_ISSRET","IIF(QTMP->F2_RECISS == '1',QTMP->F2_VALISS,0)","ISS Retido","F2_VALISS")
oPExcel:GetCol("XX_ISSRET"):SetTotal(.T.)

oPExcel:AddColX3("F2_VLCPM")
oPExcel:GetCol("F2_VLCPM"):SetTitulo("ISS Bitrib")
oPExcel:GetCol("F2_VLCPM"):SetTotal(.T.)

oPExcel:AddColX3("E1_XXISSBI")
oPExcel:GetCol("E1_XXISSBI"):SetTitulo("ISS Bitrib Indevidamente")
oPExcel:GetCol("E1_XXISSBI"):SetTotal(.T.)

oPExcel:AddColX3("F2_XXVCVIN")
oPExcel:GetCol("F2_XXVCVIN"):SetTitulo("Cta. Vinculada")
oPExcel:GetCol("F2_XXVCVIN"):SetTotal(.T.)

oPExcel:AddColX3("F2_XXVRETC")
oPExcel:GetCol("F2_XXVRETC"):SetTitulo("Ret. Contratual")
oPExcel:GetCol("F2_XXVRETC"):SetTotal(.T.)

oPExcel:AddCol("XX_VALLIQ","QTMP->F2_VALFAT - QTMP->F2_VALIRRF - QTMP->F2_VALINSS - QTMP->F2_VALPIS - QTMP->F2_VALCOFI - QTMP->F2_VALCSLL - IIF(QTMP->F2_RECISS = '1',QTMP->F2_VALISS,0) - QTMP->F2_VLCPM - QTMP->XX_E5DESC + QTMP->XX_E5MULTA - QTMP->F2_XXVRETC - QTMP->F2_XXVCVIN","Valor liquido","F2_VALFAT")
oPExcel:GetCol("XX_VALLIQ"):SetTotal(.T.)

/*
IF cMotMulta = "S"
	AADD(aCampos,"U_BKCNR07(QTMP->CND_NUMMED,'2')")
	AADD(aCabs  ,"Motivo Bonificação")

	AADD(aCampos,"U_BKCNR07(QTMP->CND_NUMMED,'1')")
	AADD(aCabs  ,"Motivo Multa")
ENDIF
*/

// Resumo por Cliente
oPExcel:AddResumos("Faturamento por Cliente","A1_NOME","F2_VALFAT")


// Adiciona a planilha notas de débito
oRExcel:AddPlan(oPExcel)

// Aba Notas de Débito
oPExcel:= PExcel():New("Notas de Débito",cAliasD)
oPExcel:SetTitulo("Notas de Débito")

oPExcel:AddColX3("E1_FILIAL")
oPExcel:GetCol("E1_FILIAL"):SetHAlign("C")

oPExcel:AddColX3("E1_CLIENTE")
oPExcel:GetCol("E1_CLIENTE"):SetHAlign("C")

oPExcel:AddColX3("E1_LOJA")
oPExcel:GetCol("E1_LOJA"):SetHAlign("C")

oPExcel:AddColX3("A1_NOME")

oPExcel:AddColX3("A1_PESSOA")
oPExcel:GetCol("A1_PESSOA"):SetHAlign("C")

oPExcel:AddCol("A1_CGC","Transform(QTMP2->A1_CGC,IIF(QTMP2->A1_PESSOA=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))","CNPJ","")
oPExcel:GetCol("A1_CGC"):SetHAlign("C")

oPExcel:AddColX3("E1_XXCUSTO")
oPExcel:GetCol("E1_XXCUSTO"):SetHAlign("C")
oPExcel:GetCol("E1_XXCUSTO"):SetTitulo("Contrato")

oPExcel:AddColX3("CTT_DESC01")

oPExcel:AddColX3("E1_XXREV")
oPExcel:GetCol("E1_XXREV"):SetHAlign("C")

oPExcel:AddColX3("E1_XXMED")
oPExcel:GetCol("E1_XXMED"):SetHAlign("C")

oPExcel:AddColX3("E1_XXCOMPE")
oPExcel:GetCol("E1_XXCOMPE"):SetHAlign("C")

oPExcel:AddColX3("E1_PREFIXO")
oPExcel:GetCol("E1_PREFIXO"):SetHAlign("C")

oPExcel:AddColX3("E1_NUM")
oPExcel:GetCol("E1_NUM"):SetHAlign("C")

oPExcel:AddColX3("E1_EMISSAO")

oPExcel:AddColX3("E1_VENCREA")

oPExcel:AddColX3("E1_BAIXA")

oPExcel:AddColX3("E1_VALOR")
oPExcel:GetCol("E1_VALOR"):SetTotal(.T.)

oPExcel:AddColX3("E1_SALDO")
oPExcel:GetCol("E1_SALDO"):SetTotal(.T.)


// Resumo por Cliente
oPExcel:AddResumos("Notas de Débito por Cliente","A1_NOME","E1_VALOR")

// Adiciona a planilha notas de débito
oRExcel:AddPlan(oPExcel)

// Cria arquivo Excel
oRExcel:Create()

Return


Static Function ParBk()
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg,.T.         ,.T.))
	lRet	:= .T.
	//cDocI	:= mv_par01
	nMesI	:= mv_par01
	nAnoI	:= mv_par02
	nMesF	:= mv_par03
	nAnoF	:= mv_par04

	cMesIni := STRZERO(nMesI,2)
	cAnoIni := STRZERO(nAnoI,4)
	cMesFim := STRZERO(nMesF,2)
	cAnoFim := STRZERO(nAnoF,4)

Endif
Return lRet


Static Function PrcGct07(cMesI,cMesF)
Local cQuery := ""

cQuery := u_QGctR07(cMesI,cMesF)
cQuery += " ORDER BY CNE_CONTRA,CNE_REVISA,CND_COMPET,F2_SERIE,F2_DOC" + CRLF

u_LogMemo("BKGCTR07.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","F2_EMISSAO","D",8,0)
TCSETFIELD("QTMP","XX_VENCTO","D",8,0)
TCSETFIELD("QTMP","XX_VENCORI","D",8,0)
TCSETFIELD("QTMP","XX_BAIXA","D",8,0)

Return Nil


// Usada nas rotinas BKGCTR07 e BKCOMA13
User Function QGctR07(cMesI,cMesF)
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
cQuery += "   F2_CLIENTE," + CRLF 
cQuery += "   F2_LOJA," + CRLF 
cQuery += "   D2_ALIQINS," + CRLF 
cQuery += "   D2_ALQIRRF," + CRLF 
cQuery += "   D2_TES," + CRLF 
cQuery += "   A1_NOME," + CRLF 
cQuery += "   A1_CGC," + CRLF 
cQuery += "   A1_PESSOA," + CRLF 
cQuery += "   C6_PRODUTO AS XX_PROD," + CRLF 
cQuery += "   B1_DESC," + CRLF 
cQuery += "   B1_CODISS," + CRLF 
cQuery += "   B1_ALIQISS," + CRLF 
cQuery += "   CNE_CONTRA," + CRLF 
cQuery += "   CNE_REVISA," + CRLF 
cQuery += "   CND_COMPET," + CRLF 
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
cQuery += "   	  AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"   + xFilial("SE1")+"') AS E1_XXISSBI, " + CRLF
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

cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA" + CRLF
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_ = ' '" + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+" SB1" + CRLF
cQuery += " 	ON (C6_PRODUTO = B1_COD" +CRLF
cQuery += " 		AND B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.D_E_L_E_T_='')"+CRLF

cQuery += " WHERE CNE.D_E_L_E_T_ = ' '"+ CRLF
//cQuery += "     AND CNE_FILIAL = '"+xFilial("CNE")+"'" Removido para co
///cQuery += " 	AND CN9.CN9_REVATU = '"+cRevAtu+"'"+ CRLF
// CN9->CN9_SITUAC <> '10' .AND. CN9->CN9_SITUAC <> '09'
If cMesI == cMesF
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,6) = '"+cMesI+"' "+ CRLF
Else
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,6) >= '"+cMesI+"' "+ CRLF
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,6) <= '"+cMesF+"' "+ CRLF
EndIf

cQuery += " UNION ALL "+ CRLF

cQuery += " SELECT DISTINCT" + CRLF 
cQuery += "   F2_FILIAL," + CRLF 
cQuery += "   F2_CLIENTE," + CRLF 
cQuery += "   F2_LOJA," + CRLF 
cQuery += "   D2_ALIQINS," + CRLF 
cQuery += "   D2_ALQIRRF," + CRLF 
cQuery += "   D2_TES," + CRLF 
cQuery += "   A1_NOME," + CRLF 
cQuery += "   A1_CGC," + CRLF 
cQuery += "   A1_PESSOA," + CRLF 
cQuery += "   D2_COD AS XX_PROD," + CRLF 
cQuery += "   B1_DESC," + CRLF 
cQuery += "   B1_CODISS," + CRLF 
cQuery += "   B1_ALIQISS," + CRLF 
cQuery += "   CASE WHEN (C5_ESPECI1 = ' ' OR C5_ESPECI1 IS NULL) THEN 'XXXXXXXXXX' ELSE C5_ESPECI1 END AS CNF_CONTRA," + CRLF 
cQuery += "   ' ' AS CNF_REVISA," + CRLF // CNF_REVISA
cQuery += "   SUBSTRING(C5_XXCOMPT,1,2)+'/'+SUBSTRING(C5_XXCOMPT,3,4) AS CNF_COMPET," + CRLF //CNF_COMPET 
cQuery += "   0 AS CNF_VLPREV," + CRLF  // CNF_VLPREV
cQuery += "   0 AS CNF_SALDO," + CRLF  // CNF_SALDO
cQuery += "   A1_NOME AS CTT_DESC01," + CRLF // CTT_DESC01
cQuery += "   ' ' AS CNA_NUMERO," + CRLF // CNA_NUMERO
cQuery += "   CASE WHEN (C5_DESCMUN = ' ' OR C5_DESCMUN IS NULL) THEN SA1.A1_MUN ELSE C5_DESCMUN END AS CNA_XXMUN, " + CRLF  // CNA_XXMUN
cQuery += "   ' ' AS CNA_FLREAJ," + CRLF // CNA_FLREAJ
cQuery += "   ' ' AS CND_NUMMED," + CRLF // CND_NUMMED
//cQuery += "   0 AS CNFRECNO," + CRLF // CNF.R_E_C_N_O_
cQuery += "   ' ' AS CXN_PARCEL," + CRLF // CXN_PARCEL
cQuery += "   C5_XXRM," + CRLF 
cQuery += "   C5_NUM AS C6_NUM," + CRLF 
cQuery += "   0 AS XX_BONIF," + CRLF // XX_BONIF
cQuery += "   0 AS XX_MULTA," + CRLF // XX_MULTA
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
cQuery += "   	  AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"   + xFilial("SE1")+"') AS E1_XXISSBI, " + CRLF
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

If cMesI == cMesF
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,6) = '"+cMesI+"' "+ CRLF
Else
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,6) >= '"+cMesI+"' "+ CRLF
	cQuery += " AND SUBSTRING(F2_EMISSAO,1,6) <= '"+cMesF+"' "+ CRLF
EndIf
cQuery += "      AND SF2.D_E_L_E_T_ = ' '" + CRLF

Return cQuery



Static Function QGctR7A(cMesI,cMesF)
Local cQuery as Character

cQuery := " SELECT " + CRLF
cQuery += "   E1_FILIAL," + CRLF 
cQuery += "   E1_CLIENTE," + CRLF 
cQuery += "   E1_LOJA," + CRLF 
cQuery += "   A1_NOME," + CRLF 
cQuery += "   A1_CGC," + CRLF 
cQuery += "   A1_PESSOA," + CRLF 
cQuery += "   E1_XXCUSTO," + CRLF 
cQuery += "   E1_XXREV," + CRLF 
cQuery += "   E1_XXCOMPE," + CRLF 
cQuery += "   E1_XXMED," + CRLF 
cQuery += "   CTT_DESC01," + CRLF 
cQuery += "   E1_PREFIXO," + CRLF 
cQuery += "   E1_NUM," + CRLF 
cQuery += "   E1_EMISSAO," + CRLF 
cQuery += "   E1_VENCREA," + CRLF 
cQuery += "   E1_BAIXA," + CRLF 
cQuery += "   E1_VALOR," + CRLF 
cQuery += "   E1_SALDO" + CRLF 

cQuery += " FROM "+RETSQLNAME("SE1")+" SE1" + CRLF

cQuery += " INNER JOIN "+RETSQLNAME("CTT")+" CTT" + CRLF
cQuery += " 	ON (CTT_CUSTO = E1_XXCUSTO" + CRLF
cQuery += " 		AND CTT_FILIAL = '"+xFilial("CTT")+"' AND CTT.D_E_L_E_T_='')" + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON E1_CLIENTE = A1_COD AND E1_LOJA = A1_LOJA" + CRLF
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_ = ' '" + CRLF

cQuery += " WHERE SE1.D_E_L_E_T_ = ' '"+ CRLF

If cMesI == cMesF
	cQuery += " AND SUBSTRING(E1_XXCOMPE,1,6) = '"+cMesI+"' "+ CRLF
Else
	cQuery += " AND SUBSTRING(E1_XXCOMPE,1,6) >= '"+cMesI+"' "+ CRLF
	cQuery += " AND SUBSTRING(E1_XXCOMPE,1,6) <= '"+cMesF+"' "+ CRLF
EndIf

cQuery += " ORDER BY E1_XXCUSTO,E1_XXREV,E1_XXCOMPE,E1_SERIE,E1_NUM" + CRLF

u_LogMemo("BKGCTR7A.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP2"
TCSETFIELD("QTMP2","E1_EMISSAO","D",8,0)
TCSETFIELD("QTMP2","E1_VENCREA","D",8,0)
TCSETFIELD("QTMP2","E1_BAIXA","D",8,0)

Return cQuery



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


// Evitar previsões duplicadas - nova medição
User Function GCTR7VPn(cChave,nVlPrev)
If !Empty(cChave)
	If AsCan(aChave,cChave) == 0
		aAdd(aChave,cChave)
	Else
		nVlPrev := 0
	EndIf
EndIf
Return nVlPrev
