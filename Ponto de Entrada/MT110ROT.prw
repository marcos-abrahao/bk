#include "protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MT110ROT
criar opções nas ações relacionados da Solicitação de Compras - BK

@Return aRotina
@author Marcos Bispo Abrahão
@since 04/07/2019
@version P11
/*/
//-------------------------------------------------------------------


User Function MT110ROT()

//Define Array contendo as Rotinas a executar do programa     
// ----------- Elementos contidos por dimensao ------------    
// 1. Nome a aparecer no cabecalho                             
// 2. Nome da Rotina associada                                 
// 3. Usado pela rotina                                        
// 4. Tipo de Transa‡„o a ser efetuada                         
//    1 - Pesquisa e Posiciona em um Banco de Dados            
//    2 - Simplesmente Mostra os Campos                        
//    3 - Inclui registros no Bancos de Dados                  
//    4 - Altera o registro corrente                           
//    5 - Remove o registro corrente do Banco de Dados         
//    6 - Altera determinados campos sem incluir novos Regs     
//AAdd( aRotina, { 'Documento', 'MsDocument('SC1', SC1->(recno()), 4)', 0, 4 } )

AADD( aRotina, {OemToAnsi("Alt. Valor Lic."), "U_MT110VLC", 0, 4 } )

Return aRotina


User function MT110VLC
Local _sAlias	:= Alias()
Local oDlg01,aButtons := {},lOk := .F.
Local aAreaAtu	:= GetArea()
Local aAreaSY1  := SY1->(GetArea())
Local nSnd,nTLin := 12
Local nXXLCVAL := SC1->C1_XXLCVAL
Local cPict := GetSX3Cache("C1_XXLCVAL","X3_PICTURE")
  
SY1->(dbgotop())
Do While SY1->(!eof())                                                                                                               
	If SY1->Y1_USER == __cUserId
		lOk := .T.
		Exit
	EndIf
    SY1->(dbskip())
Enddo

SY1->(RestArea( aAreaSY1 ))

If !lOk
	MsgStop("Usuário não é um comprador (SY1)!","MT110VLC")
	
Else	
	
	lOk := .F.
	
	Define MsDialog oDlg01 Title "MT110VLC-Alt. Valor Licitado: "+SC1->C1_NUM+"/"+SC1->C1_ITEM  From 000,000 To 150,300 Of oDlg01 Pixel
	
	nSnd := 30
	@ nSnd,010 Say "Informe o valor licitado:"  Size 080,008 Pixel Of oDlg01
	@ nSnd,080 MsGet nXXLCVAL Picture cPict     Size 060,008 Pixel Of oDlg01 HASBUTTON
	nSnd += nTLin
	
	
	ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:=.T., oDlg01:End()},{|| oDlg01:End()}, , aButtons)
	If ( lOk )
		IF SC1->C1_XXLCVAL <> nXXLCVAL
			RecLock("SC1",.F.)
			SC1->C1_XXLCVAL := nXXLCVAL
			SC1->C1_XXLCTOT := NoRound(nXXLCVAL * SC1->C1_QUANT,TamSX3("C1_XXLCTOT")[2])                         
			msUnlock()
		ENDIF
	EndIf
	
EndIf

RestArea( aAreaAtu )
dbSelectArea(_sAlias)

Return lOk
