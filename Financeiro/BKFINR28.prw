#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINR28
BK - RELATORIO DE DESPESAS POR ITEM DO DOCUMENTO DE ENTRADA POR CONTRADO POR MES
@Return
@author Marcos Bispo Abrahão
@since 01/06/2020
@version P12
/*/
//-------------------------------------------------------------------

User Function BKFINR28()


Private cTitulo     := "Despesas BK por Contrato por mes"
Private cPerg       := "BKFINR28"

Private aParam      := {}
Private aRet        := {}

Private cCusto      := SPACE(TamSx3("CTT_CUSTO")[1])
Private nMesI       := 1
Private nAnoI       := YEAR(dDataBase)
Private nMesF       := MONTH(dDataBase)
Private nAnoF       := YEAR(dDataBase)

Private cMesI       := ""
Private cMesF       := ""
Private nMeses      := 0
Private aMeses      := {}
Private dDataB      := dDataBase

Private oTmpTb
Private aFields     := {}
Private aCabs       := {}
Private aCampos     := {}
Private aTitulos    := {}
Private aPlans      := {}
Private aDbf        := {}
Private cAliasQry   := ""
Private cAliasTrb   := GetNextAlias()
Private nCont       := 0

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

aAdd(aParam, {1,"Contrato:"  ,cCusto,""    ,""                                       ,"CTT","",70,.F.})
aAdd(aParam, {1,"Mes inicial",nMesI ,"99"  ,"mv_par02 > 0 .AND. mv_par02 <= 12"      ,""   ,"",20,.F.})
aAdd(aParam, {1,"Ano inicial",nAnoI ,"9999","mv_par03 >= 2010 .AND. mv_par03 <= 2030",""   ,"",20,.F.})
aAdd(aParam, {1,"Mes final"  ,nMesF ,"99"  ,"mv_par04 > 0 .AND. mv_par04 <= 12"      ,""   ,"",20,.F.})
aAdd(aParam, {1,"Ano final"  ,nAnoF ,"9999","mv_par05 >= 2010 .AND. mv_par05 <= 2030",""   ,"",20,.F.})

If !BkFR28()
   Return
EndIf

cMesI  := STRZERO(nAnoI,4)+STRZERO(nMesI,2)
cMesF  := STRZERO(nAnoF,4)+STRZERO(nMesF,2)

nMes   := nMesI
nAno   := nAnoI

nMeses := 0
cMes   := cMesI
Do while cMes <= cMesF
	//             Mes  Titulo                               ,P F M 
 	nMeses++
	nMes++
	If nMes > 12
		nMes := 1
		nAno++
	EndIf
	cMes := STRZERO(nAno,4)+STRZERO(nMes,2)
EndDo

If nMeses <= 0
   MsgStop("Mês inicial deve ser menor que a final",cProg)
   Return Nil
EndIf

dDataB := STOD(cMes+"01") - 1

Processa( {|| ProcBKR28() })

If nCont > 0
    AADD(aPlans,{cAliasTrb,TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, .F. })
    U_GeraXlsx(aPlans,"",cPerg, .F., aParam)
else
    MsgStop("Não foram encontrados registros para esta seleção", cPerg)
EndIf

oTmpTb:Delete()

Return


Static Function BkFR28
Local lRet := .F.
//   Parambox(aParametros,@cTitle            ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam      ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,"BKFINR28",.T.         ,.T.))
	lRet     := .T.
    cCusto := mv_par01
    nMesI  := mv_par02
    nAnoI  := mv_par03
    nMesF  := mv_par04
    nAnoF  := mv_par05
Endif
Return lRet



Static Function ProcBKR28
Local cQuery    := ""
Local cFilD1    := ""
Local nI        := 0
Local nValor    := 0
Local nSaldo    := 0
Local nTSaldo   := 0
Local nASaldo   := 0

cQuery := "SELECT DISTINCT D1_FILIAL,D1_COD,D1_ITEM,B1_DESC,D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC AS D1_TOTAL,D1_QUANT,D1_CC,CTT_DESC01,"+CRLF
cQuery += "  D1_CONTA,D1_FORNECE,D1_LOJA,A2_NOME,D1_DOC,D1_SERIE,D1_DTDIGIT,D1_EMISSAO,D1_VUNIT,C7_XXURGEN,F1_VALMERC "+CRLF
cQuery += "  ,CONVERT(VARCHAR(8000),CONVERT(Binary(8000),D1_XXHIST)) D1_XXHIST "+CRLF
cQuery += "FROM "+RETSQLNAME("SD1")+" SD1 "
cQuery += "  INNER JOIN "+RETSQLNAME("SA2")+" SA2 ON D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA AND SA2.D_E_L_E_T_ = ' ' "+CRLF
cQuery += "  INNER JOIN "+RETSQLNAME("SB1")+" SB1 ON D1_COD = B1_COD AND SB1.D_E_L_E_T_ = ' ' "+CRLF
cQuery += "  INNER JOIN "+RETSQLNAME("CTT")+" CTT ON CTT_FILIAL = '"+xFilial("CTT")+"' AND D1_CC = CTT_CUSTO AND CTT.D_E_L_E_T_ = ' ' "+CRLF
cQuery += "  INNER JOIN "+RETSQLNAME("SF1")+" SF1 ON F1_FILIAL = D1_FILIAL AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1_TIPO = D1_TIPO "+CRLF
cQuery += "     AND SF1.D_E_L_E_T_ = ' ' "+CRLF 

cQuery += "  LEFT  JOIN "+RETSQLNAME("SC7")+" SC7 ON D1_FILIAL = C7_FILIAL AND D1_PEDIDO = C7_NUM AND D1_ITEMPC = C7_ITEM AND SC7.D_E_L_E_T_ = ' ' "+CRLF
cQuery += "WHERE SD1.D_E_L_E_T_ = ' ' "+CRLF

cQuery += " AND SUBSTRING(D1_DTDIGIT,1,6) >= '"+cMesI+"' "+CRLF
cQuery += " AND SUBSTRING(D1_DTDIGIT,1,6) <= '"+cMesF+"' "+CRLF
cQuery += " AND SD1.D1_CC = '"+ALLTRIM(cCusto)+"' "+CRLF
cQuery += "ORDER BY D1_DTDIGIT,D1_DOC,D1_COD "+CRLF

u_LogMemo("BKFINR28.SQL",cQuery)

cQuery := ChangeQuery(cQuery)
cAliasQry := "QSD1" //GetNextAlias()

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
TCSETFIELD("QSD1","D1_DTDIGIT","D",8,0)
TCSETFIELD("QSD1","D1_EMISSAO","D",8,0)
TCSETFIELD("QSD1","D1_XXHIST","M",10,0)
TCSETFIELD("QSD1","C7_XXURGEN","C",1,0)

Dbselectarea("QSD1")
QSD1->(Dbgotop())

ProcRegua((cAliasQry)->(LastRec()))
	
dbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())

cFilD1 := xFilial("SD1")

cMesMax := ""


aMeses := {}
DO WHILE (cAliasQry)->(!EOF())
	IncProc("Consultando banco de dados...")
    nCont++

	dbSelectArea("SE2")
	dbSetOrder(6)
	MsSeek(xFilial("SE2")+(cAliasQry)->(D1_FORNECE+D1_LOJA+D1_SERIE+D1_DOC))
	While !Eof() .And. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == ;
		xFilial("SE2")+(cAliasQry)->(D1_FORNECE+D1_LOJA+D1_SERIE+D1_DOC)
		If ALLTRIM(E2_ORIGEM)=="MATA100" .AND. SE2->E2_VENCREA >= dDataB
            cMes := SUBSTR(DTOS(E2_VENCREA),1,6)
            If Ascan(aMeses,{|x| x == cMes}) = 0
        	    AADD(aMeses,cMes)
            EndIf
		EndIf
		dbSkip()
	EndDo
	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbSkip())
ENDDO

aSort(aMeses,,,{|x,y| x < y })

aDbf := {}
aAdd(aCampos,"XX_PROD") //QSD1->D1_COD
aAdd(aCabs  ,"Produto")
aAdd(aDbf,  {"XX_PROD","C",TamSx3("D1_COD")[1],00 } )

aAdd(aCampos,"XX_DESC") //QSD1->B1_DESC
aAdd(aCabs  ,"Desc. Produto")
aAdd(aDbf,  {"XX_DESC","C",TamSx3("B1_DESC")[1],00 } )

aAdd(aCampos,"XX_CC") // QSD1->D1_CC
aAdd(aCabs  ,"Centro de Custos")
aAdd(aDbf,  {"XX_CC","C",TamSx3("D1_CC")[1],00 } )

aAdd(aCampos,"XX_DESC01")  //QSD1->CTT_DESC01
aAdd(aCabs  ,"Descriçao do C.C.")
aAdd(aDbf,  {"XX_DESC01","C",TamSx3("CTT_DESC01")[1],00 } )

aAdd(aCampos,"XX_CONTA") // QSD1->D1_CONTA
aAdd(aCabs  ,"Conta")
aAdd(aDbf,  {"XX_CONTA","C",TamSx3("D1_CONTA")[1],00 } )

aAdd(aCampos,"XX_FORNECE")  // QSD1->D1_FORNECE
aAdd(aCabs  ,"Fornecedor")
aAdd(aDbf,  {"XX_FORNECE","C",TamSx3("D1_FORNECE")[1],00 } )

aAdd(aCampos,"XX_LOJA") // QSD1->D1_LOJA
aAdd(aCabs  ,"Loja")
aAdd(aDbf,  {"XX_LOJA","C",TamSx3("D1_LOJA")[1],00 } )

aAdd(aCampos,"XX_NOME")  // QSD1->A2_NOME
aAdd(aCabs  ,"Nome do Fornecedor")
aAdd(aDbf,  {"XX_NOME","C",TamSx3("A2_NOME")[1],00 } )

aAdd(aCampos,"XX_DOC") // QSD1->D1_DOC
aAdd(aCabs  ,"Documento")
aAdd(aDbf,  {"XX_DOC","C",TamSx3("D1_DOC")[1],00 } )

aAdd(aCampos,"XX_DTDIGIT") // QSD1->D1_DTDIGIT
aAdd(aCabs  ,"Data")
aAdd(aDbf,  {"XX_DTDIGIT","D",8,00 } )

aAdd(aCampos,"XX_QUANT")  // QSD1->D1_QUANT
aAdd(aCabs  ,"Qtd.")
aAdd(aDbf,  {"XX_QUANT","N",TamSx3("D1_QUANT")[1],TamSx3("D1_QUANT")[2] } )
	
aAdd(aCampos,"XX_VUNIT") // ROUND(QSD1->D1_TOTAL / QSD1->D1_QUANT,2)
aAdd(aCabs  ,"Unit.")
aAdd(aDbf,  {"XX_VUNIT","N",TamSx3("D1_VUNIT")[1],TamSx3("D1_VUNIT")[2] } )

aAdd(aCampos,"XX_TOTAL")  // QSD1->D1_TOTAL
aAdd(aCabs  ,"Valor")
aAdd(aDbf,  {"XX_TOTAL","N",TamSx3("D1_TOTAL")[1],TamSx3("D1_TOTAL")[2] } )

aAdd(aCampos,"XX_SALDO")  // QSD1->D1_TOTAL
aAdd(aCabs  ,"Saldo em "+DTOC(dDataB))
aAdd(aDbf,  {"XX_SALDO","N",TamSx3("E2_SALDO")[1],TamSx3("E2_SALDO")[2] } )

For nI := 1 To Len(aMeses)
    aAdd(aCampos,"XX_"+aMeses[nI])
    aAdd(aCabs  ,"A Pagar "+SUBSTR(aMeses[nI],5,2)+"/"+SUBSTR(aMeses[nI],1,4))
    aAdd(aDbf,  {"XX_"+aMeses[nI],"N",TamSx3("E2_VALOR")[1],TamSx3("E2_VALOR")[2] } )
Next

aAdd(aCampos,"XX_XXURGEN") // QSD1->C7_XXURGEN
aAdd(aCabs  ,"Ped. Urgente")
aAdd(aDbf,  {"XX_XXURGEN","C",TamSx3("C7_XXURGEN")[1],00 } )

aAdd(aCampos,"XX_XXHIST") // QSD1->D1_XXHIST
aAdd(aCabs  ,"Historico")
aAdd(aDbf,  {"XX_XXHIST","M",10,00 } )

//----------------------------
//Criação da tabela temporária
//----------------------------
oTmpTb := FWTemporaryTable():New( cAliasTrb )
oTmpTb:SetFields( aDbf )

//oTmpTb:AddIndex("01", {"DESCR"} )
oTmpTb:Create()

dbSelectArea(cAliasQry)
(cAliasQry)->(dbGoTop())

DO WHILE (cAliasQry)->(!EOF())
	IncProc("Consultando banco de dados...")

    Reclock(cAliasTrb,.T.)

    (cAliasTrb)->XX_PROD    := QSD1->D1_COD
    (cAliasTrb)->XX_DESC    := QSD1->B1_DESC
    (cAliasTrb)->XX_CC      := QSD1->D1_CC
    (cAliasTrb)->XX_DESC01  := QSD1->CTT_DESC01
    (cAliasTrb)->XX_CONTA   := QSD1->D1_CONTA
    (cAliasTrb)->XX_FORNECE := QSD1->D1_FORNECE
    (cAliasTrb)->XX_LOJA    := QSD1->D1_LOJA
    (cAliasTrb)->XX_NOME    := QSD1->A2_NOME
    (cAliasTrb)->XX_DOC     := QSD1->D1_DOC
    (cAliasTrb)->XX_DTDIGIT := QSD1->D1_DTDIGIT
    (cAliasTrb)->XX_QUANT   := QSD1->D1_QUANT
    (cAliasTrb)->XX_VUNIT   := QSD1->D1_VUNIT
    (cAliasTrb)->XX_TOTAL   := QSD1->D1_TOTAL
    (cAliasTrb)->XX_XXURGEN := QSD1->C7_XXURGEN
    (cAliasTrb)->XX_XXHIST  := QSD1->D1_XXHIST

    nSaldo  := 0
    nTSaldo := 0
    nASaldo := 0

	dbSelectArea("SE2")
	dbSetOrder(6)
	MsSeek(xFilial("SE2")+(cAliasQry)->(D1_FORNECE+D1_LOJA+D1_SERIE+D1_DOC))
	While !Eof() .And. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == ;
		xFilial("SE2")+(cAliasQry)->(D1_FORNECE+D1_LOJA+D1_SERIE+D1_DOC)
		If ALLTRIM(E2_ORIGEM)=="MATA100"
            If SE2->E2_VENCREA >= dDataB
                cMes := SUBSTR(DTOS(E2_VENCREA),1,6)
                If Ascan(aMeses,{|x| x == cMes}) <> 0
                    // Valor do do titulo proporcional ao item
                    nValor := ROUND((cAliasQry)->D1_TOTAL / (cAliasQry)->F1_VALMERC * SE2->E2_VALOR,2)
                    &(cAliasTrb+"->XX_"+cMes) +=  nValor
                EndIf
            Else
                nSaldo += SaldoTit(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,;
								   SE2->E2_NATUREZA,"P",SE2->E2_FORNECE,1,dDataB,,SE2->E2_LOJA,,0)
            EndIf
		EndIf
		dbSkip()
	EndDo


    (cAliasTrb)->XX_SALDO  := nSaldo

    (cAliasTrb)->(MsUnLock())

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbSkip())
ENDDO

(cAliasQry)->(dbCloseArea())

dbSelectArea(cAliasTrb)
dbGoTop()

Return
