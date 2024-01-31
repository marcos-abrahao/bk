#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"         

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINA32
BK - Borderô - Depósito/Pix Itau
@Return
@author Marcos B. Abrahão
@since 23/10/23
@version P12
/*/
//-------------------------------------------------------------------


#DEFINE CP_MARK			01	// Marcação
#DEFINE CP_NUMBOR		02	// Numero do Borderô
#DEFINE CP_BANCO		03 
#DEFINE CP_FORMA		04  // DEPOSITO / PIX
#DEFINE CP_PREFIXO		05
#DEFINE CP_NUMERO		06
#DEFINE CP_PARCELA		07
#DEFINE CP_TIPO			08
#DEFINE CP_PGTO			09
#DEFINE CP_EMISSAO		10
#DEFINE CP_VENC			11
#DEFINE CP_CSALDO		12
#DEFINE CP_NOME			13
#DEFINE CP_FORNECE		14
#DEFINE CP_LOJA			15
#DEFINE CP_TIPOP		16
#DEFINE CP_SALDO		17
#DEFINE CP_AGENCIA		18
#DEFINE CP_CONTA		19
#DEFINE CP_DIGITO		20
#DEFINE CP_CNPJ			21
#DEFINE CP_TPPIX		22
#DEFINE CP_CHPIX		23
#DEFINE CP_REGSE2		24

#DEFINE CP_CAMPOS		24

User Function BKFINA32()

Local oDlg			as Object
Local aSize	   		:= FWGetDialogSize( oMainWnd )
Local nTop			:= 0
Local nLeft			:= 0

Local oLayer		as Object
Local oPanelUp		as Object
Local oPanelDown	as Object

Local oOk			:= LoadBitmap( GetResources(), "LBTIK" )
Local oNo 			:= LoadBitmap( GetResources(), "LBNO" )

Local oListId		as Object
Local lAll			:= .F.
Local oAll			as Object

Local aTitBor   	:= {}
Local lOk			:= .F.
Local aAreaIni  	:= GetArea()
Local cTitulo   	:= "Depósito/Pix Itaú - Borderô "+FWEmpName(cEmpAnt)

Private cPictVal	:= PesqPict("SE2","E2_VALOR")
Private cPerg   	:= "BKFINA32"
Private dData		:= dDataBase
Private cSEE    	:= ""
Private cDirTmp 	:= ""
Private cBanco 		:= ""
Private nTotal 		:= 0

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

dData  	 := mv_par01
cSEE	 := ALLTRIM(mv_par02)
cDirTmp	 := ALLTRIM(mv_par03)+"\BORDERO" 
cBanco   := SUBSTR(cSEE,1,3)

u_MsgLog(cPerg,"Venc: "+DTOC(dData) + " - Banco "+cSEE)

IF cBanco <> "341" 
	u_MsgLog(cPerg,"Selecione uma conta do Banco 341 !","E") 
	Return Nil
ENDIF

IF dData < dDatabase
	u_MsgLog(cPerg,"Data deve ser maior ou igual que a database!!","E")
	Return Nil
ENDIF

IF EMPTY(cDirTmp)
	u_MsgLog(cPerg,"Pasta deve ser preenchida!!","E")
	Return Nil
ENDIF

aTitBor := {}

u_WaitLog(cPerg, {|| aTitBor := ProcGer1() },"Selecionando títulos")

If Empty(aTitBor)
	u_MsgLog(cPerg,"Não há títulos disponíveis !!","E")
	RestArea(aAreaIni)
	Return
EndIf


oDlg := MsDialog():New( nTop, nLeft, aSize[3], aSize[4],cTitulo,,,,,,,,, .T.,,,, .F. )
oDlg:nClientHeight  := aSize[3]
oDlg:nClientWidth   := aSize[4]
oDlg:Refresh()

EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End() },{|| oDlg:End() })

oLayer := FWLayer():new()
oLayer:init(oDlg,.F.)

/*
oLayer:addCollumn ('Col1',100,.F.)
oLayer:addWindow('Col1', 'WinTop' ,'Seleção' ,15,.F.,.F.,,,)
oLayer:addWindow('Col1', 'WinGrid','Títulos' ,85,.F.,.F.,,,)

oPanelUp := oLayer:getWinPanel('Col1','WinTop')
oPanelDown := oLayer:getWinPanel('Col1','WinGrid')
*/

oLayer:addLine('Line1',005,.F.)
oLayer:addLine('Line2',095,.F.)

oPanelUp := oLayer:getLinePanel('Line1')
oPanelDown := oLayer:getLinePanel('Line2')

lAll := .F.
@ 003, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelUp SIZE 050, 010 PIXEL 
oAll:bChange := {|| MarkAll(lAll,aTitBor,oSayTot), oListId:Refresh()}
oSayTot := tSay():New(003,100,{||'Total Selecionado: '+ TransForm(nTotal,"@E 99,999,999.99")},oPanelUp,,,,,,.T.,,,200,20)


@ 015, 005 LISTBOX oListId FIELDS HEADER "","Borderô","Banco","Forma","Prefixo","Número","Parcela","Tipo","Nome","Emissão","Vencimento","Total R$","Agência","Conta","Digito","Tipo","Tp","Chave PIX" SIZE 320,180 OF oPanelDown PIXEL 
oListID:SetArray(aTitBor)
oListID:bLine := {|| {If(aTitBor[oListId:nAt][CP_MARK],oOk,oNo),;
						aTitBor[oListId:nAt][CP_NUMBOR],;
						aTitBor[oListId:nAt][CP_BANCO],;
						aTitBor[oListId:nAt][CP_FORMA],;
						aTitBor[oListId:nAt][CP_PREFIXO],;
						aTitBor[oListId:nAt][CP_NUMERO],;
						aTitBor[oListId:nAt][CP_PARCELA],;
						aTitBor[oListId:nAt][CP_TIPO],;
						aTitBor[oListId:nAt][CP_NOME],;
						aTitBor[oListId:nAt][CP_EMISSAO],;
						aTitBor[oListId:nAt][CP_VENC],;
						aTitBor[oListId:nAt][CP_CSALDO],;
						aTitBor[oListId:nAt][CP_AGENCIA],;
						aTitBor[oListId:nAt][CP_CONTA],;
						aTitBor[oListId:nAt][CP_DIGITO],;
						aTitBor[oListId:nAt][CP_TPPIX],;
						aTitBor[oListId:nAt][CP_CHPIX],;
						aTitBor[oListId:nAt][CP_TIPOP]}}

oListId:bLDblClick := {|| aTitBor[oListId:nAt][1] := MarkOne(aTitBor[oListId:nAt][CP_MARK],aTitBor[oListId:nAt][CP_NUMBOR],aTitBor[oListId:nAt][CP_SALDO],aTitBor[oListId:nAt][CP_CHPIX],oSayTot), oListId:DrawSelect()}
oListId:Align := CONTROL_ALIGN_ALLCLIENT

oDlg:Activate()
 
If ( lOk )
	u_WaitLog(cPerg, {|| GravaBordero(aTitBor,"DEPOSITO")},"Gerando borderô DEPOSITO")
	u_WaitLog(cPerg, {|| GravaBordero(aTitBor,"PIX")},"Gerando borderô PIX")
EndIf

RestArea(aAreaIni)
Return
      

Static Function MarkOne(lMrk,cNumBor,nSaldo,cChPix,oSayTot)
Local lRet := .F.
If Empty(cNumBor) .AND. nSaldo > 0 .AND. !("Erro" $ cChPix)
	lRet := !lMrk
EndIf

IF lMrk <> lRet
	IF lRet
		nTotal += nSaldo
	ELSE
		nTotal -= nSaldo
	ENDIF
ENDIF

oSayTot:cCaption := "Total Selecionado: "+TRANSFORM(nTotal,"@E 999,999,999.99")

Return lRet



Static Function MarkAll(lAll,aTitBor,oSayTot)
Local nI

nTotal := 0

For nI := 1 TO LEN(aTitBor)

	If lAll .AND. Empty(aTitBor[nI,CP_NUMBOR]) .AND. aTitBor[nI,CP_SALDO] > 0
		aTitBor[nI,CP_MARK] := .T.
		nTotal += aTitBor[nI,CP_SALDO] 
	Else
		aTitBor[nI,CP_MARK] := .F.
	EndIf
Next
oSayTot:cCaption := "Total Selecionado: "+TRANSFORM(nTotal,"@E 999,999,999.99")

Return


Static Function GravaBordero(aTitBor,cFormaPgto)
Local cCrLf   	:= Chr(13) + Chr(10)
Local cQuery    := ""
Local cArqTmp 	:= ""
Local BncoTxtT	:= ""
Local cAgencia  := ""
Local cDVAgenc	:= ""
Local cConta    := ""
Local cDVConta  := ""
Local cCGC		:= SM0->M0_CGC
Local cNomeCom  := Acento(ALLTRIM(SM0->M0_NOMECOM))
Local nLote 	:= 0
Local cDirTmp2  := ALLTRIM(cDirTmp)
Local nI		:= 0
Local cMsgLog   := ""
Local aTitGer 	:= {}
Local nQTot		:= 0
Local nValTot	:= 0

For nI := 1 To Len(aTitBor)
	If aTitBor[nI,CP_MARK] .AND. ALLTRIM(aTitBor[nI,CP_FORMA]) == cFormaPgto
		aAdd(aTitGer,aTitBor[nI])
	EndIf
Next

If Len(aTitGer) == 0
	u_MsgLog(cPerg,"Não foram selecionados títulos para geração de borderô "+cFormaPgto,"W")
	Return Nil
EndIf

// CONSORCIOS: USAR LOTE BK
IF cEmpAnt $ "06/08/09/10/11/14/15/18"
	cQuery  := "SELECT EE_CODIGO,EE_AGENCIA,EE_CONTA,EE_LOTECP "
	cQuery  += " FROM SEE010 "
	cQuery  += " WHERE EE_FILIAL='"+xFILIAL("SEE")+"' AND EE_CODIGO='"+SUBSTR(cSEE,1,3)+"' AND D_E_L_E_T_ = '' "  
	cQuery  += " AND EE_AGENCIA='"+SUBSTR(cSEE,4,5)+"' AND EE_CONTA='"+SUBSTR(cSEE,9,10)+"' AND EE_SUBCTA='"+SUBSTR(cSEE,19,3)+"'"

	If Select("QSEE") > 0
		QSEE->(DbCloseArea())
	EndIf

	TCQUERY cQuery NEW ALIAS "QSEE"
			
	DbSelectArea("QSEE")
	QSEE->(DbGoTop())
	DO WHILE QSEE->(!EOF())
		nLote := VAL(QSEE->EE_LOTECP)
		QSEE->(dbSkip())
	ENDDO
	QSEE->(DbCloseArea())

	IF  nLote > 0
		nLote := VAL(Soma1(STR(nLote),8))

		// Descomentar para Ativar
		//If !u_IsTeste()
			cQuery 	:= " UPDATE SEE010 SET EE_LOTECP = '"+STRZERO(nLote,8)+"' "
			cQuery  += " WHERE EE_FILIAL='"+xFILIAL("SEE")+"' AND EE_CODIGO='"+SUBSTR(cSEE,1,3)+"' AND D_E_L_E_T_ = '' "  
			cQuery  += " AND EE_AGENCIA='"+SUBSTR(cSEE,4,5)+"' AND EE_CONTA='"+SUBSTR(cSEE,9,10)+"' AND EE_SUBCTA='"+SUBSTR(cSEE,19,3)+"'"
			TcSqlExec(cQuery)
		//EndIf

	ENDIF

ENDIF

DbSelectArea("SEE")
DbSetOrder(1)
IF DbSeek(xFilial("SEE")+cSEE,.F.)
	// CONSORCIOS: USAR CNPJ BK
	cCGC      := IIF(cEmpAnt $ "06/08/09/10/11/14/15/18".AND. nLote > 0 ,"03022122000177",cCGC)
    cNomeCom  := IIF(cEmpAnt $ "06/08/09/10/11/14/15/18".AND. nLote > 0 ,"BK CONSULTORIA E SERVICOS LTDA",cNomeCom)
    IF (cEmpAnt $ "06/08/09/10/11/14/15/18") .AND. nLote > 0 
		u_MsgLog(cPerg,"Borderô dos consorcios considerando CNPJ da BK!","W")
	EndIf

	// Descomentar para Ativar
	//If !u_IsTeste()
		RecLock("SEE",.F.)                             
		Replace SEE->EE_LOTECP With IIF(cEmpAnt $ "06/08/09/10/11/14/15/18" .AND. nLote > 0 ,STRZERO(nLote,8),Soma1(SEE->EE_LOTECP,8))
		SEE->( MsUnlock() )
	//EndIf

	nLote := VAL(SEE->EE_LOTECP)
 
	cAgencia  := STRTRAN(SEE->EE_AGENCIA,"-","")
	cDVAgenc  := SEE->EE_DVAGE
	cConta    := STRTRAN(SEE->EE_CONTA,"-","")
	cDVConta  := SEE->EE_DVCTA
ELSE
	u_MsgLog(cPerg,"Parâmetro do Banco "+cSEE+" não foi cadastrado!!",'E')
	Return nil
ENDIF

MakeDir(cDirTmp2)

cDirTmp2 += "\ITAU"

MakeDir(cDirTmp2)

cArqTmp := cDirTmp2+"\IT"

cArqTmp += STRZERO(nLote,6)

IF File(cArqTmp+".DOC")
   If !MsgYesNo("Ja existe arquivo(s) ("+cArqTmp+".DOC) neste local, deseja sobrepor?")
		Return nil
	EndIf
EndIf

fErase(cArqTmp+".DOC")
nHandle := MsfCreate(cArqTmp+".DOC",0)

cArqTmp += ".TXT"

IF File(cArqTmp)
   If !MsgYesNo("Ja existe arquivos ("+cArqTmp+") neste local, deseja sobrepor?")
		Return nil
	EndIf
EndIf


BncoTxt := ''
BncoTxt += '<table width="100%" align="CENTER" cellpadding="2" cellspacing="2" style="border-style:outset; border-width:1; padding-left:4px; padding-right:4px; padding-top:1px; padding-bottom:1px">'
BncoTxt += '<tr>'
BncoTxt += '<td align="center">Título</td>'
BncoTxt += '<td align="center">CNPJ/CPF</td>'
BncoTxt += '<td align="center">Nome</td>'
BncoTxt += '<td align="center">Agencia</td>'
BncoTxt += '<td align="center">Conta</td>'
BncoTxt += '<td align="center">Valor</td>'
BncoTxt += '</tr>'
	
fErase(cArqTmp)
nHandle2 := MsfCreate(cArqTmp,0)
				
If nHandle > 0 .OR. nHandle2 > 0
   	nValTot := 0
   	nQTot 	:= 0
   	BncoTxtT := ""

	If cBanco == "341"

		//REGISTRO HEADER DE ARQUIVO	
	
		Bcn341H := ""
		Bcn341H += "341"    		 			//001 003 CÓDIGO DO BCO NA COMPENSAÇÃO
		Bcn341H += "0000"   		 			//004 007 LOTE DE SERVIÇO
		Bcn341H += "0"               			//008 008 REGISTRO HEADER DE ARQUIVO
		Bcn341H += SPACE(6)          			//009 014 COMPLEMENTO DE REGISTRO
		Bcn341H += "080"			 			//015 017 N? DA VERSÃO DO LAYOUT DO ARQUIVO
		Bcn341H += "2"               			//018 018 TIPO DE INSCRIÇÃO DA EMPRESA 1 = CPF 2 = CNPJ
		Bcn341H += STRZERO(VAL(cCGC),14) 		//019 032 CNPJ EMPRESA DEBITADA
		Bcn341H += SPACE(20)  					//033 052 COMPLEMENTO DE REGISTRO
		Bcn341H += STRZERO(VAL(cAgencia),5)		//053 057 NÚMERO AGÊNCIA DEBITADA
		Bcn341H += SPACE(1)   					//058 058 COMPLEMENTO DE REGISTRO
		Bcn341H += "0000000"  					//059 070 NÚMERO DE C/C DEBITADA
		Bcn341H += SUBSTR(SEE->EE_CODEMP,1,5) 
		Bcn341H += SPACE(1)   					//071 071 COMPLEMENTO DE REGISTRO
		Bcn341H += SUBSTR(SEE->EE_CODEMP,6,1)	//072 072 DAC DA AGÊNCIA/CONTA DEBITADA
		Bcn341H += PAD(cNomeCom,30) 			//073 102 NOME DA EMPRESA
		Bcn341H += PAD("BANCO ITAU S.A.",30)  	//103 132 NOME DO BANCO
		Bcn341H += SPACE(10)                  	//133 142 COMPLEMENTO DE REGISTRO
		Bcn341H += "1"                        	//143 143 CÓDIGO REMESSA/RETORNO 1=REMESSA 2=RETORNO
												//144 151 DATA DE GERAÇÃO DO ARQUIVO
		Bcn341H += Day2Str(DATE())+Month2Str(DATE())+Year2Str(DATE())  
		cTime := TIME()
		cHora := SUBSTR(cTime, 1, 2)
		cMinutos := SUBSTR(cTime, 4, 2)
		cSegundos := SUBSTR(cTime, 7, 2)
		Bcn341H += cHora+cMinutos+cSegundos      //152 157 HORA DE GERAÇÃO DO ARQUIVO
		Bcn341H += "000000000"		             //158 166 COMPLEMENTO DE REGISTRO (ZEROS)
		Bcn341H += "00000"						 //167 171 DENSIDADE DE GRAVAÇÃO DO ARQUIVO
		Bcn341H += SPACE(69)                     //172 240 COMPLEMENTO DE REGISTRO
		Bcn341H += cCrLf
						
		//Grava Bordero Header
		fWrite(nHandle2,Bcn341H)
	
		// REGISTRO HEADER DE LOTE

		Bcn341HD := ""
		Bcn341HD += "341"        				//001 003 CÓDIGO DO BCO NA COMPENSAÇÃO
		Bcn341HD += "0001"       				//004 007 LOTE IDENTIFICAÇÃO DE PAGTOS
		Bcn341HD += "1"          				//008 008 REGISTRO HEADER DE LOTE
		Bcn341HD += "C"          				//009 009 TIPO DA OPERAÇÃO C=CRÉDITO
		Bcn341HD += "20"         				//010 011 TIPO DE PAGTO 20-FORNECEDORES 30-SALARIOS // IIf(cTipoPes == "CLT" .AND. nTEDItau == 2,"30","20")
		If cFormaPgto == "DEPOSITO"
			Bcn341HD += "01"       				//012 013 FORMA DE PAGAMENTO  01-CRÉDITO EM CONTA CORRENTE NO ITAÚ //IIF(nTEDItau == 1,"41","01") //IIF(cBanco=='341' .AND. cTipoPes == "CLT","01","41")  
		Else
			Bcn341HD += "45"       				//012 013 FORMA DE PAGAMENTO  45-PIX TRANSFERÊNCIA
		EndIf
		Bcn341HD += "040"        				//014 016 NUMERO DA VERSÃO DO LAYOUT DO LOTE
		Bcn341HD += SPACE(1)     				//017 017 COMPLEMENTO DE REGISTRO
		Bcn341HD += "2"          				//018 018 TIPO INSCRIÇÃO EMPRESA DEBITADA 1 = CPF 2 = CNPJ
		Bcn341HD += STRZERO(VAL(cCGC),14) 		//019 032 CNPJ EMPRESA DEBITADA
		Bcn341HD += SPACE(13)    				//033 045 IDENTIFICAÇÃO DO LANÇAMENTO NO EXTRATO DO FAVORECIDO
		Bcn341HD += SPACE(7)	 				//046 052 COMPLEMENTO DE REGISTRO
		Bcn341HD += STRZERO(VAL(cAgencia),5)	//053 057 NÚMERO AGÊNCIA DEBITADA
		Bcn341HD += SPACE(1)     				//058 058 COMPLEMENTO DE REGISTRO
		Bcn341HD += "0000000"    				//059 070 NÚMERO DE C/C DEBITADA
		Bcn341HD += SUBSTR(SEE->EE_CODEMP,1,5)	
		Bcn341HD += SPACE(1)   					//071 071 COMPLEMENTO DE REGISTRO
		Bcn341HD += SUBSTR(SEE->EE_CODEMP,6,1) 	//072 072 DAC DA AGÊNCIA/CONTA DEBITADA

		Bcn341HD += PAD(cNomeCom,30)			//073 102 NOME DA EMPRESA DEBITADA
		Bcn341HD += SPACE(30) 					//103 132 FINALIDADE DOS PAGTOS DO LOTE
		Bcn341HD += SPACE(10) 					//133 142 COMPLEMENTO HISTÓRICO C/C DEBITADA
		Bcn341HD += PAD(ACENTO(ALLTRIM(SM0->M0_ENDCOB)),30)  //143 172 NOME DA RUA, AV, PÇA, ETC...
		Bcn341HD += "00000"		                             //173 177 NÚMERO DO LOCAL
		Bcn341HD += PAD(ACENTO(ALLTRIM(SM0->M0_COMPENT)),15) //178 192 CASA, APTO, SALA, ETC...
		Bcn341HD += PAD(ACENTO(ALLTRIM(SM0->M0_CIDCOB)),20)  //193 212 NOME DA CIDADE
		Bcn341HD += PAD(SM0->M0_CEPCOB,8)                    //213 220 CEP
		Bcn341HD += PAD(SM0->M0_ESTCOB,2)                    //221 222 SIGLA DO ESTADO
		Bcn341HD += SPACE(8)                                 //223 230 COMPLEMENTO DE REGISTRO
		Bcn341HD += SPACE(10)                                //231 240 CÓDIGO OCORRÊNCIAS P/RETORNO
		Bcn341HD += cCrLf
						
		//Grava Bordero Header
		fWrite(nHandle2,Bcn341HD)
		nSeq := 0

		For nI:=1 To Len(aTitGer)
					
			nValTot += INT(aTitGer[nI,CP_SALDO]*100)
			nQTot++
			nSeq++
		
			BncoTxtT := cNomeCom+'<BR>RELAÇÃO BANCÁRIA BANCO ITAU - <b> Lote: '+STRZERO(nLote,8)+'</b><BR> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=1><i>Emitida em : '+DTOC(dDataBase)+' - pelo usuário : '+cUserName+'</i><br><br>&nbsp;'

			// REGISTRO DETALHE - SEGMENTO A - OBRIGATÓRIO

		    Bcn341D := ""
			Bcn341D += "341"     					  	//001 003 CÓDIGO BANCO NA COMPENSAÇÃO
			Bcn341D += "0001"   					  	//004 007 LOTE DE SERVIÇO
			Bcn341D += "3"       					  	//008 008 REGISTRO DETALHE DE LOTE
			Bcn341D += STRZERO(nSeq,5)  			  	//009 013 NUMERO SEQUENCIAL REGISTRO NO LOTE
			Bcn341D += "A"              			  	//014 014 CÓDIGO SEGMENTO REG. DETALHE
			Bcn341D += IIF(aTitGer[nI,CP_TIPOP]='F',"001","002")     
									       		      	//015 017 TIPO DE MOVIMENTO - Verificação de dados - CPF 001 verifica, 000 Não verifica,CNPJ 002 verifica
			If cFormaPgto == "PIX"
				Bcn341D += "009"           			  	//018 020 CÓDIGO DA CÂMARA CENTRALIZADORA - NOTA 35
			Else
				Bcn341D += "000"           			  	//018 020 CÓDIGO DA CÂMARA CENTRALIZADORA
			EndIf

			Bcn341D += "341"							//021 023 CÓDIGO BANCO FAVORECIDO
			If cFormaPgto == "PIX"
				Bcn341D += SPACE(20)                   	//029 029 COMPLEMENTO DE REGISTRO
			Else
				Bcn341D += "0"             			  	//024 024 COMPLEMENTO DE REGISTRO (NOTA 11)
														//025 028 NÚMERO AGÊNCIA CREDITADA
				Bcn341D += STRZERO(VAL(aTitGer[nI,CP_AGENCIA]),4)  	
				Bcn341D += SPACE(1)                    	//029 029 COMPLEMENTO DE REGISTRO
				Bcn341D += "000000"						//030 035 COMPLEMENTO DE REGISTRO
														//036 041 NÚMERO DE C/C CREDITADA 
				Bcn341D += STRZERO(VAL(aTitGer[nI,CP_CONTA]),6) 
				Bcn341D += SPACE(1) 					//042 042 COMPLEMENTO DE REGISTRO
														//043 043 DAC DA AGÊNCIA/CONTA CREDITADA
			EndIf
			Bcn341D += STRZERO(VAL(aTitGer[nI,CP_DIGITO]),1)
														//044 073 NOME DO FAVORECIDO
			Bcn341D += PAD(Acento(aTitGer[nI,CP_NOME]),30) 
			Bcn341D += SPACE(20) 						//074 088 NUMERO DOCTO ATRIBUÍDO PELA EMPRESA
														//094 101 DATA PREVISTA PARA PAGTO
			Bcn341D += Day2Str(aTitGer[nI,CP_VENC])+Month2Str(aTitGer[nI,CP_VENC])+Year2Str(aTitGer[nI,CP_VENC]) 
			Bcn341D += "REA"  							//102 104 TIPO DA MOEDA
			Bcn341D += SPACE(8)							//105 112 IDENTIFICAÇÃO DA INSTITUIÇÃO PARA O SPB
			If cFormaPgto == "PIX"
				Bcn341D += "04"							//113 114 CONTA PAGAMENTO / PIX: 01 - Conta corrente, PG - Conta Pagamento, 03 – Conta Poupança, 04 – Chave Pix
			Else
				Bcn341D += SPACE(2)						//113 114 CONTA PAGAMENTO / PIX
			EndIf
			Bcn341D += "00000"							//115 119 COMPLEMENTO DE REGISTRO
														//120 134 VALOR PREVISTO DO PAGTO
		    Bcn341D += STRZERO(INT(aTitGer[nI,CP_SALDO]*100),15) 
			Bcn341D += SPACE(15)   						//135 149 NUMERO DOCTO ATRIBUÍDO PELO BANCO
			Bcn341D += SPACE(5)   						//150 154 COMPLEMENTO DE REGISTRO
			Bcn341D += STRZERO(0,8)						//155 162 DATA REAL EFETIVAÇÃO DO PAGTO
			Bcn341D += STRZERO(0,15)    				//163 177 VALOR REAL EFETIVAÇÃO DO PAGTO
			Bcn341D += SPACE(20)						//178 197 INFORMAÇÃO COMPLEMENTAR P/ HIST. DE C/C
			Bcn341D += STRZERO(0,6)					 	//198 203 NUMERO DO DOC/TED/ OP/ CHEQUE NO RETORNO
														//204 217 NUMERO DE INSCRIÇÃO DO FAVORECIDO (CPF/CNPJ)
			Bcn341D += STRZERO(VAL(aTitGer[nI,CP_CNPJ]),14)
			Bcn341D += SPACE(2)							//218 219 FINALIDADE DO DOC E STATUS DO FUNCIONÁRIO NA EMPRESA
			Bcn341D += SPACE(5)							//220 224 FINALIDADE DA TED
			Bcn341D += SPACE(5)							//225 229 COMPLEMENTO DE REGISTRO
			Bcn341D += SPACE(1)							//230 230 AVISO AO FAVORECIDO
			Bcn341D += SPACE(10)						//231 240 CÓDIGO OCORRÊNCIAS NO RETORNO
			Bcn341D += cCrLf

			//Grava Bordero Detalhe - Segmento A
			fWrite(nHandle2,Bcn341D)
		 					 						    

			// REGISTRO DETALHE - SEGMENTO B - OBRIGATÓRIO PARA PIX
			If cFormaPgto == "PIX"
				nQTot++
				nSeq++

				Bcn341D := ""
				Bcn341D += "341"     					  	//001 003 CÓDIGO BANCO NA COMPENSAÇÃO
				Bcn341D += "0001"   					  	//004 007 LOTE DE SERVIÇO
				Bcn341D += "3"       					  	//008 008 REGISTRO DETALHE DE LOTE
				Bcn341D += STRZERO(nSeq,5)  			  	//009 013 NUMERO SEQUENCIAL REGISTRO NO LOTE
				Bcn341D += "B"              			  	//014 014 CÓDIGO SEGMENTO REG. DETALHE
				Bcn341D += aTitGer[nI,CP_TPPIX]				//015 016 TIPO IDENTIFICAÇÃO DE CHAVE PIX NOTA 37
				Bcn341D += SPACE(1)							//017 017 COMPLEMENTO DE REGISTRO
															//018 018 TIPO INSCRIÇÃO DO FAVORECIDO 1=CPF 2=CNPJ
				Bcn341D += IIF(aTitGer[nI,CP_TIPOP]='F',"1","2") 
															//019 032 Nº DE INSCRIÇÃO DO FAVORECIDO (CPF/CNPJ) NOTA 15
				Bcn341D += STRZERO(VAL(aTitGer[nI,CP_CNPJ]),14)
				Bcn341D += SPACE(30)						//033 062 COMPLEMENTO DE REGISTRO

				Bcn341D += SPACE(65)						//063 127 INFORMAÇÃO ENTRE USUÁRIOS NOTA 39

				Bcn341D += PAD(aTitGer[nI,CP_CHPIX],100)	//128 227 CHAVE DE ENDEREÇAMENTO NOTA 40
				Bcn341D += SPACE(3)							//228 230 COMPLEMENTO DE REGISTRO
				Bcn341D += SPACE(10)						//231 240 CÓDIGO DE OCORRÊNCIAS NO RETORNO NOTA 8

				//Grava Bordero Detalhe - Segmento B
				fWrite(nHandle2,Bcn341D)
			EndIf

			BncoTxt += '<tr>'
			BncoTxt += '<td align="center">'+aTitGer[nI,CP_PREFIXO]+aTitGer[nI,CP_NUMERO]+aTitGer[nI,CP_PARCELA]+'</td>'
			BncoTxt += '<td align="center">'+TRANSFORM(aTitGer[nI,CP_CNPJ],IIF(aTitGer[nI,CP_TIPOP]=='J','@R 99.999.999/9999-99','@R 999.999.999-99'))+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,CP_NOME]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,CP_AGENCIA]+'</td>'
			BncoTxt += '<td align="center">'+aTitGer[nI,CP_CONTA]+'</td>'
			BncoTxt += '<td align="center">'+TRANSFORM(aTitGer[nI,CP_SALDO],"@E 999,999,999.99")+'</td>'
			BncoTxt += '</tr>'

    		cQuery 	:= " UPDATE "+RETSQLNAME("SE2")+" SET E2_XXLOTEB = '"+STRZERO(nLote,6)+"' "
			cQuery  += " WHERE R_E_C_N_O_="+STR(aTitGer[nI,CP_REGSE2],10)  
    		TcSqlExec(cQuery)

		NEXT
				
		BncoTxtT+= BncoTxt+'<tr><td colspan="6">&nbsp;</td></tr><tr><td colspan="5" align="right">TOTAL DE <b>'+ STR(nQTot,6) +'</b> PAGAMENTOS NO VALOR TOTAL DE R$</td><td align="center"><b>'+TRANSFORM((nValTot/100),"@E 999,999,999.99")+'</b></td></tr></table>'

		// REGISTRO TRAILER DE LOTE
		nSeq++
		nSeq++
		Bcn341TD := ""
		Bcn341TD += "341"    			//001 003 CÓDIGO BANCO NA COMPENSAÇÃO
		Bcn341TD += "0001"   			//004 007 LOTE DE SERVIÇO
		Bcn341TD += "5"      			//008 008 REGISTRO TRAILER DE LOTE
		Bcn341TD += SPACE(9) 			//009 017 COMPLEMENTO DE REGISTRO
		Bcn341TD += STRZERO(nSeq,6)  	//018 023 QTDE REGISTROS DO LOTE
		Bcn341TD += STRZERO(nValTot,18)	//024 041 SOMA VALOR DOS PGTOS DO LOTE

		Bcn341TD += STRZERO(0,18)     	//042 059 COMPLEMENTO DE REGISTRO
		Bcn341TD += SPACE(181)        	//060 240 COMPLEMENTO DE REGISTRO + OCORRENCIAS P/ RETORNO
		Bcn341TD += cCrLf 
	
		//Grava Bordero Trailer
		fWrite(nHandle2,Bcn341TD)

		//REGISTRO TRAILER DE ARQUIVO

		nSeq++
		nSeq++
		Bcn341T := ""
		Bcn341T += "341"   				//001 003 CÓDIGO BANCO NA COMPENSAÇÃO
		Bcn341T += "9999"  				//004 007 LOTE DE SERVIÇO
		Bcn341T += "9"     				//008 008 REGISTRO TRAILER DE ARQUIVO
		Bcn341T += SPACE(9) 			//009 017 COMPLEMENTO DE REGISTRO
		Bcn341T += "000001" 			//018 023 QTDE LOTES DO ARQUIVO
		Bcn341T += STRZERO(nSeq,6) 		//024 029 QTDE REGISTROS DO ARQUIVO
		Bcn341T += SPACE(211)      		//030 240 COMPLEMENTO DE REGISTRO
		Bcn341T += cCrLf 
					
		//Grava Bordero Trailer
		fWrite(nHandle2,Bcn341T)
 
 		//Fechar Bordero
		fClose(nHandle2)
	ENDIF
	
	//Grava e Fechar Doc 
	fWrite(nHandle,BncoTxtT)
	fClose(nHandle)
	cNumBor := ""

	// Descomentar para Ativar
	//If !u_IsTeste()
		u_WaitLog(cPerg,{|| cNumBor := RunBordero(aTitGer,cBanco,cAgencia,cConta,dData,nLote)})
	//EndIf
	
	cMsgLog := 'Borderô Nº: '+cNumBor+' gerado com sucesso: "'+cArqTmp+'"'
	u_MsgLog(cPerg,cMsgLog,"S")

ELSE
	IF nHandle <> 0
		//cArqTmp := cDirTmp2+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+cGrupo+"_"+cBanco+"_"+DTOS(dData)+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+"RELACAO_BANCARIA_"+cGrupo+"_"+cBanco+"_"+DTOS(dData)+".DOC"
		cMsgLog := "Falha na criação do arquivo "+cArqTmp
		u_MsgLog(cPerg,cMsgLog,"E")
	ENDIF
	IF nHandle2 <> 0
		//cArqTmp := cDirTmp+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+cGrupo+"_"+cBanco+"_"+DTOS(dData)+"\"+IIF(nFurnas==1,"FURNAS_","")+IIF(nFurnas==2,"FURNAS_LBK_","")+"REMESSA_"+cGrupo+"_"+cBanco+"_"+DTOS(dData)+".TXT"
		cMsgLog := "Falha na criação do arquivo "+cArqTmp
		u_MsgLog(cPerg,cMsgLog,"E")
	ENDIF
ENDIF

Return nil 



Static Function ProcGer1()
Local cQuery
Local aTitBor 	:= {}
Local aTitTmp   := {}

If SELECT("QSE2") > 0 
	dbSelectArea("QSE2")
   	dbCloseArea()
EndIf

cQuery := "WITH BORDERO AS ( " + CRLF

cQuery += " SELECT "+CRLF
cQuery += "	  '"+cEmpAnt+"' AS EMPRESA"+CRLF
cQuery += "	 ,'"+FWEmpName(cEmpAnt)+"' AS NOMEEMP"+CRLF
cQuery += "	 ,E2_TIPO"+CRLF
cQuery += "	 ,E2_PREFIXO"+CRLF
cQuery += "	 ,E2_NUM"+CRLF
cQuery += "	 ,E2_PARCELA"+CRLF
cQuery += "	 ,E2_FORNECE"+CRLF
cQuery += "	 ,E2_PORTADO"+CRLF
cQuery += "	 ,E2_LOJA"+CRLF
cQuery += "	 ,E2_NATUREZ"+CRLF
cQuery += "	 ,E2_HIST"+CRLF
cQuery += "	 ,E2_USERLGI"+CRLF 
cQuery += "	 ,E2_BAIXA"+CRLF
cQuery += "	 ,E2_EMISSAO"+CRLF
cQuery += "	 ,E2_VENCREA"+CRLF
cQuery += "	 ,E2_VALOR"+CRLF
cQuery += "	 ,E2_XXPRINT"+CRLF
cQuery += "	 ,E2_XXTIPBK"+CRLF
cQuery += "	 ,E2_NUMBOR"+CRLF
cQuery += "	 ,SE2.R_E_C_N_O_ AS REGSE2"+CRLF
cQuery += "	 ,A2_NOME"+CRLF
cQuery += "	 ,A2_TIPO"+CRLF
cQuery += "	 ,A2_CGC"+CRLF

cQuery += "	 ,(CASE WHEN E2_SALDO = E2_VALOR "+CRLF
cQuery += "	 		THEN E2_VALOR + E2_ACRESC - E2_DECRESC"+CRLF
cQuery += "	 		ELSE E2_SALDO END) AS SALDO"+CRLF

cQuery += "	 ,F1_XTIPOPG AS FORMPGT"+CRLF

cQuery += "	 ,F1_DOC"+CRLF
cQuery += "	 ,F1_XNUMPA"+CRLF
cQuery += "	 ,F1_XBANCO"+CRLF
cQuery += "	 ,F1_XAGENC"+CRLF
cQuery += "	 ,F1_XNUMCON"+CRLF
cQuery += "	 ,F1_XXTPPIX"+CRLF
cQuery += "	 ,F1_XXCHPIX"+CRLF
cQuery += "	 ,F1_USERLGI"+CRLF 
cQuery += "	 ,F1_XXUSER"+CRLF

cQuery += "	 FROM "+RetSqlName("SE2")+" SE2 "+CRLF

cQuery += "	 LEFT JOIN "+RetSqlName("SF1")+" SF1 ON"+CRLF
cQuery += "	 	SE2.E2_FILIAL      = SF1.F1_FILIAL"+CRLF
cQuery += "	 	AND SE2.E2_NUM     = SF1.F1_DOC "+CRLF
cQuery += "	 	AND SE2.E2_PREFIXO = SF1.F1_SERIE"+CRLF
cQuery += "	 	AND SE2.E2_FORNECE = SF1.F1_FORNECE"+CRLF
cQuery += "	 	AND SE2.E2_LOJA    = SF1.F1_LOJA"+CRLF
cQuery += "	 	AND SF1.D_E_L_E_T_ = ''"+CRLF

cQuery += "	 LEFT JOIN "+RetSqlName("SA2")+"  SA2 ON"+CRLF
cQuery += "	 	SA2.A2_FILIAL      = '  '"+CRLF
cQuery += "	 	AND SE2.E2_FORNECE = SA2.A2_COD"+CRLF
cQuery += "	 	AND SE2.E2_LOJA    = SA2.A2_LOJA"+CRLF
cQuery += "	 	AND SA2.D_E_L_E_T_ = ''"+CRLF

cQuery += "	 WHERE SE2.D_E_L_E_T_ = '' "+ CRLF
cQuery +=  "  AND E2_VENCREA = '"+DTOS(dData)+"' "+CRLF
cQuery +=  "  AND (F1_XTIPOPG = 'DEPOSITO' OR F1_XTIPOPG = 'PIX') "+CRLF
cQuery +=  "  AND E2_PORTADO = '"+cBanco+"' "+CRLF

cQuery += ")"+CRLF
cQuery += "SELECT " + CRLF
cQuery += "  * " + CRLF
cQuery += "  FROM BORDERO " + CRLF
cQuery += " ORDER BY FORMPGT,A2_NOME" + CRLF

u_LogMemo("BKFINR32.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QSE2"

TCSETFIELD("QSE2","E2_VENCREA","D",8,0)
TCSETFIELD("QSE2","E2_EMISSAO","D",8,0)

// Valor total mostrado na tela
nTotal := 0

// Populando array
Dbselectarea("QSE2")
QSE2->(Dbgotop())

Do While !eof()
	aTitTmp := Array(CP_CAMPOS)
	nTotal  += IIF(EMPTY(QSE2->E2_NUMBOR) .AND. QSE2->SALDO > 0,QSE2->SALDO,0)

	aTitTmp[CP_MARK] 	:= IIF(EMPTY(QSE2->E2_NUMBOR) .AND. QSE2->SALDO > 0,.T.,.F.)
	aTitTmp[CP_NUMBOR]	:= QSE2->E2_NUMBOR
	aTitTmp[CP_BANCO]	:= QSE2->E2_PORTADO
	aTitTmp[CP_FORMA]	:= QSE2->FORMPGT
	aTitTmp[CP_PREFIXO]	:= QSE2->E2_PREFIXO
	aTitTmp[CP_NUMERO]	:= QSE2->E2_NUM
	aTitTmp[CP_PARCELA]	:= QSE2->E2_PARCELA
	aTitTmp[CP_TIPO]	:= QSE2->E2_TIPO
	aTitTmp[CP_PGTO]	:= QSE2->E2_XXTIPBK
	aTitTmp[CP_EMISSAO]	:= QSE2->E2_EMISSAO
	aTitTmp[CP_VENC]	:= QSE2->E2_VENCREA
	aTitTmp[CP_CSALDO]	:= TRANS(QSE2->SALDO,cPictVal)
	aTitTmp[CP_NOME]	:= QSE2->A2_NOME
	aTitTmp[CP_FORNECE]	:= QSE2->E2_FORNECE
	aTitTmp[CP_LOJA]	:= QSE2->E2_LOJA
	aTitTmp[CP_TIPOP]	:= QSE2->A2_TIPO
	aTitTmp[CP_SALDO]	:= QSE2->SALDO
	aTitTmp[CP_AGENCIA]	:= QSE2->F1_XAGENC
	aTitTmp[CP_CONTA]	:= Conta341(QSE2->F1_XNUMCON)
	aTitTmp[CP_DIGITO]	:= Digito341(QSE2->F1_XNUMCON) 
	aTitTmp[CP_CNPJ]	:= TRIM(QSE2->A2_CGC)
	aTitTmp[CP_TPPIX]	:= QSE2->F1_XXTPPIX
	aTitTmp[CP_CHPIX]	:= Pix341(QSE2->F1_XXTPPIX,QSE2->F1_XXCHPIX)
	aTitTmp[CP_REGSE2]	:= QSE2->REGSE2

	AADD(aTitBor, aTitTmp)

	QSE2->(DbSkip())
Enddo

//ASORT(aTitBor,,,{|x,y| x[3]<y[3]})

Return aTitBor


// Pegar a conta Itau
Static Function Conta341(cConta)
Local cxConta := ''
Local nX := 0
For nX := 1 To (Len(Trim(cConta))-1)
	If Substr(cConta,nX,1) $ "0123456789"
		cxConta += Substr(cConta,nX,1)
	EndIf
Next
Return STRZERO(VAL(cxConta),6)


// Pegar o digito da conta Itau
Static Function Digito341(cConta)
Local cDig := ' '
If !Empty(cConta)
	cDig := SUBSTRING(cConta,LEN(ALLTRIM(cConta)),1)
EndIf
Return cDig


/* Tratamento das chaves Pix

01 – Telefone
02 – E-mail
03 – CPF/CNPJ
04 – Chave Aleatória

Número de telefone +XXXXXXXXXXXXX 					inicia com "+", seguido do código do país, DDD, e número de celular com nove dígitos.
Endereço de e-mail xxxxxxxx@xxxxxxx.xxx(.xx) 		contém "@", e o tamanho máximo é de 77 caracteres.
CPF XXXXXXXXXXX 									contém 11 números, incluindo os dígitos verificadores.
													Deve ser informado sem pontos ou traços.
CNPJ XXXXXXXXXXXXXX 								contém 14 números, incluindo os dígitos verificadores.
													Deve ser informado sem pontos ou traços.
Chave aleatória XXXXXXXX-XXXX-XXXXXXXX-XXXXXXXXXXXX	número hexadecimal de 32 posições, divido em 5
													blocos separados por um “-“. Deve ser informado com
													os traços, ou seja com as 36 posições totais.
*/
Static Function Pix341(cTipo,cChave)
Local cOldChave := ALLTRIM(cChave)
Local cNewChave := ""
Local cxChave 	:= ""
Local nI		:= 0

If cTipo == '01' // Telefone
	For nI := 1 To LEN(cOldChave)
		If Substr(cOldChave,nI,1) $ "0123456789"
			cxChave += Substr(cOldChave,nI,1)
		EndIf
	Next
	If LEN(cxChave) == 13 .AND. Substr(cxChave,1,2) == '55'
		// Exemplo: 5513981014636
		cNewChave := "+"+cxChave
	ElseIf LEN(cxChave) == 11
		// Exemplo: 31945426802
		cNewChave := "+55"+cxChave
	Else
		cNewChave := "Erro: "+cxChave
	EndIf
ElseIf cTipo = '02' // E-mail
	cxChave := cOldChave
	If !"@" $ cxChave
		cNewChave := "Erro: @ "+cxChave
	ElseIf Len(cxChave) > 77
		cNewChave := "Erro: 77 "+cxChave 
	Else 
		cNewChave := Lower(cxChave)
	EndIf

ElseIf cTipo = '03' // CPF/CNPJ
	For nI := 1 To LEN(cOldChave)
		If Substr(cOldChave,nI,1) $ "0123456789"
			cxChave += Substr(cOldChave,nI,1)
		EndIf
	Next
	If LEN(cxChave) < 11
		cxChave := STRZERO(VAL(cxChave),11)
	ElseIf LEN(cxChave) < 14
		cxChave := STRZERO(VAL(cxChave),14)
	EndIf
	cNewChave := cxChave
ElseIf cTipo = '04' // Chave Aleatória
	cNewChave := cOldChave
EndIf
Return cNewChave


Static Function Acento( cTexto )
Local cAcentos:= "Ç ç Ä À Â Ã Å à á ã ä å É È Ê Ë è é ê ë Ì Í Î Ï Ò Ó Ô Õ Ö ò ó ô õ ö Ù Ú Û Ü ù ú û ü Ñ ñ , ; "
Local cAcSubst:= "C c A A A A A a a a a a E E E E e e e e I I I I O O O O O o o o o o U U U U u u u u N n     "
Local cImpCar := ""
Local cImpLin := ""
Local nChar   := 0.00
Local nChars  := 0.00
Local nAt     := 0.00     

cTexto := IF( Empty( cTexto ) .or. ValType( cTexto ) != "C", "" , cTexto )

nChars := Len( cTexto )
For nChar := 1 To nChars
     cImpCar := SubStr( cTexto , nChar , 1 )
     IF ( nAt := At( cImpCar , cAcentos ) ) > 0
          cImpCar := SubStr( cAcSubst , nAt , 1 )
     EndIF
     cImpLin += cImpCar
Next nChar

Return( cImpLin )



Static Function ValidPerg(cPerg)
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Data:" ,"Data:"  ,"Data:"  ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Banco:","Banco:" ,"Banco:" ,"mv_ch2","C",26,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SEE_2"})
AADD(aRegistros,{cPerg,"03","Pasta (Diretório):","Pasta (Diretório):" ,"Pasta (Diretório):" ,"mv_ch3","C",40,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})

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

Return(NIL)




Static Function RunBordero(aTitGer,cBanco,cAgencia,cConta,dData,nLote)
Local _nI 		:= 0
Local cNBor 	:= ""
Local cNumBor	:= ""

// Verificar o numero do ultimo Bordero gerado
cNumBor := Soma1(Pad(GetMV("MV_NUMBORP"),Len(SE2->E2_NUMBOR)),Len(SE2->E2_NUMBOR))
While !MayIUseCode( "E2_NUMBOR"+xFilial("SE2")+cNumBor)  //verifica se esta na memoria, sendo usado
	cNumBor := Soma1(cNumBor)							 // busca o proximo numero disponivel 
EndDo                                           

For _nI:=1 To Len(aTitGer)
	IF !EMPTY(aTitGer[_nI,CP_REGSE2])
		dbSelectArea("SE2")
		dbGoTo(aTitGer[_nI,CP_REGSE2])
		IF EMPTY(SE2->E2_NUMBOR)
			dbSelectArea("SEA")
			RecLock("SEA",.T. )
			Replace	SEA->EA_FILIAL  With xFilial("SEA"),;
					SEA->EA_PORTADO With cBanco,;
					SEA->EA_AGEDEP  With SEE->EE_AGENCIA,;//cAgencia,;
					SEA->EA_NUMCON  With SEE->EE_CONTA,;//cConta,;
					SEA->EA_NUMBOR  With cNumBor,;
					SEA->EA_DATABOR With dData,;
					SEA->EA_PREFIXO With aTitBor[_nI,4],;
					SEA->EA_NUM     With aTitBor[_nI,5],;
					SEA->EA_PARCELA With aTitBor[_nI,6],;
					SEA->EA_TIPO    With aTitBor[_nI,7],;
					SEA->EA_FORNECE With aTitBor[_nI,13],;
					SEA->EA_LOJA	With aTitBor[_nI,14],;
					SEA->EA_CART    With "P",;
					SEA->EA_MODELO  With "01",;
					SEA->EA_TIPOPAG With "98",;
					SEA->EA_SITUANT	With "X",;			
					SEA->EA_FILORIG With SE2->E2_FILIAL
			MsUnlock()
			FKCOMMIT()
		
			RecLock("SE2")
			SE2->E2_NUMBOR  := cNumBor
			//SE2->E2_XXLOTEB := STRZERO(nLote,6)
			MsUnlock( )
			FKCOMMIT()
		ENDIF
	ENDIF
NEXT

// Gravar o numero do bordero atualizado
// Utilizar sempre GetMv para posicionar o SX6. não use SEEK !!!

cNBor := GetMv("MV_NUMBORP")
// Garantir que o numero do bordero seja sempre superior ao numero anterior
If cNBor < cNumbor
	PutMv("MV_NUMBORP",cNumbor)
EndIf

Return cNumBor
