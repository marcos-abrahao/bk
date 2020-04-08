#include "PROTHEUS.CH"
#include "TopConn.ch"
#include "RwMake.ch" 

/*/{Protheus.doc} BKCTBA04
BK - Importar planilha excel em CSV e converter para txt padrao lancamento da Contabilidade

@Return
@author Adilson do Prado / Marcos Bispo Abrahão
@since 12/02/2019
@version P12
/*/

User Function BKCTBA04()

Local cTipoArq := "Arquivos no formato CSV (*.CSV) | *.CSV | "
Local cTitulo  := "Importar planilha excel em CSV para gerar o arquivo TXT de Lançamento Padrão da Contabilidade"
Local oDlg01
Local oButSel
Local nOpcA := 0
Local nSnd:= 15,nTLin := 15

Private cArq  := ""
Private cProg := "BKCTBA04"

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
	Processa( {|| ProcBKCT04()})
Endif

RETURN NIL


Static FUNCTION ProcBKCT04()
Local aLINHA     := {}
Local cBuffer    := ""
Local cArq2		 := ""
Local cCrLf   	 := Chr(13) + Chr(10) 
Local lOk 		 := .T.

cArq2 := "C:\LP001\BKCT04.TXT"
MakeDir("C:\LP001\")
nHandle := MsfCreate(cArq2,0)


FT_FUSE(cArq)  //abrir
FT_FGOTOP() //vai para o topo
Procregua(FT_FLASTREC())  //quantos registros para ler
While !FT_FEOF()
 
	IncProc('Carregando Itens da Planilha...')

	//Capturar dados
	cBuffer := FT_FREADLN()  //lendo a linha
	u_xxLog("C:\TMP\BKCTBA04.LOG","1-"+cBuffer,.T.,"TST")
	If ( !Empty(cBuffer) )
		aLINHA := {}
		aLINHA := U_StringToArray(cBuffer,";") //Retorna Array sem colunas com valores em branco
		IF LEN(aLINHA) >= 7  
			aLINHA[5] := STRTRAN(aLINHA[5],"R$","")
			aLINHA[5] := STRTRAN(aLINHA[5],".","")
			aLINHA[5] := STRTRAN(aLINHA[5],",","")
			aLINHA[5] := STRZERO(VAL(aLINHA[5]),16)
			aLINHA[7] := STRTRAN(aLINHA[7],"/","")
			cLinha := ""
			IF VAL(aLINHA[1]) == 1
				cLinha := STRZERO(VAL(aLINHA[1]),3)+PAD(ALLTRIM(aLINHA[2]),1)+PAD(ALLTRIM(aLINHA[3]),20)+PAD(ALLTRIM(aLINHA[4]),20)+aLINHA[5]+PAD(ACENTO(ALLTRIM(aLINHA[6])),100)+PAD(aLINHA[7],8)+SPACE(342)+cCrLf
				u_xxLog("C:\TMP\BKCTBA04.LOG","2-"+cLinha,.T.,"TST")
				fWrite(nHandle,cLinha)
			ENDIF
 		ENDIF
    ENDIF
	FT_FSKIP()   //proximo registro no arquivo txt
Enddo
FT_FUSE()  //fecha o arquivo txt
fClose(nHandle)

MsgInfo("Importe o arquivo "+cArq2+" através da rotina Contabilização Txt",cProg)

//CHAMA ROTINA CONTABILIZA TXT
//CTBA500() - Retirada a chamada direta na versão 12 pois ocorre erro - 08/11/19 - Marcos

RETURN lOk 


Static Function Acento( cTexto )
Local cAcentos:= "Ç ç Ä À Â Ã Å à á ã ä å É È Ê Ë è é ê ë Ì Í Î Ï Ò Ó Ô Õ Ö ò ó ô õ ö Ù Ú Û Ü ù ú û ü Ñ ñ , ; "
Local cAcSubst:= "C c A A A A A a a a a a E E E E e e e e I I I I O O O O O o o o o o U U U U u u u u N n     "
Local cImpCar := ""
Local cImpLin := ""
Local nChar   := 0.00
Local nChars  := 0.00
Local nAt     := 0.00     

cTexto := IF( Empty( cTexto ) .or. ValType( cTexto ) != "C", "" , cTexto )

nChars := Len( cTexto )
For nChar := 1 To nChars
     cImpCar := SubStr( cTexto , nChar , 1 )
     IF ( nAt := At( cImpCar , cAcentos ) ) > 0
          cImpCar := SubStr( cAcSubst , nAt , 1 )
     EndIF
     cImpLin += cImpCar
Next nChar

Return( cImpLin )

