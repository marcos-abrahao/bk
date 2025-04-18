#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN040INC
BK - Criar Nota de D�bito Cliente
@Return
@author Adilson do Prado
@since 17/09/2019
@version P12
/*/
//-------------------------------------------------------------------

USER Function FIN040INC(nRecCND,nValor,nRecCXN)  	 
Local aAreas    := GetArea()
Local aArray 	:= {}
Local cProxNum  := "000000001"
Local cNatureza := "0000000057"
Local dVenci	:= dDataBase + 30
Local dVenciR	:= DATAVALIDA(dVenci)
Local cCliente 	:= ""
Local cLoja    	:= ""
Local aRetNDC   := {}
Local cDesNDC  	:= ""
Local aSZ2      := {}
Local dEmissao 	:= dDataBase
Local cPerg 	:= "F040INC"
Local cQuery 	:= ""
Local cNumMed   := "" 
Local cRev      := "" 
Local cContra   := "" 
Local cCompe    := ""
Local cPlan     := ""
Local nI        := 0
Local nColDel   := 9
Local cMunComp  := ""

Private aParam		:= {}
Private aRet		:= {}
Private cPict       := "@E 99,999,999,999.99"
Private lMsErroAuto := .F. 

Default nRecCND 	:= 0
Default nValor		:= 0
Default nRecCXN 	:= 0

//Posiciona na Medi��o
IF nRecCND > 0
	dbSelectArea("CND")
	dbGoTo(nRecCND)
	
	cNumMed := CND->CND_NUMMED
	cContra := CND->CND_CONTRA
	cRev    := CND->CND_REVISA
	cCompe  := SUBSTR(CND->CND_COMPET,4,4)+SUBSTR(CND->CND_COMPET,1,2)
	cPlan   := CND->CND_NUMERO

	dbSelectArea("CXN")
	dbSetOrder(1)
	dbSeek(xFilial("CXN")+CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMMED,.T.)
	Do While xFilial("CXN") == CXN->CXN_FILIAL .AND. CXN->(CXN_CONTRA+CXN_REVISA+CXN_NUMMED) == CND->(CND_CONTRA+CND_REVISA+CND_NUMMED) .AND. !EOF()
		If CXN->CXN_CHECK 
			cCliente := CXN->CXN_CLIENT
			cLoja    := CXN->CXN_LJCLI
			Exit
		EndIf
		dbSkip()
	EndDo

	IF Empty(cCliente)
		cCliente := CND->CND_CLIENT
		cLoja    := CND->CND_LOJACL
	ENDIF

	dbSelectArea("CNE")
	CNE->(dbSetOrder(4))
	CNE->(dbSeek(xFilial("CNE")+cNumMed))
	CNE->(dbSetOrder(1))

	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))

	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+CNE->CNE_PEDIDO))

	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	SC6->(DbSeek(xFilial("SC6")+CNE->CNE_PEDIDO)) 

	dbSelectArea("CNA")
	SC6->(dbSetOrder(1))
	SC6->(DbSeek(xFilial("CNA")+cContra+cRev+CPlan)) 

	cRev     := CND->CND_REVISA
	cDesNDC  := ""
	dEmissao := dDataBase //SC5->C5_EMISSAO
	If nValor == 0
		nValor 	 := CND->CND_XXVLND
	EndIf
	cMunComp := IIF(!EMPTY(CNA->CNA_XXMUN),TRIM(CNA->CNA_XXMUN)+" - "+CND->CND_COMPET,"")
ELSE
 
	ValidPerg(cPerg)

	If !Pergunte(cPerg,.T.)
		Return
	Endif

	cContra	 := MV_PAR01
	dVenci   := MV_PAR02
	nValor   := MV_PAR03
	dEmissao := dDataBase
	
	DBSELECTAREA("CN9")
	CN9->(DBSETORDER(1))
	If CN9->(DBSEEK(xFILIAL("CN9")+cContra,.T.))
		Do While CN9->(!eof())  .AND. ALLTRIM(CN9->CN9_NUMERO) == ALLTRIM(cContra) 
			If CN9->CN9_SITUAC <> '10' .AND. CN9->CN9_SITUAC <> '09'
			 	cRev 	 := CN9->CN9_REVISA
				cCliente := CN9->CN9_XCLIEN
				cLoja 	 := CN9->CN9_XLOJA
			EndIf
			CN9->(DBSKIP()) 
		EndDo

		If !SelCli(cContra,cRev,@cCliente,@cLoja)
			Return
		EndIf
		//cCliente := U_CNCF3(cContra,cRev,@cCliente,@cLoja)
	Else
		dbSelectArea("CTT")
		If dbSeek(xFilial("CTT")+cContra,.F.)
			aParam := {}
			cCliente := SPACE(TamSx3("A1_COD")[1])
			cLoja	 := SPACE(TamSx3("A1_LOJA")[1])
			aAdd( aParam,{1,RetTitle("A1_COD") ,cCliente,"","","SA1","",0,.T.})
			aAdd( aParam,{1,RetTitle("A1_LOJA"),cLoja   ,"","",""	,"",0,.T.})  
			If !BkFin40(cPerg,@cCliente,@cLoja)
				Return
			EndIf
		Else
			u_MsgLog(,"Centro de Custos n�o encontrado","E")
			Return
		Endif
	Endif


	cCompe   := SUBSTR(DTOS(dEmissao),1,6)
	
ENDIF

dVenciR  := DATAVALIDA(dVenci)

IF nValor > 0

	Processa ( {|| aRetNDC  := U_DescrNDC(nRecCND,cContra,@cCompe,@nValor,cMunComp,@dVenci)})
	
	dVenciR := DATAVALIDA(dVenci)
	cDesNDC := aRetNDC[1]
	aSZ2    := aRetNDC[2]
	
    IF !EMPTY(cDesNDC)
		cQuery := "SELECT TOP 1 E1_NUM "
		cQuery += " FROM "+RETSQLNAME("SE1")+" SE1"
		cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"'"
		cQuery += " AND E1_PREFIXO='ND' AND E1_TIPO='NDC' AND D_E_L_E_T_ = '' " 
		cQuery += " ORDER BY E1_NUM DESC" 
	 
		If SELECT("QSE1") > 0 
			QSE1->(dbCloseArea())
		EndIf
	
		TCQUERY cQuery NEW ALIAS "QSE1"
		
		DBSELECTAREA("QSE1")
		cProxNum := STRZERO(VAL(QSE1->E1_NUM)+1,9)
		QSE1->(dbCloseArea())
	
		aArray := { { "E1_PREFIXO"  , "ND"  , NIL },;
	            { "E1_NUM"      , cProxNum  , NIL },;
	            { "E1_TIPO"     , "NDC"     , NIL },;
	            { "E1_NATUREZ"  , cNatureza , NIL },;
	            { "E1_CLIENTE"  , cCliente  , NIL },;
	            { "E1_LOJA"     , cLoja 	, NIL },;
	            { "E1_XXCUSTO"  , cContra 	, NIL },;
	            { "E1_XXNDDES"  , cDesNDC	, NIL },;
	            { "E1_XXREV"    , cRev	 	, NIL },;
	            { "E1_XXMED"	, cNumMed 	, NIL },;
	            { "E1_XXCOMPE"	, cCompe 	, NIL },;
	            { "E1_EMISSAO"  , dEmissao 	, NIL },;
	            { "E1_VENCTO"   , dVenci	, NIL },;
	            { "E1_VENCREA"  , dVenciR	, NIL },;
	            { "E1_VALOR"    , nValor	, NIL }}
	 
		MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 3)  // 3 - Inclusao, 4 - Altera��o, 5 - Exclus�o
	
		If lMsErroAuto		
			u_LogMsExec("FIN040INC","Erro na grava��o da NDC "+cProxNum)
		Else	
			If !Empty(nRecCND)
				RecLock("CND")
				CND->CND_XXNDC  := cProxNum
				CND->CND_XXVLND := nValor
				CND->(MsUnLock())
			EndIf
			
			// Gravar SZ2
			For nI := 1 To Len(aSZ2)
				nColDel := LEN(aSZ2[nI])
			    IF !aSZ2[nI,nColDel] .AND. aSZ2[nI,8] > 0
			    	SZ2->(dbGoTo(aSZ2[nI,8]))
			    	RecLock("SZ2",.F.)
			    	SZ2->Z2_NDC    := cProxNum
			    	SZ2->Z2_VALNDC := aSZ2[nI,7]
			    	MsUnlock()
			    ENDIF
			Next
			
	   		IF u_MsgLog(,"Nota de D�bito: "+cProxNum+" incluida com sucesso, deseja Imprimir?","Y")
	        	u_WaitLog(,{|| U_BKFINR24(),"Gerando p�gina web..."})
	     	ENDIF
		EndIf
	ENDIF
ENDIF

RestArea(aAreas)

Return


Static Function BkFin40(cPerg,cCliente,cLoja)
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,"Cliente",@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg      ,.T.         ,.T.))
	lRet     := .T.
	cCliente := mv_par01
	cLoja    := mv_par02
Endif
Return lRet



//CHAMADA NO MENU
USER FUNCTION FN40INCMNU
	U_FIN040INC()
RETURN NIL



User Function DescrNDC(nRecCND,cContra,cCompe,nValor,cMunComp,dVenci) //Cria Descri��o da Nota de Debito
    Local aaCampos	:= {"NOME","INICIO","FINAL","QTDE","RDV","VALOR"} //Vari�vel contendo o campo edit�vel no Grid
    Local aBotoes	:= {}         //Vari�vel onde ser� incluido o bot�o para a legenda
    Local lOk		:= .F.
    Local cRet 		:= ""
	Local cCrLf     := Chr(13) + Chr(10)
	Local _iX       := 0
	Local _iY		:= 0
	Local cPict     := "@E 99,999,999,999.99"
    
    Default cMunComp    := ""
    Private aCabecalho  := {}         //Variavel que montar� o aHeader do grid
    Private aColsEx 	:= {}         //Vari�vel que receber� os dados
    Private oLista                    //Declarando o objeto do browser
    Private oPanel01
    Private oRefer, oVenc	
    Private cRefer      := PAD(cMunComp,100)
    Private cDescUni    := ""//PAD("",10000)
    Private nTaxa		:= 0
    Private oSTotal
    Private nsTotal 	:= 0
    Private oTotal
    Private bfDeleta    := {|| fDeleta()}
    Private nColDel     := 9 
    Private nTotal      := nValor
    Private nTotalOri   := nValor

    DEFINE MSDIALOG oDlg TITLE "Descri��o da Nota de D�bito - Contrato "+cContra FROM 000, 000  TO 520, 700  PIXEL
    
    	@00,00 MSPANEL oPanel01 SIZE 500, 700 OF oDlg

        //chamar a fun��o que cria a estrutura do aHeader
        CriaCabec()

		@ 035, 010 Say  oSay Prompt "Vencimento:" Size  40, 10 Of oPanel01 Pixel
		@ 034, 040 MSGet  oVenc Var  dVenci Size  50,10 Of oPanel01 Pixel Picture "@E"  

		@ 035, 100 Say  oSay Prompt "Compet�ncia:" Size  40, 10 Of oPanel01 Pixel
		@ 034, 140 MSGet  oVenc Var  cCompe Size  30,10 Of oPanel01 Pixel Picture "@9"  

		@ 050, 010 Say  oSay Prompt "Referencia:" Size  40, 10 Of oPanel01 Pixel
		@ 049, 040 MSGet  oRefer Var  cRefer Size  300,10 Of oPanel01 Pixel Picture "@!"  
		

        //Monta o browser com inclus�o, remo��o e atualiza��o
 		@ 065, 010 Say  oSay Prompt "Descri��o Detalhada:" Size  400, 10 Of oPanel01 Pixel

        oLista := MsNewGetDados():New(075, 010, 165, 340, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aACampos,1, 999, "U_SOMANDC()", "", "Eval(bfDeleta)", oPanel01, aCabecalho, aColsEx,"U_SOMANDC()")

        //oBrw1  := MsNewGetDados():New( 32 , 10, nBrwAlt, nBrwLarg,nOpc                  ,�Eval(bLinOk)�,�AllwaysTrue()�,�,{�PRODUTO�,�QUANT�,�ALMOX�,�ENDEREC�,�NUMSERI�},0,99,�AllwaysTrue()�,,�Eval(bfDeleta)�,oDlgSep,aHead1,aCols1)


        //Alinho o grid para ocupar todo o meu formul�rio
        // oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

        //Ao abrir a janela o cursor est� posicionado no meu objeto
        //oLista:oBrowse:SetFocus()

		@ 170, 010 Say  oSay Prompt "Descri��o �nica ou opcional:" Size  400, 10 Of oPanel01 Pixel
		@ 180, 010 Get oDesc Var  cDescUni Memo Size  330, 040 Of oPanel01 Pixel

		@ 225, 150 Say  oSay Prompt "Sub Total:" Size  100, 10 Of oPanel01 Pixel
		@ 225, 250 MSGet oSTotal Var nSTotal Size 080, 10 Of oPanel01 Pixel WHEN .F. Picture cPict  

		@ 240, 010 Say  oSay Prompt "Taxa:" Size  100, 10 Of oPanel01 Pixel
		@ 240, 040 MSGet oTaxa Var  nTaxa Size  50, 10 Of oPanel01 Pixel Picture "@E 9,999.99"  Valid (U_SOMANDC()) ;
		
		@ 240, 150 Say  oSay Prompt "Total da Nota D�bito:" Size  100, 10 Of oPanel01 Pixel
		@ 240, 250 MSGet oTotal Var  nTotal Size  080, 10 Of oPanel01 Pixel  WHEN .F. Picture cPict 

        //Carregar os itens que ir�o compor o conteudo do grid
        Carregar(nRecCND,cContra,cCompe)

		
 	ACTIVATE MSDIALOG oDlg CENTERED Valid(ValidaNDC(@cCompe)) ON INIT EnchoiceBar(oDlg, {|| lOk := .T. ,U_SOMANDC(),oDlg:End() }, {|| lOk := .F. ,oDlg:End() },,aBotoes)

	IF ( lOk )
		lOk := .F.
		nValor := nTotal
		IF !EMPTY(cDescUni) .AND. LEN(oLista:aCols) == 0
			cRet := "2|"+ALLTRIM(cRefer)+"|"+ALLTRIM(TRANSFORM(nTaxa,cPict))+"|"+ALLTRIM(TRANSFORM(nSTotal,cPict))+cCrLf 
			cRet += cDescUni+cCrLf 
		ELSEIF EMPTY(cDescUni) .AND. LEN(oLista:aCols) > 0
			cRet := "1|"+ALLTRIM(cRefer)+"|"+ALLTRIM(STR(nTaxa,14,2))+"|"+ALLTRIM(TRANSFORM(nSTotal,cPict))+cCrLf 
			//{"IMG","NOME","INICIO","FINAL","QTDE","RDV","VALOR","DELETE"} 
			FOR _IX:= 1 TO LEN(oLista:aCols)
			    IF !oLista:aCols[_IX,nColDel]  .AND. oLista:aCols[_IX,7] > 1
					cRet +=ALLTRIM(oLista:aCols[_IX,2])+"|"+DTOC(oLista:aCols[_IX,3])+"|"+DTOC(oLista:aCols[_IX,4])+"|"+ALLTRIM(STR(oLista:aCols[_IX,5],14,2))+"|"+ALLTRIM(oLista:aCols[_IX,6])+"|"+ALLTRIM(TRANSFORM(oLista:aCols[_IX,7],cPict))+cCrLf
			    ENDIF
			NEXT _IX 
		ELSE 
			//{"IMG","NOME","INICIO","FINAL","QTDE","RDV","VALOR","DELETE"} 
			_iY  := 0 
			cRet := ""
			FOR _IX:= 1 TO LEN(oLista:aCols)
			    IF !oLista:aCols[_IX,nColDel]  //.AND. oLista:aCols[_IX,7] > 1
					cRet += ALLTRIM(oLista:aCols[_IX,2])+"|"
					cRet += DTOC(oLista:aCols[_IX,3])+"|"
					cRet += DTOC(oLista:aCols[_IX,4])+"|"
					cRet += ALLTRIM(STR(oLista:aCols[_IX,5],14,2))
					cRet += "|"+ALLTRIM(oLista:aCols[_IX,6])
					cRet += "|"+ALLTRIM(TRANSFORM(oLista:aCols[_IX,7],cPict))
					//cRet += "|"+ALLTRIM(TRANSFORM(oLista:aCols[_IX,8],cPict))
					cRet += cCrLf
					_iY++
			    ENDIF
			NEXT _IX 
			cRet := "3|"+ALLTRIM(cRefer)+"|"+ALLTRIM(STR(nTaxa,14,2))+"|"+ALLTRIM(TRANSFORM(nSTotal,cPict))+"|"+ALLTRIM(STR(_iY,0))+cCrLf ;
					+ cRet
			cRet += cDescUni+cCrLf 
		ENDIF

	ENDIF
  
Return {cRet,oLista:aCols}


Static Function CriaCabec()
   
 Aadd(aCabecalho, {;
                  "",;			//X3Titulo()
                  "IMAGEM",;  	//X3_CAMPO
                  "@BMP",;		//X3_PICTURE
                  3,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  ".F.",;		//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "V",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  "",;			//X3_WHEN
                  "V"})			//
                   
    Aadd(aCabecalho, {;
                  "Nome",;		//X3Titulo()
                  "NOME",;  	//X3_CAMPO
                  "@!",;		//X3_PICTURE
                  50,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "NAOVAZIO()",;//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",;			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN

    Aadd(aCabecalho, {;
                  "Inicio",;	//X3Titulo()
                  "INICIO",;  	//X3_CAMPO
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
                  "Final",;		//X3Titulo()
                  "FINAL",;  	//X3_CAMPO
                  "",;			//X3_PICTURE
                  8,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "D",;			//X3_TIPO
                  "",;			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "CTOD('')",;	//X3_RELACAO
                  ""})			//X3_WHEN
 

  Aadd(aCabecalho, {;
                  "Qtde",;		//X3Titulo()
                  "QTDE",;  	//X3_CAMPO
                  "@E 999.99",;	//X3_PICTURE
                  6,;			//X3_TAMANHO
                  2,;			//X3_DECIMAL
                  "NAOVAZIO().AND.POSITIVO()",;			//X3_VALID
                  "",;			//X3_USADO
                  "N",;			//X3_TIPO
                  "",;			//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "1",;			//X3_RELACAO
                  ""})			//X3_WHEN

    Aadd(aCabecalho, {;
                  "N� RDV",;	//X3Titulo()
                  "RDV",;  		//X3_CAMPO
                  "@!",;		//X3_PICTURE
                  30,;			//X3_TAMANHO
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
                  "Valor",;	//X3Titulo()
                  "VALOR",; //X3_CAMPO
                  "@E 999,999,999.99",;		//X3_PICTURE
                  14,;		//X3_TAMANHO
                  2,;		//X3_DECIMAL
                  "POSITIVO() .AND. U_SOMANDC()",;		//X3_VALID
                  "",;		//X3_USADO
                  "N",;		//X3_TIPO
                  "",;		//X3_F3
                  "R",;		//X3_CONTEXT
                  "",;		//X3_CBOX
                  "",;		//X3_RELACAO
                  ""})		//X3_WHEN

/*
Aadd(aCabecalho, {;
                  "Vl Unit.",;	//X3Titulo()
                  "VUNIT",; //X3_CAMPO
                  "@E 999,999,999.99",;		//X3_PICTURE
                  14,;		//X3_TAMANHO
                  2,;		//X3_DECIMAL
                  "",;		//X3_VALID
                  "",;		//X3_USADO
                  "N",;		//X3_TIPO
                  "",;		//X3_F3
                  "R",;		//X3_CONTEXT
                  "",;		//X3_CBOX
                  "",;		//X3_RELACAO
                  ""})		//X3_WHEN
*/

 Aadd(aCabecalho, {;
                  "Registro",;	//X3Titulo()
                  "RECNO",; //X3_CAMPO
                  "",;	    //X3_PICTURE
                  14,;		//X3_TAMANHO
                  0,;		//X3_DECIMAL
                  "",;		//X3_VALID
                  "",;		//X3_USADO
                  "N",;		//X3_TIPO
                  "",;		//X3_F3
                  "R",;		//X3_CONTEXT
                  "",;		//X3_CBOX
                  "",;		//X3_RELACAO
                  ".F."})	//X3_WHEN

nColDel := Len(aCabecalho)+1

Return


Static Function Carregar(nRecCND,cContra,cCompe)
Local cSql := ""                 
Local cAliasSZ2 := GetNextAlias()
Local nMesComp  := 0
Local nAnoComp  := 0

If nRecCND > 0

	// Buscar solicita��es de at� 3 meses atras
	nMesComp := VAL(SUBSTR(cCompe,5,2))
	nAnoComp := VAL(SUBSTR(cCompe,1,4))
	
	nMesComp := nMesComp - 3
	If nMesComp < 1
	   nMesComp := 12 + nMesComp
	   nAnoComp--
	EndIf

	cSql := "SELECT Z2_NOME,Z2_VALOR,Z2_DATAEMI,R_E_C_N_O_ AS Z2_RECNO "
	cSql += "FROM SZ2010 SZ2 "
	cSql += "WHERE SZ2.D_E_L_E_T_='' AND Z2_CODEMP='"+SM0->M0_CODIGO+"' AND Z2_TIPO='SOL' AND Z2_STATUS <> 'D' "
	//cSql += " AND SUBSTRING(Z2_DATAEMI,1,6)='"+cCompe+"' "
	cSql += " AND SUBSTRING(Z2_DATAEMI,1,6)>='"+STRZERO(nAnoComp,4)+STRZERO(nMesComp,2)+"'"
	cSql += " AND Z2_CC='"+cContra+"' AND Z2_NDC = ' ' "
	cSql += "ORDER BY Z2_NOME "
		
	TCQUERY cSql NEW ALIAS (cAliasSZ2)
		
	dbSelectArea(cAliasSZ2)
	(cAliasSZ2)->(DbGotop()) 
	Do WHile !(cAliasSZ2)->(EOF())
		aadd(aColsEx,{"",(cAliasSZ2)->Z2_NOME,STOD((cAliasSZ2)->Z2_DATAEMI),CTOD(""),1,SPACE(30),(cAliasSZ2)->Z2_VALOR,(cAliasSZ2)->Z2_RECNO,.F.})
	
		(cAliasSZ2)->(dbSkip())
	EndDo	 
	 
	 
	//{"IMG","NOME","INICIO","FINAL","QTDE","RDV","VALOR","DELETE"} 
	
    //aadd(aDescricao,{"",PAD("",100),CTOD(""),CTOD(""),1,PAD("",100),0})
	 
	//    For i := 1 to len(aDescricao)
	//  		aadd(aColsEx,{aDescricao[i,1],aDescricao[i,2],aDescricao[i,3],aDescricao[i,4],aDescricao[i,5],aDescricao[i,6],aDescricao[i,7],.F.})
	//    Next
	
    //Setar array do aCols do Objeto.
    oLista:SetArray(aColsEx,.T.)
	
	
	// SOmar os valores
	U_SOMANDC()
	
    //Atualizo as informa��es no grid
    oLista:Refresh()

EndIf

Return

Static Function ValidaNDC(cCompe)
Local lOK := .T.
Local nColLst := 0
Local _IX

FOR _IX:= 1 TO LEN(oLista:aCols)
	IF !oLista:aCols[_IX,nColDel] .AND. oLista:aCols[_IX,7]>0 
		nColLst++
	ENDIF
NEXT 

IF Empty(cRefer)
	MSGSTOP("Referencia n�o informado. Verifique!")
	lOK := .F.
ENDIF

IF Empty(cDescUni) .AND. nColLst == 0
	MSGSTOP("Descri��o Detalhada ou Descri�o �nica n�o informada. Verifique!")
	lOK := .F.
ENDIF

IF VAL(SUBSTR(cCompe,1,4)) < 2021 .OR. VAL(SUBSTR(cCompe,5,2)) < 1 .OR. VAL(SUBSTR(cCompe,5,2)) > 12
	MSGSTOP("Compet�ncia incorreta, o formato deve ser AAAAMM. Verifique!")
	lOK := .F.
ENDIF

//IF !Empty(cDescUni) .AND. nColLst <> 0
//	MSGSTOP("Descri�o Detalhada e Descri�o �nica informada.Informar apenas uma das descri��es. Verifique!")
//	lOK := .F.
//ENDIF

   
IF nTaxa > 0 
	IF TRANSFORM((nSTotal*nTaxa)+nSTotal,cPict) <> TRANSFORM(nTotal,cPict)
		MSGSTOP("Valor Total divergende. Verifique!")
		lOK := .F.
	ENDIF 
ELSE
	IF TRANSFORM((nSTotal),cPict) <> TRANSFORM(nTotal,cPict)
		MSGSTOP("Valor Total divergende. Verifique!")
		lOK := .F.
	ENDIF 
ENDIF
Return lOK 


Static Function fDeleta()
oLista:aCols[oLista:nAt, nColDel] := !oLista:aCols[oLista:nAt, nColDel]
oLista:Refresh()
U_SOMANDC()
Return()


User Function SOMANDC()
Local lOK := .T.
Local nSomaNDC := 0
Local _iX := 0
//oLista:ForceRefresh()

FOR _IX:= 1 TO LEN(oLista:aCols)
	IF !oLista:aCols[_IX,nColDel] 
		If oLista:nAt == _iX .AND. READVAR() == "M->VALOR" 
			nSomaNDC += M->VALOR
		Else	
			nSomaNDC += oLista:aCols[_IX,7]
		EndIf
	ENDIF
NEXT 

If nSomaNDC > 0
	nSTotal := nSomaNDC
	
	IF nTaxa > 0
		nTotal := nSTotal * nTaxa
		nTotal += nSTotal
	ELSE
		nTotal := nSTotal
	ENDIF
Else
	If nTaxa > 0 
		nTotal := nTotalOri / nTaxa
		nTotal += nTotalOri
	Else
		nTotal := nTotalOri
	EndIf
EndIf


OSTotal:Refresh()
OTotal:Refresh()
 
Return lOK



Static Function  ValidPerg(cPerg)

Local aArea		:= GetArea()
Local aRegistros:= {}
Local i,j
Default cPerg	:= "F040INC"

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Contrato:","Contrato:" ,"Contrato:" ,"mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"02","Vencimento:","Vencimento:" ,"Vencimento:" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Valor:","Valor:" ,"Valor:" ,"mv_ch3","N",14,2,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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



Static Function SelCli(cContra,cRev,cCliente,cLoja)

Local cQuery 	:= ""
Local j			:= 0
Local aAreaIni	:= GetArea()
Local lOk		:= .F.
Local aButtons	:= {}

Private aSize   := MsAdvSize(,.F.,400)
Private aObjects:= { { 450, 450, .T., .T. } }
Private aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aPosObj := MsObjSize( aInfo, aObjects, .T. )
private aRotina := {{"","",0,1},{"","",0,2},{"","",0,2},{"","",0,2},{"","",0,2}}
Private aHeader	:= {}


cQuery  := "SELECT CNC_CLIENT,CNC_LOJACL,A1_NOME,A1_MUN,A1_CGC "+CRLF
cQuery  += "FROM "+RETSQLNAME("CNC")+" CNC "+CRLF
cQuery  += "LEFT JOIN "+RETSQLNAME("SA1")+" SA1 ON "+CRLF
cQuery  += " CNC_CLIENT = A1_COD AND CNC_LOJACL = A1_LOJA AND A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.D_E_L_E_T_ = '' "+CRLF
cQuery  += "WHERE CNC.D_E_L_E_T_ = '' AND CNC_FILIAL = '"+xFilial("CNC")+"' "+CRLF
cQuery  += " AND CNC_NUMERO = '"+ALLTRIM(cContra)+"' AND CNC_REVISA = '"+ALLTRIM(cRev)+"' "+CRLF
cQuery  += "ORDER BY CNC_CLIENT,CNC_LOJACL "

u_LogMemo("FIN040INC.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QCNC"

DbSelectArea("QCNC")
dbGoTop()
If Lastrec() == 1
	cCliente := QCNC->CNC_CLIENT
	cLoja	 := QCNC->CNC_LOJACL
	QCNC->(DbCloseArea())
	RestArea(aAreaIni)
	Return lOk:= .T.
EndIf

aStruc := dbStruct()
		
oTmpTb := FWTemporaryTable():New( "QCNC1" )	
oTmpTb:SetFields( aStruc )
oTmpTb:Create()

DbSelectArea("QCNC")
dbGoTop()
Do While !eof()
	DbSelectArea("QCNC1")
    RecLock("QCNC1",.T.)
	For j:=1 to QCNC->(FCount())
		FieldPut(j,QCNC->(FieldGet(j)))
	Next
     
	DbSelectArea("QCNC")
	dbSkip()
EndDo
QCNC->(DbCloseArea())

aadd(aHeader, DefAHeader("QCNC1","CNC_CLIENT"))
aadd(aHeader, DefAHeader("QCNC1","CNC_LOJACL"))
aadd(aHeader, DefAHeader("QCNC1","A1_NOME"))
aadd(aHeader, DefAHeader("QCNC1","A1_MUN"))
aadd(aHeader, DefAHeader("QCNC1","A1_CGC"))

DEFINE MSDIALOG oDlg TITLE "Selecione o Cliente" From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE aSize[6],aSize[5]
oPanelLeft:Align := CONTROL_ALIGN_LEFT

_oGetDbSint := MsGetDb():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], 2, "AllwaysTrue()", "AllwaysTrue()",,,,,,"AllwaysTrue()","QCNC1")
_oGetDbSint:oBrowse:BlDblClick := {|| lOk:=.T., oDlg:End()}        

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T.,oDlg:End()}, {||oDlg:End()},, aButtons)

If ( lOk ) //.AND. nPos > 0
	cCliente := QCNC1->CNC_CLIENT
	cLoja	 := QCNC1->CNC_LOJACL
Endif

oTmpTb:Delete() 

RestArea(aAreaIni)

Return lOk



Static Function DefAHeader(_cAlias,_cCampo)

Return {Alltrim(RetTitle(_cCampo)),;
        _cCampo,;
        GetSx3Cache( _cCampo , "X3_PICTURE" ),;
        GetSx3Cache( _cCampo , "X3_TAMANHO" ),;
        GetSx3Cache( _cCampo , "X3_DECIMAL" ),;
        GetSx3Cache( _cCampo , "X3_VALID" ),;
        "",;
        GetSx3Cache( _cCampo , "X3_TIPO" ),;
        GetSx3Cache( _cCampo , "X3_PICTVAR" ),;
        _cAlias,;
        "R"}

