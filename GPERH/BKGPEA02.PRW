#Include "Protheus.ch"
#include "rwmake.ch"
#include "TBICONN.CH"
#include "TopConn.ch"
#include "report.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKGPEA02
OSESP - Rotina Gerar pgto no financeiro PJ90
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
Local lSZ2EXIST := .F.
Local oDlg02
Local aButtons2
Local oOk
Local oNo
Local oPanelLeft
Local aCONTA:= {}
Local _CONTA := ""
Local _DIGCONT := ""
Local _XI := 0
Local cPerg := "BKGPEA02"
Local _nFALTAS := 0
Local aCtrId 	:= {}

PRIVATE aParam := {}
PRIVATE cMatI := ""
PRIVATE cMatF := ""
PRIVATE dDatRef  := CTOD("")
PRIVATE dDatPGTO := CTOD("")

aAdd( aParam, { 1, "Data de Referencia:" , CTOD("")					, ""            , ""   , ""	  , "" , 70  , .F. })
aAdd( aParam, { 1, "Matricula de:"	     , SPACE(06)	                , ""            , ""   , "SRA", "" , 70  , .F. })
aAdd( aParam, { 1, "Matricula até:"	     , SPACE(06)             	, ""            , ""   , "SRA", "" , 70  , .F. })
aAdd( aParam, { 1, "Data do Pagamento:" 		  , CTOD("")					, ""            , ""   , ""	  , "" , 70  , .F. })  

If !BKF02Par()
   Return
EndIf

u_MsgLog(cPerg)

aCtrId := {}

_SQL:= "SELECT ZK_CODIGO,ZK_CPF,ZK_NOME,ZK_RG,ZK_CODSUP,ZK_NOMSUP,ZK_XXNMG,ZK_MAT,"
_SQL+= "ZK_SRANOME,ZK_MOTIVO,ZK_PERDE,ZK_PERATE,ZK_SITUAC,ZK_ADIANT,ZK_TOTAL"
_SQL+= " FROM " +RETSQLNAME('SZK')+" SZK"
_SQL+= " WHERE SZK.D_E_L_E_T_='' AND ZK_FILIAL ='"+XFILIAL('SZK')+"'"

IF !EMPTY( MV_PAR02 ) .AND.  !EMPTY( MV_PAR03 )
	_SQL+= " AND ZK_DATA>='"+DTOS(MV_PAR02)+"' "
	_SQL+= " AND ZK_DATA<='"+DTOS(MV_PAR03)+"' "
ENDIF

IF !EMPTY( MV_PAR04 ) .AND.  !EMPTY( MV_PAR05 )
	_SQL+= " AND ZK_CODIGO>='"+MV_PAR04+"' "
	_SQL+= " AND ZK_CODIGO<='"+MV_PAR05+"' "
ENDIF

IF !EMPTY( MV_PAR06 ) .AND.  !EMPTY( MV_PAR07 )
	_SQL+= " AND ZK_CODSUP>='"+MV_PAR06+"' "
	_SQL+= " AND ZK_CODSUP<='"+MV_PAR07+"' "
ENDIF

		
IF SELECT('QSZK')> 0
	QSZK->(DBCLOSEAREA())
ENDIF
		
DBUSEAREA(.T.,"TOPCONN"	,TCGENQRY(,,_SQL),'QSZK',.F.,.T.)
TCSETFIELD("QSZK","ZK_PERDE","D",8,0)
TCSETFIELD("QSZK","ZK_PERATE","D",8,0)

DBSELECTAREA('QSZK')
QSZK->(DBGOTOP())
while QSZK->(!EOF())
	nMotivo :=  Ascan(aMotivo,{|X| SUBSTR(X,1,2) == QSZK->ZK_MOTIVO }) 
	cMotivo := IIF(nMotivo>0,aMotivo[nMotivo],"")
	lSZMEXIST := .F.
	IF cOPC=='2' // GERA ADIANTAMENTO VT
		DBSELECTAREA("SZM")
		SZM->(DBSETORDER(2))   
		IF SZM->(DBSEEK(xFILIAL("SZM")+SM0->M0_CODIGO+QSZK->ZK_CODIGO+"AVT",.F.)) //ZM_FILIAL+ZM_CODEMP+ZM_IDSZK+ZM_TIPO 
        	lSZMEXIST := .T.
        ENDIF
    ENDIF
	IF cOPC=='3' .OR. cOPC=='-1'  //GERA PGTO OU DEVOLVE AO OPERACIONAL
		DBSELECTAREA("SZM")
		SZM->(DBSETORDER(2))   
		IF SZM->(DBSEEK(xFILIAL("SZM")+SM0->M0_CODIGO+QSZK->ZK_CODIGO+"LPM",.F.)) //ZM_FILIAL+ZM_CODEMP+ZM_IDSZK+ZM_TIPO 
        	lSZMEXIST := .T.
        ENDIF
    ENDIF
    IF !lSZMEXIST
	    AADD(aCtrId,{.T.,;
	    			 QSZK->ZK_CODIGO,;
					 QSZK->ZK_CPF,;
					 QSZK->ZK_NOME,;
					 IIF(cOPC=='2',QSZK->ZK_ADIANT,QSZK->ZK_TOTAL),;
					 QSZK->ZK_RG,;
					 QSZK->ZK_CODSUP,;
					 QSZK->ZK_NOMSUP,;
					 QSZK->ZK_MAT,;
					 QSZK->ZK_SRANOME,;
					 cMotivo,;
					 QSZK->ZK_PERDE,;
					 QSZK->ZK_PERATE,;
					 QSZK->ZK_SITUAC})
	ENDIF
	    
	QSZK->(DBSKIP())
ENDDO
QSZK->(DBCLOSEAREA())



If Empty(aCtrId)
	MsgStop("Nenhum funcionario nesta seleção, verifique os filtros !!", "Atenção")
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
oAll:bChange := {|| Aeval(aCtrId,{|x| x[1]:=lAll }), oListId:Refresh()}

@ 015, 005 LISTBOX oListId FIELDS HEADER "","Codigo Solic.","CPF","Nome","Valor","RG","Cod.Sup","Supervisor","Mat. Ausente:","Nome Func. Ausente:","Motivo da Ausencia","Periodo de","Periodo Até","Status Ausente" SIZE 520,245 OF oPanelLeft PIXEL 
oListID:SetArray(aCtrId)
oListID:bLine := {|| {If(aCtrId[oListId:nAt][1],oOk,oNo),;
						 aCtrId[oListId:nAt][2],;
						 aCtrId[oListId:nAt][3],;
						 aCtrId[oListId:nAt][4],;
						 TransForm(aCtrId[oListId:nAt][5],'@E 999,999.99'),;
						 aCtrId[oListId:nAt][6],;
						 aCtrId[oListId:nAt][7],;
						 aCtrId[oListId:nAt][8],;
						 aCtrId[oListId:nAt][9],;
						 aCtrId[oListId:nAt][10],;
						 aCtrId[oListId:nAt][11],;
						 aCtrId[oListId:nAt][12],;
						 aCtrId[oListId:nAt][13],;
						 aCtrId[oListId:nAt][14]}}
						                                                      
oListID:bLDblClick := {|| aCtrId[oListId:nAt][1] := MrkTit(aCtrId[oListId:nAt][1],aCtrId[oListId:nAt][10]), oListID:DrawSelect()}

ACTIVATE MSDIALOG oDlg02 CENTERED ON INIT EnchoiceBar(oDlg02,{|| lOk2:=.T., oDlg02:End()},{|| oDlg02:End()}, , aButtons2)
 
If ( lOk2 )
	lOk2:=.F.
	Begin Transaction
		FOR  _XI:=1 TO LEN(aCtrId)
			IF aCtrId[_XI,1] 

				IF cOPC=='-1'
					DBSELECTAREA("SZM")
					SZM->(DBSETORDER(2))   
					IF SZM->(DBSEEK(xFILIAL("SZM")+SM0->M0_CODIGO+aCtrId[_XI,2]+"LPM",.F.)) //ZM_FILIAL+ZM_CODEMP+ZM_IDSZK 
						MSGSTOP("Ezitem titulos no Financeiro para essa Solicitação: "+aCtrId[_XI,2]+", deve excluir o Titulo. Verifique!!")
						Return nil
					ENDIF
				ENDIF

				IF cOPC=='1' .OR. cOPC=='2'

					IF cOPC=='2'
						DBSELECTAREA("SZK")
						SZK->(DBSETORDER(1))
						SZK->(DBSEEK(xFILIAL("SZK")+aCtrId[_XI,2],.F.))
						RecLock("SZK",.F.)
						SZK->ZK_SOLADIA := "S"
						SZK->(MsUnlock( ))
					ENDIF

					_REFPGTO:= ""
 					nDIASZK := 0
					nDIASZK := DateDiffDay(SZK->ZK_PERDE,SZK->ZK_PERATE)+1
					IF SZK->ZK_TIPO == '05'
						nCalcSal:= SZK->ZK_SALARIO+SZK->ZK_ADICION
					ELSE
						nCalcSal:= ((SZK->ZK_SALARIO+SZK->ZK_ADICION)/30)*nDIASZK
					ENDIF
					_REFPGTO:= ""+"|"+TRIM(MesExtenso(SZK->ZK_PERDE))+"|"+STR(nDIASZK,2)+"|"+STR(nCalcSal,14,2)+"|0#"
                    IF SZK->ZK_SOLADIA == "S"
						_REFPGTO += ""+"|Adiantamento VT|0|0|"+STR(SZK->ZK_ADIANT,14,2)+"#"
                    ENDIF
                    IF SZK->ZK_CESTA == "S"
						_REFPGTO += ""+"|Cesta Basica|0|"+STR(SZK->ZK_CESTAVA,14,2)+"|0#"
                    ENDIF
                    IF SZK->ZK_VR == "S"
						_REFPGTO += ""+"|Vale Refeição|0|"+STR(SZK->ZK_VRVALORA,14,2)+"|0#"
                    ENDIF
                    IF SZK->ZK_VT == "S"
						_REFPGTO += ""+"|Vale Transporte|0|"+STR(SZK->ZK_TOTALVT,14,2)+"|0#"
						_REFPGTO += ""+"|Desc. Vale Transporte|0|0|"+STR(nCalcSal*0.06,14,2)+"#"
                    ENDIF
                    IF SZK->ZK_VALMATE > 0
                        _REFPGTO += ""+"|Material|0|"+STR(SZK->ZK_VALMATE,14,2)+"|0#"
                    ENDIF
                    _nFALTAS := 0 
                    IF SZK->ZK_FALTAS > 0
						IF SZK->ZK_TIPO == '05'
                    		_nFALTAS := (nCalcSal/30) * SZK->ZK_FALTAS
						ELSE
                    		_nFALTAS := (nCalcSal/nDIASZK) * SZK->ZK_FALTAS
						ENDIF
                        _REFPGTO += ""+"|Faltas|"+TRIM(STR(SZK->ZK_FALTAS))+"|0|"+STR(_nFALTAS,14,2)+"#"
                    ENDIF

		        ENDIF

				DBSELECTAREA("SZK")
				SZK->(DBSETORDER(1))
				SZK->(DBSEEK(xFILIAL("SZK")+aCtrId[_XI,2],.F.))
				RecLock("SZK",.F.)
				IF cOPC=='-1'
					SZK->ZK_STATUS:= "02"
					SZK->ZK_LOG := SZK->ZK_LOG+"DEVOLVIDO - USUARIO = "+cUSERN+" Data= "+DTOC(DATE())+" Hora="+time()+cCrLf
				ELSEIF cOPC=='-2'
					SZK->ZK_BAIXA:= "S"
					SZK->ZK_LOG := SZK->ZK_LOG+"BAIXADO - USUARIO = "+cUSERN+" Data= "+DTOC(DATE())+" Hora="+time()+cCrLf
				ELSEIF cOPC=='1'
					SZK->ZK_STATUS := IIF(SZK->ZK_STPENDE,"04",IIF(SZK->ZK_STATUS="02","10","03"))
					IF EMPTY(SZK->ZK_REFPGTO)
						SZK->ZK_REFPGTO := _REFPGTO
					ENDIF
					SZK->ZK_LOG := SZK->ZK_LOG+"ENVIADO A SOLIC ANALISE - USUARIO = "+cUSERN+" Data= "+DTOC(DATE())+" Hora="+time()+cCrLf
				ELSEIF cOPC=='2'
					SZK->ZK_STATUS := "05"
					SZK->ZK_SOLADIA := "S"
					IF EMPTY(SZK->ZK_REFPGTO)
						SZK->ZK_REFPGTO := _REFPGTO
					ENDIF
					SZK->ZK_LOG := SZK->ZK_LOG+"ENVIADO AO FINANCEIRO SOLIC ADTO VT - USUARIO = "+cUSERN+" Data= "+DTOC(DATE())+" Hora="+time()+cCrLf
					SZK->ZK_DTADIAN := DataValida(DaySum(DATE(),3),.T.) 
				ELSEIF cOPC=='3'
					SZK->ZK_STATUS := "07"
					SZK->ZK_LOG := SZK->ZK_LOG+"ENVIADO AO FINANCEIRO SOLIC PGTO - USUARIO = "+cUSERN+" Data= "+DTOC(DATE())+" Hora="+time()+cCrLf
					SZK->ZK_DTPGTO  := DataValida(DaySum(DATE(),3),.T.) 
				ENDIF
				SZK->(MsUnlock())
				
				IF cOPC=='2' .OR. cOPC=='3' 
					DBSELECTAREA("SZM")
					SZM->(DBSETORDER(2))   
					IF !SZM->(DBSEEK(xFILIAL("SZM")+SM0->M0_CODIGO+aCtrId[_XI,2]+IIF(cOPC=='2',"AVT","LPM"),.F.)) //ZM_FILIAL+ZM_CODEMP+ZM_IDSZK+ZM_TIPO 
					
						nFormPGTO :=  Ascan(aFormPGTO,{|X| SUBSTR(X,1,2) == SUBSTR(SZK->ZK_FORPGTO,1,2)}) 
				   		_FORPGTO := IIF(nFormPGTO>0,aFormPGTO[nFormPGTO],"")
						nTCBCO :=  Ascan(aTCBCO,{|X| SUBSTR(X,1,2) == SUBSTR(SZK->ZK_TCBCO,1,2)}) 
				   		_TCBCO := IIF(nTCBCO>0,aTCBCO[nTCBCO],"") 

						aCONTA := {}
						_CONTA := ""
						_DIGCONT := ""
						aCONTA := U_StringToArray(ALLTRIM(SZK->ZK_CTDEPSA),"-")
						IF LEN(aCONTA) > 1
							_CONTA := ALLTRIM(aCONTA[1])
							_DIGCONT := ALLTRIM(aCONTA[2])
						ELSE
							_CONTA := ALLTRIM(SZK->ZK_CTDEPSA)
						ENDIF
						IF LEN(_CONTA)==10
							_DIGCONT := SUBSTR(_CONTA,10,1)
							_CONTA   := SUBSTR(_CONTA,1,9)
						ENDIF

						RecLock("SZM",.T.)
						SZM->ZM_FILIAL 	:= xFilial("SZM")
						SZM->ZM_IDSZK 	:= SZK->ZK_CODIGO
						SZM->ZM_CODEMP	:= SM0->M0_CODIGO
						SZM->ZM_CPF	 	:= SZK->ZK_CPF
						SZM->ZM_NOME 	:= SZK->ZK_NOME
						SZM->ZM_VALOR 	:= IIF(SZK->ZK_TIPO == "05" .AND. cOPC<>'2',SZK->ZK_TOTAL-SZK->ZK_VALMATE,IIF(cOPC=='2',SZK->ZK_ADIANT,SZK->ZK_TOTAL))
						SZM->ZM_TIPO 	:= IIF(cOPC=='2',"AVT","LPM")
						SZM->ZM_BANCO 	:= SZK->ZK_BCDEPSA
						SZM->ZM_AGENCIA := SUBSTR(SZK->ZK_AGDEPSA,1,4)
						SZM->ZM_DIGAGEN := SUBSTR(SZK->ZK_AGDEPSA,5,1)
						SZM->ZM_CONTA 	:= _CONTA
						SZM->ZM_DIGCONT := _DIGCONT
						SZM->ZM_DATAEMI := DATE()
						SZM->ZM_DATAPGT := IIF(SZK->ZK_TIPO == "05".AND. !EMPTY(MV_PAR08),MV_PAR08,DataValida(DaySum(DATE(),3),.T.)) 
						SZM->ZM_USUARIO := __CUSERID
						SZM->ZM_TIPOPES := SZK->ZK_TIPO
						SZM->ZM_CC 		:= Posicione("SRA",1,xFilial("SRA")+SZK->ZK_MAT,"RA_CC")
						SZM->ZM_MAT 	:= SZK->ZK_MAT
						SZM->ZM_HORALIB := TIME()
						SZM->ZM_OBSTITU	:= IIF(cOPC=='2',"Adiantamento,","Pagamento,")+","+TRIM(_TCBCO)+","+TRIM(_FORPGTO)
						SZM->ZM_APROV 	:= cUSERN
						SZM->(MsUnlock( ))

						IF SZK->ZK_TIPO == "05" .AND. SZK->ZK_VALMATE > 0
							RecLock("SZM",.T.)
							SZM->ZM_FILIAL 	:= xFilial("SZM")
							SZM->ZM_IDSZK 	:= SZK->ZK_CODIGO
							SZM->ZM_CODEMP	:= SM0->M0_CODIGO
							SZM->ZM_CPF	 	:= SZK->ZK_CPF
							SZM->ZM_NOME 	:= SZK->ZK_NOME
							SZM->ZM_VALOR 	:= SZK->ZK_VALMATE
							SZM->ZM_TIPO 	:= "MAT"
							SZM->ZM_BANCO 	:= SZK->ZK_BCDEPSA
							SZM->ZM_AGENCIA := SUBSTR(SZK->ZK_AGDEPSA,1,4)
							SZM->ZM_DIGAGEN := SUBSTR(SZK->ZK_AGDEPSA,5,1)
							SZM->ZM_CONTA 	:= _CONTA
							SZM->ZM_DIGCONT := _DIGCONT
							SZM->ZM_DATAEMI := DATE()
							SZM->ZM_DATAPGT := IIF(SZK->ZK_TIPO == "05".AND. !EMPTY(MV_PAR08),MV_PAR08,DataValida(DaySum(DATE(),3),.T.))
							SZM->ZM_USUARIO := __CUSERID
							SZM->ZM_TIPOPES := SZK->ZK_TIPO
							SZM->ZM_CC 		:= Posicione("SRA",1,xFilial("SRA")+SZK->ZK_MAT,"RA_CC")
							SZM->ZM_MAT 	:= SZK->ZK_MAT
							SZM->ZM_HORALIB := TIME()
							SZM->ZM_OBSTITU	:= "Material, "+TRIM(_TCBCO)+","+TRIM(_FORPGTO)
							SZM->ZM_APROV 	:= cUSERN
							SZM->(MsUnlock( ))
						ENDIF

					ENDIF    
				ENDIF
	 		ENDIF
		NEXT
		IF cOPC=='1'
			IF LEN(aCtrId) > 0
				IF MsgYesNo("Gerar Protocolo da Solicitação- 6019")
					U_SZKR02(aCtrId) 
				ENDIF
			ENDIF
		ENDIF
		IF cOPC=='2' .OR. cOPC=='3'
			IF LEN(aCtrId) > 0
				IF MsgYesNo("Gerar Protocolo do Financeiro - 6019")
					U_SZKR03(aCtrId,cOPC)
				ENDIF
			ENDIF
		ENDIF
	End Transaction
Endif

RestArea(aAreaIni)
Return

Static Function BKF02Par()
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,@cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKFATR04" ,.T.         ,.T.))
	lRet       := .T.
	dDataI     := mv_par01
	dDataF     := mv_par02
    cPrefixos  := mv_par03
    cSufixos   := mv_par04
    cContratos := mv_par05

	cPrefixos  := STRTRAN(cPrefixos,CRLF,"")
	cPrefixos  := STRTRAN(cPrefixos,",",";")
	cPrefixos  := STRTRAN(cPrefixos," ","")

	cSufixos   := STRTRAN(cSufixos,CRLF,"")
	cSufixos   := STRTRAN(cSufixos,",",";")
	cSufixos   := STRTRAN(cSufixos," ","")

	cContratos := STRTRAN(cContratos,CRLF,"")
	cContratos := STRTRAN(cContratos,",",";")
	cContratos := STRTRAN(cContratos," ","")
Endif
Return lRet
