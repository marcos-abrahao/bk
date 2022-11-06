//#INCLUDE "FISR050.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "REPORT.CH"

#DEFINE STR0001 "APURACAO DE IMPOSTOS RETIDOS POR NATUREZA"
#DEFINE STR0002 "BK - FUNCAO PARA CRIACAO DE RELATORIO DE APURACAO DE IMPOSTOS RETIDOS POR NATUREZA"
#DEFINE STR0003 "PREFIXO DO TÍTULO"
#DEFINE STR0004 "PREFIXO DO TÍTULO"
#DEFINE STR0005 "TIPO"
#DEFINE STR0006 "CODIGO DO FORNECEDOR"
#DEFINE STR0007 "RAZÃO SOCIAL"
#DEFINE STR0008 "CNPJ"
#DEFINE STR0009 "EMISSAO"
#DEFINE STR0010 "VENCIMENTO"
#DEFINE STR0011 "VENCIMENTO REAL"
#DEFINE STR0012 "VALOR BRUTO"
#DEFINE STR0013 "BASE"
#DEFINE STR0014 "ALIQUOTA"
#DEFINE STR0015 "IMPOSTO"
#DEFINE STR0016 "NATUREZA"
#DEFINE STR0017 "TOTAIS"
#DEFINE STR0018 "Aguarde, Gerando Relatório...."
#DEFINE STR0019 "PARCELA"


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISR050()

FUNCAO PARA CRIACAO DE RELATORIO DE APURACAO DE IMPOSTOS RETIDOS POR NATUREZA
  
@author    Robson de Souza Moura
@version   12.1.3
@since     01/04/2015

/*/
//------------------------------------------------------------------------------------------
User Function XFISR050()        

Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

Private oReport := Nil
Private oSecCab := Nil 

u_MsgLog("XFISR050")

If lVerpesssen
	ReportDef()
	oReport:PrintDialog()
EndIf
        
Return Nil   

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISR050()

REPORTDEF() - Definições do Relatório  

@author    Robson de Souza Moura
@version   12.1.3
@since     01/04/2015

/*/
//------------------------------------------------------------------------------------------
Static Function ReportDef()

Pergunte( "FISR050" , .F. ) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01     // Natureza Inicial                             ³
//³ mv_par02     // Natureza Final                               ³
//³ mv_par03     // Data Vencimento Inicial                      ³
//³ mv_par04     // Data Vencimento Final                        ³
//³ mv_par05     // Imprime Abertos/Baixados/Ambos               ³
//³ mv_par06     // Ordem de Impressao Por Titulo / Data Emissao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SE2") 

oReport := TReport():New("FISR050",STR0001,"FISR050",{|oReport| PrintReport(oReport)},STR0002)

oReport:SetUseGC(.T.) 

oSection := TRSection():New(oReport,STR0001,{"TMP","SE2","SM0","SA2","SF1"}) 

oReport:SetLandscape() 

TRCell():New(oSection,"E2_NUM"      ,"TMP",STR0003)//PREFIXO DO TÍTULO
TRCell():New(oSection,"E2_PREFIXO"  ,"TMP",STR0004)//PREFIXO DO TÍTULO
TRCell():New(oSection,"E2_PARCELA"  ,"TMP",STR0019)//Parcela
TRCell():New(oSection,"E2_TIPO"     ,"TMP",STR0005)//TIPO
TRCell():New(oSection,"A2_COD"      ,"TMP",STR0006)//CODIGO DO FORNECEDOR
TRCell():New(oSection,"A2_NOME"     ,"TMP",STR0007)//RAZÃO SOCIAL
TRCell():New(oSection,"A2_CGC"      ,"TMP",STR0008)//CNPJ
TRCell():New(oSection,"E2_EMISSAO"  ,"TMP",STR0009)//EMISSAO
TRCell():New(oSection,"E2_VENCTO"   ,"TMP",STR0010)//VENCIMENTO
TRCell():New(oSection,"E2_VENCREA"  ,"TMP",STR0011)//VENCIMENTO REAL
TRCell():New(oSection,"F1_VALBRUT"  ,"TMP",STR0012)//VALOR BRUTO
TRCell():New(oSection,"TMP_BASE"	,"TMP",STR0013, "@E 99,999,999,999.99",,,,"CENTER",,"CENTER")//BASE 
TRCell():New(oSection,"TMP_ALIQ"    ,"TMP",STR0014)//ALIQUOTA
TRCell():New(oSection,"E2_VALOR"    ,"TMP",STR0015)//IMPOSTO
TRCell():New(oSection,"E2_NATUREZ"  ,"TMP",STR0016)//NATUREZA

TRFunction():New(oSection:Cell("E2_VALOR"),/*cId*/,"SUM"     ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.           ,.T.           ,.F.        ,oSecCab)  

Return oReport 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FISR050()
IMPRESSÃO  
@author    Robson de Souza Moura
@version   12.1.3
@since     01/04/2015
/*/
//------------------------------------------------------------------------------------------
Static Function PrintReport(oReport)

Local oSection  := oReport:Section(1)
Local cQuery    := ""
Local nPrefixo  := TamSx3("E2_PREFIXO")[1]
Local nNumTit   := TamSx3("E2_NUM")[1]
Local nTipo     := TamSx3("E2_TIPO")[1]
Local nParcela  := TamSx3("E2_PARCELA")[1]
Local nFornece  := TamSx3("E2_FORNECE")[1]
Local nLoja     := TamSx3("E2_LOJA")[1]
Local aStruSE2  := SE2->(dbStruct()) 
Local nX        := 0
Local cFitro    := oSection:GetSqlExp()
//Local cTipoDB	:= AllTrim(Upper(TcGetDb()))
Local cNatPis   := SuperGetMV("MV_PISNAT",,"PIS")
Local cNatCof   := SuperGetMV("MV_COFINS",,"COFINS")
Local cNatCsl   := SuperGetMV("MV_CSLL",,"CSLL")

dbSelectArea("SE2") 

//³ Quebra de secoes e totalizadores do Relatorio ³

oBreak01 := TRBreak():New(oSection,oSection:Cell("E2_NATUREZ"),STR0017,.F.)
TRFunction():New(oSection:Cell("E2_VALOR"),"TOTNAT","SUM",oBreak01,/*Titulo*/,/*cPicture*/,/*uFormula*/,.F.,.F.)

TRPosition():New(oSection,"SA2",1,{|| xFilial("SA1") + TMP->A2_COD + TMP->A2_LOJA})
TRPosition():New(oSection,"SF1",1,{|| xFilial("SF1") + TMP->F1_DOC + TMP->F1_SERIE + TMP->F1_FORNECE + TMP->F1_LOJA })
	
cQuery := " SELECT SE2.E2_NUM,SE2.E2_PREFIXO,SE2.E2_PARCELA,SE2.E2_TIPO,SE2.E2_FORNECE,SE2.E2_EMISSAO,SE2.E2_VENCTO,SE2.E2_VENCREA,SE2.E2_VALOR,F1_EMISSAO,F1_VALBRUT,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,A2_NOME,A2_CGC,A2_COD,SE2.E2_NATUREZ,A2_LOJA, "  
cQuery += " CASE  WHEN SE2.E2_TIPO = 'INS' AND SUM(FT_BASEINS) > 0 THEN ROUND((SUM(FT_VALINS) * 100) / SUM(FT_BASEINS),2)"
cQuery += " WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + cNatPis + "' THEN ROUND((SUM(FT_VRETPIS) * 100) / SUM(FT_BRETPIS),2) "
cQuery += " WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + cNatCof + "' THEN ROUND((SUM(FT_VRETCOF) * 100) / SUM(FT_BRETCOF),2) "
cQuery += " WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + cNatCsl + "' THEN ROUND((SUM(FT_VRETCSL) * 100) / SUM(FT_BRETCSL),2) "
cQuery += " WHEN (SE2.E2_VALOR >= F1_VALBRUT) THEN  0 ELSE  ((SE2.E2_VALOR * 100)/F1_VALBRUT) END AS TMP_ALIQ, "
cQuery += " CASE  WHEN SE2.E2_TIPO = 'INS' THEN SUM(FT_BASEINS) "
cQuery += " WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + cNatPis + "' THEN SUM(FT_BRETPIS) "
cQuery += " WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + cNatCof + "' THEN SUM(FT_BRETCOF) "
cQuery += " WHEN SE2.E2_TIPO = 'TX' AND SE2.E2_NATUREZ = '" + cNatCsl + "' THEN SUM(FT_BRETCSL) "
cQuery += " ELSE F1_VALBRUT END AS TMP_BASE "
cQuery += " FROM " + RetSqlName("SE2")+ " SE2 "

cQuery += " INNER JOIN " + RetSqlname("SA2")+ " SA2 ON SA2.A2_FILIAL = '" + xFilial("SA2") + "'  AND SA2.A2_COD||SA2.A2_LOJA = SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+nNumTit+nTipo+nParcela+1))+","+Alltrim(Str(nFornece+nLoja))+") AND SA2.D_E_L_E_T_=' ' " 
cQuery += " LEFT JOIN  " + RetSqlname("SF1")+ " SF1 ON SF1.F1_FILIAL = '" + xFilial("SF1") + "'  AND SF1.F1_DOC = SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+1))+","+Alltrim(Str(nNumTit))+") AND SF1.F1_FORNECE||SF1.F1_LOJA = SUBSTRING(SE2.E2_TITPAI,"+Alltrim(Str(nPrefixo+nNumTit+nTipo+nParcela+1))+","+Alltrim(Str(nFornece+nLoja))+") AND SF1.F1_EMISSAO = SE2.E2_EMISSAO AND SF1.D_E_L_E_T_=' ' "
CqUERY += " LEFT JOIN  " + RetSqlname("SE2")+ " SE2A ON SE2A.E2_FILIAL = '" + xFilial("SE2") + "' AND SE2A.E2_PREFIXO||SE2A.E2_NUM||SE2A.E2_PARCELA||SE2A.E2_TIPO||SE2A.E2_FORNECE||SE2A.E2_LOJA = SE2.E2_TITPAI AND SE2A.D_E_L_E_T_ = ' '	
cQuery += " LEFT JOIN " + RetSqlname("SFT")+ " SFT ON SFT.FT_FILIAL = '" + xFilial("SFT") + "'  AND SFT.FT_NFISCAL = SE2A.E2_NUM AND SFT.FT_CLIEFOR = SE2A.E2_FORNECE AND SFT.FT_LOJA = SE2A.E2_LOJA AND SFT.D_E_L_E_T_ = ' ' " 

If MV_PAR05     == 1 
    cQuery += " WHERE SE2.E2_FILIAL='" +xFilial("SE2")+ "' AND SE2.E2_NATUREZ BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND SE2.E2_VENCTO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND SE2.E2_BAIXA=' ' AND   SE2.D_E_L_E_T_=' ' "   
ElseIf MV_PAR05 == 2
	cQuery += " WHERE SE2.E2_FILIAL='" +xFilial("SE2")+ "' AND SE2.E2_NATUREZ BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND SE2.E2_VENCTO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND SE2.E2_BAIXA <>' ' AND SE2.D_E_L_E_T_=' ' "
ElseIf MV_PAR05 == 3 
    cQuery += " WHERE SE2.E2_FILIAL='" +xFilial("SE2")+ "' AND SE2.E2_NATUREZ BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' AND SE2.E2_VENCTO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' AND SE2.D_E_L_E_T_=' ' "       
Endif
If !Empty(cFitro)
	cQuery += " AND " + cFitro
EndIf
cQuery += " GROUP BY SE2.E2_NUM,SE2.E2_PREFIXO,SE2.E2_PARCELA,SE2.E2_TIPO,SE2.E2_FORNECE,SE2.E2_EMISSAO,SE2.E2_VENCTO,SE2.E2_VENCREA,SE2.E2_VALOR,F1_EMISSAO,F1_VALBRUT,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,A2_NOME,A2_CGC,A2_COD,SE2.E2_NATUREZ,A2_LOJA"
If MV_PAR06  == 1
	cQuery += " ORDER BY SE2.E2_NATUREZ,SE2.E2_NUM "
ElseIf MV_PAR06 == 2
	cQuery += " ORDER BY SE2.E2_NATUREZ,SE2.E2_EMISSAO "
Endif

cQuery := ChangeQuery(cQuery) 

u_LogMemo("c",cQuery)

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TMP",.T.,.T.) //"Seleccionado registros"

For nX := 1 To len(aStruSE2)
		If aStruSE2[nX][2] <> "C" .And. FieldPos(aStruSE2[nX][1])<>0
			TcSetField("TMP",aStruSE2[nX][1],aStruSE2[nX][2],aStruSE2[nX][3],aStruSE2[nX][4])
		EndIf
Next nX

oSection:Cell("TMP_BASE"):SetSize(oSection:Cell("F1_VALBRUT"):getSize())

oReport:SetMeter(RecCount())

DbSelectArea("TMP")

ProcRegua(0)

While !TMP->(Eof())

	IncProc(STR0018) //"Aguarde, Gerando Relatório...."
	
	If oReport:Cancel()
		Exit
	EndIf	
	 
   	oSection:Init() 	
	oSection:PrintLine() 
	
	oSection:Cell("E2_NUM")	    :Show()
	oSection:Cell("E2_PREFIXO")	:Show()
	oSection:Cell("E2_PARCELA")	:Show()
	oSection:Cell("E2_TIPO")	:Show()
	oSection:Cell("A2_COD")     :Show()
	oSection:Cell("A2_NOME")	:Show()
	oSection:Cell("A2_CGC") 	:Show()
	oSection:Cell("E2_EMISSAO")	:Show()
	oSection:Cell("E2_VENCTO") 	:Show()
	oSection:Cell("E2_VENCREA")	:Show()
  	oSection:Cell("F1_VALBRUT")	:Show() 
	oSection:Cell("TMP_BASE")	:Show()
	oSection:Cell("TMP_ALIQ")   :Show()	
	oSection:Cell("E2_VALOR")	:Show()
	oSection:Cell("E2_NATUREZ")	:Show()

	TMP->(DbSkip())
Enddo         

oSection:Finish()
oReport:SkipLine()
oReport:IncMeter()
TMP->(dbCloseArea())

Return()

