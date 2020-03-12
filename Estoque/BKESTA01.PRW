#include "totvs.ch"
#include "protheus.ch"
#include "TopConn.ch"
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BKESTA01   º Autor ³ Adilson do Prado   º Data ³  28/03/17 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina para gerar solicitação ao Armazem de uma solicitaçãoº±±
±±º          ³ de compras                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BK                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function BKESTA01(aSaldos)
Local aArea     := GetArea()

PRIVATE dDataMov := dDATABASE
PRIVATE cCC      := aSaldos[1,09]
PRIVATE cDCC 	 := aSaldos[1,10]
PRIVATE cSolict  := aSaldos[1,11]

/*
//              Campo       Tipo    Tamanho                 Decimal
aAdd( aStrut, { "XX_NSOLC", "C",    TamSX3("C1_NUM")[1], 0} )
aAdd( aStrut, { "XX_ITEM",  "C",    TamSX3("C1_ITEM")[1], 0} )
aAdd( aStrut, { "XX_PROD",  "C",    TamSX3("C1_PRODUTO")[1], 0} )
aAdd( aStrut, { "XX_DESCR", "C",    TamSX3("B1_DESC")[1], 0} )
aAdd( aStrut, { "XX_QUANT", "N",    TamSX3("C1_QUANT")[1],TamSX3("C1_QUANT")[2]} )
aAdd( aStrut, { "XX_QEST",  "N",    TamSX3("C1_QUANT")[1],TamSX3("C1_QUANT")[2]} )
aAdd( aStrut, { "XX_QSOL",  "N",    TamSX3("C1_QUANT")[1],TamSX3("C1_QUANT")[2]} )

                                           
//Excluindo dados da tabela temporária, se tiver aberta, fecha a tabela
If Select(cAliasTmp)>0
    (cAliasTmp)->(DbCloseArea())
EndIf
fErase(cAliasTmp+GetDBExtension())
     
//Criando tabela temporária
cArq:= CriaTrab( aStrut, .T. )             
dbUseArea( .T.,NIL, cArq, cAliasTmp, .T., .F. )
dbSelectArea(cAliasTmp)

FOR _IX:= 1 TO LEN(aSaldos)
	dbSelectArea(cAliasTmp)
	Reclock(cAliasTmp,.T.)
	(cAliasTmp)->XX_NSOLC 	:= aSaldos[_IX,1]
	(cAliasTmp)->XX_ITEM  	:= aSaldos[_IX,2]
	(cAliasTmp)->XX_PROD	:= aSaldos[_IX,3]
	(cAliasTmp)->XX_DESCR	:= aSaldos[_IX,4]
	(cAliasTmp)->XX_QUANT	:= aSaldos[_IX,6]
	(cAliasTmp)->XX_QEST	:= aSaldos[_IX,7]
	(cAliasTmp)->XX_QSOL	:= aSaldos[_IX,8]
   	(cAliasTmp)->(MsUnlock())

NEXT
  
xBKESTA01(cAliasTmp)

(cAliasTmp)->(DbCloseArea())
FErase(cArq+GetDBExtension())
FErase(cArq+OrdBagExt())
*/

// Novo código

MsgRun("Aguarde, gerando Solicitação ao Estoque - Almoxarifado…","",{|| CursorWait(), lRet := fProcessa1(aSaldos) ,CursorArrow()})

RestArea(aArea)

Return Nil


/*
Static Function xBKESTA01(cAliasTmp)

Local cDirSrv    := ""
Local aArea      := GetArea()
Local nTamBtn    := 50

Private nColunas := 0
Private nLinhas  := 0
Private aDados   := {}
Private oDlgPvt
Private oMGet19 
Private oSayTot
Private aHeader  := {}
Private aCols    := {}
Private aEdit    := {}
Private aStrut   := {}
Private aAux     := {}

//Tamanho da Janela
Private aTamanho := MsAdvSize()
Private nJanLarg := aTamanho[5]/1.2
Private nJanAltu := aTamanho[6]/1.2
Private nColMeio := (nJanLarg)/4

Private bNSOLC   := {|| fValid("XX_NSOLC")}
Private bITEM 	 := {|| fValid("XX_ITEM")}
Private bPROD 	 := {|| fValid("XX_PROD")}
Private bDESCR   := {|| fValid("XX_DESCR")}
Private bQUANT	 := {|| fValid("XX_QUANT")}
Private bQEST	 := {|| fValid("XX_QEST")}  
Private bQSOL	 := {|| fValid("XX_QSOL")}  
Private bLinOk   := {|| fValid("LINHA")}
Private bfDeleta := {|| fDeleta()}

Private nPosnSolc 
Private nPosITEM
Private nPosPROD
Private nPosDESCR
Private nPosQUANT
Private nPosQEST
Private nPosQSOL
Private nColDel

// Tabela temporária
dbSelectArea(cAliasTmp)
Count To nLinhas
nColunas := fCount()
aStrut   := (cAliasTmp)->(DbStruct())
(cAliasTmp)->(DbGoTop())

//Cabeçalho ...	Titulo          			Campo				Mask		       						 	Tamanho				    	Dec				  		Valid         		Usado	Tip		F3	    CBOX
aAdd(aHeader,{	"Nº Solicitação"  		,	"XX_NSOLC"   	,	"@!"           						 	,	TamSX3("C1_NUM")[1]   	,	0    				,	".T."  			,	".T.",	"C",	""   ,	""})
aAdd(aHeader,{	"Item"      			,	"XX_ITEM"    	,	"@!"           						 	,   TamSX3("C1_ITEM")[1]	,	0          			,	".T."  			,	".T.",	"C",	""   ,	""})
aAdd(aHeader,{	"Cod. Prod." 			,	"XX_PROD"    	,	"@!"          						  	,	TamSX3("C1_PRODUTO")[1]	,	0         			,	".T."  			,	".T.",	"C",	""   ,	""})
aAdd(aHeader,{	"Descr. Prod"  			,	"XX_DESCR"    	,	"@!"            						,	TamSX3("B1_DESC")[1]	,	0          			,	".T."  			,	".T.",	"C",	""	 ,	""})
aAdd(aHeader,{	"Qnt. Solicitação"  	,	"XX_QUANT"    	,	GetSx3Cache("C1_QUANT", "X3_PICTURE") 	,	TamSX3("C1_QUANT")[1]	,TamSX3("C1_QUANT")[2]	,	".T."  			,	".T.",	"N",	""   ,	""})
aAdd(aHeader,{	"Qnt. Estoque"     		,	"XX_QEST"     	,	GetSx3Cache("C1_QUANT", "X3_PICTURE")	,	TamSX3("C1_QUANT")[1]	,TamSX3("C1_QUANT")[2]  ,	".T."  			,	".T.",	"N",	""   ,	""})
aAdd(aHeader,{	"Qnt. Solic. Estoque"	,	"XX_QSOL"     	,	GetSx3Cache("C1_QUANT", "X3_PICTURE")  	,	TamSX3("C1_QUANT")[1]	,TamSX3("C1_QUANT")[2]  ,	"Eval(bQSOL)"	,	".T.",	"N",	""	 ,	""})

aAdd(aEdit, "XX_QSOL" )

nPosNSOLC 	:= aScan(aHeader, {|x| AllTrim(x[2]) == "XX_NSOLC"})
nPosITEM	:= aScan(aHeader, {|x| AllTrim(x[2]) == "XX_ITEM"})
nPosPROD	:= aScan(aHeader, {|x| AllTrim(x[2]) == "XX_PROD"})
nPosDESCR	:= aScan(aHeader, {|x| AllTrim(x[2]) == "XX_DESCR"})
nPosQUANT	:= aScan(aHeader, {|x| AllTrim(x[2]) == "XX_QUANT"})
nPosQEST	:= aScan(aHeader, {|x| AllTrim(x[2]) == "XX_QEST"})
nPosQSOL	:= aScan(aHeader, {|x| AllTrim(x[2]) == "XX_QSOL"})
nColDel   := LEN(aHeader) + 1

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
	
//Montando a tela
DEFINE MSDIALOG oDlgPvt TITLE "Gera Solicitação ao Estoque - Almoxarifado" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Dados
	@ 000, 003  GROUP oGrpBc  TO 027, (nJanLarg/2)-003  PROMPT "Informações:"  OF oDlgPvt PIXEL

	@ 012, 010 SAY "Data:"  SIZE 50, 7 OF oDlgPvt PIXEL 
    @ 010, 030 MSGET dDataMov Picture "@!"  When .F. SIZE 80, 11 OF oDlgPvt PIXEL
                        
    @ 012, 120 SAY "Solicitante:" SIZE 80, 7 OF oDlgPvt PIXEL
    @ 010, 160 MSGET cSolict Picture "@!" When .F. SIZE 100, 11 OF oDlgPvt PIXEL 

    @ 012, 270 SAY "Centro de Custo:" SIZE 80, 7 OF oDlgPvt PIXEL
    @ 010, 320 MSGET cCC Picture "@!" When .F. SIZE 80, 11 OF oDlgPvt PIXEL

    @ 010, 410 MSGET cDCC Picture "@!" When .F. SIZE 120, 11 OF oDlgPvt PIXEL 

	@ 030, 003  GROUP oGrpDad TO (nJanAltu/2)-030, (nJanLarg/2)-003  PROMPT "Dados: "  OF oDlgPvt PIXEL

		oMGet19 := MsNewGetDados():New(	040,;          					//nTop
										006,;          					//nLeft
										(nJanAltu/2)-033,;        		//nBottom
										(nJanLarg/2)-006,;       		//nRight
										GD_INSERT+GD_DELETE+GD_UPDATE,;	//nStyle
										"Eval(bLinOk)",; 	      		//cLinhaOk
										,;           					//cTudoOk
										"",;          					//cIniCpos
										aEdit,;          				//aAlter
										,;           					//nFreeze
										9999999,;         				//nMax
										,;           					//cFieldOK
										,;           					//cSuperDel
										"Eval(bfDeleta)",;				//cDelOk
										oDlgPvt,;     					//oWnd
										aHeader,;        				//aHeader
										aCols)         					//aCols

			
	//Ações

	@ (nJanAltu/2)-19  , (nJanLarg/2)-((nTamBtn*1)+06) BUTTON oBtnConf PROMPT "Cancelar"   SIZE nTamBtn, 013 OF oDlgPvt ACTION(oDlgPvt:End())                   PIXEL
	@ (nJanAltu/2)-19  , (nJanLarg/2)-((nTamBtn*2)+09) BUTTON oBtnLimp PROMPT "Confirmar"     SIZE nTamBtn, 013 OF oDlgPvt ACTION(If(fValid("TODOS"),fSalvar(),))  PIXEL

ACTIVATE MSDIALOG oDlgPvt CENTERED
	 
RestArea(aArea)

Return 



Static Function fDeleta()
If !EMPTY(oMGet19)
	oMGet19:aCols[oMGet19:nAt, nColDel] := !oMGet19:aCols[oMGet19:nAt, nColDel]
	oMGet19:Refresh() 
EndIf
Return()


Static Function fValid(cCampo)

Local lRet := .T.
Local nY

If cCampo == "TODOS"
	// Valida todas as linhas
	For nY := 1 to Len(oMGet19:aCols)
		If !oMGet19:aCols[nY][nColDel]
			If !fValCampo("XX_QSOL",nY,.F.) 
				MsgStop("Problema encontrado na linha "+AllTrim(Str(nY)),"Atenção!")
				oMGet19:GoTo(nY)
				Return .F.
			EndIf
		EndIf
	Next nY
ElseIf cCampo == "LINHA"
	// Valida a linha
	nY := oMGet19:nAt
	If !oMGet19:aCols[nY][nColDel]
		If !fValCampo("XX_QSOL",nY,.F.) 
			Return .F.
		EndIf
	EndIf
Else
	// Valida o campo digitado
	lRet := fValCampo(cCampo,oMGet19:nAt,.T.)
EndIf
Return (lRet)

 

Static Function fValCampo(cCampo,nY,lDigitado)
Local cAlias
Local cHist
Local cConta
Local cTipoMov

If cCampo == "XX_QSOL"
	If IIf(lDigitado,M->XX_QSOL,oMGet19:aCols[nY][nPosQSOL]) > oMGet19:aCols[nY][nPosQEST] ;
		.OR. IIf(lDigitado,M->XX_QSOL,oMGet19:aCols[nY][nPosQSOL]) <= 0 ;
       .OR. IIf(lDigitado,M->XX_QSOL,oMGet19:aCols[nY][nPosQSOL]) > oMGet19:aCols[nY][nPosQUANT]
		MsgStop("Quantidade Digitada inválida. Verifique!","Atenção!")
		Return(.F.)
	EndIf
	If lDigitado
		oMGet19:aCols[nY][nPosQSOL] := M->XX_QSOL
	EndIf
EndIf

Return(.T.)



Static Function fSalvar()
Local lRet := .F.

MsgRun("Aguarde, gerando Solicitação ao Estoque - Almoxarifado…","",{|| CursorWait(), lRet := fProcessa1() ,CursorArrow()})

If lRet
	oDlgPvt:End()
EndIf

Return
*/
 

Static Function fProcessa1(aSaldos)

Local nX, nY
Local aUsuarios := ALLUSERS()
Local aCabec := {}
Local aItens := {}
Local lItem  := .F.

Private lMsErroAuto := .F.

nX := aScan(aUsuarios,{|x| x[1][1] == __cUserID})

If nX > 0
	cUsuario := aUsuarios[nX][1][2]
EndIf

BEGIN TRANSACTION
	
	aCabec := {}
	aadd(aCabec,{"CP_FILIAL"  ,xFilial("SCP")    ,Nil}) // Cód da Filial
	aadd(aCabec,{"CP_NUM"     ,GETSXENUM("SCP","CP_NUM") ,Nil}) // Numero da SA (Calcular se necessário)
	aadd(aCabec,{"CP_SOLICIT" ,cSolict ,Nil}) // Nome do Solicitante (usuário logado)
	aadd(aCabec,{"CP_EMISSAO" ,dDataMov ,Nil}) // Data de Emissão

	aItens := {}
    
	/*
	For nY := 1 to Len(oMGet19:aCols)
		If !oMGet19:aCols[nY][nColDel] 	
			aAdd(aItens,{})
			aadd(aItens[len(aItens)],{"CP_PRODUTO" 	,oMGet19:aCols[nY][nPosPROD],})
			aadd(aItens[len(aItens)],{"CP_QUANT"   	,oMGet19:aCols[nY][nPosQSOL],})
			aadd(aItens[len(aItens)],{"CP_ITEM"    	,STRZERO(len(aItens),2),})
			aadd(aItens[len(aItens)],{"CP_LOCAL"   	,"01",})
			aadd(aItens[len(aItens)],{"CP_CC"   	,cCC,})
			aadd(aItens[len(aItens)],{"CP_XXDCC"   	,cDCC,})
			aadd(aItens[len(aItens)],{"CP_XXNSCOM"  ,oMGet19:aCols[nY][nPosNSOLC],})
			aadd(aItens[len(aItens)],{"CP_XXISCOM"  ,oMGet19:aCols[nY][nPosITEM],})
			lItem  := .T.
		EndIf
	Next
    */

	For nY := 1 to Len(aSaldos)
		aAdd(aItens,{})
		aadd(aItens[len(aItens)],{"CP_PRODUTO" 	,aSaldos[nY,3],})
		aadd(aItens[len(aItens)],{"CP_QUANT"   	,aSaldos[nY,8],})
		aadd(aItens[len(aItens)],{"CP_ITEM"    	,STRZERO(len(aItens),2),})
		aadd(aItens[len(aItens)],{"CP_LOCAL"   	,"01",})
		aadd(aItens[len(aItens)],{"CP_CC"   	,cCC,})
		aadd(aItens[len(aItens)],{"CP_XXDCC"   	,cDCC,})
		aadd(aItens[len(aItens)],{"CP_XXNSCOM"  ,aSaldos[nY,1],})
		aadd(aItens[len(aItens)],{"CP_XXISCOM"  ,aSaldos[nY,2],})
		lItem  := .T.
	Next
    
    
	IF lItem
		MSExecAuto({|x,y,z| MATA105(x,y,z)},aCabec,aItens,3)     
		If lMsErroAuto
			MostraErro()
			DisarmTransaction()
			Return .F.
		ELSE
			FOR nY := 1 TO LEN(aItens)
				cQuery := "UPDATE "+RetSqlName("SC1")+" SET C1_QUJE=(C1_QUJE+"+STR(aItens[nY][2][2],TamSX3("C1_QUANT")[1],TamSX3("C1_QUANT")[2])+"),"
				cQuery += " C1_XXQEST="+STR(aItens[nY][2][2],TamSX3("C1_QUANT")[1],TamSX3("C1_QUANT")[2])+""
				cQuery += " FROM "+RetSqlName("SC1")+" SC1" 
				cQuery += " WHERE SC1.D_E_L_E_T_='' AND C1_NUM='"+aItens[nY][7][2]+"' AND C1_ITEM='"+aItens[nY][8][2]+"'"
				If TCSQLExec(cQuery) < 0 
					MsgStop(TCSQLERROR())
				endif
			NEXT
			IF LEN(aItens) > 0
				U_EMAILSOL(aItens[1][7][2])
			ENDIF
		EndIf
	ENDIF

END TRANSACTION

Return .T. 


User Function EMAILSOL(cNumSol)
Local cAssunto	:= ""
Local cEmail	:= "microsiga@bkconsultoria.com.br;"
Local cEmailCC  := "" //microsiga@bkconsultoria.com.br;"
Local cMsg 		:= "" 
Local cAnexo	:= ""
Local _lJob		:= .T.
Local aCabs		:= {}
Local aEmail	:= {}
Local aMotivo	:= {} 
Local lAprov	:= .T.
Local lAlmox	:= .F.
Local aGrupo	:= {}
Local cAlEmail	:= ""
Local aUsers 	:= {}
Local cAlmox 	:= ALLTRIM(SuperGetMV("MV_XXGRALX",.F.,"000021"))+"/"+ALLTRIM(SuperGetMV("MV_XXMSALX",.F.,"000027"))
Local _cXXENDEN := ""
Local _cXXEN 	:= ""
Local _nXXEN 	:= 0

AADD(aMotivo,"Início de Contrato")
AADD(aMotivo,"Reposição Programada")
AADD(aMotivo,"Reposição Eventual")

PswOrder(1) 
PswSeek(__CUSERID)  
aUser  := PswRet(1)
IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
	cEmail += ALLTRIM(aUser[1,14])+';'
ENDIF


SY1->(dbgotop())
Do While SY1->(!eof())                                                                                                               
	PswOrder(1) 
	PswSeek(SY1->Y1_USER) 
	aUser  := PswRet(1)
	IF !EMPTY(aUser[1,14]) .AND. !aUser[1][17]
		cEmail += ALLTRIM(aUser[1,14])+';'
	ENDIF
    SY1->(dbskip())
Enddo

aUsers:=AllUsers()

For nX_ := 1 to Len(aUsers)
	If Len(aUsers[nX_][1][10]) > 0 .AND. !aUsers[nX_][1][17] //USUARIO BLOQUEADO
		aGrupo := {}
		//AADD(aGRUPO,aUsers[nX_][1][10])
		//FOR i:=1 TO LEN(aGRUPO[1])
		//	lAlmox := (aGRUPO[1,i] $ cAlmox)
		//NEXT
		//Ajuste nova rotina a antiga não funciona na nova lib MDI
		aGRUPO := UsrRetGrp(aUsers[nX_][1][2])
		IF LEN(aGRUPO) > 0
			FOR i:=1 TO LEN(aGRUPO)
				lAlmox := (ALLTRIM(aGRUPO[i]) $ cAlmox )
			NEXT
		ENDIF	
    	If lAlmox
    		cAlEmail += ALLTRIM(aUsers[nX_][1][14])+";"
    	ENDIF
 	ENDIF
NEXT

IF !EMPTY(cAlEmail)
	cEmail += cAlEmail
ENDIF

//Monta corpo do email Solicitação de Compras
_cXXENDEN := ""  
DbSelectArea("SC1")
SC1->(DbSetOrder(1))
SC1->(DbSeek(xFilial("SC1")+cNumSol,.T.))
Do While SC1->(!eof()) .AND. SC1->C1_NUM == cNumSol
	IF EMPTY(_cXXENDEN) .AND. !EMPTY(SC1->C1_XXENDEN)
		_cXXENDEN := SC1->C1_XXENDEN
	ENDIF
	IF SC1->C1_QUANT-SC1->C1_XXQEST > 0
    	AADD(aEmail,{SC1->C1_NUM,SC1->C1_SOLICIT,SC1->C1_ITEM,SC1->C1_PRODUTO,SC1->C1_DESCRI,SC1->C1_UM,SC1->C1_QUANT-SC1->C1_XXQEST,SC1->C1_DATPRF,SC1->C1_OBS,SC1->C1_CC,SC1->C1_XXDCC,SC1->C1_QUJE}) //aMotivo[val(SC1->C1_XXMTCM)]})
    ENDIF
    IF SC1->C1_APROV == "B"
    	lAprov := .F.
    ENDIF
    SC1->(dbskip())
Enddo

IF lAprov
	//Adiciona Endereço de Entrega
	IF 	!EMPTY(_cXXENDEN)
    	_cXXEN := ""
		_nXXEN := 0
		_nXXEN := MLCOUNT(_cXXENDEN,80)
		FOR xi := 1 TO _nXXEN
   			_cXXEN += MemoLine(_cXXENDEN,80,xi)+" "
		NEXT    
		AADD(aEmail,{"<b>Endereço de Entrega: </b>"+_cXXEN+"</blockquote>"})  
		
	ENDIF
               
	cAssunto:= "Solicitação de Compra Alterada nº.:"+alltrim(cNumSol)+"       "+DTOC(DATE())+"-"+TIME()+" - "+ALLTRIM(SM0->M0_NOME)
	aCabs   := {"Cod. SC.","Solicitante","Ítem","Cod.Prod","Desc.Prod.","UM","Quant.","Data Limite Entrega","OBS","Centro de Custo","Descr. Centro de Custo"}//"Motivo"}
	cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,"BKESTA01")
	IF 	!EMPTY(_cXXENDEN)
		cMsg    := STRTRAN(cMsg,"><b>Endereço de Entrega:"," colspan="+str(len(aCabs))+'><blockquote style="text-align:left;font-size:14.0"><b>Endereço de Entrega:')
    ENDIF
	U_SendMail("BKESTA01",cAssunto,cEmail,cEmailCC,cMsg,cAnexo,_lJob)
ENDIF

Return Nil
             