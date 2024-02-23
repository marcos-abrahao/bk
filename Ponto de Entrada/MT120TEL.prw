#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} SF1140I
BK - Ponto de entrada: Funções do Pedido de Compras responsáveis para
     manipular o cabeçalho do Pedido de Compras permitindo
     inclusão e alteração de campos
@Return
@author Adilson do Prado / Marcos Bispo Abrahão
@since 26/01/17 
@version P12

ExecBlock("MT120TEL",.F.,.F.,{@oDlg, aPosGet, aObj, nOpcx, nReg} )

/*/

User Function MT120TEL
Local oNewDialog := PARAMIXB[1]
Local aPosGet    := PARAMIXB[2]  
//Local aNewObj    := PARAMIXB[3]
Local nOpcx      := PARAMIXB[4]
//Local nReg       := PARAMIXB[5]
Local nLin       := 0

Public aSIM   := {}
Public cSim   := "Não"

AADD(aSIM,"Sim")
AADD(aSIM,"Não")

Public cXXOBS   := Space(TamSX3("C7_XXOBS")[1])
Public cXXURGEN := Space(TamSX3("C7_XXURGEN")[1])

IF nOpcx <> 3
    cXXOBS   := SC7->C7_XXOBS
    cXXURGEN := SC7->C7_XXURGEN
    IF cXXURGEN == "S"
    	cSim := "Sim"
    ELSE
    	cSim := "Não"
    ENDIF
ENDIF 

//If TYPE("CRELEASERPO") == "U"
//	nLin := 45	// Protheus 11
//Else
	nLin := 75	// Protheus 12
//EndIf

@ nLin,aPosGet[1,1] SAY 'Pedido urgente?' PIXEL SIZE 50,10 Of oNewDialog
@ nLin,aPosGet[1,2] COMBOBOX cSim ITEMS aSIM SIZE 100,50  PIXEL SIZE 130,10 Of oNewDialog    

@ nLin,aPosGet[1,3] SAY 'Observação' PIXEL SIZE 50,10 Of oNewDialog
oMemo:= tMultiget():New(nLin,aPosGet[1,4],{|u|if(Pcount()>0,cXXOBS:=u,cXXOBS)},oNewDialog,250,20,,,,,,.T.) 

RETURN

 
//Manipula as dimensões do cabeçalho d0 pedido
User Function MT120GET() 
Local aRet:= PARAMIXB[1] 

//If TYPE("CRELEASERPO") == "U"  // P11
//	aRet[2,1] := 90
//	aRet[1,3] := 120 
//Else   // P12
	aRet[2,1] := 120
	aRet[1,3] := 150 
//EndIf

Return(aRet)


// MTA120G2 Grava em todos os itens
User Function MTA120G2()
     
If cSim == "Sim"
	cXXURGEN := "S"
Else
	cXXURGEN := "N"
EndIf
SC7->C7_XXOBS   := cXXOBS
SC7->C7_XXURGEN := cXXURGEN 
     
Return


User Function MT120BRW()

aAdd( aRotina, { "Pedido Urgente?",   "U_BKALTSC7", 4, 0, 4 } )
aAdd( aRotina, { "Pedidos em Aberto", "U_BKCOMR16", 4, 0, 4 } )
aadd(aRotina,  { "Altera Fornecedor", "U_BKALTFOR", 0, 2, 4} )

Return Nil



// Alterar fornecedor de Pedido de Compras
User Function BKALTFOR()
Local nQUJE := 0
Private cPerg := "BKALTFOR"

If !(__cUserID $ ("000000/"+u_GerCompras()+"/000232")) // códigos dos UserId permitidos na rotina 232-Barbara
	u_MsgLog(cPerg,"Você não tem permissão para usar essa rotina !!!","W")
	Return Nil
EndIf

x1AltFor()
If !Pergunte(cPerg,.T.)
	Return Nil
EndIf

If Empty(MV_PAR02)
	u_MsgLog(cPerg,"Loja destino não informada !!!","E")
	Return Nil
EndIf

cMsg := "PEDIDO: "+SC7->C7_NUM+CRLF
cMsg += "**DE:"+CRLF+SC7->C7_FORNECE+"/"+SC7->C7_LOJA+" - "+Posicione("SA2",1,xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME")+CRLF
cMsg += "**PARA:"+CRLF+MV_PAR01+"/"+MV_PAR02+" - "+Posicione("SA2",1,xFilial("SA2")+MV_PAR01+MV_PAR02,"A2_NOME")+CRLF
cMsg += CRLF+"ATENÇÃO: ESSA MODIFICAÇÃO NÃO TEM ESTORNO !!!"

If u_MsgLog(cPerg,cMsg,"Y")

	cQuery := "SELECT SUM(C7_QUJE) QTDE FROM "+RetSqlname("SC7")+CRLF
	cQuery += " WHERE C7_FILIAL='"+xFilial("SC7")+"' AND "
	cQuery += " C7_NUM = "+VALTOSQL(SC7->C7_NUM)+" AND C7_FORNECE = "+VALTOSQL(SC7->C7_FORNECE)+" AND C7_LOJA = "+VALTOSQL(SC7->C7_LOJA)+CRLF
	cQuery += " AND D_E_L_E_T_=' ' "+CRLF
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)
	nQUJE := TRB->QTDE
	TRB->(dbCloseArea())

	If nQUJE == 0
		cQuery := "UPDATE "+RetSqlname("SC7")+CRLF
		cQuery += " SET "+CRLF
		cQuery += " C7_FORNECE = "+VALTOSQL(MV_PAR01)+CRLF
		cQuery += " ,C7_LOJA = "+VALTOSQL(MV_PAR02)+CRLF
		cQuery += " FROM "+RetSqlname("SC7")+CRLF
		cQuery += " WHERE C7_FILIAL='"+xFilial("SC7")+"' AND "
		cQuery += " C7_NUM = "+VALTOSQL(SC7->C7_NUM)+" AND C7_FORNECE = "+VALTOSQL(SC7->C7_FORNECE)+" AND C7_LOJA = "+VALTOSQL(SC7->C7_LOJA)
		cQuery += " AND D_E_L_E_T_=' ' "
		TcSqlExec(cQuery)
		u_logMemo(cPerg+".SQL",cQuery)
		u_MsgLog(cPerg,"Alteração efetuada com sucesso !!!","I")
	Else
		u_MsgLog(cPerg,"Alteração CANCELADA !!! Já houveram entregas para esse pedido !!!","I")
	EndIf
EndIf
Return Nil




Static Function x1AltFor()
Local j := 0
Local nY := 0
Local aAreaAnt := GetArea()
Local aAreaSX1 := SX1->(GetArea())
Local aReg := {}

aAdd(aReg,{cPerg,"01","Fornecedor novo ? ","mv_ch1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SA2"})
aAdd(aReg,{cPerg,"02","Loja ? ","mv_ch2","C",2,0,0,"G","","","","","","","","","","","","","","","","",""})
aAdd(aReg,{"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_VARIAVL","X1_TIPO","X1_TAMANHO","X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_CNT01","X1_VAR02","X1_DEF02","X1_CNT02","X1_VAR03","X1_DEF03","X1_CNT03","X1_VAR04","X1_DEF04","X1_CNT04","X1_VAR05","X1_DEF05","X1_CNT05","X1_F3"})

dbSelectArea("SX1")
dbSetOrder(1)

For ny:=1 to Len(aReg)-1
	If !dbSeek(PAD(aReg[ny,1],10)+aReg[ny,2])
		RecLock("SX1",.T.)
		For j:=1 to Len(aReg[ny])
			FieldPut(FieldPos(aReg[Len(aReg)][j]),aReg[ny,j])
		Next j
		MsUnlock()
	EndIf
Next ny

RestArea(aAreaSX1)
RestArea(aAreaAnt)

Return Nil
