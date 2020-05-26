#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR08
BK - Mapa de Mediçoes c/ historico

@Return
@author Marcos Bispo Abrahão
@since 19/01/12 rev 19/05/20
@version P11/P12
/*/

User Function BKGCTR08()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local titulo         := ""
Local aTitulos,aCampos,aCabs

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := " "
Private nomeprog     := "BKGCTR08" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "BKGCTR08"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
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

cMes := cAnoComp+cMesComp

titulo   := "Mapa de Medições : Competencia "+cMesComp+"/"+cAnoComp

If .f. //nPlan = 2

Else
	ProcRegua(1)
	Processa( {|| ProcQuery() })

	aCabs   := {}
	aCampos := {}
	aTitulos:= {}
	
	aCampos2:= {}
	aCabs2  := {}
   
	nomeprog := "BKGCTR08/"+TRIM(SUBSTR(cUsuario,7,15))
	AADD(aTitulos,nomeprog+" - "+titulo)

	AADD(aCampos,"QTMP->CNF_CONTRA")
	AADD(aCabs  ,"Contrato")

	//AADD(aCampos,"QTMP->CNF_REVISA")
	//AADD(aCabs  ,"Revisão")

	AADD(aCampos,"QTMP->CTT_DESC01")
	AADD(aCabs  ,"Centro de Custos")

	//AADD(aCampos,"QTMP->CNA_NUMERO")
	//AADD(aCabs  ,"Planilha")

	//AADD(aCampos,"QTMP->CNA_XXMUN")
	//AADD(aCabs  ,"Municipio")

	AADD(aCampos,"QTMP->CNF_COMPET")
	AADD(aCabs  ,"Competencia")

	//AADD(aCampos,"QTMP->CND_NUMMED")
	//AADD(aCabs  ,"Medição")

	//AADD(aCampos,"QTMP->C6_NUM")
	//AADD(aCabs  ,"Pedido")
   
	//AADD(aCampos,"QTMP->F2_DOC")
	//AADD(aCabs  ,"Nota Fiscal")

	//AADD(aCampos,"QTMP->F2_EMISSAO")
	//AADD(aCabs  ,"Emissao")
   
	//AADD(aCampos,"QTMP->XX_VENCTO")
	//AADD(aCabs  ,"Vencimento")

	AADD(aCampos,"QTMP->CNF_VLPREV")
	AADD(aCabs  ,"Valor Previsto")

	AADD(aCampos,"QTMP->CNF_SALDO")
	AADD(aCabs  ,"Saldo Previsto")

	AADD(aCampos,"QTMP->F2_VALFAT")
	AADD(aCabs  ,"Valor faturado")

	//AADD(aCampos,"QTMP->CNF_VLPREV - QTMP->F2_VALFAT")
	//AADD(aCabs  ,"Previsto - Faturado")

	AADD(aCampos,"QTMP->XX_BONIF")
	AADD(aCabs  ,"Bonificações do mes")

	AADD(aCampos,"QTMP->XX_MULTA")
	AADD(aCabs  ,"Multas no mes")

	//AADD(aCampos,"QTMP->XX_MULANT")
	//AADD(aCabs  ,"Multas Anteriores")

	//AADD(aCampos,"QTMP->XX_BONANT")
	//AADD(aCabs  ,"Bonificações Anteriores")

	AADD(aCampos,"QTMP->XX_MULANT - QTMP->XX_BONANT")
	AADD(aCabs  ,"Sobras Anteriores")


	//AADD(aCampos,"QTMP->F2_VALIRRF")
	//AADD(aCabs  ,"IRRF Retido")

	//AADD(aCampos,"QTMP->F2_VALINSS")
	//AADD(aCabs  ,"INSS Retido")

	//AADD(aCampos,"QTMP->F2_VALPIS")
	//AADD(aCabs  ,"PIS Retido")

	//AADD(aCampos,"QTMP->F2_VALCOFI")
	//AADD(aCabs  ,"COFINS Retido")

	//AADD(aCampos,"QTMP->F2_VALCSLL")
	//AADD(aCabs  ,"CSLL Retido")

	//AADD(aCampos,"IIF(QTMP->F2_RECISS = '1',QTMP->F2_VALISS,0)")
	//AADD(aCabs  ,"ISS Retido")

	//AADD(aCampos,"QTMP->F2_VALFAT - QTMP->F2_VALIRRF - QTMP->F2_VALINSS - QTMP->F2_VALPIS - QTMP->F2_VALCOFI - QTMP->F2_VALCSLL - IIF(QTMP->F2_RECISS = '1',QTMP->F2_VALISS,0)")
	//AADD(aCabs  ,"Valor liquido")


	AADD(aCampos2,"STRTRAN(ALLTRIM(QTMP2->CND_XXDETG),';',',')")
	AADD(aCabs2  ,"Desc. Mult/Bon")

	AADD(aCampos2,"STRTRAN(ALLTRIM(QTMP2->CND_XXJUST),';',',')")
	AADD(aCabs2  ,"Just.Mult/Bon")

	AADD(aCampos2,"STRTRAN(ALLTRIM(QTMP2->CND_XXACAO),';',',')")
	AADD(aCabs2  ,"Acao Mult/Bon")

	AADD(aCampos2,"QTMP2->CND_XXDTAC")
	AADD(aCabs2  ,"Data Acao Mult/Bon")
    
	AADD(aCampos2,"QTMP2->CND_XXPOST")
	AADD(aCabs2  ,"Qtd. Postos")

	AADD(aCampos2,"QTMP2->CND_XXFUNC")
	AADD(aCabs2  ,"Qtd. Funcionarios")

	AADD(aCampos2,"QTMP2->CND_XXNFUN")
	AADD(aCabs2  ,"Qtd. Func. Atual")

	AADD(aCampos2,"STRTRAN(ALLTRIM(QTMP2->CND_XXJFUN),';',',')")
	AADD(aCabs2  ,"Just.Num.Funcion")
	cQuery2 := ""

	ProcRegua(QTMP->(LASTREC()))
	
	Processa( {|| U_GeraCSV2("QTMP",cPerg,aTitulos,aCampos,aCabs,cQuery2,"QTMP2",aCampos2,aCabs2)})
   
EndIf	
Return


Static Function ProcQuery
Local cQuery

IncProc("Consultando o banco de dados...")


cQuery := " SELECT DISTINCT CNF_CONTRA,CNF_REVISA,CNF_COMPET,"+ CRLF
cQuery += "    CASE WHEN CN9_SITUAC = '05' THEN CNF_VLPREV ELSE CNF_VLREAL END AS CNF_VLPREV,"+ CRLF
cQuery += "    CASE WHEN CN9_SITUAC = '05' THEN CNF_SALDO  ELSE 0 END AS CNF_SALDO, "+ CRLF
cQuery += "    CTT_DESC01, "+ CRLF
cQuery += "    CNA_NUMERO, "+ CRLF
cQuery += "    CND_NUMERO, "+ CRLF
//cQuery += "    CNA_XXMUN, "+ CRLF
cQuery += "    CND_NUMMED, "+ CRLF
//cQuery += "    C6_NUM, "+ CRLF
cQuery += "    CNF_PARCEL, "+ CRLF

cQuery += "    (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CND_NUMMED = CNR_NUMMED"+ CRLF
cQuery += "         AND CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '1') AS XX_BONIF,"+ CRLF

cQuery += "    (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CND_NUMMED = CNR_NUMMED"+ CRLF
cQuery += "         AND CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2') AS XX_MULTA,"+ CRLF

// Somar Bonificações Anteriores
cQuery += "    (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR "+ CRLF
cQuery += "         INNER JOIN "+RETSQLNAME("CND")+ " CNDB ON CNDB.CND_NUMMED = CNR_NUMMED AND"+ CRLF
cQuery += "                      SUBSTRING(CNDB.CND_COMPET,4,4)+SUBSTRING(CNDB.CND_COMPET,1,2) < '"+cAnoComp+cMesComp+"'" + CRLF
cQuery += "                      AND CNDB.CND_CONTRA = CNF_CONTRA AND CNDB.CND_REVISA = CNF_REVISA "+ CRLF
//cQuery += "                      AND CNDB.CND_PARCEL = CNF_PARCEL "+ CRLF
cQuery += "                      AND CNDB.D_E_L_E_T_ = ' '"+ CRLF
cQuery += "         WHERE CNR_FILIAL = CNDB.CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '1') AS XX_BONANT,"+ CRLF

// Somar Multas Anteriores
cQuery += "    (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR "+ CRLF
cQuery += "         INNER JOIN "+RETSQLNAME("CND") + " CNDB ON CNDB.CND_NUMMED = CNR_NUMMED AND" + CRLF
cQuery += "                      SUBSTRING(CNDB.CND_COMPET,4,4)+SUBSTRING(CNDB.CND_COMPET,1,2) < '"+cAnoComp+cMesComp+"'" + CRLF
cQuery += "                      AND CNDB.CND_CONTRA = CNF_CONTRA AND CNDB.CND_REVISA = CNF_REVISA "+ CRLF
//cQuery += "                      AND CNDB.CND_PARCEL = CNF_PARCEL "
cQuery += "                      AND CNDB.D_E_L_E_T_ = ' '"+ CRLF
cQuery += "         WHERE CNR_FILIAL = CNDB.CND_FILIAL AND  CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2') AS XX_MULANT,"+ CRLF


cQuery += "    F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS, " + CRLF

cQuery += "    (SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "        AND  E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' ') AS XX_VENCTO "+ CRLF

cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+ CRLF

cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9.CN9_SITUAC NOT IN ('01','02','08','09','10') "+ CRLF
cQuery += "      AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+ CRLF
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA"+ CRLF
cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CNA_NUMERO = CND_NUMERO AND CND_PARCEL = CNF_PARCEL AND CND_REVISA = CNA_REVISA"+ CRLF
cQuery += "      AND  CND.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM"+ CRLF
cQuery += "      AND  C6_FILIAL = CND.CND_FILIAL AND SC6.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+ " SF2 ON C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC"+ CRLF
cQuery += "      AND  F2_FILIAL = CND.CND_FILIAL AND SF2.D_E_L_E_T_ = ' '"+ CRLF

cQuery += " WHERE CNF_COMPET = '"+cCompet+"'"+ CRLF
// para teste cQuery += " WHERE SUBSTRING(F2_EMISSAO,1,6) = "+cMes

cQuery += "      AND  CNF_FILIAL = '"+xFilial("CNF")+"' AND  CNF.D_E_L_E_T_ = ' '"+ CRLF

cqContr:= "(SELECT TOP 1 C5_MDCONTR FROM "+RETSQLNAME("SC6")+ " SC6 INNER JOIN "+RETSQLNAME("SC5")+" SC5 ON C5_FILIAL = C6_FILIAL AND C6_NUM = C5_NUM AND C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ') "+ CRLF
cqEspec:= "(SELECT TOP 1 C5_ESPECI1 FROM "+RETSQLNAME("SC6")+ " SC6 INNER JOIN "+RETSQLNAME("SC5")+" SC5 ON C5_FILIAL = C6_FILIAL AND C6_NUM = C5_NUM AND C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ') "+ CRLF


cQuery += " UNION ALL "+ CRLF
cQuery += " SELECT "+ CRLF
cQuery += "        CASE WHEN "+cqEspec+" = ' ' THEN 'XXXXXXXXXX' ELSE "+cqEspec+" END,"+ CRLF
cQuery += "        ' ',' ',0,0, "  // CNF_CONTRA,CNF_REVISA,CNF_COMPET,CNF_VLPREV,CNF_SALDO
cQuery += "        A1_NOME, "  // CTT_DESC01
cQuery += "        ' ', "  // CNA_NUMERO
cQuery += "        ' ', "  // CND_NUMERO
//cQuery += "        ' ', "  // CNA_XXMUN
cQuery += "        ' ', "      // CND_NUMMED
//cQuery += "        ' ', "      // C6_NUM
cQuery += "        ' ', "      // CNF_PARCEL
cQuery += "        0,0,0,0, "+ CRLF      // XX_BONIF,XX_MULTA
cQuery += "        F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS, " + CRLF
cQuery += "        (SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+" SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "            AND  E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' ') AS XX_VENCTO "+ CRLF

cQuery += " FROM "+RETSQLNAME("SF2")+" SF2"+ CRLF
//cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = "+cqContr
//cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '""
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA"+ CRLF
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " WHERE ("+cqContr+" = ' ' OR "+ CRLF
cQuery +=           cqContr+" IS NULL ) "+ CRLF
cQuery += "      AND SUBSTRING(F2_EMISSAO,1,6) = '"+cMes+"'" + CRLF
cQuery += "      AND SF2.D_E_L_E_T_ = ' '"+ CRLF

//cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = C6_CONTRA"
//cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '""

//cQuery += " ORDER BY F2_DOC"  

cQuery += " ORDER BY CNF_CONTRA,CNF_REVISA,CNF_COMPET,F2_DOC" + CRLF

u_LogMemo("BKGCTR08.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","F2_EMISSAO","D",8,0)
TCSETFIELD("QTMP","XX_VENCTO","D",8,0)

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
Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Mes de Competencia"  ,"" ,"" ,"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Ano de Competencia"  ,"" ,"" ,"mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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

/*
USER FUNCTION BKCNR08(cNumMed,cTipo)
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
*/

                       

User Function GeraCSV2(_cAlias,cArqS,aTitulos,aCampos,aCabs,cQuery2,_cAlias2,aCampos2,aCabs2)

Local nHandle
Local cCrLf   := Chr(13) + Chr(10)
Local _ni,_nj
Local cPicN   := "@E 99999999.99999"
Local cDirTmp := "C:\TMP"
Local cArqTmp := cDirTmp+"\"+cArqS+".CSV"
Local lSoma,aSoma,nCab
Local cLetra

Local cContra := ""

Private xQuebra,xCampo

MakeDir(cDirTmp)
fErase(cArqTmp)

//If fErase(cArqTmp) == -1
//   MsgStop('O arquivo '+cArqTmp+' esta em uso ( FError'+str(ferror(),4)+ ')')
//   Return
//EndIf

lSoma := .F.
aSoma := {}
nCab  := 0

nHandle := MsfCreate(cArqTmp,0)
   
If nHandle > 0
      
   FOR _ni := 1 TO LEN(aTitulos)
      fWrite(nHandle, aTitulos[_ni])
      fWrite(nHandle, cCrLf ) // Pula linha
      nCab++
   NEXT

   FOR _ni := 1 TO LEN(aCabs)
       fWrite(nHandle, aCabs[_ni] + ";" )
   NEXT

   FOR _ni := 1 TO LEN(aCabs2)
       fWrite(nHandle, aCabs2[_ni] + IIF(_ni < LEN(aCabs2),";",""))
   NEXT


   fWrite(nHandle, cCrLf ) // Pula linha
   nCab++

   (_cAlias)->(dbgotop())
   
   cContra := ""  //(_cAlias)->CNF_CONTRA
   
   Do While (_cAlias)->(!eof())

     IF (_cAlias)->XX_BONIF == 0 .AND. (_cAlias)->XX_MULTA == 0 .AND. (_cAlias)->CNF_SALDO == 0
 		(_cAlias)->(dbSkip())
		LOOP
      ENDIF

      IF !lSoma
         For _ni :=1 to LEN(aCampos)
             xCampo := &(aCampos[_ni])
             If VALTYPE(xCampo) == "N" // Trata campos numericos
                cLetra := CHR(_ni+64)
                IF cLetra > "Z"
                   cLetra := "A"+CHR(_ni+64-26)
                ENDIF
                AADD(aSoma,'=Soma('+cLetra+ALLTRIM(STR(nCab))+':')
             Else
                AADD(aSoma,"")
             Endif
         Next
         lSoma := .T.
      ENDIF
   
      IncProc("Gerando arquivo "+cArqS)   

      For _ni :=1 to LEN(aCampos)

         xCampo := &(aCampos[_ni])
            
         _uValor := ""
            
         If VALTYPE(xCampo) == "D" // Trata campos data
            _uValor := dtoc(xCampo)
         Elseif VALTYPE(xCampo) == "N" // Trata campos numericos
         	IF (cContra == (_cAlias)->CNF_CONTRA) .AND. (aCampos[_ni] == "QTMP->XX_MULANT")
               _uValor := transform(0,cPicN)
         	ELSEIF (cContra == (_cAlias)->CNF_CONTRA) .AND. (aCampos[_ni] == "QTMP->XX_BONANT")
               _uValor := transform(0,cPicN)
         	ELSEIF (cContra == (_cAlias)->CNF_CONTRA) .AND. (aCampos[_ni] == "QTMP->XX_MULANT - QTMP->XX_BONANT")
               _uValor := transform(0,cPicN)
            ELSE
               _uValor := transform(xCampo,cPicN)
            ENDIF   
         Elseif VALTYPE(xCampo) == "C" // Trata campos caracter
             //_uValor := xCampo+CHR(160)
            _uValor := '="'+ALLTRIM(xCampo)+'"'
         Endif
            
         fWrite(nHandle, _uValor + ";" )
      Next _ni

      cContra := (_cAlias)->CNF_CONTRA

      //nCab++   


//Select CONVERT(VARCHAR(8000),CONVERT(Binary(8000),XML_SIG)) XML_SIG from SPED050

	  cQuery2 := "SELECT CONVERT(VARCHAR(8000),CONVERT(Binary(8000),CND_XXDETG)) CND_XXDETG, "
	  cQuery2 += "	     CONVERT(VARCHAR(8000),CONVERT(Binary(8000),CND_XXJUST)) CND_XXJUST, "
	  cQuery2 += "	     CONVERT(VARCHAR(8000),CONVERT(Binary(8000),CND_XXACAO)) CND_XXACAO, "
	  cQuery2 += "	     CONVERT(VARCHAR(8000),CONVERT(Binary(8000),CND_XXJFUN)) CND_XXJFUN, "
	  cQuery2 += "	     CND_XXDTAC,CND_XXPOST,CND_XXFUNC,CND_XXNFUN "
      cQuery2 += " FROM "+RETSQLNAME("CND")+" CND"
      cQuery2 += " WHERE CND.D_E_L_E_T_ = ' '  AND CND_CONTRA = '"+ALLTRIM(QTMP->CNF_CONTRA)+"'"
      cQuery2 += " AND CND_COMPET = '"+ALLTRIM(QTMP->CNF_COMPET)+"' "
      cQuery2 += " AND CND_NUMERO = '"+QTMP->CNA_NUMERO+"' "
      cQuery2 += " AND CND_PARCEL = '"+QTMP->CNF_PARCEL+"' "
      cQuery2 += " AND CND_REVISA = '"+QTMP->CNF_REVISA+"' " 
      cQuery2 += " AND CND_NUMMED = '"+QTMP->CND_NUMMED+"' " 
      
      TCQUERY cQuery2 NEW ALIAS "QTMP2"
      TCSETFIELD("QTMP2","CND_XXDTAC","D",8,0)
      
      dbSelectArea(_cAlias2)
      dbGoTop()
      lC1 := .T.
	  DO WHILE !EOF()
		 IF !lC1
			 For _nJ :=1 to LEN(aCampos)
            	fWrite(nHandle, " ;" )
   			 Next _nJ
		 ENDIF   
         lC1 := .F.

	     For _ni := 1 to LEN(aCampos2)
	         xCampo := &(aCampos2[_ni])
	            
	         _uValor := ""
	            
	         If VALTYPE(xCampo) == "D" // Trata campos data
	            _uValor := dtoc(xCampo)
	         Elseif VALTYPE(xCampo) == "N" // Trata campos numericos
	         	IF ALLTRIM(aCampos[_ni]) $ "QTMP2->CND_XXPOST/QTMP2->CND_XXFUNC/QTMP2->CND_XXNFUN"
	         		_uValor := STR(xCampo,6)
	         	ELSE
	           		 _uValor := transform(xCampo,cPicN)
	            ENDIF
	         Elseif VALTYPE(xCampo) == "C" .OR. VALTYPE(xCampo) == "M"// Trata campos caracter
	             //_uValor := xCampo+CHR(160)
	            //_uValor := '="'+ALLTRIM(xCampo)+'"'
                //_uValor := '="'+STRTRAN(ALLTRIM(xCampo),";",",")+'"'
                _uValor := '="'
                xCampo := ALLTRIM(xCampo)
                for nxx := 1 to len(xCampo)
                	xxChar := SUBSTR(xCampo,nxx,1)
                	IF ASC(xxChar) >= 32 //.AND. ASC(xxChar) <= 128
                       _uValor += SUBSTR(xCampo,nxx,1) 
                    ENDIF
                next
                _uValor += '"'
	         Endif
            
	         fWrite(nHandle, _uValor + IIF(_ni < LEN(aCampos2),";",""))

	     Next _ni
	     
         fWrite(nHandle, cCrLf ) // Pula linha
         nCab++
		 dbSkip()

	  ENDDO

      dbSelectArea(_cAlias2)
	  (_cAlias2)->(dbCloseArea())

      dbSelectArea(_cAlias)

   
	  IF lC1
      	fWrite(nHandle, cCrLf ) // Pula linha
      	nCab++
      Endif
      (_cAlias)->(dbskip())
         
   Enddo
   IF lSoma
	   FOR _ni := 1 TO LEN(aCampos)
           cLetra := CHR(_ni+64)
           IF cLetra > "Z"
              cLetra := "A"+CHR(_ni+64-26)
           ENDIF
	       IF !EMPTY(aSoma[_ni])
              aSoma[_ni] += cLetra+ALLTRIM(STR(nCab))+')'
	       ENDIF
	       fWrite(nHandle, aSoma[_ni] + IIF(_ni < LEN(aCampos),";",""))
	   NEXT
   ENDIF	
      
   fClose(nHandle)
      
   MsgInfo("O arquivo "+cArqTmp+" será aberto no MsExcel","BKGCTR08")
   ShellExecute("open", cArqTmp,"","",1)

Else
   MsgAlert("Falha na criação do arquivo "+cArqTmp,"BKGCTR08")
Endif
   
(_cAlias)->(dbCloseArea())
   
Return
