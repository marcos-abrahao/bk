#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKCOMA02()
BK - Seleção de NF - Integração VT/VR 

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

@author Marcos B. Abrahão
@since 29/09/2009
@version P10
@return Nil
/*/

User Function BKCOMA02()

Local oOk
Local oNo
Local oDlg
Local oListId
Local oPanelLeft
Local lAll
Local oAll
Local aButtons := {}

Local aCtrId,aNfGer
Local lOk      := .F.
Local aAreaIni := GetArea()
Local cQuery
Local nI,cPrf,cTitulo,nProxTit
Local nStatusX
Local cPrw     := "BKCOMA02"

dbSelectArea("SZB")
dbGoTop()
IF BOF() .OR. EOF()
	u_MsgLog(cPrw,"Não há VT/VR gerados", "W")
	RestArea(aAreaIni)
	Return
ENDIF

u_MsgLog(cPrw)

// Verificar se há processos de integração em andamento
cQuery  := "SELECT COUNT(*) AS ZBSTATUSX " 
cQuery  += "FROM "+RETSQLNAME("SZB")+" SZB WHERE ZB_STATUS = 'X' AND SZB.D_E_L_E_T_ <> '*'"

TCQUERY cQuery NEW ALIAS "QSZB"

DbSelectArea("QSZB")
DbGoTop()
nStatusX := QSZB->ZBSTATUSX
QSZB->(DbCloseArea())

IF nStatusX > 0
   u_MsgLog(cPrw,"Integração já iniciada por outra seção", "W")
	IF __cUserId <> "000000"
	   u_MsgLog(cPrw,"Verifique se há algum usuario processando a integração, caso contrário comunique o administrador do sistema", "E")
    ELSE
       IF u_MsgLog(cPrw,"Sr. Administrador, deseja resetar o campo ZB_STATUS=X de "+STRZERO(nStatusX,6)+" registros ?","Y")
		  cQuery := " UPDATE "+RetSqlName("SZB")+" SET ZB_STATUS = ' ' WHERE ZB_STATUS = 'X' AND D_E_L_E_T_ <> '*'"
    	  TcSqlExec(cQuery)
    	  u_MsgLog(cPrw,"Registros resetados: "+STRZERO(nStatusX,6)+", reinicie o programa","S")
       ENDIF  
    ENDIF
   RestArea(aAreaIni)
   Return
ENDIF

cQuery  := "SELECT ZB_FILIAL,ZB_SERIE,ZB_DOC,ZB_FORN,ZB_LOJA,MAX(ZB_COMPET) AS XX_COMPET,SUM(ZB_VUNIT) AS XX_VALOR " 
cQuery  += "FROM "+RETSQLNAME("SZB")+" SZB WHERE ZB_STATUS = ' ' AND SZB.D_E_L_E_T_ <> '*'"
cQuery  += "GROUP BY ZB_FILIAL,ZB_SERIE,ZB_DOC,ZB_FORN,ZB_LOJA "
cQuery  += "ORDER BY ZB_FILIAL,ZB_SERIE,ZB_DOC,ZB_FORN,ZB_LOJA "

TCQUERY cQuery NEW ALIAS "QSZB"

dbSelectArea("SZB")
dbSetOrder(1)

DbSelectArea("QSZB")
DbGoTop()

aCtrId := {}
Do While !eof()
	AADD(aCtrId,{.F.,QSZB->ZB_FILIAL,QSZB->ZB_SERIE,QSZB->ZB_DOC,QSZB->ZB_FORN,QSZB->ZB_LOJA,QSZB->XX_COMPET,TRANSFORM(QSZB->XX_TOTAL,"@E 999,999,999.99")})
	xCtrId := QSZ2->Z2_CTRID
	// Marcar os registros do SZB com X, selecionados
	
    cQuery := " UPDATE "+RetSqlName("SZB")+" SET ZB_STATUS = 'X' "
    cQuery += " WHERE ZB_FILIAL = '"+QSZB->ZB_FILIAL+"' "
    cQuery += "   AND ZB_SERIE  = '"+QSZB->ZB_SERIE+"' "
    cQuery += "   AND ZB_DOC    = '"+QSZB->ZB_DOC+"' "
    cQuery += "   AND ZB_FORN   = '"+QSZB->ZB_FORN+"' "
    cQuery += "   AND ZB_LOJA   = '"+QSZB->ZB_LOJA+"' "
    cQuery += "   AND ZB_STATUS = ' ' "
    cQuery += "   AND D_E_L_E_T_ <> '*'"
    
    TcSqlExec(cQuery)

	DbSelectArea("QSZB")
	DbSkip()
Enddo
QSZB->(DbCloseArea())

//ASORT(aCtrId,,,{|x,y| x[2]<y[2]})

If Empty(aCtrId)
	u_MsgLog(,"Não há NFs disponíveis", "W")
	RestArea(aAreaIni)
	Return
EndIf

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE "Seleção de NF - Integração VT/VR" FROM 000,000 TO 400,630 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 320,225
oPanelLeft:Align := CONTROL_ALIGN_LEFT
lAll := .F.
@ 003, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
oAll:bChange := {|| Aeval(aCtrId,{|x| IIF(CTOD(x[3]) >= dDatabase,x[1]:=lAll,x[1]:=.F.) }), oListId:Refresh()}

@ 015, 005 LISTBOX oListID FIELDS HEADER "","Série","NF","Fornecedor","Loja","Mes","Total R$" SIZE 310,170 OF oPanelLeft PIXEL 
oListID:SetArray(aCtrId)
oListID:bLine := {|| {If(aCtrId[oListId:nAt][1],oOk,oNo),aCtrId[oListId:nAt][3],aCtrId[oListId:nAt][4],aCtrId[oListId:nAt][5],aCtrId[oListId:nAt][6],aCtrId[oListId:nAt][7],aCtrId[oListId:nAt][8]}}
oListID:bLDblClick := {|| aCtrId[oListId:nAt][1] := ValidaMrk(aCtrId[oListId:nAt][1],aCtrId[oListId:nAt][3]), oListID:DrawSelect()}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

If ( lOk )
	aNfGer  := {}
	nProxTit := VAL(ProxNum(.F.))
	For nI:=1 To Len(aCtrId)
        If aCtrId[nI,1]

			cQuery := "SELECT ZB_FILIAL,ZB_SERIE,ZB_DOC,ZB_FORN,ZB_LOJA,MAX(ZB_COMPET) AS XX_COMPET,SUM(ZB_VUNIT) AS XX_VALOR " 
			cQuery += "FROM "+RETSQLNAME("SZB")+" "
		    cQuery += " WHERE ZB_FILIAL = '"+aCtrId[nI,2]+"' "
		    cQuery += "   AND ZB_SERIE  = '"+aCtrId[nI,3]+"' "
		    cQuery += "   AND ZB_DOC    = '"+aCtrId[nI,4]+"' "
		    cQuery += "   AND ZB_FORN   = '"+aCtrId[nI,5]+"' "
		    cQuery += "   AND ZB_LOJA   = '"+aCtrId[nI,6]+"' "
		    cQuery += "   AND ZB_STATUS = ' ' "
		    cQuery += "   AND D_E_L_E_T_ <> '*'"
			cQuery += "GROUP BY ZB_FILIAL,ZB_SERIE,ZB_DOC,ZB_FORN,ZB_LOJA "
			cQuery += "ORDER BY ZB_FILIAL,ZB_SERIE,ZB_DOC,ZB_FORN,ZB_LOJA "
			
			TCQUERY cQuery NEW ALIAS "QSZB"
			
			//TCSETFIELD("QSZB","Z2_DATAPGT","D",8,0)

			DbSelectArea("QSZB")
			DbGoTop()
			Do While !eof()
				AADD(aNfGer,{cPrf,cTitulo,QSZ2->Z2_CTRID,QSZ2->Z2_TIPO,QSZ2->Z2_BANCO,QSZ2->Z2_CODFOR,QSZ2->Z2_LOJFOR,QSZ2->Z2_TIPOPES,QSZ2->Z2_DATAPGT,QSZ2->XX_TOTAL})
				DbSkip()
			Enddo
			QSZB->(DbCloseArea())
					
        Endif
	Next nI
Endif
If !EMPTY(aTitGer)
   lOk := ConfTit(aTitGer)
EndIf

// Desmarcar os registros do SZ2 com X, dos nao selecionados
dbSelectArea("SZB")
dbSetOrder(1)

For nI := 1 TO LEN(aCtrId)
    cQuery := " UPDATE "+RetSqlName("SZB")+" SET ZB_STATUS = ' ' "
    cQuery += " WHERE ZB_FILIAL = '"+aCtrId[nI,2]+"' "
    cQuery += "   AND ZB_SERIE  = '"+aCtrId[nI,3]+"' "
    cQuery += "   AND ZB_DOC    = '"+aCtrId[nI,4]+"' "
    cQuery += "   AND ZB_FORN   = '"+aCtrId[nI,5]+"' "
    cQuery += "   AND ZB_LOJA   = '"+aCtrId[nI,6]+"' "
    cQuery += "   AND ZB_STATUS = 'X' "
    cQuery += "   AND D_E_L_E_T_ <> '*'"
    TcSqlExec(cQuery)
Next
RestArea(aAreaIni)
Return


STATIC FUNCTION ConfTit(aTitGer)
Local oOk
Local oNo
Local oDlg
Local oListId
Local oPanelLeft
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

@ 012, 005 LISTBOX oListID FIELDS HEADER "Pref","Titulo","Lote (CTRID)","Tipo","Banco","Data Pgt","Valor R$" SIZE 310,200 OF oPanelLeft PIXEL 

//cPrf,cTitulo,QSZ2->Z2_CTRID,QSZ2->Z2_TIPO,QSZ2->Z2_BANCO,QSZ2->Z2_DATAPGT,TRANSFORM(QSZ2->XX_TOTAL,"@E 999,999,999.99")

oListID:SetArray(aTitGer)
oListID:bLine := {|| {	aTitGer[oListId:nAt][1],;
						aTitGer[oListId:nAt][2],;
						aTitGer[oListId:nAt][3],;
						aTitGer[oListId:nAt][4],;
						aTitGer[oListId:nAt][5],;
						aTitGer[oListId:nAt][9],;
						TRANSFORM(aTitGer[oListId:nAt][10],"@E 999,999,999.99")}}

//oListID:bLDblClick := {|| aCtrId[oListId:nAt][1] := !aCtrId[oListId:nAt][1], oListID:DrawSelect()}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

If ( lOk )
    GravaSe2(aTitGer)
EndIf
Return lOk



Static Function GravaSe2(aTitGer)
Local cxFilial,cPrefixo,cNum,cParcela,cTipo,cFornece,cLoja,cNaturez,nValor,dVencto,dPgto
Local cKey1,cKey2
Local nI
Local cNatBK  := "0000000013"
Local cFornBK := "000084"
Local cLojaBK := "01"
Local cFornAC := "000071"
Local cLojaAC := "01"
Local lErro   := .F.

If cEmpAnt <> "01"
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
    cNum     := PAD(STRZERO(VAL(TRIM(ProxNum(.T.))),5)+aTitGer[nI,4],LEN(SE2->E2_NUM))
    cParcela := SPACE(LEN(SE2->E2_PARCELA))
    cTipo    := PAD("DP",LEN(SE2->E2_TIPO))

	cNaturez := PAD(cNatBk,LEN(SE2->E2_NATUREZ))
	cCtrId   := PAD(aTitGer[nI,3],LEN(SE2->E2_XXCTRID))
	cTipBk   := PAD(aTitGer[nI,4],LEN(SE2->E2_XXTIPBK))
	cPortado := PAD(STRZERO(VAL(aTitGer[nI,5]),3),LEN(SE2->E2_PORTADO))

   cFornece := PAD(IIF(EMPTY(aTitGer[nI,6]),cFornBk,aTitGer[nI,6]),LEN(SE2->E2_FORNECE))
   cLoja    := PAD(IIF(EMPTY(aTitGer[nI,7]),cLojaBk,aTitGer[nI,7]),LEN(SE2->E2_LOJA))

   cCodFor  := aTitGer[nI,6]
   cLojFor  := aTitGer[nI,7]
   cTipoPes := aTitGer[nI,8]

	dPgto    := dVencto  := aTitGer[nI,9]
	nValor   := aTitGer[nI,10]
	
    //IF dVencto < (dDataBase + 2)
    //   dVencto := dDataBase + 2
    //ENDIF

    IF cTipoPes $ "PJ /AC /CLA"
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
    cKey1  := cxFilial+cPrefixo+cNum+cParcela+cTipo+cFornece+cLoja
	cKey2  := xFilial("SZ2")+SM0->M0_CODIGO+cCtrId+cTipBk+cPortado  //+DTOS(dVencto) 

	aVetor :={{"E2_FILIAL"  ,cxFilial,Nil},;
             {"E2_PREFIXO"  ,cPrefixo,Nil},;
             {"E2_NUM"      ,cNum,Nil},;
             {"E2_PARCELA"  ,cParcela,Nil},;
             {"E2_TIPO"     ,cTipo,Nil},;        
             {"E2_FORNECE"  ,cFornece,Nil},; 
             {"E2_LOJA"     ,cLoja,Nil},;      
             {"E2_NATUREZ"  ,cNaturez,Nil},;
             {"E2_PORTADO"  ,cPortado,Nil},;
             {"E2_XXTIPBK"  ,cTipBk,Nil},;
             {"E2_XXCTRID"  ,cCtrId,Nil},;
             {"E2_HIST"     ,"Depto Pessoal",NIL},;
             {"E2_EMISSAO"  ,dDataBase,NIL},;
             {"E2_VENCTO"   ,dVencto,NIL},;                
             {"E2_EMIS1"    ,dDataBase,NIL},;              
             {"E2_VALOR"    ,nValor,Nil}}

	lMsErroAuto := .F.
   lErro := .F.
   Begin Transaction
      MSExecAuto({|x,y,z| Fina050(x,y,z)},aVetor,,3) //Inclusao
      If lMsErroAuto
         u_LogMsExec(,"Problemas na geração do titulo "+cKey2)
         DisarmTransaction()
         lErro := .T.
      EndIf
   End Transaction

   If !lErro
      dbSelectArea("SZ2")   
      dbSetorder(2)   // Z2_FILIAL+ Z2_CODEMP+Z2_CTRID+Z2_TIPO+Z2_BANCO+Z2_DATAPGT     
      dbSeek(cKey2,.T.)
      
      Do While !EOF() .AND. SZ2->Z2_FILIAL == xFilial("SZ2") .AND. SZ2->Z2_CODEMP = SM0->M0_CODIGO .AND. SZ2->Z2_CTRID == cCtrId .AND. ;
                           SZ2->Z2_TIPO == cTipBk .AND. STRZERO(VAL(SZ2->Z2_BANCO),3) == cPortado
            
         IF SZ2->Z2_DATAPGT == dPgto .AND. SZ2->Z2_CODFOR = cCodFor .AND. SZ2->Z2_LOJFOR = cLojFor .AND. SZ2->Z2_TIPOPES = cTipoPes
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

               MsUnlock()
            ENDIF    
         ENDIF
            
         dbSkip()
      EndDo
   EndIf
Next	
Return Nil


Static Function ValidaMrk(lRet,cPgto)
IF CTOD(cPgto) >= dDataBase
   lRet := !lRet
ELSE
   u_MsgLog(,"Data de pgto deste lote é inferior a data base do sistema", "W")
   lRet := .F.
ENDIF   
Return lRet
