#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKCOMA14()
Rateio de impostos em titulos de impostos já existentes

@author Marcos Bispo Abrahão
@since 26/09/2023
@version P2210
@return .T.
/*/

User Function BKCOMA14()
Local lRet 		:= .F.
Local cMesI		:= ""
Local cMesF		:= ""

Private cProg   := "BKCOMA14"
Private cTitulo := "Rateios de Impostos"
Private nMesI	:= Month(MonthSub(dDataBase,1))
Private nAnoI	:= Year(MonthSub(dDataBase,1))
Private nMesF	:= Month(MonthSub(dDataBase,1))
Private nAnoF	:= Year(MonthSub(dDataBase,1))

Private nValor  := 0.00

Private aParam	 :=	{}
Private aRet	 :=	{}
Private cHist    := ""
Private aBase    := {"Faturamento","Folha"} 
Private cBase    := "Faturamento"

If !FWIsAdmin() .AND. !u_IsFiscal(__cUserId)
	u_MsgLog(cProg,"Acesso a rotina somente para o grupo FIscal","W")
	Return Nil
EndIf

aAdd(aParam, { 1,"Mes ref inicial",nMesI   ,"99"  ,"mv_par01 > 0 .AND. mv_par01 <= 12"      ,""   ,"",20,.T.})
aAdd(aParam, { 1,"Ano ref inicial",nAnoI   ,"9999","mv_par02 >= 2010 .AND. mv_par02 <= 2040",""   ,"",20,.T.})
aAdd(aParam, { 1,"Mes ref final"  ,nMesF   ,"99"  ,"mv_par03 > 0 .AND. mv_par03 <= 12"      ,""   ,"",20,.T.})
aAdd(aParam, { 1,"Ano ref final"  ,nAnoF   ,"9999","mv_par04 >= 2010 .AND. mv_par04 <= 2040",""   ,"",20,.T.})
aAdd(aParam, { 3,"Base"           ,1,aBase,200,"",.T.})

// Tipo 11 -> MultiGet (Memo)
//            [2] = Descrição
//            [3] = Inicializador padrão
//            [4] = Validação
//            [5] = When
//            [6] = Campo com preenchimento obrigatório .T.=Sim .F.=Não (incluir a validação na função ParamOk)

Do While .T.
	If !PrCom14()
		lRet := .F.
   		Exit
	Endif
	If ValidaDoc()
		lRet := .T.
   		Exit
	Endif
EndDo

cMesI := STRZERO(nAnoI,4)+STRZERO(nMesI,2)
cMesF := STRZERO(nAnoF,4)+STRZERO(nMesF,2)

If lRet
	u_WaitLog(cProg, {|oSay| PGCTR07(cMesI,cMesF)}, 'Processando faturamento...')
	u_WaitLog(cProg, {|oSay| AltDoc()}, 'Alterando Documento de Entrada...')
EndIf

Return Nil



Static Function PrCom14
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cProg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cProg,.T.         ,.T.))
	lRet	:= .T.
	nMesI	:= mv_par01
	nAnoI	:= mv_par02
	nMesF	:= mv_par03
	nAnoF	:= mv_par04
    cProd	:= aBase[mv_par05]
Endif
Return lRet


Static Function ValidaDoc()
Local lOk	:=.T.
//lOk := ContD1()
//If !lOk
//	u_MsgLog(cProg,"Documento deve conter apens um item!","E")
//EndIf
RETURN lOk 


// Contagem de itens (Pode conter apenas 1 item)
Static Function ContD1()
Local cQuery 	 := "SELECT COUNT(*) AS CONTD1 FROM "+RETSQLNAME("SD1") + ;
					" WHERE D1_FILIAL  = '"+SF1->F1_FILIAL+"' "+;
					"   AND D1_DOC     = '"+SF1->F1_DOC+"' "+;
					"   AND D1_SERIE   = '"+SF1->F1_SERIE+"' "+;
					"   AND D1_FORNECE = '"+SF1->F1_FORNECE+"' "+;
					"   AND D1_LOJA    = '"+SF1->F1_LOJA+"' "+;
					"   AND D_E_L_E_T_ = '' "

Local aReturn 	 := {}
Local aBinds 	 := {}
Local aSetFields := {}
Local nRet		 := 0
Local lRet       := .F.
//aadd(aBinds,xFilial("SA1")) // Filial
//aadd(aBinds,"000281") // Codigo
//aadd(aBinds,"01") // Loja

// Ajustes de tratamento de retorno
aadd(aSetFields,{"CONTD1","N",5,0})
//aadd(aSetFields,{"A1_ULTVIS","D",8,0})

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

If nRet < 0
	u_MsgLog("ContD1",tcsqlerror()+" Falha ao executar a Query: "+cQuery)
Else
  //Alert(VarInfo("aReturn",aReturn))
  //MsgInfo("Verifique os valores retornados no console","Ok")
  If Len(aReturn) > 0
	If aReturn[1][1] == 1
		lRet := .T.
	EndIf
  EndIf
Endif

Return lRet



Static function AltDoc()
Local aLinha    := {}
Local aLinBase  := {}
Local aItens    := {}
Local nX		:= 0
Local nY        := 0
Local lRet		:= .T.
Local nValIt    := 0
Local nTotal    := 0
Local nTotalR   := 0
Local nFator    := 0
Local nPosItem  := 0
Local nPosCC    := 0
Local nPosvunit := 0
Local nPosCusto := 0
Local nPosTotal := 0
Local nPosxxHist:= 0
Local nPosNumSeq:= 0
Local cxxHist   := ""

dbSelectArea("QTMP")
dbGoTop()
Do WHile !QTMP->(EOF())
	//Carrega valores 
	aLinha := {}
	aadd(aLinha,{"D1_FILIAL ",xFilial("SD1")})
	aadd(aLinha,{"D1_COD"    ,"",Nil})
	aadd(aLinha,{"D1_QUANT"  ,1,Nil})
	aadd(aLinha,{"D1_VUNIT"  ,QTMP->F2_VALFAT,Nil})
	aadd(aLinha,{"D1_TOTAL"  ,QTMP->F2_VALFAT,Nil})
	aadd(aLinha,{"D1_CC"     ,QTMP->CNF_CONTRA,Nil})
	aadd(aLinha,{"D1_XXHIST" ,ALLTRIM(cHist),Nil})
	aadd(aItens,aLinha)
	cHist := ""
	nTotal += QTMP->F2_VALFAT
	QTMP->(dbSkip())
EndDo
QTMP->(DbCloseArea())

SD1->(dbSetOrder(1))
If SD1->(dbSeek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.T.))
	If SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
		For nX := 1 To SD1->(FCount())
			aAdd(aLinBase,SD1->(FieldGet(nX)))
			If SD1->(FieldName(nX)) == "D1_ITEM"
				nPosItem  := nX
			ElseIf SD1->(FieldName(nX)) == "D1_CC"
				nPosCC    := nX
			ElseIf SD1->(FieldName(nX)) == "D1_VUNIT"
				nPosvunit := nX
			ElseIf SD1->(FieldName(nX)) == "D1_CUSTO"
				nPosCusto := nX
			ElseIf SD1->(FieldName(nX)) == "D1_TOTAL"
				nPosTotal := nX
			ElseIf SD1->(FieldName(nX)) == "D1_XXHIST"
				nPosxxHist:= nX
			ElseIf SD1->(FieldName(nX)) == "D1_NUMSEQ"
				nPosNumSeq:= nX
			EndIf
		Next
		cxxHist := SD1->D1_XXHIST

		Do While !SD1->(Eof()) .AND. SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA
			If SD1->D1_ITEM == "0001"
				cxxHist := SD1->D1_XXHIST
			EndIf
			nValor  += SD1->D1_TOTAL
			// Exclusão do item que será substituido
			RecLock("SD1",.F.)
			SD1->(dbDelete())
			MsUnlock()
			SD1->(dbSkip())
		EndDo

	EndIf
EndIf

IF Len(aItens) > 0 .AND. nValor > 0

	nFator  := nValor / nTotal
	nTotalR := 0 
	For nX := 1 To Len(aItens)
		nValIt := ROUND(aItens[nX,4,2] * nFator,2)
		aItens[nX,4,2] := nValIt
		aItens[nX,5,2] := nValIt
		nTotalR += nValIt
	Next
	
	If nTotalR <> nValor
		aItens[1,4,2] += (nValor - nTotalR)
		aItens[1,5,2] += (nValor - nTotalR)
	EndIf

	// Inclusao dos Itens rateados
	Begin Transaction

		For nX := 1 To Len(aItens)

			RecLock("SD1",.T.)

			For nY := 1 to Len(aLinBase)
				If nY == nPosItem  
					SD1->(FieldPut(nY,STRZERO(nX,4)))
				ElseIf nY == nPosCC    
					SD1->(FieldPut(nY,aItens[nX,6,2]))
				ElseIf nY == nPosvunit 
					SD1->(FieldPut(nY,aItens[nX,4,2]))
				ElseIf nY == nPosCusto 
					SD1->(FieldPut(nY,aItens[nX,4,2]))
				ElseIf nY == nPosTotal 
					SD1->(FieldPut(nY,aItens[nX,4,2]))
				ElseIf nY == nPosNumSeq
					SD1->(FieldPut(nY,ProxNum()))
				ElseIf nY == nPosxxHist
					If nX == 1
						SD1->(FieldPut(nY,cxxHist))
					EndIf
				Else
					SD1->(FieldPut(nY,aLinBase[nY]))
				EndIf

			Next
			MsUnlock()

		Next
		//DisarmTransaction()

	End Transaction
EndIf

u_MsgLog(cProg,"Rateio do Doc "+SF1->F1_DOC+" realizado com sucesso","I")

Return lRet




Static Function PGCTR07(cMesI,cMesF)
Local cQuery := ""

cQuery := "WITH BKGCTR07 AS ("+CRLF
cQuery += u_QGctR07(iIf(cMesI == cMesF,1,3),cMesI,cMesF)
cQuery += ")"+CRLF
cQuery += "SELECT CNF_CONTRA,SUM(F2_VALFAT) AS F2_VALFAT FROM BKGCTR07 GROUP BY CNF_CONTRA"+CRLF
cQuery += "ORDER BY CNF_CONTRA"+CRLF

u_LogMemo("BKCOMA14.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"

Return NIL


