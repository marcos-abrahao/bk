#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN040INC
BK - Criar Nota de Débito Cliente
@Return
@author Adilson do Prado
@since 17/09/2019
@version P12
/*/
//-------------------------------------------------------------------

USER Function FIN040INC(nRecCND)  	 
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
Local nValor 	:= 0
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

Private cPict       := "@E 99,999,999,999.99"
Private lMsErroAuto := .F. 

Default nRecCND := 0

//Posiciona na Medição
IF nRecCND > 0
	DBSELECTAREA("CND")
	dbGoTo(nRecCND)
	
	cNumMed := CND->CND_NUMMED
	cContra := CND->CND_CONTRA
	cRev    := CND->CND_REVISA
	cCompe  := SUBSTR(CND->CND_COMPET,4,4)+SUBSTR(CND->CND_COMPET,1,2)
	cPlan   := CND->CND_NUMERO
	
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+CND->CND_CLIENT+CND->CND_LOJACL))

	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+CND->CND_PEDIDO))

	dbSelectArea("SC6")
	SC6->(dbSetOrder(1))
	SC6->(DbSeek(xFilial("SC6")+CND->CND_PEDIDO)) 

	dbSelectArea("CNA")
	SC6->(dbSetOrder(1))
	SC6->(DbSeek(xFilial("CNA")+cContra+cRev+CPlan)) 

	cCliente := CND->CND_CLIENT
	cLoja    := CND->CND_LOJACL
	cRev     := CND->CND_REVISA
	cDesNDC  := ""
	dEmissao := dDataBase //SC5->C5_EMISSAO
	nValor 	 := CND->CND_XXVLND
	cMunComp := IIF(!EMPTY(CNA->CNA_XXMUN),TRIM(CNA->CNA_XXMUN)+" - "+CND->CND_COMPET,"")
ELSE
 
	ValidPerg(cPerg)

	If !Pergunte(cPerg,.T.)
		Return
	Endif

	cContra	 := MV_PAR01
	
	DBSELECTAREA("CN9")
	CN9->(DBSETORDER(1))
	IF CN9->(DBSEEK(xFILIAL("CN9")+cContra,.T.))
		Do While CN9->(!eof())  .AND. ALLTRIM(CN9->CN9_NUMERO) == ALLTRIM(cContra) 
			IF CN9->CN9_SITUAC <> '10' .AND. CN9->CN9_SITUAC <> '09'
			 	cRev 	 := CN9->CN9_REVISA
				cCliente := CN9->CN9_CLIENT
				cLoja 	 := CN9->CN9_LOJACL
			ENDIF
			CN9->(DBSKIP()) 
		ENDDO
	ELSE
		MSGSTOP("Contrato não encontrado")
		Return
	Endif

	dEmissao := dDataBase
	dVenci   := MV_PAR02
	nValor   := MV_PAR03
	cCompe   := SUBSTR(DTOS(dEmissao),1,6)
	
ENDIF

dVenciR  := DATAVALIDA(dVenci)

IF nValor > 0

	Processa ( {|| aRetNDC  := U_DescrNDC(nRecCND,cContra,cCompe,@nValor,cMunComp,@dVenci)})
	
	dVenciR := DATAVALIDA(dVenci)
	cDesNDC := aRetNDC[1]
	aSZ2    := aRetNDC[2]
	
    IF !EMPTY(cDesNDC)
		cQuery := "SELECT TOP 1 E1_NUM "
		cQuery += " FROM "+RETSQLNAME("SE1")+" SE1"
		cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"'"
		cQuery += " AND E1_PREFIXO='ND' AND E1_TIPO='NDC'" 
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
	 
		MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
	
		If lMsErroAuto		
			MsgStop("Erro na gravação.")	
			MostraErro()
		Else	
			If !Empty(nRecCND)
				dbSelectArea("CND")
				RecLock("CND")
				CND->CND_XXNDC  := cProxNum
				CND->CND_XXVLND := nValor
				MsUnLock()
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
			
	   		IF MsgYesNo("Nota de Débito: "+cProxNum+" incluida com sucesso, deseja Imprimir?")
	        	U_BKFINR24()
	     	ENDIF
		EndIf
	ENDIF
ENDIF

RestArea(aAreas)

Return

//CHAMADA NO MENU
USER FUNCTION FN40INCMNU
	U_FIN040INC()
RETURN NIL



User Function DescrNDC(nRecCND,cContra,cCompe,nValor,cMunComp,dVenci) //Cria Descrição da Nota de Debito
    Local aaCampos	:= {"NOME","INICIO","FINAL","QTDE","RDV","VALOR"} //Variável contendo o campo editável no Grid
    Local aBotoes	:= {}         //Variável onde será incluido o botão para a legenda
    Local lOk		:= .F.
    Local cRet 		:= ""
	Local cCrLf     := Chr(13) + Chr(10)
	Local _iX       := 0
	Local cPict     := "@E 99,999,999,999.99"
    
    Default cMunComp    := ""
    Private aCabecalho  := {}         //Variavel que montará o aHeader do grid
    Private aColsEx 	:= {}         //Variável que receberá os dados
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

    DEFINE MSDIALOG oDlg TITLE "Descrição da Nota de Débito - Contrato "+cContra FROM 000, 000  TO 520, 700  PIXEL
    
    	@00,00 MSPANEL oPanel01 SIZE 500, 700 OF oDlg

        //chamar a função que cria a estrutura do aHeader
        CriaCabec()

		@ 032, 010 Say  oSay Prompt "Vencimento:" Size  40, 10 Of oPanel01 Pixel
		@ 030, 040 MSGet  oVenc Var  dVenci Size  50,10 Of oPanel01 Pixel Picture "@E"  

		@ 047, 010 Say  oSay Prompt "Referencia:" Size  40, 10 Of oPanel01 Pixel
		@ 045, 040 MSGet  oRefer Var  cRefer Size  300,10 Of oPanel01 Pixel Picture "@!"  
		

        //Monta o browser com inclusão, remoção e atualização
 		@ 065, 010 Say  oSay Prompt "Descrição Detalhada:" Size  400, 10 Of oPanel01 Pixel

        oLista := MsNewGetDados():New(075, 010, 165, 340, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aACampos,1, 999, "U_SOMANDC()", "", "Eval(bfDeleta)", oPanel01, aCabecalho, aColsEx)

        //oBrw1  := MsNewGetDados():New( 32 , 10, nBrwAlt, nBrwLarg,nOpc                  ,’Eval(bLinOk)’,’AllwaysTrue()’,”,{“PRODUTO”,”QUANT”,”ALMOX”,”ENDEREC”,”NUMSERI”},0,99,’AllwaysTrue()’,,’Eval(bfDeleta)’,oDlgSep,aHead1,aCols1)


        //Alinho o grid para ocupar todo o meu formulário
        // oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

        //Ao abrir a janela o cursor está posicionado no meu objeto
        //oLista:oBrowse:SetFocus()

		@ 170, 010 Say  oSay Prompt "Descrição Única:" Size  400, 10 Of oPanel01 Pixel
		@ 180, 010 Get oDesc Var  cDescUni Memo Size  330, 040 Of oPanel01 Pixel

		@ 225, 150 Say  oSay Prompt "Sub Total:" Size  100, 10 Of oPanel01 Pixel
		@ 225, 250 MSGet oSTotal Var nSTotal Size 080, 10 Of oPanel01 Pixel WHEN .F. Picture cPict  

		@ 240, 010 Say  oSay Prompt "Taxa:" Size  100, 10 Of oPanel01 Pixel
		@ 240, 040 MSGet oTaxa Var  nTaxa Size  50, 10 Of oPanel01 Pixel Picture "@E 9,999.99"  Valid (U_SOMANDC()) ;
		
		@ 240, 150 Say  oSay Prompt "Total da Nota Débito:" Size  100, 10 Of oPanel01 Pixel
		@ 240, 250 MSGet oTotal Var  nTotal Size  080, 10 Of oPanel01 Pixel  WHEN .F. Picture cPict 

        //Carregar os itens que irão compor o conteudo do grid
        Carregar(nRecCND,cContra,cCompe)

		
 	ACTIVATE MSDIALOG oDlg CENTERED Valid(ValidaNDC()) ON INIT EnchoiceBar(oDlg, {|| lOk := .T. ,U_SOMANDC(),oDlg:End() }, {|| lOk := .F. ,oDlg:End() },,aBotoes)

	IF ( lOk )
		lOk := .F.
		nValor := nTotal
		IF !EMPTY(cDescUni)
			cRet := "2|"+ALLTRIM(cRefer)+"|"+ALLTRIM(TRANSFORM(nTaxa,cPict))+"|"+ALLTRIM(TRANSFORM(nSTotal,cPict))+cCrLf 
			cRet += cDescUni+cCrLf 
		ELSE
			cRet := "1|"+ALLTRIM(cRefer)+"|"+ALLTRIM(STR(nTaxa,14,2))+"|"+ALLTRIM(TRANSFORM(nSTotal,cPict))+cCrLf 
			//{"IMG","NOME","INICIO","FINAL","QTDE","RDV","VALOR","DELETE"} 
			FOR _IX:= 1 TO LEN(oLista:aCols)
			    IF !oLista:aCols[_IX,nColDel]  .AND. oLista:aCols[_IX,7] > 1
					cRet +=ALLTRIM(oLista:aCols[_IX,2])+"|"+DTOC(oLista:aCols[_IX,3])+"|"+DTOC(oLista:aCols[_IX,4])+"|"+ALLTRIM(STR(oLista:aCols[_IX,5],14,2))+"|"+ALLTRIM(oLista:aCols[_IX,6])+"|"+ALLTRIM(TRANSFORM(oLista:aCols[_IX,7],cPict))+cCrLf
			    ENDIF
			NEXT _IX 
		ENDIF
	ENDIF
  
Return {cRet,oLista:aCols}


Static Function CriaCabec()
   
 Aadd(aCabecalho, {;
                  "",;//X3Titulo()
                  "IMAGEM",;  //X3_CAMPO
                  "@BMP",;		//X3_PICTURE
                  3,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  ".F.",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",; 			//X3_F3
                  "V",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  "",;			//X3_WHEN
                  "V"})			//
                   
    Aadd(aCabecalho, {;
                  "Nome",;	//X3Titulo()
                  "NOME",;  	//X3_CAMPO
                  "@!",;		//X3_PICTURE
                  30,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "NAOVAZIO()",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",;		//X3_F3
                  "R",;			//X3_CONTEXT
                  "",;			//X3_CBOX
                  "",;			//X3_RELACAO
                  ""})			//X3_WHEN

    Aadd(aCabecalho, {;
                  "Inicio",;	//X3Titulo()
                  "INICIO",;  	//X3_CAMPO
                  "",;		//X3_PICTURE
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
                  "Final",;	//X3Titulo()
                  "FINAL",;  	//X3_CAMPO
                  "",;		//X3_PICTURE
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
                  "Qtde",;	//X3Titulo()
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
                  "Nº RDV",;	//X3Titulo()
                  "RDV",;  	//X3_CAMPO
                  "@!",;		//X3_PICTURE
                  30,;			//X3_TAMANHO
                  0,;			//X3_DECIMAL
                  "",;			//X3_VALID
                  "",;			//X3_USADO
                  "C",;			//X3_TIPO
                  "",;		//X3_F3
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

	// Buscar solicitações de até 3 meses atras
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
	
    //Atualizo as informações no grid
    oLista:Refresh()

EndIf

Return

Static Function ValidaNDC()
Local lOK := .T.
Local nColLst := 0

FOR _IX:= 1 TO LEN(oLista:aCols)
	IF !oLista:aCols[_IX,nColDel] .AND. oLista:aCols[_IX,7]>0 
		nColLst++
	ENDIF
NEXT 

IF Empty(cRefer)
	MSGSTOP("Referencia não informado. Verifique!")
	lOK := .F.
ENDIF

IF Empty(cDescUni) .AND. nColLst == 0
	MSGSTOP("Descrição Detalhada ou Descrião Única não informada. Verifique!")
	lOK := .F.
ENDIF

IF !Empty(cDescUni) .AND. nColLst <> 0
	MSGSTOP("Descrião Detalhada e Descrião Única informada.Informar apenas uma das descrições. Verifique!")
	lOK := .F.
ENDIF

   
IF nTaxa > 0 
	IF TRANSFORM((nSTotal*nTaxa),cPict) <> TRANSFORM(nTotal,cPict)
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


USER Function SOMANDC()
Local lOK := .T.
Local nSomaNDC := 0
Local _iX := 0

FOR _IX:= 1 TO LEN(oLista:aCols)
	IF !oLista:aCols[_IX,nColDel]  
		nSomaNDC += oLista:aCols[_IX,7]
	ENDIF
NEXT 

If nSomaNDC > 0
	nSTotal := nSomaNDC
	
	IF nTaxa > 0
		nTotal := nSTotal * nTaxa
	ELSE
		nTotal := nSTotal
	ENDIF
Else
	If nTaxa > 0 
		nSTotal := nTotalOri / nTaxa
	Else
		nSTotal := nTotalOri
	EndIf
	nTotal  := nTotalOri
EndIf


OSTotal:Refresh()
OTotal:Refresh()
 
Return lOK



Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

Default cPerg := "F040INC"

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Contrato:","Contrato:" ,"Contrato:" ,"mv_ch1","C",15,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CN9","S","",""})
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
