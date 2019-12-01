#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} PrdSc1
Sugerir ultimo valor digitado previsto na licitação (validação C1_PRODUTO)

@Return  .T.
@author Marcos Bispo Abrahão
@since 13/06/2019
@version P12
/*/



User Function PrdSc1()
LOCAL cQuery, nXXLCVAL := 0
Local aArea1 := GetArea()

IF EMPTY(M->C1_XXLCVAL) // .AND. nOpcx = 1
   aArea1  := GetArea()
   cQuery  := "SELECT TOP 1 C1_PRODUTO,C1_XXLCVAL " 
   cQuery  += "FROM "+RETSQLNAME("SC1")+" SC1 "
   cQuery  += "WHERE C1_FILIAL = '"+xFilial("SC1")+"' "
   cQuery  += "AND C1_CC = '"+TRIM(cCC)+"' "
   cQuery  += "AND C1_PRODUTO = '"+TRIM(M->C1_PRODUTO)+"' "
   cQuery  += "AND SC1.D_E_L_E_T_ <> '*' "
   cQuery  += "ORDER BY C1_EMISSAO DESC "
   TCQUERY cQuery NEW ALIAS "TMPC1"
   dbSelectArea("TMPC1")
   dbGoTop()
   IF !EOF()
      nXXLCVAL := C1_XXLCVAL
      M->C1_XXLCVAL := nXXLCVAL
   ENDIF   
   dbCloseArea()
   RestArea(aArea1)
ENDIF

Return .T.

