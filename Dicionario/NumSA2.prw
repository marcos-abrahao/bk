#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} NumSA2
  Próximo numero de Fornecedor
  @type  Function
  @author Marcos/Adilson
  @since 07/12/2022
  @version 12.1.33
  /*/
  
User Function NumSA2()
Local nPar := 0
Local cPar := ""

nPar := GetMv("MV_XXNUMA2",.F.,"000000")
nPar++
cPar := STRZERO(nPar,6)

PutMv("MV_XXNUMA2",cPar)

/*
IF !SX6->(DBSEEK("  MV_XXNUMA2",.F.))
   RecLock("SX6",.T.)
   SX6->X6_VAR     := "MV_XXNUMA2"
   SX6->X6_TIPO    := "C"
   SX6->X6_DESCRIC := "Numero sequencial Fornecedor "
   SX6->X6_CONTEUD := STRZERO(nI,6)
   SX6->(MsUnlock())
ELSE
  RecLock("SX6",.F.)
  nI := VAL(SX6->X6_CONTEUD) + 1
  SX6->X6_CONTEUD := STRZERO(_nI,6)
  SX6->(MsUnlock())
ENDIF
*/

Return cPar
