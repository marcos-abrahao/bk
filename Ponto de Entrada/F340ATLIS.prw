#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} F340ATLIS
F340ATLIS - Manipulação de Array na tela de compensação
@Return
@author Marcos Bispo Abrahão
@since 18/06/2021
@version P12.1.25
/*/

User Function F340ATLIS()
Local aTitulos := PARAMIXB[1]   // Opção Escolhida pelo usuario 

If MsgYesNo("Deseja filtrar e marcar títulos?","BK - F340ATLIS")
    BK340Filt(aTitulos)
EndIf

Return aTitulos



Static Function BK340Filt(aTitulos)
Local oOk
Local oNo
Local oDlg
Local oPanelLeft
Local aButtons 	:= {}
Local lOk      	:= .F.
Local cTitulo2 	:= "BK340Filt - Filtrar títulos a compensar:"
Local oGetNF    AS object
Local oGetSer   AS object
Local nLin      := 10

Static cPartNF  := SPACE(LEN(SE2->E2_NUM))
Static cPrefix  := SPACE(LEN(SE2->E2_PREFIXO))

oOk := LoadBitmap( GetResources(), "LBTIK" )
oNo := LoadBitmap( GetResources(), "LBNO" )

Aadd( aButtons, {"RELATORIO", {|| BK340Pl(aTitulos,cPartNF,cPrefix)}, "Planilha", "Planilha" , {|| .T.}} )  

DEFINE MSDIALOG oDlg TITLE cTitulo2 FROM 000,000 TO 240,550 PIXEL
@ 000,000 MSPANEL oPanelLeft OF oDlg SIZE 530,230  // P12
oPanelLeft:Align := CONTROL_ALIGN_LEFT

@ nLin,010 SAY 'Nº Titulo contém:' PIXEL SIZE 50,10 OF oPanelLeft
@ nLin,070 MSGET oGetNF VAR cPartNF OF oPanelLeft PICTURE "@!" SIZE 50,10 PIXEL 
nLin += 25

@ nLin,010 SAY 'Série contém:' PIXEL SIZE 50,10 OF oPanelLeft
@ nLin,070 MSGET oGetSer VAR cPrefix OF oPanelLeft PICTURE "@!"  SIZE 50,10 PIXEL 

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| lOk:=.T., oDlg:End()},{|| oDlg:End()}, , @aButtons)

If lOk
  BK340Cp(aTitulos,cPartNF,cPrefix)
EndIf

RETURN lOk


// Processa o filtro e os valores a compensar
Static Function BK340Cp(aTitulos,cPartNF,cPrefix)
Local cxPartNF  := ""
Local cxPrefix  := ""
Local nL        := 0
Local nMovTit   := 0
Local nVlrLim   := 0

    cxPartNF := ALLTRIM(cPartNF)
    cxPrefix := ALLTRIM(cPrefix)

    nValTot  := 0

    For nL := 1 To Len(aTitulos)
        aTitulos[nL,8] := .F.
        If !Empty(cxPrefix) .AND. cxPrefix $ aTitulos[nL,1]
            aTitulos[nL,8] := .T.
        EndIf
        If !Empty(cxPartNF) .AND. cxPartNF $ aTitulos[nL,2]
            aTitulos[nL,8] := .T.
        EndIf

        If aTitulos[nL,8]

			If nValTot < nSaldo
				nVlrLim := DesTrans(aTitulos[nL][9])
							
				If (nValTot + nVlrLim) > nSaldo
					nMovTit := (nSaldo - nValTot)
				Else
					nMovTit := nVlrLim 
				EndIf
							
				aTitulos[nL,06] := Transform(nMovTit, "@E 9999,999,999.99")
				aTitulos[nL,20] := nMovTit
				aTitulos[nL,22] := nMovTit
				nValTot += nMovTit
            Else
                aTitulos[nL,08] := .F.
			EndIf

        EndIf

        If !aTitulos[nL,08]
            aTitulos[nL,06] := Transform(0, "@E 9999,999,999.99")
            aTitulos[nL,20] := 0
            aTitulos[nL,22] := 0
        Endif

    Next

Return Nil



/*/{Protheus.doc}fMarkAll (retirado do FINA340)
Marca ou Desmarca todos os titulos 
@author Cristiano Denardi
@since  05.04.05
@version 12
/*/
/* 
Static Function fMarkAll(aTit)
	Local nA := 0
	Local lValDocs := .T.
	Local lPrimeiro := .T.
	Local nAtit := 0
	Local nVlrLim := 0
	Local nMovTit := 0
	Local lMarca  := .T.
	
	Default aTit := {} 
	nAtit := Len(aTit)
	
	//Não permite selecionar vlr maior que o título de partida
	If nValTot >= __nTotal 
		lMarca   := .F.
		nValTot  := 0
	EndIf		
	
	For nA := 1 To nAtit
		lValDocs := .T.
		
		If lMarca
			If __lFinVDoc
				If !FA340ValDocs(aTit[nA],.T.,,,@lPrimeiro)
					lValDocs := .F.
				EndIf
			EndIf
			
			If lValDocs
				If F340Semaforo(aTit[nA],.T.,aRecno[nA])
					aTit[nA][8] := lMarca
					
					If cPaisLoc == "BRA"
						If nValTot < __nTotal
							nVlrLim := DesTrans(aTit[nA][9])
							
							If (nValTot + nVlrLim) > __nTotal
								nMovTit := (__nTotal - nValTot)
							Else
								nMovTit := nVlrLim 
							EndIf
							
							aTit[nA][6] := Transform(nMovTit, "@E 9999,999,999.99")
							aTit[nA][20] := nMovTit
							aTit[nA][22] := nMovTit
							nValTot += nMovTit
						EndIf
					Else
						aTit[nA][6] := aTit[nA][5]
						SCU->(DbSetOrder(2))
						
						If aTit[nA,4] == MVNOTAFIS .And. GetMv('MV_SOLNCP') .And. SCU->(MsSeek( xFilial()+SE2->E2_FORNECE+SE2->E2_LOJA+aTit[nA,2]+aTit[nA,1] )).And. Empty(SCU->CU_NCRED)
							aTit[nA][8]	:= .F.
							aTit[nA][6] := Transform(0, "@E 9999,999,999.99")
						Else
							nValTot += Fa340VTit(aTit[nA][6])
						Endif
					EndIf
					
					//Não permite selecionar vlr maior que o título de partida 
					If nValTot >= __nTotal
						exit
					EndIf						
				Endif
			EndIf
		Else
			F340Semaforo(aTit[nA], .F., aRecno[nA])
			aTit[nA][8] := lMarca
			aTit[nA][6] := Transform(0, "@E 9999,999,999.99")
			If cPaisLoc == "BRA"
				aTit[nA][20] := 0
				aTit[nA][22] := 0
			EndIF	
		Endif
	Next nA
	
Return(.T.)
*/



Static Function BK340Pl(aTitulos,cPartNF,cPrefix)
    
Local aCabec    := {}
Local aPlans    := {}
Local nI        := 0

For nI := 1 to len(aTitulos[1])
    aAdd(aCabec,STRZERO(nI,3))
Next

aCabec[01] := "Prefixo"
aCabec[02] := "Número"
aCabec[03] := "Parcela"
aCabec[04] := "Tipo"
aCabec[05] := "Saldo"
aCabec[06] := "Valor Compensado"
aCabec[07] := "Nome"
aCabec[08] := "Marcado"
aCabec[09] := "Limite de comp."
aCabec[10] := "Acréscimos"
aCabec[11] := "Decréscimos"
aCabec[12] := "Emissão"
aCabec[13] := "Vencimento"
aCabec[14] := "Fornecedor"
aCabec[15] := "Loja"
aCabec[22] := "Val Compensado"

BK340Cp(aTitulos,cPartNF,cPrefix)

AADD(aPlans,{aTitulos,"BK340Pl","Titulos a compensar",aCabec,/*aImpr1*/, /* aAlign */,/* aFormat */, /*aTotal */ })   
U_ArrToXlsx(aPlans,"Titulos a compensar","BK340Pl")

Return Nil


