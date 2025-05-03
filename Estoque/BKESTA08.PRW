#include "PROTHEUS.CH"
#include "TopConn.ch"
#include "RwMake.ch" 

/*/{Protheus.doc} BKESTA08
BARCAS RIO - Importar planilha cadastro de endereçamento - SBE
@Return
@author Marcos Abrahão / Adilson Prado
@since 03/05/2025 
@version P12
/*/

User Function BKESTA08()
Local cTipoArq := "Arquivos no formato (*.XLSX  *.XLS) | *.XLSX "
Local cTitulo  := "Importar planilha - Cadastro de Endereçamento"
Local oDlg01
Local oButSel
Local nOpcA := 0
Local nSnd:= 15,nTLin := 15

Private cArq  := ""
Private cProg := "BKESTA08"

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
	u_WaitLog(cProg, {|oSay| PBKESTA08(oSay)})
Endif

Return Nil


Static Function PBKESTA08(oSay)
 	Local nLinha    := 0
 	Local nTLin   	:= 0
 	Local nTCol  	:= 0
 	Local nPlan 	:= 1
	Local lPlan 	:= .T.
 	Local oExcel	:= YExcel():new()
	Local aItens 	:= {}
	Local cLocEst 	:= ""
	Local cLocaliz	:= ""
	Local cDescr	:= ""
	Local lErro 	:= .F.
	Local nTamLoc	:= 2
	Local lCab 		:= .T.
	Local aErros	:= {}

	nTamLoc := TamSX3('NNR_CODIGO')[1]

	DO while lPlan

		lPlan  := oExcel:OpenRead(cArq,nPlan)

		IF lPlan

			nTLin  := oExcel:adimension[1][1]
			nTCol  := oExcel:adimension[1][2]
			
			oSay:SetText("Carregando a planilha...")

			FOR nLinha	:= 1 to nTLin

				cLocEst  := ""
				IF ValType(oExcel:CellRead(nLinha,1)) == "C"
					cLocEst  := ALLTRIM(oExcel:CellRead(nLinha,1))
				ELSEIF ValType(oExcel:CellRead(nLinha,1)) == "N"
					cLocEst  := STRZERO(oExcel:CellRead(nLinha,1),2)
				ENDIF
				If Len(cLocEst) == 2
					DBSELECTAREA("NNR")
					NNR->(DBSETORDER(1))
					IF NNR->(MsSEEK(xFILIAL("NNR")+PAD(cLocEst,nTamLoc)))
						lCab := .F.
						cLocaliz := ""
						IF ValType(oExcel:CellRead(nLinha,2)) == "C"
							cLocaliz  := ALLTRIM(oExcel:CellRead(nLinha,2))
						ELSEIF ValType(oExcel:CellRead(nLinha,2)) == "N"
							cLocaliz  := ALLTRIM(STR(oExcel:CellRead(nLinha,2)))
						ENDIF

						cDescr := ""
						IF ValType(oExcel:CellRead(nLinha,2)) == "C"
							cDescr  := ALLTRIM(oExcel:CellRead(nLinha,2))
						ELSEIF ValType(oExcel:CellRead(nLinha,2)) == "N"
							cDescr  := ALLTRIM(STR(oExcel:CellRead(nLinha,2)))
						ENDIF

						AADD(aItens ,{cLocEst,cLocaliz,cDescr,nLinha})

					ELSE
						If !lCab .OR. nLinha > 4
							u_MsgLog(cProg,"Linha= "+ALLTRIM(STR(nLinha))+" nao lida, Local não encontrado: "+ALLTRIM(cLocEst),"E")
							lErro := .T.
							aAdd(aErros,{nLinha,cLocEst,"Local não encontrado"})
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
			IF u_MsgLog(cProg,"Gravar os endereçamentos (linhas importadas "+ALLTRIM(STR(LEN(aItens),3))+") ?", "Y")
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
	lOk := MyMata015(nI,aItens[nI,1],aItens[nI,2],aItens[nI,3])
	If !lOk
		aAdd(aErros,{nI,aItens[nI,2],"Não foi possível gravar o endereço"})
	EndIf
Next

Return lOK

Static Function MyMata015(nLinha,cLocEst,cLocaliz,cDescr)
LOCAL aVetor	:= {}
Local nOpc		:= 0
Local lOk		:= .T.

Private lMsErroAuto := .F.  

aVetor := 	{	{"BE_LOCAL"  	,cLocEst	,Nil},;
				{"BE_LOCALIZ"	,cLocaliz	,NIL},;
				{"BE_DESCRIC"	,cDescr		,NIL},;
				{"BE_STATUS"	,"1"		,NIL} }

nOpc := 3	// inclusao

Begin Transaction      
	MSExecAuto({|x,y| MATA015(x,y)},aVetor, nOpc) 
	If lMsErroAuto
		u_LogMsExec(cProg,"Erro na inclusao: "+cLocaliz+" Linha "+STR(nLinha,5))
		lOk := .F.
	EndIf
End Transaction

Return lOk

