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

cName := FwNoAccent(cName)

u_MsgLog("FT340CHG",cName)
Return cName

// Acertar nome na base
/*
SELECT ACB.ACB_OBJETO ,*
FROM AC9010 AC9 
LEFT JOIN ACB010 ACB ON ACB.D_E_L_E_T_ = ' '
 AND ACB.ACB_FILIAL = AC9.AC9_FILIAL
 AND ACB.ACB_CODOBJ = AC9.AC9_CODOBJ 
WHERE AC9.D_E_L_E_T_ = '' 
 AND AC9.AC9_FILIAL = '  '
 AND ACB.ACB_OBJETO LIKE 'RIDIMAR%'
 --AND AC9.AC9_ENTIDA = 
 --AND AC9.AC9_CODENT = 

 UPDATE ACB010 SET ACB_OBJETO = 'RIDIMAR1.PDF' WHERE ACB_OBJETO = 'RIDIMAR                                        ,.PDF                                                                                                                                                    '


*/
