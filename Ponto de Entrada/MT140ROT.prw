#include "rwmake.ch"

/*/{Protheus.doc} MT140ROT
BK - Ponto de Entrada para criar botões na pre-nota
@Return
@author Marcos Bispo Abrahão
@since 24/11/2009
@version P12
/*/

User Function MT140ROT()
//AADD( aRotina, {OemToAnsi("Conhecimento "+ALLTRIM(SM0->M0_NOME)), "U_MT140DOCBK", 0, 4 } )
AADD( aRotina, {OemToAnsi("Benefícios "+ALLTRIM(SM0->M0_NOME)), "U_BKCOMA03", 0, 4 } )
AADD( aRotina, {OemToAnsi("Dados Pgto "+ALLTRIM(SM0->M0_NOME)), "U_AltFPgto", 0, 4 } )
Return Nil


User function MT140DOCBK
Local _nReg
Private cCadastro := "Teste msDocument"
Dbselectarea("SF1")
Dbsetorder(1)
_nReg:=Recno()
MsDocument("SF1",_nReg,6)
Return
