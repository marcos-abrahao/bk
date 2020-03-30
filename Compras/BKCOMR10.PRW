#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} BKCOMR10
BK - Relatório Financeiro de NF de entrada

@Return
@author Marcos Bispo Abrahão
@since 26/02/15
@version P12
/*/

User Function BKCOMR10()

Private cTitulo     := "Relatório Financeiro de NFs de Entrada"
Private cPerg       := "BKCOMR10"

PRIVATE dDataI  	:= DATE()
PRIVATE dDataF  	:= DATE()

PRIVATE aDbf        := {}

PRIVATE aPlans      := {}
PRIVATE aCampos     := {}
PRIVATE aCabs       := {}
PRIVATE aTitulos    := {}


ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif


dDataI := mv_par01
dDataF := mv_par02

If dDataI == dDataF
   cTitulo += " em "+DTOC(dDataI)
Else
   cTitulo += " de "+DTOC(dDataI)+" até "+DTOC(dDataF)
EndIf

aDbf    := {}
AADD(aDbf, { 'XX_DOC',		'C', 09,00 } )
AADD(aCampos,"TRB->XX_DOC")
AADD(aCabs  ,"Documento")

AADD(aDbf, { 'XX_SERIE',	'C', 03,00 } )
AADD(aCampos,"TRB->XX_SERIE")
AADD(aCabs  ,"Série")

AADD(aDbf, { 'XX_DTDIGIT', 	'D', 08,00 } )
AADD(aCampos,"TRB->XX_DTDIGIT")
AADD(aCabs  ,"Data de Entrada")

AADD(aDbf, { 'XX_FORNEC', 	'C', 06,00 } )
AADD(aCampos,"TRB->XX_FORNEC")
AADD(aCabs  ,"Fornecedor")

AADD(aDbf, { 'XX_LOJA',   	'C', 02,00 } ) 
AADD(aCampos,"TRB->XX_LOJA")
AADD(aCabs  ,"Loja")

AADD(aDbf, { 'XX_NOME',	'C', 80,00 } ) 
AADD(aCampos,"TRB->XX_NOME")
AADD(aCabs  ,"Nome")

AADD(aDbf, { 'XX_VALBRUT',	'N', 18,02 } ) 
AADD(aCampos,"TRB->XX_VALBRUT")
AADD(aCabs  ,"Total Bruto")

AADD(aDbf, { 'XX_VALLIQ',	'N', 18,02 } ) 
AADD(aCampos,"TRB->XX_VALLIQ")
AADD(aCabs  ,"Total Liquido")

Processa( {|| ProcBKCOMR10() })
 
Return


Static Function ProcBKCOMR10
Local cQuery := ""
Local nReg   := 0
Local nQtdPc := 0
Local nTotPc := 0
Local cCampo := ""
Local oTmpTb

Local cAlmox := GrpAlmox()

cQuery := "SELECT"
cQuery += " SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_DTDIGIT, SF1.F1_DUPL, SF1.F1_FORNECE, SF1.F1_LOJA , SF1.F1_VALBRUT, SA2.A2_NREDUZ, SA2.A2_NOME, "
cQuery += " SF1.F1_VALIRF, SF1.F1_ISS, SF1.F1_INSS, SF1.F1_VALPIS, SF1.F1_VALCOFI, SF1.F1_VALCSLL, SF1.F1_XXUSER "
cQuery += " FROM "+RETSQLNAME("SF1")+" SF1"
cQuery += " INNER JOIN "+RETSQLNAME("SA2")+" SA2 ON  SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SF1.F1_FORNECE = SA2.A2_COD AND SF1.F1_LOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_ = ''" 
 
cQuery += " WHERE SF1.D_E_L_E_T_ = '' AND SF1.F1_DTDIGIT >= '"+DTOS(dDataI)+"' AND SF1.F1_DTDIGIT <= '"+DTOS(dDataF)+"' "
If !EMPTY(cAlmox)
   cQuery += " AND SF1.F1_XXUSER IN ("+cAlmox+")"
EndIf

TCQUERY cQuery NEW ALIAS "QSF1"
TCSETFIELD("QSF1","F1_DTDIGIT","D",8,0)

ProcRegua(QSF1->(LASTREC()))

dbSelectArea("SE2")
dbSetOrder(6)

dbSelectArea("QSF1")
QSF1->(dbGoTop())

Do While QSF1->(!EOF())

	dbSelectArea("SE2") 

	nQtdPc := 0
	dbSeek(xFilial("SE2")+QSF1->F1_FORNECE+QSF1->F1_LOJA+QSF1->F1_SERIE+QSF1->F1_DOC)
	Do While !Eof() .And. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == ;
 						  xFilial("SE2")+QSF1->F1_FORNECE+QSF1->F1_LOJA+QSF1->F1_SERIE+QSF1->F1_DOC
        nQtdPc++
		dbSkip()
	EndDo	            

	If nQtdPc > nTotPc
		nTotPc := nQtdPc
	EndIf

	dbSelectArea("QSF1")
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


///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,'TRB',.f.,.f. )
///IndRegua("TRB",cArqTmp,"DTOS(XX_DTDIGIT)+XX_FORNEC+XX_LOJA",,,"Indexando Arquivo de Trabalho") 

oTmpTb := FWTemporaryTable():New( "TRB")
oTmpTb:SetFields( aDbf )
oTmpTb:AddIndex("indice1", {"XX_DTDIGIT","XX_FORNEC","XX_LOJA"} )
oTmpTb:Create()


dbSelectArea("QSF1")
QSF1->(dbGoTop())

Do While QSF1->(!EOF())

	IncProc("Consultando banco de dados...")

	Reclock("TRB",.T.)
	TRB->XX_DOC 	:= QSF1->F1_DOC
	TRB->XX_SERIE 	:= QSF1->F1_SERIE
	TRB->XX_DTDIGIT := QSF1->F1_DTDIGIT
	TRB->XX_FORNEC  := QSF1->F1_FORNECE
	TRB->XX_LOJA    := QSF1->F1_LOJA
	TRB->XX_NOME    := QSF1->A2_NOME
	TRB->XX_VALBRUT := QSF1->F1_VALBRUT
	TRB->XX_VALLIQ  := QSF1->F1_VALBRUT - QSF1->F1_VALIRF - QSF1->F1_ISS - QSF1->F1_INSS - QSF1->F1_VALPIS - QSF1->F1_VALCOFI - QSF1->F1_VALCSLL

	dbSelectArea("SE2") 

	// Prefixo do SF1	
	//cPref := &("Q"+GetMV("MV_2DUPREF"))
	//cPref += Space(Len(SE2->E2_PREFIXO) - Len(cPref))

	nQtdPc := 0
	dbSeek(xFilial("SE2")+QSF1->F1_FORNECE+QSF1->F1_LOJA+QSF1->F1_SERIE+QSF1->F1_DOC)
	Do While !Eof() .And. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == ;
 						  xFilial("SE2")+QSF1->F1_FORNECE+QSF1->F1_LOJA+QSF1->F1_SERIE+QSF1->F1_DOC
		nQtdPc++

		cCampo := "XX_VAL"+STRZERO(nQtdPc,3)
		TRB->(&cCampo) := SE2->E2_VALOR

		cCampo := "XX_VEN"+STRZERO(nQtdPc,3)
		TRB->(&cCampo) := SE2->E2_VENCTO
           
		dbSkip()
	EndDo	            

 	TRB->(Msunlock())

    nReg++
	dbSelectArea("QSF1")
	QSF1->(dbSkip())

ENDDO

AADD(aPlans,{"TRB",cPerg,"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */,/*aTotal */, /*cQuebra*/, lClose:= .F. })
MsAguarde({|| U_GeraXml(aPlans,cTitulo,cPerg,.F.)},"Aguarde","Gerando planilha...",.F.)


QSF1->(dbCloseArea())

oTmpTb:Delete()
///Ferase(cArqTmp + GetDBExtension())
///FErase(cArqTmp + OrdBagExt())

Return



// Retorna membros do grupo almoxarifado

Static Function GrpAlmox()

Local nX_,i,lAlmox
Local cGrupAlmox   := SuperGetMV("MV_XXGRALX",.F.,"000021")
Local aUsers       := {}
Local aGrupo       := {}
Local cAlmox       := ""

aUsers:=AllUsers()

cAlmox := ""
cVirg  := ""
For nX_ := 1 to Len(aUsers)
	If Len(aUsers[nX_][1][10]) > 0 
		aGrupo := {}
		//AADD(aGRUPO,aUsers[nX_][1][10])
		//For i:=1 To LEN(aGRUPO[1])
		//	lAlmox := (aGRUPO[1,i] $ cGrupAlmox)
		//Next
		//Ajuste nova rotina a antiga não funciona na nova lib MDI
		aGRUPO := UsrRetGrp(aUsers[nX_][1][2])
		IF LEN(aGRUPO) > 0
			FOR i:=1 TO LEN(aGRUPO)
				lAlmox := (ALLTRIM(aGRUPO[i]) $ cGrupAlmox )
			NEXT
		ENDIF	
    	If lAlmox
    		cAlmox += cVirg+"'"+ALLTRIM(aUsers[nX_][1][1])+"'"
    		cVirg  := ","
    	EndIf
 	EndIf
Next

If !(__cUserId $ cAlmox)
	cAlmox := ""
EndIf

Return cAlmox









Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Data Digitação de :"  ,"Data Digitação de :" ,"Data Digitação de :" ,"mv_ch1","D",08,0,0,"G","NaoVazio()","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Data Digitação até:"  ,"Data Digitação até:" ,"Data Digitação até:" ,"mv_ch2","D",08,0,0,"G","NaoVazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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
