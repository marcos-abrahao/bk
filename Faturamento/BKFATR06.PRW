#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKFATR06
BK - Relação de Clientes (primeira e ultima compra)
@Return
@author Marcos Bispo Abrahão
@since 09/09/21
@version P12.1.25
/*/

User Function BKFATR06()
Local aPlans    := {}

Local aTitulos1,aCampos1,aCabs1

Private cTitulo      := "Relação de Clientes (primeira e ultima compra)"
Private cPerg        := "BKFATR06"

FWMsgRun(, {|oSay| PrcQuery1() }, "", "Consultando o banco de dados...")	

aCabs1   := {}
aCampos1 := {}
aTitulos1:= {}


AADD(aTitulos1,"Clientes")

AADD(aCampos1,"QSA1->A1_COD")
AADD(aCabs1  ,"Cliente")

AADD(aCampos1,"QSA1->A1_LOJA")
AADD(aCabs1  ,"Loja")

AADD(aCampos1,"TRANSFORM(QSA1->A1_CGC,IIF(QSA1->A1_PESSOA=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))")
AADD(aCabs1  ,"CNPJ/CPF")

AADD(aCampos1,"QSA1->A1_NOME")
AADD(aCabs1  ,"Descrição")

AADD(aCampos1,"QSA1->A1_PRICOM")
AADD(aCabs1  ,"1a Compra")

AADD(aCampos1,"QSA1->A1_ULTCOM")
AADD(aCabs1  ,"Ult. Compra")

AADD(aPlans,{"QSA1",cPerg,"",aTitulos1,aCampos1,aCabs1,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })

U_GeraXlsx(aPlans,cTitulo,cPerg,.T.)

Return


Static Function PrcQuery1
Local cQuery

cQuery := "SELECT A1_COD,A1_LOJA,A1_CGC,A1_NOME,A1_PESSOA,A1_PRICOM,A1_ULTCOM" + CRLF
cQuery += " FROM "+RETSQLNAME("SA1")+ " SA1 " + CRLF
cQuery += " WHERE A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_='' AND A1_PRICOM <> ''"+ CRLF
cQuery += "ORDER BY A1_NOME,A1_COD,A1_LOJA" + CRLF

u_LogMemo("BKFATR06.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QSA1"

TCSETFIELD("QSA1","A1_PRICOM","D",8,0)
TCSETFIELD("QSA1","A1_ULTCOM","D",8,0)

Return Nil

