#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
 
/*/{Protheus.doc} BKCOMF09
BK - Criar inclusão de Produtos específicos 
Gerar Proximo numero produtos
@Return
@author Adilson do Prado
@since 03/02/15
@version P12
/*/

User Function BKCOMF09()

Local cQuery := ""
Local nReg 	 := 0 
Local cSubPdt:= ""
Local cCod	 := ""
Local nCod	 := 0
Local cPerg  := "BKCOMF09" 
Local aGrpBK := u_BKGrupo()
Local nI 	 := 0

If l010Auto
	cCod := ""
	Return cCod 
ENDIF

//If !MsgYesNo("Gerar Proximo numero?",cPerg)
If !u_MsgLog(cPerg,"Gerar proximo código de produto?","Y")
	cCod := ""
	Return cCod 
EndIf

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	cCod := ""
	Return cCod
Endif
 
cSubPdt  	:= ALLTRIM(mv_par01)

IF EMPTY(cSubPdt)
	u_MsgLog(cPerg,"O Grupo de Produto dever ser selecionado!!","W")
	cCod := ""
	Return cCod 
EndIf

nReg := 0

For nI := 1 To Len(aGrpBK)

	//cQuery := " SELECT TOP 1 SUBSTRING(B1_COD,4,LEN(B1_COD)) AS B1_COD1 from SB1"+TRIM(SM0->M0_CODIGO)+"0 WHERE D_E_L_E_T_='' AND SUBSTRING(B1_COD,1,3)='"+cSubPdt+"' " 
	//cQuery += " ORDER BY CAST(SUBSTRING(B1_COD,4,LEN(B1_COD)) AS INT) DESC "
	//TCQUERY cQuery NEW ALIAS "QSB1"


	cQuery := " SELECT TOP 1 SUBSTRING(B1_COD,4,6) AS B1_COD1 from SB1"+aGrp[nI,1]+"0 WHERE D_E_L_E_T_='' AND SUBSTRING(B1_COD,1,3)='"+cSubPdt+"' "  
	cQuery += " 	AND SUBSTRING(B1_COD,11,1) = ' ' "   // para não estourar a quantidade de casas do INT
	cQuery += " ORDER BY CAST(SUBSTRING(B1_COD,4,6) AS INT) DESC "
	TCQUERY cQuery NEW ALIAS "QSB1"


	dbSelectArea("QSB1")	
	QSB1->(dbGoTop()) 
	
	IF VAL(QSB1->B1_COD1) > nCod
		nCod := VAL(QSB1->B1_COD1)
	ENDIF
	
	QSB1->(Dbclosearea())
Next

nCod++
cCod := cSubPdt+STRZERO(nCod,IIF(nCod>999,4,3))

u_MsgLog("BKCOMF09",cCod)

Return cCod


Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Grupo Produtos de:","Grupo Produtos de:","Grupo Produtos de:","mv_ch1","C",04,0,0,"C","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SBM2","S","",""})

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


