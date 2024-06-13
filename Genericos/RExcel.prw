#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#define XALIAS_ 1
#define XORDER_ 2
#define XKEY_ 3
#define XRECNO_ 4

#define XCONDICAO 1
#define XCORFONTE 2
#define XCORFUNDO 3
#define XSIZE	  4
#define XITALIC	  5
#define XBOLD 	  6
#define XUNDER	  7


// Exemplo do uso da classe RExcel
User Function BKCOMR18
Local cProg 	:= "BKCOMR18"
Local cTitulo	:= "Produtos x Rentabilidade"
Local cDescr 	:= "O objetivo deste relatório é para análise de produtos contemplados nos relatórios de rentabilidade da BK."
Local cVersao	:= "21/11/2023"
Local oRExcel	AS Object
Local oPExcel	AS Object
Local cQuery 	:= ""
Local cAlias 	:= "TMP"
Local cCusBK	:= U_MVXCUSBK()
Local aTcFields := {}
Local aRet		:= {}
Local aParam 	:= {}

Private cB1Blq := {}
aAdd( aParam ,{ 2, "Listar bloqueados", cB1Blq  ,{"Sim", "Não"}	, 60,'.T.'  ,.T.})

If !ParCom18(cProg,cTitulo,@aRet,aParam)
   Return
EndIf

cQuery := "SELECT "+CRLF
cQuery += "  B1_COD "+CRLF
cQuery += " ,B1_DESC "+CRLF
cQuery += " ,B1_CONTA "+CRLF
cQuery += " ,B1_USERLGA "+CRLF
cQuery += " ,B1_UREV "+CRLF
cQuery += " ,B1_CODISS "+CRLF
cQuery += " ,B1_ALIQISS "+CRLF
cQuery += " ,CT1_DESC01 "+CRLF
cQuery += " ,CASE WHEN "+CRLF
cQuery += "      (SUBSTRING(B1_CONTA,1,1) = '3'" + CRLF
cQuery += "      OR B1_CONTA IN ('"+cCusBK+"') " + CRLF
cQuery += "      OR SUBSTRING(B1_CONTA,1,5) IN ('12201','12105') " + CRLF
cQuery += "      OR SUBSTRING(B1_CONTA,1,3) IN ('124','126')) " + CRLF  // Ativo Imobilizado
cQuery += "    THEN 'Sim' ELSE 'Não' END AS RENTAB "+CRLF
cQuery += " FROM "+RetSqlName("SB1")+" SB1 "+CRLF
cQuery += " LEFT JOIN "+RetSqlName("CT1")+" CT1 ON "+CRLF
cQuery += "  	CT1_CONTA = B1_CONTA "+CRLF
cQuery += "  	AND CT1.D_E_L_E_T_ = '' "+CRLF
cQuery += " WHERE SB1.D_E_L_E_T_ = '' "+CRLF
cQuery += "     AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "+CRLF
If SUBSTR(cB1Blq,1,1) == 'S'
	cQuery += "     AND SB1.B1_MSBLQL != '1' "+CRLF
EndIf

//cQuery += " 	SUBSTRING(B1_CONTA,1,1) = '1' "+CRLF
cQuery += " ORDER BY CT1_CONTA "+CRLF

aAdd(aTcFields,FWSX3Util():GetFieldStruct( "B1_UREV" ))
aAdd(aTcFields,FWSX3Util():GetFieldStruct( "B1_ALIQISS" ))

u_RunQuery(cProg,cQuery,cAlias,aTcFields)


// Definição do Arq Excel
oRExcel := RExcel():New(cProg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetVersao(cVersao)
oRExcel:SetDescr(cDescr)
oRExcel:SetParam(aParam)

// Definição da Planilha 1
oPExcel:= PExcel():New(cProg,cAlias)
oPExcel:SetTitulo("Utilização: conferência da Rentabilidade")
If __cUserId == "000000"  // Para teste do resumo
	oPExcel:AddResumos("Contagem de Contas","B1_CONTA","B1_CONTA")
EndIf

// Colunas da Planilha 1
oPExcel:AddColX3("B1_COD")
oPExcel:AddColX3("B1_DESC")
oPExcel:AddColX3("B1_CONTA")
oPExcel:AddColX3("CT1_DESC01")
oPExcel:AddCol("RENTAB","RENTAB","Rentabilidade","")

oPExcel:AddCol("USUARIO","Capital(TMP->(FWLeUserlg('B1_USERLGA',1)))","Usuário","")
oPExcel:GetCol("USUARIO"):SetTamCol(30)

oPExcel:AddColX3("B1_UREV")

// Adiciona a planilha 1
oRExcel:AddPlan(oPExcel)


// Definição da Planilha 2
oPExcel:= PExcel():New("ISS",cAlias)
oPExcel:SetTitulo("Produtos x Alíquota de ISS")
If __cUserId == "000000"  // Para teste do resumo
	oPExcel:AddResumos("Cod. Iss X Aliq ISS","B1_CODISS","B1_ALIQISS")
EndIf
oRExcel:AddPlan(oPExcel)

// Colunas da Planilha 2
oPExcel:AddColX3("B1_COD")
oPExcel:AddColX3("B1_DESC")
oPExcel:AddColX3("B1_CODISS")

oPExcel:AddColX3("B1_ALIQISS")
oPExcel:GetCol("B1_ALIQISS"):SetFormat("#,##0.0000")
oPExcel:GetCol("B1_ALIQISS"):SetTotal(.T.)

// Cria arquivo Excel
oRExcel:Create()

(cAlias)->(dbCloseArea())

Return Nil


Static Function ParCom18(cProg,cTitulo,aRet,aParam)
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cProg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cProg      ,.T.         ,.T.))
	lRet	:= .T.
	cB1Blq	:= mv_par01
Endif
Return lRet


//-------------------------------------------------------------------------------------------//


//Dummy Function
User Function RExcel()
Return .T.


CLASS RExcel

	// Declaracao das propriedades da Classe
	DATA cPrw
	DATA cPerg
	DATA cAlias
	DATA cTitulo
	DATA cSolicit
	DATA cDescr
	DATA cVersao
	DATA cFile
	DATA cDirDest
	DATA cDirTmp
	DATA cFileR
	DATA cFileX
	DATA oFileW		AS Object
	DATA oPrtXlsx	AS Object
	DATA aPlans		AS Array
	DATA aParam 	AS Array

	// Declaração dos Métodos da Classe
	METHOD New(cProg) CONSTRUCTOR

	METHOD GetTitulo()
	METHOD SetTitulo(cTitulo)

	METHOD GetSolicit()
	METHOD SetSolicit(cSolicit)

	METHOD GetDescr()
	METHOD SetDescr(cDescr)

	METHOD GetVersao()
	METHOD SetVersao(cVersao)

	METHOD GetPerg()
	METHOD SetPerg(cPerg)

	METHOD GetParam()
	METHOD SetParam(aParam)

	METHOD Create()

	METHOD RunCreate()

	METHOD AddPlan(oPlan)

ENDCLASS

// Getters/Setters
METHOD GetTitulo() CLASS RExcel
Return Self:cTitulo

METHOD SetTitulo(cTitulo) CLASS RExcel
Self:cTitulo := Alltrim(cTitulo)
Return

METHOD GetSolicit() CLASS RExcel
Return Self:cSolicit

METHOD SetSolicit(cSolicit) CLASS RExcel
Self:cSolicit := Alltrim(cSolicit)
Return

METHOD GetDescr() CLASS RExcel
Return Self:cDescr

METHOD SetDescr(cDescr) CLASS RExcel
Self:cDescr := Alltrim(cDescr)
Return

METHOD GetVersao() CLASS RExcel
Return Self:cVersao

METHOD SetVersao(cVersao) CLASS RExcel
Self:cVersao := Alltrim(cVersao)
Return

METHOD GetPerg() CLASS RExcel
Return Self:cPerg

METHOD SetPerg(cPerg) CLASS RExcel
Self:cPerg := cPerg
Return

METHOD GetParam() CLASS RExcel
Return Self:aParam

METHOD SetParam(aParam) CLASS RExcel
Self:aParam := aParam
Return


// Criação do construtor, onde atribuimos os valores default 
// para as propriedades e retornamos Self
METHOD New(cProg) CLASS RExcel

Self:cPrw 		:= cProg
Self:cPerg 		:= cProg
Self:cDescr 	:= ""
Self:aParam		:= {}
Self:cDirDest	:= IIf(!IsBlind(),"c:\tmp\","\tmp\")
Self:cDirTmp 	:= "\tmp\"
Self:cFile 		:= TRIM(cProg)+"-"+cEmpAnt+"-"+DTOS(Date())+"-"+STRTRAN(TIME(),":","")
Self:cFileR 	:= Self:cDirTmp+Self:cFile+".rel"
Self:cFileX 	:= Self:cDirTmp+Self:cFile+".xlsx"

MakeDir(Self:cDirTmp)
MakeDir(Self:cDirDest)

Self:oFileW		:= FwFileWriter():New(Self:cFileR)
Self:oPrtXlsx	:= FwPrinterXlsx():New()

// Apagar arquivo .rel (não deveria existir neste ponto)
If file(Self:cFileR)
	FErase(self:cFileR)
EndIf

Self:oPrtXlsx:Activate(Self:cFileR, Self:oFileW)

Self:aPlans 	:= {}

Return Self


METHOD Create() CLASS RExcel
Local cArqXls

u_WaitLog(Self:cPrw,{ |oSay| cArqXls := Self:RunCreate(oSay)},"Construindo arquivo .xlsx...")

Return cArqXls


METHOD RunCreate(oSayMsg) CLASS RExcel

Local cFileL		:= ""
Local nRet			:= 0
Local lFirst 		:= .T.
Local nC 			:= 0
Local nI 			:= 0
Local nP			:= 0
Local nR 			:= 0
Local nS 			:= 0
Local nX 			:= 0
Local nM 			:= 0
Local cFont			:= FwPrinterFont():Calibri()
Local nLin 			:= 1
Local nTop			:= 1
Local nLast 		:= 1
Local nCont 		:= 0
Local nOpcFile		:= 1

// Variáveis para uso na formatação de celulas
Local oCellHorAlign := FwXlsxCellAlignment():Horizontal()
Local oCellVertAlign:= FwXlsxCellAlignment():Vertical()

// Alinhamentos horizontais
Local cHorAligD 	:= oCellHorAlign:Default()
Local cHorAligR 	:= oCellHorAlign:Right()
Local cHorAligL 	:= oCellHorAlign:Left()
Local cHorAligC 	:= oCellHorAlign:Center()

// Alinhamento Vertical 
Local cVerAligC 	:= oCellVertAlign:Center()

// Formatação padrão das linhas de dados
Local nLSize 		:= 9
Local lLItalic 		:= .F.
Local lLBold 		:= .F.
Local lLUnderl		:= .F.
Local cLHorAlig		:= cHorAligD
Local cLVertAlig	:= cVerAligC
Local lLWrapText	:= .F.
Local nLRotation	:= 0

// Estilo trocado
Local lChange 		:= .F.
Local nCSize 		:= 9
Local lCItalic 		:= .F.
Local lCBold 		:= .F.
Local lCUnderl		:= .F.


// Formatação das células do cabeçalho
Local nHSize 		:= 9
Local lHItalic 		:= .F.
Local lHBold 		:= .T.
Local lHUnderl		:= .F.
Local cHHorAlig		:= cHorAligC
Local cHVertAlig	:= cVerAligC
Local lHWrapText	:= .T.
Local nHRotation	:= 0

// Variavés para uso na planilha de parâmetros
Local aParam 		:= {}
Local aLocPar 		:= {}
Local oObjPerg  	As Object
Local aPergunte		:= {}
Local cVarDef 		:= ""

// Variavés para leitura do Logotipo
Local cStartPath 	:= GetSrvProfString( "StartPath", "" ) 
Local cImgRel 		:= 'logo'
Local cImgDir 		:= cStartPath + "lgmid"+cEmpAnt+".png"
Local nHndImagem 	:= 0
Local nLenImagem 	:= 0
Local cBuffer		:= ""

// Formatação do Cabeçalho 
Local nTSize1 		:= 18
Local nTSize2 		:= 14
Local nTSize3 		:= 9
Local lTItalic 		:= .F.
Local lTBold 		:= .T.
Local lTUnderl		:= .F.
Local cTHorAlig		:= oCellHorAlign:Default()
Local cTVertAlig	:= oCellVertAlign:Center()
Local lTWrapText 	:= .F.
Local nTRotation 	:= 0

// Cores Básicas
// Vermelho		FF0000 
// Azul			0000FF
// Verde		008000
// Amarelo		FFFF00
// Laranja 		FFA500
// Laranja2		E26B0A


Local cCorN			:= "000000" // Cor Preta
Local cFundoN		:= "FFFFFF" // Fundo Branco

Local cCorS			:= "FFFFFF" // Cor Branca
Local cFundoS		:= "9E0000" // Fundo Vermelho BK

Local cCorS1		:= "000000" // Cor Preta
Local cFundoS1		:= "FFB3B3" // Sundown

Local cCorLink 		:= "0000FF" // Azul

/*

Local cCorS2		:= "000000" // Cor Preta
Local cFundoS2		:= "9ACD32" // Fundo YellowGreen
*/

// Atributos da Planilha
Local oPlan			AS Object
Local cFiltro 		:= ""
Local cAlias 		:= ""
Local aResumos		:= {}
Local aNResumos		:= {}
Local aMatriz 		:= []

// Atributos da Linha
Local aStruct 		:= {}
Local aX3Stru 		:= {}
Local cTipo   		:= ""
Local cCampo 		:= ""
Local nField 		:= 0
Local nTamanho		:= 0
Local nDecimal		:= 0
Local nTamCol		:= 0
Local cFormat 		:= ""
Local cCorFonte 	:= cCorN
Local cCorFundo 	:= cFundoN
Local cCorAntes 	:= ""
Local aCor 			:= {}
Local cHAlign 		:= "D"
Local lWrap 		:= .F.
Local cOHAlign		:= ""
Local aLinha 		:= {}
Local cName 		:= ""
Local lEstilo		:= .F.
Local cColuna 		:= ""

// Variaveis usadas para Formulas
Local cColLin 		:= ""

// Variaveis usadas no totalizador
Local cColExcel		:= ""
Local cLinExcel		:= ""
Local cLinTop		:= ""
Local nLinR 		:= 0

// Variaveis usadas no resumo
Local cTipoVal 		:= ""

Default oSayMsg		:= Nil
// Campo para Macro
Private xCampo
Private axCampo
Private yCampo

// Inicialização do Logo
nHndImagem := fOpen(cImgDir, FO_READ)
if nHndImagem >= 0
	nLenImagem := fSeek( nHndImagem, 0, FS_END)
	fSeek( nHndImagem, 0, FS_SET)
	fRead( nHndImagem, @cBuffer, nLenImagem)
EndIf
fClose(nHndImagem)

// Percorre as Planilhas
For nP := 1 To Len(Self:aPlans)
	
	oPlan		:= Self:aPlans[nP]

	// Adiciona nova planilha
	Self:oPrtXlsx:AddSheet(oPlan:GetPlan())

    cFont   := FwPrinterFont():Calibri()
	Self:OPrtXlsx:SetBorder(.F.,.F.,.F.,.F.,FwXlsxBorderStyle():Thin(),"000000")

	// Formatação do cabeçalho
    Self:oPrtXlsx:SetFont(cFont, nTSize1, lTItalic, lTBold, lTUnderl)
    Self:oPrtXlsx:SetCellsFormat(cTHorAlig, cTVertAlig, lTWrapText, nTRotation,cCorN, cFundoN, "" )

	nLin := 1

	// Logo
    if nHndImagem >= 0
		Self:oPrtXlsx:AddImageFromBuffer(1, 1, cImgRel, cBuffer, 39, 39)
	EndIf


	// Titulo do Xls
	If !Empty(Self:cTitulo)
		Self:oPrtXlsx:SetValue(nLin,2,Self:cTitulo)
		nLin++
	EndIf

	// Titulo da Planilha
	If !Empty(oPlan:GetTitulo())
		Self:oPrtXlsx:SetFont(cFont, nTSize2, lTItalic, lTBold, lTUnderl)
		Self:oPrtXlsx:SetValue(nLin,2,oPlan:GetTitulo())
		nLin++
	Else
		// Titulo padrão
		//Self:oPrtXlsx:SetFont(cFont, nTSize3, lTItalic, lTBold, lTUnderl)
		//Self:oPrtXlsx:SetValue(nLin,2,Self:cPrw+" - Data base: "+DTOC(dDataBase) +" - Emitido em: "+DTOC(DATE())+"-"+SUBSTR(TIME(),1,5)+" - "+cUserName)
		nLin++
	EndIf

	// Salva a primeira linha de dados (subtotal)
	nTop := nLin + 1

	// Formatação do cabeçalho
    Self:oPrtXlsx:SetFont(cFont, nHSize, lHItalic, lHBold, lHUnderl)
    Self:oPrtXlsx:SetCellsFormat(cHHorAlig, cHVertAlig, lHWrapText, nHRotation, cCorS, cFundoS, "" )

	Self:OPrtXlsx:SetBorder(.T.,.T.,.T.,.T.,FwXlsxBorderStyle():Thin(),"000000")


	// Montagem da linha de titulos das colunas
	For nC := 1 To Len(oPlan:aColunas)
        Self:oPrtXlsx:SetValue(nLin,nC,oPlan:aColunas[nC]:cTitulo)
	Next

	// Formatação das linhas normais
    Self:oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
    Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )

	cCorFonte	:= cCorN
	cCorFundo	:= cFundoN
	cCorAntes	:= ""
	lFirst		:= .T.
	nCont 		:= 0

	// Planilha com Alias informado
	If !Empty(oPlan:cAlias)
		cAlias		:= oPlan:cAlias
		cFiltro		:= oPlan:cFiltro
		aResumos	:= aClone(oPlan:aResumos)

		// Monta array temporário para armazenar numero das colunas e valores
		aNResumos 	:= {}
		For nR := 1 To Len(aResumos)
			aAdd(aNResumos,{aResumos[nR,1],0,0,{}})
		Next

		// Estrutura da Query
		aStruct 	:= (cAlias)->(dbStruct())

		dbSelectArea(cAlias)
		If !Empty(cFiltro)
			(cAlias)->(dbSetFilter({|| &cFiltro} , cFiltro))
		Else
			(cAlias)->(dbClearFilter())
		Endif
		(cAlias)->(dbGoTop())
		
		//u_MsgLog("REXCEL",cFiltro,"")

		Do While (cAlias)->(!Eof()) 
			nLin++
			nCont++
			aLinha := {}

			For nC := 1 To Len(oPlan:aColunas)

				// Pega os atributos da Coluna
				cTipo 	:= oPlan:aColunas[nC]:GetTipo()
				nTamanho:= oPlan:aColunas[nC]:GetTamanho()
				nDecimal:= oPlan:aColunas[nC]:GetDecimal()
				nTamCol	:= oPlan:aColunas[nC]:GetTamCol()
				lTotal	:= oPlan:aColunas[nC]:GetTotal()
				cFormat	:= oPlan:aColunas[nC]:GetFormat()
				cHAlign := oPlan:aColunas[nC]:GetHAlign()
				nField	:= oPlan:aColunas[nC]:GetField()
				aCor	:= oPlan:aColunas[nC]:GetCor()

				// Atributos que não precisam ser atualizados
				lWrap   := oPlan:aColunas[nC]:GetWrap()
				cName   := oPlan:aColunas[nC]:GetName()
				cColuna := oPlan:aColunas[nC]:GetColuna()

				// Pega o conteúdo do campo
				cCampo	:= oPlan:aColunas[nC]:cCampo
				If nField > 0
					xCampo := FieldGet(nField)
				Else
					xCampo	:= &(cCampo)
				EndIf

				If lFirst
					// Ajusta os atributos informados ou default

					// Pega posição do campo (salvar em nField)
					nS := aScan(aStruct,{ |x| x[1] == cCampo })
					If nS > 0
						nField := nS
					EndIf

					// Pega informações da Estrutura da Query
					If nS > 0
						If Empty(cTipo)
							cTipo		:= aStruct[nS,2]
						EndIf
						If Empty(nTamanho)
							nTamanho	:= aStruct[nS,3]
						EndIf
						If Empty(nDecimal)
							nDecimal	:= aStruct[nS,4]
						EndIf
					EndIf

					// Pega informações da Coluna
					If Empty(cTipo)
						cTipo 	:= ValType(xCampo)
					EndIf
					If Empty(nTamanho)
						If "N" $ cTipo
							nTamanho := 15
							nDecimal := 2
						ElseIf "D" $ cTipo
							nTamanho := 8
						ElseIf "C" $ cTipo .OR. "M" $ cTipo
							nTamanho := Len(xCampo)
						EndIf
					EndIf
		
					//Calcula o tamanho da coluna excel
					If Empty(nTamCol)
						nTamCol := 8
						If "N" $ cTipo
							nTamCol := 15
						ElseIf "D" $ cTipo
							nTamCol := 10
						ElseIf "C" $ cTipo .OR. "M" $ cTipo
							If Len(xCampo) > 8
								If Len(xCampo) < 150
									nTamCol := Len(xCampo) + 1
								Else
									nTamCol := 150
								EndIf
							EndIf
						EndIf
					EndIf

					If Empty(cFormat)
						//Numerico
						If "N" $ cTipo
							cFormat := "#,##0"
							If nDecimal > 0
								cFormat += "."+REPLICATE("0",nDecimal)
							EndIf
							cFormat := cFormat+";[Red]-"+cFormat
						// Numerico %
						ElseIf "P" $ cTipo
							cFormat  := "0"
							If nDecimal > 0
								cFormat += "."+REPLICATE("0",nDecimal)+"%"
							Else
								cFormat += "%"
							EndIf
							cFormat := cFormat+";[Red]-"+cFormat
						// Data
						ElseIf "D" $ cTipo
							cFormat := "dd/mm/yyyy"
							// Se o campo vier em branco, setar cFormat para "" no momento de gerar a celula
						EndIf

					EndIf

					// Converter nome da coluna em numero da coluna
					If Len(aNResumos) > 0 .AND. !Empty(cName)
						For nR := 1 To Len(aNResumos)
							If aResumos[nR,2] == cName
								aNResumos[nR,2] := nC
							EndIf
							If aResumos[nR,3] == cName
								aNResumos[nR,3] := nC
							EndIf
						Next
					EndIf

					// Sempre centralizar campo tipo Data
					If "D" $ cTipo
						cHAlign := "C"
					EndIf

					// Salva os atributos
					oPlan:aColunas[nC]:SetTipo(cTipo)
					oPlan:aColunas[nC]:SetTamanho(nTamanho)
					oPlan:aColunas[nC]:SetDecimal(nDecimal)
					oPlan:aColunas[nC]:SetTamCol(nTamCol)
					oPlan:aColunas[nC]:SetTotal(lTotal)
					oPlan:aColunas[nC]:SetFormat(cFormat)
					oPlan:aColunas[nC]:SetHAlign(cHAlign)
					oPlan:aColunas[nC]:SetField(nField)

					// Aplica o tamanho da coluna
					Self:oPrtXlsx:SetColumnsWidth(nC,nC,nTamCol)

				EndIf

				// Padrão anterior
				//Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorFonte, cCorFundo, cFormat )

				If cHAlign == "C"
					cOHAlign := cHorAligC
				ElseIf cHAlign == "L"
					cOHAlign := cHorAligL
				ElseIf cHAlign == "R"
					cOHAlign := cHorAligR
				Else
					cOHAlign := cHorAligD
				EndIf

				cCorFonte	:= cCorN
				cCorFundo	:= cFundoN
				nCSize		:= nLSize
				lCItalic	:= lLItalic
				lCBold		:= lLBold
				lCUnderl	:= lLUnderl

				lChange 	:= .F.
				If Len(aCor) > 0
					For nX := 1 To Len(aCor)
						If Eval(aCor[nX,XCONDICAO],xCampo)
							If !Empty(aCor[nX,XCORFONTE])
								cCorFonte := aCor[nX,XCORFONTE]
							EndIf
							If !Empty(aCor[nX,XCORFUNDO])
								cCorFundo := aCor[nX,XCORFUNDO]
							EndIf
							If !Empty(aCor[nX,XSIZE])
								nCSize := aCor[nX,XSIZE]
								lChange	 := .T.
							EndIf
							If !Empty(aCor[nX,XITALIC])
								lCItalic := aCor[nX,XITALIC]
								lChange	 := .T.
							EndIf
							If !Empty(aCor[nX,XBOLD])
								lCBold := aCor[nX,XBOLD]
								lChange	 := .T.
							EndIf
							If !Empty(aCor[nX,XUNDER])
								lCUnderl := aCor[nX,XUNDER]
								lChange	 := .T.
							EndIf
						EndIf
					Next
				EndIf
				If lChange
					Self:oPrtXlsx:SetFont(cFont, nCSize, lCItalic, lCBold, lCUnderl)
				EndIf

				Self:oPrtXlsx:SetCellsFormat(cOHAlign, cLVertAlig, lWrap, nLRotation, cCorFonte, cCorFundo, cFormat )

				If "F" $ cTipo
					If "HYPERLINK" $ UPPER(xCampo)
						Self:oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, .T.)
						Self:oPrtXlsx:SetCellsFormat(cOHAlign, cLVertAlig, lWrap, nLRotation, cCorLink, cCorFundo, cFormat )
					ElseIf "##" $ cCampo
						// Exemplo: 
						//	oPExcel:AddCol("TOTAL","'=##C1_QUANT##*##C1_XXLCVAL##'","Total","")
						//	oPExcel:GetCol("TOTAL"):SetTipo("FN")
						//	oPExcel:GetCol("TOTAL"):SetTotal(.T.)
						nx := 1
						Do While nX <= Len(oPlan:aColunas) .AND. "##" $ cCampo
							cColLin := oPlan:aColunas[nX]:GetColuna()+ALLTRIM(STR(nLin))
							cFCampo := "##"+oPlan:aColunas[nX]:GetName()+"##"
							If cFCampo $ xCampo
								xCampo := STRTRAN(xCampo,cFCampo,cColLin)
							EndIf
							nX++
						EndDo
					EndIf

					If !Empty(xCampo)
						Self:oPrtXlsx:SetFormula(nLin,nC,xCampo)
					Else
						Self:oPrtXlsx:SetValue(nLin,nC,"")
					EndIf
					lChange := .T.
					
				ElseIf "D" $ cTipo
					If !Empty(xCampo)
						Self:oPrtXlsx:SetValue(nLin,nC,xCampo)
					Else
						Self:oPrtXlsx:SetValue(nLin,nC,"")
					EndIf
				Else
					Self:oPrtXlsx:SetValue(nLin,nC,xCampo)
				EndIf

				// Quarda elementos da linha para montagem dos resumos
				If !Empty(aNResumos)
					aAdd(aLinha,xCampo)
				EndIf

				// Voltar estilo padrão
				If lChange
					Self:oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
				EndIf

			Next

			//u_MsgLog("REXCEL","aLinha","",VarInfo("aLinha",aLinha))
			//u_MsgLog("REXCEL","aNResumos","",VarInfo("aNResumos",aNResumos))

			// Monta os resumos
			If !Empty(aNResumos)
				For nR := 1 To Len(aNResumos)
					cTipoVal := ValType(aLinha[aNResumos[nR,3]])
					If Len(aNResumos[nR,4]) > 0
						nS := Ascan(aNResumos[nR,4],{|x| x[1] == aLinha[aNResumos[nR,2]]})
						If nS == 0
							aAdd(aNResumos[nR,4],{aLinha[aNResumos[nR,2]],iIf(cTipoVal=='N',aLinha[aNResumos[nR,3]],1)})
						Else
							If cTipoVal == "N"
								aNResumos[nR,4,nS,2] += aLinha[aNResumos[nR,3]]
							Else
								aNResumos[nR,4,nS,2]++
							EndIf
						EndIf
					Else
						aAdd(aNResumos[nR,4],{aLinha[aNResumos[nR,2]],iIf(cTipoVal=='N',aLinha[aNResumos[nR,3]],1)})
					EndIf
				Next
			EndIf

			lFirst := .F.
			(cAlias)->(dbSkip())
		EndDo

	Else  
		// Matriz informada

		aMatriz 	:= oPlan:aMatriz
		aResumos	:= aClone(oPlan:aResumos)

		// Monta array temporário para armazenar numero das colunas e valores
		aNResumos 	:= {}
		For nR := 1 To Len(aResumos)
			aAdd(aNResumos,{aResumos[nR,1],0,0,{}})
		Next

		// Estrutura da Matriz
		// ???

		For nM := 1 To Len(aMatriz)
			nLin++
			nCont++
			aLinha  := {}
			axCampo := {}

			For nC := 1 To Len(oPlan:aColunas)

				// Pega os atributos da Coluna
				cTipo 	:= oPlan:aColunas[nC]:GetTipo()
				nTamanho:= oPlan:aColunas[nC]:GetTamanho()
				nDecimal:= oPlan:aColunas[nC]:GetDecimal()
				nTamCol	:= oPlan:aColunas[nC]:GetTamCol()
				lTotal	:= oPlan:aColunas[nC]:GetTotal()
				cFormat	:= oPlan:aColunas[nC]:GetFormat()
				cHAlign := oPlan:aColunas[nC]:GetHAlign()
				nField	:= oPlan:aColunas[nC]:GetField()
				aCor	:= oPlan:aColunas[nC]:GetCor()

				// Atributos que não precisam ser atualizados
				lWrap   := oPlan:aColunas[nC]:GetWrap()
				cName   := oPlan:aColunas[nC]:GetName()
				cColuna := oPlan:aColunas[nC]:GetColuna()

				// Pega o conteúdo do campo
				cCampo	:= oPlan:aColunas[nC]:cCampo

				xCampo	:= aMatriz[nM,nC]

				// Se alguma formula ADVPL for informada
				If (!Empty(cCampo) .AND. "(" $ cCampo) .OR. "F" $ cTipo
					xCampo	:= &(cCampo)
				EndIf

				// Guarda o resultado em um arrqy Private para acesso externo
				aAdd(axCampo,xCampo)

				If lFirst
					// Ajusta os atributos informados ou default

					// Pega posição do campo (salvar em nField)
					/*
					nS := aScan(aStruct,{ |x| x[1] == cCampo })
					If nS > 0
						nField := nS
					EndIf

					// Pega informações da Estrutura da Query
					If nS > 0
						If Empty(cTipo)
							cTipo		:= aStruct[nS,2]
						EndIf
						If Empty(nTamanho)
							nTamanho	:= aStruct[nS,3]
						EndIf
						If Empty(nDecimal)
							nDecimal	:= aStruct[nS,4]
						EndIf
					EndIf
					*/

					// Pega informações da Coluna
					If Empty(cTipo)
						cTipo 	:= ValType(xCampo)
					EndIf
					If Empty(nTamanho)
						If "N" $ cTipo
							nTamanho := 15
							nDecimal := 2
						ElseIf "D" $ cTipo
							nTamanho := 8
						ElseIf "C" $ cTipo .OR. "M" $ cTipo
							nTamanho := Len(xCampo)
						EndIf
					EndIf
		
					//Calcula o tamanho da coluna excel
					If Empty(nTamCol)
						nTamCol := 8
						If "N" $ cTipo
							nTamCol := 15
						ElseIf "D" $ cTipo
							nTamCol := 10
						ElseIf "C" $ cTipo .OR. "M" $ cTipo
							If Len(xCampo) > 8
								If Len(xCampo) < 150
									nTamCol := Len(xCampo) + 1
								Else
									nTamCol := 150
								EndIf
							EndIf
						EndIf
					EndIf

					If Empty(cFormat)
						//Numerico
						If "N" $ cTipo
							cFormat := "#,##0"
							If nDecimal > 0
								cFormat += "."+REPLICATE("0",nDecimal)
							EndIf
							cFormat := cFormat+";[Red]-"+cFormat
						// Numerico %
						ElseIf "P" $ cTipo
							cFormat  := "0"
							If nDecimal > 0
								cFormat += "."+REPLICATE("0",nDecimal)+"%"
							Else
								cFormat += "%"
							EndIf
							cFormat := cFormat+";[Red]-"+cFormat
						// Data
						ElseIf "D" $ cTipo
							cFormat := "dd/mm/yyyy"
							// Se o campo vier em branco, setar cFormat para "" no momento de gerar a celula
						EndIf

					EndIf

					// Converter nome da coluna em numero da coluna
					If Len(aNResumos) > 0 .AND. !Empty(cName)
						For nR := 1 To Len(aNResumos)
							If aResumos[nR,2] == cName
								aNResumos[nR,2] := nC
							EndIf
							If aResumos[nR,3] == cName
								aNResumos[nR,3] := nC
							EndIf
						Next
					EndIf

					// Sempre centralizar campo tipo Data
					If "D" $ cTipo
						cHAlign := "C"
					EndIf

					// Salva os atributos
					oPlan:aColunas[nC]:SetTipo(cTipo)
					oPlan:aColunas[nC]:SetTamanho(nTamanho)
					oPlan:aColunas[nC]:SetDecimal(nDecimal)
					oPlan:aColunas[nC]:SetTamCol(nTamCol)
					oPlan:aColunas[nC]:SetTotal(lTotal)
					oPlan:aColunas[nC]:SetFormat(cFormat)
					oPlan:aColunas[nC]:SetHAlign(cHAlign)
					oPlan:aColunas[nC]:SetField(nField)

					// Aplica o tamanho da coluna
					Self:oPrtXlsx:SetColumnsWidth(nC,nC,nTamCol)

				EndIf

				// Padrão anterior
				//Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorFonte, cCorFundo, cFormat )

				If cHAlign == "C"
					cOHAlign := cHorAligC
				ElseIf cHAlign == "L"
					cOHAlign := cHorAligL
				ElseIf cHAlign == "R"
					cOHAlign := cHorAligR
				Else
					cOHAlign := cHorAligD
				EndIf

				cCorFonte	:= cCorN
				cCorFundo	:= cFundoN
				nCSize		:= nLSize
				lCItalic	:= lLItalic
				lCBold		:= lLBold
				lCUnderl	:= lLUnderl

				lChange 	:= .F.
				If Len(aCor) > 0
					For nX := 1 To Len(aCor)
						If Eval(aCor[nX,XCONDICAO],xCampo)
							If !Empty(aCor[nX,XCORFONTE])
								cCorFonte := aCor[nX,XCORFONTE]
							EndIf
							If !Empty(aCor[nX,XCORFUNDO])
								cCorFundo := aCor[nX,XCORFUNDO]
							EndIf
							If !Empty(aCor[nX,XSIZE])
								nCSize := aCor[nX,XSIZE]
								lChange	 := .T.
							EndIf
							If !Empty(aCor[nX,XITALIC])
								lCItalic := aCor[nX,XITALIC]
								lChange	 := .T.
							EndIf
							If !Empty(aCor[nX,XBOLD])
								lCBold := aCor[nX,XBOLD]
								lChange	 := .T.
							EndIf
							If !Empty(aCor[nX,XUNDER])
								lCUnderl := aCor[nX,XUNDER]
								lChange	 := .T.
							EndIf
						EndIf
					Next
				EndIf
				If lChange
					Self:oPrtXlsx:SetFont(cFont, nCSize, lCItalic, lCBold, lCUnderl)
				EndIf

				Self:oPrtXlsx:SetCellsFormat(cOHAlign, cLVertAlig, lWrap, nLRotation, cCorFonte, cCorFundo, cFormat )

				If "F" $ cTipo
					If "HYPERLINK" $ UPPER(xCampo)
						Self:oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, .T.)
						Self:oPrtXlsx:SetCellsFormat(cOHAlign, cLVertAlig, lWrap, nLRotation, cCorLink, cCorFundo, cFormat )
					ElseIf "##" $ cCampo
						// Exemplo: 
						//	oPExcel:AddCol("TOTAL","'=##C1_QUANT##*##C1_XXLCVAL##'","Total","")
						//	oPExcel:GetCol("TOTAL"):SetTipo("FN")
						//	oPExcel:GetCol("TOTAL"):SetTotal(.T.)

						nx := 1
						Do While nX <= Len(oPlan:aColunas) .AND. "##" $ cCampo
							cColLin := oPlan:aColunas[nX]:GetColuna()+ALLTRIM(STR(nLin))
							cFCampo := "##"+oPlan:aColunas[nX]:GetName()+"##"
							If cFCampo $ xCampo
								xCampo := STRTRAN(xCampo,cFCampo,cColLin)
							EndIf
							nX++
						EndDo
					EndIf

					If !Empty(xCampo)
						Self:oPrtXlsx:SetFormula(nLin,nC,xCampo)
					Else
						Self:oPrtXlsx:SetValue(nLin,nC,"")
					EndIf
					lChange := .T.
					
				ElseIf "D" $ cTipo
					If !Empty(xCampo)
						Self:oPrtXlsx:SetValue(nLin,nC,xCampo)
					Else
						Self:oPrtXlsx:SetValue(nLin,nC,"")
					EndIf
				Else
					Self:oPrtXlsx:SetValue(nLin,nC,xCampo)
				EndIf

				// Quarda elementos da linha para montagem dos resumos
				If !Empty(aNResumos)
					aAdd(aLinha,xCampo)
				EndIf

				// Voltar estilo padrão
				If lChange
					Self:oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
				EndIf

			Next

			//u_MsgLog("REXCEL","aLinha","",VarInfo("aLinha",aLinha))
			//u_MsgLog("REXCEL","aNResumos","",VarInfo("aNResumos",aNResumos))

			// Monta os resumos
			If !Empty(aNResumos)
				For nR := 1 To Len(aNResumos)
					cTipoVal := ValType(aLinha[aNResumos[nR,3]])
					If Len(aNResumos[nR,4]) > 0
						nS := Ascan(aNResumos[nR,4],{|x| x[1] == aLinha[aNResumos[nR,2]]})
						If nS == 0
							aAdd(aNResumos[nR,4],{aLinha[aNResumos[nR,2]],iIf(cTipoVal=='N',aLinha[aNResumos[nR,3]],1)})
						Else
							If cTipoVal == "N"
								aNResumos[nR,4,nS,2] += aLinha[aNResumos[nR,3]]
							Else
								aNResumos[nR,4,nS,2]++
							EndIf
						EndIf
					Else
						aAdd(aNResumos[nR,4],{aLinha[aNResumos[nR,2]],iIf(cTipoVal=='N',aLinha[aNResumos[nR,3]],1)})
					EndIf
				Next
			EndIf

			lFirst := .F.

		Next

	EndIf

	nLast := nLin

	If !lFirst
		// Montagem da linha de total

        Self:oPrtXlsx:ApplyAutoFilter(nTop-1,1,nLin,Len(oPlan:aColunas))

		nLin++
	    Self:oPrtXlsx:SetFont(cFont, nTSize3, lTItalic, lTBold, lTUnderl)
		Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorS1, cFundoS1, "")
        Self:oPrtXlsx:SetValue(nLin,1,"Total ("+ALLTRIM(STR(nCont))+")")
        
		If nCont > 0
			// Formatação dos totais		

			For nC := 1 To Len(oPlan:aColunas)
				If oPlan:aColunas[nC]:GetTotal()
					cFormat	:= oPlan:aColunas[nC]:GetFormat()
					Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorS1, cFundoS1, cFormat )
					cColExcel := NumToString(nC)
					cLinTop   := ALLTRIM(STR(nTop))
					cLinExcel := ALLTRIM(STR(nLast))
					Self:oPrtXlsx:SetFormula(nLin,nC, "=SUBTOTAL(9,"+cColExcel+cLinTop+":"+cColExcel+cLinExcel+")")
				EndIf
			Next
		EndIf
		Self:oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)

		// Mostrar os Resumos
		If !Empty(aNResumos)

			For nI := 1 To Len(aNResumos)
				nLin+=3
				// Formatação do cabeçalho
				Self:oPrtXlsx:SetFont(cFont, nHSize, lHItalic, lHBold, lHUnderl)
				Self:oPrtXlsx:SetCellsFormat(cHHorAlig, cHVertAlig, lHWrapText, nHRotation, cCorS, cFundoS, "" )

				Self:OPrtXlsx:SetBorder(.T.,.T.,.T.,.T.,FwXlsxBorderStyle():Thin(),"000000")

				cFormat := "#,##0.00;[Red]-#,##0.00"
				// Cabeçalho do resumo
				If aNResumos[nI,2] > 0
					Self:oPrtXlsx:SetValue(nLin,2,oPlan:aColunas[aNResumos[nI,2]]:cTitulo)
				EndIf
				If aNResumos[nI,3] > 0
					Self:oPrtXlsx:SetValue(nLin,3,oPlan:aColunas[aNResumos[nI,3]]:cTitulo)
					cFormat	:= oPlan:aColunas[aNResumos[nI,3]]:GetFormat()
				EndIf

				Self:oPrtXlsx:ResetCellsFormat()
				// Formatação das linhas normais
				Self:oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
				Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )

				// Resumo
				nLin++

				// Via formula, não funcionou no excel 365 (OBS: porque tem que ser em INGLES)
				//cColExcel := NumToString(aNResumos[nI,1])
				//cLinTop   := ALLTRIM(STR(nTop))
				//cLinExcel := ALLTRIM(STR(nLast))
				//Self:oPrtXlsx:SetFormula(nLin,2, "ÚNICO("+cColExcel+cLinTop+":"+cColExcel+cLinExcel+")")
				//Self:oPrtXlsx:SetFormula(nLin,2, "SOMASES( .... "+cColExcel+cLinTop+":"+cColExcel+cLinExcel+")")

				nLinR := nLin

				Self:oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)

				For nR := 1 To Len(aNResumos[nI,4])

					Self:oPrtXlsx:ResetCellsFormat()

					// Formatação das linhas normais
					Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )

					Self:oPrtXlsx:SetValue(nLin,2,aNResumos[nI,4,nR,1])

					// Formatação de totais
					Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, cFormat )
					Self:oPrtXlsx:SetValue(nLin,3,aNResumos[nI,4,nR,2])

					nLin++
				Next

				cColExcel := NumToString(3)
				cLinTop   := ALLTRIM(STR(nLinR))
				cLinExcel := ALLTRIM(STR(nLin-1))
				Self:oPrtXlsx:SetFont(cFont, nLSize, lLItalic, .T., lLUnderl)
				Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorS1, cFundoS1, cFormat )

				Self:oPrtXlsx:SetValue(nLin,2, aNResumos[nI,1])
				Self:oPrtXlsx:SetFormula(nLin,3, "=SUBTOTAL(9,"+cColExcel+cLinTop+":"+cColExcel+cLinExcel+")")
					
			Next
		EndIf

	EndIf

Next


// --> Planilha de Parâmetros
aParam := Self:aParam
cPerg  := Self:cPerg
If Len(aParam) > 0
	For nI := 1 TO LEN(aParam)
		xCampo := &("MV_PAR"+STRZERO(nI,2))
		yCampo := cValToChar(xCampo)
		// Se for combo ou radio, pega a posição do array
		If aParam[nI,1] == 2 .OR. aParam[nI,1] == 3
			If ValType(xCampo) == "N"
				If  xCampo > 0 .AND. xCampo <= Len(aParam[nI,4])
					yCampo := aParam[nI,4,xCampo]
				EndIf
			EndIf
		EndIf
		aAdd(aLocPar,{aParam[nI,2],yCampo})
	Next
ElseIf !Empty(cPerg)
	oObjPerg := FWSX1Util():New()
	oObjPerg:AddGroup(Self:cPrw)
	oObjPerg:SearchGroup()
	aPergunte := oObjPerg:GetGroup(Self:cPrw)
	If !Empty(aPergunte[2])
		For nI := 1 TO Len(aPergunte[2])
			xCampo := "MV_PAR"+STRZERO(nI,2)
			If aPergunte[2,nI,"CX1_GSC"] == "C"
				cVarDef := SUBSTR(cValToChar(&xCampo),1,1)
				If cVarDef $ "12345"
					yCampo := "CX1_DEF0"+cVarDef
					aAdd(aLocPar,{aPergunte[2,nI,"CX1_PERGUNT"],aPergunte[2,nI,yCampo]})
				EndIf
			Else
				aAdd(aLocPar,{aPergunte[2,nI,"CX1_PERGUNT"],cValToChar(&xCampo)})
			EndIf
		Next
	EndIf
EndIf

nLin := 1
Self:oPrtXlsx:AddSheet("Parâmetros")    //Adiciona a planilha de Parâmetros
Self:oPrtXlsx:SetColumnsWidth(1,2,50)

// Formatação de cabeçalho
Self:oPrtXlsx:SetFont(cFont, nHSize, lHItalic, lHBold, lHUnderl)
Self:oPrtXlsx:SetCellsFormat(cHHorAlig, cHVertAlig, lHWrapText, nHRotation, cCorS, cFundoS, "" )

Self:oPrtXlsx:MergeCells(nLin,1,nLin,2)

// Titulo do relatório
Self:oPrtXlsx:SetValue(nLin,1,Self:cPrw+" - "+Self:cTitulo)
nLin++

// Formatação das linhas normais
Self:oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, .T. /*lLWrapText*/, nLRotation, cCorN, cFundoN, "" )

If !Empty(Self:cDescr)
	Self:oPrtXlsx:SetValue(nLin,1,"Descrição: ")
	Self:oPrtXlsx:SetValue(nLin,2,Self:cDescr)
	nLin++
EndIf

If !Empty(Self:cSolicit)
	Self:oPrtXlsx:SetValue(nLin,1,"Solicitante: ")
	Self:oPrtXlsx:SetValue(nLin,2,Self:cSolicit)
	nLin++
EndIf

If !Empty(Self:cVersao)
	Self:oPrtXlsx:SetValue(nLin,1,"Versões: ")
	Self:oPrtXlsx:SetValue(nLin,2,Self:cVersao)
	nLin++
EndIf
//Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )

Self:oPrtXlsx:SetValue(nLin,1,"Emitido por: ")
Self:oPrtXlsx:SetValue(nLin,2,Trim(cUserName)+" em "+DTOC(DATE())+"-"+SUBSTR(TIME(),1,5)+" - "+ComputerName())
nLin++
Self:oPrtXlsx:SetValue(nLin,1,"Data Base: ")
Self:oPrtXlsx:SetValue(nLin,2,+DTOC(dDataBase))
nLin++
Self:oPrtXlsx:SetValue(nLin,1,"Empresa "+cEmpAnt+": ")
Self:oPrtXlsx:SetValue(nLin,2,ALLTRIM(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_NOME"} )[1,2]))
nLin++
Self:oPrtXlsx:SetValue(nLin,1,"Filial "+cFilAnt+": ")
Self:oPrtXlsx:SetValue(nLin,2,ALLTRIM(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_FILIAL"} )[1,2]))
nLin++

If Len(aLocPar) > 0

	// Formatação de cabeçalho
    Self:oPrtXlsx:SetFont(cFont, nHSize, lHItalic, lHBold, lHUnderl)
    Self:oPrtXlsx:SetCellsFormat(cHHorAlig, cHVertAlig, lHWrapText, nHRotation, cCorS, cFundoS, "" )

	Self:oPrtXlsx:SetValue(nLin,1,"Parâmetros")
	Self:oPrtXlsx:SetValue(nLin,2,"Conteúdos")

	// Formatação das linhas normais
    Self:oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
    Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )

	For nI := 1 TO LEN(aLocPar)
		nLin++
		Self:oPrtXlsx:SetValue(nLin,1,aLocPar[nI,1],)
		Self:oPrtXlsx:SetValue(nLin,2,aLocPar[nI,2],)
	Next
EndIf
// <-- Parâmetros


// Grava a Planilha

nOpcFile := 1

If !IsBlind()
	cFileL  := Self:cDirDest+Self:cFile+".xlsx"
	If File(cFileL)
		Do While .T.
			nRet:= FERASE(cFileL)
			If nRet < 0
				//u_MsgLog("REXCEL","Não será possivel gerar a planilha "+cFileL+", feche o arquivo","W")
				nOpcFile := u_AvisoLog("REXCEL","Arquivo aberto em outro aplicativo","O arquivo "+cFileL+", já está aberto por outro aplicativo, feche-o e clique em ok",{"Ok","Cancelar"},/*nSize*/,/*cText*/,/*nRotAutDefault*/,/*cBitmap*/,/*lEdit*/,5000,1)
				If nOpcFile <> 1
					Exit
				EndIf
			Else 
				Exit
			EndIf
		EndDo
	EndIf

	If nOpcFile == 1
		oSayMsg:SetText("Abrindo o arquivo, aguarde...")
		ProcessMessages()

		Self:oPrtXlsx:toXlsx()

		If file(Self:cFileR)
			CpyS2T(Self:cFileX, Self:cDirDest)
			ShellExecute("open",cFileL,"",Self:cDirDest+"\", 1 )
		EndIf
	Else
		oSayMsg:SetText("Você cancelou a abertura do arquivo.")
		ProcessMessages()
	EndIf
Else
	cFileL := Self:cFileX
	If File(Self:cFileX)
		Ferase(self:cFileX)
	EndIf
	Self:oPrtXlsx:toXlsx()
	//u_MsgLog("REXCEL","TOXLSX")
	// Obs: o arquivo .xlsx deverá ser apagado na função que chamou, exemplo: no REST, após a leitura do arquivo
EndIf

Self:oPrtXlsx:EraseBaseFile()
Self:oPrtXlsx:DeActivate()

If !IsBlind()
	FErase(self:cFileX)
EndIf

FErase(self:cFileR)

//u_MsgLog("CFILER",self:cFileR)
//u_MsgLog("CFILEX",self:cFileX)

Return cFileL



// Adiciona nova planilha
METHOD AddPlan(oPlan) CLASS RExcel
aAdd(Self:aPlans,oPlan)    //Adiciona nova planilha
Return


//------------------------------------------------------------------------------------
// Definição da Classe das Planilhas
//------------------------------------------------------------------------------------

CLASS PExcel

	// Declaracao das propriedades da Classe
	DATA cAlias
	DATA aMatriz	AS Array
	DATA cTitulo
	DATA cPlan
	DATA cFiltro
	DATA aColunas	AS Array
	DATA aResumos 	AS Array

	// Declaração dos Métodos da Classe PExcel
	METHOD New(cPlan,cAlias) CONSTRUCTOR

	METHOD GetPlan()

	METHOD GetAlias()
	METHOD SetAlias(cAlias)

	METHOD GetMatriz()
	METHOD SetMatriz(aMatriz)

	METHOD GetFiltro()
	METHOD SetFiltro(cFiltro)

	METHOD GetTitulo()
	METHOD SetTitulo(cTitulo)

	METHOD AddCol(cName,cCampo,cDescr,cSx3)
	METHOD AddColX3(cCampo)

	METHOD GetCol(cName)

	METHOD AddResumos(cResumo,cColUnq,cColVal)

ENDCLASS

METHOD GetPlan() CLASS PExcel
Return Self:cPlan

METHOD GetAlias() CLASS PExcel
Return Self:cAlias

METHOD SetAlias(cAlias) CLASS PExcel
Self:cAlias := Alltrim(cAlias)
Return 

METHOD GetMatriz() CLASS PExcel
Return Self:aMatriz

METHOD SetMatriz(aMatriz) CLASS PExcel
Self:aMatriz := aMatriz
Return 

METHOD GetFiltro() CLASS PExcel
Return Self:cFiltro

METHOD SetFiltro(cFiltro) CLASS PExcel
Self:cFiltro := Alltrim(cFiltro)
Return 

METHOD GetTitulo() CLASS PExcel
Return Self:cTitulo

METHOD SetTitulo(cTitulo) CLASS PExcel
Self:cTitulo := Alltrim(cTitulo)
Return 


// Criação do construtor, onde atribuimos os valores default 
// para as propriedades e retornamos Self
METHOD New(cNPlan,xAlias) CLASS PExcel
Self:cPlan		:= cNPlan
Self:cTitulo	:= ""
Self:aColunas	:= {}
Self:cFiltro	:= ""
Self:aResumos 	:= {}
If ValType(xAlias) == "C"
	// Alias da tabela a percorrer
	Self:cAlias 	:= xAlias
	Self:aMatriz	:= {}
Else
	// Matriz de dados a percorrer
	Self:cAlias 	:= ""
	Self:aMatriz	:= xAlias
EndIf
Return Self


// Adiciona nova coluna
METHOD AddCol(cName,cCampo,cDescr,cSX3) CLASS PExcel
Local oCExcel	:= CExcel():New("",cCampo)
Local aX3Stru	:= {}

If !Empty(cSX3)
	aX3Stru	:= FWSX3Util():GetFieldStruct( cSX3 )
	If Empty(cDescr)
		oCExcel:SetTitulo(GetSX3Cache( cSX3 , "X3_TITULO"))
	EndIf
	oCExcel:SetTipo(aX3Stru[2])
	oCExcel:SetTamanho(aX3Stru[3])
	oCExcel:SetDecimal(aX3Stru[4])
EndIf
If !Empty(cDescr)
	oCExcel:SetTitulo(cDescr)
EndIf

oCExcel:SetName(cName)

//Adiciona nova coluna
aAdd(Self:aColunas,oCExcel)    

// Guarda coluna do Excel (letra(s))
oCExcel:SetColuna(NumToString(Len(Self:aColunas)))

Return


// Adiciona nova coluna, usando os padrões do SX3
METHOD AddColX3(cCampo) CLASS PExcel
Local oCExcel	:= CExcel():New("",cCampo)
Local aX3Stru	:= FWSX3Util():GetFieldStruct( cCampo )

oCExcel:SetTitulo(GetSX3Cache( cCampo , "X3_TITULO"))
oCExcel:SetTipo(aX3Stru[2])
oCExcel:SetTamanho(aX3Stru[3])
oCExcel:SetDecimal(aX3Stru[4])
oCExcel:SetName(cCampo)

//Adiciona nova coluna
aAdd(Self:aColunas,oCExcel)

// Guarda coluna do Excel (letra(s))
oCExcel:SetColuna(NumToString(Len(Self:aColunas)))

Return

// Retorna o objeto da Coluna pelo cName
METHOD GetCol(cName) CLASS PExcel
Local aColunas 	:= Self:aColunas
Local oCExcel	as Object
Local nS 		:= 0
nS := Ascan(aColunas,{ |x| x:GetName() == cName }) 
If nS > 0
	oCExcel := aColunas[nS]
EndIf
Return oCExcel

// Adiciona novo Resumo
METHOD AddResumos(cResumo,cColUnq,cColVal) CLASS PExcel
aAdd(Self:aResumos,{cResumo,cColUnq,cColVal})    //Adiciona novo Resumo
Return


//------------------------------------------------------------------------------------
// Definição da Classe das Colunas da Planilha
//------------------------------------------------------------------------------------

CLASS CExcel

	// Declaracao das propriedades da Classe
	DATA cTitulo
	DATA cCampo

	DATA cSX3
	DATA nField
	DATA cTipo   
	DATA nTamanho
	DATA nDecimal
	DATA nTamCol
	DATA lTotal
	DATA cFormat
	DATA cHAlign
	DATA lWrap
	DATA cName
	DATA aCor		AS Array
	DATA cColuna

	// Declaração dos Métodos da Classe CExcel
	METHOD New(cNTitulo,cNCampo) CONSTRUCTOR

	METHOD GetTitulo()
	METHOD SetTitulo(cTitulo)
	
	METHOD GetCampo()

	METHOD GetField()
	METHOD SetField(nField)

	METHOD GetColuna()
	METHOD SetColuna(cColuna)

	METHOD GetTipo()
	METHOD SetTipo(cTipo)

	METHOD GetTamanho()
	METHOD SetTamanho(nTamanho)

	METHOD GetDecimal()
	METHOD SetDecimal(nDecimal)

	METHOD GetTamCol()
	METHOD SetTamCol(nTamCol)

	METHOD GetTotal()
	METHOD SetTotal(lTotal)

	METHOD GetFormat()
	METHOD SetFormat(cFormat)

	METHOD GetHAlign()
	METHOD SetHAlign(cHAlign)

	METHOD GetWrap()
	METHOD SetWrap(lWrap)

	METHOD GetName()
	METHOD SetName(cName)

	METHOD GetCor()
	METHOD AddCor(bCondicao,cCor,cFundo,nSize,lItalic,lBold,lUnder)

ENDCLASS


// Declaração dos Métodos da Classe CExcel
METHOD New(cNTitulo,cNCampo) CLASS CExcel
Self:cTitulo 	:= cNTitulo
Self:cCampo  	:= cNCampo
Self:cSX3		:= ""
Self:nField		:= 0
Self:cTipo   	:= ""
Self:nTamanho	:= 0
Self:nDecimal	:= 0
Self:nTamCol	:= 0
Self:lTotal		:= .F.
Self:cFormat 	:= ""
Self:cHAlign 	:= "D"
Self:lWrap 		:= .F.
Self:cName 		:= ""
Self:aCor 		:= {}
Return

METHOD GetTitulo() CLASS CExcel
Return Self:cTitulo

METHOD SetTitulo(cTitulo) CLASS CExcel
Self:cTitulo := Alltrim(cTitulo)
Return 

METHOD GetCampo() CLASS CExcel
Return Self:cCampo

METHOD GetField() CLASS CExcel
Return Self:nField

//Posição do campo na estrutura da tabela (evitar macro)
METHOD SetField(nField) CLASS CExcel
Self:nField := nField
Return 

METHOD GetColuna() CLASS CExcel
Return Self:cColuna

//Letra da Coluna Excel
METHOD SetColuna(cColuna) CLASS CExcel
Self:cColuna := cColuna
Return 


METHOD GetTipo() CLASS CExcel
Return Self:cTipo

METHOD SetTipo(cTipo) CLASS CExcel
Self:cTipo := cTipo
Return 

METHOD GetTamanho() CLASS CExcel
Return Self:nTamanho

METHOD SetTamanho(nTamanho) CLASS CExcel
Self:nTamanho := nTamanho
Return 

METHOD GetDecimal() CLASS CExcel
Return Self:nDecimal

METHOD SetDecimal(nDecimal) CLASS CExcel
Self:nDecimal := nDecimal
Return 

METHOD GetTamCol() CLASS CExcel
Return Self:nTamCol

METHOD SetTamCol(nTamCol) CLASS CExcel
Self:nTamCol := nTamCol
Return 

METHOD GetTotal() CLASS CExcel
Return Self:lTotal

METHOD SetTotal(lTotal) CLASS CExcel
Self:lTotal := lTotal
Return 

METHOD GetFormat() CLASS CExcel
Return Self:cFormat

METHOD SetFormat(cFormat) CLASS CExcel
Self:cFormat := cFormat
Return 

METHOD GetHAlign() CLASS CExcel
Return Self:cHAlign

METHOD SetHAlign(cHAlign) CLASS CExcel
Self:cHAlign := cHAlign
Return 

METHOD GetWrap() CLASS CExcel
Return Self:lWrap

METHOD SetWrap(lWrap) CLASS CExcel
Self:lWrap := lWrap
Return 

METHOD GetName() CLASS CExcel
Return Self:cName

METHOD SetName(cName) CLASS CExcel
Self:cName := cName
Return 

METHOD GetCor() CLASS CExcel
Return Self:aCor

// Adiciona novo codblock para determinar a cor
METHOD AddCor(bCondicao,cCor,cFundo,nSize,lItalic,lBold,lUnder) CLASS CExcel

Default nSize	:= NIL
Default lItalic	:= NIL
Default lBold	:= NIL
Default lUnder	:= NIL

aAdd(Self:aCor,{bCondicao,cCor,cFundo,nSize,lItalic,lBold,lUnder}) 
Return


//-----------------------------------------------------------
// ALGORITIMO PARA CONVERTER COLUNAS DA PLANILHA
//-----------------------------------------------------------
Static Function NumToString(nNum)
	Local cRet	:= ""
	If nNum<=26
		cRet	:= ColunasIndex(nNum)
	ElseIf nNum<=702
		IF nNum % 26==0
			cRet	+= ColunasIndex(((nNum-(nNum % 26))/26)-1)
		Else
			cRet	+= ColunasIndex((nNum-(nNum % 26))/26)
		EndIf
		cRet	+= ColunasIndex(nNum % 26)
	Else
		IF nNum % 26==0
			cRet	+= NumToString(((nNum-(nNum % 26))/26)-1)
		Else
			cRet	+= NumToString((nNum-(nNum % 26))/26)
		EndIf
		cRet	+= ColunasIndex(nNum % 26)
	EndIf
Return cRet

Static Function StringToNum(cString)
	Local nTam	:= Len(cString)
	Local nRet
	If nTam==1
		nRet	:= ColunasIndex(cString,2)
	ElseIf nTam==2
		nRet	:= (ColunasIndex(SubStr(cString,1,1),2)*26)+ColunasIndex(SubStr(cString,2,1),2)
	ElseIf nTam==3
		nRet	:= (ColunasIndex(SubStr(cString,1,1),2)*676)+(ColunasIndex(SubStr(cString,2,1),2)*26)+ColunasIndex(SubStr(cString,3,1),2)
	EndIf
Return nRet

Static aColIdx	:= {{1,"A"},;
					{2,"B"},;
					{3,"C"},;
					{4,"D"},;
					{5,"E"},;
					{6,"F"},;
					{7,"G"},;
					{8,"H"},;
					{9,"I"},;
					{10,"J"},;
					{11,"K"},;
					{12,"L"},;
					{13,"M"},;
					{14,"N"},;
					{15,"O"},;
					{16,"P"},;
					{17,"Q"},;
					{18,"R"},;
					{19,"S"},;
					{20,"T"},;
					{21,"U"},;
					{22,"V"},;
					{23,"W"},;
					{24,"X"},;
					{25,"Y"},;
					{26,"Z"},;
					{0,"Z"},;
					}

Static Function ColunasIndex(xNum,nIdx)
	Local cRet		:= ""
	Default nIdx	:= 1
	nPos	:= aScan(aColIdx,{|x| x[nIdx]==xNum})
	If nPos>0
		If nIdx==1
			cRet	:= aColIdx[nPos][2]
		Else
			cRet	:= aColIdx[nPos][1]
		EndIf
	EndIf
Return cRet
