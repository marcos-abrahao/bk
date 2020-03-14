#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MT110TEL บAutor  ณAdilson do Prado    บ Data ณ  29/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็๕es da Solicita็ใo de Compras responsแveis pela        บฑฑ
ฑฑบ          ณ manipular o cabe็alho da Solicita็ใo de Compras permitindo บฑฑ
ฑฑบ          ณ a inclusใo e altera็ใo de campos.       					  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ BK                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

USER FUNCTION MT110TEL
Local oNewDialog := PARAMIXB[1]
Local aPosGet    := PARAMIXB[2]
Local nOpcx      := PARAMIXB[3]
//Local nReg       := PARAMIXB[4]
Local aMTCM		 := {}
Local nPQEST	 := 0
Local nLin       := 0
Public dDATPRF 	 := CTOD("")
Public cXXMTCM 	 := Space(TamSX3("C1_XXMTCM")[1])    
Public cCC		 := Space(TamSX3("C1_CC")[1])    
Public cXXDCC	 := Space(TamSX3("C1_XXDCC")[1])
Public cXXJUST	 := Space(TamSX3("C1_XXJUST")[1]) 
Public cXXENDEN  := Space(TamSX3("C1_XXENDEN")[1])


IF TYPE("lCopia") == "U"
	lCopia  := .F.
ENDIF

aMTCM := U_StringToArray(GetSx3Cache("C1_XXMTCM", "X3_CBOX"),";") 

//aadd(aPosGet[1],0) 
//aadd(aPosGet[1],0)

IF nOpcx <> 3
	dDATPRF	 := SC1->C1_DATPRF
	cXXMTCM  := SC1->C1_XXMTCM    
	cCC		 := SC1->C1_CC    
	cXXDCC	 := SC1->C1_XXDCC
	cXXJUST  := SC1->C1_XXJUST
	cXXENDEN := SC1->C1_XXENDEN
ENDIF 

// Nใo copiar data prevista de entrega - 04/02/16   
IF lCopia
	dDATPRF	 := CTOD("")
	nPQEST   := aScan(aHeader, {|x| AllTrim(x[2]) == "C1_XXQEST"})
	FOR _IX:= 1 TO LEN(aCols)
		aCols[_IX][nPQEST] := 0
	NEXT
ENDIF

If TYPE("CRELEASERPO") == "U"
	nLin := 33	// Protheus 11
Else
	nLin := 63	// Protheus 12
EndIf

@ nLin,aPosGet[1,1] SAY 'Limite Entrega' PIXEL SIZE 50,10 Of oNewDialog
@ nLin,aPosGet[1,2] MSGET dDATPRF PIXEL SIZE 50,10 Of oNewDialog    

@ nLin,aPosGet[1,3] SAY 'Endere็o Entrega' PIXEL SIZE 50,10 Of oNewDialog
@ nLin,aPosGet[1,4] MSGET cXXENDEN PIXEL SIZE 130,10 Of oNewDialog    

nLin += 15

@ nLin,aPosGet[1,1]  SAY 'Motivo da Compra' PIXEL SIZE 50,10 Of oNewDialog
@ nLin,aPosGet[1,2]  COMBOBOX cXXMTCM  ITEMS aMTCM SIZE 100,010 Pixel Of oNewDialog  VALID(Pertence("123"))

@ nLin,aPosGet[1,3]  SAY 'Centro Custo' PIXEL SIZE 50,10 Of oNewDialog
@ nLin,aPosGet[1,4]  MSGET cCC PIXEL SIZE 50,10 Of oNewDialog  F3 "CTT" VALID(Vazio(cCC) .Or. Ctb105CC(),cXXDCC:= CTT->CTT_DESC01)  

@ nLin,aPosGet[1,5]  SAY 'Descr C. Custo' PIXEL SIZE 50,10 Of oNewDialog
@ nLin,aPosGet[1,6]  MSGET cXXDCC PIXEL SIZE 100,10 Of oNewDialog WHEN .F.  

nLin += 15

@ nLin,aPosGet[1,1] SAY 'Justificativa' PIXEL SIZE 50,10 Of oNewDialog
oMemo:= tMultiget():New(nLin,aPosGet[1,2],{|u|if(Pcount()>0,cXXJUST:=u,cXXJUST)},oNewDialog,250,20,,,,,,.T.) 
            

RETURN

 
//Manipula as dimens๕es do cabe็alho da S.C
User Function MT110GET() 
Local aRet:= PARAMIXB[1] 

If TYPE("CRELEASERPO") == "U"  // Protheus 11
	aRet[2,1] := 85
	aRet[1,3] := 115 
Else   // Protheus 12
	aRet[2,1] := 115
	aRet[1,3] := 145 
EndIf

Return(aRet)



//Grava o campo do cabe็alho da S.C
User Function MT110GRV(cObserv) 
RecLock('SC1',.F.) 
SC1->C1_XXJUST  := cXXJUST
SC1->C1_XXENDEN := cXXENDEN
SC1->(MsUnlock()) 
Return 
 

