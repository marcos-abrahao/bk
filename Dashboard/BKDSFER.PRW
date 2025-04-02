#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/


ROTINA DESATIVADA EM 28/03/2025 - SOLICITADO POR FERNANDO SAMPAIO


/*/


/*/{Protheus.doc} BKDSFER
BK - Atualização da tabela FERIAS do banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/

User Function BKDSFER
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local cProg		:= "BKDSFER"

BEGINCONTENT VAR cQuery
WITH FER1 AS 
(
SELECT --DISTINCT --TOP 100
SUBSTRING(REPLACE(STR(bk_senior.bk_senior.R034fun.NumEmp,2),' ','0'),1,2) COLLATE Latin1_General_BIN AS EMPRESA,
GETDATE() AS DATAPRC,
(SELECT TOP 1 SUBSTRING(BKIntegraRubi.dbo.CUSTOSIGA.ccSiga,1,9)
	FROM BKIntegraRubi.dbo.CUSTOSIGA 
	WHERE bk_senior.bk_senior.R034fun.NumEmp = BKIntegraRubi.dbo.CUSTOSIGA.NumEmp
	AND bk_senior.bk_senior.R034fun.NumCad = BKIntegraRubi.dbo.CUSTOSIGA.Numcad
	AND bk_senior.bk_senior.R034fun.TipCol = BKIntegraRubi.dbo.CUSTOSIGA.TipCol) AS CCUSTO,
bk_senior.bk_senior.R034fun.NumEmp,
bk_senior.bk_senior.R034fun.NumCad,
bk_senior.bk_senior.R034fun.nomfun,
bk_senior.bk_senior.R034fun.datnas,
bk_senior.bk_senior.R040PER.IniPer,
bk_senior.bk_senior.R040PER.FimPer,
bk_senior.bk_senior.R040PER.QtdDir,
bk_senior.bk_senior.R040PER.QtdAfa,
bk_senior.bk_senior.R040PER.QtdFal,
bk_senior.bk_senior.R040PER.QtdSld,
bk_senior.bk_senior.R034fun.caudem,
bk_senior.bk_senior.R034fun.datafa,
CONVERT(NCHAR(6),bk_senior.bk_senior.R034fun.datafa,112) as COMPETAMAF,
bk_senior.bk_senior.R034fun.datadm,
CONVERT(NCHAR(6),bk_senior.bk_senior.R034fun.datadm,112) as COMPETAMAD,
bk_senior.bk_senior.R042CAU.DesDem,
bk_senior.bk_senior.R034fun.sitafa,
(CASE 
 WHEN bk_senior.bk_senior.R034fun.sitafa =  1 THEN 'TRABALHANDO'
 WHEN bk_senior.bk_senior.R034fun.sitafa =  2 THEN 'FÉRIAS'
 WHEN bk_senior.bk_senior.R034fun.sitafa =  3 THEN 'AUXÍLIO DOENÇA'
 WHEN bk_senior.bk_senior.R034fun.sitafa =  4 THEN 'ACIDENTE DE TRABALHO'
 WHEN bk_senior.bk_senior.R034fun.sitafa =  5 THEN 'SERVIÇO MILITAR'
 WHEN bk_senior.bk_senior.R034fun.sitafa =  6 THEN 'LICENÇA MATERNIDADE'
 WHEN bk_senior.bk_senior.R034fun.sitafa =  7 THEN 'DEMITIDO'
 WHEN bk_senior.bk_senior.R034fun.sitafa =  8 THEN 'LIC. S/ REMUNARAÇÃO'
 WHEN bk_senior.bk_senior.R034fun.sitafa =  9 THEN 'LIC. REM. P/ EMPRESA'
 WHEN bk_senior.bk_senior.R034fun.sitafa = 14 THEN 'ATESTADO'
 WHEN bk_senior.bk_senior.R034fun.sitafa = 22 THEN 'APOSENTADORIA'
 WHEN bk_senior.bk_senior.R034fun.sitafa =107 THEN 'APOSENTADORIA INVALIDEZ COD32'
END) AS DESCAFA,
bk_senior.bk_senior.R040PER.SitPer,
(CASE WHEN bk_senior.bk_senior.R040PER.SitPer = 0 THEN 'ABERTA'
  WHEN bk_senior.bk_senior.R040PER.SitPer = 1 THEN 'QUITADA NORMAL'
  WHEN bk_senior.bk_senior.R040PER.SitPer = 2 THEN 'QUITADA RESCISÃO'
     WHEN bk_senior.bk_senior.R040PER.SitPer = 3 THEN 'QUITADA P/ FALTAS'
     WHEN bk_senior.bk_senior.R040PER.SitPer = 4 THEN 'QUITADA P/ AFASTAMENTOS'
END) AS DESCRICAOPERIODO
FROM bk_senior.bk_senior.R034fun
LEFT JOIN bk_senior.bk_senior.R040PER
	ON bk_senior.bk_senior.R034fun.NumEmp  = bk_senior.bk_senior.R040PER.NumEmp
	AND bk_senior.bk_senior.R034fun.NumCad = bk_senior.bk_senior.R040PER.Numcad
	AND bk_senior.bk_senior.R034fun.TipCol = bk_senior.bk_senior.R040PER.TipCol
LEFT JOIN  bk_senior.bk_senior.R042CAU 
	ON bk_senior.bk_senior.R034fun.caudem  = bk_senior.bk_senior.R042CAU.caudem
WHERE bk_senior.bk_senior.R034fun.tipcol = 1
),
FER AS (
SELECT 
(CASE WHEN EMPRESA = '14' THEN '302000508'
      WHEN EMPRESA = '15' THEN '305000554'
	  WHEN EMPRESA = '16' THEN '386000609'
	  WHEN EMPRESA = '18' THEN '303000623'
	ELSE SUBSTRING(CCUSTO,1,9) END) AS CONTRATO,
*
FROM FER1
)
SELECT 
EMPRESAS.NOMEEMP AS NOMEEMP,
FER.*,
CCUSTOS.DESCRCC AS DESCRICAO
INTO PowerBk.dbo.FERIAS
FROM FER
LEFT JOIN PowerBk.dbo.EMPRESAS ON FER.EMPRESA = EMPRESAS.EMPRESA COLLATE Latin1_General_BIN
LEFT JOIN PowerBk.dbo.CCUSTOS  ON FER.EMPRESA = CCUSTOS.EMPRESA AND FER.CONTRATO = CCUSTOS.CCUSTO COLLATE Latin1_General_BIN
ORDER by NumEmp,NumCad,IniPer

ENDCONTENT

u_LogMemo("BKDSFER.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.FERIAS', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.FERIAS "+CRLF
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


