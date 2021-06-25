#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKFINR07
BK - RELATORIO DE DESPESAS POR ITEM DO DOCUMENTO DE ENTRADA 
@Return
@author Marcos Bispo Abrahão
@since 11/05/10 Rev 28/08/20
@version P12.1.25
/*/

User Function FINR07(fFrota)

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cTitulo        := "Despesas mensais por Doc. de Entrada"
Local nLin           := 80
Local Cabec1         := ""
Local Cabec2         := ""
Local aOrd           := {}
Local aCabs          := {}
Local aCampos        := {}
Local aTitulos       := {}
Local aPlans         := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 132
Private tamanho      := " "
Private nomeprog     := "FINR07" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "FINR07"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "FINR07" // Coloque aqui o nome do arquivo usado para impressao em disco
Private fGFrota      := fFrota
Private cString      := "SD1"

Private dDtIni,dDtFim,dDtPgIni,dDtPgFin,cProduto,cCustoDe,cCustoAte,nUsers,nImpostos

Private nPlan


ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
Endif

dDtIni   := MV_PAR01
dDtFim   := MV_PAR02
nPlan    := MV_PAR03
cProduto := MV_PAR04
cCustoDe := MV_PAR05
cCustoAte:= MV_PAR06
nUsers   := MV_PAR07
nImpostos:= MV_PAR08
fGFrota  := fFrota


If nPlan = 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
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
	
	Processa( {|| ProcGer1(@Titulo) })
	RptStatus({|| RunReport(Cabec1,Cabec2,cTitulo,nLin) },cTitulo)
	QSD1->(Dbclosearea())
	
Else
 
		//dbSelectArea("SE2")
		//dbSetOrder(6)
		//dbSeek(xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC)
		//While !Eof() .And. E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == ;
		//	xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC
		//	If ALLTRIM(E2_ORIGEM)=="MATA100"
		//		aADD(aVencto,E2_VENCTO)
		//	EndIf
		//	dbSkip()
		//EndDo


	Processa( {|| ProcGer1(@cTitulo) })

	aCabs   := {}
	aCampos := {}
	aTitulos:= {}

	AADD(aTitulos,ctitulo)

	AADD(aCampos,"QSD1->D1_COD")
	AADD(aCabs  ,"Produto")

	AADD(aCampos,"QSD1->B1_DESC")
	AADD(aCabs  ,"Descricao do Produto")

	AADD(aCampos,"QSD1->ZI_COD")
	AADD(aCabs  ,"Sub Grupo")

	AADD(aCampos,"QSD1->ZI_DESC")
	AADD(aCabs  ,"Descricao Sub Grupo")

	AADD(aCampos,"QSD1->D1_TES")
	AADD(aCabs  ,"TES")

	AADD(aCampos,"QSD1->F4_TEXTO")
	AADD(aCabs  ,GetSX3Cache("F4_TEXTO", "X3_TITULO"))

	AADD(aCampos,"QSD1->F4_CF")
	AADD(aCabs  ,GetSX3Cache("F4_CF", "X3_TITULO"))

	AADD(aCampos,"QSD1->D1_CC")
	AADD(aCabs  ,"Centro de Custos")

	AADD(aCampos,"QSD1->CTT_DESC01")
	AADD(aCabs  ,"Descriçao do C.C.")

	AADD(aCampos,"QSD1->D1_CONTA")
	AADD(aCabs  ,"Conta")

	AADD(aCampos,"QSD1->D1_FORNECE")
	AADD(aCabs  ,"Cod. do Fornecedor")

	AADD(aCampos,"QSD1->D1_LOJA")
	AADD(aCabs  ,"Loja")

	AADD(aCampos,"TRANSFORM(QSD1->A2_CGC,IIF(QSD1->A2_TIPO=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))")
	AADD(aCabs  ,"CNPJ/CPF")

	AADD(aCampos,"QSD1->A2_NOME")
	AADD(aCabs  ,"Nome do Fornecedor")

	AADD(aCampos,"QSD1->D1_DOC")
	AADD(aCabs  ,"Documento")

	IF fGFrota
		AADD(aCampos,"QSD1->D1_EMISSAO")
		AADD(aCabs  ,"Emissão")
    ENDIF

	AADD(aCampos,"QSD1->D1_DTDIGIT")
	AADD(aCabs  ,"Data Entrada")

	AADD(aCampos,"QSD1->E2_VENCREA")
	AADD(aCabs  ,"Vencimento")

	AADD(aCampos,"QSD1->E2_BAIXA")
	AADD(aCabs  ,"Pagamento")

	If nUsers == 1
		AADD(aCampos,"U_BUSER(QSD1->F1_XXUSER)")
		AADD(aCabs  ,"Responsável")

		AADD(aCampos,"U_BUSER(QSD1->F1_XXUSERS)")
		AADD(aCabs  ,"Classificador")

	EndIf

	AADD(aCampos,"QSD1->D1_QUANT")
	AADD(aCabs  ,"Qtd.")
	
	AADD(aCampos,"ROUND(QSD1->D1_TOTAL / QSD1->D1_QUANT,2)")
	AADD(aCabs  ,"Unit.")

	AADD(aCampos,"QSD1->D1_TOTAL")
	AADD(aCabs  ,"Valor")
	
	If nImpostos == 1

		AADD(aCampos,"QSD1->F1_DTLANC")
		AADD(aCabs  ,GetSX3Cache("F1_DTLANC", "X3_TITULO")+" Ctb")

		AADD(aCampos,"QSD1->E2_NATUREZ")
		AADD(aCabs  ,"(Fin) "+GetSX3Cache("E2_NATUREZ", "X3_TITULO"))

		AADD(aCampos,"QSD1->ED_DESCRIC")
		AADD(aCabs  ,GetSX3Cache("ED_DESCRIC", "X3_TITULO"))

		AADD(aCampos,"QSD1->F4_CODBCC")
		AADD(aCabs  ,"(TES) "+GetSX3Cache("F4_CODBCC", "X3_TITULO"))

		// INSS
		AADD(aCampos,"X3COMBO('A2_RECINSS',QSD1->A2_RECINSS)")
		AADD(aCabs  ,"(INSS Forn) "+GetSX3Cache("A2_RECINSS", "X3_TITULO"))

		AADD(aCampos,"QSD1->ED_CALCINS")
		AADD(aCabs  ,"(Nat) "+GetSX3Cache("ED_CALCINS", "X3_TITULO"))

		AADD(aCampos,"QSD1->ED_PERCINS")
		AADD(aCabs  ,"(Nat) "+GetSX3Cache("ED_PERCINS", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_BASEINS")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_BASEINS", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_VALINS")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_VALINS", "X3_TITULO"))

		AADD(aCampos,"QSD1->F1_INSS")
		AADD(aCabs  ,"(NF) "+GetSX3Cache("F1_INSS", "X3_TITULO"))

		AADD(aCampos,"QSD1->E2_VRETINS")
		AADD(aCabs  ,"(Fin) "+GetSX3Cache("E2_VRETINS", "X3_TITULO"))

		AADD(aCampos,"QSD1->B1_INSS")
		AADD(aCabs  ,"(Prd) "+GetSX3Cache("B1_INSS", "X3_TITULO"))

		// IRRF
		AADD(aCampos,"X3COMBO('A2_CALCIRF',QSD1->A2_CALCIRF)")
		AADD(aCabs  ,"(Forn) "+GetSX3Cache("A2_CALCIRF", "X3_TITULO"))

		AADD(aCampos,"QSD1->ED_CALCIRF")
		AADD(aCabs  ,"(Nat) "+GetSX3Cache("ED_CALCIRF", "X3_TITULO"))

		AADD(aCampos,"QSD1->ED_PERCIRF")
		AADD(aCabs  ,"(Nat) "+GetSX3Cache("ED_PERCIRF", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_BASEIRR")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_BASEIRR", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_ALIQIRR")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_ALIQIRR", "X3_TITULO"))

		AADD(aCampos,"QSD1->F1_VALIRF")
		AADD(aCabs  ,"(NF) "+GetSX3Cache("F1_VALIRF", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_VALIRR")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_VALIRR", "X3_TITULO"))

		AADD(aCampos,"QSD1->E2_IRRF")
		AADD(aCabs  ,"(Fin) "+GetSX3Cache("E2_IRRF", "X3_TITULO"))

		AADD(aCampos,"QSD1->E2_VRETIRF")
		AADD(aCabs  ,"(Fin) "+GetSX3Cache("E2_VRETIRF", "X3_TITULO"))

		AADD(aCampos,"QSD1->B1_IRRF")
		AADD(aCabs  ,"(Prd) "+GetSX3Cache("B1_IRRF", "X3_TITULO"))

		// ISS
		AADD(aCampos,"QSD1->A2_RECISS")
		AADD(aCabs  ,"(Nat) "+GetSX3Cache("A2_RECISS", "X3_TITULO"))

		AADD(aCampos,"QSD1->ED_CALCISS")
		AADD(aCabs  ,"(Nat) "+GetSX3Cache("ED_CALCISS", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_BASEISS")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_BASEISS", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_ALIQISS")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_ALIQISS", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_VALISS")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_VALISS", "X3_TITULO"))

		AADD(aCampos,"QSD1->F1_ISS")
		AADD(aCabs  ,"(NF) "+GetSX3Cache("F1_ISS", "X3_TITULO"))

		AADD(aCampos,"QSD1->E2_VRETISS")
		AADD(aCabs  ,"(Fin) "+GetSX3Cache("E2_VRETISS", "X3_TITULO"))

		AADD(aCampos,"QSD1->B1_CODISS")
		AADD(aCabs  ,"(Prd) "+GetSX3Cache("B1_CODISS", "X3_TITULO"))

		AADD(aCampos,"X3COMBO('F4_RETISS',QSD1->F4_RETISS)")
		AADD(aCabs  ,"(TES) "+GetSX3Cache("F4_RETISS", "X3_TITULO"))

		//PIS
		AADD(aCampos,"X3COMBO('A2_RECPIS',QSD1->A2_RECPIS)")
		AADD(aCabs  ,"(Forn) "+GetSX3Cache("A2_RECPIS", "X3_TITULO"))

		AADD(aCampos,"QSD1->ED_CALCPIS")
		AADD(aCabs  ,"(Nat) "+GetSX3Cache("ED_CALCPIS", "X3_TITULO"))

		AADD(aCampos,"QSD1->ED_PERCPIS")
		AADD(aCabs  ,"(Nat) "+GetSX3Cache("ED_PERCPIS", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_BASEPIS")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_BASEPIS", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_ALQPIS")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_ALQPIS", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_VALPIS")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_VALPIS", "X3_TITULO"))

		AADD(aCampos,"QSD1->F1_VALPIS")
		AADD(aCabs  ,"(NF) "+GetSX3Cache("F1_VALPIS", "X3_TITULO"))

		AADD(aCampos,"QSD1->E2_VRETPIS")
		AADD(aCabs  ,"(Fin) "+GetSX3Cache("E2_VRETPIS", "X3_TITULO"))

		AADD(aCampos,"X3COMBO('B1_PIS',QSD1->B1_PIS)")
		AADD(aCabs  ,"(Prd) "+GetSX3Cache("B1_PIS", "X3_TITULO"))

		AADD(aCampos,"X3COMBO('F4_CSTPIS',QSD1->F4_CSTPIS)")
		AADD(aCabs  ,"(TES) "+GetSX3Cache("F4_CSTPIS", "X3_TITULO"))

		AADD(aCampos,"X3COMBO('F4_PISCRED',QSD1->F4_PISCRED)")
		AADD(aCabs  ,"(TES) "+GetSX3Cache("F4_PISCRED", "X3_TITULO"))

		AADD(aCampos,"X3COMBO('F4_PISCOF',QSD1->F4_PISCOF)")
		AADD(aCabs  ,"(TES) "+GetSX3Cache("F4_PISCOF", "X3_TITULO"))

		// COFINS
		AADD(aCampos,"X3COMBO('A2_RECCOFI',QSD1->A2_RECCOFI)")
		AADD(aCabs  ,"(Forn) "+GetSX3Cache("A2_RECCOFI", "X3_TITULO"))

		AADD(aCampos,"QSD1->ED_CALCCOF")
		AADD(aCabs  ,"(Nat) "+GetSX3Cache("ED_CALCCOF", "X3_TITULO"))

		AADD(aCampos,"QSD1->ED_PERCCOF")
		AADD(aCabs  ,"(Nat) "+GetSX3Cache("ED_PERCCOF", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_BASECOF")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_BASECOF", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_ALQCOF")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_ALQCOF", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_VALCOF")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_VALCOF", "X3_TITULO"))

		AADD(aCampos,"QSD1->E2_VRETCOF")
		AADD(aCabs  ,"(Fin) "+GetSX3Cache("E2_VRETCOF", "X3_TITULO"))

		AADD(aCampos,"X3COMBO('B1_COFINS',QSD1->B1_COFINS)")
		AADD(aCabs  ,"(Prd) "+GetSX3Cache("B1_COFINS", "X3_TITULO"))

		AADD(aCampos,"QSD1->F4_CSTCOF")
		AADD(aCabs  ,"(TES) "+GetSX3Cache("F4_CSTCOF", "X3_TITULO"))

		// CSLL
		AADD(aCampos,"X3COMBO('A2_RECCSLL',QSD1->A2_RECCSLL)")
		AADD(aCabs  ,"(Forn) "+GetSX3Cache("A2_RECCSLL", "X3_TITULO"))

		AADD(aCampos,"QSD1->ED_CALCCSL")
		AADD(aCabs  ,"(Nat) "+GetSX3Cache("ED_CALCCSL", "X3_TITULO"))

		AADD(aCampos,"QSD1->ED_PERCCSL")
		AADD(aCabs  ,"(Nat) "+GetSX3Cache("ED_PERCCSL", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_BASECSL")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_BASECSL", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_ALQCSL")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_ALQCSL", "X3_TITULO"))

		AADD(aCampos,"QSD1->D1_VALCSL")
		AADD(aCabs  ,"(Item) "+GetSX3Cache("D1_VALCSL", "X3_TITULO"))

		AADD(aCampos,"QSD1->E2_VRETCSL")
		AADD(aCabs  ,"(Fin) "+GetSX3Cache("E2_VRETCSL", "X3_TITULO"))

		AADD(aCampos,"X3COMBO('B1_CSLL',QSD1->B1_CSLL)")
		AADD(aCabs  ,"(Prd) "+GetSX3Cache("B1_CSLL", "X3_TITULO"))

	EndIf


	AADD(aCampos,"QSD1->C7_XXURGEN")
	AADD(aCabs  ,"Pedido Urgente")

	AADD(aCampos,"QSD1->D1_XXHIST")
	AADD(aCabs  ,"Historico")


	AADD(aPlans,{"QSD1",cPerg,"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
	U_GeraXlsx(aPlans,cTitulo,cPerg,.T.)

Endif	
	
Return


Static Function procger1(cTitulo)
Local cQuery

If SELECT("QSD1") > 0 
	dbSelectArea("QSD1")
   	dbCloseArea()
EndIf

cTitulo := "Despesas mensais por Doc. de Entrada: "

cQuery := "SELECT DISTINCT D1_FILIAL,D1_COD,D1_ITEM,B1_DESC,D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC AS D1_TOTAL,D1_QUANT,D1_CC,CTT_DESC01,"+CRLF
cQuery += " D1_CONTA,D1_FORNECE,D1_LOJA,A2_NOME,A2_TIPO,A2_CGC,D1_DOC,D1_DTDIGIT,D1_EMISSAO,C7_XXURGEN, "+CRLF
cQuery += " ZI_COD,ZI_DESC,D1_TES,F4_TEXTO,F4_CF, "+CRLF
cQuery += " E2_VENCREA,E2_BAIXA, "+CRLF
If nImpostos == 1
	cQuery += " F1_DTLANC,E2_NATUREZ,ED_DESCRIC,F4_CODBCC, "+CRLF
	cQuery += " A2_RECINSS,ED_CALCINS,ED_PERCINS,D1_BASEINS,D1_VALINS,F1_INSS,E2_VRETINS,B1_INSS, "+CRLF
	cQuery += " A2_CALCIRF,ED_CALCIRF,ED_PERCIRF,D1_BASEIRR,D1_ALIQIRR,D1_VALIRR,F1_VALIRF,E2_IRRF,E2_VRETIRF,B1_IRRF, "+CRLF
	cQuery += " A2_RECISS,ED_CALCISS,D1_BASEISS,D1_ALIQISS,D1_VALISS,F1_ISS,E2_VRETISS,B1_CODISS,F4_RETISS, "+CRLF
	cQuery += " A2_RECPIS,ED_CALCPIS,ED_PERCPIS,D1_BASEPIS,D1_ALQPIS,D1_VALPIS,F1_VALPIS,E2_VRETPIS,B1_PIS,F4_PISCRED,F4_PISCOF,F4_CSTPIS, "+CRLF
	cQuery += " A2_RECCOFI,ED_CALCCOF,ED_PERCCOF,D1_BASECOF,D1_ALQCOF,D1_VALCOF,E2_VRETCOF,B1_COFINS,F4_CSTCOF, "+CRLF
	cQuery += " A2_RECCSLL,ED_CALCCSL,ED_PERCCSL,D1_BASECSL,D1_ALQCSL,D1_VALCSL,E2_VRETCSL,B1_CSLL, "+CRLF
EndIf
If nUsers == 1
	cQuery += " F1_XXUSER,F1_XXUSERS, "+CRLF
EndIf
cQuery += " CONVERT(VARCHAR(6000),CONVERT(Binary(6000),D1_XXHIST)) D1_XXHIST "+CRLF
cQuery += "FROM "+RETSQLNAME("SD1")+" SD1 "
cQuery += " LEFT JOIN "+RETSQLNAME("SA2")+" SA2 ON A2_FILIAL = '"+xFilial("SA2")+"' AND D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D1_COD = B1_COD AND SB1.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_FILIAL = '"+xFilial("CTT")+"' AND D1_CC = CTT_CUSTO AND CTT.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC7")+" SC7 ON D1_FILIAL = C7_FILIAL AND D1_PEDIDO = C7_NUM AND D1_ITEMPC = C7_ITEM AND SC7.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SZI")+" SZI ON ZI_FILIAL = '"+xFilial("SZI")+"' AND ZI_COD = B1_XXSGRP AND SZI.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SF1")+" SF1 ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND SF1.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"'AND SD1.D1_TES=SF4.F4_CODIGO AND SF4.D_E_L_E_T_=''"+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SE2")+" SE2 ON SE2.D_E_L_E_T_='' AND SE2.E2_FILIAL = '"+xFilial("SE2")+"' AND E2_TIPO ='NF' "+CRLF
cQuery += "   AND E2_PREFIXO = SD1.D1_SERIE" +CRLF
cQuery += "   AND E2_NUM = SD1.D1_DOC" +CRLF
cQuery += "   AND E2_FORNECE = SD1.D1_FORNECE" +CRLF
cQuery += "   AND E2_LOJA = SD1.D1_LOJA" +CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SED")+" SED ON ED_FILIAL = '"+xFilial("SED")+"' AND ED_CODIGO = E2_NATUREZ AND SED.D_E_L_E_T_ = ' ' "+CRLF

cQuery += "WHERE SD1.D_E_L_E_T_ = ' ' "+CRLF

IF !EMPTY(dDtIni)
	IF fGFrota
		cQuery += "AND (D1_EMISSAO >= '"+DTOS(dDtIni)+"' OR D1_DTDIGIT >= '"+DTOS(dDtIni)+"') "+CRLF
   		ctitulo += " de "+DTOC(dDtIni)
  	ELSE
		cQuery += "AND D1_DTDIGIT >= '"+DTOS(dDtIni)+"' "+CRLF
   		ctitulo += " de "+DTOC(dDtIni)
  	ENDIF
ENDIF
IF !EMPTY(dDtFim)
	IF fGFrota
   		cQuery += "AND (D1_EMISSAO <= '"+DTOS(dDtFim)+"' OR D1_DTDIGIT <= '"+DTOS(dDtFim)+"') " +CRLF
   		ctitulo += " ate "+DTOC(dDtFim)
	ELSE
   		cQuery += "AND D1_DTDIGIT <= '"+DTOS(dDtFim)+"' "+CRLF
   		ctitulo += " ate "+DTOC(dDtFim)
	ENDIF
ENDIF

IF fGFrota
	cQuery += " AND SD1.D1_COD IN ('320200505','320200507','320200527','320200607','41205021') "+CRLF
ELSEIF !EMPTY(cProduto) .AND. ExistCpo("SB1",cProduto) 
	cQuery += " AND SD1.D1_COD = '"+ALLTRIM(cProduto)+"' "+CRLF
	ctitulo += " - Produto: "+ALLTRIM(cProduto)
ENDIF
IF !EMPTY(cCustoDe)
	cQuery += " AND SD1.D1_CC >= '"+ALLTRIM(cCustoDe)+"' "+CRLF
	ctitulo += " - Contrato de: "+ALLTRIM(cCustoDe)+IIF(!EMPTY(cCustoAte)," até "+ALLTRIM(cCustoAte),"")
ENDIF
IF !EMPTY(cCustoAte)
	cQuery += " AND SD1.D1_CC <= '"+ALLTRIM(cCustoAte)+"' "+CRLF
	IF EMPTY(cCustoDe)
		ctitulo += " - Contrato até: "+ALLTRIM(cCustoAte)
	ENDIF
ENDIF

cQuery += "ORDER BY D1_COD,D1_DTDIGIT,D1_DOC "+CRLF

u_LogMemo("BKFINR07.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QSD1"

TCSETFIELD("QSD1","D1_DTDIGIT","D",8,0)
TCSETFIELD("QSD1","D1_EMISSAO","D",8,0)
TCSETFIELD("QSD1","D1_XXHIST","M",10,0)
TCSETFIELD("QSD1","E2_VENCREA","D",8,0)
TCSETFIELD("QSD1","E2_BAIXA","D",8,0)

Dbselectarea("QSD1")
QSD1->(Dbgotop())

Return nil



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  11/05/10   º±±
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

Local nEsp,cPicVlr,pTotal,tTotal,cPrdAnt,nPos1

SetRegua(LastRec())

nEsp    := 2
cPicVlr := "@E 9,999,999.99"

//Cabec1  := PAD("Fil",LEN(QSD1->D1_FILIAL)+nEsp)
Cabec1  := PAD("Produto",LEN(QSD1->D1_COD)+nEsp)
Cabec1  += PAD("Descr. Produto",LEN(QSD1->B1_DESC)+nEsp)

Cabec1  += PAD("C. de Custos",LEN(QSD1->D1_CC)+nEsp)
Cabec1  += PAD("Descr. C.C.",LEN(QSD1->CTT_DESC01)+nEsp)

Cabec1  += PAD("Forn.",LEN(QSD1->D1_FORNECE)+nEsp)
Cabec1  += PAD("Lj",LEN(QSD1->D1_LOJA)+nEsp)
Cabec1  += PAD("Fornecedor",LEN(QSD1->A2_NOME)+nEsp)

Cabec1  += PAD("Documento",LEN(QSD1->D1_DOC)+nEsp)
Cabec1  += PAD("Data",LEN(DTOC(QSD1->D1_DTDIGIT))+nEsp)

Cabec1  += PADL("Valor",LEN(cPicVlr)-3)+SPACE(nEsp)

//IF fGFrota
	Cabec1  += PADL("Histórico",20-3)+SPACE(nEsp)
//ENDIF 

IF LEN(Cabec1) > 132
   Tamanho := "G"
ENDIF   

nomeprog := "FINR07/"+TRIM(SUBSTR(cUsuario,7,15))
   
Dbselectarea("QSD1")
Dbgotop()
SetRegua(LastRec())

cPrdAnt := QSD1->D1_COD

pTotal  := 0
tTotal  := 0
nPos1   := 0

DO While !QSD1->(EOF())

   IncRegua()
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio. . .                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   Endif

   IF QSD1->D1_COD <> cPrdAnt
      @ nLin,0     PSAY "TOTAL DO PRODUTO "+cPrdAnt
      @ nLin,nPos1 PSAY pTotal  PICTURE cPicVlr 
      nLin+=2
      pTotal := 0
      cPrdAnt := QSD1->D1_COD
      If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
         Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
         nLin := 9
      Endif
   ENDIF
    
   nPos := 0
   //@ nLin,nPos PSAY QSD1->D1_FILIAL
   //nPos := PCOL()+nEsp

   @ nLin,nPos PSAY QSD1->D1_COD
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY QSD1->B1_DESC
   nPos := PCOL()+nEsp
   
   @ nLin,nPos PSAY QSD1->D1_CC
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY QSD1->CTT_DESC01
   nPos := PCOL()+nEsp
   
   @ nLin,nPos PSAY QSD1->D1_FORNECE
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY QSD1->D1_LOJA
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY QSD1->A2_NOME
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY QSD1->D1_DOC
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY DTOC(QSD1->D1_DTDIGIT)
   nPos := PCOL()+nEsp

   IF nPos1 = 0
      nPos1 := nPos
   ENDIF

   @ nLin,nPos PSAY QSD1->D1_TOTAL PICTURE cPicVlr 
   nPos := PCOL()+nEsp

	//IF fGFrota
   		@ nLin,nPos PSAY PAD(QSD1->D1_XXHIST,20)
   		nPos := PCOL()+nEsp
	//ENDIF
   
   pTotal  += QSD1->D1_TOTAL
   tTotal  += QSD1->D1_TOTAL
   
   nLin++
   
   dbSkip()
EndDo

nLin++
IF nPos1 > 0
   @ nLin,0     PSAY "TOTAL DO PRODUTO "+cPrdAnt                   
   @ nLin,nPos1 PSAY pTotal  PICTURE cPicVlr 
   nLin++
   @ nLin,0     PSAY "TOTAL GERAL"
   @ nLin,nPos1 PSAY tTotal  PICTURE cPicVlr 
ENDIF                         
//Roda(0,,Tamanho)

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


Return


Static Function ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Data inicial:"    ,"Data I:"      ,"Data I:"      ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Data Final:"      ,"Data F:"      ,"Data F:"      ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Gerar Planilha? " ,"Planilha"     ,"Planilha"     ,"mv_ch3","N",01,0,2,"C","","mv_par03","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","   "})
AADD(aRegistros,{cPerg,"04","Pesquisar produto","Produto"      ,"Produto"      ,"mv_ch4","C",15,0,0,"G",'Vazio() .or. ExistCpo("SB1")',"mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1","S","",""})
AADD(aRegistros,{cPerg,"05","Contrato de?"     ,"Contrato de?" ,"Contrato de?" ,"mv_ch5","C",09,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"06","Contrato até?"    ,"Contrato até?","Contrato até?","mv_ch6","C",09,0,0,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"07","Listar usuários?" ,"Usuários"     ,"Usuários"     ,"mv_ch7","N",01,0,2,"C","","mv_par07","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","   "})
AADD(aRegistros,{cPerg,"08","Listar impostos?" ,"Impostos"     ,"Impostos"     ,"mv_ch8","N",01,0,2,"C","","mv_par08","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","   "})

For i:=1 to Len(aRegistros)
	If !dbSeek(cPerg+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegistros[i])
				FieldPut(j,aRegistros[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(aArea)

Return(NIL)


User Function FINR072()
	U_FINR07(.T.)
Return
