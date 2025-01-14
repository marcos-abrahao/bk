#Include "Protheus.ch"
#include "rwmake.ch"
#include "TBICONN.CH"
#include "TopConn.ch"
#include "report.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKGPEA03
OSESP - Rotina Gerar dados para NFS PJ90
@Return
@author Adilson do Prado
@since 04/10/2024
@version P12
/*/
//-------------------------------------------------------------------


#DEFINE X_OK      01
#DEFINE X_RE      02
#DEFINE X_NOME    03
#DEFINE X_CPF     04
#DEFINE X_RG      05
#DEFINE X_VALOR   06
#DEFINE X_BANCO   07
#DEFINE X_AGENCIA 08

#DEFINE X_DIGAG   09
#DEFINE X_CONTA   10
#DEFINE X_DGCONTA 11
#DEFINE X_DTPGT   12
#DEFINE X_CUSTO   13
#DEFINE X_OBS     14
#DEFINE X_DATA    15

USER FUNCTION BKGPEA03()
Local aAreaIni  := GetArea()
Local cTitulo2  := ""
Local _SQL 	 	:= ""
Local lOk2   	:= .F.
Local oDlg02
Local aButtons2
Local oOk
Local oNo
Local oPanelLeft
Local _XI := 0
Local cPerg := "BKGPEA03"

PRIVATE aCtrId 	:= {}
PRIVATE oSay
PRIVATE aParam := {}
PRIVATE nTotSel := 0
PRIVATE cTitulo:= "Geraros dados para NFS PJ90"
PRIVATE dDTPGTOI := CTOD("")
PRIVATE dDTPGTOF := CTOD("")

aAdd( aParam, { 1, "Data do Pagamento de :"  , CTOD("")					, ""            , ""   , ""	  , "" , 70  , .F. })
aAdd( aParam, { 1, "Data do Pagamento até:"  , CTOD("")					, ""            , ""   , ""	  , "" , 70  , .F. })  

If !BKF03Par()
   Return
EndIf

u_MsgLog(cPerg)


IF dDTPGTOF < dDTPGTOI
	u_MsgLog("BKGPEA03","Data do Pagamento até menor a data do Pagamento de. Verifique!", "E")
	RestArea(aAreaIni)
	Return
EndIf

aCtrId := {}

_SQL:= "SELECT RA_MAT,RA_NOME,RA_CIC,RA_RG,RA_BCDEPSA,RA_CTDEPSA,RA_CC,RC_VALOR,RC_DATA"
_SQL+= " FROM " +RETSQLNAME('SRC')+" SRC"
_SQL+= " INNER JOIN " +RETSQLNAME('SRA')+" SRA ON SRA.D_E_L_E_T_='' AND RA_MAT=RC_MAT AND RA_FILIAL=RC_FILIAL"
_SQL+= " WHERE SRD.D_E_L_E_T_='' AND RD_FILIAL ='"+XFILIAL('SRD')+"' AND RD_PERIODO='"+cPeriodo+"' AND RD_SEMANA='"+cSemana+"'"
_SQL+= " AND RD_PD= '474' "
		
IF SELECT('QSZ2')> 0
	QSZ2->(DBCLOSEAREA())
ENDIF
		
DBUSEAREA(.T.,"TOPCONN"	,TCGENQRY(,,_SQL),'QSRDSRC',.F.,.T.)
tcSetField("QSZ2","RC_DATA","D",8,0)

DBSELECTAREA('QSZ2')
QSRDSRC->(DBGOTOP())
while QSRDSRC->(!EOF())
   AADD(aCtrId,{.T.,;         // X_OK      01
      QSRDSRC->RA_MAT,;       // X_RE      02
      QSRDSRC->RA_NOME,;      // X_NOME    03
      QSRDSRC->RA_CIC,;       // X_CPF     04
      QSRDSRC->RA_RG,;        // X_RG      05
      QSRDSRC->RC_VALOR,;     // X_VALOR   06
      SUBSTR(QSRDSRC->RA_BCDEPSA,1,3),;      // X_BANCO   07
      SUBSTR(QSRDSRC->RA_BCDEPSA,4,4),;      // X_AGENCIA 08
      SUBSTR(QSRDSRC->RA_BCDEPSA,8,1),;      // X_DIGAG 09
      STRZERO(VAL(SUBSTR(QSRDSRC->RA_CTDEPSA,1,11)),7),;    //X_CONTA   10
      SUBSTR(QSRDSRC->RA_CTDEPSA,12,1),;     // X_DGCONTA 11
      dDatPGTO,;              // X_DTPGT   12
      QSRDSRC->RA_CC,;        // X_CUSTO   13
      cOBS,;                  // X_OBS     14
      QSRDSRC->RC_DATA})      // X_DATA    15

      nTotSel += QSRDSRC->RC_VALOR

   QSRDSRC->(DBSKIP())
ENDDO
QSRDSRC->(DBCLOSEAREA())

If Empty(aCtrId)
	u_MsgLog("BKGPEA03","Nenhum funcionario nesta seleção ou ja informado no financeiro, verifique os filtros !!", "E")
	RestArea(aAreaIni)
	Return
EndIf

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

DEFINE MSDIALOG oDlg02 TITLE cTitulo2 FROM 000,000 TO 650,1050 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg02 SIZE 1050,500

oPanelLeft:Align := CONTROL_ALIGN_LEFT

lAll := .T.
@ 003, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
//oAll:bChange := {|| Aeval(aCtrId,{|x| x[1]:=lAll }), oListId:Refresh()}
oAll:bChange := {|| MudaCell(lAll) , oListId:Refresh()}

oSay := tSay():New(005,100,{||'Total Selecionado: '+ TransForm(nTotSel,"@E 99,999,999.99")},oPanelLeft,,,,,,.T.,,,100,10)

@ 015, 005 LISTBOX oListId FIELDS HEADER "","RE","Nome","CPF","RG","Valor","Banco","Agencia","Dig.Ag.","Conta","Dg.Cont.","Data PGTO","Centro de Custo",'OBS' SIZE 520,245 OF oPanelLeft PIXEL 
oListID:SetArray(aCtrId)
oListID:bLine := {|| {If(aCtrId[oListId:nAt][X_OK],oOk,oNo),;
						 aCtrId[oListId:nAt][X_RE],;
						 aCtrId[oListId:nAt][X_NOME],;
						 aCtrId[oListId:nAt][X_CPF],;
                   aCtrId[oListId:nAt][X_RG],;
						 TransForm(aCtrId[oListId:nAt][X_VALOR],'@E 9,999,999.99'),;
                   aCtrId[oListId:nAt][X_BANCO],;
                   aCtrId[oListId:nAt][X_AGENCIA],;
                   aCtrId[oListId:nAt][X_DIGAG],;
                   aCtrId[oListId:nAt][X_CONTA],;   
                   aCtrId[oListId:nAt][X_DGCONTA],;   
                   aCtrId[oListId:nAt][X_DTPGT],;
                   aCtrId[oListId:nAt][X_CUSTO],;                                                         
                   aCtrId[oListId:nAt][X_OBS]}}

oListID:bLDblClick := {|| aCtrId[oListId:nAt][X_OK] := MrkTit(aCtrId[oListId:nAt][X_OK],aCtrId[oListId:nAt][X_VALOR]), oListID:DrawSelect()}

ACTIVATE MSDIALOG oDlg02 CENTERED ON INIT EnchoiceBar(oDlg02,{|| lOk2:=.T., oDlg02:End()},{|| oDlg02:End()}, , aButtons2)
 
If ( lOk2 )
	lOk2:=.F.
	Begin Transaction
		FOR  _XI:=1 TO LEN(aCtrId)
			IF aCtrId[_XI,X_VALOR] 
				RecLock("SZ2",.T.)
            SZ2->Z2_FILIAL    := xFilial("SZ2")
            SZ2->Z2_CTRID     := DTOS(Date())+STRTRAN(TIME(),":","")+"BD"
            SZ2->Z2_CODEMP    := "01"
            SZ2->Z2_PRONT     := aCtrId[_XI,X_RE]
            SZ2->Z2_NOME      := aCtrId[_XI,X_NOME]
            SZ2->Z2_VALOR     := aCtrId[_XI,X_VALOR]
            SZ2->Z2_TIPO      := cTIPO
            SZ2->Z2_BANCO     := aCtrId[_XI,X_BANCO]
            SZ2->Z2_AGENCIA   := aCtrId[_XI,X_AGENCIA]
            SZ2->Z2_DIGAGEN   := aCtrId[_XI,X_DIGAG]
            SZ2->Z2_CONTA     := aCtrId[_XI,X_CONTA]
            SZ2->Z2_DIGCONT   := aCtrId[_XI,X_DGCONTA]
            SZ2->Z2_STATUS    := "B"
            SZ2->Z2_DATAEMI   := Date()
            SZ2->Z2_DATAPGT   := dDatPGTO
            SZ2->Z2_DORIPGT   := aCtrId[_XI,14]
            SZ2->Z2_USUARIO   := TRIM(SUBSTR(cUsuario,7,15))
            SZ2->Z2_TITULO    := ""
            SZ2->Z2_CALC      := cPeriodo
            SZ2->Z2_TIPOPES   := "PJ"
            SZ2->Z2_CC        := aCtrId[_XI,X_CUSTO]
            SZ2->Z2_OBSTITU   := aCtrId[_XI,X_OBS]
            SZ2->Z2_PRODUTO   := cPRODUTO 
            SZ2->Z2_E2PRF     := ""
            SZ2->Z2_E2NUM     := ""
            SZ2->Z2_E2PARC    := ""
            SZ2->Z2_E2TIPO    := ""
            SZ2->Z2_E2FORN    := ""
            SZ2->Z2_E2LOJA    := ""
            SZ2->Z2_ANEXO     := ""
            SZ2->Z2_CPF       := aCtrId[_XI,X_CPF]
            SZ2->Z2_TIPCOL    := 1
            SZ2->Z2_CODFOR    := ''
            SZ2->Z2_LOJFOR    := ''
				SZ2->(MsUnlock( ))
	 		ENDIF
		NEXT
	End Transaction
   u_MsgLog("BKGPEA03","Gerado com Sucesso, aguardando Liberação na Integração!","S")
Endif

RestArea(aAreaIni)
Return

Static Function MudaCell(lAll)
Local nI := 0

IF lAll
	nTotSel := 0
	FOR nI := 1 TO LEN(aCtrId)
		aCtrId[nI,1] := lAll
		nTotSel += aCtrId[nI,6]
	next
	oSay:cCaption := "Total Selecionado: "+TRANSFORM(nTotSel,"@E 999,999,999.99")
ELSE
	nTotSel := 0
	FOR nI := 1 TO LEN(aCtrId)
		aCtrId[nI,1] := .F.
	next
	oSay:cCaption := "Total Selecionado: "+TRANSFORM(nTotSel,"@E 999,999,999.99")
ENDIF

Return NIL

Static Function MrkTit(lTit,nVal)
Local lOK := .T.

IF lTit
	lOK := .F.
ELSE
	lOK := .T.
ENDIF

IF lTit <> lOK
	IF lOK
		nTotSel += nVal
	ELSE
		nTotSel -= nVal
	ENDIF
ENDIF

oSay:cCaption := "Total Selecionado: "+TRANSFORM(nTotSel,"@E 999,999,999.99")

Return lOK

Static Function BKF03Par()
Local lRet := .F.
Local aRet		:=	{}
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,@cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKGPEA03" ,.T.         ,.T.))
	lRet     := .T.
   dDTPGTOI := mv_par01
   dDTPGTOF := mv_par02
 
Endif
Return lRet
