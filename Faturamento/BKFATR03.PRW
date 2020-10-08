#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKFATR03
BK - Pedidos não Liberados ou não Faturadoe
@Return
@author Marcos Bispo Abrahão
@since 20/08/20
@version P12.1.25
/*/

User Function BKFATR03()
Local aTitulos,aCampos,aCabs,aPlans,aFormula

Private cTitulo      := "Relação de Pedidos não Liberados/Faturados"
Private cPerg        := "BKFATR03"

ProcRegua(1)
Processa( {|| ProcQuery() })

aCabs   := {}
aCampos := {}
aTitulos:= {}
aPlans  := {}
aFormula:= {}
   
AADD(aTitulos,cTitulo)

AADD(aCampos,"QSC5->C5_NUM")
AADD(aCabs  ,"Pedido")

AADD(aCampos,"QSC5->XX_LIBEROK")
AADD(aCabs  ,"Status do Pedido")

AADD(aCampos,"QSC5->C5_EMISSAO")
AADD(aCabs  ,"Revisão")

AADD(aCampos,"QSC5->C5_CLIENTE+'-'+QSC5->C5_LOJACLI")
AADD(aCabs  ,"Cliente")

AADD(aCampos,"QSC5->A1_NOME")
AADD(aCabs  ,"Nome")

AADD(aCampos,"TRANSFORM(QSC5->A1_CGC,'@R 99.999.999/9999-99' )")
AADD(aCabs  ,"CNPJ")

AADD(aCampos,"QSC5->C5_MDCONTR")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QSC5->C5_MDNUMED")
AADD(aCabs  ,"Medição")

AADD(aCampos,"QSC5->C5_MDPLANI")
AADD(aCabs  ,"Planilha")

AADD(aCampos,"QSC5->C5_ESPECI1")
AADD(aCabs  ,"Avulso")

AADD(aCampos,"QSC5->C5_XXRM")
AADD(aCabs  ,"RM")

AADD(aCampos,"QSC5->C5_XXCOMPM")
AADD(aCabs  ,"Competência")

AADD(aCampos,"Capital(QSC5->(FWLeUserlg('XX_USERLGI',1)))")
AADD(aCabs  ,"Usuário")

AADD(aCampos,"IIF(QSC5->C5_XXTPNF == 'B','Balcão',IIF(QSC5->C5_XXTPNF == 'F','Filial','Normal'))")
AADD(aCabs  ,"Tipo NF")

// Alterar estilo do não liberado
dbSelectArea("QSC5")
dbGoTop()
Do While !Eof()
    If QSC5->XX_LIBEROK=='Nao Liberado'
        AADD(aFormula,{QSC5->(RECNO()),"QSC5->XX_LIBEROK","","S1","",""})
    Else
        AADD(aFormula,{QSC5->(RECNO()),"QSC5->XX_LIBEROK","","S","",""})
    EndIf
    dbSkip()
EndDo

AADD(aPlans,{"QSC5",cPerg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, aFormula,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
U_GeraXlsx(aPlans,cTitulo,cPerg,.T.)
 

Return


Static Function ProcQuery
Local cQuery

IncProc("Consultando o banco de dados...")

cQuery := "SELECT C5_NUM,C5_EMISSAO,C5_CLIENTE,C5_LOJACLI,"+ CRLF
cQuery += "  (CASE WHEN C5_LIBEROK='S' THEN 'Nao faturado' ELSE 'Nao Liberado' END) AS XX_LIBEROK,"
cQuery += "  A1_NOME,A1_CGC," + CRLF
cQuery += "  C5_MDCONTR,C5_MDNUMED,C5_MDPLANI,C5_ESPECI1,C5_XXCOMPM,C5_XXRM," + CRLF
cQuery += "  C5_USERLGI AS XX_USERLGI,C5_XXTPNF" + CRLF
cQuery += " FROM "+RETSQLNAME("SC5")+ " SC5 " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI"+ CRLF
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND SC5.D_E_L_E_T_='' AND ( (C5_LIBEROK <> 'S' AND C5_NOTA = '') OR (C5_LIBEROK = 'S' AND C5_NOTA = '') )" + CRLF
cQuery += "ORDER BY C5_NUM" + CRLF

u_LogMemo("BKFATR03.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QSC5"
TCSETFIELD("QSC5","C5_EMISSAO","D",8,0)

Return Nil

