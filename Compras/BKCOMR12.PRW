#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} BKCOMR12
BK - Compras - Prev. X Realizado

@Return
@author Marcos Bispo Abrahão
@since 14/05/2019
@version P11/P12
/*/

User Function BKCOMR12()

Local nF      := 0
Local oTmpTb

Private aParam		:=	{}
Private aRet		:=	{}

Private cTitulo     := "Compras - Prev. X Realizado"
Private cPerg       := "BKCOMR12"

Private aFields := {}
Private	cPict       := "@E 99,999,999,999.99"
Private nPlan       := 1
Private aHeader	    := {}
Private aTitulos,aCampos,aCabs,aCampos2,aCabs2

Private cCusto  	:= ""
Private dDataI  	:= CTOD("")
Private dDataF  	:= CTOD("")
Private cFormato    := ""
Private lSintetico  := .T.

Private aDbf
Private cAliasQry   := GetNextAlias()
Private cAliasTrb   := GetNextAlias()

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
 
aAdd( aParam, { 1, "Centro de Custos:"	, SPACE(TamSx3("C1_CC")[1])	, ""            , "", "CTT"	, "" , 70  , .F. })
aAdd( aParam, { 1, "Data Inicial:" 		, CTOD("")					, ""            , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Data Final:" 		, CTOD("")					, ""            , "", ""	, "" , 70  , .F. })  
aAdd( aParam ,{ 2, "Formato:"           , "Sintetico"               , {"Sintético", "Analítico"}, 70,'.T.'  ,.T.})

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
*/

If !BkCR12Par()
   Return
EndIf

aCabs   := {}
aCampos := {}

aTitulos:= {}
AADD(aTitulos,"BKComR12/"+TRIM(cUserName)+" - "+cTitulo)

aFields := {}
If lSintetico
	aAdd(aFields,{"XX_CC"		,"D1_CC"})
	aAdd(aFields,{"XX_COD"		,"B1_XXSGRP"})
	aAdd(aFields,{"XX_DESC"		,"ZI_DESC"})
	aAdd(aFields,{"XX_GRUPO"	,"B1_GRUPO"})
	aAdd(aFields,{"XX_VLPREV"	,"","(cAliasTrb)->(XX_VLPREV)","Valor Previsto",cPict,"N",15,2})
	aAdd(aFields,{"XX_VLREAL"	,"","(cAliasQry)->(D1_TOTAL)","Valor Realizado",cPict,"N",15,2})
	aAdd(aFields,{"XX_VLDIF"	,"","(cAliasTrb)->(XX_VLDIF)","Diferença",cPict,"N",15,2})
	aAdd(aFields,{"XX_PERDIF"	,"","(cAliasTrb)->(XX_PERDIF)","Diferença %",cPict,"N",5,2})
Else
	aAdd(aFields,{"XX_CC"		,"D1_CC"})
	aAdd(aFields,{"XX_PRODUTO"	,"D1_COD"})
	aAdd(aFields,{"XX_DESCPRD"	,"B1_DESC"})
	aAdd(aFields,{"XX_CONTA"	,"D1_CONTA"})
	aAdd(aFields,{"XX_COD"		,"B1_XXSGRP"})
	aAdd(aFields,{"XX_DESC"		,"ZI_DESC"})
	aAdd(aFields,{"XX_GRUPO"	,"B1_GRUPO"})
	aAdd(aFields,{"XX_VLPREV"	,"","(cAliasTrb)->(XX_VLPREV)","Valor Previsto",cPict,"N",15,2})
	aAdd(aFields,{"XX_VLREAL"	,"","(cAliasQry)->(D1_TOTAL)","Valor Realizado",cPict,"N",15,2})
	aAdd(aFields,{"XX_VLDIF"	,"","(cAliasTrb)->(XX_VLDIF)","Diferença",cPict,"N",15,2})
	aAdd(aFields,{"XX_PERDIF"	,"","(cAliasTrb)->(XX_PERDIF)","Diferença %",cPict,"N",5,2})
EndIf

aDbf    := {}

For nF := 1 To Len(aFields)

	aAdd(aCampos,"(cAliasTrb)->"+aFields[nF,1])

	If !Empty(aFields[nF,2])
		aAdd( aDbf, { aFields[nF,1],GetSX3Cache(aFields[nF,2],"X3_TIPO"), GetSX3Cache(aFields[nF,2],"X3_TAMANHO"),GetSX3Cache(aFields[nF,2],"X3_DECIMAL") } )
		aAdd(aCabs  ,RetTitle(aFields[nF,2]))
		aAdd(aHeader,{	RetTitle(aFields[nF,2]),;
						aFields[nF,1],;
						GetSX3Cache(aFields[nF,2],"X3_PICTURE"),;
						GetSX3Cache(aFields[nF,2],"X3_TAMANHO"),;
						GetSX3Cache(aFields[nF,2],"X3_DECIMAL"),;
						"",;
						"",;
						GetSX3Cache(aFields[nF,2],"X3_TIPO"),;
						cAliasTrb,;
						"R"})
	Else
		aAdd( aDbf, { aFields[nF,1],aFields[nF,6], aFields[nF,7],aFields[nF,8] } )
		aAdd(aCabs  ,aFields[nF,4])
		aAdd(aHeader,{	aFields[nF,4],;
						aFields[nF,1],;
						aFields[nF,5],;
						aFields[nF,7],;
						aFields[nF,8],;
						"",;
						"",;
						aFields[nF,6],;
						cAliasTrb,;
						"R"})
	
	EndIf	

Next

///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,cAliasTrb,.f.,.f. )

oTmpTb := FWTemporaryTable():New( cAliasTrb )
oTmpTb:SetFields( aDbf )
oTmpTb:Create()

Processa( {|| ProcBKCR12() })

MBrwBKCR12()

oTmpTb:Delete()
///(cAliasTrb)->(Dbclosearea())
///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())

Return



Static Function BkCR12Par
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,@cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKComR12",.T.         ,.T.))
	lRet       := .T.
	cCusto     := mv_par01
	dDataI     := mv_par02
	dDataF     := mv_par03
	cFormato   := mv_par04
	lSintetico := (substr(mv_par04,1,1) == "S")
	cTitulo := "Compras - Previsto X Realizado - Centro de Custos: "+TRIM(cCusto)+" - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
Endif
Return lRet



Static Function MBrwBKCR12()
Local   oSize
Local   aPosObj 

Private aRotina		:= {}
Private lRefresh:= .T.
Private aButton := {}
Private oGetDb1
Private oDlg1
 

// Dimensionamento da tela
oSize := FWDefSize():New(.T., , nOr(WS_VISIBLE,WS_POPUP) )
oSize:AddObject("TELA1", 100, 100, .T., .T.)
oSize:aMargins:= {3,3,3,3}
oSize:Process()

aPosObj := { 	oSize:GetDimension("TELA1","LININI"), oSize:GetDimension("TELA1","COLINI") ,;
				oSize:GetDimension("TELA1","LINEND"), oSize:GetDimension("TELA1","COLEND") }



AADD(aRotina,{"Exp. Excel"	,"U_CBKCR12",0,6})
AADD(aRotina,{"Parametros"	,"U_PBKCR12",0,8})
AADD(aRotina,{"Legenda"		,"U_LBKCR12",0,9})

dbSelectArea(cAliasTrb)
//dbSetOrder(1)
dbGoTop()
	
DEFINE DIALOG oDlg1;
 TITLE cTitulo ;
 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)

oGetDb1 := MsGetDb():New(aPosObj[1],aPosObj[2],aPosObj[3],aPosObj[4], 2, "AllwaysTrue()", "AllwaysTrue()",,,,,,"AllwaysTrue()",cAliasTrb)
nBrLin  :=1
oGetDb1:ForceRefresh()

aadd(aButton , { "BMPTABLE" , { || U_CBKCR12(), (cAliasTrb)->(dbGoTop()), nBrLin:=1, oGetDb1:ForceRefresh(), oDlg1:Refresh()}, "Gerar planilha" } )
//aadd(aButton , { "BMPTABLE" , { || U_PBKCR12(), (cAliasTrb)->(dbGoTop()), nBrLin:=1, oGetDb1:ForceRefresh(), oDlg1:Refresh()}, "Parametros" } )
//aadd(aButton , { "BMPTABLE" , { || U_LBKCOMR04()}, "Legenda" } )
	
ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| oDlg1:End()}, {||oDlg1:End()},, aButton)

Return Nil



User Function LBKCR12()
Local aLegenda := {}

AADD(aLegenda,{"BR_AMARELO"," - Cancelado"})
AADD(aLegenda,{"BR_AMARELO"," - Em Elaboração" })
AADD(aLegenda,{"BR_AZUL" ," - Emitido"})
AADD(aLegenda,{"BR_LARANJA"," - Em Aprovação" })
AADD(aLegenda,{"BR_VERDE"," - Vigente" })
AADD(aLegenda,{"BR_CINZA"," - Paralisado" })
AADD(aLegenda,{"BR_MARRON"," - Sol. Finalização" })
AADD(aLegenda,{"BR_PRETO"," - Finalizado" })
AADD(aLegenda,{"BR_PINK"," - Resisão" })
AADD(aLegenda,{"BR_BRANCO"," - Revisado" })

BrwLegenda(cCadastro, "Legenda", aLegenda)

Return Nil




User FUNCTION PBKCR12()

If !BkCR12Par()
   Return Nil
EndIf

Processa( {|| ProcBKCR12() })

Return Nil
   

Static Function LimpaBrw(cAlias)

DbSelectArea(cAlias)
(cAlias)->(dbgotop())
Do While (cAlias)->(!eof())
	RecLock(cAlias,.F.)
	(cAlias)->(dbDelete())
	(cAlias)->(MsUnlock())
	dbselectArea(cAlias)
	(cAlias)->(dbskip())
EndDo

Return (.T.) 


// Gera Excel
User FUNCTION CBKCR12()
Local aPlans  := {}

AADD(aPlans,{cAliasTrb,TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
U_GeraXlsx(aPlans,cTitulo,TRIM(cPerg),.F.,aParam)

Return 



Static Function ProcBKCR12
Local cQuery := ""
Local nReg := 0

Private xCampo

LimpaBrw(cAliasTrb)

/*
aAdd(aFields,{"XX_CC"		,"D1_CC"})
aAdd(aFields,{"XX_COD"		,"ZI_COD"})
aAdd(aFields,{"XX_DESC"		,"ZI_DESC"})
aAdd(aFields,{"XX_VLPREV"	,"","(cAliasTrb)->(XX_VLPREV)","Valor Previsto",cPict,"N",15,2})
aAdd(aFields,{"XX_VLREAL"	,"","(cAliasTrb)->(XX_VLREAL)","Valor Realizado",cPict,"N",15,2})
aAdd(aFields,{"XX_VLDIF"	,"","(cAliasTrb)->(XX_VLDIF)","Diferença",cPict,"N",15,2})
aAdd(aFields,{"XX_PERDIF"	,"","(cAliasTrb)->(XX_PERDIF)","Diferença %",cPict,"N",5,2})
*/

/*
SELECT D1_CC, SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) AS D1_TOTAL,B1_XXSGRP,ZI_DESC,B1_GRUPO
FROM SD1010 SD1
INNER JOIN SB1010 SB1 ON D1_COD = B1_COD    
AND SB1.D_E_L_E_T_ = ' '  
LEFT  JOIN SZI010 SZI ON ZI_COD = B1_XXSGRP AND SZI.D_E_L_E_T_ = ' '  
WHERE SD1.D_E_L_E_T_ = ' ' 
AND SD1.D1_PEDIDO <> ''  
AND SD1.D1_DTDIGIT >= '20180501' 
AND SD1.D1_DTDIGIT <= '20180531' 
AND SD1.D1_CC = '290000471'
GROUP BY D1_CC,B1_GRUPO,B1_XXSGRP,ZI_DESC
*/

If lSintetico
	cQuery := "SELECT D1_CC, SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) AS D1_TOTAL,B1_XXSGRP,ZI_DESC,B1_GRUPO "
	cQuery += " FROM "+RETSQLNAME("SD1")+" SD1" 
	cQuery += " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON D1_COD = B1_COD    AND SB1.D_E_L_E_T_ = ' ' "                                         
	cQuery += " LEFT  JOIN "+RETSQLNAME("SZI")+" SZI ON ZI_COD = B1_XXSGRP AND SZI.D_E_L_E_T_ = ' ' "                                         
	
	cQuery += " WHERE SD1.D_E_L_E_T_ = ' ' AND SUBSTRING(D1_CONTA,1,1) = '3' "
	cQuery +=       " AND D1_PEDIDO <> '' "
	
	If !Empty(dDataI)
		cQuery += " AND SD1.D1_DTDIGIT >= '"+DTOS(dDataI)+"'"
	EndIf
	If !Empty(dDataF)
		cQuery += " AND SD1.D1_DTDIGIT <= '"+DTOS(dDataF)+"'"
	EndIf          
	If !Empty(cCusto)
		cQuery += " AND SD1.D1_CC = '"+ALLTRIM(cCusto)+"'" 
	EndIf
	cQuery += " GROUP BY D1_CC,B1_GRUPO,B1_XXSGRP,ZI_DESC"
Else
	cQuery := "SELECT D1_CC,D1_COD,D1_CONTA,B1_DESC, D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC AS D1_TOTAL,B1_XXSGRP,ZI_DESC,B1_GRUPO"
	cQuery += " FROM "+RETSQLNAME("SD1")+" SD1" 
	cQuery += " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON D1_COD = B1_COD    AND SB1.D_E_L_E_T_ = ' ' "                                         
	cQuery += " LEFT  JOIN "+RETSQLNAME("SZI")+" SZI ON ZI_COD = B1_XXSGRP AND SZI.D_E_L_E_T_ = ' ' "                                         
	
	cQuery += " WHERE SD1.D_E_L_E_T_ = ' ' AND SUBSTRING(D1_CONTA,1,1) = '3' "
	cQuery +=       " AND D1_PEDIDO <> '' "
	
	If !Empty(dDataI)
		cQuery += " AND SD1.D1_DTDIGIT >= '"+DTOS(dDataI)+"'"
	EndIf
	If !Empty(dDataF)
		cQuery += " AND SD1.D1_DTDIGIT <= '"+DTOS(dDataF)+"'"
	EndIf          
	If !Empty(cCusto)
		cQuery += " AND SD1.D1_CC = '"+ALLTRIM(cCusto)+"'" 
	EndIf
	cQuery += " ORDER BY D1_CC,B1_XXSGRP,ZI_DESC"
EndIf

u_LogMemo("BKCOMR12.SQL",cQuery)
 
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

ProcRegua((cAliasQry)->(RecCount()))

nReg := 0

dbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())
DO WHILE (cAliasQry)->(!EOF())
    nReg++
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

IF nReg < 1
	Reclock(cAliasTrb,.T.)
	(cAliasTrb)->XX_NUM 	:= "Null"
 	(cAliasTrb)->(Msunlock())
ENDIF

(cAliasQry)->(dbCloseArea())

dbSelectArea(cAliasTrb)
//dbSetOrder(1)
dbGoTop()

Return

