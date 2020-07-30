#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"

/*/{Protheus.doc} CNA130INC
BK - Ponto de Entrada para carregar campos na inclusão das mediçoes

@Return
@author Marcos B Abrahão
@since 18/05/10
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
M->CND_XXTPNF := "N"

//CONDICAO DE PAGAMENTO 10º DIAS UTIL
IF CN9->CN9_CONDPG == '065'
	dVencPGTO := U_DIASUTIL(dDataBase,10)
	M->CND_PARC1 :=	M->CND_VLTOT
	M->CND_DATA1 := dVencPGTO
ENDIF
 
MsAguarde({|| aSitFunc:= U_BKGCTF01(SM0->M0_CODIGO,SUBSTR(M->CND_CONTRA,7,3),M->CND_CONTRA)},"Aguarde","Calculando número de funcionários...",.F.)

//cSitFunc:= "Cod. Situação                       Total"+cCrLf

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
	M->CND_XXJFUN := "Sem Alterações"
ENDIF

// Verificar se tem solicitação de despesa de viagem para este contrato nesta competencia
	
//cSql := "SELECT Z2_CC,SUM(Z2_VALOR)AS TOTAL FROM "+RetSqlName("SZ2")+" SZ2"
//cSql += " WHERE SZ2.D_E_L_E_T_='' AND Z2_CODEMP='"+SM0->M0_CODIGO+"' AND Z2_TIPO='SOL' AND Z2_STATUS <> 'D'"
//cSql += " AND SUBSTRING(Z2_DATAEMI,1,6)='"+SUBSTR(M->CND_COMPET,4,4)+SUBSTR(M->CND_COMPET,1,2)+"' and Z2_CC='"+M->CND_CONTRA+"'"
//cSql += " GROUP BY Z2_CC"  	

// Buscar solicitações de até 3 meses atras
nMesComp := VAL(SUBSTR(M->CND_COMPET,1,2))
nAnoComp := VAL(SUBSTR(M->CND_COMPET,4,4))

nMesComp := nMesComp - 3
If nMesComp < 1
   nMesComp := 12 + nMesComp
   nAnoComp--
EndIf
	
cSql := "SELECT Z2_CC,SUM(Z2_VALOR)AS TOTAL,"
cSql += " (SELECT TOP 1 CND_XXDV FROM CND010 CND WHERE CND.D_E_L_E_T_='' "
cSql += "  AND CND_CONTRA='"+M->CND_CONTRA+"' AND CND_COMPET='"+M->CND_COMPET+"' AND CND_XXDV<>'' ) AS CND_XXDV " 
cSql += "FROM SZ2010 SZ2 "
cSql += "WHERE SZ2.D_E_L_E_T_='' AND Z2_CODEMP='"+SM0->M0_CODIGO+"' AND Z2_TIPO='SOL' AND Z2_STATUS <> 'D' AND Z2_NDC = ' ' "
//cSql += " AND SUBSTRING(Z2_DATAEMI,1,6)='"+SUBSTR(M->CND_COMPET,4,4)+SUBSTR(M->CND_COMPET,1,2)+"'"
cSql += " AND SUBSTRING(Z2_DATAEMI,1,6)>='"+STRZERO(nAnoComp,4)+STRZERO(nMesComp,2)+"'"
cSql += " AND Z2_CC='"+M->CND_CONTRA+"' "
cSql += "GROUP BY Z2_CC "
	
TCQUERY cSql NEW ALIAS (cAliasSZ2)
	
dbSelectArea(cAliasSZ2)
(cAliasSZ2)->(DbGotop()) 
//IF EMPTY((cAliasSZ2)->CND_XXDV)
	IF (cAliasSZ2)->TOTAL > 0 
		IF MsgYesNo("Faturado solicitação de viagens contrato: "+TRIM(M->CND_CONTRA)+" - Valor R$ "+ALLTRIM(TRANSFORM((cAliasSZ2)->TOTAL,"@E 999,999,999.99")))
			M->CND_XXDV   := "S"
			M->CND_XXVLND := (cAliasSZ2)->TOTAL
		ELSE
			M->CND_XXDV   := "N"
		ENDIF
	ENDIF
//ELSE
//	M->CND_XXDV := (cAliasSZ2)->CND_XXDV
//ENDIF

//If M->CND_VLTOT > M->CND_VLPREV
//	M->CND_DESCME := M->CND_VLTOT > M->CND_VLPREV
//EndIf 

If (INCLUI .Or. ALTERA)
    If Len(aCols) == 1
		nDif := ABS(aCols[1,9] - CND_VLPREV)
        //If ABS(aCols[1,9] - CND_VLPREV) <= 10
		If nDif > 0
			IF __cUserId $ "000000/000012/000023" .OR. nDif <= 10
				If MSGYESNO("Deseja ajustar a diferença entre a planilha e o cronograma? (R$ "+ALLTRIM(STR(nDif))+")","CN130INC")
					aCols[1,9] := CND_VLPREV
					aCols[1,8] := Round(aCols[1][9] / aCols[1][6],8)
					//aCols[1,8] := CND_VLPREV
					CND_VLTOT  := CND_VLPREV
				EndIf
			EndIf
        EndIf
    EndIf
EndIf


(cAliasSZ2)->(DbCloseArea())

RestArea(aAreas)
Return NIL
