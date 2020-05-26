#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR21
BK - Relatório faturamento de reajustes, repactuação e retroativo

@Return
@author Adilson do Prado
@since 20/12/16 Rev 26/05/20
@version P12
/*/

User Function BKGCTR21()

Local cTitulo        := ""
Local aTitulos,aCampos,aCabs,aPlans

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := " "
Private nomeprog     := "BKGCTR21" // Coloque aqui o nome do programa para impressao no cabecalho
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "BKGCTR21"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private cString      := "CN9"

Private cMesEmis     := "01"
Private cAnoEmis     := "2011"
Private nPlan        := 1
Private nTipo		 := 1
Private cMes 

Public XX_PESSOA     := ""

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

IF nTipo == 1
	cMes := cAnoEmis+cMesEmis
ELSE
	cMes := cAnoEmis
ENDIF

cTitulo   := "Faturamento Reajustes, Repactuação e Retroativo :"+IIF(nTipo=1," Emissão "+cMesEmis+"/"+cAnoEmis," Anual "+cAnoEmis)

ProcRegua(1)
Processa( {|| ProcQuery() })

aCabs   := {}
aCampos := {}
aTitulos:= {}
aPlans  := {}
   
nomeprog := "BKGCTR21/"+TRIM(SUBSTR(cUsuario,7,15))
AADD(aTitulos,nomeprog+" - "+cTitulo)

AADD(aCampos,"QTMP->XX_CLIENTE")
AADD(aCabs  ,"Cliente")

AADD(aCampos,"QTMP->XX_LOJA")
AADD(aCabs  ,"Loja")

AADD(aCampos,"Posicione('SA1',1,xFilial('SA1')+QTMP->XX_CLIENTE+QTMP->XX_LOJA,'A1_NOME')")
AADD(aCabs  ,"Nome")

AADD(aCampos,"M->XX_PESSOA := Posicione('SA1',1,xFilial('SA1')+QTMP->XX_CLIENTE+QTMP->XX_LOJA,'A1_PESSOA')")
AADD(aCabs  ,"Tipo Pes.")

AADD(aCampos,"Transform(Posicione('SA1',1,xFilial('SA1')+QTMP->XX_CLIENTE+QTMP->XX_LOJA,'A1_CGC'),IIF(M->XX_PESSOA=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))")
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

AADD(aCampos,"QTMP->F2_VALFAT - QTMP->F2_VALIRRF - QTMP->F2_VALINSS - QTMP->F2_VALPIS - QTMP->F2_VALCOFI - QTMP->F2_VALCSLL - IIF(QTMP->F2_RECISS = '1',QTMP->F2_VALISS,0)")
AADD(aCabs  ,"Valor liquido")

//ProcRegua(QTMP->(LASTREC()))
//Processa( {|| U_GeraCSV("QTMP",cPerg,aTitulos,aCampos,aCabs)})

AADD(aPlans,{"QTMP",cPerg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
U_GeraXlsx(aPlans,cTitulo,cPerg,.T.)

Return


Static Function ProcQuery
Local cQuery

IncProc("Consultando o banco de dados...")

cQuery := " SELECT DISTINCT CN9_CLIENT AS XX_CLIENTE,CN9_LOJACL AS XX_LOJA,CNF_CONTRA,CNF_REVISA,CNF_COMPET," + CRLF
cQuery += "    CASE WHEN CN9_SITUAC = '05' THEN CNF_VLPREV ELSE CNF_VLREAL END AS CNF_VLPREV," + CRLF
cQuery += "    CASE WHEN CN9_SITUAC = '05' THEN CNF_SALDO  ELSE 0 END AS CNF_SALDO, " + CRLF
cQuery += "    CTT_DESC01, " + CRLF
cQuery += "    CNA_NUMERO,CNA_XXMUN, " + CRLF
cQuery += "    CND_NUMMED, " + CRLF
cQuery += "    C6_NUM, " + CRLF

// 18/11/14 - Campos XX_BONIF alterado de '2' para '1' e XX_MULTA alrterado de '1' para '2'
cQuery += "    (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CND_NUMMED = CNR_NUMMED"
cQuery += "         AND  CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '1') AS XX_BONIF,"

cQuery += "    (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CND_NUMMED = CNR_NUMMED"
cQuery += "         AND  CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2') AS XX_MULTA," + CRLF

cQuery += "    F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS, "  + CRLF

cQuery += "    (SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC" + CRLF
cQuery += "        AND  E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' ') AS XX_VENCTO " + CRLF

cQuery += " FROM "+RETSQLNAME("CNF")+" CNF" + CRLF

cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09' " + CRLF
cQuery += "      AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA" + CRLF
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '" + CRLF
cQuery += " INNER JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA" + CRLF
cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CND_PARCEL = CNF_PARCEL AND CNA_NUMERO = CND_NUMERO AND CND_REVISA = CNF_REVISA" + CRLF
cQuery += "      AND  CND.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM" + CRLF
cQuery += "      AND  C6_FILIAL = CND_FILIAL AND  SC6.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+ " SF2 ON C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC" + CRLF
cQuery += "      AND  F2_FILIAL = CND_FILIAL AND  SF2.D_E_L_E_T_ = ' '" + CRLF

IF nTipo == 1
	cQuery += " WHERE SUBSTRING(F2_EMISSAO,1,6) = '"+cMes+"' " + CRLF
ELSE
	cQuery += " WHERE SUBSTRING(F2_EMISSAO,1,4) = '"+cMes+"' " + CRLF
ENDIF

cQuery += " AND CNF_FILIAL = '"+xFilial("CNF")+"' AND CNA_XXTIPO='2' AND  CNF.D_E_L_E_T_ = ' '" + CRLF

cQuery += " ORDER BY CNF_CONTRA,CNF_REVISA,CNF_COMPET,F2_DOC" + CRLF

u_LogMemo("BKGCTR21.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","F2_EMISSAO","D",8,0)
TCSETFIELD("QTMP","XX_VENCTO","D",8,0)

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
