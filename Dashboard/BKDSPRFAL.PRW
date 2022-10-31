#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSPRFAL
BK - Atualização da Procedure BKFALTAS do banco de dados dataP10

@Return
@author Marcos Bispo Abrahão
@since 25/10/2022
@version P12.1.25
/*/

User Function BKDSPRFAL
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""

u_LogPrw("BKDSPRFAL","Create BKFALTAS")

If TCSPExist( "BKFALTAS" )
	cQueryD := "DROP PROCEDURE BKFALTAS"  
	nErro   := TcSqlExec(cQueryD)

	If nErro != 0
		cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		If !IsBlind()
			MsgStop(cErro1, cPerg)
		EndIf
	EndIf
EndIf

BEGINCONTENT VAR cQuery

CREATE PROCEDURE BKFALTAS
AS
-- Afastamentos BK
DECLARE @NumEmp   smallint, @TipCol smallint, @NumCad int, @CodEsc int, @datafa datetime, @dattmp datetime, @datter datetime, @sitafa int
DECLARE @DataFim  datetime
DECLARE @DataAfa  datetime
DECLARE @DataNext datetime
DECLARE @nAfa     int
DECLARE @nTrb     int
DECLARE @Compet   VARCHAR(6)
DECLARE @CompetD  date
DECLARE @CodHor	  smallint
DECLARE @SeqReg	  smallint
DECLARE @CodFil	  int

IF OBJECT_ID(N'PowerBk.dbo.FOLHAFAL', N'U') IS NULL
BEGIN
    -- Tabela com Funcionarios x CCustos
    CREATE TABLE PowerBk.dbo.FOLHAFAL(NumEmp smallint, CompetAM date, TipCol smallint, NumCad int, CodEsc int, datafa datetime, dattmp datetime,datter datetime, sitafa int, ContAfa int,ContTrb int,CodHor smallint, SeqReg smallint, CodFil int, dataprc datetime)

    -- Cursor para percorrer TODOS os registros
    DECLARE cursor1 CURSOR FOR
    SELECT NumEmp,TipCol,Numcad,datafa,datter,sitafa
    FROM [bk_senior].[bk_senior].[vbi_hissit]
    WHERE TipCol = 1 AND sitafa <> 1 AND sitafa <> 7
    --AND numcad >= 32520 -- TESTE
    --ORDER BY NumEmp,TipCol,Numcad,datafa
    ORDER BY datafa,NumEmp,TipCol,Numcad
END
ELSE
BEGIN
	-- DROP TABLE PowerBk.dbo.FOLHAFAL
    -- Deletar 3 meses
    SET @datter   = GETDATE()
    SET @datter   = DATEADD(m, -3, @datter)
    SET @datter   = DATEADD(d, -DAY(@datter), @datter)
    --SELECT @datter
    DELETE FROM PowerBk.dbo.FOLHAFAL WHERE datafa > @datter

    -- Cursor para percorrer OS ULTIMOS 3 MESES
    DECLARE cursor1 CURSOR FOR
    SELECT NumEmp,TipCol,Numcad,datafa,datter,sitafa
    FROM [bk_senior].[bk_senior].[vbi_hissit]
    WHERE TipCol = 1 AND sitafa <> 1 AND sitafa <> 7
          AND datafa > @datter
    --AND numcad >= 32520 -- TESTE
    --AND numcad = 249 --32520 -- TESTE
    --ORDER BY NumEmp,TipCol,Numcad,datafa
    ORDER BY datafa,NumEmp,TipCol,Numcad

	-- SELECT * FROM FOLHAFAL where dataprc  >= CONVERT(datetime, '2022-10-26 08:40:24.950', 121)

END

--Abrindo Cursor
OPEN cursor1
 
-- Lendo a próxima linha
FETCH NEXT FROM cursor1 INTO @NumEmp,@TipCol,@Numcad,@datafa,@datter,@sitafa
 
-- Percorrendo linhas do cursor (enquanto houverem)
WHILE @@FETCH_STATUS = 0
BEGIN

	IF YEAR(@datter) > 2050
	BEGIN
		SET @datter = GETDATE()
	END
	SET @DataFim = @datter
	SET @DataNext = @datafa

	WHILE @DataNext < @DataFim
	BEGIN

		SET @Compet   = CAST(YEAR(@DataNext) AS VARCHAR(4)) + REPLACE(STR(MONTH(@DataNext),2),' ','0')
		SET @CompetD  = CONVERT(date,SUBSTRING(@Compet,1,4)+'-'+SUBSTRING(@Compet,5,2)+'-01', 126)
		SET @nTrb = 0
		SET @nAfa = 0

		-- Escala
		SET @CodEsc = (SELECT TOP 1 CodEsc FROM [bk_senior].[bk_senior].[R038HES] 
						WHERE NumEmp = @Numemp AND TipCol = 1 AND numcad = @Numcad
						      AND DatAlt <= @DataNext ORDER BY DatAlt DESC)
		---
		
		SET @CodFil = (SELECT TOP 1 CodFil FROM PowerBk.dbo.FOLHAFIL FI 
						WHERE @Numemp = FI.NumEmp AND
						       TipCol = FI.TipCol AND
						      @Numcad = FI.NumCad AND
						      @CompetD = FI.CompetAM)

		IF @CodFil IS NULL
		BEGIN
			SET @CodFil = (SELECT TOP 1 CodFil FROM PowerBk.dbo.FOLHAFIL FI 
							WHERE @Numemp = FI.NumEmp AND
								   TipCol = FI.TipCol AND
								  @Numcad = FI.NumCad 
								  ORDER BY CompetAM DESC)
		END	
			
		SET @SeqReg = DATEPART(dw,@DataNext)
		SET @CodHor = (SELECT CodHor FROM [bk_senior].[bk_senior].[R006HOR] WHERE CodEsc = @CodEsc and SeqReg = @SeqReg)

		SET @DataNext = DATEADD(d, 1, @DataNext)
		IF @CodHor < 1000
		BEGIN 
			IF @sitafa = 1
			BEGIN
				SET @nTrb = @nTrb + 1
			END
			ELSE
			BEGIN
				SET @nAfa = @nAfa + 1
			END
		END
	    INSERT INTO PowerBk.dbo.FOLHAFAL VALUES(@NumEmp,@CompetD,@TipCol,@Numcad,@CodEsc,@datafa,@DataNext,@datter,@sitafa,@nAfa,@nTrb,@CodHor,@SeqReg,@CodFil,GETDATE())
	END

	-- Lendo a próxima linha
	FETCH NEXT FROM cursor1 INTO @NumEmp,@TipCol,@Numcad,@datafa,@datter,@sitafa
	
END
 
-- Fechando Cursor para leitura
CLOSE cursor1
 
-- Finalizado o cursor
DEALLOCATE cursor1

/*
SELECT *,FI.CodFil FROM FOLHAFAL FA
LEFT JOIN FOLHAFIL FI 
	ON FA.NumEmp = FI.NumEmp AND
	   FA.TipCol = FI.TipCol AND
	   FA.NumCad = FI.NumCad AND
	   FA.CompetAM = FI.CompetAM
ORDER BY FA.NumEmp,FA.TipCol,FA.NumCad,FA.datafa
*/

/*
SELECT
    DB_NAME(dbid) as Banco, 
    COUNT(dbid) as QtdeConexoes,
    loginame as Login
FROM
    sys.sysprocesses
WHERE
    dbid > 0
GROUP BY
    dbid, loginame
   */
ENDCONTENT

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro2, cPerg)
	EndIf
EndIf

u_LogMemo("BKDSPRFAL.SQL",cErro1+cQueryD+cErro2+cQuery)

Return


// Execução da Procedure BKFALTAS do banco de dados dataP10
User Function BKDSBKFAL
Local cQuery	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""

u_LogPrw("BKDSBKFAL","Faltas")

If TCSPExist( "BKFALTAS" )
	cQuery  := "EXEC BKFALTAS"  
	nErro   := TcSqlExec(cQuery)

	If nErro != 0
		cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		If !IsBlind()
			MsgStop(cErro1, cPerg)
		EndIf
	EndIf
EndIf

u_LogMemo("BKDSBKFAL.SQL",cErro1+cQuery)
u_LogPrw("BKDSPRFAL","Final: Faltas")

Return
