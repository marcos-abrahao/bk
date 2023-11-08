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
		AADD(aCampos,"U_CN9OBJ(TMP->OBJETO)")
		AADD(aCabs  ,"Objeto")
	ElseIf cCampo == "SITUACAO"
		AADD(aCampos,"TMP->"+cCampo)
		AADD(aCabs  ,"Situação")
	ElseIf cCampo == "JUSTIF"
		AADD(aCampos,"TMP->"+cCampo)
		AADD(aCabs  ,"Justificativa")
	Else
		AADD(aCampos,"TMP->"+cCampo)
		AADD(aCabs  ,GetSX3Cache( cCampo , "X3_TITULO"))
	EndIf
Next


AADD(aPlans,{"TMP",cProg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })

U_PlanXlsx(aPlans,cTitulo,cProg,.T.,aParam)


Return


Static Function ProcQuery(cAlias)

Local cQuery	:= ""
Local cTabCN9	:= RetSqlName("CN9")
//Local cTabSYP 	:= RetSqlName("SYP")
Local aTcFields	:= {}

cQuery += " SELECT"+CRLF
cQuery += "  CN9_NUMERO,"+CRLF
cQuery += "  CN9_REVISA,"+CRLF
cQuery += "  CN9_DTREV, "+CRLF
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

cQuery += "  CN9_NOMCLI,"+CRLF
cQuery += "  CN9_GESTC, "+CRLF
cQuery += "  CN9_XXNRBK,"+CRLF
cQuery += "  CN9_XXNGC, "+CRLF
cQuery += "  CN9_XXEGC, "+CRLF
cQuery += "  CN9_XXTELS,"+CRLF
cQuery += "  CN9_VLINI, "+CRLF
cQuery += "  CN9_VLATU, "+CRLF
cQuery += "  CN9_SALDO, "+CRLF
cQuery += "  CN9_DTINIC,"+CRLF
cQuery += "  CN9_DTASSI,"+CRLF
cQuery += "  CN9_DTOSER,"+CRLF
cQuery += "  CN9_XXDVIG,"+CRLF
cQuery += "  CN9_XXDREP,"+CRLF
cQuery += "  CN9_XXOREP,"+CRLF
cQuery += "  CN9_CODOBJ AS OBJETO,"+CRLF

/*
cQuery += "  UPPER(REPLACE ("+CRLF
cQuery += "    ("+CRLF
cQuery += "      SELECT "+CRLF
cQuery += "        RTRIM(YP_TEXTO) "+CRLF
cQuery += "      FROM "+CRLF
cQuery += "        "+cTabSYP+" SYP"+CRLF
cQuery += "      WHERE "+CRLF
cQuery += "        CN9.CN9_CODOBJ = SYP.YP_CHAVE"+CRLF
cQuery += "        AND SYP.D_E_L_E_T_ = ' ' "+CRLF
cQuery += "      ORDER BY "+CRLF
cQuery += "        YP_CHAVE + YP_SEQ FOR XML PATH (''), "+CRLF
cQuery += "        TYPE"+CRLF
cQuery += "    ).value('.', 'varchar(1000)'),'\13\10',' '))"+CRLF
cQuery += "    AS OBJETO, "+CRLF
*/

cQuery += "  CONVERT(VARCHAR(600),CONVERT(Binary(600),CN9_XXOBS)) CN9_XXOBS"+CRLF
/*
cQuery += "  ,UPPER(REPLACE ("+CRLF
cQuery += "    ("+CRLF
cQuery += "      SELECT "+CRLF
cQuery += "        RTRIM(YP_TEXTO) "+CRLF
cQuery += "      FROM "+CRLF
cQuery += "        "+cTabSYP+" SYP"+CRLF
cQuery += "      WHERE "+CRLF
cQuery += "        CN9.CN9_CODJUS = SYP.YP_CHAVE"+CRLF
cQuery += "        AND SYP.D_E_L_E_T_ = ' ' "+CRLF
cQuery += "      ORDER BY "+CRLF
cQuery += "        YP_CHAVE + YP_SEQ FOR XML PATH (''), "+CRLF
cQuery += "        TYPE"+CRLF
cQuery += "    ).value('.', 'varchar(1000)'),'\13\10',' '))"+CRLF
cQuery += "    AS JUSTIF "+CRLF
*/

cQuery += " FROM " + CRLF
cQuery += "  "+cTabCN9+" CN9 " + CRLF
cQuery += " WHERE CN9.D_E_L_E_T_=''" + CRLF
cQuery += "      AND (CN9_REVATU = ' ' OR CN9_SITUAC = '05') " + CRLF
If Substr(cVigentes,1,1) == "S"
	cQuery += "      AND CN9_XXDVIG >= '"+DTOS(dDataBase)+"'" + CRLF
EndIf

aAdd(aTcFields,FWSX3Util():GetFieldStruct( "CN9_DTREV" ))
aAdd(aTcFields,FWSX3Util():GetFieldStruct( "CN9_DTINIC" ))
aAdd(aTcFields,FWSX3Util():GetFieldStruct( "CN9_DTASSI" ))
aAdd(aTcFields,FWSX3Util():GetFieldStruct( "CN9_DTOSER" ))
aAdd(aTcFields,FWSX3Util():GetFieldStruct( "CN9_XXDVIG" ))
aAdd(aTcFields,FWSX3Util():GetFieldStruct( "CN9_XXDREP" ))

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
