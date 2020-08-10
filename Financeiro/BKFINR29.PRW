#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINR29
BK - Planilha de Previsão de Pagamentos e Recebimentos
@Return
@author Marcos Bispo Abrahão
@since 02/08/2020
@version P12.1.25
/*/
//-------------------------------------------------------------------
Static __oTBxCanc
Static __oTipoBa

User Function BKFINR29()
Local nI            := 0
Local nJ            := 0
Local aTipos        := {}
Local cTipoTmp      := ""


Private oTmpTb
Private oTmpTb2

Private cTitulo     := "Previsão de Pagamentos e Recebimentos"
Private cPerg       := "BKFINR29"

Private aParam		:=	{}
Private aRet		:=	{}

Private dDataI  	:= CTOD("")
Private dDataF  	:= CTOD("")

Private aCabs       := {}
Private aCampos     := {}
Private aTitulos    := {}
Private aPlans      := {}
Private aFormula    := {}
Private aDbf        := {}
Private aDbf2       := {}

Private cAliasTrb   := ""
Private cAliasTrb2  := ""
Private nCont       := 0

Private aDias       := {}
Private aPlan2 		:= {}
Private aPlanTmp	:= {}
Private aBkR29      := {}

aAdd( aParam, { 1, "Data Inicial:" 	 , dDataBase	, "" , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Data Final:" 	 , dDataBase	, "" , "", ""	, "" , 70  , .F. })  

If !BkFR29()
   Return
EndIf


//----------------------------------- e1saldo ----
If !Empty( __oTBxCanc )
	__oTBxCanc:Destroy()
	__oTBxCanc := Nil
EndIf
If !Empty( __oTipoBa )
	__oTipoBa:Destroy()
	__oTipoBa := Nil
EndIf

__oTBxCanc	:= FWPreparedStatement():New( '' )
__oTipoBa	:= FWPreparedStatement():New( '' )

// -----------------------------------------------


aAdd(aTitulos,cTitulo)

aDbf := {}
Aadd( aDbf, { "XX_XXTIPBK","C",  6,0 } )
Aadd( aDbf, { "XX_CLIENTE","C",  6,0 } )
Aadd( aDbf, { "XX_LOJA"   ,"C",  2,0 } )
Aadd( aDbf, { "XX_SALDO"  ,"N", 18,2 } ) 
Aadd( aDbf, { "XX_VENCREA","C",  8,0 } )
Aadd( aDbf, { "XX_LINHA"  ,"N",  3,0 } )

cAliasTrb  := GetNextAlias()
oTmpTb := FWTemporaryTable():New( cAliasTrb )
oTmpTb:SetFields( aDbf )

oTmpTb:AddIndex("01", {"XX_VENCREA","XX_XXTIPBK"} )
oTmpTb:AddIndex("02", {"XX_VENCREA","XX_CLIENTE","XX_LOJA"} )
oTmpTb:Create()

nCont:= 0


// Contas a Receber
aAdd(aPlanTmp,{.T.,"CLIENTES",""})
Processa( {|| PrcE1BK29() },"Contas a Receber")

// Contas a Pagar
aPlan2 := U_BKR25PL2()
For nI := 1 To Len(aPlan2)-1   //(- 1 para tirar o "Total")

    cTipoTmp := ""
	If !Empty(aPlan2[nI,3])
        cTipoTmp := ""
		aTipos := StrTokArr(aPlan2[nI,3],"/")
        For nJ := 1 To Len(aTipos)
            cTipoTmp += PAD(aTipos[nJ],6)+"/"
        Next
    Else
        aTipos := {}
	EndIf

    aAdd(aPlanTmp,{aPlan2[nI,1],aPlan2[nI,2],cTipoTmp})
Next
Processa( {|| PrcE2BK29() },"Contas a Pagar")


If nCont > 0

    aDbf2       := {}
    aCampos     := {}
    aCabs       := {}
    cAliasTrb2  := GetNextAlias()

    Aadd( aDbf2, { "XX_TOTAL"  ,"L",  1,0 } )

    Aadd( aDbf2, { "XX_DESCR"  ,"C", 50,0 } )
    Aadd( aCampos ,cAliasTrb2+"->XX_DESCR")
    Aadd( aCabs   ,"Categorias")

    Aadd( aDbf2, { "XX_TIPOS"  ,"C", 50,0 } ) 


    aSort(aDias,,,{|x,y| x < y })

    For nI := 1 TO Len(aDias)
        Aadd( aDbf2, { "XX_"+STRZERO(nI,3) ,"N", 18,2 } ) 
        Aadd( aCampos ,cAliasTrb2+"->XX_"+STRZERO(nI,3))
        Aadd( aCabs   ,DTOC(STOD(aDias[nI])))
    Next

    oTmpTb2 := FWTemporaryTable():New(cAliasTrb2)
    oTmpTb2:SetFields( aDbf2 )
    oTmpTb2:Create()

    Processa( {|| Prc2BKR29() },"Consolidação")

EndIf



If nCont > 0

    AADD(aPlans,{cAliasTrb2,TRIM(cPerg),"",aTitulos,aCampos,aCabs,/*aImpr*/,aFormula,/*aFormat*/, /*aTotal */, /*cQuebra*/, lClose:= .F. })
    U_GeraXlsx(aPlans,"",cPerg, lClose:= .F.,aParam)
    
Else
    MsgStop("Não foram encontrados registros para esta seleção", cPerg)
EndIf

oTmpTb:Delete()
oTmpTb2:Delete()

//-----------------------
If !Empty( __oTBxCanc )
	__oTBxCanc:Destroy()
	__oTBxCanc := Nil
EndIf
If !Empty( __oTipoBa )
	__oTipoBa:Destroy()
	__oTipoBa := Nil
EndIf
//-------------------------

Return


Static Function BkFR29
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg      ,.T.         ,.T.))
	lRet     := .T.

	dDataI   := mv_par01
	dDataF   := mv_par02

Endif
Return lRet


Static Function PrcE2BK29
Local cQuery 	:= ""
Local cAliasQry := ""

Local nSaldo 	:= 0
Local cTipoBk	:= ""
Local cVencRea  := ""
Local cFilF1	:= ""


cQuery := "SELECT R_E_C_N_O_ AS E2RECNO"+ CRLF
cQuery += " FROM "+RETSQLNAME("SE2")+" SE2" + CRLF
cQuery += " WHERE SE2.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " AND SE2.E2_FILIAL = '" + xFilial("SE2") + "' "+ CRLF
cQuery += " AND SE2.E2_TIPO NOT IN "+FormatIn(MVABATIM,";")+ CRLF
If !Empty(dDataI)
	cQuery += " AND SE2.E2_VENCREA >= '"+DTOS(dDataI)+"'"+ CRLF
EndIf
If !Empty(dDataF)
	cQuery += " AND SE2.E2_VENCREA <= '"+DTOS(dDataF)+"'"+ CRLF
EndIf          
cQuery += " ORDER BY E2_VENCREA"+ CRLF

u_LogMemo("BKFINR29-E2.SQL",cQuery)

cAliasQry := "TMPR29" //GetNextAlias()

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPR29', .F., .T.)
//TCSETFIELD(cAliasQry,"E2_VENCREA","D", 8,0)
TCSETFIELD(cAliasQry,"E2_VALOR"  ,"N",18,2)
	
ProcRegua((cAliasQry)->(LastRec()))

nCont := 0
dbSelectArea("SD1")  // * Itens da N.F. de Compra
dbSetOrder(1)
aPrd   := {}
cFilF1 := xFilial("SF1")

dbSelectArea(cAliasTrb)
dbSetOrder(1)

dbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())
Procregua(LastRec())
Do While (cAliasQry)->(!EOF())
    nCont++
    IncProc("Consultando Contas a Pagar...")

	SE2->(dbGoTo((cAliasQry)->E2RECNO))

	//nSaldo  := -SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,1,,dDataI-1,SE2->E2_LOJA,,0/*nTxMoeda*/)
	nSaldo  := -SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_NATUREZ,"P",SE2->E2_FORNECE,1,,dDataBase-1,SE2->E2_LOJA,,0/*nTxMoeda*/)
    If nSaldo <> 0
        cTipoBk := SE2->E2_XXTIPBK

        If Empty(cTipoBk)
            If TRIM(SE2->E2_NATUREZ) == "IRF"
                cTipoBk := "IIRRF"
            ElseIf TRIM(SE2->E2_NATUREZ) == "INSS"
                cTipoBk := "INSS"
            ElseIf TRIM(SE2->E2_NATUREZ) == "ISS"
                cTipoBk := "ISS"
            ElseIf TRIM(SE2->E2_NATUREZ) $ "PIS/COFINS/CSLL"
                cTipoBk := "PCC"
            EndIf
        EndIf

        If Empty(cTipoBk)

            SE2->(dbGoTo((cAliasQry)->E2RECNO))

            dbSelectArea("SD1")                   // * Itens da N.F. de Compra
            IF dbSeek(xFilial("SD1")+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA)
                // Pega o primeiro produto
                cTipoBk := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_XXGRPF")
            ENDIF

            If Empty(cTipoBk)
                cTipoBk := "FORN"
            EndIf

        EndIf
        cVencRea := DTOS(SE2->E2_VENCREA)
        // Coluna do dia
        If aScan(aDias,cVencRea) = 0
            aAdd(aDias,cVencRea)
        EndIf

        dbSelectArea(cAliasTrb)
        If !dbSeek(cVencRea+cTipoBk)
            Reclock(cAliasTrb,.T.)
            (cAliasTrb)->XX_XXTIPBK := cTipoBk
            (cAliasTrb)->XX_VENCREA := cVencRea


            // Linha do Tipo
            (cAliasTrb)->XX_LINHA := aScan(aPlanTmp,{ |x| PAD(cTipoBk,6)+"/" $ x[3]})

        Else
            Reclock(cAliasTrb,.F.)
        EndIf
        (cAliasTrb)->XX_SALDO   += nSaldo


        (cAliasTrb)->(MsUnLock())
        
    EndIf

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbSkip())
EndDo
Return


// Contas a Receber

Static Function PrcE1BK29
Local cQuery 	:= ""
Local nSaldo 	:= 0
Local cVencRea  := ""
Local nLinCli   := 0
Local cAliasQry := ""

cQuery := "SELECT R_E_C_N_O_ AS E1RECNO"+ CRLF
cQuery += " FROM "+RETSQLNAME("SE1")+" SE1" + CRLF
cQuery += " WHERE SE1.D_E_L_E_T_ = ' ' "+ CRLF
cQuery += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' "+ CRLF
cQuery += " AND SE1.E1_TIPO NOT IN "+FormatIn(MVABATIM,";")+ CRLF
If !Empty(dDataI)
	cQuery += " AND SE1.E1_VENCREA >= '"+DTOS(dDataI)+"'"+ CRLF
EndIf
If !Empty(dDataF)
	cQuery += " AND SE1.E1_VENCREA <= '"+DTOS(dDataF)+"'"+ CRLF
EndIf          
cQuery += " ORDER BY E1_NOMCLI"+ CRLF

u_LogMemo("BKFINR29-E1.SQL",cQuery)

cAliasQry := "TMPE129" //GetNextAlias()

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TMPE129', .F., .T.)
//TCSETFIELD(cAliasQry,"E2_VENCREA","D", 8,0)
TCSETFIELD(cAliasQry,"E1_VALOR"  ,"N",18,2)
	
ProcRegua((cAliasQry)->(LastRec()))
dbSelectArea(cAliasTrb)
dbSetOrder(2)

dbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())
Procregua(LastRec())
Do While (cAliasQry)->(!EOF())
    nCont++
    IncProc("Consultando Contas a Receber...")

	SE1->(dbGoTo((cAliasQry)->E1RECNO))

	nSaldo := U_SaldoSe1(dDataBase-1)

    If nSaldo > 0
        SE1->(dbGoTo((cAliasQry)->E1RECNO))

        cVencRea := DTOS(SE1->E1_VENCREA)

        // Coluna do dia
        If aScan(aDias,cVencRea) = 0
            aAdd(aDias,cVencRea)
        EndIf

        dbSelectArea(cAliasTrb)
        If !dbSeek(cVencRea+SE1->E1_CLIENTE+SE1->E1_LOJA)
            Reclock(cAliasTrb,.T.)
            (cAliasTrb)->XX_CLIENTE := SE1->E1_CLIENTE
            (cAliasTrb)->XX_LOJA    := SE1->E1_LOJA
            (cAliasTrb)->XX_VENCREA := cVencRea


            // Linha do Tipo
            nLinCli := aScan(aPlanTmp,{ |x| SE1->E1_CLIENTE+SE1->E1_LOJA == x[3]})
            If nLinCli == 0
                aAdd(aPlanTmp,{.F.,SE1->E1_CLIENTE+SE1->E1_LOJA+"-"+SE1->E1_NOMCLI,SE1->E1_CLIENTE+SE1->E1_LOJA})
                nLinCli := Len(aPlanTmp)
            EndIf
            (cAliasTrb)->XX_LINHA := nLinCli

        Else
            Reclock(cAliasTrb,.F.)
        EndIf
        (cAliasTrb)->XX_SALDO += nSaldo
    EndIf

	(cAliasTrb)->(MsUnLock())


	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbSkip())
EndDo
Return



Static Function Prc2BKR29
Local nK := 0
Local nL := 0
//Private xCampo


dbSelectArea(cAliasTrb2)
For nK := 1 To Len(aPlanTmp)
    Reclock(cAliasTrb2,.T.)
    (cAliasTrb2)->XX_TOTAL := aPlanTmp[nK,1]
    (cAliasTrb2)->XX_DESCR := aPlanTmp[nK,2]
    (cAliasTrb2)->XX_TIPOS := aPlanTmp[nK,3]
	(cAliasTrb2)->(MsUnLock())
    If (cAliasTrb2)->XX_TOTAL 
        AADD(aFormula,{(cAliasTrb2)->(RECNO()),cAliasTrb2+"->XX_DESCR","","S","",""})
        For nL := 1 To Len(aDias)
            AADD(aFormula,{(cAliasTrb2)->(RECNO()),cAliasTrb2+"->XX_"+STRZERO(nL,3)," ","S","",""})
        Next
    ElseIf Empty((cAliasTrb2)->XX_DESCR)
        For nL := 1 To Len(aDias)
            AADD(aFormula,{(cAliasTrb2)->(RECNO()),cAliasTrb2+"->XX_"+STRZERO(nL,3)," ","C","",""})
        Next
    EndIf
Next


dbSelectArea(cAliasTrb)
dbGoTop()
Do While !Eof()

    If (cAliasTrb)->XX_LINHA > 0

        dbSelectArea(cAliasTrb2)
        dbGoto((cAliasTrb)->XX_LINHA)
        Reclock(cAliasTrb2,.F.)

        nL := aScan(aDias,(cAliasTrb)->XX_VENCREA)
        If nL > 0
            &(cAliasTrb2+"->XX_"+STRZERO(nL,3)) += (cAliasTrb)->XX_SALDO
        EndIf
        (cAliasTrb2)->(MsUnLock())

    EndIf
    dbSelectArea(cAliasTrb)
    dbSkip()
EndDo

Return
