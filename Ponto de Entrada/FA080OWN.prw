#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FA080CHK ºAutor  ³Marcos B. Abrahao   º Data ³  02/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada para evitar que titulos incluidos pelo    º±±
±±º          ³ liquidos BK sejam excluidos por esta rotina                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FA080OWN() 
Local lRet := .T.
Local nOpc := 0

If !lF080Auto
	IF VAL(__CUSERID) == 0 .OR. VAL(__CUSERID) == 12 //.OR. ASCAN(aUser[1,10],cMDiretoria) > 0        
	   lRet := .T.
	ELSE   
		IF TRIM(SE2->E2_XXTIPBK) = "NDB"
		    MsgStop("O cancelamento titulo tipobk = NDB somente está disponível para o Administrador do sistema", "Atenção")
		    lRet := .F.
		ENDIF
	ENDIF
EndIf

// Impede que exclusoes de baixa sejam feitas em data diferente da baixa, para nao causar erros na contabilidade. 
If lRet
	If dDatabase <> SE5->E5_DATA
		nOpc := u_AvisoLog("FA080OWN","Atenção à data",;
					"A data do estorno está diferente da data base do sistema."+Chr(13)+Chr(10)+;
					"Antes de cancelar/excluir a baixa, favor alterar a data base do sistema para "+Dtoc(SE5->E5_DATA)+".",;
					{"Sair","Estornar"}, 2 )
		lRet := (nOpc == 2)
	EndIf
EndIf

Return lRet

