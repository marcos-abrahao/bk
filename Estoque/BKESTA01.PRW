#include "totvs.ch"
#include "protheus.ch"
#include "TopConn.ch"
 
/*/{Protheus.doc} BKESTA01
BK - Rotina para gerar solicita��o ao Armazem de uma solicita��o de Compras

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

u_WaitLog("BKESTA01",{|| lRet := fProcessa1(aSaldos)},"Aguarde, gerando Solicita��o ao Estoque do amoxarifado�")

RestArea(aArea)

Return Nil

 

Static Function fProcessa1(aSaldos)

Local nY
Local aCabec := {}
Local aItens := {}
Local lItem  := .F.

Private lMsErroAuto := .F.

BEGIN TRANSACTION

	aCabec := {}
	aadd(aCabec,{"CP_FILIAL"  ,xFilial("SCP")    ,Nil}) // C�d da Filial
	aadd(aCabec,{"CP_NUM"     ,GETSXENUM("SCP","CP_NUM") ,Nil}) // Numero da SA (Calcular se necess�rio)
	aadd(aCabec,{"CP_SOLICIT" ,cSolict ,Nil}) // Nome do Solicitante (usu�rio logado)
	aadd(aCabec,{"CP_EMISSAO" ,dDataMov ,Nil}) // Data de Emiss�o

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
			u_LogMsExec()
			DisarmTransaction()
		ELSE
			FOR nY := 1 TO LEN(aItens)
				cQuery := "UPDATE "+RetSqlName("SC1")+" SET C1_QUJE=(C1_QUJE+"+STR(aItens[nY][2][2],TamSX3("C1_QUANT")[1],TamSX3("C1_QUANT")[2])+"),"
				cQuery += " C1_XXQEST="+STR(aItens[nY][2][2],TamSX3("C1_QUANT")[1],TamSX3("C1_QUANT")[2])+""
				cQuery += " FROM "+RetSqlName("SC1")+" SC1" 
				cQuery += " WHERE SC1.D_E_L_E_T_='' AND C1_NUM='"+aItens[nY][7][2]+"' AND C1_ITEM='"+aItens[nY][8][2]+"'"
				If TCSQLExec(cQuery) < 0 
					u_MsgLog(,TCSQLERROR(),"E")
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
Local cEmail	:= u_EmailAdm()
Local cEmailCC  := ""
Local cEmailU   := ""
Local cMsg 		:= "" 
Local cAnexo	:= ""
Local aCabs		:= {}
Local aEmail	:= {}
Local aMotivo	:= {} 
Local lAprov	:= .T.
Local _cXXENDEN := ""
Local _cXXEN 	:= ""
Local _nXXEN 	:= 0
Local i			as Numeric

AADD(aMotivo,"In�cio de Contrato")
AADD(aMotivo,"Reposi��o Programada")
AADD(aMotivo,"Reposi��o Eventual")

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

//Monta corpo do email Solicita��o de Compras
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
	//Adiciona Endere�o de Entrega
	IF 	!EMPTY(_cXXENDEN)
    	_cXXEN := ""
		_nXXEN := 0
		_nXXEN := MLCOUNT(_cXXENDEN,80)
		FOR i := 1 TO _nXXEN
   			_cXXEN += MemoLine(_cXXENDEN,80,i)+" "
		NEXT    
		AADD(aEmail,{"<b>Endere�o de Entrega: </b>"+_cXXEN+"</blockquote>"})  
		
	ENDIF
               
	cAssunto:= "Solicita��o de Compra Alterada n�.: "+alltrim(cNumSol)+" - "+FWEmpName(cEmpAnt)
	aCabs   := {"Cod. SC.","Solicitante","�tem","Cod.Prod","Desc.Prod.","UM","Quant.","Data Limite Entrega","OBS","Centro de Custo","Descr. Centro de Custo"}//"Motivo"}
	cMsg    := u_GeraHtmB(aEmail,cAssunto,aCabs,"BKESTA01","",cEmail,cEmailCC)
	IF 	!EMPTY(_cXXENDEN)
		cMsg    := STRTRAN(cMsg,"><b>Endere�o de Entrega:"," colspan="+str(len(aCabs))+'><blockquote style="text-align:left;font-size:14.0"><b>Endere�o de Entrega:')
    ENDIF

	cAnexo := cPrw+alltrim(cNumSol)+".html"
	u_GrvAnexo(cAnexo,cMsg,.T.)	
	u_BkSnMail(cPrw,cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)

	u_MsgLog(cPrw,cAssunto+" "+cEmail)
ENDIF

Return Nil
         