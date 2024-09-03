#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKFATR05
BK - Impressão de pedido de venda
@Return
@author Marcos Bispo Abrahão
@since 14/10/2020
@version P12
/*/

// Chamada no Doc de Saída - Consulta posicionado
User Function BKFATR5B()  
Local aArea     := GetArea()
Local aAreaSC5  := GetArea("SC5")

cPed := SC9->C9_PEDIDO
If SC5->(dbSeek(xFilial("SC5")+cPed))
    u_BKFATR05()
EndIf

SC5->(RestArea(aAreaSC5))
RestArea(aArea)

Return Nil



User Function BKFATR5M()  
Local aArea     := GetArea()
Local aPeds		:= {}
Local cQuery	:= ""

cQuery := "SELECT DISTINCT C9_PEDIDO"
cQuery += " FROM "+RETSQLNAME("SC9")+" SC9"
cQuery += " WHERE SC9.D_E_L_E_T_ ='' AND C9_FILIAL = '"+xFilial("SC9")+"' "
If oMark:lInvert
	cQuery += " AND C9_OK <> '"+oMark:cMark+"' "
Else
	cQuery += " AND C9_OK = '"+oMark:cMark+"' "
EndIf

TCQUERY cQuery NEW ALIAS "QSC9"
	
QSC9->(dbGoTop())
While !QSC9->(Eof())
	aAdd(aPeds,QSC9->C9_PEDIDO)
	QSC9->(dbSkip())
EndDo
QSC9->(dbCloseArea()) 

If Len(aPeds) > 0
    u_BKFATR05(aPeds)
EndIf

RestArea(aArea)

Return Nil




// Chamada na Medição
User Function BKFATR5C()
Local aPeds		:= {}  
Local aArea     := GetArea()
Local aAreaSC5  := GetArea("SC5")
Local aAreaCNE  := GetArea("CNE")

cPed := CND->CND_PEDIDO
If SC5->(dbSeek(xFilial("SC5")+cPed))
    u_BKFATR05()
Else
	// Nova Medição
	dbSelectArea("CNE")
	dbSetOrder(4)
	dbSeek(CND->CND_FILIAL+CND->CND_NUMMED,.T.)
	Do While !CNE->(Eof()) .AND. CNE->CNE_NUMMED == CND->CND_NUMMED
		If !Empty(CNE->CNE_PEDIDO) .AND. aScan(aPeds,{|x| x == CNE->CNE_PEDIDO}) == 0
			aAdd(aPeds,CNE->CNE_PEDIDO)
		EndIf
		CNE->(dbSkip())
	EndDo
	CNE->(RestArea(aAreaCNE))
	If Len(aPeds) == 0
    	u_MsgLog("BKFATR5C","Pedidos não encontrados!","E")
	Else
		u_BKFATR05(aPeds)
	EndIf
EndIf

SC5->(RestArea(aAreaSC5))
RestArea(aArea)

Return Nil



// Chamada no cad de pedidos
User Function BKFATR05(aPeds) 
Local aArea     := GetArea()
Local aAreaSC5  := GetArea("SC5")
Local nHandle   := 0
Local cCrLf     := Chr(13) + Chr(10)
Local cDirTmp   := "C:\TMP"
Local cArqHtml  := ""
Local aHtml     := {}
Local _nI       := 0
Local _nJ       := 0
Local cPed		:= ""


If ValType(aPeds) <> "A"
	cArqHtml  := cDirTmp+"\"+"PED"+ALLTRIM(SC5->C5_NUM)+".HTML"
Else
	cArqHtml  := cDirTmp+"\"+"PED"+DTOS(dDataBase)+".HTML"
EndIf

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   

fErase(cArqHtml)
nHandle := MsfCreate(cArqHtml,0)
If nHandle > 0
	If ValType(aPeds) == "A"
		For _nJ := 1 TO LEN(aPeds)
			cPed := aPeds[_nJ]
			If SC5->(dbSeek(xFilial("SC5")+cPed))
				u_WaitLog(, {|oSay| aHtml := PedHtml() }, "BKFATR05 - Consultando pedidos: "+SC5->C5_NUM)
				For _nI := 1 TO LEN(aHtml)
					fWrite(nHandle, aHtml[_nI] + cCrLf )
				Next
			EndIf
		Next
	Else
		u_WaitLog(, {|oSay| aHtml := PedHtml() }, "BKFATR05 - Consultando pedido "+SC5->C5_NUM)
		//u_WaitLog(, {|oSay| _nI:= 1 }, "BKFATR05 - Gravando arquivo html "+SC5->C5_NUM)
		For _nI := 1 TO LEN(aHtml)
			fWrite(nHandle, aHtml[_nI] + cCrLf )
		Next
	EndIf
	fClose(nHandle)
	//u_WaitLog(, {|oSay| _nI:= 1 }, "BKFATR05 - Abrindo arquivo html "+SC5->C5_NUM)
	ShellExecute("open", cArqHtml, "", "", 1)
EndIf
SC5->(RestArea(aAreaSC5))
RestArea(aArea)
Return


// Impressão HTML de um pedido de vendas
User Function BKFATR5A()
Local cTitulo := "Impostos PV"
Local cPed := SPACE(TamSx3("C5_NUM")[1])

//--------------------------------
Private aParam		:=	{}
Private aRet		:=	{}

aAdd( aParam, { 1, "Pedido:"	, SPACE(TamSx3("C5_NUM")[1])	, ""            , "", "SC5"	, "" , 70  , .F. })
If (Parambox(aParam     ,@cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKTESTE",.T.         ,.T.))
	lRet       := .T.
	cPed     := mv_par01
else
   Return
EndIf

SC5->(DbSeek(xFilial("SC5")+cPed))
//--------------------------------
u_BKFATR05()

Return



// Retorna HTML de um pedido de vendas
User Function BKFATR5H(cPed)
Local aAreaAtu   := GetArea()
Local aHtml		 := {}
Local cHtml 	 := ""
Local nI		 := 0

Do While Len(cPed) < 6
	cPed := "0" + cPed
EndDo

dbSelectArea("SC5")
If SC5->(DbSeek(xFilial("SC5")+cPed))
	aHtml := PedHtml()
	For nI := 1 To Len(aHtml)
		cHtml += aHtml[nI]
	Next
Else
	cHtml := "Pedido não encontrado"
EndIf
RestArea(aAreaAtu)
Return cHtml



Static Function PedHtml()
Local aHtml     := {}
Local nPag      := 1
Local cLogo     := ""
Local nI        := 0
Local cPict     := "@E 99,999,999,999.99"
Local aFiles    := {}

// Dados da Empresa/Filial
Local cNomeCom  := ALLTRIM(SM0->M0_NOMECOM)
Local cEndereco := ALLTRIM(SM0->M0_ENDENT) + IIF(!EMPTY(SM0->M0_COMPENT)," - "+ALLTRIM(SM0->M0_COMPENT),"")
Local cCep      := "CEP: "+TRANSFORM(SM0->M0_CEPENT,"@R 99999-999")
Local cCidade   := ALLTRIM(SM0->M0_CIDENT)+" - "+SM0->M0_ESTENT
Local cTel      := "TEL: "+ALLTRIM(SM0->M0_TEL)
Local cCnpj     := "CNPJ: "+TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99")
Local cIE       := "I.E.: "+ALLTRIM(SM0->M0_INSC)
Local cSite     := IIF(SM0->M0_CODIGO == "01","WWW.BKCONSULTORIA.COM.BR","")

// Dados do CLiente
Local cNomeCli  := ""
Local cEndCli   := ""
Local cMunCli   := ""
Local cUFCli    := ""
Local cCepCli   := ""
Local cCNPJCli  := ""
Local cTipoTit  := "PEDIDO DE VENDA - "+SC5->C5_NUM

Local cEmissao  := DTOC(SC5->C5_EMISSAO)
Local cVencto   := "" //DTOC(SE1->E1_VENCTO)
Local cRM       := ALLTRIM(SC5->C5_XXRM)                
                    
Local cContra   := IIF(!EMPTY(SC5->C5_MDCONTR),SC5->C5_MDCONTR,SC5->C5_ESPECI1)
Local cCompAM   := SUBSTR(SC5->C5_XXCOMPM,4,4)+SUBSTR(SC5->C5_XXCOMPM,1,2)
Local cRev      := ""
Local cPedido	:= SC5->C5_NUM
Local cMedicao  := SC5->C5_MDNUMED
Local cPlan     := SC5->C5_MDPLANI
Local cParcel	:= ""
Local cObsMed   := ""
Local cObsNF    := ""
Local cEmissor  := ""
Local cDescCtr  := ""

Local cEstPres  := SC5->C5_ESTPRES
Local cMunPres  := SC5->C5_MUNPRES
Local cDescMun  := SC5->C5_DESCMUN
Local aTpNf     := {}
Local nTpNF     := 0
Local cTpNF     := SC5->C5_XXTPNF
Local cCompM    := SC5->C5_XXCOMPM
Local cNota     := SC5->C5_NOTA
Local cSerie    := SC5->C5_SERIE
Local cCliente  := SC5->C5_CLIENTE
Local cLoja     := SC5->C5_LOJACLI
Local cLiber    := SC5->C5_XXULIB
Local cNatureza := SC5->C5_NATUREZ
Local cMenPed	:= ALLTRIM(TRIM(SC5->C5_XXDNFS)+" "+SC5->C5_MENNOTA)
Local dEmisNF   := CTOD("")
Local cFaturis  := ""
Local aCNR		:= {}
Local cRefComp  := ""

// Itens
Local aItens    := {}
Local nItem     := 0

//Salvar as áreas
Local aAreaAtu   := GetArea()
Local aAreaCND   := GetArea("CND")  
Local aAreaSC6   := GetArea("SC6")  
Local aAreaSB1   := GetArea("SB1")  
Local aAreaSF4   := GetArea("SF4")  
Local aAreaSA1   := GetArea("SA1")  
Local aAreaCN9   := GetArea("CN9")  
Local aAreaSF2   := GetArea("SF2")  

// Variaveis auxiliares
Local aParc     := {}
//Local aTmp      := {}
//Local nReg      := 0

// Totalizadores
Local nTotVal   := 0

Local nTotLiq   := 0
Local nRetCtr   := 0
Local nValFat   := 0

// Impostos
Local nAlqCPM	:= 0 	// Aliquota do ISS CEPOM
Local cAlqCPM	:= ""
Local nValCpm   := 0    // Valor do ISS CEPOM
Local cRecIss   := ""   // Recolhe ISS
Local nValCof   := 0    // Valor do COFINS
Local nValCsl   := 0    // Valor do CSLL
Local nValPis   := 0    // Valor do PIS
Local nValIss   := 0    // Valor do ISS
Local nValIssR  := 0    // Valor do ISS Retido
Local nValIRR   := 0    // Valor do IR do item
Local nValIns   := 0    // Valor do INSS do item
Local aImpostos	:= {}	// Array contendo todos os impostos calculados na funcao Fiscal com quebra por impostos+aliquotas
Local nPInss	:= 0
Local nPIrrf	:= 0
Local cRetIr 	:= ""
Local cRetCli	:= "1"

// Dados do Cliente
SA1->(dbSetOrder(1))
If SA1->(dbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
	If RetPessoa(SA1->A1_CGC) == "F"
		cCNPJCli := Transform(SA1->A1_CGC,"@R 999.999.999-99")
	Else
		cCNPJCli := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
	Endif
	cNomeCli	:= AllTrim(SA1->A1_NOME)
	//cIMCli		:= SA1->A1_INSCRM
	cEndCli		:= AllTrim(SA1->A1_END)+IIF(!EMPTY(SA1->A1_BAIRRO)," - "+AllTrim(SA1->A1_BAIRRO),"")
	//cBairrCli	:= SA1->A1_BAIRRO
	cCepCli		:= AllTrim(SA1->A1_CEP)
	cMunCli		:= AllTrim(SA1->A1_MUN)
	//cCodMun		:= SA1->A1_COD_MUN
	cUFCli		:= AllTrim(SA1->A1_EST)
	//cEmailCli	:= SA1->A1_EMAIL
	If Empty(cNatureza)
		cNatureza := SA1->A1_NATUREZ
	EndIf
	If SA1->A1_RECIRRF = '2'
		cRetIr := "Emissor"
	Else 
		cRetIr := ""
	EndIf

	cRetCli := IIf(Empty(SA1->A1_ABATIMP),"1",SA1->A1_ABATIMP)

EndIf


//Calculo dos Impostos
MaFisIni(SC5->C5_CLIENTE,;                      // 01 – Codigo Cliente/Fornecedor
         SC5->C5_LOJACLI,;                      // 02 – Loja do Cliente/Fornecedor
         Iif(SC5->C5_TIPO $ "D;B", "F", "C"),;  // 03 – C:Cliente , F:Fornecedor
         SC5->C5_TIPO,;                         // 04 – Tipo da NF
         SC5->C5_TIPOCLI,;                      // 05 – Tipo do Cliente/Fornecedor
         MaFisRelImp("MT100", {"SF2", "SD2"}),; // 06 – Relacao de Impostos que suportados no arquivo
         ,;                                     // 07 – Tipo de complemento
         ,;                                     // 08 – Permite Incluir Impostos no Rodape .T./.F.
         "SB1",;                                // 09 – Alias do Cadastro de Produtos – ("SBI" P/ Front Loja)
         "MATA461")                             // 10 – Nome da rotina que esta utilizando a funcao

nItem := 0
//Enquanto houver itens
SC6->(DbSeek(xFilial('SC6') + SC5->C5_NUM))
While !SC6->(EoF()) .And. SC6->C6_NUM == SC5->C5_NUM
   nItem++
   SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))
   SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES))

   MaFisIniLoad(nItem,{ SC6->C6_PRODUTO,; //IT_PRODUTO
   SC6->C6_TES,; //IT_TES
   If(SF4->F4_ISS=="S", SC6->C6_CODISS , " " ) ,; //IT_CODISS
   SC6->C6_QTDVEN,; //IT_QUANT
   SC6->C6_NFORI,; //IT_NFORI
   SC6->C6_SERIORI,; //IT_SERIORI
   SB1->(RecNo()),; //IT_RECNOSB1
   SF4->(RecNo()),; //IT_RECNOSF4
   SC6->(RecNo()),; //IT_RECORI
   SC6->C6_LOTECTL,; //IT_LOTECTL
   SC6->C6_NUMLOTE }) //IT_NUMLOTE
   MaFisTes(SC6->C6_TES,SF4->(RecNo()),nItem) // Carrega a TES para a Matxfis

   MaFisLoad("IT_VALMERC", SC6->C6_VALOR, nItem)

   MaFisRecal("",nItem) // Neste caso o calculo dos impostos é disparado a partir dos valores carregados
   MaFisEndLoad(nItem,2) // Fecha o calculo do item e atualiza os totalizadores do cabeçalho

   /*
   nBasICM := MaFisRet(nItem, "IT_BASEICM")
   nValICM := MaFisRet(nItem, "IT_VALICM")
   nValIPI := MaFisRet(nItem, "IT_VALIPI")
   nAlqICM := MaFisRet(nItem, "IT_ALIQICM")
   nAlqIPI := MaFisRet(nItem, "IT_ALIQIPI")
   nValSol := (MaFisRet(nItem, "IT_VALSOL") / SC6->C6_QTDVEN)
   nBasSol := MaFisRet(nItem, "IT_BASESOL")
   nPrcUniSol := SC6->C6_PRCVEN + nValSol
   nTotSol := nPrcUniSol * SC6->C6_QTDVEN

   nAlqPIS := MaFisRet(nItem, "IT_ALIQPIS")
   nValPIS := MaFisRet(nItem, "IT_VALPS2")
   nAlqCOFINS := MaFisRet(nItem, "IT_ALIQCOF")
   nValCOFINS := MaFisRet(nItem, "IT_VALCF2")

   nTotCofins += nValCOFINS
   */
   nAlqCPM := MaFisRet(nItem, "IT_ALQCPM")

   AADD(aItens,{SC6->C6_PRODUTO,SB1->B1_DESC,SC6->C6_CODISS,SB1->B1_ALIQISS,SC6->C6_TES,SC6->C6_VALOR,nAlqCpm})

   nTotVal += SC6->C6_VALOR
   SC6->(DbSkip())
EndDo


//b01 := MaFisRet(,"NF_BASECPM")    // Base do ISS CEPOM
nValCpm := MaFisRet(,"NF_VALCPM")     // Valor do ISS CEPOM

//a01 := MaFisRet(,"NF_UFPREISS")   // UF da prestacao do servico do ISS onde o servico foi prestado
//a02 := MaFisRet(,"NF_CODMUN")     // Codigo do Municipio utilizado na operacao
//a03 := MaFisRet(,"NF_VTOTPED")	 // Total do Pedido
//a07 := MaFisRet(,"NF_CODMUN")     // Codigo do Municipio utilizado na operacao
cRecIss := MaFisRet(,"NF_RECISS")     // Recolhe ISS
If !Empty(SC5->C5_RECISS)
	cRecIss := SC5->C5_RECISS
EndIf
//a13 := MaFisRet(,"NF_ALIQIR")     // Aliquota de IRF do Cliente
//a14 := MaFisRet(,"NF_BASECOF")	 // Base de calculo do COFINS
nValCof := MaFisRet(,"NF_VALCOF")	    // Valor do COFINS
//a16 := MaFisRet(,"NF_BASECSL")	 // Base de calculo do CSLL
nValCsl := MaFisRet(,"NF_VALCSL")	    // Valor do CSLL
//a18 := MaFisRet(,"NF_BASEPIS")	 // Base de calculo do PIS
nValPis := MaFisRet(,"NF_VALPIS")	    // Valor do PIS
//a20 := MaFisRet(,"NF_ISS")   	    // Array contendo os Valores de ISS
//a21 := MaFisRet(,"NF_BASEISS")    // Base de Calculo do ISS
If cRecIss == "1"
   nValIssR := MaFisRet(,"NF_VALISS")     // Valor do ISS
Else
   nValIss := MaFisRet(,"NF_VALISS")     // Valor do ISS
EndIf
//a23 := MaFisRet(,"NF_DESCISS")    // Valor de desconto total de ISS
//aIRRF := MaFisRet(,"NF_IR")         // Array contendo os valores do Imposto de renda
//a25 := MaFisRet(,"NF_BASEIRR")    // Base do Imposto de Renda do item
nValIRR := MaFisRet(,"NF_VALIRR")     // Valor do IR do item
//aINSS := MaFisRet(,"NF_INSS")       // Array contendo os valores de INSS
//a28 := MaFisRet(,"NF_BASEINS")    // Base de calculo do INSS
nValIns := MaFisRet(,"NF_VALINS")     // Valor do INSS do item
//a30 := MaFisRet(,"NF_NATUREZA")   // Codigo da natureza a ser gravado nos titulos do Financeiro.

aImpostos := MaFisRet(,"NF_IMPOSTOS") //Array contendo todos os impostos calculados na funcao Fiscal com quebra por impostos+aliquotas
//aImpostos[1]: Array {size=6}
//aImpostos[1][1]: "..."
//aImpostos[1][2]: ""
//aImpostos[1][3]: 0
//aImpostos[1][4]: 0
//aImpostos[1][5]: 0
//aImpostos[1][6]: "NEW"
//aImpostos[2]: Array {size=6}
//aImpostos[2][1]: "ISS"
//aImpostos[2][2]: "ISS Imposto sobre servico "
//aImpostos[2][3]: 432866.88
//aImpostos[2][4]: 2
//aImpostos[2][5]: 8657.33
//aImpostos[2][6]: "ISS"
//aImpostos[3]: Array {size=6}
//aImpostos[3][1]: "IRR"
//aImpostos[3][2]: "IRRF Imposto de renda "
//aImpostos[3][3]: 432866.88
//aImpostos[3][4]: 1.5
//aImpostos[3][5]: 6493
//aImpostos[3][6]: "IRR"
//aImpostos[4]: Array {size=6}
//aImpostos[4][1]: "INS"
//aImpostos[4][2]: "INSS "
//aImpostos[4][3]: 432866.88
//aImpostos[4][4]: 11
//aImpostos[4][5]: 47615.35
//aImpostos[4][6]: "INS"
//aImpostos[5]: Array {size=6}
//aImpostos[5][1]: "PS2"
//aImpostos[5][2]: "PIS/Pasep - Via apuracao"
//aImpostos[5][3]: 432866.88
//aImpostos[5][4]: 1.65
//aImpostos[5][5]: 7142.3
//aImpostos[5][6]: "PS2"
//aImpostos[6]: Array {size=6}
//aImpostos[6][1]: "CF2"
//aImpostos[6][2]: "COFINS - Via apuracao"
//aImpostos[6][3]: 432866.88
//aImpostos[6][4]: 7.6
//aImpostos[6][5]: 32897.88
//aImpostos[6][6]: "CF2"

For nI := 1 To Len(aImpostos)
	If aImpostos[nI,1]  = "INS"
		nPInss := aImpostos[nI,4]
	ElseIf aImpostos[nI,1]  = "IRR"
		nPIrrf := aImpostos[nI,4]
	EndIf
Next

MaFisEnd()

// funcao Condicao() de Pagamento
aParc := Condicao(nTotVal,SC5->C5_CONDPAG,,IIF(!EMPTY(dEmisNF),dEmisNF,SC5->C5_EMISSAO))
If Len(aParc) > 0
   cVencto := DTOC(aParc[1,1])
EndIf


If !EMPTY(SC5->C5_NOTA)
   dbSelectArea("SF2")
   dbSetOrder(1)
   If dbSeek(xFilial("SF2")+cNota+cSerie+cCliente+cLoja)
		cObsNF	:= SF2->F2_XXCORPO
		nTotVal := SF2->F2_VALFAT
		If cRetCli <> "3"
			nValPis := SF2->F2_VALPIS
			nValCof := SF2->F2_VALCOFI
			nValCsl := SF2->F2_VALCSLL
			nValIRR := SF2->F2_VALIRRF
		Else
			nValPis := 0
			nValCof := 0
			nValCsl := 0
			nValIRR := 0
		EndIf
		nValIns := SF2->F2_VALINSS
		nValCpm := SF2->F2_VLCPM
		If SF2->F2_RECISS == "1"
			nValIssR:= SF2->F2_VALISS    // Valor do ISS Retido
			nValIss := 0
		Else
			nValIss := SF2->F2_VALISS    // Valor do ISS
			nValIssR:= 0			
		EndIf

		nTotLiq := SF2->(F2_VALFAT - F2_VALCSLL - F2_VALCOFI - F2_VALPIS - F2_VALIRRF - F2_VALINSS - F2_VLCPM - IIF(F2_RECISS = "1",F2_VALISS,0))
		nRetCtr := SF2->F2_XXVRETC
		nValFat := nTotLiq - nRetCtr
		cFaturis:= SF2->(FWLeUserlg('F2_USERLGI',1))
		dEmisNF := SF2->F2_EMISSAO

		// Financeiro
		cQuery := "SELECT TOP 1 E1_VENCREA,E1_NATUREZ "+ CRLF
		cQuery += " FROM "+RETSQLNAME("SE1")+" SE1 "+ CRLF
		cQuery += " WHERE E1_TIPO = 'NF' AND E1_PREFIXO = '"+SF2->F2_SERIE+"' AND E1_NUM = '"+SF2->F2_DOC+"'" + CRLF
		cQuery += "  AND SE1.D_E_L_E_T_ ='' AND E1_FILIAL = '"+xFilial("SE1")+"' "+ CRLF
		TCQUERY cQuery NEW ALIAS "QSE1"
		dbSelectArea("QSE1")
		QSE1->(dbGoTop())
		If !Eof()
			cVencto   := DTOC(STOD(QSE1->E1_VENCREA))
			cNatureza := QSE1->E1_NATUREZ
		Endif
		QSE1->(dbCloseArea())

		// Itens
		//dbSelectArea("SD2")
		SD2->(dbSetOrder(3))
		If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
			aItens := {}
			While SD2->(!Eof()) .And. xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA==xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
				SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD))
				AADD(aItens,{SD2->D2_COD,SB1->B1_DESC,SD2->D2_CODISS,SD2->D2_ALIQISS,SD2->D2_TES,SD2->D2_TOTAL,SD2->D2_ALQCPM})
				SD2->(dbSkip())
			Enddo 
		Endif 

   EndIf
Else
	If cRetCli == "3"
		nValPis := 0
		nValCof := 0
		nValCsl := 0
		nValIRR := 0
	EndIf
	nTotLiq := nTotVal - nValPis - nValCof - nValCsl - nValIRR - nValIns - nValIssR - nValCpm
	nRetCtr := ROUND(SC5->C5_XXRETC * nTotVal / 100,2) 
	nValFat := nTotLiq - nRetCtr
EndIf

// Tipo da NF
aTpNf     := U_StringToArray(GetSx3Cache("CNA_XXTPNF", "X3_CBOX"),";") 
nTpNF     := ASCAN(aTpNf,{ |x| SUBSTR(x,1,1) == SUBSTR(SC5->C5_XXTPNF,1,1)})
If nTpNF > 0
   cTpNF   := aTpNf[nTpNf]
EndIf


If !EMPTY(cMedicao)

   cRev    := SPACE(LEN(CN9->CN9_REVISA))
   cObsMed := ""

	// Nova Medição
	U_PMedPed(cPedido,cContra,cMedicao,cPlan,@cRev,@cCompM,@cParcel,@cObsMed,@cEmissor)

	// Glosas e Bonificações
	aCNR := U_BKGlosas(SC5->C5_MDNUMED,SC5->C5_MDPLANI)

EndIf

If !Empty(cContra)
	dbSelectArea("CN9")
	dbSetOrder(1)  // Numero+Situac
	If dbSeek(xFilial("CN9")+cContra+cRev,.F.)
		cDescCtr := ALLTRIM(CN9->CN9_XXDESC)
	EndIf
EndIf	


If SM0->M0_CODIGO == "01"      // BK
	cLogo := '<img src="http://www.bkconsultoria.com.br/Imagens/logo_header.png" border=0>'
Endif	

If nPag == 1
	AADD(aHtml,'<html lang="pt-BR">')
	AADD(aHtml,'<head>') 
	//AADD(aHtml,'<meta charset="iso-8859-1">')
	AADD(aHtml,'<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">' )
	AADD(aHtml,'<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">' )
	AADD(aHtml,'<title>Pedido '+TRIM(SC5->C5_NUM)+' - '+DTOC(date())+' '+TIME()+'</title>' )
	AADD(aHtml,'<style type="text/css">')

	AADD(aHtml,'.tg  {border-collapse:collapse;border-spacing:0;margin:auto;}')
	AADD(aHtml,'')
	AADD(aHtml,'.tg td{font-family:Arial, sans-serif;font-size:14px;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}')
	AADD(aHtml,'.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}')

	AADD(aHtml,'.tg tr { line-height: 18px; }')

	AADD(aHtml,'.tg .tg-empr{font-weight:bold;font-size:28px;text-align:center;line-height: 40px;}')
	AADD(aHtml,'.tg .tg-data{font-weight:bold;font-size:12px;text-align:center}')
	AADD(aHtml,'.tg .tg-hcliente{font-weight:bold;font-size:12px;background-color:#c0c0c0;vertical-align:top}')

	AADD(aHtml,'.tg .tg-hndr{font-weight:bold;font-size:12px;background-color:#c0c0c0;text-align:center;vertical-align:top}')

	AADD(aHtml,'.tg .tg-cliente{font-weight:bold;font-size:14px;vertical-align:top}')
	AADD(aHtml,'.tg .tg-ndr{font-weight:bold;font-size:14px;text-align:center;vertical-align:top}')
	
	AADD(aHtml,'.tg .tg-hmens{font-weight:bold;font-size:14px;text-align:center;vertical-align:center;line-height: 30px;background-color:#c0c0c0;}')
	AADD(aHtml,'.tg .tg-mens{font-weight:bold;font-size:12px;text-align:center;vertical-align:center;line-height: 30px;}')

	AADD(aHtml,'.tg .tg-hdesc{font-weight:bold;background-color:#c0c0c0;font-size:14px;vertical-align:middle;min-width:300px}')
	AADD(aHtml,'.tg .tg-desc{font-size:12px;vertical-align:middle;min-width:300px}')

	AADD(aHtml,'.tg .tg-hrdv{font-weight:bold;background-color:#c0c0c0;font-size:14px;vertical-align:middle;text-align:center}')
	AADD(aHtml,'.tg .tg-rdv{font-size:12px;vertical-align:middle;text-align:center}')

	AADD(aHtml,'.tg .tg-hsc{font-weight:bold;background-color:#c0c0c0;font-size:14px;vertical-align:middle;text-align:center}')
	AADD(aHtml,'.tg .tg-sc{font-size:12px;vertical-align:middle;;text-align:center}')
	
	AADD(aHtml,'.tg .tg-hvalor{font-weight:bold;background-color:#c0c0c0;font-size:14px;vertical-align:middle;min-width:40px;text-align:center}')
	AADD(aHtml,'.tg .tg-valor{font-size:12px;vertical-align:middle;min-width:100px;text-align:center;padding-right:10px}')
	
	AADD(aHtml,'.tg .tg-hobs{font-weight:bold;font-size:12px;background-color:#c0c0c0;text-align:center;vertical-align:top}')
	AADD(aHtml,'.tg .tg-obs{font-weight:bold;font-size:12px;vertical-align:middle;max-width:200px;text-align:center;}')

	AADD(aHtml,'.tg .tg-vtotal{font-weight:bold;font-size:14px;vertical-align:middle;min-width:100px;text-align:center;padding-right:10px}')

// Tabela de Impostos
	AADD(aHtml,'.ti  {border-collapse:collapse;border-spacing:0;width:100%;margin-left:0%;margin-right:0%;}')
	AADD(aHtml,'')
	AADD(aHtml,'.ti td{font-family:Arial, sans-serif;font-size:14px;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}')
	AADD(aHtml,'.ti th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}')

	AADD(aHtml,'.t1 tr { line-height: 18px; }')

	AADD(aHtml,'.ti .ti-hvalor{font-weight:bold;background-color:#c0c0c0;font-size:14px;vertical-align:middle;min-width:40px;text-align:center}')
	AADD(aHtml,'.ti .ti-valor{font-size:12px;vertical-align:middle;min-width:100px;text-align:center;padding-right:10px}')
	AADD(aHtml,'.tg .ti-str{font-size:12px;vertical-align:middle;;text-align:center}')
	
	AADD(aHtml,'.folha {page-break-after:always;page-break-inside:avoid;}')
	
	AADD(aHtml,'</style>' )
	AADD(aHtml,'</head>' )
	AADD(aHtml,'<body lang=PT-BR>' )
EndIf                                 

AADD(aHtml,'<div class="folha">')

AADD(aHtml,'<table class="tg">')

AADD(aHtml,'<colgroup>')
AADD(aHtml,'<col style="width: 100px">')
AADD(aHtml,'<col style="width: 300px">')
AADD(aHtml,'<col style="width: 060px">')
AADD(aHtml,'<col style="width: 060px">')
AADD(aHtml,'<col style="width: 100px">')
AADD(aHtml,'<col style="width: 100px">')
AADD(aHtml,'<col style="width: 120px">')
AADD(aHtml,'</colgroup>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'  	<td colspan="7">')
AADD(aHtml,'  </tr>')

AADD(aHtml,'    <tr>')

If EMPTY(cLogo)
	AADD(aHtml,'    <td class="tg-empr" colspan="3">'+FWEmpName(cEmpAnt)+'</td>')
Else
	AADD(aHtml,'    <td class="tg-empr" colspan="3">'+cLogo+'</td>')
Endif

AADD(aHtml,'      <td class="tg-data" colspan="3" >')
AADD(aHtml,'      '+cNomeCom+'<br>')
AADD(aHtml,'      '+cEndereco+'<br>')
AADD(aHtml,'      '+cCep+" - "+cCidade+'<br>')
AADD(aHtml,'      '+cSite+'</td>')
AADD(aHtml,'      <td class="tg-data">')
AADD(aHtml,'      '+cTel+'<br>')
AADD(aHtml,'      '+cCnpj+'<br>')
AADD(aHtml,'      '+cIE+'<br>')
AADD(aHtml,'      </td>')
AADD(aHtml,'    </tr>')
  
AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-empr" colspan="7">'+cTipoTit+'</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-hcliente" colspan="4">Cliente '+ALLTRIM(cCliente)+'-'+ALLTRIM(cLoja)+'</td>')
AADD(aHtml,'      <td class="tg-hndr" colspan="2">CNPJ</td>')
AADD(aHtml,'      <td class="tg-hndr">RM</td>')
AADD(aHtml,'    </tr>')
AADD(aHtml,'    <tr>')

AADD(aHtml,'      <td class="tg-cliente" colspan="4">'+cNomeCli+'</td>')
AADD(aHtml,'      <td class="tg-ndr" colspan="2">'+cCNPJCli+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cRM+ '</td>')
AADD(aHtml,'    </tr>')
    
AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-hcliente" colspan="5">Endereço</td>')
AADD(aHtml,'      <td class="tg-hndr">Natureza</td>')
AADD(aHtml,'      <td class="tg-hndr">Vencimento</td>')
AADD(aHtml,'    </tr>')
AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-cliente" colspan="5">'+cEndCli+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cNatureza+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cVencto+'</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-hcliente" colspan="4">Município do cliente</td>')
AADD(aHtml,'      <td class="tg-hndr">UF</td>')
AADD(aHtml,'      <td class="tg-hndr">CEP</td>')
AADD(aHtml,'      <td class="tg-hndr">Emissão</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-cliente" colspan="4">'+cMunCli+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cUFCli+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cCepCli+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cEmissao+'</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-mens" colspan="7">'+cRefComp)
AADD(aHtml,'    </td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-hndr">Contrato</td>')
AADD(aHtml,'      <td class="tg-hndr" colspan="3">Descrição '+iIf(!Empty(cRev),' - Revisão '+cRev,'')+'</td>')
AADD(aHtml,'      <td class="tg-hndr">Medição '+cParcel+'</td>')
AADD(aHtml,'      <td class="tg-hndr">Planilha</td>')
AADD(aHtml,'      <td class="tg-hndr">Emissor</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-ndr">'+TRIM(cContra)+'</td>')
AADD(aHtml,'      <td class="tg-ndr" colspan="3">'+cDescCtr+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cMedicao+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cPlan+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cEmissor+'</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-hndr">Código</td>')
AADD(aHtml,'      <td class="tg-hndr" colspan="3">Município de Prestação</td>')
AADD(aHtml,'      <td class="tg-hndr">UF</td>')
AADD(aHtml,'      <td class="tg-hndr">Tipo NF</td>')
AADD(aHtml,'      <td class="tg-hndr">Competência</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-ndr">'+cMunPres+'</td>')
AADD(aHtml,'      <td class="tg-ndr" colspan="3">'+cDescMun+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cEstPres+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cTpNF+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cCompM+'</td>')
AADD(aHtml,'    </tr>')


If !Empty(cMenPed)
	AADD(aHtml,'    <tr>')
	AADD(aHtml,'      <td class="tg-hsc" colspan="7">Observações do Pedido</td>')
	AADD(aHtml,'    </tr>')

	AADD(aHtml,'    <tr>')
	AADD(aHtml,'      <td class="tg-sg" colspan="7">'+cMenPed)
	AADD(aHtml,'      </td>')
	AADD(aHtml,'    </tr>')
EndIf


If !Empty(cObsMed)
	AADD(aHtml,'    <tr>')
	AADD(aHtml,'      <td class="tg-hsc" colspan="7">Observações da Medição</td>')
	AADD(aHtml,'    </tr>')

	AADD(aHtml,'    <tr>')
	AADD(aHtml,'      <td class="tg-sg" colspan="7">'+cObsMed)
	AADD(aHtml,'      </td>')
	AADD(aHtml,'    </tr>')
EndIf

If Len(aCNR) > 0
	AADD(aHtml,'  <tr>')
	AADD(aHtml,'    <td class="tg-hsc" colspan="7">Glosas e Bonificações</td>')
	AADD(aHtml,'  </tr>')
	AADD(aHtml,'  <tr>')
	AADD(aHtml,'  	<td colspan="7">')
	AADD(aHtml,'    <table class="ti">')
	AADD(aHtml,'      <colgroup>')
	AADD(aHtml,'       <col style="width: 70px">')
	AADD(aHtml,'       <col style="width: 230px">')
	AADD(aHtml,'       <col style="width: 230px">')
	AADD(aHtml,'       <col style="width: 70px">')
	AADD(aHtml,'      </colgroup>')

	AADD(aHtml,'      <tr>')
	AADD(aHtml,'        <td class="ti-hvalor">Tipo</td>')
	AADD(aHtml,'        <td class="ti-hvalor">Descrição</td>')
	AADD(aHtml,'        <td class="ti-hvalor">Justificativa</td>')
	AADD(aHtml,'        <td class="ti-hvalor">Valor</td>')
	AADD(aHtml,'      </tr>')

	For nI := 1 To Len(aCNR)
		AADD(aHtml,'  <tr>')
		AADD(aHtml,'    <td class="tg-sc">'+aCNR[nI,1]+'</td>')
		AADD(aHtml,'    <td class="tg-sc">'+aCNR[nI,2]+'</td>')
		AADD(aHtml,'    <td class="tg-sc">'+aCNR[nI,4]+'</td>')
		AADD(aHtml,'    <td class="tg-valor">R$ '+ALLTRIM(aCNR[nI,3])+'</td>')
		AADD(aHtml,'  </tr>')
	Next

	AADD(aHtml,'    </table>')
	AADD(aHtml,'   </td>')
	AADD(aHtml,'  </tr>')
EndIf


If !Empty(cObsNF)
	AADD(aHtml,'    <tr>')
	AADD(aHtml,'      <td class="tg-hsc" colspan="7">Observações da NF</td>')
	AADD(aHtml,'    </tr>')

	AADD(aHtml,'    <tr>')
	AADD(aHtml,'      <td class="tg-sg" colspan="7">'+cObsNF)
	AADD(aHtml,'      </td>')
	AADD(aHtml,'    </tr>')
EndIf


AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-sg" colspan="7">')
AADD(aHtml,'    </td>')
AADD(aHtml,'  </tr>')

If Len(aItens) > 0
	AADD(aHtml,'  <tr>')
   //AADD(aItens,{SC6->C6_PRODUTO,SB1->B1_DESC,SC6->C6_CODISS,SB1->B1_ALIQISS,SC6->C6_TES,SC6->C6_VALOR})

	AADD(aHtml,'    <td class="tg-hsc">Produto</td>')
	AADD(aHtml,'    <td class="tg-hsc" colspan="2">Descrição</td>')
	AADD(aHtml,'    <td class="tg-hrdv">TES</td>')
	AADD(aHtml,'    <td class="tg-hrdv">ISS / CPOM</td>')
	AADD(aHtml,'    <td class="tg-hrdv">Cod. ISS</td>')
	AADD(aHtml,'    <td class="tg-hvalor">Valor</td>')
	AADD(aHtml,'  </tr>')

	For nI := 1 To Len(aItens)
			If !Empty(aItens[nI,7])
				cAlqCPM	:= +" / "+PicPer(aItens[nI,7],5,2)+'%'
			Else
				cAlqCPM	:= ""
			EndIf

			AADD(aHtml,'  <tr>')
			AADD(aHtml,'    <td class="tg-sc">'+aItens[nI,1]+'</td>')
			AADD(aHtml,'    <td class="tg-sc" colspan="2">'+aItens[nI,2]+'</td>')
			AADD(aHtml,'    <td class="tg-rdv">'+aItens[nI,5]+'</td>')
			AADD(aHtml,'    <td class="tg-sc">'+PicPer(aItens[nI,4],5,2)+'%'+cAlqCPM+'</td>')
			AADD(aHtml,'    <td class="tg-ndr">'+aItens[nI,3]+'</td>')
			AADD(aHtml,'    <td class="tg-valor">R$ '+ALLTRIM(TRANSFORM(aItens[nI,6],cPict))+'</td>')
			AADD(aHtml,'  </tr>')
		Next
	
		AADD(aHtml,'  <tr>')
		AADD(aHtml,'    <td class="tg-obs" colspan="6"></td>')
		AADD(aHtml,'    <td class="tg-vtotal">R$ '+ALLTRIM(TRANSFORM(nTotVal,cPict))+'</td>')
		AADD(aHtml,'  </tr>')
	
		AADD(aHtml,'  <tr>')
		//AADD(aHtml,'    <td class="tg-obs" colspan="5">'+IIF(VAL(cTaxa)>0,'A FATURAR COM A TAXA DE '+cTaxa,'')+' ('+Extenso(SE1->E1_VALOR)+')</td>')
		//AADD(aHtml,'    <td class="tg-vtotal">R$ '+ALLTRIM(TRANSFORM(SE1->E1_VALOR,cPict))+'</td>')
		AADD(aHtml,'  </tr>')
		
EndIf

AADD(aHtml,'  <tr>')
AADD(aHtml,'  	<td colspan="7">')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'  	<td colspan="7">')
AADD(aHtml,'    <table class="ti">')
AADD(aHtml,'      <colgroup>')
AADD(aHtml,'       <col style="width: 100px">')
AADD(aHtml,'       <col style="width: 100px">')
AADD(aHtml,'       <col style="width: 100px">')
AADD(aHtml,'       <col style="width: 100px">')
AADD(aHtml,'       <col style="width: 100px">')
AADD(aHtml,'       <col style="width: 100px">')
AADD(aHtml,'      </colgroup>')

AADD(aHtml,'      <tr>')
AADD(aHtml,'        <td class="ti-hvalor">PIS</td>')
AADD(aHtml,'        <td class="ti-hvalor">COFINS</td>')
AADD(aHtml,'        <td class="ti-hvalor">CSLL</td>')
AADD(aHtml,'        <td class="ti-hvalor">IRRF'+IIF(nPIrrf>0,' '+ALLTRIM(STR(nPIrrf))+'% '+cRetIr,'')+'</td>')
AADD(aHtml,'        <td class="ti-hvalor">INSS'+IIF(nPInss>0,' '+ALLTRIM(STR(nPinss))+'% ','')+'</td>')
AADD(aHtml,'        <td class="ti-hvalor">ISS</td>')
AADD(aHtml,'        <td class="ti-hvalor">ISS RETIDO</td>')
AADD(aHtml,'        <td class="ti-hvalor">ISS CPOM</td>')
AADD(aHtml,'      </tr>')
If cRetCli == '3'
	AADD(aHtml,'      <tr>')
	AADD(aHtml,'        <td class="ti-valor" colspan="4">Cliente configurado para não reter</td>')
	AADD(aHtml,'        <td class="ti-valor">'+ALLTRIM(TRANSFORM(nValIns,cPict))+'</td>')
	AADD(aHtml,'        <td class="ti-valor">'+ALLTRIM(TRANSFORM(nValIss,cPict))+'</td>')
	AADD(aHtml,'        <td class="ti-valor">'+ALLTRIM(TRANSFORM(nValIssR,cPict))+'</td>')
	AADD(aHtml,'        <td class="ti-valor">'+ALLTRIM(TRANSFORM(nValCpm,cPict))+'</td>')
	AADD(aHtml,'      </tr>')
Else
	AADD(aHtml,'      <tr>')
	AADD(aHtml,'        <td class="ti-valor">'+ALLTRIM(TRANSFORM(nValPis,cPict))+'</td>')
	AADD(aHtml,'        <td class="ti-valor">'+ALLTRIM(TRANSFORM(nValCof,cPict))+'</td>')
	AADD(aHtml,'        <td class="ti-valor">'+ALLTRIM(TRANSFORM(nValCsl,cPict))+'</td>')
	AADD(aHtml,'        <td class="ti-valor">'+ALLTRIM(TRANSFORM(nValIRR,cPict))+'</td>')
	AADD(aHtml,'        <td class="ti-valor">'+ALLTRIM(TRANSFORM(nValIns,cPict))+'</td>')
	AADD(aHtml,'        <td class="ti-valor">'+ALLTRIM(TRANSFORM(nValIss,cPict))+'</td>')
	AADD(aHtml,'        <td class="ti-valor">'+ALLTRIM(TRANSFORM(nValIssR,cPict))+'</td>')
	AADD(aHtml,'        <td class="ti-valor">'+ALLTRIM(TRANSFORM(nValCpm,cPict))+'</td>')
	AADD(aHtml,'      </tr>')
EndIf

AADD(aHtml,'      <tr>')
AADD(aHtml,'        <td class="ti-hvalor">NF</td>')
AADD(aHtml,'        <td class="ti-hvalor">Série</td>')
AADD(aHtml,'        <td class="ti-hvalor">Emissão</td>')
AADD(aHtml,'        <td class="ti-hvalor">Lib por</td>')
AADD(aHtml,'        <td class="ti-hvalor">Faturista</td>')
AADD(aHtml,'        <td class="ti-hvalor">Val s/ imp</td>')
AADD(aHtml,'        <td class="ti-hvalor">Retenção Ctr</td>')
AADD(aHtml,'        <td class="ti-hvalor">Valor Liq.</td>')
AADD(aHtml,'      </tr>')


AADD(aHtml,'      <tr>')
AADD(aHtml,'        <td class="ti-str">'+ALLTRIM(cNota)+'</td>')
AADD(aHtml,'        <td class="ti-str">'+ALLTRIM(cSerie)+'</td>')
AADD(aHtml,'        <td class="ti-str">'+DTOC(dEmisNF)+'</td>')
AADD(aHtml,'        <td class="ti-str">'+ALLTRIM(cLiber)+'</td>')
AADD(aHtml,'        <td class="ti-str">'+cFaturis+'</td>')
AADD(aHtml,'        <td class="ti-valor">'+ALLTRIM(TRANSFORM(nTotLiq,cPict))+'</td>')
AADD(aHtml,'        <td class="ti-valor">'+ALLTRIM(TRANSFORM(nRetCtr,cPict))+'</td>')
AADD(aHtml,'        <td class="ti-valor">'+ALLTRIM(TRANSFORM(nValFat,cPict))+'</td>')
AADD(aHtml,'      </tr>')
AADD(aHtml,'    </table>')
AADD(aHtml,'   </td>')
AADD(aHtml,'  </tr>')

// Documentos anexos: Contrato x Competência
aFiles := u_BKDocs(cEmpAnt,"SZE",PAD(cContra,15)+cCompAM,1)
If Len(aFiles) > 0
	For nI := 1 To Len(aFiles)
		AADD(aHtml,'  <tr>')
		AADD(aHtml,'  	<td colspan="7" style="text-align:center;">')
		AADD(aHtml,'       <a href="'+u_BkRest()+'/RestLibPN/v4?empresa='+cEmpAnt+'&documento='+Encode64(aFiles[nI,2])+'&tpanexo=P" class="link-primary">'+aFiles[nI,2]+'</a></br>')
		AADD(aHtml,'    </td>')
		AADD(aHtml,'  </tr>')
	Next
EndIf

AADD(aHtml,'</table>')
AADD(aHtml,'<br>')


AADD(aHtml,'<br>')
AADD(aHtml,'</div>')

AADD(aHtml,'</body>')
AADD(aHtml,'</html>')


// Restauração das áreas
CND->(RestArea(aAreaCND))
SC6->(RestArea(aAreaSC6))
SB1->(RestArea(aAreaSB1))
SF4->(RestArea(aAreaSF4))
SA1->(RestArea(aAreaSA1))
CN9->(RestArea(aAreaCN9))
SF2->(RestArea(aAreaSF2))

RestArea(aAreaAtu)

Return(aHtml)


// Retorna o Percentual em caracteres sem .00 no final
Static Function PicPer(nAliq,nT,nD)
Local cAliq := ALLTRIM(STR(nAliq,nT,nD))
If ("."+Replicate("0",nD)) $ cAliq
	cAliq := STRTRAN(cAliq,"."+Replicate("0",nD),"")
EndIf
Return cAliq


/*
#DEFINE NF_TIPONF		 01     //Tipo : N , I , C , P
#DEFINE NF_OPERNF		 02     //E-Entrada | S - Saida
#DEFINE NF_CLIFOR		 03     //C-Cliente | F - Fornecedor
#DEFINE NF_TPCLIFOR 	 04     //Tipo do destinatario R,F,S,X
#DEFINE NF_LINSCR		 05     //Indica se o destino possui inscricao estadual
#DEFINE NF_GRPCLI		 06     //Grupo de Tributacao
#DEFINE NF_UFDEST		 07     //UF do Destinatario
#DEFINE NF_UFORIGEM	 	 08     //UF de Origem
#DEFINE NF_DESCONTO	 	 10     //Valor Total do Deconto
#DEFINE NF_FRETE		 11     //Valor Total do Frete
#DEFINE NF_DESPESA	     12     //Valor Total das Despesas Acessorias
#DEFINE NF_SEGURO		 13     //Valor Total do Seguro
#DEFINE NF_AUTONOMO 	 14     //Valor Total do Frete Autonomo
#DEFINE NF_ICMS		 	 15     //Array contendo os valores de ICMS
#DEFINE NF_BASEICM	     15,01  //Valor da Base de ICMS 
#DEFINE NF_VALICM		 15,02  //Valor do ICMS Normal
#DEFINE NF_BASESOL	     15,03  //Base do ICMS Solidario
#DEFINE NF_VALSOL		 15,04  //Valor do ICMS Solidario
#DEFINE NF_BICMORI	     15,05  //Base do ICMS Original
#DEFINE NF_VALCMP		 15,06  //Valor do Icms Complementar
#DEFINE NF_BASEICA	     15,07  //Base do ICMS sobre o Frete Autonomo
#DEFINE NF_VALICA 	     15,08  //Valor do ICMS sobre o Frete Autonomo
#DEFINE NF_RECFAUT	     15,09  //1-Emitente, 2-Transportador     
#DEFINE NF_IPI  		 16     //Array contendo os valores de IPI
#DEFINE NF_BASEIPI	     16,01  //Valor da Base do IPI
#DEFINE NF_VALIPI		 16,02  //Valor do IPI
#DEFINE NF_BIPIORI	     16,03  //Valor da Base Original do IPI
#DEFINE NF_TOTAL		 17     //Valor Total da NF
#DEFINE NF_VALMERC	     18     //Total de Mercadorias
#DEFINE NF_FUNRURAL 	 19	    //Valor Total do FunRural
#DEFINE NF_CODCLIFOR	 20     //Codigo do Cliente/Fornecedor
#DEFINE NF_LOJA		 	 21	    //Loja do Cliente/Fornecedor
#DEFINE NF_LIVRO		 22     //Array contendo o Demonstrativo Fiscal
#DEFINE NF_ISS			 23	    //Array contendo os Valores de ISS
#DEFINE NF_BASEISS	     23,01  //Base de Calculo do ISS
#DEFINE NF_VALISS		 23,02  //Valor do ISS
#DEFINE NF_DESCISS      23,03   //Valor de desconto total de ISS
#DEFINE NF_IR			 24     //Array contendo os valores do Imposto de renda
#DEFINE NF_BASEIRR	     24,01  //Base do Imposto de Renda do item
#DEFINE NF_VALIRR		 24,02  //Valor do IR do item
#DEFINE NF_INSS		 	 25     //Array contendo os valores de INSS
#DEFINE NF_BASEINS	     25,01  //Base de calculo do INSS
#DEFINE NF_VALINS		 25,02  //Valor do INSS do item
#DEFINE NF_NATUREZA	 	 26	    //Codigo da natureza a ser gravado nos titulos do Financeiro.
#DEFINE NF_VALEMB		 27	    //Valor da Embalagem
#DEFINE NF_RESERV1	     28	    //Array contendo as Bases de Impostos ( Argentina,Chile,Etc.)
#DEFINE NF_RESERV2	     29	    //Array contendo os valores de Impostos ( Argentina,Chile,Etc. )
#DEFINE NF_IMPOSTOS	 	 30	    //Array contendo todos os impostos calculados na funcao Fiscal com quebra por impostos+aliquotas
#DEFINE NF_BASEDUP		 31	    //Base de calculo das duplicatas geradas no financeiro
#DEFINE NF_RELIMP		 32	    //Array contendo a relacao de impostos que podem ser alterados
#DEFINE NF_IMPOSTOS2	 33	    //Array contendo todos os impostos calculados na funcao Fiscal com quebras por impostos
#DEFINE NF_DESCZF		 34	    //Valor Total do desconto da Zona Franca
#DEFINE NF_SUFRAMA	     35	    //Indica se o Cliente pertence a SUFRAMA
#DEFINE NF_BASEIMP	     36	    //Array contendo as Bases de Impostos Variaveis
#DEFINE NF_BASEIV1	     36,01  //Base de Impostos Variaveis 1
#DEFINE NF_BASEIV2	     36,02  //Base de Impostos Variaveis 2
#DEFINE NF_BASEIV3	     36,03  //Base de Impostos Variaveis 3
#DEFINE NF_BASEIV4	     36,04  //Base de Impostos Variaveis 4
#DEFINE NF_BASEIV5	     36,05  //Base de Impostos Variaveis 5
#DEFINE NF_BASEIV6	     36,06  //Base de Impostos Variaveis 6
#DEFINE NF_BASEIV7	     36,07  //Base de Impostos Variaveis 7
#DEFINE NF_BASEIV8	     36,08  //Base de Impostos Variaveis 8
#DEFINE NF_BASEIV9	     36,09  //Base de Impostos Variaveis 9
#DEFINE NF_VALIMP		 37 	//Array contendo os valores de Impostos Agentina/Chile/Etc.
#DEFINE NF_VALIV1		 37,01  //Valor do Imposto Variavel 1
#DEFINE NF_VALIV2		 37,02  //Valor do Imposto Variavel 2
#DEFINE NF_VALIV3		 37,03  //Valor do Imposto Variavel 3
#DEFINE NF_VALIV4		 37,04  //Valor do Imposto Variavel 4
#DEFINE NF_VALIV5		 37,05  //Valor do Imposto Variavel 5
#DEFINE NF_VALIV6		 37,06  //Valor do Imposto Variavel 6
#DEFINE NF_VALIV7		 37,07  //Valor do Imposto Variavel 7
#DEFINE NF_VALIV8		 37,08  //Valor do Imposto Variavel 8
#DEFINE NF_VALIV9		 37,09  //Valor do Imposto Variavel 96
#DEFINE NF_TPCOMP		 38     //Tipo de complemento  - F Frete , D Despesa Imp.
#DEFINE NF_INSIMP		 39	    //Flag de Controle : Indica se podera inserir Impostos no Rodape.
#DEFINE NF_PESO  		 40	    //Peso Total das mercadorias da NF
#DEFINE NF_ICMFRETE 	 41	    //Valor do ICMS relativo ao frete
#DEFINE NF_BSFRETE 	 	 42	    //Base do ICMS relativo ao frete
#DEFINE NF_BASECOF 	     43	    //Base de calculo do COFINS
#DEFINE NF_VALCOF  	     44	    //Valor do COFINS
#DEFINE NF_BASECSL 	 	 45	    //Base de calculo do CSLL
#DEFINE NF_VALCSL 		 46	    //Valor do CSLL
#DEFINE NF_BASEPIS 	 	 47	    //Base de calculo do PIS
#DEFINE NF_VALPIS 		 48	    //Valor do PIS
#DEFINE NF_ROTINA 		 49	    //Nome da rotina que esta utilizando a funcao
#DEFINE NF_AUXACUM 	 	 50	    //Campo auxiliar para acumulacao no calculo de impostos
#DEFINE NF_ALIQIR       51     //Aliquota de IRF do Cliente
#DEFINE NF_VNAGREG      52	    //Valor da Mercadoria nao agregada.
#DEFINE NF_RECPIS       53     //Recolhe PIS
#DEFINE NF_RECCOFI      54     //Recolhe CONFINS
#DEFINE NF_RECCSLL      55     //Recolhe CSLL
#DEFINE NF_RECISS       56     //Recolhe ISS
#DEFINE NF_RECINSS      57     //Recolhe INSS
#DEFINE NF_MOEDA        58     //Moeda da nota
#DEFINE NF_TXMOEDA      59     //Taxa da moeda
#DEFINE NF_SERIENF      60     //Serie da nota fiscal
#DEFINE NF_TIPODOC      61     //Tipo do documento (localizacoes)
#DEFINE NF_MINIMP       62     //Minimo para calcular Impostos Variaveis
#DEFINE NF_MINIV1       62,01  //Minimo para calcular Imposto Variavel 1
#DEFINE NF_MINIV2       62,02  //Minimo para calcular Imposto Variavel 2
#DEFINE NF_MINIV3       62,03  //Minimo para calcular Imposto Variavel 3
#DEFINE NF_MINIV4       62,04  //Minimo para calcular Imposto Variavel 4
#DEFINE NF_MINIV5       62,05  //Minimo para calcular Imposto Variavel 5
#DEFINE NF_MINIV6       62,06  //Minimo para calcular Imposto Variavel 6
#DEFINE NF_MINIV7       62,07  //Minimo para calcular Imposto Variavel 7
#DEFINE NF_MINIV8       62,08  //Minimo para calcular Imposto Variavel 8
#DEFINE NF_MINIV9       62,09  //Minimo para calcular Imposto Variavel 9
#DEFINE NF_BASEPS2      63	    //Base de calculo do PIS 2
#DEFINE NF_VALPS2       64	    //Valor do PIS 2
#DEFINE NF_ESPECIE      65	    //Especie do Documento
#DEFINE NF_CNPJ         66     //CNPJ/CPF
#DEFINE NF_BASECF2      67	    //Base de calculo do COFINS 2
#DEFINE NF_VALCF2       68	    //Valor do COFINS 2
#DEFINE NF_ICMSDIF      69     //Valor do ICMS diferido
#DEFINE NF_MODIRF       70     //Calculo do IRPF
#DEFINE NF_PNF_COD      71,01  //Codigo do pagador do documento fiscal
#DEFINE NF_PNF_LOJ      71,02  //Loja   do pagador do documento fiscal
#DEFINE NF_PNF_UF       71,03  //UF do pagador do documento fiscal
#DEFINE NF_PNF_TPCLIFOR 71,04  //Tipo do pagador do documento fiscal
#DEFINE NF_CALCSUF	     72	    //Indica se cliente possui calculo suframa
#DEFINE NF_BASEAFRMM    73	    //Base de calculo do AFRMM ( Cabecalho )
#DEFINE NF_VALAFRMM     74	    //Valor do AFRMM ( Cabecalho )
#DEFINE NF_PIS252       75     //Decreto 252 de 15/06/2005 - Valor do PIS para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
#DEFINE NF_COF252       76     //Decreto 252 de 15/06/2005 - Valor da COFINS para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
#DEFINE NF_OPIRRF		 77     //Indicacao de Orgao Publico para recolhimento de IRRF
#DEFINE NF_SEST         78	    //Array contendo os valores do SEST (Servico Social do Transporte)
#DEFINE NF_BASESES      78,01  //Base de calculo do SEST
#DEFINE NF_VALSES       78,02  //Valor do SEST
#DEFINE NF_RECSEST      79     //Recolhe SEST
#DEFINE NF_BASEPS3      80	    //Base de calculo do PIS Subst. Tributaria
#DEFINE NF_VALPS3       81	    //Valor do PIS Subst. Tributaria
#DEFINE NF_BASECF3      82	    //Base de calculo da COFINS Subst. Tributaria
#DEFINE NF_VALCF3       83	    //Valor da COFINS Subst. Tributaria
#DEFINE NF_VLR_FRT      84     //Valor Total do Frete de Pauta
#DEFINE NF_VALFET		 85	    //Valor do FETHAB
#DEFINE NF_RECFET       86     //FETHAB
#DEFINE NF_CLIENT       87     //Codigo do cliente de entrega na nota fiscal de saida
#DEFINE NF_LOJENT       88     //Loja do cliente de entrega na nota fiscal de saida
#DEFINE NF_VALFDS       89     //Valor do Fundersul - Mato Grosso do Sul
#DEFINE NF_ESTCRED      90     //Valor do Estorno de Credito/Debito
#DEFINE NF_SIMPNAC      91     //Define se o Cliente/Fornecedor se enquadra no regime do Simples Nacional
#DEFINE NF_TRANSUF      92,01  //UF do transportador
#DEFINE NF_TRANSIN      92,02  //Indicacao de inscricao do transportador
#DEFINE NF_BASETST      93     //Base do ICMS de transporte Substituicao Tributaria
#DEFINE NF_VALTST       94     //Valor do ICMS de transporte Substituicao Tributaria
#DEFINE NF_CRPRSIM      95     //Valor Crédito Presumido Simples Nacional - SC, nas aquisições de fornecedores que se enquadram no simples
#DEFINE NF_VALANTI      96     //Valor Antecipacao ICMS 
#DEFINE NF_DESNTRB      97     //Despesas Acessorias nao tributadas - Portugal
#DEFINE NF_TARA         98     //Tara - despesas com embalagem do transporte - Portugal
#DEFINE NF_NUMDEP       99     //Numero de dependentes - cálculo base IRRF pessoa fisica
#DEFINE NF_PROVENT     100     //Provincia de entrega
#DEFINE NF_VALFECP     101     //Valor FECP
#DEFINE NF_VFECPST     102     //Valor FECP ST
#DEFINE NF_CRDPRES     103     //Valor Credito Presumido SC
#DEFINE NF_IRPROG      104     //Calcula IR pela Tabela Progressiva mesmo para Pessoa Jurídica
#DEFINE NF_VALII       105     //Valor do Imposto de Importacao (PIS/COFINS)   
#DEFINE NF_RECIV       106     //Flag que identifica se os impostos dos itens anteriores deverão ser recalculado recursivamente ou não - localizado PERU "PER"
#DEFINE NF_CRPREPE     107     //Credito Presumido - Art. 6 Decreto  n28.247 
#DEFINE NF_VLRORIG	    108
#DEFINE NF_VLRORI1	    108,01  //Base de Impostos Variaveis 1
#DEFINE NF_VLRORI2	    108,02  //Base de Impostos Variaveis 2
#DEFINE NF_VLRORI3	    108,03  //Base de Impostos Variaveis 3
#DEFINE NF_VLRORI4	    108,04  //Base de Impostos Variaveis 4
#DEFINE NF_VLRORI5	    108,05  //Base de Impostos Variaveis 5
#DEFINE NF_VLRORI6	    108,06  //Base de Impostos Variaveis 6
#DEFINE NF_VLRORI7	    108,07  //Base de Impostos Variaveis 7
#DEFINE NF_VLRORI8	    108,08  //Base de Impostos Variaveis 8
#DEFINE NF_VLRORI9	    108,09  //Base de Impostos Variaveis 9
#DEFINE NF_VALFAB	    109	    //Valor do FABOV -  Mato grosso
#DEFINE NF_RECFAB      110     //Responsabilidade de recolhimento FABOV - Mato Grosso
#DEFINE NF_VALFAC	    111	    //Valor do FACS - Mato Grosso
#DEFINE NF_RECFAC      112     //Responsabilidade de recolhimento FACS - Mato Grosso
#DEFINE NF_LJCIPI      113     //Controla se calcula IPI (SIGALOJA)
#DEFINE NF_VALFUM      114     //Valor FUMACOP
#DEFINE NF_VLSENAR     115     //Valor do Senar        
#DEFINE NF_CROUTSP     116     //Credito Outorgado SP - Decreto 56.018/2010 
#DEFINE NF_BSSEMDS     117     //Valor Desconto - Decreto 43.080/2002 RICMS-MG
#DEFINE NF_ICSEMDS     118     //Valor Desconto - Decreto 43.080/2002 RICMS-MG
#DEFINE NF_DS43080     119     //Valor Desconto - Decreto 43.080/2002 RICMS-MG
#DEFINE NF_VL43080     120     //Valor de ICMS sem debito de imposto - Decreto 43.080/2002 RICMS-MG
#DEFINE NF_BASEFUN	    121     //Valor da Base do FUNRURAL
#DEFINE NF_PEDIDO	    122     //Pedido de Venda
#DEFINE NF_CODMUN      123     // Codigo do Municipio utilizado na operacao
#DEFINE NF_VALTPDP     124,01  //Valor da TPDP - PB
#DEFINE NF_BASTPDP		124,02	//Base da TPDP - PB
#DEFINE NF_VLINCMG     125     //Valor do incentivo prod.leite RICMS-MG
#DEFINE NF_BASEINA     126     //Base de calculo do INSS Condições Especiais
#DEFINE NF_VALINA      127     //Valor do INSS Condições Especiais
#DEFINE NF_VFECPRN     128     //Valor FECOP-RN
#DEFINE NF_VFESTRN     129     //Valor FECOP ST-RN
#DEFINE NF_CREDPRE     130     //Credito Presumido RS
#DEFINE NF_VFECPMG     131     //Valor FECP-MG
#DEFINE NF_VFESTMG     132     //Valor FECP ST-MG
#DEFINE NF_VREINT      133     //Valor de Reintegra
#DEFINE NF_BSREIN      134     //Base de Calculo do Reintegra
#DEFINE NF_VFECPMT     135     //Valor FECP-MT
#DEFINE NF_VFESTMT     136     //Valor FECP ST-MT       
#DEFINE NF_REGESIM     137     // Regime simplificado MT - A1_REGESIM / A2_REGESIM
#DEFINE NF_PERCATM     138     // Pecentual de Carga Media - A1_PERCATM 
#DEFINE NF_PESSOA  	    139     // Tipo Pessoa - Fisica/Juridica - A1_PESSOA   
#DEFINE NF_NREDUZ 	    140     // Nome de Fantasia - A1_NREDUZ / A2_NREDUZ
#DEFINE NF_A1CRDMA 	    141     // Credito Estimulo de Manaus - A1_CRDMA 
#DEFINE NF_SIMPSC 	    142     // Clie. optante SIMPLES/SC  - A1_SIMPLES 
#DEFINE NF_CDRDES 	    143     //Regiao do cliente
#DEFINE NF_CLIEFAT     144,01  //Cliente do Faturamento 
#DEFINE NF_LOJCFAT     144,02  //Loja do Cliente do Faturamento
#DEFINE NF_TIPOFAT     144,03  //Tipo do Cliente do Faturamento
#DEFINE NF_GRPFAT      144,04  //Grupo do Cliente do Faturamento
#DEFINE NF_NATUFAT	   144,05  //Natureza do Cliente do Faturamento
#DEFINE NF_ISSABMT 		145     //Abatimentos de Materiais do ISS
#DEFINE NF_ISSABSR		146     //Abatimentos de Servicos do ISS
#DEFINE NF_INSABMT		147     //Abatimentos de Materiais do INSS
#DEFINE NF_INSABSR		148     //Abatimentos de Servicos do INSS
#DEFINE NF_ADIANT 		149     //Adiantamentos Mexico
#DEFINE NF_VTOTPED		150     //Total do Pedido
#DEFINE NF_DTEMISS		151     //Total do Pedido
#DEFINE NF_IDSA1       152     //ID Historico SA1 
#DEFINE NF_IDSA2       153     //ID Historico SA2
#DEFINE NF_IDSED       154     //ID Historico SED
#DEFINE NF_DESCTOT     155     //Total do Desconto do Item - USO DO NOVO PDV - LOJA  
#DEFINE NF_ACRESCI     156     //Total do Acrescimos do Item - USO DO NOVO PDV - LOJA
#DEFINE NF_TPFRETE     157     //Tipo de Frete definido no Pedido
#DEFINE NF_FRETISS     158     //Forma de Retencao do ISS. 1 - Considera Valor Minimo; 2 - Sempre Retem
#DEFINE NF_UFPREISS    159     //UF da prestacao do servico do ISS onde o servico foi prestado
#DEFINE NF_UFXUF	   160	   //Array com conteudo da tabela CFC
#DEFINE NF_VALCIDE     161     //Valor do CIDE
#DEFINE NF_RECCIDE     162	   // RecCide SA2
#DEFINE NF_VALFETR     163	   // VAlor do FETHAB retido pelo cliente/fornecedor
#DEFINE NF_MODAL	   164	   // Modal CTE SF1
#DEFINE NF_ADIANTTOT 167     //Adiantamento(PERU)
#DEFINE NF_BASECID  	168	 //Base de Calculo CIDE
#DEFINE NF_BASECPM 	169 //Base do ISS CEPOM
#DEFINE NF_VALCPM		170	 // Valor do ISS CEPOM
#DEFINE NF_IPIVFCF	171 //Valor IPI a ser inserido na base do ICM, venda futura CF
#DEFINE NF_BASEFMP	172	 // Base Fumipeq	
#DEFINE NF_VALFMP		173	 // Valor Fumipeq
#DEFINE NF_VALFMD		174 //Valor Famad
#DEFINE NF_RECFMD    175 //Responsabilidade de recolhimento FAMAD - Mato Grosso
#DEFINE NF_SERSAT    176 //Responsabilidade de recolhimento FAMAD - Mato Grosso
#DEFINE NF_BASNDES		177	 // Base ICMS ST Recolh. Ant.	
#DEFINE NF_ICMNDES		178	 // Valor ICMS ST Recolhido Anteriormente.
#DEFINE NF_TPCOMPL		179	 // Tipo de Complemento
#DEFINE NF_DIFAL	180 //Difal
#DEFINE NF_PPDIFAL	181  //regra para calculo de Difal para consumidor final
#DEFINE NF_VFCPDIF  182
#DEFINE NF_BASEDES  183 //Base Difal estado de destino
#DEFINE NF_CLIDEST  184 //Cliente de destino da mercadoria
#DEFINE NF_LOJDEST  185 //Loja de destino da mercadoria
#DEFINE NF_UFCDEST	186	//UF de destino da mercadoria
#DEFINE NF_CLIEDEST	187	//verifica se cliente de destino da mercadoria é contribuinte
#DEFINE NF_VALFUND	188	    //Valor do FUNDESA
#DEFINE NF_VALIMA		189	    //Valor do IMA-MT
#DEFINE NF_VALFASE	190	    //Valor do FASE-MT
#DEFINE NF_VLIMAR		191	    //Valor do IMA-MT retido pelo cliente/fornecedor
#DEFINE NF_VLFASER	192	    //Valor do FASE-MT retido pelo cliente/fornecedor
#DEFINE NF_RECIMA    193     //Recolhimento IMA-MT
#DEFINE NF_RECFASE   194     //Recolhimento FASE-MT
#DEFINE NF_PRCMEDP   195     //Preço Médio Ponderado, para ser utilizado como base de ICMS ST
#DEFINE NF_INDICE   196     //Indice tabela F0R
#DEFINE NF_VALPEDG  197 	//Valor do Pedágio, informado pela rotina MATA116.
#DEFINE NF_TPACTIV  198 	//Actividad economica
#DEFINE NF_CALCINP  199 	//Calcula INSS Patronal
#DEFINE NF_VALINP   200 	//Valor do INSS Patronal
#DEFINE NF_AFRMIMP  201		//Valor do AFRMM na Importação
#DEFINE NF_VALPRO   202 	//Valor PROTEGE-GO
#DEFINE NF_INDUFP   203  //Indice Mato Grosso
#DEFINE NF_VALFEEF  204 	//Valor FEEF-RJ
#DEFINE NF_DEDBSPC  205  // Impostos que serão deduzidos da base de PIS/COFINS.


#DEFINE IT_GRPTRIB  	 01     //Grupo de Tributacao
#DEFINE IT_EXCECAO  	 02     //Array da EXCECAO Fiscal
#DEFINE IT_ALIQICM	     03     //Aliquota de ICMS
#DEFINE IT_ICMS 		 04     //Array contendo os valores de ICMS
#DEFINE IT_BASEICM  	 04,01  //Valor da Base de ICMS
#DEFINE IT_VALICM		 04,02  //Valor do ICMS Normal
#DEFINE IT_BASESOL	     04,03  //Base do ICMS Solidario
#DEFINE IT_ALIQSOL	     04,04  //Aliquota do ICMS Solidario
#DEFINE IT_VALSOL		 04,05  //Valor do ICMS Solidario
#DEFINE IT_MARGEM		 04,06  //Margem de lucro para calculo da Base do ICMS Sol.
#DEFINE IT_BICMORI	     04,07  //Valor original da Base de ICMS
#DEFINE IT_ALIQCMP	     04,08  //Aliquota para calculo do ICMS Complementar
#DEFINE IT_VALCMP		 04,09  //Valor do ICMS Complementar do item
#DEFINE IT_BASEICA 	     04,10  //Base do ICMS sobre o frete autonomo
#DEFINE IT_VALICA  	     04,11  //Valor do ICMS sobre o frete autonomo
#DEFINE IT_DEDICM       04,12  //Valor do ICMS a ser deduzido
#DEFINE IT_VLCSOL		 04,13  //Valor do ICMS Solidario calculado sem o credito aplicado
#DEFINE IT_PAUTIC       04,14  //Valor da Pauta do ICMS Proprio
#DEFINE IT_PAUTST       04,15  //Valor da Pauta do ICMS-ST
#DEFINE IT_PREDIC       04,16  //%Redução da Base do ICMS 
#DEFINE IT_PREDST       04,17  //%Redução da Base do ICMS-ST
#DEFINE IT_MVACMP       04,18  //Margem do complementar
#DEFINE IT_PREDCMP      04,19  //%Redução da Base do ICMS-CMP
#DEFINE IT_BASEDES      04,20  //Base de ICMS difal do destinatario // EC 87
#DEFINE IT_ALIQIPI  	 05     //Aliquota de IPI
#DEFINE IT_IPI  		 06     //Array contendo os valores de IPI
#DEFINE IT_BASEIPI  	 06,01  //Valor da Base do IPI
#DEFINE IT_VALIPI		 06,02  //Valor do IPI
#DEFINE IT_BIPIORI      06,03  //Valor da Base Original do IPI
#DEFINE IT_PREDIPI      06,04  //%Redução da Base do IPI
#DEFINE IT_PAUTIPI      06,05  //Valor da Pauta do IPI
#DEFINE IT_NFORI		 07     //Numero da NF Original
#DEFINE IT_SERORI		 08     //Serie da NF Original
#DEFINE IT_RECORI		 09     //RecNo da NF Original (SD1/SD2)
#DEFINE IT_DESCONTO	     10     //Valor do Desconto
#DEFINE IT_FRETE		 11     //Valor do Frete
#DEFINE IT_DESPESA	 	 12     //Valor das Despesas Acessorias
#DEFINE IT_SEGURO		 13     //Valor do Seguro
#DEFINE IT_AUTONOMO 	 14     //Valor do Frete Autonomo
#DEFINE IT_VALMERC		 15     //Valor da mercadoria
#DEFINE IT_PRODUTO		 16     //Codigo do Produto
#DEFINE IT_TES			 17     //Codigo da TES
#DEFINE IT_TOTAL		 18     //Valor Total do Item
#DEFINE IT_CF			 19     //Codigo Fiscal de Operacao
#DEFINE IT_FUNRURAL	     20     //Aliquota para calculo do Funrural
#DEFINE IT_PERFUN		 21     //Valor do Funrural do item
#DEFINE IT_DELETED		 22     //Flag de controle para itens deletados
#DEFINE IT_LIVRO		 23     //Array contendo o Demonstrativo Fiscal do Item
#DEFINE IT_ISS			 24     //Array contendo os valores de ISS
#DEFINE IT_ALIQISS	     24,01  //Aliquota de ISS do item
#DEFINE IT_BASEISS  	 24,02  //Base de Calculo do ISS
#DEFINE IT_VALISS		 24,03  //Valor do ISS do item
#DEFINE IT_CODISS		 24,04  //Codigo do ISS
#DEFINE IT_CALCISS	     24,05  //Flag de controle para calculo do ISS
#DEFINE IT_RATEIOISS	 24,06  //Flag de controle para calculo do ISS
#DEFINE IT_CFPS     	 24,07  //Codigo Fiscal de Prestacao de Servico
#DEFINE IT_PREDISS  	 24,08  //Redução da base de calculo do ISS
#DEFINE IT_VALISORI  	 24,09  //Valor do ISS do item sem aplicar o arredondamento
#DEFINE IT_ALISSOR  	 24,10  //Alíquota do ISS que seria utilizada caso houvesse ISS (utilizada em cálculo virtual, etc)
#DEFINE IT_IR			 25     //Array contendo os valores do Imposto de renda
#DEFINE IT_BASEIRR		 25,01  //Base do Imposto de Renda do item
#DEFINE IT_REDIR		 25,02  //Percentual de Reducao da Base de calculo do IR
#DEFINE IT_ALIQIRR		 25,03  //Aliquota de Calculo do IR do Item
#DEFINE IT_VALIRR		 25,04  //Valor do IR do Item
#DEFINE IT_INSS	 	     26     //Array contendo os valores de INSS
#DEFINE IT_BASEINS		 26,01  //Base de calculo do INSS
#DEFINE IT_REDINSS		 26,02  //Percentual de Reducao da Base de Calculo do INSS
#DEFINE IT_ALIQINS		 26,03  //Aliquota de Calculo do INSS
#DEFINE IT_VALINS		 26,04  //Valor do INSS
#DEFINE IT_ACINSS		 26,05  //Acumulo INSS
#DEFINE IT_VALEMB		 27	    //Valor da embalagem
#DEFINE IT_BASEIMP		 28	    //Array contendo as Bases de Impostos Variaveis
#DEFINE IT_BASEIV1		 28,01  //Base de Impostos Variaveis 1
#DEFINE IT_BASEIV2		 28,02  //Base de Impostos Variaveis 2
#DEFINE IT_BASEIV3		 28,03  //Base de Impostos Variaveis 3
#DEFINE IT_BASEIV4		 28,04  //Base de Impostos Variaveis 4
#DEFINE IT_BASEIV5		 28,05  //Base de Impostos Variaveis 5
#DEFINE IT_BASEIV6		 28,06  //Base de Impostos Variaveis 6
#DEFINE IT_BASEIV7		 28,07  //Base de Impostos Variaveis 7
#DEFINE IT_BASEIV8		 28,08  //Base de Impostos Variaveis 8
#DEFINE IT_BASEIV9		 28,09  //Base de Impostos Variaveis 9
#DEFINE IT_ALIQIMP		 29	    //Array contendo as Aliquotas de Impostos Variaveis
#DEFINE IT_ALIQIV1		 29,01  //Aliquota de Impostos Variaveis 1
#DEFINE IT_ALIQIV2		 29,02  //Aliquota de Impostos Variaveis 2
#DEFINE IT_ALIQIV3		 29,03  //Aliquota de Impostos Variaveis 3
#DEFINE IT_ALIQIV4		 29,04  //Aliquota de Impostos Variaveis 4
#DEFINE IT_ALIQIV5		 29,05  //Aliquota de Impostos Variaveis 5
#DEFINE IT_ALIQIV6		 29,06  //Aliquota de Impostos Variaveis 6
#DEFINE IT_ALIQIV7		 29,07  //Aliquota de Impostos Variaveis 7
#DEFINE IT_ALIQIV8		 29,08  //Aliquota de Impostos Variaveis 8
#DEFINE IT_ALIQIV9		 29,09  //Aliquota de Impostos Variaveis 9
#DEFINE IT_VALIMP		 30     //Array contendo os valores de Impostos Agentina/Chile/Etc.
#DEFINE IT_VALIV1		 30,01  //Valor do Imposto Variavel 1
#DEFINE IT_VALIV2		 30,02  //Valor do Imposto Variavel 2
#DEFINE IT_VALIV3		 30,03  //Valor do Imposto Variavel 3
#DEFINE IT_VALIV4		 30,04  //Valor do Imposto Variavel 4
#DEFINE IT_VALIV5		 30,05  //Valor do Imposto Variavel 5
#DEFINE IT_VALIV6		 30,06  //Valor do Imposto Variavel 6
#DEFINE IT_VALIV7		 30,07  //Valor do Imposto Variavel 7
#DEFINE IT_VALIV8		 30,08  //Valor do Imposto Variavel 8
#DEFINE IT_VALIV9		 30,09  //Valor do Imposto Variavel 9
#DEFINE IT_BASEDUP  	 31	    //Base das duplicatas geradas no financeiro
#DEFINE IT_DESCZF		 32	    //Valor do desconto da Zona Franca do item
#DEFINE IT_DESCIV		 33	    //Array contendo a descricao dos Impostos Variaveis
#DEFINE IT_DESCIV1	     33,1   //Array contendo a Descricao dos IV 1
#DEFINE IT_DESCIV2		 33,2   //Array contendo a Descricao dos IV 2
#DEFINE IT_DESCIV3		 33,3   //Array contendo a Descricao dos IV 3
#DEFINE IT_DESCIV4		 33,4   //Array contendo a Descricao dos IV 4
#DEFINE IT_DESCIV5		 33,5   //Array contendo a Descricao dos IV 5
#DEFINE IT_DESCIV6		 33,6   //Array contendo a Descricao dos IV 6
#DEFINE IT_DESCIV7		 33,7   //Array contendo a Descricao dos IV 7         
#DEFINE IT_DESCIV8		 33,8   //Array contendo a Descricao dos IV 8
#DEFINE IT_DESCIV9		 33,9   //Array contendo a Descricao dos IV 9
#DEFINE IT_QUANT		 34	    //Quantidade do Item
#DEFINE IT_PRCUNI		 35	    //Preco Unitario do Item
#DEFINE IT_VIPIBICM 	 36	    //Valor do IPI Incidente na Base de ICMS
#DEFINE IT_PESO     	 37	    //Peso da mercadoria do item
#DEFINE IT_ICMFRETE 	 38	    //Valor do ICMS Relativo ao Frete
#DEFINE IT_BSFRETE  	 39	    //Base do ICMS Relativo ao Frete
#DEFINE IT_BASECOF  	 40	    //Base de calculo do COFINS
#DEFINE IT_ALIQCOF  	 41	    //Aliquota de calculo do COFINS
#DEFINE IT_VALCOF   	 42	    //Valor do COFINS
#DEFINE IT_BASECSL  	 43     //Base de calculo do CSLL
#DEFINE IT_ALIQCSL  	 44     //Aliquota de calculo do CSLL
#DEFINE IT_VALCSL   	 45	    //Valor do CSLL
#DEFINE IT_BASEPIS  	 46	    //Base de calculo do PIS
#DEFINE IT_ALIQPIS  	 47	    //Aliquota de calculo do PIS
#DEFINE IT_VALPIS   	 48	    //Valor do PIS
#DEFINE IT_RECNOSB1 	 49	    //RecNo do SB1
#DEFINE IT_RECNOSF4 	 50	    //RecNo do SF4
#DEFINE IT_VNAGREG      51	    //Valor da Mercadoria nao agregada.
#DEFINE IT_TIPONF       52     //Tipo da nota fiscal
#DEFINE IT_REMITO       53     //Remito
#DEFINE IT_BASEPS2      54	    //Base de calculo do PIS 2
#DEFINE IT_ALIQPS2      55	    //Aliquota de calculo do PIS 2
#DEFINE IT_VALPS2       56	    //Valor do PIS 2
#DEFINE IT_BASECF2      57	    //Base de calculo do COFINS 2
#DEFINE IT_ALIQCF2      58	    //Aliquota de calculo do COFINS 2
#DEFINE IT_VALCF2       59	    //Valor do COFINS 2
#DEFINE IT_ABVLINSS     60     //Abatimento da base do INSS em valor 
#DEFINE IT_ABVLISS      61     //Abatimento da base do ISS em valor 
#DEFINE IT_REDISS       62     //Percentual de reducao de base do ISS ( opcional, utilizar normalmente TS_BASEISS ) 
#DEFINE IT_ICMSDIF      63     //Valor do ICMS diferido
#DEFINE IT_DESCZFPIS    64     //Desconto do PIS
#DEFINE IT_DESCZFCOF    65     //Desconto do Cofins
#DEFINE IT_BASEAFRMM    66	    //Base de calculo do AFRMM ( Item )
#DEFINE IT_ALIQAFRMM    67	    //Aliquota de calculo do AFRMM ( Item )
#DEFINE IT_VALAFRMM     68	    //Valor do AFRMM ( Item )
#DEFINE IT_PIS252       69     //Decreto 252 de 15/06/2005 - PIS no item para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
#DEFINE IT_COF252       70     //Decreto 252 de 15/06/2005 - COFINS no item para retencao aquisicao a aquisicao - sem considerar R# 5.000,00 da Lei 10925
#DEFINE IT_CRDZFM       71     //Credito Presumido - Zona Franca de Manaus
#DEFINE IT_CNAE         72     //Codigo da Atividade Economica da Prestacao de Servicos
#DEFINE IT_ITEM         73     //Numero Item
#DEFINE IT_SEST	         74     //Array contendo os valores do SEST
#DEFINE IT_BASESES      74,01  //Base de calculo do SEST
#DEFINE IT_ALIQSES      74,02  //Aliquota de calculo do SEST
#DEFINE IT_VALSES       74,03  //Valor do INSS
#DEFINE IT_BASEPS3      75	    //Base de calculo do PIS Subst. Tributaria
#DEFINE IT_ALIQPS3      76	    //Aliquota de calculo do PIS Subst. Tributaria
#DEFINE IT_VALPS3       77	    //Valor do PIS Subst. Tributaria
#DEFINE IT_BASECF3      78	    //Base de calculo da COFINS Subst. Tributaria
#DEFINE IT_ALIQCF3      79	    //Aliquota de calculo da COFINS Subst. Tributaria
#DEFINE IT_VALCF3       80	    //Valor da COFINS Subst. Tributaria
#DEFINE IT_VLR_FRT      81     //Valor do Frete de Pauta
#DEFINE IT_BASEFET      82	    //Base do Fethab   
#DEFINE IT_ALIQFET      83	    //Aliquota do Fethab
#DEFINE IT_VALFET       84	    //Valor do Fethab   
#DEFINE IT_ABSCINS      85	    //Abatimento do Valor do INSS em Valor - SubContratada
#DEFINE IT_SPED         86     //SPED
#DEFINE IT_ABMATISS     87     //Abatimento da base do ISS em valor referente a material utilizado 
#DEFINE IT_RGESPST      88     //Indica se a operacao, mesmo sem calculo de ICMS ST, faz parte do Regime Especial de Substituicao Tributaria
#DEFINE IT_PRFDSUL      89     //Percentual de UFERMS para o calculo do Fundersul - Mato Grosso do Sul
#DEFINE IT_UFERMS       90     //Valor da UFERMS para o calculo do Fundersul - Mato Grosso do Sul
#DEFINE IT_VALFDS       91     //Valor do Fundersul - Mato Grosso do Sul
#DEFINE IT_ESTCRED      92     //Valor do Estorno de Credito/Debito
#DEFINE IT_CODIF        93     //Codigo de autorizacao CODIF - Combustiveis
#DEFINE IT_BASETST      94     //Base do ICMS de transporte Substituicao Tributaria
#DEFINE IT_ALIQTST      95     //Aliquota do ICMS de transporte Substituicao Tributaria
#DEFINE IT_VALTST       96     //Valor do ICMS de transporte Substituicao Tributaria
#DEFINE IT_CRPRSIM      97     //Valor Crédito Presumido Simples Nacional - SC, nas aquisições de fornecedores que se enquadram no simples
#DEFINE IT_VALANTI      98     //Valor Antecipacao ICMS                       
#DEFINE IT_DESNTRB      99     //Despesas Acessorias nao tributadas - Portugal
#DEFINE IT_TARA        100     //Tara - despesas com embalagem do transporte - Portugal
#DEFINE IT_PROVENT     101     //Provincia de entrega
#DEFINE IT_VALFECP     102     //Valor do FECP
#DEFINE IT_VFECPST     103     //Valor do FECP ST
#DEFINE IT_ALIQFECP    104     //Aliquota FECP
#DEFINE IT_CRPRESC     105     //Credito Presumido SC 
#DEFINE IT_DESCPRO     106     //Valor do desconto total proporcionalizado
#DEFINE IT_ANFORI2     107     //IVA Ajustado
#DEFINE IT_UFORI       107,01  //UF Original da Nota de Entrada para o calculo do IVA Ajustado( Opcional )
#DEFINE IT_ALQORI      107,02  //Aliquota Original da Nota de Entrada para o calculo do IVA Ajustado ( Opcional )
#DEFINE IT_PROPOR      107,03  //Quantidade proporcional na venda para o calculo do IVA Ajustado( Opcional )
#DEFINE IT_ALQPROR     107,04  //Aliquota proporcional na venda para o calculo do IVA Ajustado( Opcional )
#DEFINE IT_ANFII       108     //Array contendo os valores do Imposto de Importação
#DEFINE IT_ALIQII      108,01  //Aliquota do Imposto de Importação
#DEFINE IT_VALII       108,02  //Valor do Imposto de Importação (Digitado direto na Nota Fiscal)
#DEFINE IT_PAUTPIS     109	    //Valor da Pauta do PIS
#DEFINE IT_PAUTCOF     110	    //Valor da Pauta do Cofins
#DEFINE IT_ALIQDIF     111	    //Aliquota interna do estado para calculo do Diferencial de aliquota do Simples Nacional
#DEFINE IT_CLASFIS     112	    //Valor do Imposto de Importação (Digitado direto na Nota Fiscal)
#DEFINE IT_VLRISC      113	    //Valor do imposto ISC (Localizado Peru) por unidade  "PER"
#DEFINE IT_CRPREPE     114     //Credito Presumido - Art. 6 Decreto  n28.247
#DEFINE IT_CRPREMG     115     //Credito Presumido MG 
#DEFINE IT_SLDDEP      116     //Valor de desconto de depedendente fornecedor
#DEFINE IT_CRPRECE     117     //Credito Presumido Ceara
#DEFINE IT_BASEFAB     118     //Base do FABOV - Mato Grosso   
#DEFINE IT_ALIQFAB     119     //Aliquota do FABOV - Mato Grosso
#DEFINE IT_VALFAB      120     //Valor do FABOV - Mato Grosso
#DEFINE IT_BASEFAC     121     //Base do FACS - Mato Grosso  
#DEFINE IT_ALIQFAC     122     //Aliquota do FACS - Mato Grosso
#DEFINE IT_VALFAC      123     //Valor do FACS - Mato Grosso
#DEFINE IT_VALFUM      124     //Valor do FUMACOP
#DEFINE IT_ALIQFUM     125     //Aliquota FUMACOP
#DEFINE IT_CONCEPT     126     //Concepto de Retencao - Equador
#DEFINE IT_MOTICMS     127	    //moticms 
#DEFINE IT_ALSENAR     128     //Aliquota SENAR  
#DEFINE IT_VLSENAR     129     //Valor do Senar
#DEFINE IT_BSSENAR     130     //Base de Calculo do Senar      
#DEFINE IT_CROUTSP     131     //Cr	edito Outorgado SP - Decreto 56.018/2010   
#DEFINE IT_AVLINSS     132     //Abatimento do valor do INSS Subcontratada    
#DEFINE IT_BSSEMDS     133     //Base do ICMS sem desconto - Decreto 43.080/2002 RICMS-MG
#DEFINE IT_ICSEMDS     134     //Valor do ICMS sem desconto - Decreto 43.080/2002 RICMS-MG
#DEFINE IT_PR43080     135     //Percentual de Reducao - Decreto 43.080/2002 RICMS-MG
#DEFINE IT_BASEFUN     136     //Valor da Base do FUNRURAL
#DEFINE IT_BASVEIC     137     //Valor da Base Veiculos
#DEFINE IT_BASRESI     138,01  //Valor da Base ICMS ST nas operacoes substituidos do MT.
#DEFINE IT_VALRESI     138,02  //Valor do Valor ICMS ST nas operacoes substituidos do MT.
#DEFINE IT_ALQRESI     138,03  //Valor da Aliquota ICMS ST nas operacoes substituidos do MT.
#DEFINE IT_BASEFUM     139	   //Valor da Base do FUMACOP
#DEFINE IT_CRPREPR     140     //Valor do Credito Presumido - PR - RICMS - (Art. 4) - Anexo III.  
#DEFINE IT_TABNTRE     141,01	//Tabela Natureza da Receita
#DEFINE IT_CODNTRE     141,02	//Codigo Natureza da Receita
#DEFINE IT_GRPNTRE     141,03	//Grupo Natureza da Receita
#DEFINE IT_DATNTRE     141,04	//Data Final Natureza da Receita
#DEFINE IT_ALITPDP		142,01	// Aliquota da TPDP - Paraiba.
#DEFINE IT_BASTPDP		142,02  // Base de Calculo da TPDP - Paraiba.
#DEFINE IT_VALTPDP		142,03	// Valor da TPDP - Paraiba.
#DEFINE IT_VLINCMG     143     //Valor do incentivo prod.leite RICMS-MG
#DEFINE IT_PRINCMG     144     //Percentual de incentivo prod.leite artigo 207-B RICMS-MG
#DEFINE IT_INSSAD	    145     //Array contendo os valores de INSS Condições Especiais
#DEFINE IT_BASEINA     145,01  //Base de calculo do INSS Condições Especiais
#DEFINE IT_ALIQINA	    145,02  //Aliquota de Calculo do INSS Condições Especiais
#DEFINE IT_VALINA	    145,03  //Valor do INSS Condições Especiais
#DEFINE IT_VFECPRN     146     //Valor do FECOP-RN
#DEFINE IT_VFESTRN     147     //Valor do FECOP ST-RN
#DEFINE IT_ALFECRN     148     //Aliquota FECOP-RN            
#DEFINE IT_VLRFUE      149     //Valor do FUE - localização Austrália
#DEFINE IT_METODO      150     //Método utilizado cálculo FUE - localização Austrália
#DEFINE IT_NORESPE     151  	//NF. Emitida sob Norma Específica
#DEFINE IT_COEPSST     152  	//151 - Coeficiente de PIS por Substituição Tributária para fabricantes de cigarros
#DEFINE IT_COECFST     153  	//152 - Coeficiente de COFINS por Substituição Tributária para fabricantes de cigarros
#DEFINE IT_CREDPRE     154  	//154 - Credito Presumido RS
#DEFINE IT_PRCUNIC	    155     //155 - Preco Unitario utilizado para calculo da Substituição tributária para fabrixante de Cigarros/
#DEFINE IT_RANTSPD	    156     //156 - Recolhimento Antecipado - Para atender necessidades do SPEDFISCAL de MG
#DEFINE IT_VFECPMG     157     	//Valor do FECP-MG
#DEFINE IT_VFESTMG     158     	//Valor do FECP ST-MG
#DEFINE IT_ALFECMG     159     	//Aliquota FECP-MG 
#DEFINE IT_VREINT      160     	//Valor de Reintegra 
#DEFINE IT_BSREIN      161     	//Base de Calculo do Reintegra 
#DEFINE IT_VALCMAJ	    162     //Valor da COFINS de Importacao Majorada.
#DEFINE IT_ALQCMAJ	    163     //Aliquota da COFINS de Importacao Majorada.
#DEFINE IT_VFECPMT     164     	//Valor do FECP-MT
#DEFINE IT_VFESTMT     165     	//Valor do FECP ST-MT
#DEFINE IT_ALFECMT     166     	//Aliquota FECP-MT  
#DEFINE IT_LOTE		    167,01  //Lote do Produto
#DEFINE IT_SUBLOTE     167,02  //Lote do Produto  
#DEFINE IT_B1DIAT      168		//DIAT-SC   
#DEFINE IT_CPDIFST     169		//Campo de diferimento na tabela SB1 - Conteudo do parametro MV_ALQDFB1
#DEFINE IT_CPPERST     170		//Campo Indica o % calculo do ICMS-ST tabela SB1 - Conteudo do parametro MV_B1PTST
#DEFINE IT_RSATIVO     171		//Indica Rastro ativo do IPI - B1_RSATIVO           
#DEFINE IT_POSIPI		172		// Nomenclatura Ext.Mercosul - B1_POSIPI  
#DEFINE IT_B1UM	 		173
#DEFINE IT_B1SEGUM		174
#DEFINE IT_AFABOV		175
#DEFINE IT_AFACS		176
#DEFINE IT_AFETHAB		177
#DEFINE IT_TFETHAB		178
#DEFINE IT_EXCEFAT     179    //Array da excessao fiscal do Cliente de Faturamento 
#DEFINE IT_ADIANT      180	   //Adiantamentos Mexico
#DEFINE IT_NATOPER     181    //Codigo da Natureza da Operacao/Prestacao
#DEFINE IT_PRD         182    //Array com os Dados do cadastro de produtos ( SB1 ou SBi ou SBZ )
#DEFINE IT_IDSF4       183,01   // ID Historico SF4
#DEFINE IT_IDSF7       183,02   // ID Historico SF7
#DEFINE IT_IDSA1       183,03   // ID Historico SA1
#DEFINE IT_IDSA2       183,04   // ID Historico SA2
#DEFINE IT_IDSB1       183,05   // ID Historico SB1
#DEFINE IT_IDSB5       183,06   // ID Historico SB5
#DEFINE IT_IDSBZ       183,07   // ID Historico SBZ
#DEFINE IT_IDSED       183,08   // ID Historico SED
#DEFINE IT_IDSFB       183,09   // ID Historico SFB
#DEFINE IT_IDSFC       183,10   // ID Historico SFC                                            
#DEFINE IT_IDCFC       183,11   // ID Historico CFC
#DEFINE IT_DESCTOT     184      // Referencia de Desconto por Item - USO DO NOVO PDV - LOJA   
#DEFINE IT_ACRESCI     185      // Referencia de Acrescimo por Item - USO DO NOVO PDV - LOJA
#DEFINE IT_VALPMAJ	   186     //Valor da PIS de Importacao Majorada.
#DEFINE IT_ALQPMAJ	   187     //Aliquota da PIS de Importacao Majorada.     
#DEFINE IT_PRDFIS	    188		 // Identificação do produto fiscal
#DEFINE IT_RECPRDF	    189		 // Recno do produto fiscal
#DEFINE IT_NCMFIS	    190		 // Identificação do NCM secundario (produto fiscal)                                            
#DEFINE IT_UFXPROD		191		 // Array com conteudo da tabela CFC (por produto)
#DEFINE IT_VALCIDE	    192      // Valor Cide
#DEFINE IT_CV139	    193      // Identificação do tratamento do convênio 139/06.
#DEFINE IT_VALFETR	    194      // Valor do FETHAB de algodão retido pelo cliente.   
#DEFINE IT_ALFCST	    195      // Aliquota do FECP ST
#DEFINE IT_ALFCCMP	    196      // Aliquota do FECP Complementar (Diferencial de aliquotas/Antecipacao)
#DEFINE IT_BASNDES		197
#DEFINE IT_ICMNDES	    198	   
#DEFINE IT_ADIANTTOT    199		 // Adiantamento (Peru) 
#DEFINE IT_UVLRC		200
#DEFINE IT_PRCCF   		201  		// Identifica o preço para Consumidor Final
#DEFINE IT_BASECID      202 //Base de cálculo cide
#DEFINE IT_ALQCIDE		203	 //Aliquota Cide
#DEFINE IT_BASECPM 		204 //Base do ISS CEPOM
#DEFINE IT_VALCPM		205	 // Valor do ISS CEPOM
#DEFINE IT_ALQCPM		206 // Aliquota do ISS CEPOM
#DEFINE IT_IPIVFCF		207 //Valor IPI a ser inserido na base do ICM, venda futura CF
#DEFINE IT_BASEFMP		208 //Base Fumipeq
#DEFINE IT_VALFMP		209	 //Valor Fumipeq
#DEFINE IT_ALQFMP		210 //Aliquota Fumipeq
#DEFINE IT_BASEFMD		211 //Base FAMAD	
#DEFINE IT_VALFMD		212 //Valor FAMAD
#DEFINE IT_ALQFMD		213 // Alíquota FAMAD
#DEFINE IT_TS           214 // Array com as informacoes da TES.
#DEFINE IT_PAUTAPS		215
#DEFINE IT_PAUTACF		216
#DEFINE IT_GRPCST		217 //Enquadramento IPI
#DEFINE IT_CEST			218	//CEST
#DEFINE IT_BASECPB 	219 //Base do CPRB     
#DEFINE IT_VALCPB		220	 // Valor do CPRB
#DEFINE IT_ALIQCPB	221 // Aliquota do CPRB
#DEFINE IT_ATIVCPB	222 // Código atividade CPRB  
#DEFINE IT_DIFAL		223 //DIFAL icms
#DEFINE IT_PDDES		224
#DEFINE IT_PDORI		225
#DEFINE IT_VFCPDIF		226 //Valor FECP DIFAL
#DEFINE IT_FTRICMS		227 //Fator de Redução Desc.ICMS
#DEFINE IT_VRDICMS		228 //Valor de Redução Desc.ICMS
#DEFINE IT_BASFUND   229		//Base do FUNDESA
#DEFINE IT_ALIFUND   230		//Aliquota do FUNDESA
#DEFINE IT_VALFUND   231		//Valor do FUNDESA    
#DEFINE IT_BASIMA		232		//Base do IMA-MT
#DEFINE IT_ALIIMA		233		//Aliquota do IMA-MT
#DEFINE IT_VALIMA    234		//Valor do IMA-MT   
#DEFINE IT_AIMAMT		235  	//Alíquota IMA-MT (SB1) 
#DEFINE IT_VLIMAR		236		//Valor do IMA-MT retido pelo cliente.   
#DEFINE IT_BASFASE	237		//Base do FASE-MT
#DEFINE IT_ALIFASE	238		//Aliquota do FASE-MT
#DEFINE IT_VALFASE   239		//Valor do FASE-MT   
#DEFINE IT_AFASEMT	240  	//Alíquota FASE-MT (SB1) 
#DEFINE IT_VLFASER	241		//Valor do FASE-MT retido pelo cliente.
#DEFINE IT_PRCMEDP	242		//Preço Médio Ponderado, para ser utilizado como base de ICMS ST
#DEFINE IT_INDICE   243   //Indice tabela F0R
#DEFINE IT_VALPEDG  244   //Valor do Pedágio, informado pela rotina MATA116.
#DEFINE IT_VLSLXML	245	  // Valor Solidario XML 
#DEFINE IT_VLRCID   246 //Pauta CIDE
#DEFINE IT_CSOSN		247 //CSOSN
#DEFINE IT_BASEINP	248 //Base do INSS Patronal
#DEFINE IT_PERCINP	249 //Percentual do INSS Patronal
#DEFINE IT_VALINP	250 //Valor do INSS Patronal
#DEFINE IT_TRIBMU	251 // Código de Trib. Municipal
#DEFINE IT_AFRMIMP  252 // Valor do AFRMM na Importação
#DEFINE IT_CPRESPR  253 // Valor do Credito Presumido Paraná
#DEFINE IT_DS43080	254 //Valor do desconto - Decreto 43.080/2002 RICMS-MG
#DEFINE IT_VOPDIF    255 //Valor do ICMS da Operação - Sem diferimento (Valor como se não tivesse o diferimento)
#DEFINE IT_BASEPRO	256 //Base PROTEGE-GO
#DEFINE IT_ALIQPRO	257 //Aliquota PROTEGE-GO
#DEFINE IT_VALPRO	   258 //Valor PROTEGE-GO
#DEFINE IT_BASFEEF	259 //Base FEEF-RJ
#DEFINE IT_ALQFEEF	260 //Aliquota FEEF-RJ
#DEFINE IT_VALFEEF	261 //Valor FEEF-RJ

#DEFINE LF_CFO			 01	   // Codigo Fiscal
#DEFINE LF_ALIQICMS 	 02	   // Aliquota de ICMS
#DEFINE LF_VALCONT		 03	   // Valor Contabil
#DEFINE LF_BASEICM		 04	   // Base de ICMS
#DEFINE LF_VALICM		 05	   // Valor do ICMS
#DEFINE LF_ISENICM		 06	   // ICMS Isento
#DEFINE LF_OUTRICM		 07	   // ICMS Outros
#DEFINE LF_BASEIPI		 08	   // Base de IPI
#DEFINE LF_VALIPI		 09	   // IPI Tributado
#DEFINE LF_ISENIPI		 10	   // IPI Isento
#DEFINE LF_OUTRIPI		 11	   // IPI Outros
#DEFINE LF_OBSERV		 12	   // Observacao
#DEFINE LF_VALOBSE		 13    // Valor na Observacao
#DEFINE LF_ICMSRET		 14	   // Valor ICMS Retido
#DEFINE LF_LANCAM		 15	   // Numero do Lancamento
#DEFINE LF_TIPO	         16    // Tipo de Lancamento
#DEFINE LF_ICMSCOMP 	 17    // ICMS Complementar
#DEFINE LF_CODISS		 18	   // Cod.Serv. ISS
#DEFINE LF_IPIOBS		 19	   // IPI na Observacao
#DEFINE LF_NFLIVRO		 20	   // Numero do Livro
#DEFINE LF_ICMAUTO		 21	   // ICMS Frete Autonomo
#DEFINE LF_BASERET		 22	   // Base do ICMS Retido
#DEFINE LF_FORMUL		 23	   // Flag de Fom. Proprio
#DEFINE LF_FORMULA		 24	   // Formula
#DEFINE LF_DESPESA		 25	   // Despesas Acessorias
#DEFINE LF_ICMSDIF		 26	   // Icms Diferido
#DEFINE LF_TRFICM	     27	   // Transferencia de Debito e Credito
#DEFINE LF_OBSICM	     28	   // Icms na coluna de observacoes
#DEFINE LF_OBSSOL	     29	   // Solidario na coluna de observacoes
#DEFINE LF_SOLTRIB	     30	   // Valor do ICMS Solidario que possui tributacao com credito de imposto
#DEFINE LF_CFOEXT		 31	   // Codigo Fiscal Extendido
#DEFINE LF_ISSST		 32	   // Codigo Fiscal Extendido 
#DEFINE LF_RECISS	     33    // Codigo Fiscal Extendido 
#DEFINE LF_ISSSUB       34    // ISS de Sub-empreitada.
#DEFINE LF_ISS_ALIQICMS 35,01 // Aliquota de ICMS
#DEFINE LF_ISS_ISENICM	 35,02 // ICMS Isento
#DEFINE LF_ISS_OUTRICM	 35,03 // ICMS Outros
#DEFINE LF_ISS_ISENIPI	 35,04 // IPI Isento
#DEFINE LF_ISS_OUTRIPI	 35,05 // IPI Outros
#DEFINE LF_CREDST       36    // Credito / Debito Substituição tributária.
#DEFINE LF_CRDEST       37    // Credito Estimulo de Manaus
#DEFINE LF_CRDPRES      38    // Credito Presumido
#DEFINE LF_SIMPLES      39    // Valor do ICMS para clientes optantes pelo Simples - SC
#DEFINE LF_CRDTRAN      40    // Credito Presumido - RJ - Prestacoes de Servicos de Transporte
#DEFINE LF_CRDZFM       41    // Credito Presumido - Zona Franca de Manaus
#DEFINE LF_CNAE         42    // Codigo da Atividade Economica da Prestacao de Servicos
#DEFINE LF_IDENT        43    // Identificador de gravacao
#DEFINE LF_CLASFIS      44    //Classificacao fiscal de acordo com o F4_SITTRIB + B1_ORIGEM
#DEFINE LF_CTIPI        45    //Codigo de Situacao tributaria do IPI
#DEFINE LF_ESTOQUE      46    //Movimentacao fisica do estoque 
#DEFINE LF_DESPIPI      47    //IPI sobre despesas acessorias
#DEFINE LF_POSIPI       48    //NCM Produto
#DEFINE LF_OUTRRET      49    //ICMS Retido escriturado coluna Outros
#DEFINE LF_ISENRET      50    //ICMS Retido escriturado coluna Isento
#DEFINE LF_ITEMORI      51    //Numero Item da NF Ori
#DEFINE LF_CFPS         52    //Codigo Fiscal de Prestacao de Servicos                                        
#DEFINE LF_ALIQIPI      53    //Aliquota de IPI
#DEFINE LF_CRPRST       54    //valor Credito Presumido Substituicao Tributaria retido pelo contratante do servico de transporte - Decreto 44.147/2005 (MG)
							   //	- Decreto 44.147/2005 (MG)
							   // 	- Decreto 20.686, Art 111, $6 em diante. (AM)
#DEFINE LF_TRIBRET      55    //ICMS Retido escriturado coluna Tributado
#DEFINE LF_DESCZFR      56    //Desconto Zona Franca de Manaus
#DEFINE LF_BASEPS3      57    //Base PIS Subst. Tributaria    
#DEFINE LF_ALIQPS3      58    //Aliquota do PIS Subst. Tributaria    
#DEFINE LF_VALPS3       59    //Valor do PIS Subst. Tributaria    
#DEFINE LF_BASECF3      60    //Base da Cofins Subst. Tributaria
#DEFINE LF_ALIQCF3      61    //Aliquota da da Cofins Subst. Tributaria
#DEFINE LF_VALCF3       62    //Valor da da Cofins Subst. Tributaria
#DEFINE LF_CRPRELE      63    //Valor Crédito Presumido nas operações de Saída com o ICMS destacado sobre os produtos resultantes da industrialização com componentes, partes e pecas recebidos do exterior, destinados a fabricacao de produtos de informatica, eletronicos e telecomunicacoes, por estabelecimento industrial desses setores. Tratamento conforme Art. 1?do DECRETO 4.316 de 19 de Junho de 1995.(BA)
#DEFINE LF_ISSMAT       64    //Valor da deducao da base de calculo do ISS referente ao material aplicado
#DEFINE LF_VALFDS       65    //Valor do Fundersul - Mato Grosso do Sul
#DEFINE LF_ESTCRED      66    //Valor do Estorno de Credito/Debito
#DEFINE LF_CRPRSIM      67    //Valor Crédito Presumido Simples Nacional - SC, nas aquisições de fornecedores que se enquadram no simples
#DEFINE LF_BASETST      68    //Base do ICMS de transporte Substituicao Tributaria
#DEFINE LF_VALTST    	 69    //Valor do ICMS de transporte Substituicao Tributaria
#DEFINE LF_ANTICMS    	 70    //Indica se a operacao se refere a Antecipacao Tribut. de ICMS (1=Sim/2=Nao)
#DEFINE LF_VALANTI    	 71    //Valor Antecipacao ICMS
#DEFINE LF_CRPREPR      72    // Credito Presumido - RICMS (Art.4) - Anexo III
#DEFINE LF_VALFECP    	 73    //Valor FECP
#DEFINE LF_VFECPST    	 74    //Valor FECP ST
#DEFINE LF_CSTPIS       75    //Codigo de Situacao tributaria do PIS
#DEFINE LF_CSTCOF       76    //Codigo de Situacao tributaria do COFINS
#DEFINE LF_CREDACU    	 77    //Indicacao do Credito Acumulado de ICMS - Bahia
#DEFINE LF_CRPRERO      78    //Credito Presumido - RICMS (Art.39) - Anexo IV 
#DEFINE LF_VALII 	     79    //Valor do Imposto de Importacao (PIS/COFINS)   
#DEFINE LF_CRPREPE      80    //Credito Presumido - Art. 6 Decreto  n28.247    
#DEFINE LF_CSTISS       81    //Classificacao fiscal de acordo com o F4_CSTISS
#DEFINE LF_CPRESPR      82    //Credito Presumido art 631-A do RICMS/2008 - PR
#DEFINE LF_VALFET       83    //Valor do FACS - Mato Grosso 
#DEFINE LF_VALFAB       84    //Valor do FABOV - Mato Grosso
#DEFINE LF_VALFAC       85    //Valor do FACS - Mato Grosso 
#DEFINE LF_CRPRESP      86	   //Credito Presumido - Decreto 52.586 de 28.12.2007
#DEFINE LF_VALFUM       87    //Valor FUMACOP
#DEFINE LF_MOTICMS      88	   // Codigo Fiscal Extendido 
#DEFINE LF_VLSENAR      89    //Valor do Senar     
#DEFINE LF_CROUTSP      90    //Credito Outorgado SP - Decreto 56.018/2010    
#DEFINE LF_DS43080      91    //Valor do desconto - Decreto 43.080/2002 RICMS-MG   
#DEFINE LF_VL43080      92    //Valor do ICMS sem debito de imposto - Decreto 43.080/2002 RICMS-MG   
#DEFINE LF_CPPRODE      93    // PRODEPE
#DEFINE LF_TPPRODE      94    // PRODEPE
#DEFINE LF_CODBCC       95    //Codigo da base de calculo do credito
#DEFINE LF_INDNTFR      96    //Indicador da natureza do frete contratado
#DEFINE LF_TABNTRE      97    //Tabela Natureza da Receita
#DEFINE LF_CODNTRE      98    //Codigo Natureza da Receita
#DEFINE LF_GRPNTRE      99    //Grupo Natureza da Receita
#DEFINE LF_DATNTRE     100    //Data Final Natureza da Receita
#DEFINE LF_VALTPDP     101    //Valor do TPDP PB
#DEFINE LF_VFECPRN    	102    //Valor FECOP-RN
#DEFINE LF_VFESTRN    	103    //Valor FECOP ST-RN
#DEFINE LF_CROUTGO   	104    //Valor Credito Outorgado GO
#DEFINE LF_CRDPCTR  	105    //Valor Credito Presumido utilizando percentual da carga tributária
#DEFINE LF_CREDPRE     106    //Credito Presumido RS
#DEFINE LF_VFECPMG   	107    //Valor FECP-MG
#DEFINE LF_VFESTMG   	108    //Valor FECP ST-MG 
#DEFINE LF_VREINT   	109    //Valor de Reintegra 
#DEFINE LF_BSREIN   	110    //Base de Calculo do Reintegra
#DEFINE LF_VALCMAJ		111    //Valor da COFINS de Importacao Majorada.
#DEFINE LF_ALQCMAJ		112    //Aliquota da COFINS de Importacao Majorada.
#DEFINE LF_VFECPMT   	113    //Valor FECP-MT
#DEFINE LF_VFESTMT   	114    //Valor FECP ST-MT  
#DEFINE LF_VALPMAJ		115    //Valor da PIS de Importacao Majorada.
#DEFINE LF_ALQPMAJ		116   	//Aliquota da PIS de Importacao Majora
#DEFINE LF_BASECPM		117	  	//Base do ISS CEPOM
#DEFINE LF_ALQCPM		118  	// Valor do ISS CEPOM
#DEFINE LF_VALCPM		119  	// Aliquota do ISS CEPOM   
#DEFINE LF_BASEFMP		120	  	//Base do FUMIPEQ
#DEFINE LF_VALFMP		121  	// Valor do FUMIPEQ
#DEFINE LF_ALQFMP		122  	// Aliquota do FUMIPEQ  
#DEFINE LF_VALFMD		123 	//Valor FAMAD
#DEFINE LF_BASNDES		124		//Base ICMS ST Recolh. Ant.
#DEFINE LF_ICMNDES	    125		//Valor ICMS ST Recolhido Anteriormente.
#DEFINE LF_BASECPB		126 //Base do CPRB  
#DEFINE LF_VALCPB			127 //Valor do CPRB
#DEFINE LF_ALIQCPB		128 //Aliquota do CPRB
#DEFINE LF_DIFAL		129
#DEFINE LF_VFCPDIF		130 // Valor FECP DIFAL
#DEFINE LF_BASEDES		131 // Base Difal Destino
#DEFINE LF_BSICMOR		132 // Base ICMS original
#DEFINE LF_VALFUND	133		//Valor do FUNDESA
#DEFINE LF_VALIMA		134		//Valor do IMA-MT
#DEFINE LF_VALFASE	135		//Valor do FASE-MT
#DEFINE LF_PRCMEDP	136		//Preço Médio Ponderado, para ser utilizado como base de ICMS ST
#DEFINE LF_VALPEDG	137     //Valor do Pedágio, informado pela rotina MATA116.
#DEFINE LF_CSOSN    138     //CSOSN
#DEFINE LF_BASEINP	139 //Base do INSS Patronal
#DEFINE LF_PERCINP	140 //Percentual do INSS Patronal
#DEFINE LF_VALINP	141 //Valor do INSS Patronal 
#DEFINE LF_TRIBMU   142 //Código de Trib. Municipal
#DEFINE LF_AFRMIMP  143 //Valor do AFRMM na Importação 
#DEFINE LF_VOPDIF  144 //Valor do ICMS da Operação - Sem diferimento (Valor como se não tivesse o diferimento)
#DEFINE LF_CLIDEST 145 // Cliente de destino do CTE.
#DEFINE LF_LOJDEST 146 // Loja do cliente de destino do CTE.

#DEFINE SP_ITEM         01
#DEFINE SP_CODPRO       02
#DEFINE SP_IMP          03
#DEFINE SP_ORIGEM       04
#DEFINE SP_CST          05
#DEFINE SP_MODBC        06    // 0 - Calculo por Margem de Lucro
                               // 1 - Calculo por pauta ?Valor unitário inferior ao preço comercializado
                               // 2 - Calculo por PMC ?Valor unitário superior ao preço comercializado
                               // 3 - Valor da Operação.
#DEFINE SP_MVA          07
#DEFINE SP_PREDBC       08
#DEFINE SP_BC           09
#DEFINE SP_ALIQ         10
#DEFINE SP_VLTRIB       11
#DEFINE SP_QTRIB        12
#DEFINE SP_PAUTA        13
#DEFINE SP_COD_MN       14
#DEFINE SP_DESCZF       15
#DEFINE SP_PARTICM		16
#DEFINE SP_GRPCST		17
#DEFINE SP_CEST			18
#DEFINE SP_PICMDIF		19
#DEFINE SP_VDDES		20
#DEFINE SP_PDDES		21
#DEFINE SP_PDORI		22
#DEFINE SP_ADIF			23
#DEFINE SP_PFCP			24
#DEFINE SP_VFCP			25
#DEFINE SP_DESONE		26
#DEFINE SP_PDEVOL		27


#DEFINE TS_CODIGO      01    //Codigo da TES
#DEFINE TS_TIPO        02    //Tipo da TES - S Saida , E Entrada
#DEFINE TS_ICM         03    //Calcula ICMS , S-Sim,N-Nao
#DEFINE TS_IPI         04    //Calcula IPI , S-Sim,N-Nao,R-Comerciante nao Atac.
#DEFINE TS_CREDICM     05    //Credito de ICMS , S-Sim,N-Nao
#DEFINE TS_CREDIPI     06    //Credito de IPI  , S-Sim,N-Nao
#DEFINE TS_DUPLIC      07    //Gera Duplicata , S-Sim,N-Nao
#DEFINE TS_ESTOQUE     08    //Movimenta Estoque , S-Sim,N-Nao
#DEFINE TS_CF          09    //Codigo Fiscal de Operacao
#DEFINE TS_TEXTO       10    //Descricao do TES
#DEFINE TS_BASEICM     11    //Reducao da Base de ICMS
#DEFINE TS_BASEIPI     12    //Reducao da Base de IPI
#DEFINE TS_PODER3      13    //Controla Poder de 3os R-Remessa,D-Devolucao,N-Nao Controla
#DEFINE TS_LFICM       14    //Coluna Livros Fiscais ICM - T-Tributado,I-Isentas,O-Outras,N-Nao,Z-ICMS Zerado
#DEFINE TS_LFIPI       15    //Coluna Livros Fiscais IPI - T-Tributado,I-Isentas,O-Outras,N-Nao,Z-IPI Zerado
#DEFINE TS_DESTACA     16    //Destaca IPI S-Sim,N-Nao
#DEFINE TS_INCIDE      17    //Incide IPI na Base de ICMS , S-Sim,N-Nao
#DEFINE TS_COMPL       18    //Calcula ICMS Complementar , S-Sim,N-NAo
#DEFINE TS_IPIFRET     19    //Calcula IPI sobre Frete S-Sim,N-Nao
#DEFINE TS_ISS         20    //Calcula ISS S-Sim,N-Nao
#DEFINE TS_LFISS       21    //Coluna Livros Fiscais ISS - T=Tributado;I=Isento;O=Outros;N=Nao calcula
#DEFINE TS_NRLIVRO     22    //Numero do Livro
#DEFINE TS_UPRC        23    //Atualiza Ultimo Preco de Compra S-Sim,N-Nao
#DEFINE TS_CONSUMO     24    //Material de Consumo S-Sim,N-Nao,O-Outros
#DEFINE TS_FORMULA     25    //Formula para uso na impressao dos Livros Fiscais
#DEFINE TS_AGREG       26    //Agrega Valor a Mercadoria S-Sim N-Nao
#DEFINE TS_INCSOL      27    //Agrega Valor do ICMS Sol. S-Sim,N-Nao
#DEFINE TS_CIAP        28    //Livro Fiscal CIAP S-Sim,N-Nao
#DEFINE TS_DESPIPI     29    //Calcula IPI sobre Despesas S-Sim,N-Nao
#DEFINE TS_LIVRO       30    //Formula para livro Fiscal
#DEFINE TS_ATUTEC      31    //Atualiza SigaTec S-Sim,N-Nao
#DEFINE TS_ATUATF      32    //Atualiza Ativo Fixo S-Sim,N-Nao
#DEFINE TS_TPIPI       33    //Base do IPI B - Valor Bruto , L - Valor Liquido
#DEFINE TS_SFC         34    //Array contendo os Itens do SFC
#DEFINE TS_LIVRO       35    //Nome do Rdmake de complemento/geracao dos livors Fiscais
#DEFINE TS_STDESC      36    //Define se considera o Desconto no calculo do ICMS Retido.
#DEFINE TS_DESPICM     37    //Define se as Despesas entram na base de Calculo de ICMS
#DEFINE TS_BSICMST     38    //% de Reduco da Base de Calculo do ICMS Solidario
#DEFINE TS_BASEISS     39    //% de Reduco da Base de Calculo do ISS.
#DEFINE TS_IPILICM     40    //O ipi deve ser lancado nas colunas nao tributadas do ICMS
#DEFINE TS_ICMSDIF     41    //ICMS Diferido
#DEFINE TS_QTDZERO     42    //Tes permite digitar quantidade zero.
#DEFINE TS_TRFICM      43    //Tes permite digitar quantidade zero.
#DEFINE TS_OBSICM      44    //Icms na coluna de observacao
#DEFINE TS_OBSSOL      45    //Icms Solidario na coluna de observacao
#DEFINE TS_PICMDIF     46    //Percentual do ICMS Diferido
#DEFINE TS_PISCRED     47    //Credita/Debita PIS/COFIS
#DEFINE TS_PISCOF      48    //Calcula PIS/COFIS
#DEFINE TS_CREDST      49    //Credita Solidario
#DEFINE TS_BASEPIS     50    //Percentual de Reducao do PIS
#DEFINE TS_ICMSST      51    //Indica se o ICMS deve ser somado ao ICMS ST.
#DEFINE TS_FRETAUT     52    //Indica se o Frete Automo deve ser calculo sobre o ICMS ou ICMS-ST
#DEFINE TS_MKPCMP      53    //Indica se o ICMS complementar deve considerar a Margem de Lucro do solidario
#DEFINE TS_CFEXT       54    //Codigo Fiscal de Operacao extendido
#DEFINE TS_BASECOF     55    //Percentual de Reducao do PIS
#DEFINE TS_ISSST       56
#DEFINE TS_MKPSOL      57    //Informa a condição da Margem de Lucro no calculo do ICMS Solidario 
#DEFINE TS_AGRPIS      58    //Informa se agrega o valor do PIS ao total da nota 
#DEFINE TS_AGRCOF      59    //Informa se agrega o valor do COFINS ao total da nota 
#DEFINE TS_AGRRETC     60    //Informa se agrega o valor do ICMS Retido na Coluna Outras/Isenta
#DEFINE TS_PISBRUT     61    //Informa a condição da Margem de Lucro no calculo do ICMS Solidario 
#DEFINE TS_COFBRUT     62    //Informa se agrega o valor do PIS ao total da nota 
#DEFINE TS_COFDSZF     63    //Informa se agrega o valor do COFINS ao total da nota 
#DEFINE TS_PISDSZF     64    //Informa se agrega o valor do ICMS Retido na Coluna Outras/Isenta
#DEFINE TS_LFICMST     65    //Informa como ser?a escrituração do ICMS-ST.
#DEFINE TS_DESPRDIC    66    //Informa se as despesas acessórias devem ser reduzidas juntamente com a base de calculo do ICMS.
#DEFINE TS_CRDEST      67    //Informa se efetua o calculo do Credito Estimulo de Manaus (1 = Nao Calcula, 2 = Produtos Eletronicos, 3 = Contrucao Civil)
#DEFINE TS_CRDPRES     68    //Percentual do Credito Presumido - RJ/PR
#DEFINE TS_AFRMM       69    //Calcula AFRMM: S-Sim,N-Nao
#DEFINE TS_CRDTRAN     70    //Percentual para calculo do Credito Presumido - RJ - Prestacoes de Serv.de Transporte
#DEFINE TS_CTIPI       71
#DEFINE TS_SITTRIB     72
#DEFINE TS_CFPS        73    //Codigo Fiscal de Prestacao de Servicos
#DEFINE TS_CRPRST      74    //valor Credito Presumido Substituicao Tributaria retido pelo contratante do servico de transporte - Decreto 44.147/2005 (MG)
#DEFINE TS_IPIOBS      75    //valor Credito Presumido Substituicao Tributaria retido pelo contratante do servico de transporte - Decreto 44.147/2005 (MG)
#DEFINE TS_IPIPC       76    //Indica se o valor do IPI deve compor a base de calculo do PIS e da COFINS. 1=Sim (Compoe) e 2=Nao(Nao Compoe)
#DEFINE TS_PSCFST		77    //Indica se o PIS/COFINS devera ser calculado como Subst. Tributaria.
#DEFINE TS_CRPRELE     78    //% Crédito Presumido nas operações de Saída com o ICMS destacado sobre os produtos resultantes da industrialização com componentes, partes e pecas recebidos do exterior, destinados a fabricacao de produtos de informatica, eletronicos e telecomunicacoes, por estabelecimento industrial desses setores. Tratamento conforme Art. 1?do DECRETO 4.316 de 19 de Junho de 1995.(BA)
#DEFINE TS_CALCFET     79    //Informa se calcula o imposto FETHAB
#DEFINE TS_CONTSOC     80    //Informa se calcula o imposto FUNRURAL
#DEFINE TS_COMPRED     81    //Indica se o ICMS interestadual devera ser calculado de acordo com a reducao informada na NF ou desprezando a reducao
#DEFINE TS_CSTPIS      82    //CST PIS
#DEFINE TS_CSTCOF      83    //CST COF
#DEFINE TS_RGESPST     84    //Indica se a operacao, mesmo sem calculo de ICMS ST, faz parte do Regime Especial de Substituicao Tributaria
#DEFINE TS_CLFDSUL     85    //Indica se existira o calculo do Fundersul - Mato Grosso do Sul
#DEFINE TS_ESTCRED     86    //Indica o percentual de Estorno de Credito/Debito
#DEFINE TS_LANCFIS     87
#DEFINE TS_CRPRSIM     88    //Indica se sera calculado o Crédito Presumido Simples Nacional - SC
#DEFINE TS_ANTICMS     89    //Indica se a operacao se refere a Antecipacao Tribut. de ICMS (1=Sim/2=Nao)
#DEFINE TS_AGRDRED     90    //Indica se deve agregar o valor da deducao ao total da nota. Em conjunto com TS_AGREG="D" (1=Agrega; 2=Nao agrega, ou seja, abate)
#DEFINE TS_DESCOND     91    //Indica se a operacao tem descondo condicional (1=Sim/2=Nao)
#DEFINE TS_CRPREPR     92    //Percentual do Credito Presumido - PR - RICMS - (Art. 4) - Anexo III.
#DEFINE TS_INTBSIC     93	  //Indica se o PIS, a Cofins ou Ambos integram a Base do ICMS, ou nao, para notas de importacao
#DEFINE TS_ISEFECP     94    //Indica se a operacao tem Isencao do FECP (1=Sim/2=Nao)
#DEFINE TS_FECPANT     95
#DEFINE TS_BCPCST      96
#DEFINE TS_OPERSUC     97    //Indica se a operacao e com sucata
#DEFINE TS_CREDACU     98    //Indicacao do Credito Acumulado de ICMS - Bahia
#DEFINE TS_CRPRERO     99    //Percentual do Credito Presumido - RO - RICMS - (Art. 39) - Anexo IV.
#DEFINE TS_REDANT     100    //Reducao do Valor da Antecipação de ICMS
#DEFINE TS_APLIRED    101    //Reduzir o valor do ICMS proprio para subtracao do ICMS-ST.
#DEFINE TS_APLIIVA    102    //Aplica o valor do IVA-ST quando o valor da pauta for menor que o valor do ITEM.
#DEFINE TS_APLREDP    103    //Aplica Reducao do Valor na Base do ICMS ST, conforme redução da base do ICMS Proprio - Convenio ICMS 06 de 03/04/2009                                                                      
#DEFINE TS_PAUTICM    104    //Se igual a NAO utiliza o ICMS de PAUTA como base de ICMS mesmo quando o preco for MAIOR que a Pauta Informada no INT_ICM conforme convenio ICMS 15/90                                     
#DEFINE TS_ATACVAR    105    //Se SIM Configura o calculo do ICMS-ST do Decreto 29560/2008 para Atacadistas e Varejistas do Estado do Ceara. Para que o calculo seja realizado ?necessario que a Empresa usuaria do Sistema esteja com o CNAE informado como Atacadista CNAE iniciado pelo numero 46xxxxx ou Varejista iniciado pelo numero 47xxxxx  e o produto nao possua margem informada no campo B1_PICMENT.                  
#DEFINE TS_CRPREPE    106    //Percentual do Credito Presumido - Art. 6 Decreto  n28.247
#DEFINE TS_BSRURAL    107    //Se 1 a Base do FUNRURAL sera o Valor do Produto Rural, se 2 = a Base do FUNRURAL sera o valor do produto + as despesas acessorias (FRETE + SEGURO + DESPESAS)
#DEFINE TS_DBSTCSL    108    //Indica se o Valor do ICMS Retido ira compor a base de calculo da CSLL retida - Empresa Publica.
#DEFINE TS_DBSTIRR    109    //Indica se o Valor do ICMS Retido ira compor a base de calculo do IRRF retido - Empresa Publica.
#DEFINE TS_CROUTGO    110    //Percentual de Credito Outorgado concedido pelo Estado de GO para operacoes interestaduais para o Estado de MG.
#DEFINE TS_STCONF     111    //Se SIM Configura o calculo do ICMS-ST do Decreto 28443/2006 para Confecçoes do estado do Ceara. Para que o calculo ocorra ?necessario que o produto nao possua margem informada no campo B1_PICMRET.                  
#DEFINE TS_CSTISS     112
#DEFINE TS_CPRESPR    113    // Credito Presumido - RICMS (Art.4) - Anexo III   
#DEFINE TS_BSRDICM    114    // Se 1 base de cáclulo da red.ICMS=valor da mercadoria + despesas acessórias, se 2 somente valor da mercadoria   
#DEFINE TS_CALCFAB    115    //Informa se calcula o imposto FABOV - Mato Grosso
#DEFINE TS_CALCFAC    116    //Informa se calcula o imposto FACS - Mato Grosso
#DEFINE TS_CRPRESP    117    //Credito Presumido - Decreto 52.586 de 28.12.2007
#DEFINE TS_MOTICMS    118    //Credito Presumido - Decreto 52.586 de 28.12.2007
#DEFINE TS_ALSENAR    119    //Aliquota para calcular o Senar
#DEFINE TS_DESPPIS    120    //Define se as Despesas entram na base de Calculo de PIS
#DEFINE TS_DESPCOF    121    //Define se as Despesas entram na base de Calculo de COFINS
#DEFINE TS_DUPLIST    122    //Gera Titulo so com o valor do ICMS-ST com GERA DUPLI = NAO 
#DEFINE TS_CROUTSP    123    //Percentual do Credito Outorgado de SP - Decreto 56.018/2010  
#DEFINE TS_ICMSTMT    124    //Deduzir o valor do ICMS proprio no valor ICMS ST 1-Sim, 2-Não    
#DEFINE TS_PR35701    125    //Percentual de redução conforme decreto 35.701 - PE  
#DEFINE TS_CPPRODE    126    //Percentual de Cred Pres do PRODEPE  
#DEFINE TS_TPPRODE    127    //Tipo de Cred Pres entre os descritos no Inciso III do PRODEPE (Portaria 236 PE)
#DEFINE TS_VDASOFT    128    //Se a operacao for venda de software permite que o IPI seja dobrado na base do ICMS quando a base do ICMS for dobrada pelo F4_BASEICM = 200%
#DEFINE TS_CODBCC     129    //Codigo da base de calculo do credito
#DEFINE TS_INDNTFR    130    //Indicador da natureza do frete
#DEFINE TS_VENPRES    131    //Indica se a Venda ?Presencial ou não.
#DEFINE TS_REDBCCE    132    //Percentual de Redução para vendas destinadas ao Cear?
#DEFINE TS_ISEFERN    133    //Indica se operacao e isento do FECOP-RN
#DEFINE TS_VARATAC    134    //Indica se operacao e Atacadista ou Varejista
#DEFINE TS_NORESPE    135    //Indica se operacao est?sendo realizada sob uma norma específica
#DEFINE TS_SOMAIPI    136    //Indica se o valor do IPI ir?compor ou não a base de cálculo do ICMS-ST
#DEFINE TS_APSCFST    137    //Indica se o PIS/COFINS como Subst. Tributaria devera ser Agregado ao Valor Total do Item.
#DEFINE TS_CPRCATR    138    //Indica se deve calcular o cred presumido pelo percentual da carga tributária
#DEFINE TS_CREDPRE    139    //Percentual do Credito Presumido
#DEFINE TS_CONSIND    140    //Indica se Consignacao Industrial.
#DEFINE TS_RANTSPD    141    //Recolhimento Antecipado - Para atender necessidades do SPEDFISCAL de MG
#DEFINE TS_ISEFEMG    142    //Indica se operacao e isento do FECP-MG
#DEFINE TS_ALQCMAJ    143    //Aliquota da COFINS de Importacao Majorada.
#DEFINE TS_ISEFEMT    144    //Indica se operacao e isento do FECP-Mt
#DEFINE TS_IPIANTE    145    //Indica se IPI ir?compor a base de ICMS Complementar        
#DEFINE TS_AGREGCP    146    //Agrega Credito Presumido
#DEFINE TS_NATOPER    147    //Codigo da Natureza da Operacao/Prestacao      
#DEFINE TS_TPCPRES    148    //Indica o tipo de Crédito Presumido
#DEFINE TS_IDHIST     149    //ID Historico
#DEFINE TS_DEVPARC    150    //Devolução Parcial Proporcional (S-Sim; N-Não)     
#DEFINE TS_PERCATM    151    //Informe o Percentual de Carga Media MT
#DEFINE TS_DICMFUN    152    //Indica se o ICMS deduzido ser?retirado da base de cálculdo do FUNRURAL  
#DEFINE TS_ALQPMAJ    153    //Aliquota da COFINS de Importacao Majorada.
#DEFINE TS_IMPIND     154    //Importação Indireta/Conta e Ordem
#DEFINE TS_OPERGAR    155    //Indica operacao de garantia
#DEFINE TS_FRETISS    156    //Forma de Retencao do ISS. 1 - Considera Valor Minimo; 2 - Sempre Retem
#DEFINE TS_F4_STLIQ   157    //Indica se ir?realizar o cálculo de ICMS ST com carga líquida.
#DEFINE TS_CV139      158    //Identificação do convênio 139/06.
#DEFINE TS_RFETALG    159    //Indica se o Cliente ir?reter o valor do FETHAB
#DEFINE TS_PARTICM    160    //Indica se ?uma operação com partilha de ICMS. Operações com Concessionaria
#DEFINE TS_BSICMRE    161
#DEFINE TS_ALICRST    162	  // Aliquota Alterativa para  dedução do ICMS do Solidario
#DEFINE TS_TRANFIL    163
#DEFINE TS_IPIVFCF    164
#DEFINE TS_RDBSICM    165    //Aplica a Redução de base quando o valor da pauta for menor que o valor do ITEM
#DEFINE TS_CFAMAD     166
#DEFINE TS_DESCISS    167    //Desconto Incondicional da base ISS antes de aplicar perc. reducao
#DEFINE TS_OUTPERC    168
#DEFINE TS_PISMIN     169
#DEFINE TS_COFMIN	  170	
#DEFINE TS_IPIMIN     171
#DEFINE TS_CUSENTR    172    //Define se irá buscar o Custo da Entrada da Mercadoria para compor a Base de Cálculo
#DEFINE TS_GRPCST     173	 //Enquadramento IPI
#DEFINE TS_IPIPECR	  174    //Define percentual de crédito de IPI em operações sem destaque de IPI.
#DEFINE TS_CALCCPB    175	 //Define se calcula CPRB   	
#DEFINE TS_DIFAL	  176	 //Calcula Difal ec 87/2015
#DEFINE TS_BASCMP	  177	 // Reducao da Base de ICMS complementar	
#DEFINE TS_DUPLIPI    178    //Gera Titulo somente com o valor do IPI para nota de remessa, quando estiver com o campo GERA DUPLICATAS = NAO
#DEFINE TS_TXAPIPI	  179	 //Txt Apur.IPI
#DEFINE TS_FTRICMS	  180	 //Fator de Redução Desc.ICMS
#DEFINE TS_AGRISS     181   //Informa se agrega o valor do ISS ao total da nota 
#DEFINE TS_CFUNDES   182    //Informa se calcula o FUNDESA
#DEFINE TS_CIMAMT    183    //Informa se calcula o IMA-MT
#DEFINE TS_CFASE		184    //Informa se calcula o FASE-MT
#DEFINE TS_INDVF     185    //Informa se utiliza o indice da tabela F0R simples remessa de venda futura
#DEFINE TS_AGRPEDG   186    //Informa se o valor do pedágio será agregado a base do ICMS ou somente no valor total da NF
#DEFINE TS_CSOSN		187		 //CSOSN      	
#DEFINE TS_ALIQPRO   188		//Aliquota PROTEGE-GO
#DEFINE TS_ALQFEEF	189		//Aliquota FEEF-RJ
#DEFINE TS_DEDDIF   190   // Indica se, quando utilizado F4_AGREG = D, o valor do DIFAL também deve ser deduzido do total do documento.
#DEFINE TS_FCALCPR  191   // Forma de cálculo do crédito presumido conforme legislação selecionada.
#DEFINE MAX_TS      191    //Tamanho do array de TES  

#DEFINE SFC_SEQ        01    //Sequencia de calculo do Imposto
#DEFINE SFC_IMPOSTO    02    //Codigo do imposto
#DEFINE SFC_INCDUPL    03    //Indica se incide nas Duplicatas
#DEFINE SFC_INCNOTA    04    //Indica se incide no total da NF
#DEFINE SFC_CREDITA    05    //Indica de Credita o Imposto
#DEFINE SFC_INCIMP     06    //Indica se incide na Base de Calculo de Outro imposto
#DEFINE SFC_BASE       07    //%Reducao da base de calculo
#DEFINE SFB_DESCR      08    //Descricao do Imposto
#DEFINE SFB_CPOVREI    09    //Campo do Valor de Entrada Item
#DEFINE SFB_CPOBAEI    10    //Campo da Base de Entrada do Item
#DEFINE SFB_CPOVREC    11    //Campo do Valor de Entrada Cabecalho
#DEFINE SFB_CPOBAEC    12    //Campo da Base de Entrada Cabecalho
#DEFINE SFB_CPOVRSI    13    //Campo do Valor de Saida Item
#DEFINE SFB_CPOBASI    14    //Campo da Base de Saida Item
#DEFINE SFB_CPOVRSC    15    //Campo do Valor de Saida Cabecalho
#DEFINE SFB_CPOBASC    16    //Campo da Base de Saida Cabecalho
#DEFINE SFB_FORMENT    17    //Rotina para calculo do imposto na Entrada
#DEFINE SFB_FORMSAI    18    //Rotina para calculo do imposto na Saida
#DEFINE SFC_CALCULO    19    //Tipo de calculo
#DEFINE SFC_PROVENT    20    //Provincia de entrega
#DEFINE SFB_DESGR      21    //Provincia de entrega

#DEFINE IMP_COD			01    //Codigo do imposto no Array NF_IMPOSTOS
#DEFINE IMP_DESC		02    //Descricao do imposto no Array NF_IMPOSTOS
#DEFINE IMP_BASE		03    //Base de Calculo do Imposto no Array NF_IMPOSTOS
#DEFINE IMP_ALIQ		04    //Aliquota de calculo do imposto
#DEFINE IMP_VAL		    05    //Valor do Imposto no Array NF_IMPOSTOS
#DEFINE IMP_NOME		06    //Nome de referencia aos Impostos do cabecalho

#DEFINE NMAXIV	        36    // Numero maximo de Impostos Variaveis      

#DEFINE SB_COD         01
#DEFINE SB_GRTRIB      02
#DEFINE SB_CODIF       03
#DEFINE SB_RSATIVO     04
#DEFINE SB_POSIPI      05
#DEFINE SB_UM          06
#DEFINE SB_SEGUM       07
#DEFINE SB_AFABOV      08
#DEFINE SB_AFACS       09
#DEFINE SB_AFETHAB     10
#DEFINE SB_TFETHAB     11
#DEFINE SB_PICM        12
#DEFINE SB_FECOP       13
#DEFINE SB_ALFECOP     14
#DEFINE SB_ALIQISS     15
#DEFINE SB_IMPZFRC     16
#DEFINE SB_INT_ICM     17
#DEFINE SB_PR43080     18
#DEFINE SB_PRINCMG     19
#DEFINE SB_ALFECST     20
#DEFINE SB_PICMENT     21
#DEFINE SB_PICMRET     22
#DEFINE SB_IVAAJU      23
#DEFINE SB_RASTRO      24
#DEFINE SB_VLR_ICM     25
#DEFINE SB_VLR_PIS     26
#DEFINE SB_VLR_COF     27
#DEFINE SB_ORIGEM      28
#DEFINE SB_CRDEST      29
#DEFINE SB_CODISS      30
#DEFINE SB_TNATREC     31
#DEFINE SB_CNATREC     32
#DEFINE SB_GRPNATR     33
#DEFINE SB_DTFIMNT     34
#DEFINE SB_IPI         35
#DEFINE SB_VLR_IPI     36
#DEFINE SB_CNAE        37
#DEFINE SB_REGRISS     38
#DEFINE SB_REDINSS     39
#DEFINE SB_INSS        40
#DEFINE SB_IRRF        41
#DEFINE SB_REDIRRF     42
#DEFINE SB_REDPIS      43
#DEFINE SB_PPIS        44
#DEFINE SB_PIS         45
#DEFINE SB_CHASSI      46
#DEFINE SB_RETOPER     47
#DEFINE SB_REDCOF      48
#DEFINE SB_PCOFINS     49
#DEFINE SB_COFINS      50
#DEFINE SB_PCSLL       51
#DEFINE SB_CONTSOC     52
#DEFINE SB_PRFDSUL     53
#DEFINE SB_FECP        54
#DEFINE SB_FECPBA      55
#DEFINE SB_ALFECRN     56
#DEFINE SB_ALFUMAC     57
#DEFINE SB_PRN944I     58
#DEFINE SB_REGESIM     59
#DEFINE SB_VLRISC      60
#DEFINE SB_CRDPRES     61
#DEFINE SB_VMINDET     62
#DEFINE SB_IMPORT      63
#DEFINE SB_TPDP        64
#DEFINE SB_ALQDFB1     65
#DEFINE SB_B1PTST      66
#DEFINE SB_PRDDIAT     67
#DEFINE SB_B1CALTR     68
#DEFINE SB_B1CATRI     69
#DEFINE SB_ICMPFAT     70
#DEFINE SB_IPIPFAT     71
#DEFINE SB_PUPCCST     72
#DEFINE SB_B1CPSST     73
#DEFINE SB_B1CCFST     74
#DEFINE SB_FECPMT      75
#DEFINE SB_ADIFECP     76
#DEFINE SB_ALFECMG     77
#DEFINE SB_CSLL        78
#DEFINE SB_IDHIST      79       
#DEFINE SB_PRDFIS      80    // Produto Fiscal
#DEFINE SB_MEPLES      81
#DEFINE SB_UVLRC       82
#DEFINE SB_MV_PAUTFOB  83    // Campo personalizavel definido atraves do parametro MV_PAUTFOB
#DEFINE SB_AFAMAD      84
#DEFINE SB_CONV		   85
#DEFINE SB_MVAFRP	   86
#DEFINE SB_MVAFRC	   87
#DEFINE SB_GRPCST	   88
#DEFINE SB_CEST		  89
#DEFINE SB_CODATIV	90
#DEFINE SB_CG1_ALIQ	91
#DEFINE SB_AFUNDES     92
#DEFINE SB_AIMAMT      93
#DEFINE SB_AFASEMT     94
#DEFINE SB_VLRCID     95
#DEFINE SB_TRIBMU     96
#DEFINE SB_B1PISST    97
#DEFINE SB_B1COFST    98


#DEFINE NMAXSB         98    // Numero maximo de Campos do Cadastro de Produtos SB1 / SBi / SBZ


// Referencias da Natureza - SED 
#DEFINE NT_CODIGO  		01	// Codigo da natureza 
#DEFINE NT_CALCIRF 		02  // Calcula IRRF   
#DEFINE NT_PERCIRF 		03  // Percentual % IRRF
#DEFINE NT_BASEIRF 		04  // Base IRRF
#DEFINE NT_PERCINS 		05  // Percentual % INSS
#DEFINE NT_BASEINS 		06  // Base INSS
#DEFINE NT_CALCINS 		07 	// Calcula INSS  
#DEFINE NT_CALCISS 		08 	// Calcula ISS
#DEFINE NT_CALCPIS 		09 	// Calcula PIS
#DEFINE NT_PERCPIS 		10 	// Percentual % PIS
#DEFINE NT_CALCCOF 		11 	// Calcula COFINS
#DEFINE NT_PERCCOF 		12  // Percentual % COFINS
#DEFINE NT_CALCCSL 		13 	// Calcula CSLL 
#DEFINE NT_PERCCSL 		14 	// Percentual % CSLL
#DEFINE NT_BASESES 		15 	// Base SEST		
#DEFINE NT_PERCSES 		16 	// Percentual % SEST
#DEFINE NT_DEDINSS 		18 	// Percentual % SEST
#DEFINE NT_IRRFCAR 		22 	// IRRF Carreteiro
#DEFINE NT_BASEIRC 		23 	// Percentual % Carreteiro
#DEFINE NT_CALCFMP 		24 	// Calcula FUMIPEQ
#DEFINE NT_PERQFMP 		25 	// Aliq. FUMIPEQ
#DEFINE NT_CALCINP 		26 	// Calcula INSS Patronal
#DEFINE NT_PERCINP 		27 	// Percentual do INSS Patronal

// Referencia dos parametros
#DEFINE MV_1DUPNAT	     01   // Campo ou dado a ser gravado na natureza do titulo.  
#DEFINE MV_2DUPNAT      02   // Campo ou dado a ser gravado na natureza do titulo. 
#DEFINE MV_ACMIRPF      03   // Def. a cumulatividade dos valores de IR-PF levarão em conta a data de Emissão ou Vencimento 
#DEFINE MV_ACMIRPJ      04   // Def. a cumulatividade dos valores de IR-PJ levarão em conta a data de Emissão ou Vencimento 
#DEFINE MV_ADIFECP      05   // 
#DEFINE MV_AGENTE       06   // Uso exclusivo Agentina                            
#DEFINE MV_ALFECMG      07   // 
#DEFINE MV_ALINSB1      08   // Indique o campo na tabela SB1 que ir?conter a alíquota adicional do INSS     
#DEFINE MV_ALIQFRE      09   // Indica as alíquotas para o cálculo do ICMS incidennte no frete autônomo
#DEFINE MV_ALIQIRF      10   // Aliquota de IRRF para titulos c/retencao na fonte.
#DEFINE MV_ALIQISS      11   // Aliquota do ISS em casos de prestacao de servicos. 
#DEFINE MV_ALQDFB1      12   // Campo tabela SB1 se o produto utilizar?Exceção Fiscal mesmo que o Contr. Simples Nacional            
#DEFINE MV_ALQIPM       13   // 
#DEFINE MV_ALRN944      14   // Aliquota ICMS ST para o estado de Rio Grande do Norte de acordo com o Art. 944-I.        
#DEFINE MV_ARQPROD      15   // Configura se os dados de indicadores de produto serao considerados pela tabela "SB1" ou "SBZ" 
#DEFINE MV_ARQPROP      16   // Se .F.= Considera o parametro MV_ARQPROD, se .T.= Verifica o preenchimento dos campos      
#DEFINE MV_ASRN944 	 	 17   // Aliquota ICMS ST para o estado de Rio Grande do Norte de acordo com o Art. 944-I. 
#DEFINE MV_AUTOISS    	 18   // Preencher automaticamente os dados de cobrança do ISS e DIRF em notas fiscais de entrada.
#DEFINE MV_B1CALTR   	 19   //
#DEFINE MV_B1CPSST    	 20   //
#DEFINE MV_BASERET   	 21   // Define se as Reducoes de Base de Calculo do ICMS normal aplicam-se tambem na Base Calc. ICMS Solidario (retido)  
#DEFINE MV_BICMCMP   	 22   // Informa se a base do icms complementar deve ser reduzida como o ICMS normal     
#DEFINE MV_BX10925   	 23   // Define momento do tratamento da retencäo dos impostos Pis Cofins e Csll  
#DEFINE MV_CALCVEI   	 24   // Tratamento para o calculo da base dos impostos PIS e COFINS para Veiculos Usados.
#DEFINE MV_CODREG    	 25   // Código do regime tributário do emitente da Nf-e 1-Simples Nacional; 2-Simples Nacional- Excesso de sub-limite de receita bruta; 3- Regime Nacional   
#DEFINE MV_COFBRU    	 26   // Não considera o desconto do item na base de cálculo da COFINS
#DEFINE MV_COFPAUT   	 27   // Informe se o valor do COFINS de pauta refere-se ao valor do COFINS ou ao preço máximo ao consumidor 
#DEFINE MV_CONTSOC   	 28   //
#DEFINE MV_CONVCFO    	 29   //
#DEFINE MV_CPCATRI    	 30   //
#DEFINE MV_CRDBCOF   	 31   //
#DEFINE MV_CRDBPIS  	 32   //
#DEFINE MV_CROUTSP    	 33   //
#DEFINE MV_CRPRERJ    	 34   //
#DEFINE MV_CSLLBRU   	 35   //
#DEFINE MV_CTRAUTO   	 36   //
#DEFINE MV_CTRLFOL   	 37   //
#DEFINE MV_DBRDIF     	 38   //
#DEFINE MV_DBSTCFR   	 39
#DEFINE MV_DBSTCOF    	 40
#DEFINE MV_DBSTPIS    	 41
#DEFINE MV_DBSTPSR   	 42 
#DEFINE MV_DECALIQ  	 43
#DEFINE MV_DEDBCOF    	 44
#DEFINE MV_DEDBPIS   	 45
#DEFINE MV_DEISSBS   	 46
#DEFINE MV_DESCISS   	 47
#DEFINE MV_DESCSAI   	 48
#DEFINE MV_DESCZF    	 49
#DEFINE MV_DESPICM    	 50
#DEFINE MV_DESPSD1    	 51
#DEFINE MV_DESZFPC   	 52  	
#DEFINE MV_DEVRET   	 53
#DEFINE MV_DEVTOT      	 54		
#DEFINE MV_DPAGREG      55
#DEFINE MV_DSZFSOL      56
#DEFINE MV_EASY         57
#DEFINE MV_ESTADO       58
#DEFINE MV_ESTICM       59
#DEFINE MV_FECPMT       60
#DEFINE MV_FRETAUT      61
#DEFINE MV_FRETEST      62
#DEFINE MV_FRTBASE      63
#DEFINE MV_GERIMPV   	 64
#DEFINE MV_ICMPAD    	 65
#DEFINE MV_ICMPAUT   	 66
#DEFINE MV_ICMPFAT   	 67
#DEFINE MV_ICPAUTA   	 68
#DEFINE MV_IMPCSS		 69	     		
#DEFINE MV_INDUPF     	 70
#DEFINE MV_INITES    	 71
#DEFINE MV_INSIRF     	 72
#DEFINE MV_INSSDES   	 73
#DEFINE MV_IPIBRUT   	 74
#DEFINE MV_IPINOBS   	 75
#DEFINE MV_IPIPFAT   	 76
#DEFINE MV_IPIZFM    	 77
#DEFINE MV_IRMP232   	 78
#DEFINE MV_IRSEMNT   	 79
#DEFINE MV_ISSPRG    	 80 	
#DEFINE MV_LFAGREG   	 81
#DEFINE MV_LIMINSS   	 82
#DEFINE MV_LJLVFIS   	 83
#DEFINE MV_MINDETR   	 84
#DEFINE MV_MKPICPT    	 85
#DEFINE MV_NORTE     	 86
#DEFINE MV_PCFATPC		 87
#DEFINE MV_PERCATM   	 88
#DEFINE MV_PEREINT   	 89
#DEFINE MV_PERFECP   	 90
#DEFINE MV_PISBRU     	 91
#DEFINE MV_PISPAUT    	 92
#DEFINE MV_PRCDEC    	 93
#DEFINE MV_PRODLEI   	 94
#DEFINE MV_PUPCCST   	 95
#DEFINE MV_RASTRO     	 96
#DEFINE MV_RATDESP    	 97
#DEFINE MV_RCSTIPI   	 98
#DEFINE MV_REBICM     	 99
#DEFINE MV_REGESIM   	100
#DEFINE MV_RNDANG     	101
#DEFINE MV_RNDCF2     	102
#DEFINE MV_RNDCF3    	103
#DEFINE MV_RNDCOF    	104
#DEFINE MV_RNDCSL    	105
#DEFINE MV_RNDDES    	106
#DEFINE MV_RNDFUN     	107
#DEFINE MV_RNDICM     	108
#DEFINE MV_RNDINS     	109
#DEFINE MV_RNDIPI     	110
#DEFINE MV_RNDIRF    	111
#DEFINE MV_RNDISS     	112
#DEFINE MV_RNDPIS     	113
#DEFINE MV_RNDPREC   	114
#DEFINE MV_RNDPS2     	115
#DEFINE MV_RNDPS3     	116
#DEFINE MV_RNDRNE     	117
#DEFINE MV_RNDSOBR   	118
#DEFINE MV_RSATIVO    	119
#DEFINE MV_SIMPLSC    	120
#DEFINE MV_SM0CONT  	121
#DEFINE MV_SOLBRUT   	122
#DEFINE MV_SOMAICM   	123
#DEFINE MV_SOMAIPI     124
#DEFINE MV_STFRETE     125
#DEFINE MV_STPTPER     126
#DEFINE MV_STREDU      127
#DEFINE MV_TESIB       128
#DEFINE MV_TESVEND     129
#DEFINE MV_TIPOB       130
#DEFINE MV_TMSUFPG     131
#DEFINE MV_TMSVDEP     132
#DEFINE MV_TPABISS     133
#DEFINE MV_TPALCOF     134
#DEFINE MV_TPALCSL     135
#DEFINE MV_TPALPIS     136
#DEFINE MV_TPNFISS     137
#DEFINE MV_TPSOLCF     138
#DEFINE MV_TXAFRMM     139
#DEFINE MV_TXCOFIN     140
#DEFINE MV_TXCSLL      141
#DEFINE MV_TXPIS       142
#DEFINE MV_UFERMS      143
#DEFINE MV_UFPST21     144
#DEFINE MV_USACFPS     145
#DEFINE MV_VALDESP     146
#DEFINE MV_VALICM      147
#DEFINE MV_VISDIRF     148
#DEFINE MV_XFCOMP      149
#DEFINE MV_B1CATRI     150
#DEFINE MV_AERN944     151 
#DEFINE MV_B1CCFST		152
#DEFINE MV_DESCDVI		153   // 
#DEFINE MV_ALITPDP		154   //
#DEFINE MV_B1PTST		155   //     
#DEFINE MV_PRDDIAT		156   // DIAT-SC -> Campo criado na SB1 pelo usuario que indica o tratamento do beneficio DIAT-SC
#DEFINE MV_ISSXMUN		157	  //Controle do ISS por Municipio.
#DEFINE MV_APURPIS  	158
#DEFINE MV_APURCOF  	159
#DEFINE MV_UFPAUTA  	160
#DEFINE MV_ALALIME  	161
#DEFINE MV_DIFALIQ  	162   
#DEFINE MV_VRETISS     163
#DEFINE MV_VEICICM  	164	  //Exclusivo para calculo da base de ICMS para veiculos usados
#DEFINE MV_UFIRCE      165
#DEFINE MV_ALTCFIS  	166	  // Altera produto fiscal
#DEFINE MV_DC5602   	167	  // Parâmetro para tratamento da redução da alíquota zero de PIS COFINS conforme decreto 5602
#DEFINE MV_FISAUCF   	168	  // Classificacao Fiscal automatica
#DEFINE MV_DSPREIN   	169
#DEFINE MV_PISCOFP   	170	//Utiliza a segunda unidade para calculo do pis/cof com Pauta
#DEFINE MV_FISXMVA   	171	// Habilita a utilizacao a	utomatica da formula padrao do MVA
#DEFINE MV_C13906   	172
#DEFINE MV_139GNUF   	173	  
#DEFINE MV_RNDSEST   	174	//Habilita arredondamento no calculo de SEST 
#DEFINE MV_RPCBIZF   	175
#DEFINE MV_PBIPITR		176
#DEFINE MV_PAUTFOB		177
#DEFINE MV_VL10925		178
#DEFINE MV_REMVFUT		179
#DEFINE MV_REDIMPO		180	//Indica se o calculo da base de ICMS considerara reducao de base nas notas de importacao (.T. = considera e .F. = Nao Considera)
#DEFINE MV_SNEFCFO		181
#DEFINE MV_RPCBIUF   	182
#DEFINE MV_IPI2UNI		183
#DEFINE MV_AGRPERC		184
#DEFINE MV_MVAFRP		185
#DEFINE MV_MVAFRE		186
#DEFINE MV_MVAFRU		187
#DEFINE MV_MVAFRC		188
#DEFINE MV_CSTORI		189
#DEFINE MV_UFSTZF		190
#DEFINE MV_OPTSIMP		191
#DEFINE MV_ISSZERO		192
#DEFINE MV_CPRBATV		193 //Codigo de atividade utilizado na CPRB para identificar contribuinte desonerado por CNAE 
#DEFINE MV_CPRBNF			194 //Indica que CPRB sera apurada pelos documentos fiscais
#DEFINE MV_PPDIFAL		195
#DEFINE MV_BASDUPL		196
#DEFINE MV_ANTVISS     197
#DEFINE MV_ZRSTNEG     198
#DEFINE MV_BASDENT		199 // Estados que terão notas de entrada com base dupla no difal
#DEFINE MV_LJINTUF		200 // Estados que terão notas de entrada com base dupla no difal
#DEFINE MV_RATAGRE		201
#DEFINE MV_INTTAF	    202 // Integracao Nativa cbanco a banco com SIGATAF 
#DEFINE MV_UFBDST     203 //Estados que usam Base Dupla ST
#DEFINE MV_M116FOR	204
#DEFINE MV_CDIFBEN	205 //Indica se notas tipo B - Beneficiamento e emissao propria deverao ser consideradas como credito na apuracao do DIFAL.
#DEFINE MV_BASDEGO	206 // Estados que terão notas de entrada com base dupla no difal sem subtrair ICMS
#DEFINE MV_ANTICMS	207
#DEFINE MV_EISSXM   208 //Em conjunto com o parâmetro MV_ISSXMUN, define se nas entradas o município a ser considerado ?sempre o do tomador. 1 = Sim e 2 = Não.
#DEFINE MV_DBSTCLR  209 //Indica o tratamento para retirada do valor do icms solidario na base do CSLL.
#DEFINE MV_TXPISST	210
#DEFINE MV_TXCOFST	211
#DEFINE MV_B1PISST	212
#DEFINE MV_B1COFST	213
#DEFINE MV_CFOTES	214
#DEFINE MV_CMPALIQ	215 //calcula ICMS Complementar calculado pela diferenças entre aliquotas.
#DEFINE MV_CRPRESC	216 // parametrização das alíquotas do DIAT-SC
#DEFINE MV_UFBSTGO	217 // Base dupla ICMS ST nas saidas para estado de Goais
#DEFINE MV_UFSTALQ  218 // Utiliza diferença das aliq para calc Base dupla ICMS ST nas saidas para estado de Goais
#DEFINE MV_BASDSER	219 // Diferencial de aliquota na entrada Portaria SEFAZ SE 367/2016; Art. 22 e 23 RICMS/SE
#DEFINE MV_BASDSSE  220 // Diferencial de aliquota na Saída Portaria SEFAZ SE 367/2016; Art. 22 e 23 RICMS/SE
#DEFINE MV_EIC0064  221 // Define que o valor aduaneiro informado em notas de importação esteja sem o Valor do II
#DEFINE MV_BASDANT  222 // Define se aplica cálculo da base do ICMS Do destino em operações de entrada para Contribuinte nas operações de Antecipação
#DEFINE MV_BASDPUF  223 // Define para quais UF será considerado a Base Dupla em notas do tipo CTR/CTE/CTA/CA/CTF
#DEFINE MV_IBGE886  224 //Indica se o arredondamento de ISS respeitará a resoluc. 886/66 do IBGE: Sendo o numero 5 a ser arredondado se o antecessor for impar.


// Referencias dos PONTOS DE ENTRADA     
#DEFINE PE_M520SF3		 01
#DEFINE PE_M520SFT     	 02
#DEFINE PE_MAAFRMM      03
#DEFINE PE_MACALCCOF    04
#DEFINE PE_MACALCCSL    05
#DEFINE PE_MACALCICMS   06
#DEFINE PE_MACALCPIS    07
#DEFINE PE_MaCofDif     08
#DEFINE PE_MACOFVEIC    09
#DEFINE PE_MACSTPICO    10
#DEFINE PE_MAFISBIR     11
#DEFINE PE_MAFISOBS     12
#DEFINE PE_MAFISRASTRO  13
#DEFINE PE_MAFISRUR     14
#DEFINE PE_MAICMVEIC    15
#DEFINE PE_MAPISDIF     16
#DEFINE PE_MAPISVEIC    17
#DEFINE PE_MARATEIO     18
#DEFINE PE_MAVLDIMP     19
#DEFINE PE_MFISIMP      20
#DEFINE PE_MTA920L      21
#DEFINE PE_MXTOTIT      22
#DEFINE PE_PAUTICMS     23                                        	
#DEFINE PE_TM200ISS     24
#DEFINE PE_VISUIMP      25
#DEFINE PE_VLCODRET     26
#DEFINE PE_XFCD2SFT     27
#DEFINE PE_XFISLF       28
#DEFINE PE_MACALIRRF	29
#DEFINE PE_MFISEXCE		30
#DEFINE PE_MAZVSTDF		31
#DEFINE PE_MAEXCEFISC	32
#DEFINE PE_MACSOLICMS	33
      
// Referencias FIELDPOS
#DEFINE FP_A1_CALCIRF    	01
#DEFINE FP_A1_CONTRIB      02
#DEFINE FP_A1_PERCATM      03  
#DEFINE FP_A1_PERFECP      04
#DEFINE FP_A1_REGESIM      05
#DEFINE FP_A1_SIMPLES      06
#DEFINE FP_A1_TPESSOA      07   
#DEFINE FP_A2_CALCIRF      08
#DEFINE FP_A2_INCLTMG      09
#DEFINE FP_A2_IRPROG       10
#DEFINE FP_A2_NUMDEP       11
#DEFINE FP_A2_RECSEST      12
#DEFINE FP_A2_REGESIM      13
#DEFINE FP_A2_SIMPNAC      14 
#DEFINE FP_A2_TPESSOA      15
#DEFINE FP_B1_ALFECOP      16
#DEFINE FP_B1_ALFECST      17
#DEFINE FP_B1_ALFUMAC      18
#DEFINE FP_B1_CHASSI       19
#DEFINE FP_B1_CNATREC      20
#DEFINE FP_B1_CRDPRES      21
#DEFINE FP_B1_DTFIMNT      22
#DEFINE FP_B1_FECOP        23
#DEFINE FP_B1_FECPBA       24
#DEFINE FP_B1_GRPNATR      25
#DEFINE FP_B1_IMPORT       26
#DEFINE FP_B1_PRN944I      27
#DEFINE FP_B1_REGESIM      28
#DEFINE FP_B1_REGRISS      29
#DEFINE FP_B1_TNATREC      30
#DEFINE FP_B1_VMINDET      31
#DEFINE FP_C6_CNATREC      32
#DEFINE FP_C6_DTFIMNT      33
#DEFINE FP_C6_GRPNATR      34
#DEFINE FP_C6_TNATREC      35
#DEFINE FP_CC7_CLANAP      36
#DEFINE FP_CC7_IFCOMP      37
#DEFINE FP_CC7_TPREG       38
#DEFINE FP_CD2_DESCZF      39
#DEFINE FP_CD2_FORMU       40
#DEFINE FP_CDA_IFCOMP      41
#DEFINE FP_CDA_TPLANC      42
#DEFINE FP_CDO_CODREF      43
#DEFINE FP_CE0_NFALIQ      44
#DEFINE FP_CE0_NFALVA      45
#DEFINE FP_CE0_NFBASE      46
#DEFINE FP_CE0_NFVALO      47
#DEFINE FP_D1_ALIQSOL      48
#DEFINE FP_D1_BASEFUN      49
#DEFINE FP_D1_ICMSDIF      50
#DEFINE FP_D1_ITEM         51
#DEFINE FP_D1_MARGEM       52
#DEFINE FP_D1_SLDDEP       53
#DEFINE FP_D2_ALIQSOL      54
#DEFINE FP_D2_BASEFUN      55 
#DEFINE FP_D2_ICMSDIF      56
#DEFINE FP_D2_MARGEM       57
#DEFINE FP_DUY_ALQISS      58
#DEFINE FP_E2_BASEIRF      59
#DEFINE FP_E2_FORNISS      60
#DEFINE FP_E2_LOJAISS      61
#DEFINE FP_E2_PRETCOF      62
#DEFINE FP_E2_PRETCSL      63
#DEFINE FP_E2_PRETIRF      64
#DEFINE FP_E2_PRETPIS      65
#DEFINE FP_E2_SEQBX        66
#DEFINE FP_E2_VENCISS      67
#DEFINE FP_E2_VRETCOF      68
#DEFINE FP_E2_VRETCSL      69
#DEFINE FP_E2_VRETIRF      70
#DEFINE FP_E2_VRETPIS      71
#DEFINE FP_E5_BASEIRF      72
#DEFINE FP_E5_PRETCOF      73
#DEFINE FP_E5_PRETCSL      74
#DEFINE FP_E5_PRETIRF      75
#DEFINE FP_E5_PRETPIS      76
#DEFINE FP_E5_VRETCOF      77
#DEFINE FP_E5_VRETCSL      78
#DEFINE FP_E5_VRETIRF      79
#DEFINE FP_E5_VRETPIS      80
#DEFINE FP_ED_BASESES      81
#DEFINE FP_ED_PERCSES      82
#DEFINE FP_F1_CAE          83
#DEFINE FP_F1_CHVNFE       84
#DEFINE FP_F1_CODNFE       85
#DEFINE FP_F1_CREDNFE      86
#DEFINE FP_F1_DESNTRB      87
#DEFINE FP_F1_EMINFE       88
#DEFINE FP_F1_HORNFE       89
#DEFINE FP_F1_NFELETR      90
#DEFINE FP_F1_NUMRPS       91
#DEFINE FP_F1_TARA         92
#DEFINE FP_F1_TPVENT       93
#DEFINE FP_F1_VCTOCAE      94
#DEFINE FP_F2_CAE          95
#DEFINE FP_F2_CHVNFE       96
#DEFINE FP_F2_CODNFE       97
#DEFINE FP_F2_CREDNFE      98
#DEFINE FP_F2_DESNTRB      99
#DEFINE FP_F2_DTDIGIT     100
#DEFINE FP_F2_EMINFE      101
#DEFINE FP_F2_HORNFE      102
#DEFINE FP_F2_NFAGREG     103
#DEFINE FP_F2_NFELETR     104
#DEFINE FP_F2_RECISS      105
#DEFINE FP_F2_TARA        106
#DEFINE FP_F2_TPVENT      107
#DEFINE FP_F2_VCTOCAE     108
#DEFINE FP_F2_VLR_FRT     109
#DEFINE FP_F3_BSREIN      110
#DEFINE FP_F3_CAE         111
#DEFINE FP_F3_CODNFE      112
#DEFINE FP_F3_CRDEST      113
#DEFINE FP_F3_CREDNFE     114
#DEFINE FP_F3_CREDPRE     115
#DEFINE FP_F3_CRPREPE     116
#DEFINE FP_F3_DESCZFR     117
#DEFINE FP_F3_DS43080     118
#DEFINE FP_F3_ECF         119
#DEFINE FP_F3_EMINFE      120
#DEFINE FP_F3_HORNFE      121
#DEFINE FP_F3_MDCAT79     122
#DEFINE FP_F3_NFAGREG     123
#DEFINE FP_F3_NFELETR     124
#DEFINE FP_F3_NUMRPS      125
#DEFINE FP_F3_SIMPLES     126
#DEFINE FP_F3_TPVENT      127
#DEFINE FP_F3_VCTOCAE     128
#DEFINE FP_F3_VFECPMG     129
#DEFINE FP_F3_VFECPMT     130
#DEFINE FP_F3_VFECPRN     131
#DEFINE FP_F3_VFESTMG     132
#DEFINE FP_F3_VFESTMT     133
#DEFINE FP_F3_VFESTRN     134
#DEFINE FP_F3_VL43080     135
#DEFINE FP_F3_VLINCMG     136
#DEFINE FP_F3_VREINT      137
#DEFINE FP_F4_AFRMM       138
#DEFINE FP_F4_AGRCOF      139
#DEFINE FP_F4_AGRDRED     140
#DEFINE FP_F4_AGREGCP     141
#DEFINE FP_F4_AGRPIS      142
#DEFINE FP_F4_AGRRETC     143
#DEFINE FP_F4_ALSENAR     144
#DEFINE FP_F4_ANTICMS     145
#DEFINE FP_F4_APLIIVA     146
#DEFINE FP_F4_APLIRED     147
#DEFINE FP_F4_APLREDP     148
#DEFINE FP_F4_APSCFST     149
#DEFINE FP_F4_ATACVAR     150
#DEFINE FP_F4_BASECOF     151
#DEFINE FP_F4_BASEISS     152
#DEFINE FP_F4_BASEPIS     153
#DEFINE FP_F4_BCPCST      154
#DEFINE FP_F4_BSICMST     155
#DEFINE FP_F4_BSRDICM     156
#DEFINE FP_F4_BSRURAL     157
#DEFINE FP_F4_CALCFET     158
#DEFINE FP_F4_CFABOV      159
#DEFINE FP_F4_CFACS       160
#DEFINE FP_F4_CFPS        161
#DEFINE FP_F4_CLFDSUL     162
#DEFINE FP_F4_CNATREC     163
#DEFINE FP_F4_CODBCC      164
#DEFINE FP_F4_COFBRUT     165
#DEFINE FP_F4_COFDSZF     166
#DEFINE FP_F4_COMPRED     167
#DEFINE FP_F4_CONSIND     168
#DEFINE FP_F4_CONTSOC     169
#DEFINE FP_F4_CPPRODE     170
#DEFINE FP_F4_CPRECTR     171
#DEFINE FP_F4_CPRESPR     172
#DEFINE FP_F4_CRDEST      173
#DEFINE FP_F4_CRDPRES     174
#DEFINE FP_F4_CRDTRAN     175
#DEFINE FP_F4_CREDACU     176
#DEFINE FP_F4_CREDPRE     177
#DEFINE FP_F4_CREDST      178
#DEFINE FP_F4_CROUTGO     179
#DEFINE FP_F4_CROUTSP     180
#DEFINE FP_F4_CRPRELE     181
#DEFINE FP_F4_CRPREPE     182
#DEFINE FP_F4_CRPREPR     183
#DEFINE FP_F4_CRPRERO     184
#DEFINE FP_F4_CRPRESP     185
#DEFINE FP_F4_CRPRSIM     186
#DEFINE FP_F4_CRPRST      187
#DEFINE FP_F4_CSTCOF      188
#DEFINE FP_F4_CSTISS      189
#DEFINE FP_F4_CSTPIS      190
#DEFINE FP_F4_CTIPI       191
#DEFINE FP_F4_DBSTCSL     192
#DEFINE FP_F4_DBSTIRR     193
#DEFINE FP_F4_DESCOND     194
#DEFINE FP_F4_DESPCOF     195
#DEFINE FP_F4_DESPPIS     196
#DEFINE FP_F4_DSPRDIC     197
#DEFINE FP_F4_DTFIMNT     198
#DEFINE FP_F4_DUPLIST     199
#DEFINE FP_F4_ESTCRED     200
#DEFINE FP_F4_GRPNATR     201
#DEFINE FP_F4_ICMSST      202
#DEFINE FP_F4_ICMSTMT     203
#DEFINE FP_F4_INCSOL      204
#DEFINE FP_F4_INDNTFR     205
#DEFINE FP_F4_INTBSIC     206
#DEFINE FP_F4_IPIANT      207
#DEFINE FP_F4_IPIOBS      208
#DEFINE FP_F4_IPIPC       209
#DEFINE FP_F4_ISEFECP     210
#DEFINE FP_F4_ISEFEMG     211
#DEFINE FP_F4_ISEFEMT     212
#DEFINE FP_F4_ISEFERN     213
#DEFINE FP_F4_ISSST       214
#DEFINE FP_F4_LFICMST     215
#DEFINE FP_F4_LFISS       216
#DEFINE FP_F4_MALQCOF     217
#DEFINE FP_F4_MKPSOL      218
#DEFINE FP_F4_MOTICMS     219
#DEFINE FP_F4_NORESP      220
#DEFINE FP_F4_OBSICM      221
#DEFINE FP_F4_OBSSOL      222
#DEFINE FP_F4_OPERSUC     223
#DEFINE FP_F4_PAUTICM     224
#DEFINE FP_F4_PICMDIF     225
#DEFINE FP_F4_PISBRUT     226
#DEFINE FP_F4_PISCOF      227
#DEFINE FP_F4_PISCRED     228
#DEFINE FP_F4_PISDSZF     229
#DEFINE FP_F4_PR35701     230
#DEFINE FP_F4_PSCFST      231
#DEFINE FP_F4_REDANT      232
#DEFINE FP_F4_REDBCCE     233
#DEFINE FP_F4_RGESPST     234
#DEFINE FP_F4_SITTRIB     235
#DEFINE FP_F4_SOMAIPI     236
#DEFINE FP_F4_STCONF      237
#DEFINE FP_F4_TNATREC     238
#DEFINE FP_F4_TPPRODE     239
#DEFINE FP_F4_TRFICM      240
#DEFINE FP_F4_VARATAC     241
#DEFINE FP_F4_VDASOFT     242
#DEFINE FP_F4_VENPRES     243 
#DEFINE FP_F7_BSICMST     244
#DEFINE FP_F7_CNATREC     245
#DEFINE FP_F7_DTFIMNT     246
#DEFINE FP_F7_GRUPONC     247
#DEFINE FP_F7_PRCUNIC     248
#DEFINE FP_F7_TNATREC     249
#DEFINE FP_F7_UFBUSCA     250
#DEFINE FP_FB_DESGR       251
#DEFINE FP_FC_PROV        252
#DEFINE FP_FP_QTDITEM     253
#DEFINE FP_FP_TIPOFOR     254
#DEFINE FP_FQ_SEQDES      255 
#DEFINE FP_FT_AGREG       256
#DEFINE FP_FT_ALFECMG     257
#DEFINE FP_FT_ALFECMT     258
#DEFINE FP_FT_ALFECRN     259
#DEFINE FP_FT_ALIQSOL     260
#DEFINE FP_FT_ALIQTST     261
#DEFINE FP_FT_ALQFAB      262
#DEFINE FP_FT_ALQFAC      263
#DEFINE FP_FT_ALQFECP     264
#DEFINE FP_FT_ALQFET      265
#DEFINE FP_FT_ALQFUM      266
#DEFINE FP_FT_ALSENAR     267
#DEFINE FP_FT_ANTICMS     268
#DEFINE FP_FT_BASETST     269
#DEFINE FP_FT_BSEFAB      270
#DEFINE FP_FT_BSEFAC      271
#DEFINE FP_FT_BSEFET      272
#DEFINE FP_FT_BSREIN      273
#DEFINE FP_FT_BSSENAR     274
#DEFINE FP_FT_CHVNFE      275
#DEFINE FP_FT_CODBCC      276
#DEFINE FP_FT_CODIF       277
#DEFINE FP_FT_CODNFE      278
#DEFINE FP_FT_COECFST     279
#DEFINE FP_FT_COEPSST     280
#DEFINE FP_FT_CPPRODE     281
#DEFINE FP_FT_CPRESPR     282
#DEFINE FP_FT_CRDPRES     283
#DEFINE FP_FT_CREDNFE     284
#DEFINE FP_FT_CREDPRE     285
#DEFINE FP_FT_CROUTGO     286
#DEFINE FP_FT_CROUTSP     287
#DEFINE FP_FT_CRPREPE     288
#DEFINE FP_FT_CRPREPR     289
#DEFINE FP_FT_CRPRERO     290
#DEFINE FP_FT_CRPRESP     291
#DEFINE FP_FT_CRPRRON     292
#DEFINE FP_FT_CRPRSIM     293
#DEFINE FP_FT_CSTCOF      294
#DEFINE FP_FT_CSTISS      295
#DEFINE FP_FT_CSTPIS      296
#DEFINE FP_FT_DESCICM     297
#DEFINE FP_FT_DESCZFR     298
#DEFINE FP_FT_EMINFE      299
#DEFINE FP_FT_HORNFE      300
#DEFINE FP_FT_INDNTFR     301
#DEFINE FP_FT_MALQCOF     302
#DEFINE FP_FT_MARGEM      303
#DEFINE FP_FT_MVALCOF     304
#DEFINE FP_FT_NFELETR     305
#DEFINE FP_FT_NORESP      306
#DEFINE FP_FT_NUMRPS      307
#DEFINE FP_FT_PAUTCOF     308
#DEFINE FP_FT_PAUTIC      309
#DEFINE FP_FT_PAUTIPI     310
#DEFINE FP_FT_PAUTPIS     311
#DEFINE FP_FT_PAUTST      312
#DEFINE FP_FT_PR43080     313
#DEFINE FP_FT_PRCUNIC     314
#DEFINE FP_FT_PRFDSUL     315
#DEFINE FP_FT_PRINCMG     316
#DEFINE FP_FT_RGESPST     317
#DEFINE FP_FT_TPPRODE     318
#DEFINE FP_FT_UFERMS      319
#DEFINE FP_FT_VALANTI     320
#DEFINE FP_FT_VALFAB      321
#DEFINE FP_FT_VALFAC      322
#DEFINE FP_FT_VALFDS      323
#DEFINE FP_FT_VALFECP     324
#DEFINE FP_FT_VALFET      325
#DEFINE FP_FT_VALFUM      326
#DEFINE FP_FT_VALTST      327
#DEFINE FP_FT_VFECPMG     328
#DEFINE FP_FT_VFECPMT     329
#DEFINE FP_FT_VFECPRN     330
#DEFINE FP_FT_VFECPST     331
#DEFINE FP_FT_VFESTMG     332
#DEFINE FP_FT_VFESTMT     333
#DEFINE FP_FT_VFESTRN     334
#DEFINE FP_FT_VLINCMG     335
#DEFINE FP_FT_VLSENAR     336
#DEFINE FP_FT_VREINT      337
#DEFINE FP_N1_ALIQCOF     338
#DEFINE FP_N1_ALIQPIS     339
#DEFINE FP_N1_CODBCC      340
#DEFINE FP_N1_CSTCOFI     341
#DEFINE FP_N1_CSTPIS      342
#DEFINE FP_US_ALIQIR      343
#DEFINE FP_US_CALCSUF     344
#DEFINE FP_US_CONTRIB     345
#DEFINE FP_US_GRPTRIB     346
#DEFINE FP_US_INSCR       347
#DEFINE FP_US_NATUREZ     348
#DEFINE FP_US_RECCOFI     349
#DEFINE FP_US_RECCSLL     350
#DEFINE FP_US_RECINSS     351
#DEFINE FP_US_RECISS      352
#DEFINE FP_US_RECPIS      353
#DEFINE FP_US_SUFRAMA     354
#DEFINE FP_US_TPESSOA     355  
#DEFINE FP_WN_ITEMNF      356
#DEFINE FP_WN_TES         357    
#DEFINE FP_B1_AFABOV   	   358
#DEFINE FP_A2_RFABOV      359
#DEFINE FP_A1_RFABOV      360
#DEFINE FP_B1_AFACS       361
#DEFINE FP_A2_RFACS       362
#DEFINE FP_A1_RFACS       363
#DEFINE FP_B1_AFETHAB     364
#DEFINE FP_A2_RECFET      365
#DEFINE FP_A1_RECFET      366 
#DEFINE FP_F3_VALTPDP     367     
#DEFINE FP_F3_TIPANUL     368 
#DEFINE FP_F3_NCF		   369	 
#DEFINE FP_A1_TPDP		   370	
#DEFINE FP_B1_TPDP		   371     
#DEFINE FP_FT_B1DIAT	   372
#DEFINE FP_MV_ALQDFB1	   373 // Campo dinamico da SB1 -> Nome do campo esta contido no paramtro MV_ALQDFB1     
#DEFINE FP_MV_B1PTST	   374 // Campo dinamico da SB1 -> Nome do campo esta contido no paramtro MV_B1PTST          
#DEFINE FP_A1_CRDMA		   375 // Campo de Credito Estimulo de Manaus     
#DEFINE FP_A1_CDRDES	   376 // Campo de Regiao do Cliente  
#DEFINE FP_CC2_PERMAT	   377
#DEFINE FP_CC2_PERSER	   378
#DEFINE FP_CC2_MDEDMA	   379
#DEFINE FP_CC2_MDEDSR     380
#DEFINE FP_B1_ALFECRN     381
#DEFINE FP_D2_VALADI      382
#DEFINE FP_F4_NATOPER     383
#DEFINE FP_BI_COD         384        
#DEFINE FP_BI_GRTRIB      385        
#DEFINE FP_BI_CODIF       386        
#DEFINE FP_BI_RSATIVO     387        
#DEFINE FP_BI_POSIPI      388        
#DEFINE FP_BI_UM          389        
#DEFINE FP_BI_SEGUM       390        
#DEFINE FP_BI_AFABOV      391        
#DEFINE FP_BI_AFACS       392        
#DEFINE FP_BI_AFETHAB     393        
#DEFINE FP_BI_TFETHAB     394        
#DEFINE FP_BI_PICM        395        
#DEFINE FP_BI_FECOP       396        
#DEFINE FP_BI_ALFECOP     397        
#DEFINE FP_BI_ALIQISS     398        
#DEFINE FP_BI_IMPZFRC     399        
#DEFINE FP_BI_INT_ICM     400        
#DEFINE FP_BI_PR43080     401        
#DEFINE FP_BI_PRINCMG     402        
#DEFINE FP_BI_ALFECST     403        
#DEFINE FP_BI_PICMENT     404        
#DEFINE FP_BI_PICMRET     405        
#DEFINE FP_BI_IVAAJU      406        
#DEFINE FP_BI_RASTRO      407        
#DEFINE FP_BI_VLR_ICM     408        
#DEFINE FP_BI_VLR_PIS     409        
#DEFINE FP_BI_VLR_COF     410        
#DEFINE FP_BI_ORIGEM      411       
#DEFINE FP_BI_CRDEST      412        
#DEFINE FP_BI_CODISS      413        
#DEFINE FP_BI_TNATREC     414        
#DEFINE FP_BI_CNATREC     415        
#DEFINE FP_BI_GRPNATR     416        
#DEFINE FP_BI_DTFIMNT     417        
#DEFINE FP_BI_IPI         418        
#DEFINE FP_BI_VLR_IPI     419        
#DEFINE FP_BI_CNAE        420        
#DEFINE FP_BI_REGRISS     421        
#DEFINE FP_BI_REDINSS     422        
#DEFINE FP_BI_INSS        423        
#DEFINE FP_BI_IRRF        424        
#DEFINE FP_BI_REDIRRF     425        
#DEFINE FP_BI_REDPIS      426        
#DEFINE FP_BI_PPIS        427        
#DEFINE FP_BI_PIS         428        
#DEFINE FP_BI_CHASSI      429        
#DEFINE FP_BI_RETOPER     430        
#DEFINE FP_BI_REDCOF      431        
#DEFINE FP_BI_PCOFINS     432        
#DEFINE FP_BI_COFINS      433        
#DEFINE FP_BI_PCSLL       434        
#DEFINE FP_BI_CONTSOC     435        
#DEFINE FP_BI_PRFDSUL     436        
#DEFINE FP_BI_FECP        437        
#DEFINE FP_BI_FECPBA      438        
#DEFINE FP_BI_ALFECRN     439        
#DEFINE FP_BI_ALFUMAC     440        
#DEFINE FP_BI_PRN944I     441        
#DEFINE FP_BI_REGESIM     442        
#DEFINE FP_BI_VLRISC      443        
#DEFINE FP_BI_CRDPRES     444        
#DEFINE FP_BI_VMINDET     445        
#DEFINE FP_BI_IMPORT      446        
#DEFINE FP_BI_TPDP        447        
#DEFINE FP_BI_ALQDFB1     448 
#DEFINE FP_BI_B1PTST      449
#DEFINE FP_BI_PRDDIAT     450 
#DEFINE FP_BI_B1CALTR     451 
#DEFINE FP_BI_B1CATRI     452
#DEFINE FP_BI_ICMPFAT     453 
#DEFINE FP_BI_IPIPFAT     454 
#DEFINE FP_BI_PUPCCST     455 
#DEFINE FP_BI_B1CPSST     456 
#DEFINE FP_BI_B1CCFST     457 
#DEFINE FP_BI_FECPMT      458 
#DEFINE FP_BI_ADIFECP     459 
#DEFINE FP_BI_ALFECMG     460   
#DEFINE FP_B1_COD         461
#DEFINE FP_B1_GRTRIB      462
#DEFINE FP_B1_CODIF       463
#DEFINE FP_B1_RSATIVO     464
#DEFINE FP_B1_POSIPI      465
#DEFINE FP_B1_UM          466
#DEFINE FP_B1_SEGUM       467
#DEFINE FP_B1_TFETHAB     468
#DEFINE FP_B1_PICM        469
#DEFINE FP_B1_ALIQISS     470
#DEFINE FP_B1_IMPZFRC     471
#DEFINE FP_B1_INT_ICM     472
#DEFINE FP_B1_PR43080     473
#DEFINE FP_B1_PRINCMG     474
#DEFINE FP_B1_PICMENT     475
#DEFINE FP_B1_PICMRET     476
#DEFINE FP_B1_IVAAJU      477
#DEFINE FP_B1_RASTRO      478
#DEFINE FP_B1_VLR_ICM     479
#DEFINE FP_B1_VLR_PIS     480
#DEFINE FP_B1_VLR_COF     481
#DEFINE FP_B1_ORIGEM      482
#DEFINE FP_B1_CRDEST      483
#DEFINE FP_B1_CODISS      484
#DEFINE FP_B1_IPI         485
#DEFINE FP_B1_VLR_IPI     486
#DEFINE FP_B1_CNAE        487
#DEFINE FP_B1_REDINSS     488
#DEFINE FP_B1_INSS        489
#DEFINE FP_B1_IRRF        490
#DEFINE FP_B1_REDIRRF     491
#DEFINE FP_B1_REDPIS      492
#DEFINE FP_B1_PPIS        493
#DEFINE FP_B1_PIS         494
#DEFINE FP_B1_RETOPER     495
#DEFINE FP_B1_REDCOF      496
#DEFINE FP_B1_PCOFINS     497
#DEFINE FP_B1_COFINS      498
#DEFINE FP_B1_PCSLL       499
#DEFINE FP_B1_CONTSOC     500
#DEFINE FP_B1_PRFDSUL     501
#DEFINE FP_B1_FECP        502
#DEFINE FP_B1_VLRISC      503
#DEFINE FP_B1_ALQDFB1     504
#DEFINE FP_B1_B1PTST      505
#DEFINE FP_B1_PRDDIAT     506
#DEFINE FP_B1_B1CALTR     507
#DEFINE FP_B1_B1CATRI     508
#DEFINE FP_B1_ICMPFAT     509
#DEFINE FP_B1_IPIPFAT     510
#DEFINE FP_B1_PUPCCST     511
#DEFINE FP_B1_B1CPSST     512
#DEFINE FP_B1_B1CCFST     513
#DEFINE FP_B1_FECPMT      514
#DEFINE FP_B1_ADIFECP     515
#DEFINE FP_B1_ALFECMG     516
#DEFINE FP_BZ_PICM        517
#DEFINE FP_BZ_VLR_ICM     518
#DEFINE FP_BZ_INT_ICM     519
#DEFINE FP_BZ_PICMRET     520
#DEFINE FP_BZ_PICMENT     521
#DEFINE FP_BZ_IPI         522
#DEFINE FP_BZ_VLR_IPI     523
#DEFINE FP_BZ_REDPIS      524
#DEFINE FP_BZ_REDCOF      525
#DEFINE FP_BZ_IRRF        526
#DEFINE FP_BZ_ORIGEM      527
#DEFINE FP_BZ_GRTRIB      528
#DEFINE FP_BZ_CODISS      529
#DEFINE FP_BZ_FECP        530
#DEFINE FP_BZ_ALIQISS     531
#DEFINE FP_BZ_PIS         532
#DEFINE FP_BZ_COFINS      533
#DEFINE FP_BZ_PCSLL       534
#DEFINE FP_BZ_ALFUMAC     535
#DEFINE FP_BZ_FECPBA      536
#DEFINE FP_BZ_ALFECRN     537
#DEFINE FP_BZ_CNAE        538
#DEFINE FP_BI_CSLL        539
#DEFINE FP_B1_CSLL        540
#DEFINE FP_BZ_CSLL        541
#DEFINE FP_F4_TPCPRES     542
#DEFINE FP_FT_IDSF4       543
#DEFINE FP_FT_IDSF7       544
#DEFINE FP_FT_IDSA1       545
#DEFINE FP_FT_IDSA2       546
#DEFINE FP_FT_IDSB1       547
#DEFINE FP_FT_IDSB5       548
#DEFINE FP_FT_IDSBZ       549
#DEFINE FP_FT_IDSED       550
#DEFINE FP_FT_IDSFB       551
#DEFINE FP_F4_IDHIST      552
#DEFINE FP_F7_IDHIST      553
#DEFINE FP_A1_IDHIST      554
#DEFINE FP_A2_IDHIST      555
#DEFINE FP_B1_IDHIST      556
#DEFINE FP_B5_IDHIST      557
#DEFINE FP_BZ_IDHIST      558
#DEFINE FP_ED_IDHIST      559
#DEFINE FP_FB_IDHIST      560
#DEFINE FP_FC_IDHIST      561
#DEFINE FP_F1_IDSA1       562
#DEFINE FP_F1_IDSA2       563
#DEFINE FP_F1_IDSED       564
#DEFINE FP_F2_IDSA1       565
#DEFINE FP_F2_IDSA2       566
#DEFINE FP_F2_IDSED       567
#DEFINE FP_D1_IDSF4       568
#DEFINE FP_D1_IDSF7       569
#DEFINE FP_D1_IDSB1       570
#DEFINE FP_D1_IDSBZ       571
#DEFINE FP_D1_IDSB5       572
#DEFINE FP_D2_IDSF4       573
#DEFINE FP_D2_IDSF7       574
#DEFINE FP_D2_IDSB1       575
#DEFINE FP_D2_IDSBZ       576
#DEFINE FP_D2_IDSB5       577
#DEFINE FP_FT_DS43080     578    
#DEFINE FP_FT_DESCTOT     579
#DEFINE FP_FT_ACRESCI     580
#DEFINE FP_F4_DEVPARC     581
#DEFINE FP_B5_ALIMEN      582
#DEFINE FP_F4_ALIMEN      583          
#DEFINE FP_F4_PERCATM     584 
#DEFINE FP_F4_DICMFUN	  585	
#DEFINE FP_F4_MALQPIS     586
#DEFINE FP_D1_VALPMAJ     587
#DEFINE FP_FT_MALQPIS     588
#DEFINE FP_FT_MVALPIS     589    
#DEFINE FP_F4_IMPIND      590
#DEFINE FP_F4_OPERGAR	  591
#DEFINE FP_F4_FRETISS	  592
#DEFINE FP_BI_MEPLES      593
#DEFINE FP_B1_MEPLES      594
#DEFINE FP_S4_CHASSI	  595
#DEFINE FP_S4_VLRISC	  596
#DEFINE FP_S4_VMINDET	  597
#DEFINE FP_S4_CODIF		  598
#DEFINE FP_CFC_MGLQST  	  599
#DEFINE FP_CFC_ALQSTL  	  600
#DEFINE FP_F4_STLIQ  	  601
#DEFINE FP_S9_MGLQST  	  602
#DEFINE FP_S9_ALQSTL  	  603   
#DEFINE FP_ED_CALCCID	  604
#DEFINE FP_ED_PERCCID	  605
#DEFINE FP_ED_BASECID	  606
#DEFINE FP_A2_RECCIDE	  607
#DEFINE FP_F7_SITTRIB	  608
#DEFINE FP_F7_ORIGEM	  609
#DEFINE FP_S1_SITTRIB	  610
#DEFINE FP_S1_ORIGEM	  611
#DEFINE FP_CFC_MARGEM	  612
#DEFINE FP_S9_MARGEM	  613
#DEFINE FP_A1_FRETISS	  614
#DEFINE FP_F4_CV139	      615
#DEFINE FP_FT_CV139  	  616
#DEFINE FP_F4_RFETALG 	  617
#DEFINE FP_CFC_ALFCPO	  618
#DEFINE FP_S9_ALFCPO	  619
#DEFINE FP_CFC_FCPAUX	  620
#DEFINE FP_S9_FCPAUX	  621
#DEFINE FP_CFC_FCPXDA	  622
#DEFINE FP_S9_FCPXDA	  623
#DEFINE FP_CFC_FCPINT	  624
#DEFINE FP_S9_FCPINT	  625
#DEFINE FP_D1_BASNDES	  626
#DEFINE FP_D1_ICMNDES	  627
#DEFINE FP_CFC_CODPRD	  628
#DEFINE FP_D2_IDCFC		  629
#DEFINE FP_D1_IDCFC		  630     
#DEFINE FP_F4_PARTICM	  631   
#DEFINE FP_CD2_PARTIC	  632
#DEFINE FP_CC7_CODREF	  633
#DEFINE FP_CFC_RDCTIM	  634
#DEFINE FP_F4_BSICMRE	  635
#DEFINE FP_B1_UPRC		  636
#DEFINE FP_F4_ALICRST	  637
#DEFINE FP_F4_TRANFIL	  638
#DEFINE FP_CC2_BASISS	  639
#DEFINE FP_ED_IRRFCAR	  640
#DEFINE FP_ED_BASEIRC	  641
#DEFINE FP_F7_MSBLQD	  642
#DEFINE FP_MV_PAUTFOB	  643
#DEFINE FP_CC2_CPOM		  644
#DEFINE FP_IPIVFCF		  645
#DEFINE FP_BASECPM		  646
#DEFINE FP_ALQCPM		  647
#DEFINE FP_VALCPM		  648	
#DEFINE FP_F4_RDBSICM	  649
#DEFINE FP_BASEFMP		  650 
#DEFINE FP_VALFMP		  651
#DEFINE FP_ALQFMP		  652
#DEFINE FP_CALCFMP		  653
#DEFINE FP_PERQFMP		  654
#DEFINE FP_VALFMD		  655 //FIELDPOS DO CAMPO F3_VALFMD
#DEFINE FP_AFAMAD		  656	
#DEFINE FP_A2_RECFMD	  657
#DEFINE FP_A1_RECFMD	  658
#DEFINE FP_CFAMAD	      659
#DEFINE FP_FT_BSEFMD	  660
#DEFINE FP_FT_ALQFMD	  661
#DEFINE FP_FT_VALFMD	  662
#DEFINE FP_F4_DESCISS	  663
#DEFINE FP_CE0_VL197	  664
#DEFINE FP_CDA_VL197	  665
#DEFINE FP_CC2_TPDIA	  666
#DEFINE FP_F4_OUTPERC  	  667
#DEFINE FP_F4_PISMIN      668
#DEFINE FP_F4_COFMIN      669
#DEFINE FP_F4_IPIMIN      670
#DEFINE FP_B1_CONV	      671
#DEFINE FP_BZ_PPIS        672
#DEFINE FP_BZ_PCOFINS     673	
#DEFINE FP_F4_CUSENTR     674	
#DEFINE FP_A1_INCLTMG     675	
#DEFINE FP_BI_ALFECMG	  676
#DEFINE FP_MV_MVAFBI	  677
#DEFINE FP_MV_MVAFRP	  678
#DEFINE FP_MV_MVAFRE	  679
#DEFINE FP_MV_MVAFRU      680
#DEFINE FP_MV_MVAFS1	  681
#DEFINE FP_MV_MVAFRU	  682
#DEFINE FP_MV_MVAFRC	  683
#DEFINE FP_MV_MVAFBC	  684
#DEFINE FP_CFC_MVAES	  685
#DEFINE FP_S9_MVAES	  	  686
#DEFINE FP_FT_SERSAT	  687
#DEFINE FP_F3_SERSAT	  688
#DEFINE FP_CC7_CLANC	  689
#DEFINE FP_CDA_CLANC	  690
#DEFINE FP_FT_BASNDES	  691
#DEFINE FP_FT_ICMNDES	  692
#DEFINE FP_F3_BASNDES	  693
#DEFINE FP_F3_ICMNDES	  694
#DEFINE FP_B1_GRPCST	  695
#DEFINE FP_F4_GRPCST	  696
#DEFINE FP_FT_GRPCST	  697
#DEFINE FP_CD2_GRPCST	  698
#DEFINE FP_F4_IPIPECR     699
#DEFINE FP_F4_TXAPIPI     700
#DEFINE FP_B1_CEST		  701
#DEFINE FP_FT_CEST		  702
#DEFINE FP_CD2_CEST		  703
#DEFINE FP_F4_CALCCPB  704
#DEFINE FP_D1_BASECPB  705
#DEFINE FP_D1_VALCPB   706
#DEFINE FP_D1_ALIQCPB  707
#DEFINE FP_D2_BASECPB  708
#DEFINE FP_D2_VALCPB   709
#DEFINE FP_D2_ALIQCPB  710
#DEFINE FP_F3_BASECPB  711
#DEFINE FP_F3_VALCPB   712
#DEFINE FP_F3_ALIQCPB  713
#DEFINE FP_FT_BASECPB  714
#DEFINE FP_FT_VALCPB   715
#DEFINE FP_FT_ALIQCPB  716
#DEFINE FP_B5_CODATIV  717
#DEFINE FP_FT_ATIVCPB  718
#DEFINE FP_CG1_ALIQ    719
#DEFINE FP_CD2_PICMDF  	720
#DEFINE FP_F3_SERSAT  	721
#DEFINE FP_FT_SERSAT  	722
#DEFINE FP_FT_DIFAL		723
#DEFINE FP_F3_DIFAL		724
#DEFINE FP_F4_DIFAL		725
#DEFINE FP_CD2_PDDES	726
#DEFINE FP_CD2_PDORI	727
#DEFINE FP_CD2_VDDES 	728
#DEFINE FP_CD2_ADIF		729
#DEFINE FP_CD2_PFCP		730
#DEFINE FP_CD2_VFCP		731
#DEFINE FP_FT_PDORI		732
#DEFINE FP_FT_PDDES		733
#DEFINE FP_FT_VFCPDIF	734
#DEFINE FP_F3_VFCPDIF	735
#DEFINE FP_FT_BASEDES	736
#DEFINE FP_F3_BASEDES	737
#DEFINE FP_BI_CEST  	738
#DEFINE FP_CD2_DESONE	739
#DEFINE FP_F4_BASCMP	740
#DEFINE FP_CD2_PDEVOL	741
#DEFINE FP_A2_CONTRIB	742
#DEFINE FP_F4_DUPLIPI	743
#DEFINE FP_D1_ALIQCMP	744
#DEFINE FP_D2_ALIQCMP	745
#DEFINE FP_F4_TXAPIPI	746
#DEFINE FP_A1_SIMPNAC   747
#DEFINE FP_F4_FTRICMS   748
#DEFINE FP_D2_FTRICMS   749
#DEFINE FP_FT_FTRICMS   750
#DEFINE FP_D2_VRDICMS   751
#DEFINE FP_FT_VRDICMS   752
#DEFINE FP_D1_FTRICMS   753
#DEFINE FP_D1_VRDICMS   754
#DEFINE FP_F3_BSICMOR	755
#DEFINE FP_FT_BSICMOR	756
#DEFINE FP_F4_AGRISS		757
#DEFINE FP_F4_CFUNDES 	758
#DEFINE FP_F4_CIMAMT 	759 
#DEFINE FP_F4_CFASE	 	760 
#DEFINE FP_B1_AFUNDES	761
#DEFINE FP_B1_AIMAMT		762 
#DEFINE FP_B1_AFASEMT	763 
#DEFINE FP_A1_RFUNDES 	764 
#DEFINE FP_A1_RIMAMT 	765 
#DEFINE FP_A1_RFASEMT 	766 
#DEFINE FP_A2_RFUNDES 	767 
#DEFINE FP_A2_RIMAMT 	768 
#DEFINE FP_A2_RFASEMT 	769 
#DEFINE FP_F1_VALFUND 	770 
#DEFINE FP_F1_VALIMA 	771 
#DEFINE FP_F1_VALFASE 	772 
#DEFINE FP_F2_VALFUND 	773 
#DEFINE FP_F2_VALIMA 	774 
#DEFINE FP_F2_VALFASE 	775 
#DEFINE FP_D1_VALFUND 	776 
#DEFINE FP_D1_BASFUND 	777 
#DEFINE FP_D1_ALIFUND 	778 
#DEFINE FP_D1_VALIMA 	779 
#DEFINE FP_D1_BASIMA 	780 
#DEFINE FP_D1_ALIIMA 	781 
#DEFINE FP_D1_VALFASE 	782 
#DEFINE FP_D1_BASFASE 	783 
#DEFINE FP_D1_ALIFASE 	784 
#DEFINE FP_D2_VALFUND 	785 
#DEFINE FP_D2_BASFUND 	786 
#DEFINE FP_D2_ALIFUND 	787 
#DEFINE FP_D2_VALIMA 	788 
#DEFINE FP_D2_BASIMA 	789 
#DEFINE FP_D2_ALIIMA 	790 
#DEFINE FP_D2_VALFASE 	791 
#DEFINE FP_D2_BASFASE 	792 
#DEFINE FP_D2_ALIFASE 	793 
#DEFINE FP_FT_VALFUND 	794 
#DEFINE FP_FT_BASFUND 	795 
#DEFINE FP_FT_ALIFUND 	796 
#DEFINE FP_FT_VALIMA 	797 
#DEFINE FP_FT_BASIMA 	798 
#DEFINE FP_FT_ALIIMA 	799 
#DEFINE FP_FT_VALFASE 	800 
#DEFINE FP_FT_BASFASE 	801 
#DEFINE FP_FT_ALIFASE 	802 
#DEFINE FP_F3_VALFUND 	803 
#DEFINE FP_F3_VALIMA 	804 
#DEFINE FP_F3_VALFASE 	805
#DEFINE FP_FT_PRCMEDP 	806
#DEFINE FP_F3_PRCMEDP 	807
#DEFINE FP_F0RIND        808 
#DEFINE FP_F4_INDVF      809
#DEFINE FP_FTIND         810
#DEFINE FP_CFC_ADICST    811
#DEFINE FP_SS9_ADICST    812
#DEFINE FP_FT_TAFKEY   813
#DEFINE FP_F4_AGRPEDG	814
#DEFINE FP_FT_VALPEDG	815
#DEFINE FP_F3_VALPEDG	816
#DEFINE FP_CFC_PICM    817
#DEFINE FP_S9_PICM    818
#DEFINE FP_B5_VLRCID  819
#DEFINE FP_S5_VLRCID  820
#DEFINE FP_F4_CSOSN   821  
#DEFINE FP_FT_CSOSN   822
#DEFINE FP_A2_CALCINP 823
#DEFINE FP_ED_CALCINP 824
#DEFINE FP_ED_PERCINP 825
#DEFINE FP_D1_BASEINP 826
#DEFINE FP_FT_BASEINP 827
#DEFINE FP_F3_BASEINP 828
#DEFINE FP_D1_PERCINP 829
#DEFINE FP_FT_PERCINP 830
#DEFINE FP_F3_PERCINP 831
#DEFINE FP_D1_VALINP 832
#DEFINE FP_FT_VALINP 833
#DEFINE FP_F3_VALINP 834
#DEFINE FP_FT_CNAE   835
#DEFINE FP_FT_TRIBMUN 836
#DEFINE FP_FT_CLIDEST 837
#DEFINE FP_FT_LOJDEST 838
#DEFINE FP_CE1_TRIBMU 839
#DEFINE FP_CE1_CNAE   840
#DEFINE FP_CE1_RMUISE 841
#DEFINE FP_BI_TRIBMUN 842
#DEFINE FP_B1_TRIBMUN 843
#DEFINE FP_S4_TRIBMUN 844
#DEFINE FP_F3_CNAE   845
#DEFINE FP_F3_TRIBMUN 846
#DEFINE FP_F1_ADIANT  847
#DEFINE FP_B1_B1PISST 848
#DEFINE FP_B1_B1COFST 849
#DEFINE FP_CFC_VLICMP 850
#DEFINE FP_CFC_VL_ICM 851
#DEFINE FP_S9_VLICMP 852
#DEFINE FP_S9_VL_ICM 853
#DEFINE FP_CDA_CODREF 854
#DEFINE FP_FT_VOPDIF 855
#DEFINE FP_D1_BASEPRO 856
#DEFINE FP_D2_BASEPRO 857
#DEFINE FP_FT_BASEPRO 858
#DEFINE FP_D1_ALIQPRO 859
#DEFINE FP_D2_ALIQPRO 860
#DEFINE FP_FT_ALIQPRO 861
#DEFINE FP_D1_VALPRO 862
#DEFINE FP_D2_VALPRO 863
#DEFINE FP_FT_VALPRO 864
#DEFINE FP_F4_ALIQPRO 865
#DEFINE FP_FT_ICMSDIF 866 
#DEFINE FP_SM2_IND    867
#DEFINE FP_D1_BASFEEF 868
#DEFINE FP_D2_BASFEEF 869
#DEFINE FP_FT_BASFEEF 870
#DEFINE FP_D1_ALQFEEF 871
#DEFINE FP_D2_ALQFEEF 872
#DEFINE FP_FT_ALQFEEF 873
#DEFINE FP_D1_VALFEEF 874
#DEFINE FP_D2_VALFEEF 875
#DEFINE FP_FT_VALFEEF 876
#DEFINE FP_F4_ALQFEEF 877
#DEFINE FP_FT_NFISCAN 878
#DEFINE FP_F3_NFISCAN 879
#DEFINE FP_A2_DEDBSPC 880
#DEFINE FP_F4_DEDDIF  881
#DEFINE FP_F4_FCALCPR 882
#DEFINE FP_CFC_VL_ANT 883

// Referencias dos ALIASINDIC
#DEFINE AI_CC6		01
#DEFINE AI_CC7     02
#DEFINE AI_CD2     03
#DEFINE AI_CD3     04
#DEFINE AI_CD4     05
#DEFINE AI_CD5     06
#DEFINE AI_CD6     07
#DEFINE AI_CD7     08
#DEFINE AI_CD8     09
#DEFINE AI_CD9     10
#DEFINE AI_CDA     11
#DEFINE AI_CDC     12
#DEFINE AI_CDD     13
#DEFINE AI_CDE     14
#DEFINE AI_CDF     15
#DEFINE AI_CDG     16
#DEFINE AI_CDO     17
#DEFINE AI_CE0     18
#DEFINE AI_MDL     19
#DEFINE AI_SFT     20
#DEFINE AI_SFU     21
#DEFINE AI_SFX     22
#DEFINE AI_CE1     23
#DEFINE AI_CC2     24
#DEFINE AI_CFC     25
#DEFINE AI_SS9     26
#DEFINE AI_CG1     27
#DEFINE AI_F0R     28

// Referencias da amarracao UF x UF
#DEFINE UF_ALIQFECP		01	//Aliquota do Fecp - UF Destino
#DEFINE UF_MARGSTLIQ		02	//Margem Liquida ST
#DEFINE UF_ALIQSTLIQ		03	//Aliquota ST Liquida
#DEFINE UF_MARGEM			04	//Margem de Valor Agregado
#DEFINE UF_ALQFCPO		05	//Aliquota do Fecp - UF Origem
#DEFINE UF_FECPAUX		06	//Indice Auxiliar para calculo do Fecp
#DEFINE UF_FECPDIF		07	//Indica majoracao da aliquota do ICMS Diferencial de Aliquotas
#DEFINE UF_FECPINT		08	//Indica majoracao para operacoes internas (exceto Consumidor Final)
#DEFINE UF_RDCTIMP		09 ////Redução de Carga Tribuária de ICMS-Importação DECRETO 34.560/2010
#DEFINE UF_MVAFRU		    10  //MVA em operação de Frete
#DEFINE UF_MVAES		    11 ////Indica se o MVA deve ser utilizado apenas nas entradas, nas saídas, ou em ambos os casos
#DEFINE UF_ADICST       12 //Alíquita de ST líquida utilizado para entradas de merc. oriundas de fornecedor do simples nacional
#DEFINE UF_PICM      	13 //Alíquita de ICMS
#DEFINE UF_VLICMP      	14 //Valor ICMS Proprio de Pauta
#DEFINE UF_VL_ICM      	15 //Valor ICMS de Pauta
#DEFINE UF_VL_ANT      	16 //Valor de Pauta do ICMS Antecipacao
#DEFINE NMAXUF			16	//Numero maximo da amarracao UF x UF

// Referencias da amarracao UF x UF x Produto
#DEFINE UFP_ALIQFECP		01	//Aliquota do Fecp - UF Destino
#DEFINE UFP_MARGSTLIQ		02	//Margem Liquida ST
#DEFINE UFP_ALIQSTLIQ		03	//Aliquota ST Liquida
#DEFINE UFP_MARGEM		04	//Margem de Valor Agregado
#DEFINE UFP_ALQFCPO		05	//Aliquota do Fecp - UF Origem
#DEFINE UFP_FECPAUX		06	//Indice Auxiliar para calculo do Fecp
#DEFINE UFP_FECPDIF		07	//Indica majoracao da aliquota do ICMS Diferencial de Aliquotas
#DEFINE UFP_FECPINT		08	//Indica majoracao para operacoes internas (exceto Consumidor Final)
#DEFINE UFP_RDCTIMP		09  ////Redução de Carga Tribuária de ICMS-Importação DECRETO 34.560/2010
#DEFINE UFP_MVAFRU		10  // Margem sobre operação com frete
#DEFINE UFP_MVAES		    11 //Indica se o MVA deve ser utilizado apenas nas entradas, nas saídas, ou em ambos os casos
#DEFINE UFP_ADICST      12 //Alíquita de ST líquida utilizado para entradas de merc. oriundas de fornecedor do simples nacional
#DEFINE UFP_PICM		13 //Alíquita de ICMS
#DEFINE UFP_VLICMP		14 //Valor ICMS Proprio de Pauta
#DEFINE UFP_VL_ICM		15 //Valor ICMS de Pauta
#DEFINE UFP_VL_ANT     16 // Valor de pauta do ICMS antecipacao
#DEFINE NMAXUFP			16	//Numero maximo da amarracao UF x UF x Produto
*/
