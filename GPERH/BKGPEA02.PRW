#Include "Protheus.ch"
#include "rwmake.ch"
#include "TBICONN.CH"
#include "TopConn.ch"
#include "report.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKGPEA02
BK - Rotina Gerar pgto no financeiro PJ90
@Return
@author Adilson do Prado
@since 16/08/2024
@version P12
/*/
//-------------------------------------------------------------------


USER FUNCTION BKGPEA02()
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
Local cPerg := "BKGPEA02"
Local cForn := ""
Local cLoja := ""
Local cQryA2 := ""

Private aSize   := MsAdvSize(,.F.,400)
Private aCtrId 	:= {}
Private oSay
Private aParam := {}
Private nTotSel := 0
Private cTitulo:= "Gerar pgtos selecionados no Financeiro"
Private cROTE  := ""
Private cSemana := ""
Private cMatI  := ""
Private cMatF  := ""
Private dDatRef  := CTOD("")
Private dDatPGTO := CTOD("")
Private cPERIODO := ""
Private cFOLMES  := U_MVFOLHA('FOL')
Private cOBS     := SPACE(250)
Private cTIPO    := "LPM"
Private cPRODUTO := "11301001"

aAdd( aParam, { 1, "Roteiro :"	        , "FOL"           	, ""            , ""   , "SRY", "" , 70  , .F. })
aAdd( aParam, { 1, "Semana :"	           , "01"           	, ""            , ""   , ""   , "" , 70  , .F. })
aAdd( aParam, { 1, "Período :"           , CTOD("")			, ""            , ""   , ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Matricula de:"	     , SPACE(06)	      , ""            , ""   , "SRA", "" , 70  , .F. })
aAdd( aParam, { 1, "Matricula até:"	     , SPACE(06)        , ""            , ""   , "SRA", "" , 70  , .F. })
aAdd( aParam, { 1, "Data do Pagamento:"  , CTOD("")			, ""            , ""   , ""	, "" , 70  , .F. })  
aAdd( aParam, { 1, "OBS:"	              , SPACE(250)       , ""            , ""   , ""   , "" , 70  , .F. })

If !BKF02Par()
   Return
EndIf

u_MsgLog(cPerg)

cFOLMES := U_MVFOLHA(cROTE)
cPERIODO := Year2Str(dDatRef)+Month2Str(dDatRef)

If cPERIODO < '202409'
	u_MsgLog("BKGPEA02","Periodo Informado "+cPERIODO+" menor que '202409'  incorreto. Verifique!", "E")
	RestArea(aAreaIni)
	Return
EndIf
IF dDatPGTO < DATE()
	u_MsgLog("BKGPEA02","Data do PGTO="+DTOC(dDatPGTO)+" menor que data de hoje. Verifique!", "E")
	RestArea(aAreaIni)
	Return
EndIf

aCtrId := {}

IF cPERIODO == cFOLMES
   _SQL:= "SELECT DISTINCT RA_MAT,RA_NOME,RA_CIC,RA_RG,RA_BCDEPSA,RA_CTDEPSA, BKIntegraRubi.dbo.fnCCSiga(90,2,RA_MAT, 'AC') AS RA_CC,RC_VALOR,RC_DATA,A2_COD,A2_LOJA,RA_XXEMP"
   _SQL+= " FROM " +RETSQLNAME('SRC')+" SRC"
   _SQL+= " INNER JOIN " +RETSQLNAME('SRA')+" SRA ON SRA.D_E_L_E_T_='' AND RA_MAT=RC_MAT AND RA_FILIAL=RC_FILIAL"
   IF cROTE == "ADI"
      _SQL+= " LEFT JOIN " +RETSQLNAME('SZ2')+" SZ2 ON SZ2.D_E_L_E_T_='' AND Z2_CODEMP=RA_XXEMP AND Z2_TIPOPES='PJ'"
      _SQL+= " AND RA_MAT=Z2_PRONT AND Z2_STATUS<>'D' AND Z2_DORIPGT=RC_DATA AND Z2_TIPO IN ('LAS','LAD') AND Z2_PRONT IS NULL"
      _SQL+= " LEFT JOIN SA2010 SA2 ON SA2.D_E_L_E_T_='' AND CAST(A2_XXNCAD AS INT)= CAST(RA_MAT AS INT)"
      _SQL+= " WHERE SRC.D_E_L_E_T_='' AND RC_FILIAL ='"+XFILIAL('SRC')+"' AND RC_PERIODO='"+cPERIODO+"' AND RC_SEMANA='"+cSemana+"'"
      _SQL+= " AND RC_PD= '062' "
      cTIPO    := "LAS"
      cPRODUTO := "11301001"
   ELSEIF cROTE == "FOL"
      _SQL+= " LEFT JOIN " +RETSQLNAME('SZ2')+" SZ2 ON SZ2.D_E_L_E_T_='' AND Z2_CODEMP=RA_XXEMP AND Z2_TIPOPES='PJ'"
      _SQL+= " AND RA_MAT=Z2_PRONT AND Z2_STATUS<>'D' AND Z2_DORIPGT=RC_DATA AND Z2_TIPO='LPM' AND Z2_PRONT IS NULL"
      _SQL+= " LEFT JOIN SA2010 SA2 ON SA2.D_E_L_E_T_='' AND CAST(A2_XXNCAD AS INT)= CAST(RA_MAT AS INT)"
      _SQL+= " WHERE SRC.D_E_L_E_T_='' AND RC_FILIAL ='"+XFILIAL('SRC')+"' AND RC_PERIODO='"+cPERIODO+"' AND RC_SEMANA='"+cSemana+"'"
      _SQL+= " AND RC_PD= '727' "
      cTIPO    := "LPM"
      cPRODUTO := "11301001"
   ELSEIF cROTE == "FER"
      _SQL+= " LEFT JOIN " +RETSQLNAME('SZ2')+" SZ2 ON SZ2.D_E_L_E_T_='' AND Z2_CODEMP=RA_XXEMP AND Z2_TIPOPES='PJ'"
      _SQL+= " AND RA_MAT=Z2_PRONT AND Z2_STATUS<>'D' AND Z2_DORIPGT=RC_DATA AND Z2_TIPO='LFE' AND Z2_PRONT IS NULL"
      _SQL+= " LEFT JOIN SA2010 SA2 ON SA2.D_E_L_E_T_='' AND CAST(A2_XXNCAD AS INT)= CAST(RA_MAT AS INT)"
      _SQL+= " WHERE SRC.D_E_L_E_T_='' AND RC_FILIAL ='"+XFILIAL('SRC')+"' AND RC_PERIODO='"+cPERIODO+"' AND RC_SEMANA='"+cSemana+"'"
      _SQL+= " AND RC_PD= '432' "
      cTIPO    := "LFE"
      cPRODUTO := "11301001"  
    ELSEIF cROTE == "RES"
      _SQL+= " LEFT JOIN " +RETSQLNAME('SZ2')+" SZ2 ON SZ2.D_E_L_E_T_='' AND Z2_CODEMP=RA_XXEMP AND Z2_TIPOPES='PJ'"
      _SQL+= " AND RA_MAT=Z2_PRONT AND Z2_STATUS<>'D' AND Z2_DORIPGT=RC_DATA AND Z2_TIPO='LRC' AND Z2_PRONT IS NULL"
      _SQL+= " LEFT JOIN SA2010 SA2 ON SA2.D_E_L_E_T_='' AND CAST(A2_XXNCAD AS INT)= CAST(RA_MAT AS INT)"
      _SQL+= " WHERE SRC.D_E_L_E_T_='' AND RC_FILIAL ='"+XFILIAL('SRC')+"' AND RC_PERIODO='"+cPERIODO+"' AND RC_SEMANA='"+cSemana+"'"
      _SQL+= " AND RC_PD= '474' "
      cTIPO    := "LRC"
      cPRODUTO := "11301001"
   ENDIF
ELSE
   _SQL:= "SELECT DISTINCT RA_MAT,RA_NOME,RA_CIC,RA_RG,RA_BCDEPSA,RA_CTDEPSA, BKIntegraRubi.dbo.fnCCSiga(90,2,RA_MAT, 'AC') AS RA_CC,RD_VALOR AS RC_VALOR,RD_DATPGT AS RC_DAT,A2_COD,A2_LOJA,RA_XXEMP"
   _SQL+= " FROM " +RETSQLNAME('SRD')+" SRD"
   _SQL+= " INNER JOIN " +RETSQLNAME('SRA')+" SRA ON SRA.D_E_L_E_T_='' AND RA_MAT=RD_MAT AND RA_FILIAL=RD_FILIAL"
   IF cROTE == "ADI"
      _SQL+= " LEFT JOIN " +RETSQLNAME('SZ2')+" SZ2 ON SZ2.D_E_L_E_T_='' AND Z2_CODEMP=RA_XXEMP AND Z2_TIPOPES='PJ'"
      _SQL+= " AND RA_MAT=Z2_PRONT AND Z2_STATUS<>'D' AND Z2_DORIPGT=RD_DATPGT AND Z2_TIPO IN ('LAS','LAD') AND Z2_PRONT IS NULL"
      _SQL+= " LEFT JOIN SA2010 SA2 ON SA2.D_E_L_E_T_='' AND CAST(A2_XXNCAD AS INT)= CAST(RA_MAT AS INT)"
      _SQL+= " WHERE SRD.D_E_L_E_T_='' AND RD_FILIAL ='"+XFILIAL('SRD')+"' AND RD_PERIODO='"+cPERIODO+"' AND RD_SEMANA='"+cSemana+"'"
      _SQL+= " AND RD_PD= '062' "
      cTIPO    := "LAS"
      cPRODUTO := "11301001"  
   ELSEIF cROTE == "FOL"
      _SQL+= " LEFT JOIN " +RETSQLNAME('SZ2')+" SZ2 ON SZ2.D_E_L_E_T_='' AND Z2_CODEMP=RA_XXEMP AND Z2_TIPOPES='PJ'"
      _SQL+= " AND RA_MAT=Z2_PRONT AND Z2_STATUS<>'D' AND Z2_DORIPGT=RD_DATPGT AND Z2_TIPO='LPM' AND Z2_PRONT IS NULL"
      _SQL+= " LEFT JOIN SA2010 SA2 ON SA2.D_E_L_E_T_='' AND CAST(A2_XXNCAD AS INT)= CAST(RA_MAT AS INT)"
      _SQL+= " WHERE SRD.D_E_L_E_T_='' AND RD_FILIAL ='"+XFILIAL('SRD')+"' AND RD_PERIODO='"+cPERIODO+"' AND RD_SEMANA='"+cSemana+"'"
      _SQL+= " AND RD_PD= '727'"
      cTIPO    := "LPM"
      cPRODUTO := "11301001"
   ELSEIF cROTE == "FER"
      _SQL+= " LEFT JOIN " +RETSQLNAME('SZ2')+" SZ2 ON SZ2.D_E_L_E_T_='' AND Z2_CODEMP=RA_XXEMP AND Z2_TIPOPES='PJ'"
      _SQL+= " AND RA_MAT=Z2_PRONT AND Z2_STATUS<>'D' AND Z2_DORIPGT=RD_DATPGT AND Z2_TIPO='LFE' AND Z2_PRONT IS NULL"
      _SQL+= " LEFT JOIN SA2010 SA2 ON SA2.D_E_L_E_T_='' AND CAST(A2_XXNCAD AS INT)= CAST(RA_MAT AS INT)"
      _SQL+= " WHERE SRD.D_E_L_E_T_='' AND RD_FILIAL ='"+XFILIAL('SRD')+"' AND RD_PERIODO='"+cPERIODO+"' AND RD_SEMANA='"+cSemana+"'"
      _SQL+= " AND RD_PD= '432' "
      cTIPO    := "LFE"
      cPRODUTO := "11301001"  
    ELSEIF cROTE == "RES"
      _SQL+= " LEFT JOIN " +RETSQLNAME('SZ2')+" SZ2 ON SZ2.D_E_L_E_T_='' AND Z2_CODEMP=RA_XXEMP AND Z2_TIPOPES='PJ'"
      _SQL+= " AND RA_MAT=Z2_PRONT AND Z2_STATUS<>'D' AND Z2_DORIPGT=RD_DATPGT AND Z2_TIPO='LRC' AND Z2_PRONT IS NULL"
      _SQL+= " LEFT JOIN SA2010 SA2 ON SA2.D_E_L_E_T_='' AND CAST(A2_XXNCAD AS INT)= CAST(RA_MAT AS INT)"
      _SQL+= " WHERE SRD.D_E_L_E_T_='' AND RD_FILIAL ='"+XFILIAL('SRD')+"' AND RD_PERIODO='"+cPERIODO+"' AND RD_SEMANA='"+cSemana+"'"
      _SQL+= " AND RD_PD= '474' "
      cTIPO    := "LRC"
      cPRODUTO := "11301001"
   ENDIF
ENDIF
		
IF Select('QSRDSRC') > 0
	QSRDSRC->(dbCloseArea())
ENDIF
		
dbUseArea(.T.,"TOPCONN"	,TcGenQry(,,_SQL),'QSRDSRC',.F.,.T.)
tcSetField("QSRDSRC","RC_DATA","D",8,0)

dbSelectArea('QSRDSRC')
QSRDSRC->(dbGoTop())
while QSRDSRC->(!EOF())

   If QSRDSRC->RA_XXEMP <> "01"
      cQryA2 := "SELECT TOP 1 A2_COD,A2_LOJA"
      cQryA2 += " FROM SA2"+QSRDSRC->RA_XXEMP+"0 SA2"
      cQryA2 += " WHERE SA2.D_E_L_E_T_='' AND CAST(A2_XXNCAD AS INT) = CAST('"+QSRDSRC->RA_MAT+"' AS INT)"
      dbUseArea(.T.,"TOPCONN"	,TcGenQry(,,cQryA2),'QSA2',.F.,.T.)
      QSA2->(dbGoTop())
      If !QSA2->(EOF())
         cForn := QSA2->A2_COD
         cLoja := QSA2->A2_LOJA
      Else
         cForn := ""
         cLoja := ""
      EndIf
      QSA2->(dbCloseArea())
   Else
      cForn := QSRDSRC->A2_COD
      cLoja := QSRDSRC->A2_LOJA
   EndIf

   aAdd(aCtrId,{.T.,;
      QSRDSRC->RA_MAT,;
      QSRDSRC->RA_NOME,;
      QSRDSRC->RA_CIC,;
      QSRDSRC->RA_RG,;
      QSRDSRC->RC_VALOR,;
      SUBSTR(QSRDSRC->RA_BCDEPSA,1,3),;
      SUBSTR(QSRDSRC->RA_BCDEPSA,4,5),;      // X_AGENCIA + X_DIGAG 
      STRZERO(VAL(SUBSTR(QSRDSRC->RA_CTDEPSA,1,11)),11),; 
      SUBSTR(QSRDSRC->RA_CTDEPSA,12,1),;  
      dDatPGTO,;
      QSRDSRC->RA_CC,;       
      cOBS,;
      cForn,;
      cLoja,;      
      QSRDSRC->RC_DATA,;
      QSRDSRC->RA_XXEMP})
      nTotSel += QSRDSRC->RC_VALOR

   QSRDSRC->(dbSkip())
ENDDO
QSRDSRC->(dbCloseArea())

If Empty(aCtrId)
	u_MsgLog("BKGPEA02","Nenhum funcionario nesta seleção ou ja informado no financeiro, verifique os filtros !!", "E")
	RestArea(aAreaIni)
	Return
EndIf

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

//DEFINE MSDIALOG oDlg02 TITLE cTitulo2 FROM 000,000 TO 650,1050 PIXEL 
Define MsDialog oDlg02 Title cTitulo2 From aSize[7], 0 To aSize[6],aSize[5] Of oMainWnd Pixel
@ 000,000 MSPANEL oPanelLeft OF oDlg02 SIZE 1050,500

oPanelLeft:Align := CONTROL_ALIGN_ALLCLIENT

lAll := .T.
@ 003, 005 CHECKBOX oAll VAR lAll PROMPT "Marcar todos" OF oPanelLeft SIZE 080, 010 PIXEL 
//oAll:bChange := {|| Aeval(aCtrId,{|x| x[1]:=lAll }), oListId:Refresh()}
oAll:bChange := {|| MudaCell(lAll) , oListId:Refresh()}

oSay := tSay():New(005,100,{||'Total Selecionado: '+ TransForm(nTotSel,"@E 99,999,999.99")},oPanelLeft,,,,,,.T.,,,100,10)

@ 015, 005 LISTBOX oListId FIELDS HEADER "","RE","Nome","CPF","RG","Valor","Banco","Agencia","Conta","Dg.Cont.","Data PGTO","Centro de Custo",'Cod.Fornecedor','Loja','Empresa','OBS' SIZE 520,245 OF oPanelLeft PIXEL 
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
                   aCtrId[oListId:nAt][13],;
                   aCtrId[oListId:nAt][14],;
                   aCtrId[oListId:nAt][15],;
                   aCtrId[oListId:nAt][17],;
                   aCtrId[oListId:nAt][12]}}

oListID:bLDblClick := {|| aCtrId[oListId:nAt][1] := MrkTit(aCtrId[oListId:nAt][1],aCtrId[oListId:nAt][6]), oListID:DrawSelect()}
oListID:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg02 CENTERED ON INIT EnchoiceBar(oDlg02,{|| lOk2:=.T., oDlg02:End()},{|| oDlg02:End()}, , aButtons2)
 
If ( lOk2 )
	lOk2:=.F.
	Begin Transaction
		FOR  _XI:=1 TO LEN(aCtrId)
			IF aCtrId[_XI,1] 
				RecLock("SZ2",.T.)
            SZ2->Z2_FILIAL := xFilial("SZM")
            SZ2->Z2_CTRID  := DTOS(Date())+STRTRAN(TIME(),":","")+"BD"
            SZ2->Z2_CODEMP := aCtrId[_XI,17]
            SZ2->Z2_PRONT  := aCtrId[_XI,2]
            SZ2->Z2_NOME   := aCtrId[_XI,3]
            SZ2->Z2_VALOR  := aCtrId[_XI,6]
            SZ2->Z2_TIPO   := cTIPO
            SZ2->Z2_BANCO  := aCtrId[_XI,7]
            SZ2->Z2_AGENCIA:= SUBSTR(aCtrId[_XI,8],1,4)
            SZ2->Z2_DIGAGEN:= SUBSTR(aCtrId[_XI,8],5,1)
            SZ2->Z2_CONTA  := aCtrId[_XI,9]
            SZ2->Z2_DIGCONT:= aCtrId[_XI,10]
            SZ2->Z2_STATUS := "B"
            SZ2->Z2_DATAEMI:= Date()
            SZ2->Z2_DATAPGT:= dDatPGTO
            SZ2->Z2_DORIPGT:= aCtrId[_XI,16]
            SZ2->Z2_USUARIO:= TRIM(SUBSTR(cUsuario,7,15))
            SZ2->Z2_TITULO := ""
            SZ2->Z2_CALC   := cPERIODO
            SZ2->Z2_TIPOPES:= "PJ"
            SZ2->Z2_CC     := aCtrId[_XI,12]
            SZ2->Z2_OBSTITU:= aCtrId[_XI,13]
            SZ2->Z2_PRODUTO:= cPRODUTO 
            SZ2->Z2_E2PRF  := ""
            SZ2->Z2_E2NUM  := ""
            SZ2->Z2_E2PARC := ""
            SZ2->Z2_E2TIPO := ""
            SZ2->Z2_E2FORN := ""
            SZ2->Z2_E2LOJA := ""
            SZ2->Z2_ANEXO  := ""
            SZ2->Z2_CPF    := aCtrId[_XI,4]
            SZ2->Z2_TIPCOL := 1
            SZ2->Z2_CODFOR := aCtrId[_XI,14]
            SZ2->Z2_LOJFOR := aCtrId[_XI,15]
				SZ2->(MsUnlock( ))
	 		ENDIF
		NEXT
	End Transaction
   u_MsgLog("BKGPEA02","Gerado com Sucesso, aguardando Liberação na Integração!","S")
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

Static Function BKF02Par()
Local lRet := .F.
Local aRet		:=	{}
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,@cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKGPEA02" ,.T.         ,.T.))
	lRet     := .T.
   cROTE    := mv_par01
   cSemana  := mv_par02
   dDatRef  := mv_par03
   cMatI    := mv_par04
   cMatF    := mv_par05
   dDatPGTO := mv_par06
   cOBS     := mv_par07

Endif
Return lRet
