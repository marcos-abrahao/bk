#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINR25
BK - Planilha diária de Pagamentos
@Return
@author Marcos Bispo Abrahão
@since 24/01/2020
@version P11
/*/
//-------------------------------------------------------------------

User Function BKFINR25()

Local nF  := 0

Private cTitulo     := "Planilha diária de Pagamentos"
Private cPerg       := "BKFINR25"

Private aParam		:=	{}
Private aRet		:=	{}

Private dDataI  	:= CTOD("")
Private dDataF  	:= CTOD("")

Private aFields     := {}
Private aCabs       := {}
Private aCampos     := {}
Private aTitulos    := {}
Private aPlans      := {}
Private aDbf        := {}
Private aHeader     := {}
Private cAliasQry   := ""
Private cAliasTrb   := GetNextAlias()
Private nCont       := 0

aAdd( aParam, { 1, "Data Inicial:" 	, dDataBase	, "" , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Data Final:" 	, dDataBase	, "" , "", ""	, "" , 70  , .F. })  

If !BkFR25()
   Return
EndIf


AADD(aTitulos,cPerg+"/"+TRIM(cUserName)+" - "+cTitulo)


aAdd(aFields,{"XX_FORNECE","E2_FORNECE"})
aAdd(aFields,{"XX_LOJA"   ,"E2_LOJA"})
aAdd(aFields,{"XX_NOMFOR" ,"E2_NOMFOR"})
aAdd(aFields,{"XX_PREFIXO","E2_PREFIXO"})
aAdd(aFields,{"XX_NUM"    ,"E2_NUM"})
aAdd(aFields,{"XX_XXTIPBK","E2_XXTIPBK"})
aAdd(aFields,{"XX_PARCELA","E2_PARCELA"})
aAdd(aFields,{"XX_VENCREA","E2_VENCREA"})
aAdd(aFields,{"XX_VALOR"  ,"E2_VALOR"})

//aAdd(aFields,{"XX_SALDO","","(cAliasTrb)->(XX_SALDO)","Saldo Consolidado",cPict,"N",18,2})


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

cArqTmp := CriaTrab( aDbf, .t. )
dbUseArea( .t.,NIL,cArqTmp,cAliasTrb,.f.,.f. )

//IndRegua(cAliasTrb,cArqTmp,"XX_NUM",,,"Indexando Arquivo de Trabalho") 

Processa( {|| ProcBKR25() })

//AADD(aPlans,{cAliasTrb,TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })

//MsAguarde({|| U_GeraXml(aPlans,cTitulo,TRIM(cPerg),.F.)},"Aguarde","Gerando planilha...",.F.)

//MsAguarde({|| BKFINE25(cAliasTrb,TRIM(cPerg),cTitulo,aCampos,aCabs)},"Aguarde","Gerando planilha...",.F.)
MsAguarde({|| BKFINX25(cAliasTrb,TRIM(cPerg),cTitulo,aCampos,aCabs)},"Aguarde","Gerando planilha...",.F.)

(cAliasTrb)->(Dbclosearea())
FErase(cArqTmp+GetDBExtension())
FErase(cArqTmp+OrdBagExt())

Return

Static Function BkFR25
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,@cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKFINR23",.T.         ,.T.))
	lRet     := .T.
	dDataI   := mv_par01
	dDataF   := mv_par02
	cTitulo  := "Planilha Diária de Pagamentos - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
Endif
Return lRet


Static Function ProcBKR25
Local cQuery := ""
Local nF     := 0

Private xCampo

cQuery := "SELECT "
For nF := 1 To Len(aFields)
	cQuery += aFields[nF,2]+","
Next
cQuery += "R_E_C_N_O_"

cQuery += " FROM "+RETSQLNAME("SE2")+" SE2" 

cQuery += " WHERE SE2.D_E_L_E_T_ = ' ' "
cQuery += " AND SE2.E2_FILIAL = '" + xFilial("SE2") + "' "
cQuery += " AND SE2.E2_TIPO NOT IN "+FormatIn(MVABATIM,";")
If !Empty(dDataI)
	cQuery += " AND SE2.E2_VENCREA >= '"+DTOS(dDataI)+"'"
EndIf
If !Empty(dDataF)
	cQuery += " AND SE2.E2_VENCREA <= '"+DTOS(dDataF)+"'"
EndIf          
cQuery += " ORDER BY E2_NUM"

MemoWrite("BKFINR25.SQL",cQuery)
	
cAliasQry := "TMPR25" //GetNextAlias()

//TCQUERY cQuery NEW ALIAS "TMPR25"

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPR25', .F., .T.)
TCSETFIELD(cAliasQry,"E2_VENCREA","D", 8,0)
TCSETFIELD(cAliasQry,"E2_VALOR"  ,"N",18,2)
	
ProcRegua((cAliasQry)->(RecCount()))
	
nCont := 0
	
dbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())
DO WHILE (cAliasQry)->(!EOF())
    nCont++
	IncProc("Consultando banco de dados...")
	dbSelectArea(cAliasTrb)
	Reclock(cAliasTrb,.T.)
		
	For nF := 1 To Len(aFields)
		If !Empty(aFields[nF,2])
			xCampo := &(cAliasQry+"->"+aFields[nF,2])
			&(cAliasTrb+"->"+aFields[nF,1]) :=  xCampo
		Else
			xCampo := &(aFields[nF,3])
		EndIf
		&(cAliasTrb+"->"+aFields[nF,1]) :=  xCampo
	Next
	(cAliasTrb)->(MsUnLock())
		
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbSkip())
ENDDO

(cAliasQry)->(dbCloseArea())

dbSelectArea(cAliasTrb)
dbGoTop()

Return



/*/{Protheus.doc} BKFINE25
Teste da classe YExcel
@author Saulo Gomes Martins
@since 08/05/2017

@type function
@obs para leitura ver função YxlsRead no fim do fonte
/*/
Static Function BKFINE25(cAliasTrb,cArqXlsx,cTitulo,aCampos,aCabs)
Local oExcel  := YExcel():new()
Local nTotal  := 0
Local nI 	:= 0
Local nJ	:= 0

oExcel:new(cArqXlsx)

oExcel:ADDPlan("Tabela","0000FF")		//Adiciona nova planilha

oExcel:SetPrintTitles(1,1)				//Linha de/ate que irá repetir na impressão de paginas
oExcel:showGridLines(.F.)		//Oculta linhas de grade
oExcel:SetDefRow(.T.,{1,Len(aCabs)})		//Definir a coluna inicial e final da linha, importante para performace da classe

oTabela	:= oExcel:AddTabela("Tabela1",1,1)	//Cria uma tabela de estilos
oTabela:AddStyle("TableStyleMedium15"/*cNome*/,.T./*lLinhaTiras*/,/*lColTiras*/,/*lFormPrimCol*/,/*lFormUltCol*/)	//Cria os estilos,Cab:Preto|Linha:Cinza,Branco
//oTabela:AddStyle("TableStyleMedium2"/*cNome*/,.T./*lLinhaTiras*/,/*lColTiras*/,.T./*lFormPrimCol*/,/*lFormUltCol*/)	//Cria os estilos,Cab:Azul|Linha:Azul,Branco
oTabela:AddFilter()				//Adiciona filtros a tabela

For nJ := 1 To Len(aCabs)
	oTabela:AddColumn(aCabs[nJ])		//Adiciona cabeçalho
NEXT

oExcel:AddPane(1,1)	//Congela primeira linha e primeira coluna

nTotal	:= 0	//Valor Total da venda

(cAliasTrb)->(dbgotop())

Do While (cAliasTrb)->(!eof()) 

	oTabela:AddLine()				//Adiciona nova linha

	For nI :=1 to LEN(aCampos)

		xCampo := &(aCampos[nI])
		oTabela:Cell(nI,xCampo,,)

	Next

	
	(cAliasTrb)->(dbskip())
EndDo
//oTabela:AddTotal(1,"TOTAL","")							//Preenche texto TOTAL na linha totalizadora da coluna Linha
//oTabela:AddTotal("Filial",99,"SUBTOTAL(103,Tabela1[Filial])")	//Usa função COUNTA(Contar Valores)
//oTabela:AddTotal(8,nTotal,"SUM")		//Usa função SUM(Somar) para totalizar a coluna venda
//oTabela:AddTotais()	//Adiciona linha de totais

oTabela:Finish()	//Fecha a edição da tabela

oExcel:Gravar(GetTempPath(),.T.,.T.)

return



Static Function BKFINX25(cAliasTrb,cArqXlsx,cTitulo,aCampos,aCabs)
Local oExcel  := YExcel():new()
Local nTotal  := 0
Local nI 	:= 0
Local nJ	:= 0
Local nLin  := 1

oExcel:new(cArqXlsx)

oExcel:ADDPlan("Livre","0000FF")		//Adiciona nova planilha

oAlinhamento	:= oExcel:Alinhamento("center","center")
nPosFont		:= oExcel:AddFont(10,"FFFFFFFF","Calibri","2")
nPosCor			:= oExcel:CorPreenc("9E0000")	//Cor de Fundo Azul
nPosBorda2		:= oExcel:Borda("ALL")

nPosStyle		:= oExcel:AddStyles(/*numFmtId*/,nPosFont/*fontId*/,nPosCor/*fillId*/,/*borderId*/,/*xfId*/,{oAlinhamento})
nPosBordas		:= oExcel:AddStyles(/*numFmtId*/,/*fontId*/,/*fillId*/,nPosBorda2/*borderId*/,/*xfId*/,)

For nJ := 1 To Len(aCabs)
	oExcel:Cell(1,nJ,aCabs[nJ],,nPosBordas)
NEXT


oExcel:AddTamCol(11,11,45.00)



(cAliasTrb)->(dbgotop())

Do While (cAliasTrb)->(!eof()) 

	nLin++

	For nI :=1 to LEN(aCampos)

		xCampo := &(aCampos[nI])
		//oTabela:Cell(nI,xCampo,,)
		//oExcel:Cell(nCont,nI,xCampo,,nPosBordas)
		oExcel:Cell(nLin,nI,xCampo)

	Next

	if nLin == 3
		oExcel:AddNome("VALORES",2,9,nCont+1,9)				//Defini o nome do intervalo
		oExcel:Cell(3,11,"PESSOAL",,nPosStyle)
	EndIf
	if nLin == 4
		oExcel:Cell(4,12,202,"SUM(VALORES)")  // =SOMASE(F2:F77;"=VA";I2:I77)	
	EndIf

	(cAliasTrb)->(dbskip())
EndDo

oExcel:Gravar(GetTempPath(),.T.,.T.)
return

