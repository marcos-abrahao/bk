#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFATA1A
BK - Funcao gravar Informações do Faturamento na NF de saida
@Return
@author Adilson do Prado
@since 11/06/15
@version P12
/*/
//-------------------------------------------------------------------

User Function BKFATA1A()
Private cString   := "SF2"
Private cCadastro := "Documentos de saída"
Private aRotina

dbSelectArea("SF2")
dbSetOrder(1)
DbGoTop()

aRotina := {{"Pesquisar"   ,"AxPesqui"	,0, 1},;
			{"Visualizar"  ,"AxVisual"	,0, 2},;
			{"Alterar Inf.","U_BKFATA01",0, 5}}
//	{"Abrir Arq.","U_KK00007A()",0, 6}}

mBrowse(6,1,22,75,cString)

Return


User Function BKFATA01()
Local aAreaAtu := GetArea()
Local aButtons := {}
Local lOk      := .F.
Local nSnd     := 0
Local nTLin    := 15
Local cSerie   := SF2->F2_SERIE
Local cNotaI   := SF2->F2_DOC
Local cNotaF   := SF2->F2_DOC
Local dEmisI   := SF2->F2_EMISSAO
Local dEmisF   := SF2->F2_EMISSAO
Local dEnvNF   := SF2->F2_XXENVNF
Local dEnvDOC  := SF2->F2_XXENDOC
Local cOBS     := SF2->F2_XXOBSFA
Local aUser    := {}
Local cNomUser := ""
Local cUser    := __cUserId
Local aCamposF2:= {}
Local aStruct1 := {}

Local nI       := 0
Local oDlg01
Local oPanelTop 
Local oMark
Local lInverte := .F.

Private cTitulo     := ""
Private cAliasTmp1  := GetNextAlias()
Private cAliasTmp2  := GetNextAlias()
Private cMarca      := GetMark()
Private cPerg       := "BKFATA01"

PswOrder(1) 
PswSeek(cUser) 
aUser  := PswRet(1)
IF !EMPTY(aUser)
	cNomUser := aUser[1,2]
ENDIF

Aadd( aButtons, {"EXCEL", {|| ExpExcel()}, "Gera Excel", "Gera Excel" , {|| .T.}} )

cTitulo  := "Informações - Faturamento | Usuário: "+cNomUser

AjustaSx1(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
EndIf

cSerie   := mv_par01
cNotaI   := mv_par02
cNotaF   := mv_par03
dEmisI   := mv_par04
dEmisF   := mv_par05

AADD(aCamposF2,{"F2_OK"      ,,"  ",""})
AADD(aStruct1 ,{"F2_OK","C",2,0})

AADD(aCamposF2,{"F2_DOC"     ,,RetTitle("F2_DOC"),"@X"})
AADD(aStruct1, {"F2_DOC","C" ,GetSx3Cache("F2_DOC", "X3_TAMANHO"),0})

AADD(aCamposF2,{"F2_EMISSAO"  ,,RetTitle("F2_EMISSAO"),""})
AADD(aStruct1, {"F2_EMISSAO"  ,"D",8,0})

AADD(aCamposF2,{"F2_FATURIS" ,,"Responsável"})
AADD(aStruct1, {"F2_FATURIS" ,"C" ,20,0})

AADD(aStruct1, {"F2_XXUSFAT" ,"C" ,GetSx3Cache("F2_XXUSFAT", "X3_TAMANHO"),0})

//AADD(aCamposF2,{"F2_XXCONTR" ,,RetTitle("C5_MDCONTR"),"@X"})
AADD(aStruct1, {"F2_XXCONTR","C" ,GetSx3Cache("C5_MDCONTR", "X3_TAMANHO"),0})

AADD(aCamposF2,{"F2_XXDESCR" ,,"Contrato","@X"})
AADD(aStruct1, {"F2_XXDESCR","C" ,GetSx3Cache("CTT_DESC01", "X3_TAMANHO"),0})

AADD(aCamposF2,{"F2_USERLGI" ,,RetTitle("F2_USERLGI"),"@X"})
AADD(aStruct1, {"F2_USERLGI" ,"C" ,GetSx3Cache("F2_USERLGI", "X3_TAMANHO"),0})

AADD(aCamposF2,{"F2_XXENVNF" ,,RetTitle("F2_XXENVNF"),"@X"})
AADD(aStruct1, {"F2_XXENVNF" ,"D",8,0})

AADD(aCamposF2,{"F2_XXENDOC" ,,RetTitle("F2_XXENDOC"),""})
AADD(aStruct1, {"F2_XXENDOC" ,"D",8,0})

AADD(aCamposF2,{"F2_XXOBSFA" ,,RetTitle("F2_XXOBSFA"),"@X"})
AADD(aStruct1, {"F2_XXOBSFA","C" ,GetSx3Cache("F2_XXOBSFA", "X3_TAMANHO"),0})

AADD(aStruct1, {"F2_XXRECNO","N" ,12,0})

//cArqTmp1 := CriaTrab(aStruct1)
//dbUseArea(.T.,,cArqTmp1,cAliasTmp1,if(.F. .OR. .F.,!.F., NIL),.F.)
//IndRegua (cAliasTmp1,cArqTmp1,"F2_DOC",,,OemToAnsi("Selecionando Registros...") )  //
//dbSetOrder(1)

oTmpTb := FWTemporaryTable():New( cAliasTmp1 ) 
oTmpTb:SetFields( aStruct1 )
oTmpTb:AddIndex("indice1", {"F2_DOC"} )
oTmpTb:Create()


dbSelectArea("SF2")
dbSetOrder(1)// F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, R_E_C_N_O_, D_E_L_E_T_
DbSeek(xFilial("SF2")+cNotaI+cSerie,.T.)	

dEnvNF   := SF2->F2_XXENVNF
dEnvDOC  := SF2->F2_XXENDOC
cOBS     := SF2->F2_XXOBSFA

cQuery := "SELECT"
cQuery += " SF2.R_E_C_N_O_ AS F2RECNO,"
cQuery += " (SELECT TOP 1 C5_MDCONTR FROM "+RETSQLNAME("SC6")+ " SC6 INNER JOIN "+RETSQLNAME("SC5")+" SC5 ON C6_FILIAL = '"+xFilial("SC6")+ "' AND C5_FILIAL = C6_FILIAL AND C6_NUM = C5_NUM AND C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ') AS F2_XXCONTR,"
cQuery +=  "(SELECT TOP 1 C5_ESPECI1 FROM "+RETSQLNAME("SC6")+ " SC6 INNER JOIN "+RETSQLNAME("SC5")+" SC5 ON C6_FILIAL = '"+xFilial("SC6")+ "' AND C5_FILIAL = C6_FILIAL AND C6_NUM = C5_NUM AND C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC AND SC6.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ = ' ') AS F2_XXESPEC"
cQuery += " FROM "+RETSQLNAME("SF2")+" SF2"
cQuery += " WHERE" 
cQuery += "   SF2.D_E_L_E_T_ <> '*' "
If !EMPTY(cSerie)
	cQuery += " AND SF2.F2_SERIE = '"+cSerie+"'"
EndIf
If !EMPTY(cNotaI)
	cQuery += " AND SF2.F2_DOC >= '"+cNotaI+"'"
EndIf
If !EMPTY(cNotaF) 
	cQuery += " AND SF2.F2_DOC <= '"+cNotaF+"'"
EndIf
If !EMPTY(dEmisI)
	cQuery += " AND SF2.F2_EMISSAO >= '"+DTOS(dEmisI)+"'"
EndIf
If !EMPTY(dEmisF)
	cQuery += " AND SF2.F2_EMISSAO <= '"+DTOS(dEmisF)+"'"
EndIf


MsAguarde({|| nI := ProcQuery(cQuery)},"Aguarde","Selecionando documentos...",.F.)

If nI == 0
	oTmpTb:Delete() 
	(cAliasTmp2)->( dbCloseArea() )

	RestArea( aAreaAtu )
	MsgStop("Documentos não encontrados para este usuário")
	Return Nil
EndIf
	
//U_QryToXml(cAliasTmp1,cPerg,cTitulo,.F.)

(cAliasTmp1)->( dbGotop() )

////////////
//MONTA TELA INFORMACAO DO FATURAMENTO
////////////

oMainWnd:ReadClientCoords()  
Define MsDialog oDlg01 Title cTitulo FROM oMainWnd:nTop+20,oMainWnd:nLeft+5 To oMainWnd:nBottom-30,oMainWnd:nRight-35 Of oMainWnd Pixel

oPanelTop:= TPanel():New(0, 0, Nil, oDlg01, Nil, .T., .F., Nil, Nil, 0, 60, .T., .F. )
oPanelTop:Align := CONTROL_ALIGN_TOP

nSnd := 10

@ nSnd,010 Say "Data de Envio da Nota Fiscal:" Size 080,008 Pixel Of oPanelTop
@ nSnd,100 MsGet dEnvNF Picture "@E"           Size 050,008 Pixel Of oPanelTop
@ nSnd,155 BUTTON "Aplicar" SIZE 40,10 Pixel Of oPanelTop ACTION AltCpo(cAliasTmp1,1,dEnvNF)

nSnd += nTLin

@ nSnd,010 Say "Data de Envio da Documentação:" Size 080,008 Pixel Of oPanelTop
@ nSnd,100 MsGet dEnvDOC Picture "@E"           Size 050,008 Pixel Of oPanelTop
@ nSnd,155 BUTTON "Aplicar" SIZE 40,10 Pixel Of oPanelTop ACTION AltCpo(cAliasTmp1,2,dEnvDoc)

nSnd += nTLin

@ nSnd,010 Say "Observações:"               Size 080,008 Pixel Of oPanelTop
@ nSnd,100 MsGet cObs                       Size 190,008 Pixel Of oPanelTop
@ nSnd,300 BUTTON "Aplicar" SIZE 40,10 Pixel Of oPanelTop ACTION AltCpo(cAliasTmp1,3,cObs)

nSnd += nTLin


  // Alinha painel preenchendo toda a área
   // Neste exemplo este painel servirá de fundo
   //oPanelAll:= tPanel():New(0,0,"",oDlg01,,,,,CLR_GREEN,00,030)
   //oPanelAll:align:= CONTROL_ALIGN_ALLCLIENT
  
   // Alinha ao topo, veja que definimos apenas a altura
   // como o componente será alinhado ao topo sua largura
   // será exatamente a largura da janela
   //oPanelTop:= tPanel():New(0,0,"Top",oDlg01,,,,CLR_YELLOW,CLR_BLUE,00,030)
   //oPanelTop:align:= CONTROL_ALIGN_TOP
   
   // Alinha ao rodapé
   //oPanelBot:= tPanel():New(0,0,"Bottom",oDlg01,,,,,CLR_HRED,00,nSnd)
   //oPanelBot:align:= CONTROL_ALIGN_BOTTOM

   // Alinha à esquerda, veja que definimos apenas a largura
   // como o componente será alinhado à esquerda sua altura
   // será exatamente a altura da janela
   //oPanelLeft:= tPanel():New(0,0,"Left",oDlg01,,,,,CLR_YELLOW,030,000)
   //oPanelLeft:align:= CONTROL_ALIGN_LEFT

   // Alinha à direita
   //oPanelRight:= tPanel():New(0,0,"Right",oDlg01,,,,,CLR_YELLOW,030,000)
   //oPanelRight:align:= CONTROL_ALIGN_RIGHT


oMark := MsSelect():New(cAliasTmp1,"F2_OK","",aCamposF2,@lInverte,@cMarca,{0,2,0,0},,,oDlg01)


//oMark:bAval := {|| MarcaCpo(.F.)}
//oMark:oBrowse:lCanAllMark := .T.
//oMark:oBrowse:admin    := .T.
oMark:oBrowse:ALIGN		  := CONTROL_ALIGN_ALLCLIENT

//oMark:oBrowse:bAllMark := {|| MarcaCpo(.T.)}
//oMark:oBrowse:bChange := {|| MsgInfo("Teste"), oMark:oBrowse:Refresh()}

ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

If ( lOk )

	dbSelectArea(cAliasTmp1)
	DbGoTop()	
	While (cAliasTmp1)->(!EoF())
		If (cAliasTmp1)->F2_OK == cMarca
			nRecNo := (cAliasTmp1)->F2_XXRECNO
			dbSelectArea("SF2")
			dbGoto(nRecNo)
			RecLock("SF2",.F.)
			SF2->F2_XXENVNF  := (cAliasTmp1)->F2_XXENVNF
			SF2->F2_XXENDOC  := (cAliasTmp1)->F2_XXENDOC
			SF2->F2_XXOBSFA  := (cAliasTmp1)->F2_XXOBSFA
			If EMPTY(SF2->F2_XXUSFAT) .AND. cUser <> "000000"
				SF2->F2_XXUSFAT  := cUser
			EndIf
			msUnlock() 
		EndIf
		dbSelectArea(cAliasTmp1)
        dbSkip()
	ENDDO 
EndIf

oTmpTb:Delete() 
(cAliasTmp2)->( dbCloseArea() )

RestArea( aAreaAtu )

Return lOk


/*
Static Function MarcaCpo(lTodos) 
If lTodos
	MsgStop("Todos")
Else
	MsgStop("Atual")
EndIf
Return
*/

Static Function AltCpo(cAliasTmp,nCpo,xCpo)
Local nRecNo := 0
Local cSuper := ""
Local aUser  := {}

dbSelectArea(cAliasTmp)
nRecNo := RECNO()

dbGoTop()
Do While !eof()
	If (cAliasTmp1)->F2_OK == cMarca

	    cSuper := ""
		If !EMPTY((cAliasTmp)->F2_XXUSFAT)
			PswOrder(1) 
			PswSeek((cAliasTmp)->F2_XXUSFAT) 
			aUser  := PswRet(1)
			IF !EMPTY(aUser[1,11])
			   cSuper := SUBSTR(aUser[1,11],1,6)
			ENDIF   
		EndIf

	   	RecLock(cAliasTmp,.F.)
	    If nCpo == 1 .AND. ( EMPTY((cAliasTmp)->F2_XXENVNF) .OR. __cUserId == cSuper .OR. __cUserId == '000000') 
	    	(cAliasTmp)->F2_XXENVNF := xCpo
	    ElseIf nCpo == 2  .AND. ( EMPTY((cAliasTmp)->F2_XXENDOC) .OR. __cUserId == cSuper .OR. __cUserId == '000000') 
			(cAliasTmp)->F2_XXENDOC := xCpo
	    ElseIf nCpo == 3
			(cAliasTmp)->F2_XXOBSFA := xCpo
	    EndIf
	   	dbUnLock()
	EndIf   	
	dbSkip()
EndDo
If nRecNo = 0
	dbGoTop()
Else
	dbGoTo(nRecNo)
EndIf

Return Nil



Static Function ExpExcel(cPerg)
Local aDefs := {} // Campo,Formula,Titulo,Impr,Align,Format,Total

AADD(aDefs,{"F2_OK",,,.F.,,,})
AADD(aDefs,{"F2_FATURIS",,"Responsável",,,,})
AADD(aDefs,{"F2_XXUSFAT",,,.F.,,,})
AADD(aDefs,{"F2_USERLGI",,"Faturista",,,,})
AADD(aDefs,{"F2_XXRECNO",,,.F.,,,.F.})
AADD(aDefs,{"F2_XXDESCR",,"Contrato",,,,})
AADD(aDefs,{"F2_XXCONTR",,"C.Custo",,,,})

U_QryToXml(cAliasTmp1,cPerg,cTitulo,aDefs,,.F.)

Return (Nil)



Static Function ProcQuery(_cQuery)
Local cSuper := ""
Local nI     := 0
Local aUser  := {}

TCQUERY _cQuery NEW ALIAS (cAliasTmp2)

dbSelectArea(cAliasTmp2)
dbGoTop()
ProcRegua((cAliasTmp2)->(LASTREC()))

While (cAliasTmp2)->(!EoF())

	SF2->(dbGoTo( (cAliasTmp2)->F2RECNO))

    cSuper := ""
	If !EMPTY(SF2->F2_XXUSFAT)
		PswOrder(1) 
		PswSeek(SF2->F2_XXUSFAT) 
		aUser  := PswRet(1)
		IF !EMPTY(aUser[1,11])
		   cSuper := SUBSTR(aUser[1,11],1,6)
		ENDIF   
	EndIf
	
//	If !EMPTY(SF2->F2_XXUSFAT) .AND. SF2->F2_XXUSFAT <> __cUserId  .AND. __cUserId <> '000000' .AND.  __cUserId <> cSuper
		//MSGSTOP("Usuário não pode alterar!! Informações incluida por: "+cNomUser+"    NF: "+SF2->F2_DOC)
//	Else
		RecLock( cAliasTmp1, .T. )
		//(cAliasTmp1)->F2_OK       := cMarca 
		(cAliasTmp1)->F2_DOC      := SF2->F2_DOC 
		(cAliasTmp1)->F2_EMISSAO  := SF2->F2_EMISSAO 
		(cAliasTmp1)->F2_XXENVNF  := SF2->F2_XXENVNF
		(cAliasTmp1)->F2_XXENDOC  := SF2->F2_XXENDOC
		(cAliasTmp1)->F2_XXOBSFA  := SF2->F2_XXOBSFA
		(cAliasTmp1)->F2_FATURIS  := U_Buser(SF2->F2_XXUSFAT) 
		(cAliasTmp1)->F2_XXUSFAT  := SF2->F2_XXUSFAT 
		(cAliasTmp1)->F2_USERLGI  := FWLeUserlg("F2_USERLGI", 1)
		(cAliasTmp1)->F2_XXCONTR  := IIF(EMPTY((cAliasTmp2)->F2_XXCONTR),(cAliasTmp2)->F2_XXESPEC,(cAliasTmp2)->F2_XXCONTR)
		(cAliasTmp1)->F2_XXDESCR  := ALLTRIM(Posicione("CTT",1,xFilial("CTT")+(cAliasTmp1)->F2_XXCONTR,"CTT_DESC01"))
		(cAliasTmp1)->F2_XXRECNO  := SF2->(RECNO())
		dbUnlock()
	    nI++
//	EndIf

	dbSelectArea(cAliasTmp2)
	dbSkip()
Enddo
Return nI



Static Function AjustaSX1(cPerg)
Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Série:"		      ,"","","mv_ch1" ,"C",03,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"S","",""})
AADD(aRegistros,{cPerg,"02","Nota Fiscal inicial:","","","mv_ch2" ,"C",09,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SF2","S","",""})
AADD(aRegistros,{cPerg,"03","Nota Fiscal final:"  ,"","","mv_ch3" ,"C",09,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SF2","S","",""})
AADD(aRegistros,{cPerg,"04","Emissão de:"         ,"","","mv_ch4" ,"D",08,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"S","",""})
AADD(aRegistros,{cPerg,"05","Emissão até:"        ,"","","mv_ch5" ,"D",08,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"S","",""})

//AADD(aRegistros,{cPerg,"01","Data Digitação de :"  ,"Data Digitação de :" ,"Data Digitação de :" ,"mv_ch1","D",08,0,0,"G","NaoVazio()","mv_par01","","","        ","","","","","","","","","","","","","","","","","","","","","","","S","",""})
//          PutSx1(cPerg,"01","Série:"		       ,""                    ,""                    ,"mv_ch1","C",03,0,0,"G",""          ,""		 ,"","","MV_PAR01","","","","","","","","","","","","","","","","",)

For i:=1 to Len(aRegistros)
	If !dbSeek(cPerg+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegistros[i])
				FieldPut(j,aRegistros[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(aArea)

Return (Nil)





/*
Rotina do Adilson

User Function BKFATA01()
Local aAreaAtu	:= GetArea()
Local oDlg01,aButtons := {},lOk := .F.
Local nSnd    := 0,nTLin := 15
Local nSin    := 0
Local cSERIE  := SF2->F2_SERIE
Local cNOTAI  := SF2->F2_DOC
Local cNOTAF  := SF2->F2_DOC
Local dEnvNF  := SF2->F2_XXENVNF
Local dEnvDOC := SF2->F2_XXENDOC
Local cOBS    := SF2->F2_XXOBSFA
Local aUser   := {}
Local cNomUser  := ""
Local cUser   := IIF(!EMPTY(SF2->F2_XXUSFAT),SF2->F2_XXUSFAT,__cUserId)

PswOrder(1) 
PswSeek(cUser) 
aUser  := PswRet(1)
IF !EMPTY(aUser)
	cNomUser := aUser[1,2]
ENDIF

////////////
//MONTA TELA INFORMACAO DO FATURAMENTO
////////////
  
Define MsDialog oDlg01 Title "Informações - Faturamento | Usuário: "+cNomUser From 000,000 To 240+(nSin*nTLin),600 Of oDlg01 Pixel

nSnd := 15

@ nSnd,010 Say "Nota Fiscal de:"                  Size 080,008 Pixel Of oDlg01
@ nSnd,100 MsGet cNOTAI                       Size 050,008 Pixel Of oDlg01
nSnd += nTLin

@ nSnd,010 Say "Nota Fiscal até:"                  Size 080,008 Pixel Of oDlg01
@ nSnd,100 MsGet cNOTAF                       Size 050,008 Pixel Of oDlg01
nSnd += nTLin

@ nSnd,010 Say "Data de Envio da Nota Fiscal:" Size 080,008 Pixel Of oDlg01
@ nSnd,100 MsGet dEnvNF Picture "@E"            Size 050,008 Pixel Of oDlg01
nSnd += nTLin

@ nSnd,010 Say "Data de Envio da Documentação:" Size 080,008 Pixel Of oDlg01
@ nSnd,100 MsGet dEnvDOC Picture "@E"            Size 050,008 Pixel Of oDlg01
nSnd += nTLin

@ nSnd,010 Say "Observações:"                  Size 080,008 Pixel Of oDlg01
@ nSnd,100 MsGet cOBS                       Size 190,008 Pixel Of oDlg01
nSnd += nTLin

ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

If ( lOk )

	dbSelectArea("SF2")
	dbSetOrder(1)// F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_FORMUL, R_E_C_N_O_, D_E_L_E_T_
	DbSeek(xFilial("SF2")+cNOTAI+cSERIE,.T.)	
	While SF2->(!EoF()) .AND. SF2->F2_FILIAL == xFilial("SF2") .AND. SF2->F2_SERIE == cSerie .AND. SF2->F2_DOC >= cNOTAI .AND. SF2->F2_DOC <= cNOTAF
		IF 	!EMPTY(SF2->F2_XXUSFAT) .AND. SF2->F2_XXUSFAT <> __cUserId  .AND. __cUserId <> '000000'
			MSGSTOP("Usuário não pode alterar!! Informações incluida por: "+cNomUser+"    NF: "+SF2->F2_DOC)
		ELSE
			RecLock("SF2",.F.)
			SF2->F2_XXENVNF  := dEnvNF
			SF2->F2_XXENDOC  := dEnvDOC
			SF2->F2_XXOBSFA  := cOBS
			SF2->F2_XXUSFAT  := cUser
			msUnlock() 
        ENDIF
        SF2->(DBSKIP())
	ENDDO 
EndIf

RestArea( aAreaAtu )

Return lOk

*/
