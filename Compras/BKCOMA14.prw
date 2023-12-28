#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKCOMA14()
Rateio de impostos em titulos de impostos já existentes

@author Marcos Bispo Abrahão
@since 26/09/2023
@version P2210
@return .T.

--Verificar rateios FGTS
SELECT D1_DOC,COUNT(D1_ITEM),SUM(D1_TOTAL),MAX(D1_DTDIGIT) 
FROM SD1010 
WHERE D1_COD = '21301005'  
	AND D_E_L_E_T_ = ''
	AND D1_DTDIGIT >= '2019'
GROUP BY D1_DOC
ORDER BY D1_DOC

// SZ5 não encontrado
01/20
02/20
08/21
09/21

// Doc FGTS não encontrado
02/21
03/21



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
Private aBase    := {"PIS/COF/IRPJ","FGTS","INSS","IRRF"} 
Private nBase    := 1

If !"UNIAO" $ SF1->F1_FORNECE
	u_MsgLog(cProg,"Posicione em algum título de imposto para prosseguir com o rateio","E")
	Return Nil
Else
	u_MsgLog(cProg,"Esta rotina efetua o rateio de títulos de impostos (PIS/COF/IRPJ/FGTS/INSS/IRRF), subdividindo os itens por centros de custos no título posicionado","I")
EndIf

aAdd(aParam, { 1,"Mes ref inicial",nMesI   ,"99"  ,"mv_par01 > 0 .AND. mv_par01 <= 12"      ,""   ,"",20,.T.})
aAdd(aParam, { 1,"Ano ref inicial",nAnoI   ,"9999","mv_par02 >= 2010 .AND. mv_par02 <= 2040",""   ,"",20,.T.})
aAdd(aParam, { 1,"Mes ref final"  ,nMesF   ,"99"  ,"mv_par03 > 0 .AND. mv_par03 <= 12"      ,""   ,"",20,.T.})
aAdd(aParam, { 1,"Ano ref final"  ,nAnoF   ,"9999","mv_par04 >= 2010 .AND. mv_par04 <= 2040",""   ,"",20,.T.})
aAdd(aParam, { 3,"Imposto"        ,1,aBase,200,"",.T.})

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
	If nBase == 1
		u_WaitLog(cProg, {|oSay| u_PGCTR07(cMesI,cMesF)}, 'Processando faturamento...')
	ElseIf nBase == 2
		u_WaitLog(cProg, {|oSay| u_PFGTSCC(cMesI,cMesF)}, 'Processando FGTS...')
	ElseIf nBase == 3
		u_WaitLog(cProg, {|oSay| u_PINSSCC(cMesI,cMesF)}, 'Processando INSS Empresa e Terceiros...')
	ElseIf nBase == 4
		u_WaitLog(cProg, {|oSay| u_PIRRFCC(cMesI,cMesF)}, 'Processando IRRF...')
	EndIf
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
    nBase	:= mv_par05
Endif
Return lRet


Static Function ValidaDoc()
Local lOk	:=.T.
//lOk := ContD1()
//If !lOk
//	u_MsgLog(cProg,"Documento deve conter apens um item!","E")
//EndIf

lOk := u_MsgLog(cProg,"Confirma o Rateio do Doc "+SF1->F1_DOC+", total: "+STR(SumD1(),12,2),"Y")

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
Local nPosDCC	:= 0
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
	aadd(aLinha,{"D1_VUNIT"  ,QTMP->VALCC,Nil})
	aadd(aLinha,{"D1_TOTAL"  ,QTMP->VALCC,Nil})
	aadd(aLinha,{"D1_CC"     ,QTMP->CC,Nil})
	aadd(aLinha,{"D1_XXDCC"  ,Posicione("CTT",1,xFilial("CTT")+QTMP->CC,"CTT_DESC01"),Nil})
	aadd(aLinha,{"D1_XXHIST" ,ALLTRIM(cHist),Nil})
	aadd(aItens,aLinha)
	cHist := ""
	nTotal += QTMP->VALCC
	QTMP->(dbSkip())
EndDo
QTMP->(DbCloseArea())

IF Len(aItens) > 0 .AND. nTotal > 0

	If u_MsgLog(cProg,"Valor atual do Documento: "+ALLTRIM(STR((SumD1()),12,2))+" Valor encontrado para rateio: "+ALLTRIM(STR(nTotal,12,2))+" Confirma a operação?","N")
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
					ElseIf SD1->(FieldName(nX)) == "D1_XXDCC"
						nPosDCC := nX
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
					ElseIf nY == nPosDCC    
						SD1->(FieldPut(nY,aItens[nX,7,2]))
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

		u_MsgLog(cProg,"Rateio do Doc "+SF1->F1_DOC+" realizado com sucesso, total: "+STR((SumD1()),12,2),"I")

	EndIf
Else
	
	u_MsgLog(cProg,"Rateio do Doc "+SF1->F1_DOC+" não foi realizado, total: "+STR(nTotal,12,2),"E")

EndIf


Return lRet


Static Function SumD1()
Local cQuery 	 := "SELECT SUM(D1_TOTAL) AS TOTALD1 FROM "+RETSQLNAME("SD1") + ;
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
Local nTotal     := 0

//aadd(aBinds,xFilial("SA1")) // Filial
//aadd(aBinds,"000281") // Codigo
//aadd(aBinds,"01") // Loja

// Ajustes de tratamento de retorno
aadd(aSetFields,{"TOTALD1","N",12,2})

nRet := TCSqlToArr(cQuery,@aReturn,aBinds,aSetFields)

If nRet < 0
	u_MsgLog("SumD1",tcsqlerror()+" Falha ao executar a Query: "+cQuery)
Else
  If Len(aReturn) > 0
	nTotal := aReturn[1][1]
  EndIf
Endif

Return nTotal
