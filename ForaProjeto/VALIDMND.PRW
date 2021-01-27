#include "PROTHEUS.CH"
#include "TopConn.ch"
#include "RwMake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao ณVALIDMND บAutorณ Adilson do Prado - Proativa บData ณ08/11/2017บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.  ณ                        ฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso    ณBK                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function VALIDMND()
Local nSnd:= 15,nTLin := 15
Local cTipoArq := "Todos os Arquivos (*.TXT) | *.TXT | "
Local CPROG	   := "VALIDMND"
Local ctitulo  := "Analisa MND"
Local oDlg01,nOpcA := 0
Local lOk:= .F.

Private cArq   := ""
Private aArq   := {}
Private cDir   := ""
Private cMESANOI := "200901"
Private cMESANOF := "200913"
Private a0000 := {}
Private a0001 := {}
Private a0990 := {}
Private aI001 := {}
Private aI990 := {}
Private aK001 := {}
Private aK050 := {}
Private aK100 := {}
Private aK150 := {}
Private aK200 := {}
Private aK250 := {}
Private aK300 := {}
Private aK990 := {}
Private a9001 := {}
Private a9900 := {}
Private a9990 := {}
Private a9999 := {}


DEFINE MSDIALOG oDlg01 FROM  96,9 TO 220,392 TITLE OemToAnsi(cProg+" - "+cTitulo) PIXEL

@ nSnd,010  SAY "Arquivo: " of oDlg01 PIXEL 
@ nSnd,035  MSGET cArq SIZE 100,010 of oDlg01 PIXEL READONLY
@ nSnd,142 BUTTON oButSel PROMPT 'Selecionar' SIZE 40, 12 OF oDlg01 ACTION ( cArq := cGetFile(cTipoArq,"Selecione o diret๓rio contendo os arquivos",,cArq,.F.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY,.F.,.T.)  ) PIXEL  // "Selecionar" 
nSnd += nTLin
nSnd += nTLin

DEFINE SBUTTON FROM nSnd, 125 TYPE 1 ACTION (oDlg01:End(),nOpcA:=1) ENABLE OF oDlg01
DEFINE SBUTTON FROM nSnd, 155 TYPE 2 ACTION (oDlg01:End(),,nOpcA:=0) ENABLE OF oDlg01


ACTIVATE MSDIALOG oDlg01 CENTER 

If nOpcA == 1
	Processa( {|| procsolc()})
	nOpcA:=0
Endif

RETURN lOk


Static Function ProcSolc()
Local aLINHA  := {}
Local nLINHA  := 0
Local cBuffer := ''

FT_FUSE(cArq)  //abrir
FT_FGOTOP() //vai para o topo
Procregua(FT_FLASTREC())  //quantos registros para ler
 
While !FT_FEOF()
 
	IncProc('Lendo Linha...')
 	nLINHA++
	//Capturar dados
	cBuffer := FT_FREADLN()  //lendo a linha
	If ( !Empty(cBuffer) )
		aLINHA := {}
		aLINHA := StrTokArr(cBuffer,"|")
		cBloco := ""
		cBloco := "a"+aLINHA[1]
		AADD(&cBloco,{nLINHA,aLINHA})
    ENDIF
	FT_FSKIP()   //proximo registro no arquivo txt
Enddo
FT_FUSE()  //fecha o arquivo txt

MSGINFO("Arquivo lido com sucesso!!")

RETURN NIL 



