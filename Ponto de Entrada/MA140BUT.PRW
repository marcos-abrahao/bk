#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MA140BUT
BK - Ponto de Entrada para incluir botão na enchoice da Pré-Nota
@Return
@author Marcos Bispo Abrahão
@since 16/07/24
@version P12
/*/

User Function MA140BUT()
Local aBotao := {}

aBotao := {{"BK Incluir Itens",{|| U_I140Itens()},"Incluir Itens via copia e cola"}}

Return aBotao


User Function I140Itens()
Local yCol := {}

u_MsgLog("I140Itens","Incluir Itens","I")

yCol := aClone(aCols[1])
yCol[1] := STRZERO(Len(aCols)+1,4)

aAdd(aCols,yCol)

Return Nil
