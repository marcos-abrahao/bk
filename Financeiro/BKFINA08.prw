#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINA08()
BK - Resumo do Faturamento

Integrado com o aplicativo : http://intranet.bkinformatica.com/WebIntegraRubi/

Gera mensalmente, através de interface com usuario, o resumo mensal conforme 
parametros, na tabela SZ8010.

@author Marcos B. Abrahão
@since 05/05/11 rev 18/05/20
@version P12
@return Nil
/*/
//-------------------------------------------------------------------


User Function BKFINA08()
Local cQuery,nCount

Private cPerg := "BKFINA08"
Private cMesComp
Private cAnoComp
Private nPlan

Private lProc := .T.

ValidPerg(cPerg)

If !Pergunte(cPerg,.T.)
	Return
Endif
	
cMesComp := STRZERO(VAL(mv_par01),2)
cAnoComp := STRZERO(VAL(mv_par02),4)
nPlan    := mv_par03
	
If VAL(cMesComp) < 1 .OR. VAL(cMesComp) > 12
	MsgStop("Mes incorreto")
	Return
EndIf
	
If VAL(cAnoComp) < 2009 .OR. VAL(cAnoComp) > 2030
	MsgStop("Ano incorreto")
	Return
EndIf

// Verificar se há processos de integração em andamento
cQuery  := "SELECT COUNT(*) AS Z8COUNT " 
cQuery  += "FROM "+RETSQLNAME("SZ8")+" SZ8 "
cQuery  += "WHERE Z8_ANOMES = '"+cAnoComp+cMesComp+"' "
cQuery  += "AND Z8_STATUS = 'S' "
cQuery  += "AND SZ8.D_E_L_E_T_ <> '*' "
	
TCQUERY cQuery NEW ALIAS "QSZ8"
//TCSETFIELD("QSZ2","XX_DATAPGT","D",8,0)
	
DbSelectArea("QSZ8")
DbGoTop()
nCount := QSZ8->Z8COUNT
QSZ8->(dbCloseArea())
	
IF nCount > 0
	IF MsgYesNo("Competência já foi processada, deseja reprocessar?")
		lProc := .T.
	Else
		lProc := .F.
	EndIf   
EndIf
	
If lProc
	F08Taxas()
EndIf

If nPlan = 1
	GeraPl1()
	GeraPl2()
EndIf


Return Nil
                        


Static Function F08Taxas

Local oOk
Local oNo
Local oDlg
Local oPanelLeft
Local aButtons := {}

Local lOk      := .F.
Local aAreaIni := GetArea()
Local nLin
Local cMesAnt,cAnoAnt

Local oSay1,oPis
Local oSay2,oCof
Local oSay3,oCrdPc
Local oSay4,oTxAdm
Local oSay5,oIRPJ
Local oSay6,oAdIRPJ
Local oSay7,oCSLL

Private nPis   := 0
Private nCof   := 0
Private nCrdPc := 0
Private nTxAdm := 0
Private nIRPJ  := 0
Private nAdIRPJ:= 0
Private nCSLL  := 0

Private cCompet := cMesComp+"/"+cAnoComp

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

dbSelectArea("SZA")
dbGoTop()
If dbSeek(xFilial("SZA")+cAnoComp+cMesComp,.F.)
	nPis   := SZA->ZA_PIS
	nCof   := SZA->ZA_COF
	nCrdPc := SZA->ZA_CRDPC
	nTxAdm := SZA->ZA_TXADM
	nIRPJ  := SZA->ZA_IRPJ
	nAdIRPJ:= SZA->ZA_ADIRPJ
	nCSLL  := SZA->ZA_CSLL
Else
	cMesAnt := STRZERO(VAL(cMesComp) - 1,2)
	cAnoAnt := cAnoComp
	If VAL(cMesAnt) < 1
		cMesAnt := "01"
		cAnoAnt := STRZERO(VAL(cAnoAnt) - 1,4)
    EndIf
	If dbSeek(xFilial("SZA")+cAnoAnt+cMesAnt,.F.)
		nPis   := SZA->ZA_PIS
		nCof   := SZA->ZA_COF
		nCrdPc := SZA->ZA_CRDPC
		nTxAdm := SZA->ZA_TXADM
		nIRPJ  := SZA->ZA_IRPJ
		nAdIRPJ:= SZA->ZA_ADIRPJ
		nCSLL  := SZA->ZA_CSLL
	EndIf
EndIf



DEFINE MSDIALOG oDlg TITLE "Resumo Mensal de Faturamento "+cCompet FROM 000,000 TO 400,630 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 320,225
oPanelLeft:Align := CONTROL_ALIGN_LEFT

nLin := 15

@ nLin, 010 SAY oSay1 PROMPT "Pis:" SIZE 040, 010 OF oPanelLeft PIXEL
@ nLin, 060 MSGET oPis  VAR nPis    SIZE 040, 010 OF oPanelLeft PICTURE "@E 99.99" PIXEL
      
nLin+= 17
@ nLin, 010 SAY oSay2 PROMPT "Cofins:" SIZE 040, 010 OF oPanelLeft PIXEL
@ nLin, 060 MSGET oCof  VAR nCof       SIZE 040, 010 OF oPanelLeft PICTURE "@E 99.99" PIXEL

nLin+= 17
@ nLin, 010 SAY oSay3 PROMPT "Cred. Pis/Cofins:" SIZE 040, 010 OF oPanelLeft PIXEL
@ nLin, 060 MSGET oCrdPC  VAR nCrdPC             SIZE 040, 010 OF oPanelLeft PICTURE "@E 99.99" PIXEL

nLin+= 17
@ nLin, 010 SAY oSay4 PROMPT "Tx. Adm:" SIZE 040, 010 OF oPanelLeft PIXEL
@ nLin, 060 MSGET oTxAdm  VAR nTxAdm    SIZE 040, 010 OF oPanelLeft PICTURE "@E 99.99" PIXEL

nLin+= 17
@ nLin, 010 SAY oSay5 PROMPT "IRPJ:" SIZE 040, 010 OF oPanelLeft PIXEL
@ nLin, 060 MSGET oIRPJ  VAR nIRPJ   SIZE 040, 010 OF oPanelLeft PICTURE "@E 99.99" PIXEL

nLin+= 17
@ nLin, 010 SAY oSay6 PROMPT "Adic. IRPJ:" SIZE 040, 010 OF oPanelLeft PIXEL
@ nLin, 060 MSGET oAdIRPJ  VAR nAdIRPJ     SIZE 040, 010 OF oPanelLeft PICTURE "@E 99.99" PIXEL

nLin+= 17
@ nLin, 010 SAY oSay7 PROMPT "CSLL:" SIZE 040, 010 OF oPanelLeft PIXEL
@ nLin, 060 MSGET oCSLL  VAR nCSLL   SIZE 040, 010 OF oPanelLeft PICTURE "@E 99.99" PIXEL

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

If ( lOk )


    dbSelectArea("SZA")
	If dbSeek(xFilial("SZA")+cAnoComp+cMesComp,.F.)
		RecLock("SZA",.F.)
	Else
		RecLock("SZA",.T.)
		SZA->ZA_FILIAL := xFilial("SZA")
		SZA->ZA_ANOMES := cAnoComp+cMesComp	
	EndIf
	
	SZA->ZA_PIS    := nPis
	SZA->ZA_COF    := nCof
	SZA->ZA_CRDPC  := nCrdPC
	SZA->ZA_TXADM  := nTxAdm
	SZA->ZA_IRPJ   := nIRPJ
	SZA->ZA_ADIRPJ := nAdIRPJ
	SZA->ZA_CSLL   := nCSLL

	MsUnlock()

	Processa( {|| RunPrc1() } )
	Processa( {|| RunPrc2() } )

Endif

RestArea(aAreaIni)
Return



Static Function RunPrc1()

Local cMes    := ""
Local cqContr := ""
Local cqEspec := ""
Local cqCompt := ""

Private cCompet := cMesComp+"/"+cAnoComp

//nMes := VAL(cMesComp) + 1
//nAno := VAL(cAnoComp)
//IF nMes = 13
//   nMes := 1
//   nAno := nAno + 1
//ENDIF

//cMes := STR(nAno,4)+STRZERO(nMes,2)   

cMes := cAnoComp+cMesComp

// Faturamento
// Excluindo processo anterior, se houver
dbSelectArea("SZ8")
dbSetOrder(1)
dbGoTop()
cFilZ8 := xFilial("SZ8")
dbSeek(cFilZ8+cAnoComp+cMesComp,.T.)
Do While !EOF() .AND. cFilZ8+cAnoComp+cMesComp == SZ8->Z8_FILIAL+SZ8->Z8_ANOMES 
	IncProc("Excluindo resumo anterior - Faturamento")
	RecLock("SZ8",.F.)
	dbDelete()
/*
	SZ8->Z8_VALFAT:= 0
	SZ8->Z8_PIS   := 0
	SZ8->Z8_COF   := 0
	SZ8->Z8_ISS   := 0
	SZ8->Z8_CRDPC := 0
	SZ8->Z8_TXADM := 0
*/
	MsUnlock()
    dbSkip()
EndDo
/*
cQuery := " SELECT "

cQuery += "  F2_CLIENTE,F2_LOJA,F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALISS, " 
cQuery += "  (SELECT TOP 1 D2_CCUSTO FROM "+RETSQLNAME("SD2")+ " SD2 WHERE D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND SD2.D_E_L_E_T_ = ' ') AS CCUSTO"

cQuery += " FROM "+RETSQLNAME("SF2")+" SF2 "

cQuery += " WHERE SUBSTRING(F2_EMISSAO,1,6) = '"+cAnoComp+cMesComp+"' "
cQuery += "      AND F2_FILIAL = '"+xFilial("SF2")+"' AND SF2.D_E_L_E_T_ = ' '"

//cQuery += " ORDER BY CNF_CONTRA,CNF_REVISA,CNF_COMPET,F2_DOC"  

TCQUERY cQuery NEW ALIAS "QTMP"
//TCSETFIELD("QTMP","F2_EMISSAO","D",8,0)

*/

cQuery := " SELECT CNF_CONTRA,CNF_REVISA,CNF_COMPET,"+ CRLF
cQuery += "    CASE WHEN CN9_SITUAC = '05' THEN CNF_VLPREV ELSE CNF_VLREAL END AS CNF_VLPREV,"+ CRLF
cQuery += "    CASE WHEN CN9_SITUAC = '05' THEN CNF_SALDO  ELSE 0 END AS CNF_SALDO, "+ CRLF
cQuery += "    CTT_DESC01, "+ CRLF
cQuery += "    CNA_NUMERO,CNA_XXMUN, "+ CRLF
cQuery += "    CND_NUMMED, "+ CRLF
cQuery += "    C6_NUM, "+ CRLF

// 18/11/14 - Campos XX_BONIF alterado de '2' para '1' e XX_MULTA alrterado de '1' para '2'
cQuery += "    (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CND_NUMMED = CNR_NUMMED"+ CRLF
cQuery += "         AND  CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '1') AS XX_BONIF,"+ CRLF

cQuery += "    (SELECT SUM(CNR_VALOR) FROM "+RETSQLNAME("CNR")+" CNR WHERE CND_NUMMED = CNR_NUMMED"+ CRLF
cQuery += "         AND  CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2') AS XX_MULTA,"+ CRLF

cQuery += "    F2_DOC,F2_CLIENTE,F2_LOJA,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS,F2_XXVFUMD, "+ CRLF

cQuery += "    (SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "        AND  E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' ') AS XX_VENCTO "+ CRLF

cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+ CRLF

cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09'"+ CRLF
cQuery += "      AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+ CRLF
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA"+ CRLF
cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CND_PARCEL = CNF_PARCEL AND CNA_NUMERO = CND_NUMERO AND CND_REVISA = CNA_REVISA"+ CRLF
cQuery += "      AND  CND.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM"+ CRLF
cQuery += "      AND  C6_FILIAL = CND_FILIAL AND SC6.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+ " SF2 ON C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC"+ CRLF
cQuery += "      AND  F2_FILIAL = CND_FILIAL AND SF2.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " WHERE CNF_COMPET = '"+cCompet+"'"+ CRLF
cQuery += "      AND  CNF_FILIAL = '"+xFilial("CNF")+"' AND  CNF.D_E_L_E_T_ = ' '"+ CRLF


cqContr := "(SELECT TOP 1 C5_MDCONTR FROM "+RETSQLNAME("SC6")+ " SC6 INNER JOIN "+RETSQLNAME("SC5")+" SC5 ON C5_FILIAL = C6_FILIAL AND C6_NUM = C5_NUM AND C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ') "
cqEspec := "(SELECT TOP 1 C5_ESPECI1 FROM "+RETSQLNAME("SC6")+ " SC6 INNER JOIN "+RETSQLNAME("SC5")+" SC5 ON C5_FILIAL = C6_FILIAL AND C6_NUM = C5_NUM AND C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ') "
cqCompt := "(SELECT TOP 1 SUBSTRING(C5_XXCOMPT,1,2)+'/'+SUBSTRING(C5_XXCOMPT,3,4) FROM "+RETSQLNAME("SC6")+ " SC6 INNER JOIN "+RETSQLNAME("SC5")+" SC5 ON C5_FILIAL = C6_FILIAL AND C6_NUM = C5_NUM AND C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ') "


cQuery += " UNION ALL "
cQuery += " SELECT "
cQuery += "        CASE WHEN "+cqEspec+" = ' ' THEN 'XXXXXXXXXX' ELSE "+cqEspec+" END," + CRLF // CNF_CONTRA
cQuery += "        ' ',"+cqCompt+",0,0, "  // CNF_REVISA,CNF_COMPET,CNF_VLPREV,CNF_SALDO
cQuery += "        A1_NOME, "  // CTT_DESC01
cQuery += "        ' ',' ', "  // CNA_NUMERO,CNA_XXMUN
cQuery += "        ' ', "      // CND_NUMMED
cQuery += "        ' ', "      // C6_NUM
cQuery += "        0,0, "+ CRLF      // XX_BONIF,XX_MULTA
cQuery += "        F2_DOC,F2_CLIENTE,F2_LOJA,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS,F2_XXVFUMD, " + CRLF
cQuery += "        (SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+" SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC"+ CRLF
cQuery += "            AND  E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' ') AS XX_VENCTO "+ CRLF

cQuery += " FROM "+RETSQLNAME("SF2")+" SF2"+ CRLF
//cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = "+cqContr
//cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '""
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA"+ CRLF
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " WHERE ("+cqContr+" = ' ' OR "+ CRLF
cQuery +=           cqContr+" IS NULL ) "+ CRLF
cQuery += "      AND "+cqCompt+" = '"+cCompet+"'"+ CRLF
//cQuery += "      AND SUBSTRING(F2_EMISSAO,1,6) = "+cMes 

cQuery += "      AND SF2.D_E_L_E_T_ = ' '"+ CRLF

//cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = C6_CONTRA"
//cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '""

//cQuery += " ORDER BY F2_DOC"  

cQuery += " ORDER BY CNF_CONTRA,CNF_REVISA,CNF_COMPET,F2_DOC" + CRLF

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","F2_EMISSAO","D",8,0)
TCSETFIELD("QTMP","XX_VENCTO","D",8,0)
u_LogMemo("BKFINA08.SQL",cQuery)

dbSelectArea("QTMP")
dbGoTop()
Do While !EOF()

	IncProc("Resumo do Faturamento")

	//If EMPTY(QTMP->CNF_CONTRA)
	//	dbSelectArea("QTMP")
    //	dbSkip()
    //	Loop
	//EndIf

	If EMPTY(QTMP->F2_VALFAT)
		dbSelectArea("QTMP")
    	dbSkip()
    	Loop
	EndIf
	
	dbSelectArea("SZ8")
	If dbSeek(xFilial("SZ8")+cAnoComp+cMesComp+QTMP->CNF_CONTRA)
		RecLock("SZ8",.F.)
	Else	
		RecLock("SZ8",.T.)
		SZ8->Z8_FILIAL  := xFilial("SZ8")
		SZ8->Z8_ANOMES  := cAnoComp+cMesComp
		SZ8->Z8_CONTRAT := QTMP->CNF_CONTRA
		SZ8->Z8_CLIENTE := QTMP->F2_CLIENTE
		SZ8->Z8_LOJA    := QTMP->F2_LOJA
        IF ALLTRIM(QTMP->CNF_CONTRA) <> "000000001"
		   SZ8->Z8_NOMCLI := Posicione("SA1",1,xFilial("SA1")+QTMP->F2_CLIENTE+QTMP->F2_LOJA,"A1_NOME")
		ELSE
		   // Notas avulsas  
		   SZ8->Z8_NOMCLI := Posicione("CTT",1,xFilial("CTT")+QTMP->CNF_CONTRA,"CTT_DESC01")
		ENDIF   
		SZ8->Z8_DESCR   := Posicione("CTT",1,xFilial("CTT")+QTMP->CNF_CONTRA,"CTT_DESC01")
	EndIf
		
	nValFat := QTMP->F2_VALFAT 
	SZ8->Z8_VALFAT:= SZ8->Z8_VALFAT + nValFat
	SZ8->Z8_PIS   := SZ8->Z8_PIS + (nValFat * nPis / 100)
	SZ8->Z8_COF   := SZ8->Z8_COF + (nValFat * nCof / 100)
	SZ8->Z8_ISS   := SZ8->Z8_ISS + QTMP->F2_VALISS
	SZ8->Z8_CRDPC := SZ8->Z8_CRDPC + (nValFat * nCrdPc / 100)
	SZ8->Z8_TXADM := SZ8->Z8_TXADM + (nValFat * nTxAdm / 100)
	
	MsUnLock()
	
	dbSelectArea("QTMP")
    dbSkip()

EndDo
dbSelectArea("QTMP")
dbCloseArea()

Return Nil



Static Function RunPrc2()
Local cFilZ9
// Gastos Gerais
// Excluindo processo anterior, se houver
dbSelectArea("SZ9")
dbSetOrder(1)
dbGoTop()
cFilZ9 := xFilial("SZ9")
dbSeek(cFilZ9+cAnoComp+cMesComp,.T.)
Do While !EOF() .AND. cFilZ9+cAnoComp+cMesComp == SZ9->Z9_FILIAL+SZ9->Z9_ANOMES 
	IncProc("Excluindo resumo anterior - Gastos")
	RecLock("SZ9",.F.)
	dbDelete()
	MsUnlock()
    dbSkip()
EndDo

cQuery := "SELECT D1_FILIAL,D1_COD,B1_DESC,D1_QUANT,D1_TOTAL,D1_CC,CTT_DESC01,D1_FORNECE,D1_LOJA,"
cQuery += "       A2_NOME,D1_DOC,D1_DTDIGIT,B1_DESC,CTT_DESC01 "
cQuery += " FROM "+RETSQLNAME("SD1")+" SD1 "
cQuery += " INNER JOIN "+RETSQLNAME("SA2")+" SA2 ON D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON D1_COD = B1_COD  AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RETSQLNAME("CTT")+" CTT ON D1_CC = CTT_CUSTO AND CTT.D_E_L_E_T_ = ' ' "

cQuery += " WHERE SUBSTRING(D1_DTDIGIT,1,6) = '"+cAnoComp+cMesComp+"' "
cQuery += "      AND D1_FILIAL = '"+xFilial("SD1")+"' AND SD1.D_E_L_E_T_ = ' '"

TCQUERY cQuery NEW ALIAS "QTMP"

//TCSETFIELD("QSD1","D1_DTDIGIT","D",8,0)

dbSelectArea("QTMP")
dbGoTop()
Do While !EOF()

	IncProc("Resumo de Gastos")

	If EMPTY(QTMP->D1_CC)
		dbSelectArea("QTMP")
    	dbSkip()
    	Loop
	EndIf
	
	dbSelectArea("SZ9")
	If dbSeek(xFilial("SZ9")+cAnoComp+cMesComp+QTMP->D1_CC+QTMP->D1_COD)
		RecLock("SZ9",.F.)
	Else	
		RecLock("SZ9",.T.)
		SZ9->Z9_FILIAL  := xFilial("SZ9")
		SZ9->Z9_ANOMES  := cAnoComp+cMesComp
		SZ9->Z9_CONTRAT := QTMP->D1_CC
		SZ9->Z9_DESCC   := QTMP->CTT_DESC01
		SZ9->Z9_FORNECE := QTMP->D1_FORNECE
		SZ9->Z9_LOJA    := QTMP->D1_LOJA
		SZ9->Z9_NOMEFOR := QTMP->A2_NOME
		SZ9->Z9_PRODUTO := QTMP->D1_COD
		SZ9->Z9_DESCPRD := QTMP->B1_DESC
	EndIf
		
	SZ9->Z9_TOTAL := SZ9->Z9_TOTAL + QTMP->D1_TOTAL
	SZ9->Z9_QUANT := SZ9->Z9_QUANT + QTMP->D1_QUANT
	MsUnlock()

	dbSelectArea("QTMP")
    dbSkip()

EndDo

dbSelectArea("QTMP")
dbCloseArea()

Return Nil


 

Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Mes de Competencia"  ,"" ,"" ,"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Ano de Competencia"  ,"" ,"" ,"mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Gerar Planilha? "    ,"" ,"" ,"mv_ch3","N",01,0,2,"C","","mv_par03","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})

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



Static Function GeraPl1()
                         
aCabs   := {}
aCampos := {}
aTitulos:= {}

AADD(aTitulos,"Resumo do Faturamento: "+cMesComp+"/"+cAnoComp)

AADD(aCampos,"QSZ8->Z8_CONTRAT")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QSZ8->Z8_DESCR")
AADD(aCabs  ,"Descrição do Contrato")

AADD(aCampos,"QSZ8->Z8_CLIENTE")
AADD(aCabs  ,"Cliente")

AADD(aCampos,"QSZ8->Z8_LOJA")
AADD(aCabs  ,"Loja")

AADD(aCampos,"QSZ8->Z8_NOMCLI")
AADD(aCabs  ,"Nome do Cliente")

AADD(aCampos,"QSZ8->Z8_ANOMES")
AADD(aCabs  ,"Ano/Mes")

AADD(aCampos,"QSZ8->Z8_VALFAT")
AADD(aCabs  ,"Faturamento Bruto")

AADD(aCampos,"QSZ8->Z8_PIS")
AADD(aCabs  ,"Pis")

AADD(aCampos,"QSZ8->Z8_COF")
AADD(aCabs  ,"Cofins")

AADD(aCampos,"QSZ8->Z8_ISS")
AADD(aCabs  ,"Iss")

AADD(aCampos,"QSZ8->Z8_CRDPC")
AADD(aCabs  ,"Cred. Pis/COfins")

AADD(aCampos,"QSZ8->Z8_TXADM")
AADD(aCabs  ,"Tx. Adm.")

AADD(aCampos,"QSZ8->Z8_PROVENT")
AADD(aCabs  ,"Proventos")

AADD(aCampos,"QSZ8->Z8_ENCARG")
AADD(aCabs  ,"Encargos")

AADD(aCampos,"QSZ8->Z8_INCIDEN")
AADD(aCabs  ,"Incidencias")

AADD(aCampos,"QSZ8->Z8_VT")
AADD(aCabs  ,"VT")

AADD(aCampos,"QSZ8->Z8_RECVT")
AADD(aCabs  ,"Rec. VT")

AADD(aCampos,"QSZ8->Z8_VR")
AADD(aCabs  ,"VR")

AADD(aCampos,"QSZ8->Z8_RECVR")
AADD(aCabs  ,"Rec. VR")

AADD(aCampos,"QSZ8->Z8_IRPJ")
AADD(aCabs  ,"Irpj")

AADD(aCampos,"QSZ8->Z8_ADIRPJ")
AADD(aCabs  ,"Adic. Irpj")

AADD(aCampos,"QSZ8->Z8_CSLL")
AADD(aCabs  ,"Csll")

cQuery := "SELECT * FROM "+RETSQLNAME("SZ8")+" SZ8 "
cQuery += " WHERE Z8_ANOMES = '"+cAnoComp+cMesComp+"' "
cQuery += "       AND Z8_FILIAL = '"+xFilial("SZ8")+"' AND SZ8.D_E_L_E_T_ = ' ' "

TCQUERY cQuery NEW ALIAS "QSZ8"

ProcRegua(QSZ8->(LASTREC()))
Processa( {|| U_GeraCSV("QSZ8",cPerg+"F",aTitulos,aCampos,aCabs)})

Return Nil





Static Function GeraPl2()
                         
aCabs   := {}
aCampos := {}
aTitulos:= {}

AADD(aTitulos,"Resumo de Despesas: "+cMesComp+"/"+cAnoComp)

AADD(aCampos,"QSZ9->Z9_CONTRAT")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QSZ9->Z9_DESCC")
AADD(aCabs  ,"Descrição do Contrato")

AADD(aCampos,"QSZ9->Z9_FORNECE")
AADD(aCabs  ,"Fornecedor")

AADD(aCampos,"QSZ9->Z9_LOJA")
AADD(aCabs  ,"Loja")

AADD(aCampos,"QSZ9->Z9_NOMEFOR")
AADD(aCabs  ,"Nome do Fornecedor")

AADD(aCampos,"QSZ9->Z9_ANOMES")
AADD(aCabs  ,"Ano/Mes")

AADD(aCampos,"QSZ9->Z9_PRODUTO")
AADD(aCabs  ,"Produto")

AADD(aCampos,"QSZ9->Z9_DESCPRD")
AADD(aCabs  ,"Descrição do Produto")

AADD(aCampos,"QSZ9->Z9_QUANT")
AADD(aCabs  ,"Quantidade")

AADD(aCampos,"QSZ9->Z9_TOTAL")
AADD(aCabs  ,"Total")

cQuery := "SELECT * FROM "+RETSQLNAME("SZ9")+" SZ9 "
cQuery += " WHERE Z9_ANOMES = '"+cAnoComp+cMesComp+"' "
cQuery += "       AND Z9_FILIAL = '"+xFilial("SZ9")+"' AND SZ9.D_E_L_E_T_ = ' '"

TCQUERY cQuery NEW ALIAS "QSZ9"

ProcRegua(QSZ9->(LASTREC()))
Processa( {|| U_GeraCSV("QSZ9",cPerg+"D",aTitulos,aCampos,aCabs)})

Return Nil
