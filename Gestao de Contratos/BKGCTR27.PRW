#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR27
BK - Relação de Planilhas e Cronogramas de Contratos
@Return
@author Marcos Bispo Abrahão
@since 14/01/22
@version P12.1.33
/*/

User Function BKGCTR27()
Local aPlans    := {}

Local aTitulos1 := {}
Local aCampos1  := {}
Local aCabs1    := {}

Local aTitulos2 := {}
Local aCampos2  := {}
Local aCabs2    := {}

Private cTitulo := "Planilhas de Contratos"
Private cPerg   := "BKGCTR27"

u_MsgLog(cPerg)

FWMsgRun(, {|oSay| PrcQuery1() }, "", "Consultando planilhas...")	
FWMsgRun(, {|oSay| PrcQuery2() }, "", "Consultando cronogramas...")	


AADD(aTitulos1,"Planilhas do Contrato "+ALLTRIM(CN9->CN9_NUMERO)+": "+Posicione("CTT",1,xFilial("CTT")+CN9->CN9_NUMERO,"CTT_DESC01"))
AADD(aTitulos2,"Cronogramas do Contrato "+ALLTRIM(CN9->CN9_NUMERO)+": "+Posicione("CTT",1,xFilial("CTT")+CN9->CN9_NUMERO,"CTT_DESC01"))

AADD(aCampos1,"QCNB->CNB_CONTRA")
AADD(aCabs1  ,"Contrato")

AADD(aCampos1,"QCNB->CNB_REVISA")
AADD(aCabs1  ,"Revisão")

AADD(aCampos1,"QCNB->CNA_NUMERO")
AADD(aCabs1  ,"Planilha")

AADD(aCampos1,"QCNB->CNA_XXMOT")
AADD(aCabs1  ,"Motivo")

AADD(aCampos1,"QCNB->CNA_CLIENT")
AADD(aCabs1  ,"Cliente")

AADD(aCampos1,"QCNB->CNA_LOJACL")
AADD(aCabs1  ,"Loja")

AADD(aCampos1,"QCNB->A1_NOME")
AADD(aCabs1  ,"Nome")

AADD(aCampos1,"TRANSFORM(QCNB->A1_CGC,IIF(QCNB->A1_PESSOA=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))")
AADD(aCabs1  ,"CNPJ/CPF")

AADD(aCampos1,"QCNB->CNA_XXCMUN")
AADD(aCabs1  ,"Cod.Mun.")

AADD(aCampos1,"QCNB->CNA_XXUF")
AADD(aCabs1  ,"UF")

AADD(aCampos1,"QCNB->CNA_XXMUN")
AADD(aCabs1  ,"Município")

AADD(aCampos1,"QCNB->CNB_ITEM")
AADD(aCabs1  ,"Item")

AADD(aCampos1,"QCNB->CNB_PRODUT")
AADD(aCabs1  ,"Produto")

AADD(aCampos1,"QCNB->B1_DESC")
AADD(aCabs1  ,"Descrição")

AADD(aCampos1,"QCNB->B1_CODISS")
AADD(aCabs1  ,"Cod.ISS")

AADD(aCampos1,"QCNB->B1_ALIQISS")
AADD(aCabs1  ,"Aliq.ISS")

AADD(aCampos1,"QCNB->CNA_XXNAT")
AADD(aCabs1  ,"Natureza")

AADD(aCampos1,"QCNB->CNB_TS")
AADD(aCabs1  ,"TES")

AADD(aCampos1,"QCNB->CNA_XXTPNF")
AADD(aCabs1  ,"Tipo NF")

AADD(aCampos1,"QCNB->CNA_XXRETC")
AADD(aCabs1  ,"Ret. Contratual")

AADD(aCampos1,"QCNB->CNB_QUANT")
AADD(aCabs1  ,"Quantidade")

AADD(aCampos1,"QCNB->CNB_SLDMED")
AADD(aCabs1  ,"Saldo")

AADD(aCampos1,"QCNB->CNB_VLUNIT")
AADD(aCabs1  ,"V.Unit.")

AADD(aCampos1,"QCNB->CNB_VLUNIT * QCNB->CNB_SLDMED")
AADD(aCabs1  ,"R$ Saldo")

AADD(aCampos1,"QCNB->CNA_CRONOG")
AADD(aCabs1  ,"Cronograma")

// Cronogramas

AADD(aCampos2,"QCNF->CNF_NUMPLA")
AADD(aCabs2  ,"Planilha")

AADD(aCampos2,"QCNF->CNF_NUMERO")
AADD(aCabs2  ,"Cronograma")

AADD(aCampos2,"QCNF->CNF_PARCEL")
AADD(aCabs2  ,"Parcela")

AADD(aCampos2,"QCNF->CNF_COMPET")
AADD(aCabs2  ,"Competência")

AADD(aCampos2,"QCNF->CNF_VLPREV")
AADD(aCabs2  ,"Previsto")

AADD(aCampos2,"QCNF->CNF_VLREAL")
AADD(aCabs2  ,"Realizado")

AADD(aCampos2,"QCNF->CNF_SALDO")
AADD(aCabs2  ,"Saldo")


AADD(aPlans,{"QCNB","Planilhas","",aTitulos1,aCampos1,aCabs1,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
AADD(aPlans,{"QCNF","Cronogramas","",aTitulos2,aCampos2,aCabs2,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })

U_PlanXlsx(aPlans,cTitulo,cPerg,.T.)

Return


Static Function PrcQuery1
Local cQuery
Local cJCNACNB:= FWJoinFilial("CNA", "CNB")
Local cJCNBSB1:= FWJoinFilial("CNB", "SB1")
//Local cJCNASA1:= FWJoinFilial("CNA", "SA1")

cQuery := "SELECT CNB_CONTRA,CNB_REVISA,CNB_NUMERO,CNB_ITEM,CNB_PRODUT,CNB_TS,CNB_QUANT,CNB_SLDMED,CNB_VLUNIT,CNB_VLTOT" + CRLF
cQuery += "       ,CNA_XXMOT,CNA_NUMERO,CNA_CLIENT,CNA_LOJACL,CNA_XXCMUN,CNA_XXUF,CNA_XXMUN,CNA_XXTPNF,CNA_XXRETC,CNA_XXNAT,CNA_CRONOG"+ CRLF
cQuery += "       ,B1_DESC,B1_CODISS,B1_ALIQISS,B1_TS"+ CRLF
cQuery += "       ,A1_NOME,A1_CGC,A1_PESSOA"+ CRLF

cQuery += " FROM "+RETSQLNAME("CNB")+ " CNB " + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA " + CRLF
cQuery += "      ON CNB_NUMERO = CNA_NUMERO AND CNB_CONTRA = CNA_CONTRA AND CNB_REVISA = CNA_REVISA " + CRLF
cQuery += " 	 AND "+cJCNACNB+" AND CNA.D_E_L_E_T_=''" + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+ " SB1 " + CRLF
cQuery += "      ON CNB_PRODUT = B1_COD" + CRLF
cQuery += " 	 AND "+cJCNBSB1+" AND SB1.D_E_L_E_T_=''" + CRLF

cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 " + CRLF
cQuery += "      ON CNA_CLIENT = A1_COD AND CNA_LOJACL = A1_LOJA" + CRLF
cQuery += " 	 AND SA1.D_E_L_E_T_=''" + CRLF

cQuery += " WHERE CNB.D_E_L_E_T_=''" + CRLF
cQuery += "      AND CNB_CONTRA = '"+ALLTRIM(CN9->CN9_NUMERO)+"'" + CRLF
cQuery += "      AND CNB_REVISA = '"+CN9->CN9_REVISA+"'" + CRLF

cQuery += "ORDER BY CNB_CONTRA,CNB_REVISA,CNB_NUMERO,CNB_ITEM" + CRLF

u_LogMemo("BKGCTR27-1.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QCNB"

//TCSETFIELD("QCNB","A1_PRICOM","D",8,0)
//TCSETFIELD("QCNB","A1_ULTCOM","D",8,0)

Return Nil



Static Function PrcQuery2
Local cQuery

cQuery := "SELECT CNF_NUMPLA,CNF_NUMERO,CNF_PARCEL,CNF_COMPET,CNF_VLPREV,CNF_VLREAL,CNF_SALDO" + CRLF

cQuery += " FROM "+RETSQLNAME("CNF")+ " CNF " + CRLF

cQuery += " WHERE CNF.D_E_L_E_T_=''" + CRLF
cQuery += "      AND CNF_CONTRA = '"+ALLTRIM(CN9->CN9_NUMERO)+"'" + CRLF
cQuery += "      AND CNF_REVISA = '"+CN9->CN9_REVISA+"'" + CRLF

cQuery += "ORDER BY CNF_NUMPLA,CNF_PARCEL" + CRLF

u_LogMemo("BKGCTR27-2.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QCNF"

Return Nil



