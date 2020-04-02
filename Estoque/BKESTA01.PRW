#include "totvs.ch"
#include "protheus.ch"
#include "TopConn.ch"
 
/*/{Protheus.doc} BKCOMR12
BK - Rotina para gerar solicitação ao Armazem de uma solicitação de Compras

@Return
@author Adilson do Prado
@since 28/03/17 
@version P11/P12
/*/


User Function BKESTA01(aSaldos)
Local aArea     := GetArea()

PRIVATE dDataMov := dDATABASE
PRIVATE cCC      := aSaldos[1,09]
PRIVATE cDCC 	 := aSaldos[1,10]
PRIVATE cSolict  := aSaldos[1,11]


MsgRun("Aguarde, gerando Solicitação ao Estoque - Almoxarifado…","",{|| CursorWait(), lRet := fProcessa1(aSaldos) ,CursorArrow()})

RestArea(aArea)

Return Nil

 

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
             