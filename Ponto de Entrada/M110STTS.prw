#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} M110STTS
BK - Ponto de Entrada para envio Solicitação de Compra aos compradores
@Return
@author Adilson do Prado
@since 14/02/13
@version P12
/*/
 
User Function M110STTS()
Local cNumSol	:= Paramixb[1]
Local cAssunto	:= ""
Local cEmail	:= u_EmailAdm()+IIF(cEmpAnt<>"20","wiliam.lisboa@bkconsultoria.com.br;","") // Barcas
Local cEmailCC  := ""
Local cMsg 		:= "" 
Local cAnexo	:= ""
Local aCabs		:= {}
Local aEmail	:= {}
Local aMotivo	:= {} 
Local lAprov	:= .T.
Local aSaldos 	:= {}
Local nSaldo 	:= 0
Local _i 		:= 0
Local _IX		:= 0

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

//Monta corpo do email Solicitação de Compras
DbSelectArea("SC1")
SC1->(DbSetOrder(1))
SC1->(DbSeek(xFilial("SC1")+cNumSol,.T.))
Do While SC1->(!eof()) .AND. SC1->C1_NUM == cNumSol
    AADD(aEmail,{SC1->C1_NUM,SC1->C1_SOLICIT,SC1->C1_ITEM,SC1->C1_PRODUTO,SC1->C1_DESCRI,SC1->C1_UM,SC1->C1_QUANT-SC1->C1_XXQEST,SC1->C1_DATPRF,SC1->C1_OBS,SC1->C1_CC,SC1->C1_XXDCC}) //aMotivo[val(SC1->C1_XXMTCM)]})
    IF SC1->C1_APROV == "B"
    	lAprov := .F.
    ENDIF
    SC1->(dbskip())
Enddo


/* 
IF INCLUI
	cAssunto:= "Solicitação de Compra incluída  nº.:"+alltrim(cNumSol)+DTOC(DATE())+"-"+TIME()
ELSEIF ALTERA 
	cAssunto:= "Solicitação de Compra alterada  nº.:"+alltrim(cNumSol)+DTOC(DATE())+"-"+TIME()
ELSEIF EXCLUI               
	cAssunto:= "Solicitação de Compra excluída  nº.:"+alltrim(cNumSol)+DTOC(DATE())+"-"+TIME()
ENDIF
*/
 
_nMax 	:= 0
_nMax 	:= Len(PROCNAME())

// Variavel logica utilizada em conjunto com nMax 											 
_lProc	:= .F.

// Processa todo conteudo de nMax para encontrar A110DELETA solicitacao de compras			 
For _i:= 0 To _nMax
	If Alltrim(PROCNAME(_i)) == "A110DELETA" 
		 _lProc := .T.
		 exit
	Endif
Next

aCabs   := {}
IF _lProc 
	cAssunto:= "Solicitação de Compra excluída  nº.:"+alltrim(cNumSol)+" - "+FWEmpName(cEmpAnt)
	aCabs   := {"Cod. SC.","Solicitante","Ítem","Cod.Prod","Desc.Prod.","UM","Quant.","Data Limite Entrega","OBS","Centro de Custo","Descr. Centro de Custo"}//"Motivo"}
	cMsg    := u_GeraHtmB(aEmail,cAssunto,aCabs,"M110STTS","",cEmail,cEmailCC)
	cAnexo := "M110STTS"+alltrim(cNumSol)+".html"
	u_GrvAnexo(cAnexo,cMsg,.T.)	
	u_BkSnMail("M110STTS",cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)
ELSE
	IF lAprov 
		aSaldos := {}
		FOR _IX:= 1 TO LEN(aEmail)
			nSaldo := 0
			nSaldo := CalcEst(aEmail[_IX,4],"01", dDataBase+1)
			If ValType(nSaldo) == "N"
				IF nSaldo > 0
					AADD(aSaldos,{aEmail[_IX,3],aEmail[_IX,3],aEmail[_IX,4],aEmail[_IX,5],aEmail[_IX,6],aEmail[_IX,7],nSaldo})
				ENDIF
			EndIf
	    NEXT
	    IF LEN(aSaldos) > 0
	    	/*
			IF MsgYesNo("Produtos da solicitação em estoque. Deseja utilizalos??")
	    	   U_BKSADO(aSaldos)
	    	ENDIF
			*/
	    ENDIF            
		cAssunto:= "Solicitação de Compra nº.:"+alltrim(cNumSol)+" - "+FWEmpName(cEmpAnt)
		aCabs   := {"Cod. SC.","Solicitante","Ítem","Cod.Prod","Desc.Prod.","UM","Quant.","Data Limite Entrega","OBS","Centro de Custo","Descr. Centro de Custo"}//"Motivo"}
		cMsg    := u_GeraHtmB(aEmail,cAssunto,aCabs,"M110STTS","",cEmail,cEmailCC)

		cAnexo := "M110STTS"+alltrim(cNumSol)+".html"
		u_GrvAnexo(cAnexo,cMsg,.T.)	
		u_BkSnMail("M110STTS",cAssunto,cEmail,cEmailCC,cMsg,{cAnexo},.T.)
	ENDIF
ENDIF

Return Nil
