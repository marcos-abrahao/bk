#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKCOMR13
BK - Relação de Fornecedores e produtos
@Return
@author Marcos Bispo Abrahão
@since 18/08/20
@version P12.1.25
/*/

User Function BKCOMR13()
Local aPlans    := {}

Local aTitulos1,aCampos1,aCabs1
Local aTitulos2,aCampos2,aCabs2

Private cTitulo      := "Relação de Fornecedores e produtos"
Private cPerg        := "BKCOMR13"

ProcRegua(1000)
Processa( {|| PrcQuery1() })

aCabs1   := {}
aCampos1 := {}
aTitulos1:= {}


AADD(aTitulos1,"Fornecedores")

AADD(aCampos1,"QSA2->A2_COD")
AADD(aCabs1  ,"Contrato")

AADD(aCampos1,"QSA2->A2_LOJA")
AADD(aCabs1  ,"Loja")

AADD(aCampos1,"QSA2->A2_NOME")
AADD(aCabs1  ,"Descrição")

AADD(aCampos1,"QSA2->A2_PRICOM")
AADD(aCabs1  ,"1a Compra")

AADD(aCampos1,"QSA2->A2_ULTCOM")
AADD(aCabs1  ,"Ult. Compra")

AADD(aCampos1,"QSA2->B1_XXSGRP")
AADD(aCabs1  ,"S.Grupo")

AADD(aCampos1,"QSA2->ZI_DESC")
AADD(aCabs1  ,"Desc.Sub.Grupo")

//AADD(aCampos,"Capital(QTMP->(FWLeUserlg('QTMP_USERLGI',1)))")


ProcRegua(1000)
Processa( {|| PrcQuery2() })

aCabs2   := {}
aCampos2 := {}
aTitulos2:= {}

AADD(aTitulos2,"Produtos")

AADD(aCampos2,"QSB1->B1_COD")
AADD(aCabs2  ,"Produto")

AADD(aCampos2,"QSB1->B1_DESC")
AADD(aCabs2  ,"Descrição")

AADD(aCampos2,"QSB1->B1_GRUPO")
AADD(aCabs2  ,"Grupo")

AADD(aCampos2,"QSB1->BM_DESC")
AADD(aCabs2  ,"Desc.Grupo")

AADD(aCampos2,"QSB1->B1_XXSGRP")
AADD(aCabs2  ,"S.Grupo")

AADD(aCampos2,"QSB1->ZI_DESC")
AADD(aCabs2  ,"Desc.Sub.Grupo")

AADD(aCampos2,"Capital(QSB1->(FWLeUserlg('XX_USERLGI',1)))")
AADD(aCabs2  ,"Cadastrado por")

AADD(aCampos2,"QSB1->(FWLeUserlg('XX_USERLGI',2))")
AADD(aCabs2  ,"Data Cad.")

AADD(aCampos2,"Capital(QSB1->(FWLeUserlg('XX_USERLGA',1)))")
AADD(aCabs2  ,"Alterado por")

AADD(aCampos2,"QSB1->(FWLeUserlg('XX_USERLGA',2))")
AADD(aCabs2  ,"Data Alt.")

AADD(aPlans,{"QSA2",cPerg+"F","",aTitulos1,aCampos1,aCabs1,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
AADD(aPlans,{"QSB1",cPerg+"P","",aTitulos2,aCampos2,aCabs2,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })

U_GeraXlsx(aPlans,cTitulo,cPerg,.T.)
 

Return


Static Function PrcQuery1
Local cQuery

IncProc("Consultando fornecedores...")

cQuery := "SELECT DISTINCT A2_COD,A2_LOJA,A2_NOME,A2_PRICOM,A2_ULTCOM,B1_XXSGRP,ZI_DESC" + CRLF
//cQuery := "SELECT TOP 100 A2_COD,A2_LOJA,A2_NOME,A2_PRICOM,A2_ULTCOM,B1_XXSGRP,ZI_DESC" + CRLF
cQuery += " FROM "+RETSQLNAME("SA2")+ " SA2 " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SA5")+ " SA5 ON A2_COD = A5_FORNECE AND A2_LOJA = A5_LOJA "+ CRLF
cQuery += "      AND  A5_FILIAL = '"+xFilial("SA5")+"' AND  SA5.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+ " SB1 ON B1_COD = A5_PRODUTO "+ CRLF
cQuery += "      AND  B1_FILIAL = '"+xFilial("SB1")+"' AND  SB1.D_E_L_E_T_ = ' '"+ CRLF
//cQuery += " LEFT JOIN "+RETSQLNAME("SBM")+" SBM ON SBM.BM_FILIAL='"+xFilial("SBM")+"' AND SB1.B1_GRUPO=SBM.BM_GRUPO AND SBM.D_E_L_E_T_=''"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SZI")+" SZI ON SZI.ZI_FILIAL='"+xFilial("SZI")+"' AND SB1.B1_XXSGRP = SZI.ZI_COD AND SZI.D_E_L_E_T_=''"+ CRLF
cQuery += " WHERE A2_FILIAL = '"+xFilial("SA2")+"' AND SA2.D_E_L_E_T_='' "+ CRLF
cQuery += "ORDER BY A2_NOME,A2_COD,A2_LOJA,B1_XXSGRP" + CRLF

u_LogMemo("BKCOMR13-SA2.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QSA2"
TCSETFIELD("QSA2","A2_PRICOM","D",8,0)
TCSETFIELD("QSA2","A2_ULTCOM","D",8,0)

Return Nil






Static Function PrcQuery2
Local cQuery

IncProc("Consultando produtos...")

cQuery := "SELECT B1_COD,B1_DESC,B1_GRUPO,BM_DESC,B1_XXSGRP,ZI_DESC,B1_USERLGI AS XX_USERLGI,B1_USERLGA AS XX_USERLGA" + CRLF
//cQuery := "SELECT TOP 100 B1_COD,B1_DESC,B1_GRUPO,BM_DESC,B1_XXSGRP,ZI_DESC,B1_USERLGI AS XX_USERLGI,B1_USERLGA AS XX_USERLGA" + CRLF
cQuery += " FROM "+RETSQLNAME("SB1")+ " SB1 " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SBM")+" SBM ON SBM.BM_FILIAL='"+xFilial("SBM")+"' AND SB1.B1_GRUPO=SBM.BM_GRUPO AND SBM.D_E_L_E_T_=''"+ CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SZI")+" SZI ON SZI.ZI_FILIAL='"+xFilial("SZI")+"' AND SB1.B1_XXSGRP = SZI.ZI_COD AND SZI.D_E_L_E_T_=''"+ CRLF
cQuery += " WHERE B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.D_E_L_E_T_='' "+ CRLF
cQuery += "ORDER BY B1_DESC" + CRLF

u_LogMemo("BKCOMR13-SB1.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QSB1"

Return Nil
