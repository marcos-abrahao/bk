#include "PROTHEUS.CH"
#include "TopConn.ch"
#include "RwMake.ch" 

/*/{Protheus.doc} BKESTA06
BARCAS RIO - Importar planilha Endereçamento de estoque
@Return
@author Marcos Abrahão / Adilson Prado
@since 02/05/2025 
@version P12
/*/

User Function BKESTA06()
Local cTipoArq := "Arquivos no formato (*.XLSX  *.XLS) | *.XLSX "
Local cTitulo  := "Importar planilha Endereçamento de estoque"
Local oDlg01
Local oButSel
Local nOpcA := 0
Local nSnd:= 15,nTLin := 15

Private cArq  := ""
Private cProg := "BKESTA06"

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
	u_WaitLog(cProg, {|oSay| PBKESTA06(oSay)})
Endif

Return Nil


Static Function PBKESTA06(oSay)
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

						cLocaliz := ""
						IF ValType(oExcel:CellRead(nLinha,5)) == "C"
							cLocaliz  := ALLTRIM(oExcel:CellRead(nLinha,5))
						ELSEIF ValType(oExcel:CellRead(nLinha,5)) == "N"
							cLocaliz  := ALLTRIM(STR(oExcel:CellRead(nLinha,5)))
						ENDIF

						AADD(aItens ,{cProd,cLocEst,nQuant,nValor,cLocaliz,nLinha})

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
				u_WaitLog(cProg,{ |oSay| GravEnd(oSay,aItens,aErros)},"Gravando saldos iniciais...")
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
	lOk := MyMata265(nI,aItens[nI,1],aItens[nI,2],aItens[nI,3],aItens[nI,5])
	If !lOk
		aAdd(aErros,{nI,aItens[nI,1],"Não foi possível gravar o endereçamento"})
	EndIf
Next

Return lOK



Static Function MyMata265(nLinha,cProd,cLocEst,nQtd,cLocaliz)

Local aCabSDA       := {}
Local aItSDB        := {}
Local aItensSDB     := {}
Local cItem 		:= "0001"
Local cQrySDA 		:= ""
Local cQrySDB 		:= ""
Local cNumSeq		:= ""
Local lOk 			:= .T.

Private lMsErroAuto := .F.

cQrySDA := "SELECT "
cQrySDA += "    DA_PRODUTO, DA_LOCAL, DA_NUMSEQ, DA_DOC "
cQrySDA += "FROM "
cQrySDA += "    " + RetSQLName('SDA') + " SDA "
cQrySDA += "WHERE "
cQrySDA += "    SDA.D_E_L_E_T_ = ' ' "
cQrySDA += "    AND SDA.DA_FILIAL = '" + xFilial('SDA') + "' "
cQrySDA += "    AND SDA.DA_PRODUTO = '" + cProd + "' "
cQrySDA += "    AND SDA.DA_LOCAL = '" + cLocEst + "' "
cQrySDA += "    AND SDA.DA_ORIGEM = 'SB9' "
// cQrySDA += "    AND SDA.DA_DOC = '" + SDA->DA_DOC + "' "
// cQrySDA += "    AND SDA.DA_NUMSEQ = '" + SDA->DA_NUMSEQ + "' "

TcQuery cQrySDA New Alias 'SQL1'

SQL1->(DBGoTop())
cNumSeq := SQL1->DA_NUMSEQ
SQL1->(DBCloseArea())

cQrySDB := "SELECT MAX(DB_ITEM) DB_ITEM "
cQrySDB += "FROM " + RetSQLName('SDB') + " SDB "
cQrySDB += "WHERE SDB.D_E_L_E_T_ = ' ' "
cQrySDB += "AND SDB.DB_FILIAL = '"  + xFilial('SDB') + "' "
cQrySDB += "AND SDB.DB_PRODUTO = '" + cProd + "' "
cQrySDB += "AND SDB.DB_LOCAL = '"   + cLocEst + "' "
cQrySDB += "AND SDB.DB_NUMSEQ = '"  + cNumSeq + "' "

TcQuery cQrySDB New Alias 'SQL2'

If SQL2->(!EOF())
	cItem := StrZero(Val(SQL2->DB_ITEM) + 1, TamSX3('DB_ITEM')[1])
Else
	cItem := StrZero(1, TamSX3('DB_ITEM')[1])
EndIf

SQL2->(DBCloseArea())

//Cabecalho com a informação do item e NumSeq que sera endereçado.

aCabSDA := {{"DA_PRODUTO" ,cProd,Nil},;
			{"DA_LOCAL"	  ,cLocEst, Nil},;
            {"DA_NUMSEQ"  ,cNumSeq,Nil}}
 
//Dados do item que será endereçado
aItSDB :=  {{"DB_ITEM"    ,cItem      ,Nil},;
            {"DB_ESTORNO" ," "         ,Nil},;
            {"DB_LOCALIZ" ,cLocaliz    ,Nil},;
            {"DB_DATA"    ,dDataBase   ,Nil},;
            {"DB_QUANT"   ,nQtd        ,Nil}}

aAdd(aItensSDB,aitSDB)
 
//Executa o endere?amento do item
Begin Transaction
	MATA265( aCabSDA, aItensSDB, 3)
	If lMsErroAuto
		u_LogMsExec(cProg,"Erro no endereçamento: "+cProd+" Linha: "+STR(nLinha,5)+" Endereço: "+cLocaliz)
		lOk := .F.
	EndIf
End Transaction
Return lOk

