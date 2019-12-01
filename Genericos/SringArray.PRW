#include "rwmake.ch"
#Include "Protheus.ch"

//Funcao Converter String em array conforme separador informado

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