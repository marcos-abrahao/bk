#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR17()
BK - Situa��o dos Contratos

@author Marcos Bispo Abrah�o
@since 07/11/2023
@version P12
@return Nil
/*/

User Function BKGCTR17()

Local nI 			:= 0
Local cCampo 		:= ""

//Local aTitulos	:= {}
//Local aCampos		:= {}
//Local aCabs		:= {}
//Local aPlans 		:= {}
Local aStruct		:= {}
Local cAlias		:= "TMP"

// Excel
Local cDescricao	:= "Objetivo deste relat�rio � demonstrar a situa��o dos contratos, considerando a data de vig�ncia pelo campo CN9_XXDVIG (informado pelo usu�rio) "+CRLF+"Solicitado pela Ger�ncia da Gest�o em novembro de 2023."
Local cVersao 		:= "05/12/2023 - Inclu�do campo 'Dias para finalizar'"
Local oRExcel		AS Object
Local oPExcel		AS Object

// Par�metros
Private cTitulo     := "Situa��o dos Contratos"
Private cProg    	:= "BKGCTR17"
Private aParam		:=	{}
Private aRet		:=	{}
Private cVigentes	:= "Sim"

aAdd( aParam ,{ 2, "Somente vig�ntes", cVigentes  ,{"Sim", "N�o"}	, 60,'.T.'  ,.T.})

If !BkGC17()
   Return
EndIf

cQuery := ProcQuery(cAlias)
   
// Defini��o do Arq Excel
oRExcel := RExcel():New(cProg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetDescr(cDescricao)
oRExcel:SetVersao(cVersao)
oRExcel:SetParam(aParam)

// Defini��o da Planilha 1
oPExcel:= PExcel():New(cProg,cAlias)
oPExcel:SetTitulo(IIf(Substr(cVigentes,1,1)=="S","Somente Contratos Vigentes","Todos os Contratos"))

//AADD(aTitulos,cTitulo)

dbSelectArea(cAlias)
aStruct := dbStruct()
For nI := 1 To Len(aStruct)
	cCampo := aStruct[nI,1]
	If cCampo == "OBJETO"
		//aAdd(aCampos,"U_CN9OBJ(TMP->OBJETO)")
		//aAdd(aCabs  ,"Objeto")

		oPExcel:AddCol(cCampo,"U_CN9OBJ(TMP->OBJETO)","Objeto","")
		oPExcel:GetCol(cCampo):SetWrap(.T.)

	ElseIf cCampo == "CTT_DESC01"
		//aAdd(aCampos,"TMP->"+cCampo)
		//aAdd(aCabs  ,"Descri��o Centro de Custo")

		oPExcel:AddCol(cCampo,"TMP->CTT_DESC01","Descri��o Centro de Custo","CTT_DESC01")

	ElseIf cCampo == "SITUACAO"
		//aAdd(aCampos,"TMP->"+cCampo)
		//aAdd(aCabs  ,"Situa��o")

		oPExcel:AddCol(cCampo,"TMP->SITUACAO","Situa��o","")

	ElseIf cCampo == "JUSTIF"
		//aAdd(aCampos,"TMP->"+cCampo)
		//aAdd(aCabs  ,"Justificativa")

		oPExcel:AddCol(cCampo,"TMP->JUSTIF","Justificativa","")

	ElseIf cCampo == "CND_DTINIC"
		// Meses executados
		//aAdd(aCampos,"TMP->CND_DTINIC")
		//aAdd(aCabs  ,"�ltima Medi��o")

		//aAdd(aCampos,"TMP->(IIF(!Empty(CND_DTINIC),DateDiffMonth(CN9_DTINIC,CND_DTINIC),0))")
		//aAdd(aCabs  ,"Meses executados (in�cio at� ultima medi��o)")

		oPExcel:AddCol(cCampo,"TMP->CND_DTINIC","�ltima Medi��o","CND_DTINIC")

		oPExcel:AddCol("MESESEXEC","TMP->(IIF(!Empty(CND_DTINIC),DateDiffMonth(CN9_DTINIC,CND_DTINIC),0))","Meses executados (in�cio at� ultima medi��o)","")
		oPExcel:GetCol("MESESEXEC"):SetTamanho(5)

	ElseIf cCampo == "LIMITE60"
		// Data limite 60 meses
		//aAdd(aCampos,"TMP->(MonthSum(CN9_DTINIC,60)-1)")
		//aAdd(aCabs  ,"Data limite (60 meses)")

		oPExcel:AddCol(cCampo,"TMP->(MonthSum(CN9_DTINIC,60)-1)","Data limite (60 meses)","")

	ElseIf cCampo == "DIASFINAL"
		// Dias para finalizar
		//aAdd(aCampos,"IIF(dDataBase > TMP->(MonthSum(CN9_DTINIC,60)-1),0,TMP->(MonthSum(CN9_DTINIC,60)-1) - dDataBase)")
		//aAdd(aCabs  ,"Dias para Finalizar")

		oPExcel:AddCol(cCampo,"IIF(dDataBase > TMP->(MonthSum(CN9_DTINIC,60)-1),0,TMP->(MonthSum(CN9_DTINIC,60)-1) - dDataBase)","Dias para Finalizar","")
		oPExcel:GetCol(cCampo):SetTamanho(5)


	ElseIf cCampo == "A1_PESSOA"
	
	ElseIf cCampo == "A1_CGC"

		oPExcel:AddCol("A1_CGC","Transform(TMP->A1_CGC,IIF(TMP->A1_PESSOA=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))","CNPJ","")
		oPExcel:GetCol("A1_CGC"):SetHAlign("C")

	Else
		//aAdd(aCampos,"TMP->"+cCampo)
		//aAdd(aCabs  ,GetSX3Cache( cCampo , "X3_TITULO"))

		oPExcel:AddColX3(cCampo)
		//If cCampo $ "CN9_VLINI,CN9_VLATU,CN9_SALDO"
		//	oPExcel:GetCol(cCampo):SetTotal(.T.)
		//EndIf
	EndIf
Next

// Sets de propriedades opcionais
oPExcel:GetCol("CN9_NUMERO"):SetHAlign("C")
oPExcel:GetCol("CN9_SITUAC"):SetHAlign("C")
oPExcel:GetCol("SITUACAO"):SetHAlign("C")
oPExcel:GetCol("MESESEXEC"):SetHAlign("C")

oPExcel:GetCol("DIASFINAL"):SetHAlign("C")
oPExcel:GetCol("DIASFINAL"):AddCor({|x| x <= 60}				,"FF0000","",11,,.T.) // Vermelho
oPExcel:GetCol("DIASFINAL"):AddCor({|x| x >  60 .and. x <= 120}	,"E26B0A","",11,,.T.) // Laranja escuro
oPExcel:GetCol("DIASFINAL"):AddCor({|x| X > 120 .and. x <= 180}	,"0000FF","",11,,.T.) // Azul
oPExcel:GetCol("DIASFINAL"):AddCor({|x| X > 180}				,"008000","",10,,.T.) // Verde

oPExcel:GetCol("CN9_VLINI"):SetTotal(.T.)
oPExcel:GetCol("CN9_VLATU"):SetTotal(.T.)
oPExcel:GetCol("CN9_SALDO"):SetTotal(.T.)

// Adiciona a planilha
oRExcel:AddPlan(oPExcel)

// Cria arquivo Excel
oRExcel:Create()

//AADD(aPlans,{"TMP",cProg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
//U_PlanXlsx(aPlans,cTitulo,cProg,.T.,aParam)


Return


Static Function ProcQuery(cAlias)

Local cQuery	:= ""
Local cTabCN9	:= RetSqlName("CN9")
Local cTabSA1	:= RetSqlName("SA1")
Local cTabCND	:= RetSqlName("CND")
Local cTabCTT	:= RetSqlName("CTT")
//Local cTabCNF	:= RetSqlName("CNF")
Local aTcFields	:= {}

cQuery += " SELECT"+CRLF
cQuery += "  CN9_NUMERO,"+CRLF
cQuery += "  CN9_NOMCLI,"+CRLF
cQuery += "  A1_PESSOA,"+CRLF
cQuery += "  A1_CGC,"+CRLF

cQuery += "  CTT_DESC01,"+CRLF
cQuery += "  CN9_CODOBJ AS OBJETO,"+CRLF
//cQuery += "  CN9_NOMCLI,"+CRLF
cQuery += "  CN9_SITUAC,"+CRLF

cQuery += "  CASE CN9_SITUAC WHEN '01' THEN 'CANCELADO' "+CRLF
cQuery += "                  WHEN '02' THEN 'EM ELABORA��O' "+CRLF
cQuery += "                  WHEN '03' THEN 'EMITIDO' "+CRLF
cQuery += "                  WHEN '04' THEN 'EM APROVA��O' "+CRLF
cQuery += "                  WHEN '05' THEN 'VIGENTE' "+CRLF
cQuery += "                  WHEN '06' THEN 'PARALISADO' "+CRLF
cQuery += "                  WHEN '07' THEN 'SOL. FINALIZA��O' "+CRLF
cQuery += "                  WHEN '08' THEN 'FINALIZADO' "+CRLF
cQuery += "                  WHEN '09' THEN 'EM REVIS�O' "+CRLF
cQuery += "                  WHEN '10' THEN 'REVISADO' "+CRLF
cQuery += "                  WHEN 'A'  THEN 'EM REVIS�O - APROVA��O POR AL�ADAS' "+CRLF
cQuery += "                  ELSE 'INDEFINIDO' END AS SITUACAO, "+CRLF

cQuery += "  CN9_DTINIC,"+CRLF
cQuery += "  CN9_DTASSI,"+CRLF
cQuery += "  CN9_DTOSER,"+CRLF
cQuery += "  CN9_XXDVIG,"+CRLF

// Data da Ultima Medi��o para calcular os Meses executados
cQuery += "  (SELECT MAX(CND_DTINIC) FROM "+cTabCND+" CND WHERE CND_CONTRA = CN9_NUMERO AND CND.D_E_L_E_T_ = '') AS CND_DTINIC,"+CRLF

// Ultima Compet�ncia
//cQuery += "  (SELECT TOP 1 MAX(SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2)+'01') FROM "+cTabCNF+" CNF WHERE CNF.CNF_CONTRA = CN9.CN9_NUMERO AND CNF_VLREAL > 0 AND CNF.D_E_L_E_T_ = ' ') AS MAXCOMPET "+ CRLF

// Data limite 60 meses
cQuery += "  'X' AS LIMITE60,"+CRLF
cQuery += "   0  AS DIASFINAL,"+CRLF

cQuery += "  CN9_VLINI, "+CRLF
cQuery += "  CN9_VLATU, "+CRLF
cQuery += "  CN9_SALDO, "+CRLF
cQuery += "  CN9_GESTC, "+CRLF
cQuery += "  CN9_XXNRBK,"+CRLF
cQuery += "  CN9_XXNGC, "+CRLF
cQuery += "  CN9_XXEGC, "+CRLF
cQuery += "  CN9_XXTELS "+CRLF

cQuery += " FROM " + CRLF
cQuery += "  "+cTabCN9+" CN9 " + CRLF
cQuery += " LEFT JOIN "+cTabCTT+ " CTT ON CTT_CUSTO = CN9_NUMERO"
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"

cQuery += " LEFT JOIN "+cTabSA1+ " SA1 ON A1_COD = CN9_XCLIEN AND A1_LOJA = CN9_XLOJA"
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"

cQuery += " WHERE CN9.D_E_L_E_T_=''" + CRLF
cQuery += "      AND (CN9_REVATU = ' ' OR CN9_SITUAC = '05') " + CRLF
If Substr(cVigentes,1,1) == "S"
	cQuery += "      AND CN9_SITUAC = '05'" + CRLF
	//cQuery += "      AND CN9_XXDVIG >= '"+DTOS(dDataBase)+"'" + CRLF
EndIf

aAdd(aTcFields,FWSX3Util():GetFieldStruct( "CN9_DTINIC" ))
aAdd(aTcFields,FWSX3Util():GetFieldStruct( "CN9_DTASSI" ))
aAdd(aTcFields,FWSX3Util():GetFieldStruct( "CN9_DTOSER" ))
aAdd(aTcFields,FWSX3Util():GetFieldStruct( "CN9_XXDVIG" ))
aAdd(aTcFields,FWSX3Util():GetFieldStruct( "CND_DTINIC" ))
//aAdd(aTcFields,{"MAXCOMPET",D,8,0})

u_RunQuery(cProg,cQuery,cAlias,aTcFields)

Return


Static Function BkGC17
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cProg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cProg      ,.T.         ,.T.))
	lRet      := .T.
	cVigentes := mv_par01
Endif
Return lRet
