#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} BKCTBC01()
BK - Pesquisa Lancamento CT2

** Chamada efetuada atraves do ponto de entrada CT102BUT

@author Marcos B. Abrahão
@since 01/07/2020
@version P12
@return Nil
/*/
            

User Function BKCTBC01()

Private cPerg    := "BKCTBC01"


Private dIni    := dDataBase
Private dFim    := dDataBase
Private cHist   := ""
Private cDeb    := ""
Private cCred   := ""
Private nValor  := 0
Private cOrigem := ""
Private cChave  := ""

ValidPerg(cPerg)
	
IF !Pergunte(cPerg,.T.)
	//RestArea(aAreaIni)
	Return
ENDIF
u_MsgLog(cPerg)

dIni    := mv_par01
dFim    := mv_par02
cHist   := mv_par03
cDeb    := mv_par04
cCred   := mv_par05
nValor  := mv_par06
cOrigem := mv_par07
cChave  := mv_par08

MsAguarde({|| PesqCt2() },"Aguarde","Pesquisando Lançamentos...",.F.)

Return NIL



Static Function PesqCt2()

Local oDlg
Local oPanelLeft
Local aButtons := {}

Local lOk      := .F.

Local aAreaIni := GetArea()
Local cQuery
Local oTmpTb
//Local nValIt  := 0
Local cOrd    := ""
Local j       := 0

Private aSize   := MsAdvSize(,.F.,400)
Private aObjects:= { { 450, 450, .T., .T. } }
Private aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aPosObj := MsObjSize( aInfo, aObjects, .T. )
private aRotina := {{"","",0,1},{"","",0,2},{"","",0,2},{"","",0,2},{"","",0,2}}
Private aHeader	    := {}



cQuery  := "SELECT "
cQuery  += "CT2_DATA,CT2_LOTE,CT2_DOC,CT2_LINHA,CT2_DEBITO,CT2_CREDIT,CT2_VALOR,CT2_HIST,CT2_FILORI,CT2_ORIGEM,CT2_KEY,R_E_C_N_O_ AS CT2REC " 
cQuery  += "FROM "+RETSQLNAME("CT2")+" CT2 "
cQuery  += "WHERE CT2.D_E_L_E_T_ = '' "

IF !EMPTY(dIni)
	cQuery  += "AND CT2_DATA >= '"+DTOS(dIni)+"' "
ENDIF
IF !EMPTY(dFim)
	cQuery  += "AND CT2_DATA <= '"+DTOS(dFim)+"' "
ENDIF
IF !EMPTY(cHist)
	cQuery  += "AND UPPER(CT2_HIST) LIKE '%"+UPPER(ALLTRIM(cHist))+"%' "
ENDIF
IF !EMPTY(cDeb)
	cQuery  += "AND CT2_DEBITO LIKE '%"+ALLTRIM(cDeb)+"%' "
    cOrd    += ",CT2_DEBITO"
ENDIF
IF !EMPTY(cCred)
	cQuery  += "AND CT2_CREDIT LIKE '%"+ALLTRIM(cCred)+"%' "
    cOrd    += ",CT2_CREDIT"
ENDIF
IF nValor > 0
	//nValIt := INT(nValor)
	//cQuery  += "AND CT2_VALOR >= "+ALLTRIM(STR(nValIt - 1))+" AND  CT2_VALOR <= "+ALLTRIM(STR(nValIt + 1))+"  "
	cQuery  += "AND CT2_VALOR = "+ALLTRIM(STR(nValor))+"  "
    //cOrd    += ",CT2_VALOR"
ENDIF
IF !EMPTY(cOrigem)
	cQuery  += "AND CT2_ORIGEM LIKE '%"+ALLTRIM(cOrigem)+"%' "
    cOrd    += ",CT2_ORIGEM"
ENDIF
IF !EMPTY(cChave)
	cQuery  += "AND CT2_KEY LIKE '%"+ALLTRIM(cChave)+"%' "
	cOrd    += ",CT2_KEY"
ENDIF

cQuery  += "ORDER BY CT2_DATA" +cOrd

u_LogMemo("BKCTBC01.SQL",cQuery)


TCQUERY cQuery NEW ALIAS "QCT2"
TCSETFIELD("QCT2","CT2_DATA" ,"D", 8,0)
TCSETFIELD("QCT2","CT2_VALOR","N",16,2)
TCSETFIELD("QCT2","CT2REC"   ,"N",16,0)

DbSelectArea("QCT2")
DbGoTop()
aStruc := dbStruct()
		
oTmpTb := FWTemporaryTable():New( "QCT2T" )	
oTmpTb:SetFields( aStruc )
oTmpTb:Create()

DbSelectArea("QCT2")
dbGoTop()
Do While !eof()
	DbSelectArea("QCT2T")
    RecLock("QCT2T",.T.)
	For j:=1 to QCT2->(FCount())
		FieldPut(j,QCT2->(FieldGet(j)))
	Next
     
	DbSelectArea("QCT2")
	dbSkip()
EndDo

aadd(aHeader, DefAHeader("QCT2T","CT2_DATA"))
aadd(aHeader, DefAHeader("QCT2T","CT2_LOTE"))
aadd(aHeader, DefAHeader("QCT2T","CT2_DOC"))
aadd(aHeader, DefAHeader("QCT2T","CT2_LINHA"))
aadd(aHeader, DefAHeader("QCT2T","CT2_DEBITO"))
aadd(aHeader, DefAHeader("QCT2T","CT2_CREDIT"))
aadd(aHeader, DefAHeader("QCT2T","CT2_VALOR"))
aadd(aHeader, DefAHeader("QCT2T","CT2_HIST"))
aadd(aHeader, DefAHeader("QCT2T","CT2_FILORI"))
aadd(aHeader, DefAHeader("QCT2T","CT2_ORIGEM"))
aadd(aHeader, DefAHeader("QCT2T","CT2_KEY"))

DEFINE MSDIALOG oDlg TITLE "Pesquisa Lançamentos Contábeis" From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE aSize[6],aSize[5]
oPanelLeft:Align := CONTROL_ALIGN_LEFT

_oGetDbSint := MsGetDb():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], 2, "AllwaysTrue()", "AllwaysTrue()",,,,,,"AllwaysTrue()","QCT2T")
_oGetDbSint:oBrowse:BlDblClick := {|| lOk:=.T., oDlg:End()}        


ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T.,oDlg:End()}, {||oDlg:End()},, aButtons)

If ( lOk ) //.AND. nPos > 0
	dbSelectArea("CT2")
	dbSetOrder(1)
	//dbSeek(QSD11->D1_FILIAL+QSD11->D1_DOC+QSD11->D1_SERIE+QSD11->D1_FORNECE+QSD11->D1_LOJA,.T.)
    dbGoTo(QCT2T->CT2REC)
Else
	RestArea(aAreaIni)
Endif
QCT2->(DbCloseArea())
oTmpTb:Delete() 

Return


Static Function DefAHeader(_cAlias,_cCampo)

Return {Alltrim(RetTitle(_cCampo)),;
        _cCampo,;
        GetSx3Cache( _cCampo , "X3_PICTURE" ),;
        GetSx3Cache( _cCampo , "X3_TAMANHO" ),;
        GetSx3Cache( _cCampo , "X3_DECIMAL" ),;
        GetSx3Cache( _cCampo , "X3_VALID" ),;
        "",;
        GetSx3Cache( _cCampo , "X3_TIPO" ),;
        GetSx3Cache( _cCampo , "X3_PICTVAR" ),;
        _cAlias,;
        "R"}

Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Data inicial:"            ,"Data inicial:"  ,"Data inicial:"  ,"mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"02","Data final:"              ,"Data final:"    ,"Data final:"    ,"mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"03","Pesquisar histórico"      ,"Historico"      ,"Historico"      ,"mv_ch3","C",30,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"04","Pesquisar débito"         ,"Débito"         ,"Débito"         ,"mv_ch4","C",20,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","CT1","S","",""})
AADD(aRegistros,{cPerg,"05","Pesquisar crédito"        ,"Crédito"        ,"Crédito"        ,"mv_ch5","C",20,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","CT1","S","",""})
AADD(aRegistros,{cPerg,"06","Pesquisar valor"          ,"Valor"          ,"Valor"          ,"mv_ch6","N",16,2,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"07","Pesquisar origem"         ,"Origem"         ,"Origem"         ,"mv_ch7","C",20,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})
AADD(aRegistros,{cPerg,"08","Pesquisar chave"          ,"Chave"          ,"Chave"          ,"mv_ch8","C",20,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","S","",""})

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
