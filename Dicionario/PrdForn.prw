#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

User Function PrdForn()
LOCAL cQuery,dMesAnt,cCodPrx
Local aArea1 := GetArea()
//IF n = 1 .AND. EMPTY(M->D1_COD) // .AND. nOpcx = 1
IF EMPTY(M->D1_COD) // .AND. nOpcx = 1
   aArea1  := GetArea()
   dMesAnt := DATE() - 180
   dMesAnt := dMesAnt - DAY(dMesAnt) + 1
   cQuery  := "SELECT TOP 1 D1_COD,B1_MSBLQL " 
   cQuery  += " FROM "+RETSQLNAME("SD1")+" SD1 "
   cQuery  += " LEFT JOIN "+RETSQLNAME("SB1")+" SB1 ON B1_FILIAL = '"+xFilial("SB1")+"' AND D1_COD = B1_COD AND SB1.D_E_L_E_T_ = '' "+CRLF   
   cQuery  += " WHERE D1_FILIAL = '"+xFilial("SD1")+"' "
   cQuery  += " AND D1_FORNECE = '"+cA100For+"' "
   cQuery  += " AND D1_LOJA = '"+cLoja+"' "
   cQuery  += " AND D1_DTDIGIT >= '"+DTOS(dMesAnt)+"' "
   cQuery  += " AND SD1.D_E_L_E_T_ <> '*' "
   cQuery  += " ORDER BY D1_DTDIGIT DESC "
   TCQUERY cQuery NEW ALIAS "TMPD1"
   dbSelectArea("TMPD1")
   dbGoTop()
   IF !EOF()
      cCodPrx := TMPD1->D1_COD
      //dbSkip()
      //IF EOF()
      M->D1_COD := cCodPrx
      //ENDIF   
      If TMPD1->B1_MSBLQL == '1'
         u_MsgLog("PrdForn-When","Produto bloqueado!","E")
      EndIf
   ENDIF   
   dbCloseArea()
   RestArea(aArea1)
ENDIF

Return .T.

/*
   TMPD1->(dbGoTop())
   IF TMPD1->(LASTREC()) = 1
      M->D1_COD := TMPD1->D1_COD
   ENDIF   
   TMPD1->(dbCloseArea())
*/
