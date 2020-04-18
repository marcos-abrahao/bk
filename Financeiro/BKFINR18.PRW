#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
 
/*/{Protheus.doc} BKFINR12
BK - Relatório de Notas Fiscais Canceladas
@Return
@author Marcos Bispo Abrahão
@since 16/07/15
@version P12
/*/

User Function BKFINR18()

Private cTitulo     := "Notas fiscais canceladas:"
Private cPerg       := "BKFINR18"
Private cCCusto     := ""
Private dDataI      := DATE()
Private dDataF      := DATE()
Private dCancI      := DATE()
Private dCancF      := DATE()
Private dVencI      := DATE()
Private dVencF      := DATE()
Private cAutoriz    := ""

Private aDbf        := {}
Private aPlans      := {}
Private aCampos     := {}
Private aCabs       := {}
Private aTitulos    := {}

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

cCCusto  := mv_par01
dDataI   := mv_par02
dDataF   := mv_par03
dCancI   := mv_par04
dCancF   := mv_par05
dVencI   := mv_par06
dVencF   := mv_par07
cAutoriz := mv_par08

If !EMPTY(cCCusto)
   cTitulo += "  centro de custos "+TRIM(cCCusto)+"-"+TRIM(Posicione("CTT",1, xFilial("CTT")+cCCusto,"CTT_DESC01"))
EndIf

If !EMPTY(dDataI) .OR. !EMPTY(dDataF)
	If dDataI == dDataF
	   cTitulo += "  emissao em "+DTOC(dDataI)
	Else
	   cTitulo += "  emissao entre "+DTOC(dDataI)+" e "+DTOC(dDataF)
	EndIf
EndIf

If !EMPTY(dCancI) .OR. !EMPTY(dCancF)
	If dCancI == dCancF
	   cTitulo += "  canceladas em "+DTOC(dCancI)
	Else
	   cTitulo += "  canceladas entre "+DTOC(dCancI)+" e "+DTOC(dCancF)
	EndIf
EndIf

aDbf    := {}
AADD(aDbf, { 'XX_CONTRAT',	'C', TamSX3("C5_MDCONTR")[1],00 } )
AADD(aCampos,"TRB->XX_CONTRAT")
AADD(aCabs  ,"Contrato")

AADD(aDbf, { 'XX_COMPET',	'C', TamSX3("CND_COMPET")[1],00 } )
AADD(aCampos,"TRB->XX_COMPET")
AADD(aCabs  ,"Competencia")

AADD(aDbf, { 'XX_DOC',		'C', TamSX3("F2_DOC")[1],00 } )
AADD(aCampos,"TRB->XX_DOC")
AADD(aCabs  ,"Documento")

//AADD(aDbf, { 'XX_SERIE',	'C', TamSX3("F2_SERIE")[1],00 } )
//AADD(aCampos,"TRB->XX_SERIE")
//AADD(aCabs  ,"Série")

AADD(aDbf, { 'XX_EMISSAO', 	'D', 08,00 } )
AADD(aCampos,"TRB->XX_EMISSAO")
AADD(aCabs  ,"Emissao")

AADD(aDbf, { 'XX_VENC', 	'D', 08,00 } )
AADD(aCampos,"TRB->XX_VENC")
AADD(aCabs  ,"Vencimento")

//AADD(aDbf, { 'XX_CLIENTE', 	'C', TamSX3("A1_COD")[1],00 } )
//AADD(aCampos,"TRB->XX_CLIENTE")
//AADD(aCabs  ,"Cliente")

//AADD(aDbf, { 'XX_LOJA',   	'C', TamSX3("A1_LOJA")[1],00 } ) 
//AADD(aCampos,"TRB->XX_LOJA")
//AADD(aCabs  ,"Loja")

AADD(aDbf, { 'XX_NOME',	    'C', TamSX3("A1_NOME")[1],00 } ) 
AADD(aCampos,"TRB->XX_NOME")
AADD(aCabs  ,"Nome")

AADD(aDbf, { 'XX_VALFAT' ,	'N', TamSX3("F2_VALFAT")[1],TamSX3("F2_VALFAT")[2] } ) 
AADD(aCampos,"TRB->XX_VALFAT")
AADD(aCabs  ,"Total Bruto")

AADD(aDbf, { 'XX_VALLIQ',	'N', TamSX3("F2_VALFAT")[1],TamSX3("F2_VALFAT")[2] } )  
AADD(aCampos,"TRB->XX_VALLIQ")
AADD(aCabs  ,"Total Liquido")

AADD(aDbf, { 'XX_XXMOTEX',	    'C', TamSX3("F2_XXMOTEX")[1],00 } ) 
AADD(aCampos,"TRB->XX_XXMOTEX")
AADD(aCabs  ,"Motivo cancelamento")

AADD(aDbf, { 'XX_XXAPREX',	    'C', TamSX3("F2_XXAPREX")[1],00 } ) 
AADD(aCampos,"Capital(TRB->XX_XXAPREX)")
AADD(aCabs  ,"Aprovado por")

AADD(aDbf, { 'XX_USERINC',	    'C', TamSX3("F2_XXAPREX")[1],00 } ) 
AADD(aCampos,"Capital(TRB->XX_USERINC)")
AADD(aCabs  ,"Incluida por")

AADD(aDbf, { 'XX_USEREXC',	    'C', TamSX3("F2_XXAPREX")[1],00 } ) 
AADD(aCampos,"Capital(TRB->XX_USEREXC)")
AADD(aCabs  ,"Cancelada por")

AADD(aDbf, { 'XX_DCANC',   		'D', 08,00 } )
AADD(aCampos,"TRB->XX_DCANC")
AADD(aCabs  ,"Cancelamento")

Processa( {|| ProcBKFINR18() })
 
Return


Static Function ProcBKFINR18
Local cQuery := ""
Local nReg   := 0
Local oTmpTb
Local dCanc  := .F.

cQuery := "SELECT"
cQuery += " SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_EMISSAO, SF2.F2_DUPL, SF2.F2_CLIENTE, SF2.F2_LOJA, SA1.A1_NREDUZ, SA1.A1_NOME, "
cQuery += " SF2.F2_VALFAT,SF2.F2_VALIRRF,SF2.F2_VALINSS,SF2.F2_VALPIS,SF2.F2_VALCOFI,SF2.F2_VALCSLL,SF2.F2_RECISS,SF2.F2_VALISS,SF2.F2_XXVCVIN,SF2.F2_XXVFUMD, "
cQuery += " SF2.F2_USERLGI AS F2USERLGI, SF2.F2_XXMOTEX, SF2.F2_XXAPREX, SF2.R_E_C_N_O_ AS F2RECNO"
cQuery += " FROM "+RETSQLNAME("SF2")+" SF2"
cQuery += " INNER JOIN "+RETSQLNAME("SA1")+" SA1 ON  SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SF2.F2_CLIENTE = SA1.A1_COD AND SF2.F2_LOJA = SA1.A1_LOJA AND SA1.D_E_L_E_T_ = ''" 
 
cQuery += " WHERE" 
cQuery += "   SF2.D_E_L_E_T_ <> '' "
If !EMPTY(dDataI)
	cQuery += " AND SF2.F2_EMISSAO >= '"+DTOS(dDataI)+"'"
EndIf
If !EMPTY(dDataF)
	cQuery += " AND SF2.F2_EMISSAO <= '"+DTOS(dDataF)+"' "
EndIf

TCQUERY cQuery NEW ALIAS "QSF2"
TCSETFIELD("QSF2","F2_EMISSAO","D",8,0)

ProcRegua(QSF2->(LASTREC()))

/*
dbSelectArea("SE1")
dbSetOrder(2)

dbSelectArea("QSF2")
QSF2->(dbGoTop())

Do While QSF2->(!EOF())

	dbSelectArea("SE1") 

	nQtdPc := 0
	dbSeek(xFilial("SE1")+QSF2->F2_CLIENTE+QSF2->F2_LOJA+QSF2->F2_SERIE+QSF2->F2_DOC)
	Do While !Eof() .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == ;
 						  xFilial("SE1")+QSF2->F2_CLIENTE+QSF2->F2_LOJA+QSF2->F2_SERIE+QSF2->F2_DOC
        nQtdPc++
		dbSkip()
	EndDo	            

	If nQtdPc > nTotPc
		nTotPc := nQtdPc
	EndIf

	dbSelectArea("QSF2")
	dbSkip()
EndDo


For nQtdPc := 1 To nTotPc

	cCampo := "XX_VAL"+STRZERO(nQtdPc,3)
	AADD(aDbf, { cCampo,'N',18,2 } ) 
	AADD(aCampos,"TRB->"+cCampo)
	AADD(aCabs,"Parcela "+ALLTRIM(STR(nQtdPc,3)))

	cCampo := "XX_VEN"+STRZERO(nQtdPc,3)
	AADD(aDbf, { cCampo,'D', 8,0 } ) 
	AADD(aCampos,"TRB->"+cCampo)
	AADD(aCabs,"Venc. parcela "+ALLTRIM(STR(nQtdPc,3)))

Next
*/

//cArqTmp := CriaTrab( aDbf, .t. )
//dbUseArea( .t.,NIL,cArqTmp,'TRB',.f.,.f. )
//IndRegua("TRB",cArqTmp,"XX_DOC",,,"Indexando Arquivo de Trabalho") 

oTmpTb := FWTemporaryTable():New( "TRB")
oTmpTb:SetFields( aDbf )
oTmpTb:AddIndex("indice1", {"XX_DOC"} )
oTmpTb:Create()

dbSelectArea("QSF2")
QSF2->(dbGoTop())

Do While QSF2->(!EOF())

	ProcQryE1()
    QSE1->(dbGoTop())

	IncProc("Consultando banco de dados...")
    
	lFiltra:= .F.

	SF2->(dbGoTo(QSF2->F2RECNO))
	dCanc  := CTOD(SF2->(FWLeUserlg("F2_USERLGA",2)))

	If !EMPTY(dCancI)
		If dCanc < dCancI
			lFiltra := .T.
		EndIf
	EndIf
	If !EMPTY(dCancF)
		If dCanc > dCancF
			lFiltra := .T.
		EndIf
	EndIf
	If !EMPTY(cCCusto)
		lFiltra := .T.
	    If !(QSE1->(EOF()))
			If ALLTRIM(cCCusto) == ALLTRIM(QSE1->CONTRATO)
				lFiltra := .F.
			EndIf
		EndIf
	EndIf
	
	dbSelectArea("SF2")
	SF2->(dbSetOrder(2))
	IF SF2->(DbSeek(xFilial("SF2")+QSF2->F2_CLIENTE+QSF2->F2_LOJA+QSF2->F2_DOC+QSF2->F2_SERIE,.F.))	
		lFiltra := .T.
	EndIf

	If !lFiltra

		Reclock("TRB",.T.)
		
	    If !(QSE1->(EOF()))
			TRB->XX_CONTRAT := QSE1->CONTRATO
			TRB->XX_COMPET  := QSE1->CND_COMPET
			TRB->XX_VENC    := QSE1->E1_VENCREA
		EndIf
		
		TRB->XX_DOC 	:= QSF2->F2_DOC
		//TRB->XX_SERIE 	:= QSF2->F2_SERIE
		TRB->XX_EMISSAO := QSF2->F2_EMISSAO
		//TRB->XX_CLIENTE := QSF2->F2_CLIENTE
		//TRB->XX_LOJA    := QSF2->F2_LOJA
		TRB->XX_NOME    := QSF2->A1_NOME
		TRB->XX_VALFAT  := QSF2->F2_VALFAT 
		TRB->XX_VALLIQ  := QSF2->(F2_VALFAT - F2_VALIRRF - F2_VALINSS - F2_VALPIS - F2_VALCOFI - F2_VALCSLL - F2_XXVCVIN - F2_XXVFUMD - IIF(F2_RECISS = '1',F2_VALISS,0))
		TRB->XX_XXMOTEX := QSF2->F2_XXMOTEX
		TRB->XX_XXAPREX := QSF2->F2_XXAPREX

		dbSelectArea("SF2")
		SF2->(dbSetOrder(2))
		SET DELETED OFF
		SF2->(DbSeek(xFilial("SF2")+QSF2->F2_CLIENTE+QSF2->F2_LOJA+QSF2->F2_DOC+QSF2->F2_SERIE,.F.))	

		
		TRB->XX_USERINC := SF2->(FWLeUserlg("F2_USERLGI",1))
		TRB->XX_USEREXC := SF2->(FWLeUserlg("F2_USERLGA",1))
		TRB->XX_DCANC   := CTOD(SF2->(FWLeUserlg("F2_USERLGA",2))) 

		SET DELETED ON
		
	
	/*  
		dbSelectArea("SE1") 
	    
		nQtdPc := 0
		dbSeek(xFilial("SE1")+QSF2->F2_CLIENTE+QSF2->F2_LOJA+QSF2->F2_SERIE+QSF2->F2_DOC,.T.)
		Do While !Eof() .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == ;
	 						  xFilial("SE2")+QSF2->F2_CLIENTE+QSF2->F2_LOJA+QSF2->F2_SERIE+QSF2->F2_DOC
			nQtdPc++
	
			cCampo := "XX_VAL"+STRZERO(nQtdPc,3)
			TRB->(&cCampo) := SE1->E1_VALOR
	
			cCampo := "XX_VEN"+STRZERO(nQtdPc,3)
			TRB->(&cCampo) := SE1->E1_VENCTO
	           
			dbSkip()
		EndDo	            
	*/
	
	 	TRB->(Msunlock())
	
	    nReg++
	    
	EndIf

	QSE1->(dbCloseArea())

	    
	dbSelectArea("QSF2")
	QSF2->(dbSkip())

EndDo

AADD(aPlans,{"TRB",cPerg,"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
U_GeraXml(aPlans,cTitulo,cPerg,.F.)

//TRB->(dbCloseArea())
    
dbSelectArea("SE1") 
dbSetOrder(1)

QSF2->(dbCloseArea())

oTmpTb:Delete()
//Ferase(cArqTmp + GetDBExtension())
//FErase(cArqTmp + OrdBagExt())

Return



Static Function ProcQryE1
Local cQuery  := ""

//IncProc("Consultando o banco de dados...")

cQuery := "SELECT DISTINCT E1_VENCREA,E1_VALOR,CND_COMPET,"
cQuery += " E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,"
cQuery += " CASE C5_MDCONTR WHEN '' THEN C5_ESPECI1 ELSE C5_MDCONTR END AS CONTRATO "
cQuery += "FROM "+RETSQLNAME("SE1")+ " SE1 "

//cQuery += "LEFT JOIN "+RETSQLNAME("SF2")+ " SF2 ON SE1.E1_NUM=SF2.F2_DOC AND SE1.E1_PREFIXO=SF2.F2_SERIE "
//cQuery += "AND SE1.E1_CLIENTE=SF2.F2_CLIENTE AND SE1.E1_LOJA=SF2.F2_LOJA AND SF2.D_E_L_E_T_=''"

cQuery += "LEFT JOIN "+RETSQLNAME("SC5")+ " SC5 ON SC5.C5_NUM=SE1.E1_PEDIDO  "
cQuery += "LEFT JOIN "+RETSQLNAME("CND")+ " CND ON SC5.C5_NUM=CND.CND_PEDIDO "

cQuery += "WHERE SE1.D_E_L_E_T_ <> '' "  //AND SE1.E1_VALOR <> SE1.E1_SALDO AND SE1.E1_VALOR = SF2.F2_VALFAT " 

cQuery += " AND E1_NUM     = '"+QSF2->F2_DOC+"'"
cQuery += " AND E1_PREFIXO = '"+QSF2->F2_SERIE+"'"
cQuery += " AND E1_TIPO    = 'NF'"

//cQuery += "ORDER BY E1_VENCREA"

TCQUERY cQuery NEW ALIAS "QSE1"
TCSETFIELD("QSE1","E1_VENCREA","D", 8,0)
TCSETFIELD("QSE1","E1_VALOR"  ,"N",TamSX3("E1_VALOR")[1],TamSX3("E1_VALOR")[2])

//U_QryToXml("QSE1")

Return





Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Centro de Custo:"   ,"" ,"" ,"mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"02","Emissao de:"        ,"" ,"" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Emissão até:"       ,"" ,"" ,"mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"04","Cancelamento de:"   ,"" ,"" ,"mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"05","Cancelamento até:"  ,"" ,"" ,"mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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
