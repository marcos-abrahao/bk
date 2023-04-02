#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDASH01
BK - Geração de tabelas para o PowerBI no banco PowerBK - Gestão
@Return
@author Marcos Bispo Abrahão
@since 28/08/2022
@version P12.1.33
/*/
// Chamada do Schedule
// https://tdn.totvs.com/pages/releaseview.action?pageId=36800166

Static Function Scheddef()
Local aParam
Local aOrd     := {}

aParam := {	"P",;		//Tipo R para relatorio P para processo   
			"PARAMDEF",;// Pergunte do relatorio, caso nao use passar ParamDef            
			"CN9",;		// Alias            
			aOrd,;		//Array de ordens   
			"PowerBk"}

Return aParam



User Function BKDASH01()
Local aCampos := {{ "MARCA"    , "C", 02, 0, "Marca"    ,"@!", .F., "" },;
				  { "ROTINA"   , "C", 15, 0, "Rotina"   ,"@!", .T., "" },;
				  { "DESCRICAO", "C", 70, 0, "Descrição","@!", .T., "" } }

Local aDados  := {}
Local nX 	  := 0
Local aGrpDsp := u_BKGrpDsp()
Local bProg
Local cBlind1 := ""
Local cBlind2 := ""
Local lOk     := .F.

Private cTitulo     := "Atualizar Dashboard PowerBk"
Private cPerg       := "BKDASH01"

If FWCodEmp() == "01"

	aDados  := {}
	cBlind1 := ""
	cBlind2 := ""

	If IsBlind(); 
			.AND. SUBSTRING(TIME(),1,2) > '05' ;
			.AND. SUBSTRING(TIME(),1,2) < '22';
		 	.AND. DOW(DATE()) <> 7;
		 	.AND. DOW(DATE()) <> 1
		cBlind1 := "X"
	EndIf


	If cBlind1 == "X" .AND. SUBSTRING(TIME(),1,2) == '19'
		cBlind2 := "X"
	EndIf
	aAdd(aDados,{cBlind2,"U_BKGCTR26(.T.)","Tabelas de Fluxo de Caixa Por Contrato"})

	cBlind2 := ""
	If cBlind1 == "X" .AND. SUBSTRING(TIME(),1,2) $ '06/14'
		cBlind2 := "X"
	EndIf
	aAdd(aDados,{cBlind2,"U_BKDSDSP1()"  ,"Atualização da tabela PREVDESP1"})
	aAdd(aDados,{cBlind2,"U_BKDSDSP2()"  ,"Atualização da tabela PREVDESP2"})
	aAdd(aDados,{cBlind2,"U_BKDSEMP()"   ,"Atualização da tabela EMPRESAS"})
	aAdd(aDados,{cBlind2,"U_BKDSCC()"    ,"Atualização da tabela CCUSTOS"})
	aAdd(aDados,{cBlind2,"U_BKDSFOL()"   ,"Atualização da tabela FOLHA"})
	aAdd(aDados,{cBlind2,"U_BKDSFER()"   ,"Atualização da tabela FERIAS"})
	aAdd(aDados,{cBlind2,"U_BKDSUSR()"   ,"Atualização da tabela USUARIOS"})
	aAdd(aDados,{cBlind2,"U_BKDSTUR()"   ,"Atualização da tabela FOLHAFIL e FOLHATUR"})
	aAdd(aDados,{cBlind2,"U_BKDSBKTUR()" ,"Atualização da tabela FOLHAFILBK"})
	aAdd(aDados,{cBlind2,"U_BKDSBKFAL()" ,"Atualização da tabela FOLHAFAL"})
	aAdd(aDados,{cBlind2,"U_BK040PER()"  ,"Atualização da tabela BK040PER"})
	aAdd(aDados,{cBlind2,"U_BKDSSC()"    ,"Atualização da tabela SOLCOMPRAS"})
	aAdd(aDados,{cBlind2,"U_BKDSCFAT()"  ,"Atualização da tabela CANCFATURAMENTO"})

	cBlind2 := ""
	If cBlind1 == "X" .AND. SUBSTRING(TIME(),1,2) $ '07/11/15'
		cBlind2 := "X"
	EndIf

	aAdd(aDados,{cBlind2,"U_BKDSGES()"   ,"Atualização da tabela GESTORES"})
	aAdd(aDados,{cBlind2,"U_BKDSGLO()"   ,"Atualização da tabela GLOSAS"})
	aAdd(aDados,{cBlind2,"U_BKDSCTR()"   ,"Atualização da tabela CONTRATOS"})
	aAdd(aDados,{cBlind2,"U_BKDSPLA()"   ,"Atualização da tabela PLANILHAS"})
	aAdd(aDados,{cBlind2,"U_BKDSCRO()"   ,"Atualização da tabela CRONOGRAMAS"})
	aAdd(aDados,{cBlind2,"U_BKDSGG()"    ,"Atualização da tabela GASTOSGERAIS"})

	aAdd(aDados,{cBlind1,"U_BKDSFAT()"   ,"Atualização da tabela FATURAMENTO"})
	aAdd(aDados,{cBlind1,"U_BKDSGER()"   ,"Atualização da tabela GERAL"})

	aAdd(aDados,{"","U_BKDSPRTUR()"      ,"Criação/atualização da Procedure BKTURNOVER"})
	aAdd(aDados,{"","U_BKPRBKTUR()"      ,"Criação/atualização da Procedure BKTURNOVER1"})
	aAdd(aDados,{"","U_BKDSPRFAL()"      ,"Criação/atualização da Procedure BKFALTAS"})
	aAdd(aDados,{"","U_PRODESPC()"       ,"Atualização da Tabela PRODESPCARGA"})
	aAdd(aDados,{"","U_PRODESPI()"       ,"Atualização da Tabela PRODESPINSERIR"})
	aAdd(aDados,{"","U_PRODESPA()"       ,"Atualização da Tabela PRODESPATUALIZAR"})
	aAdd(aDados,{"","U_PRODESPE()"       ,"Atualização da Tabela PRODESPEXCLUIR"})

	If !IsBlind()
		u_TTMARKB(aCampos, aDados, .F.)
	EndIf

	For nX := 1 To Len(aDados) 
		If !Empty(aDados[nX,1])
			bProg := {|oSay| x:= &(aDados[nX,2]) }
			u_WaitLog(cPerg, bProg, aDados[nX,2]+": "+aDados[nX,3])
		EndIf
	Next nX

ElseIf Ascan(aGrpDsp,{|x| x[1] == cEmpAnt}) > 0

	If !IsBlind()
		If u_MsgLog(cPerg,"Confirma a atualização das tabelas de Fluxo de Caixa Por Contrato do banco de dados PowerBk?", "Y")
			lOk := .T.
		EndIf
	ElseIf SUBSTRING(TIME(),1,2) == '20'
		lOk := .T.
	EndIf
	If lOk
		u_WaitLog(cPerg,{|oSay| U_BKGCTR26(.T.) },"Atualizando as tabelas de Fluxo de Caixa Por Contrato do banco de dados PowerBk...")
	EndIf

EndiF

Return


/*
Static Function fQueryf()
Local cQueryF := ""

BEGINCONTENT VAR cQueryF
CREATE FUNCTION bkccusto (
	@empresa CHAR(2),
	@ccusto CHAR(10)
)
RETURNS CHAR(9) AS
BEGIN
	DECLARE @contrato CHAR(9);
	SET @contrato = 
		CASE
			WHEN @empresa = '14' AND SUBSTRING(@ccusto,1,3) = '000'
				THEN '302000508'
			WHEN @empresa = '15' AND SUBSTRING(@ccusto,1,3) = '000'
				THEN '305000554'
			ELSE
				SUBSTRING(@ccusto,1,9)
		END
 
    RETURN @contrato
END;
ENDCONTENT
Return cQueryF
*/


