#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TbiConn.ch"

/*/{Protheus.doc} F750BROW
BK - Ponto de Entrada para criar opções na tela de Funcões Contas a Pagar
@Return
@author Marcos B. Abrahao
@since 02/10/09
@version P12
/*/

User Function F750BROW() 
Local aRotY
Local cEmpName := FWEmpName(cEmpAnt)
aRotY := { {OemToAnsi("Integração Liq. "+cEmpName), "U_BKFINA02",  0, 2 },;
           {OemToAnsi("Alterar Liq. "+cEmpName),    "U_BKFINA04(.F.)", 0, 2 },;
           {OemToAnsi("Excluir Liq. "+cEmpName),    "U_BKFINA03",  0, 2 },;
           {OemToAnsi("Consultar Liq. "+cEmpName),  "U_BKFINA04(.T.)", 0, 2 },;
           {OemToAnsi("Imprimir Liq. "+cEmpName),   "U_BKFINR05",  0, 2 },;
           {OemToAnsi("Gerar Borderô "+cEmpName),   "U_BKFINA14",  0, 2 },;
           {OemToAnsi("Retorno Borderô "+cEmpName), "U_BKBXBNCO",  0, 2 }}
           
AADD( aRotina, {OemToAnsi("Liquidos "+cEmpName), aRotY, 0, 4 } )
AADD( aRotina, {OemToAnsi("Imprimir Titulos"), "U_BKFINR06", 0, 4 } )
AADD( aRotina, {OemToAnsi("Resumo Diário"), "U_BKFINR33", 0, 4 } )
AADD( aRotina, {OemToAnsi("Anexos Pré-Nota"),  "U_BKF750A", 0, 4 } )
AADD( aRotina, {OemToAnsi("Conhecimento"),  "MSDOCUMENT", 0, 4 } )
//AADD( aRotina, {OemToAnsi("Anexar Arq. "+cEmpName),   "U_BKANXA01('1','SE2')", 0, 4 } )
//AADD( aRotina, {OemToAnsi("Abrir Anexos "+cEmpName),  "U_BKANXA02('1','SE2')", 0, 4 } )
AADD( aRotina, {OemToAnsi("Alt Emissão/Bco"),  "U_BKF750B", 0, 4 } )
AADD( aRotina, {OemToAnsi("Alt Centro de Custos"), "U_BKF750C", 0, 4 } )
IF SM0->M0_CODIGO <> "01"
	AADD( aRotina, {OemToAnsi("Incluir DNF na BK"),"U_BKFINA18", 0, 4 } )
ENDIF
AADD( aRotina, {OemToAnsi("Baixa BK - RET BANCO"), "U_BKFINA22", 0, 4 } )
AADD( aRotina, {OemToAnsi("Empréstimos BK"),  "U_BKFINA31", 0, 4 } )

//aRotx := aClone(aRotina)

Return Nil



// Vizualizar Anexos-Pré Nota
// 04/09/2020
User Function BKF750A()
Local aArea	:= GetArea()
Local nRecF1:= 0
dbSelectArea("SF1")
dbSetOrder(1)
If dbSeek(xFilial("SF1")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA+SE2->E2_TIPO,.F.)
	nRecF1 := RecNo()
	MsDocument("SF1",nRecF1,6)
EndIf

RestArea( aArea )
Return Nil


// Alteração de data de emissao de titulo e Portador
User Function BKF750B()
Local _sAlias	:= Alias()
Local oDlg01,aButtons := {},lOk := .F.
Local aAreaAtu	:= GetArea()
Local nSnd,nTLin := 12

Local dEmis  := SE2->E2_EMISSAO
Local cPort  := SE2->E2_PORTADO

IF EMPTY(SE2->E2_XXCTRID)
	u_MsgLog("BKF750B","Selecione um titulo de integração liq. "+FWEmpName(cEmpAnt),"E")
	RestArea(aAreaAtu)
	Return
ENDIF

IF SE2->E2_SALDO <> SE2->E2_VALOR
	u_MsgLog("BKF750B","Titulo já sofreu baixas","E")
	RestArea(aAreaAtu)
	Return
ENDIF

Define MsDialog oDlg01 Title "BKF750B - Alt. dados Tit. a Pagar: "+SE2->E2_NUM  From 000,000 To 280,600 Of oDlg01 Pixel

nSnd := 35
@ nSnd,010 Say "Data de emissão do titulo:" Size 080,009 Pixel Of oDlg01
@ nSnd,100 MsGet dEmis Picture "@E"         Size 040,009 Pixel Of oDlg01

nSnd += nTLin
@ nSnd,010 Say "Portador:" Size 080,008 Pixel Of oDlg01
@ nSnd,100 MsGet cPort Picture "999"       Size 025,009 Pixel Of oDlg01


ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| oDlg01:End()}, , aButtons)
If ( lOk )
	IF dEmis <> SE2->E2_EMISSAO .OR. SE2->E2_PORTADO <> cPort
		RecLock("SE2",.F.)
		SE2->E2_EMISSAO := dEmis
		SE2->E2_EMIS1   := dEmis
		SE2->E2_PORTADO := cPort
		msUnlock()
	ENDIF
EndIf

RestArea( aAreaAtu )
dbSelectArea(_sAlias)

Return lOk



// Alteração de Centro de Custos - E2_CCUSTO (Usado nas PAs de Reforma de Balsa)
User Function BKF750C()
Local _sAlias	:= Alias()
Local oDlg01,aButtons := {},lOk := .F.
Local aAreaAtu	:= GetArea()
Local nSnd,nTLin := 15

Private cCusto := SE2->E2_CCUSTO
Private cHist  := SE2->E2_HIST

Define MsDialog oDlg01 Title "BKF750C - Alt. dados Tit. a Pagar: "+SE2->E2_NUM  From 000,000 To 280,600 Of oDlg01 Pixel

nSnd := 35
@ nSnd,010 Say "Centro de Custo:" Size 080,009 Pixel Of oDlg01
@ nSnd,100 MsGet cCusto Picture "999999999"  Size 040,009 HASBUTTON F3 "CTT" VALID ExistCpo("CTT",cCusto) Pixel Of oDlg01

nSnd += nTLin
@ nSnd,010 Say "Histórico:" Size 080,008 Pixel Of oDlg01
@ nSnd,100 MsGet cHist Picture "@!"  Size 100,009 Pixel Of oDlg01


ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| oDlg01:End()}, , aButtons)
If ( lOk )
	IF cCusto <> SE2->E2_CCUSTO .OR. cHist <> SE2->E2_HIST
		RecLock("SE2",.F.)
		SE2->E2_CCUSTO := cCusto
		SE2->E2_HIST   := ALLTRIM(cHist)
		u_MsgLog("BKF750C","Centro de Custo do título "+SE2->E2_NUM+" alterado para "+cCusto)
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

    If u_MsgLog("BKFINA18",'Confirma a inclusão de DNF para este título na Empresa BK?',"Y")
    
		If SM0->M0_CODIGO == "01"      // BK
			cForn := u_cFornBK()
			cProd := U_MVXCUSBK()
			cCCus := "000000001"
		ElseIf SM0->M0_CODIGO == "02"  // MMDK
			cForn := "001570"
			cProd := U_MVXCUSBK()
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
		ElseIf SM0->M0_CODIGO == "14"  // BALSA NOVA
			cForn := "003148"
			cProd := "11301027"
			cCCus := "302000508"
		ElseIf SM0->M0_CODIGO == "15"  // BHG INTERIOR 3
			cForn := "004491"
			cProd := "11301031"
			cCCus := "305000554"
		ElseIf SM0->M0_CODIGO == "16"  // CONSORCIO MOOVE
			cForn := u_cFornBK()
			cProd := "11301032"  // CRIAR NO PLANO DE CONTAS E NO CADASTRO DE PRODUTOS
			cCCus := "386000609"
		ElseIf SM0->M0_CODIGO == "17"  // DMAF
			cForn := u_cFornBK()
			cProd := "11301033"  // CRIAR NO PLANO DE CONTAS E NO CADASTRO DE PRODUTOS
			cCCus := "000000001"
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
	    
		u_WaitLog(,{|| cRetorno := StartJob("U_BKFINJ18",GetEnvServer(),.T.,aParametros) },"Incluindo DNF na empresa BK, aguarde...")
	
		RestArea( aAreaAtu )
		dbSelectArea(sAlias)
	    dbGoTo(nRecNo)
	    dDataBase := dData
		
		IF EMPTY(cRetorno) .OR. SUBSTR(cRetorno,1,3) <> "DNF" 
			IF EMPTY(cRetorno)
				cRetorno := "Erro ao incluir a DNF, contate o desenvolvimento"
			ENDIF
		    u_MsgLog(,cRetorno, "E")
		ELSE
		    u_MsgLog(,cRetorno+" incluída na empresa BK", "W")
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
   u_MsgLog(,"Esta DNF já foi incluída na empresa BK: "+TRIM(SE2->E2_HIST), "W")
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
//aItens :=	{	{'D1_COD'	,"PA02"			,NIL},;		{'D1_UM'	,'UN'			,NIL},;				{'D1_QUANT',1			,NIL},;		{'D1_VUNIT',10000			,NIL},;		{'D1_TOTAL',10000			,NIL},;		{'D1_PEDIDO','000009'			,NIL},;		{'D1_ITEMPC','0001'			,NIL},;		{'D1_LOCAL','01'			,NIL}	}AAdd(aLinha,aItens)nOpc := 3 MSExecAuto({|x,y,z| MATA140(x,y,z)}, aCabec, aItens, nOpc)     If lMsErroAuto      mostraerro()Else   Alert("Ponto de entrada MATA140 executado com sucesso!")		EndIfReturn

           
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

	cRetorno := u_LogMsExec("BKFINJ18","Problemas no Pré-Documento de Entrada "+cDoc+" "+cSerie)

	lRet := .F.
Else
	cRetorno := "DNF"+cNFiscal
	u_MsgLog("BKFINJ18","Pré-nota "+cNFiscal+ " incluída - Retorno da função: "+cRetorno)
EndIf

RpcClearEnv()
  
Return cRetorno

