#include "PROTHEUS.CH"
#include "TopConn.ch"
#include "RwMake.ch" 

/*/{Protheus.doc} BKESTA04
BK - Importar planilha para inclusão e geração do Termo de Responsabilidade de Uso
@Return
@author Adilson Prado
@since 10/05/2023 
@version P12
/*/

User Function BKESTA04()
Local cTipoArq := "Arquivos no formato (*.XLSX  *.XLS) | *.XLSX "
Local cTitulo  := "Importar planilha para inclusão e geração do Termo de Responsabilidade de Uso"
Local oDlg01
Local oButSel
Local nOpcA := 0
Local nSnd:= 15,nTLin := 15

Private cArq  := ""
Private cProg := "BKESTA04"
Private aPlanLida	:= {}

u_MsgLog(cProg)

DEFINE MSDIALOG oDlg01 FROM  96,9 TO 220,392 TITLE OemToAnsi(cProg+" - "+cTitulo) PIXEL

@ nSnd,010  SAY "Arquivo: " of oDlg01 PIXEL 
@ nSnd,035  MSGET cArq SIZE 100,010 of oDlg01 PIXEL READONLY
@ nSnd,142 BUTTON oButSel PROMPT 'Selecionar' SIZE 40, 12 OF oDlg01 ACTION ( cArq := cGetFile(cTipoArq,"Selecione o diretório contendo os arquivos",,cArq,.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY,.F.,.T.)  ) PIXEL  // "Selecionar" 
nSnd += nTLin
nSnd += nTLin

DEFINE SBUTTON FROM nSnd, 125 TYPE 1 ACTION (oDlg01:End(),nOpcA:=1) ENABLE OF oDlg01
DEFINE SBUTTON FROM nSnd, 155 TYPE 2 ACTION (oDlg01:End(),,nOpcA:=0) ENABLE OF oDlg01


ACTIVATE MSDIALOG oDlg01 CENTER

If nOpcA == 1
	nOpcA:=0
	u_WaitLog(, {|| PBKESTA04()})
Endif

RETURN NIL


STATIC FUNCTION PBKESTA04()
 	Local nLinha    := 0
 	Local nTLin   	:= 0
 	Local nTCol  	:= 0
 	Local nPlan 	:= 1
	Local lPlan 	:= .T.
 	Local oExcel	:= YExcel():new()
	LOCAL aITEM 	:= {}
	LOCAL aITEMI 	:= {}
	LOCAL cCCUSTO   := ""
	LOCAL cLOCEST 	:= ""
	LOCAL cMATR 	:= ""
	LOCAL cCODSB1 	:= ""
	LOCAL nQUANT 	:= 0

	aPlanLida	:= {}	
	
	DO while lPlan

		lPlan := oExcel:OpenRead(cArq,nPlan)
 		nTLin  := oExcel:adimension[1][1]
 		nTCol  := oExcel:adimension[1][2]
		ProcRegua(nTLin)
		IF lPlan
			FOR nLinha	:= 1 to nTLin
				IncProc("Lendo a planilha...")

				cCCUSTO  := ""
				IF ValType(oExcel:CellRead(nLinha,1)) == "C"
					cCCUSTO  := ALLTRIM(oExcel:CellRead(nLinha,1))
				ELSEIF ValType(oExcel:CellRead(nLinha,1)) == "N"
					cCCUSTO  := STRZERO(oExcel:CellRead(nLinha,1),9)
				ENDIF

				DBSELECTAREA("CTT")
				CTT->(DBSETORDER(1))
				IF CTT->(MsSEEK(xFILIAL("CTT")+cCCUSTO))

					cLOCEST := ""
					IF ValType(oExcel:CellRead(nLinha,2)) == "C"
						cLOCEST  := ALLTRIM(oExcel:CellRead(nLinha,2))
					ELSEIF ValType(oExcel:CellRead(nLinha,2)) == "N"
						cLOCEST  := STRZERO(oExcel:CellRead(nLinha,2),6)
					ENDIF

					cMATR 	:= ""
					IF ValType(oExcel:CellRead(nLinha,3)) == "C"
						cMATR  := ALLTRIM(oExcel:CellRead(nLinha,3))
					ELSEIF ValType(oExcel:CellRead(nLinha,3)) == "N"
						cMATR  := STRZERO(oExcel:CellRead(nLinha,3),6)
					ENDIF

					cCODSB1 := ""
					IF ValType(oExcel:CellRead(nLinha,4)) == "C"
						cCODSB1  := ALLTRIM(oExcel:CellRead(nLinha,4))
					ELSEIF ValType(oExcel:CellRead(nLinha,4)) == "N"
						cCODSB1  := STR(oExcel:CellRead(nLinha,4))
					ENDIF	

					nQUANT 	:= 0
					IF ValType(oExcel:CellRead(nLinha,5)) == "C"
						nQUANT  := VAL(oExcel:CellRead(nLinha,5))
					ELSEIF ValType(oExcel:CellRead(nLinha,5)) == "N"
						nQUANT  := oExcel:CellRead(nLinha,5)
					ENDIF
					
					aITEM := {}
					AADD(aITEM ,{cCCUSTO,cLOCEST,cCODSB1,nQUANT,nLinha})	

					nScan:= 0
					nScan:= aScan(aPlanLida,{|x| x[1] == cMATR })
					IF nScan == 0
						aITEMI := {}
						AADD(aITEMI,aITEM)
						AADD(aPlanLida,{cMATR,aITEMI })
					ELSE
						aITEMI := {}
						aITEMI := aPlanLida[nScan,2]
						AADD(aITEMI,aITEM)
						aPlanLida[nScan,2] := aITEMI
					ENDIF
				ELSE
					u_xxConOut("ERROR","PBKESTA04","Linha= "+ALLTRIM(STR(nLinha))+" nao lida centro de custo invalido arquivo="+ALLTRIM(cArq))	
				ENDIF
			NEXT nLinha
		ENDIF

		oExcel:CloseRead()
		++nPlan
		IF nPlan == 2
			lPlan := .F.
		ENDIF
	ENDDO

	IF LEN(aPlanLida) > 0
		IF MsgYesNo("Gerar "+STR(LEN(aPlanLida),3)+" Termo de Responsabilidade de Uso de Uniformes", "Atenção")
			GRAVUNIF()
		ENDIF
	ELSE
		MSGINFO( "Dados não encontrado", "Atenção" )
	ENDIF

 Return


 //GRAVA RECEBIMENTO DO UNIFORME FUNCIONARIO
STATIC Function GRAVUNIF()
LOCAL _lOK		:= .T.
LOCAL _lCTT		:= .T.
Local _IX   	:= 0
Local _IY   	:= 0
Local cCrLf  	:= Chr(13) + Chr(10) 
Local _SQL 		:= ""
LOCAL cQuery  	:= ""
LOCAL cmgslog   := ""
Local cCodigo 	:= ""
LOCAL aItemFUN 	:= {}
LOCAL cNOMEFUNC := ""
LOCAL cCustoFUN := ""
LOCAL cCPFFUN   := ""
LOCAL cFUNCAOFUN:= ""
LOCAL cDCLIFUN  := ""
LOCAL cDCTTFUN  := ""
LOCAL cGestorFUN:= ""

FOR _IX:= 1 TO LEN(aPlanLida)

	cQuery  := "SELECT TOP 1 bk_senior.bk_senior.r034fun.numcad,bk_senior.bk_senior.r034fun.nomfun,numcpf,"
	cQuery  += " right('00' + cast(bk_senior.bk_senior.r034fun.numemp as varchar(2)),2) AS cEmp, "
	cQuery  += " right('000' + cast(bk_senior.bk_senior.R030FIL.CodFil as varchar(3)),3) AS cFil, " 
	cQuery  += " (SELECT BKIntegraRubi.dbo.fnCCSiga(bk_senior.bk_senior.r034fun.numemp,bk_senior.bk_senior.r034fun.tipcol,bk_senior.bk_senior.r034fun.numcad, 'CLT') AS Expr1) AS CCSiga, "
	cQuery  += " bk_senior.bk_senior.R030FIL.NomFil,bk_senior.bk_senior.R024CAR.TitCar"
	cQuery  += " FROM  bk_senior.bk_senior.r034fun "
	cQuery  += " INNER JOIN bk_senior.bk_senior.R030FIL ON bk_senior.bk_senior.r034fun.numemp = bk_senior.bk_senior.R030FIL.NumEmp "
	cQuery  += " AND bk_senior.bk_senior.r034fun.codfil = bk_senior.bk_senior.R030FIL.CodFil "
	cQuery  += " LEFT JOIN bk_senior.bk_senior.R016HIE ON bk_senior.bk_senior.R016HIE.NumLoc =bk_senior.bk_senior.r034fun.numloc "
	cQuery  += " LEFT JOIN bk_senior.bk_senior.R024CAR ON 	bk_senior.bk_senior.r034fun.codcar = bk_senior.bk_senior.R024CAR.CodCar"
	cQuery  += " AND bk_senior.bk_senior.R024CAR.EstCar = 1"
	cQuery  += " WHERE bk_senior.bk_senior.r034fun.tipcol ='1' AND bk_senior.bk_senior.r034fun.numcad='"+aPlanLida[_IX,1]+"' 
	cQuery  += " AND bk_senior.bk_senior.r034fun.numemp='"+SM0->M0_CODIGO+"'"
						
	TCQUERY cQuery NEW ALIAS "Qr034fun"
						
	DbSelectArea("Qr034fun")
	cNOMEFUNC  := ''
	cCustoFUN  := ''
	cCPFFUN    := ''
	cFUNCAOFUN := ''
	cNOMEFUNC  := Qr034fun->nomfun
	cCustoFUN  := Qr034fun->CCSiga
	cCPFFUN    := STRZERO(Qr034fun->numcpf,11)
	cFUNCAOFUN := Qr034fun->TitCar
	Qr034fun->(dbCloseArea())

	IF !EMPTY(cNOMEFUNC)

		aItemFUN := {}
		aItemFUN := aPlanLida[_IX,2]

		_SQL:= " SELECT TOP 1 ZV_CODIG FROM " + RetSQLName( "SZV" ) + " SZV"
		_SQL+= " WHERE SZV.D_E_L_E_T_='' ORDER BY ZV_CODIG DESC"
		
		IF SELECT('QSZV') > 0
			QSZV->(DBCLOSEAREA())
		ENDIF
			
		DBUSEAREA(.T.,"TOPCONN"	,TCGENQRY(,,_SQL),'QSZV',.F.,.T.)

		DBSELECTAREA('QSZV')
		QSZV->(DBGOTOP())
		IF !EMPTY(QSZV->ZV_CODIG)
			cCodigo := QSZV->ZV_CODIG
		ENDIF
		QSZV->(DBCLOSEAREA())
		cCodigo := STRZERO(VAL(cCodigo)+1,9)

		FOR _IY:= 1 TO LEN(aItemFUN)

			/*
			aItemFUN[_IY][1][1] //cCCUSTO
			aItemFUN[_IY][1][2] //cLOCEST
			aItemFUN[_IY][1][3] /cCODSB1
			aItemFUN[_IY][1][4] //nQUANT
			aItemFUN[_IY][1][5] //nLinha
			*/
			_lCTT	:= .T.
			IF aItemFUN[_IY][1][1] <> cCustoFUN
				If !u_MsgLog("BKESTA04 - GRAVUNIF","Centro de custo do Funcionário diferente da planilha linha= "+TRIM(STR(aItemFUN[_IY][1][5]))+". Continuar vai aceitar o que esta na planilha?","Y")
					cmgslog  += "Cancelado inclusão da linha= "+TRIM(STR(aItemFUN[_IY][1][5]))+cCrLf 
					_lCTT	:= .F.
				ENDIF
			ENDIF

			IF _lCTT
				cCustoFUN := aItemFUN[_IY][1][1]

				DBSELECTAREA("CN9")
				CN9->(DBSETORDER(1))
				CN9->(MsSEEK(xFILIAL("CN9")+cCustoFUN))
				DO WHILE CN9->(!EOF())  .AND. ALLTRIM(CN9->CN9_NUMERO) == ALLTRIM(cCustoFUN)
					cDCLIFUN := TRIM(CN9->CN9_NOMCLI)
					cDCTTFUN := TRIM(CN9->CN9_XXDESC)
					cGestorFUN  := TRIM(CN9->CN9_XXNRBK)
					CN9->(dbSkip())
				ENDDO
				IF EMPTY(cDCLIFUN)
					DBSELECTAREA("CTT")
					CTT->(DBSETORDER(1))
					IF CTT->(MsSEEK(xFILIAL("CTT")+cCustoFUN))
						cDCLIFUN   := "Centro de Custo"
						cDCTTFUN   := CTT->CTT_DESC01
						cGestorFUN := SPACE(80)
					ELSE
						cDCLIFUN   := SPACE(80)
						cDCTTFUN   := SPACE(80)
						cGestorFUN := SPACE(80)
						_lCTT := .F.
						cmgslog += "Centro de Custo ou Contrato não Encontrado da linha= "+TRIM(STR(aItemFUN[_IY][1][5]))+cCrLf 
					ENDIF
				ENDIF
			ENDIF
			
			cLOCEST := aItemFUN[_IY][1][2]	
			IF _lCTT .AND. !EMPTY(cLOCEST)
				DBSELECTAREA("SZW")
				SZW->(DBSETORDER(1))
				SZW->(MsSEEK(xFILIAL("SZW")+cCustoFUN+cLOCEST))
				DO WHILE SZW->(!EOF())  .AND. ALLTRIM(SZW->ZW_CC) == ALLTRIM(cCustoFUN) .AND.  ALLTRIM(SZW->ZW_COD) == ALLTRIM(cLOCEST)
					cDSZW := SZW->ZW_DESC
					SZW->(dbSkip())
				ENDDO
				IF EMPTY(cDSZW)
					_lCTT := .F.
					cmgslog += "Local do Centro de Custo ou Contrato não Encontrado da linha= "+TRIM(STR(aItemFUN[_IY][1][5]))+cCrLf 
				ENDIF
			ENDIF

			IF _lCTT
				cQuery := "SELECT  SZV.ZV_ITEM,SZV.ZV_PROD,SZV.ZV_QUANT,SZV.ZV_CODCA,SZV.ZV_VALIC,SZV.ZV_CUSTO1,SZV.ZV_CODIG,SZV.ZV_DOC,SZV.ZV_SER,
				cQuery += "SZV.ZV_FOR,SZV.ZV_LOJ,"+ CRLF
				cQuery += " (SELECT SUM(ZV_QUANT)  FROM "+RetSqlName("SZV")+" SZV2 "+ CRLF
				cQuery += " WHERE SZV2.D_E_L_E_T_='' AND SZV2.ZV_TM='02' AND SZV2.ZV_IDREF=SZV.ZV_CODIG AND SZV2.ZV_DOC=SZV.ZV_DOC"+ CRLF
				cQuery += " AND SZV2.ZV_SER=SZV.ZV_SER AND SZV2.ZV_FOR=SZV.ZV_FOR AND SZV2.ZV_LOJ=SZV.ZV_LOJ AND SZV2.ZV_CC=SZV.ZV_CC"+ CRLF
				cQuery += " AND SZV2.ZV_LOCAL=SZV.ZV_LOCAL AND SZV2.ZV_ITEM=SZV.ZV_ITEM) AS QUANT_S,"+ CRLF

				cQuery += " (SELECT SUM(SZV3.ZV_QUANT)  FROM "+RetSqlName("SZV")+" SZV3 "+ CRLF
				cQuery += "  INNER JOIN "+RetSqlName("SZV")+" SZVX ON SZVX.D_E_L_E_T_='' AND SZVX.ZV_TM='02' AND SZV3.ZV_IDREF=SZVX.ZV_CODIG AND SZVX.ZV_DOC=SZV3.ZV_DOC"+ CRLF
				cQuery += " AND SZVX.ZV_SER=SZV3.ZV_SER AND SZVX.ZV_FOR=SZV3.ZV_FOR AND SZVX.ZV_LOJ=SZV3.ZV_LOJ AND SZVX.ZV_CC=SZV3.ZV_CC"+ CRLF
				cQuery += " AND SZVX.ZV_LOCAL=SZV3.ZV_LOCAL AND SZVX.ZV_ITEM=SZV3.ZV_ITEM"+ CRLF
				cQuery += " WHERE SZV3.D_E_L_E_T_='' AND SZV3.ZV_TM='03' AND SZV3.ZV_EUSO<>'R' AND SZVX.ZV_IDREF=SZV.ZV_CODIG "+ CRLF
				cQuery += " AND SZV3.ZV_DOC=SZV.ZV_DOC"+ CRLF
				cQuery += " AND SZV3.ZV_SER=SZV.ZV_SER AND SZV3.ZV_FOR=SZV.ZV_FOR AND SZV3.ZV_LOJ=SZV.ZV_LOJ AND SZV3.ZV_CC=SZV.ZV_CC"+ CRLF
				cQuery += " AND SZV3.ZV_LOCAL=SZV.ZV_LOCAL AND SZV3.ZV_ITEM=SZV.ZV_ITEM) AS QUANT_D"+ CRLF

				cQuery += " FROM "+RETSQLNAME("SZV")+ " SZV" + CRLF
				cQuery += " INNER JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT.D_E_L_E_T_=''" + CRLF
				cQuery += " AND CTT_CUSTO= ZV_CC" + CRLF
				cQuery += " LEFT JOIN "+RETSQLNAME("SZW")+ " SZW ON SZW.D_E_L_E_T_=''" + CRLF
				cQuery += " AND ZW_CC= ZV_CC AND ZW_COD= ZV_LOCAL" + CRLF
				cQuery += " WHERE SZV.D_E_L_E_T_=''  AND SZV.ZV_TM='01'"+CRLF
				cQuery += " AND SZV.ZV_CC='"+aItemFUN[_IY][1][1]+"'"
				cQuery += " AND SZV.ZV_LOCAL='"+aItemFUN[_IY][1][2]+"'"
				cQuery += " AND SZV.ZV_PROD='"+aItemFUN[_IY][1][3]+"'"
				cQuery += " ORDER BY SZV.ZV_PROD,SZV.ZV_VALIC"

				IF SELECT('QSZV2') > 0
					QSZV2->(DBCLOSEAREA())
				ENDIF
					
				DBUSEAREA(.T.,"TOPCONN"	,TCGENQRY(,,cQuery),'QSZV2',.F.,.T.)
				TCSETFIELD("QSZV2","ZV_VALIC","D",8,0)
				lACHOU := .F.
				DBSELECTAREA('QSZV2')
				IF !EMPTY(QSZV2->ZV_ITEM)
					while QSZV2->(!EOF()) .AND. !lACHOU
						nSaldo := 0
						nSaldo := (QSZV2->ZV_QUANT-QSZV2->QUANT_S+QSZV2->QUANT_D)
						IF nSaldo >= aItemFUN[_IY][1][4]
							lACHOU := .T.
							nCustoUFOR := 0 
							nCustoUFOR := QSZV2->ZV_CUSTO1/QSZV2->ZV_QUANT
							//"Item","Cod. Produto","Descrição","Quantidade","Cod. CA","Validade CA","Valor Unit","ID Movimento","Doc","Serie","Forn","Loja"
							//AADD(aUnifor,{.F.,QSZV2->ZV_ITEM,QSZV2->ZV_PROD,TRIM(Posicione("SB1",1,xFilial("SB1")+QSZV2->ZV_PROD,"B1_DESC")),nSaldo,QSZV2->ZV_CODCA,QSZV2->ZV_VALIC,nCustoUFOR,QSZV2->ZV_CODIG,QSZV2->ZV_DOC,QSZV2->ZV_SER,QSZV2->ZV_FOR,QSZV2->ZV_LOJ})

							RecLock("SZV",.T.)
							SZV->ZV_FILIAL	:= xFilial("SZV")
							SZV->ZV_CODIG	:= cCodigo
							SZV->ZV_EMISSAO	:= dDATABASE
							SZV->ZV_PROD	:= QSZV2->ZV_PROD
							SZV->ZV_DESCRI	:= Posicione("SB1",1,xFilial("SB1")+QSZV2->ZV_PROD,"B1_DESC")
							SZV->ZV_QUANT	:= aItemFUN[_IY][1][4] 
							SZV->ZV_CUSTO1	:= nCustoUFOR*aItemFUN[_IY][1][4] 
							SZV->ZV_TM		:= "02" 
							SZV->ZV_CC		:= aItemFUN[_IY][1][1]
							SZV->ZV_CCDESC	:= Posicione("CTT",1,xFilial("CTT")+aItemFUN[_IY][1][1],"CTT_DESC01")
							SZV->ZV_LOCAL   := cLOCEST
							//SZV->ZV_ENDBK	:= 
							//SZV->ZV_ENDCO	:= 
							//SZV->ZV_NOMRE	:= 
							//SZV->ZV_CPFRE	:= 
							//SZV->ZV_RECBNOM	:= 
							//SZV->ZV_RECBCPF	:= 
							SZV->ZV_GESTO	:= cGestorFUN
							SZV->ZV_CODCA	:= QSZV2->ZV_CODCA
							SZV->ZV_VALIC	:= QSZV2->ZV_VALIC
							//SZV->ZV_RDEVO	:= 
							//SZV->ZV_CPFRD	:= 
							//SZV->ZV_EUSO	:= 
							SZV->ZV_PRONT	:= aPlanLida[_IX,1]
							SZV->ZV_NOME	:= cNOMEFUNC
							SZV->ZV_FUNCA	:= cFUNCAOFUN
							SZV->ZV_RGFUNC  := cCPFFUN
							SZV->ZV_ITEM	:= QSZV2->ZV_ITEM
							SZV->ZV_IDREF   := QSZV2->ZV_CODIG
							SZV->ZV_DOC		:= QSZV2->ZV_DOC
							SZV->ZV_SER		:= QSZV2->ZV_SER
							SZV->ZV_FOR		:= QSZV2->ZV_FOR
							SZV->ZV_LOJ		:= QSZV2->ZV_LOJ
							SZV->(MSUNLOCK())																																																																																																				
						ELSE 
							cmgslog += "Sem saldo!  linha= "+TRIM(STR(aItemFUN[_IY][1][5]))+cCrLf 
						ENDIF
						QSZV2->(dbSkip())
					ENDDO
					QSZV2->(DBCLOSEAREA())
				ELSE
					cmgslog += "Dados da Notas Fiscal não Encontrado!  linha= "+TRIM(STR(aItemFUN[_IY][1][5]))+cCrLf 
				ENDIF
			ENDIF
		NEXT _IY
	ELSE
		cmgslog += "Dados do Funcionário não encontrado!  linha= "+TRIM(STR(aItemFUN[_IY][1][5]))+cCrLf 
	ENDIF
NEXT _IX
IF !EMPTY(cmgslog)

	u_MsgLog("BKESTA04","Erro na inclusão verifique!"+cCrLf+cCrLf+cmgslog,"S")

ENDIF

Return _lOK
