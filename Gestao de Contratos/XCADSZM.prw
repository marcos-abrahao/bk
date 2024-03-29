#include "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#include "TopConn.ch"

/*/{Protheus.doc} XCADSZM()
BK - Fluxo de Caixa

@author Adilson do Prado
@since 22/03/16
@version P12
@return Nil
/*/

User Function XCADSZM
Local 	cFiltra     := ""

Private cCadastro	:= "Cadastro Reajuste Projecao Financeira"
Private cDelFunc	:= ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cString 	:= "SZM"
Private aIndexSz  	:= {}
PRIVATE aFixeFX     := {}
Private bFiltraBrw	:= { || FilBrowse(cString,@aIndexSz,@cFiltra) } 
Private aCores  := {}
Private aRotina	:= {}

u_MsgLog("XCADSZM")

AADD(aCores,{"SZM->ZM_STATUS<>'A'","BR_VERDE"})
AADD(aCores,{"SZM->ZM_STATUS=='A'","BR_VERMELHO"})

AADD(aRotina,{"Pesquisa"		,"AxPesquisa",0,1})
AADD(aRotina,{"Visualizar"		,"AxVisual",0,2})
AADD(aRotina,{"Incluir"			,"AxInclui",0,3})
AADD(aRotina,{"Alterar"			,"AxAltera",0,4})
AADD(aRotina,{"Excluir"			,"AxDeleta",0,5})
AADD(aRotina,{"Legenda"			,"U_SZMLEG",0,6})
AADD(aRotina,{"Aplicar Reajuste","U_REAJUSTSZM",0,7})


dbSelectArea(cString)
dbSetOrder(1)
//+------------------------------------------------------------
//| Cria o filtro na MBrowse utilizando a fun��o FilBrowse
//+------------------------------------------------------------
Eval(bFiltraBrw)

dbSelectArea(cString)
dbGoTop()

mBrowse(6,1,22,75,cString,aFixeFX,,,,,aCores)

//+------------------------------------------------
//| Deleta o filtro utilizado na fun��o FilBrowse
//+------------------------------------------------
EndFilBrw(cString,aIndexSz)

Return 


User Function SZMLEG()
Local aCores2 := {}
Local cLegenda := ""

cLegenda	:= "Legenda de Cores"

AADD(aCores2,{"BR_VERDE", "Reajuste n�o aplicado"})
AADD(aCores2,{"BR_VERMELHO", "Reajuste aplicado"})
             		
BrwLegenda(cLegenda,"Status - Reajuste Projecao Financeira",aCores2)

Return 



User Function REAJUSTSZM()

IF SZM->ZM_STATUS == 'A'
   u_MsgLog(,"Reajuste Proje��o Financeira contrato: "+SZM->ZM_CONTRATO+" j�  aplicado","W")
   RETURN NIL
ENDIF

//IF MsgNoYes("Reajustar Proje��o Financeira contrato: "+SZM->ZM_CONTRATO)

//ENDIF

RETURN NIL
