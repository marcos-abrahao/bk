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


STATIC Function BKGCTR1X()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local titulo         := ""
Local nLin           := 80
Local Cabec1         := ""
Local Cabec2         := ""
Local aOrd           := {}
Local aTitulos,aCampos,aCabs,aPlans := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := " "
Private nomeprog     := "BKGCTR01" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "BKGCTR01"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "BKGCTR01" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString      := "CN9"

Private cMesComp     := "01"
Private cAnoComp     := "2010"
Private nPlan        := 1
Private cMes 

dbSelectArea(cString)
dbSetOrder(1)

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
	
	nomeprog := "BKGCTR01/"+TRIM(SUBSTR(cUsuario,7,15))
	ProcRegua(1)
	Processa( {|| ProcQuery() })
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	
Else
	ProcRegua(1)
	Processa( {|| ProcQuery() })

	aCabs   := {}
	aCampos := {}
	aTitulos:= {}
   
	nomeprog := "BKGCTR01/"+TRIM(SUBSTR(cUsuario,7,15))
	AADD(aTitulos,titulo)

	AADD(aCampos,"QTMP->CNF_CONTRA")
	AADD(aCabs  ,"Contrato")

	AADD(aCampos,"QTMP->CNF_REVISA")
	AADD(aCabs  ,"Revisão")

	AADD(aCampos,"QTMP->CTT_DESC01")
	AADD(aCabs  ,"Centro de Custos")

	AADD(aCampos,"U_BUSCACN9(QTMP->CNF_CONTRA,'CN9_XXNRBK')")
	AADD(aCabs  ,"Gestor "+ALLTRIM(SM0->M0_NOME))

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

	IF cMotMulta = "S"
		// 18/11/14 - Campos XX_BONIF alterado de '2' para '1' e XX_MULTA alrterado de '1' para '2'

		AADD(aCampos,"U_BKCNR01(QTMP->CND_NUMMED,'1')")
		AADD(aCabs  ,"Motivo Bonificação")

		AADD(aCampos,"U_BKCNR01(QTMP->CND_NUMMED,'2')")
		AADD(aCabs  ,"Motivo Multa")

	ENDIF
	//If nPlan == 1
	//	ProcRegua(QTMP->(LASTREC()))
	//	Processa( {|| U_GeraCSV("QTMP",wnrel,aTitulos,aCampos,aCabs)})
	//Else	
		AADD(aPlans,{"QTMP",wnrel,"",Titulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
		U_GeraXlsx(aPlans,Titulo,wnrel,.F.)
	//EndIf
	   
EndIf	
Return


Static Function ProcQuery
Local cQuery

IncProc("Consultando o banco de dados...")

/*

*/

cQuery := " SELECT DISTINCT CNF_CONTRA,CNF_REVISA,CNF_COMPET,CN9_XXNRBK,"+ CRLF
cQuery += "    CASE WHEN CN9_SITUAC = '05' THEN CNF_VLPREV ELSE CNF_VLREAL END AS CNF_VLPREV,"+ CRLF
cQuery += "    CASE WHEN CN9_SITUAC = '05' THEN CNF_SALDO  ELSE 0 END AS CNF_SALDO, "+ CRLF
cQuery += "    CTT_DESC01, "+ CRLF
cQuery += "    CNA_NUMERO,CNA_XXMUN, "+ CRLF
cQuery += "    CND_NUMMED, "+ CRLF
cQuery += "    C6_NUM, "+ CRLF
cQuery += "    C6_DATCPL AS C5_EMISSAO, "+ CRLF

// 18/11/14 - Campos XX_BONIF alterado de '2' para '1' e XX_MULTA alterado de '1' para '2'
cQuery += "    (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CND_NUMMED = CNR_NUMMED"+ CRLF
cQuery += "         AND  CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '1') AS XX_BONIF,"+ CRLF

cQuery += "    (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CND_NUMMED = CNR_NUMMED"+ CRLF
cQuery += "         AND  CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2') AS XX_MULTA,"+ CRLF

cQuery += "    F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS, " + CRLF

cQuery += "    (SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "        AND  SE1.D_E_L_E_T_ = ' ') AS XX_VENCTO "+ CRLF

cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+ CRLF

cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+ CRLF
cQuery += "      AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+ CRLF
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_CONTRA = CNF_CONTRA AND CNA_REVISA = CNF_REVISA"+ CRLF
cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CNA_NUMERO = CND_NUMERO AND CND_PARCEL = CNF_PARCEL AND CND_REVISA = CNA_REVISA"+ CRLF
cQuery += "      AND  CND.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM"+ CRLF
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
cQuery += "        ' ', " + CRLF     // CND_NUMMED
cQuery += "        D2_PEDIDO AS C6_NUM, "      // C6_NUM
cQuery += "        C5_EMISSAO, "+ CRLF
cQuery += "        0,0, " + CRLF     // XX_BONIF,XX_MULTA
cQuery += "        F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS, " + CRLF
cQuery += "        (SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+" SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "            AND  SE1.D_E_L_E_T_ = ' ') AS XX_VENCTO "+ CRLF

cQuery += " FROM "+RETSQLNAME("SF2")+" SF2"+ CRLF
//cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = "+cqContr
//cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '""
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA"+ CRLF
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SD2")+ " SD2 ON D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA" + CRLF
cQuery += "      AND  D2_FILIAL = F2_FILIAL AND SD2.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON C5_NUM = D2_PEDIDO " + CRLF
cQuery += "      AND  C5_FILIAL = D2_FILIAL AND  SD2.D_E_L_E_T_ = ' '" + CRLF
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
u_LogMemo("BKGCTR01.SQL",cQuery)

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

Local lCabec

Dbselectarea("QTMP")
Dbgotop()

SetRegua(LastRec())

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
SetRegua(LastRec())        

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


Static Function  ValidPerg(cPerg)

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


USER FUNCTION BKCNR01(cNumMed,cTipo)
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

                        
