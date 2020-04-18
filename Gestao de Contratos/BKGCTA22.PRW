#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³BKGCTA22  ºAutor  ³ Marcos B. Abrahão  º Data ³ 13/06/2017  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Ocorrências e Planos de ação - Contratos                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³BK                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
                       
User Function BKGCTA22(lVisual)

Local   oDlg,;
        oReport,;
        bOk        := {|| oDlg:End()},;
        bCancel    := {|| oDlg:End()},;
        aTb_Campos := {},;
        aCoresZP   := {},;
        aCoresZQ   := {}
Local 	aButtons   := {{"",;
                        {|| Processa({|| oReport := ReportDef(),oReport:PrintDialog()},'Imprimindo Dados...')},;
                         "Imprimir",;
                         "Imprimir"}}
                         
Local	oFont      := TFont():New('Courier new',,-14,.T.,.T.)

Default lVisual    := .F.

Private oTmpTb1,oTmpTb2


Private cContrato  := CN9->CN9_NUMERO
Private cRevisa    := CN9->CN9_REVISA
Private cTitulo    := "Ocorrências do contrato "+TRIM(cContrato)+": "+CN9->CN9_NOMCLI
Private cCadastro  := cTitulo
                         
Private oMarkSZP,;
        oMarqSZQ,;
        cMarca     := GetMark(),;
        lInverte   := .F.

Private lMarca    := .T.,;
        lRetrato  := .T.,;
        aColPrint := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.}//variáveis de filtro

// Acerto do camo ZP_NQUEM - 10/10/2018
/*
dbSelectArea("SZP")
dbGoTop()
Do While !eof()
	PswOrder(1)
	PswSeek(SZP->ZP_QUEM) 
	aUser  := PswRet(1)
	cNomeQuem := Alltrim(aUser[1][2])
	If Empty(cNomeQuem)
		cNomeQuem := SZP->ZP_QUEM
	EndIf
	RecLock("SZP",.F.)
    SZP->ZP_NQUEM := cNomeQuem
    SZP->(MsUnlock())
	dbSkip()
EndDo
*/


Processa({|| CriaWork(),;
             PreencheWk()},;
             'Aguarde...','Preparando Ambiente...')

WKSZP->(dbGoTop())
WKSZQ->(dbGoTop())

//oMainWnd:ReadClientCoords()

Private aSize   := MsAdvSize(,.F.,400)
Private aObjects:= { { 450, 450, .T., .T. },{ 30, 30, .T., .T. },{ 30, 30, .T., .T. },{ 450, 450, .T., .T. },{ 30, 30, .T., .T. } }
Private aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
Private aPosObj := MsObjSize( aInfo, aObjects, .T. )

aAdd(aCoresZP,{"WKSZP->FINALIZ == 'S'","BR_VERMELHO"})
aAdd(aCoresZP,{"WKSZP->FINALIZ <> 'S'","BR_VERDE"})

aAdd(aCoresZQ,{"WKSZQ->FINALIZ == 'S'","BR_VERMELHO"})
aAdd(aCoresZQ,{"WKSZQ->FINALIZ <> 'S'","BR_VERDE"})

Define MsDialog oDlg Title cTitulo From aSize[7], 0 To aSize[6],aSize[5] Of oMainWnd Pixel

   aPos := {aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]}
   aTb_Campos     := CriaTbCpos("SZP")
   oMarkSZP       := MsSelect():New("WKSZP","WKMARCA",  ,aTb_Campos,.F.      ,@cMarca,aPos,,,,,aCoresZP)
   
   oMarkSZP:bAval := {|| MarcaCpo(.F.,"WKSZP")}
   oMarkSZP:oBrowse:lCanAllMark := .T.
   oMarkSZP:oBrowse:lHasMark    := .F.
   //oMarkSZP:oBrowse:bAllMark := {|| MarcaCpo(.T.,"WKSZP")}
   oMarkSZP:oBrowse:bChange  := {||oMarqSZQ:oBrowse:SetFilter("SEQ",WKSZP->SEQ,WKSZP->SEQ),;
                                   oMarqSZQ:oBrowse:Refresh()}
   // 
   TButton():New(aPosObj[2,1],aPosObj[2,2],'Visualizar ocorrência',oDlg,{|| U_VISSZP() },80,10,,,,.T.)  
   If !lVisual
	   TButton():New(aPosObj[2,1],aPosObj[2,2]+85,'Incluir ocorrência',oDlg,{|| U_INCSZP() },80,10,,,,.T.)  
	   TButton():New(aPosObj[2,1],aPosObj[2,2]+85+85,'Alterar ocorrência',oDlg,{|| U_ALTSZP() },80,10,,,,.T.)  
	   TButton():New(aPosObj[2,1],aPosObj[2,2]+85+85+85,'Excluir ocorrência',oDlg,{|| U_EXCSZP() },80,10,,,,.T.)  
	   TButton():New(aPosObj[2,1],aPosObj[2,2]+85+85+85+85,'Finalizar ocorrências',oDlg,{|| U_FINSZP() },80,10,,,,.T.)  
   EndIf	   
   
   nMeio := (aPosObj[4,4] - aPosObj[4,2]) / 2 - 50
   oSay := tSay():New(aPosObj[3,1]+2,nMeio,{||'Planos de Ação'},oDlg,,oFont,,,,.T.,CLR_BLUE,CLR_WHITE,200,20)

   aPos := {aPosObj[4,1],aPosObj[4,2],aPosObj[4,3],aPosObj[4,4]}
   aTb_Campos     := CriaTbCpos("SZQ")
   oMarqSZQ       := MsSelect():New("WKSZQ","WKMARCA",,aTb_Campos,.F.,@cMarca,aPos,,,,,aCoresZQ)
   oMarqSZQ:bAval := {|| MarcaCpo(.F.,"WKSZQ")}
   oMarqSZQ:oBrowse:lCanAllMark := .T.
   oMarqSZQ:oBrowse:lHasMark    := .T.
   oMarqSZQ:oBrowse:bAllMark := {|| MarcaCpo(.T.,"WKSZQ")}
   oMarqSZQ:oBrowse:SetFilter("SEQ",WKSZP->SEQ,WKSZP->SEQ)

   TButton():New(aPosObj[5,1],aPosObj[5,2],'Visualizar Plano de Ação',oDlg,{|| U_VISSZQ() },80,10,,,,.T.)  
   If !lVisual
	   TButton():New(aPosObj[5,1],aPosObj[5,2]+85,'Incluir Plano de Ação',oDlg,{|| U_INCSZQ() },80,10,,,,.T.)  
	   TButton():New(aPosObj[5,1],aPosObj[5,2]+85+85,'Alterar Plano de Ação',oDlg,{|| U_ALTSZQ() },80,10,,,,.T.)  
	   TButton():New(aPosObj[5,1],aPosObj[5,2]+85+85+85,'Excluir Plano de Ação',oDlg,{|| U_EXCSZQ() },80,10,,,,.T.)  
   EndIf

Activate MsDialog oDlg On Init ( EnchoiceBar(oDlg,bOk,bCancel,,aButtons), ,, )

CloseWork()

Return


*--------------------------*
Static Function CloseWork()
*--------------------------*
oTmpTb1:Delete()
oTmpTb2:Delete()

///WKSZP->(dbCloseArea())
///WKSZQ->(dbCloseArea())
Return Nil


/*
Funcao      : CriaWork
Objetivos   : Cria Works para criação dos msselects
*/
*--------------------------*
Static Function CriaWork()
*--------------------------*
Local aSemSx3 := {}

//
//Cria work das Ocorrencias
aAdd(aSemSx3,{"WKMARCA","C",02                     ,0})
aAdd(aSemSx3,{"NUMERO" ,"C",TamSX3("ZP_NUMERO")[1],0})
aAdd(aSemSx3,{"CONTRAT","C",TamSX3("ZP_CONTRAT")[1],0})
aAdd(aSemSx3,{"SEQ"    ,"C",TamSX3("ZP_SEQ")[1]    ,0})
aAdd(aSemSx3,{"DATAZP" ,"D",8                      ,0})
aAdd(aSemSx3,{"OCORR"  ,"C",TamSX3("ZP_OCORR")[1]  ,0})
aAdd(aSemSx3,{"FINALIZ","C",TamSX3("ZP_FINALIZ")[1],0})
aAdd(aSemSx3,{"EFICIEN","C",TamSX3("ZP_EFICIEN")[1],0})
//
///cFile := E_CriaTrab(,aSemSX3,"WKSZP")
///IndRegua("WKSZP",cFile+OrdBagExt(),"SEQ")
///Set Index To (cFile+OrdBagExt())

oTmpTb1 := FWTemporaryTable():New( "WKSZP")
oTmpTb1:SetFields( aSemSX3 )
oTmpTb1:AddIndex("indice1", {"SEQ"} )
oTmpTb1:Create()

//Cria work dos Planos de Ação
aSemSx3 := {}
aAdd(aSemSx3,{"WKMARCA","C",02                     ,0})
aAdd(aSemSx3,{"CONTRAT","C",TamSX3("ZQ_CONTRAT")[1],0})
aAdd(aSemSx3,{"SEQ"    ,"C",TamSX3("ZQ_SEQ")[1]    ,0})
aAdd(aSemSx3,{"ITEM"   ,"C",TamSX3("ZQ_ITEM")[1]   ,0})
aAdd(aSemSx3,{"DATAZQ" ,"D",8                      ,0})
aAdd(aSemSx3,{"OQUE"   ,"C",TamSX3("ZQ_OQUE")[1]   ,0})
aAdd(aSemSx3,{"FINALIZ","C",TamSX3("ZQ_FINALIZ")[1],0})

///cFile := E_CriaTrab(,aSemSX3,"WKSZQ")
///IndRegua("WKSZQ",cFile+OrdBagExt(),"SEQ+ITEM")
///Set Index To (cFile+OrdBagExt())

oTmpTb2 := FWTemporaryTable():New( "WKSZQ")
oTmpTb2:SetFields( aSemSX3 )
oTmpTb2:AddIndex("indice2", {"SEQ","ITEM"} )
oTmpTb2:Create()

Return

/*
Funcao      : CriaTbCpos
Objetivos   : Cria tbCampos para os msSelects
*/
*--------------------------*
Static Function CriaTbCpos(cTipo)
*--------------------------*
Local aTbCpos := {}
//
aAdd(aTbCpos,{"WKMARCA",,""         ,""} )
aAdd(aTbCpos,{"CONTRAT",,"Contrato" ,""} )
aAdd(aTbCpos,{"SEQ"    ,,"Sequência",""} )
//
If cTipo == "SZP"
   //
	aAdd(aTbCpos,{"NUMERO" ,,"Número" ,""} )
	aAdd(aTbCpos,{"OCORR"  ,,"Ocorência",""} )
	aAdd(aTbCpos,{"DATAZP" ,,"Data"     ,""} )
   //
ElseIf cTipo == "SZQ"                  
   //
	aAdd(aTbCpos,{"ITEM"   ,,"Item"  ,""} )
	aAdd(aTbCpos,{"DATAZQ" ,,"Data"     ,""} )
	aAdd(aTbCpos,{"OQUE"   ,,"O que?",""} )
   //
EndIf

aAdd(aTbCpos,{"FINALIZ",,"Ok",""} )

Return aTbCpos

/*
Funcao      : PreencheWk
Objetivos   : Preenche works com dados das tableas SZP e SZQ
*/
*--------------------------*
Static Function PreencheWk()
*--------------------------*

dbSelectArea("SZP")
dbSetOrder(1)
dbGoTop()
ProcRegua(LastRec())
dbSeek(xFilial("SZP")+cContrato,.T.)
Do While !EOF() .AND. SZP->ZP_FILIAL == xFilial("SZP") .AND. SZP->ZP_CONTRAT == cContrato
	dbSelectArea("WKSZP")
	RecLock("WKSZP",.T.)
	WKSZP->NUMERO  := SZP->ZP_NUMERO
	WKSZP->CONTRAT := cContrato
	WKSZP->SEQ     := SZP->ZP_SEQ
	WKSZP->DATAZP  := SZP->ZP_DATA
	WKSZP->OCORR   := SZP->ZP_OCORR
	WKSZP->FINALIZ := SZP->ZP_FINALIZ
	WKSZP->EFICIEN := SZP->ZP_EFICIEN
    WKSZP->(MsUnlock())
	dbSelectArea("SZP")
	dbSkip()
EndDo

dbSelectArea("SZQ")
dbSetOrder(1)
dbGoTop()
dbSeek(xFilial("SZQ")+cContrato,.T.)
Do While !EOF() .AND. SZQ->ZQ_FILIAL == xFilial("SZQ") .AND. SZQ->ZQ_CONTRAT == cContrato
	dbSelectArea("WKSZQ")
	RecLock("WKSZQ",.T.)
	WKSZQ->CONTRAT := cContrato
	WKSZQ->SEQ     := SZQ->ZQ_SEQ
	WKSZQ->ITEM    := SZQ->ZQ_ITEM
	WKSZQ->DATAZQ  := SZQ->ZQ_DATA
	WKSZQ->OQUE    := SZQ->ZQ_OQUE
	WKSZQ->FINALIZ := SZQ->ZQ_FINALIZ
    WKSZQ->(MsUnlock())
	dbSelectArea("SZQ")
	dbSkip()
EndDo


Return


                            

/*
Funcao      : MarcaCpo
Objetivos   : Marca/Desmarca Campos
*/
*------------------------------*
Static Function MarcaCpo(lTodos, cAlias)
*------------------------------*
Local nRegSZP   := WKSZP->(RecNo())
//Local nRegSZQ   := WKSZQ->(RecNo())
//Local cMark     := If(Empty((cAlias)->WKMARCA),cMarca,"")
//Local cChave    := ""
Local lOk       := .F.
//
If lTodos
Else
	If (cAlias)->FINALIZ <> "S" .AND. EMPTY((cAlias)->WKMARCA)
	   If cAlias == "WKSZP"
	      WKSZQ->(dbSeek(WKSZP->SEQ))
	      While WKSZQ->SEQ == WKSZP->SEQ .AND. WKSZQ->(!Eof())
	      	 lOk := .T.
	      	 If WKSZQ->FINALIZ <> "S"
	      	 	lOk := .F.
	      	 	Exit
	      	 EndIf
	         WKSZQ->(dbSkip())
	      EndDo
	      If lOk
		  	RecLock(cAlias,.F.)
		   	(cAlias)->WKMARCA := cMarca
		   	(cAlias)->(MsUnlock())
		   EndIf
	   ElseIf cAlias == "WKSZQ"     
		If WKSZQ->FINALIZ <> "S"
		     RecLock("WKSZQ",.F.)
		     WKSZQ->WKMARCA := cMarca
		     WKSZQ->(MsUnlock())
		EndIf
	   EndIf
	EndIf
EndIf

WKSZP->(dbGoTo(nRegSZP))
RefreshBrw()

Return


/*
Funcao      : ReportDef
Objetivos   : Define estrutura de impressão
*/
*--------------------------*
Static Function ReportDef()
*--------------------------*
//
oReport := TReport():New("RELACESSO","Relatório de Acesso de Usuários","",;
                         {|oReport| ReportPrint(oReport)},"Este relatorio irá Imprimir o Relatório de Acesso de Usuários")

//Inicia o relatório como retrato
If lRetrato
   oReport:oPage:lLandScape := .F. 
   oReport:oPage:lPortRait := .T. 
Else
   oReport:oPage:lLandScape := .T. 
   oReport:oPage:lPortRait := .F. 
EndIf

//Define o objeto com a seção do relatório
oSecao  := TRSection():New(oReport,"LOG","WKACESSO",{})
//
If aColPrint[1]
   TRCell():New(oSecao,"USER"   ,"WKACESSO","Usuário"         ,""            ,30,,,"LEFT")
   TRCell():New(oSecao,"DEPART"   ,"WKACESSO","Departamento"  ,""            ,40,,,"LEFT")
EndIf
//
If aColPrint[2]
   TRCell():New(oSecao,"MODULO" ,"WKACESSO","Módulo"          ,""            ,30,,,"LEFT")
EndIf
//
If aColPrint[3]
   TRCell():New(oSecao,"MENU"   ,"WKACESSO","Menu"            ,""            ,12,,,"LEFT")
EndIf
//
If aColPrint[4]
   TRCell():New(oSecao,"SUBMENU","WKACESSO","Sub-Menu"        ,""            ,25,,,"LEFT")
EndIf
//
If aColPrint[5]
   TRCell():New(oSecao,"ROTINA" ,"WKACESSO","Rotina"          ,""            ,25,,,"LEFT")
EndIf
//
If aColPrint[6]
   TRCell():New(oSecao,"ACESSO" ,"WKACESSO","Acesso"          ,""            ,10,,,"LEFT")
EndIf
//
If aColPrint[7]
   TRCell():New(oSecao,"FUNCAO" ,"WKACESSO","Função"          ,""            ,15,,,"LEFT")
EndIf
//
If aColPrint[8]
   TRCell():New(oSecao,"XNU"    ,"WKACESSO","XNU"             ,""            ,40,,,"LEFT")
   TRCell():New(oSecao,"TIPO"   ,"WKACESSO","Tipo"            ,""            ,05,,,"LEFT")
EndIf
//

Return oReport


/*
Funcao      : ReportPrint
Objetivos   : Imprime os dados filtrados
*/
*----------------------------------*
Static Function ReportPrint(oReport)
*----------------------------------*
//Inicio da impressão da seção.
oReport:Section("LOG"):Init()
oReport:SetMeter(WKACESSO->(LastRec()))

WKACESSO->(dbGoTop())
oReport:SkipLine(2)
Do While WKACESSO->(!EoF()) .And. !oReport:Cancel()
   If !Empty(WKACESSO->WKMARCA)
      oReport:Section("LOG"):PrintLine() //Impressão da linha
      oReport:IncMeter()                 //Incrementa a barra de progresso
   EndIf
   WKACESSO->( dbSkip() )
EndDo

//Fim da impressão da seção 
oReport:Section("LOG"):Finish()      
WKACESSO->(dbSeek(WKSZQ->(CODUSER+CODMODULO)))
oMarkAcesso:oBrowse:Refresh()
Return .T. 


Static Function RefreshBrw()

oMarkSZP:oBrowse:Refresh()
oMarqSZQ:oBrowse:SetFilter("SEQ",WKSZP->SEQ,WKSZP->SEQ)
oMarqSZQ:oBrowse:Refresh()

Return Nil


// Não utilizada (testes)
User Function CADSZP()

//Local cContrato := TRIM(CN9->CN9_NUMERO)
Local cAlias    := "SZP"
Local aCores    := {}
Local cFiltra   := "ZP_FILIAL == '"+xFilial('SZP')+"' .And. TRIM(ZP_CONTRAT) = '"+cContrato+"'"

Private cCadastro := "Ocorrências do contrato "+cContrato+": "+CN9->CN9_NOMCLI
Private aRotina   := {}
Private aIndexSz  := {}
Private bFiltraBrw:= { || FilBrowse(cAlias,@aIndexSz,@cFiltra) }
                   
PUBLIC cZPContrat := cContrato //CN9->CN9_NUMERO
PUBLIC cZPSeq     := STRZERO(1,TAMSX3("ZP_SEQ")[1])


AADD(aRotina,{"Pesquisa"		,"AxPesquisa",0,1})
AADD(aRotina,{"Visualizar"		,"AxVisual",0,2})
AADD(aRotina,{"Incluir"			,"U_INCSZP",0,3})
AADD(aRotina,{"Alterar"			,"AxAltera",0,4})

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

AADD(aCores,{"ZP_FINALIZ == 'S'","BR_VERDE" })
AADD(aCores,{"ZP_FINALIZ <> 'S'","BR_VERMELHO" })

dbSelectArea(cAlias)
dbSetOrder(1)
//+------------------------------------------------------------
//| Cria o filtro na MBrowse utilizando a função FilBrowse
//+------------------------------------------------------------
Eval(bFiltraBrw)

dbSelectArea(cAlias)
dbGoTop()

U_IncSzp()
//mBrowse(6,1,22,75,cAlias,,,,,,aCores)

//+------------------------------------------------
//| Deleta o filtro utilizado na função FilBrowse
//+------------------------------------------------
EndFilBrw(cAlias,aIndexSz)
Return Nil 




USER FUNCTION IncSZP()
Local cRet
Local cQuery 

PUBLIC cZPContrat := cContrato  //CN9->CN9_NUMERO
PUBLIC cZPSeq     := STRZERO(1,TAMSX3("ZP_SEQ")[1])

cZPSeq := STRZERO(0,TAMSX3("ZP_SEQ")[1])
cQuery := " SELECT MAX(ZP_SEQ) XX_SEQ FROM "+RETSQLNAME("SZP")+" SZP WHERE ZP_CONTRAT = '"+cZPContrat+"' "
cQuery += "             AND  ZP_FILIAL = '"+xFilial("SZP")+"' AND SZP.D_E_L_E_T_ = ' ' "
TCQUERY cQuery NEW ALIAS "QTMP1"
dbSelectArea("QTMP1")
dbGoTop()
DO WHILE !EOF()
    cZPSeq := QTMP1->XX_SEQ
	dbSelectArea("QTMP1")
	dbSkip()
ENDDO
QTMP1->(dbCloseArea())

dbSelectArea("SZP")
cZPSeq := STRZERO(VAL(cZPSeq)+1,TAMSX3("ZP_SEQ")[1])

RegToMemory("SZP",.T.)
                                                                                                                     
cRet   := AxInclui("SZP",,,,,,"U_OKSZP(1)")
//        AxInclui( <cAlias>, <nReg>, <nOpc>, <aAcho>, <cFunc>, <aCpos>, <cTudoOk>, <lF3>, <cTransact>, <aButtons>, <aParam>, <aAuto>, <lVirtual>, <lMaximized>)
 

IF cRet == 1 

	//dbSelectArea("SZP")
	//RecLock("SZP",.F.)
    //SZP->ZP_FINALIZ := "N"
    //SZP->(MsUnlock())

	dbSelectArea("WKSZP")
	RecLock("WKSZP",.T.)
	WKSZP->CONTRAT := cContrato
	WKSZP->NUMERO  := SZP->ZP_NUMERO
	WKSZP->SEQ     := SZP->ZP_SEQ
	WKSZP->DATAZP  := SZP->ZP_DATA
	WKSZP->OCORR   := SZP->ZP_OCORR 	
	WKSZP->FINALIZ := SZP->ZP_FINALIZ
	WKSZP->EFICIEN := SZP->ZP_EFICIEN
    WKSZP->(MsUnlock())
	//dbGoBottom()
	
    //ENVIA EMAIL AO SOLICITADO NA OCORRENCIA
	MsAguarde({|| U_MAILSZP(1),x:=0},"Aguarde...","Preparando e-mail...",.F.)	 

	RefreshBrw()   
ENDIF
Return Nil 
                          


USER FUNCTION IncSZQ()
Local cRet
Local cQuery 

PUBLIC cZQContrat := cContrato //CN9->CN9_NUMERO
PUBLIC cZQSeq     := STRZERO(1,TAMSX3("ZQ_SEQ")[1])
PUBLIC cZQItem    := STRZERO(1,TAMSX3("ZQ_ITEM")[1])

cZQSeq  := WKSZP->SEQ
If Empty(cZQSeq) .OR. WKSZP->(EOF())
    MsgStop("Primeiro, inclua uma ocorrência!", "Atenção")
	Return Nil
EndIf

If WKSZP->FINALIZ = "S"
    MsgStop("Ocorrência finalizada!", "Atenção")
	Return Nil
EndIf

cZQItem := STRZERO(0,TAMSX3("ZQ_ITEM")[1])

cQuery := " SELECT MAX(ZQ_ITEM) XX_ITEM FROM "+RETSQLNAME("SZQ")+" SZQ WHERE ZQ_CONTRAT = '"+cZQContrat+"' "
cQuery += "             AND  ZQ_SEQ  = '"+cZQSeq+"'"
cQuery += "             AND  ZQ_FILIAL = '"+xFilial("SZQ")+"' AND SZQ.D_E_L_E_T_ = ' ' "
TCQUERY cQuery NEW ALIAS "QTMP2"
dbSelectArea("QTMP2")
dbGoTop()
DO WHILE !EOF()
    cZQItem := QTMP2->XX_ITEM
	dbSelectArea("QTMP2")
	dbSkip()
ENDDO
QTMP2->(dbCloseArea())

dbSelectArea("SZP")
cZQItem := STRZERO(VAL(cZQItem)+1,TAMSX3("ZQ_ITEM")[1])
cRet    := AxInclui("SZQ",,,,,,"U_OKSZQ()")


IF cRet == 1 
	
	dbSelectArea("WKSZQ")
	RecLock("WKSZQ",.T.)
	WKSZQ->CONTRAT := cContrato
	WKSZQ->SEQ     := cZQSeq
	WKSZQ->ITEM    := cZQItem
	WKSZQ->DATAZQ  := SZQ->ZQ_DATA
	WKSZQ->OQUE    := SZQ->ZQ_OQUE 	
	WKSZQ->FINALIZ := SZQ->ZQ_FINALIZ
    WKSZQ->(MsUnlock())
	   
	RefreshBrw()   
ENDIF
Return Nil 




USER FUNCTION AltSZP()
Local cRet
Local nRec 
Local aCpoZp := {"ZP_DATA","ZP_OCORR","ZP_DETOCOR","ZP_QUEM","ZP_FINALIZ","ZP_DATAPRV","ZP_USER","ZP_EFICIEN"}

PUBLIC cZPContrat := cContrato //CN9->CN9_NUMERO
PUBLIC cZPSeq     := WKSZP->SEQ

dbSelectArea("SZP")
If dbSeek(xFilial("SZP")+cZPContrat+cZPSeq,.F.)

	If WKSZP->FINALIZ <> "S"
		nRec   := SZP->(RECNO())
		cRet   := AxAltera("SZP",nRec,4,aCpoZp,aCpoZp,,,"U_OKSZP(2)")
	//            AxAltera( <cAlias>, <nReg>, <nOpc>, <aAcho>, <aCpos>, <nColMens>, <cMensagem>, <cTudoOk>, <cTransact>, <cFunc>, <aButtons>, <aParam>, <aAuto>, <lVirtual>, <lMaximized>)
		
		IF cRet == 1 
			//IF MsgYesNo("Deseja Incluir planos de ação ?")
			//ENDIF
			
			dbSelectArea("WKSZP")
			RecLock("WKSZP",.F.)
			WKSZP->CONTRAT := cZPContrat
			WKSZP->SEQ     := SZP->ZP_SEQ
			WKSZP->DATAZP  := SZP->ZP_DATA
			WKSZP->OCORR   := SZP->ZP_OCORR 	
			WKSZP->FINALIZ := SZP->ZP_FINALIZ
			WKSZP->EFICIEN := SZP->ZP_EFICIEN
		    WKSZP->(MsUnlock())
		    
		    IF SZP->ZP_FINALIZ == 'S'   
				//ENVIA EMAIL AVISO DE FINALIZADO
				MsAguarde({|| U_MAILFIMSZP()},"Aguarde...","Preparando e-mail...",.F.)
			ELSE
			    //ENVIA EMAIL AO SOLICITADO NA OCORRENCIA
				MsAguarde({|| U_MAILSZP(2),x:=0},"Aguarde...","Preparando e-mail...",.F.)
			ENDIF
			   
			RefreshBrw()   
		EndIf
	Else
		MsgStop("Ocorrência finalizada não pode ser alterada.")
	EndIf
EndIf
Return Nil 


// Verificar se tem plano de ação em aberto
USER FUNCTION OKSZP(_nOp)
lRet := .T.
If M->ZP_FINALIZ == "S"
	SZQ->(dbSeek(xFilial("SZQ")+M->ZP_CONTRAT+M->ZP_SEQ,.T.))
	If M->ZP_CONTRAT+M->ZP_SEQ == SZQ->ZQ_CONTRAT+SZQ->ZQ_SEQ
		Do WHile !SZQ->(EOF()) .AND. M->ZP_CONTRAT+M->ZP_SEQ == SZQ->ZQ_CONTRAT+SZQ->ZQ_SEQ
		    If SZQ->ZQ_FINALIZ <> "S"
		    	lRet := .F.
		    	Exit
		    EndIf
			SZQ->(dbSkip())
		EndDo
		If !lRet
			MsgStop("Existem planos de ação em aberto para esta ocorrência")
			M->ZP_FINALIZ := "N"
		EndIf
	Else
		lRet := .F.
		MsgStop("Não se pode fechar ocorrência sem planos de ação")
		M->ZP_FINALIZ := "N"
	EndIf
EndIf	
If Empty(M->ZP_USER)
	M->ZP_USER := cUserName
EndIf
If lRet
	If M->ZP_DATAPRV > (M->ZP_DATA+30) .OR. M->ZP_DATAPRV < M->ZP_DATA                                                             
		MsgStop("Data de previsão não deve ultrapassar 30 dias e deve ser superior a data de inclusão da ação")
		lRet := .F.
    EndIf  
EndIf

If lRet .AND. _nOp = 2
   If !EMPTY(SZP->ZP_DATAPRV) .AND. SZP->ZP_DATAPRV <> M->ZP_DATAPRV
		MsgStop("Data de previsão não pode ser alterada")
		lRet := .F.
   EndIf
EndIf

RETURN lRet




// Validar planos de ação
USER FUNCTION OKSZQ()
lRet := .T.

M->ZQ_USER := cUserName

//If M->ZQ_QUANDO < M->ZQ_DATA .OR. M->ZQ_QUANDO > SZP->ZP_DATAPRV
//	MsgStop("Data de 'quando' deve estar entre "+DTOC(M->ZQ_DATA)+" e "+DTOC(SZP->ZP_DATAPRV))
//	lRet := .F.
//EndIf

If M->ZQ_FINALIZ == "S" .AND. EMPTY(M->ZQ_RESULT) .AND. lRet
	MsgStop("Preencha o resultado do Plano de Ação")
	lRet := .F.
EndIf
RETURN lRet



USER FUNCTION AltSZQ()
Local cRet
Local nRec 
Local aCpoZq := {"ZQ_DATA","ZQ_OQUE","ZQ_PORQUE","ZQ_QUEM","ZQ_QUANDO","ZQ_ONDE","ZQ_QUANTO","ZQ_FINALIZ","ZQ_RESULT","ZQ_USER"}

PUBLIC cZQContrat := cContrato //CN9->CN9_NUMERO
PUBLIC cZQSeq     := WKSZQ->SEQ
PUBLIC cZQItem    := WKSZQ->ITEM

If WKSZP->FINALIZ = "S"
    MsgStop("Ocorrência finalizada!", "Atenção")
	Return Nil
EndIf

dbSelectArea("SZQ")
dbGotop()
If dbSeek(xFilial("SZQ")+cZQContrat+cZQSeq+cZQItem,.F.)
	nRec   := SZQ->(RECNO())
	cRet   := AxAltera("SZQ",nRec,4,aCpoZq,aCpoZq,,,"U_OKSZQ()")
	If WKSZQ->FINALIZ <> "S"
		If cRet == 1 
			//IF MsgYesNo("Deseja Incluir planos de ação ?")
			//ENDIF
			
			dbSelectArea("WKSZQ")
			RecLock("WKSZQ",.F.)
			WKSZQ->CONTRAT := cContrato
			WKSZQ->SEQ     := cZQSeq
			WKSZQ->ITEM    := cZQItem
			WKSZQ->DATAZQ  := SZQ->ZQ_DATA
			WKSZQ->OQUE    := SZQ->ZQ_OQUE 	
			WKSZQ->FINALIZ := SZQ->ZQ_FINALIZ
		    WKSZQ->(MsUnlock())
		   
			RefreshBrw()   
		EndIf
	Else
		MsgStop("Plano de Ação finalizado")
	EndIf
EndIf
Return Nil 


USER FUNCTION VISSZP()
PUBLIC cZPContrat := cContrato //CN9->CN9_NUMERO
PUBLIC cZPSeq     := WKSZP->SEQ

dbSelectArea("SZP")
If dbSeek(xFilial("SZP")+cZPContrat+cZPSeq,.F.)
	nRec   := SZP->(RECNO())
	AxVisual("SZP",nRec,2)
EndIf
Return Nil


USER FUNCTION VISSZQ()
PUBLIC cZQContrat := cContrato //CN9->CN9_NUMERO
PUBLIC cZQSeq     := WKSZQ->SEQ
PUBLIC cZQItem    := WKSZQ->ITEM

dbSelectArea("SZQ")
If dbSeek(xFilial("SZQ")+cZQContrat+cZQSeq+cZQItem,.F.)
	nRec   := SZQ->(RECNO())
	AxVisual("SZQ",nRec,2)
EndIf
Return Nil


USER FUNCTION ExcSZP()
Local cRet
Local nRec 

PUBLIC cZPContrat := cContrato //CN9->CN9_NUMERO
PUBLIC cZPSeq     := WKSZP->SEQ

dbSelectArea("SZP")
If dbSeek(xFilial("SZP")+cZPContrat+cZPSeq,.F.)
	nRec   := SZP->(RECNO())

	RegToMemory("SZP",.F.)
    
	SZQ->(dbSeek(xFilial("SZQ")+cZPContrat+cZPSeq,.T.))
    If SZQ->(EOF() .OR. (cZPContrat+cZPSeq <> ZQ_CONTRAT+ZQ_SEQ) )
    
		cRet   := AxDeleta("SZP",nRec,5,)
		
		If cRet == 2

			dbSelectArea("WKSZP")
			RecLock("WKSZP",.F.)
			dbDelete()
		    WKSZP->(MsUnlock())
			   
			RefreshBrw()   
		EndIf
	Else
		MsgStop("Esta ocorrência possui planos de ação","Atenção")
	EndIf
EndIf
Return Nil 


USER FUNCTION ExcSZQ()
Local cRet
Local nRec 

PUBLIC cZQContrat := cContrato //CN9->CN9_NUMERO
PUBLIC cZQSeq     := WKSZQ->SEQ
PUBLIC cZQItem    := WKSZQ->ITEM

If WKSZP->FINALIZ = "S"
    MsgStop("Ocorrência finalizada!", "Atenção")
	Return Nil
EndIf

dbSelectArea("SZQ")
If dbSeek(xFilial("SZQ")+cZQContrat+cZQSeq+cZQItem,.F.)
	nRec   := SZQ->(RECNO())

	RegToMemory("SZQ",.F.)

	cRet   := AxDeleta("SZQ",nRec,5)
		
	If cRet == 2

		dbSelectArea("WKSZQ")
		RecLock("WKSZQ",.F.)
		dbDelete()
	    WKSZQ->(MsUnlock())
			   
		RefreshBrw()   
	EndIf
EndIf
Return Nil 


USER FUNCTION FinSZP()
Local lOk   := .T.
Local lOkOk := .F.
Local nRec  := WKSZP->(RECNO())

dbSelectArea("WKSZP")
dbGoTop()
Do While WKSZP->(!Eof())
	If !EMPTY(WKSZP->WKMARCA)

		dbSelectArea("SZP")
		If dbSeek(xFilial("SZP")+WKSZP->CONTRAT+WKSZP->SEQ,.F.)
		
			SZQ->(dbSeek(xFilial("SZQ")+WKSZP->CONTRAT+WKSZP->SEQ,.T.))
		    Do While !SZQ->(EOF()) .AND. (WKSZP->CONTRAT+WKSZP->SEQ == SZQ->ZQ_CONTRAT+SZQ->ZQ_SEQ)
               If SZQ->ZQ_FINALIZ <> "S"
					lOk := .F.
					Exit
				Else
					lOkOk := .T.
               EndIf
               SZQ->(dbSkip())
     		EndDo
    	EndIf
	EndIf
	WKSZP->(dbSkip())
EndDo

If lOk .AND. lOkOk

	If MsgYesNo("Confirma a finalização destas ocorrências?")

		dbSelectArea("WKSZP")
		dbGoTop()
		Do While WKSZP->(!Eof())
			If !EMPTY(WKSZP->WKMARCA)
		
				dbSelectArea("SZP")
				If dbSeek(xFilial("SZP")+WKSZP->CONTRAT+WKSZP->SEQ,.F.)

					RecLock("SZP",.F.)
					SZP->ZP_FINALIZ := "S"
					SZP->(MsUnlock())

					RecLock("WKSZP",.F.)
					WKSZP->WKMARCA := ""
					WKSZP->FINALIZ := "S"
					WKSZP->(MsUnlock())              
					
					//ENVIA EMAIL AVISO DE FINALIZADO
					MsAguarde({|| U_MAILFIMSZP()},"Aguarde...","Preparando e-mail...",.F.)	 
								
		    	EndIf
			EndIf
			WKSZP->(dbSkip())
		EndDo
   EndIf
EndIf

If !lOk
	MsgStop("Existem planos de ação em aberto para esta ocorrência")
EndIf
If nRec > 0
	WKSZP->(dbGoTo(nRec))
EndIf

Return Nil


//User Function ZPNQUEM()
//Local aUser := {}
//PswOrder(1)
//PswSeek(M->ZP_QUEM) 
//aUser  := PswRet(1)
//M->ZP_NQUEM := aUser[1][2] 
//Return .T.


User Function UltRevisa(cContrato,cCampo)
Local aArea := GetArea() 
Local xCampo
dbSelectArea("CN9")
dbSetOrder(1)
dbSeek(xFilial("CN9")+cContrato,.T.)
Do While !EOF() .and. xFilial("CN9")+cContrato == CN9->CN9_FILIAL+CN9->CN9_NUMERO
   xCampo := &(cCampo)
   dbSkip()
EndDo
RestArea(aArea)
Return xCampo



//Aviso Plano de Ação - Ocorrência Incluida"
USER Function MAILSZP(nOpc)

Local cAssunto	:= "Ocorrência Incluida"
Local cEmail	:= "microsiga@bkconsultoria.com.br;vanderleia.silva@bkconsultoria.com.br;"
Local cEmailCC	:= ""
Local cMsg    	:= ""
Local cAnexo    := ""
Local aCabs		:= {}
Local aEmail	:= {}
Local aUser     := {}
Local cNomeQuem := ""
If nOpc == 1
	cAssunto	:= "Ocorrência Incluida"
Else
	cAssunto	:= "Ocorrência Alterada"
EndIf

cEmail	+= "controladoria@bkconsultoria.com.br;"
// Mandar para: Quem, Gestor, Gerente e Controladoria


/*
cEmail	+= "diego@bkconsultoria.com.br;"
cEmail	+= "gestao@bkconsultoria.com.br;"
cEmail	+= "william.nunes@bkconsultoria.com.br;"
*/


PswOrder(1)
PswSeek(SZP->ZP_QUEM) 
aUser  := PswRet(1)
cEmail	+= aUser[1][14]+";" 
cNomeQuem := Alltrim(aUser[1][4])
If Empty(cNomeQuem)
	cNomeQuem := SZP->ZP_QUEM
EndIf

PswOrder(1)
PswSeek(__cUserID) 
aUser  := PswRet(1)
cEmail	+= aUser[1][14]+";" 

    
AADD(aEmail,{SZP->ZP_CONTRAT,;
U_BUSCACN9(SZP->ZP_CONTRAT,"CN9_XXDESC"),;
SZP->ZP_DATA,;
SZP->ZP_OCORR,;
SZP->ZP_DETOCOR,;
SZP->ZP_DATAPRV,;
SZP->ZP_USER})


IF LEN(aEmail) > 0

	aCabs   := {"Contrato",;
				"Descr. Contrato",;
				"Data",;
				"Ocorrência",;
				"Descrição",;
				"Data Prevista",;
				"Criado Por"}

 	cMsg    := u_GeraHtmA(aEmail,cAssunto+": "+SZP->ZP_NUMERO+" - "+DTOC(DATE())+" "+TIME()+" - Para: "+cNomeQuem,aCabs,"MAILSZP")

	U_SendMail("MAILSZP","Aviso Plano de Ação - "+cAssunto+": "+SZP->ZP_NUMERO+" - Para: "+cNomeQuem,cEmail,cEmailCC,cMsg,cAnexo,.F.)

ENDIF

Return Nil     




//Aviso Plano de Ação - Ocorrência Finalizada"
USER Function MAILFIMSZP()

Local cAssunto	:= "Aviso Plano de Ação - Ocorrência Finalizada"
Local cEmail	:= "microsiga@bkconsultoria.com.br;"
Local cEmailCC	:= ""
Local cMsg    	:= ""
Local cAnexo    := ""
Local aCabs		:= {}
Local aEmail	:= {}
Local aUser		:= {}
Local aArea     := GetArea()
Local cNomeQuem := ""

// Mandar para: Quem, Gestor, Gerente e Controladoria
cEmail	+= "controladoria@bkconsultoria.com.br;vanderleia.silva@bkconsultoria.com.br;"

/*
cEmail	+= "diego@bkconsultoria.com.br;"
cEmail	+= "gestao@bkconsultoria.com.br;"
cEmail	+= "william.nunes@bkconsultoria.com.br;"
*/

PswOrder(1)
PswSeek(SZP->ZP_QUEM) 
aUser  := PswRet(1)
cEmail	+= aUser[1][14]+";" 
cNomeQuem := Alltrim(aUser[1][4])
If Empty(cNomeQuem)
	cNomeQuem := SZP->ZP_QUEM
EndIf

PswOrder(1)
PswSeek(__cUserID) 
aUser  := PswRet(1)
cEmail	+= aUser[1][14]+";" 

aCabs :=  { "Número",;
			"Contrato",;
			"Descr. Contrato",;
			"Data",;
			"Ocorrência",;
			"Descrição",;
			"Data Prevista",;
			"Eficiência",;
			"Criado Por"}
				    
AADD(aEmail,{SZP->ZP_NUMERO,;
	SZP->ZP_CONTRAT,;
	U_BUSCACN9(SZP->ZP_CONTRAT,"CN9_XXDESC"),;
	SZP->ZP_DATA,;
	SZP->ZP_OCORR,;
	SZP->ZP_DETOCOR,;
	SZP->ZP_DATAPRV,;
	SZP->ZP_EFICIEN,;
	SZP->ZP_USER}) 
	
cMsg := u_GeraHtmA(aEmail,"Ocorrência FInalizada: "+SZP->ZP_NUMERO+" - "+DTOC(DATE())+" "+TIME()+" - Para: "+cNomeQuem,aCabs,"")

 
aEmail := {}

dbSelectArea("SZQ")
dbSetOrder(1)
SZQ->(dbSeek(xFilial("SZQ")+SZP->ZP_CONTRAT+SZP->ZP_SEQ,.T.))
Do WHile !SZQ->(EOF()) .AND. SZP->ZP_CONTRAT+SZP->ZP_SEQ == SZQ->ZQ_CONTRAT+SZQ->ZQ_SEQ


	AADD(aEmail,{SZQ->ZQ_DATA,;
				 SZQ->ZQ_OQUE,;
				 SZQ->ZQ_PORQUE,;
				 SZQ->ZQ_QUEM,;
				 SZQ->ZQ_QUANDO,;
				 SZQ->ZQ_ONDE,;
				 SZQ->ZQ_QUANTO,;
				 SZQ->ZQ_RESULT})
	
	SZQ->(dbSkip())
EndDo

IF LEN(aEmail) > 0

	aCabs  :=  {"Data",;
				"Oque",;
				"Porque",;
				"Quem",;
				"Quando",;
				"Onde",;
				"Quanto",;
				"Resultado"}
	cMsg2	:= ""
	cMsg2   := u_GeraHtmA(aEmail,"Plano de Ação",aCabs,"MAILFIMSZP")
	cMsg2   := STRTRAN(cMsg2,'<p align=center style="text-align:center"><img src="http://www.bkconsultoria.com.br/Imagens/logo_header.png" border=0></p>',"")
    cMsg	+= cMsg2

	U_SendMail("MAILFIMSZP",cAssunto+" - Para:"+cNomeQuem,cEmail,cEmailCC,cMsg,cAnexo,.F.)

ENDIF

RestArea(aArea)

Return Nil
