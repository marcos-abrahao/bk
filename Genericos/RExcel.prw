¬#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#define XALIAS_ 1
#define XORDER_ 2
#define XKEY_ 3
#define XRECNO_ 4


User Function BKCOMR18
Local cProg 	:= "BKCOMR18"
Local cTitulo	:= "Produtos x Rentabilidade"
Local oRExcel	AS Object
Local oPExcel	AS Object
Local cQuery 	:= ""
Local cAlias 	:= "TMP"
Local cCusBK	:= U_MVXCUSBK()
Local aTcFields := {}
Local aRet		:= {}
Local aParam 	:= {}

Private cB1Blq := {}
aAdd( aParam ,{ 2, "Lista bloqueados", cB1Blq  ,{"Sim", "Não"}	, 60,'.T.'  ,.T.})

If !ParCom18(cProg,cTitulo,@aRet,aParam)
   Return
EndIf

cQuery := "SELECT top 100"+CRLF
cQuery += "  B1_COD "+CRLF
cQuery += " ,B1_DESC "+CRLF
cQuery += " ,B1_CONTA "+CRLF
cQuery += " ,B1_USERLGA "+CRLF
cQuery += " ,B1_UREV "+CRLF
cQuery += " ,B1_ALIQISS "+CRLF
cQuery += " ,B1_UPRC "+CRLF
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
cQuery += " WHERE "+CRLF
cQuery += "     SB1.D_E_L_E_T_ = '' "+CRLF
If SUBSTR(cB1Blq,1,1) == 'S'
	cQuery += "     AND B1_MSBLQL != '1' "+CRLF
EndIf

//cQuery += " 	SUBSTRING(B1_CONTA,1,1) = '1' "+CRLF
cQuery += " ORDER BY CT1_CONTA "+CRLF

aAdd(aTcFields,FWSX3Util():GetFieldStruct( "B1_UREV" ))
aAdd(aTcFields,FWSX3Util():GetFieldStruct( "B1_ALIQISS" ))
aAdd(aTcFields,FWSX3Util():GetFieldStruct( "B1_UPRC" ))

u_RunQuery(cProg,cQuery,cAlias,aTcFields)


// Definição do Arq Excel
oRExcel := RExcel():New(cProg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetDescr("O objetivo deste relatório é para análise de produtos contemplados nos relatórios de rentabilidade da BK.")
oRExcel:SetParam(aParam)

// Definição da Planilha 1
oPExcel:= PExcel():New(cProg,cAlias)
oPExcel:SetTitulo("Usado para conferência da Rentabilidade")
oPExcel:AddResumos("CONTA","ALIQISS")

// Colunas da Planilha 1
oCExcel:= CExcel():New("Código Produto","TMP->B1_COD")
oCExcel:SetSX3("B1_COD")
oPExcel:AddCol(oCExcel)

oCExcel:= CExcel():New("Descriçao Produto","TMP->B1_DESC")
oCExcel:SetSX3("B1_DESC")
oPExcel:AddCol(oCExcel)

oCExcel:= CExcel():New("Conta Contábil","TMP->B1_CONTA")
oCExcel:SetSX3("B1_CONTA")
oCExcel:SetName("CONTA")
oPExcel:AddCol(oCExcel)

oCExcel:= CExcel():New("Descriçao Conta","TMP->CT1_DESC01")
oCExcel:SetSX3("CT1_DESC01")
oPExcel:AddCol(oCExcel)

oCExcel:= CExcel():New("Rentabilidade","TMP->RENTAB")
oCExcel:SetSX3("RENTAB")
oPExcel:AddCol(oCExcel)

oCExcel:= CExcel():New("Usuário","Capital(TMP->(FWLeUserlg('B1_USERLGA',1)))")
oCExcel:SetTipo("C")
oCExcel:SetTamCol(30)
oPExcel:AddCol(oCExcel)

oCExcel:= CExcel():New("","TMP->B1_UREV")
oCExcel:SetSX3("B1_UREV")
oPExcel:AddCol(oCExcel)

oCExcel:= CExcel():New("","TMP->B1_ALIQISS")
oCExcel:SetSX3("B1_ALIQISS")
oCExcel:SetFormat("#,##0.0000")
oCExcel:SetName("ALIQISS")
oCExcel:SetTotal(.T.)

oPExcel:AddCol(oCExcel)

oCExcel:= CExcel():New("","TMP->B1_UPRC")
oCExcel:SetSX3("B1_UPRC")
oCExcel:SetTotal(.T.)
oPExcel:AddCol(oCExcel)

oRExcel:AddPlan(oPExcel)


// Definição da Planilha 2
oPExcel:= PExcel():New("PTESTE2",cAlias)
oPExcel:SetTitulo("Teste Planilha 2")
oRExcel:AddPlan(oPExcel)

// Colunas da Planilha 2
oCExcel:= CExcel():New("Código Produto","TMP->B1_COD")
oCExcel:SetSX3("B1_COD")
oPExcel:AddCol(oCExcel)

oCExcel:= CExcel():New("Descriçao Produto","TMP->B1_DESC")
oCExcel:SetSX3("B1_DESC")
oPExcel:AddCol(oCExcel)

// Cria arquivo Excel
oRExcel:Create()

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
	DATA cDescr
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

	METHOD GetDescr()
	METHOD SetDescr(cDescr)

	METHOD GetPerg()
	METHOD SetPerg(cPerg)

	METHOD GetParam()
	METHOD SetParam(aParam)

	METHOD Create()

	METHOD RunCreate()

	METHOD Fill_Records()
	METHOD AddPlan(oPlan)

ENDCLASS

// Getters/Setters
METHOD GetTitulo() CLASS RExcel
Return Self:cTitulo

METHOD SetTitulo(cTitulo) CLASS RExcel
Self:cTitulo := Alltrim(cTitulo)
Return

METHOD GetDescr() CLASS RExcel
Return Self:cDescr

METHOD SetDescr(cDescr) CLASS RExcel
Self:cDescr := Alltrim(cDescr)
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
Self:cDirDest	:= "c:\tmp\"
Self:cDirTmp 	:= "\tmp\"
Self:cFile 		:= TRIM(cProg)+"-"+cEmpAnt+"-"+DTOS(Date())
Self:cFileR 	:= Self:cDirTmp+Self:cFile+".rel"
Self:cFileX 	:= Self:cDirTmp+Self:cFile+".xlsx"

Self:oFileW		:= FwFileWriter():New(Self:cFileR)
Self:oPrtXlsx	:= FwPrinterXlsx():New()

Self:oPrtXlsx:Activate(Self:cFileR, Self:oFileW)

Self:aPlans 	:= {}

Return Self


METHOD Create() CLASS RExcel

u_WaitLog(Self:cPrw,{ || Self:RunCreate()},"Criando a planilha...")
Return


METHOD RunCreate() CLASS RExcel

Local cFileL		:= ""
Local nRet			:= 0
Local lFirst 		:= .T.
Local nC 			:= 0
Local nI 			:= 0
Local nP			:= 0
Local nR 			:= 0
Local nS 			:= 0
Local cFont			:= FwPrinterFont():Calibri()
Local nLin 			:= 1
Local nTop			:= 1
Local nLast 		:= 1
Local nCont 		:= 0

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
Local nTSize3 		:= 10
Local lTItalic 		:= .F.
Local lTBold 		:= .T.
Local lTUnderl		:= .F.
Local cTHorAlig		:= oCellHorAlign:Default()
Local cTVertAlig	:= oCellVertAlign:Center()
Local lTWrapText 	:= .T.
Local nTRotation 	:= 0

// Cores
Local cCorN			:= "000000" // Cor Preta
Local cFundoN		:= "FFFFFF" // Fundo Branco

Local cCorS			:= "FFFFFF" // Cor Branca
Local cFundoS		:= "9E0000" // Fundo Vermelho BK
/*
Local cCorS1		:= "000000" // Cor Preta
Local cFundoS1		:= "E9967A" // Fundo DarkSalmon

Local cCorS2		:= "000000" // Cor Preta
Local cFundoS2		:= "9ACD32" // Fundo YellowGreen
*/

// Atributos da Planilha
Local oPlan			AS Object
Local cFiltro 		:= ""
Local cAlias 		:= ""
Local aResumos		:= {}
Local aNResumos		:= {}

// Atributos da Linha
Local aStruct 		:= {}
Local aX3Stru 		:= {}
Local cTipo   		:= ""
Local cCampo 		:= ""
Local cDefCpo 		:= ""
Local nField 		:= 0
Local nTamanho		:= 0
Local nDecimal		:= 0
Local nTamCol		:= 0
Local cFormat 		:= ""
Local cCorFonte 	:= cCorN
Local cCorFundo 	:= cFundoN
Local cCorAntes 	:= ""
Local cHAlign 		:= "D"
Local lWrap 		:= .F.
Local cOHAlign		:= ""
Local aLinha 		:= {}
Local cName 		:= ""

// Campo para Macro
Private xCampo
Private yCampo

// Inicialização do Logo
nHndImagem := fOpen(cImgDir, FO_READ)
if nHndImagem < 0
    //MsgStop("Não foi possível abrir " + cImgDir)
Else
	nLenImagem := fSeek( nHndImagem, 0, FS_END)
	fSeek( nHndImagem, 0, FS_SET)
	fRead( nHndImagem, @cBuffer, nLenImagem)
EndIf
fClose(nHndImagem)

// Percorre as Planilhas
For nP := 1 To Len(Self:aPlans)
	
	oPlan		:= Self:aPlans[nP]

	cAlias		:= oPlan:cAlias
	cFiltro		:= oPlan:cFiltro
	aResumos	:= oPlan:aResumos

	// Monta array temporário para armazenar numero das colunas e valores
	aNResumos 	:= {}
	For nR := 1 To Len(aResumos)
		aAdd(aNResumos,{0,0,{}})
	Next

	aStruct 	:= (cAlias)->(dbStruct())

	If !Empty(cFiltro)
		(cAlias)->(dbSetFilter({|| &cFiltro} , cFiltro))
	Else
		(cAlias)->(dbClearFilter())
	Endif
	(cAlias)->(dbGoTop())

	Self:oPrtXlsx:AddSheet(oPlan:GetPlan())    //Adiciona nova planilha
    cFont   := FwPrinterFont():Calibri()
	Self:OPrtXlsx:SetBorder(.F.,.F.,.F.,.F.,FwXlsxBorderStyle():Thin(),"000000")

	// Formatação do cabeçalho
    Self:oPrtXlsx:SetFont(cFont, nTSize1, lTItalic, lTBold, lTUnderl)
    Self:oPrtXlsx:SetCellsFormat(cTHorAlig, cTVertAlig, lTWrapText, nTRotation,cCorN, cFundoN, "" )

	nLin := 1

	// Logo
    nHndImagem := fOpen(cImgDir, FO_READ)
    if nHndImagem >= 0
		Self:oPrtXlsx:AddImageFromBuffer(1, 1, cImgRel, cBuffer, 42, 40)
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
	EndIf

	// Titulo padrão
	Self:oPrtXlsx:SetFont(cFont, nTSize3, lTItalic, lTBold, lTUnderl)
	Self:oPrtXlsx:SetValue(nLin,2,Self:cPrw+" - Data base: "+DTOC(dDataBase) +" - Emitido em: "+DTOC(DATE())+"-"+SUBSTR(TIME(),1,5)+" - "+cUserName)
	nLin++


	// Logo
    nHndImagem := fOpen(cImgDir, FO_READ)
    if nHndImagem < 0
        //MsgStop("Não foi possível abrir " + cImgDir)
    Else
		nLenImagem := fSeek( nHndImagem, 0, FS_END)
		fSeek( nHndImagem, 0, FS_SET)
		fRead( nHndImagem, @cBuffer, nLenImagem)
	
		Self:oPrtXlsx:AddImageFromBuffer(1, 1, cImgRel, cBuffer, 42, 40)
	EndIf

	nTop := nLin + 1

	// Formatação do cabeçalho
    Self:oPrtXlsx:SetFont(cFont, nHSize, lHItalic, lHBold, lHUnderl)
    Self:oPrtXlsx:SetCellsFormat(cHHorAlig, cHVertAlig, lHWrapText, nHRotation, cCorS, cFundoS, "" )

	Self:OPrtXlsx:SetBorder(.T.,.T.,.T.,.T.,FwXlsxBorderStyle():Thin(),"000000")


	// Montagem do Cabeçalho
	For nC := 1 To Len(oPlan:aColunas)

		// Titulo informado em branco, pegar do dicionário SX3
		If Empty(oPlan:aColunas[nC]:cTitulo)
			cDefCpo := oPlan:aColunas[nC]:GetSx3()
			
			//oPlan:aColunas[nC]:cTitulo := FWSX3Util():GetDescription( cDefCpo ) 
			oPlan:aColunas[nC]:cTitulo := GetSX3Cache( cDefCpo , "X3_TITULO")
		EndIf

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

	dbSelectArea(cAlias)
	Do While (cAlias)->(!Eof()) 
		nLin++
		nCont++
		aLinha := {}

		For nC := 1 To Len(oPlan:aColunas)
			//oLinha := oPlan:aColunas[nC]
			cCampo := oPlan:aColunas[nC]:cCampo
			xCampo := &(cCampo)

			//aqui montar formato com aStruc


			// Pega os atributos da Coluna
			cTipo 	:= oPlan:aColunas[nC]:GetTipo()
			nTamanho:= oPlan:aColunas[nC]:GetTamanho()
			nDecimal:= oPlan:aColunas[nC]:GetDecimal()
			nTamCol	:= oPlan:aColunas[nC]:GetTamCol()
			lTotal	:= oPlan:aColunas[nC]:GetTotal()
			cFormat	:= oPlan:aColunas[nC]:GetFormat()
			cHAlign := oPlan:aColunas[nC]:GetHAlign()

			// Atributos que não precisam ser atualizados
			nField	:= oPlan:aColunas[nC]:GetField()
			cDefCpo := oPlan:aColunas[nC]:GetSx3()
			lWrap   := oPlan:aColunas[nC]:GetWrap()
			cName   := oPlan:aColunas[nC]:GetName()

			If lFirst
				// Ajusta os atributos informados ou default

				// Se informado SX3
				If !Empty(cDefCpo)
					aX3Stru	:= FWSX3Util():GetFieldStruct( cDefCpo )
					If !Empty(aX3Stru)
						cTipo		:= aX3Stru[2]
						nTamanho	:= aX3Stru[3]
						nDecimal	:= aX3Stru[4]
					Else
						// Pega informações da Estrutura da Query
						nS := aScan(aStruct,{ |x| x[1] == cDefCpo })
						If nS > 0
							cTipo		:= iIf(Empty(cTipo),aStruct[nS,2],cTipo)
							nTamanho	:= aStruct[nS,3]
							nDecimal	:= aStruct[nS,4]
						EndIf
					EndIf
				EndIf

				// Pega informações da Coluna
				If Empty(cTipo)
					cTipo 		:= ValType(xCampo)
				EndIf
				If Empty(nTamanho)
					If Substr(cTipo,1,1) == "N"
						nTamanho := 15
						nDecimal := 2
					ElseIf Substr(cTipo,1,1) == "D"
						nTamanho := 8
					ElseIf Substr(cTipo,1,1) $ "CM"
						nTamanho := Len(xCampo)
					EndIf
				EndIf
	

				//Calcula o tamanho da coluna excel
				If Empty(nTamCol)
					nTamCol := 8
					If Substr(cTipo,1,1) == "N"
						nTamCol := 15
					ElseIf Substr(cTipo,1,1) == "D"
						nTamCol := 10
					ElseIf Substr(cTipo,1,1) $ "CM"
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
					If Substr(cTipo,1,1) == "N"
						cFormat := "#,##0"
						If nDecimal > 0
							cFormat += "."+REPLICATE("0",nDecimal)
						EndIf
						cFormat := cFormat+";[Red]-"+cFormat
					// Numerico %
					ElseIf Substr(cTipo,1,1) == "P"
						cFormat  := "0"
						If nDecimal > 0
							cFormat += "."+REPLICATE("0",nDecimal)+"%"
						Else
							cFormat += "%"
						EndIf
						cFormat := cFormat+";[Red]-"+cFormat
					// Data
					ElseIf Substr(cTipo,1,1) == "D"
						cFormat := "dd/mm/yyyy"
						// Se o campo vier em branco, setar cFormat para "" no momento de gerar a celula
					EndIf

				EndIf

				// Converter nome da coluna em numero da coluna
				If !Empty(cName)
					For nR := 1 To Len(aNResumos)
						If aResumos[nR,1] == cName
							aNResumos[nR,1] := nC
						EndIf
						If aResumos[nR,2] == cName
							aNResumos[nR,2] := nC
						EndIf
					Next
				EndIf

				// Sempre centralizar campo tipo Data
				If Substr(cTipo,1,1) == "D"
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

			Self:oPrtXlsx:SetCellsFormat(cOHAlign, cLVertAlig, lWrap, nLRotation, cCorFonte, cCorFundo, cFormat )

			If cTipo == "F"
				Self:oPrtXlsx:SetFormula(nLin,nC,xCampo)
			ElseIf cTipo == "D"
				If !Empty(xCampo)
					Self:oPrtXlsx:SetValue(nLin,nC,xCampo)
				EndIf
			Else
				Self:oPrtXlsx:SetValue(nLin,nC,xCampo)
			EndIf

			// Quarda elementos da linha para montagem dos resumos
			aAdd(aLinha,xCampo)

		Next


		// Monta os resumos
		If !Empty(aNResumos)
			For nR := 1 To Len(aNResumos)
				If Len(aNResumos[nR,3]) > 0
					nS := Ascan(aNResumos[nR,3],{|x| x[1] == aLinha[aNResumos[nR,1]]})
					If nS == 0
						aAdd(aNResumos[nR,3],{aLinha[aNResumos[nR,1]],aLinha[aNResumos[nR,2]]})
					Else
						aNResumos[nR,3,nS,2] += aLinha[aNResumos[nR,2]]
					EndIf
				Else
					aAdd(aNResumos[nR,3],{aLinha[aNResumos[nR,1]],aLinha[aNResumos[nR,2]]})
				EndIf
			Next
		EndIf

		lFirst := .F.
		(cAlias)->(dbSkip())
	EndDo

	nLast := nLin

	If !lFirst
		// Montagem da linha de total

        Self:oPrtXlsx:ApplyAutoFilter(nTop-1,1,nLin,Len(oPlan:aColunas))

		nLin++
	    Self:oPrtXlsx:SetFont(cFont, nTSize3, lTItalic, lTBold, lTUnderl)
        Self:oPrtXlsx:SetValue(nLin,1,"Total ("+ALLTRIM(STR(nCont))+")")
        
		If nCont > 0
			// Formatação dos totais		
			For nC := 1 To Len(oPlan:aColunas)
				If oPlan:aColunas[nC]:GetTotal()
					cFormat	:= oPlan:aColunas[nC]:GetFormat()
					Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, cFormat )
					cColExcel := NumToString(nC)
					cLinTop   := ALLTRIM(STR(nTop))
					cLinExcel := ALLTRIM(STR(nLast))
					Self:oPrtXlsx:SetFormula(nLin,nC, "=SUBTOTAL(9,"+cColExcel+cLinTop+":"+cColExcel+cLinExcel+")")
				EndIf
			Next
		EndIf
		Self:oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
	EndIf

	// Mostrar os Resumos
	If !Empty(aNResumos)

		For nI := 1 To Len(aNResumos)
			nLin+=3
			// Formatação do cabeçalho
			Self:oPrtXlsx:SetFont(cFont, nHSize, lHItalic, lHBold, lHUnderl)
			Self:oPrtXlsx:SetCellsFormat(cHHorAlig, cHVertAlig, lHWrapText, nHRotation, cCorS, cFundoS, "" )

			Self:OPrtXlsx:SetBorder(.T.,.T.,.T.,.T.,FwXlsxBorderStyle():Thin(),"000000")

			// Cabeçalho do resumo

			Self:oPrtXlsx:SetValue(nLin,2,oPlan:aColunas[aNResumos[nI,1]]:cTitulo)
			Self:oPrtXlsx:SetValue(nLin,3,oPlan:aColunas[aNResumos[nI,2]]:cTitulo)

			Self:oPrtXlsx:ResetCellsFormat()
			// Formatação das linhas normais
			Self:oPrtXlsx:SetFont(cFont, nLSize, lLItalic, lLBold, lLUnderl)
			Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )

			// Resumo
			nLin++

			// Via formula, não funcionou no excel 365
			//cColExcel := NumToString(aNResumos[nI,1])
			//cLinTop   := ALLTRIM(STR(nTop))
			//cLinExcel := ALLTRIM(STR(nLast))
			//Self:oPrtXlsx:SetFormula(nLin,2, "ÚNICO("+cColExcel+cLinTop+":"+cColExcel+cLinExcel+")")
			//Self:oPrtXlsx:SetFormula(nLin,2, "SOMASES( .... "+cColExcel+cLinTop+":"+cColExcel+cLinExcel+")")

			nLinR := nLin
			cFormat := "#,##0.00;[Red]-#,##0.00"
			For nR := 1 To Len(aNResumos[nI,3])

				Self:oPrtXlsx:ResetCellsFormat()

				// Formatação das linhas normais
				Self:oPrtXlsx:SetFont(cFont, nLSize, lLItalic, .T., lLUnderl)
				Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )

				Self:oPrtXlsx:SetValue(nLin,2,aNResumos[nI,3,nR,1])

				// Formatação de totais
				Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, cFormat )
				Self:oPrtXlsx:SetValue(nLin,3,aNResumos[nI,3,nR,2])

				// Total do Resumo
				/*
				nS := Ascan(_aTResumo,{ |x| x[1] == aNResumos[nI,1] .AND. x[2] == aNResumos[nI,2] })

				If nS == 0
					aAdd(_aTResumo,{aNResumos[nI,1],aNResumos[nI,2],{{aNResumos[nI,3,nR,1],aNResumos[nI,3,nR,2]}}})
				Else
					aAdd(_aTResumo[nS,3],{aNResumos[nI,3,nR,1],aNResumos[nI,3,nR,2]})
				EndIf
				*/
				nLin++
			Next

			cColExcel := NumToString(3)
			cLinTop   := ALLTRIM(STR(nLinR))
			cLinExcel := ALLTRIM(STR(nLin-1))
			Self:oPrtXlsx:SetFormula(nLin,3, "=SUBTOTAL(9,"+cColExcel+cLinTop+":"+cColExcel+cLinExcel+")")
				
		Next

	EndIf



Next



// --> Planilha de Parâmetros
aParam := Self:aParam
cPerg  := Self:cPerg
If Len(aParam) > 0
	For nI := 1 TO LEN(aParam)
		xCampo := "MV_PAR"+STRZERO(nI,2)
		aAdd(aLocPar,{aParam[nI,2],cValToChar(&xCampo)})
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

If !Empty(Self:cDescr)
	Self:oPrtXlsx:SetValue(nLin,1,"Descrição: ")
	Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, .T. /*lLWrapText*/, nLRotation, cCorN, cFundoN, "" )
	Self:oPrtXlsx:SetValue(nLin,2,Self:cDescr)
	nLin++
EndIf

Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorN, cFundoN, "" )


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

	Self:oPrtXlsx:SetValue(nLin,1,"Parâmetros - "+Self:cPrw)
	Self:oPrtXlsx:SetValue(nLin,2,"Conteúdo")

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
cFileL  := Self:cDirDest+Self:cFile+".xlsx"

If File(cFileL)
	nRet:= FERASE(cFileL)
	If nRet < 0
		u_MsgLog("REXCEL","Não será possivel gerar a planilha "+cFileL+", feche o arquivo","W")
	EndIf
EndIf

Self:oPrtXlsx:toXlsx()
If !IsBlind()
	If file(Self:cFileR)
		CpyS2T(Self:cFileX, Self:cDirDest)
		ShellExecute("open",cFileL,"",Self:cDirDest+"\", 1 )
	EndIf
EndIf

Self:oPrtXlsx:EraseBaseFile()
Self:oPrtXlsx:DeActivate()

Return



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
	DATA cTitulo
	DATA cPlan
	DATA cFiltro
	DATA aColunas	AS Array
	DATA aResumos 	AS Array

	// Declaração dos Métodos da Classe
	METHOD New(cPlan,cAlias) CONSTRUCTOR

	METHOD GetPlan()

	METHOD GetAlias()
	METHOD SetAlias(cAlias)

	METHOD GetFiltro()
	METHOD SetFiltro(cFiltro)

	METHOD GetTitulo()
	METHOD SetTitulo(cTitulo)

	METHOD AddCol(oCExcel)

	METHOD AddResumos(cColUnq,cColVal)

ENDCLASS

METHOD GetPlan() CLASS PExcel
Return Self:cPlan

METHOD GetAlias() CLASS PExcel
Return Self:cAlias

METHOD SetAlias(cAlias) CLASS PExcel
Self:cAlias := Alltrim(cAlias)
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
METHOD New(cNPlan,cAlias) CLASS PExcel
Self:cPlan		:= cNPlan
Self:cTitulo	:= ""
Self:aColunas	:= {}
Self:cAlias 	:= cAlias
Self:cFiltro	:= ""
Return Self


// Adiciona nova coluna
METHOD AddCol(oCExcel) CLASS PExcel
oCExcel:SetField(Len(Self:aColunas)+1) // Guarda numero da coluna
aAdd(Self:aColunas,oCExcel)    //Adiciona nova coluna
Return

// Adiciona novo Resumo
METHOD AddResumos(cColUnq,cColVal) CLASS PExcel
aAdd(Self:aResumos,{cColUnq,cColVal})    //Adiciona novo Resumo
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

	// Declaração dos Métodos da Classe
	METHOD New(cNTitulo,cNCampo) CONSTRUCTOR

	METHOD GetTitulo()
	METHOD SetTitulo(cSX3)
	
	METHOD GetCampo()

	METHOD GetSX3()
	METHOD SetSX3(cSX3)

	METHOD GetField()
	METHOD SetField(nField)

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

ENDCLASS


// Declaração dos Métodos da Classe
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
Return


METHOD GetTitulo() CLASS CExcel
Return Self:cTitulo

METHOD SetTitulo(cTitulo) CLASS CExcel
Self:cTitulo := Alltrim(cTitulo)
Return 

METHOD GetCampo() CLASS CExcel
Return Self:cCampo

METHOD GetSX3() CLASS CExcel
Return Self:cSX3

METHOD SetSX3(cSX3) CLASS CExcel
Self:cSX3 := cSX3
Return 

METHOD GetField() CLASS CExcel
Return Self:nField

METHOD SetField(nField) CLASS CExcel
Self:nField := nField
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

//-----------------------------------------------------------
//ALGORITIMO PARA CONVERTER COLUNAS DA PLANILHA
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
