#include "rwmake.ch"

/*/{Protheus.doc} CN100SIT
BK - Ponto de Entrada valida��o altera��o situa��o do Contrato
@Return
@author Gilberto Sales
@since 04/09/08
@version P10
/*/

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
			//Retorna  a situa��o para Sol. Finaliza��o
			RecLock("CN9",.F.)
			CN9->CN9_SITUAC := '07'
			msUnlock()
			u_MsgLog("CN100SIT","Contrato com Cau��o em Aberto, Situacao n�o pode ser alterada!","E")
		EndIf
	Endif
Endif


dbSelectArea("CN9")
dbSetOrder(1)
If CN9->CN9_SITUAC == '05'
	dbSelectArea("SZG")
	dbSetOrder(1)
	IF !dbSeek(xFilial("SZG")+CN9->CN9_NUMERO,.F.) //+CN9->CN9_REVISA,.F.)
   		u_MsgLog("CN100SIT","Contrato n�o possui Ficha de Proje��o Financeira. Situacao n�o pode ser alterada!","W")
		dbSelectArea("CN9")
		dbSetOrder(1)
		//Retorna  a situa��o para Sol. Finaliza��o
		RecLock("CN9",.F.)
		CN9->CN9_SITUAC := '02'
		msUnlock()
	ENDIF
Endif

RestArea(aAreas)

Return()
