#include "totvs.ch"
#include "protheus.ch"

/*/{Protheus.doc} BKVARS
BK - Funcoes com parâmetros embutidos no fonte

@Return
@author Marcos B. Abrahão
@since 03/05/22
@version P12
/*/


// Rateio especifico por produtos ex. alugueis lançados em um unico doc de entrada
// Rateio  Contrato  x  Produtos                       15/01/20 - Marcos
//aRet := {{"345000529",{"320200301","000000000000102"}}}
User Function DefCtrPrd()
Local aRet
aRet := {}
//		 {"302000508",{"000000000000102"}}}
Return aRet


// % Media de Impostos e Contribuicoes calculo Rentabilidade dos Contratos 
User Function MVXMIMPC()
Local cPar := "1900/01;8.15|2015/07;10.7000|2019/01;9.50"
If cEmpAnt == '02'
    cPar := "1900/01;16.98000"
ElseIf cEmpAnt == '12'
    cPar := "1900/01;8.15|2015/07;10.7000"
ElseIf cEmpAnt == '15'
    cPar := "1900/01;8.15|2015/07;10.8877"
EndIf
Return cPar

// Parametro Encargos calculo Rentabilidade dos Contratos
User Function MVXENCAP()
Local nVar := 37.13280
If cEmpAnt == '02'
    nVar := 8
EndIf
Return nVar

// Parametro Encargos calculo Rentabilidade dos Contratos
User Function MVXEIPT()
Local nVar := 20
If cEmpAnt == '02'
    nVar := 1
EndIf
Return nVar


// Parametro Incidências calculo Rentabilidade dos Contratos
User Function MVXINCID()
Local nVar := 29.700
If cEmpAnt == '01'
    nVar := 28.860
ElseIf cEmpAnt == '02'
    nVar := 20.700
EndIf
Return nVar


// Parametro Taxa Administrativa -  calculo Rentabilidade dos Contratos
User Function MVXTXADM()
Local nVar := 3.000
Return nVar


//
// Retorna as variaveis abaixo no formato "IN" para queryes, retirando o "|" do inicio e do fim da string
User Function FBkVars(cVar)
Return Formatin(SUBSTRING(cVar,2,LEN(cVar)-2),"|")
//

// Parametro Proventos calculo Rentabilidade dos Contratos
User Function MVXPROVE()
Local cVar := "|1|2|11|34|35|36|37|56|60|62|64|65|68|100|102|104|108|110|126|266|268|270|274|483|600|640|656|664|674|675|685|696|700|725|726|727|728|729|745|747|749|750|754|755|756|757|758|760|761|762|763|764|765|778|779|787|789|790|791|792|824|897|"
Return cVar

// Descontos calculo Rentabilidade dos Contratos 
User Function MVXDESCO()
Local cVar := "|112|114|120|122|177|181|187|636|650|680|683|691|780|783|784|"
Return cVar

// PROVENTO DE VT - Conforme verificado com Sr. Anderson esta verba é so pára funcionario que tem vt em dinheiro
User Function MVXVTPRO()
Local cVar := "|671|"
Return cVar

//Verba desconto de VT custos calculo Rentabilidade
User Function MVXVTVER()
Local cVar := "|290|667|"
Return cVar

// Verba desconto de VR/VA calculo Rentabilidade 
User Function MVXVRVAV()
Local cVar := "|613|614|662|681|682|702|873|874|895|896|"
Return cVar

// Verba desc. assist. medica calculo Rentabilidade 
User Function MVXASSMV()
Local cVar := "|605|689|733|734|742|770|771|773|794|796|832|856|"
Return cVar

// Cod. Verba desc. assist. medica calculo Rentabilide
User Function MVXASSMP()
Local cVar := "|605|689|709|711|712|719|733|734|742|743|770|771|773|794|796|810|832|833|854|856|857|"
Return cVar

// Verba desc. sind. odonto  calculo Rentabilidade 
User Function MVXSINOV()
Local cVar := "|510|607|665|679|724|739|825|900|"
Return cVar

// Cod Produto VT custos calculo Rentabilidade
User Function MVXVTPRD()
Local cVar := "|31201046|"
Return cVar

// COD Produto de VR/VA calculo Rentabilidade  
User Function MVXVRVAP()
Local cVar := "|31201045|31201047|"
Return cVar

// Codigo contrato e empresa Consorcio calculo Rentabilidade
User Function MVXCONS()
Local cVar := " "
Local aVar := {}
If cEmpAnt == '01'
    cVar := "163000240;060;000000001;000000001;1;50;000000000/"
    cVar += "193000288;080;000000002;000001010;4;50;000000001/"
    cVar += "194000289;080;000000003;000001010;4;50;000000000/"
    cVar += "195000290;080;000000004;000001010;4;50;000000000/"
    cVar += "196000291;080;000000005;000001010;4;50;000000000/"
    cVar += "197000292;090;000000001;000001010;3;50;000000004/"
    cVar += "198000293;090;000000002;000001010;3;50;000000000/"
    cVar += "199000294;090;000000003;000001010;3;50;000000000/"
    cVar += "211000316;100;000000001;000000001;1;60;000000000/"
    cVar += "215000318;110;000000001;000000001;1;90;000000000/"
    cVar += "193001288;080;000000002;000001010;4;50;000000001/"
    cVar += "194001289;080;000000003;000001010;4;50;000000000/"
    cVar += "195001290;080;000000004;000001010;4;50;000000000/"
    cVar += "196001291;080;000000005;000001010;4;50;000000000/"
    cVar += "197001292;090;000000001;000001010;3;50;000000004/"
    cVar += "198001293;090;000000002;000001010;3;50;000000000/"
    cVar += "199001294;090;000000003;000001010;3;50;000000000/"
    cVar += "305000554;150;000000001;000001010;1;50;000000000"
ElseIf cEmpAnt == '14'
    cVar := "302000508;140;000000001;000000002;1;0;302000508;010"
EndIf
aVar := StrTokArr(cVar,"/")
Return aVar


// Cod. Prod. para rateio no calculo de rentabilidade
User Function MVXCEXMP()
Local cVar := "41201015"
Return cVar


// Cod. Prod. desc. sind. odonto  calculo Rentabilidade
User Function MVXSINOP()
Local cVar := "|510|607|665|679|724|732|739|825|900|"
Return cVar


//Cod. Prod. para rateio no calculo de rentabilidade
User Function MVXCDPRP()
Local cPar := "|320200111|34202034|000000000000112|"
If cEmpAnt == '01'
    cPar := "|320200111|34202034|000000000000112|34202057|41205013|120300106|120300105|INS510|INS511|INS512|INS513|INS514|INS515|INS516|INS517|INS518|INS519|INS520|INS521|320300104|000000000000182|"
ElseIf cEmpAnt == '02'
    cPar := "|320200111|34202034|000000000000112|34202057|120300106|120300105|INS510|INS511|INS512|INS513|INS514|INS515|INS516|INS517|INS518|INS519|INS520|INS521|320300104|"
ElseIf cEmpAnt == '14'
    cPar := "|320200111|34202034|34202086|"
EndIf
Return cPar

// Cod. Grupo Prod para rateio no calculo de rentabilidade
User Function MVXCDPRG()
Local cVar := "|0008|0009|0010|"
Return cVar

// Verba sem incidencias no calculo de rentabilidade
User Function MVXNINCI()
Local cVar := "|875|910|"
Return cVar

// Cod. Prod. para rateio no calculo de rentabilidade
User Function MVXCMFGP()
Local cVar := "31201053"
Return cVar


// Codigo produto Diaria de campo / Hospedagem / Viagens
User Function MVXCDCH()
Local cVar := "34202003"
Return cVar


// Codigo produto Custo BK
User Function MVXCUSBK()
Local cVar := "29104004"
Return cVar


// Codigo de evento PLR paa a rentabilidade
User Function MVXPLR()
Local cVar := "|430|"
Return cVar

// Codigos de contratos de FURNAS
User Function MVXFURNAS()
Local aVar := {"105000381","105000391"}
Return aVar


// %Encargos Folha CLT calculo rentabilidade Contrato de FURNAS
User Function MVXENCFU()
Local nVar := 35.8764
Return nVar

