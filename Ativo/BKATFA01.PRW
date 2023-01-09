#include "PROTHEUS.CH"
#include "TopConn.ch"
#include "RwMake.ch" 

/*/{Protheus.doc} BKATFA01
BK - Importar planilha excel em CSV e importação do Ativo Fixo
@Return
@author Adilson Prado
@since 17/12/2019 
@version P12
/*/

User Function BKATFA01()
Local cTipoArq := "Arquivos no formato CSV (*.CSV) | *.CSV | "
Local cTitulo  := "Importar planilha excel em CSV para importação do Ativo Fixo"
Local oDlg01
Local oButSel
Local nOpcA := 0
Local nSnd:= 15,nTLin := 15

Private cArq  := ""
Private cProg := "BKATFA01"

u_MsgLog(cProg)

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
	u_WaitLog(, {|| PBKATFA01()})
Endif

RETURN NIL


Static FUNCTION PBKATFA01()
Local aLINHA     := {}
Local cBuffer    := ""
Local lOk 		 := .T.
Local aCab       := {}
Local aItens     := {}
//Local cConta     := ""

FT_FUSE(cArq)  //abrir
FT_FGOTOP() //vai para o topo
Procregua(FT_FLASTREC())  //quantos registros para ler
FT_FSKIP()   //proximo registro - pular cabeçalho

While !FT_FEOF()
 
	//IncProc('Carregando Itens da Planilha...')

	//Capturar dados
	cBuffer := FT_FREADLN()  //lendo a linha
	If ( !Empty(cBuffer) )
		aLINHA := {}
		aLINHA := U_StringToArray(cBuffer,";") //Retorna Array sem colunas com valores em branco
		IF LEN(aLINHA) >= 18 
/*
     1	           2	          3	             4	                 5	                        6	       7	                        8	           
   CODIGO_ATIVO	NUM_ITEM	DATA_AQUISIÇÃO	DESCRIÇÃO_DO_BEM	DESCRIÇÃO_COMPLETA_DO_BEM	QUANTIDADE	NUMERO_PATRIMONIO	Classificação de Patrimônio 
       9	         10	             11	      12	  13	       14	       15	             16	         17	        18	                19	       20       21
   	HISTORICO	CENTRO_CUSTO	FORNECEDOR	LOJA	SERIE_NF	NUMERO_NF	DATA_GARANTIA	 VALOR_DO_BEM 	ITEM	NOME_RESPONSÁVEL	LOCALIZAÇÃO	 ATIVO   PRODUTO
  */
            aLINHA[4]  := Acento(ALLTRIM(aLINHA[4]))
            aLINHA[5]  := Acento(ALLTRIM(aLINHA[5]))
            aLINHA[8]  := STRZERO(VAL(aLINHA[8]),3)
            aLINHA[10] := STRTRAN(aLINHA[10],".","")
            aLINHA[10] := STRZERO(VAL(aLINHA[10]),9)
			aLINHA[16] := STRTRAN(aLINHA[16],"R$","")
			aLINHA[16] := STRTRAN(aLINHA[16],".","")
			aLINHA[16] := STRTRAN(aLINHA[16],",",".")
	        //cConta     := Posicione()

            aCab := { {'N1_FILIAL',xFilial("SN1"),NIL},;
                      {'N1_CBASE'  ,STRZERO(VAL(aLINHA[7]),6) ,NIL},;
                      {'N1_ITEM'   ,'0001',NIL},;
                      {'N1_AQUISIC',CTOD(aLINHA[3]),NIL},;
                      {'N1_DESCRIC',SUBSTR(aLINHA[4],1,GetSx3Cache("N1_DESCRIC", "X3_TAMANHO")) ,NIL},;
                      {'N1_QUANTD' , VAL(aLINHA[6]) ,NIL},;
                      {'N1_CHAPA'  ,STRZERO(VAL(aLINHA[7]),6) ,NIL},;
                      {'N1_CODBAR' ,STRZERO(VAL(aLINHA[7]),6),NIL},;
                      {'N1_PATRIM' ,'N',NIL},;
                      {'N1_GRUPO'  ,aLinha[8] ,NIL},;
                      {'N1_LOCAL'  ,IIF(EMPTY(aLinha[19]),"000001",STRZERO(VAL(aLinha[19]),6)) ,NIL},;
                      {'N1_NSERIE' ,ALLTRIM(aLINHA[13]) ,NIL},;
                      {'N1_NFISCAL',STRZERO(VAL(aLINHA[14]),9) ,NIL},;
                      {'N1_DETPATR','06' ,NIL},;
                      {'N1_UTIPATR','9' ,NIL},;
                      {'N1_FORNEC' ,aLINHA[11] ,NIL},;
                      {'N1_LOJA' ,aLINHA[12] ,NIL},;
                      {'N1_PRODUTO' ,aLINHA[21] , NIL}}

                    
            aItensAux := {}
            AAdd(aItensAux,{'N3_FILIAL' ,xFilial("SN3"),NIL})
            AAdd(aItensAux,{'N3_TIPO'   ,'01' , NIL})
            AAdd(aItensAux,{'N3_HISTOR' ,SUBSTR(aLINHA[4],1,GetSx3Cache("N3_HISTOR", "X3_TAMANHO")), NIL})
            AAdd(aItensAux,{'N3_DESCEST',aLINHA[5], NIL})
            AAdd(aItensAux,{'N3_TPSALDO','1', NIL})
            AAdd(aItensAux,{'N3_TPDEPR' ,'1', NIL})
            AAdd(aItensAux,{'N3_VORIG1' , VAL(aLINHA[16]) , NIL})
            AAdd(aItensAux,{'N3_DINDEPR',CTOD(aLINHA[3]) ,NIL})
            AAdd(aItensAux,{'N3_CUSTBEM',aLINHA[10], NIL})
            //AAdd(aItensAux,{'N3_CCONTAB',aLINHA[] , NIL})
            aItens := {}
            aAdd(aItens,aItensAux)
            Myatfa010Inc(aCab,aItens)

 		ENDIF
    ENDIF
	FT_FSKIP()   //proximo registro no arquivo csv
Enddo
FT_FUSE()  //fecha o arquivo CSV

RETURN lOk 


Static Function Myatfa010Inc(aCab,aItens)
Local aParam	:= {}

Private lMsHelpAuto := .f. // Determina se as mensagens de help devem ser direcionadas para o arq. de log
Private lMsErroAuto := .f. // Determina se houve alguma inconsistencia na execucao da rotina

aAdd( aParam, {"MV_PAR01", 2} )
aAdd( aParam, {"MV_PAR02", 1} )
aAdd( aParam, {"MV_PAR03", 2} )

Begin Transaction

    MSExecAuto({|x,y,z| Atfa012(x,y,z)},aCab,aItens,3,aParam)
    If lMsErroAuto 
        u_LogMsExec(cProg)
        DisarmTransaction()
    Endif
End Transaction

Return NIL


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
