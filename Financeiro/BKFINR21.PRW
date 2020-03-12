#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BKFINR21 Autor Adilson Prado                Data ³01/08/17 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Bloqueio ou Desbloqueio judicial                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BKFINR21()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local aTitulos,aCampos,aCabs
Local cTitulo   := "Bloqueio ou Desbloqueio judicial"

Private nomeprog    := "BKFINR21" 
Private cPerg       := "BKFINR21"
Private wnrel       := "BKFINR21" 
Private dEMISI  	:= CTOD("")
Private dEMISF  	:= CTOD("")
Private cBanco    	:= ""
Private cAgencia  	:= "" 
Private cConta	  	:= "" 
Private cProcesso 	:= "" 
Private cReclamante	:= "" 


ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
Endif

dEMISI    := mv_par01
dEMISF    := mv_par02
cBanco    := mv_par03
cAgencia  := mv_par04 
cConta	  := mv_par05 
//cProcesso := mv_par06 
//cReclamante	  := mv_par07 

IF !EMPTY(dEMISI) 
	cTitulo   += " - Data de: "+DTOC(dEMISI)
ENDIF
IF !EMPTY(dEMISI) .AND. !EMPTY(dEMISF) 
	cTitulo   += " até: "+DTOC(dEMISF)
ELSEIF !EMPTY(dEMISF) 
	cTitulo   += " - Data até: "+DTOC(dEMISF)
ENDIF
IF !EMPTY(cBanco)
	cTitulo   += " - Banco: "+cBanco+" Agencia: "+cAgencia+" Conta: "+cConta
ENDIF

ProcRegua(1)
Processa( {|| ProcQuery() })

aCabs   := {}
aCampos := {}
aTitulos:= {}
  
nomeprog := "BKFINR21/"+TRIM(SUBSTR(cUsuario,7,15))
AADD(aTitulos,nomeprog+" - "+cTitulo)

AADD(aCampos,"QSZO->ZO_DATA")
AADD(aCabs  ,"Data")

AADD(aCampos,"QSZO->ZO_CODIGO")
AADD(aCabs  ,"Codigo Banco")

AADD(aCampos,"QSZO->ZO_AGENC")
AADD(aCabs  ,"Agencia Banco")

AADD(aCampos,"QSZO->ZO_CONTA")
AADD(aCabs  ,"Conta Banco")

AADD(aCampos,"QSZO->ZO_PROCES")
AADD(aCabs  ,"Proc. Judicial")

AADD(aCampos,"QSZO->ZO_VARA")
AADD(aCabs  ,"Vara Judicial")

AADD(aCampos,"QSZO->ZO_TRIB")
AADD(aCabs  ,"Tribunal")

AADD(aCampos,"QSZO->ZO_RECLAM") 
AADD(aCabs  ,"Reclamante")


AADD(aCampos,"IIF(QSZO->ZO_TIPO=='B',QSZO->ZO_VALOR,0)")
AADD(aCabs  ,"Bloqueio")

AADD(aCampos,"IIF(QSZO->ZO_TIPO=='D',QSZO->ZO_VALOR,0)")
AADD(aCabs  ,"Desbloqueio")


ProcRegua(QSZO->(LASTREC()))
Processa( {|| U_GeraCSV("QSZO",wnrel,aTitulos,aCampos,aCabs)})
   
Return


Static Function ProcQuery
Local cQuery

IncProc("Consultando o banco de dados...")

cQuery := " SELECT * "
cQuery += " FROM "+RetSqlName("SZO")+" SZO" 
cQuery += " WHERE SZO.D_E_L_E_T_=''"

IF !EMPTY(dEMISI)
	cQuery += " AND ZO_DATA>='"+DTOS(dEMISI)+"'"
ENDIF

IF !EMPTY(dEMISF)
	cQuery += " AND ZO_DATA<='"+DTOS(dEMISF)+"'"
ENDIF

IF !EMPTY(cBanco)
	cQuery += " AND ZO_CODIGO='"+ALLTRIM(cBanco)+"'"
ENDIF

IF !EMPTY(cAgencia)
	cQuery += " AND ZO_AGENC='"+ALLTRIM(cAgencia)+"'"
ENDIF

IF !EMPTY(cConta)
	cQuery += " AND ZO_CONTA='"+ALLTRIM(cConta)+"'"
ENDIF

cQuery += " ORDER BY ZO_CODIGO,ZO_AGENC,ZO_CONTA,ZO_DATA"  

TCQUERY cQuery NEW ALIAS "QSZO"
TCSETFIELD("QSZO","ZO_DATA","D",8,0)

Return


Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Data de:"   ,"" ,"" ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Data até:"  ,"" ,"" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Banco:"     ,"" ,"" ,"mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","SA6","S","",""})
AADD(aRegistros,{cPerg,"04","Agencia :"  ,"" ,"" ,"mv_ch4","C",05,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"05","Conta"      ,"" ,"" ,"mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
//AADD(aRegistros,{cPerg,"06","Processo"   ,"" ,"" ,"mv_ch6","C",20,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
//AADD(aRegistros,{cPerg,"07","Reclamante" ,"" ,"" ,"mv_ch7","C",80,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})


For i:=1 to Len(aRegistros)
	If !dbSeek(cPerg+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegistros[i])
				FieldPut(j,aRegistros[i,j])
			Endif
		Next
		MsUnlock()
	//Else	
	//	RecLock("SX1",.F.)
	//	For j:=1 to FCount()
	//		If j <= Len(aRegistros[i])
	//			FieldPut(j,aRegistros[i,j])
	//		Endif
	//	Next
	//	MsUnlock()
	Endif
Next

RestArea(aArea)

Return(NIL)

