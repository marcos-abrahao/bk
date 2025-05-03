#include "PROTHEUS.CH"
#include "TopConn.ch"
#include "RwMake.ch" 

/*/{Protheus.doc} BKESTA07
BARCAS RIO - Importar planilha movimento de estoque
@Return
@author Marcos Abrahão / Adilson Prado
@since 02/05/2025 
@version P12
/*/

User Function BKESTA07()
Local cTipoArq := "Arquivos no formato (*.XLSX  *.XLS) | *.XLSX "
Local cTitulo  := "Importar planilha movimento de estoque"
Local oDlg01
Local oButSel
Local nOpcA := 0
Local nSnd:= 15,nTLin := 15

Private cArq  := ""
Private cProg := "BKESTA07"

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
	u_WaitLog(cProg, {|oSay| PBKESTA07(oSay)})
Endif

Return Nil


Static Function PBKESTA07(oSay)
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
	Local dData		:= dDatabase
	Local cCC 		:= ""
	Local cObs		:= ""
	Local cLocaliz 	:= ""
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

				dData := CTOD("")
				IF ValType(oExcel:CellRead(nLinha,1)) == "D"
					dData  := oExcel:CellRead(nLinha,1)
				ELSEIF ValType(oExcel:CellRead(nLinha,1)) == "C"
					dData  := CTOD(oExcel:CellRead(nLinha,1))
				ELSEIF ValType(oExcel:CellRead(nLinha,1)) == "N"
					dData  := CTOD(STR(oExcel:CellRead(nLinha,1)))
				ENDIF

				cProd  := ""
				IF ValType(oExcel:CellRead(nLinha,2)) == "C"
					cProd  := ALLTRIM(oExcel:CellRead(nLinha,2))
				ELSEIF ValType(oExcel:CellRead(nLinha,2)) == "N"
					cProd  := ALLTRIM(STR(oExcel:CellRead(nLinha,2)))
				ENDIF
				If !Empty(cProd)
					cProd := Pad(cProd,nTamPrd)
					DBSELECTAREA("SB1")
					SB1->(DBSETORDER(1))
					IF SB1->(MsSEEK(xFILIAL("SB1")+cProd))
						lCab := .F.
						cLocEst := ""
						IF ValType(oExcel:CellRead(nLinha,3)) == "C"
							cLocEst  := ALLTRIM(oExcel:CellRead(nLinha,3))
						ELSEIF ValType(oExcel:CellRead(nLinha,3)) == "N"
							cLocEst  := ALLTRIM(STR(oExcel:CellRead(nLinha,3)))
						ENDIF

						cLocaliz := ""
						IF ValType(oExcel:CellRead(nLinha,4)) == "C"
							cLocaliz  := ALLTRIM(oExcel:CellRead(nLinha,4))
						ELSEIF ValType(oExcel:CellRead(nLinha,4)) == "N"
							cLocaliz  := ALLTRIM(STR(oExcel:CellRead(nLinha,4)))
						ENDIF

						nQuant 	:= 0
						IF ValType(oExcel:CellRead(nLinha,5)) == "C"
							nQuant  := VAL(oExcel:CellRead(nLinha,5))
						ELSEIF ValType(oExcel:CellRead(nLinha,5)) == "N"
							nQuant  := oExcel:CellRead(nLinha,5)
						ENDIF

						nValor 	:= 0
						IF ValType(oExcel:CellRead(nLinha,6)) == "C"
							nValor  := VAL(oExcel:CellRead(nLinha,6))
						ELSEIF ValType(oExcel:CellRead(nLinha,6)) == "N"
							nValor  := oExcel:CellRead(nLinha,6)
						ENDIF

						cCC := ""
						IF ValType(oExcel:CellRead(nLinha,7)) == "C"
							cCC  := ALLTRIM(oExcel:CellRead(nLinha,7))
						ELSEIF ValType(oExcel:CellRead(nLinha,7)) == "N"
							cCC  := ALLTRIM(STR(oExcel:CellRead(nLinha,7)))
						ENDIF

						cObs := ""
						IF ValType(oExcel:CellRead(nLinha,8)) == "C"
							cObs  := ALLTRIM(oExcel:CellRead(nLinha,8))
						ELSEIF ValType(oExcel:CellRead(nLinha,8)) == "N"
							cObs  := ALLTRIM(STR(oExcel:CellRead(nLinha,8)))
						ENDIF


						AADD(aItens ,{dData,cProd,cLocEst,cLocaliz,nQuant,nValor,cCC,cObs,cCC+DTOS(dData)})

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
		Else
			u_MsgLog(cProg,"Não foi possível abrir o arquivo "+cArq,"E")		
		ENDIF

		++nPlan
		IF nPlan == 2
			lPlan := .F.
		ENDIF
	ENDDO

	IF LEN(aItens) > 0
		IF !lErro
			IF u_MsgLog(cProg,"Gravar os dados iniciais de estoque (linhas importadas "+ALLTRIM(STR(LEN(aItens),3))+") ?", "Y")
				u_WaitLog(cProg,{ |oSay| GravSD3(oSay,aItens,aErros)},"Gravando saldos iniciais...")
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
Static Function GravSD3(oSay,aItens,aErros)
Local lOk := .T.
Local nI  := 1
Local nL  := 0
Local aIt2 := {}
Local cChave := ""
ASORT(aItens,,,{|x,y| x[9]<y[9]})
Do While nI <= Len(aItens)
	//dData,cProd,cLocEst,cLocaliz,nQuant,nValor,cCC,cObs,nLinha})
	cChave := aItens[nI,9]
	aIt2 := {}
	nL := nI
	Do While nI <= Len(aItens) .AND. cChave == aItens[nI,9]
		aAdd(aIt2,aItens[nI])
		nI++
	EndDo
	lOk := MyMata241(nL,aIt2)
	If !lOk
		aAdd(aErros,{nL,cChave,"Não foi possível gravar o movimento"})
	EndIf
EndDo

Return lOK



Static Function MyMata241(nLinha,aIt2)
Local aCab1		:= {}       // Array para o cabeçalho do movimento
Local aItem		:= {}       // Array para os itens do movimento
Local aTotItem	:= {}    	// Array para agrupar todos os itens
Local lRet		:= .T.
Local cCodigoTM := "501"
Local nJ  		:= 0

// Variáveis para controle de execução automática
Private lMsHelpAuto := .T. // Se .T., exibe mensagens de help
Private lMsErroAuto := .F. // Se .F., não exibe erros automáticos

// dData,cProd,cLocEst,cLocaliz,nQuant,nValor,cCC,cObs,cCC+DTOS(dData)

dData 	:= aIt2[1,1]
cCC		:= aIt2[1,7]
cChave  := aIt2[1,9]

// Monta o cabeçalho do movimento
aCab1 := {;
        {"D3_DOC"		, NextNumero("SD3", 2, "D3_DOC", .T.), NIL},; // Número do documento (gerado automaticamente)
        {"D3_TM"		, cCodigoTM							 , NIL},; // Tipo de movimento
        {"D3_CC"		, cCC								 , NIL},; // Centro de custo (vazio)
        {"D3_EMISSAO"	, dData								 , NIL};  // Data de emissão (data atual)
    }

For nJ := 1 To Len(aIt2)
	// Monta os itens do movimento
	cProd 	:= aIt2[nJ,2]
	cLocEst	:= aIt2[nJ,3]
	cLocaliz:= aIt2[nJ,4]
	nQuant	:= aIt2[nJ,5]
	nValor	:= aIt2[nJ,6]
	cObs	:= PAD(aIt2[nJ,8],20)

	aItem := {;
			{"D3_COD"	, cProd		, NIL},;	// Código do produto
			{"D3_LOCAL"	, cLocEst	, NIL},;	// Local de estoque
			{"D3_QUANT"	, nQuant	, NIL},;	// Quantidade do item (1.99)
			{"D3_CUSTO1", nValor	, NIL},;	// Custo do item
			{"D3_CC"	, cCC		, NIL},;	// Centro de Custos (testar)
			{"D3_LOCALIZ",cLocaliz	, NIL},;	// Endereçamento
			{"D3_OBS"	, cObs		, NIL};		// Observaçoes
		}

		//        {"D3_UM"	, cUnid		, NIL},;	// Unidade de medida

	// Adiciona o item ao array de itens
	aAdd(aTotItem, aItem)
Next

// Executa a rotina de inclusão de movimento (MATA241)
// Certifique-se de que aCab1 e aTotItem são arrays válidos

Begin Transaction
	MSExecAuto({|x, y, z| MATA241(x, y, z)}, aCab1, aTotItem, 3)

	// Verifica se houve erro na execução automática
	If lMsErroAuto
		u_LogMsExec(cProg,"Erro no movimento: "+cProd+" Linha: "+STR(nLinha,5))
	    DisarmTransaction()
		lRet := .F.
	EndIf
End Transaction

Return lRet
