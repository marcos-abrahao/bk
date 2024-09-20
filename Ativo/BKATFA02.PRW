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

u_MsgLog(cProg)

PRIVATE cArq  := "C:\TEMP\ATIVOS.CSV"

DEFINE MSDIALOG oDlg01 FROM  96,9 TO 220,392 TITLE OemToAnsi(cProg+" - "+cTitulo) PIXEL

@ nSnd,010 SAY "Arquivo: " of oDlg01 PIXEL 
@ nSnd,035 MSGET cArq SIZE 100,010 of oDlg01 PIXEL READONLY
@ nSnd,142 BUTTON oButSel PROMPT 'Salvar como:' SIZE 40, 12 OF oDlg01 ACTION ( cArq := tFileDialog(cTipoArq,"Selecione o diretório",0,u_LTmpDir(),.T.,GETF_RETDIRECTORY) ) PIXEL  // "Selecionar" 
nSnd += nTLin
nSnd += nTLin

DEFINE SBUTTON FROM nSnd, 125 TYPE 1 ACTION (oDlg01:End(),nOpcA:=1) ENABLE OF oDlg01
DEFINE SBUTTON FROM nSnd, 155 TYPE 2 ACTION (oDlg01:End(),nOpcA:=0) ENABLE OF oDlg01


ACTIVATE MSDIALOG oDlg01 CENTER

If nOpcA == 1
	nOpcA:=0
    u_WaitLog(, {|oSay| QBKATFA2() }, "Consultando Itens dos Documentos de Entrada...")
    u_WaitLog(, {|oSay| PBKATFA2() }, "Gerando arquivo "+cArq+"...")
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
cQuery += " D1_FORNECE,D1_LOJA,A2_NOME,D1_SERIE,D1_DOC,D1_DTDIGIT,SD1.R_E_C_N_O_ AS D1RECNO,F1_ESPECIE, "+CRLF
cQuery += " CONVERT(VARCHAR(800),CONVERT(Binary(800),D1_XXHIST)) D1_XXHIST "+CRLF
cQuery += "FROM "+RETSQLNAME("SD1")+" SD1 "
cQuery += " LEFT JOIN "+RETSQLNAME("SF1")+" SF1 ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND SF1.D_E_L_E_T_ = ' ' "+CRLF
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
Local cBase      := "000000"
//Local nTamHist   := GetSx3Cache("N3_HISTOR", "X3_TAMANHO")
Local cHist      := ""
Local cGrupo     := ""

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
cBuffer += "ATIVO;"
cBuffer += "PRODUTO;"+CRLF

nHDestino := FCREATE(cArq, FC_NORMAL)
nBytes := FWRITE(nHDestino, cBuffer,LEN(cBuffer))

Dbselectarea("QSD1")
Dbgotop()
Do While !Eof()

    cBase   := STRZERO(QSD1->D1RECNO,6)
    cHist   := STRTRAN(QSD1->D1_XXHIST,";",",")
    cHist   := STRTRAN(cHist,CRLF," ")
    cHist   := "("+TRIM(QSD1->F1_ESPECIE)+")"+ALLTRIM(cHist)
    cGrupo  := fClass(QSD1->B1_DESC,QSD1->D1_CC)
    If TRIM(QSD1->F1_ESPECIE) <> "SPED"
        If cGrupo $ "008/108"
            If !TRIM(QSD1->F1_ESPECIE) $ "NFS"
                dbSkip()
                Loop
            EndIf
        Else
            dbSkip()
            Loop
        EndIf
    EndIf

    cBuffer := cBase+";"   // CODIGO_ATIVO
    cBuffer += "0001;"   // NUM_ITEM
    cBuffer += DTOC(QSD1->D1_DTDIGIT)+";"   // DATA_AQUISIÇÃO
    cBuffer += ALLTRIM(QSD1->B1_DESC)+";"   // DESCRIÇÃO_DO_BEM
    cBuffer += ALLTRIM(QSD1->B1_DESC)+";"   // DESCRIÇÃO_COMPLETA_DO_BEM
    cBuffer += STR(QSD1->D1_QUANT,5,0)+";"   // QUANTIDADE
    cBuffer += cBase+";"   // NUMERO_PATRIMONIO
    cBuffer += cGrupo+";"   // CLASSIFICACAO_PATRIMONIO
    cBuffer += cHist+";"   // HISTORICO
    cBuffer += QSD1->D1_CC+";"   // CENTRO_CUSTO
    cBuffer += QSD1->D1_FORNECE+";"   // FORNECEDOR
    cBuffer += QSD1->D1_LOJA+";"   // LOJA
    cBuffer += QSD1->D1_SERIE+";"   // SERIE_NF
    cBuffer += QSD1->D1_DOC+";"   // NUMERO_NF
    cBuffer += "31/12/2031;"   // DATA_GARANTIA
    cBuffer += ALLTRIM(STR(QSD1->D1_TOTAL,16,2))+";"   // VALOR_DO_BEM
    cBuffer += "001;"   // ITEM
    cBuffer += "FABIO QUIRINO;"   // NOME_RESPONSÁVEL
    cBuffer += "BK;"   // LOCALIZAÇÃO
    cBuffer += "S;"   // ATIVO
    cBuffer += QSD1->D1_COD+";"   // PRODUTO

    cBuffer += CRLF 

    nBytes := FWRITE(nHDestino, cBuffer,LEN(cBuffer))

    dbSkip()
EndDo

FCLOSE(nHDestino)  //fecha o arquivo CSV

RETURN lOk 


Static Function fClass(cDesc,cCC)
Local cGrupo := "99"
Local cTpCl  := "0"

If Val(cCC) > 100
    cTpCl  := "1"
EndIf

// 01 VEICULOS
// 02 MOVEIS E UTENSILIOS
// 03 COMPUTADORES E PERIFERICOS
// 04 TELEFONES
// 05 MAQUINAS E EQUIPAMENTOS
// 08 LICENÇAS

Do CASE
    Case "LICENC" $ cDesc
        cGrupo := "08"
    Case "SWITCH" $ cDesc
        cGrupo := "03"
    Case "SISTEMAS" $ cDesc
        cGrupo := "03"
    Case "NOTEBOOK" $ cDesc
        cGrupo := "03"
    Case "TRASNFORMADOR" $ cDesc
        cGrupo := "02"
    Case "DIGITALIZADOR" $ cDesc
        cGrupo := "03"
    Case "LEITO " $ cDesc
        cGrupo := "02"
    Case "RELOGIO" $ cDesc
        cGrupo := "03"
    Case "CARRINHO" $ cDesc
        cGrupo := "02"
    Case "MICRO VENT" $ cDesc
        cGrupo := "02"
    Case "LEITOR" $ cDesc
        cGrupo := "03"
    Case "VEICULOS" $ cDesc
        cGrupo := "01"
    Case "ACCESS" $ cDesc
        cGrupo := "03"
    Case "APLICADOR DE FITA ADESIVA" $ cDesc
        cGrupo := "02"
    Case "AR CONDICIONADO" $ cDesc
        cGrupo := "02"
    Case "ARMARIO" $ cDesc
        cGrupo := "02"
    Case "BEBEDOURO" $ cDesc
        cGrupo := "02"
    Case "CAFETEIRA" $ cDesc
        cGrupo := "02"
    Case "CAIXA DE FERRAMENTAS" $ cDesc
        cGrupo := "02"
    Case "CARRINHO" $ cDesc
        cGrupo := "02"
    Case "CELULAR" $ cDesc
        cGrupo := "04"
    Case "CONVERSOR" $ cDesc
        cGrupo := "02"
    Case "ESCADA" $ cDesc
        cGrupo := "02"
    Case "EXTINTORES" $ cDesc
        cGrupo := "02"
    Case "FILTRO" $ cDesc
        cGrupo := "02"
    Case "FOGAO" $ cDesc
        cGrupo := "02"
    Case "FORNO" $ cDesc
        cGrupo := "02"
    Case "HD EXTERNO" $ cDesc
        cGrupo := "03"
    Case "IMPRESSORA" $ cDesc
        cGrupo := "03"
    Case "KIT REATOR" $ cDesc
        cGrupo := "02"
    Case "MAQUINA DE CAFE  " $ cDesc
        cGrupo := "02"
    Case "MAQUINA FOTOGRAFICA" $ cDesc
        cGrupo := "03"
    Case "MAQUINAS E EQUIPAMENTOS" $ cDesc
        cGrupo := "05"
    Case "MONITOR" $ cDesc
        cGrupo := "03"
    Case "MOVEIS E UTENSILIOS" $ cDesc
        cGrupo := "02"
    Case "MULTIFUNCIONAL" $ cDesc
        cGrupo := "03"
    Case "MULTIMETRO" $ cDesc
        cGrupo := "02"
    Case "ROTULADOR" $ cDesc
        cGrupo := "02"
    Case "ROUPEIRO" $ cDesc
        cGrupo := "02"
    Case "SMARTPHONE" $ cDesc
        cGrupo := "04"
    Case "TELEFONE" $ cDesc
        cGrupo := "04"
    Case "CELULAR" $ cDesc
        cGrupo := "04"
    Case "WINDOWS" $ cDesc
        cGrupo := "03"

ENDCASE

Return (cTpCl+cGrupo)

