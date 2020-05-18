#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN040EXC
BK - Excluir Nota de Débito Cliente
@Return
@author Marcos Bispo Abrahao
@since 15/10/2019
@version P11
/*/
//-------------------------------------------------------------------

USER Function FIN040EXC(nRecCND)  	 
Local aAreas    := GetArea()
Local aArray 	:= {}
Local cCliente 	:= ""
Local cLoja    	:= ""
Local cSql      := ""
Local cAliasSZ2 := GetNextAlias()

Private lMsErroAuto := .F. 

Default nRecCND := 0

//Posiciona na Medição
DBSELECTAREA("CND")
dbGoTo(nRecCND)

If nRecCND > 0 .AND.!Empty(CND->CND_XXNDC)
	
	cCliente := CND->CND_CLIENT
	cLoja    := CND->CND_LOJACL

	aArray := { { "E1_PREFIXO"  , "ND "  , NIL },;
	            { "E1_NUM"      , CND->CND_XXNDC, NIL },;
	            { "E1_PARCELA"  , SPACE(TamSx3("E1_PARCELA")[1]), NIL },;
	            { "E1_TIPO"     , "NDC"     , NIL }}

//	            { "E1_CLIENTE"  , cCliente  , NIL },;
//	            { "E1_LOJA"     , cLoja 	, NIL },;
	 
	MsExecAuto( { |x,y| FINA040(x,y)} , aArray, 5)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
	
	If lMsErroAuto		
		MsgStop("Erro na exclusão da Nota de Débito "+CND->CND_XXNDC)	
		MostraErro() 
	Else

		If !Empty(CND->CND_XXNDC)
			cSql := "SELECT Z2_NDC,R_E_C_N_O_ AS Z2_RECNO "
			cSql += "FROM SZ2010 SZ2 "
			cSql += "WHERE SZ2.D_E_L_E_T_='' "
			cSql += " AND Z2_NDC='"+CND->CND_XXNDC+"' "
			cSql += "ORDER BY Z2_NOME "
				
			TCQUERY cSql NEW ALIAS (cAliasSZ2)
				
			dbSelectArea(cAliasSZ2)
			(cAliasSZ2)->(DbGotop()) 
			Do WHile !(cAliasSZ2)->(EOF())
				dbSelectArea("SZ2")
				dbGoTo((cAliasSZ2)->Z2_RECNO)
				RecLock("SZ2",.F.)
				SZ2->Z2_NDC    := ""
				SZ2->Z2_VALNDC := 0
				MsUnLock()
						
				(cAliasSZ2)->(dbSkip())
			EndDo
			(cAliasSZ2)->(DbCloseArea())	 
		EndIf	

		MsgInfo("Nota de débito "+CND->CND_XXNDC+" excluída.")	
	EndIf
EndIf

RestArea(aAreas)

Return

