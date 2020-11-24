#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} BKParam
Generico - Substituir SuperGetMv e GetMv 
@Return
@author Marcos Bispo Abrahão
@since 27/04/2020
@version P12
/*/

//SUPERGETMV( <nome do parâmetro>, <lHelp>, <cPadrão>, <Filial do sistema> )

User Function BKGetMv(_cPar,_lHelp,_xPadrao,_cFil,_cEmp)

Local aArea         := GetArea()
Local xRet          := Nil
Local nTam          := 0
Default _lHelp      := .F.
Default _xPadrao    := ""
Default _cFil       := "  "
Default _cEmp       := "  "

dbSelectArea("SZX")

If !dbSeek(_cFil+_cEmp+_cPar,.F.)
    If SX6->(DBSEEK(_cFil+_cPar,.F.))
        RecLock("SZX",.T.)
        SZX->ZX_FILIAL  := _cFil
        SZX->ZX_EMPRESA := _cEmp
        SZX->ZX_VAR     := _cPar
        SZX->ZX_TIPO    := SX6->X6_TIPO
        SZX->ZX_TAMANHO := 0
        SZX->ZX_DECIMAL := 0
        SZX->ZX_DESCR   := SX6->X6_DESCRIC
        SZX->ZX_CONTE01 := SX6->X6_CONTEUD
        MsUnLock()
    EndIf
EndIf

If dbSeek(_cFil+_cEmp+_cPar,.F.)
    nTam := SZX->ZX_TAMANHO
    If SZX->ZX_TIPO == "C"
        If nTam == 0
            xRet := ALLTRIM(SZX->ZX_CONTE01)+ALLTRIM(SZX->ZX_CONTE02)+ALLTRIM(SZX->ZX_CONTE03)
        Else
            xRet := PAD(ALLTRIM(SZX->ZX_CONTE01)+ALLTRIM(SZX->ZX_CONTE02)+ALLTRIM(SZX->ZX_CONTE03),nTam)
        EndIf
    ElseIf SZX->ZX_TIPO == "D"
        If "/" $ SZX->ZX_CONTE01
            xRet := CTOD(ALLTRIM(SZX->ZX_CONTE01))
        Else
            xRet := STOD(ALLTRIM(SZX->ZX_CONTE01))
        EndIf
        If Empty(xRet)
            xRet := CTOD("")
        EndIf
    ElseIf SZX->ZX_TIPO == "N"
        xRet := VAL(ALLTRIM(SZX->ZX_CONTE01))
    ElseIf SZX->ZX_TIPO == "L"
        xRet := IIF("T" $ UPPER(SZX->ZX_CONTE01),.T.,.F.)
    EndIf
Else 
    xRet := _xPadrao
EndIf

RestArea(aArea)

Return xRet



User Function BKPutMv(_cPar,_xConteudo,_cTipo,_nTam,_nDec,_cDescr,_cFil,_cEmp)

Local aArea         := GetArea()
Local xConte01      := ""

Default _cTipo      := "C"
Default _cDescr     := ""
Default _cFil       := "  "
Default _cEmp       := "  "

dbSelectArea("SZX")

If dbSeek(_cFil+_cEmp+_cPar,.F.)
   RecLock("SZX",.F.)
   _cTipo := SZX->ZX_TIPO
   _nTam  := SZX->ZX_TAMANHO
   _nDec  := SZX->ZX_DECIMAL
Else
   RecLock("SZX",.T.)
   SZX->ZX_FILIAL  := _cFil
   SZX->ZX_EMPRESA := _cEmp
   SZX->ZX_VAR     := _cPar
   SZX->ZX_TIPO    := _cTipo
   SZX->ZX_TAMANHO := _nTam
   SZX->ZX_DECIMAL := _nDec
   SZX->ZX_DESCR   := _cDescr
EndIf

If _cTipo == "N"
    If _nTam > 0
        xConte01 := ALLTRIM(STR(_xConteudo,_nTam,_nDec))
    Else
        xConte01 := ALLTRIM(STR(_xConteudo))
    EndIf
ElseIf _cTipo == "D"
    xConte01 := DTOS(_xConteudo)
ElseIf _cTipo == "L"
    xConte01 := IIF(_xConteudo,".T.",".F.")
Else
    xConte01 := _xConteudo
EndIf

SZX->ZX_CONTE01 := xConte01
MsUnLock()  

RestArea(aArea)

Return Nil

