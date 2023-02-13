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
             
Local cQuery := ""
Local aArea1 := GetArea()
Local nRet   := 0
Local nPosLCVal := aScan(aHeader, {|x| AllTrim(x[2]) == "C1_XXLCVAL"})
Local nPosProd  := aScan(aHeader, {|x| AllTrim(x[2]) == "C1_PRODUTO"})
Local nPosDesc	 := aScan(aHeader, {|x| AllTrim(x[2]) == 'C1_DESCRI'})


If Empty( aCols[n][nPosDesc] )
   aCols[n][nPosDesc] := Posicione("SB1",1,xFilial("SB1")+aCols[n][nPosProd],"B1_DESC")
EndIf


nRet := aCols[n,nPosLCVal]

// Preço do Ultimo Pedido de Compras
cQuery  := "SELECT TOP 1 C7_PRECO " 
cQuery  += "FROM "+RETSQLNAME("SC7")+" SC7 "
cQuery  += "WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
cQuery  += "AND C7_CC = '"+TRIM(cCC)+"' "
cQuery  += "AND C7_PRODUTO = '"+TRIM(aCols[n,nPosProd])+"' "
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
   cQuery  += "AND D1_CC = '"+TRIM(cCC)+"' "
   cQuery  += "AND D1_COD = '"+TRIM(aCols[n,nPosProd])+"' "
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
   cQuery  += "AND C1_CC = '"+TRIM(cCC)+"' "
   cQuery  += "AND C1_PRODUTO = '"+TRIM(aCols[n,nPosProd])+"' "
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

RestArea(aArea1)

Return nRet
