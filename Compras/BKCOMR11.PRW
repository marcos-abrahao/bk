#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} BKCOMR11
Relatório de Economia por CC e Período

@Return
@author Marcos Bispo Abrahão
@since 04/04/2019
@version P11/P12
/*/

User Function BKCOMR11()

Local nF      := 0
Local oTmpTb
Private aParam		:=	{}
Private aRet		:=	{}
Private cTitulo     := "Economia de compras"
Private cPerg       := "BKCOMR11"
Private aFields     := {}
Private	cPict       := "@E 99,999,999,999.99"
Private nPlan       := 1
Private aHeader	    := {}
Private aTitulos,aCampos,aCabs,aCampos2,aCabs2

Private cCusto  	:= ""
Private cGrpPrd     := SPACE(3)
Private dDataI  	:= CTOD("")
Private dDataF  	:= CTOD("")
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
 
aAdd( aParam, { 1, "Centro de Custos:" 		, SPACE(TamSx3("C1_CC")[1])	, ""    , "", "CTT"	, "" , 70  , .F. })
aAdd( aParam, { 1, "Grupo de Produtos:"		, SPACE(3)					, "@!"  , "", ""	, "" ,  0  , .F. })
aAdd( aParam, { 1, "Data Inicial:" 			, CTOD("")					, ""    , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Data Final:" 			, CTOD("")					, ""    , "", ""	, "" , 70  , .F. })  
 

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

If !BkComR11Par()
   Return
EndIf
u_MsgLog(cPerg)

aCabs   := {}
aCampos := {}

aTitulos:= {}
AADD(aTitulos,"BKCOMR11/"+TRIM(cUserName)+" - "+cTitulo)

aFields := {}
aAdd(aFields,{"XX_NUM"		,"C8_NUM"})
aAdd(aFields,{"XX_ITEM"		,"C8_ITEM"})
aAdd(aFields,{"XX_PRODUTO"	,"C8_PRODUTO"})
aAdd(aFields,{"XX_DESC"		,"B1_DESC"})
aAdd(aFields,{"XX_EMISSAO"	,"C8_EMISSAO"})
aAdd(aFields,{"XX_FORNECE"	,"C8_FORNECE"})
aAdd(aFields,{"XX_LOJA"		,"C8_LOJA"})
aAdd(aFields,{"XX_NOME"		,"A2_NOME"})
aAdd(aFields,{"XX_CC"		,"C1_CC"})
aAdd(aFields,{"XX_DESC01"	,"CTT_DESC01"})
aAdd(aFields,{"XX_UM"		,"C8_UM"})
aAdd(aFields,{"XX_NUMSC"	,"C8_NUMSC"})
aAdd(aFields,{"XX_NUMPED"	,"C8_NUMPED"})
aAdd(aFields,{"XX_ITEMPED"	,"C8_ITEMPED"})
aAdd(aFields,{"XX_QUANT"	,"C8_QUANT"})
aAdd(aFields,{"XX_PRECO"	,"C8_PRECO"})
aAdd(aFields,{"XX_TOTALN"	,"","(cAliasQry)->((C8_QUANT*C8_PRECO) - C8_VLDESC + C8_VALFRE + C8_DESPESA+C8_SEGURO)","Total negociado",cPict,"N",15,2})
aAdd(aFields,{"XX_XXLCVAL"	,"C1_XXLCVAL"})
aAdd(aFields,{"XX_TOTALL"	,"","(cAliasQry)->(C1_XXLCVAL*C8_QUANT)","Total Estimado",cPict,"N",15,2})
aAdd(aFields,{"XX_ECONVL"	,"","(cAliasTrb)->(IIF(XX_TOTALL>0,(XX_TOTALL-XX_TOTALN),0))","Economia R$",cPict,"N",15,2})
aAdd(aFields,{"XX_ECONVP"	,"","(cAliasTrb)->(IIF(XX_TOTALL>0,(100-(XX_TOTALN/XX_TOTALL*100)),0))","Economia %",cPict,"N",15,2})

aAdd(aFields,{"XX_VLDESC"	,"C8_VLDESC"})
aAdd(aFields,{"XX_VLFRE"	,"C8_VALFRE"})
aAdd(aFields,{"XX_DESPESA"	,"C8_DESPESA"})
aAdd(aFields,{"XX_SEGURO"	,"C8_SEGURO"})

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
//oTmpTb:AddIndex("indice1", {"XX_NUM","XX_ITEM"} )
oTmpTb:Create()

Processa( {|| ProcBKCOMR11() })

MBrwBKCOMR11()

oTmpTb:Delete()
///(cAliasTrb)->(Dbclosearea())
///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())

Return



Static Function BkComR11Par
Local lRet := .F.
//   Parambox(aParametros,@cTitle          ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,"BKCOMR11 - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKCOMR11",.T.         ,.T.))
	lRet := .T.
	cCusto  := mv_par01
	cGrpPrd := mv_par02
	dDataI  := mv_par03
	dDataF  := mv_par04
	
	cTitulo := "Economia de Compras - Centro de Custos: "+TRIM(cCusto)+" - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
Endif
Return lRet



Static Function MBrwBKCOMR11()
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

AADD(aRotina,{"Exp. Excel"	,"U_CBKCOMR11",0,6})
AADD(aRotina,{"Parametros"	,"U_PBKCOMR11",0,8})
AADD(aRotina,{"Legenda"		,"U_LBKCOMR11",0,9})

dbSelectArea(cAliasTrb)
//dbSetOrder(1)
dbGoTop()
	
DEFINE DIALOG oDlg1;
 TITLE cTitulo ;
 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)

oGetDb1 := MsGetDb():New(aPosObj[1],aPosObj[2],aPosObj[3],aPosObj[4], 2, "AllwaysTrue()", "AllwaysTrue()",,,,,,"AllwaysTrue()",cAliasTrb)
nBrLin  :=1
oGetDb1:ForceRefresh()

aadd(aButton , { "BMPTABLE" , { || U_CBKCOMR11(), (cAliasTrb)->(dbGoTop()), nBrLin:=1, oGetDb1:ForceRefresh(), oDlg1:Refresh()}, "Gerar planilha" } )
aadd(aButton , { "BMPTABLE" , { || U_PBKCOMR11(), (cAliasTrb)->(dbGoTop()), nBrLin:=1, oGetDb1:ForceRefresh(), oDlg1:Refresh()}, "Parametros" } )
//aadd(aButton , { "BMPTABLE" , { || U_LBKCOMR04()}, "Legenda" } )
	
ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,{|| oDlg1:End()}, {||oDlg1:End()},, aButton)

Return Nil



User Function LBKCOMR11()
Local aLegenda := {}

AADD(aLegenda,{"BR_VERMELHO"," - Cancelado"})
AADD(aLegenda,{"BR_AMARELO"," - Em Elaboração" })
AADD(aLegenda,{"BR_AZUL" ," - Emitido"})
AADD(aLegenda,{"BR_LARANJA"," - Em Aprovação" })
AADD(aLegenda,{"BR_VERDE"," - Vigente" })
AADD(aLegenda,{"BR_CINZA"," - Paralisado" })
AADD(aLegenda,{"BR_MARRON"," - Sol. Finalização" })
AADD(aLegenda,{"BR_PRETO"," - Finalizado" })
AADD(aLegenda,{"BR_PINK"," - Revisão" })
AADD(aLegenda,{"BR_BRANCO"," - Revisado" })

BrwLegenda(cCadastro, "Legenda", aLegenda)

Return Nil




User FUNCTION PBKCOMR11()

If !BkComR11Par()
   Return Nil
EndIf

Processa( {|| ProcBKCOMR11() })

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
User FUNCTION CBKCOMR11()
Local aPlans  := {}

AADD(aPlans,{cAliasTrb,TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
U_PlanXlsx(aPlans,cTitulo,TRIM(cPerg),.F.,aParam)

Return 



Static Function ProcBKCOMR11
Local cQuery := ""
Local nReg := 0
Local nF

Private xCampo

LimpaBrw(cAliasTrb)


/*
SELECT C8_ITEM,C8_PRODUTO,C8_EMISSAO,C8_FORNECE,C8_LOJA,C8_UM,C8_NUMSC,C8_QUANT,C8_PRECO,C1_XXLCVAL,C8_VLDESC,C8_VALFRE,C8_DESPESA,C8_SEGURO,B1_DESC,C1_CC,CTT_DESC01,A2_NOME 
FROM SC8010 SC8 
INNER JOIN SB1010 SB1 ON SB1.B1_FILIAL='01' AND SC8.C8_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_='' 
INNER JOIN SC1010 SC1 ON SC1.C1_FILIAL='01' AND SC8.C8_NUMSC = SC1.C1_NUM AND SC8.C8_ITEMSC = SC1.C1_ITEM AND SC1.D_E_L_E_T_='' 
INNER JOIN CTT010 CTT ON CTT.CTT_FILIAL='01' AND SC1.C1_CC = CTT.CTT_CUSTO AND CTT.D_E_L_E_T_='' 
INNER JOIN SA2010 SA2 ON SA2.A2_FILIAL='  ' AND SC8.C8_FORNECE=SA2.A2_COD AND SC8.C8_LOJA=SA2.A2_LOJA AND SA2.D_E_L_E_T_='' 
WHERE SC8.C8_FILIAL='01' AND SC8.D_E_L_E_T_='' 
AND SC8.C8_EMISSAO >= '20190101' AND SC8.C8_EMISSAO <= '20190331' 
AND SC1.C1_CC = '258000429'

WHERE C8_NUMPED <> 'XXXXXX'

*/


cQuery := "SELECT C8_NUM,C8_ITEM,C8_PRODUTO,C8_EMISSAO,C8_FORNECE,C8_LOJA,C8_UM,C8_NUMSC,C8_NUMPED,C8_ITEMPED,C8_QUANT,C8_PRECO,C1_XXLCVAL,C8_VLDESC,C8_VALFRE,C8_DESPESA,C8_SEGURO,"
cQuery +=        "B1_DESC,C1_CC,CTT_DESC01,A2_NOME"
cQuery += " FROM "+RETSQLNAME("SC8")+" SC8"
cQuery += " INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON SB1.B1_FILIAL='" +xFilial("SB1")+"' AND SC8.C8_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_=''" 
cQuery += " INNER JOIN "+RETSQLNAME("SC1")+" SC1 ON SC1.C1_FILIAL='" +xFilial("SC1")+"' AND SC8.C8_NUMSC = SC1.C1_NUM AND SC8.C8_ITEMSC = SC1.C1_ITEM AND SC1.D_E_L_E_T_=''" 
cQuery += " INNER JOIN "+RETSQLNAME("CTT")+" CTT ON CTT.CTT_FILIAL='"+xFilial("CTT")+"' AND SC1.C1_CC = CTT.CTT_CUSTO AND CTT.D_E_L_E_T_=''" 
cQuery += " INNER JOIN "+RETSQLNAME("SA2")+" SA2 ON SA2.A2_FILIAL='" +xFilial("SA2")+"' AND SC8.C8_FORNECE=SA2.A2_COD AND SC8.C8_LOJA=SA2.A2_LOJA AND SA2.D_E_L_E_T_=''" 
 
cQuery += " WHERE SC8.C8_FILIAL='"+xFilial("SC8")+"' AND SC8.D_E_L_E_T_=''"
cQuery += "     AND SC8.C8_NUMPED <> 'XXXXXX'"
If !Empty(dDataI)
	cQuery += " AND SC8.C8_EMISSAO >= '"+DTOS(dDataI)+"'"
EndIf
If !Empty(dDataF)
	cQuery += " AND SC8.C8_EMISSAO <= '"+DTOS(dDataF)+"'"
EndIf          
If !Empty(cCusto)
	cQuery += " AND SC1.C1_CC = '"+ALLTRIM(cCusto)+"'" 
EndIf
If !Empty(cGrpPrd)
	cQuery += " AND SUBSTRING(SC8.C8_PRODUTO,1,3) = '"+ALLTRIM(cGrpPrd)+"'" 
EndIf
cQuery += " ORDER BY C8_NUM,C8_ITEM"

u_LogMemo("BKCOMR11.SQL",cQuery)

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
TCSetField(cAliasQry, "C8_EMISSAO","D",8,0)

ProcRegua((cAliasQry)->(LastRec()))

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
