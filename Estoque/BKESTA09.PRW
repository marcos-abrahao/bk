#include "PROTHEUS.CH"
#include "TopConn.ch"
#include "RwMake.ch" 

/*/{Protheus.doc} BKESTA09
BARCAS RIO - Importar planilha Inventário (SB7)
@Return
@author Marcos Abrahão / Adilson Prado
@since 06/05/2025 
@version P12
/*/

User Function BKESTA09()
Local cTipoArq := "Arquivos no formato (*.XLSX  *.XLS) | *.XLSX "
Local cTitulo  := "Importar planilha - Inventário (SB7)"
Local oDlg01
Local oButSel
Local nOpcA := 0
Local nSnd:= 15,nTLin := 15

Private cArq  := ""
Private cProg := "BKESTA09"

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
	u_WaitLog(cProg, {|oSay| PBKESTA09(oSay)})
Endif

Return Nil


Static Function PBKESTA09(oSay)
 	Local nLinha    := 0
 	Local nTLin   	:= 0
 	Local nTCol  	:= 0
 	Local nPlan 	:= 1
	Local lPlan 	:= .T.
 	Local oExcel	:= YExcel():new()
	Local aItens 	:= {}
	Local cProd		:= ""
	Local cTipo		:= ""
	Local cLocEst 	:= ""
	Local cDoc 		:= ""
	Local dData		:= Date()
	Local nQuant 	:= 0
	Local cLocaliz	:= ""
	Local lErro 	:= .F.
	Local nTamLoc	:= 2
	Local nTamPrd	:= 15
	Local lCab 		:= .T.
	Local aErros	:= {}

	nTamLoc := TamSX3('NNR_CODIGO')[1]
	nTamPrd := TamSX3('B1_COD')[1]

	DO while lPlan

		lPlan  := oExcel:OpenRead(cArq,nPlan)

		IF lPlan

			nTLin  := oExcel:adimension[1][1]
			nTCol  := oExcel:adimension[1][2]
			
			oSay:SetText("Carregando a planilha...")

			FOR nLinha	:= 1 to nTLin

				cProd  := ""
				IF ValType(oExcel:CellRead(nLinha,1)) == "C"
					cProd  := ALLTRIM(oExcel:CellRead(nLinha,1))
				ELSEIF ValType(oExcel:CellRead(nLinha,1)) == "N"
					cProd  := ALLTRIM(STR(oExcel:CellRead(nLinha,1)))
				ENDIF

				If !Empty(cProd)
					cProd := Pad(cProd,nTamPrd)
					DBSELECTAREA("SB1")
					SB1->(DBSETORDER(1))
					IF SB1->(MsSEEK(xFILIAL("SB1")+cProd))
						lCab := .F.
						cTipo := SB1->B1_TIPO

						cLocEst := ""
						IF ValType(oExcel:CellRead(nLinha,2)) == "C"
							cLocEst  := ALLTRIM(oExcel:CellRead(nLinha,2))
						ELSEIF ValType(oExcel:CellRead(nLinha,2)) == "N"
							cLocEst  := ALLTRIM(STR(oExcel:CellRead(nLinha,2)))
						ENDIF

						cDoc := ALLTRIM(oExcel:CellRead(nLinha,3))

						nQuant 	:= 0
						IF ValType(oExcel:CellRead(nLinha,4)) == "C"
							nQuant  := VAL(oExcel:CellRead(nLinha,4))
						ELSEIF ValType(oExcel:CellRead(nLinha,4)) == "N"
							nQuant  := oExcel:CellRead(nLinha,4)
						ENDIF

						dData := CTOD("")
						IF ValType(oExcel:CellRead(nLinha,5)) == "D"
							dData  := oExcel:CellRead(nLinha,5)
						ELSEIF ValType(oExcel:CellRead(nLinha,5)) == "C"
							dData  := CTOD(oExcel:CellRead(nLinha,5))
						ELSEIF ValType(oExcel:CellRead(nLinha,5)) == "N"
							dData  := CTOD(STR(oExcel:CellRead(nLinha,5)))
						ENDIF


						cLocaliz := ""
						IF ValType(oExcel:CellRead(nLinha,6)) == "C"
							cLocaliz  := ALLTRIM(oExcel:CellRead(nLinha,6))
						ELSEIF ValType(oExcel:CellRead(nLinha,6)) == "N"
							cLocaliz  := ALLTRIM(STR(oExcel:CellRead(nLinha,6)))
						ENDIF

						AADD(aItens ,{cProd,cTipo,cLocEst,dData,nQuant,cLocaliz,cDoc})

					ELSE
						If !lCab .OR. nLinha > 4
							u_MsgLog(cProg,"Linha= "+ALLTRIM(STR(nLinha))+" nao lida, produto não encontrado: "+ALLTRIM(cProd),"E")
							lErro := .T.
							aAdd(aErros,{nLinha,cProd,"Produto não encontrado"})
						EndIf
					ENDIF
				EndIf

			NEXT nLinha
			oExcel:CloseRead()
		ELSE
			u_MsgLog(cProg,"Não foi posível abrir o arquivo "+cArq, "E")
		ENDIF

		++nPlan
		IF nPlan == 2
			lPlan := .F.
		ENDIF
	ENDDO

	IF LEN(aItens) > 0
		IF !lErro
			IF u_MsgLog(cProg,"Gravar o inventário (linhas importadas "+ALLTRIM(STR(LEN(aItens),3))+") ?", "Y")
				u_WaitLog(cProg,{ |oSay| GravEnd(oSay,aItens,aErros)},"Gravando endereçamentos..")
			ENDIF
		Else
			u_MsgLog(cProg,"Erros encontrados, processo não será concluído","W")
		EndIf
		If Len(aErros) > 0
			IF u_MsgLog(cProg,"Deseja visualizar os erros encontrados", "Y")
				u_WaitLog(cProg,{ |oSay| u_ErrosE05(aErros)},"Gerando planilha de erros...")
			EndIf
		Else
			u_MsgLog(cProg,"Processo concluído com sucesso","W")
		EndIf
	ELSE
		u_MsgLog(cProg,"Dados não encontrados","W")
	ENDIF

 Return


 // Gravar os dados de estoque
Static Function GravEnd(oSay,aItens,aErros)
Local lOk := .T.
Local nI  := 0
For nI := 1 To Len(aItens)
	lOk := MyMata270(nI,aItens[nI,1],aItens[nI,2],aItens[nI,3],aItens[nI,4],aItens[nI,5],aItens[nI,6],aItens[nI,7])
	If !lOk
		aAdd(aErros,{nI,aItens[nI,1],"Erro ao gravar no local "+aItens[nI,3]})
	EndIf
Next

Return lOK

Static Function MyMata270(nLinha,cProd,cTipo,cLocEst,dData,nQuant,cLocaliz,cDoc)
LOCAL aAuto		:= {}
Local nOpc		:= 0
Local lOk		:= .T.

Private lMsErroAuto := .F.  

/*
      SB7->B7_FILIAL  := xFilial("SB7")
      SB7->B7_DATA    := dData 
      SB7->B7_COD     := QINV->Produto      
      SB7->B7_LOCAL   := SUBSTR(QINV->LocEst,3,2)    
      SB7->B7_TIPO    := "MC"
      SB7->B7_DTVALID := dData 
      SB7->B7_DOC     := cDoc
      SB7->B7_QUANT   := QINV->QtdHom
      SB7->B7_QTSEGUM := QINV->QtdHom

      SB7->B7_ORIGEM  := "MATA270"
      //SB7->B7_CODGRP  := IniAuxCod(SB7->B7_COD,"B7_CODGRP")
      //SB7->B7_CODITE  := IniAuxCod(SB7->B7_COD,"B7_CODITE")
      //SB7->B7_DESC    := SB1->B1_DESC
      SB7->B7_STATUS  := "1"
*/

Aadd(aAuto, {"B7_FILIAL" 	, xFilial("SB7") , NIL})
Aadd(aAuto, {"B7_LOCAL" 	, cLocEst , NIL})
Aadd(aAuto, {"B7_TIPO" 		, cTipo , NIL})
Aadd(aAuto, {"B7_DOC" 		, cDoc , NIL})
Aadd(aAuto, {"B7_QUANT" 	, nQuant , NIL})
Aadd(aAuto, {"B7_DATA" 		, dData, NIL})
//Aadd(aAuto, {"B7_DTVALID" 	, Stod("20170613") , NIL})
Aadd(aAuto, {"B7_COD" 		, cProd , NIL})
//Aadd(aAuto, {"B7_LOTECTL" 	, Pad("LOTE0001" , Len(SB7->B7_LOTECTL)) , NIL})
//Aadd(aAuto, {"B7_NUMLOTE" 	, Pad("000001" , Len(SB7->B7_NUMLOTE)) , NIL})
Aadd(aAuto, {"B7_LOCALIZ" 	, Pad(cLocaliz, Len(SB7->B7_LOCALIZ)) , NIL})
//Aadd(aAuto, {"B7_NUMSERI" 	, Pad("" , Len(SB7->B7_NUMSERI)) , NIL})
Aadd(aAuto, {"B7_ORIGEM" 	, "MATA270" , NIL})
Aadd(aAuto, {"B7_STATUS" 	, "1" , NIL})
Aadd(aAuto, {"INDEX" 		, 1 , NIL})

lMsErroAuto := .F.

nOpc := 3	// inclusao

Begin Transaction      
	MsExecAuto({|a,b,c| MATA270(a,b,c)}, aAuto, .T., nOpc)
	If lMsErroAuto
		u_LogMsExec(cProg,"Erro na inclusao: "+cProd+" Linha "+STR(nLinha,5))
		lOk := .F.
	EndIf
End Transaction

Return lOk

