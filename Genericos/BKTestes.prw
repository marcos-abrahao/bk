#INCLUDE "PROTHEUS.CH"  
#INCLUDE "TOPCONN.CH"                     
#INCLUDE "TBICONN.CH"
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*/
Programa     : Autor: Marcos B. Abrahao - Data: 29/01/2011
Objetivo     : Acertos diversos 
/*/


User Function BKTESTE()
u_BKFATR5A()
Return Nil


User Function BKTestes()
Local oDlg1 as Object
Local oSay,oSay1,oSay2,oRot

Private cRot  := PAD("U_BKTESTE",20)


DEFINE DIALOG oDlg1;
 TITLE "Teste de User Functions"  ;
 FROM 0,0 TO 150,480 OF oMainWnd PIXEL //STYLE nOr(WS_VISIBLE,WS_POPUP)

//FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL;

//@ 200,01 TO 330,450 DIALOG oDlg1 TITLE "Teste de User Functions"
@ 15,015 Say oSay Prompt "Funcão: " Size  40, 10 Of oDlg1 Pixel 
@ 15,046 MsGet oRot Var cRot SIZE 180,10 Of oDlg1 Pixel 

@ 30,015 SAY oSay1 Prompt "Exemplos:" SIZE 180,10 Of oDlg1 Pixel 
@ 30,046 SAY oSay2 Prompt "U_BKPARFIS,U_BKPARGEN,U_NIVERSADVPL,U_TSTYEXCEL" SIZE 180,10 Of oDlg1 Pixel 

DEFINE SBUTTON FROM 050,060 TYPE 1 ACTION (ProcRot(),oDlg1:End()) ENABLE OF oDlg1
DEFINE SBUTTON FROM 050,110 TYPE 2 ACTION oDlg1:End() ENABLE OF oDlg1
	
ACTIVATE MSDIALOG oDlg1  CENTERED


//@ 50,060 BMPBUTTON TYPE 01 ACTION ProcRot()   
//@ 50,110 BMPBUTTON TYPE 02 ACTION Close(Odlg1)
//ACTIVATE DIALOG oDlg1 CENTER

RETURN


Static FUNCTION ProcRot()
//Local bError 
Private nProc := 0

cRot:= ALLTRIM(cRot)+"(@lEnd)"

If MsgYesNo("Confirma a execução do processo ?",cRot,"YESNO")
	//-> Recupera e/ou define um bloco de código para ser avaliado quando ocorrer um erro em tempo de execução.
	//bError := ErrorBlock( {|e| cError := e:Description, Break(e) } ) //, Break(e) } )
		
	//-> Inicia sequencia.
	BEGIN SEQUENCE
      x:= &(cRot)
	//RECOVER
		//-> Recupera e apresenta o erro.
		//ErrorBlock( bError )
		//MsgStop( cError )
	END SEQUENCE

Endif   

If nProc > 0
   MsgInfo("Registros processados: "+STR(nProc,6),cRot,"INFO")
EndIf

Return 


Static Function PEmailSa1()
Local lEnd := .F.
MsAguarde({|lEnd| EmailSa1(@lEnd) },"Processando...",cRot,.T.)
Return

Static Function EmailSa1(lEnd)
Local cEmail := ""

   dbSelectArea("SA1")
   dbSetOrder(0)
   dbGoTop()
   
   While !EOF()
      If lEnd
        MsgInfo(cCancel,"Título da janela")
        Exit
      Endif
      MsProcTxt("Lendo tabela: SA1 ")
      ProcessMessage()

      If !EMPTY(SA1->A1_EMAIL)
         cEmail := STRTRAN(SA1->A1_EMAIL,"|",";")
         cEmail := LOWER(ALLTRIM(cEmail))
         If SUBSTR(cEmail,LEN(cEmail),1) == ";"
            cEmail := SUBSTR(cEmail,1,LEN(cEmail)-1)
         EndIf
         RecLock("SA1",.F.)
         SA1->A1_EMAIL := cEmail
         MsUnLock()
      EndIf

      dbSkip()

      nProc++

   End

Return lEnd







/*
Static Function FuncUser1()
Local lEnd := .F.
MsAguarde({|lEnd| FuncUser(@lEnd) },"Processando...",cRot,.T.)
Return

Static Function FuncUser(lEnd)

   dbSelectArea("SX5")
   dbSetOrder(1)
   dbGoTop()
   
   While !EOF()
      If lEnd
        MsgInfo(cCancel,"Título da janela")
        Exit
      Endif
      MsProcTxt("Lendo tabela: "+SX5->X5_TABELA)
      ProcessMessage()
      dbSkip()

      nProc++

   End

Return lEnd
// fim do exemplo
*/



//#include 'protheus.ch'

User Function TmpTable()
Local aFields := {}
Local oTmpTb
Local nI
Local cAlias := "MEUALIAS"
Local cQuery

//-------------------
//Criação do objeto
//-------------------
oTmpTb := FWTemporaryTable():New( cAlias )

//--------------------------
//Monta os campos da tabela
//--------------------------
aadd(aFields,{"DESCR","C",30,0})
aadd(aFields,{"CONTR","N",3,1})
aadd(aFields,{"ALIAS","C",3,0})

oTmpTb:SetFields( aFields )
oTmpTb:AddIndex("indice1", {"DESCR"} )
oTmpTb:AddIndex("indice2", {"CONTR", "ALIAS"} )
//------------------
//Criação da tabela
//------------------
oTmpTb:Create()


Conout("Executando a cópia dos registros da tabela: " + RetSqlName("CT0") )

//--------------------------------------------------------------------------
//Caso o INSERT INTO SELECT preencha todos os campos, este será um método facilitador
//Caso contrário deverá ser chamado o InsertIntoSelect():
 // oTmpTb:InsertIntoSelect( {"DESCR", "CONTR" } , RetSqlName("CT0") , { "CT0_DESC", "CT0_CONTR" } )
//--------------------------------------------------------------------------
oTmpTb:InsertSelect( RetSqlName("CT0") , { "CT0_DESC", "CT0_CONTR", "CT0_ALIAS" } )


//------------------------------------
//Executa query para leitura da tabela
//------------------------------------
cQuery := "select * from "+ oTmpTb:GetRealName()
MPSysOpenQuery( cQuery, 'QRYTMP' )

DbSelectArea('QRYTMP')

while !eof()
	for nI := 1 to fcount()
		varinfo(fieldname(nI),fieldget(ni))
	next
	dbskip()
Enddo

	
//---------------------------------
//Exclui a tabela 
//---------------------------------
oTmpTb:Delete() 

return
