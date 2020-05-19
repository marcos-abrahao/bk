#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKFINA02
BK - Liquidos - Folha BK - Geração de titulos

Integrado com o aplicativo : http://intranet.bkinformatica.com/WebIntegraRubi/

Tratamento do campo campo Z2_STATUS pelos sistemas:

" "- Gerado ou alterado pelo RH: financeiro pode importar ou RH pode manipular
"X"- Em seleção, na tela do financeiro: RH não pode manipular
"S"- Titulos gerados no financeiro: financeiro pode excluir,RH não pode manipular
"D"- Titulos excluídos no financeiro: RH pode manipular

    Gerar PA (pagamento antecipado) quanto Z2_TIPOPES = PJ,AC ou CLA
        Quando Z2_TIPOPES = PJ, utilizar fornecedor Z2_CODFOR / Z2_LOJFOR
        Quando Z2_TIPOPES = AC, utilizar fornecedor 000071
        Quando Z2_TIPOPES = CLA, utilizar fornecedor 000071
        Quando Z2_TIPOPES = CLT, utilizar fornecedor 000084
 ****       Quando Z2_TIPOPES = AUT, utilizar Autonomo 000084

@Return
@author Marcos Bispo Abrahão
@since 29/09/2009 rev 18/05/20
@version P12

/*/

User Function BKFINA02()

Local oOk
Local oNo
Local oDlg
Local oListId
Local oPanelLeft
Local lAll
Local oAll
Local aButtons := {}

Local aCtrId,aTitGer,xCtrId
Local lOk      := .F.
Local aAreaIni := GetArea()
Local cQuery
Local nI,cPrf,cTitulo,nProxTit
Local nStatusX
Local cNome
Local cTitulo2 := "Seleção de Lotes - Liquidos "+ALLTRIM(SM0->M0_NOME)
Local MV_XXUSRPJ := "000011/000012/000000"

PRIVATE aFurnas  := {} 

aFurnas  := U_StringToArray(ALLTRIM(SuperGetMV("MV_XXFURNAS",.F.,"105000381/105000391")), "/" )

dbSelectArea("SZ2")
dbGoTop()
IF BOF() .OR. EOF()
	MsgStop("Não ha lotes gerados", "Atenção")
	RestArea(aAreaIni)
	Return
ENDIF

// Verificar se há processos de integração em andamento
cQuery  := "SELECT COUNT(*) AS Z2STATUSX " 
cQuery  += "FROM "+RETSQLNAME("SZ2")+" SZ2 WHERE Z2_CODEMP = '"+SM0->M0_CODIGO+"' AND Z2_STATUS = 'X' "
cQuery  += " AND Z2_VALOR > 0 AND SZ2.D_E_L_E_T_ <> '*'"

TCQUERY cQuery NEW ALIAS "QSZ2"
//TCSETFIELD("QSZ2","XX_DATAPGT","D",8,0)

DbSelectArea("QSZ2")
DbGoTop()
nStatusX := QSZ2->Z2STATUSX
//Do While !eof()
//	nStatusX++
//	DbSelectArea("QSZ2")
//	DbSkip()
//EndDO
QSZ2->(DbCloseArea())

IF nStatusX > 0
    MsgStop("Integração já iniciada por outra seção", "Atenção")
	IF __cUserId <> "000000"
	   MsgStop("Verifique se há algum usuario processando a integração, caso contrário comunique o administrador do sistema", "Atenção")
    ELSE
       IF MsgYesNo("Sr. Administrador, deseja resetar o campo Z2_STATUS=X de "+STRZERO(nStatusX,6)+" registros ?")
		  cQuery := " UPDATE "+RetSqlName("SZ2")+" SET Z2_STATUS = ' ' WHERE Z2_CODEMP = '"+SM0->M0_CODIGO+"' AND Z2_STATUS = 'X' AND D_E_L_E_T_ <> '*' AND Z2_VALOR > 0"
    	  TcSqlExec(cQuery)
    	  MsgInfo("Registros resetados: "+STRZERO(nStatusX,6)+", reinicie o programa")
       ENDIF  
    ENDIF
   RestArea(aAreaIni)
   Return
ENDIF

//Verifica se a titulos zerado e devolve automatico para RH
ExcVZero()

//Verifica se a titulos duplicado e devolve automatico para RH
ExcDuplic()

cQuery  := "SELECT Z2_CTRID,MAX(Z2_DATAPGT) AS XX_DATAPGT,SUM(Z2_VALOR) AS XX_TOTAL, MAX(Z2_NOME) AS XX_NOME " 
cQuery  += "FROM "+RETSQLNAME("SZ2")+" SZ2 WHERE Z2_CODEMP = '"+SM0->M0_CODIGO+"' AND Z2_STATUS = ' ' AND SZ2.D_E_L_E_T_ <> '*' AND Z2_VALOR > 0 "
//cQuery  += "AND Z2_TIPO NOT IN ('SOL ','PCT ','RMB ','NDB ') "  // PARA TESTES
// 04/02/20 - Não integrar PJ/AC caso o usuário não seja o Laudecir ou Xavier
IF !(__cUserId $ MV_XXUSRPJ)  // Laudecir, Xavier e Admin
	cQuery  += "AND Z2_TIPOPES NOT IN ('PJ','AC') "
ENDIF
cQuery  += "GROUP BY Z2_FILIAL,Z2_CTRID "
cQuery  += "ORDER BY Z2_FILIAL,Z2_CTRID "

TCQUERY cQuery NEW ALIAS "QSZ2"
TCSETFIELD("QSZ2","XX_DATAPGT","D",8,0)

dbSelectArea("SZ2")
dbSetOrder(1)

DbSelectArea("QSZ2")
DbGoTop()

aCtrId := {}
Do While !eof()
	cNome := IIF(!SUBSTR(QSZ2->Z2_CTRID,1,1) $ "0123456789",QSZ2->XX_NOME,"LF")
	AADD(aCtrId,{.F.,QSZ2->Z2_CTRID,DTOC(QSZ2->XX_DATAPGT),TRANSFORM(QSZ2->XX_TOTAL,"@E 999,999,999.99"),cNome})
	xCtrId := QSZ2->Z2_CTRID
	// Marcar os registros do SZ2 com X, selecionados
	
    cQuery := " UPDATE "+RetSqlName("SZ2")+" SET Z2_STATUS = 'X' WHERE Z2_CTRID = '"+xCtrId+"' AND Z2_CODEMP = '"+SM0->M0_CODIGO+"' AND Z2_STATUS = ' ' AND D_E_L_E_T_ <> '*' AND Z2_VALOR > 0"
    TcSqlExec(cQuery)

	/*
	DbSelectArea("SZ2")
	dbSeek(xFilial("SZ2")+xCtrId,.T.)
	DO WHILE !EOF() .AND. xFilial("SZ2")+xCtrId == SZ2->Z2_FILIAL+SZ2->Z2_CTRID
	   RecLock("SZ2",.F.)
	   //SZ2->Z2_TITULO := cKey
	   IF SZ2->Z2_STATUS == " "
		   SZ2->Z2_STATUS := "X"
	   ENDIF	   
	   MsUnlock()
	   dbSkip()
	ENDDO  
	*/
	
	DbSelectArea("QSZ2")
	DbSkip()
Enddo
QSZ2->(DbCloseArea())


ASORT(aCtrId,,,{|x,y| x[2]<y[2]})

If Empty(aCtrId)
	MsgStop("Não há lotes disponíveis", "Atenção")
	RestArea(aAreaIni)
	Return
EndIf

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE cTitulo2 FROM 000,000 TO 400,630 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 320,225
oPanelLeft:Align := CONTROL_ALIGN_LEFT
lAll := .F.
@ 003, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
oAll:bChange := {|| Aeval(aCtrId,{|x| IIF(CTOD(x[3]) >= dDatabase,x[1]:=lAll,x[1]:=.F.) }), oListId:Refresh()}

@ 015, 005 LISTBOX oListID FIELDS HEADER "","Lote (CTRID)","Pgto","Total R$","Ref." SIZE 310,155 OF oPanelLeft PIXEL 
oListID:SetArray(aCtrId)
oListID:bLine := {|| {If(aCtrId[oListId:nAt][1],oOk,oNo),aCtrId[oListId:nAt][2],aCtrId[oListId:nAt][3],aCtrId[oListId:nAt][4],aCtrId[oListId:nAt][5]}}
oListID:bLDblClick := {|| aCtrId[oListId:nAt][1] := ValidaMrk(aCtrId[oListId:nAt][1],aCtrId[oListId:nAt][3]), oListID:DrawSelect()}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

If ( lOk )
	aTitGer  := {}
	nProxTit := VAL(ProxNum(.F.))
	For nI:=1 To Len(aCtrId)
        If aCtrId[nI,1]
			cQuery  := "SELECT Z2_CTRID,Z2_TIPO,Z2_BANCO,Z2_CODFOR,Z2_LOJFOR,Z2_TIPOPES,Z2_DATAPGT,SUM(Z2_VALOR) AS XX_TOTAL,COUNT(*) AS XX_COUNT, "
			cQuery  += " MAX(Z2_DATAEMI) AS XX_DATAEMI, MAX(Z2_NOME) AS XX_NOME,MAX(Z2_CPF) AS XX_CPF" //, MAX(Z2_ANEXO) AS XX_CPF "
			cQuery  += ", (CASE WHEN Z2_BANCO = '104' AND (SUBSTRING(Z2_CONTA,1,2)='37' OR SUBSTRING(Z2_CONTA,1,3)='098') THEN '37' ELSE '00' END) AS Z2_TIPCONT"
			cQuery  += ", (CASE WHEN Z2_CC= '"+aFURNAS[1]+"' THEN Z2_CC ELSE (CASE WHEN Z2_CC= '"+aFURNAS[2]+"' THEN Z2_CC ELSE '' END) END) AS Z2_CC"
			cQuery  += " FROM "+RETSQLNAME("SZ2")+" SZ2 WHERE Z2_CODEMP = '"+SM0->M0_CODIGO+"' AND Z2_STATUS = 'X' AND Z2_CTRID = '"+aCtrId[nI,2]+"' "
			cQuery  += " AND SZ2.D_E_L_E_T_ <> '*'  AND Z2_VALOR > 0 "
			//cQuery  += "AND Z2_TIPO NOT IN ('SOL ','PCT ','RMB ','NDB ') "  // PARA TESTES
			// 04/02/20 - Não integrar PJ/AC caso o usuário não seja o Laudecir ou Xavier
			IF !(__cUserId $ MV_XXUSRPJ)  // Laudecir, Xavier e Admin
				cQuery  += "AND Z2_TIPOPES NOT IN ('PJ','AC') "
			ENDIF
			cQuery  += " GROUP BY Z2_FILIAL,Z2_CTRID,Z2_TIPO,Z2_BANCO,Z2_CODFOR,Z2_LOJFOR,Z2_TIPOPES,Z2_DATAPGT "
			cQuery  += ", (CASE WHEN Z2_BANCO = '104' AND (SUBSTRING(Z2_CONTA,1,2)='37' OR SUBSTRING(Z2_CONTA,1,3)='098') THEN '37' ELSE '00' END)"
			cQuery  += ", (CASE WHEN Z2_CC= '"+aFURNAS[1]+"' THEN Z2_CC ELSE (CASE WHEN Z2_CC= '"+aFURNAS[2]+"' THEN Z2_CC ELSE '' END) END)"
			cQuery  += "  ORDER BY Z2_FILIAL,Z2_CTRID,Z2_TIPO,Z2_BANCO,Z2_CODFOR,Z2_LOJFOR,Z2_TIPOPES,Z2_DATAPGT "
			
			TCQUERY cQuery NEW ALIAS "QSZ2"
			
			TCSETFIELD("QSZ2","Z2_DATAPGT","D",8,0)
			TCSETFIELD("QSZ2","XX_DATAEMI","D",8,0)

			DbSelectArea("QSZ2")
			DbGoTop()
			Do While !eof()
				cPrf  := "LF"
				cNome := "Diversos"
				cCPF  := STRZERO(VAL(TRIM(QSZ2->XX_CPF)),11)
				IF QSZ2->XX_COUNT = 1
				   cNome := QSZ2->XX_NOME
				ENDIF
				// Z2_TIPO -> SOL = Solicitação, PCT = Prestação de Contas, RMB = Reembolso ao funcionario, NDB = Devolução do Funcionario
				IF QSZ2->Z2_TIPO $ "SOL /HOS /PCT /RMB /NDB "
				   cPrf := "DV"
				   cNome := QSZ2->XX_NOME
				ENDIF
				// Z2_TIPO -> CXA = Caixa - Prestação de Contas
				IF QSZ2->Z2_TIPO $ "CXA "
				   cPrf := "CX"
				   cNome := QSZ2->XX_NOME
				ENDIF
			    //cTitulo := PAD(ALLTRIM(QSZ2->Z2_TIPO),3,"_"+ProxNum()
			    IF QSZ2->Z2_DATAPGT < dDataBase
					MsgStop("Lote "+TRIM(QSZ2->Z2_CTRID)+" com data de pgto ("+DTOC(QSZ2->Z2_DATAPGT)+") não permitida ", "Atenção")
			    ELSE
					IF TRIM(cPrf) == "LF" 
						cTitulo := STRZERO(nProxTit++,6)+QSZ2->Z2_TIPO
					ELSE
						cTitulo := PAD(SUBSTR(QSZ2->Z2_CTRID,8,5)+QSZ2->Z2_TIPO,LEN(SE2->E2_NUM))
					ENDIF	
					AADD(aTitGer,{cPrf,cTitulo,QSZ2->Z2_CTRID,QSZ2->Z2_TIPO,QSZ2->Z2_BANCO,QSZ2->Z2_CODFOR,QSZ2->Z2_LOJFOR,QSZ2->Z2_TIPOPES,QSZ2->Z2_DATAPGT,QSZ2->XX_TOTAL,QSZ2->XX_DATAEMI,cNome,cCPF,QSZ2->Z2_TIPCONT,QSZ2->Z2_CC})
				ENDIF
				DbSkip()
			Enddo
			QSZ2->(DbCloseArea())
					
        Endif
	Next nI
Endif
If !EMPTY(aTitGer)
   lOk := ConfTit(aTitGer)
EndIf

// Desmarcar os registros do SZ2 com X, dos nao selecionados
dbSelectArea("SZ2")
dbSetOrder(1)
For nI := 1 TO LEN(aCtrId)
	xCtrId := aCtrId[nI,2]

    cQuery := " UPDATE "+RetSqlName("SZ2")+" SET Z2_STATUS = ' ' WHERE Z2_CTRID = '"+xCtrId+"' AND Z2_CODEMP = '"+SM0->M0_CODIGO+"' AND Z2_STATUS = 'X' AND D_E_L_E_T_ <> '*' AND Z2_VALOR > 0"
    TcSqlExec(cQuery)

	/*
	DbSelectArea("SZ2")
	dbSeek(xFilial("SZ2")+xCtrId,.T.)
	DO WHILE !EOF() .AND. xFilial("SZ2")+xCtrId == SZ2->Z2_FILIAL+SZ2->Z2_CTRID
	   IF SZ2->Z2_STATUS == "X"
		   RecLock("SZ2",.F.)
		   SZ2->Z2_STATUS := " "
		   MsUnlock()
	   ENDIF	   
	   dbSkip()
	ENDDO  
	*/
Next
RestArea(aAreaIni)
Return


STATIC FUNCTION ConfTit(aTitGer)
Local oOk
Local oNo
Local oDlg
Local oListId
Local oPanelLeft
//Local lAll
//Local oAll
Local aButtons := {}

Local lOk      := .F.
Local nI,nTotal := 0

FOR nI := 1 TO LEN(aTitGer)
	nTotal += aTitGer[nI,10]
NEXT

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE "Confirme os Titulos a gerar" FROM 000,000 TO 450,630 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 320,225
oPanelLeft:Align := CONTROL_ALIGN_LEFT
//lAll := .F.
//@ 005, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
//oAll:bChange := {|| Aeval(aCtrId,{|x| x[1]:=lAll}), oListId:Refresh()}
@ 005, 005 SAY "Total: "+TRANSFORM(nTotal,"@E 999,999,999.99") OF oPanelLeft SIZE 100,10 PIXEL

@ 012, 005 LISTBOX oListID FIELDS HEADER "Pref","Titulo","Lote (CTRID)","Tipo","Banco","Data Pgt","Valor R$","Nome","CPF","TPCONT",'Custo' SIZE 310,200 OF oPanelLeft PIXEL 

//cPrf,cTitulo,QSZ2->Z2_CTRID,QSZ2->Z2_TIPO,QSZ2->Z2_BANCO,QSZ2->Z2_DATAPGT,TRANSFORM(QSZ2->XX_TOTAL,"@E 999,999,999.99",cNome

oListID:SetArray(aTitGer)
oListID:bLine := {|| {	aTitGer[oListId:nAt][1],;
						aTitGer[oListId:nAt][2],;
						aTitGer[oListId:nAt][3],;
						aTitGer[oListId:nAt][4],;
						aTitGer[oListId:nAt][5],;
						aTitGer[oListId:nAt][9],;
						TRANSFORM(aTitGer[oListId:nAt][10],"@E 999,999,999.99"),;
						aTitGer[oListId:nAt][12],;
						aTitGer[oListId:nAt][13],;
						aTitGer[oListId:nAt][14],;
						aTitGer[oListId:nAt][15]}}

//oListID:bLDblClick := {|| aCtrId[oListId:nAt][1] := !aCtrId[oListId:nAt][1], oListID:DrawSelect()}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

If ( lOk )
    GravaSe2(aTitGer)
EndIf
Return lOk



Static Function GravaSe2(aTitGer)
Local cxFilial,cPrefixo,cNum,cParcela,cTipo,cFornece,cLoja,cNaturez,nValor,dVencto,dPgto,dtEmi,cNome,cTPCONT,cCTT
Local cKey1,cKey2
Local nI      := 0
//Local lOk     := .T.
Local cNatBK  := "0000000013"
Local cFornBK := "000084"
Local cLojaBK := "01"
Local cFornAC := "000071"
Local cLojaAC := "01"
Local lErroT  := .F.

If SM0->M0_CODIGO <> "01"
   cFornAC := "000084"
ENDIF

dbSelectArea("SE2")
dbSetOrder(1)
// E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

dbGoTop()

/*
For nI := 1 TO LEN(aTitGer)
    cxFilial := xFilial("SE2")
    cPrefixo := PAD(aTitGer[nI,1],LEN(SE2->E2_PREFIXO))
    cNum     := PAD(aTitGer[nI,2],LEN(SE2->E2_NUM))
    cParcela := SPACE(LEN(SE2->E2_PARCELA))
    cTipo    := PAD("DP",LEN(SE2->E2_TIPO))
    cFornece := PAD(cFornBk,LEN(SE2->E2_FORNECE))
    cLoja    := PAD(cLojaBk,LEN(SE2->E2_LOJA))
    cKey1    := cxFilial+cPrefixo+cNum+cParcela+cTipo+cFornece+cLoja
    If MsSeek(cKey1)
    	lOk := .F.
    	Exit
    Endif	
Next
//AADD(aTitGer,{cPrf,cTitulo,QSZ2->Z2_CTRID,QSZ2->Z2_TIPO,QSZ2->Z2_BANCO,QSZ2->Z2_DATAPGT,TRANSFORM(QSZ2->XX_TOTAL,"@E 999,999,999.99")})

If !lOk
	MsgStop("Titulo "+cKey1+" já existente, informe o setor de T.I.", "Atenção")
	Return
EndIf
*/

For nI := 1 TO LEN(aTitGer)

	dbSelectArea("SE2")

    cxFilial := xFilial("SE2")
    cPrefixo := PAD(aTitGer[nI,1],LEN(SE2->E2_PREFIXO))
    IF TRIM(cPrefixo) $ "LF/DV/CX" 
       cNum     := PAD(STRZERO(VAL(ProxNum(.T.)),6)+aTitGer[nI,4],LEN(SE2->E2_NUM))
       cParcela := SPACE(LEN(SE2->E2_PARCELA))
    ELSE
       cNum     := PAD(SUBSTR(aTitGer[nI,3],8,5)+aTitGer[nI,4],LEN(SE2->E2_NUM))
       cParcela := PAD(SUBSTR(aTitGer[nI,3],13,2),LEN(SE2->E2_PARCELA))
    ENDIF   

    cTipo    := PAD("DP",LEN(SE2->E2_TIPO))

	cNaturez := PAD(cNatBk,LEN(SE2->E2_NATUREZ))
	cCtrId   := PAD(aTitGer[nI,3],LEN(SE2->E2_XXCTRID))
	cTipBk   := PAD(aTitGer[nI,4],LEN(SE2->E2_XXTIPBK))
	cPortado := PAD(STRZERO(VAL(aTitGer[nI,5]),3),LEN(SE2->E2_PORTADO))

    cFornece := PAD(IIF(EMPTY(aTitGer[nI,6]),cFornBk,aTitGer[nI,6]),LEN(SE2->E2_FORNECE))
    cLoja    := PAD(IIF(EMPTY(aTitGer[nI,7]),cLojaBk,aTitGer[nI,7]),LEN(SE2->E2_LOJA))
    cCPF     := aTitGer[nI,13]
    cNome    := aTitGer[nI,12]
    cTPCONT  := aTitGer[nI,14]
    cCTT     :=  ALLTRIM(aTitGer[nI,15])
    
    cCodFor  := aTitGer[nI,6]
    cLojFor  := aTitGer[nI,7]
    cTipoPes := aTitGer[nI,8]

    IF SUBSTR(cFornece,1,1) == "C"  // Colaborador, verificar se existe, senão, cadastrar Fornecedor
       CadColab(cCodFor,cLojFor,cNome,cCPF)
    ENDIF

	dPgto    := dVencto  := aTitGer[nI,9]
	nValor   := aTitGer[nI,10]
	dtEmi    := aTitGer[nI,11]
	If Empty(dtEmi)
		dtEmi := dDataBase
	EndIf
		
    //IF dVencto < (dDataBase + 2)
    //   dVencto := dDataBase + 2
    //ENDIF

    IF TRIM(cPrefixo) = "DV"
		cNaturez  := "0000000018"
       IF TRIM(cTipBk) == "SOL"
	      //cTipo := PAD("PA",LEN(SE2->E2_TIPO)) //Solicitado pelo Xavier em 18/05/20
	      cTipo := PAD("DP",LEN(SE2->E2_TIPO))
       ELSEIF TRIM(cTipBk) == "HOS"
	      //cTipo := PAD("PA",LEN(SE2->E2_TIPO))
	      cTipo := PAD("DP",LEN(SE2->E2_TIPO))
	   ELSEIF TRIM(cTipBk) == "NDB"   
	      cTipo := PAD("NDF",LEN(SE2->E2_TIPO))
	   ELSE   
	      cTipo := PAD("DP",LEN(SE2->E2_TIPO))
       ENDIF
    ELSEIF TRIM(cPrefixo) = "CX"
		cNaturez  := "0000000018"
       IF TRIM(cTipBk) == "CXA"
	      //cTipo := PAD("PA",LEN(SE2->E2_TIPO))
	      cTipo := PAD("DP",LEN(SE2->E2_TIPO))
	   ENDIF
    ELSE
	    IF cTipoPes $ "PJ "   //"PJ /AC /CLA"
	       cTipo := PAD("PA",LEN(SE2->E2_TIPO))
	    ENDIF
	    IF cTipoPes $ "AC " .AND. !EMPTY(cCodFor)
	       cTipo := PAD("PA",LEN(SE2->E2_TIPO))
	    ENDIF
	    
	    IF EMPTY(cCodFor)
	       IF cTipoPes $ "AC /CLA"
	          cFornece := cFornAC
	          cLoja    := cLojaAC
	       ELSE
	          cFornece := cFornBK
	          cLoja    := cLojaBK
	       ENDIF
	    ENDIF
	ENDIF    
    cKey1  := cxFilial+cPrefixo+cNum+cParcela+cTipo+cFornece+cLoja
	cKey2  := xFilial("SZ2")+SM0->M0_CODIGO+cCtrId+cTipBk+cPortado  //+DTOS(dVencto)
	
	cPortadoPA := ""
	//IF SM0->M0_CODIGO == "01"
	//	cPortadoPA := cPortado
	//ELSE
		DbSelectArea("SA6")
		SA6->(DbSetOrder(1))
		IF SA6->(DbSeek(xFilial("SA6")+cPortado,.T.))
			cPortadoPA := cPortado
		ELSE
			cPortadoPA := "001" 
		ENDIF
	//ENDIF 

	aVetor :={{"E2_FILIAL"  ,cxFilial,Nil},;
             {"E2_PREFIXO"  ,cPrefixo,Nil},;
             {"E2_NUM"      ,cNum,Nil},;
             {"E2_PARCELA"  ,cParcela,Nil},;
             {"E2_TIPO"     ,cTipo,Nil},;        
             {"E2_FORNECE"  ,cFornece,Nil},; 
             {"E2_LOJA"     ,cLoja,Nil},;      
             {"E2_NATUREZ"  ,cNaturez,Nil},;
             {"E2_PORTADO"  ,cPortado,Nil},;
             {"AUTBANCO"    ,cPortadoPA,NIL},;
	         {"AUTAGENCIA"  ,""      ,NIL},; 
	         {"AUTCONTA"    ,""      ,NIL},;
             {"AUTCHEQUE"   ,""      ,NIL},;
             {"E2_XXTIPBK"  ,cTipBk,Nil},;
             {"E2_XXCTRID"  ,cCtrId,Nil},;
             {"E2_HIST"     ,IIF(cPrefixo="LF","Depto Pessoal",IIF(cPrefixo="CX","Caixa","Despesas de Viagem")),NIL},;
             {"E2_EMISSAO"  ,dtEmi,NIL},;
             {"E2_VENCTO"   ,dVencto,NIL},;                
             {"E2_EMIS1"    ,dtEmi,NIL},;              
             {"E2_VALOR"    ,nValor,Nil},;
             {"F4_APLIIVA"  ,"2",Nil},;
             {"E2_MOEDA"    ,1  , Nil},;
             {"ED_REDCOF"   ,0  , Nil},;
             {"ED_REDPIS"   ,0  , Nil}}
   
	lErroT := .F.

	Begin Transaction

    	cErro       := ""
		lMsErroAuto := .F.   
		MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetor,,3) //Inclusao
		

		IF lMsErroAuto
		
			MsgStop("Problemas na geração do titulo "+cKey2+", informe o setor de T.I. "+cKey1, "Atenção")
		    MostraErro()
			DisarmTransaction()
			lErroT := .T.
		ENDIF	

    END Transaction

	If lErroT
		Return
		//Exit
	EndIf

	dbSelectArea("SZ2")   
	dbSetorder(2)   // Z2_FILIAL+ Z2_CODEMP+Z2_CTRID+Z2_TIPO+Z2_BANCO+Z2_DATAPGT     
	dbSeek(cKey2,.T.)
	
	Do While !EOF() .AND. SZ2->Z2_FILIAL == xFilial("SZ2") .AND. SZ2->Z2_CODEMP = SM0->M0_CODIGO .AND. SZ2->Z2_CTRID == cCtrId .AND. ;
		                  SZ2->Z2_TIPO == cTipBk .AND. STRZERO(VAL(SZ2->Z2_BANCO),3) == cPortado
		    
		IF SZ2->Z2_DATAPGT == dPgto .AND. SZ2->Z2_CODFOR = cCodFor .AND. SZ2->Z2_LOJFOR = cLojFor .AND. SZ2->Z2_TIPOPES = cTipoPes
			IF cCTT == aFURNAS[1] .AND. ALLTRIM(SZ2->Z2_CC) == aFURNAS[1]  
		   		IF cTPCONT == "37" .AND. (SUBSTR(SZ2->Z2_CONTA,1,2)=='37' .OR. SUBSTR(SZ2->Z2_CONTA,1,3)=='098')
		   			IF SZ2->Z2_STATUS == "X"
		    			RecLock("SZ2",.F.)
		    			SZ2->Z2_STATUS := "S"
		    			SZ2->Z2_TITULO := cKey1
		    			SZ2->Z2_E2Prf  := cPrefixo
		    			SZ2->Z2_E2Num  := cNum
		    			SZ2->Z2_E2Parc := cParcela
		    			SZ2->Z2_E2Tipo := cTipo
		    			SZ2->Z2_E2Forn := cFornece
		    			SZ2->Z2_E2Loja := cLoja
			    		SZ2->(MsUnlock())
			    	ENDIF
		   		ELSEIF SZ2->Z2_BANCO =='104' .AND. SUBSTR(SZ2->Z2_CONTA,1,2) <> '37' .AND. SUBSTR(SZ2->Z2_CONTA,1,3) <> '098'
            		IF SZ2->Z2_STATUS == "X" 
		    			RecLock("SZ2",.F.)
		    			SZ2->Z2_STATUS := "S"
		    			SZ2->Z2_TITULO := cKey1
		    			SZ2->Z2_E2Prf  := cPrefixo
		    			SZ2->Z2_E2Num  := cNum
		    			SZ2->Z2_E2Parc := cParcela
		    			SZ2->Z2_E2Tipo := cTipo
		    			SZ2->Z2_E2Forn := cFornece
		    			SZ2->Z2_E2Loja := cLoja
			    		SZ2->(MsUnlock())
			    	ENDIF
				ELSEIF SZ2->Z2_BANCO <>'104'
            		IF SZ2->Z2_STATUS == "X" 
			    		RecLock("SZ2",.F.)
			    		SZ2->Z2_STATUS := "S"
			    		SZ2->Z2_TITULO := cKey1
			    		SZ2->Z2_E2Prf  := cPrefixo
			    		SZ2->Z2_E2Num  := cNum
			    		SZ2->Z2_E2Parc := cParcela
			    		SZ2->Z2_E2Tipo := cTipo
			    		SZ2->Z2_E2Forn := cFornece
			    		SZ2->Z2_E2Loja := cLoja
			    		SZ2->(MsUnlock())
			    	ENDIF
				ENDIF    
			ELSEIF cCTT == aFURNAS[2] .AND. ALLTRIM(SZ2->Z2_CC) == aFURNAS[2]  
		   		IF cTPCONT == "37" .AND. (SUBSTR(SZ2->Z2_CONTA,1,2)=='37' .OR. SUBSTR(SZ2->Z2_CONTA,1,3)=='098')
		   			IF SZ2->Z2_STATUS == "X"
		    			RecLock("SZ2",.F.)
		    			SZ2->Z2_STATUS := "S"
		    			SZ2->Z2_TITULO := cKey1
		    			SZ2->Z2_E2Prf  := cPrefixo
		    			SZ2->Z2_E2Num  := cNum
		    			SZ2->Z2_E2Parc := cParcela
		    			SZ2->Z2_E2Tipo := cTipo
		    			SZ2->Z2_E2Forn := cFornece
		    			SZ2->Z2_E2Loja := cLoja
			    		SZ2->(MsUnlock())
			    	ENDIF
		   		ELSEIF SZ2->Z2_BANCO =='104' .AND. SUBSTR(SZ2->Z2_CONTA,1,2) <> '37' .AND. SUBSTR(SZ2->Z2_CONTA,1,3) <> '098'
            		IF SZ2->Z2_STATUS == "X" 
		    			RecLock("SZ2",.F.)
		    			SZ2->Z2_STATUS := "S"
		    			SZ2->Z2_TITULO := cKey1
		    			SZ2->Z2_E2Prf  := cPrefixo
		    			SZ2->Z2_E2Num  := cNum
		    			SZ2->Z2_E2Parc := cParcela
		    			SZ2->Z2_E2Tipo := cTipo
		    			SZ2->Z2_E2Forn := cFornece
		    			SZ2->Z2_E2Loja := cLoja
			    		SZ2->(MsUnlock())
			    	ENDIF
				ELSEIF SZ2->Z2_BANCO <>'104'
            		IF SZ2->Z2_STATUS == "X" 
			    		RecLock("SZ2",.F.)
			    		SZ2->Z2_STATUS := "S"
			    		SZ2->Z2_TITULO := cKey1
			    		SZ2->Z2_E2Prf  := cPrefixo
			    		SZ2->Z2_E2Num  := cNum
			    		SZ2->Z2_E2Parc := cParcela
			    		SZ2->Z2_E2Tipo := cTipo
			    		SZ2->Z2_E2Forn := cFornece
			    		SZ2->Z2_E2Loja := cLoja
			    		SZ2->(MsUnlock())
			    	ENDIF
				ENDIF    
			ELSEIF ALLTRIM(SZ2->Z2_CC) <> aFURNAS[1] .AND. ALLTRIM(SZ2->Z2_CC) <> aFURNAS[2]
		   		IF cTPCONT == "37" .AND. (SUBSTR(SZ2->Z2_CONTA,1,2)=='37' .OR. SUBSTR(SZ2->Z2_CONTA,1,3)=='098')
		   			IF SZ2->Z2_STATUS == "X"
		    			RecLock("SZ2",.F.)
		    			SZ2->Z2_STATUS := "S"
		    			SZ2->Z2_TITULO := cKey1
		    			SZ2->Z2_E2Prf  := cPrefixo
		    			SZ2->Z2_E2Num  := cNum
		    			SZ2->Z2_E2Parc := cParcela
		    			SZ2->Z2_E2Tipo := cTipo
		    			SZ2->Z2_E2Forn := cFornece
		    			SZ2->Z2_E2Loja := cLoja
			    		SZ2->(MsUnlock())
			    	ENDIF
		   		ELSEIF SZ2->Z2_BANCO =='104' .AND. SUBSTR(SZ2->Z2_CONTA,1,2) <> '37' .AND. SUBSTR(SZ2->Z2_CONTA,1,3) <> '098'

            		IF SZ2->Z2_STATUS == "X" 
		    			RecLock("SZ2",.F.)
		    			SZ2->Z2_STATUS := "S"
		    			SZ2->Z2_TITULO := cKey1
		    			SZ2->Z2_E2Prf  := cPrefixo
		    			SZ2->Z2_E2Num  := cNum
		    			SZ2->Z2_E2Parc := cParcela
		    			SZ2->Z2_E2Tipo := cTipo
		    			SZ2->Z2_E2Forn := cFornece
		    			SZ2->Z2_E2Loja := cLoja
			    		SZ2->(MsUnlock())
			    	ENDIF
				ELSEIF SZ2->Z2_BANCO <>'104'
            		IF SZ2->Z2_STATUS == "X" 
			    		RecLock("SZ2",.F.)
			    		SZ2->Z2_STATUS := "S"
			    		SZ2->Z2_TITULO := cKey1
			    		SZ2->Z2_E2Prf  := cPrefixo
			    		SZ2->Z2_E2Num  := cNum
			    		SZ2->Z2_E2Parc := cParcela
			    		SZ2->Z2_E2Tipo := cTipo
			    		SZ2->Z2_E2Forn := cFornece
			    		SZ2->Z2_E2Loja := cLoja
			    		SZ2->(MsUnlock())
			    	ENDIF
				ENDIF    
			ENDIF
		ENDIF
		SZ2->(dbSkip())
	EndDo

Next	
Return Nil

 
Static Function ValidaMrk(lRet,cPgto)
IF CTOD(cPgto) >= dDataBase
   lRet := !lRet
ELSE
   MsgStop("Data de pgto deste lote é inferior a data base do sistema", "Atenção")
   lRet := .F.
ENDIF   
Return lRet


Static Function CadColab(cFornece,cLoja,cNome,cCPF)
Local lRet := .T.
Local aVetor,nAcao,cReg,cNReduz
Local aArea1 := GetArea()
Local aAutoErro := {}
Private lMsErroAuto := .F.	


IF !SA2->(dbSeek(xFilial("SA2")+cFornece+cLoja,.F.))
   aVetor := {}
   cNReduz := SUBSTR(cNome,1,AT(cNome," "))
   IF EMPTY(cNReduz)
      cNReduz := cNome
   ENDIF
   cNReduz := PAD(cNReduz,TamSx3("A2_NREDUZ")[1])
      
   AADD(aVetor,{"A2_FILIAL"  , xFilial("SA2"),Nil} )
   AADD(aVetor,{"A2_COD"     , cFornece,Nil})
   AADD(aVetor,{"A2_LOJA"    , cLoja,Nil})
   AADD(aVetor,{"A2_NOME"    , cNome,Nil})
   AADD(aVetor,{"A2_NREDUZ"  , cNReduz,Nil})
   AADD(aVetor,{"A2_TIPO"    , "F",Nil})
   AADD(aVetor,{"A2_CGC"     , cCPF,Nil})
   AADD(aVetor,{"A2_EST"     , "SP",Nil})
   AADD(aVetor,{"A2_INSCR"   , "ISENTO",Nil})
   AADD(aVetor,{"A2_END"     , "COLABORADOR",Nil})
   AADD(aVetor,{"A2_COD_MUN" , "50308",Nil})
   AADD(aVetor,{"A2_MUN"     , "SAO PAULO",Nil})
   AADD(aVetor,{"A2_NATUREZ" , "0000000010",Nil})            
   AADD(aVetor,{"A2_CONTA"   , "21101001",Nil})                
   
   cReg  := cFornece+"-"+cLoja+"-"+cNome+": "
   nAcao := 3
   aAutoErro := {}
   
   IF nAcao > 0
      	lMsErroAuto := .F.	
      	MSExecAuto({|x,y| Mata020(x,y)},aVetor,nAcao) //Inclusao ou Alteração
         
		IF lMsErroAuto
		    MostraErro()
			DisarmTransaction()
			Return
		ENDIF	
   
	ENDIF
ENDIF

RestArea(aArea1)

Return lRet


STATIC FUNCTION ExcVZero()
Local cQuery  := ""
Local aEmail1 := {}
Local aEmail2 := {}
Local cAssunto:= "Pagamentos nao Efetuados valores zerado ou negativo devolvido ao RH "

// Verificar se há titulos com valores zerado ou negativo
cQuery  := "SELECT R_E_C_N_O_ AS nREGSZ2" 
cQuery  += " FROM "+RETSQLNAME("SZ2")+" SZ2 WHERE Z2_CODEMP = '"+SM0->M0_CODIGO+"' "
cQuery  += " AND Z2_VALOR <= 0 AND SZ2.D_E_L_E_T_ <> '*' AND Z2_STATUS <> 'D'"

TCQUERY cQuery NEW ALIAS "QSZ2"

DbSelectArea("QSZ2")
QSZ2->(DbGoTop())
Do While QSZ2->(!eof())
	dbSelectArea("SZ2")
	SZ2->(dbGoto(QSZ2->nREGSZ2))
	IF SZ2->(RecNo()) == QSZ2->nREGSZ2 .AND. SZ2->Z2_VALOR <= 0 .AND. SZ2->Z2_STATUS <> 'D'
		RecLock("SZ2",.F.)
      	SZ2->Z2_STATUS := "D"
      	SZ2->Z2_OBS    := "Titulo valor "+IIF(SZ2->Z2_VALOR < 0,"negativo","zerado")+" excluido: "+DTOC(DATE())+"-"+TIME()
    	IF SUBSTR(SZ2->Z2_TIPOPES,1,3) <> "CLT"
    	   AADD(aEmail1,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,SZ2->Z2_OBS,SZ2->Z2_E2PRF+SZ2->Z2_E2NUM,SZ2->Z2_CTRID})
    	ELSE
    	   AADD(aEmail2,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,SZ2->Z2_OBS,SZ2->Z2_E2PRF+SZ2->Z2_E2NUM,SZ2->Z2_CTRID})
    	ENDIF
	    SZ2->(MsUnlock())
  	ENDIF	 
	QSZ2->(DbSkip())
EndDO

QSZ2->(DbCloseArea())


If LEN(aEmail1) > 0 // AC
	U_Fina02E(aEmail1,.F.,cAssunto)
EndIf	
If LEN(aEmail2) > 0 // CLT
	U_Fina02E(aEmail2,.T.,cAssunto)
EndIf

Return nil 


STATIC FUNCTION ExcDuplic()
Local cQuery  := ""
Local aEmail1 := {}
Local aEmail2 := {}
Local cAssunto:= "Titulo(s) já lançado(s) devolvido ao RH "

// Verificar se há titulos ja lancados
cQuery  := "SELECT SZ2X.Z2_CODEMP,SZ2X.Z2_TIPO,SZ2X.Z2_PRONT,SZ2X.Z2_TIPCOL,SZ2X.Z2_DATAPGT,SZ2X.R_E_C_N_O_ AS nREGSZ2,"
cQuery  += " (SELECT TOP 1 Z2_PRONT"
cQuery  += " FROM "+RETSQLNAME("SZ2")+" SZ2Y WHERE SZ2Y.D_E_L_E_T_='' "
cQuery  += " AND SZ2Y.Z2_CODEMP  = SZ2X.Z2_CODEMP "
cQuery  += " AND SZ2Y.Z2_TIPO    = SZ2X.Z2_TIPO "
cQuery  += " AND SZ2Y.Z2_PRONT   = SZ2X.Z2_PRONT "
cQuery  += " AND SZ2Y.Z2_DATAPGT = SZ2X.Z2_DATAPGT "
cQuery  += " AND SZ2Y.Z2_VALOR   = SZ2X.Z2_VALOR "
cQuery  += " AND SZ2Y.Z2_STATUS <> 'D' "
cQuery  += " AND SZ2Y.Z2_TIPOPES=SZ2X.Z2_TIPOPES "
cQuery  += " AND SZ2Y.R_E_C_N_O_ <> SZ2X.R_E_C_N_O_) AS EXISTE  "
cQuery  += " FROM "+RETSQLNAME("SZ2")+" SZ2X WHERE SZ2X.D_E_L_E_T_ = '' "
cQuery  += " AND SZ2X.Z2_CODEMP = '"+SM0->M0_CODIGO+"' AND SZ2X.Z2_STATUS = ' ' AND Z2_TIPO<>'LFG' AND Z2_TIPO<>'PEN'" 

TCQUERY cQuery NEW ALIAS "QSZ2"

DbSelectArea("QSZ2")
DbGoTop()
Do While QSZ2->(!eof())
	IF !EMPTY(QSZ2->EXISTE)
		dbSelectArea("SZ2")
		SZ2->(dbGoto(QSZ2->nREGSZ2))
		IF SZ2->(RecNo()) == QSZ2->nREGSZ2 .AND. SZ2->Z2_STATUS <> 'D'
			RecLock("SZ2",.F.)
   			SZ2->Z2_STATUS := "D"
   			SZ2->Z2_OBS    := "Titulo já lançado - excluido: "+DTOC(DATE())+"-"+TIME()
   			IF SUBSTR(SZ2->Z2_TIPOPES,1,3) <> "CLT"
   	   			AADD(aEmail1,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,SZ2->Z2_OBS,SZ2->Z2_E2PRF+SZ2->Z2_E2NUM,SZ2->Z2_CTRID})
   			ELSE
   	   			AADD(aEmail2,{SZ2->Z2_PRONT,SZ2->Z2_NOME,SZ2->Z2_VALOR,SZ2->Z2_BANCO,SZ2->Z2_AGENCIA,SZ2->Z2_DIGAGEN,SZ2->Z2_CONTA,SZ2->Z2_DIGCONT,SZ2->Z2_OBS,SZ2->Z2_E2PRF+SZ2->Z2_E2NUM,SZ2->Z2_CTRID})
   			ENDIF
    		SZ2->(MsUnlock())
		ENDIF
	ENDIF
	QSZ2->(DbSkip())
EndDO

QSZ2->(DbCloseArea())


If LEN(aEmail1) > 0 // AC
	U_Fina02E(aEmail1,.F.,cAssunto)
EndIf	
If LEN(aEmail2) > 0 // CLT
	U_Fina02E(aEmail2,.T.,cAssunto)
EndIf

Return nil 



User Function Fina02E(aEmail,lCLT,cAssunto)
Local cPrw     := "BKFINA02"
Local cEmail1  := "sigapgto1@bkconsultoria.com.br"  //"anderson.oliveira@bkconsultoria.com.br;alexandre.teixeira@bkconsultoria.com.br;financeiro@bkconsultoria.com.br;"
Local cEmail2  := "sigapgto2@bkconsultoria.com.br"  //"rh@bkconsultoria.com.br;gestao@bkconsultoria.com.br;financeiro@bkconsultoria.com.br;"
Local cCC      := ""
Local cMsg     := "" 
Local cAnexo   := ""
Local _lJob    := .F.

Local aCabs


//cEmail1 := "microsiga@bkconsultoria.com.br;"
//cEmail2 := ""


aCabs   := {"Pront.","Nome","Valor","Bco","Ag.","Dg.Ag.","Conta","Dg.Conta","Obs.","Titulo","CtrId"}
cMsg    := u_GeraHtmA(aEmail,cAssunto+DTOC(DATE())+"-"+TIME(),aCabs,cPrw)

U_SendMail(cPrw,cAssunto,IIF(lCLT,cEmail2,cEmail1),cCc,cMsg,cAnexo,_lJob)

Return Nil



