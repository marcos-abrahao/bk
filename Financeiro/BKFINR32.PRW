#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKFINR32
BK - RELATORIO DE FORNECEDORES ATIVOS E ULTIMA COMPRA
Solicitado pelo Diego Oliveira do Depto Financeiro a pedido da Sra Caroline 
@Return
@author Marcos Bispo Abrahão
@since 12/07/2022
@version P12.1.33
/*/

User Function BKFINR32

Local cTitulo        := "Fornecedores ativos"
Local aCabs          := {}
Local aCampos        := {}
Local aTitulos       := {}
Local aPlans         := {}

Private cPerg        := "BKFINR32"
Private dDtIni

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
Endif
u_LogPrw(cPerg)

dDtIni   := MV_PAR01


Processa( {|| ProcGer1(@cTitulo) })

aCabs   := {}
aCampos := {}
aTitulos:= {}

AADD(aTitulos,ctitulo)

AADD(aCampos,"QSA2->A2_COD")
AADD(aCabs  ,"Código")

AADD(aCampos,"QSA2->A2_LOJA")
AADD(aCabs  ,"Loja")

AADD(aCampos,"QSA2->A2_NOME")
AADD(aCabs  ,"Razão Social")

AADD(aCampos,"TRANSFORM(QSA2->A2_CGC,IIF(QSA2->A2_TIPO=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))")
AADD(aCabs  ,"CNPJ/CPF")

AADD(aCampos,"QSA2->A2_PRICOM")
AADD(aCabs  ,"Primeira Compra")

AADD(aCampos,"QSA2->A2_ULTCOM")
AADD(aCabs  ,"Última Compra")

AADD(aCampos,"Capital(QSA2->(FWLeUserlg('XX_USERLGI',1)))")
AADD(aCabs  ,"Cadastrado por")

AADD(aCampos,"QSA2->(FWLeUserlg('XX_USERLGI',2))")
AADD(aCabs  ,"Data Cad.")

AADD(aCampos,"Capital(QSA2->(FWLeUserlg('XX_USERLGA',1)))")
AADD(aCabs  ,"Alterado por")

AADD(aCampos,"QSA2->(FWLeUserlg('XX_USERLGA',2))")
AADD(aCabs  ,"Data Alt.")

AADD(aCampos,"QSA2->D1_SERIE")
AADD(aCabs  ,"Série Últ NF")

AADD(aCampos,"QSA2->D1_DOC")
AADD(aCabs  ,"Nº Últ NF")

AADD(aCampos,"DTOC(QSA2->D1_DTDIGIT)")
AADD(aCabs  ,"Data Últ NF")

AADD(aCampos,"QSA2->D1_CC")
AADD(aCabs  ,"Centro de Custos")

AADD(aCampos,"QSA2->CTT_DESC01")
AADD(aCabs  ,"Descrição C.Custo")

AADD(aCampos,"QSA2->B1_COD")
AADD(aCabs  ,"Produto")

AADD(aCampos,"QSA2->B1_DESC")
AADD(aCabs  ,"Descricao do Produto")

AADD(aCampos,"QSA2->B1_XXSGRP")
AADD(aCabs  ,"Sub Grupo")

AADD(aCampos,"QSA2->ZI_DESC")
AADD(aCabs  ,"Descricao Sub Grupo")

AADD(aCampos,"UsrRetName(QSA2->F1_XXUSER)")
AADD(aCabs  ,"Responsável")

AADD(aCampos,"UsrRetName(QSA2->F1_XXULIB)")
AADD(aCabs  ,"Liberado por")

AADD(aCampos,"QSA2->D1_XXHIST")
AADD(aCabs  ,"Historico")

AADD(aPlans,{"QSA2",cPerg,"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })

U_PlanXlsx(aPlans,cTitulo,cPerg,.T.)


Return


Static Function ProcGer1(cTitulo)
Local cQuery

If SELECT("QSA2") > 0 
	dbSelectArea("QSA2")
   	dbCloseArea()
EndIf

cTitulo := "Fornecedores Ativos e Última Compra desde "+DTOC(dDtIni)

cQuery := "SELECT "+CRLF
cQuery += " A2_COD," + CRLF
cQuery += " A2_LOJA," + CRLF
cQuery += " A2_NOME," + CRLF
cQuery += " A2_CGC," + CRLF
cQuery += " A2_TIPO," + CRLF
cQuery += " A2_PRICOM," + CRLF
cQuery += " A2_ULTCOM," + CRLF
cQuery += " A2_USERLGI AS XX_USERLGI," + CRLF
cQuery += " A2_USERLGA AS XX_USERLGA," + CRLF
cQuery += " D1_SERIE, " + CRLF
cQuery += " D1_DOC, " + CRLF
cQuery += " D1_DTDIGIT, " + CRLF
cQuery += " D1_CC, " + CRLF
cQuery += " CTT_DESC01, " + CRLF
cQuery += " B1_COD," + CRLF
cQuery += " B1_DESC," + CRLF
cQuery += " B1_XXSGRP," + CRLF
cQuery += " ZI_DESC," + CRLF
cQuery += " F1_XXUSER, " + CRLF
cQuery += " F1_XXUSERS, " + CRLF
cQuery += " F1_XXULIB, " + CRLF
cQuery += " CONVERT(VARCHAR(6000),CONVERT(Binary(6000),D1_XXHIST)) D1_XXHIST " + CRLF
cQuery += "FROM "+RETSQLNAME("SA2")+" SA2 "

// Pega a última compra do SD1
cQuery += " LEFT JOIN "+RETSQLNAME("SD1")+" SD1 ON SD1.D_E_L_E_T_=''"+ CRLF
cQuery += "   AND SD1.D1_FILIAL = '"+xFilial("SD1")+"' "+ CRLF
cQuery += "   AND A2_COD = SD1.D1_FORNECE"+ CRLF
cQuery += "   AND A2_LOJA = SD1.D1_LOJA"+ CRLF
cQuery += "   AND SD1.R_E_C_N_O_ = "+ CRLF
cQuery += "   	(SELECT TOP 1 R_E_C_N_O_ FROM SD1010 SD1T "+ CRLF
cQuery += "   	  WHERE SD1T.D_E_L_E_T_='' "+ CRLF
cQuery += "   	        AND SD1T.D1_FILIAL = '01' "+ CRLF
cQuery += "   	        AND A2_COD = SD1T.D1_FORNECE"+ CRLF
cQuery += "   		    AND A2_LOJA = SD1T.D1_LOJA"+ CRLF
cQuery += "		        AND SD1T.D1_DTDIGIT >= '"+DTOS(dDtIni)+"' "+ CRLF
cQuery += "		 ORDER BY D1_DTDIGIT DESC)"+ CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("SF1")+" SF1 ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND SF1.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_FILIAL = '"+xFilial("CTT")+"' AND D1_CC = CTT_CUSTO AND CTT.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D1_COD = B1_COD AND SB1.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SZI")+" SZI ON ZI_FILIAL = '"+xFilial("SZI")+"' AND ZI_COD = B1_XXSGRP AND SZI.D_E_L_E_T_ = ' ' "+CRLF
cQuery += "WHERE SA2.D_E_L_E_T_ = ' ' "+CRLF
IF !EMPTY(dDtIni)
	cQuery += "AND A2_ULTCOM >= '"+DTOS(dDtIni)+"' "+CRLF
ENDIF
cQuery += "ORDER BY A2_NOME "+CRLF

u_LogMemo("BKFINR32.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QSA2"

TCSETFIELD("QSA2","A2_PRICOM","D",8,0)
TCSETFIELD("QSA2","A2_ULTCOM","D",8,0)
TCSETFIELD("QSA2","D1_DTDIGIT","D",8,0)
TCSETFIELD("QSA2","D1_XXHIST","M",10,0)

Dbselectarea("QSA2")
QSA2->(Dbgotop())

Return nil



Static Function ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Data inicial:" ,"Data inicial:" ,"Data inicial:"  ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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


