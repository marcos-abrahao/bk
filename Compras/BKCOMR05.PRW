#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
 
/*/{Protheus.doc} BKCOMR05
BK - Relatório Avaliação dos Fornecedores

@Return
@author Adilson do Prado
@since 25/04/14 rev 31/10/22
@version P12
/*/

User Function BKCOR05()

Local aDbf 		    := {}
Local oTmpTb
Local aPlans  		:= {}

Private cTitulo     := "Avaliação dos Fornecedores"
Private cTitulo2    := "Avaliação dos Fornecedores"
Private cPerg       := "BKCOR05"
Private aTitulos,aCampos,aCabs,aTotal
Private aTitulos2,aCampos2,aCabs2,aTotal2
Private aImprD		:= {}
Private dDataI		:= dDatabase
Private dDataF  	:= dDatabase
Private nComPed     := 0
Private nDet        := 0

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

dDataI   := mv_par01
dDataF   := mv_par02
nComPed	 := mv_par03
nDet	 := mv_par04

cTitulo  := "Avaliação dos Fornecedores - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)

aDbf    := {}
Aadd( aDbf, { 'XX_FORNEC', 	'C', 06,00 } )
Aadd( aDbf, { 'XX_LOJA',   	'C', 02,00 } ) 
Aadd( aDbf, { 'XX_FANTASI',	'C', 20,00 } ) 
Aadd( aDbf, { 'XX_NFORNEC',	'C', 80,00 } )
Aadd( aDbf, { 'XX_AVALC',	'C', 03,00 } )
Aadd( aDbf, { 'XX_QNTNF',	'N', 10,00 } ) 
Aadd( aDbf, { 'XX_AVAL1',	'N', 10,00 } ) 
Aadd( aDbf, { 'XX_AVAL2',	'N', 10,00 } ) 
Aadd( aDbf, { 'XX_AVAL3',	'N', 10,00 } ) 
Aadd( aDbf, { 'XX_AVAL4',	'N', 10,00 } ) 
Aadd( aDbf, { 'XX_TAVAL',	'N', 10,00 } ) 
Aadd( aDbf, { 'XX_MDAVAL',	'N', 10,00 } ) 

oTmpTb := FWTemporaryTable():New( "TRB")
oTmpTb:SetFields( aDbf )
oTmpTb:AddIndex("indice1", {"XX_FORNEC","XX_LOJA"} )
oTmpTb:Create()

aCabs   := {}
aCampos := {}
aTitulos:= {}
aTotal  := {}

aAdd(aTitulos,cTitulo)

aAdd(aCampos,"TRB->XX_FORNEC")
aAdd(aCabs  ,"Cod. Fornecedor")
aAdd(aTotal,.F.)

aAdd(aCampos,"TRB->XX_LOJA")
aAdd(aCabs  ,"Loja Fornecedor")
aAdd(aTotal,.F.)

aAdd(aCampos,"TRB->XX_FANTASI")
aAdd(aCabs  ,"Nome Fantasia")
aAdd(aTotal,.F.)

aAdd(aCampos,"TRB->XX_NFORNEC")
aAdd(aCabs  ,"Razão Social")
aAdd(aTotal,.F.)

aAdd(aCampos,"TRB->XX_AVALC")
aAdd(aCabs  ,"Avaliação Crítica")
aAdd(aTotal,.F.)

aAdd(aCampos,"TRB->XX_QNTNF")
aAdd(aCabs  ,"Qtde NF's entregues")
aAdd(aTotal,.T.)

If nDet == 1
	aAdd(aCampos,"TRB->XX_AVAL1")
	aAdd(aCabs  ,"Preço")
	aAdd(aTotal,.T.)

	aAdd(aCampos,"TRB->XX_AVAL2")
	aAdd(aCabs  ,"Prazo")
	aAdd(aTotal,.T.)

	aAdd(aCampos,"TRB->XX_AVAL3")
	aAdd(aCabs  ,"Quantidade/Atendimento")
	aAdd(aTotal,.T.)

	aAdd(aCampos,"TRB->XX_AVAL4")
	aAdd(aCabs  ,"Qualidade/Integridade")
	aAdd(aTotal,.T.)

	aAdd(aCampos,"TRB->XX_TAVAL")
	aAdd(aCabs  ,"Total da Avaliação")
	aAdd(aTotal,.T.)
EndIf

aAdd(aCampos,"TRB->XX_MDAVAL")
aAdd(aCabs  ,"Média da Avaliação (IQF)")
aAdd(aTotal,.F.)

u_WaitLog(cPerg, {|| ProcBKCOR05() },"Processando dados...")

aAdd(aPlans,{"TRB",TRIM(cPerg)    ,"",cTitulo,aCampos,aCabs,/* aImpr */, /* aAlign */,/* aFormat */, aTotal/*aTotal */, /*cQuebra*/, lClose:= .F. })

If nDet == 1

	aCabs2   := {}
	aCampos2 := {}
	aTitulos2:= {}
	aTotal2  := {}

	aAdd(aTitulos2,cTitulo2)

	aAdd(aCampos2,"QTMP->F1_DOC")
	aAdd(aCabs2  ,"Documento")
	aAdd(aTotal2 ,.F.)

	aAdd(aCampos2,"QTMP->F1_SERIE")
	aAdd(aCabs2  ,"Série")
	aAdd(aTotal2 ,.F.)

	aAdd(aCampos2,"QTMP->D1_PEDIDO")
	aAdd(aCabs2  ,"Pedido")
	aAdd(aTotal2 ,.F.)

	aAdd(aCampos2,"QTMP->F1_FORNECE")
	aAdd(aCabs2  ,"Fornecedor")
	aAdd(aTotal2 ,.F.)

	aAdd(aCampos2,"QTMP->F1_LOJA")
	aAdd(aCabs2  ,"Loja")
	aAdd(aTotal2 ,.F.)

	aAdd(aCampos2,"QTMP->A2_NOME")
	aAdd(aCabs2  ,"Nome")
	aAdd(aTotal2 ,.F.)

	aAdd(aCampos2,"QTMP->F1_EMISSAO")
	aAdd(aCabs2  ,"Emissão")
	aAdd(aTotal2 ,.F.)

	aAdd(aCampos2,"QTMP->F1_DTDIGIT")
	aAdd(aCabs2  ,"Entrada")
	aAdd(aTotal2 ,.F.)

	aAdd(aCampos2,"QTMP->F1_XXAVALI")
	aAdd(aCabs2  ,"Avaliação")
	aAdd(aTotal2 ,.F.)

	aAdd(aCampos2,"QTMP->A2_XXAVALC")
	aAdd(aCabs2  ,"Av. crítica")
	aAdd(aTotal2 ,.F.)

	aAdd(aPlans,{"QTMP",TRIM(cPerg)+"-Det" ,"",cTitulo2,aCampos2,aCabs2,/*aImpr*/, /* aAlign */,/* aFormat */, aTotal2/*aTotal */, /*cQuebra*/, lClose:= .T. })
EndIf

U_PlanXlsx(aPlans,cTitulo,cPerg,.T.)

oTmpTb:Delete()

Return



Static Function ProcBKCOR05
Local cQuery := ""
Local nReg := 0

cQuery := "SELECT DISTINCT "+CRLF
cQuery += "  F1_FILIAL,"+CRLF
cQuery += "  F1_DOC,"+CRLF
cQuery += "  F1_SERIE,"+CRLF
cQuery += "  F1_FORNECE,"+CRLF
cQuery += "  F1_LOJA,"+CRLF
cQuery += "  F1_EMISSAO,"+CRLF
cQuery += "  F1_DTDIGIT,"+CRLF
cQuery += "  F1_XXAVALI,"+CRLF
cQuery += "  F1_XXAVAL,"+CRLF
cQuery += "  D1_PEDIDO,"+CRLF
cQuery += "  SA2.A2_NREDUZ,"+CRLF
cQuery += "  SA2.A2_NOME,"+CRLF
cQuery += "  SA2.A2_XXAVALC"+CRLF
cQuery += " FROM "+RETSQLNAME("SF1")+" SF1"
cQuery += " LEFT JOIN "+RETSQLNAME("SA2")+" SA2 ON  SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SF1.F1_FORNECE=SA2.A2_COD AND SF1.F1_LOJA=SA2.A2_LOJA AND SA2.D_E_L_E_T_=''" +CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SD1")+" SD1 ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND SF1.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " WHERE SF1.D_E_L_E_T_='' AND SF1.F1_DTDIGIT >= '"+DTOS(dDataI)+"' AND SF1.F1_DTDIGIT <= '"+DTOS(dDataF)+"' AND SF1.F1_XXAVALI <> ''"+CRLF
If nComPed == 1
	cQuery += " AND (SD1.D1_PEDIDO <> '' OR SF1.F1_XXAVAL = 'S')"+CRLF
EndIf

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","F1_DTDIGIT","D",8,0)

nReg := 0

dbSelectArea("QTMP")
QTMP->(dbGoTop())
DO WHILE QTMP->(!EOF())
    nReg++
	//IncProc("Consultando banco de dados...")
	dbSelectArea("TRB")
	IF dbSeek(QTMP->F1_FORNECE+QTMP->F1_LOJA,.F.)
		Reclock("TRB",.F.)
 		TRB->(Msunlock())
	ELSE
		Reclock("TRB",.T.)
		TRB->XX_FORNEC	:= QTMP->F1_FORNECE
		TRB->XX_LOJA 	:= QTMP->F1_LOJA
		TRB->XX_FANTASI := QTMP->A2_NREDUZ
		TRB->XX_NFORNEC := QTMP->A2_NOME
		TRB->XX_AVALC   := IIF(QTMP->A2_XXAVALC=="S","SIM","NAO")
		TRB->XX_QNTNF   := 0
	ENDIF
	TRB->XX_QNTNF   += 1
	TRB->XX_AVAL1	+= IIF(SUBSTR(QTMP->F1_XXAVALI,1,1)='S',25,0)
	TRB->XX_AVAL2	+= IIF(SUBSTR(QTMP->F1_XXAVALI,2,1)='S',25,0)
	TRB->XX_AVAL3	+= IIF(SUBSTR(QTMP->F1_XXAVALI,3,1)='S',25,0)
	TRB->XX_AVAL4	+= IIF(SUBSTR(QTMP->F1_XXAVALI,4,1)='S',25,0)

	TRB->XX_TAVAL	+= 	IIF(SUBSTR(QTMP->F1_XXAVALI,1,1)='S',25,0)+IIF(SUBSTR(QTMP->F1_XXAVALI,2,1)='S',25,0)+IIF(SUBSTR(QTMP->F1_XXAVALI,3,1)='S',25,0)+IIF(SUBSTR(QTMP->F1_XXAVALI,4,1)='S',25,0)
	TRB->(Msunlock())

	dbSelectArea("QTMP")
	QTMP->(dbSkip())
ENDDO

IF nReg < 1
	Reclock("TRB",.T.)
	TRB->XX_FORNEC 	:= "Null"
 	TRB->(Msunlock())
ELSE
	dbSelectArea("TRB")
	TRB->(dbGoTop())
	DO WHILE TRB->(!EOF())
		Reclock("TRB",.F.)
		TRB->XX_MDAVAL	:= TRB->XX_TAVAL / TRB->XX_QNTNF
 		TRB->(Msunlock())
		dbSelectArea("TRB")
		TRB->(dbSkip())
	ENDDO
ENDIF

TRB->(dbGoTop())

Return



Static Function  ValidPerg(cPerg)
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Data de Entrada de:"  ,"Data da Compra de:"   ,"Data da Compra de:"   ,"mv_ch1","D",08,0,0,"G","NaoVazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Data de Entrada até:" ,"Data de Entrada até:" ,"Data de Entrada até:" ,"mv_ch2","D",08,0,0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Somente com pedido?"  ,"Somente com pedido?"  ,"Somente com pedido?"  ,"mv_ch3","N",01,0,2,"C",""          ,"mv_par03","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"04","Detalhado?"           ,"Detalhado?"           ,"Detalhado?"           ,"mv_ch4","N",01,0,2,"C",""          ,"mv_par04","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","S","",""})

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
