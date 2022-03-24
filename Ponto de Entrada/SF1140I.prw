#include "protheus.ch"
#include "rwmake.ch"


/*/{Protheus.doc} SF1140I
BK - Ponto de entrada para gravar UserId e Superior
19/11/19 - Marcos B Abrahão - Gravar dados de pagamento
@Return
@author Marcos Bispo Abrahão
@since 19/11/2009 
@version P12
/*/

User Function SF1140I()
Local aUser,cSuper

Private cxTipoPg := SF1->F1_XTIPOPG
Private cxNumPa  := SF1->F1_XNUMPA
Private cxBanco  := SF1->F1_XBANCO
Private cxAgencia:= SF1->F1_XAGENC
Private cxConta  := SF1->F1_XNUMCON
Private cChvNfe  := SF1->F1_CHVNFE
Private dPrvPgt  := SF1->F1_XXPVPGT
Private cJsPgt	 := SF1->F1_XXJSPGT
Private nTipoPg  := 0
Private cEspecie := SF1->F1_ESPECIE
Private cxCond	 := SF1->F1_COND
Private mParcel  := SF1->F1_XXPARCE

//GetSa2(SF1->F1_FORNECE,SF1->F1_LOJA)

IF VAL(__cUserId) > 0  // EMPTY(SF1->F1_XXUSER) .AND. //Não Gravar Administrador
	PswOrder(1) 
	PswSeek(__CUSERID) 
	aUser  := PswRet(1)
	cSuper := aUser[1,11]

	If Empty(SF1->F1_XXUSER) .OR. !(ASCAN(aUser[1,10],"000031") == 0)
		RecLock("SF1",.F.)
		SF1->F1_XXUSER  := __cUserId
		SF1->F1_XXUSERS := cSuper
		MsUnLock("SF1")
	EndIf
ENDIF

If !l140Auto
	U_SelFPgto(.T.,.F.)
EndIf

RecLock("SF1",.F.)
SF1->F1_XTIPOPG := cxTipoPg
SF1->F1_XNUMPA  := cxNumPa
SF1->F1_XBANCO  := cxBanco
SF1->F1_XAGENC  := cxAgencia
SF1->F1_XNUMCON := cxConta
SF1->F1_CHVNFE  := cChvNfe
SF1->F1_XXPVPGT := dPrvPgt
SF1->F1_XXJSPGT := cJsPgt
SF1->F1_COND	:= cxCond
SF1->F1_XXPARCE := mParcel

// Limpar dados de Liberação
SF1->F1_XXLIB   := "A"
SF1->F1_XXULIB  := " "
SF1->F1_XXDLIB  := " "
SF1->F1_XXDINC  := DtoC(Date())+"-"+Time()

MsUnLock("SF1")

If nTipoPg == 1 .AND. SF1->F1_FORNECE <> "000084"
	PutSa2(SF1->F1_FORNECE,SF1->F1_LOJA)
EndIf

u_LogPrw("SF1140I",iIf(Inclui,"Doc incluido: ","Doc alterado: ")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+" "+SF1->F1_ESPECIE)
	
Return .T.


User Function AltFPgto
Local lAlt := .T.
Private cxTipoPg := SF1->F1_XTIPOPG
Private cxNumPa  := SF1->F1_XNUMPA
Private cxBanco  := SF1->F1_XBANCO
Private cxAgencia:= SF1->F1_XAGENC
Private cxConta  := SF1->F1_XNUMCON
Private cChvNfe  := SF1->F1_CHVNFE
Private dPrvPgt  := SF1->F1_XXPVPGT
Private cJsPgt	 := SF1->F1_XXJSPGT
Private nTipoPg  := 0
Private cEspecie := SF1->F1_ESPECIE
Private cxCond	 := SF1->F1_COND
Private mParcel	 := SF1->F1_XXPARCE

If SF1->F1_XXLIB $ "AE" .AND. Empty(SF1->F1_STATUS)
	lAlt := .T.
Else
	lAlt := .F.
Endif

If U_SelFPgto(lAlt,.T.)
	RecLock("SF1",.F.)
	SF1->F1_XTIPOPG := cxTipoPg
	SF1->F1_XNUMPA  := cxNumPa
	SF1->F1_XBANCO  := cxBanco
	SF1->F1_XAGENC  := cxAgencia
	SF1->F1_XNUMCON := cxConta
	SF1->F1_CHVNFE  := cChvNfe
	SF1->F1_XXPVPGT := dPrvPgt
	SF1->F1_XXJSPGT := cJsPgt
	SF1->F1_COND	:= cxCond
	SF1->F1_XXPARCE := mParcel
	If Empty(SF1->F1_XXLIB) .AND. Empty(SF1->F1_STATUS)
		SF1->F1_XXLIB := "A"
	EndIf
	MsUnLock("SF1")
EndIf

Return Nil


User Function SelFPgto(lAlt,lEsc)
Local aOpcoes   := {}
Local oRadMenu1
Local oSay1
Local bClickP
Local lAnexo 	:= .F.
Local lRet 		:= .T.
Local aCabecalho:= {}
Local aaCampos	:= {"PARC","VENCTO","VALOR"} //Variável contendo o campo editável no Grid
Local nValTot	:= 0
Local aGrp 		:= UsrRetGrp()

Static oDlg3

Default lAlt 		:= .T.
Default lEsc 		:= .F.

Private nRadMenu1	:= 1
Private dValid 		:= dDataBase
Private oGetBco,oGetAge,oGetCon,oGetPA,oGetChv,oGetCond,oSaySE4,oGetPvPgt,oGetJsPgt,oLista
Private cDescrSE4	:= Posicione("SE4",1,xFilial("SE4")+cxCond,"E4_DESCRI")
Private aDados		:= {}

If LEN(aGrp) > 0
	If aGrp[1] $ "000000/000031" 
		lAlt := .T.
		lEsc := .T.
	EndIf
EndIf

nValTot := CalcTot()

dValid := DataValida(dValid+1,.T.)
dValid := DataValida(dValid+1,.T.)

aadd(aOpcoes,"DEPOSITO")   //01
aadd(aOpcoes,"CARTAO")     //02
aadd(aOpcoes,"BOLETO")     //03
aadd(aOpcoes,"P.A.")       //04
aadd(aOpcoes,"FUNDO FIXO") //05
aadd(aOpcoes,"CHEQUE")     //06

nRadMenu1 := ASCAN(aOpcoes,ALLTRIM(cxTipoPg))
If nRadMenu1 = 0
	nRadMenu1 := 1
EndIf

aCabecalho	:= u_a103Cab()
nColDel 	:= Len(aCabecalho)+1
u_a103Load()

DEFINE MSDIALOG oDlg3 TITLE "Forma de pagamento, chave NFE e Anexos" STYLE DS_MODALFRAME FROM 000,000 TO 470,470 COLORS 0, 16777215 PIXEL
oDlg3:lEscClose := .F.

bClickP	:= { || Habilita(nRadMenu1) }	
oRadMenu1:= tRadMenu():New(20,10,aOpcoes,{|u|if(PCount()>0,nRadMenu1:=u,nRadMenu1)}, oDlg3,,bClickP,,,,,,70,130,,,,.T.)

@ 010,010 SAY oSay1 PROMPT "Selecione a forma de pagamento :" SIZE 091, 007 OF oDlg3 COLORS 0, 16777215 PIXEL

@ 087,010 SAY "Banco" 	 OF oDlg3 PIXEL
@ 085,040 MSGET oGetBco VAR cxBanco   OF oDlg3 PICTURE "@!" PIXEL WHEN (nRadMenu1==1 .AND. lAlt) Valid IIf(nRadMenu1==1,!Empty(cxBanco),.T.)
@ 087,065 SAY "Agência"  OF oDlg3 PIXEL
@ 085,090 MSGET oGetAge VAR cxAgencia OF oDlg3 PICTURE "@!" PIXEL WHEN (nRadMenu1==1 .AND. lAlt) Valid IIf(nRadMenu1==1,!Empty(cxAgencia),.T.)
@ 087,125 SAY "Conta"  	 OF oDlg3 PIXEL
@ 085,145 MSGET oGetCon VAR cxConta   OF oDlg3 PICTURE "@!" SIZE 60,10 PIXEL WHEN (nRadMenu1==1 .AND. lAlt) Valid IIf(nRadMenu1==1,!Empty(cxConta),.T.)

@ 102,010 SAY "P.A."     OF oDlg3 PIXEL
@ 100,040 MSGET oGetPA VAR cxNumPa	  OF oDlg3 PICTURE "@!" PIXEL WHEN (nRadMenu1==4 .AND. lAlt) Valid IIf(nRadMenu1==4,!Empty(cxNumPa),.T.)

@ 117,010 SAY 'Cond. Pgto:' OF oDlg3 PIXEL COLOR CLR_RED 
@ 115,040 MSGET oGetCond VAR cxCond OF oDlg3 WHEN lAlt VALID (!EMPTY(cxCond) .AND. AltCond(nValTot)) F3 "SE4" SIZE 20,10 PIXEL HASBUTTON

@ 117,110 SAY oSaySE4 PROMPT cDescrSE4 OF oDlg3 PIXEL COLOR CLR_RED

//@ 132,010 SAY 'Prev. Pgto:' OF oDlg3 PIXEL COLOR CLR_RED 
//@ 130,040 MSGET oGetPvPgt VAR dPrvPgt OF oDlg3 WHEN .F. /*lAlt*/ VALID !EMPTY(dPrvPgt) PICTURE "@E" SIZE 55,10 PIXEL HASBUTTON 

@ 132,010 SAY "Justificativa:"  OF oDlg3 PIXEL
@ 130,040 MSGET oGetJsPgt VAR cJsPgt  OF oDlg3 WHEN lAlt PICTURE "@!" SIZE 60,10 PIXEL //WHEN (dPrvPgt < dValid)

@ 147,010 SAY 'Chave Nfe:' OF oDlg3 PIXEL COLOR CLR_RED 
@ 145,040 MSGET oGetChv VAR cChvNfe   OF oDlg3 WHEN lAlt PICTURE "@!" SIZE 140,10 PIXEL 

@ 160,010 SAY 'Parcelas:' OF oDlg3 PIXEL COLOR CLR_RED 
oLista := MsNewGetDados():New(160, 040, 210, 180, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aACampos,, 99, "U_VldV140()", "", "", oDlg3, aCabecalho, aDados,"U_VldV140()")

If lAlt
	@ 215,040 BUTTON "Ok" SIZE 040, 012 PIXEL OF oDlg3 Action(IIf(ValidFP(nRadMenu1),oDlg3:End(),AllwaysTrue()))
	@ 215,090 BUTTON "Anexos" SIZE 040, 012 PIXEL OF oDlg3 Action(MsDocument("SF1",SF1->(RECNO()),4),lAnexo:= .T.)
EndIf
If lEsc .OR. !lAlt
	@ 215,140 BUTTON "Sair" SIZE 040, 012 PIXEL OF oDlg3 Action(oDlg3:End(),lRet:= .F.)
EndIf

ACTIVATE MSDIALOG oDlg3 CENTERED VALID BKVerDoc("SF1",xFilial("SF1"),SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_FORMUL),lEsc)  //cNFiscal+cSerie+cA100For+cLoja+cTipo
If nRadMenu1 > 0
	cxTipoPg := aOpcoes[nRadMenu1]
	If nRadMenu1 <> 4
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
	mParcel += oLista:aCols[nX,1]+";"
	mParcel += DTOC(oLista:aCols[nX,2])+";"
	mParcel += ALLTRIM(STR(oLista:aCols[nX,3],14,2))+";"+CRLF
Next
Return



Static Function ValidFP(nRadio)
Local lRet := .T.

If nRadio <> 1 .AND. nRadio <> 4
	cxNumPa   := SPACE(9)
	cxBanco   := ""
	cxAgencia := ""
	cxConta   := ""
Else
	If nRadio == 1
		If Empty(cxBanco)
			MsgStop("Informe o banco para depósito","SF1140I - Validação de banco")
			oGetBco:Enable()
			oGetBco:Setfocus()
			lRet := .F.
		ElseIf Empty(cxAgencia)
			MsgStop("Informe a agência para depósito","SF1140I - Validação de agencia")
			oGetAge:Enable()
			oGetAge:Setfocus()
			lRet := .F. 
		ElseIf Empty(cxConta)
			MsgStop("Informe a conta bancária para depósito","SF1140I - Validação de conta")
			oGetCon:Enable()
			oGetCon:Setfocus()
			lRet := .F. 
		EndIf
	ElseIf nRadio == 4
		If Empty(cxNumPa)
			MsgStop("Informe o número do Pagamento Antecipado (P.A.)","SF1140I - Validação de numero da PA")
			oGetPA:Enable()
			oGetPA:Setfocus()
			lRet := .F.
		EndIf
	EndIf
EndIf

/*
If lRet
	If Empty(dPrvPgt)
		MsgStop("Informe a data prevista para pagamento","SF1140I - Validação data prevista de pagamento")
		oGetPvPgt:Setfocus()
		lRet := .F.
	Else
		If dPrvPgt < dDataBase
			MsgStop("Data prevista para pagamento inferior a database","SF1140I - Validação data prevista de pagamento")
			oGetPvPgt:Setfocus()
			lRet := .F.
		ElseIf dPrvPgt < dValid
			If EMPTY(cJsPgt)
				MsgStop("Data prevista para pagamento inferior a 2 dias uteis, justifique","SF1140I - Validação data prevista de pagamento")
				oGetJsPgt:Setfocus()
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf
*/

If lRet
	/*
	If Empty(cChvNfe) .AND. !Empty(cEspecie)
		If (ALLTRIM(UPPER(cEspecie))+"/") $ "SPED/BPE/CTE/CTEOS/NF3E/NFA/"   // MV_CHVESPE
			MsgStop("Chave da NFe deve ser obrigatoriamente digitada","SF1140I - Validação da Chave NFE")
			oGetChv:Setfocus()
			lRet := .F.
		EndIf
	EndIf
	*/

	// Validação da Chave NFE
	If !Empty(cEspecie)
		If !u_ConsNfe(cChvNfe,cEspecie) 
			oGetChv:Setfocus()
			lRet := .F.
		EndIf
	EndIf

EndIf
Return lRet


User Function ConsNfe(cChvNfe,cEspecie)
Local lRet := .T.
Local aAreaSA2 := SA2->(GetArea())
Local cCNPJ := ""

If !Empty(cEspecie)
	If ("|"+(ALLTRIM(UPPER(cEspecie))+"|")) $ "|SPED|BPE|CTE|CTEOS|NF3E|NFA|"   // MV_CHVESPE
		If Empty(cChvNfe)
			MsgStop("Chave da NFe deve ser obrigatoriamente digitada","SF1140I - Validação da Chave NFE")
			lRet := .F.
		Else
			cCNPJ := Posicione("SA2",1,xFilial("SA2") + SF1->F1_FORNECE + SF1->F1_LOJA,"A2_CGC")
			If !Empty(cCNPJ)
				If Val(cCNPJ) <> Val(SUBSTR(cChvNfe,7,14))
					MsgStop("CNPJ da Chave da NFe diferente do CNPJ do fornecedor","SF1140I - Validação da Chave NFE - CNPJ")
					lRet := .F.
				ElseIf SUBSTR(STR(YEAR(SF1->F1_EMISSAO),4),3,2)+STRZERO(MONTH(SF1->F1_EMISSAO),2) <> SUBSTR(cChvnfe,3,4)
					MsgStop("Mês da Chave da NFe diferente do mês de emissão informado","SF1140I - Validação da Chave NFE - Emissão")
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

SA2->(RestArea(aAreaSA2))
Return lRet



Static Function Habilita(nRadio)

If nRadio <> 1 .AND. nRadio <> 4
	oGetBco:Disable()
	oGetAge:Disable()
	OGetCon:Disable()
	cxNumPa := SPACE(9)
	oGetPA:Refresh()
	oGetPA:Disable()
Else
	If nRadio == 1
		oGetBco:Enable()
		oGetAge:Enable()
		oGetCon:Enable()
		//oGetBco:Setfocus()
	ElseIf nRadio == 4
		oGetPA:Enable()
		//oGetPA:Setfocus()
	EndIf
EndIf
Return Nil


Static Function AltCond(nValTot)
Local aParc
Local lRet	:= .T.
Local nX	:= 0

If ExistCpo("SE4", cxCond)
	aParc := Condicao(nValTot,cxCond,,dDataBase)
	If Len(aParc) > 0
		dPrvPgt 	:= aParc[1,1]
		cDescrSE4	:= Posicione("SE4",1,xFilial("SE4")+cxCond,"E4_DESCRI")

		aDados 		:= {}
		For nX := 1 To Len(aParc)
			aAdd(aDados,{STRZERO(nX,2),aParc[nX,1],aParc[nX,2],.F.})
		Next

		oLista:SetArray(aDados,.T.)
		oLista:Refresh()

		//oGetPvPgt:Refresh()
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

/*
Static Function GetSa2(cCod,cLoja)
Local aArea := GetArea()

dbSelectArea("SA2")
If dbSeek(xFilial("SA2")+cCod+cLoja) 
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
*/


Static Function PutSa2(cCod,cLoja)
Local aArea := GetArea()

dbSelectArea("SA2")
If dbSeek(xFilial("SA2")+cCod+cLoja) 
	RecLock("SA2",.F.)
	SA2->A2_BANCO   := cxBanco
	SA2->A2_AGENCIA := cxAgencia
	SA2->A2_NUMCON  := cxConta
	MSUNLOCK("SA2")
EndIf

RestArea(aArea)
Return



// Verifica a existência de anexos no SF1
	// Bloquear se não tiver anexos
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
		MsgStop("Não é permitido incluir pré-nota ou doc de entrada sem anexar arquivos!","SF1140I - Validação de Anexos")
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
