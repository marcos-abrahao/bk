#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
                                        
/*/{Protheus.doc} BKGCTR24
BK - Consulta Planos de Ação
@Return
@author Marcos Bispo Abrahão
@since 30/08/18
@version P12
/*/

User Function BKGCTR24()

PRIVATE cTitulo   := "Consulta Planos de Ação"
PRIVATE cTitulo1  := ""
PRIVATE aStruct   := {}
PRIVATE oTmpTb

PRIVATE cPerg     := "BKGCTR24"
PRIVATE dIni      := dDataBase
PRIVATE dFim      := dDataBase
PRIVATE cGestor   := ""
PRIVATE cContrato := ""
                       
PRIVATE aHeader	  := {}
PRIVATE aCabs     := {}
PRIVATE aCampos   := {}
PRIVATE aTitulos  := {}
PRIVATE aTbCpos   := {}
PRIVATE cMarca    := GetMark()

PRIVATE cAliasTmp := GetNextAlias()
PRIVATE cAliasTrb := "TRB"
PRIVATE aStatus   := {}

AADD(aStatus,"Respondido")
AADD(aStatus,"Fora do prazo")
AADD(aStatus,"No prazo")
AADD(aStatus,"Finalizado")

AADD(aStruct ,{'XX_MARCA','C', 02,00 } )
aAdd(aTbCpos,{"XX_MARCA",,"St"         ,""} )

AADD(aStruct ,{'XX_NUMERO',	'C', TamSX3("ZP_NUMERO")[1],00 } )
AADD(aCampos,cAliasTrb+"->XX_NUMERO")
AADD(aCabs  ,"Nº")
AADD(aHeader,{"Nº","XX_NUMERO" ,"@!",TamSX3("ZP_NUMERO")[1],00,"","","C",cAliasTrb,"R"})
aAdd(aTbCpos,{"XX_NUMERO",,"Nº" ,""} )

AADD(aStruct ,{'XX_STATUS',	'C', 15,00 } )
AADD(aCampos,cAliasTrb+"->XX_STATUS")
AADD(aCabs  ,"Status")

AADD(aStruct ,{'XX_DATAPRV',	'D', 8,00 } )
AADD(aCampos,cAliasTrb+"->XX_DATAPRV")
AADD(aCabs  ,"Prazo")

AADD(aStruct ,{'XX_FINALIZ',	'C', TamSX3("ZP_FINALIZ")[1],00 } )
AADD(aCampos,cAliasTrb+"->XX_FINALIZ")
AADD(aCabs  ,"Finalizado")

AADD(aStruct ,{'XX_RESPOND',	'C', 1,00 } )
AADD(aCampos,cAliasTrb+"->XX_RESPOND")
AADD(aCabs  ,"Respondido")

AADD(aStruct ,{'XX_EFICIEN',	'C', TamSX3("ZP_EFICIEN")[1],00 } )
AADD(aCampos,cAliasTrb+"->XX_EFICIEN")
AADD(aCabs  ,"Eficiência")

AADD(aStruct ,{'XX_CONTRAT',	'C', TamSX3("ZP_CONTRAT")[1],00 } )
AADD(aCampos,cAliasTrb+"->XX_CONTRAT")
AADD(aCabs  ,"Contrato")
AADD(aHeader,{"Contrato","XX_CONTRAT" ,"@!",TamSX3("ZP_CONTRAT")[1],00,"","","C",cAliasTrb,"R"})
aAdd(aTbCpos,{"XX_CONTRAT",,"Contrato" ,""} )

AADD(aStruct ,{'XX_SEQ',	'C', TamSX3("ZP_SEQ")[1],00 } )
AADD(aCampos,cAliasTrb+"->XX_SEQ")
AADD(aCabs  ,"Seq")
AADD(aHeader,{"Seq","XX_SEQ" ,"@!",TamSX3("ZP_SEQ")[1],00,"","","C",cAliasTrb,"R"})
aAdd(aTbCpos,{"XX_SEQ",,"Seq." ,""} )

AADD(aStruct,{'XX_NOMCLI',	'C', TamSX3("CN9_NOMCLI")[1],00 } )
AADD(aCampos,cAliasTrb+"->XX_NOMCLI")
AADD(aCabs  ,"Cliente")
AADD(aHeader,{"Cliente","XX_NOMCLI" ,"@!",TamSX3("CN9_NOMCLI")[1],00,"","","C",cAliasTrb,"R"})
aAdd(aTbCpos,{"XX_NOMCLI",,"CLiente" ,""} )


AADD(aStruct,{'XX_GESTOR',	'C', TamSX3("CN9_XXNGC")[1],00 } )
AADD(aCampos,cAliasTrb+"->XX_GESTOR")
AADD(aCabs  ,"Gestor")
AADD(aHeader,{"Gestor","XX_GESTOR" ,"@!",TamSX3("CN9_XXNGC")[1],00,"","","C",cAliasTrb,"R"})
aAdd(aTbCpos,{"XX_GESTOR",,"Gestor" ,""} )

AADD(aStruct,{'XX_OCORR',	'C', TamSX3("ZP_OCORR")[1],00 } )
AADD(aCampos,cAliasTrb+"->XX_OCORR")
AADD(aCabs  ,"Ocorrencia")
AADD(aHeader,{"Ocorrência","XX_OCORR" ,"@!",TamSX3("ZP_OCORR")[1],00,"","","C",cAliasTrb,"R"})
aAdd(aTbCpos,{"XX_OCORR",,"Ocorrência" ,""} )

///cArqTmp := CriaTrab( aStruct, .t. )
///dbUseArea( .t.,NIL,cArqTmp,cAliasTrb,.f.,.f. )

oTmpTb := FWTemporaryTable():New(cAliasTrb)
oTmpTb:SetFields( aStruct )
oTmpTb:Create()


AADD(aTitulos,cPerg+"/"+TRIM(SUBSTR(cUsuario,7,15)+" - "+cTitulo))

If U_PrcBKR24()
	Processa ( {|| MBrwBKR24()})
EndIf
	
oTmpTb:Delete()
///(cAliasTrb)->(Dbclosearea())
///FErase(cArqTmp+GetDBExtension())
///FErase(cArqTmp+OrdBagExt())                     
 
Return


User Function PrcBKR24()

ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return .F.
Endif

dIni      := mv_par01
dFim      := mv_par02
cGestor   := mv_par03
cContrato := mv_par04 

IF dFim < dIni
	MSGSTOP("Data final deve ser maior ou igual a inicial")                
	Return .F.
ENDIF


cTitulo1  := cTitulo + " - Período:"+DTOC(dIni)+" até "+DTOC(dFim)

ProcRegua(1000)

Processa( {|| ProcQuery() })

Return .T.




Static Function MBrwBKR24()
Local 	aCores 		:= {}

Private cCadastro	:= "Planos de Ação"
Private aRotina		:= {}
Private aIndexSz  	:= {}

Private aSize   := MsAdvSize(,.F.,400)
Private aObjects:= { { 450, 450, .T., .T. } }
Private aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Private aPosObj := MsObjSize( aInfo, aObjects, .T. )
Private aPos
Private lRefresh:= .T.
Private aButton := {}
Private oMarkSZP

Private _oGetDbSint
Private _oDlgSint

AADD(aCores ,{"TRIM(XX_STATUS) == '"+aStatus[1]+"'","BR_VERDE" })
AADD(aCores ,{"TRIM(XX_STATUS) == '"+aStatus[2]+"'","BR_VERMELHO" })
AADD(aCores ,{"TRIM(XX_STATUS) == '"+aStatus[3]+"'","BR_AMARELO" })
AADD(aCores ,{"TRIM(XX_STATUS) == '"+aStatus[4]+"'","BR_PRETO" })

AADD(aRotina,{"Exp. Excel"	,"U_XmlBKGR24",0,6})
AADD(aRotina,{"Parametros"	,"U_PrcBKGR24",0,7})
AADD(aRotina,{"Legenda"		,"U_LegBKGR24",0,8})


dbSelectArea(cAliasTrb)
//dbSetOrder(1)
	
DEFINE MSDIALOG _oDlgSint ;
TITLE cCadastro ;
From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
//_oGetDbSint := MsGetDb():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4], 2, "AllwaysTrue()", "AllwaysTrue()",,,,,,"AllwaysTrue()",cAliasTrb)

aPos     := {aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]}
oMarkSZP := MsSelect():New(cAliasTrb,"XX_MARCA", ,aTbCpos,.F.,@cMarca,aPos,,,,,aCores)


aadd(aButton , { "BMPTABLE" , { || U_XmlBKR24(), (cAliasTrb)->(dbgotop()), _oDlgSint:Refresh()}, "Gera Excel" } )
aadd(aButton , { "BMPTABLE" , { || U_PrcBKR24(), (cAliasTrb)->(dbgotop()), _oDlgSint:Refresh()}, "Parametros" } )
aadd(aButton , { "BMPTABLE" , { || U_LegBKR24()}, "Legenda" } )

	
ACTIVATE MSDIALOG _oDlgSint ON INIT EnchoiceBar(_oDlgSint,{|| _oDlgSint:End()}, {||_oDlgSint:End()},, aButton)

Return Nil



User Function LegBKR24()
Local aLegenda := {}

AADD(aLegenda,{"BR_VERDE"   ,aStatus[1] })
AADD(aLegenda,{"BR_VERMELHO",aStatus[2] })
AADD(aLegenda,{"BR_AMARELO" ,aStatus[3] })
AADD(aLegenda,{"BR_PRETO"   ,aStatus[4] })

BrwLegenda(cCadastro, "Legenda", aLegenda)
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
EndDo

Return (.T.)



User Function XmlBKR24()
Local aPlans := {}

dbSelectArea(cAliasTrb)

AADD(aPlans,{cAliasTrb,cPerg,"",cTitulo1,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
U_GeraXml(aPlans,cTitulo1,cPerg,.F.)

Return Nil

   

Static Function ProcQuery()
Local cQuery
//Local cEfic := " "

LimpaBrw (cAliasTrb)
//LimpaBrw (cAliasTmp)

IncProc("Consultando o banco de dados...")

dbSelectArea("SZQ")
dbSetOrder(1)

cQuery := " SELECT ZP_NUMERO,ZP_CONTRAT,ZP_SEQ,ZP_OCORR,ZP_DATAPRV,ZP_FINALIZ,ZP_EFICIEN, "
cQuery += " (SELECT TOP 1 CN9_XXNGC FROM "+RETSQLNAME("CN9")+" CN9 "
cQuery += "      WHERE CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''" 
cQuery += "            AND CN9_NUMERO = ZP_CONTRAT AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09') AS CN9_XXNGC, "

cQuery += " (SELECT TOP 1 CN9_NOMCLI FROM "+RETSQLNAME("CN9")+" CN9 "
cQuery += "      WHERE CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ''" 
cQuery += "            AND CN9_NUMERO = ZP_CONTRAT AND CN9_SITUAC <> '10' AND CN9_SITUAC <> '09') AS CN9_NOMCLI "

cQuery += " FROM "+RETSQLNAME("SZP")+" SZP"
cQuery += " WHERE ZP_FILIAL = '"+xFilial("SZP")+"' AND  SZP.D_E_L_E_T_ = ''" 
If !EMPTY(dIni)
	cQuery += " AND ZP_DATA >= '"+DTOS(dIni)+"'"
EndIf
If !EMPTY(dFim)
	cQuery += " AND ZP_DATA <= '"+DTOS(dFim)+"'"
EndIf
If !EMPTY(cContrato)
	cQuery += " AND ZP_CONTRAT = '"+TRIM(cContrato)+"'"
EndIf

TCQUERY cQuery NEW ALIAS (cAliasTmp)
TCSETFIELD(cAliasTmp,"ZP_DATAPRV","D",8,0)

dbSelectArea(cAliasTmp)
(cAliasTmp)->(dbGoTop())
DO WHILE (cAliasTmp)->(!EOF())

	If !EMPTY(cGestor)
		If ALLTRIM(UPPER(cGestor)) <> ALLTRIM(UPPER((cAliasTmp)->CN9_XXNGC))
		   	dbSelectArea(cAliasTmp)
		   	(cAliasTmp)->(dbSkip())
		EndIf
	EndIf


	IncProc("Criando arquivo temporario...")
	//cEfic := " "
	dbSelectArea(cAliasTrb)
	Reclock(cAliasTrb,.T.)
	(cAliasTrb)->XX_NUMERO  := (cAliasTmp)->ZP_NUMERO
	(cAliasTrb)->XX_CONTRAT := (cAliasTmp)->ZP_CONTRAT
	(cAliasTrb)->XX_SEQ     := (cAliasTmp)->ZP_SEQ
	(cAliasTrb)->XX_OCORR   := (cAliasTmp)->ZP_OCORR
	(cAliasTrb)->XX_NOMCLI  := (cAliasTmp)->CN9_NOMCLI
	(cAliasTrb)->XX_GESTOR  := (cAliasTmp)->CN9_XXNGC
	(cAliasTrb)->XX_DATAPRV := (cAliasTmp)->ZP_DATAPRV
	(cAliasTrb)->XX_FINALIZ := (cAliasTmp)->ZP_FINALIZ
	(cAliasTrb)->XX_EFICIEN := (cAliasTmp)->ZP_EFICIEN
	
	If SZQ->(dbSeek(xFilial("SZQ")+(cAliasTmp)->ZP_CONTRAT+(cAliasTmp)->ZP_SEQ,.F.))
	    //cEfic := "S"
		//Do While SZQ->(!EOF()) .AND. (cAliasTmp)->ZP_CONTRAT+(cAliasTmp)->ZP_SEQ == SZQ->ZQ_CONTRAT+SZQ->ZQ_SEQ
		//	If SZQ->ZQ_QUANDO > (cAliasTmp)->ZP_DATAPRV
		//		cEfic := "N"
		//	EndIf
		//	SZQ->(dbSkip())
		//EndDo
		(cAliasTrb)->XX_RESPOND  := "S"
		(cAliasTrb)->XX_STATUS   := aStatus[1]
	Else
		(cAliasTrb)->XX_RESPOND  := "N"
		(cAliasTrb)->XX_STATUS   := aStatus[3]
	EndIf

	If (cAliasTmp)->ZP_DATAPRV < dDataBase
		(cAliasTrb)->XX_STATUS   := aStatus[2]
	EndIf
	
	If (cAliasTmp)->ZP_FINALIZ == "S"
		(cAliasTrb)->XX_STATUS   := aStatus[4]
	EndIf
	//(cAliasTrb)->XX_EFIC := cEfic
	
	(cAliasTrb)->(Msunlock())
	
	
   	dbSelectArea(cAliasTmp)
   	(cAliasTmp)->(dbSkip())
ENDDO

(cAliasTmp)->(dbCloseArea())

dbSelectArea(cAliasTrb)
(cAliasTrb)->(dbgotop())

Return



Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Período de :"        ,"" ,"" ,"mv_ch1","D",08                     ,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"S","",""})
AADD(aRegistros,{cPerg,"02","Período até:"        ,"" ,"" ,"mv_ch2","D",08                     ,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"S","",""})
AADD(aRegistros,{cPerg,"03","Contrato:"           ,"" ,"" ,"mv_ch3","C",TamSX3("ZP_CONTRAT")[1],0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","",""})
AADD(aRegistros,{cPerg,"04","Gestor:"             ,"" ,"" ,"mv_ch4","C",TamSX3("CN9_XXNGC")[1] ,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""   ,"S","",""})

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
