#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
 
/*/{Protheus.doc} BKFINR19()
BK - Relatório de Notas Fiscais por contrato
v20/08/15b
@author Marcos Bispo Abrahão
@since 29/03/20
@version P12
@return Nil
/*/


User Function BKFINR19()

Private cTitulo     := "Notas fiscais por contrato/competencia:"
Private cPerg       := "BKFINR19"

Private cCCusto     := ""
Private cCompet1    := "04/2015"
Private nDtEmis     := 1
Private dDataI      := DATE()
Private dDataF      := DATE()

Private cCompet     := "042015"
Private cCompet2    := ""
Private cCompet3    := ""
Private cMesComp    := "04"
Private cAnoComp    := "2015"
Private cMes2       := ""
Private cMes3       := ""
Private nMes2       := 0
Private nMes3       := 0
Private cAno2       := ""
Private cAno3       := ""
Private nAno2       := 0
Private nAno3       := 0
Private aPlans      := {}
Private aCampos     := {}
Private aCabs       := {}
Private aTitulos    := {}

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

cCCusto  := mv_par01
cCompet1 := mv_par02
nDtEmis  := mv_par03
dDataI   := mv_par04
dDataF   := mv_par05
cCompet  := SUBSTR(cCompet1,1,2)+"/"+SUBSTR(cCompet1,3,4)

cMesComp := SUBSTR(cCompet1,1,2)
cAnoComp := SUBSTR(cCompet1,3,4)
cMes     := cAnoComp+cMesComp

nMes2    := VAL(cMesComp)
nAno2    := VAL(cAnoComp)
nMes2    := nMes2 - 1
If nMes2 = 0
   nMes2 := 12
   nAno2 := nAno2 - 1
EndIf

nMes3    := nMes2 - 1
nAno3    := nAno2
If nMes3 = 0
   nMes3 := 12
   nAno3 := nAno3 - 1
EndIf

cCompet2 := STRZERO(nMes2,2)+"/"+STR(nAno2,4)
cCompet3 := STRZERO(nMes3,2)+"/"+STR(nAno3,4)
cMes2    := "Emissao de "+STRZERO(nMes2,2)+"/"+STR(nAno2,4)
cMes3    := "Emissao de "+STRZERO(nMes3,2)+"/"+STR(nAno3,4)

If !EMPTY(cCCusto)
   cTitulo += "  centro de custos "+TRIM(cCCusto)+"-"+TRIM(Posicione("CTT",1, xFilial("CTT")+cCCusto,"CTT_DESC01"))
EndIf

If !EMPTY(cCompet)
   cTitulo += "  competencia de "+TRANSFORM(cCompet,"@R 99/9999")
EndIf

If nDtEmis == 1 .AND. !EMPTY(dDataI) .AND. !EMPTY(dDataF)
   cTitulo += "  emissao entre "+DTOC(dDataI)+" e "+DTOC(dDataF)
EndIf


Processa( {|| ProcQuery() })
  
Return


Static Function ProcQuery
Local cQuery := ""

IncProc("Consultando o banco de dados...")

cQuery := " SELECT DISTINCT"
cQuery += "  CNF_CONTRA AS CONTRATO,"
cQuery += "  CNF_COMPET AS COMPETENCIA,"
cQuery += "  CTT_DESC01 AS NOME,"
cQuery += "  'Não' AS NF_AVULSA,"
cQuery += "  CNA_NUMERO AS PLANILHA,"
cQuery += "  F2_DOC,F2_EMISSAO,CNF_VLPREV,"
cQuery += "  (SELECT COUNT(*) FROM "+RETSQLNAME("CND")+" CND WHERE CND_CONTRA = CNF_CONTRA AND CND_REVISA = CNF_REVISA AND CND_COMPET = CNF_COMPET AND CNA_NUMERO = CND_NUMERO AND CND_PARCEL = CNF_PARCEL AND CND_FILIAL = '"+xFilial("CND")+"' AND CND.D_E_L_E_T_ = ' ') AS QTDMED,"
cQuery += "  F2_VALFAT,F2_XXENVNF,F2_XXENDOC,F2_XXOBSFA,F2_XXUSFAT,F2_USERLGI AS QTMP_USERLGI, " 
cQuery += "  (SELECT TOP 1 CNR_DESCRI FROM "+RETSQLNAME("CNR")+" CNR WHERE CNR_NUMMED = CND_NUMMED AND  CNR_FILIAL = '"+xFilial("CNR")+"' AND  CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '2') AS MOTGLOSA, "
cQuery += "  (SELECT TOP 1 CNR_DESCRI FROM "+RETSQLNAME("CNR")+" CNR WHERE CNR_NUMMED = CND_NUMMED AND  CNR_FILIAL = '"+xFilial("CNR")+"' AND  CNR.D_E_L_E_T_ = ' ' AND CNR_TIPO = '1') AS MOTBONIF, "


cQuery += "  (SELECT TOP 1 F2_EMISSAO FROM "+RETSQLNAME("CNF")+" CNF1"

cQuery += "      INNER JOIN "+RETSQLNAME("CN9")+ " CN91 ON CN91.CN9_NUMERO = CNF1.CNF_CONTRA AND CN91.CN9_REVISA = CNF1.CNF_REVISA AND CN91.CN9_SITUAC NOT IN ('01','02','08','09','10') "
cQuery += "            AND  CN91.CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN91.D_E_L_E_T_ = ' '"
cQuery += "       LEFT JOIN "+RETSQLNAME("CNA")+ " CNA1 ON CNA1.CNA_CRONOG = CNF1.CNF_NUMERO AND CNA1.CNA_REVISA = CNF1.CNF_REVISA"
cQuery += "            AND  CNA1.CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA1.D_E_L_E_T_ = ' '"
cQuery += "       LEFT JOIN "+RETSQLNAME("CND")+ " CND1 ON CND1.CND_CONTRA = CNF1.CNF_CONTRA AND CND1.CND_COMPET = CNF1.CNF_COMPET AND CNA1.CNA_NUMERO = CND1.CND_NUMERO AND CND1.CND_PARCEL = CNF1.CNF_PARCEL AND CND1.CND_REVISA = CNA1.CNA_REVISA"
cQuery += "            AND  CND1.CND_FILIAL = '"+xFilial("CND")+"' AND  CND1.D_E_L_E_T_ = ' '"
cQuery += "       LEFT JOIN "+RETSQLNAME("SC6")+ " SC61 ON CND1.CND_PEDIDO = SC61.C6_NUM"
cQuery += "            AND  SC61.C6_FILIAL = '"+xFilial("SC6")+"'  AND  SC61.D_E_L_E_T_ = ' '"
cQuery += "       LEFT JOIN "+RETSQLNAME("SF2")+ " SF21 ON SC61.C6_SERIE = SF21.F2_SERIE AND SC61.C6_NOTA = SF21.F2_DOC"
cQuery += "            AND  SF21.F2_FILIAL = '"+xFilial("SF2")+"'  AND  SF21.D_E_L_E_T_ = ' '"
cQuery += "       WHERE CNF1.CNF_COMPET = '"+cCompet2+"'"
cQuery += "            AND  CNF1.CNF_CONTRA = CNF.CNF_CONTRA AND CNF1.CNF_REVISA = CNF.CNF_REVISA "
cQuery += "            AND  CNA1.CNA_NUMERO = CNA.CNA_NUMERO "
cQuery += "            AND  CNF1.CNF_FILIAL = '"+xFilial("CNF")+"' AND  CNF1.D_E_L_E_T_ = ' '"
If !EMPTY(cCCusto)
	cQuery += "        AND CNF1.CNF_CONTRA = '"+cCCusto+"'"
EndIf
cQuery += "        ) AS MES2,"

cQuery += "    (SELECT TOP 1 F2_EMISSAO FROM "+RETSQLNAME("CNF")+" CNF1"

cQuery += "      INNER JOIN "+RETSQLNAME("CN9")+ " CN91 ON CN91.CN9_NUMERO = CNF1.CNF_CONTRA AND CN91.CN9_REVISA = CNF1.CNF_REVISA AND CN91.CN9_SITUAC NOT IN ('01','02','08','09','10') "
cQuery += "            AND  CN91.CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN91.D_E_L_E_T_ = ' '"
cQuery += "      LEFT JOIN "+RETSQLNAME("CNA")+ " CNA1 ON CNA1.CNA_CRONOG = CNF1.CNF_NUMERO AND CNA1.CNA_REVISA = CNF1.CNF_REVISA"
cQuery += "            AND  CNA1.CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA1.D_E_L_E_T_ = ' '"
cQuery += "      LEFT JOIN "+RETSQLNAME("CND")+ " CND1 ON CND1.CND_CONTRA = CNF1.CNF_CONTRA AND CND1.CND_COMPET = CNF1.CNF_COMPET AND CNA1.CNA_NUMERO = CND1.CND_NUMERO AND CND1.CND_PARCEL = CNF1.CNF_PARCEL AND CND1.CND_REVISA = CNA1.CNA_REVISA"
cQuery += "            AND  CND1.CND_FILIAL = '"+xFilial("CND")+"' AND  CND1.D_E_L_E_T_ = ' '"
cQuery += "       LEFT JOIN "+RETSQLNAME("SC6")+ " SC61 ON CND1.CND_PEDIDO = SC61.C6_NUM"
cQuery += "            AND  SC61.C6_FILIAL = '"+xFilial("SC6")+"'  AND  SC61.D_E_L_E_T_ = ' '"
cQuery += "       LEFT JOIN "+RETSQLNAME("SF2")+ " SF21 ON SC61.C6_SERIE = SF21.F2_SERIE AND SC61.C6_NOTA = SF21.F2_DOC"
cQuery += "            AND  SF21.F2_FILIAL = '"+xFilial("SF2")+"'  AND  SF21.D_E_L_E_T_ = ' '"
cQuery += "       WHERE CNF1.CNF_COMPET = '"+cCompet3+"'"
cQuery += "            AND  CNF1.CNF_CONTRA = CNF.CNF_CONTRA AND CNF1.CNF_REVISA = CNF.CNF_REVISA "
cQuery += "            AND  CNA1.CNA_NUMERO = CNA.CNA_NUMERO "
cQuery += "            AND  CNF1.CNF_FILIAL = '"+xFilial("CNF")+"' AND  CNF1.D_E_L_E_T_ = ' '"
If !EMPTY(cCCusto)
	cQuery += "        AND CNF1.CNF_CONTRA = '"+cCCusto+"'"
EndIf
cQuery += "     ) AS MES3"


cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"

cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9.CN9_SITUAC NOT IN ('01','02','08','09','10') "
cQuery += "      AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CONTRA = CNF_CONTRA AND CNA_REVISA = CNF_REVISA AND CNA_CRONOG = CNF_NUMERO"
cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_REVISA = CNF_REVISA AND CND_COMPET = CNF_COMPET AND CNA_NUMERO = CND_NUMERO AND CND_PARCEL = CNF_PARCEL"
cQuery += "      AND  CND_FILIAL = '"+xFilial("CND")+"' AND  CND.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM"
cQuery += "      AND  C6_FILIAL = '"+xFilial("SC6")+"'  AND  SC6.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+ " SF2 ON C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC"
cQuery += "      AND  F2_FILIAL = '"+xFilial("SF2")+"'  AND  SF2.D_E_L_E_T_ = ' '"

If nDtEmis == 1 .AND. !EMPTY(dDataI) .AND. !EMPTY(dDataF)
	cQuery += " WHERE ( CNF_COMPET = '"+cCompet+"' OR ( SF2.F2_EMISSAO >= '"+DTOS(dDataI)+"' AND SF2.F2_EMISSAO <= '"+DTOS(dDataF)+"') )"
Else
	cQuery += " WHERE CNF_COMPET = '"+cCompet+"'"
EndIf


cQuery += "      AND  CNF_FILIAL = '"+xFilial("CNF")+"' AND  CNF.D_E_L_E_T_ = ' '"
If !EMPTY(cCCusto)
	cQuery += "  AND CNF_CONTRA = '"+cCCusto+"'
EndIf

cQuery += " UNION ALL "
cQuery += " SELECT "
cQuery += "   C5_ESPECI1 AS CONTRATO ,"
cQuery += "   SUBSTRING(C5_XXCOMPT,1,2)+'/'+SUBSTRING(C5_XXCOMPT,3,4) AS COMPETENCIA," 
cQuery += "   A1_NOME AS NOME, "  // CTT_DESC01
cQuery += "   'Sim' AS NF_AVULSA,"
cQuery += "   ' '   AS PLANILHA,"
cQuery += "   F2_DOC,F2_EMISSAO,0 AS CNF_VLPREV,0 AS QTDMED,F2_VALFAT,F2_XXENVNF,F2_XXENDOC,F2_XXOBSFA,F2_XXUSFAT,F2_USERLGI AS QTMP_USERLGI,' ' AS MOTGLOSA,' ' AS MOTBONIF,' ' AS MES2,' ' AS MES3"

cQuery += " FROM "+RETSQLNAME("SF2")+" SF2"
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA"
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC"
cQuery += "      AND  C6_FILIAL = '"+xFilial("SC6")+"'  AND  SC6.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON C5_NUM = C6_NUM"
cQuery += "      AND  C5_FILIAL = '"+xFilial("SC5")+"'  AND  SC5.D_E_L_E_T_ = ' '"
cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_PEDIDO = C6_NUM"
cQuery += "      AND  CND_FILIAL = '"+xFilial("CND")+"'  AND  CND.D_E_L_E_T_ = ' '"

cQuery += " WHERE CND_CONTRA IS NULL"
cQuery += "      AND F2_FILIAL = '"+xFilial("SF2")+"' AND SF2.D_E_L_E_T_ = ' '"

//If !EMPTY(cCompet1)
//	cQuery += "  AND ( (C5_XXCOMPT = '"+cCompet1+"') OR (C5_XXCOMPT = '' AND SUBSTRING(F2_EMISSAO,1,6) = '"+cMes+"') )"
//EndIf

If nDtEmis == 1 .AND. !EMPTY(dDataI) .AND. !EMPTY(dDataF)
	cQuery += "  AND ( (C5_XXCOMPT = '"+cCompet1+"') OR ( SF2.F2_EMISSAO >= '"+DTOS(dDataI)+"' AND SF2.F2_EMISSAO <= '"+DTOS(dDataF)+"') )"
Else
	cQuery += "  AND ( (C5_XXCOMPT = '"+cCompet1+"') OR (C5_XXCOMPT = '' AND SUBSTRING(F2_EMISSAO,1,6) = '"+cMes+"') )"
EndIf



If !EMPTY(cCCusto)
	cQuery += "  AND C5_ESPECI1 = '"+cCCusto+"'
EndIf

cQuery += " ORDER BY CONTRATO,F2_DOC"  



Memowrite("BKFINR19.SQL", cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","F2_EMISSAO","D",8,0)
TCSETFIELD("QTMP","MES2","D",8,0)
TCSETFIELD("QTMP","MES3","D",8,0)


//U_QryToXml("QTMP","BKFINR19",cTitulo,.T.)

AADD(aCampos,"QTMP->CONTRATO")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QTMP->COMPETENCIA")
AADD(aCabs  ,"Competencia")

AADD(aCampos,"QTMP->NOME")
AADD(aCabs  ,"Descrição")

AADD(aCampos,"QTMP->NF_AVULSA")
AADD(aCabs  ,"NF Avulsa")

AADD(aCampos,"QTMP->PLANILHA")
AADD(aCabs  ,"Planilha")

AADD(aCampos,"QTMP->QTDMED")
AADD(aCabs  ,"Qtd. Medições")

AADD(aCampos,"QTMP->F2_DOC")
AADD(aCabs  ,RetTitle("F2_DOC"))

AADD(aCampos,"QTMP->F2_EMISSAO")
AADD(aCabs  ,RetTitle("F2_EMISSAO"))

AADD(aCampos,"QTMP->F2_VALFAT")
AADD(aCabs  ,RetTitle("F2_VALFAT"))

AADD(aCampos,"IIF(QTMP->QTDMED <= 1,QTMP->CNF_VLPREV,QTMP->CNF_VLPREV / QTMP->QTDMED)")
AADD(aCabs  ,RetTitle("CNF_VLPREV"))

AADD(aCampos,"QTMP->MES2")
AADD(aCabs  ,cMes2)

AADD(aCampos,"QTMP->MES3")
AADD(aCabs  ,cMes3)

AADD(aCampos,"QTMP->MOTGLOSA")
AADD(aCabs  ,"Motivo glosa")

AADD(aCampos,"QTMP->MOTBONIF")
AADD(aCabs  ,"Motivo bonif.")

AADD(aCampos,"QTMP->F2_XXENVNF")
AADD(aCabs  ,RetTitle("F2_XXENVNF"))

AADD(aCampos,"QTMP->F2_XXENDOC")
AADD(aCabs  ,RetTitle("F2_XXENDOC"))

AADD(aCampos,"QTMP->F2_XXOBSFA")
AADD(aCabs  ,RetTitle("F2_XXOBSFA"))

AADD(aCampos,"QTMP->F2_XXUSFAT")
AADD(aCabs  ,RetTitle("F2_XXUSFAT"))

AADD(aCampos,"Capital(QTMP->(FWLeUserlg('QTMP_USERLGI',1)))")
AADD(aCabs  ,"Faturista")

AADD(aPlans,{"QTMP",cPerg,"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
MsAguarde({|| U_GeraXml(aPlans,cTitulo,cPerg,.F.)},"Aguarde","Gerando planilha...",.F.)

Return





Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Centro de Custo:"              ,"","","mv_ch1","C",09,0,0,"G","                                                            ","mv_par01","   ","   ","   ","","","   ","   ","   ","","","","","","","","","","","","","","","","","CTT","S","","","          "})
AADD(aRegistros,{cPerg,"02","Competencia:"                  ,"","","mv_ch2","C",06,0,0,"G","                                                            ","mv_par02","   ","   ","   ","","","   ","   ","   ","","","","","","","","","","","","","","","","","   ","S","","","@R 99/9999"})
AADD(aRegistros,{cPerg,"03","Considerar filtro por emissao?","","","mv_ch3","N",01,0,2,"C","IIF(MV_PAR03==2,CTOD('')=(MV_PAR05:=MV_PAR04:=CTOD('')),.T.)","mv_par03","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","   ","S","","","          "})
AADD(aRegistros,{cPerg,"04","Emissao de:"                   ,"","","mv_ch4","D",08,0,0,"G","IIF(MV_PAR03==2,MV_PAR04 == CTOD(''),MV_PAR04 <> CTOD(''))  ","mv_par04","   ","   ","   ","","","   ","   ","   ","","","","","","","","","","","","","","","","","   ","S","","","          "})
AADD(aRegistros,{cPerg,"05","Emissão até:"                  ,"","","mv_ch5","D",08,0,0,"G","IIF(MV_PAR03==2,MV_PAR05 == CTOD(''),MV_PAR05 <> CTOD(''))  ","mv_par05","   ","   ","   ","","","   ","   ","   ","","","","","","","","","","","","","","","","","   ","S","","","          "})

For i:=1 to Len(aRegistros)
	If !dbSeek(cPerg+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegistros[i])
				FieldPut(j,aRegistros[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(aArea)

Return(NIL)
