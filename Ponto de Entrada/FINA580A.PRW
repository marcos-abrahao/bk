#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FINA580A ºAutor  ³Adilso do Prado   º Data ³  27/08/12     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada para validar liberação de pgto contrato	  º±±
±±º		     ³ cancelado ou vencido										  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FINA580A() 
Local lLiber := .T.

//Local aContrato := {}
//Local cQuery:=""
//Local cMsg := ""
//Local cCrLf   := Chr(13) + Chr(10)


Return lLiber
/*

IF !EMPTY(SE2->E2_XXCTRID)
	cQuery := " SELECT Z2_CC "
	cQuery += " FROM "+RETSQLNAME("SZ2")+" SZ2"
	cQuery += " WHERE Z2_FILIAL ='"+xFilial("SZ2")+"' AND Z2_CODEMP ='"+SM0->M0_CODIGO+"' AND "
	cQuery += " Z2_E2PRF ='"+SE2->E2_PREFIXO+"' AND Z2_E2NUM='"+SE2->E2_NUM+"' AND Z2_E2PARC='"+SE2->E2_PARCELA+"' AND "
	cQuery += " Z2_E2TIPO='"+SE2->E2_TIPO+"' AND Z2_E2FORN='"+SE2->E2_FORNECE+"' AND Z2_E2LOJA='"+SE2->E2_LOJA+"'" 


	TCQUERY cQuery NEW ALIAS "QSZ2"
	
	QSZ2->(dbgotop())
   
	Do While QSZ2->(!eof())
    	IF SUBSTR(ALLTRIM(QSZ2->Z2_CC),1,3) <> "Er:"
    		nScan:= 0
			nScan:= aScan(aContrato,QSZ2->Z2_CC)
			IF nScan == 0
				AADD(aContrato,QSZ2->Z2_CC)
		   	Endif
		EndIF
		QSZ2->(DbSkip())
	EndDo
	QSZ2->(dbCloseArea())
ELSE
	cQuery := " SELECT D1_CC "
	cQuery += " FROM "+RETSQLNAME("SD1")+" SD1"
	cQuery += " WHERE D1_FILIAL ='"+xFilial("SD1")+"' AND "
	cQuery += "D1_DOC='"+SE2->E2_NUM+"'	AND D1_SERIE='"+SE2->E2_PREFIXO+"' AND D1_FORNECE='"+SE2->E2_FORNECE+"' AND D1_LOJA='"+SE2->E2_LOJA+"'"                                                                                                                                                                                                                        

	TCQUERY cQuery NEW ALIAS "QSD1"
	
	QSD1->(dbgotop())
   
	Do While QSD1->(!eof())
    	IF SUBSTR(ALLTRIM(QSD1->D1_CC),1,3) <> "Er:"
    		nScan:= 0
			nScan:= aScan(aContrato,QSD1->D1_CC)
			IF nScan == 0
				AADD(aContrato,QSD1->D1_CC)
		   	Endif
		EndIF
		QSD1->(DbSkip())
	EndDo
	QSD1->(dbCloseArea())
ENDIF

cMsg +=""
For _xi := 1 to LEN(aContrato)
	cQuery := " SELECT CN9_NUMERO,CN9_XXDESC,CN9_XXDVIG "
	cQuery += " FROM "+RETSQLNAME("CN9")+" CN9"
	cQuery += " WHERE CN9_NUMERO ='"+aContrato[_xi]+"' AND CN9_SITUAC IN ('02','05') AND CN9_FILIAL = '"+xFilial("CN9")+"'"
	cQuery += " AND CN9_XXDVIG < '"+DTOS(DATE())+"' AND  CN9.D_E_L_E_T_ = ' '"

	TCQUERY cQuery NEW ALIAS "QCN9"
	
	TCSETFIELD("QCN9","CN9_XXDVIG","D",8,0)

	QCN9->(dbgotop())
   
	Do While QCN9->(!eof())
		cMsg += "Contrato: "+ALLTRIM(QCN9->CN9_NUMERO)+" - "+ALLTRIM(QCN9->CN9_XXDESC)+"     Vigência: "+DTOC(QCN9->CN9_XXDVIG)+"   Vencido !!"+cCrLf
		QCN9->(dbSkip())
	ENDDO               
	QCN9->(dbCloseArea())
Next

IF !EMPTY(cMsg)
	If Aviso("Confirma a Liberação do(s) Pagamento(s)?","Titulo: "+TRIM(SE2->E2_PREFIXO)+" "+TRIM(SE2->E2_NUM)+SE2->E2_PARCELA+" - Venc.: "+DTOC(SE2->E2_VENCREA)+cCrLf+cCrLf+cMsg,{"Sim","Nao"} ) <> 1 
		Begin Transaction
			dbSelectArea("SE2")
			RecLock("SE2",.F.,.t.)
			SE2->E2_DATALIB := ctod("  /  /  ")
			SE2->E2_USUALIB := cUsername
			MsUnlock()
		End Transaction
	Endif
ENDIF

Return lLiber
*/