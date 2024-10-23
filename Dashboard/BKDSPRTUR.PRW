#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSCTR
BK - Atualização da tabela CONTRATOS do banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/



// Atualização da Procedure BKTURNOVER do banco de dados dataP10
User Function BKDSPRTUR
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local cProg		:= "BKDSPRTUR"

If TCSPExist( "BKTURNOVER" )
	cQueryD := "DROP PROCEDURE BKTURNOVER"  
	nErro   := TcSqlExec(cQueryD)

	If nErro != 0
		cErro1 := TcSqlError()
	EndIf
EndIf

BEGINCONTENT VAR cQuery

CREATE PROCEDURE BKTURNOVER
AS
-- Turnover
DECLARE @NumEmp   smallint, @TipCol smallint, @NumCad int, @DatAlt datetime, @CodFil int
DECLARE @NumEmp1  smallint, @TipCol1 smallint, @NumCad1 int, @DatAlt1 datetime, @CodFil1 int
DECLARE @DataAfa  datetime
DECLARE @DataFim  datetime
DECLARE @DataNext datetime
DECLARE @nAfa     int
DECLARE @Compet   VARCHAR(6)
DECLARE @CompetD  date

IF OBJECT_ID(N'PowerBk.dbo.FOLHAFIL', N'U') IS NOT NULL   DROP TABLE PowerBk.dbo.FOLHAFIL 
IF OBJECT_ID(N'PowerBk.dbo.FOLHATUR', N'U') IS NOT NULL   DROP TABLE PowerBk.dbo.FOLHATUR

-- Tabela com Funcionarios x CCustos
CREATE TABLE PowerBk.dbo.FOLHAFIL(dataprc datetime,NumEmp smallint, CompetAM date, TipCol smallint, NumCad int, DatAlt datetime, CodFil int, ContAd int,ContAt int, ContAf int, DataFim datetime)
CREATE NONCLUSTERED INDEX [FOLHAFIL01] ON [PowerBk].[dbo].[FOLHAFIL]
(
	[NumEmp] ASC,
	[CompetAM] ASC,
	[TipCol] ASC,
	[NumCad] ASC

)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

-- Cursor para percorrer os registros
DECLARE cursor1 CURSOR FOR
--SELECT TOP 1000 NumEmp,TipCol,Numcad,DatAlt,CodFil
SELECT NumEmp,TipCol,Numcad,DatAlt,CodFil
 FROM [bk_senior].[bk_senior].[R038hfi]
 WHERE TipCol = 1
 ORDER BY NumEmp,TipCol,Numcad,DatAlt,CodFil

--Abrindo Cursor
OPEN cursor1
 
-- Lendo a próxima linha
FETCH NEXT FROM cursor1 INTO @NumEmp,@TipCol,@Numcad,@DatAlt,@CodFil
 
-- Percorrendo linhas do cursor (enquanto houverem)
WHILE @@FETCH_STATUS = 0
BEGIN

	--SET @DataAfa = (SELECT datafa FROM [bk_senior].[bk_senior].[r034fun]
	--							   WHERE numemp = @NumEmp AND tipcol = @TipCol AND numcad = @Numcad AND SitAfa = 7)

	SET @DataAfa = (SELECT datafa FROM [bk_senior].[bk_senior].[R038AFA]
								   WHERE numemp = @NumEmp AND tipcol = @TipCol AND numcad = @Numcad AND SitAfa = 7)

	SET @nAfa = 1
	--IF YEAR(@DataAfa) < 1910
	IF @DataAfa IS NULL
	BEGIN
		SET @nAfa = 0
		SET @DataAfa = GETDATE()
	END
	SET @DataFim = @DataAfa

	-- Executando as rotinas desejadas manipulando o registro
	SET @Compet  = CAST(YEAR(@DatAlt)  AS VARCHAR(4)) + REPLACE(STR(MONTH(@DatAlt),2),' ','0')
	SET @CompetD = CONVERT(date,SUBSTRING(@Compet,1,4)+'-'+SUBSTRING(@Compet,5,2)+'-01', 126)

    INSERT INTO PowerBk.dbo.FOLHAFIL VALUES(GETDATE(),@NumEmp,@CompetD,@TipCol,@Numcad,@DatAlt,@CodFil,1,1,0,@DataFim)

	SET @NumEmp1 = @NumEmp
	SET @TipCol1 = @TipCol
	SET @Numcad1 = @Numcad
	SET @DatAlt1 = @DatAlt
	SET @CodFil1 = @CodFil

	-- Lendo a próxima linha
	FETCH NEXT FROM cursor1 INTO @NumEmp,@TipCol,@Numcad,@DatAlt,@CodFil
	
	IF @NumEmp1 = @NumEmp AND
	   @TipCol1 = @TipCol AND
	   @Numcad1 = @Numcad AND
	   @@FETCH_STATUS = 0
	   BEGIN
		SET @DataFim = @DatAlt
		SET @nAfa = 1
	   END
		  
	SET @DataNext = @DatAlt1

	WHILE (CAST(YEAR(@DataNext) AS VARCHAR(4)) + REPLACE(STR(MONTH(@DataNext),2),' ','0') < 
	       CAST(YEAR(@DataFim)  AS VARCHAR(4)) + REPLACE(STR(MONTH(@DataFim),2),' ','0'))
	BEGIN
		SET @DataNext = DATEADD(m, 1, @DataNext)
		SET @Compet   = CAST(YEAR(@DataNext) AS VARCHAR(4)) + REPLACE(STR(MONTH(@DataNext),2),' ','0')
		SET @CompetD  = CONVERT(date,SUBSTRING(@Compet,1,4)+'-'+SUBSTRING(@Compet,5,2)+'-01', 126)

	    INSERT INTO PowerBk.dbo.FOLHAFIL VALUES(GETDATE(),@NumEmp1,@CompetD,@TipCol1,@Numcad1,@DataNext,@CodFil1,0,1,0,@DataFim);
	END
	IF @nAfa = 1
		INSERT INTO PowerBk.dbo.FOLHAFIL VALUES(GETDATE(),@NumEmp1,@CompetD,@TipCol1,@Numcad1,@DataNext,@CodFil1,0,-1,1,@DataFim);

END
 
-- Fechando Cursor para leitura
CLOSE cursor1
 
-- Finalizado o cursor
DEALLOCATE cursor1

SELECT 
GETDATE() AS dataprc,
NumEmp,
CodFil,
CompetAM,
SUM(ContAd) AS ContAd,
SUM(ContAt) AS ContAt,
SUM(ContAf) AS ContAf

INTO PowerBk.dbo.FOLHATUR
FROM PowerBk.dbo.FOLHAFIL 
GROUP BY NumEmp,CodFil,CompetAM
ORDER BY NumEmp,CodFil,CompetAM

ENDCONTENT

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2 := TcSqlError()
EndIf

u_QryResult(cProg,cQueryD+cQuery,cErro1+cErro2)

Return


// Atualização da Procedure BKTURNOVER do banco de dados dataP10
User Function BKDSTUR
Local cQuery	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""

//u_MsgLog("BKDSTUR","Inicio: Turnover")

If TCSPExist( "BKTURNOVER" )
	cQuery  := "EXEC BKTURNOVER"  
	nErro   := TcSqlExec(cQuery)

	If nErro != 0
		cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		u_MsgLog(cPerg,cErro1,"E")
	EndIf
EndIf

u_LogMemo("BKDSTUR.SQL",cErro1+cQuery)
//u_MsgLog("BKDSPRTUR","Final: Turnover")

Return
