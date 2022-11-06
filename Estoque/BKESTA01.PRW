#include "totvs.ch"
#include "protheus.ch"
#include "TopConn.ch"
 
/*/{Protheus.doc} BKESTA01
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

u_MsgLog("BKESTA01")

MsgRun("Aguarde, gerando Solicitação ao Estoque - Almoxarifado…","",{|| CursorWait(), lRet := fProcessa1(aSaldos) ,CursorArrow()})

RestArea(aArea)

Return Nil

 

Static Function fProcessa1(aSaldos)

Local nY
Local aCabec := {}
Local aItens := {}
Local lItem  := .F.
Local cErrLog:= ""

Private lMsErroAuto := .F.

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
			cErrLog:= CRLF+MostraErro("\TMP\","BKESTA01.ERR")
			u_xxLog("\LOG\BKESTA01.LOG",cErrLog)
			MsgStop("Problemas na execução do MsExecAuto, informe o setor de T.I.:"+cErrLog,"Atenção")
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
				U_EMAILSOL(aItens[1][7][2],"BKESTA01")
			ENDIF
		EndIf
	ENDIF

END TRANSACTION

Return .T. 


User Function EMAILSOL(cNumSol,cPrw)
Local cAssunto	:= ""
Local cEmail	:= "microsiga@bkconsultoria.com.br;"
Local cEmailCC  := ""
Local cEmailU   := ""
Local cMsg 		:= "" 
Local cAnexo	:= ""
Local _lJob		:= .T.
Local aCabs		:= {}
Local aEmail	:= {}
Local aMotivo	:= {} 
Local lAprov	:= .T.
//Local lAlmox	:= .F.
//Local aGrupo	:= {}
//Local cAlEmail	:= ""
//Local aUsers 	:= {}
//Local cAlmox 	:= ALLTRIM(SuperGetMV("MV_XXGRALX",.F.,"000021"))+"/"+ALLTRIM(SuperGetMV("MV_XXMSALX",.F.,"000027"))
Local _cXXENDEN := ""
Local _cXXEN 	:= ""
Local _nXXEN 	:= 0
//Local nX_		as Numeric
Local i			as Numeric

AADD(aMotivo,"Início de Contrato")
AADD(aMotivo,"Reposição Programada")
AADD(aMotivo,"Reposição Eventual")

cEmailU := ALLTRIM(UsrRetMail(__CUSERID))
IF !EMPTY(cEmailU)
	cEmail += cEmailU+';'
ENDIF

SY1->(dbgotop())
Do While SY1->(!eof())                                                                                                               
	cEmailU := ALLTRIM(UsrRetMail(SY1->Y1_USER))
	IF !EMPTY(cEmailU) .AND. !cEmailU $ cEmail
		cEmail += cEmailU+';'
	ENDIF
    SY1->(dbskip())
Enddo

cEmail += u_EmEstAlm(__cUserID,.T.,cEmail)
//cEmail += u_EmGerCom(cEmail)

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
		FOR i := 1 TO _nXXEN
   			_cXXEN += MemoLine(_cXXENDEN,80,i)+" "
		NEXT    
		AADD(aEmail,{"<b>Endereço de Entrega: </b>"+_cXXEN+"</blockquote>"})  
		
	ENDIF
               
	cAssunto:= "Solicitação de Compra Alterada nº.:"+alltrim(cNumSol)+"       "+DTOC(DATE())+"-"+TIME()+" - "+FWEmpName(cEmpAnt)
	aCabs   := {"Cod. SC.","Solicitante","Ítem","Cod.Prod","Desc.Prod.","UM","Quant.","Data Limite Entrega","OBS","Centro de Custo","Descr. Centro de Custo"}//"Motivo"}
	cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,"BKESTA01")
	IF 	!EMPTY(_cXXENDEN)
		cMsg    := STRTRAN(cMsg,"><b>Endereço de Entrega:"," colspan="+str(len(aCabs))+'><blockquote style="text-align:left;font-size:14.0"><b>Endereço de Entrega:')
    ENDIF
	U_SendMail(cPrw,cAssunto,cEmail,cEmailCC,cMsg,cAnexo,_lJob)
	u_MsgLog(cPrw,cAssunto+" "+cEmail)
ENDIF

Return Nil
             