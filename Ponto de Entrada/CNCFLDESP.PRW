

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
Local aRetCol   := {}
Local nI        := 0
Local cCliLj    := ""

Local nPosCod   :=aScan(ExpA1,{|x| AllTrim(x[2]) == "CNC_CLIENT"})
Local nPosLoja  :=aScan(ExpA1,{|x| AllTrim(x[2]) == "CNC_LOJACL"})

If nPosCod > 0
    aAdd(ExpA1,DefAHeader("A1_CGC"))
    aAdd(ExpA1,DefAHeader("A1_MUN"))
    For nI := 1 TO Len(ExpA2)
        cCliLj := ExpA2[nI,nPosCod]+ExpA2[nI,nPosLoja]
        cCnpj  := Posicione("SA1",1,xFilial("SA1")+cCliLj,"A1_CGC")
        aAdd(aRetCol,{ExpA2[nI,1],ExpA2[nI,2],ExpA2[nI,3],cCNPJ,SA1->A1_MUN,.F. })
    Next
EndIf

Return {ExpA1,aRetCol}


Static Function DefAHeader(_cCampo)

Return {Alltrim(RetTitle(_cCampo)),;
        _cCampo,;
        GetSx3Cache( _cCampo , "X3_PICTURE" ),;
        GetSx3Cache( _cCampo , "X3_TAMANHO" ),;
        GetSx3Cache( _cCampo , "X3_DECIMAL" ),;
        GetSx3Cache( _cCampo , "X3_VALID" ),;
        "",;
        GetSx3Cache( _cCampo , "X3_TIPO" ),;
        GetSx3Cache( _cCampo , "X3_PICTVAR" ),;
        "R"}
