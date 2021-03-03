

/*/{Protheus.doc} CNCFldEsp
    Ponto de entrada para incluir campos na consulta de clientes na planilha de contratos
    @type  Function
    @author Marcos Bispo Abrahão
    @since 16/12/2020
    @version P12.25
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/


User Function CNCFldEsp()
Local ExpA1     := paramixb[1]
Local ExpA2     := paramixb[2]
Local nI        := 0
Local cCliLj    := ""
Local nPosCnpj  :=aScan(ExpA1,{|x| AllTrim(x[2]) == "CNC_XCNPJ"})
Local nPosMun   :=aScan(ExpA1,{|x| AllTrim(x[2]) == "CNC_XMUN"})
Local nPosCod   :=aScan(ExpA1,{|x| AllTrim(x[2]) == "CNC_CLIENT"})
Local nPosLoja  :=aScan(ExpA1,{|x| AllTrim(x[2]) == "CNC_LOJACL"})

For nI := 1 TO Len(ExpA2)
    cCliLj := ExpA2[nI,nPosCod]+ExpA2[nI,nPosLoja]
    cCnpj  := Posicione("SA1",1,xFilial("SA1")+cCliLj,"A1_CGC")
    If nPosCnpj > 0
        ExpA2[nI,nPosCnpj] := cCnpj
    EndIf
    If nPosMun > 0
        ExpA2[nI,nPosMun] := SA1->A1_MUN
    EndIf
Next

Return {ExpA1,ExpA2}

