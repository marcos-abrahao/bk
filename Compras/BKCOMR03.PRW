#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณBKCOMR03    บ Autor ณ Manuela /Marcos    บ Data ณ  15/01/08 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Protocolo NE                                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Proqualit                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function BKCOMR03()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "Protocolo NE - Proqualit"
Local titulo         := "Protocolo NE"
Local nLin           := 80
//                                 10        20        30        40        50        60        70        80        90        100       110       120       130       140       150                 170
//                     Fil.  Serie Documento Fornece/Loja Razao Social                                        Emissao   Digitacao   Valor Doc.  Prf/Titulo/Parc Tipo Vencimento   Vlr Titulo
//                        XX    XXX   XXXXXX    XXXXXX-XX   XXXXXXXXX1XXXXXXXXX2XXXXXXXXX3XXXXXXXXX4XXXXXXXXX5  XX/XX/XX  XX/XX/XX 99.999.999,99  XXXXXXXXX/XXX/X  XXX XX/XX/XX  99.999.999,99     NFE  XXXXXXX
Local Cabec1         := "Fil.  Serie  Documento Forn/Loja   Razao Social                                        Emissao   Digitacao   Valor Doc.  Prf/Titulo/Parc Tipo Vencimento   Vlr Titulo     " //Esp. CFOP"
//Local Cabec1         := "Fil.  Serie  Documento Forn/Loja   Razao Social                                        Emissao   Digitacao   Valor Doc.  Prf/Titulo/Parc Tipo Vencimento   Vlr Titulo   Vlr Icms      Base Ipi    Vlr Ipi Esp. CFOP"
Local Cabec2         := ""
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "BKCOMR03" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "BKCOMR03"
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "BKCOMR03" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := "SF1"
Private dDataI,dDataF,cFilP,nOrdP
dbSelectArea(cString)
dbSetOrder(1)

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return
Endif

dDataI := mv_par01
dDataF := mv_par02
cFilP  := mv_par03
nOrdP  := mv_par04

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta a interface padrao com o usuario...                           ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)
            
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  11/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local nCount
Local cStaf,lStaf,cSuper,aUser,cMDiretoria,cFiltro := ""
Local cGerGestao := ALLTRIM(GetMv("MV_XXGGCT"))

// Filtro do usuario
IF __cUserId <> "000000" // Administrador

	//__cUserId := "000067"

   cStaf  := SuperGetMV("MV_XXUSERS",.F.,"000013/000027/000061")
   //                                     Luis          Bruno Santiago
   lStaf  := (__cUserId $ cStaf)
   //lAClas := MsgBox("Filtra os Doc a Classificar", "M103BROW", "YESNO")
   DBCLEARFILTER() 
   PswOrder(1) 
   PswSeek(__CUSERID) 
   aUser  := PswRet(1)
   IF !EMPTY(aUser[1,11])
      cSuper := SUBSTR(aUser[1,11],1,6)
   ENDIF   
   cMDiretoria := SuperGetMV("MV_XXGRPMD",.F.,"000007") //SUBSTR(SuperGetMV("MV_XXGRPMD",.F.,"000007"),1,6) 
   lMDiretoria := .F.
   aGRUPO := {}
//   AADD(aGRUPO,aUser[1,10])
//   FOR i:=1 TO LEN(aGRUPO[1])
//		lMDiretoria := (aGRUPO[1,i] $ cMDiretoria)
//   NEXT
//Ajuste nova rotina a antiga nใo funciona na nova lib MDI
	aGRUPO := UsrRetGrp(aUser[1][2])
	IF LEN(aGRUPO) > 0
		FOR i:=1 TO LEN(aGRUPO)
			lMDiretoria := (ALLTRIM(aGRUPO[i]) $ cMDiretoria )
		NEXT
	ENDIF

   // Se o usuario pertence ao grupo Administradores ou Master Diretoria : nใo filtrar
    IF ASCAN(aUser[1,10],"000000") = 0 .AND. !lMDiretoria
       IF !lStaf .OR. EMPTY(cSuper)
       	  IF EMPTY(cSuper) .AND. __cUserId $ cGerGestao
          	cFiltro := " AND (F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ' OR F1_XXUSERS = '000075' OR F1_XXUSERS = '000120') "
       	  ELSE 
          	cFiltro := " AND (F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ') "
          ENDIF
       ELSE
       	  IF Staf .AND. cSuper $ cGerGestao
          	cFiltro := " AND (F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ' OR F1_XXUSERS = '000075' OR F1_XXUSERS = '000120' OR "
          	cFiltro += "      F1_XXUSER = '"+  cSuper +"' OR F1_XXUSERS = '"+  cSuper +"') "             
       	  ELSE
          	cFiltro := " AND (F1_XXUSER = '"+__cUserId+"' OR F1_XXUSERS = '"+__cUserId+"' OR F1_XXUSER = '      ' OR "
          	cFiltro += "      F1_XXUSER = '"+  cSuper +"' OR F1_XXUSERS = '"+  cSuper +"') "             
          ENDIF
       ENDIF
    ENDIF    
ENDIF

titulo   := "Protocolo NE de "+dtoc(dDataI)+" ate "+dtoc(dDataF)
nomeprog := "BKCOMR03/"+TRIM(SUBSTR(cUsuario,7,15))

cQuery := ""
cQuery := "SELECT F1_FILIAL,F1_DOC,F1_SERIE,F1_EMISSAO,F1_DTDIGIT,F1_TIPO,F1_FORNECE,F1_LOJA,F1_VALBRUT,F1_VALICM,F1_BASEIPI,F1_VALIPI,F1_ESPECIE "
cQuery += "FROM "+RETSQLNAME("SF1")+" SF1 "
cQuery += "WHERE F1_DTDIGIT BETWEEN '"+Dtos(dDataI)+"' AND '"+Dtos(dDataF)+"' AND F1_FILIAL = '"+cFilP+"' AND SF1.D_E_L_E_T_ = ' ' "
CQuery += " AND F1_STATUS='A' "

IF !EMPTY(cFiltro)
   cQuery += cFiltro
ENDIF

IF nOrdP = 1
   cQuery += "ORDER BY F1_FILIAL,F1_SERIE,F1_DOC,F1_FORNECE,F1_LOJA "
ELSE   
   cQuery += "ORDER BY F1_FILIAL,F1_EMISSAO,F1_SERIE,F1_DOC,F1_FORNECE,F1_LOJA "
ENDIF

//Memowrite("c:\bkcomr03.sql",cQuery)

TCQUERY cQuery NEW ALIAS "QSF1"

TCSETFIELD("QSF1","F1_EMISSAO","D",8,0)
TCSETFIELD("QSF1","F1_DTDIGIT","D",8,0)

Dbselectarea("QSF1")
QSF1->(Dbgotop())
cAliasSF1 := "QSF1"

SetRegua(RecCount())

nTvalor  := 0
nTvalor1 := 0
nCount   := 0

While !QSF1->(EOF())


   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Verifica o cancelamento pelo usuario...                             ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

   If lAbortPrint
      If nLin <> 80
         @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      EndIf   
      Exit
   Endif

   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Impressao do cabecalho do relatorio. . .                            ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

   If nLin > 63 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 8
   Endif
  
   @ nLin,001 psay QSF1->F1_FILIAL
   @ nLin,007 psay QSF1->F1_SERIE
   @ nLin,013 psay QSF1->F1_DOC  

   @ nLin,023 psay QSF1->F1_FORNECE+"/"+QSF1->F1_LOJA   
   
   If QSF1->F1_TIPO $ "B/D"
      @ nLin,035 psay Posicione("SA1",1,Xfilial("SA1")+QSF1->F1_FORNECE+QSF1->F1_LOJA,"A1_NOME")
   Else
      @ nLin,035 psay Posicione("SA2",1,Xfilial("SA2")+QSF1->F1_FORNECE+QSF1->F1_LOJA,"A2_NOME")
   Endif   

   //@ nLin,035 psay Posicione("SA2",1,Xfilial("SA2")+QSF1->F1_FORNECE+QSF1->F1_LOJA,"A2_NREDUZ") PICTURE "@!"
   
   @ nLin,087 psay QSF1->F1_EMISSAO
   @ nLin,097 psay QSF1->F1_DTDIGIT
   @ nLin,106 psay QSF1->F1_VALBRUT picture "@E 99,999,999.99"

   //@ nLin,166 psay QSF1->F1_VALICM  picture "@E 999,999.99"
   //@ nLin,177 psay QSF1->F1_BASEIPI picture "@E 99,999,999.99" 
   //@ nLin,191 psay QSF1->F1_VALIPI  picture "@E 999,999.99"
   //@ nLin,170 psay QSF1->F1_ESPECIE
   
   nCount++
   
   /*
   aCFO := {} 
   dbSelectArea("SD1")                   // * Itens da N.F. de Compra
   dbSetOrder(1)
   dbSeek(QSF1->F1_FILIAL+QSF1->F1_DOC+QSF1->F1_SERIE+QSF1->F1_FORNECE+QSF1->F1_LOJA,.F.)
   DO WHILE !EOF() .AND. QSF1->F1_FILIAL+QSF1->F1_DOC+QSF1->F1_SERIE+QSF1->F1_FORNECE+QSF1->F1_LOJA == SD1->D1_FILIAL+SD1->D1_DOC+ SD1->D1_SERIE+ SD1->D1_FORNECE+ SD1->D1_LOJA   
      IF Ascan(aCFO,SD1->D1_CF) = 0
         AADD(aCFO,SD1->D1_CF)
      ENDIF
      dbSkip()
   ENDDO
   cCFO := ""
   FOR nI := 1 TO LEN(aCFO)
       cCFO += TRIM(aCFO[nI])
       IF nI < LEN(aCFO)
          cCFO += "/"
       ENDIF
   NEXT    
   @ nLin,175 psay cCFO
   */ 
   
   lPula := .T.
   
   Dbselectarea("SE2")
   SE2->(Dbsetorder(6))
   DbSeek(QSF1->F1_FILIAL+QSF1->F1_FORNECE+QSF1->F1_LOJA+QSF1->F1_SERIE+QSF1->F1_DOC,.T.)
   Do While !EOF() .AND. SE2->E2_FILIAL  == QSF1->F1_FILIAL  ;
                   .AND. SE2->E2_FORNECE == QSF1->F1_FORNECE ;
                   .AND. SE2->E2_LOJA    == QSF1->F1_LOJA    ;
                   .AND. SE2->E2_PREFIXO == QSF1->F1_SERIE   ;
                   .AND. SE2->E2_NUM     == QSF1->F1_DOC
      
      @ nLin,122 psay SE2->E2_PREFIXO+"/"+SE2->E2_NUM+"/"+SE2->E2_PARCELA
      @ nLin,139 psay SE2->E2_TIPO
      @ nLin,143 psay SE2->E2_VENCTO
      @ nLin,153 psay SE2->E2_VALOR picture "@E 99,999,999.99"
      
      nTValor1 += SE2->E2_VALOR
      nLin := nLin + 1 // Avanca a linha de impressao
      lPula := .F.
      If nLin > 63 // Salto de Pแgina. Neste caso o formulario tem 55 linhas...
         Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
         nLin := 8
      Endif
      cPrefixo := SE2->E2_PREFIXO

	cParcCSS := SE2->E2_PARCCSS
	cParcIR  := SE2->E2_PARCIR
	cParcINSS:= SE2->E2_PARCINS
	cParcISS := SE2->E2_PARCISS
	cParcCof := SE2->E2_PARCCOF
	cParcPis := SE2->E2_PARCPIS
	cParcCsll:= SE2->E2_PARCSLL
      
	cUniao := PadR(GetMv('MV_UNIAO') ,Len(SE2->E2_FORNECE)) + PadR('00',Len(SE2->E2_LOJA))
	cINSS  := PadR(GetMv('MV_FORINSS'),Len(SE2->E2_FORNECE))+ PadR('00',Len(SE2->E2_LOJA))
	cMunic := PadR(GetMv('MV_MUNIC'),Len(SE2->E2_FORNECE))  + PadR('00',Len(SE2->E2_LOJA))
	                                                                                      
	cTxUniao := "TX "  // PadR(MVTAXA,Len(SE2->E2_TIPO))
	cTxINSS  := "INS"  // PadR(MVINSS,Len(SE2->E2_TIPO))
	cTxMunic := "ISS"  //PadR(MVISS,Len(SE2->E2_TIPO))

    aAreaSE2 := SE2->(GetArea())
	
	dbSelectArea('SE2')
	dbSetOrder(1)
	If (!Empty(cParcIR)).And.dbSeek(xFilial()+cPrefixo+(cAliasSF1)->F1_DOC+cParcIR+cTxUniao+cUniao)
       @ nLin,122 psay "IRRF"  //SE2->E2_PREFIXO+"/"+SE2->E2_NUM+"/"+SE2->E2_PARCELA
       @ nLin,139 psay SE2->E2_TIPO
       @ nLin,143 psay SE2->E2_VENCTO
       @ nLin,153 psay SE2->E2_VALOR picture "@E 99,999,999.99"
       nTValor1 += SE2->E2_VALOR
       nLin := nLin + 1
       If nLin > 63
          Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
          nLin := 8
       Endif
	Endif

    If (!Empty(cParcINSS)).And.dbSeek(xFilial()+cPrefixo+(cAliasSF1)->F1_DOC+cParcINSS+cTxINSS+cINSS)
       @ nLin,122 psay "INSS"  //SE2->E2_PREFIXO+"/"+SE2->E2_NUM+"/"+SE2->E2_PARCELA
       @ nLin,139 psay SE2->E2_TIPO
       @ nLin,143 psay SE2->E2_VENCTO
       @ nLin,153 psay SE2->E2_VALOR picture "@E 99,999,999.99"
       nTValor1 += SE2->E2_VALOR
       nLin := nLin + 1
       If nLin > 63
          Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
          nLin := 8
       Endif
	Endif

	If (!Empty(cParcISS)).And.dbSeek(xFilial()+cPrefixo+(cAliasSF1)->F1_DOC+cParcISS+cTxMunic+cMunic)
       @ nLin,122 psay "ISS"  //SE2->E2_PREFIXO+"/"+SE2->E2_NUM+"/"+SE2->E2_PARCELA
       @ nLin,139 psay SE2->E2_TIPO
       @ nLin,143 psay SE2->E2_VENCTO
       @ nLin,153 psay SE2->E2_VALOR picture "@E 99,999,999.99"
       nTValor1 += SE2->E2_VALOR
       nLin := nLin + 1
       If nLin > 63
          Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
          nLin := 8
       Endif
	Endif
	
	If (!Empty(cParcCof)).And.dbSeek(xFilial()+cPrefixo+(cAliasSF1)->F1_DOC+cParcCof+cTxUniao+cUniao)
       @ nLin,122 psay "COFINS"  //SE2->E2_PREFIXO+"/"+SE2->E2_NUM+"/"+SE2->E2_PARCELA
       @ nLin,139 psay SE2->E2_TIPO
       @ nLin,143 psay SE2->E2_VENCTO
       @ nLin,153 psay SE2->E2_VALOR picture "@E 99,999,999.99"
       nTValor1 += SE2->E2_VALOR
       nLin := nLin + 1
       If nLin > 63
          Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
          nLin := 8
       Endif
	Endif

	If (!Empty(cParcPis)).And.dbSeek(xFilial()+cPrefixo+(cAliasSF1)->F1_DOC+cParcPis+cTxUniao+cUniao)
       @ nLin,122 psay "PIS"  //SE2->E2_PREFIXO+"/"+SE2->E2_NUM+"/"+SE2->E2_PARCELA
       @ nLin,139 psay SE2->E2_TIPO
       @ nLin,143 psay SE2->E2_VENCTO
       @ nLin,153 psay SE2->E2_VALOR picture "@E 99,999,999.99"
       nTValor1 += SE2->E2_VALOR
       nLin := nLin + 1
       If nLin > 63
          Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
          nLin := 8
       Endif
	Endif
	

	If (!Empty(cParcCsll)).And.dbSeek(xFilial()+cPrefixo+(cAliasSF1)->F1_DOC+cParcCsll+cTxUniao+cUniao)
       @ nLin,122 psay "CSLL"  //SE2->E2_PREFIXO+"/"+SE2->E2_NUM+"/"+SE2->E2_PARCELA
       @ nLin,139 psay SE2->E2_TIPO
       @ nLin,143 psay SE2->E2_VENCTO
       @ nLin,153 psay SE2->E2_VALOR picture "@E 99,999,999.99"

       nTValor1 += SE2->E2_VALOR
       nLin := nLin + 1
       If nLin > 63
          Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
          nLin := 8
       Endif
	Endif

      //nLin := nLin + 1 // Avanca a linha de impressao

      RestArea(aAreaSE2)
      SE2->(dbSkip())
   Enddo


   If lPula
      nLin := nLin + 1 // Avanca a linha de impressao
   Endif   
   nTvalor += QSF1->F1_VALBRUT
   
   QSF1->(dbSkip()) // Avanca o ponteiro do registro no arquivo
EndDo

If nLin <> 80
	nLin++
	@ nLin,007 psay "Totais  ("+ALLTRIM(STR(nCount,5))+" documentos)"
	@ nLin,106 psay nTvalor  picture "@E 999,999,999.99"
	@ nLin,152 psay nTvalor1 picture "@E 999,999,999.99"
	@ nLin+1,1 psay ""
EndIf
	
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Finaliza a execucao do relatorio...                                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

SET DEVICE TO SCREEN

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

QSF1->(Dbclosearea())

Return

Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Da Data ?" ,"ฟDa Data ?" ,"Da Data ?" ,"mv_ch1","D",8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Ate Data ?","ฟAte Data ?","Ate Data ?","mv_ch2","D",8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Filial ?"  ,"ฟFilial ?"  ,"Filial ?"  ,"mv_ch3","C",2,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"04","Ordem de:" ,"Ordem de"   ,"Ordem de"  ,"mv_ch4","N",1,0,2,"C","","mv_par04","Documento","Documento","Documento","","","Data","Data","Data","","","","","","","","","","","","","","","","",""})

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
