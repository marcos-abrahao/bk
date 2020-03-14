#Include "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FA470CTA บ Autor ณ Adilson do Prado         Data ณ03/03/15 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ponto Entrada Leitura de saldo inicial Concilia็ใo		  บฑฑ
ฑฑบ            Automแtica Banco, Agencia, Conta 	                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BK                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

/*----------------------------------------------------------------------------------------------*
 | P.E.:  FA470CTA                                                                              |
 | Desc:  Leitura do Saldo Inicial                                                              |
 | Link:  http://tdn.totvs.com/display/public/mp/FA470CTA+-+Leitura+de+saldo+inicial+--+12006   |
 *----------------------------------------------------------------------------------------------*/
 
User Function FA470CTA()
    Local aArea    := GetArea()
    Local aRetorno := ParamIXB
    //Local cBco := aRetorno[1]
    Local cAge := aRetorno[2]
    Local cCnt := aRetorno[3]
     
    
    IF cAge == "3324" // Brasil
       aRetorno[2] := "33243"
    ELSEIF cAge == "3340" // Brasil
       aRetorno[2] := "33405"
    ENDIF
    
    IF cCnt == "001776762"  // Brasil
       aRetorno[3] := "1776762"
    ELSEIf cCnt == "130038841"  // Santander
       aRetorno[3] := "13-0038841"
    ElseIf cCnt == "56105"  // Itau
       aRetorno[3] := "56105-8"
    ElseIf cCnt == "03000000479"  // CAIXA FEDERAL
       aRetorno[3] := "0300000479"
    ElseIf cCnt == "03000001670"  // CAIXA FEDERAL
       aRetorno[3] := "1670"
    ElseIf cCnt == "03000001867"  // CAIXA FEDERAL
       aRetorno[3] := "01867"
    ElseIf cCnt == "03000002224"  // CAIXA FEDERAL
       aRetorno[3] := "0032224"
    ElseIf ALLTRIM(cCnt) == "20000002813203"  // bradesco
       aRetorno[3] := "2813203"
    EndIf
    
   RestArea(aArea)
Return aRetorno





