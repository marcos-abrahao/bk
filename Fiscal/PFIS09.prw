#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
                                        
/*/{Protheus.doc} PFIS09
Mr/Proeletronic/BK - Correçao Calculo Pis Cofins conforme TES

@Return
@author Adilson do Prado / Marcos Bispo Abrahão
@since 29/01/13
@version P12
/*/
User Function PFIS09()

Local aDbf := {}
Local oTmpTb

PRIVATE cTitulo     := "Retificação calculo PIS COFINS conforme TES"
PRIVATE cPerg       := "PFIS09"
PRIVATE dDataInicio := dDataBase
PRIVATE dDataFinal  := dDataBase
PRIVATE cCFOP		:= ""
PRIVATE cForn       := ""
PRIVATE cProd       := ""
PRIVATE cCODTES    	:= ""
PRIVATE nTPMOV    	:= 1
PRIVATE cArqS		:= "\tmp\PFIS09"
PRIVATE aFixeFX     := {}
PRIVATE aTitulos,aCampos,aCabs,aTotais
PRIVATE ALIAS_TMP    := "QTMP1"
PRIVATE _nTXPIS 	:= GetMV("MV_TXPIS") //1.65 //
PRIVATE _nTXCOFINS 	:= GetMV("MV_TXCOFINS") //7.6 //
ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

dDataInicio := mv_par01
dDataFinal  := mv_par02
cCFOP		:= mv_par03
cCODTES    	:= mv_par04
nTPMOV    	:= mv_par05
cProd 		:= mv_par06
cForn   	:= mv_par07


IF EMPTY(dDataFinal) .OR.  EMPTY(dDataInicio)
	MSGSTOP("Informe a data início e final")                
	Return Nil

ENDIF 

IF dDataFinal < dDataInicio
	MSGSTOP("Informe a data início e final")                
	Return Nil

ENDIF

IF dDataInicio > dDataFinal
	MSGSTOP("Informe a data início e final")                
	Return Nil

ENDIF

cTitulo   := cTitulo+" - Período:"+DTOC(dDataInicio)+" até "+DTOC(dDataFinal)

aDbf    := {}
Aadd( aDbf, { 'XX_LINHA', 'N', 10,00 } )
Aadd( aDbf, { 'XX_FILIAL','C',02,00 } )
Aadd( aDbf, { 'XX_NFISCAL','C',09,00 } )
Aadd( aDbf, { 'XX_SERIE','C',03,00 } )
Aadd( aDbf, { 'XX_CLIEFOR','C',06,00 } )
Aadd( aDbf, { 'XX_LOJA','C',02,00 } )
Aadd( aDbf, { 'XX_ENTRADA','D',08,00 } )
Aadd( aDbf, { 'XX_EMISSAO','D',08,00 } )
Aadd( aDbf, { 'XX_CFOP','C',05,00 } )
Aadd( aDbf, { 'XX_CFOPIT','C',05,00 } )
Aadd( aDbf, { 'XX_TES','C',03,00 } )
Aadd( aDbf, { 'XX_ITEM','C',04,00 } )
Aadd( aDbf, { 'XX_PRODUTO','C',15,00 } )
Aadd( aDbf, { 'XX_VALCONT','N',14,02 } )

Aadd( aDbf, { 'XX_CLASFIS','C',03,00 } )
Aadd( aDbf, { 'XX_CLASF_C','C',03,00 } )
Aadd( aDbf, { 'XX_CSTCOF','C',02,00 } )
Aadd( aDbf, { 'XX_CSTC_C','C',02,00 } )
Aadd( aDbf, { 'XX_CSTPIS','C',02,00 } )
Aadd( aDbf, { 'XX_CSTP_C','C',02,00 } )

Aadd( aDbf, { 'XX_ALIQPIS','N',06,02 } )
Aadd( aDbf, { 'XX_ALIPISC','N',06,02 } )
Aadd( aDbf, { 'XX_BASEPIS','N',16,02 } )
Aadd( aDbf, { 'XX_BASPISC','N',16,02 } )
Aadd( aDbf, { 'XX_VALPIS','N',14,02 } )
Aadd( aDbf, { 'XX_VALPISC','N',14,02 } )

Aadd( aDbf, { 'XX_ALIQCOF','N',06,02 } )
Aadd( aDbf, { 'XX_ALICOFC','N',06,02 } )
Aadd( aDbf, { 'XX_BASECOF','N',16,02 } )
Aadd( aDbf, { 'XX_BASCOFC','N',16,02 } )
Aadd( aDbf, { 'XX_VALCOF','N',14,02 } )
Aadd( aDbf, { 'XX_VALCOFC','N',14,02 } )

Aadd( aDbf, { 'XX_ICMSRET','N',14,02 } )
Aadd( aDbf, { 'XX_VALIPI','N',14,02 } )

Aadd( aDbf, { 'XX_ERROS','C',250,00 } )
Aadd( aDbf, { 'XX_STATUS','C',1,00 } )
Aadd( aDbf, { 'XX_CODBCC','C',02,00 } )

///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,'TRB',.f.,.f. )
///IndRegua("TRB",cArqTmp,"XX_LINHA",,,"Indexando Arquivo de Trabalho") 

oTmpTb := FWTemporaryTable():New( "TRB")
oTmpTb:SetFields( aDbf )
oTmpTb:AddIndex("indice1", {"XX_LINHA"} )
oTmpTb:Create()


nomeprog := "PFIS09/"+TRIM(SUBSTR(cUsuario,7,15))

aCabs   := {}
aCampos := {}
aTitulos:= {}
aFixeFX := {}

AADD(aTitulos,cTitulo)

AADD(aCampos,"TRB->XX_LINHA")
AADD(aCabs  ,"Linha")

Aadd( aCampos,"TRB->XX_FILIAL")
AADD(aCabs  ,"FILIAL")
AAdd(aFixeFX,{"Filial","XX_FILIAL",'C', 02,00,'@!'})

Aadd( aCampos,"TRB->XX_NFISCAL")
AADD(aCabs  ,"NFISCAL")
AAdd(aFixeFX,{"NFISCAL","XX_NFISCAL",'C', 09,00,'@!'})

Aadd( aCampos,"TRB->XX_SERIE")
AADD(aCabs  ,"SERIE")
AAdd(aFixeFX,{"SERIE","XX_SERIE",'C', 03,00,'@!'})

Aadd( aCampos,"TRB->XX_CLIEFOR")
AADD(aCabs  ,"CLI/FOR")
AAdd(aFixeFX,{"CLI/FOR","XX_CLIEFOR",'C', 06,00,'@!'})

Aadd( aCampos,"TRB->XX_LOJA")
AADD(aCabs  ,"LOJA")
AAdd(aFixeFX,{"LOJA","XX_LOJA",'C', 02,00,'@!'})

Aadd( aCampos,"XX_ENTRADA")
AADD(aCabs  ,"DTENTRADA")
AAdd(aFixeFX,{"DTENTRADA","XX_ENTRADA",'D', 08,00,'@D'})

Aadd( aCampos,"XX_EMISSAO")
AADD(aCabs  ,"DTEMISSAO")
AAdd(aFixeFX,{"DTEMISSAO","XX_EMISSAO",'D', 08,00,'@D'})

Aadd( aCampos,"TRB->XX_CFOP")
AADD(aCabs  ,"CFOP")
AAdd(aFixeFX,{"CFOP","XX_CFOP",'C', 05,00,'@!'})

Aadd( aCampos,"TRB->XX_CFOPIT")
AADD(aCabs  ,"CFOPIT")
AAdd(aFixeFX,{"CFOP","XX_CFOPIT",'C', 05,00,'@!'})

Aadd( aCampos,"TRB->XX_TES")
AADD(aCabs  ,"TES")
AAdd(aFixeFX,{"TES","XX_TES",'C', 03,00,'@!'})

Aadd( aCampos,"TRB->XX_ITEM")
AADD(aCabs  ,"ITEM")
AAdd(aFixeFX,{"ITEM","XX_ITEM",'C', 04,00,'@!'})

Aadd( aCampos,"TRB->XX_PRODUTO")
AADD(aCabs  ,"PRODUTO")
AAdd(aFixeFX,{"PRODUTO","XX_PRODUTO",'C', 15,00,'@!'})

Aadd( aCampos,"TRB->XX_VALCONT")
AADD(aCabs  ,"VALCONT")
AAdd(aFixeFX,{"VALCONT","XX_VALCONT",'N', 14,02,'@E 999,999,999.99'})

Aadd( aCampos,"TRB->XX_CLASFIS")
AADD(aCabs  ,"CLASFIS")
AAdd(aFixeFX,{"CLASFIS","XX_CLASFIS",'C', 03,00,'@!'})

Aadd( aCampos,"TRB->XX_CLASF_C")
AADD(aCabs  ,"CLASFIS_CALC")
AAdd(aFixeFX,{"CLASFIS_CALC","XX_CLASF_C",'C', 03,00,'@!'})

Aadd( aCampos,"TRB->XX_CSTCOF")
AADD(aCabs  ,"CSTCOF")
AAdd(aFixeFX,{"CSTCOF","XX_CSTCOF",'C', 02,00,'@!'})

Aadd( aCampos,"TRB->XX_CSTC_C")
AADD(aCabs  ,"CSTCOF_CALC")
AAdd(aFixeFX,{"CSTCOF_CALC","XX_CSTC_C",'C', 02,00,'@!'})

Aadd( aCampos,"TRB->XX_CSTPIS")
AADD(aCabs  ,"CSTPIS")
AAdd(aFixeFX,{"CSTPIS","XX_CSTPIS",'C', 02,00,'@!'})

Aadd( aCampos,"TRB->XX_CSTP_C")
AADD(aCabs  ,"CSTPIS_CALC")
AAdd(aFixeFX,{"CSTPIS_CALC","XX_CSTP_C",'C', 02,00,'@!'})

//*********** PIS
Aadd( aDbf, { 'XX_ALIQPIS','N',06,02 } )

Aadd( aCampos,"TRB->XX_ALIQPIS")
AADD(aCabs  ,"ALIQPIS")
AAdd(aFixeFX,{"ALIQPIS","XX_ALIQPIS",'N', 06,02,'@E 999.99'})

Aadd( aDbf, { 'XX_ALIPISC','N',06,02 } )

Aadd( aCampos,"TRB->XX_ALIPISC")
AADD(aCabs  ,"ALIPIS_CALC")
AAdd(aFixeFX,{"ALIPIS_CALC","XX_ALIPISC",'N', 06,02,'@E 999.99'})

Aadd( aDbf, { 'XX_BASEPIS','N',16,02 } )

Aadd( aCampos,"TRB->XX_BASEPIS")
AADD(aCabs  ,"BASEPIS")
AAdd(aFixeFX,{"BASEPIS","XX_BASEPIS",'N', 16,02,'@E 9,999,999,999.99'})

Aadd( aDbf, { 'XX_BASPISC','N',16,02 } )

Aadd( aCampos,"TRB->XX_BASPISC")
AADD(aCabs  ,"BASEPIS_CALC")
AAdd(aFixeFX,{"BASEPIS_CALC","XX_BASPISC",'N', 16,02,'@E 9,999,999,999.99'})

Aadd( aDbf, { 'XX_VALPIS','N',14,02 } )

Aadd( aCampos,"XX_VALPIS")
AADD(aCabs  ,"VALPIS")
AAdd(aFixeFX,{"VALPIS","XX_VALPIS",'N', 14,02,'@E 999,999,999.99'})

Aadd( aDbf, { 'XX_VALPISC','N',14,02 } )

Aadd( aCampos,"XX_VALPISC")
AADD(aCabs  ,"VALPIS_CALC")
AAdd(aFixeFX,{"VALPIS_CALC","XX_VALPISC",'N', 14,02,'@E 999,999,999.99'})
//*********** PIS

//*********** COFINS
Aadd( aCampos,"TRB->XX_ALIQCOF")
AADD(aCabs  ,"ALIQCOF")
AAdd(aFixeFX,{"ALIQCOF","XX_ALIQCOF",'N', 06,02,'@E 999.99'})

Aadd( aCampos,"TRB->XX_ALICOFC")
AADD(aCabs  ,"ALICOF_CALC")
AAdd(aFixeFX,{"ALICOF_CALC","XX_ALICOFC",'N', 06,02,'@E 999.99'})

Aadd( aCampos,"TRB->XX_BASECOF")
AADD(aCabs  ,"BASECOF")
AAdd(aFixeFX,{"BASECOF","XX_BASECOF",'N', 16,02,'@E 9,999,999,999.99'})

Aadd( aCampos,"TRB->XX_BASCOFC")
AADD(aCabs  ,"BASECOF_CALC")
AAdd(aFixeFX,{"BASECOF_CALC","XX_BASCOFC",'N', 16,02,'@E 9,999,999,999.99'})

Aadd( aCampos,"XX_VALCOF")
AADD(aCabs  ,"VALCOF")
AAdd(aFixeFX,{"VALCOF","XX_VALCOF",'N', 14,02,'@E 999,999,999.99'})

Aadd( aCampos,"XX_VALCOFC")
AADD(aCabs  ,"VALCOF_CALC")
AAdd(aFixeFX,{"VALCOF_CALC","XX_VALCOFC",'N', 14,02,'@E 999,999,999.99'})
//*********** COFINS


Aadd( aCampos,"XX_ICMSRET")
AADD(aCabs  ,"ICMSRET")
AAdd(aFixeFX,{"ICMSRET","XX_ICMSRET",'N', 14,02,'@E 999,999,999.99'})

Aadd( aCampos,"XX_VALIPI")
AADD(aCabs  ,"VALIPI")
AAdd(aFixeFX,{"VALIPI","XX_VALIPI",'N', 14,02,'@E 999,999,999.99'})


Aadd( aCampos,"TRB->XX_ERROS")
AADD(aCabs  ,"ERROS")
AAdd(aFixeFX,{"ERROS","XX_ERROS",'C', 20,00,'@!'})

Aadd( aCampos,"TRB->XX_STATUS")
AADD(aCabs  ,"STATUS")
AAdd(aFixeFX,{"STATUS","XX_STATUS",'C', 01,00,'@!'})

Aadd( aCampos,"TRB->XX_CODBCC")
AADD(aCabs  ,"CODBCC")
AAdd(aFixeFX,{"CODBCC","XX_CODBCC",'C', 02,00,'@!'})

Processa( {|| ProcPFIS09() })

//Processa ( {|| MBrwPFIS09()})
If MsgYesNo("Corrige?","Ajuste PIS/COFINS")
	cArqTmp := U_CORPFIS09()
	U_SENDMAIL("PFIS09","Backup PIS COFINS","microsiga@bkconsultoria.com.br;","","Segue anexo BACKUP PIS COFINS"+DTOC(DATE())+TIME()+" - "+cArqTmp,cArqTmp,.F.)
Else
	Processa ( {|| U_CSVPFIS09()})
EndIf

oTmpTb:Delete()
///TRB->(Dbclosearea())
 
Return




User Function LegendaPFIS09()
Local aLegenda := {}

AADD(aLegenda,{"BR_VERDE" ,"Calculo OK" })
AADD(aLegenda,{"BR_VERMELHO" ,"Verificar Calculo" })

BrwLegenda(cCadastro, "Legenda", aLegenda)
Return Nil



USER FUNCTION PARPFIS09()
LOCAL cPerg  := "PFIS09"

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

dDataInicio := mv_par01
dDataFinal  := mv_par02
cCFOP		:= mv_par03
cCODTES    	:= mv_par04
nTPMOV    	:= mv_par05
cProd 		:= mv_par06
cForn   	:= mv_par07
  
Processa( {|| ProcPFIS09() })

Return Nil

/*
Static Function MBrwPFIS09()
Local 	cAlias 		:= "TRB"
Local 	aCores 		:= {}
Local 	cFiltra   := "XX_LINHA>=0"

Private cCadastro	:= "Retificação calculo PIS COFINS conforme TES"
Private aRotina		:= {}
Private aIndexSz  	:= {}
Private bFiltraBrw	:= { || FilBrowse(cAlias,@aIndexSz,@cFiltra) }

AADD(aRotina,{"Exp. Excel"	,"U_CSVPFIS09",0,6})
AADD(aRotina,{"Parametros"	,"U_PARPFIS09",0,2})
AADD(aRotina,{"Corrigir"	,"U_CORPFIS09",0,8})
AADD(aRotina,{"Legenda"		,"U_LegendaPFIS09",0,9})

AADD(aCores,{"XX_STATUS <> 'E'" ,"BR_VERDE" })
AADD(aCores,{"XX_STATUS == 'E'" ,"BR_VERMELHO" })

*/
/*
-- CORES DISPONIVEIS PARA LEGENDA --
BR_AMARELO
BR_AZUL
BR_BRANCO
BR_CINZA
BR_LARANJA
BR_MARRON
BR_VERDE
BR_VERMELHO
BR_PINK
BR_PRETO
*/
/*
dbSelectArea(cAlias)
dbSetOrder(1)
//+------------------------------------------------------------
//| Cria o filtro na MBrowse utilizando a função FilBrowse
//+------------------------------------------------------------
Eval(bFiltraBrw)

dbSelectArea(cAlias)
dbGoTop()

mBrowse(6,1,22,75,cAlias,aFixeFX,,,,,aCores)

//+------------------------------------------------
//| Deleta o filtro utilizado na função FilBrowse
//+------------------------------------------------
//EndFilBrw(cAlias,aIndexSz)

Return Nil
*/




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



User FUNCTION CSVPFIS09()
Local cAlias := "TRB"
Local aPlans := {}
Local cFile := ""

dbSelectArea(cAlias)

///ProcRegua(10)
///Processa( {|| GCSVPFIS09(cAlias,"PFIS09",aTitulos,aCampos,aCabs,1)})

//Processa( {|| U_GeraCSV("TRB",TRIM(cPerg),aTitulos,aCampos,aCabs,"","",aQuebra,.F.)})

AADD(aPlans,{"TRB",TRIM(cPerg),"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */,/*aTotal */, /*cQuebra*/, lClose:= .F. })
cFile := U_GeraXlsx(aPlans,cTitulo,TRIM(cPerg))

Return cFile

   

Static Function ProcPFIS09()
LOCAL  cQuery,cERRO := ""
LOCAL nLINHA := 0

LimpaBrw("TRB")

cQuery:= "SELECT FT_FILIAL,FT_NFISCAL,FT_SERIE,FT_CLIEFOR,FT_LOJA,FT_ENTRADA,FT_EMISSAO,FT_CFOP,"

IF nTPMOV=1
	cQuery += "D1_TES AS FT_TES,D1_ICMSRET AS FT_ICMSRET,D1_VALIPI AS FT_VALIPI,D1_CF AS CFOPIT,"
	cQuery += "D1_ALQIMP5 AS FT_ALIQCOF,D1_BASIMP5 AS FT_BASECOF,D1_VALIMP5 AS FT_VALCOF,"
	cQuery += "D1_ALQIMP6 AS FT_ALIQPIS,D1_BASIMP6 AS FT_BASEPIS,D1_VALIMP6 AS FT_VALPIS, '' AS A1_XACUMUL,"
ELSE
	cQuery += "D2_TES AS FT_TES,D2_ICMSRET AS FT_ICMSRET,D2_VALIPI AS FT_VALIPI,D2_CF AS CFOPIT,"
	cQuery += "D2_ALQIMP5 AS FT_ALIQCOF,D2_BASIMP5 AS FT_BASECOF,D2_VALIMP5 AS FT_VALCOF,"
	cQuery += "D2_ALQIMP6 AS FT_ALIQPIS,D2_BASIMP6 AS FT_BASEPIS,D2_VALIMP6 AS FT_VALPIS,'' AS A1_XACUMUL,"
ENDIF
	
cQuery+= "FT_ITEM,FT_PRODUTO,FT_CLASFIS,FT_CSTCOF,FT_CSTPIS,FT_VALCONT,FT_CODBCC,"
cQuery+= "B1_ORIGEM+F4_SITTRIB AS F4_SITTRIB,F4_PISCOF,F4_CSTPIS,F4_CSTCOF,F4_PISBRUT,F4_COFBRUT,F4_PISCRED,FT_TIPOMOV,F4_CODBCC" 
cQuery+= " FROM "+RETSQLNAME("SFT")+"  SFT"

IF nTPMOV=1 
	cQuery+= " INNER JOIN "+RETSQLNAME("SD1")+" SD1 ON SFT.FT_FILIAL=SD1.D1_FILIAL AND SFT.FT_NFISCAL=SD1.D1_DOC AND SFT.FT_SERIE=SD1.D1_SERIE AND SFT.FT_CLIEFOR=SD1.D1_FORNECE AND SFT.FT_LOJA=SD1.D1_LOJA AND SFT.FT_ITEM=SD1.D1_ITEM AND SD1.D_E_L_E_T_=''"
	cQuery+= " LEFT JOIN "+RETSQLNAME("SF4")+" SF4 ON SD1.D1_FILIAL=SF4.F4_FILIAL AND SD1.D1_TES=SF4.F4_CODIGO AND SF4.D_E_L_E_T_=''"
ELSE
	cQuery+= " INNER JOIN "+RETSQLNAME("SD2")+" SD2 ON SFT.FT_FILIAL=SD2.D2_FILIAL AND SFT.FT_NFISCAL=SD2.D2_DOC AND SFT.FT_SERIE=SD2.D2_SERIE AND SFT.FT_CLIEFOR=SD2.D2_CLIENTE AND SFT.FT_LOJA=SD2.D2_LOJA AND SFT.FT_ITEM=SD2.D2_ITEM AND SD2.D_E_L_E_T_=''"
	cQuery+= " INNER JOIN "+RETSQLNAME("SA1")+" SA1 ON SA1.A1_COD=SD2.D2_CLIENTE AND SA1.A1_LOJA=SD2.D2_LOJA AND SA1.D_E_L_E_T_=''""
	cQuery+= " LEFT JOIN "+RETSQLNAME("SF4")+" SF4 ON SD2.D2_FILIAL=SF4.F4_FILIAL AND SD2.D2_TES=SF4.F4_CODIGO AND SF4.D_E_L_E_T_=''"
ENDIF

cQuery+= " LEFT JOIN "+RETSQLNAME("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SFT.FT_PRODUTO=SB1.B1_COD  AND SB1.D_E_L_E_T_=''"

cQuery+= " WHERE  SFT.FT_ENTRADA >= '"+DTOS(dDataInicio)+"' AND  SFT.FT_ENTRADA <= '"+DTOS(dDataFinal)+"'  AND SFT.FT_TIPOMOV = '"+IIF(nTPMOV=1,"E","S")+"' AND SFT.D_E_L_E_T_=''"

IF !EMPTY(cCFOP)
	cQuery+= " AND FT_CFOP ='"+ALLTRIM(cCFOP)+"'"
ENDIF
IF !EMPTY(cCODTES)
	IF nTPMOV=1
		cQuery+= " AND D1_TES ='"+ALLTRIM(cCODTES)+"'"
	ELSE
		cQuery+= " AND D2_TES ='"+ALLTRIM(cCODTES)+"'"
	ENDIF
ENDIF

IF !EMPTY(cProd)
	IF nTPMOV=1
		cQuery+= " AND D1_COD ='"+ALLTRIM(cProd)+"'"
	ELSE
		cQuery+= " AND D2_COD ='"+ALLTRIM(cProd)+"'"
	ENDIF
ENDIF

IF !EMPTY(cForn)
	IF nTPMOV=1
		cQuery+= " AND D1_FORNECE ='"+ALLTRIM(cForn)+"'"
	ELSE
		cQuery+= " AND D2_CLIENTE ='"+ALLTRIM(cForn)+"'"
	ENDIF
ENDIF

cQuery+= " ORDER BY FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO"



TCQUERY cQuery NEW ALIAS "QTMP1"

TCSETFIELD(ALIAS_TMP,"FT_ENTRADA","D",8,0)
TCSETFIELD(ALIAS_TMP,"FT_EMISSAO","D",8,0)

dbSelectArea("QTMP1")

nLINHA:= 0
aTotais := {}
AADD(aTotais,{"TOTAL",0,0,0,0,0,0,0,0})
DbSelectArea("TRB")
(ALIAS_TMP)->(dbgotop())
Do While (ALIAS_TMP)->(!eof())
    cERRO := ""
 	nLINHA++
	dbSelectArea("TRB")
	Reclock("TRB",.T.)
	TRB->XX_LINHA   := nLINHA
	TRB->XX_FILIAL	:=	(ALIAS_TMP)->FT_FILIAL
	TRB->XX_NFISCAL	:=	(ALIAS_TMP)->FT_NFISCAL
	TRB->XX_SERIE	:=	(ALIAS_TMP)->FT_SERIE
	TRB->XX_CLIEFOR	:=	(ALIAS_TMP)->FT_CLIEFOR
	TRB->XX_LOJA	:=	(ALIAS_TMP)->FT_LOJA
	TRB->XX_ENTRADA	:=	(ALIAS_TMP)->FT_ENTRADA
	TRB->XX_EMISSAO	:=	(ALIAS_TMP)->FT_EMISSAO
	TRB->XX_CFOP	:=	(ALIAS_TMP)->FT_CFOP
	TRB->XX_CFOPIT	:=	(ALIAS_TMP)->CFOPIT
	TRB->XX_TES		:=	(ALIAS_TMP)->FT_TES
	TRB->XX_ITEM	:=	(ALIAS_TMP)->FT_ITEM
	TRB->XX_PRODUTO	:=	(ALIAS_TMP)->FT_PRODUTO
	TRB->XX_VALCONT	:=	(ALIAS_TMP)->FT_VALCONT
		
	TRB->XX_CLASFIS	:=	(ALIAS_TMP)->FT_CLASFIS
	TRB->XX_CLASF_C	:=	(ALIAS_TMP)->F4_SITTRIB
	IF (ALIAS_TMP)->FT_CLASFIS <> (ALIAS_TMP)->F4_SITTRIB
		cERRO += "Situac. Tributária,"
	ENDIF

	TRB->XX_CSTPIS	:=	(ALIAS_TMP)->FT_CSTPIS
	TRB->XX_CSTP_C	:=	(ALIAS_TMP)->F4_CSTPIS

	IF (ALIAS_TMP)->FT_CSTPIS <> (ALIAS_TMP)->F4_CSTPIS
		cERRO += "CST PIS,"
	ENDIF

	TRB->XX_CSTCOF	:=	(ALIAS_TMP)->FT_CSTCOF
	TRB->XX_CSTC_C	:=	(ALIAS_TMP)->F4_CSTCOF

	IF (ALIAS_TMP)->FT_CSTCOF <> (ALIAS_TMP)->F4_CSTCOF
		cERRO += "CST COFINS,"
	ENDIF
		
	TRB->XX_ALIQPIS	:=	(ALIAS_TMP)->FT_ALIQPIS
	TRB->XX_BASEPIS	:=	(ALIAS_TMP)->FT_BASEPIS
	TRB->XX_VALPIS	:=	(ALIAS_TMP)->FT_VALPIS

	TRB->XX_ALIQCOF	:=	(ALIAS_TMP)->FT_ALIQCOF
	TRB->XX_BASECOF	:=	(ALIAS_TMP)->FT_BASECOF
	TRB->XX_VALCOF	:=	(ALIAS_TMP)->FT_VALCOF
		

	IF (ALIAS_TMP)->FT_CODBCC <> (ALIAS_TMP)->F4_CODBCC
		cERRO += "CODBCC,"
	ENDIF	
	TRB->XX_CODBCC	:=	(ALIAS_TMP)->F4_CODBCC
		
	TRB->XX_ICMSRET	:=	(ALIAS_TMP)->FT_ICMSRET
	TRB->XX_VALIPI	:=	(ALIAS_TMP)->FT_VALIPI

	nALIPISC:= 0
	nBASPISC:= 0
	nVALPISC:= 0

	nALICOFC:= 0
	nBASCOFC:= 0
	nVALCOFC:= 0

	IF  (ALIAS_TMP)->FT_TIPOMOV == 'E'


		// Verificar se está considerando o parametro MV_FRTBASE - Frete e desp na base

		IF(ALIAS_TMP)->F4_CSTPIS $ "04/05/06/07/08/09/49"
			nALIPISC:= 0
			nBASPISC:= 0
			nVALPISC:= 0
		ELSEIF  (ALIAS_TMP)->F4_PISCOF $ "1/3"
			IF(ALIAS_TMP)->F4_PISBRUT == "1"
				nALIPISC := _nTXPIS
				nBASPISC := (ALIAS_TMP)->FT_VALCONT
				nVALPISC := ((ALIAS_TMP)->FT_VALCONT * _nTXPIS)/100
			ELSE
				nALIPISC := _nTXPIS
				nDescto  := 0
				IF  ALLTRIM(GetMV("MV_DEDBPIS")) == 'I'
					nDescto  := (ALIAS_TMP)->FT_ICMSRET
				ELSEIF  ALLTRIM(GetMV("MV_DEDBPIS")) == 'P'
					nDescto  := (ALIAS_TMP)->FT_VALIPI
				ELSEIF  ALLTRIM(GetMV("MV_DEDBPIS")) == 'S'
					nDescto  := (ALIAS_TMP)->FT_VALIPI  + (ALIAS_TMP)->FT_ICMSRET
                ENDIF
				nBASPISC := (ALIAS_TMP)->FT_VALCONT - nDescto 
				nVALPISC := (nBASPISC * _nTXPIS)/100
			ENDIF 
		ELSE
			nALIPISC:= 0
			nBASPISC:= 0
			nVALPISC:= 0
		ENDIF
		IF(ALIAS_TMP)->F4_CSTCOF $ "04/05/06/07/08/09/49"
			nALICOFC := 0
			nBASCOFC := 0
			nVALCOFC := 0
		ELSEIF  (ALIAS_TMP)->F4_PISCOF $ "2/3"
			IF(ALIAS_TMP)->F4_COFBRUT  == "1"
				nALICOFC := _nTXCOFINS
				nBASCOFC := (ALIAS_TMP)->FT_VALCONT
				nVALCOFC := ((ALIAS_TMP)->FT_VALCONT * _nTXCOFINS)/100
			ELSE
				nALICOFC := _nTXCOFINS
				nDescto  := 0
				IF  ALLTRIM(GetMV("MV_DEDBCOF")) == 'I'
					nDescto  := (ALIAS_TMP)->FT_ICMSRET
				ELSEIF  ALLTRIM(GetMV("MV_DEDBCOF")) == 'P'
					nDescto  := (ALIAS_TMP)->FT_VALIPI
				ELSEIF  ALLTRIM(GetMV("MV_DEDBCOF")) == 'S'
					nDescto  := (ALIAS_TMP)->FT_VALIPI  + (ALIAS_TMP)->FT_ICMSRET
                ENDIF
				nBASCOFC := (ALIAS_TMP)->FT_VALCONT - nDescto
				nVALCOFC := (nBASCOFC* _nTXCOFINS)/100
			ENDIF 
		ELSE
			nALICOFC := 0
			nBASCOFC := 0
			nVALCOFC := 0
		ENDIF
    ELSEIF (ALIAS_TMP)->FT_TIPOMOV == 'S' 
		IF(ALIAS_TMP)->F4_CSTPIS $ "70/71/72/73/74/75/98/99"
			nALIPISC:= 0
			nBASPISC:= 0
			nVALPISC:= 0
		ELSEIF  (ALIAS_TMP)->F4_PISCOF $ "1/3"
			IF(ALIAS_TMP)->F4_PISBRUT == "1"
				nALIPISC := _nTXPIS
				nBASPISC := (ALIAS_TMP)->FT_VALCONT
				nVALPISC := ((ALIAS_TMP)->FT_VALCONT * _nTXPIS)/100
			ELSE
				nALIPISC := _nTXPIS
				nBASPISC := (ALIAS_TMP)->FT_VALCONT - (ALIAS_TMP)->FT_ICMSRET - (ALIAS_TMP)->FT_VALIPI
				nVALPISC := (nBASPISC* _nTXPIS)/100
			ENDIF 
		ELSE
			nALIPISC:= 0
			nBASPISC:= 0
			nVALPISC:= 0
		ENDIF
		IF(ALIAS_TMP)->F4_CSTCOF $ "70/71/72/73/74/75/98/99"
			nALICOFC := 0
			nBASCOFC := 0
			nVALCOFC := 0
		ELSEIF  (ALIAS_TMP)->F4_PISCOF $ "2/3"
			IF(ALIAS_TMP)->F4_COFBRUT == "1"
				nALICOFC := _nTXCOFINS
				nBASCOFC := (ALIAS_TMP)->FT_VALCONT
				nVALCOFC := Round(((ALIAS_TMP)->FT_VALCONT * _nTXCOFINS)/100,2)
			ELSE
				nALICOFC := _nTXCOFINS
				nBASCOFC := Round((ALIAS_TMP)->FT_VALCONT - (ALIAS_TMP)->FT_ICMSRET - (ALIAS_TMP)->FT_VALIPI,2)
				nVALCOFC := Round((nBASCOFC* _nTXCOFINS)/100,2)
			ENDIF 
		ELSE
			nALICOFC := 0
			nBASCOFC := 0
			nVALCOFC := 0
		ENDIF
    ENDIF

	TRB->XX_ALIPISC := nALIPISC
	TRB->XX_BASPISC := nBASPISC
	TRB->XX_VALPISC := nVALPISC

	IF Transform((ALIAS_TMP)->FT_ALIQPIS,"@E 99,999,999,999.99") <> Transform(nALIPISC,"@E 99,999,999,999.99")
		cERRO += "Aliq. PIS,"
	ENDIF
	IF Transform((ALIAS_TMP)->FT_BASEPIS,"@E 99,999,999,999.99") <> Transform(nBASPISC,"@E 99,999,999,999.99")
		IF ABS(((ALIAS_TMP)->FT_BASEPIS - nBASPISC)) > 0.2
			cERRO += "Base PIS,"
		ENDIF
	ENDIF
	IF Transform((ALIAS_TMP)->FT_VALPIS,"@E 99,999,999,999.99") <> Transform(nVALPISC,"@E 99,999,999,999.99")
		IF ABS(((ALIAS_TMP)->FT_VALPIS - nVALPISC)) > 0.2
			cERRO += "Valor PIS,"
		ENDIF
	ENDIF

	TRB->XX_ALICOFC := nALICOFC
	TRB->XX_BASCOFC := nBASCOFC
	TRB->XX_VALCOFC := nVALCOFC

	IF Transform((ALIAS_TMP)->FT_ALIQCOF,"@E 99,999,999,999.99") <> Transform(nALICOFC,"@E 99,999,999,999.99")
		cERRO += "Aliq. COF,"
	ENDIF
	IF Transform((ALIAS_TMP)->FT_BASECOF,"@E 99,999,999,999.99") <> Transform(nBASCOFC,"@E 99,999,999,999.99")
		IF ABS(((ALIAS_TMP)->FT_BASECOF - nBASCOFC)) > 0.2
			cERRO += "Base COF,"
		ENDIF
	ENDIF
	IF Transform((ALIAS_TMP)->FT_VALCOF,"@E 99,999,999,999.99") <> Transform(nVALCOFC,"@E 99,999,999,999.99")
		IF ABS(((ALIAS_TMP)->FT_VALCOF - nVALCOFC)) > 0.2
			cERRO += "Valor COF,"
		ENDIF
	ENDIF

	TRB->XX_ERROS  := SUBSTR(cERRO,1,LEN(cERRO)-1)
	TRB->XX_STATUS := IIF(!EMPTY(cERRO),"E","")

	TRB->(Msunlock())
	nI := 0
	nI := Ascan (aTotais, {|X| X[1] == "TOTAL" }) 
    IF nI > 0
    	aTotais[nI,2] += (ALIAS_TMP)->FT_BASEPIS
    	aTotais[nI,3] += nBASPISC
    	aTotais[nI,4] +=(ALIAS_TMP)->FT_VALPIS
    	aTotais[nI,5] += nVALPISC
    	
    	aTotais[nI,6] += (ALIAS_TMP)->FT_BASECOF
    	aTotais[nI,7] += nBASCOFC
    	aTotais[nI,8] += (ALIAS_TMP)->FT_VALCOF
    	aTotais[nI,9] += nVALCOFC
    ENDIF

	nI := 0
	nI := Ascan (aTotais, {|X| X[1] == 	(ALIAS_TMP)->FT_CFOP }) 
    IF nI > 0
    	aTotais[nI,2] += (ALIAS_TMP)->FT_BASEPIS
    	aTotais[nI,3] += nBASPISC
    	aTotais[nI,4] +=(ALIAS_TMP)->FT_VALPIS
    	aTotais[nI,5] += nVALPISC
    	
    	aTotais[nI,6] += (ALIAS_TMP)->FT_BASECOF
    	aTotais[nI,7] += nBASCOFC
    	aTotais[nI,8] += (ALIAS_TMP)->FT_VALCOF
    	aTotais[nI,9] += nVALCOFC
    ELSE
    	AADD(aTotais,{(ALIAS_TMP)->FT_CFOP,(ALIAS_TMP)->FT_BASEPIS,nBASPISC,(ALIAS_TMP)->FT_VALPIS, nVALPISC,(ALIAS_TMP)->FT_BASECOF,nBASCOFC,(ALIAS_TMP)->FT_VALCOF,nVALCOFC} )
    ENDIF


 	DbSelectArea(ALIAS_TMP)
	(ALIAS_TMP)->(dbSkip())
ENDDO
(ALIAS_TMP)->(dbCloseArea())


FOR _Xi:= 1 TO LEN(aTotais)
    cERRO := ""
 	nLINHA++
	dbSelectArea("TRB")
	Reclock("TRB",.T.)
	TRB->XX_LINHA   := nLINHA
	 
	IF aTotais[_Xi,1] == "TOTAL"
		TRB->XX_NFISCAL	:= "TOTAL GERAL"
	ELSE
		TRB->XX_NFISCAL	:= "TOTAL CFOP"
		TRB->XX_CFOP 	:= aTotais[_Xi,1]
	ENDIF	

	TRB->XX_BASEPIS	:= aTotais[_Xi,2]
	TRB->XX_BASPISC := aTotais[_Xi,3]
	TRB->XX_VALPIS	:= aTotais[_Xi,4]
	TRB->XX_VALPISC := aTotais[_Xi,5]

	TRB->XX_BASECOF	:= aTotais[_Xi,6]
	TRB->XX_BASCOFC := aTotais[_Xi,7]
	TRB->XX_VALCOF	:= aTotais[_Xi,8]
	TRB->XX_VALCOFC := aTotais[_Xi,9]
	TRB->(Msunlock())

NEXT

TRB->(dbgotop())
  
RETURN NIL



USER Function CORPFIS09()
LOCAL nOPC_ := 0
LOCAL cFile := ""

IF __CUSERID <> '000000'
	MSGSTOP("Usuário  Não  Autorizado")
	Return ""
Endif


cPerg := "PFIS09X"
ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return ""
Endif

nOPC_ := mv_par01

IF nOPC_ == 1
	IF !MsgBox("Esta rotina corrigirá os campos SITTIB,CSTPI,CSTCOFINS,ALIQPIS,ALIQCOF,BASEPIS,BASECOF,VALPIS,VALCOF nas Tabelas do Livro Fiscal. Deseja realmente confinuar?","Atenção","YESNO")
		Return nil
	ENDIF
ELSEIF nOPC_ == 2
	IF !MsgBox("Esta rotina corrigirá o codigo nos campos SITTIB,CSTPI,CSTCOFINS nas Tabelas do Livro Fiscal. Deseja realmente confinuar?","Atenção","YESNO")
		Return nil
	ENDIF
ELSEIF nOPC_ == 3
	IF !MsgBox("Esta rotina corrigirá o calculo nos campos ALIQPIS,ALIQCOF,BASEPIS,BASECOF,VALPIS,VALCOF nas Tabelas do Livro Fiscal. Deseja realmente confinuar?","Atenção","YESNO")
		Return nil
	ENDIF
ELSE
	Return nil
ENDIF


//IF !MsgBox("Esta rotina corrigirá os campos SITTIB,CSTPI,CSTCOFINS,ALIQPIS,ALIQCOF,BASEPIS,BASECOF,VALPIS,VALCOF nas Tabelas do Livro Fiscal. Deseja realmente confinuar?","Atenção","YESNO")
//	Return nil
//ENDIF

//Processa( {|| GCSVPFIS09("TRB","PFIS09",aTitulos,aCampos,aCabs,1)})
cFile := U_CSVPFIS09()

DbSelectArea("TRB")
("TRB")->(dbgotop())
Do While ("TRB")->(!eof())
	IF TRB->XX_STATUS == 'E' 
		dbSelectArea("SFT")
		("SFT")->(dbSetOrder(2)) 
		IF DBSEEK(xFILIAL("SFT")+IIF(nTPMOV=1,"E","S")+DTOS(("TRB")->XX_ENTRADA)+("TRB")->XX_SERIE+("TRB")->XX_NFISCAL+("TRB")->XX_CLIEFOR+("TRB")->XX_LOJA+("TRB")->XX_ITEM+("TRB")->XX_PRODUTO,.T.)
			Reclock("SFT",.F.) 
			IF nOPC_ == 1 .OR. nOPC_ == 2
				SFT->FT_CLASFIS := TRB->XX_CLASF_C
				SFT->FT_CSTPIS  := TRB->XX_CSTP_C
				SFT->FT_CSTCOF  := TRB->XX_CSTC_C
			ENDIF
			IF nOPC_ = 1 .OR. nOPC_ == 3
				SFT->FT_ALIQPIS := TRB->XX_ALIPISC
				SFT->FT_BASEPIS := TRB->XX_BASPISC
				SFT->FT_VALPIS  := TRB->XX_VALPISC
				SFT->FT_ALIQCOF := TRB->XX_ALICOFC
				SFT->FT_BASECOF := TRB->XX_BASCOFC
				SFT->FT_VALCOF  := TRB->XX_VALCOFC
			ENDIF
			IF SFT->FT_TES <> TRB->XX_TES
				SFT->FT_TES := TRB->XX_TES
			ENDIF
			IF SFT->FT_CFOP <> TRB->XX_CFOPIT
				SFT->FT_CFOP := TRB->XX_CFOPIT
			ENDIF
			IF SFT->FT_CODBCC <> TRB->XX_CODBCC
				SFT->FT_CODBCC := TRB->XX_CODBCC
			ENDIF
			SFT->(Msunlock())
			IF nTPMOV  == 1 .AND. (nOPC_ = 1 .OR. nOPC_ == 3)
				dbSelectArea("SF1")
				("SF1")->(dbSetOrder(1))
				IF DBSEEK(xFILIAL("SF1")+SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA+IIF(SFT->FT_TIPO=='','N',SFT->FT_TIPO),.T.)
					Reclock("SF1",.F.)
					SF1->F1_BASIMP6 := (SF1->F1_BASIMP6 - TRB->XX_BASEPIS) + TRB->XX_BASPISC
					SF1->F1_VALIMP6 := (SF1->F1_VALIMP6 - TRB->XX_VALPIS ) + TRB->XX_VALPISC
					SF1->F1_BASIMP5 := (SF1->F1_BASIMP5 - TRB->XX_BASECOF) + TRB->XX_BASCOFC
					SF1->F1_VALIMP5 := (SF1->F1_VALIMP5 - TRB->XX_VALCOF ) + TRB->XX_VALCOFC
					SF1->(Msunlock())
				ENDIF
			ENDIF
			IF nTPMOV  == 2 .AND. (nOPC_ = 1 .OR. nOPC_ == 3)
				dbSelectArea("SF2")
				("SF2")->(dbSetOrder(2))
				IF DBSEEK(xFILIAL("SF2")+SFT->FT_CLIEFOR+SFT->FT_LOJA+SFT->FT_NFISCAL+SFT->FT_SERIE,.T.) 
					Reclock("SF2",.F.)
					SF2->F2_BASIMP6 := (SF2->F2_BASIMP6 - TRB->XX_BASEPIS) + TRB->XX_BASPISC
					SF2->F2_VALIMP6 := (SF2->F2_VALIMP6 - TRB->XX_VALPIS ) + TRB->XX_VALPISC
					SF2->F2_BASIMP5 := (SF2->F2_BASIMP5 - TRB->XX_BASECOF) + TRB->XX_BASCOFC
					SF2->F2_VALIMP5 := (SF2->F2_VALIMP5 - TRB->XX_VALCOF ) + TRB->XX_VALCOFC
					SF2->(Msunlock())
				ENDIF
			ENDIF
    	ENDIF
    	IF nTPMOV  == 1 .AND. (nOPC_ = 1 .OR. nOPC_ == 3)
			dbSelectArea("SD1")
			("SD1")->(dbSetOrder(1))
			IF DBSEEK(("TRB")->XX_FILIAL+("TRB")->XX_NFISCAL+("TRB")->XX_SERIE+("TRB")->XX_CLIEFOR+("TRB")->XX_LOJA+("TRB")->XX_PRODUTO+("TRB")->XX_ITEM,.T.)
				Reclock("SD1",.F.)
				SD1->D1_ALQIMP6 := TRB->XX_ALIPISC
				SD1->D1_BASIMP6 := TRB->XX_BASPISC
				SD1->D1_VALIMP6 := TRB->XX_VALPISC
				SD1->D1_ALQIMP5 := TRB->XX_ALICOFC
				SD1->D1_BASIMP5 := TRB->XX_BASCOFC
				SD1->D1_VALIMP5 := TRB->XX_VALCOFC
				SD1->(Msunlock()) 
	    	ENDIF
    	ENDIF


    	IF  nTPMOV == 2 .AND. (nOPC_ = 1 .OR. nOPC_ == 3)
			dbSelectArea("SD2")
			("SD2")->(dbSetOrder(3))
			IF DBSEEK(("TRB")->XX_FILIAL+("TRB")->XX_NFISCAL+("TRB")->XX_SERIE+("TRB")->XX_CLIEFOR+("TRB")->XX_LOJA+("TRB")->XX_PRODUTO+("TRB")->XX_ITEM,.T.)
				Reclock("SD2",.F.)
				SD2->D2_ALQIMP6 := TRB->XX_ALIPISC
				SD2->D2_BASIMP6 := TRB->XX_BASPISC
				SD2->D2_VALIMP6 := TRB->XX_VALPISC
				SD2->D2_ALQIMP5 := TRB->XX_ALICOFC
				SD2->D2_BASIMP5 := TRB->XX_BASCOFC
				SD2->D2_VALIMP5 := TRB->XX_VALCOFC
				SD2->(Msunlock()) 
	    	ENDIF
    	ENDIF
    	
    ENDIF
 	DbSelectArea("TRB")
	("TRB")->(dbSkip())
ENDDO

//Processa( {|| ProcPFIS09() })

Return cFile


STATIC Function GCSVPFIS09(_cAlias,cArqS,aTitulos,aCampos,aCabs,nOP,cTpQuebra,cQuebra,aQuebra)
Local nHandle
Local cCrLf   := Chr(13) + Chr(10)
Local _ni,_nj
Local cPicN   := "@E 99999999.99999"
Local cDirTmp := IIF(nOP == 1,"C:\TMP","\tmp") 
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
   	         IF SUBSTR(aCampos[_ni],6,8) <> "XX_LINHA"
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
         IF SUBSTR(aCampos[_ni],6,8) <> "XX_LINHA"
          	xCampo := &(aCampos[_ni])
         	_uValor := ""
         	If VALTYPE(xCampo) == "D" // Trata campos data
            	_uValor := dtoc(xCampo)
         	Elseif VALTYPE(xCampo) == "N" // Trata campos numericos
            	_uValor := transform(xCampo,cPicN)
         	Elseif VALTYPE(xCampo) == "C" // Trata campos caracter
             	//_uValor := xCampo+CHR(160)
            	_uValor := '="'+ALLTRIM(xCampo)+'"'
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
		    	IF SUBSTR(aCampos[_ni],6,8) <> "XX_LINHA"
                 	xCampo := &(aQuebra[_nj,1])
            
                 	_uValor := ""
            
                 	If VALTYPE(xCampo) == "D" // Trata campos data
                    	_uValor := dtoc(xCampo)
                 	Elseif VALTYPE(xCampo) == "N" 
                    	_uValor := transform(xCampo,cPicN)
                 	Elseif VALTYPE(xCampo) == "C" //Trata campos caracter
		            	_uValor := '="'+ALLTRIM(xCampo)+'"'
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
   IF nOP == 1   
		MsgInfo("O arquivo "+cArqTmp+" será aberto no MsExcel","PFIS09")
		ShellExecute("open", cArqTmp,"","",1)
   ELSE
		U_SENDMAIL("PFIS09","Backup PIS COFINS","adilson@rkainformatica.com.br;camilaromano@jodola.com.br","","Segue anexo BACKUP PIS COFINS"+DTOC(DATE())+TIME(),cArqTmp,.F.)
   ENDIF
Else
   MsgAlert("Falha na criação do arquivo "+cArqTmp,"PFIS09")
Endif
   
Return




Static Function  ValidPerg(cPerg)
Local aArea      := GetArea()
Local aRegistros := {}

IF ALLTRIM(cPerg) <> "PFIS09X" 
	cPerg := "PFIS09"
ENDIF

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

IF ALLTRIM(cPerg) == "PFIS09X"                    
	AADD(aRegistros,{cPerg,"06","Corrigir ?","Corrigir ?" ,"Corrigir ?" ,"mv_ch1","N",01,0,1,"C","","mv_par01","Tudo","Tudo","Tudo","","","Codigo CST","Codigo CST","Codigo CST","","","Calculos","Calculos","Calculos","","","","","","","","","","","","","S","",""})
ELSE
	AADD(aRegistros,{cPerg,"01","Data Início ?" ,"Data Início ?" ,"Data Início ?" ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
	AADD(aRegistros,{cPerg,"02","Data Fim ?" ,"Data Fim ?" ,"Data Fim ?" ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
	AADD(aRegistros,{cPerg,"03","CFOP ?","CFOP ?"  ,"CFOP ?"  ,"mv_ch3","C",05,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
	AADD(aRegistros,{cPerg,"04","TES ?"    ,"TES ?" ,"TES ?" ,"mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
	AADD(aRegistros,{cPerg,"05","Tipo Movimento ?","Tipo Movimento ?" ,"Tipo Movimento ?" ,"mv_ch5","N",01,0,2,"C","","mv_par05","Entrada","Entrada","Entrada","","","Saida","Saida","Saida","","","","","","","","","","","","","","","","","","S","",""})
	AADD(aRegistros,{cPerg,"06","Produto:","Produto:","Produto:","mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","SB1","S","",""})
	AADD(aRegistros,{cPerg,"07","Fornecedor:","Fornecedor:" ,"Fornecedor:" ,"mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","SA2","S","",""})
ENDIF

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
