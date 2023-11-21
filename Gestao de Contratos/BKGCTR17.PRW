#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR17()
BK - Informações de Contratos 

@author Adilson do Prado
@since 02/12/14 Rev 26/05/20
@version P12
@return Nil
/*/

User Function BKGCTR17()

Local nI 			:= 0
Local cCampo 		:= ""

Local aTitulos		:= {}
Local aCampos		:= {}
Local aCabs			:= {}
Local aPlans 		:= {}
Local aStruct		:= {}

Private aParam		:=	{}
Private aRet		:=	{}
Private cTitulo     := "Situação dos Contratos"
Private cProg    	:= "BKGCTR17"
Private cVigentes	:= "Sim"

aAdd( aParam ,{ 2, "Somente vigêntes?", cVigentes  ,{"Sim", "Não"}	, 60,'.T.'  ,.T.})

If !BkGC17()
   Return
EndIf

cQuery := ProcQuery("TMP")
   
AADD(aTitulos,cTitulo)

dbSelectArea("TMP")
aStruct := dbStruct()
For nI := 1 To Len(aStruct)
	cCampo := +aStruct[nI,1]
	If cCampo == "OBJETO"
		aAdd(aCampos,"U_CN9OBJ(TMP->OBJETO)")
		aAdd(aCabs  ,"Objeto")
	ElseIf cCampo == "CTT_DESC01"
		aAdd(aCampos,"TMP->"+cCampo)
		aAdd(aCabs  ,"Descrição Centro de Custo")
	ElseIf cCampo == "SITUACAO"
		aAdd(aCampos,"TMP->"+cCampo)
		aAdd(aCabs  ,"Situação")
	ElseIf cCampo == "JUSTIF"
		aAdd(aCampos,"TMP->"+cCampo)
		aAdd(aCabs  ,"Justificativa")
	ElseIf cCampo == "CND_DTINIC"
		// Meses executados
		aAdd(aCampos,"TMP->CND_DTINIC")
		aAdd(aCabs  ,"Última Medição")

		aAdd(aCampos,"TMP->(IIF(!Empty(CND_DTINIC),DateDiffMonth(CN9_DTINIC,CND_DTINIC),0))")
		aAdd(aCabs  ,"Meses executados (início até ultima medição)")
	ElseIf cCampo == "LIMITE60"
		// Data limite 60 meses
		aAdd(aCampos,"TMP->(MonthSum(CN9_DTINIC,60)-1)")
		aAdd(aCabs  ,"Data limite (60 meses)")
	Else
		aAdd(aCampos,"TMP->"+cCampo)
		aAdd(aCabs  ,GetSX3Cache( cCampo , "X3_TITULO"))
	EndIf
Next


AADD(aPlans,{"TMP",cProg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })

U_PlanXlsx(aPlans,cTitulo,cProg,.T.,aParam)


Return


Static Function ProcQuery(cAlias)

Local cQuery	:= ""
Local cTabCN9	:= RetSqlName("CN9")
Local cTabCND	:= RetSqlName("CND")
Local cTabCTT	:= RetSqlName("CTT")
//Local cTabCNF	:= RetSqlName("CNF")
Local aTcFields	:= {}

cQuery += " SELECT"+CRLF
cQuery += "  CN9_NUMERO,"+CRLF
cQuery += "  CTT_DESC01,"+CRLF
cQuery += "  CN9_CODOBJ AS OBJETO,"+CRLF
cQuery += "  CN9_NOMCLI,"+CRLF
cQuery += "  CN9_SITUAC,"+CRLF

cQuery += "  CASE CN9_SITUAC WHEN '01' THEN 'CANCELADO' "+CRLF
cQuery += "                  WHEN '02' THEN 'EM ELABORAÇÃO' "+CRLF
cQuery += "                  WHEN '03' THEN 'EMITIDO' "+CRLF
cQuery += "                  WHEN '04' THEN 'EM APROVAÇÃO' "+CRLF
cQuery += "                  WHEN '05' THEN 'VIGENTE' "+CRLF
cQuery += "                  WHEN '06' THEN 'PARALISADO' "+CRLF
cQuery += "                  WHEN '07' THEN 'SOL. FINALIZAÇÃO' "+CRLF
cQuery += "                  WHEN '08' THEN 'FINALIZADO' "+CRLF
cQuery += "                  WHEN '09' THEN 'EM REVISÃO' "+CRLF
cQuery += "                  WHEN '10' THEN 'REVISADO' "+CRLF
cQuery += "                  WHEN 'A'  THEN 'EM REVISÃO - APROVAÇÃO POR ALÇADAS' "+CRLF
cQuery += "                  ELSE 'INDEFINIDO' END AS SITUACAO, "+CRLF

cQuery += "  CN9_DTINIC,"+CRLF
cQuery += "  CN9_DTASSI,"+CRLF
cQuery += "  CN9_DTOSER,"+CRLF
cQuery += "  CN9_XXDVIG,"+CRLF

// Data da Ultima Medição para calcular os Meses executados
cQuery += "  (SELECT MAX(CND_DTINIC) FROM "+cTabCND+" CND WHERE CND_CONTRA = CN9_NUMERO AND CND.D_E_L_E_T_ = '') AS CND_DTINIC,"+CRLF

// Ultima Competência
//cQuery += "  (SELECT TOP 1 MAX(SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2)+'01') FROM "+cTabCNF+" CNF WHERE CNF.CNF_CONTRA = CN9.CN9_NUMERO AND CNF_VLREAL > 0 AND CNF.D_E_L_E_T_ = ' ') AS MAXCOMPET "+ CRLF

// Data limite 60 meses
cQuery += "  'X' AS LIMITE60,"+CRLF

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
