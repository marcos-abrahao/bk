#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} BKCTBR01
Barcas Rio - Relatório de Lançamentos Contábeis por periodo 

@Return
@author Marcos Bispo Abrahão
@since 10/04/2025
@version P12
/*/

User Function BKCTBR01()
Local cDescr 	:= "O objetivo deste relatório é gerar a exportação da contabilidade."
Local cVersao	:= "10/04/2025 - Versão inicial"
Local oRExcel	AS Object
Local oPExcel	AS Object
Local cAlias    := "QTMP"

Private aParam 	:= {}
Private cTitulo := "Lançamentos Contábeis por periodo - Barcas Rio"

Private cProg 	:= "BKCTBR01"
Private	dDtIni  := dDataBase - Day(dDataBase) + 1
Private dDtFim  := LastDay(dDataBase)
Private cDtIni  := STR(YEAR(dDtIni),4)+"-"+STRZERO(MONTH(dDtIni),2)+"-"+STRZERO(DAY(dDtIni),2)
Private cDtFim  := STR(YEAR(dDtFim),4)+"-"+STRZERO(MONTH(dDtFim),2)+"-"+STRZERO(DAY(dDtFim),2)

// Log de Versões
//cVersao += CRLF + "XX/XX/XXXX - "

aAdd( aParam, { 1, "Data Inicial:" 	, dDtIni , ""    , "", ""	, "" , 70  , .T. })
aAdd( aParam, { 1, "Data Final:" 	, dDtFim , ""    , "", ""	, "" , 70  , .F. })

If !BkPar()
	Return Nil
EndIf

// Execução da Query
u_WaitLog(cProg, {|| PCTBR01() })

// Definição do Arq Excel
oRExcel := RExcel():New(cProg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetSolicit("31/03/2025: Jackquesfran Ferreira - Barcas Rio")
oRExcel:SetVersao(cVersao)
oRExcel:SetDescr(cDescr)
oRExcel:SetParam(aParam)

// Definição da Planilha 1
oPExcel:= PExcel():New(cProg,cAlias)
oPExcel:SetTitulo("")

// Colunas da Planilha 1

oPExcel:AddCol("BRANCOS","Space(1)","Brancos","")
oPExcel:GetCol("BRANCOS"):SetTitulo("AD_IDEXTERNO")

oPExcel:AddCol("CC","QTMP->CC","CODCENCUS","CT1_DESC01")

oPExcel:AddCol("CODCTACTB","QTMP->CONTA","CODCTACTB","CT1_CONTA")
oPExcel:GetCol("CODCTACTB"):SetTamCol(20)

oPExcel:AddCol("CODEMP","TRIM('331')","CODEMP","")
oPExcel:GetCol("CODEMP"):SetHAlign("C")

oPExcel:AddCol("CODUSU","TRIM('0')","CODUSU","")
oPExcel:GetCol("CODUSU"):SetHAlign("C")

oPExcel:AddCol("DTMOV","cDtFim","DTMOV","")
oPExcel:GetCol("DTMOV"):SetHAlign("C")

oPExcel:AddCol("LIBERADO","TRIM('S')","LIBERADO","")
oPExcel:GetCol("LIBERADO"):SetHAlign("C")

oPExcel:AddCol("NUMLANC","TRIM('1')","NUMLANC","")
oPExcel:GetCol("NUMLANC"):SetHAlign("C")

oPExcel:AddCol("NUMLOTE","TRIM('920')","NUMLOTE","")
oPExcel:GetCol("NUMLOTE"):SetHAlign("C")

oPExcel:AddCol("REFERENCIA","cDtIni","REFERENCIA","")
oPExcel:GetCol("REFERENCIA"):SetHAlign("C")

oPExcel:AddCol("SEQUENCIA","QTMP->(RECNO())","SEQUENCIA","")
oPExcel:GetCol("SEQUENCIA"):SetTipo("N")
oPExcel:GetCol("SEQUENCIA"):SetTamanho(7)
oPExcel:GetCol("SEQUENCIA"):SetDecimal(0)
oPExcel:GetCol("SEQUENCIA"):SetHAlign("C")

oPExcel:AddCol("TIPLANC","QTMP->TIPLANC","TIPLANC","")
oPExcel:GetCol("TIPLANC"):SetHAlign("C")

oPExcel:AddCol("VLRLANC","QTMP->VLRLANC","VLRLANC","")

// Adiciona a planilha 1
oRExcel:AddPlan(oPExcel)

// Cria arquivo Excel
oRExcel:Create()

QTMP->(dbCloseArea())

Return



Static Function PCTBR01
Local cQuery 	:= ""

cQuery := "SELECT " + CRLF
cQuery += " 	CT2_DATA        AS DTLANC" + CRLF
cQuery += " 	,CT2_DEBITO     AS CONTA" + CRLF
cQuery += " 	,CT2_CCD        AS CC" + CRLF
cQuery += " 	,'D'            AS TIPLANC" + CRLF
cQuery += " 	,CT2_VALOR      AS VLRLANC" + CRLF
cQuery += " 	,CT2.R_E_C_N_O_" + CRLF
cQuery += " FROM "+RETSQLNAME("CT2")+" CT2" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CT1")+" CT1 ON CT1.D_E_L_E_T_='' AND CT2_DEBITO = CT1_CONTA" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON CTT.D_E_L_E_T_='' AND CT2_CCD = CTT_CUSTO" + CRLF
cQuery += " WHERE CT2.D_E_L_E_T_=''" + CRLF
cQuery += "     AND CT2_DATA >= '"+DTOS(dDtIni)+"' " + CRLF 
cQuery += "     AND CT2_DATA <= '"+DTOS(dDtFim)+"' " + CRLF
cQuery += "     AND CT2_DEBITO <> '' " + CRLF
cQuery += "UNION ALL " + CRLF
cQuery += "SELECT " + CRLF
cQuery += " 	CT2_DATA        AS DTLANC" + CRLF
cQuery += " 	,CT2_CREDIT     AS CONTA" + CRLF
cQuery += " 	,CT2_CCC        AS CC" + CRLF
cQuery += " 	,'R'            AS TIPLANC" + CRLF
cQuery += " 	,CT2_VALOR      AS VLRLANC" + CRLF
cQuery += " 	,CT2.R_E_C_N_O_" + CRLF
cQuery += " FROM "+RETSQLNAME("CT2")+" CT2" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CT1")+" CT1 ON CT1.D_E_L_E_T_='' AND CT2_CREDIT = CT1_CONTA" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON CTT.D_E_L_E_T_='' AND CT2_CCC = CTT_CUSTO" + CRLF
cQuery += " WHERE CT2.D_E_L_E_T_=''" + CRLF
cQuery += "     AND CT2_DATA >= '"+DTOS(dDtIni)+"' " + CRLF 
cQuery += "     AND CT2_DATA <= '"+DTOS(dDtFim)+"' " + CRLF
cQuery += "     AND CT2_CREDIT <> '' " + CRLF
cQuery += " ORDER BY CT2_DATA,CT2.R_E_C_N_O_,TIPLANC" + CRLF

u_LogMemo(cProg+".SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"
TCSETFIELD("QTMP","DTLANC","D",8,0)


Return




Static Function BkPar
Local aRet		:=	{}
Local lRet := .F.

//   Parambox(aParametros,@cTitle          ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cProg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cProg,.T.         ,.T.))
	lRet := .T.
	dDtIni  := mv_par01
	dDtFim  := mv_par02
Endif
Return lRet
