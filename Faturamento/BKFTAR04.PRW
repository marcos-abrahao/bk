#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKFATR04
BK - Faturamento por contrato

@Return
@author Marcos Bispo Abrahão
@since 28/08/2020
@version P12.1.25
/*/

User Function BKFATR04()

Local nF      := 0
Local oTmpTb
Local lSqlLite:= .T.

Private aParam		:=	{}
Private aRet		:=	{}

Private cTitulo     := "Faturamento por Contrato"
Private cPerg       := "BKFATR04"

Private aFields := {}
Private aTitulos,aCampos,aCabs

Private dDataI  	:= CTOD("")
Private dDataF  	:= CTOD("")
Private cPrefixos   := ""
Private cSufixos    := ""
Private cContratos  := ""


Private aDbf
Private cAliasQry   := GetNextAlias()
Private cAliasTrb   := GetNextAlias()
Private cRealName   := ""

/*
Param Box Tipo 1
1 - MsGet
  [2] : Descrição
  [3] : String contendo o inicializador do campo
  [4] : String contendo a Picture do campo
  [5] : String contendo a validação
  [6] : Consulta F3
  [7] : String contendo a validação When
  [8] : Tamanho do MsGet
  [9] : Flag .T./.F. Parâmetro Obrigatório ?
*/
 
aAdd( aParam, { 1, "Data Inicial:" 		, CTOD("")					, ""            , ""   , ""	  , "" , 70  , .F. })
aAdd( aParam, { 1, "Data Final:" 		, CTOD("")					, ""            , ""   , ""	  , "" , 70  , .F. })  
aAdd( aParam, { 1, "Prefixos (;):"	    , SPACE(40)	                , ""            , ""   , "CTT", "" , 70  , .F. })
aAdd( aParam, { 1, "Sufixos (;):"	    , SPACE(40)             	, ""            , ""   , "CTT", "" , 70  , .F. })
aAdd( aParam ,{11, "Contratos (;)"      , SPACE(243)                , ".T."         ,".T." ,.F.})

/*  
aParametros	 	Array of Record	 	Array contendo as perguntas
cTitle	 	 	Caracter	 	 	Titulo
aRet	 	 	Array of Record	 	Array container das respostas
bOk	 	 		Array of Record	 	Array contendo definições dos botões opcionais	 	 	 	 	 	 	 	 	 	 
aButtons	 	Array of Record	 	Array contendo definições dos botões opcionais	 	 	 	 	 	 	 	 	 	 
lCentered	 	Lógico	 	 		Indica se será centralizada a janela	 	 	 	 	 	 	 	 	 	 
nPosX	 	 	Numérico	 	 	Coordenada X da janela	 	 	 	 	 	 	 	 	 	 
nPosy	 	 	Numérico	 	 	Coordenada y da janela
oDlgWizard	 	Objeto	 	 		Objeto referente janela do Wizard	 	 	 	 	 	 	 	 	 	 
cLoad	 	 	Caracter	 	 	Nome arquivo para gravar respostas	 	 	 	 	 	 	 	 	 	 
lCanSave	 	Lógico	 	 		Indica se pode salvar o arquivo com respostas	 	 	 	 	 	 	 	 	 	 
lUserSave	 	Array of Record	 	Indica se salva nome do usuario no arquivo

o ParamBox grava as informações em arquivos ???????_nomedoparametro.prb na pasta profile
Read more: http://www.blacktdn.com.br/2012/05/para-quem-precisar-desenvolver-uma.html#ixzz6WR7UYbJm

*/

If !BkFR04Par()
   Return
EndIf

aCabs   := {}
aCampos := {}

aTitulos:= {}
AADD(aTitulos,"BKFATR04/"+TRIM(cUserName)+" - "+cTitulo)

aFields := {}

aAdd(aFields,{"XX_FILIAL"	,"F2_FILIAL"})
aAdd(aFields,{"C5_MDCONTR"	,"C5_MDCONTR"})
aAdd(aFields,{"F2_CLIENTE"	,"F2_CLIENTE"})
aAdd(aFields,{"F2_LOJA"	    ,"F2_LOJA"})
aAdd(aFields,{"A1_NOME" 	,"A1_NOME"})
aAdd(aFields,{"D2_COD"	    ,"D2_COD"})
aAdd(aFields,{"B1_DESC" 	,"B1_DESC"})
aAdd(aFields,{"B1_CODISS"	,"B1_CODISS"})
aAdd(aFields,{"B1_ALIQISS"	,"B1_ALIQISS"})
//aAdd(aFields,{"A1_MUN"      ,"A1_MUN"})

aAdd(aFields,{"C5_XXCOMPM"	,"C5_XXCOMPM"})
aAdd(aFields,{"D2_PEDIDO"	,"D2_PEDIDO"})

aAdd(aFields,{"C5_MDNUMED"	,"C5_MDNUMED"})
aAdd(aFields,{"C5_MDPLANI"	,"C5_MDPLANI"})
aAdd(aFields,{"CNA_XXMUN"	,"CNA_XXMUN"})
aAdd(aFields,{"CNA_XXMOT"	,"CNA_XXMOT"})

aAdd(aFields,{"F2_DOC"		,"F2_DOC"})
aAdd(aFields,{"F2_EMISSAO"	,"F2_EMISSAO"})
aAdd(aFields,{"F2_VALFAT"	,"F2_VALFAT"})
aAdd(aFields,{"F2_VALIRRF"	,"F2_VALIRRF"})
aAdd(aFields,{"F2_VALINSS"	,"F2_VALINSS"})
aAdd(aFields,{"F2_VALPIS"	,"F2_VALPIS"})
aAdd(aFields,{"F2_VALCOFI"	,"F2_VALCOFI"})
aAdd(aFields,{"F2_VALCSLL"	,"F2_VALCSLL"})
aAdd(aFields,{"F2_RECISS"	,"F2_RECISS"})
aAdd(aFields,{"F2_VALISS"	,"F2_VALISS"})
aAdd(aFields,{"F2_VLCPM"	,"F2_VLCPM"})
aAdd(aFields,{"E1_VENCTO"	,"E1_VENCTO"})
aAdd(aFields,{"E1_VENCORI"	,"E1_VENCORI"})
aAdd(aFields,{"E1_BAIXA"	,"E1_BAIXA"})
aAdd(aFields,{"E5_VLDESCO"	,"E5_VLDESCO"})
aAdd(aFields,{"E5_VLMULTA"	,"E5_VLMULTA"})
//aAdd(aFields,{"XX_PERDIF"	,"","(cAliasTrb)->(XX_PERDIF)","Diferença %",cPict,"N",5,2})

aDbf    := {}

For nF := 1 To Len(aFields)
	aAdd(aCampos,"(cAliasTrb)->"+aFields[nF,1])
	If !Empty(aFields[nF,2])
		aAdd( aDbf, { aFields[nF,1],GetSX3Cache(aFields[nF,2],"X3_TIPO"), GetSX3Cache(aFields[nF,2],"X3_TAMANHO"),GetSX3Cache(aFields[nF,2],"X3_DECIMAL") } )
		aAdd(aCabs  ,RetTitle(aFields[nF,2]))
	Else
		aAdd( aDbf, { aFields[nF,1],aFields[nF,6], aFields[nF,7],aFields[nF,8] } )
		aAdd(aCabs  ,aFields[nF,4])
	EndIf	
Next

If lSqlLite
	cRealName	:= cAliasTrb
	DBCreate( cAliasTrb , aDbf, 'SQLITE_TMP' ) // SQLLITE_MEM -> Memória
	DBUseArea( .T., 'SQLITE_TMP', cRealName, cAliasTrb, .F., .F. )
Else
    oTmpTb := FWTemporaryTable():New( cAliasTrb )
    oTmpTb:SetFields( aDbf )
    oTmpTb:Create()
EndIf

Processa( {|| ProcBKFR04() })

BKFR04E()

If lSqlLite
	DBSqlExec(cRealName, 'DROP TABLE ' + cRealName , 'SQLITE_TMP')
Else
    oTmpTb:Delete()
EndIf

Return



Static Function BkFR04Par
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,@cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKFATR04",.T.         ,.T.))
	lRet       := .T.
	dDataI     := mv_par01
	dDataF     := mv_par02
    cPrefixos  := mv_par03
    cSufixos   := mv_par04
    cContratos := mv_par05

	cPrefixos  := STRTRAN(cPrefixos,CRLF,"")
	cPrefixos  := STRTRAN(cPrefixos,",",";")
	cPrefixos  := STRTRAN(cPrefixos," ","")

	cSufixos   := STRTRAN(cSufixos,CRLF,"")
	cSufixos   := STRTRAN(cSufixos,",",";")
	cSufixos   := STRTRAN(cSufixos," ","")

	cContratos := STRTRAN(cContratos,CRLF,"")
	cContratos := STRTRAN(cContratos,",",";")
	cContratos := STRTRAN(cContratos," ","")
Endif
Return lRet



// Gera Excel
Static Function BKFR04E()
Local aPlans  := {}

AADD(aPlans,{cAliasTrb,TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
U_GeraXlsx(aPlans,cTitulo,TRIM(cPerg),.F.,aParam)

Return 



Static Function ProcBKFR04
Local cQuery := ""
Local cFilCtr:= ""
Private xCampo

cQuery := " SELECT DISTINCT F2_FILIAL,F2_CLIENTE,F2_LOJA,A1_NOME,D2_COD,B1_DESC,B1_CODISS,B1_ALIQISS,"+ CRLF
cQuery += "        CASE WHEN (C5_ESPECI1 = ' ' OR C5_ESPECI1 IS NULL) THEN C5_MDCONTR ELSE C5_ESPECI1 END AS C5_MDCONTR,"+ CRLF
cQuery += "        CASE WHEN (C5_DESCMUN = ' ' OR C5_DESCMUN IS NULL) THEN SA1.A1_MUN ELSE C5_DESCMUN END AS A1_MUN, " + CRLF  // CNA_NUMERO,CNA_XXMUN
cQuery += "        D2_PEDIDO,C5_XXCOMPM,C5_MDNUMED,C5_MDPLANI,CNA_XXMUN,CNA_XXMOT, " + CRLF   // C6_NUM
cQuery += "        F2_DOC,F2_EMISSAO,F2_VALFAT,F2_VALIRRF,F2_VALINSS,F2_VALPIS,F2_VALCOFI,F2_VALCSLL,F2_RECISS,F2_VALISS,F2_VLCPM, " + CRLF
cQuery += "        (SELECT TOP 1 E1_VENCTO FROM "+RETSQLNAME("SE1")+" SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC" + CRLF
cQuery += "            AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"' ) AS E1_VENCTO, " + CRLF
cQuery += "        (SELECT TOP 1 E1_VENCORI FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC" + CRLF
cQuery += "            AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"') AS E1_VENCORI, " + CRLF
cQuery += "        (SELECT TOP 1 E1_BAIXA FROM "+RETSQLNAME("SE1")+ " SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC" + CRLF
cQuery += "            AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"+xFilial("SE1")+"') AS E1_BAIXA, " + CRLF
cQuery += "        (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' "  + CRLF
cQuery += "            AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS E5_VLDESCO, " + CRLF
cQuery += "        (SELECT SUM(E5_VALOR) FROM "+RETSQLNAME("SE5")+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' " + CRLF
cQuery += "            AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS E5_VLMULTA "+ CRLF

cQuery += " FROM "+RETSQLNAME("SF2")+" SF2" + CRLF
//cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = "+cqContr
//cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '""
cQuery += " LEFT JOIN "+RETSQLNAME("SA1")+ " SA1 ON F2_CLIENTE = A1_COD AND F2_LOJA = A1_LOJA" + CRLF
cQuery += "      AND  A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SD2")+ " SD2 ON D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA" + CRLF
cQuery += "      AND  D2_FILIAL = '"+xFilial("SD2")+"' AND SD2.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON C5_NUM = D2_PEDIDO " + CRLF
cQuery += "      AND  C5_FILIAL = D2_FILIAL AND SC5.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CONTRA = C5_MDCONTR AND CNA_NUMERO = C5_MDPLANI " + CRLF
cQuery += "      AND  CNA_FILIAL = F2_FILIAL AND CNA.D_E_L_E_T_ = ' '" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+ " SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D2_COD = B1_COD"+ CRLF
cQuery += "      AND  SB1.D_E_L_E_T_ = ' '"+ CRLF
cQuery += " WHERE SF2.D_E_L_E_T_ = ' ' " + CRLF
//If !Empty(cCusto)
//    cQuery += " AND (C5_MDCONTR = '"+TRIM(cCusto)+"' OR C5_ESPECI1 = '"+TRIM(cCusto)+"')" + CRLF

cAnd   := " AND ("
cFilCtr:= ""
If !Empty(cPrefixos)
    cPrefixos  := FormatIN(cPrefixos, ';' )
    cFilCtr += cAnd +" SUBSTRING(C5_MDCONTR,1,3) IN "+cPrefixos+" OR SUBSTRING(C5_ESPECI1,1,3) IN "+cPrefixos+" " + CRLF
    cAnd    := " OR "
EndIf
If !Empty(cSufixos)
    cSufixos   := FormatIN(cSufixos, ';' )
   	cFilCtr += cAnd + " SUBSTRING(C5_MDCONTR,7,3) IN "+cSufixos+" OR SUBSTRING(C5_ESPECI1,7,3) IN "+cSufixos+" " + CRLF
    cAnd    := " OR "
EndIf
If !Empty(cContratos)
    cContratos := FormatIN(cContratos, ';' )
   	cFilCtr += cAnd+" C5_MDCONTR IN "+cContratos+" OR C5_ESPECI1 IN "+cContratos+" " + CRLF
    cAnd    := " OR "
Endif
If cAnd <> " AND ("
    cQuery += cFilCtr+") "+ CRLF
EndIf

If !Empty(dDataI)
    cQuery += "  AND F2_EMISSAO >= '"+DTOS(dDataI)+"' "  + CRLF
ENDIF
If !Empty(dDataF)
    cQuery += "  AND F2_EMISSAO <= '"+DTOS(dDataF)+"' "  + CRLF
ENDIF

cQuery += " ORDER BY C5_MDCONTR,F2_DOC" + CRLF

u_LogMemo("BKFATR04.SQL",cQuery)

TCQUERY cQuery NEW ALIAS (cAliasQry)
TCSETFIELD(cAliasQry,"F2_EMISSAO","D",8,0)
TCSETFIELD(cAliasQry,"E1_VENCTO","D",8,0)
TCSETFIELD(cAliasQry,"E1_VENCORI","D",8,0)
TCSETFIELD(cAliasQry,"E1_BAIXA","D",8,0)
 
ProcRegua((cAliasQry)->(LastRec()))

dbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())
DO WHILE (cAliasQry)->(!EOF())
	IncProc("Consultando banco de dados...")
	Reclock(cAliasTrb,.T.)
	For nF := 1 To Len(aFields)
		If !Empty(aFields[nF,2])
			xCampo := &(cAliasQry+"->"+aFields[nF,2])
		Else
			xCampo := &(aFields[nF,3])
		EndIf
		&(cAliasTrb+"->"+aFields[nF,1]) :=  xCampo
	Next
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbSkip())
ENDDO

(cAliasQry)->(dbCloseArea())

dbSelectArea(cAliasTrb)
dbGoTop()

Return

