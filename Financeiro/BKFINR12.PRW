#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} BKFINR12
BK - Contas a Receber
@Return
@author Adilson do Prado
@since 11/07/14
@version P12
/*/

User Function BKFINR12()

Local titulo         := ""
Local aTitulos,aCampos,aCabs
Local oDlg01		AS Object
Local aButtons 		:= {}
Local lOk 			:= .F.
Local oPanelLeft 	AS Object

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := "G"
Private limite       := 220
Private tamanho      := " "
Private nomeprog     := "BKFINR12" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "BKFINR12"
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "BKFINR12" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString      := "CN9"

Private nEmissao 	 := 1
Private cMesComp     := ""
Private cAnoComp     := ""
Private cCompet      := ""
Private dDataI   	 := CTOD("")
Private dDataF   	 := CTOD("")
Private cContrato	 := ""
Private cNFIni       := ""
Private cNFFim       := ""
Private aTipoEmis    := {"1-Competência","2-Vencimento","3-Centro de Custo","4-Emissão","5-NF/Título"}
Private cTipoEmis    := ""


dbSelectArea(cString)
dbSetOrder(1)

//cPerg        := "1BKFINR12"
//ValidPerg1(cPerg)
//If !Pergunte(cPerg,.T.)
//	Return
//Endif

cTipoEmis := aTipoEmis[1] 

Define MsDialog oDlg01 Title "BKFINR12 - Relação de Contas a receber" From 000,000 To 150,330 Of oDlg01 Pixel
	
@ 000,000 MSPANEL oPanelLeft OF oDlg01 SIZE 380,600 
oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
@ 15,10 SAY 'Emitir por:'   SIZE 080,010 OF oPanelLeft PIXEL
@ 15,45 COMBOBOX cTipoEmis  ITEMS aTipoEmis SIZE 100,010 Pixel OF oPanelLeft 
	
ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

If ( !lOk )
	RETURN NIL
EndIf

                                                                                                                                     
//nEmissao := mv_par01

If VALTYPE(cTipoEmis) <> "N"
	nEmissao := VAL(SUBSTR(cTipoEmis,1,1))
Else
	nEmissao := cTipoEmis
EndIf
                                                                                                                                     
//nEmissao := mv_par01

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
		titulo   := "Contas a Recebidas "
	ENDIF

ENDIF


ProcRegua(1)
Processa( {|| ProcQuery() })

aCabs   := {}
aCampos := {}
aTitulos:= {}
   
nomeprog := "BKFINR12/"+TRIM(SUBSTR(cUsuario,7,15))
AADD(aTitulos,nomeprog+" - "+titulo)

AADD(aCampos,"QTMP->A1_NOME")
AADD(aCabs  ,"CLIENTE")

AADD(aCampos,"QTMP->CONTRATO")
AADD(aCabs  ,"Contrato")

AADD(aCampos,'IIF(!EMPTY(QTMP->CONTRATO),ALLTRIM(Posicione("CTT",1,xFilial("CTT")+QTMP->CONTRATO,"CTT_DESC01")),"")')
AADD(aCabs  ,"Centro de Custos")

AADD(aCampos,"QTMP->CND_COMPET")
AADD(aCabs  ,"Competencia")

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

AADD(aCampos,"QTMP->F2_XXVCVIN")
AADD(aCabs  ,"Conta Vinculada")

AADD(aCampos,"QTMP->F2_XXVFUMD")
AADD(aCabs  ,"FUMDIP OSASCO")


AADD(aCampos,"QTMP->E1_VALOR - QTMP->E1_IRRF - QTMP->E1_INSS - QTMP->E1_PIS - QTMP->E1_COFINS - QTMP->E1_CSLL - QTMP->F2_XXVCVIN - QTMP->F2_XXVFUMD - IIF(QTMP->F2_RECISS = '1',QTMP->E1_ISS,0)")
AADD(aCabs  ,"Valor liquido")

AADD(aCampos,"IIF(QTMP->E1_SALDO > 0,QTMP->E1_VALOR - QTMP->E1_IRRF - QTMP->E1_INSS - QTMP->E1_PIS - QTMP->E1_COFINS - QTMP->E1_CSLL - QTMP->F2_XXVCVIN - QTMP->F2_XXVFUMD - IIF(QTMP->F2_RECISS = '1',QTMP->E1_ISS,0) - (QTMP->E1_VALOR - QTMP->E1_SALDO),0)")
AADD(aCabs  ,"Saldo a Receber")


ProcRegua(QTMP->(LASTREC()))
Processa( {|| U_GeraCSV("QTMP",wnrel,aTitulos,aCampos,aCabs)})
   
Return


Static Function ProcQuery
Local cQuery

IncProc("Consultando o banco de dados...")

cQuery := "SELECT DISTINCT A1_NOME,E1_VENCREA,E1_VENCORI,E1_VALOR,E1_SALDO"

cQuery += ",CASE WHEN E1_TIPO <> 'NDC' THEN CND_COMPET ELSE SUBSTRING(E1_XXCOMPE,5,2)+'/'+SUBSTRING(E1_XXCOMPE,1,4) END AS CND_COMPET" 

//cQuery += ",F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS"
//cQuery += ",F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS"
cQuery += ",E1_NUM,E1_PARCELA,E1_EMISSAO,E1_VALOR,E1_IRRF,E1_INSS,E1_PIS,E1_COFINS,E1_CSLL,E1_ISS"
cQuery += ",F2_RECISS,F2_XXVCVIN,F2_XXVFUMD"
cQuery += ",CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1"
cQuery += "     ELSE C5_MDCONTR END AS CONTRATO,"
cQuery += " CASE WHEN E1_VALOR<>E1_SALDO THEN 'Baixa Parcial' ELSE '' END AS E1_XXOBX "
cQuery += " FROM "+RETSQLNAME("SE1")+ " SE1 "
cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+ " SF2 ON SF2.D_E_L_E_T_='' AND SE1.E1_NUM=SF2.F2_DUPL "
cQuery += " AND SE1.E1_PREFIXO=SF2.F2_PREFIXO AND SE1.E1_CLIENTE=SF2.F2_CLIENTE AND SE1.E1_LOJA=SF2.F2_LOJA"
cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON SC5.C5_NUM=SE1.E1_PEDIDO AND SC5.D_E_L_E_T_='' "
cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON SC5.C5_NUM=CND.CND_PEDIDO AND CND.D_E_L_E_T_=''"
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON SA1.D_E_L_E_T_='' AND SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA"
cQuery += " WHERE SE1.D_E_L_E_T_='' AND SE1.E1_TIPO IN('NF','NDC')"
IF nEmissao <> 2
	cQuery += " AND SE1.E1_SALDO > 0 "
ENDIF 
  //AND SE1.E1_VALOR=SF2.F2_VALFAT " 

//cQuery += " AND SUBSTRING(C5_MDCONTR,1,3) <> '105' "  //AND SUBSTRING(C5_ESPECI1,1,3) <> '105' "  // Eliminar Furnas

IF nEmissao == 1
	cQuery += " AND CND_COMPET='"+cCompet+"'"
ELSEIF nEmissao == 2
	cQuery += " AND E1_VENCREA>='"+DTOS(dDataI)+"' AND E1_VENCREA<='"+DTOS(dDataF)+"'"
ELSEIF nEmissao == 3
	IF !EMPTY(cContrato) 
		cQuery += " AND (C5_MDCONTR='"+ALLTRIM(cContrato)+"' OR  C5_ESPECI1='"+ALLTRIM(cContrato)+"' )"
    ELSEIF !EMPTY(cAnoComp) 
		cQuery += " AND SUBSTRING(E1_VENCREA,1,4)="+cAnoComp
	ENDIF
ELSEIF nEmissao == 4
	cQuery += " AND E1_EMISSAO>='"+DTOS(dDataI)+"' AND E1_EMISSAO<='"+DTOS(dDataF)+"'"
ELSEIF nEmissao == 5
	IF !EMPTY(cNFIni) 
		cQuery += " AND E1_NUM >= '"+ALLTRIM(cNFIni)+"'"
	ENDIF
	IF !EMPTY(cNFFim) 
		cQuery += " AND E1_NUM <= '"+ALLTRIM(cNFFim)+"'"
	ENDIF
ENDIF 

//IF nEmissao == 4
//	cQuery += "ORDER BY E1_EMISSAO"
//ELSEIF nEmissao == 5
//	cQuery += "ORDER BY E1_NUM"
//ELSE
	cQuery += "ORDER BY E1_VENCREA"
//ENDIF

u_LogMemo("BKFINR12.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","E1_EMISSAO","D",8,0)
TCSETFIELD("QTMP","E1_VENCREA","D",8,0)
TCSETFIELD("QTMP","E1_VENCORI","D",8,0)

Return


/*
Static Function  ValidPerg1

Local aArea      := GetArea()
Local aRegistros := {}
cPerg := "1BKFINR12"
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)


AADD(aRegistros,{cPerg,"01","Emitir por:","Emitir por:","Emitir por:","mv_ch1","N",01,0,2,"C","","mv_par01","Competência","Competência","Competência","","","Vencimento","Vencimento","Vencimento","","","Centro de Custo","Centro de Custo","Centro de Custo","","","","","","","","","","","",""})

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
*/

Static Function  ValidPerg2

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
