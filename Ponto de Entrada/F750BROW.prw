#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TbiConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ F750BROW ºAutor  ³Marcos B. Abrahao   º Data ³  02/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada para criar opções na tela de Funcões      º±±
±±º          ³ Contas a Pagar                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function F750BROW() 
Local aRotY

aRotY := { {OemToAnsi("Integração Liq. "+ALLTRIM(SM0->M0_NOME)), "U_BKFINA02",  0, 2 },;
           {OemToAnsi("Alterar Liq. "+ALLTRIM(SM0->M0_NOME)),    "U_BKFINA04(.F.)", 0, 2 },;
           {OemToAnsi("Excluir Liq. "+ALLTRIM(SM0->M0_NOME)),    "U_BKFINA03",  0, 2 },;
           {OemToAnsi("Consultar Liq. "+ALLTRIM(SM0->M0_NOME)),  "U_BKFINA04(.T.)", 0, 2 },;
           {OemToAnsi("Imprimir Liq. "+ALLTRIM(SM0->M0_NOME)),   "U_BKFINR05",  0, 2 },;
           {OemToAnsi("Gerar Borderô "+ALLTRIM(SM0->M0_NOME)),   "U_BKFINA14",  0, 2 },;
           {OemToAnsi("Retorno Borderô "+ALLTRIM(SM0->M0_NOME)), "U_BKBXBNCO",  0, 2 }}
           
AADD( aRotina, {OemToAnsi("Liquidos "+ALLTRIM(SM0->M0_NOME)), aRotY, 0, 4 } )

AADD( aRotina, {OemToAnsi("Imprimir Titulos"), "U_BKFINR06", 0, 4 } )
AADD( aRotina, {OemToAnsi("Anexar Arq. "+ALLTRIM(SM0->M0_NOME)),   "U_BKANXA01('1','SE2')", 0, 4 } )
AADD( aRotina, {OemToAnsi("Abrir Anexos "+ALLTRIM(SM0->M0_NOME)),  "U_BKANXA02('1','SE2')", 0, 4 } )
AADD( aRotina, {OemToAnsi("Alterar Emissão"),  "U_BKFINA10", 0, 4 } )
IF SM0->M0_CODIGO <> "01"
	AADD( aRotina, {OemToAnsi("Incluir DNF na BK"),"U_BKFINA18", 0, 4 } )
ENDIF
AADD( aRotina, {OemToAnsi("Baixa BK - RET BANCO"),  "U_BKFINA22", 0, 4 } )

//aRotx := aClone(aRotina)

Return Nil



// Alteração de data de emissao de titulo
User Function BKFINA10()
Local _sAlias	:= Alias()
Local oDlg01,aButtons := {},lOk := .F.
Local aAreaAtu	:= GetArea()
Local nSnd,nTLin := 12

Local dEmis := SE2->E2_EMISSAO

IF EMPTY(SE2->E2_XXCTRID)
	MsgStop("Selecione um titulo de integração liq. "+ALLTRIM(SM0->M0_NOME), "Atenção")
	RestArea(aAreaAtu)
	Return
ENDIF

IF SE2->E2_SALDO <> SE2->E2_VALOR
	MsgStop("Titulo já sofreu baixas", "Atenção")
	RestArea(aAreaAtu)
	Return
ENDIF

Define MsDialog oDlg01 Title "BKFINA10-Alt. dados Tit. a Pagar: "+SE2->E2_NUM  From 000,000 To 280,600 Of oDlg01 Pixel

nSnd := 30
@ nSnd,010 Say "Data de emissão do titulo:" Size 080,008 Pixel Of oDlg01
@ nSnd,100 MsGet dEmis Picture "@E"         Size 040,008 Pixel Of oDlg01
nSnd += nTLin


ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| oDlg01:End()}, , aButtons)
If ( lOk )
	IF dEmis <> SE2->E2_EMISSAO
		RecLock("SE2",.F.)
		SE2->E2_EMISSAO := dEmis
		SE2->E2_EMIS1   := dEmis
		msUnlock()
	ENDIF
EndIf

RestArea( aAreaAtu )
dbSelectArea(_sAlias)

Return lOk



// Incluir DNF na BK
User Function BKFINA18()
Local sAlias	  
Local aAreaAtu	  
Local aParametros := {}
Local cForn       := ""
Local cLoja       := "01"
Local cProd       := ""
Local cCCus       := ""
Local cHist       := ""
Local cRetorno    := ""
Local dData       := dDataBase
Local cUsuario    := __cUserId
Local cSuper	  := "" 

If !EMPTY(cUsuario)
	PswOrder(1) 
	PswSeek(cUsuario) 
	aUser  := PswRet(1)
	If !EMPTY(aUser[1,11])
		cSuper := SUBSTR(aUser[1,11],1,6)
	EndIf   
EndIf


If !("DNF" $ SE2->E2_HIST)

    If msgYesNo('Confirma a inclusão de DNF para este título na Empresa BK?')	
    
		If SM0->M0_CODIGO == "01"      // BK
			cForn := "000084"
			cProd := "29104004"  
			cCCus := "000000001"
		ElseIf SM0->M0_CODIGO == "02"  // HF
			cForn := "001570"
			cProd := "29104004"
			cCCus := "000000001"
		ElseIf SM0->M0_CODIGO == "04"  // ESA
			cForn := "000082"
			cProd := "11301011"
			cCCus := "000000001"
		ElseIf SM0->M0_CODIGO == "06"  // BKDAHER SUZANO
			cForn := "000906"
			cProd := "11301017"
			cCCus := "163000240"
		ElseIf SM0->M0_CODIGO == "07"  // JUSTFOFTWARE
			cForn := "001126"
			cProd := "11301015"
			cCCus := "000000001"
		ElseIf SM0->M0_CODIGO == "08"  // BHG CAMPINAS
			cForn := "001271"
			cProd := "11301018"
			cCCus := "000000214"
		ElseIf SM0->M0_CODIGO == "09"  // BHG OSASCO
			cForn := "001272"
			cProd := "11301019"
			cCCus := "000000215"
		ElseIf SM0->M0_CODIGO == "10"  // BKDAHER TABOAO DA SERRA
			cForn := "001450"
			cProd := "11301020"
			cCCus := "211000316"
		ElseIf SM0->M0_CODIGO == "11"  // BKDAHER LIMEIRA
			cForn := "001505"
			cProd := "11301022"
			cCCus := "215000318"
		ElseIf SM0->M0_CODIGO == "12"  // BK CORRETORA
			cForn := "002702"
			cProd := "12102007"
			cCCus := "000000005"
		ElseIf SM0->M0_CODIGO == "14"  // Consorcio Nova Balsa
			cForn := "003148"
			cProd := "11301027"
			cCCus := "302000508"
		ElseIf SM0->M0_CODIGO == "15"  // BHG Interior 3
			cForn := "004491"
			cProd := "11301031"
			cCCus := "305000554"
		Endif	
	
		cForn := SuperGetMV("MV_XXPRDBK",.F.,cForn)
		cProd := SuperGetMV("MV_XXFORBK",.F.,cProd)
		cCCus := SuperGetMV("MV_XXCCUBK",.F.,cCCus)
	
		cHist := "Aporte: "+TRIM(SM0->M0_NOME)+" "+TRIM(SE2->E2_PREFIXO)+" "+TRIM(SE2->E2_NUM)+" - R$ "+ALLTRIM(STR(SE2->E2_VALOR,15,2))
		aParametros := {"01","01",cHist,cForn,cLoja,cProd,cCCus,SE2->E2_VALOR,SE2->E2_VENCREA,cUsuario,cSuper}
		// PARA TESTAR 
		//aParametros := {"01","01","Aporte: BKDAHER SUZANO LF 054854LPM - R$ 127.74","000906","01","11301017","163000240",127.74,CTOD("06/02/2018"),"000000",""}
		  
		// Inicia o Job
		sAlias	  := Alias()
		aAreaAtu  := GetArea()
	    nRecNo    := RECNO()
  		dDataBase := SE2->E2_VENCREA		
	    
		MsgRun("incluindo DNF na empresa BK, aguarde...","",{|| CursorWait(), cRetorno := StartJob("U_BKFINJ18",GetEnvServer(),.T.,aParametros) ,CursorArrow()})
	   	//MsgRun("incluindo DNF na empresa BK, aguarde...","",{|| CursorWait(), cRetorno := U_BKFINJ18(aParametros) ,CursorArrow()})
	
		RestArea( aAreaAtu )
		dbSelectArea(sAlias)
	    dbGoTo(nRecNo)
	    dDataBase := dData
		
		IF EMPTY(cRetorno) .OR. SUBSTR(cRetorno,1,3) <> "DNF" 
			IF EMPTY(cRetorno)
				cRetorno := "Erro ao incluir a DNF, contate o desenvolvimento"
			ENDIF
		   MsgStop(cRetorno, "Atenção")
		ELSE
		   MsgInfo(cRetorno+" incluída na empresa BK", "Atenção")
			RecLock("SE2",.F.)
			IF UPPER(TRIM(SE2->E2_HIST)) == "DEPTO PESSOAL"
				SE2->E2_HIST := cRetorno+" D. Pessoal"  
			ELSE
				SE2->E2_HIST := cRetorno+" "+SE2->E2_HIST   
				//"Depto PessoalDNF000000000"
			ENDIF		
			MsUnlock()
		ENDIF
	EndIf    
ELSE
   MsgStop("Esta DNF já foi incluída na empresa BK: "+TRIM(SE2->E2_HIST), "Atenção")
ENDIF	


//RestArea( aAreaAtu )
//dbSelectArea(sAlias)

Return



// Esta funcao e a funcao chamada pela funcao StartJob
// Erros desta função somente aparecem no log do console do servidor
User Function BKFINJ18(_aParametros)

Local _cEmpresa  := _aParametros[1] // Usar o paramixb
Local _cFilial   := _aParametros[2]
Local _cHist     := _aParametros[3]
Local _cForn     := _aParametros[4]
Local _cLoja     := _aParametros[5]
Local _cProd     := _aParametros[6]
Local _cCCus     := _aParametros[7]
Local _nValor    := _aParametros[8]
Local _dDtEmis   := _aParametros[9]
Local _cUsuario  := _aParametros[10]
Local _cSuper 	 := _aParametros[11]

Local aCabec     := {}
Local aItem      := {}
Local aItens     := {}
Local cRetorno   := ""

Private cErro      := ""
Private cNFiscal := ""
Private cSerie   := "DNF
Private lMsErroAuto := .F.

//RpcSetType(3)


// Prepara a empresa BK
//PREPARE ENVIRONMENT EMPRESA _cEmpresa FILIAL _cFilial TABLES "SF1","SD1"
RpcSetEnv( _cEmpresa, _cFilial )

//dDataBase := _dData

dbSelectArea("SX6")                      
U_NumSf1()  


//#INCLUDE "RWMAKE.CH" #INCLUDE "TBICONN.CH"User Function tMata140()Local nOpc := 0 private aCabec:= {}private aItens:= {}private aLinha:= {}Private lMsErroAuto := .F.  
//aCabec := 	{	{'F1_TIPO'	,'N'		,NIL},;		{'F1_FORMUL','S'		,NIL},;		{'F1_DOC'	,"999999"    	,NIL},;		{'F1_SERIE','   '		,NIL},;		{'F1_EMISSAO',dDataBase	,NIL},;		{'F1_FORNECE','000002'	,NIL},;		{'F1_LOJA'	,'01'		,NIL},;		{'F1_COND','001'		,NIL} }				
//aItens :=	{	{'D1_COD'	,"PA02"			,NIL},;		{'D1_UM'	,'UN'			,NIL},;				{'D1_QUANT',1			,NIL},;		{'D1_VUNIT',10000			,NIL},;		{'D1_TOTAL',10000			,NIL},;		{'D1_PEDIDO','000009'			,NIL},;		{'D1_ITEMPC','0001'			,NIL},;		{'D1_LOCAL','01'			,NIL}	}AAdd(aLinha,aItens)nOpc := 3MSExecAuto({|x,y,z| MATA140(x,y,z)}, aCabec, aItens, nOpc)     If lMsErroAuto      mostraerro()Else   Alert("Ponto de entrada MATA140 executado com sucesso!")		EndIfReturn

           
// {"F1_FILIAL"    , xFilial("SF1") },;
aCabec := {{"F1_TIPO"      , "N" , NIL},;
           {"F1_FORMUL"    , "N" , NIL },;
           {"F1_DOC"       , cNFiscal, NIL },;
           {"F1_SERIE"     , cSerie, NIL },;
           {"F1_EMISSAO"   , _dDtEmis , NIL },;
           {"F1_DTDIGIT"   , _dDtEmis , NIL },;
           {"F1_FORNECE"   , _cForn, NIL },;
           {"F1_LOJA"      , _cLoja, NIL },;
           {"F1_EST"       , "SP", NIL },;
           {"F1_ESPECIE"   , "", NIL },;
           {"F1_XXUSER"    , _cUsuario, NIL },;
           {"F1_XXUSERS"   , _cSuper, NIL }}          

//           {"F1_COND"      , "000" } }
     
           
aItem  := {{"D1_COD"    , _cProd, NIL },;
           {"D1_UM"     , "PC", NIL },;
           {"D1_QUANT"  , 1, NIL },;
           {"D1_VUNIT"  , _nValor, NIL },;
           {"D1_TOTAL"  , _nValor, NIL },;
           {"D1_XXHIST" , _cHist, NIL },; 
           {"D1_CC"     , _cCCus, NIL },; 
           {"D1_EMISSAO", _dDtEmis , NIL },; 
           {"D1_DTDIGIT", _dDtEmis , NIL },;
           {"D1_LOCAL"  , "01", NIL } } 

//           {"D1_CF"     , "999" },; 
//           {"D1_TP"     , "GG" },; 
//           {"D1_RATEIO" , "2" },; 

/*
		   {"D1_TIPO"   , "N" },;
           {"D1_SERIE"  , cSerie },;
           {"D1_DOC"    , cNFiscal },;
           {"D1_FORNECE", _cForn },;
           {"D1_LOJA"   , _cLoja },;
*/
  
AADD(aItens,aItem)

lMsErroAuto := .F.    
          
MSExecAuto({|x,y,z| Mata140(x,y,z)},aCabec,aItens,3,2) //Inclusao

If lMsErroAuto
  //  MostraErro() 
 	// Função que retorna o evento de erro na forma de um array
	aAutoErro := GETAUTOGRLOG()
	
	//cErro := ALLTRIM((XCONVERRLOG(aAutoErro)))
	cErro := ""
	For _nX := 1 To Len(aAutoErro) 
		cErro += aAutoErro[_nX]+CHR(13)+CHR(10)
	NEXT
	Conout("BKFINJ18 - Erro em MSExecAuto: "+cErro)
	cRetorno := cErro
	lRet := .F.
Else
	cRetorno := "DNF"+cNFiscal
	Conout(DTOC(date())+' '+TIME()+" BKFINJ18 - Pré-nota "+cNFiscal+ " incluída - Retorno da função: "+cRetorno)
EndIf

//dDataBase := dDataAt

//RESET ENVIRONMENT 

RpcClearEnv()

//RpcSetEnv( cEmpAnt, cFilAnt )

   
Return cRetorno



/*/
+-----------------------------------------------------------------------
| Função | XCONVERRLOG | Autor | Arnaldo R. Junior | Data | |
+-----------------------------------------------------------------------
| Descrição | CONVERTE O ARRAY AAUTOERRO EM TEXTO CONTINUO. |
+-----------------------------------------------------------------------
| Uso | Curso ADVPL |
+-----------------------------------------------------------------------
/*/

/*
STATIC FUNCTION XCONVERRLOG(aAutoErro)
LOCAL cRet := ""
LOCAL nX := 1
FOR nX := 1 to Len(aAutoErro)
	cRet += aAutoErro[nX]+CHR(13)+CHR(10)
NEXT nX
RETURN cRet
*/
