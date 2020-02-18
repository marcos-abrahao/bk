#Include "Protheus.ch"

// Validar data de vencimento superior a database - Marcos 13/02/20 - Solicitado por Laudecir e Xavier

User FuncTion MT103FIN

Local aLocHead := PARAMIXB[1]      // aHeader do getdados apresentado no folter Financeiro.
Local aLocCols := PARAMIXB[2]      // aCols do getdados apresentado no folter Financeiro.
Local lRet     := PARAMIXB[3]      // Retorno
Local nPVenc   := aScan(aLocHead,{|x| AllTrim(x[2])=="E2_VENCTO"})
Local nX       := 0

If (INCLUI .Or. ALTERA) .And. lRet
    For nX := 1 TO LEN(aLocCols)
        If aLocCols[nX][nPVenc] < dDataBase
            MsgAlert("A data de vencimento ("+DTOC(aLocCols[nX][nPVenc])+") não pode ser inferior a data base!","MT103FIN")
            lRet := .F.
        EndIf
    NEXT
EndIf
Return(lRet)
