#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} MA140BUT
BK - Ponto de Entrada para incluir botão na enchoice da Pré-Nota
@Return
@author Marcos Bispo Abrahão
@since 16/07/24
@version P12
/*/

User Function MA140BUT()
Local aBotao := {}

aBotao := {{"BK Copia e Cola Itens",{|| U_CA140Dlg()},"Incluir Itens via copia e cola"}}

Return aBotao


User Function CA140Dlg()
Local aAreaAtu	:= GetArea()
Local oDlg01	As Object
Local aButtons 	:= {}
Local lOk 		:= .F.
Local nSnd    	:= 0
Local nTLin 	:= 15
Local nSin    	:= 5
Local cTexto	:= "" 

Define MsDialog oDlg01 Title "Importação de dados: Excel --> Pré-Nota" From 000,000 To 260+(nSin*nTLin),600 Of oDlg01 Pixel

nSnd := 35
@ nSnd,010 Say 'Cole as colunas do excel: Codigo do Produto,Valor,Centro de Custos'  Size 240,010 Pixel Of oDlg01
nSnd += nTLin
oMemo:= tMultiget():New(nSnd,10,{|u|if(Pcount()>0,cTexto :=u,cTexto )},oDlg01,280,100,,,,,,.T.)
nSnd += nTLin

ACTIVATE MSDIALOG oDlg01 CENTERED ON INIT EnchoiceBar(oDlg01,{|| lOk:= .T.,oDlg01:End()},{|| lOk:=.F., oDlg01:End()}, , aButtons)

If ( lOk )
	lOk := VldGrvD1(cTexto)
EndIf

RestArea( aAreaAtu )

Return lOk


Static Function VldGrvD1(cTexto)
Local nI 		:= 0
Local lOk 		:= .T.
Local cLinha	:= ""
Local cDesc 	:= ""
Local cCod  	:= ""
Local cValor	:= ""
Local nValor 	:= 0
Local cCC1      := ""
Local cDescCC   := ""
Local nTamTex	:= 0
Local cErro 	:= ""
Local aLinha    := {}
Local lErro		:= .F.
Local yCol		:= {}
Local xCol		:= {}
Local nPItem    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEM"})
Local nPCod     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
Local nPQuant   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})
Local nPVUnit   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})
Local nPTotal   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})
Local nPCC      := aScan(aHeader,{|x| AllTrim(x[2])=="D1_CC"})
Local nPXXDescP := aScan(aHeader,{|x| AllTrim(x[2])=="D1_XXDESCP"})
Local nPUM      := aScan(aHeader,{|x| AllTrim(x[2])=="D1_UM"})
Local nPCONTA   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_CONTA"})
//Local nPTP      := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TP"})
//Local nPCodIss  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_CODISS"})
Local nPXXDCC   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_XXDCC"})
Local nPLocal   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_LOCAL"})
//Local nPClasFis := aScan(aHeader,{|x| AllTrim(x[2])=="D1_CLASFIS"})

nTotGeral 	:= 0
cTexto  	:= FwNoAccent(cTexto) 
nTamTex 	:= mlCount(cTexto, 200)
xCol 		:= aClone(aCols[1])

For nI := 1 To nTamTex
	cLinha := TRIM(memoline(cTexto, 200, nI))
	If !Empty(cLinha)
		lErro	:= .F.
        cLinha  := STRTRAN(cLinha,CHR(9)," ")
        Do While ("  " $ cLinha)
            cLinha := STRTRAN(cLinha,"  "," ")
        EndDo

		aLinha  := StrToKArr(cLinha," ")
		cCod    := PAD(ALLTRIM(aLinha[1]),Len(SB1->B1_COD))
		cValor  := ALLTRIM(aLinha[2])
        cCC1    := PAD(ALLTRIM(aLinha[3]),Len(SD1->D1_CC))
		If Len(ALLTRIM(cCC1)) < 9
			cCC1 := PAD(STRZERO(VAL(ALLTRIM(cCC1)),9),Len(SD1->D1_CC))
		EndIf
			
		// Valor
		cValor  := STRTRAN(cValor,".","")
		cValor  := STRTRAN(cValor,",",".")
		nValor  := VAL(cValor)
		cDesc 	:= ""
		If !EMPTY(cCod)
			If SB1->(DbSeek(xFilial("SB1")+cCod))
				cDesc := SB1->B1_DESC
			EndIf
		EndIf	

		If Empty(cCod) .OR. Empty(cDesc)
			cErro += STRZERO(nI,4)+" Produto: "+cCod+" não encontrado"+CRLF
			lErro := .T.
		EndIf
		If nValor == 0
			cErro += STRZERO(nI,4)+" Produto: "+cCod+" sem valor informado"+CRLF
			lErro := .T.
		EndIf

        cDescCC := ""
		If !EMPTY(cCC1)
			cDescCC := Posicione("CTT",1,xFilial("CTT")+cCC1,"CTT_DESC01")
		EndIf	

		If Empty(cCC1) .OR. Empty(cDescCC)
			cErro += STRZERO(nI,4)+" Produto: "+cCod+" Centro de Custos "+cCC1+" não encontrado"+CRLF
			lErro := .T.
		EndIf

        If !lErro
		    If nI == 1
				aCols[1,nPCod]		:= cCod
				aCols[1,nPQuant]	:= 1
				aCols[1,nPVUnit]	:= nValor
				aCols[1,nPTotal]	:= nValor
				aCols[1,nPXXDescP]	:= cDesc
				aCols[1,nPUM]		:= SB1->B1_UM
				aCols[1,nPCONTA]	:= SB1->B1_CONTA
				aCols[1,nPCC]		:= cCC1
				aCols[1,nPXXDCC]	:= cDescCC
				aCols[1,nPLocal] 	:= SB1->B1_LOCPAD
			Else
				yCol := aClone(xCol)
				yCol[nPItem]    := STRZERO(Len(aCols)+1,4)
				yCol[nPCod]     := cCod
				yCol[nPQuant]   := 1
				yCol[nPVUnit]   := nValor
				yCol[nPTotal]   := nValor
				yCol[nPXXDescP] := cDesc
				yCol[nPUM]      := SB1->B1_UM
				yCol[nPCONTA]   := SB1->B1_CONTA
				yCol[nPCC]      := cCC1
				yCol[nPXXDCC]   := cDescCC
				yCol[nPLocal] 	:= SB1->B1_LOCPAD
				//yCol[nPClasFis] := SUBS(SB1->B1_ORIGEM,1,1)+SF4->F4_SITTRIB                                                            
                aAdd(aCols,yCol)
            EndIf
        EndIf
	EndIf
Next

If !Empty(cErro)
	u_MsgLog("VldGrvD1",cErro,"E")
	//lOk := .F.
EndIf

Return lOk

