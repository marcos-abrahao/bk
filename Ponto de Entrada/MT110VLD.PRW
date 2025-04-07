#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} MT110VLD  
    Ponto de Entrada: Valida usuário para alteração e Exclusão Solicitação de Compras 
 
    @type  Function
    @author Adilson do Prado
    @since 07/05/13
    @version
    @param 
    @return 
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function MT110VLD()
Local ExpN1     := Paramixb[1]
Local lValido   := .T.
Local lGCOM		:= .F. 

dbSelectArea("SAJ")
dbSetOrder(2)
IF dbSeek(xFilial("SAJ")+__cUserId,.F.)
	lGCOM := .T.
EndIf


IF ExpN1== 4
	IF SC1->C1_USER <> __cUserId  .AND.  SC1->C1_USER <> '' .AND. __cUserId <> "000000" .AND. !lGCOM
		u_MsgLog('MT110VLD','Solicitação não pode ser Alterada por outro usuário',"E")
		lValido := .F.        
	EndIf
ENDIF

IF ExpN1 == 6
	IF SC1->C1_USER <> __cUserId  .AND.  SC1->C1_USER <> '' .AND. __cUserId <> "000000"
		u_MsgLog('MT110VLD','Solicitação não pode ser Excluida por outro usuário',"E")
		lValido := .F.        
	EndIf
ENDIF

Return(lValido)
