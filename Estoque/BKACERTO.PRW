#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
Programa     : BKACERTO - Autor: Marcos B. Abrahao - Data: 29/01/2011
Objetivo     : Acertos diversos 
Uso          : BK Consultoria
/*/

User Function BKACERTO()
Private nRepl := 0
Private cRot  := PAD("U_BKB1TOZJ()",20)
 
  dbSelectArea("SZJ")

@ 200,01 TO 285,450 DIALOG oDlg1 TITLE "Rotinas emergenciais (30/09/13)"
@ 15,015 SAY "Rotina: "
@ 15,046 GET cRot SIZE 180,10
@ 30,060 BMPBUTTON TYPE 01 ACTION ProcImp()   
@ 30,110 BMPBUTTON TYPE 02 ACTION Close(Odlg1)
ACTIVATE DIALOG oDlg1 CENTER

MSGBOX("Registros alterados: "+STR(nRepl,6),"PQACERTO","INFO")

RETURN


Static FUNCTION ProcImp()
cRot:= ALLTRIM(cRot)
Close(oDlg1)
If MsgBox("Confirma a execução do processo ?",cRot,"YESNO")
   //Processa( {|| &(cRot) } )
   x:= &(cRot)
   //U_FIMPCP()
Endif   
Return 


// Inicio de inventario - Carregamento da Tabela SZJ
// 
// Passo 1 
User Function BKB1TOZJ()
nRepl := 0

// Preencher a tabela SZJ com os produtos da tabela SB1
dbSelectArea("SB1")
dbSetOrder(1)
dbGoTop()
DO WHILE !EOF()
   IncProc(STR(RECNO(),7))
   
   dbSelectArea("SZJ")
   IF !DBSEEK(xFilial("SZJ")+SB1->B1_COD+"01",.F.)
      RecLock("SZJ",.T.)
      SZJ->ZJ_FILIAL  := xFilial("SZJ")
      SZJ->ZJ_DESCR   := SB1->B1_DESC
      SZJ->ZJ_TIPO    := SB1->B1_TIPO
      SZJ->ZJ_PRODUTO := SB1->B1_COD      
      SZJ->ZJ_LOCAL   := "01"    
      SZJ->ZJ_VUNIT   := SB1->B1_UPRC
      dbUnlock()
      nRepl++
   ELSE
      RecLock("SZJ",.F.)
      IF SZJ->ZJ_VUNIT <= 0
         SZJ->ZJ_VUNIT := SB1->B1_UPRC
      ENDIF
      SZJ->ZJ_DESCR   := SB1->B1_DESC
      SZJ->ZJ_TIPO    := SB1->B1_TIPO
      SZJ->ZJ_VTOTAL  := SZJ->ZJ_QUANT * SZJ->ZJ_VUNIT   
      dbUnlock()
   ENDIF

   dbSelectArea("SB1")
   dbSkip()

ENDDO


dbSelectArea("SZJ")
dbSetOrder(1)

dbSelectArea("SB2")
ProcRegua(LASTREC())
dbSetOrder(1)
dbGoTop()

DO WHILE !EOF()
   IncProc(STR(RECNO(),7))
   
   dbSelectArea("SB1")
   dbSeek(xFilial("SB1")+SB2->B2_COD,.F.)

   dbSelectArea("SZJ")
   IF !DBSEEK(SB2->B2_FILIAL+SB2->B2_COD+SB2->B2_LOCAL,.F.)
      RecLock("SZJ",.T.)
      SZJ->ZJ_FILIAL  := SB2->B2_FILIAL
      SZJ->ZJ_DESCR   := SB1->B1_DESC
      SZJ->ZJ_TIPO    := SB1->B1_TIPO
      SZJ->ZJ_PRODUTO := SB2->B2_COD      
      SZJ->ZJ_LOCAL   := SB2->B2_LOCAL    
      SZJ->ZJ_VUNIT   := SB1->B1_UPRC
      IF SZJ->ZJ_VUNIT <= 0
         SZJ->ZJ_VUNIT := SB2->B2_CM1
      ENDIF
      dbUnlock()
      nRepl++
   ELSE
      RecLock("SZJ",.F.)
      IF SZJ->ZJ_VUNIT <= 0
         SZJ->ZJ_VUNIT := SB1->B1_UPRC
         IF SZJ->ZJ_VUNIT <= 0
            SZJ->ZJ_VUNIT := SB2->B2_CM1
         ENDIF   
      ENDIF
      SZJ->ZJ_DESCR   := SB1->B1_DESC
      SZJ->ZJ_TIPO    := SB1->B1_TIPO
      SZJ->ZJ_VTOTAL  := SZJ->ZJ_QUANT * SZJ->ZJ_VUNIT   
      dbUnlock()

   ENDIF

   dbSelectArea("SB2")
   dbSkip()
   
ENDDO                                   
MSGBOX("Registros adicionados SZJ: "+STR(nRepl,6),"BK2TOZJ","INFO")

Return Nil



/*/
Programa     : BKZJTOB7 - Autor: Marcos B. Abrahao - Data: 28/01/2011
Objetivo     : Atualiza a tabela SB7 atraves da tabela SZJ importada do excel
Uso          : Mister Imagem
               Passo 2
/*/

User Function BKZJTOB7()
nRepl := 0
dData := CTOD("30/09/2013")
cDoc  := "20130930"

// Limpar os valores do documento
cQuery := " UPDATE "+RetSqlName("SB7")+" SET B7_QUANT = 0 WHERE B7_DOC = '"+cDoc+"' "
TcSqlExec(cQuery)

cQuery := "SELECT ZJ_FILIAL,ZJ_PRODUTO,ZJ_DESCR,ZJ_LOCAL,ZJ_QUANT,ZJ_VUNIT,ZJ_VTOTAL,B1_TIPO "
cQuery += "FROM "+RETSQLNAME("SZJ")+" SZJ LEFT JOIN "+RETSQLNAME("SB1")+" SB1 ON ZJ_PRODUTO = B1_COD "
//cQuery += "AND B1_MSBLQL <> '1' "
//cQuery += "AND B2_LOCAL IN ('01','03') "       
//cQuery += "AND (B2_COD = 'CXEM0083' OR B2_COD = 'ACGE0028')  "  PARA TESTE   
//cQuery += "AND ZJ_QUANT > 0 "
cQuery += "AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "AND SZJ.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY ZJ_PRODUTO"

TCQUERY cQuery NEW ALIAS "QSZJ"


dbSelectArea("SB7")
SET ORDER TO 1

dbSelectArea("SZJ")
ProcRegua(LASTREC())
GO TOP
DO WHILE !EOF()
   IncProc(STR(RECNO(),7))
   dbSelectArea("SB1")
   IF !DBSEEK(xFilial("SB1")+QSZJ->ZJ_PRODUTO,.F.)
      RecLock("SB1",.T.)
      SB1->B1_FILIAL := xFilial("SB1")
      SB1->B1_DESC   := QSZJ->ZJ_DESCR
      SB1->B1_COD    := QSZJ->ZJ_PRODUTO
      SB1->B1_TIPO   := "MC"
      dbUnlock()
   ENDIF
   dbSelectArea("SB7")
   IF !DBSEEK(xFilial("SB7")+DTOS(dData)+QSZJ->ZJ_PRODUTO+QSZJ->ZJ_LOCAL,.F.)
      RecLock("SB7",.T.)
      SB7->B7_FILIAL  := xFilial("SB7")
      SB7->B7_DATA    := dData 
      SB7->B7_COD     := QSZJ->ZJ_PRODUTO      
      SB7->B7_LOCAL   := QSZJ->ZJ_LOCAL    
      SB7->B7_TIPO    := IIF(!EMPTY(QSZJ->B1_TIPO),QSZJ->B1_TIPO,"MC")
      SB7->B7_DTVALID := dData 
      SB7->B7_DOC     := cDoc
      SB7->B7_QUANT   := QSZJ->ZJ_QUANT
      SB7->B7_QTSEGUM := QSZJ->ZJ_QUANT
      dbUnlock()
      nRepl++
   ELSE
      RecLock("SB7",.F.)
      SB7->B7_QUANT   += QSZJ->ZJ_QUANT
      SB7->B7_QTSEGUM += QSZJ->ZJ_QUANT
      dbUnlock()
   ENDIF
   nRepl++
   dbSelectArea("QSZJ")
   SKIP
ENDDO                                   
MSGBOX("Registros adicionados SB7: "+STR(nRepl,6),"PqAcerto","INFO")

Return Nil



/*/
Programa     : BKZJTOD3 - Autor: Marcos B. Abrahao - Data: 28/01/2011
Objetivo     : Valorização dos produtos 
Uso          : Mister Imagem
               Passo 3
/*/

USER Function BKZJTOD3()
nRepl := 0
dData := CTOD("30/09/2013")
cDoc  := '20130930'

cQuery := "SELECT ZJ_PRODUTO,ZJ_LOCAL,SUM(ZJ_VTOTAL) AS ZJTOTAL "
//cQuery += "FROM "+RETSQLNAME("SZJ")+" SZJ "
cQuery += "FROM "+RETSQLNAME("SZJ")+" SZJ "

//cQuery += "AND B1_MSBLQL <> '1' "
//cQuery += "AND B2_LOCAL IN ('01','03') "       
//cQuery += "WHERE ZJ_QUANT > 0 "
cQuery += "WHERE SZJ.D_E_L_E_T_ = ' ' "

//cQuery += "AND ZJ_PRODUTO >= 'PQTT' "

cQuery += "GROUP BY ZJ_PRODUTO,ZJ_LOCAL "
cQuery += "ORDER BY ZJ_PRODUTO,ZJ_LOCAL "

TCQUERY cQuery NEW ALIAS "QSZJ"

dbSelectArea("QSZJ")
dbGoTop()

ProcRegua(LASTREC())

DO WHILE !EOF()
   IncProc(STR(RECNO(),7))

   nValD3 := 0
   cTmD3  := '110'

   dbSelectArea("SB2")
   IF !(dbseek(xFilial("SB2")+PAD(QSZJ->ZJ_PRODUTO,15)+QSZJ->ZJ_LOCAL,.F.))
      MSGSTOP(QSZJ->ZJ_PRODUTO)
      dbSelectArea("QSZJ")
      dbSkip()
      LOOP
   ENDIF
   
   nValB2 := SB2->B2_VATU1

   IF QSZJ->ZJTOTAL < nValB2
      nValD3 := (nValB2 - QSZJ->ZJTOTAL)
      cTmD3  := '510'
   ELSE
      nValD3 := (QSZJ->ZJTOTAL - nValB2)
      cTmD3  := '110'
   ENDIF   

   IF nValD3 = 0
      dbSelectArea("QSZJ")
      dbSkip()
      LOOP
   ENDIF
   
MSGINFO(STR(nValD3,14,2),"bkacerto")

   aVetor := {}
   AADD(aVetor,{"D3_FILIAL"  , xFilial('SD3'),Nil} )
   AADD(aVetor,{"D3_TM"      , cTmD3,Nil})
   AADD(aVetor,{"D3_COD"     , QSZJ->ZJ_PRODUTO,Nil})
   AADD(aVetor,{"D3_LOCAL"   , QSZJ->ZJ_LOCAL,Nil})
   AADD(aVetor,{"D3_CUSTO1"  , nValD3,Nil})

   nAcao   := 3  // Inclui  

   
   IF nAcao > 0 
      lMsErroAuto := .F.	
      MSExecAuto({|x,y| Mata240(x,y)},aVetor,nAcao) //Inclusao ou Alteração
         
      IF lMsErroAuto
         aAutoErro := {}
         // Função que retorna o evento de erro na forma de um array
         aAutoErro := GETAUTOGRLOG()
         // Função especifica que converte o array aAutoErro em texto
         // contínuo, com a quantidade de caracteres desejada por linha
         // Função específica que efetua a gravação do evento de erro no
         // arquivo previamente crado.
            
         cReg := ""
         FOR nX := 1 to Len(aAutoErro)
             cReg += TRIM(aAutoErro[nX])+CHR(13)+CHR(10)
             //IF UPPER("Invalido") $ UPPER(aAutoErro[nX])
             //   EXIT
             //ENDIF
             MsgStop(cReg)
         NEXT nX
         EXIT
      ENDIF  
   ENDIF

   nRepl++

   dbSelectArea("QSZJ")
   dbSkip()
ENDDO                                   
MSGBOX("Registros adicionados: "+STR(nRepl,6),"BKAcerto","INFO")

Return Nil



                   
// Inicio de inventario - Carregamento da Tabela SB7
// Não utilizada

User Function BKB2TOB7()
nRepl := 0

cQuery := "SELECT B2_FILIAL,B2_COD,B2_LOCAL,B1_COD,B1_TIPO,B1_DESC "
cQuery += "FROM "+RETSQLNAME("SB2")+" SB2 INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON B2_FILIAL = '"+xFilial("SB2")+"' AND B2_COD = B1_COD "
//cQuery += "AND B1_MSBLQL <> '1' "
//cQuery += "AND B2_LOCAL IN ('01') "       
//cQuery += "AND B2_LOCAL <> '01' "       
//cQuery += "AND (B2_COD = 'CXEM0083' OR B2_COD = 'ACGE0028')  "  PARA TESTE   
cQuery += "AND SB1.D_E_L_E_T_ = ' ' "
cQuery += "AND SB2.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY B2_COD,B2_LOCAL"

TCQUERY cQuery NEW ALIAS "QSB1"

dData := CTOD("30/09/2013")
cDoc  := "20130930"

dbSelectArea("SB7")
SET ORDER TO 1
dbSelectArea("SB1")
SET ORDER TO 1

ProcRegua(LASTREC())
GO TOP
DO WHILE !EOF()
   IncProc(STR(RECNO(),7))
   SELECT SB7
   DBSEEK(QSB1->B2_FILIAL+DTOS(dData)+QSB1->B2_COD+QSB1->B2_LOCAL,.T.)
   IF SB7->B7_FILIAL <> QSB1->B2_FILIAL .OR. SB7->B7_DATA <> dData .OR. SB7->B7_COD <> QSB1->B2_COD .OR. SB7->B7_LOCAL <> QSB1->B2_LOCAL
      RecLock("SB7",.T.)
      SB7->B7_FILIAL  := QSB1->B2_FILIAL
      SB7->B7_DATA    := dData 
      SB7->B7_COD     := QSB1->B2_COD      
      SB7->B7_LOCAL   := QSB1->B2_LOCAL    
      SB7->B7_TIPO    := QSB1->B1_TIPO
      SB7->B7_DTVALID := dData 
      SB7->B7_DOC     := cDoc
      dbUnlock()
      
      nRepl++
   ENDIF
   SELECT QSB1
   SKIP
ENDDO                                   
MSGBOX("Registros adicionados SB7: "+STR(nRepl,6),"SB2TOSB7","INFO")

Return Nil


// Acerto SOMENTE para Julho 2011
// alterar o parametro mv_estneg para N antes
USER Function BKZJJUL11()
nRepl := 0
dData := CTOD("31/07/2011")
cDoc  := "AC0711"
nNumSeq := 866281

cQuery := "SELECT ZJ_PRODUTO,ZJ_LOCAL,ZJ_VTOTAL,ZJ_VUNIT,B9_COD,B9_LOCAL,B9_CM1,B9_VINI1,ZJ_VUNT2,ZJ_VTOT2,SB9.R_E_C_N_O_ AS B9RECNO  "
//cQuery += "FROM "+RETSQLNAME("SZJ")+" SZJ  INNER JOIN SB9020 SB9 ON "
cQuery += "FROM "+RETSQLNAME("SZJ")+"  INNER JOIN "+RETSQLNAME("SB9")+" SB9 ON "
cQuery += "  ZJ_PRODUTO = B9_COD AND ZJ_LOCAL = B9_LOCAL AND B9_DATA = '20110731' AND SB9.D_E_L_E_T_ = ' ' AND SZJ.D_E_L_E_T_ = ' ' "
cQuery += "ORDER BY ZJ_PRODUTO,ZJ_LOCAL "

TCQUERY cQuery NEW ALIAS "QSZJ"

dbSelectArea("SB9")
dbSetOrder(1)
dbGoTop()

dbSelectArea("QSZJ")
dbGoTop()

ProcRegua(LASTREC())

DO WHILE !EOF()
   IncProc(STR(RECNO(),7))

   nValD3 := 0
   cTmD3  := '110'
   
   nValB2 := QSZJ->B9_VINI1

   IF QSZJ->ZJ_VTOT2 < nValB2
      nValD3 := (nValB2 - QSZJ->ZJ_VTOT2)
      cTmD3  := '510'
   ELSE
      nValD3 := (QSZJ->ZJ_VTOT2 - nValB2)
      cTmD3  := '110'
   ENDIF   

   IF nValD3 = 0
      dbSelectArea("QSZJ")
      dbSkip()
      LOOP
   ENDIF

   dbSelectArea("SB9")
   dbGoto(QSZJ->B9RECNO)

   RecLock("SB9",.F.)
   SB9->B9_CM1   := QSZJ->ZJ_VUNT2
   SB9->B9_VINI1 := QSZJ->ZJ_VTOT2
   MsUnlock()
   
   dbSelectArea("SB2")
   IF (dbseek(xFilial("SB2")+PAD(QSZJ->ZJ_PRODUTO,15)+QSZJ->ZJ_LOCAL,.F.))
	   RecLock("SB2",.F.)
	   SB2->B2_VFIM1  := QSZJ->ZJ_VTOT2
	   SB2->B2_CMFIM1 := QSZJ->ZJ_VUNT2
	   MsUnlock()
   ENDIF

   aVetor := {}
   AADD(aVetor,{"D3_FILIAL"  , xFilial('SD3'),Nil} )
   AADD(aVetor,{"D3_TM"      , cTmD3,Nil})
   AADD(aVetor,{"D3_COD"     , QSZJ->ZJ_PRODUTO,Nil})
   AADD(aVetor,{"D3_LOCAL"   , QSZJ->ZJ_LOCAL,Nil})
   AADD(aVetor,{"D3_CUSTO1"  , nValD3,Nil})
   AADD(aVetor,{"D3_DOC"     , cDoc,Nil})
   //AADD(aVetor,{"D3_DOCSEQ"  , STRZERO(nDocSeq,6),Nil})

   nAcao   := 3  // Inclui  

   
   IF nAcao > 0 
      lMsErroAuto := .F.	
      MSExecAuto({|x,y| Mata240(x,y)},aVetor,nAcao) //Inclusao ou Alteração
         
      IF lMsErroAuto
         aAutoErro := {}
         // Função que retorna o evento de erro na forma de um array
         aAutoErro := GETAUTOGRLOG()
         // Função especifica que converte o array aAutoErro em texto
         // contínuo, com a quantidade de caracteres desejada por linha
         // Função específica que efetua a gravação do evento de erro no
         // arquivo previamente crado.
            
         cReg := ""
         FOR nX := 1 to Len(aAutoErro)
             cReg += TRIM(aAutoErro[nX])+CHR(13)+CHR(10)
             //IF UPPER("Invalido") $ UPPER(aAutoErro[nX])
             //   EXIT
             //ENDIF
         NEXT nX
         MsgStop(cReg)
         EXIT
      ENDIF  
   ENDIF
   
   nNumSeq++
   dbSelectArea("SD3")
   dbSetOrder(0)
   dbGoBottom()
   RecLock("SD3",.F.)
   SD3->D3_NUMSEQ  := STRZERO(nNumSeq,6)
   SD3->D3_EMISSAO := dData
   MsUnlock()

   nRepl++

   dbSelectArea("QSZJ")
   dbSkip()
ENDDO                                   
MSGBOX("Registros adicionados: "+STR(nRepl,6),"BKAcerto","INFO")

Return Nil
                 