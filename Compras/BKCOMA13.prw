#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKCOMA13()
Rateio de impostos na implantação de Doc. de Entrada referentes a impostos

@author Marcos Bispo Abrahão
@since 21/11/2022
@version P12
@return .T.
/*/

User Function BKCOMA13()
Local lRet := .F.
Local cMes := ""
Local nX   := 0
Local cDesc:= ""

Private cProg    := "BKCOMA13"
Private cTitulo  := "Inclusão de Doc de Impostos"
Private cDocI	 := "000000000"
Private nMesRef  := Month(MonthSub(dDataBase,1))
Private nAnoRef  := Year(MonthSub(dDataBase,1))
Private cProd    := "21301004       "
Private nValor   := 0.00

Private cForn 	 := "UNIAO "
Private cLoja	 := "00"
Private cSerie   := "DNF"
Private cEspec   := "DF   "
Private cUF      := "SP"
Private aParam	 :=	{}
Private aRet	 :=	{}
Private cHist    := ""
Private aPrd     := {"21401003","21401004","DARF6912", "DARF5856"} 
Private aPrdDesc := {}

If !FWIsAdmin() .AND. !u_IsFiscal()
	u_MsgLog(cProg,"Acesso a rotina somente para o grupo FIscal","W")
	Return Nil
EndIf

// Descrição dos produtos
For nX := 1 To Len(aPrd)
	cDesc := TRIM(Posicione("SB1",1,xFilial("SB1")+aPrd[nX],"B1_DESC"))
	aAdd(aPrdDesc,aPrd[nX]+"-"+cDesc)
Next

aAdd(aParam, { 1,"Documento"     ,cDocI   ,""    ,""                                       ,""   ,"",70,.T.})
aAdd(aParam, { 1,"Mes referencia",nMesRef ,"99"  ,"mv_par02 > 0 .AND. mv_par02 <= 12"      ,""   ,"",20,.T.})
aAdd(aParam, { 1,"Ano referencia",nAnoRef ,"9999","mv_par03 >= 2010 .AND. mv_par03 <= 2040",""   ,"",20,.T.})
aAdd(aParam, { 3,"Produto"       ,1,aPrdDesc,70,"",.T.})
aAdd(aParam, { 1,"Valor"         ,nValor  ,"@E 999,999,999.99"  ,"mv_par05 > 0"            ,""   ,"",70,.T.})
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
	If ValidaDoc()
		lRet := .T.
   		Exit
	Endif
EndDo

cMes := STRZERO(nAnoRef,4)+STRZERO(nMesRef,2)

If lRet
	u_WaitLog(cProg, {|oSay| PGCTR07(cMes)}, 'Processando faturamento...')
	u_WaitLog(cProg, {|oSay| IncDoc()}, 'Incluindo Documento de Entrada...')
EndIf

Return Nil



Static Function PrCom13
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cProg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cProg,.T.         ,.T.))
	lRet	:= .T.
	cDocI	:= mv_par01
	nMesRef	:= mv_par02
	nAnoRef	:= mv_par03
    cProd	:= aPrd[mv_par04]
	nValor  := mv_par05
	cHist   := mv_par06
Endif
Return lRet


Static Function ValidaDoc()
LOCAL lOk	:=.T.

IF EMPTY(cDocI) .OR. Val(cDocI) == 0
	u_MsgLog(cProg,"Número do Documento de Entrada incorreto", "E")
	lOk:= .F.
    RETURN lOk 
Endif

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
	aadd(aLinha,{"D1_VUNIT"  ,QTMP->F2_VALFAT,Nil})
	aadd(aLinha,{"D1_TOTAL"  ,QTMP->F2_VALFAT,Nil})
	aadd(aLinha,{"D1_CC"     ,QTMP->CNF_CONTRA,Nil})
	aadd(aLinha,{"D1_XXHIST" ,ALLTRIM(cHist),Nil})
	aadd(aItens,aLinha)
	nTotal += QTMP->F2_VALFAT
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
		RecLock("SF1",.F.)
		SF1->F1_XXLIB  := "L"
		SF1->F1_XXULIB := __cUserId
		SF1->F1_XXDLIB := DtoC(Date())+"-"+Time()
		MsUnLock("SF1")
	EndIf
EndIf

Return lRet


Static Function PGCTR07(cMes)
Local cQuery := ""

cQuery := "WITH BKGCTR07 AS ("+CRLF
cQuery += u_QGctR07(1,cMes)
cQuery += ")"+CRLF
cQuery += "SELECT CNF_CONTRA,SUM(F2_VALFAT) AS F2_VALFAT FROM BKGCTR07 GROUP BY CNF_CONTRA"+CRLF
cQuery += "ORDER BY CNF_CONTRA"+CRLF

u_LogMemo("BKCOMA13.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QTMP"

Return NIL


