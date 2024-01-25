#include "protheus.ch"
#INCLUDE "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKGATSC1
Buscar ultimo valor estimado para o mesmo contrato e produto na solicitação de compras - BK

@Return valor estimado
@author Marcos Bispo Abrahão
@since 04/07/2019
@version P11
/*/
//-------------------------------------------------------------------


User Function BKGATSC1()
Local nRet     := 0
Local nPosLCVal:= aScan(aHeader, {|x| AllTrim(x[2]) == "C1_XXLCVAL"})
Local nPosProd := aScan(aHeader, {|x| AllTrim(x[2]) == "C1_PRODUTO"})
Local nPosDesc := aScan(aHeader, {|x| AllTrim(x[2]) == 'C1_DESCRI'})

If Empty(cCC)
   u_MsgLog("BKGATSC1","Centro de custos não informado!! (preço estimado sugerido pode estar incorreto)","E")
EndIf

If Empty( aCols[n][nPosDesc] )
   aCols[n][nPosDesc] := Posicione("SB1",1,xFilial("SB1")+aCols[n][nPosProd],"B1_DESC")
EndIf

nRet := u_GPrdSc1(TRIM(aCols[n,nPosProd]),cCC,0)
If nRet == 0
   nRet := aCols[n,nPosLCVal]
EndIf

Return nRet




User Function GPrdSc1(cProd,cCC,nVal)
Local cQuery	:= ""
Local nRet		:= 0
Local aArea1	:= GetArea()

// Preço do Ultimo Pedido de Compras
cQuery  := "SELECT TOP 1 C7_PRECO " 
cQuery  += "FROM "+RETSQLNAME("SC7")+" SC7 "
cQuery  += "WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
If !Empty(cCC) .AND. cEmpAnt == '01' // Para BK procurar por CC
   cQuery  += "AND C7_CC = '"+TRIM(cCC)+"' "
EndIf
cQuery  += "AND C7_PRODUTO = '"+cProd+"' "
cQuery  += "AND SC7.D_E_L_E_T_ = '' "
cQuery  += "ORDER BY C7_EMISSAO DESC "
TCQUERY cQuery NEW ALIAS "TMPC7"
dbSelectArea("TMPC7")
dbGoTop()
IF !EOF()
   nRet := TMPC7->C7_PRECO
   //M->C1_XXLCVAL := nXXLCVAL
ENDIF   
dbCloseArea()

// Preço da Ultima NF de Entrada
If Empty(nRet)
   cQuery  := "SELECT TOP 1 D1_VUNIT " 
   cQuery  += "FROM "+RETSQLNAME("SD1")+" SD1 "
   cQuery  += "WHERE D1_FILIAL = '"+xFilial("SD1")+"' "
   If !Empty(cCC) .AND. cEmpAnt == '01' // Para BK procurar por CC
      cQuery  += "AND D1_CC = '"+TRIM(cCC)+"' "
   EndIf
   cQuery  += "AND D1_COD = '"+cProd+"' "
   cQuery  += "AND SD1.D_E_L_E_T_ = '' "
   cQuery  += "ORDER BY D1_DTDIGIT DESC "
   TCQUERY cQuery NEW ALIAS "TMPD1"
   dbSelectArea("TMPD1")
   dbGoTop()
   IF !EOF()
      nRet := TMPD1->D1_VUNIT
      //M->C1_XXLCVAL := nXXLCVAL
   ENDIF   
   dbCloseArea()
EndIf

// Preço da Ultima Solicitação de compras
If Empty(nRet)
   cQuery  := "SELECT TOP 1 C1_XXLCVAL " 
   cQuery  += "FROM "+RETSQLNAME("SC1")+" SC1 "
   cQuery  += "WHERE C1_FILIAL = '"+xFilial("SC1")+"' "
   If !Empty(cCC) .AND. cEmpAnt == '01' // Para BK procurar por CC
      cQuery  += "AND C1_CC = '"+TRIM(cCC)+"' "
   EndIf
   cQuery  += "AND C1_PRODUTO = '"+cProd+"' "
   cQuery  += "AND SC1.D_E_L_E_T_ <> '*' "
   cQuery  += "ORDER BY C1_EMISSAO DESC "
   TCQUERY cQuery NEW ALIAS "TMPC1"
   dbSelectArea("TMPC1")
   dbGoTop()
   IF !EOF()
      nRet := TMPC1->C1_XXLCVAL
      //M->C1_XXLCVAL := nXXLCVAL
   ENDIF   
   dbCloseArea()
EndIf

If nRet == 0 .AND. nVal > 0
   nRet := nVal
EndIf

RestArea(aArea1)

Return nRet
