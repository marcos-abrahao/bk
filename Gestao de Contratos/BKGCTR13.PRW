#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR13
BK - Relatório Repactuação Gestão

@Return
@author Adilson do Prado
@since 09/05/14 Rev 26/05/20
@version P12
/*/

User Function BKGCTR13()
Local aTitulos,aCampos,aCabs,aPlans := {}
Local oTmpTb

Private cPerg       := "BKGCTR13"
Private nomeprog    := ""
Private cTitulo     := "Relatório Repactuação Gestão"
Private cVT_Prod   	:= GetMv("MV_XXVTPRD") //"|31201046|"
Private cVRVA_Prod  := GetMv("MV_XXVRVAP") //"|31201045|31201047|"
Private cContrato  	:= ""
Private cGestorBK 	:= ""
Private dDTRepac  	:= ""
Private nFormato    := 1
Private aMeses		:= {"Janeiro","Fevereiro","Março","Abril","Maio","Junho","Julho","Agosto","Setembro","Outubro","Novembro","Dezembro"}


ValidPerg(cPerg)
If !Pergunte(cPerg,.T.)
	Return Nil
Endif

cContrato  	:= mv_par01
cGestorBK 	:= mv_par02
dDTRepac  	:= mv_par03
nFormato    := mv_par04

aDbf    := {}

AADD( aDbf, { 'XX_NUMERO','C', 09,00 } )
AADD( aDbf, { 'XX_XXDESC','C', 50,00 } )
AADD( aDbf, { 'XX_DTINIC','D', 08,00 } )
AADD( aDbf, { 'XX_XXDVIG','D', 08,00 } )
AADD( aDbf, { 'XX_XXNRBK','C', 50,00 } )
AADD( aDbf, { 'XX_XXFUNC','N', 03,00 } )
AADD( aDbf, { 'XX_CARGO','C', 50,00 } )
AADD( aDbf, { 'XX_FUNATU','N', 14,02 } )
AADD( aDbf, { 'XX_SIND','C', 50,00 } )
AADD( aDbf, { 'XX_DBASE','C', 15,00 } )
AADD( aDbf, { 'XX_FOLHA','N', 14,02 } )
AADD( aDbf, { 'XX_VT','N', 14,02 } )
AADD( aDbf, { 'XX_VRVA','N', 14,02 } )
AADD( aDbf, { 'XX_FATU','N', 14,02 } )
AADD( aDbf, { 'XX_XXDREP','D', 08,00 } )
AADD( aDbf, { 'XX_XXOREP','C', 100,00 } )

///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,'QTMP',.f.,.f. )
oTmpTb := FWTemporaryTable():New("QTMP")
oTmpTb:SetFields( aDbf )
oTmpTb:Create()

aCabs   := {}
aCampos := {}
aTitulos:= {}
nomeprog := ""
   
nomeprog := "BKGCTR13/"+TRIM(SUBSTR(cUsuario,7,15))
AADD(aTitulos,nomeprog+" - "+cTitulo)

AADD(aCampos,"QTMP->XX_NUMERO")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QTMP->XX_XXDESC")
AADD(aCabs  ,"Descrição")

AADD(aCampos,"QTMP->XX_DTINIC")
AADD(aCabs  ,"Dt. Inicio")

AADD(aCampos,"QTMP->XX_XXDVIG")
AADD(aCabs  ,"Vigencia")

AADD(aCampos,"QTMP->XX_XXNRBK")
AADD(aCabs  ,"Nome Gestor "+ALLTRIM(SM0->M0_NOME))

AADD(aCampos,"QTMP->XX_XXFUNC")
AADD(aCabs  ,"Funcionarios Contrato")

AADD(aCampos,"QTMP->XX_CARGO")
AADD(aCabs  ,"Cargo")

AADD(aCampos,"QTMP->XX_FUNATU")
AADD(aCabs  ,"Funcionarios Atual")

AADD(aCampos,"QTMP->XX_SIND")
AADD(aCabs  ,"Sindicato")
                       
AADD(aCampos,"QTMP->XX_DBASE")
AADD(aCabs  ,"Mês Data Base")

AADD(aCampos,"QTMP->XX_FOLHA")
AADD(aCabs  ,"Despesa Folha Bruta")

AADD(aCampos,"QTMP->XX_VT")
AADD(aCabs  ,"Vale Transporte")

AADD(aCampos,"QTMP->XX_VRVA")
AADD(aCabs  ,"Vale Refeição ou Alimentação")

AADD(aCampos,"QTMP->XX_FATU")
AADD(aCabs  ,"Faturamento")

AADD(aCampos,"QTMP->XX_XXDREP")
AADD(aCabs  ,"Data Repactuação")

AADD(aCampos,"QTMP->XX_XXOREP")
AADD(aCabs  ,"Observação Repactuação") 

ProcRegua(1)
Processa( {|| ProcQuery() })
 
If nFormato == 1
	ProcRegua(QTMP->(LASTREC()))
	Processa( {|| U_GeraCSV("QTMP",cPerg,aTitulos,aCampos,aCabs)})
Else	
	AADD(aPlans,{"QTMP",cPerg,"",cTitulo,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .F. })
	U_GeraXlsx(aPlans,cTitulo,cPerg,.F.)
EndIf

oTmpTb:Delete()

Return


Static Function ProcQuery
Local aContrCons:= {}
Local aConsorcio:= {}
Local nScan		:= 0

aContrCons	:= StrTokArr(ALLTRIM(GetMv("MV_XXCONS1"))+ALLTRIM(GetMv("MV_XXCONS2"))+ALLTRIM(GetMv("MV_XXCONS3"))+ALLTRIM(GetMv("MV_XXCONS4")),"/") //"163000240"
FOR IX:= 1 TO LEN(aContrCons)
    AADD(aConsorcio,StrTokArr(aContrCons[IX],";"))
NEXT

cCompet := ""
cCompet := SUBSTR(DTOS(dDataBase),5,2)+"/"+SUBSTR(DTOS(dDataBase),1,4)

cQuery := "SELECT CN9_NUMERO,CN9_REVISA,CN9_XXDESC,CN9_DTINIC,CN9_XXDVIG,CN9_XXNRBK,"+CRLF
cQuery += " CN9_XXFUNC,CN9_XXDREP,CN9_XXOREP,SUM(F2_VALFAT) AS F2_VALFAT" +CRLF
cQuery += " FROM  "+RETSQLNAME("CN9")+" CN9"+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CNF")+" CNF ON CN9_NUMERO = CNF_CONTRA AND CN9_REVISA = CNF_REVISA AND CNF_COMPET = '"+cCompet+"'" +CRLF
cQuery += "      AND  CNF_FILIAL = '"+xFilial("CNF")+"' AND  CNF.D_E_L_E_T_ = ' '"+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CTT")+ " CTT ON CTT_CUSTO = CNF_CONTRA"+CRLF
cQuery += "      AND  CTT_FILIAL = '"+xFilial("CTT")+"' AND  CTT.D_E_L_E_T_ = ' '"+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CNA")+ " CNA ON CNA_CRONOG = CNF_NUMERO AND CNA_CONTRA = CNF_CONTRA AND CNA_REVISA = CNF_REVISA"+CRLF
cQuery += "      AND  CNA_FILIAL = '"+xFilial("CNA")+"' AND  CNA.D_E_L_E_T_ = ' '"+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CND")+ " CND ON CND_CONTRA = CNF_CONTRA AND CND_COMPET = CNF_COMPET AND CNA_NUMERO = CND_NUMERO AND CND_PARCEL = CNF_PARCEL AND CND_REVISA = CNA_REVISA"+CRLF
cQuery += "      AND  CND.D_E_L_E_T_ = ' '"+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SC6")+ " SC6 ON CND_PEDIDO = C6_NUM"+CRLF
cQuery += "      AND  C6_FILIAL = CND_FILIAL AND SC6.D_E_L_E_T_ = ' '"+CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("SF2")+ " SF2 ON C6_SERIE = F2_SERIE AND C6_NOTA = F2_DOC"+CRLF
cQuery += "      AND  F2_FILIAL = CND_FILIAL AND SF2.D_E_L_E_T_ = ' '"+CRLF

cQuery += " WHERE CN9_FILIAL = '"+xFilial("CN9")+"' AND  CN9.D_E_L_E_T_ = ' ' AND CN9_SITUAC='05'"+CRLF

IF !EMPTY(cContrato)
	cQuery += " AND CN9_NUMERO='"+cContrato+"'"+CRLF
ENDIF

IF !EMPTY(cGestorBK)
	cQuery += " AND CN9_XXNRBK LIKE '%"+cGestorBK+"%'"+CRLF
ENDIF

IF !EMPTY(dDTRepac)
	cQuery += " AND CN9_XXDREP='"+DTOS(dDTRepac)+"'"+CRLF
ENDIF

cQuery += " GROUP BY CN9_NUMERO,CN9_REVISA,CN9_XXDESC,CN9_DTINIC,CN9_XXDVIG,CN9_XXNRBK, CN9_XXFUNC,CN9_XXDREP,CN9_XXOREP"+CRLF

u_LogMemo("BKGCTR13.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QCN9"
TCSETFIELD("QCN9","CN9_DTINIC","D",8,0)
TCSETFIELD("QCN9","CN9_XXDVIG","D",8,0)
TCSETFIELD("QCN9","CN9_XXDREP","D",8,0) 

cXX_XXDESC	:= ""
dXX_DTINIC	:= CTOD("")
dXX_XXDVIG	:= CTOD("")
cXX_XXNRBK	:= ""
nXX_XXFUNC	:= 0
cXX_CARGO  	:= ""
nXX_FUNATU 	:= 0
cXX_SIND 	:= ""
cXX_DBASE 	:= ""
nXX_FOLHA 	:= 0
nXX_VT 		:= 0
nXX_VRVA	:= 0
nXX_FATU 	:= 0
dXX_XXDREP	:= CTOD("")
cXX_XXOREP	:= ""



dbSelectArea("QCN9")
QCN9->(dbGoTop())  
ProcRegua(QCN9->(LastRec())) 
DO WHILE QCN9->(!EOF())

	IncProc("Consultando o banco de dados...")

	cXX_XXDESC	:= QCN9->CN9_XXDESC
	dXX_DTINIC	:= QCN9->CN9_DTINIC
	dXX_XXDVIG	:= u_VigContrat(QCN9->CN9_NUMERO+QCN9->CN9_REVISA,QCN9->CN9_XXDVIG)
	cXX_XXNRBK	:= QCN9->CN9_XXNRBK
	nXX_XXFUNC	:= QCN9->CN9_XXFUNC
	nXX_FATU 	:= QCN9->F2_VALFAT
	dXX_XXDREP	:= QCN9->CN9_XXDREP
	cXX_XXOREP	:= QCN9->CN9_XXOREP

		//*********GASTOS VT VR/VA
		cQuery2 := "SELECT DISTINCT D1_FILIAL,D1_COD,B1_DESC,B1_GRUPO,D1_CC,SUM(D1_TOTAL+D1_VALFRE+D1_SEGURO+D1_DESPESA-D1_VALDESC) AS D1_TOTAL"
		cQuery2 += " FROM "+RETSQLNAME("SD1")+" SD1" 
		
		cQuery2 += " INNER JOIN "+RETSQLNAME("SB1")+" SB1"
		 
		cQuery2 += " ON D1_COD = B1_COD  AND SB1.D_E_L_E_T_ = ' ' "                                          
		
		cQuery2 += " WHERE SUBSTRING(D1_DTDIGIT,1,6) = '"+SUBSTR(cCompet,4,4)+SUBSTR(cCompet,1,2)+"' AND SD1.D_E_L_E_T_ = ' ' "
		
		cQuery2 += " AND D1_CC = '"+ALLTRIM(QCN9->CN9_NUMERO)+"'" 
		
		cPRODUT := cVT_Prod+SUBSTR(cVRVA_Prod,2,LEN(cVRVA_Prod)) 
		cPRODUT := STRTRAN(cPRODUT,"|","','") 
		cQuery2 += " AND D1_COD IN ("+SUBSTR(cPRODUT,3,LEN(cPRODUT)-4) +")" 
		cQuery2 += " GROUP BY  D1_FILIAL,D1_COD,B1_DESC,B1_GRUPO,D1_CC"
 
 		TCQUERY cQuery2 NEW ALIAS "TMPX2"

		dbSelectArea("TMPX2")
		dbGoTop()
		DO While !TMPX2->(EOF())

			IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cVT_Prod
				nXX_VT += TMPX2->D1_TOTAL
			ENDIF

			IF "|"+ALLTRIM(TMPX2->D1_COD)+"|"  $ cVRVA_Prod
				nXX_VRVA += TMPX2->D1_TOTAL
			ENDIF

			TMPX2->(dbSkip())
		ENDDO
		TMPX2->(dbCloseArea())


	cQuery := "	SELECT COUNT(FUN.numcad) AS TOTFUNC,CAR.TitCar,SND.NomSin,SND.MesDis,sum(FUN.valsal) AS FOLHA "
	cQuery += " FROM bk_senior.bk_senior.r034fun FUN "
	cQuery += " LEFT JOIN bk_senior.bk_senior.R038HSI HSI ON FUN.NumEmp=HSI.NumEmp AND FUN.numcad =HSI.NumCad "
	cQuery += "  AND  FUN.tipcol =HSI.TipCol "
	cQuery += "  AND HSI.DatAlt=(SELECT  TOP 1 DatAlt "
	cQuery += "         FROM    bk_senior.bk_senior.R038HSI HSI2"
	cQuery += "         WHERE   FUN.NumEmp=HSI2.NumEmp AND FUN.numcad =HSI2.NumCad"
	cQuery += "  AND  FUN.tipcol =HSI2.TipCol ORDER BY DatAlt DESC) "
	cQuery += " LEFT JOIN bk_senior.bk_senior.R014SIN SND ON HSI.CodSin=SND.CodSin "
	cQuery += " LEFT JOIN bk_senior.bk_senior.R024CAR CAR ON FUN.codcar=CAR.codcar AND FUN.estcar=CAR.estcar "
	cQuery += "  where FUN.sitafa in (1,2,3,4,6,8,9)"

	nScan:= 0
	nScan:= aScan(aConsorcio,{|x| x[1]==alltrim(QCN9->CN9_NUMERO) })

	IF nScan > 0 
 		cQuery += " AND FUN.numemp='"+SUBSTR(ALLTRIM(aConsorcio[nScan,2]),1,2)+"'"
		cQuery += " AND ( BKIntegraRubi.dbo.fnCCSiga(FUN.numemp,FUN.tipcol,FUN.numcad,'CLT') ='"+ALLTRIM(aConsorcio[nScan,3])+"' COLLATE SQL_Latin1_General_CP1_CI_AS"
		cQuery += " OR  BKIntegraRubi.dbo.fnCCSiga(FUN.numemp,FUN.tipcol,FUN.numcad,'CLT') ='"+ALLTRIM(aConsorcio[nScan,4])+"' COLLATE SQL_Latin1_General_CP1_CI_AS"
		cQuery += " OR  BKIntegraRubi.dbo.fnCCSiga(FUN.numemp,FUN.tipcol,FUN.numcad,'CLT') ='"+ALLTRIM(aConsorcio[nScan,7])+"' COLLATE SQL_Latin1_General_CP1_CI_AS ) "

	ELSE
 		cQuery += " AND FUN.numemp='"+SM0->M0_CODIGO+"'"
		cQuery += " AND BKIntegraRubi.dbo.fnCCSiga(FUN.numemp,FUN.tipcol,FUN.numcad,'CLT') ='"+QCN9->CN9_NUMERO+"' COLLATE SQL_Latin1_General_CP1_CI_AS"
	ENDIF
	cQuery += " group by CAR.TitCar,SND.NomSin,SND.MesDis "
	    
	TCQUERY cQuery NEW ALIAS "QRBFUN"

	dbSelectArea("QRBFUN")
	QRBFUN->(dbGoTop())
	DO WHILE QRBFUN->(!EOF())

		dbSelectArea("QTMP")
		Reclock("QTMP",.T.)
		QTMP->XX_NUMERO	:= QCN9->CN9_NUMERO
		QTMP->XX_XXDESC	:= cXX_XXDESC
		QTMP->XX_DTINIC	:= dXX_DTINIC
		QTMP->XX_XXDVIG	:= dXX_XXDVIG
		QTMP->XX_XXNRBK	:= cXX_XXNRBK
		QTMP->XX_XXFUNC	:= nXX_XXFUNC

			

		QTMP->XX_CARGO  := QRBFUN->TitCar
		QTMP->XX_FUNATU := QRBFUN->TOTFUNC
		QTMP->XX_SIND 	:= QRBFUN->NomSin
		QTMP->XX_DBASE 	:= IIF(QRBFUN->MesDis>0,aMeses[QRBFUN->MesDis],"")
		QTMP->XX_FOLHA 	:= QRBFUN->FOLHA
		

		QTMP->XX_VT     := nXX_VT
		QTMP->XX_VRVA   := nXX_VRVA
		QTMP->XX_FATU 	:= nXX_FATU 
		QTMP->XX_XXDREP	:= dXX_XXDREP
		QTMP->XX_XXOREP	:= cXX_XXOREP
		QTMP->(Msunlock())

		cXX_NUMERO	:= ""
		cXX_XXDESC	:= ""
		dXX_DTINIC	:= CTOD("")
		dXX_XXDVIG	:= CTOD("")
		cXX_XXNRBK	:= ""
		nXX_XXFUNC	:= 0
		cXX_CARGO  	:= ""
		nXX_FUNATU 	:= 0
		cXX_SIND 	:= ""
		cXX_DBASE 	:= ""
		nXX_FOLHA 	:= 0
		nXX_VT 		:= 0
		nXX_VRVA	:= 0
		nXX_FATU 	:= 0
		dXX_XXDREP	:= CTOD("")
		cXX_XXOREP	:= ""
		QRBFUN->(dbSkip())
	ENDDO
	QRBFUN->(dbCloseArea())



	QCN9->(dbSkip())
ENDDO
QCN9->(dbCloseArea())

Return



 

Static Function  ValidPerg(cPerg)

Local aArea      := GetArea()
Local aRegistros := {}

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10)

AADD(aRegistros,{cPerg,"01","Contrato:"       ,"Contrato:"        ,"Contrato:"        ,"mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","CTT","S","","Branco para Todos Contratos Ativos"})
AADD(aRegistros,{cPerg,"02","Gestor BK"       ,"Gestor BK"        ,"Gestor BK"        ,"mv_ch2","C",50,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","S","","Branco para Todos"})
AADD(aRegistros,{cPerg,"03","Data Repactuação","Data Repactuação" ,"Data Repactuação" ,"mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","S","","Branco para Todos"})
AADD(aRegistros,{cPerg,"04","Gerar Planilha"  ,"Gerar Planilha"   ,"Gerar Planilha"   ,"mv_ch4","N",01,0,2,"C","","mv_par04","CSV","CSV","CSV","","","XLSX","XLSX","XLSX","","","","","","","","","","","","","","","","",""})

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


