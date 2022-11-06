#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKCOMR14
BK - Relação de Documentos de Entrada
@Return
@author Marcos Bispo Abrahão
@since 25/03/2022
@version P12.1.33
/*/

User Function BKCOMR14()

Local aTitulos,aCampos,aCabs,aPlans,aFormula

Private cTitulo      := "Relação de Documentos de Entrada"
Private cPerg        := "BKCOMR14"
Private dDataI,dDataF,cUsr3,nOrdP

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
Endif
u_MsgLog(cPerg)

dDataI := mv_par01
dDataF := mv_par02
cUsr3  := mv_par03
nOrdP  := mv_par04

ProcRegua(1)
Processa( {|| ProcQuery() })

aCabs   := {}
aCampos := {}
aTitulos:= {}
aPlans  := {}
aFormula:= {}
   
AADD(aTitulos,cTitulo)

AADD(aCampos,"QSF1->F1EMPRESA")
AADD(aCabs  ,"Empresa")

AADD(aCampos,"QSF1->F1NOMEEMP")
AADD(aCabs  ,"Nome Emp.")

AADD(aCampos,"QSF1->F1_STATUS")
AADD(aCabs  ,FWX3Titulo("F1_STATUS"))

AADD(aCampos,"QSF1->F1_DTDIGIT")
AADD(aCabs  ,FWX3Titulo("F1_DTDIGIT"))

AADD(aCampos,"QSF1->F1_DOC")
AADD(aCabs  ,FWX3Titulo("F1_DOC"))

AADD(aCampos,"QSF1->F1_SERIE")
AADD(aCabs  ,FWX3Titulo("F1_SERIE"))

AADD(aCampos,"QSF1->F1_ESPECIE")
AADD(aCabs  ,FWX3Titulo("F1_ESPECIE"))

AADD(aCampos,"QSF1->F1_EMISSAO")
AADD(aCabs  ,FWX3Titulo("F1_EMISSAO"))

AADD(aCampos,"QSF1->F1_FORNECE")
AADD(aCabs  ,FWX3Titulo("F1_FORNECE"))

AADD(aCampos,"QSF1->F1_LOJA")
AADD(aCabs  ,FWX3Titulo("F1_LOJA"))

AADD(aCampos,"QSF1->A2_NOME")
AADD(aCabs  ,FWX3Titulo("A2_NOME"))

AADD(aCampos,"QSF1->F1_VALBRUT")
AADD(aCabs  ,FWX3Titulo("F1_VALBRUT"))

AADD(aCampos,"UsrRetName(QSF1->F1_XXUSER)")
AADD(aCabs  ,FWX3Titulo("F1_XXUSER"))

AADD(aCampos,"UsrRetName(QSF1->F1_XXULIB)")
AADD(aCabs  ,FWX3Titulo("F1_XXULIB"))

/*
// Alterar estilo
dbSelectArea("QSF1")
dbGoTop()
Do While !Eof()
    If QSF1->XX_LIBEROK=='Nao Liberado'
        AADD(aFormula,{QSF1->(RECNO()),"QSF1->XX_LIBEROK","","S1","",""})
    Else
        AADD(aFormula,{QSF1->(RECNO()),"QSF1->XX_LIBEROK","","S2","",""})
    EndIf
    dbSkip()
EndDo
*/
AADD(aPlans,{"QSF1",cPerg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, aFormula,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
U_PlanXlsx(aPlans,cTitulo,cPerg,.T.)
 

Return


Static Function ProcQuery
Local cQuery      := ""
Local aEmpresas   := u_BKGrupo()
Local nEmp        := 0
Local cTabSF1		:= ""
Local cTabSA2		:= ""

/*
Local i
Local lStaf,cSuper,aUser,cMDiretoria,cFiltro := ""

// Filtro do usuario
IF __cUserId <> "000000" // Administrador

   lStaf  := u_IsStaf(__cUserId)
  
   DBCLEARFILTER() 
   PswOrder(1) 
   PswSeek(__cUserId) 
   aUser  := PswRet(1)
   IF !EMPTY(aUser[1,11])
      cSuper := SUBSTR(aUser[1,11],1,6)
   ENDIF   

   cMDiretoria := u_GrpMDir()
   lMDiretoria := .F.
   aGRUPO := {}
	aGRUPO := UsrRetGrp(cUserName)
	IF LEN(aGRUPO) > 0
		FOR i:=1 TO LEN(aGRUPO)
			lMDiretoria := (ALLTRIM(aGRUPO[i]) $ cMDiretoria )
		NEXT
	ENDIF

   // Se o usuario pertence ao grupo Administradores ou Master Diretoria : não filtrar
    IF ASCAN(aUser[1,10],"000000") = 0 .AND. !lMDiretoria
       IF !lStaf .OR. EMPTY(cSuper)
          	cFiltro := " AND (F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ') "
       ELSE
          	cFiltro := " AND (F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ' OR "
          	cFiltro += "      F1_XXUSER = '"+  cSuper +"' OR F1_XXUSERS = '"+  cSuper +"') "             
       ENDIF
    ENDIF    
ENDIF
*/
For nEmp := 1 To Len(aEmpresas)

	cTabSF1 := "SF1"+aEmpresas[nEmp,1]+"0"
	cTabSA2 := "SA2"+aEmpresas[nEmp,1]+"0"

	cEmpresa := aEmpresas[nEmp,1]
	cNomeEmp := aEmpresas[nEmp,2]

	If nEmp > 1
		cQuery += "UNION ALL "+CRLF
	EndIf

   cQuery += "SELECT"+CRLF
	cQuery += "	'"+cEmpresa+"' AS F1EMPRESA,"+CRLF
	cQuery += "	'"+cNomeEmp+"' AS F1NOMEEMP,"+CRLF
   cQuery += "  F1_FILIAL,"+CRLF
   cQuery += "  F1_DOC,"+CRLF
   cQuery += "  F1_SERIE,"+CRLF
   cQuery += "  F1_ESPECIE,"+CRLF
   cQuery += "  F1_EMISSAO,"+CRLF
   cQuery += "  F1_DTDIGIT,"+CRLF
   cQuery += "  F1_TIPO,"+CRLF
   cQuery += "  F1_FORNECE,"+CRLF
   cQuery += "  F1_LOJA,"+CRLF
   cQuery += "  A2_NOME,"+CRLF
   cQuery += "  F1_VALBRUT,"+CRLF
   cQuery += "  F1_STATUS,"+CRLF
   cQuery += "  F1_XXUSER,"+CRLF
   cQuery += "  F1_XXUSERS,"+CRLF
   cQuery += "  F1_XXULIB"+CRLF
   cQuery += "FROM "+cTabSF1+" SF1 "+CRLF
   cQuery += "INNER JOIN "+cTabSA2+" SA2 ON"+CRLF
   cQuery += "  SF1.F1_FORNECE = SA2.A2_COD AND SF1.F1_LOJA = SA2.A2_LOJA"+CRLF
   cQuery += "  AND SA2.A2_FILIAL='"+xFilial("SA2")+"'"+CRLF
   cQuery += "  AND SA2.D_E_L_E_T_=''" +CRLF
   cQuery += "WHERE "+CRLF
   cQuery += "  F1_DTDIGIT BETWEEN '"+Dtos(dDataI)+"' AND '"+Dtos(dDataF)+"'"+CRLF
   cQuery += "  AND SF1.D_E_L_E_T_ = '' "+CRLF
   cQuery += "  AND SF1.F1_FILIAL='"+xFilial("SF1")+"'"+CRLF
   If !Empty(cUsr3)
      cQuery += "  AND (F1_XXUSER = '"+cUsr3+"' OR F1_XXUSERS = '"+cUsr3+"')" +CRLF
   EndIf
   /*
   IF !EMPTY(cFiltro)
      cQuery += cFiltro
   ENDIF
   */
Next

IF nOrdP = 1
   cQuery += "ORDER BY F1EMPRESA,F1_SERIE,F1_DOC,F1_FORNECE,F1_LOJA "+CRLF
ELSE   
   cQuery += "ORDER BY F1EMPRESA,F1_DTDIGIT,F1_SERIE,F1_DOC,F1_FORNECE,F1_LOJA "+CRLF
ENDIF

u_LogMemo(cPerg+".SQL",cQuery)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QSF1",.T.,.T.)

tcSetField("QSF1","F1_EMISSAO","D",8,0)
tcSetField("QSF1","F1_DTDIGIT","D",8,0)

Return Nil




Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Da Data"   ,"Da Data ","Da Data ","mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"S","",""})
AADD(aRegistros,{cPerg,"02","Ate Data"  ,"Ate Data","Ate Data","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"S","",""})
AADD(aRegistros,{cPerg,"03","Usuário"   ,"Usuário" ,"Usuário" ,"mv_ch3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","USR","S","",""})
AADD(aRegistros,{cPerg,"04","Ordem de:" ,"Ordem de","Ordem de","mv_ch4","N",1,0,2,"C","","mv_par04","Documento","Documento","Documento","","","Data","Data","Data","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegistros)
	If !dbSeek(cPerg+aRegistros[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegistros[i])
				FieldPut(j,aRegistros[i,j])
			Endif
		Next
		MsUnlock()
	Endif
Next

RestArea(aArea)

Return(NIL)
