#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKCOMA13()
Inclusão de Doc de Impostos com Rateio por CC

@author Marcos Bispo Abrahão
@since 21/11/2022
@version P12
@return .T.
/*/

User Function BKCOMA13()
Local lRet 		:= .F.
Local cMesI		:= ""
Local cMesF		:= ""
Local nX   		:= 0
Local cDesc		:= ""

Private cProg   := "BKCOMA13"
Private cTitulo := "Inclusão de Doc de Impostos com Rateio por CC"
Private cDocI	:= "000000000"
Private nMesI	:= Month(MonthSub(dDataBase,1))
Private nAnoI	:= Year(MonthSub(dDataBase,1))
Private nMesF	:= Month(MonthSub(dDataBase,1))
Private nAnoF	:= Year(MonthSub(dDataBase,1))

Private cProd   := "21301004       "
Private nProd	:= 1
Private nValor  := 0.00

Private cForn 	 := "UNIAO "
Private cLoja	 := "00"
Private cSerie   := "DNF"
Private cEspec   := "DF   "
Private cUF      := "SP"
Private aParam	 :=	{}
Private aRet	 :=	{}
Private cHist    := ""
Private aPrd     := {}
Private aPrdDesc := {}
Private cNFiscal := '000000000'

// Proximo numeor de DNF
U_NumSf1() 
cDocI := cNFiscal

aAdd(aPrd,"21401003")	// 1-PIS A RECOLHER 
aAdd(aPrd,"21401004")	// 2-COFINS A RECOLHER  
aAdd(aPrd,"DARF6912")	// 3-PARCELAMENTO PIS 60X 
aAdd(aPrd,"DARF5856")	// 4-PARCELAMENTO COFINS 60X         
aAdd(aPrd,"INS4982")	// 5-IRPJ A RECOLHER  X 60
aAdd(aPrd,"21301005")	// 6-FGTS  A RECOLHER
aAdd(aPrd,"21301004")	// 7-INSS A RECOLHER 


/*
-- 26/10/2023
SELECT B1_COD,B1_DESC FROM SB1010 WHERE B1_COD IN ('21401003','21401004','DARF6912', 'DARF5856','INS4982','21301005','21301004') AND D_E_L_E_T_ = ''

21401003       	PIS A RECOLHER                
21401004       	COFINS A RECOLHER             
DARF5856       	PARCELAMENTO COFINS  60X                                    
DARF6912       	PARCELAMENTO PIS 60X                                        
INS4982        	IRPJ A RECOLHER  X 60                                       
21301005       	FGTS  A RECOLHER              
21301004       	INSS A RECOLHER               

*/



//If !FWIsAdmin() .AND. !u_IsFiscal(__cUserId)
//	u_MsgLog(cProg,"Acesso a rotina somente para o grupo Fiscal","W")
//	Return Nil
//EndIf

// Descrição dos produtos
For nX := 1 To Len(aPrd)
	cDesc := TRIM(Posicione("SB1",1,xFilial("SB1")+aPrd[nX],"B1_DESC"))
	aAdd(aPrdDesc,aPrd[nX]+"-"+cDesc)
Next

//aAdd(aParam, { 1,"Documento"      ,cDocI   ,""    ,""                                       ,""   ,"",70,.T.})
aAdd(aParam, { 1,"Mes ref inicial",nMesI   ,"99"  ,"mv_par01 > 0 .AND. mv_par01 <= 12"      ,""   ,"",20,.T.})
aAdd(aParam, { 1,"Ano ref inicial",nAnoI   ,"9999","mv_par02 >= 2015 .AND. mv_par02 <= 2040",""   ,"",20,.T.})
aAdd(aParam, { 1,"Mes ref final"  ,nMesF   ,"99"  ,"mv_par03 > 0 .AND. mv_par03 <= 12"      ,""   ,"",20,.T.})
aAdd(aParam, { 1,"Ano ref final"  ,nAnoF   ,"9999","mv_par04 >= 2015 .AND. mv_par04 <= 2040",""   ,"",20,.T.})
aAdd(aParam, { 3,"Produto"        ,1,aPrdDesc,200,"",.T.})
aAdd(aParam, { 1,"Valor"          ,nValor  ,"@E 999,999,999.99"  ,"mv_par06 > 0"            ,""   ,"",70,.T.})
// Tipo 11 -> MultiGet (Memo)
//            [2] = Descrição
//            [3] = Inicializador padrão
//            [4] = Validação
//            [5] = When
//            [6] = Campo com preenchimento obrigatório .T.=Sim .F.=Não (incluir a validação na função ParamOk)
aAdd(aParam, {11,"Histórico"     ,cHist   , ""   , ""                                      ,.T.})

Do While .T.
	If !PrCom13()
		lRet := .F.
   		Exit
	Endif
	If ValidaDoc() .AND. u_MsgLog(cProg,"Confirma a inclusão do DNF "+cDocI,"Y")
		lRet := .T.
   		Exit
	Endif
EndDo

cMesI := STRZERO(nAnoI,4)+STRZERO(nMesI,2)
cMesF := STRZERO(nAnoF,4)+STRZERO(nMesF,2)

If lRet
	If nProd < 6
		u_WaitLog(cProg, {|oSay| u_PGCTR07(cMesI,cMesF)}, 'Processando faturamento...')
	ElseIf nProd == 6
		u_WaitLog(cProg, {|oSay| u_PFGTSCC(cMesI,cMesF)}, 'Processando FGTS...')
	ElseIf nProd == 7
		u_WaitLog(cProg, {|oSay| u_PINSSCC(cMesI,cMesF)}, 'Processando INSS Empresa e Terceiros...')
	EndIf
	u_WaitLog(cProg, {|oSay| IncDoc()}, 'Incluindo Documento de Entrada...')
EndIf

Return Nil



Static Function PrCom13
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cProg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cProg,.T.         ,.T.))
	lRet	:= .T.
	//cDocI	:= mv_par01
	nMesI	:= mv_par01
	nAnoI	:= mv_par02
	nMesF	:= mv_par03
	nAnoF	:= mv_par04
    cProd	:= aPrd[mv_par05]
    nProd	:= mv_par05
	nValor  := mv_par06
	cHist   := mv_par07
Endif
Return lRet


Static Function ValidaDoc()
LOCAL lOk	:=.T.

IF EMPTY(cDocI) .OR. Val(cDocI) == 0
	u_MsgLog(cProg,"Número do Documento de Entrada incorreto", "E")
	lOk:= .F.
    RETURN lOk 
Endif
cDocI := STRZERO(Val(cDocI),9)

/*   
IF EMPTY(cForn)
	u_MsgLog(cProg,"Número do Fornecedor incorreto", "E")
	lOk:= .F.
    RETURN lOk 
Endif
IF EMPTY(cEspec)
	u_MsgLog(cProg,"Espécie do Pré-Documento de Entrada incorreto", "E")
	lOk:= .F.
    RETURN lOk 
Endif

IF EMPTY(cUF)
	u_MsgLog(cProg,"UF do Pré-Documento de Entrada incorreto", "E")
	lOk:= .F.
    RETURN lOk 
Endif
*/

IF EMPTY(cProd)
	u_MsgLog(cProg,"Produto do Documento de Entrada incorreto", "E")
	lOk:= .F.
    RETURN lOk 
Endif

IF nValor <= 0
	u_MsgLog(cProg,"Valor do Documento de Entrada incorreto", "E")
	lOk:= .F.
    RETURN lOk 
Endif

/*
IF EMPTY(cTipoNF)
	u_MsgLog(cProg,"Tipo do Pré-Documento de Entrada incorreto", "E")
	lOk:= .F.
    RETURN lOk 
Endif
*/

DbSelectArea("SF1")
SET ORDER TO 1
IF SF1->(dbSeek(xFilial("SF1")+cDocI+cSerie+cForn+cLoja+"N",.F.))
	u_MsgLog(cProg,"Pré-Documento de Entrada já Existe", "E")
	lOk:= .F.
    RETURN lOk 
Endif

/*
IF !EMPTY(cProduto)
    nScan:= 0
    nScan:= aScan(aValida,{|x| x[1] == SUBSTR(cTipoNF,1,2) })
    IF nScan == 0
		u_MsgLog(cProg,"Produto do Pré-Documento de Entrada incorreto", "E")
		lOk:= .F.
		RETURN lOk 
    ELSEIF ALLTRIM(aValida[nScan,3]) $ ALLTRIM(cProduto)
		lOk:= .T.
    ELSE
		u_MsgLog(cProg,"Produto do Pré-Documento de Entrada incorreto", "E")
		lOk:= .F.
    	RETURN lOk 
    ENDIF
ENDIF
*/


RETURN lOk 


Static function IncDoc()
Local aCabec 	:= {}
Local aLinha    := {}
Local aItens    := {}
Local nX		:= 0
Local lRet		:= .T.
Local dEmissao  := dDataBase
Local nValIt    := 0
Local nTotal    := 0
Local nTotalR   := 0
Local nFator    := 0

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.
Private aAutoErro 	:= {}

aadd(aCabec,{"F1_FILIAL ",xFilial("SF1")})
aadd(aCabec,{"F1_TIPO"   ,"N"})
aadd(aCabec,{"F1_FORMUL" ,"N"})
aadd(aCabec,{"F1_DOC"    ,ALLTRIM(cDocI)})
aadd(aCabec,{"F1_SERIE"  ,ALLTRIM(cSerie)})
aadd(aCabec,{"F1_EMISSAO",dEmissao})
aadd(aCabec,{"F1_FORNECE",cForn})
aadd(aCabec,{"F1_LOJA"   ,cLoja})
aadd(aCabec,{"F1_ESPECIE",cEspec})
aadd(aCabec,{"F1_EST"    ,cUF})
// Criar a NF Liberada
aadd(aCabec,{"F1_XXLIB"  ,"L"})
aadd(aCabec,{"F1_XXULIB" ,__cUserId})
aadd(aCabec,{"F1_XXDLIB" ,DtoC(Date())+"-"+Time()})

dbSelectArea("QTMP")
dbGoTop()
Do WHile !QTMP->(EOF())
	//Carrega valores 
	aLinha := {}
	aadd(aLinha,{"D1_FILIAL ",xFilial("SD1")})
	aadd(aLinha,{"D1_COD"    ,cProd,Nil})
	aadd(aLinha,{"D1_QUANT"  ,1,Nil})
	aadd(aLinha,{"D1_VUNIT"  ,QTMP->VALCC,Nil})
	aadd(aLinha,{"D1_TOTAL"  ,QTMP->VALCC,Nil})
	aadd(aLinha,{"D1_CC"     ,QTMP->CC,Nil})
	aadd(aLinha,{"D1_XXHIST" ,ALLTRIM(cHist),Nil})
	aadd(aItens,aLinha)
	cHist := ""
	nTotal += QTMP->VALCC
	QTMP->(dbSkip())
EndDo
QTMP->(DbCloseArea())

IF Len(aItens) > 0

	nFator  := nValor / nTotal
	nTotalR := 0 
	For nX := 1 To Len(aItens)
		nValIt := ROUND(aItens[nX,4,2] * nFator,2)
		aItens[nX,4,2] := nValIt
		aItens[nX,5,2] := nValIt
		nTotalR += nValIt
	Next
	
	If nTotalR <> nValor
		aItens[1,4,2] += (nValor - nTotalR)
		aItens[1,5,2] += (nValor - nTotalR)
	EndIf

	// Inclusao da Pre Nota
	Begin Transaction
		//IncProc('Incluido Pré-Documento de Entrada')
		
		nOpc := 3
		MSExecAuto({|x,y,z| MATA140(x,y,z)}, aCabec, aItens, nOpc,.T.)   
		IF lMsErroAuto
			u_LogMsExec(cProg,"Problemas no Documento de Entrada "+cDocI+" "+cSerie)
			DisarmTransaction()
			lRet := .F.
		Else
			u_MsgLog(cProg,"Documento de Entrada incluido com sucesso! "+cDocI+" "+cSerie,"S")
		EndIf

	End Transaction
EndIf

If lRet
	If SF1->F1_DOC == cDocI .AND. SF1->F1_SERIE == cSerie
		u_AltFPgto()
		
		/* Removida liberação automática
		RecLock("SF1",.F.)
		SF1->F1_XXLIB   := "L"
		SF1->F1_XXULIB  := __cUserId
		SF1->F1_XXDLIB  := DtoC(Date())+"-"+Time()
		//SF1->F1_XXUAPRV := __cUserId
		//SF1->F1_XXDAPRV := DtoC(Date())+"-"+Time()
		MsUnLock("SF1")
		*/
	EndIf
EndIf

Return lRet


// Funções para geração de base de rateio via SQL

// Pelo Faturamento: PIS/COFINS/IRPJ
User Function PGCTR07(cMesI,cMesF)
Local cQuery := ""

cQuery := "WITH BKGCTR07 AS ("+CRLF
cQuery += u_QGctR07(iIf(cMesI == cMesF,1,3),cMesI,cMesF)
cQuery += ")"+CRLF
cQuery += "SELECT CNF_CONTRA AS CC,SUM(F2_VALFAT) AS VALCC FROM BKGCTR07 GROUP BY CNF_CONTRA"+CRLF
cQuery += "ORDER BY CNF_CONTRA"+CRLF

u_LogMemo("BKCOMA14-FAT.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"

Return NIL


// FGTS
User Function PFGTSCC(cMesI,cMesF)
Local cQuery := ""
cQuery += "SELECT Z5_CC AS CC,SUM(Z5_VALOR) AS VALCC "+CRLF
cQuery += " FROM "+RetSqlName("SZ5")+" SZ5 "+CRLF
//cQuery += " LEFT JOIN "+RetSqlName("CTT")+" CTT ON CTT_CUSTO = Z5_CC AND CTT.D_E_L_E_T_ = ''
cQuery += " WHERE Z5_EVDESCR LIKE '%FGTS%' "+CRLF
cQuery += "		AND Z5_ANOMES >= '"+cMesI+"' "+CRLF
cQuery += "		AND Z5_ANOMES <= '"+cMesF+"' "+CRLF
cQuery += "		AND SZ5.D_E_L_E_T_ = '' "+CRLF
cQuery += " GROUP BY Z5_CC"+CRLF
cQuery += " ORDER BY Z5_CC"+CRLF

u_LogMemo("BKCOMA14-FGTS.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"

Return NIL


// Valor do INSS patronal - Via integração Contábil
User Function PINSSCC(cMesI,cMesF)
Local cQuery := ""

/*
cQuery += "SELECT "+CRLF
cQuery += "	BKIntegraRubi.dbo.CUSTOSIGA.ccSiga AS CC,"+CRLF
cQuery += "	SUM(bk_senior.bk_senior.R046VER.ValEve) AS VALCC "+CRLF
cQuery += "FROM bk_senior.bk_senior.R046VER "+CRLF
cQuery += "	INNER JOIN bk_senior.bk_senior.R044cal ON "+CRLF
cQuery += "		bk_senior.bk_senior.R046VER.NumEmp= bk_senior.bk_senior.R044cal.NumEmp"+CRLF
cQuery += "		AND bk_senior.bk_senior.R046VER.CodCal= bk_senior.bk_senior.R044cal.Codcal"+CRLF
cQuery += "	INNER JOIN BKIntegraRubi.dbo.CUSTOSIGA ON "+CRLF
cQuery += "		bk_senior.bk_senior.R046VER.NumEmp= BKIntegraRubi.dbo.CUSTOSIGA.NumEmp"+CRLF
cQuery += "		AND bk_senior.bk_senior.R046VER.NumCad = BKIntegraRubi.dbo.CUSTOSIGA.Numcad"+CRLF
cQuery += "		AND bk_senior.bk_senior.R046VER.TipCol = BKIntegraRubi.dbo.CUSTOSIGA.TipCol"+CRLF
cQuery += "		AND bk_senior.bk_senior.R044cal.Codcal = BKIntegraRubi.dbo.CUSTOSIGA.Codcal"+CRLF
cQuery += "	INNER JOIN bk_senior.bk_senior.R008EVC ON "+CRLF
cQuery += "		bk_senior.bk_senior.R046VER.TabEve = bk_senior.bk_senior.R008EVC.CodTab"+CRLF
cQuery += "		AND bk_senior.bk_senior.R046VER.CodEve = bk_senior.bk_senior.R008EVC.CodEve"+CRLF
cQuery += "	INNER JOIN bk_senior.bk_senior.R008INC ON "+CRLF
cQuery += "		bk_senior.bk_senior.R046VER.TabEve = bk_senior.bk_senior.R008INC.CodTab"+CRLF
cQuery += "		AND bk_senior.bk_senior.R046VER.CodEve = bk_senior.bk_senior.R008INC.CodEve"+CRLF
cQuery += " WHERE "+CRLF
cQuery += "	bk_senior.bk_senior.R046VER.NumEmp='01' "+CRLF
cQuery += "	AND (bk_senior.bk_senior.R008INC.IncInm = '+' OR bk_senior.bk_senior.R008INC.IncInd = '+' OR bk_senior.bk_senior.R008INC.incina = '+')"+CRLF
cQuery += "	AND Tipcal In(11) And Sitcal = 'T' "+CRLF
cQuery += "	AND MONTH(PerRef) = "+STR(nMesI,0)+" AND YEAR(PerRef) = "+STR(nAnoI,0)+CRLF
cQuery += ""+CRLF
cQuery += " GROUP BY "+CRLF
cQuery += "	BKIntegraRubi.dbo.CUSTOSIGA.ccSiga"+CRLF
cQuery += " ORDER BY "+CRLF
cQuery += "	BKIntegraRubi.dbo.CUSTOSIGA.ccSiga"+CRLF
*/

cQuery += "SELECT Z5_CC AS CC,SUM(Z5_VALOR) AS VALCC "+CRLF
cQuery += " FROM "+RetSqlName("SZ5")+" SZ5 "+CRLF
//cQuery += " LEFT JOIN "+RetSqlName("CTT")+" CTT ON CTT_CUSTO = Z5_CC AND CTT.D_E_L_E_T_ = ''
cQuery += " WHERE Z5_EVENTO LIKE '%INS-%' "+CRLF
cQuery += "		AND Z5_ANOMES >= '"+cMesI+"' "+CRLF
cQuery += "		AND Z5_ANOMES <= '"+cMesF+"' "+CRLF
cQuery += "		AND SZ5.D_E_L_E_T_ = '' "+CRLF
cQuery += " GROUP BY Z5_CC"+CRLF
cQuery += " ORDER BY Z5_CC"+CRLF

u_LogMemo("BKCOMA14-INSS.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"

Return NIL





