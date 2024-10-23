#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BK040PER
BK - Atualização da tabela BK040PER do banco de dados PowerBk - Periodo aquisitivo de férias

@Return
@author Marcos Bispo Abrahão
@since 11/11/2022
@version P12.1.33
/*/

User Function BK040PER
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local cProg 	:= "BK040PER"

//u_MsgLog("BK040PER","Inicio: BK040PER")

// R030EMP -- cadastro de empresas
// R030FIL -- cadastro de filiais
// R014SIN -- cadastro de sindicatos
// R024CAR -- cadastro de cargos
// R012BAN -- cadastro de bancos
// R012AGE -- cadastro de agencias
// R004HOR -- cadastro de horario
// R018CCU -- cadastro de centros de custo
// R010SIT -- cadastro de situacoes
// R076MOT -- cadastro de motivos
// R022GRA -- cadastro de grau de instrucao
// R034FUN -- cadastro de funcionarios
// R036DEP -- cadastro de dependentes
// R038AFA -- historico de afastamentos
// R038HSA -- historico de salarios

BEGINCONTENT VAR cQuery

  WITH R040P AS (
	SELECT
	SUBSTRING(REPLACE(STR(R040.NumEmp,2),' ','0'),1,2) COLLATE Latin1_General_BIN AS EMPRESA,
	GETDATE() AS DATAPRC,
	R040.NumCad,
	
	R034.nomfun COLLATE Latin1_General_BIN AS NOME,
	R034.codcar AS CODCARGO,
	UPPER(R024.TitCar) COLLATE Latin1_General_BIN AS CARGO,
	(SELECT TOP 1 CodFil FROM PowerBk.dbo.FOLHAFIL FI 
							WHERE R040.Numemp = FI.NumEmp AND
								  R040.TipCol = FI.TipCol AND
								  R040.Numcad = FI.NumCad 
								  ORDER BY CompetAM DESC) as CodFil,

	R040.IniPer,
	R040.FimPer,
	R040.QtdDir,
	R040.QtdFal,
	R040.QtdAfa,
	R040.QtdLir,
	R040.QtdDeb,
	R040.QtdLin,
	R040.QtdMil,
	R040.QtdAbo,
	R040.QtdSld,
	R040.QtdAbn,
	R040.QtdAsd,
	R040.QtdGas,
	R040.AvoFer,
	R040.AvoPer,
	R040.DiaCom,
	R040.DiaDev,
	R040.QtdPng,
	R040.SitPer,
	R040.AltFim,
	R040.PerSus,
	R040.PagAdi,
	R040.QtdUte,
	R040.TotUte,
	R040.TotU30,
	R040.limcon,
	R040.diaint,
	R040.datint

 FROM bk_senior.bk_senior.R040PER R040
 LEFT JOIN bk_senior.bk_senior.R034FUN R034
		ON 	R040.NumEmp = R034.numemp
		AND R040.NumCad = R034.numcad
		AND R040.TipCol = R034.tipcol
 LEFT JOIN bk_senior.bk_senior.R024CAR R024
		ON 	R034.codcar = R024.CodCar
		AND	R024.EstCar = 1
 --WHERE 
--	Tipcal IN(11) AND Sitcal = 'T'

	)
	SELECT 
	EMPRESAS.NOMEEMP AS NOMEEMP,
	--CCUSTOS.DESCRCC AS DESCRICAO,
	R040P.*

	INTO PowerBk.dbo.BK040PER
	FROM R040P 
	LEFT JOIN PowerBk.dbo.EMPRESAS ON R040P.EMPRESA = EMPRESAS.EMPRESA COLLATE Latin1_General_BIN
	--LEFT JOIN PowerBk.dbo.CCUSTOS  ON R040P.EMPRESA = CCUSTOS.EMPRESA AND R040P.CONTRATO = CCUSTOS.CCUSTO COLLATE Latin1_General_BIN

ENDCONTENT

u_LogMemo("BK040PER.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.BK040PER', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.BK040PER "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1 := TcSqlError()
EndIf

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2 := TcSqlError()
EndIf

u_QryResult(cProg,cQueryD+cQuery,cErro1+cErro2)

Return
