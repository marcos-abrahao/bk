#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOLE.CH"
#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³BKANXA01  ºAutor  ³ Marcos B. Abrahão  º Data ³ 02/09/2009  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para anexar arquivos ao Documento de Entrada        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ºAlterado  ³ 19/09/2017 - Incluido anexo contas a receber SE1 - Adilson º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BKANXA01(cOrigem,cAliasKey)

Local aBmps
Local aSourceImg
Local oOk
Local oNo
Local oDlg
Local oListImg
Local nI
Local oPanelLeft
Local lAll
Local oAll
Local lOk        := .F.
Local aButtons   := {}
Local cTargetDir := ""
Local cDirAnexo  := ""
Local cTipoArq   := ""		//Tipo (extensao) do arquivo
Local lCopiado   := .F.
Local aAreaDoc := GetArea()
Local cDocOri,cKey

dbSelectArea(cAliasKey)
IF BOF() .OR. EOF()
	MsgStop("Selecione um registro", "Atenção")
	RestArea(aAreaDoc)
	Return
ENDIF

cTipoArq   := "Todos os Arquivos (*.*) | *.* | "
cTargetDir := cGetFile(cTipoArq,"Selecione o diretório contendo os arquivos",,cTargetDir,.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+128,.F.) 

If Empty(cTargetDir)
	RestArea(aAreaDoc)
	Return
EndIf

cDocOri := ""
cKey    := ""
If cAliasKey == "SF1"

	cKey := SM0->M0_CODIGO+"SF1"+SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_TIPO

	If !Empty(SF1->F1_ESPECIE)
		cDocOri += TRIM(SF1->F1_ESPECIE)+" "
	Endif
	cDocOri += SF1->F1_DOC+"-"
	If !Empty(SF1->F1_SERIE)
		cDocOri += TRIM(SF1->F1_SERIE)+"-"
	Endif
	
	If SF1->F1_TIPO <> "D"
	   cDocOri += Posicione("SA2",1,Xfilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_NOME")
	Else
	   cDocOri += Posicione("SA1",1,Xfilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA,"A1_NOME")
	Endif   
ElseIf cAliasKey == "SE2"
	cKey    := SM0->M0_CODIGO+"SE2"+SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA  
	cDocOri := SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+SE2->E2_FORNECE+SE2->E2_LOJA  
ElseIf cAliasKey == "SE1"
	cKey    := SM0->M0_CODIGO+"SE1"+SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA  
	cDocOri := SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA  
EndIf

aBmps := Directory(cTargetDir+"*.*")
aSourceImg := {}
Aeval(aBmps,{|x| Aadd(aSourceImg,{.F.,IIF(LEN(x[1])<50,PAD(x[1],50),x[1]),"", IIF(UPPER(SUBSTR(x[1],1,5)) == "CTRID",.F.,.T.) })})

Asort(aSourceImg,,,{|x,y| x[2]<y[2]})

If Empty(aSourceImg)
	MsgStop("Não há Arquivos neste diretório: " + cTargetDir, "Atenção")
	RestArea(aAreaDoc)
	Return
EndIf

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE "Seleção de Arquivos" FROM 000,000 TO 450,630 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 320,225
oPanelLeft:Align := CONTROL_ALIGN_CENTER
lAll := .F.
@ 012, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
oAll:bChange := {|| Aeval(aSourceImg,{|x| IIF(x[4],x[1]:=lAll,x[1]=.F.)}), oListImg:Refresh()}

@ 022, 005 LISTBOX oListImg FIELDS HEADER "","Arquivos","Comentário" SIZE 310,200 OF oPanelLeft PIXEL 
oListImg:SetArray(aSourceImg)
oListImg:bLine := {|| {If(aSourceImg[oListImg:nAt][1],oOk,oNo),cTargetDir+aSourceImg[oListImg:nAt][2],aSourceImg[oListImg:nAt][3]}}
oListImg:bLDblClick := {|| aSourceImg[oListImg:nAt][1] := IIF(aSourceImg[oListImg:nAt][4],!aSourceImg[oListImg:nAt][1],.F.), ;
                           aSourceImg[oListImg:nAt][3] := IIF(aSourceImg[oListImg:nAt][1],DlgComent(aSourceImg[oListImg:nAt][3],aSourceImg[oListImg:nAt][2]),""),;
                           oListImg:DrawSelect()}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

If ( lOk )
    cKey := STRTRAN(cKey," ","_")
	cDirAnexo := "\Anexos\"
	MakeDir(Alltrim(cDirAnexo))
	cDirAnexo := "\Anexos\"+ALLTRIM(cKey)                                                  
	MakeDir(Alltrim(cDirAnexo))
    lOk := .F.
	For nI:=1 To Len(aSourceImg)
		If ( aSourceImg[nI][1] )
			lCopiado := CopiaDoc(cOrigem,cAliasKey,cKey,cDocOri,cTargetDir,cTargetDir+aSourceImg[nI][2],cDirAnexo,aSourceImg[nI][3])
			If lCopiado
				lOk := lCopiado
			EndIf	
		EndIf
	Next nI
	
    If cAliasKey == "SF1"
		RecLock("SF1",.F.)
		SF1->F1_XXANEXO := "S"
		msUnlock()
    ElseIf cAliasKey == "SE2"
		RecLock("SE2",.F.)
		SE2->E2_XXANEXO := "S"
		msUnlock()
    ElseIf cAliasKey == "SE1"
		RecLock("SE1",.F.)
		SE1->E1_XXANEXO := "S"
		msUnlock()
	EndIf
	
   	If lCopiado
		Aviso("BKANXA01",OemtoAnsi("Arquivo(s) anexado(s) com sucesso!"),{"Ok"})
		
	Else
		Aviso("BKANXA01",OemtoAnsi("Arquivo(s) não foi(ram) anexado(s)!"),{"Ok"})
	Endif	
	
EndIf
RestArea(aAreaDoc)
Return (lCopiado)

//--------------------------------------------------------------------------------------
Static Function CopiaDoc(cOrigem,cAliasKey,cKey,cDocOri,cDirAtu,cFile,cDirAnexo,cComent)
Local lRet 	   := .F.
Local cDrive   := Space(255)
Local cDir     := Space(255)
Local lKey,lCopy,cArqDest

//Local cRootPath := GetSrvProfString("RootPath","")

SplitPath( cFile, @cDrive, @cDir ) // Quebrada o path em partes (Diretório, drive, etc)
cDirAtu := Alltrim(cDrive)+Alltrim(cDir)
if IsFileServer( cDirAtu ) 
	cDirAtu := OemtoAnsi("SERVIDOR")+cDirAtu   //   "SERVIDOR"
endif


IF !Empty(cFile)
	
	cArqDest := Alltrim(cDirAnexo+subs(alltrim(cFile),len(alltrim(cDirAtu)),len(alltrim(cFile))))
	dbSelectArea("SZ3")
	dbSetOrder(1)
	cKey := PAD(cKey,LEN(SZ3->Z3_CHAVE))
	dbSeek(xFilial("SZ3")+cKey)
	lKey  := .F.
	lCopy := .T.
	Do while !eof() .and. SZ3->Z3_FILIAL+SZ3->Z3_CHAVE == xFilial("SX3") + cKey
	    If ALLTRIM(SZ3->Z3_ARQANEX) == ALLTRIM(cArqDest)
	    	lKey := .T.
	    	If MsgBox("Arquivo já esta anexado a este documento, sobrepõe o anterior ?",cArqDest, "YESNO")
				If Empty(cComent)
					cComent := SZ3->Z3_COMENT
					cComent := DlgComent(cComent,Alltrim(cFile)) 
				Endif   
				RecLock("SZ3",.F.)
				SZ3->Z3_COMENT  := cComent
				SZ3->Z3_DATA    := DATE()
				SZ3->Z3_ARQANEX := cArqDest
				SZ3->Z3_ARQORIG := Alltrim(cFile)
				SZ3->Z3_USUARIO := cUserName
				msUnlock()
			Endif
			Exit	
		EndIF
		dbSkip()	
	Enddo
	If !lKey
		If Empty(cComent) 
		   cComent := DlgComent(cComent,Alltrim(cFile)) 
		Endif   
		RecLock("SZ3",.T.)
		SZ3->Z3_FILIAL  := xFilial("SZ3")
		SZ3->Z3_ORIGEM  := cOrigem
		SZ3->Z3_DOCORI  := cDocOri
		SZ3->Z3_COMENT  := cComent
		SZ3->Z3_DATA    := DATE()
		SZ3->Z3_ALIAS   := cAliasKey
		SZ3->Z3_CHAVE   := cKey
		SZ3->Z3_ARQANEX := cArqDest
		SZ3->Z3_ARQORIG := Alltrim(cFile)
		SZ3->Z3_USUARIO := cUserName
		msUnlock()     
	EndIf
	If lCopy
		__CopyFile(Alltrim(cFile), Alltrim(cDirAnexo+subs(alltrim(cFile),len(alltrim(cDirAtu)),len(alltrim(cFile)))))
		lRet := .T.
	Endif
Endif
Return lRet



Static Function DlgComent(cComent,cArquivo)
Local cComent1 := PAD(cComent,50)
@ 200, 010 To 295,580 Dialog oDlg2 Title OemToAnsi ("Digite um comentário para este arquivo")
@ 010, 015 Say OemToAnsi ("Arquivo: "+cArquivo)
@ 020, 015 Get cComent1 Valid !EMPTY(cComent1) SIZE 210, 040
@ 010, 235 BMPBUTTON TYPE 01 ACTION (cComent := cComent1,Close(oDlg2))
@ 024, 235 BMPBUTTON TYPE 02 ACTION (Close(oDlg2))
Activate Dialog oDlg2 Center
Return (cComent)

/*
	@ 010, 002 Say OemToAnsi ("Lin1")
	@ 024, 002 Say OemToAnsi ("Lin2")
	@ 010, 015 Get cLin1 Valid .T. SIZE 210, 040
	@ 024, 015 Get cLin2 Valid .T. SIZE 210, 040
	@ 010, 235 BMPBUTTON TYPE 01 ACTION MontaMsg ()
	@ 024, 235 BMPBUTTON TYPE 02 ACTION LimpaMsg ()
*/
