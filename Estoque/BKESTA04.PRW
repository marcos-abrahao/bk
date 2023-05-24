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
LOCAL _lOK	:= .T.
Local _IX   := 0
Local _IY   := 0
Local _SQL 	:= ""
Local cCodigo := ""
LOCAL aItemFUN := {}


FOR _IX:= 1 TO LEN(aPlanLida)

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

		RecLock("SZV",.T.)
		SZV->ZV_FILIAL	:= xFilial("SZV")
		SZV->ZV_CODIG	:= cCodigo
		SZV->ZV_EMISSAO	:= dDataDFUN
		SZV->ZV_PROD	:= aItemFUN[_IX,2]
		SZV->ZV_DESCRI	:= Posicione("SB1",1,xFilial("SB1")+aItemFUN[_IX,2],"B1_DESC")
		SZV->ZV_QUANT	:= aItemFUN[_IX,4]
		SZV->ZV_CUSTO1	:= aItemFUN[_IX,7]*aItemFUN[_IX,4]
		SZV->ZV_TM		:= "02" 
		SZV->ZV_CC		:= cCustoFUN
		SZV->ZV_CCDESC	:= cDCTTFUN
		SZV->ZV_LOCAL   := cLOCSZWFUN 
		//SZV->ZV_ENDBK	:= 
		//SZV->ZV_ENDCO	:= 
		//SZV->ZV_NOMRE	:= 
		//SZV->ZV_CPFRE	:= 
		//SZV->ZV_RECBNOM	:= 
		//SZV->ZV_RECBCPF	:= 
		SZV->ZV_GESTO	:= cGestorFUN
		SZV->ZV_CODCA	:= aItemFUN[_IX,5]
		SZV->ZV_VALIC	:= aItemFUN[_IX,6]
		//SZV->ZV_RDEVO	:= 
		//SZV->ZV_CPFRD	:= 
		//SZV->ZV_EUSO	:= 
		SZV->ZV_PRONT	:= cMatric
		SZV->ZV_NOME	:= cNOMEFUNC
		SZV->ZV_FUNCA	:= cFUNCAOFUN
		SZV->ZV_RGFUNC  := cCPFFUN
		SZV->ZV_ITEM	:= aItemFUN[_IX,1]
		SZV->ZV_IDREF   := aItemFUN[_IX,9]
		SZV->ZV_DOC		:= aItemFUN[_IX,10]
		SZV->ZV_SER		:= aItemFUN[_IX,11]
		SZV->ZV_FOR		:= aItemFUN[_IX,12]
		SZV->ZV_LOJ		:= aItemFUN[_IX,13]

		SZV->(MSUNLOCK())																																																																																																				
		*/
	NEXT _IY
	MSGINFO("Incluido com sucesso! cod.: "+SZV->ZV_CODIG)
NEXT _IX

Return _lOK



