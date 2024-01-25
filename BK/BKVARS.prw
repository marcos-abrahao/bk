#include "totvs.ch"
#include "protheus.ch"

/*/{Protheus.doc} BKVARS
BK - Funcoes com parâmetros embutidos no fonte
@Return
@author Marcos B. Abrahão
@since 03/05/22
@version P12
/*/


// Retorna IP e Porta do server REST
User Function BkIpPort()
Local cIpPort := "10.139.0.30:8080"
If "TST" $ UPPER(GetEnvServer()) .OR. "TESTE" $ UPPER(GetEnvServer())
	cIpPort := "10.139.0.30:8081"
EndIf
//u_MsgLog(,GetEnvServer()+" - "+cIpPort,"I")
Return cIpPort


// Retorna endereço do REST BK
User Function BKRest()
Local cRest := "http://"+u_BkIpPort()+"/rest"
Return cRest


// Retorna endereço do Servidor BK
User Function BKIpServer()
Local cRest := "http://10.139.0.30"
Return cRest


// Contratos do Regime Cumulativo
User Function BKCCCum()
Return('290000471/300000482')


// Contratos que não devem emitir aviso de contrato vencido
User Function CtrVenc(cContrato)
lRet := .T.
If ALLTRIM(cContrato) $ "302000508" .and. cEmpAnt == "01"
	lRet := .F.
EndIf
Return lRet


// Centro de Custo padrão por empresa
User Function CCPadrao()
Local cCC := SPACE(9)

If cEmpAnt == '14'
	cCC := '302000508'
ElseIf cEmpAnt == '15'
	cCC := '305000554'
ElseIf cEmpAnt == '16'
	cCC := '386000609'
ElseIf cEmpAnt == '18'
	cCC := '303000623'
EndIf

Return cCC


// Acima deste limite, irá mostrar aviso ao gerar borderô BK - BKFINA14
User Function LimAvCLT()
Return 15000


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

// %Encargos Folha CLT calculo rentabilidade Contrato de FURNAS
User Function MVXENCFU()
Local nVar := 35.8764
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
/*  18/04/23 - inclusão de novos proventos 935/936 - solicitado por Bruno Bueno
935 - Salário substituição: será devido quando o funcionário substitui outro profissional com salário mais elevado que o seu, consiste no recebimento da diferença de salário pelo período em que o profissional exercer a mesma função que o funcionário afastado. O salário substituição será pago nas seguintes situações; cobertura de férias, licença médica, licença maternidade e licença paternidade.
936 - Salário treinamento: será devido quando o funcionário estiver em período probatório de promoção para um cargo com salário superior ao seu; consiste no recebimento da diferença de salário pelo período em que o profissional exercer a função que contenha o salário superior. O período probatório deverá ser de no máximo 60 dias.
*/
Local cVar := "|1|2|11|34|35|36|37|56|60|62|64|65|68|100|102|104|108|110|126|266|268|270|274|483|600|640|656|664|674|675|685|695|696|700|720|725|726|727|728|729|745|747|749|750|754|755|756|757|758|760|761|762|763|764|765|778|779|787|789|790|791|792|824|897|935|936"
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


// Cod. Prod. desc. sind. odonto  calculo Rentabilidade
User Function MVXSINOP()
Local cVar := "|510|607|665|679|724|732|739|825|900|"
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

// Codigo contrato e empresa Consorcio calGENX3culo Rentabilidade
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
    cVar += "305000554;150;000000001;000001010;1;50;000000000/"
    cVar += "386000609;160;000000001;386000609;1;50;000000000"
    
ElseIf cEmpAnt == '14'
    cVar := "302000508;140;000000001;000000002;1;0 ;302000508;010"
ElseIf cEmpAnt == '16'
    cVar := "386000609;160;000000001;386000609;1;50;386000609;010"
ElseIf cEmpAnt == '18'
    cVar := "303000623;180;000000001;303000623;1;0 ;303000623;010"
EndIf
aVar := StrTokArr(cVar,"/")
Return aVar


// Cod. Prod. para rateio no calculo de rentabilidade
User Function MVXCEXMP()
Local cVar := "41201015"
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
Local cVar := "|875|910|938|"
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

User Function MVYFURNAS()
Local cVar := "|381|391|"
Return cVar



// Gestão de Contratos

/* Clientes Petrobras
A1_COD	A1_NOME
000153	PETROLEO BRASILEIRO S/A - PETROBRAS                                             
000249	PETROLEO BRASILEIRO S/A - PETROBRAS                                             
000255	PETROLEO BRASILEIRO S/A - PETROBRAS                                             
000256	PETROLEO BRASILEIRO S/A - PETROBRAS                                             
000281	PETROLEO BRASILEIRO S A PETROBRAS                                               
000281	PETROLEO BRASILEIRO S/A - PETROBRAS                                             
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CATU                                      
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CONSORCIO C-M-210                         
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CONSORCIO C-M-277                         
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CONSORCIO C-M-344                         
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CONSORCIO C-M-346                         
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CONSORCIO C-M-411                         
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CONSORCIO C-M-413                         
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CONSORCIO C-M-657_R15                     
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - CONSORCIO C-M-709_R15                     
000281	PETROLEO BRASILEIRO S/A - PETROBRAS - JAPARATUBA                                
000291	PETROLEO BRASILEIRO S/A PETROBRAS                                               
000310	PETROLEO BRASILEIRO S/A - PETROBRAS                                             
000313	PETROBRAS DISTRIBUIDORA SA                                                      
000316	PETROBRAS TRANSPORTE S/A - TRANSPETRO - TERMINAL SAO CAETANO DO SUL             
000317	PETROBRAS TRANSPORTE S/A - TRANSPETRO - TERMINAL BARUERI                        
000318	PETROBRAS TRANSPORTE S/A - TRANSPETRO - TERMINAL GUARULHOS                      
000319	PETROBRAS TRANSPORTE S/A - TRANSPETRO - TERMINAL GUARAREMA                      
000320	PETROBRAS TRANSPORTE S/A - TRANSPETRO - TERMINAL CUBATAO                        
000321	PETROBRAS TRANSPORTE S/A - TRANSPETRO - TERMINAL SAO SEBASTIAO                  
000333	PETROLEO BRAS S/A PETROBRAS - UIRAPURU                                          
000334	PETROLEO BRAS S/A PETROBRAS - TRES MARIAS                                       
000335	PETROLEO BRASILEIRO S/A  CABO FRIO CENTRAL                                      
000336	PETROLEO BRASILEIRO S/A - DOIS IRMAOS                                           
000345	PETROBRAS EDUCACAO AMBIENTAL                                                    
000346	PETROBRAS CARAGUATATUBA - BOMBEIROS                                             
000347	PETROBRAS EDICIN - U.P.                                                         
000372	PETROBRAS TRANSPORTE S.A. - TRANSPETRO
000389  PETROLEO BRASILEIRO S A PETROBRAS                                                                                        
*/
User Function IsPetro(cCliente)
Local lRet		:= .F.
Local aPetro 	:= {}
If cEmpAnt == "01" .AND. !Empty(cCliente)
	aAdd(aPetro,"000153")
	aAdd(aPetro,"000249")
	aAdd(aPetro,"000255")
	aAdd(aPetro,"000256")
	aAdd(aPetro,"000281")
	aAdd(aPetro,"000291")
	aAdd(aPetro,"000310")
	aAdd(aPetro,"000316")
	aAdd(aPetro,"000317")
	aAdd(aPetro,"000318")
	aAdd(aPetro,"000319")
	aAdd(aPetro,"000320")
	aAdd(aPetro,"000321")
	aAdd(aPetro,"000333")
	aAdd(aPetro,"000334")
	aAdd(aPetro,"000335")
	aAdd(aPetro,"000336")
	aAdd(aPetro,"000345")
	aAdd(aPetro,"000346")
	aAdd(aPetro,"000347")
	aAdd(aPetro,"000372")
	aAdd(aPetro,"000389")
	If Ascan(aPetro,cCliente) > 0
		lRet := .T.
	EndIf
EndIf
Return lRet


// Tabela de Mneumônicos do RH
User Function BKCodRH()
Local aDescrRH := {}

// Depto Pessoal
aAdd(aDescrRH,{"LDV","LIQUIDOS DIVERSOS"})
aAdd(aDescrRH,{"VA" ,"VALE ALIMENTACAO"})
aAdd(aDescrRH,{"LFE","FERIAS"})
aAdd(aDescrRH,{"COM","COMISSAO"})
aAdd(aDescrRH,{"VR" ,"VALE REFEICAO"})
aAdd(aDescrRH,{"LAD","ADIANTAMENTO"})
aAdd(aDescrRH,{"LRC","RESCISAO"})
aAdd(aDescrRH,{"MFG","MULTA FGTS"})
aAdd(aDescrRH,{"LFG","FGTS"})
aAdd(aDescrRH,{"LPM","PGTO MENSAL"})
aAdd(aDescrRH,{"LPMA","PGTO MENSAL"})
aAdd(aDescrRH,{"VT" ,"VALE TRANSPORTE"})
aAdd(aDescrRH,{"LAS","ADTO SALARIAL"})
aAdd(aDescrRH,{"LD1","13.o PARC 1"})
aAdd(aDescrRH,{"LD2","13.o PARC 2"})
aAdd(aDescrRH,{"EXM","EXAME MEDICO"})
aAdd(aDescrRH,{"PEN","PENSAO"})
aAdd(aDescrRH,{"REE","REEMBOLSO"})
aAdd(aDescrRH,{"DCH","DIARIA DE CAMPO"})
aAdd(aDescrRH,{"HEX","HORAS EXTRAS"})
aAdd(aDescrRH,{"GRA","GRATIFICACAO"})
aAdd(aDescrRH,{"DIN","DIN"})
aAdd(aDescrRH,{"ADF","ADF"})
aAdd(aDescrRH,{"LAC","LAC"})

// Despesas de Viagem
aAdd(aDescrRH,{"SOL","SOLICITACAO"})
aAdd(aDescrRH,{"HOS","HOSPEDAGEM"})
aAdd(aDescrRH,{"RMB","REEMBOLSO"})
aAdd(aDescrRH,{"NDB","NDB"})
aAdd(aDescrRH,{"PCT","PCT"})

// Caixa
aAdd(aDescrRH,{"CXA","PREST. CONTAS"})

Return aDescrRH


// Retorna a descrição do codigo do RH
User Function BKDescRH(cTipBK)
Local aDescrRH	:= u_BKCodRH()
Local nS 		:= 0
Local cDescr 	:= ""
nS := aScan(aDescrRH,{ |x| x[1] == AllTrim(cTipBK)})
If nS > 0
	cDescr := aDescrRH[nS,2]
EndIf
Return cDescr


// Retorna se o fornecedor é a própria BK
User Function IsFornBK(cForn)
Return (cForn == u_cFornBK())

User Function cFornBK()
Return "000084"



// Enum E2_XXPGTO - usado no RESTITCP
User Function DE2XXPgto(cE2XXPgto)
Local cStatus := "Em Aberto"
If cE2XXPgto == "P"
	cStatus := "Pendente"
ElseIf cE2XXPgto == "C"
	cStatus := "Concluido"
ElseIf cE2XXPgto == "O"
	cStatus := "Compensar PA"
ElseIf cE2XXPgto == "D"
	cStatus := "Deb Automatico"
EndIf
Return cStatus






