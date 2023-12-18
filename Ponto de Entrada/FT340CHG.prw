#Include "Protheus.ch" 

/*/{Protheus.doc} CNT121LG
BK - Evitar virgunas e pontos nos nomes de arquivos da base de conhecimento
@Return
@author Marcos Bispo Abrahão
@since  09/11/23
@version P122210
/*/

User Function FT340CHG()
Local cName  := AllTrim(ParamIXB[1])   //Nome do Arquivo
Local cName1 := ""
Local cChar  := ""
Local lPonto := .F.

Local nI    := 0
u_MsgLog("FT340CHG",cName)
If "," $ cName
    cName := STRTRAN(cName,",","_")
EndIf
Do While "  " $ cName
    cName := STRTRAN(cName,"  "," ")
EndDo
DO While " ." $ cName
    cName := STRTRAN(cName," .",".")
EndDo
Do While ".." $ cName
    cName := STRTRAN(cName,"..",".")
EndDo

// Remover ponto se houver mais de 1 ponto
cName1 := ""
For nI := Len(cName) To 1 STEP -1
    cChar := SUBSTR(cName,nI,1)
    If cChar == '.'
        If !lPonto
            lPonto := .T.
        Else
            cChar := "_"
        EndIf
    EndIf
    cName1 := cChar+cName1
Next
cName := cName1
Do While "__" $ cName
    cName := STRTRAN(cName,"__","_")
EndDo
u_MsgLog("FT340CHG",cName)
Return cName



