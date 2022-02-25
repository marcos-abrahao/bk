#include "rwmake.ch"
#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} StringToArray
BK - Funcao Converter String em array conforme separador informado

@Return Retorna vetor contendo as selecoes feitas, se nao For marcada nenhuma o vetor volta vazio.
@author Adilson do Prado
@since 
@version P12
/*/
//-------------------------------------------------------------------

USER FUNCTION StringToArray( cString, cSeparator )
   LOCAL nPos
   LOCAL aString := {}
   LOCAL cCrLf   		:= Chr(13) + Chr(10)
   DEFAULT cSeparator := ";"

   cString := ALLTRIM( cString ) + cSeparator
   DO WHILE .T.
      nPos := AT( cSeparator, cString )
      IF nPos = 0
         EXIT
      ENDIF
      AADD( aString, ALLTRIM(StrTran(SUBSTR( cString, 1, nPos-1 ),cCrLf,"")) )
      cString := SUBSTR( cString, nPos+LEN(cSeparator) )
   ENDDO
RETURN ( aString )
