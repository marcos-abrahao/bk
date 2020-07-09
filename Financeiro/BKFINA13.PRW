#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} BKFINA13
BK - Fluxo de Caixa

@Return
@author Adilson do Prado
@since 03/02/12 Rev 25/05/20
@version P12
/*/

User Function BKFINA13()

Local titulo         := ""
Local _nI
Local aDbf           := {}
Local oTmpTb

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := " "
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private cPerg        := "BKFINA13"

Private dDataInicio  := dDatabase
Private dDataFinal   := dDatabase
Private cPeriodo     := "1"
Private	cPict        := "@E 99,999,999,999.99"
Private nPeriodo     := 1
Private nCentavos    := 1
Private aDtPeriodo   := {}
Private nPlan        := 1
Private aFixeFX      := {}
Private aTitulos,aCampos,aCabs


ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

dDataInicio  := mv_par01
dDataFinal   := mv_par02
cPeriodo     := STR(mv_par03,1)
nTipo        := mv_par04
nCentavos    := mv_par05
//nBancos      := MV_PAR06   // Selecionar / Todos

IF nCentavos <> 1
	cPict := "@E 99,999,999,999"
ENDIF

IF dDataFinal < dDataInicio
	MSGSTOP("Data deve ser maior ou igual que a database")                
	Return Nil
ENDIF

IF cPeriodo = "1"
   nPeriodo +=  DateDiffDay( dDataInicio , dDataFinal ) //dDataFinal-dDataInicio
ELSEIF cPeriodo="2"                                                                             
   nPeriodo += DateDiffMonth( dDataInicio , dDataFinal )
ELSEIF cPeriodo="3"                                                                             
   nPeriodo += DateDiffYear( dDataInicio , dDataFinal )
ENDIF

titulo   := "Fluxo de Caixa: Período "+IIF(nPeriodo=1,"Diário",IIF(nPeriodo=2,"Mensal","Anual"))+" até "+DTOC(dDataFinal)

aDbf    := {}

Aadd( aDbf, { 'XX_CODZE' ,'C', 20,00 } )
Aadd( aDbf, { 'XX_HISTOR','C', 80,00 } )
Aadd( aDbf, { 'XX_CHAVE' ,'C',100,00 } )

FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,2)
	Aadd( aDbf, { 'XX_VALOR'+STRZERO(_nI,2),'C', 20,00 } )
NEXT


///cArqTmp := CriaTrab( aDbf, .t. )  
///dbUseArea( .T.,NIL,cArqTmp,'TRB',.F.,.F. )
///IndRegua("TRB",cArqTmp,"ALLTRIM(XX_CODZE)+ALLTRIM(XX_HISTOR)",,,"Indexando Arquivo de Trabalho")
///dbSetOrder(1)		
oTmpTb := FWTemporaryTable():New( "TRB")
oTmpTb:SetFields( aDbf )
oTmpTb:AddIndex("indice1", {"XX_CHAVE"} )
oTmpTb:Create()

ProcRegua(1)
//Processa( {|| ProcQuery() })

aCabs   := {}
aCampos := {}
aTitulos:= {}
   
AADD(aTitulos,titulo)

AADD(aCampos,"TRB->XX_CODZE")
AADD(aCabs  ,"Codigo")
AAdd(aFixeFX,{"Codigo","XX_CODZE",'C', 10,00,'@!'})


AADD(aCampos,"TRB->XX_HISTOR")
AADD(aCabs  ,"Descrição")
AAdd(aFixeFX,{"Descrição","XX_HISTOR",'C', 20,00,'@!'})
                                                                                                               

dDataPer := dDataInicio
AAdd(aDtPeriodo,{dDataPer,0,0,0,0})

FOR _nI := 1 TO nPeriodo
	cMes := STRZERO(_nI,2)
	
	AADD(aCampos,"TRB->XX_VALOR"+cMes)
    IF cPeriodo="1"
    	IF Dow(dDataPer) <> 7 .AND. Dow(dDataPer)<>1
			AADD(aCabs,DTOC(dDataPer))
			AAdd(aFixeFX,{DTOC(dDataPer),"XX_VALOR"+cMes,'C', 10,00,'@!'})
       ENDIF
       dDataPer := DaySum(dDataPer,1)
       AAdd(aDtPeriodo,{dDataPer,0,0,0,0})
    ELSEIF cPeriodo="2"
		AADD(aCabs,STRZERO(Month(dDataPer),2)+"/"+STRZERO(YEAR(dDataPer),4))
		AAdd(aFixeFX,{STRZERO(Month(dDataPer),2)+"/"+STRZERO(YEAR(dDataPer),4),"XX_VALOR"+cMes,'C', 10,00,'@!'})
		dDataPer := MonthSum(dDataPer,1)
        AAdd(aDtPeriodo,{dDataPer,0,0,0,0})
    ELSEIF cPeriodo="3"
		AADD(aCabs,STRZERO(YEAR(dDataPer),4))
		AAdd(aFixeFX,{STRZERO(YEAR(dDataPer),4),"XX_VALOR"+cMes,'C', 10,00,'@!'})
		dDataPer := YearSum(dDataPer,1)
        AAdd(aDtPeriodo,{dDataPer,0,0,0,0})
    ENDIF
NEXT


IF cPeriodo="1"
	dbSelectArea("TRB")
	Reclock("TRB",.T.)
	TRB->XX_CODZE  := ""
	TRB->XX_HISTOR := ""
	TRB->XX_CHAVE  := ""
	FOR _nI := 1 TO nPeriodo
    	IF Dow(aDtPeriodo[_nI,1]) <> 7 .AND. Dow(aDtPeriodo[_nI,1])<>1
    		cCampo  := "TRB->XX_VALOR"+STRZERO(_nI,2)
    		&cCampo := DiaSemana(aDtPeriodo[_nI,1],20)
    	ENDIF
	NEXT
	TRB->(Msunlock())
ENDIF


Processa( {|| ProcQuery() })


//Processa( {|| U_GeraCSV("TRB",cPerg,aTitulos,aCampos,aCabs)})
//ProcRegua(TRB->(LASTREC()))


Processa ( {|| U_MBrwSA1()})

oTmpTb:Delete()
///TRB->(Dbclosearea())
///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())
 
Return



User Function MBrwSA1()

Local cAlias 		:= "TRB"
Private cCadastro	:= "Fluxo de Caixa"
Private aRotina	:= {}                

//AADD(aRotina,{"Pesquisa"	,"AxPesquisa",0,1})
//AADD(aRotina,{"Visualizar"	,"AxVisual",0,2})
//AADD(aRotina,{"Incluir"	,"AxInclui",0,3})
//AADD(aRotina,{"Alterar"	,"AxAltera",0,4})
//AADD(aRotina,{"Excluir"	,"AxDeleta",0,5})
AADD(aRotina,{"Simulações"	,"U_BKFINA12",0,6})
                                                                         
dbSelectArea(cAlias)
dbSetOrder(1)

mBrowse(6,1,22,LEN(aFixeFX),cAlias,aFixeFX)
//mBrowse(6,1,22,75,cAlias,aFixeFX)
Return Nil



Static Function ProcQuery
Local cQuery

IncProc("Consultando o banco de dados...")



//FLUXO - REALIZADO
	IF cPeriodo="1"
		FOR _nI := 1 TO nPeriodo
   			IF Dow(aDtPeriodo[_nI,1]) <> 7 .AND. Dow(aDtPeriodo[_nI,1]) <>1
				cQuery := " SELECT DISTINCT E1_NUM,E1_PREFIXO,E1_TIPO,CNF_CONTRA,CN9_NOMCLI,E1_BAIXA,E1_VALLIQ AS VALLIQ FROM SE1010 SE1"
				cQuery += " LEFT JOIN SF2010 SF2 ON E1_NUM = F2_DOC AND E1_PREFIXO=F2_PREFIXO AND E1_CLIENTE=F2_CLIENTE AND E1_LOJA=F2_LOJA AND E1_TIPO='NF' AND  SF2.D_E_L_E_T_ = ' '" 
				cQuery += " LEFT JOIN SC6010 SC6 ON C6_NOTA = F2_DOC AND C6_SERIE=F2_SERIE AND C6_FILIAL = F2_FILIAL AND  SC6.D_E_L_E_T_ = ' '" 
				cQuery += " LEFT JOIN CND010 CND ON CND_PEDIDO = C6_NUM AND CND_FILIAL = F2_FILIAL AND CND.D_E_L_E_T_ = ' '"
				cQuery += " LEFT JOIN CNF010 CNF ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CND_REVISA = CNF_REVISA AND CND_PARCEL = CNF_PARCEL AND  CND.D_E_L_E_T_ = ' '"
				cQuery += " LEFT JOIN CNA010 CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CND_REVISA AND CNA_FILIAL = '01' AND  CNA.D_E_L_E_T_ = ' '"
				cQuery += " LEFT JOIN CN9010 CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9_FILIAL = '01' AND  CN9.D_E_L_E_T_ = ' '"
				cQuery += " LEFT JOIN CTT010 CTT ON CTT_CUSTO  = CNF_CONTRA AND  CTT.D_E_L_E_T_ = ' '"
				cQuery += " WHERE E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' ' AND E1_BAIXA='"+DTOS(aDtPeriodo[_nI,1])+"' AND E1_TIPO IN ('NF','NDC') GROUP BY E1_NUM,E1_PREFIXO,E1_TIPO,CNF_CONTRA,CN9_NOMCLI,E1_BAIXA,E1_VALLIQ"
		
				TCQUERY cQuery NEW ALIAS "QTMP" 
	   			dbSelectArea("QTMP")
				aRealizado:= {}
	   			QTMP->(DbGotop())
				DO WHILE !EOF()
					aDtPeriodo[_nI,3] += QTMP->VALLIQ 	
					IF nTipo = 2
						IF !EMPTY(QTMP->CNF_CONTRA)
						    nScan:= 0
						    nScan:= aScan(aRealizado,{|x| x[1]=="11-Contratos" .AND. x[2]==ALLTRIM(QTMP->CN9_NOMCLI)})
						    
						    IF nScan == 0
						       AADD(aRealizado,{"11-Contratos",ALLTRIM(QTMP->CN9_NOMCLI),QTMP->VALLIQ})
						    ELSE
						       aRealizado[nScan,3] += QTMP->VALLIQ
					 		ENDIF
					 	ELSE
						    nScan:= 0
						    nScan:= aScan(aRealizado,{|x| x[1]="12-Outras Receitas" .AND.x[2]=ALLTRIM(QTMP->CN9_NOMCLI)})
						    IF nScan == 0
						       AADD(aRealizado,{"12-Outras Receitas",ALLTRIM(QTMP->CN9_NOMCLI),QTMP->VALLIQ})
						    ELSE
						       aRealizado[nScan,3] += QTMP->VALLIQ
					 		ENDIF
					 	ENDIF
					ENDIF  
  					dbSelectArea("QTMP")
	   				dbSkip()
				ENDDO
                QTMP->(Dbclosearea())
                
				IF nTipo = 2
                	FOR _nj := 1 TO LEN(aRealizado)
						dbSelectArea("TRB")
						Reclock("TRB",.T.)
						TRB->XX_CODZE  := aRealizado[_nj,1]
						TRB->XX_HISTOR := aRealizado[_nj,2]
						TRB->XX_CHAVE  := ALLTRIM(TRB->XX_CODZE)+ALLTRIM(TRB->XX_HISTOR)
    					cCampo  := "TRB->XX_VALOR"+STRZERO(_nI,2)
   						&cCampo := TRANSFORM(aRealizado[_nj,3],cPict)
    					TRB->(Msunlock())
    					aRealizado[_nj,3]:= 0
                	NEXT
                ENDIF
			ENDIF
		NEXT
	ENDIF

//FLUXO - PREVISAO

	IF cPeriodo="1"
		FOR _nI := 1 TO nPeriodo
   			IF Dow(aDtPeriodo[_nI,1]) <> 7 .AND. Dow(aDtPeriodo[_nI,1]) <>1
	
				//cQuery := " SELECT CNF_CONTRA,CN9_REVISA,CN9_SITUAC,CN9_NOMCLI,CN9_XXDESC,CNF_COMPET,F2_VALFAT,CNF_DTVENC, SUM(CNF_VLPREV) AS VALPREV"
				cQuery := " SELECT DISTINCT	CNF_CONTRA,CN9_NOMCLI,F2_VALFAT,CNF_DTVENC, SUM(CNF_VLPREV) AS VALPREV"
				cQuery += " FROM "+RETSQLNAME("CNF")+" CNF"
    			cQuery += " INNER JOIN "+RETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9_SITUAC NOT IN ('01','08','09','10')"
				cQuery += "      AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"
				cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"
				cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"
				cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_REVISA = CNF_REVISA"
				cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '"
				cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CND_PARCEL = CNF_PARCEL AND CNA_NUMERO = CND_NUMERO AND CND_REVISA = CNF_REVISA"
				cQuery += "      AND  CND.D_E_L_E_T_ = ' '"
				cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM"
				cQuery += "      AND  C6_FILIAL = CND_FILIAL AND  SC6.D_E_L_E_T_ = ' '"
				cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+ " SF2 ON C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC"
				cQuery += "      AND  F2_FILIAL = CND_FILIAL  AND  SF2.D_E_L_E_T_ = ' '"
				cQuery += " LEFT JOIN "+RETSQLNAME("SE1")+ " SE1 ON E1_NUM = F2_DOC AND E1_PREFIXO=F2_PREFIXO AND E1_CLIENTE=F2_CLIENTE AND E1_LOJA=F2_LOJA AND E1_TIPO='NF'"
				cQuery += "      AND  E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' '"
				cQuery += " WHERE CNF_FILIAL = '"+xFilial("CNF")+"' AND CNF.D_E_L_E_T_ = ' ' AND CNF_DTVENC='"+DTOS(aDtPeriodo[_nI,1])+"'"
				cQuery += " GROUP BY CNF_CONTRA,CN9_NOMCLI,F2_VALFAT,CNF_DTVENC "  

		
				TCQUERY cQuery NEW ALIAS "QTMP" 
	   			dbSelectArea("QTMP")
	   			QTMP->(DbGotop())
				DO WHILE !EOF()
				    IF QTMP->F2_VALFAT = 0
					aDtPeriodo[_nI,3] += QTMP->VALPREV 	
					IF nTipo = 2
						IF !EMPTY(QTMP->CNF_CONTRA)
							TRB->(dbSeek("11-Contratos"+ALLTRIM(QTMP->CN9_NOMCLI),.T.))
							IF ALLTRIM(TRB->XX_HISTOR) = ALLTRIM(QTMP->CN9_NOMCLI) 
             		   			Reclock("TRB",.F.)
    				   			cCampo  := "TRB->XX_VALOR"+STRZERO(_nI,2)
	   				   			&cCampo := TRANSFORM(VAL(&cCampo)+QTMP->VALPREV,cPict)
					   			TRB->(Msunlock())
					 		ELSE
             		   			Reclock("TRB",.T.)
								TRB->XX_CODZE  := "11-Contratos"
								TRB->XX_HISTOR := ALLTRIM(QTMP->CN9_NOMCLI)
								TRB->XX_CHAVE  := ALLTRIM(TRB->XX_CODZE)+ALLTRIM(TRB->XX_HISTOR)
 				       			cCampo  := "TRB->XX_VALOR"+STRZERO(_nI,2)
	   				   			&cCampo := TRANSFORM(QTMP->VALPREV,cPict)
					   			TRB->(Msunlock())
					 		ENDIF
					 	ENDIF
					ENDIF  
  					ENDIF
  					dbSelectArea("QTMP")
	   				dbSkip()
				ENDDO
                QTMP->(Dbclosearea())
			ENDIF
		NEXT
	ENDIF

 //Despesas
 
 	IF cPeriodo="1"
		FOR _nI := 1 TO nPeriodo
   			IF Dow(aDtPeriodo[_nI,1]) <> 7 .AND. Dow(aDtPeriodo[_nI,1]) <>1
	
				cQuery := " SELECT DISTINCT E2_PREFIXO,E2_TIPO,E2_FORNECE,E2_LOJA,A2_NOME,E2_VENCREA,E2_BAIXA,SUM(E2_VALOR) AS VALDESP"
				cQuery += " FROM "+RETSQLNAME("SE2")+ " SE2"
				cQuery += " LEFT JOIN "+RETSQLNAME("SA2")+ " SA2 ON SA2.A2_COD=SE2.E2_FORNECE AND SA2.A2_LOJA=SE2.E2_LOJA AND SA2.D_E_L_E_T_ = ' '"
				cQuery += " WHERE E2_FILIAL = '"+xFilial("SE2")+"' AND  SE2.D_E_L_E_T_ = ' '"
				cQuery += " AND (E2_BAIXA='"+DTOS(aDtPeriodo[_nI,1])+"' OR E2_VENCREA='"+DTOS(aDtPeriodo[_nI,1])+"')"
				cQuery += " GROUP BY E2_PREFIXO,E2_TIPO,E2_FORNECE,E2_LOJA,A2_NOME,E2_VENCREA,E2_BAIXA"  

		
				TCQUERY cQuery NEW ALIAS "QTMP" 
	   			dbSelectArea("QTMP")
	   			QTMP->(DbGotop())
				DO WHILE !EOF()
					aDtPeriodo[_nI,4] += QTMP->VALDESP 	
					IF nTipo = 2
						IF QTMP->E2_PREFIXO == "LF"
							IF TRB->(dbSeek("21-Pessoal",.F.))
             		   			Reclock("TRB",.F.)
    				   			cCampo  := "TRB->XX_VALOR"+STRZERO(_nI,2)
	   				   			&cCampo := TRANSFORM(VAL(&cCampo)+QTMP->VALDESP,cPict)
					   			TRB->(Msunlock())
					 		ELSE
             		   			Reclock("TRB",.T.)
								TRB->XX_CODZE  := "21-Pessoal"
								TRB->XX_HISTOR := ""
								TRB->XX_CHAVE  := ALLTRIM(TRB->XX_CODZE)+ALLTRIM(TRB->XX_HISTOR)
 				       			cCampo  := "TRB->XX_VALOR"+STRZERO(_nI,2)
	   				   			&cCampo := TRANSFORM(QTMP->VALDESP,cPict)
					   			TRB->(Msunlock())
					 		ENDIF
							TRB->(dbSeek("211-Folha"+ALLTRIM(QTMP->A2_NOME),.T.))
							IF TRB->XX_CODZE  := "211-Folha" .AND.ALLTRIM(TRB->XX_HISTOR) = ALLTRIM(QTMP->A2_NOME)
             		   			Reclock("TRB",.F.)
    				   			cCampo  := "TRB->XX_VALOR"+STRZERO(_nI,2)
	   				   			&cCampo := TRANSFORM(VAL(&cCampo)+QTMP->VALDESP,cPict)
					   			TRB->(Msunlock())
					 		ELSE
             		   			Reclock("TRB",.T.)
								TRB->XX_CODZE  := "211-Folha"
								TRB->XX_HISTOR := ALLTRIM(QTMP->A2_NOME)
								TRB->XX_CHAVE  := ALLTRIM(TRB->XX_CODZE)+ALLTRIM(TRB->XX_HISTOR)
 				       			cCampo  := "TRB->XX_VALOR"+STRZERO(_nI,2)
	   				   			&cCampo := TRANSFORM(QTMP->VALDESP,cPict)
					   			TRB->(Msunlock())
					 		ENDIF
					 	ELSE
							IF TRB->(dbSeek("22-Outras Despesas",.F.))
             		   			Reclock("TRB",.F.)
    				   			cCampo  := "TRB->XX_VALOR"+STRZERO(_nI,2)
	   				   			&cCampo := TRANSFORM(VAL(&cCampo)+QTMP->VALDESP,cPict)
					   			TRB->(Msunlock())
					 		ELSE
             		   			Reclock("TRB",.T.)
								TRB->XX_CODZE  := "22-Outras Despesas"
								TRB->XX_HISTOR := ""
								TRB->XX_CHAVE  := ALLTRIM(TRB->XX_CODZE)+ALLTRIM(TRB->XX_HISTOR)
 				       			cCampo  := "TRB->XX_VALOR"+STRZERO(_nI,2)
	   				   			&cCampo := TRANSFORM(QTMP->VALDESP,cPict)
					   			TRB->(Msunlock())
					 		ENDIF
					 	ENDIF
  					ENDIF
  					dbSelectArea("QTMP")
	   				dbSkip()
				ENDDO
                QTMP->(Dbclosearea())
			ENDIF
		NEXT
	ENDIF


//TOTALIZANDO - SINTÉTICO

dbSelectArea("SZE")
dbGoTop()
DO WHILE !SZE->(EOF())
	IF SZE->ZE_TIPO = "S" 
		dbSelectArea("TRB")
		Reclock("TRB",.T.)
		TRB->XX_CODZE  := SZE->ZE_CODIGO
		TRB->XX_HISTOR := ALLTRIM(SZE->ZE_DESCR)
		TRB->XX_CHAVE  := ALLTRIM(TRB->XX_CODZE)+ALLTRIM(TRB->XX_HISTOR)
		IF cPeriodo="1"
			FOR _nI := 1 TO nPeriodo
   				IF Dow(aDtPeriodo[_nI,1]) <> 7 .AND. Dow(aDtPeriodo[_nI,1]) <>1
    				cCampo  := "TRB->XX_VALOR"+STRZERO(_nI,2)
    				IF ALLTRIM(SZE->ZE_CODIGO)='1-RECEITAS'
    					&cCampo := TRANSFORM(aDtPeriodo[_nI,3],cPict)
    				ELSEIF ALLTRIM(SZE->ZE_CODIGO)='2-DESPESAS'
    					&cCampo := TRANSFORM(aDtPeriodo[_nI,4],cPict)
    				ELSEIF ALLTRIM(SZE->ZE_CODIGO)='0-SALDO' .AND. _nI > 1
    				    IF Dow(aDtPeriodo[_nI,1]) = 2
    						&cCampo := TRANSFORM(aDtPeriodo[_nI-3,5],cPict)
   							aDtPeriodo[_nI,2] := aDtPeriodo[_nI-3,5]
    				    ELSE
    						&cCampo := TRANSFORM(aDtPeriodo[_nI-1,5],cPict)
   							aDtPeriodo[_nI,2] := aDtPeriodo[_nI-1,5]
    					ENDIF
    				ELSEIF ALLTRIM(SZE->ZE_CODIGO)='9-SALDO'
    					&cCampo := TRANSFORM(aDtPeriodo[_nI,2]+aDtPeriodo[_nI,3]-aDtPeriodo[_nI,4],cPict)
    			    ENDIF
	 				aDtPeriodo[_nI,5] := aDtPeriodo[_nI,2]+aDtPeriodo[_nI,3]-aDtPeriodo[_nI,4]
	    		ENDIF
 			NEXT
		ELSE
			FOR _nI := 1 TO nPeriodo
   				cCampo  := "TRB->XX_VALOR"+STRZERO(_nI,2)                                            
				&cCampo := TRANSFORM(0,cPict)
			NEXT
		ENDIF
		TRB->(Msunlock())
	ENDIF	
	dbSelectArea("SZE")
	dbSkip()
ENDDO
Return


Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Data de:" ,"Data de:"  ,"Data de:"  ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Data até:","Data até:" ,"Data até:" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Período:" ,"Período:"  ,"Período:"  ,"mv_ch3","N",01,0,2,"C","","mv_par03","Diário","Diário","Diário","","","Mensal","Mensal","Mensal","","","Anual","Anual","Anual","","","","","","","","","","","",""})
AADD(aRegistros,{cPerg,"04","Tipo:"    ,"Tipo:"     ,"Tipo:"     ,"mv_ch4","N",01,0,2,"C","","mv_par04","Sintético","Sintético","Sintético","","","Analítico","Analítico","Analítico","","","","","","","","","","","","","","","","",""})
//AADD(aRegistros,{cPerg,"05","Centavos:","Centavos:" ,"Centavos:" ,"mv_ch5","N",01,0,2,"C","","mv_par05","Sim","Sim","Sim","","","Não","Não","Não","","","","","","","","","","","","","","","","",""})

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
