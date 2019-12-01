#include "protheus.ch"



User Function CT102BUT()
Local aBotao := {}
/*
O Layout do array aBotao deve sempre respeitar os itens abaixo:

[n][1]=Título da rotina que será exibido no menu
[n][2]=Função que será executada
[n][3]=Parâmetro reservado, deve ser sempre 0 ( zero )
[n][4]=Número da operação que a função vai executar sendo :

1=Pesquisa
2=Visualização
3=Inclusão
4=Alteração
5=Exclusão
*/

aAdd(aBotao, {'Filtro Historico',"U_BKCTB02", 0 , 3 })
Return(aBotao)

User Function BKCTB02()
Local oDlg,oPanelLeft,oSay1,oTexto
Local aButtons := {}
Local nLin 
Local oBrowse := GetObjBrow()// Seta o filtro para o browse
Static cTexto := SPACE(30)
Static lOk1 := .T.

If !lOk1
   lOk1 := .T.
   Return
EndIf

Private cFilt,xVar

DEFINE MSDIALOG oDlg TITLE "Filtro para o histórico" FROM 000,000 TO 100,320 PIXEL 

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 320,225
oPanelLeft:Align := CONTROL_ALIGN_LEFT

nLin := 15

@ nLin, 010 SAY oSay1 PROMPT "Texto:" SIZE 040, 010 OF oPanelLeft PIXEL
@ nLin, 060 MSGET oTexto  VAR cTexto    SIZE 070, 010 OF oPanelLeft PIXEL

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk1:=.T., oDlg:End()},{|| lOk1:=.F.,oDlg:End()}, , aButtons)

//dbSelectArea("CT2")
//dbSetOrder(0)
//dbClearFilter()

If ( lOk1 )
	If !EMPTY(cTexto)
		cFilt := " CT2_HIST LIKE '%"+ALLTRIM(cTexto)+"%'"          	 
		SetMBTopFilter("CT2", cFilt, .T.)// Atualiza as informações do browse
	Else
		cFilt := ""
		SetMBTopFilter("CT2", cFilt, .T.)// Atualiza as informações do browse

		//cExpFilter := "" 
		//aIndex := {} 
		//EndFilBrw( "CT2" , @aIndex ) 
		//CT2->( dbClearFilter() ) 
		//bFiltraBrw := { || FilBrowse( "CT2" , @aIndex , @cExpFilter ) } 
		//Eval( bFiltraBrw ) 

	EndIf
	oBrowse:ResetLen()
	oBrowse:Gotop()
	oBrowse:Refresh()

	//cFilt := ' dbSetFilter( { || '+cFilt+" },'"+cFilt+"')"
	//xVar := &(cFilt)
Endif
 

lOk1 := .F.
//RestArea(aAreaIni)
Return .T.
