#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"

#define XALIAS_ 1
#define XORDER_ 2
#define XKEY_ 3
#define XRECNO_ 4


User Function BKCOMR18
Local cProg 	:= "BKCOMR18"
Local oRExcel	AS Object
Local oPExcel	AS Object
Local cQuery 	:= ""
Local cAlias 	:= "TMP"
Local cCusBK	:= U_MVXCUSBK()
Local aTcFields := {}

cQuery := "SELECT "+CRLF
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
cQuery += " 	SUBSTRING(B1_CONTA,1,1) = '1' "+CRLF
cQuery += " AND SB1.D_E_L_E_T_ = '' "+CRLF
cQuery += " ORDER BY CT1_CONTA "+CRLF

aAdd(aTcFields,FWSX3Util():GetFieldStruct( "B1_UREV" ))
aAdd(aTcFields,FWSX3Util():GetFieldStruct( "B1_ALIQISS" ))
aAdd(aTcFields,FWSX3Util():GetFieldStruct( "B1_UPRC" ))

u_RunQuery(cProg,cQuery,cAlias,aTcFields)


// Definição do Arq Excel
oRExcel := RExcel():New(cProg)
oRExcel:SetTitulo("Produtos x Rentabilidade")

// Definição da Planilha 1
oPExcel:= PExcel():New(cProg,cAlias)
oPExcel:SetTitulo("Usado para conferência da Rentabilidade")

// Colunas da Planilha 1
oCExcel:= CExcel():New("Código Produto","TMP->B1_COD")
oCExcel:SetSX3("B1_COD")
oPExcel:AddCol(oCExcel)

oCExcel:= CExcel():New("Descriçao Produto","TMP->B1_DESC")
oCExcel:SetSX3("B1_DESC")
oPExcel:AddCol(oCExcel)

oCExcel:= CExcel():New("Conta Contábil","TMP->B1_CONTA")
oCExcel:SetSX3("B1_CONTA")
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


//Dummy Function
User Function RExcel()
Return .T.



CLASS RExcel

	// Declaracao das propriedades da Classe
	DATA cPrw
	DATA cAlias
	DATA cTitulo
	DATA cFile
	DATA cDirDest
	DATA cDirTmp
	DATA cFileR
	DATA cFileX
	DATA oFileW		AS Object
	DATA oPrtXlsx	AS Object
	DATA aPlans		AS Array

	// Declaração dos Métodos da Classe
	METHOD New(cProg) CONSTRUCTOR

	METHOD GetTitulo()
	METHOD SetTitulo(cTitulo)

	METHOD Create()

	METHOD RunCreate()


	METHOD Fill_Records()
	METHOD AddPlan(oPlan)

ENDCLASS


// Getters/Seters
METHOD SetTitulo(cTitulo) CLASS RExcel
Self:cTitulo := Alltrim(cTitulo)
Return


// Criação do construtor, onde atribuimos os valores default 
// para as propriedades e retornamos Self
METHOD New(cProg) CLASS RExcel

Self:cPrw 		:= cProg
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
Local nP			:= 0
Local nC 			:= 0
Local nS 			:= 0
Local oPlan			AS Object
Local cFont			:= FwPrinterFont():Calibri()
Local nLin 			:= 1
Local nTop			:= 1
Local oCellHorAlign := FwXlsxCellAlignment():Horizontal()
Local oCellVertAlign:= FwXlsxCellAlignment():Vertical()

Local nLSize 		:= 9
Local lLItalic 		:= .F.
Local lLBold 		:= .F.
Local lLUnderl		:= .F.
Local cLHorAlig		:= oCellHorAlign:Default()
Local cLVertAlig	:= oCellVertAlign:Center()
Local lLWrapText	:= .F.
Local nLRotation	:= 0

Local nHSize 		:= 9
Local lHItalic 		:= .F.
Local lHBold 		:= .T.
Local lHUnderl		:= .F.
Local cHHorAlig		:= oCellHorAlign:Center()
Local cHVertAlig	:= oCellVertAlign:Center()
Local lHWrapText	:= .T.
Local nHRotation	:= 0


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
Local lTWrapText 	:= .F.
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
Local cFiltro 		:= ""
Local cAlias 		:= ""

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

// Campo para Macro
Private xCampo

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
	
	oPlan	:= Self:aPlans[nP]

	cAlias	:= oPlan:cAlias
	cFiltro	:= oPlan:cFiltro

	aStruct := (cAlias)->(dbStruct())

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

	dbSelectArea(cAlias)
	Do While (cAlias)->(!Eof()) 
		nLin++
		For nC := 1 To Len(oPlan:aColunas)
			//oLinha := oPlan:aColunas[nC]
			cCampo := oPlan:aColunas[nC]:cCampo
			xCampo := &(cCampo)

			//aqui montar formato com aStruc
			If lFirst

				// Pega os atributos da Coluna
				cTipo 	:= oPlan:aColunas[nC]:GetTipo()
				nTamanho:= oPlan:aColunas[nC]:GetTamanho()
				nDecimal:= oPlan:aColunas[nC]:GetDecimal()
				nTamCol	:= oPlan:aColunas[nC]:GetTamCol()
				lTotal	:= oPlan:aColunas[nC]:GetTotal()
				cFormat	:= oPlan:aColunas[nC]:GetFormat()
				nField	:= oPlan:aColunas[nC]:GetField()
				cDefCpo := oPlan:aColunas[nC]:GetSx3()

				// Se informado X3
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

				// Salva os atributos
				oPlan:aColunas[nC]:SetTipo(cTipo)
				oPlan:aColunas[nC]:SetTamanho(nTamanho)
				oPlan:aColunas[nC]:SetDecimal(nDecimal)
				oPlan:aColunas[nC]:SetTamCol(nTamCol)
				oPlan:aColunas[nC]:SetTotal(lTotal)
				oPlan:aColunas[nC]:SetFormat(cFormat)

				// Aplica o tamanho da coluna
				Self:oPrtXlsx:SetColumnsWidth(nC,nC,nTamCol)

			Else
				cTipo 	:= oPlan:aColunas[nC]:GetTipo()
				nTamanho:= oPlan:aColunas[nC]:GetTamanho()
				nDecimal:= oPlan:aColunas[nC]:GetDecimal()
				nTamCol	:= oPlan:aColunas[nC]:GetTamCol()
				lTotal	:= oPlan:aColunas[nC]:GetTotal()
				cFormat	:= oPlan:aColunas[nC]:GetFormat()
			EndIf

			Self:oPrtXlsx:SetCellsFormat(cLHorAlig, cLVertAlig, lLWrapText, nLRotation, cCorFonte, cCorFundo, cFormat )

			If cTipo == "F"
				Self:oPrtXlsx:SetFormula(nLin,nC,xCampo)
			ElseIf cTipo == "D"
				If !Empty(xCampo)
					Self:oPrtXlsx:SetValue(nLin,nC,xCampo)
				EndIf
			Else
				Self:oPrtXlsx:SetValue(nLin,nC,xCampo)
			EndIf
		Next
		lFirst := .F.
		(cAlias)->(dbSkip())
	EndDo
Next

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
