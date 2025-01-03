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
BK - Integração Financeira - Folha ADP
@Return
@author Marcos Bispo Abrahão
@since 02/01/2025
@version P12
/*/

/*
User Function BKFINA05()
Private cString   := "SZ2"
Private cCadastro := "Integração Financeira - Folha "+FWEmpName(cEmpAnt)
Private cPrw      := "BKFINA05"

Private aRotina
private lMsErroAuto := .F.      

u_MsgLog(cPrw)

dbSelectArea("SZ2")
dbSetOrder(1)
DbGoTop()

aRotina := {{"Pesquisar"				,"AxPesqui"		,0, 1},;
			{"Visualizar"				,"AxVisual"		,0, 2},;
            {"Importar TXT Folha ADP"	,"U_BKFIN5A()"	,0, 3}}

mBrowse(6,1,22,75,cString)

Return
*/

/*/{Protheus.doc} BKFINA05
BK - Importar txt lançamentos da Folha ADP

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
Private aAcao := {"1-Incluir","2-Alterar","3-Excluir"}

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

		cTitulo	:= SUBSTR(cBuffer,nPos,9)
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

		cValor := SUBSTR(cBuffer,nPos,12)
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
Next

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

oPExcel:AddColX3("Z2_E2NUM")
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

dbSelectArea("SZ2")

ASORT(aCtrId,,,{|x,y| x[XTITULO]<y[XTITULO]})

For nI := 1 To Len(aLinha)

	If Empty(cLote)
		cLote := aLinha[nI,XTITULO]
	EndIf
	If aLinha[nI,XTITULO] <> cLote
		cCtrId	:= DTOS(date())+SubStr( TIME(), 1, 2 )+SubStr( TIME(), 4, 2 )+SubStr( TIME(), 7, 2 )
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
	
	SZ2->Z2_CTRID	:= cCtrId
	SZ2->Z2_PRONT	:= "00000"
	SZ2->Z2_NOME	:= "ADP"
	SZ2->Z2_STATUS	:= " "
	SZ2->Z2_USUARIO	:= cUserName
	SZ2->Z2_PRODUTO	:= "21301001"
	SZ2->Z2_TIPOPES	:= "CLT"

	MsUnlock()

Next

Return lOk
