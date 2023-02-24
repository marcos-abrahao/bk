#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

// --> FINR350
Static __oTBxCanc
// <-- FINR350


/*/{Protheus.doc} BKFINR07
BK - RELATORIO DE DESPESAS POR ITEM DO DOCUMENTO DE ENTRADA 
@Return
@author Marcos Bispo Abrahão
@since 11/05/10 Rev 28/08/20
@version P12.1.25
/*/

User Function FINR07(fFrota)

Local cTitulo        := "Despesas mensais por Doc. de Entrada"
Local aCabs          := {}
Local aCampos        := {}
Local aTitulos       := {}
Local aPlans         := {}

Private cPerg        := "FINR07"
Private fGFrota      := fFrota

Private dDtIni,dDtFim,dDtPgIni,dDtPgFin,cProduto,cCustoDe,cCustoAte,nUsers,nImpostos,nPaFin
Private nPagto
Private aPgtos 		 := {}

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
Endif
u_MsgLog(cPerg)

dDtIni   := MV_PAR01
dDtFim   := MV_PAR02
nPagto   := MV_PAR03
cProduto := MV_PAR04
cCustoDe := MV_PAR05
cCustoAte:= MV_PAR06
nUsers   := MV_PAR07
nImpostos:= MV_PAR08
nPaFin	 := MV_PAR09

fGFrota  := fFrota

// --> FINR350
If !Empty( __oTBxCanc )
	__oTBxCanc:Destroy()
	__oTBxCanc := Nil
EndIf

__oTBxCanc	:= FWPreparedStatement():New( '' )

FDelQuery(.T.)
// <-- FINR350

u_WaitLog(, {|| ProcGer1(@cTitulo) })

aCabs   := {}
aCampos := {}
aTitulos:= {}

AADD(aTitulos,ctitulo)

AADD(aCampos,"QSD1->D1_COD")
AADD(aCabs  ,"Produto")

AADD(aCampos,"QSD1->B1_DESC")
AADD(aCabs  ,"Descricao do Produto")

AADD(aCampos,"QSD1->B1_CONTA")
AADD(aCabs  ,"(Prod) "+GetSX3Cache("B1_CONTA", "X3_TITULO"))

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

AADD(aCampos,"QSD1->D1_SERIE")
AADD(aCabs  ,"Série")

AADD(aCampos,"QSD1->D1_DOC")
AADD(aCabs  ,"Documento")

If fGFrota
	AADD(aCampos,"QSD1->D1_EMISSAO")
	AADD(aCabs  ,"Emissão")
EndIf

AADD(aCampos,"QSD1->D1_DTDIGIT")
AADD(aCabs  ,"Data Entrada")

If nPagto == 1

	AADD(aCampos,"iIf(LEN(aPagtos := u_ValPag('NF',QSD1->D1_SERIE,QSD1->D1_DOC,QSD1->D1_FORNECE,QSD1->D1_LOJA,QSD1->D1_TOTAL)) > 0, aPagtos[5],0)")
	AADD(aCabs  ,"Valor pago item")

	AADD(aCampos,"aPagtos[2]")
	AADD(aCabs  ,"Saldo item")

	AADD(aCampos,"aPagtos[3]")
	AADD(aCabs  ,"Parcelas")

	AADD(aCampos,"iIf(Empty(QSD1->E2_VENCREA),aPagtos[6],QSD1->E2_VENCREA)")
	AADD(aCabs  ,"Ultimo Vencimento")

	AADD(aCampos,"iIf(Empty(QSD1->E2_BAIXA),aPagtos[7],QSD1->E2_BAIXA)")
	AADD(aCabs  ,"Ultimo Pagamento")

	AADD(aCampos,"-aPagtos[8]")
	AADD(aCabs  ,"Decrescimos Fin. Item")

	AADD(aCampos,"aPagtos[9]")
	AADD(aCabs  ,"Acrescimos Fin. Item")

//AADD(aCampos,"IIF(QSD1->F1_VALBRUT>0,ROUND(QSD1->E2_VALOR/QSD1->F1_VALBRUT*QSD1->D1_TOTAL,2),0)")
//AADD(aCabs  ,"Valor parcela")

EndIf

If nUsers == 1
	AADD(aCampos,"UsrRetName(QSD1->F1_XXUSER)")
	AADD(aCabs  ,"Responsável")

	AADD(aCampos,"UsrRetName(QSD1->F1_XXULIB)")
	AADD(aCabs  ,"Liberado por")
EndIf

AADD(aCampos,"QSD1->D1_QUANT")
AADD(aCabs  ,"Qtd.")

AADD(aCampos,"ROUND(QSD1->D1_TOTAL / QSD1->D1_QUANT,2)")
AADD(aCabs  ,"Unit.")

AADD(aCampos,"QSD1->D1_TOTAL")
AADD(aCabs  ,"Valor")

If nImpostos == 1
	AADD(aCampos,"X3COMBO('A2_SIMPNAC',QSD1->A2_SIMPNAC)")
	AADD(aCabs  ,"(Forn) "+GetSX3Cache("A2_SIMPNAC", "X3_TITULO"))

	AADD(aCampos,"QSD1->A2_CONTA")
	AADD(aCabs  ,"(Forn) "+GetSX3Cache("A2_CONTA", "X3_TITULO"))

	AADD(aCampos,"QSD1->CT1_DESC01")
	AADD(aCabs  ,"(Forn) "+GetSX3Cache("CT1_DESC01", "X3_TITULO"))

	AADD(aCampos,"QSD1->CT1B_DESC01")
	AADD(aCabs  ,"(Prod) "+GetSX3Cache("CT1_DESC01", "X3_TITULO"))

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

AADD(aCampos,"QSD1->F1_XXAVALI")
AADD(aCabs  ,"Avaliação")

AADD(aCampos,"QSD1->D1_XXHIST")
AADD(aCabs  ,"Historico")

AADD(aPlans,{"QSD1",cPerg,"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })

U_PlanXlsx(aPlans,cTitulo,cPerg,.T.)


// --> FINR350
__oTBxCanc:Destroy()
__oTBxCanc := Nil
// <-- FINR350

Return


Static Function ProcGer1(cTitulo)
Local cQuery

If SELECT("QSD1") > 0 
	dbSelectArea("QSD1")
   	dbCloseArea()
EndIf


// Conta do Prd
// Conta do Forn
// Forn opt Simple

cTitulo := "Despesas mensais por Doc. de Entrada: "

cQuery := "SELECT DISTINCT "+CRLF

cQuery += " D1_FILIAL, "+CRLF
cQuery += " D1_COD, "+CRLF
cQuery += " D1_ITEM, "+CRLF
cQuery += " B1_DESC, "+CRLF
cQuery += " D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC AS D1_TOTAL, "+CRLF
cQuery += " D1_QUANT, "+CRLF
cQuery += " D1_CC, "+CRLF
cQuery += " CTT_DESC01,"+CRLF

cQuery += " D1_CONTA, "+CRLF
cQuery += " D1_FORNECE, "+CRLF
cQuery += " D1_LOJA, "+CRLF
cQuery += " A2_NOME, "+CRLF
cQuery += " A2_TIPO, "+CRLF
cQuery += " A2_CGC, "+CRLF
cQuery += " A2_CONTA, "+CRLF
cQuery += " D1_SERIE, "+CRLF
cQuery += " D1_DOC, "+CRLF
cQuery += " D1_DTDIGIT, "+CRLF
cQuery += " D1_EMISSAO, "+CRLF
cQuery += " C7_XXURGEN, "+CRLF

cQuery += " ZI_COD, "+CRLF
cQuery += " ZI_DESC, "+CRLF
cQuery += " D1_TES, "+CRLF
cQuery += " F4_TEXTO, "+CRLF
cQuery += " F4_CF, "+CRLF

cQuery += " '' AS E2_VENCREA, "+CRLF // E2_VENCREA
cQuery += " '' AS E2_BAIXA, "+CRLF   // E2_BAIXA
cQuery += " 0  AS E2_VALOR, "+CRLF   // E2_VALOR
cQuery += " F1_VALBRUT, "+CRLF
cQuery += " F1_XXAVALI, "+CRLF
cQuery += " B1_CONTA, "+CRLF

If nImpostos == 1

	cQuery += " A2_SIMPNAC, "+CRLF
	cQuery += " A2_CONTA, "+CRLF
	cQuery += " CT1.CT1_DESC01 AS CT1_DESC01, "+CRLF
	cQuery += " CT1B.CT1_DESC01 AS CT1B_DESC01, "+CRLF

	cQuery += " F1_DTLANC, "+CRLF
	cQuery += " E2_NATUREZ, "+CRLF
	cQuery += " ED_DESCRIC, "+CRLF
	cQuery += " F4_CODBCC, "+CRLF

	cQuery += " A2_RECINSS, "+CRLF
	cQuery += " ED_CALCINS, "+CRLF
	cQuery += " ED_PERCINS, "+CRLF
	cQuery += " D1_BASEINS, "+CRLF
	cQuery += " D1_VALINS, "+CRLF
	cQuery += " F1_INSS, "+CRLF
	cQuery += " E2_VRETINS, "+CRLF
	cQuery += " B1_INSS, "+CRLF

	cQuery += " A2_CALCIRF, "+CRLF
	cQuery += " ED_CALCIRF, "+CRLF
	cQuery += " ED_PERCIRF, "+CRLF
	cQuery += " D1_BASEIRR, "+CRLF
	cQuery += " D1_ALIQIRR, "+CRLF
	cQuery += " D1_VALIRR, "+CRLF
	cQuery += " F1_VALIRF, "+CRLF
	cQuery += " E2_IRRF, "+CRLF
	cQuery += " E2_VRETIRF, "+CRLF
	cQuery += " B1_IRRF, "+CRLF

	cQuery += " A2_RECISS, "+CRLF
	cQuery += " ED_CALCISS, "+CRLF
	cQuery += " D1_BASEISS, "+CRLF
	cQuery += " D1_ALIQISS, "+CRLF
	cQuery += " D1_VALISS, "+CRLF
	cQuery += " F1_ISS, "+CRLF
	cQuery += " E2_VRETISS, "+CRLF
	cQuery += " B1_CODISS, "+CRLF
	cQuery += " F4_RETISS, "+CRLF

	cQuery += " A2_RECPIS, "+CRLF
	cQuery += " ED_CALCPIS, "+CRLF
	cQuery += " ED_PERCPIS, "+CRLF
	cQuery += " D1_BASEPIS, "+CRLF
	cQuery += " D1_ALQPIS, "+CRLF
	cQuery += " D1_VALPIS, "+CRLF
	cQuery += " F1_VALPIS, "+CRLF
	cQuery += " E2_VRETPIS, "+CRLF
	cQuery += " B1_PIS, "+CRLF
	cQuery += " F4_PISCRED, "+CRLF
	cQuery += " F4_PISCOF, "+CRLF
	cQuery += " F4_CSTPIS, "+CRLF

	cQuery += " A2_RECCOFI, "+CRLF
	cQuery += " ED_CALCCOF, "+CRLF
	cQuery += " ED_PERCCOF, "+CRLF
	cQuery += " D1_BASECOF, "+CRLF
	cQuery += " D1_ALQCOF, "+CRLF
	cQuery += " D1_VALCOF, "+CRLF
	cQuery += " E2_VRETCOF, "+CRLF
	cQuery += " B1_COFINS, "+CRLF
	cQuery += " F4_CSTCOF, "+CRLF

	cQuery += " A2_RECCSLL, "+CRLF
	cQuery += " ED_CALCCSL, "+CRLF
	cQuery += " ED_PERCCSL, "+CRLF
	cQuery += " D1_BASECSL, "+CRLF
	cQuery += " D1_ALQCSL, "+CRLF
	cQuery += " D1_VALCSL, "+CRLF
	cQuery += " E2_VRETCSL, "+CRLF
	cQuery += " B1_CSLL, "+CRLF

EndIf
If nUsers == 1
	cQuery += " F1_XXUSER, "+CRLF
	cQuery += " F1_XXUSERS, "+CRLF
	cQuery += " F1_XXULIB, "+CRLF
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
cQuery += "   AND SE2.R_E_C_N_O_ = " +CRLF
// 				Subquery para pegar apenas 1 registro na left join
cQuery += "   	(SELECT TOP 1 R_E_C_N_O_ FROM "+RETSQLNAME("SE2")+" SE2 WHERE SE2.D_E_L_E_T_='' AND SE2.E2_FILIAL = '"+xFilial("SE2")+"' AND E2_TIPO ='NF'" +CRLF
cQuery += "   		AND E2_PREFIXO = SD1.D1_SERIE" +CRLF
cQuery += "   		AND E2_NUM = SD1.D1_DOC" +CRLF
cQuery += "   		AND E2_FORNECE = SD1.D1_FORNECE" +CRLF
cQuery += "   		AND E2_LOJA = SD1.D1_LOJA)" +CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("SED")+" SED ON ED_FILIAL = '"+xFilial("SED")+"' AND ED_CODIGO = E2_NATUREZ AND SED.D_E_L_E_T_ = '' "+CRLF
If nImpostos == 1
	cQuery += " LEFT JOIN "+RETSQLNAME("CT1")+" CT1 ON CT1_FILIAL = '"+xFilial("CT1")+"' AND CT1_CONTA = A2_CONTA AND CT1.D_E_L_E_T_ = ''  "+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CT1")+" CT1B ON CT1B.CT1_FILIAL = '"+xFilial("CT1")+"' AND CT1B.CT1_CONTA = B1_CONTA AND CT1B.D_E_L_E_T_ = ''  "+CRLF
EndIf
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

If nPaFin == 1 .AND. EMPTY(cProduto)

	// 04/02/2022 - Incluir pagamentos antecipados
	cQuery += " UNION ALL "+CRLF
	cQuery += " SELECT "+CRLF
	cQuery += " E2_FILIAL	AS D1_FILIAL,"+CRLF
	cQuery += " 'PA' 		AS D1_COD,"+CRLF
	cQuery += " ' ' 		AS D1_ITEM,"+CRLF
	cQuery += " 'PAGAMENTO ANTECIPADO' AS B1_DESC,"+CRLF
	cQuery += " E2_SALDO 	AS D1_TOTAL,"+CRLF
	cQuery += " 0 			AS D1_QUANT,"+CRLF
	cQuery += " E2_CCUSTO 	AS D1_CC,CTT_DESC01,"+CRLF

	cQuery += " ' ' 		AS D1_CONTA,"+CRLF
	cQuery += " E2_FORNECE 	AS D1_FORNECE,"+CRLF
	cQuery += " E2_LOJA		AS D1_LOJA,"+CRLF
	cQuery += " A2_NOME,"+CRLF
	cQuery += " A2_TIPO,"+CRLF
	cQuery += " A2_CGC,"+CRLF
	cQuery += " A2_CONTA,"+CRLF
	cQuery += " E2_PREFIXO	AS D1_SERIE,"+CRLF
	cQuery += " E2_NUM		AS D1_DOC,"+CRLF
	cQuery += " E2_EMIS1	AS D1_DTDIGIT,"+CRLF
	cQuery += " E2_EMISSAO	AS D1_EMISSAO,"+CRLF
	cQuery += " ' '			AS C7_XXURGEN, "+CRLF

	cQuery += " ' '			AS ZI_COD,"+CRLF
	cQuery += " ' '			AS ZI_DESC,"+CRLF
	cQuery += " ' '			AS D1_TES,"+CRLF
	cQuery += " ' '			AS F4_TEXTO,"+CRLF
	cQuery += " ' '			AS F4_CF, "+CRLF

	cQuery += " E2_VENCREA,"+CRLF
	cQuery += " E2_BAIXA,"+CRLF
	cQuery += " E2_VALOR,"+CRLF
	cQuery += " 0 			AS F1_VALBRUT, "+CRLF
	cQuery += " ' '			AS B1_CONTA, "+CRLF

	If nImpostos == 1
		cQuery += " A2_SIMPNAC, "+CRLF
		cQuery += " A2_CONTA, "+CRLF
		cQuery += " CT1.CT1_DESC01 AS CT1_DESC01, "+CRLF
		cQuery += " ' '			AS CT1B_DESC01, "+CRLF

		cQuery += " E2_MOVIMEN	AS F1_DTLANC, "+CRLF
		cQuery += " E2_NATUREZ, "+CRLF
		cQuery += " ED_DESCRIC, "+CRLF
		cQuery += " ' '			AS F4_CODBCC, "+CRLF

		cQuery += " A2_RECINSS, "+CRLF
		cQuery += " ED_CALCINS, "+CRLF
		cQuery += " ED_PERCINS, "+CRLF
		cQuery += " 0			AS D1_BASEINS, "+CRLF
		cQuery += " 0			AS D1_VALINS, "+CRLF
		cQuery += " 0			AS F1_INSS, "+CRLF
		cQuery += " E2_VRETINS, "+CRLF
		cQuery += " ' '			AS B1_INSS, "+CRLF

		cQuery += " A2_CALCIRF, "+CRLF
		cQuery += " ED_CALCIRF, "+CRLF
		cQuery += " ED_PERCIRF, "+CRLF
		cQuery += " 0			AS D1_BASEIRR, "+CRLF
		cQuery += " 0			AS D1_ALIQIRR, "+CRLF
		cQuery += " 0			AS D1_VALIRR, "+CRLF
		cQuery += " 0			AS F1_VALIRF, "+CRLF
		cQuery += " E2_IRRF, "+CRLF
		cQuery += " E2_VRETIRF, "+CRLF
		cQuery += " ' '			AS B1_IRRF, "+CRLF

		cQuery += " A2_RECISS, "+CRLF
		cQuery += " ED_CALCISS, "+CRLF
		cQuery += " 0			AS D1_BASEISS, "+CRLF
		cQuery += " 0			AS D1_ALIQISS, "+CRLF
		cQuery += " 0			AS D1_VALISS, "+CRLF
		cQuery += " 0			AS F1_ISS, "+CRLF
		cQuery += " 0			AS E2_VRETISS, "+CRLF
		cQuery += " ' '			AS B1_CODISS, "+CRLF
		cQuery += " ' '			AS F4_RETISS, "+CRLF

		cQuery += " A2_RECPIS, "+CRLF
		cQuery += " ED_CALCPIS, "+CRLF
		cQuery += " ED_PERCPIS, "+CRLF
		cQuery += " 0			AS D1_BASEPIS, "+CRLF
		cQuery += " 0			AS D1_ALQPIS, "+CRLF
		cQuery += " 0			AS D1_VALPIS, "+CRLF
		cQuery += " 0			AS F1_VALPIS, "+CRLF
		cQuery += " E2_VRETPIS, "+CRLF
		cQuery += " ' '			AS B1_PIS, "+CRLF
		cQuery += " ' '			AS F4_PISCRED, "+CRLF
		cQuery += " ' '			AS F4_PISCOF, "+CRLF
		cQuery += " ' '			AS F4_CSTPIS, "+CRLF

		cQuery += " A2_RECCOFI, "+CRLF
		cQuery += " ED_CALCCOF, "+CRLF
		cQuery += " ED_PERCCOF, "+CRLF
		cQuery += " 0			AS D1_BASECOF, "+CRLF
		cQuery += " 0			AS D1_ALQCOF, "+CRLF
		cQuery += " 0			AS D1_VALCOF, "+CRLF
		cQuery += " E2_VRETCOF, "+CRLF
		cQuery += " 0			AS B1_COFINS, "+CRLF
		cQuery += " ' '			AS F4_CSTCOF, "+CRLF

		cQuery += " A2_RECCSLL, "+CRLF
		cQuery += " ED_CALCCSL, "+CRLF
		cQuery += " ED_PERCCSL, "+CRLF
		cQuery += " 0			AS D1_BASECSL, "+CRLF
		cQuery += " 0			AS D1_ALQCSL, "+CRLF
		cQuery += " 0			AS D1_VALCSL, "+CRLF
		cQuery += " E2_VRETCSL, "+CRLF
		cQuery += " ' '			AS B1_CSLL, "+CRLF

	EndIf
	If nUsers == 1
		cQuery += " ' '			AS F1_XXUSER, "+CRLF
		cQuery += " ' '			AS F1_XXUSERS, "+CRLF
		cQuery += " ' '			AS F1_XXULIB, "+CRLF
	EndIf
	cQuery += " E2_HIST			AS D1_XXHIST "+CRLF

	cQuery += "FROM "+RETSQLNAME("SE2")+" SE2 "
	cQuery += " LEFT JOIN "+RETSQLNAME("SA2")+" SA2 ON A2_FILIAL = '"+xFilial("SA2")+"' AND E2_FORNECE = A2_COD AND E2_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_FILIAL = '"+xFilial("CTT")+"' AND E2_CCUSTO = CTT_CUSTO AND CTT.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("SED")+" SED ON ED_FILIAL = '"+xFilial("SED")+"' AND ED_CODIGO = E2_NATUREZ AND SED.D_E_L_E_T_ = '' "+CRLF
	If nImpostos == 1
		cQuery += " LEFT JOIN "+RETSQLNAME("CT1")+" CT1 ON CT1_FILIAL = '"+xFilial("CT1")+"' AND CT1_CONTA = A2_CONTA AND CT1.D_E_L_E_T_ = ''  "+CRLF
		//cQuery += " LEFT JOIN "+RETSQLNAME("CT1")+" CT1B ON CT1B.CT1_FILIAL = '"+xFilial("CT1")+"' AND CT1B.CT1_CONTA = B1_CONTA AND CT1B.D_E_L_E_T_ = ''  "+CRLF
	EndIf
	cQuery += "WHERE SE2.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += " AND E2_PREFIXO = '001' "+CRLF
	cQuery += " AND E2_TIPO = 'PA' "+CRLF
	cQuery += " AND E2_SALDO > 0 "+CRLF

	IF !EMPTY(dDtIni)
		cQuery += "AND E2_EMIS1 >= '"+DTOS(dDtIni)+"' "+CRLF
	ENDIF
	IF !EMPTY(dDtFim)
		cQuery += "AND E2_EMIS1 <= '"+DTOS(dDtFim)+"' "+CRLF
	ENDIF

	IF !EMPTY(cCustoDe)
		cQuery += " AND SE2.E2_CCUSTO >= '"+ALLTRIM(cCustoDe)+"' "+CRLF
	ELSE
		cQuery += " AND SE2.E2_CCUSTO > ' ' "+CRLF
	ENDIF

	IF !EMPTY(cCustoAte)
		cQuery += " AND SE2.E2_CCUSTO <= '"+ALLTRIM(cCustoAte)+"' "+CRLF
	ENDIF

EndIf


cQuery += "ORDER BY D1_DTDIGIT,D1_COD,D1_DOC "+CRLF

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

#Define I_CORRECAO_MONETARIA     1
#Define I_DESCONTO               2
#Define I_JUROS                  3
#Define I_MULTA                  4
#Define I_VALOR_RECEBIDO         5
#Define I_VALOR_PAGO             6
#Define I_RECEB_ANT              7
#Define I_PAGAM_ANT              8
#Define I_MOTBX                  9
#Define I_RECPAG_REAIS         	10
#Define I_LEI10925              12
#DeFine I_VALOR_ACESSORIO		13

#Define X_VALOR_PAGO             1
#Define X_SALDO		             2
#Define X_PARCELAS               3
#Define X_VLORIGINAL             4
#Define X_VLPAGOITEM             5
#Define X_ULTVENC	             6
#Define X_ULTPGTO                7
#Define X_DECRESCIMOS            8
#Define X_ACRESCIMOS             9


User Function ValPag(cTipo,cSerie,cDoc,cForn,cLoja,nValItem)
Local aPgtos   	:= {0,0,0,0,0,CTOD(""),CTOD(""),0,0}
Local aValor 	:= {}
Local cQuery3   := ""
Local cAliasSE2 := "SE2"
Local nMoeda 	:= 1
Local nDecs		:= 2
Local lPaBruto	:= GetNewPar("MV_PABRUTO","2") == "1"  //Indica se o PA terá o valor dos impostos descontados do seu valor

Local xmv_par05 := dDtIni   // Emissao inicial
Local xmv_par06 := dDtFim	// Emissao Finan

Local xmv_par10 := 1	// Qual a moeda ?   
Local xmv_par11 := 1	// Reajusta Venc.pela ?				1=Data Base   
Local xmv_par14 := 2	// Compoe Saldo Retroativo ?		1=Sim            
Local xmv_par17 := 1	// Conv.mov. na moeda sel. pela ?	1=Data Movimento 
Local xmv_par18 := 1	// Considera Data de Emissao ? 		1=Do Documento     

// Valores acessórios.
Local nValAcess	:= 0
Local lExistVlAc:= ExistFunc('FValAcess')
Local lFxLoadFK6:= ExistFunc('FxLoadFK6')

cQuery3 := " SELECT E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA"
//cQuery3 += " E2_VENCREA,E2_VALOR,E2_DESCONT,E2_MULTA,E2_JUROS,E2_ACRESC,E2_DECRESC,E2_VRETPIS,E2_VRETCOF,E2_VRETCSL,E2_VRETINS,E2_VRETIRF,E2_VRETISS"+CRLF
cQuery3 += " FROM "+RETSQLNAME("SE2")+" SE2"+CRLF
cQuery3 += " WHERE SE2.D_E_L_E_T_='' AND SE2.E2_FILIAL = '"+xFilial("SE2")+"' AND E2_TIPO ='"+cTipo+"' "+CRLF
cQuery3 += "   AND E2_PREFIXO = '"+cSerie+"'" +CRLF
cQuery3 += "   AND E2_NUM = '"+cDoc+"'" +CRLF
cQuery3 += "   AND E2_FORNECE = '"+cForn+"'" +CRLF
cQuery3 += "   AND E2_LOJA = '"+cLoja+"'" +CRLF

TCQUERY cQuery3 NEW ALIAS "QTMPXE2"
dbSelectArea("QTMPXE2")
dbGoTop()

nTotE2  := 0

// Posicionamento do SE5 neste ponto que servira para   
// pesquisa de descarte de registros geradores de       
// desdobramento                                        

dbSelectArea("SE5")
SE5->(dbSetOrder(7))

Do While !QTMPXE2->(EOF())

	SE2->( dbSetOrder(1) )
	If SE2->( MsSeek( xFilial("SE2")+QTMPXE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA ) ) )

		aValor := Baixas((cAliasSE2)->E2_NATUREZ,(cAliasSE2)->E2_PREFIXO,(cAliasSE2)->E2_NUM,(cAliasSE2)->E2_PARCELA,(cAliasSE2)->E2_TIPO,;
						nMoeda,"P",(cAliasSE2)->E2_FORNECE,dDataBase,(cAliasSE2)->E2_LOJA,(cAliasSE2)->E2_FILORIG,,,,nMoeda == 2,__oTBxCanc)

		If (cAliasSE2)->E2_NUM == '000000590'
			xTeste:= 0
		EndIf

		If SE2->E2_TIPO == "NDF"
			aValor[I_VALOR_PAGO]:=0
		Endif

		If xmv_par14 == 1
			nSaldo :=SaldoTit((cAliasSE2)->E2_PREFIXO,(cAliasSE2)->E2_NUM,(cAliasSE2)->E2_PARCELA,(cAliasSE2)->E2_TIPO,;
							(cAliasSE2)->E2_NATUREZ,"P",(cAliasSE2)->E2_FORNECE,nMoeda,;
							iIf(xmv_par11==1,dDataBase,(cAliasSE2)->E2_VENCREA),,(cAliasSE2)->E2_LOJA,,iIf(xmv_par17 == 1 ,(cAliasSE2)->E2_TXMOEDA,0),,,__oTBxCanc)
		Else
			nSaldo := Round(xMoeda(((cAliasSE2)->E2_SALDO+(cAliasSE2)->E2_SDACRES-(cAliasSE2)->E2_SDDECRE),(cAliasSE2)->E2_MOEDA,xmv_par10,;
				iIf(xmv_par17 == 1,iIf(xmv_par18 == 1,(cAliasSE2)->E2_EMISSAO,(cAliasSE2)->E2_EMIS1),dDataBase),nDecs+1,iIf(xmv_par17 == 1 .and. (cAliasSE2)->E2_TXMOEDA>0,(cAliasSE2)->E2_TXMOEDA, )), nDecs)
		Endif

		//compensação de nf x pa/ncc de filiais diferentes.
						//vld para corrigir o sld atual do total geral.
		If nSaldo > 0 .And. (cAliasSE2)->E2_SALDO == 0 .And. (cAliasSE2)->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG .And. len(aValor) > 0 .And. xmv_par18 == 2
			If AllTrim(aValor[9]) == "Compensação"
				nSaldo := 0
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ SE2 - Calcula valor acessório
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValAcess	:= 0
		If SE2->E2_SALDO <> SE2->E2_VALOR //Sofreu baixa
			aAreaSE5	:= SE5->(GetArea())
			DbSelectArea("SE5")
			DBSetOrder(2)  // E5_FILIAL, E5_TIPODOC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_CLIFOR, E5_LOJA, E5_SEQ.
			If SE5->(DBSeek(xFilial("SE5") + "VA" + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO + Dtos(SE2->E2_BAIXA) + SE2->E2_FORNECE + SE2->E2_LOJA))
				nValAcess := IIf(lFxLoadFK6,FxLoadFK6("FK1",SE5->E5_IDORIG,"VA")[1,2],0)
			Endif
			RestArea(aAreaSE5)
		Else
			nValAcess := IIf(lExistVlAc,FValAcess(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_NATUREZ, Iif(Empty(SE2->E2_BAIXA),.F.,.T.),"","P",DDataBase),0)
			nSaldo	+= nValAcess
		Endif

		aValor[I_DESCONTO]+= (cAliasSE2)->E2_SDDECRE
		aValor[I_JUROS]   += (cAliasSE2)->E2_SDACRES
		aValor[I_VALOR_ACESSORIO]	+= nValAcess

		nTotAbat := SumAbatPag(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_FORNECE,xmv_par10,"V",,SE2->E2_LOJA,iIf(xmv_par18==1,"1","2"),xmv_par05,xmv_par06,;
						iIf(xmv_par17 == 1,iIf(xmv_par18 == 1,SE2->E2_EMISSAO,SE2->E2_EMIS1),dDataBase),SE2->E2_TIPO)

		If !((cAliasSE2)->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG) .And. !( xMV_PAR14 == 2 .And. nSaldo == 0 ) // nao deve olhar abatimento pois e zerado o saldo na liquidacao final do titulo
			nSaldo -= nTotAbat
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se foi gerada fatura, colocar Motbx == Faturado				  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty((cAliasSE2)->E2_DTFATUR) .and. (cAliasSE2)->E2_DTFATUR <= dDataBase
			aValor[I_MOTBX] := "Faturado"
			aValor[I_VALOR_PAGO] -= nTotAbat
		Endif

		If cPaisLoc == "BRA" .And. !lPaBruto  .And. alltrim((cAliasSE2)->E2_TIPO)$"PA ,"+MV_CPNEG
			nValorOrig:=(cAliasSE2)->E2_VALOR+(cAliasSE2)->E2_COFINS+(cAliasSE2)->E2_PIS+(cAliasSE2)->E2_CSLL
		Else
			nValorOrig:=(cAliasSE2)->E2_VALOR
		EndIf

		aPgtos[X_VALOR_PAGO] 	+= aValor[I_VALOR_PAGO]
		aPgtos[X_SALDO] 		+= nSaldo
		aPgtos[X_PARCELAS]++
		aPgtos[X_VLORIGINAL] 	+= nValorOrig
		If (cAliasSE2)->E2_VENCREA > aPgtos[X_ULTVENC] 
			aPgtos[X_ULTVENC]  := (cAliasSE2)->E2_VENCREA
		EndIf
		If (cAliasSE2)->E2_BAIXA > aPgtos[X_ULTPGTO] 
			aPgtos[X_ULTPGTO]  := (cAliasSE2)->E2_BAIXA
		EndIf
		aPgtos[X_DECRESCIMOS] 	+= aValor[I_DESCONTO]
		aPgtos[X_ACRESCIMOS] 	+= aValor[I_JUROS]

	EndIf

	QTMPXE2->(dbSkip())
Enddo
QTMPXE2->(Dbclosearea())

aPgtos[X_VLPAGOITEM] := Round((aPgtos[X_VALOR_PAGO]   / aPgtos[X_VLORIGINAL]) * nValItem,2)
	//                       Val total pago titulos   / Tot Geral             * Valor do Item   			
aPgtos[X_SALDO]      := Round((aPgtos[X_SALDO]        / aPgtos[X_VLORIGINAL]) * nValItem,2)
	//                       saldo                    / Tot Geral             * Valor do Item   			

aPgtos[X_DECRESCIMOS] := Round((aPgtos[X_DECRESCIMOS] / aPgtos[X_VLORIGINAL]) * nValItem,2)
aPgtos[X_ACRESCIMOS]  := Round((aPgtos[X_ACRESCIMOS]  / aPgtos[X_VLORIGINAL]) * nValItem,2)


/*
For _nY := 1 To Len(aLAcrDcr)
	//                        Val desc/Acr  / Tot Geral * Valor do Item   			
	nTotE2 := aLAcrDcr[_nY,6]

	aLAcrDcr[_nY,3] := Round((aLAcrDcr[_nY,2] / nTotE2) * TMPX2->D1_TOTAL,2)
	//                        Val titulo    / Tot Geral * Valor do Item   			
	aLAcrDcr[_nY,5] := Round((aLAcrDcr[_nY,4] / nTotE2) * TMPX2->D1_TOTAL,2)
Next
*/
Return aPgtos



Static Function ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Data inicial:"    ,"Data I:"      ,"Data I:"      ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Data Final:"      ,"Data F:"      ,"Data F:"      ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Mostrar Pgto?"    ,"Mostrar Pgto?","Mostrar Pgto?","mv_ch3","N",01,0,2,"C","","mv_par03","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","   "})
AADD(aRegistros,{cPerg,"04","Pesquisar produto","Produto"      ,"Produto"      ,"mv_ch4","C",15,0,0,"G",'Vazio() .or. ExistCpo("SB1")',"mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1","S","",""})
AADD(aRegistros,{cPerg,"05","Contrato de?"     ,"Contrato de?" ,"Contrato de?" ,"mv_ch5","C",09,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"06","Contrato até?"    ,"Contrato até?","Contrato até?","mv_ch6","C",09,0,0,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"07","Listar usuários?" ,"Usuários"     ,"Usuários"     ,"mv_ch7","N",01,0,2,"C","","mv_par07","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","   "})
AADD(aRegistros,{cPerg,"08","Listar impostos?" ,"Impostos"     ,"Impostos"     ,"mv_ch8","N",01,0,2,"C","","mv_par08","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","   "})
AADD(aRegistros,{cPerg,"09","Listar PA (fin)?" ,"Listar PA"    ,"Listar PA"    ,"mv_ch9","N",01,0,2,"C","","mv_par09","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","   "})

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
