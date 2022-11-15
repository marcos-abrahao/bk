#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} BKGCTR15()
BK - Informações de Contratos para Licitação

@author Adilson do Prado
@since 02/12/14 Rev 26/05/20
@version P12
@return Nil
/*/

User Function BKGCTR15()
Local aTitulos,aCampos,aCabs,aPlans
Local aDbf 		    := {} 
Local oTmpTb1

Private aParam		:=	{}
Private aRet		:=	{}

Private cTitulo     := "Relatório de Informações dos Contratos para Licitações - Competência: "+STRZERO(Month(dDataBase),2)+"/"+STRZERO(YEAR(dDataBase),4) 
Private cCompet     := STRZERO(YEAR(dDataBase),4)+STRZERO(Month(dDataBase),2) 
Private cPerg    	:= "BKGCTR15"
Private cComSaldo	:= "Sim"

aAdd( aParam ,{ 2, "Somente contratos com saldo", cComSaldo  ,{"Sim", "Não"}	, 60,'.T.'  ,.T.})

If !BkGC15()
   Return
EndIf
u_MsgLog(cPerg)

Aadd( aDbf, { 'XX_CONTRAT', 'C', 10,00 } )
Aadd( aDbf, { 'XX_NOMCLI', 'C', 100,00 } )
Aadd( aDbf, { 'XX_CNPJ', 'C', 18,00 } )
Aadd( aDbf, { 'XX_ENDER','C', 200,00 } )
Aadd( aDbf, { 'XX_TELS','C', 30,00 } )
Aadd( aDbf, { 'XX_XXDESC',  'C', 100,00 } )
Aadd( aDbf, { 'XX_CODOBJ','M', 10,0 } )
Aadd( aDbf, { 'XX_UF','C', 2,0 } )
Aadd( aDbf, { 'XX_DTINIC','D', 8,0 } )
Aadd( aDbf, { 'XX_DTASSI','D', 8,0 } )
Aadd( aDbf, { 'XX_PRAZO','C', 15,0 } ) 
Aadd( aDbf, { 'XX_DTFIM','D', 8,0 } )
Aadd( aDbf, { 'XX_VTOTAL','N', 14,2 } )
Aadd( aDbf, { 'XX_PEXEC','N', 4,0 } )
Aadd( aDbf, { 'XX_PAEXEC','N', 4,0 } )
Aadd( aDbf, { 'XX_SALDOAT','N', 14,2 } )

Aadd( aDbf, { 'XX_XXNGC',  'C', 40,00 } )
Aadd( aDbf, { 'XX_XXEGC',  'C', 70,00 } )

///cArqTmp := CriaTrab( aDbf, .t. )
///dbUseArea( .t.,NIL,cArqTmp,'TRB',.f.,.f. )

oTmpTb1 := FWTemporaryTable():New( "TRB" ) 
oTmpTb1:SetFields( aDbf )
oTmpTb1:Create()


FWMsgRun(, {|oSay| ProcQuery() }, "", "Consultando o banco de dados...")	

aCabs   := {}
aCampos := {}
aTitulos:= {}
aPlans  := {}
   
//nomeprog := "BKGCTR15/"+TRIM(SUBSTR(cUsuario,7,15))
AADD(aTitulos,cTitulo)

AADD(aCampos,"TRB->XX_CONTRAT")
AADD(aCabs  ,"Nº SIGA")

AADD(aCampos,"TRB->XX_NOMCLI")
AADD(aCabs  ,"Contratante")

AADD(aCampos,"TRB->XX_CNPJ")
AADD(aCabs  ,"CNPJ")

AADD(aCampos,"TRB->XX_ENDER")
AADD(aCabs  ,"Endereço Completo do Cliente")

AADD(aCampos,"TRB->XX_XXNGC")
AADD(aCabs  ,"Contato do Cliente")

AADD(aCampos,"TRB->XX_XXEGC")
AADD(aCabs  ,"E-mail Contato do Cliente")


AADD(aCampos,"TRB->XX_TELS")
AADD(aCabs  ,"Telefone do Cliente")

AADD(aCampos,"TRB->XX_XXDESC")
AADD(aCabs  ,"Nº Contrato")

AADD(aCampos,"U_CN9OBJ(TRB->XX_CODOBJ)")
AADD(aCabs  ,"Objeto")

AADD(aCampos,"TRB->XX_UF")
AADD(aCabs  ,"Local da Obra/Seviços")

AADD(aCampos,"TRB->XX_DTINIC")
AADD(aCabs  ,"Data de Início")

AADD(aCampos,"TRB->XX_DTASSI")
AADD(aCabs  ,"Data de Assinatura")

AADD(aCampos,"TRB->XX_PRAZO")
AADD(aCabs  ,"Prazo de Execução")

AADD(aCampos,"TRB->XX_DTFIM")
AADD(aCabs  ,"Data Fim do Contrato")

AADD(aCampos,"TRB->XX_VTOTAL")
AADD(aCabs  ,"Valor da Obra/Serviço")

AADD(aCampos,"TRB->XX_PEXEC")
AADD(aCabs  ,"% executado")

AADD(aCampos,"TRB->XX_PAEXEC")
AADD(aCabs  ,"% a Executar")

AADD(aCampos,"TRB->XX_SALDOAT")
AADD(aCabs  ,"Situação Atual")

AADD(aPlans,{"TRB",cPerg,"",aTitulos,aCampos,aCabs,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */, /*cQuebra*/, lClose:= .T. })

U_PlanXlsx(aPlans,cTitulo,cPerg,.T.)

oTmpTb1:Delete()

Return


Static Function ProcQuery
//Local cRevAtu := Space(GetSx3Cache("CN9_REVATU","X3_TAMANHO"))
Local cQuery
Local dDataI
Local dDataFinal
Local nPRAZOMES := 1
Local nVTOTAL   := 0
Local nSALDOAT  := 0


dbSelectArea("CN9")
CN9->(DBSETORDER(1))
CN9->(DBGOTOP())
DO WHILE CN9->(!EOF())
	
	IF !Empty(CN9->CN9_REVATU)
		CN9->(dbSkip())
		Loop
	ENDIF

	cQuery := " SELECT SUBSTRING(CNF_COMPET,4,4)+SUBSTRING(CNF_COMPET,1,2) AS CNF_COMPET,CNF_VLPREV,"
	cQuery += " CNF_DTVENC FROM "+RETSQLNAME("CNF")+" CNF"
	cQuery += " WHERE CNF.D_E_L_E_T_='' AND CNF.CNF_CONTRA='"+ALLTRIM(CN9->CN9_NUMERO)+"' AND CNF.CNF_REVISA='"+ALLTRIM(CN9->CN9_REVISA)+"' " 
	cQuery += " ORDER BY CNF_DTVENC" 
 
	TCQUERY cQuery NEW ALIAS "QCNF"
	TCSETFIELD("QCNF","CNF_DTVENC","D",8,0)	

	nPRAZOMES := 1
	nVTOTAL   := 0
	nSALDOAT  := 0
	dbSelectArea("QCNF")
	QCNF->(dbGoTop())

	dDataI		:= CTOD("")
	dDataI		:= QCNF->CNF_DTVENC
	dDataFinal	:= CTOD("")
	
	DO WHILE QCNF->(!EOF())
		nVTOTAL   += QCNF->CNF_VLPREV
		IF QCNF->CNF_COMPET >= cCompet
			nSALDOAT  += QCNF->CNF_VLPREV
		ENDIF
		dDataFinal	:= QCNF->CNF_DTVENC
		QCNF->(DBSKIP())
	ENDDO
    
	nPRAZOMES += DateDiffMonth( dDataI , dDataFinal )
	
	QCNF->(dbCloseArea())
    
    IF SUBSTR(cComSaldo,1,1) == "S" .AND. nSALDOAT == 0
		CN9->(dbSkip())
		Loop
    ENDIF
    
    cENDER := TRIM(Posicione("SA1",1,xFilial("SA1")+CN9->CN9_XCLIEN+CN9->CN9_XLOJA,"A1_END")) 
    cENDER := TRIM(SA1->A1_END)+' - '+TRIM(SA1->A1_BAIRRO)+' - '+TRIM(SA1->A1_MUN)+' - '+SA1->A1_EST   
	If RetPessoa(SA1->A1_CGC) == "F"
		cCNPJCli := Transform(SA1->A1_CGC,"@R 999.999.999-99")
	Else
		cCNPJCli := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
	Endif

    dtFIM  := CTOD("")
    dtFIM  := MonthSum( CN9->CN9_DTINIC , nPRAZOMES ) 
    dtFIM  := DaySum( dtFIM  , 1 )

	dbSelectArea("TRB")
	Reclock("TRB",.T.)
	TRB->XX_CONTRAT := CN9->CN9_NUMERO
	TRB->XX_NOMCLI  := SA1->A1_NOME
	TRB->XX_CNPJ	:= cCNPJCli
	TRB->XX_ENDER   := cENDER
	TRB->XX_TELS    := CN9->CN9_XXTELS
	TRB->XX_XXDESC  := CN9->CN9_XXDESC
	TRB->XX_CODOBJ  := CN9->CN9_CODOBJ 
	TRB->XX_UF      := SA1->A1_EST
	TRB->XX_DTINIC  := CN9->CN9_DTINIC
	TRB->XX_DTASSI  := CN9->CN9_DTASSI
	TRB->XX_PRAZO   := STR(nPRAZOMES,4)+" Meses"
	TRB->XX_DTFIM   := dtFIM
	TRB->XX_VTOTAL  := nVTOTAL
	TRB->XX_PEXEC   := ((nVTOTAL - nSALDOAT) * 100) / nVTOTAL
	TRB->XX_PAEXEC  := (nSALDOAT * 100) / nVTOTAL
	TRB->XX_SALDOAT := nSALDOAT

	TRB->XX_XXNGC   := CN9->CN9_XXNGC
	TRB->XX_XXEGC   := CN9->CN9_XXEGC
	
	TRB->(Msunlock())

	CN9->(DBSKIP())
ENDDO
Return


Static Function BkGC15
Local lRet := .F.
//   Parambox(aParametros,@cTitle ,@aRet,[ bOk ],[ aButtons ],[ lCentered ],[ nPosX ],[ nPosy ],[ oDlgWizard ],[ cLoad ] ,[ lCanSave ],[ lUserSave ] ) --> aRet
If (Parambox(aParam     ,cPerg+" - "+cTitulo,@aRet,       ,            ,.T.          ,         ,         ,              ,cPerg      ,.T.         ,.T.))
	lRet      := .T.
	cComSaldo := mv_par01
Endif
Return lRet
