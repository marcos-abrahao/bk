#INCLUDE "Protheus.ch"
#INCLUDE "topconn.ch"                     

// Numera玢o CND - 29/06/20 - Marcos

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
北谀哪哪哪哪穆哪哪哪哪哪哪履哪哪哪履哪哪哪哪哪哪哪哪哪哪履哪哪穆哪哪哪哪哪目北
北矲un噭o    矯N130NumMd  � Autor � Felipe Bittar       � Data �24/09/2008 潮�
北媚哪哪哪哪呐哪哪哪哪哪哪聊哪哪哪聊哪哪哪哪哪哪哪哪哪哪聊哪哪牧哪哪哪哪哪拇北
北矰escricao 砎alidacao da numeracao da Medicao do Contrato                潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砇etorno   � Logico                                                      潮�
北媚哪哪哪哪呐哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪拇北
北砋so       � CNTA130						                               潮�
北滥哪哪哪哪牧哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪哪馁北
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌*/
/*

Fu玢o original
Function CN130NumMd()

Local aArea		:= GetArea()
Local aAreaCND	:= CND->(GetArea())
Local cNumMed   := ""

cNumMed:=GetSxENum("CND","CND_NUMMED")
nSaveSX8  := 1

dbSelectArea("CND")
dbSetOrder(4)
dbGoTop()

While CND->( msSeek(xFilial("CND")+cNumMed) )
	If ( __lSx8 )
		ConfirmSX8()
	EndIf
	cNumMed:=GetSxENum("CND","CND_NUMMED")
EndDo

RestArea(aAreaCND)
RestArea(aArea)

Return( cNumMed )
*/



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

cQuery := " SELECT CND_NUMMED FROM "+RETSQLNAME("CND")+" CND WHERE CND_NUMMED = '"+cNumMed+"' "
cQuery += " AND CND.D_E_L_E_T_ = '' "

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTmpAlias, .F., .T.)

dbSelectArea(cTmpAlias)
dbGoTop()
lRet := !EOF()

(cTmpAlias)->(dbCloseArea())

Return lRet

