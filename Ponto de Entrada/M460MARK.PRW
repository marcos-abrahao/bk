#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460MARK  ºAutor  ³Adilson do Prado    º Data ³  10/01/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto ponto de entrada para selecionar notas com a serie   º±±
±±º          ³ na geracao Documento de Saida 							  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ³Analista/Alterações                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M460MARK()
Local lRet        	:= .T. 
/*
Trecho desabilitado em 10/03/20 - Marcos - a pedido do Joao Pedro de Araujo Cordeiro (joao.cordeiro)

Local aArea      	:= GetArea()
Local aParam 		:= PARAMIXB

//Local cPedido     	:= SC9->C9_PEDIDO 
Local nQnt			:= 0
Local cMV_XXNFAVU	:= "" //SuperGetMV("MV_XXNFAVU",.F.,"153000304/255000304/256000304")
Local cMV_XXSERI2	:= "" //SuperGetMV("MV_XXSERI2",.F.,""291000469000002\291000469000003\")
Local cMV_XXAMBOS   := "/281003510/291000469/338000539/345000529/281044510/"
Local cQuery := ""


cMV_XXNFAVU	:= "\153000304\255000304\256000304\281004455\281006455\281010455\281011455\281012455\281013455" 
cMV_XXNFAVU	+= "\281014455\281015455\281017455\281018455\281019455\281026455\281027455\281030455\281031455\281032455"
cMV_XXNFAVU	+= "\281033455\281034455\281035455\281036455\281037455\281038455\281039455\281040455\281041455\281042455\281043455"
cMV_XXNFAVU	+= "\281049455\281050455\281047455\281048455\281000510\"

cMV_XXSERI2	:= ""

IF SM0->M0_CODIGO == "01"      // SOMENTE BK

	cQuery := "SELECT DISTINCT "
	cQuery += " C9_PEDIDO,C5_MDCONTR,C5_MDPLANI,C5_ESPECI1"
	cQuery += " FROM "+RETSQLNAME("SC9")+" SC9"
	cQuery += " INNER JOIN "+RETSQLNAME("SC5")+" SC5 ON SC5.D_E_L_E_T_ =''" 
	cQuery += " AND C9_FILIAL = '"+xFilial("SC9")+"' AND C9_PEDIDO=C5_NUM"
	cQuery += " WHERE SC9.D_E_L_E_T_ ='' AND C9_FILIAL = '"+xFilial("SC9")+"' "
	cQuery += " AND C9_NFISCAL = '' "
	If aParam[2]
		cQuery += " AND C9_OK<>'"+aParam[1]+"'"
	Else
		cQuery += " AND C9_OK= '"+aParam[1]+"'"
	EndIf

	TCQUERY cQuery NEW ALIAS "QSC9"
	
	QSC9->(dbGoTop())
	While !QSC9->(Eof())
		nQnt++
		IF !(ALLTRIM(QSC9->C5_MDCONTR) $ cMV_XXAMBOS) .AND. !(ALLTRIM(QSC9->C5_ESPECI1) $ cMV_XXAMBOS)
			IF ALLTRIM(aParam[3]) == '1'
				IF ALLTRIM(QSC9->C5_MDCONTR) $ cMV_XXNFAVU .OR. ALLTRIM(QSC9->C5_MDCONTR)+ALLTRIM(QSC9->C5_MDPLANI) $ cMV_XXSERI2 .OR. ALLTRIM(QSC9->C5_ESPECI1) $ cMV_XXNFAVU
				   lRet := .F. 
				ENDIF
			ENDIF
			IF ALLTRIM(aParam[3])== '2'
				IF !(ALLTRIM(QSC9->C5_MDCONTR) $ cMV_XXNFAVU) .AND. !(ALLTRIM(QSC9->C5_MDCONTR)+ALLTRIM(QSC9->C5_MDPLANI) $ cMV_XXSERI2) .AND. !(ALLTRIM(QSC9->C5_ESPECI1) $ cMV_XXNFAVU)
					lRet := .F. 
				ENDIF
			ENDIF
		ENDIF
		QSC9->(dbSkip())
	EndDo

	IF nQnt > 0
		IF !lRet
 			IF ALLTRIM(aParam[3]) == '1'
 				MSGSTOP("Itens selecionados contem pedidos, que é obrigatório na SERIE = 2")
	 		ENDIF
			IF ALLTRIM(aParam[3]) == '2'
 				MSGSTOP("Itens selecionados contem pedidos, que não são da SERIE = 2")
		 	ENDIF
		ENDIF
	ENDIF

	QSC9->(dbCloseArea()) 
ENDIF
RestArea(aArea)
*/


Return(lRet)   


