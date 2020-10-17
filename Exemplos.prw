#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

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
Local cQuery := ""

oTmpTb := FWTemporaryTable():New("TRB")
oTmpTb:SetFields( aDbf )
oTmpTb:AddIndex("indice1", {"XX_CHAVE"} )
oTmpTb:Create()


oTmpTb:Delete()

// Para gravar query quando admin
cQuery := "SELECT 1 "+ CRLF
u_LogMemo("BKGCTR0X.SQL",cQuery)

/// Alterar U_GeraCSV para U_GeraXlsx

//ProcRegua(QTMP->(LASTREC()))
//Processa( {|| U_GeraCSV("QTMP",cPerg,aTitulos,aCampos,aCabs)})
AADD(aPlans,{"QTMP",cPerg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
U_GeraXlsx(aPlans,Titulo,cPerg,.T.)

///


FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "JSON successfully parsed to Object", 0, (nStart - Seconds()), {}) // nStart é declarada no inicio da função

Return NIL


// Para ver se  a rotina foi chamada via schedule:

User Function xpto(aParam) 
Local lAuto := IsBlind()

//Se for por Schedule, abre o ambiente 
If lAuto 
    RpcSetType(3) 
	RpcSetEnv(aParam[1], aParam[2]) 
EndIf

//... seu código

If lAuto 
	RpcClearEnv() 
	aParam := ASize(aParam, 0) 
	aParam := Nil 
EndIf

Return 


