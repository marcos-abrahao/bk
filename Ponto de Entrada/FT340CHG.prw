#Include "Protheus.ch" 

/*/{Protheus.doc} CNT121LG
BK - Evitar virgunas nos nomes de arquivos da base de conhecimento
@Return
@author Marcos Bispo Abrahão
@since  09/11/23
@version P122210
/*/

User Function FT340CHG()
Local cName := ParamIXB[1]   //Nome do Arquivo

If "," $ cName
    cName := STRTRAN(cName,",","_")
EndIf
Return Alltrim(cName)


