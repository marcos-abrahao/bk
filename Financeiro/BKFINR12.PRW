#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} BKFINR12
BK - Contas a Receber
@Return
@author Adilson do Prado / Marcos Bispo Abrahão
@since 11/07/14 Rev 19/07/2022
@version P12 
/*/

User Function BKFINR12()

Local titulo         := ""
Local aTitulos       := {}
Local aCampos        := {}
Local aCabs			 := {}
Local oDlg01		 AS Object
Local aButtons 		 := {}
Local lOk 			 := .F.
Local oPanelLeft 	 AS Object

Private cPerg        := "BKFINR12"
Private cMesComp     := ""
Private cAnoComp     := ""
Private cCompet      := ""
Private dDataI   	 := CTOD("")
Private dDataF   	 := CTOD("")
Private cContrato	 := ""
Private cNFIni       := ""
Private cNFFim       := ""
Private nEmissao 	 := 1
Private aTipoEmis    := {"1-Competência","2-Vencimento","3-Centro de Custo","4-Emissão","5-NF/Título"}
Private cTipoEmis    := ""
Private nOpcRel 	 := 1
Private aOpcRel      := {"1-Todas","2-Vinculadas","3-ISS Bitr indevidamente"}
Private cOpcRel      := ""

Private cCrLf		 := CRLF

cTipoEmis := aTipoEmis[1] 

Define MsDialog oDlg01 Title "BKFINR12 - Relação de Contas a receber" From 000,000 To 150,330 Of oDlg01 Pixel
	
@ 000,000 MSPANEL oPanelLeft OF oDlg01 SIZE 380,600 
oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
@ 15,10 SAY 'Emitir por:'   SIZE 080,010 OF oPanelLeft PIXEL
@ 15,45 COMBOBOX cTipoEmis  ITEMS aTipoEmis SIZE 100,010 Pixel OF oPanelLeft 

@ 30,10 SAY 'Filtrar:'   SIZE 080,010 OF oPanelLeft PIXEL
@ 30,45 COMBOBOX cOpcRel  ITEMS aOpcRel SIZE 100,010 Pixel OF oPanelLeft 


ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

If ( !lOk )
	RETURN NIL
EndIf

If VALTYPE(cTipoEmis) <> "N"
	nEmissao := VAL(SUBSTR(cTipoEmis,1,1))
Else
	nEmissao := cTipoEmis
EndIf

If VALTYPE(cOpcRel) <> "N"
	nOpcRel := VAL(SUBSTR(cOpcRel,1,1))
Else
	nOpcRel := cOpcRel
EndIf


IF nEmissao = 1
	cPerg	:= "2BKFINR12"
	ValidPerg2()
	If !Pergunte(cPerg,.T.)
		Return
	Endif
	cMesComp := mv_par01
	cAnoComp := mv_par02
	cCompet  := cMesComp+"/"+cAnoComp
	titulo   := "Contas a Receber : Competencia "+cCompet

	IF LEN(ALLTRIM(cAnoComp)) < 4
   		MSGSTOP('Ano deve conter 4 digitos!!',"Atenção")
   		Return
	ENDIF 

ELSEIF nEmissao = 2
	cPerg	:= "3BKFINR12"
	ValidPerg3()
	If !Pergunte(cPerg,.T.)
		Return
	Endif
	dDataI   := mv_par01
	dDataF   := mv_par02
	titulo   := "Contas a Receber : Vencimento de "+DTOC(dDataI)+" até "+DTOC(dDataF)
ELSEIF nEmissao = 3
	cPerg	:= "4BKFINR12"
	ValidPerg4()
	If !Pergunte(cPerg,.T.)
		Return
	Endif
	cContrato:= mv_par01 
	cAnoComp := mv_par02
	IF !EMPTY(cContrato) 
		titulo   := "Contas a Receber : Contrato "+cContrato+" - "+ALLTRIM(Posicione("CTT",1,xFilial("CTT")+cContrato,"CTT_DESC01"))
    ELSEIF !EMPTY(cAnoComp) 
		titulo   := "Contas a Receber : Ano vencimento "+cAnoComp
	ENDIF
	IF EMPTY(cContrato) .AND. EMPTY(cAnoComp)
		titulo   := "Contas a Receber "
	ENDIF

ELSEIF nEmissao = 4
	cPerg	:= "5BKFINR12"
	ValidPerg5()
	If !Pergunte(cPerg,.T.)
		Return
	Endif
	dDataI   := mv_par01
	dDataF   := mv_par02
	titulo   := "Contas a Receber : Emissão de "+DTOC(dDataI)+" até "+DTOC(dDataF)

ELSEIF nEmissao = 5
	cPerg	:= "6BKFINR12"
	ValidPerg6()
	If !Pergunte(cPerg,.T.)
		Return
	Endif
	
	cNFIni   := mv_par01 
	cNFFim   := mv_par02
	
	IF !EMPTY(cNFIni) 
		titulo   := "Contas a Receber : NF/Titulo de "+TRIM(cNFIni)+IIF(!EMPTY(cNFFim)," até "+TRIM(cNFFim),"")
    ELSEIF !EMPTY(cNFFim) 
		titulo   := "Contas a Receber : NF/Titulo até "+TRIM(cNFFim)
	ENDIF
	IF EMPTY(cNFIni) .AND. EMPTY(cNFFim)
		titulo   := "Contas Recebidas "
	ENDIF

ENDIF

If nOpcRel == 2
	titulo += " - Vinculadas"
ElseIf nOpcRel == 3
	titulo += " - com Iss bitributado indevidamente"
EndIf

u_WaitLog(, {|| ProcQuery() })

aCabs   := {}
aCampos := {}
aTitulos:= {}
   
AADD(aTitulos,titulo)

AADD(aCampos,"QTMP->E1_CLIENTE")
AADD(aCabs  ,"Cliente")

AADD(aCampos,"QTMP->E1_LOJA")
AADD(aCabs  ,"Lj")

AADD(aCampos,"QTMP->A1_NOME")
AADD(aCabs  ,"Cliente")

AADD(aCampos,"Transform(QTMP->A1_CGC,IIF(QTMP->A1_PESSOA=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))")
AADD(aCabs  ,"CNPJ/CPF")

AADD(aCampos,"QTMP->CONTRATO")
AADD(aCabs  ,"Contrato")

AADD(aCampos,'IIF(!EMPTY(QTMP->CONTRATO),ALLTRIM(Posicione("CTT",1,xFilial("CTT")+QTMP->CONTRATO,"CTT_DESC01")),"")')
AADD(aCabs  ,"Centro de Custos")

AADD(aCampos,"QTMP->C5_XXCOMPM")
AADD(aCabs  ,"Competencia")

AADD(aCampos,"QTMP->E1_PREFIXO")
AADD(aCabs  ,"Prf.") 

AADD(aCampos,"QTMP->E1_NUM")
AADD(aCabs  ,"NF/Título") 

AADD(aCampos,"QTMP->E1_PARCELA")
AADD(aCabs  ,"Parcela") 

AADD(aCampos,"QTMP->E1_XXOBX")
AADD(aCabs  ,"Observação de Baixa")

AADD(aCampos,"QTMP->E1_EMISSAO")
AADD(aCabs  ,"Emissao")
   
AADD(aCampos,"QTMP->E1_VENCREA")
AADD(aCabs  ,"Vencimento")

AADD(aCampos,"QTMP->E1_VENCORI")
AADD(aCabs  ,"Venc. Original")

AADD(aCampos,"QTMP->E1_BAIXA")
AADD(aCabs  ,"Última baixa")

AADD(aCampos,"u_AtrsRec(QTMP->E1_VENCREA,IIF(QTMP->E1_SALDO > 0,dDataBase,QTMP->E1_BAIXA))")
AADD(aCabs  ,"Atraso")

AADD(aCampos,"QTMP->E1_XXDTPRV")
AADD(aCabs  ,"Previsão")

AADD(aCampos,"X3COMBO('E1_XXTPPRV',QTMP->E1_XXTPPRV)")
AADD(aCabs  ,"Status Previsão")

AADD(aCampos,"QTMP->E1_VALOR")
AADD(aCabs  ,"Valor Bruto / Parcela")

AADD(aCampos,"QTMP->E1_IRRF")
AADD(aCabs  ,"IRRF Retido")

AADD(aCampos,"QTMP->E1_INSS")
AADD(aCabs  ,"INSS Retido")

AADD(aCampos,"QTMP->E1_PIS")
AADD(aCabs  ,"PIS Retido")

AADD(aCampos,"QTMP->E1_COFINS")
AADD(aCabs  ,"COFINS Retido")

AADD(aCampos,"QTMP->E1_CSLL")
AADD(aCabs  ,"CSLL Retido")

AADD(aCampos,"IIF(QTMP->F2_RECISS = '1',QTMP->E1_ISS,0)")
AADD(aCabs  ,"ISS Retido")

AADD(aCampos,"QTMP->E1_VRETBIS")
AADD(aCabs  ,"ISS Bitrib")

//AADD(aCampos,"QTMP->XX_E5DESC")
//AADD(aCabs  ,"Desconto na NF")

//AADD(aCampos,"QTMP->XX_E5MULTA")
//AADD(aCabs  ,"Cliente não Reteve")

AADD(aCampos,"QTMP->F2_XXVCVIN")
AADD(aCabs  ,"Conta Vinculada")

//AADD(aCampos,"QTMP->F2_XXVFUMD")
//AADD(aCabs  ,"FUMDIP OSASCO")

AADD(aCampos,"QTMP->F2_XXVRETC")
AADD(aCabs  ,"Ret. Contratual")

AADD(aCampos,"QTMP->E1_VALOR - QTMP->E1_IRRF - QTMP->E1_INSS - QTMP->E1_PIS - QTMP->E1_COFINS - QTMP->E1_CSLL - QTMP->F2_XXVCVIN - QTMP->F2_XXVFUMD - IIF(QTMP->F2_RECISS = '1',QTMP->E1_ISS,0) - QTMP->E1_VRETBIS - QTMP->F2_XXVRETC") // - QTMP->XX_E5DESC + QTMP->XX_E5MULTA
AADD(aCabs  ,"Valor liquido")

//AADD(aCampos,"IIF(QTMP->E1_SALDO > 0,QTMP->E1_VALOR - QTMP->E1_IRRF - QTMP->E1_INSS - QTMP->E1_PIS - QTMP->E1_COFINS - QTMP->E1_CSLL - QTMP->F2_XXVCVIN - QTMP->F2_XXVFUMD - IIF(QTMP->F2_RECISS = '1',QTMP->E1_ISS,0) - QTMP->E1_VRETBIS - QTMP->F2_XXVRETC - (QTMP->E1_VALOR - QTMP->E1_SALDO),0)") //- QTMP->XX_E5DESC + QTMP->XX_E5MULTA 
//AADD(aCabs  ,"Saldo a Receber")
AADD(aCampos,"U_SaldoRec(QTMP->E1RECNO)")
AADD(aCabs  ,"Saldo a Receber")

AADD(aCampos,"QTMP->E1_XXISSBI")
AADD(aCabs  ,"Iss Bitrib. Indevidamente")

AADD(aCampos,"STRTRAN(QTMP->E1_XXHISTM,cCrLf,' ')")
AADD(aCabs  ,"Histórico BK")

U_GeraCSV("QTMP",cPerg,aTitulos,aCampos,aCabs)
   
Return


Static Function ProcQuery
Local cQuery

//IncProc("Consultando o banco de dados...")

/*
cQuery := "SELECT DISTINCT A1_NOME,E1_VENCREA,E1_VENCORI,E1_VALOR,E1_SALDO" + CRLF
cQuery += ",CASE WHEN E1_TIPO <> 'NDC' THEN C5_XXCOMPM ELSE SUBSTRING(E1_XXCOMPE,5,2)+'/'+SUBSTRING(E1_XXCOMPE,1,4) END AS C5_XXCOMPM"  + CRLF
cQuery += ",E1_NUM,E1_PARCELA,E1_EMISSAO,E1_VALOR,E1_IRRF,E1_INSS,E1_PIS,E1_COFINS,E1_CSLL,E1_ISS,E1_VRETBIS "+CRLF
cQuery += ",CONVERT(VARCHAR(1000),CONVERT(Binary(1000),E1_XXHISTM)) E1_XXHISTM "+CRLF
cQuery += ",F2_RECISS,F2_XXVCVIN,F2_XXVFUMD,F2_XXVRETC" + CRLF
cQuery += ",CASE E1_XXCUSTO WHEN '' THEN CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1
cQuery += "     ELSE C5_MDCONTR END ELSE E1_XXCUSTO END AS CONTRATO" + CRLF
cQuery += " CASE WHEN E1_VALOR<>E1_SALDO THEN 'Baixa Parcial' ELSE '' END AS E1_XXOBX, " + CRLF
cQuery += " (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "   AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5DESC, "+ CRLF
cQuery += " (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "   AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5MULTA "+ CRLF
cQuery += " FROM "+RETSQLNAME("SE1")+ " SE1 " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+ " SF2 ON SF2.D_E_L_E_T_='' AND SE1.E1_NUM=SF2.F2_DUPL " + CRLF
cQuery += " AND SE1.E1_PREFIXO=SF2.F2_PREFIXO AND SE1.E1_CLIENTE=SF2.F2_CLIENTE AND SE1.E1_LOJA=SF2.F2_LOJA" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON SC5.C5_NUM=SE1.E1_PEDIDO AND SC5.D_E_L_E_T_='' " + CRLF
//cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON SC5.C5_NUM=CND.CND_PEDIDO AND CND.D_E_L_E_T_=''" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON SA1.D_E_L_E_T_='' AND SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA" + CRLF
cQuery += " WHERE SE1.D_E_L_E_T_='' AND SE1.E1_TIPO IN('NF','NDC')" + CRLF
*/
cQuery := "SELECT DISTINCT "+CRLF
cQuery += " A1_NOME"+CRLF
cQuery += ",A1_CGC"+CRLF
cQuery += ",A1_PESSOA"+CRLF
cQuery += ",E1_VENCREA"+CRLF
cQuery += ",E1_VENCORI"+CRLF
cQuery += ",E1_BAIXA"+CRLF
cQuery += ",E1_VALOR"+CRLF
cQuery += ",E1_SALDO" + CRLF
cQuery += ",CASE WHEN E1_TIPO <> 'NDC' THEN C5_XXCOMPM ELSE SUBSTRING(E1_XXCOMPE,5,2)+'/'+SUBSTRING(E1_XXCOMPE,1,4) END AS C5_XXCOMPM"  + CRLF
cQuery += ",E1_PREFIXO"+CRLF
cQuery += ",E1_NUM"+CRLF
cQuery += ",E1_PARCELA"+CRLF
cQuery += ",E1_CLIENTE"+CRLF
cQuery += ",E1_LOJA"+CRLF
cQuery += ",E1_EMISSAO"+CRLF
cQuery += ",E1_VALOR"+CRLF
cQuery += ",E1_IRRF"+CRLF
cQuery += ",E1_INSS"+CRLF
cQuery += ",E1_PIS"+CRLF
cQuery += ",E1_COFINS"+CRLF
cQuery += ",E1_CSLL"+CRLF
cQuery += ",E1_ISS"+CRLF
cQuery += ",E1_VRETBIS "+CRLF
cQuery += ",E1_XXDTPRV"+CRLF
cQuery += ",E1_XXTPPRV"+CRLF
cQuery += ",CONVERT(VARCHAR(1000),CONVERT(Binary(1000),E1_XXHISTM)) E1_XXHISTM "+CRLF
cQuery += ",SE1.R_E_C_N_O_ AS E1RECNO"+CRLF
cQuery += ",F2_RECISS" + CRLF
cQuery += ",F2_XXVCVIN" + CRLF
cQuery += ",F2_XXVFUMD" + CRLF
cQuery += ",F2_XXVRETC" + CRLF
cQuery += ",E1_XXISSBI" +CRLF
cQuery += ",CASE E1_XXCUSTO WHEN '' THEN CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1
cQuery += "     ELSE C5_MDCONTR END ELSE E1_XXCUSTO END AS CONTRATO" + CRLF
cQuery += ",CASE WHEN E1_VALOR<>E1_SALDO THEN 'Baixa Parcial' ELSE '' END AS E1_XXOBX " + CRLF
cQuery += ",(SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " + CRLF
cQuery += "   AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5DESC "+ CRLF
cQuery += ",(SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " + CRLF
cQuery += "   AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5MULTA "+ CRLF
cQuery += " FROM "+RETSQLNAME("SE1")+ " SE1 " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+ " SF2 ON SF2.D_E_L_E_T_='' AND SE1.E1_NUM=SF2.F2_DUPL " + CRLF
cQuery += " AND SE1.E1_PREFIXO=SF2.F2_PREFIXO AND SE1.E1_CLIENTE=SF2.F2_CLIENTE AND SE1.E1_LOJA=SF2.F2_LOJA" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON SC5.C5_NUM=SE1.E1_PEDIDO AND SC5.D_E_L_E_T_='' " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON SA1.D_E_L_E_T_='' AND SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA" + CRLF
cQuery += " WHERE SE1.D_E_L_E_T_='' AND SE1.E1_TIPO IN('NF','NDC')" + CRLF

IF nEmissao <> 2 .AND. nOpcRel == 1
	cQuery += " AND SE1.E1_SALDO > 0 " + CRLF
ENDIF 

IF nEmissao == 1
	cQuery += " AND C5_XXCOMPM='"+cCompet+"'" + CRLF
ELSEIF nEmissao == 2
	cQuery += " AND E1_VENCREA >= '"+DTOS(dDataI)+"' AND E1_VENCREA <= '"+DTOS(dDataF)+"'" + CRLF
ELSEIF nEmissao == 3
	IF !EMPTY(cContrato) 
		cQuery += " AND (C5_MDCONTR='"+ALLTRIM(cContrato)+"' OR  C5_ESPECI1='"+ALLTRIM(cContrato)+"' )" + CRLF
    ELSEIF !EMPTY(cAnoComp) 
		cQuery += " AND SUBSTRING(E1_VENCREA,1,4)="+cAnoComp + CRLF
	ENDIF
ELSEIF nEmissao == 4
	cQuery += " AND E1_EMISSAO>='"+DTOS(dDataI)+"' AND E1_EMISSAO<='"+DTOS(dDataF)+"'" + CRLF
ELSEIF nEmissao == 5
	IF !EMPTY(cNFIni) 
		cQuery += " AND E1_NUM >= '"+ALLTRIM(cNFIni)+"'" + CRLF
	ENDIF
	IF !EMPTY(cNFFim) 
		cQuery += " AND E1_NUM <= '"+ALLTRIM(cNFFim)+"'" + CRLF
	ENDIF
ENDIF 

If nOpcRel == 2
	// Viculadas / Recuperaveis
	cQuery += " AND (F2_XXVCVIN > 0 OR F2_XXVRETC > 0 OR E1_XXISSBI > 0) "
ElseIf nOpcRel == 3
	cQuery += " AND E1_XXISSBI > 0 "
EndIf

//IF nEmissao == 4
//	cQuery += "ORDER BY E1_EMISSAO"
//ELSEIF nEmissao == 5
//	cQuery += "ORDER BY E1_NUM"
//ELSE
	cQuery += "ORDER BY E1_VENCREA,E1_PREFIXO,E1_NUM" + CRLF
//ENDIF

u_LogMemo("BKFINR12.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","E1_EMISSAO","D",8,0)
TCSETFIELD("QTMP","E1_VENCREA","D",8,0)
TCSETFIELD("QTMP","E1_BAIXA","D",8,0)
TCSETFIELD("QTMP","E1_VENCORI","D",8,0)
TCSETFIELD("QTMP","E1_XXDTPRV","D",8,0)

Return


Static Function  ValidPerg2
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}
cPerg := "2BKFINR12"
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
	Endif
Next

RestArea(aArea)

Return(NIL)


Static Function  ValidPerg3()
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}
cPerg := "3BKFINR12"
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)


AADD(aRegistros,{cPerg,"01","Vencimento de :"     ,"" ,"" ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Vencimento até:"     ,"" ,"" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})


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


Static Function  ValidPerg4()
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}
cPerg := "4BKFINR12"
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Contrato:" ,"Contrato:" ,"Contrato:","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"02","Do Ano:"   ,"Do Ano:"   ,"Do Ano:"  ,"mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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



Static Function  ValidPerg5
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}
cPerg := "5BKFINR12"
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Emissão de :"     ,"" ,"" ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Emissão até:"     ,"" ,"" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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




Static Function  ValidPerg6
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}
cPerg := "6BKFINR12"
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","NF/Titulo de :" ,"NF/Titulo de:" ,"NF/Titulo de:" ,"mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","NF/Titulo até:" ,"NF/Titulo até:","NF/Titulo até:","mv_ch2","C",09,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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
