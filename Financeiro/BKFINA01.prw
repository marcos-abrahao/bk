#INCLUDE "rwmake.ch"

/*/{Protheus.doc} BKFIN01
BK - Liquidos - Folha BK 
@Return
@author Marcos Bispo Abrahão
@since 28/08/2009
@version P12
/*/

User Function BKFINA01()

Private cString   := "SZ2"
Private cCadastro := "Liquidos - Folha "+FWEmpName(cEmpAnt)
Private aRotina

u_MsgLog("BKFINA01")

dbSelectArea("SZ2")
dbSetOrder(1)
DbGoTop()

aRotina := {{"Pesquisar" ,"AxPesqui"	,0, 1},;
			{"Visualizar","AxVisual"	,0, 2}}
			
//	{"Excluir"   ,"AxDeleta"	,0, 5},;
//	{"Abrir Arq.","U_KK00007A()",0, 6}}

mBrowse(6,1,22,75,cString)

Return
