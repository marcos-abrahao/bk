#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT440GR
BK - Ponto de Entrada - gravação da liberação do pedido de venda 
@Return
@author  Marcos Bispo Abrahão
@since 12/12/22
@version P12
/*/

User Function MT440GR()

Local aArea := GetArea()
Local nOk   := PARAMIXB[1]
Local lRet  := .T.

If nOK == 1

    // Aqui: posocionar no SZE e ver se o email já foi enviado, senão, envia e grava que foi    
    SC5Email()
    lRet := .F. // Para teste

Endif

RestArea(aArea)

Return (lRet)



User Function SC5Email()
Local cEmail    := ""
Local cEmailCC  := "microsiga@bkconsultoria.com.br;" 
Local aCabs   	:= {}
Local aEmail 	:= {}
Local aAnexos   := {}
Local cMsg		:= ""
Local cAssunto  := ""
Local cContrato := ""
Local nTotal    := 0
Local aAreaSC6  := GetArea("SC6")  

aAnexos   := DocsZE(cEmpAnt,PAD(SC5->C5_MDCONTR,15)+SUBSTR(SC5->C5_XXCOMPM,4,4)+SUBSTR(SC5->C5_XXCOMPM,1,2))
cEmail    := u_EmailFat(__cUserID)
cAssunto  := "Pedido de venda nº.:"+SC5->C5_NUM+ " - "+ALLTRIM(SA1->A1_NOME)+" liberado em "+DTOC(DATE())+"-"+TIME()+" - "+FWEmpName(cEmpAnt)
cContrato := iIf(Empty(SC5->C5_MDCONTR),SC5->C5_ESPECI1,SC5->C5_MDCONTR)

cEmailCC += UsrRetMail(__cUserId)+';'

SC6->(DbSeek(xFilial('SC6') + SC5->C5_NUM))
While !SC6->(EoF()) .And. SC6->C6_NUM == SC5->C5_NUM
   nTotal += SC6->C6_VALOR
   SC6->(DbSkip())
EndDo

aCabs   := {"Pedido nº.:" + TRIM(SC5->C5_NUM)}
aEmail 	:= {}
AADD(aEmail,{"Cliente    :"+SA1->A1_COD+"-"+SA1->A1_LOJA+" - "+SA1->A1_NOME})
AADD(aEmail,{"Contrato   :"+cContrato})
AADD(aEmail,{"Competencia:"+SC5->C5_XXCOMPM})
AADD(aEmail,{"Valor      :"+ALLTRIM(TRANSFORM(nValor,"@E 99,999,999,999.99"))})

cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,"MT440GR")
U_BkSnMail("MT440GR",cAssunto,cEmail,cEmailCC,cMsg,)
BkSnMail(cPrw, cAssunto, cPara, cCc, cCorpo, aAnexos, lUsaTLS)
SC6->(RestArea(aAreaSC6))

Return Nil



Static Function DocsZE(empresa,cChave)
Local oStatement := nil
Local cQuery     := ""
Local cAliasSQL  := ""
Local nSQLParam  := 0
Local cTabAC9	 := "AC9"+empresa+"0" 
Local cTabACB	 := "ACB"+empresa+"0"
Local aFiles	 := {}

Local cFile      := ""
Local cDir       := "/dirdoc/co"+cEmpAnt+"/shared/"


cQuery := "SELECT ACB.ACB_OBJETO " + CRLF
cQuery += " FROM " + cTabAC9 + " AC9 " + CRLF // Entidade x objeto.
cQuery += "LEFT JOIN " + cTabACB + " ACB ON ACB.D_E_L_E_T_ = ' ' " + CRLF // Objeto.
cQuery += " AND ACB.ACB_FILIAL = AC9.AC9_FILIAL " + CRLF
cQuery += " AND ACB.ACB_CODOBJ = AC9.AC9_CODOBJ " + CRLF
cQuery += "WHERE AC9.D_E_L_E_T_ = '' " + CRLF
cQuery += " AND AC9.AC9_FILIAL = ? " + CRLF
cQuery += " AND AC9.AC9_ENTIDA = ? " + CRLF
cQuery += " AND AC9.AC9_CODENT = ? " + CRLF

//cQuery += "ORDER BY AC9.AC9_FILIAL, AC9.AC9_ENTIDA, AC9.AC9_CODENT, AC9.AC9_CODOBJ "

// Trata SQL para proteger de SQL injection.
oStatement := FWPreparedStatement():New()
oStatement:SetQuery(cQuery)

nSQLParam++
oStatement:SetString(nSQLParam, xFilial("AC9"))  // Filial

nSQLParam++
oStatement:SetString(nSQLParam, "SZE")  // Entidade.

nSQLParam++
oStatement:SetString(nSQLParam, cChave) // Chave.

cQuery := oStatement:GetFixQuery()
oStatement:Destroy()
oStatement := nil

cAliasSQL := MPSysOpenQuery(cQuery)

Do While (cAliasSQL)->(!eof())
	cFile  := cDir+Decode64(AllTrim((cAliasSQL)->ACB_OBJETO))
	aAdd(aFiles,cFile)
	(cAliasSQL)->(dbSkip())
EndDo
(cAliasSQL)->(dbCloseArea())

Return (aFiles)
