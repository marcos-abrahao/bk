
#include "PROTHEUS.CH"
#include "TopConn.ch"
#include "RwMake.ch" 

/*/{Protheus.doc} BKCOMA12
BK - Importar planilha excel em CSV para inclusão de produtos
@Return
@author Adilson Prado
@since 22/12/2021 
@version P12
/*/

User Function BKCOMA12()
Local cProg := "BKCOMA12"
Local cTipoArq := "Arquivos no formato CSV (*.CSV) | *.CSV | "
Local cTitulo  := "Importar planilha excel em CSV para inclusão de produtos"
Local oDlg01
Local oButSel
Local nOpcA := 0
Local nSnd:= 15,nTLin := 15

PRIVATE cArq  := ""

u_LogPrw("BKCOMA12")

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
	Processa( {|| PBKCOMA12()})
Endif

RETURN NIL


Static FUNCTION PBKCOMA12()
Local aProd      := {}
Local cBuffer    := ""
Local lOk 		 := .T.
Local nLin 		 := 0

FT_FUSE(cArq)  //abrir
FT_FGOTOP() //vai para o topo
Procregua(FT_FLASTREC())  //quantos registros para ler
FT_FSKIP()   //proximo registro - pular cabeçalho

While !FT_FEOF()
 
	IncProc('Carregando Itens da Planilha...')
    nLin++

	//Capturar dados
	cBuffer := FT_FREADLN()  //lendo a linha
	If ( !Empty(cBuffer) )
		aProd := {}
		aProd := U_StringToArray(cBuffer,";") //Retorna Array sem colunas com valores em branco
        IF LEN(aProd)>=9

            /*
            DESCRIÇÃO
            TIPO
            UN	
            ARMAZEM PAD.	
            GRUPO	
            SUB GRUPO	
            GRUPO FIN BK	
            TE PADRAO	
            CTA CONTABIL
            */
            IF !U_IBKCOMA12(aProd)
                MSGSTOP("Erro na linha "+STR(nLin,8))
                lOk := .F.
                RETURN lOk         
            ENDIF
        ELSE
            MSGSTOP("Erro na leitura da linha "+STR(nLin,8))
            lOk := .F.
            RETURN lOk         
        ENDIF
    ENDIF
	FT_FSKIP()   //proximo registro no arquivo csv
Enddo
FT_FUSE()  //fecha o arquivo CSV

RETURN lOk 


User Function IBKCOMA12(aProd)

Local lRet := .T.
Local _aProd := {}
Local cCodProd := ""
Local cErrLog := ""

Private lMsErroAuto := .F.

    cCodProd := PXNUMSB1("INS")

    _aProd  := {{"B1_COD"     ,cCodProd         ,Nil},;
                {"B1_DESC"    ,Acento(aProd[1]) ,Nil},;                      
                {"B1_TIPO"    ,aProd[2]         ,Nil},;      
                {"B1_UM"      ,UPPER(aProd[3])  ,Nil},;
                {"B1_LOCPAD"  ,aProd[4]         ,Nil},;                      
                {"B1_GRUPO"   ,aProd[5]         ,Nil},;                      
                {"B1_XXSGRP"  ,aProd[6]         ,Nil},;                      
                {"B1_XXGRPF"  ,aProd[7]         ,Nil},;                      
                {"B1_TE"      ,aProd[8]         ,Nil},;                      
                {"B1_CONTA"   ,aProd[9]         ,Nil}}                      

    lMsErroAuto := .F.    
            
    MSExecAuto({|x,y| Mata010(x,y)},_aProd,3) //Inclusão 

    If lMsErroAuto
		cErrLog:= CRLF+MostraErro("\TMP\","BKCOMA12.ERR")
		u_xxLog("\TMP\BKCOMA12.LOG",cErrLog)
		MsgStop("Problemas na execução do MsExecAuto, informe o setor de T.I.:"+cErrLog,"Atenção")
        lRet := .F.
    EndIf
  
Return lRet



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


Static Function PXNUMSB1(cSubPdt)
LOCAL cQuery := ""
LOCAL nCod   := 0

cQuery := " SELECT TOP 1 SUBSTRING(B1_COD,4,6) AS B1_COD1 from "+RETSQLNAME("SB1")+" WHERE D_E_L_E_T_='' AND SUBSTRING(B1_COD,1,3)='"+cSubPdt+"' "  
cQuery += " 	AND SUBSTRING(B1_COD,11,1) = ' ' "   // para não estourar a quantidade de casas do INT
cQuery += " ORDER BY CAST(SUBSTRING(B1_COD,4,6) AS INT) DESC "
TCQUERY cQuery NEW ALIAS "QSB1"


dbSelectArea("QSB1")	
QSB1->(dbGoTop()) 
	
IF VAL(QSB1->B1_COD1) > nCod
	nCod := VAL(QSB1->B1_COD1)
ENDIF
QSB1->(Dbclosearea())

nCod++
cCod := cSubPdt+STRZERO(nCod,IIF(nCod>999,4,3))

Return(cCod)
