/*/{Protheus.doc} BKFINR12
BK - 
@Return
@author Adilson do Prado / Marcos Bispo Abrahão
@since 
@version P12
/*/
User Function Nada()

Local oTmpTb
Local aDbf := {}
Local nStart := Time()

oTmpTb := FWTemporaryTable():New( "TRB")
oTmpTb:SetFields( aDbf )
oTmpTb:AddIndex("indice1", {"XX_CHAVE"} )
oTmpTb:Create()


oTmpTb:Delete()


FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "JSON successfully parsed to Object", 0, (nStart - Seconds()), {}) // nStart é declarada no inicio da função

Return NIL
