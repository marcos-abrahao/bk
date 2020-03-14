#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE "topconn.ch"

// Ponto de entrada para Bloquear NF de Entrada
// 26/05/15 - Marcos B Abrahão

User Function A103BLOQ()
Local lRet      := .F. 
Local nMax      := 0
Local nI        := 0
Local lEst      := .F.
Local cTeste    := ""
Local aAprov    := {}
Local aAKUser   := {}
Local aAreaIni  := GetArea()
Local aAreaSAK  := GetArea("SAK")
Local aAreaSAL  := GetArea("SAL")
Local cFilSal   := xFilial("SAL")
Local nValBlq   := 999999999.99
Local cUserId   := RetCodUsr()  // Dicionario no banco

lRet := PARAMIXB[1]

If !lRet
	nMax := Len(PROCNAME())
	
	// Processa todo conteudo de nMax para encontrar a rotina de estorno de classificação			 
	For nI:= 0 To nMax
		cTeste := Procname(nI)
		If ALLTRIM(UPPER(cTeste)) == "A140ESTCLA"  // Estorno de classificação
			lEst := .T.
			EXIT
		Endif
	Next
	
	If lEst 
		// Remover aprovador para não classificar sem bloqueio
		lRet := .F.

		If !EMPTY(SF1->F1_APROV)
		
			dbSelectArea("SAL")
			dbSeek(cFilSal+SF1->F1_APROV,.T.)
			Do While SAL->AL_FILIAL+SAL->AL_COD == cFilSal+SF1->F1_APROV
			    AADD(aAprov,SAL->AL_APROV)
				dbSkip()
			EndDo
			
			dbSelectArea("SAK") 
			dbSetOrder(1)
			For nI := 1 TO LEN(aAprov)
				If dbSeek(cFilSal+aAprov[nI],.F.)
					If cUserId <> SAK->AK_USER .AND. aAprov[nI] $ '000013/000014' //enviar e-mail apenas para Sr. Marcio e Xavier
					    AADD(aAKUser,SAK->AK_USER)
					EndIf
					If SAK->AK_LIMMIN > 0 .AND. SAK->AK_LIMMIN < nValBlq 
						nValBlq := SAK->AK_LIMMIN
					EndIf		
				EndIf   
			Next
			EnvAvBlq(aAKUser,SF1->F1_VALBRUT,nValBlq,.T.)
		
		    RecLock("SF1",.F.)
			SF1->F1_APROV := ""
			SF1->(MsUnlock())
		EndIf
	Else
		lRet := .T. 
		// Se tiver aprovador, é porque já foi aprovado
		If !EMPTY(SF1->F1_APROV)
			lRet := .F.
		Else
		    // Aqui, verificar valores
			lRet := U_BlqDoc(U_GetValTot(),.F.)
			//If lRet
			//	MsgAlert("Este documento foi bloqueado, aguarde a liberação e classifique-o novamente. ")
			//EndIf
		EndIf

	EndIf
EndIf

RestArea(aAreaSAK)	
RestArea(aAreaSAL)	
RestArea(aAreaIni)	

Return lRet


User Function BlqDoc(_nValDoc,lTela)
Local aAreaSAK  := GetArea("SAK")
Local aAreaSAL  := GetArea("SAL")
Local lBlq      := .F.
Local cFilSal   := xFilial("SAL")
Local aAprov    := {}
Local aAKUser   := {}
Local nI        := 0
Local nValBlq   := 999999999.99
Local nValApr   := 0
Local lAprovador:= .F.
Local cMvNfAprov:= SuperGetMV("MV_NFAPROV",.F.,"000002")
Local cUserId   := RetCodUsr()

dbSelectArea("SAL")
dbSeek(cFilSal+cMvNfAprov,.T.)
Do While SAL->AL_FILIAL+SAL->AL_COD == cFilSal+cMvNfAprov
    AADD(aAprov,SAL->AL_APROV)
	dbSkip()
EndDo

dbSelectArea("SAK") 
dbSetOrder(1)
For nI := 1 TO LEN(aAprov)
	If dbSeek(cFilSal+aAprov[nI],.F.)
		If cUserId == SAK->AK_USER
			nValApr := SAK->AK_LIMMAX
			lAprovador:= .T.
		ElseIF aAprov[nI] $ '000013/000014'  //enviar e-mail apenas para Sr. Marcio e Xavier
		    AADD(aAKUser,SAK->AK_USER)
		EndIf
		If SAK->AK_LIMMIN > 0 .AND. SAK->AK_LIMMIN < nValBlq 
			nValBlq := SAK->AK_LIMMIN
		EndIf		
	EndIf   
Next

			
If _nValDoc > nValBlq .AND. nValBlq > 0
	lBlq := .T.
	If _nValDoc < nValApr .AND. nValApr > 0 .AND. lAprovador
		lBlq := .F.
	EndIf
	If lBlq .AND. !lTela
		// Envia aviso de bloqueio
		EnvAvBlq(aAKUser,_nValDoc,nValBlq,.F.)
	EndIf

EndIf

RestArea(aAreaSAK)	
RestArea(aAreaSAL)	
Return lBlq


// Devolve valor do Total do D1_TOTAL (F1_VALBRUT está zerado neste momento)
USER Function GetValTot(lPedid)
Local cQuery2  := ""
Local cAliasD1 := GetNextAlias()
Local nValTot  := 0

DEFAULT lPedid := .T. 

cQuery2 := "SELECT SUM(D1_TOTAL) AS D1TOTAL, MIN(D1_PEDIDO) AS D1PEDIDO "
cQuery2 += " FROM "+RETSQLNAME("SD1")+" SD1" 
cQuery2 += " WHERE SD1.D1_FILIAL='"+xFilial('SD1')+"' AND SD1.D_E_L_E_T_=''"
cQuery2 += "       AND SD1.D1_DOC='"+SF1->F1_DOC+"' AND SD1.D1_SERIE='"+SF1->F1_SERIE+"'"
cQuery2 += "       AND SD1.D1_FORNECE='"+SF1->F1_FORNECE+"' AND SD1.D1_LOJA='"+SF1->F1_LOJA+"'"
	        
TCQUERY cQuery2 NEW ALIAS (cAliasD1)
TCSETFIELD(cAliasD1,"D1TOTAL","N",18,2)

dbSelectArea(cAliasD1)
dbGoTop()
nValTot := (cAliasD1)->D1TOTAL
If !EMPTY((cAliasD1)->D1PEDIDO) .AND. lPedid
	nValTot := 0
EndIf
(cAliasD1)->(DbCloseArea())
Return nValTot


// Envia email avisando do bloqueio
Static Function EnvAvBlq(_aAKUser,_nValDoc,_nValBlq,_lCanc)
Local cAssunto	:= ""
Local cEmail	:= "microsiga@bkconsultoria.com.br;"
Local cEmailCC  := ""
Local cMsg 		:= "" 
Local cAnexo	:= ""
Local _lJob		:= .F.
Local aCabs		:= {}
Local aEmail	:= {}
Local nI        := 0

For nI := 1 TO LEN(_aAKUser)
	PswOrder(1) 
	PswSeek(_aAKUser[nI]) 
	aUser  := PswRet(1)
	If !EMPTY(aUser[1,14])  .AND. !aUser[1][17]
		cEmail += ALLTRIM(aUser[1,14])+';'
	EndIf
Next			

dbSelectArea("SA2")
dbSetOrder(1)
dbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)

If _lCanc	
	cAssunto:= "Estorno de classificação de Nota Fiscal liberada nº.:"+SF1->F1_DOC+" Série:"+SF1->F1_SERIE+"    Fornecedor: " +SA2->A2_COD+"-"+SA2->A2_LOJA+" - "+SA2->A2_NOME+"   "+DTOC(DATE())+"-"+TIME()+" - "+ALLTRIM(SM0->M0_NOME)
	aCabs   := {"Nota Fiscal nº.:","Série:"," Cod.For.:"," Loja:","Valor:","Limite:","Usuário"}
	AADD(aEmail,{SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,_nValDoc,_nValBlq,UsrFullName(RetCodUsr())})
Else

	cAssunto:= "Solicitação de Liberação de Nota Fiscal nº.:"+SF1->F1_DOC+" Série:"+SF1->F1_SERIE+"    Fornecedor: " +SA2->A2_COD+"-"+SA2->A2_LOJA+" - "+SA2->A2_NOME+"   "+DTOC(DATE())+"-"+TIME()+" - "+ALLTRIM(SM0->M0_NOME)

	aEmail := {}
	AADD(aEmail,{"Solicitante:"+UsrFullName(RetCodUsr())})
	AADD(aEmail,{"Fornecedor: "+SA2->A2_COD+"-"+SA2->A2_LOJA+" - "+SA2->A2_NOME,,,,,,"Total da NF:",_nValDoc,,})
	
	cHIST:= ""
	dbSelectArea("SD1") 
   	dbSetOrder(1)
	dbSeek(xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
	DO WHILE !EOF() .AND. xFilial('SD1')+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == ; 
			SD1->D1_FILIAL+SD1->D1_DOC+ SD1->D1_SERIE+ SD1->D1_FORNECE+ SD1->D1_LOJA

		AADD(aEmail,{"",SD1->D1_ITEM,SD1->D1_COD,SD1->D1_XXDESCP,SD1->D1_UM,SD1->D1_QUANT,SD1->D1_VUNIT,SD1->D1_TOTAL,SD1->D1_CC,SD1->D1_XXDCC})
		cHIST += IIF(SD1->D1_XXHIST $ cHIST,"",cHIST) 
		SD1->(dbskip())
	Enddo
  	AADD(aEmail,{"<b>Histórico: </b>"+cHIST})

	aCabs   := {}
	aCabs   := {"Solicitante/Fornecedor","Item","Cod. Produto","Descr. Produto","UM","Quant.","Valor Unit.","Total Item","Centro de Custo","Descr. Centro de Custo"}

EndIf


cMsg    := u_GeraHtmA(aEmail,cAssunto,aCabs,"A103BLOQ")
cMsg    := STRTRAN(cMsg,"><b>Histórico:"," colspan=10 ><b>Histórico:")
U_SendMail("A103BLOQ",cAssunto,cEmail,cEmailCC,cMsg,cAnexo,_lJob)
	
Return( NIL )
