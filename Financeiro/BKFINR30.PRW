#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKFINR30
BK - Clientes em aberto
@Return
@author Marcos Bispo Abrahão
@since 05/04/2022
@version P12
/*/

User Function BKFINR30()

Local aRet			:= {}

Private cTitulo     := "Clientes em aberto"
Private cPerg       := "BKFINR30"
Private aTipoEmis   := {"1-Emissão", "2-Vencimento"}
Private cTipoEmis   := "2"
Private dDataI   	:= CTOD("")
Private dDataF   	:= CTOD("")
Private cCrLf		:= CRLF
Private oTmpTb1		As Object
Private oTmpTb2		As Object
Private aParam 		:= {}

Private aFormula3   := {}

aAdd( aParam ,{ 2, "Emitir por:"    , "2-Vencimento" , aTipoEmis, 70,'.T.'  ,.T.})
aAdd( aParam, { 1, "Data inicial:"	, dDataBase	     , ""       , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Data final:"	, dDataBase	     , ""       , "", ""	, "" , 70  , .F. })  

If (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKCOMA09",.T.         ,.T.))

	u_LogPrw("BKFINR30")

	cTipoEmis	:= SUBSTR(mv_par01,1,1)
	dDataI		:= mv_par02
	dDataF		:= mv_par03
		

	FWMsgRun(, {|oSay| ProcQuery() }, "", cPerg+" - Consultando dados...")
	FWMsgRun(, {|oSay| ProcRes() }  , "", cPerg+" - Resumindo dados...")
	FWMsgRun(, {|oSay| RunFR30() }  , "", cPerg+" - Gerando relatório...")

Endif

Return Nil


Static Function RunFR30

Local aPlans		:= {}

Local aTitulos1		:= {}
Local aCampos1		:= {}
Local aCabs1		:= {}
Local lClose 		:= .F.   

Local aTitulos2		:= {}
Local aCampos2		:= {}
Local aCabs2		:= {}
Local aFormat2		:= {}

Local aTitulos3		:= {}
Local aCampos3		:= {}
Local aCabs3		:= {}
Local aFormat3		:= {}

AADD(aTitulos1,cTitulo)

AADD(aCampos1,"QTMP->E1_CLIENTE")
AADD(aCabs1  ,"Cliente")

AADD(aCampos1,"QTMP->E1_LOJA")
AADD(aCabs1  ,"Lj")

AADD(aCampos1,"QTMP->A1_NOME")
AADD(aCabs1  ,"Nome")

AADD(aCampos1,"Transform(QTMP->A1_CGC,IIF(QTMP->A1_PESSOA=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))")
AADD(aCabs1  ,"CNPJ/CPF")

AADD(aCampos1,"QTMP->CONTRATO")
AADD(aCabs1  ,"Contrato")

AADD(aCampos1,'IIF(!EMPTY(QTMP->CONTRATO),ALLTRIM(Posicione("CTT",1,xFilial("CTT")+QTMP->CONTRATO,"CTT_DESC01")),"")')
AADD(aCabs1  ,"Centro de Custos")

AADD(aCampos1,"QTMP->C5_XXCOMPM")
AADD(aCabs1  ,"Competencia")

AADD(aCampos1,"QTMP->E1_PREFIXO")
AADD(aCabs1  ,"Prf.") 

AADD(aCampos1,"QTMP->E1_NUM")
AADD(aCabs1  ,"NF/Título") 

AADD(aCampos1,"QTMP->E1_PARCELA")
AADD(aCabs1  ,"Parcela") 

AADD(aCampos1,"QTMP->E1_EMISSAO")
AADD(aCabs1  ,"Emissao")
   
AADD(aCampos1,"QTMP->E1_VENCREA")
AADD(aCabs1  ,"Vencimento")

AADD(aCampos1,"u_AtrsRec(QTMP->E1_VENCREA)")
AADD(aCabs1  ,"Atraso")

AADD(aCampos1,"QTMP->E1_XXDTPRV")
AADD(aCabs1  ,"Previsão")

AADD(aCampos1,"X3COMBO('E1_XXTPPRV',QTMP->E1_XXTPPRV)")
AADD(aCabs1  ,"Status Previsão")

AADD(aCampos1,"QTMP->E1_VALOR")
AADD(aCabs1  ,"Valor Bruto / Parcela")

AADD(aCampos1 ,"QTMP->E1_VALOR - QTMP->E1_IRRF     - QTMP->E1_INSS    - QTMP->E1_PIS    - QTMP->E1_COFINS  - QTMP->E1_CSLL    - IIF(QTMP->F2_RECISS = '1',QTMP->E1_ISS,0)    - QTMP->E1_VRETBIS - QTMP->F2_XXVCVIN - QTMP->F2_XXVFUMD - QTMP->F2_XXVRETC") // - QTMP->XX_E5DESC + QTMP->XX_E5MULTA
//AADD(aCampos,"QTMP->F2_VALFAT - QTMP->F2_VALIRRF - QTMP->F2_VALINSS - QTMP->F2_VALPIS - QTMP->F2_VALCOFI - QTMP->F2_VALCSLL - IIF(QTMP->F2_RECISS = '1',QTMP->F2_VALISS,0) - QTMP->F2_VLCPM   - QTMP->XX_E5DESC  + QTMP->XX_E5MULTA - QTMP->F2_XXVRETC")

AADD(aCabs1  ,"Valor liquido")

//AADD(aCampos1,"IIF(QTMP->E1_SALDO > 0,QTMP->E1_VALOR - QTMP->E1_IRRF - QTMP->E1_INSS - QTMP->E1_PIS - QTMP->E1_COFINS - QTMP->E1_CSLL - QTMP->F2_XXVCVIN - QTMP->F2_XXVFUMD - IIF(QTMP->F2_RECISS = '1',QTMP->E1_ISS,0) - QTMP->E1_VRETBIS - QTMP->F2_XXVRETC - (QTMP->E1_VALOR - QTMP->E1_SALDO),0)") //- QTMP->XX_E5DESC + QTMP->XX_E5MULTA 
AADD(aCampos1,"U_SaldoRec(QTMP->E1RECNO)")
AADD(aCabs1  ,"Saldo a Receber")

AADD(aCampos1,"STRTRAN(QTMP->E1_XXHISTM,cCrLf,' ')")
AADD(aCabs1  ,"Histórico BK")

AADD(aPlans,{"QTMP",cPerg,"",aTitulos1,aCampos1,aCabs1,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })

AADD(aTitulos2,cTitulo)
AADD(aCampos2,"QTMP1->XX_CLIENTE")
AADD(aCabs2  ,"Cliente")
AADD(aFormat2,"")

AADD(aCampos2,"QTMP1->XX_EMISSAO")
AADD(aCabs2  ,"Emissão")
AADD(aFormat2,"")

AADD(aCampos2,"QTMP1->XX_VENCREA")
AADD(aCabs2  ,"Vencto")
AADD(aFormat2,"")

AADD(aCampos2,"QTMP1->XX_XXDTPRV")
AADD(aCabs2  ,"Previsão")
AADD(aFormat2,"")

AADD(aCampos2,"X3COMBO('E1_XXTPPRV',QTMP1->XX_XXTPPRV)")
AADD(aCabs2  ,"Status Previsão")
AADD(aFormat2,"")

AADD(aCampos2,"QTMP1->XX_ATRASO")
AADD(aCabs2  ,"Atraso")
AADD(aFormat2,"N0")

AADD(aCampos2,"QTMP1->XX_QTDTIT")
AADD(aCabs2  ,"Qtd.")
AADD(aFormat2,"N0")

AADD(aCampos2,"QTMP1->XX_SALDO")
AADD(aCabs2  ,"Saldo")
AADD(aFormat2,"")

AADD(aCampos2,"QTMP1->XX_HIST")
AADD(aCabs2  ,"Histórico")
AADD(aFormat2,"")

AADD(aPlans,{"QTMP1","Resumo","",aTitulos2,aCampos2,aCabs2,/*aImpr1*/, /* aAlign */,aFormat2, /*aTotal */, /*cQuebra*/, lClose:= .T. })


AADD(aTitulos3,cTitulo)

AADD(aCampos3,"QTMP2->XX_DIAS")
AADD(aCabs3  ,"Classe")
AADD(aFormat3,"")

AADD(aCampos3,"QTMP2->XX_CLIENTE")
AADD(aCabs3  ,"Cliente")
AADD(aFormat3,"")

AADD(aCampos3,"QTMP2->XX_SALDO")
AADD(aCabs3  ,"Saldo")
AADD(aFormat3,"")

AADD(aCampos3,"QTMP2->XX_ATRASO")
AADD(aCabs3  ,"Atraso")
AADD(aFormat3,"N0")

AADD(aPlans,{"QTMP2","10, 30 60 Dias","",aTitulos3,aCampos3,aCabs3,/*aImpr1*/, aFormula3,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })

U_PlanXlsx(aPlans,cTitulo,cPerg, lClose := .T.,aParam)
   
Return




Static Function ProcQuery
Local cQuery

cQuery := "SELECT DISTINCT "+CRLF
cQuery += " A1_NOME"+CRLF
cQuery += ",A1_CGC"+CRLF
cQuery += ",A1_PESSOA"+CRLF
cQuery += ",E1_VENCREA"+CRLF
cQuery += ",E1_VENCORI"+CRLF
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
cQuery += " AND SE1.E1_SALDO > 0 " + CRLF
IF cTipoEmis == '1'
	cQuery += " AND E1_EMISSAO >= '"+DTOS(dDataI)+"' AND E1_EMISSAO <= '"+DTOS(dDataF)+"'" + CRLF
	cQuery += "ORDER BY E1_EMISSAO,E1_PREFIXO,E1_NUM" + CRLF
ELSEIF cTipoEmis == '2'
	cQuery += " AND E1_VENCREA >= '"+DTOS(dDataI)+"' AND E1_VENCREA <= '"+DTOS(dDataF)+"'" + CRLF
	cQuery += "ORDER BY E1_VENCREA,E1_PREFIXO,E1_NUM" + CRLF
ENDIF 

u_LogMemo("BKFINR30.SQL",cQuery)

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP",.T.,.T.)

TCSetField("QTMP","E1_EMISSAO","D",8,0)
TCSetField("QTMP","E1_VENCREA","D",8,0)
TCSetField("QTMP","E1_VENCORI","D",8,0)
TCSETFIELD("QTMP","E1_XXDTPRV","D",8,0)

Return


Static Function ProcRes
Local aStruc1  := {}
Local aStruc2  := {}
Local nAtraso  := 0

Aadd( aStruc1, { 'XX_CLIENTE', 'C', TamSX3("A1_NOME")[1],00 } )
Aadd( aStruc1, { 'XX_EMISSAO', 'D', 08,00 } )
Aadd( aStruc1, { 'XX_VENCREC', 'C', 08,00 } )
Aadd( aStruc1, { 'XX_VENCREA', 'D', 08,00 } )
Aadd( aStruc1, { 'XX_XXDTPRV', 'D', 08,00 } )
Aadd( aStruc1, { 'XX_XXTPPRV', 'C',  1,00 } )
Aadd( aStruc1, { 'XX_SALDO',   'N', 14,02 } )
Aadd( aStruc1, { 'XX_ATRASO',  'N',  5,00 } )
Aadd( aStruc1, { 'XX_QTDTIT',  'N',  5,00 } )
Aadd( aStruc1, { 'XX_HIST',	   'M', 10,00 } ) 

oTmpTb1 := FWTemporaryTable():New( "QTMP1" )	
oTmpTb1:SetFields( aStruc1 )
oTmpTb1:AddIndex("indice1", {"XX_CLIENTE","XX_VENCREC"} )
oTmpTb1:Create()


Aadd( aStruc2, { 'XX_DIAS',    'C', 2,00 } )
Aadd( aStruc2, { 'XX_INDICE',  'C', 10+TamSX3("A1_NOME")[1],00 } )
Aadd( aStruc2, { 'XX_CLIENTE', 'C', TamSX3("A1_NOME")[1],00 } )
Aadd( aStruc2, { 'XX_SALDO',   'N', 14,02 } )
Aadd( aStruc2, { 'XX_ATRASO',  'N',  5,00 } )

oTmpTb2 := FWTemporaryTable():New( "QTMP2" )	
oTmpTb2:SetFields( aStruc2 )
oTmpTb2:AddIndex("indice2", {"XX_INDICE"} )
oTmpTb2:Create()


DbSelectArea("QTMP")
dbGoTop()

Do While !EOF()
	DbSelectArea("QTMP1")
	IF dbSeek(QTMP->A1_NOME+DTOS(QTMP->E1_VENCREA),.F.)
		Reclock("QTMP1",.F.)
		QTMP1->XX_QTDTIT++
	Else
		Reclock("QTMP1",.T.)
		QTMP1->XX_CLIENTE := QTMP->A1_NOME
		QTMP1->XX_EMISSAO := QTMP->E1_EMISSAO
		QTMP1->XX_VENCREA := QTMP->E1_VENCREA
		QTMP1->XX_VENCREC := DTOS(QTMP->E1_VENCREA)
		QTMP1->XX_QTDTIT  := 1
	EndIf

	QTMP1->XX_SALDO += U_SaldoRec(QTMP->E1RECNO)	

	nAtraso := u_AtrsRec(QTMP->E1_VENCREA)
	If nAtraso > QTMP1->XX_ATRASO
		QTMP1->XX_ATRASO := nAtraso
	EndIf

	If QTMP->E1_XXDTPRV > QTMP1->XX_XXDTPRV
		QTMP1->XX_XXDTPRV := QTMP->E1_XXDTPRV
	EndIf

	If !Empty(QTMP->E1_XXTPPRV)
		QTMP1->XX_XXTPPRV := QTMP->E1_XXTPPRV
	EndIf

	If !Empty(QTMP->E1_XXHISTM)
		If !ALLTRIM(QTMP->E1_XXHISTM) $ QTMP1->XX_HIST
			If !Empty(QTMP1->XX_HIST)
				QTMP1->XX_HIST += CRLF
			EndIf
			QTMP1->XX_HIST := QTMP1->XX_HIST + ALLTRIM(QTMP->E1_XXHISTM)
		EndIf
	EndIf
	dbUnLock()

	DbSelectArea("QTMP")
	dbSkip()
ENDDO

// Indices por atraso 10 dias, 30 dias e mais de 60 dias


DbSelectArea("QTMP2")
Reclock("QTMP2",.T.)
QTMP2->XX_DIAS    := "00"
QTMP2->XX_INDICE  := "00"
QTMP2->XX_CLIENTE := "TÍTULOS A VENCER"
dbUnLock()
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_DIAS","","S","",""})
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_CLIENTE","","S","",""})
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_SALDO"," ","S","",""})
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_ATRASO"," ","S","",""})

DbSelectArea("QTMP2")
Reclock("QTMP2",.T.)
QTMP2->XX_DIAS    := "10"
QTMP2->XX_INDICE  := "10"
QTMP2->XX_CLIENTE := "TÍTULOS VENCIDOS ATÉ 10 DIAS"
dbUnLock()
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_DIAS","","S","",""})
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_CLIENTE","","S","",""})
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_SALDO"," ","S","",""})
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_ATRASO"," ","S","",""})

Reclock("QTMP2",.T.)
QTMP2->XX_DIAS    := "30"
QTMP2->XX_INDICE  := "30"
QTMP2->XX_CLIENTE := "TÍTULOS VENCIDOS DE 11 À 30 DIAS"
dbUnLock()
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_DIAS","","S","",""})
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_CLIENTE","","S","",""})
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_SALDO"," ","S","",""})
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_ATRASO"," ","S","",""})

Reclock("QTMP2",.T.)
QTMP2->XX_DIAS    := "60"
QTMP2->XX_INDICE  := "60"
QTMP2->XX_CLIENTE := "TÍTULOS VENCIDOS DE 31 À 60 DIAS"
dbUnLock()
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_DIAS","","S","",""})
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_CLIENTE","","S","",""})
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_SALDO"," ","S","",""})
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_ATRASO"," ","S","",""})


Reclock("QTMP2",.T.)
QTMP2->XX_DIAS    := "ZZ"
QTMP2->XX_INDICE  := "ZZ"
QTMP2->XX_CLIENTE := "TÍTULOS VENCIDOS A MAIS DE 60 DIAS"
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_DIAS","","S","",""})
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_CLIENTE","","S","",""})
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_SALDO"," ","S","",""})
aAdd(aFormula3,{QTMP2->(RECNO()),"QTMP2->XX_ATRASO"," ","S","",""})
dbUnLock()


DbSelectArea("QTMP1")
dbGoTop()

Do While !EOF()
	DbSelectArea("QTMP2")

	If QTMP1->XX_ATRASO <= 0
		IF dbSeek('00'+QTMP1->XX_CLIENTE+QTMP1->XX_VENCREC,.F.)
			Reclock("QTMP2",.F.)
		Else
			Reclock("QTMP2",.T.)
			QTMP2->XX_DIAS    := "00"
			QTMP2->XX_INDICE  := '00'+QTMP1->XX_CLIENTE+QTMP1->XX_VENCREC
			QTMP2->XX_CLIENTE := QTMP1->XX_CLIENTE
			QTMP2->XX_ATRASO  := QTMP1->XX_ATRASO
		EndIf
		QTMP2->XX_SALDO += QTMP1->XX_SALDO
		dbUnLock()

	ElseIf QTMP1->XX_ATRASO <= 10
		IF dbSeek('10'+QTMP1->XX_CLIENTE+QTMP1->XX_VENCREC,.F.)
			Reclock("QTMP2",.F.)
		Else
			Reclock("QTMP2",.T.)
			QTMP2->XX_DIAS    := "10"
			QTMP2->XX_INDICE  := '10'+QTMP1->XX_CLIENTE+QTMP1->XX_VENCREC
			QTMP2->XX_CLIENTE := QTMP1->XX_CLIENTE
			QTMP2->XX_ATRASO  := QTMP1->XX_ATRASO
		EndIf
		QTMP2->XX_SALDO += QTMP1->XX_SALDO
		dbUnLock()

	ElseIf QTMP1->XX_ATRASO <= 30
		IF dbSeek('30'+QTMP1->XX_CLIENTE+QTMP1->XX_VENCREC,.F.)
			Reclock("QTMP2",.F.)
		Else
			Reclock("QTMP2",.T.)
			QTMP2->XX_DIAS    := "30"
			QTMP2->XX_INDICE  := '30'+QTMP1->XX_CLIENTE+QTMP1->XX_VENCREC
			QTMP2->XX_CLIENTE := QTMP1->XX_CLIENTE
			QTMP2->XX_ATRASO  := QTMP1->XX_ATRASO
		EndIf
		QTMP2->XX_SALDO += QTMP1->XX_SALDO
		dbUnLock()
	ElseIf QTMP1->XX_ATRASO <= 60
		IF dbSeek('60'+QTMP1->XX_CLIENTE+QTMP1->XX_VENCREC,.F.)
			Reclock("QTMP2",.F.)
		Else
			Reclock("QTMP2",.T.)
			QTMP2->XX_DIAS    := "60"
			QTMP2->XX_INDICE  := '60'+QTMP1->XX_CLIENTE+QTMP1->XX_VENCREC
			QTMP2->XX_CLIENTE := QTMP1->XX_CLIENTE
			QTMP2->XX_ATRASO  := QTMP1->XX_ATRASO
		EndIf
		QTMP2->XX_SALDO += QTMP1->XX_SALDO
		dbUnLock()
	Else
		IF dbSeek('ZZ'+QTMP1->XX_CLIENTE+QTMP1->XX_VENCREC,.F.)
			Reclock("QTMP2",.F.)
		Else
			Reclock("QTMP2",.T.)
			QTMP2->XX_DIAS    := "ZZ"
			QTMP2->XX_INDICE  := 'ZZ'+QTMP1->XX_CLIENTE+QTMP1->XX_VENCREC
			QTMP2->XX_CLIENTE := QTMP1->XX_CLIENTE
			QTMP2->XX_ATRASO  := QTMP1->XX_ATRASO
		EndIf
		QTMP2->XX_SALDO += QTMP1->XX_SALDO
		dbUnLock()

	EndIf

	dbUnLock()

	DbSelectArea("QTMP1")
	dbSkip()
ENDDO


Return Nil


// Calculo do atrazo em dias
User Function AtrsRec(dVencRea)
Local nDias := 0
If dVencRea < dDataBase
	nDias := dDataBase - dVencRea + 1
EndIf
Return nDias


// Saldo a receber do titulo informado pelo recno
User Function SaldoRec(nRecE1)
Local nSaldo	 := 0
Local aArea 	 := GetArea()
Local aAreaSE1	 := SE1->(GetArea())

// --> Copiado do FINC040
Local lClcMultLj := ( SuperGetMv("MV_JURTIPO",,"") == "L" ) .Or. ( SuperGetMv("MV_LJINTFS", ,.F.) )

Private nAbatim  := 0
Private nDescFin := 0
Private nMultaTit:= 0
Private nValAces := 0
Private nJuros	 := 0  // Private
Private nMulta	 := 0  // Private

If nRecE1 > 0

	DbSelectArea("SE1")
	dbGoTo(nRecE1)
	iF SE1->E1_NUM = '000000622'
		X:= 0
	eNDiF
	If SE1->E1_SALDO = 0
  			//dBaixa := SE1->E1_BAIXA
		nSaldo := SE1->E1_VALOR
	Else
		nSaldo := SaldoTit( SE1->E1_PREFIXO ,SE1->E1_NUM  ,SE1->E1_PARCELA ,SE1->E1_TIPO , ;
						SE1->E1_NATUREZ ,"R"           ,SE1->E1_CLIENTE , 1           , ;
						NIL             ,NIL           ,SE1->E1_LOJA    ,NIL          , ;
						If(cPaisLoc=="BRA",SE1->E1_TXMOEDA,0) )
	EndIf
	//Desconto Financeiro e Abatimento
	IF !(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
		//Abatimento
		nAbatim	 := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,"R",SE1->E1_MOEDA,,SE1->E1_CLIENTE,SE1->E1_LOJA)
		//Desconto Financeiro
		If SE1->E1_VENCREA >= dDataBase .AND. SE1->E1_SALDO > 0
			nDescFin   := FaDescFin("SE1",dDataBase,SE1->E1_SALDO-nAbatim,SE1->E1_MOEDA)
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se o Saldo ja estiver Zero, nao calcular os juros.           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE1->E1_SALDO > 0
			If lClcMultLj
				//*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//*³ Calcula o valor da Multa  :funcao LojxRMul :fonte Lojxrec          ³
				//*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nMultaTit := LojxRMul(,,,nSaldo,SE1->E1_ACRESC,SE1->E1_VENCREA,dDataBase,,SE1->E1_MULTA,,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,"SE1",.T.)
			EndIf
			fa070Juros(1, nSaldo)
			
			If	ExistFunc('FValAcess')
				nValAces := FValAcess(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA, SE1->E1_NATUREZ,!Empty(SE1->E1_BAIXA),,"R",SE1->E1_BAIXA,,SE1->E1_MOEDA)		
			EndIf
		Endif
	Endif
	nJuros   += nMulta
	If Empty(SE1->E1_BAIXA)
		//@ 012, 055 SAY Trans(SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE + nJuros + nValAces + nMultaTit - nAbatim - nDescFin, tm(SE1->E1_SALDO, 17, ncasas)) SIZE 50,16 OF oPanel3 PIXEL //"Saldo T¡tulo (Impostos)"
		nSaldo := SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE + nJuros + nValAces + nMultaTit - nAbatim - nDescFin - SE1->E1_XXVRETC - SE1->E1_XXVCVIN
	Else	
		If SE1->E1_SALDO = 0 
			//@ 012, 055 SAY Trans(SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE + nJuros + nValAces + nMultaTit, tm(SE1->E1_SALDO, 17, ncasas)) SIZE 50,16 OF oPanel3 PIXEL //"Saldo T¡tulo (Impostos)"
			nSaldo := SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE + nJuros + nValAces + nMultaTit
		Else
			//@ 012, 055 SAY Trans(SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE + nJuros + nValAces + nMultaTit - nAbatim - nDescFin, tm(SE1->E1_SALDO, 17, ncasas)) SIZE 50,16 OF oPanel3 PIXEL //"Saldo T¡tulo (Impostos)"
			nSaldo := SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE + nJuros + nValAces + nMultaTit - nAbatim - nDescFin
		EndIf
	EndIf
EndIf
//<-- FINC040

SE1->(RestArea(aAreaSE1))
RestArea(aArea)

Return nSaldo
