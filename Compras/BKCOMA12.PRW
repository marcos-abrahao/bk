
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

Local cTipoArq := "Arquivos no formato CSV (*.CSV) | *.CSV | "
Local cTitulo  := "Importar planilha excel em CSV para inclusão de produtos"
Local oDlg01
Local oButSel
Local nOpcA    := 0
Local nSnd     := 15,nTLin := 15

Private cProg  := "BKCOMA12"
Private cArq   := ""

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
	u_WaitLog(, {|| PBKCOMA12()},'Carregando Itens da Planilha...')
Endif

RETURN NIL


Static FUNCTION PBKCOMA12()
Local aProd      := {}
Local cBuffer    := ""
Local lOk 		 := .T.
Local nLin 		 := 0

dbSelectArea("SB1")
dbSetOrder(1)

FT_FUSE(cArq)   // abrir
FT_FGOTOP()     // vai para o topo
FT_FSKIP()      // proximo registro - pular cabeçalho

While !FT_FEOF()
 
    nLin++

	//Capturar dados
	cBuffer := FT_FREADLN()  //lendo a linha
	If ( !Empty(cBuffer) )
		aProd := {}
		aProd := U_StringToArray(cBuffer,";") //Retorna Array sem colunas com valores em branco
        //IF LEN(aProd)>=9
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

        IF LEN(aProd)>=5

            /*
            ARMAZEM PAD.
            CODIGO
            DESCR
            UM
            GRUPO	
            */

            IF !U_IBKCOMA12(aProd)
                u_MsgLog(,"Erro na linha "+STR(nLin,8),"E")
                lOk := .F.
                RETURN lOk         
            ENDIF
        ELSE
            u_MsgLog(,"Erro na leitura da linha "+STR(nLin,8),"E")
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
Local cLoc := ""
Local cCod := ""
Local cDesc:= ""
Local cUn  := ""
Local cGrp := ""


Private lMsErroAuto := .F.

    //cCod := PXNUMSB1("INS")

    /*
    _aProd  := {{"B1_COD"     ,cCod             ,Nil},;
                {"B1_DESC"    ,Acento(aProd[1]) ,Nil},;                      
                {"B1_TIPO"    ,aProd[2]         ,Nil},;      
                {"B1_UM"      ,UPPER(aProd[3])  ,Nil},;
                {"B1_LOCPAD"  ,aProd[4]         ,Nil},;                      
                {"B1_GRUPO"   ,aProd[5]         ,Nil},;                      
                {"B1_XXSGRP"  ,aProd[6]         ,Nil},;                      
                {"B1_XXGRPF"  ,aProd[7]         ,Nil},;                      
                {"B1_TE"      ,aProd[8]         ,Nil},;                      
                {"B1_CONTA"   ,aProd[9]         ,Nil}}                      

    */
    cLoc := SUBSTR(aProd[1],3,2)
    cCod := aProd[2]
    cDesc:= aProd[3]
    cUn  := UPPER(Alltrim(aProd[4]))
    cGrp := SUBSTR(aProd[5],6,4)

    If Empty(cUn)
        cUn := "PC"
    ElseIf cUn  == "GAL"
        cUn := "GL"
    ElseIf cUn  == "M-2"
        cUn := "M2"
    ElseIf cUn  == "MHC" .OR. cUn  == "MHR"
        cUn := "MH"        
    ElseIf cUn  == "PAC"
        cUn := "PA"
    ElseIf cUn  == "PAR"
        cUn := "PR"
    ElseIf cUn  == "PEC"
        cUn := "PC"        
    ElseIf cUn  == "UNI"
        cUn := "UN"
    ElseIf cUn  == "CTL"
        cUn := "C"
    ElseIf cUn  == "SAC"
        cUn := "SC"
    ElseIf cUn  == "POT"
        cUn := "PT"
    EndIf

    dbSelectArea("SB1")
    If !SB1->(dbSeek(xFilial("SB1")+PAD(cCod,LEN(SB1->B1_COD))))

        _aProd  := {{"B1_COD"     ,cCod             ,Nil},;
                    {"B1_DESC"    ,cDesc            ,Nil},;                      
                    {"B1_TIPO"    ,"MC"             ,Nil},;      
                    {"B1_UM"      ,cUn              ,Nil},;
                    {"B1_LOCPAD"  ,cLoc             ,Nil},;                      
                    {"B1_GRUPO"   ,cGrp             ,Nil},;                      
                    {"B1_TE"      ,'101'            ,Nil},;                      
                    {"B1_CONTA"   ,'34202055'       ,Nil}}                      


        lMsErroAuto := .F.    
        Begin Transaction            

            MSExecAuto({|x,y| Mata010(x,y)},_aProd,3) //Inclusão 
            If lMsErroAuto
                u_LogMsExec(cProg,)
                DisarmTransaction()
                lRet := .F.
            EndIf

        End Transaction
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


/*/
Programa     : BKCOMI12 - Autor: Marcos B. Abrahao - Data: 28/01/2011
Objetivo     : Atualiza a tabela SB7 atraves da tabela PowerBk.dbo.INVBARCAS
Uso          : Barcas Rio
/*/

User Function BKCOMI12()

u_WaitLog("BKCOMI12", {|| PRCCOMI12()},'Importando inventario..')

Return Nil

Static Function PRCCOMI12()
nRepl := 0
dData := CTOD("31/01/2025")
cDoc  := "20250131"

// Limpar os valores do documento
cQuery := " UPDATE "+RetSqlName("SB7")+" SET B7_QUANT = 0 WHERE B7_DOC = '"+cDoc+"' "
TcSqlExec(cQuery)

cQuery := " SELECT " + CRLF
cQuery += "   Produto" + CRLF
cQuery += "  ,Local AS LocEst" + CRLF
cQuery += "  ,QtdHom" + CRLF
cQuery += "  ,Vunit" + CRLF
cQuery += "  ,VInvent" + CRLF
cQuery += "  ,Descr" + CRLF
cQuery += " FROM PowerBk.dbo.INVBARCAS" + CRLF
cQuery += " ORDER BY Produto,Local" + CRLF
TCQUERY cQuery NEW ALIAS "QINV"

tcSetField("QINV","QtdHom","N",12,2)
tcSetField("QINV","Vunit","N",15,5)
tcSetField("QINV","VInvent","N",15,2)

dbSelectArea("SB7")
SET ORDER TO 1

dbSelectArea("QINV")
ProcRegua(LASTREC())
GO TOP
DO WHILE !EOF()
   dbSelectArea("SB1")
   IF !DBSEEK(xFilial("SB1")+QINV->Produto,.F.)
      RecLock("SB1",.T.)
      SB1->B1_FILIAL := xFilial("SB1")
      SB1->B1_DESC   := QINV->Descr
      SB1->B1_COD    := QINV->Produto
      SB1->B1_TIPO   := "MC"
      SB1->B1_LOCPAD := SUBSTR(QINV->LocEst,3,2)
      SB1->B1_GRUPO  := "0000"
      SB1->B1_TE     := "101"
      SB1->B1_CONTA  := "34202055"
      dbUnlock()
   ELSE
        IF TRIM(SB1->B1_DESC) <> TRIM(QINV->Descr)
            IF ('"' $ SB1->B1_DESC) .AND. !('*' $ QINV->Descr)
                RecLock("SB1",.F.)
                SB1->B1_DESC := QINV->Descr
                dbUnlock()
            ENDIF
        ENDIF
   ENDIF
   dbSelectArea("SB7")
   IF !DBSEEK(xFilial("SB7")+DTOS(dData)+PAD(QINV->Produto,LEN(SB7->B7_COD))+SUBSTR(QINV->LocEst,3,2),.F.)
      RecLock("SB7",.T.)
      SB7->B7_FILIAL  := xFilial("SB7")
      SB7->B7_DATA    := dData 
      SB7->B7_COD     := QINV->Produto      
      SB7->B7_LOCAL   := SUBSTR(QINV->LocEst,3,2)    
      SB7->B7_TIPO    := "MC"
      SB7->B7_DTVALID := dData 
      SB7->B7_DOC     := cDoc
      SB7->B7_QUANT   := QINV->QtdHom
      SB7->B7_QTSEGUM := QINV->QtdHom

      SB7->B7_ORIGEM  := "MATA270"
      //SB7->B7_CODGRP  := IniAuxCod(SB7->B7_COD,"B7_CODGRP")
      //SB7->B7_CODITE  := IniAuxCod(SB7->B7_COD,"B7_CODITE")
      //SB7->B7_DESC    := SB1->B1_DESC
      SB7->B7_STATUS  := "1"

      dbUnlock()
      nRepl++
   ELSE
      //RecLock("SB7",.F.)
      //SB7->B7_QUANT   += QINV->QtdHom
      //SB7->B7_QTSEGUM += QINV->QtdHom
      //dbUnlock()
   ENDIF
   //nRepl++
   dbSelectArea("QINV")
   SKIP
ENDDO                                   
u_MsgLog("BKCOMI12","Registros adicionados SB7: "+STR(nRepl,6),"I")

Return Nil
