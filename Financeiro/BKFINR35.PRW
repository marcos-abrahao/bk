#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"       

//-------------------------------------------------------------------
/*/{Protheus.doc} BKFINR35
BK - Impressão da Nota de Débito / Recibo Fatura - HTML
@Return
@author Marcos Bispo Abrahão
@since 29/02/2024
@version P11
/*/
//-------------------------------------------------------------------

User Function BKFINR35() 
Local aArea     := GetArea()
Local nHandle   := 0
Local cCrLf     := Chr(13) + Chr(10)
Local cDirTmp   := "C:\TMP"
Local cArqHtml  := cDirTmp+"\"+"MED"+ALLTRIM(SE1->E1_NUM)+".HTML"
Local aHtml     := {}
Local _nI       := 0
Private cProg   := "BKFINR35"

IF SE1->E1_PREFIXO <> "MED" .OR. ('-' $ SE1->E1_TIPO)
 	u_MsgLog(cProg,"Titulo selecionado não é Nota de Débito de Medição","W")
	RETURN NIL
ENDIF
u_MsgLog(cProg)

IF !EMPTY(cDirTmp)
   MakeDir(cDirTmp)
ENDIF   

fErase(cArqHtml)

nHandle := MsfCreate(cArqHtml,0)
   
If nHandle > 0

	aHtml := NdcHtml()   
      
	FOR _nI := 1 TO LEN(aHtml)
		fWrite(nHandle, aHtml[_nI] + cCrLf )
	NEXT
      
	fClose(nHandle)

	ShellExecute("open", cArqHtml, "", "", 1)

EndIf

RestArea(aArea)

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
Local cBairrCli := ""
Local cMunCli   := ""
Local cUFCli    := ""
Local cCepCli   := ""
Local cCNPJCli  := ""
Local cTipoTit  := "NOTA DÉBITO / RECIBO FATURA (AR)"

// Dados da NDC
Local cEmissao  := DTOC(SE1->E1_EMISSAO)
Local cVencto   := DTOC(SE1->E1_VENCTO)
Local cNDR      := ALLTRIM(SE1->E1_NUM)                
                     
Local cContra   := SE1->E1_XXCUSTO
Local cDescCtr  := SE1->E1_XXCUSTO
Local cRev      := SE1->E1_XXREV

Local cCompe    := SUBSTR(SE1->E1_XXCOMPE,5,2)+'/'+SUBSTR(SE1->E1_XXCOMPE,1,4)
Local cNumMed   := SE1->E1_XXMED
Local cConta	:= ""
Local nValor	:= SE1->E1_VALOR
Local nVRetIrf	:= SE1->E1_VRETIRF
Local nPRetIrf	:= Posicione("SED",1,xFilial("SED")+SE1->E1_NATUREZ,"ED_PERCIRF")

// Itens
Local nTamTex   := 0
Local cTexto    := SE1->E1_XXNDDES
Local cTexUn	:= ""
Local cPag2		:= ""

nTamTex := MlCount(cTexto, 254)
	
For nI := 1 To nTamTex
	cLinha := MemoLine(cTexto, 254, nI)
	cTexUn += cLinha +'<br>'
Next


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
	cBairrCli	:= SA1->A1_BAIRRO
	cCepCli		:= ALLTRIM(SA1->A1_CEP)
	cMunCli		:= ALLTRIM(SA1->A1_MUN)
	//cCodMun		:= SA1->A1_COD_MUN
	cUFCli		:= ALLTRIM(SA1->A1_EST)
	//cEmailCli	:= SA1->A1_EMAIL
	cConta		:= ALLTRIM(SA1->A1_XXCTABC)
EndIf

If Empty(cConta)
	cConta := "# Informe a conta no cadastro de clientes #"
EndIf

If SM0->M0_CODIGO == "01"      // BK
	cLogo := '<img src="http://www.bkconsultoria.com.br/Imagens/logo_header.png" border=0>'
Endif	

If nPag == 1
	AADD(aHtml,'<html>')
	AADD(aHtml,'<head>') 
	AADD(aHtml,'<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">' )
	AADD(aHtml,'<link rel=Edit-Time-Data href="./HistD_arquivos/editdata.mso">' )
	AADD(aHtml,'<title>'+TRIM(SE1->E1_TIPO)+' '+cNDR+' - '+DTOC(date())+' '+TIME()+'</title>' )
	AADD(aHtml,'<style type="text/css">')

	AADD(aHtml,'.tg  {border-collapse:collapse;border-spacing:0;}')
	AADD(aHtml,'')
	AADD(aHtml,'.tg td{font-family:Arial, sans-serif;font-size:14px;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}')
	AADD(aHtml,'.tg th{font-family:Arial, sans-serif;font-size:14px;font-weight:normal;padding:2px 3px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;}')

	AADD(aHtml,'.tg tr { line-height: 18px; }')

	AADD(aHtml,'.tg .tg-empr{font-weight:bold;font-size:28px;text-align:center;line-height: 40px;}')
	AADD(aHtml,'.tg .tg-data{font-weight:bold;font-size:12px;text-align:center;vertical-align:center;}')
	AADD(aHtml,'.tg .tg-hcliente{font-weight:bold;font-size:12px;background-color:#c0c0c0;vertical-align:top}')

	AADD(aHtml,'.tg .tg-hndr{font-weight:bold;font-size:12px;background-color:#c0c0c0;text-align:center;vertical-align:top}')

	AADD(aHtml,'.tg .tg-cliente{font-weight:bold;font-size:14px;vertical-align:top}')
	AADD(aHtml,'.tg .tg-ndr{font-weight:bold;font-size:14px;text-align:center;vertical-align:center}')
	
	AADD(aHtml,'.tg .tg-hmens{font-weight:bold;font-size:14px;text-align:center;vertical-align:center;line-height: 30px;background-color:#c0c0c0;}')
	AADD(aHtml,'.tg .tg-mens{font-weight:bold;font-size:12px;text-align:center;vertical-align:center;line-height: 14px;}')

	AADD(aHtml,'.tg .tg-hsr{font-weight:bold;background-color:#c0c0c0;font-size:14px;vertical-align:middle;text-align:center}')
	AADD(aHtml,'.tg .tg-sr{font-size:12px;vertical-align:middle;text-align:center}')

	AADD(aHtml,'.tg .tg-hsc{font-weight:bold;background-color:#c0c0c0;font-size:14px;vertical-align:middle;text-align:center}')
	AADD(aHtml,'.tg .tg-sc{font-size:12px;vertical-align:middle;text-align:center}')
	
	AADD(aHtml,'.tg .tg-hobs{font-weight:bold;font-size:12px;background-color:#c0c0c0;text-align:center;vertical-align:top}')
	AADD(aHtml,'.tg .tg-obs{font-weight:bold;font-size:12px;vertical-align:middle;max-width:200px;text-align:center;}')

	AADD(aHtml,'.tg .tg-pag2{font-size:9px;vertical-align:middle;max-width:200px;text-align:justify;line-height: 16px;}')

	AADD(aHtml,'.tg .tg-vtotal{font-weight:bold;font-size:14px;vertical-align:middle;min-width:100px;text-align:right;padding-right:10px}')

	AADD(aHtml,'.folha {page-break-after:always;page-break-inside:avoid;}')
	
	AADD(aHtml,'</style>' )
	AADD(aHtml,'</head>' )
	AADD(aHtml,'<body lang=PT-BR>' )
EndIf                                 

AADD(aHtml,'<div class="folha">')

AADD(aHtml,'<table class="tg">')

AADD(aHtml,'<colgroup>')

AADD(aHtml,'<col style="width: 60px">')
AADD(aHtml,'<col style="width: 60px">')
AADD(aHtml,'<col style="width: 60px">')
AADD(aHtml,'<col style="width: 60px">')
AADD(aHtml,'<col style="width: 60px">')
AADD(aHtml,'<col style="width: 60px">')
AADD(aHtml,'<col style="width: 60px">')
AADD(aHtml,'<col style="width: 60px">')
AADD(aHtml,'<col style="width: 60px">')
AADD(aHtml,'<col style="width: 60px">')
AADD(aHtml,'<col style="width: 60px">')
AADD(aHtml,'<col style="width: 60px">')

AADD(aHtml,'</colgroup>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'  	<td colspan="12">')
AADD(aHtml,'  </tr>')

AADD(aHtml,'    <tr>')

If EMPTY(cLogo)
	AADD(aHtml,'    <td class="tg-empr" colspan="5">'+FWEmpName(cEmpAnt)+'</td>')
Else
	AADD(aHtml,'    <td class="tg-empr" colspan="5">'+cLogo+'</td>')
Endif

AADD(aHtml,'      <td class="tg-data" colspan="4" >')
AADD(aHtml,'      '+cNomeCom+'<br>')
AADD(aHtml,'      '+cEndereco+'<br>')
AADD(aHtml,'      '+cCep+" - "+cCidade+'<br>')
AADD(aHtml,'      '+cSite+'</td>')

AADD(aHtml,'      <td class="tg-data" colspan="3">')
AADD(aHtml,'      '+cTel+'<br>')
AADD(aHtml,'      '+cCnpj+'<br>')
AADD(aHtml,'      '+cIE+'<br>')
AADD(aHtml,'      </td>')
AADD(aHtml,'    </tr>')
  
AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-empr" colspan="12">'+cTipoTit+'</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-empr" colspan="12">Nº '+cNDR+'</td>')
AADD(aHtml,'    </tr>')

// Aqui falta: Emissao, vencimento, competência, cond pagamento

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-hsc" colspan="3">Emissão</td>')
AADD(aHtml,'      <td class="tg-hsc" colspan="3">Vencimento</td>')
AADD(aHtml,'      <td class="tg-hsc" colspan="3">Competência</td>')
AADD(aHtml,'      <td class="tg-hsc" colspan="3">Medição</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-sc" colspan="3">'+cEmissao+'</td>')
AADD(aHtml,'      <td class="tg-sc" colspan="3">'+cVencto+'</td>')
AADD(aHtml,'      <td class="tg-sc" colspan="3">'+cCompe+'</td>')
AADD(aHtml,'      <td class="tg-sc" colspan="3">'+cNumMed+'</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-hcliente" colspan="9">Tomador</td>')
AADD(aHtml,'      <td class="tg-hndr" colspan="3">CNPJ</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-cliente" colspan="9">'+cNomeCli+'</td>')
AADD(aHtml,'      <td class="tg-ndr" colspan="3">'+cCNPJCli+'</td>')
AADD(aHtml,'    </tr>')
    
AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-hcliente" colspan="8">Endereço</td>')
AADD(aHtml,'      <td class="tg-hndr" colspan="4">Bairro</td>')
AADD(aHtml,'    </tr>')
AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-cliente" colspan="8">'+cEndCli+'</td>')
AADD(aHtml,'      <td class="tg-ndr" colspan="4">'+cBairrCli+'</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-hcliente" colspan="10">Município</td>')
AADD(aHtml,'      <td class="tg-hndr">UF</td>')
AADD(aHtml,'      <td class="tg-hndr">CEP</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-cliente" colspan="10">'+cMunCli+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cUFCli+'</td>')
AADD(aHtml,'      <td class="tg-ndr">'+cCepCli+'</td>')
AADD(aHtml,'    </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-hmens" colspan="12">Referente ao Contrato '+cDescCtr+', conforme segue:</td>')
AADD(aHtml,'  </tr>')

If !Empty(cTexUn)
	AADD(aHtml,'  <tr>')
	AADD(aHtml,'    <td class="tg-mens" colspan="12">Observações '+cTexUn+'<br>')
	AADD(aHtml,'    </td>')
	AADD(aHtml,'  </tr>')
EndIf

//AADD(aHtml,'    <tr>')
//AADD(aHtml,'    	<td colspan="6">')
//AADD(aHtml,'    </tr>')

AADD(aHtml,'    <tr>')
AADD(aHtml,'      <td class="tg-mens" colspan="12">')

AADD(aHtml,         '<p>Prezado(s) Senhor(es). Comunicamos que levamos a débito de sua conta o valor abaixo discriminado(s), cuja liquidação aguardamos na data do vencimento.</p>')

//AADD(aHtml,         '<p>Prezado(s) Senhor(es). Comunicamos que levamos a débito de sua conta o valor abaixo discriminado(s), cuja liquidação aguardamos na data do vencimento. ')
//AADD(aHtml,         'Dados bancários para pagamento: <b>'+cConta+'</b></p>')
AADD(aHtml,'      </td>')
AADD(aHtml,'    </tr>')

If !Empty(cConta) .AND. !("DADOS BANC" $ UPPER(cTexUn))
	AADD(aHtml,'  <tr>')
	AADD(aHtml,'  	<td class="tg-obs" colspan="12">DADOS BANCÁRIOS PARA PAGAMENTO: '+ALLTRIM(cConta)+'</td>')
	AADD(aHtml,'  </tr>')
EndIf

AADD(aHtml,' <tr>')
AADD(aHtml,'    <td class="tg-hsc">Item</td>')
AADD(aHtml,'    <td class="tg-hsr" colspan="5">Descrição</td>')
AADD(aHtml,'    <td class="tg-hsc" colspan="2">Quant.</td>')
AADD(aHtml,'    <td class="tg-hsc" colspan="2">Unit.</td>')
AADD(aHtml,'    <td class="tg-hsc" colspan="2">Total</td>')
AADD(aHtml,' </tr>')

AADD(aHtml,' <tr>')
AADD(aHtml,'    <td class="tg-sc">1</td>')
AADD(aHtml,'    <td class="tg-sr" colspan="5">LOCAÇÃO DE BENS MÓVEIS</td>')
AADD(aHtml,'    <td class="tg-sc" colspan="2">1</td>')
AADD(aHtml,'    <td class="tg-sc" colspan="2">'+ALLTRIM(TRANSFORM(nValor,cPict))+'</td>')
AADD(aHtml,'    <td class="tg-sc" colspan="2">'+ALLTRIM(TRANSFORM(nValor,cPict))+'</td>')
AADD(aHtml,' </tr>')


AADD(aHtml,' <tr>')
AADD(aHtml,'    <td class="tg-hsr" colspan="4">Valor Total</td>')
AADD(aHtml,'    <td class="tg-hsc" colspan="4">IRRF '+PicPer(nPRetIrf,5,2)+'%'+'</td>')
AADD(aHtml,'    <td class="tg-hsc" colspan="4">Valor Líquido</td>')
AADD(aHtml,' </tr>')


AADD(aHtml,' <tr>')
AADD(aHtml,'    <td class="tg-sc" colspan="4">'+ALLTRIM(TRANSFORM(nValor,cPict))+'</td>')
AADD(aHtml,'    <td class="tg-sc" colspan="4">'+ALLTRIM(TRANSFORM(nVRetIrf,cPict))+'</td>')
AADD(aHtml,'    <td class="tg-sc" colspan="4">'+ALLTRIM(TRANSFORM(nValor - nVretIrf,cPict))+'</td>')
AADD(aHtml,' </tr>')

/*
AADD(aHtml,' <tr>')
AADD(aHtml,'    <td class="tg-obs" colspan="10">('+Extenso(SE1->E1_VALOR)+')</td>')
AADD(aHtml,'    <td class="tg-vtotal" colspan="2">R$ '+ALLTRIM(TRANSFORM(SE1->E1_VALOR,cPict))+'</td>')
AADD(aHtml,'  </tr>')
*/

AADD(aHtml,'  <tr>')
AADD(aHtml,'    <td class="tg-hsr" colspan="12">OBSERVAÇÕES</td>')
AADD(aHtml,'  </tr>')

// Observações
BEGINCONTENT VAR cPag2

<br>
<p>INEXISTÊNCIA DE FATO GERADOR DE ISS</p>
<p>OBS 1: O RAMO DE LOCAÇÃO DE BENS MÓVEIS EMITE NOTA DE DÉBITO POR ESTAR IMPOSSIBILITADO DE EMISSÃO DE NOTA FISCAL COM BASE NOS TERMOS DO ARTIGO 7° DA LC N° 116/2003 E NA JURISPRUDÊNCIA DA SÚMULA 31 DO SUPREMO TRIBUNAL FEDERAL.</p>
<p>O ARTIGO 1º DA LEI COMPLEMENTAR 116/2003 DISPÕE QUE O ISS TEM COMO FATO GERADOR A PRESTAÇÃO DE SERVIÇOS CONSTANTE NA LISTA ANEXA.</p>
<p>A LOCAÇÃO DE BENS MÓVEIS NÃO CONSTITUI UMA PRESTAÇÃO DE SERVIÇOS, POIS NÃO É ITEM CONSTANTE NA LISTA DE SERVIÇOS ANEXA À REFERIDA LEI COMPLEMENTAR.  TRATA-SE MERAMENTE DE UMA DISPONIBILIZAÇÃO DE BEM, SEJA ELE IMÓVEL OU MÓVEL PARA UTILIZAÇÃO DO LOCATÁRIO SEM, ENTRETANTO, CARACTERIZAR A PRESTAÇÃO DE UM SERVIÇO.
RESSALTA-SE QUE A LOCAÇÃO DE BENS MÓVEIS IRIA FAZER PARTE DO ITEM 3.01 (LOCAÇÃO DE BENS MÓVEIS) DA LISTA DA LEI COMPLEMENTAR 116/2003, NO ENTANTO FOI OBJETO DE VETO PELO PRESIDENTE DA REPÚBLICA.
ADIANTE, A TRANSCRIÇÃO DA RAZÃO AO VETO PELA PRESIDÊNCIA:</p>
<p>"3.01 - LOCAÇÃO DE BENS MÓVEIS."</p>

<p>- ADMINISTRAÇÃO, LOCAÇÃO OU CESSÃO DE BENS IMÓVEIS, MÓVEIS E DIREITOS DE QUALQUER NATUREZA;</p>
<p>RETENÇÃO DE IRRF <b>#PERCIRF#%</b> - CONFORME A IN RFB Nº 1.234/12, SUBSTITUÍDA PELA IN RFB Nº 2.145/23.</p>
<br>
ENDCONTENT

cPag2 := STRTRAN(cPag2,"#PERCIRF#",PicPer(nPRetIrf,5,2))

AADD(aHtml,'  <tr>')
AADD(aHtml,'  	<td colspan="12" class="tg-pag2">'+cPag2+'</td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'  	<td colspan="12"></td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'</table>')
AADD(aHtml,'<br>')
AADD(aHtml,'<br>')
AADD(aHtml,'</div>')

/*
AADD(aHtml,'<div class="folha">')
AADD(aHtml,'<table class="tg">')

AADD(aHtml,'<colgroup>')
AADD(aHtml,'<col style="width: 720px">')
AADD(aHtml,'</colgroup>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'  	<td></td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'  	<td class="tg-pag2">'+cPag2+'</td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'  <tr>')
AADD(aHtml,'  	<td></td>')
AADD(aHtml,'  </tr>')

AADD(aHtml,'</table>')
AADD(aHtml,'<br>')
AADD(aHtml,'<br>')
AADD(aHtml,'</div>')
*/

// Final do Html
AADD(aHtml,'</body>')
AADD(aHtml,'</html>')


Return(aHtml)



// Retorna o Percentual em caracteres sem .00 no final
Static Function PicPer(nAliq,nT,nD)
Local cAliq := ALLTRIM(STR(nAliq,nT,nD))
If ("."+Replicate("0",nD)) $ cAliq
	cAliq := STRTRAN(cAliq,"."+Replicate("0",nD),"")
EndIf
Return cAliq
