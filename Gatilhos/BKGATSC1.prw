#include "protheus.ch"
#INCLUDE "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKGATSC1
Buscar ultimo valor licitado para o mesmo contrato e produto na solicitação de compras - BK

@Return valor licitado
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

//IF EMPTY(nRet) // .AND. nOpcx = 1
//   aArea1  := GetArea()
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
   RestArea(aArea1)
//ENDIF

Return nRet
