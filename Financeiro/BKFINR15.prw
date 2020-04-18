#include "Protheus.ch"
#include "RwMake.ch"
#include "TopConn.ch"

/*/{Protheus.doc} BKFINR15
BK - Saldos Bco Empresas
@Return
@author Adilson do Prado / Marcos Bispo Abrahão
@since 
@version P12
/*/

User Function BKFINR15()

PRIVATE cNomePrg	:= "BKFINR15"
PRIVATE cPerg		:= cNomePrg
PRIVATE cAliasTmp1  := "TMP1"
PRIVATE aCabs1      := {}
PRIVATE aCampos1    := {}
PRIVATE aImpr1      := {}
PRIVATE aTitulos1   := {}
PRIVATE aStruct1    := {}
PRIVATE aPlans      := {}
PRIVATE lTReport	:= .F.
PRIVATE oTmpTb
PRIVATE cTitulo	    := OemToAnsi("Saldos bancários - todas Empresas")
PRIVATE cFiltro     := ""
PRIVATE dDtSld      := DATE()
PRIVATE aTipoBK     := {"1-Corrente","2-Vinculada","3-Garantida","4-Outra"}         
AjustaSX1(cPerg)

If !Pergunte(cPerg,.T.)
	Return Nil
Endif
dDtSld	:= MV_PAR01
cTitulo += " em "+DTOC(dDtSld)

AADD(aStruct1,{"TIPO","C",20,0})
AADD(aCampos1,cAliasTmp1+"->TIPO")
AADD(aCabs1  ,"Tipo")
AADD(aImpr1  ,.T.)

AADD(aStruct1,{"EMPRESA","C",15,0})
AADD(aCampos1,cAliasTmp1+"->EMPRESA")
AADD(aCabs1  ,"Empresa")
AADD(aImpr1  ,.T.)

AADD(aStruct1,{"BANCO","C",3,0})
AADD(aCampos1,cAliasTmp1+"->BANCO")
AADD(aCabs1  ,"Banco")
AADD(aImpr1  ,.T.)

AADD(aStruct1,{"NOME","C",30,0})
AADD(aCampos1,cAliasTmp1+"->NOME")
AADD(aCabs1  ,"Nome")
AADD(aImpr1  ,.T.)

AADD(aStruct1,{"AGENCIA","C",5,0})
AADD(aCampos1,cAliasTmp1+"->AGENCIA")
AADD(aCabs1  ,"Agencia")
AADD(aImpr1  ,.T.)

AADD(aStruct1,{"CONTA","C",10,0})
AADD(aCampos1,cAliasTmp1+"->CONTA")
AADD(aCabs1  ,"Conta")
AADD(aImpr1  ,.T.)

AADD(aStruct1,{"SALDO","N",15,2})
AADD(aCampos1,cAliasTmp1+"->SALDO")
AADD(aCabs1  ,"Saldo")
AADD(aImpr1  ,.T.)

// Valor das aplicações
AADD(aStruct1,{"EH_VALOR","N",15,2})
AADD(aCampos1,cAliasTmp1+"->EH_VALOR")
AADD(aCabs1  ,"Valor aplicado")
AADD(aImpr1  ,.T.)

// Saldo das aplicações
AADD(aStruct1,{"EH_VALREG","N",15,2})
AADD(aCampos1,cAliasTmp1+"->EH_VALREG")
AADD(aCabs1  ,"Saldo das aplicações")
AADD(aImpr1  ,.T.)
	
// Saldo liquido das aplicações
AADD(aStruct1,{"EH_VALLIQ","N",15,2})
AADD(aCampos1,cAliasTmp1+"->EH_VALLIQ")
AADD(aCabs1  ,"Saldo liquido das aplicações")
AADD(aImpr1  ,.T.)

// IR
	AADD(aStruct1,{"EH_VALIRF","N",GetSx3Cache("EH_VALIRF", "X3_TAMANHO"),GetSx3Cache("EH_VALIRF", "X3_DECIMAL")})
	AADD(aCampos1,cAliasTmp1+"->EH_VALIRF")
	AADD(aCabs1  ,RetTitle("EH_VALIRF"))
AADD(aImpr1  ,.T.)

// IOF
	AADD(aStruct1,{"EH_VALIOF","N",GetSx3Cache("EH_VALIOF", "X3_TAMANHO"),GetSx3Cache("EH_VALIOF", "X3_DECIMAL")})
	AADD(aCampos1,cAliasTmp1+"->EH_VALIOF")
	AADD(aCabs1  ,RetTitle("EH_VALIOF"))
AADD(aImpr1  ,.T.)


///cArqTmp1 := CriaTrab(aStruct1)
///dbUseArea(.T.,,cArqTmp1,cAliasTmp1,if(.F. .OR. .F.,!.F., NIL),.F.)
///IndRegua (cAliasTmp1,cArqTmp1,"TIPO+EMPRESA+BANCO+AGENCIA+CONTA",,,OemToAnsi("Selecionando Registros...") )  //
///dbSetOrder(1)

oTmpTb := FWTemporaryTable():New(cAliasTmp1)
oTmpTb:SetFields( aStruct1 )
oTmpTb:AddIndex("indice1", {"TIPO","EMPRESA","BANCO","AGENCIA","CONTA"} )
oTmpTb:Create()

AADD(aTitulos1,cNomePrg+"/"+TRIM(SUBSTR(cUsuario,7,15))+" - "+cTitulo+" em "+DTOC(dDtSld))

ProcRegua(SM0->(LASTREC()))
Processa( {|| BKFin15Emp()})

cFiltro := "" //cAliasTmp1+"->TIPO >= '1'"                                 

AADD(aPlans,{cAliasTmp1,cNomePrg,cFiltro,cTitulo,aCampos1,aCabs1,aImpr1, /* aAlign */,/* aFormat */, /*aTotal */, cAliasTmp1+"->TIPO", lClose:= .F. })
   
U_GeraXml(aPlans,cTitulo,cNomePrg,.F.)

oTmpTb:Delete()
//Ferase(cArqTmp1 + GetDBExtension())

Return (Nil)


Static Function BKFin15Emp()
Local cQry1     := ""
Local aSM0Area	:= SM0->(GetArea())

SM0->(DbGoTop())
While SM0->(!EoF())

    IncProc()
    
	IF lEnd
		Exit
	End

	If SM0->M0_CODIGO == "99" //.OR. SM0->M0_CODIGO $ getmv("MV_XNSLDS") 
		SM0->(DbSKip())
		Loop
	EndIf

	///cArquivo1 := "SX2"+SM0->M0_CODIGO+"0"+GetDBExtension()
	//If Select("SX2DBF") > 0
	///	SX2DBF->(DbCloseArea())
	///EndIf
		
	///dbUseArea(.T.,NIL,cArquivo1,"SX2DBF",.T.,.F.)
	///IndRegua("SX2DBF","SX2DBF_A", "X2_CHAVE",,, 	"Criando Indice..." )

	///dbSelectArea("SX2DBF")
	///SX2DBF->(DbSeek("SA6"))

	cQry1 := "SELECT * FROM SA6"+SM0->M0_CODIGO+"0 XSA6"  //SA6"+SM0->M0_CODIGO+"0 SA6"		
	cQry1 += " WHERE XSA6.D_E_L_E_T_ = ' ' AND XSA6.A6_BLOCKED <> '1' "
	cQry1 += " ORDER BY A6_COD,A6_AGENCIA,A6_NUMCON"
	//cQry1 += " AND SA6.A6_FLUXCAI = 'S' ORDER BY A6_COD"
		
	If Select("XSA6") > 0
		XSA6->(DbCloseArea())
	EndIf
	
	TcQuery cQry1 New Alias "XSA6"

	KFin15Sld()				   
				
	//If Select("SX2DBF") > 0
	//	SX2DBF->(DbCloseArea())
	//	FErase("SX2DBF_A"+OrdBagExt())
	//EndIf

	If Select("XSA6") > 0
		XSA6->(DbCloseArea())
	EndIf
	
	SM0->(DbSkip())
EndDo

RestArea(aSM0Area)

Return Nil





/*/
Busca os saldos bancarios
*/
Static Function KFin15Sld()
Local cQry2   := ""
Local cTipo   := ""
Local nTipoBK := 0 
Local aAplSld := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procura pelo 1.o banco no SA6	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "XSA6" )
dbGotop()

While ! Eof()
	
	//IF nCaixinha <> 1
	//	If ALLTRIM(SA6->A6_COD) $ "CBX/CX1/DRS"
	//		SA6->(dbSkip())
	//		Loop
	//	EndIf
	//ENDIF

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se n„o considerar banco para o Fluxo de Caixa              	 	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//If XSA6->A6_FLUXCAI == "N"
	//	dbSkip()
	//	Loop
	//EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura pelo saldo anterior dos bancos no SE8 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//dbSelectArea("SX2DBF")
	//SX2DBF->(DbSeek("SE8"))

	cQry2 := "SELECT TOP 1 * FROM SE8"+SM0->M0_CODIGO+"0 SE8" //RetSqlName("SE8")+" SE8"
	cQry2 += " WHERE SE8.D_E_L_E_T_ <> '*'"
	cQry2 += " AND SE8.E8_BANCO = '"+XSA6->A6_COD+"'"
	cQry2 += " AND SE8.E8_AGENCIA = '"+XSA6->A6_AGENCIA+"'"
	cQry2 += " AND SE8.E8_CONTA = '"+XSA6->A6_NUMCON+"'"
	cQry2 += " AND SE8.E8_DTSALAT <= '"+DtoS(dDtSld)+"'"// AND '"+DtoS(MV_PAR02)+"'"
    cQry2 += " ORDER BY E8_DTSALAT DESC"
   //	cQry += " ORDER BY E8_BANCO, E8_DTSALAT"
				
	If Select("XSE8") > 0
		XSE8->(DbCloseArea())
	EndIf
	
	TcQuery cQry2 New Alias "XSE8" 
	TCSETFIELD("XSE8","E8_DTSALAT","D",8,0)
    
	cTipo := "TIPO"
	
	dbSelectArea("XSE8")
    dbGoTop()
	//If !EOF()
		dbSelectArea(cAliasTmp1)
		If !dbSeek(PAD(cTipo,20)+PAD(SM0->M0_NOME,15)+XSE8->E8_BANCO+XSE8->E8_AGENCIA+XSE8->E8_CONTA)
			RecLock( cAliasTmp1, .T. )
		    nTipoBK := VAL(XSA6->A6_XXTIPBK)
		    IF nTipoBK = 0 .OR. nTipoBK > LEN(aTipoBK)
		    	nTipoBK := LEN(aTipoBK)
		    ENDIF
			(cAliasTmp1)->TIPO       := aTipoBK[nTipoBK]
			(cAliasTmp1)->EMPRESA    := SM0->M0_NOME 	
			(cAliasTmp1)->BANCO      := XSA6->A6_COD 	
			(cAliasTmp1)->NOME       := XSA6->A6_NOME	
			(cAliasTmp1)->AGENCIA    := XSE8->E8_AGENCIA	
			(cAliasTmp1)->CONTA      := XSE8->E8_CONTA	
		Else 
			RecLock( cAliasTmp1, .F. )
		EndIf
		//(cAliasTmp1)->SALDO   := xMoeda(XSE8->E8_SALATUA,nMoedaBco,nMoeda,SE8->E8_DTSALAT,nDecs+1)
		(cAliasTmp1)->SALDO   += XSE8->E8_SALATUA

        aAplSld := SldApl(dDtSld,XSA6->A6_COD,XSA6->A6_AGENCIA,XSA6->A6_NUMCON)

		(cAliasTmp1)->EH_VALOR    += aAplSld[1]
		(cAliasTmp1)->EH_VALREG   += aAplSld[2]
		(cAliasTmp1)->EH_VALLIQ   += (aAplSld[2] - aAplSld[3] - aAplSld[4])
		(cAliasTmp1)->EH_VALIRF   += aAplSld[3]
		(cAliasTmp1)->EH_VALIOF   += aAplSld[4]

		msUnlock()
    //EndIf
	dbSelectArea("XSA6")
	dbSkip()
EndDo

If Select("XSE8") > 0
	XSE8->(DbCloseArea())
EndIf


Return Nil




Static Function SldApl(_dDtProc,_cBanco,_cAgencia,_cConta)

// Calculo das aplicações
Local nValApl    := 0
Local nVlrAplAtu := 0
Local nSaldoApl  := 0
Local nTotAplAtu := 0
Local nTotSaldo  := 0
Local nTotIr     := 0
Local nTotIof    := 0
Local nValBP     := 0				
Local nValJR     := 0				
Local nValRG     := 0				
Local nValI1     := 0				
Local nValI2     := 0				
Local nValVL     := 0				
Local cAplCotas  := GetMv("MV_APLCAL4")
			
dbSelectArea("SEH")
dbGoTop()
Do While !eof()

	If SEH->EH_BANCO == _cBanco .AND. SEH->EH_AGENCIA == _cAgencia .AND. SEH->EH_CONTA == _cConta

		If !SEH->EH_TIPO $ cAplCotas .AND. SEH->EH_APLEMP == "APL" .AND. SEH->EH_DATA <= _dDtProc

			//-- Calcular saldo pela movimentação, incluido em 05/05/15
			nValApl := SEH->EH_VALOR
			nValBP  := 0				
			nValJR  := 0				
			nValRG  := 0				
			nValI1  := 0				
			nValI2  := 0				
			nValVL  := 0				
			dbSelectArea("SEI")
			dbSetOrder(2)
	
			dbSeek(xFilial("SEI")+SEH->EH_APLEMP+SEH->EH_NUMERO+SEH->EH_REVISAO,.T.)
			Do While xFilial("SEI")+SEH->EH_APLEMP+SEH->EH_NUMERO+SEH->EH_REVISAO == xFilial("SEI")+SEI->EI_APLEMP+SEI->EI_NUMERO+SEI->EI_REVISAO .AND. !EOF()
		        If SEI->EI_VALOR > 0 .AND. SEI->EI_STATUS <> "C" .AND. SEI->EI_DATA <= _dDtProc
			        If SEI->EI_TIPODOC = "BP"
						nValBP += SEI->EI_VALOR
			        ElseIf SEI->EI_TIPODOC = "JR"
						nValJR += SEI->EI_VALOR
			        ElseIf SEI->EI_TIPODOC = "RG"
						nValRG += SEI->EI_VALOR
			        ElseIf SEI->EI_TIPODOC = "I1"
						nValI1 += SEI->EI_VALOR
			        ElseIf SEI->EI_TIPODOC = "I2"
						nValI2 += SEI->EI_VALOR
			        ElseIf SEI->EI_TIPODOC = "VL"
						nValVL += SEI->EI_VALOR
					EndIf
				EndIf
				dbSkip()	
			EndDo
	
			nSaldoApl  := SEH->EH_VALOR - nValBP
			If ABS(nSaldoApl - SEH->EH_SALDO) <= 0.05
			   nSaldoApl := SEH->EH_SALDO
			EndIf
						
		    //--
			dbSelectArea("SEI")
			dbSetOrder(1)
					    
			//aCalculo	:= Fa171Calc(_dDtProc,SEH->EH_SALDO,lResgate,,,,,,,,,.T.)     
						
			//If nVlrAplAtu > 0.02
			If nSaldoApl > 0
						
				aCalculo	:= Fa171Calc(_dDtProc,nSaldoApl,.F.,,_dDtProc)
				nIrfAplAtu  := xMoeda(aCalculo[2],1,1)
				nIofAplAtu  := xMoeda(aCalculo[3],1,1)
				nJurAplAtu  := xMoeda(aCalculo[5],1,1)
				nVlrAplAtu  := xMoeda(aCalculo[1],1,1) //- xMoeda(aCalculo[5],1,1) //- xMoeda(nVlrImp1,1,1)	
	            
				/*
				RecLock(cAliasTmp6,.T.)
				(cAliasTmp6)->EH_BANCO  	:= SA6->A6_COD
				(cAliasTmp6)->EH_AGENCIA 	:= SA6->A6_AGENCIA
				(cAliasTmp6)->EH_CONTA  	:= SA6->A6_NUMCON
				(cAliasTmp6)->EH_DATA   	:= SEH->EH_DATA
				(cAliasTmp6)->EH_VALOR  	:= SEH->EH_VALOR
				(cAliasTmp6)->EH_VALIRF    := nIrfAplAtu   //xMoeda(aCalculo[2],1,1)
				(cAliasTmp6)->EH_VALJUR    := nJurAplAtu   //xMoeda(aCalculo[5],1,1)
				(cAliasTmp6)->EH_SALDO     := nSaldoApl
				(cAliasTmp6)->EH_VALCOR    := nVlrAplAtu   //xMoeda(aCalculo[1],1,1) - xMoeda(aCalculo[5],1,1) //- xMoeda(nVlrImp1,1,1)
				(cAliasTmp6)->EH_VALLIQ    := nVlrAplAtu - nIrfAplAtu
				(cAliasTmp6)->EH_NUMERO    := SEH->EH_NUMERO
				(cAliasTmp6)->EH_TAXA      := SEH->EH_TAXA  
				(cAliasTmp6)->EH_CALC1     := aCalculo[1]
				MsUnlock()
                */
                
				nTotAplAtu += nVlrAplAtu
				nTotSaldo  += nSaldoApl
				nTotIr     += nIrfAplAtu
				nTotIof    += nIofAplAtu
	
			EndIf	
		EndIf
	EndIf	
	dbSelectArea("SEH")
	dbSkip()
EndDo		

Return {nTotSaldo,nTotAplAtu,nTotIr,nTotIof}






Static Function AjustaSX1(cPerg)

Local aArea := GetArea()
Local aRegs := {}

aAdd( aRegs , { PAD(cPerg,10) , "01" , "Data do Saldo?"  , "            " , "            " , "MV_CH1" , "D" , 08 , 0 , 0 , "G" , "" , "MV_PAR01" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , ""})

DbSelectArea("SX1")
DbSetOrder(1)

For i := 1 to Len( aRegs )
   If !SX1->(dbSeek(PAD(cPerg,10)+aRegs[i,2]))
      RecLock("SX1",.T.)
	  For j:=1 to FCount()
	     If j <= Len(aRegs[i])
		    FieldPut(j,aRegs[i,j])
		 Endif
	  Next
	  SX1->(MsUnlock())
   Endif
Next  

RestArea(aArea)

Return