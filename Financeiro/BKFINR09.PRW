#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKFINR09
BK - Listagem de Despesas de Viagem/LF 

@Return
@author Marcos Bispo Abrahão
@since 11/05/10
@version P12 - 30/03/20
/*/


User Function BKFINR09()

Private cTitulo      := "Listagem de Despesas de Viagem/LF"
Private aTitulos     := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private cProg        := "FINR09"
Private cPerg        := "FINR09"
Private cString      := "SZ2"
Private nOpcA
Private aTipoBk      := {}
Private cTipoBK      := ""
Private aTipoPes     := {}
Private cTipoPes     := ""
Private aTipoRel     := {"DV - Despesas de Viagem","LF - Liquidos da Folha","CX - Caixa"}
Private cTipoRel     := aTipoRel[1] 

// Parametros - Pergunte
Private dEmisI,dEmisF,dVencI,dVencF,nValI,nValF,cCC,cForn

ProcRegua(10)
Processa( {|| LoadTpBk()})

ProcRegua(10)
Processa( {|| LoadTpPes()})

cTipoBk   := aTipoBk[LEN(aTipoBK)]
cTipoPes  := aTipoPes[LEN(aTipoPes)]

nTamTpBK  := TamSx3("Z2_TIPO")[1]
nTamTpPes := TamSx3("Z2_TIPOPES")[1]

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
Endif

DEFINE MSDIALOG oDlg FROM  96,9 TO 310,592 TITLE OemToAnsi(cProg+" - "+cTitulo) PIXEL

//@ 18, 6 TO 66, 287 LABEL "" OF oDlg  PIXEL

@ 10,10 SAY 'Relatorio:'   SIZE 50,10 OF oDlg PIXEL
@ 10,65 COMBOBOX cTipoRel  ITEMS aTipoRel SIZE 100,50 OF oDlg PIXEL

@ 25,10 SAY 'Tipo BK:'     SIZE 50,10 OF oDlg PIXEL
@ 25,65 COMBOBOX cTipoBk   ITEMS aTipoBK SIZE 100,50 OF oDlg PIXEL

@ 40,10 SAY "Tipo Pessoa"  SIZE 50,10 OF oDlg PIXEL
@ 40,65 COMBOBOX cTipoPes  ITEMS aTipoPes SIZE 100,50 OF oDlg PIXEL

DEFINE SBUTTON oBtnParam FROM 80, 183 TYPE 5 ACTION pergunte(cPerg,.T.) ENABLE OF oDlg
oBtnParam:nWidth := 80
DEFINE SBUTTON FROM 80, 223 TYPE 1 ACTION (oDlg:End(),nOpcA:=1) ENABLE OF oDlg
DEFINE SBUTTON FROM 80, 253 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTER

If nOpcA == 1
	ProcR09()
Endif
Return NIL


Static Function ProcR09()
Local aPlans := {}

dEmisI := mv_par01
dEmisF := mv_par02
dVencI := mv_par03
dVencF := mv_par04
nValI  := mv_par05
nValF  := mv_par06
cCC    := mv_par07
cForn  := mv_par08

aCabs   := {}
aCampos := {}
aTitulos:= {}

ProcRegua(5)
Processa( {|| ProcSZ2() })

AADD(aCampos,"QSZ2->Z2_TIPO")
AADD(aCabs  ,"Tipo")

AADD(aCampos,"QSZ2->Z2_TIPOPES")
AADD(aCabs  ,"Tipo Pessoa")

AADD(aCampos,"QSZ2->Z2_PRONT")
AADD(aCabs  ,"Prontuario")

AADD(aCampos,"QSZ2->Z2_NOME")
AADD(aCabs  ,"Nome")

AADD(aCampos,"IIF(SUBSTR(QSZ2->Z2_CC,1,1)<>'E',QSZ2->Z2_CC,'000000001')")
AADD(aCabs  ,"Centro de Custos")

AADD(aCampos,"IIF(!EMPTY(QSZ2->CTT_DESC01),QSZ2->CTT_DESC01,'BK CONSULTORIA')")
AADD(aCabs  ,"Descriçao do C.C.")
                       
AADD(aCampos,"QSZ2->Z2_VALOR")
AADD(aCabs  ,"Valor")

AADD(aCampos,"QSZ2->Z2_DATAEMI")
AADD(aCabs  ,"Emissao")

AADD(aCampos,"QSZ2->E2_EMIS1")
AADD(aCabs  ,"Contabil.")

AADD(aCampos,"QSZ2->Z2_DATAPGT")
AADD(aCabs  ,"Vencimento")

AADD(aCampos,"QSZ2->E2_BAIXA")
AADD(aCabs  ,"Baixa")

AADD(aCampos,"QSZ2->Z2_OBS")
AADD(aCabs  ,"Observações")

AADD(aCampos,"QSZ2->Z2_USUARIO")
AADD(aCabs  ,"Usuário")

AADD(aCampos,"QSZ2->Z2_E2FORN")
AADD(aCabs  ,"Cod. do Fornecedor")

AADD(aCampos,"QSZ2->Z2_E2LOJA")
AADD(aCabs  ,"Loja do Fornecedor")

AADD(aCampos,"QSZ2->A2_NOME")
AADD(aCabs  ,"Nome do Fornecedor")

AADD(aCampos,"QSZ2->Z2_E2PRF")
AADD(aCabs  ,"Prefixo")

AADD(aCampos,"QSZ2->Z2_E2NUM")
AADD(aCabs  ,"Numero do Titulo")

AADD(aCampos,"QSZ2->Z2_E2PARC")
AADD(aCabs  ,"Parcela do Titulo")

AADD(aCampos,"QSZ2->E2_VENCTO")
AADD(aCabs  ,"Vencimento Titulo")

AADD(aCampos,"QSZ2->Z2_PRODUTO")
AADD(aCabs  ,"Conta Contábil")

AADD(aCampos,"QSZ2->Z2_OBSTITU")
AADD(aCabs  ,"OBS")


IF !QSZ2->(EOF())
	ProcRegua(QSZ2->(LASTREC()))

	//Processa( {|| U_GeraCSV("QSZ2",cProg,aTitulos,aCampos,aCabs)})

   AADD(aPlans,{"QSZ2",TRIM(cPerg),"",aTitulos,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
   U_GeraXml(aPlans,cTitulo,TRIM(cPerg),.F.)

ELSE
   MsgStop("Sem dados para imprimir, verifique os parâmetros do relatório")
	Dbselectarea("QSZ2")
	dbCloseArea()
ENDIF	
	
Return


Static Function ProcSZ2()
Local cQuery


IncProc()
cQuery := "SELECT Z2_PRONT,Z2_NOME,Z2_CC,CTT_DESC01,Z2_VALOR,Z2_TIPO,Z2_TIPOPES,Z2_OBS,Z2_USUARIO,Z2_E2FORN,Z2_E2LOJA,Z2_DATAEMI,Z2_DATAPGT, "+CRLF
cQuery += "Z2_E2PRF,Z2_E2NUM,Z2_E2PARC,Z2_PRODUTO,Z2_OBSTITU, "+CRLF

//cQuery += "E2_BAIXA,E2_VENCTO, "  
//Z2_CTRID = E2_XXCTRID
cQuery += "(SELECT TOP 1 E2_BAIXA  FROM "+RETSQLNAME("SE2")+" SE2 WHERE SE2.D_E_L_E_T_ = ''"  +CRLF
cQuery += " AND Z2_E2NUM=E2_NUM AND Z2_E2PRF=E2_PREFIXO AND Z2_E2PARC=E2_PARCELA AND Z2_STATUS='S'"+CRLF
cQuery += " AND Z2_E2TIPO=E2_TIPO AND Z2_E2FORN=E2_FORNECE AND Z2_E2LOJA=E2_LOJA ) AS E2_BAIXA,"+CRLF
cQuery += "(SELECT TOP 1 E2_VENCTO FROM "+RETSQLNAME("SE2")+" SE2 WHERE SE2.D_E_L_E_T_ = ''"+CRLF
cQuery += " AND Z2_E2NUM=E2_NUM AND Z2_E2PRF=E2_PREFIXO AND Z2_E2PARC=E2_PARCELA AND Z2_STATUS='S'"+CRLF
cQuery += " AND Z2_E2TIPO=E2_TIPO AND Z2_E2FORN=E2_FORNECE AND Z2_E2LOJA=E2_LOJA ) AS E2_VENCTO,"+CRLF
cQuery += "(SELECT TOP 1 E2_EMIS1  FROM "+RETSQLNAME("SE2")+" SE2 WHERE SE2.D_E_L_E_T_ = ''"+CRLF
cQuery += " AND Z2_E2NUM=E2_NUM AND Z2_E2PRF=E2_PREFIXO AND Z2_E2PARC=E2_PARCELA AND Z2_STATUS='S'"+CRLF
cQuery += " AND Z2_E2TIPO=E2_TIPO AND Z2_E2FORN=E2_FORNECE AND Z2_E2LOJA=E2_LOJA ) AS E2_EMIS1,"+CRLF
//
cQuery += "A2_NOME "+CRLF
cQuery += "FROM "+RETSQLNAME("SZ2")+" SZ2 "+CRLF

//cQuery += "LEFT JOIN "+RETSQLNAME("SE2")+" SE2 ON Z2_CTRID = E2_XXCTRID AND SE2.D_E_L_E_T_ = ' ' "+CRLF
cQuery += "LEFT JOIN "+RETSQLNAME("SA2")+" SA2 ON Z2_E2FORN = A2_COD AND Z2_E2LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "+CRLF
cQuery += "LEFT JOIN "+RETSQLNAME("CTT")+" CTT ON Z2_CC = CTT_CUSTO AND CTT.D_E_L_E_T_ = ' ' "+CRLF

cQuery += "WHERE SZ2.D_E_L_E_T_ = ' '  AND SZ2.Z2_STATUS = 'S' AND SZ2.Z2_CODEMP='"+SM0->M0_CODIGO+"'"+CRLF

AADD(aTitulos,cTipoRel)

cTipoRel := PAD(cTipoRel,TamSx3("Z2_E2PRF")[1])
cQuery  += "AND Z2_E2PRF = '"+cTipoRel+"' "+CRLF

IF ALLTRIM(cTipoBK) <> "TODOS" 
   cTipoBK := PAD(cTipoBK,nTamTpBk)
   cQuery  += "AND Z2_TIPO = '"+cTipoBk+"' "+CRLF
   AADD(aTitulos,"Tipo BK: "+cTipoBK)
ENDIF

IF ALLTRIM(cTipoPes) <> "TODOS" 
   cTipoPes := PAD(cTipoPes,nTamTpPes)
   cQuery  += "AND Z2_TIPOPES = '"+cTipoPes+"' "+CRLF
   AADD(aTitulos,"Tipo Pessoa: "+cTipoPes)
ENDIF

IF !EMPTY(dEmisI)
   cQuery  += "AND Z2_DATAEMI >= '"+DTOS(dEmisI)+"' "+CRLF
   AADD(aTitulos,"Emissao de "+DTOC(dEmisI))
ENDIF
IF !EMPTY(dEmisF)
   cQuery  += "AND Z2_DATAEMI <= '"+DTOS(dEmisF)+"' "+CRLF
   AADD(aTitulos,"Emissao até "+DTOC(dEmisF))
ENDIF
IF !EMPTY(dVencI)
   cQuery  += "AND Z2_DATAPGT >= '"+DTOS(dVencI)+"' "+CRLF
   AADD(aTitulos,"Vencimento de "+DTOC(dVencI))
ENDIF
IF !EMPTY(dVencF)
   cQuery  += "AND Z2_DATAPGT <= '"+DTOS(dVencF)+"' "+CRLF
   AADD(aTitulos,"Vencimento até "+DTOC(dVencF))
ENDIF

IF !EMPTY(nValI)
   cQuery  += "AND Z2_VALOR >= '"+ALLTRIM(STR(nValI))+"' "+CRLF
   AADD(aTitulos,"Valor de "+ALLTRIM(STR(nValI,17,2)) )
ENDIF
IF !EMPTY(nValF)
   cQuery  += "AND Z2_VALOR <= '"+ALLTRIM(STR(nValF))+"' "+CRLF
   AADD(aTitulos,"Valor até "+ALLTRIM(STR(nValF,17,2)) )
ENDIF

IF !EMPTY(cCC)
   cQuery  += "AND Z2_CC = '"+cCC+"' "+CRLF
   AADD(aTitulos,"Centro de Custos "+cCC)
ENDIF

IF !EMPTY(cForn)
   cQuery  += "AND Z2_E2FORN = '"+cForn+"' "+CRLF
   AADD(aTitulos,"Fornecedor "+cForn)
ENDIF

cQuery += "ORDER BY Z2_DATAEMI,Z2_E2NUM "+CRLF

u_LogMemo("BKFINR09.SQL",cQuery)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QSZ2",.T.,.T.)

TCSETFIELD("QSZ2","Z2_DATAEMI","D",8,0)
TCSETFIELD("QSZ2","Z2_DATAPGT","D",8,0)
TCSETFIELD("QSZ2","E2_VENCTO","D",8,0)
TCSETFIELD("QSZ2","E2_BAIXA","D",8,0)
TCSETFIELD("QSZ2","E2_EMIS1","D",8,0)

Dbselectarea("QSZ2")
QSZ2->(Dbgotop())

Return nil



Static Function LoadTpBk()
Local cQry
IncProc()
// Opções tipo BK
//cQry := "SELECT Z2_TIPO FROM "+RETSQLNAME("SZ2")+" SZ2 WHERE SZ2.D_E_L_E_T_ = ' ' GROUP BY Z2_TIPO ORDER BY Z2_TIPO"
cQry := "SELECT Z2_TIPO FROM "+RETSQLNAME("SZ2")+" SZ2 GROUP BY Z2_TIPO ORDER BY Z2_TIPO"
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QSZ2",.T.,.T.)

Dbselectarea("QSZ2")
QSZ2->(Dbgotop())
DO WHILE !EOF()
   IncProc()
   AADD(aTipobK,QSZ2->Z2_TIPO)
   dbSkip()
ENDDO
AADD(aTipobK,"TODOS")
dbCloseArea()
Return Nil


Static Function LoadTpPes()
Local cQry
IncProc()
// Opções tipo BK
//cQry := "SELECT Z2_TIPOPES FROM "+RETSQLNAME("SZ2")+" SZ2 WHERE SZ2.D_E_L_E_T_ = ' ' GROUP BY Z2_TIPOPES ORDER BY Z2_TIPOPES"
cQry := "SELECT Z2_TIPOPES FROM "+RETSQLNAME("SZ2")+" SZ2 GROUP BY Z2_TIPOPES ORDER BY Z2_TIPOPES"
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QSZ2",.T.,.T.)

Dbselectarea("QSZ2")
QSZ2->(Dbgotop())
DO WHILE !EOF()
   IncProc()
   AADD(aTipoPes,QSZ2->Z2_TIPOPES)
   dbSkip()
ENDDO
AADD(aTipoPes,"TODOS")
dbCloseArea()
Return Nil



Static Function ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Emissao de :"        ,"" ,"" ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Emissao até:"        ,"" ,"" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Vencimento de :"     ,"" ,"" ,"mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"04","Vencimento até:"     ,"" ,"" ,"mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"05","Valor de:"           ,"" ,"" ,"mv_ch5","N",17,2,2,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"06","Valor até:"          ,"" ,"" ,"mv_ch6","N",17,2,2,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
aAdd(aRegistros,{cPerg,"07","Centro de Custo:"    ,"" ,"" ,"mv_ch7","C",09,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","CTT"})
aAdd(aRegistros,{cPerg,"08","Fornecedor: "        ,"" ,"" ,"mv_ch8","C",06,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","SA2"})

                                     
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
