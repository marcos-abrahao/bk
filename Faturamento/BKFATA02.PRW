#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BKFATA02  ºAutor  ³Adilson do Prado     º Data ³  30/11/17 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Gera titulo de abatimento utilizado para calculo impostos  º±±
±±º            FE-FUMDIP OSASCO  		                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ³ Analista/Alterações                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION BKFATA02(nOPCAO)
Local aArea := getarea()
LOCAL cPARCELA	:= ""
LOCAL cNOMCLI	:= ""
LOCAL dEMISSAO 	:= CTOD("")
LOCAL dVENCTO	:= CTOD("")
LOCAL dVENCREA 	:= CTOD("")
LOCAL dVENCORI 	:= CTOD("")
LOCAL cTIPO    	:= ""
LOCAL cMOEDA    := ""
LOCAL cSITUACA  := ""
Local cCliente  := ""
Local cLoja		:= ""
Local cChaveSE1 := ""
Local cFILORIG	:= ""
Local aReceber  := {}
Default nOPCAO := 3


IF SF2->F2_XXVFUMD  > 0
	cChaveSE1 := SF2->(F2_SERIE)+SF2->(F2_DOC)+" "+cTIPO+SF2->(F2_CLIENTE)+SF2->(F2_LOJA)
	DBSELECTAREA("SE1")
	SE1->(dbSetOrder(RETORDEM("SE1","E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"))) 
 	SE1->(MsSeek(xFilial("SE1") + SF2->(F2_CLIENTE) + SF2->(F2_LOJA) + SF2->(F2_SERIE)+SF2->(F2_DOC)+"  "+"NF ",.T.))     
 	cPARCELA	:= SE1->(E1_PARCELA)
 	cNOMCLI		:= SE1->(E1_NOMCLI)
 	dEMISSAO 	:= SE1->(E1_EMISSAO)
 	dVENCTO		:= SE1->(E1_VENCTO)
 	dVENCREA 	:= SE1->(E1_VENCREA)
 	dVENCORI 	:= SE1->(E1_VENCORI)
 	cTIPO    	:= SE1->(E1_TIPO)
 	cMOEDA    	:= SE1->(E1_MOEDA)
 	cSITUACA  	:= SE1->(E1_SITUACA)
 	cCliente  	:= SE1->(E1_CLIENTE)
 	cLoja		:= SE1->(E1_LOJA)
 	cFILORIG	:= SE1->(E1_FILORIG)
 	
	IF  !U_ExisteTit(SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_PREFIXO, SE1->E1_NUM,SE1->E1_PARCELA,"FE-",SF2->F2_XXVFUMD,cChaveSE1)
	        
        aReceber :={{"E1_FILIAL",xFilial("SE1"),Nil},;
						{"E1_NUM",SF2->(F2_DOC),Nil},;
						{"E1_PREFIXO",SF2->(F2_SERIE),Nil},;
						{"E1_PARCELA",cPARCELA,Nil},;
						{"E1_TIPO","FE-",Nil},;
						{"E1_NATUREZ","FUMDIP",Nil},;
						{"E1_CLIENTE",SF2->(F2_CLIENTE),Nil},;
						{"E1_LOJA",SF2->(F2_LOJA),Nil},;
						{"E1_NOMCLI",cNOMCLI,Nil},;
						{"E1_EMISSAO",dEMISSAO,Nil},;
						{"E1_EMIS1",dEMISSAO,Nil},;
						{"E1_VENCTO",dVENCTO,Nil},;
						{"E1_VENCREA",dVENCREA,Nil},;
						{"E1_VALOR",SF2->F2_XXVFUMD,Nil},;
						{"E1_SALDO",SF2->F2_XXVFUMD,Nil},;
						{"E1_VENCORI",dVENCORI,Nil},;
						{"E1_OCORREN","04",Nil},;
						{"E1_VLCRUZ",SF2->F2_XXVFUMD,Nil},;
						{"E1_STATUS","A",Nil},;
						{"E1_ORIGEM","MATA460",Nil},;
						{"E1_TITPAI",SF2->(F2_SERIE)+SF2->(F2_DOC)+"  "+cTIPO+SF2->(F2_CLIENTE)+SF2->(F2_LOJA),Nil},;
						{"E1_SITUACA",cSITUACA,Nil},;
						{"E1_MOEDA",cMOEDA,Nil},;
						{"E1_FILORIG",cFILORIG,Nil}}
		
		Begin Transaction
			lMsErroAuto := .F.
			MSExecAuto({|x,y| Fina040(x,y)},aReceber,3) //Inclusao

			IF lMsErroAuto
	    		MostraErro()
				DisarmTransaction()
			EndIf

		End Transaction
	ELSEIF nOPCAO == 5
        aReceber :={{"E1_FILIAL",xFilial("SE1"),Nil},;
						{"E1_NUM",SF2->(F2_DOC),Nil},;
						{"E1_PREFIXO",SF2->(F2_SERIE),Nil},;
						{"E1_PARCELA",cPARCELA,Nil},;
						{"E1_TIPO","FE-",Nil},;
						{"E1_NATUREZ","FUMDIP",Nil},;
						{"E1_CLIENTE",SF2->(F2_CLIENTE),Nil},;
						{"E1_LOJA",SF2->(F2_LOJA),Nil},;
						{"E1_NOMCLI",cNOMCLI,Nil},;
						{"E1_EMISSAO",dEMISSAO,Nil},;
						{"E1_EMIS1",dEMISSAO,Nil},;
						{"E1_VENCTO",dVENCTO,Nil},;
						{"E1_VENCREA",dVENCREA,Nil},;
						{"E1_VALOR",SF2->F2_XXVFUMD,Nil},;
						{"E1_SALDO",SF2->F2_XXVFUMD,Nil},;
						{"E1_VENCORI",dVENCORI,Nil},;
						{"E1_OCORREN","04",Nil},;
						{"E1_VLCRUZ",SF2->F2_XXVFUMD,Nil},;
						{"E1_STATUS","A",Nil},;
						{"E1_ORIGEM","MATA460",Nil},;
						{"E1_TITPAI",SF2->(F2_SERIE)+SF2->(F2_DOC)+"  "+cTIPO+SF2->(F2_CLIENTE)+SF2->(F2_LOJA),Nil},;
						{"E1_SITUACA",cSITUACA,Nil},;
						{"E1_MOEDA",cMOEDA,Nil},;
						{"E1_FILORIG",cFILORIG,Nil}}
		
		Begin Transaction
			lMsErroAuto := .F.
			MSExecAuto({|x,y| Fina040(x,y)},aReceber,5) //Exclusao

			IF lMsErroAuto
	    		MostraErro()
				DisarmTransaction()
			EndIf

		End Transaction
	ENDIF 
ENDIF

RestArea(aArea)

RETURN NIL



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ExisteTit   ºAutor ³Adriano Ueda       º Data ³  30/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se o titulo a receber existe                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
USER Function ExisteTit(cCli_, cLJ_, cPRFX_, cNum_, cPARC_,cTP_,Valor_,cCHAVESF2)
	Local lRet := .F.
	Local aAreaSE1 := SE1->(GetArea())
	
	dbSelectArea("SE1")

	SE1->(dbSetOrder(RETORDEM("SE1","E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"))) 

	IF SE1->(MsSeek(xFilial("SE1") + cCli_ + cLJ_ + cPRFX_ + cNum_ + cPARC_ + cTP_, .F.))
		IF SE1->(E1_VALOR) <> Valor_
			RecLock("SE1",.F.)
			SE1->(dbDelete())
			SE1->(MsUnlock())
			lRet := .F.
		ELSE
	    	IF ALLTRIM(SE1->(E1_TITPAI)) <> ALLTRIM(cCHAVESF2)
				SE1->(RECLOCK("SE1",.F.))
				SE1->(E1_TITPAI)  	:= cCHAVESF2 
				SE1->(MSUNLOCK())
			ENDIF
			lRet := .T.
		ENDIF
	ELSE
		lRet := .F.
	ENDIF

	RestArea(aAreaSE1) 
	
Return lRet 