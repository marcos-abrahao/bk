#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDSFOL
BK - Atualização da tabela FOLHA do banco de dados PowerBk

@Return
@author Marcos Bispo Abrahão
@since 27/09/2022
@version P12.1.25
/*/

User Function BKDSFOL
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local cProg		:= "BKDSFOL"

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
  WITH FOLHA AS (
	SELECT
	SUBSTRING(REPLACE(STR(bk_senior.bk_senior.R046VER.NumEmp,2),' ','0'),1,2) COLLATE Latin1_General_BIN AS EMPRESA,
	--SUBSTRING(UPPER(bk_senior.bk_senior.R030EMP.nomemp),1,10) AS NOMEEMP,
	GETDATE() AS DATAPRC,
    (CASE WHEN bk_senior.bk_senior.R046VER.NumEmp = 14 AND 
				SUBSTRING(BKIntegraRubi.dbo.CUSTOSIGA.ccSiga,1,3) IN ('000','Er:') THEN '302000508'
          WHEN bk_senior.bk_senior.R046VER.NumEmp = 15 AND 
		        SUBSTRING(BKIntegraRubi.dbo.CUSTOSIGA.ccSiga,1,3) IN ('000','Er:') THEN '305000554'
          WHEN bk_senior.bk_senior.R046VER.NumEmp = 16 AND 
		        SUBSTRING(BKIntegraRubi.dbo.CUSTOSIGA.ccSiga,1,3) IN ('000','Er:') THEN '386000609'
          WHEN bk_senior.bk_senior.R046VER.NumEmp = 18 AND 
		        SUBSTRING(BKIntegraRubi.dbo.CUSTOSIGA.ccSiga,1,3) IN ('000','Er:') THEN '303000623'
		  ELSE SUBSTRING(BKIntegraRubi.dbo.CUSTOSIGA.ccSiga,1,9) END) COLLATE Latin1_General_BIN AS CONTRATO,

	SUBSTRING(CONVERT(VARCHAR,PerRef,112),1,6) COLLATE Latin1_General_BIN AS COMPETAM,
	SUBSTRING(REPLACE(STR(bk_senior.bk_senior.R046VER.NumEmp,2),' ','0'),1,2) + 
       (CASE WHEN bk_senior.bk_senior.R046VER.NumEmp = 14 AND 
			  	  SUBSTRING(BKIntegraRubi.dbo.CUSTOSIGA.ccSiga,1,3) IN ('000','Er:') THEN '302000508'
             WHEN bk_senior.bk_senior.R046VER.NumEmp = 15 AND 
		          SUBSTRING(BKIntegraRubi.dbo.CUSTOSIGA.ccSiga,1,3) IN ('000','Er:') THEN '305000554'
             WHEN bk_senior.bk_senior.R046VER.NumEmp = 16 AND 
		          SUBSTRING(BKIntegraRubi.dbo.CUSTOSIGA.ccSiga,1,3) IN ('000','Er:') THEN '386000609'
             WHEN bk_senior.bk_senior.R046VER.NumEmp = 18 AND 
		          SUBSTRING(BKIntegraRubi.dbo.CUSTOSIGA.ccSiga,1,3) IN ('000','Er:') THEN '303000623'
		     ELSE BKIntegraRubi.dbo.CUSTOSIGA.ccSiga END) +
	    SUBSTRING(CONVERT(VARCHAR,PerRef,112),1,6) COLLATE Latin1_General_BIN AS CHAVE,
	bk_senior.bk_senior.R044CAL.PerRef AS COMPETD,
	bk_senior.bk_senior.R046VER.NumCad AS REGISTRO,
	bk_senior.bk_senior.R034FUN.nomfun COLLATE Latin1_General_BIN AS NOME,
	bk_senior.bk_senior.R034FUN.codcar AS CODCARGO,
	UPPER(bk_senior.bk_senior.R024CAR.TitCar) COLLATE Latin1_General_BIN AS CARGO,
	bk_senior.bk_senior.R046VER.CodEve AS EVENTO,
	UPPER(bk_senior.bk_senior.R008EVC.DesEve) COLLATE Latin1_General_BIN AS DESCREVENTO,
	bk_senior.bk_senior.R008EVC.TipEve AS TIPOEVENTO,
	(CASE WHEN bk_senior.bk_senior.R008EVC.TipEve = 3
			   THEN -bk_senior.bk_senior.R046VER.ValEve 
	      ELSE bk_senior.bk_senior.R046VER.ValEve END) AS VALOR,

	(CASE WHEN bk_senior.bk_senior.R046VER.CodEve IN #PROVENTOS#
			   THEN bk_senior.bk_senior.R046VER.ValEve 
	      ELSE 0 END) AS PROVENTOS,

	(CASE WHEN bk_senior.bk_senior.R046VER.CodEve IN #DESCONTOS#
			   THEN -bk_senior.bk_senior.R046VER.ValEve 
	      ELSE 0 END) AS DESCONTOS,

	(CASE WHEN bk_senior.bk_senior.R046VER.CodEve IN #PLR#
			   THEN bk_senior.bk_senior.R046VER.ValEve 
	      ELSE 0 END) AS PLR,

	(CASE WHEN bk_senior.bk_senior.R046VER.CodEve IN #VTPROV#
			   THEN bk_senior.bk_senior.R046VER.ValEve 
	      ELSE 0 END) AS VTPROV,

	(CASE WHEN bk_senior.bk_senior.R046VER.CodEve IN #VTVER#
			   THEN -bk_senior.bk_senior.R046VER.ValEve 
	      ELSE 0 END) AS VTVER,

	(CASE WHEN bk_senior.bk_senior.R046VER.CodEve IN #VRVAV#
			   THEN -bk_senior.bk_senior.R046VER.ValEve 
	      ELSE 0 END) AS VRVAV,

	(CASE WHEN bk_senior.bk_senior.R046VER.CodEve IN #ASSMP#
			   THEN bk_senior.bk_senior.R046VER.ValEve 
	      ELSE 0 END) AS ASSMP,

	(CASE WHEN bk_senior.bk_senior.R046VER.CodEve IN #ASSMV#
			   THEN -bk_senior.bk_senior.R046VER.ValEve 
	      ELSE 0 END) AS ASSMV,

	(CASE WHEN bk_senior.bk_senior.R046VER.CodEve IN #SINOP#
			   THEN bk_senior.bk_senior.R046VER.ValEve 
	      ELSE 0 END) AS SINOP,

	(CASE WHEN bk_senior.bk_senior.R046VER.CodEve IN #SINOV#
			   THEN -bk_senior.bk_senior.R046VER.ValEve 
	      ELSE 0 END) AS SINOV,

	(CASE WHEN bk_senior.bk_senior.R046VER.CodEve IN #SEMINC#
			   THEN bk_senior.bk_senior.R046VER.ValEve 
	      ELSE 0 END) AS SEMINC,

	(CASE WHEN bk_senior.bk_senior.R046VER.NumEmp = 2
			   THEN 8
		  WHEN SUBSTRING(BKIntegraRubi.dbo.CUSTOSIGA.ccSiga,7,3) IN #FURNAS#
			   THEN 35.8764
		  ELSE 37.13280 END) AS PENCARGOS,

	(CASE WHEN bk_senior.bk_senior.R046VER.NumEmp = 2
			   THEN 20.700
		  WHEN SUBSTRING(BKIntegraRubi.dbo.CUSTOSIGA.ccSiga,7,3) IN #FURNAS#
			   THEN 0
		  ELSE 28.860 END) AS PINCIDENCIAS,

	(SELECT TOP 1 [Total] FROM [BKIntegraRubi].[dbo].[EVENTOS_ASS_ODONT] 
	  WHERE [BKIntegraRubi].[dbo].[EVENTOS_ASS_ODONT].NumEmpr = bk_senior.bk_senior.R046VER.NumEmp AND 
	        CodTab = 1 AND 
		    [BKIntegraRubi].[dbo].[EVENTOS_ASS_ODONT].CodEve = bk_senior.bk_senior.R046VER.CodEve AND 
            SUBSTRING(CONVERT(VARCHAR,Validade,112),1,6) <= SUBSTRING(CONVERT(VARCHAR,PerRef,112),1,6) 
      ORDER BY [BKIntegraRubi].[dbo].[EVENTOS_ASS_ODONT].Validade DESC) AS VALASSOD 
 FROM bk_senior.bk_senior.R046VER 
 --LEFT JOIN bk_senior.bk_senior.R030EMP 
            --ON 	bk_senior.bk_senior.R046VER.NumEmp = bk_senior.bk_senior.R030EMP.numemp
 INNER JOIN bk_senior.bk_senior.R044cal  
            ON  bk_senior.bk_senior.R046VER.NumEmp = bk_senior.bk_senior.R044cal.NumEmp
            AND bk_senior.bk_senior.R046VER.CodCal= bk_senior.bk_senior.R044cal.Codcal
 INNER JOIN BKIntegraRubi.dbo.CUSTOSIGA 
			ON bk_senior.bk_senior.R046VER.NumEmp= BKIntegraRubi.dbo.CUSTOSIGA.NumEmp
			AND bk_senior.bk_senior.R046VER.NumCad = BKIntegraRubi.dbo.CUSTOSIGA.Numcad
			AND bk_senior.bk_senior.R046VER.TipCol = BKIntegraRubi.dbo.CUSTOSIGA.TipCol
			AND bk_senior.bk_senior.R044cal.Codcal = BKIntegraRubi.dbo.CUSTOSIGA.Codcal
 INNER JOIN bk_senior.bk_senior.R008EVC 
			ON bk_senior.bk_senior.R046VER.TabEve = bk_senior.bk_senior.R008EVC.CodTab
			AND bk_senior.bk_senior.R046VER.CodEve = bk_senior.bk_senior.R008EVC.CodEve
 LEFT JOIN bk_senior.bk_senior.R034FUN 
		ON 	bk_senior.bk_senior.R046VER.NumEmp = bk_senior.bk_senior.R034FUN.numemp
		AND bk_senior.bk_senior.R046VER.NumCad = bk_senior.bk_senior.R034FUN.numcad
		AND bk_senior.bk_senior.R046VER.TipCol = bk_senior.bk_senior.R034FUN.tipcol
 LEFT JOIN bk_senior.bk_senior.R024CAR 
		ON 	bk_senior.bk_senior.R034FUN.codcar = bk_senior.bk_senior.R024CAR.CodCar
		AND	bk_senior.bk_senior.R024CAR.EstCar = 1
 WHERE 
	Tipcal IN(11) AND Sitcal = 'T'

	AND (bk_senior.bk_senior.R046VER.CodEve IN #PROVENTOS#
		 OR bk_senior.bk_senior.R046VER.CodEve IN #DESCONTOS#
		 OR bk_senior.bk_senior.R046VER.CodEve IN #PLR#
		 OR bk_senior.bk_senior.R046VER.CodEve IN #VTPROV#
		 OR bk_senior.bk_senior.R046VER.CodEve IN #VTVER#
		 OR bk_senior.bk_senior.R046VER.CodEve IN #VRVAV#
		 OR bk_senior.bk_senior.R046VER.CodEve IN #ASSMP#
		 OR bk_senior.bk_senior.R046VER.CodEve IN #ASSMV#
		 OR bk_senior.bk_senior.R046VER.CodEve IN #SINOP#
		 OR bk_senior.bk_senior.R046VER.CodEve IN #SINOV#
		 OR bk_senior.bk_senior.R046VER.CodEve IN #SEMINC#)

    --AND bk_senior.bk_senior.R046VER.NumEmp='01' and 
    --AND PerRef ='20220501'
    --BKIntegraRubi.dbo.CUSTOSIGA.ccSiga = '358000567'

	---AND SUBSTRING(BKIntegraRubi.dbo.CUSTOSIGA.ccSiga,1,3) = '000'
	)
	SELECT 
	EMPRESAS.NOMEEMP AS NOMEEMP,
	FOLHA.*,
	CCUSTOS.DESCRCC AS DESCRICAO,
	(PROVENTOS + DESCONTOS) * PENCARGOS / 100 AS ENCARGOS,
	(PROVENTOS + DESCONTOS) * PINCIDENCIAS / 100 AS INCIDENCIAS,
	((PROVENTOS + DESCONTOS) * PENCARGOS / 100  + 
	 (PROVENTOS + DESCONTOS) * PINCIDENCIAS / 100 + 
	 PLR + 
	 VTPROV +
	 VTVER  +
	 VRVAV +
	 ASSMP +
	 ASSMV +
	 SINOP +
	 SINOV +
	 SEMINC ) AS CUSTO,

	(PROVENTOS + 
	 DESCONTOS+ 
	 PLR + 
	 VTPROV +
	 VTVER  +
	 VRVAV +
	 ASSMP +
	 ASSMV +
	 SINOP +
	 SINOV +
	 SEMINC ) AS CUSTOSE,

     (SELECT TOP 1 ZGCHAVE FROM 
		(SELECT MAX(COMPETAM+ZG_SEQ) AS ZGCHAVE
		FROM PowerBk.dbo.PREVDESP1 
		WHERE PREVDESP1.EMPRESA = FOLHA.EMPRESA
		    AND PREVDESP1.CONTRATO = FOLHA.CONTRATO
		    AND PREVDESP1.COMPETAM <= FOLHA.COMPETAM
		GROUP BY PREVDESP1.CONTRATO,PREVDESP1.ZG_DATA
		) AS X
		ORDER BY ZGCHAVE DESC) AS CHAVEZG

	INTO PowerBk.dbo.FOLHA
	FROM FOLHA 
	LEFT JOIN PowerBk.dbo.EMPRESAS ON FOLHA.EMPRESA = EMPRESAS.EMPRESA COLLATE Latin1_General_BIN
	LEFT JOIN PowerBk.dbo.CCUSTOS  ON FOLHA.EMPRESA = CCUSTOS.EMPRESA AND FOLHA.CONTRATO = CCUSTOS.CCUSTO COLLATE Latin1_General_BIN
	WHERE SUBSTRING(FOLHA.CONTRATO,1,3) <> '000'
ENDCONTENT

cQuery := STRTRAN(cQuery,"#PROVENTOS#",U_FBkVars(U_MVXPROVE()))
cQuery := STRTRAN(cQuery,"#DESCONTOS#",U_FBkVars(U_MVXDESCO()))
cQuery := STRTRAN(cQuery,"#PLR#",U_FBkVars(U_MVXPLR()))
cQuery := STRTRAN(cQuery,"#VTPROV#",U_FBkVars(U_MVXVTPRO()))
cQuery := STRTRAN(cQuery,"#VTVER#",U_FBkVars(U_MVXVTVER()))
cQuery := STRTRAN(cQuery,"#VRVAV#",U_FBkVars(U_MVXVRVAV()))
cQuery := STRTRAN(cQuery,"#ASSMP#",U_FBkVars(U_MVXASSMP()))
cQuery := STRTRAN(cQuery,"#ASSMV#",U_FBkVars(U_MVXASSMV()))
cQuery := STRTRAN(cQuery,"#SINOP#",U_FBkVars(U_MVXSINOP()))
cQuery := STRTRAN(cQuery,"#SINOV#",U_FBkVars(U_MVXSINOV()))
cQuery := STRTRAN(cQuery,"#SEMINC#",U_FBkVars(U_MVXNINCI()))
cQuery := STRTRAN(cQuery,"#FURNAS#",U_FBkVars(U_MVYFURNAS()))

u_LogMemo("BKDSFOL.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.FOLHA', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.FOLHA "+CRLF
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
