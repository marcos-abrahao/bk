#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKGCTR10
BK - Histórico de Multa e Bonificações
18/11/14 - Alterado conceito de glosa para multa,Bonificações

@Return
@author Marcos Bispo Abrahão
@since 26/04/12 Rev 14/04/22
@version P12
/*/

User Function BKGCTR10()

Local cTitulo   := ""
Local aCabs     := {}
Local aCampos   := {}
Local aTitulos  := {}
Local aPlans    := {}
Private cPerg   := "BKGCTR10"
Private cContrat:= ""
Private cRevisa := ""
Private cDescr  := ""

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
Endif
u_MsgLog(cPerg)

cContrat := mv_par01

BKCNR10(cContrat)

cTitulo  := "Histórico de Multa e Bonificações: "+TRIM(cContrat)+"-"+cRevisa+" - "+cDescr 

FWMsgRun(, {|oSay| ProcQuery() }, "", cPerg+" - Consultando dados...")
  
AADD(aTitulos,cTitulo)

AADD(aCampos,"QTMP->CND_COMPET")
AADD(aCabs  ,"Competencia")

AADD(aCampos,"IIF(QTMP->CNR_TIPO = '2','Bonificação','Multa')")
AADD(aCabs  ,"Competencia")

AADD(aCampos,"QTMP->CNR_DESCRI")
AADD(aCabs  ,"Descrição")

AADD(aCampos,"QTMP->ZR_XDESCR")
AADD(aCabs  ,"Tipo")

AADD(aCampos,"IIF(QTMP->CNR_TIPO = '2',-CNR_VALOR,CNR_VALOR)")
AADD(aCabs  ,"Valor")

AADD(aPlans,{"QTMP",cPerg,"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
U_PlanXlsx(aPlans,cTitulo,cPerg,.F.)

Return


Static Function ProcQuery
Local cQuery

IncProc("Consultando o banco de dados...")

cQuery := "SELECT "+ CRLF
cQuery += " CND_COMPET,"+ CRLF
cQuery += " CNR_TIPO,"+ CRLF
cQuery += " CNR_DESCRI,"+ CRLF
cQuery += " CNR_VALOR,"+ CRLF
cQuery += " RTRIM(CNR_XTPJUS+'-'+ZR_DESCR) AS ZR_XDESCR "+ CRLF
cQuery += " FROM "+RETSQLNAME("CNR")+" CNR"+ CRLF
cQuery += "	   INNER JOIN "+RETSQLNAME("CND")+" CND ON CND_NUMMED = CNR_NUMMED "+ CRLF
cQuery += "	         AND CND_CONTRA = '"+cContrat+"' AND CND_REVISA = '"+cRevisa+"' "+ CRLF
cQuery += "	         AND CND.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += "	   LEFT  JOIN SZR010 SZR ON ZR_TIPO = CNR_XTPJUS AND SZR.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " WHERE CNR_FILIAL = CND_FILIAL AND CNR.D_E_L_E_T_ = ' ' "+ CRLF

//cQuery += "	                     SUBSTRING(CNDB.CND_COMPET,4,4)+SUBSTRING(CNDB.CND_COMPET,1,2) < '201203' 

cQuery += " ORDER BY CND_DTFIM,CND_COMPET "  

u_LogMemo("BKGCTR10A.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP",.T.,.T.)
TCSETFIELD("QTMP","CND_DTFIM","D",8,0)

Return



Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}
Local i,j

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
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP1",.T.,.T.)
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
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QTMP1",.T.,.T.)
dbSelectArea("QTMP1")
dbGoTop()
DO WHILE !EOF()
    cDescr := QTMP1->CN9_XXDESC
	dbSelectArea("QTMP1")
	dbSkip()
ENDDO

QTMP1->(Dbclosearea())

Return
