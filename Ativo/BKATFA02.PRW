#include "TOTVS.CH"
#INCLUDE "FILEIO.CH"

/*/{Protheus.doc} BKATFA02
BK - Gerar planilha excel em CSV via Compras para importação no Ativo Fixo
@Return
@author Marcos Bispo Abrahão
@since 21/10/21
@version P12
/*/

User Function BKATFA02()
Local cProg := "BKATFA02"
Local cTipoArq := "Arquivos no formato CSV (*.CSV) | *.CSV | "
Local cTitulo  := "Importar planilha excel em CSV para importação do Ativo Fixo"
Local oDlg01
Local oButSel
Local nOpcA := 0
Local nSnd:= 15,nTLin := 15

PRIVATE cArq  := "C:\TEMP\ATIVOS.CSV"

DEFINE MSDIALOG oDlg01 FROM  96,9 TO 220,392 TITLE OemToAnsi(cProg+" - "+cTitulo) PIXEL

@ nSnd,010 SAY "Arquivo: " of oDlg01 PIXEL 
@ nSnd,035 MSGET cArq SIZE 100,010 of oDlg01 PIXEL READONLY
@ nSnd,142 BUTTON oButSel PROMPT 'Salvar como:' SIZE 40, 12 OF oDlg01 ACTION ( cArq := tFileDialog(cTipoArq,"Selecione o diretório",0,"C:\TMP\",.T.,GETF_RETDIRECTORY) ) PIXEL  // "Selecionar" 
nSnd += nTLin
nSnd += nTLin

DEFINE SBUTTON FROM nSnd, 125 TYPE 1 ACTION (oDlg01:End(),nOpcA:=1) ENABLE OF oDlg01
DEFINE SBUTTON FROM nSnd, 155 TYPE 2 ACTION (oDlg01:End(),nOpcA:=0) ENABLE OF oDlg01


ACTIVATE MSDIALOG oDlg01 CENTER

If nOpcA == 1
	nOpcA:=0
    FWMsgRun(, {|oSay| QBKATFA2() }, "", "Consultando Itens dos Documentos de Entrada...")
    FWMsgRun(, {|oSay| PBKATFA2() }, "", "Gerando arquivo "+cArq+"...")
Endif

RETURN NIL



Static Function QBKATFA2(cTitulo)
Local cQuery
Local dDtIni := CTOD("01/01/2021")
Local dDtFim := CTOD("31/12/2021")

If SELECT("QSD1") > 0 
	dbSelectArea("QSD1")
   	dbCloseArea()
EndIf

cQuery := "SELECT D1_FILIAL,D1_COD,D1_ITEM,B1_DESC,B1_CONTA,D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC AS D1_TOTAL,D1_QUANT,D1_CC,"+CRLF
cQuery += " D1_FORNECE,D1_LOJA,A2_NOME,D1_SERIE,D1_DOC,D1_DTDIGIT, "+CRLF
cQuery += " CONVERT(VARCHAR(6000),CONVERT(Binary(6000),D1_XXHIST)) D1_XXHIST "+CRLF
cQuery += "FROM "+RETSQLNAME("SD1")+" SD1 "
cQuery += " LEFT JOIN "+RETSQLNAME("SA2")+" SA2 ON A2_FILIAL = '"+xFilial("SA2")+"' AND D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D1_COD = B1_COD AND SB1.D_E_L_E_T_ = '' "+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SF4")+" SF4 ON F4_FILIAL = '"+xFilial("SF4")+"' AND D1_TES = SF4.F4_CODIGO AND SF4.D_E_L_E_T_='' "+CRLF

cQuery += "WHERE SD1.D_E_L_E_T_ = ' ' "+CRLF
//cQuery += " AND (B1_TIPO = 'AI' OR F4_ATUATF = 'S' OR SUBSTR(B1_CONTA,1,1) = '1') "+CRLF
cQuery += " AND (B1_TIPO = 'AI' OR F4_ATUATF = 'S') "+CRLF
IF !EMPTY(dDtIni)
	cQuery += "AND D1_DTDIGIT >= '"+DTOS(dDtIni)+"' "+CRLF
ENDIF
IF !EMPTY(dDtFim)
	cQuery += "AND D1_DTDIGIT <= '"+DTOS(dDtFim)+"' "+CRLF
ENDIF

cQuery += "ORDER BY D1_DTDIGIT,D1_DOC "+CRLF

u_LogMemo("BKATFA02.SQL",cQuery)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QSD1",.T.,.T.)

tcSetField("QSD1","D1_DTDIGIT","D",8,0)
tcSetField("QSD1","D1_XXHIST","M",10,0)

Dbselectarea("QSD1")
QSD1->(Dbgotop())

Return nil




Static FUNCTION PBKATFA2()
Local cBuffer    := ""
Local lOk 		 := .T.
Local nHDestino  := 0
Local nBytes     := 0

//Cabeçalho do CSV

/*
     1	           2	          3	             4	                 5	                        6	       7	                        8	           
   CODIGO_ATIVO	NUM_ITEM	DATA_AQUISIÇÃO	DESCRIÇÃO_DO_BEM	DESCRIÇÃO_COMPLETA_DO_BEM	QUANTIDADE	NUMERO_PATRIMONIO	CLASSIFICACAO_PATRIMONIO
       9	         10	             11	      12	  13	       14	       15	             16	         17	        18	                19	       20
   	HISTORICO	CENTRO_CUSTO	FORNECEDOR	LOJA	SERIE_NF	NUMERO_NF	DATA_GARANTIA	 VALOR_DO_BEM 	ITEM	NOME_RESPONSÁVEL	LOCALIZAÇÃO	 ATIVO
  */

cBuffer := "CODIGO_ATIVO;" 
cBuffer += "NUM_ITEM;" 
cBuffer += "DATA_AQUISIÇÃO;" 
cBuffer += "DESCRIÇÃO_DO_BEM;" 
cBuffer += "DESCRIÇÃO_COMPLETA_DO_BEM;" 
cBuffer += "QUANTIDADE;" 
cBuffer += "NUMERO_PATRIMONIO;" 
cBuffer += "CLASSIFICACAO_PATRIMONIO;" 
cBuffer += "HISTORICO;" 
cBuffer += "CENTRO_CUSTO;" 
cBuffer += "FORNECEDOR;" 
cBuffer += "LOJA;" 
cBuffer += "SERIE_NF;" 
cBuffer += "NUMERO_NF;" 
cBuffer += "DATA_GARANTIA;" 
cBuffer += "VALOR_DO_BEM;" 
cBuffer += "ITEM;" 
cBuffer += "NOME_RESPONSÁVEL;" 
cBuffer += "LOCALIZAÇÃO;" 
cBuffer += "ATIVO;"+CRLF

nHDestino := FCREATE(cArq, FC_NORMAL)
nBytes := FWRITE(nHDestino, cBuffer,LEN(cBuffer))


Dbselectarea("QSD1")
Dbgotop()
Do While !Eof()

    cBuffer := ";"   // CODIGO_ATIVO
    cBuffer += ";"   // NUM_ITEM
    cBuffer += DTOC(QSD1->D1_DTDIGIT)+";"   // DATA_AQUISIÇÃO
    cBuffer += QSD1->B1_DESC+";"   // DESCRIÇÃO_DO_BEM
    cBuffer += QSD1->B1_DESC+";"   // DESCRIÇÃO_COMPLETA_DO_BEM
    cBuffer += STR(QSD1->D1_QUANT,5,0)+";"   // QUANTIDADE
    cBuffer += ";"   // NUMERO_PATRIMONIO
    cBuffer += ";"   // CLASSIFICACAO_PATRIMONIO
    cBuffer += ";" //STRTRAN(QSD1->D1_XXHIST,";",",")+";"   // HISTORICO
    cBuffer += QSD1->D1_CC+";"   // CENTRO_CUSTO
    cBuffer += QSD1->D1_FORNECE+";"   // FORNECEDOR
    cBuffer += QSD1->D1_LOJA+";"   // LOJA
    cBuffer += QSD1->D1_SERIE+";"   // SERIE_NF
    cBuffer += QSD1->D1_DOC+";"   // NUMERO_NF
    cBuffer += ";"   // DATA_GARANTIA
    cBuffer += STR(QSD1->D1_TOTAL,16,2)+";"   // VALOR_DO_BEM
    cBuffer += "001;"   // ITEM
    cBuffer += ";"   // NOME_RESPONSÁVEL
    cBuffer += ";"   // LOCALIZAÇÃO
    cBuffer += ";"   // ATIVO

    cBuffer += CRLF 

    nBytes := FWRITE(nHDestino, cBuffer,LEN(cBuffer))

    dbSkip()
EndDo

FCLOSE(nHDestino)  //fecha o arquivo CSV

RETURN lOk 


