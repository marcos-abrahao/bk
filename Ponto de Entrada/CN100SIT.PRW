#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CN100SIT  ºAutor  ³Gilberto Sales      º Data ³  04/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada validação alteração situação do Contrato  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ³Analista/Alterações                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CN100SIT(cNewSituc)
Local aAreas  := GetArea()

dbSelectArea("CN9")
dbSetOrder(1)
If CN9->CN9_FLGCAU == '1' .and. CN9->CN9_SITUAC == '08'
	dbSelectArea("CN8")
	dbSetOrder(2)
	If dbSeek(xFilial("CN8")+CN9->(CN9_NUMERO+CN9_REVISA))
		If Empty(CN8->CN8_DTBX)
			dbSelectArea("CN9")
			dbSetOrder(1)
			//Retorna  a situação para Sol. Finalização
			RecLock("CN9",.F.)
			CN9->CN9_SITUAC := '07'
			msUnlock()
			Aviso("CN100SIT",OemtoAnsi("Contrato com Caução em Aberto, Situacao não pode ser alterada!"),{"Ok"})
		EndIf
	Endif
Endif


dbSelectArea("CN9")
dbSetOrder(1)
If CN9->CN9_SITUAC == '05'
	dbSelectArea("SZG")
	dbSetOrder(1)
	IF !dbSeek(xFilial("SZG")+CN9->CN9_NUMERO,.F.) //+CN9->CN9_REVISA,.F.)
   		MsgStop(OemtoAnsi("Contrato não possui Ficha de Projeção Financeira. Situacao não pode ser alterada!"),"Atenção")
		dbSelectArea("CN9")
		dbSetOrder(1)
		//Retorna  a situação para Sol. Finalização
		RecLock("CN9",.F.)
		CN9->CN9_SITUAC := '02'
		msUnlock()
	ENDIF
Endif

RestArea(aAreas)

Return()