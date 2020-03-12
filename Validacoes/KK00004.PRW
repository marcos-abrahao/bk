#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³KK00004   ºAutor  ³Gilberto Sales       º Data ³  22/08/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela para geraçao do codigo do contrato padrao BK           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºData      ³Analista/Alterações                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±º  /  /    ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 

// Chamado no gatilho do campo CN9_CLIENT

User Function KK00004()

Local cQuery    := ""
Local _xRetorno := ""
Local _aAreas 	:= {}

       
If (ReadVar() == "M->CN9_CLIENT")

	//Código do Contrato
	cQuery := " "
	cQuery := "SELECT MAX("+M->CN9_CLIENT+" CASE WHEN LEN(SUBSTRING("+M->CN9_NUMERO+",7,3)) = 1 THEN '00'+CAST(SUBSTRING("+M->CN9_NUMERO+",7,3) AS CHAR(3)) "
	cQuery += " WHEN LEN(SUBSTRING("+M->CN9_NUMERO+",7,3)) = 2 THEN '00'+CAST(SUBSTRING("+M->CN9_NUMERO+",7,3) AS CHAR(3)) "
	cQuery += " ELSE CAST(SUBSTRING(CN9_NUMERO,7,3)AS CHAR(3))  END) + 1 AS NUM "
	cQuery += " FROM " + RetSqlName("CN9")+" "
	cQuery += " WHERE CN9_CLIENT ='"+M->CN9_CLIENT+"' "

	If SELECT("TRB") > 0
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf

	TCQuery cQuery NEW ALIAS "TRB"

	dbSelectArea("TRB")
	_xRetorno := TRB->NUM

EndIf

//Restaura as áreas
RestArea(_aAreas)

Return(_xRetorno)