#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FWCOMMAND.CH"

STATIC NFENTRADA		:= '1'
STATIC NFSAIDA 		:= '2'	

//-------------------------------------------------------------------
/*/{Protheus.doc} FISR101
 
Relatório de conferência da EFD Contribuições. Este relatório tem objetivo 
de imprimir as movimentações consideradas na apuração, para auxiliar o usuário
no momento de conferência das informações. Aqui iremos demonstrar as movimentações
do módulo fiscal, e das integrações realizadas.
Neste relatório não iremos demonstrar detalhamento de valores provenientes de
ponto de entrada, já que o sistema não teria como rastrear a origem destas informações.
 
@author Erick G Dias
@since 06/06/2016
@version 11.80

@history Vogas Júnior, 05/06/2018, (DSERFIS1-4280)  imprimir relartório conforme período apurado.
@history Vogas Júnior, 13/09/2018, (DSERFIS1-7017) implementando quebras no relatório.
/*/
//-------------------------------------------------------------------
User Function xFISR101()

//dPer, cReg, cCKRLiv,  dDtIni, dDtFim )

local oReport
Local lContinua		:= .T.

Local dPer          := CtoD('01/11/2019')
Local cReg          := "4"
Local cCKRLiv       := "*"
Local dDtIni 		:= CtoD('01/11/2019')
Local dDtFim		:= CtoD('30/11/2019')

//IF isincallstack("FISA001")
	
//	IF AliasINdic('F0T')
//		AjustaSX1()
		If Pergunte('FSR101', .T.)
			dPer   := MV_PAR10
			dDtIni := MV_PAR10
			dDtFim := MV_PAR11
		
			If lContinua
				oReport := reportDef('FSR101', dDtIni, dDtFim, dPer, cReg, cCKRLiv, .T.)
				oReport:printDialog()
			EndIF
		EndIF
//	Else
//		Alert('Tabela F0T não existe, favor verificar atualizações de dicionários de dados')
//	EndIF
//Else
//	Alert('Esta rotina deverá ser processada através da Apuração da EFD Contribuições (FISA001)')
//EndIF

return
        
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
 
Função responsável para impressão do relatório, que irá fazer o laço nas filiais
imprimindo as seções pertinentes.
 
@author Erick G Dias
@since 06/06/2016
@version 11.80
@return oReport - Objeto - Objeto do relatório Treport

/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport, dDtIni, dDtFim, DDATAINI, CREGIME, CLIVRO, lGetFil)

local oSecao1 	:= oReport:Section(1)
local oSecao2 	:= oReport:Section(2)
Local oSecao3 	:= oReport:Section(3)
Local oSecao4 	:= oReport:Section(4)
Local oSecao5 	:= oReport:Section(5)
Local oSecao6		:= oReport:Section(6)
Local oSecao7		:= oReport:Section(7)
Local oSecao8		:= oReport:Section(8)
Local oSecao9		:= oReport:Section(9)
Local oSecao10	:= oReport:Section(10)
Local oSecao11	:= oReport:Section(11)
Local oSecao12	:= oReport:Section(12)
Local oSecao13	:= oReport:Section(13)
Local oSecao14
Local oSecao15	:= oReport:Section(15)
Local oSecao16	:= oReport:Section(16)
Local oApurEFD	:= FISX001():New()
Local cMes			:= strzero(month(DDATAINI),2)
Local cAno			:= str(year(DDATAINI),4)
Local nContFil	:= 0
Local aAreaSM0 	:= SM0->(GetArea())
local aFil			:= {}
Local dDataDe	:= IIf( ! Empty( dDtIni ), dDtIni, cTod("01/"+cMes+"/"+cAno))
Local dDataAte	:= IIf( ! Empty( dDtFim ), dDtFim,  LastDay(dDataDe))
Local lCPRBNF		:= GetNewPar('MV_CPRBNF',.F.) .AND. SFT->(FieldPos('FT_VALCPB')) > 0
Local lProcRH 	:= GetNewPar("MV_SPCBPRH",.F.)
Local cAliasRet		:= GetNextAlias()
Local cAliasF100	:= GetNextAlias()
Local cAliasF1X0	:= GetNextAlias()
Local cAliasSFT		:= GetNextAlias()
Local cAliasF0T		:= GetNextAlias() 
Local cAliasF0TT	:= GetNextAlias()
Local cAliasDIFP	:= GetNextAlias()
Local cAliasDIFA	:= GetNextAlias()
Local cAlsCPRBFA	:= GetNextAlias()
Local cAlsCPRBCX	:= GetNextAlias()
Local cAliasF0TI	:= GetNextAlias()
Local cAliasF3J		:= GetNextAlias()
Local cAliasCF4		:= GetNextAlias()
Local cAliasCFA		:= GetNextAlias()
Local cAliasF0TA	:= GetNextAlias() //diferimento crédito anterior
Local cAliasF3O		:= GetNextAlias()
Local cAliasF3P		:= GetNextAlias()
Local lAtual		:= .F.
Local lAnt			:= .F.
Local lCF4FLORIG	:= CF4->(FieldPos("CF4_FLORIG"))>0
Local lFuncCupom	:= FindFunction("FSA001QECF")
Local lF3J			:= AliasINdic('F3J')
Local lNewDif		:= FindFunction("ISA001NDIF") .AND. ISA001NDIF()
Local lF3O			:= AliasINdic('F3O')
Local lF3P			:= AliasINdic('F3P')

Default lGetFil	:=.F.

oApurEFD:SetDtIni(dDataDe)
oApurEFD:SetDtFin(dDataAte)
oApurEFD:SetLivro(Iif(!Empty(CLIVRO),CLIVRO,"*")) //Processa todos os livros caso campo CKR_LIVRO não esteja preenchido

aFil		:= GetFil(lGetFil)

If len(aFil) ==0
	MsgAlert('Nenhuma filial foi selecionada, o processamento não será realizado.')
Else	

	IF lF3J
		oSecao14	:= oReport:Section(14)
	EndIF

 	IF MV_PAR05 == 1 .AND. CREGIME <> '3'
 		//Irá verificar se na apuração houve realmente cálculo de diferimento atual e anterior
 		CheckDif(@lAtual,@lAnt,dDataDe)
 	EndIF
	
	For nContFil := 1 to Len(aFil)		
		SM0->(DbGoTop ())
		SM0->(MsSeek (aFil[nContFil][1]+aFil[nContFil][2], .T.))	//Pego a filial mais proxima
		cFilAnt := FWGETCODFILIAL
		
		//----------------------------------------------------
		//Seção que irá imprimir o detalhamento das retenções
		//----------------------------------------------------
		IF MV_PAR04 == 1
			PrintCKY(dDataDe, dDataAte,oSecao1,oReport,cAliasRet)
		EndIF		
		
		IF CREGIME $ '1/2/4' // Regime Não Cumulativo
			
			//----------------------------------------------------
		   //Query dos títulos e demais documentos
			//----------------------------------------------------	    
			IF MV_PAR02 == 1				
				PrintCL2T(dDataDe, dDataAte,oSecao2,oReport,cAliasF100)
			EndIF
			
			IF CREGIME $ '1/4'
			
				//----------------------------------------------------
				//Seção que irá imprimir o detalhamento de ativo fixo
				//----------------------------------------------------
				IF MV_PAR03 == 1					
					PrintCL2A(dDataDe, dDataAte,oSecao3,oReport,cAliasF1X0)
				EndIF
				
				//---------------------------------------------------------------------------
				//Seção que irá imprimir o detalhamento das notas de entrada, gravadas na SFT		
				//---------------------------------------------------------------------------
				IF MV_PAR01 == 1					
					PrintSFT(dDataDe, dDataAte,oSecao4,oReport,oApurEFD,NFENTRADA,oSecao7, .F.,cAliasSFT)
				EndIF
								
			EndIF
	
			//---------------------------------------------------------------------------
			//Seção que irá imprimir o detalhamento das notas de saída e Cupom Fiscal, gravadas na SFT		
			//---------------------------------------------------------------------------
			IF MV_PAR01 == 1
				PrintSFT(dDataDe, dDataAte,oSecao4,oReport,oApurEFD,NFSAIDA,oSecao7, lCPRBNF,cAliasSFT)
				IF lFuncCupom
					PrintSFTC(dDataDe, dDataAte,oSecao4,oReport,oApurEFD,cAliasSFT)
				EndIF
			EndIF
				
		EndIF	
		
		IF CREGIME == '3' // regime de caixa
			
			//---------------------------------------------------------------------------
			//Seção que irá imprimir as movimentações de documento fiscal no regime caixa		
			//---------------------------------------------------------------------------		
			IF MV_PAR01 == 1				
				PrintF0TN(dDataDe, dDataAte,oSecao5,oReport,cAliasF0T)
			EndIF
	
			//---------------------------------------------------------------------------
			//Seção que irá imprimir as movimentações dos títulos no regime caixa		
			//---------------------------------------------------------------------------		
			IF MV_PAR02 == 1				
				PrintF0TT(dDataDe, dDataAte,oSecao6,oReport,cAliasF0TT)
			EndIF
		EndIF

		IF MV_PAR05 == 1 .AND. CREGIME <> '3' //Regime Diferente de Caixa
			//---------------------------------------------------------------------------
			//Seção que irá imprimir Diferimento do período atual		
			//---------------------------------------------------------------------------
			PrintF0TDP(dDataDe, dDataAte,oSecao8,oReport,cAliasDIFP)			

			//---------------------------------------------------------------------------
			//Seção que irá imprimir Diferimento do período anterior		
			//---------------------------------------------------------------------------
			PrintF0TDA(dDataDe, dDataAte,oSecao9,oReport,cAliasDIFA)
			
			IF lNewDif
				//---------------------------------------------------------------------------
				//Seção que irá imprimir Diferimento de Crédito do período atual		
				//---------------------------------------------------------------------------
				PrintCFA(dDataDe, dDataAte,oSecao12,oReport,cAliasCFA)

				//---------------------------------------------------------------------------
				//Seção que irá imprimir Diferimento de Crédito do período anterior
				//---------------------------------------------------------------------------				
				PrintF0TA(dDataDe, dDataAte,oSecao13,oReport,cAliasF0TA)
				
			EndIF			
		EndIF		
		
		IF MV_PAR06 == 1 //Imprime CPRB		

			IF CREGIME == '3' .AND. lCPRBNF // Regime Caixa
				//---------------------------------------------------------------------------
				//Seção que irá imprimir CPRB no regime Caixa		
				//---------------------------------------------------------------------------
				PrintF0TC(dDataDe, dDataAte,oSecao7,oReport,cAlsCPRBCX)
			ElseIf CREGIME <> '3' .AND. !lCPRBNF
				//Regime Competência
				//---------------------------------------------------------------------------
				//Seção que irá imprimir CPRB com integração do Faturamento		
				//---------------------------------------------------------------------------		
				PrintF0TFR(dDataDe, dDataAte,oSecao7,oReport,lProcRH,cAlsCPRBFA)
			EndIF
		
		EndIF
		
		If MV_PAR07 == 1 .AND. lCF4FLORIG .AND. CREGIME <> '3'
			PrintCF4(dDataDe, dDataAte,oSecao10,oReport,cAliasCF4)
		EndIF
		
		
		If MV_PAR08 == 1 .AND. CREGIME <> '3'
			PrintF0TI(dDataDe, dDataAte,oSecao11,oReport,cAliasF0TI)
		EndIF
		
		IF lF3J .AND. MV_PAR09 == 1 
			PrintF3J(dDataDe, dDataAte,oSecao14,oReport,cAliasF3J)
		EndIf

		IF LF3O
			PrintF3O(dDataDe,oSecao15,oReport,cAliasF3O)			
		EndIf

		IF LF3P			
			PrintF3P(dDataDe, oSecao16,oReport,cAliasF3P)
		EndIf

			
	Next nContFil
	
	RestArea (aAreaSM0)
	cFilAnt := FWGETCODFILIAL			
	FreeObj(oApurEFD)
	oApurEFD	:= Nil

EndIF

return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
 
Função que irá criar a estrutura do relatório, com as definições de cada seção,
quebras, somatórios etc.
 
@author Erick G Dias
@since 06/06/2016
@version 11.80
@return aSM0 - Array - Array com as filiais selecionada para processar

/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg, dDtIni, dDtFim, DDATAINI, CREGIME, CLIVRO, lSelFil )

local cTitle  		:= "Relatório de Conferência da EFD Contribuições"
local cHelp   		:= "Listagem das movimentações consideradas no processamento da EFD Contribuições"
Local cCSt			:= '01/02/03/04/05/06/50/51/52/53/54/55/56/60/61/62/63/64/65/66/  '
Local cCStBase		:= '01/02/04/05/06/50/51/52/53/54/55/56/60/61/62/63/64/65/66/  '
//Local cCStCred		:= '50/51/52/53/54/55/56/60/61/62/63/64/65/66' 
Local cCStDeb		:= '01/02/03/04/05/06/  '
Local cCStDebBas	:= '01/02/04/05/06/  '
local oReport
local oSection1
local oSection2
local oSection3
local oSection4
local oSection5
local oSection6
local oSection7
local oSection8
local oSection9
local oSection10
local oSection11
local oSection12
local oSection13
local oSection14
local oSection15
Local oSection16
//Local aFields   := { }
//Local nI	:= 0
Local oBreak
Local lF0tCNPJ	:= F0T->(FieldPos("F0T_CNPJ")) > 0

Default cPerg		:= "FSR101"
Default dDtIni		:= IIf( CKR->(FieldPos('CKR_DTINI')) > 0, CKR->CKR_DTINI, CtoD(''))	
Default dDtFim		:= IIf( CKR->(FieldPos('CKR_DTFIM')) > 0, CKR->CKR_DTFIM, CtoD(''))	
Default DDATAINI	:= CKR->CKR_PER
Default CREGIME		:= alltrim(str(CKR->CKR_REGIME))
Default CLIVRO		:= IIf( CKR->(Fieldpos("CKR_LIVRO")) > 0, CKR->CKR_LIVRO, "")	
Default lSelFil		:= .F.

oReport := TReport():New('EFDCON-BK',cTitle,cPerg,{|oReport|ReportPrint(oReport, dDtIni, dDtFim, DDATAINI, CREGIME, CLIVRO, lSelFil)},cHelp)
oReport:SetLandscape()

//Primeira seção

oSection1 := TRSection():New(oReport,"Retenção na Fonte PIS e COFINS",{"CKY"})

oSection1:SetHeaderSection(.T.)
oSection1:SetTitle("Retenção na Fonte PIS e COFINS")

TRCell():New(oSection1,"CKY_FILIAL"	,  "CKY","Filial")
TRCell():New(oSection1,"CKY_NUMTIT"	,  "CKY","Número do Título")
TRCell():New(oSection1,"CKY_PREFIX"	,  "CKY","Prefixo")
TRCell():New(oSection1,"CKY_PARC"		,  "CKY","Parcela")
TRCell():New(oSection1,"CKY_DTEMIS"	,  "CKY","Data de Emissão")
TRCell():New(oSection1,"CKY_ORIG "		,  "CKY","Origem")
TRCell():New(oSection1,"CKY_DTRET "	,  "CKY","Data da Baixa")
TRCell():New(oSection1,"CKY_CNPJ  "	,  "CKY", "CNPJ")
TRCell():New(oSection1,"CKY_PISRET"	,  "CKY", "PIS Retido")
TRCell():New(oSection1,"CKY_COFRET"	,  "CKY", "COFINS Retido")

oBreak := TRBreak():New(oSection1,oSection1:Cell("CKY_FILIAL"),"Totalizadores",.F.,'Totalizadores',.T.)
TRFunction():New(oSection1:Cell("CKY_PISRET"),NIL,"SUM",oBreak,'PIS Retido   ',,,.F.,.F.) 
TRFunction():New(oSection1:Cell("CKY_COFRET"),NIL,"SUM",oBreak,'COFINS Retido',,,.F.,.F.)
oSection1:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection1:SetPageBreak(.T.) //Pula de página após quebra
oSection1:SetHeaderSection(.T.)

//Segunda seção
oSection2 := TRSection():New(oReport,"Títulos Financeiros/Demais Documentos",{"CL2"})

oSection2:SetHeaderSection(.T.)
oSection2:SetTitle("Títulos Financeiros/Demais Documentos")

TRCell():New(oSection2,"CL2_FILIAL"	,  "CL2","Filial")
TRCell():New(oSection2,"CL2_NUMTIT"	,  "CL2","Num. Título")
TRCell():New(oSection2,"CL2_PREFIX"	,  "CL2","Prefixo")
TRCell():New(oSection2,"CL2_PARC"		,  "CL2","Parcela")
TRCell():New(oSection2,"CL2_IDCF8"		,  "CL2","Demais Docs.")
TRCell():New(oSection2,"CL2_DTOPER"	,  "CL2","Data Emissão")
TRCell():New(oSection2,"CL2_VLOPER"	,  "CL2","Valor Oper.")
TRCell():New(oSection2,"CL2_REGIME"	,  "CL2","Regime")
TRCell():New(oSection2,"CL2_CODBCC"	,  "CL2", "CODBCC")
TRCell():New(oSection2,"CL2_CSTPIS"	,  "CL2", "CST PIS")
TRCell():New(oSection2,"CL2_BCPIS"		,  "CL2", "BC. PIS")
TRCell():New(oSection2,"CL2_ALQPIS"	,  "CL2", "Alq. PIS")
TRCell():New(oSection2,"CL2_VLPIS"		,  "CL2", "Vl. PIS")
TRCell():New(oSection2,"CL2_CSTCOF"	,  "CL2", "CST COF")
TRCell():New(oSection2,"CL2_BCCOF"		,  "CL2", "BC. COF")
TRCell():New(oSection2,"CL2_ALQCOF"	,  "CL2", "Alq. COF")
TRCell():New(oSection2,"CL2_VLCOF"		,  "CL2", "Vl. COF")

oBreak := TRBreak():New(oSection2,{||  CL2_FILIAL + Iif(CL2_CSTPIS<'50','S','E') },"Totalizadores ",.F.,'Totalizadores',.T.)
TRFunction():New(oSection2:Cell("CL2_VLOPER"),NIL,"SUM",oBreak,'Valor das Operações',,,.F.,.F.)
TRFunction():New(oSection2:Cell("CL2_BCPIS"),NIL,"SUM",oBreak,'Base de PIS',,,.F.,.F.,,,{|| CL2_CSTPIS $ cCStBase})
TRFunction():New(oSection2:Cell("CL2_BCCOF"),NIL,"SUM",oBreak,'Base de Cofins',,,.F.,.F.,,,{|| CL2_CSTPIS $ cCStBase})
TRFunction():New(oSection2:Cell("CL2_VLPIS"),NIL,"SUM",oBreak,'Valor de PIS',,,.F.,.F.,,,{|| CL2_CSTPIS $ cCSt}) 
TRFunction():New(oSection2:Cell("CL2_VLCOF"),NIL,"SUM",oBreak,'Valor de COFINS',,,.F.,.F.,,,{|| CL2_CSTPIS $ cCSt})
oSection2:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection2:SetHeaderSection(.T.)

//Terceira Seção
oSection3 := TRSection():New(oReport,"Conferência Crédito de Ativo Fixo",{"CL2"})

oSection3:SetHeaderSection(.T.)
oSection3:SetTitle("Conferência Crédito de Ativo Fixo")

TRCell():New(oSection3,"CL2_FILIAL"	,  "CL2","Filial")
TRCell():New(oSection3,"CL2_CODATF"	,  "CL2","Código do Ativo")
TRCell():New(oSection3,"CL2_DESATF"	,  "CL2","Descrição do Ativo")
TRCell():New(oSection3,"CL2_ITATF"  	,  "CL2","Item do Ativo")
TRCell():New(oSection3,"CL2_CRTCRD"	,  "CL2","Critério do Crédito")
TRCell():New(oSection3,"CL2_CODBCC"	,  "CL2", "CODBCC")
TRCell():New(oSection3,"CL2_CSTPIS"	,  "CL2", "CST PIS")
TRCell():New(oSection3,"CL2_BCPIS"		,  "CL2", "BC. PIS")
TRCell():New(oSection3,"CL2_ALQPIS"	,  "CL2", "Alq. PIS")
TRCell():New(oSection3,"CL2_VLPIS"		,  "CL2", "Vl. PIS")
TRCell():New(oSection3,"CL2_CSTCOF"	,  "CL2", "CST COF")
TRCell():New(oSection3,"CL2_BCCOF"		,  "CL2", "BC. COF")
TRCell():New(oSection3,"CL2_ALQCOF"	,  "CL2", "Alq. COF")
TRCell():New(oSection3,"CL2_VLCOF"		,  "CL2", "Vl. COF")

oBreak := TRBreak():New(oSection3,oSection3:Cell("CL2_CRTCRD"),"Totalizadores",.F.,'Totalizadores',.T.)
TRFunction():New(oSection3:Cell("CL2_BCPIS"),NIL,"SUM",oBreak,'Base de PIS',,,.F.,.F.)
TRFunction():New(oSection3:Cell("CL2_BCCOF"),NIL,"SUM",oBreak,'Base de COFINS',,,.F.,.F.)
TRFunction():New(oSection3:Cell("CL2_VLPIS"),NIL,"SUM",oBreak,'Crédito de PIS',,,.F.,.F.) 
TRFunction():New(oSection3:Cell("CL2_VLCOF"),NIL,"SUM",oBreak,'Crédito de COFINS',,,.F.,.F.)
oSection3:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection3:SetHeaderSection(.T.)

//Quarta Seção
oSection4 := TRSection():New(oReport,"Conferência Notas Fiscais")
oSection4:SetHeaderSection(.T.)
TRCell():New(oSection4,"CMP1"		,  "","Filial","",FWGETTAMFILIAL)
TRCell():New(oSection4,"CMP19"		,  "","Tipo Mov","@!",10)
TRCell():New(oSection4,"CMP2"		,  "","Nota Fiscal","@!",9)
TRCell():New(oSection4,"CMP3"		,  "","Entrada","@R 99/99/9999" ,10)
TRCell():New(oSection4,"CMP4"		,  "","Item")//*
TRCell():New(oSection4,"CMP5"		,  "","Modelo")//*
TRCell():New(oSection4,"CMP6"		,  "","Série","@!",3)//*
TRCell():New(oSection4,"CMP7"   	,  "","CFOP","@!",4)//*
TRCell():New(oSection4,"CMP8"		,  "", "CODBCC","@!",2)
TRCell():New(oSection4,"CMP9"		,  "","Vl.Contábil","@E 99,999,999,999.99",14)//*
TRCell():New(oSection4,"CMP10"		,  "", "CST PIS","@!",2)
TRCell():New(oSection4,"CMP11"		,  "", "BC.PIS","@E 99,999,999,999.99",14)
TRCell():New(oSection4,"CMP12"		,  "", "Alq.PIS","@E 999.9999",8)
TRCell():New(oSection4,"CMP13"		,  "", "Vl.PIS","@E 99,999,999,999.99",14)
TRCell():New(oSection4,"CMP14"		,  "", "CST COF","@!",2)
TRCell():New(oSection4,"CMP15"		,  "", "BC.COF","@E 99,999,999,999.99",14)
TRCell():New(oSection4,"CMP16"		,  "", "Alq.COF","@E 999.9999",8)
TRCell():New(oSection4,"CMP17"		,  "", "Vl.COF","@E 99,999,999,999.99",14)
TRCell():New(oSection4,"CMP18"		,  "", "Dt.Cancelamento","@R 99/99/9999" ,8)
TRCell():New(oSection4,"CMP20"		,  "", "Observação","@!" ,31)
TRCell():New(oSection4,"CMP21"		,  "", "TES","@!" ,3)
TRCell():New(oSection4,"CMP22"		,  "", "Produto","@!" ,15)
TRCell():New(oSection4,"CMP23"		,  "", "Descrição","@!" ,60)
TRCell():New(oSection4,"CMP24"		,  "", "Emissão","@R 99/99/9999" ,10)
TRCell():New(oSection4,"CMP25"		,  "", "Código","@!" ,6)
TRCell():New(oSection4,"CMP26"		,  "", "Loja","@!" ,2)
TRCell():New(oSection4,"CMP27"		,  "", "Cliente/Fornecedor","@!" ,60)
TRCell():New(oSection4,"CMP28"		,  "", "CNPJ/CPF","@!" ,14)
TRCell():New(oSection4,"CMP29"		,  "", "C.Custo","@!" ,9)
TRCell():New(oSection4,"CMP30"		,  "", "Descr. Centro de Custo","@!" ,40)
TRCell():New(oSection4,"CMP31"		,  "", "Usuário","@!" ,15)
TRCell():New(oSection4,"CMP32"		,  "", "Emissão","@R 99/99/9999" ,10)


oBreak := SetQuebra(oSection4, 'CMP1', '4')
TRFunction():New(oSection4:Cell("CMP9"),NIL,"SUM",oBreak,'Valor Contábil',,,.F.,.F.		,,,{|| Empty(oSection4:Cell("CMP18"):getvalue()) })
TRFunction():New(oSection4:Cell("CMP11"),NIL,"SUM",oBreak,'Base de PIS',,,.F.,.F.		,,,{|| Empty(oSection4:Cell("CMP18"):getvalue()) .AND. oSection4:Cell("CMP10"):getvalue() $ cCStBase})
TRFunction():New(oSection4:Cell("CMP15"),NIL,"SUM",oBreak,'Base de COFINS',,,.F.,.F.	,,,{|| Empty(oSection4:Cell("CMP18"):getvalue()) .AND. oSection4:Cell("CMP10"):getvalue() $ cCStBase})
TRFunction():New(oSection4:Cell("CMP13"),NIL,"SUM",oBreak,'Valor de PIS',,,.F.,.F.		,,,{|| Empty(oSection4:Cell("CMP18"):getvalue()) .AND. oSection4:Cell("CMP10"):getvalue() $ cCSt})                      
TRFunction():New(oSection4:Cell("CMP17"),NIL,"SUM",oBreak,'Valor de COFINS',,,.F.,.F.	,,,{|| Empty(oSection4:Cell("CMP18"):getvalue()) .AND. oSection4:Cell("CMP10"):getvalue() $ cCSt})

oSection4:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection4:SetHeaderSection(.T.)
	
//Qiinta Seção
oSection5 := TRSection():New(oReport,"Documentos Fiscais - Regime Caixa",{"F0T"})
oSection5:SetHeaderSection(.T.)
oSection5:SetTitle("Documentos Fiscais - Regime Caixa")

TRCell():New(oSection5,"F0T_FILIAL"	,  "F0T","Filial")
TRCell():New(oSection5,"F0T_NUMNF"		,  "F0T","Nota Fiscal")	
TRCell():New(oSection5,"F0T_SER"		,  "F0T","Série")
TRCell():New(oSection5,"F0T_DTEMI"		,  "F0T","Emissão")
TRCell():New(oSection5,"F0T_DTRECB"	,  "F0T","Recebimento")
TRCell():New(oSection5,"F0T_PERREC"	,  "F0T","% Recebimento")
TRCell():New(oSection5,"F0T_CFOP"		,  "F0T","CFOP")
TRCell():New(oSection5,"F0T_ITEM"		,  "F0T","Item NF")
TRCell():New(oSection5,"F0T_MODELO"	,  "F0T","Modelo")
TRCell():New(oSection5,"F0T_VLCONT"	,  "F0T","Val. Contábil")
TRCell():New(oSection5,"F0T_CSTPIS"	,  "F0T","CST PIS")
TRCell():New(oSection5,"F0T_BASPIS"	,  "F0T","Base PIS")
TRCell():New(oSection5,"F0T_ALQPIS"	,  "F0T","Alq. PIS")
TRCell():New(oSection5,"F0T_VALPIS"	,  "F0T","Val. PIS")		
TRCell():New(oSection5,"F0T_CSTCOF"	,  "F0T","CST COFINS")
TRCell():New(oSection5,"F0T_BASCOF"	,  "F0T","Base COFINS")
TRCell():New(oSection5,"F0T_ALQCOF"	,  "F0T","Alq. COFINS")
TRCell():New(oSection5,"F0T_VALCOF"	,  "F0T","Val COFINS")		
oBreak := TRBreak():New(oSection5,oSection5:Cell("F0T_FILIAL"),"Totalizadores",.F.,"Totalizadores",.T.)
TRFunction():New(oSection5:Cell("F0T_VLCONT"),NIL,"SUM",oBreak,'Valor da Operação',,,.F.,.F.)
TRFunction():New(oSection5:Cell("F0T_BASPIS"),NIL,"SUM",oBreak,'Base de PIS',,,.F.,.F.,,,{|| F0T_CSTPIS $ cCStDebBas})
TRFunction():New(oSection5:Cell("F0T_BASCOF"),NIL,"SUM",oBreak,'Base de COFINS',,,.F.,.F.,,,{|| F0T_CSTPIS $ cCStDebBas})
TRFunction():New(oSection5:Cell("F0T_VALPIS"),NIL,"SUM",oBreak,'Valor de PIS',,,.F.,.F.,,,{|| F0T_CSTPIS $ cCStDeb}) 
TRFunction():New(oSection5:Cell("F0T_VALCOF"),NIL,"SUM",oBreak,'Valor de COFINS',,,.F.,.F.,,,{|| F0T_CSTPIS $ cCStDeb})	
oSection5:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection5:SetHeaderSection(.T.)

//Sexta Seção
oSection6 := TRSection():New(oReport,"Títulos - Regime Caixa",{"F0T"})
oSection6:SetHeaderSection(.T.)
oSection6:SetTitle("Títulos - Regime Caixa")

TRCell():New(oSection6,"F0T_FILIAL"	,  "F0T","Filial")
TRCell():New(oSection6,"F0T_NUMTIT"	,  "F0T","Título")	
TRCell():New(oSection6,"F0T_PREFIX"	,  "F0T","Prefixo")
TRCell():New(oSection6,"F0T_PARC"		,  "F0T","Parcela")
TRCell():New(oSection5,"F0T_DTEMI"		,  "F0T","Emissão")
TRCell():New(oSection6,"F0T_DTRECB"	,  "F0T","Recebimento")
TRCell():New(oSection6,"F0T_PERREC"	,  "F0T","% Recebimento")
TRCell():New(oSection6,"F0T_VLCONT"	,  "F0T","Val. Contábil")
TRCell():New(oSection6,"F0T_CSTPIS"	,  "F0T","CST PIS")
TRCell():New(oSection6,"F0T_BASPIS"	,  "F0T","Base PIS")
TRCell():New(oSection6,"F0T_ALQPIS"	,  "F0T","Alíquota PIS")
TRCell():New(oSection6,"F0T_VALPIS"	,  "F0T","VAlor PIS")		
TRCell():New(oSection6,"F0T_CSTCOF"	,  "F0T","CST COFINS")
TRCell():New(oSection6,"F0T_BASCOF"	,  "F0T","Base COFINS")
TRCell():New(oSection6,"F0T_ALQCOF"	,  "F0T","Alíquota COFINS")
TRCell():New(oSection6,"F0T_VALCOF"	,  "F0T","Valor COFINS")		
oBreak := TRBreak():New(oSection6,oSection6:Cell("F0T_FILIAL"),"Totalizadores",.F.,"Totalizadores",.T.)
TRFunction():New(oSection6:Cell("F0T_VLCONT"),NIL,"SUM",oBreak,'Valor da Operação',,,.F.,.F.)
TRFunction():New(oSection6:Cell("F0T_BASPIS"),NIL,"SUM",oBreak,'Base de PIS',,,.F.,.F.,,,{|| F0T_CSTPIS $ cCStDebBas})
TRFunction():New(oSection6:Cell("F0T_BASCOF"),NIL,"SUM",oBreak,'Base de COFINS',,,.F.,.F.,,,{|| F0T_CSTPIS $ cCStDebBas})
TRFunction():New(oSection6:Cell("F0T_VALPIS"),NIL,"SUM",oBreak,'Valor de PIS',,,.F.,.F.,,,{|| F0T_CSTPIS $ cCStDeb}) 
TRFunction():New(oSection6:Cell("F0T_VALCOF"),NIL,"SUM",oBreak,'Valor de COFINS',,,.F.,.F.,,,{|| F0T_CSTPIS $ cCStDeb})	
oSection6:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection6:SetHeaderSection(.T.)

//Sétima Seção
oSection7 := TRSection():New(oReport,"Conferência CPRB Notas Fiscais")
oSection7:SetHeaderSection(.T.)
TRCell():New(oSection7,"CMP1"		,  "","Filial","",FWGETTAMFILIAL)
TRCell():New(oSection7,"CMP2"		,  "","Nota Fiscal","@!",9) //*
TRCell():New(oSection7,"CMP3"		,  "","Série","@!",3)//*
TRCell():New(oSection7,"CMP4"		,  "","Emissão","@R 99/99/9999" ,10)//*
TRCell():New(oSection7,"CMP5"   	,  "","CFOP","@!",4)//*
TRCell():New(oSection7,"CMP6"		,  "","Item")//*
TRCell():New(oSection7,"CMP7"		,  "","Modelo")//*
TRCell():New(oSection7,"CMP8"		,  "","Vl.Contábil","@E 99,999,999,999.99",14)//*
TRCell():New(oSection7,"CMP9"		,  "","Vl. Incidente","@E 99,999,999,999.99",14)//*
TRCell():New(oSection7,"CMP10"		,  "","Vl. Exclusão","@E 99,999,999,999.99",14)//*
TRCell():New(oSection7,"CMP11"		,  "","Cod. Atividade","@!",8)
TRCell():New(oSection7,"CMP12"		,  "","Base CPRB","@E 99,999,999,999.99",14)
TRCell():New(oSection7,"CMP13"		,  "","Alq.CPRB","@E 999.9999",8)
TRCell():New(oSection7,"CMP14"		,  "","Vl.CPRB","@E 99,999,999,999.99",14)

oBreak := SetQuebra(oSection7, 'CMP1','7') 
TRFunction():New(oSection7:Cell("CMP8"),NIL,"SUM",oBreak,'Valor Contábil',,,.F.,.F.)
TRFunction():New(oSection7:Cell("CMP9"),NIL,"SUM",oBreak,'Incidente',,,.F.,.F.)
TRFunction():New(oSection7:Cell("CMP10"),NIL,"SUM",oBreak,'Exclusões',,,.F.,.F.)
TRFunction():New(oSection7:Cell("CMP12"),NIL,"SUM",oBreak,'Base de Cálculo',,,.F.,.F.)
TRFunction():New(oSection7:Cell("CMP14"),NIL,"SUM",oBreak,'Valor da CPRB',,,.F.,.F.)

oSection7:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection7:SetHeaderSection(.T.)

//Oitava Seção
oSection8 := TRSection():New(oReport,"Conferência Diferimento do Período")
oSection8:SetHeaderSection(.T.)
TRCell():New(oSection8,"F0T_FILIAL"		,  "","Filial")
If lF0tCNPJ
	TRCell():New(oSection8,"F0T_CNPJ"			,  "","CNPJ")
EndIF
TRCell():New(oSection8,"F0T_NUMNF"			,  "","Nota Fiscal") //*
TRCell():New(oSection8,"F0T_SER"			,  "","Série")//*
TRCell():New(oSection8,"F0T_DTEMI"			,  "","Emissão")//*
TRCell():New(oSection8,"F0T_ITEM"			,  "","Item")//*
TRCell():New(oSection8,"F0T_NUMTIT"		,  "","Número do Título")
TRCell():New(oSection8,"F0T_PREFIX"		,  "","Prefixo")
TRCell():New(oSection8,"F0T_PARC"			,  "","Parcela")
TRCell():New(oSection8,"F0T_IDCF8"			,  "","Demais Docs.")//*
TRCell():New(oSection8,"F0T_VLCONT"		,  "","Valor da Operação")
TRCell():New(oSection8,"F0T_VALREC"		,  "","Valor Recebido")
TRCell():New(oSection8,"F0T_RECDIF"		,  "","Receita Diferida")
TRCell():New(oSection8,"F0T_VALPIS"		,  "","PIS Diferido")
TRCell():New(oSection8,"F0T_VALCOF"		,  "","COFINS Diferida")

oBreak := TRBreak():New(oSection8,oSection8:Cell("F0T_FILIAL"),'Totalizadores' ,.F.,"Totalizadores",.T.)	

TRFunction():New(oSection8:Cell("F0T_VLCONT"),NIL,"SUM",oBreak,'Valor da Operação',,,.F.,.F.)
TRFunction():New(oSection8:Cell("F0T_VALREC"),NIL,"SUM",oBreak,'Valor Recebido',,,.F.,.F.)
TRFunction():New(oSection8:Cell("F0T_RECDIF"),NIL,"SUM",oBreak,'Receita Diferida',,,.F.,.F.)
TRFunction():New(oSection8:Cell("F0T_VALPIS"),NIL,"SUM",oBreak,'PIS Diferido',,,.F.,.F.) 
TRFunction():New(oSection8:Cell("F0T_VALCOF"),NIL,"SUM",oBreak,'COFINS Diferida',,,.F.,.F.) 

oSection8:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection8:SetHeaderSection(.T.)

//Nona Seção
oSection9 := TRSection():New(oReport,"Conferência Diferimento do Período Anterior")
oSection9:SetHeaderSection(.T.)
TRCell():New(oSection9,"F0T_FILIAL"	,  "","Filial")
If lF0tCNPJ
	TRCell():New(oSection9,"F0T_CNPJ"			,  "","CNPJ")
EndIF
TRCell():New(oSection9,"F0T_NUMNF"		,  "","Nota Fiscal") //*
TRCell():New(oSection9,"F0T_SER"		,  "","Série")//*
TRCell():New(oSection9,"F0T_DTEMI"		,  "","Emissão")//*
TRCell():New(oSection9,"F0T_ITEM"		,  "","Item")//*
TRCell():New(oSection9,"F0T_NUMTIT"	,  "","Número do Título")
TRCell():New(oSection9,"F0T_PREFIX"	,  "","Prefixo")
TRCell():New(oSection9,"F0T_PARC"		,  "","Parcela")
TRCell():New(oSection9,"F0T_IDCF8"		,  "","Demais Docs.")//*
TRCell():New(oSection9,"F0T_DTRECB"	,  "","Data Recebimento")//*
TRCell():New(oSection9,"F0T_VALREC"	,  "","Receita Recebida")
TRCell():New(oSection9,"F0T_VALPIS"	,  "","Débito PIS")
TRCell():New(oSection9,"F0T_VALCOF"	,  "","Débito COFINS")

oBreak := TRBreak():New(oSection9,oSection9:Cell("F0T_FILIAL"),"Totalizadores",.F.,"Totalizadores",.T.)
TRFunction():New(oSection9:Cell("F0T_VALREC"),NIL,"SUM",oBreak,'Receita Recebida',,,.F.,.F.)
TRFunction():New(oSection9:Cell("F0T_VALPIS"),NIL,"SUM",oBreak,'Débito PIS',,,.F.,.F.) 
TRFunction():New(oSection9:Cell("F0T_VALCOF"),NIL,"SUM",oBreak,'Débito COFINS',,,.F.,.F.)

oSection9:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection9:SetHeaderSection(.T.)

//Décima Seção
oSection10 := TRSection():New(oReport,"Devoluções que Reduziram Base de Cálculo")
oSection10:SetHeaderSection(.T.)
TRCell():New(oSection10,"CMP1"		,  "","Filial","@!",FWGETTAMFILIAL)
TRCell():New(oSection10,"CMP2"		,  "","Tipo Movimentação","@!",11)
TRCell():New(oSection10,"CMP3"		,  "","Nota Fiscal","@!",9) //*
TRCell():New(oSection10,"CMP4"		,  "","Série","@!",3)
TRCell():New(oSection10,"CMP5"		,  "","Item")//*
TRCell():New(oSection10,"CMP6"		,  "","Emissão","@R 99/99/9999" ,10)//*
TRCell():New(oSection10,"CMP7"		,  "","Base PIS","@E 99,999,999,999.99",14)//*
TRCell():New(oSection10,"CMP8"		,  "","Valor PIS","@E 99,999,999,999.99",14)//*
TRCell():New(oSection10,"CMP9"		,  "","Base COFINS","@E 99,999,999,999.99",14)//*
TRCell():New(oSection10,"CMP10"		,  "","Valor COFINS","@E 99,999,999,999.99",14)//*

oBreak := TRBreak():New(oSection10,{|| oSection10:Cell("CMP1"):getvalue()+oSection10:Cell("CMP2"):getvalue() } ,"Totalizadores",.F.,"Totalizadores",.T.)
TRFunction():New(oSection10:Cell("CMP7"),NIL,"SUM",oBreak,'Base de PIS',,,.F.,.F.)
TRFunction():New(oSection10:Cell("CMP8"),NIL,"SUM",oBreak,'Valor de PIS',,,.F.,.F.)
TRFunction():New(oSection10:Cell("CMP9"),NIL,"SUM",oBreak,'Base de COFINS',,,.F.,.F.)                      
TRFunction():New(oSection10:Cell("CMP10"),NIL,"SUM",oBreak,'Valor de COFINS',,,.F.,.F.)
oSection10:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection10:SetHeaderSection(.T.)

//Décima primeira Seção
oSection11 := TRSection():New(oReport,"Títulos referente o BLoco I")
oSection11:SetHeaderSection(.T.)
TRCell():New(oSection11,"F0T_FILIAL"	,  "","Filial")
TRCell():New(oSection11,"F0T_NUMTIT"	,  "","Número do Título")
TRCell():New(oSection11,"F0T_PREFIX"	,  "","Prefixo")
TRCell():New(oSection11,"F0T_PARC"		,  "","Parcela")
TRCell():New(oSection11,"F0T_VLCONT"	,  "","Valor da Receita")
TRCell():New(oSection11,"F0T_IFEXCL"	,  "","Valor de Exclusão")
TRCell():New(oSection11,"F0T_CDBLCI"	,  "","Código Operação")
TRCell():New(oSection11,"F0T_CSTPIS"	,  "F0T","CST PIS")
TRCell():New(oSection11,"F0T_CSTCOF"	,  "F0T","CST COFINS")

oBreak := TRBreak():New(oSection11, {|| F0T_FILIAL+F0T_CDBLCI} ,"Totalizadores",.F.,"Totalizadores",.T.)
TRFunction():New(oSection11:Cell("F0T_VLCONT"),NIL,"SUM",oBreak,'Receita',,,.F.,.F.)
TRFunction():New(oSection11:Cell("F0T_IFEXCL"),NIL,"SUM",oBreak,'Exclusões',,,.F.,.F.)

oSection11:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection11:SetHeaderSection(.T.)


//Décima segunda Seção
oSection12 := TRSection():New(oReport,"Créditos Diferidos no Período")
oSection12:SetHeaderSection(.T.)
TRCell():New(oSection12,"CFA_FILIAL"	,  "","Filial")
TRCell():New(oSection12,"CFA_TPCON"		,  "","Tributo")
TRCell():New(oSection12,"CFA_CODCRE"	,  "","Código do Crédito")
TRCell():New(oSection12,"CFA_CNPJ"		,  "","CNPJ do Órgão Público")
TRCell():New(oSection12,"CFA_CREDIF"	,  "","Crédito Diferido no Período")

oBreak := TRBreak():New(oSection12, {|| CFA_FILIAL+CFA_TPCON} ,"Totalizadores",.F.,"Totalizadores",.T.)
TRFunction():New(oSection12:Cell("CFA_CREDIF"),NIL,"SUM",oBreak,'Total de Crédito Diferido no Período',,,.F.,.F.)

oSection12:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection12:SetHeaderSection(.T.)


//Décima terceira Seção
oSection13 := TRSection():New(oReport,"Crédito a Descontar vinculado à Contribuição Diferida")
oSection13:SetHeaderSection(.T.)
TRCell():New(oSection13,"F0T_FILIAL"	,  "","Filial")
If lF0tCNPJ
	TRCell():New(oSection13,"F0T_CNPJ"	,  "","CNPJ")
EndIF
TRCell():New(oSection13,"F0T_TIPO"		,  "","Tributo",,10)
TRCell():New(oSection13,"F0T_DTRECB"	,  "","Emissão")//*
TRCell():New(oSection13,"F0T_NUMTIT"	,  "","Título")
TRCell():New(oSection13,"F0T_PREFIX"	,  "","Prefixo")
TRCell():New(oSection13,"F0T_PARC"		,  "","Parcela")
TRCell():New(oSection13,"F0T_IDCF8"		,  "","Demais Docs.")//*
TRCell():New(oSection13,"F0T_VLCONT"	,  "","Vl Faturado")//*
TRCell():New(oSection13,"F0T_VALREC"	,  "","Vl Recebido")//*
TRCell():New(oSection13,"F0T_DTEMI"		,  "","Dt Recebimento")//* 
TRCell():New(oSection13,"F0T_MODELO"	,  "","Nat.Crédito")//*
TRCell():New(oSection13,"F0T_PERREC"	,  "","%Receb.Título")//*
TRCell():New(oSection13,"F0T_BASPIS"	,  "","Cred.Diferido Ant.")//*
TRCell():New(oSection13,"F0T_VALCOF"	,  "","%Receb.Cred.Diferido")//*
TRCell():New(oSection13,"F0T_VALPIS"	,  "","Crédito Descontar")//*

oBreak := TRBreak():New(oSection13, {|| F0T_FILIAL+F0T_TIPO} ,"Totalizadores",.F.,"Totalizadores",.T.)
TRFunction():New(oSection13:Cell("F0T_VALPIS"),NIL,"SUM",oBreak,'Total de Crédito a Descontar',,,.F.,.F.)

oSection13:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
oSection13:SetHeaderSection(.T.)

//Décima quarta seção
IF AliasINdic('F3J')

	oSection14 := TRSection():New(oReport,"Detalhamento Regras do Código de Receita")
	oSection14:SetHeaderSection(.T.)
	TRCell():New(oSection14,"F3J_FILIAL"	,  "","Filial")
	TRCell():New(oSection14,"F3J_CODREC"	,  "","Código de Receita")
	TRCell():New(oSection14,"F3J_TRIBUT"	,  "","Tributo")
	TRCell():New(oSection14,"F3J_VLTRIB"	,  "","Deb. A		do")
	TRCell():New(oSection14,"F3J_TOTPAG"	,  "","Tot. Deb. Período")	
	TRCell():New(oSection14,"F3J_PERCEN"	,  "","Percentual(%)")	
	TRCell():New(oSection14,"F3J_CODPAG"	,  "","Deb.Cod. Receita")
EndIF

//Décima quinta seção
IF AliasINdic('F3O')
	oSection15 := TRSection():New(oReport,"Detalhamento do percentual da exclusão do ICMS a Recolher")
	oSection15:SetHeaderSection(.T.)	
	TRCell():New(oSection15,"CMP1"	,  "","CST")
	TRCell():New(oSection15,"CMP2"	,  "","Regime", "@!", 20)
	TRCell():New(oSection15,"CMP3"	,  "","Tot. Receita","@E 99,999,999,999.99",14)
	TRCell():New(oSection15,"CMP4"	,  "","Receita Suj. ICMS","@E 99,999,999,999.99",14)
	TRCell():New(oSection15,"CMP5"	,  "","Receita Não Suj. ICMS","@E 99,999,999,999.99",14)
	TRCell():New(oSection15,"CMP6"	,  "","Percentual de Ajuste (%)","@E 999.99999999",12)
	TRCell():New(oSection15,"CMP7"	,  "","Método de Rateio","@! ",30)
	oSection15:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
	oSection15:SetHeaderSection(.T.)

	oBreak1 := TRBreak():New(oSection15,{||   },"Totais",.F.,"Totais",.T.) 
	TRFunction():New(oSection15:Cell("CMP3") ,  ,"SUM", oBreak1,"Receita" ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //"Valor "
	TRFunction():New(oSection15:Cell("CMP4") ,  ,"SUM", oBreak1,"Receita Suj. ICMS" ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //"Valor "
	TRFunction():New(oSection15:Cell("CMP5") ,  ,"SUM", oBreak1,"Receita Não Suj. ICMS" ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //"Valor "
	TRFunction():New(oSection15:Cell("CMP6") ,  ,"SUM", oBreak1,"Percentual de Ajuste (%)" ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //"Valor "
EndIF

//Décima sexta seção
IF AliasINdic('F3P')
	oSection16 := TRSection():New(oReport,"Detalhamento da exclusão de base de cálculo do ICMS a Recolher")
	oSection16:SetHeaderSection(.T.)	
	TRCell():New(oSection16,"CMP1"	,  "","CNPJ","@R 99.999.999/9999-99", 20)
	TRCell():New(oSection16,"CMP2"	,  "","CST", "@!", 2)
	TRCell():New(oSection16,"CMP3"	,  "","Regime", "@!", 20)
	TRCell():New(oSection16,"CMP4"	,  "","ICMS Recolher","@E 99,999,999,999.99",14)
	TRCell():New(oSection16,"CMP5"	,  "","Percentual de Ajuste (%)","@E 999.99999999",12)
	TRCell():New(oSection16,"CMP6"	,  "","Parcela do Ajuste a Apropriar na Base de Cálculo","@E 99,999,999,999.99",14)
	oSection16:SetHeaderBreak(.T.) //Imprime cabeçalho das células após quebra
	oSection16:SetHeaderSection(.T.)
	
	oBreak1 := TRBreak():New(oSection16,{|| oSection16:Cell("CMP1"):getvalue() },"Totais",.F.,"Totais",.T.) 	
	TRFunction():New(oSection16:Cell("CMP5") ,  ,"SUM", oBreak1,"Percentual CST (%)" ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //"Valor "
	TRFunction():New(oSection16:Cell("CMP6") ,  ,"SUM", oBreak1,"Parcela do Ajuste a Apropriar na Base de Cálculo" ,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/) //"Valor "

EndIF

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFil
 
Função que irá fazer o mecanismo de seleção de filiais
 
@author Erick G Dias
@since 06/06/2016
@version 11.80
@return aSM0 - Array - Array com as filiais selecionada para processar

/*/
//-------------------------------------------------------------------
Static Function GetFil(lGetFil)

Local aAreaSM0	:= {}
Local aSM0		:= {}
local nFil		:= 0
Local aSelFil	:= {}
Local lIsBlind	:= IsBlind()

Default aAutFilEfd	:= {{.T., cFilAnt}}

aAreaSM0 := SM0->(GetArea())
DbSelectArea("SM0")

IF lGetFil .OR. lIsBlind
	If lIsBlind
		aSelFil:= MatFilCalc( .F., aAutFilEfd )
	Else
		aSelFil	:= MatFilCalc( .T. )
	EndIf
	//--------------------------------------------------------
	//Irá preencher aSM0 somente com as filiais selecionadas
	//pelo cliente  
	//--------------------------------------------------------
	If Len(aSelFil)> 0

		SM0->(DbGoTop())
		If SM0->(MsSeek(cEmpAnt))
			Do While !SM0->(Eof()) 
				nFil := Ascan(aSelFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
				If nFil > 0 .And. aSelFil[nFil][1] .AND. cEmpAnt == SM0->M0_CODIGO
					Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})
				EndIf
				SM0->(dbSkip())
			Enddo
		EndIf
		
		SM0->(RestArea(aAreaSM0))
	EndIF
Else

	Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})

EndIF

Return aSM0

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintF600
 
Função que irá fazer query na tabela CKY para imprimir o detalhamento
das movimentações com retenção na fonte de PIS e COFINS
 
@param dDataDe - Date - Data inicial de processamento
@param dDataAte - Date - Data final de processamento
@param oSecao1 - Objeto - Objeto da seção das retenções
@param oReport - Objeto - Objeto principal do relatório

@author Erick G Dias
@since 06/06/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function PrintCKY(dDataDe, dDataAte,oSecao1,oReport,cAliasQry)

Local cFiltro		:= ''

cFiltro = "%"
cFiltro += "CKY.CKY_FILIAL		= '"	+ xFilial('CKY')				+ "' AND "
cFiltro += "CKY.CKY_PER			>= '" 	+ %Exp:DToS (dDataDe)% 		+ "' AND "
cFiltro += "CKY.CKY_PER			<= '" 	+ %Exp:DToS (dDataAte)% 		+ "' AND "
cFiltro += "CKY.D_E_L_E_T_		= '' "
cFiltro += "%"

oSecao1:BeginQuery()

BeginSql Alias cAliasQry
	COLUMN CKY_DTEMIS AS DATE		
	COLUMN CKY_DTEMIS AS DATE
	SELECT
		CKY.CKY_NUMTIT,CKY.CKY_PREFIX,CKY.CKY_PARC,CKY.CKY_DTEMIS,CKY.CKY_ORIG,;
		CKY.CKY_DTRET,CKY.CKY_CNPJ,CKY.CKY_PISRET,CKY.CKY_COFRET,CKY.CKY_FILIAL
	FROM
		%TABLE:CKY% CKY						
	WHERE
		%Exp:cFiltro%	
	ORDER BY 
		CKY.CKY_DTRET,CKY.CKY_CNPJ, CKY.CKY_NUMTIT
		EndSql

oReport:SetTitle("Retenção na Fonte")
oSecao1:EndQuery()
oReport:SetMeter((cAliasQry)->(LastRec()))
oSecao1:SetHeaderSection(.T.)
oSecao1:SetTitle("Retenção na Fonte")
oSecao1:Print()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintCL2A
 
Função que irá fazer query na tabela CL2 para imprimir o detalhamento
das movimentações com ativo fixo, seja por depreciação ou aquisição,
F120 e F130 respectivamente.
 
@param dDataDe - Date - Data inicial de processamento
@param dDataAte - Date - Data final de processamento
@param oSecao3 - Objeto - Objeto da seção dos créditos com ativo fixo
@param oReport - Objeto - Objeto principal do relatório

@author Erick G Dias
@since 06/06/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function PrintCL2A(dDataDe, dDataAte,oSecao3,oReport,cAliasF1X0)

Local cFiltro	:= ''

cFiltro = "%"
cFiltro += "CL2.Cl2_FILIAL			= '"	+ xFilial('CL2')				+ "' AND "
cFiltro += "CL2.CL2_PER				>= '" 	+ %Exp:DToS (dDataDe)% 		+ "' AND "
cFiltro += "CL2.CL2_PER				<= '" 	+ %Exp:DToS (dDataAte)% 		+ "' AND "
cFiltro += "(CL2.CL2_REG = 'F120' OR CL2.CL2_REG = 'F130' )AND "
cFiltro += "CL2.D_E_L_E_T_		= '' "
cFiltro += "%"	

oSecao3:BeginQuery()

BeginSql Alias cAliasF1X0
	COLUMN CL2_DTOPER AS DATE	
	
	SELECT
		CL2.CL2_CODATF,CL2.CL2_DESATF,CL2.CL2_ITATF,CL2.CL2_CRTCRD,CL2.CL2_CODBCC,;
		CL2.CL2_CSTPIS,CL2.CL2_BCPIS,CL2.CL2_ALQPIS,CL2.CL2_VLPIS,CL2.CL2_CSTCOF,;
		CL2.CL2_BCCOF,CL2.CL2_ALQCOF,CL2.CL2_VLCOF,CL2.Cl2_FILIAL
	FROM
		%TABLE:CL2% CL2
						
	WHERE
		%Exp:cFiltro%	
	ORDER BY 
		CL2.CL2_CRTCRD,CL2.CL2_CODBCC, CL2.CL2_CODATF,CL2.CL2_ITATF,CL2.CL2_CSTPIS
		EndSql

oReport:SetTitle("Crédito de Ativo Fixo")
oSecao3:EndQuery()
oReport:SetMeter((cAliasF1X0)->(LastRec()))
oSecao3:SetHeaderSection(.T.)
oSecao3:SetTitle("Crédito Ativo Fixo")
oSecao3:Print()	

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} PrintCL2T
 
Função que irá fazer query na tabela CL2 para imprimir o detalhamento
das dos títulos financeiros, e movimentações cadastradas na rotina
demais documento
 
@param dDataDe - Date - Data inicial de processamento
@param dDataAte - Date - Data final de processamento
@param oSecao2 - Objeto - Objeto da seção dos títulos/demais documentos
@param oReport - Objeto - Objeto principal do relatório

@author Erick G Dias
@since 06/06/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function PrintCL2T(dDataDe, dDataAte,oSecao2,oReport,cAliasF100)

Local cFiltro	:= ''

cFiltro = "%"
cFiltro += "CL2.Cl2_FILIAL			= '"	+ xFilial('CL2')				+ "' AND "
cFiltro += "CL2.CL2_PER				>= '" 	+ %Exp:DToS (dDataDe)% 		+ "' AND "
cFiltro += "CL2.CL2_PER				<= '" 	+ %Exp:DToS (dDataAte)% 		+ "' AND "
cFiltro += "CL2.CL2_REG = 'F100' AND "
cFiltro += "CL2.D_E_L_E_T_		= '' "
cFiltro += "%"

oSecao2:BeginQuery()

BeginSql Alias cAliasF100
	COLUMN CL2_DTOPER AS DATE	
	
	SELECT
		CL2.CL2_NUMTIT,CL2.CL2_PREFIX,CL2.CL2_PARC,CL2.CL2_IDCF8,CL2.CL2_DTOPER,;
		CL2.CL2_VLOPER,CL2.CL2_REGIME,CL2.CL2_CODBCC,CL2.CL2_CSTPIS,CL2.CL2_BCPIS,;
		CL2.CL2_ALQPIS,CL2.CL2_VLPIS,CL2.CL2_CSTCOF,CL2.CL2_BCCOF,CL2.CL2_ALQCOF,;
		CL2.CL2_VLCOF,CL2.CL2_INDOP,CL2.Cl2_FILIAL
	FROM
		%TABLE:CL2% CL2
						
	WHERE
		%Exp:cFiltro%	
	ORDER BY 
		CL2.CL2_CSTPIS,CL2.CL2_DTOPER, CL2.CL2_NUMTIT, CL2.CL2_IDCF8
		EndSql

oReport:SetTitle("Títulos/Demais Documentos")
oSecao2:EndQuery()
oReport:SetMeter((cAliasF100)->(LastRec()))
oSecao2:SetHeaderSection(.T.)
oSecao2:SetTitle("Títulos/Demais Documentos")
oSecao2:Print()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PrintSFT
 
Função que irá imprimir as movimentações de documento fiscal 
que serão consideradas na apuração da EFD Contribuiçõe. A query e filtro
serão obtidos da classe FISX001, para que mantenha sempre o mesmo filtro
de notas da apuração.
 
@param dDataDe - Date - Data inicial de processamento
@param dDataAte - Date - Data final de processamento
@param oSecao2 - Objeto - Objeto da seção dos títulos/demais documentos
@param oReport - Objeto - Objeto principal do relatório
@param oApurEFD - Objeto - Objeto da classe FISX001, que contém as regras de apuração de PIS e COFINS
@param cEntSai - String - Indica se deverá processar movimentações de entrada ou saída. 1=Entrada, 2=Saida

@author Erick G Dias
@since 06/06/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function PrintSFT(dDataDe, dDataAte,oSecao4,oReport,oApurEFD,cTipoMov, oSecao7, lCPRBNF,cAliasSFT)

Local cFrom			:= ''
Local cSlctSFT		:= ''
Local cFiltro		:= ''
Local cOrdem		:= ''
Local lExibeCanc	:= .T.
Local cCGC			:= ""
Local cNomeCF		:= ""
Local cCC 			:= ""
Local cDescCC 		:= ""
Local cUsuario      := ""

If Valtype(MV_PAR12) =='C'
	If ! Empty(MV_PAR12)
		cOrdem	:= 'ORDER BY '
		Do Case
			Case '01'$MV_PAR12
				cOrdem += ' SFT.FT_CSTPIS, '
			Case '02'$MV_PAR12
				cOrdem += ' SFT.FT_CSTCOF, '
			Case '03'$MV_PAR12
				cOrdem += ' SFT.FT_ALIQPIS, '
			Case '04'$MV_PAR12
				cOrdem += '	SFT.FT_ALIQCOF, '
			Case '05'$MV_PAR12
				cOrdem += '	SFT.FT_CFOP, '
			Case '06'$MV_PAR12
				cOrdem += '	SFT.FT_ATIVCPB, '
		EndCase
		cOrdem += ' SFT.FT_ENTRADA, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_ITEM'
	Else
		cOrdem	:= 'ORDER BY SFT.FT_ENTRADA, SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_ITEM'
	EndIf
EndIf

cFrom				:= oApurEFD:GetJoinFrm(0,.F.,cTipoMov)			
cSlctSFT   			:=	oApurEFD:GetCmpSFT(,.F.,.F.)
cFiltro 			:= oApurEFD:GetWhrSFT(cTipoMov,.T.,.T.)
cFiltro				:= '%'+ cFiltro + '%'		
cOrdem				:= '%'+ cOrdem + '%'

cSlctSFT			:= SUBSTR(cSlctSFT,1,LEN(cSlctSFT)-1)+",SFT.FT_TES,SFT.FT_PRODUTO,SFT.FT_EMISSAO,SFT.FT_CLIEFOR,SFT.FT_LOJA%"

BeginSql Alias cAliasSFT    	
    COLUMN FT_ENTRADA AS DATE
    COLUMN FT_DTCANC AS DATE	
	SELECT			    	 
		%Exp:cSlctSFT%		

	FROM	
		%Exp:cFrom%													
	WHERE
		%Exp:cFiltro%
		SFT.%NotDel% 
		%Exp:cOrdem%
EndSql		

If (cAliasSFT)->(!EOF())
	oSecao4:Init()
	oReport:SetTitle("Notas Fiscais de " + Iif(cTipoMov == NFENTRADA ,'Entrada','Saída'))
EndIf
while (cAliasSFT)->(!EOF())				
	//Verifica se documento deverá ser considerado na impressão do relatório
	If oApurEFD:ChkRegraNf((cAliasSFT)->FT_ESPECIE,(cAliasSFT)->FT_CFOP,cTipoMov)
		
		lExibeCanc	:= .T.
		If cTipoMov == NFSAIDA .AND. !Empty((cAliasSFT)->FT_DTCANC ) .AND. (cAliasSFT)->FT_DTCANC > lastday((cAliasSFT)->FT_ENTRADA)
			//Documento de saída, com data de cancelamento preenchida, porém cancelada em período posterior a sua emissão, não deverá ser exibida como cancelada, pois sua receita será considerada tributada no mês da emissão
			//e terá seu débito estornado na próxima apuração.
			lExibeCanc	:= .F.
		EndIF
				
		oSecao4:Cell("CMP1")			:SetValue((cAliasSFT)->FT_FILIAL)
		oSecao4:Cell("CMP2")			:SetValue((cAliasSFT)->FT_NFISCAL)
		oSecao4:Cell("CMP3")			:SetValue((cAliasSFT)->FT_ENTRADA)
		oSecao4:Cell("CMP4")			:SetValue((cAliasSFT)->FT_ITEM)
		oSecao4:Cell("CMP5")			:SetValue(AmodNOt((cAliasSFT)->FT_ESPECIE))
		oSecao4:Cell("CMP6")			:SetValue((cAliasSFT)->FT_SERIE)
		oSecao4:Cell("CMP7")			:SetValue((cAliasSFT)->FT_CFOP)
		oSecao4:Cell("CMP8")			:SetValue((cAliasSFT)->FT_CODBCC)
		oSecao4:Cell("CMP9")			:SetValue((cAliasSFT)->FT_VALCONT)
		oSecao4:Cell("CMP10")		:SetValue((cAliasSFT)->FT_CSTPIS)			
		oSecao4:Cell("CMP11")		:SetValue((cAliasSFT)->FT_BASEPIS)
		oSecao4:Cell("CMP12")		:SetValue(Iif((cAliasSFT)->FT_MALQPIS > 0,((cAliasSFT)->FT_ALIQPIS - (cAliasSFT)->FT_MALQPIS),(cAliasSFT)->FT_ALIQPIS))
		oSecao4:Cell("CMP13")		:SetValue(Iif((cAliasSFT)->FT_MALQPIS > 0,((cAliasSFT)->FT_VALPIS - (cAliasSFT)->FT_MVALPIS),(cAliasSFT)->FT_VALPIS))
		oSecao4:Cell("CMP14")		:SetValue((cAliasSFT)->FT_CSTCOF)			
		oSecao4:Cell("CMP15")		:SetValue((cAliasSFT)->FT_BASECOF)
		oSecao4:Cell("CMP16")		:SetValue(Iif((cAliasSFT)->FT_MALQCOF > 0,((cAliasSFT)->FT_ALIQCOF - (cAliasSFT)->FT_MALQCOF),(cAliasSFT)->FT_ALIQCOF))
		oSecao4:Cell("CMP17")		:SetValue(Iif((cAliasSFT)->FT_MALQCOF > 0,((cAliasSFT)->FT_VALCOF - (cAliasSFT)->FT_MVALCOF),(cAliasSFT)->FT_VALCOF))
		oSecao4:Cell("CMP18")		:SetValue( Iif( lExibeCanc ,(cAliasSFT)->FT_DTCANC , ctod('  /  /    ') ) )     
		oSecao4:Cell("CMP19")		:SetValue(Iif(cTipoMov == NFENTRADA ,'Entrada','Saída'))
		oSecao4:Cell("CMP20")		:SetValue(Iif(lExibeCanc , (cAliasSFT)->FT_OBSERV , '' )  )
		oSecao4:Cell("CMP21")		:SetValue((cAliasSFT)->FT_TES)
		oSecao4:Cell("CMP22")		:SetValue((cAliasSFT)->FT_PRODUTO)
		oSecao4:Cell("CMP23")		:SetValue(Posicione("SB1",1,xFilial("SB1")+(cAliasSFT)->FT_PRODUTO,"B1_DESC"))
		oSecao4:Cell("CMP24")		:SetValue((cAliasSFT)->FT_EMISSAO)
		oSecao4:Cell("CMP25")		:SetValue((cAliasSFT)->FT_CLIEFOR)
		oSecao4:Cell("CMP26")		:SetValue((cAliasSFT)->FT_LOJA)

		cNomeCF 	:= ""
		cCGC 		:= ""
		cCC 		:= ""
		cDescCC		:= ""

		If cTipoMov == NFENTRADA
			If SA2->(dbSeek(xFilial("SA2")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA,.F.))
				cNomeCF := SA2->A2_NOME
				If Len(AllTrim(SA2->A2_CGC)) > 11											//Se for CNPJ
					cCGC := Transform(SA2->A2_CGC,"@R 99.999.999/9999-99")
				Else 																	//Se for CPF
					cCGC := Transform(SA2->A2_CGC,"@R 999.999.999-99")
				EndIf
			EndIf
		Else
			If SA1->(dbSeek(xFilial("SA1")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA,.F.))
				cNomeCF := SA1->A1_NOME
				If Len(AllTrim(SA1->A1_CGC)) > 11											//Se for CNPJ
					cCGC := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
				Else 																	//Se for CPF
					cCGC := Transform(SA1->A1_CGC,"@R 999.999.999-99")
				EndIf
			EndIf
		EndIf

		oSecao4:Cell("CMP27")		:SetValue(cNomeCF)
		oSecao4:Cell("CMP28")		:SetValue(cCGC)

		cUsuario := ""
		If cTipoMov == NFENTRADA
			// 1- D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
			SD1->(dbSetOrder(1))
			SD1->(dbSeek(xFilial("SD1")+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM),.F.))
			cCC := SD1->D1_CC

			SF1->(dbSetOrder(1))
			IF SF1->(dbSeek(xFilial("SF1")+SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA),.F.))
				cUsuario := SF1->(FWLeUserlg("F1_USERLGI",1))
			ENDIF
		Else
			// 3- D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			SD2->(dbSetOrder(3))			
			SD2->(dbSeek(xFilial("SD2")+(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM),.F.))
			cCC := SD2->D2_CCUSTO

			SF2->(dbSetOrder(2))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSFT)->(FT_CLIEFOR+FT_LOJA+FT_NFISCAL+FT_SERIE)))
				cUsuario := SF2->(FWLeUserlg("F2_USERLGI",1))
			Endif                    

		EndIf
		If !Empty(cCC)
			cDescCC := Posicione("CTT",1,xFilial("CTT")+cCC,"CTT_DESC01")
		EndIf
		oSecao4:Cell("CMP29")		:SetValue(cCC)
		oSecao4:Cell("CMP30")		:SetValue(cDescCC)
		oSecao4:Cell("CMP31")		:SetValue(cUsuario)
		oSecao4:Cell("CMP32")		:SetValue((cAliasSFT)->FT_EMISSAO)

		oSecao4:PrintLine()	
		
	EndIF	
	(cAliasSFT)->(dBskip())
    
EndDo

//If (cAliasSFT)->(!EOF())
	oSecao4:Finish()
//EndIF	

If lCPRBNF .AND. MV_PAR06 == 1
	(cAliasSFT)->(DBGOTOP())
	If (cAliasSFT)->(!EOF())
		oSecao7:Init()
		oReport:SetTitle("CPRB - Notas Fiscais")
	EndIF
	while (cAliasSFT)->(!EOF())
		If Empty((cAliasSFT)->FT_DTCANC) .Or. (cAliasSFT)->FT_DTCANC > lastday((cAliasSFT)->FT_ENTRADA)
			oSecao7:Cell("CMP1"):SetValue((cAliasSFT)->FT_FILIAL)
			oSecao7:Cell("CMP2"):SetValue((cAliasSFT)->FT_NFISCAL)
			oSecao7:Cell("CMP3"):SetValue((cAliasSFT)->FT_SERIE)
			oSecao7:Cell("CMP4"):SetValue((cAliasSFT)->FT_ENTRADA)
			oSecao7:Cell("CMP5"):SetValue((cAliasSFT)->FT_CFOP)
			oSecao7:Cell("CMP6"):SetValue((cAliasSFT)->FT_ITEM)
			oSecao7:Cell("CMP7"):SetValue(AmodNOt((cAliasSFT)->FT_ESPECIE))
			oSecao7:Cell("CMP8"):SetValue((cAliasSFT)->FT_VALCONT)
			oSecao7:Cell("CMP9"):SetValue(IIF((cAliasSFT)->FT_VALCPB>0,(cAliasSFT)->FT_VALCONT,0))
			oSecao7:Cell("CMP10"):SetValue((cAliasSFT)->FT_VALIPI+(cAliasSFT)->FT_ICMSRET)
			oSecao7:Cell("CMP11"):SetValue((cAliasSFT)->FT_ATIVCPB)
			oSecao7:Cell("CMP12"):SetValue((cAliasSFT)->FT_BASECPB)
			oSecao7:Cell("CMP13"):SetValue((cAliasSFT)->FT_ALIQCPB)
			oSecao7:Cell("CMP14"):SetValue((cAliasSFT)->FT_VALCPB)
			oSecao7:PrintLine()
		EndIf
		(cAliasSFT)->(dBskip())
	EndDo
	//If (cAliasSFT)->(!EOF())
		oSecao7:Finish()
	//EndIF
EndIF

oApurEFD:FechaAlias(cAliasSFT)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintSFTC
 
Função que irá imprimir as movimentações de cupom fiscal 
que serão consideradas na apuração da EFD Contribuiçõe. A query e filtro
serão obtidos da função FSA001QECF do FISA001,para que mantenha sempre o mesmo filtro
de cupom fiscal da apuração.
 
@param dDataDe - Date - Data inicial de processamento
@param dDataAte - Date - Data final de processamento
@param oSecao4 - Objeto - Objeto da seção de nota fiscal/cupom
@param oReport - Objeto - Objeto principal do relatório
@param oApurEFD - Objeto - Objeto da classe FISX001, que contém as regras de apuração de PIS e COFINS
@param cAliasSFT - String - Alias que será processada a query com cupom fiscal

@author Erick G Dias
@since 29/08/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function PrintSFTC(dDataDe, dDataAte,oSecao4,oReport,oApurEFD,cAliasSFT)

//Chama função do FISA001 para fazer a query 
cAliasSFT	:= FSA001QECF(.F.,'*',dDataDe,dDataAte)

If (cAliasSFT)->(!EOF())
	oSecao4:Init()
	oReport:SetTitle("Cupom Fiscal")
EndIf

while (cAliasSFT)->(!EOF())				
	//Verifica se documento deverá ser considerado na impressão do relatório	
	oSecao4:Cell("CMP1")			:SetValue((cAliasSFT)->FT_FILIAL) 
	oSecao4:Cell("CMP2")			:SetValue((cAliasSFT)->FT_NFISCAL)
	oSecao4:Cell("CMP3")			:SetValue((cAliasSFT)->FT_ENTRADA) //data
	oSecao4:Cell("CMP4")			:SetValue((cAliasSFT)->FT_ITEM)
	oSecao4:Cell("CMP5")			:SetValue('2D') //Como no arquivo desde 2011 é tratado modelo 2D para cupom, irei manter 2D aqui também.
	oSecao4:Cell("CMP6")			:SetValue((cAliasSFT)->FT_SERIE) 
	oSecao4:Cell("CMP7")			:SetValue((cAliasSFT)->FT_CFOP) 
	oSecao4:Cell("CMP8")			:SetValue('') //Cupom fiscal não tem Codbcc, pois não é operação com direito ao crédito
	oSecao4:Cell("CMP9")			:SetValue((cAliasSFT)->FT_VALCONT) 
	oSecao4:Cell("CMP10")		:SetValue((cAliasSFT)->FT_CSTPIS)  			
	oSecao4:Cell("CMP11")		:SetValue((cAliasSFT)->FT_BASEPIS)
	oSecao4:Cell("CMP12")		:SetValue((cAliasSFT)->FT_ALIQPIS)
	oSecao4:Cell("CMP13")		:SetValue((cAliasSFT)->FT_VALPIS)  
	oSecao4:Cell("CMP14")		:SetValue((cAliasSFT)->FT_CSTCOF)  			
	oSecao4:Cell("CMP15")		:SetValue((cAliasSFT)->FT_BASECOF)
	oSecao4:Cell("CMP16")		:SetValue((cAliasSFT)->FT_ALIQCOF)
	oSecao4:Cell("CMP17")		:SetValue((cAliasSFT)->FT_VALCOF)
	oSecao4:Cell("CMP18")		:SetValue((cAliasSFT)->FT_DTCANC) 
	oSecao4:Cell("CMP19")		:SetValue('Cupom')
	oSecao4:Cell("CMP20")		:SetValue((cAliasSFT)->FT_OBSERV)
	oSecao4:PrintLine()	
		
	(cAliasSFT)->(dBskip())
    
EndDo

oSecao4:Finish()
oApurEFD:FechaAlias(cAliasSFT)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintCL2T
 
Função que irá fazer query na tabela CL2 para imprimir o detalhamento
das dos títulos financeiros, e movimentações cadastradas na rotina
demais documento
 
@param dDataDe - Date - Data inicial de processamento
@param dDataAte - Date - Data final de processamento
@param oSecao2 - Objeto - Objeto da seção dos títulos/demais documentos
@param oReport - Objeto - Objeto principal do relatório

@author Erick G Dias
@since 06/06/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function PrintF0TN(dDataDe, dDataAte,oSecao5,oReport,cAliasF0T)

Local cFiltro	:= ''

cFiltro = "%"
cFiltro += "F0T.F0T_FILIAL			= '"	+ xFilial('F0T')				+ "' AND "
cFiltro += "F0T.F0T_PER				>= '" 	+ %Exp:DToS (dDataDe)% 		+ "' AND "
cFiltro += "F0T.F0T_PER				<= '" 	+ %Exp:DToS (dDataAte)% 		+ "' AND "
cFiltro += "F0T.F0T_TIPO = '1' AND "
cFiltro += "F0T.D_E_L_E_T_		= '' "
cFiltro += "%"

oSecao5:BeginQuery()

BeginSql Alias cAliasF0T
	COLUMN F0T_DTEMI AS DATE	
	COLUMN F0T_DTRECB AS DATE	
	SELECT
		F0T.F0T_FILIAL,F0T.F0T_NUMNF,F0T.F0T_SER,F0T.F0T_DTEMI,F0T.F0T_DTRECB,;
		F0T.F0T_PERREC,F0T.F0T_CFOP,F0T.F0T_ITEM,F0T.F0T_MODELO,F0T.F0T_VLCONT,;
		F0T.F0T_CSTPIS,F0T.F0T_BASPIS,F0T.F0T_ALQPIS,F0T.F0T_VALPIS,F0T.F0T_CSTCOF,;
		F0T.F0T_BASCOF,F0T.F0T_ALQCOF, F0T.F0T_VALCOF 
	FROM
		%TABLE:F0T% F0T
						
	WHERE
		%Exp:cFiltro%	
	ORDER BY 
		F0T.F0T_NUMNF,F0T.F0T_SER, F0T.F0T_ITEM, F0T.F0T_DTRECB
		EndSql

oReport:SetTitle("Nota Fiscal - Regime Caixa")
oSecao5:EndQuery()
oReport:SetMeter((cAliasF0T)->(LastRec()))
oSecao5:SetHeaderSection(.T.)
oSecao5:SetTitle("Nota Fiscal - Regime Caixa")
oSecao5:Print()

Return

Static Function PrintF0TT(dDataDe, dDataAte,oSecao6,oReport,cAliasF0T)

Local cFiltro	:= ''

cFiltro = "%"
cFiltro += "F0T.F0T_FILIAL			= '"	+ xFilial('F0T')				+ "' AND "
cFiltro += "F0T.F0T_PER				>= '" 	+ %Exp:DToS (dDataDe)% 		+ "' AND "
cFiltro += "F0T.F0T_PER				<= '" 	+ %Exp:DToS (dDataAte)% 		+ "' AND "
cFiltro += "F0T.F0T_TIPO = '2' AND "
cFiltro += "F0T.D_E_L_E_T_		= '' "
cFiltro += "%"

oSecao6:BeginQuery()

BeginSql Alias cAliasF0T
	COLUMN F0T_DTEMI AS DATE	
	COLUMN F0T_DTRECB AS DATE	
	SELECT
		F0T.F0T_FILIAL,F0T.F0T_NUMTIT,F0T.F0T_PREFIX,F0T.F0T_PARC,F0T.F0T_DTEMI,;
		F0T.F0T_DTRECB,F0T.F0T_PERREC,F0T.F0T_VLCONT,F0T.F0T_CSTPIS,F0T.F0T_BASPIS,;
		F0T.F0T_ALQPIS,F0T.F0T_VALPIS,F0T.F0T_CSTCOF,F0T.F0T_BASCOF,F0T.F0T_ALQCOF,;
		F0T.F0T_VALCOF 
	FROM
		%TABLE:F0T% F0T
						
	WHERE
		%Exp:cFiltro%	
	ORDER BY 
		F0T.F0T_NUMTIT,F0T.F0T_PREFIX, F0T.F0T_PARC, F0T.F0T_DTRECB
		EndSql

oReport:SetTitle("Título Financeiro - Regime Caixa")
oSecao6:EndQuery()
oReport:SetMeter((cAliasF0T)->(LastRec()))
oSecao6:SetHeaderSection(.T.)
oSecao6:SetTitle("Título Financeiro - Regime Caixa")
oSecao6:Print()

Return

//Informações da CPRB de documento fiscal regime caixa
Static Function PrintF0TC(dDataDe, dDataAte,oSecao7,oReport,cAliasF0T)

Local cFiltro	:= ''

cFiltro = "%"
cFiltro += "F0T.F0T_FILIAL			= '"	+ xFilial('F0T')				+ "' AND "
cFiltro += "F0T.F0T_PER				>= '" 	+ %Exp:DToS (dDataDe)% 		+ "' AND "
cFiltro += "F0T.F0T_PER				<= '" 	+ %Exp:DToS (dDataAte)% 		+ "' AND "
cFiltro += "F0T.F0T_TIPO = '3' AND "
cFiltro += "F0T.D_E_L_E_T_		= '' "
cFiltro += "%"


BeginSql Alias cAliasF0T
	COLUMN F0T_DTEMI AS DATE
	SELECT
		F0T.F0T_FILIAL,F0T.F0T_NUMNF,F0T.F0T_SER,F0T.F0T_DTEMI,F0T.F0T_CFOP,;
		F0T.F0T_ITEM,F0T.F0T_MODELO,F0T.F0T_VLCONT,F0T.F0T_EXCPRB,F0T.F0T_CODATV,;
		F0T.F0T_BCCPRB,F0T.F0T_AQCPRB,F0T.F0T_VLCPRB
	FROM
		%TABLE:F0T% F0T
						
	WHERE
		%Exp:cFiltro%	
	ORDER BY 
		F0T.F0T_DTEMI, F0T.F0T_CODATV,F0T.F0T_NUMNF, F0T.F0T_SER, F0T.F0T_ITEM
		EndSql		
		
If (cAliasF0T)->(!EOF())	
	oSecao7:Init()
	oReport:SetTitle("CPRB Regime Caixa")
EndIF
while (cAliasF0T)->(!EOF())				
	
	oSecao7:Cell("CMP1")			:SetValue((cAliasF0T)->F0T_FILIAL)
	oSecao7:Cell("CMP2")			:SetValue((cAliasF0T)->F0T_NUMNF)
	oSecao7:Cell("CMP3")			:SetValue((cAliasF0T)->F0T_SER)
	oSecao7:Cell("CMP4")			:SetValue((cAliasF0T)->F0T_DTEMI)
	oSecao7:Cell("CMP5")			:SetValue((cAliasF0T)->F0T_CFOP)
	oSecao7:Cell("CMP6")			:SetValue((cAliasF0T)->F0T_ITEM)
	oSecao7:Cell("CMP7")			:SetValue((cAliasF0T)->F0T_MODELO)
	oSecao7:Cell("CMP8")			:SetValue((cAliasF0T)->F0T_VLCONT)
	oSecao7:Cell("CMP9")			:SetValue((cAliasF0T)->F0T_EXCPRB)
	oSecao7:Cell("CMP10")		:SetValue((cAliasF0T)->F0T_CODATV)
	oSecao7:Cell("CMP11")		:SetValue((cAliasF0T)->F0T_BCCPRB)			
	oSecao7:Cell("CMP12")		:SetValue((cAliasF0T)->F0T_AQCPRB)
	oSecao7:Cell("CMP13")		:SetValue((cAliasF0T)->F0T_VLCPRB)

	oSecao7:PrintLine()
		
	(cAliasF0T)->(dBskip())
    
EndDo
//If (cAliasF0T)->(!EOF())	
	oSecao7:Finish()
//EndIF		

DbSelectArea (cAliasF0T)
(cAliasF0T)->(DbCloseArea ())

Return


//Informações da CPRB com integração com Faturamento
Static Function PrintF0TFR(dDataDe, dDataAte,oSecao7,oReport,lCprbRh,cAliasF0T)

Local cFiltro	:= ''

cFiltro = "%"
cFiltro += "F0T.F0T_FILIAL			= '"	+ xFilial('F0T')				+ "' AND "
cFiltro += "F0T.F0T_PER				>= '" 	+ %Exp:DToS (dDataDe)% 		+ "' AND "
cFiltro += "F0T.F0T_PER				<= '" 	+ %Exp:DToS (dDataAte)% 		+ "' AND "	
cFiltro += "F0T.F0T_TIPO = '" + Iif(lCprbRh,"7","6")  +"' AND "
cFiltro += "F0T.D_E_L_E_T_		= '' "
cFiltro += "%"


BeginSql Alias cAliasF0T
	COLUMN F0T_DTEMI AS DATE
	SELECT
		F0T.F0T_FILIAL,F0T.F0T_NUMNF,F0T.F0T_SER,F0T.F0T_DTEMI,F0T.F0T_CFOP,;
		F0T.F0T_ITEM,F0T.F0T_MODELO,F0T.F0T_VLCONT,F0T.F0T_EXCPRB,F0T.F0T_CODATV,;
		F0T.F0T_BCCPRB,F0T.F0T_AQCPRB,F0T.F0T_VLCPRB
	FROM
		%TABLE:F0T% F0T
						
	WHERE
		%Exp:cFiltro%	
	ORDER BY 
		F0T.F0T_DTEMI, F0T.F0T_CODATV,F0T.F0T_NUMNF, F0T.F0T_SER, F0T.F0T_ITEM
		EndSql		
		
If (cAliasF0T)->(!EOF())	
	oSecao7:Init()
	oReport:SetTitle("CPRB Integração com " + Iif(lCprbRh,"Recursos Humanos","Faturamento") )
EndIF
while (cAliasF0T)->(!EOF())				
	
	oSecao7:Cell("CMP1")			:SetValue((cAliasF0T)->F0T_FILIAL)
	oSecao7:Cell("CMP2")			:SetValue((cAliasF0T)->F0T_NUMNF)
	oSecao7:Cell("CMP3")			:SetValue((cAliasF0T)->F0T_SER)
	oSecao7:Cell("CMP4")			:SetValue((cAliasF0T)->F0T_DTEMI)
	oSecao7:Cell("CMP5")			:SetValue((cAliasF0T)->F0T_CFOP)
	oSecao7:Cell("CMP6")			:SetValue((cAliasF0T)->F0T_ITEM)
	oSecao7:Cell("CMP7")			:SetValue((cAliasF0T)->F0T_MODELO)
	oSecao7:Cell("CMP8")			:SetValue((cAliasF0T)->F0T_VLCONT)
	//Alterei os campos 9 ao 14 para ficar igual a definição do relatório, pois haviam alterado CPRB para nota e não alteraram para CPRB do faturamento.
	oSecao7:Cell("CMP9")			:SetValue(Iif((cAliasF0T)->F0T_VLCPRB > 0, (cAliasF0T)->F0T_VLCONT , 0 ))
	oSecao7:Cell("CMP10")			:SetValue((cAliasF0T)->F0T_EXCPRB)
	oSecao7:Cell("CMP11")			:SetValue((cAliasF0T)->F0T_CODATV)
	oSecao7:Cell("CMP12")			:SetValue((cAliasF0T)->F0T_BCCPRB)			
	oSecao7:Cell("CMP13")			:SetValue((cAliasF0T)->F0T_AQCPRB)
	oSecao7:Cell("CMP14")			:SetValue((cAliasF0T)->F0T_VLCPRB)	

	oSecao7:PrintLine()
		
	(cAliasF0T)->(dBskip())
    
EndDo
	
oSecao7:Finish()

DbSelectArea (cAliasF0T)
(cAliasF0T)->(DbCloseArea ())

Return


Static Function PrintF0TDP(dDataDe, dDataAte,oSecao8,oReport,cAliasF0T)

Local cFiltro	:= ''
Local cSelect	:= ''

cSelect	:= "F0T.F0T_FILIAL,F0T.F0T_NUMNF,F0T.F0T_SER,F0T.F0T_DTEMI,F0T.F0T_ITEM,"
cSelect	+= "F0T.F0T_NUMTIT,F0T.F0T_PREFIX,F0T.F0T_PARC,F0T.F0T_IDCF8,F0T.F0T_VLCONT,"
cSelect	+= "F0T.F0T_RECDIF,F0T.F0T_VALPIS,F0T.F0T_VALCOF,F0T.F0T_VALREC"

If F0T->(FieldPos("F0T_CNPJ")) > 0
	cSelect	+= ", F0T.F0T_CNPJ"
EndIF	

cFiltro = "%"
cFiltro += "F0T.F0T_FILIAL			= '"	+ xFilial('F0T')				+ "' AND "
cFiltro += "F0T.F0T_PER				>= '" 	+ %Exp:DToS (dDataDe)% 		+ "' AND "
cFiltro += "F0T.F0T_PER				<= '" 	+ %Exp:DToS (dDataAte)% 		+ "' AND "	
cFiltro += "F0T.F0T_TIPO = '4' AND "
cFiltro += "F0T.D_E_L_E_T_		= '' "
cFiltro += "%"

cSelect	:= "%" + cSelect + "%"

oSecao8:BeginQuery()

BeginSql Alias cAliasF0T
	COLUMN F0T_DTEMI AS DATE	
	
	SELECT			    	 
		%Exp:cSelect%		
	FROM
		%TABLE:F0T% F0T
						
	WHERE
		%Exp:cFiltro%	
	ORDER BY 
		F0T.F0T_DTEMI, F0T.F0T_NUMNF,F0T.F0T_NUMTIT, F0T.F0T_IDCF8
		EndSql

oReport:SetTitle("Diferimento da Contribuição do Período Atual")
oSecao8:EndQuery()
oReport:SetMeter((cAliasF0T)->(LastRec()))
oSecao8:SetHeaderSection(.T.)
oSecao8:SetTitle("Diferimento da Contribuição do Período Atual")
oSecao8:Print()


Return

Static Function PrintF0TDA(dDataDe, dDataAte,oSecao9,oReport,cAliasF0T)

Local cFiltro	:= ''
Local cSelect	:= ''

cSelect	:= "F0T.F0T_FILIAL,F0T.F0T_NUMNF,F0T.F0T_SER,F0T.F0T_DTEMI,F0T.F0T_ITEM,"
cSelect	+= "F0T.F0T_NUMTIT,F0T.F0T_PREFIX,F0T.F0T_PARC,F0T.F0T_IDCF8,F0T.F0T_DTRECB,"
cSelect	+= "F0T.F0T_VALREC,F0T.F0T_VALPIS,F0T.F0T_VALCOF"

If F0T->(FieldPos("F0T_CNPJ")) > 0
	cSelect	+= ", F0T.F0T_CNPJ"
EndIF

cSelect	:= "%" + cSelect + "%"

cFiltro = "%"
cFiltro += "F0T.F0T_FILIAL			= '"	+ xFilial('F0T')				+ "' AND "
cFiltro += "F0T.F0T_PER				>= '" 	+ %Exp:DToS (dDataDe)% 		+ "' AND "
cFiltro += "F0T.F0T_PER				<= '" 	+ %Exp:DToS (dDataAte)% 		+ "' AND "	
cFiltro += "F0T.F0T_TIPO = '5' AND "
cFiltro += "F0T.D_E_L_E_T_		= '' "
cFiltro += "%"

oSecao9:BeginQuery()

BeginSql Alias cAliasF0T
	COLUMN F0T_DTEMI AS DATE	
	COLUMN F0T_DTRECB AS DATE
	
	SELECT			    	 
		%Exp:cSelect%	
	
	FROM
		%TABLE:F0T% F0T
						
	WHERE
		%Exp:cFiltro%	
	ORDER BY 
		F0T.F0T_DTEMI, F0T.F0T_NUMNF,F0T.F0T_NUMTIT, F0T.F0T_IDCF8
		EndSql

oReport:SetTitle("Diferimento da Contribuição de Período Anterior")
oSecao9:EndQuery()
oReport:SetMeter((cAliasF0T)->(LastRec()))
oSecao9:SetHeaderSection(.T.)
oSecao9:SetTitle("Diferimento da Contribuição de Período Anterior")
oSecao9:Print()

Return


Static Function PrintF0TI(dDataDe, dDataAte,oSecao11,oReport,cAliasF0T)

Local cFiltro	:= ''

cFiltro = "%"
cFiltro += "F0T.F0T_FILIAL			= '"	+ xFilial('F0T')				+ "' AND "
cFiltro += "F0T.F0T_PER				>= '" 	+ %Exp:DToS (dDataDe)% 		+ "' AND "
cFiltro += "F0T.F0T_PER				<= '" 	+ %Exp:DToS (dDataAte)% 		+ "' AND "	
cFiltro += "F0T.F0T_TIPO = '8' AND "
cFiltro += "F0T.D_E_L_E_T_		= '' "
cFiltro += "%"

oSecao11:BeginQuery()

BeginSql Alias cAliasF0T
	
	SELECT
		F0T.F0T_FILIAL,;
		F0T.F0T_NUMTIT,F0T.F0T_PREFIX,F0T.F0T_PARC,F0T.F0T_VLCONT,F0T.F0T_IFEXCL,;
		F0T.F0T_CDBLCI,F0T.F0T_CSTPIS,F0T.F0T_CSTCOF		
	FROM
		%TABLE:F0T% F0T
						
	WHERE
		%Exp:cFiltro%	
	ORDER BY 
		F0T.F0T_CDBLCI,F0T.F0T_NUMNF,F0T.F0T_NUMTIT 
		EndSql

oReport:SetTitle("Títulos Instituição Financeira")
oSecao11:EndQuery()
oReport:SetMeter((cAliasF0T)->(LastRec()))
oSecao11:SetHeaderSection(.T.)
oSecao11:SetTitle("Títulos Instituição Financeira")
oSecao11:Print()

Return


Static Function PrintF3J(dDataDe, dDataAte,oSecao14,oReport,cAliasF3J)

Local cFiltro	:= ''

cFiltro = "%"
cFiltro += "F3J.F3J_FILIAL			= '"	+ xFilial('F3J')				+ "' AND "
cFiltro += "F3J.F3J_PER				>= '" 	+ %Exp:DToS (dDataDe)% 		    + "' AND "
cFiltro += "F3J.F3J_PER				<= '" 	+ %Exp:DToS (dDataAte)% 		+ "' AND "

cFiltro += "F3J.D_E_L_E_T_		= '' "
cFiltro += "%"

oSecao14:BeginQuery()

BeginSql Alias cAliasF3J
	
	SELECT
		F3J.F3J_FILIAL,;
		F3J.F3J_CODREC,F3J.F3J_VLTRIB,F3J.F3J_TRIBUT  ,F3J.F3J_TOTPAG,F3J.F3J_CODPAG,F3J.F3J_PERCEN				
	FROM
		%TABLE:F3J% F3J
						
	WHERE
		%Exp:cFiltro%	
	ORDER BY 
		F3J.F3J_TRIBUT,F3J.F3J_CODREC 
		EndSql

oReport:SetTitle("Detalhamento dos valores acumulados conforme regras do código de receita")
oSecao14:EndQuery()
oReport:SetMeter((cAliasF3J)->(LastRec()))
oSecao14:SetHeaderSection(.T.)
oSecao14:SetTitle("Detalhamento dos valores acumulados conforme regras do código de receita")
oSecao14:Print()

Return

Static Function PrintCF4(dDataDe, dDataAte,oSecao10,oReport,cAliasCF4)

Local cFiltro	:= ''
Local cDtAlt		:= 	SubStr(DTos(dDataDe),5,2)+SubStr(Dtos(dDataDe),1,4)

cFiltro = "%"
cFiltro += "CF4.CF4_FILIAL		= '"	+ xFilial("CF4")				+ "' AND "
cFiltro += "CF4.CF4_FLORIG		= '"	+ xFilial("SFT")				+ "' AND "
cFiltro += "CF4.CF4_DTALT		= '" + %Exp:cDtAlt% + "' AND "
cFiltro += "CF4.CF4_TIPO 		= 'D' AND "
cFiltro += "CF4.D_E_L_E_T_		= '' "
cFiltro += "%"

BeginSql Alias cAliasCF4	
	COLUMN CF4_DATAE AS DATE	
	
	SELECT
		CF4.CF4_FILIAL,CF4.CF4_NOTA,CF4.CF4_SERIE,CF4.CF4_ITEM,CF4.CF4_TIPMOV,CF4.CF4_DATAE,;
		CF4.CF4_VALPIS,CF4.CF4_VALCOF,CF4.CF4_BASPIS,CF4.CF4_BASCOF,CF4.CF4_TIPO,CF4.CF4_FLORIG
	FROM
		%TABLE:CF4% CF4
						
	WHERE
		%Exp:cFiltro%	
	ORDER BY 
		CF4.CF4_TIPMOV,CF4.CF4_TIPO,CF4.CF4_NOTA, CF4.CF4_SERIE,CF4.CF4_ITEM 
		EndSql

If (cAliasCF4)->(!EOF())
	oSecao10:Init()
	oReport:SetTitle("Devoluções Período Atual")
EndIf 
while (cAliasCF4)->(!EOF())
		
	oSecao10:Cell("CMP1")		:SetValue((cAliasCF4)->CF4_FLORIG)	
	oSecao10:Cell("CMP2")		:SetValue(Iif( (cAliasCF4)->CF4_TIPO == 'S' ,'Dev. Compra','Dev. Venda'))
	oSecao10:Cell("CMP3")		:SetValue((cAliasCF4)->CF4_NOTA)
	oSecao10:Cell("CMP4")		:SetValue((cAliasCF4)->CF4_SERIE)
	oSecao10:Cell("CMP5")		:SetValue((cAliasCF4)->CF4_ITEM)
	oSecao10:Cell("CMP6")		:SetValue((cAliasCF4)->CF4_DATAE)
	oSecao10:Cell("CMP7")		:SetValue((cAliasCF4)->CF4_BASPIS)
	oSecao10:Cell("CMP8")		:SetValue((cAliasCF4)->CF4_VALPIS)
	oSecao10:Cell("CMP9")		:SetValue((cAliasCF4)->CF4_BASCOF)
	oSecao10:Cell("CMP10")		:SetValue((cAliasCF4)->CF4_VALCOF)

	oSecao10:PrintLine()
		
	(cAliasCF4)->(dBskip())
    
EndDo

oSecao10:Finish()

DbSelectArea (cAliasCF4)
(cAliasCF4)->(DbCloseArea ())

Return

Static Function CheckDif(lAtual,lAnt,dDataDe)

Local cChave	:= xFilial('CKS')+dTos(dDataDe)+'1'

dbSelectArea('CKS')
CKS->(dbSetOrder(2))
If CKS->(MSSEEK(xFilial('CKS')+dTos(dDataDe)))

	While CKS->(!EOF()) .AND. CKS->CKS_FILIAL+DTOS(CKS->CKS_PER)+CKS->CKS_TRIB == cChave
		
		If CKS->CKS_DIF > 0
			lAtual	:= .T.
		EndIF

		If CKS->CKS_DIFANT > 0
			lAnt	:= .T.
		EndIF		
		
		If lAtual .AND. lAnt
			Exit
		EndIF
		
		CKS->(dBskip())
	EndDo

EndIF
	

Return

Static Function PrintCFA(dDataDe, dDataAte,oSecao12,oReport,cAliasCFA)

Local cFiltro	:= ''
Local cPerApu	:=Substr(DTOS(dDataDe),5,2)+Substr(DTOS(dDataDe),1,4)

cFiltro = "%"
cFiltro += "CFA.CFA_FILIAL			= '"	+ xFilial('CFA')		+ "' AND "
cFiltro += "CFA.CFA_PERAPU			= '" 	+ %Exp:cPerApu% 		+ "' AND "
cFiltro += "CFA.D_E_L_E_T_			= ' ' "
cFiltro += "%"

oSecao12:BeginQuery()

BeginSql Alias cAliasCFA
	
	SELECT
		CFA.CFA_FILIAL,CFA.CFA_CNPJ,CFA.CFA_CODCRE,CFA.CFA_CREDIF,CASE WHEN CFA.CFA_TPCON = 'PIS' THEN '1=PIS' ELSE '2=COFINS' END AS CFA_TPCON
	FROM
		%TABLE:CFA% CFA
						
	WHERE
		%Exp:cFiltro%	
	ORDER BY 
		CFA_TPCON,CFA.CFA_CODCRE,CFA.CFA_CNPJ 
		EndSql

oReport:SetTitle("Créditos Diferidos no Período")
oSecao12:EndQuery()
oReport:SetMeter((cAliasCFA)->(LastRec()))
oSecao12:SetHeaderSection(.T.)
oSecao12:SetTitle("Créditos Diferidos no Período")
oSecao12:Print()

Return

Static Function PrintF0TA(dDataDe, dDataAte,oSecao13,oReport,cAliasF0TA)

Local cFiltro	:= ''
Local cSelect	:= ''

cSelect	:= "F0T.F0T_FILIAL,	F0T.F0T_NUMTIT,F0T.F0T_PREFIX, F0T.F0T_PARC,    F0T.F0T_IDCF8,  F0T.F0T_PERREC, F0T.F0T_VALCOF, F0T.F0T_DTRECB, F0T.F0T_VLCONT, F0T.F0T_VALREC,"
cSelect	+= "F0T.F0T_DTEMI,	F0T.F0T_MODELO, F0T.F0T_BASPIS, F0T.F0T_VALPIS, F0T.F0T_BASCOF, F0T.F0T_VALCOF, CASE WHEN F0T_TIPO = 'A' THEN '1=PIS' ELSE '2=COFINS' END AS F0T_TIPO"

If F0T->(FieldPos("F0T_CNPJ")) > 0
	cSelect	+= ", F0T.F0T_CNPJ"
EndIF	

cSelect	:= "%" + cSelect + "%"

cFiltro = "%"
cFiltro += "F0T.F0T_FILIAL			= '"	+ xFilial('F0T')				+ "' AND "
cFiltro += "F0T.F0T_PER				>= '" 	+ %Exp:DToS (dDataDe)% 		+ "' AND "
cFiltro += "F0T.F0T_PER				<= '" 	+ %Exp:DToS (dDataAte)% 		+ "' AND "	
cFiltro += "F0T.F0T_TIPO IN ('A','B') AND "
cFiltro += "F0T.D_E_L_E_T_		= ' ' "
cFiltro += "%"

oSecao13:BeginQuery()

BeginSql Alias cAliasF0TA
	SELECT			    	 
		%Exp:cSelect%	
	
	FROM
		%TABLE:F0T% F0T
						
	WHERE
		%Exp:cFiltro%	
	ORDER BY 
		F0T_TIPO,F0T_NUMTIT,F0T_DTEMI,F0T_MODELO, F0T_IDCF8
		EndSql

oReport:SetTitle("Créditos a Descontar Vinculados a Contribuição Diferida de Período Anterior")
oSecao13:EndQuery()
oReport:SetMeter((cAliasF0TA)->(LastRec()))
oSecao13:SetHeaderSection(.T.)
oSecao13:SetTitle("Créditos a Descontar Vinculados a Contribuição Diferida de Período Anterior")
oSecao13:Print()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetQuebra

Possibilita quebra e totalização do relatório pelas seguintes opções 
selecionadas no pergunte SX1:
CST PIS, CST COFINS, alíquota PIS, alíquota COFINS, CFOP, 
código de atividade (CPRB)
 
@author Vogas Júnior
@since 17/08/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------

Static Function SetQuebra(oSecao, cQuebra, cSecao)

Local oRetorno 	
Local cQbrCSTP  := ''
Local cQbrCSTC  := ''
Local cQbrAliqP := ''
Local cQbrAliqC := ''
Local cQbrCFOP	:= ''
Local cQbrCodAtv:= ''

If Valtype(MV_PAR12) =='C'
	If '01'$MV_PAR12
		cQbrCSTP	:= 'CMP10'	// Quebra por CST PIS
	EndIf
	If '02'$MV_PAR12
		cQbrCSTC	:= 'CMP14'	// Quebra por CST COFINS
	EndIf
	If '03'$MV_PAR12
		cQbrAliqP	:= 'CMP12'	// Quebra por Alíquota de PIS 
	EndIf
	If '04'$MV_PAR12
		cQbrAliqC	:= 'CMP16'	// Quebra por Alíquota de Cofins
	EndIf
	If '05'$MV_PAR12
		cQbrCFOP	:= 'CMP7'	// Quebra por CFOP
	EndIf
	If '06'$MV_PAR12
		cQbrCodAtv	:= 'CMP11'	// Quebra por Código de atividade (CPRB)
	EndIf
EndIf

Do Case 
	Case cSecao == '4'
		If Empty(cQbrCSTP) .And. Empty(cQbrCSTC).And. Empty(cQbrAliqP) .And. Empty(cQbrAliqC) .And. Empty(cQbrCFOP)
			oRetorno := TRBreak():New(oSecao,oSecao:Cell(cQuebra),"Totalizadores",.F.,'Totalizadores',.T.)
		Else
			oRetorno := TRBreak():New(oSecao,{|| oSecao:Cell(cQuebra):getvalue()+	Iif(!Empty(cQbrCSTP),oSecao:Cell(cQbrCSTP):getvalue(),'')+;
																						Iif(!Empty(cQbrCSTC),oSecao:Cell(cQbrCSTC):getvalue(),'')+;
																						Iif(!Empty(cQbrAliqP),AllTrim(STR(oSecao:Cell(cQbrAliqP):getvalue())),'')+;
																						Iif(!Empty(cQbrAliqC),AllTrim(STR(oSecao:Cell(cQbrAliqC):getvalue())),'')+;																						
																						Iif(!Empty(cQbrCFOP),oSecao:Cell(cQbrCFOP):getvalue(),'')},"Totalizadores",.F.,"Totalizadores",.T.)
		EndIf
	Case cSecao == '7'
		If Empty(cQbrCodAtv)
			oRetorno := TRBreak():New(oSecao,oSecao:Cell(cQuebra),"Totalizadores",.F.,"Totalizadores",.T.)
		Else
			oRetorno := TRBreak():New(oSecao,{||oSecao:Cell(cQuebra):getvalue() + oSecao:Cell(cQbrCodAtv):getvalue()},"Totalizadores",.F.,"Totalizadores",.T.)	
		EndIf
EndCase

Return oRetorno

/*
Static Function AjustaSX1()
Local aPergunte := {} 
Aadd(aPergunte,{'FSR101','12', 'Subdividir NFs por?', 'Subdividir NFs por?', 'Subdividir NFs por?', 'MV_CHC', 'C', 99, 0, 0, 'R', '', 'SK', '', '', 'MV_PAR12', '', '', '', 'X5_CHAVE', '', '', '', '', '', '', '', '', '', '', '', '','','','','','.FSR10112.'})
If FindFunction('EngSX1117') 
	EngSX1117(aPergunte[1,1],aPergunte[1,2],aPergunte[1,3],aPergunte[1,4],aPergunte[1,5],aPergunte[1,6],aPergunte[1,7],aPergunte[1,8],aPergunte[1,9],aPergunte[1,10],aPergunte[1,11],aPergunte[1,12],aPergunte[1,13],aPergunte[1,14],aPergunte[1,15],aPergunte[1,16],aPergunte[1,17],aPergunte[1,18],aPergunte[1,19],aPergunte[1,20],aPergunte[1,21],aPergunte[1,22],aPergunte[1,23],aPergunte[1,24],aPergunte[1,25],aPergunte[1,26],aPergunte[1,27],aPergunte[1,28],aPergunte[1,29],aPergunte[1,30],aPergunte[1,31],aPergunte[1,32],aPergunte[1,33],aPergunte[1,34],aPergunte[1,35],aPergunte[1,36])
EndIf
Return
*/

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintF3O

Função que imprimirá as informações da seção que detalha os valores
sujeitos ao ICMS por CST.
 
@author Erick G Dias
@since 17/12/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function PrintF3O(dDataDe, oSecao15,oReport,cAliasF3O)

Local cFiltro		:= ''
Local nTotRec		:= 0
Local nSujICMS		:= 0
Local nNSujICMS		:= 0

cFiltro = "%"
cFiltro += "F3O.F3O_FILIAL	= "	+ ValToSQL(xFilial("F3O"))	+ " AND "
cFiltro += "F3O.F3O_PER	= "	+ valToSql(dDataDe) + " AND "
cFiltro += "F3O.D_E_L_E_T_		= ' ' "
cFiltro += "%"

BeginSql Alias cAliasF3O
	
	SELECT
		F3O.F3O_CST ,F3O.F3O_RECBA ,F3O.F3O_RECBC ,F3O.F3O_RECBD ,F3O.F3O_RECBF ,F3O.F3O_RECBCD,;
		F3O.F3O_TOTREC, F3O.F3O_PERCD,  F3O.F3O_REGIME, F3O.F3O_METODO
	FROM
		%TABLE:F3O% F3O
						
	WHERE
		%Exp:cFiltro%	
	ORDER BY 
		F3O.F3O_CST, F3O.F3O_REGIME
		EndSql

If (cAliasF3O)->(!EOF())
	oSecao15:Init()
	oReport:SetTitle("Percentuais de exclusão do ICMS a Recolher")		
	oReport:SetTitle("Percentuais de exclusão do ICMS a Recolher")
EndIF

while (cAliasF3O)->(!EOF())	

	nTotRec		:= (cAliasF3O)->F3O_RECBA + (cAliasF3O)->F3O_RECBC + (cAliasF3O)->F3O_RECBD + (cAliasF3O)->F3O_RECBF
	nSujICMS	:= (cAliasF3O)->F3O_RECBC + (cAliasF3O)->F3O_RECBD
	nNSujICMS	:= (cAliasF3O)->F3O_RECBA + (cAliasF3O)->F3O_RECBF

	oSecao15:Cell("CMP1")		:SetValue((cAliasF3O)->F3O_CST)	 	//CST
	oSecao15:Cell("CMP2")		:SetValue(Iif((cAliasF3O)->F3O_REGIME == '1','Não Cumulativo','Cumulativo'))	//Regime
	oSecao15:Cell("CMP3")		:SetValue(nTotRec)					//Total das Receitas
	oSecao15:Cell("CMP4")		:SetValue(nSujICMS) 				//Receitas sujeitas ao ICMS, soma das receitas dos blocos C e D
	oSecao15:Cell("CMP5")		:SetValue(nNSujICMS) 				//Receitas Não sujeitas so ICMS
	oSecao15:Cell("CMP6")		:SetValue((cAliasF3O)->F3O_PERCD) 	//Percentual das receitas sujeitas ao ICMS
	oSecao15:Cell("CMP7")		:SetValue(Iif((cAliasF3O)->F3O_METODO == '1','Total da Receita','Receita Sujeita ao ICMS')) 	//Percentual das receitas sujeitas ao ICMS
	
	oSecao15:PrintLine()
	(cAliasF3O)->(dBskip())
EndDo

oSecao15:Finish()

DbSelectArea (cAliasF3O)
(cAliasF3O)->(DbCloseArea ())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintF3P

Função que imprimirá o detalhamento dos valores de redução da base de 
cálculo referente a exclusão do ICMS a Recolher, mediante a ação judicial
 
@author Erick G Dias
@since 17/12/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function PrintF3P(dDataDe, oSecao16,oReport,cAliasF3P)

Local cFiltro	:= ''

cFiltro = "%"
cFiltro += "F3P.F3P_FILIAL	= "	+ ValToSQL(xFilial("F3P"))	+ " AND "
cFiltro += "F3P.F3P_PER  = " + valToSql(dDataDe) + " AND "
cFiltro += "F3P.D_E_L_E_T_		= ' ' "
cFiltro += "%"

BeginSql Alias cAliasF3P
	
	SELECT
		F3P.F3P_FILIAL ,F3P.F3P_CST01 ,F3P.F3P_CST02 ,F3P.F3P_CST03 ,F3P.F3P_CST04 ,F3P.F3P_CST05,;
		F3P.F3P_CST06 ,F3P.F3P_CST07 ,F3P.F3P_CST08 ,F3P.F3P_CST09 ,F3P.F3P_CST49 ,F3P.F3P_CST99, ;
		F3P.F3P_VALICM, F3P.F3P_CNPJ, F3P.F3P_REGIME
	FROM
		%TABLE:F3P% F3P				
						
	WHERE
		%Exp:cFiltro%	
	ORDER BY 
		F3P.F3P_CNPJ, F3P.F3P_REGIME
		EndSql

If (cAliasF3P)->(!EOF())
	oSecao16:Init()
	oSecao16:SetTitle("Detalhamento da Exclusão do ICMS a Recolher")
	oReport:SetTitle("Detalhamento da Exclusão do ICMS a Recolher")
EndIF

while (cAliasF3P)->(!EOF())

	//Imprimindo valores por CST	
	PrintF3PCST(oSecao16, (cAliasF3P)->F3P_CNPJ, '01', (cAliasF3P)->F3P_VALICM, dDataDe, (cAliasF3P)->F3P_CST01, (cAliasF3P)->F3P_REGIME)
	PrintF3PCST(oSecao16, (cAliasF3P)->F3P_CNPJ, '02', (cAliasF3P)->F3P_VALICM, dDataDe, (cAliasF3P)->F3P_CST02, (cAliasF3P)->F3P_REGIME)
	PrintF3PCST(oSecao16, (cAliasF3P)->F3P_CNPJ, '03', (cAliasF3P)->F3P_VALICM, dDataDe, (cAliasF3P)->F3P_CST03, (cAliasF3P)->F3P_REGIME)
	PrintF3PCST(oSecao16, (cAliasF3P)->F3P_CNPJ, '04', (cAliasF3P)->F3P_VALICM, dDataDe, (cAliasF3P)->F3P_CST04, (cAliasF3P)->F3P_REGIME)
	PrintF3PCST(oSecao16, (cAliasF3P)->F3P_CNPJ, '05', (cAliasF3P)->F3P_VALICM, dDataDe, (cAliasF3P)->F3P_CST05, (cAliasF3P)->F3P_REGIME)
	PrintF3PCST(oSecao16, (cAliasF3P)->F3P_CNPJ, '06', (cAliasF3P)->F3P_VALICM, dDataDe, (cAliasF3P)->F3P_CST06, (cAliasF3P)->F3P_REGIME)
	PrintF3PCST(oSecao16, (cAliasF3P)->F3P_CNPJ, '07', (cAliasF3P)->F3P_VALICM, dDataDe, (cAliasF3P)->F3P_CST07, (cAliasF3P)->F3P_REGIME)
	PrintF3PCST(oSecao16, (cAliasF3P)->F3P_CNPJ, '08', (cAliasF3P)->F3P_VALICM, dDataDe, (cAliasF3P)->F3P_CST08, (cAliasF3P)->F3P_REGIME)
	PrintF3PCST(oSecao16, (cAliasF3P)->F3P_CNPJ, '09', (cAliasF3P)->F3P_VALICM, dDataDe, (cAliasF3P)->F3P_CST09, (cAliasF3P)->F3P_REGIME)
	PrintF3PCST(oSecao16, (cAliasF3P)->F3P_CNPJ, '49', (cAliasF3P)->F3P_VALICM, dDataDe, (cAliasF3P)->F3P_CST49, (cAliasF3P)->F3P_REGIME)	
	PrintF3PCST(oSecao16, (cAliasF3P)->F3P_CNPJ, '99', (cAliasF3P)->F3P_VALICM, dDataDe, (cAliasF3P)->F3P_CST99, (cAliasF3P)->F3P_REGIME)		
	
	(cAliasF3P)->(dBskip())
EndDo

oSecao16:Finish()

DbSelectArea (cAliasF3P)
(cAliasF3P)->(DbCloseArea ())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintF3PCST

Função auxiliar para impressão da seção com detalhamento dos valores 
de redução de base de cálculo por CST
 
@author Erick G Dias
@since 17/12/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------
Static Function PrintF3PCST(oSecao16, cCnpj, cCST, nICMS, dDataDe, nValAju, cRegime)

Local nPerCST	:= 0

IF nValAju > 0

	//Busca percentual de rateio das receitas dos blocos C e D.
	If F3O->(MSSEEK(xFilial('F3O')+dTos(dDataDe)+cCST+cRegime))
		nPerCST	:= F3O->F3O_PERCD
	EndIF

	oSecao16:Cell("CMP1")		:SetValue(cCnpj) //CNPJ do estabelecimento
	oSecao16:Cell("CMP2")		:SetValue(cCST)	//CST
	oSecao16:Cell("CMP3")		:SetValue(Iif(cRegime == '1', 'Não Cumulativo','Cumulativo')) //Regime
	oSecao16:Cell("CMP4")		:SetValue(nICMS) //ICMS a Recolher
	oSecao16:Cell("CMP5")		:SetValue(nPerCST) //TODO : Percentual de Ajuste do CST
	oSecao16:Cell("CMP6")		:SetValue(nValAju) //Valor do Ajsute de redução de basePercentual das receitas sujeitas ao ICMS
	oSecao16:PrintLine()

Endif

Return