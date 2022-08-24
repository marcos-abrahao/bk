#Include "Protheus.ch" 
/*/{Protheus.doc} MT110CP2
BK - Ponto de entrada - Grid para aprovação de Solicitações de Compras
@Return
@author Marcos Bispo Abrahão
@since 24/08/2022
@version P12.33
/*/

User Function MT110CP2()
Local aAreaSC1 := SC1->(GetArea())
Local aItens   := PARAMIXB[1]
Local oQual    := PARAMIXB[2]
Local aNItens  := {}
Local nX       := 0

// Adiciona titulo da coluna que esta sendo incluída
//AADD(PARAMIXB[2]:AHEADERS,RetTitle("C1_FORNECE"))
PARAMIXB[2]:AHEADERS := {}
AADD(PARAMIXB[2]:AHEADERS,RetTitle("C1_EMISSAO"))
AADD(PARAMIXB[2]:AHEADERS,RetTitle("C1_PRODUTO"))
AADD(PARAMIXB[2]:AHEADERS,RetTitle("C1_DESCRI"))
AADD(PARAMIXB[2]:AHEADERS,RetTitle("C1_UM"))
AADD(PARAMIXB[2]:AHEADERS,RetTitle("C1_QUANT"))
AADD(PARAMIXB[2]:AHEADERS,RetTitle("C1_CC"))
AADD(PARAMIXB[2]:AHEADERS,RetTitle("C1_XXDCC"))
AADD(PARAMIXB[2]:AHEADERS,RetTitle("C1_OBS"))

// Adiciona campo da coluna que esta sendo incluída
cNumSC := SC1->C1_NUM
DbSelectArea("SC1")
DbSetOrder(1)
For nX := 1 To Len(PARAMIXB[2]:AARRAY)
    MsSeek(xFilial("SC1")+cNumSC)
    Do While !Eof() .And. C1_FILIAL == xFilial("SC1") .And. C1_NUM == cNumSc
       If C1_PRODUTO == PARAMIXB[2]:AARRAY[nX][1] .And. ;
          C1_UM  == PARAMIXB[2]:AARRAY[nX][2] .And. ;
          C1_QUANT == PARAMIXB[2]:AARRAY[nX][3] .And. ;
          C1_OBS  == PARAMIXB[2]:AARRAY[nX][4] .And. ;
          C1_EMISSAO == PARAMIXB[2]:AARRAY[nX][5] .And. ;
          C1_DESCRI == PARAMIXB[2]:AARRAY[nX][6] .And. ;
          C1_FILENT == PARAMIXB[2]:AARRAY[nX][7]
          //AADD(PARAMIXB[2]:AARRAY[nX],SC1->C1_FORNECE)
          AADD(aNItens,{SC1->C1_EMISSAO,SC1->C1_PRODUTO,SC1->C1_DESCRI,SC1->C1_UM,SC1->C1_QUANT,SC1->C1_CC,SC1->C1_XXDCC,SC1->C1_OBS})

          Exit
        EndIf
        DbSkip()
    EndDo
Next nX

// Redefine bLine do objeto oQual inlcuindo a coluna nova
//aItens := PARAMIXB[2]:AARRAY

aItens := aClone(aNItens)
PARAMIXB[2]:bLine := { || {aItens[oQual:nAT][1],aItens[oQual:nAT][2],aItens[oQual:nAT][3],aItens[oQual:nAT][4],aItens[oQual:nAT][5],aItens[oQual:nAT][6],aItens[oQual:nAT][7],aItens[oQual:nAT][8]}}
// 1-Produto; 2-Unid.Medida; 3-Quantidade; 4-Obs.; 5-Dt.Emissao; 6-Descricao; 7-Fil.Entrega

RestArea(aAreaSC1)

Return Nil

