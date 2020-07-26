#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"


/*/{Protheus.doc} BKGCTR09
BK - Projeção Financeira dos Contratos
@Return
@author Adilson do Prado / Marcos Bispo Abrahão
@since 16/02/12
@version P12
/*/

User Function BKGCTR09()

Local titulo	:= "Projeção Financeira dos Contratos"
Local _nI
Local aDbf 		:= {}
Local aDbf2 	:= {}
Local oTmpTb1
Local oTmpTb2

Local cMes := ""

Private aMeses	:= {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := " "
Private nomeprog     := "BKGCTR09" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cPerg        := "BKGCTR09"
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "BKGCTR09" // Coloque aqui o nome do arquivo usado para impressao em disco

PRIVATE dDataInicio  := dDatabase
PRIVATE dDataFinal   := dDatabase
PRIVATE	cPict        := "@E 99,999,999,999.99"
PRIVATE nPeriodo     := 1
PRIVATE nAgrupar     := 1
PRIVATE nAnalitico   := 1
PRIVATE nCentavos    := 1
PRIVATE nPlan        := 1
PRIVATE cContrCli	 := ""
Private aHeader	     := {}
PRIVATE aTitulos,aCampos,aCabs,aCampos2,aCabs2
PRIVATE ALIAS_TMP    := "TMPC"+ALLTRIM(SM0->M0_CODIGO)
PRIVATE aDDespesas	 := {} //Detalhar despesas
PRIVATE aConsorcio	:= {}
PRIVATE aContrCons	:= {}  
PRIVATE nIndConsor	:= 1
Private aPeriodo

aContrCons	:= StrTokArr(ALLTRIM(GetMv("MV_XXCONS1"))+ALLTRIM(GetMv("MV_XXCONS2"))+ALLTRIM(GetMv("MV_XXCONS3"))+ALLTRIM(GetMv("MV_XXCONS4")),"/") //"163000240"

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

nAgrupar     := mv_par01
cContrCli    := mv_par02
nAnalitico   := mv_par03
nCentavos    := mv_par04

IF nCentavos <> 1
	cPict := "@E 99,999,999,999"
ENDIF

IF dDataFinal < dDataInicio
	MSGSTOP("Data deve ser maior ou igual que a database")                
	Return Nil
ENDIF

FOR IX:= 1 TO LEN(aContrCons)
    AADD(aConsorcio,StrTokArr(aContrCons[IX],";"))
NEXT

cQuery := " SELECT TOP 1 CNF_DTVENC"
cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"
cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9_SITUAC NOT IN ('01','02','08','09','10')"
cQuery += " AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = '' WHERE CNF.D_E_L_E_T_='' ORDER BY CNF_DTVENC DESC"

TCQUERY cQuery NEW ALIAS "QTMP1"
TCSETFIELD("QTMP1","CNF_DTVENC","D",8,0)	
dbSelectArea("QTMP1")

dDataFinal := QTMP1->CNF_DTVENC

QTMP1->(Dbclosearea())

//Determina quantos Meses utilizar no calculo
nPeriodo += DateDiffMonth( dDataInicio , dDataFinal )

titulo   := titulo+" - Período:"+DTOC(dDataInicio)+" até "+DTOC(dDataFinal)

aDbf    := {}
Aadd( aDbf, { 'XX_LINHA', 'N', 10,00 } )
Aadd( aDbf, { 'XX_CODGCT','C', 20,00 } )
Aadd( aDbf, { 'XX_NOME',  'C', 80,00 } )
Aadd( aDbf, { 'XX_CODIGO','C', 40,00 } )
FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,3)
	Aadd( aDbf, { 'XX_VAL'+cMes,'C', 25,00 } )
NEXT

Aadd( aDbf, { 'XX_STATUS','C', 2,00 } )

///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,'TRB',.f.,.f. )
///IndRegua("TRB",cArqTmp,"XX_LINHA",,,"Indexando Arquivo de Trabalho") 

oTmpTb1 := FWTemporaryTable():New("TRB")
oTmpTb1:SetFields( aDbf )
oTmpTb1:AddIndex("indice1", {"XX_LINHA"} )
oTmpTb1:Create()

aCabs   := {}
aCampos := {}
aTitulos:= {}

nomeprog := "BKGCTR09/"+TRIM(SUBSTR(cUsuario,7,15))

AADD(aTitulos,nomeprog+" - "+titulo)

AADD(aCampos,"TRB->XX_LINHA")
AADD(aCabs  ,"Linha")

AADD(aCampos,"TRB->XX_CODGCT")
AADD(aCabs  ,"Contrato/Cliente")
aadd(aHeader,{"Contrato/Cliente","XX_CODGCT" ,"@!",20,00,"","","C","TRB","R"})

AADD(aCampos,"TRB->XX_NOME")
AADD(aCabs  ,"Descrição")
aadd(aHeader,{"Descrição","XX_NOME" ,"@!",40,00,"","","C","TRB","R"})
                                                                                                               
AADD(aCampos,"TRB->XX_CODIGO")
AADD(aCabs  ,"Projeção")
aadd(aHeader,{"Projeção","XX_CODIGO" ,"@!",20,00,"","","C","TRB","R"})

FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,3)
	AADD(aCampos,"TRB->XX_VAL"+cMes)
	AADD(aCabs,STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4))
	aadd(aHeader,{STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4),"XX_VAL"+cMes ,"@!",10,00,"","","C","TRB","R"})

 	dDataInicio := MonthSum(dDataInicio,1)
NEXT

AADD(aCampos,"TRB->XX_STATUS")

aDbf2    := {}

Aadd( aDbf2, { 'XX_CODGCT','C', 20,00 } )
Aadd( aDbf2, { 'XX_NOME',  'C', 80,00 } )
Aadd( aDbf2, { 'XX_CODIGO','C', 40,00 } )
FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,3)
	Aadd( aDbf2, { 'XX_VAL'+cMes,'N', 18,02 } )
NEXT

///cArqTmp2 := CriaTrab( aDbf2, .T. )
///dbUseArea( .T.,NIL,cArqTmp2,ALIAS_TMP,.F.,.F. )
///IndRegua(ALIAS_TMP,cArqTmp2,"XX_CODGCT+XX_CODIGO",,,"Indexando Arquivo de Trabalho") 
///dbSetIndex(cArqTmp2+ordBagExt())

oTmpTb2 := FWTemporaryTable():New(ALIAS_TMP)
oTmpTb2:SetFields( aDbf2 )
oTmpTb2:AddIndex("indice2", {"XX_CODGCT","XX_CODIGO"} )
oTmpTb2:Create()


aCabs2   := {}
aCampos2 := {}


AADD(aCampos2,ALIAS_TMP+"->XX_CODGCT")
AADD(aCabs2  ,"Contrato/Cliente")

AADD(aCampos2,ALIAS_TMP+"->XX_NOME")
AADD(aCabs2  ,"Descrição")
                                                                                                               
AADD(aCampos2,ALIAS_TMP+"->XX_CODIGO")
AADD(aCabs2  ,"Projeção")


aPeriodo := {}

dDataInicio  := dDatabase

FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,3)
	AADD(aCampos2,ALIAS_TMP+"->XX_VAL"+cMes)
	AADD(aCabs2,STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4))
  	AAdd(aPeriodo,{STRZERO(Month(dDataInicio),2)+"/"+STRZERO(YEAR(dDataInicio),4)})
	dDataInicio := MonthSum(dDataInicio,1)
NEXT


ProcRegua(1000)

Processa( {|| ProcQuery(1) })

Processa ( {|| MBrwBKGCTR09()})

oTmpTb1:Delete()
oTmpTb2:Delete()

///(ALIAS_TMP)->(Dbclosearea())
///FErase(cArqTmp2+GetDBExtension())
///FErase(cArqTmp2+OrdBagExt())                     

///TRB->(Dbclosearea())
///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())                     
 
Return


Static Function MBrwBKGCTR09()
Local 	cAlias 		:= "TRB"

Private cCadastro	:= "Relatório Projeção Financeira dos Contratos"
Private aRotina		:= {}
Private aIndexSz  	:= {}

Private aSize   := MsAdvSize(,.F.,400)
Private aObjects:= { { 450, 450, .T., .T. } }
Private aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aPosObj := MsObjSize( aInfo, aObjects, .T. )
Private lRefresh:= .T.
Private aButton := {}
Private _oGetDbSint
Private _oDlgSint

AADD(aRotina,{"Exp. Excel"	,"U_CSVBKGCTR09",0,6})
AADD(aRotina,{"Parametros"	,"U_PARBKGCTR09",0,7})
AADD(aRotina,{"Legenda"		,"U_LegendaBKGCTR09",0,8})


dbSelectArea(cAlias)
dbSetOrder(1)
	
DEFINE MSDIALOG _oDlgSint ;
TITLE cCadastro ;
From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
_oGetDbSint := MsGetDb():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], 2, "AllwaysTrue()", "AllwaysTrue()",,,,,,"AllwaysTrue()","TRB")
	
aadd(aButton , { "BMPTABLE" , { || U_CSVBKGCTR09(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Gera Planilha Excel" } )
aadd(aButton , { "BMPTABLE" , { || U_PARBKGCTR09(), TRB->(dbgotop()), _oGetDbSint:ForceRefresh(), _oDlgSint:Refresh()}, "Parametros" } )
aadd(aButton , { "BMPTABLE" , { || U_LegendaBKGCTR09()}, "Legenda" } )

	
ACTIVATE MSDIALOG _oDlgSint ON INIT EnchoiceBar(_oDlgSint,{|| _oDlgSint:End()}, {||_oDlgSint:End()},, aButton)

Return Nil



User Function LegendaBKGCTR09()
Local aLegenda := {}

AADD(aLegenda,{"BR_AZUL" ,"Por Cliente - Analítico" })
AADD(aLegenda,{"BR_VERDE" ,"Por Cliente - Sintético" })
AADD(aLegenda,{"BR_CINZA" ,"Por Contrato - Analítico" })
AADD(aLegenda,{"BR_LARANJA" ,"Por Contrato - Sintético" })
AADD(aLegenda,{"BR_MARRON" ,"Por Totais - Analítico" })
AADD(aLegenda,{"BR_PINK" ,"Por Totais - Sintético" })
AADD(aLegenda,{"BR_VERMELHO" ,"Em branco" })

BrwLegenda(cCadastro, "Legenda", aLegenda)
Return Nil



User FUNCTION PARBKGCTR09()

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

nAgrupar     := mv_par01
cContrCli    := mv_par02
nAnalitico   := mv_par03
nCentavos    := mv_par04

IF nCentavos == 1
	cPict := "@E 99,999,999,999.99"
ELSE
	cPict := "@E 99,999,999,999"
ENDIF

ProcRegua(1000)

Processa( {|| ProcQuery(0) })

Return Nil



Static Function LimpaBrw(cAlias)
	DbSelectArea(cAlias)
	(cAlias)->(dbgotop())
	Do While (cAlias)->(!eof())
		RecLock(cAlias,.F.)
		(cAlias)->(dbDelete())
		(cAlias)->(MsUnlock())
       	dbselectArea(cAlias)
   		(cAlias)->(dbskip())
	ENDDO

Return (.T.)



User FUNCTION CSVBKGCTR09()
Local cAlias := "TRB"

dbSelectArea(cAlias)

ProcRegua(1000)
Processa( {|| GeraCSVBKGCTR09(cAlias,TRIM(wnrel),aTitulos,aCampos,aCabs)})

Return Nil

   

Static Function ProcQuery(nOpc)
Local cQuery

LimpaBrw ("TRB")
LimpaBrw (ALIAS_TMP)
aTESTE := {}
cTESTE := "{34},{0},{0},{6},{'ABC'}"            

AADD(aTESTE,{&cTESTE})

aCroXPla := {}
FOR _nI := 1 TO nPeriodo
	IncProc("Consultando o banco de dados...")

	cQuery := " SELECT CNF_CONTRA,CN9_REVISA,CN9_SITUAC,CN9_CLIENT,CN9_NOMCLI,CTT_DESC01,CN9_XXDESC,CNF_COMPET,SUM(CNF_VLPREV) AS CNF_FATURA"
	cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"
    cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9.CN9_NUMERO = CNF.CNF_CONTRA AND CN9.CN9_REVISA = CNF.CNF_REVISA AND  CN9.CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''"
	cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"
	cQuery += " AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ''"
	cQuery += " WHERE CNF.D_E_L_E_T_='' AND CNF.CNF_COMPET='"+aPeriodo[_nI,1]+"' AND CN9.CN9_SITUAC NOT IN ('01','02','08','09','10')"
    IF !EMPTY(cContrCli)
    	IF nAgrupar == 1
    		cQuery += " AND CN9_CLIENT ='"+ALLTRIM(cContrCli)+"'"
    	ELSEIF nAgrupar == 2
    		cQuery += " AND CNF_CONTRA ='"+ALLTRIM(cContrCli)+"'"
    	ENDIF
    ENDIF	
	cQuery += " GROUP BY CNF_CONTRA,CN9_REVISA,CN9_SITUAC,CN9_CLIENT,CN9_NOMCLI,CTT_DESC01,CN9_XXDESC,CNF_COMPET ORDER BY CNF_CONTRA,CN9_REVISA,CN9_SITUAC,CN9_NOMCLI,CN9_XXDESC,CNF_COMPET"
 
	TCQUERY cQuery NEW ALIAS "QTMP"

	nFatTOT := 0
	nDespTOT:= 0
	dbSelectArea("QTMP")
	QTMP->(dbGoTop())
	DO WHILE QTMP->(!EOF())
		IncProc("Criando arquivo temporario...")
		
        nIndTC := 0
        IF nIndConsor == 1
			nScan:= 0
			nScan:= aScan(aConsorcio,{|x| x[1]==ALLTRIM(QTMP->CNF_CONTRA) })
		    IF nScan > 0
		       nIndTC := VAL(aConsorcio[nScan,6]) 
		    ENDIF
        ENDIF


		nFatCLI := 0
		nDespCLI:= 0
        nDespesa   := 0
        aDespesas  := {}
        AADD(aDespesas,{"0-FATURAMENTO","S",IIF(nIndTC>0,QTMP->CNF_FATURA/(nIndTC/100),QTMP->CNF_FATURA)})              
        AADD(aDespesas,{"1-DESPESAS","S",0})            
        AADD(aDespesas,{"1.1-Remuneração CLT","N",0})            
        AADD(aDespesas,{"1.2-Encargos Sociais","N",0})            
        AADD(aDespesas,{"1.3-Ajuda de Custo","N",0})            
        AADD(aDespesas,{"1.4-Encargos Ajuda de Custo","N",0})            
        AADD(aDespesas,{"1.5-Insumos","N",0})            
        AADD(aDespesas,{"1.5.1-Benefícios","N",0})
        AADD(aDespesas,{"1.5.2-Uniformes","N",0})            
        AADD(aDespesas,{"1.5.3-Despesas Diversas","N",0})            
        AADD(aDespesas,{"1.6-Materiais","N",0})            
        AADD(aDespesas,{"1.7-Equipamentos","N",0})            
        AADD(aDespesas,{"1.8-Tributos","N",0})            
        AADD(aDespesas,{"1.9-Rentabilidade","N",0}) 
        AADD(aDespesas,{"2-RESULTADO","S",0}) 
        AADD(aDespesas,{"3-RESULTADO %","S",0}) 

		dDtProj     := CTOD("")
		cSeqProj	:= ""
        nXXTotal := 0
        dbselectArea("SZG")
		cContRev := xFilial("SZG")+QTMP->CNF_CONTRA //+QTMP->CN9_REVISA
		dbSeek(cContRev,.T.)
		Do While !EOF() .AND. ALLTRIM(cContRev) == ALLTRIM(SZG->ZG_FILIAL+SZG->ZG_CONTRAT) //+SZG->ZG_REVISAO
             IF SUBSTR(DTOS(SZG->ZG_DATA),1,6) <= SUBSTR(ALLTRIM(QTMP->CNF_COMPET),4,4)+SUBSTR(ALLTRIM(QTMP->CNF_COMPET),1,2)
   				nDespesa   := 0
         		nDespesa   := SZG->ZG_CLT+SZG->ZG_VLENCSO+SZG->ZG_AJCUSTO+SZG->ZG_VLENAC+SZG->ZG_BENEFIC+SZG->ZG_UNIFORM+SZG->ZG_DESPDIV+SZG->ZG_MATERIA+SZG->ZG_EQUIPAM+SZG->ZG_VLTRIBU
         		nDespesa   := IIF(nIndTC>0,(nDespesa)/(nIndTC/100),nDespesa)             
				aDespesas[02,03] := nDespesa
				aDespesas[03,03] := IIF(nIndTC>0,(SZG->ZG_CLT)/(nIndTC/100),SZG->ZG_CLT)            
    			aDespesas[04,03] := IIF(nIndTC>0,(SZG->ZG_VLENCSO )/(nIndTC/100),SZG->ZG_VLENCSO )           
       			aDespesas[05,03] := IIF(nIndTC>0,(SZG->ZG_AJCUSTO)/(nIndTC/100),SZG->ZG_AJCUSTO)            
          		aDespesas[06,03] := IIF(nIndTC>0,(SZG->ZG_VLENAC )/(nIndTC/100),SZG->ZG_VLENAC )           
          		aDespesas[07,03] := IIF(nIndTC>0,(SZG->ZG_BENEFIC+SZG->ZG_UNIFORM+SZG->ZG_DESPDIV)/(nIndTC/100),SZG->ZG_BENEFIC+SZG->ZG_UNIFORM+SZG->ZG_DESPDIV)           
          		aDespesas[08,03] := IIF(nIndTC>0,(SZG->ZG_BENEFIC)/(nIndTC/100),SZG->ZG_BENEFIC)
          		aDespesas[09,03] := IIF(nIndTC>0,(SZG->ZG_UNIFORM )/(nIndTC/100),SZG->ZG_UNIFORM )           
          		aDespesas[10,03] := IIF(nIndTC>0,(SZG->ZG_DESPDIV)/(nIndTC/100),SZG->ZG_DESPDIV)
         		aDespesas[11,03] := IIF(nIndTC>0,(SZG->ZG_MATERIA)/(nIndTC/100),SZG->ZG_MATERIA)            
          		aDespesas[12,03] := IIF(nIndTC>0,(SZG->ZG_EQUIPAM )/(nIndTC/100),SZG->ZG_EQUIPAM )           
          		aDespesas[13,03] := IIF(nIndTC>0,(SZG->ZG_VLTRIBU)/(nIndTC/100),SZG->ZG_VLTRIBU)            
          		aDespesas[14,03] := IIF(nIndTC>0,QTMP->CNF_FATURA/(nIndTC/100),QTMP->CNF_FATURA)-nDespesa //SZG->ZG_VLRENTA 
          		aDespesas[15,03] := IIF(nIndTC>0,QTMP->CNF_FATURA/(nIndTC/100),QTMP->CNF_FATURA)-nDespesa 
          		aDespesas[16,03] := ((IIF(nIndTC>0,QTMP->CNF_FATURA/(nIndTC/100),QTMP->CNF_FATURA)-nDespesa)*100)/IIF(nIndTC>0,QTMP->CNF_FATURA/(nIndTC/100),QTMP->CNF_FATURA)
          		nXXTotal := IIF(nIndTC>0,SZG->ZG_TOTAL/(nIndTC/100),SZG->ZG_TOTAL)
				dDtProj     := SZG->ZG_DATA
				cSeqProj	:= SZG->ZG_SEQ

            ENDIF
        	dbselectArea("SZG")
	   		SZG->(dbSkip())
		ENDDO
		if nXXTotal <> 0
			IF transform(nXXTotal,cPict) <> transform(IIF(nIndTC>0,QTMP->CNF_FATURA/(nIndTC/100),QTMP->CNF_FATURA),cPict)
		    	AADD(aCroXPla,"Contrato: "+QTMP->CNF_CONTRA+QTMP->CN9_REVISA+"   Competência: "+QTMP->CNF_COMPET+"  Valor do Cronograma: "+transform(IIF(nIndTC>0,QTMP->CNF_FATURA/(nIndTC/100),QTMP->CNF_FATURA),cPict)+"  diferente do Valor da Planilha: "+transform(nXXTotal,cPict))
		    ENDIF
		ENDIF

		nFatCLI := 0
		nDespCLI:= 0
        IF nAgrupar < 3
        	IF nAgrupar == 1
        	   cCliCod	:= ALLTRIM(QTMP->CN9_CLIENTE)
        	   cCliente := ALLTRIM(QTMP->CN9_NOMCLI)
        	ELSE
        	   cCliCod  := ALLTRIM(QTMP->CNF_CONTRA+QTMP->CN9_REVISA)
        	   cCliente := ALLTRIM(QTMP->CTT_DESC01)
        	ENDIF
			FOR _nJ := 1 TO LEN(aDespesas)
				IF nAnalitico==2
					IF aDespesas[_nJ,2] == "S"
						dbSelectArea(ALIAS_TMP)
						IF dbSeek(PAD(cCliCod,20)+PAD(aDespesas[_nJ,1],40),.F.)
							Reclock(ALIAS_TMP,.F.)
						ELSE
							Reclock(ALIAS_TMP,.T.)
							(ALIAS_TMP)->XX_CODIGO := aDespesas[_nJ,1]
							(ALIAS_TMP)->XX_CODGCT := cCliCod
							(ALIAS_TMP)->XX_NOME   := cCliente
						ENDIF
						IF SUBSTR(aDespesas[_nJ,1],1,2) == "2-"
							cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
							&cCampo2 := nFatCLI-nDespCLI
						ELSEIF SUBSTR(aDespesas[_nJ,1],1,2) == "3-"
							cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
							&cCampo2 := ((nFatCLI-nDespCLI)*100)/nFatCLI
						ELSE
							cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
							&cCampo2 += aDespesas[_nJ,3]
							IF SUBSTR(aDespesas[_nJ,1],1,2) == "0-"
						       nFatCli  += aDespesas[_nJ,3]
							ELSEIF SUBSTR(aDespesas[_nJ,1],1,2) == "1-"
						       nDespCli += aDespesas[_nJ,3]
						    ENDIF
						ENDIF
						(ALIAS_TMP)->(Msunlock())
					ENDIF
				ELSE
					dbSelectArea(ALIAS_TMP)
					IF dbSeek(PAD(cCliCod,20)+PAD(aDespesas[_nJ,1],40),.F.)
						Reclock(ALIAS_TMP,.F.)
					ELSE
						Reclock(ALIAS_TMP,.T.)
						(ALIAS_TMP)->XX_CODIGO := aDespesas[_nJ,1]
						(ALIAS_TMP)->XX_CODGCT := cCliCod
						(ALIAS_TMP)->XX_NOME   := cCliente
					ENDIF
					IF SUBSTR(aDespesas[_nJ,1],1,2) == "2-"
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
						&cCampo2 := nFatCLI-nDespCLI
					ELSEIF SUBSTR(aDespesas[_nJ,1],1,2) == "3-"
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
						&cCampo2 := ((nFatCLI-nDespCLI)*100)/nFatCLI
					ELSE
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
						&cCampo2 += aDespesas[_nJ,3]
						IF SUBSTR(aDespesas[_nJ,1],1,2) == "0-"
					       nFatCLI  += aDespesas[_nJ,3]
						ELSEIF SUBSTR(aDespesas[_nJ,1],1,2) == "1-"
					       nDespCLI += aDespesas[_nJ,3]
					    ENDIF
					ENDIF
					(ALIAS_TMP)->(Msunlock())  
					
					//DETALHAR - DESPESAS DIVERSAS
					IF !EMPTY(cSeqProj)
						dbSelectArea("SZL")
						SZL->(dbSetOrder(1))
						SZL->(dbSeek(xFilial("SZL")+ALLTRIM(QTMP->CNF_CONTRA)+"01"+DTOS(dDtProj)+cSeqProj,.T.))
						DO WHILE SZL->(!EOF()) .AND. SZL->ZL_CONTRAT==ALLTRIM(QTMP->CNF_CONTRA)
							IF SZL->ZL_DATA==dDtProj .AND. SZL->ZL_SEQ==cSeqProj .AND. SZL->ZL_VALOR > 0
								IF SZL->ZL_TIPO=="01"
									dbSelectArea(ALIAS_TMP)
									IF dbSeek(PAD(cCliCod,20)+PAD("1.5.1.1-"+SZL->ZL_DESC,40),.F.)
										Reclock(ALIAS_TMP,.F.)
									ELSE
										Reclock(ALIAS_TMP,.T.)
										(ALIAS_TMP)->XX_CODIGO := "1.5.1.1-"+SZL->ZL_DESC
										(ALIAS_TMP)->XX_CODGCT := cCliCod
										(ALIAS_TMP)->XX_NOME   := cCliente
									ENDIF
									cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
									&cCampo2 := IIF(nIndTC>0,SZL->ZL_VALOR/(nIndTC/100),SZL->ZL_VALOR)
									(ALIAS_TMP)->(Msunlock())
								 
								ELSEIF SZL->ZL_TIPO=="02" 
									dbSelectArea(ALIAS_TMP)
									IF dbSeek(PAD(cCliCod,20)+PAD("1.5.3.1-"+SZL->ZL_DESC,40),.F.)
										Reclock(ALIAS_TMP,.F.)
									ELSE
										Reclock(ALIAS_TMP,.T.)
										(ALIAS_TMP)->XX_CODIGO := "1.5.3.1-"+SZL->ZL_DESC
										(ALIAS_TMP)->XX_CODGCT := cCliCod
										(ALIAS_TMP)->XX_NOME   := cCliente
									ENDIF
									cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
									&cCampo2 := IIF(nIndTC>0,SZL->ZL_VALOR/(nIndTC/100),SZL->ZL_VALOR)
									(ALIAS_TMP)->(Msunlock())
		    	  				ENDIF
		    	  			ENDIF
							SZL->(dbskip())
						ENDDO
					ENDIF
				ENDIF
			NEXT
        ENDIF
		FOR _nJ := 1 TO LEN(aDespesas)
			IF nAnalitico==2
				IF aDespesas[_nJ,2] == "S"
					dbSelectArea(ALIAS_TMP)
					IF dbSeek(PAD("TOTAL",20)+PAD(aDespesas[_nJ,1],40),.F.)
						Reclock(ALIAS_TMP,.F.)
					ELSE
						Reclock(ALIAS_TMP,.T.)
						(ALIAS_TMP)->XX_CODIGO := aDespesas[_nJ,1]
						(ALIAS_TMP)->XX_CODGCT := "TOTAL"
						(ALIAS_TMP)->XX_NOME   := "TOTAL"
					ENDIF
					IF SUBSTR(aDespesas[_nJ,1],1,2) == "2-"
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
						&cCampo2 := nFatTOT-nDespTOT
					ELSEIF SUBSTR(aDespesas[_nJ,1],1,2) == "3-"
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
						&cCampo2 := ((nFatTOT-nDespTOT)*100)/nFatTOT
					ELSE
						cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
						&cCampo2 += aDespesas[_nJ,3]
						IF SUBSTR(aDespesas[_nJ,1],1,2) == "0-"
					       nFatTOT  += aDespesas[_nJ,3]
						ELSEIF SUBSTR(aDespesas[_nJ,1],1,2) == "1-"
					       nDespTOT += aDespesas[_nJ,3]
					    ENDIF
					ENDIF
					(ALIAS_TMP)->(Msunlock())
				ENDIF
			ELSE
				dbSelectArea(ALIAS_TMP)
				IF dbSeek(PAD("TOTAL",20)+PAD(aDespesas[_nJ,1],40),.F.)
					Reclock(ALIAS_TMP,.F.)
				ELSE
					Reclock(ALIAS_TMP,.T.)
					(ALIAS_TMP)->XX_CODIGO := aDespesas[_nJ,1]
					(ALIAS_TMP)->XX_CODGCT := "TOTAL"
					(ALIAS_TMP)->XX_NOME   := "TOTAL"
				ENDIF
				IF SUBSTR(aDespesas[_nJ,1],1,2) == "2-"
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 := nFatTOT-nDespTOT
				ELSEIF SUBSTR(aDespesas[_nJ,1],1,2) == "3-"
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 := ((nFatTOT-nDespTOT)*100)/nFatTOT
				ELSE
					cCampo2  := ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
					&cCampo2 += aDespesas[_nJ,3]
					IF SUBSTR(aDespesas[_nJ,1],1,2) == "0-"
				       nFatTOT  += aDespesas[_nJ,3]
					ELSEIF SUBSTR(aDespesas[_nJ,1],1,2) == "1-"
				       nDespTOT += aDespesas[_nJ,3]
				    ENDIF
				ENDIF
				(ALIAS_TMP)->(Msunlock())
			ENDIF
		NEXT
	   	dbSelectArea("QTMP")
	   	QTMP->(dbSkip())
	ENDDO
    QTMP->(dbCloseArea())
NEXT

//Verifica o Crupo do usuario - visualização do relatorio
PswOrder(1) 
PswSeek(__CUSERID) 
aUser  := PswRet(1)

cCodView := ""
//cCodView := SuperGetMV("MV_XXPROJE")

cCodView := "0-FATURAMENTO/1-DESPESAS/1.1-Remuneração CLT/1.3-Ajuda de Custo/1.4-Encargos Ajuda de Custo/1.5-Insumos/1.5.1-Benefícios/1.5.2-Uniformes/1.5.3-Despesas Diversas/1.6-Materiais/1.7-Equipamentos/"

cMaster := ""
cMaster := SuperGetMV("MV_XXGRREN",.F.,"000000/000003/000007/000008/000010/000020")
lMaster := .F.
aGRUPO := {}
//AADD(aGRUPO,aUser[1,10])
//FOR i:=1 TO LEN(aGRUPO[1])
//	lMaster := (aGRUPO[1,i] $ cMaster)
//NEXT
//Ajuste nova rotina a antiga não funciona na nova lib MDI
aGRUPO := UsrRetGrp(aUser[1][2])
IF LEN(aGRUPO) > 0
	FOR i:=1 TO LEN(aGRUPO)
		lMaster := (ALLTRIM(aGRUPO[i]) $ cMaster )
	NEXT
ENDIF	

//Carrega dados no Browser
nLINHA := 1
aLINHA := {}
DbSelectArea(ALIAS_TMP)
(ALIAS_TMP)->(dbSetOrder(1))
(ALIAS_TMP)->(dbgotop())
cCodigo := (ALIAS_TMP)->XX_NOME

Do While (ALIAS_TMP)->(!eof())
	IF !lMaster
		IF ALLTRIM((ALIAS_TMP)->XX_CODIGO) $ cCodView 
		
		ELSE
			(ALIAS_TMP)->(dbSkip())
			LOOP
		ENDIF
    ENDIF

   IF cCodigo <> (ALIAS_TMP)->XX_NOME
        nLINHA++
		dbSelectArea("TRB")
 		Reclock("TRB",.T.)
		TRB->XX_LINHA  := nLINHA
 		TRB->(Msunlock())
 		cCodigo := (ALIAS_TMP)->XX_NOME
 	ENDIF
	dbSelectArea("TRB")
	Reclock("TRB",.T.)
	TRB->XX_LINHA	:= nLINHA
	TRB->XX_CODIGO	:= (ALIAS_TMP)->XX_CODIGO
	TRB->XX_NOME	:= (ALIAS_TMP)->XX_NOME
	TRB->XX_CODGCT	:= (ALIAS_TMP)->XX_CODGCT
	FOR _nI := 1 TO nPeriodo
		cCampo2		:= ALIAS_TMP+"->XX_VAL"+STRZERO(_nI,3)
		cCampo		:= "TRB->XX_VAL"+STRZERO(_nI,3)
		&cCampo	:= transform(&cCampo2,cPict)
	NEXT
	TRB->XX_STATUS	:= STR(nAgrupar,1)+STR(nAnalitico,1)
	TRB->(Msunlock()) 
    nLINHA++
	DbSelectArea(ALIAS_TMP)
	(ALIAS_TMP)->(dbSkip())
ENDDO

aDesc := {}

AADD(aDesc,{"Por Cliente - Analítico","Por Cliente - Sintético" })
AADD(aDesc,{"Por Contrato - Analítico","Por Contrato - Sintético" })
AADD(aDesc,{"Por Totais - Analítico","Por Totais - Sintético" })


dbSelectArea("TRB")
Reclock("TRB",.T.)
TRB->XX_CODIGO  := ""
TRB->XX_NOME 	:= aDesc[nAgrupar,nAnalitico]
FOR _nI := 1 TO nPeriodo
	cCampo  := "TRB->XX_VAL"+STRZERO(_nI,3)
	&cCampo := aMeses[val(SUBSTR(aPeriodo[_nI,1],1,2))]
NEXT
TRB->(Msunlock())

dbSelectArea("TRB")
TRB->(dbgotop())



IF nOpc == 1 // Avisa se diferença valores do cronograma e planilha
	cCroXPla = ""
	IF LEN(aCroXPla) > 0
		cCroXPla += "VERIFICAR CONTRATOS"+ Chr(13) + Chr(10)+ Chr(13) + Chr(10)
		FOR XI__ := 1 TO LEN(aCroXPla)
			cCroXPla += aCroXPla[XI__]+ Chr(13) + Chr(10)+ Chr(13) + Chr(10)
		NEXT
		Aviso("Atencao",cCroXPla, {"Ok"})
	ENDIF
ENDIF


Return



STATIC Function GeraCSVBKGCTR09(_cAlias,cArqS,aTitulos,aCampos,aCabs,cTpQuebra,cQuebra,aQuebra)
Local nHandle
Local cCrLf   := Chr(13) + Chr(10)
Local _ni,_nj
Local cPicN   := "@E 99999999.99999"
Local cDirTmp := "C:\TMP"
Local cArqTmp := cDirTmp+"\"+cArqS+".CSV"
Local lSoma,aSoma,nCab
Local cLetra

Private xQuebra,xCampo

IF cTpQuebra == NIL
   cTpQuebra := " "
ENDIF

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
   		IF aCabs[_ni] <> "Linha"
       		fWrite(nHandle, aCabs[_ni] + IIF(_ni < LEN(aCabs),";",""))
     	ENDIF
   NEXT
   nCab++

   fWrite(nHandle, cCrLf ) // Pula linha

   (_cAlias)->(dbgotop())
   Do While (_cAlias)->(!eof())
      IF !lSoma
         For _ni :=1 to LEN(aCampos)
   	         IF SUBSTR(aCampos[_ni],6,8) <> "XX_LINHA" .AND. SUBSTR(aCampos[_ni],6,9) <> "XX_STATUS"
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
             ENDIF
         Next
         lSoma := .T.
      ENDIF
   
      IncProc("Gerando arquivo "+cArqS)   

      For _ni :=1 to LEN(aCampos)
         IF SUBSTR(aCampos[_ni],6,8) <> "XX_LINHA" .AND. SUBSTR(aCampos[_ni],6,9) <> "XX_STATUS"
         	xCampo := &(aCampos[_ni])
         	_uValor := ""
         	If VALTYPE(xCampo) == "D" // Trata campos data
            	_uValor := dtoc(xCampo)
         	Elseif VALTYPE(xCampo) == "N" // Trata campos numericos
            	_uValor := transform(xCampo,cPicN)
         	Elseif VALTYPE(xCampo) == "C"  .AND. SUBSTR(aCampos[_ni],6,6) <> "XX_VAL"// Trata campos caracter
             	//_uValor := xCampo+CHR(160)
            	_uValor := '="'+ALLTRIM(xCampo)+'"'
         	ELSEIF SUBSTR(aCampos[_ni],6,6) == "XX_VAL" // Trata campos numericos
            	_uValor := xCampo
         	Endif
            
         	fWrite(nHandle, _uValor + IIF(_ni < LEN(aCampos),";",""))
         ENDIF
      Next _ni
      nCab++   
      
      If !EMPTY(cTpQuebra)
         lSoma := .F.
         xQuebra := &(cQuebra)
         Do While !EOF() .AND. xQuebra == &(cQuebra)
            If cTpQuebra == "V"   
	           fWrite(nHandle, cCrLf )
            Endif
            For _nj := 1 To LEN(aQuebra)
		    	IF SUBSTR(aCampos[_ni],6,8) <> "XX_LINHA" .AND. SUBSTR(aCampos[_ni],6,9) <> "XX_STATUS"
                 	xCampo := &(aQuebra[_nj,1])
            
                 	_uValor := ""
            
                 	If VALTYPE(xCampo) == "D" // Trata campos data
                    	_uValor := dtoc(xCampo)
                 	Elseif VALTYPE(xCampo) == "N" 
                    	_uValor := transform(xCampo,cPicN)
                 	Elseif VALTYPE(xCampo) == "C" .AND. SUBSTR(aQuebra[_nj,1],6,8) <> "XX_VAL" //Trata campos caracter
		            	_uValor := '="'+ALLTRIM(xCampo)+'"'
                 	ELSEIF SUBSTR(aQuebra[_nj,1],6,8) == "XX_VAL" // Trata campos numericos
                    	_uValor := xCampo
                 	Endif
            
            		fWrite(nHandle, _uValor + IIF(_ni < LEN(aQuebra),";",""))
            	ENDIF
            Next _nj
            (_cAlias)->(dbskip())
            
         Enddo
      ENDIF
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
      
   MsgInfo("O arquivo "+cArqTmp+" será aberto no MsExcel",cPerg)
   ShellExecute("open", cArqTmp,"","",1)

Else
   MsgAlert("Falha na criação do arquivo "+cArqTmp,cPerg)
Endif
   
Return


Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Agrupar:" ,"Agrupar:" ,"Agrupar:" ,"mv_ch1","N",01,0,2,"C","","mv_par01","Cliente","Cliente","Cliente","","","Contrato","Contrato","Contrato","","","Somente Totais","Somente Totais","Somente Totais","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"02","Contrato/Cliente:","Contrato/Cliente:"  ,"Contrato/Cliente:"  ,"mv_ch2","C",10,0,0,"C","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Tipo:"    ,"Tipo:" ,"Tipo:" ,"mv_ch3","N",01,0,2,"C","","mv_par03","Analítico","Analítico","Analítico","","","Sintético","Sintético","Sintético","","","","","","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Centavos:","Centavos:" ,"Centavos:" ,"mv_ch4","N",01,0,2,"C","","mv_par04","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","","",""})
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
