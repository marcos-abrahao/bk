#INCLUDE "PROTHEUS.CH"
 
User Function MT241CAB() 
 
Local oNewDialog  := PARAMIXB[1]     
Local aCp:=Array(2,2) 
Local aTpReq := {}
//Local cTpReq := ""

aCp[1][1] := "D3_XOSHELM" 
aCp[2][1] := "D3_XTRQSC"

//A=Adm;C=Corretiva;D=Docagem;P=Preventiva                                                                                        
aTpReq    := U_StringToArray(GetSx3Cache("D3_XTRQSC", "X3_CBOX"),";")

IF PARAMIXB[2] == 3  
    aCp[1][2] := SPACE(09) 
    aCp[2][2] := aTpReq[1]

    @0.4,48 SAY "OS Helm" OF oNewDialog  
    @0.3,53 MSGET aCp[1][2] SIZE 40,08 OF oNewDialog  

    @0.4,60 SAY "Tp Requisição" OF oNewDialog  
    @0.3,65 COMBOBOX aCp[2][2] ITEMS aTpReq SIZE 50,08 OF oNewDialog  

EndIf
 
return (aCp)
