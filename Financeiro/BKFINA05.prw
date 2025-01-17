#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"


#DEFINE XACAO		01
#DEFINE XEMPRESA	02
#DEFINE XTITULO		03
#DEFINE XPORTADOR	04
#DEFINE XTIPOPAG	05
#DEFINE XEMISSAO	06
#DEFINE XVENCTO		07
#DEFINE XHIST		08
#DEFINE XVALOR		09
#DEFINE XCC			10
#DEFINE XDESCCC		11
#DEFINE XERROS		12

/*/{Protheus.doc} BKFINA05
BK - Importar txt lançamentos da Folha ADP

Pasta FTP: \\vmfileserver\G$\ADP\Inbox\processados

@Return
@author Marcos Bispo Abrahão
@since 01/01/2025
@version P12
/*/

User Function BKFINA05()

Local cTipoArq	:= "Arquivos no formato TXT (*.TXT) | *.TXT | "
Local cTitulo	:= "Importar arquivo TXT de Lançamentos da Folha ADP"
Local oDlg01
Local oButSel
Local nOpcA		:= 0
Local nSnd		:= 15
Local nTLin		:= 15
Local lValid 	:= .T.
Local aLinha 	:= {}

Private cArq	:= ""
Private cProg	:= "BKFINA05"
Private aAcao	:= {"1-Incluir","2-Alterar","3-Excluir"}
Private nTotZ2	:= 0
Private cLote 	:= ""

u_MsgLog(cProg)

DEFINE MSDIALOG oDlg01 FROM  100,10 TO 250,470 TITLE cProg+" - "+cTitulo PIXEL

@ nSnd,010  SAY "Arquivo TXT ADP: " of oDlg01 PIXEL 
@ nSnd -3,057 MSGET cArq SIZE 150,010 of oDlg01 PIXEL READONLY
nSnd += nTLin
@ nSnd -3,057 BUTTON oButSel PROMPT 'Selecionar' SIZE 40, 12 OF oDlg01 ACTION ( cArq := cGetFile(cTipoArq,"Selecione o arquivo TXT da ADP",,cArq,.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY,.F.,.T.)  ) PIXEL  // "Selecionar" 
nSnd += nTLin

DEFINE SBUTTON FROM nSnd, 125 TYPE 1 ACTION (oDlg01:End(),nOpcA:=1) ENABLE OF oDlg01
DEFINE SBUTTON FROM nSnd, 155 TYPE 2 ACTION (oDlg01:End(),,nOpcA:=0) ENABLE OF oDlg01

ACTIVATE MSDIALOG oDlg01 CENTER

If nOpcA == 1
	nOpcA:=0
	If File(cArq)
		u_WaitLog(cProg, {|| aLinha := PFIN5I()}, "Carregando arquivo TXT...")
		If !Empty(aLinha)
			u_WaitLog(cProg, {|| lValid := PFIN5V(aLinha)}, "Validando dados...")
			If lValid
				If u_MsgLog(cProg,"Lançamentos validados com sucesso, deseja imprimir o lote?","Y")
					PFIN5E(aLinha)
				EndIf
				If u_MsgLog(cProg,"Confirma a importação dos lançamentos do lote?","Y")
					u_WaitLog(cProg, {|| lValid := PFIN5Z2(aLinha)}, "Importando dados...")
					If lValid
						u_MsgLog(cProg,"Lançamentos importados: "+ALLTRIM(STR(SZ2->Z2_VALOR,14,2))+" lote "+cLote,"S")

						MoveArq(cArq)

					Else
						u_MsgLog(cProg,"Lançamentos não importados","E")
					EndIf
				EndIf
			Else
				If u_MsgLog(cProg,"Foram encontrados erros, deseja imprimir a relação de erros?","Y")
					PFIN5E(aLinha)
				EndIf
			EndIf
		Else
			u_MsgLog(cProg,"Lançamentos não importados, verifique o conteudo do arquivo "+cArq,"E")
		EndIf
	Else
		u_MsgLog(cProg,"Arquivo "+TRIM(cArq)+" não encontrado","E")
	EndIf
Endif

RETURN NIL


Static Function MoveArq(cArq)
Local cDrive, cDir, cNome, cExt
Local cArqPrc	:= ""

SplitPath( cArq, @cDrive, @cDir, @cNome, @cExt )

If Empty(cDir)
	cDir := "\"
EndIf
cDir += "processados\"
MakeDir(cDrive+cDir)

cExt :=  ".PRC"

cArqPrc := cDrive+cDir+cNome+cExt
FRename(cArq,cArqPrc)

u_MsgLog(cProg,"Arquivo movido para: "+cArqPrc,"I")

Return Nil

Static FUNCTION PFIN5I()
Local cBuffer   := ""
Local nPos		:= 0
Local aLinha	:= {}

Local cAcao		:= ""
Local cEmpresa	:= ""
Local cTitulo 	:= ""
Local cPortador	:= ""
Local cTipoPag	:= ""
Local cEmissao	:= ""
Local cVencto 	:= ""
Local cHist 	:= ""
Local cValor 	:= ""
Local nValor 	:= 0
Local cCC 		:= ""

cLote := ""

FT_FUSE(cArq)  //abrir
FT_FGOTOP() //vai para o topo

While !FT_FEOF()
 
	//Capturar dados
	cBuffer := ""
	cBuffer := FT_FREADLN()  //lendo a linha
	//u_xxLog(u_SLogDir()+"BKCTBA04.LOG","1-"+cBuffer)

	If ( !Empty(cBuffer) )
		nPos := 1

		cAcao	:= SUBSTR(cBuffer,nPos,1)
		nPos += 1

		cEmpresa := SUBSTR(cBuffer,nPos,2)
		nPos += 2

		cTitulo	:= "ADP"+SUBSTR(cBuffer,nPos,9)
		If Empty(cLote)
			cLote := cTitulo
		EndIf
		nPos += 9

		cPortador := SUBSTR(cBuffer,nPos,3)
		nPos += 3

		cTipoPag := SUBSTR(cBuffer,nPos,4)
		nPos += 4

		cEmissao := STOD(SUBSTR(cBuffer,nPos,8))
		nPos += 8

		cVencto := STOD(SUBSTR(cBuffer,nPos,8))
		nPos += 8

		// Evdescr -> Aumentado de 25 para 50 ADP 28/11/2024
		cHist := SUBSTR(cBuffer,nPos,80)
		nPos += 80

		cValor := SUBSTR(cBuffer,nPos,14)
		nValor := VAL(cValor) / 100
		nPos += 14

		cCC := SUBSTR(cBuffer,nPos,9)
		nPos += 9

		//aAdd(aLinha,{cEmpresa,cAnoMes,cCC,"",cDebito,"",cCredito,"",cEvento,cEvDescr,nValor,dDataArq,""})
		//cCC := "000000001"  // Teste
		aAdd(aLinha,{cAcao,cEmpresa,cTitulo,cPortador,cTipoPag,cEmissao,cVencto,cHist,nValor,cCC,"",""})

    ENDIF
	FT_FSKIP()   //proximo registro no arquivo txt
Enddo
FT_FUSE()  //fecha o arquivo txt

RETURN aLinha


// Validação dos dados
Static Function PFIN5V(aLinha)
Local nI	:= 0
Local cErros:= ""
Local lOk 	:= .T.
Local aLotes:= {}

CTT->(dbSetOrder(1))

For nI := 1 To Len(aLinha)

	cErros := ""

	If aLinha[nI,XACAO] <> '1' .OR. !(aLinha[nI,XACAO] $ '123')
		cErros += "Ação não disponível "+IIF(aLinha[nI,XACAO] $ '123',aAcao[VAL(aLinha[nI,XACAO])],TRIM(aLinha[nI,XACAO]))+"; "+CRLF
	EndIf

	If aLinha[nI,XEMPRESA] <> cEmpAnt
		cErros += "Empresa não correspondente "+TRIM(aLinha[nI,XEMPRESA])+"; "+CRLF
	EndIf

	If !Empty(aLinha[nI,XCC])
		If !CTT->(dbSeek(xFilial("CTT")+TRIM(aLinha[nI,XCC])))
			cErros += "Centro de custo "+TRIM(aLinha[nI,XCC])+" não cadastrado; "+CRLF
		EndIf
		aLinha[nI,XDESCCC] := CTT->CTT_DESC01
	EndIf

	aLinha[nI,XERROS] := cErros
	If !Empty(cErros)
		lOk := .F.
	EndIf

	If aScan(aLotes,aLinha[nI,XTITULO]) == 0
		aAdd(aLotes,aLinha[nI,XTITULO])
	EndIf
Next

//Consistir Lotes
If lOk
	lOk := VldLote(aLotes)
EndIf

Return lOk



Static Function PFIN5E(aLinha)
Local cTitulo	:= "Relação de Lote Financeiro - ADP"
Local cDescr 	:= "O objetivo deste relatório é a impressão de lote via arquivo TXT fornecido pela ADP."
Local cVersao	:= "02/01/2025"
Local oRExcel	AS Object
Local oPExcel	AS Object

// Definição do Arq Excel
oRExcel := RExcel():New(cProg)
oRExcel:SetTitulo(cTitulo)
oRExcel:SetVersao(cVersao)
oRExcel:SetDescr(cDescr)
oRExcel:SetParam({})

// Definição da Planilha 1
oPExcel:= PExcel():New(cProg,aLinha)
oPExcel:SetTitulo("Arquivo: "+cArq)

// Colunas da Planilha 1
//aAcao[VAL(xCampo)]
oPExcel:AddCol("ACAO","aAcao[VAL(xCampo)]","Ação","")
oPExcel:GetCol("ACAO"):SetTamanho(9)

oPExcel:AddCol("EMPRESA","u_BKNEmpr(xCampo,3)","Empresa","")
oPExcel:GetCol("EMPRESA"):SetTamanho(9)

oPExcel:AddColX3("Z2_CTRID")
oPExcel:AddColX3("Z2_BANCO")
oPExcel:AddColX3("Z2_TIPO")

oPExcel:AddColX3("Z2_DATAEMI")
oPExcel:AddColX3("Z2_DATAPGT")
oPExcel:AddColX3("Z2_OBSTITU")

oPExcel:AddColX3("Z2_VALOR")
oPExcel:GetCol("Z2_VALOR"):SetTotal(.T.)

oPExcel:AddColX3("Z2_CC")

oPExcel:AddColX3("CTT_DESC01")
oPExcel:GetCol("CTT_DESC01"):SetTitulo("Descrição do Centro de Custos")

oPExcel:AddCol("ERROS","","Erros","")
oPExcel:GetCol("ERROS"):SetTamanho(200)

// Adiciona a planilha 1
oRExcel:AddPlan(oPExcel)

// Cria arquivo Excel
oRExcel:Create()

Return Nil



// Importando Dados para a Tabela SZ2
Static Function PFIN5Z2(aLinha)
Local nI		:= 0
Local lOk		:= .T.
Local cCtrId	:= DTOS(date())+SubStr( TIME(), 1, 2 )+SubStr( TIME(), 4, 2 )+SubStr( TIME(), 7, 2 )
Local cLote		:= ""

nTotZ2 := 0

dbSelectArea("SZ2")

ASORT(aLinha,,,{|x,y| x[XTITULO]<y[XTITULO]})

For nI := 1 To Len(aLinha)

	If aLinha[nI,XTITULO] <> cLote .OR. Empty(cLote)
		cLote 	:= aLinha[nI,XTITULO]
		cCtrId	:= cLote // DTOS(date())+SubStr( TIME(), 1, 2 )+SubStr( TIME(), 4, 2 )+SubStr( TIME(), 7, 2 )
	EndIf

	RecLock("SZ2",.T.)
	SZ2->Z2_FILIAL	:= xFilial("SZ2")
	SZ2->Z2_CODEMP	:= aLinha[nI,XEMPRESA]
	SZ2->Z2_E2NUM	:= aLinha[nI,XTITULO]
	SZ2->Z2_BANCO	:= aLinha[nI,XPORTADOR]
	SZ2->Z2_TIPO	:= aLinha[nI,XTIPOPAG]
	SZ2->Z2_DATAEMI	:= aLinha[nI,XEMISSAO]
	SZ2->Z2_DATAPGT	:= aLinha[nI,XVENCTO]
	SZ2->Z2_OBSTITU	:= aLinha[nI,XHIST]
	SZ2->Z2_VALOR	:= aLinha[nI,XVALOR]
	SZ2->Z2_CC		:= aLinha[nI,XCC]
	
	SZ2->Z2_DORIPGT	:= aLinha[nI,XVENCTO]

	SZ2->Z2_CTRID	:= cCtrId
	SZ2->Z2_PRONT	:= "000000"
	SZ2->Z2_NOME	:= "LOTE ADP "+aLinha[nI,XTITULO]
	SZ2->Z2_STATUS	:= " "
	SZ2->Z2_USUARIO	:= cUserName
	SZ2->Z2_PRODUTO	:= "21301001"
	SZ2->Z2_TIPOPES	:= "CLT"

	nTotZ2 += aLinha[nI,XVALOR]

	MsUnlock()

Next

Return lOk



Static Function VldLote(aLotes)
Local cQuery        := ""
Local aReturn       := {}
Local aBinds        := {}
Local aSetFields    := {}
Local nRet          := 0
Local nI            := 0
Local nLotes 		:= 0
Local lOk 			:= .T.
Local cLotes 		:= ""

For nI := 1 TO LEN(aLotes)

    If nI > 1
        cQuery += "UNION ALL "+CRLF
    EndIf
    cQuery += "SELECT COUNT(*) AS NLOTES"+CRLF 
    cQuery += " FROM "+RETSQLNAME("SZ2")+" SZ2 "+CRLF
    cQuery += " WHERE Z2_CTRID = '"+aLotes[nI]+"' AND D_E_L_E_T_ = ' ' "+CRLF

	cLotes += aLotes[nI]+" "
Next 

//aadd(aBinds,xFilial("SA1")) // Filial
//aadd(aBinds,"000281") // Codigo
//aadd(aBinds,"01") // Loja

// Ajustes de tratamento de retorno
aadd(aSetFields,{"NLOTES"   ,"N",5,0})

//aadd(aSetFields,{"A1_ULTVIS","D",8,0})

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

If nRet < 0
  u_MsgLog("BKFINA05-L",tcsqlerror()+" - Falha ao executar a Query: "+cQuery,"E")
Else
  //Alert(VarInfo("aReturn",aReturn))
  //MsgInfo("Verifique os valores retornados no console","Ok")
  If Len(aReturn) > 0
	nLotes := aReturn[1][1]
	If nLotes > 0
		lOk := .F.
		u_MsgLog("BKFINA05-V","Lote(s) já importado(s): "+cLotes+", verifique o arquivo","E")
	EndIf
  EndIf
Endif
Return lOk
