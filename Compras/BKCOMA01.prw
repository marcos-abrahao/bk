#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKCOMA01()
BK - Substituição de Produtos

@author Marcos B. Abrahão
@since 26/04/2024
@version P12
@return Nil
/*/

User Function BKCOMA01()
Local aArea 	:= GetArea()
Local cRet     := ""

Private aParam 	:= {}
Private cTitulo	:= "Substituição de Produtos"
Private cPerg	   := "BKCOMA01"
Private cProd     := SB1->B1_COD
Private cProdA    := SB1->B1_COD

If BKPar1()
	u_WaitLog(cPerg, {|| cRet := AltPrd()},"Alterando o produto "+TRIM(cProdA)+" para "+TRIM(cProd))
   u_MsgLog(cPerg,"Retorno: "+cRet,"I")
EndIF

RestArea(aArea)

Return Nil


Static Function BKPar1()
Local lRet := .F.
Local aRet := {}
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
Do While .T.

	aParam := {}
   aAdd( aParam, { 1, "Produto novo:", cProd	, ""	, ""	, "SB1"	, ""	, 70	, .F. })

	lRet := (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg      ,.T.         ,.T.))
	If !lRet
		Exit
	Else
      cProd := MV_PAR01
      If !Empty(cProd) .AND. ExistCPO("SB1",cProd)
			If u_MsgLog(cPerg,"Confirma substituição do produto "+TRIM(cProdA)+" por "+TRIM(cProd),"Y")
				lRet := .T.
   			Exit
			EndIf
		EndIf
	Endif
EndDo
Return lRet


Static Function AltPrd()
Local cRet     := ""
Local cQuery   := ""
Local aTabs    := {}
Local nI       := 0

// Verificar se há registros de saída do produto
cQuery  := "SELECT COUNT(R_E_C_N_O_) AS EXISTSD2 " 
cQuery  += "FROM "+RETSQLNAME("SD2")+" SD2 WHERE D2_COD = '"+TRIM(cProd)+"' AND SD2.D_E_L_E_T_ = '' "
TCQUERY cQuery NEW ALIAS "QSD2"

DbSelectArea("QSD2")
DbGoTop()
nI := QSD2->EXISTSD2
QSD2->(DbCloseArea())
If nI > 0
   Return cRet := "Produto utilizado em Documentos de Saída, alteração não efetuada"
EndIf

aAdd(aTabs,{"SC7","C7_PRODUTO"})
aAdd(aTabs,{"SC1","C1_PRODUTO"})
aAdd(aTabs,{"SC8","C8_PRODUTO"})
aAdd(aTabs,{"SD1","D1_COD"})
aAdd(aTabs,{"SB2","B2_COD"})
aAdd(aTabs,{"SB7","B7_COD"})
aAdd(aTabs,{"SB9","B9_COD"})
aAdd(aTabs,{"SA5","A5_PRODUTO"})
aAdd(aTabs,{"SCE","CE_PRODUTO"})
aAdd(aTabs,{"CD2","CD2_CODPRO"})
aAdd(aTabs,{"SFT","FT_PRODUTO"})
aAdd(aTabs,{"SCY","CY_PRODUTO"})

For nI := 1 To Len(aTabs)
   cQuery := "UPDATE "+RetSqlName(aTabs[nI,1]) + " SET "+aTabs[nI,2] +" = '"+TRIM(cProd)+"' WHERE "+aTabs[nI,2] +" = '"+cProdA+"'"
   cRet += aTabs[nI,1]

   If TCSQLExec(cQuery) < 0 
   	cRet += " Erro: "+TCSQLERROR()+", "
   Else
	   cRet += " OK, "
   EndIf

   u_MsgLog(cPerg,cQuery)
Next

dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1")+cProdA)
	RecLock('SB1', .F.)
   SB1->(dbDelete())
	SB1->(MsUnlock())
EndIf

Return cRet
