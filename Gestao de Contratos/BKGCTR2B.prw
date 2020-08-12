#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKGCTR2B
BK - Gestão do Recebimento

@Return
@author Marcos Bispo Abrahão
@since 09/06/10 Rev 25/05/20
@version P11/P12
/*/
//-------------------------------------------------------------------
User Function BKGCTR2B()

Local cTitulo   := "Gestão do Recebimento - empresas: 01,02 e 14"
Local aTitulos  := {}
Local aCampos   := {}
Local aCabs     := {}
Local aDbf      := {}
Local oTmpTb
Local nMes      := 0
Local nAno      := 0
                  
Private cProg   := "BKGCTR2B"
Private nMesI   := 1
Private nAnoI   := YEAR(dDataBase)
Private cMesI   := ""
Private aMeses  := {}

Private cTpRel  := "X"
Private aPlans  := {}

Private nOpcao  := 1
Private aParam	:= {}
Private aRet	:= {}
Private aTpRel  := {"XLSX", "CSV"}
Private nCEndiv := 0.0
/*
Param Box Tipo 1
1 - MsGet
  [2] : Descrição
  [3] : String contendo o inicializador do campo
  [4] : String contendo a Picture do campo
  [5] : String contendo a validação
  [6] : Consulta F3
  [7] : String contendo a validação When
  [8] : Tamanho do MsGet
  [9] : Flag .T./.F. Parâmetro Obrigatório ?
*/

aAdd(aParam, {2,"Gerar:",nOpcao,aTpRel, 50,'.T.',.T.})
aAdd(aRet, aTpRel[nOpcao])
 
aAdd(aParam, {1,"Mes",nMesI,"99"  ,"nMesI > 0    .AND. nMesI <= 12"  ,"","",20,.F.})
aAdd(aRet, nMesI)

aAdd(aParam, {1,"Ano",nAnoI,"9999","nAnoI >= 2010 .AND. nAnoI <= 2030","","",20,.F.})
aAdd(aRet, nAnoI)

aAdd(aParam, {1,"Custo end. BK %a.a."  ,nCEndiv,"999.99"  ,"MV_PAR04 > 0.00","","",20,.F.})
aAdd(aRet, nCEndiv)

/*  
aParametros	 	Array of Record	 	Array contendo as perguntas
cTitle	 	 	Caracter	 	 	Titulo
aRet	 	 	Array of Record	 	Array container das respostas
bOk	 	 		Array of Record	 	Array contendo definições dos botões opcionais	 	 	 	 	 	 	 	 	 	 
aButtons	 	Array of Record	 	Array contendo definições dos botões opcionais	 	 	 	 	 	 	 	 	 	 
lCentered	 	Lógico	 	 		Indica se será centralizada a janela	 	 	 	 	 	 	 	 	 	 
nPosX	 	 	Numérico	 	 	Coordenada X da janela	 	 	 	 	 	 	 	 	 	 
nPosy	 	 	Numérico	 	 	Coordenada y da janela
oDlgWizard	 	Objeto	 	 		Objeto referente janela do Wizard	 	 	 	 	 	 	 	 	 	 
cLoad	 	 	Caracter	 	 	Nome arquivo para gravar respostas	 	 	 	 	 	 	 	 	 	 
lCanSave	 	Lógico	 	 		Indica se pode salvar o arquivo com respostas	 	 	 	 	 	 	 	 	 	 
lUserSave	 	Array of Record	 	Indica se salva nome do usuario no arquivo
*/

//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If !(Parambox(aParam     ,@cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cProg     ,.T.         ,.T.))
	Return Nil
EndIf  

If VALTYPE(aRet[1]) == "N"
	cTpRel := Substr(aTpRel[aRet[1]],1,1)
Else
	cTpRel := (Substr(aRet[1],1,1))
EndIf

nMesI    := aRet[2]
nAnoI    := aRet[3]
nCEndiv  := aRet[4]

cMesI    := STRZERO(nAnoI,4)+STRZERO(nMesI,2)
aMeses   := {}
AADD(aMeses,cMesI)

nMes     := nMesI
nAno     := nAnoI

cTitulo1 := cTitulo+": "+STRZERO(nMesI,2)+"/"+STRZERO(nAnoI,4)+ " - Custo Endiv. BK "+ALLTRIM(STR(nCEndiv,5,2))+"%"

aDbf     := {}
aCabs    := {}
aCampos  := {}
aTitulos := {}

Aadd( aDbf, { 'XX_EMPRESA','C',  2,00 } )
AADD(aCampos,"TMPC->XX_EMPRESA")
AADD(aCabs  ,"Empresa")

Aadd( aDbf, { 'XX_CLIENTE','C', TamSx3("A1_COD")[1],00 } )
AADD(aCampos,"TMPC->XX_CLIENTE")
AADD(aCabs  ,"Cliente")

Aadd( aDbf, { 'XX_LOJA'   ,'C', TamSx3("A1_LOJA")[1],00 } )
AADD(aCampos,"TMPC->XX_LOJA")
AADD(aCabs  ,"Loja")

Aadd( aDbf, { 'XX_NOMCLI' ,'C', TamSx3("A1_NOME")[1],00 } )
AADD(aCampos,"TMPC->XX_NOMCLI")
AADD(aCabs  ,"Nome do Cliente")

Aadd( aDbf, { 'XX_SERIE' ,'C', TamSx3("D2_SERIE")[1],00 } )
AADD(aCampos,"TMPC->XX_SERIE")
AADD(aCabs  ,"Serie")

Aadd( aDbf, { 'XX_DOC' ,'C', TamSx3("D2_DOC")[1],00 } )
AADD(aCampos,"TMPC->XX_DOC")
AADD(aCabs  ,"NF")

Aadd( aDbf, { 'XX_CONTRA' ,'C', TamSx3("CNF_CONTRA")[1],00 } )
AADD(aCampos,"TMPC->XX_CONTRA")
AADD(aCabs  ,"Contrato")

Aadd( aDbf, { 'XX_REVISAD','C',  1,00 } )

Aadd( aDbf, { 'XX_DESC'   ,'C', TamSx3("CN9_XXDESC")[1],00 } )
AADD(aCampos,"TMPC->XX_DESC")
AADD(aCabs  ,"Descrição")

Aadd( aDbf, { 'XX_INICIO' ,'C',  7,00 } )
AADD(aCampos,"TMPC->XX_INICIO")
AADD(aCabs  ,"Inicio")

Aadd( aDbf, { 'XX_FINAL'  ,'C',  7,00 } )
AADD(aCampos,"TMPC->XX_FINAL")
AADD(aCabs  ,"Final")

Aadd( aDbf, { 'XX_TOTFAT' ,'N', 17,02 } )
AADD(aCampos,"TMPC->XX_TOTFAT")
AADD(aCabs  ,"Faturado")

Aadd( aDbf, { 'XX_DIAPRV' ,'D',  8,00 } )
AADD(aCampos,"TMPC->XX_DIAPRV")
AADD(aCabs  ,"Dia Prv")

Aadd( aDbf, { 'XX_DIAFAT' ,'D',  8,00 } )
AADD(aCampos,"TMPC->XX_DIAFAT")
AADD(aCabs  ,"Dia Fat")

Aadd( aDbf, { 'XX_DIASA'  ,'N',  5,00 } )
AADD(aCampos,"TMPC->XX_DIASA")
AADD(aCabs  ,"Dias (A)")

Aadd( aDbf, { 'XX_VENCORI' ,'D',  8,00 } )
AADD(aCampos,"TMPC->XX_VENCORI")
AADD(aCabs  ,"Venc. Original")

Aadd( aDbf, { 'XX_BAIXA' ,'D',  8,00 } )
AADD(aCampos,"TMPC->XX_BAIXA")
AADD(aCabs  ,"Recebimento")

Aadd( aDbf, { 'XX_DIASB'  ,'N',  5,00 } )
AADD(aCampos,"TMPC->XX_DIASB")
AADD(aCabs  ,"Dias (B)")

Aadd( aDbf, { 'XX_DIAST'  ,'N',  5,00 } )
AADD(aCampos,"TMPC->XX_DIAST")
AADD(aCabs  ,"Dias (A+B)")

Aadd( aDbf, { 'XX_CUSFIN' ,'N', 17,02 } )
AADD(aCampos,"TMPC->XX_CUSFIN")
AADD(aCabs  ,"Custo Financeiro")

///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,'TMPC',.f.,.f. )
///IndRegua("TMPC",cArqTmp,"XX_CONTRA",,,"Indexando Arquivo de Trabalho")
///dbSetOrder(1)		

oTmpTb := FWTemporaryTable():New("TMPC")
oTmpTb:SetFields( aDbf )
oTmpTb:AddIndex("indice1", {"XX_CONTRA"} )
oTmpTb:Create()

ProcRegua(1)
Processa( {|| ProcQuery("01") })
Processa( {|| ProcQuery("02") })
Processa( {|| ProcQuery("14") })
   
AADD(aTitulos,cProg+"/"+TRIM(SUBSTR(cUsuario,7,15))+" - "+cTitulo1)
	            
If cTpRel == "C"
	// CSV
	ProcRegua(TMPC->(LASTREC()))
	Processa( {|| U_GeraCSV("TMPC",cProg,aTitulos,aCampos,aCabs,,,,.F.)})
ElseIf cTpRel == "X"
	// XLSX
	aPlans := {}
	AADD(aPlans,{"TMPC",cProg,"",cTitulo1,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
	U_GeraXlsx(aPlans,cTitulo1,cProg,.F.,aParam)
EndIf

oTmpTb:Delete()

///dbSelectArea("TMPC")
///dbCloseArea()
///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())
   
Return



Static Function ProcQuery(_cEmp)
Local cQuery,cQuery2
Local cMes   := ""
Local dDtP   := DATE()
Local dDtR   := DATE()
Local nDiasA := 0
Local nDiasB := 0
Local nDiasT := 0

Private cCampo
Private _cEmpresa := _cEmp

IncProc("Consultando o banco de dados...")


For _nI := 1 To LEN(aMeses)

	aJaPrv := {}
	cMes   := aMeses[_nI]
	cCompet:= SUBSTR(cMes,5,2)+"/"+SUBSTR(cMes,1,4)

	cQuery := " SELECT CNF_CONTRA,CNF_NUMERO,CNF_PARCEL,CN9_REVISA,CN9_SITUAC,CND_CLIENT,CND_LOJACL,CN9_NOMCLI,CN9_XXDESC,CNF_COMPET,CNF_VLPREV,"+CRLF
	cQuery +=         "D2_DOC,D2_SERIE,D2_TOTAL,CNF_PRUMED,D2_EMISSAO,E1_NUM,E1_PREFIXO,E1_VALOR,E1_VENCORI,E1_BAIXA "+CRLF
	//cQuery +=         "SUM(D2_TOTAL) AS D2_TOTAL,MAX(CNF_PRUMED) AS CNF_PRUMED,MAX(D2_EMISSAO) AS D2_EMISSAO "
	cQuery += " FROM "+xRETSQLNAME("CNF")+" CNF"+CRLF
    cQuery += " INNER JOIN "+xRETSQLNAME("CN9")+ " CN9 ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09' "+CRLF
	cQuery += "      AND  CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " LEFT JOIN "+xRETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+CRLF
	cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " LEFT JOIN "+xRETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO   AND CNF_CONTRA = CNA_CONTRA AND CNA_REVISA = CNF_REVISA"+CRLF
	cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " LEFT JOIN "+xRETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CND_PARCEL = CNF_PARCEL AND CNA_NUMERO = CND_NUMERO AND CND_REVISA = CNF_REVISA"+CRLF
	cQuery += "      AND  CND.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " LEFT JOIN "+xRETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM"+CRLF
	cQuery += "      AND  C6_FILIAL = CND_FILIAL AND  SC6.D_E_L_E_T_ = ' '"+CRLF
	cQuery += "	LEFT JOIN "+xRETSQLNAME("SD2")+ " SD2 ON SC6.C6_NUM = SD2.D2_PEDIDO AND C6_ITEM = D2_ITEM  "+CRLF
	cQuery += "      AND  D2_FILIAL = CND_FILIAL AND  SD2.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += "	LEFT JOIN "+xRETSQLNAME("SE1")+ " SE1 ON SD2.D2_DOC = SE1.E1_NUM AND SD2.D2_SERIE = SE1.E1_PREFIXO AND E1_CLIENTE=D2_CLIENTE AND E1_LOJA=D2_LOJA AND E1_TIPO='"+MVNOTAFIS+"' "+CRLF
	cQuery += "      AND  E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' ' "+CRLF
	cQuery += " WHERE CNF_COMPET = '"+cCompet+"'"+CRLF
	cQuery += "      AND  CNF_FILIAL = '"+xFilial("CNF")+"' AND  CNF.D_E_L_E_T_ = ' '"+CRLF
    If _cEmpresa <> "14"  
    	cQuery += " AND CNF_CONTRA NOT IN ('302000508')"+CRLF
    EndIf  
	//cQuery += " GROUP BY CNF_CONTRA,CNF_NUMERO,CNF_PARCEL,CN9_REVISA,CN9_SITUAC,CND_CLIENT,CND_LOJACL,CN9_NOMCLI,CN9_XXDESC,CNF_COMPET,CNF_VLPREV"
	cQuery += " ORDER BY CNF_CONTRA"+CRLF

	u_LogMemo("BKGCTR2B-CONTRATO"+_cEmpresa+".SQL",cQuery)

	TCQUERY cQuery NEW ALIAS "QTMP"
	
	dbSelectArea("QTMP")
	QTMP->(dbGoTop())
	Do While QTMP->(!EOF())
	
		IncProc()
		
		If QTMP->D2_TOTAL > 0
	
			dbSelectArea("TMPC")
		
			cQuery := " SELECT CNF_CONTRA,MAX(SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2)) AS XX_FIM,"
			cQuery += "                   MIN(SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2)) AS XX_INI "
			cQuery += " FROM "+xRETSQLNAME("CNF")+" CNF"
			cQuery += " WHERE CNF_CONTRA = '"+TRIM(QTMP->CNF_CONTRA)+"'"
			cQuery += "      AND  CNF_FILIAL = '"+xFilial("CNF")+"' AND  CNF.D_E_L_E_T_ = ' '"
			
			cQuery += " GROUP BY CNF_CONTRA "  
			cQuery += " ORDER BY CNF_CONTRA "  
	
			TCQUERY cQuery NEW ALIAS "TMP1"
	
			dbSelectArea("TMP1")
			TMP1->(dbGoTop())
	      
			Reclock("TMPC",.T.)
			TMPC->XX_EMPRESA := _cEmpresa
			TMPC->XX_CONTRA  := QTMP->CNF_CONTRA
			TMPC->XX_CLIENTE := QTMP->CND_CLIENT
			TMPC->XX_LOJA    := QTMP->CND_LOJACL
			TMPC->XX_NOMCLI  := QTMP->CN9_NOMCLI
			TMPC->XX_DESC    := QTMP->CN9_XXDESC
		 	TMPC->XX_INICIO  := SUBSTR(TMP1->XX_INI,5,2)+"/"+SUBSTR(TMP1->XX_INI,1,4)
		 	TMPC->XX_FINAL   := SUBSTR(TMP1->XX_FIM,5,2)+"/"+SUBSTR(TMP1->XX_FIM,1,4)
		 	TMPC->XX_SERIE   := QTMP->D2_SERIE
		 	TMPC->XX_DOC     := QTMP->D2_DOC
		 	TMPC->XX_DIAFAT  := STOD(QTMP->D2_EMISSAO)
		 	TMPC->XX_VENCORI := STOD(QTMP->E1_VENCORI)
		 	TMPC->XX_BAIXA   := STOD(QTMP->E1_BAIXA)
			TMPC->XX_TOTFAT  := QTMP->D2_TOTAL

			nDiasA := 0
			nDiasB := 0
			// Data prevista faturamento
			If !Empty(STOD(QTMP->CNF_PRUMED))
				dDtP := STOD(QTMP->CNF_PRUMED)
				If DAY(dDtP) >= 28
					dDtP := LastDay(dDtP)+1
				EndIf
				dDtP := DataValida(dDtP,.T.)
	           
				TMPC->XX_DIAPRV  := dDtP
			   
				nDiasA := 0
				Do While dDtP < STOD(QTMP->D2_EMISSAO)
					dDtP++
					dDtP := DataValida(dDtP,.T.)
					nDiasA++ 
				EndDo
			
				TMPC->XX_DIASA := nDiasA
			   			   
			EndIf


			// Vencimento original x data da baixa
			If Empty(STOD(QTMP->E1_BAIXA))
				dDtR := dDataBase
			Else
				dDtR := STOD(QTMP->E1_BAIXA)
			EndIf
				
			dDtP := STOD(QTMP->E1_VENCORI)
			dDtP := DataValida(dDtP,.T.)
	           
			nDiasB := 0
			Do While dDtP < dDtR
				dDtP++
				dDtP := DataValida(dDtP,.T.)
				nDiasB++ 
			EndDo
			   
			TMPC->XX_DIASB := nDiasB

          
			nDiasT := nDiasA + nDiasB
			
			TMPC->XX_DIAST   := nDiasT
			
			// Custo Financeiro = Faturado (c) x Custo Endiv (d) x Dias (e)
			TMPC->XX_CUSFIN  := TMPC->XX_TOTFAT * nCEndiv * nDiasT
						
           
			TMP1->(dbCloseArea())
		EndIf

		TMPC->(Msunlock())
		
		QTMP->(dbSkip())
	EndDo
	
	QTMP->(dbCloseArea())
    
	//********* Medições avulsas
	
	cQuery2 := "SELECT C5_ESPECI1,A1_COD,A1_LOJA,A1_NOME,CTT_DESC01,D2_TOTAL AS MEDAVULSO,D2_SERIE,D2_DOC,D2_EMISSAO,E1_NUM,E1_PREFIXO,E1_VALOR,E1_VENCORI,E1_BAIXA "
	cQuery2 += " FROM "+xRETSQLNAME("SC5")+" SC5" 
	cQuery2 += " INNER JOIN "+xRETSQLNAME("SC6")+" SC6 ON SC5.C5_NUM = SC6.C6_NUM" 
    cQuery2 += " INNER JOIN "+xRETSQLNAME("SD2")+" SD2 ON SC6.C6_SERIE = SD2.D2_SERIE AND SC6.C6_NOTA = SD2.D2_DOC"
    cQuery2 += "  AND SD2.D2_FILIAL ='"+xFilial("SD2")+"'  AND  SD2.D_E_L_E_T_ = ' '" 

	cQuery2 += " LEFT JOIN "+xRETSQLNAME("SE1")+ " SE1 ON SD2.D2_DOC = SE1.E1_NUM AND SD2.D2_SERIE = SE1.E1_PREFIXO AND E1_CLIENTE=D2_CLIENTE AND E1_LOJA=D2_LOJA AND E1_TIPO='"+MVNOTAFIS+"' "
	cQuery2 += "  AND E1_FILIAL = '"+xFilial("SE1")+"'  AND  SE1.D_E_L_E_T_ = ' ' "

    cQuery2 += " INNER JOIN "+xRETSQLNAME("SA1")+" SA1 ON SD2.D2_CLIENTE = SA1.A1_COD" 
    cQuery2 += "  AND SD2.D2_LOJA = SA1.A1_LOJA  AND  SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND  SA1.D_E_L_E_T_ = ' '"
    cQuery2 += " INNER  JOIN "+xRETSQLNAME("CTT")+" CTT ON SC5.C5_ESPECI1 = CTT.CTT_CUSTO AND CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '" 
    cQuery2 += " WHERE SC5.D_E_L_E_T_ = ' ' AND SC5.C5_MDCONTR='' AND SC5.C5_XXCOMPT ='"+SUBSTR(cCompet,1,2)+SUBSTR(cCompet,4,4)+"'"
   	cQuery2 += " AND C5_ESPECI1 <> '000000001'"
    //cQuery2 += " GROUP BY SC5.C5_ESPECI1,SA1.A1_COD,SA1.A1_LOJA,SA1.A1_NOME,CTT.CTT_DESC01" 
      	
	TCQUERY cQuery2 NEW ALIAS "TMPX2"
	u_LogMemo("BKGCTR2B-AVULSO"+_cEmpresa+".SQL",cQuery2)
	
	dbSelectArea("TMPX2")
	TMPX2->(dbGoTop())
	DO While !TMPX2->(EOF())
		dbSelectArea("TMPC")
		Reclock("TMPC",.T.)
	    TMPC->XX_EMPRESA := _cEmpresa
		TMPC->XX_CONTRA  := TMPX2->C5_ESPECI1
	 	TMPC->XX_CLIENTE := TMPX2->A1_COD
	 	TMPC->XX_LOJA    := TMPX2->A1_LOJA
		TMPC->XX_NOMCLI  := TMPX2->A1_NOME
		TMPC->XX_DESC    := TMPX2->CTT_DESC01
	    TMPC->XX_SERIE   := TMPX2->D2_SERIE
	    TMPC->XX_DOC     := TMPX2->D2_DOC
	    TMPC->XX_DIAFAT  := STOD(TMPX2->D2_EMISSAO)
	 	TMPC->XX_VENCORI := STOD(TMPX2->E1_VENCORI)
	 	TMPC->XX_BAIXA   := STOD(TMPX2->E1_BAIXA)
		TMPC->XX_TOTFAT  := TMPX2->MEDAVULSO
	                      
		nDiasA := 0
		nDiasB := 0

		// Vencimento original x data da baixa
		If Empty(STOD(TMPX2->E1_BAIXA))
			dDtR := dDataBase
		Else
			dDtR := STOD(TMPX2->E1_BAIXA)
		EndIf
		dDtP := STOD(TMPX2->E1_VENCORI)
		dDtP := DataValida(dDtP,.T.)
	           
		nDiasB := 0
		Do While dDtP < dDtR
			dDtP++
			dDtP := DataValida(dDtP,.T.)
			nDiasB++ 
		EndDo
			   
		TMPC->XX_DIASB := nDiasB
          
		nDiasT := nDiasA + nDiasB
			
		TMPC->XX_DIAST   := nDiasT
			
		// Custo Financeiro = Faturado (c) x Custo Endiv (d) x Dias (e)
		TMPC->XX_CUSFIN  := TMPC->XX_TOTFAT * nCEndiv * nDiasT

		TMPC->(Msunlock())
		
	   TMPX2->(dbSkip())
	EndDo
	TMPX2->(dbCloseArea())
Next
Return


// Substituir a função padrao RESTSQLNAME
Static Function xRETSQLNAME(cAlias)
Return cAlias+_cEmpresa+"0"



