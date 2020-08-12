#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR16()
BK - Relação de Contratos Vigentes no mes

@author Marcos Bispo Abrahão
@since 28/04/15 Rev 26/05/20
@version P12
@return Nil
/*/

User Function BKGCTR16()

Local aCampos       := {}
Local aCabs         := {}
Local aPlans        := {}

Private cPerg       := "BKGCTR16"
Private cTitulo     := "Relação de Contratos Vigentes no mês "
Private cMes        := "04"
Private cAno        := "2015"
Private cCompet     := "04/2015"

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

cMes     := mv_par01
cAno  	 := mv_par02
cCompet  := mv_par01+"/"+mv_par02
cTitulo  += cCompet

// Campos para exportar

AADD(aCampos,"QTMP->CNF_CONTRA")
AADD(aCabs  ,"Centro de Custo")

AADD(aCampos,"QTMP->CNF_REVISA")
AADD(aCabs  ,"Revisão")

AADD(aCampos,"QTMP->A1_NOME")
AADD(aCabs  ,"Cliente")

AADD(aCampos,"QTMP->CTT_DESC01")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QTMP->CN9_SITUAC")
AADD(aCabs  ,"Situação")

AADD(aCampos,"QTMP->CN9_XXNRBK")
AADD(aCabs  ,"Nome Gestor "+ALLTRIM(SM0->M0_NOME))

AADD(aCampos,"QTMP->CN9_XXNGC")
AADD(aCabs  ,"Gestor do Cliente")

AADD(aCampos,"QTMP->CN9_XXEGC")
AADD(aCabs  ,"Email do Gestor do Cliente")

AADD(aCampos,"QTMP->CN9_XXTELS")
AADD(aCabs  ,"Telefones do Cliente")

AADD(aCampos,"SUBSTR(QTMP->MAXCOMPET,5,2)+'/'+SUBSTR(QTMP->MAXCOMPET,1,4)")
AADD(aCabs  ,"Vigência")

ProcRegua(1)
Processa( {|| ProcQuery() })

AADD(aPlans,{"QTMP",cPerg,"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
U_GeraXlsx(aPlans,cTitulo,cPerg,.F.)

Return


Static Function ProcQuery
Local cQuery := ""

cQuery := " SELECT DISTINCT CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CN9_XXNRBK,CN9_XXNGC,CN9_XXEGC,CN9_XXTELS,"+ CRLF
cQuery += "  (SELECT TOP 1 MAX(SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2)) FROM "+RETSQLNAME("CNF")+" CNFX WHERE CNF.CNF_CONTRA = CNFX.CNF_CONTRA AND CNF.CNF_REVISA = CNFX.CNF_REVISA AND CNFX.D_E_L_E_T_ = ' ') AS MAXCOMPET "+ CRLF

cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"+ CRLF
cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9.CN9_NUMERO = CNF.CNF_CONTRA AND CN9.CN9_REVISA = CNF.CNF_REVISA AND  CN9.CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+ CRLF
cQuery += " AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ''"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA"+ CRLF
cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CND_PARCEL = CNF_PARCEL AND CNA_NUMERO = CND_NUMERO AND CND_REVISA = CNF_REVISA"+ CRLF
cQuery += "      AND  CND.D_E_L_E_T_ = ' '"+ CRLF

cQuery += " INNER JOIN "+RETSQLNAME("SA1")+" SA1 ON CND.CND_CLIENT = SA1.A1_COD" + CRLF
cQuery += " AND CND.CND_LOJACL = SA1.A1_LOJA  AND  SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"+ CRLF

cQuery += " WHERE CNF.D_E_L_E_T_='' AND CNF.CNF_COMPET='"+cCompet+"' AND CN9.CN9_SITUAC ='05'"+ CRLF
//cQuery += " GROUP BY CNF_CONTRA,CNF_REVISA,A1_NOME,CTT_DESC01,CN9_SITUAC,CN9_XXNRBK,CNF_COMPET,MAXCOMPET"
cQuery += " ORDER BY CNF_CONTRA"+ CRLF

u_LogMemo("BKGCTR16.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP" 

//TCSETFIELD("QCN9","CN9_DTINIC","D",8,0)

Return


Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)

AADD(aRegistros,{cPerg,"01","Mes:" ,"Mes:","Mes:","mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","","Branco para Todos Contratos Ativos"})
AADD(aRegistros,{cPerg,"02","Ano:" ,"Ano:","Ano:","mv_ch2","C",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","","Branco para Todos Contratos Ativos"})

For i:=1 to Len(aRegistros)
	If !dbSeek(PADR(cPerg,10)+aRegistros[i,2])
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
