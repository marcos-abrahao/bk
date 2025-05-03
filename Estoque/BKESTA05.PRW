#include "PROTHEUS.CH"
#include "TopConn.ch"
#include "RwMake.ch" 

/*/{Protheus.doc} BKESTA05
BARCAS RIO - Importar planilha para Saldos Iniciais e Endereçamento
@Return
@author Marcos Abrahão / Adilson Prado
@since 02/05/2025 
@version P12
/*/

User Function BKESTA05()
Local cTipoArq := "Arquivos no formato (*.XLSX  *.XLS) | *.XLSX "
Local cTitulo  := "Importar planilha para Saldos Iniciais"
Local oDlg01
Local oButSel
Local nOpcA := 0
Local nSnd:= 15,nTLin := 15

Private cArq  := ""
Private cProg := "BKESTA05"

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
	u_WaitLog(cProg, {|oSay| PBKESTA05(oSay)})
Endif

Return Nil


Static Function PBKESTA05(oSay)
 	Local nLinha    := 0
 	Local nTLin   	:= 0
 	Local nTCol  	:= 0
 	Local nPlan 	:= 1
	Local lPlan 	:= .T.
 	Local oExcel	:= YExcel():new()
	Local aItens 	:= {}
	Local cProd     := ""
	Local cLocEst 	:= ""
	Local nQuant 	:= 0
	Local nValor 	:= 0
	Local lErro 	:= .F.
	Local nTamPrd	:= 15
	Local lCab 		:= .T.
	Local aErros	:= {}

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
						cLocEst := ""
						IF ValType(oExcel:CellRead(nLinha,2)) == "C"
							cLocEst  := ALLTRIM(oExcel:CellRead(nLinha,2))
						ELSEIF ValType(oExcel:CellRead(nLinha,2)) == "N"
							cLocEst  := ALLTRIM(STR(oExcel:CellRead(nLinha,2)))
						ENDIF

						nQuant 	:= 0
						IF ValType(oExcel:CellRead(nLinha,3)) == "C"
							nQuant  := VAL(oExcel:CellRead(nLinha,3))
						ELSEIF ValType(oExcel:CellRead(nLinha,3)) == "N"
							nQuant  := oExcel:CellRead(nLinha,3)
						ENDIF

						nValor 	:= 0
						IF ValType(oExcel:CellRead(nLinha,4)) == "C"
							nValor  := VAL(oExcel:CellRead(nLinha,4))
						ELSEIF ValType(oExcel:CellRead(nLinha,4)) == "N"
							nValor  := oExcel:CellRead(nLinha,4)
						ENDIF

						AADD(aItens ,{cProd,cLocEst,nQuant,nValor,nLinha})

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
			IF u_MsgLog(cProg,"Gravar os dados iniciais de estoque (linhas importadas "+ALLTRIM(STR(LEN(aItens),3))+") ?", "Y")
				u_WaitLog(cProg,{ |oSay| GravEst(oSay,aItens,aErros)},"Gravando saldos iniciais...")
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
Static Function GravEst(oSay,aItens,aErros)
Local lOk := .T.
Local nI  := 0
For nI := 1 To Len(aItens)
	lOk := MyMata220(nI,aItens[nI,1],aItens[nI,2],aItens[nI,3],aItens[nI,4])
	If !lOk
		aAdd(aErros,{nI,aItens[nI,1],"Não foi possível gravar o saldo inicial"})
	EndIf
Next

Return lOK

// https://tdninterno.totvs.com/display/public/PROT/MATA220+-+Controle+de+Itens+do+Estoque
Static Function MyMata220(nLinha,cProd,cArmazem,cQtdIni,nValor)
Local aSB9 := {}
Local lOk		:= .T.
PRIVATE lMsErroAuto := .F.

aAdd(aSB9,{"B9_COD",cProd,})
aAdd(aSB9,{"B9_LOCAL",cArmazem,})
aAdd(aSB9,{"B9_QINI",cQtdIni,})
aAdd(aSB9,{"B9_VINI1",nValor,})

Begin Transaction      
	MSExecAuto({|x,y| mata220(x,y)},aSB9,3)
	If lMsErroAuto
		u_LogMsExec(cProg,"Erro na inclusao: "+cProd+" Linha "+STR(nLinha,5))
		lOk := .F.
	EndIf
End Transaction

Return lOk




User Function ErrosE05(aErros)
Local cTitulo	:= "Erros - importação de dados"
Local cDescr 	:= ""
Local cVersao	:= "02/05/2025"
Local cArqXls	:= ""
Local oRExcel	AS Object
Local oPExcel	AS Object

// Definição do Arq Excel
oRExcel := RExcel():New(cProg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetVersao(cVersao)
oRExcel:SetDescr(cDescr)
oRExcel:SetParam({})

// Definição da Planilha 1
oPExcel:= PExcel():New(cProg,aErros)
oPExcel:SetTitulo("Arquivo: "+cArq)

// Colunas da Planilha 1
oPExcel:AddCol("LINHA","STRZERO(xCampo,6)","Linha","")
//oPExcel:GetCol("LINHA"):SetDecimal(0)
oPExcel:GetCol("LINHA"):SetHAlign("C")

oPExcel:AddColX3("B1_COD")

oPExcel:AddCol("ERRO","","Erros","")
oPExcel:GetCol("ERRO"):SetTamanho(200)

// Adiciona a planilha 1
oRExcel:AddPlan(oPExcel)

// Cria arquivo Excel
cArqXls:= oRExcel:Create()

Return cArqXls


