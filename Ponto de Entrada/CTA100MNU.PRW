#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"       
#INCLUDE "TOPCONN.CH"       

/*/{Protheus.doc} CTA100MNU
BK - Ponto de Entrada para criar opções na tela de Contratos
@Return
@author Adilson do Prado / Marcos Bispo Abrahão
@since 30/07/10
@version P12
/*/

User Function CTA100MNU() 
Local aUser
Local cMDiretoria,cMRepac,cMRepac2
Local aRotY := {}
Local aRotZ := {}

AADD(aRotina,{OemToAnsi("Exportar Contrato BK"),  "U_XCNTR010(.T.)", 0, 2 })

cMDiretoria := SuperGetMV("MV_XXGRPMD",.F.,"000007") //SUBSTR(SuperGetMV("MV_XXGRPMD",.F.,"000007"),1,6

cMRepac     := SUBSTR(SuperGetMV("MV_XXGRPRP",.F.,"000008"),1,6)
cMRepac2    := SUBSTR(SuperGetMV("MV_XXGRPR2",.F.,"000039"),1,6)

PswOrder(1) 
PswSeek(__CUSERID) 
aUser  := PswRet(1)

//Memowrite("c:\cta100.sql",aUser[1,10])

lMDiretoria := .F.
lMRepac := .F.

aGRUPO := {}
//AADD(aGRUPO,aUser[1,10])
//FOR i:=1 TO LEN(aGRUPO[1])
//	lMDiretoria := (aGRUPO[1,i] $ cMDiretoria)
//NEXT
//Ajuste nova rotina a antiga não funciona na nova lib MDI
aGRUPO := UsrRetGrp(aUser[1][2])
IF LEN(aGRUPO) > 0
	FOR i:=1 TO LEN(aGRUPO)
		lMDiretoria := (ALLTRIM(aGRUPO[i]) $ cMDiretoria )
		lMRepac := (ALLTRIM(aGRUPO[i]) $ cMRepac )
	NEXT
ENDIF	
IF VAL(__CUSERID) == 0 .OR. VAL(__CUSERID) == 12 .OR. lMDiretoria .OR. ASCAN(aUser[1,10],cMRepac) > 0 .OR. __CUSERID $ cMRepac2

	IF VAL(__CUSERID) == 0 .OR. VAL(__CUSERID) == 12 .OR. lMRepac //ASCAN(aUser[1,10],cMRepac) > 0       
	   AADD(aRotY,{OemToAnsi("Alt Sit Vigente"), "U_BKGCTA03", 0, 2 })
	   AADD(aRotY,{OemToAnsi("Alt Modo Filial"), "U_BKGCTA21", 0, 2 })
	ENDIF
 
   AADD(aRotY,{OemToAnsi("Dados Repac."), "U_BKGCTA04", 0, 2 })
   AADD(aRotY,{OemToAnsi("Hist. Repac."), "U_BKGCTA05", 0, 2 })
   AADD(aRotY,{OemToAnsi("Dados Reeq."),  "U_BKGCTA07", 0, 2 })
   AADD(aRotY,{OemToAnsi("Hist. Reeq."),  "U_BKGCTA08", 0, 2 })

   AADD( aRotina, {OemToAnsi("Adm Gestão "+ALLTRIM(SM0->M0_NOME)), aRotY, 0, 4 } )

ENDIF

AADD(aRotZ,{OemToAnsi("Dados Prorrogação"),         "U_BKGCTA09", 0, 2 })
AADD(aRotZ,{OemToAnsi("Hist. Prorrogação"),         "U_BKGCTA10", 0, 2 })
AADD(aRotZ,{OemToAnsi("Projeção Financeira"),       "U_BKGCTA11", 0, 4 })
AADD(aRotZ,{OemToAnsi("Hist. Projeção Financeira"), "U_BKGCTA12", 0, 2 })
AADD(aRotZ,{OemToAnsi("Dados Insumos Operacionais"),"U_BKGCTA13", 0, 2 })
AADD(aRotZ,{OemToAnsi("Hist. Insumos Operacionais"),"U_BKGCTA14", 0, 2 })
AADD(aRotZ,{OemToAnsi("Dados Atestado Capacidade Técnica"),"U_BKGCTA15", 0, 2 })
AADD(aRotZ,{OemToAnsi("Hist. Atestado Capacidade Técnica"),"U_BKGCTA16", 0, 2 })
AADD(aRotZ,{OemToAnsi("Dados Venc. Doc. Segurança Trab."),"U_BKGCTA18", 0, 2 })
AADD(aRotZ,{OemToAnsi("Hist. Venc. Doc. Segurança Trab."),"U_BKGCTA19", 0, 2 })
AADD(aRotZ,{OemToAnsi("Planos de Ação"),"U_BKGCTA22(.F.)", 0, 2 })
AADD(aRotZ,{OemToAnsi("Consultar Planos de Ação"),"U_BKGCTV22", 0, 2 })
AADD(aRotZ,{OemToAnsi("Exportar Contrato BK"),  "U_XCNTR010(.T.)", 0, 2 })

AADD( aRotina, {OemToAnsi("Gestão "+ALLTRIM(SM0->M0_NOME)), aRotZ, 0, 4 } )



Return Nil


User Function BKGCTA03()
If CN9->CN9_SITUAC == "02"
	If MsgYesNo("Deseja retornar este contrato para vigente?")
		dbSelectArea("SZG")
		dbSetOrder(1)
		IF !dbSeek(xFilial("SZG")+CN9->CN9_NUMERO,.F.) //+CN9->CN9_REVISA,.F.)
			MsgAlert("Contrato não possui Ficha de Projeção Financeira!!")
		ENDIF
		dbSelectArea("CN9")
		RecLock("CN9",.F.)
	  	CN9->CN9_SITUAC := "05"
	  	msUnlock()
	EndIf
ElseIf CN9->CN9_SITUAC == "05"
   If MsgYesNo("Deseja retornar este contrato para em elaboração?")
	  dbSelectArea("CN9")
	  RecLock("CN9",.F.)
	  CN9->CN9_SITUAC := "02"
      msUnlock()
   EndIf
ElseIf CN9->CN9_SITUAC == "07"
   If MsgYesNo("Deseja retornar este contrato para vigente?")
	  dbSelectArea("CN9")
	  RecLock("CN9",.F.)
	  CN9->CN9_SITUAC := "05"
      msUnlock()
   EndIf
ElseIf CN9->CN9_SITUAC == "08"
   If MsgYesNo("Deseja retornar este contrato para vigente?")
	  dbSelectArea("CN9")
	  RecLock("CN9",.F.)
	  CN9->CN9_SITUAC := "05"
      msUnlock()
   EndIf
Endif

Return Nil



// Alteração de dados referentes a Repactuação
User Function BKGCTA04()
Local _sAlias	:= Alias()
Local oDlg01,aButtons := {},lOk := .F.
Local cSnd1 := "",cSnd2 := "",cSnd3 := "",cSnd4 := "",cSnd5 := ""
Local nSnd  := 0,nTLin := 12
Local nSin  := 0
//Local aStatus := {"Atrasado","Em Processo - Gestão","Aguardando retorno do cliente","Em Analise - Gestão","Finalizado"}
Local aStatus := {"1-Atrasado",;                        // Status 1
                  "2-Em análise "+TRIM(SM0->M0_NOME),;  //        2 
                  "3-Aguardando retorno do cliente",;   //        3
                  "4-Em analise cliente",;              //        4
                  "5-Pedido enviado",;                  //        5
                  "6-Finalizado",;                      //        6
                  "7-Aguardando decisão diretoria",;    //        7
                  "8-Contrato encerrado",;              //        8
                  "9-Em analise gestão"}                //        9
Local nMB   := 0                                        
Local nAB   := 0
Local aAreaAtu	:= GetArea()
Local aAreaCNF	:= CNF->( GetArea() )
Local cContRev
Local dDAPR,dDPRO,dDSN1,dDSN2,dDSN3,dDSN4,dDSN5,cOREP,cOBSA,dDREP,dDPEDR,nVlPedR,nSREP

IF CN9->CN9_SITUAC = "10"
	MsgStop("Posicione na revisão atual do contrato", "Atenção")
	Return .F.
ENDIF


dDVIG   := CN9->CN9_XXDVIG
IF EMPTY(dDVIG)
   // Buscar o ultimo vencto dos Cronogramas
   dbSelectArea("CNF")
   dbSetOrder(3)
   cContRev := xFilial("CNF")+CN9->CN9_NUMERO+CN9->CN9_REVISA
   dbSeek(xFilial("CNF")+CN9->CN9_NUMERO+CN9->CN9_REVISA,.T.)
   Do While !EOF() .AND. cContRev == CNF_FILIAL+CNF_CONTRA+CNF_REVISA
      IF dDVIG < CNF->CNF_DTVENC
         dDVIG := CNF->CNF_DTVENC
      ENDIF
      dbSkip()
   EndDo
   dbSelectArea("CN9")
ENDIF


dDAPR   := CN9->CN9_XXDAPR
dDPRO   := CN9->CN9_XXDPRO
dDSN1   := CN9->CN9_XXDSN1
dDSN2   := CN9->CN9_XXDSN2
dDSN3   := CN9->CN9_XXDSN3
dDSN4   := CN9->CN9_XXDSN4
dDSN5   := CN9->CN9_XXDSN5
cOREP   := CN9->CN9_XXOREP
cOBSA   := CN9->CN9_XXOBSA
dDREP   := CN9->CN9_XXDREP
nSREP   := CN9->CN9_XXSREP
dDPEDR 	:= CN9->CN9_XXDTPD
nVlPedR := CN9->CN9_XXVPED
////////////
//MONTA TELA
////////////

cSnd1 := Posicione("SZ6",1,xFilial("SZ6")+CN9->CN9_XXSND1,"Z6_DESCR")
IF EMPTY(dDSN1)
   nMB := Posicione("SZ6",1,xFilial("SZ6")+CN9->CN9_XXSND1,"Z6_MESBASE")
   IF nMB > 0
      nAB := YEAR(dDataBase)
      IF nMB < MONTH(dDataBase)
         nAB++
      ENDIF   
      dDSN1 := CTOD("01/"+STRZERO(nMB,2)+"/"+STRZERO(nAB,4))
   ENDIF
ENDIF

IF !EMPTY(CN9->CN9_XXSND2)
   cSnd2 := Posicione("SZ6",1,xFilial("SZ6")+CN9->CN9_XXSND2,"Z6_DESCR")
   nSin++

   IF EMPTY(dDSN2)
      nMB := Posicione("SZ6",1,xFilial("SZ6")+CN9->CN9_XXSND2,"Z6_MESBASE")
      IF nMB > 0
         nAB := YEAR(dDataBase)
         IF nMB < MONTH(dDataBase)
            nAB++
         ENDIF   
         dDSN2 := CTOD("01/"+STRZERO(nMB,2)+"/"+STRZERO(nAB,4))
      ENDIF
   ENDIF

ELSE
   dDSN2 := CTOD("")
ENDIF

IF !EMPTY(CN9->CN9_XXSND3)
   cSnd3 := Posicione("SZ6",1,xFilial("SZ6")+CN9->CN9_XXSND3,"Z6_DESCR")
   nSin++
   IF EMPTY(dDSN3)
      nMB := Posicione("SZ6",1,xFilial("SZ6")+CN9->CN9_XXSND3,"Z6_MESBASE")
      IF nMB > 0
         nAB := YEAR(dDataBase)
         IF nMB < MONTH(dDataBase)
            nAB++
         ENDIF   
         dDSN3 := CTOD("01/"+STRZERO(nMB,2)+"/"+STRZERO(nAB,4))
      ENDIF
   ENDIF
ELSE
   dDSN3 := CTOD("")
ENDIF

IF !EMPTY(CN9->CN9_XXSND4)
   cSnd4 := Posicione("SZ6",1,xFilial("SZ6")+CN9->CN9_XXSND4,"Z6_DESCR")
   nSin++
   IF EMPTY(dDSN4)
      nMB := Posicione("SZ6",1,xFilial("SZ6")+CN9->CN9_XXSND4,"Z6_MESBASE")
      IF nMB > 0
         nAB := YEAR(dDataBase)
         IF nMB < MONTH(dDataBase)
            nAB++
         ENDIF   
         dDSN4 := CTOD("01/"+STRZERO(nMB,2)+"/"+STRZERO(nAB,4))
      ENDIF
   ENDIF
ELSE
   dDSN4 := CTOD("")
ENDIF

IF !EMPTY(CN9->CN9_XXSND5)
   cSnd5 := Posicione("SZ6",1,xFilial("SZ6")+CN9->CN9_XXSND5,"Z6_DESCR")
   nSin++
   IF EMPTY(dDSN5)
      nMB := Posicione("SZ6",1,xFilial("SZ6")+CN9->CN9_XXSND5,"Z6_MESBASE")
      IF nMB > 0
         nAB := YEAR(dDataBase)
         IF nMB < MONTH(dDataBase)
            nAB++
         ENDIF   
         dDSN5 := CTOD("01/"+STRZERO(nMB,2)+"/"+STRZERO(nAB,4))
      ENDIF
   ENDIF
ELSE
   dDSN5 := CTOD("")
ENDIF
  
Define MsDialog oDlg01 Title "Informações de Repactuação" From 000,000 To 360+(nSin*nTLin),600 Of oDlg01 Pixel

oPanelLeft:= tPanel():New(0,0,"",oDlg01,,,,,,000,000)
oPanelLeft:Align := CONTROL_ALIGN_ALLCLIENT

nSnd := 5

@ nSnd,010 Say "Data da vigencia do contrato:" Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet dDVIG Picture "@E"            Size 040,008 Pixel Of oPanelLeft
nSnd += nTLin

@ nSnd,010 Say "Apresentação da proposta:"     Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet dDAPR Picture "@E"            Size 040,008 Pixel Of oPanelLeft
nSnd += nTLin

@ nSnd,010 Say "Data base da proposta:"        Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet dDPRO Picture "@E"            Size 040,008 Pixel Of oPanelLeft
nSnd += nTLin

@ nSnd,010 Say "Reajuste sindical:"+cSnd1        Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet dDSN1 Picture "@E"            Size 040,008 Pixel Of oPanelLeft
nSnd += nTLin

IF !EMPTY(cSnd2)
   @ nSnd,010 Say "Reajuste sindical:"+cSnd2     Size 080,008 Pixel Of oPanelLeft
   @ nSnd,100 MsGet dDSN2 Picture "@E"         Size 040,008 Pixel Of oPanelLeft
   nSnd += nTLin
ENDIF

IF !EMPTY(cSnd3)
   @ nSnd,010 Say "Reajuste sindical:"+cSnd3     Size 080,008 Pixel Of oPanelLeft
   @ nSnd,100 MsGet dDSN3 Picture "@E"         Size 040,008 Pixel Of oPanelLeft
   nSnd += nTLin
ENDIF

IF !EMPTY(cSnd4)
   @ nSnd,010 Say "Reajuste sindical:"+cSnd4     Size 080,008 Pixel Of oPanelLeft
   @ nSnd,100 MsGet dDSN4 Picture "@4"         Size 040,008 Pixel Of oPanelLeft
   nSnd += nTLin
ENDIF

IF !EMPTY(cSnd5)
   @ nSnd,010 Say "Reajuste sindical"+cSnd5     Size 080,008 Pixel Of oPanelLeft
   @ nSnd,100 MsGet dDSN5 Picture "@E"         Size 040,008 Pixel Of oPanelLeft
   nSnd += nTLin
ENDIF

@ nSnd,010 Say "Data repactuação:"             Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet dDRep  Picture "@E"           Size 040,008 Pixel Of oPanelLeft
nSnd += nTLin

@ nSnd,010 Say "Data Pedido repactuação:"      Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet dDPEDR  Picture "@E"           Size 040,008 Pixel Of oPanelLeft
nSnd += nTLin

@ nSnd,010 Say "Valor Pedido repactuação:"      Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet nVlPedR  Picture "@E 999,999,999.99"          Size 040,008 Pixel Of oPanelLeft
nSnd += nTLin

@ nSnd,010 Say "Observações:"                  Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet cOREP                         Size 190,008 Pixel Of oPanelLeft
nSnd += nTLin

@ nSnd,010 Say "Obs Andamento:"                Size 080,008 Pixel Of oPanelLeft
//@ nSnd,100 MsGet cOBSA                         Size 380,008 Pixel Of oPanelLeft
oMemo:= tMultiget():New(nSnd,100,{|u|if(Pcount()>0,cOBSA:=u,cOBSA)},oPanelLeft,190,18,,,,,,.T.)

nSnd += nTLin
nSnd += nTLin

@ nSnd,010 Say "Status:"                       Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MSCOMBOBOX oComboBo1 VAR nSREP      ITEMS aStatus SIZE 100, 008 OF oPanelLeft COLORS 0, 16777215 PIXEL



ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)
If ( lOk )
	xSREP := ASCAN(aStatus,nSREP)
	IF dDVIG == CN9->CN9_XXDVIG .AND.;
       dDAPR == CN9->CN9_XXDAPR .AND.;
       dDPRO == CN9->CN9_XXDPRO .AND.;
       dDSN1 == CN9->CN9_XXDSN1 .AND.;
       dDSN2 == CN9->CN9_XXDSN2 .AND.;
       dDSN3 == CN9->CN9_XXDSN3 .AND.;
       dDSN4 == CN9->CN9_XXDSN4 .AND.;
       dDSN5 == CN9->CN9_XXDSN5 .AND.;
       cOREP == CN9->CN9_XXOREP .AND.;
       cOBSA == CN9->CN9_XXOBSA .AND.;
       dDREP == CN9->CN9_XXDREP .AND.;
       dDPEDR == CN9->CN9_XXDTPD .AND.;
       nVlPedR == CN9->CN9_XXVPED .AND.;
       xSREP == CN9->CN9_XXSREP
       
		MsgInfo("Não houve alterações", "Atenção")
		
	ELSE
		RecLock("CN9",.F.)
		CN9->CN9_XXDVIG := dDVIG
		CN9->CN9_XXDAPR := dDAPR
		CN9->CN9_XXDPRO := dDPRO
		CN9->CN9_XXDSN1 := dDSN1
		CN9->CN9_XXDSN2 := dDSN2
		CN9->CN9_XXDSN3 := dDSN3
		CN9->CN9_XXDSN4 := dDSN4
		CN9->CN9_XXDSN5 := dDSN5
		CN9->CN9_XXOREP := cOREP
		CN9->CN9_XXOBSA := cOBSA
		CN9->CN9_XXDREP := dDREP
		CN9->CN9_XXDTPD := dDPEDR
		CN9->CN9_XXVPED := nVlPedR
		CN9->CN9_XXSREP := xSREP
		msUnlock()
		
		// Log
		DbSelectArea("SZ7")
		RecLock("SZ7",.T.)
		SZ7->Z7_FILIAL := xFilial("SZ7")
		SZ7->Z7_CONTRAT:= CN9->CN9_NUMERO
		SZ7->Z7_REVISAO:= CN9->CN9_REVISA
		SZ7->Z7_DATA   := DATE()
		SZ7->Z7_HORA   := TIME()
		SZ7->Z7_USUARIO:= SUBSTR(cUsuario,7,15)
		
	    SZ7->Z7_XXDVIG := dDVIG
	    SZ7->Z7_XXDAPR := dDAPR
	    SZ7->Z7_XXDPRO := dDPRO
	    SZ7->Z7_XXDSN1 := dDSN1
	    SZ7->Z7_XXDSN2 := dDSN2
	    SZ7->Z7_XXDSN3 := dDSN3
	    SZ7->Z7_XXDSN4 := dDSN4
	    SZ7->Z7_XXDSN5 := dDSN5
	    SZ7->Z7_XXOREP := cOREP
	    SZ7->Z7_XXDREP := dDREP
		SZ7->Z7_XXDTPED:= dDPEDR
		SZ7->Z7_XXVLPED:= nVlPedR
	    SZ7->Z7_XXSREP := xSREP
		SZ7->Z7_XXOBSAN:= cOBSA
		msUnlock()
	ENDIF
EndIf
dbSelectArea(_sAlias)

CNF->(RestArea( aAreaCNF ))
RestArea( aAreaAtu )

Return lOk


// Histórico de Repactuação
User Function BKGCTA05()

Local cContrato := TRIM(CN9->CN9_NUMERO)
Local cAlias    := "SZ7"
Local aCores    := {}
Local cFiltra   := "Z7_FILIAL == '"+xFilial('SZ7')+"' .And. TRIM(Z7_CONTRAT) = '"+cContrato+"'"

Private cCadastro := "Histórico - Repactuação"
Private aRotina   := {}
Private aIndexSz  := {}
Private bFiltraBrw:= { || FilBrowse(cAlias,@aIndexSz,@cFiltra) }
                   

aRotina := {{"Pesquisar" ,"AxPesqui"	,0, 1},;
			{"Visualizar","AxVisual"	,0, 2}}
/*
-- CORES DISPONIVEIS PARA LEGENDA --
BR_AMARELO
BR_AZUL
BR_BRANCO
BR_CINZA
BR_LARANJA
BR_MARRON
BR_VERDE
BR_VERMELHO
BR_PINK
BR_PRETO
*/

AADD(aCores,{"Z7_XXDREP > (dDataBase + 30)" ,"BR_VERDE" })
AADD(aCores,{"Z7_XXDREP < (dDataBase + 30)" ,"BR_VERMELHO" })

dbSelectArea(cAlias)
dbSetOrder(1)
//+------------------------------------------------------------
//| Cria o filtro na MBrowse utilizando a função FilBrowse
//+------------------------------------------------------------
Eval(bFiltraBrw)

dbSelectArea(cAlias)
dbGoTop()
If EOF()
   MsgInfo('Não há historico de repactuação para este contrato')
Else
   mBrowse(6,1,22,75,cAlias,,,,,,aCores)
EndIf
//+------------------------------------------------
//| Deleta o filtro utilizado na função FilBrowse
//+------------------------------------------------
EndFilBrw(cAlias,aIndexSz)
Return Nil



// Alteração de dados referentes ao Reequilíbrio
User Function BKGCTA07()
Local _sAlias	:= Alias()
Local oDlg01,aButtons := {},lOk := .F.
Local nSnd  := 0,nTLin := 12
Local nSin  := 0
//Local aStatus := {"Atrasado","Em Processo - Gestão","Aguardando retorno do cliente","Em Analise - Gestão","Finalizado"}
Local aStatus := {"1-Atrasado",;                        // Status 1
                  "2-Em análise "+TRIM(SM0->M0_NOME),;  //        2 
                  "3-Aguardando retorno do cliente",;   //        3
                  "4-Em analise cliente",;              //        4
                  "5-Pedido enviado",;                  //        5
                  "6-Finalizado",;                      //        6
                  "7-Aguardando decisão diretoria",;    //        7
                  "8-Contrato encerrado",;              //        8
                  "9-Em analise gestão"}                //        9

Local aAreaAtu	:= GetArea()
Local aAreaCNF	:= CNF->( GetArea() )

IF CN9->CN9_SITUAC = "10"
	MsgStop("Posicione na revisão atual do contrato", "Atenção")
	Return .F.
ENDIF


cREOB   := CN9->CN9_XXREOB
cREOA   := CN9->CN9_XXREOA
dDREE   := CN9->CN9_XXDREE
nSREE   := CN9->CN9_XXSREE

////////////
//MONTA TELA
////////////


  
Define MsDialog oDlg01 Title "Informações de Reequilíbrio" From 000,000 To 260+(nSin*nTLin),600 Of oDlg01 Pixel

oPanelLeft:= tPanel():New(0,0,"",oDlg01,,,,,,000,000)
oPanelLeft:Align := CONTROL_ALIGN_ALLCLIENT

nSnd := 5

@ nSnd,010 Say "Data reequilíbrio:"            Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet dDRee  Picture "@E"           Size 040,008 Pixel Of oPanelLeft
nSnd += nTLin

@ nSnd,010 Say "Observações:"                  Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet cREOB                         Size 190,008 Pixel Of oPanelLeft
nSnd += nTLin

@ nSnd,010 Say "Obs Andamento:"                Size 080,008 Pixel Of oPanelLeft
//@ nSnd,100 MsGet cREOA                         Size 380,008 Pixel Of oPanelLeft
oMemo:= tMultiget():New(nSnd,100,{|u|if(Pcount()>0,cREOA:=u,cREOA)},oPanelLeft,190,18,,,,,,.T.)


nSnd += nTLin
nSnd += nTLin

@ nSnd,010 Say "Status:"                       Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MSCOMBOBOX oComboBo1 VAR nSREE      ITEMS aStatus SIZE 100, 008 OF oPanelLeft COLORS 0, 16777215 PIXEL



ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)
If ( lOk )
	xSREE := ASCAN(aStatus,nSREE)
	IF CN9->CN9_XXREOB == cREOB .AND.;
	   CN9->CN9_XXREOA == cREOA .AND.;
	   CN9->CN9_XXDREE == dDREE .AND.;
	   CN9->CN9_XXSREE == xSREE
		MsgInfo("Não houve alterações", "Atenção")
	ELSE
		RecLock("CN9",.F.)
		CN9->CN9_XXREOB := cREOB
		CN9->CN9_XXREOA := cREOA
		CN9->CN9_XXDREE := dDREE
		CN9->CN9_XXSREE := xSREE
		msUnlock()
	
		// Log
		DbSelectArea("SZC")
		RecLock("SZC",.T.)
		SZC->ZC_FILIAL := xFilial("SZC")
		SZC->ZC_CONTRAT:= CN9->CN9_NUMERO
		SZC->ZC_REVISAO:= CN9->CN9_REVISA
		SZC->ZC_DATA   := DATE()
		SZC->ZC_HORA   := TIME()
		SZC->ZC_USUARIO:= SUBSTR(cUsuario,7,15)
		
	    SZC->ZC_XXREOBS:= cREOB
	    SZC->ZC_XXREOBA:= cREOA
	    SZC->ZC_XXDREEQ:= dDREE
	    SZC->ZC_XXSREEQ:= xSREE
	
		msUnlock()
	ENDIF
EndIf
dbSelectArea(_sAlias)

CNF->(RestArea( aAreaCNF ))
RestArea( aAreaAtu )

Return lOk



User Function BKGCTA08()

Local cContrato := TRIM(CN9->CN9_NUMERO)
Local cAlias    := "SZC"
Local aCores    := {}
Local cFiltra   := "ZC_FILIAL == '"+xFilial('SZC')+"' .And. TRIM(ZC_CONTRAT) = '"+cContrato+"'"

Private cCadastro := "Histórico - Reequilibrio"
Private aRotina   := {}
Private aIndexSz  := {}
Private bFiltraBrw:= { || FilBrowse(cAlias,@aIndexSz,@cFiltra) }
                   

aRotina := {{"Pesquisar" ,"AxPesqui"	,0, 1},;
			{"Visualizar","AxVisual"	,0, 2}}
/*
-- CORES DISPONIVEIS PARA LEGENDA --
BR_AMARELO
BR_AZUL
BR_BRANCO
BR_CINZA
BR_LARANJA
BR_MARRON
BR_VERDE
BR_VERMELHO
BR_PINK
BR_PRETO
*/

AADD(aCores,{"ZC_XXDREEQ > (dDataBase + 30)" ,"BR_VERDE" })
AADD(aCores,{"ZC_XXDREEQ < (dDataBase + 30)" ,"BR_VERMELHO" })

dbSelectArea(cAlias)
dbSetOrder(1)
//+------------------------------------------------------------
//| Cria o filtro na MBrowse utilizando a função FilBrowse
//+------------------------------------------------------------
Eval(bFiltraBrw)

dbSelectArea(cAlias)
dbGoTop()
If EOF()
   MsgInfo('Não há historico de reequilibrio para este contrato')
Else
   mBrowse(6,1,22,75,cAlias,,,,,,aCores)
EndIf
//+------------------------------------------------
//| Deleta o filtro utilizado na função FilBrowse
//+------------------------------------------------
EndFilBrw(cAlias,aIndexSz)
Return Nil





// Alteração de dados referentes a Prorrogação
User Function BKGCTA09()
Local _sAlias	:= Alias()
Local oDlg01,aButtons := {},lOk := .F.
Local nSnd  := 0,nTLin := 12
Local nSin  := 0

Local aStatus := {"1-Manifestado o Interesse",;
                  "2-Aguardando Posicionamento Diretoria",;
                  "3-Aguardando Posicionamento do Cliente",;
                  "4-Recebido confirmação do Cliente",;
                  "5-Contrato Prorrogado"}

Local aAreaAtu	:= GetArea()
Local aAreaCNF	:= CNF->( GetArea() )
Local cContRev

IF CN9->CN9_SITUAC = "10"
	MsgStop("Posicione na revisão atual do contrato", "Atenção")
	Return .F.
ENDIF

dDVIG := CN9->CN9_XXDVIG
IF EMPTY(dDVIG)
   // Buscar o ultimo vencto dos Cronogramas
   dbSelectArea("CNF")
   dbSetOrder(3)
   cContRev := xFilial("CNF")+CN9->CN9_NUMERO+CN9->CN9_REVISA
   dbSeek(xFilial("CNF")+CN9->CN9_NUMERO+CN9->CN9_REVISA,.T.)
   Do While !EOF() .AND. cContRev == CNF_FILIAL+CNF_CONTRA+CNF_REVISA
      IF dDVIG < CNF->CNF_DTVENC
         dDVIG := CNF->CNF_DTVENC
      ENDIF
      dbSkip()
   EndDo
   dbSelectArea("CN9")
ENDIF


cPROB   := CN9->CN9_XXPROB
cPROA   := CN9->CN9_XXPROA
nSPRO   := CN9->CN9_XXSPRO

////////////
//MONTA TELA PRORROGAÇÃO
////////////


  
Define MsDialog oDlg01 Title "Informações - Prorrogação" From 000,000 To 260+(nSin*nTLin),600 Of oDlg01 Pixel

oPanelLeft:= tPanel():New(0,0,"",oDlg01,,,,,,000,000)
oPanelLeft:Align := CONTROL_ALIGN_ALLCLIENT

nSnd := 5

@ nSnd,010 Say "Data da vigencia do contrato:" Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet dDVIG Picture "@E"            Size 040,008 Pixel Of oPanelLeft
nSnd += nTLin

@ nSnd,010 Say "Observações:"                  Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet cPROB                         Size 190,008 Pixel Of oPanelLeft
nSnd += nTLin

@ nSnd,010 Say "Obs Andamento:"                Size 080,008 Pixel Of oPanelLeft
//@ nSnd,100 MsGet cREOA                         Size 380,008 Pixel Of oPanelLeft
oMemo:= tMultiget():New(nSnd,100,{|u|if(Pcount()>0,cPROA:=u,cPROA)},oPanelLeft,190,18,,,,,,.T.)


nSnd += nTLin
nSnd += nTLin

@ nSnd,010 Say "Status:"                       Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MSCOMBOBOX oComboBo1 VAR nSPRO      ITEMS aStatus SIZE 100, 008 OF oPanelLeft COLORS 0, 16777215 PIXEL


ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)
If ( lOk )
	xSPRO := ASCAN(aStatus,nSPRO)
	IF dDVIG == CN9->CN9_XXDVIG .AND.;
	   CN9->CN9_XXPROB == cPROB .AND.;
	   CN9->CN9_XXPROA == cPROA .AND.;
	   CN9->CN9_XXSPRO == xSPRO
		MsgInfo("Não houve alterações", "Atenção")
	ELSE
		RecLock("CN9",.F.)
		CN9->CN9_XXDVIG := dDVIG
		CN9->CN9_XXPROB := cPROB
		CN9->CN9_XXPROA := cPROA
		CN9->CN9_XXSPRO := xSPRO
		msUnlock()
	
		// Log
		DbSelectArea("SZD")
		RecLock("SZD",.T.)
		SZD->ZD_FILIAL := xFilial("SZD")
		SZD->ZD_CONTRAT:= CN9->CN9_NUMERO
		SZD->ZD_REVISAO:= CN9->CN9_REVISA
		SZD->ZD_DATA   := DATE()
		SZD->ZD_HORA   := TIME()
		SZD->ZD_USUARIO:= SUBSTR(cUsuario,7,15)
		
	    SZD->ZD_XXPROBS:= cPROB
	    SZD->ZD_XXPROBA:= cPROA
	    SZD->ZD_XXSPROR:= xSPRO
	
		msUnlock()
	ENDIF
EndIf
dbSelectArea(_sAlias)

CNF->(RestArea( aAreaCNF ))
RestArea( aAreaAtu )

Return lOk




User Function BKGCTA10()

Local cContrato := TRIM(CN9->CN9_NUMERO)
Local cAlias    := "SZD"
Local aCores    := {}
Local cFiltra   := "ZD_FILIAL == '"+xFilial('SZD')+"' .And. TRIM(ZD_CONTRAT) = '"+cContrato+"'"

Private cCadastro := "Histórico - Prorrogação"
Private aRotina   := {}
Private aIndexSz  := {}
Private bFiltraBrw:= { || FilBrowse(cAlias,@aIndexSz,@cFiltra) }
                   

aRotina := {{"Pesquisar" ,"AxPesqui"	,0, 1},;
			{"Visualizar","AxVisual"	,0, 2}}
/*
-- CORES DISPONIVEIS PARA LEGENDA --
BR_AMARELO
BR_AZUL
BR_BRANCO
BR_CINZA
BR_LARANJA
BR_MARRON
BR_VERDE
BR_VERMELHO
BR_PINK
BR_PRETO
*/

AADD(aCores,{"ZD_XXSPROR <  5" ,"BR_VERDE" })
AADD(aCores,{"ZD_XXSPROR >= 5" ,"BR_VERMELHO" })

dbSelectArea(cAlias)
dbSetOrder(1)
//+------------------------------------------------------------
//| Cria o filtro na MBrowse utilizando a função FilBrowse
//+------------------------------------------------------------
Eval(bFiltraBrw)

dbSelectArea(cAlias)
dbGoTop()
If EOF()
   MsgInfo('Não há historico de prorrogação para este contrato')
Else
   mBrowse(6,1,22,75,cAlias,,,,,,aCores)
EndIf
//+------------------------------------------------
//| Deleta o filtro utilizado na função FilBrowse
//+------------------------------------------------
EndFilBrw(cAlias,aIndexSz)
Return Nil

 


// Alteração de dados referentes a Projeção Financeira
User Function BKGCTA11()
Local _sAlias	:= Alias()
Local oDlg01,aButtons := {},lOk := .F.
Local nSnd  := 0,nTLin := 12
Local aAreaAtu	:= GetArea()
Local aAreaCNF	:= CNF->( GetArea() )
Local cContRev:="",cContSZG:=""
Local nTotFat1:=nTotCLT1:=nEncSoc1:=nAJCuto1:=nEncAC1:=0
Local nMaterial1:=nEquip1:=nBenef1:=nUnif1:=nTributos1:=nDespDiv1:=nRentab1:=0
Local cNewSeq := ""
Local cQuery  := ""

PRIVATE dDVigPrFin := date()
PRIVATE nTotFat:=nTotCLT:=nEncSoc:=nVlEncSoc:=nAJCuto:=nEncAC:=nVLEncAC:=nInsumos:=nBenef:=nUnif:=nDespDiv:=0
PRIVATE nMaterial:=nEquip:=nTributos:=nVLTributos:=nRentab:=nVLRentab:=nTotGeral:=nFatPrev:=0
PRIVATE lAlterad:= .F.
PRIVATE aSZL01:= {}
PRIVATE aSZL02:= {}
PRIVATE dDtProj   := CTOD("")
PRIVATE cSeqProj := ""

IF CN9->CN9_SITUAC = "10"
	MsgStop("Posicione na revisão atual do contrato", "Atenção")
	Return .F.
ENDIF

IF CN9->CN9_SITUAC $ "01/06/07/08"
	MSGSTOP("A Condição do Contrato não permite inclusão de Planejamento", "Atenção")
	Return .F.
ENDIF 

dbSelectArea("SZG")
dbSetOrder(1)
cContSZG := CN9->CN9_NUMERO //+CN9->CN9_REVISA
dbSeek(xFilial("SZG")+cContSZG,.T.)
Do While SZG->(!EOF()) .AND. ALLTRIM(SZG->ZG_CONTRAT)==ALLTRIM(cContSZG) //+SZG->ZG_REVISAO
	IF SZG->ZG_DATA <= dDVigPrFin
		dDtProj     :=  SZG->ZG_DATA
		cSeqProj	:=  SZG->ZG_SEQ
		nTotFat1	:=	nTotFat		:=	SZG->ZG_FATURAD
		nTotCLT1	:= 	nTotCLT		:=	SZG->ZG_CLT
		nEncSoc1	:=	nEncSoc		:=	SZG->ZG_ENCSOC
		nVlEncSoc	:=	SZG->ZG_VLENCSO
		nAJCuto1	:=	nAJCuto		:=	SZG->ZG_AJCUSTO
		nEncAC1		:=	nEncAC 		:=	SZG->ZG_ENCAC
		nVLEncAC	:=	SZG->ZG_VLENAC
		nInsumos	:=	SZG->ZG_INSUMOS
		nMaterial1	:= 	nMaterial	:=	SZG->ZG_MATERIA
		nEquip1		:=	nEquip		:=	SZG->ZG_EQUIPAM
		nBenef1		:=	nBenef		:=	SZG->ZG_BENEFIC
		nUnif1		:=	nUnif		:=	SZG->ZG_UNIFORM
		nTributos1	:=	nTributos	:=	SZG->ZG_TRIBUTO
		nDespDiv1	:=	nDespDiv	:=	SZG->ZG_DESPDIV
		nVLTributos	:=	SZG->ZG_VLTRIBU
		nRentab1	:=	nRentab		:=	SZG->ZG_RENTABI
		nVLRentab	:=	SZG->ZG_VLRENTA
		nTotGeral 	:=	SZG->ZG_TOTAL
	ENDIF
	dbSelectArea("SZG")
    dbSkip()
EndDo

//CARREGA ITENS DETALHE BENEFICIOS
dbSelectArea("SZL")
SZL->(dbSetOrder(1))
SZL->(dbSeek(xFilial("SZL")+ALLTRIM(cContSZG)+"01"+DTOS(dDtProj)+cSeqProj,.T.))
DO WHILE SZL->(!EOF()) .AND. SZL->ZL_CONTRAT==ALLTRIM(cContSZG) .AND. SZL->ZL_TIPO=='01' .AND. SZL->ZL_DATA==dDtProj .AND. SZL->ZL_SEQ==cSeqProj 

	AADD(aSZL01,{SZL->ZL_CODIGO,SZL->ZL_DESC,SZL->ZL_VALOR})

	SZL->(dbskip())
ENDDO

//CARREGA ITENS DETALHE GASTOS GERAIS
dbSelectArea("SZL")
SZL->(dbSetOrder(1))
SZL->(dbSeek(xFilial("SZL")+ALLTRIM(cContSZG)+"02"+DTOS(dDtProj)+cSeqProj,.T.))
DO WHILE SZL->(!EOF()) .AND. SZL->ZL_CONTRAT==ALLTRIM(cContSZG) .AND. SZL->ZL_TIPO=='02' .AND. SZL->ZL_DATA==dDtProj .AND. SZL->ZL_SEQ==cSeqProj 

	AADD(aSZL02,{SZL->ZL_CODIGO,SZL->ZL_DESC,SZL->ZL_VALOR})

	SZL->(dbskip())
ENDDO


dDVIG := CN9->CN9_XXDVIG
dDVIG2 := dDVIG
nFatPrevUltimo :=0
// Buscar o ultimo vencto dos Cronogramas
dbSelectArea("CNF")
dbSetOrder(3)
cContRev := xFilial("CNF")+CN9->CN9_NUMERO+CN9->CN9_REVISA
dbSeek(xFilial("CNF")+CN9->CN9_NUMERO+CN9->CN9_REVISA,.T.)
dtInicio:= CNF->CNF_DTVENC
Do While !EOF() .AND. cContRev == CNF_FILIAL+CNF_CONTRA+CNF_REVISA
   IF dDVIG2 < CNF->CNF_DTVENC
      dDVIG2 := CNF->CNF_DTVENC
   ENDIF
  IF STRZERO(MONTH(dDVigPrFin),2)+"/"+STRZERO(YEAR(dDVigPrFin),4) == CNF->CNF_COMPET
 	 nFatPrev += CNF->CNF_VLPREV
  ENDIF
  nFatPrevUltimo := CNF->CNF_VLPREV 
  dbSkip()
EndDo

IF nFatPrev == 0
// .AND. nFatPrevUltimo <> 0
//   nFatPrev := nFatPrevUltimo
	MSGSTOP("Competência não encontrada para data informada", "Atenção")
ENDIF 

dbSelectArea("CN9")

IF dDVIG < dDVIG2
	dDVIG := dDVIG2
ENDIF

////////////
//MONTA TELA PROJEÇÃO FINANCEIRA
////////////

  
Define MsDialog oDlg01 Title "Informações Projeção Financeira - Contrato:"+ALLTRIM(CN9->CN9_NUMERO)+" Revisão:"+CN9->CN9_REVISA From 000,000 To 410,680 Of oDlg01 Pixel 

oPanelLeft:= tPanel():New(0,0,"",oDlg01,,,,,,000,000)
oPanelLeft:Align := CONTROL_ALIGN_ALLCLIENT

nSnd := 5

@ nSnd,002 Say "Competência Projeção Financ.:" Size 080,008 Pixel Of oPanelLeft
@ nSnd,075 MsGet dDVigPrFin Picture "@E"            Size 040,008 Pixel Of oPanelLeft ON CHANGE(BUSCACNF(cContRev))

@ nSnd,165 Say "Até Vigência do Contrato:" Size 080,008 Pixel Of oPanelLeft
@ nSnd,230 MsGet dDVIG Picture "@E"            Size 040,008 Pixel Of oPanelLeft WHEN .F.
nSnd += nTLin

@ nSnd,028 Say "Valor Total Mensal:" Size 080,008 Pixel Of oPanelLeft
@ nSnd,075 MsGet nTotFat Picture "@E 999,999,999,999.99" Size 060,008 Pixel Of oPanelLeft ON CHANGE(SomaSZG())

@ nSnd,157 Say "Fat. Previsto no Cronograma:"      Size 080,008 Pixel Of oPanelLeft
@ nSnd,230 MsGet nFatPrev Picture "@E 999,999,999,999.99" Size 060,008 Pixel Of oPanelLeft WHEN .F.
nSnd += nTLin

@ nSnd,011 Say "Total Remuneração (CLT):"                  Size 080,008 Pixel Of oPanelLeft
@ nSnd,075 MsGet nTotCLT Picture "@E 999,999,999,999.99" Size 060,008 Pixel Of oPanelLeft ON CHANGE(SomaSZG())
nSnd += nTLin

@ nSnd,020 Say "Encargos Sociais (%):"                Size 080,008 Pixel Of oPanelLeft
@ nSnd,075 MsGet nEncSoc  Picture "@E 99.9999"           Size 040,008 Pixel Of oPanelLeft ON CHANGE(SomaSZG())

@ nSnd,169 Say "Valor Encargos Sociais:"                Size 080,008 Pixel Of oPanelLeft
@ nSnd,230 MsGet nVlEncSoc Picture "@E 999,999,999,999.99" Size 060,008 Pixel Of oPanelLeft WHEN .F.
nSnd += nTLin

@ nSnd,034 Say "Ajuda de Custo:"                  Size 080,008 Pixel Of oPanelLeft
@ nSnd,075 MsGet nAJCuto Picture "@E 999,999,999,999.99" Size 060,008 Pixel Of oPanelLeft ON CHANGE(SomaSZG())
nSnd += nTLin

@ nSnd,030 Say "Encagos A.C (%):"                Size 080,008 Pixel Of oPanelLeft
@ nSnd,075 MsGet nEncAC  Picture "@E 99.9999"      Size 040,008 Pixel Of oPanelLeft ON CHANGE(SomaSZG())

@ nSnd,179 Say "Valor Encargos A.C:"                Size 080,008 Pixel Of oPanelLeft
@ nSnd,230 MsGet nVLEncAC Picture "@E 999,999,999,999.99" Size 060,008 Pixel Of oPanelLeft WHEN .F.
nSnd += nTLin

@ nSnd,048 Say "Materiais:"                Size 080,008 Pixel Of oPanelLeft
@ nSnd,075 MsGet nMaterial Picture "@E 999,999,999,999.99" Size 060,008 Pixel Of oPanelLeft WHEN ON CHANGE(SomaSZG())

@ nSnd,205 Say "Insumos:"                Size 080,008 Pixel Of oPanelLeft
@ nSnd,230 MsGet nInsumos Picture "@E 999,999,999,999.99" Size 060,008 Pixel Of oPanelLeft WHEN .F.
nSnd += nTLin

@ nSnd,038 Say "Equipamentos:"                Size 080,008 Pixel Of oPanelLeft
@ nSnd,075 MsGet nEquip Picture "@E 999,999,999,999.99" Size 060,008 Pixel Of oPanelLeft WHEN ON CHANGE(SomaSZG())

@ nSnd,200 Say "Benefícios:"                Size 080,008 Pixel Of oPanelLeft
@ nSnd,230 MsGet nBenef Picture "@E 999,999,999,999.99" Size 060,008 Pixel Of oPanelLeft WHEN ON CHANGE(SomaSZG())
@ nSnd,283 BUTTON oBtnBenf PROMPT "Detalhar" SIZE 050,10 ACTION {|| ValidaDet("01")} OF oPanelLeft PIXEL  
nSnd += nTLin

@ nSnd,202 Say "Uniformes:"                Size 080,008 Pixel Of oPanelLeft
@ nSnd,230 MsGet nUnif Picture "@E 999,999,999,999.99" Size 060,008 Pixel Of oPanelLeft WHEN  ON CHANGE(SomaSZG())
nSnd += nTLin

@ nSnd,190 Say "Desp. Diversas:"                Size 080,008 Pixel Of oPanelLeft
@ nSnd,230 MsGet nDespDiv Picture "@E 999,999,999,999.99" Size 060,008 Pixel Of oPanelLeft WHEN ON CHANGE(SomaSZG())
@ nSnd,283 BUTTON oBtnDpDiv PROMPT "Detalhar" SIZE 050,10 ACTION {|| ValidaDet("02") } OF oPanelLeft PIXEL  
nSnd += nTLin 

@ nSnd,041 Say "Tributos (%):"                Size 080,008 Pixel Of oPanelLeft
@ nSnd,075 MsGet nTributos Picture "@E 99.9999" Size 040,008 Pixel Of oPanelLeft ON CHANGE(SomaSZG())

@ nSnd,192 Say "Valor Tributos:"                Size 080,008 Pixel Of oPanelLeft
@ nSnd,230 MsGet nVLTributos Picture "@E 999,999,999,999.99" Size 060,008 Pixel Of oPanelLeft WHEN .F.
nSnd += nTLin

@ nSnd,028 Say "Rentabilidade (%):"                Size 080,008 Pixel Of oPanelLeft 
@ nSnd,075 MsGet nRentab Picture "@E 99.999999"    Size 040,008 Pixel Of oPanelLeft ON CHANGE(SomaSZG())

@ nSnd,178 Say "Valor Rentabilidade:"                Size 080,008 Pixel Of oPanelLeft
@ nSnd,230 MsGet nVLRentab Picture "@E 999,999,999,999.99" Size 060,008 Pixel Of oPanelLeft WHEN .F. 
nSnd += nTLin

@ nSnd,045 Say "Total Geral:"                Size 080,008 Pixel Of oPanelLeft
@ nSnd,075 MsGet nTotGeral Picture "@E 999,999,999,999.99" Size 060,008 Pixel Of oPanelLeft WHEN .F.

@ nSnd+5,230 BUTTON oBtnAnx PROMPT "Anexar Planilha" SIZE 60,12 ACTION {|| MsDocument("CN9",CN9->(Recno()),3) } OF oPanelLeft PIXEL  
nSnd += nTLin

ACTIVATE MSDIALOG oDlg01 CENTERED Valid(validaSZG()) ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons) 

If ( lOk )
   lOk:=.F.
   IF	dDVigPrFin  == date() .AND.;
   		nTotFat1	== nTotFat .AND.;
		nTotCLT1	== nTotCLT .AND.;
		nEncSoc1	== nEncSoc .AND.;
		nAJCuto1	== nAJCuto .AND.;
		nEncAC1		== nEncAC .AND.;
		nMaterial1	== nMaterial .AND.;
		nBenef1		== nBenef .AND.;
		nEquip1		== nEquip .AND.;
		nUnif1		== nUnif .AND.;
		nTributos1	== nTributos .AND.;
		nDespDiv1	== nDespDiv .AND.;
		nRentab1	== nRentab .AND.;
		!lAlterad
		MsgInfo("Não houve alterações", "Atenção")
	ELSE
        cNewSeq := ""
        cQuery  := ""

//      SELECT TOP 1 ZG_SEQ from SZG010 SZG WHERE ZG_CONTRAT = '236000376' AND ZG_DATA = '20160218' AND SZG.D_E_L_E_T_ = ''

		cQuery := " SELECT TOP 1 ZG_SEQ "
		cQuery += " FROM "+RETSQLNAME("SZG")+" SZG"
		cQuery += " WHERE ZG_CONTRAT = '"+CN9->CN9_NUMERO+"' AND ZG_DATA = '"+DTOS(dDVigPrFin)+"' AND SZG.D_E_L_E_T_ = '' " 
		cQuery += " ORDER BY ZG_CONTRAT,ZG_DATA,ZG_SEQ DESC "

        cAliasQZG := GetNextAlias()
		TCQUERY cQuery NEW ALIAS (cAliasQZG)
		
		DbSelectArea(cAliasQZG)
        cNewSeq := STRZERO( VAL((cAliasQZG)->ZG_SEQ) + 1 ,2)
		(cAliasQZG)->(dbCloseArea())
        
		DbSelectArea("SZG")
		RecLock("SZG",.T.)
		SZG->ZG_FILIAL 	:= xFilial("SZG")
		SZG->ZG_CONTRAT	:= CN9->CN9_NUMERO
		SZG->ZG_REVISAO	:= CN9->CN9_REVISA
		SZG->ZG_DATA   	:= dDVigPrFin
		SZG->ZG_SEQ    	:= cNewSeq  // AQUI ///
		SZG->ZG_USUARIO	:= SUBSTR(cUsuario,7,15)
		SZG->ZG_FATURAD	:= nTotFat
		SZG->ZG_CLT		:= nTotCLT
		SZG->ZG_ENCSOC	:= nEncSoc
		SZG->ZG_VLENCSO	:= nVlEncSoc
		SZG->ZG_AJCUSTO	:= nAJCuto
		SZG->ZG_ENCAC	:= nEncAC
		SZG->ZG_VLENAC	:= nVLEncAC
		SZG->ZG_INSUMOS	:= nInsumos
		SZG->ZG_MATERIA	:= nMaterial
		SZG->ZG_BENEFIC	:= nBenef
		SZG->ZG_EQUIPAM	:= nEquip
		SZG->ZG_UNIFORM	:= nUnif
		SZG->ZG_TRIBUTO	:= nTributos
		SZG->ZG_DESPDIV	:= nDespDiv
		SZG->ZG_VLTRIBU	:= nVLTributos
		SZG->ZG_RENTABI	:= nRentab
		SZG->ZG_VLRENTA	:= nVLRentab
		SZG->ZG_TOTAL	:= nTotGeral
		SZG->ZG_DATAI	:= DATE()
		SZG->ZG_HORAI	:= TIME()

		SZG->(msUnlock())
				
        IF LEN(aSZL01) > 0
	 		FOR _nx := 1 to LEN(aSZL01)
				DbSelectArea("SZL")
				RecLock("SZL",.T.)
				SZL->ZL_FILIAL 	:= xFilial("SZG")
				SZL->ZL_CONTRAT	:= CN9->CN9_NUMERO
				SZL->ZL_TIPO	:= '01'
				SZL->ZL_DATA   	:= dDVigPrFin
				SZL->ZL_SEQ   	:= cNewSeq
				SZL->ZL_CODIGO 	:= aSZL01[_nx,1]
				SZL->ZL_DESC 	:= aSZL01[_nx,2]
				SZL->ZL_VALOR  	:= aSZL01[_nx,3]
				SZL->(msUnlock())
	  		NEXT
        ENDIF

        IF LEN(aSZL02) > 0
	 		FOR _nx := 1 to LEN(aSZL02)
				DbSelectArea("SZL")
				RecLock("SZL",.T.)
				SZL->ZL_FILIAL 	:= xFilial("SZG")
				SZL->ZL_CONTRAT	:= CN9->CN9_NUMERO
				SZL->ZL_TIPO	:= '02'
				SZL->ZL_DATA   	:= dDVigPrFin
				SZL->ZL_SEQ   	:= cNewSeq
				SZL->ZL_CODIGO 	:= aSZL02[_nx,1]
				SZL->ZL_DESC 	:= aSZL02[_nx,2]
				SZL->ZL_VALOR  	:= aSZL02[_nx,3]
				SZL->(msUnlock())
	  		NEXT
        ENDIF

		MsgInfo("Ateração concluída com sucesso!","Atenção")
	ENDIF

EndIf
dbSelectArea(_sAlias)

CNF->(RestArea( aAreaCNF ))
RestArea( aAreaAtu )

Return lOk

STATIC FUNCTION ValidaDet(cTipo)
LOCAL nTotDet

nTotDet := U_BKGCTA17(CN9->CN9_NUMERO,cTipo)

IF cTipo == "01"
	IF nTotDet > 0 
		IF nTotDet <> nBenef
			IF nBenef > 0
		   		IF MsgNoYes( "Total do Detalhamento dos Benefícios, diferente do valor atual do Benefício. Assumir valor total do detalhamento?  "+STR(nTotDet,10,2), "Atenção" )
					nBenef := nTotDet 
		   		ENDIF
		    ELSE
				nBenef := nTotDet 
			ENDIF
		ENDIF
	ENDIF
ENDIF

IF cTipo == "02"
	IF nTotDet > 0 
		IF nTotDet <> (nDespDiv + nMaterial + nEquip + nUnif)
			IF (nDespDiv + nMaterial + nEquip + nUnif) > 0
		   		IF MsgNoYes( "Total do Detalhamento dos gastor gerais, diferente da soma dos Materiais,Equipamentos, Uniformes e Desp. Diversas. Assumir valor total do detalhamento? "+STR(nTotDet,10,2), "Atenção" )
		   			nDespDiv := nTotDet
		   			nMaterial:= 0
		   			nEquip   := 0
		   			nUnif    := 0
		   		ENDIF
		 	ELSE
	   			nDespDiv := nTotDet
	   			nMaterial:= 0
	   			nEquip   := 0
	   			nUnif    := 0
		 	ENDIF
		ENDIF
	ENDIF
ENDIF

SomaSZG() 


RETURN NIL

 
User Function BKGCTA12()

Local cContrato := TRIM(CN9->CN9_NUMERO)
Local cAlias    := "SZG"
Local aCores    := {}
Local cFiltra   := "ZG_FILIAL == '"+xFilial('SZG')+"' .And. TRIM(ZG_CONTRAT) = '"+cContrato+"'"

Private cCadastro := "Histórico - Projeção Financeira"
Private aRotina   := {}
Private aIndexSz  := {}
Private bFiltraBrw:= { || FilBrowse(cAlias,@aIndexSz,@cFiltra) }

aRotina := {{"Pesquisar" ,"AxPesqui"	,0, 1},;
			{"Visualizar","AxVisual"	,0, 2}}
/*
-- CORES DISPONIVEIS PARA LEGENDA --
BR_AMARELO
BR_AZUL
BR_BRANCO
BR_CINZA
BR_LARANJA
BR_MARRON
BR_VERDE
BR_VERMELHO
BR_PINK
BR_PRETO
*/

AADD(aCores,{"ZG_DATA >=  DATE()" ,"BR_VERDE" })
AADD(aCores,{"ZG_DATA <  DATE()" ,"BR_VERMELHO" })

dbSelectArea(cAlias)
dbSetOrder(1)
//+------------------------------------------------------------
//| Cria o filtro na MBrowse utilizando a função FilBrowse
//+------------------------------------------------------------
Eval(bFiltraBrw)

dbSelectArea(cAlias)
dbGoTop()
If EOF()
   MsgInfo('Não há histórico de projeção financeira para este contrato')
Else
   mBrowse(6,1,22,75,cAlias,,,,,,aCores)
EndIf
//+------------------------------------------------
//| Deleta o filtro utilizado na função FilBrowse
//+------------------------------------------------
EndFilBrw(cAlias,aIndexSz)
Return Nil
          

Static Function SomaSZG()

nVlEncSoc 	:=	nTotCLT * (nEncSoc *0.01) 
nVLEncAC	:=	nAJCuto * (nEncAC * 0.01)                                                                                                
nInsumos 	:=  nBenef+nUnif+nDespDiv                                        
nVLTributos := 	nTotFat * (nTributos * 0.01)
nVLRentab 	:= 	nTotFat * (nRentab * 0.01) 
nTotGeral	:=  nTotCLT+ nVlEncSoc + nAJCuto + nVLEncAC + nInsumos + nMaterial + nEquip + nVLTributos + nVLRentab

Return 


Static Function  BUSCACNF(cContRev)

nFatPrevUltimo	:= 0
nFatPrev 		:= 0
dbSelectArea("CNF")
dbSetOrder(3)
dbSeek(cContRev,.T.)
Do While !EOF() .AND. cContRev == CNF_FILIAL+CNF_CONTRA+CNF_REVISA
  IF STRZERO(MONTH(dDVigPrFin),2)+"/"+STRZERO(YEAR(dDVigPrFin),4) == CNF->CNF_COMPET
 	 nFatPrev += CNF->CNF_VLPREV
  ENDIF 
  nFatPrevUltimo = CNF->CNF_VLPREV 
  dbSkip()
EndDo

IF nFatPrev == 0 .AND. nFatPrevUltimo <> 0
   nFatPrev := nFatPrevUltimo
ENDIF

dbSelectArea("CN9")

dbSelectArea("SZG")
dbSetOrder(1)
cContSZG := CN9->CN9_NUMERO //+CN9->CN9_REVISA
dbSeek(xFilial("SZG")+cContSZG,.T.)
Do While SZG->(!EOF()) .AND. ALLTRIM(SZG->ZG_CONTRAT)==ALLTRIM(cContSZG) //+SZG->ZG_REVISAO
	IF SZG->ZG_DATA <= dDVigPrFin
		dDtProj     := SZG->ZG_DATA
		cSeqProj	:= SZG->ZG_SEQ
	ENDIF
    SZG->(dbSkip())
EndDo

//CARREGA ITENS DETALHE BENEFICIOS
aSZL01 :={}
dbSelectArea("SZL")
SZL->(dbSetOrder(1))
SZL->(dbSeek(xFilial("SZL")+ALLTRIM(cContSZG)+"01"+DTOS(dDtProj)+cSeqProj,.T.))
DO WHILE SZL->(!EOF()) .AND. SZL->ZL_CONTRAT==ALLTRIM(cContSZG) .AND. SZL->ZL_TIPO=='01' .AND. SZL->ZL_DATA==dDtProj .AND. SZL->ZL_SEQ==cSeqProj 

	AADD(aSZL01,{SZL->ZL_CODIGO,SZL->ZL_DESC,SZL->ZL_VALOR})

	SZL->(dbskip())
ENDDO

//CARREGA ITENS DETALHE GASTOS GERAIS
aSZL02 :={}
dbSelectArea("SZL")
SZL->(dbSetOrder(1))
SZL->(dbSeek(xFilial("SZL")+ALLTRIM(cContSZG)+"02"+DTOS(dDtProj)+cSeqProj,.T.))
DO WHILE SZL->(!EOF()) .AND. SZL->ZL_CONTRAT==ALLTRIM(cContSZG) .AND. SZL->ZL_TIPO=='02' .AND. SZL->ZL_DATA==dDtProj .AND. SZL->ZL_SEQ==cSeqProj 

	AADD(aSZL02,{SZL->ZL_CODIGO,SZL->ZL_DESC,SZL->ZL_VALOR})

	SZL->(dbskip())
ENDDO


 
RETURN


Static Function  validaSZG()
LOCAL lOk:=.T.

    IF dDVigPrFin < dtInicio
		MsgStop("Data Projeção Financeira menor que a vigência do Cronograma!", "Atenção")
		lOk:= .F.
    ENDIF
    IF dDVigPrFin > dDVig
		MsgStop("Data Projeção Financeira maior que a vigência do Contrato!", "Atenção")
		lOk:= .F.
    ENDIF
    IF nFatPrev == 0
		MSGSTOP("Competência não encontrada para data informada", "Atenção")
		lOk:= .F.
	ENDIF 
	If TRANSFORM(nTotFat,"@E 999,999,999,999.99") <> TRANSFORM(nTotGeral,"@E 999,999,999,999.99")
		MsgStop("Valor Total Mensal informado diferente do Total Geral!"+Chr(13) + Chr(10)+"Valor Total Mensal="+TRANSFORM(nTotFat,"@E 999,999,999,999.99")+Chr(13) + Chr(10)+"Total Geral=            "+TRANSFORM(nTotGeral,"@E 999,999,999,999.99"), "Atenção")
		lOk:= .F.
	Endif                                                                                                                                                                                                                                    
	If TRANSFORM(nTotFat,"@E 999,999,999,999.99") <> TRANSFORM(nFatPrev,"@E 999,999,999,999.99") 
		MsgStop("Valor Total Mensal informado diferente do Fat. Previsto no Cronograma!"+Chr(13) + Chr(10)+"Valor Total Mensal=                 "+TRANSFORM(nTotFat,"@E 999,999,999,999.99")+Chr(13) + Chr(10)+"Fat. Previsto no Cronograma="+TRANSFORM(nFatPrev,"@E 999,999,999,999.99"), "Atenção")
		lOk:= .F.
	Endif
	
RETURN lOk



// Alteração de dados referentes a Insumos
User Function BKGCTA13()
Local _sAlias	:= Alias()
Local oDlg01,aButtons := {},lOk := .F.
Local nSnd  := 0,nTLin := 15
Local aStatus :={"S-Sim",;
				 "N-Não",;
				 " "}
Local aAreaAtu	:= GetArea()
Local aAreaSZH	:= SZH->( GetArea() )


PRIVATE cXXUNI:="",dXXUNID:=CTOD(""),cXXUNIH:=""
PRIVATE cXXEPI:="",dXXEPID:=CTOD(""),cXXEPIH:=""
PRIVATE cXXMAT:="",dXXMATD:=CTOD(""),cXXMATH:=""
PRIVATE cXXEQP:="",dXXEQPD:=CTOD(""),cXXEQPH:=""


IF CN9->CN9_SITUAC = "10"
	MsgStop("Posicione na revisão atual do contrato", "Atenção")
	Return .F.
ENDIF

//Carrega Valores do Contrato
IF CN9->CN9_XXUNI =='S'
    cXXUNI := "S-Sim"
	fXXUNI:=.F.
ELSEIF CN9->CN9_XXUNI =='N'
    cXXUNI := "N-Não"
	fXXUNI:=.T.
ELSE
    cXXUNI := " "
	fXXUNI:=.T.
ENDIF

dXXUNID	:= CN9->CN9_XXUNID
cXXUNIH	:= CN9->CN9_XXUNIH

IF CN9->CN9_XXEPI =='S'
    cXXEPI := "S-Sim"
	fXXEPI:=.F.
ELSEIF CN9->CN9_XXEPI =='N'
    cXXEPI := "N-Não"
	fXXEPI:=.T.
ELSE
    cXXEPI := " "
	fXXEPI:=.T.
ENDIF

dXXEPID	:= CN9->CN9_XXEPID
cXXEPIH	:= CN9->CN9_XXEPIH

IF CN9->CN9_XXMAT =='S'
    cXXMAT := "S-Sim"
	fXXMAT:=.F.
ELSEIF CN9->CN9_XXMAT =='N'
    cXXMAT := "N-Não"
	fXXMAT:=.T.
ELSE
    cXXMAT := " "
	fXXMAT:=.T.
ENDIF
dXXMATD	:= CN9->CN9_XXMATD
cXXMATH	:= CN9->CN9_XXMATH

IF CN9->CN9_XXEQP =='S'
    cXXEQP := "S-Sim"
	fXXEQP:=.F.
ELSEIF CN9->CN9_XXEQP =='N'
    cXXEQP := "N-Não"
	fXXEQP:=.T.
ELSE
    cXXEQP := " "
	fXXEQP:=.T.
ENDIF
dXXEQPD	:= CN9->CN9_XXEQPD
cXXEQPH	:= CN9->CN9_XXEQPH



////////////
//MONTA TELA INSUMOS
////////////
 
Define MsDialog oDlg01 Title "Informações - Insumos Operacionais" From 000,000 To 370,600 Of oDlg01 Pixel

oPanelLeft:= tPanel():New(0,0,"",oDlg01,,,,,,000,000)
oPanelLeft:Align := CONTROL_ALIGN_ALLCLIENT

nSnd := 5

@ nSnd,010 Say "Controla Uniformes:"                       Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 COMBOBOX cXXUNI  ITEMS aStatus SIZE 040,010 Pixel OF oPanelLeft WHEN fXXUNI
//@ nSnd,100 MSCOMBOBOX oComboBo1 VAR nXXUNI ITEMS aStatus SIZE 040,010 OF oPanelLeft COLORS 0, 16777215 PIXEL WHEN fXXUNI

@ nSnd,180 Say "Data Prox. Troca Unif.:" Size 080,008 Pixel Of oPanelLeft 
@ nSnd,250 MsGet dXXUNID Picture "@E"            Size 040,008 Pixel Of oPanelLeft ON CHANGE(IIF(dXXUNID<>CN9->CN9_XXUNID,cXXUNIH:=SPACE(120),))
nSnd += nTLin

@ nSnd,010 Say "Obs Andamento Uniformes:"                  Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet cXXUNIH                         Size 190,008 Pixel Of oPanelLeft
nSnd += nTLin + 7

@ nSnd,010 Say "Controla E.P.I.:"                       Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 COMBOBOX cXXEPI  ITEMS aStatus SIZE 040,010 Pixel OF oPanelLeft WHEN fXXEPI
//@ nSnd,100 MSCOMBOBOX oComboBo2 VAR nXXEPI ITEMS aStatus SIZE 040,010 OF oPanelLeft COLORS 0, 16777215 PIXEL WHEN fXXEPI

@ nSnd,180 Say "Data Prox. Troca E.P.I.:" Size 080,008 Pixel Of oPanelLeft
@ nSnd,250 MsGet dXXEPID Picture "@E"            Size 040,008 Pixel Of oPanelLeft ON CHANGE(IIF(dXXEPID<>CN9->CN9_XXEPID,cXXEPIH:=SPACE(120),))
nSnd += nTLin

@ nSnd,010 Say "Obs Andamento E.P.I.:"                  Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet cXXEPIH                         Size 190,008 Pixel Of oPanelLeft
nSnd += nTLin + 7

@ nSnd,010 Say "Controla Materiais:"                       Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 COMBOBOX cXXMAT  ITEMS aStatus SIZE 040,010 Pixel OF oPanelLeft WHEN fXXMAT
//@ nSnd,100 MSCOMBOBOX oComboBo3 VAR nXXMAT ITEMS aStatus SIZE 040,010 OF oPanelLeft COLORS 0, 16777215 PIXEL WHEN fXXMAT

@ nSnd,180 Say "Data Prox. Troca Mat.:" Size 080,008 Pixel Of oPanelLeft
@ nSnd,250 MsGet dXXMATD Picture "@E"            Size 040,008 Pixel Of oPanelLeft ON CHANGE(IIF(dXXMATD<>CN9->CN9_XXMATD,cXXMATH:=SPACE(120),))
nSnd += nTLin

@ nSnd,010 Say "Obs Andamento Materiais:"                  Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet cXXMATH                         Size 190,008 Pixel Of oPanelLeft
nSnd += nTLin + 7

@ nSnd,010 Say "Controla Equipamentos:"                       Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 COMBOBOX cXXEQP  ITEMS aStatus SIZE 040,010 Pixel OF oPanelLeft WHEN fXXEQP
//@ nSnd,100 MSCOMBOBOX oComboBo4 VAR nXXEQP ITEMS aStatus SIZE 040,010 OF oPanelLeft COLORS 0, 16777215 PIXEL WHEN fXXEQP

@ nSnd,180 Say "Data Prox. Troca Equip.:" Size 080,008 Pixel Of oPanelLeft
@ nSnd,250 MsGet dXXEQPD Picture "@E"            Size 040,008 Pixel Of oPanelLeft ON CHANGE(IIF(dXXEQPD<>CN9->CN9_XXEQPD,cXXEQPH:=SPACE(120),))
nSnd += nTLin

@ nSnd,010 Say "Obs Andamento Equipamentos:"                  Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet cXXEQPH                         Size 190,008 Pixel Of oPanelLeft
nSnd += nTLin + 7


ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)  VALID(validaSZH())

If ( lOk )
	lOk:= .F.
	IF SUBSTR(cXXUNI,1,1) == CN9->CN9_XXUNI .AND.;
		dXXUNID == CN9->CN9_XXUNID .AND.;
		cXXUNIH == CN9->CN9_XXUNIH .AND.;
		SUBSTR(cXXEPI,1,1) == CN9->CN9_XXEPI .AND.;
		dXXEPID == CN9->CN9_XXEPID .AND.;
		cXXEPIH == CN9->CN9_XXEPIH .AND.;
		SUBSTR(cXXMAT,1,1) == CN9->CN9_XXMAT .AND.;
		dXXMATD == CN9->CN9_XXMATD .AND.;
		cXXMATH == CN9->CN9_XXMATH .AND.;
		SUBSTR(cXXEQP,1,1) == CN9->CN9_XXEQP .AND.;
		dXXEQPD == CN9->CN9_XXEQPD .AND.;
		cXXEQPH == CN9->CN9_XXEQPH

		MsgInfo("Não houve alterações", "Atenção")
	ELSE
		RecLock("CN9",.F.)
		//Carrega Valores do Contrato
		CN9->CN9_XXUNI  := SUBSTR(cXXUNI,1,1)
		CN9->CN9_XXUNID := dXXUNID 
		CN9->CN9_XXUNIH := cXXUNIH 
		CN9->CN9_XXEPI  := SUBSTR(cXXEPI,1,1)
		CN9->CN9_XXEPID := dXXEPID 
		CN9->CN9_XXEPIH := cXXEPIH 
		CN9->CN9_XXMAT  := SUBSTR(cXXMAT,1,1)
		CN9->CN9_XXMATD := dXXMATD 
		CN9->CN9_XXMATH := cXXMATH 
		CN9->CN9_XXEQP  := SUBSTR(cXXEQP,1,1)
		CN9->CN9_XXEQPD := dXXEQPD 
		CN9->CN9_XXEQPH := cXXEQPH 
	
		msUnlock()
		
		// Log
		DbSelectArea("SZH")
		RecLock("SZH",.T.)
		SZH->ZH_FILIAL := xFilial("SZH")
		SZH->ZH_CONTRAT:= CN9->CN9_NUMERO
		SZH->ZH_REVISA := CN9->CN9_REVISA
		SZH->ZH_DATA   := DATE()
		SZH->ZH_HORA   := TIME()
		SZH->ZH_USUARIO:= SUBSTR(cUsuario,7,15)

		SZH->ZH_XXUNID := CN9->CN9_XXUNID
		SZH->ZH_XXUNIH := CN9->CN9_XXUNIH
		SZH->ZH_XXEPID := CN9->CN9_XXEPID
		SZH->ZH_XXEPIH := CN9->CN9_XXEPIH
		SZH->ZH_XXMATD := CN9->CN9_XXMATD
		SZH->ZH_XXMATH := CN9->CN9_XXMATH
		SZH->ZH_XXEQPD := CN9->CN9_XXEQPD
		SZH->ZH_XXEQPH := CN9->CN9_XXEQPH
		
		msUnlock()
	ENDIF
EndIf
dbSelectArea(_sAlias)

SZH->(RestArea( aAreaSZH ))
RestArea( aAreaAtu )

Return lOk


Static Function  validaSZH()
LOCAL lOk:=.T.
LOCAL cMsg := ""
Local cCrLf   := Chr(13) + Chr(10)

    IF SUBSTR(cXXUNI,1,1) == "S"
    	IF dXXUNID == CTOD("")
   			cMsg += "Informar Data Prox. Troca Uniforme!"+cCrLf
			lOk:= .F.
	    	IF ALLTRIM(cXXUNIH) == ""
				cMsg += "Obs Andamento Uniforme obrigatório!"+cCrLf
				lOk:= .F.
    		ENDIF
        ELSEIF dXXUNID <> CN9->CN9_XXUNID .AND. ALLTRIM(cXXUNIH) == ""
   			cMsg += "Data Prox. Troca Uniforme Alterada. Informar Histórico/Motivo no campo Obs Andamento Uniforme !"+cCrLf
			lOk:= .F.
        ELSEIF dXXUNID < CN9->CN9_XXUNID
   			cMsg += "Data Prox. Troca Uniforme Informada não pode ser menor que a ultima data informada !"+cCrLf
			lOk:= .F.
        ELSEIF dXXUNID < CN9->CN9_DTINIC   
   			cMsg += "Data Prox. Troca Uniforme Informada não pode ser menor que inicio do contrato !"+cCrLf
			lOk:= .F.
        ELSEIF DateDiffMonth( dXXUNID , DATE() ) > 12  
   			cMsg += "Data Prox. Troca Uniforme Informada não pode ser maior que a 12 meses !"+cCrLf
			lOk:= .F.
        ELSE
	    	IF ALLTRIM(cXXUNIH) == ""
				cMsg += "Obs Andamento Uniforme obrigatório!"+cCrLf
				lOk:= .F.
    		ENDIF
    	ENDIF
    ELSEIF SUBSTR(cXXUNI,1,1) <>'N'
   	    cMsg += "Controla Uniformes obrigatório!"+cCrLf
		lOk:= .F.
    ENDIF
    IF SUBSTR(cXXEPI,1,1) =="S"
    	IF dXXEPID == CTOD("")
			cMsg += "Informar Data Prox. Troca E.P.I.!"+cCrLf
			lOk:= .F.
    		IF ALLTRIM(cXXEPIH) == ""
				cMsg += "Obs Andamento E.P.I. obrigatório!"+cCrLf
				lOk:= .F.
    		ENDIF
        ELSEIF dXXEPID <> CN9->CN9_XXEPID .AND. ALLTRIM(cXXEPIH) == ""
   			cMsg += "Data Prox. Troca E.P.I. Alterada. Informar Histórico/Motivo no campo Obs Andamento E.P.I. !"+cCrLf
			lOk:= .F.
        ELSEIF dXXEPID < CN9->CN9_XXEPID
   			cMsg += "Data Prox. Troca E.P.I. Informada não pode ser menor que a ultima data informada !"+cCrLf
			lOk:= .F.
        ELSEIF dXXEPID < CN9->CN9_DTINIC   
   			cMsg += "Data Prox. Troca E.P.I. Informada não pode ser menor que inicio do contrato !"+cCrLf
			lOk:= .F.
        ELSEIF DateDiffMonth( dXXEPID , DATE() ) > 24  
   			cMsg += "Data Prox. Troca E.P.I. Informada não pode ser maior que a 24 meses !"+cCrLf
			lOk:= .F.
        ELSE
    		IF ALLTRIM(cXXEPIH) == ""
				cMsg += "Obs Andamento E.P.I. obrigatório!"+cCrLf
				lOk:= .F.
    		ENDIF
		ENDIF
    ELSEIF SUBSTR(cXXEPI,1,1) <>'N'
   	    cMsg += "Controla E.P.I. obrigatório!"+cCrLf
		lOk:= .F.
    ENDIF
    IF SUBSTR(cXXMAT,1,1) == "S"
    	IF dXXMATD == CTOD("")
			cMsg += "Informar Data Prox. Troca Materiais!"+cCrLf
			lOk:= .F.
	    	IF ALLTRIM(cXXMATH) == ""
				cMsg += "Obs Andamento Materiais obrigatório!"+cCrLf
				lOk:= .F.
    		ENDIF
        ELSEIF dXXMATD <> CN9->CN9_XXMATD .AND. ALLTRIM(cXXMATH) == ""
   			cMsg += "Data Prox. Troca Materiais Alterada. Informar Histórico/Motivo no campo Obs Andamento Materiais !"+cCrLf
			lOk:= .F.
        ELSEIF dXXMATD < CN9->CN9_XXMATD
   			cMsg += "Data Prox. Troca Materiais Informada não pode ser menor que a ultima data informada !"+cCrLf
			lOk:= .F.
        ELSEIF dXXMATD < CN9->CN9_DTINIC   
   			cMsg += "Data Prox. Troca Materiais Informada não pode ser menor que inicio do contrato !"+cCrLf
			lOk:= .F.
        ELSEIF DateDiffMonth( dXXMATD , DATE() ) > 24  
   			cMsg += "Data Prox. Troca Materiais Informada não pode ser maior que a 24 meses !"+cCrLf
			lOk:= .F.
        ELSE
	    	IF ALLTRIM(cXXMATH) == ""
				cMsg += "Obs Andamento Materiais obrigatório!"+cCrLf
				lOk:= .F.
    		ENDIF
		ENDIF
    	
    ELSEIF SUBSTR(cXXMAT,1,1) <>'N'
   	    cMsg += "Controla Materiais obrigatório!"+cCrLf
		lOk:= .F.
    ENDIF

    IF SUBSTR(cXXEQP,1,1) == "S"
    	IF dXXEQPD == CTOD("")
			cMsg += "Informar Data Prox. Troca Equipamentos!"+cCrLf
			lOk:= .F.
	    	IF ALLTRIM(cXXEQPH) == "" 
				cMsg += "Obs Andamento Equipamentos obrigatório!"+cCrLf
				lOk:= .F.
    		ENDIF
        ELSEIF dXXEQPD <> CN9->CN9_XXEQPD .AND. ALLTRIM(cXXEQPH) == ""
   			cMsg += "Data Prox. Troca Equipamentos Alterada. Informar Histórico/Motivo no campo Obs Andamento Equipamentos !"+cCrLf
			lOk:= .F.
        ELSEIF dXXEQPD < CN9->CN9_XXEQPD
   			cMsg += "Data Prox. Troca Equipamentos Informada não pode ser menor que a ultima data informada !"+cCrLf
			lOk:= .F.
        ELSEIF dXXEQPD < CN9->CN9_DTINIC   
   			cMsg += "Data Prox. Troca Equipamentos Informada não pode ser menor que inicio do contrato !"+cCrLf
			lOk:= .F.
        ELSEIF DateDiffMonth( dXXEQPD , DATE() ) > 24  
   			cMsg += "Data Prox. Troca Equipamentos Informada não pode ser maior que a 24 meses !"+cCrLf
			lOk:= .F.
        ELSE
	    	IF ALLTRIM(cXXEQPH) == "" 
				cMsg += "Obs Andamento Equipamentos obrigatório!"+cCrLf
				lOk:= .F.
    		ENDIF
		ENDIF
    	
    ELSEIF SUBSTR(cXXEQP,1,1) <>'N'
   	    cMsg += "Controla Equipamentos obrigatório!"+cCrLf
		lOk:= .F.
    ENDIF
    IF !lOk
    	MSGSTOP(cMsg)
    ENDIF
Return lOk



User Function BKGCTA14()
Local cContrato := TRIM(CN9->CN9_NUMERO)
Local cAlias    := "SZH"
Local aCores    := {}
Local cFiltra   := "ZH_FILIAL == '"+xFilial('SZH')+"' .And. TRIM(ZH_CONTRAT) = '"+cContrato+"'"

Private cCadastro := "Histórico - Insumos Operacionais"
Private aRotina   := {}
Private aIndexSz  := {}
Private bFiltraBrw:= { || FilBrowse(cAlias,@aIndexSz,@cFiltra) }
                   

aRotina := {{"Pesquisar" ,"AxPesqui"	,0, 1},;
			{"Visualizar","AxVisual"	,0, 2}}
/*
-- CORES DISPONIVEIS PARA LEGENDA --
BR_AMARELO
BR_AZUL
BR_BRANCO
BR_CINZA
BR_LARANJA
BR_MARRON
BR_VERDE
BR_VERMELHO
BR_PINK
BR_PRETO
*/
                                                                                                                   
AADD(aCores,{"(ZH_XXUNID >=  DATE() .OR. ZH_XXUNID ==  CTOD(' ')) .AND. (ZH_XXEPID >=  DATE() .OR. ZH_XXEPID ==  CTOD(' ')) .AND. (ZH_XXMATD >=  DATE() .OR. ZH_XXMATD ==  CTOD(' ')) .AND. (ZH_XXEQPD >=  DATE() .OR. ZH_XXEQPD ==  CTOD(' '))" ,"BR_VERDE" })
AADD(aCores,{"(ZH_XXUNID <  DATE() .AND. ZH_XXUNID <>  CTOD(' ')) .OR. (ZH_XXEPID <  DATE() .AND. ZH_XXEPID <>  CTOD(' ')) .OR. (ZH_XXMATD <  DATE() .AND. ZH_XXMATD <>  CTOD(' ')) .OR. (ZH_XXEQPD <  DATE() .AND. ZH_XXEQPD <>  CTOD(' '))" ,"BR_VERMELHO" })

dbSelectArea(cAlias)
dbSetOrder(1)
//+------------------------------------------------------------
//| Cria o filtro na MBrowse utilizando a função FilBrowse
//+------------------------------------------------------------
Eval(bFiltraBrw)

dbSelectArea(cAlias)
dbGoTop()
If EOF()
   MsgInfo('Não há historico de insumos operacionais')
Else
   mBrowse(6,1,22,75,cAlias,,,,,,aCores)
EndIf
//+------------------------------------------------
//| Deleta o filtro utilizado na função FilBrowse
//+------------------------------------------------
EndFilBrw(cAlias,aIndexSz)
Return Nil


//Atestado de Capacidade Técnica
// Alteração de dados referentes ao Atestado de Capacidade Técnica
User Function BKGCTA15()
Local _sAlias	:= Alias()
Local oDlg01,aButtons := {},lOk := .F.
Local nSnd  := 0,nTLin := 20

Local aTpAtest := {"1º aviso +180 dias de contrato",;
                   "2º aviso +365 dias de contrato",;
                   "3- Renovação do contrato",;
                   "4- Encerramento do contrato"}

Local aStatus := {"1-Solicitado",;
                  "2-Retirado ou Entregue",;
                  "3-Solicitar a partir de",;
                  ""}

Local aAreaAtu	:= GetArea()
Local dDatAv  := CN9->CN9_XXDAAT
Local dSTAT   := CN9->CN9_XXDSTA
Local dDSAT   := CN9->CN9_XXDSAT
Local cTPAT   := ""                   
Local cSTAT   := ""

IF CN9->CN9_SITUAC = "10"
	MsgStop("Posicione na revisão atual do contrato", "Atenção")
	Return .F.
ENDIF


IF EMPTY(CN9->CN9_XXTPAT)
	MsgStop("Contrato não possui aviso de Atestado de Capacidade Técnica", "Atenção")
   	Return .F.
ENDIF

IF VAL(CN9->CN9_XXTPAT) > 0                   
	cTPAT   := aTpAtest[VAL(CN9->CN9_XXTPAT)]
ENDIF

IF VAL(CN9->CN9_XXSTAT) > 0                   
	cSTAT   := aStatus[VAL(CN9->CN9_XXSTAT)]
ENDIF

////////////
//MONTA TELA Atestado Capacidade Técnica
////////////
  
Define MsDialog oDlg01 Title "Informações - Atestado Capacidade Técnica" From 000,000 To 230,600 Of oDlg01 Pixel

oPanelLeft:= tPanel():New(0,0,"",oDlg01,,,,,,000,000)
oPanelLeft:Align := CONTROL_ALIGN_ALLCLIENT

nSnd := 5

@ nSnd,010 Say "Data do Aviso:" Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet dDatAv Picture "@E"  When .F. Size 040,008 Pixel Of oPanelLeft 
nSnd += nTLin

@ nSnd,010 Say "Tipo de Aviso:" Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 COMBOBOX cTPAT  ITEMS aTpAtest When .F. SIZE 100,50 OF oPanelLeft PIXEL
nSnd += nTLin

@ nSnd,010 Say "Status:"        Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 COMBOBOX cSTAT  ITEMS aStatus SIZE 100,50 OF oPanelLeft PIXEL
@ nSnd,220 MsGet dDSAT Picture "@E"  When SUBSTR(cSTAT,1,1) == "3" Size 040,008 Pixel Of oPanelLeft 
nSnd += nTLin

@ nSnd,010 Say "Data Status:" Size 080,008 Pixel Of oPanelLeft
@ nSnd,100 MsGet dSTAT Picture "@E"  When .T. Size 040,008 Pixel Of oPanelLeft 
nSnd += nTLin

ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)
If ( lOk )
	lOk:=.F.
	IF cSTAT == CN9->CN9_XXSTAT .AND. dSTAT == CN9->CN9_XXDSTA .AND. CN9->CN9_XXDSAT == dDSAT
		MsgInfo("Não houve alterações", "Atenção")
	ELSE
		RecLock("CN9",.F.)
		CN9->CN9_XXSTAT := cSTAT
		CN9->CN9_XXDSTA := dSTAT
		CN9->CN9_XXDSAT := dDSAT 
		msUnlock()
	
		// Log
		DbSelectArea("SZ4")
		RecLock("SZ4",.T.)
		SZ4->Z4_FILIAL 	:= xFilial("SZ4")
		SZ4->Z4_CONTRAT	:= CN9->CN9_NUMERO
		SZ4->Z4_DATA    := DATE()
		SZ4->Z4_HORA    := TIME()
		SZ4->Z4_USER	:= SUBSTR(cUsuario,7,15)
		
		SZ4->Z4_DAAT 	:= CN9->CN9_XXDAAT
		SZ4->Z4_TPAT 	:= CN9->CN9_XXTPAT   
		SZ4->Z4_STAT 	:= cSTAT
		SZ4->Z4_DSTA 	:= dSTAT
		SZ4->Z4_DENC	:= CN9->CN9_XXDENC
		SZ4->Z4_XXDSAT	:= CN9->CN9_XXDSAT
	
		msUnlock()
	ENDIF
EndIf
dbSelectArea(_sAlias)

RestArea( aAreaAtu )

Return lOk




User Function BKGCTA16()

Local cContrato := TRIM(CN9->CN9_NUMERO)
Local cAlias    := "SZ4"
Local aCores    := {}
Local cFiltra   := "Z4_FILIAL == '"+xFilial('SZ4')+"' .And. TRIM(Z4_CONTRAT) == '"+cContrato+"'"

Private cCadastro := "Histórico - Atestado Capacidade Técnica"
Private aRotina   := {}
Private aIndexSz  := {}
Private bFiltraBrw:= { || FilBrowse(cAlias,@aIndexSz,@cFiltra) }
                   

aRotina := {{"Pesquisar" ,"AxPesqui"	,0, 1},;
			{"Visualizar","AxVisual"	,0, 2}}
/*
-- CORES DISPONIVEIS PARA LEGENDA --
BR_AMARELO
BR_AZUL
BR_BRANCO
BR_CINZA
BR_LARANJA
BR_MARRON
BR_VERDE
BR_VERMELHO
BR_PINK
BR_PRETO
*/

 

AADD(aCores,{"Z4_DSTA >= Z4_DAAT " ,"BR_VERDE" })
AADD(aCores,{"Z4_DSTA < Z4_DAAT ","BR_VERMELHO" })

dbSelectArea(cAlias)
dbSetOrder(1)
//+------------------------------------------------------------
//| Cria o filtro na MBrowse utilizando a função FilBrowse
//+------------------------------------------------------------
Eval(bFiltraBrw)

dbSelectArea(cAlias)
dbGoTop()
If EOF()
   MsgInfo('Não há historico de Atestado Capacidade Técnica')
Else
   mBrowse(6,1,22,75,cAlias,,,,,,aCores)
EndIf
//+------------------------------------------------
//| Deleta o filtro utilizado na função FilBrowse
//+------------------------------------------------
EndFilBrw(cAlias,aIndexSz)
Return Nil


// Vencimento de documento de Segurança do Trabalho
// Alteração de dados referentes ao documento de Segurança do Trabalho
User Function BKGCTA18()
Local _sAlias	:= Alias()
Local oDlg01,aButtons := {},lOk := .F.
Local nSnd  := 0,nTLin := 20
Local aAreaAtu	:= GetArea()
Local aPVDST := {"1-Sim","2-Não"}
Local cPVDST := "1-Sim"                   
Local dDVST  := CN9->CN9_XXDVST
Local cSVST  := CN9->CN9_XXSVST
Local cHVST  := CN9->CN9_XXHVST


IF CN9->CN9_SITUAC = "10"
	MsgStop("Posicione na revisão atual do contrato", "Atenção")
	Return .F.
ENDIF

IF VAL(CN9->CN9_XXPVST) > 0                   
	cPVDST := aPVDST[VAL(CN9->CN9_XXPVST)]
ENDIF


////////////
//MONTA TELA Documento de Segurança do Trabalho"
////////////
  
Define MsDialog oDlg01 Title "Alteração de dados - Documento de Segurança do Trabalho" From 000,000 To 230,600 Of oDlg01 Pixel

oPanelLeft:= tPanel():New(0,0,"",oDlg01,,,,,,000,000)
oPanelLeft:Align := CONTROL_ALIGN_ALLCLIENT

nSnd := 5

@ nSnd,010 Say "Controla Documento de Segurança do Trabalho:" Size 120,008 Pixel Of oPanelLeft
@ nSnd,150 COMBOBOX cPVDST  ITEMS aPVDST SIZE 100,50 OF oPanelLeft PIXEL
nSnd += nTLin

@ nSnd,010 Say "Documento de Segurança do Trabalho:" Size 120,008 Pixel Of oPanelLeft
@ nSnd,150 MsGet cHVST  When SUBSTR(cPVDST,1,1) = "1" SIZE 100,008 OF oPanelLeft PIXEL
nSnd += nTLin

@ nSnd,010 Say "Data do Vencimento:" Size 120,008 Pixel Of oPanelLeft
@ nSnd,150 MsGet dDVST Picture "@E"  When SUBSTR(cPVDST,1,1) = "1" Size 040,008 Pixel Of oPanelLeft 
nSnd += nTLin

@ nSnd,010 Say "Ultimo Aviso:"  Size 120,008 Pixel Of oPanelLeft
@ nSnd,150 MsGet cSVST When .F. SIZE 120,008 OF oPanelLeft PIXEL
nSnd += nTLin


ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)
If ( lOk )
	lOk:=.F.
	IF CN9->CN9_XXPVST == SUBSTR(cPVDST,1,1) .AND. CN9->CN9_XXDVST == dDVST .AND. CN9->CN9_XXHVST == cHVST 
		MsgInfo("Não houve alterações", "Atenção")
	ELSE
		RecLock("CN9",.F.)
		CN9->CN9_XXPVST := cPVDST                 
		CN9->CN9_XXDVST := dDVST
		//CN9->CN9_XXSVST := cSVST
		CN9->CN9_XXHVST := cHVST
		msUnlock()
	
		// Log
		DbSelectArea("SZN")
		RecLock("SZN",.T.)
		SZN->ZN_FILIAL 	:= xFilial("SZN")
		SZN->ZN_CONTRAT	:= CN9->CN9_NUMERO
		SZN->ZN_DATA    := DATE()
		SZN->ZN_HORA    := TIME()
		SZN->ZN_USUARIO := SUBSTR(cUsuario,7,15)
		SZN->ZN_XXDVST  := CN9->CN9_XXDVST
		SZN->ZN_XXHVST 	:= CN9->CN9_XXHVST   
	
		msUnlock()
	ENDIF
EndIf
dbSelectArea(_sAlias)

RestArea( aAreaAtu )

Return lOk




User Function BKGCTA19()

Local cContrato := TRIM(CN9->CN9_NUMERO)
Local cAlias    := "SZN"
Local aCores    := {}
Local cFiltra   := "ZN_FILIAL == '"+xFilial('SZN')+"' .And. TRIM(ZN_CONTRAT) == '"+cContrato+"'"

Private cCadastro := "Histórico - Documento de Segurança do Trabalho""
Private aRotina   := {}
Private aIndexSz  := {}
Private bFiltraBrw:= { || FilBrowse(cAlias,@aIndexSz,@cFiltra) }
                   

aRotina := {{"Pesquisar" ,"AxPesqui"	,0, 1},;
			{"Visualizar","AxVisual"	,0, 2}}
/*
-- CORES DISPONIVEIS PARA LEGENDA --
BR_AMARELO
BR_AZUL
BR_BRANCO
BR_CINZA
BR_LARANJA
BR_MARRON
BR_VERDE
BR_VERMELHO
BR_PINK
BR_PRETO
*/

AADD(aCores,{"ZN_DATA <= ZN_XXDVST","BR_VERDE" })
AADD(aCores,{"ZN_DATA >= ZN_XXDVST","BR_VERMELHO" })

dbSelectArea(cAlias)
dbSetOrder(1)
//+------------------------------------------------------------
//| Cria o filtro na MBrowse utilizando a função FilBrowse
//+------------------------------------------------------------
Eval(bFiltraBrw)

dbSelectArea(cAlias)
dbGoTop()
If EOF()
   MsgInfo('Não há historico de Atestado Capacidade Técnica')
Else
   mBrowse(6,1,22,75,cAlias,,,,,,aCores)
EndIf
//+------------------------------------------------
//| Deleta o filtro utilizado na função FilBrowse
//+------------------------------------------------
EndFilBrw(cAlias,aIndexSz)
Return Nil    


/*/{Protheus.doc} BKGCTA21
BK - Alteração de modo de acesso do contrato posicionado (Usuários, Grupos e Filiais)
@Return
@author Marcos Bispo Abrahão
@since 14/05/20
@version P12
/*/

User Function BKGCTA21()

Local aGrupos 	:= {"000000","000003","000004","000008"} // Adm, User Gestão, Master Gestão, M Repac
Local nI 		:= 0
Local aAreaAtu	:= GetArea()
Local aAreaCNN	:= CNN->( GetArea() )
Local lGrupos	:= .F.

If CN9->CN9_VLDCTR <> "1"
	If MsgYesNo("Deseja alterar o modo de acesso por filial desse contrato?")
		dbSelectArea("CN9")
		RecLock("CN9",.F.)
	  	CN9->CN9_VLDCTR := "1"
	  	MsUnlock()
		lGrupos := .T.
	EndIf
Else
	lGrupos := MsgYesNo("Deseja liberar os grupos de gestão para esse contrato?")
Endif

If lGrupos
	dbSelectArea("CNN")
	dbSetOrder(2)
	For nI := 1 To Len(aGrupos)
		If !dbSeek(xFilial("CNN")+aGrupos[nI]+CN9->CN9_NUMERO+"001",.F.) //Fil+GRPCOD+CONTRA+TRACOD
			RecLock("CNN",.T.)
			CNN->CNN_FILIAL := xFilial("CNN")
			CNN->CNN_GRPCOD := aGrupos[nI]
			CNN->CNN_CONTRA := CN9->CN9_NUMERO
			CNN->CNN_TRACOD := "001"
			MsUnlock()
		EndIf
	Next
EndIf

CNN->(RestArea( aAreaCNN ))
RestArea( aAreaAtu )

Return Nil

