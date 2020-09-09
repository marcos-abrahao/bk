#include "rwmake.ch"




/*/{Protheus.doc} FT340TAM
BK - FT340TAM - Controlar tamanho do arquivo
Ponto de Entrada utilizado para controlar o tamanho do arquivo que o usuário importa para o sistema por meio da rotina Banco de Conhecimento.

@Return
@author Marcos Bispo Abrahão
@since 
@version P12
/*/

User Function FT340TAM()
Local aFiles := ParamIXB[1]
Local lRet := .T.
Local nI := 0
For nI := 1 To Len(aFiles)
    X:= 0
Next


Return lRet

