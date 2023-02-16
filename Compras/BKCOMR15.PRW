#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
 
/*/{Protheus.doc} BKCOMR15
BK - Relação de Fornecedores - (se já foi avaliado ou não)

@Return
@author Marcos B. Abrahão
@since 14/02/2022
@version P12
/*/

User Function BKCOMR15()

Local aPlans  		:= {}
Local aCabs   		:= {}
Local aCampos 		:= {}
Local aTitulos		:= {}

Private cTitulo     := "Relação de Fornecedores"
Private cPerg       := "BKCOMR15"
Private dDataI		:= dDatabase
Private dDataF  	:= dDatabase

/*
ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif
*/

dDataI   := mv_par01
dDataF   := mv_par02

aAdd(aTitulos,cTitulo)

aAdd(aCampos,"QTMP->A2_COD")
aAdd(aCabs  ,FwX3Titulo("A2_COD"))

aAdd(aCampos,"QTMP->A2_LOJA")
aAdd(aCabs  ,FwX3Titulo("A2_LOJA"))

aAdd(aCampos,"QTMP->A2_NOME")
aAdd(aCabs  ,FwX3Titulo("A2_NOME"))

aAdd(aCampos,"QTMP->A2_NREDUZ")
aAdd(aCabs  ,FwX3Titulo("A2_NREDUZ"))

aAdd(aCampos,"TRANSFORM(QTMP->A2_CGC,IIF(QTMP->A2_TIPO=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))")
aAdd(aCabs  ,FwX3Titulo("A2_CGC"))

aAdd(aCampos,"QTMP->A2_PRICOM")
aAdd(aCabs  ,FwX3Titulo("A2_PRICOM"))

aAdd(aCampos,"QTMP->A2_ULTCOM")
aAdd(aCabs  ,FwX3Titulo("A2_ULTCOM"))

aAdd(aCampos,"IIF(!EMPTY(QTMP->A2_USERLGI),U_BUSCINCALT('SA2',QTMP->nREG,'A2_USERLGI',2),QTMP->A2_PRICOM)")
aAdd(aCabs  ,"Data Cadastro")

u_WaitLog(cPerg, {|| PBKCOMR15() },"Processando dados...")

aAdd(aPlans,{"QTMP",TRIM(cPerg),"",cTitulo,aCampos,aCabs,/* aImpr */, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })

U_PlanXlsx(aPlans,cTitulo,cPerg,.T.)

QTMP->(dbCloseArea())

Return



Static Function PBKCOMR15
Local cQuery := ""

cQuery := "WITH FORNEC AS (" +CRLF
cQuery += "SELECT A2_COD," + CRLF
cQuery += "       A2_LOJA," + CRLF
cQuery += "       A2_NOME," + CRLF
cQuery += "       A2_TIPO," + CRLF
cQuery += "       A2_NREDUZ," + CRLF
cQuery += "       A2_CGC," + CRLF
cQuery += "       A2_PRICOM," + CRLF
cQuery += "       A2_ULTCOM," + CRLF
cQuery += "       A2_USERLGI," + CRLF
cQuery += "       SA2.R_E_C_N_O_ AS nREG,  " + CRLF
cQuery += "       CASE WHEN F1_XXAVALI LIKE '%S%' THEN 'S' ELSE 'N' END AS AVALIADO " + CRLF
cQuery += "FROM SA2010 SA2" + CRLF
cQuery += "LEFT JOIN SF1010 SF1 ON " + CRLF
cQuery += "       F1_FORNECE = A2_COD AND " + CRLF
cQuery += "       A2_LOJA = F1_LOJA AND " + CRLF
cQuery += "       SA2.D_E_L_E_T_ = '' " + CRLF
cQuery += "WHERE SA2.D_E_L_E_T_ = '' AND" + CRLF
cQuery += "      A2_MSBLQL <> '1'" + CRLF
//cQuery += "GROUP BY A2_COD,A2_LOJA,A2_NOME,A2_TIPO,A2_NREDUZ,A2_CGC,A2_PRICOM,A2_ULTCOM,A2_USERLGI,SA2.R_E_C_N_O_,F1_XXAVALI " + CRLF
cQuery += ")" + CRLF
cQuery += "SELECT A2_COD," + CRLF
cQuery += "       A2_LOJA," + CRLF
cQuery += "	      A2_NOME," + CRLF
cQuery += "	      A2_TIPO," + CRLF
cQuery += "	      A2_NREDUZ," + CRLF
cQuery += "	      A2_CGC," + CRLF
cQuery += "	      A2_PRICOM," + CRLF
cQuery += "	      A2_ULTCOM," + CRLF
cQuery += "	      A2_USERLGI," + CRLF
cQuery += "	      nREG," + CRLF
cQuery += "	      MAX(AVALIADO) AVALIADO" + CRLF
cQuery += "FROM FORNEC" + CRLF
cQuery += "GROUP BY A2_COD,A2_LOJA,A2_NOME,A2_TIPO,A2_NREDUZ,A2_CGC,A2_PRICOM,A2_ULTCOM,A2_USERLGI,nREG" + CRLF
cQuery += "ORDER BY A2_COD,A2_LOJA" + CRLF

u_LogMemo(cPerg+".SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","A2_PRICOM","D",8,0)
TCSETFIELD("QTMP","A2_ULTCOM","D",8,0)
Return

Static Function ValidPerg(cPerg)
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Data de Compra de:"  ,"Data da Compra de:"  ,"Data da Compra de:"   ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Data de Compra até:" ,"Data de Compra até:" ,"Data de Entrada até:" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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
