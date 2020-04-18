#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} BKFINR05
BK - Relação de titulos gerados pela rotina Liquidos
@Return
@author Marcos Bispo Abrahão
@since 28/12/09
@version P12
/*/

User Function BKFINR05()

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := ALLTRIM(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_NOME"} )[1,2])
Local titulo         := "Liquidos "+ALLTRIM(FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , {"M0_NOME"} )[1,2])+" por vencimento"
Local nLin           := 80
Local Cabec1         := ""
Local Cabec2         := ""
Local aOrd           := {}
Local aTitulos,aCampos,aCabs,aPlans

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := "G"
Private limite       := 220
Private tamanho      := " "
Private nomeprog     := "BKFINR05" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "BKFINR05"
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "BKFINR05" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cString      := "SE2"
Private nExcel       := 2
Private nMeses,aMeses

dbSelectArea(cString)
dbSetOrder(1)

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
Endif

IF mv_par01 == mv_par02
	titulo   := "Liquidos "+cDesc3+" - Vencimento: "+dtoc(mv_par01)
ELSE
	titulo   := "Liquidos "+cDesc3+" - Vencimento de : "+dtoc(mv_par01)+" até "+dtoc(mv_par02)
ENDIF

nExcel := MV_PAR03
If nExcel = 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
	   Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	            
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	nomeprog := "BKFINR05/"+TRIM(SUBSTR(cUsuario,7,15))
	ProcRegua(1)
	Processa( {|| ProcQuery() })
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	
Else
	ProcRegua(1)
	Processa( {|| ProcQuery() })

	aCabs   := {}
	aCampos := {}
	aTitulos:= {}
    aPlans  := {}
    
	nomeprog := "BKFINR05/"+TRIM(SUBSTR(cUsuario,7,15))
	AADD(aTitulos,nomeprog+" - "+titulo)

	AADD(aCampos,"QSE2->Z2_BANCO")
	AADD(aCabs  ,"Banco")

	AADD(aCampos,"QSE2->Z2_NOME")
	AADD(aCabs  ,"Nome")

	AADD(aCampos,"TRIM(QSE2->Z2_AGENCIA)+'-'+TRIM(QSE2->Z2_DIGAGEN)")
	AADD(aCabs  ,"Agencia")

	AADD(aCampos,"TRIM(QSE2->Z2_CONTA)+'-'+TRIM(QSE2->Z2_DIGCONTA)")
	AADD(aCabs  ,"Conta")

	AADD(aCampos,"QSE2->Z2_TIPO")
	AADD(aCabs  ,"Tipo")

	AADD(aCampos,"QSE2->Z2_TIPOPES")
	AADD(aCabs  ,"Tipo Pes.")

	AADD(aCampos,"QSE2->E2_NUM")
	AADD(aCabs  ,"Titulo")

	AADD(aCampos,"QSE2->E2_VENCREA")
	AADD(aCabs  ,"Vencimento")

	AADD(aCampos,"QSE2->Z2_USUARIO")
	AADD(aCabs  ,"Usuario")

	AADD(aCampos,"QSE2->Z2_CTRID")
	AADD(aCabs  ,"CtrId")

	AADD(aCampos,"QSE2->Z2_VALOR")
	AADD(aCabs  ,"Valor")
   
	AADD(aPlans,{"QSE2",wnrel,"",Titulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
	U_GeraXlsx(aPlans,Titulo,wnrel,.F.)
   
EndIf	
Return


Static Function ProcQuery
Local cQuery

IncProc("Consultando o banco de dados...")

cQuery := "SELECT E2_FILIAL,E2_PREFIXO,E2_NUM,E2_PARCELA,E2_VENCREA,E2_TIPO,E2_FORNECE,E2_LOJA,"
cQuery += " Z2_CTRID,Z2_NOME,Z2_BANCO,Z2_AGENCIA,Z2_DIGAGEN,Z2_CONTA,Z2_DIGCONT,Z2_TIPO,Z2_VALOR,Z2_TIPOPES,Z2_USUARIO "
cQuery += " FROM "+RETSQLNAME("SE2")+" SE2 INNER JOIN "+RETSQLNAME("SZ2")+ " SZ2 ON "
cQuery += " Z2_CODEMP = '"+SM0->M0_CODIGO+"' "
cQuery += " AND E2_PREFIXO = Z2_E2PRF "
cQuery += " AND E2_NUM     = Z2_E2NUM"
cQuery += " AND E2_PARCELA = Z2_E2PARC"
cQuery += " AND E2_TIPO    = Z2_E2TIPO"
cQuery += " AND E2_FORNECE = Z2_E2FORN"
cQuery += " AND E2_LOJA    = Z2_E2LOJA"
cQuery += " AND Z2_STATUS = 'S'"
IF mv_par01 == mv_par02
	cQuery += " AND E2_VENCREA = '"+DTOS(mv_par01)+"'
ELSE
	cQuery += " AND E2_VENCREA >= '"+DTOS(mv_par01)+"'
	cQuery += " AND E2_VENCREA <= '"+DTOS(mv_par02)+"'
ENDIF
cQuery += " AND SE2.D_E_L_E_T_ = ' ' AND SZ2.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY Z2_TIPOPES,Z2_BANCO,Z2_NOME"  

TCQUERY cQuery NEW ALIAS "QSE2"
TCSETFIELD("QSE2","E2_VENCREA","D",8,0)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  08/04/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local lCabec

Dbselectarea("QSE2")
Dbgotop()

SetRegua(LastRec())

nEsp    := 2
cPicVlr := "@E 9,999,999.99"

Cabec1  := PAD("Banco",LEN(QSE2->Z2_BANCO)+nEsp)
Cabec1  += PAD("Nome",LEN(QSE2->Z2_NOME)+nEsp)
Cabec1  += PAD("Agencia",LEN(QSE2->Z2_AGENCIA)+LEN(QSE2->Z2_DIGAGEN)+1+nEsp)
Cabec1  += PAD("Conta",LEN(QSE2->Z2_CONTA)+LEN(QSE2->Z2_DIGCONT)+1+nEsp)
Cabec1  += PAD("Tipo",LEN(QSE2->Z2_TIPO)+nEsp)
Cabec1  += PAD("T.Pes.",LEN(QSE2->Z2_TIPOPES)+nEsp)
Cabec1  += PAD("Titulo",LEN(QSE2->E2_NUM)+nEsp)
Cabec1  += PAD("Vencimento",LEN(QSE2->E2_VENCREA)+nEsp)
Cabec1  += PAD("Usuario",20+nEsp)
Cabec1  += PAD("CtrId",LEN(QSE2->Z2_CTRID)+nEsp)
Cabec1  += PADL("Valor",LEN(cPicVlr)-3)+SPACE(nEsp)

IF LEN(Cabec1) > 132
   Tamanho := "G"
ENDIF   

Dbselectarea("QSE2")
Dbgotop()
SetRegua(LastRec())        

cBanco := QSE2->Z2_BANCO
nPos1  := nPos2 := nPos3 := nCont := 0
nTotTP := nTotBc := nTotG := 0

DO While !QSE2->(EOF())

   cTipoPes := QSE2->Z2_TIPOPES
   nTotTP   := 0

   //If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo+" Tipo Pes: "+cTipoPes,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
      lCabec := .T. 
      //@ nLin,0 PSAY TRIM(QSE2->C6_PRODUTO) + " - " +  Posicione("SB1",1,xFilial("SB1")+QSE2->C6_PRODUTO,"B1_DESC")
      //nLin += 2
   //Endif
   
   
   DO While !QSE2->(EOF()) .AND. cTipoPes == QSE2->Z2_TIPOPES
       IF !lCabec
         Cabec(Titulo+" Tipo Pes: "+cTipoPes,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
         nLin   := 9
         lCabec := .T. 
       ENDIF
       cBanco := QSE2->Z2_BANCO
       nTotBc := 0

	   nPos1  := 0
	   @ nLin,nPos1 PSAY QSE2->Z2_BANCO
	   nPos1  := PCOL()+nEsp

	   DO While !QSE2->(EOF()) .AND. cBanco == QSE2->Z2_BANCO .AND. cTipoPes == QSE2->Z2_TIPOPES
		  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		  //³ Impressao do cabecalho do relatorio. . .                            ³
		  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		  IncRegua()
	      If lAbortPrint
			 @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			 QSE2->(DBGOBOTTOM())
			 dbSkip()
		     Exit
	      Endif
	      If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
	         Cabec(Titulo+" Tipo Pes: "+cTipoPes,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	         nLin := 9 
	         @ nLin,0 PSAY cBanco
	      Endif
	
	      @ nLin,nPos1 PSAY QSE2->Z2_NOME
	      nPos2  := PCOL()+nEsp
	      
	      @ nLin,nPos2 PSAY PAD(TRIM(QSE2->Z2_AGENCIA)+'-'+TRIM(QSE2->Z2_DIGAGEN),LEN(QSE2->Z2_AGENCIA)+LEN(QSE2->Z2_DIGAGEN)+1)
	      nPos2  := PCOL()+nEsp
	
	      @ nLin,nPos2 PSAY PAD(TRIM(QSE2->Z2_CONTA)+'-'+TRIM(QSE2->Z2_DIGCONTA),LEN(QSE2->Z2_CONTA)+LEN(QSE2->Z2_DIGCONTA)+1)
	      nPos2  := PCOL()+nEsp
	
	      @ nLin,nPos2 PSAY QSE2->Z2_TIPO
	      nPos2  := PCOL()+nEsp
	
	      @ nLin,nPos2 PSAY QSE2->Z2_TIPOPES
	      nPos2  := PCOL()+nEsp
	
	      @ nLin,nPos2 PSAY QSE2->E2_NUM
	      nPos2  := PCOL()+nEsp

	      @ nLin,nPos2 PSAY QSE2->E2_VENCREA
	      nPos2  := PCOL()+nEsp
	                           
	      @ nLin,nPos2 PSAY PAD(QSE2->Z2_USUARIO,20)
	      nPos2  := PCOL()+nEsp

	      @ nLin,nPos2 PSAY PAD(QSE2->Z2_CTRID,20)
	      nPos2  := PCOL()+nEsp
	      
	      @ nLin,nPos2 PSAY QSE2->Z2_VALOR PICTURE cPicVlr
	      nPos3  := nPos2
	      nPos2  := PCOL()+nEsp
	
	      nCont++
	      nLin++
	      
	      nTotBc += QSE2->Z2_VALOR
	      nTotTP += QSE2->Z2_VALOR
	      nTotG  += QSE2->Z2_VALOR
	
	      dbSkip()
	  ENDDO
	  IF nPos3 > 0
	    nLin++
	    @ nLin,nPos3-22 PSAY "TOTAL DO BANCO "+cBanco
	    @ nLin,nPos3 PSAY nTotBc PICTURE cPicVlr 
	    nLin+=2
	  ENDIF
      lCabec := .F.
  ENDDO
  IF nPos3 > 0
    @ nLin,nPos3-22 PSAY "TOTAL "+cTipoPes
    @ nLin,nPos3 PSAY nTotTP PICTURE cPicVlr 
    nLin++
  ENDIF
  
  nLin++
ENDDO

/*  Removido o total geral
nLin++
IF nPos3 > 0
   @ nLin,0 PSAY "TOTAL GERAL"
   @ nLin,nPos3 PSAY nTotG PICTURE cPicVlr 
ENDIF
*/


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

QSE2->(Dbclosearea())

Return


Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Vencimento de ?"  ,"Vencimento de ?"  ,"Vencimento de ?"  ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Vencimento até ?" ,"Vencimento até ?" ,"Vencimento até ?" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Gerar Planilha? " ,"Planilha"         ,"Planilha"         ,"mv_ch3","N",01,0,2,"C","","mv_par03","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","",""})

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