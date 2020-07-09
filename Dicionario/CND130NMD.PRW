#INCLUDE "Protheus.ch"
#INCLUDE "topconn.ch"                     

// Numera��o CND - 29/06/20 - Marcos

/*
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �CN130NumMd  � Autor � Felipe Bittar       � Data �24/09/2008 ���
��������������������������������������������������������������������������Ĵ��
���Descricao �Validacao da numeracao da Medicao do Contrato                ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � Logico                                                      ���
��������������������������������������������������������������������������Ĵ��
���Uso       � CNTA130						                               ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������*/
User Function CN130NMd()

Local aArea		:= GetArea()
Local aAreaCND	:= CND->(GetArea())
Local cNumMed   := ""

//cNumMed:=GetSxENum("CND","CND_NUMMED")
cNumMed:=GetSXENum("CND","CND_NUMMED","CND_NUMBK")
nSaveSX8  := 1

dbSelectArea("CND")
dbSetOrder(4)
dbGoTop()


//While CND->( msSeek(xFilial("CND")+cNumMed) )
Do While IsCnd(cNumMed)

	If ( __lSx8 )
		ConfirmSX8()
	EndIf
//	cNumMed:=GetSxENum("CND","CND_NUMMED")
    cNumMed := GetSXENum("CND","CND_NUMMED","CND_NUMBK")

EndDo

RestArea(aAreaCND)
RestArea(aArea)

Return( cNumMed )


STATIC FUNCTION IsCnd(cNumMed)
Local cQuery
Local lRet := .F.
Local cTmpAlias := GetNextAlias()

cQuery := " SELECT CND_NUMMES FROM "+RETSQLNAME("CND")+" CND WHERE CND_NUMMED = '"+cNumMed+"' "
cQuery += " AND CND.D_E_L_E_T_ = ' ' "

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTmpAlias, .F., .T.)

dbSelectArea(cTmpAlias)
dbGoTop()
lRet := !EOF()

(cTmpAlias)->(dbCloseArea())

Return lRet
