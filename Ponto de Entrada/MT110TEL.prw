#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MT110TEL
BK - Funções da Solicitação de Compras responsáveis por manipular o cabeçalho 
     da Solicitação de Compras permitindo a inclusão e alteração de campos.
@Return
@author Adilson do Prado
@since 29/10/2015
@version P12
/*/

USER FUNCTION MT110TEL
Local oNewDialog := PARAMIXB[1]
Local aPosGet    := PARAMIXB[2]
Local nOpcx      := PARAMIXB[3]
//Local nReg       := PARAMIXB[4]
Local aMTCM		 := {}
Local nPQEST	 := 0
Local nLin       := 0
Local nC 		 := 0

Public dDATPRF 	 := CTOD("")
Public cXXMTCM 	 := Space(TamSX3("C1_XXMTCM")[1])    
Public cCC		 := Space(TamSX3("C1_CC")[1])    
Public cXXDCC	 := Space(TamSX3("C1_XXDCC")[1])
Public cXXJUST	 := Space(TamSX3("C1_XXJUST")[1]) 
Public cXXENDEN  := Space(TamSX3("C1_XXENDEN")[1])

If cEmpAnt == '20'


EndIf

IF TYPE("lCopia") == "U"
	lCopia  := .F.
ENDIF

aMTCM := U_StringToArray(GetSx3Cache("C1_XXMTCM", "X3_CBOX"),";") 

//aadd(aPosGet[1],0) 
//aadd(aPosGet[1],0)

IF nOpcx <> 3
	dDATPRF	 := SC1->C1_DATPRF
	cXXMTCM  := SC1->C1_XXMTCM    
	cCC		 := SC1->C1_CC    
	cXXDCC	 := SC1->C1_XXDCC
	cXXJUST  := SC1->C1_XXJUST
	cXXENDEN := SC1->C1_XXENDEN
ENDIF 

// Não copiar data prevista de entrega - 04/02/16   
IF lCopia
	dDATPRF	 := CTOD("")
	nPQEST   := aScan(aHeader, {|x| AllTrim(x[2]) == "C1_XXQEST"})
	FOR nC:= 1 TO LEN(aCols)
		aCols[nC][nPQEST] := 0
	NEXT
ENDIF

nLin := 63

@ nLin,aPosGet[1,1] SAY 'Limite Entrega' PIXEL SIZE 50,10 Of oNewDialog
@ nLin,aPosGet[1,2] MSGET dDATPRF PIXEL SIZE 50,10 Of oNewDialog    

//@ nLin,aPosGet[1,3] SAY 'Endereço Entrega' PIXEL SIZE 50,10 Of oNewDialog

@ nLin,aPosGet[1,3]  SAY 'Centro Custo' PIXEL SIZE 50,10 Of oNewDialog
@ nLin,aPosGet[1,4]  MSGET cCC PIXEL SIZE 50,10 Of oNewDialog  F3 "CTT" VALID(Vazio(cCC) .Or. Ctb105CC(),cXXDCC:= CTT->CTT_DESC01)  

@ nLin,aPosGet[1,5]  SAY 'Descr C.Custo' PIXEL SIZE 50,10 Of oNewDialog
@ nLin,aPosGet[1,6]  MSGET cXXDCC PIXEL SIZE 100,10 Of oNewDialog WHEN .F. 

nLin += 15

@ nLin,aPosGet[1,1]  SAY 'Motivo da Compra' PIXEL SIZE 50,10 Of oNewDialog
@ nLin,aPosGet[1,2]  COMBOBOX cXXMTCM  ITEMS aMTCM SIZE 100,010 Pixel Of oNewDialog  VALID(Pertence("123"))

oTButton1 := TButton():New( nLin, aPosGet[1,3], "Endereço de entrega",oNewDialog,{||cXXENDEN := u_SelEndEnt(cCC)}, 65,11,,,.F.,.T.,.F.,,.F.,,,.F. ) 
@ nLin,aPosGet[1,4] MSGET cXXENDEN PICT "@!" PIXEL SIZE 200,10 Of oNewDialog    
//SButton():New( nLin,aPosGet[1,4]+55,15,{||cXXENDEN := u_SelEndEnt()},oNewDialog,.T.,,) 

nLin += 15

@ nLin,aPosGet[1,1] SAY 'Justificativa' PIXEL SIZE 50,10 Of oNewDialog
oMemo:= tMultiget():New(nLin,aPosGet[1,2],{|u|if(Pcount()>0,cXXJUST:=u,cXXJUST)},oNewDialog,250,20,,,,,,.T.,,,/*bwhen*/,,,,{|| VldJust()}) 

RETURN


Static Function VldJust()
Local lRet := .T.
If Empty(cXXJUST)
	u_MsgLog("MT110TEL","Preencha a justificativa","E")
	lRet := .F.
EndIf
Return lRet


 
//Manipula as dimensões do cabeçalho da S.C
User Function MT110GET() 
Local aRet:= PARAMIXB[1] 

aRet[2,1] := 115
aRet[1,3] := 145 

Return(aRet)



//Grava o campo do cabeçalho da S.C
User Function MT110GRV(cObserv) 
RecLock('SC1',.F.) 
SC1->C1_XXJUST  := cXXJUST
SC1->C1_XXENDEN := UPPER(cXXENDEN)
SC1->(MsUnlock()) 
Return 
 

User Function SelEndEnt(cCC)
Local aCoordAdms    := MsAdvSize(.T.)  //Vetor com as coordenadas da tela
Local oDlgSel       := Nil
Local oListSel      := Nil
Local cMsgTela 		:= "Selecione o Endereço de Entrega"
Local cRet 			:= ""
Local aListSel 		:= {}
Local cEnd1 		:= ""

aListSel := QryCtt()

//dbSelectArea("CN9")
If CTT->(dbSeek(xFilial("CTT")+cCC,.F.))
	If !Empty(CTT->CTT_XENDEN)
		cEnd1 := CTT->CTT_XENDEN
	EndIf
EndIf
If Empty(cEnd1)
	If CN9->(dbSeek(xFilial("CN9")+cCC,.F.))
		//dbSelectArea("SA1")
		If SA1->(dbSeek(xFIlial("SA1")+CN9->CN9_XCLIEN+CN9->CN9_XLOJA,.F.))
			cEnd1 := ALLTRIM(SA1->A1_END)+" "+Rtrim(SA1->A1_MUN)+" - "+SA1->A1_EST+" "+Trans(Alltrim(SA1->A1_CEP),PesqPict("SA1","A1_CEP"))
		EndIf
	EndIf
EndIf
If !Empty(cEnd1)
	aSize(aListSel, Len(aListSel) + 1)
	aIns(aListSel, 1)
	aListSel[1] := {cEnd1}
EndIf


oDlgSel := TDialog():New(000,000,aCoordAdms[6]/2,aCoordAdms[5]/2,cMsgTela,,,,,,,,oMainWnd,.T.)
//TSay():New(005,003,{|| cMsgTela },oDlgSel,,,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,oDlgSel:nClientWidth/2-7,008)
TGroup():New(015,003,oDlgSel:nClientHeight/2-30,oDlgSel:nClientWidth/2-7,"Localidades",oDlgSel,,,.T.,.F. )

oListSel := TWBrowse():New(025,005,oDlgSel:nClientWidth/2-15,oDlgSel:nClientHeight/2-58,,{"Endereço"},,oDlgSel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

oListSel:SetArray(aListSel)
oListSel:bLDblClick := {||	cRet := aListSel[oListSel:nAt][1],oDlgSel:End()}

oListSel:bLine := {||{ aListSel[oListSel:nAt][1] }}
//		TButton():New(oDlgSel:nClientHeight/2-27,003,OemToAnsi("&Ok"),oDlgSel,{|| oDlgSel:End() },040,010,,,,.T.,,,,{|| })
oDlgSel:Activate(,,,.T.)

//u_MsgLog("SelEndEnt",cRet)

Return cRet


Static Function QryCtt()
Local cQuery        := ""
Local aReturn       := {}
Local aBinds        := {}
Local aSetFields    := {}
Local nRet          := 0

cQuery += "SELECT CTT_XENDEN"+CRLF 
cQuery += " FROM "+RetSQLName("CTT")+ " CTT" +CRLF
cQuery += " WHERE D_E_L_E_T_ = ' ' "+CRLF
cQuery += " GROUP BY CTT_XENDEN ORDER BY CTT_XENDEN"

//aadd(aBinds,xFilial("SA1")) // Filial

// Ajustes de tratamento de retorno
aadd(aSetFields,{"CTT_XENDEN"   ,"C",60,0})

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

If nRet < 0
  u_MsgLog("ArSubord",tcsqlerror()+" - Falha ao executar a Query: "+cQuery,"E")
Endif

Return aReturn
