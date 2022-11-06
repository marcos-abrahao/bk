#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"
#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³BKANXA02  ºAutor  ³ Marcos B. Abrahão  º Data ³ 02/09/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para abrir anexos ao Documento de Entrada           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ºAlterado  ³ 19/09/2017 - Incluido anexo contas a receber SE1 - Adilson º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BKANXA02(cOrigem,cAliasKey)

Local aArqList
Local oOk
Local oNo
Local oDlg
Local oListFile
Local oPanelLeft
//Local lAll
//Local oAll
Local lOk := .F.
Local aButtons := {}
Local cFile,cDir,cDrive
Local aAreaDoc := GetArea()
Local cKey:= "",cDocOri:=""
Local cDirCtr:="",aArqCtr :={}
Local x,y

u_MsgLog("BKANXA02")

dbSelectArea(cAliasKey)
IF BOF() .OR. EOF()
	MsgStop("Selecione um Documento", "Atenção")
	RestArea(aAreaDoc)
	Return
ENDIF
If cAliasKey == "SF1"
   If SF1->F1_XXANEXO $ "N "
		MsgStop("O documento "+TRIM(SF1->F1_DOC)+ " não possui anexos" , "Atenção")
		RestArea(aAreaDoc)
		Return
   Endif
ElseIf cAliasKey == "SE2"
   If SE2->E2_XXANEXO $ "N " .AND. EMPTY(SE2->E2_XXCTRID)
		MsgStop("O título "+TRIM(SE2->E2_NUM)+ " não possui anexos" , "Atenção")
		RestArea(aAreaDoc)
		Return
   Endif
ElseIf cAliasKey == "SE1"
   If SE1->E1_XXANEXO $ "N "
		MsgStop("O título "+TRIM(SE1->E1_NUM)+ " não possui anexos" , "Atenção")
		RestArea(aAreaDoc)
		Return
   Endif
ENDIF

If cAliasKey == "SF1"
	cKey := SM0->M0_CODIGO+"SF1"+SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO
ElseIf cAliasKey == "SE2"
	cKey := SM0->M0_CODIGO+"SE2"+SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA
	IF !EMPTY(SE2->E2_XXCTRID)
	   cDirCtr := SM0->M0_CODIGO+"CTR"+SE2->E2_XXCTRID+"_"+SE2->E2_PORTADO
	ENDIF   
ElseIf cAliasKey == "SE1"
	cKey := SM0->M0_CODIGO+"SE1"+SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA
EndIf

cKey := STRTRAN(cKey," ","_")
dbSelectArea("SZ3")
dbSetOrder(1)
cKey := PAD(cKey,LEN(SZ3->Z3_CHAVE))
dbSeek(xFilial("SZ3")+cKey,.T.)
lKey  := .F.
lCopy := .T.
aArqList:={}
Do while !eof() .and. SZ3->Z3_FILIAL+SZ3->Z3_CHAVE == xFilial("SX3") + cKey
	cFile := ALLTRIM(SZ3->Z3_ARQANEX)
	SplitPath( cFile, @cDrive, @cDir ) // Quebrada o path em partes (Diretório, drive, etc)
	cFile := SUBSTR(cFile,LEN(cDrive)+LEN(cDir))
	If SUBSTR(cFile,1,1) = "\"
		cFile := SUBSTR(cFile,2)
	Endif
	Aadd(aArqList,{cFile,SZ3->Z3_COMENT,DTOC(SZ3->Z3_DATA),SZ3->Z3_USUARIO,cKey})
   
	If Empty(cDocOri)
		cDocOri := SZ3->Z3_DOCORI
	EndIf

   dbSkip()
Enddo

IF !EMPTY(cDirCtr)
   aArqCtr := Directory("\Anexos\"+cDirCtr+"\*.*")
   Aeval(aArqCtr,{|x| Aadd(aArqList,{x[1],"Integração Liq. "+FWEmpName(cEmpAnt)+" "+SE2->E2_XXCTRID,DTOC(x[3]),ALLTRIM(x[4]),cDirCtr}  )  })
ENDIF

If Empty(aArqList)
    If cAliasKey == "SF1"
		MsgStop("Problemas entre a base de dados e os anexos", "Atenção")
		RecLock("SF1",.F.)
		SF1->F1_XXANEXO := "N"
		msUnlock()
    ElseIf cAliasKey == "SE2"
    	IF EMPTY(cDirCtr)
			MsgStop("Problemas entre a base de dados e os anexos", "Atenção")
			RecLock("SE2",.F.)
			SE2->E2_XXANEXO := "N"
			msUnlock()
		ELSE
			MsgStop("Não há anexos integrados (Liq. "+FWEmpName(cEmpAnt)+")", "Atenção")
		ENDIF	
    ElseIf cAliasKey == "SE1"
		MsgStop("Problemas entre a base de dados e os anexos", "Atenção")
		RecLock("SE1",.F.)
		SE1->E1_XXANEXO := "N"
		msUnlock()
	EndIf
	RestArea(aAreaDoc)
	Return
EndIf

Asort(aArqList,,,{|x,y| x[1]<y[1]})

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE "Anexos: "+cDocOri FROM 000,000 TO 450,630 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 320,210
oPanelLeft:Align := CONTROL_ALIGN_TOP

//lAll := .F.
//@ 004, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
//oAll:bChange := {|| Aeval(aArqList,{|x| x[1]:=lAll}), oListFile:Refresh()}

@ 005, 005  BUTTON "Abrir anexo"    OF oPanelLeft SIZE 45,10 PIXEL  ACTION AbrirAnexo(aArqList,oListFile:nAt)
@ 005, 055  BUTTON "Excluir anexo"  OF oPanelLeft SIZE 45,10 PIXEL  ACTION ExcluirAnexo(aArqList,oListFile:nAt,oDlg,cAliasKey)

@ 018, 005 LISTBOX oListFile FIELDS HEADER "Arquivo","Comentário","Data","Usuário","Diretorio" SIZE 310,190 OF oPanelLeft PIXEL 
oListFile:SetArray(aArqList)
//oListFile:bLine := {|| {If(aArqList[oListFile:nAt][1],oOk,oNo),aArqList[oListFile:nAt][2],aArqList[oListFile:nAt][3]}}
oListFile:bLine := {|| {aArqList[oListFile:nAt][1],aArqList[oListFile:nAt][2],aArqList[oListFile:nAt][3],aArqList[oListFile:nAt][4],aArqList[oListFile:nAt][5]}}
//x  oListFile:bLDblClick := {|| aArqList[oListFile:nAt][1] := !aArqList[oListFile:nAt][1],oListFile:DrawSelect()}
//oListFile:bLDblClick := {|| AbrirAnexo(aArqList[oListFile:nAt][2],cKey),oListFile:DrawSelect()}
oListFile:bLDblClick := {|| AbrirAnexo(aArqList,oListFile:nAt),oListFile:DrawSelect()}
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

/*
If ( lOk )
EndIf
*/

RestArea(aAreaDoc)

Return


Static Function AbrirAnexo(aArqList,nPos)

Local _lRet := .F.,_cFile,cKey
Local cDirAnexo

cFile  := aArqList[nPos][1]
cKey   := aArqList[nPos][5]

//Local cDirDocs := MsDocPath() 

cDirAnexo := "C:\TMP\"
MakeDir(cDirAnexo)
//cDirAnexo := "C:\TMP\"+ALLTRIM(cKey)
//MakeDir(cDirAnexo)                                     

_cFile    := cDirAnexo+"\"+TRIM(cFile)
//_cFileTmp := cDirDocs+"\"+cFile
lRet := __CopyFile("\Anexos\"+TRIM(cKey)+"\"+TRIM(cFile), _cFile)
If lRet
	_nRet:= ShellExecute("open", _cFile,"","",1)
Else
	MsgStop("Não foi possível criar o arquivo "+_cFile, "Atenção")
EndIf
Return _lRet         


Static Function ExcluirAnexo(aArqList,nPos,oDlg,cAliasKey)
Local _lRet := .T.
Local cFile,_cFile,cKey
Local cDirAnexo

cFile     := aArqList[nPos][1]
cKey      := aArqList[nPos][5]
cDirAnexo := "\Anexos\"+TRIM(cKey)
_cFile    := cDirAnexo+"\"+TRIM(cFile)

IF UPPER(SUBSTR(cKey,3,3)) == "CTR"
	MsgStop("Arquivo gerado pelo sistema de integração não pode ser excluido")
    lRet  := .F.
ELSE    
    lRet  := MsgBox("Deseja excluir o arquivo "+TRIM(cFile)+" ?","", "YESNO")
ENDIF
    
If lRet
	_nRet:= FERASE(_cFile)
	dbSelectArea("SZ3")
	dbSetOrder(1)
	dbSeek(xFilial("SZ3")+cKey,.T.)
	Do while !eof() .and. SZ3->Z3_FILIAL+SZ3->Z3_CHAVE == xFilial("SX3") + cKey
 		If ALLTRIM(_cFile) = ALLTRIM(SZ3->Z3_ARQANEX)
			RecLock("SZ3",.F.)
			dbDelete()
			msUnlock()
 			Exit
 		EndIf
		dbSkip()
	Enddo

	ADEL(aArqList,nPos)
	ASIZE(aArqList,Len(aArqList)-1)
	
	If LEN(aArqList) = 0
		Dirremove(cDirAnexo) // achei a funcao
		IF cAliasKey == "SF1"
		   RecLock("SF1",.F.)
		   SF1->F1_XXANEXO := "N"
		   msUnlock()
		ELSEIF cAliasKey == "SE2"
		   RecLock("SE2",.F.)
		   SE2->E2_XXANEXO := "N"
		   msUnlock()
		ELSEIF cAliasKey == "SE1"
		   RecLock("SE1",.F.)
		   SE1->E1_XXANEXO := "N"
		   msUnlock()
		ENDIF
		oDlg:End()
	EndIf
	
EndIf
Return _lRet         
