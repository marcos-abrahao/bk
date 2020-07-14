#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINR27
BK - Titulos a Pagar com Histórico
@Return
@author Adilson do Prado
@since 18/03/2020
@version P12
/*/
//-------------------------------------------------------------------

User Function BKFINR27()

Local nF    	:= 0
Local NIL		:= 0
Local cCampo	:= ""
Local cTipo 	:= ""
Local nTam  	:= 0
Local nDec  	:= 0
Local cPict 	:= PesqPict("SE2","E2_VALOR")
Local cTitC 	:= ""
Local nTamCol   := 0
Local lTotal    := .F.
Local nTamPrd   := TamSX3("B1_COD")[01]
Private cTTipos 	:= ""

Private cTitulo     := "Titulos a Pagar"
Private cPerg       := "BKFINR27"

Private aParam		:=	{}
Private aRet		:=	{}

Private dDataI  	:= CTOD("")
Private dDataF  	:= CTOD("")
Private cProd       := PAD("29104004",nTamPrd)


Private aFields     := {}
Private aCabs       := {}
Private aCampos     := {}
Private aTitulos    := {}
Private aPlans      := {}
Private aDbf        := {}
Private aTamCol		:= {}
Private aTotal		:= {}
Private cAliasQry   := ""
Private cAliasTrb   := GetNextAlias()
Private nCont       := 0
Private aTotais     := {}
Private aLF         := {}
Private nTop		:= 3
Private nTopV		:= nTop + 1

aAdd( aParam, { 1, "Data Inicial:" 	 , dDataBase	, ""   , "", ""	   , "" , 70 , .F. })
aAdd( aParam, { 1, "Data Final:" 	 , dDataBase	, ""   , "", ""	   , "" , 70 , .F. })  
aAdd( aParam, { 1, "Produto"         , cProd        , ""   , "", "SB1" , "" , 70 , .F. })
If !BkFR27()
   Return
EndIf


aAdd(aTitulos,cPerg+"/"+TRIM(cUserName)+" - "+cTitulo)

aAdd(aFields,{"XX_TITULO"  ,"","XX_TITULO","Titulo","@!","C",13,0})
aAdd(aFields,{"XX_FORNECE" ,"","XX_FORNECE","Fornecedor","@!","C",60,0})
aAdd(aFields,{"XX_TIPO"    ,"E2_TIPO"})
aAdd(aFields,{"XX_VENC"    ,"E2_VENCREA"})
aAdd(aFields,{"XX_NATUREZ" ,"E2_NATUREZ"})
aAdd(aFields,{"XX_EMISSAO" ,"E2_EMISSAO"})
aAdd(aFields,{"XX_HIST"    ,"E2_HIST"})
aAdd(aFields,{"XX_VALOR"   ,"E2_VALOR"})
aAdd(aFields,{"XX_SALDO"   ,"","XX_SALDO","Saldo",cPict,"N",18,2})
aAdd(aFields,{"XX_DECRESC" ,"E2_DECRESC"})
aAdd(aFields,{"XX_ACRESC"  ,"E2_ACRESC"})
aAdd(aFields,{"XX_ISS"     ,"E2_ISS"})
aAdd(aFields,{"XX_VRETINS" ,"E2_VRETINS"})
aAdd(aFields,{"XX_VRETIRF" ,"E2_VRETIRF"})
aAdd(aFields,{"XX_VRETPIS" ,"E2_VRETPIS"})
aAdd(aFields,{"XX_VRETCOF" ,"E2_VRETCOF"})
aAdd(aFields,{"XX_VRETCSL" ,"E2_VRETCSL"})
aAdd(aFields,{"XX_PORTADO" ,"E2_PORTADO"})
aAdd(aFields,{"XX_XXTIPBK" ,"E2_XXTIPBK"})
aAdd(aFields,{"XX_XXCTRID" ,"E2_XXCTRID"})
//aAdd(aFields,{"XX_USER"    ,"","XX_USER","Usuário","@!","C",40,0})
//aAdd(aFields,{"XX_LIBERDO" ,"","XX_LIBERDO","Liberado por","@!","C",40,0})
aAdd(aFields,{"XX_FORMPGT" ,"","XX_FORMPGT","Forma pgto","@!","C",40,0})
aAdd(aFields,{"XX_PRODUTO" ,"","XX_PRODUTO","Produto","@!","C",nTamPrd,0})
aAdd(aFields,{"XX_VALPROD" ,"","XX_VALPROD","Vl.Produto",cPict,"N",18,2})
aAdd(aFields,{"XX_HISTNF"  ,"","XX_HISTNF","Histórico","@!","C",250,0})

aDbf := {}

For nF := 1 To Len(aFields)

	aAdd(aCampos,"(cAliasTrb)->"+aFields[nF,1])
	cCampo := aFields[nF,1]
	cTipo  := ""
	nTam   := 0
	nDec   := 0
	cPict  := ""
	cTitC  := ""

	If Len(aFields[NF]) > 3
		If !Empty(aFields[nF,4])
			cTitC := aFields[nF,4]
		EndIf
	EndIf

	If Len(aFields[NF]) > 4
		If !Empty(aFields[nF,5])
			cPict := aFields[nF,5]
		EndIf
	EndIf

	If Len(aFields[NF]) > 5
		If !Empty(aFields[nF,6])
			cTipo := aFields[nF,6]
		EndIf
	EndIf

	If Len(aFields[NF]) > 6
		If !Empty(aFields[nF,7])
			nTam := aFields[nF,7]
		EndIf
	EndIf

	If Len(aFields[NF]) > 7
		If !Empty(aFields[nF,8])
			nDec := aFields[nF,8]
		EndIf
	EndIf

	If Empty(cTitC)
		cTitC := RetTitle(aFields[nF,2])
	EndIf
	If Empty(cPict)
		cPict := GetSX3Cache(aFields[nF,2],"X3_PICTURE")
	EndIf
	If Empty(cTipo)
		cTipo := GetSX3Cache(aFields[nF,2],"X3_TIPO")
	EndIf
	If nTam = 0
		nTam  := GetSX3Cache(aFields[nF,2],"X3_TAMANHO")
	EndIf
	If nDec = 0 .and. GetSX3Cache(aFields[nF,2],"X3_DECIMAL") <> Nil
		nDec  := GetSX3Cache(aFields[nF,2],"X3_DECIMAL")
	EndIf
		
	aAdd( aDbf,  {cCampo , cTipo, nTam, nDec } )
	aAdd( aCabs, cTitC)

	nTamCol := 0
	lTotal  := .F.
	If cTipo == "N"
		nTamCol := 17
		lTotal  := .T.
	ElseIf cTipo == "D"
		nTamCol := 15
	Else
		If nTam > 8
			nTamCol := nTam + 1
		EndIf
	EndIf
	aAdd( aTamCol, nTamCol)
	aAdd( aTotal,lTotal)
Next


//----------------------------
//Criação da tabela temporária
//----------------------------
oTmpTb := FWTemporaryTable():New( cAliasTrb )
oTmpTb:SetFields( aDbf )

//oTmpTb:AddIndex("01", {"DESCR"} )
oTmpTb:Create()
nCont:= 0

Processa( {|| ProcBKR27() })

If nCont > 0
    AADD(aPlans,{cAliasTrb,TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, .F. })
    U_GeraXlsx(aPlans,"",cPerg, .F., aParam)
else
    MsgStop("Não foram encontrados registros para esta seleção", cPerg)
EndIf

oTmpTb:Delete()

Return


Static Function BkFR27
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKFINR27",.T.         ,.T.))
	lRet     := .T.
	dDataI   := mv_par01
	dDataF   := mv_par02
    cProd    := mv_par03
	cTitulo  := "Títulos a Pagar - Período: "+DTOC(dDataI)+" até "+DTOC(dDataF)
Endif
Return lRet



Static Function ProcBKR27
Local cQuery      := ""
Local nF         := 0
Local nSaldo     := 0
Local cDtHoraLib := ""
Local cDadosBanc := ""
Local cxTipoPg   := ""
Local cxNumPa    := ""
Local cFormaPgto := ""
//Local aLib       := {}
Local cHist      := ""
Local cFilD1     := ""
Local cD1Prod    := ""
Local nD1Prod    := 0


Private xCampo


cQuery := "SELECT "
For nF := 1 To Len(aFields)
	If LEN(aFields[nF]) < 3 .OR. Empty(aFields[nF,3])
		cQuery += aFields[nF,2]+","
	EndIf
Next
cQuery += "SE2.R_E_C_N_O_ AS E2RECNO,E2_PREFIXO+''+E2_NUM AS XX_TITULO,"+ CRLF
cQuery += " A2_COD+'-'+A2_LOJA+' - '+A2_NOME AS XX_FORNECE "+ CRLF
cQuery += " FROM "+RETSQLNAME("SE2")+" SE2" + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SA2")+" SA2 ON SA2.A2_COD = SE2.E2_FORNECE"
cQuery += " AND SA2.A2_LOJA = SE2.E2_LOJA AND SA2.D_E_L_E_T_ = ' ' AND SA2.A2_FILIAL = '" + xFilial("SA2") + "' " + CRLF
cQuery += " WHERE SE2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += " AND SE2.E2_FILIAL = '" + xFilial("SE2") + "' " + CRLF
cQuery += " AND E2_TIPO NOT IN "+FormatIn(MVABATIM,"|")

If !Empty(dDataI)
	cQuery += " AND SE2.E2_EMISSAO >= '"+DTOS(dDataI)+"'" + CRLF
EndIf
If !Empty(dDataF)
	cQuery += " AND SE2.E2_EMISSAO <= '"+DTOS(dDataF)+"'" + CRLF
EndIf          
cQuery += " ORDER BY E2_EMISSAO,E2_NUM"

u_LogMemo("BKFINR27.SQL",cQuery)

cQuery := ChangeQuery(cQuery)
cAliasQry := "TMPR27" //GetNextAlias()


dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
TCSETFIELD(cAliasQry,"E2_EMISSAO","D", 8,0)
TCSETFIELD(cAliasQry,"E2_VENCREA","D", 8,0)
ProcRegua((cAliasQry)->(LastRec()))
	
dbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())

cFilD1 := xFilial("SD1")

DO WHILE (cAliasQry)->(!EOF())
	IncProc("Consultando banco de dados...")
	dbSelectArea(cAliasTrb)

    cD1Prod := ""
    nD1Prod := 0
	SE2->(dbGoTo((cAliasQry)->E2RECNO))
    cHist := ""
    dbSelectArea("SD1")                   // * Itens da N.F. de Compra
    IF MsSeek(cFilD1+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA)
        DO WHILE !EOF() .AND. cFilD1+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA == ;
            SD1->D1_FILIAL+SD1->D1_DOC+ SD1->D1_SERIE+ SD1->D1_FORNECE+ SD1->D1_LOJA
            IF !ALLTRIM(SD1->D1_XXHIST) $ cHist                   
                cHist += ALLTRIM(SD1->D1_XXHIST)+" "  //IIF(ALLTRIM(SD1->D1_XXHIST) $ cHist,"",cHist+" ") 
            ENDIF
            If ALLTRIM(SD1->D1_COD) == ALLTRIM(cProd) .OR. EMPTY(cProd)
                If Empty(cProd)
                    If Empty(cD1Prod)
                        cD1Prod := SD1->D1_COD
                    Else
                        cD1Prod := "DIVERSOS PRODS"
                    EndIf
                Else
                    cD1Prod := SD1->D1_COD
                EndIf
               nD1Prod += SD1->D1_TOTAL
            EndIf
            SD1->(dbSkip())
        ENDDO
    ENDIF
	
    If ALLTRIM(cProd) == ALLTRIM(cD1Prod) .OR. Empty(cProd)

        nCont++

        dbSelectArea(cAliasTrb)

        Reclock(cAliasTrb,.T.)

        For nF := 1 To Len(aFields)
            If Len(aFields[nF]) > 2 .AND. !Empty(aFields[nF,3])
                If (cAliasQry)->(FieldPos(aFields[nF,3])) > 0
                    xCampo := &(cAliasQry+"->"+aFields[nF,3])
                EndIf
            Else
                xCampo := &(cAliasQry+"->"+aFields[nF,2])
            EndIf

            If aFields[nF,1] = "XX_SALDO"
                SE2->(dbGoTo((cAliasQry)->E2RECNO))
                nSaldo := 0
                IF TRANSFORM(SE2->E2_SALDO,"@e 999,999,999.99") == TRANSFORM(SE2->E2_VALOR,"@e 999,999,999.99")
                    nSaldo := SE2->E2_VALOR + (SE2->E2_ACRESC - SE2->E2_DECRESC)
                ELSE
                    nSaldo := SE2->E2_SALDO
                ENDIF 
                xCampo := nSaldo
            ElseIf aFields[nF,1] = "XX_USER"
                /*

                SE2->(dbGoTo((cAliasQry)->E2RECNO))
                dbSelectArea("SF1")                   // * Cabeçalho da N.F. de Compra
                dbSetOrder(1)
                cFilF1     := xFilial("SF1")
                cUser      := ""
                cDigUser   := ""
                cFormaPgto := ""
                
                IF MsSeek(cFilF1+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA+"N")
                    cUser := SF1->F1_XXUSER
                    PswOrder(1) 
                    PswSeek(cUser) 
                    aUser  := PswRet(1)
                    IF !EMPTY(aUser)
                        cDigUser := aUser[1,2]
                    ENDIF
                    cDtHoraLib := FWLeUserlg("F1_USERLGA", 2)+TRIM(" "+SF1->F1_HORA)
                    cxTipoPg := SF1->F1_XTIPOPG
                    cxNumPa  := SF1->F1_XNUMPA
                    If !Empty(cxTipoPg)
                        cFormaPgto := TRIM(cxTipoPg)
                        If TRIM(cxTipoPg) == "DEPOSITO" //.AND. SF1->F1_FORNECE <> "000084"
                            If Empty(SF1->F1_XBANCO) .AND. SF1->F1_FORNECE <> "000084"
                                cDadosBanc := "Bco: "+ALLTRIM(SA2->A2_BANCO)+" Ag: "+ALLTRIM(SA2->A2_AGENCIA)+" C/C: "+ALLTRIM(SA2->A2_NUMCON)
                            Else
                                cDadosBanc := "Bco: "+ALLTRIM(SF1->F1_XBANCO)+" Ag: "+ALLTRIM(SF1->F1_XAGENC)+" C/C: "+ALLTRIM(SF1->F1_XNUMCON)
                            EndIf
                            cFormaPgto += ": "+cDadosBanc
                        ElseIf TRIM(cxTipoPg) == "P.A."
                            cFormaPgto += " "+cxNumPa
                        EndIf
                    EndIf
                ENDIF
                IF EMPTY(cDigUser) .AND. !EMPTY(SE2->E2_USERLGI)
                    //cDigUser := USRFULLNAME(SUBSTR(EMBARALHA(SE2->E2_USERLGI,1),3,6))
                    cDigUser := USRRETNAME(SUBSTR(EMBARALHA(SE2->E2_USERLGI,1),3,6))
                ENDIF   
                cLibUser := SE2->E2_USUALIB
                IF ALLTRIM(SE2->E2_PREFIXO) $ "LF/DV/CX"
                    aLib := {}
                    aLib := U_BLibera("LFRH",SE2->E2_NUM) // Localiza liberação Alcada
                    cDigUser := aLib[1]
                    cLibUser := aLib[2]
                ELSE
                    aLib := {}
                    dbSelectArea("SD1")                   // * Itens da N.F. de Compra
                    IF MsSeek(cFilD1+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA)
                        aLib := U_BLibera(SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA,SD1->D1_PEDIDO) // Localiza liberação Alcada
                        IF LEN(aLib) > 0
                            cDigUser := aLib[1]
                            cLibUser := aLib[2]
                        ENDIF
                    ENDIF
                ENDIF
                xCampo := cDigUser
                */
            ElseIf aFields[nF,1] = "XX_LIBERDO"
                /*
                SE2->(dbGoTo((cAliasQry)->E2RECNO))
                dbSelectArea("SF1")                   // * Cabeçalho da N.F. de Compra
                dbSetOrder(1)
                cFilF1     := xFilial("SF1")
                cUser      := ""
                cDigUser   := ""
                cFormaPgto := ""
                
                IF MsSeek(cFilF1+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA+"N")
                    cUser := SF1->F1_XXUSER
                    PswOrder(1) 
                    PswSeek(cUser) 
                    aUser  := PswRet(1)
                    IF !EMPTY(aUser)
                        cDigUser := aUser[1,2]
                    ENDIF
                    cDtHoraLib := FWLeUserlg("F1_USERLGA", 2)+TRIM(" "+SF1->F1_HORA)
                    cxTipoPg := SF1->F1_XTIPOPG
                    cxNumPa  := SF1->F1_XNUMPA
                    If !Empty(cxTipoPg)
                        cFormaPgto := TRIM(cxTipoPg)
                        If TRIM(cxTipoPg) == "DEPOSITO" //.AND. SF1->F1_FORNECE <> "000084"
                            If Empty(SF1->F1_XBANCO) .AND. SF1->F1_FORNECE <> "000084"
                                cDadosBanc := "Bco: "+ALLTRIM(SA2->A2_BANCO)+" Ag: "+ALLTRIM(SA2->A2_AGENCIA)+" C/C: "+ALLTRIM(SA2->A2_NUMCON)
                            Else
                                cDadosBanc := "Bco: "+ALLTRIM(SF1->F1_XBANCO)+" Ag: "+ALLTRIM(SF1->F1_XAGENC)+" C/C: "+ALLTRIM(SF1->F1_XNUMCON)
                            EndIf
                            cFormaPgto += ": "+cDadosBanc
                        ElseIf TRIM(cxTipoPg) == "P.A."
                            cFormaPgto += " "+cxNumPa
                        EndIf
                    EndIf
                ENDIF
                IF EMPTY(cDigUser) .AND. !EMPTY(SE2->E2_USERLGI)
                    //cDigUser := USRFULLNAME(SUBSTR(EMBARALHA(SE2->E2_USERLGI,1),3,6))
                    cDigUser := USRRETNAME(SUBSTR(EMBARALHA(SE2->E2_USERLGI,1),3,6))
                ENDIF   
                cLibUser := SE2->E2_USUALIB
                IF ALLTRIM(SE2->E2_PREFIXO) $ "LF/DV/CX"
                    aLib := {}
                    aLib := U_BLibera("LFRH",SE2->E2_NUM) // Localiza liberação Alcada
                    cDigUser := aLib[1]
                    cLibUser := aLib[2]
                ELSE
                    aLib := {}
                    dbSelectArea("SD1")                   // * Itens da N.F. de Compra
                    IF MsSeek(cFilD1+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA)
                        aLib := U_BLibera(SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA,SD1->D1_PEDIDO) // Localiza liberação Alcada
                        IF LEN(aLib) > 0
                            cDigUser := aLib[1]
                            cLibUser := aLib[2]
                        ENDIF
                    ENDIF
                ENDIF

                xCampo := cLibUser
                */
            ElseIf aFields[nF,1] = "XX_FORMPGT"
                SE2->(dbGoTo((cAliasQry)->E2RECNO))
                dbSelectArea("SF1")                   // * Cabeçalho da N.F. de Compra
                dbSetOrder(1)
                cFilF1     := xFilial("SF1")
                cUser      := ""
                cDigUser   := ""
                cFormaPgto := ""
                cLibUser := SE2->E2_USUALIB
                IF MsSeek(cFilF1+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA+"N")
                    cUser := SF1->F1_XXUSER
                    PswOrder(1) 
                    PswSeek(cUser) 
                    aUser  := PswRet(1)
                    IF !EMPTY(aUser)
                        cDigUser := aUser[1,2]
                    ENDIF
                    cDtHoraLib := FWLeUserlg("F1_USERLGA", 2)+TRIM(" "+SF1->F1_HORA)
                    cxTipoPg := SF1->F1_XTIPOPG
                    cxNumPa  := SF1->F1_XNUMPA
                    If !Empty(cxTipoPg)
                        cFormaPgto := TRIM(cxTipoPg)
                        If TRIM(cxTipoPg) == "DEPOSITO" //.AND. SF1->F1_FORNECE <> "000084"
                            If Empty(SF1->F1_XBANCO) .AND. SF1->F1_FORNECE <> "000084"
                                cDadosBanc := "Bco: "+ALLTRIM(SA2->A2_BANCO)+" Ag: "+ALLTRIM(SA2->A2_AGENCIA)+" C/C: "+ALLTRIM(SA2->A2_NUMCON)
                            Else
                                cDadosBanc := "Bco: "+ALLTRIM(SF1->F1_XBANCO)+" Ag: "+ALLTRIM(SF1->F1_XAGENC)+" C/C: "+ALLTRIM(SF1->F1_XNUMCON)
                            EndIf
                            cFormaPgto += ": "+cDadosBanc
                        ElseIf TRIM(cxTipoPg) == "P.A."
                            cFormaPgto += " "+cxNumPa
                        EndIf
                    EndIf
                ENDIF
                xCampo := cFormaPgto
            ElseIf aFields[nF,1] = "XX_HISTNF"
                xCampo := cHist
            ElseIf aFields[nF,1] = "XX_PRODUTO"
                xCampo := cD1Prod
            ElseIf aFields[nF,1] = "XX_VALPROD"
                xCampo := nD1Prod
            EndIf
            //ConOut(aFields[nF,1],xCampo)
            &(cAliasTrb+"->"+aFields[nF,1]) :=  xCampo
        Next

        (cAliasTrb)->(MsUnLock())
    EndIf

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbSkip())
ENDDO

(cAliasQry)->(dbCloseArea())

dbSelectArea(cAliasTrb)
dbGoTop()

Return
