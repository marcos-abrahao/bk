#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FINR07  º                                    Data ³11/05/10º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ RELATORIO DE DESPESAS POR ITEM DO DOCUMENTO DE ENTRADA     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK Consultoria                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
         
/*/
User Function FINR07(fFrota)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local titulo         := "Despesas mensais por Doc. de Entrada"
Local nLin           := 80
Local Cabec1         := ""
Local Cabec2         := ""
Local aOrd           := {}
Local aCabs          := {}
Local aCampos        := {}
Local aTitulos       := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 132
Private tamanho      := " "
Private nomeprog     := "FINR07" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "FINR07"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "FINR07" // Coloque aqui o nome do arquivo usado para impressao em disco
Private fGFrota      := fFrota
Private cString      := "SD1"

Private dDtIni,dDtFim,dDtPgIni,dDtPgFin,cProduto,cCustoDe,cCustoAte

Private nPlan


ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
Endif

dDtIni   := MV_PAR01
dDtFim   := MV_PAR02
nPlan    := MV_PAR03
cProduto := MV_PAR04
cCustoDe := MV_PAR05
cCustoAte:= MV_PAR06
fGFrota  := fFrota


If nPlan = 2
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
	
	Processa( {|| ProcGer1(@Titulo) })
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	QSD1->(Dbclosearea())
	
Else
 
		//dbSelectArea("SE2")
		//dbSetOrder(6)
		//dbSeek(xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC)
		//While !Eof() .And. E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == ;
		//	xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC
		//	If ALLTRIM(E2_ORIGEM)=="MATA100"
		//		aADD(aVencto,E2_VENCTO)
		//	EndIf
		//	dbSkip()
		//EndDo


	Processa( {|| ProcGer1(@Titulo) })

	aCabs   := {}
	aCampos := {}
	aTitulos:= {}

	nomeprog := wnRel+"/"+TRIM(SUBSTR(cUsuario,7,15))   
	AADD(aTitulos,nomeprog+" - "+titulo)

	AADD(aCampos,"QSD1->D1_COD")
	AADD(aCabs  ,"Produto")

	AADD(aCampos,"QSD1->B1_DESC")
	AADD(aCabs  ,"Descricao do Produto")

	AADD(aCampos,"QSD1->D1_CC")
	AADD(aCabs  ,"Centro de Custos")

	AADD(aCampos,"QSD1->CTT_DESC01")
	AADD(aCabs  ,"Descriçao do C.C.")

	AADD(aCampos,"QSD1->D1_CONTA")
	AADD(aCabs  ,"Conta")

	AADD(aCampos,"QSD1->D1_FORNECE")
	AADD(aCabs  ,"Cod. do Fornecedor")

	AADD(aCampos,"QSD1->D1_LOJA")
	AADD(aCabs  ,"Loja do Fornecedor")

	AADD(aCampos,"QSD1->A2_NOME")
	AADD(aCabs  ,"Nome do Fornecedor")

	AADD(aCampos,"QSD1->D1_DOC")
	AADD(aCabs  ,"Documento")

	IF fGFrota
		AADD(aCampos,"QSD1->D1_EMISSAO")
		AADD(aCabs  ,"Emissão")
    ENDIF

	AADD(aCampos,"QSD1->D1_DTDIGIT")
	AADD(aCabs  ,"Data")

	AADD(aCampos,"QSD1->D1_QUANT")
	AADD(aCabs  ,"Qtd.")
	
	AADD(aCampos,"ROUND(QSD1->D1_TOTAL / QSD1->D1_QUANT,2)")
	AADD(aCabs  ,"Unit.")

	AADD(aCampos,"QSD1->D1_TOTAL")
	AADD(aCabs  ,"Valor")
	
	AADD(aCampos,"QSD1->C7_XXURGEN")
	AADD(aCabs  ,"Pedido Urgente")

	AADD(aCampos,"QSD1->D1_XXHIST")
	AADD(aCabs  ,"Historico")

	ProcRegua(QSD1->(LASTREC()))
	Processa( {|| GeraCSVBKFINR07("QSD1",cPerg,aTitulos,aCampos,aCabs)})
	QSD1->(Dbclosearea())

	//AADD(aPlans,{"QSD1",cPerg,"",Titulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
	//MsAguarde({|| U_GeraXml(aPlans,Titulo,cPerg,.F.)},"Aguarde","Gerando planilha...",.F.)


Endif	

	
Return


Static Function procger1(Titulo)
Local cQuery

If SELECT("QSD1") > 0 
	dbSelectArea("QSD1")
   	dbCloseArea()
EndIf

Titulo := "Despesas mensais por Doc. de Entrada: "

cQuery := "SELECT DISTINCT D1_FILIAL,D1_COD,D1_ITEM,B1_DESC,D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC AS D1_TOTAL,D1_QUANT,D1_CC,CTT_DESC01,"
cQuery += "D1_CONTA,D1_FORNECE,D1_LOJA,A2_NOME,D1_DOC,D1_DTDIGIT,D1_EMISSAO,C7_XXURGEN "
//IF fGFrota
	cQuery += ",CONVERT(VARCHAR(8000),CONVERT(Binary(8000),D1_XXHIST)) D1_XXHIST "
//ENDIF
cQuery += "FROM "+RETSQLNAME("SD1")+" SD1 "
cQuery += "INNER JOIN "+RETSQLNAME("SA2")+" SA2 ON D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "
cQuery += "INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON D1_COD = B1_COD  AND SB1.D_E_L_E_T_ = ' ' "                                          
cQuery += "INNER JOIN "+RETSQLNAME("CTT")+" CTT ON D1_FILIAL = CTT_FILIAL AND D1_CC = CTT_CUSTO AND CTT.D_E_L_E_T_ = ' ' "
cQuery += "LEFT  JOIN "+RETSQLNAME("SC7")+" SC7 ON D1_FILIAL = C7_FILIAL AND D1_PEDIDO = C7_NUM AND D1_ITEMPC = C7_ITEM AND SC7.D_E_L_E_T_ = ' ' "

cQuery += "WHERE SD1.D_E_L_E_T_ = ' '  "

IF !EMPTY(dDtIni)
	IF fGFrota
		cQuery += "AND (D1_EMISSAO >= '"+DTOS(dDtIni)+"' OR D1_DTDIGIT >= '"+DTOS(dDtIni)+"') "
   		titulo += " de "+DTOC(dDtIni)
  	ELSE
		cQuery += "AND D1_DTDIGIT >= '"+DTOS(dDtIni)+"' "
   		titulo += " de "+DTOC(dDtIni)
  	ENDIF
ENDIF
IF !EMPTY(dDtFim)
	IF fGFrota
   		cQuery += "AND (D1_EMISSAO <= '"+DTOS(dDtFim)+"' OR D1_DTDIGIT <= '"+DTOS(dDtFim)+"') " 
   		titulo += " ate "+DTOC(dDtFim)
	ELSE
   		cQuery += "AND D1_DTDIGIT <= '"+DTOS(dDtFim)+"' "
   		titulo += " ate "+DTOC(dDtFim)
	ENDIF
ENDIF


IF fGFrota
	cQuery += " AND SD1.D1_COD IN ('320200505','320200507','320200527','320200607','41205021') "
ELSEIF !EMPTY(cProduto) .AND. ExistCpo("SB1",cProduto) 
	cQuery += " AND SD1.D1_COD = '"+ALLTRIM(cProduto)+"' "
	titulo += " - Produto: "+ALLTRIM(cProduto)
ENDIF
IF !EMPTY(cCustoDe)
	cQuery += " AND SD1.D1_CC >= '"+ALLTRIM(cCustoDe)+"' "
	titulo += " - Contrato de: "+ALLTRIM(cCustoDe)+IIF(!EMPTY(cCustoAte)," até "+ALLTRIM(cCustoAte),"")
ENDIF
IF !EMPTY(cCustoAte)
	cQuery += " AND SD1.D1_CC <= '"+ALLTRIM(cCustoAte)+"' "
	IF EMPTY(cCustoDe)
		titulo += " - Contrato até: "+ALLTRIM(cCustoAte)
	ENDIF
ENDIF

cQuery += "ORDER BY D1_COD,D1_DTDIGIT,D1_DOC "

Memowrite("BKFINR07.SQL", cQuery)

TCQUERY cQuery NEW ALIAS "QSD1"

TCSETFIELD("QSD1","D1_DTDIGIT","D",8,0)
TCSETFIELD("QSD1","D1_EMISSAO","D",8,0)
TCSETFIELD("QSD1","D1_XXHIST","M",10,0)
//TCSETFIELD("QSD1","C7_XXURGEN","N",1,0)

Dbselectarea("QSD1")
QSD1->(Dbgotop())

Return nil



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  11/05/10   º±±
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

Local nEsp,cPicVlr,pTotal,tTotal,cPrdAnt,nPos1

SetRegua(RecCount())

nEsp    := 2
cPicVlr := "@E 9,999,999.99"

//Cabec1  := PAD("Fil",LEN(QSD1->D1_FILIAL)+nEsp)
Cabec1  := PAD("Produto",LEN(QSD1->D1_COD)+nEsp)
Cabec1  += PAD("Descr. Produto",LEN(QSD1->B1_DESC)+nEsp)

Cabec1  += PAD("C. de Custos",LEN(QSD1->D1_CC)+nEsp)
Cabec1  += PAD("Descr. C.C.",LEN(QSD1->CTT_DESC01)+nEsp)

Cabec1  += PAD("Forn.",LEN(QSD1->D1_FORNECE)+nEsp)
Cabec1  += PAD("Lj",LEN(QSD1->D1_LOJA)+nEsp)
Cabec1  += PAD("Fornecedor",LEN(QSD1->A2_NOME)+nEsp)

Cabec1  += PAD("Documento",LEN(QSD1->D1_DOC)+nEsp)
Cabec1  += PAD("Data",LEN(DTOC(QSD1->D1_DTDIGIT))+nEsp)

Cabec1  += PADL("Valor",LEN(cPicVlr)-3)+SPACE(nEsp)

//IF fGFrota
	Cabec1  += PADL("Histórico",20-3)+SPACE(nEsp)
//ENDIF 

IF LEN(Cabec1) > 132
   Tamanho := "G"
ENDIF   

nomeprog := "FINR07/"+TRIM(SUBSTR(cUsuario,7,15))
   
Dbselectarea("QSD1")
Dbgotop()
SetRegua(RecCount())

cPrdAnt := QSD1->D1_COD

pTotal  := 0
tTotal  := 0
nPos1   := 0

DO While !QSD1->(EOF())

   IncRegua()
   If lAbortPrint
      @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Impressao do cabecalho do relatorio. . .                            ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   Endif

   IF QSD1->D1_COD <> cPrdAnt
      @ nLin,0     PSAY "TOTAL DO PRODUTO "+cPrdAnt
      @ nLin,nPos1 PSAY pTotal  PICTURE cPicVlr 
      nLin+=2
      pTotal := 0
      cPrdAnt := QSD1->D1_COD
      If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
         Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
         nLin := 9
      Endif
   ENDIF
    
   nPos := 0
   //@ nLin,nPos PSAY QSD1->D1_FILIAL
   //nPos := PCOL()+nEsp

   @ nLin,nPos PSAY QSD1->D1_COD
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY QSD1->B1_DESC
   nPos := PCOL()+nEsp
   
   @ nLin,nPos PSAY QSD1->D1_CC
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY QSD1->CTT_DESC01
   nPos := PCOL()+nEsp
   
   @ nLin,nPos PSAY QSD1->D1_FORNECE
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY QSD1->D1_LOJA
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY QSD1->A2_NOME
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY QSD1->D1_DOC
   nPos := PCOL()+nEsp

   @ nLin,nPos PSAY DTOC(QSD1->D1_DTDIGIT)
   nPos := PCOL()+nEsp

   IF nPos1 = 0
      nPos1 := nPos
   ENDIF

   @ nLin,nPos PSAY QSD1->D1_TOTAL PICTURE cPicVlr 
   nPos := PCOL()+nEsp

	//IF fGFrota
   		@ nLin,nPos PSAY PAD(QSD1->D1_XXHIST,20)
   		nPos := PCOL()+nEsp
	//ENDIF
   
   pTotal  += QSD1->D1_TOTAL
   tTotal  += QSD1->D1_TOTAL
   
   nLin++
   
   dbSkip()
EndDo

nLin++
IF nPos1 > 0
   @ nLin,0     PSAY "TOTAL DO PRODUTO "+cPrdAnt                   
   @ nLin,nPos1 PSAY pTotal  PICTURE cPicVlr 
   nLin++
   @ nLin,0     PSAY "TOTAL GERAL"
   @ nLin,nPos1 PSAY tTotal  PICTURE cPicVlr 
ENDIF                         
//Roda(0,,Tamanho)

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


Return


Static Function ValidPerg

Local aArea      := GetArea()
Local aRegistros := {}
Local i,j

cPerg := "FINR07"
dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Data inicial:"    ,"Data I:"      ,"Data I:"      ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Data Final:"      ,"Data F:"      ,"Data F:"      ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Gerar Planilha? " ,"Planilha"     ,"Planilha"     ,"mv_ch3","N",01,0,2,"C","","mv_par03","Sim","Sim","Sim","","","Nao","Nao","Nao","","","","","","","","","","","","","","","","","   "})
AADD(aRegistros,{cPerg,"04","Pesquisar produto","Produto"      ,"Produto"      ,"mv_ch4","C",15,0,0,"G",'Vazio() .or. ExistCpo("SB1")',"mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","SB1","S","",""})
AADD(aRegistros,{cPerg,"05","Contrato de?"     ,"Contrato de?" ,"Contrato de?" ,"mv_ch5","C",09,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"06","Contrato até?"    ,"Contrato até?","Contrato até?","mv_ch6","C",09,0,0,"G","NaoVazio()","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})

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


STATIC Function GeraCSVBKFINR07(_cAlias,cArqS,aTitulos,aCampos,aCabs)
Local nHandle
Local cCrLf   := Chr(13) + Chr(10)
Local _ni
Local cPicN   := "@E 99999999.99999"
Local cDirTmp := "C:\TMP"
Local cArqTmp := cDirTmp+"\"+TRIM(cArqS)+".CSV"
Local lSoma,aSoma,nCab
Local cLetra

Private xCampo

MakeDir(cDirTmp)
fErase(cArqTmp)

lSoma := .F.
aSoma := {}
nCab  := 0

nHandle := MsfCreate(cArqTmp,0)
   
If nHandle > 0
      
   FOR _ni := 1 TO LEN(aTitulos)
      fWrite(nHandle, aTitulos[_ni])
      fWrite(nHandle, cCrLf ) // Pula linha
      nCab++
   NEXT

   FOR _ni := 1 TO LEN(aCabs)
   		fWrite(nHandle, aCabs[_ni] + IIF(_ni < LEN(aCabs),";",""))
   NEXT
   nCab++

   fWrite(nHandle, cCrLf ) // Pula linha

   (_cAlias)->(dbgotop())
   Do While (_cAlias)->(!eof())

      IF !lSoma
         For _ni :=1 to LEN(aCampos)
           	xCampo := &(aCampos[_ni])
           	If VALTYPE(xCampo) == "N" // Trata campos numericos
               	cLetra := CHR(_ni+64)
               	IF cLetra > "Z"
               		cLetra := "A"+CHR(_ni+64-26)
               	ENDIF
               	AADD(aSoma,'=Soma('+cLetra+ALLTRIM(STR(nCab))+':')
           	Else
               	AADD(aSoma,"")
           	Endif
         Next
         lSoma := .T.
      ENDIF
   
      IncProc("Gerando arquivo "+cArqS)   

      For _ni :=1 to LEN(aCampos)
        xCampo := &(aCampos[_ni])
                                                    
        _uValor := ""
            
        If VALTYPE(xCampo) == "D" // Trata campos data
           	_uValor := dtoc(xCampo)
        Elseif VALTYPE(xCampo) == "N" // Trata campos numericos
           	_uValor := transform(xCampo,cPicN)
	         Elseif VALTYPE(xCampo) == "C" .OR. VALTYPE(xCampo) == "M"// Trata campos caracter
	             //_uValor := xCampo+CHR(160)
	            //_uValor := '="'+ALLTRIM(xCampo)+'"'
                //_uValor := '="'+STRTRAN(ALLTRIM(xCampo),";",",")+'"'

                
                //_uValor := '="'
                xCampo := ALLTRIM(xCampo)
                for nxx := 1 to len(xCampo)
                	xxChar := SUBSTR(xCampo,nxx,1)
                	IF ASC(xxChar) >= 32 .AND. SUBSTR(xCampo,nxx,1) <> ";"
                       _uValor += SUBSTR(xCampo,nxx,1) 
                    ENDIF
                next
                //_uValor += '"'
                

         		IF LEN(ALLTRIM(_uValor)) > 250
            		_uValor := OEMTOANSI(ALLTRIM(_uValor))
            	ELSE
            		_uValor := '="'+OEMTOANSI(ALLTRIM(_uValor))+'"'
            	ENDIF
                
	         Endif
           
      	fWrite(nHandle, _uValor + IIF(_ni < LEN(aCampos),";",""))
      Next _ni
      nCab++   
      
      fWrite(nHandle, cCrLf )

      (_cAlias)->(dbskip())
         
   Enddo
   IF lSoma
	   FOR _ni := 1 TO LEN(aSoma)
           cLetra := CHR(_ni+64)
           IF cLetra > "Z"
              cLetra := "A"+CHR(_ni+64-26)
           ENDIF
	       IF !EMPTY(aSoma[_ni])
              aSoma[_ni] += cLetra+ALLTRIM(STR(nCab))+')'
	       ENDIF
	       fWrite(nHandle, aSoma[_ni] + IIF(_ni < LEN(aSoma),";",""))
	   NEXT
   ENDIF	
      
   fClose(nHandle)
      
   MsgInfo("O arquivo "+cArqTmp+" será aberto no MsExcel")
   ShellExecute("open", cArqTmp,"","",1)

Else
   MsgAlert("Falha na criação do arquivo "+cArqTmp)
Endif
   
Return


User Function FINR072()
	U_FINR07(.T.)
Return
