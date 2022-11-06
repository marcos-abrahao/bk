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

Private cTitulo     := "Atualizar Dashboard PowerBk"
Private cPerg       := "BKDASH01"

If FWCodEmp() == "01"

	u_MsgLog(cPerg,"Inicio")

	If IsBlind()
		//If (DOW(DATE()) = 7 .OR. DOW(DATE()) = 4) .AND. SUBSTRING(TIME(),1,2) = '06'

		If SUBSTRING(TIME(),1,2) == '19' //.AND. DOW(DATE()) <> 1
			U_BKGCTR26(.T.)
		EndIf

		If SUBSTRING(TIME(),1,2) > '05' ;
				.AND. SUBSTRING(TIME(),1,2) < '22';
			 	.AND. DOW(DATE()) <> 7;
			 	.AND. DOW(DATE()) <> 1

			If SUBSTRING(TIME(),1,2) $ '06/14'
				U_BKDSDSP1()
				U_BKDSDSP2()
				U_BKDSEMP()
				U_BKDSCC()
				U_BKDSFOL()
				U_BKDSFER()
				U_BKDSUSR()
				U_BKDSTUR()
				U_BKDSBKTUR()
				U_BKDSBKFAL()
				U_BKDSSC()
			EndIf

			U_BKDSFAT()

			If SUBSTRING(TIME(),1,2) $ '07/11/15'
				U_BKDSGES()
				U_BKDSGLO()
				U_BKDSCTR()
				U_BKDSPLA()
				U_BKDSCRO()
				U_BKDSGG()
			EndIf
			//U_BKDSGLF()
			U_BKDSGER()

		EndIf

	Else
		aDados := {}
		aAdd(aDados,{"","U_BKGCTR26(.T.)","Tabelas de Fluxo de Caixa Por Contrato"})
		aAdd(aDados,{"","U_BKDSPRTUR()"  ,"Criação/atualização da Procedure BKTURNOVER"})
		aAdd(aDados,{"","U_BKDSTUR()"    ,"Atualização da tabela FOLHAFIL e FOLHATUR"})

		aAdd(aDados,{"","U_BKPRBKTUR()"  ,"Criação/atualização da Procedure BKTURNOVER1"})
		aAdd(aDados,{"","U_BKDSBKTUR()"  ,"Atualização da tabela FOLHAFILBK"})

		aAdd(aDados,{"","U_BKDSPRFAL()"  ,"Criação/atualização da Procedure BKFALTAS"})
		aAdd(aDados,{"","U_BKDSBKFAL()"  ,"Atualização da tabela FOLHAFAL"})

		aAdd(aDados,{"","U_BKDSDSP1()"   ,"Atualização da tabela PREVDESP1"})
		aAdd(aDados,{"","U_BKDSDSP2()"   ,"Atualização da tabela PREVDESP2"})
		aAdd(aDados,{"","U_BKDSEMP()"    ,"Atualização da tabela EMPRESAS"})
		aAdd(aDados,{"","U_BKDSCC()"     ,"Atualização da tabela CCUSTOS"})
		aAdd(aDados,{"","U_BKDSFOL()"    ,"Atualização da tabela FOLHA"})
		aAdd(aDados,{"","U_BKDSFER()"    ,"Atualização da tabela FERIAS"})
		aAdd(aDados,{"","U_BKDSUSR()"    ,"Atualização da tabela USUARIOS"})
		aAdd(aDados,{"","U_BKDSCTR()"    ,"Atualização da tabela CONTRATOS"})
		aAdd(aDados,{"","U_BKDSPLA()"    ,"Atualização da tabela PLANILHAS"})
		aAdd(aDados,{"","U_BKDSCRO()"    ,"Atualização da tabela CRONOGRAMAS"})
		aAdd(aDados,{"","U_BKDSFAT()"    ,"Atualização da tabela FATURAMENTO"})
		aAdd(aDados,{"","U_BKDSGES()"    ,"Atualização da tabela GESTORES"})
		aAdd(aDados,{"","U_BKDSGLO()"    ,"Atualização da tabela GLOSAS"})
		aAdd(aDados,{"","U_BKDSGG()"     ,"Atualização da tabela GASTOSGERAIS"})
		aAdd(aDados,{"","U_BKDSSC()"     ,"Atualização da tabela SOLCOMPRAS"})
		aAdd(aDados,{"","U_BKDSGER()"    ,"Atualização da tabela GERAL"})

		u_TTMARKB(aCampos, aDados, .F.)

		For nX := 1 To Len(aDados) 
			If !Empty(aDados[nX,1])
				FWMsgRun(, {|oSay| x:= &(aDados[nX,2]) }, "", aDados[nX,2]+": "+aDados[nX,3])
			EndIf
		Next nX

	EndIf
	u_MsgLog(cPerg,"Final")

ElseIf Ascan(aGrpDsp,{|x| x[1] == cEmpAnt}) > 0

	If !IsBlind()
		If MsgYesNo("Confirma a atualização das tabelas de Fluxo de Caixa Por Contrato do banco de dados PowerBk?", cPerg)
			u_MsgLog(cPerg,"Inicio")
			FWMsgRun(, {|oSay| U_BKGCTR26(.T.) }, "", "Atualizando as tabelas de Fluxo de Caixa Por Contrato do banco de dados PowerBk...")
			u_MsgLog(cPerg,"Final")
		EndIf
	Else
		If SUBSTRING(TIME(),1,2) = '20'
			u_MsgLog(cPerg,"Inicio")
			U_BKGCTR26(.T.)
			u_MsgLog(cPerg,"Final")
		EndIf
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


