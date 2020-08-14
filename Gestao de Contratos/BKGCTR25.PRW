#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR25
BK - Objetos dos Contratos
@Return
@author Marcos Bispo Abrahão
@since 13/08/20
@version P12.1.25
/*/

User Function BKGCTR25()
Local aTitulos,aCampos,aCabs,aPlans

Private cTitulo      := "Relação de Contratos"
Private cPerg        := "BKGCTR25"
Private cCompet      := STRZERO(Month(dDataBase),2)+"/"+STRZERO(YEAR(dDataBase),4)

ProcRegua(1)
Processa( {|| ProcQuery() })

aCabs   := {}
aCampos := {}
aTitulos:= {}
aPlans  := {}
   
AADD(aTitulos,cTitulo)


AADD(aCampos,"QCN9->CN9_NUMERO")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QCN9->CN9_REVISA")
AADD(aCabs  ,"Revisão")

AADD(aCampos,"QCN9->CN9_XXDESC")
AADD(aCabs  ,"Descrição")

AADD(aCampos,"IIF(QCN9->CN9_SITUAC $ '02/03/04/05','Ativo','Inativo')")
AADD(aCabs  ,"Status")

AADD(aCampos,"QCN9->CN9_CLIENT+'-'+QCN9->CN9_LOJACL")
AADD(aCabs  ,"Cliente")

AADD(aCampos,"QCN9->A1_NOME")
AADD(aCabs  ,"Nome")

AADD(aCampos,"TRANSFORM(QCN9->A1_CGC,'@R 99.999.999/9999-99' )")
AADD(aCabs  ,"CNPJ")

AADD(aCampos,"TRIM(QCN9->A1_END)+'-'+QCN9->A1_BAIRRO")
AADD(aCabs  ,"Endereço")

AADD(aCampos,"TRIM(QCN9->A1_MUN)+'-'+QCN9->A1_EST")
AADD(aCabs  ,"Cidade")

AADD(aCampos,"TRANSFORM(QCN9->A1_CEP,'@R 99999-999')")
AADD(aCabs  ,"CEP")

AADD(aCampos,"IIF(!EMPTY(QCN9->A1_DDD),TRIM(QCN9->A1_DDD)+'-','')+QCN9->A1_TEL")
AADD(aCabs  ,"Tel.")

AADD(aCampos,"QCN9->A1_EMAIL")
AADD(aCabs  ,"E-Mail")

AADD(aCampos,"QCN9->CN9_DTINIC")
AADD(aCabs  ,"Dt. Inicio")

AADD(aCampos,"u_VigContrat(QCN9->CN9_NUMERO+QCN9->CN9_REVISA,QCN9->CN9_XXDVIG)")
AADD(aCabs  ,"Vigencia")

AADD(aCampos,"QCN9->CN9_XXNRBK")
AADD(aCabs  ,"Gestor "+ALLTRIM(SM0->M0_NOME))

AADD(aCampos,"QCN9->CN9_XXNGC")
AADD(aCabs  ,"Nome Gestor")

AADD(aCampos,"QCN9->CN9_XXEGC")
AADD(aCabs  ,"E-mail Gestor")

AADD(aCampos,"QCN9->CN9_XXTELS")
AADD(aCabs  ,"Tel Gestor")

AADD(aPlans,{"QCN9",cPerg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
U_GeraXlsx(aPlans,cTitulo,cPerg,.T.)
 

Return


Static Function ProcQuery
Local cQuery

IncProc("Consultando o banco de dados...")

cQuery := "SELECT CN9_SITUAC,CN9_NUMERO,CN9_REVISA,CN9_XXDESC," + CRLF
cQuery += "  CN9_CLIENT,CN9_LOJACL,A1_NOME,A1_CGC," + CRLF
cQuery += "  A1_END,A1_BAIRRO,A1_MUN,A1_EST,A1_CEP," + CRLF
cQuery += "  A1_DDD,A1_TEL,A1_EMAIL," + CRLF
cQuery += "  CN9_DTINIC,CN9_XXDVIG,CN9_XXNRBK," + CRLF
cQuery += "  CN9_XXNGC,CN9_XXEGC,CN9_XXTELS" + CRLF
cQuery += " FROM "+RETSQLNAME("CN9")+ " CN9 " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON A1_COD = CN9_CLIENT AND A1_LOJA = CN9_LOJACL"+ CRLF
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " WHERE CN9_FILIAL = '"+xFilial("CN9")+"' AND CN9.D_E_L_E_T_='' AND CN9_SITUAC NOT IN ('01','09','10')" + CRLF
cQuery += "ORDER BY CN9_NOMCLI,CN9_NUMERO" + CRLF

u_LogMemo("BKGCTR25.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QCN9"
TCSETFIELD("QCN9","CN9_DTINIC","D",8,0)
TCSETFIELD("QCN9","CN9_XXDVIG","D",8,0)

Return Nil

