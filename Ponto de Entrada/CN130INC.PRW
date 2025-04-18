#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#include "RWMAKE.CH"

/*/{Protheus.doc} CNA130INC
BK - Ponto de Entrada para carregar campos na inclus�o das medi�oes

@Return
@author Marcos B Abrah�o
@since 18/05/10 rev 22/02/2022
@version P11/P12
/*/

User Function CN130INC()

Local aAreas    := GetArea()
Local cSitFunc  := ""
Local aSitFunc  := {}
Local nTotFunc  := 0
Local _XI       := 0
Local cCrLf     := Chr(13) + Chr(10)
Local cSql      := "" 
Local cAliasSZ2 := GetNextAlias()
Local dVencPGTO := CTOD("")
Local nMesComp  := 0
Local nAnoComp  := 0
Local nDif		:= 0

M->CND_XXMUN  := POSICIONE("CNA",1,xFilial("CNA")+M->CND_CONTRA+M->CND_REVISA+M->CND_NUMERO,"CNA_XXMUN")
M->CND_XXDESC := POSICIONE("CTT",1,xFilial("CTT")+M->CND_CONTRA,"CTT_DESC01")            
M->CND_NOMCLI := POSICIONE("SA1",1,xFilial("SA1")+M->CND_CLIENT+M->CND_LOJACL,"A1_NOME")
M->CND_XXPOST := CN9->CN9_XXPOST
M->CND_XXFUNC := CN9->CN9_XXFUNC
M->CND_XXTPNF := POSICIONE("CNA",1,xFilial("CNA")+M->CND_CONTRA+M->CND_REVISA+M->CND_NUMERO,"CNA_XXTPNF")

//CONDICAO DE PAGAMENTO 10� DIAS UTIL
IF CN9->CN9_CONDPG == '065'
	dVencPGTO := U_DIASUTIL(dDataBase,10)
	M->CND_PARC1 :=	M->CND_VLTOT
	M->CND_DATA1 := dVencPGTO
ENDIF
 
u_WaitLog(,{|| aSitFunc:= U_BKGCTF01(SM0->M0_CODIGO,SUBSTR(M->CND_CONTRA,7,3),M->CND_CONTRA)},"Aguarde","Calculando n�mero de funcion�rios...",.F.)

//cSitFunc:= "Cod. Situa��o                       Total"+cCrLf

FOR _XI := 1 TO LEN(aSitFunc)
	cSitFunc += STR(aSitFunc[_XI,1],4)+" - "+PAD(aSitFunc[_XI,2],20)+" "+STR(aSitFunc[_XI,3],6)+" | "
	IF MOD(_XI,2) == 0
		cSitFunc += cCrLf
	ENDIF
	nTotFunc += aSitFunc[_XI,3] 
NEXT
M->CND_XXDFUN := cSitFunc
M->CND_XXNFUN := nTotFunc
IF M->CND_XXFUNC == M->CND_XXNFUN 
	M->CND_XXJFUN := "Sem Altera��es"
ENDIF

// Verificar se tem solicita��o de despesa de viagem para este contrato nesta competencia
	
//cSql := "SELECT Z2_CC,SUM(Z2_VALOR)AS TOTAL FROM "+RetSqlName("SZ2")+" SZ2"
//cSql += " WHERE SZ2.D_E_L_E_T_='' AND Z2_CODEMP='"+SM0->M0_CODIGO+"' AND Z2_TIPO='SOL' AND Z2_STATUS <> 'D'"
//cSql += " AND SUBSTRING(Z2_DATAEMI,1,6)='"+SUBSTR(M->CND_COMPET,4,4)+SUBSTR(M->CND_COMPET,1,2)+"' and Z2_CC='"+M->CND_CONTRA+"'"
//cSql += " GROUP BY Z2_CC"  	

// Buscar solicita��es de at� 3 meses atras
nMesComp := VAL(SUBSTR(M->CND_COMPET,1,2))
nAnoComp := VAL(SUBSTR(M->CND_COMPET,4,4))

nMesComp := nMesComp - 3
If nMesComp < 1
   nMesComp := 12 + nMesComp
   nAnoComp--
EndIf

M->CND_XXDV   := "N"
If !u_IsPetro(M->CND_CLIENT)
	cSql := "SELECT SUM(Z2_VALOR) AS TOTAL"
	//cSql += " ,Z2_CC"
	//cSql += " ,(SELECT TOP 1 CND_XXDV FROM CND010 CND WHERE CND.D_E_L_E_T_='' "
	//cSql += "  AND CND_CONTRA='"+M->CND_CONTRA+"' AND CND_COMPET='"+M->CND_COMPET+"' AND CND_XXDV<>'' ) AS CND_XXDV " 
	cSql += "FROM SZ2010 SZ2 "
	cSql += "WHERE SZ2.D_E_L_E_T_='' " //AND SZ2.Z2_FILIAL = '"+xFilial("SZ2")+"' "
	cSql += "  AND Z2_CODEMP='"+cEmpAnt+"' AND Z2_TIPO='SOL' AND Z2_STATUS <> 'D' AND Z2_NDC = ' ' "
	//cSql += " AND SUBSTRING(Z2_DATAEMI,1,6)='"+SUBSTR(M->CND_COMPET,4,4)+SUBSTR(M->CND_COMPET,1,2)+"'"
	cSql += " AND SUBSTRING(Z2_DATAEMI,1,6)>='"+STRZERO(nAnoComp,4)+STRZERO(nMesComp,2)+"'"
	cSql += " AND Z2_CC='"+M->CND_CONTRA+"' "
	//cSql += "GROUP BY Z2_CC "
		
	TCQUERY cSql NEW ALIAS (cAliasSZ2)
		
	//dbSelectArea(cAliasSZ2)
	(cAliasSZ2)->(DbGotop()) 
	IF (cAliasSZ2)->TOTAL > 0 
		If u_MsgLog("CN130INC","Faturado solicita��o de viagens contrato: "+TRIM(M->CND_CONTRA)+" - Valor R$ "+ALLTRIM(TRANSFORM((cAliasSZ2)->TOTAL,"@E 999,999,999.99")),"Y")
			M->CND_XXDV   := "S"
			M->CND_XXVLND := (cAliasSZ2)->TOTAL
		ENDIF
	ENDIF
	(cAliasSZ2)->(DbCloseArea())
ENDIF

//If M->CND_VLTOT > M->CND_VLPREV
//	M->CND_DESCME := M->CND_VLTOT > M->CND_VLPREV
//EndIf 

If (INCLUI .Or. ALTERA)
    If Len(aCols) == 1
		nDif := ABS(aCols[1,9] - CND_VLPREV)
        //If ABS(aCols[1,9] - CND_VLPREV) <= 10
		If nDif > 0
			IF __cUserId $ "000000/000012/000023/000288" .OR. nDif <= 10
				If u_MsgLog("CN130INC","Deseja ajustar a diferen�a entre a planilha e o cronograma (R$ "+ALLTRIM(STR(nDif))+")","Y")
					aCols[1,9] := CND_VLPREV
					aCols[1,8] := Round(aCols[1][9] / aCols[1][6],8)
					//aCols[1,8] := CND_VLPREV
					CND_VLTOT  := CND_VLPREV
				EndIf
			EndIf
        EndIf
    EndIf
EndIf

RestArea(aAreas)
Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} DATAUTIL
BK - VERIFICA SE A DATA � UTIL
@Return
@author Marcos B. Abrahao
@since 29/01/2011
@version P12
/*/
//-------------------------------------------------------------------

USER FUNCTION DATAUTIL(dData)
Local lRet := .F.
Local dData2 := CTOD("")

dData2 := LastDay(dData, 3)
IF dData2  == dData
	lRet := .T.
ENDIF

RETURN lRet 



USER FUNCTION DIASUTIL(dData,nDIAS)
Local dData2 := CTOD("")
Local nSoma  := 1

dData2 := dData

DO WHILE nDIAS > nSoma

	IF U_DATAUTIL(dData2)
		++nSoma
	ENDIF
	dData2 := DaySum(dData2,1)
ENDDO

DO WHILE !U_DATAUTIL(dData2)
	dData2 := DaySum(dData2,1)
ENDDO
RETURN dData2 
