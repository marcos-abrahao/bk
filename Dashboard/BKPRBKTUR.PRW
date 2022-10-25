#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSCTR
BK - Atualização da Procedure BKTURNOVER1 do banco de dados dataP10

@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/

User Function BKPRBKTUR
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""

u_LogPrw("BKPRBKTUR","Create BKTURNOVER1")

If TCSPExist( "BKTURNOVER1" )
	cQueryD := "DROP PROCEDURE BKTURNOVER1"  
	nErro   := TcSqlExec(cQueryD)

	If nErro != 0
		cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		If !IsBlind()
			MsgStop(cErro1, cPerg)
		EndIf
	EndIf
EndIf

BEGINCONTENT VAR cQuery

CREATE PROCEDURE BKTURNOVER1
AS
-- Turnover BK geral
DECLARE @NumEmp   smallint, @TipCol smallint, @NumCad int, @datadm datetime, @datafa datetime, @caudem int
DECLARE @DataFim  datetime
DECLARE @DataAfa  datetime
DECLARE @DataNext datetime
DECLARE @nAfa     int
DECLARE @Compet   VARCHAR(6)
DECLARE @CompetD  date

IF OBJECT_ID(N'PowerBk.dbo.FOLHAFILBK', N'U') IS NOT NULL   DROP TABLE PowerBk.dbo.FOLHAFILBK 
--IF OBJECT_ID(N'PowerBk.dbo.FOLHATURBK', N'U') IS NOT NULL   DROP TABLE PowerBk.dbo.FOLHATURBK

-- Tabela com Funcionarios x CCustos
CREATE TABLE PowerBk.dbo.FOLHAFILBK(NumEmp smallint, CompetAM date, TipCol smallint, NumCad int, datadm datetime, datafa datetime, caudem int, ContAd int,ContAt int, ContAf int)

-- Cursor para percorrer os registros
DECLARE cursor1 CURSOR FOR
  SELECT NumEmp,TipCol,Numcad,datadm,datafa,caudem
  FROM [bk_senior].[bk_senior].[r034fun]
  WHERE TipCol = 1
  ORDER BY NumEmp,TipCol,Numcad

--Abrindo Cursor
OPEN cursor1
 
-- Lendo a próxima linha
FETCH NEXT FROM cursor1 INTO @NumEmp,@TipCol,@Numcad,@datadm,@datafa,@caudem
 
-- Percorrendo linhas do cursor (enquanto houverem)
WHILE @@FETCH_STATUS = 0
BEGIN

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
	SET @Compet  = CAST(YEAR(@datadm)  AS VARCHAR(4)) + REPLACE(STR(MONTH(@datadm),2),' ','0')
	SET @CompetD = CONVERT(date,SUBSTRING(@Compet,1,4)+'-'+SUBSTRING(@Compet,5,2)+'-01', 126)

    INSERT INTO PowerBk.dbo.FOLHAFILBK VALUES(@NumEmp,@CompetD,@TipCol,@Numcad,@datadm,@DataAfa,0,1,1,0)

	SET @DataNext = @datadm

	WHILE (CAST(YEAR(@DataNext) AS VARCHAR(4)) + REPLACE(STR(MONTH(@DataNext),2),' ','0') < 
	       CAST(YEAR(@DataFim)  AS VARCHAR(4)) + REPLACE(STR(MONTH(@DataFim),2),' ','0'))
	BEGIN
		SET @DataNext = DATEADD(m, 1, @DataNext)
		SET @Compet   = CAST(YEAR(@DataNext) AS VARCHAR(4)) + REPLACE(STR(MONTH(@DataNext),2),' ','0')
		SET @CompetD  = CONVERT(date,SUBSTRING(@Compet,1,4)+'-'+SUBSTRING(@Compet,5,2)+'-01', 126)

	    INSERT INTO PowerBk.dbo.FOLHAFILBK VALUES(@NumEmp,@CompetD,@TipCol,@Numcad,@datadm,@DataAfa,0,0,1,0)
	END
	IF @nAfa = 1
	    INSERT INTO PowerBk.dbo.FOLHAFILBK VALUES(@NumEmp,@CompetD,@TipCol,@Numcad,@datadm,@DataAfa,@caudem,0,-1,1)

	-- Lendo a próxima linha
	FETCH NEXT FROM cursor1 INTO @NumEmp,@TipCol,@Numcad,@datadm,@datafa,@caudem
	
END
 
-- Fechando Cursor para leitura
CLOSE cursor1
 
-- Finalizado o cursor
DEALLOCATE cursor1

ENDCONTENT

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro2, cPerg)
	EndIf
EndIf

u_LogMemo("BKPRBKTUR.SQL",cErro1+cQueryD+cErro2+cQuery)

Return


// Execução da Procedure BKTURNOVER1 do banco de dados dataP10
User Function BKDSBKTUR
Local cQuery	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""

u_LogPrw(cPerg,"TurnoverBK")

If TCSPExist( "BKTURNOVER1" )
	cQuery  := "EXEC BKTURNOVER1"  
	nErro   := TcSqlExec(cQuery)

	If nErro != 0
		cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		If !IsBlind()
			MsgStop(cErro1, cPerg)
		EndIf
	EndIf
EndIf

u_LogMemo("BKDSBKTUR.SQL",cErro1+cQuery)

Return

