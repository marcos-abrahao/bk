#include "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#include "TopConn.ch"

/*/
BKESTA03 - BK -Inclusão Termo Transferencia / Responsabilidade / Recebimento controle de Estoque

@author Adilson do Prado
@since 18/01/2023
@version P12
@return Nil
/*/

User Function BKESTA03()
Local cFiltra     := ""

Private cCadastro	:= "Inclusão Termo Transferencia / Responsabilidade / Recebimento"
Private cDelFunc	:= ".F." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString 	:= "SZV"
Private aIndexSz  	:= {}
Private aFixeFX     := {}
Private bFiltraBrw	:= { || FilBrowse(cString,@aIndexSz,@cFiltra) } 
Private aCores  := {}
Private aRotina	:= {}
Private oListSZV
Private oListFUN
Private oListDevFU

PUBLIC _cCCSZW := ""

u_MsgLog("BKESTA03")

AADD(aCores,{"ALLTRIM(SZV->ZV_TM) =='01'","BR_VERDE"})
AADD(aCores,{"ALLTRIM(SZV->ZV_TM) =='02' .AND. SZV->ZV_RECEBEU<>'S'","BR_LARANJA"})
AADD(aCores,{"ALLTRIM(SZV->ZV_TM) =='02' .AND. SZV->ZV_RECEBEU=='S'","BR_PRETO"})
AADD(aCores,{"ALLTRIM(SZV->ZV_TM) =='03'","BR_VERMELHO"})

AADD(aRotina,{"Pesquisa"		       	 		,"AxPesquisa"   ,0,1})
AADD(aRotina,{"Visualizar"		        		,"AxVisual"     ,0,2})
AADD(aRotina,{"Incluir Nota Trans."				,"U_INCLSZV"    ,0,3})
AADD(aRotina,{"Entrega Uniforme"				,"U_RECBUNISZV" ,0,4})
AADD(aRotina,{"Devolução Uniforme"				,"U_DEVOUNISZV" ,0,4})
AADD(aRotina,{"Impressão Termos"				,"U_BUSCSZV"    ,0,4})
AADD(aRotina,{"Excluir Termos"		    		,"U_EXCLUISZV"  ,0,4})
AADD(aRotina,{"Relatorio de Saldo"				,"U_RELSALDSZV" ,0,4})
AADD(aRotina,{"Confirma Receb. Funcionário"		,"U_BXRECEBEU" 	,0,4})
AADD(aRotina,{"Baixa Resp. Recebimento"			,"U_BXRESDEV" 	,0,4})
AADD(aRotina,{"Planilha Excel Entrega Uniforme"	,"U_BKESTA04"   ,0,4})
AADD(aRotina,{"Legenda"			        		,"U_SZVLEG"     ,0,4})


dbSelectArea(cString)
dbSetOrder(1)
//+------------------------------------------------------------
//| Cria o filtro na MBrowse utilizando a função FilBrowse
//+------------------------------------------------------------
Eval(bFiltraBrw)

dbSelectArea(cString)
dbGoTop()

mBrowse(6,1,22,75,cString,aFixeFX,,,,,aCores)

//+------------------------------------------------
//| Deleta o filtro utilizado na função FilBrowse
//+------------------------------------------------
EndFilBrw(cString,aIndexSz)

RETURN NIL


User Function SZVLEG()
Local aCores2 := {}
Local cLegenda := ""

cLegenda	:= "Legenda de Cores"

AADD(aCores2,{"BR_VERDE"  	, "Entrada NF Estoque"})
AADD(aCores2,{"BR_LARANJA"	, "Envio para o Funcionário"})
AADD(aCores2,{"BR_PRETO"	, "Confirmado a Entrega para o Funcionário"})
AADD(aCores2,{"BR_VERMELHO"	, "Devolução do Funcionário"})

BrwLegenda(cLegenda,"Inclusão Termo Transferencia / Responsabilidade / Recebimento / Devolução",aCores2)

RETURN NIL


USER FUNCTION INCLSZV
Local lOk		 := .F.
Local nSnd       := 15
Local nTLin      := 15
Local oDlg01     as Object
Local oButInv    as Object
Local aButtons   := {}

PRIVATE aItemSZV   := {}
PRIVATE cCusto     := SPACE(9)
PRIVATE cDESCTT	 := SPACE(80)
PRIVATE cENDSAID   := SPACE(250)
PRIVATE cENDENTR   := SPACE(250)
PRIVATE cRespDecl  := SPACE(80)
PRIVATE cCPFDecl   := SPACE(11)
PRIVATE dDataD	 := dDATABASE
PRIVATE cGestor  := SPACE(80)
PRIVATE cLOCSZW  := SPACE(6)
PRIVATE cDSZW  := SPACE(80)
PRIVATE cDCLIENT := SPACE(80)


    AADD(aItemSZV,{"","","",0,0,SPACE(20),CTOD(""),0,"","","",""})


    Define MsDialog oDlg01 Title "Incluir Termo de Transferencia / Responsabilidade de Uso" From 000,000 To 510,830 Of oDlg01 Pixel
	
	@ 000,000 MSPANEL oPanelLeft OF oDlg01 SIZE 490,825 
	oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
	@ nSnd,010 SAY "Data de Emissão:" SIZE 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet dDataD Picture "@E"  Size 060,010 Pixel OF oPanelLeft WHEN .T.

	@ nSnd,130 MsGet cDCLIENT Picture '@!' Size 280,010 Pixel OF oPanelLeft PIXEL WHEN .F. 
	nSnd += nTLin

	@ nSnd,010 Say "Custo / Contrato:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cCusto Picture '@!' F3 "CTT" Size 060,010 Pixel OF oPanelLeft WHEN .T. VALID(!Empty(cCusto) .AND. VALIDCONTR(cCusto))

	@ nSnd,130 MsGet cDESCTT Picture '@!' Size 150,010 Pixel OF oPanelLeft PIXEL WHEN .F. 

	@ nSnd,285 SAY "Gestor:" SIZE 080,010 Pixel OF oPanelLeft
	@ nSnd,310 MsGet cGestor SIZE 100,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .T.
	nSnd += nTLin

	@ nSnd,010 SAY "Local Estoque:" SIZE 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cLOCSZW Picture '@!' F3 "SZW" Size 060,010 Pixel OF oPanelLeft WHEN .T. VALID(VALIDSZW(cLOCSZW))
	@ nSnd,130 MsGet cDSZW Picture '@!' Size 280,010 Pixel OF oPanelLeft PIXEL WHEN .F. 
	nSnd += nTLin

	@ nSnd,010 Say "Endereço Saida:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cENDSAID Picture '@!' Size 350,010 Pixel OF oPanelLeft WHEN .T.
	nSnd += nTLin
	
	@ nSnd,010 Say "Endereço Entrega:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cENDENTR Picture "@E"  Size 350,010 Pixel OF oPanelLeft WHEN .T.
	nSnd += nTLin
		
	@ nSnd,010 Say "Resp. Declaração" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cRespDecl Picture '@!' Size 200,010 Pixel OF oPanelLeft WHEN .T.
	
	@ nSnd,265 Say "CPF Resp. Declaração:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,330 MsGet cCPFDecl SIZE 080,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .T.
	nSnd += nTLin

    @ nSnd,010 Button oButInv    Prompt "Seleciona Nota\Produtos"  Size 100, 12 Pixel Action ( BKESTA03A() ) ;
    Message "Seleciona Produtos" Of oPanelLeft
	nSnd += nTLin
	
	@ nSnd, 010 LISTBOX oListSZV FIELDS HEADER "Item","Cod. Produto","Descrição","Quantidade","Saldo","Cod. CA","Validade CA","Valor Total",'Nota Fiscal',"Serie","Fornece","Loja" SIZE 400,085  OF oPanelLeft PIXEL 
	
	oListSZV:SetArray(aItemSZV)
	oListSZV:bLine := {|| {	aItemSZV[oListSZV:nAt][1],;
							aItemSZV[oListSZV:nAt][2],;
							aItemSZV[oListSZV:nAt][3],;
							aItemSZV[oListSZV:nAt][4],;
							aItemSZV[oListSZV:nAt][5],;   
							aItemSZV[oListSZV:nAt][6],;                                                     
							aItemSZV[oListSZV:nAt][7],;
							aItemSZV[oListSZV:nAt][8],;
							aItemSZV[oListSZV:nAt][9],;
							aItemSZV[oListSZV:nAt][10],;                                                                                    
							aItemSZV[oListSZV:nAt][11],;                                                                                    
							aItemSZV[oListSZV:nAt][12]}}

	oListSZV:bLDblClick := {|| EDITCNR2(@aItemSZV),oListSZV:DrawSelect(), }
	
	ACTIVATE MSDIALOG oDlg01 CENTERED Valid(ValidaSZV()) ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

	If ( lOk )
		lOk:=.F.
		If u_MsgLog("INCLSZV","Confirma a inclusão e geração do Termo de Transferencia / Responsabilidade de Uso?","Y")
			IF U_GRAVSZV()
				U_PRINTSZV()
			ENDIF
		ENDIF
	Endif

RETURN lOk



STATIC FUNCTION VALIDCONTR(cNumContr)
LOCAL lOK := .F.

cDCLIENT := ""
cDESCTT	 := ""
cGestor  := ""


DBSELECTAREA("CN9")
CN9->(DBSETORDER(1))
CN9->(MsSEEK(xFILIAL("CN9")+cNumContr))
DO WHILE CN9->(!EOF())  .AND. ALLTRIM(CN9->CN9_NUMERO) == ALLTRIM(cNumContr)
	cDCLIENT := TRIM(CN9->CN9_NOMCLI)
	cDESCTT	 := TRIM(CN9->CN9_XXDESC)
	cGestor  := TRIM(CN9->CN9_XXNRBK)
	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial("SA1")+CN9->CN9_CLIENT+CN9->CN9_LOJACL))
		cENDENTR := AllTrim(SA1->A1_END)
		cENDENTR += IIF(!EMPTY(SA1->A1_BAIRRO),", "+AllTrim(SA1->A1_BAIRRO),"")
		cENDENTR += ", "+AllTrim(SA1->A1_MUN)+" - "+AllTrim(SA1->A1_EST)
		cENDENTR +=  " CEP "+TRANSFORM(SA1->A1_CEP,"@R 99999-999")
	EndIf
	CN9->(dbSkip())
ENDDO

IF EMPTY(cDESCTT)
	DBSELECTAREA("CTT")
	CTT->(DBSETORDER(1))
	IF CTT->(MsSEEK(xFILIAL("CTT")+cNumContr))
		cDCLIENT := "Centro de Custo"
		cDESCTT	 := CTT->CTT_DESC01
		cGestor  := SPACE(80)
		lOK := .T.
		ENDERSAIDA()
	ELSE
		cDCLIENT := SPACE(80)
		cDESCTT	 := SPACE(80)
		cGestor  := SPACE(80)
		lOK := .F.
		MSGSTOP("Centro de Custo ou Contrato não Encontrado!", "Atenção" )
	ENDIF
ELSE
	lOK := .T.
	ENDERSAIDA()
ENDIF

_cCCSZW := cNumContr

RETURN lOK


STATIC FUNCTION VALIDSZW(cLOCEST)
LOCAL lOK := .T.

DBSELECTAREA("SZW")
SZW->(DBSETORDER(1))
SZW->(MsSEEK(xFILIAL("SZW")+cCusto+cLOCEST))
DO WHILE SZW->(!EOF())  .AND. ALLTRIM(SZW->ZW_CC) == ALLTRIM(cCusto) .AND.  ALLTRIM(SZW->ZW_COD) == ALLTRIM(cLOCEST)
	cDSZW := SZW->ZW_DESC
	IF !EMPTY(SZW->ZW_END)
		cENDENTR := AllTrim(SZW->ZW_END)
		cENDENTR += ", "+AllTrim(SZW->ZW_CIDADE)+" - "+SZW->ZW_UF
		cENDENTR +=  " CEP "+TRANSFORM(SZW->ZW_CEP,"@R 99999-999")
	ENDIF
	SZW->(dbSkip())
ENDDO

RETURN lOK


STATIC FUNCTION ValidaSZV()
LOCAL lOK := .T.
LOCAL cMensag := ""
LOCAL _IX := 0

IF EMPTY(ALLTRIM(cLOCSZW))
	IF !u_MsgLog("INCLSZV","Local do Estoque não informado. Deseja inclur sem o Local ?","N")
		lOK := .F.
		RETURN lOK
	ENDIF
ENDIF

IF EMPTY(ALLTRIM(cENDSAID))
	cMensag += "Endereço de Saida não informado."+CRLF
	lOK := .F.
ENDIF
IF EMPTY(ALLTRIM(cENDENTR))
	cMensag += "Endereço de Entrega não informado."+CRLF
	lOK := .F.
ENDIF
IF EMPTY(ALLTRIM(cRespDecl))
	cMensag += "Responsavel pela Declaração não informado."+CRLF
	lOK := .F.
ENDIF
IF EMPTY(ALLTRIM(cCPFDecl))
	cMensag += "CPF do Responsavel pela Declaração não informado."+CRLF
	lOK := .F.
ELSE
	IF !ChkCPF(ALLTRIM(cCPFDecl))
		cMensag += "CPF do Responsavel pela Declaração Inválido."+CRLF
		lOK := .F.
	ENDIF
ENDIF
IF LEN(aItemSZV) <= 0
	cMensag += "Nota\Produtos não informado."+CRLF
	lOK := .F.
ENDIF
IF LEN(aItemSZV) == 1
	IF EMPTY(aItemSZV[1,1]) 
		cMensag += "Nota\Produtos não informado."+CRLF
		lOK := .F.
	ENDIF
ELSEIF lOK
	FOR _IX := 1 TO LEN(aItemSZV)
		IF aItemSZV[_IX,4]  > aItemSZV[_IX,5]
			cMensag += " Quantidade maior que o Saldo Item: "+aItemSZV[_IX,1]+CRLF
			lOK := .F.
		ENDIF
		IF SUBSTR(aItemSZV[_IX,2],1,3)  == 'EPI'
			IF EMPTY(aItemSZV[_IX,6]) .OR. aItemSZV[_IX,7] == CTOD("")
				lOK := .F.
			ENDIF
		ENDIF
	NEXT 
	IF !lOK
		cMensag += "Produtos EPI informar CA e Validade."+CRLF
	ENDIF
ENDIF

IF !lOK
	MSGSTOP(cMensag,"Atenção!")
ENDIF
RETURN lOK


STATIC FUNCTION ENDERSAIDA()
Local aArea     := Getarea()
Local oOk
Local oNo
Local oDlg
Local oPanelLeft
Local aButtons 	:= {}
Local lOk      	:= .F.
Local cTitulo 	:= "Endereço de Saida"
Local aEndSaida := {}
Local cEndSaida := cENDSAID

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

nLin := 15

AADD(aEndSaida,"AV. LPIRANGA, 104, REPÚBLICA, SÃO PAULO - SP CEP 01046-010")
AADD(aEndSaida,"RUA BONNARD, 980 - BLOCO 9 - NÍVEL 7, ALPHAVILLE EMPRESARIAL, BARUERI - SP CEP 06473-000")

DO WHILE .T.	

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 160,800 PIXEL
	@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 800,150
	oPanelLeft:Align := CONTROL_ALIGN_LEFT

	@ nLin,010 SAY 'Endereço Saida:' PIXEL SIZE 60,10 OF oPanelLeft
 	@ nLin,080 COMBOBOX cEndSaida  ITEMS aEndSaida SIZE 250,010 Pixel OF oPanelLeft WHEN .T.
	nLin += 25

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , @aButtons)
		
	If ( lOk )
  		lOk := .F.
		cENDSAID := cEndSaida
  	EndIf
	EXIT
	
ENDDO
Restarea( aArea )
RETURN NIL

//ALTERA COLUNAS CA E VALIDADE CA
STATIC FUNCTION EDITCNR2(aItemSZV)
Local _IX := 0
Local cMensag := ""

lEditCell(aItemSZV,oListSZV,'@E 999',4)
lEditCell(aItemSZV,oListSZV,'@!',6)
lEditCell(aItemSZV,oListSZV,'@!',7)

FOR _IX := 1 TO LEN(aItemSZV)
	IF aItemSZV[_IX,4]  > aItemSZV[_IX,5]
		cMensag := " Quantidade maior que o Saldo. Verifique!"+CRLF
	ENDIF
NEXT

IF !EMPTY(cMensag)
	MSGSTOP(cMensag,"Atenção!")
ENDIF

RETURN NIL

//GRAVA ENTRADA ENTRADA DA NOTAS
User Function GRAVSZV()
LOCAL _lOK	:= .T.
Local _IX   := 0
Local _SQL 	:= ""
Local cCodigo := ""

	_SQL:= " SELECT TOP 1 ZV_CODIG FROM " + RetSQLName( "SZV" ) + " SZV"
 	_SQL+= " WHERE SZV.D_E_L_E_T_='' ORDER BY ZV_CODIG DESC"
 	
	IF SELECT('QSZV') > 0
		QSZV->(DBCLOSEAREA())
	ENDIF
		
	DBUSEAREA(.T.,"TOPCONN"	,TCGENQRY(,,_SQL),'QSZV',.F.,.T.)

	DBSELECTAREA('QSZV')
 	QSZV->(DBGOTOP())
	IF !EMPTY(QSZV->ZV_CODIG)
		cCodigo := QSZV->ZV_CODIG
    ENDIF
	QSZV->(DBCLOSEAREA())
	cCodigo := STRZERO(VAL(cCodigo)+1,9)


	FOR _IX:= 1 TO LEN(aItemSZV)

		RecLock("SZV",.T.)
		SZV->ZV_FILIAL	:= xFilial("SZV")
		SZV->ZV_CODIG	:= cCodigo
		SZV->ZV_EMISSAO	:= dDataD
		SZV->ZV_PROD	:= aItemSZV[_IX,2]
		SZV->ZV_DESCRI	:= Posicione("SB1",1,xFilial("SB1")+aItemSZV[_IX,2],"B1_DESC")
		SZV->ZV_QUANT	:= aItemSZV[_IX,4]
		SZV->ZV_CUSTO1	:= (aItemSZV[_IX,8]/aItemSZV[_IX,5])*aItemSZV[_IX,4]
		SZV->ZV_TM		:= "01" 
		SZV->ZV_CC		:= cCusto
		SZV->ZV_CCDESC	:= cDESCTT
		SZV->ZV_LOCAL   := cLOCSZW
		SZV->ZV_ENDBK	:= cENDSAID
		SZV->ZV_ENDCO	:= cENDENTR
		SZV->ZV_NOMRE	:= cRespDecl
		SZV->ZV_CPFRE	:= cCPFDecl
		//SZV->ZV_RECBNOM	:= 
		//SZV->ZV_RECBCPF	:= 
		SZV->ZV_GESTO	:= cGestor
		SZV->ZV_CODCA	:= aItemSZV[_IX,6]
		SZV->ZV_VALIC	:= aItemSZV[_IX,7]
		//SZV->ZV_RDEVO	:= 
		//SZV->ZV_CPFRD	:= 
		//SZV->ZV_EUSO	:= 
		//SZV->ZV_PRONT	:= 
		//SZV->ZV_NOME	:= 
		//SZV->ZV_FUNCA	:= 
		SZV->ZV_ITEM	:= aItemSZV[_IX,1]
		SZV->ZV_DOC		:= aItemSZV[_IX,9]
		SZV->ZV_SER		:= aItemSZV[_IX,10]
		SZV->ZV_FOR		:= aItemSZV[_IX,11]
		SZV->ZV_LOJ		:= aItemSZV[_IX,12]
		SZV->(MSUNLOCK())																																																																																																				

	NEXT _IX
	MSGINFO("Incluido com sucesso! cod.: "+SZV->ZV_CODIG)

Return _lOK

//EXCLUIR SZV
USER FUNCTION EXCLUISZV()
LOCAL cTermo 	:= SZV->ZV_CODIG
LOCAL _lOK		:= .T.
LOCAL _SQL		:= ""
LOCAL cCODIGO   := ""


dbSelectArea("SZV")
dbSetOrder(1)
IF dbSeek(xFilial("SZV")+cTermo,.T.)

	_SQL:= " SELECT ZV_CODIG FROM " + RetSQLName( "SZV" ) + " SZV"
 	_SQL+= " WHERE SZV.D_E_L_E_T_='' AND ZV_IDREF='"+cTermo+"'"
	_SQL+= " GROUP BY ZV_CODIG "

	IF SELECT('QSZV') > 0
		QSZV->(DBCLOSEAREA())
	ENDIF
		
	DBUSEAREA(.T.,"TOPCONN"	,TCGENQRY(,,_SQL),'QSZV',.F.,.T.)
	cCODIGO := ""
	DBSELECTAREA('QSZV')
 	QSZV->(DBGOTOP())
	DO WHILE QSZV->(!EOF())
		cCODIGO += ZV_CODIG+";"
		QSZV->(DBSKIP())
	ENDDO
	QSZV->(DBCLOSEAREA())

	IF EMPTY(cCODIGO)
		IF u_MsgLog("INCLSZV","Confirma a Exclusão do Termo de Transferencia / Responsabilidade de Uso cod.: "+SZV->ZV_CODIG+"?","Y")
			dbSelectArea("SZV")
			dbSetOrder(1)
			dbSeek(xFilial("SZV")+cTermo,.T.)
			Do while !eof() .AND. SZV->ZV_CODIG=cTermo
				
				RecLock("SZV",.F.)
				dbDelete()
				SZV->(MSUNLOCK())																																																																																																				
				SZV->(dbSkip())
			Enddo
			dbSelectArea("SZV")
			dbSetOrder(1)
			IF !dbSeek(xFilial("SZV")+cTermo,.T.)
				_lOK		:= .T.
				MSGINFO("Excluido com sucesso! cod.: "+cTermo)
			ELSE
				MSGSTOP("Erro na Exclusão. Verifique!")
				_lOK		:= .F.
			ENDIF
		ENDIF
	ELSE
		MSGSTOP("Não pode ser excluido, dados Utilizados no(s) Cood: "+cCODIGO+". Verifique!")
		_lOK		:= .F.
	ENDIF
ELSE
	MSGSTOP("Dados não encontrados. Verifique!")
ENDIF

Return _lOK


USER FUNCTION PRINTSZV(lTipo)
LOCAL cTermo 	:= SZV->ZV_CODIG
LOCAL cCLIENT 	:= ""
LOCAL cMUNIC	:= "SÃO PAULO" 
LOCAL aItens 	:= {}

DEFAULT lTipo := .T.


dbSelectArea("SZV")
dbSetOrder(1)
IF dbSeek(xFilial("SZV")+cTermo,.T.)
	Do while !eof() .AND. SZV->ZV_CODIG=cTermo

		AADD(aItens,{TRIM(Posicione("SB1",1,xFilial("SB1")+SZV->ZV_PROD,"B1_DESC")),Posicione("SB1",1,xFilial("SB1")+SZV->ZV_PROD,"B1_UM"),SZV->ZV_QUANT,TRIM(SZV->ZV_CODCA),SZV->ZV_VALIC,SZV->ZV_CUSTO1,SZV->ZV_EUSO})
		SZV->(dbSkip())
	Enddo

	dbSeek(xFilial("SZV")+cTermo,.T.)
	IF "BARUERI" $ SZV->ZV_ENDBK
		cMUNIC	:= "BARUERI" 
	ENDIF

	DBSELECTAREA("CN9")
	CN9->(DBSETORDER(1))
	CN9->(MsSEEK(xFILIAL("CN9")+SZV->ZV_CC))
	DO WHILE CN9->(!EOF())  .AND. ALLTRIM(CN9->CN9_NUMERO) == ALLTRIM(SZV->ZV_CC)
		cCLIENT := TRIM(CN9->CN9_NOMCLI)
		CN9->(dbSkip())
	ENDDO


	IF LEN(aItens) > 0
		IF ALLTRIM(SZV->ZV_TM) == '01'
			//IF u_MsgLog("DTRANSTML","Gerar impressão da Declaração de Transferência ?","Y")
				DTRANSTML(SZV->ZV_CODIG,SZV->ZV_EMISSAO,cMUNIC,SZV->ZV_ENDBK,cCLIENT,SZV->ZV_ENDCO,SZV->ZV_NOMRE,SZV->ZV_CPFRE,aItens)
			//ENDIF
			//IF u_MsgLog("RESPUSO","Gerar impressão do Termo de Responsabilidade de Uso ?","Y")
				RESPUSO(SZV->ZV_CODIG,SZV->ZV_EMISSAO,SZV->ZV_CC,SZV->ZV_GESTO,cMUNIC,SZV->ZV_ENDBK,cCLIENT,SZV->ZV_ENDCO,SZV->ZV_NOMRE,SZV->ZV_CPFRE,aItens)
			//ENDIF
		ENDIF
		IF ALLTRIM(SZV->ZV_TM)  == '02'
			//IF u_MsgLog("RECEBUNIFORME","Gerar impressão do Termo de Recebimento Local de Uniforme ?","Y")
				RECEBUNIFORME(cTermo,SZV->ZV_EMISSAO,SZV->ZV_CC,SZV->ZV_NOME,SZV->ZV_RGFUNC,SZV->ZV_PRONT,SZV->ZV_FUNCA,aItens)
			//ENDIF
		ENDIF
		IF ALLTRIM(SZV->ZV_TM)  == '03'
			//IF u_MsgLog("TDEVOLUCAO","Gerar impressão do Termo de Devolução de Uniforme/EPI ?","Y")
				TDEVOLUCAO(cTermo,SZV->ZV_EMISSAO,cMUNIC,SZV->ZV_CC,SZV->ZV_CCDESC,SZV->ZV_NOME,SZV->ZV_RGFUNC,SZV->ZV_PRONT,SZV->ZV_FUNCA,SZV->ZV_RDEVO,SZV->ZV_CPFRD,aItens)
			//ENDIF
		ENDIF
	ENDIF
ENDIF

Return NIL

USER FUNCTION BUSCSZV()
LOCAL cPerg  := "BUSCSZV"
LOCAL cQuery := ""

ValidPerg(cPerg)
	
IF !Pergunte(cPerg,.T.)
	RestArea(aAreaIni)
	Return
ENDIF
cQuery += " SELECT ZV_CODIG"
cQuery += " FROM "+RETSQLNAME("SZV")+ " SZV" + CRLF
cQuery += " WHERE SZV.D_E_L_E_T_='' "
cQuery += " AND SZV.ZV_CODIG>='"+mv_par01+"'"
cQuery += " AND SZV.ZV_CODIG<='"+mv_par02+"'"
cQuery += " GROUP BY ZV_CODIG"
cQuery += " ORDER BY ZV_CODIG"

IF SELECT('QYZV2') > 0
	QYZV2->(DBCLOSEAREA())
ENDIF
					
DBUSEAREA(.T.,"TOPCONN"	,TCGENQRY(,,cQuery),'QYZV2',.F.,.T.)

DBSELECTAREA('QYZV2')
while QYZV2->(!EOF())
	dbSelectArea("SZV")
	dbSetOrder(1)
	IF dbSeek(xFilial("SZV")+QYZV2->ZV_CODIG,.T.)
		U_PRINTSZV(.F.)
	ENDIF
	QYZV2->(dbSkip())
ENDDO
QYZV2->(DBCLOSEAREA())
Return NIL


Static Function  ValidPerg(cPerg)
Local i,j
Local aArea      := GetArea()
Local aRegistros := {}
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Termo de ?"       ,"Termo de ?"       ,"Termo de ?"       ,"mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Termo até ?"      ,"Termo até ?"      ,"Termo até ?"      ,"mv_ch2","C",09,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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


STATIC FUNCTION BKESTA03A()
Local oOk
Local oNo
Local oDlg
Local oListId
Local oPanelLeft
Local lAll
Local oAll
Local aButtons := {}
Local lOk      := .F.
Local aNotas := {}
Local aParam 	:= {}
Local aRet		:=	{}
Local cTitulo   :=  "Selecionar Notas Fiscais"
Local cQuery	:= ""
Local nSaldo 	:= 0


aAdd( aParam, { 1, "Nota Fiscal ?"	, SPACE(TamSx3("F1_DOC")[1])	, ""            , "", "SF1"	, "" , 70  , .F. })
aAdd( aParam, { 1, "Serie?"		, SPACE(TamSx3("F1_SERIE")[1])	, ""            , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Fornecedor?"	, SPACE(TamSx3("A1_COD")[1])	, ""            , "", "SA2"	, "" , 70  , .F. })
aAdd( aParam, { 1, "Loja?"	, SPACE(TamSx3("A1_LOJA")[1])	, ""            , "", ""	, "" , 70  , .F. })


If (Parambox(aParam,"BKESTA03A - "+cTitulo,@aRet,,,.T.,,,,"BKESTA03A",.T.,.T.))
	lRet := .T.
	cNota 	:= MV_PAR01
	cSerie	:= MV_PAR02
	cFornec	:= MV_PAR03
	cLoja	:= MV_PAR04

	cQuery := "SELECT D1_ITEM,D1_COD,D1_QUANT,D1_VUNIT,D1_TOTAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_CC,
	cQuery += " (SELECT SUM(ZV_QUANT) FROM  "+RetSqlName("SZV")+" SZV WHERE SZV.D_E_L_E_T_=''"
	cQuery += " AND D1_FILIAL=ZV_FILIAL AND D1_DOC=ZV_DOC AND D1_SERIE=ZV_SER"
	cQuery += " AND D1_FORNECE=ZV_FOR AND D1_LOJA=ZV_LOJ"
	cQuery += " AND D1_ITEM=ZV_ITEM AND D1_COD=ZV_PROD AND SZV.ZV_TM='01') AS ZV_QUANT"
	cQuery += " FROM "+RetSqlName("SD1")+" SD1"
	cQuery += " WHERE SD1.D_E_L_E_T_=''"
	cQuery += " AND D1_FILIAL='"+xFilial("SD1")+"'"
	cQuery += " AND D1_DOC='"+cNota+"'"
	cQuery += " AND D1_SERIE='"+cSerie+"'"
	cQuery += " AND D1_FORNECE='"+cFornec+"'"
	cQuery += " AND D1_LOJA='"+cLoja+"'"
	cQuery += " ORDER BY D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_ITEM"

	IF SELECT('QSD1') > 0
		QSD1->(DBCLOSEAREA())
	ENDIF
		
	DBUSEAREA(.T.,"TOPCONN"	,TCGENQRY(,,cQuery),'QSD1',.F.,.T.)
	DBSELECTAREA('QSD1')
	IF !EMPTY(QSD1->D1_ITEM)
		while ! QSD1->( EOF() )
			nSaldo 	:= 0
			nSaldo 	:= QSD1->D1_QUANT - QSD1->ZV_QUANT
			IF nSaldo > 0
				//"Item","Cod. Produto","Descrição","Quantidade","Valor Total",'Nota Fiscal',"Serie","Fornece","Loja" 
				AADD(aNOTAS,{.F.,QSD1->D1_ITEM,QSD1->D1_COD,TRIM(Posicione("SB1",1,xFilial("SB1")+QSD1->D1_COD,"B1_DESC")),nSaldo,QSD1->D1_VUNIT*nSaldo,QSD1->D1_DOC,QSD1->D1_SERIE,QSD1->D1_FORNECE,QSD1->D1_LOJA,QSD1->D1_CC})
        	ENDIF
			QSD1->(dbSkip())
       ENDDO
	   QSD1->(DBCLOSEAREA())
	ELSE
		aNotas := {}
		AADD(aNotas,{.F.,"","","",0,0,"","","","",""})
		MSGSTOP("Dados da Notas Fiscal não Encontrada!")
		RETURN aNotas
	ENDIF
Endif

IF LEN(aNotas) < 1
	AADD(aNotas,{.F.,"","","",0,0,"","","","",""})
ENDIF


oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE "Confirme os itens da Nota Fiscal" FROM 000,000 TO 450,830 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 430,825 
oPanelLeft:Align := CONTROL_ALIGN_LEFT
lAll := .F.
@ 005, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
oAll:bChange := {|| Aeval(aNotas,{|x| IIF(x[11]== cCusto,x[1]:=lAll,x[1]:=.F.) }), oListId:Refresh()}

			//"Item","Cod. Produto","Descrição","Quantidade","Valor Total",'Nota Fiscal',"Serie","Fornece","Loja","C.Custo"

@ 015, 010 LISTBOX oListID FIELDS HEADER "","Item","Produto","Descrição","Quantidade","Total","Nota Fiscal","Serie","Fornecedor","Loja","C.Custo" SIZE 400,180 OF oPanelLeft PIXEL 

oListID:SetArray(aNotas)
oListID:bLine := {||{If(aNotas[oListId:nAt][1],oOk,oNo),;
						aNotas[oListId:nAt][2],;
						aNotas[oListId:nAt][3],;
						aNotas[oListId:nAt][4],;
						aNotas[oListId:nAt][5],;
						aNotas[oListId:nAt][6],;
						aNotas[oListId:nAt][7],;
						aNotas[oListId:nAt][8],;
						aNotas[oListId:nAt][9],;
						aNotas[oListId:nAt][10],;
						aNotas[oListId:nAt][11]}}

oListId:bLDblClick := {|| aNotas[oListId:nAt][1] := ValidaMrk(aNotas[oListId:nAt][1],aNotas[oListId:nAt][11]), oListId:DrawSelect()}


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

If ( lOk )
    GravaNOTAS(aNOTAS)
EndIf
Return lOk


Static Function ValidaMrk(lRet,cCCSD1)
LOCAL lOK := .T.

IF cCusto <> cCCSD1
	If !u_MsgLog("BKESTA03A","Contrato ou C.Custo diferente da Nota e Termo. Continua ?","N")
		lOK := .F.
		Return lOK 
	EndIf
ENDIF

Return lOK 


STATIC FUNCTION GravaNOTAS(aNOTAS)
Local _ix:=0
Local nSCAN:=0

IF LEN(aItemSZV) == 1 
	IF EMPTY(aItemSZV[1,1])
		aItemSZV:= {}
	ENDIF
ENDIF

FOR _ix:=1 TO LEN(aNOTAS)

	IF aNOTAS[_ix,1]

		//                  1        2             3           4          5         6          7            8               9        10       11       12
		//aItemSZV//    "Item","Cod. Produto","Descrição","Quantidade","Saldo","Cod. CA","Validade CA","Valor Total",'Nota Fiscal',"Serie","Fornece","Loja" 
		//          1       2        3             4           5                                    6             7           8       9        10     11
		//aNOTAS//"MRK","Item","Cod. Produto","Descrição","Quantidade"                        ,"Valor Total",'Nota Fiscal',"Serie","Fornece","Loja","C.Custo"
	
		nScan:= 0
		nScan:= aScan(aItemSZV,{|x| x[1] == aNOTAS[_ix,2] .AND. x[9] == aNOTAS[_ix,7] .AND. x[10] == aNOTAS[_ix,8] .AND. x[11] == aNOTAS[_ix,9] .AND. x[12] == aNOTAS[_ix,10] })
		IF nScan == 0
			AADD(aItemSZV,{aNOTAS[_ix,2],aNOTAS[_ix,3],aNOTAS[_ix,4],aNOTAS[_ix,5],aNOTAS[_ix,5],SPACE(20),CTOD(""),aNOTAS[_ix,6],aNOTAS[_ix,7],aNOTAS[_ix,8],aNOTAS[_ix,9],aNOTAS[_ix,10]})
		ENDIF
	ENDIF

NEXT _ix

oListSZV:SetArray(aItemSZV)
oListSZV:bLine := {|| {	aItemSZV[oListSZV:nAt][1],;
						aItemSZV[oListSZV:nAt][2],;
						aItemSZV[oListSZV:nAt][3],;
						aItemSZV[oListSZV:nAt][4],;
						aItemSZV[oListSZV:nAt][5],;   
						aItemSZV[oListSZV:nAt][6],;                                                     
						aItemSZV[oListSZV:nAt][7],;
						aItemSZV[oListSZV:nAt][8],;
						aItemSZV[oListSZV:nAt][9],;
						aItemSZV[oListSZV:nAt][10],;                                                                                    
						aItemSZV[oListSZV:nAt][11],;                                                                                    
						aItemSZV[oListSZV:nAt][12]}}
oListSZV:bLDblClick := {|| EDITCNR2(@aItemSZV),oListSZV:DrawSelect(), }

RETURN NIL

//INCLUSÃO RECEBIMENTO DE UNIFORME
USER FUNCTION RECBUNISZV()
Local lOk		 := .F.
Local nSnd       := 15
Local nTLin      := 15
Local oDlg01     as Object
Local oButInv    as Object
Local aButtons   := {}

PRIVATE aItemFUN 	:= {}
PRIVATE cCustoFUN	:= SPACE(9)
PRIVATE cDCLIFUN 	:= SPACE(80)
PRIVATE cDCTTFUN  	:= SPACE(80)
PRIVATE dDataDFUN 	:= dDATABASE
PRIVATE cGestorFUN  := SPACE(80)
PRIVATE cLOCSZWFUN  := SPACE(6)
PRIVATE cDSZWFUN    := SPACE(80)
PRIVATE cMatric 	:= SPACE(6)
PRIVATE cNOMEFUNC	:= SPACE(80)
PRIVATE cCPFFUN		:= SPACE(11)
PRIVATE cFUNCAOFUN 	:= SPACE(80)

    AADD(aItemFUN,{"","","","",SPACE(20),CTOD(""),0,"","","","","",""})


    Define MsDialog oDlg01 Title "Incluir Termo de Recebimento Local de Uniformes" From 000,000 To 510,830 Of oDlg01 Pixel
	
	@ 000,000 MSPANEL oPanelLeft OF oDlg01 SIZE 480,825 
	oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
	@ nSnd,010 SAY "Data de Emissão:" SIZE 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet dDataDFUN  Picture "@E"  Size 060,010 Pixel OF oPanelLeft WHEN .T.
	nSnd += nTLin

	@ nSnd,010 Say "Matricula:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cMatric Picture '@!' Size 060,010 Pixel OF oPanelLeft WHEN .T. VALID(!Empty(cMatric) .AND. VALIDMATRIC(cMatric))
	@ nSnd,130 MsGet cNOMEFUNC Picture '@!' Size 150,010 Pixel OF oPanelLeft PIXEL WHEN .F. 
	@ nSnd,285 Say "Função:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,310 MsGet cFUNCAOFUN Picture '@!' Size 100,010 Pixel OF oPanelLeft WHEN .F.
	nSnd += nTLin

	@ nSnd,010 Say "CPF:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cCPFFUN Picture '@!' Size 060,010 Pixel OF oPanelLeft WHEN .F.

	@ nSnd,130 MsGet cDCLIFUN Picture '@!' Size 280,010 Pixel OF oPanelLeft PIXEL WHEN .F. 
	nSnd += nTLin

	@ nSnd,010 Say "Custo / Contrato:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cCustoFUN Picture '@!' Size 060,010 Pixel OF oPanelLeft WHEN .T. VALID(!Empty(cCustoFUN) .AND. VALIDCN9(cCustoFUN))

	@ nSnd,130 MsGet cDCTTFUN Picture '@!' Size 150,010 Pixel OF oPanelLeft PIXEL WHEN .F. 

	@ nSnd,285 SAY "Gestor:" SIZE 080,010 Pixel OF oPanelLeft
	@ nSnd,310 MsGet cGestorFUN SIZE 100,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .F.
	nSnd += nTLin

	@ nSnd,010 SAY "Local Estoque:" SIZE 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cLOCSZWFUN Picture '@!' F3 "SZW" Size 060,010 Pixel OF oPanelLeft WHEN .T. VALID(VALIDSZW2(cLOCSZWFUN))
	@ nSnd,130 MsGet cDSZWFUN Picture '@!' Size 280,010 Pixel OF oPanelLeft PIXEL WHEN .F. 
	nSnd += nTLin


    @ nSnd,010 Button oButInv    Prompt "Seleciona Produtos"  Size 100, 12 Pixel Action ( BKESTA03B() ) ;
    Message "Seleciona Produtos" Of oPanelLeft
	nSnd += nTLin
	
	@ nSnd, 010 LISTBOX oListFUN FIELDS HEADER "Item","Cod. Produto","Descrição","Quantidade","Cod. CA","Validade CA","Valor Unitario","Saldo","ID Movimento","Doc","Serie","Fornece","Loja" SIZE 400,085  OF oPanelLeft PIXEL 
	
	oListFUN:SetArray(aItemFUN)
	oListFUN:bLine := {|| {	aItemFUN[oListFUN:nAt][1],;
							aItemFUN[oListFUN:nAt][2],;
							aItemFUN[oListFUN:nAt][3],;
							aItemFUN[oListFUN:nAt][4],;
							aItemFUN[oListFUN:nAt][5],;   
							aItemFUN[oListFUN:nAt][6],;                                                     
							aItemFUN[oListFUN:nAt][7],;
							aItemFUN[oListFUN:nAt][8],;
							aItemFUN[oListFUN:nAt][9],;
							aItemFUN[oListFUN:nAt][10],;
							aItemFUN[oListFUN:nAt][11],;
							aItemFUN[oListFUN:nAt][12],;
							aItemFUN[oListFUN:nAt][13]}}

	oListFUN:bLDblClick := {|| EDITQFUN(@aItemFUN),oListFUN:DrawSelect(), }
	
	ACTIVATE MSDIALOG oDlg01 CENTERED Valid(ValidaFUN()) ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

	If ( lOk )
		lOk:=.F.
		If u_MsgLog("INCLSZV","Confirma a inclusão e geração do Termo de Recebimento Local de Uniformes ?","Y")
			IF U_GRAVFUN()
				U_PRINTSZV()
			ENDIF
		ENDIF
	Endif

RETURN lOk

//ALTERA QUANTIDADE SELECTIONADO DE PRODUTO PARA O FUNCIONNÁRIO
STATIC FUNCTION EDITQFUN(aItemFUN)
LOCAL _IX := 0
LOCAL cMensag := ""

lEditCell(aItemFUN,oListFUN,'@E 999',4)

FOR _IX := 1 TO LEN(aItemFUN)
	IF aItemFUN[_IX,4]  > aItemFUN[_IX,8]
		cMensag := " Quantidade maior que o Saldo. Verifique!"+CRLF
	ENDIF
NEXT
IF !EMPTY(cMensag)
	MSGSTOP(cMensag,"Atenção!")
ENDIF

RETURN NIL


STATIC FUNCTION ValidaFUN()
LOCAL lOK := .T.
LOCAL cMensag := ""
LOCAL _IX := 0

IF EMPTY(ALLTRIM(cMatric))
	cMensag += "Matrícula do Funcionário não informado."+CRLF
	lOK := .F.
ENDIF

IF EMPTY(ALLTRIM(cCustoFUN))
	cMensag += "Centro de Custo / Contrato não informado."+CRLF
	lOK := .F.
ENDIF
IF EMPTY(ALLTRIM(cCPFFUN))
	cMensag += "CPF do Funcionário não informado."+CRLF
	lOK := .F.
ENDIF
IF LEN(aItemFUN) <= 0
	cMensag += "Produto não informado."+CRLF
	lOK := .F.
ENDIF
IF LEN(aItemFUN) == 1
	IF EMPTY(aItemFUN[1,1]) 
		cMensag += "Produto não informado."+CRLF
		lOK := .F.
	ENDIF
ELSEIF lOK
	FOR _IX := 1 TO LEN(aItemFUN)
		IF aItemFUN[_IX,4]  < 1
			lOK := .F.
		ENDIF
	NEXT 
	IF !lOK
		cMensag += "Quantidade não informada."+CRLF
	ELSE
		FOR _IX := 1 TO LEN(aItemFUN)
			IF aItemFUN[_IX,4]  > aItemFUN[_IX,8]
				cMensag += " Quantidade maior que o Saldo Item: "+aItemFUN[_IX,1]+CRLF
				lOK := .F.
			ENDIF
		NEXT 
	ENDIF
ENDIF
IF !lOK
	MSGSTOP(cMensag,"Atenção!")
ENDIF

RETURN lOK



STATIC FUNCTION VALIDSZW2(cLOCEST)
LOCAL lOK := .T.

DBSELECTAREA("SZW")
SZW->(DBSETORDER(1))
SZW->(MsSEEK(xFILIAL("SZW")+cCustoFUN+cLOCEST))
DO WHILE SZW->(!EOF())  .AND. ALLTRIM(SZW->ZW_CC) == ALLTRIM(cCustoFUN) .AND.  ALLTRIM(SZW->ZW_COD) == ALLTRIM(cLOCEST)
	cDSZWFUN := SZW->ZW_DESC
	SZW->(dbSkip())
ENDDO

RETURN lOK


STATIC FUNCTION VALIDMATRIC(cMatric)
Local lOK := .T.
Local cQuery := "" 

	cQuery  := "SELECT TOP 1 bk_senior.bk_senior.r034fun.numcad,bk_senior.bk_senior.r034fun.nomfun,numcpf,"
	cQuery  += " right('00' + cast(bk_senior.bk_senior.r034fun.numemp as varchar(2)),2) AS cEmp, "
	cQuery  += " right('000' + cast(bk_senior.bk_senior.R030FIL.CodFil as varchar(3)),3) AS cFil, " 
	cQuery  += " (SELECT BKIntegraRubi.dbo.fnCCSiga(bk_senior.bk_senior.r034fun.numemp,bk_senior.bk_senior.r034fun.tipcol,bk_senior.bk_senior.r034fun.numcad, 'CLT') AS Expr1) AS CCSiga, "
	cQuery  += " bk_senior.bk_senior.R030FIL.NomFil,bk_senior.bk_senior.R024CAR.TitCar"
	cQuery  += " FROM  bk_senior.bk_senior.r034fun "
	cQuery  += " INNER JOIN bk_senior.bk_senior.R030FIL ON bk_senior.bk_senior.r034fun.numemp = bk_senior.bk_senior.R030FIL.NumEmp "
	cQuery  += " AND bk_senior.bk_senior.r034fun.codfil = bk_senior.bk_senior.R030FIL.CodFil "
	cQuery  += " LEFT JOIN bk_senior.bk_senior.R016HIE ON bk_senior.bk_senior.R016HIE.NumLoc =bk_senior.bk_senior.r034fun.numloc "
 	cQuery  += " LEFT JOIN bk_senior.bk_senior.R024CAR ON 	bk_senior.bk_senior.r034fun.codcar = bk_senior.bk_senior.R024CAR.CodCar"
 	cQuery  += " AND bk_senior.bk_senior.R024CAR.EstCar = 1"
	cQuery  += " WHERE bk_senior.bk_senior.r034fun.tipcol ='1' AND bk_senior.bk_senior.r034fun.numcad='"+cMatric+"' 
	cQuery  += " AND bk_senior.bk_senior.r034fun.numemp='"+SM0->M0_CODIGO+"'"
			
	TCQUERY cQuery NEW ALIAS "Qr034fun"
			
	DbSelectArea("Qr034fun")
	cNOMEFUNC  := ''
	cCustoFUN  := ''
	cCPFFUN    := ''
	cNOMEFUNC  := Qr034fun->nomfun
	cCustoFUN  := Qr034fun->CCSiga
	cCPFFUN    := STRZERO(Qr034fun->numcpf,11)
	cFUNCAOFUN := Qr034fun->TitCar
	Qr034fun->(dbCloseArea())

	DBSELECTAREA("CN9")
	CN9->(DBSETORDER(1))
	CN9->(MsSEEK(xFILIAL("CN9")+cCustoFUN))
	DO WHILE CN9->(!EOF())  .AND. ALLTRIM(CN9->CN9_NUMERO) == ALLTRIM(cCustoFUN)
		cDCLIFUN := TRIM(CN9->CN9_NOMCLI)
		cDCTTFUN := TRIM(CN9->CN9_XXDESC)
		cGestorFUN  := TRIM(CN9->CN9_XXNRBK)
		CN9->(dbSkip())
	ENDDO

	IF EMPTY(cDCLIFUN)
		DBSELECTAREA("CTT")
		CTT->(DBSETORDER(1))
		IF CTT->(MsSEEK(xFILIAL("CTT")+cCustoFUN))
			cDCLIFUN   := "Centro de Custo"
			cDCTTFUN   := CTT->CTT_DESC01
			cGestorFUN := SPACE(80)
			lOK := .T.
		ELSE
			cDCLIFUN   := SPACE(80)
			cDCTTFUN   := SPACE(80)
			cGestorFUN := SPACE(80)
			lOK := .F.
			MSGSTOP("Centro de Custo ou Contrato não Encontrado!", "Atenção" )
		ENDIF
	ELSE
		lOK := .T.
	ENDIF
	_cCCSZW := cCustoFUN

RETURN lOK


STATIC FUNCTION VALIDCN9(cNumContr)
LOCAL lOK := .F.

cDCLIFUN 	:= ""
cDCTTFUN	:= ""
cGestorFUN  := ""


DBSELECTAREA("CN9")
CN9->(DBSETORDER(1))
CN9->(MsSEEK(xFILIAL("CN9")+cNumContr))
DO WHILE CN9->(!EOF())  .AND. ALLTRIM(CN9->CN9_NUMERO) == ALLTRIM(cNumContr)
	cDCLIFUN   := TRIM(CN9->CN9_NOMCLI)
	cDCTTFUN   := TRIM(CN9->CN9_XXDESC)
	cGestorFUN := TRIM(CN9->CN9_XXNRBK)
	lOK := .T.
	CN9->(dbSkip())
ENDDO

IF EMPTY(cDCTTFUN)
	DBSELECTAREA("CTT")
	CTT->(DBSETORDER(1))
	IF CTT->(MsSEEK(xFILIAL("CTT")+cNumContr))
		cDCLIFUN 	:= "Centro de Custo"
		cDCTTFUN	:= CTT->CTT_DESC01
		cGestorFUN  := SPACE(80)
		lOK := .T.
	ELSE
		cDCLIFUN 	:= SPACE(80)
		cDCTTFUN	:= SPACE(80)
		cGestorFUN  := SPACE(80)
		lOK := .F.
		MSGSTOP("Centro de Custo ou Contrato não Encontrado!", "Atenção" )
	ENDIF
ENDIF

_cCCSZW := cNumContr

RETURN lOK



STATIC FUNCTION BKESTA03B()
Local oOk
Local oNo
Local oDlg
Local oListId
Local oPanelLeft
Local lAll
Local oAll
Local aButtons := {}
Local lOk      := .F.
Local aUnifor  := {}
Local cTitulo   :=  "Selecionar Produtos / Uniformes /EPI"
Local cQuery	:= ""
Local nSaldo := 0
Local nCustoUFOR := 0 

	cQuery := "SELECT  SZV.ZV_ITEM,SZV.ZV_PROD,SZV.ZV_QUANT,SZV.ZV_CODCA,SZV.ZV_VALIC,SZV.ZV_CUSTO1,SZV.ZV_CODIG,SZV.ZV_DOC,SZV.ZV_SER,
	cQuery += "SZV.ZV_FOR,SZV.ZV_LOJ,"+ CRLF
	cQuery += " (SELECT SUM(ZV_QUANT)  FROM "+RetSqlName("SZV")+" SZV2 "+ CRLF
	cQuery += " WHERE SZV2.D_E_L_E_T_='' AND SZV2.ZV_TM='02' AND SZV2.ZV_IDREF=SZV.ZV_CODIG AND SZV2.ZV_DOC=SZV.ZV_DOC"+ CRLF
	cQuery += " AND SZV2.ZV_SER=SZV.ZV_SER AND SZV2.ZV_FOR=SZV.ZV_FOR AND SZV2.ZV_LOJ=SZV.ZV_LOJ AND SZV2.ZV_CC=SZV.ZV_CC"+ CRLF
	cQuery += " AND SZV2.ZV_LOCAL=SZV.ZV_LOCAL AND SZV2.ZV_ITEM=SZV.ZV_ITEM) AS QUANT_S,"+ CRLF

	cQuery += " (SELECT SUM(SZV3.ZV_QUANT)  FROM "+RetSqlName("SZV")+" SZV3 "+ CRLF
	cQuery += "  INNER JOIN "+RetSqlName("SZV")+" SZVX ON SZVX.D_E_L_E_T_='' AND SZVX.ZV_TM='02' AND SZV3.ZV_IDREF=SZVX.ZV_CODIG AND SZVX.ZV_DOC=SZV3.ZV_DOC"+ CRLF
	cQuery += " AND SZVX.ZV_SER=SZV3.ZV_SER AND SZVX.ZV_FOR=SZV3.ZV_FOR AND SZVX.ZV_LOJ=SZV3.ZV_LOJ AND SZVX.ZV_CC=SZV3.ZV_CC"+ CRLF
	cQuery += " AND SZVX.ZV_LOCAL=SZV3.ZV_LOCAL AND SZVX.ZV_ITEM=SZV3.ZV_ITEM"+ CRLF
	cQuery += " WHERE SZV3.D_E_L_E_T_='' AND SZV3.ZV_TM='03' AND SZV3.ZV_EUSO<>'R' AND SZVX.ZV_IDREF=SZV.ZV_CODIG "+ CRLF
	cQuery += " AND SZV3.ZV_DOC=SZV.ZV_DOC"+ CRLF
	cQuery += " AND SZV3.ZV_SER=SZV.ZV_SER AND SZV3.ZV_FOR=SZV.ZV_FOR AND SZV3.ZV_LOJ=SZV.ZV_LOJ AND SZV3.ZV_CC=SZV.ZV_CC"+ CRLF
	cQuery += " AND SZV3.ZV_LOCAL=SZV.ZV_LOCAL AND SZV3.ZV_ITEM=SZV.ZV_ITEM) AS QUANT_D"+ CRLF

	cQuery += " FROM "+RETSQLNAME("SZV")+ " SZV" + CRLF
	cQuery += " INNER JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT.D_E_L_E_T_=''" + CRLF
	cQuery += " AND CTT_CUSTO= ZV_CC" + CRLF
	cQuery += " LEFT JOIN "+RETSQLNAME("SZW")+ " SZW ON SZW.D_E_L_E_T_=''" + CRLF
	cQuery += " AND ZW_CC= ZV_CC AND ZW_COD= ZV_LOCAL" + CRLF

	cQuery += " WHERE SZV.D_E_L_E_T_=''  AND SZV.ZV_TM='01'"+CRLF
	cQuery += " AND SZV.ZV_CC='"+cCustoFUN+"'"
	cQuery += " AND SZV.ZV_LOCAL='"+cLOCSZWFUN+"'"
	cQuery += " ORDER BY SZV.ZV_PROD,SZV.ZV_VALIC"

	IF SELECT('QSZV2') > 0
		QSZV2->(DBCLOSEAREA())
	ENDIF
		
	DBUSEAREA(.T.,"TOPCONN"	,TCGENQRY(,,cQuery),'QSZV2',.F.,.T.)
	TCSETFIELD("QSZV2","ZV_VALIC","D",8,0)

	DBSELECTAREA('QSZV2')
	IF !EMPTY(QSZV2->ZV_ITEM)
		while ! QSZV2->( EOF() )
			nSaldo := 0
			nSaldo := (QSZV2->ZV_QUANT-QSZV2->QUANT_S+QSZV2->QUANT_D)
			IF nSaldo > 0
				nCustoUFOR := 0 
				nCustoUFOR := QSZV2->ZV_CUSTO1/QSZV2->ZV_QUANT
				//"Item","Cod. Produto","Descrição","Quantidade","Cod. CA","Validade CA","Valor Unit","ID Movimento","Doc","Serie","Forn","Loja"
				AADD(aUnifor,{.F.,QSZV2->ZV_ITEM,QSZV2->ZV_PROD,TRIM(Posicione("SB1",1,xFilial("SB1")+QSZV2->ZV_PROD,"B1_DESC")),nSaldo,QSZV2->ZV_CODCA,QSZV2->ZV_VALIC,nCustoUFOR,QSZV2->ZV_CODIG,QSZV2->ZV_DOC,QSZV2->ZV_SER,QSZV2->ZV_FOR,QSZV2->ZV_LOJ})
			ENDIF
        	QSZV2->(dbSkip())
       ENDDO
	   QSZV2->(DBCLOSEAREA())
	ELSE
		aUnifor := {}
		AADD(aUnifor,{.F.,"","","",0,"","","","","","","",""})
		MSGSTOP("Dados da Notas Fiscal não Encontrada!")
		RETURN aUnifor
	ENDIF

IF LEN(aUnifor) < 1
	AADD(aUnifor,{.F.,"","","",0,"","","","","","","",""})
ENDIF


oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 450,830 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 430,825 
oPanelLeft:Align := CONTROL_ALIGN_LEFT
lAll := .F.
@ 005, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
oAll:bChange := {|| Aeval(aUnifor,{|x| x[1]:=lAll }), oListId:Refresh()}

			//"Item","Cod. Produto","Descrição","Quantidade","Cod. CA","Validade CA","Valor Total","ID Movimento","Doc","Serie","Fornece","Loja"

@ 015, 010 LISTBOX oListID FIELDS HEADER "","Item","Produto","Descrição","Saldo","Cod. CA","Validade CA","Valor Total","ID Movimento","Doc","Serie","Fornece","Loja" SIZE 400,180 OF oPanelLeft PIXEL 

oListID:SetArray(aUnifor)
oListID:bLine := {||{If(aUnifor[oListId:nAt][1],oOk,oNo),;
						aUnifor[oListId:nAt][2],;
						aUnifor[oListId:nAt][3],;
						aUnifor[oListId:nAt][4],;
						aUnifor[oListId:nAt][5],;
						aUnifor[oListId:nAt][6],;
						aUnifor[oListId:nAt][7],;
						aUnifor[oListId:nAt][8],;
						aUnifor[oListId:nAt][9],;
						aUnifor[oListId:nAt][10],;
						aUnifor[oListId:nAt][11],;
						aUnifor[oListId:nAt][12],;
						aUnifor[oListId:nAt][13]}}

oListID:bLDblClick := {|| aUnifor[oListId:nAt][1] := IIF(aUnifor[oListId:nAt][1],.F.,.T.), oListID:DrawSelect()}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

If ( lOk )
    GravaUNIF(aUnifor)
EndIf
Return lOk



STATIC FUNCTION GravaUNIF(aUnifor)
Local _ix:=0
Local nSCAN:=0

IF LEN(aItemFUN) == 1 
	IF EMPTY(aItemFUN[1,1])
		aItemFUN:= {}
	ENDIF
ENDIF

FOR _ix:=1 TO LEN(aUnifor)

	IF aUnifor[_ix,1]

	    //		     1     2       3          4         5        6         7               8            9	       10     11       12      13
		//aUnifor = "","Item","Produto","Descrição","Saldo","Cod. CA","Validade CA","Valor Total","ID Movimento","Doc","Serie","Fornece","Loja" 
		//			     1          2            3           4           5          6               7            8           9	      10     11        12      13
		//aItemFUN =  "Item","Cod. Produto","Descrição","Quantidade","Cod. CA","Validade CA","Valor Unitario","Saldo","ID Movimento","Doc","Serie","Fornece","Loja"  

		nScan:= 0
		nScan:= aScan(aItemFUN,{|x| x[1] == aUnifor[_ix,2] .AND. x[9] == aUnifor[_ix,9] .AND. x[10] == aUnifor[_ix,10].AND. x[11] == aUnifor[_ix,11].AND. x[12] == aUnifor[_ix,12].AND. x[13] == aUnifor[_ix,13]})
		IF nScan == 0
			AADD(aItemFUN,{aUnifor[_ix,2],aUnifor[_ix,3],aUnifor[_ix,4],1,aUnifor[_ix,6],aUnifor[_ix,7],aUnifor[_ix,8],aUnifor[_ix,5],aUnifor[_ix,9],aUnifor[_ix,10],aUnifor[_ix,11],aUnifor[_ix,12],aUnifor[_ix,13]})
		ENDIF
	ENDIF

NEXT _ix

oListFUN:SetArray(aItemFUN)
oListFUN:bLine := {|| {	aItemFUN[oListFUN:nAt][1],;
						aItemFUN[oListFUN:nAt][2],;
						aItemFUN[oListFUN:nAt][3],;
						aItemFUN[oListFUN:nAt][4],;
						aItemFUN[oListFUN:nAt][5],;   
						aItemFUN[oListFUN:nAt][6],;                                                     
						aItemFUN[oListFUN:nAt][7],;
						aItemFUN[oListFUN:nAt][8],;
						aItemFUN[oListFUN:nAt][9],;
						aItemFUN[oListFUN:nAt][10],;
						aItemFUN[oListFUN:nAt][11],;
						aItemFUN[oListFUN:nAt][12],;
						aItemFUN[oListFUN:nAt][13]}}

RETURN NIL

//GRAVA RECEBIMENTO DO UNIFORME FUNCIONARIO
User Function GRAVFUN()
LOCAL _lOK	:= .T.
Local _IX   := 0
Local _SQL 	:= ""
Local cCodigo := ""

	_SQL:= " SELECT TOP 1 ZV_CODIG FROM " + RetSQLName( "SZV" ) + " SZV"
 	_SQL+= " WHERE SZV.D_E_L_E_T_='' ORDER BY ZV_CODIG DESC"
 	
	IF SELECT('QSZV') > 0
		QSZV->(DBCLOSEAREA())
	ENDIF
		
	DBUSEAREA(.T.,"TOPCONN"	,TCGENQRY(,,_SQL),'QSZV',.F.,.T.)

	DBSELECTAREA('QSZV')
 	QSZV->(DBGOTOP())
	IF !EMPTY(QSZV->ZV_CODIG)
		cCodigo := QSZV->ZV_CODIG
    ENDIF
	QSZV->(DBCLOSEAREA())
	cCodigo := STRZERO(VAL(cCodigo)+1,9)

	FOR _IX:= 1 TO LEN(aItemFUN)

		RecLock("SZV",.T.)
		SZV->ZV_FILIAL	:= xFilial("SZV")
		SZV->ZV_CODIG	:= cCodigo
		SZV->ZV_EMISSAO	:= dDataDFUN
		SZV->ZV_PROD	:= aItemFUN[_IX,2]
		SZV->ZV_DESCRI	:= Posicione("SB1",1,xFilial("SB1")+aItemFUN[_IX,2],"B1_DESC")
		SZV->ZV_QUANT	:= aItemFUN[_IX,4]
		SZV->ZV_CUSTO1	:= aItemFUN[_IX,7]*aItemFUN[_IX,4]
		SZV->ZV_TM		:= "02" 
		SZV->ZV_CC		:= cCustoFUN
		SZV->ZV_CCDESC	:= cDCTTFUN
		SZV->ZV_LOCAL   := cLOCSZWFUN 
		//SZV->ZV_ENDBK	:= 
		//SZV->ZV_ENDCO	:= 
		//SZV->ZV_NOMRE	:= 
		//SZV->ZV_CPFRE	:= 
		//SZV->ZV_RECBNOM	:= 
		//SZV->ZV_RECBCPF	:= 
		SZV->ZV_GESTO	:= cGestorFUN
		SZV->ZV_CODCA	:= aItemFUN[_IX,5]
		SZV->ZV_VALIC	:= aItemFUN[_IX,6]
		//SZV->ZV_RDEVO	:= 
		//SZV->ZV_CPFRD	:= 
		//SZV->ZV_EUSO	:= 
		SZV->ZV_PRONT	:= cMatric
		SZV->ZV_NOME	:= cNOMEFUNC
		SZV->ZV_FUNCA	:= cFUNCAOFUN
		SZV->ZV_RGFUNC  := cCPFFUN
		SZV->ZV_ITEM	:= aItemFUN[_IX,1]
		SZV->ZV_IDREF   := aItemFUN[_IX,9]
		SZV->ZV_DOC		:= aItemFUN[_IX,10]
		SZV->ZV_SER		:= aItemFUN[_IX,11]
		SZV->ZV_FOR		:= aItemFUN[_IX,12]
		SZV->ZV_LOJ		:= aItemFUN[_IX,13]

		SZV->(MSUNLOCK())																																																																																																				

	NEXT _IX
	MSGINFO("Incluido com sucesso! cod.: "+SZV->ZV_CODIG)

Return _lOK


//INCLUSÃO DEVOLUCAO DE UNIFORME
USER FUNCTION DEVOUNISZV()
Local lOk		 := .F.
Local nSnd       := 15
Local nTLin      := 15
Local oDlg01     as Object
Local oButInv    as Object
Local aButtons   := {}
Local oOk
Local oNo

PRIVATE aItemDevFUN := {}
PRIVATE dDTDEVFUN 	:= dDATABASE
PRIVATE cCLIDEVFUN	:= SPACE(80)
PRIVATE cCCDEVFUN	:= SPACE(9)
PRIVATE cDCCDEVFUN  := SPACE(80)
PRIVATE cGEDEVFUN   := SPACE(80)
PRIVATE cMATDEVFUN 	:= SPACE(6)
PRIVATE cNDEVFUNC	:= SPACE(80)
PRIVATE cFUNDEVFUN 	:= SPACE(80)
PRIVATE cCPFDEVFUN	:= SPACE(11)
PRIVATE CRESPREC 	:= SPACE(80)
PRIVATE cCPFRec 	:= SPACE(11)

	//"Item","Cod. Produto","Descrição","Quantidade","Saldo","Cod. CA","Validade CA","Valor Unitario","ID Movimento","Doc","Serie","Fornece","Loja","C.Custo","Local"
    AADD(aItemDevFUN,{"","","",0,0,"","",CTOD(""),"","","","","","","","",""})
	
	oOk := LoadBitmap( GetResources(), "LBTIK" )
	oNo := LoadBitmap( GetResources(), "LBNO" )

    Define MsDialog oDlg01 Title "Incluir Termo de Devolução Local de Uniformes" From 000,000 To 510,830 Of oDlg01 Pixel
	
	@ 000,000 MSPANEL oPanelLeft OF oDlg01 SIZE 490,825 
	oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
	@ nSnd,010 SAY "Data de Emissão:" SIZE 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet dDTDEVFUN  Picture "@E"  Size 060,010 Pixel OF oPanelLeft WHEN .T.
	nSnd += nTLin

	@ nSnd,010 Say "Matricula:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cMATDEVFUN Picture '@!' Size 060,010 Pixel OF oPanelLeft WHEN .T. VALID(!Empty(cMATDEVFUN) .AND. VALIDFUNDEV(cMATDEVFUN))
	@ nSnd,130 MsGet cNDEVFUNC Picture '@!' Size 150,010 Pixel OF oPanelLeft PIXEL WHEN .F. 
	@ nSnd,285 Say "Função:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,310 MsGet cFUNDEVFUN Picture '@!' Size 100,010 Pixel OF oPanelLeft WHEN .F.
	nSnd += nTLin

	@ nSnd,010 Say "CPF:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cCPFDEVFUN Picture '@!' Size 060,010 Pixel OF oPanelLeft WHEN .F.

	@ nSnd,130 MsGet cCLIDEVFUN Picture '@!' Size 250,010 Pixel OF oPanelLeft PIXEL WHEN .F. 
	nSnd += nTLin

	@ nSnd,010 Say "Custo / Contrato:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cCCDEVFUN Picture '@!' Size 060,010 Pixel OF oPanelLeft WHEN .F. 

	@ nSnd,130 MsGet cDCCDEVFUN Picture '@!' Size 150,010 Pixel OF oPanelLeft PIXEL WHEN .F. 

	@ nSnd,285 SAY "Gestor:" SIZE 080,010 Pixel OF oPanelLeft
	@ nSnd,310 MsGet cGEDEVFUN SIZE 100,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .F.
	nSnd += nTLin

	@ nSnd,010 Say "Resp. Recebimento" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,060 MsGet cRespRec Picture '@!' Size 200,010 Pixel OF oPanelLeft WHEN .T.
	
	@ nSnd,265 Say "CPF Resp. Recebimento" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,330 MsGet cCPFRec SIZE 080,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .T.
	nSnd += nTLin

    @ nSnd,010 Button oButInv    Prompt "Seleciona Produtos"  Size 100, 12 Pixel Action ( BKESTA03C() ) ;
    Message "Seleciona Produtos" Of oPanelLeft
	nSnd += nTLin

	@ nSnd, 010 LISTBOX oListDevFU FIELDS HEADER "Item","Cod. Produto","Descrição","Quantidade","Saldo","Estado de Uso","Cod. CA","Validade CA","Valor Unitario","ID Movimento","Doc","Serie","Fornece","Loja","Emissão","Centro Custo/Contrato","Local" SIZE 400,120  OF oPanelLeft PIXEL 
	
	oListDevFU:SetArray(aItemDevFUN)
	oListDevFU:bLine := {||{aItemDevFUN[oListDevFU:nAt][1],;
							aItemDevFUN[oListDevFU:nAt][2],;
							aItemDevFUN[oListDevFU:nAt][3],;
							aItemDevFUN[oListDevFU:nAt][4],;
							aItemDevFUN[oListDevFU:nAt][5],;   
							aItemDevFUN[oListDevFU:nAt][6],;                                                     
							aItemDevFUN[oListDevFU:nAt][7],;
							aItemDevFUN[oListDevFU:nAt][8],;
							aItemDevFUN[oListDevFU:nAt][9],;
							aItemDevFUN[oListDevFU:nAt][10],;
							aItemDevFUN[oListDevFU:nAt][11],;
							aItemDevFUN[oListDevFU:nAt][12],;
							aItemDevFUN[oListDevFU:nAt][13],;
							aItemDevFUN[oListDevFU:nAt][14],;
							aItemDevFUN[oListDevFU:nAt][15],;
							aItemDevFUN[oListDevFU:nAt][16],;
							aItemDevFUN[oListDevFU:nAt][17]}}

	oListDevFU:bLDblClick := {|| EDDEVFUN(@aItemDevFUN),oListDevFU:DrawSelect(), }
	
	ACTIVATE MSDIALOG oDlg01 CENTERED Valid(ValDevFUN()) ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

	If ( lOk )
		lOk:=.F.
		If u_MsgLog("INCLSZV","Confirma a Inclusão da Devolução de Uniforme/EPI ?","Y")
			IF U_GRAVDEVFUN()
				U_PRINTSZV()
			ENDIF
		ENDIF
	Endif

RETURN lOk

STATIC FUNCTION VALIDFUNDEV(cNUMMATRI)
Local lOK := .T.
Local cQuery := ""

	cQuery  := "SELECT TOP 1 bk_senior.bk_senior.r034fun.numcad,bk_senior.bk_senior.r034fun.nomfun,numcpf,"
	cQuery  += " right('00' + cast(bk_senior.bk_senior.r034fun.numemp as varchar(2)),2) AS cEmp, "
	cQuery  += " right('000' + cast(bk_senior.bk_senior.R030FIL.CodFil as varchar(3)),3) AS cFil, " 
	cQuery  += " (SELECT BKIntegraRubi.dbo.fnCCSiga(bk_senior.bk_senior.r034fun.numemp,bk_senior.bk_senior.r034fun.tipcol,bk_senior.bk_senior.r034fun.numcad, 'CLT') AS Expr1) AS CCSiga, "
	cQuery  += " bk_senior.bk_senior.R030FIL.NomFil,bk_senior.bk_senior.R024CAR.TitCar"
	cQuery  += " FROM  bk_senior.bk_senior.r034fun "
	cQuery  += " INNER JOIN bk_senior.bk_senior.R030FIL ON bk_senior.bk_senior.r034fun.numemp = bk_senior.bk_senior.R030FIL.NumEmp "
	cQuery  += " AND bk_senior.bk_senior.r034fun.codfil = bk_senior.bk_senior.R030FIL.CodFil "
	cQuery  += " LEFT JOIN bk_senior.bk_senior.R016HIE ON bk_senior.bk_senior.R016HIE.NumLoc =bk_senior.bk_senior.r034fun.numloc "
 	cQuery  += " LEFT JOIN bk_senior.bk_senior.R024CAR ON 	bk_senior.bk_senior.r034fun.codcar = bk_senior.bk_senior.R024CAR.CodCar"
 	cQuery  += " AND bk_senior.bk_senior.R024CAR.EstCar = 1"
	cQuery  += " WHERE bk_senior.bk_senior.r034fun.tipcol ='1' AND bk_senior.bk_senior.r034fun.numcad='"+cNUMMATRI+"' 
	cQuery  += " AND bk_senior.bk_senior.r034fun.numemp='"+SM0->M0_CODIGO+"'"
			
	TCQUERY cQuery NEW ALIAS "Qr034fun"
			
	DbSelectArea("Qr034fun")
	cNDEVFUNC  := ''
	cCCDEVFUN  := ''
	cCPFDEVFUN := ''
	cNDEVFUNC  := Qr034fun->nomfun
	cCCDEVFUN  := Qr034fun->CCSiga
	cCPFDEVFUN := STRZERO(Qr034fun->numcpf,11)
	cFUNDEVFUN := Qr034fun->TitCar
	Qr034fun->(dbCloseArea())


	DBSELECTAREA("CN9")
	CN9->(DBSETORDER(1))
	CN9->(MsSEEK(xFILIAL("CN9")+cCCDEVFUN))
	DO WHILE CN9->(!EOF())  .AND. ALLTRIM(CN9->CN9_NUMERO) == ALLTRIM(cCCDEVFUN)
		cCLIDEVFUN := TRIM(CN9->CN9_NOMCLI)
		cDCCDEVFUN := TRIM(CN9->CN9_XXDESC)
		cGEDEVFUN  := TRIM(CN9->CN9_XXNRBK)
		CN9->(dbSkip())
	ENDDO

	IF EMPTY(cCLIDEVFUN)
		DBSELECTAREA("CTT")
		CTT->(DBSETORDER(1))
		IF CTT->(MsSEEK(xFILIAL("CTT")+cCCDEVFUN))
			cCLIDEVFUN   := "Centro de Custo"
			cDCCDEVFUN   := CTT->CTT_DESC01
			cGEDEVFUN := SPACE(80)
			lOK := .T.
		ELSE
			cCLIDEVFUN   := SPACE(80)
			cDCCDEVFUN   := SPACE(80)
			cGEDEVFUN := SPACE(80)
			lOK := .F.
			MSGSTOP("Centro de Custo ou Contrato não Encontrado!", "Atenção" )
		ENDIF
	ELSE
		lOK := .T.
	ENDIF

RETURN lOK


//ALTERA QUANTIDADE SELECTIONADO DE PRODUTO PARA DEVOLUSÃO FUNCIONNÁRIO
STATIC FUNCTION EDDEVFUN(aItemDevFUN)
LOCAL _IX := 0
LOCAL cMensag := ""

lEditCell(aItemDevFUN,oListDevFU,'@E 999',4)
lEditCell(aItemDevFUN,oListDevFU,'@!',6)

FOR _IX := 1 TO LEN(aItemDevFUN)
	IF aItemDevFUN[_IX,4]  > aItemDevFUN[_IX,5]
		cMensag := " Quantidade maior que o Saldo Entregue. Verifique!"+CRLF
	ENDIF
	IF !(aItemDevFUN[_IX,6] $ "RB") //RUIM OU BOM
		cMensag := "  Estado de Uso Incorreto, utilizar B=Bom ou R=Ruim. Verifique!"+CRLF
	ENDIF
NEXT
IF !EMPTY(cMensag)
	MSGSTOP(cMensag,"Atenção!")
ENDIF

RETURN NIL


STATIC FUNCTION ValDevFUN()
LOCAL lOK := .T.
LOCAL cMensag := ""
LOCAL _IX := 0

IF EMPTY(ALLTRIM(cNDEVFUNC))
	cMensag += "Matrícula do Funcionário não informado."+CRLF
	lOK := .F.
ENDIF
IF EMPTY(ALLTRIM(cCCDEVFUN))
	cMensag += "Centro de Custo / Contrato não informado."+CRLF
	lOK := .F.
ENDIF
IF EMPTY(ALLTRIM(cCPFDEVFUN))
	cMensag += "CPF do Funcionário não informado."+CRLF
	lOK := .F.
ENDIF
IF EMPTY(ALLTRIM(CRESPREC))
	cMensag += "Responsavel pelo recebimento não informado."+CRLF
	lOK := .F.
ENDIF
IF EMPTY(ALLTRIM(cCPFRec))
	cMensag += "CPF do Responsavel pelo recebimento não informado."+CRLF
	lOK := .F.
ELSE
	IF !ChkCPF(ALLTRIM(cCPFRec))
		cMensag += "CPF do Responsavel pelo recebimento Inválido."+CRLF
		lOK := .F.
	ENDIF
ENDIF
IF LEN(aItemDevFUN) <= 0
	cMensag += "Produto não informado."+CRLF
	lOK := .F.
ENDIF
IF LEN(aItemDevFUN) == 1
	IF EMPTY(aItemDevFUN[1,1]) 
		cMensag += "Produto não informado."+CRLF
		lOK := .F.
	ENDIF
ELSEIF lOK
	FOR _IX := 1 TO LEN(aItemDevFUN)
		IF aItemDevFUN[_IX,4]  < 1
			lOK := .F.
		ENDIF
	NEXT 
	IF !lOK
		cMensag += "Quantidade não informada."+CRLF
	ELSE
		FOR _IX := 1 TO LEN(aItemDevFUN)
			IF aItemDevFUN[_IX,4]  > aItemDevFUN[_IX,5]
				cMensag += " Quantidade maior que o Saldo Item: "+aItemDevFUN[_IX,1]+CRLF
				lOK := .F.
			ENDIF
			IF !(aItemDevFUN[_IX,6] $ "RB") //RUIM OU BOM
				cMensag += " Estado de Uso Incorreto, utilizar B=Bom ou R=Ruim Item: "+aItemDevFUN[_IX,1]+CRLF
				lOK := .F.
			ENDIF
		NEXT 
	ENDIF
ENDIF

IF !lOK
	MSGSTOP(cMensag,"Atenção!")
ENDIF

RETURN lOK


//GRAVA RECEBIMENTO DO UNIFORME FUNCIONARIO
User Function GRAVDEVFUN()
LOCAL _lOK	:= .T.
Local _IX   := 0
Local _SQL 	:= ""
Local cCodigo := ""

	_SQL:= " SELECT TOP 1 ZV_CODIG FROM " + RetSQLName( "SZV" ) + " SZV"
 	_SQL+= " WHERE SZV.D_E_L_E_T_='' ORDER BY ZV_CODIG DESC"
 	
	IF SELECT('QSZV') > 0
		QSZV->(DBCLOSEAREA())
	ENDIF
		
	DBUSEAREA(.T.,"TOPCONN"	,TCGENQRY(,,_SQL),'QSZV',.F.,.T.)

	DBSELECTAREA('QSZV')
 	QSZV->(DBGOTOP())
	IF !EMPTY(QSZV->ZV_CODIG)
		cCodigo := QSZV->ZV_CODIG
    ENDIF
	QSZV->(DBCLOSEAREA())
	cCodigo := STRZERO(VAL(cCodigo)+1,9)

	FOR _IX:= 1 TO LEN(aItemDevFUN)

		RecLock("SZV",.T.)
		SZV->ZV_FILIAL	:= xFilial("SZV")
		SZV->ZV_CODIG	:= cCodigo
		SZV->ZV_EMISSAO	:= dDTDEVFUN 
		SZV->ZV_PROD	:= aItemDevFUN[_IX,2]
		SZV->ZV_DESCRI	:= Posicione("SB1",1,xFilial("SB1")+aItemDevFUN[_IX,2],"B1_DESC")
		SZV->ZV_QUANT	:= aItemDevFUN[_IX,4]
		SZV->ZV_CUSTO1	:= aItemDevFUN[_IX,9]*aItemDevFUN[_IX,4]
		SZV->ZV_TM		:= "03" 
		SZV->ZV_CC		:= aItemDevFUN[_IX,16]
		SZV->ZV_CCDESC	:= Posicione("CTT",1,xFilial("CTT")+aItemDevFUN[_IX,16],"CTT_DESC01")
		SZV->ZV_LOCAL   := aItemDevFUN[_IX,17]
		//SZV->ZV_ENDBK	:= 
		//SZV->ZV_ENDCO	:= 
		//SZV->ZV_NOMRE	:= 
		//SZV->ZV_CPFRE	:= 
		//SZV->ZV_RECBNOM	:= 
		//SZV->ZV_RECBCPF	:= 
		SZV->ZV_GESTO	:= cGEDEVFUN
		SZV->ZV_CODCA	:= aItemDevFUN[_IX,7]
		SZV->ZV_VALIC	:= aItemDevFUN[_IX,8]
		SZV->ZV_RDEVO	:= CRESPREC
		SZV->ZV_CPFRD	:= cCPFRec
		SZV->ZV_EUSO	:= aItemDevFUN[_IX,6]
		SZV->ZV_PRONT	:= cMATDEVFUN
		SZV->ZV_NOME	:= cNDEVFUNC
		SZV->ZV_FUNCA	:= cFUNDEVFUN
		SZV->ZV_RGFUNC  := cCPFDEVFUN
		SZV->ZV_ITEM	:= aItemDevFUN[_IX,1]
		SZV->ZV_IDREF   := aItemDevFUN[_IX,10]
		SZV->ZV_DOC		:= aItemDevFUN[_IX,11]
		SZV->ZV_SER		:= aItemDevFUN[_IX,12]
		SZV->ZV_FOR		:= aItemDevFUN[_IX,13]
		SZV->ZV_LOJ		:= aItemDevFUN[_IX,14]
		SZV->(MSUNLOCK())

	NEXT _IX
	MSGINFO("Incluido com sucesso! cod.: "+SZV->ZV_CODIG)

Return _lOK



STATIC FUNCTION BKESTA03C()
Local oOk
Local oNo
Local oDlg
Local oListId
Local oPanelLeft
Local lAll
Local oAll
Local aButtons := {}
Local lOk      := .F.
Local aDevUnifor  := {}
Local cTitulo   :=  "Selecionar Produtos Devolução / Uniformes /EPI"
Local cQuery	:= ""
Local nSaldo := 0

	cQuery := " SELECT ZV_ITEM,ZV_PROD,ZV_PRONT,ZV_QUANT,ZV_CODCA,ZV_VALIC,ZV_CUSTO1,ZV_CODIG,ZV_DOC,ZV_SER,ZV_FOR,ZV_LOJ,ZV_EMISSAO,ZV_CC,ZV_LOCAL,"
	cQuery += " (SELECT SUM(ZV_QUANT)  FROM "+RetSqlName("SZV")+" SZV2 "
	cQuery += " WHERE SZV2.D_E_L_E_T_='' AND SZV2.ZV_TM='03' AND SZV2.ZV_IDREF=SZV.ZV_CODIG AND SZV2.ZV_DOC=SZV.ZV_DOC"
	cQuery += " AND SZV2.ZV_SER=SZV.ZV_SER AND SZV2.ZV_FOR=SZV.ZV_FOR AND SZV2.ZV_LOJ=SZV.ZV_LOJ AND SZV2.ZV_CC=SZV.ZV_CC AND SZV2.ZV_PRONT=SZV.ZV_PRONT"
	cQuery += " AND SZV2.ZV_LOCAL=SZV.ZV_LOCAL AND SZV2.ZV_ITEM=SZV.ZV_ITEM) AS QUANT_D"
	cQuery += " FROM "+RetSqlName("SZV")+" SZV "
	cQuery += " WHERE SZV.D_E_L_E_T_=''  AND SZV.ZV_TM='02'"
	cQuery += " AND SZV.ZV_PRONT='"+cMATDEVFUN+"'"
	cQuery += " ORDER BY ZV_EMISSAO,ZV_PROD"


	IF SELECT('QSZVDEV') > 0
		QSZVDEV->(DBCLOSEAREA())
	ENDIF
		
	DBUSEAREA(.T.,"TOPCONN"	,TCGENQRY(,,cQuery),'QSZVDEV',.F.,.T.)
	TCSETFIELD("QSZVDEV","ZV_EMISSAO","D",8,0)
	TCSETFIELD("QSZVDEV","ZV_VALIC","D",8,0)
	
	aDevUnifor := {}
	DBSELECTAREA('QSZVDEV')
	QSZVDEV->(Dbgotop())
	while ! QSZVDEV->( EOF() )
		nSaldo := 0
		nSaldo := QSZVDEV->ZV_QUANT - QSZVDEV->QUANT_D

		IF nSaldo > 0 
			//"","Item","Cod. Produto","Descrição","Quantidade","Saldo","Estado de Uso","Cod. CA","Validade CA","Valor Unitario","ID Movimento","Doc","Serie","Fornece","Loja","Emissão","C.Custo","Local" 
			AADD(aDevUnifor,{.F.,QSZVDEV->ZV_ITEM,QSZVDEV->ZV_PROD,Posicione("SB1",1,xFilial("SB1")+QSZVDEV->ZV_PROD,"B1_DESC"),nSaldo,"R",QSZVDEV->ZV_CODCA,QSZVDEV->ZV_VALIC,QSZVDEV->ZV_CUSTO1/nSaldo,QSZVDEV->ZV_CODIG,QSZVDEV->ZV_DOC,QSZVDEV->ZV_SER,QSZVDEV->ZV_FOR,QSZVDEV->ZV_LOJ,QSZVDEV->ZV_EMISSAO,QSZVDEV->ZV_CC,QSZVDEV->ZV_LOCAL})
		ENDIF
		QSZVDEV->(DBSKIP())
	ENDDO
	QSZVDEV->(DBCLOSEAREA())

	IF LEN(aDevUnifor) == 0
		MSGSTOP("Não existe movimentos para o funcionário informado. Verifique!")
		AADD(aDevUnifor,{.F.,"","","",0,"","",CTOD(""),"","","","","","","","",""})
	ENDIF


oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 450,830 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 430,825 
oPanelLeft:Align := CONTROL_ALIGN_LEFT

lAll := .F.
@ 005, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
oAll:bChange := {|| Aeval(aDevUnifor,{|x| x[1]:=lAll }), oListId:Refresh()}


@ 015, 010 LISTBOX oListId FIELDS HEADER "","Item","Cod. Produto","Descrição","Saldo","Estado de Uso","Cod. CA","Validade CA","Valor Unitario","ID Movimento","Doc","Serie","Fornece","Loja","Emissão","Centro Custo/Contrato","Local" SIZE 400,180 OF oPanelLeft PIXEL 

oListId:SetArray(aDevUnifor)
oListId:bLine :=  {||{If(aDevUnifor[oListId:nAt][1],oOk,oNo),;
						aDevUnifor[oListId:nAt][2],;
						aDevUnifor[oListId:nAt][3],;
						aDevUnifor[oListId:nAt][4],;
						aDevUnifor[oListId:nAt][5],;   
						aDevUnifor[oListId:nAt][6],;                                                     
						aDevUnifor[oListId:nAt][7],;
						aDevUnifor[oListId:nAt][8],;
						aDevUnifor[oListId:nAt][9],;
						aDevUnifor[oListId:nAt][10],;
						aDevUnifor[oListId:nAt][11],;
						aDevUnifor[oListId:nAt][12],;
						aDevUnifor[oListId:nAt][13],;
						aDevUnifor[oListId:nAt][14],;
						aDevUnifor[oListId:nAt][15],;
						aDevUnifor[oListId:nAt][16],;
					    aDevUnifor[oListId:nAt][17]}}

oListID:bLDblClick := {|| aDevUnifor[oListId:nAt][1] := IIF(aDevUnifor[oListId:nAt][1],.F.,.T.), oListID:DrawSelect()}

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , aButtons)

If ( lOk )
    GrvDevUNIF(aDevUnifor)
EndIf
Return lOk



STATIC FUNCTION GrvDevUNIF(aDevUnifor)
Local _ix:=0
Local nSCAN:=0

IF LEN(aItemDevFUN) == 1 
	IF EMPTY(aItemDevFUN[1,1])
		aItemDevFUN:= {}
	ENDIF
ENDIF

FOR _ix:=1 TO LEN(aDevUnifor)

	IF aDevUnifor[_ix,1]

	    //		        1    2           3          4         5             6           7          8            9	                 10         11     12       13      14       15              16              17
		//aDevUnifor = "","Item","Cod. Produto","Descrição","Saldo","Estado de Uso","Cod. CA","Validade CA","Valor Unitario","ID Movimento","Doc","Serie","Fornece","Loja","Emissão","Centro Custo/Contrato","Local"
	    //		             1           2           3         4            5           6           7           8              9	           10         11     12       13      14       15              16              17
		//aItemDevFUN =   "Item","Cod. Produto","Descrição","Quantidade","Saldo","Estado de Uso","Cod. CA","Validade CA","Valor Unitario","ID Movimento","Doc","Serie","Fornece","Loja","Emissão","Centro Custo/Contrato","Local"

		nScan:= 0
		nScan:= aScan(aItemDevFUN,{|x| x[1] == aDevUnifor[_ix,2] .AND. x[10] == aDevUnifor[_ix,10] .AND. x[11] == aDevUnifor[_ix,11].AND. x[12] == aDevUnifor[_ix,12].AND. x[13] == aDevUnifor[_ix,13] .AND. x[14] == aDevUnifor[_ix,14] .AND. x[16] == aDevUnifor[_ix,16] .AND. x[17] == aDevUnifor[_ix,17]})
		IF nScan == 0
			AADD(aItemDevFUN,{aDevUnifor[_ix,2],aDevUnifor[_ix,3],aDevUnifor[_ix,4],1,aDevUnifor[_ix,5],aDevUnifor[_ix,6],aDevUnifor[_ix,7],aDevUnifor[_ix,8],aDevUnifor[_ix,9],aDevUnifor[_ix,10],aDevUnifor[_ix,11],aDevUnifor[_ix,12],aDevUnifor[_ix,13],aDevUnifor[_ix,14],aDevUnifor[_ix,15],aDevUnifor[_ix,16],aDevUnifor[_ix,17]})
		ENDIF
	ENDIF

NEXT _ix

oListDevFU:SetArray(aItemDevFUN)
oListDevFU:bLine := {||{aItemDevFUN[oListDevFU:nAt][1],;
						aItemDevFUN[oListDevFU:nAt][2],;
						aItemDevFUN[oListDevFU:nAt][3],;
						aItemDevFUN[oListDevFU:nAt][4],;
						aItemDevFUN[oListDevFU:nAt][5],;   
						aItemDevFUN[oListDevFU:nAt][6],;                                                     
						aItemDevFUN[oListDevFU:nAt][7],;
						aItemDevFUN[oListDevFU:nAt][8],;
						aItemDevFUN[oListDevFU:nAt][9],;
						aItemDevFUN[oListDevFU:nAt][10],;
						aItemDevFUN[oListDevFU:nAt][11],;
						aItemDevFUN[oListDevFU:nAt][12],;
						aItemDevFUN[oListDevFU:nAt][13],;
						aItemDevFUN[oListDevFU:nAt][14],;
						aItemDevFUN[oListDevFU:nAt][15],;
						aItemDevFUN[oListDevFU:nAt][16],;
						aItemDevFUN[oListDevFU:nAt][17]}}

RETURN NIL


//IMPRIME A RELAÇÃO DE SALDO DOS UNIFORMES
USER FUNCTION RELSALDSZV()
Local aPlans    := {}
Local aTitulos1,aCampos1,aCabs1

Private cTitulo      := "Relação de Saldo de Uniformes"
Private cPerg        := "RELSALDSZV"

u_WaitLog(cPerg, {|oSay| PrcQuery1() }, cTitulo)

aCabs1   := {}
aCampos1 := {}
aTitulos1:= {}

AADD(aTitulos1,"Uniformes")

AADD(aCampos1,"QSZV3->ZV_CC")
AADD(aCabs1  ,"C. Custo ou Contrato")

AADD(aCampos1,"QSZV3->CTT_DESC01")
AADD(aCabs1  ,"Descrição")

AADD(aCampos1,"QSZV3->ZV_LOCAL")
AADD(aCabs1  ,"Cod. Local")

AADD(aCampos1,"QSZV3->ZW_DESC")
AADD(aCabs1  ,"Desc. Local")

AADD(aCampos1,"QSZV3->ZV_EMISSAO")
AADD(aCabs1  ,"Emissão")

AADD(aCampos1,"QSZV3->ZV_PROD")
AADD(aCabs1  ,"Produto")

AADD(aCampos1,"QSZV3->ZV_DESCRI")
AADD(aCabs1  ,"Descrição Prod.")

AADD(aCampos1,"QSZV3->ZV_CODCA")
AADD(aCabs1  ,"CA")

AADD(aCampos1,"QSZV3->ZV_VALIC")
AADD(aCabs1  ,"validade CA")

AADD(aCampos1,"QSZV3->ZV_QUANT")
AADD(aCabs1  ,"Quantidade")

AADD(aCampos1,"QSZV3->SAIDA")
AADD(aCabs1  ,"Quant. Saida")

AADD(aCampos1,"QSZV3->DEVOLVIDA")
AADD(aCabs1  ,"Quant. Devolução")

AADD(aCampos1,"QSZV3->ZV_QUANT - QSZV3->SAIDA + QSZV3->DEVOLVIDA")
AADD(aCabs1  ,"Saldo Atual")

AADD(aPlans,{"QSZV3",cPerg,"",aTitulos1,aCampos1,aCabs1,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })

U_PlanXlsx(aPlans,cTitulo,cPerg,.T.)

Return NIL


Static Function PrcQuery1
Local cQuery

cQuery := "SELECT DISTINCT SZV.ZV_CC,CTT.CTT_DESC01,SZV.ZV_LOCAL,SZW.ZW_DESC,SZV.ZV_EMISSAO,SZV.ZV_ITEM,SZV.ZV_PROD,SZV.ZV_DESCRI,"+ CRLF
cQuery += " SZV.ZV_QUANT,SZV.ZV_CODCA,SZV.ZV_VALIC,SZV.ZV_CUSTO1,SZV.ZV_CODIG," + CRLF

cQuery += " (SELECT SUM(ZV_QUANT)  FROM "+RetSqlName("SZV")+" SZV2 "+ CRLF
cQuery += " WHERE SZV2.D_E_L_E_T_='' AND SZV2.ZV_TM='02' AND SZV2.ZV_IDREF=SZV.ZV_CODIG AND SZV2.ZV_DOC=SZV.ZV_DOC"+ CRLF
cQuery += " AND SZV2.ZV_SER=SZV.ZV_SER AND SZV2.ZV_FOR=SZV.ZV_FOR AND SZV2.ZV_LOJ=SZV.ZV_LOJ AND SZV2.ZV_CC=SZV.ZV_CC"+ CRLF
cQuery += " AND SZV2.ZV_LOCAL=SZV.ZV_LOCAL AND SZV2.ZV_ITEM=SZV.ZV_ITEM) AS SAIDA,"+ CRLF
/*
cQuery += " (SELECT SUM(ZV_QUANT)  FROM "+RetSqlName("SZV")+" SZV3 "+ CRLF
cQuery += " WHERE SZV3.D_E_L_E_T_='' AND SZV3.ZV_TM='03' AND SZV3.ZV_EUSO<>'R' AND SZV3.ZV_IDREF=SZVX.ZV_CODIG AND SZV3.ZV_DOC=SZV.ZV_DOC"+ CRLF
cQuery += " AND SZV3.ZV_SER=SZV.ZV_SER AND SZV3.ZV_FOR=SZV.ZV_FOR AND SZV3.ZV_LOJ=SZV.ZV_LOJ AND SZV3.ZV_CC=SZV.ZV_CC"+ CRLF
cQuery += " AND SZV3.ZV_LOCAL=SZV.ZV_LOCAL AND SZV3.ZV_ITEM=SZV.ZV_ITEM) AS DEVOLVIDA"+ CRLF
*/
cQuery += " (SELECT SUM(SZV3.ZV_QUANT)  FROM "+RetSqlName("SZV")+" SZV3 "+ CRLF
cQuery += "  INNER JOIN "+RetSqlName("SZV")+" SZVX ON SZVX.D_E_L_E_T_='' AND SZVX.ZV_TM='02' AND SZV3.ZV_IDREF=SZVX.ZV_CODIG AND SZVX.ZV_DOC=SZV3.ZV_DOC"+ CRLF
cQuery += " AND SZVX.ZV_SER=SZV3.ZV_SER AND SZVX.ZV_FOR=SZV3.ZV_FOR AND SZVX.ZV_LOJ=SZV3.ZV_LOJ AND SZVX.ZV_CC=SZV3.ZV_CC"+ CRLF
cQuery += " AND SZVX.ZV_LOCAL=SZV3.ZV_LOCAL AND SZVX.ZV_ITEM=SZV3.ZV_ITEM"+ CRLF
cQuery += " WHERE SZV3.D_E_L_E_T_='' AND SZV3.ZV_TM='03' AND SZV3.ZV_EUSO<>'R' AND SZVX.ZV_IDREF=SZV.ZV_CODIG "+ CRLF
cQuery += " AND SZV3.ZV_DOC=SZV.ZV_DOC"+ CRLF
cQuery += " AND SZV3.ZV_SER=SZV.ZV_SER AND SZV3.ZV_FOR=SZV.ZV_FOR AND SZV3.ZV_LOJ=SZV.ZV_LOJ AND SZV3.ZV_CC=SZV.ZV_CC"+ CRLF
cQuery += " AND SZV3.ZV_LOCAL=SZV.ZV_LOCAL AND SZV3.ZV_ITEM=SZV.ZV_ITEM) AS DEVOLVIDA"+ CRLF

cQuery += " FROM "+RETSQLNAME("SZV")+ " SZV" + CRLF
cQuery += " INNER JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT.D_E_L_E_T_=''" + CRLF
cQuery += " AND CTT_CUSTO= ZV_CC" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SZW")+ " SZW ON SZW.D_E_L_E_T_=''" + CRLF
cQuery += " AND ZW_CC= ZV_CC AND ZW_COD= ZV_LOCAL" + CRLF
//cQuery += " LEFT JOIN "+RetSqlName("SZV")+" SZVX ON SZVX.D_E_L_E_T_=''"+ CRLF
//cQuery += " AND SZVX.ZV_TM='02' AND SZVX.ZV_IDREF=SZV.ZV_CODIG AND SZVX.ZV_DOC=SZV.ZV_DOC"+ CRLF
//cQuery += " AND SZVX.ZV_SER=SZV.ZV_SER AND SZVX.ZV_FOR=SZV.ZV_FOR AND SZVX.ZV_LOJ=SZV.ZV_LOJ AND SZVX.ZV_CC=SZV.ZV_CC"+ CRLF
//cQuery += " AND SZVX.ZV_LOCAL=SZV.ZV_LOCAL AND SZVX.ZV_ITEM=SZV.ZV_ITEM"+CRLF
cQuery += " WHERE SZV.D_E_L_E_T_=''  AND SZV.ZV_TM='01'"+CRLF

u_LogMemo("RELSALDSZV.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QSZV3"
TCSETFIELD("QSZV3","ZV_VALIC","D",8,0)

Return nil

USER FUNCTION BXRECEBEU
Local lOk		 := .F.
Local nSnd       := 15
Local nTLin      := 15
Local oDlg01     as Object
Local aButtons   := {}
Local cCODTERMO  := SZV->ZV_CODIG
Local cFuncion   := SZV->ZV_NOME
Local cCPFFUN    := SZV->ZV_RGFUNC

	IF ALLTRIM(SZV->ZV_TM) <> '02'
		MSGINFO("Terno não é de funcionário. Verifique!")
		RETURN lOk
	ENDIF


    Define MsDialog oDlg01 Title "Confirmea o Recebimento TERMO pelo funcionário:"+cCODTERMO From 000,000 To 150,480 Of oDlg01 Pixel
	
	@ 000,000 MSPANEL oPanelLeft OF oDlg01 SIZE 200,460
	oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
	@ nSnd,010 Say "Funcionário: " Size 080,010 Pixel OF oPanelLeft
	@ nSnd,080 MsGet cFuncion Picture '@!' Size 180,010 Pixel OF oPanelLeft WHEN .F.
	nSnd += nTLin

	@ nSnd,010 Say "CPF Funcionario :" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,080 MsGet cCPFFUN SIZE 180,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .F.
	nSnd += nTLin
	
	ACTIVATE MSDIALOG oDlg01 CENTERED  ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

	If ( lOk )
		lOk:=.F.
		If u_MsgLog("BXRESDEV","Confirmea Recebimento pelo funcionário do TERMO:"+cCODTERMO+" ?","Y")

			dbSelectArea("SZV")
			SZV->(dbSetOrder(1))
			dbSeek(xFilial("SZV")+cCODTERMO,.T.)
			Do while !eof() .AND. SZV->ZV_CODIG=cCODTERMO

				RecLock("SZV",.F.)
				SZV->ZV_RECEBEU:=  'S'
				SZV->(MSUNLOCK())

				SZV->(dbSkip())
			Enddo

		ENDIF
	Endif

RETURN lOk

USER FUNCTION BXRESDEV
Local lOk		 := .F.
Local nSnd       := 15
Local nTLin      := 15
Local oDlg01     as Object
Local aButtons   := {}
Local cResReceb  := ""
Local cCPFReceb  := ""
Local cCODTERMO  := SZV->ZV_CODIG


cResReceb := IIF(!EMPTY(SZV->ZV_RECBNOM),SZV->ZV_RECBNOM,SPACE(80))
cCPFReceb := IIF(!EMPTY(SZV->ZV_RECBCPF),SZV->ZV_RECBCPF,SPACE(11))

    Define MsDialog oDlg01 Title "Incluir Responsável pelo Recebimento TERMO:"+cCODTERMO From 000,000 To 150,480 Of oDlg01 Pixel
	
	@ 000,000 MSPANEL oPanelLeft OF oDlg01 SIZE 200,460
	oPanelLeft:Align := CONTROL_ALIGN_LEFT
	
	@ nSnd,010 Say "Resp. Recebimento" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,080 MsGet cResReceb Picture '@!' Size 180,010 Pixel OF oPanelLeft WHEN .T.
	nSnd += nTLin

	@ nSnd,010 Say "CPF Resp. Recebimento:" Size 080,010 Pixel OF oPanelLeft
	@ nSnd,080 MsGet cCPFReceb SIZE 180,010 OF oPanelLeft PIXEL PICTURE '@!' WHEN .T.
	nSnd += nTLin
	
	ACTIVATE MSDIALOG oDlg01 CENTERED Valid(ChkCPF(ALLTRIM(cCPFReceb))) ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

	If ( lOk )
		lOk:=.F.
		If u_MsgLog("BXRESDEV","Confirma a inclusão/Alteração do Resp. Recebimento TERMO:"+cCODTERMO+" ?","Y")

			dbSelectArea("SZV")
			SZV->(dbSetOrder(1))
			dbSeek(xFilial("SZV")+cCODTERMO,.T.)
			Do while !eof() .AND. SZV->ZV_CODIG=cCODTERMO

				RecLock("SZV",.F.)
				SZV->ZV_RECBNOM	:=  cResReceb
				SZV->ZV_RECBCPF	:=  cCPFReceb
				SZV->(MSUNLOCK())

				SZV->(dbSkip())
			Enddo

		ENDIF
	Endif

RETURN lOk



STATIC FUNCTION DTRANSTML(cTermo,dEMISSAO,cMUNIC,cENDEMPR,cCLIENT,cENDCLI,cRESPONS,cCPFRESP,aItens)
LOCAL cTipoTit :="DECLARAÇÃO DE TRANSFERÊNCIA - "+cTermo
Local nHandle   := 0
Local cCrLf     := Chr(13) + Chr(10)
Local cDirTmp   := u_LTmpDir()
Local cArqHtml  := ""
Local aHtml     := {}
Local _nI       := 0
Local nPag 		:= 1
Local cDtExtso  := ""

cDtExtso  := cMUNIC+", "+Day2Str(dEMISSAO)+" de "+MesExtenso(Month(dEMISSAO))+" de "+Year2Str(dEMISSAO)+"."

cLogo := u_BKLogos()

If nPag == 1
	AADD(aHtml,'<html lang="pt-BR">')
	AADD(aHtml,'<head>') 
	AADD(aHtml,'<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">' )
	AADD(aHtml,'<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">' )
	AADD(aHtml,'<title>'+cTipoTit+' - '+DTOC(date())+' '+TIME()+'</title>' )
	AADD(aHtml,'<style type="text/css">')
	AADD(aHtml,'.tg  {border-collapse:collapse;border-spacing:0;margin:auto;}')
	AADD(aHtml,'.tg td{font-family:Arial, sans-serif;font-size:14px;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}')
	AADD(aHtml,'.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}')
	AADD(aHtml,'.tg tr { line-height: 18px; }')
	AADD(aHtml,'.tg .tg-logo{font-weight:bold;font-size:26px;text-align:left;line-height: 40px;}')
	AADD(aHtml,'.tg .tg-empr{font-weight:bold;font-size:26px;text-align:center;line-height: 40px;}')
	AADD(aHtml,'.tg .tg-assin{font-weight:bold;font-size:16px;text-align:center;line-height: 20px;}')
	AADD(aHtml,'.tg .tg-corpo{font-weight:bold;font-size:12px;text-align:justify}')
	AADD(aHtml,'.tg .tg-hndr{font-weight:bold;font-size:12px;background-color:#c0c0c0;text-align:center;vertical-align:top}')
	AADD(aHtml,'.tg .tg-sc{font-size:12px;vertical-align:middle;;text-align:left}')
	AADD(aHtml,'.tg .tg-sc2{font-size:12px;vertical-align:middle;;text-align:center}')
	AADD(aHtml,'.folha {page-break-after:always;page-break-inside:avoid;}')
	AADD(aHtml,'</style>' )
	AADD(aHtml,'</head>' )
	AADD(aHtml,'<body lang=PT-BR>' )
EndIf                                 

AADD(aHtml,'<div class="folha">')

AADD(aHtml,'<table class="tg">')

AADD(aHtml,'<colgroup>')
AADD(aHtml,'<col style="width: 700px">')
AADD(aHtml,'<col style="width: 40px">')
AADD(aHtml,'<col style="width: 40px">')
AADD(aHtml,'<col style="width: 60px">')
AADD(aHtml,'</colgroup>')

AADD(aHtml,'    <tr>')

If EMPTY(cLogo)
	AADD(aHtml,'    <td class="tg-logo" colspan="4">'+FWEmpName(cEmpAnt)+'</td>')
Else
	AADD(aHtml,'    <td class="tg-logo" colspan="4">'+cLogo+'</td>')
Endif
  
AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-empr" colspan="4">'+cTipoTit+'</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-corpo" colspan="4">Declaramos a quem interessar possa, que a Empresa '+ALLTRIM(SM0->M0_NOMECOM)+', estabelecida na')
AADD(aHtml,'      '+cENDEMPR+', devidamente inscrita no CNPJ sob o n° '+TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99")+', é isenta de Inscrição Estadual')
AADD(aHtml,'      , portanto desobrigada de emissão de Nota Fiscal, neste ato e através desta Declaração envia para o')
AADD(aHtml,'      '+cCLIENT+', com endereço à Endereço: '+cENDCLI+',o(s) seguinte(s) bem(ns), abaixo discriminado(s) de nossa')
AADD(aHtml,'      propriedade, para (Conserto, uso de nossos colaboradores, etc.) nesta localidade,')
AADD(aHtml,'      sem valor mercantil:</td>')
AADD(aHtml,'    </tr>')

If Len(aItens) > 0
	AADD(aHtml,'    <tr>')
	AADD(aHtml,'      <td class="tg-hndr">Produto</td>')
	AADD(aHtml,'      <td class="tg-hndr">Unidade</td>')
	AADD(aHtml,'      <td class="tg-hndr">Quantidade</td>')
	AADD(aHtml,'      <td class="tg-hndr">Valor</td>')
	AADD(aHtml,'    </tr>')

	For _nI := 1 To Len(aItens)
		AADD(aHtml,'  <tr>')
		AADD(aHtml,'    <td class="tg-sc">'+aItens[_nI,1]+'</td>')
		AADD(aHtml,'    <td class="tg-sc2">'+aItens[_nI,2]+'</td>')
		AADD(aHtml,'    <td class="tg-sc2">'+TRANSFORM(aItens[_nI,3],"@E 999.99")+'</td>')
		AADD(aHtml,'    <td class="tg-sc2">'+TRANSFORM(aItens[_nI,6],"@E 9,999,999.99")+'</td>')
		AADD(aHtml,'  </tr>')
	Next

EndIf

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-assin" colspan="4">&nbsp;<br>'+cDtExtso+'&nbsp;<br>&nbsp;<br>&nbsp;<br>'+cRESPONS+'<br>'+cCPFRESP+'</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'</table>')


AADD(aHtml,'<p class="tg-sc" colspan="3">BK_FM_026 — Versão 01</p>')


AADD(aHtml,'<br>')

AADD(aHtml,'<br>')
AADD(aHtml,'</div>')

AADD(aHtml,'</body>')
AADD(aHtml,'</html>')


IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   

cArqHtml  := cDirTmp+"DECLARACAO_TRANS_"+ALLTRIM(cTermo)+".HTML"

fErase(cArqHtml)
nHandle := MsfCreate(cArqHtml,0)
If nHandle > 0
	For _nI := 1 TO LEN(aHtml)
		fWrite(nHandle, aHtml[_nI] + cCrLf )
	Next
	fClose(nHandle)
	ShellExecute("open", cArqHtml, "", "", 1)
ENDIF

RETURN NIL

//IMPRIME O TERMO DE RESPONSABILIDADE DE USO EM HTML
STATIC FUNCTION RESPUSO(cTermo,dEMISSAO,cCONTRATO,cGCONTR,cMUNIC,cENDEMPR,cCLIENT,cENDCLI,cRESPONS,cCPFRESP,aItens)
LOCAL cTipoTit :="TERMO DE RESPONSABILIDADE DE USO - "+cTermo
Local nHandle   := 0
Local cCrLf     := Chr(13) + Chr(10)
Local cDirTmp   := u_LTmpDir()
Local cArqHtml  := ""
Local aHtml     := {}
Local _nI       := 0
Local nPag 		:= 1
Local cDtExtso  := ""

cDtExtso  := cMUNIC+", "+Day2Str(dEMISSAO)+" de "+MesExtenso(Month(dEMISSAO))+" de "+Year2Str(dEMISSAO)+"."

cLogo := u_BKLogos()

If nPag == 1
	AADD(aHtml,'<html lang="pt-BR">')
	AADD(aHtml,'<head>') 
	AADD(aHtml,'<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">' )
	AADD(aHtml,'<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">' )
	AADD(aHtml,'<title>'+cTipoTit+' - '+DTOC(date())+' '+TIME()+'</title>' )
	AADD(aHtml,'<style type="text/css">')
	AADD(aHtml,'.tg  {border-collapse:collapse;border-spacing:0;}')
	AADD(aHtml,'.tg td{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;')
	AADD(aHtml,'  overflow:hidden;padding:10px 5px;word-break:normal;}')
	AADD(aHtml,'.tg th{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;')
	AADD(aHtml,'  font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}')
	AADD(aHtml,'.tg .tg-0w9m{font-family:Arial, Helvetica, sans-serif !important;font-weight:bold;text-align:center;vertical-align:top}')
	AADD(aHtml,'.tg .tg-tcrt{font-family:Arial, Helvetica, sans-serif !important;text-align:center;vertical-align:top}')
	AADD(aHtml,'.tg .tg-i7zr{font-family:Arial, Helvetica, sans-serif !important;text-align:left;vertical-align:top}')
	AADD(aHtml,'.tg .tg-sc{font-size:12px;vertical-align:middle;;text-align:left}')
	AADD(aHtml,'.folha {page-break-after:always;page-break-inside:avoid;}')
	AADD(aHtml,'</style>')
EndIf                                 

AADD(aHtml,'<div class="folha">')

AADD(aHtml,'<table class="tg" style="undefined;table-layout: fixed; width: 1257px">')

AADD(aHtml,'<colgroup>')
AADD(aHtml,'<col style="width: 66.2px">')
AADD(aHtml,'<col style="width: 80.2px">')
AADD(aHtml,'<col style="width: 300.2px">')
AADD(aHtml,'<col style="width: 80.2px">')
AADD(aHtml,'<col style="width: 80.2px">')
AADD(aHtml,'<col style="width: 100.2px">')
AADD(aHtml,'<col style="width: 66.2px">')
AADD(aHtml,'<col style="width: 80.2px">')
AADD(aHtml,'<col style="width: 88.2px">')
AADD(aHtml,'<col style="width: 100.2px">')
AADD(aHtml,'</colgroup>')

AADD(aHtml,'<thead>')
AADD(aHtml,'  <tr>')

If EMPTY(cLogo)
	AADD(aHtml,'    <th class="tg-i7zr" colspan="3">'+FWEmpName(cEmpAnt)+'</th>')
Else
	AADD(aHtml,'    <th class="tg-i7zr" colspan="3">'+cLogo+'</th>')
Endif

AADD(aHtml,'    <th class="tg-0w9m" colspan="7">'+cTipoTit+'</th>')
AADD(aHtml,'  </tr>')
AADD(aHtml,'</thead>')

AADD(aHtml,'<tbody>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-i7zr" colspan="3">Cliente/Depto: '+cCLIENT+'</td>')
AADD(aHtml,'    <td class="tg-i7zr" colspan="3">Local: '+cENDCLI+'</td>')
AADD(aHtml,'    <td class="tg-i7zr" colspan="4">Setor:</td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-i7zr" colspan="2">Contrato N°: '+cCONTRATO+'</td>')
AADD(aHtml,'    <td class="tg-i7zr" colspan="4">Gestor do Contrato: '+cGCONTR+'</td>')
AADD(aHtml,'    <td class="tg-i7zr" colspan="4">Preposto:</td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-0w9m" colspan="6">ENTREGA DO PATRIMÔNIO</td>')
AADD(aHtml,'    <td class="tg-tcrt" colspan="4">DEVOLUÇÃO DO PATRIMÔNIO</td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-tcrt" rowspan="2">Qtde</td>')
AADD(aHtml,'    <td class="tg-tcrt" rowspan="2">N° Patrimônio</td>')
AADD(aHtml,'    <td class="tg-i7zr" rowspan="2">Descrição (especificar Marca / Tamanho / Modelo)</td>')
AADD(aHtml,'    <td class="tg-tcrt" colspan="2">Estado de Uso</td>')
AADD(aHtml,'    <td class="tg-tcrt" rowspan="2">Data</td>')
AADD(aHtml,'    <td class="tg-tcrt" rowspan="2">Qtde</td>')
AADD(aHtml,'    <td class="tg-tcrt" colspan="2">Estado de uso</td>')
AADD(aHtml,'    <td class="tg-tcrt" rowspan="2">Data</td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-tcrt">Bom</td>')
AADD(aHtml,'    <td class="tg-tcrt">Ruim</td>')
AADD(aHtml,'    <td class="tg-tcrt">Bom</td>')
AADD(aHtml,'    <td class="tg-tcrt">Ruim</td>')
AADD(aHtml,'  </tr>')

For _nI := 1 To Len(aItens)
	cINFCOMPL := ""
	IF !EMPTY(aItens[_nI,4])
		cINFCOMPL += " - CA "+aItens[_nI,4]
	ENDIF
	IF !EMPTY(aItens[_nI,5])
		cINFCOMPL += " - Validade: "+DTOC(aItens[_nI,5])
	ENDIF
	AADD(aHtml,'  <tr>')
	AADD(aHtml,'    <td class="tg-tcrt">'+TRANSFORM(aItens[_nI,3],"@E 999")+'</td>')
	AADD(aHtml,'    <td class="tg-tcrt">N.A</td>')
	AADD(aHtml,'    <td class="tg-i7zr">'+aItens[_nI,1]+cINFCOMPL+'</td>')
	AADD(aHtml,'    <td class="tg-tcrt">X</td>')
	AADD(aHtml,'    <td class="tg-tcrt"></td>')
	AADD(aHtml,'    <td class="tg-tcrt">'+DTOC(dEMISSAO)+'</td>')
	AADD(aHtml,'    <td class="tg-tcrt"></td>')
	AADD(aHtml,'    <td class="tg-tcrt"></td>')
	AADD(aHtml,'    <td class="tg-tcrt"></td>')
	AADD(aHtml,'    <td class="tg-tcrt"></td>')
	AADD(aHtml,'  </tr>')
Next

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-i7zr" colspan="6">Declaro que recebi os itens de patrimônio abaixo relacionados e me responsabilizo pela aplicação e ouso exclusivo na prestação dos serviços para o qual foi contratada a BK Consultoria e Servi os Ltda, bem como em .0.Rnicar ao Gestor do Contrato/Gestor Patrimonial, toda manutenção, alteração e/ou movimentação necessária a qualquer dos bens sob minha responsabilidade.</td>')
AADD(aHtml,'    <td class="tg-tcrt" colspan="4">Declaro que recebi em devolução os equipamentos relacionados e me responsabilizo pela sua entrega à Área de Patrimônio</td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-i7zr" colspan="6">Nome:</td>')
AADD(aHtml,'    <td class="tg-i7zr" colspan="4">Nome:</td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-i7zr" colspan="6">CPF:<br></td>')
AADD(aHtml,'    <td class="tg-i7zr" colspan="4">CPF:</td>')
AADD(aHtml,'  </tr>')
AADD(aHtml,'</tbody>')
AADD(aHtml,'</table>')

AADD(aHtml,'<p class="tg-sc" colspan="3">BK FM_020_ Termo de Responsabilidade de Uso_v2_24/09/2018</p>')

AADD(aHtml,'<br>')

AADD(aHtml,'<br>')
AADD(aHtml,'</div>')

AADD(aHtml,'</body>')
AADD(aHtml,'</html>')

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   

cArqHtml  := cDirTmp+"TERMO_RESP_USO_"+ALLTRIM(cTermo)+".HTML"

fErase(cArqHtml)
nHandle := MsfCreate(cArqHtml,0)
If nHandle > 0
	For _nI := 1 TO LEN(aHtml)
		fWrite(nHandle, aHtml[_nI] + cCrLf )
	Next
	fClose(nHandle)
	ShellExecute("open", cArqHtml, "", "", 1)
ENDIF

RETURN NIL

// IMPRIME O TERMO DE RECEBIMENTO LOCAL DE UNIFORMES HTML
STATIC FUNCTION RECEBUNIFORME(cTermo,dEMISSAO,cCONTRATO,cFuncionario,c_CPFFUN,cMATR,cFUNCAO,aItens)
LOCAL cTipoTit  := "TERMO DE RECEBIMENTO LOCAL DE UNIFORMES - "+cTermo
Local nHandle   := 0
Local cCrLf     := Chr(13) + Chr(10)
Local cDirTmp   := u_LTmpDir()
Local cArqHtml  := ""
Local aHtml     := {}
Local _nI       := 0
Local nPag 		:= 1
Local cDtExtso  := ""
Local cEMPRESA  := ALLTRIM(SM0->M0_NOMECOM)
Local cEndEmpres := SM0->M0_ENDENT+"  "+Rtrim(SM0->M0_CIDENT)+"  - "+SM0->M0_ESTENT+" - CEP "+Trans(Alltrim(SM0->M0_CEPENT),PesqPict("SA2","A2_CEP"))


cDtExtso  := Day2Str(dEMISSAO)+" de "+MesExtenso(Month(dEMISSAO))+" de "+Year2Str(dEMISSAO)+"."

cLogo := u_BKLogos()

If nPag == 1
	AADD(aHtml,'<html lang="pt-BR">')
	AADD(aHtml,'<head>') 
	AADD(aHtml,'<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">' )
	AADD(aHtml,'<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">' )
	AADD(aHtml,'<title>'+cTipoTit+' - '+DTOC(date())+' '+TIME()+'</title>' )
	AADD(aHtml,'<style type="text/css">' )
	AADD(aHtml,'.tg  {border-collapse:collapse;border-color:#aabcfe;border-spacing:0;}' )
	AADD(aHtml,'.tg td{background-color:#e8edff;border-color:#aabcfe;border-style:solid;border-width:1px;color:#669;' )
  	AADD(aHtml,'font-family:Arial, sans-serif;font-size:14px;overflow:hidden;padding:10px 5px;word-break:normal;}' )
	AADD(aHtml,'.tg th{background-color:#b9c9fe;border-color:#aabcfe;border-style:solid;border-width:1px;color:#039;' )
  	AADD(aHtml,'font-family:Arial, sans-serif;font-size:14px;font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}' )
	AADD(aHtml,'.tg .tg-2amj{background-color:#ffffff;border: none;font-family:Arial, Helvetica, sans-serif !important;font-size:14px;text-align:left;' )
  	AADD(aHtml,'vertical-align:top}' )
	AADD(aHtml,'.tg .tg-1kq3{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;text-align:center;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-iejx{background-color:#ffffff;border-color:#ffffff;font-family:Arial, Helvetica, sans-serif !important;font-size:14px;' )
  	AADD(aHtml,'text-align:left;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-2e78{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:center;vertical-align:bottom}' )
	AADD(aHtml,'.tg .tg-u7bl{background-color:#ffffff;border-color:#ffffff;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;text-align:left;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-dek0{background-color:#ffffff;border-color:#ffffff;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;text-align:left;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-w959{background-color:#ffffff;border-color:#ffffff;color:#ffffff;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:left;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-4aw3{background-color:#ffffff;border-color:#ffffff;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;text-align:center;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-f4uc{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:center;vertical-align:bottom}' )
	AADD(aHtml,'.tg .tg-ohsq{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:center;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-rfxw{background-color:#FFF;border-color:#ffffff;font-family:Arial, Helvetica, sans-serif !important;font-size:14px;' )
  	AADD(aHtml,'text-align:left;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-dfok{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;text-align:right;vertical-align:top}')
	AADD(aHtml,'.tg .tg-fy3d{background-color:#ffffff;border: none;color:#000000;font-family:Arial, Helvetica, sans-serif !important;font-size:14px;' )
  	AADD(aHtml,'text-align:left;vertical-align:top}')
	AADD(aHtml,'.tg .tg-uymm{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:center;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-uymc{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:center;vertical-align:center}' )
	AADD(aHtml,'.tg .tg-0ep5{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:center;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-uuna{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;font-size:14px;' )
  	AADD(aHtml,'text-align:left;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-uunn{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;font-size:14px;' )
  	AADD(aHtml,'text-align:center;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-3s9g{background-color:#ffffff;border-color:#ffffff;font-family:Arial, Helvetica, sans-serif !important;font-size:14px;' )
  	AADD(aHtml,'text-align:left;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-9cio{background-color:#ffffff;border-color:#ffffff;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:left;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-ur1u{background-color:#ffffff;border-color:#ffffff;color:#000000;font-family:Arial, Helvetica, sans-serif !important;font-size:14px;' )
  	AADD(aHtml,'text-align:center;vertical-align:bottom}' )
	AADD(aHtml,'.tg .tg-ena9{background-color:#ffffff;border-color:#ffffff;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:center;vertical-align:top}' )
	AADD(aHtml,'</style>')
EndIf                                 

AADD(aHtml,'<div class="folha">')

AADD(aHtml,'<table class="tg" style="undefined;table-layout: fixed; width: 1294px">')

AADD(aHtml,'<colgroup>')
AADD(aHtml,'<col style="width: 29.2px">')
AADD(aHtml,'<col style="width: 218.2px">')
AADD(aHtml,'<col style="width: 55.2px">')
AADD(aHtml,'<col style="width: 153.2px">')
AADD(aHtml,'<col style="width: 134.2px">')
AADD(aHtml,'<col style="width: 201.2px">')
AADD(aHtml,'<col style="width: 147.2px">')
AADD(aHtml,'<col style="width: 158.2px">')
AADD(aHtml,'<col style="width: 169.2px">')
AADD(aHtml,'<col style="width: 28.2px">')
AADD(aHtml,'</colgroup>')

AADD(aHtml,'<thead>')
AADD(aHtml,'  <tr>')

If EMPTY(cLogo)
	AADD(aHtml,'    <th class="tg-1kq3" colspan="2">'+FWEmpName(cEmpAnt)+'</th>')
Else
	AADD(aHtml,'    <th class="tg-1kq3" colspan="2">'+cLogo+'</th>')
Endif

AADD(aHtml,'    <th class="tg-ohsq" colspan="6">'+cTipoTit+'</th>')
AADD(aHtml,'    <th class="tg-dfok" colspan="2">BK_FM_016_V6 18/11/2020</th>')
AADD(aHtml,'  </tr>')
AADD(aHtml,'</thead>')
AADD(aHtml,'<tbody>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-2amj"></td>')
AADD(aHtml,'    <td class="tg-fy3d" colspan="8">Contrato n° '+cCONTRATO+'<br>Eu, '+cFuncionario+', portador do CPF n° '+c_CPFFUN+', n° de Registro '+cMATR+', contratado para a funçao de '+cFUNCAO+' declaro ter recebido da empresa '+cEMPRESA+', os uniformes descritos conforme tabela abaixo:</td>')
AADD(aHtml,'    <td class="tg-2amj"></td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-2amj" rowspan="2"></td>')
AADD(aHtml,'    <td class="tg-2e78" rowspan="2">Uniforme Tipo</td>')
AADD(aHtml,'    <td class="tg-f4uc" rowspan="2">Qtde.</td>')
AADD(aHtml,'    <td class="tg-f4uc" rowspan="2">Valor Unitário R$</td>')
AADD(aHtml,'    <td class="tg-f4uc" rowspan="2">Numero do CA</td>')
AADD(aHtml,'    <td class="tg-f4uc" rowspan="2">Data Vencimento do CA</td>')
AADD(aHtml,'    <td class="tg-uymm" colspan="3">DEPRECIAÇÃO</td>')
AADD(aHtml,'    <td class="tg-2amj"></td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-0ep5">Até 6 Meses</td>')
AADD(aHtml,'    <td class="tg-0ep5">6 Meses a 01 ano</td>')
AADD(aHtml,'    <td class="tg-0ep5">Acima de 01 Ano</td>')
AADD(aHtml,'    <td class="tg-2amj"></td>')
AADD(aHtml,'  </tr>')


For _nI := 1 To Len(aItens)
	AADD(aHtml,'  <tr>')
	AADD(aHtml,'    <td class="tg-2amj"></td>')
	AADD(aHtml,'    <td class="tg-uuna">'+aItens[_nI,1]+'</td>')
	AADD(aHtml,'    <td class="tg-uunn">'+TRANSFORM(aItens[_nI,3],"@E 999")+'</td>')
	AADD(aHtml,'    <td class="tg-uunn">'+TRANSFORM(aItens[_nI,6],"@E 9,999.00")+'</td>')
	AADD(aHtml,'    <td class="tg-uunn">'+aItens[_nI,4]+'</td>')
	AADD(aHtml,'    <td class="tg-uunn">'+DTOC(aItens[_nI,5])+'</td>')
	IF _ni == 1 
		AADD(aHtml,'    <td class="tg-uymc" rowspan="'+TRIM(STR(Len(aItens)))+'">100%</td>')
		AADD(aHtml,'    <td class="tg-uymc" rowspan="'+TRIM(STR(Len(aItens)))+'">50%</td>')
		AADD(aHtml,'    <td class="tg-uymc" rowspan="'+TRIM(STR(Len(aItens)))+'">25%</td>')
	ENDIF

	AADD(aHtml,'    <td class="tg-2amj"></td>')
	AADD(aHtml,'  </tr>')
Next


AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-2amj"></td>')
AADD(aHtml,'    <td class="tg-dek0" colspan="8"><b>DECLARO QUE:</b><br>1. Caso venha a ser desligado devolverei todos os itens acima devidamente higienizados e caso a devolução não ocorra, assumo a responsabilidade e autorizo o desconto do valor referente aos mesmos, de acordo com a depreciação informada na tabela ac?ma. (Ex: 2 meses de uso, 100% do valor, 7 meses de uso 50% do valor)<br><br>2. Estou ciente do uso exclusivo em trabalho e que a manutenção e conservação dos mesmos são de minha inteira e exclusiva responsabilidade.<br><br>3. O mau uso do mesmo será de minha responsabilidade e os custos de reposição serão descontados dos meus vencimentos.<br><br>4. Comparecerei ao local de trabalho devidamente uniformizado e dentro dos padrões adequados:<br>     a. Peças limpas e passadas;<br>     b. Peças sem alteração das características originais<br>     c. Peças ajustadas ao manequim do colaborador.<br>     d. Comprimento das saias com 2 (dois) cm abaixo ou acima do joelho. <br><br>5 Estou ciente que não poderei utilizar itens complementares ao vestuário, pois isto irá comprometer o padrão de atendimento e a apresentação profissional<br><br>   Abaixo seguem os itens complementares que não poderão ser utilizados:<br><br>     a. Chapéu e boné (Salvo quando for parte integrante do uniforme);<br>     b. Peça intima, colorida ou estampada sob a blusa,<br>     c. Tênis tamanco. chinelo e calçado sem fechamento no calcanhar Exceções relacionadas a prescrições médicas, assim como o calçado não for parte integrante do <br>          uniforme, deverá ser tratado junto ao gestor responsável pelo colaborador da '+cEMPRESA+';<br>     d. Acessórios em tamanho e quantidade excessivos (ex: brincos, pulseiras, colares, piercings etc).<br><br>6. Em casos de descumprimento, estou ciente que serei advertido verbalmente e na reincidência, serão aplicadas as disposições pertinentes da CLT.<br></td>')
AADD(aHtml,'    <td class="tg-2amj"></td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-2amj"></td>')
AADD(aHtml,'    <td class="tg-9cio" colspan="4">Data da Retirada '+cDtExtso+'</td>')
AADD(aHtml,'    <td class="tg-ur1u" colspan="4">____________________________________________________</td>')
AADD(aHtml,'    <td class="tg-2amj"></td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-2amj"></td>')
AADD(aHtml,'    <td class="tg-2amj"></td>')
AADD(aHtml,'    <td class="tg-2amj"></td>')
AADD(aHtml,'    <td class="tg-2amj"></td>')
AADD(aHtml,'    <td class="tg-2amj"></td>')
AADD(aHtml,'    <td class="tg-ena9" colspan="4">'+cFuncionario+'</td>')
AADD(aHtml,'    <td class="tg-2amj"></td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-2amj"></td>')
AADD(aHtml,'    <td class="tg-4aw3" colspan="8">'+cEMPRESA+'<br>'+cEndEmpres+'</td>')
AADD(aHtml,'    <td class="tg-2amj"></td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'</tbody>')
AADD(aHtml,'</table>')

AADD(aHtml,'</div>')

AADD(aHtml,'</body>')
AADD(aHtml,'</html>')

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   

cArqHtml  := cDirTmp+"TERMO_RECEB_UNIFORME_"+ALLTRIM(cTermo)+".HTML"

fErase(cArqHtml)
nHandle := MsfCreate(cArqHtml,0)
If nHandle > 0
	For _nI := 1 TO LEN(aHtml)
		fWrite(nHandle, aHtml[_nI] + cCrLf )
	Next
	fClose(nHandle)
	ShellExecute("open", cArqHtml, "", "", 1)
ENDIF

RETURN NIL


//IMPRIME O TERMO DE DEVOLUÇÃO DE UNIFORMES EPI EM HTML
STATIC FUNCTION TDEVOLUCAO(cTermo,dEMISSAO,cMUNIC,cCONTRATO,cDescContr,cFuncionario,c_CPFFUN,cMATR,cFUNCAO,cRRECEBI,cCPFRREC,aItens)
LOCAL cTipoTit :="TERMO DE DEVOLUÇÃO DE UNIFORMES EPI - "+cTermo
Local nHandle   := 0
Local cCrLf     := Chr(13) + Chr(10)
Local cDirTmp   := u_LTmpDir()
Local cArqHtml  := ""
Local aHtml     := {}
Local _nI       := 0
Local nPag 		:= 1
Local cDtExtso  := ""
Local cINFCOMPL := "s"

cDtExtso  := cMUNIC+", "+Day2Str(dEMISSAO)+" de "+MesExtenso(Month(dEMISSAO))+" de "+Year2Str(dEMISSAO)+"."

//If SM0->M0_CODIGO == "01"      // BK
	cLogo := u_BKLogos()
//Endif	

If nPag == 1
	AADD(aHtml,'<html lang="pt-BR">')
	AADD(aHtml,'<head>') 
	AADD(aHtml,'<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">' )
	AADD(aHtml,'<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">' )
	AADD(aHtml,'<title>'+cTipoTit+' - '+DTOC(date())+' '+TIME()+'</title>' )
	AADD(aHtml,'<style type="text/css">' )
	AADD(aHtml,'.tg  {border-collapse:collapse;border-color:#aabcfe;border-spacing:0;}' )
	AADD(aHtml,'.tg td{background-color:#e8edff;border-color:#aabcfe;border-style:solid;border-width:1px;color:#669;' )
  	AADD(aHtml,'font-family:Arial, sans-serif;font-size:14px;overflow:hidden;padding:10px 5px;word-break:normal;}' )
	AADD(aHtml,'.tg th{background-color:#b9c9fe;border-color:#aabcfe;border-style:solid;border-width:1px;color:#039;' )
  	AADD(aHtml,'font-family:Arial, sans-serif;font-size:14px;font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}' )
	AADD(aHtml,'.tg .tg-2amj{background-color:#ffffff;border: none;font-family:Arial, Helvetica, sans-serif !important;font-size:14px;text-align:left;' )
  	AADD(aHtml,'vertical-align:top}' )
  	AADD(aHtml,'.tg .tg-ohs2{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;')
  	AADD(aHtml,'font-size:16px;font-weight:bold;text-align:center;vertical-align:center}')
	AADD(aHtml,'.tg .tg-1kq3{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;text-align:center;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-iejx{background-color:#ffffff;border-color:#ffffff;font-family:Arial, Helvetica, sans-serif !important;font-size:14px;' )
  	AADD(aHtml,'text-align:left;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-2e78{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:center;vertical-align:bottom}' )
	AADD(aHtml,'.tg .tg-u7bl{background-color:#ffffff;border-color:#ffffff;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;text-align:left;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-dek0{background-color:#ffffff;border-color:#ffffff;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;text-align:left;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-w959{background-color:#ffffff;border-color:#ffffff;color:#ffffff;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:left;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-4aw3{background-color:#ffffff;border-color:#ffffff;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;text-align:center;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-f4uc{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:center;vertical-align:bottom}' )
	AADD(aHtml,'.tg .tg-ohsq{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:center;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-rfxw{background-color:#FFF;border-color:#ffffff;font-family:Arial, Helvetica, sans-serif !important;font-size:14px;' )
  	AADD(aHtml,'text-align:left;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-dfok{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;text-align:right;vertical-align:top}')
	AADD(aHtml,'.tg .tg-fy3d{background-color:#ffffff;border: none;color:#000000;font-family:Arial, Helvetica, sans-serif !important;font-size:14px;' )
  	AADD(aHtml,'text-align:left;vertical-align:top}')
	AADD(aHtml,'.tg .tg-uymm{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:center;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-uymc{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:center;vertical-align:center}' )
	AADD(aHtml,'.tg .tg-0ep5{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:center;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-uuna{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;font-size:14px;' )
  	AADD(aHtml,'text-align:left;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-uunn{background-color:#ffffff;border-color:#000000;color:#000000;font-family:Arial, Helvetica, sans-serif !important;font-size:14px;' )
  	AADD(aHtml,'text-align:center;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-3s9g{background-color:#ffffff;border-color:#ffffff;font-family:Arial, Helvetica, sans-serif !important;font-size:14px;' )
  	AADD(aHtml,'text-align:left;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-9cio{background-color:#ffffff;border-color:#ffffff;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:left;vertical-align:top}' )
	AADD(aHtml,'.tg .tg-ur1u{background-color:#ffffff;border-color:#ffffff;color:#000000;font-family:Arial, Helvetica, sans-serif !important;font-size:14px;' )
  	AADD(aHtml,'text-align:center;vertical-align:bottom}' )
	AADD(aHtml,'.tg .tg-ena9{background-color:#ffffff;border-color:#ffffff;color:#000000;font-family:Arial, Helvetica, sans-serif !important;' )
  	AADD(aHtml,'font-size:14px;font-weight:bold;text-align:center;vertical-align:top}' )
	AADD(aHtml,'</style>')
EndIf                                 

AADD(aHtml,'<div class="folha">')

AADD(aHtml,'<table class="tg" style="undefined;table-layout: fixed; width: 692px">')
AADD(aHtml,'<colgroup>')
AADD(aHtml,'<col style="width: 220.2px">')
AADD(aHtml,'<col style="width: 186.2px">')
AADD(aHtml,'<col style="width: 104.2px">')
AADD(aHtml,'<col style="width: 131.2px">')
AADD(aHtml,'<col style="width: 114.2px">')
AADD(aHtml,'</colgroup>')

AADD(aHtml,'<thead>')
AADD(aHtml,'  <tr>')
If EMPTY(cLogo)
	AADD(aHtml,'    <th class="tg-1kq3" >'+FWEmpName(cEmpAnt)+'</th>')
Else
	AADD(aHtml,'    <th class="tg-1kq3" >'+cLogo+'</th>')
Endif
AADD(aHtml,'    <th class="tg-ohs2" colspan="4">'+cTipoTit+'</th>')
AADD(aHtml,'  </tr>')
AADD(aHtml,'</thead>')

AADD(aHtml,'<tbody>')
AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-2e78" colspan="5"><span style="font-weight:bold">Contrato '+cDescContr+' N°: '+cContrato+'</span></td>')
AADD(aHtml,'  </tr>')
AADD(aHtml,'  <tr>')
//AADD(aHtml,'    <td class="tg-0lax"></td>')
AADD(aHtml,'    <td class="tg-fy3d" colspan="5">Declaramos que recebemos em devolução, do Sr(a) '+cMatr+' - '+cFuncionario+'as peças de Uniforme abaixo discriminadas:</td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-2e78" colspan="2" rowspan="2">DESCRIÇÃO UNIFORME E EPI</td>')
AADD(aHtml,'    <td class="tg-2e78" rowspan="2">QUANT</td>')
AADD(aHtml,'    <td class="tg-2e78" colspan="2">ESTADO DE CONSERVAÇÃO</td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-2e78">Em Condições</td>')
AADD(aHtml,'    <td class="tg-2e78">Sem Condições</td>')
AADD(aHtml,'  </tr>')


For _nI := 1 To Len(aItens)
	cINFCOMPL := ""
	IF !EMPTY(aItens[_nI,4])
		cINFCOMPL += " - CA "+aItens[_nI,4]
	ENDIF
	IF !EMPTY(aItens[_nI,5])
		cINFCOMPL += " - Validade: "+DTOC(aItens[_nI,5])
	ENDIF
	AADD(aHtml,'  <tr>')
	AADD(aHtml,'    <td class="tg-uuna" colspan="2">'+aItens[_nI,1]+cINFCOMPL+'</td>')
	AADD(aHtml,'    <td class="tg-uunn">'+TRANSFORM(aItens[_nI,3],"@E 999")+'</td>')
	AADD(aHtml,'    <td class="tg-uunn">'+IIF(aItens[_nI,7]=="B","X","")+'</td>')
	AADD(aHtml,'    <td class="tg-uunn">'+IIF(aItens[_nI,7]=="R","X","")+'</td>')
	AADD(aHtml,'  </tr>')
Next


AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-ena9" colspan="5"></td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-ena9" colspan="5"></td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-9cio" colspan="2">'+cDtExtso+'</td>')
AADD(aHtml,'    <td class="tg-ur1u" colspan="3">_____________________________________________</td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-ena9" colspan="2"></td>')
AADD(aHtml,'    <td class="tg-ena9" colspan="3">'+cRRECEBI+'<br>CPF: '+cCPFRREC+'<br>Responsavel Recebimento</td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'</tbody>')

AADD(aHtml,'</table>')

AADD(aHtml,'</div>')

AADD(aHtml,'</body>')
AADD(aHtml,'</html>')

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   

cArqHtml  := cDirTmp+"TERMO_DEVOLUCAO_"+ALLTRIM(cTermo)+".HTML"

fErase(cArqHtml)
nHandle := MsfCreate(cArqHtml,0)
If nHandle > 0
	For _nI := 1 TO LEN(aHtml)
		fWrite(nHandle, aHtml[_nI] + cCrLf )
	Next
	fClose(nHandle)
	ShellExecute("open", cArqHtml, "", "", 1)
ENDIF

RETURN NIL
