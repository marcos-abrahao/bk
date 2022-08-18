#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BKDASH01
BK - Faturamento por contrato

@Return
@author Marcos Bispo Abrahão
@since 28/08/2020
@version P12.1.25


Faltam:

Tabela Geral: folha, calculo de resultado, % rentabilidade
Tabela Folha: tudo
Tabela GastosGerais: Categorias de produtos
Tabela Previsoesdecustos: 

Ok:
Tabela Previsoesdegastos: Ok
Tabela Faturamento: Faturamento Liquido


/*/

User Function BKDASH01()

Private cTitulo     := "Atualizar Dashboard PowerBk"
Private cPerg       := "BKDASH01"

If FWCodEmp() == "01"

	u_LogPrw(cPerg,"Inicio")

	If IsBlind()
		//If (DOW(DATE()) = 7 .OR. DOW(DATE()) = 4) .AND. SUBSTRING(TIME(),1,2) = '06'
		If SUBSTRING(TIME(),1,2) > '05' ;
				.AND. SUBSTRING(TIME(),1,2) < '21';
			 	.AND. DOW(DATE()) <> 7;
			 	.AND. DOW(DATE()) <> 1

			If SUBSTRING(TIME(),1,2) = '06'
				ProcDSDP1()
				ProcDSDP2()
				ProcDSEMP()
				ProcDSCC()
				ProcDSFOL()
				ProcDSUSR()
			EndIf

			ProcDSFAT()
			ProcDSGES()
			ProcDSGLO()
			If SUBSTRING(TIME(),1,2) $ '06/10/12/16/18/20'
				ProcDSGG()
			EndIf
			//ProcDSGLF()
			ProcDSGER()
		EndIf
	Else
		If MsgYesNo("Confirma a atualização da tabela PREVDESP1 do banco de dados PowerBk?", cPerg)
			FWMsgRun(, {|oSay| ProcDSDP1() }, "", "Atualizando a tabela PREVDESP1 do banco de dados PowerBk...")
		EndIf
		If MsgYesNo("Confirma a atualização da tabela PREVDESP2 do banco de dados PowerBk?", cPerg)
			FWMsgRun(, {|oSay| ProcDSDP2() }, "", "Atualizando a tabela PREVDESP2 do banco de dados PowerBk...")
		EndIf
		If MsgYesNo("Confirma a atualização da tabela EMPRESAS do banco de dados PowerBk?", cPerg)
			FWMsgRun(, {|oSay| ProcDSEMP() }, "", "Atualizando a tabela EMPRESAS do banco de dados PowerBk...")
		EndIf
		If MsgYesNo("Confirma a atualização da tabela CCUSTOS do banco de dados PowerBk?", cPerg)
			FWMsgRun(, {|oSay| ProcDSCC() }, "", "Atualizando a tabela CCUSTOS do banco de dados PowerBk...")
		EndIf
		If MsgYesNo("Confirma a atualização da tabela FOLHA do banco de dados PowerBk?", cPerg)
			FWMsgRun(, {|oSay| ProcDSFOL() }, "", "Atualizando a tabela FOLHA do banco de dados PowerBk...")
		EndIf
		If MsgYesNo("Confirma a atualização da tabela USUARIOS do banco de dados PowerBk?", cPerg)
			FWMsgRun(, {|oSay| ProcDSUSR() }, "", "Atualizando a tabela USUARIOS do banco de dados PowerBk...")
		EndIf
		If MsgYesNo("Confirma a atualização da tabela FATURAMENTO do banco de dados PowerBk?", cPerg)
			FWMsgRun(, {|oSay| ProcDSFAT() }, "", "Atualizando a tabela FATURAMENTO do banco de dados PowerBk...")
		EndIf
		If MsgYesNo("Confirma a atualização da tabela GESTORES do banco de dados PowerBk?", cPerg)
			FWMsgRun(, {|oSay| ProcDSGES() }, "", "Atualizando a tabela GESTORES do banco de dados PowerBk...")
		EndIf
		If MsgYesNo("Confirma a atualização da tabela GLOSAS do banco de dados PowerBk?", cPerg)
			FWMsgRun(, {|oSay| ProcDSGLO() }, "", "Atualizando a tabela GLOSAS do banco de dados PowerBk...")
		EndIf
		If MsgYesNo("Confirma a atualização da tabela GASTOSGERAIS do banco de dados PowerBk?", cPerg)
			FWMsgRun(, {|oSay| ProcDSGG() }, "", "Atualizando a tabela GASTOSGERAIS do banco de dados PowerBk...")
		EndIf
		//If MsgYesNo("Confirma a atualização da tabela GASTOSLIQFOL do banco de dados PowerBk?", cPerg)
		//	FWMsgRun(, {|oSay| ProcDSGLF() }, "", "Atualizando a tabela GASTOSLIQFOL do banco de dados PowerBk...")
		//EndIf
		If MsgYesNo("Confirma a atualização da tabela GERAL do banco de dados PowerBk?", cPerg)
			FWMsgRun(, {|oSay| ProcDSGER() }, "", "Atualizando a tabela GERAL do banco de dados PowerBk...")
		EndIf
	EndIf

	u_LogPrw(cPerg,"Final")

Else
	If !IsBlind()
		MsgStop("Rodar apenas na empresa 01-BK", cPerg)
	EndIf
EndiF

Return


// Atualização da tabela FOLHA do banco de dados PowerBk
Static Function ProcDSFOL
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""

u_LogPrw(cPerg,"Folha")

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
		  ELSE SUBSTRING(BKIntegraRubi.dbo.CUSTOSIGA.ccSiga,1,9) END) COLLATE Latin1_General_BIN AS CONTRATO,

	SUBSTRING(CONVERT(VARCHAR,PerRef,112),1,6) COLLATE Latin1_General_BIN AS COMPETAM,
	SUBSTRING(REPLACE(STR(bk_senior.bk_senior.R046VER.NumEmp,2),' ','0'),1,2) + 
       (CASE WHEN bk_senior.bk_senior.R046VER.NumEmp = 14 AND 
			  	  SUBSTRING(BKIntegraRubi.dbo.CUSTOSIGA.ccSiga,1,3) IN ('000','Er:') THEN '302000508'
             WHEN bk_senior.bk_senior.R046VER.NumEmp = 15 AND 
		          SUBSTRING(BKIntegraRubi.dbo.CUSTOSIGA.ccSiga,1,3) IN ('000','Er:') THEN '305000554'
		     ELSE BKIntegraRubi.dbo.CUSTOSIGA.ccSiga END) +
	    SUBSTRING(CONVERT(VARCHAR,PerRef,112),1,6) COLLATE Latin1_General_BIN AS CHAVE,
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
	  WHERE [BKIntegraRubi].[dbo].[EVENTOS_ASS_ODONT].NumEmpr = '01' AND 
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

u_LogMemo("BKDASH01-FOL.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.FOLHA', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.FOLHA "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro1, cPerg)
	EndIf
EndIf

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro2, cPerg)
	EndIf
EndIf

u_LogMemo("BKDASH01-FOL.SQL",cErro1+cQueryD+cErro2+cQuery)

Return





// Atualização da tabela FATURAMENTO do banco de dados PowerBk
Static Function ProcDSFAT
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0
Local cEmpresa  := ""
Local cNomeEmp  := ""

Local cTabSZR   := ""
Local cTabCNR   := ""
Local cTabSF2   := ""
Local cTabSC5   := ""
Local cTabCXN   := ""
Local cTabCND   := ""
Local cTabCTT   := ""
Local cTabCN9   := ""
Local cTabCNF   := ""
Local cTabCNA   := ""
Local cTabSE5   := ""
Local cTabSE1   := ""

u_LogPrw(cPerg,"Faturamento")

cTabSZR := "SZR010"

cQuery := "WITH FATUR AS ("
For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabCNR := "CNR"+cEmpresa+"0"
	cTabSF2 := "SF2"+cEmpresa+"0"
	cTabSC5 := "SC5"+cEmpresa+"0"
	cTabCXN := "CXN"+cEmpresa+"0"
	cTabCND := "CND"+cEmpresa+"0"
	cTabCTT := "CTT"+cEmpresa+"0"
	cTabCN9 := "CN9"+cEmpresa+"0"
	cTabCNF := "CNF"+cEmpresa+"0"
	cTabCNA := "CNA"+cEmpresa+"0"
	cTabSE5 := "SE5"+cEmpresa+"0"
	cTabSE1 := "SE1"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += "SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF

	cQuery += "  SUBSTRING(ISNULL(CND_CONTRA, ISNULL(C5_ESPECI1,'000000001')),1,9) AS CONTRATO, " + CRLF
	cQuery += "  ISNULL(CTT_DESC01,'BK CONSULTORIA') AS DESCRICAO, " + CRLF
	cQuery += "  ISNULL(C5_XXCOMPM,SUBSTRING(F2_EMISSAO,5,2)+'/'+SUBSTRING(F2_EMISSAO,1,4)) AS COMPET, " + CRLF
	cQuery += "  ISNULL(SUBSTRING(C5_XXCOMPM,4,4)+SUBSTRING(C5_XXCOMPM,1,2),SUBSTRING(F2_EMISSAO,1,6)) AS COMPETAM, " + CRLF
	cQuery += "  CONVERT(DATE,ISNULL(SUBSTRING(C5_XXCOMPM,4,4)+SUBSTRING(C5_XXCOMPM,1,2),SUBSTRING(F2_EMISSAO,1,6))+'01',112) AS COMPETD, " + CRLF

	// Chave
	cQuery += "  '"+cEmpresa+"' + "+CRLF
	cQuery += "     SUBSTRING(ISNULL(CND_CONTRA, ISNULL(C5_ESPECI1,'000000001')),1,9) +  " + CRLF
	cQuery += "     ISNULL(SUBSTRING(C5_XXCOMPM,4,4)+SUBSTRING(C5_XXCOMPM,1,2),SUBSTRING(F2_EMISSAO,1,6)) AS CHAVE, " + CRLF

	cQuery += "  C5_NUM, " + CRLF
	cQuery += "  C5_MDNUMED, " + CRLF
	cQuery += "  C5_MDPLANI, " + CRLF
	cQuery += "  F2_SERIE, " + CRLF
	cQuery += "  F2_DOC, " + CRLF
	cQuery += "  CONVERT(DATE,F2_EMISSAO,112) AS F2_EMISSAO, " + CRLF
	cQuery += "  F2_VALFAT, " + CRLF
	// Fernando 01/08/22 - O ISS Retido e Apurado precisam entrar dentro da conta de faturamento líquido e a retenção e conta vinculada precisam sair
	//cQuery += "  (F2_VALFAT - F2_VALIRRF - F2_VALINSS - F2_VALPIS - F2_VALCOFI - F2_VALCSLL - (CASE WHEN F2_RECISS = '1' THEN F2_VALISS ELSE 0 END) - F2_VLCPM - F2_XXVRETC - F2_XXVCVIN) AS F2VALLIQ1, " + CRLF
	//cQuery += "  (F2_VALFAT - F2_VALIRRF - F2_VALINSS - F2_VALPIS - F2_VALCOFI - F2_VALCSLL - F2_VALISS - F2_VLCPM) AS F2VALLIQ1, " + CRLF

	cQuery += "  F2_VALISS, " + CRLF
	cQuery += "  F2_VLCPM, " + CRLF

	If cEmpresa = '02'
		cQuery += "  16.98 AS PERIMP," + CRLF
		cQuery += "  (F2_VALFAT * 16.98 / 100) AS VALIMP," + CRLF
	    cQuery += "  (F2_VALFAT - (F2_VALFAT * 16.98 / 100) - F2_VALISS - F2_VLCPM) AS F2VALLIQ1, " + CRLF
	Else
		cQuery += "  9.5 AS PERIMP," + CRLF
		cQuery += "  (F2_VALFAT * 9.5 / 100) AS VALIMP," + CRLF
	    cQuery += "  (F2_VALFAT - (F2_VALFAT * 9.5 / 100) - F2_VALISS - F2_VLCPM) AS F2VALLIQ1, " + CRLF
	EndIf

	cQuery += "  CND_USUAR, " + CRLF
	cQuery += "  (" + CRLF
	cQuery += "    CASE WHEN CND_NUMERO = '' THEN 'NOVA' ELSE 'ANTIGA' END" + CRLF
	cQuery += "  ) AS FORMAMED, " + CRLF
	cQuery += "  CNA_XXMUN  AS CNA_XXMUN,"+ CRLF	
	//cQuery += "  ISNULL(CXN_VLPREV, CND_VLPREV) AS CXN_VLPREV, " + CRLF
	cQuery += "  CASE WHEN ISNULL(CXN_VLPREV, CND_VLPREV) = CNF_VLPREV THEN CNF_VLPREV ELSE 0 END AS CXN_VLPREV,"+ CRLF
	//cQuery += "  ISNULL(CXN_VLBONI, CND_VLBONI) AS CXN_VLBONI, " + CRLF
	//cQuery += "  ISNULL(CXN_VLMULT, CND_VLMULT) AS CXN_VLMULT, " + CRLF

	// Movimento Financeiro (multas e descontos)
	cQuery += "   (SELECT SUM(E5_VALOR) FROM "+cTabSE5+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC = 'DC' AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " + CRLF
	cQuery += "   	AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5DESC," + CRLF
	cQuery += "   (SELECT SUM(E5_VALOR) FROM "+cTabSE5+" SE5 WHERE E5_PREFIXO = F2_SERIE AND E5_NUMERO = F2_DOC  AND E5_TIPO = 'NF' AND  E5_CLIFOR = F2_CLIENTE AND E5_LOJA = F2_LOJA AND E5_TIPODOC IN ('MT','JR','CM') AND E5_RECPAG = 'R' AND E5_SITUACA <> 'C' AND E5_DTCANBX = '' " + CRLF
	cQuery += "   	AND SE5.D_E_L_E_T_ = ' ' AND E5_FILIAL = '"+xFilial("SE5")+"') AS XX_E5MULTA," + CRLF
	cQuery += "   (SELECT TOP 1 E1_XXISSBI FROM "+cTabSE1+" SE1 WHERE E1_PREFIXO = F2_SERIE AND E1_NUM = F2_DOC AND E1_TIPO = 'NF'"+ CRLF
	cQuery += "   	  AND SE1.D_E_L_E_T_ = ' ' AND E1_FILIAL = '"   + xFilial("SE1")+"') AS E1_XXISSBI, " + CRLF

	cQuery += "   (SELECT SUM(CNR_VALOR)"+ CRLF
	cQuery += "        FROM "+cTabCNR+" CNR " + CRLF
	cQuery += "        WHERE "+ CRLF
	cQuery += "          C5_MDNUMED = CNR.CNR_NUMMED "+ CRLF
	cQuery += "          AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))"+ CRLF
	cQuery += "          AND CNR_FILIAL = '01'"+ CRLF
	cQuery += "          AND CNR.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += "          AND CNR_TIPO = '2' ) AS CNRVLBONI,"+ CRLF

	cQuery += "   (SELECT SUM(CNR_VALOR)"+ CRLF
	cQuery += "        FROM "+cTabCNR+" CNR " + CRLF
	cQuery += "        WHERE "+ CRLF
	cQuery += "          C5_MDNUMED = CNR.CNR_NUMMED "+ CRLF
	cQuery += "          AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))"+ CRLF
	cQuery += "          AND CNR_FILIAL = '01'"+ CRLF
	cQuery += "          AND CNR.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += "          AND CNR_TIPO = '1' ) AS CNRVLMULT,"+ CRLF

	cQuery += "  STUFF (" + CRLF
	cQuery += "    (" + CRLF
	cQuery += "      SELECT " + CRLF
	cQuery += "        ';' + RTRIM(CNR_XTPJUS + '-' + ZR_DESCR) " + CRLF
	cQuery += "      FROM " + CRLF
	cQuery += "        "+cTabCNR+" CNR " + CRLF
	cQuery += "        INNER JOIN "+cTabSZR+" SZR ON ZR_TIPO = CNR_XTPJUS " + CRLF
	cQuery += "      WHERE " + CRLF
	cQuery += "        C5_MDNUMED = CNR.CNR_NUMMED " + CRLF
	cQuery += "        AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))" + CRLF
	cQuery += "        AND CNR_FILIAL = CND_FILIAL" + CRLF
	cQuery += "        AND CNR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "        AND CNR_TIPO = '1' " + CRLF
	cQuery += "      ORDER BY " + CRLF
	cQuery += "        ';' + RTRIM(CNR_XTPJUS + '-' + ZR_DESCR) FOR XML PATH (''), " + CRLF
	cQuery += "        TYPE" + CRLF
	cQuery += "    ).value('.', 'varchar(100)'), " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    ''" + CRLF
	cQuery += "  ) AS CNRTPMUL, " + CRLF
	cQuery += "  STUFF (" + CRLF
	cQuery += "    (" + CRLF
	cQuery += "      SELECT " + CRLF
	cQuery += "        ';' + RTRIM(CNR_DESCRI) " + CRLF
	cQuery += "      FROM " + CRLF
	cQuery += "        "+cTabCNR+" CNR " + CRLF
	cQuery += "      WHERE " + CRLF
	cQuery += "        C5_MDNUMED = CNR.CNR_NUMMED " + CRLF
	cQuery += "        AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))" + CRLF
	cQuery += "        AND CNR_FILIAL = CND_FILIAL" + CRLF
	cQuery += "        AND CNR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "        AND CNR_TIPO = '1' " + CRLF
	cQuery += "      ORDER BY " + CRLF
	cQuery += "        ';' + RTRIM(CNR_DESCRI) FOR XML PATH (''), " + CRLF
	cQuery += "        TYPE" + CRLF
	cQuery += "    ).value('.', 'varchar(100)'), " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    ''" + CRLF
	cQuery += "  ) AS CNRDESCMUL, " + CRLF
	cQuery += "  STUFF (" + CRLF
	cQuery += "    (" + CRLF
	cQuery += "      SELECT " + CRLF
	cQuery += "        ';' + RTRIM(CNR_XTPJUS + '-' + ZR_DESCR) " + CRLF
	cQuery += "      FROM " + CRLF
	cQuery += "        "+cTabCNR+" CNR " + CRLF
	cQuery += "        INNER JOIN "+cTabSZR+" SZR ON ZR_TIPO = CNR_XTPJUS " + CRLF
	cQuery += "      WHERE " + CRLF
	cQuery += "        C5_MDNUMED = CNR.CNR_NUMMED " + CRLF
	cQuery += "        AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))" + CRLF
	cQuery += "        AND CNR_FILIAL = CND_FILIAL" + CRLF
	cQuery += "        AND CNR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "        AND CNR_TIPO = '2' " + CRLF
	cQuery += "      ORDER BY " + CRLF
	cQuery += "        ';' + RTRIM(CNR_XTPJUS + '-' + ZR_DESCR) FOR XML PATH (''), " + CRLF
	cQuery += "        TYPE" + CRLF
	cQuery += "    ).value('.', 'varchar(100)'), " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    ''" + CRLF
	cQuery += "  ) AS CNRTPBON, " + CRLF
	cQuery += "  STUFF (" + CRLF
	cQuery += "    (" + CRLF
	cQuery += "      SELECT " + CRLF
	cQuery += "        ';' + RTRIM(CNR_DESCRI) " + CRLF
	cQuery += "      FROM " + CRLF
	cQuery += "        "+cTabCNR+" CNR " + CRLF
	cQuery += "      WHERE " + CRLF
	cQuery += "        C5_MDNUMED = CNR.CNR_NUMMED " + CRLF
	cQuery += "        AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))" + CRLF
	cQuery += "        AND CNR_FILIAL = CND_FILIAL" + CRLF
	cQuery += "        AND CNR.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "        AND CNR_TIPO = '2' " + CRLF
	cQuery += "      ORDER BY " + CRLF
	cQuery += "        ';' + RTRIM(CNR_DESCRI) FOR XML PATH (''), " + CRLF
	cQuery += "        TYPE" + CRLF
	cQuery += "    ).value('.', 'varchar(100)'), " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    1, " + CRLF
	cQuery += "    ''" + CRLF
	cQuery += "  ) AS CNRDESCBON, "+CRLF

	// Gravar a chave das Previsões
	cQuery += "	(SELECT TOP 1 ZGCHAVE FROM "+CRLF
	cQuery += "		(SELECT MAX(COMPETAM+ZG_SEQ) AS ZGCHAVE"+CRLF
	cQuery += "		FROM PowerBk.dbo.PREVDESP1 "+CRLF
	cQuery += "		WHERE PREVDESP1.EMPRESA = '"+cEmpresa+"'"+CRLF
	cQuery += "		    AND PREVDESP1.CONTRATO = SUBSTRING(ISNULL(CND_CONTRA, ISNULL(C5_ESPECI1,'000000001')),1,9)"+CRLF
	cQuery += "		    AND PREVDESP1.COMPETAM <= SUBSTRING(C5_XXCOMPM,4,4)+SUBSTRING(C5_XXCOMPM,1,2)"+CRLF
	cQuery += "		GROUP BY PREVDESP1.CONTRATO,PREVDESP1.ZG_DATA"+CRLF
	cQuery += "		) AS X"+CRLF
	cQuery += "		ORDER BY ZGCHAVE DESC) AS CHAVEZG"+CRLF
	// --
	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabSF2+" SF2 " + CRLF

	cQuery += " LEFT JOIN "+cTabSC5+" SC5" + CRLF
	cQuery += "     ON (C5_NOTA = F2_DOC " + CRLF
	cQuery += "         AND C5_SERIE = F2_SERIE " + CRLF
	cQuery += "         AND C5_FILIAL = F2_FILIAL " + CRLF
	cQuery += "         AND SC5.D_E_L_E_T_ = ''" + CRLF
	cQuery += " ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCND+" CND" + CRLF
	cQuery += "     ON (CND_NUMMED = C5_MDNUMED " + CRLF
	//cQuery += "         AND CND_REVISA = CND_REVGER " + CRLF
	cQuery += "         AND CND_FILIAL = '01' " + CRLF
	cQuery += "         AND CND.D_E_L_E_T_ = '' " + CRLF
	cQuery += "         AND CND.R_E_C_N_O_ = (" + CRLF
	cQuery += "         SELECT " + CRLF
	cQuery += "            MIN(R_E_C_N_O_) " + CRLF
	cQuery += "         FROM " + CRLF
	cQuery += "            "+cTabCND+" CND1 " + CRLF
	cQuery += "         WHERE " + CRLF
	cQuery += "            CND1.CND_NUMMED = C5_MDNUMED " + CRLF
	cQuery += "            AND CND1.CND_FILIAL = '01' " + CRLF
	cQuery += "            AND CND1.D_E_L_E_T_ = ''" + CRLF
	cQuery += "    )" + CRLF
	
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCXN+" CXN" + CRLF
	cQuery += "     ON (CXN_CONTRA = C5_MDCONTR " + CRLF
	cQuery += "         AND CXN_NUMMED = C5_MDNUMED " + CRLF
	cQuery += "         AND CXN_NUMPLA = C5_MDPLANI " + CRLF
	cQuery += "         AND CXN_REVISA = CND_REVISA " + CRLF
	cQuery += "         AND CXN.CXN_CHECK = 'T' " + CRLF
	cQuery += "         AND CXN_FILIAL = F2_FILIAL " + CRLF
	cQuery += "         AND CXN.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCNF+" CNF" + CRLF
	cQuery += " 	ON (CND_CONTRA = CNF_CONTRA AND C5_XXCOMPM = CNF_COMPET" + CRLF
	cQuery += " 	    AND ISNULL(CXN_NUMPLA,CND_NUMERO) = CNF_NUMPLA" + CRLF
	cQuery += " 	    AND ISNULL(CXN_REVISA,CND_REVISA) = CNF_REVISA" + CRLF
	cQuery += " 	    AND CNF_PARCEL = ISNULL(CXN_PARCEL,CND_PARCEL)" + CRLF
	cQuery += " 	 	AND CNF_FILIAL = F2_FILIAL AND CNF.D_E_L_E_T_=''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCNA+" CNA" + CRLF
	cQuery += " 	ON (CNA_CONTRA = CNF_CONTRA" + CRLF
	cQuery += " 	 	AND CNA_CRONOG = CNF_NUMERO" + CRLF
	cQuery += " 	 	AND CNA_REVISA = CNF_REVISA" + CRLF
	cQuery += " 	 	AND CNA_NUMERO = CNF_NUMPLA" +CRLF
	cQuery += " 		AND CNA_FILIAL = CNF_FILIAL AND CNA.D_E_L_E_T_=''"+CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON (ISNULL(CND_CONTRA, C5_ESPECI1) = CTT_CUSTO " + CRLF
	cQuery += " 		AND CTT_FILIAL = '"+xFilial("CTT")+"'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "WHERE " + CRLF
	cQuery += "  SF2.D_E_L_E_T_ = '' " + CRLF

	cQuery += "UNION ALL " + CRLF

	cQuery += "SELECT " + CRLF
	cQuery += "  DISTINCT " + CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF

	cQuery += "  SUBSTRING(CNF_CONTRA,1,9) AS CONTRATO, " + CRLF
	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
	cQuery += "  CNF_COMPET AS COMPET, " + CRLF
	cQuery += "  SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2) AS COMPETAM, " + CRLF
	cQuery += "  CONVERT(DATE,SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2)+'01',112) AS COMPETD, " + CRLF

	// Chave
	cQuery += "  '"+cEmpresa+"' + "+CRLF
	cQuery += "     SUBSTRING(CNF_CONTRA,1,9) +  " + CRLF
	cQuery += "     SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2) AS CHAVE, " + CRLF

	cQuery += "  ' ' 		AS C5_NUM, " + CRLF
	cQuery += "  ' ' 		AS C5_MDNUMED, " + CRLF
	cQuery += "  CNF_NUMPLA AS C5_MDPLANI, " + CRLF
	cQuery += "  ' ' 		AS F2_SERIE, " + CRLF
	cQuery += "  'PREVISTO' AS F2_DOC, " + CRLF
	cQuery += "  CONVERT(DATE,CONVERT(VARCHAR,''),112) AS F2_EMISSAO, " + CRLF
	cQuery += "  0 			AS F2_VALFAT, " + CRLF

	cQuery += "  0 			AS F2_VALISS, " + CRLF
	cQuery += "  0 			AS F2_VLCPM, " + CRLF

	If cEmpresa = '02'
		cQuery += "  16.98 	AS PERIMP," + CRLF
		cQuery += "  0 		AS VALIMP," + CRLF
	    cQuery += "  0 		AS F2VALLIQ1, " + CRLF
	Else
		cQuery += "  9.5 	AS PERIMP," + CRLF
		cQuery += "  0 		AS VALIMP," + CRLF
	    cQuery += "  0 		AS F2VALLIQ1, " + CRLF
	EndIf

	cQuery += "  ' ' 		AS CND_USUAR, " + CRLF
	cQuery += "  ' ' 		AS FORMAMED, " + CRLF
	cQuery += "  CNA_XXMUN  AS CNA_XXMUN,"+ CRLF	
	cQuery += "  CNF_VLPREV AS CXN_VLPREV, " + CRLF
	cQuery += "  0 			AS XX_E5DESC, " + CRLF
	cQuery += "  0 			AS XX_E5MULTA, " + CRLF
	cQuery += "  0 			AS E1_XXISSBI, " + CRLF
	cQuery += "  0 			AS CNRVLBONI, " + CRLF
	cQuery += "  0 			AS CNRVLMULT, " + CRLF
	cQuery += "  ' ' 		AS CNRTPMUL, " + CRLF
	cQuery += "  ' ' 		AS CNRDESCMUL, " + CRLF
	cQuery += "  ' ' 		AS CNRTPBON, " + CRLF
	cQuery += "  ' ' 		AS CNRDESCBON, " + CRLF

	// Gravar a chave das Previsões
	cQuery += "	(SELECT TOP 1 ZGCHAVE FROM "+CRLF
	cQuery += "		(SELECT MAX(COMPETAM+ZG_SEQ) AS ZGCHAVE"+CRLF
	cQuery += "		FROM PowerBk.dbo.PREVDESP1 "+CRLF
	cQuery += "		WHERE PREVDESP1.EMPRESA = '"+cEmpresa+"'"+CRLF
	cQuery += "		    AND PREVDESP1.CONTRATO = SUBSTRING(CNF_CONTRA,1,9)"+CRLF
	cQuery += "		    AND PREVDESP1.COMPETAM <= SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2)"+CRLF
	cQuery += "		GROUP BY PREVDESP1.CONTRATO,PREVDESP1.ZG_DATA"+CRLF
	cQuery += "		) AS X"+CRLF
	cQuery += "		ORDER BY ZGCHAVE DESC) AS CHAVEZG"+CRLF

	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabCNF+" CNF " + CRLF

	cQuery += " INNER JOIN "+cTabCN9+" CN9" + CRLF
	cQuery += "     ON CN9_NUMERO = CNF_CONTRA " + CRLF
	cQuery += "     AND CN9_REVISA = CNF_REVISA " + CRLF
	cQuery += "     AND CN9_REVATU = ' ' " + CRLF
	cQuery += "     AND CN9_FILIAL = '01' " + CRLF
	cQuery += "     AND CN9.D_E_L_E_T_ = ' ' " + CRLF

	cQuery += " LEFT JOIN "+cTabCNA+" CNA" + CRLF
	cQuery += " 	ON (CNA_CONTRA = CNF_CONTRA" + CRLF
	cQuery += " 	AND CNA_CRONOG = CNF_NUMERO" + CRLF
	cQuery += " 	AND CNA_REVISA = CNF_REVISA" + CRLF
	cQuery += " 	AND CNA_NUMERO = CNF_NUMPLA" +CRLF
	cQuery += " 		AND CNA_FILIAL = CNF_FILIAL AND CNA.D_E_L_E_T_='')"+CRLF

	cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON CTT_CUSTO = CNF_CONTRA" + CRLF
	cQuery += " 	AND CTT_FILIAL = '"+xFilial("CTT")+"'" + CRLF
	cQuery += "     AND CTT.D_E_L_E_T_ = ' ' " + CRLF

	cQuery += "WHERE " + CRLF
	cQuery += "     CNF_SALDO = CNF_VLPREV " + CRLF
	cQuery += "     AND CNF_FILIAL = '01' " + CRLF
	cQuery += "     AND CNF.D_E_L_E_T_ = ' ' " + CRLF
Next

cQuery += ")"  + CRLF
cQuery += " SELECT *," + CRLF
//cQuery += " F2VALLIQ1 - ISNULL(XX_E5DESC,0) + ISNULL(XX_E5MULTA,0) - E1_XXISSBI AS F2VALLIQ" + CRLF

cQuery += " CASE WHEN CONTRATO = '305000554' " + CRLF
cQuery += "      THEN (F2VALLIQ1 - ISNULL(XX_E5DESC,0) + ISNULL(XX_E5MULTA,0) - E1_XXISSBI) * 2 " + CRLF
cQuery += "      ELSE (F2VALLIQ1 - ISNULL(XX_E5DESC,0) + ISNULL(XX_E5MULTA,0) - E1_XXISSBI) END AS F2VALLIQ," + CRLF
cQuery += " CASE WHEN CONTRATO = '305000554' " + CRLF
cQuery += "      THEN (F2_VALFAT * 2) " + CRLF
cQuery += "      ELSE (F2_VALFAT) END AS VALFAT" + CRLF

cQuery += " INTO PowerBk.dbo.FATURAMENTO " + CRLF
cQuery += " FROM FATUR " + CRLF
cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,CONTRATO,COMPETAM,F2_DOC" + CRLF

//u_LogMemo("BKDASH01.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

//Begin Transaction

	cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.FATURAMENTO', N'U') IS NOT NULL"  
 	cQueryD += "   DROP TABLE PowerBk.dbo.FATURAMENTO "+CRLF
	nErro   := TcSqlExec(cQueryD)

	If nErro != 0
		cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		If !IsBlind()
			MsgStop(cErro1, cPerg)
		EndIf
	EndIf

	nErro   := TcSqlExec(cQuery)

	If nErro != 0
		cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		If !IsBlind()
			MsgStop(cErro2, cPerg)
		EndIf
	EndIf


//End Transaction

u_LogMemo("BKDASH01-FAT.SQL",cErro1+cQueryD+cErro2+cQuery)

Return


// Atualização da tabela CCUSTOS do banco de dados PowerBk
Static Function ProcDSCC
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrupo()
Local nE 		:= 0
Local cTabCTT   := ""

u_LogPrw(cPerg,"Centros de Custo")
 
cQuery := "WITH CCUSTOS AS ( " + CRLF

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabCTT := "CTT"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT"+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC, " + CRLF
	cQuery += "  SUBSTRING(CTT_CUSTO,1,9) AS CCUSTO,"+CRLF
	cQuery += "  CTT_DESC01 AS DESCRCC"+CRLF
	cQuery += " FROM " + CRLF
	cQuery += "  "+cTabCTT+" CTT " + CRLF
	cQuery += " WHERE CTT.D_E_L_E_T_=''" + CRLF
Next

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  * " + CRLF
cQuery += "  INTO PowerBk.dbo.CCUSTOS" + CRLF
cQuery += "  FROM CCUSTOS " + CRLF
cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,CCUSTO" + CRLF

u_LogMemo("BKDASH01-CC.SQL",cQuery)

If !TCIsConnected()
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.CCUSTOS', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.CCUSTOS "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro1, cPerg)
	EndIf
EndIf

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro2, cPerg)
	EndIf
EndIf

u_LogMemo("BKDASH01-CC.SQL",cErro1+cQueryD+cErro2+cQuery)

Return




// Atualização da tabela GESTORES do banco de dados PowerBk
Static Function ProcDSGES
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0

Local cTabCN9   := ""
Local cTabCNF   := ""

u_LogPrw(cPerg,"Gestores")
 
cQuery := "WITH VIG AS ( " + CRLF

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabCN9 := "CN9"+cEmpresa+"0"
	cTabCNF := "CNF"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT"+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  SUBSTRING(CN9_NUMERO,1,9) AS CONTRATO,"+CRLF
	cQuery += "  CN9_SITUAC,"+CRLF
	cQuery += "  CN9_GESTC, "+CRLF
    cQuery += "  CN9_XXNRBK, "+CRLF
	cQuery += "  MIN(CN9_DTOSER) AS CN9DTOSER,"+CRLF
	cQuery += "  MIN(CN9_DTINIC) AS CN9DTINIC,"+CRLF
	cQuery += "  MIN(CNF_DTVENC) AS CNFINICIO,"+CRLF
	cQuery += "  MAX(CNF_DTVENC) AS CNFFIM,"+CRLF
	cQuery += "  CN9_XXDVIG,"+CRLF
	cQuery += "  MAX((SUBSTRING(CNF_COMPET,4,4))+SUBSTRING(CNF_COMPET,1,2))+'01' AS MAXCOMPET"+CRLF
	cQuery += " FROM " + CRLF
	cQuery += "  "+cTabCNF+" CNF " + CRLF

	cQuery += " INNER JOIN "+cTabCN9+" CN9 ON "+ CRLF
	cQuery += "    CN9_NUMERO = CNF_CONTRA" + CRLF
	cQuery += "	   AND CN9_REVISA = CNF_REVISA" + CRLF
	cQuery += "    AND CN9_FILIAL = '01' AND  CN9.D_E_L_E_T_ = ''" + CRLF
	cQuery += " WHERE CNF.D_E_L_E_T_=''" + CRLF
	cQuery += "      AND CN9_REVATU = ' '" + CRLF
	cQuery += " GROUP BY " + CRLF
	cQuery += "      CN9_NUMERO," + CRLF
	cQuery += "      CN9_GESTC, " + CRLF
	cQuery += "      CN9_SITUAC," + CRLF
	cQuery += "      CN9_XXNRBK," + CRLF
	cQuery += "      CN9_XXDVIG"+CRLF
Next

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  EMPRESA, " + CRLF
cQuery += "  NOMEEMP, " + CRLF
cQuery += "  GETDATE() AS DATAPRC, " + CRLF
cQuery += "  CONTRATO,  " + CRLF
cQuery += "  EMPRESA + CONTRATO AS CHAVE," + CRLF
cQuery += "  CN9_GESTC,  " + CRLF
cQuery += "  CN9_XXNRBK,  " + CRLF
cQuery += "  VIG.CN9_SITUAC, " + CRLF
cQuery += "  VIG.CN9DTOSER, " + CRLF
cQuery += "  VIG.CN9DTINIC, " + CRLF
cQuery += "  VIG.CNFINICIO, " + CRLF
cQuery += "  VIG.CNFFIM, " + CRLF
cQuery += "  VIG.MAXCOMPET, " + CRLF
cQuery += "  -- Inicio do contrato " + CRLF
cQuery += "  CASE WHEN VIG.CN9DTOSER > ' ' AND VIG.CN9DTOSER < CN9DTINIC AND VIG.CN9DTOSER < VIG.CNFINICIO THEN CONVERT(DATE,VIG.CN9DTOSER,112) " + CRLF
cQuery += "       WHEN VIG.CN9DTINIC > ' ' AND VIG.CN9DTINIC < VIG.CNFINICIO THEN CONVERT(DATE,VIG.CN9DTINIC,112) " + CRLF
cQuery += "       ELSE CONVERT(DATE,VIG.CNFINICIO,112) " + CRLF
cQuery += "       END AS VIGINICIO, " + CRLF
cQuery += "  -- Final do contrato " + CRLF
cQuery += "  CONVERT(DATE,VIG.CN9_XXDVIG,112) AS CTFINAL,"
cQuery += "  CASE WHEN VIG.MAXCOMPET > VIG.CNFFIM THEN CONVERT(DATE,VIG.MAXCOMPET,112) ELSE CONVERT(DATE,VIG.CNFFIM,112) END AS VIGFINAL " + CRLF
cQuery += "  INTO PowerBk.dbo.GESTORES  " + CRLF
cQuery += "  FROM VIG " + CRLF

cQuery += " ORDER BY" + CRLF
cQuery += "    EMPRESA,CONTRATO" + CRLF

u_LogMemo("BKDASH01-GES.SQL",cQuery)

If !TCIsConnected()
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.GESTORES', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.GESTORES "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro1, cPerg)
	EndIf
EndIf

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro2, cPerg)
	EndIf
EndIf

u_LogMemo("BKDASH01-GES.SQL",cErro1+cQueryD+cErro2+cQuery)

Return


// Atualização da tabela GLOSAS do banco de dados PowerBk
Static Function ProcDSGLO
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0
Local cEmpresa  := ""
Local cNomeEmp  := ""

Local cTabSZR   := ""
Local cTabCNR   := ""
Local cTabSF2   := ""
Local cTabSC5   := ""
Local cTabCXN   := ""
Local cTabCND   := ""
Local cTabCTT   := ""
Local cTabCN9   := ""
Local cTabCNF   := ""
Local cTabCNA   := ""

u_LogPrw(cPerg,"Glosas")

cTabSZR := "SZR010"

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabCNR := "CNR"+cEmpresa+"0"
	cTabSF2 := "SF2"+cEmpresa+"0"
	cTabSC5 := "SC5"+cEmpresa+"0"
	cTabCXN := "CXN"+cEmpresa+"0"
	cTabCND := "CND"+cEmpresa+"0"
	cTabCTT := "CTT"+cEmpresa+"0"
	cTabCN9 := "CN9"+cEmpresa+"0"
	cTabCNF := "CNF"+cEmpresa+"0"
	cTabCNA := "CNA"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += "SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF
	cQuery += "  SUBSTRING(ISNULL(CND_CONTRA, ISNULL(C5_ESPECI1,'000000001')),1,9) AS CONTRATO, " + CRLF
	cQuery += "  ISNULL(CTT_DESC01,'BK CONSULTORIA') AS DESCRICAO, " + CRLF
	cQuery += "  ISNULL(C5_XXCOMPM,SUBSTRING(F2_EMISSAO,5,2)+'/'+SUBSTRING(F2_EMISSAO,1,4)) AS COMPET, " + CRLF
	cQuery += "  SUBSTRING(C5_XXCOMPM,4,4)+SUBSTRING(C5_XXCOMPM,1,2) AS COMPETAM, " + CRLF
	cQuery += "  CONVERT(DATE,SUBSTRING(C5_XXCOMPM,4,4)+SUBSTRING(C5_XXCOMPM,1,2)+'01',112) AS COMPETD, " + CRLF

	// Chave
	cQuery += "  '"+cEmpresa+"' + "+CRLF
	cQuery += "     SUBSTRING(ISNULL(CND_CONTRA, ISNULL(C5_ESPECI1,'000000001')),1,9) +  " + CRLF
	cQuery += "     ISNULL(C5_XXCOMPM,SUBSTRING(F2_EMISSAO,1,6)) AS CHAVE, " + CRLF

	cQuery += "  C5_NUM, " + CRLF
	cQuery += "  C5_MDNUMED, " + CRLF
	cQuery += "  C5_MDPLANI, " + CRLF
	cQuery += "  F2_SERIE, " + CRLF
	cQuery += "  F2_DOC, " + CRLF
	cQuery += "  CONVERT(DATE,F2_EMISSAO,112) AS F2_EMISSAO, " + CRLF
	cQuery += "  CND_USUAR, " + CRLF
	cQuery += "  (" + CRLF
	cQuery += "    CASE WHEN CND_NUMERO = '' THEN 'NOVA' ELSE 'ANTIGA' END" + CRLF
	cQuery += "  ) AS FORMAMED, " + CRLF
	cQuery += "  CNA_XXMUN  AS CNA_XXMUN," + CRLF
	cQuery += "    CNR_TIPO," + CRLF
  	cQuery += "  (" + CRLF
    cQuery += "    CASE WHEN CNR_TIPO = '1' THEN 'MULTA' ELSE 'BONIFICAÇÃO' END" + CRLF
  	cQuery += "  ) AS CNRTIPO, " + CRLF
  	cQuery += "  CNR_VALOR," + CRLF
  	cQuery += "  CNR_XTPJUS," + CRLF
  	cQuery += "  ZR_DESCR," + CRLF
  	cQuery += "  CNR_DESCRI" + CRLF

	If nE == 1
		cQuery += "  INTO PowerBk.dbo.GLOSAS " + CRLF
	EndIf
	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabSF2+" SF2" + CRLF

	cQuery += " LEFT JOIN "+cTabSC5+" SC5" + CRLF
	cQuery += "     ON (C5_NOTA = F2_DOC " + CRLF
	cQuery += "         AND C5_SERIE = F2_SERIE " + CRLF
	cQuery += "         AND C5_FILIAL = F2_FILIAL " + CRLF
	cQuery += "         AND SC5.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCND+" CND" + CRLF
	cQuery += "     ON (CND_NUMMED = C5_MDNUMED " + CRLF
	cQuery += "         AND CND_FILIAL = F2_FILIAL " + CRLF
	cQuery += "         AND CND.D_E_L_E_T_ = '' " + CRLF
	cQuery += "         AND CND.R_E_C_N_O_ = (" + CRLF
	cQuery += "         SELECT " + CRLF
	cQuery += "             MIN(R_E_C_N_O_) " + CRLF
	cQuery += "         FROM " + CRLF
	cQuery += "            "+cTabCND+" CND1 " + CRLF
	cQuery += "         WHERE " + CRLF
	cQuery += "             CND1.CND_NUMMED = C5_MDNUMED " + CRLF
	cQuery += "             AND CND1.CND_FILIAL = '01' " + CRLF
	cQuery += "             AND CND1.D_E_L_E_T_ = ''" + CRLF
	cQuery += "         )" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCXN+" CXN" + CRLF
	cQuery += "     ON (CXN_CONTRA = C5_MDCONTR " + CRLF
	cQuery += "         AND CXN_NUMMED = C5_MDNUMED " + CRLF
	cQuery += "         AND CXN_NUMPLA = C5_MDPLANI " + CRLF
	cQuery += "         AND CXN_REVISA = CND_REVISA " + CRLF
	cQuery += "         AND CXN.CXN_CHECK = 'T' " + CRLF
	cQuery += "         AND CXN_FILIAL = F2_FILIAL " + CRLF
	cQuery += "         AND CXN.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCNF+" CNF" + CRLF
	cQuery += " 	ON (CND_CONTRA = CNF_CONTRA" +CRLF
	cQuery += " 	    AND C5_XXCOMPM = CNF_COMPET AND ISNULL(CXN_NUMPLA,CND_NUMERO) = CNF_NUMPLA" +CRLF
	cQuery += " 	    AND ISNULL(CXN_REVISA, CND_REVISA) = CNF_REVISA" +CRLF
	cQuery += " 	    AND CNF_PARCEL = ISNULL(CXN_PARCEL,CND_PARCEL)" + CRLF
	cQuery += " 	 	AND CNF_FILIAL = F2_FILIAL" + CRLF
	cQuery += " 	 	AND CNF.D_E_L_E_T_='')" + CRLF

	cQuery += " LEFT JOIN "+cTabCNA+" CNA" + CRLF
	cQuery += " 	ON (CNA_CONTRA = CNF_CONTRA" + CRLF
	cQuery += " 	    AND CNA_CRONOG = CNF_NUMERO" + CRLF
	cQuery += " 	    AND CNA_REVISA = CNF_REVISA" + CRLF
	cQuery += " 	    AND CNA_NUMERO = CNF_NUMPLA" +CRLF
	cQuery += " 		AND CNA_FILIAL = CNF_FILIAL" +CRLF
	cQuery += " 		AND CNA.D_E_L_E_T_=''"+CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON (ISNULL(CND_CONTRA, C5_ESPECI1) = CTT_CUSTO " + CRLF
	cQuery += " 		AND CTT_FILIAL = '"+xFilial("CTT")+"'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " INNER JOIN "+cTabCNR+" CNR" + CRLF
	cQuery += "     ON (C5_MDNUMED = CNR.CNR_NUMMED " + CRLF
	cQuery += "         AND (CNR_CODPLA = ' ' OR CNR_CODPLA = ISNULL(CXN_NUMPLA,CND_NUMERO))" + CRLF
	cQuery += "         AND CNR_FILIAL = F2_FILIAL " + CRLF
	cQuery += "         AND CNR.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabSZR+" SZR" + CRLF
	cQuery += "     ON ZR_TIPO = CNR_XTPJUS" + CRLF
	cQuery += "     AND SZR.D_E_L_E_T_ = ''" + CRLF

	cQuery += "WHERE " + CRLF
	cQuery += "     SF2.D_E_L_E_T_ = '' " + CRLF

Next

cQuery += " ORDER BY" + CRLF
cQuery += "      EMPRESA,F2_SERIE,F2_DOC" + CRLF

u_LogMemo("BKDASH01-GLO.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

//Begin Transaction


	cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.GLOSAS', N'U') IS NOT NULL"  
	cQueryD += "   DROP TABLE PowerBk.dbo.GLOSAS "+CRLF
	nErro   := TcSqlExec(cQueryD)

	If nErro != 0
		cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		If !IsBlind()
			MsgStop(cErro1, cPerg)
		EndIf
	EndIf

	nErro   := TcSqlExec(cQuery)

	If nErro != 0
		cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		If !IsBlind()
			MsgStop(cErro2, cPerg)
		EndIf
	EndIf


//End Transaction

u_LogMemo("BKDASH01-GLO.SQL",cErro1+cQueryD+cErro2+cQuery)

Return




// Atualização da tabela GASTOSGERAIS do banco de dados PowerBk
Static Function ProcDSGG
Local cQuery	:= ""
Local cQueryD	:= ""
//Local cQueryF	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpDsp()
Local nE 		:= 0
Local cEmpresa  := ""
Local cNomeEmp  := ""

Local cTabSD1	:= ""
Local cTabSB1	:= ""
Local cTabSE2	:= ""
Local cTabSA2	:= ""
Local cTabSF1	:= ""
Local cTabCTT	:= ""
Local cTabSE5	:= ""
Local cTabCT1	:= ""
Local cTabSZ2   := "SZ2010"
Local cCusBK	:= U_MVXCUSBK()
Local cDescExm  := Posicione("SB1",1,xFilial("SB1")+U_MVXCEXMP(),"B1_DESC")
Local cDescDCH 	:= Posicione("SB1",1,xFilial("SB1")+U_MVXCDCH(),"B1_DESC")
Local cDescCBK	:= Posicione("SB1",1,xFilial("SB1")+cCusBK,"B1_DESC")

u_LogPrw(cPerg,"Gastos Gerais")

cQuery := "WITH DESPESAS AS ("+CRLF

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabSD1 := "SD1"+cEmpresa+"0"
	cTabSB1 := "SB1"+cEmpresa+"0"
	cTabSE2 := "SE2"+cEmpresa+"0"
	cTabSA2 := "SA2"+cEmpresa+"0"
	cTabSF1 := "SF1"+cEmpresa+"0"
	cTabCT1 := "CT1"+cEmpresa+"0"
	cTabCTT := "CTT"+cEmpresa+"0"
	cTabSE5 := "SE5"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF
	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '302000508' ELSE SUBSTRING(D1_CC,1,9) END) AS CONTRATO,"+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '305000554' ELSE SUBSTRING(D1_CC,1,9) END) AS CONTRATO,"+CRLF	
	Else
		cQuery += "  SUBSTRING(D1_CC,1,9) AS CONTRATO, " + CRLF
	EndIf
	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
 	cQuery += "  SUBSTRING(E2_VENCREA,5,2)+'/'+SUBSTRING(E2_VENCREA,1,4) AS COMPET,"+CRLF
 	cQuery += "  SUBSTRING(E2_VENCREA,1,6) AS COMPETAM,"+CRLF
 	cQuery += "  CONVERT(DATE,SUBSTRING(E2_VENCREA,1,6)+'01',112) AS COMPETD,"+CRLF

	// Chave
	cQuery += "  '"+cEmpresa+"' + "+CRLF
	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '302000508' ELSE SUBSTRING(D1_CC,1,9) END) + "+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '305000554' ELSE SUBSTRING(D1_CC,1,9) END) + "+CRLF	
	Else
		cQuery += "  SUBSTRING(D1_CC,1,9) + " + CRLF
	EndIf
	cQuery += "     SUBSTRING(E2_VENCREA,1,6)  AS CHAVE, " + CRLF
	cQuery += "     'SD1' AS ORIGEM, " + CRLF

 	cQuery += "  D1_FILIAL,"+CRLF
 	cQuery += "  D1_SERIE,"+CRLF
 	cQuery += "  D1_DOC,"+CRLF
 	cQuery += "  D1_FORNECE,"+CRLF
 	cQuery += "  D1_LOJA,"+CRLF
 	cQuery += "  A2_NOME,"+CRLF
 	cQuery += "  D1_ITEM,"+CRLF
 	cQuery += "  D1_COD,"+CRLF
	cQuery += "  CONVERT(VARCHAR(600),CONVERT(Binary(600),D1_XXHIST)) D1_XXHIST,"+CRLF
 	cQuery += "  B1_DESC,"+CRLF
 	cQuery += "  B1_GRUPO,"+CRLF
 	cQuery += "  F1_VALBRUT,"+CRLF
 	cQuery += "  F1_XXUSER,"+CRLF
	cQuery += "  (SELECT TOP 1 USUARIOS.NOME FROM PowerBk.dbo.USUARIOS USUARIOS WHERE F1_XXUSER = USUARIOS.CODIGO) AS F1RESPON,"+CRLF
 	cQuery += "  F1_XXULIB,"+CRLF
	cQuery += "  (SELECT TOP 1 USUARIOS.NOME FROM PowerBk.dbo.USUARIOS USUARIOS WHERE F1_XXULIB = USUARIOS.CODIGO) AS F1APROV,"+CRLF
 	cQuery += "  E2_PARCELA,"+CRLF
 	cQuery += "  E2_VALOR,"+CRLF
 	cQuery += "  E2_DESCONT,"+CRLF
 	cQuery += "  E2_MULTA,"+CRLF
 	cQuery += "  E2_JUROS,"+CRLF
 	cQuery += "  E2_ACRESC,"+CRLF
 	cQuery += "  E2_DECRESC,"+CRLF
 	cQuery += "  E2_VRETPIS,"+CRLF
 	cQuery += "  E2_VRETCOF,"+CRLF
 	cQuery += "  E2_VRETCSL,"+CRLF
 	cQuery += "  E2_VRETINS,"+CRLF
 	cQuery += "  E2_VRETIRF,"+CRLF
 	cQuery += "  E2_VRETISS,"+CRLF
 	cQuery += "  E2_VALOR+E2_VRETPIS+E2_VRETCOF+E2_VRETCSL+E2_VRETINS+E2_VRETIRF+E2_VRETISS AS E2VALTIT,"+CRLF
 	cQuery += "  (D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC)  AS D1TOTAL,"+CRLF
 	cQuery += "  CASE WHEN E2_ACRESC  > 0 THEN E2_ACRESC  ELSE E2_MULTA+E2_JUROS END - "+CRLF
 	cQuery += "  	CASE WHEN E2_DECRESC > 0 THEN E2_DECRESC ELSE E2_DESCONT END AS E2ACDEC"+CRLF

	cQuery += "FROM " + CRLF
	cQuery += " "+cTabSD1+" SD1" + CRLF

	cQuery += " LEFT JOIN "+cTabSA2+" SA2" + CRLF
	cQuery += "     ON (A2_COD = D1_FORNECE " + CRLF
	cQuery += "         AND A2_LOJA = D1_LOJA " + CRLF
	cQuery += "         AND A2_FILIAL = '"+xFilial("SA2")+"' " + CRLF
	cQuery += "         AND SA2.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " INNER JOIN "+cTabSB1+" SB1" + CRLF
	cQuery += "     ON (B1_COD = D1_COD " + CRLF
	cQuery += "         AND B1_FILIAL = '"+xFilial("SB1")+"' "  + CRLF
	cQuery += "         AND SB1.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

 	cQuery += " INNER JOIN "+cTabSE2+" SE2" + CRLF
	cQuery += "     ON (E2_TIPO = 'NF' " + CRLF
	cQuery += "         AND E2_PREFIXO = D1_SERIE" + CRLF
	cQuery += "         AND E2_NUM = D1_DOC" + CRLF
	cQuery += "         AND E2_FORNECE = D1_FORNECE" + CRLF
	cQuery += "         AND E2_LOJA = D1_LOJA" + CRLF
	cQuery += "         AND E2_FILIAL = '"+xFilial("SE2")+"' " + CRLF
	cQuery += "         AND SE2.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

 	cQuery += " INNER JOIN "+cTabSF1+" SF1" + CRLF
	cQuery += "     ON (F1_SERIE = D1_SERIE" + CRLF
	cQuery += "         AND F1_DOC = D1_DOC" + CRLF
	cQuery += "         AND F1_FORNECE = D1_FORNECE" + CRLF
	cQuery += "         AND F1_LOJA = D1_LOJA" + CRLF
	cQuery += "         AND F1_FILIAL = D1_FILIAL " + CRLF
	cQuery += "         AND SF1.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON ( CTT_CUSTO = " + CRLF

	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '302000508' ELSE D1_CC END)"+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(D1_CC,1,3) = '000' THEN '305000554' ELSE D1_CC END)"+CRLF	
	Else
		cQuery += "  D1_CC " + CRLF
	EndIf

	cQuery += " 		AND CTT_FILIAL = '01'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "WHERE SD1.D1_FILIAL = '01' " + CRLF
	cQuery += "      AND SD1.D_E_L_E_T_ = '' " + CRLF
	cQuery += "      AND (SUBSTRING(B1_CONTA,1,1) = '3'" + CRLF
	cQuery += "      	OR B1_CONTA IN ('"+cCusBK+"') " + CRLF
	cQuery += "      	OR SUBSTRING(B1_CONTA,1,5) IN ('12201','12105')) " + CRLF

	IF cEmpresa == "01" // Despesas médicas 
		cQuery += "AND 1 = CASE WHEN D1_CC = '313000504' AND D1_FORNECE = '002918' THEN 0 ELSE 1 END"+CRLF
	ENDIF 
	IF cEmpresa == "14" // Despesas médicas
		cQuery += "      AND D1_FORNECE <> '000604'"+CRLF
	ENDIF 

	// Movimento Bancário
	cQuery += "UNION ALL "+CRLF

	cQuery += " SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF

	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '302000508' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END) AS CONTRATO, " + CRLF
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '305000554' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END) AS CONTRATO, " + CRLF
	Else
		cQuery += "  (CASE "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END) AS CONTRATO, " + CRLF
	EndIf

	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
 	cQuery += "  SUBSTRING(E5_VENCTO,5,2)+'/'+SUBSTRING(E5_VENCTO,1,4) AS COMPET,"+CRLF
 	cQuery += "  SUBSTRING(E5_VENCTO,1,6) AS COMPETAM,"+CRLF
 	cQuery += "  CONVERT(DATE,SUBSTRING(E5_VENCTO,1,6)+'01',112) AS COMPETD,"+CRLF

	// Chave
	cQuery += "  '"+cEmpresa+"' + "+CRLF

	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '302000508' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END) + " + CRLF
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '305000554' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END) + " + CRLF
	Else
		cQuery += "  (CASE "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END) + " + CRLF
	EndIf
	cQuery += "   SUBSTRING(E5_VENCTO,1,6) AS CHAVE, " + CRLF
	cQuery += "     'SE5' AS ORIGEM, " + CRLF

 	//cQuery += "  E5_VALOR * (CASE WHEN E5_RECPAG = 'R' THEN -1 ELSE 1 END) AS E5_VALOR,"+CRLF
 	//cQuery += "  E5_RECPAG,"+CRLF
 	//cQuery += "  UPPER(E5_HISTOR) AS E5_HISTOR,"+CRLF
 	//Query += "  'W'+SUBSTRING(CT1_DESC01,1,15) AS E5CODIGO "+CRLF

  	cQuery += "     E5_FILIAL  AS D1_FILIAL, " + CRLF
  	cQuery += "     E5_PREFIXO AS D1_SERIE, " + CRLF
  	cQuery += "     E5_NUMERO  AS D1_DOC, " + CRLF
  	cQuery += "     E5_CLIFOR  AS D1_FORNECE, " + CRLF
  	cQuery += "     E5_LOJA    AS D1_LOJA, " + CRLF
 	cQuery += "     A2_NOME,"+CRLF
  	cQuery += "     '0001'     AS D1_ITEM, " + CRLF
  	cQuery += "     SUBSTRING(CT1_DESC01,1,15) AS D1_COD, " + CRLF
	cQuery += "     E5_HISTOR  AS D1_XXHIST, " + CRLF
  	cQuery += "     CT1_DESC01 AS B1_DESC, " + CRLF
  	cQuery += "     ' '        AS B1_GRUPO, " + CRLF
  	cQuery += "     E5_VALOR * (CASE WHEN E5_RECPAG = 'R' THEN -1 ELSE 1 END) AS F1_VALBRUT, " + CRLF
	cQuery += "     ' '        AS F1_XXUSER, " + CRLF
	cQuery += "     ' '        AS F1RESPON, " + CRLF
	cQuery += "     ' '        AS F1_XXULIB, " + CRLF
	cQuery += "     ' '        AS F1APROV, " + CRLF
  	cQuery += "     E5_PARCELA AS E2_PARCELA, " + CRLF
  	cQuery += "     E5_VALOR * (CASE WHEN E5_RECPAG = 'R' THEN -1 ELSE 1 END) AS E2_VALOR, " + CRLF
  	cQuery += "     E5_VLDESCO AS E2_DESCONT, " + CRLF
  	cQuery += "     E5_VLMULTA AS E2_MULTA, " + CRLF
  	cQuery += "     E5_VLJUROS AS E2_JUROS, " + CRLF
  	cQuery += "     E5_VLACRES AS E2_ACRESC, " + CRLF
  	cQuery += "     E5_VLDECRE AS E2_DECRESC, " + CRLF
  	cQuery += "     E5_VRETPIS AS E2_VRETPIS, " + CRLF
  	cQuery += "     E5_VRETCOF AS E2_VRETCOF, " + CRLF
  	cQuery += "     E5_VRETCSL AS E2_VRETCSL, " + CRLF
  	cQuery += "     E5_VRETINS AS E2_VRETINS, " + CRLF
  	cQuery += "     E5_VRETIRF AS E2_VRETIRF, " + CRLF
  	cQuery += "     E5_VRETISS AS E2_VRETISS, " + CRLF
  	cQuery += "     E5_VALOR * (CASE WHEN E5_RECPAG = 'R' THEN -1 ELSE 1 END) AS E2VALTIT, " + CRLF
  	cQuery += "     E5_VALOR * (CASE WHEN E5_RECPAG = 'R' THEN -1 ELSE 1 END) AS D1TOTAL, " + CRLF
  	cQuery += "     CASE WHEN E5_VLACRES > 0 THEN E5_VLACRES ELSE E5_VLMULTA+E5_VLJUROS END -  " + CRLF
  	cQuery += "     	CASE WHEN E5_VLDECRE > 0 THEN E5_VLDECRE ELSE E5_VLDESCO END AS E2ACDEC " + CRLF

	cQuery += "FROM " + CRLF
	cQuery += " "+cTabSE5+" SE5 " + CRLF

	cQuery += "LEFT JOIN "+cTabSA2+" SA2" + CRLF
	cQuery += "     ON (A2_COD = E5_CLIFOR " + CRLF
	cQuery += "         AND A2_LOJA = E5_LOJA " + CRLF
	cQuery += "         AND A2_FILIAL = '"+xFilial("SA2")+"' " + CRLF
	cQuery += "         AND SA2.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON ( CTT_CUSTO = "+ CRLF
	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '302000508' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END)  " + CRLF
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(E5_CCD,1,3) = '000' OR SUBSTRING(E5_CCC,1,3) = '000' THEN '305000554' "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END)  " + CRLF
	Else
		cQuery += "  (CASE "+CRLF
		cQuery += "        WHEN E5_CCD = ' ' THEN E5_CCC "+CRLF
		cQuery += "        WHEN E5_CCC = ' ' THEN E5_CCD "+CRLF
		cQuery += "   END)  " + CRLF
	EndIf
	cQuery += " 		AND CTT_FILIAL = '01'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "LEFT JOIN "+cTabCT1+" CT1" + CRLF
	cQuery += "     ON ( "+ CRLF
	cQuery += "        (CT1_CONTA = E5_DEBITO OR CT1_CONTA = E5_CREDITO)" + CRLF
	cQuery += " 	   AND CT1_FILIAL = '  '" + CRLF
	cQuery += "        AND CT1.D_E_L_E_T_=''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "WHERE SE5.E5_FILIAL = '01' " + CRLF
	cQuery += "      AND SE5.D_E_L_E_T_ = '' " + CRLF
	cQuery += "      AND (SUBSTRING(E5_DEBITO,1,1)='3' OR SUBSTRING(E5_CREDITO,1,1)='3' )" + CRLF
	cQuery += "      AND E5_SITUACA <> 'C' " + CRLF
	cQuery += "      AND (E5_CCC <> ' ' OR E5_CCD <> '  ') " + CRLF
	//If cEmpresa <> '14' .AND. cEmpresa <> '15'
		cQuery += "      AND (SUBSTRING(E5_CCC,1,3) <> '000' AND SUBSTRING(E5_CCD,1,3) <> '000') " + CRLF
	///EndIf

	// Despesas advindas da integração Rubi Microsiga
	// CLT

	cQuery += "UNION ALL "+CRLF

	cQuery += " SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF

	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '302000508' ELSE SUBSTRING(Z2_CC,1,9) END) AS CONTRATO,"+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '305000554' ELSE SUBSTRING(Z2_CC,1,9) END) AS CONTRATO,"+CRLF	
	Else
		cQuery += "  SUBSTRING(Z2_CC,1,9) AS CONTRATO, " + CRLF
	EndIf

	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
 	cQuery += "  SUBSTRING(Z2_DATAPGT,5,2)+'/'+SUBSTRING(Z2_DATAPGT,1,4) AS COMPET,"+CRLF
 	cQuery += "  SUBSTRING(Z2_DATAPGT,1,6) AS COMPETAM,"+CRLF
 	cQuery += "  CONVERT(DATE,SUBSTRING(Z2_DATAPGT,1,6)+'01',112) AS COMPETD,"+CRLF

	// Chave
	cQuery += "  ('"+cEmpresa+"' + "+CRLF
	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '302000508' ELSE SUBSTRING(Z2_CC,1,9) END) + "+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '305000554' ELSE SUBSTRING(Z2_CC,1,9) END) + "+CRLF	
	Else
		cQuery += "  SUBSTRING(Z2_CC,1,9) + " + CRLF
	EndIf
	cQuery += "   SUBSTRING(Z2_DATAPGT,1,6)) AS CHAVE, " + CRLF
	cQuery += "  'SZ2-CLT' AS ORIGEM, " + CRLF

	cQuery += "  Z2_FILIAL   AS D1_FILIAL,"+CRLF
	cQuery += "  Z2_E2PRF	 AS D1_SERIE,"+CRLF
	cQuery += "  Z2_E2NUM    AS D1_DOC,"+CRLF
	cQuery += "  Z2_E2FORN   AS D1_FORNECE,"+CRLF
	cQuery += "  Z2_E2LOJA   AS D1_LOJA,"+CRLF
 	cQuery += "  A2_NOME,"+CRLF
	cQuery += "  '0001'      AS D1_ITEM,"+CRLF

	// PRODUTO CLT
	cQuery += "  (CASE "+CRLF
	cQuery += "    	WHEN Z2_TIPO = 'VT' THEN '12' "+CRLF
	cQuery += "    	WHEN Z2_TIPO IN ('VR','VA') THEN '14' "+CRLF
	cQuery += "    	WHEN Z2_TIPO = 'EXM' THEN '"+U_MVXCEXMP()+"'"+CRLF
	cQuery += "    	WHEN Z2_TIPO IN ('DCH','SOL','HOS','REE','CXA') THEN '"+U_MVXCDCH()+"'"+CRLF
	cQuery += "     ELSE Z2_TIPO "+CRLF
	cQuery += "   END"+CRLF
	cQuery += "  ) AS D1_COD,"+CRLF

	cQuery += "  RTRIM(Z2_NOME)+': '+RTRIM(Z2_OBSTITU)  AS D1_XXHIST,"+CRLF

	cQuery += "  (CASE "+CRLF
	cQuery += "     WHEN Z2_TIPO = 'VT' THEN 'VT' "+CRLF
	cQuery += "    	WHEN Z2_TIPO IN ('VR','VA') THEN 'VR/VA' "+CRLF
	cQuery += "    	WHEN Z2_TIPO = 'EXM' THEN '"+cDescExm+"'"+CRLF
	cQuery += "    	WHEN Z2_TIPO IN ('DCH','SOL','HOS','REE','CXA') THEN '"+cDescDCH+"'"+CRLF
	cQuery += "     ELSE Z2_TIPO "+CRLF
	cQuery += "   END"+CRLF
	cQuery += "  ) AS B1_DESC,"+CRLF

	cQuery += "  ' '         AS B1_GRUPO, "+CRLF
	cQuery += "  Z2_VALOR    AS F1_VALBRUT,"+CRLF
	cQuery += "  (SELECT TOP 1 USUARIOS.CODIGO FROM PowerBk.dbo.USUARIOS USUARIOS WHERE UPPER(Z2_USUARIO) = USUARIOS.NOME OR UPPER(Z2_USUARIO) = USUARIOS.USUARIO) AS F1_XXUSER, "+CRLF
	cQuery += "  UPPER(Z2_USUARIO)  AS F1_RESPON,"+CRLF
	cQuery += "  (SELECT TOP 1 USUARIOS.CODIGO FROM PowerBk.dbo.USUARIOS USUARIOS WHERE UPPER(Z2_USUARIO) = USUARIOS.NOME OR UPPER(Z2_USUARIO) = USUARIOS.USUARIO) AS F1_XXULIB, "+CRLF
	cQuery += "  UPPER(Z2_USUARIO)  AS F1_APROV,"+CRLF
	cQuery += "  '  '        AS E2_PARCELA,"+CRLF
	cQuery += "  Z2_VALOR    AS E2_VALOR,"+CRLF
	cQuery += "  0           AS E2_DESCONT,"+CRLF
	cQuery += "  0           AS E2_MULTA,"+CRLF
	cQuery += "  0           AS E2_JUROS,"+CRLF
	cQuery += "  0           AS E2_ACESC,"+CRLF
	cQuery += "  0           AS E2_DECRESC,"+CRLF
	cQuery += "  0           AS E2_VRETPIS,"+CRLF
	cQuery += "  0           AS E2_VRETCOF,"+CRLF
	cQuery += "  0           AS E2_VRETCSL,"+CRLF
	cQuery += "  0           AS E2_VRETINS,"+CRLF
	cQuery += "  0           AS E2_VRETIRF,"+CRLF
	cQuery += "  0           AS E2_VRETISS,"+CRLF
	cQuery += "  Z2_VALOR    AS E2VALTIT,"+CRLF
	cQuery += "  Z2_VALOR    AS D1TOTAL,"+CRLF
	cQuery += "  0           AS E2ACDEC"+CRLF

	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabSZ2+" SZ2" + CRLF

	cQuery += "LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON ( CTT_CUSTO = " + CRLF
	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '302000508' ELSE Z2_CC END)"+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '305000554' ELSE Z2_CC END)"+CRLF	
	Else
		cQuery += "  Z2_CC " + CRLF
	EndIf
	cQuery += " 		AND CTT_FILIAL = '01'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += " LEFT JOIN "+cTabSA2+" SA2" + CRLF
	cQuery += "     ON (A2_COD = Z2_E2FORN " + CRLF
	cQuery += "         AND A2_LOJA = Z2_E2LOJA " + CRLF
	cQuery += "         AND A2_FILIAL = '"+xFilial("SA2")+"' " + CRLF
	cQuery += "         AND SA2.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "WHERE Z2_FILIAL = '  ' " + CRLF
	cQuery += "      AND SZ2.D_E_L_E_T_ = '' " + CRLF
	cQuery += "      AND SZ2.Z2_CODEMP = '"+cEmpresa+"'" + CRLF
	cQuery += "      AND SZ2.Z2_TIPO IN ('EXM','VT','VR','VA','DCH','SOL','HOS','REE','CXA') " + CRLF
	cQuery += "      AND SZ2.Z2_TIPOPES = 'CLT' " + CRLF
	cQuery += "      AND SZ2.Z2_STATUS = 'S' " + CRLF

	cQuery += "UNION ALL "+CRLF

	cQuery += " SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF
	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '302000508' ELSE SUBSTRING(Z2_CC,1,9) END) AS CONTRATO,"+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '305000554' ELSE SUBSTRING(Z2_CC,1,9) END) AS CONTRATO,"+CRLF	
	Else
		cQuery += "  SUBSTRING(Z2_CC,1,9) AS CONTRATO, " + CRLF
	EndIf	
	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
 	cQuery += "  SUBSTRING(Z2_DATAPGT,5,2)+'/'+SUBSTRING(Z2_DATAPGT,1,4) AS COMPET,"+CRLF
 	cQuery += "  SUBSTRING(Z2_DATAPGT,1,6) AS COMPETAM,"+CRLF
 	cQuery += "  CONVERT(DATE,SUBSTRING(Z2_DATAPGT,1,6)+'01',112) AS COMPETD,"+CRLF

	// Chave
	cQuery += "  ('"+cEmpresa+"' + "+CRLF
	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '302000508' ELSE SUBSTRING(Z2_CC,1,9) END) + "+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '305000554' ELSE SUBSTRING(Z2_CC,1,9) END) + "+CRLF	
	Else
		cQuery += "  SUBSTRING(Z2_CC,1,9) + " + CRLF
	EndIf
	cQuery += "   SUBSTRING(Z2_DATAPGT,1,6)) AS CHAVE, " + CRLF
	cQuery += "  'SZ2-AC' AS ORIGEM, " + CRLF

	cQuery += "  Z2_FILIAL   AS D1_FILIAL,"+CRLF
	cQuery += "  Z2_E2PRF	 AS D1_SERIE,"+CRLF
	cQuery += "  Z2_E2NUM    AS D1_DOC,"+CRLF
	cQuery += "  Z2_E2FORN   AS D1_FORNECE,"+CRLF
	cQuery += "  Z2_E2LOJA   AS D1_LOJA,"+CRLF
 	cQuery += "  A2_NOME,"+CRLF
	cQuery += "  '0001'      AS D1_ITEM,"+CRLF

	// PRODUTO AC/CLA
	cQuery += "  '"+cCusBK+"' AS D1_COD,"+CRLF
	cQuery += "  RTRIM(Z2_NOME)+': '+RTRIM(Z2_OBSTITU)  AS D1_XXHIST,"+CRLF
	cQuery += "  '"+cDescCBK+"' AS B1_DESC,"+CRLF
	cQuery += "  ' '         AS B1_GRUPO, "+CRLF
	cQuery += "  Z2_VALOR    AS F1_VALBRUT,"+CRLF
	cQuery += "  (SELECT TOP 1 USUARIOS.CODIGO FROM PowerBk.dbo.USUARIOS USUARIOS WHERE UPPER(Z2_USUARIO) = USUARIOS.NOME OR UPPER(Z2_USUARIO) = USUARIOS.USUARIO) AS F1_XXUSER, "+CRLF
	cQuery += "  UPPER(Z2_USUARIO)  AS F1_RESPON,"+CRLF
	cQuery += "  (SELECT TOP 1 USUARIOS.CODIGO FROM PowerBk.dbo.USUARIOS USUARIOS WHERE UPPER(Z2_USUARIO) = USUARIOS.NOME OR UPPER(Z2_USUARIO) = USUARIOS.USUARIO) AS F1_XXULIB, "+CRLF
	cQuery += "  UPPER(Z2_USUARIO)  AS F1_APROV,"+CRLF
	cQuery += "  '  '        AS E2_PARCELA,"+CRLF
	cQuery += "  Z2_VALOR    AS E2_VALOR,"+CRLF
	cQuery += "  0           AS E2_DESCONT,"+CRLF
	cQuery += "  0           AS E2_MULTA,"+CRLF
	cQuery += "  0           AS E2_JUROS,"+CRLF
	cQuery += "  0           AS E2_ACESC,"+CRLF
	cQuery += "  0           AS E2_DECRESC,"+CRLF
	cQuery += "  0           AS E2_VRETPIS,"+CRLF
	cQuery += "  0           AS E2_VRETCOF,"+CRLF
	cQuery += "  0           AS E2_VRETCSL,"+CRLF
	cQuery += "  0           AS E2_VRETINS,"+CRLF
	cQuery += "  0           AS E2_VRETIRF,"+CRLF
	cQuery += "  0           AS E2_VRETISS,"+CRLF
	cQuery += "  Z2_VALOR    AS E2VALTIT,"+CRLF
	cQuery += "  Z2_VALOR    AS D1TOTAL,"+CRLF
	cQuery += "  0           AS E2ACDEC"+CRLF

	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabSZ2+" SZ2" + CRLF

	cQuery += "LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON ( CTT_CUSTO = " + CRLF
	If cEmpresa == '14'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '302000508' ELSE Z2_CC END)"+CRLF	
	ElseIf cEmpresa == '15'
		cQuery += "  (CASE WHEN SUBSTRING(Z2_CC,1,3) = '000' OR SUBSTRING(Z2_CC,1,3) = 'Er:' THEN '305000554' ELSE Z2_CC END)"+CRLF	
	Else
		cQuery += "  Z2_CC " + CRLF
	EndIf
	cQuery += " 		AND CTT_FILIAL = '01'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "LEFT JOIN "+cTabSA2+" SA2" + CRLF
	cQuery += "     ON (A2_COD = Z2_E2FORN " + CRLF
	cQuery += "         AND A2_LOJA = Z2_E2LOJA " + CRLF
	cQuery += "         AND A2_FILIAL = '"+xFilial("SA2")+"' " + CRLF
	cQuery += "         AND SA2.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "WHERE Z2_FILIAL = '  ' " + CRLF
	cQuery += "      AND SZ2.D_E_L_E_T_ = '' " + CRLF
	cQuery += "      AND SZ2.Z2_CODEMP = '"+cEmpresa+"'" + CRLF
	cQuery += "      AND SZ2.Z2_TIPOPES IN ('AC','CLA') " + CRLF
	cQuery += "      AND SZ2.Z2_STATUS = 'S' " + CRLF

Next

cQuery += ")"+CRLF
cQuery += " SELECT *,"+CRLF

// Gravar a chave das Previsões
cQuery += "	(SELECT TOP 1 ZGCHAVE FROM "+CRLF
cQuery += "		(SELECT MAX(COMPETAM+ZG_SEQ) AS ZGCHAVE"+CRLF
cQuery += "		FROM PowerBk.dbo.PREVDESP1 "+CRLF
cQuery += "		WHERE PREVDESP1.EMPRESA = DESPESAS.EMPRESA"+CRLF
cQuery += "		    AND PREVDESP1.CONTRATO = DESPESAS.CONTRATO"+CRLF
cQuery += "		    AND PREVDESP1.COMPETAM <= DESPESAS.COMPETAM"+CRLF
cQuery += "		GROUP BY PREVDESP1.CONTRATO,PREVDESP1.ZG_DATA"+CRLF
cQuery += "		) AS X"+CRLF
cQuery += "		ORDER BY ZGCHAVE DESC) AS CHAVEZG,"+CRLF

cQuery += "	   (E2ACDEC  / F1_VALBRUT * D1TOTAL)   AS E2ACDECIT,"+CRLF
cQuery += "	   (E2VALTIT / F1_VALBRUT * D1TOTAL)   AS D1TOTIT,"+CRLF
cQuery += "       (E2ACDEC  / F1_VALBRUT * D1TOTAL) + (E2VALTIT / F1_VALBRUT * D1TOTAL) AS DESPESA,"+CRLF

// Produtos das previsões

cQuery += "    (CASE "+CRLF
cQuery += "    	WHEN D1_COD IN "+U_FBkVars(U_MVXVTPRD())+" THEN '12' "+CRLF
cQuery += "    	WHEN D1_COD IN "+U_FBkVars(U_MVXVRVAP())+" THEN '14' "+CRLF
cQuery += "    	WHEN B1_GRUPO = '0008' THEN 'WUNIFORME' "+CRLF
cQuery += "    	WHEN B1_GRUPO = '0009' THEN 'WMATERIAL DE SEG' "+CRLF
cQuery += "    	WHEN B1_GRUPO = '0010' THEN 'WINSUMOS' "+CRLF
cQuery += "     ELSE 'W'+D1_COD "+CRLF
cQuery += "     END"+CRLF
cQuery += "    ) AS PREVPROD,"+CRLF

cQuery += "    (CASE "+CRLF
cQuery += "    	WHEN D1_COD IN "+U_FBkVars(U_MVXVTPRD())+" THEN 'VT' "+CRLF
cQuery += "    	WHEN D1_COD IN "+U_FBkVars(U_MVXVRVAP())+" THEN 'VR/VA' "+CRLF
cQuery += "    	WHEN B1_GRUPO = '0008' THEN 'UNIFORME' "+CRLF
cQuery += "    	WHEN B1_GRUPO = '0009' THEN 'MATERIAL DE SEGURANCA' "+CRLF
cQuery += "    	WHEN B1_GRUPO = '0010' THEN 'INSUMOS' "+CRLF
cQuery += "     ELSE B1_DESC "+CRLF
cQuery += "     END"+CRLF
cQuery += "    ) AS PREVDESC"+CRLF

cQuery += "	INTO PowerBk.dbo.GASTOSGERAIS"+CRLF
cQuery += "	FROM DESPESAS"+CRLF
cQuery += " ORDER BY" + CRLF
cQuery += "      EMPRESA,CONTRATO,COMPETAM,D1_SERIE,D1_DOC" + CRLF

u_LogMemo("BKDASH01-GG.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  


//  Apaga a tabela GASTOSGERAIS da base PowerBk
cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.GASTOSGERAIS', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.GASTOSGERAIS "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1  += "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro1, cPerg)
	EndIf
EndIf

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2  += "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro2, cPerg)
	EndIf
EndIf

u_LogMemo("BKDASH01-GG.SQL",cErro1+cQueryD+cErro2+cQuery)

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


// Atualização da tabela GASTOSLIQFOL do banco de dados PowerBk (Movimento Bancario)
Static Function ProcDSGLF
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0
Local cEmpresa  := ""
Local cNomeEmp  := ""
local cCusBK    := U_MVXCUSBK()

Local cTabSZ2	:= "SZ2010"
Local cTabCTT	:= ""

Local cDescExm  := Posicione("SB1",1,xFilial("SB1")+U_MVXCEXMP(),"B1_DESC")
Local cDescDCH 	:= Posicione("SB1",1,xFilial("SB1")+U_MVXCDCH(),"B1_DESC")
Local cDescCBK	:= Posicione("SB1",1,xFilial("SB1")+cCusBK,"B1_DESC")

u_LogPrw(cPerg,"Liquidos de Folha")

For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabCTT := "CTT"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF
	cQuery += "  SUBSTRING(Z2_CC,1,9) AS CONTRATO, " + CRLF
	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
 	cQuery += "  SUBSTRING(Z2_DATAPGT,5,2)+'/'+SUBSTRING(Z2_DATAPGT,1,4) AS COMPET,"+CRLF
 	cQuery += "  SUBSTRING(Z2_DATAPGT,1,6) AS COMPETAM,"+CRLF
 	cQuery += "  CONVERT(DATE,SUBSTRING(Z2_DATAPGT,1,6)+'01',112) AS COMPETD,"+CRLF

	// Chave
	cQuery += "  ('"+cEmpresa+"' + "+CRLF
	cQuery += "   SUBSTRING(Z2_CC,1,9) + " + CRLF
	cQuery += "   SUBSTRING(Z2_DATAPGT,1,6)) AS CHAVE, " + CRLF

 	cQuery += "  Z2_PRONT,"+CRLF
 	cQuery += "  Z2_NOME,"+CRLF
 	cQuery += "  Z2_TIPO,"+CRLF
 	cQuery += "  Z2_TIPOPES,"+CRLF
 	cQuery += "  Z2_VALOR,"+CRLF
 	cQuery += "  UPPER(Z2_OBSTITU) AS Z2_OBSTITU,"+CRLF

	// PRODUTO CLT

	cQuery += "    (CASE "+CRLF
	cQuery += "    	WHEN Z2_TIPO = 'VT' THEN '12' "+CRLF
	cQuery += "    	WHEN Z2_TIPO IN ('VR','VA') THEN '14' "+CRLF
	cQuery += "    	WHEN Z2_TIPO = 'EXM' THEN '"+U_MVXCEXMP()+"'"+CRLF
	cQuery += "    	WHEN Z2_TIPO IN ('DCH','SOL','HOS','REE','CXA') THEN '"+U_MVXCDCH()+"'"+CRLF
	cQuery += "     ELSE Z2_TIPO "+CRLF
	cQuery += "     END"+CRLF
	cQuery += "    ) AS PRODUTO,"+CRLF

	cQuery += "    (CASE "+CRLF
	cQuery += "    	WHEN Z2_TIPO = 'VT' THEN 'VT' "+CRLF
	cQuery += "    	WHEN Z2_TIPO IN ('VR','VA') THEN 'VR/VA' "+CRLF
	cQuery += "    	WHEN Z2_TIPO = 'EXM' THEN '"+cDescExm+"'"+CRLF
	cQuery += "    	WHEN Z2_TIPO IN ('DCH','SOL','HOS','REE','CXA') THEN '"+cDescDCH+"'"+CRLF
	cQuery += "     ELSE Z2_TIPO "+CRLF
	cQuery += "     END"+CRLF
	cQuery += "    ) AS DESCPRD"+CRLF

	If nE = 1
		cQuery += "  INTO PowerBk.dbo.GASTOSLIQFOL  " + CRLF
	EndIf

	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabSZ2+" SZ2" + CRLF

	cQuery += "LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON (Z2_CC = CTT_CUSTO " + CRLF
	cQuery += " 		AND CTT_FILIAL = '01'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "WHERE Z2_FILIAL = '  ' " + CRLF
	cQuery += "      AND SZ2.D_E_L_E_T_ = '' " + CRLF
	cQuery += "      AND SZ2.Z2_CODEMP = '"+cEmpresa+"'" + CRLF
	cQuery += "      AND SZ2.Z2_TIPO IN ('EXM','VT','VR','VA','DCH','SOL','HOS','REE','CXA') " + CRLF
	cQuery += "      AND SZ2.Z2_TIPOPES = 'CLT' " + CRLF
	cQuery += "      AND SZ2.Z2_STATUS = 'S' " + CRLF

	cQuery += "UNION ALL "+CRLF

	cQuery += " SELECT "+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF
	cQuery += "  SUBSTRING(Z2_CC,1,9) AS CONTRATO, " + CRLF
	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
 	cQuery += "  SUBSTRING(Z2_DATAPGT,5,2)+'/'+SUBSTRING(Z2_DATAPGT,1,4) AS COMPET,"+CRLF
 	cQuery += "  SUBSTRING(Z2_DATAPGT,1,6) AS COMPETAM,"+CRLF
 	cQuery += "  CONVERT(DATE,SUBSTRING(Z2_DATAPGT,1,6)+'01',112) AS COMPETD,"+CRLF

	// Chave
	cQuery += "  ('"+cEmpresa+"' + "+CRLF
	cQuery += "   SUBSTRING(Z2_CC,1,9) + " + CRLF
	cQuery += "   SUBSTRING(Z2_DATAPGT,1,6)) AS CHAVE, " + CRLF

 	cQuery += "  Z2_PRONT,"+CRLF
 	cQuery += "  Z2_NOME,"+CRLF
 	cQuery += "  Z2_TIPO,"+CRLF
 	cQuery += "  Z2_TIPOPES,"+CRLF
 	cQuery += "  Z2_VALOR,"+CRLF
 	cQuery += "  UPPER(Z2_OBSTITU) AS Z2_OBSTITU,"+CRLF
	// PRODUTO AC/CLA
	cQuery += "  '"+cCusBK+"' AS PRODUTO,"+CRLF
	cQuery += "  '"+cDescCBK+"' AS DESCPRD"+CRLF

	cQuery += "FROM " + CRLF
	cQuery += "  "+cTabSZ2+" SZ2" + CRLF

	cQuery += "LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON (Z2_CC = CTT_CUSTO " + CRLF
	cQuery += " 		AND CTT_FILIAL = '01'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF

	cQuery += "WHERE Z2_FILIAL = '  ' " + CRLF
	cQuery += "      AND SZ2.D_E_L_E_T_ = '' " + CRLF
	cQuery += "      AND SZ2.Z2_CODEMP = '"+cEmpresa+"'" + CRLF
	cQuery += "      AND SZ2.Z2_TIPOPES IN ('AC','CLA') " + CRLF
	cQuery += "      AND SZ2.Z2_STATUS = 'S' " + CRLF

Next

//cQuery += " ORDER BY" + CRLF
//cQuery += "      EMPRESA,CONTRATO,COMPETAM,D1_SERIE,D1_DOC" + CRLF

u_LogMemo("BKDASH01-GLF.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

//Begin Transaction

	cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.GASTOSLIQFOL', N'U') IS NOT NULL"  
	cQueryD += "   DROP TABLE PowerBk.dbo.GASTOSLIQFOL "+CRLF
	nErro   := TcSqlExec(cQueryD)

	If nErro != 0
		cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		If !IsBlind()
			MsgStop(cErro1, cPerg)
		EndIf
	EndIf

	nErro   := TcSqlExec(cQuery)

	If nErro != 0
		cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		If !IsBlind()
			MsgStop(cErro2, cPerg)
		EndIf
	EndIf

//End Transaction

u_LogMemo("BKDASH01-GLF.SQL",cErro1+cQueryD+cErro2+cQuery)

Return





// Atualização da tabela PREVDESP1 do banco de dados PowerBk
Static Function ProcDSDP1
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0

Local cTabSZG   := ""

u_LogPrw(cPerg,"Previsão de despesas 1")
 
For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabSZG := "SZG"+cEmpresa+"0"
	cTabCTT := "CTT"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT"+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF
	cQuery += "  SUBSTRING(ZG_CONTRAT,1,9) AS CONTRATO,"+CRLF
	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
 	cQuery += "  SUBSTRING(ZG_DATA,5,2)+'/'+SUBSTRING(ZG_DATA,1,4) AS COMPET,"+CRLF
 	cQuery += "  SUBSTRING(ZG_DATA,1,6) AS COMPETAM,"+CRLF
 	cQuery += "  CONVERT(DATE,SUBSTRING(ZG_DATA,1,6)+'01',112) AS COMPETD,"+CRLF

	// Chave
	cQuery += "  '"+cEmpresa+"' + "+CRLF
	cQuery += "     SUBSTRING(ZG_CONTRAT,1,9) +  " + CRLF
	cQuery += "     SUBSTRING(ZG_DATA,1,6) AS CHAVE, " + CRLF
 	cQuery += "  SUBSTRING(ZG_DATA,1,6) + ZG_SEQ AS CHAVEZG,"+CRLF

   	cQuery += "  ZG_DATA,"+CRLF
   	cQuery += "  ZG_HORA,"+CRLF
   	cQuery += "  ZG_CLT,"+CRLF
   	cQuery += "  ZG_ENCSOC,"+CRLF
   	cQuery += "  ZG_VLENCSO,"+CRLF
   	cQuery += "  ZG_AJCUSTO,"+CRLF
   	cQuery += "  ZG_ENCAC,"+CRLF
   	cQuery += "  ZG_VLENAC,"+CRLF
   	cQuery += "  ZG_INSUMOS,"+CRLF
   	cQuery += "  ZG_BENEFIC,"+CRLF
   	cQuery += "  ZG_EQUIPAM,"+CRLF
   	cQuery += "  ZG_UNIFORM,"+CRLF
   	cQuery += "  ZG_DESPDIV,"+CRLF
   	cQuery += "  ZG_TRIBUTO,"+CRLF
   	cQuery += "  ZG_VLTRIBU,"+CRLF
   	cQuery += "  ZG_RENTABI,"+CRLF
   	cQuery += "  ZG_VLRENTA,"+CRLF
   	cQuery += "  ZG_TOTAL,"+CRLF
   	cQuery += "  ZG_USUARIO,"+CRLF
   	cQuery += "  ZG_SEQ,"+CRLF
   	cQuery += "  ZG_DATAI,"+CRLF
   	cQuery += "  ZG_HORAI"+CRLF
	If nE = 1
		cQuery += "  INTO PowerBk.dbo.PREVDESP1  " + CRLF
	EndIf
	cQuery += " FROM "+cTabSZG+" SZG " + CRLF
	cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON (ZG_CONTRAT = CTT_CUSTO " + CRLF
	cQuery += " 		AND CTT_FILIAL = '01'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF
	cQuery += " WHERE SZG.D_E_L_E_T_ = '' " + CRLF
Next
cQuery += " ORDER BY" + CRLF
cQuery += "      EMPRESA,CONTRATO,ZG_DATA,ZG_SEQ" + CRLF

u_LogMemo("BKDASH01-PVD1.SQL",cQuery)

If !TCIsConnected()
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

//Begin Transaction

	cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.PREVDESP1', N'U') IS NOT NULL"  
	cQueryD += "   DROP TABLE PowerBk.dbo.PREVDESP1 "+CRLF
	nErro   := TcSqlExec(cQueryD)

	If nErro != 0
		cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		If !IsBlind()
			MsgStop(cErro1, cPerg)
		EndIf
	EndIf

	nErro   := TcSqlExec(cQuery)

	If nErro != 0
		cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		If !IsBlind()
			MsgStop(cErro2, cPerg)
		EndIf
	EndIf


//End Transaction

u_LogMemo("BKDASH01-PVD1.SQL",cErro1+cQueryD+cErro2+cQuery)

Return

// Atualização da tabela PREVDESP2 do banco de dados PowerBk
Static Function ProcDSDP2
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aEmpresas := u_BKGrpGct()
Local nE 		:= 0

Local cTabSZL   := ""

u_LogPrw(cPerg,"Previsão de despesas 2")
 
For nE := 1 TO Len(aEmpresas)

	cEmpresa := aEmpresas[nE,1]
	cNomeEmp := aEmpresas[nE,2]

	cTabSZL := "SZL"+cEmpresa+"0"
	cTabCTT := "CTT"+cEmpresa+"0"

	If nE > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

	cQuery += " SELECT"+CRLF
	cQuery += "  '"+cEmpresa+"' AS EMPRESA,"+CRLF
	cQuery += "  '"+cNomeEmp+"' AS NOMEEMP,"+CRLF
	cQuery += "  GETDATE() AS DATAPRC,"+CRLF
	cQuery += "  SUBSTRING(ZL_CONTRAT,1,9) AS CONTRATO,"+CRLF
	cQuery += "  CTT_DESC01 AS DESCRICAO, " + CRLF
 	cQuery += "  SUBSTRING(ZL_DATA,5,2)+'/'+SUBSTRING(ZL_DATA,1,4) AS COMPET,"+CRLF
 	cQuery += "  SUBSTRING(ZL_DATA,1,6) AS COMPETAM,"+CRLF
 	cQuery += "  CONVERT(DATE,SUBSTRING(ZL_DATA,1,6)+'01',112) AS COMPETD,"+CRLF

	// Chave
	cQuery += "  '"+cEmpresa+"' + "+CRLF
	cQuery += "     SUBSTRING(ZL_CONTRAT,1,9) +  " + CRLF
	cQuery += "     SUBSTRING(ZL_DATA,1,6) AS CHAVE, " + CRLF
 	cQuery += "  SUBSTRING(ZL_DATA,1,6) + ZL_SEQ AS CHAVEZG,"+CRLF

   	cQuery += "  ZL_TIPO,"+CRLF
	cQuery += "  (CASE WHEN ZL_TIPO = '01' THEN 'BENEFICIOS' ELSE 'GASTOS GERAIS' END) AS ZLDESCTIPO,"
   	cQuery += "  ZL_DATA,"+CRLF
   	cQuery += "  ZL_HORA,"+CRLF
   	cQuery += "  ZL_CODIGO,"+CRLF
   	cQuery += "  ZL_DESC,"+CRLF
   	cQuery += "  ZL_VALOR,"+CRLF
   	cQuery += "  ZL_SEQ"+CRLF
	If nE = 1
		cQuery += "  INTO PowerBk.dbo.PREVDESP2  " + CRLF
	EndIf
	cQuery += " FROM "+cTabSZL+" SZL " + CRLF
	cQuery += " LEFT JOIN "+cTabCTT+" CTT" + CRLF
	cQuery += "     ON (ZL_CONTRAT = CTT_CUSTO " + CRLF
	cQuery += " 		AND CTT_FILIAL = '01'" + CRLF
	cQuery += "         AND CTT.D_E_L_E_T_ = ''" + CRLF
	cQuery += "  ) " + CRLF
	cQuery += " WHERE SZL.D_E_L_E_T_ = '' AND ZL_DATA <> ''" + CRLF
Next
cQuery += " ORDER BY" + CRLF
cQuery += "      EMPRESA,CONTRATO,ZL_DATA,ZL_SEQ" + CRLF

u_LogMemo("BKDASH01-PVD2.SQL",cQuery)

If !TCIsConnected()
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

//Begin Transaction

	cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.PREVDESP2', N'U') IS NOT NULL"  
	cQueryD += "   DROP TABLE PowerBk.dbo.PREVDESP2 "+CRLF
	nErro   := TcSqlExec(cQueryD)

	If nErro != 0
		cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		If !IsBlind()
			MsgStop(cErro1, cPerg)
		EndIf
	EndIf

	nErro   := TcSqlExec(cQuery)

	If nErro != 0
		cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		If !IsBlind()
			MsgStop(cErro2, cPerg)
		EndIf
	EndIf

//End Transaction

u_LogMemo("BKDASH01-PVD2.SQL",cErro1+cQueryD+cErro2+cQuery)

Return


// Atualização da tabela GERAL do banco de dados PowerBk
Static Function ProcDSGER
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""

u_LogPrw(cPerg,"Geral")

BEGINCONTENT VAR cQuery
WITH GER AS (
SELECT 
	FG.EMPRESA AS EMPRESA,
	FG.NOMEEMP AS NOMEEMP,
	GETDATE() AS DATAPRC,
	FG.CONTRATO AS CONTRATO,
	FG.DESCRICAO,
	G.CN9_XXNRBK,
	FG.COMPETAM,
	FG.COMPET,
	FG.COMPETD,
	FG.EMPRESA + FG.CONTRATO + FG.COMPETAM AS CHAVE,
	SUM(FG.VALFAT) AS VALFAT,
	SUM(FG.F2VALLIQ) AS F2VALLIQ,
	SUM(FG.PREVFAT) AS PREVFAT,
	SUM(FG.DESPESA) AS DESPESAS,
	SUM(FG.CUSTO) AS CUSTOS,
	CHAVEZG
FROM 
	-- FATURAMENTO
	(SELECT 
		EMPRESA,
		NOMEEMP,
		CONTRATO,
		DESCRICAO,
		COMPETAM,
		COMPET,
		COMPETD,
		CHAVEZG,
		SUM(VALFAT) AS VALFAT,
		SUM(F2VALLIQ) AS F2VALLIQ,
		SUM(CXN_VLPREV) AS PREVFAT,
		0 AS DESPESA,
		0 AS CUSTO

		--(SELECT TOP 1 ZGCHAVE FROM 
		--	(SELECT MAX(COMPETAM+ZG_SEQ) AS ZGCHAVE
		--	FROM PowerBk.dbo.PREVDESP1 
		--	WHERE PREVDESP1.EMPRESA = FATURAMENTO.EMPRESA AND PREVDESP1.CONTRATO = FATURAMENTO.CONTRATO AND PREVDESP1.COMPETAM <= FATURAMENTO.COMPETAM
		--	GROUP BY PREVDESP1.CONTRATO,PREVDESP1.ZG_DATA
		--	) AS X
		--	ORDER BY ZGCHAVE DESC) AS CHAVEZG1

		FROM PowerBk.dbo.FATURAMENTO
		GROUP BY EMPRESA,NOMEEMP,CONTRATO,DESCRICAO,COMPETAM,COMPET,COMPETD,CHAVEZG
	UNION ALL
	-- DESPESAS
	SELECT 
		EMPRESA,
		NOMEEMP,
		CONTRATO,
		DESCRICAO,
		COMPETAM,
		COMPET,
		COMPETD,
		CHAVEZG,
		0 AS VALFAT,
		0 AS F2VALLIQ,
		0 AS PREVFAT,
		SUM(DESPESA) AS DESPESA,
		0 AS CUSTO
		--(SELECT TOP 1 ZGCHAVE FROM 
		--	(SELECT MAX(COMPETAM+ZG_SEQ) AS ZGCHAVE
		--	FROM PowerBk.dbo.PREVDESP1 
		--	WHERE PREVDESP1.EMPRESA = GASTOSGERAIS.EMPRESA AND PREVDESP1.CONTRATO = GASTOSGERAIS.CONTRATO AND PREVDESP1.COMPETAM <= GASTOSGERAIS.COMPETAM
		--	GROUP BY PREVDESP1.CONTRATO,PREVDESP1.ZG_DATA
		--	) AS X
		--	ORDER BY ZGCHAVE DESC) AS CHAVEZG1

		FROM PowerBk.dbo.GASTOSGERAIS
			GROUP BY EMPRESA,NOMEEMP,CONTRATO,DESCRICAO,COMPETAM,COMPET,COMPETD,CHAVEZG

	UNION ALL
	-- FOLHA
	SELECT 
		EMPRESA,
		NOMEEMP,
		CONTRATO,
		DESCRICAO,
		COMPETAM,
		SUBSTRING(COMPETAM,5,2) + '/' + SUBSTRING(COMPETAM,1,4) AS COMPET,
	    CONVERT(DATE,COMPETAM+'01',112) AS COMPETD,
		CHAVEZG,
		0 AS VALFAT,
		0 AS F2VALLIQ,
		0 AS PREVFAT,
		0 AS DESPESA,
		SUM(CUSTO) AS CUSTO
		FROM PowerBk.dbo.FOLHA
			GROUP BY EMPRESA,NOMEEMP,CONTRATO,DESCRICAO,COMPETAM,CHAVEZG
		) AS FG
	LEFT JOIN PowerBk.dbo.GESTORES G
  	ON	G.EMPRESA  = FG.EMPRESA 
	AND G.CONTRATO = FG.CONTRATO 
	GROUP BY FG.EMPRESA,FG.NOMEEMP,FG.CONTRATO,FG.DESCRICAO,FG.COMPETAM,FG.COMPET,FG.COMPETD,G.CN9_XXNRBK,CHAVEZG)

SELECT 
GER.* ,
GER.F2VALLIQ - GER.DESPESAS - GER.CUSTOS AS RESULTADO,
PDP1.ZG_CLT + PDP1.ZG_BENEFIC AS PREVCUSTOS,
PDP1.ZG_DESPDIV AS PREVDESP,
PDP1.ZG_DESPDIV * 0.9 AS PREVDESP09,
PDP1.ZG_DESPDIV * 1.2 AS PREVDESP12,
PDP1.ZG_VLRENTA AS PREVRESULT
  	--PDP1.ZG_DATA,
  	--PDP1.ZG_SEQ,
  	--PDP1.ZG_CLT,
  	--PDP1.ZG_ENCSOC,
  	--PDP1.ZG_VLENCSO,
  	--PDP1.ZG_AJCUSTO,
  	--PDP1.ZG_ENCAC,
  	--PDP1.ZG_VLENAC,
  	--PDP1.ZG_INSUMOS,
  	--PDP1.ZG_BENEFIC,
  	--PDP1.ZG_EQUIPAM,
  	--PDP1.ZG_UNIFORM,
  	--PDP1.ZG_DESPDIV,
  	--PDP1.ZG_TRIBUTO,
  	--PDP1.ZG_VLTRIBU,
  	--PDP1.ZG_RENTABI,
  	--PDP1.ZG_VLRENTA,
  	--PDP1.ZG_TOTAL
INTO PowerBk.dbo.GERAL
FROM GER
OUTER APPLY (SELECT TOP 1 * FROM PowerBk.dbo.PREVDESP1 PDP1 WHERE
GER.EMPRESA  = PDP1.EMPRESA AND 
GER.CONTRATO = PDP1.CONTRATO AND 
GER.CHAVEZG  = PDP1.COMPETAM+PDP1.ZG_SEQ) AS PDP1
ORDER BY GER.EMPRESA,GER.CONTRATO,GER.COMPETAM

ENDCONTENT

u_LogMemo("BKDASH01-G.SQL",cQuery)

If !TCIsConnected() 
  MsgAlert( "Sem conexão com o banco de dados", cPerg )
  Return( Nil )
Endif  

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.GERAL', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.GERAL "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro1, cPerg)
	EndIf
EndIf

nErro   := TcSqlExec(cQuery)

If nErro != 0
	cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro2, cPerg)
	EndIf
EndIf

u_LogMemo("BKDASH01-G.SQL",cErro1+cQueryD+cErro2+cQuery)

Return

// Atualização da tabela EMPRESAS do banco de dados PowerBk
Static Function ProcDSEmp
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local nX 		:= 0
Local aEmpresas := U_BKEmpr()

u_LogPrw(cPerg,"Empresas")

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.EMPRESAS', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.EMPRESAS "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro1, cPerg)
	EndIf
EndIf

cQuery := "CREATE TABLE PowerBk.dbo.EMPRESAS " + CRLF
cQuery += "( " + CRLF
cQuery += "  EMPRESA VARCHAR(02), " + CRLF
cQuery += "  NOMEEMP VARCHAR(15), " + CRLF
cQuery += "  PRIMARY KEY (EMPRESA)" + CRLF
cQuery += ") " + CRLF

nErro   := TcSqlExec(cQuery)
If nErro != 0
	cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro2, cPerg)
	EndIf
EndIf

For nX := 1 To Len(aEmpresas)
    // Popula elemento
    cQuery := "INSERT INTO PowerBk.dbo.EMPRESAS " + CRLF
    cQuery += "("         + CRLF
    cQuery += "EMPRESA,"  + CRLF
    cQuery += "NOMEEMP"   + CRLF
    cQuery += ")"         + CRLF
    cQuery += "VALUES"    + CRLF
    cQuery += "("         + CRLF
    cQuery += "'" + aEmpresas[nX,1] + "',"    + CRLF
    cQuery += "'" + aEmpresas[nX,2] + "'"    + CRLF
    cQuery += ")"

	nErro   := TcSqlExec(cQuery)
	If nErro != 0
		cErro2  += "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		If !IsBlind()
			MsgStop(cErro2, cPerg)
		EndIf
	EndIf
Next nX

u_LogMemo("BKDASH01-EMP.SQL",cErro1+cQueryD+cErro2+cQuery)
Return



// Atualização da tabela USUARIOS do banco de dados PowerBk
Static Function ProcDSUsr
Local cQuery	:= ""
Local cQueryD	:= ""
Local nErro 	:= 0
Local cErro1 	:= ""
Local cErro2 	:= ""
Local aUsers    := AllUsers()
Local aGrupos   := AllGroups()
Local aGrpUsr   := {}
Local nZ 		:= 0
Local nX 		:= 0
Local xUsrCodigo:= ""
Local xUsrConta := ""
Local xUsrSenha := ""
Local xUsrNome  := ""
Local xUsrEmail := ""
Local xUsrGrupo := ""
Local xUsrDepto := ""
Local xUsrBloq  := ""
Local xUsrUltLog:= ""
Local nPosGrp   := 0

u_LogPrw(cPerg,"Usuários")

cQueryD := "IF OBJECT_ID(N'PowerBk.dbo.USUARIOS', N'U') IS NOT NULL"  
cQueryD += "   DROP TABLE PowerBk.dbo.USUARIOS "+CRLF
nErro   := TcSqlExec(cQueryD)

If nErro != 0
	cErro1  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro1, cPerg)
	EndIf
EndIf


cQuery := "CREATE TABLE PowerBk.dbo.USUARIOS " + CRLF
cQuery += "( " + CRLF
cQuery += "  CODIGO    VARCHAR(06), " + CRLF
cQuery += "  USUARIO   VARCHAR(50), " + CRLF
cQuery += "  NOME      VARCHAR(50), " + CRLF
cQuery += "  EMAIL     VARCHAR(50), " + CRLF
cQuery += "  GRUPO     VARCHAR(50), " + CRLF
cQuery += "  SENHA     VARCHAR(100)," + CRLF
cQuery += "  DEPTO     VARCHAR(100)," + CRLF
cQuery += "  ULTLOG    VARCHAR(100)," + CRLF
cQuery += "  BLOQUEADO VARCHAR(03), " + CRLF    
cQuery += "  DTRUN     VARCHAR(50), " + CRLF
cQuery += "  PRIMARY KEY (CODIGO)         " + CRLF
cQuery += ") " + CRLF

nErro   := TcSqlExec(cQuery)
If nErro != 0
	cErro2  := "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
	If !IsBlind()
		MsgStop(cErro2, cPerg)
	EndIf
EndIf

For nX := 1 To Len(aUsers)
    // Popula elemento
    xUsrCodigo   := aUsers[nX][01][01]                                           //CODIGO
    xUsrConta    := Upper(FWSFUser(xUsrCodigo,"DATAUSER","USR_CODIGO",.F.))      //USUARIO
    xUsrSenha    := RTrim(FWSFUser(xUsrCodigo,"DATAUSER","USR_PSWMD5",.F.))      //SENHA
    xUsrNome     := Upper(FWSFUser(xUsrCodigo,"DATAUSER","USR_NOME",.F.))        //NOME
    xUsrEmail    := Upper(FWSFUser(xUsrCodigo,"DATAUSER","USR_EMAIL",.F.))       //EMAIL
    xUsrGrupo    := ""
    xUsrDepto    := Upper(FWSFUser(xUsrCodigo,"DATAUSER","USR_DEPTO",.F.))       //DEPARTAMENTO
    xUsrBloq     := RTrim(FWSFUser(xUsrCodigo,"DATAUSER","USR_MSBLQL",.F.))      //BLOQUEADO
    xUsrUltLog   := FWUsrUltLog(xUsrCodigo)                                      //INFORMACOES DE LOGIN

    // Obtem grupos de acesso do usuario
    aGrpUsr := aUsers[nX][01][10]
    For nZ := 1 To Len(aGrpUsr)
        nPosGrp   := aScan(aGrupos, {|elem|AllTrim(elem[1][1]) == AllTrim(aGrpUsr[nZ])})
        xUsrGrupo += Upper(AllTrim(aGrupos[nPosGrp][1][2])) + "#"
    Next nZ
    cQuery := "INSERT INTO PowerBk.dbo.USUARIOS " + CRLF
    cQuery += "("         + CRLF
    cQuery += "CODIGO,"   + CRLF
    cQuery += "USUARIO,"  + CRLF
    cQuery += "NOME,"     + CRLF
    cQuery += "EMAIL,"    + CRLF
    cQuery += "GRUPO,"    + CRLF
    cQuery += "SENHA,"    + CRLF
    cQuery += "DEPTO,"    + CRLF
    cQuery += "ULTLOG,"   + CRLF
    cQuery += "BLOQUEADO,"+ CRLF
    cQuery += "DTRUN"     + CRLF
    cQuery += ")"         + CRLF
    cQuery += "VALUES"    + CRLF
    cQuery += "("         + CRLF
    cQuery += "'" + xUsrCodigo   + "',"    + CRLF
    cQuery += "'" + xUsrConta    + "',"    + CRLF
    cQuery += "'" + xUsrNome     + "',"    + CRLF
    cQuery += "'" + xUsrEmail    + "',"    + CRLF
    cQuery += "'" + xUsrGrupo    + "',"    + CRLF
    cQuery += "'" + xUsrSenha    + "',"    + CRLF
    cQuery += "'" + xUsrDepto    + "',"    + CRLF    
    cQuery += "'" + "DATA: " + DtoC(xUsrUltLog[1]) + " HORA: " + xUsrUltLog[2] + " WORKSTATION: " + xUsrUltLog[4] + "'," + CRLF
    cQuery += "'" + IIf( xUsrBloq == "1", "SIM", "NAO" ) + "'," + CRLF                 
    cQuery += "'" + DtoC(Date()) + "'  " + CRLF
    cQuery += ")"

	nErro   := TcSqlExec(cQuery)
	If nErro != 0
		cErro2  += "/* Erro na atualização: "+ CRLF + TcSqlError() + " */" +  CRLF
		If !IsBlind()
			MsgStop(cErro2, cPerg)
		EndIf
	EndIf
Next nX

u_LogMemo("BKDASH01-USR.SQL",cErro1+cQueryD+cErro2+cQuery)
Return


/*


WITH DESPESAS AS (
 SELECT 
  '01' AS EMPRESA,
  'BK' AS NOMEEMP,
  GETDATE() AS DATAPRC,
  SUBSTRING(D1_CC,1,9) AS CONTRATO, 
  CTT_DESC01 AS DESCRICAO, 
  SUBSTRING(E2_VENCREA,5,2)+'/'+SUBSTRING(E2_VENCREA,1,4) AS COMPET,
  SUBSTRING(E2_VENCREA,1,6) AS COMPETAM,
  CONVERT(DATE,SUBSTRING(E2_VENCREA,1,6)+'01',112) AS COMPETD,
  '01' + 
     SUBSTRING(D1_CC,1,9) +  
     SUBSTRING(E2_VENCREA,5,2)+'/'+SUBSTRING(E2_VENCREA,1,4)  AS CHAVE, 
  D1_FILIAL,
  D1_SERIE,
  D1_DOC,
  D1_FORNECE,
  D1_LOJA,
  D1_ITEM,
  D1_COD,
  CONVERT(VARCHAR(600),CONVERT(Binary(600),D1_XXHIST)) D1_XXHIST,
  B1_DESC,
  B1_GRUPO,
  F1_VALBRUT,
  F1_XXUSER,
  (SELECT TOP 1 USUARIOS.NOME FROM PowerBk.dbo.USUARIOS USUARIOS WHERE F1_XXUSER = USUARIOS.CODIGO) AS F1RESPON,
  F1_XXULIB,
  (SELECT TOP 1 USUARIOS.NOME FROM PowerBk.dbo.USUARIOS USUARIOS WHERE F1_XXULIB = USUARIOS.CODIGO) AS F1APROV,
  E2_PARCELA,
  E2_VALOR,
  E2_DESCONT,
  E2_MULTA,
  E2_JUROS,
  E2_ACRESC,
  E2_DECRESC,
  E2_VRETPIS,
  E2_VRETCOF,
  E2_VRETCSL,
  E2_VRETINS,
  E2_VRETIRF,
  E2_VRETISS,
  E2_VALOR+E2_VRETPIS+E2_VRETCOF+E2_VRETCSL+E2_VRETINS+E2_VRETIRF+E2_VRETISS AS E2VALTIT,
  (D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC)  AS D1TOTAL,
  CASE WHEN E2_ACRESC  > 0 THEN E2_ACRESC  ELSE E2_MULTA+E2_JUROS END - 
  	CASE WHEN E2_DECRESC > 0 THEN E2_DECRESC ELSE E2_DESCONT END AS E2ACDEC
FROM 
  SD1010 SD1
 INNER JOIN SB1010 SB1
     ON (B1_COD = D1_COD 
         AND B1_FILIAL = '01' 
         AND SB1.D_E_L_E_T_ = ''
  ) 
 INNER JOIN SE2010 SE2
     ON (E2_TIPO = 'NF' 
         AND E2_PREFIXO = D1_SERIE
         AND E2_NUM = D1_DOC
         AND E2_FORNECE = D1_FORNECE
         AND E2_LOJA = D1_LOJA
         AND E2_FILIAL = '01' 
         AND SE2.D_E_L_E_T_ = ''
  ) 
 INNER JOIN SF1010 SF1
     ON (F1_SERIE = D1_SERIE
         AND F1_DOC = D1_DOC
         AND F1_FORNECE = D1_FORNECE
         AND F1_LOJA = D1_LOJA
         AND F1_FILIAL = D1_FILIAL 
         AND SF1.D_E_L_E_T_ = ''
  ) 
 LEFT JOIN CTT010 CTT
     ON (D1_CC = CTT_CUSTO 
 		AND CTT_FILIAL = '01'
         AND CTT.D_E_L_E_T_ = ''
  ) 
WHERE SD1.D1_FILIAL = '01' 
      AND SD1.D_E_L_E_T_ = '' 
      AND (SUBSTRING(B1_CONTA,1,1) = '3'
      	OR B1_CONTA IN ('29104004') 
      	OR SUBSTRING(B1_CONTA,1,5) IN ('12201','12105')) 
AND 1 = CASE WHEN D1_CC = 313000504 AND D1_FORNECE = '002918' THEN 0 ELSE 1 END
UNION ALL 
 SELECT 
  '01' AS EMPRESA,
  'BK' AS NOMEEMP,
  GETDATE() AS DATAPRC,
  CASE 
  	WHEN E5_CCD = ' ' THEN E5_CCC 
  	WHEN E5_CCC = ' ' THEN E5_CCD 
  END AS CONTRATO, 
  CTT_DESC01 AS DESCRICAO, 
  SUBSTRING(E5_VENCTO,5,2)+'/'+SUBSTRING(E5_VENCTO,1,4) AS COMPET,
  SUBSTRING(E5_VENCTO,1,6) AS COMPETAM,
  CONVERT(DATE,SUBSTRING(E5_VENCTO,1,6)+'01',112) AS COMPETD,
  '01' + 
  	CASE 
  		WHEN E5_CCD = ' ' THEN E5_CCC 
  		WHEN E5_CCC = ' ' THEN E5_CCD 
  	END + 
     SUBSTRING(E5_VENCTO,5,2)+'/'+SUBSTRING(E5_VENCTO,1,4)  AS CHAVE, 
     E5_FILIAL  AS D1_FILIAL, 
     E5_PREFIXO AS D1_SERIE, 
     E5_NUMERO  AS D1_DOC, 
     E5_CLIFOR  AS D1_FORNECE, 
     E5_LOJA    AS D1_LOJA, 
     '0001'     AS D1_ITEM, 
     SUBSTRING(CT1_DESC01,1,15) AS D1_COD, 
     ' '        AS D1_XXHIST, 
     CT1_DESC01 AS B1_DESC, 
     ' '        AS B1_GRUPO, 
     E5_VALOR * (CASE WHEN E5_RECPAG = 'R' THEN -1 ELSE 1 END) AS F1_VALBRUT, 
     ' '        AS F1_XXUSER, 
     ' '        AS F1RESPON, 
     ' '        AS F1_XXULIB, 
     ' '        AS F1APROV, 
     E5_PARCELA AS E2_PARCELA, 
     E5_VALOR * (CASE WHEN E5_RECPAG = 'R' THEN -1 ELSE 1 END) AS E2_VALOR, 
     E5_VLDESCO AS E2_DESCONT, 
     E5_VLMULTA AS E2_MULTA, 
     E5_VLJUROS AS E2_JUROS, 
     E5_VLACRES AS E2_ACRESC, 
     E5_VLDECRE AS E2_DECRESC, 
     E5_VRETPIS AS E2_VRETPIS, 
     E5_VRETCOF AS E2_VRETCOF, 
     E5_VRETCSL AS E2_VRETCSL, 
     E5_VRETINS AS E2_VRETINS, 
     E5_VRETIRF AS E2_VRETIRF, 
     E5_VRETISS AS E2_VRETISS, 
     E5_VALOR * (CASE WHEN E5_RECPAG = 'R' THEN -1 ELSE 1 END) AS E2VALTIT, 
     E5_VALOR * (CASE WHEN E5_RECPAG = 'R' THEN -1 ELSE 1 END) AS D1TOTAL, 
     CASE WHEN E5_VLACRES > 0 THEN E5_VLACRES ELSE E5_VLMULTA+E5_VLJUROS END -  
     	CASE WHEN E5_VLDECRE > 0 THEN E5_VLDECRE ELSE E5_VLDESCO END AS E2ACDEC 
FROM 
  SE5010 SE5
LEFT JOIN CTT010 CTT
     ON (  	    CASE 
  		   WHEN E5_CCD = ' ' THEN E5_CCC 
  		   WHEN E5_CCC = ' ' THEN E5_CCD 
  	    END = CTT_CUSTO 
 		AND CTT_FILIAL = '01'
         AND CTT.D_E_L_E_T_ = ''
  ) 
LEFT JOIN CT1010 CT1
     ON ( 
        (CT1_CONTA = E5_DEBITO OR CT1_CONTA = E5_CREDITO)
 	   AND CT1_FILIAL = '  '
        AND CT1.D_E_L_E_T_=''
  ) 
WHERE SE5.E5_FILIAL = '01' 
      AND SE5.D_E_L_E_T_ = '' 
      AND (SUBSTRING(E5_DEBITO,1,1)='3' OR SUBSTRING(E5_CREDITO,1,1)='3' )
      AND E5_SITUACA <> 'C' 
      AND (E5_CCC <> ' ' OR E5_CCD <> '  ') 
      AND (SUBSTRING(E5_CCC,1,3) <> '000' AND SUBSTRING(E5_CCD,1,3) <> '000') 
union all
 SELECT 
  '01' AS EMPRESA,
  'BK' AS NOMEEMP,
  GETDATE() AS DATAPRC,
  SUBSTRING(Z2_CC,1,9) AS CONTRATO, 
  CTT_DESC01 AS DESCRICAO, 
  SUBSTRING(Z2_DATAPGT,5,2)+'/'+SUBSTRING(Z2_DATAPGT,1,4) AS COMPET,
  SUBSTRING(Z2_DATAPGT,1,6) AS COMPETAM,
  CONVERT(DATE,SUBSTRING(Z2_DATAPGT,1,6)+'01',112) AS COMPETD,
  ('01' + 
   SUBSTRING(Z2_CC,1,9) + 
   SUBSTRING(Z2_DATAPGT,5,2)+'/'+SUBSTRING(Z2_DATAPGT,1,4))  AS CHAVE, 
  Z2_FILIAL   AS D1_FILIAL,
  Z2_E2PRF	  AS D1_SERIE,
  Z2_E2NUM    AS D1_DOC,
  Z2_E2FORN   AS D1_FORNECE,
  Z2_E2LOJA   AS D1_LOJA,
  '0001'      AS D1_ITEM,
  (CASE 
   	WHEN Z2_TIPO = 'VT' THEN '12' 
   	WHEN Z2_TIPO IN ('VR','VA') THEN '14' 
   	WHEN Z2_TIPO = 'EXM' THEN '41201015'
   	WHEN Z2_TIPO IN ('DCH','SOL','HOS','REE','CXA') THEN '34202003'
    ELSE Z2_TIPO 
   END
   ) AS D1_COD,
  RTRIM(Z2_NOME)+': '+RTRIM(Z2_OBSTITU)  AS D1_XXHIST,
  (CASE 
   	WHEN Z2_TIPO = 'VT' THEN 'VT' 
   	WHEN Z2_TIPO IN ('VR','VA') THEN 'VR/VA' 
   	WHEN Z2_TIPO = 'EXM' THEN 'EXAMES MEDICOS                                              '
   	WHEN Z2_TIPO IN ('DCH','SOL','HOS','REE','CXA') THEN 'DIARIA DE CAMPO / HOSPEDAGEM                                '
    ELSE Z2_TIPO 
   END
  ) AS B1_DESC,
  ' '         AS B1_GRUPO, 
  Z2_VALOR    AS F1_VALBRUT,
  (SELECT TOP 1 USUARIOS.CODIGO FROM PowerBk.dbo.USUARIOS USUARIOS WHERE UPPER(Z2_USUARIO) = USUARIOS.NOME OR UPPER(Z2_USUARIO) = USUARIOS.USUARIO) AS F1_XXUSER, 
  UPPER(Z2_USUARIO)  AS F1_RESPON,
  (SELECT TOP 1 USUARIOS.CODIGO FROM PowerBk.dbo.USUARIOS USUARIOS WHERE UPPER(Z2_USUARIO) = USUARIOS.NOME OR UPPER(Z2_USUARIO) = USUARIOS.USUARIO) AS F1_XXULIB, 
  UPPER(Z2_USUARIO)  AS F1_APROV,
  '  '        AS E2_PARCELA,
  Z2_VALOR    AS E2_VALOR,
  0           AS E2_DESCONT,
  0           AS E2_MULTA,
  0           AS E2_JUROS,
  0           AS E2_ACESC,
  0           AS E2_DECRESC,
  0           AS E2_VRETPIS,
  0           AS E2_VRETCOF,
  0           AS E2_VRETCSL,
  0           AS E2_VRETINS,
  0           AS E2_VRETIRF,
  0           AS E2_VRETISS,
  Z2_VALOR    AS E2VALTIT,
  Z2_VALOR    AS D1TOTAL,
  0           AS E2ACDEC



  --Z2_PRONT,
  --Z2_NOME,
  --Z2_TIPO,
  --Z2_TIPOPES,
  --Z2_VALOR,
  --UPPER(Z2_OBSTITU) AS Z2_OBSTITU,


FROM 
  SZ2010 SZ2
LEFT JOIN CTT010 CTT
     ON (Z2_CC = CTT_CUSTO 
 		AND CTT_FILIAL = '01'
         AND CTT.D_E_L_E_T_ = ''
  ) 
WHERE Z2_FILIAL = '  ' 
      AND SZ2.D_E_L_E_T_ = '' 
      AND SZ2.Z2_CODEMP = '01'
      AND SZ2.Z2_TIPO IN ('EXM','VT','VR','VA','DCH','SOL','HOS','REE','CXA') 
      AND SZ2.Z2_TIPOPES = 'CLT' 
      AND SZ2.Z2_STATUS = 'S' 
UNION ALL 
 SELECT 
  '01' AS EMPRESA,
  'BK' AS NOMEEMP,
  GETDATE() AS DATAPRC,
  SUBSTRING(Z2_CC,1,9) AS CONTRATO, 
  CTT_DESC01 AS DESCRICAO, 
  SUBSTRING(Z2_DATAPGT,5,2)+'/'+SUBSTRING(Z2_DATAPGT,1,4) AS COMPET,
  SUBSTRING(Z2_DATAPGT,1,6) AS COMPETAM,
  CONVERT(DATE,SUBSTRING(Z2_DATAPGT,1,6)+'01',112) AS COMPETD,
  ('01' + 
   SUBSTRING(Z2_CC,1,9) + 
   SUBSTRING(Z2_DATAPGT,5,2)+'/'+SUBSTRING(Z2_DATAPGT,1,4))  AS CHAVE, 
  Z2_FILIAL   AS D1_FILIAL,
  Z2_E2PRF	  AS D1_SERIE,
  Z2_E2NUM    AS D1_DOC,
  Z2_E2FORN   AS D1_FORNECE,
  Z2_E2LOJA   AS D1_LOJA,
  '0001'      AS D1_ITEM,
  '29104004'  AS D1_COD,
  RTRIM(Z2_NOME)+': '+RTRIM(Z2_OBSTITU)  AS D1_XXHIST,
  'CUSTO BK' AS B1_DESC,
  ' '         AS B1_GRUPO, 
  Z2_VALOR    AS F1_VALBRUT,
  (SELECT TOP 1 USUARIOS.CODIGO FROM PowerBk.dbo.USUARIOS USUARIOS WHERE UPPER(Z2_USUARIO) = USUARIOS.NOME OR UPPER(Z2_USUARIO) = USUARIOS.USUARIO) AS F1_XXUSER, 
  Z2_USUARIO  AS F1_RESPON,
  (SELECT TOP 1 USUARIOS.CODIGO FROM PowerBk.dbo.USUARIOS USUARIOS WHERE UPPER(Z2_USUARIO) = USUARIOS.NOME OR UPPER(Z2_USUARIO) = USUARIOS.USUARIO) AS F1_XXULIB, 
  Z2_USUARIO  AS F1_APROV,
  '  '        AS E2_PARCELA,
  Z2_VALOR    AS E2_VALOR,
  0           AS E2_DESCONT,
  0           AS E2_MULTA,
  0           AS E2_JUROS,
  0           AS E2_ACESC,
  0           AS E2_DECRESC,
  0           AS E2_VRETPIS,
  0           AS E2_VRETCOF,
  0           AS E2_VRETCSL,
  0           AS E2_VRETINS,
  0           AS E2_VRETIRF,
  0           AS E2_VRETISS,
  Z2_VALOR    AS E2VALTIT,
  Z2_VALOR    AS D1TOTAL,
  0           AS E2ACDEC

FROM 
  SZ2010 SZ2
LEFT JOIN CTT010 CTT
     ON (Z2_CC = CTT_CUSTO 
 		AND CTT_FILIAL = '01'
         AND CTT.D_E_L_E_T_ = ''
  ) 
WHERE Z2_FILIAL = '  ' 
      AND SZ2.D_E_L_E_T_ = '' 
      AND SZ2.Z2_CODEMP = '01'
      AND SZ2.Z2_TIPOPES IN ('AC','CLA') 
      AND SZ2.Z2_STATUS = 'S' 

)
	select * 
	FROM DESPESAS
 ORDER BY
      EMPRESA,CONTRATO,COMPETAM,D1_SERIE,D1_DOC

*/

