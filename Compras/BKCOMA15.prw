#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} BKCOMA15()
Inclusão de Doc de Sindicatos com Rateio por CC

@author Marcos Bispo Abrahão
@since 08/01/2024
@version P12
@return .T.
/*/

User Function BKCOMA15()
Local lRet 		:= .F.
Local cMesI		:= ""
Local cMesF		:= ""
Local nX   		:= 0
Local cDesc		:= ""

Private cProg   := "BKCOMA15"
Private cTitulo := "Inclusão de Doc de Sindicatos com Rateio por CC"
Private cDocI	:= "000000000"
Private nMesI	:= Month(MonthSub(dDataBase,1))
Private nAnoI	:= Year(MonthSub(dDataBase,1))

Private cProd   := "21301004       "
Private nProd	:= 1
Private nValor  := 0.00

Private cForn 	 := "UNIAO "
Private cLoja	 := "00"
Private cSerie   := "DNF"
Private cEspec   := "DF   "
Private cUF      := "SP"
Private aParam	 :=	{}
Private aParamF  := {}
Private aRet	 :=	{}
Private cHist    := ""
Private aPrd     := {}
Private aPrdDesc := {}
Private cNFiscal := '000000000'
Private cArquivo := ""

// Seleção do arquivo exportado do senior
aAdd(aParamF,{6,"Arquivo txt exportado do Senior",Space(80),"","","",80,.F.,"Todos os arquivos (*.*) |*.*"})
//aAdd(aParamFile,{6,STR0076,padr("",150),"",,"",90 ,.T.,STR0077+" .CSV |*.CSV","",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}
If !(Parambox(aParamF    ,cProg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cProg,.T.         ,.T.))
	cArquivo:= mv_par01
	Return Nil
EndIf

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
aAdd(aPrd,"21401005")	// 8-IRRF ASSALARIADOS

// Descrição dos produtos
For nX := 1 To Len(aPrd)
	cDesc := TRIM(Posicione("SB1",1,xFilial("SB1")+aPrd[nX],"B1_DESC"))
	aAdd(aPrdDesc,aPrd[nX]+"-"+cDesc)
Next

//aAdd(aParam, { 1,"Documento"      ,cDocI   ,""    ,""                                       ,""   ,"",70,.T.})
aAdd(aParam, { 1,"Mes ref inicial",nMesI   ,"99"  ,"mv_par01 > 0 .AND. mv_par01 <= 12"      ,""   ,"",20,.T.})
aAdd(aParam, { 1,"Ano ref inicial",nAnoI   ,"9999","mv_par02 >= 2015 .AND. mv_par02 <= 2040",""   ,"",20,.T.})
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
	If !PrCom15()
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
	ElseIf nProd == 8
		u_WaitLog(cProg, {|oSay| u_PIRRFCC(cMesI,cMesF)}, 'Processando IRRF...')
	EndIf

	QTMP->(dbGoTop())
	If QTMP->(EOF())
		If nProd < 6
			u_MsgLog(cProg,"Não houve faturamento neste período","E")
		Else
			u_MsgLog(cProg,"Dados de rateio não encontrados, processe a GPS no sistema Senior e solicite a integração contábil.","E")
		EndIf
	Else
		u_WaitLog(cProg, {|oSay| IncDoc()}, 'Incluindo Documento de Entrada...')
	EndIf
EndIf

Return Nil



Static Function PrCom15
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
// Usuário e Superior
aadd(aCabec,{"F1_XXUSER" ,__cUserId})
aadd(aCabec,{"F1_XXUSERS",u_cSuper1(__cUserID)})
// Criar a NF Liberada
//aadd(aCabec,{"F1_XXLIB"  ,"L"})
//aadd(aCabec,{"F1_XXULIB" ,__cUserId})
//aadd(aCabec,{"F1_XXDLIB" ,DtoC(Date())+"-"+Time()})

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
	aadd(aLinha,{"D1_XXDCC"  ,Posicione("CTT",1,xFilial("CTT")+QTMP->CC,"CTT_DESC01"),Nil})
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
