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
_SQL+= " WHERE SRD.D_E_L_E_T_='' AND RD_FILIAL ='"+XFILIAL('SRD')+"' AND RD_PERIODO='"+cPERIODO+"' AND RD_SEMANA='"+cSemana+"'"
_SQL+= " AND RD_PD= '474' "
		
IF SELECT('QSZ2')> 0
	QSZ2->(DBCLOSEAREA())
ENDIF
		
DBUSEAREA(.T.,"TOPCONN"	,TCGENQRY(,,_SQL),'QSRDSRC',.F.,.T.)
tcSetField("QSZ2","RC_DATA","D",8,0)

DBSELECTAREA('QSZ2')
QSRDSRC->(DBGOTOP())
while QSRDSRC->(!EOF())
   AADD(aCtrId,{.T.,;
      QSRDSRC->RA_MAT,;
      QSRDSRC->RA_NOME,;
      QSRDSRC->RA_CIC,;
      QSRDSRC->RA_RG,;
      QSRDSRC->RC_VALOR,;
      SUBSTR(QSRDSRC->RA_BCDEPSA,1,3),;
      SUBSTR(QSRDSRC->RA_BCDEPSA,4,4),;
      STRZERO(VAL(SUBSTR(QSRDSRC->RA_CTDEPSA,1,11)),7),; 
      SUBSTR(QSRDSRC->RA_CTDEPSA,12,1),;  
      dDatPGTO,;
      QSRDSRC->RA_CC,;       
      cOBS,;
      QSRDSRC->RC_DATA})
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

@ 015, 005 LISTBOX oListId FIELDS HEADER "","RE","Nome","CPF","RG","Valor","Banco","Agencia","Conta","Dg.Cont.","Data PGTO","Centro de Custo",'OBS' SIZE 520,245 OF oPanelLeft PIXEL 
oListID:SetArray(aCtrId)
oListID:bLine := {|| {If(aCtrId[oListId:nAt][1],oOk,oNo),;
						 aCtrId[oListId:nAt][2],;
						 aCtrId[oListId:nAt][3],;
						 aCtrId[oListId:nAt][4],;
                   aCtrId[oListId:nAt][5],;
						 TransForm(aCtrId[oListId:nAt][6],'@E 9,999,999.99'),;
                   aCtrId[oListId:nAt][7],;
                   aCtrId[oListId:nAt][8],;
                   aCtrId[oListId:nAt][9],;   
                   aCtrId[oListId:nAt][10],;   
                   aCtrId[oListId:nAt][11],;
                   aCtrId[oListId:nAt][12],;                                                         
                   aCtrId[oListId:nAt][13]}}

oListID:bLDblClick := {|| aCtrId[oListId:nAt][1] := MrkTit(aCtrId[oListId:nAt][1],aCtrId[oListId:nAt][6]), oListID:DrawSelect()}

ACTIVATE MSDIALOG oDlg02 CENTERED ON INIT EnchoiceBar(oDlg02,{|| lOk2:=.T., oDlg02:End()},{|| oDlg02:End()}, , aButtons2)
 
If ( lOk2 )
	lOk2:=.F.
	Begin Transaction
		FOR  _XI:=1 TO LEN(aCtrId)
			IF aCtrId[_XI,1] 
				RecLock("SZ2",.T.)
            SZ2->Z2_FILIAL:= xFilial("SZM")
            SZ2->Z2_CTRID := DTOS(Date())+STRTRAN(TIME(),":","")+"BD"
            SZ2->Z2_CODEMP:= "01"
            SZ2->Z2_PRONT := aCtrId[_XI,2]
            SZ2->Z2_NOME  := aCtrId[_XI,3]
            SZ2->Z2_VALOR:= aCtrId[_XI,6]
            SZ2->Z2_TIPO:= cTIPO
            SZ2->Z2_BANCO:= aCtrId[_XI,7]
            SZ2->Z2_AGENCIA:= aCtrId[_XI,8]
            SZ2->Z2_DIGAGEN:= ""
            SZ2->Z2_CONTA:= aCtrId[_XI,9]
            SZ2->Z2_DIGCONT:= aCtrId[_XI,10]
            SZ2->Z2_STATUS:= "B"
            SZ2->Z2_DATAEMI:= Date()
            SZ2->Z2_DATAPGT:= dDatPGTO
            SZ2->Z2_DORIPGT:= aCtrId[_XI,14]
            SZ2->Z2_USUARIO:= TRIM(SUBSTR(cUsuario,7,15))
            SZ2->Z2_TITULO:= ""
            SZ2->Z2_CALC:= cPERIODO
            SZ2->Z2_TIPOPES:= "PJ"
            SZ2->Z2_CC:= aCtrId[_XI,13]
            SZ2->Z2_OBSTITU := aCtrId[_XI,13]
            SZ2->Z2_PRODUTO:= cPRODUTO 
            SZ2->Z2_E2PRF:= ""
            SZ2->Z2_E2NUM:= ""
            SZ2->Z2_E2PARC:= ""
            SZ2->Z2_E2TIPO:= ""
            SZ2->Z2_E2FORN:= ""
            SZ2->Z2_E2LOJA:= ""
            SZ2->Z2_ANEXO:= ""
            SZ2->Z2_CPF:= aCtrId[_XI,4]
            SZ2->Z2_TIPCOL:= 1
            SZ2->Z2_CODFOR:= ''
            SZ2->Z2_LOJFOR := ''
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
