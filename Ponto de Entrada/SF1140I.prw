#include "protheus.ch"
#include "rwmake.ch"


/*/{Protheus.doc} SF1140I
BK - Ponto de entrada para gravar UserId e Superior
19/11/19 - Marcos B Abrah�o - Gravar dados de pagamento
@Return
@author Marcos Bispo Abrah�o
@since 19/11/2009 
@version P12
/*/

User Function SF1140I()

Private cxTipoPg := SF1->F1_XTIPOPG
Private cxNumPa  := SF1->F1_XNUMPA
Private cxBanco  := SF1->F1_XBANCO
Private lxP1PA   := IIF(SF1->F1_XXP1PA=='S',.T.,.F.)
Private cxAgencia:= SF1->F1_XAGENC
Private cxConta  := SF1->F1_XNUMCON
Private cChvNfe  := SF1->F1_CHVNFE
Private dPrvPgt  := SF1->F1_XXPVPGT
Private cJsPgt	 := SF1->F1_XXJSPGT
Private cxTpPix  := SF1->F1_XXTPPIX
Private cxChPix  := SF1->F1_XXCHPIX
Private nTipoPg  := 0
Private cEspecie := SF1->F1_ESPECIE
Private cxCond	 := SF1->F1_COND
Private mParcel  := SF1->F1_XXPARCE
Private dCompet  := IIF(EMPTY(SF1->F1_XXCOMPD),SF1->F1_DTDIGIT,SF1->F1_XXCOMPD)
Private cLibF1   := "A"
Private cCnpj    := Posicione("SA2",1,Xfilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_CGC")

// 2 Etapas

If u_InGrupo(__cUserId,"000000/000007/000038/000005/000031/000037")
	cLibF1   := "A"
Else 
	cLibF1   := "9"
EndIf
//cLibF1   := "A" // Remover


If Empty(cxBanco)
	u_GetSa2(SF1->F1_FORNECE,SF1->F1_LOJA)
EndIf

If Empty(SF1->F1_XXUSER) //.OR. !u_InGrupo(__cUserID,"000000/000031")
	RecLock("SF1",.F.)
	SF1->F1_XXUSER  := __cUserId
	If Empty(SF1->F1_XXUSERS)
		SF1->F1_XXUSERS := u_cSuper1(__cUserID)
	EndIf
	MsUnLock("SF1")
EndIf

If Empty(SF1->F1_XXCOMPD)
	RecLock("SF1",.F.)
	SF1->F1_XXCOMPD := dCompet
	MsUnLock("SF1")
EndIf

If !l140Auto
	U_SelFPgto(.T.,u_SemAnexo(__cUserId),@cLibF1)
	If u_IsAvalPN(__cUserID)
		If u_MsgLog("SF1140I","Deseja avaliar este fornecedor?","Y")
			u_AvalForn(.F.)
		EndIf
	EndIf
EndIf

RecLock("SF1",.F.)
SF1->F1_XTIPOPG := cxTipoPg
SF1->F1_XNUMPA  := cxNumPa
SF1->F1_XXP1PA  := IIF(lxP1PA,'S','N')
If ALLTRIM(cxTipoPg) == "DEPOSITO"
	SF1->F1_XBANCO  := cxBanco
	SF1->F1_XAGENC  := cxAgencia
	SF1->F1_XNUMCON := cxConta
Else
	SF1->F1_XBANCO  := " "
	SF1->F1_XAGENC  := " "
	SF1->F1_XNUMCON := " "
EndIf
SF1->F1_CHVNFE  := cChvNfe
SF1->F1_XXPVPGT := dPrvPgt
SF1->F1_XXJSPGT := cJsPgt
SF1->F1_COND	:= cxCond
SF1->F1_XXPARCE := mParcel
If ALLTRIM(cxTipoPg) == "PIX"
	SF1->F1_XXTPPIX := cxTpPix
	SF1->F1_XXCHPIX := cxChPix
Else
	SF1->F1_XXTPPIX := ""
	SF1->F1_XXCHPIX := ""
EndIf
SF1->F1_XXCOMPD := dCompet

// Limpar dados de Libera��o
SF1->F1_XXLIB   := cLibF1
SF1->F1_XXULIB  := " "
SF1->F1_XXDLIB  := " "
SF1->F1_XXDINC  := DtoC(Date())+"-"+Time()

MsUnLock("SF1")

If nTipoPg == 1 
	If !u_IsFornBK(SF1->F1_FORNECE)
		PutSa2(SF1->F1_FORNECE,SF1->F1_LOJA)
	EndIf
ElseIf nTipoPg == 7
	PutF72(SF1->F1_FORNECE,SF1->F1_LOJA,cxTpPix,cxChPix)
EndIf

u_MsgLog("SF1140I",iIf(Inclui,"Doc incluido: ","Doc alterado: ")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+" "+SF1->F1_ESPECIE)
	
Return .T.


User Function AltFPgto
Local lAlt := .T.
Private cxTipoPg := SF1->F1_XTIPOPG
Private cxNumPa  := SF1->F1_XNUMPA
Private cxBanco  := SF1->F1_XBANCO
Private lxP1PA   := IIF(SF1->F1_XXP1PA=='S',.T.,.F.)
Private cxAgencia:= SF1->F1_XAGENC
Private cxConta  := SF1->F1_XNUMCON
Private cChvNfe  := SF1->F1_CHVNFE
Private dPrvPgt  := SF1->F1_XXPVPGT
Private cJsPgt	 := SF1->F1_XXJSPGT
Private cxTpPix  := SF1->F1_XXTPPIX
Private cxChPix  := SF1->F1_XXCHPIX
Private nTipoPg  := 0
Private cEspecie := SF1->F1_ESPECIE
Private cxCond	 := SF1->F1_COND
Private mParcel	 := SF1->F1_XXPARCE
Private dCompet  := IIF(EMPTY(SF1->F1_XXCOMPD),SF1->F1_DTDIGIT,SF1->F1_XXCOMPD)
Private cLibF1   := "A"
Private cCnpj    := Posicione("SA2",1,Xfilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA,"A2_CGC")

// 2 Etapas
If u_InGrupo(__cUserId,"000000/000007/000038/000005/000031/000037")
	cLibF1   := "A"
Else 
	cLibF1   := "9"
EndIf
//cLibF1   := "A" // Remover

If SF1->F1_XXLIB $ "9AE " .AND. Empty(SF1->F1_STATUS)
	lAlt := .T.
Else
	lAlt := .F.
Endif

If U_SelFPgto(lAlt,.T.,@cLibF1)
	RecLock("SF1",.F.)
	SF1->F1_XTIPOPG := cxTipoPg
	SF1->F1_XNUMPA  := cxNumPa
	SF1->F1_XXP1PA  := IIF(lxP1PA,'S','N')
	SF1->F1_XBANCO  := cxBanco
	SF1->F1_XAGENC  := cxAgencia
	SF1->F1_XNUMCON := cxConta
	SF1->F1_CHVNFE  := cChvNfe
	SF1->F1_XXPVPGT := dPrvPgt
	SF1->F1_XXJSPGT := cJsPgt
	SF1->F1_COND	:= cxCond
	SF1->F1_XXPARCE := mParcel
	If ALLTRIM(cxTipoPg) == "PIX"
		SF1->F1_XXTPPIX := cxTpPix
		SF1->F1_XXCHPIX := cxChPix
	Else
		SF1->F1_XXTPPIX := ""
		SF1->F1_XXCHPIX := ""
	EndIf

	SF1->F1_XXCOMPD := dCompet

	If Empty(SF1->F1_XXLIB) .AND. Empty(SF1->F1_STATUS)
		SF1->F1_XXLIB := cLibF1
	EndIf

	MsUnLock("SF1")

	If nTipoPg == 1 
		If SF1->F1_FORNECE <> u_cFornBK() .AND. SF1->F1_FORNECE <> u_ForFolBK()
			PutSa2(SF1->F1_FORNECE,SF1->F1_LOJA)
		EndIf
	ElseIf nTipoPg == 7
		PutF72(SF1->F1_FORNECE,SF1->F1_LOJA,cxTpPix,cxChPix)
	EndIf
	
EndIf

Return Nil


User Function SelFPgto(lAlt,lEsc,cLibF1)
Local aOpcoes   := {}
Local oRadMenu1
Local oSay1
Local bClickP
Local lAnexo 	:= .F.
Local lRet 		:= .T.
Local aCabecalho:= {}
Local aaCampos	:= {"PARC","VENCTO","VALOR"} //Vari�vel contendo o campo edit�vel no Grid
Local nValTot	:= 0
//Local aGrp 		:= UsrRetGrp()
Local aTpPix    := U_StringToArray(GetSx3Cache("F72_TPCHV", "X3_CBOX"),";") 
Local dDigit 	:= SF1->F1_DTDIGIT

Static oDlg3

Default lAlt 		:= .T.
Default lEsc 		:= .F.

Private nRadMenu1	:= 1
Private dValid 		:= dDataBase
Private oGetBco,oGetAge,oGetCon,oGetPA,oGetChv,oGetCond,oSaySE4,oGetCompet,oGetDigit,oGetJsPgt,oLista,oP1PA
Private oCmbTpPix,oGetChPix
Private cDescrSE4	:= Posicione("SE4",1,xFilial("SE4")+cxCond,"E4_DESCRI")
Private aDados		:= {}

// 2 Etapas
If u_InGrupo(__cUserId,"000000/000007/000038/000005/000031/000037")
	cLibF1  := "A"
	If u_InGrupo(__cUserId,"000000/000031")
		lAlt 	:= .T.
		lEsc 	:= .T.
	EndIf
Else 
	cLibF1  := "9"
EndIf
//cLibF1   := "A" // Remover
nValTot := CalcTot()

If FWIsInCallStack("GERADOCE")
	// Pegar os campos das varivei private, pois via autocab n�o vem
	cxTipoPg := ycxTipoPg 
	cxNumPa  := ycxNumPa  
	cxBanco  := ycxBanco  
	lxP1PA   := ylxP1PA   
	cxAgencia:= ycxAgencia
	cxConta  := ycxConta  
	cChvNfe  := ycChvNfe  
	dPrvPgt  := ydPrvPgt  
	cJsPgt	 := ycJsPgt
	cxTpPix  := ycxTpPix  
	cxChPix  := ycxChPix  
	nTipoPg  := ynTipoPg  
	cEspecie := ycEspecie 
	cxCond	 := ycxCond
	//mParcel  := ymParcel 
EndIf

If Empty(dCompet)
	dCompet := dDataBase
EndIf

If Empty(cxCond)
	cxCond := "092" // 3 dias
EndIf

dValid := DataValida(dValid+1,.T.)
dValid := DataValida(dValid+1,.T.)
dValid := DataValida(dValid+1,.T.)

aadd(aOpcoes,"DEPOSITO")   //01
aadd(aOpcoes,"CARTAO")     //02
aadd(aOpcoes,"BOLETO")     //03
aadd(aOpcoes,"P.A.")       //04
aadd(aOpcoes,"FUNDO FIXO") //05
aadd(aOpcoes,"CHEQUE")     //06
aadd(aOpcoes,"PIX")        //07

nRadMenu1 := ASCAN(aOpcoes,ALLTRIM(cxTipoPg))
If nRadMenu1 = 0
	nRadMenu1 := 1
EndIf

aCabecalho	:= u_a103Cab()
nColDel 	:= Len(aCabecalho)+1
u_a103Load()

DEFINE MSDIALOG oDlg3 TITLE "Dados Fiscais e Financeiros: "+SF1->F1_SERIE+" "+SF1->F1_DOC STYLE DS_MODALFRAME FROM 000,000 TO 520,550 COLORS 0, 16777215 PIXEL
oDlg3:lEscClose := .F.

bClickP	:= { || ChangePgt(nRadMenu1) }
oRadMenu1:= tRadMenu():New(20,10,aOpcoes,{|u|if(PCount()>0,nRadMenu1:=u,nRadMenu1)}, oDlg3,,bClickP,,,,,,70,130,,,,.T.)

@ 010,010 SAY oSay1 PROMPT "Forma de pagamento :" SIZE 091, 007 OF oDlg3 COLORS 0, 16777215 PIXEL

@ 022,055 SAY "Banco" 	 OF oDlg3 PIXEL
@ 020,085 MSGET oGetBco VAR cxBanco   OF oDlg3 PICTURE "@!" PIXEL WHEN (nRadMenu1==1 .AND. lAlt) Valid (!lRet .OR. IIf(nRadMenu1==1,VAL(cxBanco) > 0,.T.))
@ 022,110 SAY "Ag�ncia"  OF oDlg3 PIXEL
@ 020,135 MSGET oGetAge VAR cxAgencia OF oDlg3 PICTURE "@!" PIXEL WHEN (nRadMenu1==1 .AND. lAlt) Valid (!lRet .OR. IIf(nRadMenu1==1,!Empty(cxAgencia),.T.))
@ 022,170 SAY "Conta"  	 OF oDlg3 PIXEL
@ 020,190 MSGET oGetCon VAR cxConta   OF oDlg3 PICTURE "@!" SIZE 60,10 PIXEL WHEN (nRadMenu1==1 .AND. lAlt) Valid (!lRet .OR. IIf(nRadMenu1==1,!Empty(cxConta),.T.))

@ 045,055 MSGET oGetPA VAR cxNumPa	  OF oDlg3 PICTURE "@!" PIXEL WHEN ((nRadMenu1==4 .OR. lxP1PA) .AND. lAlt) Valid (!lRet .OR. IIf(nRadMenu1==4 .OR. lxP1PA,!Empty(cxNumPa),.T.))
@ 047,117 CHECKBOX oP1PA VAR lxP1PA PROMPT "1� parcela � P.A. ? (Pagamento Antecipado)" OF oDlg3 SIZE 150, 010 PIXEL WHEN (lAlt .AND. nRadMenu1<>4 )
oP1PA:bChange := { || ChangePgt(nRadMenu1) }

@ 077,065 SAY "Tipo PIX"  OF oDlg3 PIXEL
@ 075,055 MSCOMBOBOX oCmbTpPix VAR cxTpPix  ITEMS aTpPix SIZE 60,10 Pixel OF oDlg3
 oCmbTpPix:bChange := { || ChangePix() }

// oCmbTpPix := TCOMBOBOX():Create(oDlg3)
// oCmbTpPix:cName 		:= "oCmbTpPix"
// oCmbTpPix:cCaption 	:= "Tipo Chave"
// oCmbTpPix:nLeft 		:= 100
// oCmbTpPix:nTop 		:= 125
// oCmbTpPix:nWidth 	:= 050
// oCmbTpPix:nHeight 	:= 040
// oCmbTpPix:lShowHint 	:= .T.
// oCmbTpPix:lReadOnly 	:= .F.
// oCmbTpPix:Align 		:= 0
// oCmbTpPix:cVariable 	:= "cxTpPix"
// oCmbTpPix:bSetGet 	:= {|u| If(PCount()>0,cxTpPix:=u,cxTpPix) }
// oCmbTpPix:aItems 	:= aTpPix
// oCmbTpPix:nAt 		:= 1                                                 
// oCmbTpPix:bChange 	:= { || ChangePgt(nRadMenu1) }
// oCmbTpPix:lVisibleControl := .T.

If nRadMenu1 <> 7
	oCmbTpPix:Disable()
EndIf

@ 077,117 SAY "Chave" OF oDlg3 PIXEL
@ 075,135 MSGET oGetChPix VAR cxChPix   OF oDlg3 PICTURE "@!" SIZE 130,10 PIXEL WHEN (nRadMenu1==7 .AND. lAlt) Valid IIf(nRadMenu1==7,!Empty(cxChPix),.T.)

@ 097,010 SAY 'Cond. Pgto:' OF oDlg3 PIXEL COLOR CLR_RED 
@ 095,045 MSGET oGetCond VAR cxCond OF oDlg3 WHEN lAlt VALID (!EMPTY(cxCond) .AND. AltCond(nValTot,.F.)) F3 "SE4" SIZE 20,10 PIXEL HASBUTTON

@ 097,080 SAY oSaySE4 PROMPT cDescrSE4 OF oDlg3 PIXEL COLOR CLR_RED

@ 112,010 SAY "Justificativa:"  OF oDlg3 PIXEL
@ 110,045 MSGET oGetJsPgt VAR cJsPgt  OF oDlg3 WHEN lAlt PICTURE "@!" SIZE 70,10 PIXEL

@ 127,010 SAY 'Compet�ncia:' OF oDlg3 PIXEL COLOR CLR_RED 
@ 125,045 MSGET oGetCompet VAR dCompet OF oDlg3 VALID !EMPTY(dCompet) PICTURE "@E" SIZE 55,10 PIXEL HASBUTTON 

@ 127,117 SAY 'Entrada:' OF oDlg3 PIXEL COLOR CLR_RED 
@ 125,145 MSGET oGetDigit VAR dDigit OF oDlg3 WHEN .F. PICTURE "@E" SIZE 55,10 PIXEL HASBUTTON 

@ 142,010 SAY 'Chave Nfe:' OF oDlg3 PIXEL COLOR CLR_RED 
@ 140,045 MSGET oGetChv VAR cChvNfe   OF oDlg3 WHEN lAlt PICTURE "@!" SIZE 140,10 PIXEL 

@ 155,010 SAY 'Parcelas:' OF oDlg3 PIXEL COLOR CLR_RED
oLista := MsNewGetDados():New(155, 045, 240, 210, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aACampos,, 99, "U_VldV140()", "", "", oDlg3, aCabecalho, aDados,"U_VldV140()")

If lAlt
	@ 245,070 BUTTON "Ok" SIZE 040, 012 PIXEL OF oDlg3 Action(IIf(ValidFP(nRadMenu1,@cLibF1),oDlg3:End(),AllwaysTrue()))
	@ 245,120 BUTTON "Anexos" SIZE 040, 012 PIXEL OF oDlg3 Action(MsDocument("SF1",SF1->(RECNO()),4),lAnexo:= .T.)
EndIf
If lEsc .OR. !lAlt
	@ 245,170 BUTTON "Sair" SIZE 040, 012 PIXEL OF oDlg3 Action(lRet:= .F.,oDlg3:End())
EndIf

ACTIVATE MSDIALOG oDlg3 CENTERED ON INIT AltCond(nValTot,.T.) VALID BKVerDoc("SF1",xFilial("SF1"),SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_FORMUL),lEsc)  //cNFiscal+cSerie+cA100For+cLoja+cTipo
If nRadMenu1 > 0
	cxTipoPg := aOpcoes[nRadMenu1]
	If nRadMenu1 <> 4 .AND. !lxP1PA
		cxNumPa := SPACE(9)
	EndIf
EndIf

nTipoPg := nRadMenu1

Return lRet


Static Function CalcTot()
Local nTotal := 0

dbSelectArea("SD1")                   // * Itens da N.F. de Compra
If DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	Do While !EOF() .AND. SD1->D1_FILIAL+SD1->D1_DOC+ SD1->D1_SERIE+ SD1->D1_FORNECE+ SD1->D1_LOJA  == 	xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA  
		nTotal += SD1->(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA+D1_VALIPI-D1_VALDESC)
		SD1->(dbSkip())
	EndDo
EndIf
Return nTotal


User Function VldV140()
Local lOk := .T.
Return lOK


User Function a103Load()
Local aTmp		:= {}
Local nX 		:= 0
Local nTamTex	:= 0

aDados := {}
IF !EMPTY(mParcel)
	nTamTex := mlCount(mParcel, 200)
	For nX := 1 To nTamTex	
		aTmp := StrTokArr(memoline(mParcel, 200, nX),";")
		If !Empty(aTmp[1])
			aAdd(aDados,{aTmp[1],CTOD(aTmp[2]),VAL(aTmp[3]),.F.})
			If nX == 1
				dPrvPgt := CTOD(aTmp[2])
			EndIf
		EndIf
	Next
ENDIF
Return


Static Function SaveVenc()
Local nX := 0
mParcel := ""
For nX := 1 To Len(aDados)
	If nX == 1
		dPrvPgt := oLista:aCols[nX,2]
	EndIf
	//aDados[nX,1] := oLista:aCols[nX,1]
	//aDados[nX,2] := oLista:aCols[nX,2]
	//aDados[nX,3] := oLista:aCols[nX,3]

	mParcel += oLista:aCols[nX,1]+";"
	mParcel += DTOC(oLista:aCols[nX,2])+";"
	mParcel += ALLTRIM(STR(oLista:aCols[nX,3],14,2))+";"+CRLF
Next
Return



Static Function ValidFP(nRadio,cLibF1)
Local lRet   := .T.
Local cMens2 := ""

If nRadio <> 4
	If !lxP1PA
		cxNumPa := SPACE(9)
	EndIf
Else
	lxP1PA := .F.
	oP1PA:Disable()
EndIf

If nRadio <> 1 
	cxBanco   := ""
	cxAgencia := ""
	cxConta   := ""
EndIf

If nRadio == 1
	If VAL(cxBanco) = 0 .OR. LEN(ALLTRIM(cxBanco)) < 3
		u_MsgLog("SF1140I","Informe o banco para dep�sito (num�rico, 3 d�gitos)","E")
		oGetBco:Enable()
		oGetBco:Setfocus()
		lRet := .F.
	ElseIf Empty(cxAgencia)
		u_MsgLog("SF1140I","Informe a ag�ncia para dep�sito","E")
		oGetAge:Enable()
		oGetAge:Setfocus()
		lRet := .F. 
	ElseIf Empty(cxConta)
		u_MsgLog("SF1140I","Informe a conta banc�ria para dep�sito","E")
		oGetCon:Enable()
		oGetCon:Setfocus()
		lRet := .F. 
	EndIf
ElseIf nRadio == 4
	If Empty(cxNumPa)
		u_MsgLog("SF1140I","Informe o n�mero do Pagamento Antecipado (P.A.)","E")
		oGetPA:Enable()
		oGetPA:Setfocus()
		lRet := .F.
	EndIf
ElseIf nRadio == 7
	If Empty(cxChPix)
		u_MsgLog("SF1140I","Informe a chave do PIX","E")
		oGetChPix:Enable()
		oGetChPix:Setfocus()
		lRet := .F.
	EndIf
EndIf

If lRet .AND. lxP1PA
	If Empty(cxNumPa)
		oGetPA:Enable()
		oGetPA:Setfocus()
		u_MsgLog("SF1140I","Informe o n�mero do Pagamento Antecipado da 1� parcela","E")
	EndIf
EndIf

If lRet
	If Empty(cxCond) .OR. !ExistCpo("SE4", cxCond)
		u_MsgLog("SF1140I-ValidFP","Condi��o de pagamento n�o encontrada","E")
		oGetCond:Setfocus()
		lRet := .F.
	EndIf
EndIf

If lRet
	If Len(oLista:aCols) > 0
		//dPrvPgt := aDados[1,2]
		dPrvPgt := oLista:aCols[1,2]
	EndIf
	If dPrvPgt < dValid 
		u_MsgLog("SF1140I-ValidFP","Doc : "+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+" "+SF1->F1_ESPECIE+" "+DTOC(dPrvPgt)+" "+DTOC(dValid)+" Justificativa: "+ALLTRIM(cJsPgt))
		If u_IsMasFin(__cUserId)
			If EMPTY(cJsPgt) .OR. LEN(ALLTRIM(cJsPgt)) < 5
				cJsPgt := PAD("FINANCEIRO",LEN(cJsPgt))
			EndIf
		Else
			If EMPTY(cJsPgt) .OR. LEN(ALLTRIM(cJsPgt)) < 5
				If LEN(ALLTRIM(cJsPgt)) < 5
					cMens2 := " COM CLAREZA"
				EndIf
				u_MsgLog("SF1140I","Data prevista para pagamento inferior a 3 dias uteis."+CRLF+"Justifique"+cMens2+"!!!"+CRLF+"Evite transtornos �s outras �reas implantando os documentos com anteced�ncia!!","E")
				oGetJsPgt:Setfocus()
				lRet := .F.
			
			//Else // Aqui: libera��o por Token	31/10/22
			//	cLibF1 := "T"
			//	u_MsgLog("SF1140I","Data prevista para pagamento inferior a 3 dias uteis, solicite o Token de libera��o para a controladoria via e-mail.","E")
			EndIf
		EndIf
	EndIf
EndIf


If lRet

	// Valida��o da Chave NFE
	If !Empty(cEspecie)
		If !u_ConsNfe(cChvNfe,cEspecie,SF1->F1_SERIE,SF1->F1_FORMUL) 
			oGetChv:Setfocus()
			lRet := .F.
		EndIf
	EndIf

EndIf
Return lRet


User Function ConsNfe(cChvNfe,cEspecie,cSerie,cFormul)
Local lRet := .T.
Local aAreaSA2 := SA2->(GetArea())
Local cCNPJ := ""

If !Empty(cEspecie) .AND. cFormul <> "S"
	If ("|"+(ALLTRIM(UPPER(cEspecie))+"|")) $ "|SPED|BPE|CTE|CTEOS|NF3E|NFA|"   // MV_CHVESPE
		If Empty(cChvNfe)
			u_MsgLog("SF1140I","Chave da NFe deve ser obrigatoriamente digitada","E")
			lRet := .F.
		Else
			cCNPJ := Posicione("SA2",1,xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA,"A2_CGC")
			If !Empty(cCNPJ)
				If Val(cCNPJ) <> Val(SUBSTR(cChvNfe,7,14)) //.AND. cSerie <> "890" NFA
					u_MsgLog("SF1140I","CNPJ da Chave da NFe diferente do CNPJ do fornecedor","E")
					lRet := .F.
				ElseIf SUBSTR(STR(YEAR(SF1->F1_EMISSAO),4),3,2)+STRZERO(MONTH(SF1->F1_EMISSAO),2) <> SUBSTR(cChvnfe,3,4)
					u_MsgLog("SF1140I","M�s da Chave da NFe diferente do m�s de emiss�o informado","E")
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

SA2->(RestArea(aAreaSA2))
Return lRet


Static Function ChangePix()

//u_MsgLog("CHANGEPIX",cxTpPix,"I")
cxChPix := SPACE(LEN(F72->F72_CHVPIX))
If F72->(dbSeek(xFilial("F72")+SF1->F1_FORNECE+SF1->F1_LOJA+cxTpPix,.T.))
	If SF1->F1_FORNECE+SF1->F1_LOJA+cxTpPix == F72->(F72_COD+F72_LOJA+F72_TPCHV)
		cxChPix := F72->F72_CHVPIX
	EndIf
EndIf
If Empty(cxChPix) .AND. cxTpPix == "03"
	cxChPix := cCNPJ
EndIf
oGetChPix:Refresh()

Return Nil 



Static Function ChangePgt(nRadio)

If nRadio == 1
	oGetBco:Enable()
	oGetAge:Enable()
	oGetCon:Enable()
	//oGetBco:Setfocus()
Else
	oGetBco:Disable()
	oGetAge:Disable()
	OGetCon:Disable()
EndIf 

If nRadio == 4
	oGetPA:Enable()
	lxP1PA := .F.
	oP1PA:Refresh()
	oP1PA:Disable()
Else
	oP1PA:Enable()
	oP1PA:Refresh()
	If !lxP1PA
		cxNumPa := SPACE(9)
		oGetPA:Refresh()
		oGetPA:Disable()
	Else
		oGetPA:Enable()
	EndIf
EndIf

If nRadio == 7
	oGetChPix:Enable()
	oCmbTpPix:Enable()
Else
	oGetChPix:Disable()
	oCmbTpPix:Disable()
	cxChPix := SPACE(100)
	oGetChPix:Refresh()
EndIf

Return Nil


Static Function AltCond(nValTot,lIni)
Local aParc
Local lRet	:= .T.
Local nX	:= 0

If ExistCpo("SE4", cxCond)
	aParc := Condicao(nValTot,cxCond,,dDataBase)
	If Len(aParc) > 0

		If lIni .AND. !Empty(dPrvPgt)
			aParc[1,1] := dPrvPgt
		EndIf

		aParc[1,1]	:= DataValida(aParc[1,1],.T.)

		dPrvPgt 	:= aParc[1,1]
		cDescrSE4	:= Posicione("SE4",1,xFilial("SE4")+cxCond,"E4_DESCRI")

		aDados 		:= {}
		For nX := 1 To Len(aParc)
			aAdd(aDados,{STRZERO(nX,2),aParc[nX,1],aParc[nX,2],.F.})
		Next

		oLista:SetArray(aDados,.T.)
		oLista:Refresh()

		oGetCompet:Refresh()
		oSaySE4:Refresh()
	EndIf
Else
	lRet := .F.
EndIf
Return lRet



User Function a103Cab()
Local aCabecalho := {}   

Aadd(aCabecalho, {;
                  "Parc.",;//X3Titulo()
                  "PARC",;  	//X3_CAMPO
                  "",;			//X3_PICTURE
                  2,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",;			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN

Aadd(aCabecalho, {;
                  "Vencimento",;//X3Titulo()
                  "VENCTO",;  	//X3_CAMPO
                  "",;			//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "D",;			//X3_TIPO
                  "",;			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN
 
 
 Aadd(aCabecalho, {;
                  "Valor",;	//X3Titulo()
                  "VALOR",; //X3_CAMPO
                  "@E 999,999,999.99",;		//X3_PICTURE
                  14,;		//X3_TAMANHO
                  2,;		//X3_DECIMAL
                  "POSITIVO()",;		//X3_VALID
                  "",;		//X3_USADO
                  "N",;		//X3_TIPO
                  "",;		//X3_F3
                  "R",;		//X3_CONTEXT
                  "",;		//X3_CBOX
                  "",;		//X3_RELACAO
                  ""})		//X3_WHEN

Return(aCabecalho)


User Function GetSa2(cCod,cLoja)
Local aArea := GetArea()

dbSelectArea("SA2")
If !u_IsFornBK(cCod) .AND. dbSeek(xFilial("SA2")+cCod+cLoja)
	cxBanco   := SA2->A2_BANCO
	cxAgencia := SA2->A2_AGENCIA
	cxConta   := SA2->A2_NUMCON
Else
	cxBanco   := SPACE(LEN(SA2->A2_BANCO))
	cxAgencia := SPACE(LEN(SA2->A2_AGENCIA))
	cxConta   := SPACE(LEN(SA2->A2_NUMCON))
EndIf

RestArea(aArea)
Return



Static Function PutSa2(cCod,cLoja)
Local aArea := GetArea()

If !Empty(cxBanco) .AND. !u_IsFornBK(cCod)
	dbSelectArea("SA2")
	If dbSeek(xFilial("SA2")+cCod+cLoja) 
		RecLock("SA2",.F.)
		SA2->A2_BANCO   := cxBanco
		SA2->A2_AGENCIA := cxAgencia
		SA2->A2_NUMCON  := cxConta
		MsUnLock("SA2")
	EndIf
EndIf

RestArea(aArea)
Return

// Gravar dados do PIX na tabela padr�o do sistema
Static Function PutF72(cCod,cLoja,cxTpPix,cxChPix)
Local aArea := GetArea()
Local lInc  := .F.

If !Empty(cxChPix)
	dbSelectArea("F72")
	If dbSeek(xFilial("F72")+cCod+cLoja+cxTpPix,.T.)
		If cCod+cLoja+cxTpPix == F72->(F72_COD+F72_LOJA+F72_TPCHV)
			RecLock("F72",.F.)
			F72->F72_CHVPIX := AllTrim(cxChPix)
			MsUnLock("F72")
		Else 
			lInc := .T.
		EndIf
	Else
		lInc := .T.
	EndIf
	If lInc
		RecLock("F72",.T.)
		F72->F72_FILIAL := xFilial("F72")
		F72->F72_COD    := cCod
		F72->F72_LOJA   := cLoja
		F72->F72_TPCHV  := cxTpPix
		F72->F72_CHVPIX := AllTrim(cxChPix)
		F72->F72_ACTIVE := "2"
		F72->F72_NOME   := "*"
		MsUnLock("F72")
	EndIf
EndIf

RestArea(aArea)
Return


// Verifica a exist�ncia de anexos no SF1
	// Bloquear se n�o tiver anexos
	// Chave do SF1: F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_FORMUL
	// Chave do AC9: xFilial( "AC9" ) + cEntidade + xFilial( cEntidade ) + cCodEnt
	//                                +     SF1   + xFilial( "SF1"" )    + F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_FORMUL -> 000049423DNFUNIAO 00 (OBS: sem filial)
Static Function BKVerDoc(_cAlias,_cFilial,_cChave,lEsc)
Local aArea 	:= GetArea()
Local aAreaAC9	:= {}
Local lRet 		:= .F.

If !lEsc
	aAreaAC9 := AC9->(GetArea())
	dbSelectArea("AC9")
	dbSetOrder(2)
	If dbSeek(xFilial("AC9")+_cAlias+_cFilial+_cChave,.T.)
		If _cAlias+_cFilial+TRIM(_cChave) == TRIM(AC9->(AC9_ENTIDA+AC9_FILENT+AC9_CODENT))
			lRet := .T.
		EndIf
	EndIf

	If !lRet
		u_MsgLog("SF1140I","N�o � permitido incluir pr�-nota ou doc de entrada sem anexar arquivos!","E")
	EndIf

	AC9->(RestArea(aAreaAC9))
	RestArea(aArea)
Else
	lRet := .T.
EndIf
If lRet
	SaveVenc()
EndIf

Return lRet


