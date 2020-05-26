#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR10
BK - Histórico de Multa e Bonificações
18/11/14 - Alterado conceito de glosa para multa,Bonificações

@Return
@author Marcos Bispo Abrahão
@since 26/04/12 Rev 26/05/20
@version P12
/*/

User Function BKGCTR10()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local titulo         := ""
Local aTitulos,aCampos,aCabs,aPlans

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := " "
Private nomeprog     := "BKGCTR10" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "BKGCTR10"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "BKGCTR10" // Coloque aqui o nome do arquivo usado para impressao em disco
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

cContrat := mv_par01
cRevisa  := ""
cDescr   := ""

BKCNR10(cContrat)

titulo   := "Histórico de Multa e Bonificações: "+TRIM(cContrat)+"-"+cRevisa+" - "+cDescr 

If .f. //nPlan = 2

Else
	ProcRegua(1)
	Processa( {|| ProcQuery() })

	aCabs   := {}
	aCampos := {}
	aTitulos:= {}
	aPlans  := {}
  
	nomeprog := "BKGCTR10/"+TRIM(SUBSTR(cUsuario,7,15))
	AADD(aTitulos,nomeprog+" - "+titulo)

	AADD(aCampos,"QTMP->CND_COMPET")
	AADD(aCabs  ,"Competencia")

	AADD(aCampos,"IIF(QTMP->CNR_TIPO = '2','Bonificação','Multa')")
	AADD(aCabs  ,"Competencia")

	AADD(aCampos,"QTMP->CNR_DESCRI")
	AADD(aCabs  ,"Descrição")

	AADD(aCampos,"IIF(QTMP->CNR_TIPO = '2',-CNR_VALOR,CNR_VALOR)")
	AADD(aCabs  ,"Valor")

	//ProcRegua(QTMP->(LASTREC()))
	//Processa( {|| U_GeraCSV("QTMP","BKGCT10",aTitulos,aCampos,aCabs)})

	AADD(aPlans,{"QTMP",cPerg,"",Titulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
	U_GeraXlsx(aPlans,Titulo,cPerg,.F.)
	   
EndIf	
Return


Static Function ProcQuery
Local cQuery

IncProc("Consultando o banco de dados...")

cQuery := " SELECT CND_DTFIM,CND_COMPET,CNR_TIPO,CNR_DESCRI,CNR_VALOR "+ CRLF
cQuery += " FROM "+RETSQLNAME("CNR")+" CNR"+ CRLF
cQuery += "	          INNER JOIN "+RETSQLNAME("CND")+" CND ON CND_NUMMED = CNR_NUMMED "+ CRLF
cQuery += "	                AND CND_CONTRA = '"+cContrat+"' AND CND_REVISA = '"+cRevisa+"' "+ CRLF
cQuery += "	                AND CND.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += "	          WHERE CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' "+ CRLF

//cQuery += "	                     SUBSTRING(CNDB.CND_COMPET,4,4)+SUBSTRING(CNDB.CND_COMPET,1,2) < '201203' 

cQuery += " ORDER BY CND_DTFIM,CND_COMPET "  

u_LogMemo("BKGCTR10A.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","CND_DTFIM","D",8,0)

Return



Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

aAdd(aRegistros,{cPerg,"01","Contrato: "        ,"" ,"" ,"mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CN9"})

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

STATIC FUNCTION BKCNR10(cContrat)
LOCAL cQuery

cQuery := " SELECT MAX(CN9_REVISA) XX_REVISA FROM "+RETSQLNAME("CN9")+" CN9 WHERE CN9_NUMERO = '"+cContrat+"' "
cQuery += "             AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND CN9.D_E_L_E_T_ = ' ' "
TCQUERY cQuery NEW ALIAS "QTMP1"
dbSelectArea("QTMP1")
dbGoTop()
DO WHILE !EOF()
    cRevisa := QTMP1->XX_REVISA
	dbSelectArea("QTMP1")
	dbSkip()
ENDDO

QTMP1->(Dbclosearea())

cQuery := " SELECT CN9_XXDESC FROM "+RETSQLNAME("CN9")+" CN9 WHERE CN9_NUMERO = '"+cContrat+"' AND CN9_REVISA = '"+cRevisa+"' "
cQuery += "             AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND CN9.D_E_L_E_T_ = ' ' "
TCQUERY cQuery NEW ALIAS "QTMP1"
dbSelectArea("QTMP1")
dbGoTop()
DO WHILE !EOF()
    cDescr := QTMP1->CN9_XXDESC
	dbSelectArea("QTMP1")
	dbSkip()
ENDDO

QTMP1->(Dbclosearea())

Return
