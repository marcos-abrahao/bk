#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR12
BK - Objetos dos Contratos
@Return
@author Adilson do Prado 
@since 14/11/13 Rev 26/05/20
@version P12
/*/

User Function BKGCTR12()
Local aTitulos,aCampos,aCabs,aPlans

Private nomeprog     := ""
Private cTitulo      := "Objetos dos Contratos"
Private cPerg        := "BKGCTR12"
Private cCompet      := STRZERO(Month(dDataBase),2)+"/"+STRZERO(YEAR(dDataBase),4)

ProcRegua(1)
Processa( {|| ProcQuery() })

aCabs   := {}
aCampos := {}
aTitulos:= {}
aPlans  := {}
nomeprog := ""
   
nomeprog := "BKGCTR12/"+TRIM(SUBSTR(cUsuario,7,15))
AADD(aTitulos,nomeprog+" - "+cTitulo)

AADD(aCampos,"QCN9->CN9_NOMCLI")
AADD(aCabs  ,"Cliente")

AADD(aCampos,"QCN9->CN9_NUMERO")
AADD(aCabs  ,"Contrato")

AADD(aCampos,"QCN9->CN9_XXDESC")
AADD(aCabs  ,"Descrição")

AADD(aCampos,"QCN9->CN9_DTINIC")
AADD(aCabs  ,"Dt. Inicio")

AADD(aCampos,"u_VigContrat(QCN9->CN9_NUMERO+QCN9->CN9_REVISA,QCN9->CN9_XXDVIG)")
AADD(aCabs  ,"Vigencia")

AADD(aCampos,"QCN9->CN9_XXNRBK")
AADD(aCabs  ,"Nome Gestor "+ALLTRIM(SM0->M0_NOME))

AADD(aCampos,"QCN9->CN9_XXNGC")
AADD(aCabs  ,"Nome Gestor")

AADD(aCampos,"QCN9->CN9_XXEGC")
AADD(aCabs  ,"E-mail Gestor")

AADD(aCampos,"QCN9->CN9_XXTELS")
AADD(aCabs  ,"Tel Gestor")

AADD(aCampos,"U_CN9OBJ(QCN9->CN9_CODOBJ)")
AADD(aCabs  ,"Objeto")

AADD(aCampos,"QCN9->CND_XXPOST")
AADD(aCabs  ,"Qtd. Postos Contrato")

AADD(aCampos,"QCN9->CND_XXFUNC")
AADD(aCabs  ,"Qtd. Funcionarios Contrato")

AADD(aCampos,"QCN9->CND_XXNFUN")
AADD(aCabs  ,"Qtd. Func. Atual Competência: "+ cCompet)

AADD(aCampos,"STRTRAN(ALLTRIM(QCN9->CND_XXJFUN),';',',')")
AADD(aCabs  ,"Just. Num. Funcionários")

//ProcRegua(QCN9->(LASTREC()))
//Processa( {|| U_GeraCSV("QCN9",cPerg,aTitulos,aCampos,aCabs)})

AADD(aPlans,{"QCN9",cPerg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })
U_GeraXlsx(aPlans,cTitulo,cPerg,.T.)
 

Return


Static Function ProcQuery
Local cQuery

IncProc("Consultando o banco de dados...")

cQuery := "SELECT DISTINCT CN9_NOMCLI,CN9_NUMERO,CN9_REVISA,CN9_XXDESC,CN9_DTINIC,CN9_XXDVIG,CN9_XXNRBK," + CRLF
cQuery += "CN9_XXNGC,CN9_XXEGC,CN9_XXTELS,CN9_CODOBJ," + CRLF
cQuery += " CONVERT(VARCHAR(8000),CONVERT(Binary(8000),CND_XXJFUN)) CND_XXJFUN, " + CRLF
cQuery += "	CND_XXDTAC,CND_XXPOST,CND_XXFUNC,CND_XXNFUN " + CRLF
cQuery += " FROM "+RETSQLNAME("CN9")+ " CN9 " + CRLF
cQuery += " LEFT JOIN "+RETSQLNAME("CND")+" CND ON " + CRLF
cQuery += " CND_CONTRA = CN9_NUMERO" + CRLF
cQuery += " AND CND_REVISA = CN9_REVISA AND CND_COMPET = '"+cCompet+"' " + CRLF
cQuery += " AND CND.D_E_L_E_T_ = ' '" + CRLF
cQuery += " WHERE CN9.D_E_L_E_T_='' AND CN9_SITUAC = '05'" + CRLF

u_LogMemo("BKGCTR12.SQL",cQuery)

TCQUERY cQuery NEW ALIAS "QCN9"
TCSETFIELD("QCN9","CN9_DTINIC","D",8,0)
TCSETFIELD("QCN9","CN9_XXDVIG","D",8,0)

/*CN9_NUMERO IN ('011000182',"
cQuery += "'012000174','012000209','083000227','092000230','094000255','130000242','148000222','170000253',"
cQuery += "'032000121','032000155','032000210','138000208','171000254','006000236','026000175','088000145',"
cQuery += "'104000212','104000220','104000229','049000130','049000171','049000223','065000269','079000131',"
cQuery += "'137000260','008126034','008129034','008132034','008134034','008145034','008146034','008147034',"
cQuery += "'008150034','008154034','008157034','008159034','008162034','008164034','008165034','008166034',"
cQuery += "'008167034','008168034','008169034','008170034','008171034','008172034','008173034','008174034',"
cQuery += "'008175034','008176034','008177034','008178034','008179034','008180034','008181034','008182034',"
cQuery += "'008183034','008185034','008186034','008187034','008188034','008189034','008190034','008191034',"
cQuery += "'008192034','008193034','008194034','142000211','142000246','142000261','018000249','033000276',"
cQuery += "'064000214','077000173','155000235','157000247','167000250','170000252','178000265','178000266',"
cQuery += "'181000247','182000247','007000019','005000114','071000128','071000188','071000233','071000241',"
cQuery += "'071000256','071000259','132000204','160000239','018000001','044000024','044000127','075000117',"
cQuery += "'080000219','083000149','126000196','128000189','161000244','018000228','044000271','018000232',"
cQuery += "'044000185','044000272','089000148','129000201','164000245','177000264','179000270','186000274',"
cQuery += "'179000275','063000096','071000205','087000105','137000206','163000240','015000181','068000262',"
cQuery += "'068000262','068000262','068000262','076000166','076000268','076000273')"
cQuery += " ORDER BY CN9_NUMERO"
*/

Return 

// BKGCTR12/BKGCTR13/BKGCTR25
User Function VigContrat(cContrato,dDVIG)
Local cContRev := ""
Local dXDVig   := dDVIG

// Buscar o ultimo vencto dos Cronogramas
dbSelectArea("CNF")
dbSetOrder(3)
cContRev := xFilial("CNF")+cContrato
dbSeek(cContRev,.T.)
Do While !EOF() .AND. cContRev == CNF_FILIAL+CNF_CONTRA+CNF_REVISA
	IF dDVIG < CNF->CNF_DTVENC
		dDVIG := CNF->CNF_DTVENC
	ENDIF
	CNF->(dbSkip())
EndDo
If Empty(dDVIG)
	dDVIG := dXDVig
EndIf
Return dDVIG
