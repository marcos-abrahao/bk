// Marcos - 01/02/2020
#INCLUDE "PROTHEUS.CH"

// Exemplo
User Function ExGera()
Local aParams := {}
Local aPlans  := {}
Local cTitRel := "Relatório Teste"
Local cArqXlsx := "EXGERAXLSX"
Local lClose  := .T.

Local aPlan   := {}
Local cPlan   := "GERAXLSX"
Local cTitPlan:= "Relatório Teste"
Local cQuery  := "SELECT A2_COD,A2_LOJA,A2_CGC,A2_NOME,A2_SALDUP,R_E_C_N_O_ FROM "+RetSqlName("SA2")+" WHERE A2_COD <= '000100'"
Local aCampos := {}
Local aCabs   := {}

mv_par01 := dDataBase - Day(dDataBase) + 1
mv_par01 := dDataBase

AADD(aParams,{"Data inicial",mv_par01})
AADD(aParams,{"Data Final"  ,mv_par02})

AADD(aPlan,cPlan)     // Nome da Planilha
AADD(aPlan,cTitPlan)  // Título da Planilha
AADD(aPlan,cQuery)    // Alias ou Query começando com "SELECT"
AADD(aPlan,aCampos)   // Campos
AADD(aPlan,aCabs)     // Cabeçalhos dos campos ou "XX_CAMPO" doc SX3

AADD(aPlans,aPlan)

MsAguarde({|| U_GeraXlsx(cTitRel,aParams,aPlans,cArqXlsx,"C:\TMP\",lClose)},"Aguarde","Gerando planilha...",.F.)

Return Nil


User Function GeraEx( _cTitulo,_aParams,_aPlans,_cArqXlsx,_cDirXlsx,_lClose)

Local oExcel 	:= YExcel():new()
Local nI 		:= 0
Local nJ		:= 0
Local cAlias 	:= ""
Local lQuery	:= .F.
Local cDirTmp   := ""

Local cPlan		:= ""
Local cTitPlan	:= ""
Local cQuery	:= ""
Local aCampos	:= {}
Local aCabs		:= {}
Local cCab  	:= ""
Local aStruct	:= {}


IF !Empty(_cDirXlsx)
	cDirTmp := _cDirXlsx
Else
	cDirTmp := GetTempPath()
EndIf

oExcel:new(_cArqXlsx)

For nI := 1 TO LEN(_aPlans)

	cPlan		:= _aPlans[nI,1]
	cTitPlan	:= _aPlans[nI,2]
	cAlias		:= _aPlans[nI,3]
	aCampos		:= _aPlans[nI,4]
	aCabs		:= _aPlans[nI,5]

	If UPPER(SUBSTR(cAlias,1,6)) == "SELECT"
		lQuery := .T.
		Processa( {|| cAlias := ProcQry(cAlias) })
	else
		cAlias := cQuery
	EndIf

	aStruct := (cAlias)->(dbStruct())
	If Empty(aCampos)
		aCampos := {}
		For nJ := 1 to len(aStruct)
			AADD(aCampos,aStruct[nJ,1])
		Next
	EndIf

	If Empty(aCabs)
		aCabs := {}
		aCabs := aClone(aCampos)
	EndIf



	oExcel:ADDPlan(cPlan,"0000FF")	//Adiciona nova planilha

	oExcel:SetPrintTitles(1,1)		//Linha de/ate que irá repetir na impressão de paginas
	//oExcel:showGridLines(.F.)		//Oculta linhas de grade
	oExcel:SetDefRow(.T.,{1,Len(aCampos)})		//Definir a coluna inicial e final da linha, importante para performace da classe

	oTabela	:= oExcel:AddTabela("Tabela"+ALLTRIM(STR(nI,2,0)),1,1)	//Cria uma tabela de estilos
	oTabela:AddStyle("TableStyleMedium15"/*cNome*/,.T./*lLinhaTiras*/,/*lColTiras*/,/*lFormPrimCol*/,/*lFormUltCol*/)	//Cria os estilos,Cab:Preto|Linha:Cinza,Branco
	oTabela:AddFilter()				//Adiciona filtros a tabela

	For nJ := 1 To Len(aCabs)
		cCab := aCabs[nj]
		If "_" $ cCab
			cCab := RetTitle(cCab)
			If Empty(cCab)
				cCab := aCabs[nj]
			EndIf
		EndIf
		oTabela:AddColumn(TRIM(cCab))		//Adiciona cabeçalho
		If aStruct[nj,2] == "C" .AND. aStruct[nj,3] > 11 

			oExcel:AddTamCol(nJ,nJ,aStruct[nj,3]*0.75)
		ENDIF
	NEXT

	oExcel:AddPane(1)	//Congela primeira linha //e primeira coluna


	(cAlias)->(dbgotop())

	Do While (cAlias)->(!eof()) 

		oTabela:AddLine()				//Adiciona nova linha

		For nJ :=1 to LEN(aCampos)

			xCampo := &(aCampos[nJ])
			oTabela:Cell(nJ,xCampo,,)

		Next

		(cAlias)->(dbskip())
	EndDo

	oTabela:AddTotal(aCabs[1],"TOTAL","")							//Preenche texto TOTAL na linha totalizadora da coluna Linha
	For nJ := 2 To Len(aStruct)
		If aStruct[nj,2] == "N"
			oTabela:AddTotal(aCabs[nJ],0,"SUBTOTAL(103,Tabela1["+aCabs[nJ]+"])")

			//oTabela:AddTotal(aCabs[nJ],0,"SUM")
		EndIf
	Next
	oTabela:AddTotais()	

	oTabela:Finish()	//Fecha a edição da tabela

Next

oExcel:Gravar(cDirTmp,.T.,.T.)
If _lClose
	(cAlias)->(dbCloseArea())
EndIf

Return



Static Function ProcQry(_cQuery)

Local cAliasQry := GetNextAlias()
Local nK		:= 0
Local aStruct 	:= {}

dbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), cAliasQry, .F., .T.)
aStruct := dbStruct()
For nk := 1 to Len(aStruct)
	If aStruct[nK,2] != 'C' .and. FieldPos(aStru[nK,1]) > 0
		TCSetField(cAliasQry, aStruct[nK,1], aStruct[nK,2],aStruct[nK,3],aStruct[nK,4])
	Endif
Next

Return cAliasQry
