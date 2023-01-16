#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINA27
Balsa Nova - Baixas de contas a pagar - titulos pagos na BK 
@Return
@author Marcos Bispo Abrahão
@since 16/11/2021
@version P12
/*/
//-------------------------------------------------------------------

User Function BKFINA27()
Local aParam 	:= {}
Local aRet		:=	{}
Local cTitulo   := "Baixas de contas a pagar - titulos pagos na BK"
Local dDataI	:= CTOD("01/11/2018")
Local dDataF	:= dDataBase
Private cPrw    := "BKFINA27"

If cEmpAnt == "01"
	u_MsgLog(cPrw,"Esta rotina não pode ser utilizada na empresa BK","E")
	Return Nil
EndIf

aAdd( aParam, { 1, "Venc. inicial:"		, dDataBase	, ""    , "", ""	, "" , 70  , .F. })
aAdd( aParam, { 1, "Venc. final:"		, dDataBase	, ""    , "", ""	, "" , 70  , .F. })  

If (Parambox(aParam,"BKFINA27 - "+cTitulo,@aRet,,,.T.,,,,cPrw,.T.,.T.))
	lRet := .T.
	dDataI  := mv_par01
	dDataF  := mv_par02
	F27Proc(dDataI,dDataF)
Endif

Return Nil


Static Function F27Proc(dDataI,dDataF)
Local aArea     := GetArea()
Local cAliasTmp := GetNextAlias()
Local oTmpTb
Local aStrut    := {}

Private aFacil  := {}
Private cBanco  := PAD("CTB",TamSX3("A6_COD")[1])
Private cAgencia:= PAD("00001",TamSX3("A6_AGENCIA")[1])
Private cNumCon := PAD("0000000001",TamSX3("A6_NUMCON")[1])
Private cNomeBc := PAD("",TamSX3("A6_NOME")[1]) 
Private dDataMov:= dDataBase
Private nTotPg := 0

cNomeBC := Posicione("SA6",1,xFilial("SA6")+cBanco+cAgencia+cNumCon,"A6_NOME")

//              Campo        Tipo    Tamanho            Decimal
aAdd( aStrut, { "XX_PREFIXO","C", TamSX3("E2_PREFIXO")[1], 0} )
aAdd( aStrut, { "XX_NUM",    "C", TamSX3("E2_NUM")[1]    , 0} )
aAdd( aStrut, { "XX_PARCELA","C", TamSX3("E2_PARCELA")[1], 0} )
aAdd( aStrut, { "XX_TIPO",   "C", TamSX3("E2_TIPO")[1]   , 0} )
aAdd( aStrut, { "XX_FORNECE","C", TamSX3("E2_FORNECE")[1], 0} )
aAdd( aStrut, { "XX_LOJA",   "C", TamSX3("E2_LOJA")[1]   , 0} )
aAdd( aStrut, { "XX_NOMFOR", "C", TamSX3("E2_NOMFOR")[1] , 0} )
aAdd( aStrut, { "XX_EMISSAO","D", TamSX3("E2_EMISSAO")[1], 0} )
aAdd( aStrut, { "XX_VENCTO", "D", TamSX3("E2_VENCTO")[1] , 0} )
aAdd( aStrut, { "XX_VENCREA","D", TamSX3("E2_VENCREA")[1] , 0} )
aAdd( aStrut, { "XX_SALDO",  "N", TamSX3("E2_SALDO")[1], TamSX3("E2_SALDO")[2]} )
aAdd( aStrut, { "XX_PORTADO","C", TamSX3("E2_PORTADO")[1] , 0} )
aAdd( aStrut, { "XX_HIST",   "C", TamSX3("E2_HIST")[1] , 0} )
//Criando tabela temporária
//cArq:= CriaTrab( aStrut, .T. )             
//dbUseArea( .T.,NIL, cArq, cAliasTmp, .T., .F. )
//dbSelectArea(cAliasTmp)
 
oTmpTb := FWTemporaryTable():New( cAliasTmp ) 
oTmpTb:SetFields( aStrut )
oTmpTb:Create()

u_WaitLog(, {|oSay| FA27Qry(cAliasTmp,dDataI,dDataF) },"Consultando títulos não baixados...")

FA22EdtCx(cAliasTmp)

oTmpTb:Delete() 
//(cAliasTmp)->(DbCloseArea())
//FErase(cArq+GetDBExtension())
//FErase(cArq+OrdBagExt())

RestArea(aArea)

Return Nil


Static Function FA22EdtCx(cAliasTmp)

Local aArea      := GetArea()
Local nTamBtn    := 50
Local nAtual	 := 0

Private nColunas := 0
Private nLinhas  := 0
Private aDados   := {}
Private oDlgPvt
Private oMGet22 
Private oSayTot
Private aHeader  := {}
Private aCols    := {}
Private aEdit    := {}
Private aStrut   := {}
Private aAux     := {}

//Tamanho da Janela
Private aTamanho := MsAdvSize()
Private nJanLarg := aTamanho[5]
Private nJanAltu := aTamanho[6]
Private nColMeio := (nJanLarg)/4

Private bfDeleta := {|| fDeleta()}

Private nPosPrefixo
Private nPosNUM
Private nPosPARCELA
Private nPosTIPO
Private nPosFORNECE
Private nPosLOJA
Private nPosSALDO
Private nPosHist

Private nColDel

// Tabela temporária
dbSelectArea(cAliasTmp)
Count To nLinhas
nColunas := fCount()
aStrut   := (cAliasTmp)->(DbStruct())
(cAliasTmp)->(DbGoTop())

//Cabeçalho ...	Titulo          Campo				Mask		        Tamanho				    Dec									Valid               Usado	Tip		F3	       CBOX
aAdd(aHeader,{	"Prefixo"   ,	"XX_PREFIXO"  	,	"@!"            ,TamSX3("E2_PREFIXO")[1],	0                				,	".T."   		,	".T.",	"C",	""   	,	""})
aAdd(aHeader,{	"No. Titulo"  ,	"XX_NUM"        ,	"@!"            ,TamSX3("E2_NUM")[1]    ,	0                				,	".T."  			,	".T.",	"C",	""   	,	""})
aAdd(aHeader,{	"Parcela"   ,	"XX_PARCELA"    ,	"@!"            ,TamSX3("E2_PARCELA")[1],	0                				,	".T."  			,	".T.",	"C",	""   	,	""})
aAdd(aHeader,{	"Tipo"      ,	"XX_TIPO"       ,	"@!"            ,TamSX3("E2_TIPO")[1],		0                				,	".T."    		,	".T.",	"C",	"05"   	,	""})
aAdd(aHeader,{	"Fornecedor" ,	"XX_FORNECE"    ,	"@!"            ,TamSX3("E2_FORNECE")[1],	0               				,	".T."           ,	".T.",	"C",	""   	,	""})
aAdd(aHeader,{	"LOJA"      ,	"XX_LOJA"       ,	"@!"            ,TamSX3("E2_LOJA")[1],		0                				,	".T."           ,	".T.",	"C",	""   	,	""})
aAdd(aHeader,{	"Nome Fornece",	"XX_NOMFOR"     ,	"@!"            ,TamSX3("E2_NOMFOR")[1],	0                				,	".T."           ,	".T.",	"C",	"FOR"   ,	""})
aAdd(aHeader,{	"DT Emissao"  ,	"XX_EMISSAO"    ,	"@!"            ,TamSX3("E2_EMISSAO")[1],	0              					,	".T." 			,	".T.",	"D",	""   	,	""})
aAdd(aHeader,{	"Vencimento",	"XX_VENCTO"     ,	"@!"            ,TamSX3("E2_VENCTO")[1],	0               				,	".T."           ,	".T.",	"D",	""   	,	""})
aAdd(aHeader,{	"Vencto Real" ,	"XX_VENCREA"    ,	"@!"            ,TamSX3("E2_VENCREA")[1],	0              				  	,	".T."           ,	".T.",	"D",	""   	,	""})
aAdd(aHeader,{	"Saldo"     ,	"XX_SALDO"    	,	"@E 999,999,999,999,999.99",TamSX3("E2_SALDO")[1],TamSX3("E2_SALDO")[2] 	,	".T." 			,	".T.",	"N",	""   	,	""})
aAdd(aHeader,{	"Portado" ,		"XX_PORTADO"    ,	"@!"            ,TamSX3("E2_PORTADO")[1],	0                				,	".T."           ,	".T.",	"C",	"BCO"   ,	""})
aAdd(aHeader,{	"Historico" ,	"XX_HIST"	    ,	"@!"            ,TamSX3("E2_HIST")[1]	,	0                				,	".T."           ,	".T.",	"C",	"" 		,	""})

nPosPrefixo := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_PREFIXO"})
nPosNUM 	:= aScan(aHeader, {|x| AllTrim(x[2]) == "XX_NUM"})
nPosPARCELA := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_PARCELA"})
nPosTIPO	:= aScan(aHeader, {|x| AllTrim(x[2]) == "XX_TIPO"})
nPosFORNECE := aScan(aHeader, {|x| AllTrim(x[2]) == "XX_FORNECE"})
nPosLOJA  	:= aScan(aHeader, {|x| AllTrim(x[2]) == "XX_LOJA"})
nPosSALDO 	:= aScan(aHeader, {|x| AllTrim(x[2]) == "XX_SALDO"})
nPosHIST 	:= aScan(aHeader, {|x| AllTrim(x[2]) == "XX_HIST"})
nColDel   	:= LEN(aHeader) + 1

//Percorrendo as linhas e adicionando no aCols
While ! (cAliasTmp)->(EoF())
	//Montando a linha atual
	aAux := Array(Len(aHeader)+1)
	For nAtual := 1 To Len(aStrut)
		aAux[nAtual] := &((cAliasTmp)->(aStrut[nAtual,1]))
	Next
	aAux[Len(aHeader)+1] := .F.
	
	//Adiciona no aCols
	aAdd(aCols, aClone(aAux))
		
	(cAliasTmp)->(DbSkip())
EndDo

MsgInfo("Atenção: Use a tecla DEL para desconsiderar titulos desta baixa",cPrw)

//Montando a tela
DEFINE MSDIALOG oDlgPvt TITLE "Baixa Contas a Pagar" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Dados
	@ 000, 003  GROUP oGrpBc  TO 027, (nJanLarg/2)-003  PROMPT "Dados da conta para movimentação financeira:"  OF oDlgPvt PIXEL

	@ 012, 010 SAY "Banco:"  SIZE 50, 7 OF oDlgPvt PIXEL 
    @ 010, 030 MSGET cBanco Picture "@!"  When .T. SIZE 50, 11 OF oDlgPvt PIXEL F3 "SA6" VALID (NaoVazio(cBanco) .AND. ExistCpo("SA6") .AND. !EMPTY(cNomeBc:=SA6->A6_NOME) )
                        
    @ 012, 090 SAY "Agência:" SIZE 50, 7 OF oDlgPvt PIXEL
    @ 010, 120 MSGET cAgencia Picture "@!" When .F. SIZE 30, 11 OF oDlgPvt PIXEL VALID NaoVazio(cAgencia)

    @ 012, 160 SAY "Conta:" SIZE 50, 7 OF oDlgPvt PIXEL
    @ 010, 180 MSGET cNumCon Picture "@!" When .F. SIZE 60, 11 OF oDlgPvt PIXEL VALID NaoVazio(cNumCon)

    @ 010, 250 MSGET cNomeBc Picture "@!" When .F. SIZE 120, 11 OF oDlgPvt PIXEL 

    @ 012, 380 SAY "Data:" SIZE 50, 7 OF oDlgPvt PIXEL
    @ 010, 400 MSGET dDataMov Picture "@E" When .F. SIZE 50, 11 OF oDlgPvt PIXEL


	@ 030, 003  GROUP oGrpDad TO (nJanAltu/2)-030, (nJanLarg/2)-003  PROMPT "Dados: "  OF oDlgPvt PIXEL

	oMGet22 := MsNewGetDados():New(	040,;          					//nTop
									006,;          					//nLeft
									(nJanAltu/2)-033,;        		//nBottom
									(nJanLarg/2)-006,;       		//nRight
									GD_DELETE,;	                    //nStyle
									"",; 	      	   				//cLinhaOk
									,;           					//cTudoOk
									"",;          					//cIniCpos
									,;          			    	//aAlter
									,;           					//nFreeze
									9999999,;         				//nMax
									,;           					//cFieldOK
									,;           					//cSuperDel
									"Eval(bfDeleta)",;				//cDelOk
									oDlgPvt,;     					//oWnd
									aHeader,;        				//aHeader
									aCols)         					//aCols
			
	//Ações
	@ (nJanAltu/2)-25, 03 GROUP oGrpAco TO (nJanAltu/2)-003, (nJanLarg/2)-003  PROMPT "Ações: "  OF oDlgPvt PIXEL

	@ (nJanAltu/2)-19+5, 10 SAY oSayTot PROMPT "Total a pagar: "+TRANSFORM(nTotPg,"@E 999,999,999.99") SIZE 250, 10 OF oDlgPvt COLORS RGB(0,0,0) PIXEL
	@ (nJanAltu/2)-19  , (nJanLarg/2)-((nTamBtn*1)+06) BUTTON oBtnConf PROMPT "Cancelar"   SIZE nTamBtn, 013 OF oDlgPvt ACTION(oDlgPvt:End())                   PIXEL
	@ (nJanAltu/2)-19  , (nJanLarg/2)-((nTamBtn*2)+09) BUTTON oBtnLimp PROMPT "Baixar"     SIZE nTamBtn, 013 OF oDlgPvt ACTION(If(fValid("TODOS"),fSalvar(),),oDlgPvt:End())  PIXEL


ACTIVATE MSDIALOG oDlgPvt CENTERED
	 
RestArea(aArea)

Return 



Static Function fDeleta()
If !EMPTY(oMGet22)
	oMGet22:aCols[oMGet22:nAt, nColDel] := !oMGet22:aCols[oMGet22:nAt, nColDel]
	oMGet22:Refresh() 
	SomaTot()
EndIf
Return()


Static Function SomaTot()
Local nY := 0
nTotPg := 0
For nY := 1 to Len(oMGet22:aCols)
	If !oMGet22:aCols[nY][nColDel]
		nTotPg += oMGet22:aCols[nY][nPosSALDO]
	EndIf
Next nY
oSayTot:Refresh()
Return Nil


Static Function fValid(cCampo)
Local lRet := .T.
Return (lRet)



Static Function fSalvar()
Local lRet := .F.

u_WaitLog(, {|oSay| lRet := ProcBaixa() }, "Gerando Baixas a Pagar…")

If lRet
	oDlgPvt:End()
EndIf

Return

 
 

Static Function ProcBaixa()

Local nY
//Local aUsuarios := ALLUSERS()
Local aBaixa    := {}
Local lSucess	:= .T.

Private lMsErroAuto := .F.

/*
nX := aScan(aUsuarios,{|x| x[1][1] == __cUserID})

If nX > 0
	cUsuario := aUsuarios[nX][1][2]
EndIf
*/

BEGIN TRANSACTION
	
	For nY := 1 to Len(oMGet22:aCols)

		If !oMGet22:aCols[nY][nColDel] 	
	
	        aBaixa := {}
	        AADD(aBaixa, {"E2_FILIAL" , xFILIAL("SE2") , Nil})
	        AADD(aBaixa, {"E2_PREFIXO" , oMGet22:aCols[nY][nPosPREFIXO] , Nil})
	        AADD(aBaixa, {"E2_NUM" , oMGet22:aCols[nY][nPosNUM] , Nil})
	        AADD(aBaixa, {"E2_PARCELA" , oMGet22:aCols[nY][nPosPARCELA] , Nil})
	        AADD(aBaixa, {"E2_TIPO" , oMGet22:aCols[nY][nPosTIPO] , Nil})
	        AADD(aBaixa, {"E2_FORNECE" , oMGet22:aCols[nY][nPosFORNECE] , Nil})
	        AADD(aBaixa, {"E2_LOJA" , oMGet22:aCols[nY][nPosLOJA] , Nil}) 
	        AADD(aBaixa, {"AUTMOTBX" , "DEBITO CC" , Nil})
	        AADD(aBaixa, {"AUTBANCO" , cBanco , Nil})
	        AADD(aBaixa, {"AUTAGENCIA" , cAgencia , Nil})
	        AADD(aBaixa, {"AUTCONTA" , cNumCon , Nil})
	        AADD(aBaixa, {"AUTDTBAIXA" , dDataMov , Nil}) 
	        AADD(aBaixa, {"AUTDTCREDITO", dDataMov , Nil})
            AADD(aBaixa, {"AUTHIST" , oMGet22:aCols[nY][nPosHIST] , Nil})
	        AADD(aBaixa, {"AUTVLRPG" , oMGet22:aCols[nY][nPosSALDO] , Nil})
	        ACESSAPERG("FIN080", .F.)

			lMsErroAuto := .F.
			MSEXECAUTO({|x,y| FINA080(x,y)}, aBaixa, 3)
			
			If lMsErroAuto
				u_LogMsExec(cPrw,"Titulo não baixado: "+oMGet22:aCols[nY][nPosPREFIXO]+oMGet22:aCols[nY][nPosNUM]+oMGet22:aCols[nY][nPosPARCELA])
				DisarmTransaction()
				lSucess := .F.
			EndIf
		EndIf
	Next

END TRANSACTION

If lSucess
	u_MsgLog(cPrw,"Baixas de contas a Pagar realizadas com sucesso.","S")
Else
	u_MsgLog(cPrw,"Algumas baixas de contas a Pagar não foram realizadas","E")
EndIf

Return lSucess



STATIC Function FA27Qry(cAliasTmp,dDataI,dDataF)
Local aAreaAtu			:= GetArea()
Local cQuery 			:= ""

cQuery := "SELECT E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_FORNECE,E2_LOJA,E2_NOMFOR,"
cQuery += "E2_EMISSAO,E2_VENCTO,E2_VENCREA,E2_SALDO-E2_SDDECRE+E2_SDACRES AS E2_SALDO,E2_PORTADO,E2_HIST,R_E_C_N_O_ AS NREG"
cQuery += " FROM "+RetSqlName("SE2")+" SE2"
cQuery += " WHERE SE2.D_E_L_E_T_=''" 
cQuery += " AND E2_VENCREA >= '"+DTOS(dDataI)+"'"
cQuery += " AND E2_VENCREA <= '"+DTOS(dDataF)+"'"
cQuery += " AND SUBSTRING(E2_HIST,1,3)='DNF'"
cQuery += " AND E2_BAIXA=''"
cQuery += " AND E2_TIPO<>'PA'"
cQuery += " AND E2_SALDO > 0" 

u_LogMemo("BKFINA27.SQL",cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QSE2",.T.,.T.)

TCSETFIELD("QSE2","E2_EMISSAO","D",8,0)
TCSETFIELD("QSE2","E2_VENCTO","D",8,0)
TCSETFIELD("QSE2","E2_VENCREA","D",8,0)

DbSelectArea("QSE2")
QSE2->(dbgotop())

nTotPg := 0
Do While QSE2->(!eof())
	dbSelectArea(cAliasTmp)
	Reclock(cAliasTmp,.T.)
	(cAliasTmp)->XX_PREFIXO := QSE2->E2_PREFIXO
	(cAliasTmp)->XX_NUM 	:= QSE2->E2_NUM
	(cAliasTmp)->XX_PARCELA := QSE2->E2_PARCELA
	(cAliasTmp)->XX_TIPO 	:= QSE2->E2_TIPO
	(cAliasTmp)->XX_FORNECE := QSE2->E2_FORNECE
	(cAliasTmp)->XX_LOJA 	:= QSE2->E2_LOJA
	(cAliasTmp)->XX_NOMFOR 	:= QSE2->E2_NOMFOR
	(cAliasTmp)->XX_EMISSAO := QSE2->E2_EMISSAO
	(cAliasTmp)->XX_VENCTO 	:= QSE2->E2_VENCTO
	(cAliasTmp)->XX_VENCREA := QSE2->E2_VENCREA
	(cAliasTmp)->XX_SALDO 	:= QSE2->E2_SALDO
	(cAliasTmp)->XX_PORTADO := QSE2->E2_PORTADO
	(cAliasTmp)->XX_HIST	:= QSE2->E2_HIST
	(cAliasTmp)->(MsUnlock())  
	nTotPg += QSE2->E2_SALDO      
	QSE2->(dbSkip())
ENDDO
QSE2->(dbCloseArea())

RestArea( aAreaAtu )

Return Nil
                  
