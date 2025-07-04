#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"       

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINR24
BK - Impress�o da Nota de D�bito - HTML
@Return
@author Marcos Bispo Abrah�o
@since 24/09/2019
@version P11
/*/
//-------------------------------------------------------------------
User Function BKSELR24() 
IF SE1->E1_PREFIXO == "MED"
	u_WaitLog(,{|| U_BKFINR35(),"Gerando pag�na web..."})
Else
	u_WaitLog(,{|| U_BKFINR24(),"Gerando pag�na web..."})
ENDIF
Return Nil


User Function BKFINR24() 
Local aArea     := GetArea()
Local cCrLf     := Chr(13) + Chr(10)
Local aHtml     := {}
Local nI        := 0
Local cHtml 	:= ""
Private cProg   := "BKFINR24"

IF SE1->E1_TIPO <> "NDC"
 	u_MsgLog(cProg,"Titulo selecionado n�o � Tipo NDC!","E")
	RETURN NIL
ENDIF
u_MsgLog(cProg)

aHtml := NdcHtml()   

RestArea(aArea)

If Len(aHtml) > 0
      
	FOR nI := 1 TO LEN(aHtml)
		cHtml += aHtml[nI] + cCrLf
	NEXT
      
	u_TmpHtml(cHtml,cProg,.T.)

EndIf

Return




Static Function NdcHtml()
Local aHtml     := {}
Local nPag      := 1
Local cLogo     := ""
Local nI        := 0
Local cPict     := "@E 99,999,999,999.99"

// Dados da Empresa/Filial
Local cNomeCom  := ALLTRIM(SM0->M0_NOMECOM)
Local cEndereco := ALLTRIM(SM0->M0_ENDENT) + IIF(!EMPTY(SM0->M0_COMPENT)," - "+ALLTRIM(SM0->M0_COMPENT),"")
Local cCep      := "CEP: "+TRANSFORM(SM0->M0_CEPENT,"@R 99999-999")
Local cCidade   := ALLTRIM(SM0->M0_CIDENT)+" - "+SM0->M0_ESTENT
Local cTel      := "TEL: "+ALLTRIM(SM0->M0_TEL)
Local cCnpj     := "CNPJ: "+TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99")
Local cIE       := "I.E.: "+ALLTRIM(SM0->M0_INSC)
Local cSite     := IIF(SM0->M0_CODIGO == "01","WWW.BKCONSULTORIA.COM.BR","")

// Dados do CLiente
Local cNomeCli  := ""
Local cEndCli   := ""
Local cMunCli   := ""
Local cUFCli    := ""
Local cCepCli   := ""
Local cCNPJCli  := ""
Local cTipoTit  := "NOTA DE D�BITO"

// Dados da NDC
Local cEmissao  := DTOC(SE1->E1_EMISSAO)
Local cVencto   := DTOC(SE1->E1_VENCTO)
Local cNDR      := ALLTRIM(SE1->E1_NUM)                
                     
Local cContra   := SE1->E1_XXCUSTO
Local cDescCtr  := SE1->E1_XXCUSTO
Local cRev      := SE1->E1_XXREV

Local cTipoNDC  := "1"
Local cRefComp  := ""
Local cTaxa     := ""
Local cTotal    := ""
Local cConta	:= ""

// Itens
Local nTamTex   := 0
Local cTexto    := SE1->E1_XXNDDES
Local aLin1     := {}
Local aItens    := {}
Local lColRdv   := .F.
Local lColFinal := .F.
Local lColVunit := .F.
Local cItem		:= ""
Local cTexUn	:= ""
Local nItens	:= 0
Local cVunit	:= ""
Local nVUnit	:= 0
Local nQuant	:= 0
Local cVTot		:= 0
Local aTabSX5   := {}

If SE1->E1_TIPO <> "NDC"
 	//cTipoTit := Posicione("SX5",1,xFilial("SX5")+"05"+SE1->E1_TIPO,"X5_DESCRI")
	aTabSX5 := FWGetSX5("05", PadR(SE1->E1_TIPO, TamSx3("X5_CHAVE")[1]))
	If Len(aTabSX5) > 0
		cTipoTit := aTabSX5[1,4]
	EndIf
EndIf


// Simula��o Tipo 1
/*
1|SAO PAULO - 02/2021|0.00|5.605,00
BRUNO BRITO DE JESUS|11/02/2021|  /  /    |1.00||796,50
BRUNO BRITO DE JESUS|18/02/2021|  /  /    |1.00||796,50
BRUNO BRITO DE JESUS|25/02/2021|  /  /    |1.00||560,50
CARLOS ROBERTO DE SOUZA|05/02/2021|  /  /    |1.00||265,50
CLAYTON BATISTA FABIANO|05/02/2021|  /  /    |1.00||619,50
CLAYTON BATISTA FABIANO|11/02/2021|  /  /    |1.00||265,50
CLAYTON BATISTA FABIANO|18/02/2021|  /  /    |1.00||265,50
CLAYTON BATISTA FABIANO|18/02/2021|  /  /    |1.00||796,50
CLAYTON BATISTA FABIANO|18/02/2021|  /  /    |1.00||265,50
CLAYTON BATISTA FABIANO|25/02/2021|  /  /    |1.00||973,50
*/

// Simula��o Tipo 2
/*
2|OUTUBRO 2020.|0,00|60.427,45
REEMBOLSO - DECRETO - 59.321 - COVID 19 - COMPETENCIA - OUTUBRO / 2020 - PER�ODO DESUSPENS�O : 01/10/2020 A 15/10/2020.
*/

// Simula��o Tipo 3
/*
3|AS HOSPEDAGENS DE 19/01  A 17/02|1.03|2.900,00|1
MARCELO KRUMEL|19/01/2021|17/02/2021|30.00|RDV 001|2.900,00
REF. A RDV/001-GEHITE-PA/2021
*/


nTamTex := mlCount(cTexto, 254)
	
For nI := 1 To nTamTex
	cLinha := memoline(cTexto, 254, nI)
	If nI == 1
		aLin1 := U_StringToArray(cLinha,"|")
		cTipoNDC := aLin1[1]
		cRefComp := aLin1[2]
		cTaxa    := aLin1[3]
		cTotal   := aLin1[4]
		If LEN(aLin1) > 4
			nItens := VAL(aLin1[5])
		Endif
	Else
		If cTipoNDC == "3"
			If nI <= nItens + 1
				If !Empty(cLinha)
					AADD(aItens,U_StringToArray(cLinha,"|"))
				EndIf
			Else
				cTexUn += cLinha +'<br>'
			EndIf
		Else
			If !Empty(cLinha)
				AADD(aItens,U_StringToArray(cLinha,"|"))
			EndIf
			cTexUn += cLinha +'<br>'
		EndIf
	EndIf
Next

If LEN(aLin1) > 0
//Else
//   MsgStop("Erro")
//   Return aHtml

	If cTipoNDC <> "2"
		For nI := 1 To Len(aItens)
		    If !Empty(aItens[nI,3]) .AND. !Empty(CTOD(aItens[nI,3]))
		    	lColFinal := .T.
		    EndIf
		    If !Empty(aItens[nI,5]) .AND. ALLTRIM(aItens[nI,5]) <> "."
		    	lColRdv   := .T.
		    EndIf
		Next
		If !lColRdv
			lColVunit := .T.
		Endif
	EndIf
EndIf


If !Empty(cContra)
	dbSelectArea("CN9")
	dbSetOrder(1)  // Numero+Situac
	If dbSeek(xFilial("CN9")+cContra+cRev,.F.)
		cDescCtr := ALLTRIM(CN9->CN9_XXDESC)
	EndIf
EndIf	


SA1->(dbSetOrder(1))
If SA1->(dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
	If RetPessoa(SA1->A1_CGC) == "F"
		cCNPJCli := Transform(SA1->A1_CGC,"@R 999.999.999-99")
	Else
		cCNPJCli := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
	Endif
	cNomeCli	:= ALLTRIM(SA1->A1_NOME)
	//cIMCli		:= SA1->A1_INSCRM
	cEndCli		:= ALLTRIM(SA1->A1_END)
	//cBairrCli	:= SA1->A1_BAIRRO
	cCepCli		:= ALLTRIM(SA1->A1_CEP)
	cMunCli		:= ALLTRIM(SA1->A1_MUN)
	//cCodMun		:= SA1->A1_COD_MUN
	cUFCli		:= ALLTRIM(SA1->A1_EST)
	//cEmailCli	:= SA1->A1_EMAIL
	cConta		:= TRIM(SA1->A1_XXCTABC)
EndIf


//If SM0->M0_CODIGO == "01"      // BK
	cLogo := u_BKLogos()
//Endif	

If nPag == 1
	AADD(aHtml,'<html>')
	AADD(aHtml,'<head>') 
	AADD(aHtml,'<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">' )
	AADD(aHtml,'<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">' )
	AADD(aHtml,'<title>'+TRIM(SE1->E1_TIPO)+' '+cNDR+' - '+DTOC(date())+' '+TIME()+'</title>' )
	AADD(aHtml, u_BkFavIco())
	AADD(aHtml,'<style type="text/css">')

	AADD(aHtml,'.tg  {border-collapse:collapse;border-spacing:0;}')
	AADD(aHtml,'')
	AADD(aHtml,'.tg td{font-family:Arial, sans-serif;font-size:14px;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}')
	AADD(aHtml,'.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}')

	AADD(aHtml,'.tg tr { line-height: 18px; }')

	AADD(aHtml,'.tg .tg-empr{font-weight:bold;font-size:28px;text-align:center;line-height: 40px;}')
	AADD(aHtml,'.tg .tg-data{font-weight:bold;font-size:12px;text-align:center}')
	AADD(aHtml,'.tg .tg-hcliente{font-weight:bold;font-size:12px;background-color:#c0c0c0;vertical-align:top}')

	AADD(aHtml,'.tg .tg-hndr{font-weight:bold;font-size:12px;background-color:#c0c0c0;text-align:center;vertical-align:top}')

	AADD(aHtml,'.tg .tg-cliente{font-weight:bold;font-size:14px;vertical-align:top}')
	AADD(aHtml,'.tg .tg-ndr{font-weight:bold;font-size:14px;text-align:center;vertical-align:top}')
	
	AADD(aHtml,'.tg .tg-hmens{font-weight:bold;font-size:14px;text-align:center;vertical-align:center;line-height: 30px;background-color:#c0c0c0;}')
	AADD(aHtml,'.tg .tg-mens{font-weight:bold;font-size:12px;text-align:center;vertical-align:center;line-height: 30px;}')

	AADD(aHtml,'.tg .tg-hdesc{font-weight:bold;background-color:#c0c0c0;font-size:14px;vertical-align:middle;min-width:300px}')
	AADD(aHtml,'.tg .tg-desc{font-size:12px;vertical-align:middle;min-width:300px}')

	AADD(aHtml,'.tg .tg-hrdv{font-weight:bold;background-color:#c0c0c0;font-size:14px;vertical-align:middle;text-align:center}')
	AADD(aHtml,'.tg .tg-rdv{font-size:12px;vertical-align:middle;text-align:center}')

	AADD(aHtml,'.tg .tg-hsc{font-weight:bold;background-color:#c0c0c0;font-size:14px;vertical-align:middle;text-align:center}')
	AADD(aHtml,'.tg .tg-sc{font-size:12px;vertical-align:middle;;text-align:center}')
	//AADD(aHtml,'.tg .tg-tx{font-size:10px;vertical-align:middle;text-align:center}')
	
	AADD(aHtml,'.tg .tg-hvalor{font-weight:bold;background-color:#c0c0c0;font-size:14px;vertical-align:middle;min-width:40px;text-align:center}')
	AADD(aHtml,'.tg .tg-valor{font-size:12px;vertical-align:middle;min-width:100px;text-align:right;padding-right:10px}')
	
	AADD(aHtml,'.tg .tg-hobs{font-weight:bold;font-size:12px;background-color:#c0c0c0;text-align:center;vertical-align:top}')
	AADD(aHtml,'.tg .tg-obs{font-weight:bold;font-size:12px;vertical-align:middle;max-width:200px;text-align:center;}')

	AADD(aHtml,'.tg .tg-vtotal{font-weight:bold;font-size:14px;vertical-align:middle;min-width:100px;text-align:right;padding-right:10px}')

	AADD(aHtml,'.folha {page-break-after:always;page-break-inside:avoid;}')
	
	AADD(aHtml,'</style>' )
	AADD(aHtml,'</head>' )
	AADD(aHtml,'<body lang=PT-BR>' )
EndIf                                 

AADD(aHtml,'<div class="folha">')

AADD(aHtml,'<table class="tg">')

AADD(aHtml,'<colgroup>')
If lColRdv .or. lColVunit
	AADD(aHtml,'<col style="width: 300px">')
Else
	AADD(aHtml,'<col style="width: 500px">')
EndIf
If lColFinal
	AADD(aHtml,'<col style="width: 060px">')
	AADD(aHtml,'<col style="width: 060px">')
Else
	AADD(aHtml,'<col style="width: 100px">')
	AADD(aHtml,'<col style="width: 001px">')
EndIf

AADD(aHtml,'<col style="width: 060px">')

If lColRdv .or. lColVunit
	AADD(aHtml,'<col style="width: 200px">')
Else
	AADD(aHtml,'<col style="width: 001px">')
EndIf                               

AADD(aHtml,'<col style="width: 160px">')
AADD(aHtml,'</colgroup>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'  	<td colspan="6">')
AADD(aHtml,'  </tr>')

AADD(aHtml,'    <tr>')

If EMPTY(cLogo)
	AADD(aHtml,'    <td class="tg-empr" colspan="3">'+FWEmpName(cEmpAnt)+'</td>')
Else
	AADD(aHtml,'    <td class="tg-empr" colspan="3">'+cLogo+'</td>')
Endif

AADD(aHtml,'      <td class="tg-data" colspan="2" >')
AADD(aHtml,'      '+cNomeCom+'<br>')
AADD(aHtml,'      '+cEndereco+'<br>')
AADD(aHtml,'      '+cCep+" - "+cCidade+'<br>')
AADD(aHtml,'      '+cSite+'</td>')
AADD(aHtml,'      <td class="tg-data">')
AADD(aHtml,'      '+cTel+'<br>')
AADD(aHtml,'      '+cCnpj+'<br>')
AADD(aHtml,'      '+cIE+'<br>')
AADD(aHtml,'      </td>')
AADD(aHtml,'    </tr>')
  
AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-empr" colspan="6">'+cTipoTit+'</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-hcliente" colspan="4">'+iIf(lColRdv,"Nome","Descri��o")+'</td>')
AADD(aHtml,'      <td class="tg-hndr">CNPJ</td>')
AADD(aHtml,'      <td class="tg-hndr">'+IIF(SE1->E1_TIPO=="NDC","NDR",SE1->E1_TIPO)+'</td>')
AADD(aHtml,'    </tr>')
AADD(aHtml,'    <tr>')

AADD(aHtml,'      <td class="tg-cliente" colspan="4">'+cNomeCli+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cCNPJCli+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cNDR+'</td>')
AADD(aHtml,'    </tr>')
    
AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-hcliente" colspan="5">Endere�o</td>')
AADD(aHtml,'      <td class="tg-hndr">Vencimento</td>')
AADD(aHtml,'    </tr>')
AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-cliente" colspan="5">'+cEndCli+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cVencto+'</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-hcliente" colspan="3">Munic�pio</td>')
AADD(aHtml,'      <td class="tg-hndr">UF</td>')
AADD(aHtml,'      <td class="tg-hndr">CEP</td>')
AADD(aHtml,'      <td class="tg-hndr">Emiss�o</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-cliente" colspan="3">'+cMunCli+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cUFCli+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cCepCli+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cEmissao+'</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,' <tr>')
If SE1->E1_TIPO == "NDC" .AND. !EMPTY(cDescCtr)
	AADD(aHtml,'    <td class="tg-hmens" colspan="6">Referente � despesas do Contrato '+cDescCtr+', conforme segue:')
Else
	AADD(aHtml,'    <td class="tg-hmens" colspan="6">'+ALLTRIM(SE1->E1_HIST))
EndIf
AADD(aHtml,'    </td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-mens" colspan="6">'+cRefComp)
AADD(aHtml,'    </td>')
AADD(aHtml,'  </tr>')

//AADD(aHtml,'    <tr>')
//AADD(aHtml,'    	<td colspan="6">')
//AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-mens" colspan="6">Prezado(s) Senhor(es). Comunicamos que levamos a d�bito de sua conta o(s) valor(es) abaixo discriminado(s), cuja liquida��o aguardamos na data do vencimento.')
AADD(aHtml,'      </td>')
AADD(aHtml,'    </tr>')

If Len(aItens) > 0
	If cTipoNDC <> "2"


		If cTipoNDC == "3"
			AADD(aHtml,' <tr>')
			AADD(aHtml,'    <td class="tg-hdesc" colspan="6">Descri��o</td>')
			AADD(aHtml,'  </tr>')

			cItem := cTexUn
			AADD(aHtml,'  <tr>')
			AADD(aHtml,'    <td class="tg-desc" colspan="6">'+cItem+'</td>')
			AADD(aHtml,'  </tr>')
		EndIf


		AADD(aHtml,'  <tr>')
		AADD(aHtml,'    <td class="tg-hdesc">Nome</td>')
		If lColFInal
			AADD(aHtml,'    <td class="tg-hsc">In�cio</td>')
			AADD(aHtml,'    <td class="tg-hsc">Final</td>')
		Else
			AADD(aHtml,'    <td class="tg-hsc" colspan="2">Data</td>')
		EndIf
		If lColRdv .or. lColVunit
			AADD(aHtml,'    <td class="tg-hsc">Quant.</td>')
			If !lColVunit
				AADD(aHtml,'    <td class="tg-hrdv">N� RDV</td>')
			Else
				AADD(aHtml,'    <td class="tg-hrdv">Vl.Unit.</td>')
			EndIf
		Else
			AADD(aHtml,'    <td class="tg-hsc" colspan="2">Quant.</td>')
		EndIf

		AADD(aHtml,'    <td class="tg-hvalor">Valor</td>')
		AADD(aHtml,'  </tr>')
		For nI := 1 To Len(aItens)
			AADD(aHtml,'  <tr>')
			AADD(aHtml,'    <td class="tg-desc">'+aItens[nI,1]+'</td>')
			If lColFinal
				AADD(aHtml,'    <td class="tg-sc">'+aItens[nI,2]+'</td>')
				AADD(aHtml,'    <td class="tg-sc">'+aItens[nI,3]+'</td>')
			Else
				AADD(aHtml,'    <td class="tg-sc" colspan="2">'+aItens[nI,2]+'</td>')
			EndIf
			If lColRdv .or. lColVunit
				AADD(aHtml,'    <td class="tg-sc">'+aItens[nI,4]+'</td>')
				If !lColVunit
					AADD(aHtml,'    <td class="tg-rdv">'+aItens[nI,5]+'</td>')
				Else
					nQuant := Val(aItens[nI,4])
					If  nQuant > 0
						cVTot  := StrTran(aItens[nI,6],".","")
						cVTot  := StrTran(cVTot,",",".")
						nVUnit := ROUND(Val(cVTot) / Val(aItens[nI,4]),2)
						cVunit := ALLTRIM(TRANSFORM(nVUnit,cPict))
					EndIf
					AADD(aHtml,'    <td class="tg-rdv">R$ '+cVunit+'</td>')
				EndIf
			Else
				AADD(aHtml,'    <td class="tg-sc" colspan="2">'+aItens[nI,4]+'</td>')
			EndIf
			AADD(aHtml,'    <td class="tg-valor">R$ '+aItens[nI,6]+'</td>')
			AADD(aHtml,'  </tr>')
		Next
	
		AADD(aHtml,'  <tr>')
		AADD(aHtml,'    <td class="tg-obs" colspan="5"></td>')
		AADD(aHtml,'    <td class="tg-vtotal">R$ '+cTotal+'</td>')
		AADD(aHtml,'  </tr>')


		AADD(aHtml,'  <tr>')
		AADD(aHtml,'    <td class="tg-obs" colspan="5">'+IIF(VAL(cTaxa)>0,'A FATURAR COM A TAXA DE '+cTaxa,'')+' ('+Extenso(SE1->E1_VALOR)+')</td>')
		AADD(aHtml,'    <td class="tg-vtotal">R$ '+ALLTRIM(TRANSFORM(SE1->E1_VALOR,cPict))+'</td>')
		AADD(aHtml,'  </tr>')
			
	Else
	
		AADD(aHtml,' <tr>')
		AADD(aHtml,'    <td class="tg-hdesc" colspan="5">Descri��o</td>')
		AADD(aHtml,'    <td class="tg-hvalor">Valor</td>')
		AADD(aHtml,'  </tr>')

		cItem := cTexUn
		//cItem := STRTRAN(cTexUn,CRLF,'<br>')
		
		//For nI := 1 To Len(aItens)
		//	cItem += aItens[nI,1]+'<br>'
		//Next

		AADD(aHtml,'  <tr>')
		AADD(aHtml,'    <td class="tg-desc" colspan="5">'+cItem+'</td>')
		AADD(aHtml,'    <td class="tg-valor">&nbsp;</td>')
		AADD(aHtml,'  </tr>')
		
		AADD(aHtml,' <tr>')
		AADD(aHtml,'    <td class="tg-obs" colspan="5">('+Extenso(SE1->E1_VALOR)+')</td>')
		AADD(aHtml,'    <td class="tg-vtotal">R$ '+ALLTRIM(TRANSFORM(SE1->E1_VALOR,cPict))+'</td>')
		AADD(aHtml,'  </tr>')
	
	EndIf
EndIf

If !Empty(cConta) .AND. !("DADOS BANC" $ UPPER(cItem))
	AADD(aHtml,'  <tr>')
	AADD(aHtml,'  	<td class="tg-obs" colspan="6">DADOS BANC�RIOS: '+ALLTRIM(cConta)+'</td>')
	AADD(aHtml,'  </tr>')
EndIf

AADD(aHtml,'  <tr>')
AADD(aHtml,'  	<td colspan="6"></td>')
AADD(aHtml,'  </tr>')


AADD(aHtml,'</table>')
AADD(aHtml,'<br>')
AADD(aHtml,'<br>')
AADD(aHtml,'</div>')

AADD(aHtml,'</body>')
AADD(aHtml,'</html>')


Return(aHtml)

